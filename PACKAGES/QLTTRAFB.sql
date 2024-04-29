--------------------------------------------------------
--  DDL for Package QLTTRAFB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTTRAFB" AUTHID CURRENT_USER as
/* $Header: qlttrafb.pls 120.1 2005/10/10 02:55:22 ntungare noship $ */

-- 5/21/96 - CREATED
-- Paul Mishkin

FUNCTION FORMAT_SQL_VALIDATION_STRING (X_STRING VARCHAR2) RETURN VARCHAR2;
FUNCTION VALIDATE_TYPE(X_VALUE VARCHAR2, X_DATATYPE NUMBER) RETURN BOOLEAN;
PROCEDURE EXEC_SQL (STRING IN VARCHAR2);
FUNCTION DECODE_ACTION_VALUE_LOOKUP (NUM NUMBER) RETURN VARCHAR2;
FUNCTION DECODE_OPERATOR (OP NUMBER) RETURN VARCHAR2;

PROCEDURE VALIDATE_DISABLED(COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            ERROR_MESSAGE VARCHAR2,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER);

PROCEDURE VALIDATE_MANDATORY(COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            ERROR_MESSAGE VARCHAR2,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER,
                            PARENT_COL_NAME VARCHAR2,
                            ERROR_COL_LIST VARCHAR2);

PROCEDURE VALIDATE_LOOKUPS(COL_NAME VARCHAR2,
                          ERROR_COL_NAME VARCHAR2,
                          ERROR_MESSAGE VARCHAR2,
                          X_GROUP_ID NUMBER,
                          X_USER_ID NUMBER,
                          X_LAST_UPDATE_LOGIN NUMBER,
                          X_REQUEST_ID NUMBER,
                          X_PROGRAM_APPLICATION_ID NUMBER,
                          X_PROGRAM_ID NUMBER,
                          X_CHAR_ID NUMBER,
                          X_PLAN_ID NUMBER,
                          ERROR_COL_LIST VARCHAR2);

PROCEDURE VALIDATE_PARENT_ENTERED(COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            ERROR_MESSAGE VARCHAR2,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER,
                            PARENT_COL_NAME VARCHAR2,
                            ERROR_COL_LIST VARCHAR2);

-- Tracking Bug : 3104827. Review Tracking Bug : 3148873
-- Added for Read Only for Flag Collection Plan Elements
-- saugupta Thu Aug 28 08:59:59 PDT 2003
PROCEDURE VALIDATE_READ_ONLY(P_COL_NAME VARCHAR2,
                            P_ERROR_COL_NAME VARCHAR2,
                            P_ERROR_MESSAGE VARCHAR2,
                            P_GROUP_ID NUMBER,
                            P_USER_ID NUMBER,
                            P_LAST_UPDATE_LOGIN NUMBER,
                            P_REQUEST_ID NUMBER,
                            P_PROGRAM_APPLICATION_ID NUMBER,
                            P_PROGRAM_ID NUMBER,
                            P_PARENT_COL_NAME VARCHAR2,
                            P_ERROR_COL_LIST VARCHAR2);

--
-- BUG 4635316
-- Added the Function  already present in the Package Body to the spec
-- Replaces every occurrence of X_OLD_TOKEN, in upper, lower, or mixed
-- case, with X_NEW_TOKEN. Assumes that both tokens are sent in upper case.
-- ntungare Sun Oct  9 23:54:14 PDT 2005
--
FUNCTION REPLACE_TOKEN( X_STRING VARCHAR2,
                        X_OLD_TOKEN VARCHAR2,
                        X_NEW_TOKEN VARCHAR2 ) RETURN VARCHAR2;


END QLTTRAFB;


 

/
