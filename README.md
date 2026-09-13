# 苍穹外卖（sky-take-out）

> 黑马程序员《苍穹外卖》项目实战 —— 个人学习实现版本
> 仓库：<https://github.com/shixun926-dotcom/MyFirstProject>

本项目是跟着黑马程序员《苍穹外卖》课程实现的**外卖点餐系统后端**，采用 Maven 多模块
架构，包含管理端（商家后台）与用户端（微信小程序）两套接口体系。当前个人实现进度
停留在**管理端基础模块（员工 / 分类 / 菜品 / 套餐）**，其余模块按课程进度持续补全。

---

## 目录

- [一、项目介绍](#一项目介绍)
- [二、技术选型](#二技术选型)
- [三、工程结构](#三工程结构)
- [四、已完成功能](#四已完成功能)
- [五、接口文档](#五接口文档)
- [六、数据库设计](#六数据库设计)
- [七、环境搭建与运行](#七环境搭建与运行)
- [八、核心技术点说明](#八核心技术点说明)
- [九、开发进度与待办](#九开发进度与待办)
- [十、常见问题](#十常见问题)
- [十一、安全说明](#十一安全说明)

---

## 一、项目介绍

苍穹外卖是一套完整的**餐饮外卖点餐系统**，业务上分为两大部分：

| 端 | 使用者 | 说明 |
| --- | --- | --- |
| 管理端 | 商家 / 运营人员 | 员工管理、分类管理、菜品管理、套餐管理、订单管理、数据统计等 |
| 用户端 | 顾客（微信小程序） | 微信登录、浏览菜品、购物车、下单、微信支付、历史订单等 |

后端对外提供两套 REST 接口：

- `/admin/**` —— 管理端接口，使用 JWT 令牌鉴权，令牌请求头名称为 `token`
- `/user/**` —— 用户端接口，使用微信登录换取 JWT（当前版本尚未实现）

统一响应格式（`com.sky.result.Result`）：

```json
{
  "code": 1,
  "msg": null,
  "data": {}
}
```

- `code = 1` 表示成功，`code = 0` 表示失败，失败时 `msg` 为错误原因
- 分页数据统一封装为 `PageResult`：`{ "total": 100, "records": [] }`

---

## 二、技术选型

### 后端

| 技术 | 版本 | 说明 |
| --- | --- | --- |
| Spring Boot | 2.7.3 | 基础框架 |
| JDK | 17 | 编译与运行版本 |
| Maven | 3.6+ | 多模块构建 |
| MyBatis / MyBatis-Spring-Boot-Starter | 2.2.0 | 持久层框架 |
| Druid | 1.2.1 | 数据库连接池 |
| PageHelper | 1.3.0 | 分页插件 |
| MySQL | 8.x | 关系型数据库 |
| Lombok | 1.18.20 | 简化实体类代码 |
| fastjson | 1.2.76 | JSON 处理 |
| JJWT | 0.9.1 | JWT 令牌生成与校验 |
| Spring AOP (AspectJ) | 1.9.4 | 公共字段自动填充 |
| Knife4j (Swagger) | 3.0.2 | 接口文档 |
| 阿里云 OSS SDK | 3.10.2 | 图片对象存储 |
| Apache POI | 3.16 | Excel 报表导出（待使用） |
| wechatpay-apache-httpclient | 0.4.8 | 微信支付（待使用） |

### 前端（非本仓库）

- 管理端：Nginx + Vue（黑马提供的 `nginx-1.20.2` 静态资源包）
- 用户端：微信开发者工具 + 小程序代码包

---

## 三、工程结构

```text
sky-take-out/                        父工程（pom 聚合）
├─ pom.xml                           统一依赖版本管理（dependencyManagement）
├─ sky-common/                       公共模块：工具类、常量、异常、统一响应
│  └─ src/main/java/com/sky/
│     ├─ constant/                   常量（JWT 声明、公共字段、提示信息、状态…）
│     ├─ context/                    BaseContext：基于 ThreadLocal 保存当前登录用户 id
│     ├─ enumeration/                OperationType：INSERT / UPDATE
│     ├─ exception/                  自定义业务异常（11 个）
│     ├─ json/                       JacksonObjectMapper：统一时间序列化格式
│     ├─ properties/                 JwtProperties / AliOssProperties / WeChatProperties
│     ├─ result/                     Result / PageResult 统一返回结果
│     └─ utils/                      JwtUtil / AliOssUtil / HttpClientUtil / WeChatPayUtil
├─ sky-pojo/                         实体模块：DTO / VO / Entity
│  └─ src/main/java/com/sky/
│     ├─ dto/                        数据传输对象（接收前端参数）
│     ├─ entity/                     与数据库表一一对应的实体
│     └─ vo/                         视图对象（返回给前端）
└─ sky-server/                       服务模块：启动类、配置、Controller、Service、Mapper
   └─ src/main/
      ├─ java/com/sky/
      │  ├─ SkyApplication.java      启动类
      │  ├─ annotation/AutoFill      自定义注解：标记需要自动填充的 Mapper 方法
      │  ├─ aspect/AutoFillAspect    AOP 切面：自动填充 create_time/create_user/update_time/update_user
      │  ├─ config/                  WebMvcConfiguration / OssConfiguration / DataInitializer
      │  ├─ controller/admin/        管理端控制器
      │  ├─ handler/                 GlobalExceptionHandler 全局异常处理
      │  ├─ interceptor/             JwtTokenAdminInterceptor JWT 校验拦截器
      │  ├─ mapper/                  MyBatis Mapper 接口
      │  └─ service/ + service/impl/ 业务接口与实现
      └─ resources/
         ├─ application.yml          主配置（端口、数据源、MyBatis、JWT）
         ├─ application-dev.yml      开发环境配置（数据源、OSS，需自行填写）
         └─ mapper/*.xml             MyBatis 映射文件
```

---

## 四、已完成功能

### ✅ 员工管理 `sky-server/.../controller/admin/EmployeeController.java`

- [x] 员工登录（用户名 + 密码，密码 BCrypt 校验，登录成功签发 JWT）
- [x] 员工退出
- [x] 新增员工（用户名唯一校验，默认密码，BCrypt 加密存储）
- [x] 员工分页查询（支持按姓名模糊查询）
- [x] 启用 / 禁用员工账号
- [x] 根据 id 查询员工
- [x] 编辑员工信息

### ✅ 分类管理 `CategoryController.java`

- [x] 新增分类（菜品分类 / 套餐分类）
- [x] 分类分页查询（支持按名称、类型查询）
- [x] 删除分类（**关联了菜品或套餐的分类不允许删除**）
- [x] 修改分类
- [x] 启用 / 禁用分类
- [x] 根据类型查询分类列表

### ✅ 菜品管理 `DishController.java`

- [x] 新增菜品（同时保存菜品口味 `dish_flavor`）
- [x] 菜品分页查询（支持按名称、分类、状态查询）
- [x] 菜品批量删除（**起售中或关联了套餐的菜品不允许删除**）
- [x] 根据 id 查询菜品及其口味
- [x] 修改菜品（同时更新口味）
- [x] 根据分类 id 查询启售中的菜品列表
- [x] 菜品起售 / 停售

### ✅ 套餐管理 `SetmealController.java`

- [x] 新增套餐（同时保存套餐菜品关系 `setmeal_dish`）
- [x] 套餐分页查询
- [x] 套餐批量删除（**起售中的套餐不允许删除**）
- [x] 根据 id 查询套餐及关联菜品
- [x] 修改套餐
- [x] 套餐起售 / 停售（**套餐内含未启售菜品时不允许启售**）

### ✅ 通用能力

- [x] 文件上传（阿里云 OSS，UUID 重命名避免覆盖）
- [x] JWT 登录校验拦截器（拦截 `/admin/**`，放行 `/admin/employee/login`）
- [x] 公共字段自动填充（AOP + 自定义注解 + 反射）
- [x] 全局异常处理（业务异常、SQL 唯一约束冲突、兜底异常）
- [x] 统一时间格式序列化（`JacksonObjectMapper`）
- [x] Knife4j 接口文档
- [x] 历史数据密码兼容处理（`DataInitializer`：启动时将明文密码升级为 BCrypt）

---

## 五、接口文档

启动项目后访问 Knife4j 在线接口文档：

```text
http://localhost:8080/doc.html
```

### 5.1 管理端接口一览

统一前缀 `/admin`，除登录接口外**均需在请求头携带 `token`**。

#### 员工管理 `/admin/employee`

| 功能 | 方法 | 路径 | 请求参数 |
| --- | --- | --- | --- |
| 员工登录 | POST | `/admin/employee/login` | body：`EmployeeLoginDTO`（username、password） |
| 员工退出 | POST | `/admin/employee/logout` | 无 |
| 新增员工 | POST | `/admin/employee` | body：`EmployeeDTO` |
| 员工分页查询 | GET | `/admin/employee/page` | query：name、page、pageSize |
| 启用禁用账号 | POST | `/admin/employee/status/{status}` | path：status；query：id |
| 根据 id 查询 | GET | `/admin/employee/{id}` | path：id |
| 编辑员工 | PUT | `/admin/employee` | body：`EmployeeDTO` |

#### 分类管理 `/admin/category`

| 功能 | 方法 | 路径 | 请求参数 |
| --- | --- | --- | --- |
| 新增分类 | POST | `/admin/category` | body：`CategoryDTO` |
| 分类分页查询 | GET | `/admin/category/page` | query：name、type、page、pageSize |
| 删除分类 | DELETE | `/admin/category` | query：id |
| 修改分类 | PUT | `/admin/category` | body：`CategoryDTO` |
| 启用禁用分类 | POST | `/admin/category/status/{status}` | path：status；query：id |
| 按类型查询分类 | GET | `/admin/category/list` | query：type（1 菜品分类 / 2 套餐分类） |

#### 菜品管理 `/admin/dish`

| 功能 | 方法 | 路径 | 请求参数 |
| --- | --- | --- | --- |
| 新增菜品 | POST | `/admin/dish` | body：`DishDTO`（含 flavors 口味数组） |
| 菜品分页查询 | GET | `/admin/dish/page` | query：name、categoryId、status、page、pageSize |
| 菜品批量删除 | DELETE | `/admin/dish` | query：ids（多个 id） |
| 根据 id 查询 | GET | `/admin/dish/{id}` | path：id |
| 修改菜品 | PUT | `/admin/dish` | body：`DishDTO` |
| 按分类查询菜品 | GET | `/admin/dish/list` | query：categoryId |
| 起售停售 | POST | `/admin/dish/status/{status}` | path：status；query：id |

#### 套餐管理 `/admin/setmeal`

| 功能 | 方法 | 路径 | 请求参数 |
| --- | --- | --- | --- |
| 新增套餐 | POST | `/admin/setmeal` | body：`SetmealDTO`（含 setmealDishes 数组） |
| 套餐分页查询 | GET | `/admin/setmeal/page` | query：name、categoryId、status、page、pageSize |
| 套餐批量删除 | DELETE | `/admin/setmeal` | query：ids（逗号分隔字符串） |
| 根据 id 查询 | GET | `/admin/setmeal/{id}` | path：id |
| 修改套餐 | PUT | `/admin/setmeal` | body：`SetmealDTO` |
| 起售停售 | POST | `/admin/setmeal/status/{status}` | path：status；query：id |

#### 通用接口 `/admin/common`

| 功能 | 方法 | 路径 | 请求参数 |
| --- | --- | --- | --- |
| 文件上传 | POST | `/admin/common/upload` | form-data：file |

#### 调用示例

```bash
# 1. 登录获取 token
curl -X POST http://localhost:8080/admin/employee/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'

# 响应：{"code":1,"data":{"id":1,"userName":"admin","name":"管理员","token":"eyJhbGciOi..."}}

# 2. 携带 token 调用业务接口
curl "http://localhost:8080/admin/category/page?page=1&pageSize=10" \
  -H "token: eyJhbGciOi..."
```

### 5.2 用户端接口（未实现）

课程规划中的 `/user/**` 接口当前尚未实现，包括：微信登录、菜品浏览、购物车、下单、
微信支付、历史订单等，详见[开发进度与待办](#九开发进度与待办)。

---

## 六、数据库设计

数据库名：`sky_take_out`，字符集 `utf8mb4`。

> 建表脚本见 [`docs/database/sky_take_out.sql`](docs/database/sky_take_out.sql)，
> 该脚本依据 `sky-pojo` 中的实体类字段整理，字段与真实库表一致。

### 6.1 当前项目使用的表

| 表名 | 说明 | 对应实体 |
| --- | --- | --- |
| `employee` | 员工表 | `Employee` |
| `category` | 分类表（菜品分类 / 套餐分类） | `Category` |
| `dish` | 菜品表 | `Dish` |
| `dish_flavor` | 菜品口味表 | `DishFlavor` |
| `setmeal` | 套餐表 | `Setmeal` |
| `setmeal_dish` | 套餐菜品关系表 | `SetmealDish` |

### 6.2 课程完整业务表（待实现模块使用）

| 表名 | 说明 |
| --- | --- |
| `user` | 用户表（微信用户） |
| `address_book` | 收货地址表 |
| `shopping_cart` | 购物车表 |
| `orders` | 订单表 |
| `order_detail` | 订单明细表 |

### 6.3 关键字段说明

- 所有业务表均含公共字段：`create_time`、`update_time`、`create_user`、`update_user`，
  由 `AutoFillAspect` 切面自动填充，无需在业务代码中手动赋值。
- `employee.status`、`category.status`、`dish.status`、`setmeal.status`：
  `1` 表示启用 / 起售，`0` 表示禁用 / 停售。
- `category.type`：`1` 菜品分类，`2` 套餐分类。
- `dish_flavor.value`：口味可选值，JSON 数组字符串，例如 `["不辣","微辣","中辣","重辣"]`。
- `setmeal_dish` 中的 `name`、`price` 为**冗余字段**，用于避免查询套餐时多次关联菜品表。

---

## 七、环境搭建与运行

### 7.1 环境要求

| 软件 | 版本要求 |
| --- | --- |
| JDK | 17 |
| Maven | 3.6+ |
| MySQL | 8.x |
| Git | 任意 |

### 7.2 初始化数据库

```sql
CREATE DATABASE sky_take_out DEFAULT CHARACTER SET utf8mb4;
```

导入建表脚本：

```bash
mysql -uroot -p sky_take_out < docs/database/sky_take_out.sql
```

> 也可以直接使用黑马课程资料中的 `sky_take_out.sql` 完整脚本（含初始数据与全部业务表）。

### 7.3 修改配置

编辑 `sky-server/src/main/resources/application-dev.yml`，把数据库、阿里云 OSS
替换成**你自己的**账号信息：

```yaml
sky:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    host: localhost
    port: 3306
    database: sky_take_out
    username: root
    password: 你的数据库密码
  alioss:
    endpoint: oss-cn-xxx.aliyuncs.com
    access-key-id: 你的AccessKeyId
    access-key-secret: 你的AccessKeySecret
    bucket-name: 你的Bucket名称
```

配置模板见 [`.env.example`](.env.example)。**请勿把真实密钥提交到仓库**，
详见[安全说明](#十一安全说明)。

### 7.4 启动项目

方式一：IDEA 直接运行 `com.sky.SkyApplication` 的 `main` 方法。

方式二：命令行构建并启动：

```bash
# 在父工程目录执行
mvn clean package -DskipTests

# 运行 sky-server 模块
java -jar sky-server/target/sky-server-1.0-SNAPSHOT.jar
```

启动成功后：

- 服务端口：`8080`
- 接口文档：<http://localhost:8080/doc.html>
- 默认账号：`admin`（密码以数据库 `employee` 表中的初始数据为准，登录后建议立即修改）

### 7.5 管理端前端（可选）

本仓库只包含后端。管理端页面使用黑马课程提供的 Nginx + Vue 静态资源，
将其放入 Nginx 的 `html/sky` 目录并配置反向代理指向 `http://localhost:8080` 即可。

---

## 八、核心技术点说明

### 8.1 JWT 登录鉴权

- 登录成功后由 `JwtUtil.createJWT()` 签发令牌，HS256 算法，载荷中保存员工 id，
  有效期由 `sky.jwt.admin-ttl` 控制（默认 2 小时）。
- `JwtTokenAdminInterceptor` 拦截 `/admin/**`，从请求头 `token` 中取出令牌校验；
  校验通过后把员工 id 存入 `BaseContext`（ThreadLocal），失败直接返回 `401`。
- 配置项位于 `application.yml` 的 `sky.jwt` 下。

### 8.2 公共字段自动填充（AOP + 注解 + 反射）

- 自定义注解 `@AutoFill(OperationType.INSERT | UPDATE)` 标注在 Mapper 方法上。
- `AutoFillAspect` 定义切入点 `execution(* com.sky.mapper.*.*(..)) && @annotation(com.sky.annotation.AutoFill)`，
  在前置通知中通过反射为实体赋值：
  - `INSERT`：填充 `createTime`、`createUser`、`updateTime`、`updateUser`
  - `UPDATE`：填充 `updateTime`、`updateUser`
- 当前登录人 id 从 `BaseContext` 获取，避免在每个 Service 中重复写赋值代码。

### 8.3 ThreadLocal 上下文

`BaseContext` 使用 `ThreadLocal<Long>` 保存当前登录用户 id，请求结束后在拦截器的
`afterCompletion` 中清理，防止线程复用导致的数据串号。

### 8.4 全局异常处理

`GlobalExceptionHandler` 通过 `@RestControllerAdvice` 统一处理三类异常：

- `BaseException`：业务异常，直接把异常信息返回给前端
- `SQLIntegrityConstraintViolationException`：解析唯一索引冲突，返回「xxx 已存在」
- `Exception`：兜底异常，记录日志并返回「未知错误」

### 8.5 统一返回与时间格式

- `Result<T>` 统一响应结构，`PageResult` 统一分页结构。
- `JacksonObjectMapper` 注册到消息转换器首位，统一 `LocalDateTime` 等时间类型
  的序列化与反序列化格式（`yyyy-MM-dd HH:mm:ss`）。

### 8.6 多模块依赖关系

```text
sky-server  ──依赖──▶  sky-common
     │        ──依赖──▶  sky-pojo
     └──────────────▶  sky-pojo ──依赖──▶ sky-common
```

- `sky-common`：不依赖任何业务模块，可被复用
- `sky-pojo`：只放实体 / DTO / VO
- `sky-server`：业务逻辑、Web 层、配置

---

## 九、开发进度与待办

### 已完成

| 模块 | 端 | 状态 |
| --- | --- | --- |
| 员工管理 | 管理端 | ✅ 完成 |
| 分类管理 | 管理端 | ✅ 完成 |
| 菜品管理 | 管理端 | ✅ 完成 |
| 套餐管理 | 管理端 | ✅ 完成 |
| 文件上传（OSS） | 管理端 | ✅ 完成 |
| JWT 鉴权 / 全局异常 / 公共字段填充 | 公共 | ✅ 完成 |

### 待实现

| 模块 | 端 | 说明 |
| --- | --- | --- |
| 微信登录 | 用户端 | 调用微信接口换取 openid，签发用户 JWT |
| 用户端菜品浏览 | 用户端 | 分类列表、菜品列表、套餐列表、套餐详情 |
| 购物车 | 用户端 | 添加、减少、查看、清空 |
| 收货地址 | 用户端 | 地址簿增删改查、默认地址 |
| 用户下单 | 用户端 | 提交订单、订单明细、金额校验 |
| 微信支付 | 用户端 | 预支付、支付回调、订单状态流转 |
| 用户订单 | 用户端 | 历史订单、订单详情、再来一单、取消 |
| 商家订单管理 | 管理端 | 接单、拒单、取消、派送、完成、订单搜索 |
| 来单提醒 / 客户催单 | 管理端 | WebSocket 实时提醒 |
| 工作台 | 管理端 | 今日数据、订单管理、菜品总览、套餐总览 |
| 数据统计 | 管理端 | 营业额统计、用户统计、订单统计、销量排名 |
| Excel 报表导出 | 管理端 | Apache POI 导出运营数据（依赖已引入） |
| 缓存优化 | 公共 | Redis 缓存菜品 / 套餐，Spring Cache |
| 定时任务 | 公共 | 处理超时未支付订单 |

进度看板见 [`docs/progress.md`](docs/progress.md)。

---

## 十、常见问题

**1. 启动报错 `Unknown database 'sky_take_out'`**
数据库未创建或未导入脚本，参考 [7.2 初始化数据库](#72-初始化数据库)。

**2. 启动报错 `Access denied for user 'root'@'localhost'`**
`application-dev.yml` 中的数据库用户名或密码不正确。

**3. 接口返回 401**
请求头缺少 `token`，或令牌已过期（默认 2 小时），重新登录即可。

**4. Knife4j 文档页 404**
确认访问路径为 `/doc.html`（而非 `/swagger-ui.html`），且项目已正常启动。

**5. 登录提示「密码错误」但密码确实是初始密码**
初始数据中的密码可能是明文。项目内置 `DataInitializer`，启动时会自动把明文密码
升级为 BCrypt 格式，重新启动项目后再登录即可。

**6. 图片上传失败**
检查 `sky.alioss` 配置是否正确、Bucket 是否具有公共读权限、服务器能否访问外网。

**7. 时间显示相差 8 小时**
确认数据库连接串中带 `serverTimezone=Asia/Shanghai`（`application.yml` 中已配置）。

---

## 十一、安全说明

> ⚠️ 本项目为个人学习项目，**数据库密码、阿里云 AccessKey、微信支付密钥等敏感信息
> 一律不得提交到 Git 仓库**。

- 请把 `application-dev.yml` 中的敏感配置替换为你自己的信息，并且**不要提交真实值**。
  推荐做法：本地保留 `application-dev.yml` 并用 Git 忽略，仓库中只提交
  `application-dev.yml.example` 模板（本仓库提供 `.env.example` 作为参考）。
- 若密钥曾经被提交过，请到对应平台**立即禁用 / 轮换**该密钥，并清理 Git 历史。
- 生产环境应使用环境变量或配置中心注入密钥，而不是写在配置文件里。
- JWT 密钥 `sky.jwt.admin-secret-key` 同样应当在部署时替换为足够复杂的随机值。

---

## 参考

- 黑马程序员《苍穹外卖》项目实战课程
- [README 由 AI 协助整理，内容以仓库实际代码为准]

如果这个项目对你有帮助，欢迎 Star ⭐
