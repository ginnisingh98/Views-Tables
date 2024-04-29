--------------------------------------------------------
--  DDL for Package Body INV_MATERIAL_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MATERIAL_STATUS_PKG" as
/* $Header: INVMSPVB.pls 120.9.12010000.4 2009/07/21 22:57:44 musinha ship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_MATERIAL_STATUS_PKG';
-- BEGIN SCHANDRU INVERES
g_eres_enabled         VARCHAR2(3)   := NVL(fnd_profile.VALUE('EDR_ERES_ENABLED'), 'N');
-- END SCHANDRU INVERES
FUNCTION status_assigned(p_status_id IN NUMBER) return Boolean
IS
   count_assigned number := 0;
BEGIN
    -- Check subinventories
    select 1
    into count_assigned
    from dual
    where exists (select 1
                  from mtl_secondary_inventories
                  where status_id = p_status_id);

    if count_assigned >0 then
        return TRUE;
    end if;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    BEGIN
    -- Check locator
    select 1
    into count_assigned
    from dual
    where exists (select 1
                  from mtl_item_locations
                  where status_id = p_status_id);

    if count_assigned >0 then
        return TRUE;
    end if;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        BEGIN
            -- Check lot
            select 1
            into count_assigned
            from dual
            where exists (select 1
                          from mtl_lot_numbers
                          where status_id = p_status_id);

            if count_assigned >0 then
                return TRUE;
            end if;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             BEGIN
              -- Check serial
             select 1
             into count_assigned
             from dual
             where exists (select 1
                           from mtl_serial_numbers
                           where status_id = p_status_id);

             if count_assigned >0 then
                  return TRUE;
             end if;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 BEGIN
                 -- Check Onhand -- Bug 6842219
                 select 1
                 into count_assigned
                 from dual
                 where exists (select 1
                               from mtl_onhand_quantities_detail moqd, mtl_parameters mp
                               where moqd.organization_id = mp.organization_id
                               and mp.default_status_id is not null
                               and nvl(moqd.status_id, -9999) = p_status_id
                               and rownum = 1); -- Do we need to add rownum as the query is inside 'exists'.

                 if count_assigned >0 then
                     return TRUE;
                 end if;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       return FALSE;
                 END;
             END;
        END;
    END;
    return FALSE;
END;

Function get_default_locator_status(
                           p_organization_id     IN NUMBER,
                           p_sub_code            IN VARCHAR2
                           ) return NUMBER IS
l_status_id NUMBER;
BEGIN
    SELECT default_loc_status_id
    INTO l_status_id
    FROM MTL_SECONDARY_INVENTORIES
    WHERE organization_id = p_organization_id
      AND secondary_inventory_name = p_sub_code;
    return l_status_id;
    exception
      when others then
          return NULL;
END get_default_locator_status;

-- Procedure Initialize_status_rec
-- Description
--   convert missing value in the input record
--   to null or proper default value .

PROCEDURE  Initialize_status_rec(px_status_rec
                                 IN OUT NOCOPY INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type )
IS
BEGIN
    if px_status_rec.organization_id = fnd_api.g_miss_num THEN
        px_status_rec.organization_id := NULL;
    end if;
    if px_status_rec.inventory_item_id = fnd_api.g_miss_num THEN
        px_status_rec.inventory_item_id := NULL;
    end if;
    if px_status_rec.lot_number = fnd_api.g_miss_char then
        px_status_rec.lot_number := NULL;
    end if;
    if px_status_rec.serial_number = fnd_api.g_miss_char then
        px_status_rec.serial_number := NULL;
    end if;
    if px_status_rec.to_serial_number = fnd_api.g_miss_char then
        px_status_rec.to_serial_number := NULL;
    end if;
    if px_status_rec.update_method = fnd_api.g_miss_num then
        px_status_rec.update_method := NULL;
    end if;
    if px_status_rec.status_id = fnd_api.g_miss_num then
        px_status_rec.status_id := NULL;
    end if;
    if px_status_rec.zone_code = fnd_api.g_miss_char then
        px_status_rec.zone_code := NULL;
    end if;
    if px_status_rec.locator_id = fnd_api.g_miss_num then
        px_status_rec.locator_id := NULL;
    end if;
    if px_status_rec.created_by = fnd_api.g_miss_num then
        px_status_rec.created_by := FND_GLOBAL.USER_ID;
    end if;
    if px_status_rec.last_updated_by = fnd_api.g_miss_num then
        px_status_rec.last_updated_by := FND_GLOBAL.USER_ID;
    end if;
    -- always default the creation date and update date to sysdate
    -- since we only need to insert this record and never need to
    -- change it, bug 1912638
    px_status_rec.creation_date := SYSDATE;
    px_status_rec.last_update_date := SYSDATE;
    if px_status_rec.last_update_login = fnd_api.g_miss_num then
        px_status_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
    end if;

    if px_status_rec.program_application_id = fnd_api.g_miss_num then
        px_status_rec.program_application_id := NULL;
    end if;

    if px_status_rec.program_id = fnd_api.g_miss_num then
        px_status_rec.program_id := NULL;
    end if;

    if px_status_rec.attribute_category = fnd_api.g_miss_char then
        px_status_rec.attribute_category := NULL;
    end if;
    if px_status_rec.attribute1 = fnd_api.g_miss_char then
        px_status_rec.attribute1 := NULL;
    end if;
    if px_status_rec.attribute2 = fnd_api.g_miss_char then
        px_status_rec.attribute2 := NULL;
    end if;
    if px_status_rec.attribute3 = fnd_api.g_miss_char then
        px_status_rec.attribute3 := NULL;
    end if;
    if px_status_rec.attribute4 = fnd_api.g_miss_char then
        px_status_rec.attribute4 := NULL;
    end if;
    if px_status_rec.attribute5 = fnd_api.g_miss_char then
        px_status_rec.attribute5 := NULL;
    end if;
    if px_status_rec.attribute6 = fnd_api.g_miss_char then
        px_status_rec.attribute6 := NULL;
    end if;
    if px_status_rec.attribute7 = fnd_api.g_miss_char then
        px_status_rec.attribute7 := NULL;
    end if;
    if px_status_rec.attribute8 = fnd_api.g_miss_char then
        px_status_rec.attribute8 := NULL;
    end if;
    if px_status_rec.attribute9 = fnd_api.g_miss_char then
        px_status_rec.attribute9 := NULL;
    end if;
    if px_status_rec.attribute10 = fnd_api.g_miss_char then
        px_status_rec.attribute10 := NULL;
    end if;
    if px_status_rec.attribute11 = fnd_api.g_miss_char then
        px_status_rec.attribute11 := NULL;
    end if;
    if px_status_rec.attribute12 = fnd_api.g_miss_char then
        px_status_rec.attribute12 := NULL;
    end if;
    if px_status_rec.attribute13 = fnd_api.g_miss_char then
        px_status_rec.attribute13 := NULL;
    end if;
    if px_status_rec.attribute14 = fnd_api.g_miss_char then
        px_status_rec.attribute14 := NULL;
    end if;
    if px_status_rec.attribute15 = fnd_api.g_miss_char then
        px_status_rec.attribute15 := NULL;
    end if;
    if px_status_rec.update_reason_id = fnd_api.g_miss_num then
        px_status_rec.update_reason_id := NULL;
    end if;

    if px_status_rec.initial_status_flag = fnd_api.g_miss_char then
        px_status_rec.initial_status_flag := NULL;
    end if;
    if px_status_rec.from_mobile_apps_flag = fnd_api.g_miss_char then
        px_status_rec.from_mobile_apps_flag := NULL;
    end if;
    --BUG 7306729 Quantities should be changed to NULL when the value is g_miss_num
    if px_status_rec.PRIMARY_ONHAND = fnd_api.g_miss_num then
        px_status_rec.PRIMARY_ONHAND := NULL;
    end if;

    if px_status_rec.SECONDARY_ONHAND = fnd_api.g_miss_num then
        px_status_rec.SECONDARY_ONHAND := NULL;
    end if;
    --End of 7306729

    -- Bug# 1695432 added initial_status_flag,from_mobile_apps_flag columns


END Initialize_status_rec;

PROCEDURE  Insert_status_history(p_status_rec
                               IN INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type )
IS
    l_status_rec INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_label_status             varchar2(300);
    l_return_status        varchar2(1);
    l_to_serial_number     varchar2(30):= NULL;

    cursor cur_serial_number is
        SELECT serial_number
        FROM MTL_SERIAL_NUMBERS
        WHERE current_organization_id = p_status_rec.organization_id
          AND inventory_item_id = p_status_rec.inventory_item_id
          AND serial_number > p_status_rec.serial_number
          AND serial_number <= p_status_rec.to_serial_number;
   l_status_update_id NUMBER := NULL;   -- SCHANDRU INVERES
--   g_eres_enabled varchar2(1):= 'Y';

BEGIN
	--BEGIN SCHANDRU INVERES
	Select MTL_MATERIAL_STATUS_HISTORY_S.nextval
	Into l_status_update_id
	From dual;
	-- END SCHANDRU INVERES
    l_status_rec := p_status_rec;
    INV_MATERIAL_STATUS_PKG.Initialize_status_rec(l_status_rec);

    INSERT INTO MTL_MATERIAL_STATUS_HISTORY
    (
      	 STATUS_UPDATE_ID
	,ORGANIZATION_ID
	,INVENTORY_ITEM_ID
	,LOT_NUMBER
	,SERIAL_NUMBER
	,UPDATE_METHOD
	,STATUS_ID
	,ZONE_CODE
	,LOCATOR_ID
	,LPN_ID  ---- Added for # 6633612
        ,CREATION_DATE
 	,CREATED_BY
 	,LAST_UPDATED_BY
 	,LAST_UPDATE_DATE
 	,LAST_UPDATE_LOGIN
 	,PROGRAM_APPLICATION_ID
 	,PROGRAM_ID
	,ATTRIBUTE_CATEGORY
	,ATTRIBUTE1
	,ATTRIBUTE2
	,ATTRIBUTE3
	,ATTRIBUTE4
	,ATTRIBUTE5
	,ATTRIBUTE6
	,ATTRIBUTE7
	,ATTRIBUTE8
	,ATTRIBUTE9
	,ATTRIBUTE10
	,ATTRIBUTE11
	,ATTRIBUTE12
	,ATTRIBUTE13
	,ATTRIBUTE14
	,ATTRIBUTE15
        ,UPDATE_REASON_ID
	,INITIAL_STATUS_FLAG
	,FROM_MOBILE_APPS_FLAG
        -- NSRIVAST, INVCONV , Start
        ,GRADE_CODE
        ,PRIMARY_ONHAND
        ,SECONDARY_ONHAND
        -- NSRIVAST, INVCONV , End
        )
        VALUES (
	-- BEGIN SCHANDRU INVERES
   	--MTL_MATERIAL_STATUS_HISTORY_S.nextval
         l_status_update_id, -- Add this local variable so that it   can be used to be stored in the temp table.
        -- END SCHANDRU INVERES
         l_status_rec.ORGANIZATION_ID
        ,l_status_rec.INVENTORY_ITEM_ID
        ,l_status_rec.LOT_NUMBER
        ,l_status_rec.SERIAL_NUMBER
        ,l_status_rec.UPDATE_METHOD
        ,l_status_rec.STATUS_ID
        ,l_status_rec.ZONE_CODE
        ,l_status_rec.LOCATOR_ID
        ,l_status_rec.LPN_ID  ---- Added for # 6633612
        ,l_status_rec.CREATION_DATE
        ,l_status_rec.CREATED_BY
        ,l_status_rec.LAST_UPDATED_BY
        ,l_status_rec.LAST_UPDATE_DATE
        ,l_status_rec.LAST_UPDATE_LOGIN
        ,l_status_rec.PROGRAM_APPLICATION_ID
        ,l_status_rec.PROGRAM_ID
        ,l_status_rec.ATTRIBUTE_CATEGORY
        ,l_status_rec.ATTRIBUTE1
        ,l_status_rec.ATTRIBUTE2
        ,l_status_rec.ATTRIBUTE3
        ,l_status_rec.ATTRIBUTE4
        ,l_status_rec.ATTRIBUTE5
        ,l_status_rec.ATTRIBUTE6
        ,l_status_rec.ATTRIBUTE7
        ,l_status_rec.ATTRIBUTE8
        ,l_status_rec.ATTRIBUTE9
        ,l_status_rec.ATTRIBUTE10
        ,l_status_rec.ATTRIBUTE11
        ,l_status_rec.ATTRIBUTE12
        ,l_status_rec.ATTRIBUTE13
        ,l_status_rec.ATTRIBUTE14
        ,l_status_rec.ATTRIBUTE15
 	,l_status_rec.UPDATE_REASON_ID
	,l_status_rec.INITIAL_STATUS_FLAG
	,l_status_rec.FROM_MOBILE_APPS_FLAG
        -- NSRIVAST, INVCONV , Start
        ,l_status_rec.GRADE_CODE
        ,l_status_rec.PRIMARY_ONHAND
        ,l_status_rec.SECONDARY_ONHAND
        -- NSRIVAST, INVCONV , End
        );


-- BEGIN SCHANDRU INVERES
	IF g_eres_enabled <> 'N' THEN
      		Insert into MTL_GRADE_STATUS_ERES_GTMP(status_update_id,
            		grade_update_id)  values (l_status_update_id, NULL);
	END IF;
-- END SCHANDRU INVERES


	--Bug# 1695432 added INITIAL_STATUS_FLAG,FROM_MOBILE_APPS_FLAG col

        if p_status_rec.to_serial_number is not null and
           p_status_rec.serial_number <> p_status_rec.to_serial_number then
            l_to_serial_number := p_status_rec.to_serial_number;
            FOR cc IN cur_serial_number LOOP
		-- BEGIN SCHANDRU INVERES
		Select MTL_MATERIAL_STATUS_HISTORY_S.nextval
		Into l_status_update_id
		From dual;

		-- END SCHANDRU INVERES
    		INSERT INTO MTL_MATERIAL_STATUS_HISTORY
    		(
         	STATUS_UPDATE_ID
        	,ORGANIZATION_ID
        	,INVENTORY_ITEM_ID
        	,LOT_NUMBER
        	,SERIAL_NUMBER
        	,UPDATE_METHOD
        	,STATUS_ID
        	,ZONE_CODE
        	,LOCATOR_ID
		,LPN_ID  ---- Added for # 6633612
        	,CREATION_DATE
        	,CREATED_BY
        	,LAST_UPDATED_BY
        	,LAST_UPDATE_DATE
        	,LAST_UPDATE_LOGIN
        	,PROGRAM_APPLICATION_ID
        	,PROGRAM_ID
        	,ATTRIBUTE_CATEGORY
        	,ATTRIBUTE1
        	,ATTRIBUTE2
        	,ATTRIBUTE3
        	,ATTRIBUTE4
        	,ATTRIBUTE5
        	,ATTRIBUTE6
        	,ATTRIBUTE7
        	,ATTRIBUTE8
        	,ATTRIBUTE9
        	,ATTRIBUTE10
        	,ATTRIBUTE11
        	,ATTRIBUTE12
        	,ATTRIBUTE13
        	,ATTRIBUTE14
       	 	,ATTRIBUTE15
 		,UPDATE_REASON_ID
		,INITIAL_STATUS_FLAG
		,FROM_MOBILE_APPS_FLAG
                 -- NSRIVAST, INVCONV , Start
                ,GRADE_CODE
                ,PRIMARY_ONHAND
                ,SECONDARY_ONHAND
                -- NSRIVAST, INVCONV , End
        	)
        	VALUES (
       		--BEGIN SCHANDRU INVERES
		--MTL_MATERIAL_STATUS_HISTORY_S.nextval
		l_status_update_id, -- Add this local variable so that it can be used to be stored in the temp table
		-- END SCHANDRU INVERES
        	 l_status_rec.ORGANIZATION_ID
        	,l_status_rec.INVENTORY_ITEM_ID
        	,l_status_rec.LOT_NUMBER
                ,cc.serial_number
        	,l_status_rec.UPDATE_METHOD
        	,l_status_rec.STATUS_ID
        	,l_status_rec.ZONE_CODE
       	 	,l_status_rec.LOCATOR_ID
		,l_status_rec.LPN_ID -- Added for # 6633612
        	,l_status_rec.CREATION_DATE
        	,l_status_rec.CREATED_BY
        	,l_status_rec.LAST_UPDATED_BY
        	,l_status_rec.LAST_UPDATE_DATE
        	,l_status_rec.LAST_UPDATE_LOGIN
        	,l_status_rec.PROGRAM_APPLICATION_ID
        	,l_status_rec.PROGRAM_ID
        	,l_status_rec.ATTRIBUTE_CATEGORY
        	,l_status_rec.ATTRIBUTE1
        	,l_status_rec.ATTRIBUTE2
        	,l_status_rec.ATTRIBUTE3
        	,l_status_rec.ATTRIBUTE4
       	 	,l_status_rec.ATTRIBUTE5
        	,l_status_rec.ATTRIBUTE6
        	,l_status_rec.ATTRIBUTE7
        	,l_status_rec.ATTRIBUTE8
        	,l_status_rec.ATTRIBUTE9
        	,l_status_rec.ATTRIBUTE10
        	,l_status_rec.ATTRIBUTE11
        	,l_status_rec.ATTRIBUTE12
        	,l_status_rec.ATTRIBUTE13
        	,l_status_rec.ATTRIBUTE14
        	,l_status_rec.ATTRIBUTE15
                ,l_status_rec.UPDATE_REASON_ID
		,l_status_rec.INITIAL_STATUS_FLAG
		,l_status_rec.FROM_MOBILE_APPS_FLAG
                -- NSRIVAST, INVCONV , Start
                ,l_status_rec.GRADE_CODE
                ,l_status_rec.PRIMARY_ONHAND
                ,l_status_rec.SECONDARY_ONHAND
                -- NSRIVAST, INVCONV , End
        	);
		--BEGIN SCHANDRU INVERES
		IF g_eres_enabled <> 'N' THEN
			      Insert into MTL_GRADE_STATUS_ERES_GTMP(status_update_id,
				      grade_update_id) values (l_status_update_id, NULL);
		END IF;
		-- END SCHANDRU INVERES


		--Bug# 1695432 added INITIAL_STATUS_FLAG,FROM_MOBILE_APPS_FLAG col

            END LOOP;
        end if;

        -- call print_label to print the label
        /* inv_label.print_label(
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data              => l_msg_data,
             x_label_status          => l_label_status,
             p_api_version           => 1.0,
             p_print_mode            => 2,
             p_business_flow_code    => 10,
             p_input_param_rec       => l_input_param_rec); */
       -- changed to call INV_LABEL.PRINT_LABEL_MANUAL_WRAP to pass serial range
       INV_LABEL.PRINT_LABEL_MANUAL_WRAP(
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data              => l_msg_data,
             x_label_status          => l_label_status,
             p_business_flow_code    => 10,
             p_organization_id       => l_status_rec.organization_id,
             p_subinventory_code     => l_status_rec.zone_code,
             p_locator_id            => l_status_rec.locator_id,
             p_inventory_item_id     => l_status_rec.inventory_item_id,
             p_lot_number            => l_status_rec.lot_number,
             p_fm_serial_number      => l_status_rec.serial_number,
             p_to_serial_number      => l_to_serial_number);

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
            FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL');
            FND_MSG_PUB.ADD;
       END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       Raise FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Status_history'
            );
        END IF;


       Raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_status_history;

