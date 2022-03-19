import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

import '../domain_error.dart';
import 'models/user_entity.dart';

abstract class AuthRepository {
  Future<Either<DomainError, List<UserEntity>>> fetchUsers();
}

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<DomainError, List<UserEntity>>> fetchUsers() async {
    throw UnimplementedError();
  }
}
