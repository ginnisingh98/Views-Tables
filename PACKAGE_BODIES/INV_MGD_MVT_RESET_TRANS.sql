--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_RESET_TRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_RESET_TRANS" AS
-- $Header: INVRMVTB.pls 120.0 2005/05/25 05:39:20 appldev noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVRMVTB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Reset_Transaction_Status                                          |
--|                                                                       |
--| HISTORY                                                               |
--|     06/12/2000 pseshadr        Created                                |
--|     11/09/2001 yawang          Add parameter p_reset_option           |
--|                                increased version number to 2.0        |
--|     01/16/2002 yawang          Add movement status "Pending" to support|
--|                                Reference Period                       |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_MGD_MVT_RESET_TRANS';
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_RESET_TRANS.';

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
--                                  (All, Ignore Only,Exclude Ignore)
--
-- VERSION   : current version         2.0
--             initial version         1.0
--
-- COMMENT   : Procedure body to Update the Movement Status to 'O-Open',
--             EDI_SENT_FLAG      = 'N'
---            for the given Input parameters.

--- UPDATED  : 01/16/2002
--=======================================================================--

PROCEDURE Reset_Transaction_Status
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
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
IS
  l_api_version_number   CONSTANT NUMBER       := 2.0;
  l_procedure_name             CONSTANT VARCHAR2(30) := 'Reset_Transaction_Status';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
    ( l_api_version_number
    , p_api_version_number
    , l_procedure_name
    , G_PKG_NAME
    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_reset_option = 'NOIGNORE'
  THEN
    UPDATE
      mtl_movement_statistics
    SET
      movement_status    = 'O'
    , edi_sent_flag      = 'N'
    , last_updated_by    = NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
    , last_update_date   = SYSDATE
    , report_reference   = NULL
    WHERE  entity_org_id = p_legal_entity_id
      AND  zone_code     = p_zone_code
      AND  stat_type     = p_stat_type
      AND  usage_type    = p_usage_type
      AND  period_name   = p_period_name
      AND  document_source_type = NVL(p_document_source_type,
                                  document_source_type)
      AND  movement_status NOT IN ('I', 'P');
  ELSIF p_reset_option = 'IGNORE'
  THEN
    UPDATE
      mtl_movement_statistics
    SET
      movement_status    = 'O'
    , edi_sent_flag      = 'N'
    , last_updated_by    = NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
    , last_update_date   = SYSDATE
    , report_reference   = NULL
    WHERE  entity_org_id = p_legal_entity_id
      AND  zone_code     = p_zone_code
      AND  stat_type     = p_stat_type
      AND  usage_type    = p_usage_type
      AND  period_name   = p_period_name
      AND  document_source_type = NVL(p_document_source_type,
                                  document_source_type)
      AND  movement_status = 'I';
  ELSE
    UPDATE
      mtl_movement_statistics
    SET
      movement_status    = 'O'
    , edi_sent_flag      = 'N'
    , last_updated_by    = NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
    , last_update_date   = SYSDATE
    , report_reference   = NULL
    WHERE  entity_org_id = p_legal_entity_id
      AND  zone_code     = p_zone_code
      AND  stat_type     = p_stat_type
      AND  usage_type    = p_usage_type
      AND  period_name   = p_period_name
      AND  document_source_type = NVL(p_document_source_type,
                                  document_source_type)
      AND  movement_status <> 'P';
  END IF;

  -- Commit the Operation
  COMMIT;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Reset_Transaction_Status'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );
END Reset_Transaction_Status;

END INV_MGD_MVT_RESET_TRANS;

/
