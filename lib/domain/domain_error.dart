enum DomainErrorType {
  /// Error authenticating user data
  authentication,

  /// Error returned while processing data on server
  backend,

  /// Error caused by json parsing
  parsing,

  /// Error while sending or receiving data
  connection,

  /// Error when there is no internet connection
  noInternet,

  /// Error while trying to reach unexisting local resource
  noData,

  /// Error not expected by a developer. Needs a fix in a code
  unexpected,

  /// Error which does not fit any of the above
  unknown,
}

class DomainError {
  final DomainErrorType type;
  final String? errorMessage;

  final int? statusCode;

  DomainError.authentication(this.errorMessage)
      : type = DomainErrorType.authentication,
        statusCode = 403;

  DomainError.backend(this.errorMessage, this.statusCode)
      : type = DomainErrorType.backend;

  DomainError.parsing(this.errorMessage)
      : type = DomainErrorType.parsing,
        statusCode = null;

  DomainError.noData(this.errorMessage)
      : type = DomainErrorType.noData,
        statusCode = 404;

  DomainError.unexpected(this.errorMessage)
      : type = DomainErrorType.unexpected,
        statusCode = null;

  DomainError.unknown(this.errorMessage)
      : type = DomainErrorType.unknown,
        statusCode = null;

  @override
  String toString() => errorMessage ?? '$type';
}
