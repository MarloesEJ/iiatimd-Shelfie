// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import '../services/firebase_service.dart';
import '../widgets/book_list.dart';
import '../models/book.dart';
import 'add_book_view.dart';


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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async{
          // wacht to terug is van AddBookView
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddBookView()));
            // refreshed wanneer addBookview gesloten is, zodat nieuwe toegevoegde boeken te zien zijn.
            _refreshData();
        },
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