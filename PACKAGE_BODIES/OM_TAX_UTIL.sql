--------------------------------------------------------
--  DDL for Package Body OM_TAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OM_TAX_UTIL" AS
/* $Header: OEXUTAXB.pls 120.20.12010000.7 2010/01/19 08:46:04 srsunkar ship $ */
G_BINARY_LIMIT                CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT;
G_DEBUG_BYPASS_TAX            CONSTANT VARCHAR2(1):=nvl(Fnd_Profile.value('OE_DBG_BYPASS'),'N');
 -- structure for caching loc_ship_bill_info
 TYPE loc_ship_bill_info_rec IS RECORD (
          site_use_id                 HZ_CUST_SITE_USES_ALL.site_use_id%TYPE,
          acct_site_id                HZ_CUST_SITE_USES_ALL.cust_acct_site_id%TYPE,
          cust_acct_id                HZ_CUST_ACCT_SITES_ALL.cust_account_id%TYPE,
          postal_code                 HZ_LOCATIONS.postal_code%TYPE,
          customer_name               HZ_PARTIES.party_name%TYPE,
          customer_number             HZ_CUST_ACCOUNTS_ALL.account_number%TYPE,
          party_id                    HZ_PARTIES.party_id%TYPE,
          party_site_id               HZ_PARTY_SITES.party_site_id%TYPE,
          location_id                 HZ_LOCATIONS.location_id%TYPE);

 TYPE ship_bill_records IS TABLE OF loc_ship_bill_info_rec INDEX BY BINARY_INTEGER;
 ship_bill_records_tab  ship_bill_records;
 pr_index    number;

-- salesrep criteria
G_SALESREP_ID                     NUMBER;
G_SALESREP_POA_ID                 NUMBER;

-- cache values
G_POO_PARTY_ID                          NUMBER;
G_POO_LOCATION_ID                   NUMBER;

Procedure Debug_msg(p_index         IN  NUMBER,
		    x_return_status OUT NOCOPY Varchar2) ;


Function get_le_id(p_order_type_id NUMBER
                  , p_sold_to_customer_id NUMBER
                  , p_bill_to_customer_id NUMBER
                  , p_org_id NUMBER
) RETURN NUMBER;

PROCEDURE TAX_LINE( p_line_rec           in OE_Order_PUB.Line_Rec_Type,
                    p_header_rec         in OE_Order_PUB.Header_Rec_Type,
                    x_tax_value          out NOCOPY /* file.sql.39 change */ number,
                    x_tax_out_tbl OUT NOCOPY OM_TAX_UTIL.om_tax_out_tab_type,
                    x_return_status      out NOCOPY /* file.sql.39 change */ varchar2) as

 l_tax_rec_out_tbl              OM_TAX_UTIL.om_tax_out_tab_type;
 -- x_ret_sts                       VARCHAR2(10) := NULL; --bug 3064854
 l_return_status                VARCHAR2(1);
 -- l_ren_tax_timing            NUMBER := 0;
 -- lp                          BINARY_INTEGER;
 l_call_tax                     VARCHAR2(1);
 l_tax_value                    NUMBER;
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(1000);
 l_trx_shipping_date		DATE;
 l_trx_business_category	VARCHAR2(240);
 l_product_fisc_classification	VARCHAR2(240);
 l_uom_code			VARCHAR2(3);
 l_product_code			VARCHAR2(1000);
 l_trx_line_number		NUMBER;
 l_user_item_description	VARCHAR2(1000);
 i				NUMBER;
 l_ship_party_id		NUMBER(15);
 l_ship_party_site_id	        NUMBER(15);
 l_ship_location_id	        NUMBER(15);
 l_bill_party_id		NUMBER(15);
 l_bill_party_site_id	        NUMBER(15);
 l_bill_location_id	        NUMBER(15);
 l_ship_to_site_use_id		HZ_CUST_SITE_USES_ALL.SITE_USE_ID%type;
 l_ship_to_address_id           NUMBER ;
 l_ship_to_customer_id          NUMBER ;
 l_ship_to_postal_code          VARCHAR2(60);
 l_ship_to_customer_name        VARCHAR2(360);
 l_ship_to_customer_number      VARCHAR2(30);
 l_bill_to_address_id           NUMBER;
 l_bill_to_site_use_id          NUMBER;
 l_bill_to_customer_id          NUMBER;
 l_bill_to_postal_code          VARCHAR2(60);
 l_internal_org_location_id        NUMBER;
 l_bill_to_customer_name        VARCHAR2(360);
 l_bill_to_customer_number      VARCHAR2(30);
 l_header_id			oe_order_headers.header_id%type;
 l_tax_date			oe_order_lines.tax_date%type;
 l_ordered_quantity		oe_order_lines.ordered_quantity%type;
 l_unit_selling_price		oe_order_lines.unit_selling_price%type;
 l_tax_exempt_number		oe_order_lines.tax_exempt_number%type;
 l_tax_exempt_reason		oe_order_lines.tax_exempt_reason_code%type;
 l_inventory_item_id		oe_order_lines.inventory_item_id%type;
 l_ship_from_org_id		oe_order_lines.ship_from_org_id%type;
 l_ship_from_location_id        NUMBER;
 l_fob_point_code		oe_order_lines.fob_point_code%type;
 l_ship_to_org_id		oe_order_lines.ship_to_org_id%type;
 l_invoice_to_org_id		oe_order_lines.invoice_to_org_id%type;
 l_application_id               NUMBER;
 l_entity_code_crsr	        zx_detail_tax_lines_gt.entity_code%TYPE;
 l_event_class_code_crsr	zx_detail_tax_lines_gt.event_class_code%TYPE ;
 l_trx_level_type_crsr	        zx_detail_tax_lines_gt.trx_level_type%TYPE;
 l_line_id                      NUMBER;
 l_line_rec                     OE_Order_PUB.Line_Rec_Type;
 l_inventory_org_id 	        NUMBER;
 l_currency_code  	        VARCHAR2(30);
 l_tax_code                     VARCHAR2(50);
 l_header_org_id  	        NUMBER;
 l_conversion_rate 	        NUMBER;
 l_precision                    fnd_currencies.precision%type;
 l_minimum_accountable_unit     fnd_currencies.minimum_accountable_unit%type;
 l_commitment_id                oe_order_lines.commitment_id%type;
 l_cust_trx_type_id             ra_cust_trx_types_all.cust_Trx_type_id%type;
 l_AR_Sys_Param_Rec             ar_system_parameters_all%ROWTYPE;
 l_product_type			zx_product_types_def_v.classification_code%TYPE;
 --x_otoc_le_info_rec   		XLE_BUSINESSINFO_GRP.otoc_le_rec;
 l_legal_entity_id    		NUMBER(15);
 l_customer_type      		VARCHAR2(30);
 l_customer_id        		NUMBER;
 l_batch_source_id		NUMBER;
 l_sold_to_customer_id		NUMBER;
 l_invoice_number_profile	VARCHAR2(30);
 l_bill_from_location_id        NUMBER;
 Is_fmt           BOOLEAN;   --8431420


 cursor getlocinfo(p_site_org_id HZ_CUST_SITE_USES_ALL.SITE_USE_ID%type) is
 SELECT /* MOAC_SQL_CHANGE */ s_ship.site_use_id,
       s_ship.cust_acct_site_id,
       acct_site_ship.cust_account_id,
       loc_ship.postal_code,
       party.party_name,
       cust_acct.account_number,
       party.party_id,
       party_site_ship.party_site_id,
       loc_ship.location_id
 FROM
       HZ_CUST_SITE_USES           S_SHIP ,
       HZ_CUST_ACCT_SITES_ALL      ACCT_SITE_SHIP,
       HZ_PARTY_SITES              PARTY_SITE_SHIP,
       HZ_LOCATIONS                LOC_SHIP,
       HZ_PARTIES                  PARTY,
       HZ_CUST_ACCOUNTS_ALL        CUST_ACCT
