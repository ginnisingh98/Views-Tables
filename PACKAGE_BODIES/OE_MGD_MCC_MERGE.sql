--------------------------------------------------------
--  DDL for Package Body OE_MGD_MCC_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_MGD_MCC_MERGE" AS
/* $Header: OEXCMCRB.pls 120.1 2006/03/29 16:42:18 spooruli noship $ */
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OEXCMCRB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Package body of OE_MGD_MCC_MERGE                                   |
--|                                                                       |
--| PUBLIC PROCEDURES                                                     |
--| Customer_Merge                                                        |
--| Note: This procedure is OBSOLETE.  This is now handled by an AR       |
--| package since the table is HZ.  Previously, it was called by the main |
--| Customer Merge(TCA) feature.                                          |
--|                                                                       |
--| HISTORY                                                               |
--|     09/07/2001 vjavli        Created                                  |
--|                                                                       |
--|     09/17/2001 vjavli        modified to have cursor for duplicate_id |
--|     10/09/2002 vjavli  Bug#2619854 fix: COMMIT removed                |
--|                        records will be deleted in full and not in     |
--|                        batches                                        |
--|     01/28/2003 vjavli  Bug#2447520 fix: TCA enhancments to insert     |
--|                        deleted record in the log table                |
--|     08/07/2003 vto     bug 3089178. stub out this file.               |
--+======================================================================*/

--=================
-- CONSTANTS
--=================
G_OE_MGD_MCC_MERGE VARCHAR2(30) := 'OE_MGD_MCC_MERGE';

--====================
-- Debug log variables
--====================
g_log_level     NUMBER      := NULL;  -- 0 for manual test
g_log_mode      VARCHAR2(3) := 'OFF'; -- possible values: OFF, SQL, SRS

--=====================================
-- PRIVATE VARIABLES
--=====================================
  g_count               NUMBER := 0;

--========================================================================
-- PROCEDURE  : Log_Initialize   PRIVATE OBSOLETE
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
IS
BEGIN
  NULL;
END Log_Initialize;


--========================================================================
-- PROCEDURE : Log                        PRIVATE OBSOLETE
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
--========================================================================
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
BEGIN
  NULL;
END Log;

--=========================================================================
-- PROCEDURE : Customer_merge      PUBLIC OBSOLETE
-- PARAMETERS: req_id          IN  NUMBER    Concurrent process request id
--             set_number      IN  NUMBER    Set Number
--             process_mode    IN  VARCHAR2  Process mode of the called
--                                           program
-- COMMENT   : This procedure deletes the records from the table
--             HZ_CREDIT_USAGES for the corresponding customer Ids in
--             RA_CUSTOMER_MERGES
--=========================================================================
PROCEDURE  Customer_Merge
( req_id       IN NUMBER
 ,set_number   IN NUMBER
 ,process_mode IN VARCHAR2
) IS

BEGIN
  NULL;
END Customer_Merge;

END OE_MGD_MCC_MERGE;

/
