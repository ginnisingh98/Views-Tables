--------------------------------------------------------
--  DDL for Package PV_SEED_DERIVED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_SEED_DERIVED_PKG" AUTHID CURRENT_USER as
/* $Header: pvdervds.pls 115.0 2003/11/06 02:17:33 dhii noship $ */

procedure last_order_date(partner_id number, x_last_order_date out nocopy jtf_varchar2_table_4000);
procedure prod_bought_last_yr(partner_id number, x_inventory_item out nocopy jtf_varchar2_table_4000);
procedure prod_sold_last_yr(partner_id number, x_inventory_item out nocopy jtf_varchar2_table_4000);
end;

 

/
