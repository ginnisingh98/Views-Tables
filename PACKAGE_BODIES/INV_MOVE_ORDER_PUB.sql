--------------------------------------------------------
--  DDL for Package Body INV_MOVE_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MOVE_ORDER_PUB" AS
/* $Header: INVPTROB.pls 120.5.12010000.4 2009/08/12 11:07:04 asugandh ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Move_Order_PUB';

g_inventory_item_id    NUMBER := NULL;
g_primary_uom_code    VARCHAR2(3) := NULL;
g_restrict_subinventories_code NUMBER;
g_restrict_locators_code NUMBER;


PROCEDURE print_debug(p_message in varchar2, p_module in varchar2) IS
begin
  -- dbms_output.put_line(p_message);
  inv_trx_util_pub.trace(p_message, p_module);
end;

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_trohdr_rec                    IN  Trohdr_Rec_Type
,   p_trolin_tbl                    IN  Trolin_Tbl_Type
,   x_trohdr_val_rec                OUT NOCOPY Trohdr_Val_Rec_Type
,   x_trolin_val_tbl                OUT NOCOPY Trolin_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trohdr_rec                    IN  Trohdr_Rec_Type
,   p_trohdr_val_rec                IN  Trohdr_Val_Rec_Type
,   p_trolin_tbl                    IN  Trolin_Tbl_Type
,   p_trolin_val_tbl                IN  Trolin_Val_Tbl_Type
,   x_trohdr_rec                    IN OUT NOCOPY Trohdr_Rec_Type
,   x_trolin_tbl                    IN OUT NOCOPY Trolin_Tbl_Type
);
--  Start of Comments
--  API name    Create_Move_Order_Header
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Create_Move_Order_Header
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_trohdr_rec                    IN  Trohdr_Rec_Type := G_MISS_TROHDR_REC
,   p_trohdr_val_rec                IN  Trohdr_Val_Rec_Type := G_MISS_TROHDR_VAL_REC
,   x_trohdr_rec                    IN OUT NOCOPY Trohdr_Rec_Type
,   x_trohdr_val_rec                IN OUT NOCOPY Trohdr_Val_Rec_Type
,   p_validation_flag            IN VARCHAR2
) IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Create_Move_Order_Header';
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_trohdr_rec                  Trohdr_Rec_Type;
l_trolin_tbl                  Trolin_Tbl_Type := G_MISS_TROLIN_TBL;
l_trolin_val_tbl              Trolin_Val_Tbl_Type := G_MISS_TROLIN_VAL_TBL;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    if l_debug = 1 THEN
      print_debug('enter Create Move Order Header', l_api_name);
    end if;
    --  Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  g_primary_uom_code := NULL;
  g_inventory_item_id := NULL;
  IF NVL(p_validation_flag,g_validation_yes) = g_validation_no THEN
    If l_debug = 1 THEN
      print_debug('No Validation', l_api_name);
    End If;
    x_trohdr_rec := p_trohdr_rec;
    --set default values
    x_trohdr_rec.date_required := sysdate;
    x_trohdr_rec.description := NULL;
    x_trohdr_rec.from_subinventory_code := NULL;
    x_trohdr_rec.header_id := INV_TRANSFER_ORDER_PVT.get_next_header_id;
    x_trohdr_rec.program_application_id := NULL;
    x_trohdr_rec.program_id := NULL;
    x_trohdr_rec.program_update_date := NULL;
    x_trohdr_rec.request_id := NULL;
    x_trohdr_rec.status_date := sysdate;
    x_trohdr_rec.to_account_id := NULL;
    x_trohdr_rec.to_subinventory_code := NULL;
    x_trohdr_rec.ship_to_location_id := NULL;

    x_trohdr_rec.attribute_category:= NULL;
    x_trohdr_rec.attribute1 := NULL;
    x_trohdr_rec.attribute2 := NULL;
    x_trohdr_rec.attribute3 := NULL;
    x_trohdr_rec.attribute4 := NULL;
    x_trohdr_rec.attribute5 := NULL;
    x_trohdr_rec.attribute6 := NULL;
    x_trohdr_rec.attribute7 := NULL;
    x_trohdr_rec.attribute8 := NULL;
    x_trohdr_rec.attribute9 := NULL;
    x_trohdr_rec.attribute10 := NULL;
    x_trohdr_rec.attribute11 := NULL;
    x_trohdr_rec.attribute12 := NULL;
    x_trohdr_rec.attribute13 := NULL;
    x_trohdr_rec.attribute14 := NULL;
    x_trohdr_rec.attribute15 := NULL;
    inv_trohdr_util.insert_row(x_trohdr_rec);
    x_return_status := fnd_api.g_ret_sts_success;

  ELSE
    If l_debug = 1 THEN
      print_debug('Validation turned on', l_api_name);
    End If;
    l_control_rec.controlled_operation := TRUE;
    l_control_Rec.process_entity := INV_GLOBALS.G_ENTITY_TROHDR;
    l_control_Rec.default_attributes := TRUE;
    l_control_rec.change_attributes := TRUE;
    l_control_rec.write_to_db := TRUE;

    If l_debug = 1 THEN
      print_debug('Call to process_transfer_order', l_api_name);
    End If;
    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order
    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_commit                      => p_commit
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_control_rec                 => l_control_rec
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_trohdr_rec                  => p_trohdr_rec
    ,   p_trohdr_val_rec              => p_trohdr_val_rec
    ,   p_trolin_tbl                  => l_trolin_tbl
    ,   p_trolin_val_tbl              => l_trolin_val_tbl
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
		If l_debug = 1 THEN
			print_debug('Error from process_transfer_order',l_api_name);
		End If;
		RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
		If l_debug = 1 THEN
			print_debug('Unexpected error from process_transfer_order',l_api_name);
		End If;
		RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --  Load Id OUT parameters.

    x_trohdr_rec                   := l_trohdr_rec;
    if( p_commit = FND_API.G_TRUE ) Then
    commit;
    end if;
    --x_trolin_tbl                   := p_trolin_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_trohdr_rec                  => p_trohdr_rec
        ,   p_trolin_tbl                  => l_trolin_tbl
        ,   x_trohdr_val_rec              => x_trohdr_val_rec
        ,   x_trolin_val_tbl              => l_trolin_val_tbl
        );

    END IF;
  END IF;

  If l_debug = 1 THEN
    print_debug('End Create Move Order Header', l_api_name);
  End If;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Create_Move_Order_Header');
        END IF;

        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Create_Move_Order_Header;


--  Start of Comments
--  API name    Create_Move_Order_Lines
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--  Changed by P lowe for bug 6689912
--  End of Comments

PROCEDURE Create_Move_Order_Lines
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_trolin_tbl                    IN  Trolin_Tbl_Type :=
                                        G_MISS_TROLIN_TBL
,   p_trolin_val_tbl                IN  Trolin_Val_Tbl_Type :=
                                        G_MISS_TROLIN_VAL_TBL
,   x_trolin_tbl                    IN OUT NOCOPY Trolin_Tbl_Type
,   x_trolin_val_tbl                IN OUT NOCOPY Trolin_Val_Tbl_Type
,   p_validation_flag            IN VARCHAR2
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Create_Move_Order_Lines';
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_trohdr_rec                  Trohdr_Rec_Type := G_MISS_TROHDR_REC;
l_trohdr_val_rec              Trohdr_Val_Rec_Type := G_MISS_TROHDR_VAL_REC;
l_trolin_tbl                  Trolin_Tbl_Type := p_trolin_tbl;
l_trolin_tbl_out          Trolin_Tbl_Type;
l_dummy                  NUMBER;
l_index                  NUMBER;
l_primary_uom_code          VARCHAR2(3);
l_restrict_locators_code      NUMBER := NULL;
l_restrict_subinventories_code NUMBER:= NULL;
l_result              VARCHAR2(1);
l_current_ship_set_id           NUMBER;
l_failed_ship_set_id          NUMBER;
l_shipset_start_index          NUMBER;

l_batch_id            NUMBER := WSH_PICK_LIST.G_BATCH_ID;
l_new_trolin_tbl        trolin_new_tbl_type;
l_found_backorder_cache        BOOLEAN := FALSE;
l_return_value            BOOLEAN := TRUE;
l_shipping_attr            WSH_INTERFACE.ChangedAttributeTabType;
l_shipset_smc_backorder_rec    WSH_INTEGRATION.BackorderRecType;
l_reservable_type        NUMBER;
l_count                NUMBER;

 CURSOR get_move_order_type (V_header_id NUMBER) IS
 select move_order_type
 from mtl_txn_request_headers h
 where h.header_id = V_header_id;
-- 6689912
 CURSOR get_sales_order (V_line_id NUMBER) IS
 select h.order_number , l.org_id -- 6689912 added org_id
 from oe_order_headers_all h
     ,oe_order_lines_all l
 where l.header_id = h.header_id
 and l.line_id = V_line_id;

 l_org_id number; -- 6689912
 l_order_number       OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE;
 l_move_order_type    MTL_TXN_REQUEST_HEADERS.MOVE_ORDER_TYPE%TYPE;
 l_error_code         NUMBER;
 l_msg_data           VARCHAR2(240);

 CURSOR get_sub_loc_ctrl(v_org_id  NUMBER, v_sub_code  VARCHAR2) IS
 SELECT locator_type
   FROM mtl_secondary_inventories
  WHERE organization_id = v_org_id
    AND secondary_inventory_name = v_sub_code;

 l_sub_loc_ctrl       NUMBER;

 CURSOR get_item_loc_ctrl(v_org_id  NUMBER, v_item_id  NUMBER) IS
 SELECT location_control_code
   FROM mtl_system_items
  WHERE organization_id = v_org_id
    AND inventory_item_id = v_item_id;

 l_item_loc_ctrl      NUMBER;
 l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

 --Bug 7148749, added for ship model complete handling
 l_current_ship_model_id NUMBER;
 l_shipmodel_start_index NUMBER;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

/*
    --  Perform Value to Id conversion
    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_trohdr_rec                  => l_trohdr_rec
    ,   p_trohdr_val_rec              => l_trohdr_val_rec
    ,   p_trolin_tbl                  => p_trolin_tbl
    ,   p_trolin_val_tbl              => p_trolin_val_tbl
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    --l_control_rec.process_entity := INV_GLOBALS.G_ENTITY_TROLIN;
    --l_control_rec.controlled_operation := TRUE;
    --l_control_rec.write_to_db := FND_API.to_boolean(p_commit);

  IF NVL(p_validation_flag, g_validation_yes) = g_validation_no THEN  --{ Validation No
    l_index := p_trolin_tbl.FIRST;
    l_count := 1;
    Loop
      -- print_debug('start l_index '||l_index,l_api_name);
      x_trolin_tbl(l_index) := p_trolin_tbl(l_index);
      x_trolin_tbl(l_Index).return_status := fnd_api.g_ret_sts_success;
      l_found_backorder_cache := FALSE;
      l_restrict_subinventories_code := NULL;
      l_restrict_locators_code := NULL;

      IF x_trolin_tbl(l_index).ship_set_id IS NOT NULL AND
        x_trolin_tbl(l_index).ship_set_id <> fnd_api.g_miss_num AND
        x_trolin_tbl(l_index).ship_set_id <> nvl(l_current_ship_set_id, -9999) THEN
        SAVEPOINT SHIPSET_SP;
        l_current_ship_set_id := x_trolin_tbl(l_index).ship_set_id;
        l_shipset_start_index := l_index;
      ELSIF (x_trolin_tbl(l_index).ship_set_id IS NULL OR
        x_trolin_tbl(l_index).ship_set_Id = fnd_api.g_miss_num) AND
        l_current_ship_set_id IS NOT NULL THEN
        l_current_ship_set_id := NULL;
        l_shipset_start_index := NULL;
      END IF;

      -- Bug 7148749, added for ship model complete handling
      IF x_trolin_tbl(l_index).ship_model_id IS NOT NULL AND
        x_trolin_tbl(l_index).ship_model_id <> fnd_api.g_miss_num AND
        x_trolin_tbl(l_index).ship_model_id <> nvl(l_current_ship_model_id, -9999) THEN
        SAVEPOINT SHIPMODEL_SP;
        l_current_ship_model_id := x_trolin_tbl(l_index).ship_model_id;
        l_shipmodel_start_index := l_index;
      ELSIF (x_trolin_tbl(l_index).ship_model_id IS NULL OR
        x_trolin_tbl(l_index).ship_model_Id = fnd_api.g_miss_num) AND
        l_current_ship_model_id IS NOT NULL THEN
        l_current_ship_model_id := NULL;
        l_shipmodel_start_index := NULL;
      END IF;
      -- End Bug 7148749

      If x_trolin_tbl(l_index).transaction_type_id = 52 Then
        x_trolin_tbl(l_index).transaction_source_type_id := 2;
      Elsif x_trolin_tbl(l_index).transaction_type_id = 53 Then
        x_trolin_tbl(l_index).transaction_source_type_id := 8;
      Else
        BEGIN
          select transaction_source_type_id
                into x_trolin_tbl(l_index).transaction_source_type_id
          from mtl_transaction_types
          where transaction_type_id = x_trolin_tbl(l_index).transaction_type_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            print_debug('Error in fetching source type, Invalid transaction type', l_api_name);
            RAISE fnd_api.g_exc_error;
        END;
      End If;

      IF x_trolin_tbl(l_index).primary_quantity IS NULL OR
         x_trolin_tbl(l_index).primary_quantity = fnd_api.g_miss_num THEN
        IF g_inventory_item_id = x_trolin_tbl(l_index).inventory_item_id THEN
            l_primary_uom_code := g_primary_uom_code;
        ELSE
          -- print_debug('Selecting primary uom code', l_api_name);
          SELECT primary_uom_code
              ,nvl(restrict_locators_code,0)
              ,nvl(restrict_subinventories_code,0)
          INTO l_primary_uom_code
              ,l_restrict_locators_code
              ,l_restrict_subinventories_code
          FROM mtl_system_items
          WHERE organization_id = x_trolin_tbl(l_index).organization_id
          AND inventory_item_id = x_trolin_tbl(l_index).inventory_item_id;

          g_inventory_item_id := x_trolin_tbl(l_index).inventory_item_id;
          g_primary_uom_code := l_primary_uom_code;
          g_restrict_locators_code := l_restrict_locators_code;
          g_restrict_subinventories_code := l_restrict_subinventories_code;
        END IF;

        IF l_primary_uom_code = x_trolin_tbl(l_index).uom_code THEN
          x_trolin_tbl(l_index).primary_quantity := x_trolin_tbl(l_index).quantity;
        ELSE
          -- Bug 8597009: add org ID and lot number for lot-specific conversions
          x_trolin_tbl(l_index).primary_quantity :=
             inv_convert.inv_um_convert(
                      item_id         => x_trolin_tbl(l_index).inventory_item_id
                    , lot_number      => x_trolin_tbl(l_index).lot_number
                    , organization_id => x_trolin_tbl(l_index).organization_id
                    , PRECISION       => NULL
                    , from_quantity   => x_trolin_tbl(l_index).quantity
                    , from_unit       => x_trolin_tbl(l_index).uom_code
                    , to_unit         => l_primary_uom_code
                    , from_name       => NULL
                    , to_name         => NULL);
          --print_debug('primary_quantity = '|| x_trolin_tbl(l_index).primary_quantity, l_api_name);
          IF x_trolin_tbl(l_index).primary_quantity < 0 THEN
            print_debug('Error during conversion. Primary quantity less that 0', l_api_name);
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF; -- primary uom = txn uom
      END IF; -- primary qty is missing

      IF x_trolin_tbl(l_index).to_subinventory_code IS NOT NULL THEN
        IF l_restrict_subinventories_code IS NULL THEN
          IF g_inventory_item_id = x_trolin_tbl(l_index).inventory_item_id Then
            l_restrict_subinventories_code := g_restrict_subinventories_code;
            l_restrict_locators_code := g_restrict_locators_code;
          ELSE  -- item doesn't match saved item
            SELECT primary_uom_code
                ,nvl(restrict_locators_code,0)
                ,nvl(restrict_subinventories_code,0)
            INTO l_primary_uom_code
                ,l_restrict_locators_code
                ,l_restrict_subinventories_code
             FROM mtl_system_items
            WHERE organization_id = x_trolin_tbl(l_index).organization_id
              AND inventory_item_id = x_trolin_tbl(l_index).inventory_item_id;

            g_inventory_item_id :=  x_trolin_tbl(l_index).inventory_item_id;
            g_primary_uom_code := l_primary_uom_code;
            g_restrict_subinventories_code := l_restrict_subinventories_code;
            g_restrict_locators_code := l_restrict_locators_code;
          END IF; -- inventory item matches
        END IF; -- restrict subs is null
        IF l_restrict_locators_code = 1 AND
              x_trolin_tbl(l_index).to_locator_id IS NOT NULL THEN
          BEGIN
               SELECT 'Y'
              INTO l_result
                  FROM DUAL
                 WHERE exists (
                    SELECT secondary_locator
                      FROM mtl_secondary_locators
                     WHERE organization_id = x_trolin_tbl(l_index).organization_id
                       AND secondary_locator = x_trolin_tbl(l_index).to_locator_id
                   AND inventory_item_id = x_trolin_tbl(l_index).inventory_item_id);
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   x_trolin_tbl(l_index).return_status := fnd_api.g_ret_sts_error;
               END;

        ELSIF l_restrict_subinventories_code = 1 and x_trolin_tbl(l_index).to_subinventory_code is NOT NULL Then
          BEGIN
           SELECT 'Y'
              INTO l_result
                   FROM DUAL
                 WHERE exists (
                     SELECT secondary_inventory
                       FROM mtl_item_sub_inventories
                      WHERE organization_id = x_trolin_tbl(l_index).organization_id
                      AND secondary_inventory = x_trolin_tbl(l_index).to_subinventory_code
                      AND inventory_item_id = x_trolin_tbl(l_index).inventory_item_id);
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               x_trolin_tbl(l_index).return_status := fnd_api.g_ret_sts_error;
           END;
        END IF;
      END IF; -- to sub is not null

/*Fix for bug#8608683
  Validation for from sub inventory has been added.
*/
      IF x_trolin_tbl(l_index).from_subinventory_code IS NOT NULL THEN
        IF l_restrict_subinventories_code IS NULL THEN
          IF g_inventory_item_id = x_trolin_tbl(l_index).inventory_item_id Then
            l_restrict_subinventories_code := g_restrict_subinventories_code;
            l_restrict_locators_code := g_restrict_locators_code;
          ELSE  -- item doesn't match saved item
            SELECT primary_uom_code
                ,nvl(restrict_locators_code,0)
                ,nvl(restrict_subinventories_code,0)
            INTO l_primary_uom_code
                ,l_restrict_locators_code
                ,l_restrict_subinventories_code
             FROM mtl_system_items
            WHERE organization_id = x_trolin_tbl(l_index).organization_id
              AND inventory_item_id = x_trolin_tbl(l_index).inventory_item_id;

            g_inventory_item_id :=  x_trolin_tbl(l_index).inventory_item_id;
            g_primary_uom_code := l_primary_uom_code;
            g_restrict_subinventories_code := l_restrict_subinventories_code;
            g_restrict_locators_code := l_restrict_locators_code;
          END IF; -- inventory item matches
        END IF; -- restrict subs is null

        IF l_restrict_subinventories_code = 1 and x_trolin_tbl(l_index).from_subinventory_code is NOT NULL Then
          BEGIN
           SELECT 'Y'
              INTO l_result
                   FROM DUAL
                 WHERE exists (
                     SELECT secondary_inventory
                       FROM mtl_item_sub_inventories
                      WHERE organization_id = x_trolin_tbl(l_index).organization_id
                      AND secondary_inventory = x_trolin_tbl(l_index).from_subinventory_code
                      AND inventory_item_id = x_trolin_tbl(l_index).inventory_item_id);
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
	       print_debug('From Subinventory is not in list of restricted sub inventory', l_api_name);
               x_trolin_tbl(l_index).return_status := fnd_api.g_ret_sts_error;
           END;
        END IF;
      END IF; -- From sub is not null
