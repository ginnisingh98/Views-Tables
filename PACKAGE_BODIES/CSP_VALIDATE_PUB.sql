--------------------------------------------------------
--  DDL for Package Body CSP_VALIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_VALIDATE_PUB" AS
/*$Header: cspgtvpb.pls 120.4.12010000.3 2013/01/29 10:05:07 htank ship $*/
-- Start of Comments
-- Package name     : CSP_VALIDATE_PUB
-- File name        : cspgtvpb.pls
-- Purpose          : The package includes public procedures used for CSP.
-- History          :
--   25-Mar-2000, Modified error messages to comply with the CRM standards.
--   20-Dev-1999, Included Get_Avail_Qty function
--   10-Dec-1999, created by Vernon Lou
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_VALIDATE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtvpb.pls';

FUNCTION Get_Onhand_Qty RETURN NUMBER Is
Begin
  Return(G_qoh);
End;

FUNCTION Get_Available_Qty RETURN NUMBER Is
Begin
  Return(G_atr);
End;

PROCEDURE CHECK_PART_AVAILABLE (
/* This procedure returns the avalibale quantity based on the given organization, subinventory, locator*/
    P_API_VERSION_NUMBER    IN  NUMBER,
    P_INVENTORY_ITEM_ID     IN  NUMBER,
    P_ORGANIZATION_ID       IN  NUMBER,
    P_SUBINVENTORY_CODE     IN  VARCHAR2,
    P_LOCATOR_ID            IN  NUMBER,
    P_REVISION              IN  VARCHAR2,
    P_SERIAL_NUMBER         IN  VARCHAR2,
    P_LOT_NUMBER            IN  VARCHAR2,
    X_AVAILABLE_QUANTITY    OUT NOCOPY NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2
    )
IS
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER := 0;
    l_msg_data          VARCHAR2(200) := '';
    l_api_version_number   CONSTANT  NUMBER := 1.00;
    l_api_name             CONSTANT VARCHAR2(30) := 'Check_Part_Available';
    l_onhand_qty        NUMBER;
    l_reserved_qty      NUMBER;
    l_count_qty         NUMBER;
    l_check_existence   NUMBER;
    l_is_revision_control BOOLEAN := false;
    l_is_lot_control      BOOLEAN := false;
    l_is_serial_control   BOOLEAN := false;
    l_org_id            mtl_onhand_quantities.organization_id%type;
    l_sub_code          mtl_onhand_quantities.subinventory_code%type;
    l_locator_id        mtl_onhand_quantities.locator_id%type;
    EXCP_USER_DEFINED   EXCEPTION;
    l_serial_control_code   NUMBER := 0;
    l_revision_control_code NUMBER := 0;
    l_lot_control_code      NUMBER := 0;
    l_serial_status         NUMBER := 0;
    l_qoh                  	NUMBER := 0;
    l_rqoh                 	NUMBER := 0;
    l_qr                   	NUMBER := 0;
    l_qs                   	NUMBER := 0;
    l_att                  	NUMBER := 0;
    l_atr                  	NUMBER := 0;

