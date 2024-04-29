--------------------------------------------------------
--  DDL for Package FND_TRACE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TRACE_UTILS" AUTHID CURRENT_USER as
/* $Header: AFPMUTLS.pls 120.2 2005/11/03 14:54:39 rtikku noship $ */


procedure PLSQL_PROF_RPT( errbuf OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                          retcode OUT NOCOPY /* file.sql.39 change */ NUMBER,
                          RUN_ID in NUMBER,
                          RELATED_RUN in NUMBER,
                          PURGE_DATA IN VARCHAR2 DEFAULT 'Y' ,
                          CUTOFF_PCT in NUMBER default 1
                         );


procedure PLSQL_PROF_RPT( RUN_ID in NUMBER,
                          RELATED_RUN in NUMBER,
                          PURGE_DATA IN VARCHAR2 DEFAULT 'Y' ,
                          CUTOFF_PCT in NUMBER default 1
                         );


end FND_TRACE_UTILS;

 

/
