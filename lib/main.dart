import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

void main() => runApp(const CampusSwapApp());

// ------------------ APP ROOT ------------------
class CampusSwapApp extends StatefulWidget {
  const CampusSwapApp({super.key});
  @override
  _CampusSwapAppState createState() => _CampusSwapAppState();
}

class _CampusSwapAppState extends State<CampusSwapApp> {
  final List<Order> _placedOrders = [];
  final List<ProductFeedback> _productFeedback = [];
  UserProfile? _currentUserProfile;
  final List<UserAccount> _users = [];
  final List<Item> _items = [
    Item(
      category: 'Science',
      title: 'Lab Coat',
      description: 'Used lab coat in good condition. Size medium.',
      price: 250,
      contact: 'syed@example.com',
      imagePath: 'labcoat.jpg',
    ),
    Item(
      category: 'Electronics',
      title: 'Scientific Calculator',
      description: 'Casio scientific calculator, perfect for engineering students.',
      price: 500,
      contact: 'syed@example.com',
      imagePath: 'calculator.jpg',
    ),
    Item(
      category: 'Books',
      title: 'Organic Chemistry Textbook',
      description: 'Textbook for first-year organic chemistry. Minor wear and tear.',
      price: 800,
      contact: 'syed@example.com',
      imagePath: 'book.jpg',
    ),
  ];

void _login(UserProfile userProfile) => setState(() => _currentUserProfile = userProfile);
  void _logout() => setState(() => _currentUserProfile = null);
  void _addOrder(Order newOrder) => setState(() => _placedOrders.add(newOrder));
  void _addFeedback(ProductFeedback newFeedback) => setState(() => _productFeedback.add(newFeedback));
  void _addItem(Item newItem) => setState(() => _items.add(newItem));
  void _updateProfile(UserProfile updatedProfile) => setState(() => _currentUserProfile = updatedProfile);

  // New: auth helpers
  UserProfile? _authenticate(String email, String password) {
    final match = _users.where((u) => u.email.toLowerCase() == email.toLowerCase()).toList();
    if (match.isEmpty) return null;
    final u = match.first;
    if (u.password != password) return null;
    return UserProfile(name: u.name, contact: u.email);
  }

  void _registerAccount(UserAccount account) {
    // Upsert by email
    setState(() {
      _users.removeWhere((u) => u.email.toLowerCase() == account.email.toLowerCase());
      _users.add(account);
    });
  }

  bool _emailExists(String email) => _users.any((u) => u.email.toLowerCase() == email.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusSwap',
      theme: ThemeData(scaffoldBackgroundColor: const Color.fromARGB(255, 94, 164, 185)),
      debugShowCheckedModeBanner: false,
      home: _currentUserProfile == null
          ? LoginScreen(
              onLogin: _login,
              authenticate: _authenticate,
              onCreateAccount: _registerAccount,
              emailExists: _emailExists,
            )
          : HomeScreen(
              placedOrders: _placedOrders,
              userProfile: _currentUserProfile!,
              onLogout: _logout,
              onAddOrder: _addOrder,
              productFeedback: _productFeedback,
              onUpdateProfile: _updateProfile,
              onAddFeedback: _addFeedback,
              items: _items,
              onAddItem: _addItem,
            ),
    );
  }
}
// ------------------ MODELS ------------------

class UserAccount {
  final String name;
  final String dob; // ISO string or "dd/MM/yyyy"
  final String usn;
  final String email;
  final String branch;
  final String year; // e.g., "1", "2", "3", "4"
  final String password;

  UserAccount({
    required this.name,
    required this.dob,
    required this.usn,
    required this.email,
    required this.branch,
    required this.year,
    required this.password,
  });
}

class Item {
  final String category;
  final String title;
  final String description;
  final double price;
  final String contact;
  final List<Uint8List?>? imageBytes;
  final String? imagePath;
  final String? upiid;
  Item({
    required this.category,
    required this.title,
    required this.description,
    required this.price,
    required this.contact,
    this.imageBytes,
    this.imagePath,
    this.upiid,
  });
}
class Order {
  final List<Item> items;
  final double total;
  final String buyerContact;
  final String deliveryPlace;
  final DateTime orderDate;
   bool isDelivered; // NEW
  List<String> sellerContacts;
  Order({
    required this.items,
    required this.total,
    required this.buyerContact,
    required this.deliveryPlace,
    required this.orderDate,
    this.isDelivered = false,
    required this.sellerContacts,
  });
}

