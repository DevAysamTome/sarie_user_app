import 'package:flutter/material.dart';
import 'package:user_app/models/meal.dart';
import 'package:user_app/views/home/resturent_view/meal_detial_view.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  List<Meal> meals = [];
  String selectedCategory = '';
  double parsePrice(dynamic price) {
    if (price is int) {
      return price.toDouble();
    } else if (price is String) {
      return double.parse(price);
    } else {
      throw TypeError();
    }
  }

  @override
  void initState() {
    super.initState();
    meals = List<Map<String, dynamic>>.from(widget.restaurant['meals'] ?? [])
        .map((mealData) => Meal(
            id: mealData['id'],
            name: mealData['mealName'],
            description: mealData['description'],
            price: parsePrice(mealData['price']),
            imageUrl: mealData['imageUrl'] ?? '',
            ingredients: mealData['ingredients'] ?? '',
            addOns: mealData['addOns'],
            category: mealData['category']))
        .toList();
    selectedCategory = '';
  }

  void filterMeals(String category) {
    setState(() {
      selectedCategory = category;
      if (category == '') {
        meals =
            List<Map<String, dynamic>>.from(widget.restaurant['meals'] ?? [])
                .map((mealData) => Meal(
                    id: mealData['id'],
                    name: mealData['mealName'],
                    description: mealData['description'],
                    price: parsePrice(mealData['price']),
                    imageUrl: mealData['imageUrl'] ?? '',
                    ingredients: mealData['ingredients'],
                    addOns: mealData['addOns'],
                    category: mealData['category']))
                .toList();
      } else {
        meals =
            List<Map<String, dynamic>>.from(widget.restaurant['meals'] ?? [])
                .map((mealData) => Meal(
                    id: mealData['id'],
                    name: mealData['mealName'],
                    description: mealData['description'],
                    price: parsePrice(mealData['price']),
                    imageUrl: mealData['imageUrl'] ?? '',
                    ingredients: mealData['ingredients'],
                    addOns: mealData['addOns'],
                    category: mealData['category']))
                .where((meal) => meal.category == category)
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.restaurant['name'] ?? 'اسم غير متوفر',
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.redAccent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Restaurant Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.restaurant['imageUrl'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Restaurant Name and Rating
            Center(
              child: Column(
                children: [
                  Text(
                    widget.restaurant['name'] ?? 'اسم غير متوفر',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.restaurant['address'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Delivery Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.restaurant['rating'] ?? 0}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                const Row(
                  children: [
                    Icon(Icons.delivery_dining, color: Colors.green, size: 24),
                    SizedBox(width: 4),
                    Text(
                      'توصيل ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                const Row(
                  children: [
                    Icon(Icons.timer, color: Colors.redAccent, size: 24),
                    SizedBox(width: 4),
                    Text(
                      '20 دقيقة',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categories
            const Text(
              'التصنيفات:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('كل الوجبات'),
                    selected: selectedCategory == '',
                    onSelected: (selected) {
                      filterMeals('');
                    },
                    selectedColor: Colors.redAccent,
                  ),
                  const SizedBox(width: 10), // المسافة بين العناصر
                  ...List<String>.from(widget.restaurant['categories'] ?? [])
                      .map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          filterMeals(category);
                        },
                        selectedColor: Colors.redAccent,
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Meals
            const Text(
              'المنتجات:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailsScreen(
                          meal: meal,
                          restaurant: widget.restaurant,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: Image.network(
                            meal.imageUrl,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Meal Name
                              Text(
                                meal.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Meal Description
                              Text(meal.description,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),

                              // Meal Price
                              Text(
                                'السعر: ${meal.price}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
