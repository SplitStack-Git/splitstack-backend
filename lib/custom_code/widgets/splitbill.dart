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

import 'index.dart'; // Imports other custom widgets

import 'package:flutter/foundation.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_contacts/flutter_contacts.dart';

class Splitbill extends StatefulWidget {
  const Splitbill(
      {super.key,
      this.width,
      this.height,
      this.data,
      this.totalamount,
      this.splitValue,
      this.callback,
      this.addcontacts,
      this.uid,
      this.participentImage,
      this.currencySymbol});

  final double? width;
  final double? height;
  final List<ParticipantsStruct>? data;
  final double? totalamount;
  final String? splitValue;
  final Future Function(List<ParticipantsStruct>? update, double? amount)?
      callback;
  final Future Function(List<ParticipantsStruct>? update, double? amount)?
      addcontacts;
  final String? uid;
  final Widget Function()? participentImage;
  final String? currencySymbol;

  @override
  State<Splitbill> createState() => _SplitbillState();
}

class _SplitbillState extends State<Splitbill> {
  late List<ParticipantsStruct> _participants;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  bool _isPhoneValid = false;

  double get _step => double.tryParse((widget.splitValue ?? '1').trim()) ?? 1.0;
  double get _totalAmount => widget.totalamount ?? 0.0;
  double get _perParticipantFee => 0.40;

