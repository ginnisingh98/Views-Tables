--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_UTIL" as
--$Header: JMFUSHKB.pls 120.17 2007/10/10 06:47:06 kdevadas ship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFUSHKB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Package body file for the Utility package          |
--|                        of the Charge Based SHIKYU project.                |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   29-APR-2005          vchu  Created.                                     |
--|   28-SEP-2005          vchu  Corrected where clause of the query in the   |
--|                              Get_Shikyu_Component_Price procedure         |
--|   28-SEP-2005          vchu  Modified signature of the                    |
--|                              Get_Shikyu_Component_Price procedure         |
--|   03-OCT-2005          shu   Added the debug_output procedure             |
--|   21-OCT-2005          vchu  Added the Get_Shikyu_Offset_Account          |
--|                              procedure                                    |
--|   13-DEC-2005          vchu  Modified Get_Subcontract_Allocated_Qty to    |
--|                              return 0 if there are no existing allocations|
--|                              for the subcontracting order specified       |
--|   15-FEB-2005          vchu  Modified Get_Allocation_Date to return the   |
--|                              scheduled_start_date of the WIP job if it    |
--|                              has not already started, and the             |
--|                              scheduled_completion_date otherwise.         |
--|   13-JUN-2006      rajkrish  Changed the request options for workers      |
--|                              so that it willl be visible                  |
--|   26-JUN-2006        nesoni  Function Get_Replenish_So_Returned_Qty is    |
--|                              modified.                                    |
--|   30-AUG-2006      rajkrish  Added the new procedure clean_invalid_data   |
--|   08-SEP-2006          vchu  Added the new function To_Xsd_Date_String    |
--|                              to convert date values into XSD format so    |
--|                              that they can be formatted correctly in XML  |
--|                              Publisher Reports.                           |
--|   19-SEP-2006          vchu  Modified the function To_Xsd_Date_String     |
--|                              to take a second optional parameter that     |
--|                              denotes the timezone of the offset to be     |
--|                              attached to the DateTime string (either      |
--|                              Server or Client).                           |
--|   20-SEP-2006          vchu  Modified the function To_Xsd_Date_String     |
--|                              to take a second optional parameter that     |
--|                              denotes whether the time component of the    |
--|                              Oracle Date should be omitted.  No need for  |
--|                              this function to optionally attach the User  |
--|                              Timezone offset since it has been decided    |
--|                              that UPTZ would not be supported for R12.    |
--|   04-OCT-2007      kdevadas  12.1 Buy/Sell Subcontracting changes         |
--|                              Reference - GBL_BuySell_TDD.doc              |
--|                              Reference - GBL_BuySell_FDD.doc              |
--+===========================================================================+

--=============================================
-- CONSTANTS
--=============================================
G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'jmf.plsql.' || G_PKG_NAME || '.';

--=============================================
-- GLOBAL VARIABLES
--=============================================

g_fnd_debug   VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

g_submit_failure_exc EXCEPTION;

--========================================================================
-- FUNCTION  : Get_Primary_Uom    PUBLIC
-- PARAMETERS: p_inventory_item_id Item
--             p_organization_id   Inventory Organization
-- COMMENT   : This function returns the name of the primary UOM
--             of the item specified by the input parameters
--========================================================================

FUNCTION Get_Primary_Uom
( p_inventory_item_id   IN NUMBER
, p_organization_id     IN NUMBER
)
RETURN VARCHAR2
IS

l_api_name CONSTANT VARCHAR2(30) := 'Get_Primary_Uom';
l_uom VARCHAR2(25);

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL

  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  SELECT primary_unit_of_measure
  INTO   l_uom
  FROM   mtl_system_items
  WHERE  inventory_item_id  = p_inventory_item_id
  AND    organization_id    = p_organization_id;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

  RETURN l_uom;

END Get_Primary_Uom;


--===================================================================
-- PROCEDURE : clean_invalid_data
-- PARAMETERS :
-- COMMENTS : This procedure will clean/freeze the invalid data in the
--            SHIKYu tables if the data is corrupted
--=====================================================================

PROCEDURE clean_invalid_data

IS


BEGIN

--- The SCO records are updated to interlock status T of the
--- parent PO is cancelled and interlock has not yet processed it

IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , 'JMFUSHKB: clean_invalid_data INTO '
                  , 'IN');
  END IF;


  UPDATE JMF_SUBCONTRACT_ORDERS sco
  SET sco.INTERLOCK_STATUS = 'T'
  WHERE sco.INTERLOCK_STATUS IN ('N','E','U' )
     AND sco.SUBCONTRACT_PO_SHIPMENT_ID IN
                  ( SELECT poll.line_location_id
                  FROM po_headers_all poh
                      , po_lines_all pol
                      , po_line_locations_all poll
                  WHERE poh.po_header_id = sco.SUBCONTRACT_PO_HEADER_ID
                    AND pol.po_line_id   = sco.SUBCONTRACT_PO_LINE_ID
                    AND poll.line_location_id = sco.SUBCONTRACT_PO_SHIPMENT_ID
                    AND poll.po_header_id = sco.SUBCONTRACT_PO_HEADER_ID
                    AND poll.po_line_id  = sco.SUBCONTRACT_PO_LINE_ID
                    AND poll.po_line_id = pol.po_line_id
                    AND poll.po_header_id = pol.po_header_id
                    AND pol.po_header_id = poh.po_header_id
                    AND ( pol.cancel_flag = 'Y' OR
                          poh.cancel_flag = 'Y' OR
                          poll.cancel_flag = 'Y'
                       )
                ) ;




IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , 'JMFUSHKB: clean_invalid_data OUT  '
                  , 'OUT ');
  END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null ;

  WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
     THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , 'JMFUSHKB: clean_invalid_data OUT  '
                  , 'INTO OTHERS EXCEPTION' );
     END IF;


   RAISE FND_API.G_EXC_ERROR;


END clean_invalid_data ;


--========================================================================
-- FUNCTION  : Get_Primary_Uom_Code    PUBLIC
-- PARAMETERS: p_inventory_item_id Item
--             p_organization_id   Inventory Organization
-- COMMENT   : This function returns the code of the primary UOM
--             of the item specified by the input parameters
--========================================================================

FUNCTION Get_Primary_Uom_Code
( p_inventory_item_id   IN NUMBER
, p_organization_id     IN NUMBER
)
RETURN VARCHAR2
IS

l_api_name CONSTANT VARCHAR2(30) := 'Get_Primary_Uom_Code';
l_uom_code VARCHAR2(3);

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  SELECT primary_uom_code
  INTO   l_uom_code
  FROM   mtl_system_items
  WHERE  inventory_item_id  = p_inventory_item_id
  AND    organization_id    = p_organization_id;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

  RETURN l_uom_code;

END Get_Primary_Uom_Code;

--========================================================================
-- FUNCTION  : Get_Uom_Code       PUBLIC
-- PARAMETERS: p_unit_of_measure  Unit of Measure
-- COMMENT   : This function converts an UOM name to the corresponding
--             UOM code
--========================================================================

FUNCTION Get_Uom_Code
( p_unit_of_measure     IN VARCHAR2
)
RETURN VARCHAR2
IS

l_api_name CONSTANT VARCHAR2(30) := 'Get_Uom_Code';

l_uom_code VARCHAR2(25);

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  SELECT uom_code
  INTO   l_uom_code
  FROM   mtl_units_of_measure
  WHERE  unit_of_measure = p_unit_of_measure;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

  RETURN l_uom_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.Set_Name('INV', 'INV_INVALID_UOM_CONV');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END Get_Uom_Code;

--========================================================================
-- FUNCTION  : Get_Uom_Conversion_Rate	PUBLIC
-- PARAMETERS: p_inventory_item_id Inventory Item
--             p_organization_id   Inventory Organization
-- COMMENT   : This function returns UOM conversion rate
--========================================================================

FUNCTION Get_Uom_Conversion_Rate
( P_from_unit IN VARCHAR2
, P_to_unit   IN VARCHAR2
, P_item_id   IN NUMBER
)
RETURN NUMBER
IS

l_uom_rate NUMBER;

BEGIN

  l_uom_rate := 0;
  inv_convert.inv_um_conversion(from_unit => p_from_unit
                               ,to_unit   => p_to_unit
                               ,item_id   => p_item_id
                               ,uom_rate  =>l_uom_rate);
  RETURN l_uom_rate;
EXCEPTION
  WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || 'Get_Uom_Conversion_Rate.others_exception'
                    , 'Exception - Item Id: '||p_item_id ||', From Unit: ' ||
                       p_from_unit || ', To Unit: '  || p_to_unit);
    END IF;
END Get_Uom_Conversion_Rate;

