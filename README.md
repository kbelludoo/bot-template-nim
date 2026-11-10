# bot-template-nim ⚡

Template mestre canônico para desenvolvimento de bots de jogos idle em **Nim 2.2** com modelo de memória ORC (`--mm:orc`).

## Arquitetura & Resiliência
- **Worker Supervisor & Auto-Recovery:** Padrão estilo Erlang/OTP onde cada conta roda de forma isolada. Se uma task quebrar por erro transitório ou fatal, o supervisor reinicia automaticamente a rotina da conta com backoff exponencial e jitter.
- **Watchdog Assíncrono:** Monitor global de pulso (`lastHeartbeat`) que detecta stalls de rede ou sockets congelados (sem resposta há mais de 45s) e alerta no dashboard.
- **Circuit Breaker:** Proteção contra bloqueios de rede com recuo exponencial e desarme automático por conta.
- **Pacing Orgânico & Jitter:** Variação gaussiana ($\pm 20\%$) e atrasos de clique humanos (300ms–650ms).
- **Servidor HTTP & Telemetria:** Endpoints `/api/status`, `/status.json` e Web Dashboard com contadores de `restarts` e status em tempo real.
- **Shutdown Gracioso:** Captura de sinais do SO via `std/exitprocs`.

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
