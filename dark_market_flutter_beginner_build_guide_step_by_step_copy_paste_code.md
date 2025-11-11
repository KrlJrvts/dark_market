# Dark Market — Beginner Build Guide

This guide walks you through creating a **minimal, beginner‑friendly Flutter auction app** with Firebase: email/password auth, listing items, bidding, image upload, and offline support. It’s written so you can **copy/paste** files into your project and get it running fast.

> Tip: Skim the whole guide first, then go step by step. Each step builds on the previous.

---

## 0) What we’re building
- Mobile‑first Flutter app with a neon/dark theme.
- Users can **register/login**, **create auctions** (with photo), **see a list**, open an **auction detail** and **place a bid** or **buy out** instantly.
- Uses **Firebase Authentication**, **Cloud Firestore**, and **Firebase Storage**.
- **Offline:** Firestore persistence is enabled so previously loaded auctions remain visible and new ones sync when you reconnect.

---

## 1) Prerequisites
- Flutter SDK installed; Android Studio or VS Code with Flutter/Dart plugins.
- An Android emulator/iOS Simulator or a physical device.
- A Google Firebase project you can access.

---

## 2) Create project & connect Firebase
1. **Create Flutter app** (skip if you already have one):
   ```bash
   flutter create dark_market
   cd dark_market
   ```
2. **Add packages** (lets Pub pick compatible versions):
   ```bash
   flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage \
     image_picker provider go_router cached_network_image intl uuid
   ```
3. **Install FlutterFire CLI** (one time on your machine):
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. **Configure Firebase for your app** (select platforms you’ll run on):
   ```bash
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`.

---

## 3) Platform permissions (copy where needed)
### Android
- In `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.CAMERA"/>
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
  ```
  And inside `<application ...>` add (if missing) for file picker camera intents on newer devices:
  ```xml
  <queries>
    <intent>
      <action android:name="android.media.action.IMAGE_CAPTURE"/>
    </intent>
  </queries>
  ```

### iOS
- In `ios/Runner/Info.plist` add keys:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>We use the camera to take item photos.</string>
  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>We need photo library access to save item images.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>We access your library to pick an image for the item.</string>
  ```

### Web (optional)
- Offline persistence on web needs enabling in code (done in `main.dart` below).
- Ensure your Firebase Hosting or local web origin is allowed in Firebase auth sign‑in.

---

## 4) Firestore & Storage security rules (development‑friendly)
> These rules are **for class/demo only**. Lock them down further for production.

**Firestore rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }

    match /users/{uid} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == uid;
    }

    match /auctions/{auctionId} {
      allow read: if true; // public
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && request.resource.data.sellerId == request.auth.uid;

      match /bids/{bidId} {
        allow read: if true;
        allow create: if isSignedIn();
      }
    }
  }
}
```

**Storage rules**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function isSignedIn() { return request.auth != null; }
    match /auction_images/{file} {
      allow read: if true;
      allow write: if isSignedIn();
    }
  }
}
```

---

## 5) Project structure (simple and clear)
```
lib/
  models/
    auction_item.dart
    bid.dart
    user_profile.dart
  services/
    auth_service.dart
    firestore_service.dart
    storage_service.dart
  providers/
    auth_provider.dart
    auction_provider.dart
  screens/
    login_screen.dart
    register_screen.dart
    auction_list_screen.dart
    auction_detail_screen.dart
    auction_edit_screen.dart  // create/edit auction
    profile_screen.dart
  widgets/
    auction_card.dart
    loading.dart
    error_retry.dart
  theme.dart
  router.dart
  main.dart
