// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart'; // ADD THIS IMPORT
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService(); // ADD THIS
  final List<SaleItemCreate> _cart = [];
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.getProducts();
  }

  void _addToCart(Product product, int quantity) {
    setState(() {
      _cart.add(SaleItemCreate(
        productId: product.id ?? 0,
        quantity: quantity,
        price: product.price ?? 0.0,
        productName: product.name,
        sku: product.sku,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $quantity x ${product.name} to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    try {
      // GET CURRENT USER INFO FOR EMPLOYEE TRACKING
      final currentUser = _authService.currentUser;

      // UPDATED: Create sale with employee information
      final saleCreate = SaleCreate(
        items: _cart,
        paymentMethod: 'cash',
        taxRate: 0.16,
        employeeId: currentUser?.id ?? 'unknown', // ADD THIS
        employeeName: currentUser?.name ?? 'Unknown Employee', // ADD THIS
      );

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing sale...'),
            ],
          ),
        ),
      );

      // Process checkout
      final Sale? sale = await _apiService.checkout(saleCreate);

      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      if (sale != null) {
        // Success
        setState(() {
          _cart.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale #${sale.id} completed successfully! Total: ZK${sale.totalAmount?.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Optionally navigate back or show success screen
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context); // Go back to previous screen
          }
        });
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  double _calculateSubtotal() {
    return _cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double _calculateTax(double subtotal, double taxRate) {
    return subtotal * taxRate;
  }

  double _calculateTotal(double subtotal, double tax) {
    return subtotal + tax;
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = _calculateSubtotal();
    final double tax = _calculateTax(subtotal, 0.16);
    final double total = _calculateTotal(subtotal, tax);
    final currentUser = _authService.currentUser; // GET CURRENT USER

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        actions: [
          if (_cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearCart,
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: Column(
        children: [
          // Cart Summary
          if (_cart.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // ADDED: Employee info
                    if (currentUser != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Processing as:'),
                            Text(
                              currentUser.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _authService.isAdmin ? Colors.blue : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('ZK${subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax (16%):'),
                        Text('ZK${tax.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'ZK${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _cart.length,
                itemBuilder: (context, index) {
                  final item = _cart[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo[100],
                        child: Text('${item.quantity}'),
                      ),
                      title: Text(item.productName ?? 'Product ${item.productId}'),
                      subtitle: Text('ZK${item.price.toStringAsFixed(2)} each'),
                      trailing: Text(
                        'ZK${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _removeFromCart(index),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // Empty cart message
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add products from the list below',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const Divider(),

          // Products List
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(product.name ?? 'Unnamed Product'),
                          subtitle: Text(
                            'ZK${product.price?.toStringAsFixed(2) ?? '0.00'} - Stock: ${product.stockQuantity ?? 0}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Show stock status
                              if ((product.stockQuantity ?? 0) <= 0)
                                const Icon(Icons.error, color: Colors.red),
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                                onPressed: (product.stockQuantity ?? 0) > 0
                                    ? () => _showAddQuantityDialog(context, product)
                                    : null,
                                tooltip: (product.stockQuantity ?? 0) > 0
                                    ? 'Add to cart'
                                    : 'Out of stock',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),

          // Checkout Button
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'PROCEED TO CHECKOUT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddQuantityDialog(BuildContext context, Product product) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add ${product.name ?? 'Product'} to Cart'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Price: ZK${product.price?.toStringAsFixed(2) ?? '0.00'}'),
                  Text('Available: ${product.stockQuantity ?? 0}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: quantity < (product.stockQuantity ?? 0)
                            ? () => setState(() => quantity++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addToCart(product, quantity);
                    Navigator.pop(context);
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}