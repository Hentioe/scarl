defmodule Bot.Router.HelpRouter do
  @moduledoc """
  Bot help 指令路由器
  """
  alias Nostrum.Api
  import Nostrum.Struct.Embed
  use Bot.FlagRouter
  alias Bot.{Consumer}

  init_flag(:help)

  def handle_flag(args, msg) do
    message =
      if length(args) > 0 do
        gen_func_help_msg(hd(args))
      else
        title = "欢迎使用 SCAR-L 机器人，这里是帮助信息"
        [prefix_name, _] = Consumer.get_prefix_name()
        [invoke_mark, _] = Consumer.get_invoke_mark()
        prefix_invoke = "#{prefix_name}#{invoke_mark}"

        gen_info_field = fn embed ->
          content = "
** 程序版本 **: alpha
** 上次重启 **: #{Consumer.get_last_restart_date()}　
          "
          put_field(embed, "运行时", content <> "\n")
        end

        gen_feature_field = fn embed ->
          content = "
** #{prefix_invoke}welcome ** (进服通知)
** #{prefix_invoke}clean** (消息清理)
** #{prefix_invoke}records** (战绩查询)
** #{prefix_invoke}help** (功能帮助)
        "

          put_field(embed, "功能列表", content <> "\n")
        end

        gen_opensource_field = fn embed ->
          content = "
** 作者 **: Hentioe_Cl#0120
** 代码 **: https://github.com/Hentioe/scarl
** 许可 **: MIT
"
          put_field(embed, "开源信息", content <> "\n")
        end

        embed =
          %Nostrum.Struct.Embed{}
          |> put_title(title)
          |> put_color(6_271_715)
          |> gen_info_field.()
          |> gen_feature_field.()
          |> gen_opensource_field.()
          |> put_footer(
            "您可以使用 '#{prefix_invoke}help [功能名称]' 查看具体功能的详细用法以及指令示例",
            Consumer.gen_avatar_url(msg.author)
          )

        [embed: embed]
      end

    Api.create_message(msg.channel_id, message)
  end

  def gen_func_help_msg(func_name) do
    case func_name do
      "welcome" ->
        "
`welcome` 功能的目的是为每一个进服的小伙伴发去一个附带@的欢迎消息，还可以用于向新人阐述服务器规则。
        "
        |> String.trim()

      "records" ->
        "
`records` 指令用于查询 PUBG 战绩，它按顺序支持三个参数（可都省略，有默认值）：
```
1. 用户名，无大小写区分，默认值：Discord 昵称
2. 游戏模式，fpp/tpp，默认值：tpp
3. 服务器，as/sea/na，默认值：as
```
指令结构：`scar.records [用户名] [游戏模式] [服务器]`，举例：`scar.records shroud fpp na`
        "
        |> String.trim()

      "help" ->
        "使用 help 功能查询 help 的用法是无效的，请直接使用 `scar` 指令"

      _ ->
        "您要咨询的 #{func_name} 功能无效，是不是输入错了？"
    end
  end
end
