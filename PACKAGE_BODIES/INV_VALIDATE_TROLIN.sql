--------------------------------------------------------
--  DDL for Package Body INV_VALIDATE_TROLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_VALIDATE_TROLIN" AS
/* $Header: INVLTRLB.pls 120.9.12010000.4 2010/10/13 00:42:25 vissubra ship $ */
--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Validate_Trolin';

g_organization_id      NUMBER;
g_wms_org_flag         BOOLEAN;

-- Line level Validations
-- ---------------------------------------------------------------------

FUNCTION Line ( p_line_id IN NUMBER ) RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    IF p_line_id IS NULL OR p_line_id = FND_API.G_MISS_NUM THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_LINE_ID'),FALSE); -- ND
            FND_MSG_PUB.Add;
        END IF;
        RETURN F;
    END IF;
    RETURN T;
END Line;

-- ---------------------------------------------------------------------
FUNCTION Line_Number ( p_line_number IN NUMBER,
		       p_header_id IN NUMBER,
		       p_org IN inv_validate_trohdr.ORG ) RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
l_return_value		      BOOLEAN;
l_request_number              VARCHAR2(30);
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_line_number IS NULL OR p_line_number = FND_API.G_MISS_NUM THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_LINE_NUMBER'),FALSE); -- ND
      FND_MSG_PUB.Add;
    END IF;
    RETURN F;
  END IF;
  l_return_value :=INV_Transfer_Order_PVT.Unique_Line(
                p_org.organization_id
              , p_header_id
              , p_line_number);
  IF l_return_value then
    RETURN T;
  ELSE
    --Bug #4347016
    --If the line number is not unique display an error message
    FND_MESSAGE.SET_NAME('INV','INV_ALREADY_EXISTS');
    FND_MESSAGE.SET_TOKEN('ENTITY',FND_MESSAGE.GET_STRING('INV','INV_LINE_NUMBER'),FALSE);
    FND_MSG_PUB.Add;
	  RETURN F;
  END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	--inv_debug.message('in when no_data_found');
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','LINE_NUMBER'),FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RETURN F;
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Line_Number;

-- ---------------------------------------------------------------------
FUNCTION Line_Status ( p_line_status IN NUMBER ) RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF p_line_status IS NULL OR p_line_status = FND_API.G_MISS_NUM THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_LINE_STATUS'),FALSE); -- ND
            FND_MSG_PUB.Add;
        END IF;
        RETURN F;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    MFG_LOOKUPS
    WHERE   LOOKUP_TYPE = 'MTL_TXN_REQUEST_STATUS'
      AND   p_line_status IN (1,7)
      AND   LOOKUP_CODE = p_line_status;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_LINE_STATUS'),FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RETURN F;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Status'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Status;

-- ---------------------------------------------------------------------
FUNCTION Quantity_Delivered ( p_quantity_delivered IN NUMBER ) RETURN NUMBER
IS
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
     RETURN T;
END Quantity_Delivered;

-- ---------------------------------------------------------------------
FUNCTION Quantity_Detailed ( p_quantity_detailed IN NUMBER ) RETURN NUMBER
IS
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
     RETURN T;
END Quantity_Detailed;

-- ---------------------------------------------------------------------
--INVCONV
-- ---------------------------------------------------------------------
FUNCTION Secondary_Quantity_Delivered ( p_secondary_quantity_delivered IN NUMBER ) RETURN NUMBER
IS
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
     RETURN T;
END Secondary_Quantity_Delivered;

-- ---------------------------------------------------------------------
FUNCTION Secondary_Quantity_Detailed ( p_secondary_quantity_detailed IN NUMBER ) RETURN NUMBER
IS
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
     RETURN T;
END Secondary_Quantity_Detailed;

-- ---------------------------------------------------------------------
--INVCONV
--  Procedure Entity
PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trolin_rec                    IN  INV_Move_Order_PUB.Trolin_Rec_Type
,   p_old_trolin_rec                IN  INV_Move_Order_PUB.Trolin_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROLIN_REC
,   p_move_order_type	    	    IN  NUMBER DEFAULT INV_GLOBALS.G_MOVE_ORDER_REQUISITION
)
IS

    CURSOR c_get_jobsch_name
    ( p_wip_entity_id    IN  NUMBER
    , p_organization_id  IN  NUMBER
    ) IS
      SELECT wip_entity_name
        FROM wip_entities
       WHERE wip_entity_id   = p_wip_entity_id
         AND organization_id = p_organization_id;

    CURSOR c_get_item_num
    ( p_item_id  IN  NUMBER
    , p_organization_id  IN  NUMBER
    ) IS
      SELECT concatenated_segments
        FROM mtl_system_items_kfv
       WHERE inventory_item_id = p_item_id
         AND organization_id   = p_organization_id;

l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_start_prefix                VARCHAR2(30);
l_start_number                NUMBER;
l_end_prefix                  VARCHAR2(30);
l_end_number                  NUMBER;
l_unit_effectivity	      NUMBER;
l_cross_unit_number	      NUMBER;
l_unit_effective_item	      NUMBER;
l_dummy 		      NUMBER;
l_debug                       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_errorcode                   NUMBER;
l_temp_bool                   BOOLEAN;
l_quantity                    NUMBER;
l_return_value                BOOLEAN;
--Bug #4777248
l_sub_loc_control             NUMBER;
l_item_loc_control            NUMBER;
l_org_loc_control             NUMBER;
--Bug #4438410
l_sub_lpn_controlled          NUMBER := 0;
l_sub_reservable              NUMBER;
l_wip_entity_name             VARCHAR2(240);
l_item_number                 VARCHAR2(40);

