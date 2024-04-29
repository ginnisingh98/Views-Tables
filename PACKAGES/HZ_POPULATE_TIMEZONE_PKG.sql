--------------------------------------------------------
--  DDL for Package HZ_POPULATE_TIMEZONE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_POPULATE_TIMEZONE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHTZCPS.pls 115.0 2003/09/05 01:05:01 awu noship $ */

   G_DEBUG_CONCURRENT       CONSTANT NUMBER := 1;
   G_DEBUG_TRIGGER          CONSTANT NUMBER := 2;

   G_Debug                  Boolean := True;
   G_CODE_LEVEL		    Constant number := 25;

PROCEDURE PHONE_TIMEZONE(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_overwrite_flag IN varchar2);

PROCEDURE LOCATION_TIMEZONE(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_overwrite_flag IN varchar2);

END;

 

/
