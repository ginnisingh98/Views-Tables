--------------------------------------------------------
--  DDL for Package CTO_TRANSFER_PRICE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_TRANSFER_PRICE_PK" AUTHID CURRENT_USER as
/* $Header: CTOTPRCS.pls 120.1 2005/10/28 15:15:30 rekannan noship $*/
/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOTPRCS.pls
|
|DESCRIPTION : Contains modules to :
|		1. Get the optional components of a configuration item from either the sales order or the BOM
|		2. Calculate Transfer Price for a configuration item
|
|HISTORY     : Created on 29-AUG-2003  by Sajani Sheth
|
+-----------------------------------------------------------------------------*/

/***********************************************************************
This procedure returns the optional components of a configuration item
and its child configuration items, based on either a sales order or the
configuration BOM.
The optional components are populated in table bom_explosion_temp with
a unique group_id. The group_id is passed back to the calling application.
***********************************************************************/
PROCEDURE get_config_details
(
p_item_id IN number,
p_org_id IN number default NULL,
p_mode_id IN number default 3,
p_configs_only IN varchar2 default 'N',
p_line_id      IN Number default null,
x_group_id OUT NOCOPY number,
x_msg_count OUT NOCOPY number,
x_msg_data OUT NOCOPY varchar2,
x_return_status OUT NOCOPY varchar);


/***********************************************************************
This procedure returns the optional components of a configuration item
and its child configuration items, based on a sales order. The optional
components are populated in table bom_explosion_temp for input parameter
group_id.
***********************************************************************/
PROCEDURE get_config_details_bcol
(p_line_id IN NUMBER,
p_grp_id IN NUMBER,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2);


/***********************************************************************
This procedure returns the optional components of a configuration item
and its child configuration items, based on the configuration BOM. The
optional components are populated in table bom_explosion_temp for
input parameter group_id.
***********************************************************************/
PROCEDURE get_config_details_bom
(p_item_id IN NUMBER,
p_organization_id IN NUMBER,
p_grp_id IN NUMBER,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2);


/**************************************************************************
   Procedure:   Cto_Transfer_Price
   Parameters:  P_config_item_id
		P_selling_oper_unit
		P_shipping_oper_unit
		P_transaction_uom
		P_transaction_id
		P_price_list_id
		P_global_procurement_flag
		P_from_organization_id
		P_currency_code
		X_transfer_price
		X_return_status
		X_msg_count
		X_msg_data
   Description: This API calculates the transfer price for a
		configuration item by rolling up the transfer
		prices of its optional components.

*****************************************************************************/
Procedure Cto_Transfer_Price (
	p_config_item_id IN NUMBER,
	p_selling_oper_unit IN NUMBER,
	p_shipping_oper_unit IN NUMBER,
	p_transaction_uom IN VARCHAR2,
	p_transaction_id IN NUMBER,
	p_price_list_id IN NUMBER,
	p_global_procurement_flag IN VARCHAR2,
	p_from_organization_id IN NUMBER DEFAULT NULL,
	p_currency_code IN VARCHAR2 DEFAULT NULL,
	x_transfer_price OUT NOCOPY NUMBER,
	x_currency_code  OUT NOCOPY varchar2,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2);

END CTO_TRANSFER_PRICE_PK;

 

/
