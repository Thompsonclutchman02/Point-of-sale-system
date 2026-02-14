// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/product.dart';
import '../models/sale.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  late List<Product> _products = [];
  late List<Sale> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _apiService.getProducts();
      final sales = await _apiService.getSales();

      setState(() {
        _products = products;
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _authService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  List<Product> get _lowStockProducts {
    return _products.where((product) => (product.stockQuantity ?? 0) < 10).toList();
  }

  int get _totalProducts => _products.length;
  int get _lowStockCount => _lowStockProducts.length;

  double get _totalSalesAmount => _sales.fold(0.0, (sum, sale) {
    final amount = sale.totalAmount ?? 0.0;
    return sum + amount;
  });

  double get _todaySalesAmount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _sales.fold(0.0, (sum, sale) {
      if (sale.createdAt == null) return sum;

      final saleDate = DateTime(
          sale.createdAt!.year,
          sale.createdAt!.month,
          sale.createdAt!.day
      );

      if (saleDate == today) {
        return sum + (sale.totalAmount ?? 0.0);
      }
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isWideScreen
          ? null
          : AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/products');
            },
            tooltip: 'Add Product',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: isWideScreen
          ? null
          : Drawer(
        child: _buildSidebarContent(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return Row(
              children: [
                Container(
                  width: 250,
                  color: Colors.grey[100],
                  child: _buildSidebarContent(),
                ),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            );
          } else {
            return _buildMainContent();
          }
        },
      ),
    );
  }

  Widget _buildSidebarContent() {
    final currentUser = _authService.currentUser;
    final isAdmin = _authService.isAdmin;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'CARTGO',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Inventory'),
                onTap: () {
                  Navigator.pushNamed(context, '/products');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Sales'),
                onTap: () {
                  Navigator.pushNamed(context, '/sales');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Checkout'),
                onTap: () {
                  Navigator.pushNamed(context, '/checkout');
                },
              ),
              if (isAdmin) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.green),
                  title: const Text('Employee Management'),
                  onTap: () {
                    Navigator.pushNamed(context, '/employees');
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings screen coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: _authService.isAdmin ? Colors.blue : Colors.green,
            child: Text(
              _authService.currentUser?.name[0] ?? 'U',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          title: Text(_authService.currentUser?.name ?? 'User'),
          subtitle: Text(
            _authService.isAdmin ? 'Administrator' : 'Employee',
            style: TextStyle(
              color: _authService.isAdmin ? Colors.blue : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.of(context).size.width >= 800)
            Row(
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_authService.isAdmin) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/employees');
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('Manage Employees'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/products');
                  },
                  icon: const Icon(Icons.inventory_2),
                  label: const Text('Inventory'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loadDashboardData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          const SizedBox(height: 4),
          Text(
            "Welcome back, ${_authService.currentUser?.name ?? 'User'}! Here's your store overview.",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // RESPONSIVE STAT CARDS - 2x2 grid on mobile, horizontal on desktop
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Mobile: 2x2 grid
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    _buildStatCard(
                      Icons.inventory_2,
                      _totalProducts.toString(),
                      'Total Products',
                      Colors.blue,
                    ),
                    _buildStatCard(
                      Icons.warning_amber,
                      _lowStockCount.toString(),
                      'Low Stock',
                      Colors.orange,
                    ),
                    _buildStatCard(
                      Icons.today,
                      'ZK${_todaySalesAmount.toStringAsFixed(2)}',
                      "Today's Sales",
                      Colors.green,
                    ),
                    _buildStatCard(
                      Icons.trending_up,
                      'ZK${_totalSalesAmount.toStringAsFixed(2)}',
                      'Total Sales',
                      Colors.purple,
                    ),
                  ],
                );
              } else {
                // Desktop: Horizontal layout
                return Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    _buildStatCard(
                      Icons.inventory_2,
                      _totalProducts.toString(),
                      'Total Products',
                      Colors.blue,
                    ),
                    _buildStatCard(
                      Icons.warning_amber,
                      _lowStockCount.toString(),
                      'Low Stock',
                      Colors.orange,
                    ),
                    _buildStatCard(
                      Icons.today,
                      'ZK${_todaySalesAmount.toStringAsFixed(2)}',
                      "Today's Sales",
                      Colors.green,
                    ),
                    _buildStatCard(
                      Icons.trending_up,
                      'ZK${_totalSalesAmount.toStringAsFixed(2)}',
                      'Total Sales',
                      Colors.purple,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),

          // Low Stock Items Table - RESPONSIVE
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Low Stock Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Products that need to be reordered soon',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  if (_lowStockProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No low stock items',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    _buildLowStockTable(),

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/products');
                      },
                      child: const Text('View All'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Point of Sale Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Point of Sale',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            // Mobile: Icon only button
                            return IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/sales');
                              },
                              icon: const Icon(Icons.shopping_cart),
                              tooltip: 'Sales History',
                            );
                          } else {
                            // Desktop: Full button with text
                            return ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/sales');
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('History'),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Process transactions and manage sales',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/checkout');
                        },
                        child: const Text('Process Transactions'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Print Receipts'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 600;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isSmallScreen ? 500 : constraints.maxWidth,
            ),
            child: DataTable(
              columnSpacing: 16,
              horizontalMargin: 16,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 60,
              columns: [
                DataColumn(
                  label: Text(
                      'Product Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      )
                  ),
                ),
                DataColumn(
                  label: Text(
                      'Current Stock',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      )
                  ),
                ),
                DataColumn(
                  label: Text(
                      'Min. Required',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      )
                  ),
                ),
                DataColumn(
                  label: Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      )
                  ),
                ),
              ],
              rows: _lowStockProducts.map((product) {
                final stock = product.stockQuantity ?? 0;
                String status = 'Normal';
                Color statusColor = Colors.green;

                if (stock < 5) {
                  status = 'Critical';
                  statusColor = Colors.red;
                } else if (stock < 10) {
                  status = 'Low';
                  statusColor = Colors.orange;
                }

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        product.name ?? 'Unknown Product',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        '$stock',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ),
                    DataCell(Text(
                      '10',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    )),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: isMobile
                ? const EdgeInsets.all(12.0)
                : const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: isMobile
                      ? const EdgeInsets.all(8)
                      : const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      icon,
                      size: isMobile ? 20 : 28,
                      color: color
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 11 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}