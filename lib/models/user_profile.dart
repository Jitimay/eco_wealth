import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String village;

  @HiveField(2)
  int goats;

  @HiveField(3)
  int chickens;

  @HiveField(4)
  DateTime createdAt;

  UserProfile({
    required this.name,
    required this.village,
    required this.goats,
    required this.chickens,
    required this.createdAt,
  });
}
