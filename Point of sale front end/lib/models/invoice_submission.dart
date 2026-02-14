// lib/models/invoice_submission.dart
import 'package:json_annotation/json_annotation.dart';

part 'invoice_submission.g.dart';

@JsonSerializable()
class InvoiceSubmission {
  int id;
  int saleId;
  String status;
  String? authorityRef;
  DateTime createdAt;

  InvoiceSubmission({
    required this.id,
    required this.saleId,
    required this.status,
    this.authorityRef,
    required this.createdAt,
  });

  factory InvoiceSubmission.fromJson(Map<String, dynamic> json) => _$InvoiceSubmissionFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceSubmissionToJson(this);
}