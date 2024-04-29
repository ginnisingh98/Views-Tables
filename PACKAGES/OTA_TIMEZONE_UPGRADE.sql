--------------------------------------------------------
--  DDL for Package OTA_TIMEZONE_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TIMEZONE_UPGRADE" AUTHID CURRENT_USER as
/* $Header: ottznupg.pkh 120.2 2006/09/04 09:38:38 niarora noship $ */


   l_upgrade_status        BOOLEAN       := TRUE;

   PROCEDURE run_timezone_upgrade (ERRBUF OUT NOCOPY  VARCHAR2,RETCODE OUT NOCOPY VARCHAR2);
   PROCEDURE validate_proc_for_tz_upg (do_upg OUT NOCOPY VARCHAR2);
END;


 

/
