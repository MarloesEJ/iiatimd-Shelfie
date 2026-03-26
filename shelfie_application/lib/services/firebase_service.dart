import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class FirebaseService{
  final CollectionReference _booksRef =
      FirebaseFirestore.instance.collection('users/USER_ID/books');

  Future<void> syncBookToCloud(Book book) async{
    await _booksRef.doc(book.isbn).set(book.toMap());
  }
}