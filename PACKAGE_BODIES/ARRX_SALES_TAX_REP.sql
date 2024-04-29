--------------------------------------------------------
--  DDL for Package Body ARRX_SALES_TAX_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_SALES_TAX_REP" as
/* $Header: ARRXSTB.pls 115.7 2002/11/15 03:13:08 anukumar ship $ */

PROCEDURE INSERT_SALES_TAX_REPORT   (
	chart_of_accounts_id	in	number,
	trx_date_low		in	date,
	trx_date_high		in	date,
	gl_date_low		in	date,
	gl_date_high		in	date,
	state_low 		in	varchar2,
	state_high		in	varchar2,
	currency_low		in	varchar2,
	currency_high		in	varchar2,
	exemption_status	in 	varchar2,
	lp_gltax_where		in	varchar2,
	where_gl_flex 		in	varchar2,
	show_deposit_children	in	varchar2,
	detail_level 		in	varchar2,
	posted_status 		in	varchar2,
	show_cms_adjs_outside_date in	varchar2,
        request_id 		in	number,
    	user_id 		in	number,
    	mesg 			out NOCOPY	varchar2,
    	success 		out NOCOPY	boolean)   is

 h_sob_id NUMBER;
 h_cnt_lines NUMBER;
 h_taxable_amount NUMBER;
 h_exemption_amount NUMBER;
 h_exemption_amount_trx_line NUMBER;
 cnt_lines NUMBER;
 cnt_tax_lines NUMBER;
 h_trx_line_id NUMBER;
 h_exemption_amount_line NUMBER;
 h_request_id NUMBER;
 h_login_id NUMBER;
 in_mesg  VARCHAR2(50);
 h_trx_id NUMBER;
 h_currency VARCHAR2(15);
 h_trx_number VARCHAR2(20);
 h_line_trx_id NUMBER;
 h_line_number NUMBER;
 h_description VARCHAR2(240);
 h_amount NUMBER;
 h_sob_name VARCHAR2(30);
 h_state_low VARCHAR2(60);
 h_state_high VARCHAR2(60);
 h_base_currency VARCHAR2(15);
 h_inv_line_amount_abs	number;
 h_inv_freight_amount_abs number;
 h_inv_tax_amount_abs number;
 h_inv_line_lines_count	number;
 h_inv_tax_lines_count	number;
 h_inv_freight_lines_count number;
 h_line_amount number;
 h_line_amount_for_exemption number;
 h_tax_amount number;
 h_so_organization_id NUMBER;
 h_inventory_item VARCHAR2(800);
 h_item_description VARCHAR2(240);
 h_total_lines_amount NUMBER;
 h_total_tax_amount NUMBER;
 h_exchange_rate_type VARCHAR2(30);
 c_precision NUMBER;
 c_mau NUMBER;
 h_cnt_tax_lines NUMBER;
 c INTEGER;  -- cursor handler
 gl_posted_status VARCHAR2(500);
 gl_posted_status_adj VARCHAR2(500);
 trx_date_range VARCHAR2(500);
 trx_date_range_adj VARCHAR2(500);
 where_exemption_status VARCHAR2(500);
 where_currency VARCHAR2(500);
 where_trx_flex VARCHAR2(2000);
 where_adj_flex VARCHAR2(2000);
 h_exemption_status VARCHAR2(30);
 h_trx_date_low DATE;
 h_trx_date_high DATE;
 trx_date_low_1 DATE;
 trx_date_low_2 DATE;
 trx_date_high_1 DATE;
 trx_date_high_2 DATE;
 h_gl_date_low DATE;
 h_gl_date_high DATE;
 gl_date_low_1 DATE;
 gl_date_low_2 DATE;
 gl_date_high_1 DATE;
 gl_date_high_2 DATE;
 execute_feedback INTEGER; -- value not needed
 select_statement VARCHAR2(30000);
 select_trx_cols VARCHAR2(5000);
 select_trx_from VARCHAR2(1000);
 select_trx_where VARCHAR2(5000);
 select_adj_cols VARCHAR2(5000);
 select_adj_from VARCHAR2(1000);
 select_adj_where VARCHAR2(5000);
 union_d VARCHAR2(10);
-- local 'into' variables
 c_tax_reference VARCHAR2(50);
 c_sic_code VARCHAR2(30);
 c_tax_code VARCHAR2(50);
 c_fob_point VARCHAR2(30);
 c_currency VARCHAR2(15);
 c_ship_to_customer_id NUMBER;
 c_ship_to_site_use_id NUMBER;
 c_ship_to_cust_name VARCHAR2(50);
 c_ship_to_cust_number VARCHAR2(30);
 c_ship_to_customer_type VARCHAR2(80);
 c_ship_to_address1 VARCHAR2(240);
 c_ship_to_address2 VARCHAR2(240);
 c_ship_to_address3 VARCHAR2(240);
 c_ship_to_address4 VARCHAR2(240);
 c_ship_to_state VARCHAR2(60);
 c_ship_to_county VARCHAR2(60);
 c_ship_to_city VARCHAR2(60);
 c_ship_to_postal_code VARCHAR2(60);
 c_ship_to_province VARCHAR2(60);
 c_bill_to_customer_id NUMBER;
 c_bill_to_site_use_id NUMBER;
 c_bill_to_cust_name VARCHAR2(50);
 c_bill_to_cust_number VARCHAR2(30);
 c_bill_to_customer_type VARCHAR2(80);
 c_bill_to_address1 VARCHAR2(240);
 c_bill_to_address2 VARCHAR2(240);
 c_bill_to_address3 VARCHAR2(240);
 c_bill_to_address4 VARCHAR2(240);
 c_bill_to_state VARCHAR2(60);
 c_bill_to_county VARCHAR2(60);
 c_bill_to_city VARCHAR2(60);
 c_bill_to_postal_code VARCHAR2(60);
 c_bill_to_province VARCHAR2(60);
 c_sold_to_site_use_id NUMBER;
 c_sold_to_cust_name VARCHAR2(50);
 c_sold_to_cust_number VARCHAR2(30);
 c_sold_to_customer_id NUMBER;
 c_sold_to_customer_type VARCHAR2(80);
 c_sold_to_address1 VARCHAR2(240);
 c_sold_to_address2 VARCHAR2(240);
 c_sold_to_address3 VARCHAR2(240);
 c_sold_to_address4 VARCHAR2(240);
 c_sold_to_state VARCHAR2(60);
 c_sold_to_county VARCHAR2(60);
 c_sold_to_city VARCHAR2(60);
 c_sold_to_postal_code VARCHAR2(60);
 c_sold_to_province VARCHAR2(60);
 c_inv_number VARCHAR2(20);
 c_inv_type VARCHAR2(80);
 c_inv_type_code VARCHAR2(20);
 c_inv_type_code_order VARCHAR2(20);
 c_adj_number VARCHAR2(20);
 c_adj_line_amount NUMBER;
 c_adj_tax_amount NUMBER;
 c_adj_freight_amount NUMBER;
 c_adj_type VARCHAR2(30); --check the type!
 c_adjustment_id NUMBER;
 c_inv_date DATE;
 c_location VARCHAR2(40);
 c_cust_tax_code VARCHAR2(50);
 c_type_flag VARCHAR2(20);
 c_inv_cust_trx_id NUMBER;
 c_cust_trx_id NUMBER;
 c_batch_source_id NUMBER;
 c_trx_line_id NUMBER;
 c_line_number NUMBER;
 c_description VARCHAR2(240);
 c_line_amount NUMBER;
 c_tax_line_number NUMBER;
 c_tax_cust_trx_line_id NUMBER;
 c_tax_rate NUMBER;
 c_vat_code VARCHAR2(50);
 c_tax_vendor_return_code VARCHAR2(30);
 c_vat_code_type VARCHAR2(30);
 c_exempt_number VARCHAR2(80);
 c_exempt_reason VARCHAR2(80);
 c_exempt_percent NUMBER;
 c_tax_amount NUMBER;
 c_tax_except_percent NUMBER;
 c_tax_authority_id NUMBER;
 c_tax_authority_zip_code VARCHAR2(60);
 c_sales_tax_id NUMBER;
 c_gltax_inrange_flag VARCHAR2(2);
 c_posted VARCHAR2(10);
 c_ship_date_actual DATE;
 c_waybill_number VARCHAR2(50);
 c_purchase_order VARCHAR2(50);
 c_purchase_order_revision VARCHAR2(50);
 c_exchange_rate_type VARCHAR2(50);
 c_exchange_rate_date DATE;
 c_exchange_rate NUMBER;
 c_ship_via VARCHAR2(30);
 c_uom_code VARCHAR2(3);
 c_quantity_invoiced NUMBER;
 c_unit_selling_price NUMBER;
 c_tax_precedence NUMBER;
 c_sales_order_source VARCHAR2(50);
 c_sales_order VARCHAR2(50);
 c_sales_order_revision NUMBER;
 c_sales_order_line NUMBER;
 c_sales_order_date DATE;
 c_comment VARCHAR2(80);
 c_trx_id NUMBER;
 c_inventory_item_id NUMBER;
 c_header_category VARCHAR2(30);
 c_header_attr1 VARCHAR2(30);
 c_header_attr2 VARCHAR2(30);
 c_header_attr3 VARCHAR2(30);
 c_header_attr4 VARCHAR2(30);
 c_header_attr5 VARCHAR2(30);
 c_header_attr6 VARCHAR2(30);
 c_header_attr7 VARCHAR2(30);
 c_header_attr8 VARCHAR2(30);
 c_header_attr9 VARCHAR2(30);
 c_header_attr10 VARCHAR2(30);
 c_header_attr11 VARCHAR2(30);
 c_header_attr12 VARCHAR2(30);
 c_header_attr13 VARCHAR2(30);
 c_header_attr14 VARCHAR2(30);
 c_header_attr15 VARCHAR2(30);
 c_line_category VARCHAR2(30);
 c_line_attr1 VARCHAR2(30);
 c_line_attr2 VARCHAR2(30);
 c_line_attr3 VARCHAR2(30);
 c_line_attr4 VARCHAR2(30);
 c_line_attr5 VARCHAR2(30);
 c_line_attr6 VARCHAR2(30);
 c_line_attr7 VARCHAR2(30);
 c_line_attr8 VARCHAR2(30);
 c_line_attr9 VARCHAR2(30);
 c_line_attr10 VARCHAR2(30);
 c_line_attr11 VARCHAR2(30);
 c_line_attr12 VARCHAR2(30);
 c_line_attr13 VARCHAR2(30);
 c_line_attr14 VARCHAR2(30);
 c_line_attr15 VARCHAR2(30);
 c_type_name VARCHAR2(20);
 c_gl_flex VARCHAR2(1);
 c_counter NUMBER;

BEGIN
/* bug 2018415 replace fnd_profile call to arp_global.sysparam for SOB_ID
 h_sob_id := fnd_profile.value('GL_SET_OF_BKS_ID');
*/
 h_sob_id := arp_global.sysparam.set_of_books_id;

 -- OE/OM Change
 --
 -- h_so_organization_id := fnd_profile.value('SO_ORGANIZATION_ID');
 h_so_organization_id := oe_profile.value('SO_ORGANIZATION_ID');

