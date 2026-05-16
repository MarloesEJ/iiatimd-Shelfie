import 'package:flutter/material.dart';
import 'scan_view.dart';
import '../services/api_service.dart';
import '../models/book.dart';
import 'book_detail_view.dart';

class AddBookView extends StatefulWidget{
  const AddBookView({super.key});

  @override
  State<AddBookView> createState() => _AddBookViewState();
}

class _AddBookViewState extends State<AddBookView>{
  List<Book> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  void _searchBooks(String query) async{
    final results = await ApiService.searchBooks(query);
    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Boek toevoegen')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: 'Zoek of naam of ISBN', border: OutlineInputBorder()),
                    onSubmitted: _searchBooks,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, size: 30),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanView())),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index){
                final book = _searchResults[index];
                return ListTile(
                  leading: book.thumbnailUrl != null
                      ? Image.network(book.thumbnailUrl!)
                      : const Icon(Icons.book),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => BookDetailView(book: book, isPreview: true))
                  ),
                );
              })
          )
        ],
      )
    );
  }
}