class ProductFeedback {
  final String productTitle;
  final int rating;
  final String comment;
  final String customerContact;
  ProductFeedback({
    required this.productTitle,
    required this.rating,
    required this.comment,
    required this.customerContact,
  });
}

class Product {
  final String name;
  final double price;
  final String upiId;
  Product({required this.name, required this.price, required this.upiId});
}

class UserProfile {
  String name;
  String contact;
  Uint8List? profileImageBytes;
  UserProfile({required this.name, required this.contact, this.profileImageBytes});
}

// ------------------ LOGIN ------------------
class LoginScreen extends StatefulWidget {
  final Function(UserProfile) onLogin;
  final UserProfile? Function(String email, String password) authenticate;
  final void Function(UserAccount) onCreateAccount;
  final bool Function(String email) emailExists;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.authenticate,
    required this.onCreateAccount,
    required this.emailExists,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final profile = widget.authenticate(_email.trim(), _password.trim());
      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
        return;
      }
      widget.onLogin(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 94, 164, 185), Color.fromARGB(255, 209, 155, 235)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.store_mall_directory, size: 40, color: Color.fromARGB(255, 94, 164, 185)),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'CampusSwap',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 94, 164, 185)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Your Campus Marketplace', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.email),
                          filled: true, fillColor: Colors.white,
                        ),
                        onSaved: (val) => _email = val!.trim(),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.lock),
                          filled: true, fillColor: Colors.white,
                        ),
                        obscureText: true,
                        onSaved: (val) => _password = val!.trim(),
                        validator: (val) => (val == null || val.length < 4) ? 'Min 4 chars' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateAccountScreen(
                                onRegister: widget.onCreateAccount,
                                emailExists: widget.emailExists,
                              ),
                            ),
                          );
                        },
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//---------------------------------------CREATE ACCOUNT--------------------------------------
class CreateAccountScreen extends StatefulWidget {
  final void Function(UserAccount) onRegister;
  final bool Function(String email) emailExists;

  const CreateAccountScreen({
    super.key,
    required this.onRegister,
    required this.emailExists,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dobController = TextEditingController();

  String name = '';
  String dob = '';
  String usn = '';
  String email = '';
  String branch = '';
  String year = '';
  String password = '';

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1970),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        dob = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _dobController.text = dob;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.emailExists(email)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email already in use')));
        return;
      }
      widget.onRegister(UserAccount(
        name: name,
        dob: dob,
        usn: usn,
        email: email,
        branch: branch,
        year: year,
        password: password,
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created. You can log in now.')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final years = ['1', '2', '3', '4'];
    final branches = ['CSE', 'ECE', 'EEE', 'ME', 'CE', 'ISE', 'Other'];

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (v) => name = v!.trim(),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDob),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Pick DOB' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'USN'),
                onSaved: (v) => usn = v!.trim(),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter USN' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => email = v!.trim(),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter email' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Branch'),
                items: branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => branch = v ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Select branch' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Year of Study'),
                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                onChanged: (v) => year = v ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Select year' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (v) => password = v!.trim(),
                validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Create Account')),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------ HOME ------------------
class HomeScreen extends StatefulWidget {
  final List<Order> placedOrders;
  final List<ProductFeedback> productFeedback;
  final List<Item> items;
  final UserProfile userProfile;
  final VoidCallback onLogout;
  final Function(Order) onAddOrder;
  final Function(Item) onAddItem;
  final Function(UserProfile) onUpdateProfile;
  final Function(ProductFeedback) onAddFeedback;
  const HomeScreen({
    super.key,
    required this.placedOrders,
    required this.userProfile,
    required this.onLogout,
    required this.onAddOrder,
    required this.onUpdateProfile,
    required this.productFeedback,
    required this.onAddFeedback,
    required this.items,
    required this.onAddItem,
  });
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final List<Item> cartItems = [];

