import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageService {
  // Processa a imagem para um tamanho padrão de avatar e remove metadados.
  static Future<Uint8List> processAvatar(File imageFile) async {
    // Decodifica a imagem para poder manipulá-la
    final originalImage = img.decodeImage(await imageFile.readAsBytes());

    if (originalImage == null) {
      throw Exception('Não foi possível decodificar a imagem.');
    }

    // Redimensiona para um tamanho fixo de 256x256 pixels
    final resizedImage = img.copyResize(originalImage, width: 256, height: 256);

    // Codifica para o formato JPG com qualidade de 85%.
    // Isso comprime a imagem e remove automaticamente os metadados EXIF.
    return img.encodeJpg(resizedImage, quality: 85);
  }
}