WHERE  s_ship.site_use_id = p_site_org_id
  AND  s_ship.cust_acct_site_id  = acct_site_ship.cust_acct_site_id
  and  acct_site_ship.cust_account_id = cust_acct.cust_account_id
  and  cust_acct.party_id = party.party_id
  and  acct_site_ship.party_site_id = party_site_ship.party_site_id
  and  party_site_ship.location_id = loc_ship.location_id;

 /*
  CURSOR oeorderline IS
  SELECT
  oe_order_lines.header_id,
  oe_order_lines.tax_date,
  oe_order_lines.pricing_quantity,
  oe_order_lines.unit_selling_price,
  oe_order_lines.tax_exempt_number,
  oe_order_lines.tax_exempt_reason_code,
  oe_order_lines.inventory_item_id,
  oe_order_lines.ship_from_org_id,
  oe_order_lines.fob_point_code,
  oe_order_lines.tax_code,
  NVL(oe_order_lines.actual_shipment_date, oe_order_lines.schedule_ship_date),
  DECODE(	oe_order_lines.global_attribute_category,
  	'JL.AR.OEXOEORD.LINES', oe_order_lines.global_attribute6,
  	'JL.BR.OEXOEORD.LINES', oe_order_lines.global_attribute6,
  	'JL.CO.OEXOEORD.LINES', oe_order_lines.global_attribute6,NULL) ,
  Decode(oe_order_lines.global_attribute_category,
  	'JL.AR.OEXOEORD.LINES', oe_order_lines.global_attribute5,
  	'JL.BR.OEXOEORD.LINES', oe_order_lines.global_attribute5,
  	'JL.CO.OEXOEORD.LINES',oe_order_lines.global_attribute5,NULL) ,
  NVL(oe_order_lines.pricing_quantity_uom, oe_order_lines.order_quantity_uom) ,
  DECODE(oe_order_lines.user_item_description, NULL, 'MEMO', 'SERVICE'),
  oe_order_lines.line_number ,
  oe_order_lines.user_item_description
  FROM 	oe_order_lines, oe_system_parameters
  WHERE	oe_order_lines.org_id = oe_system_parameters.org_id
  --AND	header_id = p_header_id
  AND	line_id = p_line_rec.line_id;
 */

 CURSOR get_internal_loc(p_organization_id number) IS
 select location_id
 from   hr_organization_units
 where  organization_id = p_organization_id;


 CURSOR detail_tax_lines_gt (p_header_id oe_order_lines.header_id%type,
			    p_line_id oe_order_lines.line_id%type)
  is
  select * from
  ZX_DETAIL_TAX_LINES_GT
  where
  application_id = l_application_id
  and entity_code = l_entity_code_crsr 		 --'OE_ORDER_HEADERS'
  and event_class_code = l_event_class_code_crsr --'SALES_TRANSACTION_TAX_QUOTE'
  and trx_id =  p_header_id
  and trx_line_id = p_line_id
  and trx_level_type = l_trx_level_type_crsr;	 --'LINE';


 detail_tax_lines_gt_rec detail_tax_lines_gt%rowtype;
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_transaction_rec zx_api_pub.transaction_rec_type;
 l_doc_level_recalc_flag varchar2(30);
 l_trx_date DATE;
 L_POO_PARTY_ID    NUMBER;
 l_POO_LOCATION_ID  NUMBER;
BEGIN

    IF G_DEBUG_BYPASS_TAX = 'Y' THEN
      l_return_status         := FND_API.G_RET_STS_SUCCESS;
      return;
    END IF;

    l_line_rec              := p_line_rec;
    l_return_status         := FND_API.G_RET_STS_SUCCESS;
    l_entity_code_crsr	    := 'OE_ORDER_HEADERS';
    l_event_class_code_crsr := 'SALES_TRANSACTION_TAX_QUOTE';
    l_trx_level_type_crsr   := 'LINE';
    l_line_id               := l_line_rec.line_id;
    l_call_tax              := 'N';
    l_tax_value             := 0;
    l_application_id        := 660;

    IF l_debug_level > 0 THEN

	 oe_debug_pub.add('entering tax_line:'||l_line_id , 1);
	 oe_debug_pub.add('tax_line 1' , 1);
    END IF;

    -- Get Header Information
/*
    oe_order_cache.load_order_header(l_line_rec.header_id);
    l_currency_code := oe_order_cache.g_header_rec.transactional_curr_code;
    l_header_org_id := oe_order_cache.g_header_rec.org_id;
    l_conversion_rate := oe_order_cache.g_header_rec.conversion_rate;
    l_inventory_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID',oe_order_cache.g_header_rec.org_id);
*/

    l_currency_code := p_header_rec.transactional_curr_code;
    l_header_org_id := p_header_rec.org_id;
    l_conversion_rate := p_header_rec.conversion_rate;
    l_inventory_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID',p_header_rec.org_id);


     select    c.minimum_accountable_unit,
               c.precision
     into      l_minimum_accountable_unit,
               l_precision
     from      fnd_currencies c
     where     c.currency_code = l_currency_code;

     l_AR_Sys_Param_Rec          := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params;

--8431420
  IF OE_ORDER_UTIL.G_Precision IS NULL THEN
    Is_fmt:= OE_ORDER_UTIL.Get_Precision(p_header_id=>p_header_rec.header_id);

    IF OE_ORDER_UTIL.G_Precision IS NULL THEN
       OE_ORDER_UTIL.G_Precision:=2;
    END IF;
  END IF;
