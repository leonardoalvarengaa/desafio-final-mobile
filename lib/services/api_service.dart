import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/cliente.dart';
import '../models/produto.dart';

// Serviço responsável pela comunicação com o backend.
// Aqui ficam todos os métodos de login, clientes e produtos,
// além do armazenamento do token JWT.

class ApiService {
  // Emulador Android conversando com backend na máquina
  static const String baseUrl = 'http://10.0.2.2:3000';

  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  final http.Client _client = http.Client();
  String? _token;

  String? get token => _token;

  Map<String, String> _headers({bool auth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ---------------- AUTH ----------------
  // Realiza o login e guarda o token JWT para acessar rotas protegidas.

  Future<bool> login(String usuario, String senha) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await _client.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'usuario': usuario,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Seu backend retorna { "token": "..." }
      final token = data['token'];
      if (token == null) {
        throw Exception('Token não encontrado na resposta de login');
      }

      _token = token;
      return true;
    } else if (response.statusCode == 401) {
      // Credenciais inválidas
      return false;
    } else {
      throw Exception(
          'Erro no login (${response.statusCode}): ${response.body}');
    }
  }

  void logout() {
    _token = null;
  }

  // ---------------- CLIENTES ----------------
  // Métodos para listar, criar, editar e deletar clientes no backend.

  Future<List<Cliente>> getClientes() async {
    final url = Uri.parse('$baseUrl/clientes');

    final response = await _client.get(
      url,
      headers: _headers(auth: true),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map<Cliente>(
              (e) => Cliente.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      } else if (decoded is Map) {
        return [
          Cliente.fromJson(Map<String, dynamic>.from(decoded)),
        ];
      } else {
        return [];
      }
    } else {
      throw Exception(
          'Erro ao buscar clientes (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> createCliente(Cliente cliente) async {
    final url = Uri.parse('$baseUrl/clientes');

    // Não enviar "id" no body (backend não permite)
    final response = await _client.post(
      url,
      headers: _headers(auth: true),
      body: jsonEncode({
        'nome': cliente.nome,
        'sobrenome': cliente.sobrenome,
        'email': cliente.email,
        'idade': cliente.idade,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Erro ao criar cliente (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateCliente(Cliente cliente) async {
    if (cliente.id == null) {
      throw Exception('Cliente sem ID para atualizar');
    }

    final url = Uri.parse('$baseUrl/clientes/${cliente.id}');

    // Também não enviar "id" no body no PUT
    final response = await _client.put(
      url,
      headers: _headers(auth: true),
      body: jsonEncode({
        'nome': cliente.nome,
        'sobrenome': cliente.sobrenome,
        'email': cliente.email,
        'idade': cliente.idade,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao atualizar cliente (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteCliente(int id) async {
    final url = Uri.parse('$baseUrl/clientes/$id');

    final response = await _client.delete(
      url,
      headers: _headers(auth: true),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Erro ao excluir cliente (${response.statusCode}): ${response.body}');
    }
  }

  // ---------------- PRODUTOS ----------------
  // Métodos para listar, criar, editar e deletar produtos no backend.

  Future<List<Produto>> getProdutos() async {
    final url = Uri.parse('$baseUrl/produtos');

    final response = await _client.get(
      url,
      headers: _headers(), // se depois proteger produtos, troca para auth: true
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map<Produto>(
              (e) => Produto.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      } else if (decoded is Map) {
        return [
          Produto.fromJson(Map<String, dynamic>.from(decoded)),
        ];
      } else {
        return [];
      }
    } else {
      throw Exception(
          'Erro ao buscar produtos (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> createProduto(Produto produto) async {
    final url = Uri.parse('$baseUrl/produtos');

    // Não enviar "id" no body
    final response = await _client.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'nome': produto.nome,
        'descricao': produto.descricao,
        'preco': produto.preco,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Erro ao criar produto (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateProduto(Produto produto) async {
    if (produto.id == null) {
      throw Exception('Produto sem ID para atualizar');
    }

    final url = Uri.parse('$baseUrl/produtos/${produto.id}');

    // Também não enviar "id" no body no PUT
    final response = await _client.put(
      url,
      headers: _headers(),
      body: jsonEncode({
        'nome': produto.nome,
        'descricao': produto.descricao,
        'preco': produto.preco,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao atualizar produto (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteProduto(int id) async {
    final url = Uri.parse('$baseUrl/produtos/$id');

    final response = await _client.delete(
      url,
      headers: _headers(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Erro ao excluir produto (${response.statusCode}): ${response.body}');
    }
  }
}
