--------------------------------------------------------
--  DDL for Package CSD_ESTIMATES_FROM_BOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_ESTIMATES_FROM_BOM_PVT" AUTHID CURRENT_USER AS
	/* $Header: csdvboms.pls 120.0 2008/02/23 17:07:07 subhat noship $*/

	/* This is the wrapper Procedure to call the Bom Exploder.
	 -- This would retrieve a PL/SQL table and then insert it into the
	 --temporary table.
	 --@param:p_item: name of the item to be exploded.
	 --@param:p_alt_bom: alternate BOM if any.
	*/

PROCEDURE explode_bom_items(p_itemId IN NUMBER,p_alt_bom IN VARCHAR2 DEFAULT NULL );

PROCEDURE create_estimate_lines(p_itemQty IN varchar2_table_200,
	                        p_repair_line_id	IN NUMBER,
							p_repair_type_id	IN NUMBER,
							p_currency_code		IN VARCHAR2,
							p_org_id			IN NUMBER,
							p_repair_estimate_id IN NUMBER,
							p_pricelist_header_id IN NUMBER,
							p_contract_line_id	IN NUMBER default null,
							p_incident_id		IN NUMBER,
							p_init_msg_list		IN VARCHAR2,
							x_msg_data			OUT NOCOPY VARCHAR2,
							x_msg_count			OUT NOCOPY NUMBER,
							x_return_status		OUT NOCOPY varchar2);

FUNCTION get_default_contract(l_contract_line_id IN NUMBER,
					  l_repair_type_id IN NUMBER,
					  x_msg_count OUT NOCOPY NUMBER,
					  x_msg_data  OUT NOCOPY VARCHAR2,
					  x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER;


FUNCTION get_item_cost(p_item_id IN number,
				   p_uom IN varchar2,
				   p_currency_code IN varchar2,
				   p_org_id IN NUMBER,
				   x_msg_count OUT NOCOPY NUMBER,
				   x_msg_data  OUT NOCOPY VARCHAR2,
				   x_return_status OUT NOCOPY VARCHAR2) return NUMBER ;

FUNCTION get_selling_price(p_item_id IN number,
				   p_uom IN varchar2,
				   p_quantity IN number,
				   p_pricelist_header_id IN number,
				   p_currency_code IN varchar2,
				   p_org_id IN NUMBER,
				   x_msg_count OUT NOCOPY NUMBER,
				   x_msg_data  OUT NOCOPY VARCHAR2,
				   x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION get_discount_price(p_contract_line_id IN NUMBER,p_repair_type_id IN number,
				p_selling_price IN NUMBER,p_quantity IN NUMBER,
				x_msg_count OUT NOCOPY NUMBER,
				x_msg_data  OUT NOCOPY VARCHAR2,
				x_return_status OUT NOCOPY VARCHAR2)RETURN NUMBER;

END CSD_ESTIMATES_FROM_BOM_PVT;

/
