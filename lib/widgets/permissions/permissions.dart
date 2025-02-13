import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses =
      await [Permission.notification, Permission.microphone].request();

  // Verificar se as permissões foram concedidas
  if (statuses[Permission.notification] != PermissionStatus.granted) {
    if (statuses[Permission.notification] == PermissionStatus.denied) {
      // permissão de notificação negada
    } else if (statuses[Permission.notification] ==
        PermissionStatus.permanentlyDenied) {
      // permissão de notificação permanentemente negada
    }
  }

  if (statuses[Permission.microphone] != PermissionStatus.granted) {
    if (statuses[Permission.microphone] == PermissionStatus.denied) {
      // permissão de microfone negada
    } else if (statuses[Permission.microphone] ==
        PermissionStatus.permanentlyDenied) {
      // permissão de microfone permanentemente negada
    }
  }
}
