type
  RouteSolver* = object

proc selectBestHunt*(level: int): string =
  case level
  of 1..15: "Floresta Inicial"
  of 16..30: "Caverna Sombria"
  of 31..50: "Vulcão Ativo"
  of 51..80: "Ilha dos Dragões"
  else: "Santuário Sagrado"
