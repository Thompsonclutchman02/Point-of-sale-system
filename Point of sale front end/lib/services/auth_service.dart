import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initializeDefaultUsers();
  }

  List<User> _users = [];
  User? _currentUser;

  void _initializeDefaultUsers() {
    // Default admin user
    _users.add(User(
      id: '1',
      username: 'admin',
      password: '4321',
      role: 'admin',
      name: 'System Administrator',
      createdAt: DateTime.now(),
    ));
  }

  Future<User?> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

    final user = _users.firstWhere(
          (user) => user.username == username && user.password == password,
      orElse: () => User(
        id: '',
        username: '',
        password: '',
        role: '',
        name: '',
        createdAt: DateTime.now(),
      ),
    );

    if (user.id.isNotEmpty) {
      _currentUser = user;
      return user;
    }

    return null;
  }

  void logout() {
    _currentUser = null;
  }

  User? get currentUser => _currentUser;

  bool get isAdmin => _currentUser?.role == 'admin';

  void addEmployee(User employee) {
    _users.add(employee);
  }

  List<User> getEmployees() {
    return _users.where((user) => user.role == 'employee').toList();
  }

  void removeEmployee(String id) {
    _users.removeWhere((user) => user.id == id);
  }
}