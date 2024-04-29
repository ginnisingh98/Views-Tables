--------------------------------------------------------
--  DDL for Package WSM_RESERVATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_RESERVATIONS_GRP" AUTHID CURRENT_USER as
/* $Header: WSMGRSVS.pls 120.0 2005/06/27 08:30:41 mprathap noship $ */

PROCEDURE get_available_supply_demand (
	x_return_status            	OUT    	NOCOPY VARCHAR2
  	, x_msg_count                	OUT    	NOCOPY NUMBER
	, x_msg_data                 	OUT    	NOCOPY VARCHAR2
	, x_available_quantity		OUT     NOCOPY NUMBER
	, x_source_uom_code		OUT	NOCOPY VARCHAR2
	, x_source_primary_uom_code	OUT	NOCOPY VARCHAR2
	, p_organization_id		IN 	NUMBER default null
	, p_item_id			IN 	NUMBER default null
	, p_revision			IN 	VARCHAR2 default null
	, p_lot_number			IN	VARCHAR2 default null
	, p_subinventory_code		IN	VARCHAR2 default null
	, p_locator_id			IN 	NUMBER default null
	, p_supply_demand_code		IN	NUMBER
	, p_supply_demand_type_id	IN	NUMBER
	, p_supply_demand_header_id	IN	NUMBER
	, p_supply_demand_line_id	IN	NUMBER
	, p_supply_demand_line_detail	IN	NUMBER
	, p_lpn_id			IN	NUMBER
	, p_project_id			IN	NUMBER default null
	, p_task_id			IN	NUMBER default null
	, p_api_version_number     	IN     	NUMBER default 1.0
  	, p_init_msg_lst             	IN      VARCHAR2 DEFAULT fnd_api.g_false
	);

PROCEDURE validate_supply_demand (
	x_return_status            	OUT    	NOCOPY VARCHAR2
  	, x_msg_count                	OUT    	NOCOPY NUMBER
	, x_msg_data                 	OUT    	NOCOPY VARCHAR2
	, x_valid_status		OUT      NOCOPY VARCHAR2
	, p_organization_id		IN	NUMBER
	, p_item_id			IN	NUMBER
	, p_supply_demand_code		IN	NUMBER
	, p_supply_demand_type_id	IN	NUMBER
	, p_supply_demand_header_id	IN	NUMBER
	, p_supply_demand_line_id	IN	NUMBER
	, p_supply_demand_line_detail	IN	NUMBER
	, p_demand_ship_date		IN	DATE
	, p_expected_receipt_date	IN	DATE
	, p_api_version_number     	IN     	NUMBER default 1.0
  	, p_init_msg_lst             	IN      VARCHAR2 DEFAULT fnd_api.g_false
);
end WSM_RESERVATIONS_GRP;

 

/
