import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdfx/pdfx.dart';

void main() {
  runApp(const WckVaultApp());
}

class Product {
  final String title;
  final String product;
  final String description;
  final String applications;
  final String technicalData;
  final String methodology;
  final String limitations;
  final String revision;
  final String sourceStatus;
  final String pdfAsset;
  final String searchText;

  Product(Map<String, dynamic> data)
      : title = '${data['title'] ?? ''}',
        product = '${data['product'] ?? ''}',
        description = '${data['description'] ?? ''}',
        applications = '${data['applications'] ?? ''}',
        technicalData = '${data['technicalData'] ?? ''}',
        methodology = '${data['methodology'] ?? ''}',
        limitations = '${data['limitations'] ?? ''}',
        revision = '${data['revision'] ?? ''}',
        sourceStatus = '${data['sourceStatus'] ?? ''}',
        pdfAsset = '${data['pdfAsset'] ?? ''}',
        searchText = '${data['searchText'] ?? ''}';
}

class WckVaultApp extends StatelessWidget {
  const WckVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WCK Vault',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

// -----------------------------------------------------------------------------
// LOGIN
// -----------------------------------------------------------------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (mobileController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Mobile/ID and Password.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final otpController = TextEditingController();

        return AlertDialog(
          title: const Text('OTP Verification'),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter OTP',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                );
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Icon(
                      Icons.water_damage_outlined,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'WCK Vault',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Waterproofing & Construction Knowledge Vault',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Created by Noyon',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: mobileController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile / ID',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: login,
                        icon: const Icon(Icons.login),
                        label: const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HOME
// -----------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool loading = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadKnowledgeBase();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadKnowledgeBase() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/knowledge_base.json',
      );

      final decoded = jsonDecode(raw);

      List<dynamic> rows;

      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final possible = decoded['products'] ?? decoded['items'] ?? [];
        rows = possible is List ? possible : [];
      } else {
        rows = [];
      }

      final loaded = rows
          .whereType<Map>()
          .map(
            (item) => Product(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        products = loaded;
        filteredProducts = loaded;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        products = [];
        filteredProducts = [];
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Knowledge base could not be loaded: $e',
          ),
        ),
      );
    }
  }

  void searchProducts(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() {
        filteredProducts = products;
      });
      return;
    }

    setState(() {
      filteredProducts = products.where((product) {
        final text = [
          product.title,
          product.product,
          product.description,
          product.applications,
          product.technicalData,
          product.methodology,
          product.limitations,
          product.revision,
          product.searchText,
        ].join(' ').toLowerCase();

        return text.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WCK Vault'),
        actions: [
          IconButton(
            tooltip: 'Super Admin',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminPage(),
                ),
              );
            },
            icon: const Icon(Icons.admin_panel_settings_outlined),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchProducts,
                    decoration: InputDecoration(
                      hintText:
                          'Search product, TDS, application, technical data...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                searchController.clear();
                                searchProducts('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filteredProducts.length} records',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching WCK Vault records found.',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            0,
                            12,
                            20,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];

                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(
                                    Icons.description_outlined,
                                  ),
                                ),
                                title: Text(
                                  product.product.isEmpty
                                      ? product.title
                                      : product.product,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductPage(
                                        product: product,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCT DETAIL
// -----------------------------------------------------------------------------

class ProductPage extends StatelessWidget {
  final Product product;

  const ProductPage({
    super.key,
    required this.product,
  });

  Widget section(
    BuildContext context,
    String title,
    String text,
  ) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SelectableText(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.product.isEmpty
              ? 'Product Details'
              : product.product,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (product.revision.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Revision: ${product.revision}'),
                  ],
                ],
              ),
            ),
          ),
          section(
            context,
            'Description / TDS Information',
            product.description,
          ),
          section(
            context,
            'Application',
            product.applications,
          ),
          section(
            context,
            'Technical Data',
            product.technicalData,
          ),
          section(
            context,
            'Methodology',
            product.methodology,
          ),
          section(
            context,
            'Limitations / Precautions',
            product.limitations,
          ),
          if (product.sourceStatus.isNotEmpty)
            section(
              context,
              'Source Status',
              product.sourceStatus,
            ),
          if (product.pdfAsset.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf_outlined,
                ),
                title: const Text('Open Original PDF'),
                subtitle: const Text(
                  'Read the original source document',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerPage(
                        title: product.title,
                        assetPath: product.pdfAsset,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PDF VIEWER
// -----------------------------------------------------------------------------

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const PdfViewerPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late final PdfControllerPinch controller;

  @override
  void initState() {
    super.initState();

    controller = PdfControllerPinch(
      document: PdfDocument.openAsset(
        widget.assetPath,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: PdfViewPinch(
        controller: controller,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SUPER ADMIN
// -----------------------------------------------------------------------------

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.security_outlined,
              ),
              title: const Text('Super Admin Control'),
              subtitle: const Text(
                'WCK Vault administration structure',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.people_outline,
              ),
              title: const Text('User Management'),
              subtitle: const Text(
                'Approval, permissions, suspension and revocation',
              ),
              onTap: () {
                showInfo(
                  context,
                  'User Management',
                  'Production server-side user management will be connected here.',
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
              ),
              title: const Text('PDF Review'),
              subtitle: const Text(
                'Review original PDF source documents',
              ),
              onTap: () {
                showInfo(
                  context,
                  'PDF Review',
                  'Original source PDFs are designed to remain separate by revision/source file.',
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.settings_outlined,
              ),
              title: const Text('System Settings'),
              subtitle: const Text(
                'WCK Vault application configuration',
              ),
              onTap: () {
                showInfo(
                  context,
                  'System Settings',
                  'Production backend and security configuration will be connected here.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
