import 'package:flutter/material.dart';

import '../models/ledger_model.dart';

class LedgerProvider extends ChangeNotifier {
  final List<LedgerModel> _ledgers = [
    LedgerModel(
      id: "cash",
      name: "Cash",
      type: "Cash",
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    LedgerModel(
      id: "bank_account",
      name: "Bank Account",
      type: "Bank Account",
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    LedgerModel(
      id: "upi_wallet",
      name: "UPI Wallet",
      type: "Wallet",
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    LedgerModel(
      id: "credit_card",
      name: "Credit Card",
      type: "Credit Card",
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    LedgerModel(
      id: "debit_card",
      name: "Debit Card",
      type: "Debit Card",
      isDefault: true,
      createdAt: DateTime.now(),
    ),
  ];

  List<LedgerModel> get ledgers => List.unmodifiable(_ledgers);

  void addLedger(LedgerModel ledger) {
    _ledgers.add(ledger);
    notifyListeners();
  }

  void updateLedger(LedgerModel ledger) {
    final index = _ledgers.indexWhere((item) => item.id == ledger.id);

    if (index == -1) return;

    _ledgers[index] = ledger;
    notifyListeners();
  }

  void deleteLedger(String id) {
    final ledger = _ledgers.firstWhere((item) => item.id == id);

    if (ledger.isDefault) return;

    _ledgers.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}