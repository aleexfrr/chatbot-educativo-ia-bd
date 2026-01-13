
class Utils {
  // Validar nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su nombre';
    }
    return null;
  }

  // Validar apellidos
  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese sus apellidos';
    }
    return null;
  }

  // Validar teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su número de teléfono';
    }
    final phoneRegex = RegExp(r'^[6789]\d{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'El teléfono debe tener 9 caracteres y empezar con 6, 7, 8 o 9';
    }
    return null;
  }

  // Validar correo electrónico
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  // Validar contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'La contraseña debe tener al menos 8 caracteres y contener al menos un número, una letra y un símbolo';
    }
    return null;
  }

  // Validar Población
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su dirección';
    }
    if(value.length < 3){
      return 'El nombre debe tener al menos 3 carácteres';
    }
    return null;
  }
}