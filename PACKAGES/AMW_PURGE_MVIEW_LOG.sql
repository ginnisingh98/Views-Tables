--------------------------------------------------------
--  DDL for Package AMW_PURGE_MVIEW_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PURGE_MVIEW_LOG" AUTHID CURRENT_USER AS
/* $Header: amwslprs.pls 120.0 2005/05/31 20:04:42 appldev noship $ */

  FUNCTION GET_ROW_COUNT(schema_name VARCHAR2, table_name VARCHAR2)
	RETURN NUMBER;

  PROCEDURE PURGE_LOG(errbuf  OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY VARCHAR2);

  PROCEDURE REFRESH_ALL(errbuf  OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY VARCHAR2,
                      p_mview_name IN VARCHAR2);

END AMW_PURGE_MVIEW_LOG;

 

/
