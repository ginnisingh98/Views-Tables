--------------------------------------------------------
--  DDL for Package OTA_GENERIC_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_GENERIC_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: otagenrp.pkh 115.0 99/07/16 00:49:35 porting ship $ */

----------------------------------------------------------------------------
--|---------------------< different_currency > ----------------------------|
----------------------------------------------------------------------------
--Description:
-- This function checks to see if the currencies of the totals to be sumed
-- are the same.

Function  different_currency (event in  number,
		      tablename in  varchar2
		  ) RETURN Boolean;



--
--

END ota_generic_report_pkg;

 

/
