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

  //State bijhouden of Scan modes of Resultaat modes is.
  bool _showResults = false;
  bool _isLoading = false;

  void _handleSearch(String query) async{
    if(query.trim().isEmpty) return;

    setState((){
      _isLoading = true;
      _showResults = true; //gaat naar resultaten scherm.
    });

    final results = await ApiService.searchBooks(query);

    setState((){
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _resetToScanner(){
    setState(() {
      _showResults = false;
      _searchResults = [];
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context){
    //Als showResults true is, wordt alleen de resultaten getoond en is de scanner uit.
    if(_showResults){
      return _buildResultsView();
    }
    //zoek scherm is weer actief, scanner is aan.
    return buildScannerView();
  }

  Widget buildScannerView(){
    return ScanView(
      onCodeDetected: (query){
        _searchController.text = query;
        _handleSearch(query);
      }
    );
  }

  Widget _buildResultsView(){
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _resetToScanner,
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Verder zoeken...',
            border: InputBorder.none,
          ),
          onSubmitted: _handleSearch,
        ),
        actions: [
          if(_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: (){
                _searchController.clear();
              },
            ),
        ],
      ),
      
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _searchResults.isEmpty
          ? const Center(child: Text('Geen boeken gevonden. Probeer een andere zoekopdracht.'))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index){
                final book = _searchResults[index];
                return ListTile(
                  leading: (book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty)
                    ? Image.network(book.thumbnailUrl!, width: 40, errorBuilder: (c, e, s) => const Icon(Icons.book))
                    : const Icon(Icons.book),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailView(book: book, isPreview: true),
                      ),
                    ).then((_){
                    });
                  },
                );
              },
          ),
    );
  }
}