defmodule Pubg.Records.Struct do
  defstruct [
    # 评分
    :rating,
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

  def create(props) when is_map(props) do
    rating = props["rating"]
    assists_sum = props["assists_sum"]
    damage_dealt_avg = props["damage_dealt_avg"]
    deaths_sum = props["deaths_sum"]
    headshot_kills_sum = props["headshot_kills_sum"]
    kills_max = props["kills_max"]
    kills_sum = props["kills_sum"]
    longest_kill_max = props["longest_kill_max"]
    matches_cnt = props["matches_cnt"]
    rank_avg = props["rank_avg"]
    time_survived_avg = props["time_survived_avg"]
    topten_matches_cnt = props["topten_matches_cnt"]
    win_matches_cnt = props["win_matches_cnt"]

    %__MODULE__{
      rating: rating,
      assists_sum: assists_sum,
      damage_dealt_avg: damage_dealt_avg,
      deaths_sum: deaths_sum,
      headshot_kills_sum: headshot_kills_sum,
      kills_max: kills_max,
      kills_sum: kills_sum,
      longest_kill_max: longest_kill_max,
      matches_cnt: matches_cnt,
      rank_avg: rank_avg,
      time_survived_avg: time_survived_avg,
      topten_matches_cnt: topten_matches_cnt,
      win_matches_cnt: win_matches_cnt
    }
  end
end
