# 开发进度看板

> 对照黑马程序员《苍穹外卖》课程的功能清单，记录本仓库的完成情况。
> 最后更新：依据仓库 `master` 分支实际代码整理。

## 状态说明

| 标记 | 含义 |
| --- | --- |
| ✅ | 已完成，代码已提交 |
| 🟡 | 部分完成 / 待完善 |
| ⬜ | 未开始 |

---

## 一、公共基础层（sky-common / 配置）

| 序号 | 功能点 | 涉及文件 | 状态 |
| --- | --- | --- | --- |
| 1 | 统一返回结果 `Result` / `PageResult` | `sky-common/result` | ✅ |
| 2 | 自定义业务异常体系（11 个异常类） | `sky-common/exception` | ✅ |
| 3 | 提示信息常量 `MessageConstant` | `sky-common/constant` | ✅ |
| 4 | JWT 工具类 `JwtUtil` | `sky-common/utils` | ✅ |
| 5 | 阿里云 OSS 工具类 `AliOssUtil` | `sky-common/utils` | ✅ |
| 6 | 微信支付工具类 `WeChatPayUtil` | `sky-common/utils` | ✅ 已就绪，未接入业务 |
| 7 | HTTP 客户端工具 `HttpClientUtil` | `sky-common/utils` | ✅ 已就绪，用于调用微信接口 |
| 8 | `BaseContext`（ThreadLocal 保存登录人 id） | `sky-common/context` | ✅ |
| 9 | `JacksonObjectMapper` 统一时间格式 | `sky-common/json` | ✅ |
| 10 | 配置属性类 `JwtProperties` / `AliOssProperties` / `WeChatProperties` | `sky-common/properties` | ✅ |
| 11 | `@AutoFill` 注解 + `AutoFillAspect` 公共字段填充 | `sky-server/annotation`、`aspect` | ✅ |
| 12 | `WebMvcConfiguration`（拦截器、Knife4j、静态资源、消息转换器） | `sky-server/config` | ✅ |
| 13 | `GlobalExceptionHandler` 全局异常处理 | `sky-server/handler` | ✅ |
| 14 | `JwtTokenAdminInterceptor` 管理端令牌校验 | `sky-server/interceptor` | ✅ |
| 15 | `DataInitializer` 明文密码自动升级为 BCrypt | `sky-server/config` | ✅ 个人扩展 |
| 16 | Redis 缓存菜品 / 套餐 | — | ⬜ |
| 17 | Spring Cache 注解缓存 | — | ⬜ |
| 18 | 定时任务处理超时订单 | — | ⬜ |

---

## 二、管理端（/admin/**）

### 2.1 员工管理

| 序号 | 功能点 | 对应接口 | 状态 |
| --- | --- | --- | --- |
| 1 | 员工登录（BCrypt 校验 + 签发 JWT） | `POST /admin/employee/login` | ✅ |
| 2 | 员工退出 | `POST /admin/employee/logout` | ✅ |
| 3 | 新增员工 | `POST /admin/employee` | ✅ |
| 4 | 员工分页查询 | `GET /admin/employee/page` | ✅ |
| 5 | 启用 / 禁用员工账号 | `POST /admin/employee/status/{status}` | ✅ |
| 6 | 根据 id 查询员工 | `GET /admin/employee/{id}` | ✅ |
| 7 | 编辑员工信息 | `PUT /admin/employee` | ✅ |
| 8 | 修改密码 | `PUT /admin/employee/editPassword` | ⬜ |

### 2.2 分类管理

| 序号 | 功能点 | 对应接口 | 状态 |
| --- | --- | --- | --- |
| 1 | 新增分类 | `POST /admin/category` | ✅ |
| 2 | 分类分页查询 | `GET /admin/category/page` | ✅ |
| 3 | 删除分类（校验是否关联菜品/套餐） | `DELETE /admin/category` | ✅ |
| 4 | 修改分类 | `PUT /admin/category` | ✅ |
| 5 | 启用 / 禁用分类 | `POST /admin/category/status/{status}` | ✅ |
| 6 | 根据类型查询分类 | `GET /admin/category/list` | ✅ |

### 2.3 菜品管理

| 序号 | 功能点 | 对应接口 | 状态 |
| --- | --- | --- | --- |
| 1 | 新增菜品（含口味） | `POST /admin/dish` | ✅ |
| 2 | 菜品分页查询 | `GET /admin/dish/page` | ✅ |
| 3 | 批量删除菜品（校验起售/关联套餐） | `DELETE /admin/dish` | ✅ |
| 4 | 根据 id 查询菜品及口味 | `GET /admin/dish/{id}` | ✅ |
| 5 | 修改菜品（含口味） | `PUT /admin/dish` | ✅ |
| 6 | 根据分类查询启售菜品 | `GET /admin/dish/list` | ✅ |
| 7 | 菜品起售 / 停售 | `POST /admin/dish/status/{status}` | ✅ |

### 2.4 套餐管理