BEGIN
     -- initialize message list
     FND_MSG_PUB.initialize;
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF p_organization_id IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
            FND_MSG_PUB.ADD;
     ELSE
           BEGIN
                select organization_id into l_check_existence
                from mtl_parameters
                where organization_id = p_organization_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                     FND_MSG_PUB.ADD;
                     RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                    fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                    fnd_message.set_token('TABLE', 'MTL_ORGANIZATIONS', TRUE);
                    FND_MSG_PUB.ADD;
                    RAISE EXCP_USER_DEFINED;
            END;
     END IF;

     IF p_inventory_item_id IS NULL THEN
                  FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
                  FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_inventory_item_id ', TRUE);
                  FND_MSG_PUB.ADD;
                  RAISE EXCP_USER_DEFINED;
             ELSE
                  BEGIN
                    -- validate whether the inventory_item_is exists in the given oranization_id
                    select inventory_item_id into l_check_existence
                    from mtl_system_items_kfv
                    where inventory_item_id = p_inventory_item_id
                    and organization_id = P_organization_id;
                  EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                         fnd_message.set_name('INV', 'INV-NO ITEM RECROD');
                         fnd_msg_pub.add;
                         RAISE EXCP_USER_DEFINED;
                      WHEN OTHERS THEN
                         fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                            fnd_message.set_token('ERR_FIELD', 'p_inventory_item_id', TRUE);
                            fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                            fnd_message.set_token('TABLE', 'MTL_SYSTEM_ITEMS', TRUE);
                            FND_MSG_PUB.ADD;
                            RAISE EXCP_USER_DEFINED;
                  END;
      END IF;

     -- check whether the item is under serial control
        select serial_number_control_code into l_serial_control_code
        from mtl_system_items
        where organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id;

        IF l_serial_control_code <> 1 THEN
            l_is_serial_control := true;
        END IF;

        -- check whether the item is under revision control
        select revision_qty_control_code into l_revision_control_code
        from mtl_system_items
        where organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id;

        IF l_revision_control_code <> 1 THEN
            l_is_revision_control := true;
        END IF;

        -- check whether the item is under lot control
        select lot_control_code into l_lot_control_code
        from mtl_system_items
        where organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id;

        IF l_lot_control_code <> 1 THEN
            l_is_lot_control := true;
        END IF;

IF p_serial_number IS NULL THEN
-- If serial number is null, it means that the user does not want to query for the quantity of the item on a
-- specific serial number. It should not be taken for granted that the item is not under seiral control.
-- The same theory should be applied to the validation of revision control and serial control.
-- First check whether the item is under serial control, if yes, set l_is_serial_control to true.

   inv_quantity_tree_pub.query_quantities(
     p_api_version_number   => l_api_version_number
   , p_init_msg_lst         => fnd_api.g_false
   , x_return_status        => l_return_status
   , x_msg_count            => l_msg_count
   , x_msg_data             => l_msg_data
   , p_organization_id      => p_organization_id
   , p_inventory_item_id    => p_inventory_item_id
   , p_tree_mode            => inv_quantity_tree_pvt.g_reservation_mode
   , p_is_revision_control  => l_is_revision_control
   , p_is_lot_control       => l_is_lot_control
   , p_is_serial_control    => l_is_serial_control
   , p_demand_source_type_id    => NULL
   , p_demand_source_header_id  => NULL
   , p_demand_source_line_id    => NULL
   , p_demand_source_name       => NULL
   , p_lot_expiration_date      => NULL
   , p_revision             	=> p_revision
   , p_lot_number           	=> p_lot_number
   , p_subinventory_code    	=> p_subinventory_code
   , p_locator_id           	=> p_locator_id
   , x_qoh                  	=> l_qoh
   , x_rqoh                 	=> l_rqoh
   , x_qr                   	=> l_qr
   , x_qs                   	=> l_qs
   , x_att                  	=> l_att
   , x_atr                  	=> l_atr);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


      if l_qr is null then
        l_qr := 0;
      end if;

        x_available_quantity := l_qoh - l_qr;

ELSE
-- serial number = not null
-- If the item is under serial control, we do not have to check its availability at subinventory and locator level.
-- The reason is that item_id (plus its serial number) should be unique under one organization.
        IF l_serial_control_code = 1 THEN
            fnd_message.set_name('INV', 'INV_ITEM_NOT_SERIAL_CONTROLLED');
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END IF;

        l_serial_control_code := 0;   -- reset l_serial_control_code for reuse

     -- check whether the serial number resides in the store
        select nvl(current_status, 1) into l_serial_status
        from mtl_serial_numbers
        where inventory_item_id = p_inventory_item_id
        and serial_number = p_serial_number
        and current_organization_id = p_organization_id;


        IF l_serial_status = 3 THEN
            l_onhand_qty := 1;
          -- check whether the item with that specified serial number is reserved
            select count(inventory_item_id) into l_count_qty
            from mtl_reservations
            where inventory_item_id = p_inventory_item_id
            and organization_id = p_organization_id
            and serial_number = p_serial_number;

            x_available_quantity := l_onhand_qty - l_count_qty;
       END IF;

  --  l_msg_count := l_msg_count + 1;
  --  l_msg_data := 'Operation completed successfully.';
