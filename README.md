# 前言

    很早之前开源了一个简单的视频播放器，由于年久失修，效果惨目忍睹，最近特意花时间对其进行了深度重构。旧版本后期不再维护，新版本使用`Swift`实现，后续会增加更多功能。不想看文字的请自行下载代码------>>>[CLPlayer](https://github.com/JmoVxia/CLPlayer)
# 旧版本 VS 重构版本

**1.新版本使用`Swift`，旧版本使用`Objective-C`**

**2.新版本采用自定义转场实现全屏，旧版本使用旋转屏幕**

**3.新版本不需要手动销毁播放器**

**4.新版本修复了老版本遗留bug**

**5.新版本降低了代码耦合性**

**6.新版本增加了倍数播放，切换填充模式**

**7.新版本提供更丰富的API**

**8.新版本适配了iPhone X**

**9.新版本移除了状态栏相关配置**

# 效果
![效果图](https://upload-images.jianshu.io/upload_images/1979970-3f35995fbe988a91.gif?imageMogr2/auto-orient/strip)

![全屏](https://upload-images.jianshu.io/upload_images/1979970-46f701b4f1d654ee.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![控制面板](https://upload-images.jianshu.io/upload_images/1979970-dd643aea0e8db12f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![UITableView](https://upload-images.jianshu.io/upload_images/1979970-6eaee76837eb46aa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![UICollectionView](https://upload-images.jianshu.io/upload_images/1979970-7d239b30f5b91d72.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 功能

- [x] 支持全屏模式、小屏模式
- [x] 支持跟随手机自动旋转
- [x] 支持本地视频、网络`URL`
- [x] 支持`UITableView`
- [x] 支持`UICollectionView`
- [x] 支持手势改变屏幕的亮度（屏幕左半边）
- [x] 支持手势改变音量大小（屏幕右半边）
- [x] 支持拖动`UISlider`快进快退
- [x] 支持`iPhone X`留海屏
- [x] 支持倍速播放（`0.5X、1.0X、1.25X、1.5X、1.75X、2X`）
- [x] 支持动态改变播放器的填充模式（`适应、拉伸、填充`）
- [x] 支持`cocoapods`

# 接入指南

**项目必须支持全屏，建议将屏幕支持方向交由当前显示的控制器自行管理。**
#### 项目支持全屏方案

#### **1.先勾选支持方向，只保留`portrait`，保证APP启动不会横屏**

![image.png](https://upload-images.jianshu.io/upload_images/1979970-e805d44b28ba55c0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### **2.`AppDelegate`中重写`func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {}`方法**

```swift
func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
}
```

#### **3.在父类中重写屏幕控制相关方法**

```swift
// 是否支持自动转屏
override var shouldAutorotate: Bool {
    guard let navigationController = selectedViewController as? UINavigationController else { return selectedViewController?.shouldAutorotate ?? false }
    return navigationController.topViewController?.shouldAutorotate ?? false
}

// 支持哪些屏幕方向
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    guard let navigationController = selectedViewController as? UINavigationController else { return selectedViewController?.supportedInterfaceOrientations ?? .portrait }
    return navigationController.topViewController?.supportedInterfaceOrientations ?? .portrait
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    guard let navigationController = selectedViewController as? UINavigationController else { return selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait }
    return navigationController.topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
}
```
`UINavigationController`

```swift
// 是否支持自动转屏
override var shouldAutorotate: Bool {
    return topViewController?.shouldAutorotate ?? false
}

// 支持哪些屏幕方向
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return topViewController?.supportedInterfaceOrientations ?? .portrait
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
}
```
`UIViewController`
```swift
// 是否支持自动转屏
override var shouldAutorotate: Bool {
    return false
}

// 支持哪些屏幕方向
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
}
```
#### **4.部分页面需要支持多方向**

在对应控制器中重写以下方法

```swift
override var shouldAutorotate: Bool {
    return true
}

// 支持哪些屏幕方向
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .allButUpsideDown
}
```

#### 基础配置

```swift
public struct CLPlayerConfigure {
    /// 顶部工具条隐藏风格
    public enum CLPlayerTopBarHiddenStyle {
        /// 小屏和全屏都不隐藏
        case never
        /// 小屏和全屏都隐藏
        case always
        /// 小屏隐藏，全屏不隐藏
        case onlySmall
    }

    /// 自动旋转
    public var isAutoRotate = true
    /// 手势控制
    public var isGestureInteractionEnabled = true
    /// 是否显示更多面板
    public var isShowMorePanel = true
    /// 顶部工具条隐藏风格
    public var topBarHiddenStyle: CLPlayerTopBarHiddenStyle = .onlySmall
    /// 工具条自动消失时间
    public var autoFadeOut: TimeInterval = 5
    /// 默认拉伸方式
    public var videoGravity: AVLayerVideoGravity = .resizeAspectFill
    /// 顶部工具条背景颜色
    public var topToobarBackgroundColor: UIColor = .black.withAlphaComponent(0.6)
    /// 底部工具条背景颜色
    public var bottomToolbarBackgroundColor: UIColor = .black.withAlphaComponent(0.6)
    /// 进度条背景颜色
    public var progressBackgroundColor: UIColor = .white.withAlphaComponent(0.35)
    /// 缓冲条缓冲进度颜色
    public var progressBufferColor: UIColor = .white.withAlphaComponent(0.5)
    /// 进度条播放完成颜色
    public var progressFinishedColor: UIColor = .white
    /// 转子背景颜色
    public var loadingBackgroundColor: UIColor = .white
    /// 返回按钮图片
    public var backImage: UIImage?
    /// 更多按钮图片
    public var moreImage: UIImage?
    /// 播放按钮图片
    public var playImage: UIImage?
    /// 暂停按钮图片
    public var pauseImage: UIImage?
    /// 进度滑块图片
    public var sliderImage: UIImage?
    /// 最大化按钮图片
    public var maxImage: UIImage?
    /// 最小化按钮图片
    public var minImage: UIImage?
    /// 封面图片
    public var maskImage: UIImage?
}
```
# 总结

    本次重构为`Swift`第一版，后续会持续更新，定制化开发请自行参考[CLPlayer](https://github.com/JmoVxia/CLPlayer)修改 ， 如果喜欢，欢迎star。

# 参考资料

1.  [iOS播放器全屏方案](https://www.jianshu.com/p/182f6d1e7b04)

2.  [iOS状态栏](https://www.justisit.com/15626010144789.html)

3.  [iOS播放器全屏旋转实现](https://www.jianshu.com/p/84a148e58fc8)

4.  [iOS横竖屏旋转解决方案 - Swift](https://www.jianshu.com/p/539b265bcb5d)

5.  [iOS视频旋转探究](https://drinking.github.io/iOS-video-rotation)

6.  [iOS屏幕旋转的解决方案](https://www.jianshu.com/p/c973817d40c8)
