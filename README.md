# win32_clock
## Foreword
本项目为NJUPT *CS* 专业大三下学期（2022.02-2022.07）的汇编程序设计大作业。由于疫情原因，学校提前了两周来完成位于教学计划任务。故而，位于十七至十八周本学期的汇编程序设计被提前发放至我们，按照计划每周日编写一天。由于本人本学期也在忙于备考考研，无法全心意和抽出充足时间完成本项目，故而code的编写可能会显得仓促。具体完成度视最终结果。
`本项目编写采取win32汇编语言`

---
## Demand
**题目描述：**
利用PC 系统机资源，采用汇编语言的程序设计方法，实现可以在显示器上显示时、分、
秒的电子时钟，并能提供整点报时的功能。
###
**基本要求：**
1. 设计一个基本的具有显示时、分、秒的电子时钟。
2. 到整点或预定的报警时间，能够以不同的音乐进行报时，可以自行设置闹钟报警时
间；
3. 实物演示时要求讲出程序原理和设计思想；
4. 程序运行良好、界面清晰。
###
**提高要求：**
设计一个具有钟面、分针、秒针的指针式钟表，在圆盘上有均匀分布的60 根刻度，对
应小时的刻度用不同颜色的长刻度区别，并且将12、3、6、9 对应的拉丁文绘制于表盘外。
###
**设计提示：**
1. 指针式钟表的绘制。将屏幕设置成图形显示方式，通过画点、画线，画圆等基本程
序完成钟表的绘制。表盘圆周上刻度线段两端点坐标计算是钟表绘制的核心部分。
2. 秒针、分针、时针的转动。是经过一定的延时时间，通过在下一位置重新画一个，
在原来的位置用背景色覆盖的方法实现。
3. 音乐的演奏。利用PC 系统机的外围8254 与8255A 相关电路，通过程序设计改变8255A
的PB0，PB1 口，接通或关闭扬声器，使得计算机能够发出声音。还可以通过程序改变8254
的2 号计数器的计数初值，从而改变OUT2 端的输出信号频率，来控制扬声器的发声音调。
通过建立适当的延时程序达到一定时间后改变2 号计数器产生的方波的频率，实现音乐程序
的演奏。

---
## Timeline

### day1  20/4/22
- 主要成果：完成部分了vs2019的win32汇编环境配置，配置过程参考了博文[<sup>1</sup>](#refer-anchor-1)

- 遇见的错误：
   - 错误	A2044	invalid character in file 

### day2  24/4/22
- 主要成果 
   - win32汇编环境配置完成。
   - 相应的位图，Ico等资源的查找
   - resedit 的配置以及使用（这里使用该工具是出于一个教学视屏推荐，后发现无需时使用该工具）
- 遇见的错误：
   - 错误 A2044	invalid character in file - 使用masm32时由于库自身的bug原因，项目的命名以及安装路径中`不能含有空格！！！`
   - 错误 A2026 constant expected winextra.inc 11052行和11053行 -高于14.26.28801的msvc工具集编译不了`masm32v11r`环境的汇编，通过补增一个低版本的msvc工具即可解决[<sup>2</sup>](#refer-anchor-2)
   - resedit 缺少相应的lib库，经过试验，为vc++6.0的lib库支持。

### day3 1/5/22
- 主要成果 
   - 完成了图标和菜单栏以及部分加速键的编辑配置。
- 遇见的错误：
   - 实际上经过摸索，根本不需要resedit 的资源编辑。vs2019本身就提供了极其优秀的可视化`.rc文件编程器`。它的使用及上手异常简单，这里不再赘言。`应当注意:`vs2019自动生成的resorce.h里用的编号是十进制，而汇编里需要使用的是16进制，否则考虑导致窗体无法找到正确的资源文件。
### day4 8/5/22
- 主要成果 
   - 完成了时钟面的绘制
   - 完成了基本的时钟响应机制
- 遇见的错误：
   - 由于动态计算窗口和时钟位置过于繁复，故采取了固定的的winstyle。这里需注意`CreateWindowEx`函数的多参数写法
   - 计算设定时间和所需的时间的转换方式应当注意type的转换和寄存器位数的提升
### day5 14/5/22
- 主要成果
   - 完成了对存储定时时间数组的初始化，增加，删除的接口函数
   - 初始了解窗口间信息传递机制，试验性的完成了一个button的功能,参考借鉴为[<sup>3，4</sup>](#refer-anchor-34)
   - 综上，定时机制完全完成，后需要界面介入
- 遇见的错误：
   - 传参过程间对操作数寻址的操作，需要对操作数的加减倍乘操作需要通过运算完成，而使用`+,-,*,\`的快捷运算会涉及到地址的变换，无法实际操作到数
   - 由于传参的操作是无法指定数据类型的，所以相应的数据对应转换操作都应该借助于常用寄存器完成
### day6 15/5/22
- 主要成果
   - 完成闹钟显示界面，设置删除修改界面待完成
   - 完成了音乐资源的导入和设置
- 遇见的错误：
   - 不同的画文本函数 - DrawText[<sup>5</sup>](#refer-anchor-5)，以及设置定义容器RECT的函数[<sup>6</sup>](#refer-anchor-6)
   - 字体及设备环境相关，如何修改一个待输出字体的字体大小和高度，尚未解决。参考了相关文档[<sup>7</sup>](#refer-anchor-7)
   - 将音乐资源文件（wav）嵌入资源文件，并进行播放，参考了相关文档[<sup>8</sup>](#refer-anchor-8)
### day7 19/5/22
- 主要成果
    - 完成了音乐修改部分
- 遇见的错误：
    - 暂时无法解决菜单栏内单选项`cheaked`样式为`radio`选择，参考了参考了相关文档[<sup>9</sup>](#refer-anchor-9)
---
## References

<span id="refer-anchor-1">

-[1] [汇编环境搭建(vs2010(2012)+masm32)](https://blog.csdn.net/u013761036/article/details/52186683)
</span>
<span id="refer-anchor-2"> 

-[2] [一个Bug解决办法](https://blog.csdn.net/DongMaoup/article/details/120471110)</span>
<span id="refer-anchor-34">

-[3] [windows应用开发-按钮（Windows 控件）](https://docs.microsoft.com/zh-cn/windows/win32/controls/buttons)

-[4] [windows应用开发-控件库](https://docs.microsoft.com/zh-cn/windows/win32/controls/individual-control-info)
</span>
<span id="refer-anchor-5">

-[5] [windows函数库 -DrawText](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-drawtext)
</span>

<span id="refer-anchor-6">

-[6] [windows函数库 -SetRect](https://docs.microsoft.com/zh-CN/windows/win32/api/winuser/nf-winuser-setrect)
</span>
<span id="refer-anchor-7">

-[7] [win32应用 -Fonts and Text](https://docs.microsoft.com/en-us/windows/win32/gdi/string-widths-and-heights)
</span>
<span id="refer-anchor-8">

-[8] [windows函数库 -PlaySound](https://docs.microsoft.com/zh-cn/windows/win32/multimedia/playing-wave-resources)
</span>
<span id="refer-anchor-9">
-[9] [windows函数库 -CheckMenuRadioItem](https://docs.microsoft.com/zh-cn/windows/win32/api/winuser/nf-winuser-checkmenuradioitem?redirectedfrom=MSDN)
</span>
