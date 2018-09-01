defmodule Bot do
  @moduledoc """
  Bot 模块开放 API
  """

  def gen_avatar_url(user, size \\ 64) do
    "#{Nostrum.Struct.User.avatar_url(user)}?size=#{size}"
  end
end
