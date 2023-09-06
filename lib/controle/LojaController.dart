import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pvadmin/modelo/Loja.dart';

class LojaController with ChangeNotifier {
  final CollectionReference _lojasCollection =
      FirebaseFirestore.instance.collection('lojas');

  // Adiciona um novo loja ao Firestore
  Future<void> adicionarLoja(Loja loja) async {
    try {
      await _lojasCollection.add(loja.toMap());
    } catch (e) {
      print('Erro ao adicionar o loja: $e');
    }
  }

  // Atualiza os dados de um loja no Firestore
  Future<void> atualizarLoja(String lojaUid, Loja loja) async {
    try {
      final DocumentReference lojaRef = _lojasCollection.doc(lojaUid);

      if (await lojaRef.get().then((doc) => doc.exists)) {
        await lojaRef.update(loja.toMap());
        print('Loja atualizado com sucesso.');
      } else {
        print('Documento com UID $lojaUid não encontrado.');
      }
    } catch (e) {
      print('Erro ao atualizar o loja: $e');
    }
  }

  // Exclui um loja do Firestore
  Future<void> excluirLoja(String lojaId) async {
    try {
      await _lojasCollection.doc(lojaId).delete();
    } catch (e) {
      print('Erro ao excluir loja: $e');
    }
  }

  // Obtém uma lista de todos os lojas do Firestore
  /**Stream<List<loja>> getlojas() {
    return _lojasCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => loja.fromMap(doc.data(), doc.id))
          .toList();
    });
  }**/
}
