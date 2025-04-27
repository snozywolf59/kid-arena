import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thông tin cá nhân')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CircleAvatar(radius: 40),
            TextField(decoration: InputDecoration(labelText: 'Tên đăng nhập')),
            TextField(decoration: InputDecoration(labelText: 'Mật khẩu')),
            TextField(decoration: InputDecoration(labelText: 'Email')),
            TextField(decoration: InputDecoration(labelText: 'Giới tính')),
            TextField(decoration: InputDecoration(labelText: 'Ngày sinh')),
            TextField(decoration: InputDecoration(labelText: 'Khối/Lớp')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text('Đăng xuất')),
          ],
        ),
      ),
    );
  }
}
