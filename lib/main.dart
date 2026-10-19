import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'product.dart';

void main() => runApp(const MiniCatalogApp());

// Our simple demo cart. It exists only while the app is running.
final List<Product> cart = [];

// Read the six products from a local JSON file.
Future<List<Product>> loadProducts() async {
  final text = await rootBundle.loadString('assets/products.json');
  final data = jsonDecode(text) as List<dynamic>;
  return data
      .map((item) => Product.fromJson(item as Map<String, dynamic>))
      .toList();
}

class MiniCatalogApp extends StatelessWidget {
  const MiniCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/products') {
          return MaterialPageRoute(builder: (_) => const ProductsPage());
        }
        if (settings.name == '/details') {
          // This is a route argument: we pass the selected Product.
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => DetailsPage(product: product),
          );
        }
        if (settings.name == '/cart') {
          return MaterialPageRoute(builder: (_) => const CartPage());
        }
        return null;
      },
    );
  }
}

// A cart icon used on the first three pages.
class CartIcon extends StatelessWidget {
  const CartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open cart',
      icon: const Icon(Icons.shopping_cart_outlined),
      onPressed: () => Navigator.pushNamed(context, '/cart'),
    );
  }
}

// SCREEN 1: Home
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Catalog'),
        actions: const [CartIcon()],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, size: 90, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Mini Catalog',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              child: const Text('View Products'),
            ),
          ],
        ),
      ),
    );
  }
}

// SCREEN 2: Products and search
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final Future<List<Product>> productsFuture = loadProducts();
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: const [CartIcon()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Could not read products'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final visible = snapshot.data!
                      .where((p) => p.name
                          .toLowerCase()
                          .contains(search.toLowerCase()))
                      .toList();

                  if (visible.isEmpty) {
                    return const Center(child: Text('No matching products'));
                  }

                  return GridView.builder(
                    itemCount: visible.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final product = visible[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: product,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    product.image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        const Center(
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text('\$${product.price.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SCREEN 3: Details with an Add to Cart button
class DetailsPage extends StatefulWidget {
  final Product product;

  const DetailsPage({super.key, required this.product});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: const [CartIcon()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                product.image,
                height: 230,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) =>
                    const Text('Product photo not found'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(product.description),
            const SizedBox(height: 12),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
              onPressed: () {
                setState(() => cart.add(product));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to cart')),
                );
              },
            ),
            const SizedBox(height: 10),
            Text('Items in cart: ${cart.length}'),
          ],
        ),
      ),
    );
  }
}

// SCREEN 4: Simple cart simulation — no payment or checkout.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (final product in cart) {
      total += product.price;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final product = cart[index];
                      return ListTile(
                        leading: Image.asset(
                          product.image,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.broken_image_outlined),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Remove ${product.name}',
                          onPressed: () {
                            setState(() => cart.removeAt(index));
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
