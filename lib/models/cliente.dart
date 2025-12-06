class Cliente {
  final int? id;
  final String nome;
  final String sobrenome;
  final String email;
  final int idade;

  Cliente({
    this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.idade,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'] ?? '',
      sobrenome: json['sobrenome'] ?? '',
      email: json['email'] ?? '',
      idade: json['idade'] is int
          ? json['idade']
          : int.tryParse(json['idade'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
      'idade': idade,
    };
  }

  Cliente copyWith({
    int? id,
    String? nome,
    String? sobrenome,
    String? email,
    int? idade,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sobrenome: sobrenome ?? this.sobrenome,
      email: email ?? this.email,
      idade: idade ?? this.idade,
    );
  }
}
