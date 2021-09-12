import 'package:pet_lover/model/adminPower.dart';

class AdminPowers {
  static const List<AdminPower> powerOfAdmin = [
    promoteMember,
    demoteMember,
    removeMember
  ];
  static const promoteMember = AdminPower(power: 'Promote');
  static const demoteMember = AdminPower(power: 'demote');
  static const removeMember = AdminPower(power: 'Remove');
}
