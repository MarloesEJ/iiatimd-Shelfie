// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import '../services/firebase_service.dart';
import '../widgets/book_list.dart';
import '../models/book.dart';
import 'add_book_view.dart';
import 'book_detail_view.dart';


class HomeView extends StatefulWidget{
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>{
  Book? _selectedBook;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shelfie', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Zoek tussen je boeken...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value){
                setState((){
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          )
        )
      ),

      body: LayoutBuilder(
        builder: (Context, constraints){
          if(constraints.maxWidth > 600){
            return _buildTabletLayout();
          }
          else{
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
            MaterialPageRoute(builder: (context) => const AddBookView())
            );

            // refreshed wanneer addBookview gesloten is, zodat nieuwe toegevoegde boeken te zien zijn.
            _refreshData();
        },
      ),
    );
  }


  //Layout

  Widget _buildMobileLayout(){
    return BookList(
      searchQuery: _searchQuery,
      onBookSelected: (book) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailView(book: book, isPreview: false),
          ),
        ).then((_) => _refreshData());
      },
      onRefresh: _refreshData,
    );
  }

  Widget _buildTabletLayout(){
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: BookList(
            searchQuery: _searchQuery,
            onBookSelected: (book) => setState(()=> _selectedBook = book),
            onRefresh: (){
              _refreshData;
              setState(() => _selectedBook = null);
            }, 
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        Expanded(
          child: _selectedBook == null
          ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Selecteer een boek uit je bibliotheek', style: TextStyle(fontSize: 16, color: Colors.grey))
              ],
            ),
          )
          : KeyedSubtree(
              key: ValueKey(_selectedBook!.id),
              child: BookDetailView(book: _selectedBook!, isPreview: false),
            ),
        ),
      ],
    );
  }


}

