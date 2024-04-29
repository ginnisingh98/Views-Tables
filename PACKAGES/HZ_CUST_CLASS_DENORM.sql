--------------------------------------------------------
--  DDL for Package HZ_CUST_CLASS_DENORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_CLASS_DENORM" AUTHID CURRENT_USER AS
/* $Header: ARHCLDPS.pls 115.2 2003/03/12 23:02:26 awu noship $ */


--
-- HISTORY
-- 05/10/2002       AWU    Created
--

-- Constants
   G_PKG_NAME               Constant VARCHAR2(30):='HZ_CUST_CLASS_DENORM';
   G_FILE_NAME              Constant VARCHAR2(12):='ARHCLDPS.pls';
   G_COMMIT_SIZE            Constant Number := 10000;

   -- The following two variables are used to indicate debug message is
   -- written to message stack(G_DEBUG_TRIGGER) or to log/output file
   -- (G_DEBUG_CONCURRENT).
   G_DEBUG_CONCURRENT       CONSTANT NUMBER := 1;
   G_DEBUG_TRIGGER          CONSTANT NUMBER := 2;

 -- Global variables
   G_Debug                  Boolean := True;
   G_CODE_LEVEL		    Constant number := 25;

Procedure Main(ERRBUF       OUT NOCOPY Varchar2,
    RETCODE      OUT NOCOPY Varchar2,
    p_class_category IN Varchar2,
    p_debug_mode IN  Varchar2,
    p_trace_mode IN  Varchar2);

procedure insert_class_codes(ERRBUF  OUT NOCOPY Varchar2,
	                      RETCODE OUT NOCOPY Varchar2,
		              p_class_category in varchar2);
End HZ_CUST_CLASS_DENORM;

 

/
