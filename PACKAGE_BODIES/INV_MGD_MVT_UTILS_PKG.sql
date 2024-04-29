--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_UTILS_PKG" AS
/* $Header: INVUINTB.pls 120.13.12010000.2 2009/06/03 11:03:13 ajmittal ship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVUINTB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Mvt_Stats_Util_Info                                               |
--|     Calc_Unit_Weight                                                  |
--|     Calc_Total_Weight                                                 |
--|     Convert_Territory_Code                                            |
--|     Get_Commodity_Info                                                |
--|     Get_Category_Id                                                   |
--|     Get_Site_Location                                                 |
--|     Get_Org_Location                                                  |
--|     Get_Vendor_Location                                               |
--|     Get_Zone_Code                                                     |
--|     Get_Subinv_Location                                               |
--|     Get_SO_Legal_Entity                                               |
--|     Get_Vendor_Info                                                   |
--|     Get_Cust_VAT_Number                                               |
--|     Get_Org_VAT_Number                                                |
--|     Get_Shipping_Legal_Entity                                         |
--|     Get_LE_Currency                                                   |
--|     Get_LE_Location                                                   |
--|     Get_Weight_Precision                                              |
--|     Round_Number                                                      |
--|     Get_Org_From_Le                                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     11/17/98 pseshadr        Created                                  |
--|     10/29/99 pjuvara, ssui   revised Update_Mtl_Movement_Statistics   |
--|                              to correct row who columns               |
--|     11/26/02 yawang          add function get_subinv_location         |
--|     12/16/02 yawang          add function get_so_legal_entity and     |
--|                              get_shipping_legal_entity                |
--|     12/02/04 vma             Fix bug 3869825                          |
--|     24/04/07 mkarra          Bug 5984760 Modified Calc_Unit_Weight
--|                              function to call INV UOM CONVERSION APIs |
--+========================================================================

--===================
-- GLOBALS
--===================

G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_UTILS_PKG.';
g_too_many_transactions_exc  EXCEPTION;
g_no_data_transaction_exc    EXCEPTION;
g_period_name_not_found_exc  EXCEPTION;
g_log_level                  NUMBER;
g_log_mode                   VARCHAR2(3);       -- possible values: OFF, SQL, SRS

--========================================================================
-- PROCEDURE : Mvt_Stats_Util_Info  PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
--             p_stat_typ_transaction  IN  Stat type Usages record
--             x_movement_transaction  IN OUT  Movement Statistics Record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Utility procedure that calculates invoice info,
--             weight info, this procedure inturns calls the
--             functions and procedures described above.
--=========================================================================

PROCEDURE Mvt_Stats_Util_Info
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_api_version_number   CONSTANT NUMBER       := 1.0;
l_api_name             CONSTANT VARCHAR2(30) := 'Mvt_Stats_Util_Info';
l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
l_uom_code             VARCHAR2(15);
l_procedure_name CONSTANT VARCHAR2(30) := 'Mvt_Stats_Util_Info';
l_weight_precision     NUMBER;
l_rounding_method      VARCHAR2(30);
l_total_weight         NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_movement_transaction := x_movement_transaction;
  l_stat_typ_transaction := p_stat_typ_transaction;

  IF x_movement_transaction.primary_quantity IS NULL
  THEN
    x_movement_transaction.primary_quantity := INV_CONVERT.INV_UM_CONVERT
    ( x_movement_transaction.inventory_item_id
    , 5
    , x_movement_transaction.transaction_quantity
    , x_movement_transaction.transaction_uom_code
    , x_movement_transaction.primary_uom_code
    , null
    , null
    );
  END IF;

  x_movement_transaction.category_id  := Get_Category_Id
  ( p_movement_transaction  => x_movement_transaction
  , p_stat_typ_transaction  => l_stat_typ_transaction
  );

  IF (x_movement_transaction.category_id IS NOT NULL)
  THEN
    Get_Commodity_Info(x_movement_transaction => x_movement_transaction);
  END IF;

  -- If there is an invoice then get all the info from the invoice
  x_movement_transaction.period_name :=
  INV_MGD_MVT_FIN_MDTR.Get_Period_Name
  ( p_movement_transaction => x_movement_transaction
  , p_stat_typ_transaction => l_stat_typ_transaction
  );

  -- Fix Bug 3869825: Movement Statistics Processor should fail
  -- if the period is not defined in GL
  IF (x_movement_transaction.period_name IS NULL)
  THEN
    RAISE g_period_name_not_found_exc;
  END IF;

  -- move this condition to INVFMDRB.pls so that all the places
  --where call calc_invoice_info will also filter out following conditions
  INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
  ( p_stat_typ_transaction => l_stat_typ_transaction
  , x_movement_transaction => x_movement_transaction
  );

  x_movement_transaction.movement_amount :=
  INV_MGD_MVT_FIN_MDTR.Calc_Movement_Amount
  (p_movement_transaction => x_movement_transaction);

  --Calculate freight charge and include in statistics value
  x_movement_transaction.stat_ext_value :=
  INV_MGD_MVT_FIN_MDTR.Calc_Statistics_Value
  (p_movement_transaction => x_movement_transaction);

  /* Bug: 5291257. Call to function INV_MGD_MVT_FIN_MDTR.Get_Set_Of_Books_Period
  is modified becasue p_period_type is no more required. */
  x_movement_transaction.set_of_books_period :=
  INV_MGD_MVT_FIN_MDTR.Get_Set_Of_Books_Period
  ( p_legal_entity_id => x_movement_transaction.entity_org_id
  , p_period_date     => NVL(x_movement_transaction.invoice_date_reference,
                            x_movement_transaction.transaction_date)
  --, p_period_type     => NVL(l_stat_typ_transaction.period_type,'Month')
  );

  IF (x_movement_transaction.transaction_quantity IS NOT NULL)
     AND (x_movement_transaction.transaction_uom_code IS NOT NULL)
  THEN
    x_movement_transaction.unit_weight := Calc_Unit_Weight
    ( p_inventory_item_id => x_movement_transaction.inventory_item_id
    , p_organization_id   => x_movement_transaction.organization_id
    , p_stat_typ_uom_code => l_stat_typ_transaction.weight_uom_code
    , p_tranx_uom_code    => x_movement_transaction.transaction_uom_code
    );

    --Fix bug 4866967 and 5203245 get weight precision and rounding method
    Get_Weight_Precision
    (p_legal_entity_id      => x_movement_transaction.entity_org_id
    , p_zone_code           => x_movement_transaction.zone_code
    , p_usage_type          => x_movement_transaction.usage_type
    , p_stat_type           => x_movement_transaction.stat_type
    , x_weight_precision    => l_weight_precision
    , x_rep_rounding        => l_rounding_method);

    IF x_movement_transaction.unit_weight IS NOT NULL
    THEN
      l_total_weight := x_movement_transaction.unit_weight *
                        x_movement_transaction.transaction_quantity;

      x_movement_transaction.total_weight := Round_Number
      ( p_number          => l_total_weight
      , p_precision       => l_weight_precision
      , p_rounding_method => l_rounding_method
      );
    ELSE
      x_movement_transaction.total_weight := NULL;
    END IF;

    -- If there is an alternate uom we need to convert quantity to this
    -- alternate uom
    IF (l_stat_typ_transaction.alt_uom_rule_set_code IS NOT NULL)
    THEN
      x_movement_transaction.alternate_uom_code := Get_Alternate_UOM
      ( p_category_set_id       => l_stat_typ_transaction.category_set_id
      , p_alt_uom_rule_set_code => l_stat_typ_transaction.alt_uom_rule_set_code
      , p_commodity_code        => x_movement_transaction.commodity_code
      );

      IF (x_movement_transaction.alternate_uom_code IS NOT NULL)
      THEN
        x_movement_transaction.alternate_quantity := Convert_alternate_Quantity
        ( p_transaction_quantity  => x_movement_transaction.transaction_quantity
        , p_alternate_uom_code    => x_movement_transaction.alternate_uom_code
        , p_transaction_uom_code  => x_movement_transaction.transaction_uom_code
        , p_inventory_item_id     => x_movement_transaction.inventory_item_id
        );
      ELSE
        x_movement_transaction.alternate_quantity := NULL;
      END IF;
    ELSE
      x_movement_transaction.alternate_quantity := NULL;
      x_movement_transaction.alternate_uom_code := NULL;
    END IF;
  ELSE
    x_movement_transaction.total_weight := null;
    x_movement_transaction.unit_weight := null;
  END IF;

  IF (x_movement_transaction.origin_territory_code IS NOT NULL)
  THEN
    x_movement_transaction.origin_territory_eu_code :=
    Convert_Territory_Code (x_movement_transaction.origin_territory_code);
  END IF;

  IF (x_movement_transaction.dispatch_territory_code IS NOT NULL)
  THEN
    x_movement_transaction.dispatch_territory_eu_code :=
    Convert_Territory_Code (x_movement_transaction.dispatch_territory_code);
  END IF;

  IF (x_movement_transaction.destination_territory_code IS NOT NULL)
  THEN
    x_movement_transaction.destination_territory_eu_code :=
    Convert_Territory_Code (x_movement_transaction.destination_territory_code);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN g_period_name_not_found_exc THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    ,'Mvt_Stats_Util_Info: GL Period is not defined. '
                      || 'Please define the GL Period for the transaction date '
                      || x_movement_transaction.transaction_date
                      || ' in the Period Set '
                      || l_stat_typ_transaction.period_set_name
                      || ' and the Period Type '
                      || l_stat_typ_transaction.period_type
                      || '.'
                    );
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ('INV_MGD_MVT_UTILS_PKG'
      , 'Mvt_Stats_Util_Info: GL Period is not defined. '
      || 'Please define the GL Period for the transaction date '
      || x_movement_transaction.transaction_date
      || ' in the Period Set '
      || l_stat_typ_transaction.period_set_name
      || ' and the Period Type '
      || l_stat_typ_transaction.period_type
      || '.'
      );
    END IF;

    x_movement_transaction := l_movement_transaction;

  WHEN NO_DATA_FOUND THEN
      x_movement_transaction := l_movement_transaction;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.No data found exception'
                      , 'Exception'
                      );
      END IF;

  WHEN TOO_MANY_ROWS THEN
      x_movement_transaction := l_movement_transaction;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_procedure_name||'.too many rows exception'
                      , 'Exception'
                      );
      END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_movement_transaction := l_movement_transaction;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'.unexpected exception'
                    , 'Exception'
                    );
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_movement_transaction := l_movement_transaction;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'.Others exception'
                    ,'Exception'
                    );
    END IF;

    /*IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'INV_MGD_MVT_UTILS_PKG'
      );
    END IF;*/

