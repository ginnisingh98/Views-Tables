--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_VALIDATE_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_VALIDATE_PROC" AUTHID CURRENT_USER AS
-- $Header: INVVALCS.pls 115.4 2002/11/22 18:37:12 yawang ship $

--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVVALCS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_VALIDATE_PROC                                |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Validate_Transaction                                             |
--|                                                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     04/24/2000 ksaini        Created                                  |
--+======================================================================*/


--========================================================================
--PROCEDURE : Validate_Transaction         PUBLIC
--
--PARAMETERS: p_api_version_number       IN  Known api version
--            p_init_msg_list            IN  FND_API.G_FALSE to preserve list
--            p_legal_entity_id          IN  Legal Entity Id
--            p_economic_zone_code       IN  Economic Zone Code
--            p_usage_type               IN  Usage type
--            p_stat_type                IN  Stat Type
--            p_period_name              IN  Period name
--            p_document_source_type     IN  Document Source Type
--            x_return_status            OUT NOCOPY return status
--
--
-- VERSION   : current version            1.0
--             initial_version            1.0
-- COMMENT   : Wrapper API to call Validate_Movement_Statistics
--=======================================================================

PROCEDURE Validate_Transaction (
    p_api_version_number           IN  NUMBER    := 1
    , p_init_msg_list              IN  VARCHAR2  := FND_API.G_FALSE
    , p_legal_entity_id            IN  NUMBER
    , p_economic_zone_code         IN  VARCHAR2
    , p_usage_type                 IN  VARCHAR2
    , p_stat_type                  IN  VARCHAR2
    , p_period_name                IN  VARCHAR2
    , p_document_source_type       IN  VARCHAR2
    , x_return_status              OUT NOCOPY VARCHAR2
    , x_msg_count                  OUT NOCOPY NUMBER
    , x_msg_data                   OUT NOCOPY VARCHAR2
);

END INV_MGD_MVT_VALIDATE_PROC;

 

/
