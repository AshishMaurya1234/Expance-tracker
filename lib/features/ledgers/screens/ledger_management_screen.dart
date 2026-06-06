import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ledger_model.dart';
import '../providers/ledger_provider.dart';

class LedgerManagementScreen extends StatelessWidget {
  const LedgerManagementScreen({super.key});

  static const List<String> ledgerTypes = [
    "Cash",
    "Bank Account",
    "Wallet",
    "Credit Card",
    "Debit Card",
    "Investment",
  ];

  @override
  Widget build(BuildContext context) {
    final ledgers = context.watch<LedgerProvider>().ledgers;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Ledgers"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showLedgerDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ledgers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ledger = ledgers[index];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                _ledgerColor(ledger.type).withValues(alpha: 0.15),
                child: Icon(
                  _ledgerIcon(ledger.type),
                  color: _ledgerColor(ledger.type),
                ),
              ),
              title: Text(ledger.name),
              subtitle: Text(
                ledger.isDefault
                    ? "${ledger.type} • Default ledger"
                    : "${ledger.type} • Custom ledger",
              ),
              trailing: ledger.isDefault
                  ? const Icon(Icons.lock_outline)
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _showLedgerDialog(
                        context,
                        ledger: ledger,
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      _confirmDelete(context, ledger);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static void _showLedgerDialog(
      BuildContext context, {
        LedgerModel? ledger,
      }) {
    final nameController = TextEditingController(
      text: ledger?.name ?? "",
    );

    String selectedType = ledger?.type ?? "Cash";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                ledger == null ? "Add Ledger" : "Edit Ledger",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Ledger Name",
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: "Ledger Type",
                    ),
                    items: ledgerTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_ledgerIcon(type)),
                            const SizedBox(width: 10),
                            Text(type),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ledger name is required"),
                        ),
                      );
                      return;
                    }

                    final provider = context.read<LedgerProvider>();

                    if (ledger == null) {
                      provider.addLedger(
                        LedgerModel(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: name,
                          type: selectedType,
                          isDefault: false,
                          createdAt: DateTime.now(),
                        ),
                      );
                    } else {
                      provider.updateLedger(
                        ledger.copyWith(
                          name: name,
                          type: selectedType,
                        ),
                      );
                    }

                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    ledger == null ? "Save" : "Update",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _confirmDelete(
      BuildContext context,
      LedgerModel ledger,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Ledger?"),
          content: Text(
            "${ledger.name} will be permanently deleted.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                context.read<LedgerProvider>().deleteLedger(ledger.id);

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Ledger deleted"),
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  static IconData _ledgerIcon(String type) {
    switch (type) {
      case "Cash":
        return Icons.payments;
      case "Bank Account":
        return Icons.account_balance;
      case "Wallet":
        return Icons.account_balance_wallet;
      case "Credit Card":
        return Icons.credit_card;
      case "Debit Card":
        return Icons.credit_score;
      case "Investment":
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  static Color _ledgerColor(String type) {
    switch (type) {
      case "Cash":
        return Colors.green;
      case "Bank Account":
        return Colors.blue;
      case "Wallet":
        return Colors.orange;
      case "Credit Card":
        return Colors.purple;
      case "Debit Card":
        return Colors.teal;
      case "Investment":
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}