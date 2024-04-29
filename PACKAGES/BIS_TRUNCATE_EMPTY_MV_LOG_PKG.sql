--------------------------------------------------------
--  DDL for Package BIS_TRUNCATE_EMPTY_MV_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TRUNCATE_EMPTY_MV_LOG_PKG" AUTHID CURRENT_USER AS
/*$Header: BISTEMLS.pls 120.0 2005/06/01 16:48 appldev noship $*/

FUNCTION Check_Refresh_Prog_running return number;

FUNCTION get_Table_size(p_obj_owner IN VARCHAR2
                          ,p_log_table IN VARCHAR2)
RETURN NUMBER;

PROCEDURE Truncate_Empty_MV_Log( errbuf   OUT NOCOPY VARCHAR2
                                ,retcode  OUT NOCOPY VARCHAR
                                ,threshold IN  NUMBER);
END BIS_TRUNCATE_EMPTY_MV_LOG_PKG;


 

/
