// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ListTile(
                  title: Text(product.name ?? ''),
                  subtitle: Text(
                    'SKU: ${product.sku ?? ''} - Price: \$${product.price ?? 0} - Stock: ${product.stockQuantity ?? 0}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditProductDialog(context, product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product.id ?? 0),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: ProductForm(
            onSubmit: (product) async {
              await _apiService.addProduct(product);
              if (!mounted) return;
              setState(() {
                _productsFuture = _apiService.getProducts();
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: ProductForm(
            product: product,
            onSubmit: (updatedProduct) async {
              await _apiService.updateProduct(product.id ?? 0, updatedProduct);
              if (!mounted) return;
              setState(() {
                _productsFuture = _apiService.getProducts();
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteProduct(int id) async {
    await _apiService.deleteProduct(id);
    if (!mounted) return;
    setState(() {
      _productsFuture = _apiService.getProducts();
    });
  }
}

class ProductForm extends StatefulWidget {
  final Product? product;
  final Function(Product) onSubmit;

  const ProductForm({Key? key, this.product, required this.onSubmit})
      : super(key: key);

  @override
  State<ProductForm> createState() => ProductFormState();
}

class ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _priceController = TextEditingController(
        text: widget.product?.price?.toString() ?? '');
    _stockController = TextEditingController(
        text: widget.product?.stockQuantity?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _skuController,
            decoration: const InputDecoration(labelText: 'SKU'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _stockController,
            decoration: const InputDecoration(labelText: 'Stock Quantity'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final product = Product(
                  id: widget.product?.id ?? 0,
                  name: _nameController.text,
                  sku: _skuController.text,
                  price: double.tryParse(_priceController.text) ?? 0,
                  stockQuantity: int.tryParse(_stockController.text) ?? 0,
                  discountAllowed: widget.product?.discountAllowed ?? 1,
                  createdAt: widget.product?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                widget.onSubmit(product);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

}
