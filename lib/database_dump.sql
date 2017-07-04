 # database pandora 
 CREATE DATABASE `pandora` /*!40100 DEFAULT CHARACTER SET latin1 */;

 # table Users
CREATE TABLE `Users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(80) NOT NULL,
  `display_name` varchar(50) NOT NULL,
  `password` text NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1

# table Teams
CREATE TABLE `Teams` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `target_velocity` int(10) DEFAULT NULL,
  `days_in_iteration` int(10) DEFAULT NULL,
  `daily_meeting` varchar(100) DEFAULT NULL,
  `sprint_planning` varchar(100) DEFAULT NULL,
  `sprint_retrospective` varchar(100) DEFAULT NULL,
  `manager_id` int(10) DEFAULT NULL,
  `notes` text,
  `no_of_ba` int(11) DEFAULT NULL,
  `no_of_dev` int(11) DEFAULT NULL,
  `no_of_qa` int(11) DEFAULT NULL,
  `qa_filled` int(11) DEFAULT '0',
  `ba_filled` int(11) DEFAULT '0',
  `dev_filled` int(11) DEFAULT '0',
  `price` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_manager_id` (`manager_id`),
  CONSTRAINT `fk_manager_id` FOREIGN KEY (`manager_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1

# table departments
CREATE TABLE `departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dname` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1

# table employees
CREATE TABLE `employees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  `department` varchar(45) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` int(11) NOT NULL,
  `role_id` int(3) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1

# table sprints
 CREATE TABLE `sprints` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `project_id` int(4) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `sprint_title` varchar(100) DEFAULT NULL,
  `sprint_description` text,
  `velocity` int(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_project_id` (`project_id`),
  CONSTRAINT `fk_project_id` FOREIGN KEY (`project_id`) REFERENCES `Teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1

# table roles
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1

# table technical_skills
CREATE TABLE `technical_skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `technical_skill` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1

# table project_skill
CREATE TABLE `project_skill` (
  `id_project` int(5) NOT NULL,
  `id_skill` int(5) NOT NULL,
  PRIMARY KEY (`id_project`,`id_skill`),
  KEY `fk_skill_id` (`id_skill`),
  CONSTRAINT `fk_project_skill_id` FOREIGN KEY (`id_project`) REFERENCES `Teams` (`id`),
  CONSTRAINT `fk_skill_id` FOREIGN KEY (`id_skill`) REFERENCES `technical_skills` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1

# table employee_skill
CREATE TABLE `employee_skill` (
  `id_employee` int(5) NOT NULL,
  `id_skill` int(5) NOT NULL,
  PRIMARY KEY (`id_employee`,`id_skill`),
  KEY `fk_skill_emp_id` (`id_skill`),
  CONSTRAINT `fk_employee_id` FOREIGN KEY (`id_employee`) REFERENCES `employees` (`id`),
  CONSTRAINT `fk_skill_emp_id` FOREIGN KEY (`id_skill`) REFERENCES `technical_skills` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1

# table employee_performance
CREATE TABLE `employee_performance` (
  `sprint_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `velocity` int(11) NOT NULL,
  PRIMARY KEY (`sprint_id`,`employee_id`,`project_id`),
  KEY `fk_project_perf_id` (`project_id`),
  KEY `fk_employee_perf_id` (`employee_id`),
  CONSTRAINT `fk_employee_perf_id` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
  CONSTRAINT `fk_project_perf_id` FOREIGN KEY (`project_id`) REFERENCES `Teams` (`id`),
  CONSTRAINT `fk_sprint_perf_id` FOREIGN KEY (`sprint_id`) REFERENCES `sprints` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1

INSERT INTO `Teams` VALUES (1,'A Team',80,21,'9:25 PM','9:25 PM','11:25 PM',1,'',1,7,3,1,1,1),(2,'B team',120,15,'8:10 PM','8:10 PM','8:10 PM',1,'',1,10,3,1,1,1),(3,'C Team',100,15,'7:35 PM','7:35 PM,Friday','7:35 PM,Friday',1,'',1,4,1,0,0,1);
INSERT INTO `Users` VALUES (1,'m_edina_92@yahoo.com','edinamoldvai','strawb3rry'),(2,'m_edina_92@yahoo.comkjjhxfhffhgfcjb','edina.moldvai@evozon.com','strawb3rry'),(3,'m_edinmbna_92@yahoo.com','mhvhgm','strawb3rry'),(4,'test@edina.com','test','test'),(5,'ertert','rdgeereer',''),(6,'test','test','test'),(7,'test@something.com','test','test'),(8,'test_edina@yahoo.com','test_edina','{X-PBKDF2}HMACSHA2+512:AAAnEA:ogl0543MMOCBBA==:kyLt5KK6NUcHxcysqU3k2upg6apWOBlIE497us+4EF3IvBi67F/QXX5VPfKIRdZhGGm3JK3ZoDAjIbjxlxS9rA=='),(9,'test@tester.com','test','{X-PBKDF2}HMACSHA2+512:AAAnEA:5Ke1M6yg+3eKDA==:OMED3JcOxasKmOgkLg4tJO8Te7AwB1dt8QDiNvJCyPhVPNDSvV+z919vICn7YWwr/KjwLxZ95XV8OrUjZZuguw=='),(10,'testdfgdfg','test','{X-PBKDF2}HMACSHA2+512:AAAnEA:7WRHrLWWAi39xw==:mtS4Pce+K+3JLDZvrMbmZ/kdqkLq8eH47qLpfPUSPeVrGQXBIjSdmxQKpuzt4mf5CSJuEHiGDF8H7WRwAtCRPQ=='),(11,'test_user@yahoo.com','test','{X-PBKDF2}HMACSHA2+512:AAAnEA:m2POEhhLl3G01g==:ARcBL4h2+ot1gqSWpPpt+uwnBI3gBbKy4qjK8kP4Viic1huJUvGuvAmS8wJQGgK/SIopeH8DXfCZ610UeZit9Q==');
INSERT INTO `departments` VALUES (1,'perl'),(2,'javascript'),(3,'java'),(4,'.net'),(5,'ui/ux');
INSERT INTO `employee_skill` VALUES (2,1),(2,2),(2,3),(3,3),(3,8),(3,9),(4,9),(6,10);
INSERT INTO `employees` VALUES (2,'Edina','Moldvai','m_edina_92@yahoo.com','2017-01-21','1',3,'2017-02-11 17:48:20',1,1),(3,'Marius','Gog','m_edina_92@yahoo.com','2017-01-21','2',2,'2017-02-05 14:27:58',1,3),(4,'Nick','Johnson','m_edina_92@yahoo.com','2017-01-22','1',1,'2017-03-08 11:04:56',1,1),(5,'John','Doe','m_edina_92@yahoo.com','2017-01-27','5',1,'2017-03-08 11:04:44',1,2),(6,'Jane','Doe','m_edina_92@yahoo.com','2017-01-27','1',1,'2017-02-11 15:18:13',1,3);
INSERT INTO `project_skill` VALUES (1,0),(1,1),(1,2),(1,3),(1,7),(1,11),(1,12);
INSERT INTO `roles` VALUES (1,'Developer'),(2,'QA'),(3,'Business Analyst'),(4,'Database Analyst');
INSERT INTO `sprints` VALUES (11,1,'2017-01-01','2017-01-22','Sprint : 2017-01-01 - 2017-01-22','test',78),(12,1,'2017-01-22','2017-02-12','Sprint : 2017-01-22 - 2017-02-12','test',90),(13,1,'2017-02-13','2017-03-06','Sprint : 2017-02-13 - 2017-03-06','',79),(14,2,'2017-01-02','2017-01-17','Sprint : 2017-01-02 - 2017-01-17','',60),(15,1,'2017-03-07','2017-03-27','Sprint : 2017-03-07 - 2017-03-27','',80),(16,1,'2017-01-13','2017-02-03','Sprint : 2017-01-13 - 2017-02-03','',66),(17,1,'2017-03-11','2017-03-06','Sprint : 2017-03-11 - 2017-03-06','',80),(18,1,'2017-03-11','2017-03-06','Sprint : 2017-03-11 - 2017-03-06','',80),(19,1,'2017-03-11','2017-03-03','Sprint : 2017-03-11 - 2017-03-03','',6),(20,1,'2017-03-11','2017-03-02','Sprint : 2017-03-11 - 2017-03-02','',1),(21,1,'2017-03-11','2017-03-02','Sprint : 2017-03-11 - 2017-03-02','',1),(22,2,'2017-03-11','2017-03-03','Sprint : 2017-03-11 - 2017-03-03','',5),(23,1,'2017-03-11','2017-03-31','Sprint : 2017-03-11 - 2017-03-31','',8788),(24,3,'2017-01-02','2017-01-17','Sprint : 2017-01-02 - 2017-01-17','',5),(25,3,'2017-01-05','2017-01-20','Sprint : 2017-01-05 - 2017-01-20','',5),(26,3,'2017-03-11','2017-03-26','Sprint : 2017-03-11 - 2017-03-26','',6);
INSERT INTO `technical_skills` VALUES (1,'perl'),(2,'mysql'),(3,'git'),(4,' git'),(5,' perl'),(6,'html'),(7,'bootstrap'),(8,'ui'),(9,'javascript'),(10,'english'),(11,' mysql'),(12,' bootstrap'),(13,'backend'),(14,'scrum');
