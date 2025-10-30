import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Expensemodel {
  Expensemodel({
    required this.expensename,
    required this.Amount,
    required this.addtime,
    required this.note1,
    required this.ImageLocalAddress,
    required this.ImageCloundAddress,
    required this.walletId,
    required this.userId,
    String? expenseIDgiven,
  }) : expenseID = expenseIDgiven ?? Uuid().v4().toString();

  final String expensename;
  final int Amount;
  final String addtime;
  final String note1;
  final String ImageLocalAddress;
  final String ImageCloundAddress;
  final String walletId;
  final String userId;
  final String expenseID;
}
