CREATE TABLE `kps_peds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `ped` varchar(50) NOT NULL,
  `owned_peds` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;