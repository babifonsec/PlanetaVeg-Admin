class Loja {
  late String _nome;
  late String _cnpj;
  late String _telefone;
  late String _imagem;
   late List<Map<String, dynamic>> _enderecos;

  Loja(this._nome, this._cnpj, this._telefone, this._imagem);

  Loja.map(dynamic obj) {
  
    this._nome = obj['nome'];
    this._cnpj = obj['cnpj'];
    this._telefone = obj['telefone'];
    this._imagem = obj['imagem'];
  }

  String get nome => _nome;
  String get cnpj => _cnpj;
  String get telefone => _telefone;
  String get iamgem => _imagem;
   List<Map <String, dynamic>> get enderecos => _enderecos;

  // Converte o objeto Loja em um mapa que pode ser armazenado no Firestore
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['nome'] = _nome;
    map['cnpj'] = _cnpj;
    map['telefone'] = _telefone;
    map['imagem'] = _imagem;
    return map;
  }

  Loja.fromMap(Map<String, dynamic> map, String id) {
    this._nome = map['nome'] ?? '';
    this._cnpj = map['cnpj'] ?? '';
    this._telefone = map['telefone'] ?? '';
    this._imagem = map['imagem'] ?? '';
  }
}
