// lib/models/sale.dart
import 'package:json_annotation/json_annotation.dart';
import 'sale_item.dart';

part 'sale.g.dart';

@JsonSerializable()
class Sale {
  int? id;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'total_before_tax')
  double? totalBeforeTax;
  @JsonKey(name: 'tax_amount')
  double? taxAmount;
  @JsonKey(name: 'total_amount')
  double? totalAmount;
  List<SaleItem>? items;
  @JsonKey(name: 'employee_id') // ADD THIS
  String? employeeId;
  @JsonKey(name: 'employee_name') // ADD THIS
  String? employeeName;

  Sale({
    this.id,
    this.createdAt,
    this.totalBeforeTax,
    this.taxAmount,
    this.totalAmount,
    this.items,
    this.employeeId, // ADD THIS
    this.employeeName, // ADD THIS
  });

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
  Map<String, dynamic> toJson() => _$SaleToJson(this);
}

@JsonSerializable()
class SaleCreate {
  List<SaleItemCreate> items;
  @JsonKey(name: 'payment_method')
  String paymentMethod;
  @JsonKey(name: 'customer_id')
  int? customerId;
  @JsonKey(name: 'tax_rate')
  double taxRate;
  @JsonKey(name: 'employee_id') // ADD THIS
  String employeeId;
  @JsonKey(name: 'employee_name') // ADD THIS
  String employeeName;

  SaleCreate({
    required this.items,
    this.paymentMethod = 'cash',
    this.customerId,
    this.taxRate = 0.16,
    required this.employeeId, // ADD THIS
    required this.employeeName, // ADD THIS
  });

  factory SaleCreate.fromJson(Map<String, dynamic> json) => _$SaleCreateFromJson(json);
  Map<String, dynamic> toJson() => _$SaleCreateToJson(this);
}