FUNCTION validate_mtstatus(
p_old_status_id         mtl_material_statuses.status_id%TYPE,
p_new_status_id         mtl_material_statuses.status_id%TYPE ,
p_subinventory_code     mtl_onhand_quantities_detail.subinventory_code%TYPE,
p_locator_id            mtl_onhand_quantities_detail.locator_id%TYPE,
p_organization_id       mtl_secondary_inventories.organization_id%TYPE,
p_inventory_item_id     mtl_onhand_quantities_detail.inventory_item_id%TYPE
)RETURN BOOLEAN AS

p_lot_number mtl_onhand_quantities_detail.lot_number%TYPE := NULL;
l_return_status BOOLEAN;

BEGIN

inv_trx_util_pub.TRACE('inside non-overloaded validate_mtstatus ', 'INV_MATERIAL_STATUS_PKG', 14);

l_return_status := validate_mtstatus(
                          p_old_status_id,
                          p_new_status_id,
                          p_subinventory_code,
                          p_locator_id,
                          p_organization_id,
                          p_inventory_item_id,
                          p_lot_number);

if (l_return_status) then
  inv_trx_util_pub.TRACE('validate_mtstatus: returning true', 'INV_MATERIAL_STATUS_PKG', 14);
else
  inv_trx_util_pub.TRACE('validate_mtstatus: returning false', 'INV_MATERIAL_STATUS_PKG', 14);
