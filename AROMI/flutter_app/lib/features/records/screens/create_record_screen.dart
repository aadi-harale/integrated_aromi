import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../models/models.dart';
import '../providers/records_provider.dart';

class CreateRecordScreen extends ConsumerStatefulWidget {
  const CreateRecordScreen({super.key});

  @override
  ConsumerState<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends ConsumerState<CreateRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = 'M';
  DateTime? _selectedDob;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? now.subtract(const Duration(days: 365 * 2)),
      firstDate: now.subtract(const Duration(days: 365 * 6)), // 0-6 years
      lastDate: now,
      helpText: 'बच्चे की जन्म तिथि चुनें',
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया जन्म तिथि चुनें (Select date of birth)'),
          backgroundColor: AromiTheme.error,
        ),
      );
      return;
    }

    final newChildData = ChildCreate(
      name: _nameController.text.trim(),
      dob: DateFormat('yyyy-MM-dd').format(_selectedDob!),
      gender: _gender,
      parentName: _parentNameController.text.trim().isEmpty ? null : _parentNameController.text.trim(),
      parentPhone: _parentPhoneController.text.trim().isEmpty ? null : _parentPhoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
    );

    final createdChild = await ref.read(childrenNotifierProvider.notifier).createChild(newChildData);

    if (!mounted) return;

    if (createdChild != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${createdChild.name} सफलतापूर्वक पंजीकृत (Registered successfully)'),
          backgroundColor: AromiTheme.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पंजीकरण विफल रहा। कृपया पुनः प्रयास करें।'),
          backgroundColor: AromiTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childrenNotifierProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('नया बच्चा पंजीकृत करें (New Child)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Guidance banner
              Card(
                color: AromiTheme.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AromiTheme.primary.withValues(alpha: 0.3)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Icon(Icons.mic_rounded, color: AromiTheme.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'टीप: आप आवाज़ (Voice Assistant) से भी बच्चे का फॉर्म भर सकते हैं!',
                          style: TextStyle(
                            fontSize: 13,
                            color: AromiTheme.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'बच्चे का नाम (Child Name) *',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'कृपया नाम दर्ज करें (Enter child name)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date of Birth
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDob(context),
                decoration: const InputDecoration(
                  labelText: 'जन्म तिथि (Date of Birth) *',
                  prefixIcon: Icon(Icons.cake_outlined),
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'कृपया जन्म तिथि चुनें (Select Date of Birth)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'लिंग (Gender)',
                  prefixIcon: Icon(Icons.people_outline_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('लड़का (Boy / Male)')),
                  DropdownMenuItem(value: 'F', child: Text('लड़की (Girl / Female)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _gender = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Parent Name
              TextFormField(
                controller: _parentNameController,
                decoration: const InputDecoration(
                  labelText: 'माता/पिता का नाम (Parent Name)',
                  prefixIcon: Icon(Icons.family_restroom_rounded),
                ),
              ),

              const SizedBox(height: 16),

              // Parent Phone
              TextFormField(
                controller: _parentPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'फोन नंबर (Phone Number)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'पता / गाँव (Address)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),

              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'पंजीकृत करें (Save Child Record)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
