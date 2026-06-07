import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../expenses/add_expense_screen.dart';
// import '../expenses/models/expense_model.dart';
import '../expenses/providers/expense_provider.dart';
import '../profile/profile_screen.dart';
import '../expenses/widgets/expense_tile.dart';
import '../expenses/screens/expense_list_screen.dart';
import '../reports/screens/reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  bool isSidebarExpanded = true;

  static const double desktopBreakpoint = 700;

  final List<Widget> pages = const [
    HomePage(),
    ExpenseListScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  final List<_NavigationItem> navItems = const [
    _NavigationItem(
      label: "Dashboard",
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _NavigationItem(
      label: "Expenses",
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    _NavigationItem(
      label: "Reports",
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
    ),
    _NavigationItem(
      label: "Profile",
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  bool get showFab => currentIndex == 0 || currentIndex == 1;

  void openAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= desktopBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
      ),

      floatingActionButton: showFab
          ? FloatingActionButton.large(
        onPressed: openAddExpense,
        child: const Icon(Icons.add, size: 34),
      )
          : null,

      body: isDesktop
          ? Row(
        children: [
          AppSidebar(
            items: navItems,
            selectedIndex: currentIndex,
            isExpanded: isSidebarExpanded,
            onToggle: () {
              setState(() {
                isSidebarExpanded = !isSidebarExpanded;
              });
            },
            onSelected: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          Expanded(
            child: pages[currentIndex],
          ),
        ],
      )
          : pages[currentIndex],

      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  final List<_NavigationItem> items;
  final int selectedIndex;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;

  const AppSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.isExpanded,
    required this.onToggle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = isExpanded ? 240.0 : 84.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  if (isExpanded)
                    Expanded(
                      child: Text(
                        "Expense\nTracker",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),

                  IconButton(
                    onPressed: onToggle,
                    tooltip: "Menu",
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = selectedIndex == index;

                  return _SidebarTile(
                    item: item,
                    isSelected: isSelected,
                    isExpanded: isExpanded,
                    onTap: () => onSelected(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final _NavigationItem item;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 0,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment:
          isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected
                  ? selectedColor
                  : Theme.of(context).iconTheme.color,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 14),
              Text(
                item.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? selectedColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SummaryGrid(expenseProvider: expenseProvider),
        const SizedBox(height: 24),

        if (expenses.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                "No expenses yet.\nTap + to add your first expense.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
        else ...[
          const Text(
            "Recent Transactions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...expenses.map(
                (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExpenseTile(expense: expense),
            ),
          ),
        ],
      ],
    );
  }
}

class SummaryGrid extends StatelessWidget {
  final ExpenseProvider expenseProvider;

  const SummaryGrid({
    super.key,
    required this.expenseProvider,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width >= 900 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        SummaryCard(
          title: "Today",
          value: "₹${expenseProvider.todayTotal.toStringAsFixed(0)}",
          icon: Icons.today,
          color: Colors.green,
        ),
        SummaryCard(
          title: "This Week",
          value: "₹${expenseProvider.weekTotal.toStringAsFixed(0)}",
          icon: Icons.calendar_view_week,
          color: Colors.blue,
        ),
        SummaryCard(
          title: "This Month",
          value: "₹${expenseProvider.monthTotal.toStringAsFixed(0)}",
          icon: Icons.calendar_month,
          color: Colors.purple,
        ),
        SummaryCard(
          title: "Transactions",
          value: expenseProvider.transactionCount.toString(),
          icon: Icons.receipt_long,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.18),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}