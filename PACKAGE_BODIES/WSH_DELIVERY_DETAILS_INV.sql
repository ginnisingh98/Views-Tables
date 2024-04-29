--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_DETAILS_INV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_DETAILS_INV" as
/* $Header: WSHDDICB.pls 120.10.12010000.2 2009/05/20 12:30:08 sunilku ship $ */

g_org		INV_VALIDATE.Org;
g_item		INV_VALIDATE.Item;
g_sub        	INV_VALIDATE.Sub;
g_loc		INV_VALIDATE.Locator;
g_lot		INV_VALIDATE.Lot;
g_serial	INV_VALIDATE.Serial;
g_to_sub        INV_VALIDATE.Sub;


-- bug 5264874

TYPE inventory_control_rec IS RECORD(
    LOC_CONTROL_FLAG                 VARCHAR2(3),
    LOT_CONTROL_FLAG                 VARCHAR2(3),
    REV_CONTROL_FLAG                 VARCHAR2(3),
    SERIAL_CONTROL_FLAG              VARCHAR2(3),
    RESTRICT_LOCATORS_CODE           MTL_SYSTEM_ITEMS.RESTRICT_LOCATORS_CODE%TYPE,
    RESTRICT_SUBINVENTORIES_CODE     MTL_SYSTEM_ITEMS.RESTRICT_SUBINVENTORIES_CODE%TYPE,
    SERIAL_NUMBER_CONTROL_CODE       MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE%TYPE,
    LOCATION_CONTROL_CODE            MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE%TYPE,
    RESERVABLE_TYPE                  MTL_SYSTEM_ITEMS.RESERVABLE_TYPE%TYPE,
    MTL_TRANSACTIONS_ENABLED_FLAG    MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG%TYPE);


TYPE inventory_control_tab IS       TABLE OF inventory_control_rec INDEX BY VARCHAR2(90);
g_inventory_control_tab             inventory_control_tab;


CURSOR c_item_info (v_organization_id NUMBER, v_inventory_item_id IN NUMBER) IS
SELECT organization_id, inventory_item_id,
       primary_uom_code, secondary_uom_code, secondary_default_ind,
       lot_control_code, tracking_quantity_ind, dual_uom_deviation_low,
       dual_uom_deviation_high, enabled_flag, shippable_item_flag,
       inventory_item_flag, lot_divisible_flag, container_item_flag,
       reservable_type, mtl_transactions_enabled_flag, 'Y' valid_flag
FROM MTL_SYSTEM_ITEMS
WHERE organization_id = v_organization_id
AND   inventory_item_id = v_inventory_item_id;

CURSOR c_org_param_info (v_organization_id NUMBER) IS
SELECT  STOCK_LOCATOR_CONTROL_CODE,
        NEGATIVE_INV_RECEIPT_CODE,
        SERIAL_NUMBER_TYPE
FROM    MTL_PARAMETERS
WHERE   organization_id = v_organization_id;

CURSOR c_sec_inv_info (v_organization_id NUMBER, v_subinventory VARCHAR2) IS
SELECT locator_type
FROM MTL_SUBINVENTORIES_TRK_VAL_V
WHERE organization_id = v_organization_id
AND secondary_inventory_name = v_subinventory;

TYPE Item_Cache_Tab_Typ   IS TABLE OF c_item_info%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE Param_Cache_Tab_Typ  IS TABLE OF c_org_param_info%ROWTYPE INDEX BY VARCHAR2(60);
TYPE Sec_inv_Tab_Typ      IS TABLE OF c_sec_inv_info%ROWTYPE  INDEX BY VARCHAR2(60);
-- HW OPMCONV New table to hold item information

g_item_tab              Item_Cache_Tab_Typ;
g_param_tab             Param_Cache_Tab_Typ;
g_sec_inv_tab           Sec_inv_Tab_Typ;
g_lpad_char             VARCHAR2(1)  := '0';
g_lpad_length           NUMBER       := 25;
g_session_id            NUMBER;

-- bug 5264874 end
/*
** bug 1583800: enable support for nontransactable items
** Internal procedure: Inventory_Item
**   This is a copy of function INV_VALIDATE.inventory_item in INVVSVATB.pls
**   The code has been modified not to check MTL_TRANSACTIONS_ENABLED_FLAG
**   and to qualify the package INV_VALIDATE constants T and F.
**   The code is simplified, as we set only p_item.inventory_item_id.
**/
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_DETAILS_INV';
--

-- HW OPMCONV New procedure to cach item info

--========================================================================
-- PROCEDURE : get_item_table_index
--
-- COMMENT   : Validate using Hash (internal API)
--             uses Hash and avoids linear scans while using PL/SQL tables
--             Currently available for 4 parameters (VARCHAR2 datatype)
-- PARAMETERS:
-- p_validate_rec   -- Input Key to be validated
-- x_generic_tab  -- populated for existing cached records
-- x_index       -- New index which can be used for x_flag = U
-- x_return_status     -- S,E,U,W
-- x_flag    -- U to use this index,D to indicate valid record
--
-- HISTORY   : Bug 3821688
-- NOTE      : For performance reasons, no debug calls are added
--========================================================================
PROCEDURE get_item_table_index
  (p_validate_rec  IN c_item_info%ROWTYPE,
   p_item_tab      IN Item_Cache_Tab_Typ,
   x_index         OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_flag          OUT NOCOPY VARCHAR2
  )IS

  c_hash_base CONSTANT NUMBER := 1;
  c_hash_size CONSTANT NUMBER := power(2, 25);

  l_hash_string      VARCHAR2(4000) := NULL;
  l_index            NUMBER;
  l_hash_exists      BOOLEAN := FALSE;

  l_flag             VARCHAR2(1);


BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_hash_exists   := FALSE;
    -- need to hash this index
    -- Key (for hash) : Organization_id || Inventory_item_id

    l_hash_string := to_char(p_validate_rec.organization_id)||
                     to_char(p_validate_rec.inventory_item_id);

    -- Hash returns a common index if l_hash_string is identical
    l_index := dbms_utility.get_hash_value (
                 name => l_hash_string,
                 base => c_hash_base,
                 hash_size => c_hash_size);
    WHILE NOT l_hash_exists LOOP
      IF p_item_tab.EXISTS(l_index) THEN
          -- Check for all attributes match

        IF (
              p_item_tab(l_index).organization_id =p_validate_rec.organization_id
              AND
               p_item_tab(l_index).inventory_item_id=p_validate_rec.inventory_item_id
            ) THEN
            -- exact match found at this index
            l_flag := 'D';
            EXIT;
        ELSE

          -- Index exists but key does not match this table element
          -- Bump l_index till key matches or table element does not exist
          l_index := l_index + 1;
        END IF;
      ELSE
        -- Index is not used in the table, can be used to create a new record
        l_hash_exists := TRUE; -- to exit from the loop
        l_flag := 'U';
      END IF;
    END LOOP;

  x_index := l_index;
  x_flag := l_flag;

END get_item_table_index;
--

FUNCTION Inventory_Item (p_item IN OUT nocopy INV_VALIDATE.item,
                         p_org  IN            INV_VALIDATE.org)
RETURN NUMBER
IS
   l_appl_short_name VARCHAR2(3) := 'INV';
   l_key_flex_code VARCHAR2(4) := 'MSTK';
   l_structure_number NUMBER := 101;
   l_conc_segments VARCHAR2(2000);
   l_keystat_val BOOLEAN;
   l_id                 NUMBER;
   l_validation_mode VARCHAR2(25) := INV_VALIDATE.EXISTS_ONLY;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INVENTORY_ITEM';
--
BEGIN

    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
    END IF;
    --
    SELECT  *
      INTO    p_item
      FROM    MTL_SYSTEM_ITEMS
      WHERE   ORGANIZATION_ID = p_org.organization_id
      AND   INVENTORY_ITEM_ID = p_item.inventory_item_id;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN INV_VALIDATE.T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INT_ITMCODE');
            FND_MSG_PUB.Add;

        END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
END IF;
--
        RETURN INV_VALIDATE.F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   'WSH_DELIVERY_DETAILS_INV'  -- Shipping package
            ,   'Inventory_Item'
            );
        END IF;

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

-- bug 5264874

/*
-----------------------------------------------------------------------------
  PROCEDURE   : Get_Org_Param_information
  PARAMETERS  : p_organization_id       - organization id
                x_mtl_org_param_rec     - Record to hold parameters informatiom
                x_return_status   - success if able to look up item information
                                    error if cannot find item information

  DESCRIPTION :	This API takes the organization id
		and checks if parameters information is already cached, if
		not, it loads the new parameters information for a specific
		organization
-----------------------------------------------------------------------------
*/

PROCEDURE Get_Org_Param_information (
  p_organization_id         IN            NUMBER
, x_mtl_org_param_rec       OUT  NOCOPY   WSH_DELIVERY_DETAILS_INV.mtl_org_param_rec
, x_return_status           OUT  NOCOPY   VARCHAR2
)IS


  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Org_Param_information';
  TYPE org_param_cache_tab IS TABLE OF c_org_param_info%ROWTYPE;

  l_cache_rec c_org_param_info%ROWTYPE;

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


    IF p_organization_id IS NOT NULL THEN

        IF g_param_tab.EXISTS(p_organization_id) THEN
            l_cache_rec := g_param_tab(p_organization_id);
        ELSE
          OPEN  c_org_param_info (p_organization_id);
          FETCH c_org_param_info INTO l_cache_rec;
          IF c_org_param_info%NOTFOUND THEN
            l_cache_rec.negative_inv_receipt_code   := 1;
            l_cache_rec.serial_number_type          := -99;
            l_cache_rec.stock_locator_control_code  := 4;
          END IF;
          CLOSE c_org_param_info;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_cache_rec.stock_locator_control_code',l_cache_rec.stock_locator_control_code);
            WSH_DEBUG_SV.log(l_module_name,'l_cache_rec.negative_inv_receipt_code',l_cache_rec.negative_inv_receipt_code);
            WSH_DEBUG_SV.log(l_module_name,'l_cache_rec.serial_number_type',l_cache_rec.serial_number_type);
          END IF;
          -- add record to cache
          g_param_tab(p_organization_id) := l_cache_rec;
        END IF;

        x_mtl_org_param_rec.stock_locator_control_code  :=  l_cache_rec.stock_locator_control_code;
        x_mtl_org_param_rec.negative_inv_receipt_code   :=  l_cache_rec.negative_inv_receipt_code;
        x_mtl_org_param_rec.serial_number_type          :=  l_cache_rec.serial_number_type;

    ELSE  -- Org is is null
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,x_return_status);
        END IF;
	    --
      RETURN;
    END IF;

    IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name,x_return_status);
     END IF;

EXCEPTION

   WHEN others THEN
     wsh_util_core.default_handler ('WSH_DELIVERY_DETAILS_INV.Get_Org_Param_information');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     IF c_org_param_info%isopen THEN
        close c_org_param_info;
     END IF;

END Get_Org_Param_information;


/*
-----------------------------------------------------------------------------
  PROCEDURE   : Get_Sec_Inv_information
  PARAMETERS  : p_organization_id       - organization id
                p_inventory_item_id     - inventory_item_id
                x_mtl_sec_inv_rec  - Record to hold sec inventoy informatiom
                x_return_status   - success if able to look up sec inventoy information
                                    error if cannot find information

  DESCRIPTION :	This API takes the organization and inventory item
		and checks if sec inventoy information is already cached, if
		not, it loads the new sec inventoy information for a specific
		organization
-----------------------------------------------------------------------------
*/

PROCEDURE Get_Sec_Inv_information (
  p_organization_id         IN            NUMBER
, p_subinventory_name       IN            VARCHAR2
, x_mtl_sec_inv_rec         OUT  NOCOPY   WSH_DELIVERY_DETAILS_INV.mtl_sec_inv_rec
, x_return_status           OUT  NOCOPY   VARCHAR2
)IS



  l_debug_on        BOOLEAN;
  l_module_name     CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Sec_Inv_information';

  l_cache_rec       c_sec_inv_info%ROWTYPE;
  l_key             VARCHAR2(60);

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   IF p_organization_id IS NOT NULL THEN

        l_key := LPAD(p_organization_id, g_lpad_length, g_lpad_char) ||'-'|| LPAD(p_subinventory_name, g_lpad_length, g_lpad_char);

        IF g_sec_inv_tab.EXISTS(l_key) THEN
            l_cache_rec := g_sec_inv_tab(l_key);
        ELSE
          OPEN  c_sec_inv_info (p_organization_id, p_subinventory_name);
          FETCH c_sec_inv_info INTO l_cache_rec;
          IF c_sec_inv_info%NOTFOUND THEN
            l_cache_rec.locator_type  := 1;
          END IF;
          CLOSE c_sec_inv_info;

          -- add record to cache
          g_sec_inv_tab(l_key) := l_cache_rec;
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'x_mtl_sec_inv_rec.locator_type',x_mtl_sec_inv_rec.locator_type);
          END IF;

        END IF;

        x_mtl_sec_inv_rec.locator_type  :=  l_cache_rec.locator_type;

    ELSE  -- Org is is null
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name, x_return_status);
        END IF;
	    --
      RETURN;
    END IF;

    IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name,x_return_status);
     END IF;

EXCEPTION

   WHEN others THEN
     wsh_util_core.default_handler ('WSH_DELIVERY_DETAILS_INV.Get_Sec_Inv_information');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     IF c_sec_inv_info%isopen THEN
        close c_sec_inv_info;
     END IF;

END Get_Sec_Inv_information;

-- bug 5264874 end

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Fetch_Inv_Controls
   PARAMETERS : p_delivery_detail_id - delivery detail id.
		p_inventory_item_id - inventory_item_id on line for which
		inventory controls need to be determined.
		p_organization_id - organization_id to which inventory_item
		belongs.
		p_subinventory - subinventory to which the item belongs
		x_inv_controls_rec - output record of
		WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec type containing
		all inv control flags for the item and organization.
		x_return_status - return status of the API.
  DESCRIPTION : This procedure takes a delivery detail id and optionally
		inventory item id and organization id and determines whether
		the item is under any of the inventory controls. The API
		fetches the control codes/flags from mtl_system_items for the
		given inventory item and organization and decodes them and
		returns a record of inv controls with a 'Y' or a 'N' for each
		of the inv controls.

------------------------------------------------------------------------------
*/

