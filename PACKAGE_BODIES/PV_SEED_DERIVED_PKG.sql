--------------------------------------------------------
--  DDL for Package Body PV_SEED_DERIVED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_SEED_DERIVED_PKG" as
/* $Header: pvdervdb.pls 115.0 2003/11/06 02:17:02 dhii noship $ */

procedure last_order_date(partner_id number, x_last_order_date out nocopy jtf_varchar2_table_4000)
is

   cursor lc_get_date (pc_partner_id number) is
   select to_char(aa.ordered_date,'yyyymmddhh24miss')
   from oe_order_headers_all aa, hz_cust_accounts b, pv_partner_profiles c
   where c.partner_id = pc_partner_id
   and c.partner_party_id = b.party_id
   and b.cust_account_id = aa.sold_to_org_id
   order by aa.ordered_date desc;

   l_date varchar2(30);
   lc_date_tbl jtf_varchar2_table_4000 := jtf_varchar2_table_4000();

begin
    open  lc_get_date(pc_partner_id => partner_id);
    fetch lc_get_date into l_date;
    close lc_get_date;
    if l_date is not null then
       lc_date_tbl.extend;
       lc_date_tbl(1) := l_date;
       x_last_order_date := lc_date_tbl;
    end if;
end;

procedure prod_bought_last_yr(partner_id number, x_inventory_item out nocopy jtf_varchar2_table_4000)
is

   cursor lc_prod_bought (pc_partner_id number) is
   select distinct a.inventory_item_id
   from oe_order_lines_all a, oe_order_headers_all aa, hz_cust_accounts b, pv_partner_profiles c
   where c.partner_id = pc_partner_id
   and c.partner_party_id = b.party_id and b.cust_account_id = aa.invoice_to_org_id
   and aa.ordered_date > add_months(sysdate, -12)
   and aa.header_id = a.header_id
   and a.flow_status_code = 'CLOSED'
   and a.actual_shipment_date is not null and a.line_category_code = 'ORDER'
   and a.cancelled_flag = 'N';

   l_items_tbl jtf_varchar2_table_4000 := jtf_varchar2_table_4000();

begin
    for lc_rec in lc_prod_bought(pc_partner_id => partner_id)
    loop
       l_items_tbl.extend;
       l_items_tbl(1) := lc_rec.inventory_item_id;
    end loop;
    x_inventory_item := l_items_tbl;
end;


procedure prod_sold_last_yr(partner_id number, x_inventory_item out nocopy jtf_varchar2_table_4000)
is

   cursor lc_prod_sold (pc_partner_id number) is
   select distinct a.inventory_item_id
   from ozf_sales_transactions_all a, hz_cust_accounts b, pv_partner_profiles c
   where c.partner_id = pc_partner_id
   and c.partner_party_id = b.party_id
   and b.cust_account_id = a.SOLD_FROM_CUST_ACCOUNT_ID
   and a.transfer_type = 'S'
   and a.transaction_date > add_months(sysdate, -12);

   l_items_tbl jtf_varchar2_table_4000 := jtf_varchar2_table_4000();

begin
    for lc_rec in lc_prod_sold(pc_partner_id => partner_id)
    loop
       l_items_tbl.extend;
       l_items_tbl(1) := lc_rec.inventory_item_id;
    end loop;
    x_inventory_item := l_items_tbl;
end;


end;

/