  void _addToCart(Item item) {
    setState(() => cartItems.add(item));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.title} added to cart')));
  }

  void _openAddItemScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddItemScreen(onAddItem: widget.onAddItem)));
  }

  Future<void> _navigateTo(String destination) async {
    Navigator.pop(context); // Close drawer
    if (destination == 'Profile') {
      final updatedProfile = await Navigator.push<UserProfile?>(
        context, MaterialPageRoute(builder: (_) => ProfileScreen(userProfile: widget.userProfile)),
      );
      if (updatedProfile != null) widget.onUpdateProfile(updatedProfile);
    } else if (destination == 'Cart') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CartScreen(
            cartItems: cartItems,
            onCreateOrder: widget.onAddOrder,
          ),
        ),
      );
      setState(() {}); // Refresh in case cart changed
    } else if (destination == 'Orders') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderScreen(
            placedOrders: widget.placedOrders,
            onAddFeedback: widget.onAddFeedback,
          ),
        ),
      );
    } else if (destination == 'Feedback') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FeedbackScreen(
            productFeedback: widget.productFeedback,
            placedOrders: widget.placedOrders,
            onAddFeedback: widget.onAddFeedback,
          ),
        ),
      );
    }
  }

  void _openProductDetail(Item item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          item: item,
          onAddToCart: _addToCart,
          onBuyNow: _openBuyNow,
        ),
      ),
    );
  }

  void _openBuyNow(List<Item> items) async {
    // Create order in summary screen, then go to payment
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BuyNowScreen(
          itemsToBuy: items,
          onOrderCreated: (order) {
            widget.onAddOrder(order);
          },
        ),
      ),
    );
  }

  Widget _buildItemImage(Item item, {double size = 50}) {
    if (item.imageBytes != null && item.imageBytes!.isNotEmpty) {
      return Image.memory(item.imageBytes!.first!, width: size, height: size, fit: BoxFit.cover);
    } else if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      return Image.network(item.imagePath!, width: size, height: size, fit: BoxFit.cover);
    } else {
      return Image.network('https://via.placeholder.com/50', width: size, height: size);
    }
  }

  double _getAverageRating(String productTitle) {
    final relevant = widget.productFeedback.where((f) => f.productTitle == productTitle).toList();
    if (relevant.isEmpty) return 0.0;
    final total = relevant.fold<int>(0, (sum, f) => sum + f.rating);
    return total / relevant.length;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusSwap'),
        backgroundColor: const Color.fromARGB(255, 94, 164, 185),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.pinkAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.userProfile.profileImageBytes != null
                        ? MemoryImage(widget.userProfile.profileImageBytes!)
                        : null,
                    child: widget.userProfile.profileImageBytes == null ? const Icon(Icons.person, size: 30) : null,
                  ),
                  const SizedBox(height: 10),
                  Text(widget.userProfile.name, style: const TextStyle(color: Colors.white, fontSize: 20)),
                  Text(widget.userProfile.contact, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.person), title: const Text('Profile'), onTap: () => _navigateTo('Profile')),
            ListTile(leading: const Icon(Icons.shopping_cart), title: const Text('Cart'), onTap: () => _navigateTo('Cart')),
            ListTile(leading: const Icon(Icons.receipt), title: const Text('Orders'), onTap: () => _navigateTo('Orders')),
            ListTile(leading: const Icon(Icons.rate_review), title: const Text('Feedback'), onTap: () => _navigateTo('Feedback')),
            ListTile(
  leading: const Icon(Icons.sell),
  title: const Text('My Sold Items'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SellerOrdersScreen(
        placedOrders: widget.placedOrders,
        sellerEmail: widget.userProfile.contact,
      ),
    ),
  ),
),

            const Divider(),
            ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Logout'),
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Do you really want to log out?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // close dialog
                widget.onLogout();                  // triggers root rebuild to LoginScreen
              },
            ),
          ],
        );
      },
    );
  },
),

        ],),
      ),
      body: widget.items.isEmpty
          ? const Center(child: Text('No items listed yet. Tap + to add.'))
          : ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (ctx, i) {
                final item = widget.items[i];
                final avg = _getAverageRating(item.title);
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => _openProductDetail(item),
                        leading: _buildItemImage(item),
                        title: Text('${item.title} (${item.category})'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.description),
                            Text('₹${item.price.toStringAsFixed(0)} - Contact: ${item.contact}'),
                            const SizedBox(height: 4),
                            if (avg > 0)
                              Row(children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text('${avg.toStringAsFixed(1)} stars', style: const TextStyle(fontSize: 12)),
                              ])
                            else
                              const Text('No ratings yet', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _addToCart(item),
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to Cart'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _openBuyNow([item]),
                            icon: const Icon(Icons.bolt),
                            label: const Text('Buy Now'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: Tooltip(message:'Add new item',child:FloatingActionButton(onPressed: _openAddItemScreen, child: const Icon(Icons.add)),)
    );
  }
}