```

> You can keep your existing folders — just replace or merge files from this guide.

---

## 6) Copy‑paste code (minimal working app)
Paste these files into your `lib/` folder. Read comments as you go.

### `lib/models/auction_item.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String sellerId;
  final double startPrice;
  final double? buyoutPrice;
  final double highestBid;
  final String? highestBidderId;
  final DateTime createdAt;
  final DateTime endsAt;

  AuctionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.sellerId,
    required this.startPrice,
    this.buyoutPrice,
    required this.highestBid,
    this.highestBidderId,
    required this.createdAt,
    required this.endsAt,
  });

  factory AuctionItem.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AuctionItem(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      sellerId: d['sellerId'] ?? '',
      startPrice: (d['startPrice'] ?? 0).toDouble(),
      buyoutPrice: d['buyoutPrice'] == null ? null : (d['buyoutPrice']).toDouble(),
      highestBid: (d['highestBid'] ?? 0).toDouble(),
      highestBidderId: d['highestBidderId'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      endsAt: (d['endsAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'sellerId': sellerId,
        'startPrice': startPrice,
        'buyoutPrice': buyoutPrice,
        'highestBid': highestBid,
        'highestBidderId': highestBidderId,
        'createdAt': Timestamp.fromDate(createdAt),
        'endsAt': Timestamp.fromDate(endsAt),
      };
}
```

### `lib/models/bid.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BidModel {
  final String id;
  final String auctionId;
  final String bidderId;
  final double amount;
  final DateTime createdAt;

  BidModel({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.amount,
    required this.createdAt,
  });

  factory BidModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BidModel(
      id: doc.id,
      auctionId: d['auctionId'],
      bidderId: d['bidderId'],
      amount: (d['amount']).toDouble(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'auctionId': auctionId,
        'bidderId': bidderId,
        'amount': amount,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
```

### `lib/models/user_profile.dart`
```dart
class UserProfile {
  final String uid;
  final String displayName;
  final String? photoUrl;

  UserProfile({required this.uid, required this.displayName, this.photoUrl});

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'photoUrl': photoUrl,
      };

  factory UserProfile.fromMap(String uid, Map<String, dynamic> d) =>
      UserProfile(uid: uid, displayName: d['displayName'] ?? '', photoUrl: d['photoUrl']);
}
```

### `lib/services/auth_service.dart`
```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
```

### `lib/services/storage_service.dart`
```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadAuctionImage(File file) async {
    final id = _uuid.v4();
    final ref = _storage.ref().child('auction_images/$id.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
```

### `lib/services/firestore_service.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_item.dart';
import '../models/bid.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _auctions => _db.collection('auctions');

  // Streams
  Stream<List<AuctionItem>> watchAuctions() => _auctions
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(AuctionItem.fromDoc).toList());

  Future<AuctionItem> getAuction(String id) async {
    final doc = await _auctions.doc(id).get();
    return AuctionItem.fromDoc(doc);
  }

  // Create / update auction
  Future<String> createAuction(AuctionItem item) async {
    final doc = await _auctions.add(item.toMap());
    return doc.id;
  }

  Future<void> updateAuction(String id, Map<String, dynamic> data) =>
      _auctions.doc(id).update(data);

  // Place a bid using a transaction to ensure atomic update
  Future<void> placeBid({
    required String auctionId,
    required String bidderId,
    required double amount,
  }) async {
    final auctionRef = _auctions.doc(auctionId);
    final bidsRef = auctionRef.collection('bids');

    await _db.runTransaction((tx) async {
      final snap = await tx.get(auctionRef);
      final item = AuctionItem.fromDoc(snap);
      if (DateTime.now().isAfter(item.endsAt)) {
        throw Exception('Auction ended.');
      }
      if (amount <= item.highestBid) {
        throw Exception('Bid must be higher than current.');
      }
      tx.update(auctionRef, {
        'highestBid': amount,
        'highestBidderId': bidderId,
      });
      final bidRef = bidsRef.doc();
      tx.set(bidRef, BidModel(
        id: bidRef.id,
        auctionId: auctionId,
        bidderId: bidderId,
        amount: amount,
        createdAt: DateTime.now(),
      ).toMap());
    });
  }
}
```

### `lib/providers/auth_provider.dart`
```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;
  User? user;

  AuthProvider(this._auth) {
    _auth.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;

  Future<void> signIn(String email, String password) async {
    await _auth.signIn(email, password);
  }

  Future<void> register(String email, String password) async {
    await _auth.register(email, password);
  }

  Future<void> signOut() => _auth.signOut();
}
```

### `lib/providers/auction_provider.dart`
```dart
import 'package:flutter/foundation.dart';
import '../models/auction_item.dart';
import '../services/firestore_service.dart';

class AuctionProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  List<AuctionItem> auctions = [];

  AuctionProvider(this._firestore) {
    _firestore.watchAuctions().listen((items) {
      auctions = items;
      notifyListeners();
    });
  }
}
```

### `lib/widgets/loading.dart`
```dart
import 'package:flutter/material.dart';
class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
```

### `lib/widgets/error_retry.dart`
```dart
import 'package:flutter/material.dart';
class ErrorRetry extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const ErrorRetry({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(message), const SizedBox(height: 8),
      ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
    ]),
  );
}
```

### `lib/widgets/auction_card.dart`
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/auction_item.dart';

class AuctionCard extends StatelessWidget {
  final AuctionItem item; final VoidCallback onTap;
  const AuctionCard({super.key, required this.item, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.25),
    child: InkWell(onTap: onTap, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(
          height: 72, width: 72,
          child: CachedNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover,
            placeholder: (c,_)=>const Center(child:CircularProgressIndicator()),),
        )),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Current: ${item.highestBid.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium),
        ])),
      ]),
    )),
  );
}
```

### `lib/screens/login_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(()=>_busy=true);
    try {
      await context.read<AuthProvider>().signIn(_email.text, _password.text);
    } catch(e){
      if(mounted){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));}    
    } finally { if(mounted) setState(()=>_busy=false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign in')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(key: _form, child: Column(children: [
        TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'),
          validator: (v)=> v!=null && v.contains('@')? null : 'Enter a valid email'),
        TextFormField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true,
          validator: (v)=> (v??'').length>=6? null : 'Min 6 chars'),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _busy? null : _submit, child: const Text('Sign in')),
        TextButton(onPressed: ()=>Navigator.of(context).pushReplacementNamed('/register'), child: const Text('Create account')),
      ])),
    ),
  );
}
```

### `lib/screens/register_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(()=>_busy=true);
    try {
      await context.read<AuthProvider>().register(_email.text, _password.text);
    } catch(e){
      if(mounted){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));}    
    } finally { if(mounted) setState(()=>_busy=false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(key: _form, child: Column(children: [
        TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'),
          validator: (v)=> v!=null && v.contains('@')? null : 'Enter a valid email'),
        TextFormField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true,
          validator: (v)=> (v??'').length>=6? null : 'Min 6 chars'),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _busy? null : _submit, child: const Text('Register')),
        TextButton(onPressed: ()=>Navigator.of(context).pushReplacementNamed('/login'), child: const Text('Back to sign in')),
      ])),
    ),
  );
}
```

### `lib/screens/auction_list_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auction_provider.dart';
import '../widgets/auction_card.dart';

