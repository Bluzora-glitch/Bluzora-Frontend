import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 81, 115, 94),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          '© 2025 Bluzora. All rights reserved.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
