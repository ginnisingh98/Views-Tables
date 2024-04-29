--------------------------------------------------------
--  DDL for Package ICX_POR_EXT_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_EXT_UTL" AUTHID CURRENT_USER AS
/* $Header: ICXEXTUS.pls 120.1 2006/01/10 11:58:58 sbgeorge noship $*/


NOLOG_LEVEL     	PLS_INTEGER := -1;
MUST_LEVEL		PLS_INTEGER := 0;
ERROR_LEVEL		PLS_INTEGER := 1;
ANLYS_LEVEL		PLS_INTEGER := 2;
INFO_LEVEL		PLS_INTEGER := 3;
DEBUG_LEVEL		PLS_INTEGER := 4;
DETIL_LEVEL     	PLS_INTEGER := 100;

gDebugLevel     	PLS_INTEGER := INFO_LEVEL;

USE_FILE_SYSTEM		PLS_INTEGER := 1;
USE_CONCURRENT_LOG	PLS_INTEGER := 0;

UTL_FILE_DIR		VARCHAR2(20) := 'UTL_FILE_DIR';

gCommitSize  		PLS_INTEGER := 5000;

gFatalException 	EXCEPTION;
gException 		EXCEPTION;

-- PCREDDY: Bug # 3488764: Error message for file open error
UTL_FILE_ERR_MSG        VARCHAR2(1000) := fnd_global.newline ||
  '=============================================================================' ||
  fnd_global.newline ||
  'Unable to write the debug messages to the log file.' ||
  fnd_global.newline ||
  'FIX:' ||
  fnd_global.newline ||
  'Ensure that the virtual path assigned to the ' ||
  'APPLPTMP environment variable is valid, writable, and is referenced ' ||
  'at the beginning of the UTL_FILE_DIR database parameter in init.ora.' ||
  fnd_global.newline ||
  '=============================================================================' ||
  fnd_global.newline;

PROCEDURE setDebugLevel(pLevel	IN PLS_INTEGER);
PROCEDURE debug(pLevel		IN PLS_INTEGER,
                pMsg		IN VARCHAR2) ;
PROCEDURE debug(pMsg		IN VARCHAR2) ;

PROCEDURE pushError(pMsg	IN VARCHAR2);
PROCEDURE printStackTrace;

PROCEDURE setFilePath(pFilePath	IN VARCHAR2 DEFAULT UTL_FILE_DIR);
FUNCTION  getFilePath RETURN VARCHAR2;
PROCEDURE setUseFile(pUseFile	IN PLS_INTEGER DEFAULT USE_FILE_SYSTEM);
PROCEDURE openLog(pFileName	IN varchar2,
                  pOpenMode	IN varchar2 DEFAULT 'w');
PROCEDURE closeLog;

PROCEDURE extCommit;
PROCEDURE extAFCommit;
PROCEDURE extRollback;

FUNCTION getTableElement(pTable	IN DBMS_SQL.NUMBER_TABLE,
                         pIndex IN BINARY_INTEGER)
  RETURN VARCHAR2;

FUNCTION getTableElement(pTable	IN DBMS_SQL.VARCHAR2_TABLE,
                         pIndex IN BINARY_INTEGER)
  RETURN VARCHAR2;

FUNCTION getTableElement(pTable	IN DBMS_SQL.UROWID_TABLE,
                         pIndex IN BINARY_INTEGER)
  RETURN VARCHAR2;

FUNCTION getTableElement(pTable	IN DBMS_SQL.DATE_TABLE,
                         pIndex IN BINARY_INTEGER)
  RETURN VARCHAR2;

FUNCTION getIcxSchema RETURN VARCHAR2;

FUNCTION getTimeStamp RETURN VARCHAR2;

FUNCTION getDatabaseVersion RETURN NUMBER;

END ICX_POR_EXT_UTL;

 

/
