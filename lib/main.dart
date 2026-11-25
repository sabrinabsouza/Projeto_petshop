import 'package:flutter/material.dart';

void main() {
  runApp(const PetShopApp());
}

// ---------------------------------------------------------------------------
// App: configura tema e define a tela inicial (a lista)
// ---------------------------------------------------------------------------
class PetShopApp extends StatelessWidget {
  const PetShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const ListaPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Modelo: um registro do pet shop com os 3 campos obrigatórios
// ---------------------------------------------------------------------------
class Registro {
  final String nome;
  final String especie;
  final String tutor;

  Registro({
    required this.nome,
    required this.especie,
    required this.tutor,
  });
}

// ---------------------------------------------------------------------------
// Tela 1: LISTAGEM (+ botão de cadastro, edição ao tocar, exclusão)
// ---------------------------------------------------------------------------
class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  // Lista em memória (some ao fechar o app, como o enunciado permite)
  final List<Registro> _registros = [];

  // CADASTRO: abre o formulário vazio e, se voltar um registro, adiciona
  Future<void> _abrirCadastro() async {
    final novo = await Navigator.push<Registro>(
      context,
      MaterialPageRoute(builder: (_) => const FormularioPage()),
    );
    if (novo != null) {
      setState(() => _registros.add(novo));
    }
  }

  // EDIÇÃO: abre o formulário preenchido e SUBSTITUI na mesma posição
  // (por isso não cria duplicata)
  Future<void> _abrirEdicao(int index) async {
    final editado = await Navigator.push<Registro>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioPage(registro: _registros[index]),
      ),
    );
    if (editado != null) {
      setState(() => _registros[index] = editado);
    }
  }

  // EXCLUSÃO: pede confirmação e remove da lista
  Future<void> _excluir(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Remover "${_registros[index].nome}" da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      setState(() => _registros.removeAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Shop')),
      body: _registros.isEmpty
          ? const Center(
              child: Text('Nenhum registro. Toque em + para cadastrar.'),
            )
          : ListView.builder(
              itemCount: _registros.length,
              itemBuilder: (context, index) {
                final r = _registros[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.pets),
                    title: Text(r.nome),
                    subtitle: Text('Espécie: ${r.especie}\nTutor: ${r.tutor}'),
                    isThreeLine: true,
                    onTap: () => _abrirEdicao(index),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Excluir',
                      onPressed: () => _excluir(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        tooltip: 'Novo registro',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tela 2: FORMULÁRIO (serve para cadastro e para edição)
// ---------------------------------------------------------------------------
class FormularioPage extends StatefulWidget {
  final Registro? registro; // null = cadastro; preenchido = edição

  const FormularioPage({super.key, this.registro});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _especieCtrl;
  late final TextEditingController _tutorCtrl;

  @override
  void initState() {
    super.initState();
    // Se for edição, já começa com os dados do registro
    _nomeCtrl = TextEditingController(text: widget.registro?.nome ?? '');
    _especieCtrl = TextEditingController(text: widget.registro?.especie ?? '');
    _tutorCtrl = TextEditingController(text: widget.registro?.tutor ?? '');
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _especieCtrl.dispose();
    _tutorCtrl.dispose();
    super.dispose();
  }

  // VALIDAÇÃO: trim() remove espaços, então "   " conta como vazio
  String? _validar(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        Registro(
          nome: _nomeCtrl.text.trim(),
          especie: _especieCtrl.text.trim(),
          tutor: _tutorCtrl.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.registro != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar registro' : 'Novo registro'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome do animal',
                border: OutlineInputBorder(),
              ),
              validator: _validar,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _especieCtrl,
              decoration: const InputDecoration(
                labelText: 'Espécie',
                border: OutlineInputBorder(),
              ),
              validator: _validar,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tutorCtrl,
              decoration: const InputDecoration(
                labelText: 'Tutor',
                border: OutlineInputBorder(),
              ),
              validator: _validar,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label: Text(editando ? 'Salvar alterações' : 'Salvar registro'),
            ),
          ],
        ),
      ),
    );
  }
}