// ------------------ ADD ITEM ------------------
class AddItemScreen extends StatefulWidget {
  final Function(Item) onAddItem;
  const AddItemScreen({super.key, required this.onAddItem});
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}
class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String category = '';
  String title = '';
  String description = '';
  double price = 0;
  String contact = '';
  String upiid = '';
  List<Uint8List?>? imageBytes = [];

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => imageBytes = result.files.map((f) => f.bytes).toList());
    }
  }

  void _submitItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newItem = Item(
        category: category,
        title: title,
        description: description,
        price: price,
        contact: contact,
        upiid: upiid,
        imageBytes: imageBytes,
      );
      widget.onAddItem(newItem);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      backgroundColor: const Color.fromARGB(255, 209, 155, 235),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Category'), onSaved: (v) => category = v!, validator: (v) => v!.isEmpty ? 'Enter category' : null),
            TextFormField(decoration: const InputDecoration(labelText: 'Title'), onSaved: (v) => title = v!, validator: (v) => v!.isEmpty ? 'Enter title' : null),
            TextFormField(decoration: const InputDecoration(labelText: 'Description'), onSaved: (v) => description = v!, validator: (v) => v!.isEmpty ? 'Enter description' : null),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onSaved: (v) => price = double.tryParse(v!) ?? 0,
              validator: (v) => v!.isEmpty ? 'Enter price' : null,
            ),
            TextFormField(decoration: const InputDecoration(labelText: 'Contact'), onSaved: (v) => contact = v!, validator: (v) => v!.isEmpty ? 'Enter contact' : null),
            TextFormField(decoration: const InputDecoration(labelText: 'UPI ID'), onSaved: (v) => upiid = v!, validator: (v) => v!.isEmpty ? 'Enter UPI ID' : null),
            const SizedBox(height: 10),
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text('Pick Images')),
            const SizedBox(height: 10),
            if (imageBytes != null && imageBytes!.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageBytes!.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.memory(imageBytes![index]!, height: 150, width: 150, fit: BoxFit.cover),
                  ),
                ),
              )
            else
              const Text('No images selected'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submitItem, child: const Text('Submit Item')),
          ]),
        ),
      ),
    );
  }
}

