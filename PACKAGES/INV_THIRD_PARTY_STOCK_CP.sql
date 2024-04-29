--------------------------------------------------------
--  DDL for Package INV_THIRD_PARTY_STOCK_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_THIRD_PARTY_STOCK_CP" AUTHID CURRENT_USER AS
-- $Header: INVCCCPS.pls 115.1 2002/12/11 01:51:58 dherring noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCCCPS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consumption Transactions Concurrent Program                       |
--| HISTORY                                                               |
--|     11/10/02 David Herring        Created                             |
--+======================================================================*/

--===============================================
-- CONSTANTS for concurrent program return values
--===============================================
-- Return values for RETCODE parameter (standard for concurrent programs):
RETCODE_SUCCESS                         VARCHAR2(10)    := '0';
RETCODE_WARNING                         VARCHAR2(10)    := '1';
RETCODE_ERROR                           VARCHAR2(10)    := '2';


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Consumption_Txn_Manager     PUBLIC
-- PARAMETERS: x_retcode            OUT   return status
--             x_errbuff            OUT   return error messages
--             p_batch_id           IN    Organization Hierarchy
--
-- COMMENT   : This procedure will set in motion the creation of
--             one or more consumption advices
--=========================================================================
PROCEDURE consumption_txn_manager
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_size         IN  NUMBER
, p_max_workers        IN  NUMBER
, p_vendor_name        IN  VARCHAR2
, p_vendor_site_id     IN  NUMBER
, p_item_id            IN  NUMBER
, p_org_id             IN  NUMBER
);

--========================================================================
-- PROCEDURE : Cons_Txn_Worker     PUBLIC
-- PARAMETERS: x_retcode            OUT   return status
--             x_errbuff            OUT   return error messages
--             p_batch_id           IN    Organization Hierarchy
--
-- COMMENT   : This procedure will set in motion the creation of
--             one consumption advice
--=========================================================================
PROCEDURE cons_txn_work
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_id           IN  NUMBER
);

END INV_THIRD_PARTY_STOCK_CP;

 

/
