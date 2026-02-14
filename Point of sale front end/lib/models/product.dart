// lib/models/product.dart
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  int? id;
  String? name;
  String? sku;
  double? price;
  @JsonKey(name: 'stock_quantity')
  int? stockQuantity;
  @JsonKey(name: 'discount_allowed')
  int? discountAllowed;
  @JsonKey(name: 'expiry_date')
  DateTime? expiryDate;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  Product({
    this.id,
    this.name,
    this.sku,
    this.price,
    this.stockQuantity,
    this.discountAllowed,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Helper method to check if product has low stock
  bool get isLowStock => (stockQuantity ?? 0) < 10;

  // Helper method to check if product is expiring soon
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final difference = expiryDate!.difference(DateTime.now());
    return difference.inDays < 30 && difference.inDays >= 0;
  }
}