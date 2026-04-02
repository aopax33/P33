import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  // ── Collection references ──────────────────────────────────────────────────

  CollectionReference get usersRef => _firestore.collection('users');
  CollectionReference get productsRef => _firestore.collection('products');
  CollectionReference get ratingsRef => _firestore.collection('ratings');
  CollectionReference get categoriesRef => _firestore.collection('categories');

  // ── Generic helpers ────────────────────────────────────────────────────────

  /// Fetch a single document and return its data map with the doc id merged in.
  Future<Map<String, dynamic>?> getDoc(
      CollectionReference collection, String docId) async {
    final doc = await collection.doc(docId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }

  /// Fetch all documents in a collection (no filters).
  Future<List<Map<String, dynamic>>> getDocs(
      CollectionReference collection) async {
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Set a document (creates or overwrites).
  Future<void> setDoc(
      CollectionReference collection, String docId, Map<String, dynamic> data,
      {bool merge = false}) async {
    await collection.doc(docId).set(data, SetOptions(merge: merge));
  }

  /// Update specific fields in a document.
  Future<void> updateDoc(CollectionReference collection, String docId,
      Map<String, dynamic> data) async {
    await collection.doc(docId).update(data);
  }

  /// Delete a document.
  Future<void> deleteDoc(
      CollectionReference collection, String docId) async {
    await collection.doc(docId).delete();
  }

  /// Add a new document (auto-generated ID) and return its reference.
  Future<DocumentReference> addDoc(
      CollectionReference collection, Map<String, dynamic> data) async {
    return await collection.add(data);
  }

  // ── Batch helpers ──────────────────────────────────────────────────────────

  WriteBatch batch() => _firestore.batch();

  // ── Transaction helpers ────────────────────────────────────────────────────

  Future<T> runTransaction<T>(
      TransactionHandler<T> transactionHandler) async {
    return await _firestore.runTransaction(transactionHandler);
  }

  // ── Query helpers ──────────────────────────────────────────────────────────

  /// Stream of a single document.
  Stream<DocumentSnapshot> docStream(
          CollectionReference collection, String docId) =>
      collection.doc(docId).snapshots();

  /// Stream of a collection query.
  Stream<QuerySnapshot> queryStream(Query query) => query.snapshots();

  /// Paginated query: returns next page given last document snapshot.
  Future<QuerySnapshot> paginate({
    required Query query,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query q = query.limit(limit);
    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }
    return await q.get();
  }

  // ── Server timestamp ───────────────────────────────────────────────────────

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  FieldValue increment(num value) => FieldValue.increment(value);

  FieldValue arrayUnion(List items) => FieldValue.arrayUnion(items);

  FieldValue arrayRemove(List items) => FieldValue.arrayRemove(items);
}