if detail_level = 'RX_LINE' then
 select_trx_cols :=
  'SELECT trx.invoice_currency_code, party.tax_reference, decode(party.party_type, ''ORGANIZATION'', party.sic_code,NULL), trx.ship_date_actual, trx.fob_point, '||
     'decode(types.type,''CM'',nvl(othertrx.trx_number,''On Account''),trx.trx_number), lk.meaning, types.type, '||
     'decode( types.type, ''INV'', 10, ''DM'', 15, ''CM'', 20, 30), '||
     'decode( types.type, ''CM'', trx.trx_number, othertrx.trx_number), '||
     'to_number(null),to_number(null),to_number(null),to_char(null),'||
     'decode( types.type, ''CM'', nvl(othertrx.trx_date, trx.trx_date), trx.trx_date), '||
     'substrb(party.party_name,1,50), c.account_number, su.location, nvl(su.tax_code, c.tax_code), '||
     'decode( types.type, ''INV'', ''INVOICE'',''DM'', ''INVOICE'',''CREDIT MEMO''), '||
     'decode( types.type, ''CM'', nvl(othertrx.customer_trx_id,-1*trx.customer_trx_id),trx.customer_trx_id), '||
     'trx.customer_trx_id, trx.batch_source_id,0, line.customer_trx_line_id , '||
     'line.line_number, line.description, line.extended_amount, tax.line_number, '||
     'tax.customer_trx_line_id, tax.tax_rate, vat.tax_code, '||
     'line.tax_vendor_return_code, vat.tax_type, '||
     'nvl(ex.customer_exemption_number,line.tax_exempt_number), '||
     'nvl(lk2.meaning,lk3.meaning), '||
     'decode(lk2.meaning, null, decode( lk3.meaning, null, null, 100),ex.percent_exempt), '||
     'nvl(decode(tax.global_attribute_category, ''VERTEX'', '||
     'nvl(tax.global_attribute2, 0) + nvl(tax.global_attribute4, 0) + nvl(tax.global_attribute6, 0), '||
     '  ''AVP'', nvl(tax.global_attribute2, 0) + nvl(tax.global_attribute4, 0) + nvl(tax.global_attribute6, 0), '||
     'tax.extended_amount),0), '||
     ' tax.item_exception_rate_id, loc_assign.loc_id, '||
     'loc.postal_code, tax.sales_tax_id, '||
     'decode(gltax.code_combination_id, null, ''N'', ''Y''), '||
     'decode(dist.gl_posted_date, null, ''Unposted'', ''Posted''), '||
     'trx.ship_to_customer_id, trx.ship_to_site_use_id, trx.bill_to_customer_id, '||
     'trx.bill_to_site_use_id, trx.sold_to_customer_id, trx.sold_to_site_use_id, '||
     'trx.waybill_number, trx.purchase_order, trx.purchase_order_revision, '||
     'trx.exchange_rate_type, trx.exchange_date, trx.exchange_rate, trx.ship_via, '||
     'line.uom_code, line.quantity_invoiced, line.unit_selling_price, '||
     'line.tax_precedence, line.sales_order_source, line.sales_order, '||
     'line.sales_order_revision, line.sales_order_line, line.sales_order_date, '||
     'line.inventory_item_id, '||
     'trx.attribute_category, trx.attribute1, trx.attribute2, '||
     'trx.attribute3, trx.attribute4, trx.attribute5, '||
     'trx.attribute6, trx.attribute7, trx.attribute8, '||
     'trx.attribute9, trx.attribute10, trx.attribute11, '||
     'trx.attribute12, trx.attribute13, trx.attribute14, '||
     'trx.attribute15, '||
     'line.attribute_category, line.attribute1, line.attribute2, '||
     'line.attribute3, line.attribute4, line.attribute5, '||
     'line.attribute6, line.attribute7, line.attribute8, '||
     'line.attribute9, line.attribute10, line.attribute11, '||
     'line.attribute12, line.attribute13, line.attribute14, '||
     'line.attribute15, types.name ';

  select_trx_where :=
     'WHERE trx.previous_customer_trx_id = othertrx.customer_trx_id(+) '||
     'AND   nvl(trx.ship_to_site_use_id, trx.bill_to_site_use_id) = su.site_use_id '||
     'AND   su.cust_acct_site_id = acct_site.cust_acct_site_id '||
     'AND   c.party_id = party.party_id ' ||
     'AND   acct_site.party_site_id = party_site.party_site_id ' ||
     'AND   loc.location_id = party_site.location_id ' ||
     'AND   loc.location_id = loc_assign.location_id ' ||
     'AND   upper(loc.state) between :state_low_q and :state_high_q '||
     'AND   loc.country = ''US'' ' ||
     'AND   trx.cust_trx_type_id = types.cust_trx_type_id '||
     'AND   types.type = lk.lookup_code '||
     'AND   types.type in ( ''CM'', ''INV'', ''DM'' ) '||
     'AND   lk.lookup_type = ''INV/CM/ADJ'' '||
     'AND   cy.currency_code = trx.invoice_currency_code '||
     'AND   c.cust_account_id = trx.bill_to_customer_id '||
     'AND   dist.customer_trx_id = trx.customer_trx_id '||
     'AND   dist.account_class = ''REC'' '||
     'AND   trx.customer_trx_id = line.customer_trx_id '||
     'AND   line.customer_trx_line_id = tax.link_to_cust_trx_line_id(+) '||
     'AND   line.line_type = ''LINE'' '||
     'AND   tax.line_type(+) = ''TAX'' '||
     'AND   vat.vat_tax_id(+) = nvl(tax.vat_tax_id,-1) '||
     'AND   ex.tax_exemption_id(+) = nvl(tax.tax_exemption_id,-1) '||
     'AND   lk2.lookup_code(+) = ex.reason_code '||
     'AND   lk2.lookup_type(+) = ''TAX_REASON'' '||
     'AND   lk3.lookup_type(+) = ''TAX_REASON'' '||
     'AND   lk3.lookup_code(+) = line.tax_exempt_reason_code '||
     'AND   dist.gl_date between :gl_date_low_q and :gl_date_high_q '||
     'AND   dist.latest_rec_flag = ''Y'''||
     'AND   trx.complete_flag = ''Y'''||
     'AND   taxdist.customer_trx_line_id(+) = tax.customer_trx_line_id '||
     'AND   nvl(taxdist.code_combination_id,-1) = gltax.code_combination_id(+) ';

  select_adj_cols :=
    'SELECT trx.invoice_currency_code, party.tax_reference, decode(party.party_type, ''ORGANIZATION'',party.sic_code,NULL), trx.ship_date_actual, trx.fob_point, '||
       'trx.trx_number, ''Adjustment'', ''ADJ'', 30, adj.adjustment_number, '||
       'adj.line_adjusted, adj.tax_adjusted, adj.freight_adjusted, adj.type, adj.apply_date, '||
       'substrb(party.party_name,1,50), c.account_number,  su.location, nvl(su.tax_code, c.tax_code), '||
       '''ADJUSTMENT'', trx.customer_trx_id,  trx.customer_trx_id, trx.batch_source_id, '||
       'adj.adjustment_id, line.customer_trx_line_id, line.line_number, line.description,'||
       'line.extended_amount, tax.line_number, tax.customer_trx_line_id,tax.tax_rate,'||
       'vat.tax_code, tax.tax_vendor_return_code, vat.tax_type, '||
       'nvl(ex.customer_exemption_number,line.tax_exempt_number),'||
       'nvl(lk2.meaning,lk3.meaning), '||
       'decode(lk2.meaning, null,decode( lk3.meaning, null, null, 100), ex.percent_exempt),'||
       'nvl(tax.extended_amount,0), tax.item_exception_rate_id, loc_assign.location_id, '||
       'loc.postal_code, tax.sales_tax_id,''Y'','||
       'decode(adj.gl_posted_date, null, ''Unposted'', ''Posted'') ,'||
       'trx.ship_to_customer_id, trx.ship_to_site_use_id, trx.bill_to_customer_id, '||
       'trx.bill_to_site_use_id, trx.sold_to_customer_id, trx.sold_to_site_use_id, '||
       'trx.waybill_number, trx.purchase_order, trx.purchase_order_revision, '||
       'trx.exchange_rate_type, trx.exchange_date, trx.exchange_rate, trx.ship_via, '||
       'line.uom_code, line.quantity_invoiced, line.unit_selling_price, '||
       'line.tax_precedence, line.sales_order_source, line.sales_order, '||
       'line.sales_order_revision, line.sales_order_line, line.sales_order_date, '||
       'line.inventory_item_id, '||
       'trx.attribute_category, trx.attribute1, trx.attribute2, '||
       'trx.attribute3, trx.attribute4, trx.attribute5, '||
       'trx.attribute6, trx.attribute7, trx.attribute8, '||
       'trx.attribute9, trx.attribute10, trx.attribute11, '||
       'trx.attribute12, trx.attribute13, trx.attribute14, '||
       'trx.attribute15, '||
       'line.attribute_category, line.attribute1, line.attribute2, '||
       'line.attribute3, line.attribute4, line.attribute5, '||
       'line.attribute6, line.attribute7, line.attribute8, '||
       'line.attribute9, line.attribute10, line.attribute11, '||
       'line.attribute12, line.attribute13, line.attribute14, '||
       'line.attribute15, to_char(null) ';

  select_adj_where :=
    'WHERE trx.customer_trx_id = adj.customer_trx_id '||
    'AND   nvl(trx.ship_to_site_use_id, trx.bill_to_site_use_id) = su.site_use_id '||
    'AND   c.party_id = party.party_id ' ||
    'AND   acct_site.party_site_id = party_site.party_site_id ' ||
    'AND   loc.location_id = party_site.location_id ' ||
    'AND   loc.location_id = loc_assign.location_id ' ||
    'AND   upper(loc.state) between :state_low_q and :state_high_q '||
    'AND   loc.country = ''US'''||
    'AND   su.cust_acct_site_id = acct_site.cust_acct_site_id '||
    'AND   c.cust_account_id = trx.bill_to_customer_id '||
    'AND   trx.customer_trx_id = line.customer_trx_id '||
    'AND   line.customer_trx_line_id = tax.link_to_cust_trx_line_id(+) '||
    'AND   cy.currency_code = trx.invoice_currency_code '||
    'AND   line.line_type = ''LINE'''||
    'AND   tax.line_type(+) = ''TAX'''||
    'AND   vat.vat_tax_id(+) = nvl(tax.vat_tax_id,-1)'||
    'AND   ex.tax_exemption_id(+) = nvl(tax.tax_exemption_id,-1)'||
    'AND   lk2.lookup_code(+) = ex.reason_code '||
    'AND   lk2.lookup_type(+) = ''TAX_REASON'''||
    'AND   lk3.lookup_type(+) = ''TAX_REASON'''||
    'AND   lk3.lookup_code(+) = line.tax_exempt_reason_code '||
    'AND   adj.gl_date between :gl_date_low_q and :gl_date_high_q '||
    'AND   adj.code_combination_id = cc.code_combination_id '||
    'AND   cc.chart_of_accounts_id = :chart_of_accounts_id_q '||
    'AND   adj.chargeback_customer_trx_id is null '||
    'AND   adj.approved_by is not null' ;

else   -- Header level