end if;

return l_return_status;

EXCEPTION
   when others then
      return TRUE;
END;


/* Bug 6837479 */
FUNCTION validate_mtstatus(
p_old_status_id         mtl_material_statuses.status_id%TYPE,
p_new_status_id         mtl_material_statuses.status_id%TYPE ,
p_subinventory_code     mtl_onhand_quantities_detail.subinventory_code%TYPE,
p_locator_id            mtl_onhand_quantities_detail.locator_id%TYPE,
p_organization_id       mtl_secondary_inventories.organization_id%TYPE,
p_inventory_item_id     mtl_onhand_quantities_detail.inventory_item_id%TYPE,
p_lot_number            mtl_onhand_quantities_detail.lot_number%TYPE
)RETURN BOOLEAN AS

l_return_status        BOOLEAN;
l_dummy_param          NUMBER := 1;

BEGIN

inv_trx_util_pub.TRACE('inside 1st overloaded validate_mtstatus ', 'INV_MATERIAL_STATUS_PKG', 14);

l_return_status := validate_mtstatus(
                          p_old_status_id,
                          p_new_status_id,
                          p_subinventory_code,
                          p_locator_id,
                          p_organization_id,
                          p_inventory_item_id,
                          p_lot_number,
                          l_dummy_param);

if (l_return_status) then
  inv_trx_util_pub.TRACE('1st validate_mtstatus: returning true', 'INV_MATERIAL_STATUS_PKG', 14);
