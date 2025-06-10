CREATE TABLE IF NOT EXISTS `user_needs` (
  `identifier` varchar(60) NOT NULL,
  `pipi` int(11) NOT NULL DEFAULT 0,
  `cacca` int(11) NOT NULL DEFAULT 0,
  `sonno` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
