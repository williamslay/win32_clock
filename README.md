# win32_clock
## Foreword
本项目为NJUPT *CS* 专业大三下学期（2022.02-2022.07）的汇编程序设计大作业。由于疫情原因，学校提前了两周来完成位于教学计划任务。故而，位于十七至十八周本学期的汇编程序设计被提前发放至我们，按照计划每周日编写一天。由于本人本学期也在忙于备考考研，无法全心意和抽出充足时间完成本项目，故而code的编写可能会显得仓促。
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

---
## Intorduction
基本功能

- 简单的菜单项，加速键响应
- 闹钟到可以进行闹钟响应
   - 可以设置多个不同的闹钟时间
      - 这里对闹钟数量做出了固定为10的限制，实际上可以扩充数据段以容纳更多
   - 可以增加，删除，修改闹钟时间
      - 实现了一些简单的用户交互反馈机制
- 闹钟可以以音乐进行闹钟响应
   - 可以设置不同的闹钟音乐
      - 内置了四首时长位于1至2分钟的音乐，可于`source`文件夹中找到
   - 闹钟音乐为.exe可执行文件编译内置
- 闹钟具有指针式外观
   - 附带了数字式可以选择
- 闹钟可以执行页面跳转来到作者主页

上述功能均会有一些不足，可见后文[Some Question](#refer-anchor-16)

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
    - 暂时无法解决菜单栏内单选项`cheaked`样式为`radio`选择，参考了相关文档[<sup>9</sup>](#refer-anchor-9)

*ps* 自今日起可能只能忙里偷闲间歇性完成本项目了。

### day8 21/5/22
- 主要成果
    - 完成了两个主要对话框的资源绘制
- 遇见的错误：
    - 开始尝试对话框的设置和窗口交互，参考了相关文档[<sup>10</sup>](#refer-anchor-10)

### day9 22/5/22
- 主要成果
    - 尝试对对话框过程进行处理
- 遇见的错误：
    - 关于时间选择组件`Date and Time Picker Controls(DTP)`，参考了相关文档[<sup>11</sup>](#refer-anchor-11)
    - 用`DTM_GETSYSTEMTIME`消息未能正确获取用户选择的时间，原因暂未知，参考了相关文档[<sup>12</sup>](#refer-anchor-12)。
### day10 23/5/22
- 主要成果
    - 解决了昨天的错误，正确获取了DTP控件的时间。昨天的错误是由于调用函数未正确提供控件的句柄。参考文档[<sup>13</sup>](#refer-anchor-13)
    - 新增闹钟功能相关的按钮，菜单选项，加速键全部完成
- 遇见的错误：
    - 加速键的加载问题：由于加速键发出的指令相对正常指令id有所不同，在eax中增加了`1`的前缀，所以设置加速键消息的时候应当注意丢弃这个前缀，以拿到正常相同的命令id
    - 第二个对话框出现了一些奇怪的加载bug
### day11 24/5/22
- 主要成果
    - 解决了昨天的错误。
    - 删除闹钟功能相关的按钮，菜单选项，加速键全部完成。参考文档[<sup>14</sup>](#refer-anchor-14)

### day12 25/5/22
- 主要成果
    - 修改闹钟功能相关的按钮，菜单选项，加速键全部完成。
- 遇见的错误：
   - 使用`DTM_SETSYSTEMTIME`修改DTP中的时间时，注意对结构体的全部变量的赋值，不可贪图简单不做赋值，这会使得无法正确设置DTP中的时间。
   - 对话框的传参问题。这里注意一些局部变量很难存住某次信息所传的wparam，lparam，与windows实现机制有关，不可知。
### day13 26/5/22
- 主要成果
    - 增加联系作者功能。参考文档[<sup>15</sup>](#refer-anchor-15)
    - 开始尝试增加样式转换功能。
### day14 27/5/22
- 主要成果
    - 基本完成所有预期功能目标，正式1.0版本。
---

<span id="refer-anchor-16">

## Some Question


由于时间和精力有限，所以仍然余留了一些问题或者可以改进提高的部分。

- 关于闹钟的数量限制，可以设置一个较大的数据段存储，然后在程序中给出设置限制大小标的的入口
- 关于菜单栏对于单选的所用的`radio`item的开始状态预选，尚未找到合适的在资源文件中标识的方法，即一开始是没有状态的。可选用的是`cheaked`，但是对于这一项没有找到radio item那么方便的检测函数
- 音乐的播放制造了微软原生支持的`wav`文件格式的播放api，这也是导致最终生成文件过大（46mb）的原因，里面几乎有45mb多的内容都是我的四首音乐，`mp3`的文件以二进制存入资源文件而后调用或者进行一些特殊操作应该是可以解决的，但是这里出于时间问题就不做解决了
- 闹钟的预设时间应该是应该写入注册表或者类似的数据库文件的，以确保可以真的实时响应改动和存储设置的闹钟，这里出于时间问题就不做解决了
- 可以在程序中留出功能接口或者按钮以使用户可以对一些特定的文字进行修改
</span>

---
## Some Words

事实上写到这部分我总觉感慨万千，然而开始撰写这一部分却每又忘言。

自本程序设计项目伊始，我就选择了一条更为艰难的道路，采取有`GDI`支持的win32汇编来完成项目设计，而不是课本所学的dos汇编。这意味着从头开始学很多东西，从编辑工具的配置，到微软的窗口机制，再到gdi设备概念。所有的概念都是陌生的，而且本身由于汇编的过底层以及几乎所有大学的汇编教育均是dos汇编，所以在中文网络环境中这些信息都少的可怜。

在这里，我应当指出，我很多知识都来自于一本上古的win32汇编书籍，作者是罗云斌，好像已经绝版了，但是书的pdf以及源码在网上应该都是可以找到的。但是由于过于古老，书中自己写makefile，利用masm32去做编译的方式被我抛弃，我采用的方式是`vs2019+masm32`

自从配置编译器环境开始，每一个出现的bug或者问题都要花费很大的力气去寻找解决方案，从msdn文档到stackoverflow，一个简单的问题解决往往耗费大量时间。并且由于msdn文档是面向c++的文档，许多函数的调用，传参，回调值的判断在底层的汇编来讲都是模糊不清的，这导致只能一个个去试，去脑补其中的运行机制，其中困难，也只有自己亲历才可知。

虽然整个代码的长度不多，实现的功能也极为简陋，我常常整天整天地查找问题，从只言片语中推测过程逻辑。开头也异常艰难(如你所见，我光是配置环境就花掉了一天半),整个开发过程可以讲是把该踩的坑一个不漏的全部踩了一遍。甚至有时候出了bug，我都不知道怎样去查找和我一样问题的情况（2022年了，写win32汇编的属实是屈指可数）。这个过程是孤独又痛苦的。

现如今，回过头来看所写出的程序，这无疑是一个我写过的功能最简单的程序了，但确实又是一个我实现起来过程异常艰辛的一个程序。很多的概念和实现都是从底层的汇编角度来完成，虽然微软提供了类似于.if这样的语法糖，但是很多时候的我都得从底层角度来重新完成许多高级语言轻轻松松就可以实现的功能。我开始逐步体会到一些程序员对汇编的描述，你是真正自由的，这里没有面向过程，面向对象，没有数组和指针，你可以自由的操纵每一个数据块和代码块。但是这种自由就又意味着很多熟知的方法概念得依靠原始的少量的指令集重构，意味着没有快捷的语法糖，意味着你得时刻关注寄存器里的存值，你在数据段放的偏移值是否又飞了。

在win32汇编里多了很多相比于dos汇编更进一步的概念，也逐步更加靠近一些现在熟知的方式和规则。我感觉经此一次编程过程，我对计算机底部的运行机制更加的熟悉，也更加深刻地理解了一些自编程之初就被教导过的一些简单概念，或者，称之为基础。于是，虽然这个过程是痛苦的，但是如果让我重新选择，我依然会选择这一方式。

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

-[7] [win32应用 -Fonts and Text](https://docs.microsoft.com/en-us/windows/win32/gdi/fonts-and-text)
</span>
<span id="refer-anchor-8">

-[8] [windows函数库 -PlaySound](https://docs.microsoft.com/zh-cn/windows/win32/multimedia/playing-wave-resources)
</span>
<span id="refer-anchor-9">

-[9] [windows函数库 -CheckMenuRadioItem](https://docs.microsoft.com/zh-CN/previous-versions//dd743680(v=vs.85))
</span>
<span id="refer-anchor-10">

-[10] [windows函数库 -dialogboxparama](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-dialogboxparama)
</span>
<span id="refer-anchor-11">

-[11] [win32应用-About Date and Time Picker Controls](https://docs.microsoft.com/en-us/windows/win32/controls/date-and-time-picker-controls)
</span>
<span id="refer-anchor-12">

-[12] [windows函数库-GetSystemTime function](https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemtime)
</span>
<span id="refer-anchor-13">

-[13] [windows函数库-GetDlgItem function](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdlgitem)
</span>
<span id="refer-anchor-14">

-[14] [win32应用-List Box](https://docs.microsoft.com/en-us/windows/win32/controls/list-boxes)
</span>
<span id="refer-anchor-15">

-[15] [win32函数库-ShellExecute](https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecutea)
</span>