select_trx_cols :=
  'SELECT distinct trx.invoice_currency_code, party.tax_reference, decode(party.party_type, ''ORGANIZATION'', party.sic_code, NULL), trx.ship_date_actual, trx.fob_point, '||
     'decode(types.type,''CM'',nvl(othertrx.trx_number,''On Account''),trx.trx_number), lk.meaning, types.type, '||
     'decode( types.type, ''INV'', 10, ''DM'', 15, ''CM'', 20, 30), '||
     'decode( types.type, ''CM'', trx.trx_number, othertrx.trx_number), '||
     'to_number(null),to_number(null),to_number(null),to_char(null),'||
     'decode( types.type, ''CM'', nvl(othertrx.trx_date, trx.trx_date), trx.trx_date), '||
     'substrb(party.party_name,1,50), c.account_number, su.location, nvl(su.tax_code, c.tax_code), '||
     'decode( types.type, ''INV'', ''INVOICE'',''DM'', ''INVOICE'',''CREDIT MEMO''), '||
     'decode( types.type, ''CM'', nvl(othertrx.customer_trx_id,-1*trx.customer_trx_id),trx.customer_trx_id), '||
     'trx.customer_trx_id, trx.batch_source_id,0, null , '||
     'null, null, '||
     'null,null,null,null, '||
     'null, null, null, '||
     'null, '|| -- tassa oli ex
     'null, '||
     'null, '||
     'null, null, loc_assign.location_id, '||
     'loc.postal_code, null, '||
     'null, '||
     'decode(dist.gl_posted_date, null, ''Unposted'', ''Posted''), '||
     'trx.ship_to_customer_id, trx.ship_to_site_use_id, trx.bill_to_customer_id, '||
     'trx.bill_to_site_use_id, trx.sold_to_customer_id, trx.sold_to_site_use_id, '||
     'trx.waybill_number, trx.purchase_order, trx.purchase_order_revision, '||
     'trx.exchange_rate_type, trx.exchange_date, trx.exchange_rate, trx.ship_via, '||
     'null,null,null, '||
     'null,null,null, '||
     'null,null,null,null, '||
     'trx.attribute_category, trx.attribute1, trx.attribute2, '||
     'trx.attribute3, trx.attribute4, trx.attribute5, '||
     'trx.attribute6, trx.attribute7, trx.attribute8, '||
     'trx.attribute9, trx.attribute10, trx.attribute11, '||
     'trx.attribute12, trx.attribute13, trx.attribute14, '||
     'trx.attribute15, '||
     'null,null,null,null,null,null,null,null,null,null, '||
     'null,null,null,null,null,null,types.name ';

 select_trx_where :=
     'WHERE trx.previous_customer_trx_id = othertrx.customer_trx_id(+) '||
     'AND   nvl(trx.ship_to_site_use_id, trx.bill_to_site_use_id) = su.site_use_id '||
     'AND   su.cust_acct_site_id = acct_site.cust_acct_site_id '||
     'AND   c.party_id = party.party_id ' ||
     'AND   acct_site.party_site_id = party_site.party_site_id ' ||
     'AND   loc.location_id = party_site.location_id ' ||
     'AND   loc.location_id = loc_assign.location_id ' ||
     'AND   upper(loc.state) between :state_low_q and :state_high_q '||
     'AND   loc.country = ''US'' ' ||
     'AND   trx.cust_trx_type_id = types.cust_trx_type_id '||
     'AND   types.type = lk.lookup_code '||
     'AND   types.type in ( ''CM'', ''INV'', ''DM'' ) '||
     'AND   lk.lookup_type = ''INV/CM/ADJ'' '||
     'AND   cy.currency_code = trx.invoice_currency_code '||
     'AND   c.cust_account_id = trx.bill_to_customer_id '||
     'AND   dist.customer_trx_id = trx.customer_trx_id '||
     'AND   dist.account_class = ''REC'' '||
     'AND   trx.customer_trx_id = line.customer_trx_id '||
     'AND   line.customer_trx_line_id = tax.link_to_cust_trx_line_id(+) '||
     'AND   line.line_type = ''LINE'' '||
     'AND   tax.line_type(+) = ''TAX'' '||
     'AND   vat.vat_tax_id(+) = nvl(tax.vat_tax_id,-1) '||
     'AND   ex.tax_exemption_id(+) = nvl(tax.tax_exemption_id,-1) '||
     'AND   lk2.lookup_code(+) = ex.reason_code '||
     'AND   lk2.lookup_type(+) = ''TAX_REASON'' '||
     'AND   lk3.lookup_type(+) = ''TAX_REASON'' '||
     'AND   lk3.lookup_code(+) = line.tax_exempt_reason_code '||
     'AND   dist.gl_date between :gl_date_low_q and :gl_date_high_q '||
     'AND   dist.latest_rec_flag = ''Y'''||
     'AND   trx.complete_flag = ''Y'''||
     'AND   taxdist.customer_trx_line_id(+) = tax.customer_trx_line_id '||
     'AND   nvl(taxdist.code_combination_id,-1) = gltax.code_combination_id(+) ';
  select_adj_cols :=
    'SELECT distinct trx.invoice_currency_code,party.tax_reference, decode(party.party_type,''ORGANIZATION'', party.sic_code,NULL), trx.ship_date_actual, trx.fob_point, '||
       'trx.trx_number, ''Adjustment'', ''ADJ'', '||
       '30, '||
       'adj.adjustment_number, '||
       'adj.line_adjusted, adj.tax_adjusted, adj.freight_adjusted, adj.type, '||
       'adj.apply_date, '||
       'substrb(party.party_name,1,50), c.account_number,  su.location, nvl(su.tax_code, c.tax_code), '||
       '''ADJUSTMENT'', '||
       'trx.customer_trx_id, '||
       'trx.customer_trx_id, trx.batch_source_id, adj.adjustment_id, null,'||
       'null, null, '||
       'null,null,null,null, '||
       'null, null, null, '||
       'null, '||  -- tassa oli ex
       'null, '||
       'null, '||
       'null, null, loc_assign.location_id, '||
       'loc.postal_code, null,''Y'', '||
       'decode(adj.gl_posted_date, null, ''Unposted'', ''Posted''), '||
       'trx.ship_to_customer_id, trx.ship_to_site_use_id, trx.bill_to_customer_id, '||
       'trx.bill_to_site_use_id, trx.sold_to_customer_id, trx.sold_to_site_use_id, '||
       'trx.waybill_number, trx.purchase_order, trx.purchase_order_revision, '||
       'trx.exchange_rate_type, trx.exchange_date, trx.exchange_rate, trx.ship_via, '||
       'null,null,null, '||
       'null,null,null, '||
       'null,null,null,null, '||
       'trx.attribute_category, trx.attribute1, trx.attribute2, '||
       'trx.attribute3, trx.attribute4, trx.attribute5, '||
       'trx.attribute6, trx.attribute7, trx.attribute8, '||
       'trx.attribute9, trx.attribute10, trx.attribute11, '||
       'trx.attribute12, trx.attribute13, trx.attribute14, '||
       'trx.attribute15, '||
       'null,null,null,null,null,null,null,null,null,null, '||
       'null,null,null,null,null,null,to_char(null) ';

 select_adj_where :=
    'WHERE trx.customer_trx_id = adj.customer_trx_id '||
    'AND   nvl(trx.ship_to_site_use_id, trx.bill_to_site_use_id) = su.site_use_id '||
    'AND   upper(loc.state) between :state_low_q and :state_high_q '||
    'AND   loc.country = ''US'''||
    'AND   su.cust_acct_site_id = acct_site.cust_acct_site_id '||
    'AND   c.party_id = party.party_id ' ||
    'AND   acct_site.party_site_id = party_site.party_site_id ' ||
    'AND   loc.location_id = party_site.location_id ' ||
    'AND   loc.location_id = loc_assign.location_id ' ||
    'AND   c.cust_account_id = trx.bill_to_customer_id '||
    'AND   trx.customer_trx_id = line.customer_trx_id '||
    'AND   line.customer_trx_line_id = tax.link_to_cust_trx_line_id(+) '||
    'AND   cy.currency_code = trx.invoice_currency_code '||
    'AND   line.line_type = ''LINE'''||
    'AND   tax.line_type(+) = ''TAX'''||
    'AND   vat.vat_tax_id(+) = nvl(tax.vat_tax_id,-1)'||
    'AND   ex.tax_exemption_id(+) = nvl(tax.tax_exemption_id,-1)'||
    'AND   lk2.lookup_code(+) = ex.reason_code '||
    'AND   lk2.lookup_type(+) = ''TAX_REASON'''||
    'AND   lk3.lookup_type(+) = ''TAX_REASON'''||
    'AND   lk3.lookup_code(+) = line.tax_exempt_reason_code '||
    'AND   adj.gl_date between :gl_date_low_q and :gl_date_high_q '||
    'AND   adj.code_combination_id = cc.code_combination_id '||
    'AND   cc.chart_of_accounts_id = :chart_of_accounts_id_q '||
    'AND   adj.chargeback_customer_trx_id is null '||
    'AND   adj.approved_by is not null' ;