--========================================================================
-- FUNCTION  : Get_Replenish_So_Returned_Qty	PUBLIC
-- PARAMETERS: p_replenishment_so_line_id Replenishment Sales Order line
-- COMMENT   : This function calculates returned quantity in primary
--             UOM against Replenishment Sales Order Line
--========================================================================

FUNCTION Get_Replenish_So_Returned_Qty
( p_replenishment_so_line_id IN NUMBER
)
RETURN NUMBER
IS

l_returned_quantity NUMBER;

BEGIN
  SELECT sum(RT1.PRIMARY_QUANTITY)
  INTO l_returned_quantity
  FROM RCV_TRANSACTIONS RT1, RCV_TRANSACTIONS RT2
  WHERE  RT1.TRANSACTION_TYPE = 'RETURN TO VENDOR'
  AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID
  AND RT2.REPLENISH_ORDER_LINE_ID = p_replenishment_so_line_id;

  IF (l_returned_quantity IS NULL) THEN
   l_returned_quantity := 0;
  END IF;

  RETURN l_returned_quantity;

EXCEPTION
  WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || 'Get_Replenish_So_Returned_Qty.others_exception'
                    , 'Exception - Sales Order Line Id: ' || p_replenishment_so_line_id);
    END IF;
END Get_Replenish_So_Returned_Qty;


--========================================================================
-- FUNCTION  : Get_Replenish_So_Received_Qty	PUBLIC
-- PARAMETERS: p_replenishment_so_line_id Replenishment Sales Order line
-- COMMENT   : This function calculates received quantity in TP Org in primary
--             UOM against Replenishment Sales Order Line
--========================================================================

FUNCTION Get_Replenish_So_Received_Qty
( p_replenishment_so_line_id IN NUMBER
)
RETURN NUMBER
IS

l_received_quantity NUMBER;

BEGIN
  SELECT PRIMARY_QUANTITY
  INTO l_received_quantity
  FROM RCV_TRANSACTIONS
  WHERE TRANSACTION_TYPE IN ('RECEIVE','DELIVER')
  AND REPLENISH_ORDER_LINE_ID = p_replenishment_so_line_id
  AND ROWNUM = 1;

  IF (l_received_quantity IS NULL) THEN
   l_received_quantity := 0;
  END IF;

  RETURN l_received_quantity;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0 ;
  WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || 'Get_Replenish_So_Received_Qty.others_exception'
                    , 'Exception - Sales Order Line Id: ' || p_replenishment_so_line_id);
    END IF;
END Get_Replenish_So_Received_Qty;

-----------------------------------------------------------------------
-- FUNCTION Get_Used_Quantity
-- Comments: This utility will return the component quantity that has been
--           currently issued for WIP job
------------------------------------------------------------------------
FUNCTION Get_Used_Quantity
( p_wip_entity_id              IN NUMBER
, p_shikyu_component_id        IN NUMBER
, p_organization_id            IN NUMBER
)
RETURN NUMBER
IS

l_api_name CONSTANT VARCHAR2(30) := 'Get_Used_Quantity';

l_quantity NUMBER;

BEGIN

 IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
 THEN
   FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                 , G_MODULE_PREFIX || l_api_name || 'GET_used_quantity'
                 , 'begin');
 END IF;

 BEGIN
    SELECT SUM(QUANTITY_ISSUED)
    INTO   l_quantity
    FROM   WIP_REQUIREMENT_OPERATIONS
    WHERE  INVENTORY_ITEM_ID = p_shikyu_component_id
    AND    ORGANIZATION_ID   = p_organization_id
    AND    WIP_ENTITY_ID     = p_wip_entity_id ;

 EXCEPTION
    WHEN NO_DATA_FOUND
    THEN l_quantity := 0 ;

 END;

 IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
 THEN
   FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                 , 'GET_used_quantity Return quantity: '
                 , l_quantity);
 END IF;

 RETURN l_quantity;

END Get_Used_Quantity;

-----------------------------------------------------------------
--- FUNCTION Get_Primary_Quantity
--  Comments: This utility will convert the PO UOM qty into
--            Primary qty
--------------------------------------------------------------------------------
FUNCTION Get_Primary_Quantity
( p_purchasing_UOM     IN VARCHAR2
, p_quantity           IN NUMBER
, P_inventory_org_id   IN NUMBER
, p_inventory_item_id  IN NUMBER ) RETURN NUMBER
IS

l_api_name CONSTANT VARCHAR2(30) := 'Get_Primary_Quantity';