// ------------------ CART ------------------
class CartScreen extends StatefulWidget {
  final List<Item> cartItems;
  final Function(Order) onCreateOrder;
  const CartScreen({super.key, required this.cartItems, required this.onCreateOrder});
  @override
  _CartScreenState createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  final Set<int> _selected = {};
  double get selectedTotal => _selected.map((i) => widget.cartItems[i].price).fold(0.0, (sum, p) => sum + p);

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selected.addAll(List.generate(widget.cartItems.length, (i) => i));
      } else {
        _selected.clear();
      }
    });
  }

  Future<void> _buySelected() async {
    if (_selected.isEmpty) return;
    final itemsToBuy = _selected.map((i) => widget.cartItems[i]).toList();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BuyNowScreen(
          itemsToBuy: itemsToBuy,
          onOrderCreated: (order) => widget.onCreateOrder(order),
        ),
      ),
    );
    if (result == true) {
      setState(() {
        final toRemove = _selected.toList()..sort((a, b) => b.compareTo(a));
        for (final idx in toRemove) {
          widget.cartItems.removeAt(idx);
        }
        _selected.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchased selected items')));
      Navigator.pop(context);
    }
  }

  Widget _buildItemDetails(Item item, int index) {
    Widget image;
    if (item.imageBytes != null && item.imageBytes!.isNotEmpty) {
      image = Image.memory(item.imageBytes!.first!, width: 80, height: 80, fit: BoxFit.cover);
    } else if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      image = Image.network(item.imagePath!, width: 80, height: 80, fit: BoxFit.cover);
    } else {
      image = Image.network('https://via.placeholder.com/80', width: 80, height: 80);
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            image,
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Category: ${item.category}'),
                Text('Price: ₹${item.price.toStringAsFixed(0)}'),
                Text('Seller: ${item.contact}'),
              ]),
            ),
            Checkbox(
              value: _selected.contains(index),
              onChanged: (val) => setState(() {
                if (val == true) {
                  _selected.add(index);
                } else {
                  _selected.remove(index);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAllSelected = _selected.length == widget.cartItems.length && widget.cartItems.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: widget.cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  Checkbox(value: isAllSelected, onChanged: _toggleSelectAll),
                  const Text('Select All'),
                  const Spacer(),
                  if (_selected.isNotEmpty) Text('Selected: ${_selected.length} • ₹${selectedTotal.toStringAsFixed(0)}'),
                ]),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (ctx, i) => _buildItemDetails(widget.cartItems[i], i),
                  ),
                ),
              ]),
            ),
      bottomNavigationBar: (_selected.isNotEmpty)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  onPressed: _buySelected,
                  icon: const Icon(Icons.bolt),
                  label: Text('Buy Now (${_selected.length}) • ₹${selectedTotal.toStringAsFixed(0)}'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            )
          : null,
    );
  }
}

// ------------------ PROFILE ------------------
class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  const ProfileScreen({super.key, required this.userProfile});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _contact;
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _name = widget.userProfile.name;
    _contact = widget.userProfile.contact;
    _profileImageBytes = widget.userProfile.profileImageBytes;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _profileImageBytes = result.files.first.bytes);
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updated = UserProfile(name: _name, contact: _contact, profileImageBytes: _profileImageBytes);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!')));
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = _profileImageBytes ?? widget.userProfile.profileImageBytes;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: avatarImage != null ? MemoryImage(avatarImage) : null,
                  child: avatarImage == null ? const Icon(Icons.camera_alt, size: 50, color: Colors.white70) : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(initialValue: _name, decoration: const InputDecoration(labelText: 'Name'),
                    onSaved: (v) => _name = v!, validator: (v) => v!.isEmpty ? 'Please enter a name' : null),
                TextFormField(initialValue: _contact, decoration: const InputDecoration(labelText: 'Contact'),
                    onSaved: (v) => _contact = v!, validator: (v) => v!.isEmpty ? 'Please enter contact details' : null),
              ]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProfile, child: const Text('Save Profile')),
          ]),
        ),
      ),
    );
  }
}

