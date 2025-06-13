class CatImage {
  final String url;
  final DateTime date;

  CatImage({required this.url, required this.date});

  factory CatImage.fromJson(Map<String, dynamic> json) {
    return CatImage(
      url: json['url'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'date': date.toIso8601String(),
      };
}
