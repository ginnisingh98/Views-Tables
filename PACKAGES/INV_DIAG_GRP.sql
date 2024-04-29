--------------------------------------------------------
--  DDL for Package INV_DIAG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_GRP" AUTHID CURRENT_USER AS
/* $Header: INVDGTPS.pls 120.0.12000000.1 2007/06/22 00:50:45 musinha noship $ */
 TYPE item_info_rec_type is RECORD
 (inventory_item_id         number
 ,org_id                    number
 ,serial_number_control_code number
 ,lot_control_code           number
 ,location_control_code      number
 ,revision_qty_control_code  number
 );

 TYPE item_tbl_type is table of  item_info_rec_type INDEX BY BINARY_INTEGER;
 g_inv_diag_item_tbl 	item_tbl_type;

 TYPE order_info_rec_type is RECORD
 (sales_order_id	number);

 TYPE order_info_tbl_type is table of  order_info_rec_type INDEX BY BINARY_INTEGER;
 g_inv_diag_oe_tbl 	order_info_tbl_type;

 g_org_id number;

 g_grp_name varchar2(50):='';

 g_max_row number:=2000;

 FUNCTION CHECK_AVAIL(p_Inventory_item_id Number
                     ,p_Organization_id  Number
                     ,p_revision   Varchar2
                     ,p_Subinventory_code Varchar2
                     ,p_locator_id        Number
                     ) return NUMBER;
 FUNCTION CHECK_ONHAND(p_Inventory_item_id Number
                     ,p_Organization_id  Number
                     ,p_revision   Varchar2
                     ,p_Subinventory_code Varchar2
                     ,p_locator_id        Number
                     ) return NUMBER;
 FUNCTION check_responsibility (p_responsibility_name in FND_RESPONSIBILITY_TL.Responsibility_Name%type) return BOOLEAN;

end;

 

/
