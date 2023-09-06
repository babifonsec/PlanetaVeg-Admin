import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pvadmin/controle/PromocaoController.dart';
import 'package:pvadmin/database/dbHelper.dart';
import 'package:pvadmin/servico/auth_service.dart';
import 'package:pvadmin/visao/promocao/create.dart';
import 'package:provider/provider.dart';
import 'package:pvadmin/visao/promocao/edit.dart';

class PromocaoIndex extends StatefulWidget {
  const PromocaoIndex({super.key});

  @override
  State<PromocaoIndex> createState() => _PromocaoIndexState();
}

class _PromocaoIndexState extends State<PromocaoIndex> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore db = DBFirestore.get();
  PromocaoController promocao = PromocaoController();

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
              builder: (context) => PromocaoCreate(
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
                ' Promoções:',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF7A8727),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('promocoes')
                  .where('uidLoja', isEqualTo: user?.uid)
                  .snapshots(), //consulta para retornar apenas os Promocao da loja logada
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
                    child: Text('Nenhuma promoção encontrada.'),
                  );
                }

                // Exibe a lista de Promocao
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot promocaoDoc =
                        snapshot.data!.docs[index];
                    final promocaoData =
                        promocaoDoc.data() as Map<String, dynamic>;
                   String? promocaoId = promocaoDoc.id;

                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 5, right: 10, bottom: 5, top: 5),
                      child: Container(
                        height: 60,
                        child: ListTile(
                          leading: const Icon(
                            Icons.local_offer,
                            color: Color(0xFF7A8727),
                          ),
                          title: Text(promocaoData['nome'] ?? ''),
                          subtitle: Text(promocaoData['descricao'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.grey),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PromocaoEdit(promocaoId: promocaoId,),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.grey),
                                onPressed: () {
                                  String? promocaoUid = promocaoDoc.id;
                                  if (promocaoUid != null) {
                                    context
                                        .read<PromocaoController>()
                                        .excluirPromocao(promocaoUid);
                                  } else {
                                   throw Exception('UID da promocao ausente ou nulo.');
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
