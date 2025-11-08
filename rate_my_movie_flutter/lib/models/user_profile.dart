class UserProfile {
  final String uid; // email no modo local; uid Firebase no modo remoto
  final String name;
  final String email;
  final String? photoPath; // caminho local da foto (galeria/câmera)

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoPath,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoPath': photoPath,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        photoPath: m['photoPath'],
      );
}