BEGIN

    --  Check required attributes.
    IF  p_trolin_rec.line_id IS NULL THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_id');
            FND_MSG_PUB.Add;
        END IF;
    END IF;

    IF  p_trolin_rec.header_id IS NULL THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Header_Id');
            FND_MSG_PUB.Add;
        END IF;
    END IF;
    --
    --  Check rest of required attributes here.
    --  Return Error if a required attribute is missing.

    IF  p_trolin_rec.inventory_item_id IS NULL THEN
	if( p_move_order_type <> INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY ) then
            l_return_status := FND_API.G_RET_STS_ERROR;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('INV','INV_ENTER_ITEM');
                FND_MSG_PUB.Add;
            END IF;
	elsif( p_move_order_type = INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY AND p_trolin_rec.lpn_id is NULL) then
	    l_return_status := FND_API.G_RET_STS_ERROR;
	    if( FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) then
		FND_MESSAGE.SET_NAME('INV', 'INV_ENTER_ITEM_LPN');
		FND_MSG_PUB.Add;
	    end if;
	end if;
    END IF;

    IF  p_trolin_rec.date_required IS NULL THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_DATE_REQUIRED'),FALSE);
            FND_MSG_PUB.Add;
        END IF;
    END IF;

    IF  p_trolin_rec.quantity IS NULL THEN
	if( p_move_order_type <> INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY ) then
            l_return_status := FND_API.G_RET_STS_ERROR;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('INV','INV_INT_QTYCODE');
                FND_MSG_PUB.Add;
            END IF;
	end if;
    END IF;

    IF  p_trolin_rec.uom_code IS NULL THEN
	if( p_trolin_rec.inventory_item_id is not null and p_move_order_type <> INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY ) then
            l_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','UOM'),FALSE);
                FND_MSG_PUB.Add;
            END IF;
	end if;
    END IF;

    IF p_trolin_rec.lpn_id IS NULL THEN
	if p_move_order_type = INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY and p_trolin_rec.inventory_item_id is null then
	    if( fnd_msg_pub.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)) then
		FND_MESSAGE.SET_NAME('INV', 'INV_ENTER_ITEM_LPN');
		FND_MSG_PUB.Add;
	    end if;
	end if;
    END IF;

    IF  g_transaction_l.transaction_action_id = 1 THEN
        IF  p_trolin_rec.to_account_id IS NULL AND
            p_trolin_rec.transaction_type_id <> INV_GLOBALS.G_TYPE_XFER_ORDER_WIP_ISSUE
	    AND g_item.inventory_asset_flag = 'Y'  THEN
        	-- Added the last condition for bug 2519579
            l_return_status := FND_API.G_RET_STS_ERROR;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Account');
               FND_MSG_PUB.Add;
            END IF;
        END IF;

     ELSIF g_transaction_l.transaction_action_id in (2,28) THEN

        IF p_trolin_rec.organization_id <> nvl(g_organization_id, -1) THEN
           g_organization_id := p_trolin_rec.organization_id;
           l_return_value := INV_CACHE.set_wms_installed(g_organization_id);
           If NOT l_return_value Then
              RAISE fnd_api.g_exc_unexpected_error;
           End If;
           g_wms_org_flag := INV_CACHE.wms_installed;
        END IF;

        IF  p_trolin_rec.to_subinventory_code IS NULL THEN
          --Bug #4347016
          --For the Move Order types Putaway and Subinventory, destination subinventory
          --is not required. Hence Bypass the validation
	        IF (p_move_order_type NOT IN
               (INV_GLOBALS.G_MOVE_ORDER_PUT_AWAY, INV_GLOBALS.G_MOVE_ORDER_SYSTEM)) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','To Subinventory');
              FND_MSG_PUB.Add;
            END IF; --END IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          END IF; --END IF MO type not in Putaway, System)
        END IF;   --END IF sub code is NULL
    END IF;

     --Bug #4777248
    --Validating source and destination subinventories
    --Bug #6271307, skipping validations for Kanban replenishment move orders.

    if ((p_trolin_rec.transaction_type_id = 64) and
        (p_trolin_rec.from_subinventory_code IS NOT NULL) and
	(p_trolin_rec.to_subinventory_code IS NOT NULL) and
  (NVL(p_trolin_rec.reference_type_code,0) <> 1) and
	(p_trolin_rec.from_subinventory_code = p_trolin_rec.to_subinventory_code)) THEN

       SELECT nvl(stock_locator_control_code, 1)
         into l_org_loc_control
         from mtl_parameters
        where organization_id = p_trolin_rec.organization_id;

	if (l_org_loc_control = 1) then
	   l_return_status := FND_API.G_RET_STS_ERROR;

	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('INV','INV_SUB_RESTRICT');
                FND_MSG_PUB.Add;
          END IF;
	else
	     if (l_org_loc_control = 4) then
                select nvl(locator_type,3)
	          into l_sub_loc_control
	          from mtl_secondary_inventories
	         where organization_id = p_trolin_rec.organization_id
                   and secondary_inventory_name = p_trolin_rec.to_subinventory_code;

                if (l_sub_loc_control = 1) THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;

	          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.SET_NAME('INV','INV_SUB_RESTRICT');
                    FND_MSG_PUB.Add;
                  END IF;
                elsif (l_sub_loc_control = 5) THEN
	          select nvl(location_control_code,1)
	            into l_item_loc_control
	            from mtl_system_items_b
	           where organization_id = p_trolin_rec.organization_id
	             and inventory_item_id = p_trolin_rec.inventory_item_id;

	           if (l_item_loc_control = 1) THEN
	             l_return_status := FND_API.G_RET_STS_ERROR;

	             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.SET_NAME('INV','INV_SUB_RESTRICT');
                       FND_MSG_PUB.Add;
                     END IF;
	           end if;
                 end if;
	       end if;
        end if;
     end if;
    --End Bug #4777248

    --Bug #4438410, adding validations for WIP component pick release.
    IF inv_wip_picking_pvt.g_wip_patch_level >= 1159
    THEN
       IF p_trolin_rec.transaction_source_type_id
          = inv_globals.g_sourcetype_inventory
          AND p_move_order_type = inv_globals.g_move_order_mfg_pick
          AND p_trolin_rec.to_subinventory_code is not null
       THEN
            SELECT NVL(lpn_controlled_flag, 0), reservable_type
              INTO l_sub_lpn_controlled, l_sub_reservable
              FROM mtl_secondary_inventories
             WHERE organization_id = p_trolin_rec.organization_id
               AND secondary_inventory_name = p_trolin_rec.to_subinventory_code;

            IF l_sub_reservable = inv_globals.g_subinventory_reservable
            THEN
              -- Get the job or schedule number
              OPEN c_get_jobsch_name( p_trolin_rec.txn_source_id
                                    , p_trolin_rec.organization_id);
              FETCH c_get_jobsch_name INTO l_wip_entity_name;
              CLOSE c_get_jobsch_name;

              -- Get the item number
              OPEN c_get_item_num( p_trolin_rec.inventory_item_id
                                 , p_trolin_rec.organization_id);
              FETCH c_get_item_num INTO l_item_number;
              CLOSE c_get_item_num;

              fnd_message.set_name('INV', 'INV_SUB_RESERVABLE');
              fnd_message.set_token('JOB', l_wip_entity_name);
              fnd_message.set_token('SUB', p_trolin_rec.to_subinventory_code);
              fnd_message.set_token('ITEM', l_item_number);
              fnd_msg_pub.ADD;
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF g_wms_org_flag
               AND l_sub_lpn_controlled = inv_globals.g_subinventory_lpn_controlled
            THEN
               -- Get the job or schedule number
               OPEN c_get_jobsch_name( p_trolin_rec.txn_source_id
                                     , p_trolin_rec.organization_id);
               FETCH c_get_jobsch_name INTO l_wip_entity_name;
               CLOSE c_get_jobsch_name;

               -- Get the item number
               OPEN c_get_item_num( p_trolin_rec.inventory_item_id
                                  , p_trolin_rec.organization_id);
               FETCH c_get_item_num INTO l_item_number;
               CLOSE c_get_item_num;

               fnd_message.set_name('WMS', 'WMS_SUB_LPN_CONTROLLED');
               fnd_message.set_token('JOB', l_wip_entity_name);
               fnd_message.set_token('SUB', p_trolin_rec.to_subinventory_code);
               fnd_message.set_token('ITEM', l_item_number);

               fnd_msg_pub.ADD;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
       END IF; -- end if source type is g_sourcetype_inventory
    END IF;
    --End Bug #4438410

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    --  Check conditionally required attributes here.
    --
    --  Validate attribute dependencies here.
    --
    -- inv_debug.message('TRO: dependency conditions');
    -- validate unit number is the unit number is not null
    IF (p_trolin_Rec.unit_number is NOT NULL) then
        if( nvl(PJM_UNIT_EFF.ENABLED, 'N') = 'Y' ) then
	   if( PJM_UNIT_EFF.UNIT_EFFECTIVE_ITEM(p_trolin_rec.inventory_item_id,
						p_trolin_rec.organization_id) = 'Y') then
	       begin
		  select 1
		  into l_dummy
		  from pjm_unit_numbers_lov_v
		  where unit_number = p_trolin_rec.unit_number;
	       exception
		  when no_data_found then
	 	    FND_MESSAGE.SET_NAME('INV', 'INV_INT_UNITNUMBER');
		    FND_MSG_PUB.ADD;
		    raise FND_API.G_EXC_ERROR;
	       end;
	    end if;
	end if;
    end if;

    IF (p_trolin_rec.serial_number_start IS NOT NULL
         AND p_trolin_rec.serial_number_end IS NULL)
     OR (p_trolin_rec.serial_number_start IS NULL
         AND p_trolin_rec.serial_number_end IS NOT NULL)
    THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       return;
    ELSIF p_trolin_rec.serial_number_start IS NOT NULL
    THEN
      --Bug #2659444
      --Call the procedure mtl_serial_check.inv_serial_info for validating
      --serial prefixes, quantity between serials. (Replaced the existing validations
      --with this call since it was not complete)
      l_temp_bool := mtl_serial_check.inv_serial_info(
              p_from_serial_number  =>  p_trolin_rec.serial_number_start,
	            p_to_serial_number    =>  p_trolin_rec.serial_number_end,
	            x_prefix              =>  l_start_prefix,
	            x_quantity            =>  l_quantity,
	            x_from_number         =>  l_start_number,
	            x_to_number           =>  l_end_number,
	            x_errorcode           =>  l_errorcode);
      IF l_temp_bool = FALSE THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
       return;
      END IF;
    END IF;

    --  Done validating entity
    x_return_status := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        -- inv_debug.message('TRO U: ' || SQLERRM);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trolin_rec                    IN OUT NOCOPY INV_Move_Order_PUB.Trolin_Rec_Type