// ------------------ PRODUCT DETAIL ------------------
class ProductDetailScreen extends StatelessWidget {
  final Item item;
  final void Function(Item) onAddToCart;
  final void Function(List<Item>) onBuyNow;
  const ProductDetailScreen({
    super.key,
    required this.item,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  Widget _buildImage(Item item) {
    if (item.imageBytes != null && item.imageBytes!.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: item.imageBytes!.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.memory(item.imageBytes![index]!, height: 200, width: 200, fit: BoxFit.cover),
          ),
        ),
      );
    } else if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      return Image.network(item.imagePath!, height: 200, fit: BoxFit.cover);
    } else {
      return Image.network('https://via.placeholder.com/300x200', height: 200, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildImage(item),
          const SizedBox(height: 16),
          Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Category: ${item.category}'),
          const SizedBox(height: 8),
          Text(item.description),
          const SizedBox(height: 12),
          Text('Price: ₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Seller: ${item.contact}'),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  onAddToCart(item);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.title} added to cart')));
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onBuyNow([item]),
                child: const Text('Buy Now'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ------------------ BUY NOW (ORDER SUMMARY) ------------------
enum PaymentMethod { upi, cash }

class BuyNowScreen extends StatefulWidget {
  final List<Item> itemsToBuy;
  final void Function(Order) onOrderCreated;
  const BuyNowScreen({super.key, required this.itemsToBuy, required this.onOrderCreated});

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  final _formKey = GlobalKey<FormState>();
  String contact = '';
  String deliveryPlace = '';
  PaymentMethod? _method;

  double get total => widget.itemsToBuy.fold(0, (sum, item) => sum + item.price);

  Future<void> _confirmPurchase() async {
    if (_formKey.currentState!.validate()) {
      if (_method == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a payment method')));
        return;
      }
      _formKey.currentState!.save();
      final sellerContacts = widget.itemsToBuy.map((item) => item.contact).toSet().toList();

      final order = Order(
        items: List.from(widget.itemsToBuy),
        total: total,
        buyerContact: contact,
        deliveryPlace: deliveryPlace,
        orderDate: DateTime.now(),
        isDelivered: false,
  sellerContacts: sellerContacts,
      );

      widget.onOrderCreated(order);

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Order Placed'),
          content: Text('Your order has been placed.\nPayment: ${_method == PaymentMethod.upi ? 'UPI' : 'Cash'}\nTotal: ₹${total.toStringAsFixed(0)}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );

      Navigator.pop(context, true); // signal success to caller (Cart can remove purchased items)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Now')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.itemsToBuy.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.title),
                  subtitle: Text('₹${item.price.toStringAsFixed(0)}'),
                )),
            const Divider(),
            Text('Total: ₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            RadioListTile<PaymentMethod>(
              value: PaymentMethod.upi,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v),
              title: const Text('UPI'),
              subtitle: Text('Pay to seller’s UPI when you meet (UPI ID is provided by seller).'),
            ),
            RadioListTile<PaymentMethod>(
              value: PaymentMethod.cash,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v),
              title: const Text('Cash'),
              subtitle: const Text('Pay in cash on delivery/pickup.'),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Your Contact'),
                    onSaved: (val) => contact = val!.trim(),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter contact info' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Preferred Place of Delivery'),
                    onSaved: (val) => deliveryPlace = val!.trim(),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter delivery place' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _confirmPurchase,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Purchase'),
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



// ------------------ ORDERS ------------------
class OrderScreen extends StatelessWidget {
  final List<Order> placedOrders;
  final Function(ProductFeedback) onAddFeedback;
  const OrderScreen({super.key, required this.placedOrders, required this.onAddFeedback});

  void _showFeedbackDialog(BuildContext context, Item item, Order order) {
  final TextEditingController _controller = TextEditingController();
  int _rating = 0;

  showDialog(
  context: context,
  builder: (ctx) {
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Feedback for ${item.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ⭐️ Star Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Icon(
                    Icons.star,
                    color: index < _rating ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Enter your feedback'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final feedback = _controller.text.trim();
              if (_rating > 0 && feedback.isNotEmpty) {
                // Save feedback and rating here

                Navigator.of(ctx).pop(); // Close dialog first

                // Show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thanks! You rated ${item.title} $_rating⭐')),
                );

                // Redirect to home after short delay
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pushReplacementNamed(context, '/home');
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a rating and feedback')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  },
);

}



  Widget _thumb(Item item) {
    if (item.imageBytes != null && item.imageBytes!.isNotEmpty) {
      return Image.memory(item.imageBytes!.first!, width: 50, height: 50, fit: BoxFit.cover);
    } else if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      return Image.network(item.imagePath!, width: 50, height: 50, fit: BoxFit.cover);
    }
    return Image.network('https://via.placeholder.com/50', width: 50, height: 50);
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Order Placed: ${order.orderDate.toString().substring(0, 10)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Buyer Contact: ${order.buyerContact}'),
          Text('Delivery Place: ${order.deliveryPlace}'),
          const SizedBox(height: 10),
          const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
          for (var item in order.items)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _thumb(item),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${item.title} - ₹${item.price.toStringAsFixed(0)}'),

                    Text('Category: ${item.category}'),
                    
                  ]),
                ),
              ],
            ),
          const Divider(),
          Text('Total: ₹${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
if (!order.isDelivered)
  ElevatedButton.icon(
    icon: const Icon(Icons.local_shipping),
    label: const Text('Confirm Delivery'),
    onPressed: () {
      order.isDelivered = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery confirmed!')),
      );
      for (var item in order.items) {
        _showFeedbackDialog(context, item, order);
      }
    },
  )
else
  const Text('Delivery Status: Delivered', style: TextStyle(color: Colors.green)),

        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: placedOrders.isEmpty
          ? const Center(
              child: Text('No orders yet.\nStart buying items!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(itemCount: placedOrders.length, itemBuilder: (ctx, i) => _buildOrderCard(ctx, placedOrders[i])),
    );
  }
}

