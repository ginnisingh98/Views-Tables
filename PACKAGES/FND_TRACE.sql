--------------------------------------------------------
--  DDL for Package FND_TRACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TRACE" AUTHID CURRENT_USER as
/* $Header: AFPMTRCS.pls 120.1 2005/07/02 03:06:11 appldev noship $ */

/* Trace Type Constant Definitions */

SQL_REGULAR         NUMBER :=  1 ;
SQL_BINDS           NUMBER :=  4 ;
SQL_WAITS           NUMBER :=  8 ;
SQL_BINDS_WAITS     NUMBER := 12 ;
PLSQL_INSTR         NUMBER := 10928 ;
PLSQL_PROF          NUMBER := 10941 ;
CBO                 NUMBER := 10053 ;

-- Exposing related_runid, spid and prof_runid can be obtained
-- using the get_trace_id function.

RELATED_RUNID       NUMBER;


procedure START_TRACE(TRACE_TYPE in NUMBER default SQL_WAITS );

procedure START_TRACE(TRACE_TYPE in NUMBER,
                      SESSION_ID in NUMBER,
                      SERIAL# in NUMBER);


procedure STOP_TRACE(TRACE_TYPE in NUMBER  default SQL_BINDS_WAITS);

procedure STOP_TRACE(TRACE_TYPE in NUMBER,
                     SESSION_ID in NUMBER,
                     SERIAL# in NUMBER);


procedure SET_TRACE_IDENTIFIER(IDENTIFIER_STRING in VARCHAR2);

procedure SET_MAX_DUMP_FILE_SIZE(TRACEFILE_SIZE in NUMBER);


function GET_TRACE_IDENTIFIER RETURN VARCHAR2;

function GET_TRACE_FILENAME RETURN VARCHAR2;

function GET_TRACE_LEVEL(TRACE_TYPE in NUMBER) RETURN NUMBER;

function GET_TRACE_ID(TRACE_TYPE in NUMBER) RETURN NUMBER;

function IS_TRACE_ENABLED(TRACE_TYPE in NUMBER) RETURN BOOLEAN;

function SUBMIT_PROFILER_REPORT(PROF_RUNID in NUMBER
                                ,RELATED_RUNID IN NUMBER
                                ,PURGE_DATA IN VARCHAR2 DEFAULT 'Y'
                               )
          RETURN NUMBER;



function SUBMIT_PROFILER_REPORT RETURN NUMBER;

end FND_TRACE;

 

/
