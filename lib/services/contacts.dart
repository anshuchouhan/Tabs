import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

class Contacts {
  static List<String> _contacts;
  static bool hasRequestedThisSession = false;

  static Future<PermissionStatus> _checkPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    bool showRationale = await PermissionHandler()
            .shouldShowRequestPermissionRationale(PermissionGroup.contacts) &&
        !hasRequestedThisSession;
    if (permission == PermissionStatus.unknown || showRationale) {
      // ask the user for contact permission
      Map<PermissionGroup, PermissionStatus> statuses =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      hasRequestedThisSession = true;
      return statuses[PermissionGroup.contacts];
    } else {
      return permission;
    }
  }

  static void _getContacts() async {
    if (await _checkPermission() == PermissionStatus.granted) {
      Iterable<Contact> contacts =
          await ContactsService.getContacts(withThumbnails: false);
      _contacts = contacts
          .map((contact) => contact.displayName != null
              ? contact.displayName
              : contact.givenName)
          .toList();
    }
  }

  static Future<List<String>> queryContacts(pattern) async {
    if (_contacts == null)
      _getContacts();
    else if (_contacts != null && _contacts.length > 0 && pattern.length > 0) {
      return _contacts
          .where((contact) =>
              contact.toLowerCase().contains(pattern.toLowerCase()))
          .toList();
    }
    return null;
  }
}
