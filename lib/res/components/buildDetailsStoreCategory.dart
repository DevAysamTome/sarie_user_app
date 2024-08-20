import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryCards extends StatelessWidget {
  final String title;
  final Future<List<Map<String, dynamic>>> futureData;
  final Function(Map<String, dynamic>) onTap;

  const CategoryCards({
    super.key,
    required this.title,
    required this.futureData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<Map<String, dynamic>> data = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var item = data[index];

                  // Get current time
                  final now = TimeOfDay.now();

                  // Parse opening and closing times
                  final openingTime = _parseTime(item['openingTime']);
                  final closingTime = _parseTime(item['closingTime']);

                  // Determine store status
                  final isOpen = _isStoreOpen(now, openingTime, closingTime);

                  return GestureDetector(
                    onTap: () => onTap(item),
                    child: Container(
                      width: 320,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12.0)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: item['imageUrl'] != null &&
                                        item['imageUrl'].isNotEmpty
                                    ? Image.network(
                                        item['imageUrl'],
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.work_rounded,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${item['openingTime']} - ${item['closingTime']}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item['address'] ?? '',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'الحالة : ${isOpen ? 'مفتوح' : 'مغلق'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isOpen ? Colors.green : Colors.red,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  TimeOfDay _parseTime(String time) {
    try {
      final format = DateFormat.jm(); // "6:00 AM"
      final dateTime = format.parse(time);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      print('Error parsing time: $e');
      return TimeOfDay.now(); // Return current time if parsing fails
    }
  }

  bool _isStoreOpen(
      TimeOfDay now, TimeOfDay openingTime, TimeOfDay closingTime) {
    final currentMinutes = now.hour * 60 + now.minute;
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;

    if (closingMinutes >= openingMinutes) {
      return currentMinutes >= openingMinutes &&
          currentMinutes <= closingMinutes;
    } else {
      // Handles overnight cases (e.g., opening at 22:00, closing at 02:00)
      return currentMinutes >= openingMinutes ||
          currentMinutes <= closingMinutes;
    }
  }
}
