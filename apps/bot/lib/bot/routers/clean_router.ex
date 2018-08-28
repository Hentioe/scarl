defmodule Bot.Router.CleanRouter do
  @moduledoc """
  Bot clean 指令路由器
  """
  alias Nostrum.Api
  use Bot.FlagRouter

  init_flag(:clean)

  @author_id "379265518907162637"
  def handle_flag(args, msg) do
    cond do
      Integer.to_string(msg.author.id) != @author_id ->
        Api.create_message(msg.channel_id, "您没有权限使用删除指令，因为它的风险很高。")

      length(args) == 2 ->
        [user, limit] = args
        limit = String.to_integer(limit)

        user_match =
          (fn ->
             rs = Regex.scan(~r/<@(\d+)>/, user)

             if length(rs) > 0 do
               [[_, id]] = rs
               {:id, id}
             else
               [[_, nickname, discriminator]] = Regex.scan(~r/@([^#]+)#(\d+)/, user)

               {:username_discriminator, nickname, discriminator}
             end
           end).()

        mached_msg_author? = fn user_msg ->
          case user_match do
            {:id, id} ->
              Integer.to_string(user_msg.author.id) == id

            {:username_discriminator, username, discriminator} ->
              user_msg.author.username == username &&
                user_msg.author.discriminator == discriminator
          end
        end

        if_same_id_execute_delete = fn user_msg ->
          if mached_msg_author?.(user_msg) do
            Api.delete_message(user_msg)
          else
            :ignore
          end
        end

        {:ok, msg_list} = Api.get_channel_messages(msg.channel_id, limit + 1)

        gen_response_result = fn results ->
          executed_count = Enum.count(results, &(&1 != :ignore))
          deleted_count = Enum.count(results, &(&1 == {:ok}))
          error_count = Enum.count(results, &([&1][:error] != nil))

          resp_content =
            "扫描 #{length(results)} 条消息，执行删除 #{executed_count} 条消息，实际删除 #{deleted_count} 条消息，删除失败 #{
              error_count
            } 条。"

          resp_content =
            if error_count > 0,
              do: resp_content <> "（出现删除失败可能是网络问题，建议再次输入删除指令清空没删掉的消息）",
              else: resp_content

          resp_content
        end

        msg_content =
          msg_list
          |> Enum.map(if_same_id_execute_delete)
          |> gen_response_result.()

        Api.create_message(msg.channel_id, msg_content)

      true ->
        Api.create_message(msg.channel_id, "您输入的参数不正确！")
    end

    :ignore
  end
end