l_to_code          VARCHAR2(30);
l_from_code        VARCHAR2(30);
l_primary_quantity NUMBER ;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name ||
                    'get_prImary_quantity. Invoked'
                  , 'begin');
  END IF;

  SELECT uom_code
  INTO  l_from_code
  FROM  mtl_units_of_measure
  WHERE  unit_of_measure = p_purchasing_UOM  ;

  SELECT mum.uom_code
  INTO   l_to_code
  FROM   mtl_units_of_measure mum
      ,  mtl_system_items msi
  WHERE  mum.unit_of_measure         = msi.primary_unit_of_measure
    AND  msi.inventory_item_id       = p_inventory_item_id
    AND  msi.primary_unit_of_measure = mum.unit_of_measure
    AND  msi.organization_id         = p_inventory_org_id;

  l_primary_quantity := INV_CONVERT.inv_um_convert
                        ( item_id             => p_inventory_item_id                  , precision           => 2
                        , from_quantity       => p_quantity                           , from_unit           => l_from_code
                        , to_unit             => l_to_code
                        , from_name           => null
                        , to_name             => null
                        );

  RETURN l_primary_quantity;

END Get_Primary_Quantity;

----------------------------------------------------------------
--FUNCTION Get_Final_Ship_Date
--Comments: This utility returns the ship date with the lead intransit
--          days included
-----------------------------------------------------------------
FUNCTION Get_Final_Ship_Date
( p_oem_organization    IN NUMBER
, p_tp_organization     IN NUMBER
, p_scheduled_ship_date IN DATE
)
RETURN DATE
IS

l_api_name CONSTANT VARCHAR2(30) := 'Get_Final_Ship_Date';

l_days     NUMBER;
l_date     DATE;

BEGIN

  l_date := NULL;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name ||
                    'get_final_ship_date.Invoked'
                  , 'begin');
  END IF;

  BEGIN

    SELECT NVL(intransit_time, 0)
    INTO   l_days
    FROM   mtl_interorg_ship_methods
    WHERE  from_organization_id = p_oem_organization
    AND    to_organization_id   = p_tp_organization
    AND    default_flag         = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_date := NULL;
  END;

 l_date := p_scheduled_ship_date + l_days;

 RETURN l_date;

END Get_Final_Ship_Date;

----------------------------------------------------------
-- FUNCTION Get_Allocation_Date
-- Comments: This utility returns the allocation need by date
--           based on a WIP entity job
---------------------------------------------------------
FUNCTION Get_Allocation_Date
( p_wip_entity_id IN NUMBER
)
RETURN DATE
IS

l_api_name CONSTANT VARCHAR2(30) := 'Get_Allocation_Date';

l_completion_date DATE;
l_start_date      DATE ;
l_date            DATE ;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name ||
                    'GET_allocation_date.Invoked '
                  , 'begin');
  END IF;

  SELECT SCHEDULED_COMPLETION_DATE , scheduled_start_date
  INTO   l_completion_date , l_start_date
  FROM   WIP_DISCRETE_JOBS
  WHERE  wip_entity_id = p_wip_entity_id;

  IF l_start_date > SYSDATE
  THEN
    l_date := l_start_date;
  ELSE
    l_date := l_completion_date;
 END IF;

 RETURN l_date;

END Get_Allocation_Date;

--=============================================================================
-- PROCEDURE NAME: To_Xsd_Date_String
-- TYPE          : PUBLIC
-- PARAMETERS    :
--   p_date        Oracle Date to be converted to XSD Date Format
--   p_omit_time   Denotes whether the time component of the Oracle Date
--                 should be omitted
-- RETURN        : A String representing the passed in Date in XSD Date Format
-- DESCRIPTION   : Convert an Oracle DB Date Object to a date string represented
--                 in the XSD Date Format.  This is mainly for use by the
--                 XML Publisher Reports.
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 07-SEP-06    VCHU    Created.
--=============================================================================

FUNCTION To_Xsd_Date_String
( p_date      IN DATE
, p_omit_time IN VARCHAR2 DEFAULT 'N'
)
RETURN VARCHAR2
IS

l_api_name CONSTANT VARCHAR2(30) := 'To_Xsd_Date_String';
l_xsd_date_string   VARCHAR2(40);