PROCEDURE Fetch_Inv_Controls (
  p_delivery_detail_id IN NUMBER DEFAULT NULL,
  p_inventory_item_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_subinventory IN VARCHAR2,
  x_inv_controls_rec OUT NOCOPY  WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec,
  x_return_status OUT NOCOPY  VARCHAR2) IS

  -- OPM change 1711019


  l_pickable_flag VARCHAR2(1);-- added for Bug 3584278


  -- HW OPM BUG#:3011758 Added container_item_flag
  -- Bug 3584278 : Remove join to wsh_delivery_details table(in the cursor) since the fields required
  -- from wdd are already available in the local variables
  CURSOR Get_Inv_Controls (v_inventory_item_id NUMBER,
                           v_organization_id NUMBER,
                           v_pickable_flag VARCHAR2) IS
  SELECT DECODE(msi.location_control_code, 1, 'N',
                                          'Y') loc_control_flag,
   	 DECODE(msi.lot_control_code, 2, DECODE(v_pickable_flag, 'N', 'O',
                                                                  'Y'),
                                      3, 'N',
                                      'N') lot_control_flag,
    	 DECODE(msi.revision_qty_control_code, 2, DECODE(v_pickable_flag, 'N', 'O',
                                                                           'Y'),
                                                 'N') rev_control_flag,
	 DECODE(msi.serial_number_control_code,2, 'Y',
                                              5, 'Y',
                                              6, 'D',
                                              'N') serial_control_flag,
	 msi.restrict_locators_code,
	 msi.restrict_subinventories_code,
	 msi.serial_number_control_code,
	 msi.location_control_code,
-- HW OPMCONV. No need for item_no
--      msi.segment1 ,
--      msi.container_item_flag,
	 msi.reservable_type,
         msi.MTL_TRANSACTIONS_ENABLED_FLAG  -- Bug 3599363
    FROM MTL_SYSTEM_ITEMS     msi
   WHERE msi.inventory_item_id = v_inventory_item_id
     AND msi.organization_id     = v_organization_id;

  CURSOR Get_Detail_Item IS
  SELECT inventory_item_id, organization_id, subinventory,
         container_flag,pickable_flag
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = p_delivery_detail_id;


  l_rev_flag VARCHAR2(3);
  l_loc_flag VARCHAR2(3);
  l_lot_flag VARCHAR2(3);
  l_ser_flag VARCHAR2(3);
  l_sub_flag VARCHAR2(3) := 'Y';
  l_serial_number_code NUMBER;
  l_location_control_code NUMBER;

  l_restrict_loc_code NUMBER;
  l_restrict_sub_code NUMBER;

  l_inv_item_id NUMBER;
  l_org_id NUMBER;
  l_cont_flag VARCHAR2(1);

  l_org_loc_code NUMBER;
  l_sub_loc_code NUMBER;

  l_subinv VARCHAR2(30);
  l_dft_subinv VARCHAR2(30);
  l_txn_enabled_flag VARCHAR2(1);
  l_loc_ctl_code NUMBER;

  -- HW OPM BUG:3011758 Added l_container_item_flag
  -- HW OPMCONV. No need for container_item_flag variable
--l_container_item_flag VARCHAR2(1);
  --
  l_debug_on BOOLEAN;

  l_reservable_type  NUMBER ;
  l_inventory_control_rec inventory_control_rec;
  l_key                   VARCHAR2(90);
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FETCH_INV_CONTROLS';
  --

BEGIN

  --
  -- Debug Statements
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
  END IF;
  --
  IF p_delivery_detail_id IS NULL THEN
   --{
   FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WSH_UTIL_CORE.Add_Message(x_return_status);
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;
   --}
  END IF;
  --
  -- Bug 3584278 , the cursor is required always, so moving the cursor before
  -- If validation.This is required to identify if the delivery line is a container
  OPEN Get_Detail_Item;
  FETCH Get_Detail_Item INTO l_inv_item_id, l_org_id, l_subinv,
                             l_cont_flag,l_pickable_flag;
  --
  IF Get_Detail_Item%NOTFOUND THEN
   --{
   CLOSE Get_Detail_Item;
   FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WSH_UTIL_CORE.Add_Message(x_return_status);
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;
   --}
  END IF;
  --
  IF Get_Detail_Item%ISOPEN THEN
    CLOSE Get_Detail_Item;
  END IF;
  -- End of Bug 3584278
  --
  -- Note that the Input variables are being assigned to Local variables
  -- This overrides the values returned from above cursor in local variables
  IF p_inventory_item_id IS NOT NULL AND p_organization_id IS NOT NULL THEN
    l_inv_item_id := p_inventory_item_id;
    l_org_id := p_organization_id;
    l_subinv := p_subinventory;
  END IF;
  --
  -- Use the Inventory Item Id and organization to fetch the inv controls..
  -- Bug 3584278, Container item is not under inventory controls
  IF (l_inv_item_id IS NULL OR
      l_cont_flag = 'Y'
     )THEN
   --{
   -- bug 1661590: LPNs/containers in WMS can have NULL inventory_item_id
   -- For them, we should not send a message "No Data Found."
   -- bug 2177410, delivery detail line in WMS can have NULL
   -- inventory_item_id as well
   x_inv_controls_rec.rev_flag              := 'N';
   x_inv_controls_rec.rev_flag              := 'N';
   x_inv_controls_rec.lot_flag              := 'N';
   x_inv_controls_rec.sub_flag              := 'N';
   x_inv_controls_rec.loc_flag              := 'N';
   x_inv_controls_rec.ser_flag              := 'N';
   x_inv_controls_rec.restrict_loc          := NULL;
   x_inv_controls_rec.restrict_sub          := NULL;
   x_inv_controls_rec.location_control_code := NULL;
   x_inv_controls_rec.serial_code           := NULL;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Case where l_inv_item_id IS NULL or line is Container');
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;
   --}
  END IF;
  -- bug 5264874


  l_key := lpad(l_inv_item_id,g_lpad_length, g_lpad_char) || '-' ||
           lpad(l_org_id, g_lpad_length, g_lpad_char)||'-'||
           lpad(l_pickable_flag,g_lpad_length, g_lpad_char);

  IF g_inventory_control_tab.EXISTS(l_key) THEN

        l_inventory_control_rec := g_inventory_control_tab(l_key);

        l_loc_flag              := l_inventory_control_rec.LOC_CONTROL_FLAG;
        l_lot_flag              := l_inventory_control_rec.LOT_CONTROL_FLAG;
        l_rev_flag              := l_inventory_control_rec.REV_CONTROL_FLAG;
        l_ser_flag              := l_inventory_control_rec.SERIAL_CONTROL_FLAG;
        l_restrict_loc_code     := l_inventory_control_rec.RESTRICT_LOCATORS_CODE;
        l_restrict_sub_code     := l_inventory_control_rec.RESTRICT_SUBINVENTORIES_CODE;
        l_serial_number_code    := l_inventory_control_rec.SERIAL_NUMBER_CONTROL_CODE;
        l_location_control_code := l_inventory_control_rec.LOCATION_CONTROL_CODE;
        l_reservable_type       := l_inventory_control_rec.RESERVABLE_TYPE;
        l_txn_enabled_flag      := l_inventory_control_rec.MTL_TRANSACTIONS_ENABLED_FLAG;
  -- bug 5264874 end
  ELSE

      --
      -- Bug 3584278, input parameters added for cursor get_inv_controls
      OPEN Get_Inv_Controls (l_inv_item_id,l_org_id,l_pickable_flag);
      --
      -- HW OPM BUG#:3011758 Added l_container_item_flag
      -- HW OPMCONV. No need to retreieve item_no, l_container_item_flag
      FETCH Get_Inv_Controls INTO
        l_loc_flag,
        l_lot_flag,
        l_rev_flag,
        l_ser_flag,
        l_restrict_loc_code,
        l_restrict_sub_code,
        l_serial_number_code,
        l_location_control_code,
    --      l_item_no ,
    --      l_container_item_flag,
        l_reservable_type,
        l_txn_enabled_flag ; -- Bug 3599363
      --
      IF Get_Inv_Controls%NOTFOUND THEN
       --{
       CLOSE Get_Inv_Controls;
       FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.Add_Message(x_return_status);
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       return;
       --}
      END IF;
      --
      IF Get_Inv_Controls%ISOPEN THEN
       CLOSE Get_Inv_Controls;
      END IF;
      -- bug 526487
      l_inventory_control_rec.LOC_CONTROL_FLAG                  :=    l_loc_flag;
      l_inventory_control_rec.LOT_CONTROL_FLAG                  :=    l_lot_flag;
      l_inventory_control_rec.REV_CONTROL_FLAG                  :=    l_rev_flag;
      l_inventory_control_rec.SERIAL_CONTROL_FLAG               :=    l_ser_flag;
      l_inventory_control_rec.RESTRICT_LOCATORS_CODE            :=    l_restrict_loc_code;
      l_inventory_control_rec.RESTRICT_SUBINVENTORIES_CODE      :=    l_restrict_sub_code;
      l_inventory_control_rec.SERIAL_NUMBER_CONTROL_CODE        :=    l_serial_number_code;
      l_inventory_control_rec.LOCATION_CONTROL_CODE             :=    l_location_control_code;
      l_inventory_control_rec.RESERVABLE_TYPE                   :=    l_reservable_type;
      l_inventory_control_rec.MTL_TRANSACTIONS_ENABLED_FLAG     :=    l_txn_enabled_flag;

      g_inventory_control_tab(l_key)                            :=    l_inventory_control_rec;
      -- bug 5264874 end
  END IF;
  --
  -- OPM B1711019
  --
   -- HW OPMCONV. No need to fork code

  x_inv_controls_rec.rev_flag := l_rev_flag;
  x_inv_controls_rec.lot_flag := l_lot_flag;
  x_inv_controls_rec.sub_flag := 'Y';
  x_inv_controls_rec.reservable_type  := l_reservable_type ;
  x_inv_controls_rec.transactable_flag := l_txn_enabled_flag;
  --
  -- Bug 3599363 : Call default_subinventory() only if the
  -- sub on the line is NULL and the item is transactable
  --
  IF (l_subinv IS NULL AND
     NVL(l_txn_enabled_flag, 'N') = 'Y') THEN
   --{
   IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'Txn Enabled Flag', l_txn_enabled_flag);
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.DEFAULT_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_DELIVERY_DETAILS_INV.Default_Subinventory (
				l_org_id,
				l_inv_item_id,
				l_dft_subinv,
				x_return_status);
   --
   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    l_dft_subinv := NULL;
   END IF;
   --}
  END IF;
  --
  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'Default Sub', l_dft_subinv);
    wsh_debug_sv.log(l_module_name, 'Input Default Sub', l_subinv);
  END IF;
  --
  IF (nvl(l_subinv, l_dft_subinv) IS NOT NULL) THEN
   --{
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.GET_ORG_LOC',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_org_loc_code := WSH_DELIVERY_DETAILS_INV.Get_Org_Loc (l_org_id);
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.SUB_LOC_CTL',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_sub_loc_code := WSH_DELIVERY_DETAILS_INV.Sub_Loc_Ctl (
					nvl(l_subinv,l_dft_subinv),
					l_org_id);

   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.LOCATOR_CTL_CODE',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_loc_ctl_code := WSH_DELIVERY_DETAILS_INV.Locator_Ctl_Code(
					l_org_id,
					l_restrict_loc_code,
					l_org_loc_code,
					l_sub_loc_code,
					l_location_control_code);
   --
   IF l_loc_ctl_code = 1 THEN
     l_loc_flag := 'N';
   ELSE
     l_loc_flag := 'Y';
   END IF;
   --
   -- Hverddin 12-SEP-2000 OPM start Of Changes --
   --
-- HW OPMCONV. No need to check for OPM orgs

  END IF;
  --
  x_inv_controls_rec.loc_flag := l_loc_flag;
  x_inv_controls_rec.ser_flag := l_ser_flag;
  x_inv_controls_rec.restrict_loc := l_restrict_loc_code;
  x_inv_controls_rec.restrict_sub := l_restrict_sub_code;
  x_inv_controls_rec.serial_code := l_serial_number_code;
  x_inv_controls_rec.location_control_code := l_loc_ctl_code;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'X_INV_CONTROLS_REC.LOC_FLAG',x_inv_controls_rec.loc_flag);
     WSH_DEBUG_SV.log(l_module_name,'X_INV_CONTROLS_REC.SER_FLAG',x_inv_controls_rec.ser_flag);
     WSH_DEBUG_SV.log(l_module_name,'X_INV_CONTROLS_REC.RESTRICT_LOC',x_inv_controls_rec.restrict_loc);
     WSH_DEBUG_SV.log(l_module_name,'X_INV_CONTROLS_REC.RESTRICT_SUB',x_inv_controls_rec.restrict_sub);
     WSH_DEBUG_SV.log(l_module_name,'X_INV_CONTROLS_REC.SERIAL_CODE',x_inv_controls_rec.serial_code);
     WSH_DEBUG_SV.log(l_module_name,'X_INV_CONTROLS_REC.LOCATION_CONTROL_CODE',x_inv_controls_rec.location_control_code);
     WSH_DEBUG_SV.log(l_module_name, 'X_INV_CONTROLS_REC.TRANSACTABLE_FLAG',
                      x_inv_controls_rec.transactable_flag);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN Others THEN
       IF Get_Detail_Item%ISOPEN THEN
          CLOSE Get_Detail_Item;
        END IF;

        IF Get_Inv_Controls%ISOPEN THEN
	        CLOSE Get_Inv_Controls;
        END IF;

	WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_INV.Fetch_Inv_Controls');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Fetch_Inv_Controls;

/*
-----------------------------------------------------------------------------
   FUNCTION   : Details_Required
   PARAMETERS : p_line_inv_rec - WSH_DELIVERY_DETAILS_INV.line_inv_info type
		that contains information about all the inventory control
		values on the form for the delivery detail id.
		p_set_default - boolean variable that indicates whether
		to retrieve the default values for controls if the
		attributes are missing.
		x_line_inv_rec - WSH_DELIVERY_DETAILS_INV.line_inv_info type
		containing default values in the case where set_default is TRUE
  DESCRIPTION : This function takes a WSH_DELIVERY_DETAILS_INV.line_inv_info
		type with inventory control attributes for the delivery detail
		id from the form and determines whether additional inventory
		control information needs to be entered or not. If additional
		control information is needed then the functions returns a
		TRUE or else it is returns FALSE.
		Alternatively, if the p_set_default value is set to TRUE, then
		it retrieves any default control attributes for the inventory
		item on the line and returns the information as x_line_inv_rec

------------------------------------------------------------------------------
*/


PROCEDURE Details_Required (
  p_line_inv_rec IN WSH_DELIVERY_DETAILS_INV.line_inv_info,
  p_set_default IN BOOLEAN DEFAULT FALSE,
  x_line_inv_rec OUT NOCOPY  WSH_DELIVERY_DETAILS_INV.line_inv_info,
  x_details_required OUT NOCOPY  BOOLEAN,
  x_return_status OUT NOCOPY  VARCHAR2) IS

  dft_subinv 		VARCHAR2(12);
  subinv		VARCHAR2(12);
  loc_restricted_flag 	VARCHAR2(1);
  dft_loc_id		NUMBER;
  org_loc_ctl		NUMBER;
  sub_loc_ctl		NUMBER;
  item_loc_ctl		NUMBER;
  loc_ctl_code		NUMBER;
  default_loc		VARCHAR2(2000);

  l_inv_controls_rec WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;

  l_ser_qty 		NUMBER;
  l_container_flag 	VARCHAR2(1) := 'N';

CURSOR get_line_info_cur (p_delivery_detail_id in number ) IS
SELECT container_flag
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = p_delivery_detail_id;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DETAILS_REQUIRED';
--
BEGIN

