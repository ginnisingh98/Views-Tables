--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_INV_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_INV_MDTR" AS
-- $Header: INVIMDRB.pls 120.3.12010000.2 2008/12/30 15:01:40 ybabulal ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVIMDRB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of INV_MGD_MVT_INV_MDTR                                      |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Get_INV_Transactions                                              |
--|     Get_INV_Details                                                   |
--|     Update_INV_Transactions                                           |
--|                                                                       |
--| HISTORY                                                               |
--|    07-Jan-2002 odaboval   Bug 2169239                                 |
--|                                                                       |
--|                                                                       |
--|                                                                       |
--+=======================================================================

--===================
-- CONSTANTS
--===================
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_INV_MDTR.';


--===================
-- PRIVATE PROCEDURES
--===================


--========================================================================
-- PROCEDURE : Get_INV_Transactions    PUBLIC
-- PARAMETERS: inv_crsr                REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for INV and returns the cursor.
--========================================================================

PROCEDURE Get_INV_Transactions
( inv_crsr               IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.invCurTyp
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_INV_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF inv_crsr%ISOPEN THEN
     CLOSE inv_crsr;
  END IF;


--Fix performance bug 4912552, use hr_organization_information to replace
--org_organization_definitions according to proposal from INV
--karthik.gnanamurthy, because inventory organization is already existing
--in mtl_material_transactions, so it's not required to validate the organization
--again in mtl_parameters or hr_all_organization_units as OOD does

IF NVL(p_movement_transaction.creation_method,'A') = 'A' THEN

  OPEN inv_crsr FOR
  SELECT
    inv.transaction_id
  , inv.transaction_type_id
  , inv.transaction_action_id
  , inv.transfer_organization_id
  , inv.transaction_date
  , inv.organization_id
  , inv.transaction_quantity
  , inv.subinventory_code
  , inv.transfer_subinventory
  FROM
    MTL_MATERIAL_TRANSACTIONS inv
  , hr_organization_information hoi
  WHERE inv.organization_id  = hoi.organization_id
  AND   hoi.org_information_context = 'Accounting Information'
  AND   hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
  AND   inv.transaction_type_id   IN (21,3,12,2)
  AND   inv.transaction_action_id IN (21,3,12,2)
  AND   NVL(inv.mvt_stat_status,'NEW')   = 'NEW'
  AND   inv.transaction_date BETWEEN p_start_date AND p_end_date;
ELSE

  OPEN inv_crsr FOR
  SELECT
    inv.transaction_id
  , inv.transaction_type_id
  , inv.transaction_action_id
  , inv.transfer_organization_id
  , inv.transaction_date
  , inv.organization_id
  , inv.transaction_quantity
  , inv.subinventory_code
  , inv.transfer_subinventory
  FROM
    MTL_MATERIAL_TRANSACTIONS inv
  , hr_organization_information hoi
  WHERE inv.organization_id  = hoi.organization_id
  AND   hoi.org_information_context = 'Accounting Information'
  AND   hoi.org_information2 = to_char(p_movement_transaction.entity_org_id) /* bug 7676431: Added to_char */
  AND   inv.transaction_id   = p_movement_transaction.mtl_transaction_id
  AND   inv.transaction_type_id   IN (21,3,12,2)
  AND   inv.transaction_action_id IN (21,3,12,2)
  AND   NVL(inv.mvt_stat_status,'NEW')   = 'NEW';

END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Get_INV_Transactions;


--========================================================================
-- PROCEDURE : Get_INV_Details         PUBLIC
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for INV
--========================================================================

PROCEDURE Get_INV_Details
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_INV_Details';

  CURSOR inv_details IS
  SELECT
    inv.freight_code
  , inv.transaction_type_id
  , inv.transaction_action_id
  , inv.transaction_id
  , inv.organization_id
  , inv.transfer_organization_id
  , inv.transaction_uom
 -- , inv.transaction_date    timezone support donot populate transaction date again
  , inv.primary_quantity
  , inv.inventory_item_id
  , si.description
  , nvl(cst.item_cost,0)+decode(sign(transaction_quantity),-1,0,
                                nvl(inv.transfer_cost,0))
  FROM
    MTL_MATERIAL_TRANSACTIONS inv
  , MTL_SYSTEM_ITEMS si
  , CST_ITEM_COSTS_FOR_GL_VIEW cst
  WHERE inv.organization_id    = si.organization_id
    AND inv.inventory_item_id  = si.inventory_item_id
    AND inv.organization_id    = cst.organization_id(+)
    AND inv.inventory_item_id  = cst.inventory_item_id(+)
    AND inv.transaction_id     = x_movement_transaction.mtl_transaction_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status        := 'Y';

  OPEN inv_details;
  FETCH inv_details INTO
    x_movement_transaction.delivery_terms
  , x_movement_transaction.transaction_type_id
  , x_movement_transaction.transaction_action_id
  , x_movement_transaction.mtl_transaction_id
  , x_movement_transaction.from_organization_id
  , x_movement_transaction.to_organization_id
  , x_movement_transaction.transaction_uom_code
 -- , x_movement_transaction.transaction_date
  , x_movement_transaction.primary_quantity
  , x_movement_transaction.inventory_item_id
  , x_movement_transaction.item_description
  , x_movement_transaction.item_cost;

  IF inv_details%NOTFOUND
  THEN
    CLOSE inv_details;
    x_return_status := 'N';
    RETURN;
  END IF;

  CLOSE inv_details;

  --fix bug 2888046, interorg transfer should always be in functional currency
  x_movement_transaction.currency_code            := x_movement_transaction.gl_currency_code;
  x_movement_transaction.currency_conversion_rate := 1;
  x_movement_transaction.currency_conversion_type := null;
  x_movement_transaction.currency_conversion_date := null;

  x_movement_transaction.document_unit_price      := x_movement_transaction.item_cost;
  x_movement_transaction.document_line_ext_value  := abs(x_movement_transaction.document_unit_price *
                                                     x_movement_transaction.transaction_quantity);
  x_movement_transaction.document_source_type     := 'INV';
  x_movement_transaction.transaction_nature       := '60';
  x_movement_transaction.origin_territory_code    := x_movement_transaction.dispatch_territory_code;

  IF ((x_movement_transaction.transaction_type_id = 12 AND
       x_movement_transaction.transaction_action_id = 12)
      OR
      (x_movement_transaction.transaction_type_id IN (2,3) AND
       x_movement_transaction.transaction_action_id IN (2,3) AND
       x_movement_transaction.transaction_quantity > 0))
  THEN
    x_movement_transaction.movement_type                 := 'A';
    x_movement_transaction.from_organization_id          :=
                                         x_movement_transaction.to_organization_id;
    x_movement_transaction.to_organization_id            :=
                                         x_movement_transaction.organization_id;
  ELSE
    x_movement_transaction.movement_type        := 'D';
    x_movement_transaction.transaction_quantity :=
                                          abs(x_movement_transaction.transaction_quantity);
    x_movement_transaction.primary_quantity     :=
                                          NVL(abs(x_movement_transaction.primary_quantity),null);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;
END Get_INV_Details;

--========================================================================
-- PROCEDURE : Update_INV_Transactions    PUBLIC
-- PARAMETERS: x_return_status            return status
--             p_movement_transaction     movement transaction record
-- COMMENT   : Update the status of the transaction record to PROCESSED
--========================================================================

PROCEDURE Update_INV_Transactions
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_procedure_name CONSTANT VARCHAR2(30) := 'Update_INV_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';
  -- Update the transaction table
  UPDATE MTL_MATERIAL_TRANSACTIONS
  SET mvt_stat_status   = 'PROCESSED'
  ,   movement_id       = p_movement_transaction.movement_id
  WHERE transaction_id  = p_movement_transaction.mtl_transaction_id;

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
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. No data found exception'
                    , 'Exception'
                    );
    END IF;
  WHEN OTHERS THEN
    x_return_status := 'N';
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'. Others exception'
                    , 'Exception'
                    );
    END IF;

END Update_INV_Transactions;

END INV_MGD_MVT_INV_MDTR;

/