END Mvt_Stats_Util_Info;


--========================================================================
-- FUNCTION  : Get_Conversion_Rate Private
-- PARAMETERS:
--             p_item_id     Inventory Item
--             p_uom_code    UOM code
-- COMMENT   : Returns the conversion rate between the passing in UOM and
--             the base UOM of the same class
--=======================================================================
FUNCTION Get_Conversion_Rate
( p_item_id   NUMBER
, p_uom_code VARCHAR2
)
RETURN NUMBER
IS
l_rate NUMBER;
BEGIN
  --Get rate for this specific item if there is defined
  BEGIN
    SELECT
      conversion_rate
    INTO
      l_rate
    FROM
      mtl_uom_conversions
    WHERE uom_code = p_uom_code
      AND inventory_item_id = p_item_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_rate := NULL;
  END;

  --If there is no special conversion for this item, get standard rate
  IF l_rate IS NULL
  THEN
    SELECT
      conversion_rate
    INTO
      l_rate
    FROM
      mtl_uom_conversions
    WHERE uom_code = p_uom_code
      AND inventory_item_id = 0;
  END IF;

  RETURN (l_rate);

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || 'Get_Conversion_Rate'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    l_rate := NULL;
    RETURN (l_rate);
END Get_Conversion_Rate;


--========================================================================
-- FUNCTION  : Get_Rate_Two_Uom Private
-- PARAMETERS:
--             p_item_id     Inventory Item
--             p_uom1        UOM1
--             p_uom2        UOM2
-- COMMENT   : Returns the conversion rate between the two passing in uoms
--=======================================================================