| 序号 | 功能点 | 对应接口 | 状态 |
| --- | --- | --- | --- |
| 1 | 新增套餐（含套餐菜品关系） | `POST /admin/setmeal` | ✅ |
| 2 | 套餐分页查询 | `GET /admin/setmeal/page` | ✅ |
| 3 | 批量删除套餐（校验起售状态） | `DELETE /admin/setmeal` | ✅ |
| 4 | 根据 id 查询套餐及关联菜品 | `GET /admin/setmeal/{id}` | ✅ |
| 5 | 修改套餐 | `PUT /admin/setmeal` | ✅ |
| 6 | 套餐起售 / 停售（校验菜品是否启售） | `POST /admin/setmeal/status/{status}` | ✅ |

### 2.5 通用与其他

| 序号 | 功能点 | 对应接口 | 状态 |
| --- | --- | --- | --- |
| 1 | 文件上传（阿里云 OSS） | `POST /admin/common/upload` | ✅ |
| 2 | 商家订单管理（接单/拒单/取消/派送/完成） | `/admin/order/**` | ⬜ |
| 3 | 订单搜索 | `GET /admin/order/conditionSearch` | ⬜ |
| 4 | 各个状态的订单数量统计 | `GET /admin/order/statistics` | ⬜ |
| 5 | 查询订单详情 | `GET /admin/order/details/{id}` | ⬜ |
| 6 | 来单提醒（WebSocket） | `/ws/{sid}` | ⬜ |
| 7 | 客户催单 | `GET /admin/order/reminder/{id}` | ⬜ |
| 8 | 工作台今日数据 | `GET /admin/workspace/businessData` | ⬜ |
| 9 | 工作台订单管理 | `GET /admin/workspace/overviewOrders` | ⬜ |
| 10 | 工作台菜品总览 | `GET /admin/workspace/overviewDishes` | ⬜ |
| 11 | 工作台套餐总览 | `GET /admin/workspace/overviewSetmeals` | ⬜ |
| 12 | 营业额统计 | `GET /admin/report/turnoverStatistics` | ⬜ |
| 13 | 用户统计 | `GET /admin/report/userStatistics` | ⬜ |
| 14 | 订单统计 | `GET /admin/report/ordersStatistics` | ⬜ |
| 15 | 销量排名 Top10 | `GET /admin/report/top10` | ⬜ |
| 16 | 导出运营数据 Excel | `GET /admin/report/export` | ⬜ |

---

## 三、用户端（/user/**）

| 序号 | 功能点 | 对应接口 | 状态 |
| --- | --- | --- | --- |
| 1 | 微信登录 | `POST /user/user/login` | ⬜ |
| 2 | 用户端分类列表 | `GET /user/category/list` | ⬜ |
| 3 | 根据分类查询菜品 | `GET /user/dish/list` | ⬜ |
| 4 | 根据分类查询套餐 | `GET /user/setmeal/list` | ⬜ |
| 5 | 根据 id 查询套餐及菜品 | `GET /user/setmeal/dish/{id}` | ⬜ |
| 6 | 添加购物车 | `POST /user/shoppingCart/add` | ⬜ |
| 7 | 减少购物车商品 | `POST /user/shoppingCart/sub` | ⬜ |
| 8 | 查看购物车 | `GET /user/shoppingCart/list` | ⬜ |
| 9 | 清空购物车 | `DELETE /user/shoppingCart/clean` | ⬜ |
| 10 | 新增收货地址 | `POST /user/addressBook` | ⬜ |
| 11 | 查询收货地址列表 | `GET /user/addressBook/list` | ⬜ |
| 12 | 查询默认收货地址 | `GET /user/addressBook/default` | ⬜ |
| 13 | 修改收货地址 | `PUT /user/addressBook` | ⬜ |
| 14 | 删除收货地址 | `DELETE /user/addressBook` | ⬜ |
| 15 | 设置默认收货地址 | `PUT /user/addressBook/default` | ⬜ |
| 16 | 用户下单 | `POST /user/order/submit` | ⬜ |
| 17 | 订单支付（微信支付） | `POST /user/order/payment` | ⬜ |
| 18 | 支付成功回调 | `POST /user/order/paymentSuccess` / `notify` | ⬜ |
| 19 | 历史订单查询 | `GET /user/order/historyOrders` | ⬜ |
| 20 | 查询订单详情 | `GET /user/order/orderDetail/{id}` | ⬜ |
| 21 | 取消订单 | `PUT /user/order/cancel/{id}` | ⬜ |
| 22 | 再来一单 | `POST /user/order/repetition/{id}` | ⬜ |
| 23 | 用户端 JWT 拦截器 | `JwtTokenUserInterceptor` | ⬜ |

---

## 四、下一步计划

按课程顺序，建议的实现路线：

1. **微信登录与用户端基础**：`user` 表、`WeChatProperties` 配置、调用微信 `jscode2session`
   换取 openid、`JwtTokenUserInterceptor`。
2. **用户端浏览**：分类 / 菜品 / 套餐查询接口（可复用管理端 mapper 方法）。
3. **购物车**：`shopping_cart` 表与增删改查，注意菜品与套餐共用购物车表（用 `dish_id` /
   `setmeal_id` 区分）。
4. **收货地址**：`address_book` 表，默认地址互斥处理。
5. **用户下单 + 微信支付**：`orders` / `order_detail` 表，金额校验、订单状态机、
   微信预支付与支付回调。
6. **商家订单管理 + WebSocket 来单提醒**。
7. **工作台与数据统计报表**（POI 导出 Excel）。
8. **性能优化**：Redis 缓存、Spring Cache、定时任务。