END IF;

    x_msg_count := l_msg_count;
    x_msg_data  := l_msg_data;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
          WHEN EXCP_USER_DEFINED THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_available_quantity := NULL;
               fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

/*           WHEN EXCP_INVALID_ITEMS THEN
               x_return_status := FND_API.G_RET_STS_SUCCESS;
               x_msg_data := l_msg_data||'Return 0 quantity.';
               x_available_quantity := NULL;
               fnd_message.set_name('CSP', 'CSP_AVAIL_QTY');
               fnd_message.set_token('ERROR', l_msg_data);
               fnd_msg_pub.ADD;
                fnd_msg_pub.count_and_get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                );
*/
          WHEN FND_API.G_EXC_ERROR THEN
               x_return_status := l_return_status;
               fnd_msg_pub.count_and_get
                (  p_count => x_msg_count
                 , p_data  => x_msg_data );
               x_available_quantity := NULL;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               fnd_msg_pub.count_and_get
                (  p_count => x_msg_count
                 , p_data  => x_msg_data );
               x_available_quantity := NULL;

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              fnd_message.set_name('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
              fnd_message.set_token ('ROUTINE', l_api_name, TRUE);
              fnd_message.set_token ('SQLERRM', sqlerrm, TRUE);
              fnd_msg_pub.add;
              fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
              x_available_quantity := NULL;

END CHECK_PART_AVAILABLE;


FUNCTION Get_Avail_Qty (
/*  Name: get_avail_qty
    Purpose: Get the available quantity of an item at organization level, subinventory level or locator level.
             For Spares Management, avail_qty = unreserved_qty = total_onhand_qty - reserved_qty.
             This function returns NULL when there is an error.
    MODIFICATION HISTORY
   -- Person     Date          Comments
   -- ---------  ------        ------------------------------------------
   -- klou       02-Nov-99     Created
   -- klou       25-Mar-00     Change the p_tree_mode from g_transaction_mode to g_reservation_mode when calling
                               the inv_quantity_tree_pub.query_quantities procedure.
   -- End of comments
    Author: Vernon Lou
    Date: 2-Nov-99
          03/25/00:
*/
    p_organization_id   NUMBER,
    p_subinventory_code VARCHAR2,
    p_locator_id        NUMBER,
    p_inventory_item_id NUMBER)

RETURN NUMBER IS
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER := 0;
    l_msg_data          VARCHAR2(200) := '';
    l_api_version_number   CONSTANT  NUMBER := 1.00;
    l_is_revision_control BOOLEAN := false;
    l_is_lot_control      BOOLEAN := false;
    l_is_serial_control   BOOLEAN := false;
    l_serial_control_code   NUMBER := 0;
    l_revision_control_code NUMBER := 0;
    l_lot_control_code      NUMBER := 0;
    l_serial_status         NUMBER := 0;
    l_qoh                  	NUMBER := 0;
    l_rqoh                 	NUMBER := 0;
    l_qr                   	NUMBER := 0;
    l_qs                   	NUMBER := 0;
    l_att                  	NUMBER := 0;
    l_atr                  	NUMBER := 0;
    l_count_qty             NUMBER := 0;
    EXCP_NO_REQ_PARAMETERS  EXCEPTION;
    EXCP_INVALID_ITEMS  EXCEPTION;
BEGIN
   g_qoh := null;
   g_atr := null;
   IF p_organization_id IS NULL THEN
        RAISE EXCP_NO_REQ_PARAMETERS;
      END IF;
      IF p_inventory_item_id IS NULL THEN
         RAISE EXCP_NO_REQ_PARAMETERS;
      ELSE    -- verify whether the item is assigned to the given organization_id
        select count(organization_id) into l_count_qty
        from mtl_system_items_kfv
        where organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id;

            IF l_count_qty = 0 THEN
                RAISE EXCP_INVALID_ITEMS;
            ELSE
                l_count_qty := 0;
            END IF;
      END IF;

        -- check whether the item is under serial control
        select serial_number_control_code into l_serial_control_code
        from mtl_system_items
        where organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id;

        IF l_serial_control_code <> 1 THEN
            l_is_serial_control := true;
        END IF;

        -- check whether the item is under revision control
        select revision_qty_control_code into l_revision_control_code
        from mtl_system_items
        where organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id;

        IF l_revision_control_code <> 1 THEN
            l_is_revision_control := true;
        END IF;

        -- check whether the item is under lot control
        select lot_control_code into l_lot_control_code
        from mtl_system_items
        where organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id;

        IF l_lot_control_code <> 1 THEN
            l_is_lot_control := true;
        END IF;

   inv_quantity_tree_pub.clear_quantity_cache;

   inv_quantity_tree_pub.query_quantities(
     p_api_version_number   => l_api_version_number
   , p_init_msg_lst         => fnd_api.g_false
   , x_return_status        => l_return_status
   , x_msg_count            => l_msg_count
   , x_msg_data             => l_msg_data
   , p_organization_id      => p_organization_id
   , p_inventory_item_id    => p_inventory_item_id
   , p_tree_mode            => inv_quantity_tree_pvt.g_reservation_mode
   , p_is_revision_control  => l_is_revision_control
   , p_is_lot_control       => l_is_lot_control
   , p_is_serial_control    => l_is_serial_control
   , p_demand_source_type_id    => NULL
   , p_demand_source_header_id  => NULL
   , p_demand_source_line_id    => NULL
   , p_demand_source_name       => NULL
   , p_lot_expiration_date      => NULL
   , p_revision             	=> NULL
   , p_lot_number           	=> NULL
   , p_subinventory_code    	=> p_subinventory_code
   , p_locator_id           	=> p_locator_id
   , x_qoh                  	=> l_qoh
   , x_rqoh                 	=> l_rqoh
   , x_qr                   	=> l_qr
   , x_qs                   	=> l_qs
   , x_att                  	=> l_att
   , x_atr                  	=> l_atr);

    g_qoh := l_qoh;
    g_atr := l_atr;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    return l_att;

EXCEPTION
          WHEN EXCP_NO_REQ_PARAMETERS THEN
               return NULL;

          WHEN FND_API.G_EXC_ERROR THEN
              return NULL;

          WHEN OTHERS THEN
             return NULL;

END GET_AVAIL_QTY;

FUNCTION Get_Avail_Qty (
/*  Name: get_avail_qty
    Purpose: Get the available quantity of an item at organization level, subinventory level or locator level.
             For Spares Management, avail_qty = unreserved_qty = total_onhand_qty - reserved_qty.
             This function returns NULL when there is an error.
    MODIFICATION HISTORY
   -- Person     Date          Comments
   -- ---------  ------        ------------------------------------------
   -- hhaugeru   22-Jun-01     Created

   -- End of comments
    Author: Hans Haugerud
    Date: 22-Jun-01
*/
    p_organization_id   NUMBER,
    p_subinventory_code VARCHAR2,
    p_locator_id        NUMBER,
    p_inventory_item_id NUMBER,
    p_revision          VARCHAR2)

RETURN NUMBER IS
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER := 0;
    l_msg_data          VARCHAR2(200) := '';
    l_api_version_number   CONSTANT  NUMBER := 1.00;
    l_is_revision_control BOOLEAN := false;
    l_is_lot_control      BOOLEAN := false;
    l_is_serial_control   BOOLEAN := false;
    l_serial_control_code   NUMBER := 0;
    l_revision_control_code NUMBER := 0;
    l_lot_control_code      NUMBER := 0;
    l_serial_status         NUMBER := 0;
    l_qoh                  	NUMBER := 0;
    l_rqoh                 	NUMBER := 0;
    l_qr                   	NUMBER := 0;
    l_qs                   	NUMBER := 0;
    l_att                  	NUMBER := 0;
    l_atr                  	NUMBER := 0;
    l_count_qty             NUMBER := 0;
    EXCP_NO_REQ_PARAMETERS  EXCEPTION;
    EXCP_INVALID_ITEMS  EXCEPTION;
BEGIN

      IF p_organization_id IS NULL THEN
        RAISE EXCP_NO_REQ_PARAMETERS;
      END IF;
      IF p_inventory_item_id IS NULL THEN
         RAISE EXCP_NO_REQ_PARAMETERS;
      END IF;

        -- check whether the item is under serial, lot and revision control
        select  serial_number_control_code,
                lot_control_code,
                revision_qty_control_code
        into    l_serial_control_code,
                l_lot_control_code,
                l_revision_control_code
        from    mtl_system_items
        where   organization_id   = p_organization_id
        and     inventory_item_id = p_inventory_item_id;

        IF l_serial_control_code <> 1 THEN
            l_is_serial_control := true;
        END IF;

        IF l_revision_control_code <> 1 THEN
            l_is_revision_control := true;
        END IF;

        -- bug # 7171956
        -- if we want to total available qty for an item then don't say it is lot_controlled and this API will
        -- return toal of all the lot_numbers otherwise we have to pass lot_number as well
        /*
        IF l_lot_control_code <> 1 THEN
            l_is_lot_control := true;
        END IF;
        */

   inv_quantity_tree_pub.clear_quantity_cache;

   inv_quantity_tree_pub.query_quantities(
     p_api_version_number   => l_api_version_number
   , p_init_msg_lst         => fnd_api.g_false
   , x_return_status        => l_return_status
   , x_msg_count            => l_msg_count
   , x_msg_data             => l_msg_data
   , p_organization_id      => p_organization_id
   , p_inventory_item_id    => p_inventory_item_id
   , p_tree_mode            => inv_quantity_tree_pvt.g_reservation_mode
   , p_is_revision_control  => l_is_revision_control
   , p_is_lot_control       => l_is_lot_control
   , p_is_serial_control    => l_is_serial_control
   , P_ONHAND_SOURCE          => inv_quantity_tree_pvt.g_all_subs
   , p_demand_source_type_id    => NULL
   , p_demand_source_header_id  => NULL
   , p_demand_source_line_id    => NULL
   , p_demand_source_name       => NULL
   , p_lot_expiration_date      => NULL
   , p_revision             	=> p_revision
   , p_lot_number           	=> NULL
   , p_subinventory_code    	=> p_subinventory_code
   , p_locator_id           	=> p_locator_id
   , x_qoh                  	=> l_qoh
   , x_rqoh                 	=> l_rqoh
   , x_qr                   	=> l_qr
   , x_qs                   	=> l_qs
   , x_att                  	=> l_att
   , x_atr                  	=> l_atr);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    return l_att;

EXCEPTION
          WHEN EXCP_NO_REQ_PARAMETERS THEN
               return NULL;

          WHEN FND_API.G_EXC_ERROR THEN
              return NULL;

          WHEN OTHERS THEN
             return NULL;

END GET_AVAIL_QTY;


-- bug # 7171956
-- new function to calculate available qty for lot controlled item

FUNCTION Get_Avail_Qty (
/*  Name: get_avail_qty
    Purpose: Get the available quantity of an item at organization level, subinventory level or locator level.
             For Spares Management, avail_qty = unreserved_qty = total_onhand_qty - reserved_qty.
             This function returns NULL when there is an error.
*/
    p_organization_id   NUMBER,
    p_subinventory_code VARCHAR2,
    p_locator_id        NUMBER,
    p_inventory_item_id NUMBER,
    p_revision          VARCHAR2,
        p_lot_num        VARCHAR2)

RETURN NUMBER IS
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER := 0;
    l_msg_data          VARCHAR2(200) := '';
    l_api_version_number   CONSTANT  NUMBER := 1.00;
    l_is_revision_control BOOLEAN := false;
    l_is_lot_control      BOOLEAN := false;
    l_is_serial_control   BOOLEAN := false;
    l_serial_control_code   NUMBER := 0;
    l_revision_control_code NUMBER := 0;
    l_lot_control_code      NUMBER := 0;
    l_serial_status         NUMBER := 0;
    l_qoh                  	NUMBER := 0;
    l_rqoh                 	NUMBER := 0;
    l_qr                   	NUMBER := 0;
    l_qs                   	NUMBER := 0;
    l_att                  	NUMBER := 0;
    l_atr                  	NUMBER := 0;
    l_count_qty             NUMBER := 0;
    EXCP_NO_REQ_PARAMETERS  EXCEPTION;
    EXCP_INVALID_ITEMS  EXCEPTION;
BEGIN

      IF p_organization_id IS NULL THEN
        RAISE EXCP_NO_REQ_PARAMETERS;
      END IF;
      IF p_inventory_item_id IS NULL THEN
         RAISE EXCP_NO_REQ_PARAMETERS;
      END IF;

        -- check whether the item is under serial, lot and revision control
        select  serial_number_control_code,
                lot_control_code,
                revision_qty_control_code
        into    l_serial_control_code,
                l_lot_control_code,
                l_revision_control_code
        from    mtl_system_items
        where   organization_id   = p_organization_id
        and     inventory_item_id = p_inventory_item_id;

        IF l_serial_control_code <> 1 THEN
            l_is_serial_control := true;
        END IF;

        IF l_revision_control_code <> 1 THEN
            l_is_revision_control := true;
        END IF;

        if l_is_revision_control and p_revision is NULL then
          l_is_revision_control := false;
        end if;

        IF l_lot_control_code <> 1 THEN
            l_is_lot_control := true;
        END IF;

   inv_quantity_tree_pub.clear_quantity_cache;

   inv_quantity_tree_pub.query_quantities(
     p_api_version_number   => l_api_version_number
   , p_init_msg_lst         => fnd_api.g_false
   , x_return_status        => l_return_status
   , x_msg_count            => l_msg_count
   , x_msg_data             => l_msg_data
   , p_organization_id      => p_organization_id
   , p_inventory_item_id    => p_inventory_item_id
   , p_tree_mode            => inv_quantity_tree_pvt.g_reservation_mode
   , p_is_revision_control  => l_is_revision_control
   , p_is_lot_control       => l_is_lot_control
   , p_is_serial_control    => l_is_serial_control
   , p_demand_source_type_id    => NULL
   , p_demand_source_header_id  => NULL
   , p_demand_source_line_id    => NULL
   , p_demand_source_name       => NULL
   , p_lot_expiration_date      => NULL
   , p_revision             	=> p_revision
   , p_lot_number           	=> p_lot_num
   , P_ONHAND_SOURCE          => inv_quantity_tree_pvt.g_all_subs
   , p_subinventory_code    	=> p_subinventory_code
   , p_locator_id           	=> p_locator_id
   , x_qoh                  	=> l_qoh
   , x_rqoh                 	=> l_rqoh
   , x_qr                   	=> l_qr
   , x_qs                   	=> l_qs
   , x_att                  	=> l_att
   , x_atr                  	=> l_atr);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    return l_att;

EXCEPTION
          WHEN EXCP_NO_REQ_PARAMETERS THEN
               return NULL;

          WHEN FND_API.G_EXC_ERROR THEN
              return NULL;

          WHEN OTHERS THEN
             return NULL;

END GET_AVAIL_QTY;
-- enf of bug # 7171956

END CSP_VALIDATE_PUB;

/
