# eyewish
The SSVEP system repo by conanplus


# windows10 64位  安装

* WinRAR
`
https://www.cnblogs.com/sixuwuxian/p/12512803.html#%EF%BC%882%EF%BC%89%E8%A7%A3%E5%8E%8B%E6%96%87%E4%BB%B6
`
* matlab

* 还需安装phychtoolbox  和 eeglab
`https://blog.csdn.net/nvsirgn/article/details/96858035`

* phychtoolbox  
`https://blog.csdn.net/weixin_40521823/article/details/83270065`
`https://sccn.ucsd.edu/eeglab/downloadtoolbox.php`


* gtec
安装  g.NEEDaccess Server V1.16.00
安装  g.Recorder 5.16.00
安装加密狗驱动 sentinel HL 的驱动SDK

gtec硬件有三部分。
加密狗（长的像u盘，插进电脑usb接口，安装驱动后会亮红灯）
base station usb接口 插在电脑上 会有蓝灯慢闪的提示。
headset 要长按两次power按钮   直到青蓝色的灯慢闪  才能进行连接。串口先不需要使用。（没有串口线）
（headset 需要使用无线充电，无线充电器可用，线和插头有讲究，无线充电器插电后会有蓝色指示灯，headset放置在空白面，充电中会有指示灯蓝色）

gtecorder 的 管理员密码不需要输入 直接点ok即可。
数据存储目录：C:\Users\[USERNAME]\Documents\gRecorder
C:\Users\[USERNAME]\Documents\gRecorder
.hdf5数据格式。

系统：
刺激端
采集端（硬件、驱动、软件）
处理端（数据来源、数据格式、离线、在线）

https://blog.csdn.net/weixin_42014622/article/details/82227236

https://blog.csdn.net/weixin_42675785/article/details/116134687
打开控制中心——>程序——>程序与功能——>启用或关闭windows功能——>勾选.NET Framework 3.5



使用matlab2015和gtec的时候每次都要去c盘programfiles下面把gtec的路径添加进来。recorder和sever软件都不能打开。


bluebci 使用 两个 matlab2020. recorder 要打开。


* 串口软件：SSCOM
清空：---
查询串口的采样率：AT+ACK_FRE=？
设置串口的采样率：AT+ACK_FRE=1000

cmd代码：
ping 192.168.28.170 -t
ping 192.168.28.60 -t


