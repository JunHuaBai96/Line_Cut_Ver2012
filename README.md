# Line_Cut_Ver20
利用MATLAB插件Linecut实现晶粒尺寸测量

## 测量原理

该插件所依据的原理在Kril的论文中得到详细介绍。Kril等人[1]提出，使用X射线衍射的方法可以较准确地得出晶粒的尺寸分布图（横坐标为晶粒尺寸，纵坐标为出现频率）。Kril与其合作者同时使用X射线衍射（XRD）和透射电子显微镜（TEM）方法对Pd金属的晶粒进行了测量，结果表明，两种测量方法得到的晶粒尺寸结果符合得很好。Kril等人又从数学的角度，推导出晶粒的尺寸分布符合一定的分布函数。其中位置参数中就有平均晶粒尺寸D0。 通过使用该公式对晶粒的尺寸分布进行分布拟合，便可以得到材料的平均晶粒尺寸。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/7d3dc464-aba8-4979-8b37-1eae63ea98e8)


以上所述便是运用该原理进行插件设计，并实现晶粒尺寸测量的主要思路。

晶粒的尺寸分布图及拟合曲线如下图所示。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/0b622a2f-6596-42f4-b785-c0135abccffe)

## MATLAB插件Linecut的下载及运行
MATLAB的使用范围是十分广泛的。在国外，MATLAB的熟练使用是理工科学生的“生存必备技能”之一。

由于MATLAB各个版本的安装方法在其他地方已经较为广泛地讨论了，在这里便不加赘言。

今天要介绍的这款插件也是我在Google搜索“晶粒尺寸测量”的过程中偶然发现的。该插件可以在MathWorks中国的社区中被搜索到，其最后更新日期为2012年。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/d5db3830-69ca-4213-b362-2e0b40b0fc65)

当然我们也可以直接使用Google或百度进行搜索得到其下载链接。其下载和使用都是免费的。

该插件介绍页面上有详细的视频教程。不过该教程使用英文解说，并且存储在Youtube上，除非“渴学尚往”，否则国内网络无法对其进行访问。关于“渴学尚往”的具体方法请大家自行搜索。

如下图，点击“Download”之后我们便可以开始下载其压缩包文件。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/ead10001-3762-4c04-88a6-5dd8a32d0d87)

将压缩包移动至合适位置（笔者会在F盘建立一个MATLAB Toolbox文件夹专门存放MATLAB插件工具），解压至Line_Cut_Ver2012文件夹（默认文件夹名称）。

这时候可以打开MATLAB，将工作目录地址移至Line_Cut_Ver2012文件夹。接下来，笔者会以MATLAB 2016b为例给大家演示。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/e52af5d0-c890-4355-8434-8880e1436827)

实际操作时不一定以本例中地址为准。可以自行设定，只要最后工作目录同下图所示即可。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/05a1747c-152b-40e2-b7e5-5c7573987e7e)

这时候，我们可以在命令行界面输入

GUI_linecut

或者右键单击当前文件夹中的 GUI_linecut.m文件并选择“运行”。这样我们就进入插件主页面了，如下图所示。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/7cec34c8-3af5-4ab4-94f7-1ac3ec84008f)

## Linecut插件的基本使用

打开了插件主页面之后，我们正式进入插件的使用阶段。如上图，大家只需要关注左边的输入即可。接下来，笔者将就一个个的关键选项进行讲解。

### 界面介绍

#### File

选择待分析的图片。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/caf8e19b-a163-4a5d-9a4f-a39ccb8aa7aa)

#### Length of metering bar（比例尺长度）

在这里我们可以选择100μm。如下图中所示。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/1a45c717-977f-4488-99ab-06a82ba7c830)

#### Results directory

图片分析结束后会生成一个数据文件（TXT格式），在这里可以设置其存放地址。建议自己专门存放，并做好标识工作。使用该数据文件可以再次对数据进行重复分析。

当然大家也可以不进行设置，插件会默认勾选“create results-folder automatically”，生成的数据文件也会自动存储到自动生成的文件夹中。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/c864aa82-63e0-4500-b47e-27c0d20ed510)

