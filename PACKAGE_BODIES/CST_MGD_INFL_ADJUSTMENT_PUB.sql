--------------------------------------------------------
--  DDL for Package Body CST_MGD_INFL_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_MGD_INFL_ADJUSTMENT_PUB" AS
/* $Header: CSTPIADB.pls 115.6 2004/04/03 02:56:56 vjavli ship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_MGD_INFL_ADJUSTMENT_PUB';

--===================
-- PUBLIC PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Period_Final_Status    PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_acct_period_id        Account period ID
--             x_return_status         Return error if failed
-- COMMENT   : This procedure makes the inflation adjusted period status
--             to FINAL
-- USAGE     : This procedue is used in Create Historical Costs to set the
--             inflation status FINAL
-- EXCEPTIONS: g_exception1            exception description
--========================================================================
PROCEDURE Create_Period_Final_Status
( p_org_id         IN         NUMBER
, p_acct_period_id IN         NUMBER
, x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO
    CST_MGD_INFL_ADJ_PER_STATUSES(
      Organization_ID
    , Acct_Period_ID
    , Last_Update_Date
    , Last_Updated_By
    , Creation_Date
    , Created_By
    , Last_Update_Login
    , Request_ID
    , Program_Application_ID
    , Program_ID
    , Program_Update_Date
    , STATUS
    )
  VALUES(
      p_org_id
    , p_acct_period_id
    , SYSDATE
    , NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
    , SYSDATE
    , NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),0)
    , TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'))
    , TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID'))
    , TO_NUMBER(FND_PROFILE.Value('PROG_APPL_ID'))
    , TO_NUMBER(FND_PROFILE.Value('CONC_PROG_ID'))
    , SYSDATE
    , 'FINAL'
    );

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Create_Period_Final_Status'
                             );
    END IF;
    RAISE;

END Create_Period_Final_Status;


--========================================================================
PROCEDURE Create_Historical_Cost (
  p_api_version_number      IN  NUMBER
, p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_historical_infl_adj_rec IN  Inflation_Adjustment_Rec_Type
)
IS
l_return_status           VARCHAR2(1);
l_api_version_number      NUMBER := 1.0;
L_API_NAME                CONSTANT VARCHAR2(30) := 'Create_Historical_Cost';
l_historical_infl_adj_rec Inflation_Adjustment_Rec_Type;
BEGIN

  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , L_API_NAME
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

  l_historical_infl_adj_rec := p_historical_infl_adj_rec;

  -- Clear status table
  DELETE FROM CST_MGD_INFL_ADJ_PER_STATUSES
  WHERE ORGANIZATION_ID = l_historical_infl_adj_rec.organization_id
    AND ACCT_PERIOD_ID  = l_historical_infl_adj_rec.acct_period_id;

  -- Attribute level validation
  CST_MGD_INFL_ADJUSTMENT_PVT.Validate_Hist_Attributes
  ( p_historical_infl_adj_rec => l_historical_infl_adj_rec
  , x_return_status           => l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Default missing attributes
  CST_MGD_INFL_ADJUSTMENT_PVT.Hist_Default
  ( p_historical_infl_adj_rec => l_historical_infl_adj_rec
  , x_historical_infl_adj_rec => l_historical_infl_adj_rec
  );

  CST_MGD_INFL_ADJUSTMENT_PVT.Insert_Inflation_Adj
  ( p_inflation_adjustment_rec => l_historical_infl_adj_rec
  );

  -- Make period final
  Create_Period_Final_Status
  ( p_org_id         => l_historical_infl_adj_rec.organization_id
  , p_acct_period_id => l_historical_infl_adj_rec.acct_period_id
  , x_return_status  => l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    DELETE FROM CST_MGD_INFL_ADJUSTED_COSTS
    WHERE Organization_ID = l_historical_infl_adj_rec.organization_id
      AND Acct_Period_ID  = l_historical_infl_adj_rec.acct_period_id;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    DELETE FROM CST_MGD_INFL_ADJUSTED_COSTS
    WHERE Organization_ID = l_historical_infl_adj_rec.organization_id
      AND Acct_Period_ID  = l_historical_infl_adj_rec.acct_period_id;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    DELETE FROM CST_MGD_INFL_ADJUSTED_COSTS
    WHERE Organization_ID = l_historical_infl_adj_rec.organization_id
      AND Acct_Period_ID  = l_historical_infl_adj_rec.acct_period_id;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Create_Historical_Cost'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );

END Create_Historical_Cost;


--========================================================================
-- PROCEDURE : Delete_All_Historical_Costs PUBLIC
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : User use this API to refresh the inflation adjustment
--             process
--========================================================================
PROCEDURE Delete_All_Historical_Costs (
  p_api_version_number IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_return_status      VARCHAR2(1);
l_api_version_number NUMBER := 1.0;
L_API_NAME           CONSTANT VARCHAR2(30) := 'Delete_All_Historical_Costs';
BEGIN

  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , L_API_NAME
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

  DELETE FROM CST_MGD_INFL_ADJUSTED_COSTS;

  DELETE FROM CST_MGD_INFL_TSF_ORG_ENTRIES;

  DELETE FROM CST_MGD_INFL_ADJ_PER_STATUSES;

EXCEPTION

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
      , 'Delete_All_Historical_Costs'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

END Delete_All_Historical_Costs;


END CST_MGD_INFL_ADJUSTMENT_PUB;

/
