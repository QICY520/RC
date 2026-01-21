# RC

## 项目结构总览（青少年 AR 编程原型）

本仓库是一个面向青少年的 AR 编程教学原型，用 Flutter 搭建。下面按目录/文件说明主要职责，方便小组成员快速上手和协作。

---

### 顶层

- **`pubspec.yaml`**  
  - Flutter 项目配置，依赖声明，以及静态资源路径（`assets/images/`）。  
  - 如需新增第三方包或图片资源，先在这里配置再执行 `flutter pub get`。

- **`lib/main.dart`**  
  - 应用入口。  
  - 当前直接启动 `SpatialProgrammingScreen` 作为主界面。

---

### 主题与样式

- **`lib/theme/app_colors.dart`**  
  - 定义整套“极客蓝”暗色主题的**语义化颜色变量**：  
    - `primary / accent / background / surface / surfaceMuted / surfaceLight` 等基础色。  
    - 文本色：`textPrimary / textSecondary / textMuted`。  
    - 逻辑积木专用色：`blockRole`（角色）、`blockDevice`（设备）、`blockAction`（动作）、`blockLogic`（逻辑词）、`danger`（删除高亮）、`overlay`（遮罩）。
  - 所有页面和组件都应引用这里的颜色，禁止新写 `Color(0xFF...)` 硬编码。

- **`lib/theme/app_text_styles.dart`**  
  - 文本样式：  
    - `header`：大标题。  
    - `body`：普通正文。  
    - `code`：等宽代码字体。  
  - UI 里如果要改字体大小或粗细，优先在此基础上 `copyWith`。

---

### Mock 数据

- **`lib/mock/demo_scripts.dart`**  
  - 演示用脚本文案：  
    - `initialCode`：初始占位代码。  
    - `voiceInputText`：模拟语音输入句子“如果妈妈回家，就打开灯”。  
    - `generatedCode`：对应生成的伪代码片段。  
    - `aiResponse`：AI 的反馈文案。

---

### 核心交互页面

- **`lib/screens/spatial_programming_screen.dart`**  
  当前主玩法页面，职责较多，是阅读和修改的重点：

  - **`SpatialProgrammingScreen`（StatefulWidget）**  
    - 整个空间编程工作台：  
      - 背景：客厅照片（模拟 AR 摄像头画面）。  
      - 顶部 AR 反馈：爸爸站立/坐下 + 空调开关状态（`_ArActors` + `_ImageCard`）。  
      - 右上角相机按钮：跳转到拍照识别界面 `_PhotoCaptureScreen`。  
      - 左侧 `DrawerMenu`：背包抽屉，展示各类积木（角色/设备/动作/逻辑），支持从这里拖拽积木到桌面。  
      - 底部“虚拟编程桌”`CodingTable`：  
        - 支持拖拽组合积木、排序、拖拽删除（垃圾桶）、AI 语音生成积木。  
        - 支持“查看源代码”⇄“返回积木”的翻转动画，并切换 Python/C++ 伪代码视图。  
      - 右下“运行”按钮：驱动 AR 区域动画（爸爸坐下 → 延迟 → 空调出风）并弹出“逻辑执行成功！”提示。

  - **关键状态字段**  
    - `_inventory`：背包目前包含的所有积木。  
    - `_logicBlocks`：桌面上当前排列的积木（字符串列表）。  
    - `_isRunning / _dadSeated / _acOn`：运行逻辑时 AR 反馈用状态。  
    - `_drawerOpen`：背包抽屉展开/收起状态。

  - **主要交互方法**  
    - `_handleMicInput()`：模拟语音输入“当爸爸坐下时，打开空调”，生成一组预设积木。  
    - `_handleDropBlock(...)`：处理从背包拖入、桌面内部拖拽重排等情况。  
    - `_handleDeleteBlock(...)`：处理拖拽到垃圾桶删除。  
    - `_isLogicValid(...)`：校验逻辑是否为“当 爸爸 坐下 空调 打开”，用于控制“查看源代码”按钮是否可用。  
    - `_runLogic()`：点击“运行”时的 AR 动画逻辑。  
    - `_openPhotoCapture()`：跳转到 `_PhotoCaptureScreen`，从照片中“提取台灯”后，将“台灯积木”加入背包。

  - **内嵌组件（同文件内定义）**  

    - `DrawerMenu` / `_DraggableBlock` / `_BlockCard`  
      - 左侧背包抽屉及每一个可拖拽的格子积木。  
      - 支持从这里把积木拖拽到编程桌。

    - `_ReorderChip` / `_DragPayload`  
      - 桌面上的小积木标签，支持横向拖拽排序。  
      - 通过 `_DragPayload` 记录来源索引，以实现列表内重排。

    - `_ArActors` / `_ImageCard`  
      - 顶部 AR 区域的两个实体：爸爸、空调。  
      - 仅展示/动画，不参与拖拽。

    - `_PhotoCaptureScreen`  
      - 模拟拍照识别界面：  
        - 显示客厅照片、中央瞄准框、右侧“提取”按钮、左侧背包图标。  
        - 点击提取会播放台灯图标飞向背包的动画，动画结束后调用 `onExtract()` 回调（由主页面传入）将“台灯积木”加入背包。

    - `CodingTable`（改为 Stateful + 内部 `_CodingTableState`）  
      - 底部核心区域，负责：  
        - 展示和管理桌面的积木视图。  
        - 触发 AI 语音生成（右下麦克风 FAB）。  
        - 积木视图与源码视图的翻转动画。  
      - 重要子组件：  
        - `_BlocksView`：积木视图 + 尾部追加 Drop 区 + 右侧垃圾桶 `_TrashBin`。  
        - `_CodeView`：代码视图（行号 + 等宽字体，支持 Python/C++）。  
        - `_LangToggle` / `_Pill`：代码视图右上角的语言切换 UI。  
        - `_pythonPseudo` / `_cppPseudo`：根据当前逻辑生成对应的伪代码（目前对“爸爸坐下 → 空调打开”做了简化写死）。

    - `_TrashBin`  
      - 积木视图最右侧的垃圾桶 `DragTarget`。  
      - 任意从编程桌拖出来的积木（或抽屉积木）拖到这里松手即可从 `_logicBlocks` 中移除。

