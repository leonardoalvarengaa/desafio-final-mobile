import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../services/api_service.dart';

// Valida e envia os dados do formulário para o backend.
// Decide entre criar um novo cliente ou atualizar um existente.

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormScreen({super.key, this.cliente});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _emailController;
  late TextEditingController _idadeController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    _nomeController = TextEditingController(text: cliente?.nome ?? '');
    _sobrenomeController =
        TextEditingController(text: cliente?.sobrenome ?? '');
    _emailController = TextEditingController(text: cliente?.email ?? '');
    _idadeController = TextEditingController(
        text: cliente != null ? cliente.idade.toString() : '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final idade = int.parse(_idadeController.text);
      final novoCliente = Cliente(
        id: widget.cliente?.id,
        nome: _nomeController.text.trim(),
        sobrenome: _sobrenomeController.text.trim(),
        email: _emailController.text.trim(),
        idade: idade,
      );

      if (widget.cliente == null) {
        await ApiService.instance.createCliente(novoCliente);
      } else {
        await ApiService.instance.updateCliente(novoCliente);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente salvo com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar cliente: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.cliente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Cliente' : 'Novo Cliente'),
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
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sobrenomeController,
                decoration: const InputDecoration(
                  labelText: 'Sobrenome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a idade';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Idade inválida';
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
