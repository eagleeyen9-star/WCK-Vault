import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdfx/pdfx.dart';

void main() => runApp(const WckVaultApp());

class Product {
  final String title, product, description, applications, technicalData, methodology, limitations, revision, sourceStatus, pdfAsset, searchText;
  Product(Map<String, dynamic> x)
      : title = x['title'] ?? '',
        product = x['product'] ?? '',
        description = x['description'] ?? '',
        applications = x['applications'] ?? '',
        technicalData = x['technicalData'] ?? '',
        methodology = x['methodology'] ?? '',
        limitations = x['limitations'] ?? '',
        revision = x['revision'] ?? '',
        sourceStatus = x['sourceStatus'] ?? '',
        pdfAsset = x['pdfAsset'] ?? '',
        searchText = x['searchText'] ?? '';
}

class WckVaultApp extends StatelessWidget {
  const WckVaultApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WCK Vault',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: const LoginPage(),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final id = TextEditingController();
  final pass = TextEditingController();
  void login() {
    if (id.text.trim().isEmpty || pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter Mobile / ID and Password.')));
      return;
    }
    showDialog<bool>(context: context, builder: (c) {
      final otp = TextEditingController();
      return AlertDialog(
        title: const Text('OTP Verification'),
        content: TextField(controller: otp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OTP')),
        actions: [FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Verify'))],
      );
    }).then((ok) {
      if (ok == true && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }
  @override
  Widget build(BuildContext c) => Scaffold(
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Card(margin: const EdgeInsets.all(24), child: Padding(
      padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.water_drop, size: 64),
        const SizedBox(height: 10),
        const Text('WCK Vault', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const Text('Waterproofing & Construction Knowledge Vault', textAlign: TextAlign.center),
        const SizedBox(height: 6), const Text('Created by Noyon'),
        const SizedBox(height: 26),
        TextField(controller: id, decoration: const InputDecoration(labelText: 'Mobile / ID', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: login, icon: const Icon(Icons.login), label: const Padding(padding: EdgeInsets.all(12), child: Text('Login / Register')))),
        const SizedBox(height: 12),
        const Text('Production authentication/OTP must be connected to the secured backend before deployment.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
      ])))));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int tab = 0;
  List<Product> products = [];
  List<Product> filtered = [];
  final search = TextEditingController();
  @override void initState() { super.initState(); load(); }
  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/knowledge_base.json');
    final list = (jsonDecode(raw) as List).map((e) => Product(e)).toList();
    if (mounted) setState(() { products = list; filtered = list; });
  }
  void filter(String q) {
    final x = q.trim().toLowerCase();
    setState(() => filtered = x.isEmpty ? products : products.where((p) => ('${p.title} ${p.product} ${p.description} ${p.applications} ${p.technicalData} ${p.methodology} ${p.searchText}').toLowerCase().contains(x)).toList());
  }
  void logout() => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('WCK Vault'), actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout), tooltip: 'Logout')]),
    drawer: NavigationDrawer(selectedIndex: tab, onDestinationSelected: (i) { Navigator.pop(c); setState(() => tab = i); }, children: const [
      Padding(padding: EdgeInsets.fromLTRB(28, 24, 28, 12), child: Text('Created by Noyon', style: TextStyle(fontWeight: FontWeight.bold))),
      NavigationDrawerDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
      NavigationDrawerDestination(icon: Icon(Icons.library_books_outlined), selectedIcon: Icon(Icons.library_books), label: Text('PDF / Product Library')),
      NavigationDrawerDestination(icon: Icon(Icons.manage_search), selectedIcon: Icon(Icons.search), label: Text('Knowledge Search')),
      NavigationDrawerDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: Text('Super Admin')),
      NavigationDrawerDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history), label: Text('Audit Log')),
    ]),
    body: tab == 0 ? Dashboard(products: products, onOpen: () => setState(() => tab = 1)) :
           tab == 1 ? Library(products: filtered, search: search, onSearch: filter) :
           tab == 2 ? Library(products: filtered, search: search, onSearch: filter, searchMode: true) :
           tab == 3 ? const AdminPanel() : const AuditLog(),
  );
}

