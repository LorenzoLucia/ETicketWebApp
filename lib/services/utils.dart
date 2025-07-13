import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}


class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Rimuove tutti i caratteri non numerici
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limita il numero massimo di cifre a 16
    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    // Aggiunge uno spazio ogni 4 cifre
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      int indexInGroup = i + 1;
      if (indexInGroup % 4 == 0 && indexInGroup != text.length) {
        buffer.write(' ');
      }
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}


class CardExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 4) {
      text = text.substring(0, 4); // max 4 cifre (MMYY)
    }

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        // aggiungi '/' solo se ci sono almeno altri caratteri
        buffer.write('/');
      } else if (i == 1 && text.length <= 2) {
        // aggiungi '/' appena scritte 2 cifre
        buffer.write('/');
      }
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}




class EuroPriceFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat = NumberFormat.currency(
    locale: "it_IT",
    symbol: "€",
    decimalDigits: 2,
    customPattern: "€#,##0.00",
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Rimuove tutto tranne cifre
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String oldText = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Se vuoto, restituisci testo vuoto
    if (newText.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse come numero
    double value = double.parse(newText) / 100;
    String formatted = _numberFormat.format(value);

    // Calcola nuovo offset del cursore
    int cursorOffset = formatted.length - (oldText.length - newText.length);

    // Proteggi offset dai limiti del testo
    if (cursorOffset > formatted.length) {
      cursorOffset = formatted.length;
    } else if (cursorOffset < 0) {
      cursorOffset = 0;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}


class CvcFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Rimuove tutto tranne numeri
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limita a massimo 3 cifre
    if (text.length > 3) {
      text = text.substring(0, 3);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
