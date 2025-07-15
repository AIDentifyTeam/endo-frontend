import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:flutter/material.dart';



class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {

  // Sample data
  final List<Map<String, dynamic>> recentPatients = [
    {
      'id': 1,
      'name': 'Sarah Johnson',
      'age': 34,
      'lastVisit': '2025-06-01',
      'tooth': '#14',
      'status': 'Irreversible Pulpitis'
    },
    {
      'id': 2,
      'name': 'Michael Chen',
      'age': 28,
      'lastVisit': '2025-05-30',
      'tooth': '#21',
      'status': 'Reversible Pulpitis'
    },
    {
      'id': 3,
      'name': 'Emma Davis',
      'age': 45,
      'lastVisit': '2025-05-28',
      'tooth': '#36',
      'status': 'Pulp Necrosis'
    },
  ];

  final List<Map<String, dynamic>> recentPapers = [
    {
      'title': 'Novel Approaches to Vital Pulp Therapy',
      'journal': 'IEJ',
      'date': '2025-05-15',
      'rating': 4.8
    },
    {
      'title': 'AI in Endodontic Diagnosis',
      'journal': 'JOE',
      'date': '2025-05-10',
      'rating': 4.9
    },
    {
      'title': 'Regenerative Endodontics Update',
      'journal': 'IEJ',
      'date': '2025-05-05',
      'rating': 4.7
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      drawer: const MainDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEBF4FF),
              Color(0xFFFFFFFF),
              Color(0xFFEEF2FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'EndoDiag Pro',
                subtitle: 'Advanced Endodontic Diagnosis System',
                icon: Icons.favorite,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQuickActions(),
                      SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildRecentPatients(),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                _buildTodaysSummary(),
                                SizedBox(height: 16),
                                _buildLatestResearch(),
                                SizedBox(height: 16),
                                _buildQuickAccess(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'New Patient',
            'Create a new patient record and start diagnosis',
            Icons.add,
            [Color(0xFF10B981), Color(0xFF059669)],
            () {
              Navigator.of(context).pushNamed('/new_patient');
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'Patient History',
            'View and manage existing patient records',
            Icons.history,
            [Color(0xFF3B82F6), Color(0xFF06B6D4)],
            () {
              Navigator.of(context).pushNamed('/patient_history');
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'Research Papers',
            'Latest publications from IEJ and JOE',
            Icons.book_outlined,
            [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, List<Color> colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                Spacer(),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatients() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.people_outline, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text(
                  'Recent Patients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text('View All'),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ...recentPatients.map((patient) => _buildPatientTile(patient)),
        ],
      ),
    );
  }

  Widget _buildPatientTile(Map<String, dynamic> patient) {
    Color statusColor = patient['status'] == 'Irreversible Pulpitis'
        ? Colors.red
        : patient['status'] == 'Reversible Pulpitis'
            ? Colors.orange
            : Colors.purple;

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF2563EB),
            child: Text(
              patient['name'].split(' ').map((n) => n[0]).join(''),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Age: ${patient['age']} • Tooth: ${patient['tooth']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  patient['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                patient['lastVisit'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Today\'s Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSummaryRow('Patients Seen', '8', Color(0xFF2563EB)),
          _buildSummaryRow('Diagnoses Made', '12', Color(0xFF10B981)),
          _buildSummaryRow('RCT Recommended', '5', Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestResearch() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_outlined, color: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              Text(
                'Latest Research',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...recentPapers.map((paper) => _buildPaperTile(paper)),
        ],
      ),
    );
  }

  Widget _buildPaperTile(Map<String, dynamic> paper) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paper['title'],
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: paper['journal'] == 'IEJ' ? Colors.blue[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  paper['journal'],
                  style: TextStyle(
                    color: paper['journal'] == 'IEJ' ? Colors.blue[700] : Colors.green[700],
                    fontSize: 10,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow[600], size: 12),
                  SizedBox(width: 2),
                  Text(
                    paper['rating'].toString(),
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildQuickAccessButton('Schedule', Icons.calendar_today, Color(0xFF2563EB)),
          _buildQuickAccessButton('Reports', Icons.assessment, Color(0xFF10B981)),
          _buildQuickAccessButton('Settings', Icons.settings, Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(12),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}