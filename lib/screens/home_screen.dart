import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../models/myorder.dart'; // Import Order model
import 'add_edit_product_screen.dart';
import 'scaffold_with_bottom_nav.dart';



// ... imports ...

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<OrderProvider>().fetchOrdersForCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final totalProducts = productProvider.products.length;
    final lowStock = productProvider.products.where((p) => p.stock <= 5).length;
    
    // Get recent orders (top 5)
    final recentOrders = orderProvider.orders.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.warmPaper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.charcoal.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pastel Beauty',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Status Cards
              if (productProvider.isLoading || orderProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Products',
                        value: totalProducts.toString(),
                        icon: Icons.inventory_2_outlined,
                        color: AppTheme.lightPink,
                        textColor: AppTheme.charcoal,
                        iconColor: AppTheme.pastelPink,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Low Stock',
                        value: lowStock.toString(),
                        icon: Icons.warning_amber_rounded,
                        color: AppTheme.softGray.withValues(alpha: 0.25),
                        textColor: AppTheme.charcoal,
                        iconColor: AppTheme.softGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Recent Orders Section
                if (recentOrders.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENT ORDERS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                           final scaffold = context.findAncestorStateOfType<ScaffoldWithBottomNavState>();
                           scaffold?.onItemTapped(2); // Go to Orders tab
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentOrders.length,
                    separatorBuilder: (ctx, index) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final order = recentOrders[index];
                      return _buildRecentOrderTile(order);
                    },
                  ),
                ],
              ],

              const SizedBox(height: 40),

              // Quick Actions
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.add,
                    label: 'Add New',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditProductScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickAction(
                    context,
                    icon: Icons.inventory_outlined,
                    label: 'Inventory',
                    onTap: () {
                      // Switch to Products tab (index 1)
                      final scaffold = context.findAncestorStateOfType<ScaffoldWithBottomNavState>();
                      scaffold?.onItemTapped(1);
                    },
                  ),
                  _buildQuickAction(
                    context,
                    icon: Icons.local_shipping_outlined,
                    label: 'Orders',
                    onTap: () {
                      // Switch to Orders tab (index 2)
                      final scaffold = context.findAncestorStateOfType<ScaffoldWithBottomNavState>();
                      scaffold?.onItemTapped(2);
                    },
                  ),
                  _buildQuickAction(
                    context,
                    icon: Icons.tune,
                    label: 'Settings',
                    onTap: () {
                      // Switch to Profile tab (index 3)
                      final scaffold = context.findAncestorStateOfType<ScaffoldWithBottomNavState>();
                      scaffold?.onItemTapped(3);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
    Widget _buildExternalApiCard(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_queue, color: AppTheme.pastelPink.withValues(alpha: 0.8)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              status,
              style: const TextStyle(
                color: AppTheme.charcoal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: AppTheme.charcoal),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRecentOrderTile(Order order) {
    final isCompleted = order.status == 'completed';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
          child: Icon(
            isCompleted ? Icons.check : Icons.access_time,
            color: isCompleted ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          'Order #${order.id.substring(0, 6).toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${order.items.length} items • \$${order.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        onTap: () {
             final scaffold = context.findAncestorStateOfType<ScaffoldWithBottomNavState>();
             scaffold?.onItemTapped(2); // Go to Orders tab
        },
      ),
    );
  }
}