/*
  IF (p_line_inv_rec IS NULL) THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_DETAIL_INVALID');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     x_details_required := FALSE;
     return;
  END IF;
*/

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_SET_DEFAULT',P_SET_DEFAULT);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.DELIVERY_DETAIL_ID',P_LINE_INV_REC.delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.INVENTTORY_ITEM_ID',P_LINE_INV_REC.inventory_item_id);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.SHP_QTY',P_LINE_INV_REC.shp_qty);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.REQ_QTY',P_LINE_INV_REC.req_qty);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.SER_QTY',P_LINE_INV_REC.ser_qty);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.REVISION',P_LINE_INV_REC.revision);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.SUBINVENTORY',P_LINE_INV_REC.subinventory);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.LOT_NUMBER',P_LINE_INV_REC.lot_number);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.LOCATOR_ID',P_LINE_INV_REC.locator_id);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.LOCATOR_CONTROL_CODE',P_LINE_INV_REC.locator_control_code);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.SERIAL_NUMBER_CONTROL_CODE',P_LINE_INV_REC.serial_number_control_code);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.TRANSACTION_TEMP_ID',P_LINE_INV_REC.transaction_temp_id);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_INV_REC.ORGANIZATION_ID',P_LINE_INV_REC.organization_id);
  END IF;
  --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.FETCH_INV_CONTROLS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_DELIVERY_DETAILS_INV.Fetch_Inv_Controls (
	p_line_inv_rec.delivery_detail_id,
     	p_line_inv_rec.inventory_item_id,
	p_line_inv_rec.organization_id,
	p_line_inv_rec.subinventory,
	l_inv_controls_rec,
	x_return_status);

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	x_details_required := FALSE;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  -- bug 1661590: if no inventory controls, details are not required
  IF     l_inv_controls_rec.rev_flag              = 'N'
     AND l_inv_controls_rec.rev_flag              = 'N'
     AND l_inv_controls_rec.lot_flag              = 'N'
     AND l_inv_controls_rec.sub_flag              = 'N'
     AND l_inv_controls_rec.loc_flag              = 'N'
     AND l_inv_controls_rec.ser_flag              = 'N'
     AND l_inv_controls_rec.restrict_loc          IS NULL
     AND l_inv_controls_rec.restrict_sub          IS NULL
     AND l_inv_controls_rec.location_control_code IS NULL
     AND l_inv_controls_rec.serial_code           IS NULL THEN
    x_details_required := FALSE;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  END IF;

  -- changing the check to remove null shp qty as details not required.
  -- changing nvl(shp_qty,0) to nvl(shp_qty,-99) so that if shp qty is null
  -- details required will be governed by the item attributes.

  IF (nvl(p_line_inv_rec.shp_qty,-99) = 0 ) THEN
      x_details_required := FALSE;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
  END IF;

  IF (p_line_inv_rec.revision IS NULL) AND (l_inv_controls_rec.rev_flag = 'Y') THEN
	x_details_required := TRUE;
 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    	--
    	-- Debug Statements
    	--
    	IF l_debug_on THEN
    	    WSH_DEBUG_SV.pop(l_module_name);
    	END IF;
    	--
    	RETURN;
  END IF;

  IF (p_line_inv_rec.lot_number IS NULL) AND (l_inv_controls_rec.lot_flag = 'Y' ) THEN
	x_details_required := TRUE;
 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    	--
    	-- Debug Statements
    	--
    	IF l_debug_on THEN
    	    WSH_DEBUG_SV.pop(l_module_name);
    	END IF;
    	--
    	RETURN;
  END IF;
  --
  subinv := p_line_inv_rec.subinventory;
  --
  -- Bug 3599363 : Call default_subinventory() only if the
  -- sub on the line is NULL and the item is transactable
  --
  IF (subinv IS NULL AND
      NVL(l_inv_controls_rec.transactable_flag, 'N') = 'Y') THEN

    l_container_flag := 'N';
    --
    FOR get_line_info_rec IN get_line_info_cur(p_line_inv_rec.delivery_detail_id)
    LOOP
       l_container_flag := NVL(get_line_info_rec.container_flag,'N');
    END LOOP;

    IF l_container_flag = 'N'
    THEN
    --{
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.DEFAULT_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DELIVERY_DETAILS_INV.Default_Subinventory (
				p_line_inv_rec.organization_id,
				p_line_inv_rec.inventory_item_id,
				dft_subinv,
				x_return_status);

	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	   x_details_required := FALSE;
    	   --
    	   -- Debug Statements
    	   --
    	   IF l_debug_on THEN
    	       WSH_DEBUG_SV.pop(l_module_name);
    	   END IF;
    	   --
    	   RETURN;
	END IF;

  	IF ( dft_subinv IS NULL ) THEN
	   x_details_required := TRUE;
 	   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    	   --
    	   -- Debug Statements
    	   --
    	   IF l_debug_on THEN
    	       WSH_DEBUG_SV.pop(l_module_name);
    	   END IF;
    	   --
    	   RETURN;
 	END IF;
    --}
    END IF;

  END IF;

  IF (p_line_inv_rec.locator_id IS NULL) THEN

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.GET_ORG_LOC',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	org_loc_ctl := WSH_DELIVERY_DETAILS_INV.Get_Org_Loc (p_line_inv_rec.organization_id);

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.SUB_LOC_CTL',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	sub_loc_ctl := WSH_DELIVERY_DETAILS_INV.Sub_Loc_Ctl (
					nvl(subinv,dft_subinv),
					p_line_inv_rec.organization_id);

	item_loc_ctl := l_inv_controls_rec.location_control_code;


	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.LOCATOR_CTL_CODE',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	loc_ctl_code := WSH_DELIVERY_DETAILS_INV.Locator_Ctl_Code(
					p_line_inv_rec.organization_id,
					l_inv_controls_rec.restrict_loc,
					org_loc_ctl,
					sub_loc_ctl,
					item_loc_ctl);

	IF ( loc_ctl_code <> 1 ) THEN
          IF ( l_inv_controls_rec.restrict_loc = 1) THEN
            loc_restricted_flag := 'Y';
          ELSE
            loc_restricted_flag := 'N';
          END IF;

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.DEFAULT_LOCATOR',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          dft_loc_id := WSH_DELIVERY_DETAILS_INV.Default_Locator (
					p_line_inv_rec.organization_id,
					p_line_inv_rec.inventory_item_id,
	                                NVL(subinv, dft_subinv),
					loc_restricted_flag);

	  IF ( dft_loc_id IS NULL ) THEN
	     x_details_required := TRUE;
 	     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    	     --
    	     -- Debug Statements
    	     --
    	     IF l_debug_on THEN
    	         WSH_DEBUG_SV.pop(l_module_name);
    	     END IF;
    	     --
    	     RETURN;
	  END IF;
	END IF;
  END IF;

    -- We count on the fact that autodetail will reserve all
    -- inventory control except serial number control

  IF (p_line_inv_rec.serial_number_control_code <> 1) THEN

      -- if serial qty is not passed by the form and is null, then call API
      -- to estimate the serial qty before checking if serial numbers need to
      -- be entered.


      IF p_line_inv_rec.ser_qty IS NULL THEN

	     --
	     -- Debug Statements
	     --
	     IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.GET_SERIAL_QTY',WSH_DEBUG_SV.C_PROC_LEVEL);
	     END IF;
	     --
	     l_ser_qty := WSH_DELIVERY_DETAILS_INV.Get_Serial_Qty (
					p_line_inv_rec.organization_id,
					p_line_inv_rec.delivery_detail_id);

	     IF nvl(l_ser_qty,-99) = -99 THEN
		x_details_required := TRUE;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	     END IF;
      ELSE
	     l_ser_qty := p_line_inv_rec.ser_qty;
      END IF;

      IF (nvl(p_line_inv_rec.shp_qty,0)) > NVL(l_ser_qty, 0) THEN
	     x_details_required := TRUE;
 	     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    	     --
    	     -- Debug Statements
    	     --
    	     IF l_debug_on THEN
    	         WSH_DEBUG_SV.pop(l_module_name);
    	     END IF;
    	     --
    	     RETURN;
      END IF;
      IF (p_line_inv_rec.shp_qty IS NULL AND p_line_inv_rec.serial_number_control_code <> 1 ) THEN
	     x_details_required := TRUE;
 	     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    	     --
    	     -- Debug Statements
    	     --
    	     IF l_debug_on THEN
    	         WSH_DEBUG_SV.pop(l_module_name);
    	     END IF;
    	     --
    	     RETURN;
      END IF;
  END IF;

--  x_details_required := FALSE;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_INV.Details_Required');
        x_details_required := FALSE;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END details_required;


/*
-----------------------------------------------------------------------------
  FUNCTION : Sub_Loc_Ctl
  PARAMETERS : p_subinventory - subinventory
	       x_sub_loc_ctl - locator control code of subinventory
	       x_return_status - return status of API..
  DESCRIPTION : This API takes the subinventory and determines whether the
	 	subinventory is under locator control and returns the locator
		control code for the subinventory.
-----------------------------------------------------------------------------
*/

FUNCTION Sub_Loc_Ctl (
  p_subinventory IN VARCHAR2,
  p_organization_id IN NUMBER ) RETURN NUMBER IS


 l_sub_loc_ctl      NUMBER;
 l_mtl_sec_inv_rec  WSH_DELIVERY_DETAILS_INV.mtl_sec_inv_rec;
 l_return_status    VARCHAR2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SUB_LOC_CTL';
--
BEGIN

 --
 -- Debug Statements
 --
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     --
     WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
     WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
 END IF;
 --

 -- bug 5264874

 Get_Sec_Inv_information(p_organization_id      => p_organization_id
                        , p_subinventory_name   => p_subinventory
                        , x_mtl_sec_inv_rec     => l_mtl_sec_inv_rec
                        , x_return_status       => l_return_status);
 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 l_sub_loc_ctl := l_mtl_sec_inv_rec.locator_type;

IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
   --
   RETURN l_sub_loc_ctl;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
END Sub_Loc_Ctl;


/*
-----------------------------------------------------------------------------
  FUNCTION   : Get_Org_Loc
  PARAMETERS : p_organization_id - organization id of line
  DESCRIPTION : This API takes the organization determines whether the
	 	organization is under locator control and returns the locator
		control code for the organization.
-----------------------------------------------------------------------------
*/


FUNCTION Get_Org_Loc (
 p_organization_id IN NUMBER) RETURN NUMBER IS

l_mtl_org_param_rec     WSH_DELIVERY_DETAILS_INV.mtl_org_param_rec;
l_org_loc_ctl           NUMBER;
l_return_status         VARCHAR2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ORG_LOC';
--
BEGIN

 --
 -- Debug Statements
 --
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
 END IF;
 --

 -- bug 5264874

Get_Org_Param_information (
  p_organization_id    =>     p_organization_id
, x_mtl_org_param_rec  =>     l_mtl_org_param_rec
, x_return_status      =>     l_return_status);

IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
END IF;

l_org_loc_ctl := l_mtl_org_param_rec.stock_locator_control_code;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_org_loc_ctl',l_org_loc_ctl);
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;
 --
 RETURN l_org_loc_ctl;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

END Get_Org_Loc;


/*
-----------------------------------------------------------------------------
  PROCEDURE   : Default_Subinventory
  PARAMETERS  : p_org_id - organization_id
 	        p_inv_item_id - inventory_item_id on the line
	        x_default_sub - default subinventory for the item/org
	        x_return_status - return status of the API
  DESCRIPTION : Get Default Sub for this item/org if it is defined else it
		returns null.
-----------------------------------------------------------------------------
*/

PROCEDURE Default_Subinventory (
  p_org_id IN NUMBER,
  p_inv_item_id IN NUMBER,
  x_default_sub OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2) IS

  CURSOR Default_Sub IS
  SELECT mtlsub.secondary_inventory_name
  FROM   mtl_item_sub_defaults mtlisd,
    	 mtl_secondary_inventories mtlsub
  WHERE  mtlisd.inventory_item_id = p_inv_item_id
  AND mtlisd.organization_id = p_org_id
  AND mtlisd.default_type = 1
  AND mtlsub.organization_id = mtlisd.organization_id
  AND mtlsub.secondary_inventory_name = mtlisd.subinventory_code
  AND mtlsub.quantity_tracked = 1
  AND trunc(sysdate) <= nvl( mtlsub.disable_date, trunc(sysdate));

  l_dflt_sub VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEFAULT_SUBINVENTORY';
--
BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',P_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INV_ITEM_ID',P_INV_ITEM_ID);
   END IF;
   --
   OPEN  Default_Sub;
   FETCH Default_Sub into l_dflt_sub;

   IF Default_Sub%NOTFOUND THEN
	CLOSE Default_Sub;
	x_default_sub := NULL;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   END IF;

   IF Default_Sub%ISOPEN THEN
   	CLOSE Default_Sub;
   END IF;

   x_default_sub := l_dflt_sub;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_INV.Default_Subinventory');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Default_Subinventory;


/*
-----------------------------------------------------------------------------
  FUNCTION    : DEFAULT_LOCATOR
  PARAMETERS  : p_organization_id - input org id
  		p_inv_item_id - input item_id
  		p_subinventory - input sub id
  		p_loc_restricted_flag - Y or N. If Y will ensure location is
		in predefined list
  		x_locator_id -  output default locator id.
		x_return_status - return status of API.
  DESCRIPTION : Retrieves default locator. If none exists then it returns null.
-----------------------------------------------------------------------------
*/


FUNCTION DEFAULT_LOCATOR
	(p_organization_id IN NUMBER,
	 p_inv_item_id IN NUMBER,
         p_subinventory IN VARCHAR2,
         p_loc_restricted_flag IN VARCHAR2) RETURN NUMBER IS

CURSOR Default_Locator IS
SELECT mtldl.locator_id
FROM   mtl_item_loc_defaults mtldl
WHERE  mtldl.inventory_item_id = p_inv_item_id
    and    mtldl.organization_id = p_organization_id
    and    mtldl.default_type = 1
    and    mtldl.subinventory_code = p_subinventory
    and   (  nvl(p_loc_restricted_flag, 'N') = 'N'
	   OR
	     (nvl(p_loc_restricted_flag, 'N') = 'Y'
	      and nvl(mtldl.locator_id, -1) in
		   (select mtlsls.secondary_locator
		    from   mtl_secondary_locators mtlsls
		    where  mtlsls.organization_id = p_organization_id
		    and    mtlsls.inventory_item_id = p_inv_item_id
		    and    mtlsls.subinventory_code = p_subinventory)));

 dflt_locator_id	NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEFAULT_LOCATOR';
--
BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INV_ITEM_ID',P_INV_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
       WSH_DEBUG_SV.log(l_module_name,'P_LOC_RESTRICTED_FLAG',P_LOC_RESTRICTED_FLAG);
   END IF;
   --
   OPEN Default_Locator;
   FETCH Default_Locator INTO dflt_locator_id;

   IF Default_Locator%NOTFOUND THEN
   	CLOSE Default_Locator;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN NULL;
   END IF;

   IF Default_Locator%ISOPEN THEN
	CLOSE Default_Locator;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN (dflt_locator_id);

