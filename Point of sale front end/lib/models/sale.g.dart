// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
  id: json['id'] as int?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  totalBeforeTax: (json['total_before_tax'] as num?)?.toDouble(),
  taxAmount: (json['tax_amount'] as num?)?.toDouble(),
  totalAmount: (json['total_amount'] as num?)?.toDouble(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  employeeId: json['employee_id'] as String?,
  employeeName: json['employee_name'] as String?,
);

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt?.toIso8601String(),
  'total_before_tax': instance.totalBeforeTax,
  'tax_amount': instance.taxAmount,
  'total_amount': instance.totalAmount,
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'employee_id': instance.employeeId,
  'employee_name': instance.employeeName,
};

SaleCreate _$SaleCreateFromJson(Map<String, dynamic> json) => SaleCreate(
  items: (json['items'] as List<dynamic>)
      .map((e) => SaleItemCreate.fromJson(e as Map<String, dynamic>))
      .toList(),
  paymentMethod: json['payment_method'] as String? ?? 'cash',
  customerId: json['customer_id'] as int?,
  taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.16,
  employeeId: json['employee_id'] as String,
  employeeName: json['employee_name'] as String,
);

Map<String, dynamic> _$SaleCreateToJson(SaleCreate instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'payment_method': instance.paymentMethod,
      'customer_id': instance.customerId,
      'tax_rate': instance.taxRate,
      'employee_id': instance.employeeId,
      'employee_name': instance.employeeName,
    };