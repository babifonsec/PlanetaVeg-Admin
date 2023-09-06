import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pvadmin/controle/CategoriaController.dart';
import 'package:pvadmin/database/dbHelper.dart';
import 'package:pvadmin/modelo/Categoria.dart';
import 'package:pvadmin/modelo/Promocao.dart';
import 'package:pvadmin/servico/auth_service.dart';
import 'package:pvadmin/controle/promocaoController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PromocaoCreate extends StatefulWidget {
  final AuthService auth;
  PromocaoCreate({required this.auth});

  @override
  State<PromocaoCreate> createState() => _PromocaoCreateState(auth: auth);
}

class _PromocaoCreateState extends State<PromocaoCreate> {
  AuthService auth;
  _PromocaoCreateState({required this.auth});

  FirebaseFirestore db = DBFirestore.get();
  FirebaseStorage storage = FBStorage.get();
  bool uploading = false;
  String imageUrl = '';
  String promocaoImageUrl = '';
  User? user = FirebaseAuth.instance.currentUser;
  final key = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final ingredientesController = TextEditingController();
  final precoController = TextEditingController();
  final imagemController = TextEditingController();
  final uidCategoriaController = TextEditingController();
  final dataExpiracaoController = TextEditingController();
  PromocaoController promocao = PromocaoController();
  CategoriaController categoria = CategoriaController();


  @override
  Widget build(BuildContext context) {
    String? uidCategoria;

// lista de DropdownMenuItem para categorias
    List<DropdownMenuItem<String>> categoriaItens = [];
    DocumentSnapshot categoriaSnapshot;
    String categoriaNome = '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF672F67),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Cadastre sua promoção:',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF7A8727),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                child: Text(
                  'Banner da promoção (16:9): ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: InkWell(
                    onTap: () => pickAndUpload(),
                    child: Container(
                      width: 200,
                      height: 113.2,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 243, 243),
                        border: Border.all(
                          width: 1,
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
                              : promocaoImageUrl.isNotEmpty
                                  ? ClipRect(
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9, // Proporção 16:9
                                        child: Image.network(
                                          promocaoImageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.fastfood,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                                icon: Icon(Icons.edit,
                                    size: 23,
                                    color: Color.fromARGB(255, 105, 105, 105)),
                                onPressed: () => pickAndUpload()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome do produto',
                      suffixIcon: Icon(Icons.edit),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: descricaoController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      suffixIcon: Icon(Icons.edit),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: ingredientesController,
                    decoration: InputDecoration(
                      labelText: 'Ingredientes',
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
                    controller: precoController,
                    decoration: InputDecoration(
                      labelText: 'Preço',
                      suffixIcon: Icon(Icons.edit),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: StreamBuilder<List<Categoria>>(
                  stream: categoria.getCategorias(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    // Quando os dados estiverem disponíveis, atualize a lista categoriaItens
                    categoriaItens = (snapshot.data ?? []).map((categoria) {
                      return DropdownMenuItem(
                        value: categoria.id,
                        child: Text(categoria.nome),
                      );
                    }).toList();

                    return Container(
                      child: DropdownButtonFormField<String>(
                        value: uidCategoria,
                        items: categoriaItens,
                        onChanged: (value) {
                          setState(() async {
                            //OBSERVAR O SET STATE ASYNC
                            categoriaSnapshot = await db
                                .collection('categorias')
                                .doc(value)
                                .get();
                            categoriaNome = categoriaSnapshot.get('nome');
                            uidCategoria = value;
                            uidCategoriaController.text = value ?? '';
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Categoria',
                          hintText: categoriaNome,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Container(
                    width: 160,
                    child: OutlinedButton(
                      onPressed: () {
                       
                        promocao.adicionarPromocao(
                          Promocao(
                            precoController.text,
                            promocaoImageUrl,
                              nomeController.text,
                              descricaoController.text,
                              ingredientesController.text,
                              uidCategoriaController.text,
                               user!.uid,
                              ),
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
                        fixedSize:
                            MaterialStateProperty.all<Size>(Size(180, 50)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
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

//pegar imagem da galeria
  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

//upload da imagem para o bd
  Future<UploadTask> upload(String path) async {
    File file = File(path);
    try {
      String ref = 'images/img-${DateTime.now().toString()}.jpg';
      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }

// coordena o processo de seleção e upload da imagem
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
            promocaoImageUrl = imageUrl;
            uploading = false;
          });
        }
      });
    }
  }

}
