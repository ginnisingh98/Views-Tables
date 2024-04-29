--------------------------------------------------------
--  DDL for Package JMF_INTERLOCK_SHIKYU_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_INTERLOCK_SHIKYU_CP" AUTHID CURRENT_USER AS
-- $Header: JMFCSHKS.pls 120.1 2005/07/05 20:39 rajkrish noship $
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFCSHKS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Interlock SHIKYU Concurrent Program wrapper                       |
--| HISTORY                                                               |
--|     04/26/05 Prabha Seshadri created                                  |
--      rajkrish updated MOAC JUly 1
--+======================================================================--

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Interlock_SHIKYU_Manager     PUBLIC
-- PARAMETERS: x_retcode            OUT NOCOPY Return status
--             x_errbuff            OUT NOCOPY Return error message
--             p_batch_size         IN    Size of a batch
--             p_max_workers        IN    Number of workers allowed
--             p_operating_unit     IN    Operating Unit
--             p_from_organization  IN    From Organization
--             p_to_organization    IN    To Organization
-- COMMENT   : This is the concurrent program wrapper for the Interlock
--             SHIKYU Manager.This will invoke the JMF_Subcontract_Orders Private
--             package to load the subcontract orders and assign records to batches.
--=========================================================================
PROCEDURE Interlock_SHIKYU_Manager
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_size         IN  NUMBER
, p_max_workers        IN  NUMBER
, p_from_organization  IN  NUMBER
, p_to_organization    IN  NUMBER
);

--========================================================================
-- PROCEDURE : Interlock_SHIKYU_Worker     PUBLIC
-- PARAMETERS: x_retcode            OUT NOCOPY  Return status
--             x_errbuff            OUT NOCOPY  Return error message
--             p_batch_id           IN    Batch identifier
-- COMMENT   : This procedure will process all the records in the batch
--=========================================================================
PROCEDURE Interlock_SHIKYU_Worker
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_id           IN  NUMBER
);

--========================================================================
-- PROCEDURE :Run_SHIKYU_reconciliation     PUBLIC
-- PARAMETERS:
--             x_retcode            OUT NOCOPY Return status
--             x_errbuff            OUT NOCOPY Return error message
--             p_operating_unit         IN    Operating Unit
--             p_from_organization   IN    From Organization
--             p_to_organization       IN    To Organization
-- COMMENT   : This is the concurrent program wrapper for the SHIKYU
--                            reconciliation process
--=========================================================================

PROCEDURE Run_SHIKYU_reconciliation
( x_retcode                     OUT NOCOPY VARCHAR2
, x_errbuff                       OUT NOCOPY VARCHAR2
, p_from_organization         IN  NUMBER
, p_to_organization             IN  NUMBER
);
END JMF_Interlock_SHIKYU_CP;

 

/