--END bug#8608683


      IF x_trolin_tbl(l_index).return_status = fnd_api.g_ret_sts_success THEN --{

        l_return_value := INV_CACHE.set_item_rec( p_organization_id   => x_trolin_tbl(l_index).organization_id
                             ,p_item_id           => x_trolin_tbl(l_index).inventory_item_id);

        IF NOT l_return_value Then
          print_debug('Error setting cache for inventory_item', l_api_name);
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_reservable_type := INV_CACHE.item_rec.reservable_type;

        IF l_reservable_type = 2 then
          l_found_backorder_cache := FALSE;
        ELSE
          l_found_backorder_cache := inv_pick_release_pvt.check_backorder_cache(
                   p_org_id        => x_trolin_tbl(l_index).organization_id
                  ,p_inventory_item_id    => x_trolin_tbl(l_index).inventory_item_id
                  ,p_ignore_reservations    => FALSE
                  ,p_demand_line_id    => x_trolin_tbl(l_index).txn_source_line_id);
        END IF;

        IF l_found_backorder_cache THEN
          IF l_current_ship_set_id IS NOT NULL THEN
            BEGIN
              l_shipset_smc_backorder_rec.delivery_detail_id := x_trolin_tbl(l_index).txn_source_line_detail_id;
              l_shipset_smc_backorder_rec.ship_set_id := l_current_ship_set_id;

              If l_debug = 1 THEN
                  print_debug('Calling BO SS for WDD = '||x_trolin_tbl(l_index).txn_source_line_detail_id||', SS_ID = '||l_current_ship_set_id,l_api_name);
              End If;

              wsh_integration.ins_backorder_ss_smc_rec
                    (p_api_version_number => 1.0,
                     p_source_code        => 'INV',
                     p_init_msg_list      => fnd_api.g_false,
                     p_backorder_rec      => l_shipset_smc_backorder_rec,
                     x_return_status      => l_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                 print_debug('Error occured while updating shipping for ' || 'failed ship set',l_api_name);
                 print_debug('l_return_status: ' || l_return_status, l_api_name);
              END IF;

            EXCEPTION
              WHEN OTHERS THEN
                  print_debug('When other exception: ' || Sqlerrm, l_api_name);
                  print_debug('l_return_status: ' || l_return_status, l_api_name);
            END;

          -- Bug 7148749, added for ship model complete handling
          ELSIF l_current_ship_model_id IS NOT NULL THEN
            BEGIN
              l_shipset_smc_backorder_rec.delivery_detail_id := x_trolin_tbl(l_index).txn_source_line_detail_id;
              l_shipset_smc_backorder_rec.ship_model_id := l_current_ship_model_id;

              If l_debug = 1 THEN
                print_debug('Calling BO SMC for WDD = '||x_trolin_tbl(l_index).txn_source_line_detail_id||', Model_ID = '||l_current_ship_model_id,l_api_name);
              End If;

              wsh_integration.ins_backorder_ss_smc_rec
                (p_api_version_number => 1.0,
                 p_source_code        => 'INV',
                 p_init_msg_list      => fnd_api.g_false,
                 p_backorder_rec      => l_shipset_smc_backorder_rec,
                 x_return_status      => l_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                print_debug('Error occured while updating shipping for ' || 'failed ship set',l_api_name);
                print_debug('l_return_status: ' || l_return_status, l_api_name);
              END IF;

            EXCEPTION
              WHEN OTHERS THEN
                  print_debug('When other exception: ' || Sqlerrm, l_api_name);
                  print_debug('l_return_status: ' || l_return_status, l_api_name);
            END;
          -- End Bug 7148749
          END IF;
          x_trolin_tbl(l_index).return_status:= fnd_api.g_ret_sts_error;
        END IF;
      END IF; -- x_trolin_tbl(l_index).return_status = fnd_api.g_ret_sts_success }

      IF x_trolin_tbl(l_index).return_status = fnd_api.g_ret_sts_error THEN --{
        IF l_current_ship_set_id is NOT NULL THEN  --{
          ROLLBACK to SHIPSET_SP;
          l_index := l_shipset_start_index;
          LOOP
            IF not x_trolin_tbl.exists(l_index) THEN
                 x_trolin_tbl(l_index) := p_trolin_tbl(l_index);
            END IF;
            IF l_found_backorder_cache THEN  --{

              l_shipping_attr(1).source_line_id := x_trolin_tbl(l_index).txn_source_line_id;
              l_shipping_attr(1).ship_from_org_id := x_trolin_tbl(l_index).organization_id;
              l_shipping_attr(1).delivery_detail_id := x_trolin_tbl(l_index).txn_source_line_detail_id;
              l_shipping_attr(1).action_flag := 'B';

              WSH_INTERFACE.Update_Shipping_Attributes
                (p_source_code               => 'INV',
                 p_changed_attributes        => l_shipping_attr,
                 x_return_status             => l_return_status
                );

              IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
                print_debug('return error from update shipping attributes',l_api_name);
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                print_debug('return error from update shipping attributes',l_api_name);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;  --} backorder_flag
            x_trolin_tbl(l_index).return_status := fnd_api.g_ret_sts_error;
            EXIT WHEN l_index = p_trolin_tbl.LAST;
            l_index := p_trolin_tbl.NEXT(l_index);

            IF p_trolin_tbl(l_index).ship_set_id IS NULL OR
              p_trolin_tbl(l_index).ship_set_id = fnd_api.g_miss_num OR
              p_trolin_tbl(l_index).ship_set_id <> nvl(l_current_ship_set_id, -9999) THEN
              l_index := p_trolin_tbl.prior(l_index);
              EXIT;
            END IF;
          END LOOP; --loop for all records in shipset
          l_current_ship_set_id := NULL;
          l_shipset_start_index := NULL;
        ELSIF l_current_ship_model_id IS NOT NULL THEN  --l_current_ship_set_id } {
          ROLLBACK to SHIPMODEL_SP;
          l_index := l_shipmodel_start_index;
          LOOP
            IF not x_trolin_tbl.exists(l_index) THEN
              x_trolin_tbl(l_index) := p_trolin_tbl(l_index);
            END IF;
            IF l_found_backorder_cache THEN --{
              l_shipping_attr(1).source_line_id := x_trolin_tbl(l_index).txn_source_line_id;
              l_shipping_attr(1).ship_from_org_id := x_trolin_tbl(l_index).organization_id;
              l_shipping_attr(1).delivery_detail_id := x_trolin_tbl(l_index).txn_source_line_detail_id;
              l_shipping_attr(1).action_flag := 'B';

              If l_debug = 1 THEN
                print_debug('Backordering WDD = '||x_trolin_tbl(l_index).txn_source_line_detail_id||', MODEL_ID = '||l_current_ship_model_id,l_api_name);
              End If;

              WSH_INTERFACE.Update_Shipping_Attributes
                (p_source_code               => 'INV',
                 p_changed_attributes        => l_shipping_attr,
                 x_return_status             => l_return_status
                );
              IF l_return_status = FND_API.G_RET_STS_ERROR then
                print_debug('return error from update shipping attributes',l_api_name);
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                print_debug('return error from update shipping attributes',l_api_name);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF; -- l_back_order_flag }
            x_trolin_tbl(l_index).return_status := fnd_api.g_ret_sts_error;

            EXIT WHEN l_index = p_trolin_tbl.LAST;
            l_index := p_trolin_tbl.NEXT(l_index);

            IF p_trolin_tbl(l_index).ship_model_id IS NULL OR
              p_trolin_tbl(l_index).ship_model_id = fnd_api.g_miss_num OR
              p_trolin_tbl(l_index).ship_model_id <> nvl(l_current_ship_model_id, -9999) THEN
              l_index := p_trolin_tbl.prior(l_index);
              EXIT;
            END IF;
          END LOOP; --loop for all records in ship model
          l_current_ship_model_id := NULL;
          l_shipmodel_start_index := NULL;

        ELSE -- l_current_ship_set_id } {

          IF l_found_backorder_cache THEN --{

            l_shipping_attr(1).source_line_id := x_trolin_tbl(l_index).txn_source_line_id;
            l_shipping_attr(1).ship_from_org_id := x_trolin_tbl(l_index).organization_id;
            l_shipping_attr(1).delivery_detail_id := x_trolin_tbl(l_index).txn_source_line_detail_id;
            l_shipping_attr(1).action_flag := 'B';

            WSH_INTERFACE.Update_Shipping_Attributes
              (p_source_code               => 'INV',
               p_changed_attributes        => l_shipping_attr,
               x_return_status             => l_return_status
              );

            IF l_return_status = FND_API.G_RET_STS_ERROR then
              print_debug('return error from update shipping attributes',l_api_name);
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              print_debug('return error from update shipping attributes',l_api_name);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF; -- l_back_order_flag }
          x_trolin_tbl(l_index).return_status := fnd_api.g_ret_sts_error;
        END IF; -- l_current_ship_set_id }
    --Bug 7148749, moving this after the loop, so that the new move order lines table
    --l_new_trolin_tbl gets populated only when all the lines in x_trolin_tbl are validated.
   /* ELSE --} {
        --print_debug('in insert',l_api_name);
        SELECT  MTL_TXN_REQUEST_LINES_S.NEXTVAL
         INTO  x_trolin_tbl(l_index).line_id
        FROM  DUAL;
        x_trolin_tbl(l_index).status_date     := SYSDATE;
        x_trolin_tbl(l_index).creation_date      := SYSDATE;
        x_trolin_tbl(l_index).created_by         := fnd_global.user_id;
        x_trolin_tbl(l_index).last_update_date   := SYSDATE;
        x_trolin_tbl(l_index).last_updated_by    := fnd_global.user_id;
        x_trolin_tbl(l_index).last_update_login  := fnd_global.login_id;
        x_trolin_tbl(l_index).return_status := fnd_api.g_ret_sts_success;
        x_trolin_tbl(l_index) := inv_trolin_util.convert_miss_to_null_parallel
                                (p_trolin_rec => x_trolin_tbl(l_index));

            l_new_trolin_tbl(l_count).attribute1  :=  x_trolin_tbl(l_index).attribute1;
        l_new_trolin_tbl(l_count).attribute10 := x_trolin_tbl(l_index).attribute10;
        l_new_trolin_tbl(l_count).attribute11 := x_trolin_tbl(l_index).attribute11;
        l_new_trolin_tbl(l_count).attribute12 := x_trolin_tbl(l_index).attribute12;
        l_new_trolin_tbl(l_count).attribute13 := x_trolin_tbl(l_index).attribute13;
        l_new_trolin_tbl(l_count).attribute14 := x_trolin_tbl(l_index).attribute14;
        l_new_trolin_tbl(l_count).attribute15 := x_trolin_tbl(l_index).attribute15;
        l_new_trolin_tbl(l_count).attribute2  := x_trolin_tbl(l_index).attribute2;
        l_new_trolin_tbl(l_count).attribute3  := x_trolin_tbl(l_index).attribute3;
        l_new_trolin_tbl(l_count).attribute4  := x_trolin_tbl(l_index).attribute4;
        l_new_trolin_tbl(l_count).attribute5  := x_trolin_tbl(l_index).attribute5;
        l_new_trolin_tbl(l_count).attribute6  := x_trolin_tbl(l_index).attribute6;
        l_new_trolin_tbl(l_count).attribute7  := x_trolin_tbl(l_index).attribute7;
        l_new_trolin_tbl(l_count).attribute8  := x_trolin_tbl(l_index).attribute8;
        l_new_trolin_tbl(l_count).attribute9  := x_trolin_tbl(l_index).attribute9;
        l_new_trolin_tbl(l_count).attribute_category  := x_trolin_tbl(l_index).attribute_category;
        l_new_trolin_tbl(l_count).created_by      := x_trolin_tbl(l_index).created_by;
        l_new_trolin_tbl(l_count).creation_date     := x_trolin_tbl(l_index).creation_date;
        l_new_trolin_tbl(l_count).date_required      := x_trolin_tbl(l_index).date_required;
        l_new_trolin_tbl(l_count).from_locator_id      := x_trolin_tbl(l_index).from_locator_id;
        l_new_trolin_tbl(l_count).from_subinventory_code  := x_trolin_tbl(l_index).from_subinventory_code;
        l_new_trolin_tbl(l_count).from_subinventory_id    := x_trolin_tbl(l_index).from_subinventory_id;
        l_new_trolin_tbl(l_count).header_id          := x_trolin_tbl(l_index).header_id;
        l_new_trolin_tbl(l_count).inventory_item_id      := x_trolin_tbl(l_index).inventory_item_id;
        l_new_trolin_tbl(l_count).last_updated_by      := x_trolin_tbl(l_index).last_updated_by;
        l_new_trolin_tbl(l_count).last_update_date      := x_trolin_tbl(l_index).last_update_date;
        l_new_trolin_tbl(l_count).last_update_login      := x_trolin_tbl(l_index).last_update_login;
        l_new_trolin_tbl(l_count).line_id          := x_trolin_tbl(l_index).line_id;
        l_new_trolin_tbl(l_count).line_number      := x_trolin_tbl(l_index).line_number;
        l_new_trolin_tbl(l_count).line_status      := x_trolin_tbl(l_index).line_status;
        l_new_trolin_tbl(l_count).lot_number      := x_trolin_tbl(l_index).lot_number;
        l_new_trolin_tbl(l_count).organization_id      := x_trolin_tbl(l_index).organization_id;
        l_new_trolin_tbl(l_count).program_application_id  := x_trolin_tbl(l_index).program_application_id;
        l_new_trolin_tbl(l_count).program_id      := x_trolin_tbl(l_index).program_id;
        l_new_trolin_tbl(l_count).program_update_date := x_trolin_tbl(l_index).program_update_date;
        l_new_trolin_tbl(l_count).project_id      := x_trolin_tbl(l_index).project_id;
        l_new_trolin_tbl(l_count).quantity          := x_trolin_tbl(l_index).quantity;
        l_new_trolin_tbl(l_count).quantity_delivered  := x_trolin_tbl(l_index).quantity_delivered;
        l_new_trolin_tbl(l_count).quantity_detailed      := x_trolin_tbl(l_index).quantity_detailed;
        l_new_trolin_tbl(l_count).reason_id          := x_trolin_tbl(l_index).reason_id;
        l_new_trolin_tbl(l_count).REFERENCE          := x_trolin_tbl(l_index).REFERENCE;
        l_new_trolin_tbl(l_count).reference_id      := x_trolin_tbl(l_index).reference_id;
        l_new_trolin_tbl(l_count).reference_type_code := x_trolin_tbl(l_index).reference_type_code;
        l_new_trolin_tbl(l_count).request_id      := x_trolin_tbl(l_index).request_id;
        l_new_trolin_tbl(l_count).revision          := x_trolin_tbl(l_index).revision;
        l_new_trolin_tbl(l_count).serial_number_end      := x_trolin_tbl(l_index).serial_number_end;
        l_new_trolin_tbl(l_count).serial_number_start := x_trolin_tbl(l_index).serial_number_start;
        l_new_trolin_tbl(l_count).status_date      := x_trolin_tbl(l_index).status_date;
        l_new_trolin_tbl(l_count).task_id          := x_trolin_tbl(l_index).task_id;
        l_new_trolin_tbl(l_count).to_account_id      := x_trolin_tbl(l_index).to_account_id;
        l_new_trolin_tbl(l_count).to_locator_id      := x_trolin_tbl(l_index).to_locator_id;
        l_new_trolin_tbl(l_count).to_subinventory_code  := x_trolin_tbl(l_index).to_subinventory_code;
        l_new_trolin_tbl(l_count).to_subinventory_id  := x_trolin_tbl(l_index).to_subinventory_id;
        l_new_trolin_tbl(l_count).transaction_header_id := x_trolin_tbl(l_index).transaction_header_id;
        l_new_trolin_tbl(l_count).uom_code          := x_trolin_tbl(l_index).uom_code;
        l_new_trolin_tbl(l_count).transaction_type_id := x_trolin_tbl(l_index).transaction_type_id;
        l_new_trolin_tbl(l_count).transaction_source_type_id  := x_trolin_tbl(l_index).transaction_source_type_id;
        l_new_trolin_tbl(l_count).txn_source_id      := x_trolin_tbl(l_index).txn_source_id;
        l_new_trolin_tbl(l_count).txn_source_line_id  := x_trolin_tbl(l_index).txn_source_line_id;
        l_new_trolin_tbl(l_count).txn_source_line_detail_id      := x_trolin_tbl(l_index).txn_source_line_detail_id;
        l_new_trolin_tbl(l_count).to_organization_id  := x_trolin_tbl(l_index).to_organization_id;
        l_new_trolin_tbl(l_count).primary_quantity      := x_trolin_tbl(l_index).primary_quantity;
        l_new_trolin_tbl(l_count).pick_strategy_id      := x_trolin_tbl(l_index).pick_strategy_id;
        l_new_trolin_tbl(l_count).put_away_strategy_id      := x_trolin_tbl(l_index).put_away_strategy_id;
        l_new_trolin_tbl(l_count).unit_number  := x_trolin_tbl(l_index).unit_number;
        l_new_trolin_tbl(l_count).ship_to_location_id := x_trolin_tbl(l_index).ship_to_location_id;
        l_new_trolin_tbl(l_count).from_cost_group_id  := x_trolin_tbl(l_index).from_cost_group_id;
        l_new_trolin_tbl(l_count).to_cost_group_id      := x_trolin_tbl(l_index).to_cost_group_id;
        l_new_trolin_tbl(l_count).lpn_id          := x_trolin_tbl(l_index).lpn_id;
        l_new_trolin_tbl(l_count).to_lpn_id          := x_trolin_tbl(l_index).to_lpn_id;
        l_new_trolin_tbl(l_count).inspection_status      := x_trolin_tbl(l_index).inspection_status;
        l_new_trolin_tbl(l_count).pick_methodology_id := x_trolin_tbl(l_index).pick_methodology_id;
        l_new_trolin_tbl(l_count).container_item_id      := x_trolin_tbl(l_index).container_item_id;
        l_new_trolin_tbl(l_count).carton_grouping_id  := x_trolin_tbl(l_index).carton_grouping_id;
        l_new_trolin_tbl(l_count).wms_process_flag  := x_trolin_tbl(l_index).wms_process_flag;
        l_new_trolin_tbl(l_count).pick_slip_number  := x_trolin_tbl(l_index).pick_slip_number;
        l_new_trolin_tbl(l_count).pick_slip_date    := x_trolin_tbl(l_index).pick_slip_date;
        l_new_trolin_tbl(l_count).ship_set_id      := x_trolin_tbl(l_index).ship_set_id;
        l_new_trolin_tbl(l_count).ship_model_id      := x_trolin_tbl(l_index).ship_model_id;
        l_new_trolin_tbl(l_count).model_quantity      := x_trolin_tbl(l_index).model_quantity;
        l_new_trolin_tbl(l_count).required_quantity      := x_trolin_tbl(l_index).required_quantity;
        l_new_trolin_tbl(l_count).crossdock_type     := NULL;
        l_new_trolin_tbl(l_count).backorder_delivery_detail_id := NULL;
        l_new_trolin_tbl(l_count).assignment_id    := NULL;
        l_new_trolin_tbl(l_count).reference_detail_id    := NULL;

-- Added for INVCONV BEGIN
        l_new_trolin_tbl(l_count).secondary_quantity    := x_trolin_tbl(l_index).secondary_quantity;
        l_new_trolin_tbl(l_count).secondary_uom_code    := x_trolin_tbl(l_index).secondary_uom;
        l_new_trolin_tbl(l_count).secondary_quantity_detailed   := x_trolin_tbl(l_index).secondary_quantity_detailed;
        l_new_trolin_tbl(l_count).secondary_quantity_delivered  := x_trolin_tbl(l_index).secondary_quantity_delivered;
        l_new_trolin_tbl(l_count).secondary_required_quantity   := x_trolin_tbl(l_index).secondary_required_quantity;
        l_new_trolin_tbl(l_count).grade_code    := x_trolin_tbl(l_index).grade_code;
-- INVCONV END

        l_count := l_count+1;
      */ -- Bug 7148749
      END IF; --  x_trolin_tbl(l_index).return_status = fnd_api.g_ret_sts_error   }
    -- gmi_reservation_util.println('- PAL inside Create_Move_Order_Lines ');
      /* Bug 4162173 Added the following to initate the Outbound for Third Party Integration */
      OPEN get_move_order_type(x_trolin_tbl(l_index).header_id);
      FETCH get_move_order_type INTO l_move_order_type;
      CLOSE get_move_order_type;

      IF (l_move_order_type = 3) AND
        (x_trolin_tbl(l_index).txn_source_line_id IS NOT NULL) THEN
        OPEN get_sales_order(x_trolin_tbl(l_index).txn_source_line_id);
        FETCH get_sales_order INTO l_order_number ,l_org_id; -- 6689912
        CLOSE get_sales_order;
        --          gmi_reservation_util.println('- PAL about to call GR_WF_UTIL_PUB.INITIATE_PROCESS_SALES_ORDER ');
        GR_WF_UTIL_PUB.INITIATE_PROCESS_SALES_ORDER
            (p_api_version         => 1.0,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             p_sales_order_org_id  => l_org_id,  -- 6689912
             p_orgn_id             => x_trolin_tbl(l_index).organization_id,
             p_item_id             => x_trolin_tbl(l_index).inventory_item_id,
             p_sales_order_no      => l_order_number,
             x_return_status       => l_return_status,
             x_error_code          => l_error_code,
             x_msg_data            => l_msg_data);

         IF l_return_status <> 'S' THEN
            WSH_Util_Core.PrintLn('Error occured on initiate the Outbound to Partner Application ' ||
                                  'with the following error message ' || l_msg_data);
            --gmi_reservation_util.println('- PAL - called GR_WF_UTIL_PUB.INITIATE_PROCESS_SALES_ORDER -  Error occured ');
         ELSE
            --gmi_reservation_util.println('- PAL - called GR_WF_UTIL_PUB.INITIATE_PROCESS_SALES_ORDER -  success ');
            WSH_Util_Core.PrintLn('Successfully initiated the Outbound to Partner Application => ' ||
                                   x_trolin_tbl(l_index).inventory_item_id);
         END IF;
      END IF;

      -- Bug 5311250: null out TO_LOCATOR_ID if TO SUB has locator control
      -- set to item level, and item is not locator controlled
      IF (l_move_order_type = 3) THEN
        OPEN get_sub_loc_ctrl (x_trolin_tbl(l_index).organization_id
                             ,x_trolin_tbl(l_index).to_subinventory_code);
        FETCH get_sub_loc_ctrl INTO l_sub_loc_ctrl;
        CLOSE get_sub_loc_ctrl;
        IF l_sub_loc_ctrl = 5 THEN
          BEGIN
             l_item_loc_ctrl := INV_CACHE.item_rec.location_control_code;
          EXCEPTION
             WHEN OTHERS THEN
                print_debug('Exception retrieving item locator control from cache ' || sqlerrm
                           ,'INV_Move_Order_PUB.Create_Move_Order_Lines');
                l_item_loc_ctrl := 0;
          END;
          IF l_item_loc_ctrl IS NULL OR l_item_loc_ctrl = 0 THEN
             OPEN get_item_loc_ctrl (x_trolin_tbl(l_index).organization_id
                                    ,x_trolin_tbl(l_index).inventory_item_id);
             FETCH get_item_loc_ctrl INTO l_item_loc_ctrl;
             CLOSE get_item_loc_ctrl;
          END IF;
          IF l_item_loc_ctrl = 1 THEN
             x_trolin_tbl(l_index).to_locator_id := NULL;
             -- Bug 7148749, commenting the below line, since l_new_trolin_tbl population code is moved below.
             -- l_new_trolin_tbl(l_count - 1).to_locator_id := NULL;
          END IF;
        END IF;
      END IF;

      --print_debug('return_status '|| x_trolin_tbl(l_index).return_status, l_api_name);
      EXIT WHEN l_index = p_trolin_tbl.LAST;
      l_index := p_trolin_tbl.NEXT(l_index);
    END LOOP;  -- loop throUgh p_trolin_tbl

    --Bug 7148749, populating l_new_trolin_tbl only after all the records in x_trolin_tbl
 	  --have been successfully validated, so that entire ship set can be handled.
 	  l_index := x_trolin_tbl.FIRST;
 	  l_count := 1;
 	  Loop
 	    If x_trolin_tbl(l_index).return_status = fnd_api.g_ret_sts_success THEN

        If l_debug = 1 THEN
           print_debug('Creating MO Line for WDD = '||x_trolin_tbl(l_index).txn_source_line_detail_id,l_api_name);
        End If;
        SELECT  MTL_TXN_REQUEST_LINES_S.NEXTVAL
          INTO  x_trolin_tbl(l_index).line_id
          FROM  DUAL;

        x_trolin_tbl(l_index).status_date       := SYSDATE;
        x_trolin_tbl(l_index).creation_date     := SYSDATE;
        x_trolin_tbl(l_index).created_by        := fnd_global.user_id;
        x_trolin_tbl(l_index).last_update_date  := SYSDATE;
        x_trolin_tbl(l_index).last_updated_by   := fnd_global.user_id;
        x_trolin_tbl(l_index).last_update_login := fnd_global.login_id;
        x_trolin_tbl(l_index).return_status     := fnd_api.g_ret_sts_success;
        x_trolin_tbl(l_index)                   := inv_trolin_util.convert_miss_to_null_parallel
                                                        (p_trolin_rec => x_trolin_tbl(l_index));

        l_new_trolin_tbl(l_count).attribute1                    := x_trolin_tbl(l_index).attribute1;
        l_new_trolin_tbl(l_count).attribute10                   := x_trolin_tbl(l_index).attribute10;
        l_new_trolin_tbl(l_count).attribute11                   := x_trolin_tbl(l_index).attribute11;
        l_new_trolin_tbl(l_count).attribute12                   := x_trolin_tbl(l_index).attribute12;
        l_new_trolin_tbl(l_count).attribute13                   := x_trolin_tbl(l_index).attribute13;
        l_new_trolin_tbl(l_count).attribute14                   := x_trolin_tbl(l_index).attribute14;
        l_new_trolin_tbl(l_count).attribute15                   := x_trolin_tbl(l_index).attribute15;
        l_new_trolin_tbl(l_count).attribute2                    := x_trolin_tbl(l_index).attribute2;
        l_new_trolin_tbl(l_count).attribute3                    := x_trolin_tbl(l_index).attribute3;
        l_new_trolin_tbl(l_count).attribute4                    := x_trolin_tbl(l_index).attribute4;
        l_new_trolin_tbl(l_count).attribute5                    := x_trolin_tbl(l_index).attribute5;
        l_new_trolin_tbl(l_count).attribute6                    := x_trolin_tbl(l_index).attribute6;
        l_new_trolin_tbl(l_count).attribute7                    := x_trolin_tbl(l_index).attribute7;
        l_new_trolin_tbl(l_count).attribute8                    := x_trolin_tbl(l_index).attribute8;
        l_new_trolin_tbl(l_count).attribute9                    := x_trolin_tbl(l_index).attribute9;
        l_new_trolin_tbl(l_count).attribute_category            := x_trolin_tbl(l_index).attribute_category;
        l_new_trolin_tbl(l_count).created_by                    := x_trolin_tbl(l_index).created_by;
        l_new_trolin_tbl(l_count).creation_date                 := x_trolin_tbl(l_index).creation_date;
        l_new_trolin_tbl(l_count).date_required                 := x_trolin_tbl(l_index).date_required;
        l_new_trolin_tbl(l_count).from_locator_id               := x_trolin_tbl(l_index).from_locator_id;
        l_new_trolin_tbl(l_count).from_subinventory_code        := x_trolin_tbl(l_index).from_subinventory_code;
        l_new_trolin_tbl(l_count).from_subinventory_id          := x_trolin_tbl(l_index).from_subinventory_id;
        l_new_trolin_tbl(l_count).header_id                     := x_trolin_tbl(l_index).header_id;
        l_new_trolin_tbl(l_count).inventory_item_id             := x_trolin_tbl(l_index).inventory_item_id;
        l_new_trolin_tbl(l_count).last_updated_by               := x_trolin_tbl(l_index).last_updated_by;
        l_new_trolin_tbl(l_count).last_update_date              := x_trolin_tbl(l_index).last_update_date;
        l_new_trolin_tbl(l_count).last_update_login             := x_trolin_tbl(l_index).last_update_login;
        l_new_trolin_tbl(l_count).line_id                       := x_trolin_tbl(l_index).line_id;
        l_new_trolin_tbl(l_count).line_number                   := x_trolin_tbl(l_index).line_number;
        l_new_trolin_tbl(l_count).line_status                   := x_trolin_tbl(l_index).line_status;
        l_new_trolin_tbl(l_count).lot_number                    := x_trolin_tbl(l_index).lot_number;
        l_new_trolin_tbl(l_count).organization_id               := x_trolin_tbl(l_index).organization_id;
        l_new_trolin_tbl(l_count).program_application_id        := x_trolin_tbl(l_index).program_application_id;
        l_new_trolin_tbl(l_count).program_id                    := x_trolin_tbl(l_index).program_id;
        l_new_trolin_tbl(l_count).program_update_date           := x_trolin_tbl(l_index).program_update_date;
        l_new_trolin_tbl(l_count).project_id                    := x_trolin_tbl(l_index).project_id;
        l_new_trolin_tbl(l_count).quantity                      := x_trolin_tbl(l_index).quantity;
        l_new_trolin_tbl(l_count).quantity_delivered            := x_trolin_tbl(l_index).quantity_delivered;
        l_new_trolin_tbl(l_count).quantity_detailed             := x_trolin_tbl(l_index).quantity_detailed;
        l_new_trolin_tbl(l_count).reason_id                     := x_trolin_tbl(l_index).reason_id;
        l_new_trolin_tbl(l_count).REFERENCE                     := x_trolin_tbl(l_index).REFERENCE;
        l_new_trolin_tbl(l_count).reference_id                  := x_trolin_tbl(l_index).reference_id;
        l_new_trolin_tbl(l_count).reference_type_code           := x_trolin_tbl(l_index).reference_type_code;
        l_new_trolin_tbl(l_count).request_id                    := x_trolin_tbl(l_index).request_id;
        l_new_trolin_tbl(l_count).revision                      := x_trolin_tbl(l_index).revision;
        l_new_trolin_tbl(l_count).serial_number_end             := x_trolin_tbl(l_index).serial_number_end;
        l_new_trolin_tbl(l_count).serial_number_start           := x_trolin_tbl(l_index).serial_number_start;
        l_new_trolin_tbl(l_count).status_date                   := x_trolin_tbl(l_index).status_date;
        l_new_trolin_tbl(l_count).task_id                       := x_trolin_tbl(l_index).task_id;
        l_new_trolin_tbl(l_count).to_account_id                 := x_trolin_tbl(l_index).to_account_id;
        l_new_trolin_tbl(l_count).to_locator_id                 := x_trolin_tbl(l_index).to_locator_id;
        l_new_trolin_tbl(l_count).to_subinventory_code          := x_trolin_tbl(l_index).to_subinventory_code;
        l_new_trolin_tbl(l_count).to_subinventory_id            := x_trolin_tbl(l_index).to_subinventory_id;
        l_new_trolin_tbl(l_count).transaction_header_id         := x_trolin_tbl(l_index).transaction_header_id;
        l_new_trolin_tbl(l_count).uom_code                      := x_trolin_tbl(l_index).uom_code;
        l_new_trolin_tbl(l_count).transaction_type_id           := x_trolin_tbl(l_index).transaction_type_id;
        l_new_trolin_tbl(l_count).transaction_source_type_id    := x_trolin_tbl(l_index).transaction_source_type_id;
        l_new_trolin_tbl(l_count).txn_source_id                 := x_trolin_tbl(l_index).txn_source_id;
        l_new_trolin_tbl(l_count).txn_source_line_id            := x_trolin_tbl(l_index).txn_source_line_id;
        l_new_trolin_tbl(l_count).txn_source_line_detail_id     := x_trolin_tbl(l_index).txn_source_line_detail_id;
        l_new_trolin_tbl(l_count).to_organization_id            := x_trolin_tbl(l_index).to_organization_id;
        l_new_trolin_tbl(l_count).primary_quantity              := x_trolin_tbl(l_index).primary_quantity;
        l_new_trolin_tbl(l_count).pick_strategy_id              := x_trolin_tbl(l_index).pick_strategy_id;
        l_new_trolin_tbl(l_count).put_away_strategy_id          := x_trolin_tbl(l_index).put_away_strategy_id;
        l_new_trolin_tbl(l_count).unit_number                   := x_trolin_tbl(l_index).unit_number;
        l_new_trolin_tbl(l_count).ship_to_location_id           := x_trolin_tbl(l_index).ship_to_location_id;
        l_new_trolin_tbl(l_count).from_cost_group_id            := x_trolin_tbl(l_index).from_cost_group_id;
        l_new_trolin_tbl(l_count).to_cost_group_id              := x_trolin_tbl(l_index).to_cost_group_id;
        l_new_trolin_tbl(l_count).lpn_id                        := x_trolin_tbl(l_index).lpn_id;
        l_new_trolin_tbl(l_count).to_lpn_id                     := x_trolin_tbl(l_index).to_lpn_id;
        l_new_trolin_tbl(l_count).inspection_status             := x_trolin_tbl(l_index).inspection_status;
        l_new_trolin_tbl(l_count).pick_methodology_id           := x_trolin_tbl(l_index).pick_methodology_id;
        l_new_trolin_tbl(l_count).container_item_id             := x_trolin_tbl(l_index).container_item_id;
        l_new_trolin_tbl(l_count).carton_grouping_id            := x_trolin_tbl(l_index).carton_grouping_id;
        l_new_trolin_tbl(l_count).wms_process_flag              := x_trolin_tbl(l_index).wms_process_flag;
        l_new_trolin_tbl(l_count).pick_slip_number              := x_trolin_tbl(l_index).pick_slip_number;
        l_new_trolin_tbl(l_count).pick_slip_date                := x_trolin_tbl(l_index).pick_slip_date;
        l_new_trolin_tbl(l_count).ship_set_id                   := x_trolin_tbl(l_index).ship_set_id;
        l_new_trolin_tbl(l_count).ship_model_id                 := x_trolin_tbl(l_index).ship_model_id;
        l_new_trolin_tbl(l_count).model_quantity                := x_trolin_tbl(l_index).model_quantity;
        l_new_trolin_tbl(l_count).required_quantity             := x_trolin_tbl(l_index).required_quantity;
        l_new_trolin_tbl(l_count).crossdock_type                := NULL;
        l_new_trolin_tbl(l_count).backorder_delivery_detail_id  := NULL;
        l_new_trolin_tbl(l_count).assignment_id                 := NULL;
        l_new_trolin_tbl(l_count).reference_detail_id           := NULL;

 	 -- Added for INVCONV BEGIN
        l_new_trolin_tbl(l_count).secondary_quantity            := x_trolin_tbl(l_index).secondary_quantity;
        l_new_trolin_tbl(l_count).secondary_uom_code            := x_trolin_tbl(l_index).secondary_uom;
        l_new_trolin_tbl(l_count).secondary_quantity_detailed   := x_trolin_tbl(l_index).secondary_quantity_detailed;
        l_new_trolin_tbl(l_count).secondary_quantity_delivered  := x_trolin_tbl(l_index).secondary_quantity_delivered;
        l_new_trolin_tbl(l_count).secondary_required_quantity   := x_trolin_tbl(l_index).secondary_required_quantity;
        l_new_trolin_tbl(l_count).grade_code                    := x_trolin_tbl(l_index).grade_code;
 	 -- INVCONV END

 	      l_count := l_count+1;
 	    End If;
 	    EXIT WHEN l_index = x_trolin_tbl.LAST;
 	    l_index := x_trolin_tbl.NEXT(l_index);
 	  End Loop;

 	  If l_debug = 1 THEN
 	    print_debug('l_new_trolin_tbl Count = '||l_new_trolin_tbl.count||', x_trolin_tbl Count = '||x_trolin_tbl.count
                  ||', p_trolin_tbl Count = '||p_trolin_tbl.count,l_api_name);
 	  End If;
    -- End bug 7148749

    x_return_status := fnd_api.g_ret_sts_success;

    inv_trolin_util.insert_mo_lines_bulk
                  (p_new_trolin_tbl => l_new_trolin_tbl
                  ,x_return_status => x_return_status);

    --delete the records from l_new_trolin_tbl
    l_new_trolin_tbl.delete;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
       print_debug('return error from INSERT_MO_LINES_BULK',l_api_name);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSE   --} Validation Yes
    l_control_rec.controlled_operation := TRUE;
    l_control_Rec.process_entity := INV_GLOBALS.G_ENTITY_TROLIN;
    l_control_Rec.default_attributes := TRUE;
    l_control_rec.change_attributes := TRUE;
    l_control_rec.write_to_db := TRUE;
    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order
    if( l_trolin_tbl.count > 0 ) then
      for i in 1..l_trolin_tbl.count LOOP
        --inv_debug.message('trolin.line_id is ' || l_trolin_tbl(l).line_id);
/* to fix bug 1402677: Also we shouldn't change the operation here
        if( (l_trolin_tbl(i).line_id <> FND_API.G_MISS_NUM OR l_trolin_tbl(i).line_id is NULL ) AND
        l_trolin_tbl(i).operation = INV_GLOBALS.G_OPR_CREATE ) then
        l_trolin_tbl(i).operation := INV_GLOBALS.G_OPR_UPDATE;
        els*/
            if (l_trolin_tbl(i).operation = INV_GLOBALS.G_OPR_UPDATE and
        (l_trolin_tbl(i).line_id = FND_API.G_MISS_NUM OR
         l_trolin_tbl(i).line_id is null ) ) then
            --inv_debug.message('update and no line id');
          fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
        fnd_message.set_token('ATTRIBUTE', 'LINE_ID');
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
        end if;

        if( l_trolin_tbl(i).header_id is not null
        and l_trolin_tbl(i).header_id <> FND_API.G_MISS_NUM ) then
        --inv_debug.message('check if the header_id exists');
            select count(*)
            into l_dummy
        from mtl_txn_request_headers
            where header_id = l_trolin_tbl(i).header_id
            and organization_id = l_trolin_tbl(i).organization_id;
            --inv_debug.message('l_dummy is ' || l_dummy);
                if( l_dummy = 0 ) then
            --inv_debug.message('header id not found');
            FND_MESSAGE.SET_NAME('INV', 'INV_FIELD_INVALID');
            FND_MESSAGE.SET_TOKEN('ENTITY1', 'Header_Id');
            FND_MSG_PUB.ADD;
            raise fnd_api.g_exc_error;
        else
           l_trohdr_rec := inv_trohdr_util.query_row(p_header_id => l_trolin_tbl(i).header_id);
            end if;
        end if;

            /* Bug 4162173 Added the following to initate the Outbound for Third Party Integration */
            OPEN get_move_order_type(l_trolin_tbl(i).header_id);
            FETCH get_move_order_type INTO l_move_order_type;
            CLOSE get_move_order_type;

            IF (l_move_order_type = 3) AND
               (l_trolin_tbl(i).txn_source_line_id IS NOT NULL) THEN
               OPEN get_sales_order(l_trolin_tbl(i).txn_source_line_id);
               FETCH get_sales_order INTO l_order_number ,l_org_id;  -- 6689912
               CLOSE get_sales_order;

               GR_WF_UTIL_PUB.INITIATE_PROCESS_SALES_ORDER
                  (p_api_version         => 1.0,
                   p_init_msg_list       => p_init_msg_list,
                   p_commit              => p_commit,
                   p_sales_order_org_id  => l_org_id,  -- 6689912
                   p_orgn_id             => l_trolin_tbl(i).organization_id,
                   p_item_id             => l_trolin_tbl(i).inventory_item_id,
                   p_sales_order_no      => l_order_number,
                   x_return_status       => l_return_status,
                   x_error_code          => l_error_code,
                   x_msg_data            => l_msg_data);

               IF l_return_status <> 'S' THEN
                  WSH_Util_Core.PrintLn('Error occured on initiate the Outbound to Partner Application ' ||
                                        'with the following error message ' || l_msg_data);
               ELSE
                  --Jalaj Srivastava Bug 5695822
                  --table index used was l_index. should be i.
                  --table should be l_trolin_tbl instead of x_trolin_tbl
                  WSH_Util_Core.PrintLn('Successfully initiated the Outbound to Partner Application => ' ||
                                         l_trolin_tbl(i).inventory_item_id);
               END IF;
            END IF;

            -- Bug 5311250: null out TO_LOCATOR_ID if TO SUB has locator control
            -- set to item level, and item is not locator controlled
            IF (l_move_order_type = 3) THEN
               OPEN get_sub_loc_ctrl (l_trolin_tbl(i).organization_id
                                     ,l_trolin_tbl(i).to_subinventory_code);
               FETCH get_sub_loc_ctrl INTO l_sub_loc_ctrl;
               CLOSE get_sub_loc_ctrl;
               IF l_sub_loc_ctrl = 5 THEN
                  OPEN get_item_loc_ctrl (l_trolin_tbl(i).organization_id
                                         ,l_trolin_tbl(i).inventory_item_id);
                  FETCH get_item_loc_ctrl INTO l_item_loc_ctrl;
                  CLOSE get_item_loc_ctrl;
                  IF l_item_loc_ctrl = 1 THEN
                     l_trolin_tbl(i).to_locator_id := NULL;
                  END IF;
               END IF;
            END IF;
        end loop;
    end if;

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trohdr_rec                  => l_trohdr_rec
    ,   p_trohdr_val_rec              => l_trohdr_val_rec
    ,   p_trolin_tbl                  => l_trolin_tbl
    ,   p_trolin_val_tbl              => p_trolin_val_tbl
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl_out
    );

    --  Load Id OUT parameters.

    --x_trohdr_rec                   := p_trohdr_rec;
    x_trolin_tbl                   := l_trolin_tbl_out;

    if( p_commit = FND_API.G_TRUE ) Then
    commit;
    end if;
    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN
        Id_To_Value
        (   p_trohdr_rec                  => l_trohdr_rec
        ,   p_trolin_tbl                  => p_trolin_tbl
        ,   x_trohdr_val_rec              => l_trohdr_val_rec
        ,   x_trolin_val_tbl              => x_trolin_val_tbl
        );
    END IF;
  END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
    --inv_debug.message('returning error');
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Move_Order'
            );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END Create_Move_Order_Lines;

