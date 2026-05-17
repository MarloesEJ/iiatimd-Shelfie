import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService{
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const String _apiKey = 'AIzaSyCbqJkT4StjGkVUUNlvkNVukhWYkUCD-bg';

  static Future<Book?> fetchBookByIsbn(String isbn) async{
    final url = Uri.parse('$_baseUrl?q=isbn:$isbn&key=$_apiKey');

    try{
      final response = await http.get(url);
      if (response.statusCode == 200){
        final data = jsonDecode(response.body);
        if (data['totalItems']>0){
          final item = data['items'][0]['volumeInfo'];
          return _mapToBook(item, isbn);
        }
      }
    }
    catch (e){
      print('Fout bij ophalen boek: $e');
    }
    return null;
  }
  
  static Future<List<Book>> searchBooks(String query) async{
    print('ApiService: Start zoeken naar "$query"...');

    if (query.isEmpty) return [];

    // verwijder spaties en streepjes voor een schonere invoer.
    String cleanQuery = query.replaceAll(RegExp(r'[\s-]'), '');

    //controleerd op de invoer puur uit 10 of 13 cijfers bestaat, voor een ISBN
    bool isIsbn = RegExp(r'^\d{10}$|^\d{13}$').hasMatch(cleanQuery);

    String finalQuery = isIsbn ? 'isbn:$cleanQuery' : Uri.encodeComponent(query);


    final url = Uri.parse('$_baseUrl?q=$finalQuery&maxResults=10&key=$_apiKey');
    print('ApiService: URL opgebouwd -> $url');

    try {
      print('ApiService: HTTP GET verzoek wordt verstuurd');

      final response = await http.get(url).timeout(const Duration(
          seconds: 5)); //timeout toegevoegd, zodat dit niet voor eeuwig duurt en door catch gevangen kan worden

      print('ApiService: Statuscode ontvangen -> ${response.statusCode}');

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data['totalItems'] == 0 || data['items'] == null) {
        print('ApiService: 0 resultaten teruggekregen van de API link');
        return [];
      }

      final List items = data['items'];
      List<Book> books = [];

      for (var item in items) {
        final volumeInfo = item['volumeInfo'];
        final String id = item['id'] ?? DateTime
            .now()
            .millisecondsSinceEpoch
            .toString();

        books.add(_mapToBook(volumeInfo, id));
      }
      print('ApiService: ${books.length} boeken gevonden');
      return books;
    }

    catch (e){
      print('fout bij handmatig zoeken naar boek: $e');
    }
    return [];
  }

  static Book _mapToBook(Map<String, dynamic> volumeInfo, String customId){
    String isbn = customId;
    if (volumeInfo['industryIdentifiers'] != null) {
      final List idents = volumeInfo['industryIdentifiers'];
      final isbn13 = idents.firstWhere(
        (id) => id['type'] == 'ISBN_13',
        orElse: () => idents.firstWhere((id) => id['type'] == 'ISBN_10', orElse: () => null),
      );
      if (isbn13 != null){
        isbn = isbn13['identifier'];
      }
    }

    return Book(
      id: customId,
      title: volumeInfo['title'] ?? 'Onbekende Titel',
      author: (volumeInfo['authors'] as List?)?.join(',')?? 'Onbekende auteur',
      isbn: isbn,
      thumbnailUrl: volumeInfo['imageLinks']?['thumbnail']?? '',
      description: volumeInfo['description'] ?? 'Geen beschrijving beschikbaar.',
      createdAt: DateTime.now(),
    );
  }
}