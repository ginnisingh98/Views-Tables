--------------------------------------------------------
--  DDL for Package MRP_KANBAN_FUNCTIONS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_KANBAN_FUNCTIONS_PK" AUTHID CURRENT_USER AS
    /* $Header: MRPPKANS.pls 115.8 2003/05/30 09:01:37 nrajpal ship $ */
    PROCEDURE UPDATE_PULL_SEQUENCES
	(x_return_status 		OUT	NOCOPY VARCHAR2,
	 x_msg_count			OUT	NOCOPY NUMBER,
	 x_msg_data			OUT	NOCOPY VARCHAR2,
 	p_pull_sequence_id		IN	NUMBER,
	p_organization_id		IN	NUMBER,
	p_kanban_plan_id		IN	NUMBER,
	p_inventory_item_id		IN	NUMBER,
	p_subinventory_name		IN	VARCHAR2,
	p_locator_id			IN	NUMBER,
	p_kanban_size			IN	NUMBER,
	p_number_of_cards		IN	NUMBER,
	p_source_type			IN	NUMBER := FND_API.G_MISS_NUM,
	p_source_organization_id	IN	NUMBER := FND_API.G_MISS_NUM,
	p_source_subinventory		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_source_locator_id		IN	NUMBER := FND_API.G_MISS_NUM,
	p_line_id			IN	NUMBER := FND_API.G_MISS_NUM,
	p_supplier_id			IN	NUMBER := FND_API.G_MISS_NUM,
	p_supplier_site_id		IN	NUMBER := FND_API.G_MISS_NUM,
        p_calculate_kanban_flag         IN      NUMBER := FND_API.G_MISS_NUM,
        p_replenishment_lead_time       IN      NUMBER := FND_API.G_MISS_NUM,
        p_release_kanban_flag           IN      NUMBER := FND_API.G_MISS_NUM,
        p_minimum_order_quantity        IN      NUMBER := FND_API.G_MISS_NUM,
        p_fixed_lot_multiplier          IN      NUMBER := FND_API.G_MISS_NUM,
        p_safety_stock_days             IN      NUMBER := FND_API.G_MISS_NUM);

PROCEDURE DELETE_PULL_SEQUENCES
       (x_return_status                 OUT     NOCOPY VARCHAR2,
        x_msg_count                     OUT     NOCOPY NUMBER,
        x_msg_data                      OUT     NOCOPY VARCHAR2,
        p_kanban_plan_id                IN      NUMBER);

PROCEDURE UPDATE_AND_PRINT_KANBANS (
	x_return_status			OUT 	NOCOPY VARCHAR2,
	x_msg_count			OUT   	NOCOPY NUMBER,
	x_msg_data			OUT    	NOCOPY VARCHAR2,
	p_query_id			IN	NUMBER,
	p_update_flag			IN	VARCHAR2 );

PROCEDURE INSERT_PULL_SEQUENCES (
	x_return_status			OUT	NOCOPY  VARCHAR2,
	x_msg_count			OUT   	NOCOPY  NUMBER,
	x_msg_data			OUT    	NOCOPY  VARCHAR2,
        p_plan_pull_sequence_id		IN	NUMBER );
END mrp_kanban_functions_pk;

 

/
