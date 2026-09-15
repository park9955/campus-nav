-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: campusnav
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `campus_entrances`
--

DROP TABLE IF EXISTS `campus_entrances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `campus_entrances` (
  `entrance_id` int NOT NULL AUTO_INCREMENT,
  `entrance_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '출입구/강의실 이름',
  `building` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `floor` tinyint NOT NULL DEFAULT '1' COMMENT '층수',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '부가설명',
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '사용여부(1=활성)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pixel_x` float DEFAULT NULL,
  `pixel_y` float DEFAULT NULL,
  PRIMARY KEY (`entrance_id`),
  KEY `idx_building` (`building`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='교내 출입구 및 강의실 위치 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campus_entrances`
--

LOCK TABLES `campus_entrances` WRITE;
/*!40000 ALTER TABLE `campus_entrances` DISABLE KEYS */;
INSERT INTO `campus_entrances` VALUES (1,'1공학관-정문','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(2,'1공학관-후문','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(3,'대학본부','대학본부',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(4,'1생활관','1생활관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(5,'2생활관','2생활관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(6,'학생회관-후문','학생회관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(7,'학생회관-식당-정문','학생회관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(8,'학생회관-엘리베이터','학생회관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(9,'2공학관-정문','2공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(10,'2공학관-후문','2공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(11,'1공학관-1107호실','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(12,'1공학관-1106호실','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(13,'1공학관-1105호실','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(14,'1공학관-1104호실','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(15,'1공학관-1103호실','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(16,'1공학관-1102호실','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(17,'1공학관-1101호실','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(18,'1공학관-1207호실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(19,'1공학관-1206호실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(20,'1공학관-1205호실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(21,'1공학관-1204호실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(22,'1공학관-1203호실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(23,'1공학관-1202호실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(24,'1공학관-1201호실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(25,'1공학관-1307호실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(26,'1공학관-1306호실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(27,'1공학관-1305호실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(28,'1공학관-1304호실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(29,'1공학관-1303호실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(30,'1공학관-1302호실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(31,'1공학관-1301호실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(32,'1공학관-1407호실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(33,'1공학관-1406호실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(34,'1공학관-1405호실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(35,'1공학관-1404호실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(36,'1공학관-1403호실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(37,'1공학관-1402호실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(38,'1공학관-1401호실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(39,'1공학관-1503호실','1공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(40,'1공학관-1502호실','1공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(41,'1공학관-1501호실','1공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(42,'1공학관-1층 실습실','1공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(43,'1공학관-2층 실습실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(44,'1공학관-3층 실습실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(45,'1공학관-4층 실습실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(46,'1공학관-5층 실습실','1공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(47,'1공학관-2층 교수실','1공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(48,'1공학관-3층 교수실','1공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(49,'1공학관-4층 교수실','1공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(50,'1공학관-5층 교수실','1공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(51,'1공학관-5층 강당','1공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(52,'휴게실','휴게실',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(53,'도서관','도서관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(54,'2공학관-1층 2101호실','2공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(55,'2공학관-1층 2102호실','2공학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(56,'2공학관-2층 2201호실','2공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(57,'2공학관-2층 2202호실','2공학관',2,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(58,'2공학관-3층 2301호실','2공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(59,'2공학관-3층 2302호실','2공학관',3,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(60,'2공학관-4층 2401호실','2공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(61,'2공학관-4층 2402호실','2공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(62,'2공학관-4층 제 1 스마트워크룸','2공학관',4,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(63,'2공학관-5층 2501호실','2공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(64,'2공학관-5층 2502호실','2공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(65,'2공학관-5층 제 1 스마트워크룸','2공학관',5,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(66,'산업협력학관','산업협력학관',1,NULL,0,'2026-04-13 04:54:48',NULL,NULL,NULL),(67,'1공학관 출입구','1공학관',1,NULL,1,'2026-04-13 06:33:18','/CAN/images/locations/eng1.jpg',315.74,243.43),(68,'2공학관 출입구','2공학관',1,NULL,0,'2026-04-13 06:33:18','/CAN/images/locations/eng2.jpg',NULL,NULL),(69,'1생활관 출입구','1생활관',1,NULL,0,'2026-04-13 06:33:18','/CAN/images/locations/dorm1.jpg',NULL,NULL),(70,'2생활관 출입구','2생활관',1,NULL,0,'2026-04-13 06:33:18','/CAN/images/locations/dorm2.jpg',NULL,NULL),(71,'대학본부 출입구','대학본부',1,NULL,0,'2026-04-13 06:33:18','/CAN/images/locations/main.jpg',NULL,NULL),(72,'도서관 출입구','도서관',1,NULL,0,'2026-04-13 06:33:18','/CAN/images/locations/library.jpg',NULL,NULL),(73,'산업협력학관 출입구','산업협력학관',1,NULL,0,'2026-04-13 06:33:18','/CAN/images/locations/industry.jpg',NULL,NULL),(74,'학생회관 출입구','학생회관',1,NULL,0,'2026-04-13 06:33:18','/CAN/images/locations/student.jpg',NULL,NULL),(75,'휴게실 출입구','휴게실',1,NULL,0,'2026-04-13 06:33:18','/CAN/images/locations/lounge.jpg',NULL,NULL),(76,'정문 출입구1','정문',1,NULL,0,'2026-04-13 06:45:07','/CAN/images/locations/gate1.jpg',NULL,NULL),(77,'정문 출입구2','정문',1,NULL,0,'2026-04-13 06:45:07','/CAN/images/locations/gate2.jpg',NULL,NULL),(78,'정문 출입구3','정문',1,NULL,0,'2026-04-13 06:45:07','/CAN/images/locations/gate3.jpg',NULL,NULL),(79,'2공학관 출입구','2공학관',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/eng2.jpg',NULL,NULL),(80,'1생활관 출입구','1생활관',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/dorm1.jpg',NULL,NULL),(81,'2생활관 출입구','2생활관',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/dorm2.jpg',NULL,NULL),(82,'대학본부 출입구','대학본부',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/main.jpg',NULL,NULL),(83,'도서관 출입구','도서관',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/library.jpg',NULL,NULL),(84,'산업협력학관 출입구','산업협력학관',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/industry.jpg',NULL,NULL),(85,'학생회관 출입구','학생회관',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/student.jpg',NULL,NULL),(86,'휴게실 출입구','휴게실',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/lounge.jpg',NULL,NULL),(87,'정문 출입구1','정문',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/gate1.jpg',NULL,NULL),(88,'정문 출입구2','정문',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/gate2.jpg',NULL,NULL),(89,'정문 출입구3','정문',1,NULL,0,'2026-04-13 06:46:59','/CAN/images/locations/gate3.jpg',NULL,NULL),(90,'2공학관 출입구','2공학관',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/eng2.jpg',726.7,225.36),(91,'1생활관 출입구','1생활관',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/dorm1.jpg',392.92,136.05),(92,'2생활관 출입구','2생활관',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/dorm2.jpg',387.91,104.94),(93,'대학본부 출입구','대학본부',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/main.jpg',285.67,351.81),(94,'도서관 출입구','도서관',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/library.jpg',331.78,174.18),(95,'산업협력학관 출입구','산업협력학관',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/industry.jpg',731.71,302.64),(96,'학생회관 출입구','학생회관',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/student.jpg',498.17,171.17),(97,'휴게실 출입구','휴게실',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/lounge.jpg',326.77,195.26),(98,'정문 출입구1','정문',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/gate1.jpg',19.04,482.28),(99,'정문 출입구2','정문',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/gate2.jpg',161.38,474.25),(100,'정문 출입구3','정문',1,NULL,1,'2026-04-13 06:50:12','/CAN/images/locations/gate3.jpg',307.72,459.2);
/*!40000 ALTER TABLE `campus_entrances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campus_routes`
--

DROP TABLE IF EXISTS `campus_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `campus_routes` (
  `route_id` int NOT NULL AUTO_INCREMENT,
  `entrance_id` int NOT NULL,
  `route_name` varchar(200) DEFAULT NULL,
  `points_json` text NOT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint DEFAULT '1',
  `from_entrance_id` int DEFAULT NULL,
  `to_entrance_id` int DEFAULT NULL,
  PRIMARY KEY (`route_id`),
  KEY `entrance_id` (`entrance_id`),
  CONSTRAINT `campus_routes_ibfk_1` FOREIGN KEY (`entrance_id`) REFERENCES `campus_entrances` (`entrance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campus_routes`
--

LOCK TABLES `campus_routes` WRITE;
/*!40000 ALTER TABLE `campus_routes` DISABLE KEYS */;
INSERT INTO `campus_routes` VALUES (1,67,'test','[{\"x\":25.058685446009388,\"y\":508.3716517857143},{\"x\":119.27934272300469,\"y\":503.3537946428571},{\"x\":185.43427230046947,\"y\":493.31808035714283}]','admin','2026-04-13 16:15:31',0,NULL,NULL),(2,91,'','[{\"x\":337.3779296875,\"y\":248.17047119140625},{\"x\":356.3779296875,\"y\":175.17047119140625},{\"x\":476.3779296875,\"y\":177.17047119140625},{\"x\":478.3779296875,\"y\":141.17047119140625},{\"x\":413.3779296875,\"y\":138.17047119140625}]','admin','2026-04-13 17:32:15',1,67,91),(3,93,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":300.70422535211264,\"y\":351.8145089285714}]','admin1234','2026-04-23 13:03:05',1,67,93),(4,100,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":294.6901408450704,\"y\":453.1752232142857}]','admin1234','2026-04-23 13:03:14',1,67,100),(5,98,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":294.6901408450704,\"y\":453.1752232142857},{\"x\":31.57394366197183,\"y\":480.27165178571425}]','admin1234','2026-04-23 13:03:21',1,67,98),(6,99,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":294.6901408450704,\"y\":453.1752232142857},{\"x\":167.8931924882629,\"y\":483.28236607142856}]','admin1234','2026-04-23 13:03:38',1,67,99),(7,97,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":340.7981220657277,\"y\":200.27522321428572}]','admin1234','2026-04-23 13:03:57',1,67,97),(8,94,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":349.8192488262911,\"y\":188.23236607142857}]','admin1234','2026-04-23 13:04:06',1,67,94),(9,96,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":349.8192488262911,\"y\":188.23236607142857},{\"x\":491.6514084507042,\"y\":176.18950892857143}]','admin1234','2026-04-23 13:04:18',1,67,96),(10,91,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":349.8192488262911,\"y\":188.23236607142857},{\"x\":491.6514084507042,\"y\":176.18950892857143},{\"x\":479.62323943661966,\"y\":143.0716517857143},{\"x\":393.4213615023474,\"y\":123.00022321428571}]','admin1234','2026-04-23 13:04:26',1,67,91),(11,92,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":349.8192488262911,\"y\":188.23236607142857},{\"x\":491.6514084507042,\"y\":176.18950892857143},{\"x\":479.62323943661966,\"y\":143.0716517857143},{\"x\":393.4213615023474,\"y\":123.00022321428571}]','admin1234','2026-04-23 13:04:31',1,67,92),(12,90,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":349.8192488262911,\"y\":188.23236607142857},{\"x\":679.0903755868544,\"y\":188.23236607142857},{\"x\":710.163145539906,\"y\":228.3752232142857}]','admin1234','2026-04-23 13:04:51',1,67,90),(13,95,'','[{\"x\":325.76291079812205,\"y\":248.4466517857143},{\"x\":349.8192488262911,\"y\":188.23236607142857},{\"x\":679.0903755868544,\"y\":188.23236607142857},{\"x\":725.1983568075117,\"y\":290.5966517857143}]','admin1234','2026-04-23 13:04:59',1,67,95),(14,67,'','[{\"x\":26.562206572769952,\"y\":478.26450892857144},{\"x\":286.1701877934272,\"y\":443.13950892857144},{\"x\":325.26173708920186,\"y\":247.44308035714286}]','권동해','2026-04-23 13:49:45',1,98,67),(15,67,'','[{\"x\":26.562206572769952,\"y\":478.26450892857144},{\"x\":176.91431924882627,\"y\":463.2109375},{\"x\":294.1889671361502,\"y\":429.08950892857143},{\"x\":325.26173708920186,\"y\":253.46450892857143}]','권동해','2026-04-23 13:50:03',0,99,67),(16,67,'','[{\"x\":177.91666666666666,\"y\":477.2609375},{\"x\":291.18192488262906,\"y\":428.0859375},{\"x\":330.2734741784037,\"y\":249.4502232142857}]','권동해','2026-04-23 13:50:21',1,99,67),(17,67,'','[{\"x\":297.19600938967136,\"y\":445.14665178571425},{\"x\":335.28521126760563,\"y\":239.41450892857142}]','권동해','2026-04-23 13:50:31',1,100,67),(18,67,'','[{\"x\":302.2077464788732,\"y\":360.8466517857143},{\"x\":333.28051643192487,\"y\":253.46450892857143}]','권동해','2026-04-23 13:50:39',1,93,67),(19,67,'','[{\"x\":344.30633802816897,\"y\":201.27879464285715},{\"x\":336.28755868544596,\"y\":247.44308035714286}]','권동해','2026-04-23 13:50:49',1,97,67),(20,67,'','[{\"x\":348.3157276995305,\"y\":180.20379464285713},{\"x\":335.28521126760563,\"y\":250.45379464285713}]','권동해','2026-04-23 13:50:59',1,94,67),(21,67,'','[{\"x\":398.43309859154925,\"y\":127.01450892857143},{\"x\":494.6584507042253,\"y\":147.0859375},{\"x\":495.66079812206567,\"y\":183.21450892857143},{\"x\":351.3227699530516,\"y\":189.2359375},{\"x\":336.28755868544596,\"y\":250.45379464285713}]','권동해','2026-04-23 13:51:17',1,91,67),(22,67,'','[{\"x\":398.43309859154925,\"y\":127.01450892857143},{\"x\":494.6584507042253,\"y\":147.0859375},{\"x\":495.66079812206567,\"y\":183.21450892857143},{\"x\":351.3227699530516,\"y\":189.2359375},{\"x\":336.28755868544596,\"y\":250.45379464285713}]','권동해','2026-04-23 13:51:25',1,92,67),(23,67,'','[{\"x\":711.1654929577464,\"y\":235.40022321428572},{\"x\":684.1021126760563,\"y\":185.22165178571427},{\"x\":356.3345070422535,\"y\":181.20736607142857},{\"x\":332.2781690140845,\"y\":249.4502232142857}]','권동해','2026-04-23 13:51:50',1,90,67),(24,67,'','[{\"x\":720.1866197183098,\"y\":305.6502232142857},{\"x\":315.2382629107981,\"y\":434.10736607142854},{\"x\":328.268779342723,\"y\":252.4609375}]','권동해','2026-04-23 13:52:09',1,95,67);
/*!40000 ALTER TABLE `campus_routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `floor_routes`
--

DROP TABLE IF EXISTS `floor_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `floor_routes` (
  `route_id` int NOT NULL AUTO_INCREMENT,
  `building` varchar(100) NOT NULL,
  `floor` varchar(20) DEFAULT NULL,
  `dest_room` varchar(100) NOT NULL,
  `route_name` varchar(200) DEFAULT NULL,
  `points_json` text NOT NULL,
  `floorplan_img` varchar(500) DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint DEFAULT '1',
  `room_id` int DEFAULT NULL,
  PRIMARY KEY (`route_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `floor_routes`
--

LOCK TABLES `floor_routes` WRITE;
/*!40000 ALTER TABLE `floor_routes` DISABLE KEYS */;
/*!40000 ALTER TABLE `floor_routes` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-23 15:22:34
