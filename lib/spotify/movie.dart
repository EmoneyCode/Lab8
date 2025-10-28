class Movie {
  final String title;
  final String releaseDate;
  final String voteAverage;

  Movie.fromJson(Map<String, dynamic> json)
    : title = json['title'] ?? 'No Title',
      releaseDate = json['release_date'] ?? 'Unknown',
      voteAverage = (json['vote_average'] != null)
          ? (double.tryParse(
                  json['vote_average'].toString(),
                )?.toStringAsFixed(1) ??
                '0.0')
          : '0.0';
}
