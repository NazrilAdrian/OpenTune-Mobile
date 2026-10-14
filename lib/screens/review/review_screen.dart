import 'package:flutter/material.dart';
import 'review_model.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final List<ReviewModel> _reviews = [
    ReviewModel(
      id: '1',
      userName: 'Nazril Adrian',
      rating: 5.0,
      comment: 'Lagunya keren banget, pas buat didengerin!',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReviewModel(
      id: '2',
      userName: 'Syahid Ahmad',
      rating: 4.0,
      comment: 'Kualitas audio jernih dan enak didengar.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void _showAddReviewDialog(BuildContext context) {
    double currentRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Beri Ulasan & Rating'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pilih Bintang:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < currentRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            currentRating = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Tulis ulasan Anda...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      setState(() {
                        _reviews.insert(
                          0,
                          ReviewModel(
                            id: DateTime.now().toString(),
                            userName: 'Anda (Fharel)',
                            rating: currentRating,
                            comment: commentController.text,
                            createdAt: DateTime.now(),
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan & Rating Lagu'),
      ),
      body: ListView.builder(
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(5, (star) {
                          return Icon(
                            star < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(review.comment),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context),
        label: const Text('Beri Ulasan'),
        icon: const Icon(Icons.rate_review),
      ),
    );
  }
}
