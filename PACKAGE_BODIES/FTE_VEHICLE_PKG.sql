--------------------------------------------------------
--  DDL for Package Body FTE_VEHICLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_VEHICLE_PKG" AS
/* $Header: FTEVEHLB.pls 120.0 2005/05/26 18:07:02 appldev noship $ */


PROCEDURE VALIDATE_VEHICLE_TYPE
(
    p_organization_name		IN		VARCHAR2,
    p_status			IN 		VARCHAR2,
    p_weight_uom	     	IN		VARCHAR2,
    p_volume_uom	     	IN		VARCHAR2,
    p_dimension_uom	     	IN		VARCHAR2,
    x_organization_id    	OUT NOCOPY	NUMBER,
    x_weight_uom_code    	OUT NOCOPY	VARCHAR2,
    x_volume_uom_code    	OUT NOCOPY	VARCHAR2,
    x_dimension_uom_code 	OUT NOCOPY	VARCHAR2,
    x_return_status	     	OUT NOCOPY	VARCHAR2,
    x_error_table	     	OUT NOCOPY	STRINGARRAY
)
IS
    i			NUMBER := 0;
    t_status		VARCHAR2(10);
BEGIN

    x_error_table := STRINGARRAY(NULL,NULL,NULL,NULL,NULL);
    if (p_organization_name is not null)
    then
      	BEGIN
    	    SELECT ORGANIZATION_ID INTO x_organization_id
	      FROM HR_ORGANIZATION_UNITS
		WHERE NAME = p_organization_name;
      	EXCEPTION
	    WHEN OTHERS THEN
		i := i+1;
	  	x_error_table(i) := fnd_message.get_string('FTE','FTE_VEH_ORG_INVALID');
      	END;
    end if;

    if (p_status is not null)
    then
      	BEGIN
    	    SELECT INVENTORY_ITEM_STATUS_CODE INTO t_status
	      FROM MTL_ITEM_STATUS
	     WHERE INVENTORY_ITEM_STATUS_CODE = p_status;
      	EXCEPTION
	    WHEN OTHERS THEN
		i := i+1;
	  	x_error_table(i) := fnd_message.get_string('FTE','FTE_VEH_STATUS_INVALID');
      	END;
    end if;

    -- Bug 4127713
    -- Validate against the Weight UOM Class defined in Global Parameters
    -- 1) If it's not defined, no UOM is acceptable
    --    : current implementation to be consistent with LOV behavior
    --      (java/util/webui/LovUOMCO.java)
    -- 2) The alternative would be validating against all UOM Classes.
    --      AND UOM_CLASS like (select gu_weight_class
    --                            from wsh_global_parameters
    --                           where rownum=1)||'%';
    --    :The defect with this approach is if 'Weight' is set as the default
    --     class and a non-used 'Weight***' class exists, any UOM belonging to
    --     'Weight***' can also be accepted.

    if (p_weight_uom is not null)
    then
      	BEGIN
    	    SELECT UOM_CODE INTO x_weight_uom_code
	      FROM MTL_UNITS_OF_MEASURE_TL
	     WHERE UNIT_OF_MEASURE_TL = p_weight_uom
	       AND LANGUAGE = USERENV('LANG')
	       AND NVL(DISABLE_DATE, SYSDATE+1) > SYSDATE
               AND UOM_CLASS = (select gu_weight_class
                                  from wsh_global_parameters where rownum=1);

      	EXCEPTION
	    WHEN OTHERS THEN
		i := i+1;
	  	x_error_table(i) := fnd_message.get_string('FTE','FTE_VEH_WEIGHT_UOM_INVALID');
      	END;
    end if;

    if (p_volume_uom is not null)
    then
      	BEGIN
    	    SELECT UOM_CODE INTO x_volume_uom_code
	      FROM MTL_UNITS_OF_MEASURE_TL
	     WHERE UNIT_OF_MEASURE_TL = p_volume_uom
	       AND LANGUAGE = USERENV('LANG')
	       AND NVL(DISABLE_DATE, SYSDATE+1) > SYSDATE
               AND UOM_CLASS = (select gu_volume_class
                                  from wsh_global_parameters where rownum=1);
      	EXCEPTION
	    WHEN OTHERS THEN
		i := i+1;
	  	x_error_table(i) := fnd_message.get_string('FTE','FTE_VEH_VOL_UOM_INVALID');
      	END;
    end if;

    if (p_dimension_uom is not null)
    then
      	BEGIN
    	    SELECT UOM_CODE INTO x_dimension_uom_code
	      FROM MTL_UNITS_OF_MEASURE_TL
	     WHERE UNIT_OF_MEASURE_TL = p_dimension_uom
	       AND LANGUAGE = USERENV('LANG')
	       AND NVL(DISABLE_DATE, SYSDATE+1) > SYSDATE
               AND UOM_CLASS = (select gu_dimension_class
                                  from wsh_global_parameters where rownum=1);
      	EXCEPTION
	    WHEN OTHERS THEN
		i := i+1;
	  	x_error_table(i) := fnd_message.get_string('FTE','FTE_VEH_DIM_UOM_INVALID');
      	END;
    end if;

    if (i = 0)
    then
	x_return_status := 'S';
    else
	x_return_status := 'E';
    end if;

