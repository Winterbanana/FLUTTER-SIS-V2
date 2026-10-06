class Section {
  final int? id;
  final String sectionName;
  final int yearLevel;

  Section({
    this.id,
    required this.sectionName,
    required this.yearLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_name': sectionName,
      'year_level': yearLevel,
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'],
      sectionName: map['section_name'],
      yearLevel: map['year_level'],
    );
  }
}