BEGIN

  IF p_date IS NULL
  THEN
    RETURN NULL;
  END IF;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL

  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX
                  , G_MODULE_PREFIX || l_api_name || '.begin');
  END IF;

  IF p_omit_time = 'Y'
  THEN

    SELECT TO_CHAR(p_date, 'YYYY-MM-DD')
    INTO   l_xsd_date_string
    FROM   DUAL;

  ELSE

    SELECT TO_CHAR(p_date, 'YYYY-MM-DD') || 'T' || TO_CHAR(p_date, 'HH24:MI:SS')
    INTO   l_xsd_date_string
    FROM   DUAL;

  END IF;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX
                  , G_MODULE_PREFIX || l_api_name
                  || '.end: Returning XSD Date = '
                  || l_xsd_date_string);
  END IF;

  RETURN TRIM(l_xsd_date_string);

EXCEPTION

  WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX
                    , G_MODULE_PREFIX || l_api_name || ': ' || sqlerrm);
    END IF;

    RETURN NULL;

END To_Xsd_Date_String;

--=============================================================================
-- PROCEDURE NAME : Get_Subcontract_Order_Org_Ids
-- TYPE          : PUBLIC
--
-- PARAMETERS    :
-- IN:
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 31-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Subcontract_Order_Org_Ids
( p_subcontract_po_shipment_id NUMBER
, x_oem_organization_id        OUT NOCOPY NUMBER
, x_tp_organization_id         OUT NOCOPY NUMBER
)
IS

BEGIN

  SELECT jso.oem_organization_id,
         jso.tp_organization_id
  INTO   x_oem_organization_id,
         x_tp_organization_id
  FROM   JMF_SUBCONTRACT_ORDERS jso
  WHERE  jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_oem_organization_id := NULL;
    x_tp_organization_id := NULL;

END Get_Subcontract_Order_Org_Ids;

--=============================================================================
-- PROCEDURE NAME : Get_Shikyu_Attributes
-- TYPE          : PUBLIC
--
-- PARAMETERS    :
-- IN:
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 25-APR-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Shikyu_Attributes
( p_organization_id          IN  NUMBER
, p_item_id                  IN  NUMBER
, x_outsourced_assembly      OUT NOCOPY NUMBER
, x_subcontracting_component OUT NOCOPY NUMBER
, p_primary_uom_price        OUT NOCOPY NUMBER
)
IS

BEGIN

  SELECT outsourced_assembly,
         subcontracting_component
  INTO   x_outsourced_assembly,
         x_subcontracting_component
  FROM   MTL_SYSTEM_ITEMS_B
  WHERE  organization_id = p_organization_id
  AND    inventory_item_id = p_item_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_outsourced_assembly := NULL;
    x_subcontracting_component := NULL;

END Get_Shikyu_Attributes;

--=============================================================================
-- FUNCTION NAME : Get_Shikyu_Component_Price
-- TYPE          : PUBLIC
--
-- PARAMETERS    :
-- IN:
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 25-APR-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Shikyu_Component_Price
( p_subcontract_po_shipment_id IN  NUMBER
, p_shikyu_component_id        IN  NUMBER
, x_component_uom              OUT NOCOPY VARCHAR2
, x_component_price            OUT NOCOPY NUMBER
, x_primary_uom                OUT NOCOPY VARCHAR2
, x_primary_uom_price          OUT NOCOPY NUMBER
)
IS

BEGIN

  SELECT uom,
         shikyu_component_price,
         primary_uom,
         primary_uom_price
  INTO   x_component_uom,
         x_component_price,
         x_primary_uom,
         x_primary_uom_price
  FROM   JMF_SHIKYU_COMPONENTS
  WHERE  shikyu_component_id = p_shikyu_component_id
  AND    subcontract_po_shipment_id = p_subcontract_po_shipment_id;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_component_uom := NULL;
    x_component_price := NULL;
    x_primary_uom := NULL;
    x_primary_uom_price := NULL;

END Get_Shikyu_Component_Price;

--=============================================================================
-- FUNCTION NAME : Get_Replen_Po_Allocated_Qty
-- TYPE          : PUBLIC
--
-- PARAMETERS    :
-- IN:
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 25-APR-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Replen_Po_Allocated_Qty
( p_replen_po_shipment_id IN  NUMBER
, x_allocated_primary_uom_qty OUT NOCOPY NUMBER
, x_primary_uom               OUT NOCOPY VARCHAR2
)
IS

BEGIN

  SELECT SUM(allocated_primary_uom_quantity),
         MAX(uom)
  INTO   x_allocated_primary_uom_qty,
         x_primary_uom
  FROM   jmf_shikyu_replenishments
  WHERE  replenishment_po_shipment_id = p_replen_po_shipment_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_allocated_primary_uom_qty := NULL;
    x_primary_uom := NULL;

