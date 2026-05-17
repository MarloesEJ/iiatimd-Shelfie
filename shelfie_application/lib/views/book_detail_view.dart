import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_helper.dart';
// import '../services/firebase_service.dart';

class BookDetailView extends StatefulWidget{
  final Book book;
  final bool isPreview; //true = via zoeken, false= via homepage

  const BookDetailView({super.key, required this.book, this.isPreview = false});

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView>{
  bool _isAlreadySaved = false;
  bool _isLoadingCheck = true;

  @override
  void initState(){
    super.initState();
    if(widget.isPreview){
      _checkIfBookExists();
    }
    else{
      _isLoadingCheck = false;
    }
  }

  Future<void> _checkIfBookExists() async{
    final savedBooks = await DatabaseHelper.instance.readAllBooks();
    final exists = savedBooks.any((b) => b.id == widget.book.id || b.isbn == widget.book.isbn);

    setState((){
      _isAlreadySaved = exists;
      _isLoadingCheck = false;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions:[
          if(!widget.isPreview)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async{
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Boek verwijderen'),
                    content: Text('Weet je zeker dat je "${widget.book.title}" wilt verwijderen?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuleer')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Verwijder', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (confirm == true){
                  await DatabaseHelper.instance.delete(widget.book.id);
                  if(!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Boek is verwijderd'), backgroundColor: Colors.amber),
                  );
                  if (widget.isPreview == false && Navigator.canPop(context)){
                    Navigator.pop(context);
                  }
                  else{}
                }
              },
            ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.book.thumbnailUrl?.isNotEmpty == true)
                      Center(child: Image.network(widget.book.thumbnailUrl!, height: 220, errorBuilder: (c, e, s) => const Icon(Icons.book, size: 100))),
                    const SizedBox(height: 20),
                    Text(widget.book.title, style: Theme.of(context).textTheme.headlineMedium),
                    Text(widget.book.author, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                    const Divider(),
                    Text(widget.book.description, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            if(widget.isPreview)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoadingCheck
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),

                      backgroundColor: _isAlreadySaved
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Theme.of(context).colorScheme.primary,
                      foregroundColor: _isAlreadySaved
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: _isAlreadySaved ? 0 : 2,
                    ),

                    onPressed: _isAlreadySaved
                      ? null
                      : () async{
                        try{
                          await DatabaseHelper.instance.create(widget.book);
                          if(!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"${widget.book.title}" is successvol toegevoegd!'),
                              backgroundColor: Colors.lightGreen.withValues(alpha: 0.8),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                        catch(e){
                          print('Fout bij opslaan: $e');
                        }
                        finally{
                          Navigator.pop(context);
                        }
                      },

                      child: Text(
                        _isAlreadySaved ? 'Al in je bibliotheek' : 'Toevoegen aan bibliotheek',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}