import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/book.dart';

class BookList extends StatelessWidget{
  const BookList({super.key});

  @override
  Widget build(BuildContext context){
    return FutureBuilder<List<Book>>(
      future: DatabaseHelper.instance.readAllBooks(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError){
          return Center(child: Text('Fout: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty){
          return const Center(child: Text('Nog geen boeken gescnad.'));
        }

        final books = snapshot.data!;

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index){
            final book = books[index];
            return ListTile(
              leading: (book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty)
                  ? Image.network(book.thumbnailUrl!)
                  : const Icon(Icons.book),
              title: Text(book.title),
              subtitle: Text(book.author),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await DatabaseHelper.instance.delete(book.id);
                }
              ),
            );
          },
        );
      },
    );
  }
}