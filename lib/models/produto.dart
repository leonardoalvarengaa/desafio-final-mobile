class Produto {
  final int? id;
  final String nome;
  final String descricao;
  final double preco;

  Produto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      preco: json['preco'] is num
          ? (json['preco'] as num).toDouble()
          : double.tryParse(json['preco'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
    };
  }

  Produto copyWith({
    int? id,
    String? nome,
    String? descricao,
    double? preco,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
    );
  }
}