/* Bug 5984760 -  This function will no longer be used and will be obsoleted*/
FUNCTION Get_Rate_Two_Uom
( p_item_id    NUMBER
, p_uom1       VARCHAR2
, p_uom2       VARCHAR2
)
RETURN NUMBER
IS
l_rate1           NUMBER;
l_rate2           NUMBER;
l_conversion_rate NUMBER;
BEGIN
  --Get conversion rate between uom1 and it's base uom
  l_rate1 := Get_Conversion_Rate
             ( p_item_id  => p_item_id
             , p_uom_code => p_uom1
             );
  --Get conversion rate between uom2 and it's base uom
  l_rate2 := Get_Conversion_Rate
            ( p_item_id  => p_item_id
            , p_uom_code => p_uom2
             );

  --Calculate 1 of uom1 equals to how much of uom2
  IF (l_rate1 IS NOT NULL
      AND l_rate2 IS NOT NULL
      AND l_rate2 <> 0)
  THEN
    l_conversion_rate := l_rate1/l_rate2;
  ELSE
    l_conversion_rate := null;
  END IF;

  RETURN (l_conversion_rate);

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || 'Get_Rate_Two_Uom'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    l_conversion_rate := NULL;
    RETURN (l_conversion_rate);
END Get_Rate_Two_Uom;

--========================================================================
-- FUNCTION : Calc_Unit_Weight PUBLIC
-- PARAMETERS:
--             p_inventory_item_id     Inventory Item
--             p_organization_id       Organization_id
--             p_stat_typ_uom_code     UOM defined by stat_type_usages
--             p_tranx_uom_code        Transaction UOM
-- COMMENT   : Returns the unit weight of an item
--=======================================================================
FUNCTION Calc_Unit_Weight
( p_inventory_item_id	NUMBER
, p_organization_id     NUMBER
, p_stat_typ_uom_code   VARCHAR2
, p_tranx_uom_code      VARCHAR2
)
RETURN NUMBER
IS
l_unit_weight NUMBER;
l_item_unit_weight NUMBER;
l_weight_uom_code VARCHAR2(3);
l_primary_uom_code VARCHAR2(3);
l_conversion_rate NUMBER;
l_uom_class       VARCHAR2(10);

l_tranx_uom_class    VARCHAR2(10);
l_stat_typ_uom_class VARCHAR2(10);
l_rate1              NUMBER;
l_rate2              NUMBER;
l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_Unit_Weight';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  IF (p_inventory_item_id IS NOT NULL
     AND p_tranx_uom_code IS NOT NULL)
  THEN
    --yawang fix bug 2326128, re-design the way we calculate the unit weight
    --Find the class of transaction uom
    SELECT uom_class
      INTO l_tranx_uom_class
      FROM mtl_units_of_measure_vl
     WHERE uom_code = p_tranx_uom_code;

    --Find the class of movement uom defined on movement statistics parameter form
    SELECT uom_class
      INTO l_stat_typ_uom_class
      FROM mtl_units_of_measure_vl
     WHERE uom_code = p_stat_typ_uom_code;

    --Scenario 1, the transaction uom is of weight class
    --we will do intra-class conversion if the transaction uom is different
    --from movement weight uom
    IF l_tranx_uom_class = l_stat_typ_uom_class
    THEN
      IF p_tranx_uom_code = p_stat_typ_uom_code
      THEN
        l_unit_weight := 1;
      ELSE

	/* Bug 5984760 - Start */
         /* INV_CONVERT standard conversion APIs are called to get the conversion
         rates. Get_Rate_Two_UOM will no longer be uses */


        --Get conversion rate between transaction uom and movement uom
        /*l_conversion_rate := Get_Rate_Two_Uom
                             ( p_item_id => p_inventory_item_id
                             , p_uom1    => p_tranx_uom_code
                             , p_uom2    => p_stat_typ_uom_code
                             );  */

	     INV_CONVERT.inv_um_conversion(
                from_unit => p_tranx_uom_code
                , to_unit => p_stat_typ_uom_code
                , item_id => p_inventory_item_id
                , uom_rate => l_conversion_rate);


        --Calculate unit weight for 1 of transaction uom
        --Unit weight should not be static as defined on the item master
        --It should be calculated against transaction uom
        --ex: unit weight for each TON or for each KG or for each Lbs
        l_unit_weight := 1 * l_conversion_rate;
      END IF;
    ELSE
      --Scenario 2, the transaction uom is not of weight class
      -- retrieve item unit weight from master item
      SELECT
        unit_weight
      , weight_uom_code
      , primary_uom_code
      INTO
        l_item_unit_weight
      , l_weight_uom_code
      , l_primary_uom_code
      FROM
        MTL_SYSTEM_ITEMS muc
      WHERE muc.inventory_item_id   = p_inventory_item_id
        AND   muc.organization_id     = p_organization_id;

      IF (l_primary_uom_code IS NOT NULL
          AND l_weight_uom_code IS NOT NULL)
      THEN
        --Get conversion rate between transaction uom and primary uom
     /*   l_rate1 := Get_Rate_Two_Uom
                   ( p_item_id => p_inventory_item_id
                   , p_uom1    => p_tranx_uom_code
                   , p_uom2    => l_primary_uom_code
                   );  */

	   INV_CONVERT.inv_um_conversion(
             from_unit => p_tranx_uom_code
             , to_unit => l_primary_uom_code
             , item_id => p_inventory_item_id
             , uom_rate => l_rate1);


        --Get conversion rate between item master unit weight uom
        --and movement uom
       /* l_rate2 := Get_Rate_Two_Uom
                   ( p_item_id => p_inventory_item_id
                   , p_uom1    => l_weight_uom_code
                   , p_uom2    => p_stat_typ_uom_code
                   );  */

	INV_CONVERT.inv_um_conversion(
           from_unit => l_weight_uom_code
           , to_unit => p_stat_typ_uom_code
           , item_id => p_inventory_item_id
           , uom_rate => l_rate2);

        /* Bug 5984760 - End */


        --Calculate unit weight for 1 of transaction uom
        --Unit weight should not be static as defined on the item master
        --It should be calculated against transaction uom
        --ex: unit weight for each Dozen or for each Box
        l_unit_weight := l_item_unit_weight * l_rate1 * l_rate2;
      END IF;
    END IF;
  ELSE
    l_unit_weight := null;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  RETURN round(l_unit_weight,10);   -- Fix bug 4197941

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'.Others exception'
                    , 'Exception'
                    );
    END IF;

    l_unit_weight := null;
    RETURN (l_unit_weight);