  double get _targetTotalWithFees =>
      _totalAmount + (_participants.length * _perParticipantFee);

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _triggerCallback() async {
    if (widget.callback != null) {
      final double fullAmount =
          _participants.fold(0.0, (sum, p) => sum + p.amount);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.callback!(_participants, fullAmount);
      });
    }
  }

  Future<void> _triggerAddContactsCallback() async {
    if (widget.addcontacts != null) {
      final double fullAmount =
          _participants.fold(0.0, (sum, p) => sum + p.amount);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.addcontacts!(_participants, fullAmount);
      });
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
    final autoIndices = _autoIndices();
    if (autoIndices.isEmpty) return;

    final targetRemaining = _targetTotalWithFees - lockedTotal;

    final existingAutos = <int>[];
    final newAutos = <int>[];
    double sumExisting = 0;

    for (final i in autoIndices) {
      if (_participants[i].amount > 0) {
        existingAutos.add(i);
        sumExisting += _participants[i].amount;
      } else {
        newAutos.add(i);
      }
    }

    if (existingAutos.isEmpty) {
      final each = double.parse(
          (targetRemaining / autoIndices.length).toStringAsFixed(2));
      for (final i in autoIndices) {
        _participants[i].amount = each;
      }
    } else if (newAutos.isEmpty) {
      if (sumExisting > 0) {
        final multiplier = targetRemaining / sumExisting;
        for (final i in existingAutos) {
          _participants[i].amount = double.parse(
              (_participants[i].amount * multiplier).toStringAsFixed(2));
        }
      }
    } else {
      final multiplierCount = existingAutos.length / autoIndices.length;
      final targetForExisting = targetRemaining * multiplierCount;
      final scaleFactor =
          (sumExisting > 0) ? (targetForExisting / sumExisting) : 1.0;

      for (final i in existingAutos) {
        _participants[i].amount = double.parse(
            (_participants[i].amount * scaleFactor).toStringAsFixed(2));
      }

      final shareForNew =
          (targetRemaining - targetForExisting) / newAutos.length;
      final roundedNew = double.parse(shareForNew.toStringAsFixed(2));
      for (final i in newAutos) {
        _participants[i].amount = roundedNew;
      }
    }

    setState(() {});
    _triggerCallback();
  }

  void _normalizeTotals() {
    if (_participants.isEmpty) return;

    final sum = _participants.fold(0.0, (s, p) => s + p.amount);
    final diff = _targetTotalWithFees - sum;

    final autos = _autoIndices();
    if (autos.isNotEmpty) {
      final per = diff / autos.length;
      final roundedPer = double.parse(per.toStringAsFixed(2));

      for (final i in autos) {
        _participants[i].amount += roundedPer;
      }
    }
  }

  String _normalizePhone(String value) {
    return value.trim();
  }

  bool _isValidPhone(String phone) {
    // Only check if empty as requested
    return phone.trim().isNotEmpty;
  }

  bool _isPhoneAlreadyAdded(String phone) {
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return false;

    for (final participant in _participants) {
      final existingPhone = _normalizePhone(participant.phone);
      if (existingPhone.isNotEmpty && existingPhone == normalized) {
        return true;
      }
    }
    return false;
  }

  Future<void> _addPerson() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Name is required' : null;

      if (phone.isEmpty) {
        _phoneError = 'Phone number is required';
      } else {
        _phoneError = null;
      }
    });

    if (_nameError != null || _phoneError != null) return;

    final normalizedPhone = _normalizePhone(phone);

    _participants.add(
      ParticipantsStruct(
        name: name,
        phone: normalizedPhone,
        amount: 0,
        lock: false,
        paidStatus: false,
        paymentLinkSend: false,
        pendingPayment: false,
        userID: '',
      ),
    );

    _nameController.clear();
    _phoneController.clear();
    _isPhoneValid = false;
    setState(() {});
    _recalculateAutoSplit();
    _normalizeTotals();
  }

  Future<void> _removePerson(int index) async {
    _participants.removeAt(index);

    if (_participants.isNotEmpty) {
      _recalculateAutoSplit();
      _normalizeTotals();
    } else {
      await _triggerCallback();
    }

    setState(() {});
  }

  Future<void> _toggleLock(int index) async {
    _participants[index].lock = !(_participants[index].lock == true);
    _recalculateAutoSplit();
    _normalizeTotals();
  }

  Future<void> _changeAmount(int index, bool plus) async {
    final p = _participants[index];
    if (p.lock == true) return;

    final delta = plus ? _step : -_step;

    if (!plus && (p.amount + delta) < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Limit reached! ${p.name}'s split can't go any lower."),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final others = <int>[];
    for (int i = 0; i < _participants.length; i++) {
      if (i != index && _participants[i].lock != true) {
        others.add(i);
      }
    }

    if (others.isNotEmpty) {
      final adjust = delta / others.length;
      final roundedAdjust = double.parse(adjust.toStringAsFixed(2));

      for (final i in others) {
        if ((_participants[i].amount - roundedAdjust) < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Can't reduce further—it would put some participant's split below ${widget.currencySymbol}0.",
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      p.amount += delta;

      for (final i in others) {
        _participants[i].amount -= roundedAdjust;
      }
    } else {
      p.amount += delta;
    }

    _normalizeTotals();
    setState(() {});
  }

  Future<void> _resetEqualSplit() async {
    if (_participants.isEmpty) return;

    final each = _targetTotalWithFees / _participants.length;
    final roundedEach = double.parse(each.toStringAsFixed(2));

    for (final p in _participants) {
      p.lock = false;
      p.amount = roundedEach;
    }

    setState(() {});
    await _triggerCallback();
  }

  Future<void> _showLimitedAccessDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Limited Access',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You have granted limited access to your contacts. To add more people, you need to update your selection in Settings.',
          style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Open Settings',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<List<_LocalContact>> _fetchContacts() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) return [];

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    final List<_LocalContact> result = [];

    for (final contact in contacts) {
      if (contact.phones.isEmpty) continue;

      final rawPhone = contact.phones.first.number.trim();
      final cleanPhone = _normalizePhone(rawPhone);
      if (cleanPhone.isEmpty) continue;

      result.add(
        _LocalContact(
          name: contact.displayName.trim().isEmpty
              ? 'Unnamed Contact'
              : contact.displayName.trim(),
          phone: rawPhone,
        ),
      );
    }

    return result;
  }

  Future<void> _openContactPicker() async {
    final status = await Permission.contacts.status;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Contact picker is not supported on web. Please add contacts manually.'),
        ),
      );
      return;
    }

    if (status == PermissionStatus.denied) {
      final requested = await FlutterContacts.requestPermission();
      if (!requested) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact permission denied.')),
        );
        return;
      }
    }

    if (status == PermissionStatus.restricted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact access is restricted.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    List<_LocalContact> contacts = [];
    try {
      contacts = await _fetchContacts();
    } catch (_) {
      contacts = [];
    }

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!mounted) return;

    if (contacts.isEmpty && status != PermissionStatus.limited) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No contacts found or permission denied.'),
        ),
      );
      return;
    }

    final currentStatus = await Permission.contacts.status;

    final selectedContacts =
        await _showContactsBottomSheet(contacts, currentStatus);

    if (selectedContacts == null || selectedContacts.isEmpty) return;

    bool addedAny = false;

    for (final contact in selectedContacts) {
      if (_isPhoneAlreadyAdded(contact.phone)) continue;

      _participants.add(
        ParticipantsStruct(
          name: contact.name,
          phone: contact.phone,
          amount: 0,
          lock: false,
          paidStatus: false,
          paymentLinkSend: false,
          pendingPayment: false,
          userID: '',
        ),
      );
      addedAny = true;
    }

    if (!addedAny) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected contacts are already added.'),
        ),
      );
      return;
    }

    _recalculateAutoSplit();
    _normalizeTotals();
    setState(() {});

    await _triggerAddContactsCallback();
  }

  Future<List<_LocalContact>?> _showContactsBottomSheet(
    List<_LocalContact> contacts,
    PermissionStatus status,
  ) async {
    final Set<String> selectedPhones = {};

    return showModalBottomSheet<List<_LocalContact>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSetState) {
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.78,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 40),
                        const Expanded(
                          child: Text(
                            'Select Contacts',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (status == PermissionStatus.limited)
                          IconButton(
                            onPressed: _showLimitedAccessDialog,
                            icon: widget.participentImage!(),
                          )
                        else
                          const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final item = contacts[index];
                          final normalizedPhone = _normalizePhone(item.phone);
                          final isSelected =
                              selectedPhones.contains(normalizedPhone);
                          final isAlreadyAdded =
                              _isPhoneAlreadyAdded(item.phone);

                          return InkWell(
                            key: ValueKey(item.phone),
                            onTap: isAlreadyAdded
                                ? null
                                : () {
                                    bottomSetState(() {
                                      if (isSelected) {
                                        selectedPhones.remove(normalizedPhone);
                                      } else {
                                        selectedPhones.add(normalizedPhone);
                                      }
                                    });
                                  },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : const Color(0xFFE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isAlreadyAdded
                                    ? const Color(0xFFF9FAFB)
                                    : Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.green
                                            : const Color(0xFFD1D5DB),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: isAlreadyAdded
                                                ? const Color(0xFF9CA3AF)
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.phone,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAlreadyAdded)
                                    const Text(
                                      'Added',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final selected = contacts.where((c) {
                            return selectedPhones
                                .contains(_normalizePhone(c.phone));
                          }).toList();

                          Navigator.pop(context, selected);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Submit (${selectedPhones.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _currentTotal() => _participants.fold(0.0, (s, p) => s + p.amount);
  int _lockedCount() => _participants.where((p) => p.lock == true).length;
  int _autoCount() => _participants.where((p) => p.lock != true).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// CONTACT BUTTON
          InkWell(
            onTap: _openContactPicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Select participants from contacts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.person_add, color: Colors.white),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// ADD PERSON
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        onChanged: (val) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter name...',
                          border: InputBorder.none,
                          errorText: _nameError,
                          errorStyle: const TextStyle(
                              height: 0.8, color: Color(0xffff5963)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        onChanged: (val) {
                          if (_phoneError != null) {
                            setState(() => _phoneError = null);
                          }
                          setState(() {
                            _isPhoneValid = _isValidPhone(val);
                          });
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Mobile number',
                          hintStyle: const TextStyle(
                              fontSize: 14, color: Color(0xff57636c)),
                          border: InputBorder.none,
                          errorText: _phoneError,
                          errorStyle: const TextStyle(
                              height: 0.8, color: Color(0xffff5963)),
                        ),
                      ),
                    ],
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

          Column(
            children: _participants.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              final bool isYou = widget.uid != null && widget.uid == p.userID;

              return Container(
                key: ValueKey(p.phone + (p.userID ?? '')),
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
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                        Text(
                          '${widget.currencySymbol}${p.amount.toStringAsFixed(2)}',
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
            }).toList(),
          ),

          const SizedBox(height: 8),

          /// FOOTER
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
                  '${widget.currencySymbol}${_currentTotal().toStringAsFixed(2)} total • Balanced',
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

class _LocalContact {
  final String name;
  final String phone;

  _LocalContact({
    required this.name,
    required this.phone,
  });
}