END default_locator;


/*
-----------------------------------------------------------------------------
  FUNCTION    : Locator_Ctl_Code
  PARAMETERS  : p_organization_id - input org id
		p_restrict_loc - restrict locators code
  		p_org_loc_code - loc control code for org
  		p_sub_loc_code - loc control code for sub
  		p_item_loc_code - loc control code for item
  DESCRIPTION : Determines the locator control code based on the three loc
		control codes and returns the governing loc control code.
-----------------------------------------------------------------------------
*/


FUNCTION Locator_Ctl_Code (
		p_org_id IN NUMBER,
		p_restrict_loc IN NUMBER,
		p_org_loc_code  IN NUMBER,
		p_sub_loc_code  IN NUMBER,
		p_item_loc_code IN NUMBER ) RETURN NUMBER IS


 prespecified 	CONSTANT NUMBER := 2;
 dynamic	CONSTANT NUMBER := 3;

 l_neg_inv_code NUMBER;
 l_mtl_org_param_rec     WSH_DELIVERY_DETAILS_INV.mtl_org_param_rec;
 l_return_status         VARCHAR2(1);
 --
 l_debug_on BOOLEAN;
 --
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCATOR_CTL_CODE';
 --
BEGIN


  -- Hverddin 12-SEP-2000 OPM Start Of Changes

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',P_ORG_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_RESTRICT_LOC',P_RESTRICT_LOC);
      WSH_DEBUG_SV.log(l_module_name,'P_ORG_LOC_CODE',P_ORG_LOC_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_SUB_LOC_CODE',P_SUB_LOC_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_ITEM_LOC_CODE',P_ITEM_LOC_CODE);
  END IF;
  --
  --
  -- Debug Statements
  --
-- HW OPMCONV. Removed code forking

    -- bug 5264874
  Get_Org_Param_information (
  p_organization_id    =>     p_org_id
, x_mtl_org_param_rec  =>     l_mtl_org_param_rec
, x_return_status      =>     l_return_status);

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_neg_inv_code := l_mtl_org_param_rec.negative_inv_receipt_code;

  IF ( NVL(p_org_loc_code, 4) <> 4 ) THEN
      -- honor ORG level locator control
     IF ( p_org_loc_code <> 3 ) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN p_org_loc_code;
     ELSE
	-- p_org_loc_code = 3 : Dynamic entry locator control

	IF (p_restrict_loc = 1) THEN
  	  -- restrictive to pre-defined list then return Prespecified
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN prespecified;
        ELSIF (l_neg_inv_code = 1) THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN dynamic;
	ELSE
	  -- not allow negative balance in this organization therefore
	  -- can not create locator dynamically for issue
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN prespecified;
	END IF;
      END IF;
    ELSIF ( NVL(p_sub_loc_code, 5) <> 5 ) THEN
      -- honor SUB level locator control code

      IF ( p_sub_loc_code <> 3 ) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN p_sub_loc_code;
      ELSE
	-- p_sub_loc_code = 3 : Dynamic entry locator control
	IF ( p_restrict_loc = 1) THEN
  	  -- restrictive to pre-defined list then return Prespecified
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN prespecified;
        ELSIF (l_neg_inv_code = 1) THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN dynamic;
	ELSE
	  -- not allow negative balance in this organization therefore
	  -- can not create locator dynamically for issue
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN prespecified;
	END IF;
      END IF;
    ELSE
      -- use item level locator control code

      IF ( NVL(p_item_loc_code, 1) <> 3 ) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN p_item_loc_code;
      ELSE
	-- p_item_loc_code = 3 : Dynamic entry locator control
	IF ( p_restrict_loc = 1) THEN
  	  -- restrictive to pre-defined list then return Prespecified
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN prespecified;
        ELSIF (l_neg_inv_code = 1) THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN dynamic;
	ELSE
	  -- not allow negative balance in this organization therefore
	  -- can not create locator dynamically for issue
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN prespecified;
	END IF;
      END IF;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

    WHEN others THEN
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Locator_Ctl_Code');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Locator_Ctl_Code;



/*
-----------------------------------------------------------------------------
  PROCEDURE   : Mark_Serial_Number
  PARAMETERS  : p_delivery_detail_id - delivery detail id or container id
		p_serial_number - serial number in case of single quantity
		p_transaction_temp_id - transaction temp id for multiple
		quantity of serial numbers.
	        x_return_status - return status of the API
  DESCRIPTION : Call Inventory's serial number mark API.
                - frontport bug 5028993 : change from here
                - before fix : Uses the delivery
		  detail id as the group mark id, temp lot id and temp id to
		  identify the serial numbers in mtl serial numbers.
                - after fix : When serial_number is
                  not null, use the transaction_temp_id created by using the
                  sequence mtl_material_transactions_s as group_mark_id.
                - frontport bug 5028993 : change to here
                If the qty
		is greater than 1, then it uses the transaction temp id to
		fetch all the serial number ranges and then calls the mark API
		for each of the ranges.
-----------------------------------------------------------------------------
*/

PROCEDURE Mark_Serial_Number (
  p_delivery_detail_id IN NUMBER,
  p_serial_number IN VARCHAR2,
  p_transaction_temp_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR Fetch_Detail_Info IS
SELECT Inventory_Item_Id, Organization_Id
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = p_delivery_detail_id;

CURSOR Fetch_Serial_Ranges IS
SELECT Fm_Serial_Number, To_Serial_Number,
       Serial_Prefix
FROM   MTL_SERIAL_NUMBERS_TEMP
WHERE transaction_temp_id = p_transaction_temp_id;

-- Bug 5028993: needs to pass transaction_temp_id
CURSOR c_temp_id IS
SELECT mtl_material_transactions_s.nextval
FROM   dual;

l_inv_item_id NUMBER;
l_org_id NUMBER;
l_transaction_temp_id NUMBER;

l_success NUMBER;
l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MARK_SERIAL_NUMBER';
--
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_NUMBER',P_SERIAL_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TEMP_ID',P_TRANSACTION_TEMP_ID);
  END IF;
  --
  OPEN Fetch_Detail_Info;

  FETCH Fetch_Detail_Info INTO l_inv_item_id, l_org_id;

  IF Fetch_Detail_Info%NOTFOUND THEN
	CLOSE Fetch_Detail_Info;
	FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_ID');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF Fetch_Detail_Info%ISOPEN THEN
	CLOSE Fetch_Detail_Info;
  END IF;

  IF p_serial_number IS NOT NULL AND p_transaction_temp_id IS NOT NULL THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_DET_TRX_SERIAL_INVALID');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF p_serial_number IS NOT NULL THEN

        -- bug 5028993: needs to pass transaction_temp_id
        OPEN  c_temp_id;
        FETCH c_temp_id INTO  l_transaction_temp_id;
        IF c_temp_id%NOTFOUND THEN
        --{
           CLOSE c_temp_id;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            --
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Return Status is error',x_return_status);
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           return;
        --}
        END IF;
        CLOSE c_temp_id;
        --
        -- bug 5028993: End

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'transaction_temp_id',l_transaction_temp_id);
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit SERIAL_CHECK.INV_MARK_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
        -- bug 5028993
        -- if serial_number is not null, while calling mark_serial,
        -- need to use l_transaction_temp_id and not the delivery_detail_id
	Serial_Check.Inv_Mark_Serial(
			p_serial_number,
			p_serial_number,
			l_inv_item_id,
			l_org_id,
			l_transaction_temp_id,
			NULL,
			NULL,
			l_success);


	IF l_success < 0 THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_SERIAL_MARK_ERROR');
		FND_MESSAGE.SET_TOKEN('SERIAL_NUM',p_serial_number);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;

  END IF;

  IF p_transaction_temp_id IS NOT NULL THEN

	FOR c IN Fetch_Serial_Ranges LOOP
	EXIT WHEN Fetch_Serial_Ranges%NOTFOUND;

		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit SERIAL_CHECK.INV_MARK_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
                -- Fix for bug 2762219.
                -- if transaction_Temp_id is not null, while calling mark_serial,
                -- need to Use p_transaction_Temp_id and not the delivery_detail_id
		Serial_Check.Inv_Mark_Serial(
			c.fm_serial_number,
			c.to_serial_number,
			l_inv_item_id,
			l_org_id,
			p_transaction_temp_id, -- Fix for Bug 2762219.
			p_transaction_temp_id,
			p_transaction_temp_id,
			l_success);

		IF l_success < 0 THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_SER_RANGE_MK_ERROR');
			FND_MESSAGE.SET_TOKEN('FM_SERIAL',c.fm_serial_number);
			FND_MESSAGE.SET_TOKEN('TO_SERIAL',c.to_serial_number);
			l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			WSH_UTIL_CORE.Add_Message(l_return_status);
		END IF;

	END LOOP;

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
EXCEPTION

    WHEN OTHERS THEN
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Mark_Serial_Number');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Mark_Serial_Number;


/*
-----------------------------------------------------------------------------
  PROCEDURE   : Unmark_Serial_Number
  PARAMETERS  : p_delivery_detail_id - delivery detail id or container id
		p_serial_number_code - serial number code for the inventory
		item on the line.
		p_serial_number - serial number in case of single quantity
		p_transaction_temp_id - transaction temp id for multiple
		quantity of serial numbers.
	        x_return_status - return status of the API
	        p_inventory_item_id - inventory item
  DESCRIPTION : Call Inventory's serial number unmark API.
                Inventory needs only the serial number (From and To) and
                the inventory_item_id to unmark the Serial Number. All other
                parameters are passed as Null to the api.
		If the qty is greater than 1, then it uses the transaction
                temp id to fetch all the serial number ranges and then
                calls the ummark API for each of the ranges.
-----------------------------------------------------------------------------
*/

PROCEDURE Unmark_Serial_Number (
  p_delivery_detail_id IN NUMBER,
  p_serial_number_code IN NUMBER,
  p_serial_number IN VARCHAR2,
  p_transaction_temp_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  p_inventory_item_id IN NUMBER DEFAULT NULL) IS

CURSOR Fetch_Serial_Ranges IS
SELECT Fm_Serial_Number, To_Serial_Number,
       Serial_Prefix
FROM   MTL_SERIAL_NUMBERS_TEMP
WHERE transaction_temp_id = p_transaction_temp_id
FOR UPDATE OF fm_serial_number NOWAIT;

CURSOR Fetch_Item IS
SELECT inventory_item_id
FROM   wsh_delivery_details
WHERE  delivery_detail_id = p_delivery_detail_id;

l_success            NUMBER;
l_inventory_item_id  NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNMARK_SERIAL_NUMBER';
--
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_NUMBER_CODE',P_SERIAL_NUMBER_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_NUMBER',P_SERIAL_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TEMP_ID',P_TRANSACTION_TEMP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
  END IF;
  --
  IF p_serial_number_code IS NULL OR p_serial_number_code = 1 THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_SER_CODE_UNMARK');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF p_serial_number IS NOT NULL AND p_transaction_temp_id IS NOT NULL THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_DET_TRX_SERIAL_INVALID');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF p_inventory_item_id IS NULL THEN
     OPEN  Fetch_Item;
     FETCH Fetch_Item INTO l_inventory_item_id;
     CLOSE Fetch_Item;
  ELSE
     l_inventory_item_id := p_inventory_item_id;
  END IF;

  IF p_serial_number IS NOT NULL THEN

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit SERIAL_CHECK.INV_UNMARK_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        Serial_Check.Inv_Unmark_Serial(
                        p_serial_number,
                        p_serial_number,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        l_inventory_item_id);

     --Bugfix 8517694  Start - Deleting the unmarked serial numbers of "Sales Order issue" types so as make them available for different Items.
        IF p_serial_number_code = 6 THEN
          DELETE FROM mtl_serial_numbers
           WHERE inventory_item_id = l_inventory_item_id
             AND current_status = 6
             AND (group_mark_id IS NULL or group_mark_id = -1);
        END IF;
     --Bugfix 8517694  End

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;

  END IF;

  IF p_transaction_temp_id IS NOT NULL THEN

	FOR c IN Fetch_Serial_Ranges LOOP
	EXIT WHEN Fetch_Serial_Ranges%NOTFOUND;

	-- if transaction temp id is not null it means that the number of
	-- serial numbers entered is greater than 1. this also implies that
	-- serial numbers were entered using the serial entry window
	-- it seems like the serial entry window uses the transaction temp id
	-- to mark the serial numbers as compared to the delivery detail id
	-- used when the mark is called with a single serial number. so use
	-- the transaction temp id to unmark.

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit SERIAL_CHECK.INV_UNMARK_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               Serial_Check.Inv_Unmark_Serial(
                                c.fm_Serial_number ,
                                c.to_Serial_number ,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                l_inventory_item_id);

	END LOOP;

	DELETE FROM MTL_SERIAL_NUMBERS_TEMP
	WHERE transaction_temp_id = p_transaction_temp_id;

	IF SQLCODE <> 0 THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_SER_TEMP_CLEAR_ERROR');
	    	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;

    --Bugfix 8517694  Start -  Deleting the unmarked serial numbers of "Sales Order issue" types so as make them available for different Items.
        IF p_serial_number_code = 6 THEN
           DELETE FROM mtl_serial_numbers
            WHERE inventory_item_id = l_inventory_item_id
              AND current_status = 6
              AND (group_mark_id IS NULL or group_mark_id = -1);
        END IF;
    --Bugfix 8517694  End

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;

  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
EXCEPTION

    WHEN OTHERS THEN
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Unmark_Serial_Number');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Unmark_Serial_Number;



/*
-----------------------------------------------------------------------------

    Procedure	: validate_locator
    Parameters	: p_locator_id
                  p_inventory_item
		  p_sub
		  p_transaction_type_id
                  p_object_type
    Description	: This function returns a boolean value to
                  indicate if the locator is valid in the context of inventory
                  and subinventory

-----------------------------------------------------------------------------
*/


PROCEDURE Validate_Locator(
  p_locator_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_subinventory IN VARCHAR2,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN) IS

