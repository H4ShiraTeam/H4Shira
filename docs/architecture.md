# Arquitetura técnica

- Scene intent: identifica estilo por paleta, saturação, materiais e nomes contextuais.
- Artistic signature: cria médias por material para localizar outliers visuais.
- Perceptual priority: considera distância, tamanho e centralidade na câmera.
- Runtime budgets: mede frame time e tempo do Lua para ajustar lotes.
- Native budgets: limita luzes locais e partículas distantes usando propriedades públicas.
