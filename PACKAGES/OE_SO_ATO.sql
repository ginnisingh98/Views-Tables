--------------------------------------------------------
--  DDL for Package OE_SO_ATO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SO_ATO" AUTHID CURRENT_USER AS
/* $Header: oesoatos.pls 115.2 99/07/16 08:28:11 porting ship  $ */


	PROCEDURE QUERY_ATTRIBUTES(
			x_header_id 			IN 	NUMBER,
			x_line_id 			IN 	NUMBER,
			x_warehouse_id			IN	NUMBER,
			x_inventory_item_id		IN	NUMBER,
			x_organization_id		IN	NUMBER,
			x_order_number			IN	NUMBER,
			x_order_type			IN	VARCHAR2,
			x_s27				IN OUT	NUMBER,
			x_schato_allowed		OUT	VARCHAR2,
			x_configuration_item_id 	IN OUT	NUMBER,
			x_config_item_description	OUT	VARCHAR2,
			x_config_line_detail_id		OUT	NUMBER,
			x_configured_quantity		OUT	NUMBER,
			x_demand_source_header_id	OUT	NUMBER,
			x_demand_source_delivery	OUT	NUMBER,
			x_user_delivery			OUT	VARCHAR2,
			x_reserved_quantity		OUT	NUMBER,
			x_mfg_action			OUT 	VARCHAR2,
			x_mfg_result			OUT	VARCHAR2,
			x_action_date			OUT	VARCHAR2,
			x_creation_date_time		OUT	VARCHAR2);
END OE_SO_ATO;

 

/
