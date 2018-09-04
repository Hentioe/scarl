defmodule StorageTest do
  use ExUnit.Case

  import Storage

  alias Storage.Repo
  alias Storage.Repo.{Welcome}

  setup do
    on_exit(fn ->
      Repo.delete_all(Welcome)
    end)
  end

  @server_id 1_234_567_890
  @channel_id 0_987_654_321
  @operator "Hentioe_Cl#0120"
  @tpl_text "^at_user^欢迎来到本服务器！"

  test "welcome" do
    # 设置(添加) Welcome
    {state, welcome} =
      %Welcome{
        server_id: @server_id,
        channel_id: @channel_id,
        tpl_text: @tpl_text,
        operator: @operator
      }
      |> set_welcome()

    assert state == :ok
    assert welcome.server_id == @server_id
    assert welcome.channel_id == @channel_id

    # 查找
    welcome = find_welcome(@server_id, @channel_id)

    assert welcome != nil
    assert welcome.operator == @operator
    assert welcome.tpl_text == @tpl_text

    # 设置(更新) Welcome
    updated_tpl_text = @tpl_text <> ".updated"
    welcome = %{welcome | tpl_text: updated_tpl_text}
    {state, welcome} = set_welcome(welcome)
    assert state == :ok
    assert welcome.tpl_text == updated_tpl_text
  end
end