else
  inv_trx_util_pub.TRACE('1st validate_mtstatus: returning false', 'INV_MATERIAL_STATUS_PKG', 14);
end if;

if (NOT l_return_status) then
  -- ER Change: Calling the hook
  inv_trx_util_pub.TRACE('validate_mtstatus: Calling the hook', 'INV_MATERIAL_STATUS_PKG', 14);
  inv_material_status_hook.validate_rsv_matstatus(p_old_status_id,
                                                  p_new_status_id,
                                                  p_subinventory_code,
                                                  p_locator_id,
                                                  p_organization_id,
                                                  p_inventory_item_id,
                                                  p_lot_number,
                                                  l_return_status);

  if (l_return_status) then
     inv_trx_util_pub.TRACE('Hook returned true', 'INV_MATERIAL_STATUS_PKG', 14);
  else
     inv_trx_util_pub.TRACE('Hook returned false', 'INV_MATERIAL_STATUS_PKG', 14);
  end if;

end if;

return l_return_status;

EXCEPTION
   when others then
      inv_trx_util_pub.TRACE('Exception was raised', 'INV_MATERIAL_STATUS_PKG', 14);
      return TRUE;
END;

/* Bug 6837479: Modified the function to properly check for existing
 * reservations
 */
--INVCONV kkillams
FUNCTION validate_mtstatus(
p_old_status_id         mtl_material_statuses.status_id%TYPE,
p_new_status_id         mtl_material_statuses.status_id%TYPE ,
p_subinventory_code     mtl_onhand_quantities_detail.subinventory_code%TYPE,
p_locator_id            mtl_onhand_quantities_detail.locator_id%TYPE,
p_organization_id       mtl_secondary_inventories.organization_id%TYPE,
p_inventory_item_id     mtl_onhand_quantities_detail.inventory_item_id%TYPE,
p_lot_number            mtl_onhand_quantities_detail.lot_number%TYPE, /* bug 6837479 */
p_dummy_param           NUMBER
)RETURN BOOLEAN AS
        CURSOR cur_mt_status (cp_old_status_id mtl_material_statuses.status_code%TYPE,
                              cp_new_status_id mtl_material_statuses.status_code%TYPE) IS
                              SELECT 1 FROM mtl_material_statuses mts1,
                                            mtl_material_statuses mts2
                                       WHERE  cp_old_status_id <> cp_new_status_id
                                       AND mts1.status_id      = cp_old_status_id
                                       AND mts1.reservable_type  = 1
                                       AND mts2.status_id = cp_new_status_id
                                       AND mts2.reservable_type  <> mts1.reservable_type;

        CURSOR c_subinv_items(cp_organization_id        mtl_onhand_quantities_detail.organization_id%TYPE,
                              cp_inventory_item_id      mtl_onhand_quantities_detail.inventory_item_id%TYPE,
                              cp_subinventory_code      mtl_onhand_quantities_detail.subinventory_code%TYPE) IS
                              SELECT 1 FROM mtl_onhand_quantities_detail moq
                                       WHERE organization_id  = cp_organization_id
                                       AND subinventory_code  = cp_subinventory_code
                                       AND EXISTS
                                            (SELECT 1
                                             FROM mtl_reservations mr
                                             WHERE mr.inventory_item_id = moq.inventory_item_id
                                             AND mr.organization_id = moq.organization_id
                                             /* Bug 8674685
                                             AND ( (mr.inventory_item_id = cp_inventory_item_id )
                                                     OR cp_inventory_item_id IS NULL
                                                 )
                                             */
                                             AND ( (mr.subinventory_code = cp_subinventory_code )
                                                     OR mr.subinventory_code IS NULL
                                                 )
                                            )
                                       AND ROWNUM = 1;

        CURSOR c_locator_items(cp_organization_id        mtl_onhand_quantities_detail.organization_id%TYPE,
                               cp_inventory_item_id      mtl_onhand_quantities_detail.inventory_item_id%TYPE,
                               cp_locator_id             mtl_onhand_quantities_detail.locator_id%TYPE) IS
                              SELECT 1 FROM mtl_onhand_quantities_detail moq
                                       WHERE organization_id  = cp_organization_id
                                       AND locator_id = cp_locator_id
                                       AND EXISTS
                                            (SELECT 1
                                             FROM mtl_reservations mr
                                             WHERE mr.inventory_item_id = moq.inventory_item_id
                                             AND mr.organization_id = moq.organization_id
                                             /* Bug 8674685
                                             AND ( (mr.inventory_item_id = cp_inventory_item_id )
                                                     OR cp_inventory_item_id IS NULL
                                                 )
                                             */
                                             AND ( (mr.locator_id = cp_locator_id )
                                                  OR ( (mr.locator_id IS NULL
                                                        AND mr.subinventory_code = moq.subinventory_code
                                                       )
                                                       OR mr.subinventory_code IS NULL
                                                     )
                                                 )
                                            )
                                       AND ROWNUM = 1;

        CURSOR c_lot_items(   cp_organization_id        mtl_reservations.organization_id%TYPE,
                              cp_inventory_item_id      mtl_reservations. inventory_item_id %TYPE,
                              cp_lot_number             mtl_onhand_quantities_detail.lot_number%TYPE) IS
                              SELECT 1 FROM mtl_onhand_quantities_detail moq
                                       WHERE organization_id  = cp_organization_id
                                       AND (inventory_item_id = cp_inventory_item_id OR cp_inventory_item_id IS NULL)
                                       AND lot_number = cp_lot_number
                                       AND EXISTS
                                            (SELECT 1
                                             FROM mtl_reservations mr
                                             WHERE mr.inventory_item_id = moq.inventory_item_id
                                             AND mr.organization_id = moq.organization_id
                                             AND ( (mr.inventory_item_id = cp_inventory_item_id )
                                                     OR cp_inventory_item_id IS NULL
                                                 )
                                             AND ( (mr.lot_number = cp_lot_number )
                                                     OR mr.lot_number IS NULL
                                                 )
                                            )
                                       AND ROWNUM = 1;

        CURSOR c_items_reserv( cp_organization_id        mtl_reservations.organization_id%TYPE,
                               cp_inventory_item_id      mtl_reservations. inventory_item_id%TYPE) IS
                              SELECT 1 FROM mtl_reservations
                                       WHERE inventory_item_id = cp_inventory_item_id
                                       AND organization_id  = cp_organization_id
                                       AND ROWNUM = 1;

        l_dummy        NUMBER;
