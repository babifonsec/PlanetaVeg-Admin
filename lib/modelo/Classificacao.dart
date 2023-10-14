class Classificacao {
  late String _id;
  late String _nome;

  Classificacao(this._id, this._nome);

  Classificacao.map(dynamic obj) {
    this._id = obj['id'];
    this._nome = obj['nome'];
  }

  String get id => _id;
  String get nome => _nome;

  // Converte o objeto Loja em um mapa que pode ser armazenado no Firestore
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    if (_id != null) {
      map['id'] = _id;
    }
    map['nome'] = _nome;
    return map;
  }

  Classificacao.fromMap(Map<String, dynamic> map, String id) {
    this._id = id ?? '';
    this._nome = map['nome'] ?? '';
  }
}