--8431420

     --code changes made for bug 1883552  begin
     l_commitment_id := nvl(l_line_rec.commitment_id,0);
     if l_commitment_id <> 0 then


          IF l_debug_level > 0 THEN
            oe_debug_pub.add('Commitment id is:'||l_commitment_id,4);
          END IF;

          begin

           select /* MOAC_SQL_CHANGE */ nvl(cust_type.subsequent_trx_type_id, cust_type.cust_trx_type_id)
           into l_cust_trx_type_id
           from ra_cust_trx_types_all cust_type,
                ra_customer_trx cust_trx
           where
                cust_type.cust_trx_type_id = cust_trx.cust_trx_type_id
           and  cust_type.org_id = cust_trx.org_id
           and  cust_trx.customer_trx_id = l_commitment_id;

          exception
             when others then

             IF l_debug_level > 0 THEN
               oe_debug_pub.add('In commitment exception ',4);
             END IF;
             null;
          end;

        IF l_debug_level > 0 THEN
          oe_debug_pub.add('cust trx type from commitment:'||l_cust_Trx_type_id,4);
        END IF;
     else

       IF l_debug_level > 0 THEN
         oe_debug_pub.add('In else part of commitment id',4);
       END IF;
       l_cust_trx_type_id :=    OE_INVOICE_PUB.Get_Customer_Transaction_Type(p_line_rec);
     end if;
     --code changes made for bug 1883552  end

    IF l_debug_level > 0 THEN
     oe_debug_pub.add('Customer trx type id is:'||l_cust_trx_type_id,4);
    END IF;

    l_ship_to_org_id := l_line_rec.ship_to_org_id ;
    l_invoice_to_org_id := l_line_rec.invoice_to_org_id;

    IF l_ship_to_org_id is not null THEN

	pr_index := MOD(l_ship_to_org_id,G_BINARY_LIMIT);
	BEGIN

         IF l_debug_level > 0 THEN
	  oe_debug_pub.add('om_tax_line  3' , 4);
	 END IF;

	 IF ship_bill_records_tab.exists(pr_index) THEN --bug8799250

	   IF l_debug_level > 0 THEN
	      oe_debug_pub.add('om_tax_line  3.5' , 4);
	   END IF;

	   l_ship_to_site_use_id :=          ship_bill_records_tab(pr_index).site_use_id;
	   l_ship_to_address_id  :=          ship_bill_records_tab(pr_index).acct_site_id;
	   l_ship_to_customer_id  :=         ship_bill_records_tab(pr_index).cust_acct_id;
	   l_ship_to_postal_code  :=         ship_bill_records_tab(pr_index).postal_code;
	   l_ship_to_customer_name  :=       ship_bill_records_tab(pr_index).customer_name;
	   l_ship_to_customer_number  :=     ship_bill_records_tab(pr_index).customer_number;
	   l_ship_party_id  :=               ship_bill_records_tab(pr_index).party_id;
	   l_ship_party_site_id  :=          ship_bill_records_tab(pr_index).party_site_id;
	   l_ship_location_id :=             ship_bill_records_tab(pr_index).location_id;

	 ELSE
	   OPEN getlocinfo(l_ship_to_org_id);

	   IF l_debug_level > 0 THEN
	        oe_debug_pub.add('om_tax_line  4' , 4);
	   END IF;

           FETCH getlocinfo
           INTO l_ship_to_site_use_id,
                l_ship_to_address_id,
                l_ship_to_customer_id,
                l_ship_to_postal_code,
                l_ship_to_customer_name,
                l_ship_to_customer_number,
	        l_ship_party_id,
	        l_ship_party_site_id,
	        l_ship_location_id;


	    ship_bill_records_tab(pr_index).site_use_id  :=               l_ship_to_site_use_id;
	    ship_bill_records_tab(pr_index).acct_site_id  :=              l_ship_to_address_id;
	    ship_bill_records_tab(pr_index).cust_acct_id  :=              l_ship_to_customer_id;
	    ship_bill_records_tab(pr_index).postal_code  :=               l_ship_to_postal_code;
	    ship_bill_records_tab(pr_index).customer_name  :=             l_ship_to_customer_name;
	    ship_bill_records_tab(pr_index).customer_number  :=           l_ship_to_customer_number;
	    ship_bill_records_tab(pr_index).party_id  :=                  l_ship_party_id;
	    ship_bill_records_tab(pr_index).party_site_id  :=             l_ship_party_site_id;
	    ship_bill_records_tab(pr_index).location_id  :=               l_ship_location_id;


	   IF l_debug_level > 0 THEN
	    oe_debug_pub.add('om_tax_line  5' , 4);
	   END IF;
           close getlocinfo;

          END IF;

       EXCEPTION
            when no_data_found then
		 IF l_debug_level > 0 THEN
		   oe_debug_pub.add('om_tax_line  6' , 1);
		 END IF;

                 NULL;
                 close getlocinfo;
       END;
    END IF;

    IF l_invoice_to_org_id is not null THEN

       pr_index := MOD(l_invoice_to_org_id,G_BINARY_LIMIT); --bug8799250
       BEGIN
         IF l_debug_level > 0 THEN
	    oe_debug_pub.add('om_tax_line  7' , 4);
	 END IF;


	 IF ship_bill_records_tab.exists(pr_index) THEN

	    IF l_debug_level > 0 THEN
	        oe_debug_pub.add('om_tax_line  7.5' , 4);
	    END IF;

	   l_bill_to_site_use_id :=          ship_bill_records_tab(pr_index).site_use_id;
	   l_bill_to_address_id  :=          ship_bill_records_tab(pr_index).acct_site_id;
	   l_bill_to_customer_id  :=         ship_bill_records_tab(pr_index).cust_acct_id;
	   l_bill_to_postal_code  :=         ship_bill_records_tab(pr_index).postal_code;
	   l_bill_to_customer_name  :=       ship_bill_records_tab(pr_index).customer_name;
	   l_bill_to_customer_number  :=     ship_bill_records_tab(pr_index).customer_number;
	   l_bill_party_id  :=               ship_bill_records_tab(pr_index).party_id;
	   l_bill_party_site_id  :=          ship_bill_records_tab(pr_index).party_site_id;
	   l_bill_location_id :=             ship_bill_records_tab(pr_index).location_id;

	 ELSE

             OPEN getlocinfo(l_invoice_to_org_id);
             IF l_debug_level > 0 THEN
	          oe_debug_pub.add('om_tax_line  8' , 4);
	     END IF;

              FETCH getlocinfo
              INTO l_bill_to_site_use_id,
                   l_bill_to_address_id,
                   l_bill_to_customer_id,
                   l_bill_to_postal_code,
                   l_bill_to_customer_name,
                   l_bill_to_customer_number,
	           l_bill_party_id,
	           l_bill_party_site_id,
	           l_bill_location_id;
              IF l_debug_level > 0 THEN
                 oe_debug_pub.add('om_tax_line  9' , 4);
              END IF;

            ship_bill_records_tab(pr_index).site_use_id  :=      l_bill_to_site_use_id;
	    ship_bill_records_tab(pr_index).acct_site_id  :=     l_bill_to_address_id;
	    ship_bill_records_tab(pr_index).cust_acct_id  :=     l_bill_to_customer_id;
	    ship_bill_records_tab(pr_index).postal_code  :=      l_bill_to_postal_code;
	    ship_bill_records_tab(pr_index).customer_name  :=    l_bill_to_customer_name;
	    ship_bill_records_tab(pr_index).customer_number  :=  l_bill_to_customer_number;
	    ship_bill_records_tab(pr_index).party_id  :=         l_bill_party_id;
	    ship_bill_records_tab(pr_index).party_site_id  :=    l_bill_party_site_id;
	    ship_bill_records_tab(pr_index).location_id  :=      l_bill_location_id;

            close getlocinfo;

         END IF;

       EXCEPTION
           when no_data_found then
            IF l_debug_level > 0 THEN
            	oe_debug_pub.add('om_tax_line  10' , 1);
            END IF;
            close getlocinfo;
       END;
    END IF;

     open get_internal_loc(p_header_Rec.org_id );
     fetch get_internal_loc into l_internal_org_location_id;
     close get_internal_loc;


    BEGIN
       -- assign values from l_line_rec
       l_header_id          := l_line_rec.header_id;
       l_tax_date           := l_line_rec.tax_date;
       l_ordered_quantity   := l_line_rec.ordered_quantity;
       l_unit_selling_price := l_line_rec.unit_selling_price;
       l_tax_exempt_number  := l_line_rec.tax_exempt_number;
       l_tax_exempt_reason  := l_line_rec.tax_exempt_reason_code;
       l_inventory_item_id  := l_line_rec.inventory_item_id;
       l_ship_from_org_id   := l_line_rec.ship_from_org_id;
       l_fob_point_code     := l_line_rec.fob_point_code;
       l_tax_code           := l_line_rec.tax_code;
       l_trx_shipping_date  := NVL(l_line_rec.actual_shipment_date, l_line_rec.schedule_ship_date);
       l_uom_code           := NVL(l_line_rec.order_quantity_uom, l_line_rec.pricing_quantity_uom);
       -- l_product_code      := l_line_rec.user_item_description;  -- this should be mtl_system_items_b.segment1
       l_trx_line_number    := l_line_rec.line_number;
       l_user_item_description := l_line_rec.user_item_description;
       IF l_line_rec.global_attribute_category in
          ('JL.AR.OEXOEORD.LINES',
           'JL.BR.OEXOEORD.LINES',
           'JL.CO.OEXOEORD.LINES')
       THEN
           l_trx_business_category := l_line_rec.global_attribute6;
       ELSE
           l_trx_business_category := NULL;
       END IF;

       IF l_line_rec.global_attribute_category in
          ('JL.AR.OEXOEORD.LINES',
           'JL.BR.OEXOEORD.LINES',
           'JL.CO.OEXOEORD.LINES')
       THEN
           l_product_fisc_classification := l_line_rec.global_attribute5;
       ELSE
           l_product_fisc_classification := NULL;
       END IF;

    END;

      IF l_debug_level > 0 THEN
       oe_debug_pub.add('trx business:'||l_trx_business_category,3);
     END IF;
    /* per bug 5193035:OM should not pass product_type, otherwise other product category etc won't default*/
   l_product_type := NULL;
   /*
    BEGIN
      -- for getting product_type
      SELECT classification_code
        INTO l_product_type
        FROM zx_product_types_def_v
       WHERE org_id = l_inventory_org_id
         AND inventory_item_id = l_line_rec.inventory_item_id;
     IF l_debug_level > 0 THEN
       oe_debug_pub.add('product type:'||l_product_type,3);
     END IF;
    EXCEPTION
     WHEN OTHERS THEN
      NULL;
    END;
    */
    -- bug 4622791
    IF (l_ship_from_org_id IS NOT NULL
       AND l_ship_from_org_id <> FND_API.G_MISS_NUM)
    THEN
      BEGIN
        SELECT location_id
        INTO l_ship_from_location_id
        FROM hr_all_organization_units hu
        WHERE hu.organization_id = l_ship_from_org_id;
      EXCEPTION
       WHEN OTHERS THEN
         NULL;
      END;
    END IF;

    -- bug 5061910: pass l_poo_party_id poa_party_id
    IF l_line_rec.salesrep_id IS NOT NULL THEN

     IF NOT (OE_GLOBALS.Equal(l_line_rec.salesrep_id, G_SALESREP_ID) AND
             OE_Globals.Equal(l_header_org_id, G_SALESREP_POA_ID)) THEN
         -- fetch and cache salerep info
      BEGIN

       G_SALESREP_ID := l_line_rec.salesrep_id;
       G_SALESREP_POA_ID := l_header_org_id;

       IF l_debug_level > 0 then
        oe_debug_pub.add('om_tax_line, need to query  poo for salesrep'||l_line_rec.salesrep_id , 4);
       END IF;

         SELECT ASGN.ORGANIZATION_ID
            , hou.location_id
         INTO l_poo_party_id
           , l_poo_location_id
         FROM  RA_SALESREPS_ALL sales
            ,  PER_ALL_ASSIGNMENTS_F ASGN
            , hr_organization_units hou
         WHERE ASGN.PERSON_ID = sales.PERSON_ID
         AND sales.salesrep_id = l_line_rec.salesrep_id
         AND sales.org_id = l_header_org_id
         AND  NVL(ASGN.PRIMARY_FLAG, 'Y') = 'Y'
         AND hou.organization_id = ASGN.ORGANIZATION_ID
         AND    l_TAX_DATE
            BETWEEN nvl(ASGN.EFFECTIVE_START_DATE,TO_DATE( '01011900'
             , 'DDMMYYYY'))
            AND nvl(ASGN.EFFECTIVE_END_DATE,TO_DATE( '31122199', 'DDMMYYYY'))
         AND ASSIGNMENT_TYPE = 'E';

       G_POO_PARTY_ID := l_poo_party_id;
       G_POO_LOCATION_ID := l_poo_location_id;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          IF l_debug_level > 0 then
           oe_debug_pub.add('om_tax_line  9' , 1);
          END IF;

              G_POO_PARTY_ID := NULL;
              G_POO_LOCATION_ID := NULL;
      END;
    ELSE -- get cached values

       IF l_debug_level > 0 then
        oe_debug_pub.add('om_tax_line  getting poo from cache for salesrep:'||l_line_rec.salesrep_id , 4);
       END IF;

       l_poo_party_id := G_POO_PARTY_ID;
       l_poo_location_id := G_POO_LOCATION_ID;

    END IF; -- if cached

  END IF; -- if p_salerep_id is not null

