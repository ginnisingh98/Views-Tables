--------------------------------------------------------
--  DDL for Package Body INV_MATERIAL_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MATERIAL_STATUS_PUB" as
/* $Header: INVMSPUB.pls 120.3 2008/02/19 19:04:24 musinha ship $ */

-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'INV_MATERIAL_STATUS_PUB';

PROCEDURE update_status
  (  p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_object_type               IN  VARCHAR2
   , p_status_rec                IN  INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type
   ) IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'UPDATE_STATUS';
l_return_status               VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_status_rec	     	      INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type;
l_msg_count NUMBER;
l_msg_data VARCHAR2(240);
l_lot_status_enabled VARCHAR2(1);
l_default_lot_status_id NUMBER;
l_serial_status_enabled VARCHAR2(1);
l_default_serial_status_id NUMBER;

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

     --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    if p_object_type = 'O' or p_object_type = 'S' then
        -- check if the item is lot_serial status controlled
        inv_material_status_grp.get_lot_serial_status_control(
         p_organization_id      => p_status_rec.organization_id
        ,p_inventory_item_id    => p_status_rec.inventory_item_id
        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        ,x_lot_status_enabled   => l_lot_status_enabled
        ,x_default_lot_status_id => l_default_lot_status_id
        ,x_serial_status_enabled => l_serial_status_enabled
        ,x_default_serial_status_id => l_default_serial_status_id);
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
        END IF;
        if (l_lot_status_enabled = 'N' AND p_object_type = 'O') or
           (l_serial_status_enabled = 'N' AND p_object_type = 'S') then
            RAISE fnd_api.g_exc_error;
        end if;
    end if;

    l_status_rec := p_status_rec;
    INV_MATERIAL_STATUS_PKG.Initialize_status_rec(l_status_rec);

    if p_object_type = 'Z' then
        update mtl_secondary_inventories
        set status_id = l_status_rec.status_id
            , last_updated_by = l_status_rec.last_updated_by
	    , last_update_date = l_status_rec.last_update_date
	    , last_update_login = l_status_rec.last_update_login
        where organization_id = l_status_rec.organization_id
          and secondary_inventory_name = l_status_rec.zone_code;
    elsif p_object_type = 'L' then
        update  mtl_item_locations
        set status_id = l_status_rec.status_id
            , last_updated_by = l_status_rec.last_updated_by
            , last_update_date = l_status_rec.last_update_date
            , last_update_login = l_status_rec.last_update_login
        where organization_id = l_status_rec.organization_id
          and inventory_location_id = l_status_rec.locator_id;
    elsif p_object_type = 'O' then
        update  mtl_lot_numbers
        set status_id = l_status_rec.status_id
            , last_updated_by = l_status_rec.last_updated_by
            , last_update_date = l_status_rec.last_update_date
            , last_update_login = l_status_rec.last_update_login
        where organization_id = l_status_rec.organization_id
          and inventory_item_id = l_status_rec.inventory_item_id
          and lot_number = l_status_rec.lot_number;
    elsif p_object_type = 'S' then
       update  mtl_serial_numbers
       set status_id = l_status_rec.status_id
            , last_updated_by = l_status_rec.last_updated_by
            , last_update_date = l_status_rec.last_update_date
            , last_update_login = l_status_rec.last_update_login
        where current_organization_id = l_status_rec.organization_id
          and inventory_item_id = l_status_rec.inventory_item_id
          and serial_number = l_status_rec.serial_number;
        if l_status_rec.to_serial_number is not null and
           l_status_rec.serial_number <> l_status_rec.to_serial_number then
        	update  mtl_serial_numbers
       		set status_id = l_status_rec.status_id
            		, last_updated_by = l_status_rec.last_updated_by
            		, last_update_date = l_status_rec.last_update_date
            		, last_update_login = l_status_rec.last_update_login
        	where current_organization_id = l_status_rec.organization_id
          	and inventory_item_id = l_status_rec.inventory_item_id
          	and serial_number > l_status_rec.serial_number and
                    serial_number <= l_status_rec.to_serial_number;
	end if;
-- Start of changes for # 6633612---------------
   elsif p_object_type = 'H' then
   -- Need to add code to make sure that not serial controlled one.
   -- I think as this is in else of serial .. no need to check the serial control again
	if l_status_rec.status_id is not null or l_status_rec.status_id <> 0 or l_status_rec.status_id <> -1 then
	        update  mtl_onhand_quantities_detail
	        set status_id = l_status_rec.status_id
	      , last_updated_by = l_status_rec.last_updated_by
	      , last_update_date = l_status_rec.last_update_date
              , last_update_login = l_status_rec.last_update_login
              where inventory_item_id = l_status_rec.inventory_item_id
              and organization_id = l_status_rec.organization_id
	      and subinventory_code = l_status_rec.zone_code
              and nvl(lot_number, '@@@@') = nvl(l_status_rec.lot_number, '@@@@')
              and nvl(locator_id, -9999) = nvl(l_status_rec.locator_id, -9999)
	      and nvl(lpn_id, -9999) = nvl(l_status_rec.lpn_id, -9999);
        end if;
  -- End of changes for # 6633612---------------
   else
      -- Onhand Material Status Support (6633612): Object type is passed as 'Q' from QtyManager.java to
      -- avoid the update of onhand records. In this case we only want the new record to be inserted into
      -- the history table.
      if p_object_type <> 'Q' then
        l_return_status := fnd_api.g_ret_sts_error;
      end if;
   end if;

    -- Bug 6798024: For object_type Q, no update statement is executed, hence
    -- we should not raise no-data-found error.
    if ((sql%notfound) AND p_object_type <> 'Q') then
        raise no_data_found;
    end if;

     -- Insert the update history to the update status history table
    INV_MATERIAL_STATUS_PKG.Insert_status_history(p_status_rec);

    if( p_commit = FND_API.G_TRUE ) Then
        commit;
    end if;

    x_return_status := l_return_status;

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
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
        END IF;

        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END update_status;

END INV_MATERIAL_STATUS_PUB;

/
