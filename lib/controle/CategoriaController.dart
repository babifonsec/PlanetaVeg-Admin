import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pvadmin/modelo/Categoria.dart';

class CategoriaController {
  final CollectionReference _categoriasCollection =
      FirebaseFirestore.instance.collection('categorias');

  // Adiciona um novo categoria ao Firestore
  Future<void> adicionarcategoria(Categoria categoria) async {
    try {
      await _categoriasCollection.add(categoria.toMap());
    } catch (e) {
      print('Erro ao adicionar o categoria: $e');
    }
  }

  // Atualiza os dados de um categoria no Firestore
  Future<void> atualizarcategoria(Categoria categoria) async {
    try {
      await _categoriasCollection.doc(categoria.id).update(categoria.toMap());
    } catch (e) {
      print('Erro ao atualizar o categoria: $e');
    }
  }

  // Exclui um categoria do Firestore
  Future<void> excluircategoria(String categoriaId) async {
    try {
      await _categoriasCollection.doc(categoriaId).delete();
    } catch (e) {
      print('Erro ao excluir o categoria: $e');
    }
  }

  // Obtém uma lista de todos os categorias do Firestore
  Stream<List<Categoria>> getCategorias() {
    return _categoriasCollection.snapshots().map((snapshot) {
      return snapshot.docs.map(
        (doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            return Categoria.fromMap(data, doc.id);
          } else {
            throw Exception(
                'A categoria: ${doc.id} não existe.');
          }
        },
      ).toList();
    });
  }
}