,   p_trolin_val_rec                IN  INV_Move_Order_PUB.Trolin_Val_Rec_Type
,   p_old_trolin_rec                IN  INV_Move_Order_PUB.Trolin_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROLIN_REC
)
IS
v_locator_control                   NUMBER;
l_return_status                     VARCHAR2(10);
l_temp                              VARCHAR2(10);
l_msg_count                         NUMBER;
l_msg_data                          VARCHAR2(240);
l_keystat_val                       BOOLEAN;
l_combination_id                    NUMBER;
l_project_id                        VARCHAR2(15);
l_task_id                           VARCHAR2(15);
l_chart_of_accounts_id              NUMBER;
l_acct_txn                          NUMBER;
l_found				    VARCHAR2(1);
l_project_id_mil                    VARCHAR2(15);
l_mov_order_type                    NUMBER;
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_pjm                               NUMBER;--Bug#5036174
BEGIN


    x_return_status := FND_API.G_RET_STS_SUCCESS;


     --inv_debug.message('ssia', 'TRO: validating attributes');
    --  Validate trolin attributes

    IF p_trolin_rec.organization_id <> INV_Validate_Trohdr.g_org.organization_id
      THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       return;
    END IF;
     --inv_debug.message('ssia', 'TRO: organization: ' || x_return_status);
     --inv_debug.message('ssia', 'TRO: inventoryItem: '|| p_trolin_val_rec.inventory_item || x_return_status);

    IF  p_trolin_rec.inventory_item_id IS NULL
        AND p_trolin_val_rec.inventory_item IS NOT NULL
    THEN
        p_trolin_rec.inventory_item_id :=  INV_Value_To_Id.Inventory_Item(p_trolin_rec.organization_id,
                                              p_trolin_val_rec.inventory_item);
    END IF;

    IF  p_trolin_rec.transaction_type_id IS NOT NULL and
        ( p_trolin_rec.transaction_type_id <> p_old_trolin_rec.transaction_type_id OR
          p_old_trolin_rec.transaction_type_id IS NULL )
    THEN
        g_transaction_l.transaction_type_id := p_trolin_rec.transaction_type_id;
        IF INV_Validate.Transaction_Type(g_transaction_l) = inv_validate.F THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    /* bug9267446 moved the code after validation of transaction type id */
    IF  p_trolin_rec.inventory_item_id IS NOT NULL AND
        (   p_trolin_rec.inventory_item_id <>
            p_old_trolin_rec.inventory_item_id OR
            p_old_trolin_rec.inventory_item_id IS NULL )
    THEN
       g_item.inventory_item_id := p_trolin_rec.inventory_item_id;
       inv_validate_trohdr.g_org.organization_id := p_trolin_rec.organization_id;
       /* bug9267446 */
      IF  g_transaction_l.transaction_type_id IS NOT NULL THEN
	 IF INV_Validate.Inventory_Item(g_item,inv_validate_trohdr.g_org,g_transaction_l.transaction_type_id) =
	  INV_Validate.F
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
     ELSE
       /* bug9267446 */
       IF INV_Validate.Inventory_Item(g_item,inv_validate_trohdr.g_org) =
       --IF INV_Validate.Inventory_Item(g_item,inv_validate_trohdr.g_org) =
	 INV_Validate.F
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
      END IF;
    END IF;
     --inv_debug.message('ssia', 'TRO: item: ' || x_return_status);



     --inv_debug.message('ssia', 'TRO: created_by: ' || to_char(p_trolin_rec.created_by));
    IF  p_trolin_rec.created_by IS NOT NULL AND
        (   p_trolin_rec.created_by <>
            p_old_trolin_rec.created_by OR
            p_old_trolin_rec.created_by IS NULL )
    THEN
       IF INV_Validate.Created_By(p_trolin_rec.created_by) = inv_validate.F
	 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        END IF;
    END IF;
    --inv_debug.message('ssia', 'TRO: created_by: ' || x_return_status);

    IF  p_trolin_rec.creation_date IS NULL THEN
       p_trolin_rec.creation_date := SYSDATE;
    END IF;
    IF  p_trolin_rec.creation_date IS NOT NULL AND
        (   p_trolin_rec.creation_date <>
            p_old_trolin_rec.creation_date OR
            p_old_trolin_rec.creation_date IS NULL )
    THEN
       IF INV_Validate.Creation_Date(p_trolin_rec.creation_date) =
	 INV_Validate.F
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

     --inv_debug.message('ssia', 'TRO: creation_date: ' || x_return_status);
    IF  p_trolin_rec.date_required IS NOT NULL AND
        (   p_trolin_rec.date_required <>
            p_old_trolin_rec.date_required OR
            p_old_trolin_rec.date_required IS NULL )
    THEN
       IF INV_Validate_Trohdr.Date_Required(p_trolin_rec.date_required) =
	 INV_Validate.F
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

     --inv_debug.message('ssia', 'TRO: date_required: ' || x_return_status);

    IF  p_trolin_rec.from_subinventory_code IS NOT NULL AND
        (   p_trolin_rec.from_subinventory_code <>
            p_old_trolin_rec.from_subinventory_code OR
            p_old_trolin_rec.from_subinventory_code IS NULL )
    THEN
       g_from_sub.secondary_inventory_name :=
	 p_trolin_rec.from_subinventory_code;
       IF inv_validate_trolin.g_transaction_l.transaction_action_id = 2 THEN
	  l_acct_txn := 0;
       ELSE
          l_acct_txn := 1;
       END IF;
       IF INV_Validate.From_Subinventory(g_from_sub,
					 inv_validate_trohdr.g_org,
					 g_item,l_acct_txn ) = INV_Validate.F
	 THEN
	   --inv_Debug.message('ssia', 'error from inv_validate.from_subinventory');
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;

       if( g_item.restrict_subinventories_code = 1 ) then
	 --inv_debug.message('ssia', 'g_item.restrict_subinventories_code is 1');
         BEGIN
           SELECT 'Y' INTO l_found
             FROM mtl_item_sub_trk_all_v
             WHERE inventory_item_id = p_trolin_Rec.inventory_item_id
             AND organization_id = p_trolin_rec.organization_id
             AND secondary_inventory_name = p_trolin_rec.from_subinventory_code;
         --
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
	      --inv_debug.message('ssia', 'invalid from sub');
              fnd_message.set_name('INV','INVALID_SUB');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
         END ;
       ELSIF g_item.restrict_subinventories_code = 2 THEN
           -- item is not restricted to specific subs
	 --inv_debug.message('ssia', 'g_item.restrict_subinventories_code is 2');
         BEGIN
           SELECT 'Y' INTO l_found
             FROM mtl_subinventories_trk_val_v
             WHERE organization_id = p_trolin_rec.organization_id
             AND secondary_inventory_name = p_trolin_rec.from_subinventory_code ;
           --
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
	      --inv_debug.message('ssia', 'invalid from sub');
              fnd_message.SET_NAME('INV','INVALID_SUB');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
         END ;
       END IF;
     --inv_debug.message('ssia', 'TRO: from_subinventory_code: ' || x_return_status);
    end if;

    IF  p_trolin_rec.project_id IS NOT NULL AND
        (   p_trolin_rec.project_id <>
            p_old_trolin_rec.project_id OR
            p_old_trolin_rec.project_id IS NULL )
    THEN
       IF INV_Validate.Project(p_trolin_rec.project_id) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        END IF;
    END IF;

    -- inv_debug.message('TRO: project_id: ' || x_return_status);

    IF  p_trolin_rec.task_id IS NOT NULL AND
        (   p_trolin_rec.task_id <>
            p_old_trolin_rec.task_id OR
            p_old_trolin_rec.task_id IS NULL )
    THEN
       IF INV_Validate.Task(p_trolin_rec.task_id, p_trolin_rec.project_id)
	 = INV_Validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: task_id: ' || x_return_status);

    IF  p_trolin_rec.from_locator_id IS NULL
       AND p_trolin_val_rec.from_locator IS NOT NULL
    THEN
        p_trolin_rec.from_locator_id := INV_Value_To_Id.from_locator(p_trolin_rec.organization_id,
                                                         p_trolin_val_rec.from_locator);
    END IF;

    IF  p_trolin_rec.from_locator_id IS NOT NULL AND
        (   p_trolin_rec.from_locator_id <>
            p_old_trolin_rec.from_locator_id OR
            p_old_trolin_rec.from_locator_id IS NULL )
    THEN
       g_from_locator.inventory_location_id := p_trolin_rec.from_locator_id;
