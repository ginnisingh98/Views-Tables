--------------------------------------------------------
--  DDL for Package IBE_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_SEARCH_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVCSKS.pls 120.0.12010000.2 2014/06/02 10:34:02 amaheshw ship $ */

procedure Item_Category_Inserted(
new_category_id       number,
new_category_set_id   number,
new_inventory_item_id number,
new_organization_id   number);

procedure Item_Category_Deleted(
old_category_id number,
old_category_set_id number,
old_inventory_item_id number,
old_organization_id number);

procedure Item_Category_Updated(
old_category_id number,new_category_id number,
old_category_set_id number,new_category_set_id number,
old_inventory_item_id number,new_inventory_item_id number,
old_organization_id   number,new_organization_id   number);

procedure Item_Deleted(
old_inventory_item_id number,
old_organization_id number);

procedure Item_Updated(
old_inventory_item_id number,
old_organization_id   number,
old_web_status        varchar2,
new_web_status        varchar2);


procedure ItemTL_Deleted(
old_inventory_item_id number,
old_organization_id   number,
old_language          varchar2);


procedure ItemTL_Updated(
old_inventory_item_id number,
old_organization_id number,
old_language varchar2,
new_language varchar2,
new_description varchar2,
new_long_description varchar2);



procedure ItemTL_Inserted(
new_inventory_item_id number,
new_organization_id number,
new_language varchar2,
new_description varchar2,
new_long_description varchar2 );

end;

/
