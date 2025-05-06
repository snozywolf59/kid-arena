import 'package:flutter/material.dart';
import 'package:kid_arena/screens/student/progress_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/300',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Class 8A',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Progress'),
                  Tab(text: 'Achievements'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            const ProgressScreen(),
            _buildAchievementsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Personal Information', [
            _buildInfoRow(Icons.person, 'Full Name', 'John Doe'),
            _buildInfoRow(Icons.email, 'Email', 'john.doe@example.com'),
            _buildInfoRow(Icons.phone, 'Phone', '+84 123 456 789'),
            _buildInfoRow(Icons.cake, 'Date of Birth', '01/01/2008'),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Academic Information', [
            _buildInfoRow(Icons.school, 'Class', '8A'),
            _buildInfoRow(Icons.grade, 'Grade', '8'),
            _buildInfoRow(Icons.calendar_today, 'Join Date', '01/09/2023'),
            _buildInfoRow(Icons.assignment, 'Student ID', 'STU2023001'),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Parent Information', [
            _buildInfoRow(Icons.person, 'Father\'s Name', 'Michael Doe'),
            _buildInfoRow(Icons.phone, 'Father\'s Phone', '+84 123 456 788'),
            _buildInfoRow(Icons.person, 'Mother\'s Name', 'Sarah Doe'),
            _buildInfoRow(Icons.phone, 'Mother\'s Phone', '+84 123 456 787'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAchievementCard(
          'Math Champion',
          'Achieved highest score in Mathematics',
          Icons.emoji_events,
          Colors.amber,
        ),
        const SizedBox(height: 16),
        _buildAchievementCard(
          'Perfect Attendance',
          'No absences for 3 months',
          Icons.calendar_today,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildAchievementCard(
          'Science Explorer',
          'Completed all science experiments',
          Icons.science,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
