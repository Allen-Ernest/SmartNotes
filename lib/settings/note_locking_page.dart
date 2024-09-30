import 'package:flutter/material.dart';

class NoteLockingPage extends StatefulWidget {
  const NoteLockingPage({super.key});

  @override
  State<NoteLockingPage> createState() => _NoteLockingPageState();
}

class _NoteLockingPageState extends State<NoteLockingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure note locking')),
    );
  }
}
