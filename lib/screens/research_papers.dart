import 'package:flutter/material.dart';

class ResearchPapersScreen extends StatelessWidget {
  const ResearchPapersScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('Research Papers')),
      body: Center(child: Text('List of papers goes here')),
    );
  }
}
