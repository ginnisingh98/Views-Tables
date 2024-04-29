--------------------------------------------------------
--  DDL for Package Body INV_MGD_POS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_POS_UTIL" AS
/* $Header: INVUPOSB.pls 115.2 2002/12/24 23:33:29 vjavli ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVUPOSB.pls                                                      |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Log_Initialize                                                    |
--|     Log                                                               |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Utilities for Inventory Position View and Export                  |
--|                                                                       |
--| HISTORY                                                               |
--|     09/01/2000 Paolo Juvara      Created                              |
--+======================================================================*/

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT          VARCHAR2(30) := 'INV_MGD_POS_UTIL';
g_log_level                  NUMBER       := NULL;
g_log_mode                   VARCHAR2(3)  := 'OFF';   -- values: OFF, SQL, SRS


--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
IS
BEGIN
  g_log_level  := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
  IF g_log_level IS NULL THEN
    g_log_mode := 'OFF';
  ELSE
    IF (TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')) <> 0) THEN
      g_log_mode := 'SRS';
    ELSE
      g_log_mode := 'SQL';
    END IF;
  END IF;

END Log_Initialize;


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
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
BEGIN
  IF ((g_log_mode <> 'OFF') AND (p_priority >= g_log_level))
  THEN
    IF g_log_mode = 'SQL'
    THEN
      -- SQL*Plus session: uncomment the next line during unit test
      -- DBMS_OUTPUT.put_line(p_msg);
      NULL;
    ELSE
      -- Concurrent request
      FND_FILE.put_line
      ( FND_FILE.log
      , p_msg
      );
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Log;


END INV_MGD_POS_UTIL;

/
