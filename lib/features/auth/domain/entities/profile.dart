/// What the app stores in the `profiles` table.
///
/// [id] is the same id that Auth gave the account.
class Profile {
  final String id;
  final String username;
  final String fullName;

  const Profile({
    required this.id,
    required this.username,
    required this.fullName,
  });
}
