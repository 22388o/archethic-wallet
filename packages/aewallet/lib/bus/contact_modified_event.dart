// Package imports:

// Package imports:
import 'package:core/model/data/hive_db.dart';
import 'package:event_taxi/event_taxi.dart';

class ContactModifiedEvent implements Event {
  ContactModifiedEvent({this.contact});

  final Contact? contact;
}
