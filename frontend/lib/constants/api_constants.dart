import 'package:flutter/foundation.dart';

const String _productionUrl = 'https://flowplan-ai-production.up.railway.app';
const String _localUrl = 'http://localhost:8000';

String get baseUrl => kReleaseMode ? _productionUrl : _localUrl;
