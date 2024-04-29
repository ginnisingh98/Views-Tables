--------------------------------------------------------
--  DDL for Package Body WMS_CONTAINER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CONTAINER_PVT" AS
/* $Header: WMSVCNTB.pls 120.55.12010000.19 2010/04/22 09:26:28 schiluve ship $ */

--  Global constant holding the package name
g_pkg_name    CONSTANT VARCHAR2(30)  := 'WMS_CONTAINER_PVT';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSVCNTB.pls 120.55.12010000.19 2010/04/22 09:26:28 schiluve ship $';

-- Various debug levels
G_ERROR     CONSTANT NUMBER := 1;
G_INFO      CONSTANT NUMBER := 5;
G_MESSAGE   CONSTANT NUMBER := 9;

G_NULL_NUM  CONSTANT NUMBER      := -9;
G_NULL_CHAR CONSTANT VARCHAR2(1) := '@';
G_PRECISION CONSTANT NUMBER      := 5;

-- package level debug variable
g_progress VARCHAR(500) := 'none';

-- Types used by Convert_UOM
TYPE to_uom_code_tb          IS TABLE OF NUMBER INDEX BY VARCHAR2(3);
TYPE from_uom_code_tb        IS TABLE OF to_uom_code_tb INDEX BY VARCHAR2(3);
TYPE item_uom_conversion_tb  IS TABLE OF from_uom_code_tb INDEX BY BINARY_INTEGER;
g_item_uom_conversion_tb     item_uom_conversion_tb;
g_item_uom_conversion_tb_cnt NUMBER := 0;

g_client_rec inv_cache.ct_rec_type; -- Added For LSP Project, bug 9087971

PROCEDURE mdebug(msg IN VARCHAR2, LEVEL NUMBER := G_MESSAGE) IS
BEGIN
  --DBMS_OUTPUT.put_line(msg);
  INV_TRX_UTIL_PUB.TRACE(msg, g_pkg_name, LEVEL);
END;

FUNCTION Convert_UOM (
  p_inventory_item_id IN NUMBER
, p_fm_quantity       IN NUMBER
, p_fm_uom            IN VARCHAR2
, p_to_uom            IN VARCHAR2
, p_mode              IN VARCHAR2 := null
) RETURN NUMBER
IS
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

l_conversion_rate   NUMBER;
l_inventory_item_id NUMBER;

BEGIN
   g_progress := 'Entered Convert_UOM';

  -- IF to_uom is the same as from_uom, Return from quantity
  IF p_fm_uom = p_to_uom THEN
     RETURN p_fm_quantity;
  ELSE
    --- Bug 5507188
    --- l_inventory_item_id := NVL(l_inventory_item_id, 0);
    l_inventory_item_id := NVL(p_inventory_item_id, 0);
    --- End bug 5507188

    -- Need to convert fm_qty
    g_progress := 'First check whether the convesrion rate has been cached';
    IF ( g_item_uom_conversion_tb.EXISTS(l_inventory_item_id) AND
         g_item_uom_conversion_tb(l_inventory_item_id).EXISTS(p_fm_uom) AND
         g_item_uom_conversion_tb(l_inventory_item_id)(p_fm_uom).EXISTS(p_to_uom) )
    THEN
      g_progress := 'Conversion rate is cached so just use the value';
      RETURN p_fm_quantity * g_item_uom_conversion_tb(l_inventory_item_id)(p_fm_uom)(p_to_uom);
    ELSE
      -- conversion rate is not cached
      g_progress := 'Call convert API and store the value';
      inv_convert.inv_um_conversion (
        from_unit  => p_fm_uom
      , to_unit    => p_to_uom
      , item_id    => l_inventory_item_id
      , uom_rate   => l_conversion_rate );

      IF ( l_conversion_rate > 0 ) THEN
        g_progress := 'Store the conversion rate';
        g_item_uom_conversion_tb(l_inventory_item_id)(p_fm_uom)(p_to_uom) := l_conversion_rate;
        g_item_uom_conversion_tb(l_inventory_item_id)(p_to_uom)(p_fm_uom) := 1 / l_conversion_rate;
        g_item_uom_conversion_tb_cnt := g_item_uom_conversion_tb_cnt + 1;

        g_progress := 'Need to purge table after a certain number of records';
        IF ( g_item_uom_conversion_tb_cnt > 1000 ) THEN
          g_item_uom_conversion_tb.delete;
          g_item_uom_conversion_tb_cnt := 0;
        END IF;

        RETURN p_fm_quantity * l_conversion_rate;
      ELSE -- Can not convert
         IF ( l_debug = 1 ) THEN
           mdebug('No coversion rate between '||p_fm_uom||' and '||p_to_uom||' mode='||p_mode, G_ERROR);
        END IF;
        fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
        fnd_message.set_token('uom1', p_fm_uom);
        fnd_message.set_token('uom2', p_to_uom);
        fnd_message.set_token('module', g_pkg_name);
        fnd_msg_pub.ADD;

         IF ( p_mode = G_NO_CONV_RETURN_NULL ) THEN
          RETURN NULL;
        ELSIF ( p_mode = G_NO_CONV_RETURN_ZERO ) THEN
         RETURN 0;
        ELSE -- Normal converstion error
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF; -- IF cache exists
  END IF; -- IF p_fm_uom = p_to_uom
END Convert_UOM;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Get_Update_LPN_Start_Num (
  p_org_id   IN         NUMBER
, p_qty      IN         NUMBER
, x_curr_seq OUT NOCOPY NUMBER
) IS PRAGMA AUTONOMOUS_TRANSACTION;
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_lpn_start_num NUMBER:=0;

BEGIN
  --Creating an overloaded procedure so that the select of the
  --starting number and the update happens with the same autonomous transaction
  -- If the org default lpn starting number was used, we will need to update
  -- that value so that the same number will not be used again the next time
  -- Generate_LPN is called for that org

  SELECT lpn_starting_number INTO l_lpn_start_num
    FROM mtl_parameters
    WHERE organization_id=p_org_id
    FOR UPDATE;

  UPDATE MTL_PARAMETERS
    SET lpn_starting_number  =  l_lpn_start_num+p_qty,
    last_update_date         =  SYSDATE,
    last_updated_by          =  FND_GLOBAL.USER_ID
    WHERE organization_id = p_org_id;

  x_curr_seq:=l_lpn_start_num;

  COMMIT;
END Get_Update_LPN_Start_Num;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 1  = Resides in Inventory
-- 2  = Resides in WIP
-- 3  = Resides in Receiving
-- 4  = Issued out of Stores
-- 5  = Pre-generated
-- 6  = Resides in intransit
-- 7  = Resides at vendor site
-- 8  = Packing context, used as a temporary context value
--      when the user wants to reassociate the LPN with a
--      different license plate number and/or container item ID
-- 9  = Loaded for shipment
-- 10 = Prepack of WIP
-- 11 = LPN Picked
-- 12 = Loaded in staging: Temporary context for staged (picked) LPNs

FUNCTION Valid_Context_Change (
  p_caller      VARCHAR
, p_old_context NUMBER
, p_new_context NUMBER
) RETURN BOOLEAN IS

l_lookup_meaning MFG_LOOKUPS.MEANING%TYPE;

BEGIN
  IF ( p_old_context = LPN_CONTEXT_INV ) THEN
    IF ( p_new_context IN(1, 2, 3, 4, 5, 6, 8, 11) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_CONTEXT_WIP ) THEN
    IF ( p_new_context IN(1, 2, 5, 11 ) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_CONTEXT_RCV ) THEN
    IF ( p_new_context IN(1, 3, 4, 5, 11) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_CONTEXT_STORES ) THEN
    IF ( p_new_context IN(4, 6) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_CONTEXT_PREGENERATED ) THEN
    IF ( p_new_context IN(1, 2, 3, 4, 5, 6, 7, 8, 9, 11) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_CONTEXT_INTRANSIT ) THEN
    IF ( p_new_context IN(1, 3, 5, 6, 11) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_CONTEXT_VENDOR ) THEN
    IF ( p_new_context IN(1, 3, 5, 7) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_CONTEXT_PACKING ) THEN
    IF ( p_new_context IN(1, 5, 8, 11) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_LOADED_FOR_SHIPMENT ) THEN
    IF ( p_new_context IN(1, 4, 5, 6, 9, 11) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_PREPACK_FOR_WIP ) THEN
    IF ( p_new_context IN(1, 2, 5, 10) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_CONTEXT_PICKED ) THEN
    IF ( p_new_context IN(1, 4, 5, 6, 9, 11, 12) ) THEN
      RETURN TRUE;
    END IF;
  ELSIF ( p_old_context = LPN_LOADED_IN_STAGE ) THEN
    IF ( p_new_context IN(4, 11, 12) ) THEN   --8454203
      RETURN TRUE;
    END IF;
  END IF;

  -- If haven't returned true must be disallowed context change
  -- return false and add error message
  fnd_message.set_name('INV', 'WMS_CONTEXT_CHANGE_ERR');

  SELECT meaning
  INTO   l_lookup_meaning
  FROM   mfg_lookups
  WHERE  lookup_type = 'WMS_LPN_CONTEXT'
  AND    lookup_code = p_old_context;
  fnd_message.set_token('CONTEXT1', l_lookup_meaning);

  SELECT meaning
  INTO   l_lookup_meaning
  FROM   mfg_lookups
  WHERE  lookup_type = 'WMS_LPN_CONTEXT'
  AND    lookup_code = p_new_context;
  fnd_message.set_token('CONTEXT2', l_lookup_meaning);

  fnd_msg_pub.ADD;
  RAISE fnd_api.g_exc_error;
  RETURN FALSE;
END Valid_Context_Change;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE To_LPNBulkRecType (
  p_lpn_table    IN            WMS_Data_Type_Definitions_PUB.LPNTableType
, p_table_first  IN            NUMBER
, p_table_last   IN            NUMBER
, p_record_last  IN            NUMBER
, x_lpn_bulk_rec IN OUT NOCOPY LPNBulkRecType
) IS
l_table_first  NUMBER;
l_table_last   NUMBER;
l_rec_last     NUMBER;

BEGIN
  IF ( p_lpn_table.first IS NOT NULL ) THEN
    l_table_first := NVL(p_table_first, p_lpn_table.first);
    l_table_last  := NVL(p_table_last, p_lpn_table.last);
    l_rec_last    := NVL(p_record_last, NVL(x_lpn_bulk_rec.lpn_id.last, p_lpn_table.first - 1));

    FOR i IN l_table_first .. l_table_last LOOP
      l_rec_last := l_rec_last + 1;

      x_lpn_bulk_rec.lpn_id(l_rec_last)                  := p_lpn_table(i).lpn_id;
      x_lpn_bulk_rec.license_plate_number(l_rec_last)    := p_lpn_table(i).license_plate_number;
      x_lpn_bulk_rec.parent_lpn_id(l_rec_last)           := p_lpn_table(i).parent_lpn_id;
      x_lpn_bulk_rec.outermost_lpn_id(l_rec_last)        := p_lpn_table(i).outermost_lpn_id;
      x_lpn_bulk_rec.lpn_context(l_rec_last)             := p_lpn_table(i).lpn_context;

      x_lpn_bulk_rec.organization_id(l_rec_last)         := p_lpn_table(i).organization_id;
      x_lpn_bulk_rec.subinventory_code(l_rec_last)       := p_lpn_table(i).subinventory_code;
      x_lpn_bulk_rec.locator_id(l_rec_last)              := p_lpn_table(i).locator_id;

      x_lpn_bulk_rec.inventory_item_id(l_rec_last)       := p_lpn_table(i).inventory_item_id;
      x_lpn_bulk_rec.revision(l_rec_last)                := p_lpn_table(i).revision;
      x_lpn_bulk_rec.lot_number(l_rec_last)              := p_lpn_table(i).lot_number;
      x_lpn_bulk_rec.serial_number(l_rec_last)           := p_lpn_table(i).serial_number;
      x_lpn_bulk_rec.cost_group_id(l_rec_last)           := p_lpn_table(i).cost_group_id;

      x_lpn_bulk_rec.tare_weight_uom_code(l_rec_last)    := p_lpn_table(i).tare_weight_uom_code;
      x_lpn_bulk_rec.tare_weight(l_rec_last)             := p_lpn_table(i).tare_weight;
      x_lpn_bulk_rec.gross_weight_uom_code(l_rec_last)   := p_lpn_table(i).gross_weight_uom_code;
      x_lpn_bulk_rec.gross_weight(l_rec_last)            := p_lpn_table(i).gross_weight;
      x_lpn_bulk_rec.container_volume_uom(l_rec_last)    := p_lpn_table(i).container_volume_uom;
      x_lpn_bulk_rec.container_volume(l_rec_last)        := p_lpn_table(i).container_volume;
      x_lpn_bulk_rec.content_volume_uom_code(l_rec_last) := p_lpn_table(i).content_volume_uom_code;
      x_lpn_bulk_rec.content_volume(l_rec_last)          := p_lpn_table(i).content_volume;

      x_lpn_bulk_rec.source_type_id(l_rec_last)          := p_lpn_table(i).source_type_id;
      x_lpn_bulk_rec.source_header_id(l_rec_last)        := p_lpn_table(i).source_header_id;
      x_lpn_bulk_rec.source_line_id(l_rec_last)          := p_lpn_table(i).source_line_id;
      x_lpn_bulk_rec.source_line_detail_id(l_rec_last)   := p_lpn_table(i).source_line_detail_id;
      x_lpn_bulk_rec.source_name(l_rec_last)             := p_lpn_table(i).source_name;
      x_lpn_bulk_rec.source_transaction_id(l_rec_last)   := p_lpn_table(i).source_transaction_id;
      x_lpn_bulk_rec.reference_id(l_rec_last)            := p_lpn_table(i).reference_id;

      x_lpn_bulk_rec.attribute_category(l_rec_last)      := p_lpn_table(i).attribute_category;
      x_lpn_bulk_rec.attribute1(l_rec_last)              := p_lpn_table(i).attribute1;
      x_lpn_bulk_rec.attribute2(l_rec_last)              := p_lpn_table(i).attribute2;
      x_lpn_bulk_rec.attribute3(l_rec_last)              := p_lpn_table(i).attribute3;
      x_lpn_bulk_rec.attribute4(l_rec_last)              := p_lpn_table(i).attribute4;
      x_lpn_bulk_rec.attribute5(l_rec_last)              := p_lpn_table(i).attribute5;
      x_lpn_bulk_rec.attribute6(l_rec_last)              := p_lpn_table(i).attribute6;
      x_lpn_bulk_rec.attribute7(l_rec_last)              := p_lpn_table(i).attribute7;
      x_lpn_bulk_rec.attribute8(l_rec_last)              := p_lpn_table(i).attribute8;
      x_lpn_bulk_rec.attribute9(l_rec_last)              := p_lpn_table(i).attribute9;
      x_lpn_bulk_rec.attribute10(l_rec_last)             := p_lpn_table(i).attribute10;
      x_lpn_bulk_rec.attribute11(l_rec_last)             := p_lpn_table(i).attribute11;
      x_lpn_bulk_rec.attribute12(l_rec_last)             := p_lpn_table(i).attribute12;
      x_lpn_bulk_rec.attribute13(l_rec_last)             := p_lpn_table(i).attribute13;
      x_lpn_bulk_rec.attribute14(l_rec_last)             := p_lpn_table(i).attribute14;
      x_lpn_bulk_rec.attribute15(l_rec_last)             := p_lpn_table(i).attribute15;
    END LOOP;
  END IF;
END To_LPNBulkRecType;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

FUNCTION To_LPNBulkRecType (
  p_lpn_table IN WMS_Data_Type_Definitions_PUB.LPNTableType
)
RETURN LPNBulkRecType
IS
l_lpn_bulk_rec LPNBulkRecType;

BEGIN
  To_LPNBulkRecType (
    p_lpn_table    => p_lpn_table
  , p_table_first  => null
  , p_table_last   => null
  , p_record_last  => null
  , x_lpn_bulk_rec => l_lpn_bulk_rec );

  RETURN l_lpn_bulk_rec;
END To_LPNBulkRecType;

FUNCTION To_DeliveryDetailsRecType (
  p_lpn_record IN WMS_Data_Type_Definitions_PUB.LPNRecordType
)
RETURN WSH_Glbl_Var_Strct_GRP.Delivery_Details_Rec_Type IS

l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_wsh_dd_rec WSH_Glbl_Var_Strct_GRP.Delivery_Details_Rec_Type;

BEGIN

 l_wsh_dd_rec.lpn_id            := p_lpn_record.lpn_id;
 l_wsh_dd_rec.container_name    := p_lpn_record.license_plate_number;
 l_wsh_dd_rec.inventory_item_id := p_lpn_record.inventory_item_id;

 l_wsh_dd_rec.organization_id   := p_lpn_record.organization_id;
 l_wsh_dd_rec.subinventory      := p_lpn_record.subinventory_code;
 l_wsh_dd_rec.locator_id        := p_lpn_record.locator_id;

 l_wsh_dd_rec.gross_weight      := p_lpn_record.gross_weight;
 l_wsh_dd_rec.weight_uom_code   := p_lpn_record.gross_weight_uom_code;

 l_wsh_dd_rec.filled_volume     := p_lpn_record.content_volume;
 l_wsh_dd_rec.volume_uom_code   := p_lpn_record.content_volume_uom_code;

 -- Need to caclcuate this net_weight = gross_weight - tare_weight
 IF ( NVL(p_lpn_record.tare_weight, 0) = 0 OR p_lpn_record.tare_weight_uom_code IS NULL ) THEN
   l_wsh_dd_rec.net_weight := p_lpn_record.gross_weight;
 ELSIF ( NVL(p_lpn_record.gross_weight, 0) = 0 OR p_lpn_record.gross_weight_uom_code IS NULL ) THEN
   l_wsh_dd_rec.net_weight      := 0;
   l_wsh_dd_rec.weight_uom_code := p_lpn_record.tare_weight_uom_code;
 ELSIF ( p_lpn_record.tare_weight_uom_code = p_lpn_record.gross_weight_uom_code ) THEN
   l_wsh_dd_rec.net_weight := p_lpn_record.gross_weight - p_lpn_record.tare_weight;
 ELSE -- Both are not null but with different UOMs need to convert
   l_wsh_dd_rec.net_weight := Convert_UOM(p_lpn_record.inventory_item_id, p_lpn_record.tare_weight, p_lpn_record.tare_weight_uom_code, p_lpn_record.gross_weight_uom_code);
   l_wsh_dd_rec.net_weight := p_lpn_record.gross_weight - l_wsh_dd_rec.net_weight;
 END IF;

 IF ( l_wsh_dd_rec.net_weight < 0 ) THEN
   l_wsh_dd_rec.net_weight := 0;
 END IF;

 -- Need to convert container volume into the content volume uom for shipping
 IF ( NVL(p_lpn_record.container_volume, -1) < 0 OR p_lpn_record.container_volume_uom IS NULL ) THEN
   l_wsh_dd_rec.volume := NULL;
 ELSIF ( p_lpn_record.container_volume_uom = NVL(p_lpn_record.content_volume_uom_code, p_lpn_record.container_volume_uom) ) THEN
   l_wsh_dd_rec.volume          := p_lpn_record.container_volume;
   l_wsh_dd_rec.volume_uom_code := p_lpn_record.container_volume_uom;
 ELSE
   l_wsh_dd_rec.volume := Convert_UOM(p_lpn_record.inventory_item_id, p_lpn_record.container_volume, p_lpn_record.container_volume_uom, p_lpn_record.content_volume_uom_code);
 END IF;

 IF ( l_debug = 1 ) THEN
   mdebug('ddrectype lpnid='||l_wsh_dd_rec.lpn_id||' lpn='||l_wsh_dd_rec.container_name||' itm='||l_wsh_dd_rec.inventory_item_id||' org='||l_wsh_dd_rec.organization_id||' sub='||l_wsh_dd_rec.subinventory||' loc='||l_wsh_dd_rec.locator_id, G_INFO);
   mdebug('gwt='||l_wsh_dd_rec.gross_weight||' nwt='||l_wsh_dd_rec.net_weight||' wuom='||l_wsh_dd_rec.weight_uom_code||' fvol='||l_wsh_dd_rec.filled_volume||' vol='||l_wsh_dd_rec.volume||' vuom='||l_wsh_dd_rec.volume_uom_code, G_INFO);
 END IF;

 RETURN l_wsh_dd_rec;
END To_DeliveryDetailsRecType;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Get_Greater_Qty (
  p_debug             IN         NUMBER
, p_inventory_item_id IN         NUMBER
, p_quantity1         IN         NUMBER
, p_quantity1_uom     IN         VARCHAR2
, p_quantity2         IN         NUMBER
, p_quantity2_uom     IN         VARCHAR2
, x_greater_qty       OUT NOCOPY NUMBER
, x_greater_qty_uom   OUT NOCOPY VARCHAR2
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Get_Greater_Qty';

BEGIN
  IF ( NVL(p_quantity1, 0) = 0 OR p_quantity1_uom IS NULL ) THEN
    x_greater_qty     := p_quantity2;
    x_greater_qty_uom := p_quantity2_uom;
  ELSIF ( NVL(p_quantity2, 0) = 0 OR p_quantity2_uom IS NULL ) THEN
    x_greater_qty     := p_quantity1;
    x_greater_qty_uom := p_quantity1_uom;
  ELSIF ( p_quantity1_uom = p_quantity2_uom ) THEN
    x_greater_qty     := GREATEST(p_quantity1, p_quantity2);
    x_greater_qty_uom := p_quantity2_uom;
  ELSE -- Both are not null but with different UOMs need to convert
    x_greater_qty_uom := p_quantity2_uom;

    x_greater_qty := Convert_UOM(p_inventory_item_id, p_quantity1, p_quantity1_uom, x_greater_qty_uom);
    x_greater_qty := GREATEST(x_greater_qty, p_quantity2);
  END IF;

  IF (p_debug = 1) THEN
    mdebug('x_greater_qty='||x_greater_qty||' x_greater_qty_uom='||x_greater_qty_uom, G_INFO);
  END IF;
END Get_Greater_Qty;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Calc_Vol_Change (
  p_debug             IN         NUMBER
, p_old_lpn           IN         WMS_Data_Type_Definitions_PUB.LPNRecordType
, p_new_lpn           IN         WMS_Data_Type_Definitions_PUB.LPNRecordType
, p_volume_change     OUT NOCOPY NUMBER
, p_volume_uom_change OUT NOCOPY VARCHAR2
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Calc_Vol_Change';
l_progress             VARCHAR2(500) := 'Entered API';

l_old_max_volume       NUMBER;
l_old_max_volume_uom   VARCHAR2(3);
l_new_max_volume       NUMBER;
l_new_max_volume_uom   VARCHAR2(3);

BEGIN
  l_progress := 'Calculate the greater for old container/content volume';
  -- First determine which was greater before update, container or content
  Get_Greater_Qty (
    p_debug             => p_debug
  , p_inventory_item_id => p_old_lpn.inventory_item_id
  , p_quantity1         => p_old_lpn.container_volume
  , p_quantity1_uom     => p_old_lpn.container_volume_uom
  , p_quantity2         => p_old_lpn.content_volume
  , p_quantity2_uom     => p_old_lpn.content_volume_uom_code
  , x_greater_qty       => l_old_max_volume
  , x_greater_qty_uom   => l_old_max_volume_uom );

  IF (p_debug = 1) THEN
    mdebug('old max vol='||l_old_max_volume||' old max vol uom='||l_old_max_volume_uom, G_INFO);
  END IF;

  Get_Greater_Qty (
    p_debug             => p_debug
  , p_inventory_item_id => p_new_lpn.inventory_item_id
  , p_quantity1         => p_new_lpn.container_volume
  , p_quantity1_uom     => p_new_lpn.container_volume_uom
  , p_quantity2         => p_new_lpn.content_volume
  , p_quantity2_uom     => p_new_lpn.content_volume_uom_code
  , x_greater_qty       => l_new_max_volume
  , x_greater_qty_uom   => l_new_max_volume_uom );

  IF (p_debug = 1) THEN
    mdebug('new max vol='||l_new_max_volume||' new max vol uom='||l_new_max_volume_uom, G_INFO);
  END IF;

  -- Now we need to compare the difference between the greatest of the new and old
  -- volumes to get the change in volume
  -- again if the lpn is newly packed, then just use the new value
  IF ( (p_old_lpn.parent_lpn_id IS NULL AND p_new_lpn.parent_lpn_id IS NOT NULL) OR
       NVL(l_old_max_volume, 0) = 0 OR l_old_max_volume_uom IS NULL ) THEN
    p_volume_change     := l_new_max_volume;
    p_volume_uom_change := l_new_max_volume_uom;
  ELSIF ( NVL(l_new_max_volume, 0) = 0 OR l_new_max_volume_uom IS NULL ) THEN
    p_volume_change     := 0 - l_old_max_volume;
    p_volume_uom_change := l_old_max_volume_uom;
  ELSIF ( l_old_max_volume_uom = l_new_max_volume_uom ) THEN
    p_volume_change     := l_new_max_volume - l_old_max_volume;
    p_volume_uom_change := l_new_max_volume_uom;
  ELSE -- Both are not null but with different UOMs need to convert
    l_old_max_volume     := Convert_UOM(p_new_lpn.inventory_item_id, l_old_max_volume, l_old_max_volume_uom, l_new_max_volume_uom);
    -- Change old max volume uom just for completeness sake
    l_old_max_volume_uom := l_new_max_volume_uom;

    p_volume_change     := l_new_max_volume - l_old_max_volume;
    p_volume_uom_change := l_new_max_volume_uom;
  END IF;

  IF (p_debug = 1) THEN
    mdebug('change vol='||p_volume_change||' change vuom='||p_volume_uom_change, G_INFO);
  END IF;
END;

--Bug 4144326. Added the following procedure.
--This procedure has to be called with the LPN before updating the attributes.
--This procedure will calculate the change in weight and volume for the LPN
--and update the Locator capacity with the difference.
PROCEDURE Update_Locator_Capacity (
  x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
, p_organization_id   IN         NUMBER
, p_subinventory      IN         VARCHAR2
, p_locator_id        IN         NUMBER
, p_weight_change     IN         NUMBER
, p_weight_uom_change IN         VARCHAR2
, p_volume_change     IN         NUMBER
, p_volume_uom_change IN         VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR2(30) := 'Update_Locator_Capacity';
l_debug                NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
wtdiff                 NUMBER := 0;
voldiff                NUMBER := 0;
l_loc_wt_uom           VARCHAR2(3);
l_loc_vol_uom          VARCHAR2(3);

BEGIN
   -- Standard Start of API savepoint
  SAVEPOINT WMS_Update_Locator_Capacity;

  x_return_status := fnd_api.g_ret_sts_success ; --set to Success by default.

  IF (l_debug = 1) THEN
    mdebug(l_api_name|| ' Entered ' ||g_pkg_version, 1);
    mdebug('orgid='||p_organization_id||' sub='||p_subinventory||' loc='||p_locator_id||' wt='||p_weight_change||' wuom='||p_weight_uom_change||' vol='||p_volume_change||' vuom='||p_volume_uom_change, G_INFO);
  END IF;


  -- Bug 5150314, LPNs in non wms orgs may not have sub and loc info
  -- bypass the update in this case
  IF ( p_subinventory IS NOT NULL AND p_locator_id IS NOT NULL ) THEN
    g_progress := 'Get UOM for Weight and volume of Locator';

    -- Get locator information from cache
    /*IF NOT ( INV_Cache.set_to_locator( p_locator_id ) THEN
      --set_to_locator not implemented
    END IF;*/

    SELECT mil.location_weight_uom_code
         , mil.volume_uom_code
    INTO   l_loc_wt_uom
         , l_loc_vol_uom
    FROM   mtl_item_locations mil
    WHERE  mil.organization_id = p_organization_id
    AND    mil.subinventory_code = p_subinventory
    AND    mil.inventory_location_id = p_locator_id;

    IF (l_debug = 1) THEN
      mdebug('Got locator uoms location_weight_uom_code='||l_loc_wt_uom||' volume_uom_code='||l_loc_vol_uom, G_INFO);
    END IF;

    -- Find out the weight difference
    IF ( l_loc_wt_uom IS NOT NULL ) THEN
      IF ( NVL(p_weight_change, 0) <> 0 AND p_weight_uom_change IS NOT NULL ) THEN
        g_progress := 'Convert change in weight to locator weight uom';
        wtdiff := Convert_UOM (
                    p_inventory_item_id => 0
                  , p_fm_quantity       => p_weight_change
                  , p_fm_uom            => p_weight_uom_change
                  , p_to_uom            => l_loc_wt_uom );
      END IF;
    END IF;

    -- Find out the volume difference
    IF ( l_loc_vol_uom IS NOT NULL ) THEN
      IF ( NVL(p_volume_change, 0) <> 0 AND p_volume_uom_change IS NOT NULL) THEN
         g_progress := 'Convert change in volume to locator volume uom';
         voldiff := Convert_UOM (
                     p_inventory_item_id => 0
                   , p_fm_quantity       => p_volume_change
                   , p_fm_uom            => p_volume_uom_change
                   , p_to_uom            => l_loc_vol_uom );
      END IF;
    END IF;
  END IF;

  IF (l_debug = 1) THEN
    mdebug('wtdiff='||wtdiff||' voldiff='||voldiff, G_INFO);
  END IF;

  IF ( wtdiff <> 0 OR  voldiff <> 0 ) THEN
    g_progress := 'Update Locator capacity';

    UPDATE mtl_item_locations mil
    SET current_weight = nvl(current_weight,0) + wtdiff
      , available_weight = nvl(available_weight,0) - wtdiff
      , current_cubic_area = nvl(current_cubic_area,0) + voldiff
       , available_cubic_area =  nvl(available_cubic_area,0) - voldiff
    WHERE mil.organization_id = p_organization_id
    AND   mil.subinventory_code = p_subinventory
    AND   mil.inventory_location_id = p_locator_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error g_progress= '||g_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        mdebug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    ROLLBACK TO WMS_Update_Locator_Capacity;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Update_Locator_Capacity;


-- ======================================================================
-- FUNCTION Generate_Check_Digit
-- ======================================================================
-- Purpose
--     Generate the Check Digit for LPN using Modulo 10 Check Digit Algorithm
--      1. Consider the right most digit of the code to be in an 'even'
--           position and assign odd/even to each character moving from right to
--           left.
--      2. Sum the digits in all odd positions
--      3. Sum the digits in all even positions and multiply the result by 3 .
--      4. Sum the totals calculated in steps 2 and 3.
--      5. The Check digit is the number which, when added to the totals
--         calculated in step 4, result in a number  evenly divisible by 10.

-- Input Parameters
--    P_lpn_str  (Required)
--
-- Output value :
--    Valid single check digit .
--

FUNCTION Generate_Check_Digit( p_debug NUMBER, p_lpn_str IN VARCHAR2 )

RETURN NUMBER
IS
  l_api_name CONSTANT VARCHAR2(30)  := 'Generate_Check_Digit';

  L NUMBER;
  I NUMBER;
  l_evensum        NUMBER := 0;
  l_oddsum         NUMBER := 0;
  l_total          NUMBER := 0;
  l_checkdigit     NUMBER := 0;
  l_remainder      NUMBER := 0;

  l_length NUMBER;
  l_lpn_str varchar2(255);
BEGIN
  IF ( p_debug = 1 ) THEN
    mdebug('p_lpn_str : ' || p_lpn_str, G_INFO);
  END IF;

  L := 0;
  l_lpn_str := rtrim(p_lpn_str);
  l_length := LENGTH(l_lpn_str);

  FOR I IN REVERSE 1..l_length
  LOOP
    -- mdebug('l_lpn_str(' || I || ') : ' || to_number(substr(l_lpn_str,I,1)), G_INFO);
    IF (mod(L,2) = 0) THEN
      l_Evensum := l_Evensum + to_number(substr(l_lpn_str,I,1));
    ELSE
      l_Oddsum := l_Oddsum + to_number(substr(l_lpn_str,I,1));
    END IF;
    L := L + 1;
  END LOOP;

  l_Evensum := l_Evensum * 3;
  l_Total := l_Evensum + l_Oddsum;
  l_remainder := mod(l_total,10);

  IF ( p_debug = 1 ) THEN
    mdebug('l_total:' || l_total || ' l_remainder : ' || l_remainder, G_INFO);
  END IF;

  IF (l_remainder > 0) THEN
     l_checkdigit := 10 - l_remainder;
  END IF;

  IF ( p_debug = 1 ) THEN
    mdebug('l_checkdigit : ' || l_checkdigit, G_INFO);
  END IF;

  RETURN l_checkdigit;
END Generate_Check_Digit;


-- ----------------------------------------------------------------------------------
-- Added For LSP Project, bug 9087971
-- ----------------------------------------------------------------------------------
-- ======================================================================
-- PROCEDURE set_client_info
-- ======================================================================
-- Purpose
-- 			Following procedure will accept the client code of the item
-- 			and set the client record in global variable g_client_rec of this package.

-- Input Parameters
--    p_client_code 	client code of the item
--
-- Output value :
--    x_ret_status	Return Status
--

PROCEDURE set_client_info
(
  p_client_code IN VARCHAR2,
  x_ret_status OUT NOCOPY VARCHAR2
) IS
  l_api_name    CONSTANT VARCHAR2(30)  := 'set_client_info';
  l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_client_id NUMBER;
  l_client_rec inv_cache.ct_rec_type;
BEGIN
  SELECT client_id INTO l_client_id
  FROM MTL_CLIENT_PARAMETERS
  WHERE client_code = p_client_code;

  inv_cache.get_client_default_parameters
  ( p_client_id => l_client_id,
    x_return_status => x_ret_status,
    x_client_parameters_rec => l_client_rec
  );

  IF x_ret_status = fnd_api.g_ret_sts_success THEN
	g_client_rec := l_client_rec;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_ret_status := fnd_api.g_ret_sts_error;
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;
END;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Create_LPNs (
  p_api_version   IN            NUMBER
, p_init_msg_list IN            VARCHAR2
, p_commit        IN            VARCHAR2
, x_return_status OUT    NOCOPY VARCHAR2
, x_msg_count     OUT    NOCOPY NUMBER
, x_msg_data      OUT    NOCOPY VARCHAR2
, p_caller        IN            VARCHAR2
, p_lpn_table     IN OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Create_LPNs';
l_api_version CONSTANT NUMBER        := 1.0;
l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(500) := 'Entered API';
l_msgdata              VARCHAR2(1000);

l_lpn_bulk_rec  LPNBulkRecType;

l_user_id        NUMBER;
l_request_id     NUMBER;

l_label_status   VARCHAR2(300);
l_dummy_num      NUMBER;

-- Variables for call to Print_Label
l_input_param_tbl inv_label.input_parameter_rec_type;
l_return_status   VARCHAR2(30);

-- Variables used for Creating LPNs in shipping
l_detail_info_tab WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;
l_IN_rec          WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
l_OUT_rec         WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT CREATE_LPNS_PVT;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  -- API body
  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('ver='||p_api_version||' initmsg='||p_init_msg_list||' commit='||p_commit||' caller='||p_caller||' tabcnt='||p_lpn_table.last, G_INFO);
  END IF;

  l_progress := 'Getting any profile user values';

  SELECT fnd_global.user_id
       , FND_PROFILE.value('CONC_REQUEST_ID')
    INTO l_user_id
       , l_request_id
    FROM DUAL;

  IF (l_debug = 1) THEN
    mdebug('Got profile info user_id='||l_user_id||' request_id='||l_request_id , G_INFO);
  END IF;

  l_progress := 'Validation for each LPN in record';

  FOR i IN p_lpn_table.first .. p_lpn_table.last LOOP
    IF ( l_debug = 1 ) THEN
      mdebug('lpn='||p_lpn_table(i).license_plate_number||' org='||p_lpn_table(i).organization_id||' sub='||p_lpn_table(i).subinventory_code||' loc='||p_lpn_table(i).locator_id||' ctx='||p_lpn_table(i).lpn_context||
             ' itm='||p_lpn_table(i).inventory_item_id||' plpn='||p_lpn_table(i).parent_lpn_id||' olpn='||p_lpn_table(i).outermost_lpn_id, G_INFO);
      mdebug('gwt='||p_lpn_table(i).gross_weight||' gwuom='||p_lpn_table(i).gross_weight_uom_code||' twt='||p_lpn_table(i).tare_weight_uom_code|| ' twuom='||p_lpn_table(i).tare_weight_uom_code||
             ' ctrvuom='||p_lpn_table(i).container_volume_uom||' ctrvol='||p_lpn_table(i).container_volume||' cntvuom='||p_lpn_table(i).content_volume_uom_code||' cntvol='||p_lpn_table(i).content_volume, G_INFO);
    END IF;

    -- Organization is required.  Make sure that it is populated
    IF ( p_lpn_table(i).organization_id IS NULL ) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF ( p_lpn_table(i).inventory_item_id IS NOT NULL) THEN
      l_progress  := 'Calling INV_CACHE.Set_Item_Rec to get item values';

      IF ( inv_cache.set_item_rec(
             p_organization_id => p_lpn_table(i).organization_id
           , p_item_id         => p_lpn_table(i).inventory_item_id ) )
      THEN
        IF (l_debug = 1) THEN
          mdebug('Got Item info citm='||inv_cache.item_rec.container_item_flag||' snctl='||inv_cache.item_rec.serial_number_control_code, G_INFO);
          mdebug('wuom='||inv_cache.item_rec.weight_uom_code||' wt='||inv_cache.item_rec.unit_weight||' vuom='||inv_cache.item_rec.volume_uom_code||' vol='||inv_cache.item_rec.unit_volume, G_INFO);
        END IF;

        IF ( inv_cache.item_rec.container_item_flag = 'N' ) THEN
          IF (l_debug = 1) THEN
            mdebug(p_lpn_table(i).inventory_item_id || ' is not a container', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_ITEM_NOT_CONTAINER');
          fnd_message.set_token('ITEM', inv_cache.item_rec.segment1);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        p_lpn_table(i).tare_weight_uom_code := inv_cache.item_rec.weight_uom_code;
        p_lpn_table(i).tare_weight          := inv_cache.item_rec.unit_weight;
        p_lpn_table(i).container_volume_uom := inv_cache.item_rec.volume_uom_code;
        p_lpn_table(i).container_volume     := inv_cache.item_rec.unit_volume;
      ELSE
        l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid'||p_lpn_table(i).organization_id||' item id='||p_lpn_table(i).inventory_item_id;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- LPN Context cannot be null
    p_lpn_table(i).lpn_context := NVL(p_lpn_table(i).lpn_context, WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED);

    -- If context is pregenerated, do not allow sub and loc info
    IF ( p_lpn_table(i).lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED ) THEN
      p_lpn_table(i).subinventory_code := NULL;
      p_lpn_table(i).locator_id        := NULL;
    END IF;

    --Check LPN for leading or trailing spaces if they exist
    p_lpn_table(i).license_plate_number := RTRIM(LTRIM(p_lpn_table(i).license_plate_number,' '),' ');

    IF ( length(p_lpn_table(i).license_plate_number) = 0 ) THEN
      IF (l_debug = 1) THEN
        mdebug(' LPN name parameter consists of only spaces cannot create', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_LPN_INAPPROPRIATE_SPACES');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT wms_license_plate_numbers_s1.NEXTVAL
    INTO   p_lpn_table(i).lpn_id
    FROM   DUAL;

    IF (l_debug = 1) THEN
      mdebug('Created lpn_id='||p_lpn_table(i).lpn_id||' for LPN '||p_lpn_table(i).license_plate_number, G_INFO);
    END IF;

    p_lpn_table(i).outermost_lpn_id := p_lpn_table(i).lpn_id;

    l_progress := 'Passed validation inserting into bulk table';

    To_LPNBulkRecType(
      p_lpn_table    => p_lpn_table
    , p_table_first  => i
    , p_table_last   => i
    , p_record_last  => l_lpn_bulk_rec.lpn_id.last
    , x_lpn_bulk_rec => l_lpn_bulk_rec );

    -- Insert into label printing table
    l_input_param_tbl(i).lpn_id := p_lpn_table(i).lpn_id;

    -- If caller is shipping we need to put LPNs in WDD as well
    -- since they are in WDD, we will need to default the LPNs to picked
    IF ( p_caller like 'WSH%' ) THEN
      l_detail_info_tab(i).lpn_id            := p_lpn_table(i).lpn_id;
      l_detail_info_tab(i).container_name    := p_lpn_table(i).license_plate_number;
      l_detail_info_tab(i).organization_id   := p_lpn_table(i).organization_id;
      l_detail_info_tab(i).subinventory      := p_lpn_table(i).subinventory_code;
      l_detail_info_tab(i).locator_id        := p_lpn_table(i).locator_id;
      l_detail_info_tab(i).inventory_item_id := p_lpn_table(i).inventory_item_id;

      l_detail_info_tab(i).net_weight        := p_lpn_table(i).tare_weight;
      l_detail_info_tab(i).gross_weight      := p_lpn_table(i).tare_weight;
      l_detail_info_tab(i).weight_uom_code   := p_lpn_table(i).tare_weight_uom_code;

      l_detail_info_tab(i).filled_volume     := NULL;
      l_detail_info_tab(i).volume            := p_lpn_table(i).container_volume;
      l_detail_info_tab(i).volume_uom_code   := p_lpn_table(i).container_volume_uom;
    END IF;
  END LOOP;

  -- Insert the newly created lpn id/license plate number record into the table
  BEGIN
    IF (l_debug = 1) THEN
      mdebug('Bulk insert LPNs in WLPN: '||to_char(l_lpn_bulk_rec.lpn_id.first)||'-'||to_char(l_lpn_bulk_rec.lpn_id.last), G_INFO);
    END IF;

    FORALL j IN l_lpn_bulk_rec.lpn_id.first..l_lpn_bulk_rec.lpn_id.last
    INSERT INTO wms_license_plate_numbers (
      last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , request_id

    , lpn_id
    , license_plate_number
    , parent_lpn_id
    , outermost_lpn_id
    , lpn_context
    , sealed_status

    , organization_id
    , subinventory_code
    , locator_id

    , inventory_item_id
    , revision
    , lot_number
    , serial_number
    , cost_group_id

    , tare_weight_uom_code
    , tare_weight
    , gross_weight_uom_code
    , gross_weight
    , container_volume_uom
    , container_volume
    , content_volume_uom_code
    , content_volume

    , source_type_id
    , source_header_id
    , source_line_id
    , source_line_detail_id
    , source_name
    )
    VALUES (
      SYSDATE
    , l_user_id
    , SYSDATE
    , l_user_id
    , l_request_id

    , l_lpn_bulk_rec.lpn_id(j)
    , l_lpn_bulk_rec.license_plate_number(j)
    , l_lpn_bulk_rec.parent_lpn_id(j)
    , l_lpn_bulk_rec.outermost_lpn_id(j)
    , l_lpn_bulk_rec.lpn_context(j)
    , 2 --sealed_status

    , l_lpn_bulk_rec.organization_id(j)
    , l_lpn_bulk_rec.subinventory_code(j)
    , l_lpn_bulk_rec.locator_id(j)

    , l_lpn_bulk_rec.inventory_item_id(j)
    , l_lpn_bulk_rec.revision(j)
    , l_lpn_bulk_rec.lot_number(j)
    , l_lpn_bulk_rec.serial_number(j)
    , l_lpn_bulk_rec.cost_group_id(j)

    , l_lpn_bulk_rec.tare_weight_uom_code(j)
    , l_lpn_bulk_rec.tare_weight(j)
    , l_lpn_bulk_rec.tare_weight_uom_code(j)
    , l_lpn_bulk_rec.tare_weight(j)
    , l_lpn_bulk_rec.container_volume_uom(j)
    , l_lpn_bulk_rec.container_volume(j)
    , l_lpn_bulk_rec.content_volume_uom_code(j)
    , NULL --content_volume

    , l_lpn_bulk_rec.source_type_id(j)
    , l_lpn_bulk_rec.source_header_id(j)
    , l_lpn_bulk_rec.source_line_id(j)
    , l_lpn_bulk_rec.source_line_detail_id(j)
    , l_lpn_bulk_rec.source_name(j)
    );
    IF (l_debug = 1) THEN
      mdebug('Bulk insert LPNs in WLPN done count='||SQL%ROWCOUNT, G_INFO);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mdebug('Insert into WLPN failed SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
      END IF;

      IF ( SQLCODE = 00001 ) THEN
        FOR k IN l_lpn_bulk_rec.lpn_id.first..l_lpn_bulk_rec.lpn_id.last LOOP
          --l_progress := 'Validate if LPN already exists in the system';
          BEGIN
            SELECT 1 INTO l_dummy_num
            FROM   wms_license_plate_numbers
            WHERE  license_plate_number = l_lpn_bulk_rec.license_plate_number(k);

            IF ( l_debug = 1 ) THEN
              mdebug('LPN '||l_lpn_bulk_rec.license_plate_number(k)||' already exists, cannot create it', G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_DUPLICATE_LPN');
            fnd_message.set_token('LPN', l_lpn_bulk_rec.license_plate_number(k));
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
          END;
        END LOOP;
      END IF;

      l_progress := 'Could not find reason for LPN insert failure. Give generic failure msg';
      fnd_message.set_name('WMS', 'WMS_LPN_NOTGEN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
  END;

  l_progress := 'Create LPN call to label printing';

  BEGIN
    inv_label.print_label (
      p_api_version        => 1.0
    , x_return_status      => l_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , x_label_status       => l_label_status
    , p_print_mode         => 2
    , p_business_flow_code => 16
    , p_input_param_rec    => l_input_param_tbl );

    IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
      IF (l_debug = 1) THEN
        mdebug('failed to print labels in create_lpns', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
      fnd_msg_pub.ADD;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mdebug('Exception occured while calling print_label in create_lpns', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
      fnd_msg_pub.ADD;
  END;

  l_progress := 'Call shipping with new LPNs in need be';
  IF ( l_detail_info_tab.last > 0 )THEN
    IF (l_debug = 1) THEN
      mdebug('Calling Create_Update_Containers size='||l_detail_info_tab.last, G_INFO);
    END IF;

    l_IN_rec.caller      := 'WMS';
    l_IN_rec.action_code := 'CREATE';

    WSH_WMS_LPN_GRP.Create_Update_Containers (
      p_api_version     => 1.0
    , p_init_msg_list   => fnd_api.g_false
    , p_commit          => fnd_api.g_false
    , x_return_status   => x_return_status
    , x_msg_count       => x_msg_count
    , x_msg_data        => x_msg_data
    , p_detail_info_tab => l_detail_info_tab
    , p_IN_rec          => l_IN_rec
    , x_OUT_rec         => l_OUT_rec );

    IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
      IF (l_debug = 1) THEN
        mdebug('Create_Update_Containers Failed', G_ERROR);
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSIF ( l_debug = 1 ) THEN
      mdebug('Done with Create_Update_Containers', G_INFO);
    END IF;
  END IF;

  l_progress := 'End of API body';

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and data
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
      mdebug('msg: '||l_msgdata, G_ERROR);
    END IF;
    ROLLBACK TO CREATE_LPNS_PVT;

    -- Failed to generate remove lpn_ids from table
    FOR i IN p_lpn_table.first .. p_lpn_table.last LOOP
      p_lpn_table(i).lpn_id := NULL;
    END LOOP;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WMS', 'WMS_LPN_NOTGEN');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;
    ROLLBACK TO CREATE_LPNS_PVT;

    -- Failed to generate remove lpn_ids from table
    FOR i IN p_lpn_table.first .. p_lpn_table.last LOOP
      p_lpn_table(i).lpn_id := NULL;
    END LOOP;
END Create_LPNs;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Auto_Create_LPNs (
  p_api_version         IN         NUMBER
, p_init_msg_list       IN         VARCHAR2
, p_commit              IN         VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_caller              IN         VARCHAR2
, p_quantity            IN         NUMBER
, p_lpn_prefix          IN         VARCHAR2
, p_lpn_suffix          IN         VARCHAR2
, p_starting_number     IN         NUMBER
, p_total_lpn_length    IN         NUMBER
, p_ucc_128_suffix_flag IN         VARCHAR2
, p_lpn_attributes      IN         WMS_Data_Type_Definitions_PUB.LPNRecordType
, p_serial_ranges       IN         WMS_Data_Type_Definitions_PUB.SerialRangeTableType
, x_created_lpns        OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
) IS

BEGIN
 Auto_Create_LPNs (
  p_api_version         =>	p_api_version
, p_init_msg_list       =>	p_init_msg_list
, p_commit              =>	p_commit
, x_return_status       =>	x_return_status
, x_msg_count           =>	x_msg_count
, x_msg_data            =>	x_msg_data
, p_caller              =>	p_caller
, p_quantity            =>	p_quantity
, p_lpn_prefix          =>	p_lpn_prefix
, p_lpn_suffix          =>	p_lpn_suffix
, p_starting_number     =>	p_starting_number
, p_total_lpn_length    =>	p_total_lpn_length
, p_ucc_128_suffix_flag =>	p_ucc_128_suffix_flag
, p_lpn_attributes      =>	p_lpn_attributes
, p_serial_ranges       =>	p_serial_ranges
, x_created_lpns        =>	x_created_lpns
, p_client_code		=>	NULL
);
END Auto_Create_LPNs;

-- ----------------------------------------------------------------------------------
-- Added For LSP Project, bug 9087971
-- ----------------------------------------------------------------------------------

	PROCEDURE Get_Upd_Client_LPN_Start_Num (
	  p_client_id   IN         NUMBER
	, p_qty      IN         NUMBER
	, x_curr_seq OUT NOCOPY NUMBER
	) IS PRAGMA AUTONOMOUS_TRANSACTION;
	l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
	l_lpn_start_num NUMBER:=0;

	BEGIN

	  SELECT lpn_starting_number INTO l_lpn_start_num
	    FROM mtl_client_parameters
	    WHERE client_id = p_client_id
	    FOR UPDATE;

	  UPDATE mtl_client_parameters
	    SET lpn_starting_number  =  l_lpn_start_num+p_qty,
	    last_update_date         =  SYSDATE,
	    last_updated_by          =  FND_GLOBAL.USER_ID
	    WHERE client_id = p_client_id;

	  x_curr_seq:=l_lpn_start_num;

	  COMMIT;
	END Get_Upd_Client_LPN_Start_Num;


-- ----------------------------------------------------------------------------------
-- Added For LSP Project, bug 9087971
-- Overloaded procedure for LSPs with additional parameter as p_client_code.
-- ----------------------------------------------------------------------------------

PROCEDURE Auto_Create_LPNs (
  p_api_version         IN         NUMBER
, p_init_msg_list       IN         VARCHAR2
, p_commit              IN         VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_caller              IN         VARCHAR2
, p_quantity            IN         NUMBER
, p_lpn_prefix          IN         VARCHAR2
, p_lpn_suffix          IN         VARCHAR2
, p_starting_number     IN         NUMBER
, p_total_lpn_length    IN         NUMBER
, p_ucc_128_suffix_flag IN         VARCHAR2
, p_lpn_attributes      IN         WMS_Data_Type_Definitions_PUB.LPNRecordType
, p_serial_ranges       IN         WMS_Data_Type_Definitions_PUB.SerialRangeTableType
, x_created_lpns        OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
, p_client_code		IN         VARCHAR2   -- Adding for LSP, bug 9087971
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Auto_Create_LPNs New';
l_api_version CONSTANT NUMBER        := 1.0;
l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(500) := 'Entered API';
l_msgdata              VARCHAR2(1000);

-- Constants used for LPN processing
l_from_user   CONSTANT NUMBER := 1;
l_from_db_seq CONSTANT NUMBER := 2;
l_from_org    CONSTANT NUMBER := 3;
l_from_client CONSTANT NUMBER := 4;
l_lpn_tab     WMS_Data_Type_Definitions_PUB.LPNTableType;
l_serial_rec  WMS_Data_Type_Definitions_PUB.SerialRangeRecordType;

-- Local copies of input params that may need update from defaults
l_quantity            NUMBER       := p_quantity ;
l_lpn_prefix          VARCHAR2(50) := p_lpn_prefix;
l_lpn_suffix          VARCHAR2(50) := p_lpn_suffix;
l_total_lpn_length    NUMBER       := p_total_lpn_length;
l_ucc_128_suffix_flag VARCHAR2(1)  := p_ucc_128_suffix_flag;
l_client_code         VARCHAR2(40) := p_client_code; -- Increased the size to 40 for Bug 9575186
l_ret_status VARCHAR2(1);
-- Variable used to creaate LPN name
l_seq_source     NUMBER;
l_loop_cnt       NUMBER;
l_lpn_cnt        NUMBER;
l_curr_seq       NUMBER;
l_last_org_seq   NUMBER;
l_last_client_seq NUMBER;
l_lpn_seq_length NUMBER;
l_dummy_number   NUMBER;

-- Varibles used for Serial processing
l_current_serial VARCHAR2(30);
l_current_number NUMBER;
l_padded_length  NUMBER;

l_lsp_installed       NUMBER        := NVL(FND_PROFILE.VALUE('WMS_DEPLOYMENT_MODE'),1); --Added for LSPs, bug 9087971

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT AUTO_CREATE_LPNS_PVT;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  -- API body
  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('ver='||p_api_version||' initmsg='||p_init_msg_list||' commit='||p_commit||' caller='||p_caller, G_INFO);
    mdebug('org='||p_lpn_attributes.organization_id||' sub='||p_lpn_attributes.subinventory_code||' loc='||p_lpn_attributes.locator_id||' itm='||p_lpn_attributes.inventory_item_id||' pfx='||p_lpn_prefix||' sfx='||p_lpn_suffix||
           ' snum='||p_starting_number||' qty='||p_quantity||' ctx='||p_lpn_attributes.lpn_context||' lgth='||p_total_lpn_length||' ucc='||p_ucc_128_suffix_flag, G_INFO);
    mdebug('srctype='||p_lpn_attributes.source_type_id|| ' l_client_code=' || l_client_code||' srchdr='||p_lpn_attributes.source_header_id||' srcln='||p_lpn_attributes.source_line_id||' trxid='||p_lpn_attributes.source_transaction_id, G_INFO);
  END IF;

  l_progress := 'Validate quantity';
  IF ( NVL(p_quantity, -1) < 0 ) THEN
    fnd_message.set_name('WMS', 'WMS_INVALID_QTY');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  l_progress := 'Validate Organization ID';

  IF ( NOT Inv_Cache.set_org_rec( p_organization_id => p_lpn_attributes.organization_id ) )THEN
    IF (l_debug = 1) THEN
      mdebug(p_lpn_attributes.organization_id||' is an invalid organization id', G_ERROR);
    END IF;
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;


    l_progress := 'Validate Client Code';

    IF (l_lsp_installed = 3 AND l_client_code IS NOT NULL) THEN
      set_client_info (p_client_code => l_client_code,
                    x_ret_status  => l_ret_status);
	    IF (l_ret_status <> fnd_api.g_ret_sts_success )THEN
	      IF (l_debug = 1) THEN
	        mdebug(l_client_code||' is an invalid client code', G_ERROR);
	      END IF;
	      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CLIENT');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;
	    END IF;
	  END IF;


  IF (l_debug = 1) THEN
    mdebug('Got org info pfx='||inv_cache.org_rec.lpn_prefix||' sfx='||inv_cache.org_rec.lpn_suffix||' seq='||inv_cache.org_rec.lpn_starting_number||' lgth='||inv_cache.org_rec.total_lpn_length||' ucc='||inv_cache.org_rec.ucc_128_suffix_flag, 5);
  END IF;

  IF ( p_lpn_attributes.inventory_item_id IS NOT NULL) THEN
    l_progress := 'Validate Container Item';

    IF ( inv_cache.set_item_rec(
           p_organization_id => p_lpn_attributes.organization_id
         , p_item_id         => p_lpn_attributes.inventory_item_id ) )
    THEN
      IF (l_debug = 1) THEN
        mdebug('Itm info citm='||inv_cache.item_rec.container_item_flag||' snctl='||inv_cache.item_rec.serial_number_control_code, G_INFO);
      END IF;

      IF ( inv_cache.item_rec.container_item_flag = 'N' ) THEN
        IF (l_debug = 1) THEN
          mdebug(p_lpn_attributes.inventory_item_id|| ' is not a container', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_ITEM_NOT_CONTAINER');
        fnd_message.set_token('ITEM', inv_cache.item_rec.segment1);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid'||p_lpn_attributes.organization_id||' item id='||p_lpn_attributes.inventory_item_id;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  l_progress := 'Determine the source for LPN seq starting number';

  IF ( p_starting_number IS NOT NULL ) THEN
    IF ( p_starting_number < 0 ) THEN
      IF (l_debug = 1) THEN
        mdebug(p_starting_number || ' is an invalid start num', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_START_NUM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_seq_source := l_from_user;
    l_curr_seq   := p_starting_number;

    ELSIF ( l_lsp_installed = 3 AND l_client_code IS NOT NULL AND g_client_rec.client_rec.lpn_starting_number IS NOT NULL ) THEN
	    l_seq_source := l_from_client;
	    l_curr_seq   := null;

  ELSIF ( inv_cache.org_rec.lpn_starting_number IS NOT NULL ) THEN
    l_seq_source := l_from_org;
    l_curr_seq   := null;
  ELSE
    -- neither defined at org level or user level use db seq
    l_seq_source := l_from_db_seq;
  END IF;

  l_progress := 'UCC128 validation';
  -- If any user defined values are not given, use values defined
  -- at the organization level

  IF ( l_ucc_128_suffix_flag IS NULL ) THEN
    IF (l_seq_source = l_from_client) THEN
	      l_ucc_128_suffix_flag := g_client_rec.client_rec.ucc_128_suffix_flag;
	    ELSE
	      l_ucc_128_suffix_flag := inv_cache.org_rec.ucc_128_suffix_flag;
	    END IF;
  END IF;

  IF ( l_lpn_prefix = FND_API.G_MISS_CHAR ) THEN
    l_lpn_prefix := NULL;
  ELSE
    IF (l_seq_source = l_from_client) THEN
	      l_lpn_prefix := NVL(l_lpn_prefix, g_client_rec.client_rec.lpn_prefix);
	    ELSE
	      l_lpn_prefix := NVL(l_lpn_prefix, inv_cache.org_rec.lpn_prefix);
	    END IF;
  END IF;

  IF ( l_lpn_suffix = FND_API.G_MISS_CHAR ) THEN
    l_lpn_suffix := NULL;
  ELSE
    IF (l_seq_source = l_from_client) THEN
	      l_lpn_suffix := NVL(l_lpn_suffix, g_client_rec.client_rec.lpn_suffix );
	    ELSE
	      l_lpn_suffix := NVL(l_lpn_suffix, inv_cache.org_rec.lpn_suffix );
	    END IF;
  END IF;

  IF ( l_total_lpn_length = FND_API.G_MISS_NUM ) THEN
    l_total_lpn_length := NULL;
  ELSE
   	    IF (l_seq_source = l_from_client) THEN
	      l_total_lpn_length := NVL(l_total_lpn_length, g_client_rec.client_rec.total_lpn_length);
	    ELSE
	      l_total_lpn_length := NVL(l_total_lpn_length, inv_cache.org_rec.total_lpn_length);
	    END IF;
  END IF;

  IF ( l_ucc_128_suffix_flag = 'Y' ) THEN
    BEGIN
      l_dummy_number := to_number(l_lpn_prefix);
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          mdebug('LPN prefix is invalid: ' || l_lpn_prefix, G_ERROR);
        END IF;
        fnd_message.set_name('INV', 'INV_INTEGER_GREATER_THAN_0');
        fnd_message.set_token('ENTITY1','INV_LPN_PREFIX');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;
  END IF;

  IF ( l_total_lpn_length IS NOT NULL ) THEN
    l_lpn_seq_length := l_total_lpn_length - NVL(LENGTH(l_lpn_prefix), 0);

    -- UCC128 uses a check digit in place of suffix. subtract one for that digit
    IF ( l_ucc_128_suffix_flag = 'Y' ) THEN
      l_lpn_seq_length := l_lpn_seq_length - 1;
    ELSE
      l_lpn_seq_length := l_lpn_seq_length - NVL(LENGTH(l_lpn_suffix), 0);
    END IF;

    IF ( l_lpn_seq_length <= 0 ) THEN
      IF (l_debug = 1) THEN
        mdebug('total length '||l_total_lpn_length||' less than sum length of prefix '||l_lpn_prefix||' and suffix '||l_lpn_suffix, G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_LPN_TOTAL_LENGTH_INVALID');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  ELSE
    l_lpn_seq_length := 0;
  END IF;

  l_progress := 'Checking for serial numbers';

  IF ( p_serial_ranges.last > 0 AND p_serial_ranges(1).fm_serial_number IS NOT NULL ) THEN
    -- Check that item is under serial control
    IF ( p_lpn_attributes.inventory_item_id IS NULL OR inv_cache.item_rec.serial_number_control_code = 1 ) THEN
      IF (l_debug = 1) THEN
        mdebug('Item '||inv_cache.item_rec.inventory_item_id||' is not serial controlled', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- For now only support a single range of serial numbers
    l_serial_rec.fm_serial_number := p_serial_ranges(1).fm_serial_number;
    l_serial_rec.to_serial_number := NVL(p_serial_ranges(1).to_serial_number, p_serial_ranges(1).fm_serial_number);
    l_current_serial              := l_serial_rec.fm_serial_number;

    l_progress := 'Call this API to inv_serial_info';

    IF ( NOT mtl_serial_check.inv_serial_info (
               p_from_serial_number => l_serial_rec.fm_serial_number
             , p_to_serial_number   => l_serial_rec.to_serial_number
             , x_prefix             => l_serial_rec.prefix
             , x_quantity           => l_serial_rec.quantity
             , x_from_number        => l_serial_rec.fm_number
             , x_to_number          => l_serial_rec.to_number
             , x_errorcode          => l_dummy_number ) )
    THEN
      IF (l_debug = 1) THEN
        mdebug(l_serial_rec.to_serial_number||' failed INV_Serial_Info x_errorcode='||l_dummy_number, G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Quantity of LPNs will be determined by serial range
    l_quantity       := l_serial_rec.quantity;
    l_current_serial := l_serial_rec.fm_serial_number;
    l_current_number := l_serial_rec.fm_number;

    IF (l_debug = 1) THEN
      mdebug('SN info qty='||l_quantity||' pfx='||l_serial_rec.prefix||' fm#='||l_serial_rec.fm_number||' to#='||l_serial_rec.to_number, G_INFO);
    END IF;
  ELSE
    l_current_serial := NULL;
  END IF;

  IF (l_debug = 1) THEN
    mdebug('prefix='||l_lpn_prefix||' suffix='||l_lpn_suffix||' seq='||l_curr_seq||' suffix flag='||l_ucc_128_suffix_flag, G_INFO);
  END IF;

  l_loop_cnt := 1;
  l_lpn_cnt  := 1;

  WHILE ( l_lpn_cnt <= l_quantity ) LOOP

    IF ( l_seq_source = l_from_db_seq ) THEN
      SELECT wms_license_plate_numbers_s2.NEXTVAL
      INTO l_curr_seq
      FROM DUAL;
    ELSIF ( l_seq_source = l_from_client ) THEN
	      -- If taken from client parameters make sure the new seq is within the range
	      -- already allocated, if not will need to allocate more
	      IF ( l_curr_seq IS NULL OR l_curr_seq = l_last_client_seq ) THEN
	        Get_Upd_Client_LPN_Start_Num (
	          p_client_id   => g_client_rec.client_rec.client_id
	        , p_qty      => l_quantity - l_lpn_cnt + 1
	        , x_curr_seq => l_curr_seq );

	        -- Keep track of the last sequence fetched from the org params
	        l_last_client_seq := l_curr_seq + l_quantity - l_lpn_cnt + 1;
	        IF (l_debug = 1) THEN
	          mdebug('Got seq from client curr_seq='||l_curr_seq||' l_last_client_seq='||l_last_client_seq, G_INFO);
	        END IF;
	      END IF;
    ELSIF ( l_seq_source = l_from_org ) THEN
      -- If taken from org parameters make sure the new seq is within the range
      -- already allocated, if not will need to allocate more
      IF ( l_curr_seq IS NULL OR l_curr_seq = l_last_org_seq ) THEN
        Get_Update_LPN_Start_Num (
          p_org_id   => p_lpn_attributes.organization_id
        , p_qty      => l_quantity - l_lpn_cnt + 1
        , x_curr_seq => l_curr_seq );

        -- Keep track of the last sequence fetched from the org params
        l_last_org_seq := l_curr_seq + l_quantity - l_lpn_cnt + 1;
        IF (l_debug = 1) THEN
          mdebug('Got seq from org curr_seq='||l_curr_seq||' last_org_seq='||l_last_org_seq, G_INFO);
        END IF;
      END IF;
    END IF;

    -- Generate a valid license plate number
    l_lpn_tab(l_lpn_cnt).license_plate_number := l_lpn_prefix || LPAD(l_curr_seq, GREATEST(length(l_curr_seq), l_lpn_seq_length), '0');

    IF ( l_ucc_128_suffix_flag = 'Y' ) THEN
      l_progress := 'Call api to calculate and append check digit to end of LPN';
      l_lpn_tab(l_lpn_cnt).license_plate_number := l_lpn_tab(l_lpn_cnt).license_plate_number || Generate_Check_Digit(l_debug, l_lpn_tab(l_lpn_cnt).license_plate_number);
    ELSE
      l_progress := 'Not UCC128 LPN normal LPN name generatation';
      l_lpn_tab(l_lpn_cnt).license_plate_number := l_lpn_tab(l_lpn_cnt).license_plate_number || l_lpn_suffix;
    END IF;

    l_progress := 'Check that new LPN does not alreay exist in WLPN';

    BEGIN
      SELECT 1
      INTO   l_dummy_number
      FROM   WMS_LICENSE_PLATE_NUMBERS
      WHERE  license_plate_number = l_lpn_tab(l_lpn_cnt).license_plate_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_dummy_number := 2;
    END;

    IF ( l_dummy_number <> 1 ) THEN
      l_progress := 'LPN does not exist yet insert into LPN table';

      -- Validate LPN total length if total length is passed.
      IF ( l_total_lpn_length < length(l_lpn_tab(l_lpn_cnt).license_plate_number) ) THEN
        IF (l_debug = 1) THEN
          mdebug('LPN name '||l_lpn_tab(l_lpn_cnt).license_plate_number||' exceeds total length '||l_total_lpn_length, G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_LPN_TOTAL_LENGTH_INVALID');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := 'Insert the newly created lpn id/license plate number record into the table';

      l_lpn_tab(l_lpn_cnt).lpn_context             := p_lpn_attributes.lpn_context;
      l_lpn_tab(l_lpn_cnt).organization_id         := p_lpn_attributes.organization_id;
      l_lpn_tab(l_lpn_cnt).subinventory_code       := p_lpn_attributes.subinventory_code;
      l_lpn_tab(l_lpn_cnt).locator_id              := p_lpn_attributes.locator_id;

      l_lpn_tab(l_lpn_cnt).inventory_item_id       := p_lpn_attributes.inventory_item_id;
      l_lpn_tab(l_lpn_cnt).revision                := p_lpn_attributes.revision;
      l_lpn_tab(l_lpn_cnt).lot_number              := p_lpn_attributes.lot_number;
      l_lpn_tab(l_lpn_cnt).serial_number           := l_current_serial;
      l_lpn_tab(l_lpn_cnt).cost_group_id           := p_lpn_attributes.cost_group_id;

      l_lpn_tab(l_lpn_cnt).source_type_id          := p_lpn_attributes.source_type_id;
      l_lpn_tab(l_lpn_cnt).source_header_id        := p_lpn_attributes.source_header_id;
      l_lpn_tab(l_lpn_cnt).source_line_id          := p_lpn_attributes.source_line_id;
      l_lpn_tab(l_lpn_cnt).source_line_detail_id   := p_lpn_attributes.source_line_detail_id;
      l_lpn_tab(l_lpn_cnt).source_name             := p_lpn_attributes.source_name;
      l_lpn_tab(l_lpn_cnt).source_transaction_id   := p_lpn_attributes.source_transaction_id;

      IF (l_debug = 1) THEN
        mdebug('Created LPN name '||l_lpn_tab(l_lpn_cnt).license_plate_number||' lpn_cnt='||l_lpn_cnt||' curr_seq='||l_curr_seq||' loop_cnt='||l_loop_cnt, G_INFO);
      END IF;

      l_progress := 'Increment the current serial number';

      IF ( l_current_serial IS NOT NULL ) THEN
        l_padded_length  := LENGTH(l_current_serial) - LENGTH(l_current_number);
        l_current_number := l_current_number + 1;

        -- See bug 2375043 for info on why this is done
        IF ( l_serial_rec.prefix IS NOT NULL ) THEN
          l_current_serial := RPAD(l_serial_rec.prefix, l_padded_length, '0') || l_current_number;
        ELSE
          l_current_serial := RPAD('@',l_padded_length+1,'0') || l_current_number;
          l_current_serial := Substr(l_current_serial,2);
        END IF;
      END IF;

      l_progress := 'Done creating LPN name increment counter';
      l_lpn_cnt := l_lpn_cnt + 1;
    ELSE -- LPN already exists in WLPN
      IF ( l_seq_source = l_from_user ) THEN
        IF ( l_debug = 1 ) THEN
          mdebug('Cannot generate LPNs with user defined starting number', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_DUPLICATE_LPN');
        fnd_message.set_token('LPN', l_lpn_tab(l_lpn_cnt).license_plate_number);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSIF ( l_loop_cnt > l_quantity + 1000 ) THEN
        IF ( l_debug = 1 ) THEN
          mdebug('Cannot find valid LPN sequence after 1000 Attempts', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_GEN_LPN_LOOP_ERR');
        fnd_message.set_token('NUM', '1000');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSIF ( l_debug = 1 ) THEN
        mdebug('LPN '||l_lpn_tab(l_lpn_cnt).license_plate_number||' already exists trying new sequence', G_INFO);
      END IF;
    END IF;

    -- If LPN sequence is not taken from DB, need to incrament manually
    l_curr_seq := l_curr_seq + 1;

    -- Keep track of total number of loops done to avoid infinite loop
    l_loop_cnt := l_loop_cnt + 1;
  END LOOP;

  l_progress := 'Call Create_LPNs number of rec='||l_lpn_tab.last;

  Create_LPNs (
    p_api_version   => p_api_version
  , p_init_msg_list => fnd_api.g_false
  , p_commit        => fnd_api.g_false
  , x_return_status => x_return_status
  , x_msg_count     => x_msg_count
  , x_msg_data      => x_msg_data
  , p_caller        => p_caller
  , p_lpn_table     => l_lpn_tab );

  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF (l_debug = 1) THEN
      mdebug('Create_LPNs failed', G_ERROR);
    END IF;
    RAISE fnd_api.g_exc_error;
  END IF;

  x_created_lpns := l_lpn_tab;

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and data
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
      mdebug('msg: '||l_msgdata, G_ERROR);
    END IF;
    ROLLBACK TO AUTO_CREATE_LPNS_PVT;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WMS', 'WMS_LPN_GENERATION_FAIL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;
    ROLLBACK TO AUTO_CREATE_LPNS_PVT;
END Auto_Create_LPNs;




-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Modify_LPNs (
  p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2
, p_commit        IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_caller        IN         VARCHAR2
, p_lpn_table     IN         WMS_Data_Type_Definitions_PUB.LPNTableType
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Modify_LPNs';
l_api_version CONSTANT NUMBER        := 1.0;
l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(500) := 'Entered API';
l_msgdata              VARCHAR2(1000);
l_delivery_id          NUMBER ; --7119011
l_status_code          VARCHAR2(2) := 'OP'; --7119011 / 7603755
l_return_status        VARCHAR2(2); --7119011

CURSOR nested_parent_lpn_cursor (p_parent_lpn_id NUMBER) IS
  SELECT lpn_id
       , license_plate_number
       , parent_lpn_id
       , outermost_lpn_id
       , lpn_context

       , organization_id
       , subinventory_code
       , locator_id

       , inventory_item_id
       , revision
       , lot_number
       , serial_number
       , cost_group_id

       , tare_weight_uom_code
       , tare_weight
       , gross_weight_uom_code
       , gross_weight
       , container_volume_uom
       , container_volume
       , content_volume_uom_code
       , content_volume

       , source_type_id
       , source_header_id
       , source_line_id
       , source_line_detail_id
       , source_name

       , attribute_category
       , attribute1
       , attribute2
       , attribute3
       , attribute4
       , attribute5
       , attribute6
       , attribute7
       , attribute8
       , attribute9
       , attribute10
       , attribute11
       , attribute12
       , attribute13
       , attribute14
       , attribute15
    FROM wms_license_plate_numbers
   START WITH lpn_id = p_parent_lpn_id
 CONNECT BY lpn_id = PRIOR parent_lpn_id
     FOR UPDATE NOWAIT;

 CURSOR nested_child_lpn_cursor (p_lpn_id NUMBER) IS
   SELECT lpn_id
        , license_plate_number
        , parent_lpn_id
        , outermost_lpn_id
        , lpn_context

        , organization_id
        , subinventory_code
        , locator_id

        , inventory_item_id
        , revision
        , lot_number
        , serial_number
        , cost_group_id

        , tare_weight_uom_code
        , tare_weight
        , gross_weight_uom_code
        , gross_weight
        , container_volume_uom
        , container_volume
        , content_volume_uom_code
        , content_volume

        , source_type_id
        , source_header_id
        , source_line_id
        , source_line_detail_id
        , source_name

        , attribute_category
        , attribute1
        , attribute2
        , attribute3
        , attribute4
        , attribute5
        , attribute6
        , attribute7
        , attribute8
        , attribute9
        , attribute10
        , attribute11
        , attribute12
        , attribute13
        , attribute14
        , attribute15
     FROM wms_license_plate_numbers
    START WITH parent_lpn_id = p_lpn_id
  CONNECT BY parent_lpn_id = PRIOR lpn_id
      FOR UPDATE NOWAIT;

--Bug #3516547
CURSOR lpn_item_control_cursor (p_old_org_id NUMBER, p_new_org_id NUMBER, p_outermost_lpn_id NUMBER) IS
  SELECT wlc.rowid
       , wlc.inventory_item_id
       , msi.primary_uom_code
       , msi.serial_number_control_code
       , msi.lot_control_code
       , msi.revision_qty_control_code
    FROM wms_license_plate_numbers wlpn
       , wms_lpn_contents wlc
       , mtl_system_items msi
   WHERE wlpn.organization_id = p_old_org_id
     AND wlpn.outermost_lpn_id = p_outermost_lpn_id
     AND wlc.parent_lpn_id = wlpn.lpn_id
     AND msi.inventory_item_id = wlc.inventory_item_id
     AND msi.organization_id = p_new_org_id
   ORDER BY wlc.inventory_item_id;
--End of changes for Bug #3516547

-- Types needed for WSH_WMS_LPN_GRP.Create_Update_Containers
wsh_update_tbl  WSH_Glbl_Var_Strct_GRP.delivery_details_Attr_tbl_Type;
wsh_create_tbl  WSH_Glbl_Var_Strct_GRP.delivery_details_Attr_tbl_Type;
l_IN_rec        WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
l_OUT_rec       WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;

-- Types needed for WSH_WMS_LPN_GRP.Delivery_Detail_Action
l_wsh_del_det_id_tbl wsh_util_core.id_tab_type;
l_wsh_action_prms    WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
l_wsh_defaults       WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;
l_wsh_action_out_rec WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

-- Types needed for WSH_WMS_LPN_GRP.Delivery_Detail_Action
-- Need 2 different tables one for lpns that need to be unpacked one for
-- lpns thatn need to be deleted
l_wsh_unpack_lpn_id_tbl wsh_util_core.id_tab_type;
l_wsh_delete_lpn_id_tbl wsh_util_core.id_tab_type;

-- Variables used to store LPN information
l_lpn_ids       WMS_Data_Type_Definitions_PUB.NumberTableType;
l_outer_lpn_ids WMS_Data_Type_Definitions_PUB.NumberTableType;

l_lpn_tab_i     NUMBER;
l_tmp_i         NUMBER;
l_dummy_num     NUMBER;

l_tmp_new       WMS_Data_Type_Definitions_PUB.LPNRecordType;
l_tmp_old       WMS_Data_Type_Definitions_PUB.LPNRecordType;
l_new           WMS_Data_Type_Definitions_PUB.LPNRecordType;
l_old           WMS_Data_Type_Definitions_PUB.LPNRecordType;
l_lpns          WMS_Data_Type_Definitions_PUB.LPNTableType;
l_outer_lpns    WMS_Data_Type_Definitions_PUB.LPNTableType;
l_lpn_bulk_rec  LPNBulkRecType;

-- Temp variables needed for wt/vol calculation
l_change_in_gross_weight     NUMBER;
l_change_in_gross_weight_uom VARCHAR2(3);

l_change_in_weight     NUMBER;     --Added for Bug#6504032
l_change_in_weight_uom VARCHAR2(3);      --Added for Bug#6504032

-- bug5404902 added to store tare weight change
l_change_in_tare_weight     NUMBER;
l_change_in_tare_weight_uom VARCHAR2(3);

l_change_in_volume     NUMBER;
l_change_in_volume_uom VARCHAR2(3);

--Flag added to identify LPN context change from 'Loaded to Truck' to
--'Defined but not used' which is only for Internal Orders
--Bug number 5639121
l_internal_order_flag NUMBER := 0;
--Bug 8693053
 honor_case_pick_count NUMBER := 0;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT MODIFY_LPNS_PVT;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  -- API body
  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('ver='||p_api_version||' initmsg='||p_init_msg_list||' commit='||p_commit||' caller='||p_caller||' tabfst='||p_lpn_table.first||' tablst='||p_lpn_table.last, G_INFO);
  END IF;

  FOR lpn_tbl_cnt IN p_lpn_table.first .. p_lpn_table.last LOOP
    IF (l_debug = 1) THEN
      l_old := p_lpn_table(lpn_tbl_cnt);

      l_old.lpn_id                  := l_old.lpn_id;
      l_old.license_plate_number    := l_old.license_plate_number;
      l_old.parent_lpn_id           := substr(l_old.parent_lpn_id, 1, 10);
      l_old.outermost_lpn_id        := l_old.outermost_lpn_id;
      l_old.lpn_context             := l_old.lpn_context;

      l_old.organization_id         := l_old.organization_id;
      l_old.subinventory_code       := substr(l_old.subinventory_code, 1, 10);
      l_old.locator_id              := substr(l_old.locator_id, 1, 10);

      l_old.inventory_item_id       := substr(l_old.inventory_item_id, 1, 10);
      l_old.revision                := substr(l_old.revision, 1, 10);
      l_old.lot_number              := substr(l_old.lot_number, 1, 10);
      l_old.serial_number           := substr(l_old.serial_number, 1, 10);
      l_old.cost_group_id           := substr(l_old.cost_group_id, 1, 10);

      l_old.tare_weight_uom_code    := substr(l_old.tare_weight_uom_code, 1, 10);
      l_old.tare_weight             := substr(l_old.tare_weight, 1, 10);
      l_old.gross_weight_uom_code   := substr(l_old.gross_weight_uom_code, 1, 10);
      l_old.gross_weight            := substr(l_old.gross_weight, 1, 10);
      l_old.container_volume_uom    := substr(l_old.container_volume_uom, 1, 10);
      l_old.container_volume        := substr(l_old.container_volume, 1, 10);
      l_old.content_volume_uom_code := substr(l_old.content_volume_uom_code, 1, 10);
      l_old.content_volume          := substr(l_old.content_volume, 1, 10);

      l_old.source_type_id          := substr(l_old.source_type_id, 1, 10);
      l_old.source_header_id        := substr(l_old.source_header_id, 1, 10);
      l_old.source_line_id          := substr(l_old.source_line_id, 1, 10);
      l_old.source_line_detail_id   := substr(l_old.source_line_detail_id, 1, 10);
      l_old.source_name             := l_old.source_name;

      l_old.attribute_category      := substr(l_old.attribute_category, 1, 10);
      l_old.attribute1              := substr(l_old.attribute1, 1, 10);
      l_old.attribute2              := substr(l_old.attribute2, 1, 10);
      l_old.attribute3              := substr(l_old.attribute3, 1, 10);
      l_old.attribute4              := substr(l_old.attribute4, 1, 10);
      l_old.attribute5              := substr(l_old.attribute5, 1, 10);
      l_old.attribute6              := substr(l_old.attribute6, 1, 10);
      l_old.attribute7              := substr(l_old.attribute7, 1, 10);
      l_old.attribute8              := substr(l_old.attribute8, 1, 10);
      l_old.attribute9              := substr(l_old.attribute9, 1, 10);
      l_old.attribute10             := substr(l_old.attribute10, 1, 10);
      l_old.attribute11             := substr(l_old.attribute11, 1, 10);
      l_old.attribute12             := substr(l_old.attribute12, 1, 10);
      l_old.attribute13             := substr(l_old.attribute13, 1, 10);
      l_old.attribute14             := substr(l_old.attribute14, 1, 10);
      l_old.attribute15             := substr(l_old.attribute15, 1, 10);

      mdebug('-------------------------------------------------');
      mdebug('Values passed by caller to be updated l_lpn_tab_i='||l_lpn_tab_i||' lpn_tbl_cnt='||lpn_tbl_cnt, G_INFO);
      mdebug('lpnid='||l_old.lpn_id||' lpn='||l_old.license_plate_number||' ctx='||l_old.lpn_context||' plpn='||l_old.parent_lpn_id||' olpn='||l_old.outermost_lpn_id||' itm='||l_old.inventory_item_id||' rev='||l_old.revision, G_INFO);
      mdebug('lot='||l_old.lot_number||' sn='||l_old.serial_number||' cg='||l_old.cost_group_id||' org='||l_old.organization_id||' sub='||l_old.subinventory_code||' loc='||l_old.locator_id, G_INFO);
      mdebug('twt='||l_old.tare_weight||' twuom='||l_old.tare_weight_uom_code||' gwt='||l_old.gross_weight||' gwuom='||l_old.gross_weight_uom_code||
             ' ctrvol='||l_old.container_volume||' ctrvoluom='||l_old.container_volume_uom||' ctnvol='||l_old.content_volume||' ctvuom='||l_old.content_volume_uom_code, G_INFO);
      mdebug('stype='||l_old.source_type_id||' shdr='||l_old.source_header_id||' srcln='||l_old.source_line_id||' srclndt='||l_old.source_line_detail_id||' srcnm='||l_old.source_name, G_INFO);
      --mdebug('reuse='||l_old.lpn_reusability||' hom='||l_old.homogeneous_container||' stat='||l_old.status_id ||' seal='||l_old.sealed_status, G_INFO);
      mdebug('acat='||l_old.attribute_category||' a1='||l_old.attribute1||' a2='||l_old.attribute2||' a3='||l_old.attribute3||' a4='||l_old.attribute4||' a5='||l_old.attribute5||' a6='||l_old.attribute6||' a7='||l_old.attribute7, G_INFO);
      mdebug('a8='||l_old.attribute8||' a9='||l_old.attribute9||' a10='||l_old.attribute10||' a11='||l_old.attribute11||' a12='||l_old.attribute12||' a13='||l_old.attribute13||' a14='||l_old.attribute14||' a15='||l_old.attribute15, G_INFO);
      mdebug('-------------------------------------------------');
    END IF;

    l_progress := 'Validate and massage data given by user lpnid='||p_lpn_table(lpn_tbl_cnt).lpn_id;

    -- General validations for data protection
    IF ( p_lpn_table(lpn_tbl_cnt).outermost_lpn_id IS NOT NULL ) THEN
      -- Specific validations of attributes limited to certain callers
      IF ( NVL(p_caller, G_NULL_CHAR) <> 'WMS_PackUnpack_Container' ) THEN
        l_progress := 'Updating outermost_lpn_id is restricted to PackUnpack_Container API';
        fnd_message.set_name('WMS', 'WMS_UPDATE_LPN_ATTR_ERR');
        fnd_message.set_token('ATTR', 'outermost_lpn_id');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    l_progress := 'Done with general validation';

    IF ( l_lpn_ids.exists(p_lpn_table(lpn_tbl_cnt).lpn_id) ) THEN
      IF (l_debug = 1) THEN
        mdebug('LPN attributes already exist in table lpnid='||p_lpn_table(lpn_tbl_cnt).lpn_id, G_INFO);
      END IF;
      l_lpn_tab_i := l_lpn_ids(p_lpn_table(lpn_tbl_cnt).lpn_id);
      l_old       := l_lpns(l_lpn_tab_i);
    ELSE
      IF (l_debug = 1) THEN
        mdebug('Retrieve attributes of LPN lpnid='||p_lpn_table(lpn_tbl_cnt).lpn_id, G_INFO);
      END IF;
      l_lpn_tab_i := NULL;

      BEGIN
        SELECT lpn_id
             , license_plate_number
             , parent_lpn_id
             , outermost_lpn_id
             , lpn_context

             , organization_id
             , subinventory_code
             , locator_id

             , inventory_item_id
             , revision
             , lot_number
             , serial_number
             , cost_group_id

             , tare_weight_uom_code
             , tare_weight
             , gross_weight_uom_code
             , gross_weight
             , container_volume_uom
             , container_volume
             , content_volume_uom_code
             , content_volume

             , source_type_id
             , source_header_id
             , source_line_id
             , source_line_detail_id
             , source_name

             , attribute_category
             , attribute1
             , attribute2
             , attribute3
             , attribute4
             , attribute5
             , attribute6
             , attribute7
             , attribute8
             , attribute9
             , attribute10
             , attribute11
             , attribute12
             , attribute13
             , attribute14
             , attribute15
          INTO l_old.lpn_id
             , l_old.license_plate_number
             , l_old.parent_lpn_id
             , l_old.outermost_lpn_id
             , l_old.lpn_context

             , l_old.organization_id
             , l_old.subinventory_code
             , l_old.locator_id

             , l_old.inventory_item_id
             , l_old.revision
             , l_old.lot_number
             , l_old.serial_number
             , l_old.cost_group_id

             , l_old.tare_weight_uom_code
             , l_old.tare_weight
             , l_old.gross_weight_uom_code
             , l_old.gross_weight
             , l_old.container_volume_uom
             , l_old.container_volume
             , l_old.content_volume_uom_code
             , l_old.content_volume

             , l_old.source_type_id
             , l_old.source_header_id
             , l_old.source_line_id
             , l_old.source_line_detail_id
             , l_old.source_name

             , l_old.attribute_category
             , l_old.attribute1
             , l_old.attribute2
             , l_old.attribute3
             , l_old.attribute4
             , l_old.attribute5
             , l_old.attribute6
             , l_old.attribute7
             , l_old.attribute8
             , l_old.attribute9
             , l_old.attribute10
             , l_old.attribute11
             , l_old.attribute12
             , l_old.attribute13
             , l_old.attribute14
             , l_old.attribute15
        FROM   wms_license_plate_numbers
        WHERE  lpn_id = p_lpn_table(lpn_tbl_cnt).lpn_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;

      l_progress := 'Done getting LPN attributes, Add LPN to hash table';
    END IF;

    -- Store Original attributes
    l_new := l_old;

    IF (l_debug = 1) THEN
      mdebug('Old values from LPN to be updated l_lpn_tab_i='||l_lpn_tab_i||' lpn_tbl_cnt='||lpn_tbl_cnt, G_INFO);
      mdebug('lpnid='||l_old.lpn_id||' lpn='||l_old.license_plate_number||' ctx='||l_old.lpn_context||' plpn='||l_old.parent_lpn_id||' olpn='||l_old.outermost_lpn_id||' itm='||l_old.inventory_item_id||' rev='||l_old.revision, G_INFO);
      mdebug('lot='||l_old.lot_number||' sn='||l_old.serial_number||' cg='||l_old.cost_group_id||' org='||l_old.organization_id||' sub='||l_old.subinventory_code||' loc='||l_old.locator_id, G_INFO);
      mdebug('twt='||l_old.tare_weight||' twuom='||l_old.tare_weight_uom_code||' gwt='||l_old.gross_weight||' gwuom='||l_old.gross_weight_uom_code||
             ' ctrvol='||l_old.container_volume||' ctrvoluom='||l_old.container_volume_uom||' ctnvol='||l_old.content_volume||' ctvuom='||l_old.content_volume_uom_code, G_INFO);
      mdebug('stype='||l_old.source_type_id||' shdr='||l_old.source_header_id||' srcln='||l_old.source_line_id||' srclndt='||l_old.source_line_detail_id||' srcnm='||l_old.source_name, G_INFO);
      --mdebug('reuse='||l_old.lpn_reusability||' hom='||l_old.homogeneous_container||' stat='||l_old.status_id ||' seal='||l_old.sealed_status, G_INFO);
      mdebug('acat='||l_old.attribute_category||' a1='||l_old.attribute1||' a2='||l_old.attribute2||' a3='||l_old.attribute3||' a4='||l_old.attribute4||' a5='||l_old.attribute5||' a6='||l_old.attribute6||' a7='||l_old.attribute7, G_INFO);
      mdebug('a8='||l_old.attribute8||' a9='||l_old.attribute9||' a10='||l_old.attribute10||' a11='||l_old.attribute11||' a12='||l_old.attribute12||' a13='||l_old.attribute13||' a14='||l_old.attribute14||' a15='||l_old.attribute15, G_INFO);
    END IF;

    l_progress := 'Start of section to massage data';

    -- List of attributes that pertain to the LPN itself and not to the
    -- entire hierarchy
    IF ( p_lpn_table(lpn_tbl_cnt).license_plate_number    <> NVL(l_old.license_plate_number, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).parent_lpn_id           <> NVL(l_old.parent_lpn_id, FND_API.G_MISS_NUM) OR
         Nvl(p_lpn_table(lpn_tbl_cnt).inventory_item_id,0)<> NVL(l_old.inventory_item_id, FND_API.G_MISS_NUM) OR  --Bug#6504032 Added nvl condition
         p_lpn_table(lpn_tbl_cnt).revision                <> NVL(l_old.revision, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).lot_number              <> NVL(l_old.lot_number, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).serial_number           <> NVL(l_old.serial_number, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).cost_group_id           <> NVL(l_old.cost_group_id, FND_API.G_MISS_NUM) OR
         p_lpn_table(lpn_tbl_cnt).tare_weight_uom_code    <> NVL(l_old.tare_weight_uom_code, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).tare_weight             <> NVL(l_old.tare_weight, FND_API.G_MISS_NUM) OR
         p_lpn_table(lpn_tbl_cnt).gross_weight_uom_code   <> NVL(l_old.gross_weight_uom_code, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).gross_weight            <> NVL(l_old.gross_weight, FND_API.G_MISS_NUM) OR
         p_lpn_table(lpn_tbl_cnt).container_volume_uom    <> NVL(l_old.container_volume_uom, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).container_volume        <> NVL(l_old.container_volume, FND_API.G_MISS_NUM) OR
         p_lpn_table(lpn_tbl_cnt).content_volume_uom_code <> NVL(l_old.content_volume_uom_code, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).content_volume          <> NVL(l_old.content_volume, FND_API.G_MISS_NUM) OR
         p_lpn_table(lpn_tbl_cnt).attribute_category      <> NVL(l_old.attribute_category, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute1              <> NVL(l_old.attribute1, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute2              <> NVL(l_old.attribute2, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute3              <> NVL(l_old.attribute3, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute4              <> NVL(l_old.attribute4, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute5              <> NVL(l_old.attribute5, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute6              <> NVL(l_old.attribute6, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute7              <> NVL(l_old.attribute7, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute8              <> NVL(l_old.attribute8, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute9              <> NVL(l_old.attribute9, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute10             <> NVL(l_old.attribute10, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute11             <> NVL(l_old.attribute11, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute12             <> NVL(l_old.attribute12, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute13             <> NVL(l_old.attribute13, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute14             <> NVL(l_old.attribute14, FND_API.G_MISS_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).attribute15             <> NVL(l_old.attribute15, FND_API.G_MISS_CHAR) )
    THEN
      l_progress := 'Initialize temp variables used for each loop';
      l_change_in_gross_weight     := 0;
      l_change_in_gross_weight_uom := NULL;
      l_change_in_tare_weight      := 0;
      l_change_in_tare_weight_uom  := NULL;
      l_change_in_volume           := 0;
      l_change_in_volume_uom       := NULL;

      -- If this LPN has not been updated, create record
      IF ( l_lpn_tab_i IS NULL ) THEN
        l_lpn_tab_i := NVL(l_lpns.last, 0) + 1;
        l_lpns(l_lpn_tab_i) := l_old;
        l_lpn_ids(p_lpn_table(lpn_tbl_cnt).lpn_id) := l_lpn_tab_i;
      END IF;

      IF (l_debug = 1) THEN
        mdebug('Need to update based on lpn_id l_lpn_tab_i='||l_lpn_tab_i, G_INFO);
      END IF;

      l_progress := 'License Plate Number';
      IF ( p_lpn_table(lpn_tbl_cnt).license_plate_number <> l_old.license_plate_number ) THEN
        l_progress := 'Validate Organization ID';

        IF ( NOT Inv_Cache.set_org_rec( p_organization_id => NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)) )THEN
          IF (l_debug = 1) THEN
            mdebug(NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)||' is an invalid organization id', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_debug = 1) THEN
          mdebug('Got org info wms_enabled='||inv_cache.org_rec.wms_enabled_flag, 5);
        END IF;

        IF ( inv_cache.org_rec.wms_enabled_flag = 'Y' ) THEN
          -- License Plate Number cannot be updated in a WMS organziation
          fnd_message.set_name('WMS', 'WMS_UPDATE_LPN_ATTR_ERR');
          fnd_message.set_token('ATTR', 'License Plate Number');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          l_new.license_plate_number := p_lpn_table(lpn_tbl_cnt).license_plate_number;
        END IF;
      END IF;

      l_progress := 'Validate container item';
      IF ( (p_lpn_table(lpn_tbl_cnt).inventory_item_id IS NOT NULL)
         AND (Nvl(p_lpn_table(lpn_tbl_cnt).inventory_item_id,G_NULL_NUM) <> NVL(l_old.inventory_item_id, G_NULL_NUM)) ) THEN  --Bug#6504032 Modified IF condition and commented following code
        -- Can change an LPNs existing container item for context 1 and 5 LPNs
        /*IF NOT ( l_old.lpn_context = lpn_context_pregenerated OR l_old.inventory_item_id IS NULL ) THEN
          IF (l_debug = 1) THEN
            mdebug(' LPN is not empty or already is assigned cannot update container item ctx='||l_old.lpn_context, G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_UPDATE_CONTAINER_ITEM_ERR');
          fnd_msg_pub.ADD;

          IF ( l_old.lpn_context <> lpn_context_pregenerated ) THEN
            fnd_message.set_name('WMS', 'WMS_LPN_NOT_EMPTY');
            fnd_msg_pub.ADD;
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;*/

        l_progress := 'Calling INV_CACHE.Set_Item_Rec to get item values';
        IF ( inv_cache.set_item_rec(
               p_organization_id => NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)
             , p_item_id         => p_lpn_table(lpn_tbl_cnt).inventory_item_id ) )
        THEN
          IF (l_debug = 1) THEN
            mdebug('Got Item info citm='||inv_cache.item_rec.container_item_flag||' snctl='||inv_cache.item_rec.serial_number_control_code, G_INFO);
            mdebug('wuom='||inv_cache.item_rec.weight_uom_code||' wt='||inv_cache.item_rec.unit_weight||' vuom='||inv_cache.item_rec.volume_uom_code||' vol='||inv_cache.item_rec.unit_volume, G_INFO);
          END IF;

          IF ( inv_cache.item_rec.container_item_flag = 'N' ) THEN
            IF (l_debug = 1) THEN
              mdebug(p_lpn_table(lpn_tbl_cnt).inventory_item_id || ' is not a container', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_ITEM_NOT_CONTAINER');
            fnd_message.set_token('ITEM', inv_cache.item_rec.segment1);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
          l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid='||NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)||' item id='||p_lpn_table(lpn_tbl_cnt).inventory_item_id;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- Container item is valid, change container item
        l_new.inventory_item_id := p_lpn_table(lpn_tbl_cnt).inventory_item_id;
      END IF;

      -- bug5404902 changed l_change_in_gross_weight(_uom) to l_change_in_tare_weight(_uom)
      l_progress := 'Tare weight';
      IF ( p_lpn_table(lpn_tbl_cnt).tare_weight = FND_API.G_MISS_NUM OR p_lpn_table(lpn_tbl_cnt).tare_weight_uom_code = FND_API.G_MISS_CHAR ) THEN
        l_new.tare_weight          := NULL;
        l_new.tare_weight_uom_code := NULL;

        IF ( NVL(l_old.tare_weight, 0) <> 0 AND l_old.tare_weight_uom_code IS NOT NULL ) THEN
          l_change_in_tare_weight     := 0 - l_old.tare_weight;
          l_change_in_tare_weight_uom := l_old.tare_weight_uom_code;
        END IF;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).tare_weight IS NOT NULL AND p_lpn_table(lpn_tbl_cnt).tare_weight_uom_code IS NOT NULL ) THEN
        -- Check that value is not negative.  If it is, floor at zero
        IF ( p_lpn_table(lpn_tbl_cnt).tare_weight < 0 ) THEN
          l_new.tare_weight := 0;
        ELSE
         l_new.tare_weight := p_lpn_table(lpn_tbl_cnt).tare_weight;
        END IF;

        l_new.tare_weight_uom_code := p_lpn_table(lpn_tbl_cnt).tare_weight_uom_code;

        IF ( NVL(l_old.tare_weight,0) <> 0 AND l_old.tare_weight_uom_code IS NOT NULL ) THEN
          l_change_in_tare_weight_uom := l_old.tare_weight_uom_code;
          l_change_in_tare_weight     := Convert_UOM(l_new.inventory_item_id, l_new.tare_weight, l_new.tare_weight_uom_code, l_change_in_tare_weight_uom, G_NO_CONV_RETURN_NULL);
          l_change_in_tare_weight     := l_change_in_tare_weight - l_old.tare_weight;
        ELSE
          l_change_in_tare_weight     := l_new.tare_weight;
          l_change_in_tare_weight_uom := l_new.tare_weight_uom_code;
        END IF;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).inventory_item_id IS NOT NULL
              AND (Nvl(p_lpn_table(lpn_tbl_cnt).inventory_item_id,G_NULL_NUM) <> Nvl(l_old.inventory_item_id,G_NULL_NUM)) ) THEN  --Bug#6504032 Modified this ELSIF to allow modifying and attaching container
          IF ( l_old.inventory_item_id IS NOT NULL ) THEN
            IF (inv_cache.set_item_rec(
              p_organization_id => NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)
              , p_item_id         => l_old.inventory_item_id ))
            THEN
              IF (l_debug = 1) THEN
                mdebug('Got Old Item info citm='||inv_cache.item_rec.container_item_flag||' snctl='||inv_cache.item_rec.serial_number_control_code, G_INFO);
                mdebug('wuom='||inv_cache.item_rec.weight_uom_code||' wt='||inv_cache.item_rec.unit_weight||' vuom='||inv_cache.item_rec.volume_uom_code||' vol='||inv_cache.item_rec.unit_volume, G_INFO);
              END IF;
            ELSE
              l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid='||NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)||' item id='||l_old.inventory_item_id;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
            IF ( inv_cache.item_rec.unit_weight IS NOT NULL AND
                inv_cache.item_rec.weight_uom_code IS NOT NULL ) THEN

              IF ( NVL(l_old.tare_weight, 0) = 0 OR l_old.tare_weight_uom_code IS NULL ) THEN
                l_new.tare_weight          := 0;
                l_new.tare_weight_uom_code := NULL;
              ELSIF ( l_old.tare_weight_uom_code = inv_cache.item_rec.weight_uom_code ) THEN
                l_new.tare_weight          := l_old.tare_weight - inv_cache.item_rec.unit_weight;
                l_old.tare_weight := l_old.tare_weight - inv_cache.item_rec.unit_weight;
                l_new.tare_weight_uom_code := l_old.tare_weight_uom_code;
              ELSE -- Both are not null but with different UOMs need to convert
                l_new.tare_weight := Convert_UOM(inv_cache.item_rec.inventory_item_id, inv_cache.item_rec.unit_weight, inv_cache.item_rec.weight_uom_code, l_old.tare_weight_uom_code, G_NO_CONV_RETURN_NULL);

                l_new.tare_weight          := l_old.tare_weight - l_new.tare_weight;
                l_old.tare_weight := l_old.tare_weight - inv_cache.item_rec.unit_weight;
                l_new.tare_weight_uom_code := l_old.tare_weight_uom_code;
              END IF;

              l_change_in_tare_weight     := 0-inv_cache.item_rec.unit_weight;
              l_change_in_tare_weight_uom := l_old.tare_weight_uom_code;
            END IF;
          END IF;
          IF ( inv_cache.set_item_rec(
               p_organization_id => NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)
             , p_item_id         => p_lpn_table(lpn_tbl_cnt).inventory_item_id ) )
          THEN
            IF (l_debug = 1) THEN
              mdebug('Got Item info citm='||inv_cache.item_rec.container_item_flag||' snctl='||inv_cache.item_rec.serial_number_control_code, G_INFO);
              mdebug('wuom='||inv_cache.item_rec.weight_uom_code||' wt='||inv_cache.item_rec.unit_weight||' vuom='||inv_cache.item_rec.volume_uom_code||' vol='||inv_cache.item_rec.unit_volume, G_INFO);
            END IF;
          ELSE
            l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid='||NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)||' item id='||p_lpn_table(lpn_tbl_cnt).inventory_item_id;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
          IF ( inv_cache.item_rec.unit_weight IS NOT NULL AND
                inv_cache.item_rec.weight_uom_code IS NOT NULL ) THEN

            IF ( NVL(l_old.tare_weight, 0) = 0 OR l_old.tare_weight_uom_code IS NULL ) THEN
              l_new.tare_weight          := inv_cache.item_rec.unit_weight;
              l_new.tare_weight_uom_code := inv_cache.item_rec.weight_uom_code;
            ELSIF ( l_old.tare_weight_uom_code = inv_cache.item_rec.weight_uom_code ) THEN
              l_new.tare_weight          := l_new.tare_weight + inv_cache.item_rec.unit_weight;
              l_new.tare_weight_uom_code := l_old.tare_weight_uom_code;
            ELSE -- Both are not null but with different UOMs need to convert
              l_new.tare_weight := Convert_UOM(inv_cache.item_rec.inventory_item_id, inv_cache.item_rec.unit_weight, inv_cache.item_rec.weight_uom_code, l_old.tare_weight_uom_code, G_NO_CONV_RETURN_NULL);

              l_new.tare_weight          := l_new.tare_weight + l_old.tare_weight;
              l_new.tare_weight_uom_code := l_old.tare_weight_uom_code;
            END IF;

          -- bug5404902 now that we are just adding the container item unit weight to the
          -- existing tare, change in tare is just the container item unit weight
            l_change_in_tare_weight     := l_change_in_tare_weight + inv_cache.item_rec.unit_weight;
            l_change_in_tare_weight_uom := inv_cache.item_rec.weight_uom_code;
          END IF;
        ELSIF ( p_lpn_table(lpn_tbl_cnt).inventory_item_id IS NULL  ----Bug#6504032 Added this ELSIF to take care of container removal
	        AND l_old.inventory_item_id IS NOT NULL
		AND l_old.lpn_context IN (1,5)
		AND p_caller = 'UpdateLPNPage' ) THEN
          IF (inv_cache.set_item_rec(
              p_organization_id => NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)
              , p_item_id         => l_old.inventory_item_id ))
          THEN
            IF (l_debug = 1) THEN
              mdebug('Got Old Item info citm='||inv_cache.item_rec.container_item_flag||' snctl='||inv_cache.item_rec.serial_number_control_code, G_INFO);
              mdebug('wuom='||inv_cache.item_rec.weight_uom_code||' wt='||inv_cache.item_rec.unit_weight||' vuom='||inv_cache.item_rec.volume_uom_code||' vol='||inv_cache.item_rec.unit_volume, G_INFO);
            END IF;
          ELSE
            l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid='||NVL(p_lpn_table(lpn_tbl_cnt).organization_id, l_old.organization_id)||' item id='||p_lpn_table(lpn_tbl_cnt).inventory_item_id;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          IF  (inv_cache.item_rec.unit_weight IS NOT NULL AND
              inv_cache.item_rec.weight_uom_code IS NOT NULL ) THEN

            IF ( NVL(l_old.tare_weight, 0) = 0 OR l_old.tare_weight_uom_code IS NULL ) THEN
              l_new.tare_weight          := 0;
              l_new.tare_weight_uom_code := NULL;
            ELSIF ( l_old.tare_weight_uom_code = inv_cache.item_rec.weight_uom_code ) THEN
              l_new.tare_weight          := l_old.tare_weight - inv_cache.item_rec.unit_weight;
              l_new.tare_weight_uom_code := l_old.tare_weight_uom_code;
            ELSE -- Both are not null but with different UOMs need to convert
              l_new.tare_weight := Convert_UOM(inv_cache.item_rec.inventory_item_id, inv_cache.item_rec.unit_weight, inv_cache.item_rec.weight_uom_code, l_old.tare_weight_uom_code, G_NO_CONV_RETURN_NULL);

              l_new.tare_weight          := l_old.tare_weight - l_new.tare_weight;
              l_new.tare_weight_uom_code := l_old.tare_weight_uom_code;
            END IF;

            l_change_in_tare_weight     := 0-inv_cache.item_rec.unit_weight;
            l_change_in_tare_weight_uom := l_old.tare_weight_uom_code;
          END IF;
          l_new.inventory_item_id := NULL;
          l_new.container_volume     := NULL;
          l_new.container_volume_uom := NULL;
        END IF;

      l_progress := 'Gross Weight';
      IF ( p_lpn_table(lpn_tbl_cnt).gross_weight = FND_API.G_MISS_NUM OR p_lpn_table(lpn_tbl_cnt).gross_weight_uom_code = FND_API.G_MISS_CHAR ) THEN
        l_new.gross_weight          := NULL;
        l_new.gross_weight_uom_code := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).gross_weight IS NOT NULL AND p_lpn_table(lpn_tbl_cnt).gross_weight_uom_code IS NOT NULL ) THEN
        -- Check that value is not negative.  If it is, floor at zero
        IF ( p_lpn_table(lpn_tbl_cnt).gross_weight < 0 ) THEN
          l_new.gross_weight := 0;
        ELSE
         l_new.gross_weight := p_lpn_table(lpn_tbl_cnt).gross_weight;
        END IF;
        l_new.gross_weight_uom_code := p_lpn_table(lpn_tbl_cnt).gross_weight_uom_code;
      END IF;

      --Bug#6504032 Separated calculation of change in Gr Wt due to container association
      IF ( p_caller = 'UpdateLPNPage' ) THEN
        IF ( NVL(l_new.gross_weight, 0) = 0 OR l_new.gross_weight_uom_code IS NULL ) THEN
          l_change_in_weight     := 0 - l_old.gross_weight;
          l_change_in_weight_uom := l_old.gross_weight_uom_code;
        ELSIF ( NVL(l_old.gross_weight, 0) = 0 OR l_old.gross_weight_uom_code IS NULL ) THEN
          l_change_in_weight     := l_new.gross_weight;
          l_change_in_weight_uom := l_new.gross_weight_uom_code;
        ELSIF ( l_old.gross_weight_uom_code = l_new.gross_weight_uom_code ) THEN
          l_change_in_weight     := l_new.gross_weight - l_old.gross_weight;
          l_change_in_weight_uom := l_old.gross_weight_uom_code;
        ELSE -- Both are not null but with different UOMs need to convert
          l_change_in_weight_uom := l_old.gross_weight_uom_code;

          l_change_in_weight := Convert_UOM(l_new.inventory_item_id, l_new.gross_weight, l_new.gross_weight_uom_code, l_change_in_weight_uom, G_NO_CONV_RETURN_NULL);
          l_change_in_weight := l_change_in_weight - l_old.gross_weight;
        END IF;

        /*Bug#6845814 If there is a change in gross weight, it will be a change in tare weight.  */
        IF (    l_change_in_weight <> 0
                AND p_caller='UpdateLPNPage'
	        --AND NVL(p_lpn_table(lpn_tbl_cnt).inventory_item_id ,G_NULL_NUM) = G_NULL_NUM
	       ) THEN
	        IF (l_new.tare_weight_uom_code IS NOT NULL ) THEN
	            IF ( l_change_in_weight_uom <> l_new.tare_weight_uom_code ) THEN
	                l_new.tare_weight := NVL( l_new.tare_weight,0) + inv_convert.inv_um_convert(
	                                                             l_new.inventory_item_id,
								     6,
								     l_change_in_weight,
								     l_change_in_weight_uom ,
								     l_new.tare_weight_uom_code
								     ,NULL,NULL);
	            ELSE
                        l_new.tare_weight := NVL( l_new.tare_weight,0) +  l_change_in_weight ;
                    END IF;
                ELSE  --l_new.tare_weight_uom_code IS NULL
	            l_new.tare_weight := l_change_in_weight ;
	            l_new.tare_weight_uom_code := NVL( l_change_in_weight_uom ,  l_new.gross_weight_uom_code  );
                END IF;

                IF (l_new.tare_weight <= 0 ) THEN
                    l_new.tare_weight := 0 ;
                    l_new.tare_weight_uom_code := NULL ;
                END IF;
        END IF;
      END IF;

      /*Bug7529224 moved code that adds change in tare weight into gross wt  to down  */
      IF (l_debug = 1) THEN
         mdebug('After gr wt calc ,l_change_in_tare_weight:'||l_change_in_tare_weight ,G_INFO );
      END IF;

      l_progress := 'Container Volume';
      IF ( p_lpn_table(lpn_tbl_cnt).container_volume = FND_API.G_MISS_NUM OR p_lpn_table(lpn_tbl_cnt).container_volume_uom = FND_API.G_MISS_CHAR ) THEN
        l_new.container_volume     := NULL;
        l_new.container_volume_uom := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).container_volume IS NOT NULL AND p_lpn_table(lpn_tbl_cnt).container_volume_uom IS NOT NULL ) THEN
        -- Check that value is not negative.  If it is, floor at zero
        IF ( p_lpn_table(lpn_tbl_cnt).container_volume < 0 ) THEN
          l_new.container_volume := 0;
        ELSE
         l_new.container_volume := p_lpn_table(lpn_tbl_cnt).container_volume;
        END IF;

        l_new.container_volume_uom := p_lpn_table(lpn_tbl_cnt).container_volume_uom;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).inventory_item_id IS NOT NULL ) THEN
        -- use new container item tare weight and uom if values are not defined yet
        --IF ( l_old.container_volume IS NULL OR l_old.container_volume_uom IS NULL ) THEN  --Bug#6504032 Commented this IF as container can be updated now
          l_new.container_volume     := inv_cache.item_rec.unit_volume;
          l_new.container_volume_uom := inv_cache.item_rec.volume_uom_code;
        --END IF;
      END IF;

      l_progress := 'Content Volume';
      IF ( p_lpn_table(lpn_tbl_cnt).content_volume = FND_API.G_MISS_NUM OR p_lpn_table(lpn_tbl_cnt).content_volume_uom_code = FND_API.G_MISS_CHAR ) THEN
        l_new.content_volume          := NULL;
        l_new.content_volume_uom_code := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).content_volume IS NOT NULL AND p_lpn_table(lpn_tbl_cnt).content_volume_uom_code IS NOT NULL ) THEN
        -- Check that value is not negative.  If it is, floor at zero
        IF ( p_lpn_table(lpn_tbl_cnt).content_volume < 0 ) THEN
          l_new.content_volume := 0;
        ELSE
         l_new.content_volume := p_lpn_table(lpn_tbl_cnt).content_volume;
        END IF;

        l_new.content_volume_uom_code := p_lpn_table(lpn_tbl_cnt).content_volume_uom_code;
      END IF;

      /* Not sure if we need to support this
      l_progress := 'Status ID?';
      IF ( p_lpn_table(lpn_tbl_cnt).status_id = FND_API.G_MISS_NUM ) THEN
        l_new.status_id := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).status_id IS NOT NULL ) THEN
        l_new.status_id := p_lpn_table(lpn_tbl_cnt).status_id;
      END IF;*/

      l_progress := 'Update attribute_category';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute_category = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute_category := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute_category IS NOT NULL ) THEN
        l_new.attribute_category := p_lpn_table(lpn_tbl_cnt).attribute_category;
      END IF;

      l_progress := 'Update attribute1';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute1 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute1 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute1 IS NOT NULL ) THEN
        l_new.attribute1 := p_lpn_table(lpn_tbl_cnt).attribute1;
      END IF;

      l_progress := 'Update attribute2';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute2 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute2 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute2 IS NOT NULL ) THEN
        l_new.attribute2 := p_lpn_table(lpn_tbl_cnt).attribute2;
      END IF;

      l_progress := 'Update attribute3';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute3 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute3 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute3 IS NOT NULL ) THEN
        l_new.attribute3 := p_lpn_table(lpn_tbl_cnt).attribute3;
      END IF;

      l_progress := 'Update attribute4';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute4 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute4 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute4 IS NOT NULL ) THEN
        l_new.attribute4 := p_lpn_table(lpn_tbl_cnt).attribute4;
      END IF;

      l_progress := 'Update attribute5';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute5 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute5 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute5 IS NOT NULL ) THEN
        l_new.attribute5 := p_lpn_table(lpn_tbl_cnt).attribute5;
      END IF;

      l_progress := 'Update attribute6';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute6 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute6 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute6 IS NOT NULL ) THEN
        l_new.attribute6 := p_lpn_table(lpn_tbl_cnt).attribute6;
      END IF;

      l_progress := 'Update attribute7';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute7 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute7 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute7 IS NOT NULL ) THEN
        l_new.attribute7 := p_lpn_table(lpn_tbl_cnt).attribute7;
      END IF;

      l_progress := 'Update attribute8';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute8 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute8 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute8 IS NOT NULL ) THEN
        l_new.attribute8 := p_lpn_table(lpn_tbl_cnt).attribute8;
      END IF;

      l_progress := 'Update attribute9';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute9 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute9 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute9 IS NOT NULL ) THEN
        l_new.attribute9 := p_lpn_table(lpn_tbl_cnt).attribute9;
      END IF;

      l_progress := 'Update attribute10';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute10 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute10 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute10 IS NOT NULL ) THEN
        l_new.attribute10 := p_lpn_table(lpn_tbl_cnt).attribute10;
      END IF;

      l_progress := 'Update attribute11';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute11 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute11 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute11 IS NOT NULL ) THEN
        l_new.attribute11 := p_lpn_table(lpn_tbl_cnt).attribute11;
      END IF;

      l_progress := 'Update attribute12';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute12 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute12 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute12 IS NOT NULL ) THEN
        l_new.attribute12 := p_lpn_table(lpn_tbl_cnt).attribute12;
      END IF;

      l_progress := 'Update attribute13';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute13 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute13 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute13 IS NOT NULL ) THEN
        l_new.attribute13 := p_lpn_table(lpn_tbl_cnt).attribute13;
      END IF;

      l_progress := 'Update attribute14';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute14 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute14 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute14 IS NOT NULL ) THEN
        l_new.attribute14 := p_lpn_table(lpn_tbl_cnt).attribute14;
      END IF;

      l_progress := 'Update attribute15';
      IF ( p_lpn_table(lpn_tbl_cnt).attribute15 = FND_API.G_MISS_CHAR ) THEN
        l_new.attribute15 := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).attribute15 IS NOT NULL ) THEN
        l_new.attribute15 := p_lpn_table(lpn_tbl_cnt).attribute15;
      END IF;

      l_progress := 'Parent LPN';
      IF ( p_lpn_table(lpn_tbl_cnt).parent_lpn_id IS NOT NULL ) THEN
        IF ( NVL(p_caller, G_NULL_CHAR) <> 'WMS_PackUnpack_Container' ) THEN
          l_progress := 'Updating parent_lpn_id is retructed to PackUnpack_Container API';
          fnd_message.set_name('WMS', 'WMS_UPDATE_LPN_ATTR_ERR');
          fnd_message.set_token('ATTR', 'parent_lpn_id');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSIF ( p_lpn_table(lpn_tbl_cnt).parent_lpn_id = FND_API.G_MISS_NUM ) THEN
          -- UNPACKING LPN
          l_new.parent_lpn_id    := NULL;
          l_new.outermost_lpn_id := l_new.lpn_id;
        ELSIF ( l_old.parent_lpn_id IS NOT NULL ) THEN
          -- Nesting an lpn that is already nested not allowed in a single
          -- operaiton.  Must unpack LPN before packing into new LPN
          fnd_message.set_name('WMS', 'WMS_LPN_ALREADY_NESTED_ERR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          -- PACKING LPN
          l_new.parent_lpn_id := p_lpn_table(lpn_tbl_cnt).parent_lpn_id;

          -- Need to populate new outermost lpn id
          IF ( p_lpn_table(lpn_tbl_cnt).outermost_lpn_id IS NOT NULL ) THEN
            l_new.outermost_lpn_id := p_lpn_table(lpn_tbl_cnt).outermost_lpn_id;
          ELSIF ( l_lpn_ids.exists(l_new.parent_lpn_id) ) THEN
            l_new.outermost_lpn_id := l_lpns(l_lpn_ids(l_new.parent_lpn_id)).outermost_lpn_id;
          ELSE -- not in table just get from db
            l_progress := 'Getting outermost_lpn_id for plpnid='||l_new.parent_lpn_id;
            SELECT outermost_lpn_id
            INTO   l_new.outermost_lpn_id
            FROM   wms_license_plate_numbers
            WHERE  lpn_id = l_new.parent_lpn_id;
          END IF;
        END IF;
      END IF;

      l_progress := 'Done with section that deals with LPN itself';

      /************************************************************/
      /* Calculate changes to weight and volume                   */
      /*                                                          */
      /************************************************************/
      l_progress := 'Calculate total change in gross weight';

      IF ( NVL(l_new.gross_weight, 0) = 0 OR l_new.gross_weight_uom_code IS NULL ) THEN
        l_change_in_gross_weight     := 0 - l_old.gross_weight;
        l_change_in_gross_weight_uom := l_old.gross_weight_uom_code;
      ELSIF ( NVL(l_old.gross_weight, 0) = 0 OR l_old.gross_weight_uom_code IS NULL ) THEN
        l_change_in_gross_weight     := l_new.gross_weight;
        l_change_in_gross_weight_uom := l_new.gross_weight_uom_code;
      ELSIF ( l_old.gross_weight_uom_code = l_new.gross_weight_uom_code ) THEN
        l_change_in_gross_weight     := l_new.gross_weight - l_old.gross_weight;
        l_change_in_gross_weight_uom := l_old.gross_weight_uom_code;
      ELSE -- Both are not null but with different UOMs need to convert
        l_change_in_gross_weight_uom := l_old.gross_weight_uom_code;

        l_change_in_gross_weight := Convert_UOM(l_new.inventory_item_id, l_new.gross_weight, l_new.gross_weight_uom_code, l_change_in_gross_weight_uom, G_NO_CONV_RETURN_NULL);
        l_change_in_gross_weight := l_change_in_gross_weight - l_old.gross_weight;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('after total change in gr wt ,l_new.gross_weight:'||l_new.gross_weight,G_INFO );
	 mdebug('l_change_in_gross_weight:'||l_change_in_gross_weight,G_INFO );
      END if;

      /*Bug#7529224. Moved the code here otherwise change in tare wt is added twice*/
      IF ( NVL(l_change_in_tare_weight, 0) <> 0 AND l_change_in_tare_weight_uom IS NOT NULL
           AND  l_change_in_gross_weight = 0 )
         THEN
      	-- bug5404902 changed l_change_in_gross_weight(_uom) to l_change_in_tare_weight(_uom)
        -- If tare weight has changed need to add the difference to gross
        IF ( NVL(l_old.gross_weight, 0) = 0 OR l_old.gross_weight_uom_code IS NULL ) THEN
          l_new.gross_weight          := l_new.tare_weight;
          l_new.gross_weight_uom_code := l_new.tare_weight_uom_code;
        ELSIF ( l_old.gross_weight_uom_code = l_change_in_gross_weight_uom ) THEN
          l_new.gross_weight          := l_new.gross_weight + l_change_in_tare_weight;
          l_new.gross_weight_uom_code := l_old.gross_weight_uom_code;
        ELSE -- Both are not null but with different UOMs need to convert
        	-- bug5404902 intentionally used l_change_in_gross_weight to store conversion value
        	-- so that l_change_in_tare_weight can maintain it's original UOM
        	-- Marker
          l_change_in_gross_weight     := Convert_UOM(l_new.inventory_item_id, l_change_in_tare_weight, l_change_in_tare_weight_uom, l_new.gross_weight_uom_code, G_NO_CONV_RETURN_ZERO);
          l_change_in_gross_weight_uom := l_new.gross_weight_uom_code;

          l_new.gross_weight := l_new.gross_weight + l_change_in_tare_weight;
        END IF;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('After adding change in tare weight l_new.gross_weight:'||l_new.gross_weight,G_INFO );
      end if;
      /*Bug#7529224 End*/

      IF (l_debug = 1) THEN
        mdebug('change wt='||l_change_in_gross_weight||' change wuom='||l_change_in_gross_weight_uom, G_INFO);
	mdebug('After all calc, l_new.gross_weight:'||l_new.gross_weight,G_INFO );
	mdebug('New item='||p_lpn_table(lpn_tbl_cnt).inventory_item_id ||',old item='||l_old.inventory_item_id,G_INFO);
      END IF;

      l_progress := 'Call helper procedure to calculate change in volume';
      Calc_Vol_Change (
        p_debug             => l_debug
      , p_old_lpn           => l_old
      , p_new_lpn           => l_new
      , p_volume_change     => l_change_in_volume
      , p_volume_uom_change => l_change_in_volume_uom );

      -- bug 4144326 When there is a change in wt/vol need to update locator capacity.
      -- Only for explicit update transactions.  Not for TM invoked updates.
      /*IF ( NVL(p_caller, G_NULL_CHAR) <> 'WMS_PackUnpack_Container' AND
           NVL(p_caller, G_NULL_CHAR) <> 'INV_TRNSACTION' )
      THEN*/
      IF ( NVL(p_caller, G_NULL_CHAR) not in ('WMS_PackUnpack_Container', 'INV_TRNSACTION') ) THEN
        l_progress := 'Calling Update_Locator_Capacity';

        Update_Locator_Capacity (
          x_return_status     => x_return_status
        , x_msg_count         => x_msg_count
        , x_msg_data          => x_msg_data
        , p_organization_id   => l_new.organization_id
        , p_subinventory      => l_new.subinventory_code
        , p_locator_id        => l_new.locator_id
        , p_weight_change     => l_change_in_gross_weight
        , p_weight_uom_change => l_change_in_gross_weight_uom
        , p_volume_change     => l_change_in_volume
        , p_volume_uom_change => l_change_in_volume_uom
        );

        IF ( x_return_status <> fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            mdebug('Call to WMS_CONTAINER_PVT.Update_Locator_capacity failed !!!');
          END IF;
        END IF;
      END IF;
      /*ELSE
         l_progress := 'No change is weight/vol of lpn, set vars to null';

         l_change_in_gross_weight     := null;
         l_change_in_gross_weight_uom := null;
         l_change_in_volume           := null;
         l_change_in_volume_uom       := null;
      END IF;*/

      /************************************************************/
      /* Changes that only pertain to LPNs nested inside this LPN */
      /* Update child LPNs                                        */
      /************************************************************/
      IF ( l_old.outermost_lpn_id <> l_new.outermost_lpn_id )  THEN
        IF ( l_old.lpn_id = l_old.outermost_lpn_id ) THEN
          -- This LPN was the outermost can update based on outermost LPN column

          IF ( l_outer_lpn_ids.exists(l_old.outermost_lpn_id) ) THEN
            l_tmp_i := l_outer_lpn_ids(l_old.outermost_lpn_id);
            IF (l_debug = 1) THEN
              mdebug('LPN old outer already exist in table l_tmp_i='||l_tmp_i, G_INFO);
            END IF;
          ELSE
            l_tmp_i := NVL(l_outer_lpns.last, 0) + 1;
            l_outer_lpn_ids(l_old.outermost_lpn_id) := l_tmp_i;
            l_outer_lpns(l_tmp_i).reference_id      := l_old.outermost_lpn_id;

            IF (l_debug = 1) THEN
              mdebug('Create old outer entry in outer table l_tmp_i='||l_tmp_i, G_INFO);
            END IF;
          END IF;

          l_outer_lpns(l_tmp_i).outermost_lpn_id      := l_new.outermost_lpn_id;
          l_outer_lpns(l_tmp_i).organization_id       := l_new.organization_id;
          l_outer_lpns(l_tmp_i).subinventory_code     := l_new.subinventory_code;
          l_outer_lpns(l_tmp_i).locator_id            := l_new.locator_id;
          l_outer_lpns(l_tmp_i).lpn_context           := l_new.lpn_context;
          l_outer_lpns(l_tmp_i).source_type_id        := l_new.source_type_id;
          l_outer_lpns(l_tmp_i).source_header_id      := l_new.source_header_id;
          l_outer_lpns(l_tmp_i).source_line_id        := l_new.source_line_id;
          l_outer_lpns(l_tmp_i).source_line_detail_id := l_new.source_line_detail_id;
          l_outer_lpns(l_tmp_i).source_name           := l_new.source_name;
        ELSE
          -- LPN an inner LPN. Need to update child lpns
          FOR child_lpn_rec IN nested_child_lpn_cursor( l_old.lpn_id ) LOOP
            IF (l_debug = 1) THEN
              mdebug('Got child lpn lpnid='||child_lpn_rec.lpn_id, G_INFO);
            END IF;

            IF ( l_lpn_ids.exists(child_lpn_rec.lpn_id) ) THEN
              l_progress := 'LPN attributes already exist in table';
              l_tmp_i := l_lpn_ids(child_lpn_rec.lpn_id);

              IF (l_debug = 1) THEN
                mdebug('LPN attributes already exist in table lpnid='||l_old.lpn_id||' plpn='||l_old.parent_lpn_id||' olpn='||l_old.outermost_lpn_id, G_INFO);
              END IF;
            ELSE
              l_progress := 'Does not already exist in table get from rec';
              l_tmp_i := NVL(l_lpns.last, 0) + 1;
              l_lpn_ids(child_lpn_rec.lpn_id) := l_tmp_i;

              -- Add attributes from rec type to table of lpns
              l_lpns(l_tmp_i).lpn_id                  := child_lpn_rec.lpn_id;
              l_lpns(l_tmp_i).license_plate_number    := child_lpn_rec.license_plate_number;
              l_lpns(l_tmp_i).parent_lpn_id           := child_lpn_rec.parent_lpn_id;
              l_lpns(l_tmp_i).outermost_lpn_id        := child_lpn_rec.outermost_lpn_id;
              l_lpns(l_tmp_i).lpn_context             := child_lpn_rec.lpn_context;

              l_lpns(l_tmp_i).organization_id         := child_lpn_rec.organization_id;
              l_lpns(l_tmp_i).subinventory_code       := child_lpn_rec.subinventory_code;
              l_lpns(l_tmp_i).locator_id              := child_lpn_rec.locator_id;

              l_lpns(l_tmp_i).inventory_item_id       := child_lpn_rec.inventory_item_id;
              l_lpns(l_tmp_i).revision                := child_lpn_rec.revision;
              l_lpns(l_tmp_i).lot_number              := child_lpn_rec.lot_number;
              l_lpns(l_tmp_i).serial_number           := child_lpn_rec.serial_number;
              l_lpns(l_tmp_i).cost_group_id           := child_lpn_rec.cost_group_id;

              l_lpns(l_tmp_i).tare_weight_uom_code    := child_lpn_rec.tare_weight_uom_code;
              l_lpns(l_tmp_i).tare_weight             := child_lpn_rec.tare_weight;
              l_lpns(l_tmp_i).gross_weight_uom_code   := child_lpn_rec.gross_weight_uom_code;
              l_lpns(l_tmp_i).gross_weight            := child_lpn_rec.gross_weight;
              l_lpns(l_tmp_i).container_volume_uom    := child_lpn_rec.container_volume_uom;
              l_lpns(l_tmp_i).container_volume        := child_lpn_rec.container_volume;
              l_lpns(l_tmp_i).content_volume_uom_code := child_lpn_rec.content_volume_uom_code;
              l_lpns(l_tmp_i).content_volume          := child_lpn_rec.content_volume;

              l_lpns(l_tmp_i).source_type_id          := child_lpn_rec.source_type_id;
              l_lpns(l_tmp_i).source_header_id        := child_lpn_rec.source_header_id;
              l_lpns(l_tmp_i).source_line_id          := child_lpn_rec.source_line_id;
              l_lpns(l_tmp_i).source_line_detail_id   := child_lpn_rec.source_line_detail_id;
              l_lpns(l_tmp_i).source_name             := child_lpn_rec.source_name;

              l_lpns(l_tmp_i).attribute_category      := child_lpn_rec.attribute_category;
              l_lpns(l_tmp_i).attribute1              := child_lpn_rec.attribute1;
              l_lpns(l_tmp_i).attribute2              := child_lpn_rec.attribute2;
              l_lpns(l_tmp_i).attribute3              := child_lpn_rec.attribute3;
              l_lpns(l_tmp_i).attribute4              := child_lpn_rec.attribute4;
              l_lpns(l_tmp_i).attribute5              := child_lpn_rec.attribute5;
              l_lpns(l_tmp_i).attribute6              := child_lpn_rec.attribute6;
              l_lpns(l_tmp_i).attribute7              := child_lpn_rec.attribute7;
              l_lpns(l_tmp_i).attribute8              := child_lpn_rec.attribute8;
              l_lpns(l_tmp_i).attribute9              := child_lpn_rec.attribute9;
              l_lpns(l_tmp_i).attribute10             := child_lpn_rec.attribute10;
              l_lpns(l_tmp_i).attribute11             := child_lpn_rec.attribute11;
              l_lpns(l_tmp_i).attribute12             := child_lpn_rec.attribute12;
              l_lpns(l_tmp_i).attribute13             := child_lpn_rec.attribute13;
              l_lpns(l_tmp_i).attribute14             := child_lpn_rec.attribute14;
              l_lpns(l_tmp_i).attribute15             := child_lpn_rec.attribute15;

              IF (l_debug = 1) THEN
                mdebug('Retrieve attr from rec lpnid='||l_lpns(l_tmp_i).lpn_id||' plpn='||l_lpns(l_tmp_i).parent_lpn_id||' olpn='||l_lpns(l_tmp_i).outermost_lpn_id, G_INFO);
              END IF;
            END IF;

            -- Child LPN record may have already been processed, so there is the possiblity
            -- that it is no longer has the same parent lpn.  If not then, it is no longer
            -- part of this hierarchy, so skip update
            IF ( l_lpns(l_tmp_i).parent_lpn_id = child_lpn_rec.parent_lpn_id ) THEN
              IF (l_debug = 1) THEN
                mdebug('Update values to be inline with new outermost lpn l_tmp_i='||l_tmp_i, G_INFO);
              END IF;

              -- Values that need updating in child LPNs
              l_lpns(l_tmp_i).outermost_lpn_id := l_new.outermost_lpn_id;
            ELSIF ( l_debug = 1) THEN
              mdebug('Child LPNs parent lpn is not the same skip new='||l_lpns(l_tmp_i).parent_lpn_id||' old='||child_lpn_rec.parent_lpn_id, G_INFO);
            END IF;
          END LOOP;
        END IF;
      END IF;

      /*****************************************************************/
      /* Changes that only pertain to LPNs in which this LPN is packed */
      /* Update Parent LPNs                                            */
      /*****************************************************************/
      IF ( l_old.parent_lpn_id = l_new.parent_lpn_id ) THEN

        -- List of attributes that affect parent LPNs.  Only if there is a change in
        -- these should we open cursor for parent LPNs
        -- bug5404902 added change in tare weight to condition
        IF ( NVL(l_change_in_gross_weight, 0) <> 0 OR
             NVL(l_change_in_tare_weight, 0) <> 0 OR
             NVL(l_change_in_volume, 0) <> 0 )
        THEN

          -- If The LPN has a parent and there is a change in weight or volume, cycle through
          -- parent LPNs and update their weights and volumes as well
          FOR parent_lpn_rec IN nested_parent_lpn_cursor( NVL(l_old.parent_lpn_id, l_new.parent_lpn_id) ) LOOP
            IF (l_debug = 1) THEN
              mdebug('Got parent lpn lpnid='||parent_lpn_rec.lpn_id, G_INFO);
            END IF;

            IF ( l_lpn_ids.exists(parent_lpn_rec.lpn_id) ) THEN
              l_progress := 'LPN attributes already exist in table';
              l_tmp_i := l_lpn_ids(parent_lpn_rec.lpn_id);
              l_tmp_old := l_lpns(l_tmp_i);

              IF (l_debug = 1) THEN
                mdebug('LPN attributes already exist in table lpnid='||l_tmp_old.lpn_id||' gwuom='||l_tmp_old.gross_weight_uom_code||' gwt='||l_tmp_old.gross_weight||
                       ' vuom='||l_tmp_old.content_volume_uom_code||' vol='||l_tmp_old.content_volume||' twuom='||l_tmp_old.tare_weight_uom_code||' twt='||l_tmp_old.tare_weight, G_INFO);
              END IF;
            ELSE
              l_progress := 'Does not already exist in table get from rec';
              l_tmp_i := l_lpns.last + 1;
              l_lpn_ids(parent_lpn_rec.lpn_id) := l_tmp_i;

              -- Add attributes from rec type to table of lpns
              l_tmp_old.lpn_id                  := parent_lpn_rec.lpn_id;
              l_tmp_old.license_plate_number    := parent_lpn_rec.license_plate_number;
              l_tmp_old.parent_lpn_id           := parent_lpn_rec.parent_lpn_id;
              l_tmp_old.outermost_lpn_id        := parent_lpn_rec.outermost_lpn_id;
              l_tmp_old.lpn_context             := parent_lpn_rec.lpn_context;

              l_tmp_old.organization_id         := parent_lpn_rec.organization_id;
              l_tmp_old.subinventory_code       := parent_lpn_rec.subinventory_code;
              l_tmp_old.locator_id              := parent_lpn_rec.locator_id;

              l_tmp_old.inventory_item_id       := parent_lpn_rec.inventory_item_id;
              l_tmp_old.revision                := parent_lpn_rec.revision;
              l_tmp_old.lot_number              := parent_lpn_rec.lot_number;
              l_tmp_old.serial_number           := parent_lpn_rec.serial_number;
              l_tmp_old.cost_group_id           := parent_lpn_rec.cost_group_id;

              l_tmp_old.tare_weight_uom_code    := parent_lpn_rec.tare_weight_uom_code;
              l_tmp_old.tare_weight             := parent_lpn_rec.tare_weight;
              l_tmp_old.gross_weight_uom_code   := parent_lpn_rec.gross_weight_uom_code;
              l_tmp_old.gross_weight            := parent_lpn_rec.gross_weight;
              l_tmp_old.container_volume_uom    := parent_lpn_rec.container_volume_uom;
              l_tmp_old.container_volume        := parent_lpn_rec.container_volume;
              l_tmp_old.content_volume_uom_code := parent_lpn_rec.content_volume_uom_code;
              l_tmp_old.content_volume          := parent_lpn_rec.content_volume;

              l_tmp_old.source_type_id          := parent_lpn_rec.source_type_id;
              l_tmp_old.source_header_id        := parent_lpn_rec.source_header_id;
              l_tmp_old.source_line_id          := parent_lpn_rec.source_line_id;
              l_tmp_old.source_line_detail_id   := parent_lpn_rec.source_line_detail_id;
              l_tmp_old.source_name             := parent_lpn_rec.source_name;

              l_tmp_old.attribute_category      := parent_lpn_rec.attribute_category;
              l_tmp_old.attribute1              := parent_lpn_rec.attribute1;
              l_tmp_old.attribute2              := parent_lpn_rec.attribute2;
              l_tmp_old.attribute3              := parent_lpn_rec.attribute3;
              l_tmp_old.attribute4              := parent_lpn_rec.attribute4;
              l_tmp_old.attribute5              := parent_lpn_rec.attribute5;
              l_tmp_old.attribute6              := parent_lpn_rec.attribute6;
              l_tmp_old.attribute7              := parent_lpn_rec.attribute7;
              l_tmp_old.attribute8              := parent_lpn_rec.attribute8;
              l_tmp_old.attribute9              := parent_lpn_rec.attribute9;
              l_tmp_old.attribute10             := parent_lpn_rec.attribute10;
              l_tmp_old.attribute11             := parent_lpn_rec.attribute11;
              l_tmp_old.attribute12             := parent_lpn_rec.attribute12;
              l_tmp_old.attribute13             := parent_lpn_rec.attribute13;
              l_tmp_old.attribute14             := parent_lpn_rec.attribute14;
              l_tmp_old.attribute15             := parent_lpn_rec.attribute15;

              IF (l_debug = 1) THEN
                mdebug('Retrieve attr from rec lpnid='||l_tmp_old.lpn_id||' gwuom='||l_tmp_old.gross_weight_uom_code||' gwt='||l_tmp_old.gross_weight||' twuom='||l_tmp_old.tare_weight_uom_code||' twt='||l_tmp_old.tare_weight, G_INFO);
                mdebug('cntvuom='||l_tmp_old.content_volume_uom_code||' cntvol='||l_tmp_old.content_volume||' ctrvuom='||l_tmp_old.container_volume_uom||' ctrvol='||l_tmp_old.container_volume, G_INFO);
              END IF;
            END IF;

            -- Add all attibutes to new lpn record
            l_tmp_new := l_tmp_old;

	    --8447369 start
            IF ( inv_cache.set_item_rec(
                                    p_organization_id => l_tmp_old.organization_id
                                  , p_item_id         => l_tmp_old.inventory_item_id ) ) THEN

             mdebug('Found parent lpn item details', G_INFO);

            ELSE
                l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid'||l_tmp_old.organization_id ||' item id='||l_tmp_old.inventory_item_id;
             mdebug('Did not find parent lpn item details', G_INFO);

            END IF;
            --8447369 end

            -- Update parent lpns gross weight
            IF ( NVL(l_change_in_gross_weight, 0) <> 0 AND l_change_in_gross_weight_uom IS NOT NULL ) THEN
              l_progress := 'Update parent LPN gross weight';

              IF ( NVL(l_tmp_new.gross_weight, 0) = 0 OR l_tmp_new.gross_weight_uom_code IS NULL ) THEN
                l_tmp_new.gross_weight          := l_change_in_gross_weight;
                l_tmp_new.gross_weight_uom_code := l_change_in_gross_weight_uom;
              ELSIF ( l_tmp_new.gross_weight_uom_code = l_change_in_gross_weight_uom ) THEN
                l_tmp_new.gross_weight := l_tmp_new.gross_weight + l_change_in_gross_weight;
              ELSE
                -- Both are not null but with different UOMs need to convert
                l_change_in_gross_weight     := Convert_UOM(l_tmp_new.inventory_item_id, l_change_in_gross_weight, l_change_in_gross_weight_uom, l_tmp_new.gross_weight_uom_code, G_NO_CONV_RETURN_ZERO);
                l_change_in_gross_weight_uom := l_tmp_new.gross_weight_uom_code;
                l_tmp_new.gross_weight       := l_tmp_new.gross_weight + l_change_in_gross_weight;
              END IF;

              IF ( l_tmp_new.gross_weight < 0 ) THEN
                l_tmp_new.gross_weight := 0;
              END IF;
            END IF;

	    --8447369 start
              IF (inv_cache.item_rec.weight_uom_code IS NOT NULL ) THEN
               IF (l_tmp_new.gross_weight_uom_code <> inv_cache.item_rec.weight_uom_code ) THEN
                 l_tmp_new.gross_weight := Convert_UOM(
                                    p_inventory_item_id => l_tmp_old.inventory_item_id
                                  , p_fm_quantity       => l_tmp_new.gross_weight
                                  , p_fm_uom            => l_tmp_new.gross_weight_uom_code
                                  , p_to_uom            => inv_cache.item_rec.weight_uom_code
                                  , p_mode              => G_NO_CONV_RETURN_ZERO );
                l_tmp_new.gross_weight_uom_code := inv_cache.item_rec.weight_uom_code;
               END IF;
              END IF;
               mdebug('after conv l_tmp_new.gross_weight' || l_tmp_new.gross_weight, G_INFO);
               mdebug('after conv l_tmp_new.gross_weight_uom_code' || l_tmp_new.gross_weight_uom_code, G_INFO);

              --8447369 end


            -- bug5404902 add section just like above for tare weight
            -- Update parent lpns tare weight
            IF ( NVL(l_change_in_tare_weight, 0) <> 0 AND l_change_in_tare_weight_uom IS NOT NULL ) THEN
              l_progress := 'Update parent LPN tare weight';

              IF ( NVL(l_tmp_new.tare_weight, 0) = 0 OR l_tmp_new.tare_weight_uom_code IS NULL ) THEN
                l_tmp_new.tare_weight          := l_change_in_tare_weight;
                l_tmp_new.tare_weight_uom_code := l_change_in_tare_weight_uom;
              ELSIF ( l_tmp_new.tare_weight_uom_code = l_change_in_tare_weight_uom ) THEN
                l_tmp_new.tare_weight := l_tmp_new.tare_weight + l_change_in_tare_weight;
              ELSE
                -- Both are not null but with different UOMs need to convert
                l_change_in_tare_weight     := Convert_UOM(l_tmp_new.inventory_item_id, l_change_in_tare_weight, l_change_in_tare_weight_uom, l_tmp_new.tare_weight_uom_code, G_NO_CONV_RETURN_ZERO);
                l_change_in_tare_weight_uom := l_tmp_new.tare_weight_uom_code;
                l_tmp_new.tare_weight := l_tmp_new.tare_weight + l_change_in_tare_weight;
              END IF;

              IF ( l_tmp_new.tare_weight < 0 ) THEN
                l_tmp_new.tare_weight := 0;
              END IF;
            END IF;

	    --8447369 start
               IF (inv_cache.item_rec.weight_uom_code IS NOT NULL ) THEN
                IF (l_tmp_new.tare_weight_uom_code <> inv_cache.item_rec.weight_uom_code ) THEN
                 l_tmp_new.tare_weight := Convert_UOM(
                                    p_inventory_item_id => l_tmp_old.inventory_item_id
                                  , p_fm_quantity       => l_tmp_new.tare_weight
                                  , p_fm_uom            => l_tmp_new.tare_weight_uom_code
                                  , p_to_uom            => inv_cache.item_rec.weight_uom_code
                                  , p_mode              => G_NO_CONV_RETURN_ZERO );
                 l_tmp_new.tare_weight_uom_code := inv_cache.item_rec.weight_uom_code ;
                END IF;
               END IF;
               mdebug(' after conv  l_tmp_new.tare_weight' || l_tmp_new.tare_weight, G_INFO);
               mdebug(' after conv  l_tmp_new.tare_weight_uom_code' || l_tmp_new.tare_weight_uom_code, G_INFO);
               --8447369 end


            IF ( NVL(l_change_in_volume, 0) <> 0 AND l_change_in_volume_uom IS NOT NULL ) THEN
              -- Update parent lpns content volume
              IF ( NVL(l_tmp_old.content_volume, 0) = 0 OR l_tmp_old.content_volume_uom_code IS NULL ) THEN
                l_tmp_new.content_volume          := l_change_in_volume;
                l_tmp_new.content_volume_uom_code := l_change_in_volume_uom;
              ELSIF ( l_tmp_old.content_volume_uom_code = l_change_in_volume_uom ) THEN
                l_tmp_new.content_volume := l_tmp_new.content_volume + l_change_in_volume;
              ELSE
                -- Both are not null but with different UOMs need to convert
                l_change_in_volume       := Convert_UOM(l_tmp_new.inventory_item_id, l_change_in_volume, l_change_in_volume_uom, l_tmp_old.content_volume_uom_code, G_NO_CONV_RETURN_ZERO);
                l_change_in_volume_uom   := l_tmp_old.content_volume_uom_code;
                l_tmp_new.content_volume := l_tmp_old.content_volume + l_change_in_volume;
              END IF;

              -- If this LPN is with within another LPN then need to recalculate the change in
              -- volume since content volume used to add to it's parent may be based on the
              -- container item, not the contents.  If no container item is defined then no need
              -- recalculate.
              IF ( l_tmp_new.parent_lpn_id IS NOT NULL AND
                   NVL(l_tmp_old.container_volume, 0) <> 0 AND l_tmp_old.container_volume_uom IS NOT NULL )
              THEN
                l_progress := 'Call helper procedure to calculate change in parent volume';
                Calc_Vol_Change (
                  p_debug             => l_debug
                , p_old_lpn           => l_tmp_old
                , p_new_lpn           => l_tmp_new
                , p_volume_change     => l_change_in_volume
                , p_volume_uom_change => l_change_in_volume_uom );
              END IF;

              IF ( l_tmp_new.content_volume < 0 ) THEN
                l_tmp_new.content_volume := 0;
              END IF;
            END IF;

	    --Bug 8693053
             SELECT count (*) into honor_case_pick_count
                            FROM mtl_material_transactions_temp mmtt, wms_user_task_type_attributes wutta
                            WHERE mmtt.standard_operation_id = wutta.user_task_type_id
                            AND mmtt.organization_id = wutta.organization_id
                            AND mmtt.transfer_lpn_id = l_old.lpn_id
                            AND honor_case_pick_flag = 'Y';

            -- Done calculating changes for this LPN
            l_lpns(l_tmp_i) := l_tmp_new;

            IF (l_debug = 1) THEN
              mdebug('New values for parent LPN lpnid='||l_tmp_new.lpn_id||' gwuom='||l_tmp_new.gross_weight_uom_code||' gwt='||l_tmp_new.gross_weight||' twuom='||l_tmp_new.tare_weight_uom_code||' twt='||l_tmp_new.tare_weight, G_INFO);
              mdebug('cntvuom='||l_tmp_new.content_volume_uom_code||' cntvol='||l_tmp_new.content_volume||' ctrvuom='||l_tmp_new.container_volume_uom||' ctrvol='||l_tmp_new.container_volume, G_INFO);
              mdebug('l_tmp_new.lpn_context '|| l_tmp_new.lpn_context || 'LPN_CONTEXT_PICKED '|| LPN_CONTEXT_PICKED, G_INFO);
              mdebug('ll_old.lpn_id '|| l_old.lpn_id, G_INFO);
              mdebug('honor_case_pick_count '|| honor_case_pick_count, G_INFO);
	    END IF;

            --Bug 8693053 If honorCasePick is enabled for the task, then we need not update the parentLPN
            IF honor_case_pick_count <= 0 THEN

	    IF ( l_tmp_new.lpn_context = LPN_CONTEXT_PICKED ) THEN
              -- Need to call shipping to update this LPNs wt and vol
              wsh_update_tbl(NVL(wsh_update_tbl.last, 0) + 1) := To_DeliveryDetailsRecType(l_tmp_new);
            END IF;
	    END IF;

            -- If there is no more change in weight of volume exit loop
            IF ( NVL(l_change_in_gross_weight, 0) = 0 AND NVL(l_change_in_volume, 0) = 0 ) THEN
              EXIT;
            END IF;
          END LOOP;
          l_progress := 'Done updating nest lpn wt/vol';
        END IF;
        -- Else this is the outermost lpn, no need recalculate change in volume
      END IF;

      l_progress := 'Done updating based in lpn_id';
      l_lpns(l_lpn_tab_i) := l_new;
    END IF; -- End of section that pertains to the LPN itself

    /************************************************************/
    /* Changes that only pertain to Update of entire heirarchy  */
    /* Update or all lpns with same outermost LPN               */
    /************************************************************/
    l_progress := 'Do updates that effect entire heirarcy';
    IF ( p_lpn_table(lpn_tbl_cnt).organization_id       <> l_old.organization_id OR
         p_lpn_table(lpn_tbl_cnt).subinventory_code     <> NVL(l_old.subinventory_code, G_NULL_CHAR) OR
         p_lpn_table(lpn_tbl_cnt).locator_id            <> NVL(l_old.locator_id, G_NULL_NUM) OR
         p_lpn_table(lpn_tbl_cnt).lpn_context           <> NVL(l_old.lpn_context, G_NULL_NUM) OR
         p_lpn_table(lpn_tbl_cnt).source_type_id        <> NVL(l_old.source_type_id, G_NULL_NUM) OR
         p_lpn_table(lpn_tbl_cnt).source_header_id      <> NVL(l_old.source_header_id, G_NULL_NUM) OR
         p_lpn_table(lpn_tbl_cnt).source_line_id        <> NVL(l_old.source_line_id, G_NULL_NUM) OR
         p_lpn_table(lpn_tbl_cnt).source_line_detail_id <> NVL(l_old.source_line_detail_id , G_NULL_NUM)OR
         p_lpn_table(lpn_tbl_cnt).source_name           <> NVL(l_old.source_name, G_NULL_CHAR) )
    THEN
      l_progress := 'Organization';
      IF ( p_lpn_table(lpn_tbl_cnt).organization_id = FND_API.G_MISS_NUM ) THEN
        l_progress := 'organization_id cannot be made null';
        fnd_message.set_name('WMS', 'WMS_UPDATE_LPN_ATTR_ERR');
        fnd_message.set_token('ATTR', 'organization_id');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).organization_id <> l_old.organization_id ) THEN
        l_new.organization_id := p_lpn_table(lpn_tbl_cnt).organization_id;

        --Bug # 3516547
        --Added code to make sure that the Revision/Lot number/Serial Summary Entry are
        --updated from WLC in case of a transfer to an org that doesnt have those controls
        --for the item.
        FOR new_org IN lpn_item_control_cursor ( l_old.organization_id,
                                                   l_new.organization_id,
                                                   l_new.outermost_lpn_id )
        LOOP
         l_progress := 'Find the primary uom code for this item in the source org';

         IF ( NOT inv_cache.set_item_rec(
                p_organization_id => l_old.organization_id
               , p_item_id         => new_org.inventory_item_id ) )
          THEN
            l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid='||l_old.organization_id||' item id='||new_org.inventory_item_id;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

         IF (l_debug = 1) THEN
            mdebug('Got WLC for orgxfer itm='||new_org.inventory_item_id||' oldpuom='||inv_cache.item_rec.primary_uom_code||' newpuom='||new_org.primary_uom_code||
                   ' sctl='||new_org.serial_number_control_code||' lctl='||new_org.lot_control_code||' rctl='||new_org.revision_qty_control_code, G_INFO);
          END IF;

          UPDATE wms_lpn_contents wlc
          SET wlc.last_update_date = SYSDATE
            , wlc.last_updated_by = fnd_global.user_id
            , wlc.organization_id = l_new.organization_id
            , wlc.serial_summary_entry = DECODE (new_org.serial_number_control_code,1,2,6,2,wlc.serial_summary_entry)
            , wlc.serial_number = DECODE (new_org.serial_number_control_code,1,NULL,6,NULL,wlc.serial_number)
            , wlc.lot_number = DECODE (new_org.lot_control_code,1,NULL,wlc.lot_number)
            , wlc.revision = DECODE (new_org.revision_qty_control_code,1,NULL,wlc.revision)
            , wlc.primary_quantity = Convert_UOM(new_org.inventory_item_id, primary_quantity, inv_cache.item_rec.primary_uom_code, new_org.primary_uom_code)
          WHERE rowid = new_org.rowid;
        END LOOP;
      END IF;

      l_progress := 'Subiventory';
      IF ( p_lpn_table(lpn_tbl_cnt).subinventory_code = FND_API.G_MISS_CHAR ) THEN
        l_new.subinventory_code := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).subinventory_code IS NOT NULL ) THEN
        l_new.subinventory_code := p_lpn_table(lpn_tbl_cnt).subinventory_code;
      END IF;

      l_progress := 'Locator';
      IF ( p_lpn_table(lpn_tbl_cnt).locator_id = FND_API.G_MISS_NUM ) THEN
        l_new.locator_id := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).locator_id IS NOT NULL ) THEN
        l_new.locator_id := p_lpn_table(lpn_tbl_cnt).locator_id;
      END IF;

      l_progress := 'source_type_id';
      IF ( p_lpn_table(lpn_tbl_cnt).source_type_id = FND_API.G_MISS_NUM ) THEN
        l_new.source_type_id := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).source_type_id IS NOT NULL ) THEN
        l_new.source_type_id := p_lpn_table(lpn_tbl_cnt).source_type_id;
      END IF;

      l_progress := 'source_header_id';
      IF ( p_lpn_table(lpn_tbl_cnt).source_header_id = FND_API.G_MISS_NUM ) THEN
        l_new.source_header_id := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).source_header_id IS NOT NULL ) THEN
        l_new.source_header_id := p_lpn_table(lpn_tbl_cnt).source_header_id;
      END IF;

      l_progress := 'source_line_id';
      IF ( p_lpn_table(lpn_tbl_cnt).source_line_id = FND_API.G_MISS_NUM ) THEN
        l_new.source_line_id := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).source_line_id IS NOT NULL ) THEN
        l_new.source_line_id := p_lpn_table(lpn_tbl_cnt).source_line_id;
      END IF;

      l_progress := 'source_line_detail_id';
      IF ( p_lpn_table(lpn_tbl_cnt).source_line_detail_id = FND_API.G_MISS_NUM ) THEN
        l_new.source_line_detail_id := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).source_line_detail_id IS NOT NULL ) THEN
        l_new.source_line_detail_id := p_lpn_table(lpn_tbl_cnt).source_line_detail_id;
      END IF;

      l_progress := 'source_name';
      IF ( p_lpn_table(lpn_tbl_cnt).source_name = FND_API.G_MISS_CHAR ) THEN
        l_new.source_name := NULL;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).source_name IS NOT NULL ) THEN
        l_new.source_name := p_lpn_table(lpn_tbl_cnt).source_name;
      END IF;

      l_progress := 'Context';
      -- Must to context after sub and loc!
      IF ( p_lpn_table(lpn_tbl_cnt).lpn_context = FND_API.G_MISS_NUM ) THEN
        l_progress := 'LPN context cannot be made null';
        fnd_message.set_name('WMS', 'WMS_UPDATE_LPN_ATTR_ERR');
        fnd_message.set_token('ATTR', 'lpn_context');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSIF ( p_lpn_table(lpn_tbl_cnt).lpn_context <> l_old.lpn_context ) THEN
        l_new.lpn_context := p_lpn_table(lpn_tbl_cnt).lpn_context;

        l_progress := 'Call API to validate context change';
        IF ( NOT Valid_Context_Change(p_caller, l_old.lpn_context, l_new.lpn_context) ) THEN
          l_progress := 'Failed Valid_Context_Change check';
          RAISE fnd_api.g_exc_error;
        END IF;

        IF ( l_new.lpn_context = LPN_CONTEXT_STORES OR
             l_new.lpn_context = LPN_CONTEXT_PREGENERATED OR
             l_new.lpn_context = LPN_CONTEXT_INTRANSIT )
        THEN
          -- LPNs not in warehouse, cannot have location
          l_new.subinventory_code := NULL;
          l_new.locator_id        := NULL;
        END IF;
      END IF;

      l_progress := 'Add new record to update outermost lpn table to be updated';
      IF ( l_outer_lpn_ids.exists(l_new.outermost_lpn_id) ) THEN
        l_tmp_i := l_outer_lpn_ids(l_new.outermost_lpn_id);
        IF (l_debug = 1) THEN
          mdebug('LPN new outer already exist in table l_tmp_i='||l_tmp_i, G_INFO);
        END IF;
      ELSE
        l_tmp_i := NVL(l_outer_lpns.last, 0) + 1;
        l_outer_lpn_ids(l_new.outermost_lpn_id) := l_tmp_i;
        l_outer_lpns(l_tmp_i).reference_id      := l_new.outermost_lpn_id;

        IF (l_debug = 1) THEN
          mdebug('Create new outer entry in outer table l_tmp_i='||l_tmp_i, G_INFO);
        END IF;
      END IF;

      l_outer_lpns(l_tmp_i).outermost_lpn_id      := l_new.outermost_lpn_id;
      l_outer_lpns(l_tmp_i).organization_id       := l_new.organization_id;
      l_outer_lpns(l_tmp_i).subinventory_code     := l_new.subinventory_code;
      l_outer_lpns(l_tmp_i).locator_id            := l_new.locator_id;
      l_outer_lpns(l_tmp_i).lpn_context           := l_new.lpn_context;
      l_outer_lpns(l_tmp_i).source_type_id        := l_new.source_type_id;
      l_outer_lpns(l_tmp_i).source_header_id      := l_new.source_header_id;
      l_outer_lpns(l_tmp_i).source_line_id        := l_new.source_line_id;
      l_outer_lpns(l_tmp_i).source_line_detail_id := l_new.source_line_detail_id;
      l_outer_lpns(l_tmp_i).source_name           := l_new.source_name;
    END IF;

    IF (l_debug = 1) THEN
      mdebug('New values from LPN updated l_lpn_tab_i='||l_lpn_tab_i||' lpn_tbl_cnt='||lpn_tbl_cnt, G_INFO);
      mdebug('lpnid='||l_new.lpn_id||' lpn='||l_new.license_plate_number||' ctx='||l_new.lpn_context||' plpn='||l_new.parent_lpn_id||' olpn='||l_new.outermost_lpn_id||' itm='||l_new.inventory_item_id||' rev='||l_new.revision, G_INFO);
      mdebug('lot='||l_new.lot_number||' sn='||l_new.serial_number||' cg='||l_new.cost_group_id||' org='||l_new.organization_id||' sub='||l_new.subinventory_code||' loc='||l_new.locator_id, G_INFO);
      mdebug('twt='||l_new.tare_weight||' twuom='||l_new.tare_weight_uom_code||' gwt='||l_new.gross_weight||' gwuom='||l_new.gross_weight_uom_code||
             ' ctrvol='||l_new.container_volume||' ctrvoluom='||l_new.container_volume_uom||' ctnvol='||l_new.content_volume||' ctvuom='||l_new.content_volume_uom_code, G_INFO);
      mdebug('stype='||l_new.source_type_id||' shdr='||l_new.source_header_id||' srcln='||l_new.source_line_id||' srclndt='||l_new.source_line_detail_id||' srcnm='||l_new.source_name, G_INFO);
      --mdebug('reuse='||l_new.lpn_reusability||' hom='||l_new.homogeneous_container||' stat='||l_new.status_id ||' seal='||l_new.sealed_status, G_INFO);
      mdebug('acat='||l_new.attribute_category||' a1='||l_new.attribute1||' a2='||l_new.attribute2||' a3='||l_new.attribute3||' a4='||l_new.attribute4||' a5='||l_new.attribute5||' a6='||l_new.attribute6||' a7='||l_new.attribute7, G_INFO);
      mdebug('a8='||l_new.attribute8||' a9='||l_new.attribute9||' a10='||l_new.attribute10||' a11='||l_new.attribute11||' a12='||l_new.attribute12||' a13='||l_new.attribute13||' a14='||l_new.attribute14||' a15='||l_new.attribute15, G_INFO);
    END IF;

    -- Bug 5639121
    -- Check to find whether flow is for Internal Order
    -- LPN Context changes from 'Loaded to Truck' to "defined but not used'
    -- for Internal Orders only
    IF ( l_old.lpn_context = LPN_LOADED_FOR_SHIPMENT and l_new.lpn_context = LPN_CONTEXT_PREGENERATED ) THEN
	l_internal_order_flag := 1;
    END IF;

    -- Bug 5246192
    -- when shipping a LPN for an internal requisition with direct routing,
    -- the .LPN's context is changed from Picked to Resides in Inventory in a different org
    -- In that case, the LPN should not be removed from WDD in the source org
    -- Add addition where clause that only when context is changed in the same org,
    -- then remove LPN from the WDD.
    -- Bug 7119011

      BEGIN

      select nvl(wda.delivery_id,999) into l_delivery_id
      from  wsh_delivery_details wdd, wsh_delivery_assignments wda
      WHERE wda.delivery_detail_id(+) = wdd.delivery_detail_id  AND ROWNUM < 2
      AND wdd.lpn_id IN
           ( select wlpn.lpn_id
               from wms_license_plate_numbers wlpn
              where wlpn.outermost_lpn_id = p_lpn_table(1).lpn_id);

      IF (l_delivery_id <> 999) THEN

      WSH_UTIL_CORE.GET_DELIVERY_STATUS(
        p_entity_type              => 'DELIVERY'
       ,p_entity_id                => l_delivery_id
       ,x_status_code              => l_status_code
       ,x_return_status            => l_return_status);

      END IF ;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
     IF ( l_debug = 1 ) THEN
          mdebug('There are no deliveries ', G_ERROR);
        END IF;
     END;

    IF ( (l_old.lpn_context = LPN_CONTEXT_PICKED OR l_old.lpn_context = LPN_LOADED_FOR_SHIPMENT) AND
         (l_new.lpn_context = LPN_CONTEXT_INV OR l_new.lpn_context = LPN_CONTEXT_PREGENERATED)  AND
         (l_old.organization_id = l_new.organization_id) -- Bug 5246192
         AND (l_internal_order_flag = 0) AND (NVL(l_status_code,'OP') <>'CL')) -- Bug 7603755
      THEN
      IF ( l_old.parent_lpn_id IS NOT NULL ) THEN
        -- Add this LPN to table so that it can be unpacked in WDD before deletion
        -- No need to specify parent LPN, shipping will derrive this
        l_wsh_unpack_lpn_id_tbl(NVL(l_wsh_unpack_lpn_id_tbl.last, 0) + 1) := l_old.lpn_id;
      END IF;

      -- Add this LPN to table so that it can be deleted from WDD
      -- No need to specify parent LPN, shipping will derrive this
      l_wsh_delete_lpn_id_tbl(NVL(l_wsh_delete_lpn_id_tbl.last, 0) + 1) := l_old.lpn_id;

    ELSIF ( l_old.lpn_context = LPN_CONTEXT_PICKED AND l_new.lpn_context = LPN_CONTEXT_PICKED) THEN
      IF ( NVL(l_old.inventory_item_id, G_NULL_NUM)        <> NVL(l_new.inventory_item_id, G_NULL_NUM) OR
           NVL(l_old.tare_weight, G_NULL_NUM)              <> NVL(l_new.tare_weight, G_NULL_NUM) OR
           NVL(l_old.tare_weight_uom_code, G_NULL_CHAR)    <> NVL(l_new.tare_weight_uom_code, G_NULL_CHAR) OR
           NVL(l_old.gross_weight, G_NULL_NUM)             <> NVL(l_new.gross_weight, G_NULL_NUM) OR
           NVL(l_old.gross_weight_uom_code, G_NULL_CHAR)   <> NVL(l_new.gross_weight_uom_code, G_NULL_CHAR) OR
           NVL(l_old.container_volume, G_NULL_NUM)         <> NVL(l_new.container_volume, G_NULL_NUM) OR
           NVL(l_old.container_volume_uom, G_NULL_CHAR)    <> NVL(l_new.container_volume_uom, G_NULL_CHAR) OR
           NVL(l_old.content_volume, G_NULL_NUM)           <> NVL(l_new.content_volume, G_NULL_NUM) OR
           NVL(l_old.content_volume_uom_code, G_NULL_CHAR) <> NVL(l_new.content_volume_uom_code, G_NULL_CHAR) )
      THEN
        -- If some attribute that shipping cares about has been changed
        -- Need to call shipping to update this LPNs attributes
        wsh_update_tbl(NVL(wsh_update_tbl.last, 0) + 1) := To_DeliveryDetailsRecType(l_new);
      ELSIF ( NVL(l_old.subinventory_code, G_NULL_CHAR) <> NVL(l_new.subinventory_code, G_NULL_CHAR) OR
              NVL(l_old.locator_id, G_NULL_NUM)         <> NVL(l_new.locator_id, G_NULL_NUM) )
      THEN
        -- If any of the following attributes were changed need to inform shipping
        -- add record to call WSH_WMS_LPN_GRP.create_update_containers
        l_tmp_i := NVL(wsh_update_tbl.last, 0) + 1;

        wsh_update_tbl(l_tmp_i).organization_id := l_new.organization_id;
        wsh_update_tbl(l_tmp_i).lpn_id          := l_new.outermost_lpn_id;
        wsh_update_tbl(l_tmp_i).container_name  := l_new.license_plate_number;
        wsh_update_tbl(l_tmp_i).subinventory    := l_new.subinventory_code;
        wsh_update_tbl(l_tmp_i).locator_id      := l_new.locator_id;
      END IF;
    ELSIF ( l_old.lpn_context <> LPN_CONTEXT_PICKED AND l_new.lpn_context = LPN_CONTEXT_PICKED ) THEN
      -- Need to call shipping to create this record
      wsh_create_tbl(NVL(wsh_create_tbl.last, 0) + 1) := To_DeliveryDetailsRecType(l_new);
    END IF;


    IF ( wsh_create_tbl.last > 0 ) THEN
      IF (l_debug = 1) THEN
        mdebug('Calling WSH API to create WDD count='||wsh_create_tbl.last, G_INFO);
      END IF;

      l_IN_rec.caller      := 'WMS';
      l_IN_rec.action_code := 'CREATE';

      WSH_WMS_LPN_GRP.Create_Update_Containers (
        p_api_version     => 1.0
      , p_init_msg_list   => fnd_api.g_false
      , p_commit          => fnd_api.g_false
      , x_return_status   => x_return_status
      , x_msg_count       => x_msg_count
      , x_msg_data        => x_msg_data
      , p_detail_info_tab => wsh_create_tbl
      , p_IN_rec          => l_IN_rec
      , x_OUT_rec         => l_OUT_rec );

      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
        IF (l_debug = 1) THEN
          mdebug('Create_Update_Containers Failed, May alreade exist in WDD, Try update instead', G_ERROR);
          FOR i in 1..x_msg_count LOOP
            l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
          END LOOP;
          mdebug('msg: '||l_msgdata, G_ERROR);
        END IF;
        l_IN_rec.action_code := 'UPDATE';

        WSH_WMS_LPN_GRP.Create_Update_Containers (
          p_api_version     => 1.0
        , p_init_msg_list   => fnd_api.g_false
        , p_commit          => fnd_api.g_false
        , x_return_status   => x_return_status
        , x_msg_count       => x_msg_count
        , x_msg_data        => x_msg_data
        , p_detail_info_tab => wsh_create_tbl
        , p_IN_rec          => l_IN_rec
        , x_OUT_rec         => l_OUT_rec );
      END IF;

      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
        IF (l_debug = 1) THEN
          mdebug('WSH Create Containers Failed', G_ERROR);
        END IF;
        RAISE fnd_api.g_exc_error;
      ELSIF ( l_debug = 1 ) THEN
        mdebug('Done with Create_Update_Containers', G_INFO);
      END IF;

      -- Once Create is done need to clear table
      wsh_create_tbl.delete;
    END IF;

    -- Call Update shipping on an per record basis
    IF ( wsh_update_tbl.last > 0 ) THEN
      IF (l_debug = 1) THEN
        mdebug('Calling WSH API to update WDD count='||wsh_update_tbl.last, G_INFO);
      END IF;

      l_IN_rec.caller      := 'WMS';
      l_IN_rec.action_code := 'UPDATE';

      WSH_WMS_LPN_GRP.Create_Update_Containers (
        p_api_version     => 1.0
      , p_init_msg_list   => fnd_api.g_false
      , p_commit          => fnd_api.g_false
      , x_return_status   => x_return_status
      , x_msg_count       => x_msg_count
      , x_msg_data        => x_msg_data
      , p_detail_info_tab => wsh_update_tbl
      , p_IN_rec          => l_IN_rec
      , x_OUT_rec         => l_OUT_rec );

      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
        IF (l_debug = 1) THEN
          mdebug('Create_Update_Containers Failed, Might not yet exist in WDD, Try create instead', G_ERROR);
          FOR i in 1..x_msg_count LOOP
            l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
          END LOOP;
          mdebug('msg: '||l_msgdata, G_ERROR);
        END IF;
        l_IN_rec.action_code := 'CREATE';

        WSH_WMS_LPN_GRP.Create_Update_Containers (
          p_api_version     => 1.0
        , p_init_msg_list   => fnd_api.g_false
        , p_commit          => fnd_api.g_false
        , x_return_status   => x_return_status
        , x_msg_count       => x_msg_count
        , x_msg_data        => x_msg_data
        , p_detail_info_tab => wsh_update_tbl
        , p_IN_rec          => l_IN_rec
        , x_OUT_rec         => l_OUT_rec );
      END IF;

      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
        IF (l_debug = 1) THEN
          mdebug('WSH Update Containers Failed', G_ERROR);
        END IF;
        RAISE fnd_api.g_exc_error;
      ELSIF ( l_debug = 1 ) THEN
        mdebug('Done with Create_Update_Containers', G_INFO);
      END IF;

      -- Once update is done need to clear table
      wsh_update_tbl.delete;
    END IF;

    IF (l_debug = 1) THEN
      mdebug('Done processing lpn_id='||l_old.lpn_id, G_INFO);
    END IF;
  END LOOP;

  l_progress := 'Done with data handling, transfer to LPN bulk record of tables';

  IF ( l_wsh_unpack_lpn_id_tbl.last > 0 ) THEN
   IF (l_debug = 1) THEN
      mdebug('Call to WSH Delivery_Detail_Action unpack LPNs before becoming pregenerated: '||l_wsh_unpack_lpn_id_tbl.first||'-'||l_wsh_unpack_lpn_id_tbl.last, G_INFO);
    END IF;

    l_wsh_action_prms.caller      := 'WMS';
    l_wsh_action_prms.action_code := 'UNPACK';

    WSH_WMS_LPN_GRP.Delivery_Detail_Action (
      p_api_version_number => 1.0
    , p_init_msg_list      => fnd_api.g_false
    , p_commit             => fnd_api.g_false
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_lpn_id_tbl         => l_wsh_unpack_lpn_id_tbl
    , p_del_det_id_tbl     => l_wsh_del_det_id_tbl
    , p_action_prms        => l_wsh_action_prms
    , x_defaults           => l_wsh_defaults
    , x_action_out_rec     => l_wsh_action_out_rec );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      l_progress := 'Delivery_Detail_Action failed';
      --RAISE fnd_api.g_exc_error;

      IF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF ( l_debug = 1 ) THEN
        mdebug('x_return_status='||x_return_status, G_INFO);
      END IF;
    ELSIF (l_debug = 1) THEN
      mdebug('Done with call to WSH Create_Update_Containers', G_INFO);
    END IF;

    -- Clear used parameters for completeness
    l_wsh_action_prms.caller      := NULL;
    l_wsh_action_prms.action_code := NULL;
    l_wsh_unpack_lpn_id_tbl.delete;
  END IF;

  IF ( l_wsh_delete_lpn_id_tbl.last > 0 ) THEN
    IF (l_debug = 1) THEN
      mdebug('Calling WSH API to remove LPN from WDD: '||l_wsh_delete_lpn_id_tbl.first||'-'||l_wsh_delete_lpn_id_tbl.last, G_INFO);
    END IF;

    l_wsh_action_prms.caller      := 'WMS';
    l_wsh_action_prms.action_code := 'DELETE';

    WSH_WMS_LPN_GRP.Delivery_Detail_Action (
      p_api_version_number => 1.0
    , p_init_msg_list      => fnd_api.g_false
    , p_commit             => fnd_api.g_false
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_lpn_id_tbl         => l_wsh_delete_lpn_id_tbl
    , p_del_det_id_tbl     => l_wsh_del_det_id_tbl
    , p_action_prms        => l_wsh_action_prms
    , x_defaults           => l_wsh_defaults
    , x_action_out_rec     => l_wsh_action_out_rec );

    IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
      IF (l_debug = 1) THEN
        mdebug('Delivery_Detail_Action Not Successful', G_ERROR);
      END IF;

      IF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF ( l_debug = 1 ) THEN
        mdebug('x_return_status='||x_return_status, G_INFO);
      END IF;
    ELSIF ( l_debug = 1 ) THEN
      mdebug('Done with Delivery_Detail_Action', G_INFO);
    END IF;

    -- Clear parameters used
    l_wsh_action_prms.caller      := NULL;
    l_wsh_action_prms.action_code := NULL;
    l_wsh_delete_lpn_id_tbl.delete;
  END IF;

  IF ( l_lpns.last > 0 ) THEN
    l_progress := 'Update LPNs last='||l_outer_lpns.last;
    l_lpn_bulk_rec := To_LPNBulkRecType(l_lpns);

    IF (l_debug = 1) THEN
      mdebug('Bulk Update LPNs in WLPN: '||l_lpn_bulk_rec.lpn_id.first||'-'||l_lpn_bulk_rec.lpn_id.last, G_INFO);

      /*(FOR bulk_i IN l_lpn_bulk_rec.outermost_lpn_id.first .. l_lpn_bulk_rec.outermost_lpn_id.last LOOP
        mdebug('lpn_id='|| l_lpn_bulk_rec.lpn_id(bulk_i));
      END LOOP;*/
    END IF;

    BEGIN
      FORALL bulk_i IN l_lpn_bulk_rec.lpn_id.first .. l_lpn_bulk_rec.lpn_id.last
      UPDATE wms_license_plate_numbers wlpn
         SET last_update_date        = SYSDATE
           , last_updated_by         = fnd_global.user_id
           , organization_id         = l_lpn_bulk_rec.organization_id(bulk_i)
           , license_plate_number    = l_lpn_bulk_rec.license_plate_number(bulk_i)
           , parent_lpn_id           = l_lpn_bulk_rec.parent_lpn_id(bulk_i)
           , outermost_lpn_id        = l_lpn_bulk_rec.outermost_lpn_id(bulk_i)
           , inventory_item_id       = l_lpn_bulk_rec.inventory_item_id(bulk_i)
           , subinventory_code       = l_lpn_bulk_rec.subinventory_code(bulk_i)
           , locator_id              = l_lpn_bulk_rec.locator_id(bulk_i)
           , tare_weight             = l_lpn_bulk_rec.tare_weight(bulk_i)
           , tare_weight_uom_code    = l_lpn_bulk_rec.tare_weight_uom_code(bulk_i)
           , gross_weight_uom_code   = l_lpn_bulk_rec.gross_weight_uom_code(bulk_i)
           , gross_weight            = l_lpn_bulk_rec.gross_weight(bulk_i)
           , container_volume        = l_lpn_bulk_rec.container_volume(bulk_i)
           , container_volume_uom    = l_lpn_bulk_rec.container_volume_uom(bulk_i)
           , content_volume_uom_code = l_lpn_bulk_rec.content_volume_uom_code(bulk_i)
           , content_volume          = l_lpn_bulk_rec.content_volume(bulk_i)
           --, status_id               = l_lpn_bulk_rec.status_id(bulk_i)
           , lpn_context             = l_lpn_bulk_rec.lpn_context(bulk_i)
           --, sealed_status           = l_lpn_bulk_rec.sealed_status(bulk_i)
           , attribute_category      = l_lpn_bulk_rec.attribute_category(bulk_i)
           , attribute1              = l_lpn_bulk_rec.attribute1(bulk_i)
           , attribute2              = l_lpn_bulk_rec.attribute2(bulk_i)
           , attribute3              = l_lpn_bulk_rec.attribute3(bulk_i)
           , attribute4              = l_lpn_bulk_rec.attribute4(bulk_i)
           , attribute5              = l_lpn_bulk_rec.attribute5(bulk_i)
           , attribute6              = l_lpn_bulk_rec.attribute6(bulk_i)
           , attribute7              = l_lpn_bulk_rec.attribute7(bulk_i)
           , attribute8              = l_lpn_bulk_rec.attribute8(bulk_i)
           , attribute9              = l_lpn_bulk_rec.attribute9(bulk_i)
           , attribute10             = l_lpn_bulk_rec.attribute10(bulk_i)
           , attribute11             = l_lpn_bulk_rec.attribute11(bulk_i)
           , attribute12             = l_lpn_bulk_rec.attribute12(bulk_i)
           , attribute13             = l_lpn_bulk_rec.attribute13(bulk_i)
           , attribute14             = l_lpn_bulk_rec.attribute14(bulk_i)
           , attribute15             = l_lpn_bulk_rec.attribute15(bulk_i)
           , source_type_id          = l_lpn_bulk_rec.source_type_id(bulk_i)
           , source_header_id        = l_lpn_bulk_rec.source_header_id(bulk_i)
           , source_line_id          = l_lpn_bulk_rec.source_line_id(bulk_i)
           , source_line_detail_id   = l_lpn_bulk_rec.source_line_detail_id(bulk_i)
           , source_name             = l_lpn_bulk_rec.source_name(bulk_i)
       WHERE lpn_id                  = l_lpn_bulk_rec.lpn_id(bulk_i);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         IF ( l_debug = 1 ) THEN
          mdebug('Bulk Update WLPN failed uniqueness constraint', G_ERROR);
        END IF;

        FOR bulk_i IN l_lpn_bulk_rec.lpn_id.first..l_lpn_bulk_rec.lpn_id.last LOOP
          BEGIN
            SELECT 1 INTO l_dummy_num
            FROM   wms_license_plate_numbers
            WHERE  license_plate_number = l_lpn_bulk_rec.license_plate_number(bulk_i);

            IF ( l_debug = 1 ) THEN
              mdebug('LPN '||l_lpn_bulk_rec.license_plate_number(bulk_i)||' already exists, cannot update another LPN with this name', G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_DUPLICATE_LPN');
            fnd_message.set_token('LPN', l_lpn_bulk_rec.license_plate_number(bulk_i));
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
          END;
        END LOOP;
    END;

    IF (l_debug = 1) THEN
      mdebug('Bulk Updated WLPN count='||SQL%ROWCOUNT, G_INFO);
    END IF;
  END IF;

  IF ( l_outer_lpns.last > 0 ) THEN
    l_progress := 'Update outermost LPNs last='||l_outer_lpns.last;
    l_lpn_bulk_rec := To_LPNBulkRecType(l_outer_lpns);

    IF (l_debug = 1) THEN
      mdebug('Bulk Update outermost LPNs in WLPN: '||l_lpn_bulk_rec.lpn_id.first||'-'||l_lpn_bulk_rec.lpn_id.last, G_INFO);

      /*FOR bulk_i IN l_lpn_bulk_rec.outermost_lpn_id.first .. l_lpn_bulk_rec.outermost_lpn_id.last LOOP
        mdebug('reference_id          ='|| l_lpn_bulk_rec.reference_id(bulk_i));
      END LOOP;*/
    END IF;

    FORALL bulk_i IN l_lpn_bulk_rec.outermost_lpn_id.first .. l_lpn_bulk_rec.outermost_lpn_id.last
    UPDATE wms_license_plate_numbers wlpn
       SET last_update_date      = SYSDATE
         , last_updated_by       = fnd_global.user_id
         , outermost_lpn_id      = l_lpn_bulk_rec.outermost_lpn_id(bulk_i)
         , organization_id       = l_lpn_bulk_rec.organization_id(bulk_i)
         , subinventory_code     = l_lpn_bulk_rec.subinventory_code(bulk_i)
         , locator_id            = l_lpn_bulk_rec.locator_id(bulk_i)
         , lpn_context           = l_lpn_bulk_rec.lpn_context(bulk_i)
         , source_type_id        = l_lpn_bulk_rec.source_type_id(bulk_i)
         , source_header_id      = l_lpn_bulk_rec.source_header_id(bulk_i)
         , source_line_id        = l_lpn_bulk_rec.source_line_id(bulk_i)
         , source_line_detail_id = l_lpn_bulk_rec.source_line_detail_id(bulk_i)
         , source_name           = l_lpn_bulk_rec.source_name(bulk_i)
     WHERE outermost_lpn_id      = l_lpn_bulk_rec.reference_id(bulk_i);

    IF (l_debug = 1) THEN
      mdebug('Bulk Updated outermost WLPN count='||SQL%ROWCOUNT, G_INFO);
    END IF;
  END IF;

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and data
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
      mdebug('msg: '||l_msgdata, G_ERROR);
    END IF;
    ROLLBACK TO MODIFY_LPNS_PVT;
  --WHEN NOWAIT THEN
  --	x_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WMS', 'WMS_UPDATE_LPN_FAILED');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;
    ROLLBACK TO MODIFY_LPNS_PVT;
END Modify_LPNs;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Generate_LPN_CP (
  errbuf                OUT NOCOPY VARCHAR2
, retcode               OUT NOCOPY NUMBER
, p_api_version         IN         NUMBER
, p_organization_id     IN         NUMBER
, p_container_item_id   IN         NUMBER   := NULL
, p_revision            IN         VARCHAR2 := NULL
, p_lot_number          IN         VARCHAR2 := NULL
, p_from_serial_number  IN         VARCHAR2 := NULL
, p_to_serial_number    IN         VARCHAR2 := NULL
, p_subinventory        IN         VARCHAR2 := NULL
, p_locator_id          IN         NUMBER   := NULL
, p_org_parameters      IN         NUMBER
, p_parm_dummy_1        IN         VARCHAR2
, p_total_length        IN         NUMBER
, p_lpn_prefix          IN         VARCHAR2 := NULL
, p_starting_num        IN         NUMBER   := NULL
, p_ucc_128_suffix_flag IN         NUMBER
, p_parm_dummy_2        IN         VARCHAR2
, p_lpn_suffix          IN         VARCHAR2 := NULL
, p_quantity            IN         NUMBER   := 1
, p_source              IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id       IN         NUMBER   := NULL
) IS
BEGIN
  Generate_LPN_CP (
  errbuf                =>	errbuf
, retcode               =>	retcode
, p_api_version         =>	p_api_version
, p_organization_id     =>	p_organization_id
, p_container_item_id   =>	p_container_item_id
, p_revision            =>	p_revision
, p_lot_number          =>	p_lot_number
, p_from_serial_number  =>	p_from_serial_number
, p_to_serial_number    =>	p_to_serial_number
, p_subinventory        =>	p_subinventory
, p_locator_id          =>	p_locator_id
, p_org_parameters      =>	p_org_parameters
, p_parm_dummy_1        =>	p_parm_dummy_1
, p_total_length        =>	p_total_length
, p_lpn_prefix          =>	p_lpn_prefix
, p_starting_num        =>	p_starting_num
, p_ucc_128_suffix_flag =>	p_ucc_128_suffix_flag
, p_parm_dummy_2        =>	p_parm_dummy_2
, p_lpn_suffix          =>	p_lpn_suffix
, p_quantity            =>	p_quantity
, p_source              =>	p_source
, p_cost_group_id       =>	p_cost_group_id
, p_client_code		      =>	NULL
);
END;

------------------------------------------------------------------------
-- Added For LSP Project, bug 9087971
-- Overloaded Procedure added for LSPs with additional parameter as p_client_code
------------------------------------------------------------------------
PROCEDURE Generate_LPN_CP (
  errbuf                OUT NOCOPY VARCHAR2
, retcode               OUT NOCOPY NUMBER
, p_api_version         IN         NUMBER
, p_organization_id     IN         NUMBER
, p_container_item_id   IN         NUMBER   := NULL
, p_revision            IN         VARCHAR2 := NULL
, p_lot_number          IN         VARCHAR2 := NULL
, p_from_serial_number  IN         VARCHAR2 := NULL
, p_to_serial_number    IN         VARCHAR2 := NULL
, p_subinventory        IN         VARCHAR2 := NULL
, p_locator_id          IN         NUMBER   := NULL
, p_org_parameters      IN         NUMBER
, p_parm_dummy_1        IN         VARCHAR2
, p_total_length        IN         NUMBER
, p_lpn_prefix          IN         VARCHAR2 := NULL
, p_starting_num        IN         NUMBER   := NULL
, p_ucc_128_suffix_flag IN         NUMBER
, p_parm_dummy_2        IN         VARCHAR2
, p_lpn_suffix          IN         VARCHAR2 := NULL
, p_quantity            IN         NUMBER   := 1
, p_source              IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id       IN         NUMBER   := NULL
, p_client_code		IN         VARCHAR2  -- Adding for LSP, bug 9087971
) IS
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
x_return_status VARCHAR2(4);
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(300);
ret             BOOLEAN;

l_ucc_128_suffix_flag VARCHAR2(1);
l_lpn_prefix          VARCHAR2(50);
l_lpn_suffix          VARCHAR2(50);
l_wms_org_flag        BOOLEAN;

l_lpn_att_rec WMS_Data_Type_Definitions_PUB.LPNRecordType;
l_serial_tbl  WMS_Data_Type_Definitions_PUB.SerialRangeTableType;
l_gen_lpn_tbl WMS_Data_Type_Definitions_PUB.LPNTableType;

BEGIN
  IF (l_debug = 1) THEN
    mdebug('Generate_LPN_CP Entered '|| g_pkg_version, 1);
    mdebug('orgid=' ||p_organization_id||' sub='||p_subinventory||' loc='||p_locator_id||' orgparam='||p_org_parameters||' src=' ||p_source, G_INFO);
    mdebug('cntitemid=' ||p_container_item_id|| ' rev=' ||p_revision||' lot='||p_lot_number||' fmsn='||p_from_serial_number||' tosn='||p_to_serial_number||' cg='||p_cost_group_id, G_INFO);
    mdebug('prefix='||p_lpn_prefix||' suffix='|| p_lpn_suffix ||' strtnum='||p_starting_num ||' qty='||p_quantity||' lgth='||p_total_length||' ucc='||p_ucc_128_suffix_flag, G_INFO);
  END IF;

  -- Bug 5144565 Check if the organization is a WMS organization
  l_wms_org_flag := wms_install.check_install (
                      x_return_status   => x_return_status
                    , x_msg_count       => x_msg_count
                    , x_msg_data        => x_msg_data
                    , p_organization_id => p_organization_id );
  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug('Call to wms_install.check_install failed:' ||x_msg_data, 1);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( NOT l_wms_org_flag ) THEN
   IF ( l_debug = 1 ) THEN
      mdebug('Generate License Plate concurrent program is only available for WMS enabled organizations', 1);
    END IF;
    fnd_message.set_name('WMS', 'WMS_ONLY_FUNCTIONALITY');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

--7270863 the condition IF ( l_ucc_128_suffix_flag IS NULL ) will be successful now if l_ucc_128_suffix_flag value is null in Auto_Create_LPNs
--'N' will be passed only if it is having some values(2) other than 1
  IF ( p_ucc_128_suffix_flag = 1 ) THEN
    l_ucc_128_suffix_flag := 'Y';
  ELSIF p_ucc_128_suffix_flag is NOT NULL THEN --7270863
    l_ucc_128_suffix_flag := 'N';
  END IF;

  -- Bug 4691144 If the default from org parameters is set to 'no'
  -- Set prefix and suffix to NULL.
  IF ( p_org_parameters = 2 ) THEN
    IF ( p_lpn_prefix IS NULL ) THEN
      l_lpn_prefix := FND_API.G_MISS_CHAR;
    ELSE
      l_lpn_prefix := p_lpn_prefix;
    END IF;

    IF ( p_lpn_suffix IS NULL ) THEN
      l_lpn_suffix := FND_API.G_MISS_CHAR;
    ELSE
      l_lpn_suffix := p_lpn_suffix;
    END IF;
  END IF;

  l_lpn_att_rec.lpn_context       := p_source;
  l_lpn_att_rec.organization_id   := p_organization_id;
  l_lpn_att_rec.subinventory_code := p_subinventory;
  l_lpn_att_rec.locator_id        := p_locator_id;
  l_lpn_att_rec.inventory_item_id := p_container_item_id;
  l_lpn_att_rec.revision          := p_revision;
  l_lpn_att_rec.lot_number        := p_lot_number;
  l_lpn_att_rec.cost_group_id     := p_cost_group_id;

  l_serial_tbl(1).fm_serial_number := p_from_serial_number;
  l_serial_tbl(1).to_serial_number := p_to_serial_number;

  Auto_Create_LPNs (
    p_api_version         => p_api_version
  , p_init_msg_list       => fnd_api.g_false
  , p_commit              => fnd_api.g_false
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  , p_caller              => 'WMS_Generate_LPN_CP'
  , p_quantity            => p_quantity
  , p_lpn_prefix          => l_lpn_prefix
  , p_lpn_suffix          => l_lpn_suffix
  , p_starting_number     => p_starting_num
  , p_total_lpn_length    => p_total_length
  , p_ucc_128_suffix_flag => l_ucc_128_suffix_flag
  , p_lpn_attributes      => l_lpn_att_rec
  , p_serial_ranges       => l_serial_tbl
  , x_created_lpns        => l_gen_lpn_tbl
  , p_client_code         => p_client_code );-- Adding for LSP, bug 9087971

  IF (x_return_status = fnd_api.g_ret_sts_success) THEN
    ret      := fnd_concurrent.set_completion_status('NORMAL', x_msg_data);
    retcode  := 0;
  ELSE
    ret      := fnd_concurrent.set_completion_status('ERROR', x_msg_data);
    retcode  := 2;
    errbuf   := x_msg_data;
  END IF;
END;



/*********************************************************************************
 * Generate_LPN()
 *
 *********************************************************************************/
PROCEDURE Generate_LPN (
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_organization_id       IN         NUMBER
, p_container_item_id     IN         NUMBER   := NULL
, p_revision              IN         VARCHAR2 := NULL
, p_lot_number            IN         VARCHAR2 := NULL
, p_from_serial_number    IN         VARCHAR2 := NULL
, p_to_serial_number      IN         VARCHAR2 := NULL
, p_subinventory          IN         VARCHAR2 := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_lpn_prefix            IN         VARCHAR2 := NULL
, p_lpn_suffix            IN         VARCHAR2 := NULL
, p_starting_num          IN         NUMBER   := NULL
, p_quantity              IN         NUMBER   := 1
, p_source                IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id         IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
, p_lpn_id_out            OUT NOCOPY NUMBER
, p_lpn_out               OUT NOCOPY VARCHAR2
, p_process_id            OUT NOCOPY NUMBER
, p_total_length          IN         NUMBER   := NULL
, p_ucc_128_suffix_flag   IN         NUMBER   := 2
) IS
BEGIN
  Generate_LPN (
  p_api_version           =>	p_api_version
, p_init_msg_list         =>	p_init_msg_list
, p_commit                =>	p_commit
, p_validation_level      =>	p_validation_level
, x_return_status         =>	x_return_status
, x_msg_count             =>	x_msg_count
, x_msg_data              =>	x_msg_data
, p_organization_id       =>	p_organization_id
, p_container_item_id     =>	p_container_item_id
, p_revision              =>	p_revision
, p_lot_number            =>	p_lot_number
, p_from_serial_number    =>	p_from_serial_number
, p_to_serial_number      =>	p_to_serial_number
, p_subinventory          =>	p_subinventory
, p_locator_id            =>	p_locator_id
, p_lpn_prefix            =>	p_lpn_prefix
, p_lpn_suffix            =>	p_lpn_suffix
, p_starting_num          =>	p_starting_num
, p_quantity              =>	p_quantity
, p_source                =>	p_source
, p_cost_group_id         =>	p_cost_group_id
, p_source_type_id        =>	p_source_type_id
, p_source_header_id      =>	p_source_header_id
, p_source_name           =>	p_source_name
, p_source_line_id        =>	p_source_line_id
, p_source_line_detail_id =>	p_source_line_detail_id
, p_lpn_id_out            =>	p_lpn_id_out
, p_lpn_out               =>	p_lpn_out
, p_process_id            =>	p_process_id
, p_total_length          =>	p_total_length
, p_ucc_128_suffix_flag   =>	p_ucc_128_suffix_flag
, p_client_code		  =>	NULL
);
END Generate_LPN;

/*********************************************************************************
 * Generate_LPN()
 * Added for LSP Project, bug 9087971
 * Overloaded for LSPs
 *********************************************************************************/
PROCEDURE Generate_LPN (
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_organization_id       IN         NUMBER
, p_container_item_id     IN         NUMBER   := NULL
, p_revision              IN         VARCHAR2 := NULL
, p_lot_number            IN         VARCHAR2 := NULL
, p_from_serial_number    IN         VARCHAR2 := NULL
, p_to_serial_number      IN         VARCHAR2 := NULL
, p_subinventory          IN         VARCHAR2 := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_lpn_prefix            IN         VARCHAR2 := NULL
, p_lpn_suffix            IN         VARCHAR2 := NULL
, p_starting_num          IN         NUMBER   := NULL
, p_quantity              IN         NUMBER   := 1
, p_source                IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id         IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
, p_lpn_id_out            OUT NOCOPY NUMBER
, p_lpn_out               OUT NOCOPY VARCHAR2
, p_process_id            OUT NOCOPY NUMBER
, p_total_length          IN         NUMBER   := NULL
, p_ucc_128_suffix_flag   IN         NUMBER   := 2
, p_client_code		IN         VARCHAR2  -- Adding for LSP, bug 9087971
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Generate_LPN New';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_ucc_128_suffix_flag VARCHAR2(1);
l_lpn_att_rec  WMS_Data_Type_Definitions_PUB.LPNRecordType;
l_serial_tbl   WMS_Data_Type_Definitions_PUB.SerialRangeTableType;
l_gen_lpn_tbl  WMS_Data_Type_Definitions_PUB.LPNTableType;
l_lpn_bulk_rec LPNBulkRecType;

BEGIN
  SAVEPOINT GENERATE_LPN_PVT;

  IF (l_debug = 1) THEN
    mdebug(l_api_name|| ' Entered '|| g_pkg_version, 1);
    mdebug('orgid=' ||p_organization_id|| ' sub=' ||p_subinventory|| ' loc=' ||p_locator_id|| ' src=' ||p_source, G_INFO);
    mdebug('cntitemid=' ||p_container_item_id|| ' rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' fmsn=' ||p_from_serial_number|| ' tosn=' ||p_to_serial_number|| ' cstgrp=' ||p_cost_group_id, G_INFO);
    mdebug('prefix=' ||p_lpn_prefix|| ' suffix=' || p_lpn_suffix || ' strtnum=' ||p_starting_num || ' qty=' ||p_quantity);
    --mdebug('scrtype=' ||p_source_type_id|| ' srchdr=' ||p_source_header_id|| ' srcname=' ||p_source_name|| ' srcln=' ||p_source_line_id||' srclndet='||p_source_line_detail_id, G_INFO);
    --mdebug('p_total_length='||p_total_length||', p_ucc_128_suf='||p_ucc_128_suffix_flag);
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  l_lpn_att_rec.lpn_context           := p_source;
  l_lpn_att_rec.organization_id       := p_organization_id;
  l_lpn_att_rec.subinventory_code     := p_subinventory;
  l_lpn_att_rec.locator_id            := p_locator_id;
  l_lpn_att_rec.inventory_item_id     := p_container_item_id;
  l_lpn_att_rec.revision              := p_revision;
  l_lpn_att_rec.lot_number            := p_lot_number;
  l_lpn_att_rec.cost_group_id         := p_cost_group_id;
  l_lpn_att_rec.source_type_id        := p_source_type_id;
  l_lpn_att_rec.source_header_id      := p_source_header_id;
  l_lpn_att_rec.source_name           := p_source_name;
  l_lpn_att_rec.source_line_id        := p_source_line_id;
  l_lpn_att_rec.source_line_detail_id := p_source_line_detail_id;

  l_serial_tbl(1).fm_serial_number := p_from_serial_number;
  l_serial_tbl(1).to_serial_number := p_to_serial_number;


    IF ( p_ucc_128_suffix_flag = 1 ) THEN
      l_ucc_128_suffix_flag := 'Y';
    ELSIF p_ucc_128_suffix_flag is NOT NULL THEN
      l_ucc_128_suffix_flag := 'N';
    END IF;

  Auto_Create_LPNs (
    p_api_version         => p_api_version
  , p_init_msg_list       => fnd_api.g_false
  , p_commit              => fnd_api.g_false
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  , p_caller              => 'Generate_LPN'
  , p_quantity            => p_quantity
  , p_lpn_prefix          => p_lpn_prefix
  , p_lpn_suffix          => p_lpn_suffix
  , p_starting_number     => p_starting_num
  , p_total_lpn_length    => p_total_length
  , p_ucc_128_suffix_flag => l_ucc_128_suffix_flag
  , p_lpn_attributes      => l_lpn_att_rec
  , p_serial_ranges       => l_serial_tbl
  , x_created_lpns        => l_gen_lpn_tbl
  , p_client_code         => p_client_code );-- Adding for LSP, bug 9087971

  IF ( x_return_status = fnd_api.g_ret_sts_success ) THEN
    IF ( p_quantity = 1 ) THEN
      p_lpn_id_out := l_gen_lpn_tbl(1).lpn_id;
      p_lpn_out    := l_gen_lpn_tbl(1).license_plate_number;
    ELSE
      -- More than one LPN was requested to be generated
      -- Generate a process ID number to tell which LPN's were generated
      SELECT wms_lpn_process_temp_s.NEXTVAL
      INTO   p_process_id
      FROM   DUAL;

      -- transfer to LPN bulk record of tables
      l_lpn_bulk_rec := To_LPNBulkRecType(l_gen_lpn_tbl);

      IF ( l_debug = 1 ) THEN
        mdebug('Inser into the WMS_LPN_PROCESS_TEMP procid='||p_process_id||' '||l_lpn_bulk_rec.lpn_id.first||'-'||l_lpn_bulk_rec.lpn_id.last , G_INFO);
      END IF;

      FORALL i in l_lpn_bulk_rec.lpn_id.first .. l_lpn_bulk_rec.lpn_id.last
      INSERT INTO wms_lpn_process_temp (
        process_id
      , lpn_id )
      VALUES (
        p_process_id
      , l_lpn_bulk_rec.lpn_id(i) );
    END IF;
  ELSE
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    --fnd_message.set_name('WMS', 'WMS_LPN_GENERATION_FAIL');
    --fnd_msg_pub.ADD;
    ROLLBACK TO GENERATE_LPN_PVT;
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    fnd_message.set_name('WMS', 'WMS_LPN_GENERATION_FAIL');
    fnd_msg_pub.ADD;
    ROLLBACK TO GENERATE_LPN_PVT;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    fnd_message.set_name('WMS', 'WMS_LPN_GENERATION_FAIL');
    fnd_msg_pub.ADD;
    ROLLBACK TO GENERATE_LPN_PVT;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END Generate_LPN;

  -- ----------------------------------------------------------------------------------
  -- ----------------------------------------------------------------------------------
  PROCEDURE associate_lpn(
    p_api_version           IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false,
    p_commit                IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN     NUMBER := fnd_api.g_valid_level_full,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_lpn_id                IN     NUMBER,
    p_container_item_id     IN     NUMBER,
    p_lot_number            IN     VARCHAR2 := NULL,
    p_revision              IN     VARCHAR2 := NULL,
    p_serial_number         IN     VARCHAR2 := NULL,
    p_organization_id       IN     NUMBER,
    p_subinventory          IN     VARCHAR2 := NULL,
    p_locator_id            IN     NUMBER := NULL,
    p_cost_group_id         IN     NUMBER := NULL,
    p_source_type_id        IN     NUMBER := NULL,
    p_source_header_id      IN     NUMBER := NULL,
    p_source_name           IN     VARCHAR2 := NULL,
    p_source_line_id        IN     NUMBER := NULL,
    p_source_line_detail_id IN     NUMBER := NULL
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'Associate_LPN';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_lpn_tbl WMS_Data_Type_Definitions_PUB.LPNTableType;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT ASSOCIATE_LPN_PVT;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- API body
    IF (l_debug = 1) THEN
      mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
      mdebug('orgid=' ||p_organization_id|| ' sub=' ||p_subinventory|| ' loc=' ||p_locator_id|| ' lpnid=' ||p_lpn_id, G_INFO);
      mdebug('itemid=' ||p_container_item_id|| ' rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' sn=' ||p_serial_number, G_INFO);
      mdebug('cg=' ||p_cost_group_id|| ' srctype=' ||p_source_type_id||' srchdr='||p_source_header_id||' srcln='||p_source_line_id, G_INFO);
    END IF;

    l_lpn_tbl(1).lpn_id                := p_lpn_id;
    l_lpn_tbl(1).organization_id       := p_organization_id;
    l_lpn_tbl(1).subinventory_code     := p_subinventory;
    l_lpn_tbl(1).locator_id            := p_locator_id;

    l_lpn_tbl(1).inventory_item_id     := p_container_item_id;
    l_lpn_tbl(1).lot_number            := p_lot_number;
    l_lpn_tbl(1).revision              := p_revision;
    l_lpn_tbl(1).serial_number         := p_serial_number;
    l_lpn_tbl(1).cost_group_id         := p_cost_group_id;

    l_lpn_tbl(1).source_type_id        := p_source_type_id;
    l_lpn_tbl(1).source_header_id      := p_source_header_id;
    l_lpn_tbl(1).source_name           := p_source_name;
    l_lpn_tbl(1).source_line_id        := p_source_line_id;
    l_lpn_tbl(1).source_line_detail_id := p_source_line_detail_id;

    Modify_LPNs (
      p_api_version   => 1.0
    , p_init_msg_list => fnd_api.g_false
    , p_commit        => fnd_api.g_false
    , x_return_status => x_return_status
    , x_msg_count     => x_msg_count
    , x_msg_data      => x_msg_data
    , p_caller        => l_api_name
    , p_lpn_table     => l_lpn_tbl );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF ( l_debug = 1 ) THEN
        mdebug('Modify_LPNs failed', G_ERROR);
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO ASSOCIATE_LPN_PVT;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO ASSOCIATE_LPN_PVT;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ASSOCIATE_LPN_PVT;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END associate_lpn;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Create_LPN (
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_lpn                   IN         VARCHAR2
, p_organization_id       IN         NUMBER
, p_container_item_id     IN         NUMBER   := NULL
, p_lot_number            IN         VARCHAR2 := NULL
, p_revision              IN         VARCHAR2 := NULL
, p_serial_number         IN         VARCHAR2 := NULL
, p_subinventory          IN         VARCHAR2 := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_source                IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id         IN         NUMBER   := NULL
, p_parent_lpn_id         IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
, x_lpn_id                OUT NOCOPY NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Create_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';
l_msgdata              VARCHAR2(1000);

l_lpn_tbl WMS_Data_Type_Definitions_PUB.LPNTableType;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT CREATE_LPN_PVT;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status               := fnd_api.g_ret_sts_success;

  -- API body
  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('orgid=' ||p_organization_id|| ' sub=' ||p_subinventory|| ' loc=' ||p_locator_id|| ' lpn=' ||p_lpn|| ' src=' ||p_source, G_INFO);
    mdebug('cntitemid=' ||p_container_item_id|| ' rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' sn=' ||p_serial_number|| ' cstgrp=' ||p_cost_group_id, G_INFO);
    mdebug('prntlpnid=' ||p_parent_lpn_id|| ' scrtype=' ||p_source_type_id|| ' srchdr=' ||p_source_header_id|| ' srcname=' ||p_source_name|| ' srcln=' ||p_source_line_id||' srclndet='||p_source_line_detail_id, G_INFO);
  END IF;

  l_lpn_tbl(1).license_plate_number  := p_lpn;
  l_lpn_tbl(1).organization_id       := p_organization_id;
  l_lpn_tbl(1).inventory_item_id     := p_container_item_id;
  l_lpn_tbl(1).lot_number            := p_lot_number;
  l_lpn_tbl(1).revision              := p_revision;
  l_lpn_tbl(1).serial_number         := p_serial_number;
  l_lpn_tbl(1).subinventory_code     := p_subinventory;
  l_lpn_tbl(1).locator_id            := p_locator_id;
  l_lpn_tbl(1).lpn_context           := p_source;
  l_lpn_tbl(1).cost_group_id         := p_cost_group_id;
  --l_lpn_tbl(1).parent_lpn_id         := p_parent_lpn_id;
  l_lpn_tbl(1).source_type_id        := p_source_type_id;
  l_lpn_tbl(1).source_header_id      := p_source_header_id;
  l_lpn_tbl(1).source_name           := p_source_name;
  l_lpn_tbl(1).source_line_id        := p_source_line_id;
  l_lpn_tbl(1).source_line_detail_id := p_source_line_detail_id;

  Create_LPNs (
    p_api_version   => p_api_version
  , p_init_msg_list => fnd_api.g_false
  , p_commit        => fnd_api.g_false
  , x_return_status => x_return_status
  , x_msg_count     => x_msg_count
  , x_msg_data      => x_msg_data
  , p_caller        => l_api_name
  , p_lpn_table     => l_lpn_tbl );

  IF ( x_return_status = fnd_api.g_ret_sts_success ) THEN
    x_lpn_id := l_lpn_tbl(1).lpn_id;
  ELSE
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' Error progress= '||l_progress||'SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
      mdebug('msg: '||l_msgdata, G_ERROR);
    END IF;
    ROLLBACK TO CREATE_LPN_PVT;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress= '||l_progress||'SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;
    ROLLBACK TO CREATE_LPN_PVT;
END Create_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE PackUnpack_Container(
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_lpn_id                 IN         NUMBER
, p_content_lpn_id         IN         NUMBER   := NULL
, p_content_item_id        IN         NUMBER   := NULL
, p_content_item_desc      IN         VARCHAR2 := NULL
, p_revision               IN         VARCHAR2 := NULL
, p_lot_number             IN         VARCHAR2 := NULL
, p_from_serial_number     IN         VARCHAR2 := NULL
, p_to_serial_number       IN         VARCHAR2 := NULL
, p_quantity               IN         NUMBER   := 1
, p_uom                    IN         VARCHAR2 := NULL
, p_sec_quantity           IN         NUMBER   := NULL   -- INVCONV kkillams
, p_sec_uom                IN         VARCHAR2 := NULL   -- INVCONV kkillams
, p_organization_id        IN         NUMBER
, p_subinventory           IN         VARCHAR2 := NULL
, p_locator_id             IN         NUMBER   := NULL
, p_enforce_wv_constraints IN         NUMBER   := 2
, p_operation              IN         NUMBER
, p_cost_group_id          IN         NUMBER   := NULL
, p_source_type_id         IN         NUMBER   := NULL
, p_source_header_id       IN         NUMBER   := NULL
, p_source_name            IN         VARCHAR2 := NULL
, p_source_line_id         IN         NUMBER   := NULL
, p_source_line_detail_id  IN         NUMBER   := NULL
, p_unpack_all             IN         NUMBER   := 2
, p_auto_unnest_empty_lpns IN         NUMBER   := 1
, p_ignore_item_controls   IN         NUMBER   := 2
, p_primary_quantity       IN         NUMBER   := NULL
, p_caller                 IN         VARCHAR2 := NULL
, p_source_transaction_id  IN         NUMBER   := NULL
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'PackUnpack_Container';
l_api_version CONSTANT NUMBER        := 1.0;
l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_request_id           NUMBER        := FND_PROFILE.value('CONC_REQUEST_ID');
l_progress             VARCHAR2(100) := '0';
l_msgdata              VARCHAR2(1000);

-- Constants defined for transaction types
L_PACK       CONSTANT NUMBER := 1;
L_UNPACK     CONSTANT NUMBER := 2;
L_CORRECT    CONSTANT NUMBER := 3;
L_UNPACK_ALL CONSTANT NUMBER := 4;

-- Types needed for WSH_WMS_LPN_GRP.Delivery_Detail_Action
l_wsh_lpn_id_tbl       wsh_util_core.id_tab_type;
l_wsh_del_det_id_tbl   wsh_util_core.id_tab_type;
l_wsh_action_prms      WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
l_wsh_defaults         WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;
l_wsh_action_out_rec   WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

l_lpn_tbl              WMS_Data_Type_Definitions_PUB.LPNTableType;
l_new                  WMS_Data_Type_Definitions_PUB.LPNRecordType;
l_cont_new             WMS_Data_Type_Definitions_PUB.LPNRecordType;

l_tmp_bulk_lpns        LPNBulkRecType;
l_tmp_i                NUMBER;

l_lpn                    WMS_CONTAINER_PUB.LPN;
l_content_lpn            WMS_CONTAINER_PUB.LPN;
l_wt_vol_new             WMS_CONTAINER_PUB.LPN;

l_result                 NUMBER;
l_serial_summary_entry   NUMBER := 2;

l_subinventory           VARCHAR(30);
l_locator_id             NUMBER;

l_prefix                 VARCHAR2(30);
l_from_number            NUMBER;
l_to_number              NUMBER;
l_errorcode              NUMBER;

l_converted_quantity     NUMBER;
l_sec_converted_quantity NUMBER;  --INVCONV kkillams
l_lpn_is_empty           NUMBER := 0;

l_operation_mode         NUMBER;
l_quantity               NUMBER;
l_primary_quantity       NUMBER;
l_item_quantity          NUMBER;
l_serial_quantity        NUMBER;
l_uom_priority           VARCHAR2(3);

l_change_in_gross_weight     NUMBER;
l_change_in_gross_weight_uom VARCHAR2(3);
l_change_in_tare_weight      NUMBER;
l_change_in_tare_weight_uom  VARCHAR(3);
l_change_in_volume           NUMBER;
l_change_in_volume_uom       VARCHAR2(3);

CURSOR nested_children_cursor(p_outer_lpn_id NUMBER) IS
  SELECT lpn_id
    FROM wms_license_plate_numbers
   START WITH lpn_id = p_outer_lpn_id
 CONNECT BY parent_lpn_id = PRIOR lpn_id;

CURSOR nested_parent_cursor(p_child_lpn_id NUMBER) IS
  SELECT organization_id, parent_lpn_id, lpn_id, inventory_item_id,
         tare_weight, tare_weight_uom_code, gross_weight, gross_weight_uom_code,
         container_volume, container_volume_uom, content_volume, content_volume_uom_code
  FROM   wms_license_plate_numbers
  START WITH lpn_id = p_child_lpn_id
  CONNECT BY lpn_id = PRIOR parent_lpn_id;

empty_lpn_rec nested_parent_cursor%ROWTYPE;

CURSOR existing_record_cursor( p_context NUMBER, p_serial_summary_entry NUMBER ) IS
  SELECT wlc.rowid
       , wlc.primary_quantity
       , wlc.quantity
       , wlc.uom_code
       , wlc.cost_group_id
       , wlc.secondary_quantity  --INVCONV kkillams
       , wlc.secondary_uom_code  --INVCONV kkillams
    FROM wms_lpn_contents wlc
   WHERE wlc.parent_lpn_id = p_lpn_id
     AND wlc.organization_id = p_organization_id
     AND wlc.uom_code = p_uom
     AND wlc.inventory_item_id = p_content_item_id
     AND NVL(wlc.revision, G_NULL_CHAR) = NVL(p_revision, G_NULL_CHAR)
     AND NVL(wlc.lot_number, G_NULL_CHAR) = NVL(p_lot_number, G_NULL_CHAR)
     AND NVL(wlc.source_type_id, G_NULL_NUM) = NVL(p_source_type_id, G_NULL_NUM)
     AND NVL(wlc.source_header_id, G_NULL_NUM) = NVL(p_source_header_id, G_NULL_NUM)
     AND NVL(wlc.source_line_id, G_NULL_NUM) = NVL(p_source_line_id, G_NULL_NUM)
     AND NVL(wlc.source_line_detail_id, G_NULL_NUM) = NVL(p_source_line_detail_id, G_NULL_NUM)
     AND NVL(wlc.source_name, G_NULL_CHAR) = NVL(p_source_name, G_NULL_CHAR)
     AND NVL(wlc.serial_summary_entry, 2) = p_serial_summary_entry;

l_existing_record_cursor existing_record_cursor%ROWTYPE;

CURSOR existing_unpack_record_cursor( p_serial_summary_entry NUMBER, p_uom_code VARCHAR2 ) IS
  SELECT wlc.rowid
       , wlc.primary_quantity
       , wlc.quantity
       , wlc.uom_code
       , wlc.lot_number
       , wlc.serial_summary_entry
       , wlc.secondary_quantity  --INVCONV kkillams
       , wlc.secondary_uom_code  --INVCONV kkillams
    FROM wms_lpn_contents wlc
   WHERE wlc.parent_lpn_id = p_lpn_id
     AND wlc.organization_id = p_organization_id
     AND wlc.inventory_item_id = p_content_item_id
     AND wlc.uom_code = NVL(p_uom_code, wlc.uom_code)
     AND NVL(wlc.revision, G_NULL_CHAR) = NVL(p_revision, G_NULL_CHAR)
     AND NVL(wlc.lot_number, G_NULL_CHAR) = NVL(DECODE(p_serial_summary_entry, NULL, wlc.lot_number, p_lot_number), G_NULL_CHAR)
     AND NVL(wlc.source_type_id, G_NULL_NUM) = NVL(p_source_type_id, NVL(wlc.source_type_id, G_NULL_NUM))
     AND NVL(wlc.source_header_id, G_NULL_NUM) = NVL(p_source_header_id, NVL(wlc.source_header_id, G_NULL_NUM))
     AND NVL(wlc.source_line_id, G_NULL_NUM) = NVL(p_source_line_id, NVL(wlc.source_line_id, G_NULL_NUM))
     AND NVL(wlc.source_line_detail_id, G_NULL_NUM) = NVL(p_source_line_detail_id, NVL(wlc.source_line_detail_id, G_NULL_NUM))
     AND NVL(wlc.source_name, G_NULL_CHAR) = NVL(p_source_name, NVL(wlc.source_name, G_NULL_CHAR))
     AND NVL(wlc.serial_summary_entry, 2) = NVL(p_serial_summary_entry, NVL(wlc.serial_summary_entry, 2))
     AND (NVL(wlc.source_name, G_NULL_CHAR) NOT IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
          OR NVL(p_source_name, G_NULL_CHAR) IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
         )
   ORDER BY wlc.lot_number, wlc.source_type_id DESC, wlc.source_header_id DESC, wlc.source_line_id DESC, wlc.source_line_detail_id DESC, wlc.source_name DESC;

l_temp_record existing_unpack_record_cursor%ROWTYPE;

CURSOR one_time_item_cursor IS
  SELECT rowid
       , primary_quantity
       , quantity
       , secondary_quantity --INVCONV kkillams
    FROM wms_lpn_contents
   WHERE parent_lpn_id = p_lpn_id
     AND organization_id = p_organization_id
     AND item_description = p_content_item_desc
     AND NVL(cost_group_id, G_NULL_NUM) = NVL(p_cost_group_id, G_NULL_NUM)
     AND NVL(serial_summary_entry, 2) = l_serial_summary_entry;

l_one_time_item_rec one_time_item_cursor%ROWTYPE;

CURSOR nested_container_cursor IS
  SELECT rowid
       , lpn_id
       , organization_id
       , inventory_item_id
       , tare_weight
       , tare_weight_uom_code
    FROM wms_license_plate_numbers
   START WITH lpn_id = p_lpn_id
 CONNECT BY parent_lpn_id = PRIOR lpn_id;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT PACKUNPACK_CONTAINER;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('orgid='||p_organization_id||' sub='||p_subinventory||' loc='||p_locator_id||' lpnid='||p_lpn_id||' cntlpn='||p_content_lpn_id||' enfrc='||p_enforce_wv_constraints, G_INFO);
    mdebug('itemid='||p_content_item_id||' rev='||p_revision||' lot='||p_lot_number||' fmsn='||p_from_serial_number||' tosn='||p_to_serial_number||' itmds='||p_content_item_desc, G_INFO);
    mdebug('qty='||p_quantity||' uom='||p_uom||' cg='||p_cost_group_id||' oper='||p_operation||' upkall='||p_unpack_all||' unnst='||p_auto_unnest_empty_lpns||' ign='||p_ignore_item_controls, G_INFO);
    mdebug('styp='||p_source_type_id||' shdr='||p_source_header_id||' sln='||p_source_line_id||' slndt='||p_source_line_detail_id||' snm='||p_source_name, G_INFO);
    mdebug('secondary quantity='||p_sec_quantity||' secondary uom='||p_sec_uom);  --INVCONV kkillams
  END IF;

  -- Need to do this to support old legacy parameter
  IF ( p_unpack_all = 1 ) THEN
    l_operation_mode := L_UNPACK_ALL;
  ELSE
    l_operation_mode := p_operation;
  END IF;

  IF ( p_from_serial_number IS NOT NULL ) THEN
    l_serial_summary_entry := 1;
  ELSE
    l_serial_summary_entry := 2;
  END IF;

  l_progress := 'Retrieve valuse for parent LPN';

  l_lpn.lpn_id                := p_lpn_id;
  l_lpn.license_plate_number  := NULL;
  l_result                    := WMS_CONTAINER_PVT.validate_lpn(l_lpn, 1);

  IF (l_result = inv_validate.f) THEN
    IF (l_debug = 1) THEN
      mdebug(p_lpn_id || 'is an invalid lpn_id', G_ERROR);
    END IF;
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  IF (l_debug = 1) THEN
    mdebug('lpn='||l_lpn.license_plate_number||' org='||l_lpn.organization_id||' sub='||l_lpn.subinventory_code||' loc='||l_lpn.locator_id||' ctx='||l_lpn.lpn_context, G_MESSAGE);
    mdebug('lpnid='||l_lpn.lpn_id||' lpn='||l_lpn.license_plate_number||' ctx='||l_lpn.lpn_context||' plpn='||l_lpn.parent_lpn_id||' olpn='||l_lpn.outermost_lpn_id||' itm='||l_lpn.inventory_item_id||' rev='||l_lpn.revision, G_INFO);
    mdebug('lot='||l_lpn.lot_number||' sn='||l_lpn.serial_number||' cg='||l_lpn.cost_group_id||' org='||l_lpn.organization_id||' sub='||l_lpn.subinventory_code||' loc='||l_lpn.locator_id||' gwuom='||l_lpn.gross_weight_uom_code, G_INFO);
    mdebug('gwt='||l_lpn.gross_weight||' vuom='||l_lpn.content_volume_uom_code||' vol='||l_lpn.content_volume||' twuom='||l_lpn.tare_weight_uom_code||' twt='||l_lpn.tare_weight||' stype='||l_lpn.source_type_id, G_INFO);
    mdebug('shdr='||l_lpn.source_header_id||' srcln='||l_lpn.source_line_id||' srclndt='||l_lpn.source_line_detail_id||' srcnm='||l_lpn.source_name||' stat='|| l_lpn.status_id ||' seal='||l_lpn.sealed_status, G_INFO);
  END IF;

  -- Validate that LPN is in correct organzation
  IF ( p_organization_id <> l_lpn.organization_id ) THEN
    l_progress := 'Org passed by user does not match org on LPN';
    fnd_message.set_name('WMS', 'WMS_LPN_DIFF_ORG_ERR');
    fnd_message.set_token('LPN', l_lpn.license_plate_number);
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Validate quantities
  IF ( NVL(p_quantity, 0) < 0 OR NVL(p_primary_quantity, 0) < 0 ) THEN
    l_progress := 'cannot pass negitive qty to this API';
    fnd_message.set_name('WMS', 'WMS_CONT_NEG_QTY');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  IF ( p_content_lpn_id IS NOT NULL ) THEN
    l_progress := 'Validate Content LPN';
    l_content_lpn.lpn_id  := p_content_lpn_id;
    l_result              := WMS_CONTAINER_PVT.validate_lpn(l_content_lpn);

    IF (l_result = inv_validate.f) THEN
      IF (l_debug = 1) THEN
        mdebug(p_lpn_id || 'is an invalid lpn_id', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CONTENT_LPN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      mdebug('cntlpn='||l_content_lpn.license_plate_number||' org='||l_content_lpn.organization_id||' sub='||l_content_lpn.subinventory_code||' loc='||l_content_lpn.locator_id||' ctx='||l_content_lpn.lpn_context, G_MESSAGE);
      mdebug('lpnid='||l_content_lpn.lpn_id||' lpn='||l_content_lpn.license_plate_number||' ctx='||l_content_lpn.lpn_context||' plpn='||l_content_lpn.parent_lpn_id||' olpn='||l_content_lpn.outermost_lpn_id, G_INFO);
      mdebug('itm='||l_content_lpn.inventory_item_id||' rev='||l_content_lpn.revision||' lot='||l_content_lpn.lot_number||' sn='||l_content_lpn.serial_number||' cg='||l_content_lpn.cost_group_id||' org='||l_content_lpn.organization_id, G_INFO);
      mdebug('sub='||l_content_lpn.subinventory_code||' loc='||l_content_lpn.locator_id||' gwuom='||l_content_lpn.gross_weight_uom_code||' gwt='||l_content_lpn.gross_weight||' vuom='||l_content_lpn.content_volume_uom_code, G_INFO);
      mdebug('vol='||l_content_lpn.content_volume||' twuom='||l_content_lpn.tare_weight_uom_code||' twt='||l_content_lpn.tare_weight||' stype='||l_content_lpn.source_type_id||' shdr='||l_content_lpn.source_header_id, G_INFO);
      mdebug('srcln='||l_content_lpn.source_line_id||' srclndt='||l_content_lpn.source_line_detail_id||' srcnm='||l_content_lpn.source_name||' stat='||l_content_lpn.status_id, G_INFO);
    END IF;

    -- Check that the content lpn is in fact stored within the given parent lpn
    -- Do this check only for the unpack operation
    IF ( l_operation_mode = L_UNPACK ) THEN
      IF (l_content_lpn.parent_lpn_id <> l_lpn.lpn_id) THEN
        IF (l_debug = 1) THEN
          mdebug('content lpn not in parent lpn', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_LPN_NOT_IN_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    l_quantity         := 1;
    l_primary_quantity := 1;
  ELSIF ( p_content_item_id IS NOT NULL ) THEN
    l_progress := 'Calling INV_CACHE.Set_Item_Rec to get item values';

    IF ( inv_cache.set_item_rec(
           p_organization_id => p_organization_id
         , p_item_id         => p_content_item_id ) )
    THEN
      IF (l_debug = 1) THEN
        mdebug('Got Item info puom='||inv_cache.item_rec.primary_uom_code||' snctl='||inv_cache.item_rec.serial_number_control_code, G_INFO);
        mdebug('wuom='||inv_cache.item_rec.weight_uom_code||' wt='||inv_cache.item_rec.unit_weight||' vuom='||inv_cache.item_rec.volume_uom_code||' vol='||inv_cache.item_rec.unit_volume, G_INFO);
      END IF;
    ELSE
      l_progress := 'Error calling INV_CACHE.Set_Item_Rec for orgid'||p_organization_id||' item id='||p_content_item_id;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF ( p_primary_quantity IS NULL ) THEN
      IF ( p_uom = inv_cache.item_rec.primary_uom_code ) THEN
        l_primary_quantity := p_quantity;
      ELSE
        l_primary_quantity := Convert_UOM(p_content_item_id, p_quantity, p_uom, inv_cache.item_rec.primary_uom_code);
      END IF;
    ELSE
      l_primary_quantity := p_primary_quantity;
    END IF;

    l_quantity := p_quantity;

    IF (l_debug = 1) THEN
      mdebug('l_quantity='||l_quantity||' l_primary_quantity='||l_primary_quantity, G_INFO);
    END IF;
  ELSIF ( l_operation_mode <> L_UNPACK_ALL ) THEN
   -- Unpack all transaction does not need a content lpn/item every other transaction should however.
    l_progress := 'Either an item or a content lpn must be specified';
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
    fnd_msg_pub.ADD;
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CONTENT_LPN');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Parse Serials with out validation
  -- Sub and locator might not be given in the case of pre-packing
  IF (p_content_item_id IS NOT NULL) THEN
    /* Toshiba Fix */
    IF ( inv_cache.item_rec.serial_number_control_code NOT IN (1) ) THEN
      IF ((p_from_serial_number IS NOT NULL) AND (p_to_serial_number IS NOT NULL)) THEN
        l_progress := 'Call this API to parse sn '||p_from_serial_number||'-'||p_to_serial_number;

        IF (NOT mtl_serial_check.inv_serial_info(p_from_serial_number, p_to_serial_number, l_prefix, l_quantity, l_from_number, l_to_number, l_errorcode)) THEN
          IF (l_debug = 1) THEN
            mdebug('Invalid serial number in range', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        l_progress := 'Done with call to parse sn';
        IF (l_debug = 1) THEN
          mdebug('Parse SN done prefix='||l_prefix||' qty='||l_quantity||' fmnum='||l_from_number||' tonum='||l_to_number, G_MESSAGE);
        END IF;

        -- bug5025225 transaction of serial items assumed to be in primary UOM
        -- must assign value to primary quantity.
        l_primary_quantity := l_quantity;

        -- Check that in the case of a range of serial numbers, that the
        -- inputted p_quantity equals the amount of items in the serial range.
        IF (p_quantity IS NOT NULL) THEN
          IF (p_quantity <> l_quantity) THEN
            IF (l_debug = 1) THEN
              mdebug('Serial range quantity '||l_quantity||' not the same as given qty '||p_quantity, G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_X_QTY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;

  l_progress := 'Figure out what subinventory we are trying to pack into';
  IF ( p_subinventory IS NULL ) THEN
    IF ( l_lpn.subinventory_code IS NOT NULL ) THEN
      l_subinventory := l_lpn.subinventory_code;
      l_locator_id   := l_lpn.locator_id;
    ELSIF ( l_content_lpn.subinventory_code IS NOT NULL ) THEN
      l_subinventory := l_content_lpn.subinventory_code;
      l_locator_id   := l_content_lpn.locator_id;
    ELSIF ( l_lpn.lpn_context IN (LPN_CONTEXT_INV, LPN_CONTEXT_PICKED) ) THEN
      IF (l_debug = 1) THEN
        mdebug('No sub and loc info found' , 1);
      END IF;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_SUBLOC_MISS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_subinventory := p_subinventory;
    l_locator_id   := p_locator_id;
  END IF;

  IF ( l_subinventory IS NOT NULL ) THEN
    l_progress := 'Calling Inv_Cache.Set_Tosub_Rec to get sub';
    IF ( NOT inv_cache.set_tosub_rec(p_organization_id, l_subinventory) ) THEN
      l_progress := 'Failed to find subinventory org='||p_organization_id||' sub='||l_subinventory;
      FND_MESSAGE.SET_NAME('INV', 'INVALID_SUB');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF ( p_subinventory IS NOT NULL AND NVL(inv_cache.tosub_rec.lpn_controlled_flag, 2) = 1 ) THEN
    -- subinventory and location infromation was passed validate against lpn
    IF ( p_subinventory <> NVL(l_lpn.subinventory_code, l_content_lpn.subinventory_code) OR
         p_locator_id   <> NVL(l_lpn.locator_id, l_content_lpn.locator_id ) ) THEN
      IF (l_debug = 1) THEN
        mdebug('LPN was found to be in a different sub/loc than what user specified' , 1);
        mdebug('lpn sub=' || l_lpn.subinventory_code ||' lpn loc=' || l_lpn.locator_id, 1);
      END IF;
      -- Recieving LPNs may have Rcv locations on them but.  Allow the location
      -- to be different
      IF ( l_lpn.lpn_context <> LPN_CONTEXT_RCV ) THEN
        FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_SUBLOC_MISMATCH');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;

  /*** Packing or Adjust Operation ***/
  IF ( l_operation_mode = L_PACK OR l_operation_mode = L_CORRECT ) THEN
    -- Check that in case of a pack, the destination subinventory
    -- is an LPN enabled/controlled subinventory otherwise fail.
    IF ( l_subinventory IS NOT NULL AND NVL(inv_cache.tosub_rec.lpn_controlled_flag, 2) <> 1 ) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_NON_LPN_SUB');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF ( p_content_lpn_id IS NOT NULL AND p_content_item_id IS NULL ) THEN
      l_progress := 'Packing a LPN into another LPN';

      -- Update content LPN parent lpn to be null
      l_cont_new.lpn_id                := p_content_lpn_id;
      l_cont_new.parent_lpn_id         := l_lpn.lpn_id;
      l_cont_new.outermost_lpn_id      := l_lpn.outermost_lpn_id;
      l_cont_new.source_type_id        := p_source_type_id;
      l_cont_new.source_header_id      := p_source_header_id;
      l_cont_new.source_line_id        := p_source_line_id;
      l_cont_new.source_line_detail_id := p_source_line_detail_id;
      l_cont_new.source_name           := p_source_name;

      -- If the LPN has no sub or loc information, it will take on the values of the packed item.

      IF ( l_lpn.subinventory_code IS NULL ) THEN
        IF (l_debug = 1) THEN
          mdebug('Xfer LPN has no sub lpnctx='||l_lpn.lpn_context||' clpn sub='||l_content_lpn.subinventory_code||' loc='||l_content_lpn.locator_id||' ctx='||l_content_lpn.lpn_context, G_MESSAGE);
        END IF;
        -- Update the local LPN variable
        l_new.lpn_id            := l_lpn.lpn_id;
        l_new.subinventory_code := l_subinventory;
        l_new.locator_id        := l_locator_id;

        IF ( l_lpn.lpn_context = LPN_CONTEXT_PREGENERATED ) THEN
          -- If pregenerated take context of the content LPN
          l_new.lpn_context := l_content_lpn.lpn_context;
        END IF;
      ELSIF ( l_lpn.subinventory_code <> l_content_lpn.subinventory_code OR
              l_lpn.locator_id        <> l_content_lpn.locator_id ) THEN
        -- Check if the content LPN's sub and loc are the same as the parent lpn

        IF (l_debug = 1) THEN
          mdebug('parent lpn sub '|| l_lpn.subinventory_code || ' or loc ' || l_lpn.locator_id, G_ERROR);
          mdebug('differs from content item sub '|| l_lpn.subinventory_code || ' or loc ' || l_lpn.locator_id, G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_MISMATCHED_SUB_LOC');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- Only if there is a difference in location, update nested
      -- lpns/items/serials with the new location
      IF ( l_lpn.organization_id   <> l_content_lpn.organization_id OR
           l_lpn.subinventory_code <> l_content_lpn.subinventory_code OR
           l_lpn.locator_id        <> l_content_lpn.locator_id )
      THEN
        l_tmp_bulk_lpns.lpn_id.delete;

        OPEN nested_children_cursor(l_content_lpn.outermost_lpn_id);

        FETCH nested_children_cursor
        BULK COLLECT INTO l_tmp_bulk_lpns.lpn_id;

        IF (l_debug = 1) THEN
          mdebug('Bulk update child LPN WLC/MSN: '||l_tmp_bulk_lpns.lpn_id.first||'-'||l_tmp_bulk_lpns.lpn_id.last, G_INFO);
        END IF;

        -- Update the location information for the packed items
        IF ( l_lpn.organization_id <> l_content_lpn.organization_id) THEN
          FORALL bulk_i IN l_tmp_bulk_lpns.lpn_id.first .. l_tmp_bulk_lpns.lpn_id.last
          UPDATE wms_lpn_contents
             SET organization_id = l_lpn.organization_id
               , last_update_date = SYSDATE
               , last_updated_by  = fnd_global.user_id
               , request_id       = l_request_id
           WHERE parent_lpn_id = l_tmp_bulk_lpns.lpn_id(bulk_i);

           IF (l_debug = 1) THEN
             mdebug('Bulk updated org in WLC cnt='||SQL%ROWCOUNT, G_INFO);
           END IF;
        END IF;

        -- Update the location information for serialized packed items
        FORALL bulk_i IN l_tmp_bulk_lpns.lpn_id.first .. l_tmp_bulk_lpns.lpn_id.last
        UPDATE mtl_serial_numbers
          SET current_organization_id   = l_lpn.organization_id
            , current_subinventory_code = l_lpn.subinventory_code
            , current_locator_id        = l_lpn.locator_id
            , last_update_date          = SYSDATE
            , last_updated_by           = fnd_global.user_id
        WHERE lpn_id = l_tmp_bulk_lpns.lpn_id(bulk_i);

        IF (l_debug = 1) THEN
          mdebug('Bulk updated org/sub/loc in MSN cnt='||SQL%ROWCOUNT, G_INFO);
        END IF;

        CLOSE nested_children_cursor;
      END IF;

      -- Update the location information for the nested child containers
      l_progress := 'Pack LPN: Need to update parent lpns weight and volume';
      l_wt_vol_new                 := l_lpn;
      l_change_in_gross_weight     := l_content_lpn.gross_weight;
      l_change_in_gross_weight_uom := l_content_lpn.gross_weight_uom_code;
      -- bug5404902 Added to update tare weight of parent
      l_change_in_tare_weight      := l_content_lpn.tare_weight;
      l_change_in_tare_weight_uom  := l_content_lpn.tare_weight_uom_code;

      -- Need to find if the container of content volume is greater and increment parent
      -- LPNs content volume by that amount
      Get_Greater_Qty (
        p_debug             => l_debug
      , p_inventory_item_id => l_content_lpn.inventory_item_id
      , p_quantity1         => l_content_lpn.container_volume
      , p_quantity1_uom     => l_content_lpn.container_volume_uom
      , p_quantity2         => l_content_lpn.content_volume
      , p_quantity2_uom     => l_content_lpn.content_volume_uom_code
      , x_greater_qty       => l_change_in_volume
      , x_greater_qty_uom   => l_change_in_volume_uom );

    ELSIF ( p_content_lpn_id IS NULL AND p_content_item_id IS NOT NULL ) THEN
      l_progress := 'Packing a non-container item item_id='|| p_content_item_id;

      -- If the LPN has no sub or loc information, it will take on the values of the packed item.
      IF (l_lpn.subinventory_code IS NULL AND
          (p_subinventory IS NOT NULL OR p_locator_id IS NOT NULL))
      THEN
        l_progress := 'LPN has no loc info, setting to values passed in by api';
        l_new.lpn_id            := l_lpn.lpn_id;
        l_new.subinventory_code := p_subinventory;
        l_new.locator_id        := p_locator_id;
      END IF;

      -- If item is serail controlled update MSN
      IF ( p_from_serial_number IS NOT NULL ) THEN
        l_progress := 'Packing serialized items sn '||p_from_serial_number||'-'||p_to_serial_number;

        -- Serialized item packed LPN information are stored in the serial numbers table
        -- Also update the cost group field since it is not guaranteed that the serial number will
        -- have that value stamped
        UPDATE mtl_serial_numbers
           SET lpn_id                  = p_lpn_id
             , cost_group_id           = p_cost_group_id
             , last_update_date        = SYSDATE
             , last_updated_by         = fnd_global.user_id
             , last_txn_source_type_id = DECODE(last_txn_source_type_id, 5, 5, p_source_type_id)--8687722
             , last_txn_source_id      = p_source_header_id
             , last_txn_source_name    = p_source_name
             , revision                = DECODE(current_status, 3, revision, p_revision)
             , lot_number              = DECODE(current_status, 3, lot_number, p_lot_number)
         WHERE inventory_item_id       = p_content_item_id
           AND current_organization_id = p_organization_id
           AND length(serial_number)   = length(p_from_serial_number)
           AND serial_number BETWEEN p_from_serial_number AND NVL(p_to_serial_number, p_from_serial_number);

        l_serial_quantity := SQL%ROWCOUNT;

        IF (l_debug = 1) THEN
          mdebug('Packed serials cnt='||l_serial_quantity, G_INFO);
        END IF;

        -- Check that in the case of a range of serial numbers, that the
        -- inputted p_quantity equals the amount of items in the serial range.
        IF ( p_quantity IS NOT NULL ) THEN
          IF ( l_serial_quantity <> l_primary_quantity ) THEN
            l_progress := 'Serial range quantity '||l_serial_quantity||' not the same as given qty '||l_primary_quantity;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_X_QTY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      -- Keep track of change in quantity since in case of correction
      -- it will be the difference of existing quantity and new quantity
      l_item_quantity := l_primary_quantity;

      OPEN existing_record_cursor(l_lpn.lpn_context, l_serial_summary_entry);

      FETCH existing_record_cursor INTO l_existing_record_cursor;

      IF ( existing_record_cursor%FOUND ) THEN
        IF (l_debug = 1) THEN
          mdebug('Got WLC rec pqty='||l_existing_record_cursor.primary_quantity||' qty='||l_existing_record_cursor.quantity||' uom='||l_existing_record_cursor.uom_code||' cg='||l_existing_record_cursor.cost_group_id, G_INFO);
        END IF;

        -- Validate that if the same item (as the passed-in item p_content_item_id)
        -- exists on the destination LPN (p_lpn_id) at the top level (not in a child LPN),
        -- their cost groups are the same.
        IF ( p_validation_level = fnd_api.g_valid_level_full ) THEN
          IF ( l_serial_summary_entry <> 1 AND p_cost_group_id <> l_existing_record_cursor.cost_group_id ) THEN
            IF (l_debug = 1) THEN
              mdebug('Cost Group Violation during packing cg='||l_existing_record_cursor.cost_group_id||' already exists in lpn', G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_DIFF_CST_GRPS');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        --INCONV kkillams
        IF p_sec_uom IS NOT NULL THEN
           l_sec_converted_quantity := inv_convert.inv_um_convert(p_content_item_id,
                                                                  g_precision,
                                                                  l_existing_record_cursor.secondary_quantity,
                                                                  l_existing_record_cursor.secondary_uom_code,
                                                                  p_sec_uom,
                                                                  NULL,
                                                                  NULL);
           IF ( l_sec_converted_quantity < 0 ) THEN
                   fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
                   fnd_message.set_token('uom1', l_existing_record_cursor.secondary_uom_code);
                   fnd_message.set_token('uom2', p_sec_uom);
                   fnd_message.set_token('module', l_api_name);
                   fnd_msg_pub.ADD;
                   RAISE fnd_api.g_exc_error;
            END IF;
        END IF;
        --INCONV kkillams

        l_progress := 'Updating existing item row in WLC for pack';
        /* fix for bug 2949825 */
        IF ( l_operation_mode = L_CORRECT ) THEN
          UPDATE wms_lpn_contents
          SET last_update_date = SYSDATE
            , last_updated_by  = fnd_global.user_id
            , request_id       = l_request_id
            , quantity         = l_quantity
            , uom_code         = p_uom
            , primary_quantity = l_primary_quantity
          WHERE rowid = l_existing_record_cursor.rowid;

          -- To calculate wt and volume changes need the difference in quantity
          l_item_quantity := l_primary_quantity - l_existing_record_cursor.primary_quantity;
        ELSE
          UPDATE WMS_LPN_CONTENTS
          SET last_update_date   = SYSDATE
            , last_updated_by    = FND_GLOBAL.USER_ID
            , request_id         = l_request_id
            , quantity           = quantity + l_quantity
            , uom_code           = p_uom
            , primary_quantity   = primary_quantity + l_primary_quantity
            , secondary_quantity = CASE WHEN p_sec_uom IS NOT NULL THEN l_sec_converted_quantity + p_sec_quantity
                                        ELSE secondary_quantity END  --INVCONV kkillams
          WHERE rowid = l_existing_record_cursor.rowid;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mdebug('Inserting new item row into WLC');
        END IF;

        INSERT INTO wms_lpn_contents (
          last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , request_id
        , lpn_content_id
        , parent_lpn_id
        , organization_id
        , inventory_item_id
        , item_description
        , revision
        , lot_number
        , quantity
        , uom_code
        , primary_quantity
        , cost_group_id
        , source_type_id
        , source_header_id
        , source_line_id
        , source_line_detail_id
        , source_name
        , serial_summary_entry
        , secondary_quantity
        , secondary_uom_code)
        VALUES (
          SYSDATE
        , fnd_global.user_id
        , SYSDATE
        , fnd_global.user_id
        , l_request_id
        , wms_lpn_contents_s.NEXTVAL
        , p_lpn_id
        , p_organization_id
        , p_content_item_id
        , p_content_item_desc
        , p_revision
        , p_lot_number
        , l_quantity
        , p_uom
        , l_primary_quantity
        , p_cost_group_id
        , p_source_type_id
        , p_source_header_id
        , p_source_line_id
        , p_source_line_detail_id
        , p_source_name
        , l_serial_summary_entry
        , p_sec_quantity --INVCONV kkillams
        , p_sec_uom      --INVCONV kkillams
        );
      END IF;

      CLOSE existing_record_cursor;

      l_progress := 'Pack item: Need to update parent lpns weight and volume';
      l_wt_vol_new                 := l_lpn;
      l_change_in_gross_weight     := l_item_quantity * inv_cache.item_rec.unit_weight;
      l_change_in_gross_weight_uom := inv_cache.item_rec.weight_uom_code;
      l_change_in_volume           := l_item_quantity * inv_cache.item_rec.unit_volume;
      l_change_in_volume_uom       := inv_cache.item_rec.volume_uom_code;
    ELSE /** Packing a one time item **/
      -- If the LPN has no sub or loc information, it will take on the
      -- values of the packed item.
      IF (l_lpn.subinventory_code IS NULL AND
          (p_subinventory IS NOT NULL OR p_locator_id IS NOT NULL))
      THEN
        l_new.lpn_id            := p_lpn_id;
        l_new.subinventory_code := p_subinventory;
        l_new.locator_id        := p_locator_id;
      END IF;

      /* Pack the one time item */
      OPEN one_time_item_cursor;
      FETCH one_time_item_cursor INTO l_one_time_item_rec;

      IF one_time_item_cursor%NOTFOUND THEN
        INSERT INTO wms_lpn_contents (
          last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , request_id
        , lpn_content_id
        , parent_lpn_id
        , organization_id
        , inventory_item_id
        , item_description
        , revision
        , lot_number
        , serial_number
        , quantity
        , uom_code
        , primary_quantity
        , cost_group_id
        , source_type_id
        , source_header_id
        , source_line_id
        , source_line_detail_id
        , source_name
        , serial_summary_entry
        , secondary_quantity
        , secondary_uom_code
        )
        VALUES (
          SYSDATE
        , fnd_global.user_id
        , SYSDATE
        , fnd_global.user_id
        , l_request_id
        , WMS_LPN_CONTENTS_S.NEXTVAL
        , p_lpn_id
        , p_organization_id
        , p_content_item_id
        , p_content_item_desc
        , p_revision
        , p_lot_number
        , p_from_serial_number
        , l_quantity
        , p_uom
        , l_primary_quantity
        , p_cost_group_id
        , p_source_type_id
        , p_source_header_id
        , p_source_line_id
        , p_source_line_detail_id
        , p_source_name
        , 2
        , p_sec_quantity --INVCONV kkillams
        , p_sec_uom      --INVCONV kkillams
        );
      ELSE
        UPDATE wms_lpn_contents
           SET last_update_date = SYSDATE
             , last_updated_by  = fnd_global.user_id
             , request_id       = l_request_id
             , quantity         = NVL(l_one_time_item_rec.quantity, 1) + NVL(l_quantity, 1)
             , uom_code         = p_uom
             , source_type_id = p_source_type_id
             , source_header_id = p_source_header_id
             , source_line_id = p_source_line_id
             , source_line_detail_id = p_source_line_detail_id
             , source_name = p_source_name
             , secondary_quantity = CASE WHEN p_sec_uom IS NOT NULL THEN NVL(l_one_time_item_rec.secondary_quantity, 1) +
                                                                         inv_convert.inv_um_convert(inventory_item_id
                                                                                                    ,g_precision
                                                                                                    ,NVL(l_quantity,1)
                                                                                                    ,p_uom
                                                                                                    ,p_sec_uom
                                                                                                    ,NULL
                                                                                                    ,NULL)
                                         ELSE secondary_quantity END --INVCONV kkillams
             , secondary_uom_code = p_sec_uom  --INVCONV kkillams
         WHERE rowid = l_one_time_item_rec.rowid;
      END IF;

      CLOSE one_time_item_cursor;

    END IF;
  ELSIF ( l_operation_mode = L_UNPACK ) THEN /*** Unpacking Operation ***/
    IF ( p_content_lpn_id IS NOT NULL AND p_content_item_id IS NULL ) THEN
      -- Update content LPN parent lpn to be null
      l_cont_new.lpn_id           := p_content_lpn_id;
      l_cont_new.parent_lpn_id    := FND_API.G_MISS_NUM;
      l_cont_new.outermost_lpn_id := p_content_lpn_id;

      /* Bug 2308339: Update the Organization, Sub, Locator only if Sub is LPN Controlled */
      IF( l_subinventory IS NOT NULL AND NVL(inv_cache.tosub_rec.lpn_controlled_flag, 2) = 1 ) THEN
        FOR l_child_lpn IN nested_children_cursor(p_content_lpn_id) LOOP
          -- Only if there is a difference in location, update nested
          -- lpns/items/serials with the new location
          IF ( l_content_lpn.organization_id <> p_organization_id OR
               l_content_lpn.subinventory_code <> l_subinventory OR
               l_content_lpn.locator_id <> l_locator_id ) THEN
            -- Update the location information for the packed items
            IF ( l_content_lpn.organization_id <> p_organization_id ) THEN
              UPDATE wms_lpn_contents
                 SET organization_id  = p_organization_id
                   , last_update_date = SYSDATE
                   , last_updated_by  = fnd_global.user_id
                   , request_id       = l_request_id
               WHERE organization_id = l_content_lpn.organization_id
                 AND parent_lpn_id = l_child_lpn.lpn_id;
            END IF;

            -- Update the location information for serialized packed items
            UPDATE mtl_serial_numbers
               SET current_organization_id = p_organization_id
                 , current_subinventory_code = l_subinventory
                 , current_locator_id = l_locator_id
                 , last_update_date = SYSDATE
                 , last_updated_by = fnd_global.user_id
             WHERE current_organization_id = l_content_lpn.organization_id
               AND lpn_id = l_child_lpn.lpn_id;
          END IF;
        END LOOP;

        -- Update the location information for the nested child containers
        l_cont_new.organization_id   := p_organization_id;
        l_cont_new.subinventory_code := l_subinventory;
        l_cont_new.locator_id        := l_locator_id;
      END IF;

      -- Check to see if there are any items or child containers in soruce LPN
      IF ( NVL(p_auto_unnest_empty_lpns, 1) = 1 AND l_lpn_is_empty = 0 ) THEN
        BEGIN
          SELECT 0 INTO l_lpn_is_empty
          FROM   dual
          WHERE EXISTS (
            SELECT 1 FROM wms_lpn_contents
            WHERE  organization_id = p_organization_id
            AND    parent_lpn_id = l_lpn.lpn_id )
          OR EXISTS (
            SELECT 1 FROM wms_license_plate_numbers
            WHERE  organization_id = p_organization_id
            AND    parent_lpn_id = l_lpn.lpn_id
            AND    lpn_id <> l_content_lpn.lpn_id );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_lpn_is_empty := 1;
        END;
      END IF;

      -- If the source LPN is not empty then the update weight and volume of source LPN
      -- Otherwise this calculation is irrelevant since the lpn will become pregenerated
      IF ( l_lpn_is_empty <> 1 ) THEN
        l_progress := 'Unpack LPN: Need to update parent lpns weight and volume';
        l_wt_vol_new                 := l_lpn;
        l_change_in_gross_weight     := -1 * l_content_lpn.gross_weight;
        l_change_in_gross_weight_uom := l_content_lpn.gross_weight_uom_code;
        -- bug5404902 Added to update tare weight of parent
        l_change_in_tare_weight      := -1 * l_content_lpn.tare_weight;
        l_change_in_tare_weight_uom  := l_content_lpn.tare_weight_uom_code;

        -- Need to find if the container of content volume is greater and decrement parent
        -- LPNs content volume by that amount
        Get_Greater_Qty (
          p_debug             => l_debug
        , p_inventory_item_id => l_content_lpn.inventory_item_id
        , p_quantity1         => l_content_lpn.container_volume
        , p_quantity1_uom     => l_content_lpn.container_volume_uom
        , p_quantity2         => l_content_lpn.content_volume
        , p_quantity2_uom     => l_content_lpn.content_volume_uom_code
        , x_greater_qty       => l_change_in_volume
        , x_greater_qty_uom   => l_change_in_volume_uom );

        -- Unpack need change value to negative
        l_change_in_volume := -1 * l_change_in_volume;
      END IF;
    ELSIF ((p_content_lpn_id IS NULL) AND (p_content_item_id IS NOT NULL)) THEN
      l_progress := 'Unpacking item from LPN';

      IF ((p_from_serial_number IS NOT NULL)AND (p_to_serial_number IS NOT NULL)) THEN
        l_progress := 'Unacking serialized items sn '||p_from_serial_number||'-'||p_to_serial_number;

        -- Serialized item packed LPN information are stored
        -- in the serial numbers table
        UPDATE mtl_serial_numbers
          SET lpn_id                  = NULL
            , last_update_date        = SYSDATE
            , last_updated_by         = fnd_global.user_id
        WHERE inventory_item_id       = p_content_item_id
          AND current_organization_id = p_organization_id
          AND length(serial_number)   = length(p_from_serial_number)
          AND serial_number BETWEEN p_from_serial_number AND NVL(p_to_serial_number, p_from_serial_number);

        IF (l_debug = 1) THEN
          mdebug('Unpacked serials cnt='||SQL%ROWCOUNT, G_INFO);
        END IF;
      END IF;

      -- If serial numbers were passed to API remove contents from serial summary entries in WLC
      IF ( p_ignore_item_controls = 1 ) THEN
        l_serial_summary_entry := NULL;
      END IF;

      -- Use l_item_quantity to remember how much qty needs to be decremented
      l_item_quantity := l_primary_quantity;
      l_uom_priority  := p_uom;

      l_progress := 'Opening existing_unpack_record_cursor serentry='||l_serial_summary_entry||' uom='||l_uom_priority;
      OPEN existing_unpack_record_cursor(l_serial_summary_entry, l_uom_priority);

      LOOP
        FETCH existing_unpack_record_cursor INTO l_temp_record;

        IF ( existing_unpack_record_cursor%FOUND ) THEN
          IF (l_debug = 1) THEN
            mdebug('Got WLC rec pqty='||l_temp_record.primary_quantity||' qty='||l_temp_record.quantity||' uom='||l_temp_record.uom_code||' lot='||l_temp_record.lot_number||' snsum='||l_temp_record.serial_summary_entry, G_INFO);
          END IF;

          IF ( l_temp_record.primary_quantity IS NULL ) THEN
            l_temp_record.primary_quantity := Convert_UOM(
                                                p_content_item_id
                                              , l_temp_record.quantity
                                              , l_temp_record.uom_code
                                              , inv_cache.item_rec.primary_uom_code);

            IF (l_debug = 1) THEN
              mdebug('Converted WLC pri qty='||l_temp_record.primary_quantity, G_INFO);
            END IF;
          END IF;

         IF (l_debug = 1) THEN
              mdebug('p_sec_uom ='||p_sec_uom, G_INFO);
              mdebug('l_temp_record.secondary_uom_code ='||l_temp_record.secondary_uom_code, G_INFO);
         END IF;
         --INCONV kkillams

         -- Bug 7665639 rework

         IF (p_sec_uom IS NOT NULL )
            AND (p_sec_uom <> l_temp_record.secondary_uom_code) THEN
            l_sec_converted_quantity := inv_convert.inv_um_convert(p_content_item_id,
                                                                   g_precision,
                                                                   l_temp_record.secondary_quantity,
                                                                   l_temp_record.secondary_uom_code,
                                                                   p_sec_uom,
                                                                   NULL,
                                                                   NULL);
            IF (l_debug = 1) THEN
              mdebug('l_sec_converted_quantity ='||l_sec_converted_quantity, G_INFO);
            END IF;

            IF ( l_sec_converted_quantity < 0 ) THEN
                    fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
                    fnd_message.set_token('uom1', l_temp_record.secondary_uom_code);
                    fnd_message.set_token('uom2', p_sec_uom);
                    fnd_message.set_token('module', l_api_name);
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_error;
             END IF;
         else  -- Bug 7665639  rework added else condition
            l_sec_converted_quantity :=  l_temp_record.secondary_quantity;

         END IF;


          IF (l_debug = 1) THEN
              mdebug('l_item_quantity ='||l_item_quantity, G_INFO);
              mdebug('l_temp_record.primary_quantity ='||l_temp_record.primary_quantity, G_INFO);
              mdebug('l_temp_record.uom_code ='||l_temp_record.uom_code, G_INFO);
              mdebug('inv_cache.item_rec.primary_uom_code ='||inv_cache.item_rec.primary_uom_code, G_INFO);
          END IF;

          --INCONV kkillams

          IF ( round(l_item_quantity, g_precision) < round(l_temp_record.primary_quantity, g_precision) ) THEN
            IF ( l_temp_record.uom_code <> inv_cache.item_rec.primary_uom_code ) THEN
              l_converted_quantity := Convert_UOM(
                                        p_content_item_id
                                      , l_item_quantity
                                      , inv_cache.item_rec.primary_uom_code
                                      , l_temp_record.uom_code);
            ELSE
              l_converted_quantity := l_item_quantity;
            END IF;

            IF (l_debug = 1) THEN
              mdebug('l_converted_quantity ='||l_converted_quantity, G_INFO);
            END IF;
             --Bug#8526734,no need to use std conversion everytime.Also added lot_number in case p_sec_quantity is null
            -- Decrement unpack quantity from contents and break loop
            UPDATE wms_lpn_contents
               SET last_update_date = SYSDATE
                 , last_updated_by  = fnd_global.user_id
                 , request_id       = l_request_id
                 , quantity         = quantity - l_converted_quantity
                 , primary_quantity = primary_quantity - l_item_quantity
                 , secondary_quantity =  CASE WHEN p_sec_uom IS NOT NULL
                                                THEN (secondary_quantity - p_sec_quantity) -- bug 8671025
                                                ELSE secondary_quantity END    --INVCONV kkillams
                 , secondary_uom_code = p_sec_uom
             WHERE rowid = l_temp_record.rowid;

            EXIT;
          ELSIF ( round(l_item_quantity, g_precision) >= round(l_temp_record.primary_quantity, g_precision) ) THEN
            mdebug('Delete column from content table and decrement total unpack quantity', G_INFO);
            DELETE FROM wms_lpn_contents
            WHERE rowid = l_temp_record.rowid;

            l_item_quantity := l_item_quantity - l_temp_record.primary_quantity;
            EXIT WHEN l_item_quantity <= 0;
          END IF;
        ELSIF ( l_uom_priority IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
            mdebug('Not enough to unpack in trx uom='||l_uom_priority, G_ERROR);
          END IF;
          l_uom_priority := NULL;
          CLOSE existing_unpack_record_cursor;
          OPEN existing_unpack_record_cursor(l_serial_summary_entry, l_uom_priority);
        ELSIF ( l_item_quantity = l_primary_quantity ) THEN
          IF (l_debug = 1) THEN
            mdebug('Content item not found to unpack', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_ITEM_NOT_FOUND');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          IF (l_debug = 1) THEN
            mdebug('Not enough to upack, qty found='||l_item_quantity, G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_NOT_ENOUGH_TO_UNPACK');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP;
      CLOSE existing_unpack_record_cursor;

      -- Check to see if there are any items or child containers in soruce LPN
      IF ( NVL(p_auto_unnest_empty_lpns, 1) = 1 AND l_lpn_is_empty = 0 ) THEN
        BEGIN
          SELECT 0 INTO l_lpn_is_empty
          FROM   dual
          WHERE EXISTS (
            SELECT 1 FROM wms_lpn_contents
            WHERE  organization_id = p_organization_id
            AND    parent_lpn_id   = l_lpn.lpn_id )
            OR EXISTS (
            SELECT 1 FROM wms_license_plate_numbers
            WHERE  organization_id = p_organization_id
            AND    parent_lpn_id = l_lpn.lpn_id );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_lpn_is_empty := 1;
        END;
      END IF;

      -- If the source LPN is not empty then the update weight and volume of source LPN
      -- Otherwise this calculation is irrelevant since the lpn will become pregenerated
      IF ( l_lpn_is_empty <> 1 ) THEN
        l_progress := 'Unpack item: Need to update parent lpns weight and volume';
        l_wt_vol_new                 := l_lpn;
        l_change_in_gross_weight     := -1 * l_primary_quantity * inv_cache.item_rec.unit_weight;
        l_change_in_gross_weight_uom := inv_cache.item_rec.weight_uom_code;
        l_change_in_volume           := -1 * l_primary_quantity * inv_cache.item_rec.unit_volume;
        l_change_in_volume_uom       := inv_cache.item_rec.volume_uom_code;
      END IF;
    ELSIF (p_content_item_desc IS NOT NULL) THEN /*Unpacking a one time item*/
      OPEN one_time_item_cursor;
      FETCH one_time_item_cursor INTO l_one_time_item_rec;

      IF one_time_item_cursor%FOUND THEN
        IF ( l_quantity < l_one_time_item_rec.quantity ) THEN
          UPDATE wms_lpn_contents
             SET last_update_date = SYSDATE
               , last_updated_by  = fnd_global.user_id
               , request_id       = l_request_id
               , quantity         = (l_one_time_item_rec.quantity - l_quantity)
               , uom_code         = p_uom
           WHERE rowid = l_one_time_item_rec.rowid;
        ELSIF ( l_quantity = l_one_time_item_rec.quantity ) THEN
          DELETE FROM wms_lpn_contents
           WHERE rowid = l_one_time_item_rec.rowid;
        ELSE
          IF (l_debug = 1) THEN
             mdebug('Not enough of this onetime item to unpack', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_NOT_ENOUGH_TO_UNPACK');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
           mdebug('No one time items exits', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_NO_ONE_TIME_ITEM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  ELSIF ( l_operation_mode = L_UNPACK_ALL ) THEN /*** Unpack All Operation ***/
    -- This lpn will be empty, need to check parent lpns to see if they also will
    -- be empty. if so, they will need to be made defined but not used.
    l_lpn_is_empty := 1;
    l_tmp_bulk_lpns.lpn_id.delete;

    -- Update the information for the child containers
    FOR l_child_lpn IN nested_container_cursor LOOP
      IF (l_debug = 1) THEN
        mdebug('Unpacking all for child lpn='||l_child_lpn.lpn_id, G_INFO);
      END IF;

      l_tmp_i := NVL(l_lpn_tbl.last, 0) + 1;

      -- bug5404902 section for making tare via MSI
      IF ( l_child_lpn.inventory_item_id IS NOT NULL ) THEN
        SELECT unit_weight
             , weight_uom_code
          INTO l_lpn_tbl(l_tmp_i).tare_weight
             , l_lpn_tbl(l_tmp_i).tare_weight_uom_code
          FROM mtl_system_items
         WHERE organization_id = l_child_lpn.organization_id
           AND inventory_item_id = l_child_lpn.inventory_item_id;
      ELSE
      	-- if there isn't a container item, empty lpns will have undefined
      	-- tare weight
      	l_lpn_tbl(l_tmp_i).tare_weight          := fnd_api.g_miss_num;
        l_lpn_tbl(l_tmp_i).tare_weight_uom_code := fnd_api.g_miss_char;
      END IF;

      l_lpn_tbl(l_tmp_i).lpn_id                  := l_child_lpn.lpn_id;
      l_lpn_tbl(l_tmp_i).organization_id         := p_organization_id;
      l_lpn_tbl(l_tmp_i).subinventory_code       := fnd_api.g_miss_char;
      l_lpn_tbl(l_tmp_i).locator_id              := fnd_api.g_miss_num;
      l_lpn_tbl(l_tmp_i).parent_lpn_id           := fnd_api.g_miss_num;
      l_lpn_tbl(l_tmp_i).content_volume          := fnd_api.g_miss_num;
      l_lpn_tbl(l_tmp_i).content_volume_uom_code := fnd_api.g_miss_char;
      -- bug5404902 changed l_child_lpn to l_lpn_tbl(l_tmp_i) since it represents
      -- the container items original unit weight
      l_lpn_tbl(l_tmp_i).gross_weight            := NVL(l_lpn_tbl(l_tmp_i).tare_weight, fnd_api.g_miss_num);
      l_lpn_tbl(l_tmp_i).gross_weight_uom_code   := NVL(l_lpn_tbl(l_tmp_i).tare_weight_uom_code, fnd_api.g_miss_char);
      l_lpn_tbl(l_tmp_i).outermost_lpn_id        := l_child_lpn.lpn_id;
      l_lpn_tbl(l_tmp_i).lpn_context             := LPN_CONTEXT_PREGENERATED;

      l_progress := 'Add child LPN to bulk rec to delete contents';
      l_tmp_bulk_lpns.lpn_id(NVL(l_tmp_bulk_lpns.lpn_id.last, 0) + 1) := l_child_lpn.lpn_id;
    END LOOP;

    IF (l_debug = 1) THEN
      mdebug('Bulk Delete/Update LPNs in WLC/MSN: '||l_tmp_bulk_lpns.lpn_id.first||'-'||l_tmp_bulk_lpns.lpn_id.last, G_INFO);
    END IF;

    -- Remove the records for the packed items
    FORALL bulk_i IN l_tmp_bulk_lpns.lpn_id.first .. l_tmp_bulk_lpns.lpn_id.last
    DELETE FROM wms_lpn_contents
    WHERE  parent_lpn_id = l_tmp_bulk_lpns.lpn_id(bulk_i);

    IF (l_debug = 1) THEN
      mdebug('Bulk delete from WLC cnt='||SQL%ROWCOUNT, G_INFO);
    END IF;

    -- Update the information for serialized packed items
    FORALL bulk_i IN l_tmp_bulk_lpns.lpn_id.first .. l_tmp_bulk_lpns.lpn_id.last
    UPDATE mtl_serial_numbers
       SET last_update_date = SYSDATE
         , last_updated_by = fnd_global.user_id
         , lpn_id = NULL
     WHERE lpn_id = l_tmp_bulk_lpns.lpn_id(bulk_i);

    IF (l_debug = 1) THEN
      mdebug('Bulk update MSN cnt='||SQL%ROWCOUNT, G_INFO);
    END IF;
  END IF;

  IF ( l_lpn_is_empty = 1 ) THEN
  	-- bug5404902 added org and item
  	empty_lpn_rec.organization_id         := l_lpn.organization_id;
  	empty_lpn_rec.inventory_item_id       := l_lpn.inventory_item_id;
    empty_lpn_rec.lpn_id                  := l_lpn.lpn_id;
    empty_lpn_rec.parent_lpn_id           := l_lpn.parent_lpn_id;
    empty_lpn_rec.gross_weight            := l_lpn.gross_weight;
    empty_lpn_rec.gross_weight_uom_code   := l_lpn.gross_weight_uom_code;
    -- bug5404902 added
    empty_lpn_rec.tare_weight             := l_lpn.tare_weight;
    empty_lpn_rec.tare_weight_uom_code    := l_lpn.tare_weight_uom_code;
    empty_lpn_rec.container_volume        := l_lpn.container_volume;
    empty_lpn_rec.container_volume_uom    := l_lpn.container_volume_uom;
    empty_lpn_rec.content_volume          := l_lpn.content_volume;
    empty_lpn_rec.content_volume_uom_code := l_lpn.content_volume_uom_code;

    -- Since source lpn is being unnested, it may cause parent lpn to be empty and cause a chain reaction
    -- or parent LPNs to become pregenerated.  Loop through parents until an unempty one is found
    LOOP
      IF (l_debug = 1) THEN
        mdebug('lpn_id='||empty_lpn_rec.lpn_id||' is empty, making pregenerated plpnid='||empty_lpn_rec.parent_lpn_id||' empty='||l_lpn_is_empty, G_MESSAGE);
      END IF;

      l_tmp_i := NVL(l_lpn_tbl.last, 0) + 1;

      -- bug5404902 section for making tare via MSI
      IF ( empty_lpn_rec.inventory_item_id IS NOT NULL ) THEN
        SELECT unit_weight
             , weight_uom_code
          INTO l_lpn_tbl(l_tmp_i).tare_weight
             , l_lpn_tbl(l_tmp_i).tare_weight_uom_code
          FROM mtl_system_items
         WHERE organization_id = empty_lpn_rec.organization_id
           AND inventory_item_id = empty_lpn_rec.inventory_item_id;
      ELSE
      	-- if there isn't a container item, empty lpns will have undefined
      	-- tare weight
      	l_lpn_tbl(l_tmp_i).tare_weight          := fnd_api.g_miss_num;
        l_lpn_tbl(l_tmp_i).tare_weight_uom_code := fnd_api.g_miss_char;
      END IF;

      l_lpn_tbl(l_tmp_i).lpn_id                  := empty_lpn_rec.lpn_id;
      l_lpn_tbl(l_tmp_i).subinventory_code       := fnd_api.g_miss_char;
      l_lpn_tbl(l_tmp_i).locator_id              := fnd_api.g_miss_num;
      l_lpn_tbl(l_tmp_i).parent_lpn_id           := fnd_api.g_miss_num;
      l_lpn_tbl(l_tmp_i).content_volume          := fnd_api.g_miss_num;
      l_lpn_tbl(l_tmp_i).content_volume_uom_code := fnd_api.g_miss_char;
      -- bug5404902 changed empty_lpn_rec to l_lpn_tbl(l_tmp_i) since it represents
      -- the container items original unit weight
      l_lpn_tbl(l_tmp_i).gross_weight            := NVL(l_lpn_tbl(l_tmp_i).tare_weight, fnd_api.g_miss_num);
      l_lpn_tbl(l_tmp_i).gross_weight_uom_code   := NVL(l_lpn_tbl(l_tmp_i).tare_weight_uom_code, fnd_api.g_miss_char);
      l_lpn_tbl(l_tmp_i).outermost_lpn_id        := empty_lpn_rec.lpn_id;
      l_lpn_tbl(l_tmp_i).lpn_context             := LPN_CONTEXT_PREGENERATED;

      IF ( empty_lpn_rec.parent_lpn_id IS NOT NULL ) THEN
        BEGIN
          SELECT 0 INTO l_lpn_is_empty
          FROM   dual
          WHERE EXISTS (
            -- Check to make sure that the parent lpn has no items in it
            SELECT 1 FROM wms_lpn_contents
            WHERE  organization_id = p_organization_id
            AND    parent_lpn_id = empty_lpn_rec.parent_lpn_id )
          OR EXISTS (
            -- Check to make sure that the parent lpn has no lpns in it
            -- Ignore the child lpn that will become pregenerated later since
            -- we already know it will unpacked from the parent
            SELECT 1 FROM wms_license_plate_numbers
            WHERE  organization_id = p_organization_id
            AND    parent_lpn_id = empty_lpn_rec.parent_lpn_id
            AND    lpn_id <> empty_lpn_rec.lpn_id );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_lpn_is_empty := 1;
        END;

        -- If lpn has any weight in it, it needs to be decremented from the the parent lpn
        IF ( l_lpn_is_empty <> 1 ) THEN
          l_progress := 'UPDATE Wt and Vol when making to auto unnest empty LPNs';

          l_change_in_gross_weight     := -1 * empty_lpn_rec.gross_weight;
          l_change_in_gross_weight_uom := empty_lpn_rec.gross_weight_uom_code;
          -- bug5404902 added
          l_change_in_tare_weight      := -1 * empty_lpn_rec.tare_weight;
          l_change_in_tare_weight_uom  := empty_lpn_rec.tare_weight_uom_code;

          -- Need to find if the container of content volume is greater and decrement parent
          -- LPNs content volume by that amount
          Get_Greater_Qty (
            p_debug             => l_debug
          , p_inventory_item_id => empty_lpn_rec.inventory_item_id
          , p_quantity1         => empty_lpn_rec.container_volume
          , p_quantity1_uom     => empty_lpn_rec.container_volume_uom
          , p_quantity2         => empty_lpn_rec.content_volume
          , p_quantity2_uom     => empty_lpn_rec.content_volume_uom_code
          , x_greater_qty       => l_change_in_volume
          , x_greater_qty_uom   => l_change_in_volume_uom );

          -- Unpack need change value to negative
          l_change_in_volume := -1 * l_change_in_volume;

          IF ( nested_parent_cursor%ISOPEN ) THEN
            FETCH nested_parent_cursor INTO empty_lpn_rec;
            l_wt_vol_new.lpn_id                  := empty_lpn_rec.lpn_id;
            l_wt_vol_new.inventory_item_id       := empty_lpn_rec.inventory_item_id;
            l_wt_vol_new.gross_weight            := empty_lpn_rec.gross_weight;
            l_wt_vol_new.gross_weight_uom_code   := empty_lpn_rec.gross_weight_uom_code;
            l_wt_vol_new.tare_weight             := empty_lpn_rec.tare_weight;
            l_wt_vol_new.tare_weight_uom_code    := empty_lpn_rec.tare_weight_uom_code;
            l_wt_vol_new.content_volume          := empty_lpn_rec.content_volume;
            l_wt_vol_new.content_volume_uom_code := empty_lpn_rec.content_volume_uom_code;
          ELSE -- Need to get lpn_information of parent_lpn
            SELECT lpn_id
                 , inventory_item_id
                 , gross_weight
                 , gross_weight_uom_code
                 , tare_weight
                 , tare_weight_uom_code
                 , content_volume
                 , content_volume_uom_code
              INTO l_wt_vol_new.lpn_id
                 , l_wt_vol_new.inventory_item_id
                 , l_wt_vol_new.gross_weight
                 , l_wt_vol_new.gross_weight_uom_code
                 , l_wt_vol_new.tare_weight
                 , l_wt_vol_new.tare_weight_uom_code
                 , l_wt_vol_new.content_volume
                 , l_wt_vol_new.content_volume_uom_code
              FROM wms_license_plate_numbers
             WHERE lpn_id = empty_lpn_rec.parent_lpn_id;
          END IF;
        END IF;
      END IF;

      -- If parent lpn is not empty or doesn't exist, We are at the end.
      IF ( empty_lpn_rec.parent_lpn_id IS NULL OR l_lpn_is_empty = 0 ) THEN
        EXIT;
      ELSIF ( NOT nested_parent_cursor%ISOPEN ) THEN
        OPEN nested_parent_cursor(l_lpn.parent_lpn_id);
      END IF;

      FETCH nested_parent_cursor INTO empty_lpn_rec;
      EXIT WHEN nested_parent_cursor%NOTFOUND;
    END LOOP;

    IF ( nested_parent_cursor%ISOPEN ) THEN
      CLOSE nested_parent_cursor;
    END IF;
  END IF;

  IF (l_debug = 1) THEN
    mdebug('lpn_id='||l_wt_vol_new.lpn_id||' change_gwt='||l_change_in_gross_weight||' change_gwt_uom='||l_change_in_gross_weight_uom||
           ' change_twt='||l_change_in_tare_weight||' change_twt_uom='||l_change_in_tare_weight_uom||' change_vol='||l_change_in_volume||' change_vol_uom='||l_change_in_volume_uom, G_INFO);
  END IF;

  -- If a item or LPN was packed or unpacked from the parent_lpn (p_lpn).  And it
  -- had a weight of volume.  need to recalculate the weight and volume of the
  -- parent LPN
  -- bug5404902 add section for tare weight
  IF ( (NVL(l_change_in_gross_weight, 0) <> 0 AND l_change_in_gross_weight_uom IS NOT NULL)OR
  	   (NVL(l_change_in_tare_weight, 0) <> 0 AND l_change_in_tare_weight_uom IS NOT NULL)OR
       (NVL(l_change_in_volume, 0) <> 0 AND l_change_in_volume_uom IS NOT NULL) )
  THEN
    l_progress := 'calculate any change in weight and volume';

    IF ( NVL(l_change_in_gross_weight, 0) = 0 OR l_change_in_gross_weight_uom IS NULL ) THEN
      -- Item/LPN weight not defined, no change in LPN weight
      l_wt_vol_new.gross_weight          := NULL;
      l_wt_vol_new.gross_weight_uom_code := NULL;
    ELSIF ( NVL(l_wt_vol_new.gross_weight, 0) = 0 OR l_wt_vol_new.gross_weight_uom_code IS NULL ) THEN
      -- LPN has no gross weight, if packing assign total item/LPN weight to gross
      -- if unpacking, no change, since weight cannot go negative
      IF ( l_change_in_gross_weight > 0 ) THEN
        l_wt_vol_new.gross_weight          := l_change_in_gross_weight;
        l_wt_vol_new.gross_weight_uom_code := l_change_in_gross_weight_uom;
      END IF;
    ELSIF ( l_wt_vol_new.gross_weight_uom_code = l_change_in_gross_weight_uom ) THEN
      -- Same uom, can simply add the two values
      l_wt_vol_new.gross_weight := l_wt_vol_new.gross_weight + l_change_in_gross_weight;
    ELSE
      -- Both are not null but with different UOMs need to convert
      -- If cannot covert uom, ignore the change in volume
      IF ( inv_cache.item_rec.weight_uom_code IS NOT NULL) THEN
       IF (l_change_in_gross_weight_uom <> inv_cache.item_rec.weight_uom_code) THEN  --8447369 added condition
          l_change_in_gross_weight := Convert_UOM(
                                    p_inventory_item_id => l_lpn.inventory_item_id
                                  , p_fm_quantity       => l_change_in_gross_weight
                                  , p_fm_uom            => l_change_in_gross_weight_uom
                                  , p_to_uom            => inv_cache.item_rec.weight_uom_code
                                  , p_mode              => G_NO_CONV_RETURN_ZERO );
       END IF;

       IF (l_wt_vol_new.gross_weight_uom_code <> inv_cache.item_rec.weight_uom_code ) THEN --8447369 added condition
          l_wt_vol_new.gross_weight := Convert_UOM(
                                    p_inventory_item_id => l_lpn.inventory_item_id
                                  , p_fm_quantity       => l_wt_vol_new.gross_weight
                                  , p_fm_uom            => l_wt_vol_new.gross_weight_uom_code
                                  , p_to_uom            => inv_cache.item_rec.weight_uom_code
                                  , p_mode              => G_NO_CONV_RETURN_ZERO );
       l_wt_vol_new.gross_weight_uom_code := inv_cache.item_rec.weight_uom_code ;
       END IF;
      ELSE
       l_change_in_gross_weight := Convert_UOM(
                                    p_inventory_item_id => l_lpn.inventory_item_id
                                  , p_fm_quantity       => l_change_in_gross_weight
                                  , p_fm_uom            => l_change_in_gross_weight_uom
                                  , p_to_uom            => l_wt_vol_new.gross_weight_uom_code
                                  , p_mode              => G_NO_CONV_RETURN_ZERO );

      END IF;

      l_wt_vol_new.gross_weight := l_wt_vol_new.gross_weight + l_change_in_gross_weight;
    END IF;

    IF ( l_wt_vol_new.gross_weight < 0 ) THEN
      l_wt_vol_new.gross_weight := 0;
    END IF;

    -- bug5404902 added section for tare weight
    l_progress := 'Calculate changes in tare weight';

    IF ( NVL(l_change_in_tare_weight, 0) = 0 OR l_change_in_tare_weight_uom IS NULL ) THEN
      -- Child LPN tare weight not defined, no change in tare weight
       mdebug('l_wt_vol_new.tare_weight_uom_code'|| l_wt_vol_new.tare_weight_uom_code, G_INFO);
       -- 8447369 Added If condition
       IF (inv_cache.item_rec.weight_uom_code IS NOT NULL AND NVL(l_wt_vol_new.tare_weight, 0) <> 0 AND l_wt_vol_new.tare_weight_uom_code <> inv_cache.item_rec.weight_uom_code) THEN
         l_wt_vol_new.tare_weight := Convert_UOM(
                                    p_inventory_item_id => l_lpn.inventory_item_id
                                  , p_fm_quantity       => l_wt_vol_new.tare_weight
                                  , p_fm_uom            => l_wt_vol_new.tare_weight_uom_code
                                  , p_to_uom            => inv_cache.item_rec.weight_uom_code
                                  , p_mode              => G_NO_CONV_RETURN_ZERO );

         l_wt_vol_new.tare_weight_uom_code := inv_cache.item_rec.weight_uom_code;
       ELSE
        l_wt_vol_new.tare_weight          := NULL;
        l_wt_vol_new.tare_weight_uom_code := NULL;
       END IF;
    ELSIF ( NVL(l_wt_vol_new.tare_weight, 0) = 0 OR l_wt_vol_new.tare_weight_uom_code IS NULL ) THEN
      -- LPN has no tare weight, if packing assign total child LPN tare weight to parent LPN tare
      -- if unpacking, no change, since weight cannot go negative
      IF ( l_change_in_tare_weight > 0 ) THEN
        l_wt_vol_new.tare_weight          := l_change_in_tare_weight;
        l_wt_vol_new.tare_weight_uom_code := l_change_in_tare_weight_uom;
      END IF;
    ELSIF ( l_wt_vol_new.tare_weight_uom_code = l_change_in_tare_weight_uom ) THEN
      -- Same uom, can simply add the two values
      l_wt_vol_new.tare_weight := l_wt_vol_new.tare_weight + l_change_in_tare_weight;
    ELSE
      -- Both are not null but with different UOMs need to convert
      -- If cannot covert uom, ignore the change in volume
      l_change_in_tare_weight := Convert_UOM(
                                   p_inventory_item_id => l_lpn.inventory_item_id
                                 , p_fm_quantity       => l_change_in_tare_weight
                                 , p_fm_uom            => l_change_in_tare_weight_uom
                                 , p_to_uom            => l_wt_vol_new.tare_weight_uom_code
                                 , p_mode              => G_NO_CONV_RETURN_ZERO );

      l_wt_vol_new.tare_weight := l_wt_vol_new.tare_weight + l_change_in_tare_weight;
    END IF;

    IF ( l_wt_vol_new.tare_weight < 0 ) THEN
      l_wt_vol_new.tare_weight := 0;
    END IF;

    l_progress := 'Calculate changes in volume';

    IF ( NVL(l_change_in_volume, 0) = 0 OR l_change_in_volume_uom IS NULL ) THEN
      -- Item/LPN volume not defined, no change in LPN volume
      l_wt_vol_new.content_volume          := NULL;
      l_wt_vol_new.content_volume_uom_code := NULL;
    ELSIF ( NVL(l_wt_vol_new.content_volume, 0) = 0 OR l_wt_vol_new.content_volume_uom_code IS NULL ) THEN
      -- LPN has no content volume, if packing assign total item/LPN volume to gross
      -- if unpacking, no change, since volume cannot go negative
      IF ( l_change_in_volume > 0 ) THEN
        l_wt_vol_new.content_volume          := l_change_in_volume;
        l_wt_vol_new.content_volume_uom_code := l_change_in_volume_uom;
      END IF;
    ELSIF ( l_wt_vol_new.content_volume_uom_code = l_change_in_volume_uom ) THEN
      -- Same uom, can simply add the two values
      l_wt_vol_new.content_volume := l_wt_vol_new.content_volume + l_change_in_volume;
    ELSE
      -- Both are not null but with different UOMs need to convert
      -- If cannot covert uom, ignore the change in volume
      l_change_in_volume := Convert_UOM(
                              p_inventory_item_id => l_lpn.inventory_item_id
                            , p_fm_quantity       => l_change_in_volume
                            , p_fm_uom            => l_change_in_volume_uom
                            , p_to_uom            => l_wt_vol_new.content_volume_uom_code
                            , p_mode              => G_NO_CONV_RETURN_ZERO );

      l_wt_vol_new.content_volume := l_wt_vol_new.content_volume + l_change_in_volume;
      l_change_in_volume_uom      := l_wt_vol_new.content_volume_uom_code;
    END IF;

    IF ( l_new.content_volume < 0 ) THEN
      l_wt_vol_new.content_volume := 0;
    END IF;

    -- bug5404902 added tare weight
    IF ( l_new.lpn_id = l_wt_vol_new.lpn_id ) THEN
      l_new.gross_weight            := l_wt_vol_new.gross_weight;
      l_new.gross_weight_uom_code   := l_wt_vol_new.gross_weight_uom_code;
      l_new.tare_weight             := l_wt_vol_new.tare_weight;
      l_new.tare_weight_uom_code    := l_wt_vol_new.tare_weight_uom_code;
      l_new.content_volume          := l_wt_vol_new.content_volume;
      l_new.content_volume_uom_code := l_wt_vol_new.content_volume_uom_code;
    ELSE -- Not the immediate parent, create a new record
      l_tmp_i := NVL(l_lpn_tbl.last, 0) + 1;
      l_lpn_tbl(l_tmp_i).lpn_id                  := l_wt_vol_new.lpn_id;
      l_lpn_tbl(l_tmp_i).gross_weight            := l_wt_vol_new.gross_weight;
      l_lpn_tbl(l_tmp_i).gross_weight_uom_code   := l_wt_vol_new.gross_weight_uom_code;
      l_lpn_tbl(l_tmp_i).tare_weight             := l_wt_vol_new.tare_weight;
      l_lpn_tbl(l_tmp_i).tare_weight_uom_code    := l_wt_vol_new.tare_weight_uom_code;
      l_lpn_tbl(l_tmp_i).content_volume          := l_wt_vol_new.content_volume;
      l_lpn_tbl(l_tmp_i).content_volume_uom_code := l_wt_vol_new.content_volume_uom_code;
    END IF;
  END IF;

  -- IF both LPNs are picked and doing an unpack, need to update nested LPN structure in WDD
  IF ( p_lpn_id IS NOT NULL AND p_content_lpn_id IS NOT NULL AND l_operation_mode = L_UNPACK AND
       l_lpn.lpn_context = LPN_CONTEXT_PICKED AND l_content_lpn.lpn_context = LPN_CONTEXT_PICKED )
  THEN
    IF (l_debug = 1) THEN
      mdebug('Call to WSH Delivery_Detail_Action to unpack LPN heirarchy', G_INFO);
    END IF;

    l_wsh_action_prms.caller                  := 'WMS';
    l_wsh_action_prms.action_code             := 'UNPACK';
    l_wsh_action_prms.lpn_rec.organization_id := l_lpn.organization_id;
    l_wsh_action_prms.lpn_rec.lpn_id          := l_lpn.lpn_id;
    l_wsh_action_prms.lpn_rec.container_name  := l_lpn.license_plate_number;
    l_wsh_lpn_id_tbl(1)                       := p_content_lpn_id;

    WSH_WMS_LPN_GRP.Delivery_Detail_Action (
      p_api_version_number => 1.0
    , p_init_msg_list      => fnd_api.g_false
    , p_commit             => fnd_api.g_false
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_lpn_id_tbl         => l_wsh_lpn_id_tbl
    , p_del_det_id_tbl     => l_wsh_del_det_id_tbl
    , p_action_prms        => l_wsh_action_prms
    , x_defaults           => l_wsh_defaults
    , x_action_out_rec     => l_wsh_action_out_rec );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      l_progress := 'Delivery_Detail_Action failed';
      RAISE fnd_api.g_exc_error;
    ELSIF (l_debug = 1) THEN
      mdebug('Done with call to WSH Create_Update_Containers', G_INFO);
    END IF;
  END IF;

  -- If there were any changes made to the parent LPN, add this to the lpn table
  -- to have WLPN be updated by modify_lpns
  IF ( l_new.lpn_id IS NOT NULL ) THEN
    l_lpn_tbl(NVL(l_lpn_tbl.last, 0) + 1) := l_new;
  END IF;

  -- If there were any changes made to the content LPN, add this to the lpn table
  -- to have WLPN be updated by modify_lpns
  IF ( l_cont_new.lpn_id IS NOT NULL ) THEN
    l_lpn_tbl(NVL(l_lpn_tbl.last, 0) + 1) := l_cont_new;
  END IF;

  -- Call Modify_LPNs API to update WLPN
  IF ( l_lpn_tbl.last > 0 ) THEN
    IF (l_debug = 1) THEN
      mdebug('Call to Modify_LPNs first='||l_lpn_tbl.first||' last='||l_lpn_tbl.last, G_INFO);
    END IF;

    Modify_LPNs (
      p_api_version   => 1.0
    , p_init_msg_list => fnd_api.g_false
    , p_commit        => fnd_api.g_false
    , x_return_status => x_return_status
    , x_msg_count     => x_msg_count
    , x_msg_data      => x_msg_data
    , p_caller        => 'WMS_PackUnpack_Container'
    , p_lpn_table     => l_lpn_tbl );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      l_progress := 'Modify_LPNs failed';
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  -- IF both LPNs are picked then need to update nested LPN structure
  IF ( p_lpn_id IS NOT NULL AND p_content_lpn_id IS NOT NULL AND l_operation_mode = L_PACK AND
       NVL(l_new.lpn_context, l_lpn.lpn_context) = LPN_CONTEXT_PICKED AND
       NVL(l_cont_new.lpn_context, l_content_lpn.lpn_context) = LPN_CONTEXT_PICKED )
  THEN
    IF (l_debug = 1) THEN
      mdebug('Call to WSH Delivery_Detail_Action to pack LPN heirarchy', G_INFO);
    END IF;

    l_wsh_action_prms.caller                  := 'WMS';
    l_wsh_action_prms.action_code             := 'PACK';
    l_wsh_action_prms.lpn_rec.organization_id := l_lpn.organization_id;
    l_wsh_action_prms.lpn_rec.lpn_id          := l_lpn.lpn_id;
    l_wsh_action_prms.lpn_rec.container_name  := l_lpn.license_plate_number;
    l_wsh_lpn_id_tbl(1)                       := p_content_lpn_id;

    WSH_WMS_LPN_GRP.Delivery_Detail_Action (
      p_api_version_number => 1.0
    , p_init_msg_list      => fnd_api.g_false
    , p_commit             => fnd_api.g_false
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_lpn_id_tbl         => l_wsh_lpn_id_tbl
    , p_del_det_id_tbl     => l_wsh_del_det_id_tbl
    , p_action_prms        => l_wsh_action_prms
    , x_defaults           => l_wsh_defaults
    , x_action_out_rec     => l_wsh_action_out_rec );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      l_progress := 'Delivery_Detail_Action failed';
      RAISE fnd_api.g_exc_error;
    ELSIF (l_debug = 1) THEN
      mdebug('Done with call to WSH Create_Update_Containers', G_INFO);
    END IF;
  END IF;

  l_progress := 'Inserting record into WLH';
  INSERT INTO wms_lpn_histories (
    lpn_history_id
  , caller
  , source_transaction_id
  , parent_lpn_id
  , parent_license_plate_number
  , lpn_id
  , license_plate_number
  , inventory_item_id
  , item_description
  , revision
  , lot_number
  , serial_number
  , to_serial_number
  , quantity
  , uom_code
  , organization_id
  , subinventory_code
  , locator_id
  , lpn_context
  , status_id
  , sealed_status
  , operation_mode
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , cost_group_id
  , outermost_lpn_id
  , source_type_id
  , source_header_id
  , source_line_id
  , source_line_detail_id
  , source_name
  , secondary_quantity
  , secondary_uom_code
  )
  VALUES (
    WMS_LPN_HISTORIES_S.NEXTVAL
  , p_caller
  , p_source_transaction_id
  , p_lpn_id
  , l_lpn.license_plate_number
  , p_content_lpn_id
  , l_content_lpn.license_plate_number
  , p_content_item_id
  , p_content_item_desc
  , p_revision
  , p_lot_number
  , p_from_serial_number
  , p_to_serial_number
  , l_quantity
  , p_uom
  , p_organization_id
  , p_subinventory
  , p_locator_id
  , NVL(l_new.lpn_context, l_lpn.lpn_context)
  , l_lpn.status_id
  , l_lpn.sealed_status
  , l_operation_mode
  , SYSDATE
  , fnd_global.user_id
  , SYSDATE
  , fnd_global.user_id
  , p_cost_group_id
  , DECODE(l_new.outermost_lpn_id, fnd_api.g_miss_num, NULL, NVL(l_new.outermost_lpn_id, l_lpn.outermost_lpn_id))
  , NVL(p_source_type_id, l_lpn.source_type_id)
  , NVL(p_source_header_id, l_lpn.source_header_id)
  , NVL(p_source_line_id, l_lpn.source_line_id)
  , NVL(p_source_line_detail_id, l_lpn.source_line_detail_id)
  , NVL(p_source_name, l_lpn.source_name)
  , p_sec_quantity --INVCONV kkillams
  , p_sec_uom      --INVCONV kkillams
  );

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  IF ( l_debug = 1 ) THEN
    mdebug(l_api_name||' Exited', 1);
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PACKUNPACK_CONTAINER;
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Exc err prog='||l_progress||' SQL err: '|| SQLERRM(SQLCODE), 1);
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug('msg: '||l_msgdata, 1);
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO PACKUNPACK_CONTAINER;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Unexp err prog='||l_progress||' SQL err: '|| SQLERRM(SQLCODE), 1);
    END IF;
END PackUnpack_Container;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Modify_LPN (
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_lpn                   IN         WMS_CONTAINER_PUB.LPN
, p_caller                IN         VARCHAR2 := NULL
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Modify_LPN';
l_api_version CONSTANT NUMBER       := 1.0;

l_lpn_table WMS_Data_Type_Definitions_PUB.LPNTableType;

BEGIN

  l_lpn_table(1).lpn_id                  := p_lpn.lpn_id;
  l_lpn_table(1).license_plate_number    := p_lpn.license_plate_number;
  l_lpn_table(1).parent_lpn_id           := p_lpn.parent_lpn_id;
  l_lpn_table(1).outermost_lpn_id        := p_lpn.outermost_lpn_id;
  l_lpn_table(1).lpn_context             := p_lpn.lpn_context;

  l_lpn_table(1).organization_id         := p_lpn.organization_id;
  l_lpn_table(1).subinventory_code       := p_lpn.subinventory_code;
  l_lpn_table(1).locator_id              := p_lpn.locator_id;

  l_lpn_table(1).inventory_item_id       := p_lpn.inventory_item_id;
  l_lpn_table(1).revision                := p_lpn.revision;
  l_lpn_table(1).lot_number              := p_lpn.lot_number;
  l_lpn_table(1).serial_number           := p_lpn.serial_number;
  l_lpn_table(1).cost_group_id           := p_lpn.cost_group_id;

  l_lpn_table(1).tare_weight_uom_code    := p_lpn.tare_weight_uom_code;
  l_lpn_table(1).tare_weight             := p_lpn.tare_weight;
  l_lpn_table(1).gross_weight_uom_code   := p_lpn.gross_weight_uom_code;
  l_lpn_table(1).gross_weight            := p_lpn.gross_weight;
  l_lpn_table(1).container_volume_uom    := p_lpn.container_volume_uom;
  l_lpn_table(1).container_volume        := p_lpn.container_volume;
  l_lpn_table(1).content_volume_uom_code := p_lpn.content_volume_uom_code;
  l_lpn_table(1).content_volume          := p_lpn.content_volume;

  l_lpn_table(1).source_type_id          := p_lpn.source_type_id;
  l_lpn_table(1).source_header_id        := p_lpn.source_header_id;
  l_lpn_table(1).source_line_id          := p_lpn.source_line_id;
  l_lpn_table(1).source_line_detail_id   := p_lpn.source_line_detail_id;
  l_lpn_table(1).source_name             := p_lpn.source_name;

  l_lpn_table(1).attribute_category      := p_lpn.attribute_category;
  l_lpn_table(1).attribute1              := p_lpn.attribute1;
  l_lpn_table(1).attribute2              := p_lpn.attribute2;
  l_lpn_table(1).attribute3              := p_lpn.attribute3;
  l_lpn_table(1).attribute4              := p_lpn.attribute4;
  l_lpn_table(1).attribute5              := p_lpn.attribute5;
  l_lpn_table(1).attribute6              := p_lpn.attribute6;
  l_lpn_table(1).attribute7              := p_lpn.attribute7;
  l_lpn_table(1).attribute8              := p_lpn.attribute8;
  l_lpn_table(1).attribute9              := p_lpn.attribute9;
  l_lpn_table(1).attribute10             := p_lpn.attribute10;
  l_lpn_table(1).attribute11             := p_lpn.attribute11;
  l_lpn_table(1).attribute12             := p_lpn.attribute12;
  l_lpn_table(1).attribute13             := p_lpn.attribute13;
  l_lpn_table(1).attribute14             := p_lpn.attribute14;
  l_lpn_table(1).attribute15             := p_lpn.attribute15;

  Modify_LPNs (
    p_api_version   => p_api_version
  , p_init_msg_list => p_init_msg_list
  , p_commit        => p_commit
  , x_return_status => x_return_status
  , x_msg_count     => x_msg_count
  , x_msg_data      => x_msg_data
  , p_caller        => p_caller
  , p_lpn_table     => l_lpn_table );

END Modify_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Modify_LPN_Wrapper(
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_lpn_id                IN         NUMBER
, p_license_plate_number  IN         VARCHAR2 := NULL
, p_inventory_item_id     IN         NUMBER   := NULL
, p_weight_uom_code       IN         VARCHAR2 := NULL
, p_gross_weight          IN         NUMBER   := NULL
, p_volume_uom_code       IN         VARCHAR2 := NULL
, p_content_volume        IN         NUMBER   := NULL
, p_status_id             IN         NUMBER   := NULL
, p_lpn_context           IN         NUMBER   := NULL
, p_sealed_status         IN         NUMBER   := NULL
, p_organization_id       IN         NUMBER   := NULL
, p_subinventory          IN         VARCHAR  := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
, p_caller                IN         VARCHAR2 := NULL
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Modify_LPN_Wrapper';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';
l_msgdata              VARCHAR2(1000);

l_lpn                  WMS_Data_Type_Definitions_PUB.LPNTableType;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT MODIFY_LPN_WRAPPER_PVT;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  IF (l_debug = 1) THEN
    mdebug(l_api_name|| ' Entered '|| g_pkg_version, 1);
  END IF;

  l_lpn(1).lpn_id                  := p_lpn_id;
  l_lpn(1).license_plate_number    := p_license_plate_number;
  l_lpn(1).inventory_item_id       := p_inventory_item_id;
  l_lpn(1).gross_weight_uom_code   := p_weight_uom_code;
  l_lpn(1).gross_weight            := p_gross_weight;
  l_lpn(1).content_volume_uom_code := p_volume_uom_code;
  l_lpn(1).content_volume          := p_content_volume;
  --l_lpn(1).status_id               := p_status_id;
  l_lpn(1).lpn_context             := p_lpn_context;
  --l_lpn(1).sealed_status           := p_sealed_status;
  l_lpn(1).organization_id         := p_organization_id;
  l_lpn(1).subinventory_code       := p_subinventory;
  l_lpn(1).locator_id              := p_locator_id;
  l_lpn(1).source_type_id          := p_source_type_id;
  l_lpn(1).source_header_id        := p_source_header_id;
  l_lpn(1).source_line_id          := p_source_line_id;
  l_lpn(1).source_line_detail_id   := p_source_line_detail_id;
  l_lpn(1).source_name             := p_source_name;

  l_progress := '100';
  Modify_LPNs (
    p_api_version   => p_api_version
  , p_init_msg_list => p_init_msg_list
  , p_commit        => p_commit
  , x_return_status => x_return_status
  , x_msg_count     => x_msg_count
  , x_msg_data      => x_msg_data
  , p_caller        => p_caller
  , p_lpn_table     => l_lpn );

  l_progress := '200';
  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
    -- Modify LPN should put the appropriate error message in the stack
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO MODIFY_LPN_WRAPPER_PVT;
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO MODIFY_LPN_WRAPPER_PVT;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress= '||l_progress||'SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;
END Modify_LPN_Wrapper;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Validate_Update_Wt_Volume (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_lpn_id                 IN         NUMBER
, p_content_lpn_id         IN         VARCHAR2 := NULL
, p_content_item_id        IN         NUMBER   := NULL
, p_quantity               IN         NUMBER   := NULL
, p_uom                    IN         VARCHAR2 := NULL
, p_organization_id        IN         NUMBER   := NULL
, p_enforce_wv_constraints IN         NUMBER   := 2
, p_operation              IN         NUMBER
, p_action                 IN         NUMBER
, x_valid_operation        OUT NOCOPY NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Update_Wt_Volume';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

END Validate_Update_Wt_Volume;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Container_Required_Qty(
  p_api_version       IN            NUMBER
, p_init_msg_list     IN            VARCHAR2 := fnd_api.g_false
, p_commit            IN            VARCHAR2 := fnd_api.g_false
, x_return_status     OUT    NOCOPY VARCHAR2
, x_msg_count         OUT    NOCOPY NUMBER
, x_msg_data          OUT    NOCOPY VARCHAR2
, p_source_item_id    IN            NUMBER
, p_source_qty        IN            NUMBER
, p_source_qty_uom    IN            VARCHAR2
, p_qty_per_cont      IN            NUMBER   := NULL
, p_qty_per_cont_uom  IN            VARCHAR2 := NULL
, p_organization_id   IN            NUMBER
, p_dest_cont_item_id IN OUT NOCOPY NUMBER
, p_qty_required      OUT    NOCOPY NUMBER
) IS
l_api_name           CONSTANT VARCHAR2(30)     := 'Container_Required_Qty';
l_api_version           CONSTANT NUMBER      := 1.0;
l_source_item            INV_Validate.ITEM;
l_dest_cont_item         INV_Validate.ITEM;
l_cont_item              INV_Validate.ITEM;
l_org                    INV_Validate.ORG;
l_result                 NUMBER;
l_max_load_quantity      NUMBER;
l_qty_per_cont           NUMBER;
l_curr_min_container     NUMBER;
l_curr_min_value         NUMBER;
l_curr_load_quantity     NUMBER;
l_temp_min_value         NUMBER;
l_temp_value             NUMBER;
l_temp_load_quantity     NUMBER;
CURSOR max_load_cursor IS
   SELECT max_load_quantity
   FROM WSH_CONTAINER_ITEMS
   WHERE master_organization_id = p_organization_id
   AND container_item_id = p_dest_cont_item_id
   AND load_item_id = p_source_item_id;

CURSOR container_items_cursor IS
   SELECT container_item_id, max_load_quantity, preferred_flag
   FROM WSH_CONTAINER_ITEMS
   WHERE master_organization_id = p_organization_id
   AND load_item_id = p_source_item_id
   AND container_item_id IN
   (SELECT inventory_item_id
    FROM MTL_SYSTEM_ITEMS
    WHERE mtl_transactions_enabled_flag = 'Y'
    AND container_item_flag = 'Y'
    AND organization_id = p_organization_id);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   CONTAINER_REQUIRED_QTY_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
               p_api_version  ,
               l_api_name      ,
               G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body

   /* Validate Organization ID */
   l_org.organization_id := p_organization_id;
   l_result := INV_Validate.Organization(l_org);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_ORG');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Source item */
   l_source_item.inventory_item_id := p_source_item_id;
   l_result := INV_Validate.inventory_item(l_source_item, l_org);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_ITEM');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Source Quantity */
   IF ((p_source_qty IS NULL) OR (p_source_qty <= 0)) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SRC_QTY');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Source UOM */
   l_result := INV_Validate.Uom(p_source_qty_uom, l_org, l_source_item);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SRC_UOM');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Quantity Per Container */
   IF (p_qty_per_cont IS NOT NULL) THEN
      IF (p_qty_per_cont <= 0) THEN
    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVLD_QTY_PER_CONT');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   /* Validate Quantity Per Container UOM */
   IF (p_qty_per_cont IS NOT NULL) THEN
      l_result := INV_Validate.Uom(p_qty_per_cont_uom, l_org, l_source_item);
      IF (l_result = INV_Validate.F) THEN
    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVLD_QTY_PER_UOM');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   /* Validate Destination container item */
   IF (p_dest_cont_item_id IS NOT NULL) THEN
      l_dest_cont_item.inventory_item_id := p_dest_cont_item_id;
      l_result := INV_Validate.inventory_item(l_dest_cont_item, l_org);
      IF (l_result = INV_Validate.F) THEN
    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONT_ITEM');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_dest_cont_item.container_item_flag = 'N') THEN
    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_ITEM_NOT_A_CONT');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   /* End of input validation */

   IF (p_dest_cont_item_id IS NOT NULL) THEN
      /* Extract or calculate the value of l_max_load_quantity */
      OPEN max_load_cursor;
      FETCH max_load_cursor INTO l_max_load_quantity;
      IF max_load_cursor%NOTFOUND THEN
      /* Need to calculate this value based on weight and volume constraints */
      -- Check that the source item contains all the physical item information
      -- needed for calculation of l_max_load_quantity
      IF ((l_source_item.unit_weight IS NULL) OR
          (l_source_item.weight_uom_code IS NULL) OR
          (l_source_item.unit_volume IS NULL) OR
          (l_source_item.volume_uom_code IS NULL)) THEN
         FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NOT_ENOUGH_INFO');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* Volume constraint */
      l_temp_value := Convert_UOM(
                        l_source_item.inventory_item_id
            , l_source_item.unit_volume
            , l_source_item.volume_uom_code
            , l_dest_cont_item.volume_uom_code);

      IF (l_dest_cont_item.internal_volume IS NOT NULL) THEN
         -- Check that the source item's unit volume is less than or
         -- equal to the destination container item's internal volume
         IF (l_temp_value <= l_dest_cont_item.internal_volume) THEN
            l_max_load_quantity := FLOOR(l_dest_cont_item.internal_volume/l_temp_value);
         ELSE
            FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_ITEM_TOO_LARGE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      /* Weight constraint */
      l_temp_value := Convert_UOM(
                        l_source_item.inventory_item_id
            , l_source_item.unit_weight
            , l_source_item.weight_uom_code
            , l_dest_cont_item.weight_uom_code);

      /* Select the most constraining value for l_max_load_quantity */
      IF (l_dest_cont_item.maximum_load_weight IS NOT NULL) THEN
         -- Check that the source item's unit weight is less than or
         -- equal to the destination container item's maximum load weight
         IF (l_temp_value <= l_dest_cont_item.maximum_load_weight) THEN
            IF (l_max_load_quantity > FLOOR (l_dest_cont_item.maximum_load_weight /
                       l_temp_value)) THEN
               l_max_load_quantity := FLOOR (l_dest_cont_item.maximum_load_weight /
                       l_temp_value);
            END IF;
         ELSE
            FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_ITEM_TOO_LARGE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;
   CLOSE max_load_cursor;

   /* Convert l_max_load_quantity into the same UOM as p_source_qty_uom */
   IF (l_max_load_quantity IS NOT NULL) THEN
      l_max_load_quantity := Convert_UOM(
                                l_source_item.inventory_item_id
                    , l_max_load_quantity
                    , l_source_item.primary_uom_code
                    , p_source_qty_uom);
   END IF;

   /* Calculate the required number of containers needed to store the items */
   IF ((p_qty_per_cont IS NOT NULL) AND (l_max_load_quantity IS NOT NULL)) THEN
      l_qty_per_cont := Convert_UOM(
                          l_source_item.inventory_item_id
              , p_qty_per_cont
              , p_qty_per_cont_uom
              , p_source_qty_uom);

      IF (l_qty_per_cont > l_max_load_quantity) THEN
         FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_OVERPACKED_OPERATION');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         p_qty_required := CEIL(p_source_qty/l_qty_per_cont);
      END IF;
   ELSIF ((p_qty_per_cont IS NULL) AND (l_max_load_quantity IS NOT NULL)) THEN
         p_qty_required := CEIL(p_source_qty/l_max_load_quantity);
   ELSE
      -- If the destination container item contains no internal volume or maximum
      -- load weight restriction values, assume that it has infinite capacity
        FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NO_RESTRICTIONS_FND');
      -- FND_MESSAGE.SHOW;
      p_qty_required := 1;
   END IF;

   ELSE /* No container item was given */
      l_curr_min_container := 0;
      -- Search through all the containers in WSH_CONTAINER_ITEMS table which can store
      -- the given load_item_id
      FOR v_container_item IN container_items_cursor LOOP
         /* Get the item information for the current container item being considered */
         l_cont_item.inventory_item_id := v_container_item.container_item_id;
         l_result := INV_Validate.inventory_item(l_cont_item, l_org);
         IF (l_result = INV_Validate.F) THEN
            FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONT_ITEM');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         /* Get the max load quantity for that given container */
         l_temp_load_quantity := Convert_UOM (
                                   l_source_item.inventory_item_id
                                 , v_container_item.max_load_quantity
                                 , l_source_item.primary_uom_code
                                 , p_source_qty_uom);

         -- Calculate the min value, i.e. how much space is empty in the final container
         -- used to store the items in units of the source item's uom
         l_temp_min_value := l_temp_load_quantity - MOD(p_source_qty, l_temp_load_quantity);

         -- If ther preferred container flag is set for this container load relationship
         -- Use it reguardless of it's min value
         IF ( v_container_item.preferred_flag = 'Y' ) THEN
            l_curr_min_container := v_container_item.container_item_id;
            l_curr_load_quantity := l_temp_load_quantity;
            EXIT;
         -- Compare the min value for this container with the best one found so far
         ELSIF ((l_curr_min_container = 0) OR (l_temp_min_value < l_curr_min_value)) THEN
            l_curr_min_value := l_temp_min_value;
            l_curr_min_container := v_container_item.container_item_id;
            l_curr_load_quantity := l_temp_load_quantity;
            -- If the min values are the same, then choose the container which can hold
            -- more of the source item, i.e. has a higher load quantity
         ELSIF (l_temp_min_value = l_curr_min_value) THEN
            IF (l_temp_load_quantity > l_curr_load_quantity) THEN
               l_curr_min_value := l_temp_min_value;
               l_curr_min_container := v_container_item.container_item_id;
               l_curr_load_quantity := l_temp_load_quantity;
            END IF;
         END IF;
      END LOOP;
      /* No containers were found that can store the source item */
      IF (l_curr_min_container = 0) THEN
         p_qty_required := 0;
         FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_NO_CONTAINER_FOUND');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         /* Valid container found.  Store this information in the output parameters */
         p_dest_cont_item_id := l_curr_min_container;
         p_qty_required := CEIL(p_source_qty / l_curr_load_quantity);
      END IF;
   END IF;
   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (   p_count     => x_msg_count,
   p_data      => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CONTAINER_REQUIRED_QTY_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
   (  p_count     => x_msg_count,
      p_data      => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CONTAINER_REQUIRED_QTY_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
   (  p_count     => x_msg_count,
      p_data      => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO CONTAINER_REQUIRED_QTY_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level
   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
    FND_MSG_PUB.Add_Exc_Msg
      (  G_PKG_NAME  ,
      l_api_name
      );
      END IF;
      FND_MSG_PUB.Count_And_Get
   (  p_count     => x_msg_count,
      p_data      => x_msg_data
      );
END Container_Required_Qty;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Prepack_LPN_CP (
   ERRBUF                    OUT NOCOPY VARCHAR2
,  RETCODE                   OUT NOCOPY NUMBER
,  p_api_version             IN         NUMBER
,  p_organization_id         IN         NUMBER
,  p_subinventory            IN         VARCHAR2 := NULL
,  p_locator_id              IN         NUMBER   := NULL
,  p_inventory_item_id       IN         NUMBER
,  p_revision                IN         VARCHAR2 := NULL
,  p_lot_number              IN         VARCHAR2 := NULL
,  p_quantity                IN         NUMBER
,  p_uom                     IN         VARCHAR2
,  p_source                  IN         NUMBER
,  p_serial_number_from      IN         VARCHAR2 := NULL
,  p_serial_number_to        IN         VARCHAR2 := NULL
,  p_container_item_id       IN         NUMBER   := NULL
,  p_cont_revision           IN         VARCHAR2 := NULL
,  p_cont_lot_number         IN         VARCHAR2 := NULL
,  p_cont_serial_number_from IN         VARCHAR2 := NULL
,  p_cont_serial_number_to   IN         VARCHAR2 := NULL
,  p_lpn_sealed_flag         IN         NUMBER   := NULL
,  p_print_label             IN         NUMBER   := NULL
,  p_print_content_report    IN         NUMBER   := NULL
,  p_packaging_level         IN         NUMBER   := -1
,  p_sec_quantity            IN         NUMBER   := NULL  --INVCONV kkillams
,  p_sec_uom                 IN         VARCHAR2 := NULL  --INVCONV kkillams
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Prepack_LPN_CP';
l_api_version CONSTANT NUMBER        := 1.0;

l_result               NUMBER;
x_return_status        VARCHAR2(4);
x_msg_count            NUMBER;
x_msg_data             VARCHAR2(300);
ret                    BOOLEAN;
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT PREPACK_LPN_CP_PVT;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Call Prepack LPN
    Prepack_LPN(
      p_api_version=> p_api_version,
      --p_init_msg_list=> := fnd_api.g_false,
      --p_commit=> fnd_api.g_false;,
      x_return_status=> x_return_status,
      x_msg_count=> x_msg_count,
      x_msg_data=> x_msg_data,
      p_organization_id=> p_organization_id,
      p_subinventory=> p_subinventory,
      p_locator_id=> p_locator_id,
      p_inventory_item_id=> p_inventory_item_id,
      p_revision=> p_revision,
      p_lot_number=> p_lot_number,
      p_quantity=> p_quantity,
      p_uom=> p_uom,
      p_source=> p_source,
      p_serial_number_from=> p_serial_number_from,
      p_serial_number_to=> p_serial_number_to,
      p_container_item_id=> p_container_item_id,
      p_cont_revision=> p_cont_revision,
      p_cont_lot_number=> p_cont_lot_number,
      p_cont_serial_number_from=> p_cont_serial_number_from,
      p_cont_serial_number_to=> p_cont_serial_number_to,
      p_lpn_sealed_flag=> p_lpn_sealed_flag,
      p_print_label=> p_print_label,
      p_print_content_report=> p_print_content_report,
      p_packaging_level=>p_packaging_level,
      p_sec_quantity    => p_sec_quantity, --INVCONV kkillams
      p_sec_uom         => p_sec_uom       --INVCONV kkillams
    );

    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      ret      := fnd_concurrent.set_completion_status('NORMAL', x_msg_data);
      retcode  := 0;
    ELSE
      ret      := fnd_concurrent.set_completion_status('ERROR', x_msg_data);
      retcode  := 2;
      errbuf   := x_msg_data;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO PREPACK_LPN_CP_PVT;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO PREPACK_LPN_CP_PVT;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO PREPACK_LPN_CP_PVT;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END prepack_lpn_cp;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Prepack_LPN(
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_subinventory            IN         VARCHAR2 := NULL
, p_locator_id              IN         NUMBER   := NULL
, p_inventory_item_id       IN         NUMBER
, p_revision                IN         VARCHAR2 := NULL
, p_lot_number              IN         VARCHAR2 := NULL
, p_quantity                IN         NUMBER
, p_uom                     IN         VARCHAR2
, p_source                  IN         NUMBER
, p_serial_number_from      IN         VARCHAR2 := NULL
, p_serial_number_to        IN         VARCHAR2 := NULL
, p_container_item_id       IN         NUMBER   := NULL
, p_cont_revision           IN         VARCHAR2 := NULL
, p_cont_lot_number         IN         VARCHAR2 := NULL
, p_cont_serial_number_from IN         VARCHAR2 := NULL
, p_cont_serial_number_to   IN         VARCHAR2 := NULL
, p_lpn_sealed_flag         IN         NUMBER   := NULL
, p_print_label             IN         NUMBER   := NULL
, p_print_content_report    IN         NUMBER   := NULL
, p_packaging_level         IN         NUMBER   := -1
, p_sec_quantity            IN         NUMBER   := NULL --INVCONV kkillams
, p_sec_uom                 IN         VARCHAR2 := NULL --INVCONV kkillams
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Prepack_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_result                     NUMBER;
l_container_item_id          NUMBER        := p_container_item_id;
l_max_load_quantity          NUMBER;
l_quantity                   NUMBER;
l_sec_quantity               NUMBER;      -- INVCONV kkillams
l_primary_quantity           NUMBER;
l_lot_number                 VARCHAR2(30)  := p_lot_number;
l_uom                        VARCHAR(30)   := p_uom;
l_lpn_source                 NUMBER        := p_source;
l_sec_pack_quantity          NUMBER;     -- INVCONV kkillams
l_sec_uom                    VARCHAR(3); -- INVCONV kkillams
l_pack_quantity              NUMBER;
l_lpn_quantity               NUMBER;
l_process_id                 NUMBER;
l_lpn_to_pack                NUMBER;
l_lpn_sealed_flag            NUMBER        := 2;
l_print_label                NUMBER        := 2;
l_print_content_report       NUMBER        := 2;
l_serial_number_from         VARCHAR2(30)  := NULL;
l_serial_number_to           VARCHAR2(30)  := NULL;
l_serial_suffix_current      NUMBER;
l_serial_def_flag            BOOLEAN       := FALSE;
l_serial_prefix              VARCHAR2(30);
l_serial_suffix_from         NUMBER;
l_serial_suffix_to           NUMBER;
l_serial_qty_btwn            NUMBER;
l_serial_suffix_length       NUMBER        := 0;
temp                         NUMBER;
l_cont_serial_number_from    VARCHAR2(30)  := NULL;
l_cont_serial_number_to      VARCHAR2(30)  := NULL;
l_cont_serial_suffix_current NUMBER;
l_cont_serial_def_flag       BOOLEAN       := FALSE;
l_cont_serial_prefix         VARCHAR2(30);
l_cont_serial_suffix_from    NUMBER;
l_cont_serial_suffix_to      NUMBER;
l_cont_serial_qty_btwn       NUMBER;
l_cont_serial_suffix_length  NUMBER        := 0;
l_current_serial             VARCHAR2(30);
l_lpn_id_out                 NUMBER;
l_lpn_out                    VARCHAR2(30);
x_error_code                 NUMBER;
x_proc_msg                   VARCHAR2(2000);
x_xml_file                   VARCHAR2(30);
l_trx_tmp_id                 NUMBER;
l_trx_header_id              NUMBER;
l_ser_trx_id                 NUMBER        := NULL;
l_primary_uom                VARCHAR2(4);
l_lot_control_code           NUMBER;

l_label_status               VARCHAR2(300);
l_input_param_tbl            inv_label.input_parameter_rec_type;
l_input_param_rec            mtl_material_transactions_temp%ROWTYPE;
l_counter                    NUMBER                                   := 1; -- Counter variable initialized to 1
l_qty                        NUMBER := 0;
error_msg                    VARCHAR2(2000);

CURSOR container_load IS
  SELECT max_load_quantity
    FROM wsh_container_items
   WHERE load_item_id = p_inventory_item_id
     AND container_item_id = p_container_item_id
     AND master_organization_id = p_organization_id
     AND ROWNUM < 2;

CURSOR container_lpn IS
  SELECT lpn_id
    FROM wms_lpn_process_temp
   WHERE process_id = l_process_id;

CURSOR cartonization_cursor IS
  SELECT mmtt.cartonization_id,
         mmtt.transaction_quantity,
         mmtt.primary_quantity,
         mmtt.transaction_uom,
         mtlt.lot_number,
         NVL(msnt1.fm_serial_number, msnt2.fm_serial_number),
         NVL(msnt1.to_serial_number, msnt2.to_serial_number)
       , mmtt.secondary_transaction_quantity --INVCONV kkillams
       , mmtt.secondary_uom_code             --INVCONV kkillams
    FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers_temp msnt1, mtl_serial_numbers_temp msnt2
   WHERE mmtt.organization_id = p_organization_id
     AND mmtt.transaction_header_id = l_trx_header_id
     AND mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
     AND msnt1.transaction_temp_id(+) = mtlt.serial_transaction_temp_id
     AND msnt2.transaction_temp_id(+) = mmtt.transaction_temp_id;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT prepack_lpn_pub;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  --x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  IF (l_debug = 1) THEN
      mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
      mdebug('orgid=' ||p_organization_id|| ' sub=' ||p_subinventory|| ' loc=' ||p_locator_id|| ' qty=' ||p_quantity|| ' uom=' ||p_uom|| ' src=' ||p_source||' lvl='||p_packaging_level, G_INFO);
      mdebug('itemid=' ||p_inventory_item_id|| ' rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' fmsn=' ||p_serial_number_from|| ' tosn=' ||p_serial_number_to, G_INFO);
      mdebug('citemid=' ||p_container_item_id|| ' crev=' ||p_cont_revision|| ' clot=' ||p_cont_lot_number|| ' cfmsn=' ||p_cont_serial_number_from|| ' ctosn=' ||p_cont_serial_number_to, G_INFO);
  END IF;

  -- Find primary UOM for this item
  SELECT primary_uom_code, lot_control_code
    INTO l_primary_uom, l_lot_control_code
    FROM mtl_system_items
   WHERE organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id;

  IF ( p_source = LPN_CONTEXT_WIP ) THEN
    -- WIP needs a different context for generate lpns than what is given.
    l_lpn_source := LPN_PREPACK_FOR_WIP;

    -- If lot controlled item in WIP and no lot is given generate a new lot for item
    IF ( l_lot_control_code = 2 AND p_lot_number IS NULL ) THEN
      l_lot_number := INV_LOT_API_PUB.Auto_Gen_Lot (
                        p_api_version       => 1.0
                      , x_return_status     => x_return_status
                      , x_msg_count         => x_msg_count
                      , x_msg_data          => x_msg_data
                      , p_org_id            => p_organization_id
                      , p_inventory_item_id => p_inventory_item_id );

      IF ( x_error_code <> 0 ) THEN
        IF (l_debug = 1) THEN
           mdebug('auto_gen_lot failed', G_ERROR);
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('lot number generated: '|| l_lot_number);
      END IF;
    END IF;
  END IF;

  -- If a container item has been specified, find quantity of
  -- items that can be contained in each.
  IF (p_container_item_id IS NOT NULL) THEN
    FOR l_temp_rec IN container_load LOOP
      l_max_load_quantity  := l_temp_rec.max_load_quantity;
    END LOOP;

    IF (l_debug = 1) THEN
       mdebug('max load qty '|| TO_CHAR(l_max_load_quantity), G_INFO);
    END IF;

    -- If no item container relationship exists assume container
    -- has infinite quanitiy and specify only one LPN, else
    -- calculate the number of containers need to prepack items
    IF (l_max_load_quantity IS NULL) THEN
      /* Generate only one LPN */
      l_lpn_quantity       := 1;
      l_max_load_quantity  := p_quantity;
      IF (l_debug = 1) THEN
         mdebug('Container_Required_Qty default '|| TO_CHAR(l_lpn_quantity), G_INFO);
      END IF;
    ELSE
      /* Calculate number of LPNs required */
      Container_Required_Qty(
        p_api_version=> 1.0,
        p_init_msg_list=> fnd_api.g_false,
        p_commit=> fnd_api.g_false,
        x_return_status=> x_return_status,
        x_msg_count=> x_msg_count,
        x_msg_data=> x_msg_data,
        p_source_item_id=> p_inventory_item_id,
        p_source_qty=> p_quantity,
        p_source_qty_uom=> p_uom,
        p_organization_id=> p_organization_id,
        p_dest_cont_item_id=> l_container_item_id,
        p_qty_required=> l_lpn_quantity
      );

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
           mdebug('calc lpn failed'|| x_msg_data, G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_QTY_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('Container_Required_Qty '|| TO_CHAR(l_lpn_quantity), G_INFO);
      END IF;
    END IF;

    Generate_LPN (
      p_api_version        => p_api_version
    , p_init_msg_list      => fnd_api.g_false
    , p_commit             => fnd_api.g_false
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_organization_id    => p_organization_id
    , p_container_item_id  => l_container_item_id
    , p_revision           => p_cont_revision
    , p_lot_number         => p_cont_lot_number
    , p_from_serial_number => l_cont_serial_number_from
    , p_to_serial_number   => l_cont_serial_number_to
    , p_quantity           => l_lpn_quantity
    , p_process_id         => l_process_id
    , p_lpn_id_out         => l_lpn_id_out
    , p_lpn_out            => l_lpn_out
    , p_source             => l_lpn_source );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
         mdebug('failed to generate lpn '|| x_msg_data, 1);
      END IF;
      fnd_message.set_name('WMS', 'WMS_LPN_GENERATION_FAIL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       mdebug('Process Id '|| TO_CHAR(l_process_id), G_INFO);
    END IF;

    SELECT COUNT(*)
      INTO temp
      FROM wms_lpn_process_temp
     WHERE process_id = l_process_id;

    IF (l_debug = 1) THEN
       mdebug('num lpn created: '|| TO_CHAR(temp), G_INFO);
    END IF;
  ELSE
    IF (l_debug = 1) THEN
       mdebug(' No container item specified ', G_MESSAGE);
    END IF;
    -- No container type specified, use cartonization API to find containers
    -- Convert transaction quantity to primary quantity
    l_primary_quantity := Convert_UOM(p_inventory_item_id, p_quantity, p_uom, l_primary_uom);

    IF (l_debug = 1) THEN
       mdebug('using cartonization api', G_MESSAGE);
    END IF;

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_trx_header_id
      FROM DUAL;

    IF (l_debug = 1) THEN
       mdebug('trx header id for cartonization created: '|| TO_CHAR(l_trx_header_id), G_INFO);
    END IF;
    x_error_code        := inv_trx_util_pub.insert_line_trx(
                             p_trx_hdr_id=> l_trx_header_id,
                             p_item_id=> p_inventory_item_id,
                             p_revision=> p_revision,
                             p_org_id=> p_organization_id,
                             p_trx_action_id=> inv_globals.g_action_containerpack,
                             p_subinv_code=> p_subinventory,
                             p_tosubinv_code=> NULL,
                             p_locator_id=> p_locator_id,
                             p_tolocator_id=> NULL,
                             p_xfr_org_id=> NULL,
                             p_trx_type_id=> inv_globals.g_type_container_pack,
                             p_trx_src_type_id=> inv_globals.g_sourcetype_inventory,
                             p_trx_qty=> p_quantity,
                             p_pri_qty=> l_primary_quantity,
                             p_uom=> p_uom,
                             p_date=> SYSDATE,
                             p_reason_id=> NULL,
                             p_user_id=> fnd_global.user_id,
                             p_frt_code=> NULL,
                             p_ship_num=> NULL,
                             p_dist_id=> NULL,
                             p_way_bill=> NULL,
                             p_exp_arr=> NULL,
                             p_cost_group=> NULL,
                             p_from_lpn_id=> NULL,
                             p_cnt_lpn_id=> NULL,
                             --p_xfr_lpn_id       => l_lpn_to_pack,
                             x_trx_tmp_id=> l_trx_tmp_id,
                             x_proc_msg=> x_proc_msg,
                             p_secondary_trx_qty =>p_sec_quantity, --INVCONV kkillams
                             p_secondary_uom =>p_sec_uom --INVCONV kkillams
                           );

    IF (x_error_code <> 0) THEN
      IF (l_debug = 1) THEN
         mdebug('failed INSERT_LINE_TRX '|| x_error_code, 1);
         mdebug('error msg: '|| x_proc_msg, 1);
      END IF;
      fnd_message.set_name('WMS', 'WMS_INSERT_LINE_TRX_FAIL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       mdebug('trx temp id created: '|| TO_CHAR(l_trx_tmp_id), G_INFO);
    END IF;

    IF ( x_error_code = 0 AND l_lot_number IS NOT NULL ) THEN
      IF (l_debug = 1) THEN
         mdebug('Insert lot entry in MTL_LOT_NUMBER_TEMP lot='|| l_lot_number, G_INFO);
      END IF;
      x_error_code  := inv_trx_util_pub.insert_lot_trx(
                         p_trx_tmp_id=> l_trx_tmp_id,
                         p_user_id=> fnd_global.user_id,
                         p_lot_number=> l_lot_number,
                         p_trx_qty=> p_quantity,
                         p_pri_qty=> l_primary_quantity,
                         p_secondary_qty =>p_sec_quantity, --INVCONV kkillams
                         p_secondary_uom =>p_sec_uom, --INVCONV kkillams
                         x_ser_trx_id=> l_ser_trx_id,
                         x_proc_msg=> x_proc_msg
                       );

      IF (x_error_code <> 0) THEN
        IF (l_debug = 1) THEN
           mdebug('failed INSERT_LOT_TRX lot='||l_lot_number||' '||x_error_code, G_ERROR);
           mdebug('error msg: '|| x_proc_msg, G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_INSERT_LOT_TRX_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF ( x_error_code = 0 AND l_serial_number_from IS NOT NULL ) THEN
      IF (l_ser_trx_id IS NOT NULL) THEN
        l_trx_tmp_id  := l_ser_trx_id;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('inserting serials '|| l_serial_number_from || '-' || l_serial_number_to || ' into mmtt', G_INFO);
         mdebug('with l_trx_tmp_id='|| l_trx_tmp_id, G_INFO);
      END IF;
      --Insert serials into MTL_SERIAL_NUMBERS_TEMP
      x_error_code  := inv_trx_util_pub.insert_ser_trx(
                         p_trx_tmp_id=> l_trx_tmp_id,
                         p_user_id=> fnd_global.user_id,
                         p_fm_ser_num=> l_serial_number_from,
                         p_to_ser_num=> l_serial_number_to,
                         x_proc_msg=> x_proc_msg
                       );

      IF (x_error_code <> 0) THEN
        IF (l_debug = 1) THEN
           mdebug('failed INSERT_SER_TRX '|| x_error_code, G_ERROR);
           mdebug('error msg: '|| x_proc_msg, G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_INSERT_SER_TRX_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
       mdebug('Calling cartonization', 9);
    END IF;

    WMS_CARTNZN_WRAP.Cartonize (
      p_api_version           => 1.0
    , p_init_msg_list         => fnd_api.g_false
    , p_commit                => fnd_api.g_false
    , x_return_status         => x_return_status
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    , p_org_id                => p_organization_id
    , p_transaction_header_id => l_trx_header_id
    , p_stop_level            => p_packaging_level
    , p_packaging_mode        => WMS_CARTNZN_WRAP.PREPACK_PKG_MODE );

    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
      IF (l_debug = 1) THEN
         mdebug('Error in calling Cartonization'|| x_msg_data, 1);
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      IF (l_debug = 1) THEN
         mdebug('Unexpectied error in calling Cartonization'|| x_msg_data, 1);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
         mdebug('Undefined error in calling Cartonization'|| x_msg_data, 1);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       mdebug('cartonization api done');
    END IF;
    -- Cartonization does label printing disable pack label printing
    l_print_label       := 2;

    -- Generate a process ID number to to insert LPNs into process temp table
    SELECT wms_lpn_process_temp_s.NEXTVAL
      INTO l_process_id
      FROM DUAL;

    IF (l_debug = 1) THEN
       mdebug('created process id: '|| l_process_id, G_INFO);
    END IF;
  END IF;

  --Could be useful later
  /*IF ( l_container_item.serial_number_control_code = 2 AND p_source IN (2,3) ) THEN
  -- Serials need to be dymanically generated for LPNs
  x_error_code := INV_SERIAL_NUMBER_PUB.GENERATE_SERIALS
    (p_org_id     =>  p_organization_id,
     p_item_id    =>  p_container_item_id,
     p_qty        =>  l_lpn_quantity,
     p_wip_id     =>  NULL,
     p_rev        =>  p_cont_revision,
     p_lot        =>  p_cont_lot_number,
     x_start_ser  =>  l_cont_serial_number_from,
     x_end_ser    =>  l_cont_serial_number_to,
     x_proc_msg   =>  x_msg_data);

    IF x_error_code <> 0 THEN
    IF (l_debug = 1) THEN
       mdebug('failed genreate serials ' || TO_CHAR(x_error_code));
    END IF;
    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SER');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
    ELSE
    IF (l_debug = 1) THEN
       mdebug('genreated serials ' || l_cont_serial_number_from || ' - ' || l_cont_serial_number_to);
    END IF;
    END IF;
    END IF;*/

  -- put total quantity into temp variable
  l_quantity  := p_quantity;
  l_sec_quantity := p_sec_quantity;  --INVCONV kkillams

  IF l_serial_def_flag THEN
    l_serial_suffix_current  := l_serial_suffix_from - 1;
  ELSE
    l_serial_number_from  := NULL;
    l_serial_number_to    := NULL;
  END IF;

  -- Open Cursor
  IF (p_container_item_id IS NULL) THEN
    OPEN cartonization_cursor;
  ELSE
    OPEN container_lpn;
  END IF;

  -- Pack and Change Context of LPN
  --FOR container_rec IN container_lpn
  LOOP
    IF (p_container_item_id IS NULL) THEN
                FETCH cartonization_cursor INTO l_lpn_to_pack, l_pack_quantity, l_primary_quantity,
                                                l_uom, l_lot_number, l_serial_number_from, l_serial_number_to,
                                                l_sec_pack_quantity,l_sec_uom; --INVCONV kkillams
      EXIT WHEN cartonization_cursor%NOTFOUND;

    -- Cartonization created LPNs, lpn_context must be set before packing
      IF (l_debug = 1) THEN
         mdebug('setting lpn id= ' || l_lpn_to_pack || ' to context ' || l_lpn_source, G_INFO);
      END IF;
      -- Bug5659809: update last_update_date and last_update_by as well
      UPDATE wms_license_plate_numbers
      SET lpn_context = l_lpn_source
        , last_update_date = SYSDATE
        , last_updated_by = fnd_global.user_id
      WHERE lpn_id = l_lpn_to_pack;
    ELSE
      FETCH container_lpn INTO l_lpn_to_pack;
      EXIT WHEN container_lpn%NOTFOUND;

      -- Pack the lesser of the maximum container load or remaining item quantity
      IF l_quantity < l_max_load_quantity THEN
        l_pack_quantity  := l_quantity;
                  l_sec_pack_quantity := l_sec_quantity;  -- INVCONV kkillams
      ELSE
        l_pack_quantity  := l_max_load_quantity;
                  l_sec_pack_quantity := inv_convert.inv_um_convert(p_inventory_item_id,
                                                                    g_precision,
                                                                    l_max_load_quantity,
                                                                    p_uom,
                                                                    p_sec_uom,
                                                                    NULL,
                                                                    NULL); --INVCONV KKILLAMS
        l_quantity       := l_quantity - l_max_load_quantity;
      END IF;

      -- Not using cartonization. Need to convert pack quantity to a primary quantity
      l_primary_quantity  := Convert_UOM(p_inventory_item_id, l_pack_quantity, p_uom, l_primary_uom);

      -- set next group of serials to be packed.
      IF l_serial_def_flag THEN
        l_serial_suffix_from     := l_serial_suffix_current + 1;
        --l_serial_suffix_current := l_serial_suffix_current + least(l_max_load_quantity, l_quantity);
        l_serial_suffix_current  := l_serial_suffix_current + l_primary_quantity;
        l_serial_number_from     := l_serial_prefix || LPAD(TO_CHAR(l_serial_suffix_from), l_serial_suffix_length, '0');
        l_serial_number_to       := l_serial_prefix || LPAD(TO_CHAR(l_serial_suffix_current), l_serial_suffix_length, '0');
      END IF;
    END IF;

    IF (l_lpn_to_pack IS NULL) THEN
      IF (l_debug = 1) THEN
         mdebug('cartonize failed: No LPN Specified in row', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CARTONIZE_ERROR');
      fnd_msg_pub.ADD;
      --COMMIT;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       mdebug('packing lpn='|| l_lpn_to_pack || ' with qty=' || l_primary_quantity || ' ' ||l_primary_uom);
       mdebug('with lot='|| l_lot_number || ' serials=' || l_serial_number_from || '-' || l_serial_number_to);
    END IF;

    --If an invenotory prepack, insert trx in mtl_material_transactions_temp table
    IF (p_source = 1) THEN
      -- if inventory prepack, trx header id required
      SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_trx_header_id
      FROM DUAL;

      IF (l_debug = 1) THEN
         mdebug('trx header id created: '|| TO_CHAR(l_trx_header_id), G_INFO);
      END IF;

      IF (l_debug = 1) THEN
         mdebug('packing lpn: '|| TO_CHAR(l_lpn_to_pack) || ' with qty ' || TO_CHAR(l_primary_quantity));
      END IF;
      x_error_code  := inv_trx_util_pub.insert_line_trx(
                         p_trx_hdr_id=> l_trx_header_id,
                         p_item_id=> p_inventory_item_id,
                         p_revision=> p_revision,
                         p_org_id=> p_organization_id,
                         p_trx_action_id=> inv_globals.g_action_containerpack,
                         p_subinv_code=> p_subinventory,
                         p_tosubinv_code=> NULL,
                         p_locator_id=> p_locator_id,
                         p_tolocator_id=> NULL,
                         p_xfr_org_id=> NULL,
                         p_trx_type_id=> inv_globals.g_type_container_pack,
                         p_trx_src_type_id=> inv_globals.g_sourcetype_inventory,
                         p_trx_qty=> l_pack_quantity,
                         p_pri_qty=> l_primary_quantity,
                         p_uom=> l_primary_uom,
                         p_date=> SYSDATE,
                         p_reason_id=> NULL,
                         p_user_id=> fnd_global.user_id,
                         p_frt_code=> NULL,
                         p_ship_num=> NULL,
                         p_dist_id=> NULL,
                         p_way_bill=> NULL,
                         p_exp_arr=> NULL,
                         p_cost_group=> NULL,
                         p_from_lpn_id=> NULL,
                         p_cnt_lpn_id=> NULL,
                         p_xfr_lpn_id=> l_lpn_to_pack,
                         x_trx_tmp_id=> l_trx_tmp_id,
                                   x_proc_msg=> x_proc_msg,
                                   p_secondary_trx_qty =>l_sec_pack_quantity, --INVCONV kkillams
                                   p_secondary_uom =>l_sec_uom --INVCONV kkillams
                                   );

      IF (x_error_code <> 0) THEN
        IF (l_debug = 1) THEN
           mdebug('failed INSERT_LINE_TRX '|| x_error_code, G_ERROR);
           mdebug('error msg: '|| x_proc_msg, 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_INSERT_LINE_TRX_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('trx temp id created: '|| TO_CHAR(l_trx_tmp_id), G_INFO);
      END IF;

      IF ( x_error_code = 0 AND l_lot_number IS NOT NULL ) THEN
         IF (l_debug = 1) THEN
            mdebug('Insert lot entry in MTL_LOT_NUMBER_TEMP lot='|| l_lot_number, G_INFO);
         END IF;
         x_error_code  := inv_trx_util_pub.insert_lot_trx(
                            p_trx_tmp_id=> l_trx_tmp_id,
                            p_user_id=> fnd_global.user_id,
                            p_lot_number=> l_lot_number,
                            p_trx_qty=> l_primary_quantity,
                            p_pri_qty=> l_primary_quantity,
                                           p_secondary_qty => l_sec_pack_quantity, --INVCONV kkillams
                                           p_secondary_uom =>l_sec_uom, --INVCONV kkillams
                            x_ser_trx_id=> l_ser_trx_id,
                            x_proc_msg=> x_proc_msg
                          );

         IF (x_error_code <> 0) THEN
           IF (l_debug = 1) THEN
              mdebug('failed INSERT_LOT_TRX '|| x_error_code, 1);
              mdebug('error msg: '|| x_proc_msg, 1);
           END IF;
           fnd_message.set_name('WMS', 'WMS_INSERT_LOT_TRX_FAIL');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF ( x_error_code = 0 AND l_serial_number_from IS NOT NULL ) THEN
         IF (l_ser_trx_id IS NOT NULL) THEN
            l_trx_tmp_id  := l_ser_trx_id;
         END IF;
         IF (l_debug = 1) THEN
            mdebug('inserting serials '|| l_serial_number_from || '-' || l_serial_number_to || ' into mmtt', G_INFO);
            mdebug('with l_trx_tmp_id='|| l_trx_tmp_id, G_INFO);
         END IF;
         x_error_code  := inv_trx_util_pub.insert_ser_trx(
                            p_trx_tmp_id=> l_trx_tmp_id,
                            p_user_id=> fnd_global.user_id,
                            p_fm_ser_num=> l_serial_number_from,
                            p_to_ser_num=> l_serial_number_to,
                            x_proc_msg=> x_proc_msg
                          );

         IF (x_error_code <> 0) THEN
            IF (l_debug = 1) THEN
               mdebug('failed INSERT_SER_TRX '|| x_error_code, 1);
               mdebug('error msg: '|| x_proc_msg, 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_INSERT_SER_TRX_FAIL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      --Call LPN Transaction API
      IF (l_debug = 1) THEN
         mdebug('calling process lpn trx');
      END IF;
      x_error_code  := inv_lpn_trx_pub.process_lpn_trx(p_trx_hdr_id => l_trx_header_id, p_commit => fnd_api.g_false, x_proc_msg => error_msg, p_business_flow_code => 20);

      IF (x_error_code <> 0) THEN
        IF (l_debug = 1) THEN
           mdebug('failed PROCESS_LPN_TRX '|| x_error_code, 1);
           mdebug('error msg: '|| error_msg, G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_PROCESS_LPN_TRX_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('Packed LPN_ID '|| TO_CHAR(l_lpn_to_pack), G_INFO);
      END IF;
    ELSE --Source is WIP or Rec do pack w/o trx manager
      IF (l_debug = 1) THEN
         mdebug('packing lpn: '|| l_lpn_to_pack || ' with qty ' || l_primary_quantity ||' '|| l_primary_uom, G_INFO);
      END IF;

      PackUnpack_Container(
        p_api_version=> 1.0,
        p_init_msg_list=> fnd_api.g_false,
        p_commit=> fnd_api.g_false,
        p_validation_level=> fnd_api.g_valid_level_none,
        x_return_status=> x_return_status,
        x_msg_count=> x_msg_count,
        x_msg_data=> x_msg_data,
        p_lpn_id=> l_lpn_to_pack,
        p_content_item_id=> p_inventory_item_id,
        p_revision=> p_revision,
        p_lot_number=> l_lot_number,
        p_from_serial_number=> l_serial_number_from,
        p_to_serial_number=> l_serial_number_to,
        p_quantity=> l_primary_quantity,
        p_uom=> l_primary_uom,
        p_organization_id=> p_organization_id,
        p_operation=> 1 );

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         IF (l_debug = 1) THEN
            mdebug('failed to pack lpn: '|| TO_CHAR(l_lpn_to_pack), G_ERROR);
         END IF;
         fnd_message.set_name('WMS', 'WMS_PACK_CONTAINER_FAIL');
         fnd_message.set_token('lpn', TO_CHAR(l_lpn_to_pack));
         fnd_msg_pub.ADD;
         --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
         IF (l_debug = 1) THEN
            mdebug('packed lpn: '|| l_lpn_to_pack || ' with qty ' || l_primary_quantity, G_INFO);
         END IF;
      END IF;
    END IF;

    IF (p_container_item_id IS NULL) THEN
      -- Insert the LPN created into the WMS_LPN_PROCESS_TEMP table
      IF (l_debug = 1) THEN
         mdebug('making insert to temp table', G_MESSAGE);
      END IF;
      INSERT INTO wms_lpn_process_temp ( process_id, lpn_id )
      VALUES ( l_process_id, l_lpn_to_pack);
    ELSE
      --Not through cartonization, need to insert Row for label printing
      l_input_param_rec.lpn_id      := l_lpn_to_pack;
      l_input_param_tbl(l_counter)  := l_input_param_rec;
      l_counter                     := l_counter + 1;
    END IF;

    IF (l_lpn_sealed_flag = 1) THEN
      IF (l_debug = 1) THEN
         mdebug('Sealing LPN', G_MESSAGE);
      END IF;
      modify_lpn_wrapper(
        p_api_version=> 1.0,
        p_init_msg_list=> fnd_api.g_false,
        p_commit=> fnd_api.g_false,
        x_return_status=> x_return_status,
        x_msg_count=> x_msg_count,
        x_msg_data=> x_msg_data,
        p_lpn_id=> l_lpn_to_pack,
        p_sealed_status=> 1 );

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
           mdebug('failed to seal lpn: '|| TO_CHAR(l_lpn_to_pack), G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_PACK_CONTAINER_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
END LOOP;

IF (l_debug = 1) THEN
  mdebug('done with loop', G_MESSAGE);
END IF;

-- Label printing call with cartonization flow must be made if cartonization was used
IF (p_container_item_id IS NULL) THEN
  inv_label.print_label (
    x_return_status      => x_return_status
  , x_msg_count          => x_msg_count
  , x_msg_data           => x_msg_data
  , x_label_status       => l_label_status
  , p_api_version        => 1.0
  , p_print_mode         => 1
  , p_business_flow_code => 22
  , p_transaction_id     => WMS_CARTNZN_WRAP.get_lpns_generated_tb);

  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
    IF (l_debug = 1) THEN
      mdebug('**Error in Cartonization Label Printing :'||x_return_status,1);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END if;
END IF;

IF (l_print_label = 1) THEN
  -- Print LPN Labels
  IF (l_debug = 1) THEN
     mdebug('Calling Print label api');
  END IF;
  inv_label.print_label(
    x_return_status=> x_return_status,
    x_msg_count=> x_msg_count,
    x_msg_data=> x_msg_data,
    x_label_status=> l_label_status,
    p_api_version=> 1.0,
    p_print_mode=> 2,
    p_business_flow_code=> 20,
    p_input_param_rec=> l_input_param_tbl
  );

  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
    IF (l_debug = 1) THEN
       mdebug('failed to print labels', 1);
    END IF;
    fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
    fnd_msg_pub.ADD;
  --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
END IF;

-- Close cursor
IF (p_container_item_id IS NULL) THEN
  CLOSE cartonization_cursor;
ELSE
  CLOSE container_lpn;
END IF;

-- Delete lpn entries from temp table
DELETE FROM wms_lpn_process_temp
WHERE process_id = l_process_id;

-- Delete lpn entries from temp table
IF (p_container_item_id IS NULL) THEN
   DELETE FROM mtl_material_transactions_temp
   WHERE transaction_header_id = l_trx_header_id;
END IF;

-- End of API body

-- Standard check of p_commit.
IF fnd_api.to_boolean(p_commit) THEN
  COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1,
-- get message info.
fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    IF (l_debug = 1) THEN
       mdebug('Execution Error', 1);
    END IF;
    ROLLBACK TO prepack_lpn_pub;
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF (l_debug = 1) THEN
       mdebug('Unexpected Execution Error', 1);
    END IF;
    ROLLBACK TO prepack_lpn_pub;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
       mdebug('others error', 1);
    END IF;
    ROLLBACK TO prepack_lpn_pub;
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END Prepack_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Pack_Prepack_Container(
  p_api_version        IN         NUMBER
, p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
, p_commit             IN         VARCHAR2 := fnd_api.g_false
, p_validation_level   IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_lpn_id             IN         NUMBER
, p_content_item_id    IN         NUMBER   := NULL
, p_revision           IN         VARCHAR2 := NULL
, p_lot_number         IN         VARCHAR2 := NULL
, p_from_serial_number IN         VARCHAR2 := NULL
, p_to_serial_number   IN         VARCHAR2 := NULL
, p_quantity           IN         NUMBER   := 1
, p_uom                IN         VARCHAR2 := NULL
, p_organization_id    IN         NUMBER
, p_operation          IN         NUMBER
, p_source_type_id     IN         NUMBER   := NULL
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Pack_Prepack_Container';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_current_serial VARCHAR2(30):= p_from_serial_number;
l_prefix         VARCHAR2(30);
l_quantity       NUMBER;
l_from_number    NUMBER;
l_to_number      NUMBER;
l_length         NUMBER;
l_errorcode      NUMBER;

l_padded_length  NUMBER;
l_current_number NUMBER;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT PACK_PREPACK_CONTAINER;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  -- API body
  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('lpnid=' ||p_lpn_id|| ' orgid=' ||p_organization_id||' itemid=' ||p_content_item_id, G_INFO);
    mdebug('rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' fmsn=' ||p_from_serial_number|| ' tosn=' ||p_to_serial_number, G_INFO);
    mdebug('qty=' ||p_quantity|| ' uom=' ||p_uom|| ' oper=' ||p_operation|| ' srctype=' ||p_source_type_id, G_INFO);
  END IF;

  IF ( p_content_item_id IS NOT NULL ) THEN
    IF ( p_from_serial_number IS NOT NULL AND p_to_serial_number IS NOT NULL ) THEN
      -- Packing range serialized items
      -- Call this API to parse the serial numbers into prefixes and numbers
      IF (NOT mtl_serial_check.inv_serial_info(p_from_serial_number, p_to_serial_number, l_prefix, l_quantity, l_from_number, l_to_number, l_errorcode)) THEN
        IF (l_debug = 1) THEN
          mdebug('Invalid serial number given in range', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- Initialize the current pointer variables
      l_current_serial  := p_from_serial_number;
      l_current_number  := l_from_number;

      LOOP
        -- Serialized item packed LPN information are stored
        -- in the serial numbers table
        -- Also update the cost group field since it is not
        -- guaranteed that the serial number will have that value stamped
        -- if serial status is not resides in store (3), update lot and rev
        UPDATE mtl_serial_numbers
           SET lpn_id = p_lpn_id,
               last_update_date = SYSDATE,
               last_updated_by = fnd_global.user_id,
               last_txn_source_type_id = p_source_type_id,
               revision = DECODE(current_status, 3, revision, p_revision),
               lot_number = DECODE(current_status, 3, lot_number, p_lot_number)
         WHERE inventory_item_id = p_content_item_id
           AND serial_number = l_current_serial
           AND current_organization_id = p_organization_id;

        EXIT WHEN l_current_serial = p_to_serial_number;
        /* Increment the current serial number */
        l_current_number  := l_current_number + 1;
        l_padded_length   := l_length - LENGTH(l_current_number);

        IF l_prefix IS NOT NULL THEN
          l_current_serial := RPAD(l_prefix, l_padded_length, '0') || l_current_number;
        ELSE
          l_current_serial := Rpad('@',l_padded_length+1,'0') || l_current_number;
          l_current_serial := Substr(l_current_serial,2);
        END IF;
        -- Bug 2375043
        --l_current_serial := RPAD(l_prefix, l_padded_length, '0') || l_current_number;
      END LOOP;

      UPDATE wms_lpn_contents
         SET last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             serial_summary_entry = 1,
             source_type_id = p_source_type_id
       WHERE parent_lpn_id = p_lpn_id
         AND organization_id = p_organization_id
         AND inventory_item_id = p_content_item_id
         AND NVL(revision, G_NULL_CHAR) = NVL(p_revision, G_NULL_CHAR)
         AND NVL(lot_number, G_NULL_CHAR) = NVL(p_lot_number, G_NULL_CHAR);

      UPDATE wms_license_plate_numbers
         SET last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             lpn_context = LPN_CONTEXT_WIP
       WHERE lpn_id = p_lpn_id
         AND organization_id = p_organization_id;
    END IF;
  END IF;
  -- End of API body

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO PACK_PREPACK_CONTAINER;
    x_return_status  := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO PACK_PREPACK_CONTAINER;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO PACK_PREPACK_CONTAINER;
    x_return_status  := fnd_api.g_ret_sts_unexp_error;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END Pack_Prepack_Container;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Explode_LPN (
  p_api_version     IN         NUMBER
, p_init_msg_list   IN         VARCHAR2 := fnd_api.g_false
, p_commit          IN         VARCHAR2 := fnd_api.g_false
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
, p_lpn_id          IN         NUMBER
, p_explosion_level IN         NUMBER   := 0
, x_content_tbl     OUT NOCOPY WMS_CONTAINER_PUB.WMS_Container_Tbl_Type
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Explode_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';
l_msgdata              VARCHAR2(1000);

l_counter               NUMBER := 1;  -- Counter variable initialized to 1
l_current_lpn           NUMBER;
l_temp_uom_code         VARCHAR2(3);
l_container_content_rec WMS_CONTAINER_PUB.WMS_Container_Content_Rec_Type;

CURSOR nested_lpn_cursor IS
  SELECT lpn_id, parent_lpn_id, inventory_item_id, organization_id,
         revision, lot_number, serial_number, cost_group_id
    FROM WMS_LICENSE_PLATE_NUMBERS
   WHERE Level <= p_explosion_level
   START WITH lpn_id = p_lpn_id
 CONNECT BY parent_lpn_id = PRIOR lpn_id;

CURSOR all_nested_lpn_cursor IS
  SELECT lpn_id, parent_lpn_id, inventory_item_id, organization_id,
         revision, lot_number, serial_number, cost_group_id
    FROM WMS_LICENSE_PLATE_NUMBERS
   START WITH lpn_id = p_lpn_id
 CONNECT BY parent_lpn_id = PRIOR lpn_id;

CURSOR lpn_contents_cursor IS
  SELECT parent_lpn_id, inventory_item_id, item_description,
           organization_id, revision, lot_number,
        serial_number, quantity, uom_code, cost_group_id,
        secondary_quantity, secondary_uom_code  --INVCONV kkillams
    FROM WMS_LPN_CONTENTS
   WHERE parent_lpn_id = l_current_lpn
     AND NVL(serial_summary_entry, 2) = 2;

CURSOR lpn_serial_contents_cursor IS
  SELECT inventory_item_id, current_organization_id, lpn_id,
           revision, lot_number, serial_number, cost_group_id
    FROM MTL_SERIAL_NUMBERS
   WHERE lpn_id = l_current_lpn
   -- bug 5103594, added the Order By clause
   ORDER BY inventory_item_id, revision, lot_number, serial_number;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT EXPLODE_LPN;

  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('ver='||p_api_version||' initmsg='||p_init_msg_list||' commit='||p_commit||' lpn='||p_lpn_id||' explvl='||p_explosion_level, G_INFO);
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  IF (p_explosion_level = 0) THEN
    /* Use the cursor that searches through all levels in the parent child relationship */
    FOR v_lpn_id IN all_nested_lpn_cursor LOOP
       l_current_lpn := v_lpn_id.lpn_id;

       /* Store the lpn information also from license plate numbers table */
       l_container_content_rec.parent_lpn_id       := v_lpn_id.parent_lpn_id;
       l_container_content_rec.content_lpn_id      := v_lpn_id.lpn_id;
       l_container_content_rec.content_item_id     := v_lpn_id.inventory_item_id;
       l_container_content_rec.content_description := NULL;
       l_container_content_rec.content_type        := '2';
       l_container_content_rec.organization_id     := v_lpn_id.organization_id;
       l_container_content_rec.revision            := v_lpn_id.revision;
       l_container_content_rec.lot_number          := v_lpn_id.lot_number;
       l_container_content_rec.serial_number       := v_lpn_id.serial_number;
       l_container_content_rec.quantity            := 1;
       l_container_content_rec.uom                 := NULL;
       l_container_content_rec.cost_group_id       := v_lpn_id.cost_group_id;

       x_content_tbl(l_counter) := l_container_content_rec;
       l_counter := l_counter + 1;

       /* Store all the item information from the lpn contents table */
       FOR v_lpn_content IN lpn_contents_cursor LOOP
         l_container_content_rec.parent_lpn_id       := v_lpn_content.parent_lpn_id;
         l_container_content_rec.content_lpn_id      := NULL;
         l_container_content_rec.content_item_id     := v_lpn_content.inventory_item_id;
         l_container_content_rec.content_description := v_lpn_content.item_description;
         IF (v_lpn_content.inventory_item_id IS NOT NULL) THEN
           l_container_content_rec.content_type      := '1';
         ELSE
           l_container_content_rec.content_type      := '3';
         END IF;
         l_container_content_rec.organization_id     := v_lpn_content.organization_id;
         l_container_content_rec.revision            := v_lpn_content.revision;
         l_container_content_rec.lot_number          := v_lpn_content.lot_number;
         l_container_content_rec.serial_number       := v_lpn_content.serial_number;
         l_container_content_rec.quantity            := v_lpn_content.quantity;
         l_container_content_rec.uom                 := v_lpn_content.uom_code;
         l_container_content_rec.cost_group_id       := v_lpn_content.cost_group_id;
              l_container_content_rec.sec_quantity        := v_lpn_content.secondary_quantity;  --INVCONV kkillams
              l_container_content_rec.sec_uom             := v_lpn_content.secondary_uom_code;  --INVCONV kkillams
         x_content_tbl(l_counter) := l_container_content_rec;
         l_counter := l_counter + 1;
       END LOOP;

       -- Store all the serialized item information from the serial
       -- numbers table
       FOR v_lpn_serial_content IN lpn_serial_contents_cursor LOOP
         /* Get the primary UOM for the serialized item */
         SELECT primary_uom_code
           INTO l_temp_uom_code
           FROM mtl_system_items
          WHERE inventory_item_id = v_lpn_serial_content.inventory_item_id
            AND organization_id = v_lpn_serial_content.current_organization_id;

         l_container_content_rec.parent_lpn_id       := v_lpn_serial_content.lpn_id;
         l_container_content_rec.content_lpn_id      := NULL;
         l_container_content_rec.content_item_id     := v_lpn_serial_content.inventory_item_id;
         l_container_content_rec.content_description := NULL;
         l_container_content_rec.content_type        := '1';
         l_container_content_rec.organization_id     := v_lpn_serial_content.current_organization_id;
         l_container_content_rec.revision            := v_lpn_serial_content.revision;
         l_container_content_rec.lot_number          := v_lpn_serial_content.lot_number;
         l_container_content_rec.serial_number       := v_lpn_serial_content.serial_number;
         l_container_content_rec.quantity            := 1;
         l_container_content_rec.uom                 := l_temp_uom_code;
         l_container_content_rec.cost_group_id       := v_lpn_serial_content.cost_group_id;

         x_content_tbl(l_counter) := l_container_content_rec;
         l_counter := l_counter + 1;
       END LOOP;
     END LOOP;
  ELSE
    /* Use the cursor that searches only a specified number of levels */
    FOR v_lpn_id IN nested_lpn_cursor LOOP
       l_current_lpn := v_lpn_id.lpn_id;

       /* Store the lpn information also from license plate numbers table */
       l_container_content_rec.parent_lpn_id       := v_lpn_id.parent_lpn_id;
       l_container_content_rec.content_lpn_id      := v_lpn_id.lpn_id;
       l_container_content_rec.content_item_id     := v_lpn_id.inventory_item_id;
       l_container_content_rec.content_description := NULL;
       l_container_content_rec.content_type        := '2';
       l_container_content_rec.organization_id     := v_lpn_id.organization_id;
       l_container_content_rec.revision            := v_lpn_id.revision;
       l_container_content_rec.lot_number          := v_lpn_id.lot_number;
       l_container_content_rec.serial_number       := v_lpn_id.serial_number;
       l_container_content_rec.quantity            := 1;
       l_container_content_rec.uom                 := NULL;
       l_container_content_rec.cost_group_id       := v_lpn_id.cost_group_id;

       x_content_tbl(l_counter) := l_container_content_rec;
       l_counter := l_counter + 1;

       /* Store all the item information from the lpn contents table */
       FOR v_lpn_content IN lpn_contents_cursor LOOP
         l_container_content_rec.parent_lpn_id       := v_lpn_content.parent_lpn_id;
         l_container_content_rec.content_lpn_id      := NULL;
         l_container_content_rec.content_item_id     := v_lpn_content.inventory_item_id;
         l_container_content_rec.content_description := v_lpn_content.item_description;
         IF (v_lpn_content.inventory_item_id IS NOT NULL) THEN
           l_container_content_rec.content_type      := '1';
         ELSE
           l_container_content_rec.content_type      := '3';
         END IF;
         l_container_content_rec.organization_id     := v_lpn_content.organization_id;
         l_container_content_rec.revision            := v_lpn_content.revision;
         l_container_content_rec.lot_number          := v_lpn_content.lot_number;
         l_container_content_rec.serial_number       := v_lpn_content.serial_number;
         l_container_content_rec.quantity            := v_lpn_content.quantity;
         l_container_content_rec.uom                 := v_lpn_content.uom_code;
         l_container_content_rec.cost_group_id       := v_lpn_content.cost_group_id;
              l_container_content_rec.sec_quantity        := v_lpn_content.secondary_quantity;  --INVCONV kkillams
              l_container_content_rec.sec_uom             := v_lpn_content.secondary_uom_code;  --INVCONV kkillams

         x_content_tbl(l_counter) := l_container_content_rec;
         l_counter := l_counter + 1;
       END LOOP;

       -- Store all the serialized item information from the serial
       -- numbers table
       FOR v_lpn_serial_content IN lpn_serial_contents_cursor LOOP
         /* Get the primary UOM for the serialized item */
         SELECT primary_uom_code
           INTO l_temp_uom_code
           FROM mtl_system_items
          WHERE inventory_item_id = v_lpn_serial_content.inventory_item_id
            AND organization_id = v_lpn_serial_content.current_organization_id;

         l_container_content_rec.parent_lpn_id       := v_lpn_serial_content.lpn_id;
         l_container_content_rec.content_lpn_id      := NULL;
         l_container_content_rec.content_item_id     := v_lpn_serial_content.inventory_item_id;
         l_container_content_rec.content_description := NULL;
         l_container_content_rec.content_type        := '1';
         l_container_content_rec.organization_id     := v_lpn_serial_content.current_organization_id;
         l_container_content_rec.revision            := v_lpn_serial_content.revision;
         l_container_content_rec.lot_number          := v_lpn_serial_content.lot_number;
         l_container_content_rec.serial_number       := v_lpn_serial_content.serial_number;
         l_container_content_rec.quantity            := 1;
         l_container_content_rec.uom                 := l_temp_uom_code;
         l_container_content_rec.cost_group_id       := v_lpn_serial_content.cost_group_id;

         x_content_tbl(l_counter) := l_container_content_rec;
         l_counter := l_counter + 1;
       END LOOP;
     END LOOP;
  END IF;
  -- End of API body

  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Exit x_content_tbl count=' ||x_content_tbl.last, G_INFO);
  END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get( p_count =>   x_msg_count, p_data  => x_msg_data );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO EXPLODE_LPN;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data  => x_msg_data );

    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Exc err prog='||g_progress||' SQL err: '|| SQLERRM(SQLCODE), 1);
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug('msg: '||l_msgdata, 1);
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO EXPLODE_LPN;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data  => x_msg_data );

    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Unexp err prog='||g_progress||' SQL err: '|| SQLERRM(SQLCODE), 1);
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug('msg: '||l_msgdata, 1);
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO EXPLODE_LPN;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data  => x_msg_data );

    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Others err prog='||g_progress||' SQL err: '|| SQLERRM(SQLCODE), 1);
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug('msg: '||l_msgdata, 1);
    END IF;
END Explode_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

FUNCTION Validate_LPN (
  p_lpn IN OUT nocopy WMS_CONTAINER_PUB.LPN
, p_lock IN NUMBER := 2
) RETURN NUMBER IS
l_api_name    CONSTANT VARCHAR2(30) := 'Validate_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

BEGIN
  /* Check that either an lpn id or license plate number was given */
  IF ((p_lpn.lpn_id IS NULL OR p_lpn.lpn_id = FND_API.G_MISS_NUM) AND
      (p_lpn.license_plate_number IS NULL OR
    p_lpn.license_plate_number = FND_API.G_MISS_CHAR)) THEN
    RETURN F;
  END IF;

  /* Search the table for an entry that matches the given input(s) */
  IF (p_lpn.license_plate_number IS NULL OR
      p_lpn.license_plate_number = FND_API.G_MISS_CHAR)
  THEN
    IF ( p_lock = 1 ) THEN
      SELECT *
      INTO p_lpn
      FROM WMS_LICENSE_PLATE_NUMBERS
      WHERE LPN_ID  = p_lpn.lpn_id
      FOR UPDATE;
    ELSE
      SELECT *
      INTO p_lpn
      FROM WMS_LICENSE_PLATE_NUMBERS
      WHERE LPN_ID  = p_lpn.lpn_id;
    END IF;

    RETURN T;
  ELSIF (p_lpn.lpn_id IS NULL OR p_lpn.lpn_id = FND_API.G_MISS_NUM) THEN
    IF ( p_lock = 1 ) THEN
      SELECT *
      INTO p_lpn
      FROM WMS_LICENSE_PLATE_NUMBERS
      WHERE LICENSE_PLATE_NUMBER = p_lpn.license_plate_number
      FOR UPDATE;
    ELSE
      SELECT *
      INTO p_lpn
      FROM WMS_LICENSE_PLATE_NUMBERS
      WHERE LICENSE_PLATE_NUMBER = p_lpn.license_plate_number;
    END IF;

    RETURN T;
  ELSE
    IF ( p_lock = 1 ) THEN
      SELECT *
      INTO p_lpn
      FROM WMS_LICENSE_PLATE_NUMBERS
      WHERE LPN_ID = p_lpn.lpn_id
      AND LICENSE_PLATE_NUMBER = p_lpn.license_plate_number
      FOR UPDATE;
    ELSE
      SELECT *
      INTO p_lpn
      FROM WMS_LICENSE_PLATE_NUMBERS
      WHERE LPN_ID = p_lpn.lpn_id
      AND LICENSE_PLATE_NUMBER = p_lpn.license_plate_number;
    END IF;

    RETURN T;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
    RETURN F;
  WHEN OTHERS THEN
    RETURN F;
END Validate_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

FUNCTION Validate_LPN (
  p_organization_id IN NUMBER
, p_lpn_id          IN NUMBER
, p_validation_type IN VARCHAR2
) RETURN NUMBER IS
l_api_name    CONSTANT VARCHAR2(30) := 'Validate_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

CURSOR Nested_LPN_Cursor IS
  SELECT lpn_id
    FROM wms_license_plate_numbers
   WHERE outermost_lpn_id = p_lpn_id;

lpn_rec         Nested_LPN_Cursor%ROWTYPE;
l_lpn_is_valid  NUMBER := WMS_CONTAINER_PVT.F;
l_parent_lpn_id NUMBER;
BEGIN
  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('orgid=' ||p_organization_id||' lpnid='||p_lpn_id||' type='||p_validation_type, G_MESSAGE);
  END IF;

  IF ( p_validation_type = WMS_CONTAINER_PVT.G_RECONFIGURE_LPN OR
       p_validation_type = WMS_CONTAINER_PVT.G_NO_ONHAND_EXISTS ) THEN
    l_progress := '100';
    -- Check if the lpn_id entered is the outermost
    BEGIN
      SELECT parent_lpn_id INTO l_parent_lpn_id
        FROM wms_license_plate_numbers
       WHERE organization_id = p_organization_id
         AND lpn_id = p_lpn_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF ( l_debug = 1 ) THEN
          mdebug('lpnid='||p_lpn_id|| ' does not exist', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
        fnd_msg_pub.ADD;
        RETURN WMS_CONTAINER_PVT.F;
    END;

    l_progress := '110';
    IF ( l_parent_lpn_id IS NOT NULL ) THEN
        IF ( l_debug = 1 ) THEN
        mdebug('lpnid='||p_lpn_id|| ' is not the outermost LPN', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_LPN_NOT_OUTERMOST');
      fnd_msg_pub.ADD;
      RETURN WMS_CONTAINER_PVT.F;
    END IF;
  END IF;

  l_progress := '200';
  OPEN Nested_LPN_Cursor;
  FETCH Nested_LPN_Cursor INTO lpn_rec;

  l_progress := '210';
  IF ( Nested_LPN_Cursor%FOUND ) THEN
    l_lpn_is_valid := WMS_CONTAINER_PVT.T;
    l_progress := '220';
    WHILE ( l_lpn_is_valid = WMS_CONTAINER_PVT.T AND Nested_LPN_Cursor%FOUND ) LOOP
      IF ( p_validation_type = WMS_CONTAINER_PVT.G_RECONFIGURE_LPN ) THEN
        -- Check if the lpn is on a reservation
        BEGIN
          SELECT WMS_CONTAINER_PVT.F
            INTO l_lpn_is_valid
            FROM mtl_reservations
           WHERE organization_id = p_organization_id
             AND lpn_id = lpn_rec.lpn_id
             AND rownum < 2;
           IF ( l_debug = 1 ) THEN
             mdebug('lpnid='||lpn_rec.lpn_id|| ' is reserved', G_ERROR);
           END IF;
           fnd_message.set_name('INV', 'INV_LPN_RESERVED');
           fnd_msg_pub.ADD;
           EXIT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL; --no rows fround everything is okay
        END;

        -- check to see if there are pending transactions or the
        -- lpn has been allocatied
        BEGIN
          SELECT WMS_CONTAINER_PVT.F
            INTO l_lpn_is_valid
            FROM mtl_material_transactions_temp
           WHERE organization_id = p_organization_id
             AND ( ALLOCATED_LPN_ID = lpn_rec.lpn_id OR
                   lpn_id = lpn_rec.lpn_id OR
                   content_lpn_id = lpn_rec.lpn_id OR
                   transfer_lpn_id = lpn_rec.lpn_id )
             AND rownum < 2;
           IF ( l_debug = 1 ) THEN
             mdebug('lpnid='||lpn_rec.lpn_id||' is in a pending MMTT transaction', G_ERROR);
           END IF;
           fnd_message.set_name('WMS', 'INV_PART_OF_PENDING_TXN');
           fnd_message.set_token('ENTITY1','INV_LPN');
           fnd_msg_pub.ADD;
           EXIT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL; --no rows fround everything is okay
        END;
      END IF;

      IF ( p_validation_type = WMS_CONTAINER_PVT.G_NO_ONHAND_EXISTS ) THEN
        -- check to see if there is any onhand quantity associated with lpn
        BEGIN
          SELECT WMS_CONTAINER_PVT.F
            INTO l_lpn_is_valid
            FROM mtl_onhand_quantities_detail
           WHERE organization_id = p_organization_id
             AND lpn_id = lpn_rec.lpn_id
             AND rownum < 2;
           IF ( l_debug = 1 ) THEN
             mdebug('lpnid='||lpn_rec.lpn_id||' has onhand associated with it', G_ERROR);
           END IF;
           fnd_message.set_name('WMS', 'WMS_CONT_NON_EMPTY_LPN');
           fnd_msg_pub.ADD;
           EXIT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL; --no rows fround everything is okay
        END;

        --check to see if there are any serial numbers associated with lpn
        BEGIN
          SELECT WMS_CONTAINER_PVT.F
            INTO l_lpn_is_valid
            FROM mtl_serial_numbers
           WHERE current_organization_id = p_organization_id
             AND lpn_id = lpn_rec.lpn_id
             AND rownum < 2;
           IF ( l_debug = 1 ) THEN
             mdebug('lpnid='||lpn_rec.lpn_id|| ' has serial numbers associated with it', G_ERROR);
           END IF;
           fnd_message.set_name('WMS', 'WMS_CONT_NON_EMPTY_LPN');
           fnd_msg_pub.ADD;
           EXIT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL; --no rows fround everything is okay
        END;
      END IF;
      FETCH Nested_LPN_Cursor INTO lpn_rec;
    END LOOP;
  END IF;
  l_progress := '300';
  CLOSE Nested_LPN_Cursor;

  IF ( l_debug = 1 ) THEN
    mdebug(l_api_name || ' Exited return='||l_lpn_is_valid, 1);
  END IF;
  RETURN l_lpn_is_valid;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress= '||l_progress||'SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;
    RETURN WMS_CONTAINER_PVT.F;
END Validate_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Merge_Up_LPN (
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Merge_Up_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_contents_tbl  WMS_CONTAINER_PUB.WMS_CONTAINER_TBL_TYPE;
l_return_status NUMBER;
l_trx_tmp_id    NUMBER;
l_ser_tmp_id    NUMBER;
l_trx_hdr_id    NUMBER;
l_converted_qty NUMBER;
l_primary_uom   VARCHAR2(3);

l_insert_item_rec BOOLEAN := FALSE;
l_insert_lot_rec  BOOLEAN := FALSE;
l_insert_ser_rec  BOOLEAN := FALSE;

-- Variables for call to Inv_Serial_Info
l_range_is_done        BOOLEAN := FALSE;
l_serial_def_flag      BOOLEAN;
l_serial_prefix        VARCHAR2(30);
l_fm_serial            VARCHAR2(30);
l_to_serial            VARCHAR2(30);
l_serial_suffix        NUMBER;
l_serial_suffix_length NUMBER := 0;
l_temp_num             NUMBER;
v_acct_period_id       NUMBER;
v_open_past_period     BOOLEAN := FALSE;
l_label_status         VARCHAR2(100);
l_label_return         VARCHAR2(1);

CURSOR Nested_LPN_cur IS
  SELECT lpn_id, lpn_context, subinventory_code, locator_id, parent_lpn_id
    FROM wms_license_plate_numbers
   WHERE lpn_id <> p_outermost_lpn_id
   START WITH lpn_id = p_outermost_lpn_id
 CONNECT BY parent_lpn_id = PRIOR lpn_id;

CURSOR LPN_item_cur (p_parent_lpn_id NUMBER)  IS
  SELECT inventory_item_id, quantity, uom_code, revision, lot_number, quantity lot_quantity,
         cost_group_id, serial_summary_entry
         ,secondary_quantity, secondary_uom_code --INVCONV kkillams
    FROM wms_lpn_contents
   WHERE organization_id = p_organization_id
     AND parent_lpn_id = p_parent_lpn_id
   ORDER BY inventory_item_id, revision, cost_group_id, lot_number;

l_crnt_item_rec LPN_item_cur%ROWTYPE;
l_next_item_rec LPN_item_cur%ROWTYPE;

CURSOR LPN_serial_cur (p_lpn_id NUMBER, p_item_id NUMBER, p_revision VARCHAR2, p_lot_number VARCHAR2) IS
  SELECT serial_number
    FROM mtl_serial_numbers
   WHERE current_organization_id = p_organization_id
     AND inventory_item_id = p_item_id
     AND lpn_id = p_lpn_id
     AND NVL(revision, '@') = NVL(p_revision, '@')
     AND NVL(lot_number, '@') = NVL(p_lot_number, '@');

l_crnt_ser_rec LPN_serial_cur%ROWTYPE;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT MERGE_UP_LPN;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('orgid=' ||p_organization_id||' lpnid='||p_outermost_lpn_id, G_MESSAGE);
  END IF;

  -- get the account period ID
  invttmtx.tdatechk(p_organization_id, SYSDATE, v_acct_period_id, v_open_past_period);

  SELECT mtl_material_transactions_s.nextval
  INTO l_trx_hdr_id
  FROM DUAL;

  FOR Nested_LPN_rec IN Nested_LPN_cur LOOP
    -- Insert an 'UNPACK' transaction of child LPN from parent LPN into
    -- MTL_MATERIAL_TRANSACTIONS_TEMP using standard MMTT insert API
    l_return_status := INV_TRX_UTIL_PUB.INSERT_LINE_TRX (
      p_trx_hdr_id      => l_trx_hdr_id
    , p_item_id         => -1
    , p_org_id          => p_organization_id
    , p_subinv_code     => Nested_LPN_rec.subinventory_code
    , p_locator_id      => Nested_LPN_rec.locator_id
    , p_trx_src_type_id => INV_GLOBALS.G_SourceType_Inventory
    , p_trx_action_id   => INV_GLOBALS.G_Action_ContainerUnPack
    , p_trx_type_id     => INV_GLOBALS.G_TYPE_CONTAINER_UNPACK
    , p_trx_qty         => 1
    , p_pri_qty         => 1
    , p_uom             => 'Ea'
    , p_date            => SYSDATE
    , p_user_id         => fnd_global.user_id
    , p_from_lpn_id     => Nested_LPN_rec.parent_lpn_id
    , p_cnt_lpn_id      => Nested_LPN_rec.lpn_id
    , x_trx_tmp_id      => l_trx_tmp_id
    , x_proc_msg        => x_msg_data );
    IF ( l_return_status <> 0) THEN
       IF (l_debug = 1) THEN
         mdebug('Insert_Line_Trx failed :'||x_msg_data,  1);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 1) THEN
      mdebug('Inserted unpack hdrid='||l_trx_hdr_id||' tempid='||l_trx_tmp_id||' lpn='||Nested_LPN_rec.lpn_id||' parlpn='|| Nested_LPN_rec.parent_lpn_id, 4);
    END IF;

    OPEN LPN_item_cur( Nested_LPN_rec.lpn_id );
    FETCH LPN_item_cur INTO l_next_item_rec;

    IF ( LPN_item_cur%FOUND ) THEN
      -- Create new trx temp id
      SELECT mtl_material_transactions_s.nextval
      INTO l_trx_tmp_id
      FROM DUAL;

      -- Find the primary uom
      SELECT primary_uom_code
        INTO l_primary_uom
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = l_next_item_rec.inventory_item_id;

      LOOP
        l_crnt_item_rec := l_next_item_rec;
        EXIT WHEN l_crnt_item_rec.inventory_item_id IS NULL;
        FETCH LPN_item_cur INTO l_next_item_rec;

        IF ( LPN_item_cur%NOTFOUND ) THEN
          l_next_item_rec.inventory_item_id := NULL;
          l_next_item_rec.revision          := NULL;
        END IF;

        IF (l_debug = 1) THEN
          mdebug('critm='||l_crnt_item_rec.inventory_item_id||' rv='||l_crnt_item_rec.revision||' lot='||l_crnt_item_rec.lot_number||' qty='||l_crnt_item_rec.quantity||' uom='||l_crnt_item_rec.uom_code||' lqty='||l_crnt_item_rec.lot_quantity);
          mdebug('sec uom='||l_crnt_item_rec.secondary_uom_code||' sec qty='||l_crnt_item_rec.secondary_quantity, 4);
          mdebug('nxitm='||l_next_item_rec.inventory_item_id||' rv='||l_next_item_rec.revision||' lot='||l_next_item_rec.lot_number||' qty='||l_next_item_rec.quantity||' uom='||l_next_item_rec.uom_code||' lqty='||l_next_item_rec.lot_quantity);
          mdebug('sec uom='||l_next_item_rec.secondary_uom_code||' sec qty='||l_next_item_rec.secondary_quantity, 4);
        END IF;

        IF ( l_crnt_item_rec.inventory_item_id = l_next_item_rec.inventory_item_id AND
             NVL(l_crnt_item_rec.revision, '@') = NVL(l_next_item_rec.revision, '@') AND
             NVL(l_crnt_item_rec.cost_group_id, -9) = NVL(l_next_item_rec.cost_group_id, -9) ) THEN
          -- Will be adding quantities, make sure the uoms are the same
          IF ( l_crnt_item_rec.uom_code <> l_next_item_rec.uom_code ) THEN
            l_next_item_rec.quantity := Convert_UOM(l_crnt_item_rec.inventory_item_id, l_next_item_rec.quantity, l_next_item_rec.uom_code, l_next_item_rec.uom_code);
            l_next_item_rec.uom_code := l_crnt_item_rec.uom_code;
          END IF;
          -- These to records can go into the same MMTT line add the quantities
          l_next_item_rec.quantity := l_next_item_rec.quantity + l_crnt_item_rec.quantity;

          IF ( l_crnt_item_rec.lot_number = l_next_item_rec.lot_number ) THEN
            l_next_item_rec.lot_quantity := l_next_item_rec.quantity + l_crnt_item_rec.lot_quantity;
          ELSIF ( l_crnt_item_rec.lot_number IS NOT NULL ) THEN
            l_insert_lot_rec := TRUE;
          END IF;
        ELSE -- Different item/rev need to make MMTT
          l_insert_item_rec := TRUE;
          -- If lot controlled, will need to insert lot record too
          IF ( l_crnt_item_rec.lot_number IS NOT NULL ) THEN
            l_insert_lot_rec := TRUE;
          ELSIF ( l_crnt_item_rec.serial_summary_entry = 1 ) THEN
            l_insert_ser_rec := TRUE;
            l_ser_tmp_id     := l_trx_tmp_id;
          END IF;
        END IF;

        IF ( l_insert_lot_rec ) THEN
          IF ( l_crnt_item_rec.uom_code <> l_primary_uom ) THEN
            l_converted_qty := Convert_UOM(l_crnt_item_rec.inventory_item_id, l_crnt_item_rec.quantity, l_crnt_item_rec.uom_code, l_primary_uom);
          ELSE
            l_converted_qty := l_crnt_item_rec.lot_quantity;
          END IF;
          -- Insert record into MTL_TRANSACTIONS_LOTS_TEMP
          l_return_status := INV_TRX_UTIL_PUB.Insert_Lot_Trx(
            p_trx_tmp_id    => l_trx_tmp_id
          , p_user_id       => fnd_global.user_id
          , p_lot_number    => l_crnt_item_rec.lot_number
          , p_trx_qty       => l_crnt_item_rec.lot_quantity
          , p_pri_qty       => l_converted_qty
          , p_secondary_qty => l_crnt_item_rec.secondary_quantity --INVCONV kkillams
          , p_secondary_uom => l_crnt_item_rec.secondary_uom_code --INVCONV kkillams
          , x_ser_trx_id    => l_ser_tmp_id
          , x_proc_msg      => x_msg_data );
          IF ( l_return_status <> 0 ) THEN
            IF (l_debug = 1) THEN
              mdebug('Insert_Lot_Trx failed :'||x_msg_data,  1);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (l_debug = 1) THEN
            mdebug('Inserted lot tempid='||l_trx_tmp_id||' lot='||l_crnt_item_rec.lot_number||' qty='||l_crnt_item_rec.lot_quantity||' stmpid='||l_ser_tmp_id, 4);
          END IF;

          -- May need to insert serials if item is serial controlled
          IF ( l_crnt_item_rec.serial_summary_entry = 1 ) THEN
            l_insert_ser_rec := TRUE;
          END IF;
          l_insert_lot_rec := FALSE;
        END IF;

        -- Insert record into MTL_SERIAL_NUMBERS_TEMP
        IF ( l_insert_ser_rec ) THEN
          OPEN LPN_serial_cur(Nested_LPN_rec.lpn_id, l_crnt_item_rec.inventory_item_id,
                              l_crnt_item_rec.revision, l_crnt_item_rec.lot_number);
          FETCH LPN_serial_cur INTO l_crnt_ser_rec;
          l_fm_serial:= l_crnt_ser_rec.serial_number;
          l_to_serial:= l_crnt_ser_rec.serial_number;
          LOOP
            FETCH LPN_serial_cur INTO l_crnt_ser_rec;
            IF (l_debug = 1) THEN
              mdebug('current serial='||l_crnt_ser_rec.serial_number, 4);
            END IF;

            -- Algorithm to try and flatten serial ranges as much as possible
            IF ( LPN_serial_cur%FOUND AND l_serial_prefix IS NULL ) THEN
              l_serial_def_flag := MTL_SERIAL_CHECK.Inv_Serial_Info(
                                   l_fm_serial, l_to_serial, l_serial_prefix,
                                   l_temp_num, l_serial_suffix, l_serial_suffix, l_return_status);
              IF ( l_return_status <> 0 ) THEN
                IF (l_debug = 1) THEN
                  mdebug('Inv_Serial_Info failed', 1);
                END IF;
                FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SER');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              -- calculate the length of the serial number suffix
              l_serial_suffix_length := LENGTH(l_fm_serial) - LENGTH(l_serial_prefix);
              l_serial_suffix := l_serial_suffix + 1;

              IF (l_debug = 1) THEN
                mdebug('New prefix='||l_serial_prefix||' suffix='||l_serial_suffix||' sfxlgth='||l_serial_suffix_length, 1);
              END IF;
            END IF;

            IF ( l_crnt_ser_rec.serial_number = l_serial_prefix||LPAD(TO_CHAR(l_serial_suffix), l_serial_suffix_length, '0') ) THEN
              -- The serials are contiguous, set l_to_serial to new serial
              l_to_serial     := l_crnt_ser_rec.serial_number;
              l_serial_suffix := l_serial_suffix + 1;
            ELSE
              l_range_is_done := TRUE;
            END IF;

            mdebug('expected next sn='||l_serial_prefix||LPAD(TO_CHAR(l_serial_suffix), l_serial_suffix_length, '0'), 1);

            IF ( l_range_is_done OR LPN_serial_cur%NOTFOUND ) THEN
              IF (l_debug = 1) THEN
                mdebug('Insert ser tempid='||l_ser_tmp_id||' fmsn='||l_fm_serial||' tosn='||l_to_serial, 4);
              END IF;
              -- Range finished or last serial processed, insert serial with API and reset from serial
              l_return_status := INV_TRX_UTIL_PUB.Insert_Ser_Trx (
                p_trx_tmp_id => l_ser_tmp_id
              , p_user_id    => fnd_global.user_id
              , p_fm_ser_num => l_fm_serial
              , p_to_ser_num => l_to_serial
              , x_proc_msg   => x_msg_data );
              IF ( l_return_status <> 0 ) THEN
                IF (l_debug = 1) THEN
                  mdebug('Insert_Ser_Trx failed :'||x_msg_data,  1);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              -- reset serial variables
              l_fm_serial:= l_crnt_ser_rec.serial_number;
              l_to_serial:= l_crnt_ser_rec.serial_number;
              l_serial_prefix := NULL;
              l_range_is_done := FALSE;
            END IF;

            EXIT WHEN LPN_serial_cur%NOTFOUND;
          END LOOP;
          CLOSE LPN_serial_cur;
          -- Reset serial variables
          l_insert_ser_rec := FALSE;
        END IF;

        IF ( l_insert_item_rec ) THEN
          IF (l_debug = 1) THEN
            mdebug('Insert split tmpid='||l_trx_tmp_id||' plpn='||Nested_LPN_rec.parent_lpn_id||' itm='||l_crnt_item_rec.inventory_item_id||' rev='||l_crnt_item_rec.revision||' qty='||l_crnt_item_rec.quantity||' cg='||l_crnt_item_rec.cost_group_id, 4);
          END IF;

          IF ( l_crnt_item_rec.uom_code <> l_primary_uom ) THEN
            l_converted_qty := Convert_UOM(l_crnt_item_rec.inventory_item_id, l_crnt_item_rec.quantity, l_crnt_item_rec.uom_code, l_primary_uom);
          ELSE
            l_converted_qty := l_crnt_item_rec.quantity;
          END IF;

          -- MTL_MATERIAL_TRANSACTIONS_TEMP cannot use API because
          -- need to use sepecific transaction temp id
          INSERT INTO mtl_material_transactions_temp (
            transaction_header_id
          , transaction_temp_id
          , process_flag
          , creation_date
          , created_by
          , last_update_date
          , last_updated_by
          , last_update_login
          , transaction_date
          , organization_id
          , subinventory_code
          , locator_id
          , inventory_item_id
          , revision
          , cost_group_id
          , transaction_source_type_id
          , transaction_action_id
          , transaction_type_id
          , transaction_quantity
          , primary_quantity
          , transaction_uom
          , lpn_id
          , transfer_lpn_id
          , acct_period_id
          , secondary_transaction_quantity   --INCONV kkillams
          , secondary_uom_code               --INCONV kkillamsb
          ) VALUES (
            l_trx_hdr_id
          , l_trx_tmp_id
          , 'Y'
          , SYSDATE
          , fnd_global.user_id
          , SYSDATE
          , fnd_global.user_id
          , fnd_global.user_id
          , SYSDATE
          , p_organization_id
          , Nested_LPN_rec.subinventory_code
          , Nested_LPN_rec.locator_id
          , l_crnt_item_rec.inventory_item_id
          , l_crnt_item_rec.revision
          , l_crnt_item_rec.cost_group_id
          , INV_GLOBALS.G_SourceType_Inventory
          , INV_GLOBALS.G_Action_ContainerSplit
          , INV_GLOBALS.G_TYPE_CONTAINER_SPLIT
          , l_crnt_item_rec.quantity
          , l_converted_qty
          , l_crnt_item_rec.uom_code
          , Nested_LPN_rec.lpn_id
          , p_outermost_lpn_id
          , v_acct_period_id
          , l_crnt_item_rec.secondary_quantity --INCONV kkillams
          , l_crnt_item_rec.secondary_uom_code --INCONV kkillams
          );

          -- Done with this item/revision/costgroup combo need new trx temp id
          SELECT mtl_material_transactions_s.nextval
            INTO l_trx_tmp_id
            FROM DUAL;

          -- If next record is for a new item need to find the primary uom
          IF ( l_crnt_item_rec.inventory_item_id <> l_next_item_rec.inventory_item_id ) THEN
            SELECT primary_uom_code
              INTO l_primary_uom
              FROM mtl_system_items
             WHERE organization_id = p_organization_id
               AND inventory_item_id = l_crnt_item_rec.inventory_item_id;
          END IF;
          l_insert_item_rec := FALSE;
        END IF;
      END LOOP;
    END IF;
    CLOSE LPN_item_cur;
  END LOOP; -- Nested_LPN_cur

  IF (l_debug = 1) THEN
    mdebug('Call to TM hdrid='||l_trx_hdr_id, 4);
  END IF;
  l_return_status := INV_LPN_TRX_PUB.PROCESS_LPN_TRX (
                       p_trx_hdr_id => l_trx_hdr_id
                     , x_proc_msg   => x_msg_data
                     , p_proc_mode  => 1
                     , p_atomic     => fnd_api.g_true );
  IF ( l_return_status <> 0 ) THEN
    IF (l_debug = 1) THEN
      mdebug('PROCESS_LPN_TRX Failed msg: '||x_msg_data, 1);
    END IF;
      RAISE fnd_api.g_exc_error;
  END IF;

  INV_LABEL.PRINT_LABEL_MANUAL_WRAP(
    x_return_status      => l_label_return
  , x_msg_count          => x_msg_count
  , x_msg_data           => x_msg_data
  , x_label_status       => l_label_status
  , p_business_flow_code => 36
  , p_lpn_id             => p_outermost_lpn_id );

  IF ( l_debug = 1 ) THEN
    mdebug('Called INV_LABEL.PRINT_LABEL, return_status='||l_label_return||' label stat='||l_label_status, 1);
  END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        mdebug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    ROLLBACK TO MERGE_UP_LPN;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_API_FAILURE');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Merge_Up_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Break_Down_LPN(
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Break_Down_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

CURSOR nested_lpn_cursor IS
  SELECT rowid, lpn_id, parent_lpn_id, subinventory_code, locator_id
  FROM WMS_LICENSE_PLATE_NUMBERS
  WHERE lpn_id <> p_outermost_lpn_id
  START WITH lpn_id = p_outermost_lpn_id
  CONNECT BY parent_lpn_id = PRIOR lpn_id;

l_return_status NUMBER;
l_trx_tmp_id    NUMBER;
l_trx_hdr_id    NUMBER;
l_label_count   NUMBER := 1;
l_label_status  VARCHAR2(100);
l_label_return  VARCHAR2(1);
l_input_param_rec_tbl INV_LABEL.input_parameter_rec_type;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT BREAK_DOWN_LPN;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('orgid=' ||p_organization_id||' lpnid='||p_outermost_lpn_id, G_MESSAGE);
  END IF;

  SELECT mtl_material_transactions_s.nextval
  INTO l_trx_hdr_id
  FROM DUAL;

  --Every nested lpn will need to be deconsolidated from the outermost lpn,
  FOR lpn_rec IN nested_lpn_cursor LOOP
    -- Insert an 'UNPACK' transaction of child LPN from parent LPN into
    -- MTL_MATERIAL_TRANSACTIONS_TEMP using standard MMTT insert API
    l_return_status := INV_TRX_UTIL_PUB.INSERT_LINE_TRX (
      p_trx_hdr_id      => l_trx_hdr_id
    , p_item_id         => -1
    , p_org_id          => p_organization_id
    , p_subinv_code     => lpn_rec.subinventory_code
    , p_locator_id      => lpn_rec.locator_id
    , p_trx_src_type_id => INV_GLOBALS.G_SourceType_Inventory
    , p_trx_action_id   => INV_GLOBALS.G_Action_ContainerUnPack
    , p_trx_type_id     => INV_GLOBALS.G_TYPE_CONTAINER_UNPACK
    , p_trx_qty         => 1
    , p_pri_qty         => 1
    , p_uom             => 'Ea'
    , p_date            => SYSDATE
    , p_user_id         => fnd_global.user_id
    , p_from_lpn_id     => lpn_rec.parent_lpn_id
    , p_cnt_lpn_id      => lpn_rec.lpn_id
    , x_trx_tmp_id      => l_trx_tmp_id
    , x_proc_msg        => x_msg_data );
    IF (l_debug = 1) THEN
      mdebug('Inserted unpack tempid='||l_trx_tmp_id||' lpn='||lpn_rec.lpn_id||' parlpn='|| lpn_rec.parent_lpn_id, 4);
    END IF;
    -- Add entry for this lpn to print label
    l_input_param_rec_tbl(l_label_count).lpn_id := lpn_rec.lpn_id;
    l_label_count := l_label_count + 1;
  END LOOP;

  IF (l_debug = 1) THEN
    mdebug('Call to TM hdrid='||l_trx_hdr_id, 4);
  END IF;
  l_return_status := INV_LPN_TRX_PUB.PROCESS_LPN_TRX (
                       p_trx_hdr_id => l_trx_hdr_id
                     , x_proc_msg   => x_msg_data
                     , p_proc_mode  => 1
                     , p_atomic     => fnd_api.g_true );
  IF ( l_return_status <> 0 ) THEN
    IF (l_debug = 1) THEN
      mdebug('PROCESS_LPN_TRX Failed msg: '||x_msg_data, 1);
    END IF;
      RAISE fnd_api.g_exc_error;
  END IF;

  -- Add entry for this lpn to print label for outermost lpn
  l_input_param_rec_tbl(l_label_count).lpn_id := p_outermost_lpn_id;

  INV_LABEL.PRINT_LABEL (
    x_return_status      => l_label_return
  , x_msg_count          => x_msg_count
  , x_msg_data           => x_msg_data
  , x_label_status       => l_label_status
  , p_api_version        => 1.0
  , p_print_mode         => 2
  , p_business_flow_code => 36
  , p_input_param_rec    => l_input_param_rec_tbl ) ;

  IF ( l_debug = 1 ) THEN
    mdebug('Called INV_LABEL.PRINT_LABEL, return_status='||l_label_return||' label stat='||l_label_status, 1);
  END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        mdebug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    ROLLBACK TO BREAK_DOWN_LPN;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_API_FAILURE');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Break_Down_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Initialize_LPN (
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
)IS
l_api_name    CONSTANT VARCHAR2(30) := 'Initialize_LPNs';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

CURSOR nested_lpn_cursor IS
  SELECT rowid, lpn_id
    FROM wms_license_plate_numbers
   WHERE organization_id = p_organization_id
     AND outermost_lpn_id = p_outermost_lpn_id;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT INITIALIZE_LPN;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, 1);
    mdebug('orgid=' ||p_organization_id||' lpnid='||p_outermost_lpn_id, G_MESSAGE);
  END IF;

  FOR lpn_rec IN nested_lpn_cursor LOOP
    IF (l_debug = 1) THEN
      mdebug('Initializing LPN with lpnid='||lpn_rec.lpn_id, G_MESSAGE);
    END IF;

    -- Remove all contents from WLC
    DELETE FROM wms_lpn_contents
    WHERE parent_lpn_id = lpn_rec.lpn_id;

    -- Reset lpn properties to pregenerated
    UPDATE wms_license_plate_numbers
       SET lpn_context = LPN_CONTEXT_PREGENERATED
         , subinventory_code = NULL
         , locator_id = NULL
         , parent_lpn_id = NULL
         , outermost_lpn_id = lpn_id
         , content_volume = NULL
         , content_volume_uom_code = NULL
         , gross_weight = tare_weight
         , gross_weight_uom_code = tare_weight_uom_code
         , last_update_date = SYSDATE
         , last_updated_by = fnd_global.user_id
     WHERE rowid = lpn_rec.rowid;
  END LOOP;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        mdebug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    ROLLBACK TO INITIALIZE_LPN;
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Initialize_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE plan_delivery(p_lpn_id        IN NUMBER,
                        x_return_status OUT nocopy VARCHAR2,
                        x_msg_data      OUT nocopy VARCHAR2,
                        x_msg_count     OUT nocopy NUMBER) IS

   l_action_prms            wsh_interface_ext_grp.del_action_parameters_rectype;
   l_delivery_id_tab        wsh_util_core.id_tab_type;
   l_delivery_out_rec       wsh_interface_ext_grp.del_action_out_rec_type;
   l_delivery_id            NUMBER;

   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_debug                  NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SELECT wda.delivery_id
     INTO l_delivery_id
     FROM wsh_delivery_details_ob_grp_v wdd,
          wsh_delivery_assignments wda
     WHERE wdd.lpn_id IN (SELECT lpn_id FROM wms_license_plate_numbers
                          WHERE outermost_lpn_id = (SELECT outermost_lpn_id
                                                    FROM wms_license_plate_numbers
                                                    WHERE lpn_id = p_lpn_id)
                          AND lpn_context = 11)
     AND wdd.released_status = 'X'  --  For LPN reuse ER : 6845650
     AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
     AND ROWNUM = 1;

   IF l_delivery_id IS NOT NULL THEN
      l_action_prms.caller := 'WMS_DLMG';
      l_action_prms.event := wsh_interface_ext_grp.g_start_of_packing;
      l_action_prms.action_code := 'ADJUST-PLANNED-FLAG';

      l_delivery_id_tab(1) := l_delivery_id;

      wsh_interface_ext_grp.delivery_action
        (p_api_version_number     => 1.0,
         p_init_msg_list          => fnd_api.g_false,
         p_commit                 => fnd_api.g_false,
         p_action_prms            => l_action_prms,
         p_delivery_id_tab        => l_delivery_id_tab,
         x_delivery_out_rec       => l_delivery_out_rec,
         x_return_status          => l_return_status,
         x_msg_count              => l_msg_count,
         x_msg_data               => l_msg_data);

      IF x_return_status = 'E' THEN
         RAISE fnd_api.g_exc_error;
       ELSIF x_return_status = 'U' THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

   x_return_status := 'S';

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := 'E';
      mdebug('Plan Delivery: Error: E', 1);
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := 'U';
         mdebug('Plan Delivery: Error: U', 1);
   WHEN OTHERS THEN
      x_return_status := 'U';
      IF (l_debug = 1) THEN
         mdebug('Plan Delivery: Error: ' || Sqlerrm, 1);
      END IF;
END plan_delivery;


-------------------------------------------------
-- Added for LSP Project, bug 9087971
-- NAME
-- PROCEDURE get_item_from_lpn
-------------------------------------------------
-- Purpose
-- 		Following procedure will get the concatenated item segments from the given LPN.
--
-- Input Parameters
--    p_org			Organization ID
--	p_lpn_id		LPN ID
--	p_lpn_context	Context of the LPN
--
-- Output Parameters
--	x_item		Item name

PROCEDURE get_item_from_lpn
  (
    p_org         IN NUMBER,
    p_lpn_id      IN NUMBER,
    p_lpn_context IN NUMBER,
    x_item OUT NOCOPY VARCHAR2 )
IS
  l_api_name    CONSTANT VARCHAR2(30)  := 'get_item_from_lpn';
  l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_lpn_context NUMBER;
  l_concatenated_segments mtl_system_items_b_kfv.concatenated_segments%TYPE;
BEGIN

  IF (l_debug = 1) THEN
    mdebug(' p_org : ' || p_org || ' p_lpn_id : ' || p_lpn_id || ' p_lpn_context : ' || p_lpn_context, G_INFO);
  END IF;

  if p_lpn_context is null THEN
    SELECT lpn_context INTO l_lpn_context
    FROM wms_license_plate_numbers
    WHERE lpn_id = p_lpn_id
    AND organization_id = p_org;
  else
    l_lpn_context := p_lpn_context;
  end if;


    IF l_lpn_context = 8 THEN
      SELECT msikfv.concatenated_segments
      INTO l_concatenated_segments
      FROM mtl_material_transactions_temp mmtt,
        mtl_system_items_b_kfv msikfv
      WHERE transfer_lpn_id IN
        (SELECT lpn_id
        FROM wms_license_plate_numbers
          START WITH lpn_id       = p_lpn_id
          CONNECT BY PRIOR lpn_id = parent_lpn_id
        )
      AND mmtt.inventory_item_id = msikfv.inventory_item_id
      AND mmtt.organization_id   = msikfv.organization_id
      AND msikfv.organization_id = p_org
      AND rownum                 = 1;
    ELSE
      SELECT msikfv.concatenated_segments
      INTO l_concatenated_segments
      FROM WMS_LPN_CONTENTS wlc,
        mtl_system_items_b_kfv msikfv
      WHERE wlc.parent_lpn_id IN
        (SELECT lpn_id
        FROM wms_license_plate_numbers
          START WITH lpn_id       = p_lpn_id
          CONNECT BY PRIOR lpn_id = parent_lpn_id
        )
      AND wlc.inventory_item_id  = msikfv.inventory_item_id
      AND wlc.organization_id    = msikfv.organization_id
      AND msikfv.organization_id = p_org
      AND rownum                 = 1;
    END IF;

  x_item := l_concatenated_segments;

  IF (l_debug = 1) THEN
    mdebug(' l_concatenated_segments : ' || l_concatenated_segments, G_INFO);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
  END IF;
END get_item_from_lpn;


-- End of package
END WMS_CONTAINER_PVT;

/
