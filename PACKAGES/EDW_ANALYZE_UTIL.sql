--------------------------------------------------------
--  DDL for Package EDW_ANALYZE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ANALYZE_UTIL" AUTHID CURRENT_USER AS
/* $Header: EDWARSTS.pls 115.5 2003/11/19 09:19:35 smulye noship $  */
VERSION	CONSTANT CHAR(80) := '$Header: EDWARSTS.pls 115.5 2003/11/19 09:19:35 smulye noship $';

-- ------------------------
-- Global Variables
-- ------------------------

-- ------------------------
-- Public Procedures
-- ------------------------


Procedure analyze_table( p_table_name  in Varchar2);

Procedure analyze_wh_tables(Errbuf      in out nocopy  Varchar2,
                Retcode     	in out  nocopy Varchar2);

end;


 

/