l_locator          INV_VALIDATE.Locator;
l_result           NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_LOCATOR';
--
BEGIN
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
	    WSH_DEBUG_SV.log(l_module_name,'p_transaction_type_id',p_transaction_type_id);
	    WSH_DEBUG_SV.log(l_module_name,'p_object_type',p_object_type);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	g_org.organization_id := p_organization_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.ORGANIZATION',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := INV_VALIDATE.organization(g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Organization');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;
   g_item.inventory_item_id := p_inventory_item_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.INVENTORY_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := wsh_delivery_details_inv.inventory_item(
		p_item 	 => g_item,
		p_org     => g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Item');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;

	g_sub.secondary_inventory_name := p_subinventory;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.FROM_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := INV_VALIDATE.From_subinventory(
		p_sub       => g_sub,
		p_item 	   => g_item,
		p_org     	=> g_org,
		p_trx_type_id => p_transaction_type_id,
		p_object_type => p_object_type ,
		p_acct_txn  => 0);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Subinventory');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;
	l_locator.inventory_location_id := p_locator_id;

  	--
  	-- Debug Statements
  	--
  	IF l_debug_on THEN
  	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.VALIDATELOCATOR',WSH_DEBUG_SV.C_PROC_LEVEL);
  	END IF;
  	--
	IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
    	   l_result := INV_VALIDATE.ValidateLocator(
				   	        p_locator        => l_locator,
						p_org            => g_org,
						p_sub            => g_sub,
						p_item           => g_item,
						p_trx_type_id => p_transaction_type_id,
						p_object_type => p_object_type);
        ELSE
  	   l_result := INV_VALIDATE.ValidateLocator(
				   	        p_locator        => l_locator,
						p_org            => g_org,
						p_sub            => g_sub,
						p_item           => g_item);
	END IF;
	IF (l_result = INV_VALIDATE.T) THEN
		x_result := TRUE;
	ELSE
		x_result := FALSE;
	END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Validate_locator');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Locator;


/*
-----------------------------------------------------------------------------

   Procedure	: 	Validate_Revision
   Parameters	: 	p_revision
                  p_organization_id
  		  				p_inventory_item_id
                  x_return_status
   Description	: Validate item in context of organization_id
  		  Return TRUE if validate item successfully
  		  FALSE otherwise
-----------------------------------------------------------------------------
*/


PROCEDURE Validate_Revision(
  p_revision IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN ) IS

l_result   			NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_REVISION';
--
BEGIN
   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   g_org.organization_id := p_organization_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.ORGANIZATION',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := INV_VALIDATE.organization(g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Organization');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;
   g_item.inventory_item_id := p_inventory_item_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.INVENTORY_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := wsh_delivery_details_inv.inventory_item(
		p_item 	 => g_item,
		p_org     => g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Item');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.REVISION',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_result := INV_VALIDATE.Revision(
		p_revision      =>      p_revision,
		p_org           =>      g_org,
		p_item          =>      g_item);

   IF (l_result = INV_VALIDATE.T) THEN
	x_result := TRUE;
   ELSE
	x_result := FALSE;
   END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Validate_revision');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Revision;


/*
-----------------------------------------------------------------------------

   Procedure	: Validate_Subinventory
   Parameters	: p_subinventory
                  p_organization_id
  	  	  p_inventory_item_id
		  p_transaction_type_id
		  p_object_type
		  x_return_status
                  p_to_subinventory
   Description	: Validate item in context of organization_id
  		  Return TRUE if validate item successfully
  		  FALSE otherwise
                  p_to_subinventory is defaulted to NULL, if it is NULL
                  p_subinventory will be validated as from_subinventory.
                  Else, p_to_subinventory will be validated as to_subinvnetory.

-----------------------------------------------------------------------------
*/


PROCEDURE Validate_Subinventory(
  p_subinventory IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN,
  p_to_subinventory IN VARCHAR2 DEFAULT NULL) IS

l_result   			NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SUBINVENTORY';
--
BEGIN
   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_TO_SUBINVENTORY',P_TO_SUBINVENTORY);
       WSH_DEBUG_SV.log(l_module_name,'p_transaction_type_id',p_transaction_type_id);
       WSH_DEBUG_SV.log(l_module_name,'p_object_type',p_object_type);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   g_org.organization_id := p_organization_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.ORGANIZATION',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := INV_VALIDATE.organization(g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Organization');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;
   g_item.inventory_item_id := p_inventory_item_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.INVENTORY_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := wsh_delivery_details_inv.inventory_item(
		p_item 	 => g_item,
		p_org     => g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Item');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;
   g_sub.secondary_inventory_name := p_subinventory;

   IF p_to_subinventory IS NULL THEN

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.FROM_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
     l_result := INV_VALIDATE.from_subinventory(
		p_sub	       =>      g_sub,
		p_org        =>      g_org,
		p_item       =>      g_item,
		p_trx_type_id => p_transaction_type_id,
		p_object_type => p_object_type,
		p_acct_txn   => 		0);
     ELSE
     l_result := INV_VALIDATE.from_subinventory(
		p_sub	       =>      g_sub,
		p_org        =>      g_org,
		p_item       =>      g_item,
		p_acct_txn   => 		0);
     END IF;
     IF (l_result = INV_VALIDATE.T) THEN
	x_result := TRUE;
     ELSE
	x_result := FALSE;
     END IF;

   ELSE

     g_to_sub.secondary_inventory_name := p_to_subinventory;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.TO_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
     l_result := INV_VALIDATE.to_subinventory(
                p_sub          =>      g_to_sub,
                p_org        =>      g_org,
                p_item       =>      g_item,
                p_from_sub   =>      g_sub,
		p_trx_type_id => p_transaction_type_id,
		p_object_type => p_object_type,
                p_acct_txn   =>                 0);
      ELSE
     l_result := INV_VALIDATE.to_subinventory(
                p_sub          =>      g_to_sub,
                p_org        =>      g_org,
                p_item       =>      g_item,
                p_from_sub   =>      g_sub,
                p_acct_txn   =>                 0);
      END IF;

     IF (l_result = INV_VALIDATE.T) THEN
        x_result := TRUE;
     ELSE
        x_result := FALSE;
     END IF;

   END IF;



    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION

  WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Validate_subinventory');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Subinventory;


/*
-----------------------------------------------------------------------------

   Procedure	: Validate_Lot_Number
   Parameters	: p_lot_number
                  p_organization_id
  		  p_inventory_item_id
                  p_subinventory
  		  p_revision
                  p_locator_id
		  p_transaction_type_id
                  p_object_type
                  x_return_status
   Description	: Validate item in context of organization_id
  		  Return TRUE if validate item successfully
  		  FALSE otherwise
-----------------------------------------------------------------------------
*/


PROCEDURE Validate_Lot_Number(
  p_lot_number IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_subinventory IN VARCHAR2,
  p_revision IN VARCHAR2,
  p_locator_id IN NUMBER,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN) IS

l_result   			NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_LOT_NUMBER';
--
BEGIN
   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
       WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_transaction_type_id',p_transaction_type_id);
       WSH_DEBUG_SV.log(l_module_name,'p_object_type',p_object_type);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   g_org.organization_id := p_organization_id;
   g_item.inventory_item_id := p_inventory_item_id;
   g_loc.inventory_location_id := p_locator_id;
   g_lot.lot_number := p_lot_number;
   g_sub.secondary_inventory_name := p_subinventory;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.ORGANIZATION',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := INV_VALIDATE.organization(g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Organization');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;

   g_item.inventory_item_id := p_inventory_item_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.INVENTORY_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := wsh_delivery_details_inv.inventory_item(
		p_item 	 => g_item,
		p_org     => g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Item');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;

   g_sub.secondary_inventory_name := p_subinventory;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.FROM_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
	l_result := INV_VALIDATE.From_Subinventory(
		p_org 	 	=> g_org,
		p_sub     	=> g_sub,
		p_item    	=> g_item,
		p_trx_type_id   => p_transaction_type_id,
        	p_object_type => p_object_type,
		p_acct_txn  => 1);
        ELSE
	l_result := INV_VALIDATE.From_Subinventory(
		p_org 	 	=> g_org,
		p_sub     	=> g_sub,
		p_item    	=> g_item,
		p_acct_txn  => 1);
	END IF;
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Locator');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN;
	END IF;

   g_loc.inventory_location_id := p_locator_id;
	IF (p_locator_id IS NOT NULL) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.VALIDATELOCATOR',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
	l_result := INV_VALIDATE.validateLocator(
		p_locator => g_loc,
		p_org 	 => g_org,
		p_sub     => g_sub,
		p_trx_type_id   => p_transaction_type_id,
        	p_object_type => p_object_type,
		p_item    => g_item);
        ELSE
	l_result := INV_VALIDATE.validateLocator(
		p_locator => g_loc,
		p_org 	 => g_org,
		p_sub     => g_sub,
		p_item    => g_item);
	END IF;
	IF (l_result = INV_VALIDATE.F) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Locator');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN;
	END IF;
	END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.LOT_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
   l_result := INV_VALIDATE.lot_number(
		p_lot           =>      g_lot,
		p_org           =>      g_org,
		p_item          =>      g_item,
		p_from_sub      =>      g_sub,
		p_loc           =>      g_loc,
		p_trx_type_id   => p_transaction_type_id,
        	p_object_type => p_object_type,
		p_revision      =>      p_revision);
   ELSE
   l_result := INV_VALIDATE.lot_number(
		p_lot           =>      g_lot,
		p_org           =>      g_org,
		p_item          =>      g_item,
		p_from_sub      =>      g_sub,
		p_loc           =>      g_loc,
		p_revision      =>      p_revision);
   END IF;

   IF (l_result = INV_VALIDATE.T) THEN
	x_result := TRUE;
   ELSE
	x_result := FALSE;
   END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Validate_lot_number');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_lot_number;


/*
-----------------------------------------------------------------------------

   Procedure	: Validate_Serial
   Parameters	: p_serial_number
                  p_lot_number
                  p_organization_id
  		  p_inventory_item_id
                  p_subinventory
  		  p_revision
                  p_locator_id
		  p_transaction_type_id
                  p_object_type
		  x_return_status
   Description	: Validate serial in context of organization_id
  		  Return TRUE if validate item successfully
  		  FALSE otherwise
-----------------------------------------------------------------------------
*/
PROCEDURE Validate_Serial(
  p_serial_number IN VARCHAR2,
  p_lot_number IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_subinventory IN VARCHAR2,
  p_revision IN VARCHAR2,
  p_locator_id IN NUMBER,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN) IS

l_result   			NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SERIAL';
--
BEGIN
   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_NUMBER',P_SERIAL_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
       WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_transaction_type_id',p_transaction_type_id);
       WSH_DEBUG_SV.log(l_module_name,'p_object_type',p_object_type);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   g_org.organization_id := p_organization_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.ORGANIZATION',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := INV_VALIDATE.organization(g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Organization');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN;
	END IF;
   g_item.inventory_item_id := p_inventory_item_id;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.INVENTORY_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_result := wsh_delivery_details_inv.inventory_item(
		p_item 	 => g_item,
		p_org     => g_org);
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Item');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN;
	END IF;

   g_sub.secondary_inventory_name := p_subinventory;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.FROM_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
       IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
	l_result := INV_VALIDATE.From_Subinventory(
		p_org 	 	=> g_org,
		p_sub     	=> g_sub,
		p_item    	=> g_item,
		p_trx_type_id   => p_transaction_type_id,
        	p_object_type => p_object_type,
		p_acct_txn  => 1);
       ELSE
	l_result := INV_VALIDATE.From_Subinventory(
		p_org 	 	=> g_org,
		p_sub     	=> g_sub,
		p_item    	=> g_item,
		p_acct_txn  => 1);
       END IF;
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Locator');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN;
	END IF;

   g_loc.inventory_location_id := p_locator_id;
	-- Need to check if locator is NULL cause inventory validation API will
	-- validate on flex field and return false when locator is NULL
	IF (p_locator_id IS NOT NULL) THEN
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.VALIDATELOCATOR',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
                IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
		l_result := INV_VALIDATE.validateLocator(
			p_locator => g_loc,
			p_org 	 => g_org,
			p_sub     => g_sub,
			p_trx_type_id   => p_transaction_type_id,
	        	p_object_type => p_object_type,
			p_item    => g_item);
               ELSE
		l_result := INV_VALIDATE.validateLocator(
			p_locator => g_loc,
			p_org 	 => g_org,
			p_sub     => g_sub,
			p_item    => g_item);
	       END IF;
		IF (l_result = INV_VALIDATE.F) THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
			FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Locator');
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			WSH_UTIL_CORE.Add_Message(x_return_status);
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			--
			RETURN;
		END IF;
	END IF;

   g_lot.lot_number := p_lot_number;
	IF (p_lot_number IS NOT NULL) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.LOT_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
        IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
	l_result := INV_VALIDATE.Lot_Number(
		p_lot     		=> g_lot,
		p_org 	 		=> g_org,
		p_item	 		=> g_item,
		p_from_sub     => g_sub,
		p_trx_type_id   => p_transaction_type_id,
        	p_object_type => p_object_type,
		p_loc 			=> g_loc,
		p_revision     => p_revision);
        ELSE
	l_result := INV_VALIDATE.Lot_Number(
		p_lot     		=> g_lot,
		p_org 	 		=> g_org,
		p_item	 		=> g_item,
		p_from_sub     => g_sub,
		p_loc 			=> g_loc,
		p_revision     => p_revision);
	END IF;
	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Locator');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN;
	END IF;
	END IF;
   g_serial.serial_number := p_serial_number;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.VALIDATE_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
   l_result := INV_VALIDATE.Validate_serial(
	p_serial        =>      g_serial,
	p_lot           =>      g_lot,
	p_org           =>      g_org,
	p_item          =>      g_item,
	p_from_sub      =>      g_sub,
	p_loc           =>      g_loc,
	p_trx_type_id   => p_transaction_type_id,
       	p_object_type => p_object_type,
	p_revision      =>      p_revision);
   ELSE
   l_result := INV_VALIDATE.Validate_serial(
	p_serial        =>      g_serial,
	p_lot           =>      g_lot,
	p_org           =>      g_org,
	p_item          =>      g_item,
	p_from_sub      =>      g_sub,
	p_loc           =>      g_loc,
	p_revision      =>      p_revision);
   END IF;

   IF (l_result = INV_VALIDATE.T) THEN
		x_result := TRUE;
   ELSE
		x_result := FALSE;
   END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION

   WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Validate_Serial');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Serial;


/*
-----------------------------------------------------------------------------
  PROCEDURE   : Update_Locator_Subinv
  PARAMETERS  : p_organization_id - organization id for the delivery detail
		p_locator_id - locator id for the delivery detail
		-1 if dynamic insert and 1 if pre-defined.
		p_subinventory - subinventory for the delivery detail
	        x_return_status - return status of the API
  DESCRIPTION : This procedure takes in the inventory location id (locator id),
		subinventory and org for the delivery detail and validates if
		the locator id exists for the given organization and location.
		If it can find it then it raises a duplicate locator exception,
		else it updates the mtl item locations table with the
		input subinventory for the given locator id and organization.
-----------------------------------------------------------------------------
*/

PROCEDURE Update_Locator_Subinv (
 p_organization_id IN NUMBER,
 p_locator_id IN NUMBER,
 p_subinventory IN VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2) IS


CURSOR Check_Dup_Loc IS
SELECT 'Exist'
FROM Mtl_Item_Locations
WHERE organization_id = p_organization_id
AND inventory_location_id = p_locator_id
AND subinventory_code IS NOT NULL
AND subinventory_code <> p_subinventory;