END Get_Replen_Po_Allocated_Qty;

--=============================================================================
-- FUNCTION NAME : Get_Replen_Po_Ordered_Qty
-- TYPE          : PUBLIC
--
-- PARAMETERS    :
-- IN:
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 25-APR-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Replen_Po_Ordered_Qty
( p_replen_po_shipment_id   IN  NUMBER
, x_ordered_primary_uom_qty OUT NOCOPY NUMBER
, x_primary_uom             OUT NOCOPY VARCHAR2
)
IS

BEGIN

  SELECT SUM(ordered_primary_uom_quantity),
         MAX(primary_uom)
  INTO   x_ordered_primary_uom_qty,
         x_primary_uom
  FROM   jmf_shikyu_replenishments
  WHERE  replenishment_po_shipment_id = p_replen_po_shipment_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_ordered_primary_uom_qty := NULL;
    x_primary_uom := NULL;

END Get_Replen_Po_Ordered_Qty;

--=============================================================================
-- FUNCTION NAME : Get_Replen_So_Allocated_Qty
-- TYPE          : PUBLIC
--
-- PARAMETERS    :
-- IN:
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 25-APR-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Replen_So_Allocated_Qty
( p_replen_so_line_id         IN  NUMBER
, x_allocated_qty             OUT NOCOPY NUMBER
, x_uom                       OUT NOCOPY VARCHAR2
, x_allocated_primary_uom_qty OUT NOCOPY NUMBER
, x_primary_uom               OUT NOCOPY VARCHAR2
)
IS

BEGIN

  SELECT allocated_quantity,
         uom,
         allocated_primary_uom_quantity,
         primary_uom
  INTO   x_allocated_qty,
         x_uom,
         x_allocated_primary_uom_qty,
         x_primary_uom
  FROM   JMF_SHIKYU_REPLENISHMENTS
  WHERE  replenishment_so_line_id = p_replen_so_line_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_allocated_qty := NULL;
    x_uom := NULL;
    x_allocated_primary_uom_qty := NULL;
    x_primary_uom := NULL;

END Get_Replen_So_Allocated_Qty;

--=============================================================================
-- FUNCTION NAME : Get_Subcontract_Allocated_Qty
-- TYPE          : PUBLIC
--
-- PARAMETERS    :
-- IN:
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 25-APR-05    VCHU    Created.
--=============================================================================

-- the quantity would be in primary uom
FUNCTION Get_Subcontract_Allocated_Qty
( p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
)
RETURN NUMBER
IS
  l_allocated_qty NUMBER := 0;
BEGIN

  SELECT NVL(SUM(allocated_quantity), 0)
  INTO   l_allocated_qty
  FROM   jmf_shikyu_allocations
  WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND    shikyu_component_id = p_component_id;

  RETURN l_allocated_qty;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;

END Get_Subcontract_Allocated_Qty;

--=============================================================================
-- FUNCTION NAME : Get_Replenishment_So_Price
-- TYPE          : PUBLIC
--
-- PARAMETERS    :
-- IN:
--
-- RETURN:
--
-- DESCRIPTION   :
--
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 25-APR-05    VCHU    Created.
--=============================================================================

PROCEDURE Get_Replenishment_So_Price
( p_replenishment_so_line_id IN  NUMBER
, x_uom                      OUT NOCOPY VARCHAR2
, x_price                    OUT NOCOPY NUMBER
)
IS
BEGIN

  SELECT pricing_quantity_uom,
         unit_selling_price
  INTO   x_uom,
         x_price
  FROM   oe_order_lines_all
  WHERE  line_id = p_replenishment_so_line_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  x_uom := NULL;
  x_price := NULL;
END Get_Replenishment_So_Price;

--========================================================================
-- PROCEDURE : debug_output    PUBLIC
-- PARAMETERS: p_output_to            Identifier of where to output to
--             p_api_name             the called api name
--             p_message              the message that need to be output
-- COMMENT   : the debug output, for using in readonly UT environment
-- PRE-COND  :
-- EXCEPTIONS:
--========================================================================
PROCEDURE debug_output
( p_output_to IN VARCHAR2
, p_api_name  IN VARCHAR2
, p_message   IN VARCHAR2
)
IS
BEGIN

  CASE p_output_to
    WHEN 'FND_LOG.STRING' THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                      ,p_api_name || '.debug_output'
                      ,p_message);
      END IF;
    WHEN 'FND_FILE.OUTPUT' THEN
      fnd_file.put_line(fnd_file.OUTPUT
                       ,p_api_name || '.debug_output' || ': ' ||
                        p_message);
    WHEN 'FND_FILE.LOG' THEN
      fnd_file.put_line(fnd_file.LOG
                       ,p_api_name || '.debug_output' || ': ' ||
                        p_message);
    ELSE
      NULL;
  END CASE;

