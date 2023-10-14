import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pvadmin/modelo/Classificacao.dart';

class ClassificacaoController {
  final CollectionReference _classificacaoCollection =
      FirebaseFirestore.instance.collection('classificacao');

  // Adiciona um novo classificacao ao Firestore
  Future<void> adicionarclassificacao(Classificacao classificacao) async {
    try {
      await _classificacaoCollection.add(classificacao.toMap());
    } catch (e) {
      print('Erro ao adicionar o classificacao: $e');
    }
  }

  // Atualiza os dados de um Classificacao no Firestore
  Future<void> atualizarClassificacao(Classificacao classificacao) async {
    try {
      await _classificacaoCollection.doc(classificacao.id).update(classificacao.toMap());
    } catch (e) {
      print('Erro ao atualizar o classificacao: $e');
    }
  }

  // Exclui um classificacao do Firestore
  Future<void> excluirclassificacao(String classificacaoId) async {
    try {
      await _classificacaoCollection.doc(classificacaoId).delete();
    } catch (e) {
      print('Erro ao excluir o classificacao: $e');
    }
  }

  // Obtém uma lista de todos os classificacaos do Firestore
  Stream<List<Classificacao>> getclassificacaos() {
    return _classificacaoCollection.snapshots().map((snapshot) {
      return snapshot.docs.map(
        (doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            return Classificacao.fromMap(data, doc.id);
          } else {
            throw Exception(
                'A classificacao: ${doc.id} não existe.');
          }
        },
      ).toList();
    });
  }
}
