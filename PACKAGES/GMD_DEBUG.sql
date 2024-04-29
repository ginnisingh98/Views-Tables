--------------------------------------------------------
--  DDL for Package GMD_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_DEBUG" AUTHID CURRENT_USER AS
/*  $Header: GMDUDBGS.pls 115.1 2002/11/08 16:26:03 txdaniel noship $    */
/*
REM *********************************************************************
REM *
REM * FILE:    GMDUDBGS.pls
REM * PURPOSE: Package Specification for the GMD degug utilities
REM * AUTHOR:  Olivier DABOVAL, OPM Development
REM * DATE:    27th May 2001
REM *
REM * PROCEDURE log_initialize
REM * PROCEDURE put_line
REM *
REM *
REM * HISTORY:
REM * ========
REM *
REM **********************************************************************
*/

--===================
-- CONSTANTS
--===================

G_LOG_ERROR                   CONSTANT NUMBER := 5;
G_LOG_EXCEPTION               CONSTANT NUMBER := 4;
G_LOG_EVENT                   CONSTANT NUMBER := 3;
G_LOG_PROCEDURE               CONSTANT NUMBER := 2;
G_LOG_STATEMENT               CONSTANT NUMBER := 1;

G_LOG_LEVEL                  NUMBER      := NULL;
G_LOG_ENABLED		     VARCHAR2(1) := 'N';
G_LOG_MODE                   VARCHAR2(3) := 'OFF';       -- possible values: OFF, SQL, SRS
G_LOG_LOCATION               VARCHAR2(500) := '.';
G_LOG_USERNAME               VARCHAR2(50);
G_FILE_NAME	             VARCHAR2(50) := 'DEBUGLOG';

--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
( p_file_name   IN VARCHAR2 DEFAULT '0'
);

--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE put_line
( p_msg                         IN  VARCHAR2
, p_priority                    IN  NUMBER   DEFAULT 100
, p_file_name                   IN  VARCHAR2 DEFAULT '0'
);

PROCEDURE display_messages
( p_msg_count			IN NUMBER
);

END  GMD_DEBUG;

 

/