l_temp 	VARCHAR2(240);
l_org_id 	NUMBER;
l_loc_id 	NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_LOCATOR_SUBINV';
--
BEGIN

 --
 -- Debug Statements
 --
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     --
     WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
 END IF;
 --
 OPEN Check_Dup_Loc;
 FETCH Check_Dup_Loc INTO l_temp;

 IF ( Check_Dup_Loc%FOUND) THEN

    IF (Check_Dup_Loc%ISOPEN) THEN
       CLOSE Check_Dup_Loc;
    END IF;

    FND_MESSAGE.SET_NAME('WSH','WSH_INV_DUP_LOCATOR');
    FND_MESSAGE.SET_TOKEN('SUBINV',p_subinventory);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    l_temp := WSH_UTIL_CORE.Get_Org_Name(p_organization_id);
    FND_MESSAGE.SET_TOKEN('ORG_NAME',l_temp);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.Add_Message(x_return_status);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;

 END IF;

 IF (Check_Dup_Loc%ISOPEN) THEN
      CLOSE Check_Dup_Loc;
 END IF;

 UPDATE Mtl_Item_Locations
 SET subinventory_code = p_subinventory
 WHERE organization_id = p_organization_id
 AND inventory_location_id = p_locator_id;

 IF SQL%NOTFOUND THEN
	FND_MESSAGE.SET_NAME('FND','SQLERRM');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
 	--
 	-- Debug Statements
 	--
 	IF l_debug_on THEN
 	    WSH_DEBUG_SV.pop(l_module_name);
 	END IF;
 	--
 	return;
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

    WHEN OTHERS THEN
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Update_Locator_Subinv');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Locator_Subinv;


/*
-----------------------------------------------------------------------------
  FUNCTION    : Get_Serial_Qty
  PARAMETERS  : p_organization_id - organization id of line
	        p_delivery_detail_id - delivery detail id for the line
  DESCRIPTION :	This API takes the organization and delivery detail id for
		the line and calculates the serial quantity for the line
		based on the transaction temp id/serial number that is
		entered for the line. If the item is not under serial control
		then it returns a 0. If it is an invalid delivery detail id
		then it returns a -99.
-----------------------------------------------------------------------------
*/

FUNCTION Get_Serial_Qty (
 p_organization_id IN NUMBER,
 p_delivery_detail_id IN NUMBER) RETURN NUMBER IS

CURSOR Get_Ser_Qty (v_trx_temp_id NUMBER) IS
SELECT sum (serial_prefix)
FROM MTL_SERIAL_NUMBERS_TEMP
WHERE transaction_temp_id = nvl(v_trx_temp_id,transaction_temp_id);

CURSOR Get_Detail_Info IS
SELECT transaction_temp_id, inventory_item_id, shipped_quantity,
       organization_id, serial_number
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = p_delivery_detail_id;

l_trx_id	NUMBER;
l_ser_num	VARCHAR2(30);
l_org_id	NUMBER;
l_inv_item_id	NUMBER;

l_shp_qty	NUMBER;

l_ser_qty	NUMBER := 0;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SERIAL_QTY';
--
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
  END IF;
  --
  IF p_delivery_detail_id IS NULL THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	l_ser_qty := -99;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return l_ser_qty;
  END IF;

  OPEN Get_Detail_Info;

  FETCH Get_Detail_Info INTO
	l_trx_id,
	l_inv_item_id,
	l_shp_qty,
	l_org_id,
	l_ser_num;

  IF Get_Detail_Info%NOTFOUND THEN
	CLOSE Get_Detail_Info;
	FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	l_ser_qty := -99;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return l_ser_qty;
  END IF;

  IF Get_Detail_Info%ISOPEN THEN
	CLOSE Get_Detail_Info;
  END IF;

  IF l_ser_num IS NOT NULL AND l_shp_qty = 1 THEN
	l_ser_qty := 1;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return l_ser_qty;
  END IF;

  IF l_trx_id IS NOT NULL AND l_ser_num IS NOT NULL THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TRX_ID');
	WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	l_ser_qty := -99;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return l_ser_qty;
  END IF;

  IF l_trx_id IS NOT NULL AND nvl(l_shp_qty,0) < 1 THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TRX_ID');
	WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	l_ser_qty := -99;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return l_ser_qty;
  END IF;

  IF l_trx_id IS NOT NULL THEN

	OPEN Get_Ser_Qty(l_trx_id);

	FETCH Get_Ser_Qty INTO l_ser_qty;

	IF Get_Ser_Qty%NOTFOUND THEN
		CLOSE Get_Ser_Qty;
		FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TRX_ID');
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
		l_ser_qty := -99;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return l_ser_qty;
	END IF;

	IF Get_Ser_Qty%ISOPEN THEN
		CLOSE Get_Ser_Qty;
	END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return nvl(l_ser_qty,0);

  END IF;

  -- nvl the shp qty to 2 in this case because the shp qty cannot be null and
  -- have a valid serial number populated. this is data corruption.

  IF l_ser_num IS NOT NULL AND nvl(l_shp_qty,2) > 1 THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_DETAIL_INVALID_SERIAL');
	WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	l_ser_qty := -99;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return l_ser_qty;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return nvl(l_ser_qty,0);

EXCEPTION

  WHEN OTHERS THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_INV.Get_Serial_Qty');
	l_ser_qty := -99;
	--
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
	return l_ser_qty;

END Get_Serial_Qty;


FUNCTION get_reservable_flag(x_item_id         IN NUMBER,
                             x_organization_id IN NUMBER,
                             x_pickable_flag   IN VARCHAR2) RETURN
VARCHAR2 IS
-- bug 1583800: pickable_flag <> 'Y' overrides the reservable_flag
--              also, check if the item is transactable.

  l_type        MTL_SYSTEM_ITEMS.RESERVABLE_TYPE%TYPE;
  l_trx_flag    MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG%TYPE;
  l_flag        VARCHAR2(1) := 'Y';
  l_item_info   WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;
  --
  l_debug_on    BOOLEAN;
  l_return_status VARCHAR2(1);
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_RESERVABLE_FLAG';
  --
BEGIN

