import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pvadmin/controle/ProdutoController.dart';
import 'package:pvadmin/database/dbHelper.dart';
import 'package:pvadmin/servico/auth_service.dart';
import 'package:pvadmin/visao/produtos/create.dart';
import 'package:provider/provider.dart';
import 'package:pvadmin/visao/produtos/edit.dart';

class ProdutosIndex extends StatefulWidget {
  const ProdutosIndex({super.key});

  @override
  State<ProdutosIndex> createState() => _ProdutosIndexState();
}

class _ProdutosIndexState extends State<ProdutosIndex> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore db = DBFirestore.get();
  ProdutoController produto = ProdutoController();

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF672F67),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF672F67),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProdutosCreate(
                auth: context.read<AuthService>(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Seus Produtos:',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF7A8727),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('produtos')
                  .where('uidLoja', isEqualTo: user?.uid)
                  .snapshots(), //consulta para retornar apenas os produtos da loja logada
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Nenhum produto encontrado.'),
                  );
                }

                // Exibe a lista de produtos
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot productDoc =
                        snapshot.data!.docs[index];
                    final productData =
                        productDoc.data() as Map<String, dynamic>;
                   String? produtoId = productDoc.id;

                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 5, right: 10, bottom: 5, top: 5),
                      child: Container(
                        height: 60,
                        child: ListTile(
                          leading: const Icon(
                            Icons.fastfood,
                            color: Color(0xFF7A8727),
                          ),
                          title: Text(productData['nome'] ?? ''),
                          subtitle: Text(productData['descricao'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.grey),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProdutosEdit(produtoId: produtoId,),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.grey),
                                onPressed: () {
                                  String? produtoUid = productDoc.id;
                                  if (produtoUid != null) {
                                    context
                                        .read<ProdutoController>()
                                        .excluirProduto(produtoUid);
                                  } else {
                                   throw Exception('UID do produto ausente ou nulo.');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
