--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_SETUP_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_SETUP_MDTR" AS
/* $Header: INVUSGSB.pls 120.1.12000000.2 2007/04/17 06:37:41 nesoni ship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    MGDUSGSB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of INV_MGD_MVT_SETUP_MDTR                                    |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Get_Setup_Context                                                 |
--|     Get_Invoice_Context                                               |
--|     Process_Setup_Context                                             |
--|     Get_Movement_Stat_Usages                                          |
--|     Get_Reference_Context                                             |
--|                                                                       |
--| HISTORY                                                               |
--|     12/04/2000 pseshadr     Created                                   |
--|     06/16/00   ksaini       Added Get_Movement_Stat_Usages Procedure  |
--|     07/06/00   ksaini       Added 2 columns for validation rules to   |
--|                             Get_Movement_Stat_Usages Procedure        |
--|     04/01/02   pseshadr     Added Get_Reference_Context procedure     |
--|     16/04/2007 Neelam Soni   Bug 5920143. Added support for Include   |
--|                              Establishments.                          |
--+=======================================================================

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_MGD_MVT_SETUP_MDTR';
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_SETUP_MDTR.';

--========================================================================
-- PROCEDURE : Get_Reference_Context       PRIVATE
-- PARAMETERS:
--             x_return_status         return status
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction type (SO,PO etc)
-- COMMENT   :
--             This processes all the transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Get_Reference_Context
( p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, ref_crsr               IN OUT NOCOPY INV_MGD_MVT_DATA_STR.setupCurTyp
)
IS
l_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_stat_typ_transaction  INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(100);
l_transaction_date      DATE;
l_reference_date        DATE;
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Reference_Context';

BEGIN

  INV_MGD_MVT_UTILS_PKG.Log_Initialize;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';
  l_transaction_date := p_movement_transaction.transaction_date;
  l_reference_date   := p_movement_transaction.reference_date;

  IF ref_crsr%ISOPEN THEN
     CLOSE ref_crsr;
  END IF;

  --Bug: 5920143. New column include_establishments has beed added in
  -- select clause
  OPEN ref_crsr FOR
  SELECT
    mstat.zone_code
  , UPPER(mstat.usage_type)
  , UPPER(mstat.stat_type )
  , mstat.start_period_name
  , mstat.end_period_name
  , mstat.period_set_name
  , mstat.period_type
  , mstat.weight_uom_code
  , mstat.conversion_type
  , mstat.attribute_rule_set_code
  , mstat.alt_uom_rule_set_code
  , glp.start_date
  , DECODE(mstat.end_period_name,NULL,NULL,glp1.end_date)
  , mstat.category_set_id
  , gllv.period_set_name
  , gllv.currency_code
  , gllv.currency_code
  , mstat.conversion_option
  , mstat.triangulation_mode
  , mstat.reference_period_rule
  , mstat.pending_invoice_days
  , mstat.prior_invoice_days
  , mstat.returns_processing
  , mstat.kit_method
  , nvl(mstat.include_establishments,'N')
  FROM
    GL_PERIODS glp
  , GL_PERIODS glp1
  , gl_ledger_le_v gllv
  , MTL_STAT_TYPE_USAGES mstat
  WHERE glp.period_set_name   = mstat.period_set_name
  AND   glp1.period_set_name  = mstat.period_set_name
  AND   glp.period_name       = mstat.start_period_name
  AND   glp1.period_name      = NVL(mstat.end_period_name,
                                    mstat.start_period_name)
  AND   gllv.legal_entity_id  = mstat.legal_entity_id
  AND   ledger_category_code  = 'PRIMARY'
  AND   mstat.legal_entity_id = p_legal_entity_id
  AND   mstat.zone_code       = p_movement_transaction.zone_code
  AND   mstat.usage_type      = p_movement_transaction.usage_type
  AND   mstat.stat_type       = p_movement_transaction.stat_type
  AND   trunc(l_transaction_date) BETWEEN trunc(glp.start_date) AND
          TRUNC(DECODE(mstat.end_period_name,NULL,
                        (l_transaction_date+1),glp1.end_date));


--  RETURN setup_crsr;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  RAISE;

  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';

    FND_MESSAGE.Set_Name('INV', 'INV_MGD_MVT_GET_TRANS_CP');
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Reference_Context'
                             );
    END IF;
    RAISE ;


  WHEN OTHERS THEN
    x_return_status := 'N';
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Reference_Context'
                             );
    END IF;
    RAISE;


END Get_Reference_Context;

--========================================================================
-- PROCEDURE : Get_Setup_Context
-- PARAMETERS:
--             x_return_status         return status
--             p_legal_entity_id       Legal Entity ID
--             p_movement_transaction  Movement Transaction record Type
--             setup_crsr                Cursr
-- COMMENT   :
--             This processes all the transaction for the specified legal
--             entity that  is set up in the parameters table.
--========================================================================

PROCEDURE Get_Setup_Context
( p_legal_entity_id      IN  NUMBER
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, setup_crsr             IN OUT NOCOPY INV_MGD_MVT_DATA_STR.setupCurTyp
)
IS
l_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(100);
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Setup_Context';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF setup_crsr%ISOPEN THEN
     CLOSE setup_crsr;
  END IF;

  OPEN setup_crsr FOR
  SELECT
    mstat.zone_code
  , UPPER(mstat.usage_type)
  , UPPER(mstat.stat_type )
  , mstat.reference_period_rule
  , mstat.pending_invoice_days
  , mstat.prior_invoice_days
  , mstat.triangulation_mode
  FROM
    MTL_STAT_TYPE_USAGES mstat
  WHERE mstat.legal_entity_id = p_legal_entity_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  RAISE;

  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';

    FND_MESSAGE.Set_Name('INV', 'INV_MGD_MVT_GET_TRANS_CP');
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Setup_Context'
                             );
    END IF;
    RAISE ;


  WHEN OTHERS THEN
    x_return_status := 'N';
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Setup_Context'
                             );
    END IF;
    RAISE;

END Get_Setup_Context;



--========================================================================
-- PROCEDURE : Get_Invoice_Context     PRIVATE
-- PARAMETERS:
--             x_return_status         return status
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction type (SO,PO etc)
-- COMMENT   :
--========================================================================

PROCEDURE Get_Invoice_Context
( p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, setup_crsr             IN OUT NOCOPY INV_MGD_MVT_DATA_STR.setupCurTyp
)
IS
l_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_stat_typ_transaction  INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(100);
l_transaction_date      DATE;
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Invoice_Context';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';
  l_transaction_date := p_movement_transaction.transaction_date;

  IF setup_crsr%ISOPEN THEN
     CLOSE setup_crsr;
  END IF;

  OPEN setup_crsr FOR
  SELECT
    mstat.start_period_name
  , mstat.end_period_name
  , mstat.period_set_name
  , mstat.period_type
  , mstat.weight_uom_code
  , mstat.conversion_type
  , mstat.attribute_rule_set_code
  , mstat.alt_uom_rule_set_code
  , glp.start_date
  , DECODE(mstat.end_period_name,NULL,NULL,glp1.end_date)
  , mstat.category_set_id
  , gllv.currency_code
  , gllv.currency_code
  , mstat.conversion_option
  , mstat.triangulation_mode
  , mstat.reference_period_rule
  , mstat.pending_invoice_days
  , mstat.prior_invoice_days
  , mstat.returns_processing
  FROM
    GL_PERIODS glp
  , GL_PERIODS glp1
  , gl_ledger_le_v gllv
  , MTL_STAT_TYPE_USAGES mstat
  WHERE glp.period_set_name   = glp1.period_set_name
  AND   glp.period_set_name   = mstat.period_set_name
  AND   glp1.period_set_name  = mstat.period_set_name
  AND   glp.period_type       = mstat.period_type
  AND   glp1.period_type      = mstat.period_type
  AND   glp.period_name       = mstat.start_period_name
  AND   glp1.period_name      = NVL(mstat.end_period_name,
                                    mstat.start_period_name)
  --AND   glb.period_set_name   = glp.period_set_name        fix bug2203762,3723698
  AND   gllv.legal_entity_id  = mstat.legal_entity_id
  AND   gllv.ledger_category_code  = 'PRIMARY'
  AND   mstat.legal_entity_id = p_legal_entity_id
  AND   mstat.zone_code       = p_movement_transaction.zone_code
  AND   mstat.usage_type      = p_movement_transaction.usage_type
  AND   mstat.stat_type       = p_movement_transaction.stat_type;

--  RETURN setup_crsr;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

/*
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
  -- report success
null;
  END IF;
*/

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  RAISE;

  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';

    FND_MESSAGE.Set_Name('INV', 'INV_MGD_MVT_GET_TRANS_CP');
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Invoice_Context'
                             );
    END IF;
    RAISE ;


  WHEN OTHERS THEN
    x_return_status := 'N';
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Invoice_Context'
                             );
    END IF;
    RAISE;

