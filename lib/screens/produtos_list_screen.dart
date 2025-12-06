import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'produto_form_screen.dart';

class ProdutosListScreen extends StatefulWidget {
  const ProdutosListScreen({super.key});

  @override
  State<ProdutosListScreen> createState() => _ProdutosListScreenState();
}

class _ProdutosListScreenState extends State<ProdutosListScreen> {
  late Future<List<Produto>> _futureProdutos;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  void _carregarProdutos() {
    setState(() {
      _futureProdutos = ApiService.instance.getProdutos();
    });
  }

  Future<void> _abrirFormulario({Produto? produto}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProdutoFormScreen(produto: produto),
      ),
    );

    if (result == true) {
      _carregarProdutos();
    }
  }

  Future<void> _deletarProduto(int id) async {
    try {
      await ApiService.instance.deleteProduto(id);
      _carregarProdutos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto excluído com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir produto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Produto>>(
        future: _futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child:
                  Text('Erro ao carregar produtos: ${snapshot.error.toString()}'),
            );
          }

          final produtos = snapshot.data ?? [];

          if (produtos.isEmpty) {
            return const Center(
              child: Text('Nenhum produto cadastrado.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _carregarProdutos();
            },
            child: ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: Text(produto.nome),
                    subtitle: Text(
                      '${produto.descricao}\nR\$ ${produto.preco.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _abrirFormulario(produto: produto),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deletarProduto(produto.id!),
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