end if;
  -- union
  union_d := ' UNION ';

  -- posted where clause
  if posted_status = 'POSTED' then
    	gl_posted_status := ' AND dist.gl_posted_date is not null';
        gl_posted_status_adj := ' AND adj.gl_posted_date is not null';
  elsif posted_status = 'UNPOSTED' then
	gl_posted_status := ' AND dist.gl_posted_date is null';
        gl_posted_status_adj := ' AND adj.gl_posted_date is null';
  else
	gl_posted_status := ' AND 1=1';
	gl_posted_status_adj := ' AND 1=1';
  end if;


  -- values for state parameters
  h_state_low := state_low;
  h_state_high := state_high;
  if state_low is null or state_high is null then
	select decode(state_low, null, min(location_segment_value), state_low),
	       decode(state_high, null, max(location_segment_value), state_high)
        into h_state_low, h_state_high
        from ar_location_values v, ar_system_parameters p
	where v.location_segment_qualifier = 'STATE'
	and v.location_structure_id = p.location_structure_id;
  end if;


  -- values for trx_dates
  h_trx_date_low := trx_date_low;
  h_trx_date_high := trx_date_high;

  if trx_date_low is null then
            select min(trx_date)
            into   trx_date_low_1
            from   ra_customer_trx;

	    select nvl(min(gl_date), trx_date_low_1)
	    into   trx_date_low_2
            from   ar_adjustments;

	    if trx_date_low_1 < trx_date_low_2
	       then h_trx_date_low := trx_date_low_1;
	    else h_trx_date_low := trx_date_low_2;
	    end if;
  end if;

  if trx_date_high is null then
            select max(trx_date)
            into   trx_date_high_1
            from   ra_customer_trx;

	    select nvl(max(gl_date), trx_date_high_1)
	    into   trx_date_high_2
            from   ar_adjustments;

	    if trx_date_high_1 > trx_date_high_2
	       then h_trx_date_high := trx_date_high_1;
	       else h_trx_date_high := trx_date_high_2;
	    end if;
  end if;

  -- values for gl dates
  h_gl_date_low := gl_date_low;
  h_gl_date_high := gl_date_high;
    if gl_date_low is null then
            select min(gl_date)
            into   gl_date_low_1
            from   ra_cust_trx_line_gl_dist;

  	    if trx_date_low_2 is null then
	            select nvl(min(gl_date), gl_date_low_1)
	            into   gl_date_low_2
                    from   ar_adjustments;
	    else gl_date_low_2 := trx_date_low_2;
            end if;

	    if gl_date_low_1 < gl_date_low_2
	       then h_gl_date_low := gl_date_low_1;
	       else h_gl_date_low := gl_date_low_2;
	    end if;
  end if;

  if gl_date_high is null then
            select max(gl_date)
            into   gl_date_high_1
            from   ra_cust_trx_line_gl_dist;

	    if trx_date_high_2 is null then
	            select nvl(max(gl_date), gl_date_high_1)
	            into   gl_date_high_2
                    from   ar_adjustments;
	    else gl_date_high_2 := trx_date_high_2;
            end if;

	    if gl_date_high_1 > gl_date_high_2
	       then h_gl_date_high := gl_date_high_1;
	       else h_gl_date_high := gl_date_high_2;
	    end if;

  end if;


  -- values for lp_cm_trx_date_join and lp_adj_trx_date_join
  if show_cms_adjs_outside_date = 'Y' then
  	trx_date_range := ' AND (  trx.trx_date between to_date( '''||
                           to_char(h_trx_date_low,'DD-MM-YYYY')||
			   ''',''DD-MM-YYYY'') AND to_date('''||
			   to_char(h_trx_date_high, 'DD-MM-YYYY')||
			   ''', ''DD-MM-YYYY'')
	       	           OR othertrx.trx_date between to_date( ''' ||
			   to_char(h_trx_date_low, 'DD-MM-YYYY') ||
			   ''', ''DD-MM-YYYY'') AND to_date( ''' ||
			   to_char(h_trx_date_high, 'DD-MM-YYYY') ||
			   ''', ''DD-MM-YYYY'')  )';
	trx_date_range_adj := ' AND trx.trx_date between to_date( '''||
                           to_char(h_trx_date_low,'DD-MM-YYYY')||
			   ''',''DD-MM-YYYY'') AND to_date('''||
			   to_char(h_trx_date_high, 'DD-MM-YYYY')||
			   ''', ''DD-MM-YYYY'')';

  else
  	trx_date_range := ' AND trx.trx_date between to_date( '''||
                           to_char(h_trx_date_low,'DD-MM-YYYY')||
			   ''',''DD-MM-YYYY'') AND to_date('''||
			   to_char(h_trx_date_high, 'DD-MM-YYYY')||
			   ''', ''DD-MM-YYYY'')';

	trx_date_range_adj := ' AND adj.apply_date between to_date( '''||
                           to_char(h_trx_date_low,'DD-MM-YYYY')||
			   ''',''DD-MM-YYYY'') AND to_date('''||
			   to_char(h_trx_date_high, 'DD-MM-YYYY')||
			   ''', ''DD-MM-YYYY'')';

  end if;

  -- value for exemption where clause
  if exemption_status is not null then
	where_exemption_status := ' AND ex.status = :exemption_status_q';
  end if;

  -- value for currency where clause
  if  currency_low is  null and currency_high is not null then
	where_currency := ' AND trx.invoice_currency_code <= :currency_high_q ';
  elsif currency_low is not null and currency_high is  null then
	where_currency := ' AND trx.invoice_currency_code >=  :currency_low_q ';
  elsif currency_low is not null and currency_high is not null then
        where_currency := ' AND trx.invoice_currency_code between :currency_low_q and :currency_high_q';
  else
	where_currency := ' AND 1=1';
  end if;


  -- value for accounting flexfield where clause
  if lp_gltax_where is null then
	where_trx_flex := ' AND 1=1';
  else
	where_trx_flex := ' AND '||lp_gltax_where;
  end if;

  if where_gl_flex is null then
	where_adj_flex := ' AND 1=1';
  else
	where_adj_flex := ' AND '||where_gl_flex;
  end if;

 -- from clause
    IF 	(  to_date(to_char(h_trx_date_high, 'DD-MM-YYYY'), 'DD-MM-YYYY')
  	-   to_date(to_char(h_trx_date_low, 'DD-MM-YYYY'), 'DD-MM-YYYY' ) )
   <
   	(  to_date(to_char(h_gl_date_high, 'DD-MM-YYYY'), 'DD-MM-YYYY')
  	-   to_date(to_char(h_gl_date_low, 'DD-MM-YYYY'), 'DD-MM-YYYY') )       THEN

 	select_trx_from :=
	'FROM  fnd_currencies cy, ra_cust_trx_types types, ar_lookups lk, hz_cust_accounts c, hz_parties party '||
        'ar_vat_tax vat, ra_tax_exemptions ex, ar_lookups lk2, ar_lookups lk3, '||
        'ra_customer_trx_lines line, ra_customer_trx_lines tax, hz_cust_acct_sites acct_site, '||
        'hz_party_sites party_site, hz_loc_assignments loc_assign, hz_locations loc, ' ||
        'hz_cust_site_uses su, ra_customer_trx othertrx, ra_cust_trx_line_gl_dist taxdist, '||
        'gl_code_combinations gltax, ra_cust_trx_line_gl_dist dist, '||
        'ra_customer_trx trx  ';

        select_adj_from :=
        'FROM gl_code_combinations cc, ar_adjustments adj, hz_cust_accounts c, hz_parties party,  ar_vat_tax vat, '||
        'ra_tax_exemptions ex, ar_lookups lk2, ar_lookups lk3, fnd_currencies cy, '||
        'ra_customer_trx_lines line, ra_customer_trx_lines tax, ra_customer_trx trx, '||
        'hz_cust_site_uses su, hz_cust_acct_sites acct_site, ' ||
        'hz_locations loc, hz_loc_assignments loc_assign, hz_party_sites party_site ';
     ELSE
         select_trx_from :=
        'FROM  fnd_currencies cy, ra_cust_trx_types types, ar_lookups lk, hz_cust_accounts c, hz_parties party, '||
        'ar_vat_tax vat, ra_tax_exemptions ex, ar_lookups lk2, ar_lookups lk3, '||
        'ra_customer_trx_lines line, ra_customer_trx_lines tax, ' ||
        ' hz_cust_acct_sites acct_site, hz_locations loc, hz_loc_assignments loc_assign, hz_party_sites party_site, '||
        'hz_cust_site_uses su, ra_customer_trx othertrx, ra_cust_trx_line_gl_dist taxdist, '||
        'gl_code_combinations gltax,  '||
        'ra_customer_trx trx,ra_cust_trx_line_gl_dist dist  ';

        select_adj_from :=
        'FROM  hz_cust_accounts c, hz_parties party, ar_vat_tax vat, '||
        'ra_tax_exemptions ex, ar_lookups lk2, ar_lookups lk3, fnd_currencies cy, '||
        'ra_customer_trx_lines line, ra_customer_trx_lines tax, ra_customer_trx trx, '||
        'hz_cust_site_uses su, hz_cust_acct_sites acct_site, hz_party_sites party_site, ' ||
        'hz_locations loc,  hz_loc_assignments loc_assign, gl_code_combinations cc, ar_adjustments adj ';
    END IF;

select_statement := 	select_trx_cols ||
			select_trx_from ||
			select_trx_where ||
			trx_date_range ||
			where_exemption_status ||
			where_currency ||
			where_trx_flex||
			gl_posted_status ||
			union_d ||
			select_adj_cols ||
			select_adj_from ||
			select_adj_where ||
			trx_date_range_adj ||
			where_exemption_status ||
			where_currency||
			where_adj_flex ||
			gl_posted_status_adj ;

  success := FALSE;
  h_request_id := request_id;
  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

  select name, currency_code into h_sob_name, h_base_currency
  from gl_sets_of_books
  where set_of_books_id = h_sob_id;

  -- open cursor
  c := DBMS_SQL.OPEN_CURSOR;
  -- parse cursor
  DBMS_SQL.PARSE
    (c,
     select_statement,
     DBMS_SQL.V7);

  -- values for bind variables
   DBMS_SQL.BIND_VARIABLE(c,'state_low_q', h_state_low);
   DBMS_SQL.BIND_VARIABLE(c,'state_high_q', h_state_high);
   DBMS_SQL.BIND_VARIABLE(c,'gl_date_low_q', h_gl_date_low);
   DBMS_SQL.BIND_VARIABLE(c,'gl_date_high_q', h_gl_date_high);
   DBMS_SQL.BIND_VARIABLE(c,'chart_of_accounts_id_q', chart_of_accounts_id);
   if exemption_status is not null then
	DBMS_SQL.BIND_VARIABLE(c,'exemption_status_q',exemption_status);
   end if;
   if currency_low is not null then
 	DBMS_SQL.BIND_VARIABLE(c,'currency_low_q',currency_low);
   end if;
   if currency_high is not null then
 	DBMS_SQL.BIND_VARIABLE(c,'currency_high_q',currency_high);
   end if;

   -- define the columns in SELECT

   DBMS_SQL.define_column(c,1, c_currency,15);
   DBMS_SQL.define_column(c,2, c_tax_reference,50);
   DBMS_SQL.define_column(c,3, c_sic_code,30);
   DBMS_SQL.define_column(c,4, c_ship_date_actual);
   DBMS_SQL.define_column(c,5, c_fob_point,30);
   DBMS_SQL.define_column(c,6, c_inv_number, 20);
   DBMS_SQL.define_column(c,7, c_inv_type, 80);
   DBMS_SQL.define_column(c,8, c_inv_type_code, 20);
   DBMS_SQL.define_column(c,9, c_inv_type_code_order, 20);
   DBMS_SQL.define_column(c,10, c_adj_number, 20);
   DBMS_SQL.define_column(c,11, c_adj_line_amount);
   DBMS_SQL.define_column(c,12, c_adj_tax_amount);
   DBMS_SQL.define_column(c,13, c_adj_freight_amount);
   DBMS_SQL.define_column(c,14, c_adj_type,30);
   DBMS_SQL.define_column(c,15, c_inv_date );
   DBMS_SQL.define_column(c,16, c_ship_to_cust_name, 50);
   DBMS_SQL.define_column(c,17, c_ship_to_cust_number, 30);
   DBMS_SQL.define_column(c,18, c_location, 40);
   DBMS_SQL.define_column(c,19, c_cust_tax_code, 50);
   DBMS_SQL.define_column(c,20, c_type_flag, 20);
   DBMS_SQL.define_column(c,21, c_inv_cust_trx_id );
   DBMS_SQL.define_column(c,22, c_cust_trx_id );
   DBMS_SQL.define_column(c,23, c_batch_source_id );
   DBMS_SQL.define_column(c,24, c_adjustment_id);
   DBMS_SQL.define_column(c,25, c_trx_line_id );
   DBMS_SQL.define_column(c,26, c_line_number );
   DBMS_SQL.define_column(c,27, c_description, 240);
   DBMS_SQL.define_column(c,28, c_line_amount);
   DBMS_SQL.define_column(c,29, c_tax_line_number);
   DBMS_SQL.define_column(c,30, c_tax_cust_trx_line_id);
   DBMS_SQL.define_column(c,31, c_tax_rate );
   DBMS_SQL.define_column(c,32, c_vat_code, 50);
   DBMS_SQL.define_column(c,33, c_tax_vendor_return_code, 30);
   DBMS_SQL.define_column(c,34, c_vat_code_type, 30);
   DBMS_SQL.define_column(c,35, c_exempt_number, 80);
   DBMS_SQL.define_column(c,36, c_exempt_reason, 80);
   DBMS_SQL.define_column(c,37, c_exempt_percent );
   DBMS_SQL.define_column(c,38, c_tax_amount);
   DBMS_SQL.define_column(c,39, c_tax_except_percent);
   DBMS_SQL.define_column(c,40, c_tax_authority_id );
   DBMS_SQL.define_column(c,41, c_tax_authority_zip_code, 60);
   DBMS_SQL.define_column(c,42, c_sales_tax_id );
   DBMS_SQL.define_column(c,43, c_gltax_inrange_flag,2);
   DBMS_SQL.define_column(c,44, c_posted,10);
   DBMS_SQL.define_column(c,45, c_ship_to_customer_id);
   DBMS_SQL.define_column(c,46, c_ship_to_site_use_id);
   DBMS_SQL.define_column(c,47, c_bill_to_customer_id);
   DBMS_SQL.define_column(c,48, c_bill_to_site_use_id);
   DBMS_SQL.define_column(c,49, c_sold_to_customer_id);
   DBMS_SQL.define_column(c,50, c_sold_to_site_use_id);
   DBMS_SQL.define_column(c,51,c_waybill_number,50);
   DBMS_SQL.define_column(c,52,c_purchase_order,50);
   DBMS_SQL.define_column(c,53,c_purchase_order_revision,50);
   DBMS_SQL.define_column(c,54,c_exchange_rate_type,50);
   DBMS_SQL.define_column(c,55,c_exchange_rate_date);
   DBMS_SQL.define_column(c,56,c_exchange_rate);
   DBMS_SQL.define_column(c,57,c_ship_via,30);
   DBMS_SQL.define_column(c,58,c_uom_code,3);
   DBMS_SQL.define_column(c,59,c_quantity_invoiced);
   DBMS_SQL.define_column(c,60,c_unit_selling_price);
   DBMS_SQL.define_column(c,61,c_tax_precedence);
   DBMS_SQL.define_column(c,62,c_sales_order_source,50);
   DBMS_SQL.define_column(c,63,c_sales_order,50);
   DBMS_SQL.define_column(c,64,c_sales_order_revision);
   DBMS_SQL.define_column(c,65,c_sales_order_line);
   DBMS_SQL.define_column(c,66,c_sales_order_date);
   DBMS_SQL.define_column(c,67,c_inventory_item_id);
   DBMS_SQL.define_column(c,68,c_header_category,150);
   DBMS_SQL.define_column(c,69,c_header_attr1,150);
   DBMS_SQL.define_column(c,70,c_header_attr2,150);
   DBMS_SQL.define_column(c,71,c_header_attr3,150);
   DBMS_SQL.define_column(c,72,c_header_attr4,150);
   DBMS_SQL.define_column(c,73,c_header_attr5,150);
   DBMS_SQL.define_column(c,74,c_header_attr6,150);
   DBMS_SQL.define_column(c,75,c_header_attr7,150);
   DBMS_SQL.define_column(c,76,c_header_attr8,150);
   DBMS_SQL.define_column(c,77,c_header_attr9,150);
   DBMS_SQL.define_column(c,78,c_header_attr10,150);
   DBMS_SQL.define_column(c,79,c_header_attr11,150);
   DBMS_SQL.define_column(c,80,c_header_attr12,150);
   DBMS_SQL.define_column(c,81,c_header_attr13,150);
   DBMS_SQL.define_column(c,82,c_header_attr14,150);
   DBMS_SQL.define_column(c,83,c_header_attr15,150);
   DBMS_SQL.define_column(c,84,c_line_category,150);
   DBMS_SQL.define_column(c,85,c_line_attr1,150);
   DBMS_SQL.define_column(c,86,c_line_attr2,150);
   DBMS_SQL.define_column(c,87,c_line_attr3,150);
   DBMS_SQL.define_column(c,88,c_line_attr4,150);
   DBMS_SQL.define_column(c,89,c_line_attr5,150);
   DBMS_SQL.define_column(c,90,c_line_attr6,150);
   DBMS_SQL.define_column(c,91,c_line_attr7,150);
   DBMS_SQL.define_column(c,92,c_line_attr8,150);
   DBMS_SQL.define_column(c,93,c_line_attr9,150);
   DBMS_SQL.define_column(c,94,c_line_attr10,150);
   DBMS_SQL.define_column(c,95,c_line_attr11,150);
   DBMS_SQL.define_column(c,96,c_line_attr12,150);
   DBMS_SQL.define_column(c,97,c_line_attr13,150);
   DBMS_SQL.define_column(c,98,c_line_attr14,150);
   DBMS_SQL.define_column(c,99,c_line_attr15,150);
   DBMS_SQL.define_column(c,100,c_type_name,20);


   -- execute the SQL
   execute_feedback := DBMS_SQL.execute(c);
   -- set counter
   c_counter := 0;
   -- fetch rows
   while DBMS_SQL.fetch_rows(c) > 0
   loop

   -- retrieve values from execution using COLUMN_VALUE
   DBMS_SQL.column_value(c,1, c_currency);
   DBMS_SQL.column_value(c,2, c_tax_reference);
   DBMS_SQL.column_value(c,3, c_sic_code);
   DBMS_SQL.column_value(c,4, c_ship_date_actual);
   DBMS_SQL.column_value(c,5, c_fob_point);
   DBMS_SQL.column_value(c,6, c_inv_number);
   DBMS_SQL.column_value(c,7, c_inv_type);
   DBMS_SQL.column_value(c,8, c_inv_type_code);
   DBMS_SQL.column_value(c,9, c_inv_type_code_order);
   DBMS_SQL.column_value(c,10, c_adj_number);
   DBMS_SQL.column_value(c,11, c_adj_line_amount);
   DBMS_SQL.column_value(c,12, c_adj_tax_amount);
   DBMS_SQL.column_value(c,13, c_adj_freight_amount);
   DBMS_SQL.column_value(c,14, c_adj_type);
   DBMS_SQL.column_value(c,15, c_inv_date );
   DBMS_SQL.column_value(c,16, c_ship_to_cust_name);
   DBMS_SQL.column_value(c,17, c_ship_to_cust_number);
   DBMS_SQL.column_value(c,18, c_location);
   DBMS_SQL.column_value(c,19, c_cust_tax_code);
   DBMS_SQL.column_value(c,20, c_type_flag);
   DBMS_SQL.column_value(c,21, c_inv_cust_trx_id );
   DBMS_SQL.column_value(c,22, c_cust_trx_id );
   DBMS_SQL.column_value(c,23, c_batch_source_id );
   DBMS_SQL.column_value(c,24, c_adjustment_id);
   DBMS_SQL.column_value(c,25, c_trx_line_id );
   DBMS_SQL.column_value(c,26, c_line_number );
   DBMS_SQL.column_value(c,27, c_description);
   DBMS_SQL.column_value(c,28, c_line_amount);
   DBMS_SQL.column_value(c,29, c_tax_line_number);
   DBMS_SQL.column_value(c,30, c_tax_cust_trx_line_id);
   DBMS_SQL.column_value(c,31, c_tax_rate );
   DBMS_SQL.column_value(c,32, c_vat_code);
   DBMS_SQL.column_value(c,33, c_tax_vendor_return_code);
   DBMS_SQL.column_value(c,34, c_vat_code_type);
   DBMS_SQL.column_value(c,35, c_exempt_number);
   DBMS_SQL.column_value(c,36, c_exempt_reason);
   DBMS_SQL.column_value(c,37, c_exempt_percent );
   DBMS_SQL.column_value(c,38, c_tax_amount);
   DBMS_SQL.column_value(c,39, c_tax_except_percent);
   DBMS_SQL.column_value(c,40, c_tax_authority_id );
   DBMS_SQL.column_value(c,41, c_tax_authority_zip_code);
   DBMS_SQL.column_value(c,42, c_sales_tax_id );
   DBMS_SQL.column_value(c,43, c_gltax_inrange_flag);
   DBMS_SQL.column_value(c,44, c_posted);
   DBMS_SQL.column_value(c,45, c_ship_to_customer_id);
   DBMS_SQL.column_value(c,46, c_ship_to_site_use_id);
   DBMS_SQL.column_value(c,47, c_bill_to_customer_id);
   DBMS_SQL.column_value(c,48, c_bill_to_site_use_id);
   DBMS_SQL.column_value(c,49, c_sold_to_customer_id);
   DBMS_SQL.column_value(c,50, c_sold_to_site_use_id);
   DBMS_SQL.column_value(c,51,c_waybill_number);
   DBMS_SQL.column_value(c,52,c_purchase_order);
   DBMS_SQL.column_value(c,53,c_purchase_order_revision);
   DBMS_SQL.column_value(c,54,c_exchange_rate_type);
   DBMS_SQL.column_value(c,55,c_exchange_rate_date);
   DBMS_SQL.column_value(c,56,c_exchange_rate);
   DBMS_SQL.column_value(c,57,c_ship_via);
   DBMS_SQL.column_value(c,58,c_uom_code);
   DBMS_SQL.column_value(c,59,c_quantity_invoiced);
   DBMS_SQL.column_value(c,60,c_unit_selling_price);
   DBMS_SQL.column_value(c,61,c_tax_precedence);
   DBMS_SQL.column_value(c,62,c_sales_order_source);
   DBMS_SQL.column_value(c,63,c_sales_order);
   DBMS_SQL.column_value(c,64,c_sales_order_revision);
   DBMS_SQL.column_value(c,65,c_sales_order_line);
   DBMS_SQL.column_value(c,66,c_sales_order_date);
   DBMS_SQL.column_value(c,67,c_inventory_item_id);
   DBMS_SQL.column_value(c,68,c_header_category);
   DBMS_SQL.column_value(c,69,c_header_attr1);
   DBMS_SQL.column_value(c,70,c_header_attr2);
   DBMS_SQL.column_value(c,71,c_header_attr3);
   DBMS_SQL.column_value(c,72,c_header_attr4);
   DBMS_SQL.column_value(c,73,c_header_attr5);
   DBMS_SQL.column_value(c,74,c_header_attr6);
   DBMS_SQL.column_value(c,75,c_header_attr7);
   DBMS_SQL.column_value(c,76,c_header_attr8);
   DBMS_SQL.column_value(c,77,c_header_attr9);
   DBMS_SQL.column_value(c,78,c_header_attr10);
   DBMS_SQL.column_value(c,79,c_header_attr11);
   DBMS_SQL.column_value(c,80,c_header_attr12);
   DBMS_SQL.column_value(c,81,c_header_attr13);
   DBMS_SQL.column_value(c,82,c_header_attr14);
   DBMS_SQL.column_value(c,83,c_header_attr15);
   DBMS_SQL.column_value(c,84,c_line_category);
   DBMS_SQL.column_value(c,85,c_line_attr1);
   DBMS_SQL.column_value(c,86,c_line_attr2);
   DBMS_SQL.column_value(c,87,c_line_attr3);
   DBMS_SQL.column_value(c,88,c_line_attr4);
   DBMS_SQL.column_value(c,89,c_line_attr5);
   DBMS_SQL.column_value(c,90,c_line_attr6);
   DBMS_SQL.column_value(c,91,c_line_attr7);
   DBMS_SQL.column_value(c,92,c_line_attr8);
   DBMS_SQL.column_value(c,93,c_line_attr9);
   DBMS_SQL.column_value(c,94,c_line_attr10);
   DBMS_SQL.column_value(c,95,c_line_attr11);
   DBMS_SQL.column_value(c,96,c_line_attr12);
   DBMS_SQL.column_value(c,97,c_line_attr13);
   DBMS_SQL.column_value(c,98,c_line_attr14);
   DBMS_SQL.column_value(c,99,c_line_attr15);
   DBMS_SQL.column_value(c,100,c_type_name);


  -- get customer information for ship-to, bill-to and sold-to
  -- first initialize the columns
  c_ship_to_cust_name := to_char(null);
  c_ship_to_cust_number := to_char(null);
  c_ship_to_customer_type := to_char(null);
  c_ship_to_address1 := to_char(null);
  c_ship_to_address2 := to_char(null);
  c_ship_to_address3 := to_char(null);
  c_ship_to_address4 := to_char(null);
  c_ship_to_city := to_char(null);
  c_ship_to_postal_code := to_char(null);
  c_ship_to_state := to_char(null);
  c_ship_to_province := to_char(null);
  c_ship_to_county := to_char(null);
  c_bill_to_cust_name := to_char(null);
  c_bill_to_cust_number := to_char(null);
  c_bill_to_customer_type := to_char(null);
  c_bill_to_address1 := to_char(null);
  c_bill_to_address2 := to_char(null);
  c_bill_to_address3 := to_char(null);
  c_bill_to_address4 := to_char(null);
  c_bill_to_city := to_char(null);
  c_bill_to_postal_code := to_char(null);
  c_bill_to_state := to_char(null);
  c_bill_to_province := to_char(null);
  c_bill_to_county := to_char(null);
  c_sold_to_cust_name := to_char(null);
  c_sold_to_cust_number := to_char(null);
  c_sold_to_customer_type := to_char(null);
  c_sold_to_address1 := to_char(null);
  c_sold_to_address2 := to_char(null);
  c_sold_to_address3 := to_char(null);
  c_sold_to_address4 := to_char(null);
  c_sold_to_city := to_char(null);
  c_sold_to_postal_code := to_char(null);
  c_sold_to_state := to_char(null);
  c_sold_to_province := to_char(null);
  c_sold_to_county := to_char(null);

  if c_ship_to_customer_id  is not null and c_ship_to_site_use_id is not null
  then
     ARRX_SALES_TAX_REP.GET_CUSTOMER_INFORMATION(
	fc_customer_id_in	=> c_ship_to_customer_id,
	fc_site_use_id	=> c_ship_to_site_use_id,
	fc_customer_trx_id => c_cust_trx_id,
	fc_customer_name	=> c_ship_to_cust_name,
	fc_customer_number	=> c_ship_to_cust_number,
	fc_customer_type => c_ship_to_customer_type,
	fc_address1 => c_ship_to_address1,
	fc_address2 => c_ship_to_address2,
	fc_address3 => c_ship_to_address3,
	fc_address4 => c_ship_to_address4,
	fc_city => c_ship_to_city,
	fc_zip_code => c_ship_to_postal_code,
	fc_state => c_ship_to_state,
	fc_province => c_ship_to_province,
	fc_county => c_ship_to_county);
   end if;
  if c_bill_to_customer_id  is not null and c_bill_to_site_use_id is not null
  then
     ARRX_SALES_TAX_REP.GET_CUSTOMER_INFORMATION(
	fc_customer_id_in	=> c_bill_to_customer_id,
	fc_site_use_id	=> c_bill_to_site_use_id,
	fc_customer_trx_id => c_cust_trx_id,
	fc_customer_name	=> c_bill_to_cust_name,
	fc_customer_number	=> c_bill_to_cust_number,
	fc_customer_type => c_bill_to_customer_type,
	fc_address1 => c_bill_to_address1,
	fc_address2 => c_bill_to_address2,
	fc_address3 => c_bill_to_address3,
	fc_address4 => c_bill_to_address4,
	fc_city => c_bill_to_city,
	fc_zip_code => c_bill_to_postal_code,
	fc_state => c_bill_to_state,
	fc_province => c_bill_to_province,
	fc_county => c_bill_to_county);
   end if;

  if c_sold_to_customer_id  is not null and c_sold_to_site_use_id is not null
  then
     ARRX_SALES_TAX_REP.GET_CUSTOMER_INFORMATION(
	fc_customer_id_in	=> c_sold_to_customer_id,
	fc_site_use_id	=> c_sold_to_site_use_id,
	fc_customer_trx_id => c_cust_trx_id,
	fc_customer_name	=> c_sold_to_cust_name,
	fc_customer_number	=> c_sold_to_cust_number,
	fc_customer_type => c_sold_to_customer_type,
	fc_address1 => c_sold_to_address1,
	fc_address2 => c_sold_to_address2,
	fc_address3 => c_sold_to_address3,
	fc_address4 => c_sold_to_address4,
	fc_city => c_sold_to_city,
	fc_zip_code => c_sold_to_postal_code,
	fc_state => c_sold_to_state,
	fc_province => c_sold_to_province,
	fc_county => c_sold_to_county);
   end if;

 -- get minimum accountable unit and mau for invoice currency
        ARRX_SALES_TAX_REP.GET_PRECISION_AND_MAU(
	fc_currency => c_currency,
	fc_precision => c_precision,
	fc_mau => c_mau);

 if detail_level = 'RX_LINE' then
   	ARRX_SALES_TAX_REP.FETCH_TRX_ABS_TOTALS(
	fc_cust_trx_id => c_cust_trx_id,
	fc_type_flag => c_type_flag,
	fc_inv_line_amount_abs => h_inv_line_amount_abs,
	fc_inv_freight_amount_abs => h_inv_freight_amount_abs,
	fc_inv_tax_amount_abs => h_inv_tax_amount_abs,
	fc_inv_line_lines_count => h_inv_line_lines_count,
	fc_inv_tax_lines_count => h_inv_tax_lines_count,
	fc_inv_freight_lines_count =>h_inv_freight_lines_count);

  	h_line_amount :=  LINE_AMOUNT_CALC (
	c_type_flag ,
	c_line_amount ,
	h_inv_line_lines_count,
	h_inv_line_amount_abs,
	c_adj_line_amount);
	h_line_amount := aol_round(h_line_amount, c_precision, c_mau);

   	h_tax_amount := TAX_AMOUNT_CALC (
	c_type_flag,
	c_tax_amount,
	h_inv_tax_lines_count,
	h_inv_tax_amount_abs,
	c_adj_line_amount,
	h_inv_line_lines_count,
	c_adj_tax_amount);
	h_tax_amount := aol_round(h_tax_amount, c_precision, c_mau);

	-- here we calculate the exempt amount;
	if c_exempt_percent is null and nvl(c_tax_rate,0) = 0 then
		c_exempt_percent := 100;
	end if;
	h_cnt_tax_lines := CNT_TAX_LINES_FOR_INV_LINE(c_trx_line_id);
        h_exemption_amount := EXEMPTION_AMOUNT_CALC_LINE(
	c_precision,
	c_mau,
	c_exempt_percent,
	h_line_amount,
	h_cnt_tax_lines);

	--here we calculate the taxable amount
	h_taxable_amount := TAXABLE_AMOUNT_CALC_LINE(
	c_precision,
	c_mau,
	h_exemption_amount,
	h_line_amount,
	h_cnt_tax_lines);

	-- we do not want to print the line amount for each tax amount lines, if
	-- there are more than one tax line per invoice line
	if NVL(c_tax_cust_trx_line_id,0) <> GET_MIN_TAX_LINE_ID(c_trx_line_id) then
		h_line_amount := to_number(null);
	end if;

 else
	 -- this is header level report, call procedure that calculates total lines and total tax amount for
	 -- line and adjustment transactions
 	SUM_ITEM_LINE_AMOUNT(
	fc_cust_trx_id => c_cust_trx_id,
	fc_type_flag => c_type_flag,
	fc_adj_line_amount => c_adj_line_amount,
	fc_adj_tax_amount => c_adj_tax_amount,
	fc_exemption_status => exemption_status,
	fc_line_total => h_total_lines_amount,
	fc_tax_total => h_total_tax_amount);
	h_total_lines_amount := aol_round(h_total_lines_amount,c_precision, c_mau);
	h_total_tax_amount := aol_round(h_total_tax_amount,c_precision, c_mau);


	-- following section is for finding out NOCOPY the exemption amount for a transaction
	--if c_type_flag <> 'ADJUSTMENT' then
	   h_exemption_amount := GET_EXEMPTION_AMT(c_cust_trx_id, c_precision, c_mau, c_type_flag);
	--else   -- this is adjustment and needs proper handling
	  -- h_exemption_amount := 0;
	--end if;
	h_exemption_amount := aol_round(h_exemption_amount, c_precision, c_mau);
	h_taxable_amount := h_total_lines_amount - h_exemption_amount;
	h_taxable_amount := aol_round(h_taxable_amount, c_precision, c_mau);
 end if;

   -- note, you call following function either from line or header level,
   -- for ADJUSTMENTS, there's not difference between two modes
   -- for rest these rules apply:
   -- c_trx_id will contain c_tax_cust_trx_line_id at line level.
   -- at header level c_trx_id will have c_cust_trx_id
   -- call this function after you called TAX/LINE_AMOUNT_CALC or SUM_ITEM_LINE_AMOUNT
   -- because you need h_tax_amount
   -- if user entered accounting flexfield range (lp_gltax_where is not 1=1 ) the report print
   -- all non/adjustoments transactions should have *** Out NOCOPY of Balance *** footnote
   if substr(lp_gltax_where,1,10) = 'GLTAX.SEGM' then
	c_gl_flex := 'Y';
   else
	c_gl_flex := 'N';
   end if;

   if detail_level = 'RX_LINE' then
	c_trx_id := nvl(c_tax_cust_trx_line_id, to_number(null));
   else
	c_trx_id := nvl(c_cust_trx_id,to_number(null));
   end if;
   c_comment := ARRX_SALES_TAX_REP.TRX_COMMENT_FLAG(c_type_flag, c_trx_id, detail_level,
		h_tax_amount, c_adj_line_amount, c_adj_freight_amount, c_adj_type,c_gl_flex);

   -- inventory item and and item description
   -- because invetory item does not exist for all rows, assigns null values first
   h_item_description := to_char(null);
   h_inventory_item := to_char(null);

   if detail_level = 'RX_LINE' and c_inventory_item_id is not null then
	h_item_description := ARRX_SALES_TAX_REP.GET_ITEM_DESCRIPTION(h_so_organization_id,c_inventory_item_id);
        h_inventory_item := ARRX_SALES_TAX_REP.GET_ITEM(h_so_organization_id,c_inventory_item_id);
   end if;

   h_exchange_rate_type := to_char(null);
   if c_exchange_rate_type is not null then
	h_exchange_rate_type := ARRX_SALES_TAX_REP.GET_CONVERSION_RATE_TYPE(c_exchange_rate_type);
   end if;

     -- ready for insert
     insert into ar_sales_tax_rep_itf
       (request_id, sob_name, base_currency, posting_status, ship_to_state,
	ship_to_county, ship_to_province, ship_to_city, ship_to_postal_code,
        ship_to_customer_name, ship_to_customer_number, ship_to_customer_type,ship_to_address1,
        ship_to_address2, ship_to_address3, ship_to_address4,
        bill_to_state,
	bill_to_county, bill_to_province, bill_to_city, bill_to_postal_code,
        bill_to_customer_name, bill_to_customer_number, bill_to_customer_type, bill_to_address1,
        bill_to_address2, bill_to_address3, bill_to_address4,
        sold_to_state,
	sold_to_county, sold_to_province, sold_to_city, sold_to_postal_code,
        sold_to_customer_name, sold_to_customer_number, sold_to_customer_type, sold_to_address1,
        sold_to_address2, sold_to_address3, sold_to_address4,
        invoice_number,class, adjustment_number, inv_or_adj_date,  line_number,
        description, line_amount, tax_line_number, sic_code, invoice_currency_code,
        tax_rate, tax_code, exempt_number, exempt_reason, tax_amount ,
        ship_date_actual, fob_point, tax_reference,
	waybill_number, purchase_order, purchase_order_revision, exchange_rate_type,
	exchange_date, exchange_rate, ship_via,  transaction_type,
 	uom, quantity_invoiced , unit_selling_price,
       	tax_precedence, sales_order_source, sales_order,
	sales_order_revision, sales_order_line, sales_order_date, footnote,
        inventory_item, item_description, total_lines_amount, total_tax_amount,
	exempt_amount,taxable_amount,
        HEADER_CATEGORY, HEADER_ATTRIBUTE1, HEADER_ATTRIBUTE2,
        HEADER_ATTRIBUTE3, HEADER_ATTRIBUTE4, HEADER_ATTRIBUTE5,
        HEADER_ATTRIBUTE6, HEADER_ATTRIBUTE7, HEADER_ATTRIBUTE8,
        HEADER_ATTRIBUTE9, HEADER_ATTRIBUTE10, HEADER_ATTRIBUTE11,
        HEADER_ATTRIBUTE12, HEADER_ATTRIBUTE13,
        HEADER_ATTRIBUTE14, HEADER_ATTRIBUTE15,
        LINE_CATEGORY, LINE_ATTRIBUTE1, LINE_ATTRIBUTE2,
        LINE_ATTRIBUTE3, LINE_ATTRIBUTE4, LINE_ATTRIBUTE5,
        LINE_ATTRIBUTE6, LINE_ATTRIBUTE7, LINE_ATTRIBUTE8,
        LINE_ATTRIBUTE9, LINE_ATTRIBUTE10, LINE_ATTRIBUTE11,
        LINE_ATTRIBUTE12, LINE_ATTRIBUTE13, LINE_ATTRIBUTE14,
        LINE_ATTRIBUTE15,
        last_updated_by,last_update_login, created_by, creation_date, last_update_date)
     values
       (h_request_id, h_sob_name, h_base_currency, c_posted, c_ship_to_state,
        c_ship_to_county, c_ship_to_province, c_ship_to_city, c_ship_to_postal_code,
        c_ship_to_cust_name, c_ship_to_cust_number, c_ship_to_customer_type, c_ship_to_address1,
        c_ship_to_address2, c_ship_to_address3, c_ship_to_address4,
        c_bill_to_state,
	c_bill_to_county, c_bill_to_province, c_bill_to_city, c_bill_to_postal_code,
        c_bill_to_cust_name, c_bill_to_cust_number, c_bill_to_customer_type, c_bill_to_address1,
        c_bill_to_address2, c_bill_to_address3, c_bill_to_address4,
        c_sold_to_state,
	c_sold_to_county, c_sold_to_province, c_sold_to_city, c_sold_to_postal_code,
        c_sold_to_cust_name, c_sold_to_cust_number, c_sold_to_customer_type, c_sold_to_address1,
        c_sold_to_address2, c_sold_to_address3, c_sold_to_address4,
        c_inv_number, c_inv_type,  c_adj_number, c_inv_date,
        c_line_number, c_description, h_line_amount, c_tax_line_number, c_sic_code, c_currency,
        c_tax_rate, c_vat_code, c_exempt_number, c_exempt_reason, h_tax_amount,
	c_ship_date_actual, c_fob_point, c_tax_reference,
	c_waybill_number, c_purchase_order, c_purchase_order_revision, h_exchange_rate_type,
	c_exchange_rate_date, c_exchange_rate, c_ship_via,  c_type_name,
 	c_uom_code, c_quantity_invoiced , c_unit_selling_price,
 	c_tax_precedence, c_sales_order_source, c_sales_order,
	c_sales_order_revision, c_sales_order_line, c_sales_order_date, c_comment,
        h_inventory_item, h_item_description, h_total_lines_amount, h_total_tax_amount,
	h_exemption_amount, h_taxable_amount,
        c_header_category, c_header_attr1,
        c_header_attr2, c_header_attr3, c_header_attr4,
        c_header_attr5, c_header_attr6, c_header_attr7,
        c_header_attr8, c_header_attr9, c_header_attr10,
        c_header_attr11, c_header_attr12, c_header_attr13,
        c_header_attr14, c_header_attr15, c_line_category,
        c_line_attr1, c_line_attr2, c_line_attr3,
        c_line_attr4, c_line_attr5, c_line_attr6,
        c_line_attr7, c_line_attr8, c_line_attr9,
        c_line_attr10, c_line_attr11, c_line_attr12,
        c_line_attr13, c_line_attr14, c_line_attr15,
        h_login_id, h_login_id, h_login_id, sysdate, sysdate);
	c_counter := c_counter + 1;
  end loop;

-- close cursor
   DBMS_SQL.close_cursor(c);

    success := TRUE;
    if c_counter = 0 then
	    ARRX_SALES_TAX_REP.WRITE_LOG(
		fc_which => 1,
		fc_text => 'No data found',
		fc_buffer => in_mesg);
    mesg := in_mesg;
    else
    	ARRX_SALES_TAX_REP.WRITE_LOG(
		fc_which => 1,
		fc_text => 'Concurrent request completed successfully, '||to_char(c_counter)||' row(s) inserted.',
		fc_buffer => in_mesg);
    	mesg := in_mesg;
   end if;


exception
  when no_data_found then
    ARRX_SALES_TAX_REP.WRITE_LOG(
		fc_which => 1,
		fc_text => 'No data found',
		fc_buffer => in_mesg);
    mesg := in_mesg;


  when others then
  if dbms_sql.is_open(c) then
	dbms_sql.close_cursor(c);
  end if;
  success := FALSE;
  ARRX_SALES_TAX_REP.WRITE_LOG(
		fc_which => 1,
		fc_text => 'Concurrent request ended with error',
		fc_buffer => in_mesg);
  mesg := in_mesg;
  raise;


end INSERT_SALES_TAX_REPORT;


PROCEDURE SALES_TAX_RPT   (
	chart_of_accounts_id	in	number,
	trx_date_low		in	date,
	trx_date_high		in	date,
	gl_date_low		in	date,
	gl_date_high		in	date,
	state_low 		in	varchar2,
	state_high		in	varchar2,
	currency_low		in	varchar2,
	currency_high		in	varchar2,
	exemption_status	in 	varchar2,
	lp_gltax_where		in	varchar2,
	where_gl_flex 		in	varchar2,
	show_deposit_children	in	varchar2,
	detail_level 		in	varchar2,
	posted_status 		in	varchar2,
	show_cms_adjs_outside_date in	varchar2,
        request_id 		in	number,
    	user_id 		in	number,
    	retcode 		out NOCOPY	number,
    	errbuf	 		out NOCOPY	varchar2) is

h_success boolean;

BEGIN

  ARRX_SALES_TAX_REP.insert_sales_tax_report (
	chart_of_accounts_id => chart_of_accounts_id,
	trx_date_low => trx_date_low,
	trx_date_high => trx_date_high,
	gl_date_low => gl_date_low,
	gl_date_high => gl_date_high,
	state_low => state_low,
	state_high => state_high,
	currency_low => currency_low,
	currency_high => currency_high,
	exemption_status => exemption_status,
	lp_gltax_where => lp_gltax_where,
	where_gl_flex => where_gl_flex,
	show_deposit_children => show_deposit_children,
	detail_level => detail_level,
	posted_status => posted_status,
	show_cms_adjs_outside_date => show_cms_adjs_outside_date,
        request_id => request_id,
    	user_id => user_id,
    	mesg => errbuf,
    	success => h_success);

  if (h_success) then
	retcode := 0;
  else
	retcode := 2;
  end if;

  commit;

END SALES_TAX_RPT;


PROCEDURE FETCH_TRX_ABS_TOTALS (
	fc_cust_trx_id			in	number,
	fc_type_flag			in	varchar2,
	fc_inv_line_amount_abs		out NOCOPY	number,
	fc_inv_freight_amount_abs 	out NOCOPY	number,
	fc_inv_tax_amount_abs		out NOCOPY	number,
	fc_inv_line_lines_count		out NOCOPY	number,
	fc_inv_tax_lines_count		out NOCOPY	number,
	fc_inv_freight_lines_count	out NOCOPY	number) is


h_abs_line  number;
h_abs_freight number;
h_abs_tax  number;
h_count_line number;
h_count_freight number;
h_count_tax number;



  cursor c_amts is
  select sum(abs(decode(l.line_type, 'LINE',    l.extended_amount, 0))),
         sum(abs(decode(l.line_type, 'TAX',     decode(l.global_attribute_category, 'VERTEX',
         nvl(l.global_attribute2, 0) + nvl(l.global_attribute4, 0) + nvl(l.global_attribute6, 0),
         'AVP', nvl(l.global_attribute2, 0) + nvl(l.global_attribute4, 0) + nvl(l.global_attribute6, 0),
         l.extended_amount), 0))),
         sum(abs(decode(l.line_type, 'FREIGHT', l.extended_amount, 0))),
         sum(decode(l.line_type, 'LINE', 1, 0)),
         sum(decode(l.line_type, 'TAX', 1, 0)),
         sum(decode(l.line_type, 'FREIGHT', 1, 0))
  from   ra_customer_trx_lines l
  where  customer_trx_id = fc_cust_trx_id ;

BEGIN
  if nvl(fc_type_flag, 'INVOICE') = 'ADJUSTMENT'
  then
  	open c_amts;
  	fetch c_amts
           into h_abs_line, h_abs_tax, h_abs_freight, h_count_line, h_count_tax, h_count_freight;
  	close c_amts;

  	fc_inv_line_amount_abs := h_abs_line;
  	fc_inv_freight_amount_abs := h_abs_freight;
  	fc_inv_tax_amount_abs := h_abs_tax;
  	fc_inv_line_lines_count := h_count_line;
  	fc_inv_tax_lines_count := h_count_tax;
  	fc_inv_freight_lines_count := h_count_freight;

  else
	fc_inv_line_amount_abs := 0;
  	fc_inv_freight_amount_abs := 0;
  	fc_inv_tax_amount_abs := 0;
  	fc_inv_line_lines_count := 0;
  	fc_inv_tax_lines_count := 0;
  	fc_inv_freight_lines_count := 0;
 end if;

exception
  when others then
  	raise;

END  FETCH_TRX_ABS_TOTALS;


FUNCTION LINE_AMOUNT_CALC (
	c_type_flag 		IN 	VARCHAR2,
	c_line_amount 		IN 	NUMBER,
	c_inv_line_lines_count 	IN 	NUMBER,
	c_inv_line_amount_abs 	IN 	NUMBER,
	c_adj_line_amount 	IN 	NUMBER)
	RETURN NUMBER is

calc_amount NUMBER;
total_adjust_amount ar_adjustments.line_adjusted%TYPE;
abs_total number;
count_lines number;
line_amount number;

BEGIN
  if nvl(c_type_flag, 'INVOICE') <> 'ADJUSTMENT'
	then 	calc_amount := c_line_amount;
  else

	count_lines := c_inv_line_lines_count;
	abs_total := c_inv_line_amount_abs;

	if nvl(count_lines,0) = 0
	  then
	       count_lines := 1;
	end if;

	line_amount := c_line_amount;

	if nvl(abs_total,0) = 0 -- The original invoice had *NO* Invoice amounts
 	  then
	      abs_total := count_lines;
	      line_amount := count_lines;
	end if;

	total_adjust_amount := c_adj_line_amount;

	calc_amount:=
		total_adjust_amount * ( abs(line_amount) / abs_total );

   end if;

return(calc_amount);

EXCEPTION
	WHEN NO_DATA_FOUND then
		return(to_number(null));
        WHEN OTHERS then
  	        raise;

END LINE_AMOUNT_CALC;


FUNCTION TAX_AMOUNT_CALC (
	c_type_flag 		IN 	VARCHAR2,
	c_tax_amount		IN	NUMBER,
	c_inv_tax_lines_count 	IN 	NUMBER,
	c_inv_tax_amount_abs 	IN 	NUMBER,
	c_adj_line_amount 	IN 	NUMBER,
	c_inv_line_lines_count	IN	NUMBER,
	c_adj_tax_amount	IN	NUMBER)
RETURN NUMBER is


calc_amount ra_customer_trx_lines.extended_amount%TYPE;
total_adjust_amount ar_adjustments.line_adjusted%TYPE;
count_lines number;
abs_total number;
tax_amount number;

BEGIN

  if c_type_flag <> 'ADJUSTMENT'
    then
	calc_amount := c_tax_amount;
  else
	count_lines := c_inv_tax_lines_count;
	abs_total := c_inv_tax_amount_abs;

	 --  If the original invoice has *NO* tax; then we must prorate the
	 --  adjustment amount equally over the original invoice/credit memo.

	if nvl(count_lines,0) = 0
	then
	  	count_lines := c_inv_line_lines_count;
	end if;

	tax_amount := c_tax_amount;

	if nvl(abs_total,0) = 0 -- The original invoice had *NO* tax amounts
 	then
	  	 abs_total := count_lines;
	 	  tax_amount := 1; -- So aportion the tax adjusted across each line
	end if;

	total_adjust_amount := c_adj_tax_amount;

	calc_amount :=  total_adjust_amount * ( abs(tax_amount) / abs_total );

   end if;

   return(calc_amount);

EXCEPTION
	WHEN NO_DATA_FOUND then
		return(to_number(null));
        WHEN OTHERS then
  	        raise;

end TAX_AMOUNT_CALC;


PROCEDURE SUM_ITEM_LINE_AMOUNT(
	fc_cust_trx_id		IN	NUMBER,
	fc_type_flag 		IN      VARCHAR2,
	fc_adj_line_amount 	IN 	NUMBER,
	fc_adj_tax_amount	IN	NUMBER,
	fc_exemption_status	IN	VARCHAR2,
	fc_line_total		OUT NOCOPY	NUMBER,
	fc_tax_total		OUT NOCOPY	NUMBER) is


h_line_total NUMBER;
h_tax_total NUMBER;

cursor ssum is
       select sum(decode(line_type, 'TAX', decode(global_attribute_category, 'VERTEX',
         nvl(global_attribute2, 0) + nvl(global_attribute4, 0) + nvl(global_attribute6, 0),
         'AVP', nvl(global_attribute2, 0) + nvl(global_attribute4, 0) + nvl(global_attribute6, 0),
         extended_amount),0)),
              sum(decode(line_type, 'LINE', extended_amount,0))
       from   ra_customer_trx_lines
       where  customer_trx_id = fc_cust_trx_id
       and    line_type  in ( 'LINE', 'TAX');

cursor exlinesum is
	select  sum(trx.extended_amount)
	from   ra_customer_trx_lines trx
	where  trx.customer_trx_id = fc_cust_trx_id
	and trx.line_type = 'LINE'
	and trx.customer_trx_line_id in
 	     (  select tax.link_to_cust_trx_line_id
    		from ra_customer_trx_lines tax, ra_tax_exemptions ex
    		where tax.customer_trx_id = fc_cust_trx_id
    		and  tax.line_type = 'TAX'
    		and  tax.tax_exemption_id = ex.tax_exemption_id
    		and ex.status = fc_exemption_status  );

cursor extaxsum is
	select sum(decode(tax.global_attribute_category, 'VERTEX', nvl(tax.global_attribute2, 0)
        + nvl(tax.global_attribute4, 0) + nvl(tax.global_attribute6, 0), 'AVP',
        nvl(tax.global_attribute2, 0) + nvl(tax.global_attribute4, 0) + nvl(tax.global_attribute6, 0),
         tax.extended_amount))
	from ra_customer_trx_lines tax, ra_tax_exemptions ex
	where tax.customer_trx_id = fc_cust_trx_id
	and tax.line_type = 'TAX'
	and  tax.tax_exemption_id = ex.tax_exemption_id
	and ex.status = fc_exemption_status ;


BEGIN

if fc_type_flag = 'ADJUSTMENT' then
	fc_line_total := fc_adj_line_amount;
	fc_tax_total := fc_adj_tax_amount;

elsif   fc_exemption_status is null then
	open ssum;
        fetch ssum into h_tax_total, h_line_total;

        IF ssum%NOTFOUND
        THEN
           fc_tax_total := 0;
           fc_line_total := 0;
	ELSE
	   fc_tax_total := h_tax_total;
	   fc_line_total := h_line_total;
        END IF;
        close ssum;
else
	open exlinesum;
        fetch exlinesum into h_line_total;

        IF exlinesum%NOTFOUND
        THEN
           fc_line_total := 0;
	ELSE
	   fc_line_total := h_line_total;
        END IF;
        close exlinesum;

	open extaxsum;
        fetch extaxsum into h_tax_total;

        IF extaxsum%NOTFOUND
        THEN
           fc_tax_total := 0;
	ELSE
	   fc_tax_total := h_tax_total;
        END IF;
        close extaxsum;

end if;
EXCEPTION
        WHEN OTHERS then
  	        raise;


END SUM_ITEM_LINE_AMOUNT;


PROCEDURE GET_CUSTOMER_INFORMATION(
	fc_customer_id_in	IN 	NUMBER,
	fc_site_use_id	IN	NUMBER,
	fc_customer_trx_id IN	NUMBER,
	fc_customer_name	OUT NOCOPY	VARCHAR2,
	fc_customer_number	OUT NOCOPY	VARCHAR2,
	fc_customer_type	OUT NOCOPY	VARCHAR2,
	fc_address1	OUT NOCOPY	VARCHAR2,
	fc_address2	OUT NOCOPY	VARCHAR2,
	fc_address3	OUT NOCOPY	VARCHAR2,
	fc_address4	OUT NOCOPY	VARCHAR2,
	fc_city		OUT NOCOPY	VARCHAR2,
	fc_zip_code	OUT NOCOPY	VARCHAR2,
	fc_state		OUT NOCOPY	VARCHAR2,
	fc_province	OUT NOCOPY	VARCHAR2,
	fc_county		OUT NOCOPY	VARCHAR2) is

h_customer_name	VARCHAR2(60);
h_customer_number VARCHAR2(60);
h_customer_type VARCHAR2(60);
h_address1 VARCHAR2(240);
h_address2 VARCHAR2(240);
h_address3 VARCHAR2(240);
h_address4 VARCHAR2(240);
h_city VARCHAR2(60);
h_zip_code VARCHAR2(60);
h_state VARCHAR2(60);
h_province VARCHAR2(60);
h_county VARCHAR2(60);

cursor cust is
SELECT substrb(party.party_name,1,50),
       c.account_number,
       decode(c.customer_type,'I','Internal','R','External'),
       loc.address1, loc.address2, loc.address3,
       loc.address4, loc.city , loc.postal_code,
       loc.state, loc.province,loc.county
from
  ra_customer_trx trx, hz_cust_accounts c,
  hz_parties party,
  hz_cust_site_uses su,  hz_cust_acct_sites acct_site,
  hz_locations loc, hz_party_sites party_site
where c.cust_account_id = fc_customer_id_in
AND su.site_use_id = fc_site_use_id
AND c.party_id = party.party_id
AND su.cust_acct_site_id = acct_site.cust_acct_site_id
AND acct_site.party_site_id = party_site.party_site_id
AND loc.location_id = party_site.location_id
AND trx.customer_trx_id = fc_customer_trx_id;

BEGIN

open cust;

fetch cust into h_customer_name, h_customer_number,
h_customer_type, h_address1, h_address2,
h_address3, h_address4, h_city,h_zip_code,
h_state,h_province,h_county;

	fc_customer_name	:= h_customer_name;
	fc_customer_number	:= h_customer_number;
	fc_customer_type	:= h_customer_type;
	fc_address1 := h_address1;
	fc_address2 := h_address2;
	fc_address3 := h_address3;
	fc_address4 := h_address4;
	fc_city := h_city;
	fc_zip_code := h_zip_code;
	fc_state := h_state;
	fc_province := h_province;
	fc_county := h_county;

close cust;
exception
  when others then
  	raise;

END GET_CUSTOMER_INFORMATION;


-- note, you call following function either from line or header level,
-- for ADJUSTMENTS, there's not difference between two modes
-- for rest these rules apply:
-- c_trx_id will contain c_tax_cust_trx_line_id at line level
-- if c_type is not ADJUSTMENT and c_tax_cust_trx_line_id is null, do not call this
-- at header level c_trx_id will have c_cust_trx_id
-- call this function after you called TAX/LINE_AMOUNT_CALC or SUM_ITEM_LINE_AMOUNT
-- because you need h_tax_amount

FUNCTION TRX_COMMENT_FLAG(
	fc_type_flag		IN	VARCHAR2,
	fc_trx_id		IN	NUMBER,
	fc_detail_level		IN	VARCHAR2,
	fc_sum_tax_line_amount	IN	NUMBER,
	fc_adj_line_amount	IN	NUMBER,
	fc_adj_freight_amount	IN 	NUMBER,
	fc_adj_type		IN	VARCHAR2,
	fc_gl_flex		IN	VARCHAR2)
RETURN VARCHAR2 is

 text VARCHAR2(80);

  BEGIN

  text := '';

  if fc_type_flag = 'ADJUSTMENT'    then
     if (nvl(fc_adj_line_amount,0)+nvl(fc_adj_freight_amount,0)>0) or
       (fc_adj_type not in ( 'TAX', 'INVOICE') )
     then
       text := ' + Adjustment Transaction *** Out NOCOPY of Balance ***';
     else
       text := ' + Adjustment Transaction';
     end if;
  elsif fc_gl_flex = 'Y' then
       text := ' * Transaction not posted to Sales Tax Account *** Out NOCOPY of Balance ***';
  elsif ARRX_SALES_TAX_REP.GLTAX_IN_BALANCE(fc_trx_id,fc_detail_level) = 'N'   then
     if fc_sum_tax_line_amount = 0  then
        text := ' * Transaction not posted to Sales Tax Account';
     else
        text := ' * Transaction not posted to Sales Tax Account *** Out NOCOPY of Balance ***';
     end if;
  else text := ' ';
  end if;

  return (text);

EXCEPTION
	WHEN NO_DATA_FOUND then
		return(to_char(null));
        WHEN OTHERS then
  	        raise;

END  TRX_COMMENT_FLAG;


FUNCTION GLTAX_IN_BALANCE (
	c_trx_id		IN	NUMBER,
	c_detail_level		IN	VARCHAR2)
RETURN VARCHAR2 is

 warn_gltax_range VARCHAR2(1);

BEGIN
  if c_detail_level = 'RX_LINE' then
 	select min(decode(taxdist.code_combination_id,null,'N','Y'))
	into warn_gltax_range
	from ra_cust_trx_line_gl_dist taxdist, gl_code_combinations cc
	where customer_trx_line_id = c_trx_id
	AND taxdist.code_combination_id = cc.code_combination_id;
	if warn_gltax_range is null then
		warn_gltax_range := 'N';
	end if;
  else
 	select 	min(decode(taxdist.code_combination_id,null,'N','Y'))
	into warn_gltax_range
	from ra_cust_trx_line_gl_dist taxdist, gl_code_combinations cc,
	     ra_customer_trx trx, ra_customer_trx_lines tax
	where taxdist.customer_trx_line_id = tax.customer_trx_line_id
	AND   tax.line_type = 'TAX'
	AND   trx.customer_trx_id = tax.customer_trx_id
	AND   trx.customer_trx_id = c_trx_id
	AND   taxdist.code_combination_id = cc.code_combination_id;
	if warn_gltax_range is null then
		warn_gltax_range := 'N';
	end if;
  end if;

  return (warn_gltax_range);

EXCEPTION
	WHEN NO_DATA_FOUND then
		return(to_char(null));
        WHEN OTHERS then
  	        raise;

END GLTAX_IN_BALANCE;

FUNCTION GET_CONVERSION_RATE_TYPE
        (c_exchange_rate_type	IN	VARCHAR2)
RETURN VARCHAR2 is

  rate_type VARCHAR(30);

BEGIN
  select user_conversion_type into rate_type
  from gl_daily_conversion_types
  where conversion_type = c_exchange_rate_type;

  return(rate_type);

  EXCEPTION
	WHEN NO_DATA_FOUND then
		return(to_char(null));
        WHEN OTHERS then
  	        raise;

END GET_CONVERSION_RATE_TYPE;

FUNCTION GET_ITEM_DESCRIPTION(
	fc_organization_id	IN	NUMBER,
	fc_inventory_item_id	IN	NUMBER)
RETURN VARCHAR2 is

  item_description VARCHAR2(240);

BEGIN
  select description into item_description
  from mtl_system_items
  where inventory_item_id = fc_inventory_item_id
  and   organization_id = fc_organization_id;

  return(item_description);

  EXCEPTION
	WHEN NO_DATA_FOUND then
		return(to_char(null));
        WHEN OTHERS then
  	        raise;

END GET_ITEM_DESCRIPTION;


FUNCTION GET_ITEM(
	fc_organization_id	IN	NUMBER,
	fc_inventory_item_id	IN	NUMBER)
RETURN VARCHAR2 is

  s1 VARCHAR2(40);
  s2 VARCHAR2(40);
  s3 VARCHAR2(40);
  s4 VARCHAR2(40);
  s5 VARCHAR2(40);
  s6 VARCHAR2(40);
  s7 VARCHAR2(40);
  s8 VARCHAR2(40);
  s9 VARCHAR2(40);
  s10 VARCHAR2(40);
  s11 VARCHAR2(40);
  s12 VARCHAR2(40);
  s13 VARCHAR2(40);
  s14 VARCHAR2(40);
  s15 VARCHAR2(40);
  s16 VARCHAR2(40);
  s17 VARCHAR2(40);
  s18 VARCHAR2(40);
  s19 VARCHAR2(40);
  s20 VARCHAR2(40);
  item VARCHAR2(800);

BEGIN
  select segment1, segment2, segment3, segment4, segment5, segment6, segment7, segment8,
  segment9, segment10, segment11, segment12, segment13, segment14, segment15, segment16,
  segment17, segment18, segment19, segment20
  into s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20
  from mtl_system_items
  where inventory_item_id = fc_inventory_item_id
  and   organization_id = fc_organization_id;

  item :=
    s1||s2||s3||s4||s5||s6||s7||s8||s9||s10||s11||s12||s13||s14||s15||s16||s17||s18||s19||s20;

  return(item);

EXCEPTION
	WHEN NO_DATA_FOUND then
		return(to_char(null));
        WHEN OTHERS then
  	        raise;


END GET_ITEM;

PROCEDURE WRITE_LOG(
	fc_which		IN	NUMBER,
	fc_text			IN	VARCHAR2,
	fc_buffer 		OUT NOCOPY     VARCHAR2) is

BEGIN
	fnd_file.put_line( which => fc_which,
			   BUFF	=> fc_text);
	fc_buffer := '';

EXCEPTION
	WHEN utl_file.invalid_path then
		fc_buffer := 'Invalid path';
	WHEN utl_file.invalid_mode then
		fc_buffer := 'Invalid Mode';
	WHEN utl_file.invalid_filehandle then
		fc_buffer := 'Invalid filehandle';
	WHEN utl_file.invalid_operation then
		fc_buffer := 'Invalid operation';
	WHEN utl_file.write_error then
		fc_buffer := 'Write error';

END WRITE_LOG;

FUNCTION GET_MIN_TAX_LINE_ID(
	fc_trx_line_id 		IN	NUMBER
	)
RETURN NUMBER is

min_tax_line_id NUMBER;

BEGIN
  select min(customer_trx_line_id) into min_tax_line_id
  from ra_customer_trx_lines
  where link_to_cust_trx_line_id = fc_trx_line_id
  and  line_type = 'TAX';

  return(min_tax_line_id);

EXCEPTION
	WHEN NO_DATA_FOUND then
		return 0;
        WHEN OTHERS then
  	        raise;

END GET_MIN_TAX_LINE_ID;

-- here we calculate the exempt amount

FUNCTION EXEMPTION_AMOUNT_CALC_LINE(
	fc_precision		IN	NUMBER,
	fc_mau			IN	NUMBER,
	fc_exempt_percent	IN	NUMBER,
	fc_line_amount		IN	NUMBER,
	fc_cnt_tax_lines	IN	NUMBER)
RETURN NUMBER is

	exemption_amount NUMBER;
BEGIN
  	exemption_amount := (nvl(fc_line_amount,0)/fc_cnt_tax_lines) * nvl(fc_exempt_percent,0)/100;
	exemption_amount := aol_round(exemption_amount, fc_precision, fc_mau);
	return(exemption_amount);

EXCEPTION
        WHEN OTHERS then
  	        raise;

END EXEMPTION_AMOUNT_CALC_LINE;


--here we calculate the taxable amount

FUNCTION TAXABLE_AMOUNT_CALC_LINE(
	fc_precision		IN	NUMBER,
	fc_mau			IN	NUMBER,
	fc_exemption_amount	IN	NUMBER,
	fc_line_amount		IN	NUMBER,
	fc_cnt_tax_lines	IN	NUMBER)
RETURN NUMBER is

	taxable_amount NUMBER;
BEGIN
	taxable_amount := fc_line_amount/fc_cnt_tax_lines - fc_exemption_amount;
	taxable_amount := aol_round(taxable_amount, fc_precision, fc_mau);
	return(taxable_amount);

EXCEPTION
        WHEN OTHERS then
  	        raise;

END TAXABLE_AMOUNT_CALC_LINE;

FUNCTION AOL_ROUND(
	fc_n			IN	NUMBER,
	fc_precision		IN	NUMBER,
	fc_mac			IN	NUMBER)
RETURN NUMBER is
	n_amount NUMBER;
BEGIN
	if fc_mac is null then
		n_amount := round(fc_n, fc_precision);
	else
		n_amount := round(fc_n,fc_mac) * fc_mac;
	end if;
	return(n_amount);
EXCEPTION
        WHEN OTHERS then
  	        raise;
END AOL_ROUND;

FUNCTION CNT_TAX_LINES_FOR_INV_LINE(
	fc_trx_line_id		IN	NUMBER)
RETURN NUMBER is
	cnt_tax_lines NUMBER;
BEGIN
	select count(*) into cnt_tax_lines from ra_customer_trx_lines
	where link_to_cust_trx_line_id = fc_trx_line_id
	and line_type = 'TAX';
	if nvl(cnt_tax_lines,0) = 0 then
	   cnt_tax_lines := 1;
	end if;
	return(cnt_tax_lines);

EXCEPTION
	WHEN NO_DATA_FOUND then
		return 1;
        WHEN OTHERS then
  	        raise;
END CNT_TAX_LINES_FOR_INV_LINE;

FUNCTION CNT_INV_LINES_FOR_INV_HEADER(
	f_trx_id		IN	NUMBER)
RETURN NUMBER is
	cnt_inv_lines NUMBER;
BEGIN
	select count(*) into cnt_inv_lines from ra_customer_trx_lines
	where customer_trx_id = f_trx_id
	and line_type = 'LINE';
	if nvl(cnt_inv_lines,0) = 0 then
	   cnt_inv_lines := 0;
	end if;
	return(cnt_inv_lines);

EXCEPTION
	WHEN NO_DATA_FOUND then
		return 0;
        WHEN OTHERS then
  	        raise;
END CNT_INV_LINES_FOR_INV_HEADER;

FUNCTION GET_CUSTOMER_TRX_LINE_ID(
	fn_trx_id		IN	NUMBER,
	fn_cnt_lines		IN	NUMBER)
RETURN NUMBER is
	cus_trx_line_id NUMBER;

cursor get_customer_trx_line_id is
SELECT customer_trx_line_id from ra_customer_trx_lines
WHERE customer_trx_id = fn_trx_id
AND line_type = 'LINE'
AND line_number = fn_cnt_lines;
BEGIN
	open get_customer_trx_line_id;
	fetch get_customer_trx_line_id into cus_trx_line_id;
	close get_customer_trx_line_id;
	return(cus_trx_line_id);

EXCEPTION
        WHEN OTHERS then
  	        raise;
END GET_CUSTOMER_TRX_LINE_ID;

FUNCTION GET_EXEMPTION_AMT(
	fg_trx_id		IN	NUMBER,
	fg_precision		IN	NUMBER,
	fg_mau			IN	NUMBER,
	fg_type_flag		IN	VARCHAR2)
RETURN NUMBER is
	exemption_amount NUMBER;
	exemption_amount_for_line NUMBER;
	exemption_amount_for_line_tot NUMBER;
	cus_trx_line_id NUMBER;
	tax_line_id NUMBER;
	in_mesg VARCHAR2(35);
	cnt_lines NUMBER;
	cnt_tax_lines NUMBER;
	l_tax_rate NUMBER;
	l_exempt_percent NUMBER;
	l_tax_exemption_id NUMBER;
	l_line_amount NUMBER;

cursor get_customer_trx_line_id is
SELECT customer_trx_line_id, extended_amount from ra_customer_trx_lines
WHERE customer_trx_id = fg_trx_id
AND line_type = 'LINE';

cursor get_customer_trx_tax_id is
SELECT customer_trx_line_id, tax_exemption_id, tax_rate from ra_customer_trx_lines
WHERE link_to_cust_trx_line_id = cus_trx_line_id
AND line_type = 'TAX';

cursor get_tax_exemption_rate is
SELECT percent_exempt from ra_tax_exemptions
WHERE tax_exemption_id = l_tax_exemption_id;

BEGIN
	in_mesg := 'GET_EXEMPTION_AMT';
	exemption_amount := 0;
	cnt_lines := CNT_INV_LINES_FOR_INV_HEADER(fg_trx_id);
	open get_customer_trx_line_id;
	loop  -- invoice lines for invoice header
	  fetch get_customer_trx_line_id into cus_trx_line_id, l_line_amount;
	  if fg_type_flag = 'ADJUSTMENT' then
		l_line_amount := (-1)*l_line_amount;
	  end if;
	  if (get_customer_trx_line_id%NOTFOUND)  then
	    	exit;
	  end if;
	  exemption_amount_for_line := 0;
	  exemption_amount_for_line_tot := 0;
	  -- first we check does the invoice lile have tax lines at all, if not
	  -- whole line amount is exempt amount

	  select count(*) into cnt_tax_lines from ra_customer_trx_lines
	  where link_to_cust_trx_line_id = cus_trx_line_id
	  and line_type = 'TAX';
	  if cnt_tax_lines = 0 then
		exemption_amount_for_line_tot := l_line_amount;
	  end if;
	  open get_customer_trx_tax_id;
	  loop          -- tax lines for invoice line
		fetch get_customer_trx_tax_id into tax_line_id, l_tax_exemption_id, l_tax_rate;
		if (get_customer_trx_tax_id%NOTFOUND) then
			exit;
				end if;
		if l_tax_exemption_id is null and nvl(l_tax_rate,0) = 0 then
			l_exempt_percent := 100;
			ARRX_SALES_TAX_REP.WRITE_LOG(
			fc_which => 1,
			fc_text => '100 prosenttia',
			fc_buffer => in_mesg );

		elsif l_tax_exemption_id is not null then
			open get_tax_exemption_rate;
			fetch get_tax_exemption_rate into l_exempt_percent;
			close get_tax_exemption_rate;
		else
		  	l_exempt_percent := 0;
		end if;
		if l_exempt_percent is not null then
			cnt_tax_lines := CNT_TAX_LINES_FOR_INV_LINE(cus_trx_line_id);
        		exemption_amount_for_line := EXEMPTION_AMOUNT_CALC_LINE(
				fg_precision,
				fg_mau,
				l_exempt_percent,
				l_line_amount,
				cnt_tax_lines);
		else
			exemption_amount_for_line := 0;
		end if;
		exemption_amount_for_line_tot :=  exemption_amount_for_line_tot + exemption_amount_for_line ;

	     end loop;      -- tax lines for invoice line
	     close get_customer_trx_tax_id;
	     exemption_amount := exemption_amount + exemption_amount_for_line_tot;

	end loop; -- invoice lines for invoice header
	close get_customer_trx_line_id;

	return(exemption_amount);

EXCEPTION
        WHEN OTHERS then
		if get_customer_trx_line_id%ISOPEN then
			close get_customer_trx_line_id;
		end if;
		if get_customer_trx_tax_id%ISOPEN then
			close get_customer_trx_tax_id;
		end if;
 		if get_tax_exemption_rate%ISOPEN then
			close  get_tax_exemption_rate;
		end if;
		ARRX_SALES_TAX_REP.WRITE_LOG(
		fc_which => 1,
	        fc_text => 'An error occured when getting exemption amount for invoice header',
		fc_buffer => in_mesg);
  	        raise;

END GET_EXEMPTION_AMT;


PROCEDURE GET_PRECISION_AND_MAU(
	fc_currency		IN	VARCHAR2,
	fc_precision		OUT NOCOPY	NUMBER,
	fc_mau			OUT NOCOPY	NUMBER) is

 c_precision NUMBER;
 c_mau	NUMBER;

BEGIN

 select nvl(precision,0), minimum_accountable_unit
 into c_precision, c_mau
 from fnd_currencies
 where currency_code = fc_currency;

 fc_precision := c_precision;
 if c_mau is null then
	fc_mau := to_number(null);
 else
	fc_mau := c_mau;
 end if;

EXCEPTION
        WHEN OTHERS then
  	        raise;
END GET_PRECISION_AND_MAU;

end ARRX_SALES_TAX_REP;

/
