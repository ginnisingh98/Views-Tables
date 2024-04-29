--------------------------------------------------------
--  DDL for Package AR_MCC_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MCC_MERGE" AUTHID CURRENT_USER AS
/* $Header: ARXCMCRS.pls 115.0 2003/08/07 21:02:57 apandit noship $ */
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARXCMCRS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of AR_MCC_MERGE                                           |
--|                                                                       |
--| PUBLIC PROCEDURES                                                     |
--| Customer_Merge                                                        |
--| Note: This procedure will be called by the main Customer Merge(TCA)   |
--| feature                                                               |
--|                                                                       |
--| HISTORY                                                               |
--|     09/07/2001 vjavli        Created                                  |
--|                                                                       |
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
-- PROCEDURE : Customer_merge      PUBLIC
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

END AR_MCC_MERGE;

 

/
