import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../services/api_service.dart';

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto;

  const ProdutoFormScreen({super.key, this.produto});

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    _nomeController = TextEditingController(text: produto?.nome ?? '');
    _descricaoController =
        TextEditingController(text: produto?.descricao ?? '');
    _precoController = TextEditingController(
      text: produto != null ? produto.preco.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final preco = double.parse(_precoController.text.replaceAll(',', '.'));

      final novoProduto = Produto(
        id: widget.produto?.id,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: preco,
      );

      if (widget.produto == null) {
        await ApiService.instance.createProduto(novoProduto);
      } else {
        await ApiService.instance.updateProduto(novoProduto);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto salvo com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar produto: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o preço';
                  }
                  final parsed =
                      double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return 'Preço inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(editando ? 'Atualizar' : 'Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