-- HW OPMCONV. Removed code forking

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'X_ITEM_ID',X_ITEM_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_ORGANIZATION_ID',X_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_PICKABLE_FLAG',X_PICKABLE_FLAG);
  END IF;
  --

  --Bug 5352779
  IF (x_item_id IS NULL) OR (x_organization_id IS NULL) THEN
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return 'Y';
  END IF;

  l_type := NULL;

  -- bug 1583800: assume NULL pickable_flag means 'Y'
  IF NVL(x_pickable_flag, 'Y') = 'N' THEN
    l_flag := 'N';
  ELSE
     Get_item_information( p_organization_id       => x_organization_id
                          , p_inventory_item_id    => x_item_id
                          , x_mtl_system_items_rec => l_item_info
                          , x_return_status        => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_type      := l_item_info.reservable_type;
    l_trx_flag  := l_item_info.mtl_transactions_enabled_flag;

    IF l_type = 2 THEN  -- 2 = non-reservable
        l_flag := 'N';
    ELSE                -- 1 = reservable
      -- bug 1583800: if item is also transactable, it will have
      --reservations.
      l_flag := l_trx_flag;
    END IF;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return l_flag;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
        --
        return 'Y';

WHEN OTHERS THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_INV.get_reservable_flag');
        --
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
        RETURN 'Y';

END get_reservable_flag;

/*
-----------------------------------------------------------------------------
  FUNCTION    : Line_Reserved
  PARAMETERS  : p_detail_id       - delivery_detail_id
                p_source_code     - source system code
                p_released_status - released status
                p_pickable_flag   - pickable flag
                p_organization_id - organization id of item
                p_inventory_item_id - item id
                x_return_status   - success if able to look up reservation status
                                    error if cannot look up
  DESCRIPTION :	This API takes the organization and inventory item
		and determines whether the lines item is reserved.
              It returns Y if it is reserved, N otherwise.
-----------------------------------------------------------------------------
*/

FUNCTION Line_Reserved(
             p_detail_id          IN  NUMBER,
             p_source_code        IN  VARCHAR2,
             p_released_status    IN  VARCHAR2,
             p_pickable_flag      IN  VARCHAR2,
             p_organization_id    IN  NUMBER,
             p_inventory_item_id  IN  NUMBER,
             x_return_status      OUT NOCOPY  VARCHAR2) RETURN VARCHAR2
IS
g_cache_item_id         NUMBER := NULL;
g_cache_organization_id NUMBER := NULL;
g_cache_reservable_flag VARCHAR(1) := NULL;


l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_reservable_type NUMBER;
l_mtl_txns_enabled_flag VARCHAR2(1);
l_item_info   WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LINE_RESERVED';
--
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_RELEASED_STATUS',P_RELEASED_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKABLE_FLAG',P_PICKABLE_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF    p_pickable_flag   = 'N'
     OR p_source_code     IN ('OKE', 'WSH')
     OR p_released_status IN ('N', 'R', 'S', 'X') THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return 'N' ;
  END IF;

  IF     g_cache_organization_id = p_organization_id
     AND g_cache_item_id         = p_inventory_item_id
     AND g_cache_reservable_flag IS NOT NULL THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN g_cache_reservable_flag;
  END IF;

  Get_item_information( p_organization_id          => p_organization_id
                          , p_inventory_item_id    => p_inventory_item_id
                          , x_mtl_system_items_rec => l_item_info
                          , x_return_status        => l_return_status);

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_reservable_type := l_item_info.reservable_type;

  g_cache_reservable_flag := NULL;
  g_cache_item_id         := p_inventory_item_id;
  g_cache_organization_id := p_organization_id;

  IF  l_reservable_type = 1 /* reservable = 1 */ THEN
    g_cache_reservable_flag := 'Y';
  ELSE
    g_cache_reservable_flag := 'N' ;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN g_cache_reservable_flag;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

  WHEN OTHERS THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_DETAILS_INV.Line_Reserved');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
        RETURN NULL;

END Line_Reserved;

PROCEDURE Create_Dynamic_Serial(
  	p_from_number IN VARCHAR2,
  	p_to_number IN VARCHAR2,
  	p_source_line_id IN NUMBER,
  	p_delivery_detail_id IN NUMBER,
  	p_inventory_item_id IN NUMBER,
  	p_organization_id IN NUMBER,
  	p_revision IN VARCHAR2,
  	p_lot_number IN VARCHAR2,
  	p_subinventory IN VARCHAR2,
  	p_locator_id IN NUMBER,
  	x_return_status OUT NOCOPY  VARCHAR2,
        p_serial_number_type_id IN NUMBER DEFAULT NULL,
        p_source_document_type_id IN NUMBER DEFAULT NULL)
  IS

  cursor c_header_info(c_delivery_detail_id number) is
	select 	nvl(dd.source_document_type_id, -9999) source_document_type_id
	from 	wsh_delivery_details dd
	where	dd.delivery_detail_id = c_delivery_detail_id;

  l_header_info	c_header_info%ROWTYPE;
  l_return_status        VARCHAR2(300);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(300);
  l_error_code            NUMBER;
  l_quantity             NUMBER;
  l_prefix               VARCHAR2(240);
  serial_number_type     NUMBER;
  trx_action_id          NUMBER;
  trx_source_type        VARCHAR2(1);
  l_to_number            VARCHAR2(100);
  l_return               NUMBER;
  l_mtl_org_param_rec    WSH_DELIVERY_DETAILS_INV.mtl_org_param_rec;
  WSH_INVALID_SER_NUM EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DYNAMIC_SERIAL';
--
  begin
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_FROM_NUMBER',P_FROM_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_TO_NUMBER',P_TO_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
      WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_serial_number_type_id',p_serial_number_type_id);
      WSH_DEBUG_SV.log(l_module_name,'p_source_document_type_id',p_source_document_type_id);

  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_serial_number_type_id IS NULL THEN

    -- bug 5264874
      Get_Org_Param_information (
          p_organization_id    =>     p_organization_id
        , x_mtl_org_param_rec  =>     l_mtl_org_param_rec
        , x_return_status      =>     l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      serial_number_type := l_mtl_org_param_rec.serial_number_type;
      IF serial_number_type = -99 THEN
        raise WSH_INVALID_SER_NUM;
      END IF;
    -- bug 5264874 end
  ELSE

     serial_number_type := p_serial_number_type_id;

  END IF;

  IF p_source_document_type_id IS NULL THEN

     open  c_header_info(p_delivery_detail_id);
     fetch c_header_info into l_header_info;
     if c_header_info%NOTFOUND then
        l_header_info.source_document_type_id := -9999;
     end if;
     close c_header_info;

  ELSE

     l_header_info.source_document_type_id := p_source_document_type_id;

  END IF;

  l_to_number := p_to_number;


  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.TRX_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  trx_action_id := WSH_DETAILS_VALIDATIONS.Trx_Id('TRX_ACTION_ID',
                                                  p_source_line_id,
                                                  l_header_info.source_document_type_id);


  IF l_header_info.source_document_type_id = 10 THEN
    trx_source_type := '8';
  ELSIF l_header_info.source_document_type_id <> 10 THEN
    trx_source_type := '2';
  END IF;


  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_SERIAL_NUMBER_PUB.VALIDATE_SERIALS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --



   l_return := INV_SERIAL_NUMBER_PUB.VALIDATE_SERIALS(
                    p_org_id => p_organization_id,
                    p_item_id => p_inventory_item_id,
                    p_qty =>  l_quantity,
                    p_rev =>  p_revision,
                    p_lot =>  p_lot_number,
                    p_start_ser => p_from_number,
                    p_trx_src_id => trx_source_type,
                    p_trx_action_id => trx_action_id,
                    p_subinventory_code =>p_subinventory,
                    p_locator_id =>p_locator_id,
                    p_group_mark_id => NULL,
                    p_issue_receipt => 'I',
                    x_end_ser => l_to_number,
                    x_proc_msg => l_msg_data,
                    p_check_for_grp_mark_id => 'Y' --Bug# 2656316
                 );


   IF l_return = 1 THEN

      RAISE WSH_INVALID_SER_NUM;

   END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

    WHEN WSH_INVALID_SER_NUM THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_SER_NUM');
       WSH_UTIL_CORE.Add_Message(x_return_status);
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_SER_NUM');
       END IF;

     WHEN others THEN
        IF c_header_info%ISOPEN THEN
           close c_header_info;
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Create_Dynamic_Serial');

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;

   --
END Create_Dynamic_Serial;

/*
-----------------------------------------------------------------------------
  PROCEDURE   : Validate_Serial_Range
  PARAMETERS  : p_from_serial_number - The start serial number
  		p_to_serial_number - The end serial number
  		p_lot_number - lot id for the delivery detail
  		p_organization_id - organization id for the delivery detail
  		p_inventory_item_id - Item id for the delivery detail
  		p_revision	- revision of the delivery detail
		p_locator_id - locator id for the delivery detail
		-1 if dynamic insert and 1 if pre-defined.
		p_subinventory - subinventory for the delivery detail
	        p_quantity - Amount of quantitiy to be shipped
 	        p_transaction_type_id
                p_object_type
		x_prefix - The prefix of serial number
	        x_return_status - return status of the API
	        x_result - The result of the API

  DESCRIPTION : This procedure takes in the from_serial number and to_serial number
  		and validates if the serial numbers fall in Range and range is equal
  		to the given quantity.It also checks if the serial numbers falling
  		in the range are predefined for the item.
-----------------------------------------------------------------------------
*/

PROCEDURE Validate_Serial_Range(
  p_from_serial_number IN VARCHAR2,
  p_to_serial_number   IN VARCHAR2,
  p_lot_number         IN VARCHAR2,
  p_organization_id    IN NUMBER,
  p_inventory_item_id  IN NUMBER,
  p_subinventory       IN VARCHAR2,
  p_revision           IN VARCHAR2,
  p_locator_id         IN NUMBER,
  p_quantity           IN NUMBER,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type        IN VARCHAR2 DEFAULT NULL,
  x_prefix             OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_result             OUT NOCOPY BOOLEAN)

 IS

l_result   			NUMBER;

l_number_part     NUMBER := 0;
l_counter         NUMBER := 0;
l_from_number     VARCHAR2(30);
l_to_number       VARCHAR2(30);
l_length          NUMBER;
l_padded_length   NUMBER;
p_prefix 	  VARCHAR(30);
x_quantity  	  NUMBER;
x_errorcode 	  NUMBER;
l_fm_serial       INV_VALIDATE.SERIAL_NUMBER_TBL;
l_to_serial       INV_VALIDATE.SERIAL_NUMBER_TBL;
x_errored_serials INV_VALIDATE.SERIAL_NUMBER_TBL;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SERIAL_RANGE';

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'From Serial Num',p_from_serial_number);
      WSH_DEBUG_SV.log(l_module_name, 'To Serial Num', p_to_serial_number);
      WSH_DEBUG_SV.log(l_module_name, 'Lot Number', p_lot_number);
      WSH_DEBUG_SV.log(l_module_name, 'Organization Id', p_organization_id);
      WSH_DEBUG_SV.log(l_module_name, 'Inventory Item id', p_inventory_item_id);
      WSH_DEBUG_SV.log(l_module_name, 'Subinventory', p_subinventory);
      WSH_DEBUG_SV.log(l_module_name, 'Revision', p_revision);
      WSH_DEBUG_SV.log(l_module_name, 'Locator Id', p_locator_id);
      WSH_DEBUG_SV.log(l_module_name, 'Quantity', p_quantity);
      WSH_DEBUG_SV.log(l_module_name, 'p_transaction_type_id', p_transaction_type_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_object_type', p_object_type);
  END IF;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   g_org.organization_id := p_organization_id;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.ORGANIZATION',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	l_result := INV_VALIDATE.organization(g_org);

        IF(l_debug_on) THEN
          wsh_debug_sv.log(l_module_name, 'Org Result', l_result);
        END IF;

	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Organization');
                raise FND_API.G_EXC_ERROR;
	END IF;
   g_item.inventory_item_id := p_inventory_item_id;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.INVENTORY_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	l_result := wsh_delivery_details_inv.inventory_item(
		p_item 	 => g_item,
		p_org     => g_org);

        IF(l_debug_on) THEN
          wsh_debug_sv.log(l_module_name, 'Inv Item Result', l_result);
        END IF;

	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Item');
                raise FND_API.G_EXC_ERROR;
	END IF;

   g_sub.secondary_inventory_name := p_subinventory;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.FROM_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
	l_result := INV_VALIDATE.From_Subinventory(
		p_org 	 	=> g_org,
		p_sub     	=> g_sub,
		p_item    	=> g_item,
		p_trx_type_id   => p_transaction_type_id,
        	p_object_type => p_object_type,
		p_acct_txn  => 1);
        ELSE
		l_result := INV_VALIDATE.From_Subinventory(
		p_org 	 	=> g_org,
		p_sub     	=> g_sub,
		p_item    	=> g_item,
		p_acct_txn  => 1);
	END IF;
        IF(l_debug_on) THEN
          wsh_debug_sv.log(l_module_name, 'Subinv Result', l_result);
        END IF;

	IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Locator');
                raise FND_API.G_EXC_ERROR;
	END IF;

   g_loc.inventory_location_id := p_locator_id;
	-- Need to check if locator is NULL cause inventory validation API will
	-- validate on flex field and return false when locator is NULL
	IF (p_locator_id IS NOT NULL) THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.VALIDATELOCATOR',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
                IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
		l_result := INV_VALIDATE.validateLocator(
			p_locator => g_loc,
			p_org 	 => g_org,
			p_sub     => g_sub,
			p_trx_type_id   => p_transaction_type_id,
	        	p_object_type => p_object_type,
			p_item    => g_item);
                ELSE
		l_result := INV_VALIDATE.validateLocator(
			p_locator => g_loc,
			p_org 	 => g_org,
			p_sub     => g_sub,
			p_item    => g_item);
		END IF;
                 IF(l_debug_on) THEN
                    wsh_debug_sv.log(l_module_name, 'Locator Result', l_result);
                 END IF;

		IF (l_result = INV_VALIDATE.F) THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
			FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Locator');
                        raise FND_API.G_EXC_ERROR;
		END IF;
	END IF;

   g_lot.lot_number := p_lot_number;
	IF (p_lot_number IS NOT NULL) THEN
           IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.LOT_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
       IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
	l_result := INV_VALIDATE.Lot_Number(
		p_lot     		=> g_lot,
		p_org 	 		=> g_org,
		p_item	 		=> g_item,
		p_trx_type_id           => p_transaction_type_id,
        	p_object_type           => p_object_type,
		p_from_sub              => g_sub,
		p_loc 			=> g_loc,
		p_revision              => p_revision);
       ELSE
		l_result := INV_VALIDATE.Lot_Number(
		p_lot     		=> g_lot,
		p_org 	 		=> g_org,
		p_item	 		=> g_item,
		p_from_sub              => g_sub,
		p_loc 			=> g_loc,
		p_revision              => p_revision);
       END IF;
        IF(l_debug_on) THEN
          wsh_debug_sv.log(l_module_name, 'Lot Number Result', l_result);
        END IF;

	  IF (l_result <> INV_VALIDATE.T) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_INV_INVALID');
		FND_MESSAGE.SET_TOKEN('INV_ATTRIBUTE', 'Lot');--Material Status Impact
                raise FND_API.G_EXC_ERROR;
	  END IF;
	END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit MTL_SERIAL_CHECK.INV_SERIAL_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

	IF NOT MTL_SERIAL_CHECK.INV_SERIAL_INFO(p_from_serial_number  =>  p_from_serial_number ,
			        p_to_serial_number    =>  p_to_serial_number ,
			        x_prefix              =>  x_prefix,
			        x_quantity            =>  x_quantity,
			        x_from_number         =>  l_from_number,
			        x_to_number           =>  l_to_number,
			        x_errorcode           =>  x_errorcode)
       THEN
   		x_result := FALSE;
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
   		RETURN;
       END IF;
	IF (x_quantity <> p_quantity) THEN
		x_result := false;
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		RETURN;
	END IF;
   	l_number_part := TO_NUMBER(l_FROM_NUMBER);
      	l_counter := 1;
      	-- Get the length of the serial number
      	l_length := length(p_from_serial_number);

        IF(l_debug_on) THEN
          wsh_debug_sv.log(l_module_name, 'Length ', l_length);
        END IF;

        IF p_transaction_type_id IS NOT NULL AND p_object_type IS NOT NULL THEN
           l_fm_serial(1) := p_from_serial_number;
           l_to_serial(1) := p_to_serial_number;
	   l_result := INV_VALIDATE.validate_serial_range(
	                                       p_fm_serial       => l_fm_serial,
  		                               p_to_serial       => l_to_serial,
  		                               p_org             => g_org,
  				               p_item            => g_item ,
  					       p_from_sub        => g_sub ,
  		                               p_lot             => g_lot,
  		                               p_loc             => g_loc,
  		                               p_revision        => p_revision,
  		                               p_trx_type_id     => p_transaction_type_id,
  		                               p_object_type     => p_object_type,
  		                               x_errored_serials => x_errored_serials);
           IF (l_result = INV_VALIDATE.T) THEN
               x_result := TRUE;
           ELSE
               x_result := FALSE;
               FOR i in 1..x_errored_serials.count LOOP
                   IF l_debug_on THEN
                      wsh_debug_sv.log(l_module_name, 'errored serial_number'||to_char(i), x_errored_serials(i));
                   END IF;
               END LOOP;
            END IF;
	ELSE
           WHILE (l_counter <= x_quantity) LOOP

	         -- The padded length will be the length of the serial number minus
        	 -- the length of the number part
	         -- Fix by etam
        	l_padded_length := l_length - length(l_number_part);
         	g_serial.serial_number := RPAD(nvl(x_Prefix,'0'), l_padded_length, '0') ||l_number_part;

             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_VALIDATE.VALIDATE_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
	     l_result := INV_VALIDATE.Validate_serial(
				p_serial        =>      g_serial,
				p_lot           =>      g_lot,
				p_org           =>      g_org,
				p_item          =>      g_item,
				p_from_sub      =>      g_sub,
				p_loc           =>      g_loc,
				p_revision      =>      p_revision);

             IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Serial Result', l_result);
             END IF;

             IF (l_result = INV_VALIDATE.T) THEN
		  x_result := TRUE;
	     ELSE
		  x_result := FALSE;
		  EXIT;
	     END IF;
	     l_number_part := l_number_part + 1;
	     l_counter :=  l_counter + 1;
	   END LOOP;
           IF (l_result = INV_VALIDATE.T) THEN
               x_result := TRUE;
           ELSE
               x_result := FALSE;
           END IF;
        END IF;
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END  IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

   WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Validate_Serial_Range');
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Validate_Serial_Range;

PROCEDURE Create_Dynamic_Serial_Range(
        p_from_number        IN VARCHAR2,
        p_to_number          IN VARCHAR2,
        p_source_line_id     IN NUMBER,
        p_delivery_detail_id IN NUMBER,
        p_inventory_item_id  IN NUMBER,
        p_organization_id    IN NUMBER,
        p_revision           IN VARCHAR2,
        p_lot_number         IN VARCHAR2,
        p_subinventory       IN VARCHAR2,
        p_locator_id         IN NUMBER,
        p_quantity           IN NUMBER,
        x_prefix             OUT NOCOPY VARCHAR2,
        x_return_status      OUT NOCOPY VARCHAR2)
  IS

  cursor c_header_info(c_delivery_detail_id number) is
	select 	nvl(dd.source_document_type_id, -9999) source_document_type_id
	from 	wsh_delivery_details dd
	where	dd.delivery_detail_id = c_delivery_detail_id;

  l_header_info	c_header_info%ROWTYPE;
  l_return_status        VARCHAR2(300);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(300);
  l_error_code            NUMBER;
  l_quantity             NUMBER;
  l_prefix               VARCHAR2(240);
  l_serial_number_type     NUMBER;
  l_trx_action_id          NUMBER;
  l_trx_source_type        VARCHAR2(1);
  l_to_number              VARCHAR2(100);
  l_return                 NUMBER;
  l_mtl_org_param_rec      WSH_DELIVERY_DETAILS_INV.mtl_org_param_rec;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DYNAMIC_SERIAL_RANGE';

BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_FROM_NUMBER',P_FROM_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_TO_NUMBER',P_TO_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
      WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
      WSH_DEBUG_SV.log(l_module_name, 'P_QUANTITY',p_quantity);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- bug 5264874
  Get_Org_Param_information (p_organization_id     =>     p_organization_id
                            , x_mtl_org_param_rec  =>     l_mtl_org_param_rec
                            , x_return_status      =>     l_return_status);

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_serial_number_type := l_mtl_org_param_rec.serial_number_type;
  IF l_serial_number_type = -99 THEN
    raise FND_API.G_EXC_ERROR;
  END IF;
  -- bug 5264874 end

  open  c_header_info(p_delivery_detail_id);
  fetch c_header_info into l_header_info;
  if c_header_info%NOTFOUND then
    l_header_info.source_document_type_id := -9999;
  end if;
  close c_header_info;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'Serial Number Type', l_serial_number_type);
  END IF;

  l_to_number := p_to_number;

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.TRX_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  l_trx_action_id := WSH_DETAILS_VALIDATIONS.Trx_Id('TRX_ACTION_ID',
                                                  p_source_line_id,
                                                  l_header_info.source_document_type_id);

  IF l_header_info.source_document_type_id = 10 THEN
    l_trx_source_type := '8';
  ELSIF l_header_info.source_document_type_id <> 10 THEN
    l_trx_source_type := '2';
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_SERIAL_NUMBER_PUB.VALIDATE_SERIALS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

 l_return := INV_SERIAL_NUMBER_PUB.VALIDATE_SERIALS(
                    p_org_id => p_organization_id,
                    p_item_id => p_inventory_item_id,
                    p_qty =>  l_quantity,
                    p_rev =>  p_revision,
                    p_lot =>  p_lot_number,
                    p_start_ser => p_from_number,
                    p_trx_src_id => l_trx_source_type,
                    p_trx_action_id => l_trx_action_id,
                    p_subinventory_code =>p_subinventory,
                    p_locator_id =>p_locator_id,
                    p_group_mark_id => NULL,
                    p_issue_receipt => 'I',
                    x_end_ser => l_to_number,
                    x_proc_msg => l_msg_data,
                    p_check_for_grp_mark_id => 'Y' --Bug# 2656316
                 );

   IF l_return = 1 THEN
    RAISE FND_API.G_EXC_ERROR;
   END IF;



   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Quantity', l_quantity);
      wsh_debug_sv.log(l_module_name, 'Prefix', l_prefix);
   END IF;
   IF (l_quantity <> p_quantity) THEN
        fnd_message.set_name('WSH', 'WSH_SERIAL_NUM_WRG_RANGE');
	RAISE FND_API.G_EXC_ERROR;
   END IF;

    x_prefix := l_prefix;

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
     WHEN others THEN
        /*IF c_serial_type%ISOPEN THEN
           close c_serial_type;
        END IF;*/
        IF c_header_info%ISOPEN THEN
           close c_header_info;
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Create_Dynamic_Serial_Range');

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Create_Dynamic_Serial_Range;


   -- Pack J - Catch Weights
   -- This procedure checks if the catch weight can be
   -- defaulted in a wms organization and,  if possible, defaults it.
   -- If the catch weight is required and cannot be defaulted,
   -- raises an error

PROCEDURE Check_Default_Catch_Weights(p_line_inv_rec IN WSH_DELIVERY_DETAILS_INV.line_inv_info,
                                      x_return_status   OUT NOCOPY VARCHAR2) IS

l_msg_count NUMBER;
l_msg_data  VARCHAR2(20000);
l_wms_table WMS_SHIPPING_INTERFACE_GRP.g_delivery_detail_tbl;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Default_Catch_Weights';

BEGIN


       l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
       IF l_debug_on IS NULL THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
       END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          WSH_DEBUG_SV.log(l_module_name,'p_line_inv_rec.delivery_detail_id', p_line_inv_rec.delivery_detail_id);
       END IF;

       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_SHIPPING_INTERFACE_GRP.process_delivery_details',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      -- Call to WMS API to check/default catch weights

      l_wms_table(1).delivery_detail_id            := p_line_inv_rec.delivery_detail_id;
      l_wms_table(1).inventory_item_id             := p_line_inv_rec.inventory_item_id;
      l_wms_table(1).organization_id               := p_line_inv_rec.organization_id;
      l_wms_table(1).picked_quantity               := p_line_inv_rec.picked_quantity;
      l_wms_table(1).picked_quantity2              := p_line_inv_rec.picked_quantity2;
      l_wms_table(1).requested_quantity_uom        := p_line_inv_rec.requested_quantity_uom;
      l_wms_table(1).requested_quantity_uom2       := p_line_inv_rec.requested_quantity_uom2;
      l_wms_table(1).source_line_id                := p_line_inv_rec.source_line_id;
      l_wms_table(1).line_direction                := p_line_inv_rec.line_direction;


      WMS_SHIPPING_INTERFACE_GRP.process_delivery_details (
                 p_api_version   => 1.0,
                 p_action                 => WMS_SHIPPING_INTERFACE_GRP.g_action_validate_sec_qty,
                 p_delivery_detail_tbl  => l_wms_table,
                 x_return_status  => x_return_status,
                 x_msg_count       => l_msg_count,
                 x_msg_data         => l_msg_data);

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status after calling WMS_SHIPPING_INTERFACE_GRP.process_delivery_details', x_return_status);
          WSH_DEBUG_SV.log(l_module_name,'status of dd after calling WMS_SHIPPING_INTERFACE_GRP.process_delivery_details', l_wms_table(1).return_status);
      END IF;

      IF (x_return_status IN  (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) OR
         (l_wms_table(1).return_status = 'E')
      THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CATCHWEIGHT');
        FND_MESSAGE.SET_TOKEN('DEL_DET', p_line_inv_rec.delivery_detail_id);
        WSH_UTIL_CORE.Add_Message(x_return_status);
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;

      EXCEPTION

      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Check_Default_Catch_Weights');

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Check_Default_Catch_Weights;

-- HW OPMCONV - New procedure to get item information
/*
-----------------------------------------------------------------------------
  PROCEDURE   : Get_item_information
  PARAMETERS  : p_organization_id       - organization id
                p_inventory_item_id     - source system code
                x_mtl_system_items_rec  - Record to hold item informatiom
                x_return_status   - success if able to look up item information
                                    error if cannot find item information

  DESCRIPTION :	This API takes the organization and inventory item
		and checks if item information is already cached, if
		not, it loads the new item information for a specific
		organization
-----------------------------------------------------------------------------
*/

PROCEDURE Get_item_information (
  p_organization_id        IN            NUMBER
, p_inventory_item_id      IN            NUMBER
, x_mtl_system_items_rec   OUT  NOCOPY   WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec
, x_return_status          OUT  NOCOPY VARCHAR2
)IS



l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_item_information';
TYPE item_info_cache_tab IS TABLE OF c_item_info%ROWTYPE;

  l_index NUMBER;
  l_flag VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_cache_rec c_item_info%ROWTYPE;
  -- 2nd cursor
  l_item_index NUMBER;
  l_item_flag VARCHAR2(1);
  l_item_return_status VARCHAR2(1);

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
      WSH_DEBUG_SV.log(l_module_name,'p_inventory_item_id',p_inventory_item_id);
  END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


    IF (p_organization_id IS NOT NULL AND p_inventory_item_id IS NOT NULL) THEN
      l_cache_rec.organization_id := (p_organization_id);
      l_cache_rec.inventory_item_id := (p_inventory_item_id);

      get_item_table_index
       (p_validate_rec  => l_cache_rec,
        p_item_tab      => g_item_tab,
        x_index         => l_index,
        x_return_status => l_return_status,
        x_flag          => l_flag
       );

       IF l_flag = 'U' AND l_index IS NOT NULL THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Org is not cached yet: ',p_organization_id);
            WSH_DEBUG_SV.log(l_module_name,'Item_id  is not cached yet: ',p_inventory_item_id);
          END IF ;
          OPEN  c_item_info (p_organization_id,p_inventory_item_id);

          FETCH c_item_info INTO l_cache_rec;
          IF (c_item_info%NOTFOUND) THEN

             l_cache_rec.organization_id := p_organization_id;
             l_cache_rec.inventory_item_id := p_inventory_item_id;
             l_cache_rec.valid_flag := 'N';
          END IF;
          CLOSE c_item_info;
          -- add record to cache
          g_item_tab(l_index) := l_cache_rec;
       ELSE
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Org is already chached: ',p_organization_id);
            WSH_DEBUG_SV.log(l_module_name,'Inv_item_id is already chached',p_inventory_item_id);
          END IF;
          -- retrieve record from cache
          l_cache_rec := g_item_tab(l_index);
       END IF;

--  At this point, l_cache_rec has the cache information.
--      you can alternately use g_item_tab(l_index).

        IF l_cache_rec.valid_flag = 'N' THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ORG');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           wsh_util_core.add_message(x_return_status,l_module_name);

           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;

           RETURN;
        END IF;
-- Always populate the values

      x_mtl_system_items_rec.primary_uom_code:= l_cache_rec.primary_uom_code;
      /* Lgao, bug 5137114, the secondary_default_ind only has meanings when the
       * tracking_quantity_ind is for both primary and secondary in inventory.
       */
      if l_cache_rec.tracking_quantity_ind = 'PS' then
        x_mtl_system_items_rec.secondary_default_ind:=l_cache_rec.secondary_default_ind;
        x_mtl_system_items_rec.secondary_uom_code:=l_cache_rec.secondary_uom_code;
      else
        x_mtl_system_items_rec.secondary_default_ind:='';
        x_mtl_system_items_rec.secondary_uom_code:= '';
      end if;
      x_mtl_system_items_rec.lot_control_code:=l_cache_rec.lot_control_code;

      x_mtl_system_items_rec.tracking_quantity_ind:=l_cache_rec.tracking_quantity_ind;
      x_mtl_system_items_rec.dual_uom_deviation_low:=l_cache_rec.dual_uom_deviation_low;
      x_mtl_system_items_rec.dual_uom_deviation_high:=l_cache_rec.dual_uom_deviation_high;
      x_mtl_system_items_rec.enabled_flag:=l_cache_rec.enabled_flag;
      x_mtl_system_items_rec.shippable_item_flag:=l_cache_rec.shippable_item_flag;
      x_mtl_system_items_rec.inventory_item_flag:=l_cache_rec.inventory_item_flag;
      x_mtl_system_items_rec.lot_divisible_flag:=l_cache_rec.lot_divisible_flag;
      x_mtl_system_items_rec.container_item_flag:=l_cache_rec.container_item_flag;
      x_mtl_system_items_rec.reservable_type:=l_cache_rec.reservable_type;
      x_mtl_system_items_rec.mtl_transactions_enabled_flag:=l_cache_rec.mtl_transactions_enabled_flag;

    ELSE  -- Both or one is NULL (Org and Inv_item)
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
	 WSH_DEBUG_SV.pop(l_module_name,x_return_status);
      END IF;
	    --
      RETURN;
    END IF;

    IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.primary_uom_code',x_mtl_system_items_rec.primary_uom_code);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.secondary_uom_code',x_mtl_system_items_rec.secondary_uom_code);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.secondary_default_ind',x_mtl_system_items_rec.secondary_default_ind);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.lot_control_code',x_mtl_system_items_rec.lot_control_code);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.tracking_quantity_ind',x_mtl_system_items_rec.tracking_quantity_ind);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.dual_uom_deviation_low',x_mtl_system_items_rec.dual_uom_deviation_low);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.dual_uom_deviation_high',x_mtl_system_items_rec.dual_uom_deviation_high);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.enabled_flag',x_mtl_system_items_rec.enabled_flag);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.shippable_item_flag',x_mtl_system_items_rec.shippable_item_flag);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.inventory_item_flag',x_mtl_system_items_rec.inventory_item_flag);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.lot_divisible_flag',x_mtl_system_items_rec.lot_divisible_flag);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.container_item_flag',x_mtl_system_items_rec.container_item_flag);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.reservable_type',x_mtl_system_items_rec.reservable_type);
         WSH_DEBUG_SV.log(l_module_name,'x_mtl_system_items_rec.mtl_transactions_enabled_flag',x_mtl_system_items_rec.mtl_transactions_enabled_flag);
	 WSH_DEBUG_SV.pop(l_module_name,x_return_status);
     END IF;

