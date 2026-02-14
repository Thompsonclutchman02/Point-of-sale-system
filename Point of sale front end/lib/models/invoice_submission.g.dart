// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceSubmission _$InvoiceSubmissionFromJson(Map<String, dynamic> json) =>
    InvoiceSubmission(
      id: (json['id'] as num).toInt(),
      saleId: (json['saleId'] as num).toInt(),
      status: json['status'] as String,
      authorityRef: json['authorityRef'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$InvoiceSubmissionToJson(InvoiceSubmission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'status': instance.status,
      'authorityRef': instance.authorityRef,
      'createdAt': instance.createdAt.toIso8601String(),
    };
