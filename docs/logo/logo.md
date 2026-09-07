# Especificação de Prompt para IA: Logotipo & Ícone "Qual o Rock?"

Este documento define o prompt oficial para geração e refinamento da identidade visual da plataforma **Qual o Rock?** utilizando ferramentas de IA generativa (como Midjourney, ChatGPT/DALL-E 3 ou Stable Diffusion).

## 1. Contexto do Modelo
* **Plataforma:** Agregador e guia de eventos musicais para a Grande Vitória (Vitória, Vila Velha, Serra e Cariacica).
* **Público-Alvo:** Jovens de 16 a 29 anos (Geração Z e Millennials).
* **Significado Cultural:** A palavra "Rock" no nome refere-se à gíria capixaba para qualquer tipo de festa, show ou rolê. A identidade deve ser plural e abraçar todos os gêneros musicais (Samba, Sertanejo, Eletrônico, Rock, Reggae, etc.).

---

## 2. Prompt Oficial (Inglês)
*Nota: A maioria das ferramentas de IA generativa de imagem entrega resultados significativamente melhores quando o prompt é submetido em inglês.*

> Create a modern, minimalist vector logo and app icon for a multi-genre event discovery platform called "Qual o Rock?". The word 'Rock' is a local Brazilian slang for any party, concert, or nightlife event, so the design MUST NOT use rock n' roll clichés like guitars, skulls, or heavy metal typography. Instead, the icon must feature smooth, rounded, and organic geometry symbolizing exploration, local discovery, or a universal musical beat—such as a rounded location pin merging with a soundwave, or fluid organic shapes that represent gathering and nightlife. The typography for the brand name must be a bold, modern geometric sans-serif like Space Grotesk. Flat design, crisp paths, high contrast. Color palette drawn from a premium dark UI design system: a deep charcoal-navy night background (#0B0D14) with a vibrant, energetic gradient of hot pink (#FF2E7E) and electric blue (#2EC5FF) to represent diversity (pop, samba, electronic, reggae). Highly scalable for a 1:1 mobile app icon and website header. Youthful festival energy (targeting ages 16-29), isolated on a solid white background for presentation.

---

## 3. Diretrizes de Design Aplicadas (Tokens Alinhados)
Para garantir a consistência com o **Design System NIGHTLIFE-GV**, o prompt força as seguintes regras:

* **Geometria:** Formas orgânicas e arredondadas (`--radius-lg: 16px`, `--radius-pill`).
* **Cores Neutras:** Fundo escuro profundo baseado no token `--color-bg-deep` (`#0B0D14`).
* **Cores de Destaque:** Uso combinado de `--accent-pink` (`#FF2E7E`) e `--accent-blue` (`#2EC5FF`) em formato de gradiente para simbolizar a multiplicidade de ritmos.
* **Tipografia:** Estilo geométrico e moderno inspirado na fonte `--text-event-title` (Space Grotesk).
