import 'package:flutter/material.dart';
import 'package:pvadmin/servico/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pvadmin/database/dbHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pvadmin/visao/endereco/create.dart';
import 'package:pvadmin/visao/endereco/edit.dart';
import 'package:pvadmin/visao/endereco/index.dart';
import 'package:pvadmin/visao/loja/index.dart';
import 'package:pvadmin/visao/produtos/index.dart';
import 'package:pvadmin/visao/promocao/index.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String imageUrl = '';
  late final FirebaseAuth _auth;
  late final User? user;
  FirebaseFirestore db = DBFirestore.get();
  DocumentSnapshot? snapshot;

  @override
  void initState() {
    super.initState();

    _auth = FirebaseAuth.instance;
    user = _auth.currentUser;
    db.collection('lojas').doc(user?.uid).get().then(
      (DocumentSnapshot docSnapshot) {
        setState(
          () {
            snapshot = docSnapshot;
            imageUrl = docSnapshot.get('imagem');
          },
        );
      },
    );
  }

  String getNomeFromSnapshot(DocumentSnapshot? snapshot) {
    if (snapshot != null && snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['nome'];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final nome = getNomeFromSnapshot(snapshot);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF672F67),
        
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF672F67).withOpacity(0.4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(60),
                      color: Color.fromARGB(255, 216, 216, 216),
                    ),
                    child: imageUrl == ""
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )
                        : ClipOval(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Image.network(
                                imageUrl,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 65,
                      ),
                      Container(
                        width: 160,
                        height: 30,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    LojaIndex(context.read<AuthService>()),
                              ),
                            );
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              nome,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '  Administrador',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.store,
                color: Color(0xFF7A8727),
              ),
              title: Text('Sua loja'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        LojaIndex(context.read<AuthService>()),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Color(0xFF7A8727),
              ),
              title: Text('Endereços'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EnderecosIndex(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Color(0xFF7A8727),
              ),
              title: Text('Sair'),
              onTap: () => context.read<AuthService>().logout(),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProdutosIndex(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        primary: Colors.white,
                        onPrimary: Color(0xFF7A8727),
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Color(0xFF7A8727), width: 1),
                        ),
                        minimumSize: Size(140, 70)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Produtos'),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.fastfood,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PromocaoIndex(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        primary: Colors.white,
                        onPrimary: Color(0xFF7A8727),
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Color(0xFF7A8727), width: 1),
                        ),
                        minimumSize: Size(140, 70)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Promoções'),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.local_offer,
                          size: 25,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