#### lines

决定了截线的根数，截线越多，统计结果越接近真实结果，但是也会同时增加我们的工作量。所以一般默认5根是足够的。如果统计结果与实际有偏差，则需要适当调整，增加截线数目。

#### L/D（截线修正系数）

等轴晶粒与孪晶修正系数不同。等轴晶粒取值0.79，孪晶取值1。

#### Plot Settings
控制最后输出结果格式，大家可以适当调整。

### 分析步骤

1. 点击工具栏的“放大镜”按钮，将图片放大至只含比例尺，以方便下一步矫正比例尺的操作。如下图所示。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/35b8ff87-b520-4de3-a9c9-bd12f9a93eb5)

2. 点击左边绿色三角形按钮，开始校核比例尺。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/eb611bba-40ac-49ce-be29-e5dacf926d98)

3. 用鼠标单击比例尺两端，弹出对话框中选择“Accept”，完成比例尺矫正。如果仍有不明白的地方可以依照插件右上角的英文提示进行操作。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/69ea4b36-ac7b-47c1-bbce-b0ac1b7126ae)

4. 接下来，用鼠标拖拽出一个矩形选框，可以框选出待分析区域，并双击结束框选。建议选择腐蚀后晶界较为清晰的地方进行分析，并且不要包含比例尺。同样插件右上角的会有英文提示。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/dd04412d-7ac4-4bc0-835f-4985af0577f5)

5. 然后，插件窗口便会弹出画了5根截线的界面。这时候我们就使用鼠标，从最上面一个红色截线开始，从左到右（或者没有顺序的不重复单击），单击每一个晶界所在位置。单击完成后，按下“Enter”键结束一条截线的晶界识别。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/e956f04f-e900-432e-aee5-65014a0ae248)

6. 一条截线上的晶界都逐个单击完成并按下“Enter”键后，会弹出对话框，如果觉得晶界可以接受，便可以选择“Yes”。接下来还需要依次把剩下的4根截线的晶界都单击识别完成。需要注意的是，单击晶界时，光标没有必要完全准确地落在晶界上，光标所在位置横坐标与晶界与截线交点重合即可（光标所在处有辅助“黑色十字”，纵向辅助线跟晶界与截线的交点重合即可）。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/579ec802-38e8-4b6d-9815-836bd73f0d0c)

7. 完成所有截线的晶界识别后，我们可以得到下图。

![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/8c2e06fc-ac44-4c1c-acb7-8084937c8bbc)

其中柱状图为晶粒尺寸分布图，红色实线为拟合曲线。在界面右下角我们能看到输出的参数拟合结果。其中a_mu即平均晶粒尺寸。从图中，我们可看到该值为53.6887，单位为μm（之前设置的）。
​
![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/e7ae4740-2593-465c-a05e-6912ab556f93)
​
在命令行界面我们也可以看到有相应输出。比在插件主界面更好的是，我们还可以得到其拟合后参数的置信区间。
​
![image](https://github.com/JunHuaBai96/Line_Cut_Ver20/assets/102909786/d3ccf143-d709-456e-8157-583dac21c9af)

## 写在后面
有关于利用Linecut插件进行晶粒计数的基本方法和步骤到这里为止，算是告一段落了。

Linecut插件还提供了其他较丰富的功能：将图片旋转一定角度，再进行晶粒尺寸测量（方便轧向、横向和法向这样不同方向晶粒尺寸测量）；通过生成的TXT数据文件绘出柱状统计图，并对其进行分布拟合；通过生成的TXT数据文件做出晶粒分布图的累积分布曲线（CDF曲线），并通过该曲线计算出平均晶粒尺寸。

以上功能都具有其统计意义。因此，相较于一般的截线法对晶粒尺寸进行测量，该测量方法更充分的利用了图片信息，因此得出的结果相应的可能会更具有重复性，更可靠。

## 参考文献
[1]Kril C E, Birringer R. Estimating grain-size distributions in nanocrystalline materials from X-ray diffraction profile analysis[J]. Philosophical Magazine A, 1998, 77(3): 621-640.
