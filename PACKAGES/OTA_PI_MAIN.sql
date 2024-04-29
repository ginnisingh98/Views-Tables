--------------------------------------------------------
--  DDL for Package OTA_PI_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_PI_MAIN" AUTHID CURRENT_USER AS
/* $Header: otpimain.pkh 120.2 2005/07/05 00:05:24 sbairagi noship $ */

PROCEDURE def_bg_data (errbuf out NOCOPY varchar2,
  retcode out NOCOPY number,
  p_business_group_id IN NUMBER DEFAULT NULL);
end OTA_PI_MAIN;

 

/
