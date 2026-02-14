import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/sale.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  SaleListScreenState createState() => SaleListScreenState();
}

class SaleListScreenState extends State<SaleListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Sale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = _loadSales();
  }

  Future<List<Sale>> _loadSales() async {
    try {
      final sales = await _apiService.getSales();
      return sales ?? [];
    } catch (e) {
      print('Error loading sales: $e');
      return [];
    }
  }

  void _refreshSales() {
    setState(() {
      _salesFuture = _loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSales,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Sale>>(
        future: _salesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading sales: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshSales,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No sales found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sales will appear here once transactions are made',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to checkout or POS screen
                      Navigator.pushNamed(context, '/checkout');
                    },
                    child: const Text('Make First Sale'),
                  ),
                ],
              ),
            );
          } else {
            final sales = snapshot.data!;
            return ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return _buildSaleCard(sale);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/checkout');
        },
        child: const Icon(Icons.add_shopping_cart),
        tooltip: 'New Sale',
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    // Safe date formatting
    final dateString = sale.createdAt != null
        ? '${sale.createdAt!.toLocal()}'.split(' ')[0]
        : 'Unknown Date';

    // Safe total amount
    final totalAmount = sale.totalAmount ?? 0.0;
    final itemCount = sale.items?.length ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo[100],
          child: Text(
            '${sale.id ?? '?'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'Sale #${sale.id ?? 'N/A'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $dateString'),
            Text('Items: $itemCount • Total: ZK${totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Text(
          'ZK${totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
        ),
        children: [
          if (sale.items == null || sale.items!.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No items in this sale',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...sale.items!.map((item) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(
                  '${item.quantity ?? 0}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              title: Text(
                item.product?.name ?? 'Unknown Product',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'SKU: ${item.product?.sku ?? 'N/A'}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                'ZK${(item.subtotal ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )).toList(),

          // Sale summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal: ZK${(sale.totalBeforeTax ?? totalAmount).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tax: ZK${(sale.taxAmount ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: ZK${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}