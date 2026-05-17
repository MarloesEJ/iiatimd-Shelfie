import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/book.dart';

class BookList extends StatefulWidget{
  final String searchQuery;
  final Function(Book) onBookSelected;
  final VoidCallback onRefresh;

  const BookList({
    super.key,
    required this.searchQuery,
    required this.onBookSelected,
    required this.onRefresh
  });

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList>{
  late Future<List<Book>> _booksFuture;

  @override
  void initState(){
    super.initState();
    _loadBooks();
  }

  void _loadBooks(){
    _booksFuture = DatabaseHelper.instance.readAllBooks();
  }

  @override
  Widget build(BuildContext context){
    _loadBooks();

    return FutureBuilder<List<Book>>(
      future: _booksFuture,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        else if(snapshot.hasError){
          return Center(child: Text('Fout bij laden boeken: ${snapshot.error}'));
        }
        else if(!snapshot.hasData || snapshot.data!.isEmpty){
          return const Center(child: Text('Nog geen boeken toegevoegd. Klik op + om een boek toe te voegen.'));
        }
        
        final allBooks = snapshot.data!;

        final filteredBooks = allBooks.where((book){
          final titleMatch = book.title.toLowerCase().contains(widget.searchQuery);
          final authorMatch = book.author.toLowerCase().contains(widget.searchQuery);
          return titleMatch || authorMatch;
        }).toList();

        if(filteredBooks.isEmpty){
          return const Center(child: Text('Geen boeken gevonden die overeenkomen met de zoekopdracht.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
            ),
          itemCount: filteredBooks.length,
          itemBuilder: (context, index){
            final book = filteredBooks[index];
            return GestureDetector(
              onTap: () {
                print('BOOK_LIST: Klik op boek tegel');
                widget.onBookSelected(book); //stuurt geklikte boek door naar homeView
              },
              child: Card(
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: (book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty)
                          ? Image.network(
                            book.thumbnailUrl!, 
                            fit: BoxFit.cover, 
                            errorBuilder: (c, e, s) => const Icon(Icons.book, size: 50))
                          : const Icon(Icons.book, size: 50),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}