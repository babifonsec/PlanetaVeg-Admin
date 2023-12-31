import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pvadmin/controle/ClassificacaoController.dart';
import 'package:pvadmin/database/dbHelper.dart';
import 'package:pvadmin/controle/CategoriaController.dart';
import 'package:pvadmin/controle/ProdutoController.dart';
import 'package:pvadmin/modelo/Categoria.dart';
import 'package:pvadmin/modelo/Classificacao.dart';
import 'package:pvadmin/modelo/Produto.dart';

class ProdutosEdit extends StatefulWidget {
  String produtoId;
  ProdutosEdit({required this.produtoId});

  @override
  State<ProdutosEdit> createState() => _ProdutosEditState(produtoId: produtoId);
}

class _ProdutosEditState extends State<ProdutosEdit> {
  String produtoId;
  _ProdutosEditState({required this.produtoId});

  FirebaseFirestore db = DBFirestore.get();
  FirebaseStorage storage = FBStorage.get();
  bool uploading = false;
  String imageUrl = '';
  String produtoImageUrl = '';

  User? user = FirebaseAuth.instance.currentUser;
  final key = GlobalKey<FormState>();
  TextEditingController nomeController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  TextEditingController ingredientesController = TextEditingController();
  TextEditingController precoController = TextEditingController();
  TextEditingController imagemController = TextEditingController();
  final uidClassificacaoController = TextEditingController();
  TextEditingController uidCategoriaController = TextEditingController();
  ProdutoController produto = ProdutoController();
  CategoriaController categoria = CategoriaController();
  ClassificacaoController classificacao = ClassificacaoController();

  String? uidClassificacao;
  List<DropdownMenuItem<String>> classificacaoItens = [];
  String classificacaoNome = '';

  @override
  void initState() {
    super.initState();
    loadProdutoData(); // Carrega os dados do produto ao abrir a tela
  }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Cadastre seu produto:',
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
                  'Imagem: ',
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
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
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
                              : produtoImageUrl.isNotEmpty
                                  ? ClipRect(
                                      child: Image.network(
                                        produtoImageUrl,
                                        width: 130,
                                        height: 130,
                                        fit: BoxFit.cover,
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
                child: StreamBuilder<List<Classificacao>>(
                  stream: classificacao.getclassificacaos(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    // Quando os dados estiverem disponíveis, atualize a lista
                    classificacaoItens =
                        (snapshot.data ?? []).map((classificacao) {
                      return DropdownMenuItem(
                        value: classificacao.id,
                        child: Text(classificacao.nome),
                      );
                    }).toList();

                    return Container(
                      child: DropdownButtonFormField<String>(
                        value: uidClassificacao,
                        items: classificacaoItens,
                        onChanged: (value) {
                          setState(() async {
                            //OBSERVAR O SET STATE ASYNC
                            categoriaSnapshot = await db
                                .collection('classificacao')
                                .doc(value)
                                .get();
                            classificacaoNome = categoriaSnapshot.get('nome');
                            uidClassificacao = value;
                            uidClassificacaoController.text = value ?? '';
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Classificação',
                          hintText: classificacaoNome,
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
                        produto.atualizarProduto(
                          produtoId,
                          Produto(
                              nomeController.text,
                              descricaoController.text,
                              ingredientesController.text,
                              precoController.text,
                              produtoImageUrl,
                              user!.uid,
                              uidCategoriaController.text,
                              uidClassificacaoController.text),
                        );
                        Fluttertoast.showToast(
                          msg: "Produto atualizado com sucesso",
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
            produtoImageUrl = imageUrl;
            uploading = false;
          });
        }
      });
    }
  }

//carrega os dados do produto
  Future<void> loadProdutoData() async {
    try {
      if (produtoId != null) {
        DocumentSnapshot snapshot =
            await db.collection('produtos').doc(produtoId).get();
        if (snapshot.exists) {
          setState(() {
            nomeController.text = snapshot.get('nome');
            descricaoController.text = snapshot.get('descricao');
            ingredientesController.text = snapshot.get('ingredientes');
            precoController.text = snapshot.get('preco');
            produtoImageUrl = snapshot.get('imagem');
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados do cliente: $e');
    }
  }
}
