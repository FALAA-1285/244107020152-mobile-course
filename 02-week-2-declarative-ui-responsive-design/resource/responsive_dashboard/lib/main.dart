import 'package:flutter/material.dart';

// 1. Memindahkan breakpoint ke konstanta global
const double kWideBreakpoint = 700;

void main() => runApp(const AcademicOverviewApp());

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({super.key});

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Overview',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true, 
        brightness: Brightness.dark, 
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AcademicOverviewPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              ),
              const SizedBox(width: 4),
              Semantics(
                label: 'Toggle tema gelap',
                child: Switch.adaptive(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Profil Mahasiswa: Ahmad Falahi, Information Technology, Politeknik Negeri Malang',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        child: Icon(
                          Icons.person, 
                          size: 40, 
                          color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ahmad Falahi',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Information Technology\nPoliteknik Negeri Malang',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Semantics(
                header: true,
                child: Text(
                  'Statistik Akademik',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  // 2. Menggunakan konstanta breakpoint
                  final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth >= kWideBreakpoint ? 2.5 : 3.0,
                    children: const [
                      // 3. Menggunakan widget reusable bernama InfoCard
                      InfoCard(
                        title: 'IPK', 
                        value: '3.85', 
                        icon: Icons.school,
                        semanticLabel: 'Indeks Prestasi Kumulatif 3.85',
                      ),
                      InfoCard(
                        title: 'SKS Selesai', 
                        value: '84', 
                        icon: Icons.library_books,
                        semanticLabel: 'Total SKS yang telah diselesaikan 84',
                      ),
                      InfoCard(
                        title: 'Kehadiran', 
                        value: '95%', 
                        icon: Icons.check_circle,
                        semanticLabel: 'Persentase Kehadiran 95 persen',
                      ),
                      InfoCard(
                        title: 'Tugas Aktif', 
                        value: '3', 
                        icon: Icons.assignment,
                        semanticLabel: 'Ada 3 tugas aktif yang belum selesai',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 4. Widget yang diekstrak dan diubah namanya menjadi InfoCard
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title, 
    required this.value, 
    required this.icon,
    required this.semanticLabel,
    super.key,
  });
  
  final String title;
  final String value;
  final IconData icon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // 5. Mengganti hardcode Colors.black dengan Theme dan menggunakan withValues (menggantikan withOpacity)
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 40, 
              color: Theme.of(context).colorScheme.onSecondaryContainer
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title, 
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value, 
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    )
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