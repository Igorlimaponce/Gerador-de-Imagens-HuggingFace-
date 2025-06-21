import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api-inference.huggingface.co/models';
  final String model = 'stabilityai/stable-diffusion-3-medium-diffusers';
  // IMPORTANTE: Cole aqui o seu Access Token do Hugging Face
  final String apiKey =
      'COLAR_AQUI_TOKEN'; // Certifique-se de que colou seu token aqui

  Future<String> generateImage(String prompt) async {
    // A linha abaixo foi corrigida.
    // A forma correta de criar a URL é usando '$variavel' para que o Dart
    // substitua o nome da variável pelo seu valor, sem barras invertidas.
    final url = Uri.parse('$baseUrl/$model');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'negative_prompt': 'low quality, blurry, distorted',
            'guidance_scale': 7.5,
          }
        }),
      );

      if (response.statusCode == 200) {
        final base64Image = base64Encode(response.bodyBytes);
        return 'data:image/jpeg;base64,$base64Image';
      } else {
        // Se o modelo estiver carregando (erro 503), a API pede para tentar de novo.
        if (response.statusCode == 503) {
          await Future.delayed(
              const Duration(seconds: 10)); // Aumentei o tempo de espera
          return generateImage(prompt);
        }

        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error'] ?? 'Erro desconhecido da API';
        // Lança uma exceção mais detalhada para ser exibida na tela.
        throw Exception(
            'Falha ao gerar imagem (Status ${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      // Relança a exceção para ser tratada na tela inicial.
      rethrow;
    }
  }
}