class AuctionListScreen extends StatelessWidget {
  const AuctionListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AuctionProvider>();
    final items = prov.auctions;
    return Scaffold(
      appBar: AppBar(title: const Text('Dark Market')),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> Navigator.of(context).pushNamed('/edit'),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => AuctionCard(
          item: items[i],
          onTap: ()=> Navigator.of(context).pushNamed('/detail', arguments: items[i].id),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: items.length,
      ),
    );
  }
}
```

### `lib/screens/auction_detail_screen.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auction_item.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class AuctionDetailScreen extends StatefulWidget {
  final String auctionId;
  const AuctionDetailScreen({super.key, required this.auctionId});
  @override State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final _bidCtrl = TextEditingController();
  AuctionItem? item;
  bool _busy = true; String? _error;

  @override void initState(){ super.initState(); _load(); }

  Future<void> _load() async {
    setState(()=>{_busy=true,_error=null});
    try { item = await FirestoreService().getAuction(widget.auctionId); }
    catch(e){ _error = e.toString(); }
    finally { if(mounted) setState(()=>_busy=false); }
  }

  Future<void> _placeBid() async {
    final user = context.read<AuthProvider>().user!;
    final amount = double.tryParse(_bidCtrl.text);
    if (amount == null) return;
    try {
      await FirestoreService().placeBid(
        auctionId: widget.auctionId,
        bidderId: user.uid,
        amount: amount,
      );
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid placed')));
        await _load();
      }
    } catch(e){
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error!=null) return Scaffold(body: Center(child: Text(_error!)));
    final it = item!;
    final remaining = it.endsAt.difference(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(it.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(aspectRatio: 16/9, child: Image.network(it.imageUrl, fit: BoxFit.cover)),
          const SizedBox(height: 12),
          Text(it.description),
          const SizedBox(height: 12),
          Text('Current: ${it.highestBid.toStringAsFixed(2)}'),
          Text('Ends in: ${remaining.inMinutes} min'),
          const Divider(),
          Row(children: [
            Expanded(child: TextField(controller: _bidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Your bid'))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _placeBid, child: const Text('Bid')),
          ]),
          if (it.buyoutPrice != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('auctions').doc(it.id).update({
                    'highestBid': it.buyoutPrice,
                    'highestBidderId': context.read<AuthProvider>().user!.uid,
                    'endsAt': Timestamp.fromDate(DateTime.now()),
                  });
                  if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bought out!')));
                } catch(e){
                  if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: Text('Buy now for ${it.buyoutPrice!.toStringAsFixed(2)}'),
            ),
          ],
        ]),
      ),
    );
  }
}
```

### `lib/screens/auction_edit_screen.dart`
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/auction_item.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AuctionEditScreen extends StatefulWidget {
  const AuctionEditScreen({super.key});
  @override State<AuctionEditScreen> createState() => _AuctionEditScreenState();
}

class _AuctionEditScreenState extends State<AuctionEditScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _start = TextEditingController(text: '10');
  final _buyout = TextEditingController();
  DateTime _endsAt = DateTime.now().add(const Duration(hours: 1));
  File? _image;

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.camera);
    if (x != null) setState(()=> _image = File(x.path));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _image == null) return;
    final user = context.read<AuthProvider>().user!;
    final imageUrl = await StorageService().uploadAuctionImage(_image!);
    final item = AuctionItem(
      id: 'new',
      title: _title.text,
      description: _desc.text,
      imageUrl: imageUrl,
      sellerId: user.uid,
      startPrice: double.parse(_start.text),
      buyoutPrice: _buyout.text.isEmpty? null : double.parse(_buyout.text),
      highestBid: double.parse(_start.text),
      highestBidderId: null,
      createdAt: DateTime.now(),
      endsAt: _endsAt,
    );
    await FirestoreService().createAuction(item);
    if(mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New auction')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(
      key: _form,
      child: Column(children: [
        TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v)=> (v??'').isEmpty? 'Required' : null),
        TextFormField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
        TextFormField(controller: _start, decoration: const InputDecoration(labelText: 'Start price'), keyboardType: TextInputType.number),
        TextFormField(controller: _buyout, decoration: const InputDecoration(labelText: 'Buyout price (optional)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Text('Ends: ${_endsAt.toLocal()}')),
          TextButton(onPressed: () async {
            final r = await showDatePicker(context: context, initialDate: _endsAt, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (r != null) setState(()=> _endsAt = DateTime(r.year, r.month, r.day, _endsAt.hour, _endsAt.minute));
          }, child: const Text('Pick date')),
        ]),
        const SizedBox(height: 12),
        _image == null
          ? OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.camera_alt), label: const Text('Take photo'))
          : Column(children: [ Image.file(_image!, height: 160, fit: BoxFit.cover), TextButton(onPressed: ()=>setState(()=>_image=null), child: const Text('Remove')) ]),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ]),
    )),
  );
}
```

