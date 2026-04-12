import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: 'lib/env/.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'API_KEY')
  static String apiKey = _Env.apiKey;
}