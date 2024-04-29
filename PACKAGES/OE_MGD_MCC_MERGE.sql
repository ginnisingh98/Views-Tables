--------------------------------------------------------
--  DDL for Package OE_MGD_MCC_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_MGD_MCC_MERGE" AUTHID CURRENT_USER AS
/* $Header: OEXCMCRS.pls 120.1 2006/03/29 16:42:40 spooruli noship $ */
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OEXCMCRS.pls OBSOLETE                                             |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    This file is no longer used.  The body is stubbed out.             |
--|    Spec of OE_MGD_MCC_MERGE                                           |
--|                                                                       |
--| PUBLIC PROCEDURES                                                     |
--| Customer_Merge                                                        |
--| Note: This procedure will be called by the main Customer Merge(TCA)   |
--| feature                                                               |
--|                                                                       |
--| HISTORY                                                               |
--|     09/07/2001 vjavli        Created                                  |
--|     08/07/2003 vto           bug2089178 Added comments.no other change|
--+======================================================================*/


--===================
-- CONSTANTS
--===================

G_LOG_ERROR                   CONSTANT NUMBER := 5;
G_LOG_EXCEPTION               CONSTANT NUMBER := 4;
G_LOG_EVENT                   CONSTANT NUMBER := 3;
G_LOG_PROCEDURE               CONSTANT NUMBER := 2;
G_LOG_STATEMENT               CONSTANT NUMBER := 1;

--========================================================================
-- PROCEDURE : Customer_merge      PUBLIC    OBSOLETE
-- PARAMETERS: req_id          IN  NUMBER    Concurrent process request id
--             set_number      IN  NUMBER    Set Number
--             process_mode    IN  VARCHAR2  Process mode of the called
--                                           program
-- COMMENT   : This procedure deletes the records from the table
--             HZ_CREDIT_USAGES for the corresponding customer Ids in
--             RA_CUSTOMER_MERGE
--=========================================================================
PROCEDURE  Customer_Merge
( req_id       IN NUMBER
 ,set_number   IN NUMBER
 ,process_mode IN VARCHAR2
);

END OE_MGD_MCC_MERGE;

/