END debug_output;

--===========================================================================
--  API NAME   : Get_Shikyu_Offset_Account
--
--  DESCRIPTION:
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--  CHANGE HISTORY:	21-Oct-05	VCHU   Created.
--===========================================================================
PROCEDURE Get_Shikyu_Offset_Account
( p_po_shipment_id  IN  NUMBER
, x_offset_account  OUT NOCOPY NUMBER
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Get_Shikyu_Offset_Account';
l_api_version CONSTANT NUMBER       := 1.0;

BEGIN

  x_offset_account := NULL;

  -- Joining the subcontracting orders table with the Shipping Networks
  -- table to get the Code Combination ID of the SHIKYU Offset Account.
  -- The Shipping Networks table stores relationships from OEM Organizations
  -- to MP Organizations
  SELECT mip.shikyu_tp_offset_account_id
  INTO   x_offset_account
  FROM   mtl_interorg_parameters mip,
         jmf_subcontract_orders jso
  WHERE  jso.subcontract_po_shipment_id = p_po_shipment_id
  AND    jso.oem_organization_id = mip.from_organization_id
  AND    jso.tp_organization_id = mip.to_organization_id
 --AND    mip.shikyu_enabled_flag = 'Y';
	AND mip.subcontracting_type in ('B','C') ;   -- 12.1 Buy/Sell Subcontracting changes


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.no_data_found'
                    , 'No relationship exists for the OEM Organization and Manufacturing Organization of the Subcontracting PO');
    END IF;

END Get_Shikyu_Offset_Account;

--========================================================================
-- PROCEDURE : Submit_Worker PUBLIC
-- PARAMETERS: p_batch_id            IN NUMBER    Batch reference that identifies set
--                                                of rows to be processed
--             p_request_count       IN NUMBER    Max number of workers allowed
--             p_cp_short_name       IN VARCHAR2  Short name of concurrent program
--             p_cp_product_code     IN VARCHAR2  Owning product of concurrent program
--             x_workers             IN OUT       Table (of type g_request_tbl_type) containing the
--                                                concurrent request IDs of all the active workers
--             x_request_id          OUT NUMBER   It returns Concurrent Request ID which is
--                                                submitted recently.
--             x_return_status       OUT NUMBER   Return Status
-- COMMENT   : This generic procedure is called to submit concurrent requests.
--             It returns a table containing list of active workers. This accepts
--             batch id as single argument to concurrent program.
--========================================================================
PROCEDURE Submit_Worker
( p_batch_id	    IN NUMBER
, p_request_count   IN NUMBER
, p_cp_short_name   IN VARCHAR2
, p_cp_product_code IN VARCHAR2
, x_workers	    IN OUT NOCOPY g_request_tbl_type
, x_request_id      OUT NOCOPY NUMBER
, x_return_status   OUT NOCOPY VARCHAR2
)
IS

l_worker_idx BINARY_INTEGER;
l_api_name   CONSTANT VARCHAR2(30) := 'Submit_Worker';

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , p_cp_product_code || '.' ||p_cp_short_name || '(' || p_batch_id ||')');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF x_workers.COUNT < p_request_count THEN
    -- number of workers submitted so far does not exceed the maximum
    -- number of workers allowed
    l_worker_idx := x_workers.COUNT + 1;
  ELSE
    -- need to wait for a submitted worker to finish
    JMF_SHIKYU_UTIL.wait_for_worker
    ( p_workers    => x_workers
    , x_worker_idx => l_worker_idx
    );
  END IF;

  -- Calling FND_REQUEST.Set_Options before submitting request to set request attributes
  IF NOT FND_REQUEST.Set_Options
         ( implicit  => 'NO'
         , protected => 'YES'
         )
  THEN
    RAISE g_submit_failure_exc;
  END IF;

  -- Submits concurrent request to be processed by a concurrent manager
  x_workers(l_worker_idx) := FND_REQUEST.submit_request
                             ( application => p_cp_product_code
                             , program     => p_cp_short_name
                             , argument1   => p_batch_id
                             );
  x_request_id := x_workers(l_worker_idx);

  IF x_workers(l_worker_idx) = 0 THEN
    RAISE g_submit_failure_exc;
  END IF;

  COMMIT;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;
