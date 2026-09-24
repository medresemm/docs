import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../services/plan_service.dart';

/// Inline AZ/EN copy. Falls back to Azerbaijani.
String tr(BuildContext context, String az, String en) {
  final code = Provider.of<PlanService>(context, listen: true).locale;
  return code == 'en' ? en : az;
}

String trRead(BuildContext context, String az, String en) {
  final code = Provider.of<PlanService>(context, listen: false).locale;
  return code == 'en' ? en : az;
}