END Get_Invoice_Context;

--========================================================================
-- FUNCTION : Process_Setup_Context     PRIVATE
-- PARAMETERS: p_movement_transaction    Movement transaction record
-- COMMENT   : This function validates and checks to see if the transaction
--             is to be inserted into the mvt stats table
--========================================================================

FUNCTION Process_Setup_Context
( p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)RETURN VARCHAR2
IS
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_insert_flag          VARCHAR2(1);
  l_ship_from_loc        VARCHAR2(10);
  l_ship_to_loc          VARCHAR2(10);
  l_procedure_name CONSTANT VARCHAR2(30) := 'Process_Setup_Context';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_movement_transaction := p_movement_transaction;

  IF (l_movement_transaction.dispatch_territory_code =
       l_movement_transaction.destination_territory_code)
      OR
      (l_movement_transaction.dispatch_territory_code  IS NULL)
      OR
      (l_movement_transaction.destination_territory_code IS NULL)

  THEN
    l_insert_flag   := 'N';
    l_ship_from_loc := null;
    l_ship_to_loc   := null;

  ELSE

-- Based on the dispatch and destination territory codes determine
-- the zone that the territory codes are part of.

    l_ship_from_loc :=
      INV_MGD_MVT_UTILS_PKG.Get_Zone_Code
     ( p_territory_code => l_movement_transaction.dispatch_territory_code
     , p_zone_code      => l_movement_transaction.zone_code
     , p_trans_date     => l_movement_Transaction.transaction_date
     );

    l_ship_to_loc :=
      INV_MGD_MVT_UTILS_PKG.Get_Zone_Code
   ( p_territory_code => l_movement_transaction.destination_territory_code
     , p_zone_code      => l_movement_transaction.zone_code
     , p_trans_date     => l_movement_Transaction.transaction_date
     );

  END IF;