---

### 通用 UI / 工具组件

- **`lib/widgets/ui/aim_box.dart`**  
  - 闪烁的瞄准框组件，用于拍照识别界面中高亮“台灯”位置。  
  - 使用 `CustomPainter` 画四个角，再用 `AnimationController` 做简单呼吸动画。

---

### 旧版 / 辅助页面与占位

> 这些主要是早期的 workspace + AR/代码分屏原型，当前入口已切到 `SpatialProgrammingScreen`，但仍可参考或复用。

- **`lib/screens/workspace/workspace_screen.dart`**  
  - 分屏工作区：左侧代码编辑占位、右侧 AR 预览占位。  
  - 现在主要作为对比用示例，不走主导航。

- **`lib/widgets/placeholders/ar_view_placeholder.dart`**  
  - 早期的 AR 占位组件，用灰色容器 + 相机/灯泡图标模拟 AR 视窗。

- **`lib/widgets/placeholders/code_editor_placeholder.dart`**  
  - 代码编辑区域占位组件：  
    - 上方文本代码视图（带行号）。  
    - 下方“动态意图甲板” Chips（妈妈、回家、开灯、欢迎音乐）。

---

### 使用建议 & 代码约定

- **颜色 & 文本**：统一从 `app_colors.dart`、`app_text_styles.dart` 引用，避免魔法常量。  
- **交互逻辑集中在页面 State**：  
  - 例如 `_handleMicInput / _runLogic / _openPhotoCapture` 等都集中在 `SpatialProgrammingScreenState`，子组件尽量保持“傻”展示。  
- **Mock 与真实逻辑解耦**：  
  - 目前的语音解析、AR 识别、代码生成等全部是 Mock；未来接入后端或模型时，可以替换对应的 Mock 函数即可。  
- **拖拽相关**：  
  - 桌面内排序使用 `_DragPayload`（记录来源索引），背包→桌面使用 `_BlockItem`。  
  - 删除统一通过拖到 `_TrashBin`。

如需扩展新关卡或新逻辑（例如“妈妈回家→开灯”），推荐复用现有的流程：  
在 `SpatialProgrammingScreenState` 中新增一套校验 + 伪代码生成函数，然后在 `CodingTable` 里根据当前场景选择对应的伪代码生成器即可。
