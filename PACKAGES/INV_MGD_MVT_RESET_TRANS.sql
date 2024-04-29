--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_RESET_TRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_RESET_TRANS" AUTHID CURRENT_USER AS
-- $Header: INVRMVTS.pls 115.4 2002/12/03 19:38:38 yawang ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVRMVTS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_MVT_RESET_TRANS                                    |
--|                                                                       |
--| HISTORY                                                               |
--|     06/12/2000 pseshadr        Created                                |
--|     11/09/2001 yawang          Add parameter p_reset_option           |
--|                                increased the version number to 2.0
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Reset_Transaction_Status   PUBLIC
--
-- PARAMETERS: x_return_status      Procedure return status
--             x_msg_count          Number of messages in the list
--             x_msg_data           Message text
--             p_api_version_number Known Version Number
--             p_init_msg_list      Empty PL/SQL Table listfor
--                                  Initialization
--
--             p_legal_entity_id    Legal Entity
--             p_zone_code          Zonal Code
--             p_usage_type         Usage Type
--             p_stat_type          Stat Type
----           p_period_name        Period Name for processing
--             p_document_source_type Document Source Type
--                                    (PO,SO,INV,RMA,RTV)
--             p_reset_option       Reset Status Option
--                                  (All, Ignore Only, Exclude Ignore)
--
-- VERSION   : current version         2.0
--             initial version         1.0
--
-- COMMENT   : Procedure specification
--             to Update the Movement Status to 'O-Open',
--             EDI_SENT_FLAG  = 'N' for the given Input parameters.

-- Updated   :  09/Jul/2000
-- History   :  11/09/2001 yawang   Add parameter p_reset_option,current
--                                  version number increased to 2.0
--=======================================================================--

PROCEDURE Reset_Transaction_Status
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE
, p_legal_entity_id      IN  NUMBER
, p_zone_code            IN  VARCHAR2
, p_usage_type           IN  VARCHAR2
, p_stat_type            IN  VARCHAR2
, p_period_name          IN  VARCHAR2
, p_document_source_type IN  VARCHAR2
, p_reset_option         IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
;


END INV_MGD_MVT_RESET_TRANS;

 

/
