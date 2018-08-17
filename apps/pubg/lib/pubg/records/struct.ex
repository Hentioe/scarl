defmodule Pubg.Records.Struct do
  @moduledoc false

  defstruct [
    # 评分
    :rating,
    # 评级
    :grade,
    # 杀人率（计算）
    :kda,
    # 爆头率（计算）
    :headshot_ratio,
    # 助攻次数
    :assists_sum,
    # 均场伤害
    :damage_dealt_avg,
    # 死亡次数
    :deaths_sum,
    # 爆头次数
    :headshot_kills_sum,
    # 最多击杀
    :kills_max,
    # 击杀总数
    :kills_sum,
    # 最远击杀
    :longest_kill_max,
    # 匹配次数
    :matches_cnt,
    # 平均排名
    :rank_avg,
    # 生存时间
    :time_survived_avg,
    # 前十次数
    :topten_matches_cnt,
    # 吃鸡次数
    :win_matches_cnt
  ]

  def create(stats, grade) when is_map(stats) do
    rating = stats["rating"]
    assists_sum = stats["assists_sum"]
    damage_dealt_avg = stats["damage_dealt_avg"]
    deaths_sum = stats["deaths_sum"]
    headshot_kills_sum = stats["headshot_kills_sum"]
    kills_max = stats["kills_max"]
    kills_sum = stats["kills_sum"]
    longest_kill_max = stats["longest_kill_max"]
    matches_cnt = stats["matches_cnt"]
    rank_avg = stats["rank_avg"]
    time_survived_avg = stats["time_survived_avg"]
    topten_matches_cnt = stats["topten_matches_cnt"]
    win_matches_cnt = stats["win_matches_cnt"]

    gen_rem_seconds = fn ->
      i = rem(Kernel.trunc(time_survived_avg), 60)

      cond do
        i < 10 -> "0#{i}"
        i < 0 -> "0"
        true -> "#{i}"
      end
    end

    %__MODULE__{
      rating: rating,
      grade: grade,
      kda: Float.round((kills_sum + assists_sum) / deaths_sum, 2),
      headshot_ratio: Float.round(headshot_kills_sum / kills_sum * 100, 1),
      assists_sum: assists_sum,
      damage_dealt_avg: Kernel.trunc(damage_dealt_avg),
      deaths_sum: deaths_sum,
      headshot_kills_sum: headshot_kills_sum,
      kills_max: kills_max,
      kills_sum: kills_sum,
      longest_kill_max: longest_kill_max,
      matches_cnt: matches_cnt,
      rank_avg: Float.round(rank_avg / 1, 1),
      time_survived_avg: "#{Kernel.trunc(time_survived_avg / 60)}:#{gen_rem_seconds.()}",
      topten_matches_cnt: topten_matches_cnt,
      win_matches_cnt: win_matches_cnt
    }
  end

  def gen_records(records) do
    "
**评　　分**：#{records.rating}\n
**评　　级**：#{records.grade}\n
**　　KDA**：#{records.kda}\n
**匹配次数**：#{records.matches_cnt}\n
**前十次数**：#{records.topten_matches_cnt}\n
**吃鸡次数**：#{records.win_matches_cnt}\n
**击杀总数**：#{records.kills_sum}\n
**助攻次数**：#{records.assists_sum}\n
**爆头几率**：#{records.headshot_ratio}%\n
**均场伤害**：#{records.damage_dealt_avg}\n
**最多击杀**：#{records.kills_max}\n
**生存时间**：#{records.time_survived_avg}\n
**平均排名**：\##{records.rank_avg}
    "
    |> String.replace("\n\n", "\n")
    |> String.trim()
  end
end
