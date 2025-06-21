Gerador de Imagens com IA - Projeto Flutter
Este é um aplicativo móvel desenvolvido em Flutter como parte do trabalho do 2º bimestre. O aplicativo permite aos usuários gerar imagens únicas a partir de descrições de texto (prompts) utilizando uma API de Inteligência Artificial.

Vídeo de Demonstração
https://github.com/user-attachments/assets/13503faa-bf49-415a-88d1-3bcaf1306141


✨ Funcionalidades
Geração de Imagens por IA: Digite um prompt de texto e a IA criará uma imagem baseada na sua descrição.

Visualização em Tela Cheia: Visualize a imagem gerada em modo de tela cheia para ver todos os detalhes.

Salvar na Galeria: Salve suas criações diretamente na galeria de fotos do seu dispositivo.

Compartilhamento: Compartilhe facilmente as imagens geradas com amigos ou em redes sociais.

Interface Simples: Uma interface limpa e intuitiva, fácil de usar.

🛠️ Tecnologias Utilizadas
Este projeto foi construído utilizando as seguintes tecnologias e pacotes:

Flutter: Framework principal para o desenvolvimento de aplicativos multiplataforma.

Dart: Linguagem de programação utilizada pelo Flutter.

Hugging Face API: Serviço de backend para a geração das imagens por IA (modelo stabilityai/stable-diffusion-3-medium-diffusers).

Pacotes Flutter:

http: Para realizar as chamadas à API.

image_gallery_saver: Para salvar as imagens na galeria.

path_provider: Para encontrar diretórios do sistema de arquivos.

permission_handler: Para solicitar permissões de armazenamento.

share_plus: Para habilitar a funcionalidade de compartilhamento.

🚀 Como Executar o Projeto
Siga os passos abaixo para compilar e executar o projeto localmente.

Pré-requisitos

Flutter SDK instalado.

Um editor de código como o VS Code ou Android Studio.

Um emulador Android ou dispositivo físico.

1. Clone o Repositório

git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio

2. Instale as Dependências

Execute o seguinte comando no terminal para instalar todos os pacotes necessários listados no pubspec.yaml:

flutter pub get

3. Configure a Chave da API (Token)

⚠️ ATENÇÃO: ESTE PASSO É OBRIGATÓRIO!

O aplicativo precisa de um Access Token (chave de acesso) do Hugging Face para se comunicar com a API de geração de imagens.

Crie uma conta gratuita no site Hugging Face.

Após o login, acesse seu perfil e vá para Settings -> Access Tokens.

Clique em New token, dê um nome a ele (ex: flutter-app-token) e selecione a permissão Read.

Copie o token gerado.

Abra o arquivo lib/services/api_service.dart no seu projeto e cole o seu token na seguinte linha:

// lib/services/api_service.dart

// ...
// IMPORTANTE: Cole aqui o seu Access Token do Hugging Face
final String apiKey = 'COLE_AQUI_O_SEU_TOKEN'; // Substitua pelo seu token real
// ...

4. Execute o Aplicativo

Com o seu emulador aberto ou dispositivo conectado, execute o comando:

flutter run
