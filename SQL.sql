CREATE TABLE `mms_whitelistquestions` (
	`identifier` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`whitelisted` INT(11) NULL DEFAULT '0',
	`banned` INT(11) NULL DEFAULT '0',
	`bantime` INT(11) NULL DEFAULT '0'
)
COLLATE='armscii8_general_ci'
ENGINE=InnoDB
;
