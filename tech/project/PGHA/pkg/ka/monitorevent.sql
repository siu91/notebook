/*
 Navicat Premium Data Transfer

 Source Server         : pg-afom
 Source Server Type    : PostgreSQL
 Source Server Version : 100015
 Source Host           : 192.168.5.181:5431
 Source Catalog        : pg_auto_failover
 Source Schema         : pgautofailover

 Target Server Type    : PostgreSQL
 Target Server Version : 100015
 File Encoding         : 65001

 Date: 14/12/2020 16:49:07
*/


-- ----------------------------
-- Table structure for monitorevent
-- ----------------------------
DROP TABLE IF EXISTS "pgautofailover"."monitorevent";
CREATE TABLE "pgautofailover"."monitorevent" (
  "id" int8 NOT NULL DEFAULT nextval('"pgautofailover".monitor_id_seq'::regclass),
  "ip" varchar(255) COLLATE "pg_catalog"."default",
  "nodename" varchar(255) COLLATE "pg_catalog"."default",
  "currentrole" varchar(16) COLLATE "pg_catalog"."default",
  "lastrole" varchar(16) COLLATE "pg_catalog"."default",
  "failovertype" varchar(256) COLLATE "pg_catalog"."default",
  "failovertime" timestamp(6) DEFAULT CURRENT_TIMESTAMP(0),
  "reporttime" timestamp(6) DEFAULT CURRENT_TIMESTAMP(0)
)
;

-- ----------------------------
-- Primary Key structure for table monitorevent
-- ----------------------------
ALTER TABLE "pgautofailover"."monitorevent" ADD CONSTRAINT "monitor_copy1_pkey" PRIMARY KEY ("id");