class Dashboard extends StatelessWidget {
  final List<Product> products; final VoidCallback onOpen;
  const Dashboard({super.key, required this.products, required this.onOpen});
  @override Widget build(BuildContext c) => ListView(padding: const EdgeInsets.all(24), children: [
    const Text('Super Admin Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6), const Text('Waterproofing & Construction Knowledge Vault'), const SizedBox(height: 24),
    Wrap(spacing: 16, runSpacing: 16, children: [
      stat('Knowledge records', '${products.length}', Icons.library_books),
      stat('Source PDFs available', '133', Icons.picture_as_pdf),
      stat('Final source inventory', '133', Icons.inventory_2),
      stat('Pending inventory', '0', Icons.pending_actions),
    ]),
    const SizedBox(height: 26),
    Card(child: ListTile(leading: const Icon(Icons.info_outline), title: const Text('Vault structure'), subtitle: const Text('Category → Product → TDS → Application → Technical Data → Methodology → Limitations → Revision → Original PDF'), trailing: FilledButton(onPressed: onOpen, child: const Text('Open Library')))),
    const SizedBox(height: 10),
    const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Inventory policy: 133 source PDFs are the final WCK Vault source set. Original PDF titles are preserved exactly; separate revisions/source files remain separate; no unrelated product visual is substituted.'))),
  ]);
  Widget stat(String a, String b, IconData i) => SizedBox(width: 230, height: 120, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i), const Spacer(), Text(b, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(a)]))));
}

class Library extends StatelessWidget {
  final List<Product> products; final TextEditingController search; final ValueChanged<String> onSearch; final bool searchMode;
  const Library({super.key, required this.products, required this.search, required this.onSearch, this.searchMode = false});
  @override Widget build(BuildContext c) => Column(children: [
    Padding(padding: const EdgeInsets.all(16), child: TextField(controller: search, onChanged: onSearch, decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: searchMode ? 'Search the full indexed PDF text...' : 'Search product, application, technical data...', suffixIcon: IconButton(onPressed: () { search.clear(); onSearch(''); }, icon: const Icon(Icons.clear)), border: const OutlineInputBorder()))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: Text('${products.length} matching records'))),
    const SizedBox(height: 8),
    Expanded(child: ListView.builder(itemCount: products.length, itemBuilder: (c, i) { final p = products[i]; return Card(margin: const EdgeInsets.fromLTRB(16, 4, 16, 6), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.description)), title: Text(p.product, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${p.title}\n${p.applications}', maxLines: 2, overflow: TextOverflow.ellipsis), isThreeLine: true, trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => ProductPage(p))))); }))
  ]);
}

class ProductPage extends StatelessWidget {
  final Product p; const ProductPage(this.p, {super.key});
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text(p.product)), body: ListView(padding: const EdgeInsets.all(20), children: [
    Text(p.product, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6), SelectableText(p.title, style: const TextStyle(fontSize: 14)), const SizedBox(height: 14),
    FilledButton.icon(onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PdfViewerPage(title: p.title, asset: p.pdfAsset))), icon: const Icon(Icons.picture_as_pdf), label: const Text('Open Original PDF')),
    const SizedBox(height: 14),
    section('Description', p.description), section('Applications', p.applications), section('Technical Data', p.technicalData), section('Methodology / Application', p.methodology), section('Limitations / Precautions', p.limitations), section('Revision / Version', p.revision), section('Source Status', p.sourceStatus),
  ]);
  Widget section(String h, String b) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 7), SelectableText(b)])));
}

class PdfViewerPage extends StatefulWidget {
  final String title, asset; const PdfViewerPage({super.key, required this.title, required this.asset});
  @override State<PdfViewerPage> createState() => _PdfViewerPageState();
}
class _PdfViewerPageState extends State<PdfViewerPage> {
  late final PdfControllerPinch controller;
  @override void initState() { super.initState(); controller = PdfControllerPinch(document: PdfDocument.openAsset(widget.asset)); }
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text(widget.title)), body: PdfViewPinch(controller: controller));
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override Widget build(BuildContext c) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Super Admin Control', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 15),
    const Card(child: ListTile(leading: Icon(Icons.admin_panel_settings), title: Text('Noyon — Sole Super Admin'), subtitle: Text('Full control • PDF read/review/revision • users • permissions • suspension/revocation'))),
    const Card(child: ListTile(leading: Icon(Icons.picture_as_pdf), title: Text('PDF inventory'), subtitle: Text('133 source PDFs bundled. This is the final WCK Vault source inventory.'))),
    const Card(child: ListTile(leading: Icon(Icons.security), title: Text('Production security'), subtitle: Text('Connect authenticated backend, OTP provider, protected storage, role/permission service and server-side audit logging before public deployment.'))),
    const Card(child: ListTile(leading: Icon(Icons.image_not_supported), title: Text('Product visual policy'), subtitle: Text('Use the clear visual from the source PDF when available. Never substitute an unrelated image. If unclear, mark as no clear source visual.'))),
  ]);
}
class AuditLog extends StatelessWidget { const AuditLog({super.key}); @override Widget build(BuildContext c) => ListView(padding: const EdgeInsets.all(20), children: const [Text('Audit Log', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), Card(child: ListTile(leading: Icon(Icons.login), title: Text('Local session event'), subtitle: Text('Production server audit logging is required for deployment.'))), Card(child: ListTile(leading: Icon(Icons.library_books), title: Text('Knowledge Base access'), subtitle: Text('Library/search access event.')))]); }
