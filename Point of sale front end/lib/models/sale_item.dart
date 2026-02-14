// lib/models/sale_item.dart - UPDATED
import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'sale_item.g.dart';

@JsonSerializable()
class SaleItem {
  int? id;
  @JsonKey(name: 'product_id')
  int? productId;
  int? quantity;
  double? price;
  double? subtotal;
  Product? product;

  SaleItem({
    this.id,
    this.productId,
    this.quantity,
    this.price,
    this.subtotal,
    this.product,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) => _$SaleItemFromJson(json);
  Map<String, dynamic> toJson() => _$SaleItemToJson(this);
}

@JsonSerializable()
class SaleItemCreate {
  @JsonKey(name: 'product_id')
  int productId;
  int quantity;
  double price; // CHANGED: Made non-nullable since price is required
  @JsonKey(name: 'discount_rate')
  double discountRate;
  String? productName; // ADDED: For better debugging
  String? sku; // ADDED: For better debugging

  SaleItemCreate({
    required this.productId,
    required this.quantity,
    required this.price, // CHANGED: Now required
    this.discountRate = 0.0,
    this.productName,
    this.sku,
  });

  factory SaleItemCreate.fromJson(Map<String, dynamic> json) => _$SaleItemCreateFromJson(json);
  Map<String, dynamic> toJson() => _$SaleItemCreateToJson(this);

  // Helper method to create from Product
  factory SaleItemCreate.fromProduct(Product product, int quantity) {
    return SaleItemCreate(
      productId: product.id ?? 0,
      quantity: quantity,
      price: product.price ?? 0.0, // Ensure price is never null
      productName: product.name,
      sku: product.sku,
    );
  }
}