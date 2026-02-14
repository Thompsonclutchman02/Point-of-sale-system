// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/sale.dart';
import '../models/invoice_submission.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  //'http://127.0.0.1: CHROME EMULATOR
  //'http://192.168.1.83:8000' ANDROID EMULATOR
  // Helper method for safe JSON decoding
  dynamic _safeJsonDecode(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      print('JSON decode error: $e');
      return null;
    }
  }

  // Helper method for safe HTTP requests
  Future<http.Response> _safeHttpRequest(Future<http.Response> request) async {
    try {
      final response = await request;
      return response;
    } catch (e) {
      print('HTTP request error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Product Endpoints

  Future<List<Product>> getProducts() async {
    final response = await _safeHttpRequest(
      http.get(Uri.parse('$baseUrl/products/')),
    );

    if (response.statusCode == 200) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson is List) {
        // Safe mapping with null filtering
        final products = decodedJson.map((json) {
          try {
            return Product.fromJson(json);
          } catch (e) {
            print('Error parsing product: $e');
            return null;
          }
        }).whereType<Product>().toList();

        return products;
      } else {
        throw Exception('Invalid response format: Expected list');
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Product?> getProduct(int id) async {
    final response = await _safeHttpRequest(
      http.get(Uri.parse('$baseUrl/products/$id')),
    );

    if (response.statusCode == 200) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson != null) {
        try {
          return Product.fromJson(decodedJson);
        } catch (e) {
          print('Error parsing product: $e');
          return null;
        }
      }
      return null;
    } else if (response.statusCode == 404) {
      return null; // Product not found
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  Future<Product?> addProduct(Product product) async {
    final response = await _safeHttpRequest(
      http.post(
        Uri.parse('$baseUrl/products/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson != null) {
        try {
          return Product.fromJson(decodedJson);
        } catch (e) {
          print('Error parsing added product: $e');
          return null;
        }
      }
      return null;
    } else {
      throw Exception('Failed to add product: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Product?> updateProduct(int id, Product product) async {
    final response = await _safeHttpRequest(
      http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ),
    );

    if (response.statusCode == 200) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson != null) {
        try {
          return Product.fromJson(decodedJson);
        } catch (e) {
          print('Error parsing updated product: $e');
          return null;
        }
      }
      return null;
    } else {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  }

  Future<bool> deleteProduct(int id) async {
    final response = await _safeHttpRequest(
      http.delete(Uri.parse('$baseUrl/products/$id')),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 404) {
      return false; // Product not found
    } else {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }

  Future<Product?> searchProductBySku(String sku) async {
    final response = await _safeHttpRequest(
      http.get(Uri.parse('$baseUrl/products/search/$sku')),
    );

    if (response.statusCode == 200) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson != null) {
        try {
          return Product.fromJson(decodedJson);
        } catch (e) {
          print('Error parsing searched product: $e');
          return null;
        }
      }
      return null;
    } else if (response.statusCode == 404) {
      return null; // Product not found
    } else {
      throw Exception('Failed to search product: ${response.statusCode}');
    }
  }

  // Sales Endpoints - ENHANCED CHECKOUT METHOD WITH PRICE VALIDATION

  Future<Sale?> checkout(SaleCreate saleCreate) async {
    // Enhanced validation with price checks
    if (saleCreate.items.isEmpty) {
      throw Exception('Cannot checkout with empty cart');
    }

    // Validate each item has required fields and prices
    for (final item in saleCreate.items) {
      if (item.productId <= 0) {
        throw Exception('Invalid product ID in cart item');
      }
      if (item.quantity <= 0) {
        throw Exception('Invalid quantity in cart item');
      }
      if (item.price <= 0) {
        throw Exception('Invalid price (${item.price}) for product ${item.productName ?? item.productId}');
      }
    }

    // Calculate totals directly without relying on SaleCreate methods
    double calculatedSubtotal = 0.0;
    for (final item in saleCreate.items) {
      calculatedSubtotal += item.price * item.quantity;
    }

    final calculatedTax = calculatedSubtotal * saleCreate.taxRate;
    final calculatedTotal = calculatedSubtotal + calculatedTax;

    print('=== PRICE VALIDATION ===');
    print('Calculated Subtotal: $calculatedSubtotal');
    print('Calculated Tax: $calculatedTax');
    print('Calculated Total: $calculatedTotal');
    print('Tax Rate: ${saleCreate.taxRate}');

    // Debug: Print each item with details
    print('=== ITEM DETAILS ===');
    for (final item in saleCreate.items) {
      print('Product: ${item.productName} (ID: ${item.productId})');
      print('Quantity: ${item.quantity}');
      print('Price: ${item.price}');
      print('Subtotal: ${item.price * item.quantity}');
      print('---');
    }

    // Debug: Print the request body
    final requestBody = jsonEncode(saleCreate.toJson());
    print('=== CHECKOUT REQUEST ===');
    print('URL: $baseUrl/sales/checkout');
    print('Body: $requestBody');

    final response = await _safeHttpRequest(
      http.post(
        Uri.parse('$baseUrl/sales/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ),
    );

    // Debug: Print the response
    print('=== CHECKOUT RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson != null) {
        try {
          final sale = Sale.fromJson(decodedJson);

          // Validate server response matches our calculations
          if (sale.totalAmount != calculatedTotal) {
            print('WARNING: Server total (${sale.totalAmount}) differs from calculated total ($calculatedTotal)');
          }

          return sale;
        } catch (e) {
          print('Error parsing checkout sale: $e');
          throw Exception('Failed to parse sale response: $e');
        }
      }
      throw Exception('Empty response from server');
    } else if (response.statusCode == 422) {
      // Enhanced 422 error parsing
      final errorBody = _safeJsonDecode(response.body);
      String errorMessage = 'Validation error: ';

      if (errorBody is Map) {
        if (errorBody.containsKey('errors')) {
          errorMessage += '${errorBody['errors']}';
        } else if (errorBody.containsKey('detail')) {
          errorMessage += '${errorBody['detail']}';
        } else {
          // Try to extract field-specific errors
          final fieldErrors = errorBody.entries
              .where((entry) => entry.value is List)
              .map((entry) => '${entry.key}: ${entry.value}')
              .join(', ');
          errorMessage += fieldErrors.isNotEmpty ? fieldErrors : errorBody.toString();
        }
      } else {
        errorMessage += response.body;
      }

      throw Exception(errorMessage);
    } else if (response.statusCode == 400) {
      throw Exception('Bad request: ${response.body}');
    } else if (response.statusCode == 404) {
      throw Exception('Checkout endpoint not found');
    } else if (response.statusCode == 500) {
      throw Exception('Server error: ${response.body}');
    } else {
      throw Exception('Failed to checkout: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Sale>> getSales() async {
    final response = await _safeHttpRequest(
      http.get(Uri.parse('$baseUrl/sales/')),
    );

    if (response.statusCode == 200) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson is List) {
        // Safe mapping with null filtering
        final sales = decodedJson.map((json) {
          try {
            return Sale.fromJson(json);
          } catch (e) {
            print('Error parsing sale: $e');
            return null;
          }
        }).whereType<Sale>().toList();

        return sales;
      } else {
        // Return empty list instead of throwing for empty response
        return [];
      }
    } else if (response.statusCode == 404) {
      return []; // No sales found
    } else {
      throw Exception('Failed to load sales: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Sale?> getSale(int id) async {
    final response = await _safeHttpRequest(
      http.get(Uri.parse('$baseUrl/sales/$id')),
    );

    if (response.statusCode == 200) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson != null) {
        try {
          return Sale.fromJson(decodedJson);
        } catch (e) {
          print('Error parsing sale: $e');
          return null;
        }
      }
      return null;
    } else if (response.statusCode == 404) {
      return null; // Sale not found
    } else {
      throw Exception('Failed to load sale: ${response.statusCode}');
    }
  }

  Future<InvoiceSubmission?> submitInvoice(int saleId) async {
    final response = await _safeHttpRequest(
      http.post(Uri.parse('$baseUrl/sales/$saleId/submit_invoice')),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson != null) {
        try {
          return InvoiceSubmission.fromJson(decodedJson);
        } catch (e) {
          print('Error parsing invoice submission: $e');
          return null;
        }
      }
      return null;
    } else {
      throw Exception('Failed to submit invoice: ${response.statusCode}');
    }
  }

  Future<InvoiceSubmission?> getInvoiceStatus(int saleId) async {
    final response = await _safeHttpRequest(
      http.get(Uri.parse('$baseUrl/sales/$saleId/invoice_status')),
    );

    if (response.statusCode == 200) {
      final decodedJson = _safeJsonDecode(response.body);
      if (decodedJson != null) {
        try {
          return InvoiceSubmission.fromJson(decodedJson);
        } catch (e) {
          print('Error parsing invoice status: $e');
          return null;
        }
      }
      return null;
    } else if (response.statusCode == 404) {
      return null; // Invoice status not found
    } else {
      throw Exception('Failed to get invoice status: ${response.statusCode}');
    }
  }

  // Helper method to test connection
  Future<bool> testConnection() async {
    try {
      final response = await _safeHttpRequest(
        http.get(Uri.parse('$baseUrl/products/')),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}