END Calc_Unit_Weight;

/*
--========================================================================
-- FUNCTION : Calc_Total_Weight PUBLIC
-- PARAMETERS:
--             p_inventory_item_id     Inventory Item
--             p_organization_id       Organization_id
--             p_weight_uom_code       UOM
--             p_weight_precision      rounding decimal digits
--             p_transaction_quantity  Quantity
--             p_transaction_uom_code  Transaction UOM
-- COMMENT   : Total weight in the UOM that is defined in
--             the set-up form in mtl stat type usages.
--             The weight is defined in the UOm that is defined
--             by the authorities for reporting.
--=======================================================================

FUNCTION Calc_Total_Weight
( p_inventory_item_id	 NUMBER
, p_organization_id	 NUMBER
, p_weight_uom_code	 VARCHAR2
, p_weight_precision     NUMBER
, p_transaction_quantity NUMBER
, p_transaction_uom_code VARCHAR2
, p_unit_weight  	 NUMBER
)
RETURN NUMBER
IS

l_conversion_rate NUMBER;
l_weight          NUMBER;
l_unit_weight          NUMBER;

BEGIN

l_unit_weight := p_unit_weight;

IF l_unit_weight IS NOT NULL AND
   p_transaction_quantity IS NOT NULL
THEN

  l_weight := l_unit_weight * p_transaction_quantity;
  l_weight := round(l_weight,NVL(p_weight_precision,0));            --Fix bug 4866967
ELSE
  l_weight := NULL;

END IF;

-- Weight rounded up for all the EEC countries
-- except Portugal who need 3 decimals
--if P_FORMAT_TYPE = 'PT'
-- then l_weight := round(l_weight,3);
--else l_weight := ceil(l_weight);
--END IF;


RETURN(l_weight);

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Calc_Total_Weight'||'.Others exception'
                    , 'Exception'
                    );
    END IF;

    l_conversion_rate := null;
    l_weight := null;
    RETURN l_weight;

END Calc_Total_Weight;
*/

--========================================================================
-- FUNCTION : Convert_alternate_Quantity PUBLIC
-- PARAMETERS:
--             p_inventory_item_id     Inventory Item
--             p_organization_id       Organization_id
--             p_stat_typ_uom_code      UOM defined by stat_type_usages
-- COMMENT   : Returns the unit weight of an item
--=======================================================================
FUNCTION Convert_alternate_Quantity
( p_transaction_quantity   NUMBER
, p_alternate_uom_code     VARCHAR2
, p_inventory_item_id	   NUMBER
, p_transaction_uom_code   VARCHAR2
)
RETURN NUMBER
IS
l_conv_rate NUMBER;
l_alternate_quantity NUMBER;
l_procedure_name CONSTANT VARCHAR2(30) := 'Convert_alternate_Quantity';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

   INV_CONVERT.inv_um_conversion(
             from_unit => p_transaction_uom_code
             , to_unit => p_alternate_uom_code
             , item_id => p_inventory_item_id
             , uom_rate => l_conv_rate);

    -- Calculate alternate quantity
      l_alternate_quantity :=
           p_transaction_quantity * round(l_conv_rate,3);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  RETURN l_alternate_quantity;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||l_procedure_name||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    l_alternate_quantity := null;
    RETURN (l_alternate_quantity);

  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||l_procedure_name||'.Others exception'
                    , 'Exception'
                    );
    END IF;

    l_alternate_quantity := null;
    RETURN (l_alternate_quantity);

END Convert_alternate_Quantity;

--========================================================================
-- FUNCTION : Get_Alternate_UOM PUBLIC
-- PARAMETERS:
-- category set_id	Category set in stat type usages
-- alt_uom_rule_set_code alternate rule set code
-- commodity code        Transaction commodity code
-- COMMENT   : Returns the alternate UOM
--=======================================================================
FUNCTION Get_Alternate_UOM
( p_category_set_id    	   NUMBER
, p_alt_uom_rule_set_code  VARCHAR2
, p_commodity_code         VARCHAR2
)
RETURN VARCHAR2
IS
 l_alt_uom_code   VARCHAR2(50);
 l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Alternate_UOM';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  SELECT attribute_code INTO l_alt_uom_code
  FROM   MTL_MVT_STATS_RULES R
       , MTL_MVT_STATS_RULE_SETS_B RS
  WHERE  R.rule_set_code    = RS.rule_set_code
  AND    R.COMMODITY_CODE   = p_commodity_code
  AND    RS.category_set_id = p_category_set_id
  AND    RS.rule_set_type    = 'ALTERNATE_UOM'
  AND    R.rule_set_code    = p_alt_uom_rule_set_code;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  RETURN l_alt_uom_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||l_procedure_name||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    l_alt_uom_code := null;
    RETURN (l_alt_uom_code);

  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||l_procedure_name||'.Others exception'
                    , 'Exception'
                    );
    END IF;

    l_alt_uom_code := null;
    RETURN (l_alt_uom_code);

END Get_Alternate_UOM;


--========================================================================
-- FUNCTION : Convert_Territory_Code PUBLIC
-- PARAMETERS:
--             l_iso_code              varchar2
-- COMMENT   : Calculates and returns the ISO code given the territory code
--=======================================================================

FUNCTION Convert_Territory_Code (l_iso_code VARCHAR2)
RETURN VARCHAR2
IS
l_code VARCHAR2(3);

CURSOR l_eu IS
  SELECT
    fnd.eu_code
  FROM
    FND_TERRITORIES fnd
  WHERE
  territory_code = l_iso_code;

