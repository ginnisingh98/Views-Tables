--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_RCV_TRANSACTIONS_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_RCV_TRANSACTIONS_CP" AUTHID CURRENT_USER AS
-- $Header: JMFCSKTS.pls 120.0 2005/06/30 05:51 nesoni noship $
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFCSKTS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Concurrent Program wrapper for SHIKYU operations triggered by     |
--|     RCV transactions.                                                 |
--| HISTORY                                                               |
--|     23-JUN-05 Neelam Soni created                                     |
--+======================================================================--

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Process_Shikyu_Rcv_Trx_Cp     PUBLIC
-- PARAMETERS: x_retcode            OUT NOCOPY Return status
--             x_errbuff            OUT NOCOPY Return error message
--             p_reuqest_id         IN    Request Id
--             p_group_id           IN    Group Id
-- COMMENT   : This is the concurrent program wrapper for SHIKYU operations
--             triggered after RCV transactions. Currently it handles OSA
--             Receipt, OSA Transactions and RTV at MP site against SHIKYU RMA.
--=========================================================================
PROCEDURE Process_Shikyu_Rcv_Trx_Cp
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_request_id         IN  NUMBER
, p_group_id           IN  NUMBER
);


END JMF_SHIKYU_RCV_TRANSACTIONS_CP;

 

/
