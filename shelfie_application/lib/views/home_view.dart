import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/book_list.dart';
import '../models/book.dart';
import 'scan_view.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class HomeView extends StatefulWidget{
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>{
  Book? _selectedBook;

  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shelfie', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _handleScan(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if(constraints.maxWidth > 600){
            return _buildTabletLayout();
          } else{
            return _buildMobileLayout();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleScan(context),
        label: const Text('Scan Book'),
        icon: const Icon(Icons.add),
      ),
    );
  }


  //Layout

  Widget _buildMobileLayout(){
    return BookList(
      onBookSelected: (book) => _showBookDetails(book),
      onRefresh: _refreshData,
    );
  }

  Widget _buildTabletLayout(){
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: BookList(
            onBookSelected: (book) => setState(()=> _selectedBook = book),
            onRefresh: _refreshData,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedBook == null
          ? const Center(child: Text('Selecteer een boek om details te zien'))
          : _BookDetailPane(book: _selectedBook!),
        ),
      ],
    );
  }


  //Logica

  Future<void> _handleScan(BuildContext context) async{
    final String? isbn = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> const ScanView()),
    );

    if(isbn != null){
      final book = await ApiService.fetchBookByIsbn(isbn);
      if(book != null){
        await DatabaseHelper.instance.create(book);

        await FirebaseService().syncBookToCloud(book);
        _refreshData();
      }
    }
  }

  void _showBookDetails(Book book){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context)=> DraggableScrollableSheet(
        initialChildSize: 0.6,
        builder: (context, scrollController) => _BookDetailPane(book: book),
      ),
    );
  }

}

class _BookDetailPane extends StatelessWidget{
  final Book book;
  const _BookDetailPane({required this.book});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (book.thumbnailUrl != null)
            Center(child: Image.network(book.thumbnailUrl!, height: 200)),
          const SizedBox(height: 20),
          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
          Text(book.author, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
          const Divider(height: 30),
          Text('Beschrijving:', style: Theme.of(context).textTheme.titleSmall),
          const Divider(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(book.description)
            ),
          ),
        ],
      ),
    );
  }
}