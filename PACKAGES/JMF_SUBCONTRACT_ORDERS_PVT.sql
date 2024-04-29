--------------------------------------------------------
--  DDL for Package JMF_SUBCONTRACT_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SUBCONTRACT_ORDERS_PVT" AUTHID CURRENT_USER AS
-- $Header: JMFVSHKS.pls 120.0 2005/07/05 15:57 rajkrish noship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFVSHKS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   Main Package for SHIKYU Interlock processor                         |
--| HISTORY                                                               |
--|     04/26/2005 pseshadr       Created                                 |
--+========================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Subcontract_Orders_Manager    PUBLIC
-- PARAMETERS: p_batch_size          Batch size to be processed
--             p_max_workers         Maximum no of workers allowed
--             p_operating_unit      Operating Unit
--             p_from_organization   From Organization
--             p_to_organization     To Organization
--             p_init_msg_list       indicate if msg list needs to be initialized
--             p_validation_level    Validation Level
-- COMMENT   : The Interlock Concurrent program manager invokes this procedure
--             to process all the Subcontract Orders. This is the main entry
--             point for processing any subcontract records.
--========================================================================
PROCEDURE Subcontract_Orders_Manager
( p_batch_size                 IN   NUMBER
, p_max_workers                IN   NUMBER
, p_operating_unit             IN   NUMBER
, p_from_organization          IN   NUMBER
, p_to_organization            IN   NUMBER
, p_init_msg_list              IN  VARCHAR2
, p_validation_level           IN  NUMBER
);

--========================================================================
-- PROCEDURE : Subcontract_Orders_Worker    PUBLIC
-- PARAMETERS: p_batch_id          Batch Id
-- COMMENT   : This procedure is invoked by the Subcontract_Orders_manager.
--             After the batch is assigned by the Manager, the Subcontract
--             Orders Manager process will launch this worker to complete
--             the processing of the Subcontract Orders.
--========================================================================
PROCEDURE Subcontract_Orders_Worker
( p_batch_id         IN   NUMBER
);

END JMF_SUBCONTRACT_ORDERS_PVT;

 

/