### `lib/screens/profile_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('UID: ${u.uid}'),
          Text('Email: ${u.email ?? '—'}'),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: ()=>auth.signOut(), child: const Text('Sign out')),
        ]),
      ),
    );
  }
}
```

### `lib/theme.dart` (neon/dark, accessible)
```dart
import 'package:flutter/material.dart';

ThemeData darkNeonTheme() {
  const primary = Color(0xFF00E5FF); // cyan neon
  const surface = Color(0xFF0B0F14); // deep dark
  final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(surface: surface, background: surface),
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(centerTitle: true),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}
```

### `lib/router.dart` (Navigator 2.0 via `go_router` OR simple `Navigator.push`)
> To stay beginner‑friendly but still use Navigator 2.0, we’ll use **go_router**. If you prefer the classic API, you can use `routes` in `MaterialApp`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auction_detail_screen.dart';
import 'screens/auction_edit_screen.dart';
import 'screens/auction_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';

GoRouter buildRouter(BuildContext context) {
  bool loggedIn() => context.read<AuthProvider>().isLoggedIn;
  return GoRouter(
    initialLocation: '/list',
    refreshListenable: context.read<AuthProvider>(),
    redirect: (ctx, state) {
      final goingAuth = state.subloc == '/login' || state.subloc == '/register';
      if (!loggedIn() && !goingAuth) return '/login';
      if (loggedIn() && goingAuth) return '/list';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/list', builder: (_, __) => const AuctionListScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/edit', builder: (_, __) => const AuctionEditScreen()),
      GoRoute(path: '/detail', builder: (_, state) {
        final id = state.extra as String? ?? (state.queryParams['id'] ?? '');
        return AuctionDetailScreen(auctionId: id);
      }),
    ],
  );
}
```

### `lib/main.dart`
```dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/auction_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'theme.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline persistence (web must opt‑in)
  if (kIsWeb) {
    await FirebaseFirestore.instance.enablePersistence(const PersistenceSettings(synchronizeTabs: true));
  } else {
    // Android/iOS enabled by default; nothing needed.
  }

  runApp(const DarkMarketApp());
}

class DarkMarketApp extends StatelessWidget {
  const DarkMarketApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => AuctionProvider(FirestoreService())),
      ],
      child: Builder(builder: (context) {
        final router = buildRouter(context);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Dark Market',
          theme: darkNeonTheme(),
          routerConfig: router,
        );
      }),
    );
  }
}
```

---

## 7) Run it
```bash
flutter pub get
flutter run -d <your_device_id>
```
- First run may ask you to **configure Firebase**; confirm your platforms.
- Create an account (Register), sign in.
- Tap **+** to create an auction, take a photo, set start price, optional buyout.
- Back on the list, tap an item to open details, enter a bid, and submit.

---

## 8) How offline works (quick check)
- Turn on airplane mode after opening the list once; items should remain visible.
- Create a new auction while offline. When you reconnect, it will sync and appear on other devices.

---

## 9) Stretch ideas (optional)
- Push notifications (Firebase Cloud Messaging) when you’re outbid.
- Google Sign‑In / Apple Sign‑In.
- Seller dashboard with “my auctions only”.
- Countdown timer widget that ticks every second (use `Stream.periodic`).

---

## 10) Troubleshooting
- **Auth errors**: make sure the email/password provider is enabled i