--------------------------------------------------------
--  DDL for Package EAM_COPY_BOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_COPY_BOM_PKG" AUTHID CURRENT_USER as
/* $Header: EAMCPBMS.pls 115.0 2003/12/17 15:15:22 cboppana noship $ */

/*
  Record type for materials in the asset bom
--  component_item_id  Inventory Item Id
--  description        Material Description
--  component_quantity quantity
--  uom                Material's unit of measure
--  wip_supply_type    Supply Type
*/

TYPE t_bom_record IS RECORD (
  component_item_id	NUMBER,
  description		VARCHAR2(240),
  component_quantity	NUMBER,
  uom			VARCHAR2(3),
  wip_supply_type	NUMBER
);

/*
   Record Type for materials in workorder requirements
--  component_item              Item Name
--  component_item_id           Inventory Item Id
--  operation_sequence_number   Operation in the workorder
--  quantity_per_assembly       Quantity
--  wip_supply_type             Supply Type
--  supply_subinventory         Sub-inventory Name
--  supply_locator_id           Locator Id
--  supply_locator_name         Locator Name
*/
TYPE t_component_record IS RECORD (
  component_item	VARCHAR2(81),
  component_item_id	NUMBER,
  operation_sequence_number	NUMBER,
  quantity_per_assembly	NUMBER,
  wip_supply_type	NUMBER,
  supply_subinventory	VARCHAR2(30),
  supply_locator_id	NUMBER,
  supply_locator_name	VARCHAR2(81)
);

--Table type for bom materials
TYPE t_bom_table IS TABLE OF t_bom_record
  INDEX BY BINARY_INTEGER;
--Table type form  material requirements
TYPE t_component_table IS TABLE OF t_component_record
  INDEX BY BINARY_INTEGER;

/*
  Procedure to copy materials from  workorder to bom
--  p_organization_id   Organization Id
--  p_organization_code Organization Code
--  p_asset_number      Asset Number
--  p_asset_group_id    Inventory Item  Id
--  p_component_table   Table of workorder materials
--  x_error_code        0   success
                        1   some of components are already in the asset bom
                        2   error in the bom api
*/
PROCEDURE copy_to_bom(
		p_organization_id	IN	NUMBER,
		p_organization_code	IN	VARCHAR2,
		p_asset_number		IN	VARCHAR2,
		p_asset_group_id	IN	NUMBER,
		p_component_table	IN	t_component_table,
                x_error_code		OUT NOCOPY	NUMBER);


/*
   Procedure to copy materials from the asset bom to workorder
-- p_organization_id      Organization Id
-- p_wip_entity_id        Wip Entity Id
-- p_operation_seq_num    Operation to which materials are to be copied
-- p_department_id        Department
-- p_bom_table            Table of bom materials
-- x_error_code           S    success
                          U    error
                          E    error
*/
PROCEDURE retrieve_asset_bom(
		p_organization_id	IN 	NUMBER,
		p_wip_entity_id         IN      NUMBER,
                p_operation_seq_num     IN      NUMBER,
                p_department_id         IN      NUMBER,
 		p_bom_table		IN 	t_bom_table,
                x_error_code		OUT NOCOPY	VARCHAR2);

END EAM_COPY_BOM_PKG;

 

/
