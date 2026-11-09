# bot-template-nim ⚡

Template mestre canônico para desenvolvimento de bots de jogos idle em **Nim 2.2** com modelo de memória ORC (`--mm:orc`).

## Arquitetura
- **Supervisor Multi-Conta:** Execução assíncrona isolada via `asyncdispatch`.
- **Circuit Breaker:** Proteção contra bloqueios de rede com recuo exponencial e desarme automático.
- **Pacing Orgânico & Jitter:** Variação gaussiana ($\pm 20\%$) e atrasos de clique humanos (300ms–650ms).
- **Servidor HTTP & Telemetria:** Endpoints `/api/status`, `/status.json` e Web Dashboard inline.

## Compilação Cruzada (Linux x86_64 via Zig)
```powershell
nim c --os:linux --cpu:amd64 --gcc.exe:zigcc-linux-gnu.bat --gcc.linkerexe:zigcc-linux-gnu.bat -d:ssl -d:release -o:bot-template-linux-nim main.nim
```