END VALIDATE_VEHICLE_TYPE;

-- Procecure : CREATE_UPDATE_VEHICLE_TYPE (public API)
-- Purpose   : Create or update a Vehicle Type
--             1) Insert/Update FTE_VEHICLE_TYPES
--             2) Insert/Update/Delete FTE_VEHICLE_FEATURES
--             3) Call INV_ITEM_GRP.CREATE_ITEM/UPDATE_ITEM
--	          to create/update an inventory master item

PROCEDURE CREATE_UPDATE_VEHICLE_TYPE
(
    p_inventory_item_id		IN	NUMBER,		   /* MAIN PROPERTIES */
    p_organization_id		IN	NUMBER,
    p_organization_name		IN	VARCHAR2,
    p_vehicle_type_id		IN	NUMBER,
    p_vehicle_type_name		IN	VARCHAR2,
    p_vehicle_class_code	IN	VARCHAR2,
    p_status			IN	VARCHAR2,
    p_description		IN	VARCHAR2,
    p_weight_uom		IN	VARCHAR2, 	   /* LOAD CAPACITIES */
    p_maximum_load_weight	IN	NUMBER,
    p_volume_uom		IN	VARCHAR2,
    p_internal_volume		IN	NUMBER,
    p_pallet_floor_space	IN	NUMBER,
    p_pallet_stacking_height	IN	NUMBER,
    p_ef_volume_cap_direct	IN 	NUMBER,
    p_ef_volume_cap_pool	IN 	NUMBER,
    p_ef_volume_cap_one_stop	IN 	NUMBER,
    p_ef_volume_cap_two_stop	IN 	NUMBER,
    p_ef_volume_cap_two_pool	IN 	NUMBER,
    p_ef_volume_cap_three_pool	IN 	NUMBER,
    p_tare_weight		IN	NUMBER, 		/* DIMENSIONS */
    p_dimension_uom		IN	VARCHAR2,
    p_exterior_length		IN	NUMBER,
    p_exterior_width		IN	NUMBER,
    p_exterior_height		IN	NUMBER,
    p_usable_length		IN	NUMBER,
    p_usable_width		IN	NUMBER,
    p_usable_height		IN	NUMBER,
    p_suspension_type_code	IN	VARCHAR2, 		/* FEATURES */
    p_temperature_control_code	IN	VARCHAR2,
    p_features_table		IN	STRINGARRAY,		-- Database Type
    p_number_of_doors		IN	NUMBER,			/* DOORS */
    p_door_height		IN	NUMBER,
    p_door_width		IN	NUMBER,
    p_attribute1		IN	VARCHAR2,
    p_attribute2		IN	VARCHAR2,
    p_attribute3		IN	VARCHAR2,
    p_attribute4		IN	VARCHAR2,
    p_attribute5		IN	VARCHAR2,
    p_attribute6		IN	VARCHAR2,
    p_attribute7		IN	VARCHAR2,
    p_attribute8		IN	VARCHAR2,
    p_attribute9		IN	VARCHAR2,
    p_attribute10		IN	VARCHAR2,
    p_attribute11		IN	VARCHAR2,
    p_attribute12		IN	VARCHAR2,
    p_attribute13		IN	VARCHAR2,
    p_attribute14		IN	VARCHAR2,
    p_attribute15		IN	VARCHAR2,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_error_table		OUT NOCOPY	STRINGARRAY,
    x_vehicle_type_id		OUT NOCOPY	NUMBER
)
IS
    newItem		INV_ITEM_GRP.Item_rec_type;
    savedItem		INV_ITEM_GRP.Item_rec_type;
    errorTable		INV_ITEM_GRP.Error_tbl_type;
    errorRec		INV_ITEM_GRP.Error_rec_type;
    i			NUMBER := 0;

    --l_debug_on    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_debug_on    CONSTANT BOOLEAN := TRUE;
    l_module_name CONSTANT VARCHAR2(100) := 'FTE_VEHICLE_PKG';
    l_inventory_item_id NUMBER;