BEGIN

  OPEN l_eu;
  FETCH l_eu INTO
      l_code;

  IF l_eu%NOTFOUND THEN
    CLOSE l_eu;
      l_code := null;
        RETURN(l_code);
  END IF;

  CLOSE l_eu;
  RETURN(l_code);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Convert_Territory_Code'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    l_code := null;
    RETURN(l_code);

  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Convert_Territory_Code'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    l_code := null;
    RETURN(l_code);

END Convert_Territory_Code;


--========================================================================
-- FUNCTION : Get_Category_Id  PUBLIC
-- PARAMETERS: p_movement_transaction  IN  Movement Statistics Record
--             p_stat_typ_transaction  IN  Stat type Usages record
-- COMMENT   : Function that returns the category id for an item
--=========================================================================

FUNCTION Get_Category_Id
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
)
RETURN NUMBER
IS
  l_category_id       NUMBER;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Category_Id';

CURSOR c_ccode
IS
SELECT
  sic.category_id
FROM
    MTL_SYSTEM_ITEMS si
  , MTL_ITEM_CATEGORIES sic
WHERE si.inventory_item_id    = sic.inventory_item_id
  AND si.organization_id      = sic.organization_id
  AND si.inventory_item_id    = p_movement_Transaction.inventory_item_id
  AND si.organization_id      = p_movement_Transaction.organization_id
  AND sic.category_set_id     = p_stat_typ_transaction.category_set_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  OPEN c_ccode;
  FETCH c_ccode
  INTO
    l_category_id;

  IF c_ccode%NOTFOUND THEN
    CLOSE c_ccode;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE c_ccode;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  RETURN(l_category_id);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    l_category_id := null;
    RETURN(l_category_id);

  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    l_category_id := null;
    RETURN(l_category_id);

  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    l_category_id := null;
    RETURN(l_category_id);
END Get_Category_Id;



--========================================================================
-- PROCEDURE : Get_Commodity_Info  PUBLIC
-- PARAMETERS: x_movement_transaction  IN OUT Movement Statistics Record
--             x_movement_transaction  OUT Movement Statistics Record
-- COMMENT   : Procedure to populate the commoddity information for the item
--=========================================================================

PROCEDURE Get_Commodity_Info
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Commodity_Info';

CURSOR l_com
IS
SELECT
  substrb(mkv.concatenated_segments,1,230)
, substrb(mic.description,1,230)
FROM
  MTL_CATEGORIES mic
, MTL_CATEGORIES_KFV mkv
WHERE  mic.category_id  = mkv.category_id
AND    mic.category_id  = x_movement_transaction.category_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_movement_transaction := x_movement_transaction;

  OPEN  l_com;
  FETCH l_com
  INTO
    x_movement_transaction.commodity_code
  , x_movement_transaction.commodity_description;
  CLOSE l_com;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||l_procedure_name||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    x_movement_transaction := l_movement_transaction;

  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||l_procedure_name||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    x_movement_transaction := l_movement_transaction;

END Get_Commodity_Info;

--========================================================================
-- PROCEDURE : Get_Order_Number  PUBLIC
-- PARAMETERS: x_movement_transaction  IN OUT  Movement Statistics Record
--
-- COMMENT   : Procedure to populate the Order Number
--=========================================================================

PROCEDURE Get_Order_Number
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Order_Number';

CURSOR l_on
IS
SELECT
  oh.order_number
, oh.org_id
FROM
  OE_ORDER_HEADERS_ALL oh
WHERE   oh.header_id  = x_movement_transaction.order_header_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_movement_transaction := x_movement_transaction;

  OPEN  l_on;
  FETCH l_on
  INTO
    x_movement_transaction.order_number
  , x_movement_transaction.org_id;
  CLOSE l_on;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||l_procedure_name||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    x_movement_transaction := l_movement_transaction;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||l_procedure_name||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    x_movement_transaction := l_movement_transaction;

END Get_Order_Number;

--========================================================================
-- FUNCTION : Get_Site_Location
-- PARAMETERS: p_site_use_id           Site id
-- COMMENT   : Function that returns the territory code where the site
--             is located.
--=========================================================================

FUNCTION Get_Site_Location
( p_site_use_id  IN NUMBER
)
RETURN VARCHAR2
IS
l_site_location  VARCHAR2(80);
l_short_name     VARCHAR2(80);

CURSOR l_ra_site
IS
  SELECT
    hzl.country
  FROM
    HZ_CUST_ACCT_SITES_ALL ras
  , HZ_CUST_SITE_USES_ALL raa
  , HZ_LOCATIONS hzl
  , HZ_PARTY_SITES hzp
  WHERE ras.cust_acct_site_id  = raa.cust_acct_site_id
  AND   NVL(ras.org_id, -1)    = NVL(raa.org_id, -1)     --fix bug 4015171
  AND   ras.party_site_id      = hzp.party_site_id
  AND   hzl.location_id        = hzp.location_id
  AND   raa.site_use_id        = p_site_use_id;


CURSOR l_fnd_cy
IS
  SELECT
    DISTINCT territory_code
  FROM
    FND_TERRITORIES_TL        --fix bug 4165090
  WHERE
    territory_short_name = l_short_name;

BEGIN
  OPEN l_ra_site;
    FETCH l_ra_site INTO
      l_site_location;
  CLOSE l_ra_site;

  IF length(l_site_location) > 3 THEN
     l_short_name := l_site_location;
     OPEN l_fnd_cy;
       FETCH l_fnd_cy INTO
         l_site_location;
     CLOSE l_fnd_cy;

  END IF;

  RETURN l_site_location;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Site_Location'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Site_Location'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Site_Location'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Site_Location;


--========================================================================
-- FUNCTION : Get_Org_Location
-- PARAMETERS: p_warehouse_id          warehouse id
-- COMMENT   : Function that returns the territory code where the warehouse
--             is located.
--=========================================================================

FUNCTION Get_Org_Location
( p_warehouse_id  IN NUMBER
)
RETURN VARCHAR2
IS
l_org_location    VARCHAR2(80);
l_short_name      VARCHAR2(80);

