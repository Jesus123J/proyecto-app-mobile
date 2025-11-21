class WalletDisponible {
  final String walletUuid;
  final String userName;
  final String appName;

  WalletDisponible({
    required this.walletUuid,
    required this.userName,
    required this.appName,
  });

  factory WalletDisponible.fromJson(Map<String, dynamic> json) {
    return WalletDisponible(
      walletUuid: json['wallet_uuid']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      appName: json['app_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_uuid': walletUuid,
      'user_name': userName,
      'app_name': appName,
    };
  }
}

class WalletResponse {
  final bool found;
  final String identifier;
  final List<WalletDisponible> walletsDisponibles;

  WalletResponse({
    required this.found,
    required this.identifier,
    required this.walletsDisponibles,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      found: json['found'] ?? false,
      identifier: json['identifier']?.toString() ?? '',
      walletsDisponibles: (json['wallets_disponibles'] as List<dynamic>?)
              ?.map((w) => WalletDisponible.fromJson(w))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'found': found,
      'identifier': identifier,
      'wallets_disponibles': walletsDisponibles.map((w) => w.toJson()).toList(),
    };
  }
}