-- If the dispatch and destination territory codes are within the same
-- economic zones then the transaction is of usage_type INTERNAL.
-- Check if there is an entry in the MTL_STAT_TYPE_USAGES table for
-- usage_type of INTERNAL, if there is then we go ahead and process
-- the transaction, otherwise get the next record from the c_shp loop.

  IF l_movement_transaction.usage_type = 'INTERNAL'
  THEN

    IF (l_ship_from_loc IS NOT NULL)
       AND (l_ship_to_loc IS NOT NULL)
       AND (l_ship_from_loc = l_ship_to_loc)
    THEN
      l_insert_flag := 'Y';
    ELSE
      l_insert_flag := 'N';
    END IF;

-- If the dispatch and destination territory codes are in different
-- economic zones then the transaction is of usage_type EXTERNAL.
-- Check if there is an entry in the MTL_STAT_TYPE_USAGES table for
-- usage_type of EXTERNAL, if there is then we go ahead and process
-- the transaction, otherwise get the next record from the c_shp loop.

  ELSIF l_movement_transaction.usage_type = 'EXTERNAL'
  THEN
    IF (l_ship_from_loc IS NULL)
       AND (l_ship_to_loc IS NULL)
    THEN
      l_insert_flag := 'N';
    ELSIF  (l_ship_from_loc IS NULL)
       OR  (l_ship_to_loc   IS NULL)
       AND (NVL(l_ship_from_loc,'NONE') <> NVL(l_ship_to_loc,'NONE'))
    THEN
      l_insert_flag := 'Y';
    ELSE
      l_insert_flag := 'N';
    END IF;
  ELSE
    l_insert_flag := 'N';
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