BEGIN

    inv_trx_util_pub.TRACE('inside 2nd overloaded validate_mtstatus ', 'INV_MATERIAL_STATUS_PKG', 14);
    inv_trx_util_pub.TRACE('validate_mtstatus: old status id: '||p_old_status_id, 'INV_MATERIAL_STATUS_PKG', 14);
    inv_trx_util_pub.TRACE('validate_mtstatus: new status id: '||p_new_status_id, 'INV_MATERIAL_STATUS_PKG', 14);
    inv_trx_util_pub.TRACE('validate_mtstatus: organization id: '||p_organization_id, 'INV_MATERIAL_STATUS_PKG', 14);
    inv_trx_util_pub.TRACE('validate_mtstatus: inventory item id: '||p_inventory_item_id, 'INV_MATERIAL_STATUS_PKG', 14);
    inv_trx_util_pub.TRACE('validate_mtstatus: subinventory: '||p_subinventory_code, 'INV_MATERIAL_STATUS_PKG', 14);
    inv_trx_util_pub.TRACE('validate_mtstatus: locator id: '||p_locator_id, 'INV_MATERIAL_STATUS_PKG', 14);
    inv_trx_util_pub.TRACE('validate_mtstatus: lot number: '||p_lot_number, 'INV_MATERIAL_STATUS_PKG', 14);
    inv_trx_util_pub.TRACE('validate_mtstatus: dummy parameter: '||p_dummy_param, 'INV_MATERIAL_STATUS_PKG', 14);

    OPEN cur_mt_status(p_old_status_id,p_new_status_id);
    FETCH cur_mt_status INTO l_dummy;
    IF cur_mt_status%NOTFOUND THEN
       CLOSE cur_mt_status;

       inv_trx_util_pub.TRACE('validate_mtstatus: New status also allows reservation: '||p_new_status_id, 'INV_MATERIAL_STATUS_PKG', 14);

       RETURN TRUE;
    END IF; --cur_mt_status
    CLOSE cur_mt_status;

    inv_trx_util_pub.TRACE('validate_mtstatus: New status does not allow reservation: '||p_new_status_id, 'INV_MATERIAL_STATUS_PKG', 14);

    IF (p_lot_number IS NOT NULL ) THEN
       inv_trx_util_pub.TRACE('validate_mtstatus: lot number: '||p_lot_number, 'INV_MATERIAL_STATUS_PKG', 14);
       OPEN c_lot_items(p_organization_id,p_inventory_item_id,p_lot_number);
       FETCH c_lot_items INTO l_dummy;
       IF c_lot_items%FOUND THEN
          CLOSE c_lot_items;

          inv_trx_util_pub.TRACE('validate_mtstatus: reservations exist for the lot number: '||p_lot_number, 'INV_MATERIAL_STATUS_PKG', 14);

          RETURN FALSE;
       END IF;
       CLOSE c_lot_items;

    ELSIF ( p_locator_id IS NOT NULL) THEN
       inv_trx_util_pub.TRACE('validate_mtstatus: locator id: '||p_locator_id, 'INV_MATERIAL_STATUS_PKG', 14);
       OPEN c_locator_items(p_organization_id,p_inventory_item_id,p_locator_id);
       FETCH c_locator_items INTO l_dummy;
       IF c_locator_items%FOUND THEN
          CLOSE c_locator_items;

          inv_trx_util_pub.TRACE('validate_mtstatus: reservations exist for locator id: '||p_locator_id, 'INV_MATERIAL_STATUS_PKG', 14);

          RETURN FALSE;
       END IF;
       CLOSE c_locator_items;

    --If api is called from subinventory/locator form.
    ELSIF (P_subinventory_code IS NOT NULL ) THEN
       inv_trx_util_pub.TRACE('validate_mtstatus: subinventory: '||p_subinventory_code, 'INV_MATERIAL_STATUS_PKG', 14);
       -- Bug 6829224: Passing item_id to the cursor
       OPEN c_subinv_items(p_organization_id,p_inventory_item_id,p_subinventory_code);
       FETCH c_subinv_items INTO l_dummy;
       IF c_subinv_items%FOUND THEN
          CLOSE c_subinv_items;

          inv_trx_util_pub.TRACE('validate_mtstatus: reservations exist for the subinventory: '||p_subinventory_code, 'INV_MATERIAL_STATUS_PKG', 14);

          RETURN FALSE;
       END IF;
       CLOSE c_subinv_items;

    ELSE
        inv_trx_util_pub.TRACE('validate_mtstatus: checking reservatios only for the item', 'INV_MATERIAL_STATUS_PKG', 14);
        OPEN c_items_reserv(p_organization_id,p_inventory_item_id);
        FETCH c_items_reserv INTO l_dummy;
        IF c_items_reserv%FOUND THEN
           CLOSE c_items_reserv;

           inv_trx_util_pub.TRACE('validate_mtstatus: reservations exist for the item: '||p_inventory_item_id, 'INV_MATERIAL_STATUS_PKG', 14);

           RETURN FALSE;
        END IF;  --c_items_reserv
        CLOSE c_items_reserv;
    END IF; --P_subinventory_code IS NOT NULL

    inv_trx_util_pub.TRACE('2nd overloaded validate_mtstatus: returning true', 'INV_MATERIAL_STATUS_PKG', 14);

    RETURN TRUE;

