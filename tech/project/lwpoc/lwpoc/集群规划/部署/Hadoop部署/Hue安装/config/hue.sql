/*
 Navicat Premium Data Transfer

 Source Server         : 192.168.5.151
 Source Server Type    : MySQL
 Source Server Version : 50735
 Source Host           : 192.168.5.151:3306
 Source Schema         : hue

 Target Server Type    : MySQL
 Target Server Version : 50735
 File Encoding         : 65001

 Date: 31/08/2021 14:20:25
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for auth_group
-- ----------------------------
DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE `auth_group`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group
-- ----------------------------
INSERT INTO `auth_group` VALUES (1, 'default');

-- ----------------------------
-- Table structure for auth_group_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE `auth_group_permissions`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_group_permissions_group_id_permission_id_0cd325b0_uniq`(`group_id`, `permission_id`) USING BTREE,
  INDEX `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm`(`permission_id`) USING BTREE,
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for auth_permission
-- ----------------------------
DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE `auth_permission`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_permission_content_type_id_codename_01ab375a_uniq`(`content_type_id`, `codename`) USING BTREE,
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 235 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_permission
-- ----------------------------
INSERT INTO `auth_permission` VALUES (1, 'Can add group', 1, 'add_group');
INSERT INTO `auth_permission` VALUES (2, 'Can change group', 1, 'change_group');
INSERT INTO `auth_permission` VALUES (3, 'Can delete group', 1, 'delete_group');
INSERT INTO `auth_permission` VALUES (4, 'Can add permission', 2, 'add_permission');
INSERT INTO `auth_permission` VALUES (5, 'Can change permission', 2, 'change_permission');
INSERT INTO `auth_permission` VALUES (6, 'Can delete permission', 2, 'delete_permission');
INSERT INTO `auth_permission` VALUES (7, 'Can add user', 3, 'add_user');
INSERT INTO `auth_permission` VALUES (8, 'Can change user', 3, 'change_user');
INSERT INTO `auth_permission` VALUES (9, 'Can delete user', 3, 'delete_user');
INSERT INTO `auth_permission` VALUES (10, 'Can add content type', 4, 'add_contenttype');
INSERT INTO `auth_permission` VALUES (11, 'Can change content type', 4, 'change_contenttype');
INSERT INTO `auth_permission` VALUES (12, 'Can delete content type', 4, 'delete_contenttype');
INSERT INTO `auth_permission` VALUES (13, 'Can add session', 5, 'add_session');
INSERT INTO `auth_permission` VALUES (14, 'Can change session', 5, 'change_session');
INSERT INTO `auth_permission` VALUES (15, 'Can delete session', 5, 'delete_session');
INSERT INTO `auth_permission` VALUES (16, 'Can add site', 6, 'add_site');
INSERT INTO `auth_permission` VALUES (17, 'Can change site', 6, 'change_site');
INSERT INTO `auth_permission` VALUES (18, 'Can delete site', 6, 'delete_site');
INSERT INTO `auth_permission` VALUES (19, 'Can add document permission', 7, 'add_documentpermission');
INSERT INTO `auth_permission` VALUES (20, 'Can change document permission', 7, 'change_documentpermission');
INSERT INTO `auth_permission` VALUES (21, 'Can delete document permission', 7, 'delete_documentpermission');
INSERT INTO `auth_permission` VALUES (22, 'Can add default configuration', 8, 'add_defaultconfiguration');
INSERT INTO `auth_permission` VALUES (23, 'Can change default configuration', 8, 'change_defaultconfiguration');
INSERT INTO `auth_permission` VALUES (24, 'Can delete default configuration', 8, 'delete_defaultconfiguration');
INSERT INTO `auth_permission` VALUES (25, 'Can add connector', 9, 'add_connector');
INSERT INTO `auth_permission` VALUES (26, 'Can change connector', 9, 'change_connector');
INSERT INTO `auth_permission` VALUES (27, 'Can delete connector', 9, 'delete_connector');
INSERT INTO `auth_permission` VALUES (28, 'Can add document', 10, 'add_document');
INSERT INTO `auth_permission` VALUES (29, 'Can change document', 10, 'change_document');
INSERT INTO `auth_permission` VALUES (30, 'Can delete document', 10, 'delete_document');
INSERT INTO `auth_permission` VALUES (31, 'Can add document tag', 11, 'add_documenttag');
INSERT INTO `auth_permission` VALUES (32, 'Can change document tag', 11, 'change_documenttag');
INSERT INTO `auth_permission` VALUES (33, 'Can delete document tag', 11, 'delete_documenttag');
INSERT INTO `auth_permission` VALUES (34, 'Can add settings', 12, 'add_settings');
INSERT INTO `auth_permission` VALUES (35, 'Can change settings', 12, 'change_settings');
INSERT INTO `auth_permission` VALUES (36, 'Can delete settings', 12, 'delete_settings');
INSERT INTO `auth_permission` VALUES (37, 'Can add document2', 13, 'add_document2');
INSERT INTO `auth_permission` VALUES (38, 'Can change document2', 13, 'change_document2');
INSERT INTO `auth_permission` VALUES (39, 'Can delete document2', 13, 'delete_document2');
INSERT INTO `auth_permission` VALUES (40, 'Can add document2 permission', 14, 'add_document2permission');
INSERT INTO `auth_permission` VALUES (41, 'Can change document2 permission', 14, 'change_document2permission');
INSERT INTO `auth_permission` VALUES (42, 'Can delete document2 permission', 14, 'delete_document2permission');
INSERT INTO `auth_permission` VALUES (43, 'Can add user preferences', 15, 'add_userpreferences');
INSERT INTO `auth_permission` VALUES (44, 'Can change user preferences', 15, 'change_userpreferences');
INSERT INTO `auth_permission` VALUES (45, 'Can delete user preferences', 15, 'delete_userpreferences');
INSERT INTO `auth_permission` VALUES (46, 'Can add hue user', 3, 'add_hueuser');
INSERT INTO `auth_permission` VALUES (47, 'Can change hue user', 3, 'change_hueuser');
INSERT INTO `auth_permission` VALUES (48, 'Can delete hue user', 3, 'delete_hueuser');
INSERT INTO `auth_permission` VALUES (49, 'Can add directory', 13, 'add_directory');
INSERT INTO `auth_permission` VALUES (50, 'Can change directory', 13, 'change_directory');
INSERT INTO `auth_permission` VALUES (51, 'Can delete directory', 13, 'delete_directory');
INSERT INTO `auth_permission` VALUES (52, 'Can add access log', 18, 'add_accesslog');
INSERT INTO `auth_permission` VALUES (53, 'Can change access log', 18, 'change_accesslog');
INSERT INTO `auth_permission` VALUES (54, 'Can delete access log', 18, 'delete_accesslog');
INSERT INTO `auth_permission` VALUES (55, 'Can add access attempt', 19, 'add_accessattempt');
INSERT INTO `auth_permission` VALUES (56, 'Can change access attempt', 19, 'change_accessattempt');
INSERT INTO `auth_permission` VALUES (57, 'Can delete access attempt', 19, 'delete_accessattempt');
INSERT INTO `auth_permission` VALUES (58, 'Can add Token', 20, 'add_token');
INSERT INTO `auth_permission` VALUES (59, 'Can change Token', 20, 'change_token');
INSERT INTO `auth_permission` VALUES (60, 'Can delete Token', 20, 'delete_token');
INSERT INTO `auth_permission` VALUES (61, 'Can add session', 21, 'add_session');
INSERT INTO `auth_permission` VALUES (62, 'Can change session', 21, 'change_session');
INSERT INTO `auth_permission` VALUES (63, 'Can delete session', 21, 'delete_session');
INSERT INTO `auth_permission` VALUES (64, 'Can add saved query', 22, 'add_savedquery');
INSERT INTO `auth_permission` VALUES (65, 'Can change saved query', 22, 'change_savedquery');
INSERT INTO `auth_permission` VALUES (66, 'Can delete saved query', 22, 'delete_savedquery');
INSERT INTO `auth_permission` VALUES (67, 'Can add meta install', 23, 'add_metainstall');
INSERT INTO `auth_permission` VALUES (68, 'Can change meta install', 23, 'change_metainstall');
INSERT INTO `auth_permission` VALUES (69, 'Can delete meta install', 23, 'delete_metainstall');
INSERT INTO `auth_permission` VALUES (70, 'Can add query history', 24, 'add_queryhistory');
INSERT INTO `auth_permission` VALUES (71, 'Can change query history', 24, 'change_queryhistory');
INSERT INTO `auth_permission` VALUES (72, 'Can delete query history', 24, 'delete_queryhistory');
INSERT INTO `auth_permission` VALUES (73, 'Can add hive server query history', 24, 'add_hiveserverqueryhistory');
INSERT INTO `auth_permission` VALUES (74, 'Can change hive server query history', 24, 'change_hiveserverqueryhistory');
INSERT INTO `auth_permission` VALUES (75, 'Can delete hive server query history', 24, 'delete_hiveserverqueryhistory');
INSERT INTO `auth_permission` VALUES (76, 'Can add hive query', 26, 'add_hivequery');
INSERT INTO `auth_permission` VALUES (77, 'Can change hive query', 26, 'change_hivequery');
INSERT INTO `auth_permission` VALUES (78, 'Can delete hive query', 26, 'delete_hivequery');
INSERT INTO `auth_permission` VALUES (79, 'Can add query details', 27, 'add_querydetails');
INSERT INTO `auth_permission` VALUES (80, 'Can change query details', 27, 'change_querydetails');
INSERT INTO `auth_permission` VALUES (81, 'Can delete query details', 27, 'delete_querydetails');
INSERT INTO `auth_permission` VALUES (82, 'Can add dag info', 28, 'add_daginfo');
INSERT INTO `auth_permission` VALUES (83, 'Can change dag info', 28, 'change_daginfo');
INSERT INTO `auth_permission` VALUES (84, 'Can delete dag info', 28, 'delete_daginfo');
INSERT INTO `auth_permission` VALUES (85, 'Can add dag details', 29, 'add_dagdetails');
INSERT INTO `auth_permission` VALUES (86, 'Can change dag details', 29, 'change_dagdetails');
INSERT INTO `auth_permission` VALUES (87, 'Can delete dag details', 29, 'delete_dagdetails');
INSERT INTO `auth_permission` VALUES (88, 'Can add oozie action', 30, 'add_oozieaction');
INSERT INTO `auth_permission` VALUES (89, 'Can change oozie action', 30, 'change_oozieaction');
INSERT INTO `auth_permission` VALUES (90, 'Can delete oozie action', 30, 'delete_oozieaction');
INSERT INTO `auth_permission` VALUES (91, 'Can add check for setup', 31, 'add_checkforsetup');
INSERT INTO `auth_permission` VALUES (92, 'Can change check for setup', 31, 'change_checkforsetup');
INSERT INTO `auth_permission` VALUES (93, 'Can delete check for setup', 31, 'delete_checkforsetup');
INSERT INTO `auth_permission` VALUES (94, 'Can add job history', 32, 'add_jobhistory');
INSERT INTO `auth_permission` VALUES (95, 'Can change job history', 32, 'change_jobhistory');
INSERT INTO `auth_permission` VALUES (96, 'Can delete job history', 32, 'delete_jobhistory');
INSERT INTO `auth_permission` VALUES (97, 'Can add oozie mapreduce action', 33, 'add_ooziemapreduceaction');
INSERT INTO `auth_permission` VALUES (98, 'Can change oozie mapreduce action', 33, 'change_ooziemapreduceaction');
INSERT INTO `auth_permission` VALUES (99, 'Can delete oozie mapreduce action', 33, 'delete_ooziemapreduceaction');
INSERT INTO `auth_permission` VALUES (100, 'Can add job design', 34, 'add_jobdesign');
INSERT INTO `auth_permission` VALUES (101, 'Can change job design', 34, 'change_jobdesign');
INSERT INTO `auth_permission` VALUES (102, 'Can delete job design', 34, 'delete_jobdesign');
INSERT INTO `auth_permission` VALUES (103, 'Can add oozie java action', 35, 'add_ooziejavaaction');
INSERT INTO `auth_permission` VALUES (104, 'Can change oozie java action', 35, 'change_ooziejavaaction');
INSERT INTO `auth_permission` VALUES (105, 'Can delete oozie java action', 35, 'delete_ooziejavaaction');
INSERT INTO `auth_permission` VALUES (106, 'Can add oozie design', 36, 'add_ooziedesign');
INSERT INTO `auth_permission` VALUES (107, 'Can change oozie design', 36, 'change_ooziedesign');
INSERT INTO `auth_permission` VALUES (108, 'Can delete oozie design', 36, 'delete_ooziedesign');
INSERT INTO `auth_permission` VALUES (109, 'Can add oozie streaming action', 37, 'add_ooziestreamingaction');
INSERT INTO `auth_permission` VALUES (110, 'Can change oozie streaming action', 37, 'change_ooziestreamingaction');
INSERT INTO `auth_permission` VALUES (111, 'Can delete oozie streaming action', 37, 'delete_ooziestreamingaction');
INSERT INTO `auth_permission` VALUES (112, 'Can add bundled coordinator', 38, 'add_bundledcoordinator');
INSERT INTO `auth_permission` VALUES (113, 'Can change bundled coordinator', 38, 'change_bundledcoordinator');
INSERT INTO `auth_permission` VALUES (114, 'Can delete bundled coordinator', 38, 'delete_bundledcoordinator');
INSERT INTO `auth_permission` VALUES (115, 'Can add data output', 39, 'add_dataoutput');
INSERT INTO `auth_permission` VALUES (116, 'Can change data output', 39, 'change_dataoutput');
INSERT INTO `auth_permission` VALUES (117, 'Can delete data output', 39, 'delete_dataoutput');
INSERT INTO `auth_permission` VALUES (118, 'Can add history', 40, 'add_history');
INSERT INTO `auth_permission` VALUES (119, 'Can change history', 40, 'change_history');
INSERT INTO `auth_permission` VALUES (120, 'Can delete history', 40, 'delete_history');
INSERT INTO `auth_permission` VALUES (121, 'Can add link', 41, 'add_link');
INSERT INTO `auth_permission` VALUES (122, 'Can change link', 41, 'change_link');
INSERT INTO `auth_permission` VALUES (123, 'Can delete link', 41, 'delete_link');
INSERT INTO `auth_permission` VALUES (124, 'Can add job', 42, 'add_job');
INSERT INTO `auth_permission` VALUES (125, 'Can change job', 42, 'change_job');
INSERT INTO `auth_permission` VALUES (126, 'Can delete job', 42, 'delete_job');
INSERT INTO `auth_permission` VALUES (127, 'Can add data input', 43, 'add_datainput');
INSERT INTO `auth_permission` VALUES (128, 'Can change data input', 43, 'change_datainput');
INSERT INTO `auth_permission` VALUES (129, 'Can delete data input', 43, 'delete_datainput');
INSERT INTO `auth_permission` VALUES (130, 'Can add coordinator', 44, 'add_coordinator');
INSERT INTO `auth_permission` VALUES (131, 'Can change coordinator', 44, 'change_coordinator');
INSERT INTO `auth_permission` VALUES (132, 'Can delete coordinator', 44, 'delete_coordinator');
INSERT INTO `auth_permission` VALUES (133, 'Can add node', 45, 'add_node');
INSERT INTO `auth_permission` VALUES (134, 'Can change node', 45, 'change_node');
INSERT INTO `auth_permission` VALUES (135, 'Can delete node', 45, 'delete_node');
INSERT INTO `auth_permission` VALUES (136, 'Can add dataset', 46, 'add_dataset');
INSERT INTO `auth_permission` VALUES (137, 'Can change dataset', 46, 'change_dataset');
INSERT INTO `auth_permission` VALUES (138, 'Can delete dataset', 46, 'delete_dataset');
INSERT INTO `auth_permission` VALUES (139, 'Can add ssh', 47, 'add_ssh');
INSERT INTO `auth_permission` VALUES (140, 'Can change ssh', 47, 'change_ssh');
INSERT INTO `auth_permission` VALUES (141, 'Can delete ssh', 47, 'delete_ssh');
INSERT INTO `auth_permission` VALUES (142, 'Can add start', 48, 'add_start');
INSERT INTO `auth_permission` VALUES (143, 'Can change start', 48, 'change_start');
INSERT INTO `auth_permission` VALUES (144, 'Can delete start', 48, 'delete_start');
INSERT INTO `auth_permission` VALUES (145, 'Can add kill', 49, 'add_kill');
INSERT INTO `auth_permission` VALUES (146, 'Can change kill', 49, 'change_kill');
INSERT INTO `auth_permission` VALUES (147, 'Can delete kill', 49, 'delete_kill');
INSERT INTO `auth_permission` VALUES (148, 'Can add fs', 50, 'add_fs');
INSERT INTO `auth_permission` VALUES (149, 'Can change fs', 50, 'change_fs');
INSERT INTO `auth_permission` VALUES (150, 'Can delete fs', 50, 'delete_fs');
INSERT INTO `auth_permission` VALUES (151, 'Can add decision end', 51, 'add_decisionend');
INSERT INTO `auth_permission` VALUES (152, 'Can change decision end', 51, 'change_decisionend');
INSERT INTO `auth_permission` VALUES (153, 'Can delete decision end', 51, 'delete_decisionend');
INSERT INTO `auth_permission` VALUES (154, 'Can add join', 52, 'add_join');
INSERT INTO `auth_permission` VALUES (155, 'Can change join', 52, 'change_join');
INSERT INTO `auth_permission` VALUES (156, 'Can delete join', 52, 'delete_join');
INSERT INTO `auth_permission` VALUES (157, 'Can add mapreduce', 53, 'add_mapreduce');
INSERT INTO `auth_permission` VALUES (158, 'Can change mapreduce', 53, 'change_mapreduce');
INSERT INTO `auth_permission` VALUES (159, 'Can delete mapreduce', 53, 'delete_mapreduce');
INSERT INTO `auth_permission` VALUES (160, 'Can add decision', 54, 'add_decision');
INSERT INTO `auth_permission` VALUES (161, 'Can change decision', 54, 'change_decision');
INSERT INTO `auth_permission` VALUES (162, 'Can delete decision', 54, 'delete_decision');
INSERT INTO `auth_permission` VALUES (163, 'Can add email', 55, 'add_email');
INSERT INTO `auth_permission` VALUES (164, 'Can change email', 55, 'change_email');
INSERT INTO `auth_permission` VALUES (165, 'Can delete email', 55, 'delete_email');
INSERT INTO `auth_permission` VALUES (166, 'Can add workflow', 56, 'add_workflow');
INSERT INTO `auth_permission` VALUES (167, 'Can change workflow', 56, 'change_workflow');
INSERT INTO `auth_permission` VALUES (168, 'Can delete workflow', 56, 'delete_workflow');
INSERT INTO `auth_permission` VALUES (169, 'Can add java', 57, 'add_java');
INSERT INTO `auth_permission` VALUES (170, 'Can change java', 57, 'change_java');
INSERT INTO `auth_permission` VALUES (171, 'Can delete java', 57, 'delete_java');
INSERT INTO `auth_permission` VALUES (172, 'Can add fork', 58, 'add_fork');
INSERT INTO `auth_permission` VALUES (173, 'Can change fork', 58, 'change_fork');
INSERT INTO `auth_permission` VALUES (174, 'Can delete fork', 58, 'delete_fork');
INSERT INTO `auth_permission` VALUES (175, 'Can add generic', 59, 'add_generic');
INSERT INTO `auth_permission` VALUES (176, 'Can change generic', 59, 'change_generic');
INSERT INTO `auth_permission` VALUES (177, 'Can delete generic', 59, 'delete_generic');
INSERT INTO `auth_permission` VALUES (178, 'Can add pig', 60, 'add_pig');
INSERT INTO `auth_permission` VALUES (179, 'Can change pig', 60, 'change_pig');
INSERT INTO `auth_permission` VALUES (180, 'Can delete pig', 60, 'delete_pig');
INSERT INTO `auth_permission` VALUES (181, 'Can add dist cp', 61, 'add_distcp');
INSERT INTO `auth_permission` VALUES (182, 'Can change dist cp', 61, 'change_distcp');
INSERT INTO `auth_permission` VALUES (183, 'Can delete dist cp', 61, 'delete_distcp');
INSERT INTO `auth_permission` VALUES (184, 'Can add sub workflow', 62, 'add_subworkflow');
INSERT INTO `auth_permission` VALUES (185, 'Can change sub workflow', 62, 'change_subworkflow');
INSERT INTO `auth_permission` VALUES (186, 'Can delete sub workflow', 62, 'delete_subworkflow');
INSERT INTO `auth_permission` VALUES (187, 'Can add bundle', 63, 'add_bundle');
INSERT INTO `auth_permission` VALUES (188, 'Can change bundle', 63, 'change_bundle');
INSERT INTO `auth_permission` VALUES (189, 'Can delete bundle', 63, 'delete_bundle');
INSERT INTO `auth_permission` VALUES (190, 'Can add end', 64, 'add_end');
INSERT INTO `auth_permission` VALUES (191, 'Can change end', 64, 'change_end');
INSERT INTO `auth_permission` VALUES (192, 'Can delete end', 64, 'delete_end');
INSERT INTO `auth_permission` VALUES (193, 'Can add sqoop', 65, 'add_sqoop');
INSERT INTO `auth_permission` VALUES (194, 'Can change sqoop', 65, 'change_sqoop');
INSERT INTO `auth_permission` VALUES (195, 'Can delete sqoop', 65, 'delete_sqoop');
INSERT INTO `auth_permission` VALUES (196, 'Can add streaming', 66, 'add_streaming');
INSERT INTO `auth_permission` VALUES (197, 'Can change streaming', 66, 'change_streaming');
INSERT INTO `auth_permission` VALUES (198, 'Can delete streaming', 66, 'delete_streaming');
INSERT INTO `auth_permission` VALUES (199, 'Can add shell', 67, 'add_shell');
INSERT INTO `auth_permission` VALUES (200, 'Can change shell', 67, 'change_shell');
INSERT INTO `auth_permission` VALUES (201, 'Can delete shell', 67, 'delete_shell');
INSERT INTO `auth_permission` VALUES (202, 'Can add hive', 68, 'add_hive');
INSERT INTO `auth_permission` VALUES (203, 'Can change hive', 68, 'change_hive');
INSERT INTO `auth_permission` VALUES (204, 'Can delete hive', 68, 'delete_hive');
INSERT INTO `auth_permission` VALUES (205, 'Can add document', 69, 'add_document');
INSERT INTO `auth_permission` VALUES (206, 'Can change document', 69, 'change_document');
INSERT INTO `auth_permission` VALUES (207, 'Can delete document', 69, 'delete_document');
INSERT INTO `auth_permission` VALUES (208, 'Can add pig script', 70, 'add_pigscript');
INSERT INTO `auth_permission` VALUES (209, 'Can change pig script', 70, 'change_pigscript');
INSERT INTO `auth_permission` VALUES (210, 'Can delete pig script', 70, 'delete_pigscript');
INSERT INTO `auth_permission` VALUES (211, 'Can add facet', 71, 'add_facet');
INSERT INTO `auth_permission` VALUES (212, 'Can change facet', 71, 'change_facet');
INSERT INTO `auth_permission` VALUES (213, 'Can delete facet', 71, 'delete_facet');
INSERT INTO `auth_permission` VALUES (214, 'Can add sorting', 72, 'add_sorting');
INSERT INTO `auth_permission` VALUES (215, 'Can change sorting', 72, 'change_sorting');
INSERT INTO `auth_permission` VALUES (216, 'Can delete sorting', 72, 'delete_sorting');
INSERT INTO `auth_permission` VALUES (217, 'Can add collection', 73, 'add_collection');
INSERT INTO `auth_permission` VALUES (218, 'Can change collection', 73, 'change_collection');
INSERT INTO `auth_permission` VALUES (219, 'Can delete collection', 73, 'delete_collection');
INSERT INTO `auth_permission` VALUES (220, 'Can add result', 74, 'add_result');
INSERT INTO `auth_permission` VALUES (221, 'Can change result', 74, 'change_result');
INSERT INTO `auth_permission` VALUES (222, 'Can delete result', 74, 'delete_result');
INSERT INTO `auth_permission` VALUES (223, 'Can add user profile', 75, 'add_userprofile');
INSERT INTO `auth_permission` VALUES (224, 'Can change user profile', 75, 'change_userprofile');
INSERT INTO `auth_permission` VALUES (225, 'Can delete user profile', 75, 'delete_userprofile');
INSERT INTO `auth_permission` VALUES (226, 'Can add group permission', 76, 'add_grouppermission');
INSERT INTO `auth_permission` VALUES (227, 'Can change group permission', 76, 'change_grouppermission');
INSERT INTO `auth_permission` VALUES (228, 'Can delete group permission', 76, 'delete_grouppermission');
INSERT INTO `auth_permission` VALUES (229, 'Can add Connector permission', 77, 'add_huepermission');
INSERT INTO `auth_permission` VALUES (230, 'Can change Connector permission', 77, 'change_huepermission');
INSERT INTO `auth_permission` VALUES (231, 'Can delete Connector permission', 77, 'delete_huepermission');
INSERT INTO `auth_permission` VALUES (232, 'Can add ldap group', 78, 'add_ldapgroup');
INSERT INTO `auth_permission` VALUES (233, 'Can change ldap group', 78, 'change_ldapgroup');
INSERT INTO `auth_permission` VALUES (234, 'Can delete ldap group', 78, 'delete_ldapgroup');

-- ----------------------------
-- Table structure for auth_user
-- ----------------------------
DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE `auth_user`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_login` datetime(6) NULL DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `first_name` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_name` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `email` varchar(254) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1100715 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user
-- ----------------------------
INSERT INTO `auth_user` VALUES (1100713, '!', NULL, 0, 'hue', '', '', '', 0, 0, '2021-08-30 23:10:17.211470');
INSERT INTO `auth_user` VALUES (1100714, 'pbkdf2_sha256$36000$2QRBAG3MeHBv$hy81jxO0Ilb1qDeJ5y1IwpsjPvm6MplL8Oh/jTgUE2M=', '2021-08-30 23:10:32.739938', 1, 'admin', '', '', '', 0, 1, '2021-08-30 23:10:32.654408');

-- ----------------------------
-- Table structure for auth_user_groups
-- ----------------------------
DROP TABLE IF EXISTS `auth_user_groups`;
CREATE TABLE `auth_user_groups`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_user_groups_user_id_group_id_94350c0c_uniq`(`user_id`, `group_id`) USING BTREE,
  INDEX `auth_user_groups_group_id_97559544_fk_auth_group_id`(`group_id`) USING BTREE,
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user_groups
-- ----------------------------
INSERT INTO `auth_user_groups` VALUES (1, 1100713, 1);
INSERT INTO `auth_user_groups` VALUES (2, 1100714, 1);

-- ----------------------------
-- Table structure for auth_user_user_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_user_user_permissions`;
CREATE TABLE `auth_user_user_permissions`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq`(`user_id`, `permission_id`) USING BTREE,
  INDEX `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm`(`permission_id`) USING BTREE,
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for authtoken_token
-- ----------------------------
DROP TABLE IF EXISTS `authtoken_token`;
CREATE TABLE `authtoken_token`  (
  `key` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `created` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`key`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id`) USING BTREE,
  CONSTRAINT `authtoken_token_user_id_35299eff_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for axes_accessattempt
-- ----------------------------
DROP TABLE IF EXISTS `axes_accessattempt`;
CREATE TABLE `axes_accessattempt`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_agent` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `ip_address` char(39) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `http_accept` varchar(1025) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `path_info` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `attempt_time` datetime(6) NOT NULL,
  `get_data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `post_data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `failures_since_start` int(10) UNSIGNED NOT NULL,
  `trusted` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `axes_accessattempt_ip_address_10922d9c`(`ip_address`) USING BTREE,
  INDEX `axes_accessattempt_user_agent_ad89678b`(`user_agent`) USING BTREE,
  INDEX `axes_accessattempt_username_3f2d4ca0`(`username`) USING BTREE,
  INDEX `axes_accessattempt_trusted_0eddf52e`(`trusted`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for axes_accesslog
-- ----------------------------
DROP TABLE IF EXISTS `axes_accesslog`;
CREATE TABLE `axes_accesslog`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_agent` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `ip_address` char(39) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `trusted` tinyint(1) NOT NULL,
  `http_accept` varchar(1025) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `path_info` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `attempt_time` datetime(6) NOT NULL,
  `logout_time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `axes_accesslog_ip_address_86b417e5`(`ip_address`) USING BTREE,
  INDEX `axes_accesslog_trusted_496c5681`(`trusted`) USING BTREE,
  INDEX `axes_accesslog_user_agent_0e659004`(`user_agent`) USING BTREE,
  INDEX `axes_accesslog_username_df93064b`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of axes_accesslog
-- ----------------------------
INSERT INTO `axes_accesslog` VALUES (1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36 Edg/92.0.902.67', '192.168.31.175', 'admin', 1, 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9', '/hue/accounts/login', '2021-08-30 23:10:32.938206', NULL);

-- ----------------------------
-- Table structure for beeswax_metainstall
-- ----------------------------
DROP TABLE IF EXISTS `beeswax_metainstall`;
CREATE TABLE `beeswax_metainstall`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `installed_example` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for beeswax_queryhistory
-- ----------------------------
DROP TABLE IF EXISTS `beeswax_queryhistory`;
CREATE TABLE `beeswax_queryhistory`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_state` int(11) NOT NULL,
  `has_results` tinyint(1) NOT NULL,
  `submission_date` datetime(6) NOT NULL,
  `server_id` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `server_guid` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `statement_number` smallint(6) NOT NULL,
  `operation_type` smallint(6) NULL DEFAULT NULL,
  `modified_row_count` double NULL DEFAULT NULL,
  `log_context` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `server_host` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `server_port` int(10) UNSIGNED NOT NULL,
  `server_name` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `server_type` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `query_type` smallint(6) NOT NULL,
  `notify` tinyint(1) NOT NULL,
  `is_redacted` tinyint(1) NOT NULL,
  `extra` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `is_cleared` tinyint(1) NOT NULL,
  `design_id` int(11) NULL DEFAULT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `beeswax_queryhistory_last_state_3b123643`(`last_state`) USING BTREE,
  INDEX `beeswax_queryhistory_design_id_8b19f1ba_fk_beeswax_savedquery_id`(`design_id`) USING BTREE,
  INDEX `beeswax_queryhistory_owner_id_f56d0c52_fk_auth_user_id`(`owner_id`) USING BTREE,
  CONSTRAINT `beeswax_queryhistory_design_id_8b19f1ba_fk_beeswax_savedquery_id` FOREIGN KEY (`design_id`) REFERENCES `beeswax_savedquery` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `beeswax_queryhistory_owner_id_f56d0c52_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for beeswax_savedquery
-- ----------------------------
DROP TABLE IF EXISTS `beeswax_savedquery`;
CREATE TABLE `beeswax_savedquery`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `name` varchar(80) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `desc` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `mtime` datetime(6) NOT NULL,
  `is_auto` tinyint(1) NOT NULL,
  `is_trashed` tinyint(1) NOT NULL,
  `is_redacted` tinyint(1) NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `beeswax_savedquery_owner_id_f98eb824_fk_auth_user_id`(`owner_id`) USING BTREE,
  INDEX `beeswax_savedquery_is_auto_7ba521ab`(`is_auto`) USING BTREE,
  INDEX `beeswax_savedquery_is_trashed_8dc60321`(`is_trashed`) USING BTREE,
  CONSTRAINT `beeswax_savedquery_owner_id_f98eb824_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for beeswax_session
-- ----------------------------
DROP TABLE IF EXISTS `beeswax_session`;
CREATE TABLE `beeswax_session`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status_code` smallint(5) UNSIGNED NOT NULL,
  `secret` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `guid` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `server_protocol_version` smallint(6) NOT NULL,
  `last_used` datetime(6) NOT NULL,
  `application` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `beeswax_session_owner_id_46797e50_fk_auth_user_id`(`owner_id`) USING BTREE,
  INDEX `beeswax_session_last_used_df0f793b`(`last_used`) USING BTREE,
  CONSTRAINT `beeswax_session_owner_id_46797e50_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for defaultconfiguration_groups
-- ----------------------------
DROP TABLE IF EXISTS `defaultconfiguration_groups`;
CREATE TABLE `defaultconfiguration_groups`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `defaultconfiguration_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `defaultconfiguration_gro_defaultconfiguration_id__89a9cd30_uniq`(`defaultconfiguration_id`, `group_id`) USING BTREE,
  INDEX `defaultconfiguration_groups_group_id_f9733e62_fk_auth_group_id`(`group_id`) USING BTREE,
  CONSTRAINT `defaultconfiguration_defaultconfiguration_16cbc944_fk_desktop_d` FOREIGN KEY (`defaultconfiguration_id`) REFERENCES `desktop_defaultconfiguration` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `defaultconfiguration_groups_group_id_f9733e62_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_connector
-- ----------------------------
DROP TABLE IF EXISTS `desktop_connector`;
CREATE TABLE `desktop_connector`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `dialect` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `settings` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_modified` datetime(6) NOT NULL,
  `interface` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `desktop_connector_name_0a0d3fbc_uniq`(`name`) USING BTREE,
  INDEX `desktop_connector_dialect_0d1539ca`(`dialect`) USING BTREE,
  INDEX `desktop_connector_last_modified_954fecde`(`last_modified`) USING BTREE,
  INDEX `desktop_connector_interface_2a9a31a6`(`interface`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_defaultconfiguration
-- ----------------------------
DROP TABLE IF EXISTS `desktop_defaultconfiguration`;
CREATE TABLE `desktop_defaultconfiguration`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `is_default` tinyint(1) NOT NULL,
  `user_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `desktop_defaultconfiguration_app_2a22dcdc`(`app`) USING BTREE,
  INDEX `desktop_defaultconfiguration_is_default_3a224335`(`is_default`) USING BTREE,
  INDEX `desktop_defaultconfiguration_user_id_8611da32_fk_auth_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `desktop_defaultconfiguration_user_id_8611da32_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_document
-- ----------------------------
DROP TABLE IF EXISTS `desktop_document`;
CREATE TABLE `desktop_document`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_modified` datetime(6) NOT NULL,
  `version` smallint(6) NOT NULL,
  `extra` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `object_id` int(10) UNSIGNED NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `desktop_document_content_type_id_object_id_af1b9053_uniq`(`content_type_id`, `object_id`) USING BTREE,
  INDEX `desktop_document_last_modified_36ad4264`(`last_modified`) USING BTREE,
  INDEX `desktop_document_owner_id_6209716b_fk_auth_user_id`(`owner_id`) USING BTREE,
  CONSTRAINT `desktop_document_content_type_id_fe7f05ef_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `desktop_document_owner_id_6209716b_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_document2
-- ----------------------------
DROP TABLE IF EXISTS `desktop_document2`;
CREATE TABLE `desktop_document2`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `uuid` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `extra` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_modified` datetime(6) NOT NULL,
  `version` smallint(6) NOT NULL,
  `is_history` tinyint(1) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `parent_directory_id` int(11) NULL DEFAULT NULL,
  `search` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `is_trashed` tinyint(1) NULL DEFAULT NULL,
  `is_managed` tinyint(1) NOT NULL,
  `connector_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `desktop_document2_uuid_version_is_history_f449ad78_uniq`(`uuid`, `version`, `is_history`) USING BTREE,
  INDEX `desktop_document2_uuid_01e04a24`(`uuid`) USING BTREE,
  INDEX `desktop_document2_type_7a9e90a7`(`type`) USING BTREE,
  INDEX `desktop_document2_last_modified_15243c0d`(`last_modified`) USING BTREE,
  INDEX `desktop_document2_version_2299c6bb`(`version`) USING BTREE,
  INDEX `desktop_document2_is_history_c15f5853`(`is_history`) USING BTREE,
  INDEX `desktop_document2_owner_id_342662fe_fk_auth_user_id`(`owner_id`) USING BTREE,
  INDEX `desktop_document2_parent_directory_id_428ead9c_fk_desktop_d`(`parent_directory_id`) USING BTREE,
  INDEX `desktop_document2_is_trashed_e36a0b8a`(`is_trashed`) USING BTREE,
  INDEX `desktop_document2_is_managed_572d9c22`(`is_managed`) USING BTREE,
  INDEX `desktop_document2_connector_id_62b342cf_fk_desktop_connector_id`(`connector_id`) USING BTREE,
  CONSTRAINT `desktop_document2_connector_id_62b342cf_fk_desktop_connector_id` FOREIGN KEY (`connector_id`) REFERENCES `desktop_connector` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `desktop_document2_owner_id_342662fe_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `desktop_document2_parent_directory_id_428ead9c_fk_desktop_d` FOREIGN KEY (`parent_directory_id`) REFERENCES `desktop_document2` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_document2_dependencies
-- ----------------------------
DROP TABLE IF EXISTS `desktop_document2_dependencies`;
CREATE TABLE `desktop_document2_dependencies`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `from_document2_id` int(11) NOT NULL,
  `to_document2_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `desktop_document2_depend_from_document2_id_to_doc_e8e0aebc_uniq`(`from_document2_id`, `to_document2_id`) USING BTREE,
  INDEX `desktop_document2_de_to_document2_id_2a18afeb_fk_desktop_d`(`to_document2_id`) USING BTREE,
  CONSTRAINT `desktop_document2_de_from_document2_id_e5f62f5a_fk_desktop_d` FOREIGN KEY (`from_document2_id`) REFERENCES `desktop_document2` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `desktop_document2_de_to_document2_id_2a18afeb_fk_desktop_d` FOREIGN KEY (`to_document2_id`) REFERENCES `desktop_document2` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_document2permission
-- ----------------------------
DROP TABLE IF EXISTS `desktop_document2permission`;
CREATE TABLE `desktop_document2permission`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `perms` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `doc_id` int(11) NOT NULL,
  `is_link_on` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `desktop_document2permission_doc_id_perms_5a4d2ad8_uniq`(`doc_id`, `perms`) USING BTREE,
  INDEX `desktop_document2permission_perms_449c1144`(`perms`) USING BTREE,
  CONSTRAINT `desktop_document2per_doc_id_b851e790_fk_desktop_d` FOREIGN KEY (`doc_id`) REFERENCES `desktop_document2` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_document_tags
-- ----------------------------
DROP TABLE IF EXISTS `desktop_document_tags`;
CREATE TABLE `desktop_document_tags`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document_id` int(11) NOT NULL,
  `documenttag_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `desktop_document_tags_document_id_documenttag_id_b89a0f94_uniq`(`document_id`, `documenttag_id`) USING BTREE,
  INDEX `desktop_document_tag_documenttag_id_4ac450c6_fk_desktop_d`(`documenttag_id`) USING BTREE,
  CONSTRAINT `desktop_document_tag_document_id_97885747_fk_desktop_d` FOREIGN KEY (`document_id`) REFERENCES `desktop_document` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `desktop_document_tag_documenttag_id_4ac450c6_fk_desktop_d` FOREIGN KEY (`documenttag_id`) REFERENCES `desktop_documenttag` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_documentpermission
-- ----------------------------
DROP TABLE IF EXISTS `desktop_documentpermission`;
CREATE TABLE `desktop_documentpermission`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `perms` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `doc_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `desktop_documentpermission_doc_id_perms_e898a5e1_uniq`(`doc_id`, `perms`) USING BTREE,
  CONSTRAINT `desktop_documentperm_doc_id_f3913804_fk_desktop_d` FOREIGN KEY (`doc_id`) REFERENCES `desktop_document` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_documenttag
-- ----------------------------
DROP TABLE IF EXISTS `desktop_documenttag`;
CREATE TABLE `desktop_documenttag`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `desktop_documenttag_owner_id_tag_040d0073_uniq`(`owner_id`, `tag`) USING BTREE,
  INDEX `desktop_documenttag_tag_0cc3fdde`(`tag`) USING BTREE,
  CONSTRAINT `desktop_documenttag_owner_id_74dfe3a5_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for desktop_settings
-- ----------------------------
DROP TABLE IF EXISTS `desktop_settings`;
CREATE TABLE `desktop_settings`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collect_usage` tinyint(1) NOT NULL,
  `tours_and_tutorials` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `desktop_settings_collect_usage_a62e7068`(`collect_usage`) USING BTREE,
  INDEX `desktop_settings_tours_and_tutorials_376b46bd`(`tours_and_tutorials`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of desktop_settings
-- ----------------------------
INSERT INTO `desktop_settings` VALUES (1, 1, 1);

-- ----------------------------
-- Table structure for desktop_userpreferences
-- ----------------------------
DROP TABLE IF EXISTS `desktop_userpreferences`;
CREATE TABLE `desktop_userpreferences`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `value` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `desktop_userpreferences_user_id_f372df8e_fk_auth_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `desktop_userpreferences_user_id_f372df8e_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of desktop_userpreferences
-- ----------------------------
INSERT INTO `desktop_userpreferences` VALUES (1, 'is_welcome_tour_seen', 'seen', 1100714);

-- ----------------------------
-- Table structure for django_content_type
-- ----------------------------
DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE `django_content_type`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `model` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `django_content_type_app_label_model_76bd3d3b_uniq`(`app_label`, `model`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 79 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_content_type
-- ----------------------------
INSERT INTO `django_content_type` VALUES (1, 'auth', 'group');
INSERT INTO `django_content_type` VALUES (2, 'auth', 'permission');
INSERT INTO `django_content_type` VALUES (3, 'auth', 'user');
INSERT INTO `django_content_type` VALUES (20, 'authtoken', 'token');
INSERT INTO `django_content_type` VALUES (19, 'axes', 'accessattempt');
INSERT INTO `django_content_type` VALUES (18, 'axes', 'accesslog');
INSERT INTO `django_content_type` VALUES (25, 'beeswax', 'hiveserverqueryhistory');
INSERT INTO `django_content_type` VALUES (23, 'beeswax', 'metainstall');
INSERT INTO `django_content_type` VALUES (24, 'beeswax', 'queryhistory');
INSERT INTO `django_content_type` VALUES (22, 'beeswax', 'savedquery');
INSERT INTO `django_content_type` VALUES (21, 'beeswax', 'session');
INSERT INTO `django_content_type` VALUES (4, 'contenttypes', 'contenttype');
INSERT INTO `django_content_type` VALUES (9, 'desktop', 'connector');
INSERT INTO `django_content_type` VALUES (8, 'desktop', 'defaultconfiguration');
INSERT INTO `django_content_type` VALUES (17, 'desktop', 'directory');
INSERT INTO `django_content_type` VALUES (10, 'desktop', 'document');
INSERT INTO `django_content_type` VALUES (13, 'desktop', 'document2');
INSERT INTO `django_content_type` VALUES (14, 'desktop', 'document2permission');
INSERT INTO `django_content_type` VALUES (7, 'desktop', 'documentpermission');
INSERT INTO `django_content_type` VALUES (11, 'desktop', 'documenttag');
INSERT INTO `django_content_type` VALUES (16, 'desktop', 'hueuser');
INSERT INTO `django_content_type` VALUES (12, 'desktop', 'settings');
INSERT INTO `django_content_type` VALUES (15, 'desktop', 'userpreferences');
INSERT INTO `django_content_type` VALUES (29, 'jobbrowser', 'dagdetails');
INSERT INTO `django_content_type` VALUES (28, 'jobbrowser', 'daginfo');
INSERT INTO `django_content_type` VALUES (26, 'jobbrowser', 'hivequery');
INSERT INTO `django_content_type` VALUES (27, 'jobbrowser', 'querydetails');
INSERT INTO `django_content_type` VALUES (31, 'jobsub', 'checkforsetup');
INSERT INTO `django_content_type` VALUES (34, 'jobsub', 'jobdesign');
INSERT INTO `django_content_type` VALUES (32, 'jobsub', 'jobhistory');
INSERT INTO `django_content_type` VALUES (30, 'jobsub', 'oozieaction');
INSERT INTO `django_content_type` VALUES (36, 'jobsub', 'ooziedesign');
INSERT INTO `django_content_type` VALUES (35, 'jobsub', 'ooziejavaaction');
INSERT INTO `django_content_type` VALUES (33, 'jobsub', 'ooziemapreduceaction');
INSERT INTO `django_content_type` VALUES (37, 'jobsub', 'ooziestreamingaction');
INSERT INTO `django_content_type` VALUES (63, 'oozie', 'bundle');
INSERT INTO `django_content_type` VALUES (38, 'oozie', 'bundledcoordinator');
INSERT INTO `django_content_type` VALUES (44, 'oozie', 'coordinator');
INSERT INTO `django_content_type` VALUES (43, 'oozie', 'datainput');
INSERT INTO `django_content_type` VALUES (39, 'oozie', 'dataoutput');
INSERT INTO `django_content_type` VALUES (46, 'oozie', 'dataset');
INSERT INTO `django_content_type` VALUES (54, 'oozie', 'decision');
INSERT INTO `django_content_type` VALUES (51, 'oozie', 'decisionend');
INSERT INTO `django_content_type` VALUES (61, 'oozie', 'distcp');
INSERT INTO `django_content_type` VALUES (55, 'oozie', 'email');
INSERT INTO `django_content_type` VALUES (64, 'oozie', 'end');
INSERT INTO `django_content_type` VALUES (58, 'oozie', 'fork');
INSERT INTO `django_content_type` VALUES (50, 'oozie', 'fs');
INSERT INTO `django_content_type` VALUES (59, 'oozie', 'generic');
INSERT INTO `django_content_type` VALUES (40, 'oozie', 'history');
INSERT INTO `django_content_type` VALUES (68, 'oozie', 'hive');
INSERT INTO `django_content_type` VALUES (57, 'oozie', 'java');
INSERT INTO `django_content_type` VALUES (42, 'oozie', 'job');
INSERT INTO `django_content_type` VALUES (52, 'oozie', 'join');
INSERT INTO `django_content_type` VALUES (49, 'oozie', 'kill');
INSERT INTO `django_content_type` VALUES (41, 'oozie', 'link');
INSERT INTO `django_content_type` VALUES (53, 'oozie', 'mapreduce');
INSERT INTO `django_content_type` VALUES (45, 'oozie', 'node');
INSERT INTO `django_content_type` VALUES (60, 'oozie', 'pig');
INSERT INTO `django_content_type` VALUES (67, 'oozie', 'shell');
INSERT INTO `django_content_type` VALUES (65, 'oozie', 'sqoop');
INSERT INTO `django_content_type` VALUES (47, 'oozie', 'ssh');
INSERT INTO `django_content_type` VALUES (48, 'oozie', 'start');
INSERT INTO `django_content_type` VALUES (66, 'oozie', 'streaming');
INSERT INTO `django_content_type` VALUES (62, 'oozie', 'subworkflow');
INSERT INTO `django_content_type` VALUES (56, 'oozie', 'workflow');
INSERT INTO `django_content_type` VALUES (69, 'pig', 'document');
INSERT INTO `django_content_type` VALUES (70, 'pig', 'pigscript');
INSERT INTO `django_content_type` VALUES (73, 'search', 'collection');
INSERT INTO `django_content_type` VALUES (71, 'search', 'facet');
INSERT INTO `django_content_type` VALUES (74, 'search', 'result');
INSERT INTO `django_content_type` VALUES (72, 'search', 'sorting');
INSERT INTO `django_content_type` VALUES (5, 'sessions', 'session');
INSERT INTO `django_content_type` VALUES (6, 'sites', 'site');
INSERT INTO `django_content_type` VALUES (76, 'useradmin', 'grouppermission');
INSERT INTO `django_content_type` VALUES (77, 'useradmin', 'huepermission');
INSERT INTO `django_content_type` VALUES (78, 'useradmin', 'ldapgroup');
INSERT INTO `django_content_type` VALUES (75, 'useradmin', 'userprofile');

-- ----------------------------
-- Table structure for django_migrations
-- ----------------------------
DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE `django_migrations`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 53 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_migrations
-- ----------------------------
INSERT INTO `django_migrations` VALUES (1, 'contenttypes', '0001_initial', '2021-08-30 23:08:36.949659');
INSERT INTO `django_migrations` VALUES (2, 'contenttypes', '0002_remove_content_type_name', '2021-08-30 23:08:37.003529');
INSERT INTO `django_migrations` VALUES (3, 'auth', '0001_initial', '2021-08-30 23:08:37.257930');
INSERT INTO `django_migrations` VALUES (4, 'auth', '0002_alter_permission_name_max_length', '2021-08-30 23:08:37.280685');
INSERT INTO `django_migrations` VALUES (5, 'auth', '0003_alter_user_email_max_length', '2021-08-30 23:08:37.300662');
INSERT INTO `django_migrations` VALUES (6, 'auth', '0004_alter_user_username_opts', '2021-08-30 23:08:37.316699');
INSERT INTO `django_migrations` VALUES (7, 'auth', '0005_alter_user_last_login_null', '2021-08-30 23:08:37.339989');
INSERT INTO `django_migrations` VALUES (8, 'auth', '0006_require_contenttypes_0002', '2021-08-30 23:08:37.341558');
INSERT INTO `django_migrations` VALUES (9, 'auth', '0007_alter_validators_add_error_messages', '2021-08-30 23:08:37.356371');
INSERT INTO `django_migrations` VALUES (10, 'auth', '0008_alter_user_username_max_length', '2021-08-30 23:08:37.377020');
INSERT INTO `django_migrations` VALUES (11, 'authtoken', '0001_initial', '2021-08-30 23:08:37.407270');
INSERT INTO `django_migrations` VALUES (12, 'authtoken', '0002_auto_20160226_1747', '2021-08-30 23:08:37.486301');
INSERT INTO `django_migrations` VALUES (13, 'axes', '0001_initial', '2021-08-30 23:08:37.526153');
INSERT INTO `django_migrations` VALUES (14, 'axes', '0002_auto_20151217_2044', '2021-08-30 23:08:37.646237');
INSERT INTO `django_migrations` VALUES (15, 'axes', '0003_auto_20160322_0929', '2021-08-30 23:08:37.706451');
INSERT INTO `django_migrations` VALUES (16, 'axes', '0004_auto_20181024_1538', '2021-08-30 23:08:37.781195');
INSERT INTO `django_migrations` VALUES (17, 'axes', '0005_remove_accessattempt_trusted', '2021-08-30 23:08:37.801277');
INSERT INTO `django_migrations` VALUES (18, 'axes', '0006_add_accessattempt_trusted', '2021-08-30 23:08:37.830448');
INSERT INTO `django_migrations` VALUES (19, 'beeswax', '0001_initial', '2021-08-30 23:08:38.026423');
INSERT INTO `django_migrations` VALUES (20, 'beeswax', '0002_auto_20200320_0746', '2021-08-30 23:08:38.070196');
INSERT INTO `django_migrations` VALUES (21, 'desktop', '0001_initial', '2021-08-30 23:08:39.092328');
INSERT INTO `django_migrations` VALUES (22, 'desktop', '0002_initial', '2021-08-30 23:08:39.220828');
INSERT INTO `django_migrations` VALUES (23, 'desktop', '0003_initial', '2021-08-30 23:08:39.230329');
INSERT INTO `django_migrations` VALUES (24, 'desktop', '0004_initial', '2021-08-30 23:08:39.239537');
INSERT INTO `django_migrations` VALUES (25, 'desktop', '0005_initial', '2021-08-30 23:08:39.288753');
INSERT INTO `django_migrations` VALUES (26, 'desktop', '0006_initial', '2021-08-30 23:08:39.343967');
INSERT INTO `django_migrations` VALUES (27, 'desktop', '0007_initial', '2021-08-30 23:08:39.403340');
INSERT INTO `django_migrations` VALUES (28, 'desktop', '0008_auto_20191031_0704', '2021-08-30 23:08:39.453011');
INSERT INTO `django_migrations` VALUES (29, 'desktop', '0009_auto_20191202_1056', '2021-08-30 23:08:39.539804');
INSERT INTO `django_migrations` VALUES (30, 'desktop', '0010_auto_20200115_0908', '2021-08-30 23:08:39.576347');
INSERT INTO `django_migrations` VALUES (31, 'desktop', '0011_document2_connector', '2021-08-30 23:08:39.645783');
INSERT INTO `django_migrations` VALUES (32, 'desktop', '0012_connector_interface', '2021-08-30 23:08:39.676975');
INSERT INTO `django_migrations` VALUES (33, 'jobsub', '0001_initial', '2021-08-30 23:08:40.223413');
INSERT INTO `django_migrations` VALUES (34, 'oozie', '0001_initial', '2021-08-30 23:08:41.181511');
INSERT INTO `django_migrations` VALUES (35, 'oozie', '0002_initial', '2021-08-30 23:08:41.223774');
INSERT INTO `django_migrations` VALUES (36, 'oozie', '0003_initial', '2021-08-30 23:08:41.853017');
INSERT INTO `django_migrations` VALUES (37, 'oozie', '0004_initial', '2021-08-30 23:08:41.959723');
INSERT INTO `django_migrations` VALUES (38, 'oozie', '0005_initial', '2021-08-30 23:08:42.290115');
INSERT INTO `django_migrations` VALUES (39, 'oozie', '0006_auto_20200714_1204', '2021-08-30 23:08:42.595654');
INSERT INTO `django_migrations` VALUES (40, 'oozie', '0007_auto_20210126_2113', '2021-08-30 23:08:42.685141');
INSERT INTO `django_migrations` VALUES (41, 'oozie', '0008_auto_20210216_0216', '2021-08-30 23:08:42.742118');
INSERT INTO `django_migrations` VALUES (42, 'pig', '0001_initial', '2021-08-30 23:08:43.797337');
INSERT INTO `django_migrations` VALUES (43, 'pig', '0002_auto_20200714_1204', '2021-08-30 23:08:43.816410');
INSERT INTO `django_migrations` VALUES (44, 'pig', '0003_auto_20210827_0214', '2021-08-30 23:08:43.835751');
INSERT INTO `django_migrations` VALUES (45, 'search', '0001_initial', '2021-08-30 23:08:44.170111');
INSERT INTO `django_migrations` VALUES (46, 'sessions', '0001_initial', '2021-08-30 23:08:44.194908');
INSERT INTO `django_migrations` VALUES (47, 'sites', '0001_initial', '2021-08-30 23:08:44.216467');
INSERT INTO `django_migrations` VALUES (48, 'sites', '0002_alter_domain_unique', '2021-08-30 23:08:44.241070');
INSERT INTO `django_migrations` VALUES (49, 'useradmin', '0001_initial', '2021-08-30 23:08:44.519135');
INSERT INTO `django_migrations` VALUES (50, 'useradmin', '0002_userprofile_json_data', '2021-08-30 23:08:44.698887');
INSERT INTO `django_migrations` VALUES (51, 'useradmin', '0003_auto_20200203_0802', '2021-08-30 23:08:44.826164');
INSERT INTO `django_migrations` VALUES (52, 'useradmin', '0004_userprofile_hostname', '2021-08-30 23:08:44.868449');

-- ----------------------------
-- Table structure for django_session
-- ----------------------------
DROP TABLE IF EXISTS `django_session`;
CREATE TABLE `django_session`  (
  `session_key` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `session_data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`) USING BTREE,
  INDEX `django_session_expire_date_a5c62663`(`expire_date`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_session
-- ----------------------------
INSERT INTO `django_session` VALUES ('qxh7j81b71h82athbfzlhsbtbfz9tqxm', 'YjFlN2YxNmFlYjM2OGU4MTJjYzRhNzYxMGU3YWMzYjdmY2U1YWZmYzp7Il9hdXRoX3VzZXJfaGFzaCI6IjZlODUwY2Q4MjMwMmUwMGMyYWM4MGQ4OWQyNTJlMmY2MGI2ODI2MDkiLCJfYXV0aF91c2VyX2JhY2tlbmQiOiJkZXNrdG9wLmF1dGguYmFja2VuZC5BbGxvd0ZpcnN0VXNlckRqYW5nb0JhY2tlbmQiLCJfYXV0aF91c2VyX2lkIjoiMTEwMDcxNCJ9', '2021-09-13 23:10:33.078028');

-- ----------------------------
-- Table structure for django_site
-- ----------------------------
DROP TABLE IF EXISTS `django_site`;
CREATE TABLE `django_site`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `django_site_domain_a2e37b91_uniq`(`domain`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_site
-- ----------------------------
INSERT INTO `django_site` VALUES (1, 'example.com', 'example.com');

-- ----------------------------
-- Table structure for documentpermission2_groups
-- ----------------------------
DROP TABLE IF EXISTS `documentpermission2_groups`;
CREATE TABLE `documentpermission2_groups`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document2permission_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `documentpermission2_grou_document2permission_id_g_b82724d9_uniq`(`document2permission_id`, `group_id`) USING BTREE,
  INDEX `documentpermission2_groups_group_id_7efb8a45_fk_auth_group_id`(`group_id`) USING BTREE,
  CONSTRAINT `documentpermission2__document2permission__1f9f783b_fk_desktop_d` FOREIGN KEY (`document2permission_id`) REFERENCES `desktop_document2permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `documentpermission2_groups_group_id_7efb8a45_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for documentpermission2_users
-- ----------------------------
DROP TABLE IF EXISTS `documentpermission2_users`;
CREATE TABLE `documentpermission2_users`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document2permission_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `documentpermission2_user_document2permission_id_u_66ccf253_uniq`(`document2permission_id`, `user_id`) USING BTREE,
  INDEX `documentpermission2_users_user_id_848e20ce_fk_auth_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `documentpermission2__document2permission__ad7af084_fk_desktop_d` FOREIGN KEY (`document2permission_id`) REFERENCES `desktop_document2permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `documentpermission2_users_user_id_848e20ce_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for documentpermission_groups
-- ----------------------------
DROP TABLE IF EXISTS `documentpermission_groups`;
CREATE TABLE `documentpermission_groups`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `documentpermission_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `documentpermission_group_documentpermission_id_gr_b617df3f_uniq`(`documentpermission_id`, `group_id`) USING BTREE,
  INDEX `documentpermission_groups_group_id_d44a4071_fk_auth_group_id`(`group_id`) USING BTREE,
  CONSTRAINT `documentpermission_g_documentpermission_i_d838bd22_fk_desktop_d` FOREIGN KEY (`documentpermission_id`) REFERENCES `desktop_documentpermission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `documentpermission_groups_group_id_d44a4071_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for documentpermission_users
-- ----------------------------
DROP TABLE IF EXISTS `documentpermission_users`;
CREATE TABLE `documentpermission_users`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `documentpermission_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `documentpermission_users_documentpermission_id_us_b0be31ca_uniq`(`documentpermission_id`, `user_id`) USING BTREE,
  INDEX `documentpermission_users_user_id_4afc7785_fk_auth_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `documentpermission_u_documentpermission_i_4546e93f_fk_desktop_d` FOREIGN KEY (`documentpermission_id`) REFERENCES `desktop_documentpermission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `documentpermission_users_user_id_4afc7785_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jobsub_checkforsetup
-- ----------------------------
DROP TABLE IF EXISTS `jobsub_checkforsetup`;
CREATE TABLE `jobsub_checkforsetup`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setup_run` tinyint(1) NOT NULL,
  `setup_level` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jobsub_jobdesign
-- ----------------------------
DROP TABLE IF EXISTS `jobsub_jobdesign`;
CREATE TABLE `jobsub_jobdesign`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_modified` datetime(6) NOT NULL,
  `type` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `jobsub_jobdesign_owner_id_648998a1_fk_auth_user_id`(`owner_id`) USING BTREE,
  CONSTRAINT `jobsub_jobdesign_owner_id_648998a1_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jobsub_jobhistory
-- ----------------------------
DROP TABLE IF EXISTS `jobsub_jobhistory`;
CREATE TABLE `jobsub_jobhistory`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `submission_date` datetime(6) NOT NULL,
  `job_id` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `design_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `jobsub_jobhistory_design_id_06d16a98_fk_jobsub_ooziedesign_id`(`design_id`) USING BTREE,
  INDEX `jobsub_jobhistory_owner_id_5bdaa10b_fk_auth_user_id`(`owner_id`) USING BTREE,
  CONSTRAINT `jobsub_jobhistory_design_id_06d16a98_fk_jobsub_ooziedesign_id` FOREIGN KEY (`design_id`) REFERENCES `jobsub_ooziedesign` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `jobsub_jobhistory_owner_id_5bdaa10b_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jobsub_oozieaction
-- ----------------------------
DROP TABLE IF EXISTS `jobsub_oozieaction`;
CREATE TABLE `jobsub_oozieaction`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_type` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jobsub_ooziedesign
-- ----------------------------
DROP TABLE IF EXISTS `jobsub_ooziedesign`;
CREATE TABLE `jobsub_ooziedesign`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_modified` datetime(6) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `root_action_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `jobsub_ooziedesign_owner_id_cb5405f3_fk_auth_user_id`(`owner_id`) USING BTREE,
  INDEX `jobsub_ooziedesign_root_action_id_a68cdf79_fk_jobsub_oo`(`root_action_id`) USING BTREE,
  CONSTRAINT `jobsub_ooziedesign_owner_id_cb5405f3_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `jobsub_ooziedesign_root_action_id_a68cdf79_fk_jobsub_oo` FOREIGN KEY (`root_action_id`) REFERENCES `jobsub_oozieaction` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jobsub_ooziejavaaction
-- ----------------------------
DROP TABLE IF EXISTS `jobsub_ooziejavaaction`;
CREATE TABLE `jobsub_ooziejavaaction`  (
  `oozieaction_ptr_id` int(11) NOT NULL,
  `files` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `jar_path` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `main_class` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `args` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `java_opts` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`oozieaction_ptr_id`) USING BTREE,
  CONSTRAINT `jobsub_ooziejavaacti_oozieaction_ptr_id_0f52fef4_fk_jobsub_oo` FOREIGN KEY (`oozieaction_ptr_id`) REFERENCES `jobsub_oozieaction` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jobsub_ooziemapreduceaction
-- ----------------------------
DROP TABLE IF EXISTS `jobsub_ooziemapreduceaction`;
CREATE TABLE `jobsub_ooziemapreduceaction`  (
  `oozieaction_ptr_id` int(11) NOT NULL,
  `files` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `jar_path` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`oozieaction_ptr_id`) USING BTREE,
  CONSTRAINT `jobsub_ooziemapreduc_oozieaction_ptr_id_92fe5d48_fk_jobsub_oo` FOREIGN KEY (`oozieaction_ptr_id`) REFERENCES `jobsub_oozieaction` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jobsub_ooziestreamingaction
-- ----------------------------
DROP TABLE IF EXISTS `jobsub_ooziestreamingaction`;
CREATE TABLE `jobsub_ooziestreamingaction`  (
  `oozieaction_ptr_id` int(11) NOT NULL,
  `files` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `mapper` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `reducer` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`oozieaction_ptr_id`) USING BTREE,
  CONSTRAINT `jobsub_ooziestreamin_oozieaction_ptr_id_8007acc7_fk_jobsub_oo` FOREIGN KEY (`oozieaction_ptr_id`) REFERENCES `jobsub_oozieaction` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_bundle
-- ----------------------------
DROP TABLE IF EXISTS `oozie_bundle`;
CREATE TABLE `oozie_bundle`  (
  `job_ptr_id` int(11) NOT NULL,
  `kick_off_time` datetime(6) NOT NULL,
  PRIMARY KEY (`job_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_bundle_job_ptr_id_0c53aa88_fk_oozie_job_id` FOREIGN KEY (`job_ptr_id`) REFERENCES `oozie_job` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_bundledcoordinator
-- ----------------------------
DROP TABLE IF EXISTS `oozie_bundledcoordinator`;
CREATE TABLE `oozie_bundledcoordinator`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parameters` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `bundle_id` int(11) NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `oozie_bundledcoordin_bundle_id_c0a51e15_fk_oozie_bun`(`bundle_id`) USING BTREE,
  INDEX `oozie_bundledcoordin_coordinator_id_deb5052a_fk_oozie_coo`(`coordinator_id`) USING BTREE,
  CONSTRAINT `oozie_bundledcoordin_bundle_id_c0a51e15_fk_oozie_bun` FOREIGN KEY (`bundle_id`) REFERENCES `oozie_bundle` (`job_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_bundledcoordin_coordinator_id_deb5052a_fk_oozie_coo` FOREIGN KEY (`coordinator_id`) REFERENCES `oozie_coordinator` (`job_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_coordinator
-- ----------------------------
DROP TABLE IF EXISTS `oozie_coordinator`;
CREATE TABLE `oozie_coordinator`  (
  `job_ptr_id` int(11) NOT NULL,
  `frequency_number` smallint(6) NOT NULL,
  `frequency_unit` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `timezone` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `start` datetime(6) NOT NULL,
  `end` datetime(6) NOT NULL,
  `timeout` smallint(6) NULL DEFAULT NULL,
  `concurrency` smallint(5) UNSIGNED NULL DEFAULT NULL,
  `execution` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `throttle` smallint(5) UNSIGNED NULL DEFAULT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `coordinatorworkflow_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`job_ptr_id`) USING BTREE,
  INDEX `oozie_coordinator_coordinatorworkflow__b6161414_fk_oozie_wor`(`coordinatorworkflow_id`) USING BTREE,
  CONSTRAINT `oozie_coordinator_coordinatorworkflow__b6161414_fk_oozie_wor` FOREIGN KEY (`coordinatorworkflow_id`) REFERENCES `oozie_workflow` (`job_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_coordinator_job_ptr_id_59cbcc0c_fk_oozie_job_id` FOREIGN KEY (`job_ptr_id`) REFERENCES `oozie_job` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_datainput
-- ----------------------------
DROP TABLE IF EXISTS `oozie_datainput`;
CREATE TABLE `oozie_datainput`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `dataset_id` int(11) NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `dataset_id`(`dataset_id`) USING BTREE,
  INDEX `oozie_datainput_coordinator_id_d8d911b9_fk_oozie_coo`(`coordinator_id`) USING BTREE,
  CONSTRAINT `oozie_datainput_coordinator_id_d8d911b9_fk_oozie_coo` FOREIGN KEY (`coordinator_id`) REFERENCES `oozie_coordinator` (`job_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_datainput_dataset_id_5fcb31a7_fk_oozie_dataset_id` FOREIGN KEY (`dataset_id`) REFERENCES `oozie_dataset` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_dataoutput
-- ----------------------------
DROP TABLE IF EXISTS `oozie_dataoutput`;
CREATE TABLE `oozie_dataoutput`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `dataset_id` int(11) NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `dataset_id`(`dataset_id`) USING BTREE,
  INDEX `oozie_dataoutput_coordinator_id_12e73c29_fk_oozie_coo`(`coordinator_id`) USING BTREE,
  CONSTRAINT `oozie_dataoutput_coordinator_id_12e73c29_fk_oozie_coo` FOREIGN KEY (`coordinator_id`) REFERENCES `oozie_coordinator` (`job_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_dataoutput_dataset_id_84e68919_fk_oozie_dataset_id` FOREIGN KEY (`dataset_id`) REFERENCES `oozie_dataset` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_dataset
-- ----------------------------
DROP TABLE IF EXISTS `oozie_dataset`;
CREATE TABLE `oozie_dataset`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `start` datetime(6) NOT NULL,
  `frequency_number` smallint(6) NOT NULL,
  `frequency_unit` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `uri` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `timezone` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `done_flag` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `instance_choice` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `advanced_start_instance` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `advanced_end_instance` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `oozie_dataset_coordinator_id_4d1eb286_fk_oozie_coo`(`coordinator_id`) USING BTREE,
  CONSTRAINT `oozie_dataset_coordinator_id_4d1eb286_fk_oozie_coo` FOREIGN KEY (`coordinator_id`) REFERENCES `oozie_coordinator` (`job_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_decision
-- ----------------------------
DROP TABLE IF EXISTS `oozie_decision`;
CREATE TABLE `oozie_decision`  (
  `node_ptr_id` int(11) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_decision_node_ptr_id_1ee18de2_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_decisionend
-- ----------------------------
DROP TABLE IF EXISTS `oozie_decisionend`;
CREATE TABLE `oozie_decisionend`  (
  `node_ptr_id` int(11) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_decisionend_node_ptr_id_ec0ad089_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_distcp
-- ----------------------------
DROP TABLE IF EXISTS `oozie_distcp`;
CREATE TABLE `oozie_distcp`  (
  `node_ptr_id` int(11) NOT NULL,
  `params` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `prepares` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_xml` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_distcp_node_ptr_id_0f63bff7_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_email
-- ----------------------------
DROP TABLE IF EXISTS `oozie_email`;
CREATE TABLE `oozie_email`  (
  `node_ptr_id` int(11) NOT NULL,
  `to` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `cc` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `subject` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `body` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_email_node_ptr_id_b6164766_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_end
-- ----------------------------
DROP TABLE IF EXISTS `oozie_end`;
CREATE TABLE `oozie_end`  (
  `node_ptr_id` int(11) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_end_node_ptr_id_9a6db5e6_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_fork
-- ----------------------------
DROP TABLE IF EXISTS `oozie_fork`;
CREATE TABLE `oozie_fork`  (
  `node_ptr_id` int(11) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_fork_node_ptr_id_286409b0_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_fs
-- ----------------------------
DROP TABLE IF EXISTS `oozie_fs`;
CREATE TABLE `oozie_fs`  (
  `node_ptr_id` int(11) NOT NULL,
  `deletes` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `mkdirs` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `moves` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `chmods` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `touchzs` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_fs_node_ptr_id_324d62ec_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_generic
-- ----------------------------
DROP TABLE IF EXISTS `oozie_generic`;
CREATE TABLE `oozie_generic`  (
  `node_ptr_id` int(11) NOT NULL,
  `xml` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_generic_node_ptr_id_39a1a65a_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_history
-- ----------------------------
DROP TABLE IF EXISTS `oozie_history`;
CREATE TABLE `oozie_history`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `submission_date` datetime(6) NOT NULL,
  `oozie_job_id` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `submitter_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `oozie_history_submission_date_85ff5210`(`submission_date`) USING BTREE,
  INDEX `oozie_history_submitter_id_b55e2183_fk_auth_user_id`(`submitter_id`) USING BTREE,
  INDEX `oozie_history_job_id_fbea900b_fk_oozie_job_id`(`job_id`) USING BTREE,
  CONSTRAINT `oozie_history_job_id_fbea900b_fk_oozie_job_id` FOREIGN KEY (`job_id`) REFERENCES `oozie_job` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_history_submitter_id_b55e2183_fk_auth_user_id` FOREIGN KEY (`submitter_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_hive
-- ----------------------------
DROP TABLE IF EXISTS `oozie_hive`;
CREATE TABLE `oozie_hive`  (
  `node_ptr_id` int(11) NOT NULL,
  `script_path` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `params` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `files` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `prepares` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_xml` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_hive_node_ptr_id_747c09c7_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_java
-- ----------------------------
DROP TABLE IF EXISTS `oozie_java`;
CREATE TABLE `oozie_java`  (
  `node_ptr_id` int(11) NOT NULL,
  `files` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `jar_path` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `main_class` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `args` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `java_opts` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `prepares` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_xml` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `capture_output` tinyint(1) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_java_node_ptr_id_41ceeff8_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_job
-- ----------------------------
DROP TABLE IF EXISTS `oozie_job`;
CREATE TABLE `oozie_job`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_modified` datetime(6) NOT NULL,
  `schema_version` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `deployment_dir` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `is_shared` tinyint(1) NOT NULL,
  `parameters` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `is_trashed` tinyint(1) NOT NULL,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `oozie_job_last_modified_75350e87`(`last_modified`) USING BTREE,
  INDEX `oozie_job_is_shared_353b5458`(`is_shared`) USING BTREE,
  INDEX `oozie_job_is_trashed_da42d7e5`(`is_trashed`) USING BTREE,
  INDEX `oozie_job_owner_id_c255618e_fk_auth_user_id`(`owner_id`) USING BTREE,
  CONSTRAINT `oozie_job_owner_id_c255618e_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_join
-- ----------------------------
DROP TABLE IF EXISTS `oozie_join`;
CREATE TABLE `oozie_join`  (
  `node_ptr_id` int(11) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_join_node_ptr_id_17901551_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_kill
-- ----------------------------
DROP TABLE IF EXISTS `oozie_kill`;
CREATE TABLE `oozie_kill`  (
  `node_ptr_id` int(11) NOT NULL,
  `message` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_kill_node_ptr_id_6e3b4c7f_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_link
-- ----------------------------
DROP TABLE IF EXISTS `oozie_link`;
CREATE TABLE `oozie_link`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `comment` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `child_id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `oozie_link_parent_id_5b2a2286_fk_oozie_node_id`(`parent_id`) USING BTREE,
  INDEX `oozie_link_child_id_c3e8341e_fk_oozie_node_id`(`child_id`) USING BTREE,
  CONSTRAINT `oozie_link_child_id_c3e8341e_fk_oozie_node_id` FOREIGN KEY (`child_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_link_parent_id_5b2a2286_fk_oozie_node_id` FOREIGN KEY (`parent_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_mapreduce
-- ----------------------------
DROP TABLE IF EXISTS `oozie_mapreduce`;
CREATE TABLE `oozie_mapreduce`  (
  `node_ptr_id` int(11) NOT NULL,
  `files` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `jar_path` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `prepares` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_xml` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_mapreduce_node_ptr_id_5ef2cd6d_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_node
-- ----------------------------
DROP TABLE IF EXISTS `oozie_node`;
CREATE TABLE `oozie_node`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `node_type` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `workflow_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `oozie_node_workflow_id_a6bd1a69_fk_oozie_workflow_job_ptr_id`(`workflow_id`) USING BTREE,
  CONSTRAINT `oozie_node_workflow_id_a6bd1a69_fk_oozie_workflow_job_ptr_id` FOREIGN KEY (`workflow_id`) REFERENCES `oozie_workflow` (`job_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_pig
-- ----------------------------
DROP TABLE IF EXISTS `oozie_pig`;
CREATE TABLE `oozie_pig`  (
  `node_ptr_id` int(11) NOT NULL,
  `script_path` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `params` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `files` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `prepares` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_xml` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_pig_node_ptr_id_251c17e0_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_shell
-- ----------------------------
DROP TABLE IF EXISTS `oozie_shell`;
CREATE TABLE `oozie_shell`  (
  `node_ptr_id` int(11) NOT NULL,
  `command` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `params` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `files` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `prepares` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_xml` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `capture_output` tinyint(1) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_shell_node_ptr_id_4b2d0551_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_sqoop
-- ----------------------------
DROP TABLE IF EXISTS `oozie_sqoop`;
CREATE TABLE `oozie_sqoop`  (
  `node_ptr_id` int(11) NOT NULL,
  `script_path` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `params` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `files` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `prepares` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_xml` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_sqoop_node_ptr_id_bc17434d_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_ssh
-- ----------------------------
DROP TABLE IF EXISTS `oozie_ssh`;
CREATE TABLE `oozie_ssh`  (
  `node_ptr_id` int(11) NOT NULL,
  `user` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `host` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `command` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `params` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `capture_output` tinyint(1) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_ssh_node_ptr_id_f8399593_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_start
-- ----------------------------
DROP TABLE IF EXISTS `oozie_start`;
CREATE TABLE `oozie_start`  (
  `node_ptr_id` int(11) NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_start_node_ptr_id_845ed7e5_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_streaming
-- ----------------------------
DROP TABLE IF EXISTS `oozie_streaming`;
CREATE TABLE `oozie_streaming`  (
  `node_ptr_id` int(11) NOT NULL,
  `files` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `archives` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `mapper` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `reducer` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  CONSTRAINT `oozie_streaming_node_ptr_id_33986c0c_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_subworkflow
-- ----------------------------
DROP TABLE IF EXISTS `oozie_subworkflow`;
CREATE TABLE `oozie_subworkflow`  (
  `node_ptr_id` int(11) NOT NULL,
  `propagate_configuration` tinyint(1) NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `sub_workflow_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`node_ptr_id`) USING BTREE,
  INDEX `oozie_subworkflow_sub_workflow_id_4e2908b9_fk_oozie_wor`(`sub_workflow_id`) USING BTREE,
  CONSTRAINT `oozie_subworkflow_node_ptr_id_6d9b076e_fk_oozie_node_id` FOREIGN KEY (`node_ptr_id`) REFERENCES `oozie_node` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_subworkflow_sub_workflow_id_4e2908b9_fk_oozie_wor` FOREIGN KEY (`sub_workflow_id`) REFERENCES `oozie_workflow` (`job_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oozie_workflow
-- ----------------------------
DROP TABLE IF EXISTS `oozie_workflow`;
CREATE TABLE `oozie_workflow`  (
  `job_ptr_id` int(11) NOT NULL,
  `is_single` tinyint(1) NOT NULL,
  `job_xml` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `job_properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `managed` tinyint(1) NOT NULL,
  `end_id` int(11) NULL DEFAULT NULL,
  `start_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`job_ptr_id`) USING BTREE,
  INDEX `oozie_workflow_end_id_2f6d0f36_fk_oozie_end_node_ptr_id`(`end_id`) USING BTREE,
  INDEX `oozie_workflow_start_id_677c5e08_fk_oozie_start_node_ptr_id`(`start_id`) USING BTREE,
  CONSTRAINT `oozie_workflow_end_id_2f6d0f36_fk_oozie_end_node_ptr_id` FOREIGN KEY (`end_id`) REFERENCES `oozie_end` (`node_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_workflow_job_ptr_id_8f44b9da_fk_oozie_job_id` FOREIGN KEY (`job_ptr_id`) REFERENCES `oozie_job` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `oozie_workflow_start_id_677c5e08_fk_oozie_start_node_ptr_id` FOREIGN KEY (`start_id`) REFERENCES `oozie_start` (`node_ptr_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pig_document
-- ----------------------------
DROP TABLE IF EXISTS `pig_document`;
CREATE TABLE `pig_document`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `is_design` tinyint(1) NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `pig_document_is_design_f1e0139b`(`is_design`) USING BTREE,
  INDEX `pig_document_owner_id_27d3660e_fk_auth_user_id`(`owner_id`) USING BTREE,
  CONSTRAINT `pig_document_owner_id_27d3660e_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pig_pigscript
-- ----------------------------
DROP TABLE IF EXISTS `pig_pigscript`;
CREATE TABLE `pig_pigscript`  (
  `document_ptr_id` int(11) NOT NULL,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`document_ptr_id`) USING BTREE,
  CONSTRAINT `pig_pigscript_document_ptr_id_8cbae244_fk_pig_document_id` FOREIGN KEY (`document_ptr_id`) REFERENCES `pig_document` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for search_collection
-- ----------------------------
DROP TABLE IF EXISTS `search_collection`;
CREATE TABLE `search_collection`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) NOT NULL,
  `name` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `label` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `is_core_only` tinyint(1) NOT NULL,
  `cores` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `properties` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `facets_id` int(11) NOT NULL,
  `owner_id` int(11) NULL DEFAULT NULL,
  `result_id` int(11) NOT NULL,
  `sorting_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `search_collection_facets_id_38fca094_fk_search_facet_id`(`facets_id`) USING BTREE,
  INDEX `search_collection_owner_id_e32f7d25_fk_auth_user_id`(`owner_id`) USING BTREE,
  INDEX `search_collection_result_id_d20b13e1_fk_search_result_id`(`result_id`) USING BTREE,
  INDEX `search_collection_sorting_id_9d8d07cf_fk_search_sorting_id`(`sorting_id`) USING BTREE,
  CONSTRAINT `search_collection_facets_id_38fca094_fk_search_facet_id` FOREIGN KEY (`facets_id`) REFERENCES `search_facet` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `search_collection_owner_id_e32f7d25_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `search_collection_result_id_d20b13e1_fk_search_result_id` FOREIGN KEY (`result_id`) REFERENCES `search_result` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `search_collection_sorting_id_9d8d07cf_fk_search_sorting_id` FOREIGN KEY (`sorting_id`) REFERENCES `search_sorting` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for search_facet
-- ----------------------------
DROP TABLE IF EXISTS `search_facet`;
CREATE TABLE `search_facet`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) NOT NULL,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for search_result
-- ----------------------------
DROP TABLE IF EXISTS `search_result`;
CREATE TABLE `search_result`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for search_sorting
-- ----------------------------
DROP TABLE IF EXISTS `search_sorting`;
CREATE TABLE `search_sorting`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for useradmin_grouppermission
-- ----------------------------
DROP TABLE IF EXISTS `useradmin_grouppermission`;
CREATE TABLE `useradmin_grouppermission`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `hue_permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `useradmin_grouppermission_group_id_da9c1a34_fk_auth_group_id`(`group_id`) USING BTREE,
  INDEX `useradmin_grouppermi_hue_permission_id_ece6426f_fk_useradmin`(`hue_permission_id`) USING BTREE,
  CONSTRAINT `useradmin_grouppermi_hue_permission_id_ece6426f_fk_useradmin` FOREIGN KEY (`hue_permission_id`) REFERENCES `useradmin_huepermission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `useradmin_grouppermission_group_id_da9c1a34_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for useradmin_huepermission
-- ----------------------------
DROP TABLE IF EXISTS `useradmin_huepermission`;
CREATE TABLE `useradmin_huepermission`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `action` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `connector_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `useradmin_huepermission_connector_id_action_18d0f080_uniq`(`connector_id`, `action`) USING BTREE,
  CONSTRAINT `useradmin_huepermiss_connector_id_31a17ccd_fk_desktop_c` FOREIGN KEY (`connector_id`) REFERENCES `desktop_connector` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for useradmin_ldapgroup
-- ----------------------------
DROP TABLE IF EXISTS `useradmin_ldapgroup`;
CREATE TABLE `useradmin_ldapgroup`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `useradmin_ldapgroup_group_id_162e4d49_fk_auth_group_id`(`group_id`) USING BTREE,
  CONSTRAINT `useradmin_ldapgroup_group_id_162e4d49_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for useradmin_userprofile
-- ----------------------------
DROP TABLE IF EXISTS `useradmin_userprofile`;
CREATE TABLE `useradmin_userprofile`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `home_directory` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `creation_method` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `first_login` tinyint(1) NOT NULL,
  `last_activity` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL,
  `json_data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `hostname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id`) USING BTREE,
  INDEX `useradmin_userprofile_last_activity_c0e0b56b`(`last_activity`) USING BTREE,
  CONSTRAINT `useradmin_userprofile_user_id_6333d17b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of useradmin_userprofile
-- ----------------------------
INSERT INTO `useradmin_userprofile` VALUES (1, '/user/admin', 'HUE', 0, '2021-08-30 23:12:28.541923', 1100714, '{\"auth_backend\": \"desktop.auth.backend.AllowFirstUserDjangoBackend\"}', 'minio-1');

SET FOREIGN_KEY_CHECKS = 1;
