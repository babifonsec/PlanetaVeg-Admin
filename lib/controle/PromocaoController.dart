import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pvadmin/modelo/Promocao.dart';

class PromocaoController with ChangeNotifier {
  final CollectionReference _promocaoCollection =
      FirebaseFirestore.instance.collection('promocoes');

  // Adiciona um novo promocao ao Firestore
  Future<void> adicionarPromocao(Promocao promocao) async {
    try {
      await _promocaoCollection.add(promocao.toMap());
    } catch (e) {
      print('Erro ao adicionar o promocao: $e');
    }
  }

  // Atualiza os dados de um promocao no Firestore
  Future<void> atualizarPromocao(String promocaoUid, Promocao promocao) async {
    try {
      final DocumentReference promocaoRef = _promocaoCollection.doc(promocaoUid);

      if (await promocaoRef.get().then((doc) => doc.exists)) {
        await promocaoRef.update(promocao.toMap());
        print('promocao atualizado com sucesso.');
      } else {
        print('Documento com UID $promocaoUid não encontrado.');
      }
    } catch (e) {
      print('Erro ao atualizar o promocao: $e');
    }
  }

  // Exclui um promocao do Firestore
  Future<void> excluirPromocao(String promocaoId) async {
    try {
      await _promocaoCollection.doc(promocaoId).delete();
    } catch (e) {
      print('Erro ao excluir promocao: $e');
    }
  }

  // Obtém uma lista de todos os promocaos do Firestore
  /**Stream<List<Promocao>> getPromocao() {
    return _promocaoCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => promocao.fromMap(doc.data(), doc.id))
          .toList();
    });
  }**/
}
