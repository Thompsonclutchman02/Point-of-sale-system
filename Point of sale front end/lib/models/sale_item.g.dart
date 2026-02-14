// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleItem _$SaleItemFromJson(Map<String, dynamic> json) => SaleItem(
  id: json['id'] as int?,
  productId: json['product_id'] as int?,
  quantity: json['quantity'] as int?,
  price: (json['price'] as num?)?.toDouble(),
  subtotal: (json['subtotal'] as num?)?.toDouble(),
  product: json['product'] == null
      ? null
      : Product.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SaleItemToJson(SaleItem instance) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'quantity': instance.quantity,
  'price': instance.price,
  'subtotal': instance.subtotal,
  'product': instance.product?.toJson(),
};

SaleItemCreate _$SaleItemCreateFromJson(Map<String, dynamic> json) =>
    SaleItemCreate(
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountRate: (json['discount_rate'] as num?)?.toDouble() ?? 0.0,
      productName: json['product_name'] as String?,
      sku: json['sku'] as String?,
    );

Map<String, dynamic> _$SaleItemCreateToJson(SaleItemCreate instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'price': instance.price,
      'discount_rate': instance.discountRate,
      'product_name': instance.productName,
      'sku': instance.sku,
    };