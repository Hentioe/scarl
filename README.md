# Scarl

````
                                                                                                    
                                 .`                                       .:`                       
                                 +:                                       -s.                       
                            ``.-:hys+...................................-.-+                        
   ``           `.-::://///++oyhddyyyysssssssyyyyyyyyyyyyyyyyyyysyysyyssyo+s./-  `                  
   :++:::///////yyssssssssyyydyhysooooooooossssssssssooooooooossssssooooos/+/+-.-+-........--:-:-   
   :shyyyyyyyyyyhhhhhhyyyyyhhdhhhhhhhhhhhhdmdddhhhhhddhyhyyyyhdhhhhhhhhhhs/:--:://:::::::::+/+/+/   
   .sdyyyyyhyyyyyhhhhhhhhhhhhhhhhddddddddhhddddhhhhhho:.+oooooooooooooso+.                          
   `sdhhhhy:......----------------/dmdddyhyyydddhhhh+                                               
   `sdhyhy-                       `ohddh./` `ohhyyyy/                                               
   .sdhhy.                       .+syyo+..```/hdhhhd-                                               
   -ydhs.                       :oyyyo`      `hdhhhd/                                               
   -/:.                       ./syhh:         yhhhhds                                               
                              .:+oo/          :hhyhhh:                                              
                                               yhhhyy+                                              
                                               .-.`                                                 
                                                                                                    
````

**SCAR-L Discord 机器人**

SCAR-L 机器人有多个功能，一方面为了增强 Discord 服务器管理，另一方面则是为游戏服务。
使用 SCAR-L 查询 PUBG 战绩示例：

```
scar.records shroud fpp na
```

上面查询了 shroud 在 FPP 模式下 NA 服务器的战绩数据，它会响应你一个 Embed 消息，列出你在各个模式下的统计数据。

如果你懒得输入参数也不要紧，因为它们都有默认值。例如你可以直接输入 `scar.records`，它相当于：


```
scar.records [Discord 昵称] fpp as
```

游戏名默认为 Discord 用户的显示昵称，模式默认为 FPP，服务器默认为 AS。

更多功能，将 SCAR-L 邀请进来一探究竟！

附加：SCAR-L 的数据来源于第三方平台，会对第三方平台的数据进行合并与统计计算，但会标注来源：）

## TODO(1.0)

* [x] PUBG 战绩查询
* [x] 新人进服提醒(未公开)
* [x] 批量消息清理(未公开)
* [x] 功能配置持久化
* [ ] 国际化支持

## TODO(2.0)
* [ ] WEB UI 后台管理
