
class Meal {
  final String id; // إضافة خاصية id
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<dynamic> ingredients;
  final List<dynamic> addOns;
  final String category;

  Meal({
    required this.id, // تهيئة خاصية id
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.ingredients,
    required this.addOns,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // إضافة id إلى الخريطة
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'addOns': addOns,
      'category': category,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'], // قراءة id من الخريطة
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      ingredients: List<String>.from(map['ingredients']),
      addOns: List<String>.from(map['addOns']),
      category: map['category'],
    );
  }
}