/*Bug#5036174. If the org is non-PJM enbled, then the 'from locator' should not   be specific to any project. So the values of both project_id and task_id
  passed to 'INV_VALIDATE.FROM_LOCATOR' should be null when the org is non-PJM
  enabled.*/

       IF (inv_cache.set_org_rec(p_trolin_rec.organization_id)) THEN
         l_pjm := inv_cache.org_rec.project_reference_enabled;
       END IF;
       IF (l_pjm = 2) THEN
         IF INV_Validate.From_Locator(
                      g_from_locator
	             ,inv_validate_trohdr.g_org
	             ,g_item
                     ,g_from_sub
	             ,NULL
	             ,NULL
	             ,inv_validate_trolin.g_transaction_l.transaction_action_id)                     = INV_Validate.F
	         THEN
	           x_return_status := FND_API.G_RET_STS_ERROR;
	           return;
           END IF;
         ELSE
           IF INV_Validate.From_Locator(g_from_locator,
				    inv_validate_trohdr.g_org,
				    g_item, g_from_sub,
				    p_trolin_rec.project_id,
				    p_trolin_rec.task_id,
				    inv_validate_trolin.g_transaction_l.transaction_action_id) =
	 INV_Validate.F
	 THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    return;
         END IF;
      END IF;
    END IF;


    -- inv_debug.message('TRO: from_locator_id: ' || x_return_status);

    IF  p_trolin_rec.header_id IS NOT NULL AND
        (   p_trolin_rec.header_id <>
            p_old_trolin_rec.header_id OR
            p_old_trolin_rec.header_id IS NULL )
    THEN
       IF INV_Validate_Trohdr.Header(p_trolin_rec.header_id) =
	 INV_Validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        END IF;
    END IF;

    -- inv_debug.message('TRO: header id: ' || x_return_status);

    IF  p_trolin_rec.last_updated_by IS NOT NULL AND
        (   p_trolin_rec.last_updated_by <>
            p_old_trolin_rec.last_updated_by OR
            p_old_trolin_rec.last_updated_by IS NULL )
    THEN
       IF INV_Validate.Last_Updated_By(p_trolin_rec.last_updated_by) =
	 INV_Validate.F
       	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: last_updated_by: ' || x_return_status);

    IF  p_trolin_rec.last_update_date IS NULL THEN
       p_trolin_rec.last_update_date := SYSDATE;
    END IF;
    IF  p_trolin_rec.last_update_date IS NOT NULL AND
        (   p_trolin_rec.last_update_date <>
            p_old_trolin_rec.last_update_date OR
            p_old_trolin_rec.last_update_date IS NULL )
    THEN
       IF INV_Validate.Last_Update_Date(p_trolin_rec.last_update_date) =
	 inv_validate.f
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: last_update_date: ' || x_return_status);

    IF  p_trolin_rec.last_update_login IS NOT NULL AND
        (   p_trolin_rec.last_update_login <>
            p_old_trolin_rec.last_update_login OR
            p_old_trolin_rec.last_update_login IS NULL )
	      THEN
       IF INV_Validate.Last_Update_Login(p_trolin_rec.last_update_login) =
	 INV_Validate.f
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: last_update_login: ' || x_return_status);

    IF  p_trolin_rec.line_id IS NOT NULL AND
        (   p_trolin_rec.line_id <>
            p_old_trolin_rec.line_id OR
            p_old_trolin_rec.line_id IS NULL )
	      THEN
        IF Line(p_trolin_rec.line_id) = F THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   return;
        END IF;
    END IF;

    -- inv_debug.message('TRO: line_id: ' || x_return_status);


    IF  p_trolin_rec.line_number IS NOT NULL AND
      (   p_trolin_rec.line_number <>
	  p_old_trolin_rec.line_number OR
	  p_old_trolin_rec.line_number IS NULL )
    THEN
       IF Line_Number(p_trolin_rec.line_number,p_trolin_rec.header_id,
		      inv_validate_trohdr.g_org) = F
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  RETURN;
       END IF;
    END IF;

    -- inv_debug.message('TRO: line_number: ' || x_return_status);


    IF  p_trolin_rec.line_status IS NOT NULL AND
        (
	    --p_trolin_rec.line_status <>
            --p_old_trolin_rec.line_status OR
            p_old_trolin_rec.line_status IS NULL )
    THEN
       IF Line_Status(p_trolin_rec.line_status) = F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: line_status: ' || x_return_status);

    IF  p_trolin_rec.program_application_id IS NOT NULL AND
        (   p_trolin_rec.program_application_id <>
            p_old_trolin_rec.program_application_id OR
            p_old_trolin_rec.program_application_id IS NULL )
    THEN
       IF
	 INV_Validate.Program_Application(p_trolin_rec.program_application_id)
	 = INV_Validate.F
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: program_application_id: ' || x_return_status);

    IF  p_trolin_rec.program_id IS NOT NULL AND
        (   p_trolin_rec.program_id <>
            p_old_trolin_rec.program_id OR
            p_old_trolin_rec.program_id IS NULL )
    THEN
       IF INV_Validate.Program(p_trolin_rec.program_id) = inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: program_id: ' || x_return_status);

    IF  p_trolin_rec.program_update_date IS NOT NULL AND
        (   p_trolin_rec.program_update_date <>
            p_old_trolin_rec.program_update_date OR
            p_old_trolin_rec.program_update_date IS NULL )
    THEN
       IF
	 INV_Validate.Program_Update_Date(p_trolin_rec.program_update_date)
	 = inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: program_update_date: ' || x_return_status);

    IF  p_trolin_rec.quantity IS NOT NULL AND
        (   p_trolin_rec.quantity <>
            p_old_trolin_rec.quantity OR
            p_old_trolin_rec.quantity IS NULL )
    THEN
       IF INV_Validate.Quantity(p_trolin_rec.quantity) = inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: quantity: ' || x_return_status);

    IF  p_trolin_rec.quantity_delivered IS NOT NULL AND
        (   p_trolin_rec.quantity_delivered <>
            p_old_trolin_rec.quantity_delivered OR
            p_old_trolin_rec.quantity_delivered IS NULL )
    THEN
       IF Quantity_Delivered(p_trolin_rec.quantity_delivered) = F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: quantity_delivered: ' || x_return_status);

    IF  p_trolin_rec.quantity_detailed IS NOT NULL AND
        (   p_trolin_rec.quantity_detailed <>
            p_old_trolin_rec.quantity_detailed OR
            p_old_trolin_rec.quantity_detailed IS NULL )
    THEN
       IF Quantity_Detailed(p_trolin_rec.quantity_detailed) = F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: quantity_detailed: ' || x_return_status);

