class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String? thumbnailUrl;
  final String description;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.thumbnailUrl,
    this.description = '',
    required this.createdAt,
  });

  // zet een Map om naar een Book object
  factory Book.fromMap(Map<String, dynamic> map){
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      isbn: map['isbn'],
      thumbnailUrl: map['thumbnailUrl'],
      description: map['description']?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  //Book object om zetten naar een map voor opslag
  Map<String, dynamic> toMap(){
    return{
      'title': title,
      'author': author,
      'isbn' : isbn,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };

  }
}