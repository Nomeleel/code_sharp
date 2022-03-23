如果项目目录存在analysis_options.yaml文件 证明启用了分析
首先[analyzer_server]创建 
  AnalysisDriver[analyzer]
    其中会去解析analysis_options.yaml文件 结合include形成的YamlMap 主要关注 analyzer、linter节点（后面会介绍这些节点配置应用到的地方）
    相关配置节点在analysisOptions字段里面

  同时创建后会将目录下的所有dart文件添加到 分析文件队列中
    注意添加的时候会应用 exclude配置 ？？？？？？

    1. 开始分析：
      先将文件解析成可读的ResolvedUnitResult 里面就有ast数据 [analyzer]
        双重检查：还是会先判断是否在可分析的目录下 exclude配置  driver.analysisContext?.contextRoot.isAnalyzed
      取出可用的规则 规则都在[linter]里面
        主要是通过所有注册的规则 结合 配置的linter 的 rule节点
        (lints和flutter_lints这俩库就是配置了规则名称)
      将规则应用分析 unit.accept(visitor)
        unit里面是抽象语法书里面需要遍历的项目非常多为了节约性能 设计了 LinterVisitor(nodeRegistry)遍历器
        定义的规则必须实现 registerNodeProcessors
          将需要关注的项手动注册到registry里面，未注册的不会被遍历
      分析过程中的error上报
        lint有reporter上报字段 需要传入一个监听者 所有上报的error都会收集到监听器里面
      分析结果在监听器的errors里面
    2. 分析结果筛选
      IgnoreInfo 正则去掉ignore的字段
      如果配置了cannot-ignore字段 则ignore不可用
    3. error转换 [analyzer_plugin]
      error是analysiser所定义的 通信到第三方需要转化成json的plugin的error
      所提供的AnalyzerConverter().convertAnalysisErrors(用来转换
      同时analyzer error配置下可以转换lint error的等级（error、info、）
      在convert的过程中会进行应用（ignore的会被过滤掉）
    4. error通过lsp通信给client

