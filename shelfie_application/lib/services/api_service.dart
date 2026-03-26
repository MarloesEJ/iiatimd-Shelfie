import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService{
  static Future<Book?> fetchBookByIsbn(String isbn) async{
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn');

    try{
      final response = await http.get(url);
      if (response.statusCode == 200){
        final data = jsonDecode(response.body);
        if (data['totalItemss']>0){
          final item = data['items'][0]['volumeInfo'];

          return Book(
            id: isbn,
            title: item['title']?? 'Onbekende titel',
            author: (item['authors'] as List?)?.join(', ') ?? 'Onbekende auteur',
            isbn: isbn,
            thumbnailUrl: item['imageLinks']?['thumbnail']?? '',
            description: item['description']?? '',
            createdAt: DateTime.now(),
          );
        }
      }
    }
    catch(e){
      print('Fout bij ophalen boek: $e');
    }
    return null;
  }
}