--bug7228640
begin
	select location_id
	into l_bill_from_location_id
	from HR_ALL_ORGANIZATION_UNITS
	where organization_id = p_header_rec.org_id ;
Exception
	when others then
	l_bill_from_location_id := NULL;
End;


IF l_debug_level > 0 then
 oe_debug_pub.add('om_tax_line  13' , 4);
 oe_debug_pub.add('l_poo_party_id: '|| l_poo_party_id , 4);
END IF;

    l_legal_entity_id := get_le_id(p_order_type_id => p_header_rec.order_type_id
                                 , p_sold_to_customer_id => p_header_rec.sold_to_org_id
                                 , p_bill_to_customer_id => l_bill_to_customer_id
                                 , p_org_id         => p_header_rec.org_id
                                  );

    if l_legal_entity_id = -1 THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

       i:= 1;
       zx_global_structures_pkg.init_trx_line_dist_tbl(i);
       zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID(i)	:= 660;
       zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE(i)	:= 'OE_ORDER_HEADERS';
       zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE(i)	:= 'SALES_TRANSACTION_TAX_QUOTE';
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID(i)		:= L_HEADER_ID;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE(i)	:= 'LINE';

       zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(i)          := p_header_rec.org_id;
       zx_global_structures_pkg.trx_line_dist_tbl.EVENT_TYPE_CODE(i)                   := 'CREATE';
       -- bug 4700796
       IF p_header_rec.transaction_phase_code = 'N' THEN
         l_trx_date := p_header_rec.quote_date;
       ELSE
         l_trx_date := p_header_rec.ordered_date;
       END IF;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_DATE(i)               := l_trx_date;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_DOC_REVISION(i)                  := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.LEDGER_ID(i)                         := l_AR_Sys_Param_Rec.set_of_books_id;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_CURRENCY_CODE(i)                 := p_header_rec.TRANSACTIONAL_CURR_CODE;
       zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(i)          := p_header_rec.CONVERSION_RATE_DATE;
       zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(i)          := p_header_rec.CONVERSION_RATE;
       zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(i)          := p_header_rec.CONVERSION_TYPE_CODE;
       zx_global_structures_pkg.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(i)          := l_minimum_accountable_unit;
       zx_global_structures_pkg.trx_line_dist_tbl.PRECISION(i)                         := l_precision;
   -- revisit the logic to derive legal_entity_id later when legal_entity_id approach is clarified.
       zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(i)                   := l_legal_entity_id; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.ESTABLISHMENT_ID(i)                  := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(i)           := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_NUMBER(i)                        := p_header_Rec.order_number;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_DESCRIPTION(i)                   := NULL; --   VARCHAR2_240_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_COMMUNICATED_DATE(i)             := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.BATCH_SOURCE_ID(i)                   := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.BATCH_SOURCE_NAME(i)                 := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_ID(i)                        := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_NAME(i)                      := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_VALUE(i)                     := NULL; --   VARCHAR2_240_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_DUE_DATE(i)                      := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_TYPE_DESCRIPTION(i)              := NULL; --   VARCHAR2_240_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.FIRST_PTY_ORG_ID(i)                  := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.RECEIVABLES_TRX_TYPE_ID(i)           := l_cust_trx_type_id;
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(i)              := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE(i)               := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOC_EVENT_STATUS(i)                  := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(i)                 := NULL; --   VARCHAR2_240_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_NUMBER(i)       := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_DATE(i)         := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_EXCHANGE_RATE(i)            := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_DATE(i)                  := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_NUMBER(i)                := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.QUOTE_FLAG(i)                        := 'Y'; --   VARCHAR2_1_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(i)          := NULL; --   VARCHAR2_2_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(i)             := NULL; --   VARCHAR2_1_tbl_type    ,
       zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(i)             := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.PORT_OF_ENTRY_CODE(i)                := NULL; --   VARCHAR2_30_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_REPORTING_FLAG(i)                := 'N'; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG(i)             := NULL; --   VARCHAR2_1_tbl_type ,
       zx_global_structures_pkg.trx_line_dist_tbl.COMPOUNDING_TAX_FLAG(i)              := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(i)     := NULL; --   DATE_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.INSERT_UPDATE_FLAG(i)                := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_NUMBER(i)             := NULL; --   VARCHAR2_150_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.START_EXPENSE_DATE(i)                := NULL; --   DATE_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_BATCH_ID(i)                      := NULL; --   NUMBER_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.RECORD_TYPE_CODE(i)                  := NULL; --   VARCHAR2_30_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_PROCESSING_COMPLETED_FLAG(i)     := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_DOC_STATUS(i)            := NULL; --   VARCHAR2_30_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.OVERRIDING_RECOVERY_RATE(i)          := NULL; --   NUMBER_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_CALCULATION_DONE_FLAG(i)         := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG(i)         := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.ICX_SESSION_ID(i)                    := NULL; --   NUMBER_tbl_type
       -- line level columns
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CODE(i)            := NULL; --   VARCHAR2_15_tbl_type   ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_DATE(i)       := NULL; --   DATE_tbl_type          ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_RATE(i)       := NULL; --   NUMBER_tbl_type        ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_TYPE(i)       := NULL; --   VARCHAR2_30_tbl_type   ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_MAU(i)                      := NULL; --   NUMBER_tbl_type        ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_PRECISION(i)                := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE(i)                 := NULL; --   VARCHAR2_240_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(i)     := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG(i)            := l_line_rec.TAX_EXEMPT_FLAG;
       zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_REASON_CODE(i)                := l_line_rec.TAX_EXEMPT_REASON_CODE;
       zx_global_structures_pkg.trx_line_dist_tbl.INTERFACE_ENTITY_CODE(i)             := NULL; --   VARCHAR2_30_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.INTERFACE_LINE_ID(i)                 := NULL; --   NUMBER_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_TAX_CODE_ID(i)            := NULL; --   NUMBER_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID(i)	:= l_line_rec.line_id;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_CLASS(i)	        := 'INVOICE';
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(i)	:= 'CREATE';
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_SHIPPING_DATE(i)	:= l_trx_shipping_date;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_RECEIPT_DATE(i)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_TYPE(i)	:= 'LINE';
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DATE(i)	:= l_tax_date;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(i)	:= l_trx_business_category;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(i)	:= 'S';
       --8431420 zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT(i)	:= l_ordered_quantity*l_unit_selling_price;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT(i)   := ROUND(l_ordered_quantity*l_unit_selling_price,OE_ORDER_UTIL.G_Precision); --8431420
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_QUANTITY(i)	:= l_ordered_quantity;
       zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(i)	:= l_unit_selling_price;
       zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER(i)	:= l_tax_exempt_number;
       zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_REASON(i)	:= l_tax_exempt_reason;
       zx_global_structures_pkg.trx_line_dist_tbl.CASH_DISCOUNT(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.VOLUME_DISCOUNT(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_DISCOUNT(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRANSFER_CHARGE(i)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.TRANSPORTATION_CHARGE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.INSURANCE_CHARGE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OTHER_CHARGE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ID(i)	:= l_inventory_item_id;
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(i):= l_product_fisc_classification;
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ORG_ID(i)	:= NVL(l_ship_from_org_id,l_inventory_org_id); --bug7456264
       zx_global_structures_pkg.trx_line_dist_tbl.UOM_CODE(i)		:= l_uom_code;
       if l_inventory_item_id is NULL then
          zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE(i)	:= NULL;
       else
         -- this should be GOODS/SERVICES based on zx_product_types_def_v.
         -- to be changed when zx_product_types_def_v is available.
          zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE(i)	:= l_product_type;
       end if;
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CODE(i)	:= l_product_code;
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CATEGORY(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_SIC_CODE(i)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.FOB_POINT(i)		:= l_fob_point_code;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_ID(i)	:= l_ship_party_id; --1001;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_ID(i):= l_ship_from_org_id; -- Bug 7532302
       zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_ID(i)	:= l_header_org_id;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_ID(i)	:= l_poo_party_id;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_ID(i)	:= l_bill_party_id; --1001;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_ID(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID(i)	:= l_ship_party_site_id;--1024;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_SITE_ID(i)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_SITE_ID(i)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID(i)	:= l_bill_party_site_id; --1024;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(i)	:= l_ship_location_id;--1067;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(i)	:= l_ship_from_location_id;
       zx_global_structures_pkg.trx_line_dist_tbl.POA_LOCATION_ID(i)		:= l_internal_org_location_id;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_LOCATION_ID(i)		:= l_poo_location_id ;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_LOCATION_ID(i)	:= l_bill_location_id;--1067;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(i)	:= l_bill_from_location_id; --bug7228640
       zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_CCID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_STRING(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_FLAG(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_NUMBER(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_TYPE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_COST(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_LEVEL_ACTION(i)           := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TAX_DIST_ID(i)    := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TAX_DIST_ID(i)    := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.TASK_ID(i)                     := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.AWARD_ID(i)                    := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.PROJECT_ID(i)                  := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_TYPE(i)            := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_ORGANIZATION_ID(i) := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_ITEM_DATE(i)       := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_AMT(i)           := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_QUANTITY(i)      := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_CURR_CONV_RATE(i)      := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.ITEM_DIST_NUMBER(i)            := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_DIST_ID(i)             := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_TAX_AMT(i)       := NULL; --   NUMBER_tbl_type        ,

       zx_global_structures_pkg.trx_line_dist_tbl.ASSESSABLE_VALUE(i)		:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(i)	:= l_tax_code;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY1(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY2(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY3(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY4(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY5(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY6(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_NUMBER(i)   := l_trx_line_number;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_ID(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY1(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY2(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY3(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY4(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY5(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY6(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_FLAG(i)	:='N';
       zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(i)	:='N';
       zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT(i)	:=NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DESCRIPTION(i)	:= substrb(l_user_item_description,1,240); --bug9293783
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_DESCRIPTION(i)	:= substrb(l_user_item_description,1,240); --bug9293783
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_WAYBILL_NUMBER(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_GL_DATE(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_NAME(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_SITE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_SITE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_SITE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_SITE_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_SITE_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_SITE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_LOCATION_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_LOCATION_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POC_LOCATION_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_LOCATION_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_LOCATION_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID(i):= NULL;
       -- Rounding parties not required for OM. No override of rounding level
       zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(i):= NULL;

       -- Ref_doc, applied_from, applied_to, related_doc are not applicable for OM
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_APPLICATION_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_ENTITY_CODE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY1(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY2(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY3(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY4(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY5(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY6(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_LINE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY1(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY2(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY3(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY4(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY5(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY6(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_DIST_ID(i)      := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY1(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY2(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY3(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY4(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY5(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY6(i) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(i)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DIST_ID(i)       := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY1(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY2(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY3(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY4(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY5(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY6(i)     := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE(i)     := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_TRX_ID(i)          := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY1(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY2(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY3(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY4(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY5(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY6(i)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_NUMBER(i)          := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_DATE(i)            := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_APPLN_ID(i)           := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_ENTITY_CODE(i)        := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_EVNT_CLS_CODE(i)      := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_ID(i)             := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_LEVEL_TYPE(i)     := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_LINE_ID(i)        := NULL;

       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC7(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC8(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC9(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC10(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR7(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR8(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR9(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR10(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE1(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE7(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE8(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE9(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE10(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.internal_org_location_id(i) := l_internal_org_location_id;
     /*
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POA_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID(i)    := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID(i)    := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID(i)    := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID(i)    := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID(i)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(i)      := NULL;

     */
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_APPLICATION_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_ENTITY_CODE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_LINE_ID(i)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(i):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1(i)	:= 'N';
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TAX_LINE_ID(i)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(i)	:= NULL;

	zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(i)	:= l_SHIP_TO_ADDRESS_ID;--1024;
	zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(i)	:= l_BILL_TO_ADDRESS_ID;--1024;
	zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(i)	:= l_SHIP_TO_SITE_USE_ID;--1007;
	zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(i)	:= l_BILL_TO_SITE_USE_ID;--1006;
	zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID(i)		:= l_SHIP_TO_CUSTOMER_ID;--1001;
	zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID(i)		:= l_BILL_TO_CUSTOMER_ID;--1001;

  IF l_debug_level > 0 THEN
    debug_msg(i, x_return_status);
 		null;
  END IF;

  l_line_rec.tax_value := l_tax_value;

  IF ( NOT ( l_line_rec.header_id is null OR
             l_line_rec.inventory_item_id is null OR
             --p_ship_to_org_id is null OR   /*commented for the bug#3336052*/
             l_line_rec.unit_selling_price is null)
           -- OR
            -- l_line_rec.tax_code is null)
           )
  THEN


    IF l_debug_level > 0 THEN
 	oe_debug_pub.add('tax_line 11' , 1);
    END IF;

    l_call_tax := 'Y';

      l_transaction_rec.application_id := 660;
      l_transaction_rec.entity_code := 'OE_ORDER_HEADERS';
      l_transaction_rec.event_class_code := 'SALES_TRANSACTION_TAX_QUOTE';
      l_transaction_rec.event_type_code := 'CREATE';
      l_transaction_rec.trx_id := l_line_rec.header_id;
      l_transaction_rec.internal_organization_id := l_line_rec.org_id;

       zx_api_pub.calculate_tax(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_TRUE,
                        p_commit           => NULL,
                        p_validation_level => NULL,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data,
                        p_transaction_rec => l_transaction_rec,
                        p_quote_flag  => 'Y',
                        p_data_transfer_mode => 'PLS',
                        x_doc_level_recalc_flag => l_doc_level_recalc_flag);

          IF l_debug_level > 0 THEN
             oe_debug_pub.add('Message returned by tax API ZX_API_PUB.calculate_tax: '||l_msg_count,2);
          END IF;

          IF l_msg_count = 1 THEN
	       --there is one message raised by the API
           IF l_debug_level > 0 THEN
             oe_debug_pub.add(l_msg_data,2);
           END IF;

           IF l_msg_data is not null then
  	     FND_MESSAGE.SET_NAME('ONT','ONT_AVAIL_GENERIC');
	     FND_MESSAGE.SET_TOKEN('TEXT',l_msg_data);
	     OE_MSG_PUB.Add;
           ELSE
	     OE_MSG_PUB.Add_text('Tax engine call raised Error ' );  --For bug # 4206796
 	   END IF;

	  ELSIF l_msg_count > 1 THEN
	     LOOP
	       l_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
	       IF l_msg_data is null then
                 IF l_debug_level > 0 THEN
	              oe_debug_pub.add('msg data is null',2);
 	         END IF;
	         EXIT;
	       ELSE
	          IF l_debug_level > 0 THEN
	              oe_debug_pub.add(l_msg_data,2);
 	          END IF;
       	          FND_MESSAGE.SET_NAME('ONT','ONT_AVAIL_GENERIC');
                  FND_MESSAGE.SET_TOKEN('TEXT',l_msg_data);
	          OE_MSG_PUB.Add;
  	       END IF;
	     END LOOP;
         END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level > 0 THEN
      	    oe_debug_pub.add('tax engine call returned unexp error',1);
           END IF;
           x_return_status := l_return_status; -- nocopy related change
           RETURN;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level > 0 THEN
      	    oe_debug_pub.add('tax engine call returned error',1);
           END IF;
           x_return_status := l_return_status; -- nocopy related change
           RETURN;
        ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
           IF l_debug_level > 0 THEN
      	    oe_debug_pub.add('tax engine call returned successfully',1);
           END IF;
           x_return_status := l_return_status; -- nocopy related change

        END IF;

 END IF; /* IF inventory_item_id is not null */


/*    i:=0;
    open detail_tax_lines_gt(l_line_rec.header_id, l_line_rec.line_id);
    fetch detail_tax_lines_gt into detail_tax_lines_gt_rec;
    loop
       exit when detail_tax_lines_gt%NOTFOUND;*/
    i := 1;
    for detail_tax_lines_gt_rec in detail_tax_lines_gt(l_line_rec.header_id, l_line_rec.line_id) loop

       x_tax_out_tbl(i).tax_amount := detail_tax_lines_gt_rec.tax_amt;
       x_tax_out_tbl(i).taxable_amount := detail_tax_lines_gt_rec.taxable_amt;
       x_tax_out_tbl(i).tax_rate_id := detail_tax_lines_gt_rec.tax_rate_id;
       x_tax_out_tbl(i).tax_rate := detail_tax_lines_gt_rec.tax_rate;
       x_tax_out_tbl(i).trx_line_id := detail_tax_lines_gt_rec.trx_line_id;
       x_tax_out_tbl(i).amount_includes_tax_flag := detail_tax_lines_gt_rec.tax_amt_included_flag;

        IF l_debug_level > 0 THEN
          oe_debug_pub.add('tax amount, taxable amount  ' || i || ' : ' || x_tax_out_tbl(i).tax_amount || ';' || x_tax_out_tbl(i).taxable_amount);
        END IF;

       if ( nvl( x_tax_out_tbl(i).amount_includes_tax_flag, 'N' ) <> 'Y'
           and x_tax_out_tbl(i).trx_line_id = l_line_rec.line_id )  then

         l_tax_value := l_tax_value + nvl(x_tax_out_tbl(i).tax_amount,0);

       end if;
      i := i + 1;
    end loop;

    IF l_debug_level > 0 THEN
    	oe_debug_pub.add('tax amount after excluding inclusive tax : ' || l_tax_value);
    END IF;

   x_tax_value := l_tax_value;


  IF l_debug_level > 0 THEN
   oe_debug_pub.add('tax_line 12' , 1);
   oe_debug_pub.add('success - tax call success ' , 1);
   oe_debug_pub.add('exiting tax_line' , 1);
  END IF;

  x_return_status := l_return_status;

  IF l_call_tax = 'N' then
    x_return_status := 'N';
  END IF;

 EXCEPTION

   WHEN NO_DATA_FOUND THEN
	  x_return_status  := FND_API.G_RET_STS_SUCCESS;

   WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   'OM_TAX_UTIL'          ,
                'Tax_Line'
            );
        END IF;

   IF l_debug_level > 0 THEN
    oe_debug_pub.add('some error occurred  ' || sqlerrm , 1);
   END IF;
   	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    --dbms_output.put_line('some error occurred  ' || sqlerrm  );

 END TAX_LINE;

-- added for bug 1406890
PROCEDURE CALCULATE_TAX(p_header_id IN NUMBER
                       ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2) AS

l_index			NUMBER := 1;
l_entity_id_tbl         OE_Delayed_Requests_PVT.Entity_Id_Tbl_Type;
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

TYPE num_tbl is TABLE OF NUMBER;
l_num_tbl num_tbl := num_tbl();

CURSOR order_line_cur IS
SELECT line_id
FROM   oe_order_lines_all
WHERE  header_id = p_header_id;

BEGIN
  -- performance bug 4255597
  OPEN order_line_cur;
  FETCH order_line_cur BULK COLLECT INTO l_num_tbl;
  CLOSE order_line_cur;

  FOR i in 1..l_num_tbl.count LOOP
    l_entity_id_tbl(i).request_ind := i;
    l_entity_id_tbl(i).entity_id := l_num_tbl(i);
  END LOOP;

  OE_Delayed_Requests_UTIL.Process_Tax
   ( p_Entity_id_tbl      => l_entity_id_tbl
    ,x_return_status     => l_return_status
    );

  x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   'OM_TAX_UTIL'          ,
                'Calculate_Tax'
            );
      END IF;

      IF l_debug_level > 0 THEN
       oe_debug_pub.add('some error occurred  ' || sqlerrm , 1);
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CALCULATE_TAX;


Procedure Debug_msg(p_index         IN  NUMBER,
		    x_return_status OUT NOCOPY Varchar2) IS

i	NUMBER;
Begin
        i:=p_index;
	IF i IS NOT NULL
	   AND zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID.exists(I)
THEN
        oe_debug_pub.add('Entering OM_TAX_UTIL.Debug_msg procedure ');
        oe_debug_pub.add(' i = '||i);
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_CLASS(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_CLASS(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_SHIPPING_DATE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_SHIPPING_DATE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_RECEIPT_DATE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_RECEIPT_DATE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DATE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DATE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_QUANTITY(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_QUANTITY(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_REASON(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_REASON(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CASH_DISCOUNT(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CASH_DISCOUNT(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.VOLUME_DISCOUNT(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.VOLUME_DISCOUNT(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRADING_DISCOUNT(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRADING_DISCOUNT(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRANSFER_CHARGE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRANSFER_CHARGE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRANSPORTATION_CHARGE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRANSPORTATION_CHARGE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.INSURANCE_CHARGE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.INSURANCE_CHARGE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.OTHER_CHARGE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.OTHER_CHARGE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ORG_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ORG_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.UOM_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.UOM_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CATEGORY(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CATEGORY(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_SIC_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_SIC_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.FOB_POINT(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.FOB_POINT(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POA_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POA_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POO_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POO_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_CCID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_CCID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_STRING(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_STRING(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_APPLICATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_APPLICATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_ENTITY_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_ENTITY_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_LINE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_LINE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ASSESSABLE_VALUE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ASSESSABLE_VALUE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_NUMBER(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_NUMBER(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_FLAG(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_FLAG(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DESCRIPTION(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DESCRIPTION(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_DESCRIPTION(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_DESCRIPTION(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_WAYBILL_NUMBER(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_WAYBILL_NUMBER(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_GL_DATE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_GL_DATE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_NAME(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_NAME(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PAYING_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PAYING_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POC_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POC_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POI_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POI_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POD_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POD_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ASSET_FLAG(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ASSET_FLAG(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ASSET_NUMBER(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ASSET_NUMBER(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ASSET_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ASSET_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ASSET_COST(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ASSET_COST(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC7(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC7(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC8(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC8(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC9(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC9(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC10(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC10(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR7(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR7(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR8(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR8(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR9(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR9(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.CHAR10(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.CHAR10(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE7(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE7(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE8(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE8(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE9(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE9(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DATE10(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DATE10(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POA_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POA_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POO_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POO_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POI_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POI_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.POD_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.POD_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID(i));

	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_APPLICATION_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_APPLICATION_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_ENTITY_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_ENTITY_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_LINE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_LINE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TAX_LINE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TAX_LINE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(i));

	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID(i));
	oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID(i)= '||zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID(i));
        oe_debug_pub.add(' zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(i)= '||
                                   zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(i),3);
        oe_debug_pub.add('Exiting OM_TAX_UTIL.Debug_msg procedure ');
ELSE
	oe_debug_pub.add(' Index:'||i||' not avail for debug');
END IF;
End Debug_msg ;

Function get_le_id(p_order_type_id NUMBER
                  , p_sold_to_customer_id NUMBER
                  , p_bill_to_customer_id NUMBER
                  , p_org_id NUMBER
) RETURN NUMBER IS

l_invoice_source_id	NUMBER;
l_invoice_source	VARCHAR2(50);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_order_type_rec  OE_ORDER_CACHE.ORDER_TYPE_REC_TYPE;
 l_customer_type      		VARCHAR2(30);
 l_customer_id        		NUMBER;
 l_batch_source_id		NUMBER;
 l_sold_to_customer_id		NUMBER;
l_cust_trx_type_id              NUMBER;
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_legal_entity_id NUMBER;
l_msg_data                     VARCHAR2(1000);
BEGIN

      IF p_sold_to_customer_id IS NOT NULL THEN
        l_customer_type := 'SOLD_TO';
        l_customer_id := p_sold_to_customer_id;
      ELSIF p_bill_to_customer_id IS NOT NULL THEN
        l_customer_type := 'BILL_TO';
        l_customer_id := p_bill_to_customer_id;
      END IF;

     IF l_debug_level > 0 THEN
       oe_debug_pub.add('l_customer_type:'||l_customer_type, 3);
       oe_debug_pub.add('l_customer_id:'||l_customer_id, 3);
     END IF;

     l_order_type_rec := OE_ORDER_CACHE.Load_Order_Type(p_order_type_id);
     l_invoice_source_id := l_order_type_rec.invoice_source_id;
     l_cust_trx_type_id := l_order_type_rec.cust_trx_type_id;

     IF l_invoice_source_id IS NOT NULL THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INVOICE SOURCE ID IS ( 3 ) : '||L_INVOICE_SOURCE_ID , 5 ) ;
        END IF;
     ELSE
        l_invoice_source := oe_sys_parameters.value('INVOICE_SOURCE', p_org_id);

                   IF (l_invoice_source IS NOT NULL) THEN
		   SELECT batch_source_id
		     INTO l_invoice_source_id
		     FROM ra_batch_sources
		    WHERE name = l_invoice_source;

                   END IF;

		   IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  'INVOICE_SOURCE_ID IS ( 4 ) : '||L_INVOICE_SOURCE_ID , 5 ) ;
		   END IF;
    END IF;

    IF l_cust_trx_type_id IS NULL THEN
          l_cust_trx_type_id := oe_sys_parameters.value('OE_INVOICE_TRANSACTION_TYPE_ID',p_org_id);
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CUSTOMER TRANSACTION TYPE ID FROM sys parameter : '||L_CUST_TRX_TYPE_ID , 5 ) ;
          END IF;
   END IF;

   IF l_debug_level > 0 THEN
       oe_debug_pub.add('customer type:'||l_customer_type,3);
       oe_debug_pub.add('customer id:'||l_customer_id,3);
       oe_debug_pub.add('ar trx type:'||l_cust_trx_type_id,3);
       oe_debug_pub.add('batch source:'||l_invoice_source_id,3);
       oe_debug_pub.add('OU:'||p_org_id,3);
   END IF;

   l_legal_entity_id := XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info(
     x_return_status => l_return_status,		-- OUT
     x_msg_data => l_msg_data,		-- OUT
     p_customer_type => l_customer_type,		-- IN	P_customer_type
     p_customer_id => l_customer_id, 		-- IN	P_customer_id (sold_to/bill_to customer_id)
     p_transaction_type_id => l_cust_trx_type_id,	-- IN	P_transaction_type_id
     p_batch_source_id => l_invoice_source_id,		-- IN	P_batch_source_id
     p_operating_unit_id => p_org_id 	-- IN	P_operating_unit_id (org_id)
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_legal_entity_id = -1 THEN

        IF l_debug_level > 0 THEN
   	    oe_debug_pub.add('In getting legal_entity_id, return status error'||l_msg_data);
        END IF;
           IF l_msg_data is not null then
  	     FND_MESSAGE.SET_NAME('ONT','ONT_AVAIL_GENERIC');
	     FND_MESSAGE.SET_TOKEN('TEXT',l_msg_data);
	     OE_MSG_PUB.Add;
           ELSE
	     OE_MSG_PUB.Add_text('XLE call raised Error ' );  --For bug # 4206796
 	   END IF;
         RETURN -1;
     END IF;

     IF l_debug_level > 0 THEN
   	oe_debug_pub.add('legal_entity_id is '||l_legal_entity_id);
     END IF;

     RETURN l_legal_entity_id;
  EXCEPTION
      WHEN OTHERS THEN

      	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'Error getting legal_entity_id'||sqlerrm);
	END IF;
      RETURN -1;
END get_le_id;

/* ==============================================================+
 * FUNCTION Get_Content_Owner_Id
 *
 * Description:
 *  Created for R12  Vertext project called from oip and sales order form
 *  Function Get_Content_Owner_Id
 *  is calling  APIs : XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info
 *  and ZX_TCM_PTP_PKG.get_tax_subscriber to get content_owner_id
 *================================================================*/

FUNCTION Get_Content_Owner_Id(
p_header_id          IN  NUMBER)
RETURN  NUMBER
IS

l_org_id               NUMBER;
l_le_id                NUMBER;
l_conten_owner_id      NUMBER;
l_return_status        VARCHAR2(1);
l_msg_data             VARCHAR2(1000);
l_sold_to_customer_id  NUMBER;
l_bill_to_customer_id          NUMBER;
l_invoice_to_org_id NUMBER;
l_order_type_id        NUMBER;
l_batch_source_id      NUMBER;
l_otoc_Le_info         XLE_BUSINESSINFO_GRP.otoc_le_rec;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN


  SELECT org_id
        ,SOLD_TO_ORG_ID
        ,INVOICE_TO_ORG_ID
        ,ORDER_TYPE_ID
  INTO l_org_id
      ,l_sold_to_customer_id
      ,l_invoice_to_org_id
      ,l_order_type_id
  FROM oe_order_headers_all
  WHERE header_id = p_header_id;

  IF (l_invoice_to_org_id IS NOT NULL) THEN
    SELECT acct_site.cust_account_id
    INTO l_bill_to_customer_id
    FROM HZ_CUST_SITE_USES_ALL         site_use ,
       HZ_CUST_ACCT_SITES_ALL      acct_site
    WHERE site_use.site_use_id = l_invoice_to_org_id
    AND   site_use.cust_acct_site_id = acct_site.cust_acct_site_id;
  END IF;

  l_le_id := Get_Le_Id(p_order_type_id => l_order_type_id
            , p_sold_to_customer_id => l_sold_to_customer_id
            , p_bill_to_customer_id => l_bill_to_customer_id
            , p_org_id      => l_org_id);


    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Get_le_id: '||l_le_id, 2) ;
    END IF;



  -- Call ZX_TCM_PTP_PKG.get_tax_subscriber
  -- to get conten_owner_id

  ZX_TCM_PTP_PKG.get_tax_subscriber(
                 p_le_id   => l_le_id
                ,p_org_id  => l_org_id
                ,p_ptp_id  => l_conten_owner_id
                ,p_return_status => l_return_status);

  IF l_return_status = 'S' THEN
     return l_conten_owner_id ;
  ELSE
     IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Return Status from ZX_TCM_PTP_PKG.get_tax_subscriber '||l_return_status, 1) ;
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
WHEN OTHERS THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   'OM_TAX_UTIL'
            ,  'Get_Content_Owner_Id'
            );
         RETURN -99;

END Get_Content_Owner_Id;


END OM_TAX_UTIL;

/
