# UUScrollablesViewProtocol
一行代码创建cell
### 一、上代码
![](https://user-gold-cdn.xitu.io/2018/8/20/16555bde9bbfbd58?w=2032&h=256&f=jpeg&s=114902)

```
let cell = InventoryCell.setup(in: tableView, at: indexPath)
或者
let cell = InventoryCell.newAlways()
或者
let cell = InventoryCell.setup(in: tableView, at: indexPath, reuseAtTheIndexPathOnly: true)
```

****

返回值都是 ``InventoryCell``这样做的好处是不用注册cell，不需要管理***重用标识符***，不需要转换cell的类型

---

### 二、还是代码
![](https://user-gold-cdn.xitu.io/2018/8/20/16555be63db00f36?w=2184&h=204&f=jpeg&s=133769)
```
public static func newAlways(_ cellStyle: UITableViewCellStyle = default) -> Self

public static func setup(in tableView: UITableView, cellStyle: UITableViewCellStyle = default) -> Self

public static func setup(in tableView: UITableView, at indexPath: IndexPath, reuseAtTheIndexPathOnly reusable: Bool = default) -> Self
```

----

1.上面这三个是核心方法，``newAways()``见名知意，总是创建新的cell。大家都知道在cell的代理方法中，滑动列表的时候代码会重复调用，如果创建的cell不想重用，可以调用此方法来创建。可以在任何方法中调用来创建cell，如：
![](https://user-gold-cdn.xitu.io/2018/8/20/16555beb58aedaa6?w=1842&h=442&f=jpeg&s=130737)

****

2.``setup(in tableView: UITableView, cellStyle: UITableViewCellStyle = default)``这个方法与第一个刚好不同，等同于如下代码
![](https://user-gold-cdn.xitu.io/2018/8/20/16555bfd3d27a9ab?w=1480&h=156&f=jpeg&s=69367)

创建的cell在滑动列表的时候会根据重用标识符进行重用，如果列表内容较多，且数据格式一致，墙裂建议使用此方法，节省系统资源

****

3.``setup(in tableView: UITableView, at indexPath: IndexPath, reuseAtTheIndexPathOnly reusable: Bool = default)``
这个方法的参数 ***reuseAtTheIndexPathOnly*** 为``false``时，效果等同于2方法，都会对cell重用，之所以保留是因为这两个方法创建cell的方式不同。3方法是通过注册创建的。

这个方法主要用在代理方法中创建在``指定indexPath进行重用``的cell，创建的cell也会重用，是在指定的indexPath进行重用，比如上传表单内容的列表，每个cell的内容都不同，在对应的indexPath重用，不会造成数据错乱。``（这个例子举的不太好，表单中创建cell我一般会用1方法，初始化时创建一个cell数组，在代理方法中返回对应indexPath[section][row]的cell）``

---

### 三、继续上代码
![](https://user-gold-cdn.xitu.io/2018/8/20/16555c03a725fc06?w=2260&h=744&f=jpeg&s=351457)
这是方法内部的实现，是通过协议来实现，对代码入侵比较小，导入工程就能使用这些方法
下面是方法内变量、方法的来源：

![](https://user-gold-cdn.xitu.io/2018/8/20/16555c0b4d33363e?w=2136&h=1166&f=jpeg&s=552153)

自此，方法使用介绍完毕，内部实现相信大家也了然于心

****

然鹅，就这样结束了？
---

### 四、依然上代码

![](https://user-gold-cdn.xitu.io/2018/8/20/16555c1728145671?w=2754&h=1070&f=jpeg&s=507006)

可以滑动的列表上元素那么多，只有 **“一行代码创建cell”** 怎么够？现在还可以：
**一行代码创建 TableViewHeadterFooterView**，
**一行代码创建 collectionViewCell**，
**一行代码创建 collectionHeaderFooterView（UICollectionReusableView）**

---

### 五、小结

****
1、先说说代码中还存在的问题

① ``collectionViewCell``继承自``UICollectionReuseableView``,就是collectionView的区头区尾视图,这样造成在调用setup方法创建collectionViewCell的时候，编译器代码提示会把创建区头的方法也显示成创建collectionViewCell的方法：
![](https://user-gold-cdn.xitu.io/2018/8/20/16555c1df436abfd?w=2490&h=496&f=jpeg&s=383614)
这个小问题目前还没有解决，本来考虑通过不同的协议来区分，后来发现行不通，继承自``UICollectionReusableView``的类都会有父类的方法，如果用子类的话还可以通过关键字```final```使子类不能继承此方法，但这里是用协议实现的，不能使用这个关键字，不知有没有我没了解到的知识能解决这个问题，欢迎大家一起交流

② 可视化编程，创建的xib文件，如果想要重用的话需要注意填写 ***重用标识符*** ，否则无法重用，只能每次都创建新的view

③ 由于``colleactionViewCell``只能通过注册来创建，所以没能写出``tableViewCell``那种随处可使用的`` newAlways()``方法。

④ ``collectionViewCell``的``newAlways()``方法是通过每次注册``随机的reuseIdentifier``来实现的，这样子滑动列表会一直创建新的cell，而没有复用，如果需要创建非常多的cell，对系统资源的占用比较多。
初步构想通过自动释放池对创建的cell进行管理，对不在屏幕显示区域的cell手动释放内存，因为本人目前对Swift的自动释放池不太熟，目前轮子里没有加入相关的代码

#### 目前自己发现的问题有这些,欢迎一起探讨

****

2、说说代码中的一些小思考

① 四种可重用的cell，本来只想写一个带有 reuseAtTheIndexPathOnly的方法，把代码再精简一下，最后发现放在一个方法中判断四种类型有点乱，反而没有分开逻辑清晰

② 在这次造轮子的过程中得到了一些人的帮助，发现自己的进步比在写逻辑代码的舒适区提高的快，兴趣依然是程序员进步的有效方式

③ 这个轮子也只是利用了编译器的提供的一些便利，深度上并没有扩展。有很多程序员写底层代码，开发新的技术，也有人（xcode开发团队）开发方便大家使用的工具，在应用层带来便利，就如这个轮子在使用上带来的一点点便利。

---