CURSOR l_org
IS
  SELECT
    hrl.country
  FROM
    HR_ALL_ORGANIZATION_UNITS hr
  , HR_LOCATIONS_ALL hrl
  WHERE hr.location_id     = hrl.location_id
  AND   hr.organization_id = p_warehouse_id;

CURSOR l_fnd_cy
IS
  SELECT
    DISTINCT territory_code
  FROM
    FND_TERRITORIES_TL                      --fix bug 4165090
  WHERE
    territory_short_name = l_short_name;

BEGIN

  OPEN l_org;
    FETCH l_org INTO
      l_org_location;
  CLOSE l_org;

  IF length(l_org_location) > 3 THEN
     l_short_name := l_org_location;
     OPEN l_fnd_cy;
       FETCH l_fnd_cy INTO
         l_org_location;
     CLOSE l_fnd_cy;
  END IF;

  RETURN l_org_location;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Org_Location'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Org_Location'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Org_Location'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Org_Location;

--========================================================================
-- FUNCTION : Get_Subinv_Location
-- PARAMETERS: p_warehouse_id        warehouse id
--             p_subinv_code         the subinventory code
-- COMMENT   : Function that returns the territory code where the subinventory
--             is located.
--=========================================================================

FUNCTION Get_Subinv_Location
( p_warehouse_id  IN NUMBER
, p_subinv_code   IN VARCHAR2
)
RETURN VARCHAR2
IS
l_subinv_location    VARCHAR2(80);
l_short_name      VARCHAR2(80);

CURSOR l_country
IS
  SELECT
    hrl.country
  FROM
    mtl_secondary_inventories msi
  , HR_LOCATIONS_ALL hrl
  WHERE hrl.location_id     = msi.location_id
  AND   msi.organization_id = p_warehouse_id
  AND   msi.secondary_inventory_name = p_subinv_code;

CURSOR l_fnd_cy
IS
  SELECT
    DISTINCT territory_code
  FROM
    FND_TERRITORIES_TL                           --fix bug 4165090
  WHERE
    territory_short_name = l_short_name;
BEGIN
  OPEN l_country;
  FETCH l_country INTO
    l_subinv_location;

  IF l_country%NOTFOUND
  THEN
    RETURN null;
    CLOSE l_country;
  ELSE
    IF length(l_subinv_location) > 3
    THEN
      l_short_name := l_subinv_location;

      OPEN l_fnd_cy;
      FETCH l_fnd_cy INTO
        l_subinv_location;
      CLOSE l_fnd_cy;
    END IF;

    CLOSE l_country;
  END IF;

  RETURN l_subinv_location;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_subinv_Location'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_subinv_Location'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_subinv_Location'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_subinv_Location;

--========================================================================
-- FUNCTION : Get_Vendor_Location
-- PARAMETERS: p_vendor_site_id        Vendor Site
-- COMMENT   : Function that returns the territory code where the vendor site
--             is located.
--=========================================================================

FUNCTION Get_vendor_Location
( p_vendor_site_id  IN NUMBER
)
RETURN VARCHAR2
IS
l_vendor_location  VARCHAR2(150);

CURSOR l_vendor
IS
  SELECT
    pov.country
  FROM
    PO_VENDOR_SITES_ALL pov
  WHERE pov.vendor_site_id  = p_vendor_site_id;

BEGIN

  OPEN l_vendor;
    FETCH l_vendor INTO
      l_vendor_location;
  CLOSE l_vendor;

  RETURN l_vendor_location;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Vendor_Location'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Vendor_Location'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Vendor_Location'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Vendor_Location;


--========================================================================
-- FUNCTION : Get_Zone_Code
-- PARAMETERS: p_territory_code        territory code
--             p_zone_code             zone code
--             p_trans_date            transaction date
-- COMMENT   : Function that returns the zone code if the zone code
--             and territory code matches and entry in country assignments
--=========================================================================


FUNCTION Get_Zone_Code
( p_territory_code IN VARCHAR2
, p_zone_code      IN VARCHAR2
, p_trans_date     IN VARCHAR2
)
RETURN VARCHAR2
IS
l_zone_code   VARCHAR2(10);
-- cursor to get the zone so that we can determine if the
-- transaction is an Intrastat or an extrastat

CURSOR c_zone IS
  SELECT
    zone_code
  FROM
    MTL_COUNTRY_ASSIGNMENTS
  WHERE territory_code = p_territory_code
  AND   zone_code      = p_zone_code
  AND   p_trans_date  BETWEEN (start_date) and (NVL(end_date,p_trans_date));

BEGIN

OPEN c_zone;
  FETCH c_zone
  INTO l_zone_code;

  IF c_zone%NOTFOUND THEN
    l_zone_code:= null;
  END IF;

CLOSE c_zone;

RETURN l_zone_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Zone_Code'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Zone_Code'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Zone_Code'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Zone_Code;


--========================================================================
-- PROCEDURE : Get_Vendor_Info  PUBLIC
-- PARAMETERS: x_movement_transaction  IN OUT Movement Statistics Record
--
-- COMMENT   : Procedure to populate the  vendor info
--=========================================================================

PROCEDURE Get_Vendor_Info
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;

CURSOR l_ven
IS
SELECT
  pov.vendor_name
, pov.segment1
, povs.vendor_site_code
, povs.province
, povs.vat_registration_num
FROM
  PO_VENDORS pov
, PO_VENDOR_SITES_ALL povs
WHERE  pov.vendor_id       = povs.vendor_id
AND    pov.vendor_id       = x_movement_transaction.vendor_id
AND    povs.vendor_site_id = x_movement_transaction.vendor_site_id;

BEGIN

  l_movement_transaction := x_movement_transaction;

  OPEN  l_ven;
  FETCH l_ven
  INTO
    x_movement_transaction.vendor_name
  , x_movement_transaction.vendor_number
  , x_movement_transaction.vendor_site
  , x_movement_transaction.area
  , x_movement_transaction.customer_vat_number;
  CLOSE l_ven;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Vendor_Info'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    x_movement_transaction := l_movement_transaction;

  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Vendor_Info'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    x_movement_transaction := l_movement_transaction;
END Get_Vendor_Info;

