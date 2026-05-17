import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_helper.dart';
// import '../services/firebase_service.dart';

class BookDetailView extends StatelessWidget{
  final Book book;
  final bool isPreview;

  const BookDetailView({super.key, required this.book, this.isPreview = false});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (book.thumbnailUrl != null) Image.network(book.thumbnailUrl!, height: 250),
                    const SizedBox(height: 20),
                    Text(book.title, style: Theme.of(context).textTheme.headlineMedium),
                    Text(book.author, style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    Text(book.description),
                    const SizedBox(height: 30),
    ],
                ),
              ),
            ),

            if (isPreview)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async{
                    try{
                      print('BOOK_DETAIL: Start opslaan van boek: ${book.title}');

                      await DatabaseHelper.instance.create(book);
                      // await FirebaseService().saveBookToCloud(book);

                      print('BOOK_DETAIL: Opslaan gelukt!');

                      if(!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${book.title}" is succesvol toegevoegd!'),
                          backgroundColor: Colors.lightGreen.withValues(alpha: 0.5),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    catch(e, stacktrace){
                      print('BOOK_DETAIL ERROR: $e');
                      print('STACKTRACE: $stacktrace');

                      if(!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Fout bij toevoegen: $e'),
                          backgroundColor: Colors.red.withValues(alpha: 0.5),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                    finally {
                      print('BOOK_DETAIL: Sluiten van preview scherm');
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Toevoegen aan bibliotheek', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ),    
          ],
        )
      ) 
    );
  }
}