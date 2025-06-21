import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Importação adicionada para corrigir 'Undefined class Uint8List'.
import 'package:flutter/material.dart';
// Import alterado para o pacote correto
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ImageViewScreen extends StatefulWidget {
  final String imageUrl;
  final String prompt;

  // Construtor corrigido para usar super parâmetros.
  const ImageViewScreen({
    super.key,
    required this.imageUrl,
    required this.prompt,
  });

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  bool _isFullScreen = false;
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _saveImage() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // No Android 10+ a permissão de storage não é mais necessária
      // para salvar na galeria, mas é bom manter para versões mais antigas.
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        // Se a permissão for negada, tentamos a permissão de fotos (Android 13+)
        status = await Permission.photos.request();
        if (!status.isGranted) {
          throw Exception('Permissão para salvar imagens negada');
        }
      }

      late Uint8List imageBytes;

      if (widget.imageUrl.startsWith('data:image')) {
        final base64Data = widget.imageUrl.split(',')[1];
        imageBytes = base64Decode(base64Data);
      } else {
        final response = await http.get(Uri.parse(widget.imageUrl));
        imageBytes = response.bodyBytes;
      }

      // Uso do pacote 'image_gallery_saver' para salvar a imagem
      final result = await ImageGallerySaver.saveImage(imageBytes);

      if (result['isSuccess'] != true) {
        throw Exception('Falha ao salvar imagem na galeria');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem salva na galeria com sucesso!')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao salvar imagem: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/shared_image.jpg').create();

      if (widget.imageUrl.startsWith('data:image')) {
        final base64Data = widget.imageUrl.split(',')[1];
        await file.writeAsBytes(base64Decode(base64Data));
      } else {
        final response = await http.get(Uri.parse(widget.imageUrl));
        await file.writeAsBytes(response.bodyBytes);
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Imagem gerada com IA a partir do prompt: ${widget.prompt}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao compartilhar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text('Imagem Gerada'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareImage,
                ),
              ],
            ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isFullScreen = !_isFullScreen;
          });
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: widget.imageUrl.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(widget.imageUrl.split(',')[1]),
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Erro ao carregar imagem',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
              ),
              if (!_isFullScreen)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Prompt: ${widget.prompt}',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveImage,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.download),
                                  label: const Text('Salvar'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isFullScreen = true;
                                    });
                                  },
                                  icon: const Icon(Icons.fullscreen),
                                  label: const Text('Tela Cheia'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isFullScreen)
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.fullscreen_exit,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
