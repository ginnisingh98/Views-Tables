--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_PURGE_TRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_PURGE_TRANS" AS
-- $Header: INVPURGB.pls 120.0.12010000.2 2008/10/22 13:39:38 ajmittal ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVPURGB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Purge_Movement_Transactions                                            |
--|                                                                       |
--| HISTORY                                                               |
--|     06/12/00 pseshadr        Created                                  |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_MGD_MVT_PURGE_TRANS';
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_PURGE_TRANS.';
g_too_many_transactions_exc  EXCEPTION;
g_no_data_transaction_exc    EXCEPTION;
g_final_excp_list      INV_MGD_MVT_DATA_STR.excp_list ;
g_trans_rec            INV_MGD_MVT_DATA_STR.Trans_list;

--========================================================================
-- PROCEDURE : Purge_Movement_Transactions   PUBLIC
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
--
-- VERSION   : current version         1.0
--             initial version         1.0
--
-- COMMENT   : Procedure body to Update the Movement Status to 'O-Open',
--             EDI_SENT_FLAG      = 'N'
---            for the given Input parameters.

--- UPDATED  : 12/Jul/2000
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
IS
  l_api_version_number   CONSTANT NUMBER       := 1.0;
  l_procedure_name             CONSTANT VARCHAR2(30) := 'Purge_Movement_Transactions';

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

  x_return_status := FND_API.G_RET_STS_SUCCESS;/*bug #7499719 'Y' was hardcoded changed to standard*/

  DELETE FROM MTL_MOVEMENT_STATISTICS
  WHERE  entity_org_id      = p_legal_entity_id
   AND   upper(stat_type)   like nvl(upper(p_stat_type),'%')
   AND   upper(usage_type)  like nvl(upper(p_usage_type),'%')
   AND   upper(zone_code)   like nvl(upper(p_zone_code),'%')
   AND   upper(period_name) =    upper(p_period_name)
   AND   upper(document_source_type)
                like nvl(upper(p_document_source_type),'%')
   AND   (MOVEMENT_STATUS IN ('F','I','X')
   OR  EDI_SENT_FLAG      = 'Y')
 ;


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

   WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;/*bug #7499719 'Y' was hardcoded changed to standard*/
    FND_MESSAGE.Set_Name('INV', 'INV_NO_DATA_TRANSACTIONS');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Update_Movement_Status'
      );
    END IF;
    RAISE g_no_data_transaction_exc;

  WHEN TOO_MANY_ROWS THEN
    x_return_status :=FND_API.G_RET_STS_ERROR;/*bug #7499719 'Y' was hardcoded changed to standard*/
    FND_MESSAGE.Set_Name('INV', 'INV_TOO_MANY_TRANSACTIONS');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Update_Movement_Status'
      );
    END IF;
    RAISE g_too_many_transactions_exc;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Purge_Movement_Transactions'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

END Purge_Movement_Transactions;

END INV_MGD_MVT_PURGE_TRANS;

/