// ------------------ FEEDBACK ------------------
class FeedbackScreen extends StatefulWidget {
  final List<ProductFeedback> productFeedback;
  final List<Order> placedOrders;
  final Function(ProductFeedback) onAddFeedback;
  const FeedbackScreen({
    super.key,
    required this.productFeedback,
    required this.placedOrders,
    required this.onAddFeedback,
  });
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}
class _FeedbackScreenState extends State<FeedbackScreen> {
  Widget _buildStars(int rating) => Row(
        children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
      );

  void _showAddFeedbackDialog() {
    final purchasedItems = widget.placedOrders.expand((o) => o.items).toList();
    final unique = <String, Item>{for (var it in purchasedItems) it.title: it};

    showDialog(
      context: context,
      builder: (dialogContext) {
        String? selectedTitle;
        int rating = 0;
        String comment = '';
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Add New Feedback'),
          content: StatefulBuilder(
            builder: (context, setState) => Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Product'),
                  value: selectedTitle,
                  items: unique.values.map((it) => DropdownMenuItem(value: it.title, child: Text(it.title))).toList(),
                  onChanged: (v) => setState(() => selectedTitle = v),
                  validator: (v) => v == null ? 'Please select a product' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                      onPressed: () => setState(() => rating = index + 1),
                    );
                  }),
                ),
                TextFormField(decoration: const InputDecoration(labelText: 'Your Comment'), maxLines: 3, onSaved: (v) => comment = v ?? ''),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && rating > 0) {
                  formKey.currentState!.save();
                  widget.onAddFeedback(ProductFeedback(
                    productTitle: selectedTitle!,
                    rating: rating,
                    comment: comment,
                    customerContact: 'syed@example.com',
                  ));
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted!')));
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Feedback'), backgroundColor: const Color.fromARGB(255, 94, 164, 185)),
      body: widget.productFeedback.isEmpty
          ? const Center(
              child: Text(
                'No feedback has been submitted yet.\nTap + to add some for your purchased items!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: widget.productFeedback.length,
              itemBuilder: (ctx, i) {
                final f = widget.productFeedback[i];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.productTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      _buildStars(f.rating),
                      const SizedBox(height: 8),
                      Text(f.comment),
                      const SizedBox(height: 4),
                      Text('- from ${f.customerContact}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                    ]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddFeedbackDialog, child: const Icon(Icons.add)),
    );
  }
}

//----------------------------------------Sellersscreen----------------------------------------
class SellerOrdersScreen extends StatelessWidget {
  final List<Order> placedOrders;
  final String sellerEmail;

  const SellerOrdersScreen({
    super.key,
    required this.placedOrders,
    required this.sellerEmail,
  });

  @override
  Widget build(BuildContext context) {
    final sellerOrders = placedOrders.where((order) =>
      order.sellerContacts.contains(sellerEmail)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Sold Items')),
      body: sellerOrders.isEmpty
          ? const Center(child: Text('No items sold yet'))
          : ListView.builder(
              itemCount: sellerOrders.length,
              itemBuilder: (ctx, i) {
                final order = sellerOrders[i];
                final soldItems = order.items.where((item) => item.contact == sellerEmail).toList();

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Buyer: ${order.buyerContact}'),
                      Text('Delivery Place: ${order.deliveryPlace}'),
                      Text('Delivery Status: ${order.isDelivered ? "Delivered" : "Pending"}'),
                      const SizedBox(height: 10),
                      const Text('Items Sold:', style: TextStyle(fontWeight: FontWeight.bold)),
                      for (var item in soldItems)
                        Text('${item.title} - ₹${item.price.toStringAsFixed(0)}'),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
