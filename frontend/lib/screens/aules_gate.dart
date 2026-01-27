import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/aules_service.dart';
import 'aules_info_screen.dart';
import 'aules_register_screen.dart';

class AulesGate extends StatefulWidget {
  const AulesGate({super.key});

  @override
  State<AulesGate> createState() => _AulesGateState();
}

class _AulesGateState extends State<AulesGate> {
  final _auth = FirebaseAuth.instance;

  bool _loading = true;
  bool _hasAulesAccount = false;

  @override
  void initState() {
    super.initState();
    _checkAulesAccount();
  }

  Future<void> _checkAulesAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final aulesService = AulesService();
      final aulesData = await aulesService.getAulesData();

      setState(() {
        _hasAulesAccount = aulesData != null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _hasAulesAccount = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasAulesAccount) {
      return const AulesInfoScreen();
    } else {
      return const AulesRegisterScreen();
    }
  }
}