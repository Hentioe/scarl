defmodule Bot.Router.WelcomeRouter do
  @moduledoc """
  Bot welcome 指令路由器
  """
  alias Nostrum.Api
  use Bot.FlagRouter
  alias Storage.Repo.{Welcome}

  init_flag :welcome

  def handle_flag(args, msg) do
    msg |> IO.inspect()
    tpl_text = Enum.join(args, " ")

    case Storage.set_welcome(%Welcome{
           server_id: msg.guild_id,
           channel_id: msg.channel_id,
           operator: "#{msg.author.username}\##{msg.author.discriminator}",
           tpl_text: tpl_text
         }) do
      {:ok, _} -> Api.create_message(msg.channel_id, "欢迎模板设置成功～之后新加入的小伙伴将在本频道进行记录！")
      error -> Api.create_message(msg.channel_id, "欢迎模板设置失败！建议联系作者询问原因。错误详情：#{error}")
    end
  end
end
