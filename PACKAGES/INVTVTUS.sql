--------------------------------------------------------
--  DDL for Package INVTVTUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVTVTUS" AUTHID CURRENT_USER as
/* $Header: INVTVTUS.pls 115.6 2002/07/12 19:01:25 ssia ship $ */

 procedure item_only_summaries (
	sessionid number,
	orgid mtl_parameters.organization_id%TYPE,
	orgloctype number,
	invid mtl_system_items.inventory_item_id%TYPE,
	rev mtl_item_revisions.revision%TYPE,
	uom mtl_system_items.primary_uom_code%TYPE,
	puom mtl_system_items.primary_uom_code%TYPE,
	sdate mtl_material_transactions.transaction_date%TYPE,
	edate mtl_material_transactions.transaction_date%TYPE,
	cg_id mtl_secondary_inventories.default_cost_group_id%TYPE);

 procedure sub_only_summaries (
	sessionid number,
	orgid mtl_parameters.organization_id%TYPE,
	sub mtl_secondary_inventories.secondary_inventory_name%TYPE,
	locid mtl_item_locations.inventory_location_id%TYPE,
	catsetid mtl_category_sets.category_set_id%TYPE,
	catid mtl_categories.category_id%TYPE,
	sdate mtl_material_transactions.transaction_date%TYPE,
	edate mtl_material_transactions.transaction_date%TYPE,
	cg_id mtl_secondary_inventories.default_cost_group_id%TYPE);

 procedure both_summaries (
	sessionid number,
	orgid mtl_parameters.organization_id%TYPE,
	invid mtl_system_items.inventory_item_id%TYPE,
	rev mtl_item_revisions.revision%TYPE,
	uom mtl_system_items.primary_uom_code%TYPE,
	puom mtl_system_items.primary_uom_code%TYPE,
	sub mtl_secondary_inventories.secondary_inventory_name%TYPE,
	locid mtl_item_locations.inventory_location_id%TYPE,
	sdate mtl_material_transactions.transaction_date%TYPE,
	edate mtl_material_transactions.transaction_date%TYPE,
	cg_id mtl_secondary_inventories.default_cost_group_id%TYPE);

/* procedure cost_group_summaries (
	sessionid number,
	orgid mtl_parameters.organization_id%TYPE,
	orgloctype NUMBER,
	cost_group_id mtl_secondary_inventories.default_cost_group_id%TYPE,
	sdate mtl_material_transactions.transaction_date%TYPE,
	edate mtl_material_transactions.transaction_date%TYPE);

   procedure sub_cost_group_summaries(
	sessionid NUMBER,
	orgid mtl_parameters.organization_id%TYPE,
	sub mtl_secondary_inventories.secondary_inventory_name%TYPE,
	cost_group_id mtl_secondary_inventories.default_cost_group_id%TYPE,
	sdate mtl_material_transactions.transaction_date%TYPE,
	edate mtl_material_transactions.transaction_date%TYPE);*/
end INVTVTUS;

 

/