--========================================================================
-- FUNCTION : Get_Cust_VAT_Number
-- PARAMETERS: p_site_use_id           Site id
-- COMMENT   : Function that returns the  vat number for SO
--=========================================================================

FUNCTION Get_Cust_VAT_Number
( p_site_use_id  IN NUMBER
)
RETURN VARCHAR2
IS
l_vat_number     VARCHAR2(50);

CURSOR l_ra_vat
IS
  SELECT
    raa.tax_reference
  FROM
    HZ_CUST_SITE_USES_ALL raa
  WHERE   raa.site_use_id        = p_site_use_id;


BEGIN
  OPEN l_ra_vat;
    FETCH l_ra_vat INTO
      l_vat_number;
  CLOSE l_ra_vat;


  RETURN l_vat_number;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Cust_VAT_Number'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Cust_VAT_Number'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Cust_VAT_Number'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Cust_VAT_Number;

--========================================================================
-- FUNCTION : Get_Org_VAT_Number
-- PARAMETERS: p_entity_org_id           legal entity id
-- COMMENT   : Function that returns the vat number for legal entity used
--             in inter-org transfer
--=========================================================================

FUNCTION Get_Org_VAT_Number
( p_entity_org_id  IN NUMBER
, p_date           IN DATE
)
RETURN VARCHAR2
IS
l_vat_number     VARCHAR2(1000);
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(300);
l_effective_date DATE;

BEGIN
  --Call XLE package for VAT number:
  XLE_UTILITIES_GRP.Get_FP_VATRegistration_LEID
  ( p_api_version          => 1.0
  , p_init_msg_list        => FND_API.G_FALSE
  , p_commit		   => FND_API.G_FALSE
  , p_effective_date       => p_date
  , x_return_status        => l_return_status
  , x_msg_count            => l_msg_count
  , x_msg_data             => l_msg_data
  , p_legal_entity_id      => p_entity_org_id
  , x_registration_number  => l_vat_number
  );

  RETURN SUBSTR(l_vat_number,1,50);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Org_VAT_Number'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Org_VAT_Number'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Org_VAT_Number'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Org_VAT_Number;

--========================================================================
-- FUNCTION : Get_SO_Legal_Entity      PUBLIC
-- PARAMETERS: p_order_line_id         order line id
--
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Function that returns the legal entity where this sales order
--             is created.
--=======================================================================--

FUNCTION Get_SO_Legal_Entity
( p_order_line_id  IN NUMBER
)
RETURN NUMBER
IS
l_sold_to_org_id NUMBER;
l_so_ou_id       NUMBER;
l_so_le_id       NUMBER;

--Fix bug 5437773, replace sold_from_org_id with org_id
--org_id is the correct column to get operating unit
CURSOR l_so_ou IS
SELECT
  sold_to_org_id
, org_id
FROM
  oe_order_lines_all
WHERE line_id = p_order_line_id;


BEGIN
  OPEN l_so_ou;
  FETCH l_so_ou INTO
    l_sold_to_org_id
  , l_so_ou_id;

  IF l_so_ou%NOTFOUND
  THEN
    l_so_le_id:= null;
  ELSE
 /* bug 8467743 XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info was always returning default legal entity*/
    /* l_so_le_id := XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info
                  ( p_customer_type     => 'SOLD_TO'
                  , p_customer_id       => l_sold_to_org_id
                  , p_operating_unit_id => l_so_ou_id);*/
   SELECT To_Number(NVL(O3.ORG_INFORMATION2,-1))
      INTO l_so_le_id
      FROM HR_ALL_ORGANIZATION_UNITS O
         , HR_ORGANIZATION_INFORMATION O2
         , HR_ORGANIZATION_INFORMATION O3
      WHERE O.ORGANIZATION_ID = O2.ORGANIZATION_ID
      AND   O.ORGANIZATION_ID = O3.ORGANIZATION_ID
      AND   O2.ORG_INFORMATION_CONTEXT||'' = 'CLASS'
      AND   O3.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
      AND   O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
      AND   O2.ORG_INFORMATION2 = 'Y'
      AND   O.ORGANIZATION_ID = l_so_ou_id;

  END IF;

  CLOSE l_so_ou;

  RETURN l_so_le_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_SO_Legal_Entity'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_SO_Legal_Entity'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_SO_Legal_Entity'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_SO_Legal_Entity;

--========================================================================
-- FUNCTION  : Get_Shipping_Legal_Entity  PUBLIC
-- PARAMETERS: p_warehouse_id             warehouse id
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns the legal entity where this sales order
--             is ship released.
--=======================================================================--

FUNCTION Get_Shipping_Legal_Entity
( p_warehouse_id  IN NUMBER
)
RETURN NUMBER
IS
l_shipping_le_id NUMBER;

CURSOR l_shipping_le IS
SELECT
  TO_NUMBER(org_information2)
FROM
  hr_organization_information
WHERE org_information_context = 'Accounting Information'
  AND organization_id = p_warehouse_id;

BEGIN
  OPEN l_shipping_le;
  FETCH l_shipping_le
  INTO l_shipping_le_id;

  IF l_shipping_le%NOTFOUND
  THEN
    l_shipping_le_id:= null;
  END IF;

  CLOSE l_shipping_le;

  RETURN l_shipping_le_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Shipping_Legal_Entity'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Shipping_Legal_Entity'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Shipping_Legal_Entity'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Shipping_Legal_Entity;

--========================================================================
-- FUNCTION  : Get_LE_Currency            PUBLIC
-- PARAMETERS: p_le_id                    legal entity id
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns the functional currency of a given
--             legal entity.
--=======================================================================--

FUNCTION Get_LE_Currency
( p_le_id  IN NUMBER
)
RETURN VARCHAR2
IS
l_currency_code  VARCHAR2(3);

CURSOR c_currency IS
SELECT
  currency_code
FROM
  gl_ledger_le_v
WHERE legal_entity_id = p_le_id
  AND ledger_category_code = 'PRIMARY';
BEGIN
  OPEN c_currency;
  FETCH c_currency
  INTO l_currency_code;

  IF c_currency%NOTFOUND
  THEN
    l_currency_code:= null;
  END IF;

  CLOSE c_currency;

  RETURN l_currency_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_LE_Currency'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_LE_Currency'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_LE_Currency'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_LE_Currency;