EXCEPTION

   WHEN others THEN
     wsh_util_core.default_handler ('WSH_DELIVERY_DETAILS_INV .Get_item_information');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     IF c_item_info%isopen THEN
        close c_item_info;
     END IF;

END Get_item_information;


/*
-----------------------------------------------------------------------------
  PROCEDURE   : Update_Marked_Serial
  PARAMETERS  : p_from_serial_number - serial number to be marked with new
                transaction_temp_id
                p_to_serial_number - to serial number
                p_inventory_item_id - inventory item
                p_organization_id - organization_id
                p_transaction_temp_id - newly generated transaction temp id
                for serial number
                x_return_status - return status of the API
  DESCRIPTION : Call Inventory's update_marked_serial API which will take
                serial number and new transaction_temp_id as input and
                mark the serial number with the new transaction_temp_id
-----------------------------------------------------------------------------
*/
PROCEDURE Update_Marked_Serial (
  p_from_serial_number  IN      VARCHAR2,
  p_to_serial_number    IN      VARCHAR2 DEFAULT NULL,
  p_inventory_item_id   IN      NUMBER,
  p_organization_id     IN      NUMBER,
  p_transaction_temp_id IN      NUMBER,
  x_return_status       OUT     NOCOPY VARCHAR2)
IS
 --
  l_success BOOLEAN;
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_MARKED_SERIAL';
  --
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_FROM_SERIAL_NUMBER',P_FROM_SERIAL_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'P_TO_SERIAL_NUMBER',P_TO_SERIAL_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TEMP_ID',
                     P_TRANSACTION_TEMP_ID);
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit SERIAL_CHECK.INV_UPDATE_MARKED_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  Serial_Check.Inv_Update_Marked_Serial (
             from_serial_number => p_from_serial_number,
             to_serial_number   => p_to_serial_number, -- this should be NULL for single serial
             item_id            => p_inventory_item_id,
             org_id             => p_organization_id,
             temp_id            => p_transaction_temp_id,
             hdr_id             => NULL,
             lot_temp_id        => NULL,
             success            => l_success);
  --
  IF NOT l_success THEN
   --
   FND_MESSAGE.SET_NAME('WSH','WSH_SERIAL_MARK_ERROR');
   FND_MESSAGE.SET_TOKEN('SERIAL_NUM',p_from_serial_number);
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WSH_UTIL_CORE.Add_Message(x_return_status);
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'Return status after INV API',
                      x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;
   --
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.Update_Marked_Serial');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Update_Marked_Serial;


PROCEDURE get_trx_type_id(
  p_source_line_id IN NUMBER,
  p_source_code IN VARCHAR2,
  x_transaction_type_id OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR c_order_line_info(c_order_line_id number) IS
  SELECT source_document_type_id, source_document_id, source_document_line_id
  FROM   oe_order_lines_all
  WHERE  line_id = c_order_line_id;

  l_order_line_info c_order_line_info%ROWTYPE;

  CURSOR c_po_info(c_po_line_id number, c_source_document_id number) IS
  SELECT  destination_type_code,
          destination_subinventory,
          source_organization_id,
  	destination_organization_id,
  	deliver_to_location_id,
  	pl.requisition_line_id,
  	pd.distribution_id,
  	pl.unit_price,
  	nvl(pd.budget_account_id,-1)  budget_account_id,
  	decode(nvl(pd.prevent_encumbrance_flag,'N'),'N',nvl(pd.encumbered_flag,'N'),'N') encumbered_flag
  FROM    po_requisition_lines_all pl,
          po_req_distributions_all pd
  WHERE   pl.requisition_line_id = c_po_line_id
  AND     pl.requisition_header_id = c_source_document_id
  AND     pl.requisition_line_id = pd.requisition_line_id;

  l_po_info c_po_info%ROWTYPE;

  CURSOR c_mtl_interorg_parameters (c_from_organization_id NUMBER , c_to_organization_id NUMBER) IS
  SELECT   intransit_type
  FROM   mtl_interorg_parameters
  WHERE  from_organization_id = c_from_organization_id AND
            to_organization_id = c_to_organization_id;
  l_intransit_type NUMBER;

  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TRX_TYPE_ID';

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_source_line_id',p_source_line_id);
    WSH_DEBUG_SV.log(l_module_name,'p_source_code',p_source_code);
  END IF;

  IF p_source_code ='OE' THEN --{

    OPEN c_order_line_info(p_source_line_id);
    FETCH c_order_line_info into l_order_line_info;
    IF c_order_line_info%NOTFOUND THEN
      CLOSE c_order_line_info;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'No data found for order line',p_source_line_id);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    END IF;
    CLOSE c_order_line_info;

    IF (l_order_line_info.source_document_type_id = 10) THEN --Internal Sales order

       OPEN c_po_info(l_order_line_info.source_document_line_id, l_order_line_info.source_document_id);
       FETCH c_po_info into l_po_info;
       IF c_po_info%NOTFOUND THEN
         CLOSE c_po_info;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'No data found for PO '||l_order_line_info.source_document_line_id||' ,'||l_order_line_info.source_document_id);
	   WSH_DEBUG_SV.pop(l_module_name);
  	 END IF;
	 return;
       END IF;
       CLOSE c_po_info;
       IF (l_po_info.destination_type_code = 'EXPENSE') THEN
         x_transaction_type_id := 34 /* Store_issue */;
       ELSIF (l_po_info.destination_type_code = 'INVENTORY') AND
             (l_po_info.source_organization_id = l_po_info.destination_organization_id) THEN
          x_transaction_type_id := 50 /* Subinv_xfer */;
       ELSIF (l_po_info.destination_organization_id <> l_po_info.source_organization_id) THEN

          OPEN c_mtl_interorg_parameters( l_po_info.source_organization_id,
                                          l_po_info.destination_organization_id);
          FETCH c_mtl_interorg_parameters INTO l_intransit_type;

	  IF c_mtl_interorg_parameters%NOTFOUND THEN
            /* default to intransit */
            x_transaction_type_id := 62; /* intransit_shpmnt */
          ELSE
            IF l_intransit_type = 1 THEN
              x_transaction_type_id := 54; /* direct shipment */
            ELSE
              x_transaction_type_id := 62; /* intransit_shpmnt */
            END IF;
          END IF;
          CLOSE c_mtl_interorg_parameters;
       END IF;
    ELSE
      x_transaction_type_id := 33;
    END IF;
   --}
   ELSIF p_source_code ='OKE' THEN
     x_transaction_type_id := 77;
   ELSE
     x_transaction_type_id := 32; -- miscellaneous issue
   END IF;

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_transaction_type_id',x_transaction_type_id);
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status',x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;

 EXCEPTION

    WHEN OTHERS THEN
      --
      WSH_UTIL_CORE.default_handler('WSH_DELIVERY_DETAILS_INV.get_trx_type_id');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF c_order_line_info%isopen THEN
        CLOSE c_order_line_info;
      END IF;
      IF c_po_info%isopen THEN
        CLOSE c_po_info;
      END IF;
      IF c_mtl_interorg_parameters%isopen THEN
        CLOSE c_mtl_interorg_parameters;
      END IF;
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END get_trx_type_id;


END WSH_DELIVERY_DETAILS_INV;


/
