# bot-template-nim ⚡

Template mestre canônico para desenvolvimento de bots de jogos idle e automação em **Nim 2.2** com modelo de memória ORC (`--mm:orc`).

🌐 **GitHub Pages & Live Telemetry:** [kbelludoo.github.io/bot-template-nim](https://kbelludoo.github.io/bot-template-nim/)

---

## 🌐 A Suíte Completa: Os 18 Bots em Nim

Este template alimenta a suíte de 18 bots de alta performance desenvolvidos em Nim nativo:

| # | Repositório | Descrição / Especialidade |
|---|-------------|----------------------------|
| 1 | [bot-baiak-nim](https://github.com/kbelludoo/bot-baiak-nim) | Baiak Idle MMORPG com Colyseus StateSync e tRPC queries |
| 2 | [bot-tibiaidle-nim](https://github.com/kbelludoo/bot-tibiaidle-nim) | Tibia Idle MMORPG Auto-Hunt com rotação de spots |
| 3 | [bot-pokeidle-nim](https://github.com/kbelludoo/bot-pokeidle-nim) | PokeIdle Auto-Catch e batalhas de safari |
| 4 | [bot-pokeidleworld-nim](https://github.com/kbelludoo/bot-pokeidleworld-nim) | PokeIdle World Multi-Zone e ginásios |
| 5 | [bot-pokelegacy-nim](https://github.com/kbelludoo/bot-pokelegacy-nim) | PokeLegacy Combat Engine em turnos |
| 6 | [bot-pokepixel-nim](https://github.com/kbelludoo/bot-pokepixel-nim) | PokePixel Runner em grade e caça a shinies |
| 7 | [bot-poketrue-nim](https://github.com/kbelludoo/bot-poketrue-nim) | PokeTrue PvP Arena e eventos sazonais |
| 8 | [bot-huntera-nim](https://github.com/kbelludoo/bot-huntera-nim) | Huntera Idle Engine para dungeons e clãs |
| 9 | [bot-lolidle-nim](https://github.com/kbelludoo/bot-lolidle-nim) | LoL Idle Battle estratégico de campeões |
| 10 | [bot-luxidle-nim](https://github.com/kbelludoo/bot-luxidle-nim) | Lux Idle mineração de cristais e crafting |
| 11 | [bot-farmbot-nim](https://github.com/kbelludoo/bot-farmbot-nim) | FarmBot loop de plantio e colheitas cronometradas |
| 12 | [bot-leveling-nim](https://github.com/kbelludoo/bot-leveling-nim) | Leveling Optimizer com maximização de EXP/hora |
| 13 | [bot-kickminer-nim](https://github.com/kbelludoo/bot-kickminer-nim) | Kick Miner com monitoramento de streams e drops |
| 14 | [bot-twitchminer-nim](https://github.com/kbelludoo/bot-twitchminer-nim) | Twitch Miner de Channel Points e baús |
| 15 | [bot-lichess-nim](https://github.com/kbelludoo/bot-lichess-nim) | Lichess Chess Bot com Minimax e aberturas |
| 16 | [bot-restream-nim](https://github.com/kbelludoo/bot-restream-nim) | Restream Multi-Stream orchestration |
| 17 | [bot-sigma-nim](https://github.com/kbelludoo/bot-sigma-nim) | Sigma Engine Worker ultra-rápido de alto TPS |
| 18 | [bot-template-nim](https://github.com/kbelludoo/bot-template-nim) | **Template Mestre Canônico** (este repositório) |

---

## Arquitetura & Resiliência
- **Worker Supervisor & Auto-Recovery:** Padrão estilo Erlang/OTP onde cada conta roda de forma isolada. Se uma task quebrar por erro transitório ou fatal, o supervisor reinicia automaticamente a rotina da conta com backoff exponencial e jitter.
- **Watchdog Assíncrono:** Monitor global de pulso (`lastHeartbeat`) que detecta stalls de rede ou sockets congelados (sem resposta há mais de 45s) e alerta no dashboard.
- **Circuit Breaker:** Proteção contra bloqueios de rede com recuo exponencial e desarme automático por conta.
- **Pacing Orgânico & Jitter:** Variação gaussiana ($\pm 20\%$) e atrasos de clique humanos (300ms–650ms).
- **Servidor HTTP & Telemetria:** Endpoints `/api/status`, `/status.json` e Web Dashboard com contadores de `restarts` e status em tempo real.
- **Shutdown Gracioso:** Captura de sinais do SO via `std/exitprocs`.

---

## Compilação Cruzada (Linux x86_64 via Zig)
```powershell
nim c --os:linux --cpu:amd64 --gcc.exe:zigcc-linux-gnu.bat --gcc.linkerexe:zigcc-linux-gnu.bat -d:ssl -d:release -o:bot-template-linux-nim main.nim
```

## Compilação Local (Windows)
```powershell
nim c --mm:orc -d:release main.nim
```

## Auto-Recovery no Sistema Operacional (systemd)
Copie o arquivo `nim-bot.service` para `/etc/systemd/system/`:
```bash
sudo cp nim-bot.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now nim-bot
```
