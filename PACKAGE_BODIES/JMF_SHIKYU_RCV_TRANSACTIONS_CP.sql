--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_RCV_TRANSACTIONS_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_RCV_TRANSACTIONS_CP" AS
-- $Header: JMFCSKTB.pls 120.1 2005/06/30 07:11 nesoni noship $
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFCSKTB.pls                                                      |
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
, p_group_id        IN  NUMBER
)
IS

l_return_status VARCHAR2(1);

BEGIN
  -- Call method from private package.
  JMF_PROCESS_SHIKYU_RCV_TRX_PVT.Process_Shikyu_Rcv_trx
  ( p_api_version =>1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_request_id => p_request_id,
    p_group_id => p_group_id,
    x_return_Status => l_return_status );

  -- If return status is not Success then raise exception
  -- to propogate error to concurrent program
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   raise FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_retcode := 2;
    x_errbuff := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                        ,1
                        ,250);


END Process_Shikyu_Rcv_Trx_Cp;



END JMF_SHIKYU_RCV_TRANSACTIONS_CP;

/
