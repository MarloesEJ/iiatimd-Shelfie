import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class FirebaseService{
  final CollectionReference _booksRef =
      FirebaseFirestore.instance.collection('books');

  Future<void> syncBookToCloud(Book book) async{
    try{
      await _booksRef.doc(book.id).set(book.toMap());
    } catch (e) {
      print('Fout bij synchroniseren boek: $e');
    }
  }

  Future<List<Book>> fetchBooksFromCloud() async{
    final snapshot = await _booksRef.get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}