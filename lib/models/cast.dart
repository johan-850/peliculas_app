class Cast {
  Cast({
    required this.id,
    required this.name,
    this.profilePath,
    this.character,
    this.knownForDepartment,
    this.order,
  });

  int id;
  String name;
  String? profilePath;
  String? character;
  String? knownForDepartment;
  int? order;

  String get fullProfileImg {
    if (profilePath != null) {
      return 'https://image.tmdb.org/t/p/w500$profilePath';
    }
    return 'https://via.placeholder.com/300x450.png?text=No+Image';
  }

  factory Cast.fromMap(Map<String, dynamic> json) => Cast(
        id: json['id'],
        name: json['name'],
        profilePath: json['profile_path'],
        character: json['character'],
        knownForDepartment: json['known_for_department'],
        order: json['order'],
      );
}