EXCEPTION
when others then
      return TRUE;

END validate_mtstatus;

PROCEDURE SET_MS_FLAGS(
 p_status_id                MTL_MATERIAL_STATUSES.STATUS_ID%TYPE
,p_org_id                   MTL_SECONDARY_INVENTORIES.ORGANIZATION_ID%TYPE
,p_inventory_item_id        MTL_LOT_NUMBERS.INVENTORY_ITEM_ID%TYPE DEFAULT NULL
,p_secondary_inventory_name MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE DEFAULT NULL
,p_lot_number               MTL_LOT_NUMBERS.LOT_NUMBER%TYPE DEFAULT NULL
,p_inventory_location_id    MTL_ITEM_LOCATIONS.INVENTORY_LOCATION_ID%TYPE DEFAULT NULL
,p_serial_number            MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE DEFAULT NULL
) AS
CURSOR cur_ms IS SELECT inventory_atp_code
                       ,reservable_type
                       ,availability_type FROM mtl_material_statuses
                                          WHERE status_id = p_status_id;
rec_ms cur_ms%ROWTYPE;
BEGIN
   OPEN cur_ms;
   FETCH cur_ms INTO rec_ms;
   CLOSE cur_ms;
   IF p_lot_number IS NOT NULL THEN
           UPDATE mtl_lot_numbers SET   inventory_atp_code =rec_ms.inventory_atp_code,
                                        availability_type  =rec_ms.reservable_type,
                                        reservable_type    =rec_ms.availability_type
                                  WHERE organization_id      = p_org_id
                                  AND   lot_number           = p_lot_number
                                  AND   inventory_item_id    = p_inventory_item_id;
   ELSIF p_serial_number IS NOT NULL THEN

   /* Bug#4560805 The columns inventory_atp_code,availability_type and reservable_type are not a part of
      mtl_serial_numbers. Hence commenting the UPDATE statement */

   /*
           UPDATE mtl_serial_numbers SET inventory_atp_code =rec_ms.inventory_atp_code,
                                         availability_type  =rec_ms.reservable_type,
                                         reservable_type    =rec_ms.availability_type
                                  WHERE current_organization_id      = p_org_id
                                  AND   serial_number                = p_serial_number
                                  AND   inventory_item_id            = p_inventory_item_id;
   */
	   NULL;
   ELSIF p_inventory_location_id IS NOT NULL THEN
           UPDATE MTL_ITEM_LOCATIONS SET   inventory_atp_code =rec_ms.inventory_atp_code,
                                           availability_type  =rec_ms.reservable_type,
                                           reservable_type    =rec_ms.availability_type
                                  WHERE organization_id = p_org_id
                                  AND   inventory_location_id = p_inventory_location_id;
   ELSIF p_secondary_inventory_name IS NOT NULL THEN
           UPDATE mtl_secondary_inventories SET   inventory_atp_code =rec_ms.inventory_atp_code,
                                                  availability_type  =rec_ms.reservable_type,
                                                  reservable_type    =rec_ms.availability_type
                                  WHERE organization_id = p_org_id
                                  AND   secondary_inventory_name =p_secondary_inventory_name;
   END IF;
END SET_MS_FLAGS;
--END INVCONV kkillams

END INV_MATERIAL_STATUS_PKG;

/
