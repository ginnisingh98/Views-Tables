--------------------------------------------------------
--  DDL for Package Body OE_CATALOG_PRICING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CATALOG_PRICING_PUB" AS
/* $Header: OEXPRCAB.pls 115.3 2000/10/02 13:47:07 pkm ship      $ */

PROCEDURE Get_Pricing
(p_item_number IN NUMBER,
 p_ordered_quantity IN NUMBER,
 p_uom IN VARCHAR2,
 p_price_list_id IN NUMBER,
 p_sold_to_org_id IN NUMBER,
 p_currency IN VARCHAR2,
 p_ordered_date IN VARCHAR2,
 status OUT VARCHAR2,
 x_customer_price OUT NUMBER,
 x_list_price OUT NUMBER
)
IS
l_line_tbl            oe_order_adj_pvt.quote_line_tbl_type;
lx_line_tbl           oe_order_adj_pvt.quote_line_tbl_type;
l_header              oe_order_adj_pvt.quote_header_rec_type;
lx_return_status      Varchar2(30);
lx_return_status_text Varchar2(200);
i PLS_INTEGER;

BEGIN

l_header.ordered_date := to_date(p_ordered_date,'DD-MON-YYYY');
l_header.transactional_curr_code := p_currency;

l_header.sold_to_org_id := p_sold_to_org_id;

l_line_tbl(1).price_list_id     := p_price_list_id;
l_line_tbl(1).inventory_item_id := p_item_number;
l_line_tbl(1).ordered_quantity  := p_ordered_quantity;
l_line_tbl(1).order_quantity_uom := p_uom;
l_line_tbl(1).sold_to_org_id := p_sold_to_org_id;

oe_order_adj_pvt.Get_Quote(p_quote_header            => l_header,
                            p_quote_line_tbl          => l_line_tbl,
          	     	   p_request_type_code       => 'ONT',
          		        x_quote_line_tbl          => lx_line_tbl,
          		        x_return_status           => lx_return_status,
                            x_return_status_text      => lx_return_status_text);

if lx_line_tbl(1).status_code = 'S' then

   status := lx_line_tbl(1).status_code;
   x_list_price := lx_line_tbl(1).Unit_List_Price;
   x_customer_price := lx_line_tbl(1).Unit_Selling_Price;
else
   status := 'Contact Sales';
   x_list_price := 0;
   x_customer_price := 0;
end if;

END Get_Pricing;

END OE_CATALOG_PRICING_PUB ;

/
