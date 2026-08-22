import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('अन्य सुविधाएँ (More Features)'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _MoreMenuItem(
            title: 'MPR रिपोर्ट',
            subtitle: 'मासिक प्रगति विवरण',
            icon: Icons.description_outlined,
            color: Colors.indigo,
            onTap: () => context.push('/more/reports'),
          ),
          _MoreMenuItem(
            title: 'दैनिक उपस्थिति',
            subtitle: 'उपस्थिति व आहार',
            icon: Icons.fact_check_outlined,
            color: AromiTheme.primary,
            onTap: () => context.push('/more/attendance'),
          ),
          _MoreMenuItem(
            title: 'स्मार्ट गृह भ्रमण',
            subtitle: 'उच्च-प्राथमिकता सूची',
            icon: Icons.home_work_outlined,
            color: Colors.purple,
            onTap: () => context.push('/more/visits'),
          ),
          _MoreMenuItem(
            title: 'गतिविधि योजना',
            subtitle: 'AI दैनिक सेशन',
            icon: Icons.event_note_rounded,
            color: Colors.orange,
            onTap: () => context.push('/more/activity'),
          ),
          _MoreMenuItem(
            title: 'स्वास्थ्य नियम (RAG)',
            subtitle: 'WHO व ICDS मदद',
            icon: Icons.menu_book_rounded,
            color: AromiTheme.secondary,
            onTap: () => context.push('/more/knowledge'),
          ),
          _MoreMenuItem(
            title: 'फोटो से कुपोषण जाँच',
            subtitle: 'विजुअल स्क्रीनर',
            icon: Icons.camera_alt_rounded,
            color: Colors.pink,
            onTap: () => context.push('/more/photo'),
          ),
          _MoreMenuItem(
            title: 'प्रोफ़ाइल व केंद्र',
            subtitle: 'आपकी जानकारी',
            icon: Icons.person_outline_rounded,
            color: Colors.blueGrey,
            onTap: () => context.push('/more/profile'),
          ),
        ],
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AromiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AromiTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
