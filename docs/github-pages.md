# Publicar no GitHub Pages

O jogo já está exportado para a pasta `site/` e não precisa de servidor. O workflow em `.github/workflows/pages.yml` envia essa pasta para o GitHub Pages sempre que houver push na branch `main`.

## Passos no GitHub

1. Crie ou abra um repositório GitHub para este projeto.
2. Envie o conteúdo do projeto para a branch `main`, incluindo `site/` e `.github/workflows/pages.yml`.
3. Abra **Settings → Pages** e selecione **GitHub Actions** como fonte de publicação.
4. Aguarde a execução do workflow `Deploy Pastelaria do Bairro`.
5. O GitHub mostrará a URL pública em **Settings → Pages** e também no resumo da execução.

O jogo é offline e não usa login, banco de dados nem variáveis secretas. Se o repositório for publicado como projeto público, o endereço normalmente ficará no formato `https://usuario.github.io/repositorio/`.

A action de deploy usa o artefato oficial do GitHub Pages e as permissões mínimas de `pages: write` e `id-token: write`.