RETURN l_insert_flag;

END Process_Setup_Context;

--========================================================================
-- PROCEDURE : Get_Movement_Stat_Usages   PRIVATE
-- PARAMETERS:
--             x_return_status            OUT return status
--             x_msg_count                OUT number of messages in the list
--             x_msg_data                 OUT message text
--             p_legal_entity_id          IN  legal_entity
--             p_economic_zone_code       IN  economic zone
--             p_usage_type               IN  usage type
--             p_stat_type                IN  stat_type
--             x_movement_stat_usages_rec OUT Stat type Usages record
-- VERSION   : current version         1.0
--             initial version         1.0

--=======================================================================--
PROCEDURE Get_Movement_Stat_Usages
( x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_legal_entity_id         IN  NUMBER
, p_economic_zone_code      IN  VARCHAR2
, p_usage_type              IN  VARCHAR2
, p_stat_type               IN  VARCHAR2
, x_movement_stat_usages_rec OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
)
IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_procedure_name           CONSTANT VARCHAR2(30):= 'Get_Movement_Stat_Usages';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --  Initialize message stack if required
  --IF FND_API.to_Boolean(p_init_msg_list)
  --THEN
  --  FND_MSG_PUB.initialize;
  --END IF;

  x_movement_stat_usages_rec.legal_entity_id := p_legal_entity_id;
  x_movement_stat_usages_rec.zone_code       := p_economic_zone_code;
  x_movement_stat_usages_rec.usage_type      := p_usage_type;
  x_movement_stat_usages_rec.stat_type       := p_stat_type;

  SELECT  conversion_option
       ,  conversion_type
       ,  category_set_id
       ,  start_period_name
       ,  end_period_name
       ,  weight_uom_code
       ,  period_set_name
       ,  attribute_rule_set_code
       ,  alt_uom_rule_set_code
       ,  returns_processing
    INTO  x_movement_stat_usages_rec.conversion_option
       ,  x_movement_stat_usages_rec.conversion_type
       ,  x_movement_stat_usages_rec.category_set_id
       ,  x_movement_stat_usages_rec.start_period_name
       ,  x_movement_stat_usages_rec.end_period_name
       ,  x_movement_stat_usages_rec.weight_uom_code
       ,  x_movement_stat_usages_rec.period_set_name
       ,  x_movement_stat_usages_rec.attribute_rule_set_code
       ,  x_movement_stat_usages_rec.alt_uom_rule_set_code
       ,  x_movement_stat_usages_rec.returns_processing
    FROM  mtl_stat_type_usages
    WHERE legal_entity_id = p_legal_entity_id
      AND zone_code       = p_economic_zone_code
      AND usage_type      = p_usage_type
      AND stat_type       = p_stat_type;

  SELECT  ledger_id
       ,  currency_code
    INTO  x_movement_stat_usages_rec.gl_set_of_books_id
       ,  x_movement_stat_usages_rec.gl_currency_code
    FROM  gl_ledger_le_v
    WHERE legal_entity_id = p_legal_entity_id
      AND ledger_category_code = 'PRIMARY';

  -- report success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_Get
  ( p_count => x_msg_count
  , p_data  => x_msg_data
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Get_Movement_Stat_Usages'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

END Get_Movement_Stat_Usages;

END INV_MGD_MVT_SETUP_MDTR;


/
