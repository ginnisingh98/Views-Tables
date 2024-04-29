--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_PURGE_TRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_PURGE_TRANS" AUTHID CURRENT_USER AS
-- $Header: INVPURGS.pls 115.3 2002/12/03 21:55:00 yawang ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVRMVTS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_MVT_PURGE_TRANS                                    |
--|                                                                       |
--| HISTORY                                                               |
--|     06/12/00 pseshadr        Created                                  |
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Purge_Movement_Transactions   PUBLIC
--
-- PARAMETERS: x_return_status      Procedure return status
--             p_legal_entity_id    Legal Entity
--             p_zone_code          Zonal Code
--             p_usage_type         Usage Type
--             p_stat_type          Stat Type
----           p_period_name        Period Name for processing
--             p_document_source_type Document Source Type
--                                    (PO,SO,INV,RMA,RTV)
--
-- VERSION   : current version         1.0
--             initial version         1.0
--
-- COMMENT   : Procedure specification

-- Updated   :  09/Jul/2000
--=======================================================================--

PROCEDURE Purge_Movement_Transactions
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE
, p_legal_entity_id      IN  NUMBER
, p_zone_code            IN  VARCHAR2
, p_usage_type           IN  VARCHAR2
, p_stat_type            IN  VARCHAR2
, p_period_name          IN  VARCHAR2
, p_document_source_type IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
;


END INV_MGD_MVT_PURGE_TRANS;

 

/
