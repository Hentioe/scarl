import Mix.Config

config :bot,
  # 前缀名称(测试环境建议后缀字母t)
  prefix_name: "scar",
  # 功能调用符号
  invoke_mark: ".",
  # 参数分隔符号
  args_split: " ",
  # 游戏状态
  game_status: "scar.help | @Hentioe_Cl"

import_config("./prod.secret.exs")
