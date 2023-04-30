class Group {
  String id;
  String name;
  int owner_user_id;
  String created_at;
  String updated_at;

  Group({
    required this.id,
    required this.name,
    required this.owner_user_id,
    required this.created_at,
    required this.updated_at,
  });
}