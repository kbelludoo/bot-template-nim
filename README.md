# ⚡ Game Bot Starter Kit & Command Center (Nim Native Engine)

Template padronizado de altíssima performance desenvolvido em **Nim 2.2 nativo (Zero-GC ORC)** para bots autônomos de jogos de navegador / idle com consumo de memória ultra-reduzido (~1 a 4 MB de RAM).

Transposto fielmente com **100% de paridade estrutural e arquitetural** a partir dos ecossistemas de referência `bot-template-rust` e `bot-template-go`.

🌐 **GitHub Pages Dashboard:** [https://kbelludoo.github.io/bot-template-nim/](https://kbelludoo.github.io/bot-template-nim/)

---

## 🌟 Arquitetura & Paridade Completa

### 1. Engine (`src/engine/`)
- ⚡ **Zero-GC ORC (`--mm:orc`):** Alocações determinísticas e liberação instantânea de memória, sem pausas de Garbage Collector.
- 🛡️ **Anti-Ban Circuit Breaker (`src/engine/circuit_breaker.nim`):** Disjuntor automático que detecta erros 429, 403 e recusas heurísticas com recuo exponencial e desarme progressivo (5m a 1h).
- 💤 **Auditoria de Stamina & Fadiga (`src/engine/stamina.nim`):** Controlador de histerese anti-thrashing com suporte a fadiga percentual (0% a 100%) e stamina decrescente (42h a 0h).
- 🧩 **Preservação de Schema Bruto (`src/engine/overlay.nim`):** `StateOverlay` preserva campos desconhecidos do envelope do servidor, prevenindo rejeições por save malformado.
- 🎯 **Pacing Orgânico & Jitter (`src/engine/pacing.nim` / `src/engine/stealth.nim`):** Variação gaussiana ($\pm 20\%$) e atrasos humanos orgânicos (300ms a 650ms).
- 🔄 **Worker Supervisor com Auto-Recovery (`supervisor.nim`):** Supervisão estilo Erlang/OTP onde cada worker reinicia automaticamente sob falhas de rede.

### 2. Networking Resiliente (`src/network/`)
- 🌐 **Cliente HTTP com Stealth (`src/network/client.nim`):** Injeção de cabeçalhos desktop realistas (`sec-ch-ua`, User-Agent, Accept-Language).
- 🔑 **Assinador HMAC & Sharding (`src/network/signer.nim`):** Idempotência UUIDv4 nativa e particionamento hash DJB2.
- 🔌 **WebSocket Resiliente (`src/network/socket.nim`):** Cliente de socket assíncrono com reconexão automática.

### 3. Suíte Multi-Protocolo (`src/protocol/`)
- 📦 **Varint & Protobuf (`src/protocol/binary.nim`):** Decodificador Varint, Zigzag e tags Protobuf com zero-alocação.
- 🔄 **tRPC v10 Batch (`src/protocol/trpc.nim`):** Formatador de batch `{"0":{"json":...}}` e unwrap automático de respostas.
- 🎮 **Colyseus StateSync (`src/protocol/colyseus.nim`):** Parser de `OpJoinRoom` (10) e codificador de `OpRoomData` (13).
- 💬 **Socket.IO v4 (`src/protocol/socketio.nim`):** Parser de pacotes Engine.IO / Socket.IO v4.

### 4. Autenticação & Solver Relay (`src/auth/`)
- 🕵️ **Descoberta de Navegador (`src/auth/cdp_ticket.nim`):** Localização automática de binários Chrome/Chromium/Edge/Brave.
- 🔁 **Relay de Solver (`src/auth/relay.nim`):** Extração de URL de túneis Cloudflare e acionamento via GitHub Actions.
- 🛡️ **Scripts Anti-Detecção (`src/auth/stealth_hook.nim`):** Remoção de `navigator.webdriver` e interceptação de Turnstile.

### 5. Subsistemas Autônomos (`src/subsystem/`)
- 🗺️ **`RouteSolver` (`src/subsystem/solver.nim`):** Seleção dinâmica da melhor rota de caça por nível de personagem.
- 🎒 **`InventoryManager` (`src/subsystem/inventory.nim`):** Auto-sell de lixo ao atingir $\ge 80\%$ de ocupação da mochila.
- 📅 **`DailyManager` (`src/subsystem/dailies.nim`):** Resgate automático de recompensas e streaks diários na virada UTC.
- 🧪 **`PotionManager` (`src/subsystem/potions.nim`):** Otimizador de consumo de poções de vida e mana.
- 🐉 **`BossScheduler` (`src/subsystem/bosses.nim`):** Agendamento e entrada em eventos de World Boss.
- 👑 **`PromotionManager` (`src/subsystem/promotion.nim`):** Upgrade automático de classe e compra de bênçãos.
- 🛡️ **`PartyCoordinator` (`src/subsystem/party.nim`):** Coordenação de grupos, líderes e bônus de EXP.
- 🎁 **`Lurker` (`src/subsystem/lurker.nim`):** Coleta de drops e pontos na Kick e Twitch.

---

## 🚀 Compilação & Execução

```powershell
# 1. Compilar nativo Windows Release
nim c --mm:orc -d:release main.nim

# 2. Compilar binário estático para Linux x86_64 via Zig
nim c --os:linux --cpu:amd64 --gcc.exe:zigcc-linux-gnu.bat --gcc.linkerexe:zigcc-linux-gnu.bat -d:ssl -d:release -o:bot-template-linux-nim main.nim
```
