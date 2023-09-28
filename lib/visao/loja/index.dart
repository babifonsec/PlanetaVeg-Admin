import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pvadmin/controle/LojaController.dart';
import 'package:pvadmin/database/dbHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pvadmin/modelo/Loja.dart';
import 'package:pvadmin/servico/auth_service.dart';
import 'package:provider/provider.dart';

class LojaIndex extends StatefulWidget {
  late AuthService auth;
  LojaIndex(this.auth);

  @override
  State<LojaIndex> createState() => _LojaIndexState(auth: auth);
}

class _LojaIndexState extends State<LojaIndex> {
  @override
  final key = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final cnpjController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  FirebaseStorage storage = FBStorage.get(); //recupera a instancia do storage
  FirebaseFirestore db = DBFirestore.get(); //recupera a instancia do firestore

  late AuthService auth;
  _LojaIndexState({required this.auth});

  bool uploading = false;
  double total = 0;
  String imageUrl = '';
  String lojaImageUrl = '';

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<UploadTask> upload(String path) async {
    File file = File(path);
    try {
      String ref = 'images/img-${DateTime.now().toString()}.jpg';
      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }

  pickAndUpload() async {
    XFile? file = await getImage();
    if (file != null) {
      UploadTask task = await upload(file.path);

      task.snapshotEvents.listen((TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.running) {
          setState(() {
            uploading = true;
          });
        } else if (snapshot.state == TaskState.success) {
          imageUrl = await snapshot.ref.getDownloadURL();
          setState(() {
            uploading = false;
            lojaImageUrl = imageUrl;
          });
        }
      });
    }
  }

  Future<void> loadlojaData() async {
    try {
      User? currentUser = auth.usuario;
      String? userId = currentUser?.uid;

      if (userId != null) {
        DocumentSnapshot snapshot =
            await db.collection('lojas').doc(userId).get();
        if (snapshot.exists) {
          setState(() {
            nomeController.text = snapshot.get('nome');
            telefoneController.text = snapshot.get('telefone');
            cnpjController.text = snapshot.get('cnpj');
            lojaImageUrl = snapshot.get('imagem');
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados do loja: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadlojaData(); // Carrega os dados do loja ao abrir a tela
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF672F67),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () => pickAndUpload(),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 243, 243, 243),
                      border: Border.all(
                        width: 2,
                        color: Color.fromARGB(255, 105, 105, 105),
                      ),
                    ),
                    child: Stack(
                      children: [
                        uploading
                            ? Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Color(0xFF7A8727),
                                ),
                              )
                            : lojaImageUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      lojaImageUrl,
                                      width: 130,
                                      height: 130,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.edit,
                                size: 20,
                                color: Color.fromARGB(255, 105, 105, 105)),
                            onPressed: () {
                              // Aqui você pode adicionar a lógica para a ação de edição
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: TextFormField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      suffixIcon: Icon(Icons.edit),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: TextFormField(
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Telefone',
                      suffixIcon: Icon(Icons.edit),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: cnpjController,
                    enabled: !cnpjController.text.isNotEmpty,
                    decoration: InputDecoration(
                      labelText: 'CNPJ',
                      suffixIcon: Icon(Icons.edit),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: 160,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<LojaController>().adicionarOuAtualizarLoja(
                            user!.uid,
                            Loja(nomeController.text, cnpjController.text,
                                telefoneController.text, lojaImageUrl),
                          );
                          Fluttertoast.showToast(
                    msg: "Perfil atualizado com sucesso",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Color(0xFF672F67),
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                    },
                    child: Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF7A8727)),
                      fixedSize: MaterialStateProperty.all<Size>(Size(180, 50)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
