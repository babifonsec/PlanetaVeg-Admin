class Promocao {
  late String _preco;
  late String _imagem;
  late String _uidLoja;
  late String _nome;
  late String _descricao;
  late String _ingredientes;
  late String _uidCategoria;

  Promocao(
    this._preco,
    this._imagem,
    this._nome,
    this._descricao,
    this._ingredientes,
    this._uidCategoria,
    this._uidLoja,
  );

  Promocao.map(dynamic obj) {
    this._preco = obj['preco'];
    this._imagem = obj['imagem'];
    this._uidLoja = obj['uidLoja'];
    this._nome = obj['imagem'];
    this._descricao = obj['imagem'];
    this._ingredientes = obj['imagem'];
    this._uidCategoria = obj['uidCategoria'];
  }

  String get preco => _preco;
  String get imagem => _imagem;
  String get uidLoja => _uidLoja;
  String get nome => _nome;
  String get descricao => _descricao;
  String get ingredientes => _ingredientes;
  String get uidCategoria => _uidCategoria;

  // Converte o objeto Loja em um mapa que pode ser armazenado no Firestore
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['preco'] = _preco;
    map['imagem'] = _imagem;
    map['uidLoja'] = _uidLoja;
    map['nome'] = _nome;
    map['descricao'] = _descricao;
    map['ingredientes'] = _ingredientes;
    map['uidCategoria'] = _uidCategoria;

    return map;
  }

  Promocao.fromMap(Map<String, dynamic> map, String id) {
    this._preco = map['preco'] ?? '';
    this._imagem = map['imagem'] ?? '';
    this._uidLoja = map['uidLoja'] ?? '';
    this._nome = map['nome'] ?? '';
    this._descricao = map['descricao'] ?? '';
    this._ingredientes = map['ingredientes'] ?? '';
    this._uidCategoria = map['uidCategoria'] ?? '';
  }
}