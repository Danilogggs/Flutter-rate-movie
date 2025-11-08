# Rate My Movie (Flutter)

Aplicativo Flutter que permite **buscar filmes (TMDb)**, **ver detalhes** e **manter uma lista pessoal** de filmes assistidos com **avaliações**.
Inclui **acessibilidade (a11y)**, **validações com regex**, **autenticação com Firebase (Opção Avançada A)** com **Esqueci minha senha** e **persistência por usuário** (Firestore). Também há **modo local** (sem Firebase), salvando dados por usuário via `shared_preferences`.

## Requisitos Atendidos (MVP)
- RF01: Login, Cadastro (com foto de perfil por câmera/galeria), persistência local (modo local) e opção de autenticação real via Firebase (opção avançada).
- RF02: Tela de Perfil exibe nome e foto.
- RF03: Tela de Busca TMDb (TextField + lista).
- RF04: Tela de Detalhes com avaliação e salvar em lista pessoal.
- RF05: Tela “Meus Filmes Assistidos” por usuário, estado global com Provider.
- RF06: Persistência por usuário: no **Firebase** (Cloud Firestore) ou no **modo local** (shared_preferences).
- RF07: Acessibilidade: rótulos descritivos, alt text, foco lógico e alvos de toque mínimos (~48px).

## Opção Avançada A (Firebase)
- Autenticação com `firebase_auth` (e-mail/senha).
- “Esqueci minha senha” funcional (envio de e-mail).
- Persistência na nuvem (`cloud_firestore`): lista por usuário.
- *Obs.:* Foto de perfil fica armazenada localmente por simplicidade; você pode evoluir para Firebase Storage depois.

## Configuração Rápida
1) **Requisitos de Ambiente**
   - Flutter 3.22+ e Dart 3.3+
   - Android SDK / iOS toolchain
   - VS Code ou Android Studio

2) **TMDb**
   - Crie uma chave em https://www.themoviedb.org/ (grátis).
   - Renomeie `.env.sample` para `.env` e preencha `TMDB_API_KEY`.

3) **Modo Firebase (recomendado)**
   - Renomeie `.env.sample` para `.env` e deixe `USE_FIREBASE=true`.
   - No Firebase Console:
     - Crie um projeto, adicione app Android e/ou iOS e Web.
     - Habilite **Authentication > E-mail/Senha**.
     - Crie o Firestore em modo production e mantenha regras adequadas (exemplo simples):
       ```
       rules_version = '2';
       service cloud.firestore {
         match /databases/{database}/documents {
           match /watched/{userId}/entries/{docId} {
             allow read, write: if request.auth != null && request.auth.uid == userId;
           }
         }
       }
       ```
     - Baixe e adicione os arquivos de configuração (Android: `android/app/google-services.json`, iOS: `ios/Runner/GoogleService-Info.plist`).
     - Para Web, registre o app e copie a config em `web/index.html` se necessário (FlutterFire CLI pode automatizar).

   - **Inicialização Firebase**
     - Rode `dart pub global activate flutterfire_cli`
     - Execute `flutterfire configure` no diretório do projeto e siga o wizard.
     - Isso ajustará `firebase_options.dart` automaticamente.

4) **Modo Local (sem Firebase)**
   - Em `.env`, defina `USE_FIREBASE=false`.
   - Autenticação e dados ficam em `shared_preferences` (simula multiusuário).

5) **Instalação**
   ```bash
   flutter pub get
   flutter run
   ```

## Variáveis de Ambiente
- `TMDB_API_KEY`: sua chave do TMDb.
- `USE_FIREBASE`: `"true"` ou `"false"` (string).

## Estrutura (principais)
- `lib/main.dart`: bootstrap + carregamento .env + inicialização condicional Firebase.
- `lib/app.dart`: MaterialApp + rotas.
- `lib/models/*`: modelos Movie, WatchedEntry, UserProfile.
- `lib/services/*`: TMDb API, Auth (Firebase/local), Storage (Firestore/local), utilidades de imagem.
- `lib/providers/*`: AuthProvider, MoviesProvider.
- `lib/screens/*`: Login, Cadastro, Esqueci Senha, Perfil, Busca, Detalhes, Meus Filmes.
- `lib/utils/validators.dart`: regex de e-mail/senha e helpers.
- `lib/widgets/movie_card.dart`: card com a11y.

## Acessibilidade
- `Semantics` + `excludeSemantics/label` em widgets importantes (botões de ícone, imagens com alt text).
- Tamanho mínimo dos alvos interativos ~48px (Material padrão do Flutter).

## Observações
- Para publicar, gere ícones e assine o app conforme a plataforma.
- Para foto de perfil, armazenamos o **caminho local**; sincronia em múltiplos dispositivos pode ser evoluída com Firebase Storage.

Bom uso! ;)