--========================================================================
-- FUNCTION  : Get_LE_Location     PUBLIC
-- PARAMETERS: p_le_id             legal entity id
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns the country location of a given
--             legal entity.
--=======================================================================--

FUNCTION Get_LE_Location
( p_le_id  IN NUMBER
)
RETURN VARCHAR2
IS
l_country  hr_locations_all.country%TYPE;
l_short_name hr_locations_all.country%TYPE;

CURSOR c_country IS
SELECT
  country
FROM
  xle_firstparty_information_v
WHERE legal_entity_id = p_le_id;

CURSOR c_terr_code
IS
  SELECT
    DISTINCT territory_code
  FROM
    FND_TERRITORIES_TL                      --fix bug 4165090
  WHERE
    territory_short_name = l_short_name;
BEGIN
  OPEN c_country;
  FETCH c_country INTO
    l_country;
  CLOSE c_country;

  IF length(l_country) > 3
  THEN
    l_short_name := l_country;

    OPEN c_terr_code;
    FETCH c_terr_code INTO
      l_country;
    CLOSE c_terr_code;
  END IF;

  RETURN l_country;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_LE_Location'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_LE_Location'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_LE_Location'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_LE_Location;


--========================================================================
-- PROCEDURE  : Get_Weight_Precision       PUBLIC
-- PARAMETERS: p_legal_entity_id       IN   legal entity  id
--             p_zone_code             IN   zone code
--             p_usage_type            IN   usage type
--             p_stat_type             IN   stat type
--             x_weight_precision      OUT  weight precision
--             x_rep_rounding          OUT  reporting rounding method
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns the weight precision defined on
--             parameter form
--=======================================================================--

PROCEDURE Get_Weight_Precision
( p_legal_entity_id  IN NUMBER
, p_zone_code        IN VARCHAR2
, p_usage_type       IN VARCHAR2
, p_stat_type        IN VARCHAR2
, x_weight_precision OUT NOCOPY NUMBER
, x_rep_rounding     OUT NOCOPY VARCHAR2
)
IS

CURSOR l_prec_rounding IS
SELECT
  weight_precision
, reporting_rounding
FROM
  mtl_stat_type_usages
WHERE legal_entity_id = p_legal_entity_id
  AND zone_code       = p_zone_code
  AND usage_type      = p_usage_type
  AND stat_type       = p_stat_type;
BEGIN
  OPEN l_prec_rounding;
  FETCH l_prec_rounding
  INTO x_weight_precision
     , x_rep_rounding;

  IF l_prec_rounding%NOTFOUND
  THEN
    x_weight_precision := 0;
    x_rep_rounding     := 'NORMAL';
  END IF;

  CLOSE l_prec_rounding;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Weight_Precision'||'.No data found exception'
                    , 'Exception'
                    );
    END IF;
  WHEN TOO_MANY_ROWS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Weight_Precision'||'.too many rows exception'
                    , 'Exception'
                    );
    END IF;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Weight_Precision'||'.Others exception'
                    , 'Exception'
                    );
    END IF;
END Get_Weight_Precision;

--========================================================================
-- FUNCTION  : Round_Number  PUBLIC
-- PARAMETERS: p_number                   number to be rounded
--             p_precision                the precision to be rounded to
--             p_rounding_method          rounding method
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns a rounded number
--=======================================================================--
FUNCTION Round_Number
( p_number           IN NUMBER
, p_precision        IN NUMBER
, p_rounding_method  IN VARCHAR2
)
RETURN NUMBER
IS
l_number NUMBER;

BEGIN
  IF p_rounding_method = 'NORMAL'
  THEN
    l_number := ROUND(p_number, p_precision);
  ELSIF p_rounding_method = 'TRUNCATE'
  THEN
    l_number := TRUNC(p_number, p_precision);
  ELSIF p_rounding_method = 'UP'
  THEN
    SELECT CEIL(p_number * POWER(10,p_precision))/POWER(10,p_precision)
    INTO l_number
    FROM dual;
  ELSE
    l_number := ROUND(p_number, p_precision);
  END IF;

  RETURN l_NUMBER;
EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Round_Number'
                      ||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Round_Number;

--========================================================================
-- FUNCTION  : Get_Org_From_Le            PUBLIC
-- PARAMETERS: p_le_id                    legal entity id
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns a rounded number
--=======================================================================--
FUNCTION Get_Org_From_Le
( p_le_id          IN NUMBER
)
RETURN NUMBER
IS
l_organization_id NUMBER;

CURSOR c_org_id
IS
SELECT
  organization_id
FROM hr_organization_information
WHERE org_information_context = 'Accounting Information'
  AND to_number(org_information2) = p_le_id
  AND rownum = 1;
BEGIN
  OPEN c_org_id;
  FETCH c_org_id INTO
    l_organization_id;

  IF c_org_id%NOTFOUND
  THEN
    l_organization_id := null;
  END IF;

  CLOSE c_org_id;

  RETURN l_organization_id;
EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME ||'Get_Org_From_Le'
                      ||'.Others exception'
                    , 'Exception'
                    );
    END IF;
    RETURN null;
END Get_Org_From_Le;


--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
IS
BEGIN
  g_log_level  := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
  IF g_log_level IS NULL THEN
    g_log_mode := 'OFF';
  ELSE
    IF (TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')) <> 0) THEN
      g_log_mode := 'SRS';
    ELSE
      g_log_mode := 'SQL';
    END IF;
  END IF;

END Log_Initialize;


--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
BEGIN
  IF ((g_log_mode <> 'OFF') AND (p_priority >= g_log_level))
  THEN
    IF g_log_mode = 'SQL'
    THEN
      -- SQL*Plus session: uncomment the next line during unit test
      -- DBMS_OUTPUT.put_line(p_msg);
      NULL;
    ELSE
      -- Concurrent request
      FND_FILE.put_line
      ( FND_FILE.log
      , p_msg
      );
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Log;


END INV_MGD_MVT_UTILS_PKG;

/