EXCEPTION
  WHEN g_submit_failure_exc THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.Submit Request'
                    , 'Exception - ' || p_cp_product_code || '.' ||p_cp_short_name || '(' || p_batch_id ||')');
    END IF;
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception - ' || p_cp_product_code || '.' ||p_cp_short_name || '(' || p_batch_id ||')');
    END IF;
END Submit_Worker;

--========================================================================
-- FUNCTION  : Has_Worker_Completed    PUBLIC
-- PARAMETERS: p_request_id            IN  NUMBER  Unique identifier of a concurrent request.
-- RETURNS   : BOOLEAN
-- COMMENT   : This function accepts a unique identifier of concurrent request
--             and it returns boolean value. It returns TRUE if the corresponding worker
--             has completed, otherwise FALSE.
--=========================================================================
FUNCTION Has_worker_completed
( p_request_id IN NUMBER
)
RETURN BOOLEAN
IS

l_count    NUMBER;
l_result   BOOLEAN;

l_api_name CONSTANT VARCHAR2(30) := 'Has_Worker_Completed';

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , 'Request Id: ' || p_request_id);
  END IF;

  SELECT  COUNT(*)
    INTO  l_count
    FROM  fnd_concurrent_requests
    WHERE request_id = p_request_id
      AND phase_code = 'C';

  IF l_count = 1 THEN
    l_result := TRUE;
  ELSE
    l_result := FALSE;
  END IF;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

  RETURN l_result;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.no_data_found'
                    , 'No data found for concurrent request Id:' || p_request_id);
    END IF;
  WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception - Request Id: ' || p_request_id);
    END IF;

END Has_worker_completed;

--========================================================================
-- PROCEDURE : Wait_For_Worker         PUBLIC
-- PARAMETERS: p_workers               IN  Required
--                                         Table (of type g_request_tbl_type) containing the
--                                         concurrent request IDs of all the active workers
--             x_worker_idx            OUT Index of the worker (within the p_workers table)
--                                         whose current task has completed and can start
--                                         a new concurrent request.
-- COMMENT   : This procedure polls submitted workers and suspend
--             the program till the completion of one of them; it returns
--             the completed worker through x_worker_idx
--=========================================================================
PROCEDURE Wait_for_worker
( p_workers    IN  g_request_tbl_type
, x_worker_idx OUT NOCOPY BINARY_INTEGER
)
IS

l_done     BOOLEAN;
l_api_name CONSTANT VARCHAR2(30) := 'Wait_for_worker';

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  l_done := FALSE;

  WHILE (NOT l_done) LOOP

    FOR l_Idx IN 1..p_workers.COUNT LOOP

      IF JMF_SHIKYU_UTIL.has_worker_completed(p_workers(l_Idx))
      THEN
          l_done := TRUE;
          x_worker_idx := l_Idx;
          EXIT;
      END IF;

    END LOOP;

    IF (NOT l_done) THEN
      DBMS_LOCK.sleep(G_SLEEP_TIME);
    END IF;

  END LOOP;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Wait_For_Worker;

--========================================================================
-- PROCEDURE : Wait_For_All_Workers    PUBLIC
-- PARAMETERS: p_workers               IN  Required
--                                         Table (of type g_request_tbl_type) containing the
--                                         concurrent request IDs of all the active workers
-- COMMENT   : This procedure polls submitted workers and suspend
--             the program till completion of all of workers.
--=========================================================================
PROCEDURE wait_for_all_workers
( p_workers IN g_request_tbl_type
)
IS

l_done     BOOLEAN;
l_api_name CONSTANT VARCHAR2(30) := 'Wait_for_all_workers';

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  l_done := FALSE;

  WHILE (NOT l_done) LOOP

    l_done := TRUE;

    FOR l_Idx IN 1..p_workers.COUNT LOOP

      IF NOT
        JMF_SHIKYU_UTIL.has_worker_completed(p_workers(l_Idx))
      THEN
        l_done := FALSE;
        EXIT;
      END IF;

    END LOOP;

    IF (NOT l_done) THEN
      DBMS_LOCK.sleep(G_SLEEP_TIME);
    END IF;

  END LOOP;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;

END wait_for_all_workers;

END JMF_SHIKYU_UTIL;

/