BEGIN

    x_error_table := STRINGARRAY(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

    newItem.ITEM_NUMBER 		:= p_vehicle_type_name;
    newItem.DESCRIPTION 		:= p_description;
    newItem.MAXIMUM_LOAD_WEIGHT 	:= p_maximum_load_weight;
    newItem.INTERNAL_VOLUME 		:= p_internal_volume;
    newItem.UNIT_WEIGHT 		:= p_tare_weight;
    newItem.UNIT_LENGTH 		:= p_exterior_length;
    newItem.UNIT_WIDTH 			:= p_exterior_width;
    newItem.UNIT_HEIGHT 		:= p_exterior_height;
    newItem.ENABLED_FLAG 		:= 'Y';
    newItem.VEHICLE_ITEM_FLAG 		:= 'Y';
    newItem.ATTRIBUTE1 			:= p_attribute1;
    newItem.ATTRIBUTE2 			:= p_attribute2;
    newItem.ATTRIBUTE3 			:= p_attribute3;
    newItem.ATTRIBUTE4 			:= p_attribute4;
    newItem.ATTRIBUTE5 			:= p_attribute5;
    newItem.ATTRIBUTE6 			:= p_attribute6;
    newItem.ATTRIBUTE7 			:= p_attribute7;
    newItem.ATTRIBUTE8 			:= p_attribute8;
    newItem.ATTRIBUTE9 			:= p_attribute9;
    newItem.ATTRIBUTE10 		:= p_attribute10;
    newItem.ATTRIBUTE11 		:= p_attribute11;
    newItem.ATTRIBUTE12 		:= p_attribute12;
    newItem.ATTRIBUTE13 		:= p_attribute13;
    newItem.ATTRIBUTE14 		:= p_attribute14;
    newItem.ATTRIBUTE15 		:= p_attribute15;

    IF l_debug_on THEN
      WSH_DEBUG_SV.PUSH(l_module_name);
    END IF;

    VALIDATE_VEHICLE_TYPE(p_organization_name  => p_organization_name,
			p_status             => p_status,
			p_weight_uom	     => p_weight_uom,
			p_volume_uom	     => p_volume_uom,
			p_dimension_uom	     => p_dimension_uom,
			x_organization_id    => newItem.ORGANIZATION_ID,
			x_weight_uom_code    => newItem.WEIGHT_UOM_CODE,
			x_volume_uom_code    => newItem.VOLUME_UOM_CODE,
			x_dimension_uom_code => newItem.DIMENSION_UOM_CODE,
			x_return_status	     => x_return_status,
			x_error_table	     => x_error_table);

    IF l_debug_on THEN
      WSH_DEBUG_SV.LOGMSG(l_module_name, 'ValidateVehicleType-'||x_return_status);
    END IF;

    if (x_return_status = 'E')
    then
	return;
    end if;

    SAVEPOINT Create_Update_Vehicle_Type;

    newItem.INVENTORY_ITEM_STATUS_CODE := p_status;

    -- CREATE
    if (p_vehicle_type_id is null)
    then

        -- Bug 3268520
        -- Begin : Check whether the given Name already exists
      	BEGIN
/*
            SELECT item.inventory_item_id INTO l_inventory_item_id
              FROM mtl_system_items_b_kfv item, fte_vehicle_types veh
             WHERE item.concatenated_segments = p_vehicle_type_name
               AND item.inventory_item_id = veh.inventory_item_id
               AND item.organization_id = veh.organization_id;

            -- This query is changed as follows
            -- to avoid INDEX FULL SCAN on FTE_VEHICLE_TYPES_U1
*/
            SELECT veh.inventory_item_id INTO l_inventory_item_id
              FROM fte_vehicle_types veh
             WHERE (veh.inventory_item_id, veh.organization_id) =
                   (SELECT item.inventory_item_id, item.organization_id
                      FROM mtl_system_items_b_kfv item
                     WHERE item.concatenated_segments = p_vehicle_type_name
                       AND rownum < 2);

            i := i+1;
            x_return_status := 'E';
            x_error_table(i) := fnd_message.get_string('FTE','FTE_VEH_NAME_UNIQUE_ERROR');
            return;

      	EXCEPTION
            WHEN NO_DATA_FOUND then
                null;
            WHEN TOO_MANY_ROWS then
                i := i+1;
                x_return_status := 'E';
                x_error_table(i) := fnd_message.get_string('FTE','FTE_VEH_NAME_UNIQUE_ERROR');
                return;
            WHEN OTHERS THEN
                i := i+1;
                x_return_status := 'E';
                x_error_table(i) := fnd_message.get_string('FTE','FTE_VEH_NAME_OTHER_ERROR2');
                return;
      	END;
        -- End : Check whether the given Name already exists

        IF l_debug_on THEN
          WSH_DEBUG_SV.LOGMSG(l_module_name, 'BeforeCreate');
        END IF;
    	INV_ITEM_GRP.Create_Item(p_Item_rec 	 => newItem,
				 x_Item_rec 	 => savedItem,
				 x_return_status => x_return_status,
				 x_Error_tbl 	 => errorTable);
    	IF l_debug_on THEN
          WSH_DEBUG_SV.LOGMSG(l_module_name, 'AfterCreate-'||x_return_status);
    	END IF;

	if (x_return_status = 'S')
	then
	    INSERT INTO FTE_VEHICLE_TYPES
		   (VEHICLE_TYPE_ID, INVENTORY_ITEM_ID,
		    ORGANIZATION_ID, VEHICLE_CLASS_CODE,
		    PALLET_FLOOR_SPACE, PALLET_STACKING_HEIGHT,
		    EF_VOLUME_CAP_DIRECT, EF_VOLUME_CAP_POOL,
		    EF_VOLUME_CAP_ONE_STOP, EF_VOLUME_CAP_TWO_STOP,
		    EF_VOLUME_CAP_TWO_POOL, EF_VOLUME_CAP_THREE_POOL,
		    USABLE_LENGTH, USABLE_WIDTH, USABLE_HEIGHT,
		    SUSPENSION_TYPE_CODE, TEMPERATURE_CONTROL_CODE,
		    NUMBER_OF_DOORS, DOOR_HEIGHT, DOOR_WIDTH,
		    CREATION_DATE, CREATED_BY,
		    LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
	    VALUES (FTE_VEHICLE_TYPES_S.NEXTVAL, savedItem.INVENTORY_ITEM_ID,
		    newItem.ORGANIZATION_ID, p_vehicle_class_code,
		    p_pallet_floor_space, p_pallet_stacking_height,
		    p_ef_volume_cap_direct, p_ef_volume_cap_pool,
		    p_ef_volume_cap_one_stop, p_ef_volume_cap_two_stop,
		    p_ef_volume_cap_two_pool, p_ef_volume_cap_three_pool,
		    p_usable_length, p_usable_width, p_usable_height,
		    p_suspension_type_code, p_temperature_control_code,
		    p_number_of_doors, p_door_height, p_door_width,
		    SYSDATE, FND_GLOBAL.USER_ID,
		    SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID)
	    RETURNING vehicle_type_id INTO x_vehicle_type_id;

    	    IF l_debug_on THEN
              WSH_DEBUG_SV.LOGMSG(l_module_name, 'AfterInsertType');
    	    END IF;

    	    FOR i IN 1..p_features_table.COUNT LOOP
		INSERT INTO FTE_VEHICLE_FEATURES
		       (VEHICLE_TYPE_FEATURE_ID, VEHICLE_TYPE_ID,
			VEHICLE_FEATURE_CODE,
			CREATION_DATE, CREATED_BY,
			LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
		VALUES (FTE_VEHICLE_FEATURES_S.NEXTVAL, x_vehicle_type_id,
			p_features_table(i),
		    	SYSDATE, FND_GLOBAL.USER_ID,
		    	SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID);
	    END LOOP;
    	    IF l_debug_on THEN
              WSH_DEBUG_SV.LOGMSG(l_module_name, 'AfterInsertFeature');
    	    END IF;

	end if;
    -- UPDATE
    else
    	IF l_debug_on THEN
          WSH_DEBUG_SV.LOGMSG(l_module_name, 'BeforeUpdate');
    	END IF;
	newItem.INVENTORY_ITEM_ID := p_inventory_item_id;
    	INV_ITEM_GRP.Update_Item(p_Item_rec 	 => newItem,
				 x_Item_rec 	 => savedItem,
				 x_return_status => x_return_status,
				 x_Error_tbl 	 => errorTable);
    	IF l_debug_on THEN
          WSH_DEBUG_SV.LOGMSG(l_module_name, 'AfterUpdate-'||x_return_status);
    	END IF;
	if (x_return_status = 'S')
	then
	    UPDATE FTE_VEHICLE_TYPES
	       SET VEHICLE_CLASS_CODE 	    = p_vehicle_class_code,
		   PALLET_FLOOR_SPACE 	    = p_pallet_floor_space,
		   PALLET_STACKING_HEIGHT   = p_pallet_stacking_height,
		   EF_VOLUME_CAP_DIRECT     = p_ef_volume_cap_direct,
		   EF_VOLUME_CAP_POOL       = p_ef_volume_cap_pool,
		   EF_VOLUME_CAP_ONE_STOP   = p_ef_volume_cap_one_stop,
		   EF_VOLUME_CAP_TWO_STOP   = p_ef_volume_cap_two_stop,
		   EF_VOLUME_CAP_TWO_POOL   = p_ef_volume_cap_two_pool,
		   EF_VOLUME_CAP_THREE_POOL = p_ef_volume_cap_three_pool,
		   USABLE_LENGTH 	    = p_usable_length,
		   USABLE_WIDTH  	    = p_usable_width,
		   USABLE_HEIGHT 	    = p_usable_height,
		   SUSPENSION_TYPE_CODE     = p_suspension_type_code,
		   TEMPERATURE_CONTROL_CODE = p_temperature_control_code,
		   NUMBER_OF_DOORS 	    = p_number_of_doors,
		   DOOR_HEIGHT     	    = p_door_height,
		   DOOR_WIDTH      	    = p_door_width,
		   LAST_UPDATE_DATE 	    = SYSDATE,
		   LAST_UPDATED_BY  	    = FND_GLOBAL.USER_ID,
		   LAST_UPDATE_LOGIN 	    = FND_GLOBAL.LOGIN_ID
	     WHERE VEHICLE_TYPE_ID = p_vehicle_type_id;
    	    IF l_debug_on THEN
              WSH_DEBUG_SV.LOGMSG(l_module_name, 'AfterInsertType');
    	    END IF;

	    DELETE FTE_VEHICLE_FEATURES
	     WHERE VEHICLE_TYPE_ID = p_vehicle_type_id;
    	    IF l_debug_on THEN
              WSH_DEBUG_SV.LOGMSG(l_module_name, 'AfterDeleteFeature');
    	    END IF;

    	    FOR i IN 1..p_features_table.COUNT LOOP
		INSERT INTO FTE_VEHICLE_FEATURES
		       (VEHICLE_TYPE_FEATURE_ID, VEHICLE_TYPE_ID,
			VEHICLE_FEATURE_CODE,
			CREATION_DATE, CREATED_BY,
			LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
		VALUES (FTE_VEHICLE_FEATURES_S.NEXTVAL, p_vehicle_type_id,
			p_features_table(i),
		    	SYSDATE, FND_GLOBAL.USER_ID,
		    	SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID);
	    END LOOP;
    	    IF l_debug_on THEN
              WSH_DEBUG_SV.LOGMSG(l_module_name, 'AfterInsertFeature-Update');
    	    END IF;
	end if;

    end if;

    FOR i IN 1..errorTable.COUNT LOOP
    	errorRec := errorTable(i);
	x_error_table(i) := errorRec.message_text;
        WSH_DEBUG_SV.LOGMSG(l_module_name, errorRec.message_text);
    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.POP(l_module_name);
    END IF;

    IF (x_return_status <> 'S') THEN
        ROLLBACK TO Create_Update_Vehicle_Type;
    END IF;

EXCEPTION WHEN OTHERS THEN
    x_return_status := 'E';
    x_error_table(1) := SQLERRM;
    IF l_debug_on THEN
      WSH_DEBUG_SV.LOGMSG(l_module_name, 'Exception Others'||SQLERRM);
      WSH_DEBUG_SV.POP(l_module_name);
    END IF;
    ROLLBACK TO Create_Update_Vehicle_Type;
END CREATE_UPDATE_VEHICLE_TYPE;

PROCEDURE UPGRADE_ITEMS
(   x_return_status             OUT NOCOPY    VARCHAR2,
    x_error_message             OUT NOCOPY    VARCHAR2)
IS

    CURSOR item_cur IS
	SELECT inventory_item_id, organization_id
	  FROM mtl_system_items
	 WHERE organization_id in (SELECT distinct master_organization_id
				     FROM mtl_parameters)
	   AND vehicle_item_flag = 'Y'
	   AND inventory_item_id not in	(SELECT inventory_item_id
		   	                   FROM fte_vehicle_types);
BEGIN

    FOR item_cur_rec IN item_cur
    LOOP
    	INSERT INTO FTE_VEHICLE_TYPES
	       (VEHICLE_TYPE_ID, INVENTORY_ITEM_ID,
	        ORGANIZATION_ID, CREATION_DATE, CREATED_BY,
		LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
    	VALUES (FTE_VEHICLE_TYPES_S.NEXTVAL, item_cur_rec.inventory_item_id,
	 	item_cur_rec.organization_id, SYSDATE, FND_GLOBAL.USER_ID,
	    	SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID);
    END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := 'E';
    x_error_message := SQLERRM;
    rollback;
END UPGRADE_ITEMS;

FUNCTION GET_VEHICLE_TYPE_ID
(   p_inventory_item_id         IN NUMBER ) RETURN NUMBER
IS
    x_vehicle_type_id NUMBER;
BEGIN

    SELECT vehicle_type_id INTO x_vehicle_type_id
    FROM   fte_vehicle_types
    WHERE  inventory_item_id = p_inventory_item_id;

    return x_vehicle_type_id;

EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      return x_vehicle_type_id;
    WHEN OTHERS THEN
      return -1;
END GET_VEHICLE_TYPE_ID;

-- Function : get_vehicle_org_id
-- Purpose  : Get the vehicle org id for a given inventory item id
--            from fte_vehicle_types

FUNCTION GET_VEHICLE_ORG_ID
(   p_inventory_item_id         IN NUMBER ) RETURN NUMBER
IS
    x_vehicle_org_id NUMBER;

    CURSOR c_get_veh_org IS
    SELECT organization_id
    FROM   fte_vehicle_types
    WHERE  inventory_item_id = p_inventory_item_id
    AND rownum=1;

BEGIN

    OPEN c_get_veh_org;
    FETCH c_get_veh_org INTO x_vehicle_org_id;
    IF c_get_veh_org%NOTFOUND THEN
       x_vehicle_org_id:=-1;
    END IF;
    CLOSE c_get_veh_org;

    return x_vehicle_org_id;

EXCEPTION
    WHEN OTHERS THEN
      return -1;
END GET_VEHICLE_ORG_ID;

END FTE_VEHICLE_PKG;

/
