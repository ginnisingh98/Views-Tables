--------------------------------------------------------
--  DDL for Package AHL_INV_RESERVATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_INV_RESERVATIONS_GRP" AUTHID CURRENT_USER AS
/* $Header: AHLGRSVS.pls 120.5 2005/06/30 11:52 anraj noship $ */
/*
 * This Group package provides the apis that will get final availability of the document line
 * for which the reservation is being created/modified and validate whether a supply or a demand line
 * for which the reservation is being created/ modified is a valid document line
 */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_INV_RESERVATIONS_GRP';


/*
 * The purpose of this API is to get the final availability of the document line for which the reservation is being
 * created/modified. This procedure will be called by the inventory APIs to get the expected availability at the
 * document level. The reason being that the actual ordered/receipt quantity on the document may not reflect the
 * expected quantity that is pending. Reservation API needs to know the final availability so that the ATR (available
 * to reserve) can be calculated.
 *
 * Parameters:
 * p_organization_id Organization id of the document to be validated
 * p_item_id Inventory item id of the document to be validated
 * p_revision Revision of the item
 * p_lot_number Lot number of the item
 * p_subinventory_code Subinventory code
 * p_locator_id Locator id of the subinventory if the subinventory is locator controlled
 * p_supply_demand_code The action determines whether the calling API is querying for a supply or demand
 * p_supply_demand_type_id This holds the demand type for which the availability is to be checked
 * p_supply_demand_header_id This holds the header information of the demand document for which the availability is to be checked
 * p_supply_demand_line_id This holds the line information of the demand document for which the availability is to be checked
 * p_supply_demand_line_detail This holds the line information of the demand document for which the availability is to be checked
 * p_lpn_id This is the lpn for the supply document for which the availability is going to be computed
 * p_project_id This holds the project id for the demand document
 * p_task_id This holds the task id for the demand document
 * x_available_quantity Returns the final available quantity on the document line for which the reservation is being made
 */
PROCEDURE get_available_supply_demand (
			  p_api_version_number     		IN     	NUMBER := 1.0
			, p_init_msg_lst             		IN	      VARCHAR2  := fnd_api.g_false
			, x_return_status            		OUT    	NOCOPY VARCHAR2
  			, x_msg_count                		OUT    	NOCOPY NUMBER
			, x_msg_data                 		OUT    	NOCOPY VARCHAR2
			, p_organization_id					IN 		NUMBER :=  null
			, p_item_id								IN 		NUMBER := null
			, p_revision							IN 		VARCHAR2 := null
			, p_lot_number							IN			VARCHAR2 := null
			, p_subinventory_code				IN			VARCHAR2 := null
			, p_locator_id							IN 		NUMBER := null
			, p_supply_demand_code				IN			NUMBER
			, p_supply_demand_type_id			IN			NUMBER
			, p_supply_demand_header_id		IN			NUMBER
			, p_supply_demand_line_id			IN			NUMBER
			, p_supply_demand_line_detail		IN			NUMBER := fnd_api.g_miss_num
			, p_lpn_id								IN			NUMBER := fnd_api.g_miss_num
			, p_project_id							IN			NUMBER := null
			, p_task_id								IN			NUMBER := null
			, x_available_quantity				OUT      NOCOPY NUMBER
			, x_source_uom_code					OUT		NOCOPY VARCHAR2
			,  x_source_primary_uom_code		OUT		NOCOPY VARCHAR2
);

/*
 * The purpose of this API is to validate whether a supply or a demand line for which the reservation is being
 * created/ modified is a valid document line. This procedure will be called by the inventory APIs to validate a
 * supply or a demand document, if the supply/demand document line is non-inventory.
 *
 * Parameters:
 * p_api_version_number Api Version Number,Standard API parameter
 * p_init_msg_lst Initialize the message stack,Standard API parameter
 * x_return_status Return status,Standard API parameter
 * x_msg_count Return message count,Standard API parameter
 * x_msg_data Return message data,Standard API parameter
 * p_organization_id Organization id of the document to be validated
 * p_item_id Inventory item id of the document to be validated
 * p_supply_demand_code The action determines whether the calling API is querying for a supply or demand
 * p_supply_demand_type_id This holds the demand type for which the availability is to be checked
 * p_supply_demand_header_id This holds the header information of the demand document for which the availability is to be checked
 * p_supply_demand_line_id This holds the line information of the demand document for which the availability is to be checked
 * p_supply_demand_line_detail This holds the line information of the demand document for which the availability is to be checked
 * p_demand_ship_date This is will be filled in for reservations that are crossdocked. For non-crossdocked reservations, this will be the need-by-date of the demand
 * p_expected_receipt_date This is will be filled in for reservations that are crossdocked. For non-crossdocked reservations, this will be null.
 * x_valid_status Returns whether the supply or demand document is valid or not
 */
PROCEDURE validate_supply_demand (
			  p_api_version_number     		IN     	NUMBER := 1.0
		  	, p_init_msg_lst             		IN       VARCHAR2 := fnd_api.g_false
			, x_return_status            		OUT    	NOCOPY VARCHAR2
  			, x_msg_count                		OUT    	NOCOPY NUMBER
			, x_msg_data                 		OUT    	NOCOPY VARCHAR2
			, p_organization_id					IN			NUMBER
			, p_item_id								IN			NUMBER
			, p_supply_demand_code				IN			NUMBER
			, p_supply_demand_type_id			IN			NUMBER
			, p_supply_demand_header_id		IN			NUMBER
			, p_supply_demand_line_id			IN			NUMBER
			, p_supply_demand_line_detail		IN			NUMBER := fnd_api.g_miss_num
			, p_demand_ship_date					IN			DATE
			, p_expected_receipt_date			IN			DATE
			, x_valid_status						OUT      NOCOPY VARCHAR2
);

END AHL_INV_RESERVATIONS_GRP;

 

/
