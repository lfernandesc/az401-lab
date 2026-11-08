# DevOps Atlas — AZ-401

Portal estático de estudo que integra os 20 laboratórios e as 50 perguntas do guia. Sem backend ou credenciais de serviços. O progresso é guardado em localStorage, por navegador/origem; export/import permitem backup manual. Tentativas em curso ficam apenas em memória; resultados finalizados e notas são persistidos.

## Atualizar conteúdo

Execute `node build-data.mjs` a partir desta pasta. O script lê `../docs/GUIA-COMPLETO-AZ401.md`, valida 20 labs/40 perguntas objetivas/10 cenários e gera `dist/data.js` e `dist/guia-completo.md`. Preserve o formato do guia ou ajuste o parser. Publique a pasta `dist`.

## Uso local

Sirva `dist` com um servidor HTTP estático (por exemplo `python -m http.server 4173 --directory dist`) e abra `http://localhost:4173`. Os recursos principais são locais; fontes Google são opcionais e têm fallback. Não há integração live com Azure ou GitHub. Simulações e pendências continuam identificadas no conteúdo.

## Questionário

Prática: correção após cada resposta, bloqueada depois da validação. Simulado: gabarito só ao finalizar todas as 40 respostas. Ambos registam resultado e tempo decorrido. Cenários 41–50: resposta livre e comparação com modelo, sem pontuação automática. A meta de 80% não equivale à escala Microsoft.

