import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:kid_arena/services/auth_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/utils/index.dart';
import 'package:kid_arena/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedGender;
  String? selectedRole;
  final _dateOfBirthController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _gradeController = TextEditingController();
  final _classNameController = TextEditingController();
  final _schoolNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Parse date from dd/mm/yyyy format
        final dateParts = _dateOfBirthController.text.split('/');
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);

        if (selectedRole == 'teacher') {
          await getIt<AuthService>().registerTeacher(
            _nameController.text.toString().trim(),
            _usernameController.text.toString(),
            _passwordController.text.toString(),
            selectedGender.toString(),
            selectedRole.toString(),
            DateTime(year, month, day).toIso8601String(),
          );
        } else if (selectedRole == 'student') {
          await getIt<AuthService>().registerStudent(
            _nameController.text.toString().trim(),
            _usernameController.text.toString(),
            _passwordController.text.toString(),
            selectedGender.toString(),
            selectedRole.toString(),
            DateTime(year, month, day).toIso8601String(),
            int.parse(_gradeController.text.toString()),
            _classNameController.text.toString(),
            _schoolNameController.text.toString(),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng ký thành công!')),
            );
            Navigator.pop(context);
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Đã xảy ra lỗi';
        if (e.code == 'weak-password') {
          message = 'Mật khẩu quá yếu';
        } else if (e.code == 'email-already-in-use') {
          message = 'Email đã được sử dụng';
        }
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xảy ra lỗi không xác định')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dateOfBirthController,
                  decoration: const InputDecoration(
                    labelText: 'Ngày sinh',
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'dd/mm/yyyy',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _DateInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập ngày sinh';
                    }
                    // Validate date format
                    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                    if (!dateRegex.hasMatch(value)) {
                      return 'Định dạng ngày không hợp lệ (dd/mm/yyyy)';
                    }
                    // Validate date values
                    final parts = value.split('/');
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);

                    if (day < 1 ||
                        day > 31 ||
                        month < 1 ||
                        month > 12 ||
                        year < 1900 ||
                        year > DateTime.now().year) {
                      return 'Ngày sinh không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Giới tính',
                    prefixIcon: Icon(Icons.people_outline),
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Nam')),
                    DropdownMenuItem(value: 'female', child: Text('Nữ')),
                    DropdownMenuItem(value: 'other', child: Text('Khác')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn giới tính';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Chức vụ',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder(),
                  ),
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(
                      value: 'teacher',
                      child: Text('Giáo viên'),
                    ),
                    DropdownMenuItem(value: 'student', child: Text('Học sinh')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn chức vụ';
                    }
                    return null;
                  },
                ),
                if (selectedRole == 'student') _buildStudentAdditionalForm(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('ĐĂNG KÝ'),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageTransitions.slideTransition(const LoginScreen()),
                    );
                  },
                  child: const Text('Đã có tài khoản? Đăng nhập ngay'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentAdditionalForm() {
    return Column(
      children: [
        const SizedBox(height: 20),
        TextFormField(
          controller: _gradeController,
          decoration: const InputDecoration(labelText: 'Lớp'),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _classNameController,
          decoration: const InputDecoration(labelText: 'Tên lớp'),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _schoolNameController,
          decoration: const InputDecoration(labelText: 'Tên trường'),
        ),
      ],
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
