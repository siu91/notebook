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

 Date: 14/12/2020 14:27:22
*/


-- ----------------------------
-- Table structure for monitor
-- ----------------------------
DROP TABLE IF EXISTS "pgautofailover"."monitor";
CREATE TABLE "pgautofailover"."monitor" (
  "id" int8 NOT NULL DEFAULT nextval('"pgautofailover".monitor_id_seq'::regclass),
  "ip" varchar(255) COLLATE "pg_catalog"."default",
  "nodename" varchar(255) COLLATE "pg_catalog"."default",
  "currentrole" varchar(16) COLLATE "pg_catalog"."default",
  "lastrole" varchar(16) COLLATE "pg_catalog"."default",
  "failovertype" int2,
  "failovertime" timestamp(6) DEFAULT CURRENT_TIMESTAMP(0),
  "reporttime" timestamp(6) DEFAULT CURRENT_TIMESTAMP(0)
)
;

-- ----------------------------
-- Uniques structure for table monitor
-- ----------------------------
ALTER TABLE "pgautofailover"."monitor" ADD CONSTRAINT "u_ip" UNIQUE ("ip");

-- ----------------------------
-- Primary Key structure for table monitor
-- ----------------------------
ALTER TABLE "pgautofailover"."monitor" ADD CONSTRAINT "monitor_pkey" PRIMARY KEY ("id");
