--------------------------------------------------------
--  DDL for Package FTE_VEHICLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_VEHICLE_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEVEHLS.pls 115.3 2004/02/25 02:41:25 ttrichy ship $ */

-- Procecure : Create_Update_Vehicle_Type
-- Purpose   : Create or update a Vehicle Type
--             1) Insert/Update FTE_VEHICLE_TYPES
--             2) Insert/Update/Delete FTE_VEHICLE_FEATURES
--             3) Call INV_ITEM_GRP.CREATE_ITEM/UPDATE_ITEM
--	          to create/update an inventory master item

PROCEDURE Create_Update_Vehicle_Type
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
    p_features_table		IN	STRINGARRAY,	        -- Databae Type
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
);

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
);

--  Procecure : Upgrade_Items
--  Purpose   : Upgrade Inventory Master Items of type Vehicle to Vehicle Types
--              1) Select from MTL_SYSTEM_ITEMS
--              2) Insert into FTE_VEHICLE_TYPES

PROCEDURE Upgrade_Items
(   x_return_status 		OUT NOCOPY 	VARCHAR2,
    x_error_message		OUT NOCOPY	VARCHAR2
);

--  Function : Get_Vehicle_Type_Id
--  Purpose  : Convert the Inventory Item Id into Vehicle Type Id
--             If there's more than one Vehicle Types matching the given
--             the Inventory Item Id, the first one will be returned.
FUNCTION GET_VEHICLE_TYPE_ID
(   p_inventory_item_id 	IN NUMBER ) RETURN NUMBER;

-- Function : get_vehicle_org_id
-- Purpose  : Get the vehicle org id for a given inventory item id
--            from fte_vehicle_types

FUNCTION GET_VEHICLE_ORG_ID
(   p_inventory_item_id         IN NUMBER ) RETURN NUMBER;

END FTE_VEHICLE_PKG;

 

/
