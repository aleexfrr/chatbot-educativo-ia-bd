import 'package:flutter/material.dart';

enum DialogType {
  logout,
  updateProfile,
  deleteAccount,
  desactivateAccount,
}

class CustomDialog {
  static Future<void> show(
      BuildContext context, {
        required DialogType type,
        VoidCallback? onConfirm,
      }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final String title;
    final String content;
    final String confirmText;
    final Color confirmColor;

    switch (type) {
      case DialogType.logout:
        title = '¿Cerrar sesión?';
        content = '¿Estás seguro de que deseas cerrar sesión?';
        confirmText = 'Cerrar sesión';
        confirmColor = Colors.red;
        break;
      case DialogType.updateProfile:
        title = '¿Actualizar perfil?';
        content = '¿Deseas guardar los cambios realizados en tu perfil?';
        confirmText = 'Actualizar';
        confirmColor = Colors.blue;
        break;
      case DialogType.deleteAccount:
        title = '¿Eliminar cuenta?';
        content = '¿Estás seguro de que deseas eliminar tu cuenta?';
        confirmText = 'Eliminar cuenta';
        confirmColor = Colors.red;
        break;
      case DialogType.desactivateAccount:
        title = '¿Desactivar cuenta?';
        content = '¿Estás seguro de que deseas desactivar tu cuenta?';
        confirmText = 'Desactivar cuenta';
        confirmColor = Colors.orange;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra el diálogo
              onConfirm?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}