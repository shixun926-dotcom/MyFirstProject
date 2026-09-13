-- ----------------------------------------------------------------------------
-- 苍穹外卖 sky_take_out 建表脚本（当前项目已使用的表）
--
-- 依据 sky-pojo 模块中的实体类字段整理，字段与项目代码一一对应。
-- 如需包含用户端、订单等全部业务表及初始数据，
-- 请使用黑马课程资料中提供的完整 sky_take_out.sql。
--
-- 使用方式：
--   CREATE DATABASE sky_take_out DEFAULT CHARACTER SET utf8mb4;
--   mysql -uroot -p sky_take_out < docs/database/sky_take_out.sql
-- ----------------------------------------------------------------------------

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 员工表
-- ----------------------------
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        VARCHAR(32)  NOT NULL COMMENT '姓名',
  `username`    VARCHAR(32)  NOT NULL COMMENT '用户名',
  `password`    VARCHAR(64)  NOT NULL COMMENT '密码（BCrypt 加密）',
  `phone`       VARCHAR(11)  NOT NULL COMMENT '手机号',
  `sex`         VARCHAR(2)   NOT NULL COMMENT '性别',
  `id_number`   VARCHAR(18)  NOT NULL COMMENT '身份证号',
  `status`      INT          NOT NULL DEFAULT 1 COMMENT '状态 0:禁用 1:启用',
  `create_time` DATETIME     DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME     DEFAULT NULL COMMENT '更新时间',
  `create_user` BIGINT       DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT       DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '员工信息';

-- ----------------------------
-- 2. 分类表
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `type`        INT         DEFAULT NULL COMMENT '类型 1:菜品分类 2:套餐分类',
  `name`        VARCHAR(32) NOT NULL UNIQUE COMMENT '分类名称',
  `sort`        INT         NOT NULL DEFAULT 0 COMMENT '顺序',
  `status`      INT         DEFAULT NULL COMMENT '状态 0:禁用 1:启用',
  `create_time` DATETIME    DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME    DEFAULT NULL COMMENT '更新时间',
  `create_user` BIGINT      DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT      DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '菜品及套餐分类';

-- ----------------------------
-- 3. 菜品表
-- ----------------------------
DROP TABLE IF EXISTS `dish`;
CREATE TABLE `dish` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        VARCHAR(32)   NOT NULL UNIQUE COMMENT '菜品名称',
  `category_id` BIGINT        NOT NULL COMMENT '菜品分类id',
  `price`       DECIMAL(10,2) DEFAULT NULL COMMENT '菜品价格',
  `image`       VARCHAR(255)  DEFAULT NULL COMMENT '图片',
  `description` VARCHAR(255)  DEFAULT NULL COMMENT '描述信息',
  `status`      INT           DEFAULT 1 COMMENT '0:停售 1:起售',
  `create_time` DATETIME      DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME      DEFAULT NULL COMMENT '更新时间',
  `create_user` BIGINT        DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT        DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_dish_name` (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '菜品';

-- ----------------------------
-- 4. 菜品口味表
-- ----------------------------
DROP TABLE IF EXISTS `dish_flavor`;
CREATE TABLE `dish_flavor` (
  `id`      BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dish_id` BIGINT       NOT NULL COMMENT '菜品id',
  `name`    VARCHAR(32)  DEFAULT NULL COMMENT '口味名称',
  `value`   VARCHAR(255) DEFAULT NULL COMMENT '口味数据list（JSON 数组字符串）',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '菜品口味关系表';

-- ----------------------------
-- 5. 套餐表
-- ----------------------------
DROP TABLE IF EXISTS `setmeal`;
CREATE TABLE `setmeal` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id` BIGINT        NOT NULL COMMENT '菜品分类id',
  `name`        VARCHAR(32)   NOT NULL UNIQUE COMMENT '套餐名称',
  `price`       DECIMAL(10,2) NOT NULL COMMENT '套餐价格',
  `status`      INT           DEFAULT 1 COMMENT '状态 0:停用 1:启用',
  `description` VARCHAR(255)  DEFAULT NULL COMMENT '描述信息',
  `image`       VARCHAR(255)  DEFAULT NULL COMMENT '图片',
  `create_time` DATETIME      DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME      DEFAULT NULL COMMENT '更新时间',
  `create_user` BIGINT        DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT        DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_setmeal_name` (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '套餐';

-- ----------------------------
-- 6. 套餐菜品关系表
-- ----------------------------
DROP TABLE IF EXISTS `setmeal_dish`;
CREATE TABLE `setmeal_dish` (
  `id`         BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `setmeal_id` BIGINT        DEFAULT NULL COMMENT '套餐id',
  `dish_id`    BIGINT        DEFAULT NULL COMMENT '菜品id',
  `name`       VARCHAR(32)   DEFAULT NULL COMMENT '菜品名称（冗余字段）',
  `price`      DECIMAL(10,2) DEFAULT NULL COMMENT '菜品原价（冗余字段）',
  `copies`     INT           DEFAULT NULL COMMENT '份数',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '套餐菜品关系';

-- ----------------------------------------------------------------------------
-- 初始数据
-- 注意：初始密码可以是明文，项目启动时 DataInitializer 会自动升级为 BCrypt。
--       更推荐直接写入 BCrypt 密文。
-- ----------------------------------------------------------------------------
INSERT INTO `employee` (`name`, `username`, `password`, `phone`, `sex`, `id_number`, `status`, `create_time`, `update_time`, `create_user`, `update_user`)
VALUES ('管理员', 'admin', '123456', '13800000000', '1', '110101199001010000', 1, NOW(), NOW(), 1, 1);

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 说明：用户端与订单相关表（尚未在项目中实现）
--   user           用户表（微信用户）
--   address_book   收货地址表
--   shopping_cart  购物车表
--   orders         订单表
--   order_detail   订单明细表
-- 这些表请从黑马课程资料的完整 sky_take_out.sql 中导入。
-- ----------------------------------------------------------------------------
