// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class Splitbill extends StatefulWidget {
  const Splitbill({
    super.key,
    this.width,
    this.height,
    this.data,
    this.totalamount,
    this.splitValue,
    this.callback,
    this.uid,
  });

  final double? width;
  final double? height;
  final List<ParticipantsStruct>? data;
  final double? totalamount;
  final String? splitValue;
  final Future Function(List<ParticipantsStruct>? update, double? amount)?
      callback;
  final String? uid;

  @override
  State<Splitbill> createState() => _SplitbillState();
}

class _SplitbillState extends State<Splitbill> {
  late List<ParticipantsStruct> _participants;
  final TextEditingController _nameController = TextEditingController();

  double get _step => double.tryParse((widget.splitValue ?? '1').trim()) ?? 1.0;
  double get _totalAmount => widget.totalamount ?? 0.0;

  @override
  void initState() {
    super.initState();
    _participants = List<ParticipantsStruct>.from(widget.data ?? []);
    _recalculateAutoSplit();
  }

  @override
  void didUpdateWidget(covariant Splitbill oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dataChanged =
        (oldWidget.data?.length ?? 0) != (widget.data?.length ?? 0);
    final totalChanged = oldWidget.totalamount != widget.totalamount;

    if (dataChanged || totalChanged) {
      _participants = List<ParticipantsStruct>.from(widget.data ?? []);
      _recalculateAutoSplit();
    }
  }

  Future<void> _triggerCallback() async {
    if (widget.callback != null) {
      // Pass the full amount (after adjustments) to the callback
      double fullAmount = _participants.fold(0.0, (sum, p) => sum + p.amount);
      await widget.callback!(_participants, fullAmount);
    }
  }

  double _sumLocked() {
    return _participants
        .where((p) => p.lock == true)
        .fold(0.0, (s, p) => s + p.amount);
  }

  List<int> _autoIndices() {
    final idx = <int>[];
    for (int i = 0; i < _participants.length; i++) {
      if (_participants[i].lock != true) idx.add(i);
    }
    return idx;
  }

  void _recalculateAutoSplit() {
    if (_participants.isEmpty) return;

    final lockedTotal = _sumLocked();
    final autos = _autoIndices();
    if (autos.isEmpty) return;

    final remaining = _totalAmount - lockedTotal;
    final each = (remaining / autos.length) + 0.40; // Add 0.40 to each split

    // Rounding to 2 decimal places to avoid rounding errors
    final roundedEach = double.parse(each.toStringAsFixed(2));

    for (final i in autos) {
      _participants[i].amount = roundedEach;
    }

    setState(() {});
    // Trigger callback to pass full amount
    _triggerCallback();
  }

  void _normalizeTotals() {
    if (_participants.isEmpty) return;

    final sum = _participants.fold(0.0, (s, p) => s + p.amount);
    final diff = _totalAmount - sum;

    final autos = _autoIndices();
    if (autos.isNotEmpty) {
      final per = diff / autos.length;

      // Rounding to 2 decimal places to avoid rounding errors
      final roundedPer = double.parse(per.toStringAsFixed(2));

      for (final i in autos) {
        _participants[i].amount += roundedPer;
      }
    }
  }

  Future<void> _addPerson() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    _participants.add(
      ParticipantsStruct(
        name: name,
        amount: 0,
        lock: false,
        paidStatus: false,
        paymentLinkSend: false,
      ),
    );

    _nameController.clear();
    _recalculateAutoSplit();
    _normalizeTotals();
    setState(() {});
  }

  Future<void> _removePerson(int index) async {
    _participants[index].amount -=
        0.40; // Remove 0.40 for the removed participant
    _participants.removeAt(index);

    if (_participants.isNotEmpty) {
      _recalculateAutoSplit();
      _normalizeTotals();
    }
    setState(() {});
  }

  Future<void> _toggleLock(int index) async {
    _participants[index].lock = !(_participants[index].lock == true);
    _recalculateAutoSplit();
    _normalizeTotals();
    setState(() {});
  }

  Future<void> _changeAmount(int index, bool plus) async {
    final p = _participants[index];
    if (p.lock == true) return;

    final delta = plus ? _step : -_step;
    p.amount += delta;

    final others = <int>[];
    for (int i = 0; i < _participants.length; i++) {
      if (i != index && _participants[i].lock != true) {
        others.add(i);
      }
    }

    if (others.isNotEmpty) {
      final adjust = delta / others.length;

      // Rounding to 2 decimal places to avoid rounding errors
      final roundedAdjust = double.parse(adjust.toStringAsFixed(2));

      for (final i in others) {
        _participants[i].amount -= roundedAdjust;
      }
    }

    _normalizeTotals();
    setState(() {});
  }

  Future<void> _resetEqualSplit() async {
    if (_participants.isEmpty) return;

    final each = _totalAmount / _participants.length;

    // Rounding to 2 decimal places to avoid rounding errors
    final roundedEach = double.parse(each.toStringAsFixed(2));

    for (final p in _participants) {
      p.lock = false;
      p.amount =
          roundedEach + 0.40; // Add 0.40 to each participant when split equally
    }

    setState(() {});
  }

  double _currentTotal() => _participants.fold(0.0, (s, p) => s + p.amount);
  int _lockedCount() => _participants.where((p) => p.lock == true).length;
  int _autoCount() => _participants.where((p) => p.lock != true).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ADD PERSON
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Add a person...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _addPerson,
                  child: Container(
                    height: 44,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// PARTICIPANTS LIST
          Expanded(
            child: ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final p = _participants[index];
                final bool isYou = widget.uid != null && widget.uid == p.userID;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _toggleLock(index),
                        child: Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Icon(
                            p.lock == true ? Icons.lock : Icons.lock_open,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                if (isYou) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'You',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              p.lock == true ? 'Fixed' : 'Auto-split',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: p.lock == true
                                ? null
                                : () => _changeAmount(index, false),
                            child: Container(
                              height: 36,
                              width: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: p.lock == true
                                    ? const Color(0xFFF3F4F6)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.remove, size: 18),
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// ✅ ONLY CHANGE (DISPLAY)
                          Text(
                            '\$${p.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(width: 12),
                          InkWell(
                            onTap: p.lock == true
                                ? null
                                : () => _changeAmount(index, true),
                            child: Container(
                              height: 36,
                              width: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: p.lock == true
                                    ? const Color(0xFFF3F4F6)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _removePerson(index),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          /// FOOTER (UNCHANGED)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Text(
                  '\$${_currentTotal().toStringAsFixed(2)} total • Balanced',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_lockedCount()} locked • ${_autoCount()} auto-split',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _resetEqualSplit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Reset to Equal Split',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