--  Start of Comments
--  API name    Process_Move_Order
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Move_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_trohdr_rec                    IN  Trohdr_Rec_Type     := G_MISS_TROHDR_REC
,   p_trohdr_val_rec                IN  Trohdr_Val_Rec_Type := G_MISS_TROHDR_VAL_REC
,   p_trolin_tbl                    IN  Trolin_Tbl_Type     := G_MISS_TROLIN_TBL
,   p_trolin_val_tbl                IN  Trolin_Val_Tbl_Type := G_MISS_TROLIN_VAL_TBL
,   x_trohdr_rec                    IN OUT NOCOPY Trohdr_Rec_Type
,   x_trohdr_val_rec                IN OUT NOCOPY Trohdr_Val_Rec_Type
,   x_trolin_tbl                    IN OUT NOCOPY Trolin_Tbl_Type
,   x_trolin_val_tbl                IN OUT NOCOPY Trolin_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Move_Order';
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_trohdr_rec                  Trohdr_Rec_Type;
l_trolin_tbl                  Trolin_Tbl_Type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_control_Rec.process_entity := INV_GLOBALS.G_ENTITY_ALL;
/*
    --  Perform Value to Id conversion
    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_trohdr_rec                  => p_trohdr_rec
    ,   p_trohdr_val_rec              => p_trohdr_val_rec
    ,   p_trolin_tbl                  => p_trolin_tbl
    ,   p_trolin_val_tbl              => p_trolin_val_tbl
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trohdr_rec                  => p_trohdr_rec
    ,   p_trohdr_val_rec              => p_trohdr_val_rec
    ,   p_trolin_tbl                  => p_trolin_tbl
    ,   p_trolin_val_tbl              => p_trolin_val_tbl
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl
    );

    --  Load Id OUT parameters.

    x_trohdr_rec                   := l_trohdr_rec;
    x_trolin_tbl                   := l_trolin_tbl;

    if p_commit = FND_API.G_TRUE then
    commit;
    end if;
    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN
        Id_To_Value
        (   p_trohdr_rec                  => p_trohdr_rec
        ,   p_trolin_tbl                  => p_trolin_tbl
        ,   x_trohdr_val_rec              => x_trohdr_val_rec
        ,   x_trolin_val_tbl              => x_trolin_val_tbl
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Move_Order'
            );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END Process_Move_Order;

--  Start of Comments
--  API name    Lock_Move_Order
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Move_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_trohdr_rec                    IN  Trohdr_Rec_Type :=
                                        G_MISS_TROHDR_REC
,   p_trohdr_val_rec                IN  Trohdr_Val_Rec_Type :=
                                        G_MISS_TROHDR_VAL_REC
,   p_trolin_tbl                    IN  Trolin_Tbl_Type :=
                                        G_MISS_TROLIN_TBL
,   p_trolin_val_tbl                IN  Trolin_Val_Tbl_Type :=
                                        G_MISS_TROLIN_VAL_TBL
,   x_trohdr_rec                    IN OUT NOCOPY Trohdr_Rec_Type
,   x_trohdr_val_rec                IN OUT NOCOPY Trohdr_Val_Rec_Type
,   x_trolin_tbl                    IN OUT NOCOPY Trolin_Tbl_Type
,   x_trolin_val_tbl                IN OUT NOCOPY Trolin_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Move_Order';
l_return_status               VARCHAR2(1);
l_trohdr_rec                  Trohdr_Rec_Type;
l_trolin_tbl                  Trolin_Tbl_Type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_trohdr_rec                  => p_trohdr_rec
    ,   p_trohdr_val_rec              => p_trohdr_val_rec
    ,   p_trolin_tbl                  => p_trolin_tbl
    ,   p_trolin_val_tbl              => p_trolin_val_tbl
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call INV_Transfer_Order_PVT.Lock_Transfer_Order

    INV_Transfer_Order_PVT.Lock_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_trohdr_rec                  => l_trohdr_rec
    ,   p_trolin_tbl                  => l_trolin_tbl
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl
    );

    --  Load Id OUT parameters.

    x_trohdr_rec                   := l_trohdr_rec;
    x_trolin_tbl                   := l_trolin_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_trohdr_rec                  => l_trohdr_rec
        ,   p_trolin_tbl                  => l_trolin_tbl
        ,   x_trohdr_val_rec              => x_trohdr_val_rec
        ,   x_trolin_val_tbl              => x_trolin_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Move_Order'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Move_Order;

--  Start of Comments
--  API name    Get_Move_Order
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Move_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_trohdr_rec                    OUT NOCOPY Trohdr_Rec_Type
,   x_trohdr_val_rec                OUT NOCOPY Trohdr_Val_Rec_Type
,   x_trolin_tbl                    OUT NOCOPY Trolin_Tbl_Type
,   x_trolin_val_tbl                OUT NOCOPY Trolin_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Move_Order';
l_header_id                   NUMBER := p_header_id;
l_trohdr_rec                  INV_Move_Order_PUB.Trohdr_Rec_Type;
l_trolin_tbl                  INV_Move_Order_PUB.Trolin_Tbl_Type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Standard check for Val/ID conversion

    IF  p_header = FND_API.G_MISS_CHAR
    THEN

        l_header_id := p_header_id;

    ELSIF p_header_id <> FND_API.G_MISS_NUM THEN

        l_header_id := p_header_id;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            FND_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_header_id := INV_Value_To_Id.header
        (   p_header                      => p_header
        );

        IF l_header_id = FND_API.G_MISS_NUM THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('INV','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
                FND_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call INV_Transfer_Order_PVT.Get_Transfer_Order

    INV_Transfer_Order_PVT.Get_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_header_id                   => l_header_id
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl
    );

    --  Load Id OUT parameters.

    x_trohdr_rec                   := l_trohdr_rec;
    x_trolin_tbl                   := l_trolin_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_trohdr_rec                  => l_trohdr_rec
        ,   p_trolin_tbl                  => l_trolin_tbl
        ,   x_trohdr_val_rec              => x_trohdr_val_rec
        ,   x_trolin_val_tbl              => x_trolin_val_tbl
        );

    END IF;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Move_Order'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Move_Order;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_trohdr_rec                    IN  Trohdr_Rec_Type
,   p_trolin_tbl                    IN  Trolin_Tbl_Type
,   x_trohdr_val_rec                OUT NOCOPY Trohdr_Val_Rec_Type
,   x_trolin_val_tbl                OUT NOCOPY Trolin_Val_Tbl_Type
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Convert trohdr

    x_trohdr_val_rec := INV_Trohdr_Util.Get_Values(p_trohdr_rec);

    --  Convert trolin

    FOR I IN 1..p_trolin_tbl.COUNT LOOP
        x_trolin_val_tbl(I) :=
            INV_Trolin_Util.Get_Values(p_trolin_tbl(I));
    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trohdr_rec                    IN  Trohdr_Rec_Type
,   p_trohdr_val_rec                IN  Trohdr_Val_Rec_Type
,   p_trolin_tbl                    IN  Trolin_Tbl_Type
,   p_trolin_val_tbl                IN  Trolin_Val_Tbl_Type
,   x_trohdr_rec                    IN OUT NOCOPY Trohdr_Rec_Type
,   x_trolin_tbl                    IN OUT NOCOPY Trolin_Tbl_Type
)
IS
l_trohdr_rec                  Trohdr_Rec_Type;
l_trolin_rec                  Trolin_Rec_Type;
l_index                       BINARY_INTEGER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert trohdr

    l_trohdr_rec := INV_Trohdr_Util.Get_Ids
    (   p_trohdr_rec                  => p_trohdr_rec
    ,   p_trohdr_val_rec              => p_trohdr_val_rec
    );

    x_trohdr_rec                   := l_trohdr_rec;

    IF l_trohdr_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert trolin

    x_trolin_tbl := p_trolin_tbl;

    l_index := p_trolin_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_trolin_rec := INV_Trolin_Util.Get_Ids
        (   p_trolin_rec                  => p_trolin_tbl(l_index)
        ,   p_trolin_val_rec              => p_trolin_val_tbl(l_index)
        );

        x_trolin_tbl(l_index)          := l_trolin_rec;

        IF l_trolin_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_trolin_val_tbl.NEXT(l_index);

    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

PROCEDURE Process_Move_Order_Line
(
    p_api_version_number        IN NUMBER
,   p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
,   p_return_values             IN VARCHAR2 := FND_API.G_FALSE
,   p_commit                    IN VARCHAR2 := FND_API.G_TRUE
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_msg_count                 OUT NOCOPY NUMBER
,   x_msg_data                  OUT NOCOPY VARCHAR2
,   p_trolin_tbl                IN Trolin_Tbl_Type
,   p_trolin_old_tbl            IN Trolin_Tbl_Type
,   x_trolin_tbl                IN OUT NOCOPY Trolin_Tbl_Type
) IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Update_Move_Order_line';
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_trohdr_rec                  Trohdr_Rec_Type := G_MISS_TROHDR_REC;
l_trohdr_val_rec              Trohdr_Val_Rec_Type := G_MISS_TROHDR_VAL_REC;
l_trolin_tbl                  Trolin_Tbl_Type := p_trolin_tbl;
l_trolin_val_tbl              Trolin_Val_Tbl_Type := G_MISS_TROLIN_VAL_TBL;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_control_rec.controlled_operation := TRUE;
    l_control_Rec.validate_entity := TRUE;
    l_control_Rec.process_entity := INV_GLOBALS.G_ENTITY_TROLIN;
    l_control_rec.write_to_db := TRUE;
    l_control_Rec.default_attributes := FALSE;
    l_control_Rec.change_attributes := FALSE;
    l_control_rec.process := FALSE;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order
    -- inv_debug.message('calling inv_transfer_order_pvt.process_transfer_order');
    -- inv_debug.message('l_trolin_tbl count is ' || p_trolin_tbl.COUNT);
    /*for l_count in 1..p_trolin_tbl.COUNT LOOP
    -- inv_debug.message('l_trolin_tbl.line_id is ' || p_trolin_tbl(l_count).line_id);
        -- inv_debug.message('l_trolin_tbl.operation is ' || p_trolin_tbl(l_count).operation);
    end loop; */
    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_commit                      => p_commit
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_control_rec                 => l_control_rec
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_trolin_tbl                  => p_trolin_tbl
    ,   p_trolin_val_tbl              => l_trolin_val_tbl
    ,   x_trohdr_rec                  => l_trohdr_rec
    ,   x_trolin_tbl                  => l_trolin_tbl
    );

    --  Load Id OUT parameters.

    --x_trohdr_rec                   := p_trohdr_rec;
    x_trolin_tbl                   := l_trolin_tbl;
    if( p_commit = FND_API.G_TRUE ) then
    commit;
    end if;
    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_trohdr_rec                  => l_trohdr_rec
        ,   p_trolin_tbl                  => l_trolin_tbl
        ,   x_trohdr_val_rec              => l_trohdr_val_rec
        ,   x_trolin_val_tbl              => l_trolin_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Move_Order'
            );
        END IF;

        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
   END Process_Move_Order_Line;

 PROCEDURE stamp_cart_id ( p_validation_level IN NUMBER
            , p_carton_grouping_tbl IN inv_move_order_pub.num_tbl_type
            , p_move_order_line_tbl IN inv_move_order_pub.num_tbl_type
            ) IS
   BEGIN
    FORALL i in 1..p_move_order_line_tbl.count
      UPDATE mtl_txn_request_lines SET
       carton_grouping_id = p_carton_grouping_tbl(i)
      WHERE line_id = p_move_order_line_tbl(i);
  END stamp_cart_id;


END INV_Move_Order_PUB;

/
