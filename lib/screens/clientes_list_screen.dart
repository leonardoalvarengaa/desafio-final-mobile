import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'cliente_form_screen.dart';

// FutureBuilder responsável por carregar a lista de clientes
// e atualizar a tela conforme o estado da requisição.

class ClientesListScreen extends StatefulWidget {
  const ClientesListScreen({super.key});

  @override
  State<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  late Future<List<Cliente>> _futureClientes;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  void _carregarClientes() {
    setState(() {
      _futureClientes = ApiService.instance.getClientes();
    });
  }

  Future<void> _abrirFormulario({Cliente? cliente}) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ClienteFormScreen(cliente: cliente),
      ),
    );

    if (resultado == true) {
      _carregarClientes();
    }
  }

  Future<void> _deletarCliente(int id) async {
    try {
      await ApiService.instance.deleteCliente(id);
      _carregarClientes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente excluído com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir cliente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Cliente>>(
        future: _futureClientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child:
                  Text('Erro ao carregar clientes: ${snapshot.error.toString()}'),
            );
          }

          final clientes = snapshot.data ?? [];

          if (clientes.isEmpty) {
            return const Center(
              child: Text('Nenhum cliente cadastrado.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _carregarClientes();
            },
            child: ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        cliente.nome.isNotEmpty
                            ? cliente.nome[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text('${cliente.nome} ${cliente.sobrenome}'),
                    subtitle:
                        Text('${cliente.email} • ${cliente.idade} anos'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _abrirFormulario(cliente: cliente),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deletarCliente(cliente.id!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