--INVCONV

    IF  p_trolin_rec.secondary_quantity IS NOT NULL AND
        (   p_trolin_rec.secondary_quantity <>
            p_old_trolin_rec.secondary_quantity OR
            p_old_trolin_rec.secondary_quantity IS NULL )
    THEN
       IF INV_Validate.Secondary_Quantity(p_trolin_rec.secondary_quantity) = inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: secondary_quantity: ' || x_return_status);

    IF  p_trolin_rec.secondary_quantity_delivered IS NOT NULL AND
        (   p_trolin_rec.secondary_quantity_delivered <>
            p_old_trolin_rec.secondary_quantity_delivered OR
            p_old_trolin_rec.secondary_quantity_delivered IS NULL )
    THEN
       IF Secondary_Quantity_Delivered(p_trolin_rec.secondary_quantity_delivered) = F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: secondary_quantity_delivered: ' || x_return_status);

    IF  p_trolin_rec.secondary_quantity_detailed IS NOT NULL AND
        (   p_trolin_rec.secondary_quantity_detailed <>
            p_old_trolin_rec.secondary_quantity_detailed OR
            p_old_trolin_rec.secondary_quantity_detailed IS NULL )
    THEN
       IF Secondary_Quantity_Detailed(p_trolin_rec.secondary_quantity_detailed) = F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;

    -- inv_debug.message('TRO: secondary_quantity_detailed: ' || x_return_status);
