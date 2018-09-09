defmodule Bot.Router.WelcomeRouter do
  @moduledoc """
  Bot welcome 指令路由器
  """
  alias Nostrum.Api
  use Bot.FlagRouter
  alias Storage.Repo.{Welcome}

  init_flag :welcome

  @author_id 379_265_518_907_162_637
  def handle_flag(args, msg) do
    if msg.author.id == @author_id do
      set_welcome(Enum.join(args, " "), msg)
    else
      Api.create_message(msg.channel_id, "您没有权限使用这个指令。")
    end
  end

  def set_welcome(tpl_text, msg) do
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

# 热烈欢迎新人 ^at_user^ 来到这里！我是由 ^at_author^ 所开发的^  ^专属此服务器的机器人<^bot_name^>^  ^