--INVCONV
    IF  p_trolin_rec.reason_id IS NOT NULL AND
        (   p_trolin_rec.reason_id <>
            p_old_trolin_rec.reason_id OR
            p_old_trolin_rec.reason_id IS NULL )
    THEN
       IF INV_Validate.Reason(p_trolin_rec.reason_id) = inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;
    -- inv_debug.message('TRO: reason_id: ' || x_return_status);

    IF  p_trolin_rec.reference IS NOT NULL AND
        (   p_trolin_rec.reference <>
            p_old_trolin_rec.reference OR
            p_old_trolin_rec.reference IS NULL )
    THEN
       IF INV_Validate.Reference(p_trolin_rec.reference) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        END IF;
    END IF;
    -- inv_debug.message('TRO: reference: ' || x_return_status);

    IF  p_trolin_rec.reference_type_code IS NOT NULL AND
        (   p_trolin_rec.reference_type_code <>
            p_old_trolin_rec.reference_type_code OR
            p_old_trolin_rec.reference_type_code IS NULL )
    THEN
       IF INV_Validate.Reference_Type(p_trolin_rec.reference_type_code) =
	 inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;
    -- inv_debug.message('TRO: reference_type_code: ' || x_return_status);

    IF  p_trolin_rec.reference_id IS NOT NULL AND
        p_trolin_rec.reference_type_code IS NOT NULL AND
        (   p_trolin_rec.reference_id <>
            p_old_trolin_rec.reference_id OR
            p_old_trolin_rec.reference_id IS NULL )
    THEN
       IF INV_Validate.Reference(p_trolin_rec.reference_id,
				 p_trolin_rec.reference_type_code) =
	 inv_validate.F  THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;
    -- inv_debug.message('TRO: reference_id: ' || x_return_status);

    IF  p_trolin_rec.request_id IS NOT NULL AND
        (   p_trolin_rec.request_id <>
            p_old_trolin_rec.request_id OR
            p_old_trolin_rec.request_id IS NULL )
    THEN
       IF INV_Validate_Trohdr.Request(p_trolin_rec.request_id) =
	 inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;
    -- inv_debug.message('TRO: request_id: ' || x_return_status);

    IF  p_trolin_rec.revision IS NOT NULL AND
        (   p_trolin_rec.revision <>
            p_old_trolin_rec.revision OR
            p_old_trolin_rec.revision IS NULL )
    THEN
       IF INV_Validate.Revision(p_trolin_rec.revision,
				inv_validate_trohdr.g_org,
				g_item) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        END IF;
    END IF;
    -- inv_debug.message('TRO: revision: ' || x_return_status);

 /* Bug# 3347313. Moved the code to initialise the g_lot.lot_number variable
    outside the condition.*/
    g_lot.lot_number := p_trolin_rec.lot_number;

    IF  p_trolin_rec.lot_number IS NOT NULL AND
        (   p_trolin_rec.lot_number <>
            p_old_trolin_rec.lot_number OR
            p_old_trolin_rec.lot_number IS NULL )
    THEN
       --g_lot.lot_number := p_trolin_rec.lot_number;
       --Added to call new lot number function if putaway move order
       -- this is because on hand might not have this lot already
       -- in the case of a putaway move order

       SELECT move_order_type INTO l_mov_order_type
	 FROM   mtl_txn_request_headers
	 WHERE header_id=p_trolin_rec.header_id;


       IF l_mov_order_type=INV_GLOBALS.g_move_order_put_away
	 THEN

	  IF INV_Validate.Lot_Number(g_lot, inv_validate_trohdr.g_org, g_item) = inv_validate.F THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     return;
	  END IF;

	ELSE

	  IF INV_Validate.Lot_Number(g_lot, inv_validate_trohdr.g_org, g_item,
				     g_from_sub, g_from_locator,
				     p_trolin_rec.revision) = inv_validate.F THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     return;
	  END IF;

       END IF;


       /*
       IF INV_Validate.Lot_Number(g_lot, inv_validate_trohdr.g_org, g_item,
				  g_from_sub, g_from_locator,
				  p_trolin_rec.revision) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
	 END IF;
	 */
    END IF;
    -- inv_debug.message('TRO: lot_number: ' || x_return_status);

    IF  p_trolin_rec.serial_number_start IS NOT NULL AND
        (   p_trolin_rec.serial_number_start <>
            p_old_trolin_rec.serial_number_start OR
            p_old_trolin_rec.serial_number_start IS NULL )
    THEN
       g_serial.serial_number := p_trolin_rec.serial_number_start;
       IF INV_Validate.Serial_Number_Start(g_serial,
					   inv_validate_trohdr.g_org,
					   g_item, g_from_sub, g_lot,
					   g_from_locator,
					   p_trolin_rec.revision) =
	 inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;
    -- inv_debug.message('TRO: serial_number_start: ' || x_return_status);

    IF  p_trolin_rec.serial_number_end IS NOT NULL AND
        (   p_trolin_rec.serial_number_end <>
            p_old_trolin_rec.serial_number_end OR
            p_old_trolin_rec.serial_number_end IS NULL )
    THEN
       g_serial.serial_number := p_trolin_rec.serial_number_end;
       IF INV_Validate.Serial_Number_End(g_serial,
					 inv_validate_trohdr.g_org,
					 g_item, g_from_sub, g_lot,
					 g_from_locator,
					 p_trolin_rec.revision) =
	 inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;
    -- inv_debug.message('TRO: serial_number: ' || x_return_status);


    IF  p_trolin_rec.status_date IS NOT NULL AND
        (   p_trolin_rec.status_date <>
            p_old_trolin_rec.status_date OR
            p_old_trolin_rec.status_date IS NULL )
    THEN
       IF INV_Validate_Trohdr.Status_Date(p_trolin_rec.status_date) =
	 inv_validate.F THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  return;
       END IF;
    END IF;
    -- inv_debug.message('TRO: status_date: ' || x_return_status);


    IF g_transaction_l.transaction_action_id = 1 THEN
       IF  p_trolin_rec.to_account_id IS NULL
          AND p_trolin_val_rec.to_account IS NOT NULL
      THEN

	 SELECT ORG.CHART_OF_ACCOUNTS_ID
	   INTO l_chart_of_accounts_id
	   FROM ORG_ORGANIZATION_DEFINITIONS ORG
	   WHERE ORG.ORGANIZATION_ID = inv_validate_trohdr.g_org.organization_id;

	 l_keystat_val := FND_FLEX_KEYVAL.Validate_Segs(
                            OPERATION        => 'CREATE_COMBINATION',
                            APPL_SHORT_NAME  => 'SQLGL',
			    key_flex_code    => 'GL#',
                            STRUCTURE_NUMBER => l_chart_of_accounts_id,
                            CONCAT_SEGMENTS  => p_trolin_val_rec.to_account,
                            VALUES_OR_IDS    => 'V');
                            -- DATA_SET         => INV_Validate.g_TRO_VAttributes.organization_id);
          if l_keystat_val then
            l_combination_id := FND_FLEX_KEYVAL.combination_id;
            p_trolin_rec.to_account_id := l_combination_id;
          else
            x_return_status := FND_API.G_RET_STS_ERROR;
          end if;
      END IF;


      IF  p_trolin_rec.to_account_id IS NOT NULL AND
          (   p_trolin_rec.to_account_id <>
              p_old_trolin_rec.to_account_id OR
              p_old_trolin_rec.to_account_id IS NULL )
      THEN
	 IF INV_Validate.To_Account(p_trolin_rec.to_account_id) =
	   inv_validate.f THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;
      -- inv_debug.message('TRO: to_account_id: ' || x_return_status);
    END IF;

    IF  g_transaction_l.transaction_action_id in (2,28) THEN
       IF  p_trolin_rec.to_subinventory_code IS NOT NULL AND
          (   p_trolin_rec.to_subinventory_code <>
              p_old_trolin_rec.to_subinventory_code OR
              p_old_trolin_rec.to_subinventory_code IS NULL )
      THEN
         --inv_debug.message('ssia', 'check to_subinventory_code');
	 g_to_sub.secondary_inventory_name := p_trolin_rec.to_subinventory_code;
	 IF INV_Validate.To_Subinventory(g_to_sub, inv_validate_trohdr.g_org,
					 g_item, g_from_sub, 0) =
	   inv_validate.F THEN
	    --inv_debug.message('ssia', 'error to_subinventory_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
	 END IF;
         if( g_item.restrict_subinventories_code = 1 ) then
	    --inv_Debug.message('ssia', 'g_item_restrict subinventory code is 1');
            BEGIN
              SELECT 'Y' INTO l_found
                FROM mtl_secondary_inventories sec, mtl_item_sub_inventories item
                WHERE item.inventory_item_id = p_trolin_rec.inventory_item_id
                AND sec.organization_id = p_trolin_Rec.organization_id
                AND sec.secondary_inventory_name = p_trolin_rec.to_subinventory_code
		AND sec.organization_id = item.organization_id
		AND sec.secondary_inventory_name = item.secondary_inventory;
            --
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
		 --inv_debug.message('ssia', 'invalid to sub');
                 fnd_message.set_name('INV','INVALID_SUB');
                 fnd_msg_pub.add;
                 RAISE fnd_api.g_exc_error;
            END ;
          ELSIF g_item.restrict_subinventories_code = 2 THEN
              -- item is not restricted to specific subs
	    --inv_Debug.message('ssia', 'g_item_restrict subinventory code is 2');
            BEGIN
              SELECT 'Y' INTO l_found
                FROM mtl_secondary_inventories
                WHERE organization_id = p_trolin_rec.organization_id
		AND secondary_inventory_name = p_trolin_rec.to_subinventory_code
		AND nvl(disable_date, SYSDATE+1) > SYSDATE;
            --
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
		 --inv_debug.message('ssia', 'invalid to sub');
                  fnd_message.SET_NAME('INV','INVALID_SUB');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_error;
            END ;
	 END IF;
      END IF;
       --inv_debug.message('ssia', 'TRO: to_subinventory: ' || x_return_status);


    -- **********************************************************
    -- Validation
    -- **********************************************************
      IF  p_trolin_rec.to_locator_id IS NULL
          AND p_trolin_val_rec.to_locator IS NOT NULL
      THEN
          v_locator_control :=
             INV_Globals.Locator_control(
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           inv_validate_trohdr.g_org.stock_locator_control_code,
                           nvl(g_to_sub.locator_type,1),
                           g_item.location_control_code,
                           g_item.restrict_locators_code,
                           inv_validate_trohdr.g_org.negative_inv_receipt_code,
			   inv_validate_trolin.g_transaction_l.transaction_action_id);
          if (NVL(v_locator_control,1) = 3) then
            l_keystat_val := FND_FLEX_KEYVAL.Validate_Segs(
                            OPERATION        => 'CREATE_COMB_NO_AT',
                            APPL_SHORT_NAME  => 'INV',
                            KEY_FLEX_CODE    => 'MTLL',
                            STRUCTURE_NUMBER => 101,
                            CONCAT_SEGMENTS  => p_trolin_val_rec.to_locator,
                            VALUES_OR_IDS    => 'V',
                            DATA_SET         => inv_validate_trohdr.g_org.organization_id);

            if l_keystat_val then
              l_combination_id := FND_FLEX_KEYVAL.combination_id;
              BEGIN
                SELECT 'EXISTS'
                  INTO l_temp
                  FROM MTL_ITEM_LOCATIONS
                 WHERE INVENTORY_LOCATION_ID = l_combination_id
                   AND ORGANIZATION_ID = inv_validate_trohdr.g_org.organization_id
		AND SUBINVENTORY_CODE = g_to_sub.secondary_inventory_name;

              EXCEPTION
               WHEN NO_DATA_FOUND THEN
		  UPDATE mtl_item_locations
                   SET SUBINVENTORY_CODE = g_to_sub.secondary_inventory_name
                 WHERE INVENTORY_LOCATION_ID = l_combination_id
                   AND ORGANIZATION_ID = inv_validate_trohdr.g_org.organization_id
                   AND SUBINVENTORY_CODE = NULL;

                if SQL%NOTFOUND then
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   return;
                else
                  SELECT PROJECT_ID,TASK_ID
                    INTO l_project_id, l_task_id
                    FROM MTL_ITEM_LOCATIONS
                   WHERE INVENTORY_LOCATION_ID = l_combination_id
                     AND ORGANIZATION_ID =inv_validate_trohdr.g_org.organization_id;

                   if NOT INV_ProjectLocator_PUB.Check_Project_References(
                              inv_validate_trohdr.g_org.organization_id,
                              p_trolin_rec.to_locator_id,
                              'ANY',
                              'N',
                              l_project_id,
                              l_task_id) then
                      x_return_status := FND_API.G_RET_STS_ERROR;
                   end if;
                 end if;
              END;
            end if;
          else
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
          end if;
          p_trolin_rec.to_locator_id := INV_Value_To_Id.To_Locator(p_trolin_rec.organization_id,
                                                       p_trolin_val_rec.to_locator);
      END IF;

      IF  p_trolin_rec.to_locator_id IS NOT NULL AND
          (   p_trolin_rec.to_locator_id <>
              p_old_trolin_rec.to_locator_id OR
              p_old_trolin_rec.to_locator_id IS NULL )
      THEN
	 g_to_locator.inventory_location_id := p_trolin_rec.to_locator_id;

/*	BUG 2347421 - When locator is specified on order line this validation fails
		      if the logical locator with the project and task does not exist.
		      This project locator is created later on in the flow.
		      Changing this validation to not consider the project and task.

        BUG 3036732 - The fix in 2347421 fails when the locator is already entered with project and task
                      If the project info is already entered on the locator then validate the locator , else
                      do not consider the project and task
*/
                    SELECT PROJECT_ID
                    INTO l_project_id_mil
                    FROM MTL_ITEM_LOCATIONS
                    WHERE INVENTORY_LOCATION_ID =  g_to_locator.inventory_location_id
                    AND ORGANIZATION_ID = p_trolin_rec.organization_id;


           IF l_project_id_mil is NOT NULL THEN


        	 IF INV_Validate.To_Locator(g_to_locator,
				    inv_validate_trohdr.g_org, g_item,
				    g_to_sub, p_trolin_rec.project_id,
				    p_trolin_rec.task_id,
			    inv_validate_trolin.g_transaction_l.transaction_action_id) = inv_validate.F THEN
                             x_return_status := FND_API.G_RET_STS_ERROR;
                             return;
                  END IF;

           ELSE

	           IF INV_Validate.To_Locator(g_to_locator,
				    inv_validate_trohdr.g_org, g_item,
				    g_to_sub, null, null,
				    inv_validate_trolin.g_transaction_l.transaction_action_id) = inv_validate.F THEN
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                                    return;
                   END IF;
            END IF;
      END IF;
      -- inv_debug.message('TRO: to_locator_id: ' || x_return_status);
    END IF;


    IF  p_trolin_rec.transaction_header_id IS NOT NULL AND
        (   p_trolin_rec.transaction_header_id <>
            p_old_trolin_rec.transaction_header_id OR
            p_old_trolin_rec.transaction_header_id IS NULL )
    THEN
       IF
	 INV_Validate.Transaction_Header(p_trolin_rec.transaction_header_id) =
	 inv_validate.f THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    -- inv_debug.message('TRO: transaction_header_id: ' || x_return_status);

    IF p_trolin_rec.ship_to_location_id IS NOT NULL AND
       ( p_trolin_rec.ship_to_location_id <>
           p_old_trolin_rec.transaction_header_id OR
           p_old_trolin_rec.transaction_header_id IS NULL)
    THEN
      IF INV_Validate.HR_Location(p_trolin_rec.ship_to_location_id) =
           INV_Validate.F
      THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF  p_trolin_rec.uom_code IS NOT NULL AND
        (   p_trolin_rec.uom_code <>
            p_old_trolin_rec.uom_code OR
            p_old_trolin_rec.uom_code IS NULL )
    THEN
       IF INV_Validate.Uom(p_trolin_rec.uom_code,
			   inv_validate_trohdr.g_org, g_item) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF p_trolin_rec.from_cost_group_id IS NOT NULL AND
       (p_trolin_rec.from_cost_group_id <> p_old_trolin_rec.from_cost_group_id OR
	p_old_trolin_rec.from_cost_group_id IS NULL) then
        if INV_Validate.Cost_Group(p_trolin_rec.from_cost_group_id,
				   p_trolin_rec.organization_id) = inv_validate.F then
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;
    END IF;

    IF p_trolin_rec.to_cost_group_id IS NOT NULL AND
       (p_trolin_rec.to_cost_group_id <> p_old_trolin_rec.to_cost_group_id OR
        p_old_trolin_rec.to_cost_group_id IS NULL) then
        if INV_Validate.Cost_Group(p_trolin_rec.to_cost_group_id,
                                   p_trolin_rec.organization_id) = inv_validate.F then
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF p_trolin_rec.lpn_id IS NOT NULL AND
       (p_trolin_rec.lpn_id <> p_old_trolin_rec.lpn_id OR
        p_old_trolin_rec.lpn_id IS NULL) then
        if INV_Validate.LPN(p_trolin_rec.lpn_id) = inv_validate.F then
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF p_trolin_rec.to_lpn_id IS NOT NULL AND
       (p_trolin_rec.to_lpn_id <> p_old_trolin_rec.to_lpn_id OR
        p_old_trolin_rec.to_lpn_id IS NULL) then
        if INV_Validate.LPN(p_trolin_rec.to_lpn_id) = inv_validate.F then
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    -- inv_debug.message('TRO: uom: ' || x_return_status);

    IF  (p_trolin_rec.attribute1 IS NOT NULL AND
        (   p_trolin_rec.attribute1 <>
            p_old_trolin_rec.attribute1 OR
            p_old_trolin_rec.attribute1 IS NULL ))
    OR  (p_trolin_rec.attribute10 IS NOT NULL AND
        (   p_trolin_rec.attribute10 <>
            p_old_trolin_rec.attribute10 OR
            p_old_trolin_rec.attribute10 IS NULL ))
    OR  (p_trolin_rec.attribute11 IS NOT NULL AND
        (   p_trolin_rec.attribute11 <>
            p_old_trolin_rec.attribute11 OR
            p_old_trolin_rec.attribute11 IS NULL ))
    OR  (p_trolin_rec.attribute12 IS NOT NULL AND
        (   p_trolin_rec.attribute12 <>
            p_old_trolin_rec.attribute12 OR
            p_old_trolin_rec.attribute12 IS NULL ))
    OR  (p_trolin_rec.attribute13 IS NOT NULL AND
        (   p_trolin_rec.attribute13 <>
            p_old_trolin_rec.attribute13 OR
            p_old_trolin_rec.attribute13 IS NULL ))
    OR  (p_trolin_rec.attribute14 IS NOT NULL AND
        (   p_trolin_rec.attribute14 <>
            p_old_trolin_rec.attribute14 OR
            p_old_trolin_rec.attribute14 IS NULL ))
    OR  (p_trolin_rec.attribute15 IS NOT NULL AND
        (   p_trolin_rec.attribute15 <>
            p_old_trolin_rec.attribute15 OR
            p_old_trolin_rec.attribute15 IS NULL ))
    OR  (p_trolin_rec.attribute2 IS NOT NULL AND
        (   p_trolin_rec.attribute2 <>
            p_old_trolin_rec.attribute2 OR
            p_old_trolin_rec.attribute2 IS NULL ))
    OR  (p_trolin_rec.attribute3 IS NOT NULL AND
        (   p_trolin_rec.attribute3 <>
            p_old_trolin_rec.attribute3 OR
            p_old_trolin_rec.attribute3 IS NULL ))
    OR  (p_trolin_rec.attribute4 IS NOT NULL AND
        (   p_trolin_rec.attribute4 <>
            p_old_trolin_rec.attribute4 OR
            p_old_trolin_rec.attribute4 IS NULL ))
    OR  (p_trolin_rec.attribute5 IS NOT NULL AND
        (   p_trolin_rec.attribute5 <>
            p_old_trolin_rec.attribute5 OR
            p_old_trolin_rec.attribute5 IS NULL ))
    OR  (p_trolin_rec.attribute6 IS NOT NULL AND
        (   p_trolin_rec.attribute6 <>
            p_old_trolin_rec.attribute6 OR
            p_old_trolin_rec.attribute6 IS NULL ))
    OR  (p_trolin_rec.attribute7 IS NOT NULL AND
        (   p_trolin_rec.attribute7 <>
            p_old_trolin_rec.attribute7 OR
            p_old_trolin_rec.attribute7 IS NULL ))
    OR  (p_trolin_rec.attribute8 IS NOT NULL AND
        (   p_trolin_rec.attribute8 <>
            p_old_trolin_rec.attribute8 OR
            p_old_trolin_rec.attribute8 IS NULL ))
    OR  (p_trolin_rec.attribute9 IS NOT NULL AND
        (   p_trolin_rec.attribute9 <>
            p_old_trolin_rec.attribute9 OR
            p_old_trolin_rec.attribute9 IS NULL ))
    OR  (p_trolin_rec.attribute_category IS NOT NULL AND
        (   p_trolin_rec.attribute_category <>
            p_old_trolin_rec.attribute_category OR
            p_old_trolin_rec.attribute_category IS NULL ))
    THEN

    --  These calls are temporarily commented out


        --  Validate descriptive flexfield.

       IF INV_Validate.Desc_Flex( 'TROLIN' ) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;

    --  Done validating attributes
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, 'Attributes');
        END IF;
END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trolin_rec                    IN  INV_Move_Order_PUB.Trolin_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Validate entity delete.
    NULL;

    --  Done.
    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Entity_Delete');
        END IF;

END Entity_Delete;

-- Bug # 1911054
-- Procedure Init : used to initialized the global variable created in this package
PROCEDURE Init
IS
 l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
     /*Fixed for bug#8358229
       Initialization should be done for complete record.
       Modified following initialization to initialize complete
       record
     */

   g_transaction_l             := Null;
   g_item                      := Null;
   g_from_sub                  := Null;
   g_to_sub                    := Null;
   g_from_locator              := Null;
   g_to_locator                := Null;
END;

END INV_Validate_Trolin;

/
