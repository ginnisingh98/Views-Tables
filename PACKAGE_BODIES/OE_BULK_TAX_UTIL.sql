--------------------------------------------------------
--  DDL for Package Body OE_BULK_TAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_TAX_UTIL" AS
/* $Header: OEBUTAXB.pls 120.0.12010000.7 2009/01/21 13:02:12 smanian noship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):= 'OE_BULK_TAX_UTIL';

Procedure Debug_msg(p_index         IN  NUMBER,
		    x_return_status OUT NOCOPY Varchar2) ;


Function get_le_id(p_order_type_id NUMBER
                  , p_sold_to_customer_id NUMBER
                  , p_bill_to_customer_id NUMBER
                  , p_org_id NUMBER
) RETURN NUMBER IS

l_invoice_source_id     NUMBER;
l_invoice_source        VARCHAR2(50);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_order_type_rec  OE_ORDER_CACHE.ORDER_TYPE_REC_TYPE;
 l_customer_type                VARCHAR2(30);
 l_customer_id                  NUMBER;
 l_batch_source_id              NUMBER;
 l_sold_to_customer_id          NUMBER;
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
     x_return_status => l_return_status,                -- OUT
     x_msg_data => l_msg_data,          -- OUT
     p_customer_type => l_customer_type,                -- IN   P_customer_type
     p_customer_id => l_customer_id,            -- IN   P_customer_id (sold_to/bill_to customer_id)
     p_transaction_type_id => l_cust_trx_type_id,       -- IN   P_transaction_type_id
     p_batch_source_id => l_invoice_source_id,          -- IN   P_batch_source_id
     p_operating_unit_id => p_org_id    -- IN   P_operating_unit_id (org_id)
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

PROCEDURE Get_Default_Tax_Code
IS
l_index                   NUMBER;
l_header_index            NUMBER;
l_index_inc               NUMBER;
l_error_inc               NUMBER;
l_remaining_lines         NUMBER;
x_tax_code                VARCHAR2(50);
x_vat_tax_id	          NUMBER;
x_amt_incl_tax_flag       VARCHAR2(1);
x_amt_incl_tax_override   VARCHAR2(1);


l_AR_Sys_Param_Rec       AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
l_sob_id                 NUMBER;
l_dummy                  VARCHAR2(10);
l_start_time             NUMBER;
l_end_time               NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_BULK_TAX_UTIL.GET_DEFAULT_TAX_CODE' ) ;
  END IF;
  --Loop over the loaded lines to default the tax code
  l_index := 1;
  WHILE l_index <= OE_Bulk_Order_PVT.G_LINE_REC.LINE_ID.COUNT LOOP
    l_index_inc := 1;

    --IF (OE_Bulk_Order_PVT.G_LINE_REC.tax_exempt_flag(l_index) = 'R'
    --    OR
     --   OE_Bulk_Order_PVT.G_LINE_REC.tax_calculation_flag(l_index) = 'Y')
    --THEN
   --bug7685103

      l_header_index := OE_Bulk_Order_PVT.G_LINE_REC.header_index(l_index);


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'line index: ' || l_index || '   line id: '|| OE_Bulk_Order_PVT.G_LINE_REC.line_id(l_index) || '    header index: ' || l_header_index || '    header id: ' || OE_Bulk_Order_PVT.G_HEADER_REC.header_id(l_header_index));
      END IF;

      IF nvl(OE_Bulk_Order_PVT.G_HEADER_REC.lock_control(l_header_index),0) = -99
      THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'lock control set.  skipping header with header id: '|| OE_Bulk_Order_PVT.G_HEADER_REC.header_id(l_header_index));
        END IF;
        --Skip the remaining lines in this header as it is marked for error
        l_remaining_lines := OE_Bulk_Order_PVT.G_HEADER_REC.end_line_index(l_header_index) - l_index;
        l_index_inc := l_remaining_lines + 1;
      ELSE

        --default the tax_date with the following precedence:  1. schedule_ship_date, 2. request_date, 3. promise_date, 4. sysdate
        IF OE_Bulk_Order_PVT.G_LINE_REC.schedule_ship_date(l_index) IS NOT NULL
        THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'defaulting tax date from schedule ship date');
          END IF;
          OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index) := OE_Bulk_Order_PVT.G_LINE_REC.schedule_ship_date(l_index);
        ELSIF OE_Bulk_Order_PVT.G_LINE_REC.request_date(l_index) IS NOT NULL
        THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'defaulting tax date from request date');
          END IF;
          OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index) := OE_Bulk_Order_PVT.G_LINE_REC.request_date(l_index);
        ELSIF OE_Bulk_Order_PVT.G_LINE_REC.promise_date(l_index) IS NOT NULL
        THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'defaulting tax date from promise date');
          END IF;
          OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index) := OE_Bulk_Order_PVT.G_LINE_REC.promise_date(l_index);
        ELSE
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'defaulting tax date from sysdate');
          END IF;
          OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index) := sysdate;
        END IF;  --end of schedule_ship_date is not null

        --get the tax code
        IF OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index) IS NULL
        THEN

          BEGIN

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'before calling ZX_AR_TAX_CLASSIFICATN_DEF_PKG.GET_DEFAULT_TAX_CLASSIFICATION');
	      oe_debug_pub.add(  'OE_Bulk_Order_PVT.G_LINE_REC.org_id('||l_index||') :'||OE_Bulk_Order_PVT.G_LINE_REC.org_id(l_index) );
            END IF;

 SELECT hsecs INTO l_start_time from v$timer;

	ZX_AR_TAX_CLASSIFICATN_DEF_PKG.GET_DEFAULT_TAX_CLASSIFICATION
	      (     p_ship_to_site_use_id => OE_Bulk_Order_PVT.G_LINE_REC.ship_to_org_id(l_index) ,
	          p_bill_to_site_use_id => OE_Bulk_Order_PVT.G_LINE_REC.invoice_to_org_id(l_index),
	          p_inventory_item_id =>OE_Bulk_Order_PVT.G_LINE_REC.inventory_item_id(l_index) ,
	          p_organization_id     => OE_Bulk_Order_PVT.G_ITEM_ORG,
	          p_set_of_books_id     => OE_Bulk_Order_PVT.G_SOB_ID,
	          p_trx_date            => OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index),
	          p_trx_type_id         => OE_Bulk_Order_PVT.G_LINE_REC.cust_trx_type_id(l_index),
	          p_tax_classification_code => x_tax_code,
	         -- p_cust_trx_id         => l_ra_cust_trx_type_id,
	         -- p_customer_id         => nvl(l_shipment_rec.ship_to_cust_party_id,l_shipment_header_rec.ship_to_cust_party_id),
	          appl_short_name       => 'ONT',
	          p_entity_code         => 'OE_ORDER_HEADERS',
	          p_event_class_code    => 'SALES_TRANSACTION_TAX_QUOTE',
	          p_application_id      => 660,
	          p_internal_organization_id => OE_Bulk_Order_PVT.G_LINE_REC.org_id(l_index) --bug7759207
	        );




 SELECT hsecs INTO l_end_time from v$timer;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in GET_DEFAULT_TAX_CLASSIFICATION is (sec) '||((l_end_time-l_start_time)/100));

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'after calling AZX_AR_TAX_CLASSIFICATN_DEF_PKG.GET_DEFAULT_TAX_CLASSIFICATION');
              oe_debug_pub.add(  'tax code: ' || x_tax_code);
              oe_debug_pub.add(  'vat tax id: ' || x_vat_tax_id);
              oe_debug_pub.add(  'tax inclusive flag: ' || x_amt_incl_tax_flag);
              oe_debug_pub.add(  'tax inclusive override: ' || x_amt_incl_tax_override);
            END IF;

     --bug7685103
     IF x_tax_code IS NULL
         THEN

             /* Handle_Tax_Code_Error(p_index => l_index,
                                    p_header_index => l_header_index,
                                    x_index_inc => l_error_inc);

              IF l_error_inc IS NOT NULL
              THEN
              l_index_inc := l_error_inc;
              END IF;
	     */
	     NULL;

      ELSE
         OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index) := x_tax_code;
         oe_debug_pub.add(  ' Tax Code  :'|| OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index),1);
      END IF; -- tax_code IS NULL


          EXCEPTION
            WHEN OTHERS THEN

              IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'in others exception in get default tax: ' || SQLERRM);
              END IF;

	      OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index) := x_tax_code;

	      /*Handle_Tax_Code_Error(p_index => l_index,
                                    p_header_index => l_header_index,
                                    x_index_inc => l_error_inc);

              IF l_error_inc IS NOT NULL
              THEN
              l_index_inc := l_error_inc;
              END IF;*/
	      --bug7685103

          END;
        END IF;  --end of IF tax_code is NULL

 SELECT hsecs INTO l_start_time from v$timer;

   --bug7685103
   --This validation will be done in OEBLLINB.pls
   /* -- Validating Tax Information
        IF OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index) IS NOT NULL AND
           OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index) IS NOT NULL
        THEN
          BEGIN
            IF oe_code_control.code_release_level >= '110510' THEN

              l_AR_Sys_Param_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params(OE_GLOBALS.G_ORG_ID);
              l_sob_id := l_AR_Sys_Param_Rec.set_of_books_id;

              SELECT 'VALID'
              INTO   l_dummy
              FROM   AR_VAT_TAX V
              WHERE  V.TAX_CODE = OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index)
              AND V.SET_OF_BOOKS_ID = l_sob_id
              AND NVL(V.ENABLED_FLAG,'Y')='Y'
              AND NVL(V.TAX_CLASS,'O')='O'
              AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
              AND TRUNC(OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index))
              BETWEEN TRUNC(V.START_DATE) AND
              TRUNC(NVL(V.END_DATE, OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index)))
              AND ROWNUM = 1;

              ELSE

              SELECT 'VALID'
              INTO   l_dummy
              FROM   AR_VAT_TAX V,
                     AR_SYSTEM_PARAMETERS P
              WHERE  V.TAX_CODE = OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index)
              AND V.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
              AND NVL(V.ENABLED_FLAG,'Y')='Y'
              AND NVL(V.TAX_CLASS,'O')='O'
              AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
              AND TRUNC(OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index))
              BETWEEN TRUNC(V.START_DATE) AND
              TRUNC(NVL(V.END_DATE, OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index)))
              AND ROWNUM = 1;

            END IF;


 SELECT hsecs INTO l_end_time from v$timer;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent validating tax information is (sec) '||((l_end_time-l_start_time)/100));

          EXCEPTION
            WHEN OTHERS THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OTHERS WHEN VALIDATING TAX CODE ' || SQLERRM ) ;
              END IF;
              fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Entity: Tax Code');
              OE_BULK_MSG_PUB.Add('Y','ERROR');

              Handle_Tax_Code_Error(p_index => l_index,
                                    p_header_index => l_header_index,
                                    x_index_inc => l_error_inc);

              IF l_error_inc IS NOT NULL
              THEN
              l_index_inc := l_error_inc;
              END IF;

          END; -- BEGIN
        END IF;

*/

    END IF;  -- end of IF lock_control = -99

    --END IF;  -- end of IF tax_exempt_flag = R or tax_calculation_flag = Y

    l_index := l_index + l_index_inc;
  END LOOP;


IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'EXITING OE_BULK_TAX_UTIL.GET_DEFAULT_TAX_CODE' ) ;
END IF;

 EXCEPTION
  WHEN OTHERS THEN

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'in others exception: ' || SQLERRM);
  END IF;

  IF OE_BULK_MSG_PUB.check_msg_level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_BULK_MSG_PUB.add_exc_msg
    (G_PKG_NAME
    ,'Get_Default_Tax_Code'
    );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Default_Tax_Code;


PROCEDURE Calculate_Tax
          (p_post_insert            IN    BOOLEAN
          )
IS



-- 11510
l_index                   NUMBER;
l_header_index            NUMBER;
l_index_inc               NUMBER;
l_tax_index               NUMBER;
l_header_id               NUMBER;
l_line_id                 NUMBER;
l_order_type_cache_key    NUMBER;
l_remaining_lines         NUMBER;
l_tax_code_cache_key      NUMBER;
l_ship_to_cache_key       NUMBER;
l_invoice_to_cache_key    NUMBER;
l_asgn_org_id             NUMBER;
l_salesrep_cache_key      NUMBER;
l_person_id               NUMBER;
l_tax_method              VARCHAR2(30);
l_vendor_installed        VARCHAR2(1);
l_AR_Sys_Param_Rec	  AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
l_bill_to_cust_id         NUMBER;
l_bill_to_location_id     NUMBER;
l_bill_to_cust_acct_site_id    NUMBER;
l_bill_to_cust_account_id      NUMBER;
l_bill_to_account_number       VARCHAR2(30);
l_bill_su_tax_hdr_flag  VARCHAR2(1);
l_bill_acct_tax_hdr_flag  VARCHAR2(1);
l_bill_to_su_tax_rnd_rule        VARCHAR2(30);
l_bill_to_acct_tax_rnd_rule      VARCHAR2(30);
l_bill_to_state           VARCHAR2(60);
l_bill_to_party_name      VARCHAR2(360);
l_ship_to_cust_id         NUMBER;
l_ship_to_location_id     NUMBER;
l_ship_to_state           VARCHAR2(60);
l_ship_to_cust_acct_site_id    NUMBER;
l_ship_to_cust_account_id      NUMBER;
l_ship_to_account_number  VARCHAR2(30);
l_ship_to_party_name      VARCHAR2(360);
l_ship_su_tax_hdr_flag  VARCHAR2(1);
l_ship_acct_tax_hdr_flag  VARCHAR2(1);
l_ship_to_su_tax_rnd_rule        VARCHAR2(30);
l_ship_to_acct_tax_rnd_rule      VARCHAR2(30);
x_tax_value                           NUMBER;
l_x_msg_count                  NUMBER;
l_x_msg_data                   VARCHAR2(2000);
l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_tax_value               NUMBER := 0;
l_tax_code                VARCHAR2(50);
l_adj_index               NUMBER;
l_start_time             NUMBER;
l_end_time               NUMBER;
l_load_person_failed     Boolean := false;

 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(1000);
 I                        INTEGER;
  J                       INTEGER;
 l_call_tax                     VARCHAR2(1) := 'N';
 l_minimum_accountable_unit     fnd_currencies.minimum_accountable_unit%type;
 l_precision                    fnd_currencies.precision%type;
 l_ship_from_location_id        NUMBER;
 l_commitment_id                oe_order_lines.commitment_id%type;
 l_currency_code                VARCHAR2(30);
 l_inventory_org_id             NUMBER;
 l_header_org_id                NUMBER;
 l_conversion_rate              NUMBER;
 l_cust_trx_type_id             ra_cust_trx_types_all.cust_Trx_type_id%type;
 l_legal_entity_id              NUMBER(15);
 l_ship_party_id                NUMBER(15);
 l_ship_party_site_id           NUMBER(15);
 l_ship_location_id             NUMBER(15);
 l_bill_party_id                NUMBER(15);
 l_bill_party_site_id           NUMBER(15);
 l_bill_location_id             NUMBER(15);
 l_ship_to_site_use_id          HZ_CUST_SITE_USES_ALL.SITE_USE_ID%type;
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
 l_transaction_rec zx_api_pub.transaction_rec_type;
 l_entity_code_crsr             zx_detail_tax_lines_gt.entity_code%TYPE := 'OE_ORDER_HEADERS';
 l_event_class_code_crsr        zx_detail_tax_lines_gt.event_class_code%TYPE := 'SALES_TRANSACTION_TAX_QUOTE';
 l_trx_level_type_crsr          zx_detail_tax_lines_gt.trx_level_type%TYPE;
 l_application_id               NUMBER := 660;
 l_bill_from_location_id        NUMBER;
 l_POO_LOCATION_ID              NUMBER;
 l_doc_level_recalc_flag varchar2(30);

CURSOR get_internal_loc(p_organization_id number) IS
 select location_id
 from   hr_organization_units
 where  organization_id = p_organization_id;


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

CURSOR detail_tax_lines_gt (p_header_id oe_order_lines.header_id%type)
                          --  p_line_id oe_order_lines.line_id%type)
  is
  select * from
  ZX_DETAIL_TAX_LINES_GT
  where
  application_id = l_application_id
  and entity_code = l_entity_code_crsr           --'OE_ORDER_HEADERS'
  and event_class_code = l_event_class_code_crsr --'SALES_TRANSACTION_TAX_QUOTE'
  and trx_id =  p_header_id
  --and trx_line_id = p_line_id
  and trx_level_type = 'LINE';


 detail_tax_lines_gt_rec detail_tax_lines_gt%rowtype;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_BULK_TAX_UTIL.CALCULATE_TAX' ) ;
    IF p_post_insert THEN
      oe_debug_pub.add(  'Post_insert : TRUE');
    ELSE
      oe_debug_pub.add(  'Post_insert : FALSE');
    END IF;
  END IF;



  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'tax method: ' || l_tax_method || '    vendor installed: ' || l_vendor_installed);
  END IF;


  --l_AR_Sys_Param_Rec := OE_SYS_PARAMETERS_PVT.Get_AR_Sys_Params;


  --Loop over the loaded lines to calculate the tax
  l_index := 1;
  l_tax_index := 1;
  l_adj_index := 1;

  WHILE l_index <= OE_Bulk_Order_PVT.G_LINE_REC.LINE_ID.COUNT LOOP
    l_tax_value := 0;
    l_index_inc := 1;
    l_header_index := OE_Bulk_Order_PVT.G_LINE_REC.header_index(l_index);
    l_header_id := OE_Bulk_Order_PVT.G_LINE_REC.header_id(l_index);
    l_line_id := OE_Bulk_Order_PVT.G_LINE_REC.line_id(l_index);
    zx_global_structures_pkg.init_trx_line_dist_tbl(l_index);
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'line index: ' || l_index || '   line id: '|| l_line_id || '    header index: ' || l_header_index || '    header id: ' || l_header_id);
      END IF;


    IF nvl(OE_Bulk_Order_PVT.G_HEADER_REC.lock_control(l_header_index),0) = -99
      THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'lock control set.  skipping header with header id: '|| l_header_id);
        END IF;

       l_legal_entity_id := get_le_id(p_order_type_id =>
OE_Bulk_Order_PVT.G_HEADER_REC.order_type_id(l_header_index)
                                 , p_sold_to_customer_id =>
OE_Bulk_Order_PVT.G_HEADER_REC.sold_to_org_id(l_header_index)
                                 , p_bill_to_customer_id => l_bill_to_customer_id
                                 , p_org_id         => OE_Bulk_Order_PVT.G_HEADER_REC.org_id(l_header_index)
                                  );


        --Skip the remaining lines in this header as it is marked for error
        l_remaining_lines := OE_Bulk_Order_PVT.G_HEADER_REC.end_line_index(l_header_index) - l_index;
        l_index_inc := l_remaining_lines + 1;
      ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('inventory_item_id: ' || OE_Bulk_Order_PVT.G_LINE_REC.inventory_item_id(l_index));
        oe_debug_pub.add('unit_selling_price: ' || OE_Bulk_Order_PVT.G_LINE_REC.unit_selling_price(l_index));
        oe_debug_pub.add('tax_exempt_flag: ' || OE_Bulk_Order_PVT.G_LINE_REC.tax_exempt_flag(l_index));
        oe_debug_pub.add('tax_calculation_flag: ' || OE_Bulk_Order_PVT.G_LINE_REC.tax_calculation_flag(l_index));
      END IF;

       begin
        select location_id
        into l_bill_from_location_id
        from HR_ALL_ORGANIZATION_UNITS
        where organization_id = OE_Bulk_Order_PVT.G_HEADER_REC.org_id(l_header_index);
      Exception
        when others then
        l_bill_from_location_id := NULL;
     End;

    open get_internal_loc(OE_Bulk_Order_PVT.G_HEADER_REC.org_id(l_header_index));
     fetch get_internal_loc into l_internal_org_location_id;
     close get_internal_loc;

     IF l_debug_level > 0 then
         oe_debug_pub.add('om_tax_line  13' , 4);
	  oe_debug_pub.add('OE_Bulk_Order_PVT.G_LINE_REC.inventory_item_id(l_index):'||OE_Bulk_Order_PVT.G_LINE_REC.inventory_item_id(l_index));
	   oe_debug_pub.add('OE_Bulk_Order_PVT.G_LINE_REC.unit_selling_price(l_index):'||OE_Bulk_Order_PVT.G_LINE_REC.unit_selling_price(l_index));
	    oe_debug_pub.add('OE_Bulk_Order_PVT.G_LINE_REC.item_type_code(l_index):'||OE_Bulk_Order_PVT.G_LINE_REC.item_type_code(l_index));
      END IF;


      IF ((OE_Bulk_Order_PVT.G_LINE_REC.inventory_item_id(l_index) IS NOT NULL
          AND OE_Bulk_Order_PVT.G_LINE_REC.unit_selling_price(l_index) IS NOT NULL
          AND OE_Bulk_Order_PVT.G_LINE_REC.item_type_code(l_index) <> OE_GLOBALS.G_ITEM_INCLUDED)
	  )
          --AND
         --(OE_Bulk_Order_PVT.G_LINE_REC.tax_exempt_flag(l_index) = 'R' OR
          --OE_Bulk_Order_PVT.G_LINE_REC.tax_calculation_flag(l_index) = 'Y'))
	  --bug7685103
      THEN

         l_order_type_cache_key := OE_BULK_CACHE.Load_Order_Type(OE_Bulk_Order_PVT.G_HEADER_REC.order_type_id(l_header_index));

	 IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'tax calculation event: ' || OE_Bulk_Cache.G_ORDER_TYPE_TBL(l_order_type_cache_key).tax_calculation_event);
           oe_debug_pub.add(  'booked_flag: ' || nvl(OE_Bulk_Order_PVT.G_HEADER_REC.booked_flag(l_header_index), 'N'));
         END IF;

	 IF ((nvl(OE_Bulk_Order_PVT.G_HEADER_REC.booked_flag(l_header_index), 'N') = 'N' AND
             OE_Bulk_Cache.G_ORDER_TYPE_TBL(l_order_type_cache_key).tax_calculation_event = 'BOOKING')
             OR
            (OE_Bulk_Cache.G_ORDER_TYPE_TBL(l_order_type_cache_key).tax_calculation_event NOT IN ('ENTERING', 'BOOKING')))
         THEN
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'tax calculation event not set to ENTERING or BOOKING...OR....event is set to BOOKING but order is not booked.  skipping header with header id: '|| l_header_id);
           END IF;

           --Skip the remaining lines in this header
           l_remaining_lines := OE_Bulk_Order_PVT.G_HEADER_REC.end_line_index(l_header_index) - l_index;
           l_index_inc := l_remaining_lines + 1;
         ELSE

	     oe_debug_pub.add(  'Set message Context ');
           -- Set the message context for errors.
           OE_BULK_MSG_PUB.set_msg_context
                 ( p_entity_code                => 'LINE'
          	 ,p_entity_id                   => l_line_id
        	 ,p_header_id                   => l_header_id
        	 ,p_line_id                     => l_line_id
       		 ,p_orig_sys_document_ref       => OE_Bulk_Order_PVT.G_LINE_REC.orig_sys_document_ref(l_index)
       		 ,p_orig_sys_document_line_ref  => OE_Bulk_Order_PVT.G_LINE_REC.orig_sys_line_ref(l_index)
        	 ,p_source_document_id          => NULL
       		 ,p_source_document_line_id     => NULL
       		 ,p_order_source_id             => OE_Bulk_Order_PVT.G_LINE_REC.order_source_id(l_index)
         	 ,p_source_document_type_id     => NULL
                 );


             IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'loading tax attributes cache');
             END IF;



    l_currency_code := OE_Bulk_Order_PVT.G_HEADER_REC.transactional_curr_code(l_header_index);
    l_header_org_id := OE_Bulk_Order_PVT.G_HEADER_REC.org_id(l_header_index);
    l_conversion_rate := OE_Bulk_Order_PVT.G_HEADER_REC.conversion_rate(l_header_index);
    l_inventory_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID',OE_Bulk_Order_PVT.G_HEADER_REC.org_id(l_header_index));


     select    c.minimum_accountable_unit,
               c.precision
     into      l_minimum_accountable_unit,
               l_precision
     from      fnd_currencies c
     where     c.currency_code = l_currency_code;

     l_AR_Sys_Param_Rec          := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params;

     --code changes made for bug 1883552  begin
     l_commitment_id := nvl(OE_Bulk_Order_PVT.G_LINE_REC.commitment_id(l_index),0);
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
       /*l_cust_trx_type_id :=
OE_INVOICE_PUB.Get_Customer_Transaction_Type(OE_Bulk_Order_PVT.G_LINE_REC(l_index)); */

     end if;
     --code changes made for bug 1883552  end

    IF l_debug_level > 0 THEN
     oe_debug_pub.add('Customer trx type id is:'||l_cust_trx_type_id,4);
    END IF;

-- bug7685103 to avoid NO_DATA_FOUND exception
 IF OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index) IS NOT NULL THEN
   l_tax_code_cache_key := OE_Bulk_Cache.load_tax_attributes(OE_Bulk_Order_PVT.G_LINE_REC.tax_code(l_index), OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index));

             IF l_debug_level  > 0 THEN
               oe_debug_pub.add('tax inclusive flag from cache:' || OE_BULK_CACHE.G_TAX_ATTRIBUTES_TBL(l_tax_code_cache_key).amount_includes_tax_flag);
             END IF;

END IF;



             BEGIN

                l_salesrep_cache_key := OE_BULK_CACHE.Load_Salesrep(OE_Bulk_Order_PVT.G_LINE_REC.salesrep_id(l_index));
                l_person_id := OE_BULK_CACHE.G_SALESREP_TBL(l_salesrep_cache_key).person_id;

                IF l_debug_level  > 0 THEN
                         oe_debug_pub.add( 'Before Calling load_person: ' || l_person_id);
                         oe_debug_pub.add( ' l_index :'|| l_index);
                         oe_debug_pub.add( ' Tax Date :'|| OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index));
                END IF;

                l_asgn_org_id := OE_BULK_CACHE.Load_Person(l_person_id, OE_Bulk_Order_PVT.G_LINE_REC.tax_date(l_index));

             EXCEPTION
                  When others then
                      l_load_person_failed := true;
                      IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'Load Person Failed. ' || SQLERRM);
                      END IF;
             END;

          IF l_load_person_failed THEN
                    l_asgn_org_id := null;
                    l_poo_location_id := NULL;
                 ELSE
                    l_asgn_org_id := OE_BULK_CACHE.G_PERSON_TBL(l_person_id).ORGANIZATION_ID; -- the cache key is l_person_id only
                    l_poo_location_id := OE_BULK_CACHE.G_PERSON_TBL(l_person_id).LOCATION_ID;
                 END IF;

-- Legal Entity
              oe_debug_pub.add(  ' Ship from org id :'|| OE_Bulk_Order_PVT.G_LINE_REC.ship_from_org_id(l_index));

           IF OE_Bulk_Order_PVT.G_LINE_REC.ship_from_org_id(l_index) IS NOT NULL THEN
               BEGIN
                 SELECT location_id
                 INTO l_ship_from_location_id
                 FROM hr_all_organization_units hu
                 WHERE hu.organization_id = OE_Bulk_Order_PVT.G_LINE_REC.ship_from_org_id(l_index);
              EXCEPTION
               WHEN OTHERS THEN
               NULL;
             END;
           END IF;


 -- zx_global_structures_pkg.init_trx_line_dist_tbl(i);

             -- populate ship_to info if ship_to_org_id is not null
             IF OE_Bulk_Order_PVT.G_LINE_REC.ship_to_org_id(l_index) IS NOT NULL
             THEN
               IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'retrieving ship_to info');
               END IF;
               l_ship_to_cache_key := OE_Bulk_Cache.load_loc_info(OE_Bulk_Order_PVT.G_LINE_REC.ship_to_org_id(l_index));
               l_ship_to_cust_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).CUST_ACCOUNT_ID;
               l_ship_to_postal_code := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).POSTAL_CODE;
               l_ship_location_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).LOC_ID;
	       l_ship_to_state := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).STATE;
	       l_ship_to_cust_acct_site_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).CUST_ACCT_SITE_ID;
               l_ship_to_cust_account_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).CUST_ACCOUNT_ID;
               l_ship_to_account_number := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).ACCOUNT_NUMBER;
               l_ship_party_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).PARTY_ID;
               l_ship_to_party_name := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).PARTY_NAME;
               l_ship_party_site_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).PARTY_SITE_ID;
               l_ship_su_tax_hdr_flag := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).TAX_HEADER_LEVEL_FLAG;
               l_ship_acct_tax_hdr_flag := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).ACCT_TAX_HEADER_LEVEL_FLAG;
               l_ship_to_su_tax_rnd_rule := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).TAX_ROUNDING_RULE;
               l_ship_to_acct_tax_rnd_rule := OE_BULK_CACHE.G_LOC_INFO_TBL(l_ship_to_cache_key).ACCT_TAX_ROUNDING_RULE;
             END IF; -- end of if ship_to_org_id IS NOT NULL
             oe_debug_pub.add(  'Ship to cache key :'|| l_ship_to_cache_key);
             oe_debug_pub.add(  ' l_ship_party_id :'|| l_ship_party_id);
             oe_debug_pub.add(  '  l_ship_location_id :'|| l_ship_location_id);
             oe_debug_pub.add(  ' l_ship_to_cust_acct_site_id :'|| l_ship_to_cust_acct_site_id);
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_ID(l_index)   := l_ship_party_id; --1001;
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID(l_index)      := l_ship_party_site_id;--1024;
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(l_index)        := l_ship_location_id;--1067;
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(l_index) := l_ship_to_cust_acct_site_id;--1024;
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(l_index) := OE_Bulk_Order_PVT.G_LINE_REC.ship_to_org_id(l_index);--1007;
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID(l_index) := l_ship_to_cust_account_id;--1001;


             -- populate invoice_to info if invoice_to_org_id is not null
             IF OE_Bulk_Order_PVT.G_LINE_REC.invoice_to_org_id(l_index) IS NOT NULL
             THEN
               IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'retrieving bill_to info');
               END IF;
               l_invoice_to_cache_key := OE_Bulk_Cache.load_loc_info(OE_Bulk_Order_PVT.G_LINE_REC.invoice_to_org_id(l_index));
               l_bill_to_cust_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).CUST_ACCOUNT_ID;
               l_bill_to_postal_code := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).POSTAL_CODE;
               l_bill_location_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).LOC_ID;
               l_bill_to_state := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).STATE;
               l_bill_to_cust_acct_site_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).CUST_ACCT_SITE_ID;
               l_bill_to_cust_account_id := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).CUST_ACCOUNT_ID;
               l_bill_to_account_number := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).ACCOUNT_NUMBER;
               l_bill_party_id          := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).PARTY_ID;
               l_bill_to_party_name := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).PARTY_NAME;
               l_bill_party_site_id  := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).PARTY_SITE_ID;
               l_bill_su_tax_hdr_flag := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).TAX_HEADER_LEVEL_FLAG;
               l_bill_acct_tax_hdr_flag := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).ACCT_TAX_HEADER_LEVEL_FLAG;
               l_bill_to_su_tax_rnd_rule := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).TAX_ROUNDING_RULE;
               l_bill_to_acct_tax_rnd_rule := OE_BULK_CACHE.G_LOC_INFO_TBL(l_invoice_to_cache_key).ACCT_TAX_ROUNDING_RULE;
             END IF;  --end of if invoice_to_org_id IS NOT NULL


        l_legal_entity_id := get_le_id(p_order_type_id => OE_Bulk_Order_PVT.G_HEADER_REC.order_type_id(l_header_index)
                                     , p_sold_to_customer_id => OE_Bulk_Order_PVT.G_HEADER_REC.sold_to_org_id(l_header_index)
                                 , p_bill_to_customer_id => l_bill_to_cust_id
                                 , p_org_id         => OE_Bulk_Order_PVT.G_HEADER_REC.org_id(l_header_index)
                                  );


     oe_debug_pub.add(  ' Assign Bill To info ');
                 oe_debug_pub.add(  'Bill to cache key :'|| l_invoice_to_cache_key);
             oe_debug_pub.add(  ' l_bill_party_id :'|| l_bill_party_id);
             oe_debug_pub.add(  '  l_bill_location_id :'|| l_bill_location_id);
             oe_debug_pub.add(  ' l_ship_to_cust_acct_site_id :'|| l_bill_to_cust_acct_site_id);

                zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_ID(l_index) := l_bill_party_id;
                zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID(l_index)      := l_bill_party_site_id; --1024;
                zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_LOCATION_ID(l_index)        := l_bill_location_id;--1067;
                zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(l_index) := l_bill_to_cust_acct_site_id;--1024;
                zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(l_index) := OE_Bulk_Order_PVT.G_LINE_REC.invoice_to_org_id(l_index);--1006;
                zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID(l_index) := l_bill_to_cust_account_id;


       oe_debug_pub.add(  ' Assign other values ',1);
       l_call_tax := 'Y'; --bug7685103 --Call ZX api only if there is atleast one eligible line to be taxed

       zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID(l_index)	:= 660;
       zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE(l_index)	:= 'OE_ORDER_HEADERS';
       zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE(l_index)	:= 'SALES_TRANSACTION_TAX_QUOTE';
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID(l_index)		:= OE_Bulk_Order_PVT.G_Line_Rec.header_id(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE(l_index)	:= 'LINE';

       zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(l_index)          := OE_Bulk_Order_PVT.G_Header_Rec.org_id(l_header_index);
       zx_global_structures_pkg.trx_line_dist_tbl.EVENT_TYPE_CODE(l_index)                   := 'CREATE';

       zx_global_structures_pkg.trx_line_dist_tbl.TRX_DATE(l_index)               := OE_Bulk_Order_PVT.G_Line_Rec.TAX_DATE(l_index);

       zx_global_structures_pkg.trx_line_dist_tbl.TRX_DOC_REVISION(l_index)                  := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.LEDGER_ID(l_index)                         := l_AR_Sys_Param_Rec.set_of_books_id;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_CURRENCY_CODE(l_index)                 := OE_Bulk_Order_PVT.G_Header_Rec.transactional_curr_code(l_header_index);
       oe_debug_pub.add(  '1:');

       zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(l_index)          := OE_Bulk_Order_PVT.G_Header_Rec.conversion_rate_Date(l_header_index);
       zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(l_index)          := OE_Bulk_Order_PVT.G_Header_Rec.conversion_rate(l_header_index);
       zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(l_index)          := OE_Bulk_Order_PVT.G_Header_Rec.CONVERSION_TYPE_CODE(l_header_index);
       zx_global_structures_pkg.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(l_index)          := G_MINIMUM_ACCOUNTABLE_UNIT;
       zx_global_structures_pkg.trx_line_dist_tbl.PRECISION(l_index)                         := l_precision;
   -- revisit the logic to derive legal_entity_id later when legal_entity_id approach is clarified.
       zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(l_index)                   := l_legal_entity_id; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.ESTABLISHMENT_ID(l_index)                  := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(l_index)           := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_NUMBER(l_index)                        := OE_Bulk_Order_PVT.G_Header_Rec.order_number(l_header_index);
       oe_debug_pub.add(  '2:');
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_DESCRIPTION(l_index)                   := NULL; --   VARCHAR2_240_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_COMMUNICATED_DATE(l_index)             := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.BATCH_SOURCE_ID(l_index)                   := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.BATCH_SOURCE_NAME(l_index)                 := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_ID(l_index)                        := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_NAME(l_index)                      := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_VALUE(l_index)                     := NULL; --   VARCHAR2_240_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_DUE_DATE(l_index)                      := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_TYPE_DESCRIPTION(l_index)              := NULL; --   VARCHAR2_240_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.FIRST_PTY_ORG_ID(l_index)                  := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.RECEIVABLES_TRX_TYPE_ID(l_index)           := l_cust_trx_type_id;
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(l_index)              := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE(l_index)               := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOC_EVENT_STATUS(l_index)                  := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(l_index)                 := NULL; --   VARCHAR2_240_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_NUMBER(l_index)       := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_DATE(l_index)         := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_EXCHANGE_RATE(l_index)            := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_DATE(l_index)                  := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_NUMBER(l_index)                := NULL; --   VARCHAR2_150_tbl_type  ,
       zx_global_structures_pkg.trx_line_dist_tbl.QUOTE_FLAG(l_index)                        := 'Y'; --   VARCHAR2_1_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(l_index)          := NULL; --   VARCHAR2_2_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(l_index)             := NULL; --   VARCHAR2_1_tbl_type    ,
       zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(l_index)             := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.PORT_OF_ENTRY_CODE(l_index)                := NULL; --   VARCHAR2_30_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_REPORTING_FLAG(l_index)                := 'N'; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG(l_index)             := NULL; --   VARCHAR2_1_tbl_type ,
       zx_global_structures_pkg.trx_line_dist_tbl.COMPOUNDING_TAX_FLAG(l_index)              := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(l_index)     := NULL; --   DATE_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.INSERT_UPDATE_FLAG(l_index)                := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_NUMBER(l_index)             := NULL; --   VARCHAR2_150_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.START_EXPENSE_DATE(l_index)                := NULL; --   DATE_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_BATCH_ID(l_index)                      := NULL; --   NUMBER_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.RECORD_TYPE_CODE(l_index)                  := NULL; --   VARCHAR2_30_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_PROCESSING_COMPLETED_FLAG(l_index)     := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_DOC_STATUS(l_index)            := NULL; --   VARCHAR2_30_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.OVERRIDING_RECOVERY_RATE(l_index)          := NULL; --   NUMBER_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.TAX_CALCULATION_DONE_FLAG(l_index)         := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG(l_index)         := NULL; --   VARCHAR2_1_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.ICX_SESSION_ID(l_index)                    := NULL; --   NUMBER_tbl_type
       oe_debug_pub.add(  '3:');
       -- line level columns
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CODE(l_index)            := NULL; --   VARCHAR2_15_tbl_type   ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_DATE(l_index)       := NULL; --   DATE_tbl_type          ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_RATE(l_index)       := NULL; --   NUMBER_tbl_type        ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_TYPE(l_index)       := NULL; --   VARCHAR2_30_tbl_type   ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_MAU(l_index)                      := NULL; --   NUMBER_tbl_type        ,
       --zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_PRECISION(l_index)                := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE(l_index)                 := NULL; --   VARCHAR2_240_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(l_index)     := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG(l_index)            := OE_Bulk_Order_PVT.G_Line_Rec.TAX_EXEMPT_FLAG(l_index);
       oe_debug_pub.add(  '4:');
       zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_REASON_CODE(l_index)                := OE_Bulk_Order_PVT.G_Line_Rec.TAX_EXEMPT_REASON_CODE(l_index);
        oe_debug_pub.add(  '44:');
       zx_global_structures_pkg.trx_line_dist_tbl.INTERFACE_ENTITY_CODE(l_index)             := NULL; --   VARCHAR2_30_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.INTERFACE_LINE_ID(l_index)                 := NULL; --   NUMBER_tbl_type,
       zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_TAX_CODE_ID(l_index)            := NULL; --   NUMBER_tbl_type,

       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec.Line_Id(l_index);
       oe_debug_pub.add(  '444:');
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_CLASS(l_index) := 'INVOICE';
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(l_index)	:= 'CREATE';
        oe_debug_pub.add(  '441:');
--       zx_global_structures_pkg.trx_line_dist_tbl.TRX_SHIPPING_DATE(l_index)	:= Nvl(OE_Bulk_Order_PVT.G_Line_Rec.actual_shipment_date(l_index), OE_Bulk_Order_PVT.G_Line_Rec.schedule_ship_date(l_index)); -- l_trx_shipping_date;
      oe_debug_pub.add(  '412');
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_RECEIPT_DATE(l_index)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_TYPE(l_index)	:= 'LINE';
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DATE(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec.tax_date(l_index);
       oe_debug_pub.add(  '5:');
    IF OE_Bulk_Order_PVT.G_Line_Rec.global_attribute_category(l_index) IN
       ('JL.AR.OEXOEORD.LINES',
        'JL.BR.OEXOEORD.LINES',
        'JL.CO.OEXOEORD.LINES') THEN
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec.global_attribute6(l_index); --l_trx_business_category;
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(l_index):= OE_Bulk_Order_PVT.G_Line_Rec.global_attribute5(l_index);
    ELSE
      zx_global_structures_pkg.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(l_index) := NULL;
      zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(l_index):= NULL;
    END IF;
       oe_debug_pub.add(  '6:');
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(l_index)	:= 'S';
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec. ordered_quantity (l_index) * OE_Bulk_Order_PVT.G_Line_Rec.unit_selling_price(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_QUANTITY(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec. ordered_quantity (l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec.unit_selling_price(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec.tax_exempt_number(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_REASON(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec.TAX_EXEMPT_REASON_CODE(l_index);
       oe_debug_pub.add(  '7:');
       zx_global_structures_pkg.trx_line_dist_tbl.CASH_DISCOUNT(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.VOLUME_DISCOUNT(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_DISCOUNT(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRANSFER_CHARGE(l_index)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.TRANSPORTATION_CHARGE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.INSURANCE_CHARGE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OTHER_CHARGE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ID(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec.inventory_item_id(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ORG_ID(l_index)	:= NVL(OE_Bulk_Order_PVT.G_Line_Rec.ship_from_org_id(l_index),l_inventory_org_id);
       oe_debug_pub.add(  '8:');
       zx_global_structures_pkg.trx_line_dist_tbl.UOM_CODE(l_index)		:=NVL( OE_Bulk_Order_PVT.G_Line_Rec.order_quantity_uom (l_index), OE_Bulk_Order_PVT.G_Line_Rec.pricing_quantity_uom(l_index));
      zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE(l_index)	:= NULL;
zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CATEGORY(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_SIC_CODE(l_index)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.FOB_POINT(l_index)		:= OE_Bulk_Order_PVT.G_Line_Rec.fob_point_code(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_ID(l_index):= OE_Bulk_Order_PVT.G_Line_Rec.ship_from_org_id(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_ID(l_index)	:= l_header_org_id;
       oe_debug_pub.add(  '9:');
       zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_ID(l_index)	:= l_asgn_org_id; -- Load it from person_id cache ->asgn_org_id;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_ID(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_SITE_ID(l_index)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_SITE_ID(l_index)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(l_index)	:= l_ship_from_location_id;
       zx_global_structures_pkg.trx_line_dist_tbl.POA_LOCATION_ID(l_index)		:= l_internal_org_location_id;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_LOCATION_ID(l_index)		:= l_poo_location_id ;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(l_index)	:= l_bill_from_location_id; --bug7228640
       zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_CCID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_STRING(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_FLAG(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_NUMBER(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_TYPE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ASSET_COST(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_LEVEL_ACTION(l_index)           := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TAX_DIST_ID(l_index)    := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TAX_DIST_ID(l_index)    := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.TASK_ID(l_index)                     := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.AWARD_ID(l_index)                    := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.PROJECT_ID(l_index)                  := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_TYPE(l_index)            := NULL; --   VARCHAR2_30_tbl_type   ,
       zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_ORGANIZATION_ID(l_index) := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_ITEM_DATE(l_index)       := NULL; --   DATE_tbl_type          ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_AMT(l_index)           := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_QUANTITY(l_index)      := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_CURR_CONV_RATE(l_index)      := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.ITEM_DIST_NUMBER(l_index)            := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_DIST_ID(l_index)             := NULL; --   NUMBER_tbl_type        ,
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_TAX_AMT(l_index)       := NULL; --   NUMBER_tbl_type        ,
       oe_debug_pub.add(  '10:');
       zx_global_structures_pkg.trx_line_dist_tbl.ASSESSABLE_VALUE(l_index)		:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec.tax_code(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY1(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY2(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY3(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY4(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY5(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY6(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_NUMBER(l_index)   := OE_Bulk_Order_PVT.G_Line_Rec.line_number(l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_ID(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY1(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY2(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY3(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY4(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY5(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DIST_TRX_USER_KEY6(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_FLAG(l_index)	:='N';
       zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(l_index)	:='N';
       zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT(l_index)	:=NULL;
       oe_debug_pub.add(  '11:');
      zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DESCRIPTION(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec. user_item_description (l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_DESCRIPTION(l_index)	:= OE_Bulk_Order_PVT.G_Line_Rec. user_item_description (l_index);
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_WAYBILL_NUMBER(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_GL_DATE(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_NAME(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_SITE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_SITE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_SITE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_SITE_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_SITE_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_SITE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_LOCATION_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_LOCATION_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POC_LOCATION_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_LOCATION_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_LOCATION_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID(l_index):= NULL;
       -- Rounding parties not required for OM. No override of rounding level
       zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(l_index):= NULL;

       -- Ref_doc, applied_from, applied_to, related_doc are not applicable for OM
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_APPLICATION_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_ENTITY_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY1(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY2(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY3(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY4(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY5(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY6(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_LINE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY1(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY2(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY3(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY4(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY5(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY6(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_DIST_ID(l_index)      := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY1(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY2(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY3(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY4(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY5(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY6(l_index) := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(l_index)	:= NULL ;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DIST_ID(l_index)       := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY1(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY2(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY3(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY4(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY5(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY6(l_index)     := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE(l_index)     := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_TRX_ID(l_index)          := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY1(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY2(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY3(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY4(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY5(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY6(l_index)   := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_NUMBER(l_index)          := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_DATE(l_index)            := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_APPLN_ID(l_index)           := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_ENTITY_CODE(l_index)        := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_EVNT_CLS_CODE(l_index)      := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_ID(l_index)             := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_LEVEL_TYPE(l_index)     := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_LINE_ID(l_index)        := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC7(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC8(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC9(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC10(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR7(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR8(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR9(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.CHAR10(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE1(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE7(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE8(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE9(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DATE10(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.internal_org_location_id(l_index) := l_internal_org_location_id;
       oe_debug_pub.add(  '12:');
     /*
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POA_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POO_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POI_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.POD_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID(l_index)    := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID(l_index)    := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID(l_index)    := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID(l_index)    := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID(l_index)  := NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(l_index)      := NULL;

     */
       oe_debug_pub.add(  '13:');
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_APPLICATION_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_ENTITY_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_LINE_ID(l_index)		:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(l_index):= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1(l_index)	:= 'N';
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TAX_LINE_ID(l_index)	:= NULL;
       zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(l_index)	:= NULL;
	oe_debug_pub.add(  '14');
      IF l_debug_level > 0 THEN
         debug_msg(l_index, l_return_status);
 		null;
      END IF;


         END IF;  --end of IF tax_calculation_event NOT ENTERING or BOOKING

      END IF;  -- end of IF inventory item_id...
    END IF; -- end of IF header lock_control = -99

    l_index := l_index + l_index_inc;
  END LOOP; -- end of lines loop


         oe_debug_pub.add(  ' Assigned the Tax values ');
   /*
  IF ( NOT ( OE_Bulk_Order_PVT.G_Line_Rec.header_id(l_index) is null OR
             OE_Bulk_Order_PVT.G_Line_Rec.inventory_item_id(l_index) is null OR
             OE_Bulk_Order_PVT.G_Line_Rec.unit_selling_price(l_index) is null)
           )
  THEN


    IF l_debug_level > 0 THEN
 	oe_debug_pub.add('tax_line 11' , 1);
     SELECT hsecs INTO l_start_time from v$timer;
    END IF;

    l_call_tax := 'Y';
   */

      l_transaction_rec.application_id := 660;
      l_transaction_rec.entity_code := 'OE_ORDER_HEADERS';
      l_transaction_rec.event_class_code := 'SALES_TRANSACTION_TAX_QUOTE';
      l_transaction_rec.event_type_code := 'CREATE';
      l_transaction_rec.trx_id := OE_Bulk_Order_PVT.G_Header_Rec.header_id(l_header_index);
      l_transaction_rec.internal_organization_id := OE_Bulk_Order_PVT.G_Header_Rec.org_id(l_header_index);


      SELECT hsecs INTO l_start_time from v$timer;

       IF l_call_tax = 'Y' THEN --Call ZX api only if there is atleast one eligible line to be taxed
       oe_debug_pub.add(  ' Call zx_api_pub.calculate_tax ',1);

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
	END IF;

	SELECT hsecs INTO l_end_time from v$timer;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in zx_api_pub.calculate_tax is (sec) '||((l_end_time-l_start_time)/100));

          IF l_debug_level > 0 THEN
             oe_debug_pub.add('Message returned by tax API ZX_API_PUB.calculate_tax: '||l_msg_count,2);
          END IF;


        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'unexpected error');
             END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              IF l_x_msg_data is not null then
                 FND_MESSAGE.SET_NAME('ONT','ONT_AVAIL_GENERIC');
                 FND_MESSAGE.SET_TOKEN('TEXT',l_x_msg_data);
                 OE_MSG_PUB.Add;
              END IF;
         Handle_Error( l_header_index);

              IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'return status was ERROR.  skipping header with header id: '|| OE_Bulk_Order_PVT.G_Header_Rec.header_id(l_header_index));
                oe_debug_pub.add(  ' Error :'|| l_x_msg_data, 1);
              END IF;

              --Skip the remaining lines in this header as it is marked for error
--              l_remaining_lines := OE_Bulk_Order_PVT.G_HEADER_REC.end_line_index(l_header_index) - l_index;
--               l_index_inc := l_remaining_lines + 1;
           ELSE

             IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'before building adjustment records');
             END IF;

/*    i:=0;
    open detail_tax_lines_gt(l_line_rec.header_id, l_line_rec.line_id);
    fetch detail_tax_lines_gt into detail_tax_lines_gt_rec;
    loop
       exit when detail_tax_lines_gt%NOTFOUND;*/
    i := 1;
    for detail_tax_lines_gt_rec in detail_tax_lines_gt(OE_Bulk_Order_PVT.G_Header_Rec.header_id(l_header_index)) loop
       oe_debug_pub.add(  ' Header il_header_index Lalit' || detail_tax_lines_gt_rec.trx_level_type, 1);
       oe_debug_pub.add(  ' Header id :' || OE_Bulk_Order_PVT.G_Header_Rec.header_id(l_header_index), 1);
       oe_debug_pub.add(  '  Tax Code  :'|| detail_tax_lines_gt_rec.Tax_Code,1);
        oe_debug_pub.add(  '  Tax_rate_id  :'|| detail_tax_lines_gt_rec.tax_rate_id ,1);

                  --Build the Adjustments records to INSERT Tax Info
                      Extend_Adj_Rec(1, G_LINE_ADJ_REC);
                      oe_debug_pub.add(  ' Aftr Extend ');
		      G_LINE_ADJ_REC.header_id(i) :=  detail_tax_lines_gt_rec.trx_id;  --OE_Bulk_Order_PVT.G_Line_Rec.header_id(i);
                      G_LINE_ADJ_REC.line_id(i) :=  detail_tax_lines_gt_rec.trx_line_id; --OE_Bulk_Order_PVT.G_Line_Rec.line_id(i);

                      --  l_tax_code := OE_Bulk_Order_PVT.G_LINE_REC.Tax_Code(i);

                      G_LINE_ADJ_REC.tax_code(i) := detail_tax_lines_gt_rec.Tax_Code;
                      G_LINE_ADJ_REC.operand(i) := detail_tax_lines_gt_rec.tax_rate;
                      G_LINE_ADJ_REC.adjusted_amount(i) := detail_tax_lines_gt_rec.tax_amt;
		      G_LINE_ADJ_REC.automatic_flag(i) := 'N';
                      G_LINE_ADJ_REC.list_line_type_code(i) := 'TAX';
                      G_LINE_ADJ_REC.arithmetic_operator(i) := 'AMT';
		      G_LINE_ADJ_REC.tax_rate_id(i) := detail_tax_lines_gt_rec.tax_rate_id ; --bug7685103

                     -- OE_Bulk_Order_PVT.G_LINE_REC.tax_value(i) := detail_tax_lines_gt_rec.tax_amt;

                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'total tax value: i: ' ||
detail_tax_lines_gt_rec.tax_amt, 1);
                     END IF;

          --IF p_post_insert THEN

            --IF l_debug_level  > 0 THEN
             -- oe_debug_pub.add(  'post insert mode, so reset global tax info');
            --END IF;

            G_Tax_Line_Id(i) := detail_tax_lines_gt_rec.trx_line_id;
            G_Tax_Line_Value(i) := detail_tax_lines_gt_rec.tax_amt;
         -- END IF;


                  --   l_adj_index := l_adj_index + 1;
            i := i + 1;

          END LOOP;
         END IF;
     --   END IF;

--Tax value not updated on order line in case of post_insert = FALSE
FOR i IN 1..OE_Bulk_Order_PVT.G_LINE_REC.line_id.COUNT  LOOP --bug7685103
    FOR j in 1..G_Tax_Line_Id.COUNT LOOP
	IF OE_Bulk_Order_PVT.G_LINE_REC.line_id(i) = G_Tax_Line_Id(j) THEN
	   OE_Bulk_Order_PVT.G_LINE_REC.tax_value(i) := NVL(OE_Bulk_Order_PVT.G_LINE_REC.tax_value(i),0)+ G_Tax_Line_Value(j);
	END IF;
    END LOOP;
END  LOOP;
 --bug7685103

IF G_LINE_ADJ_REC.line_id.COUNT > 0
  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'adjustment records found: '|| G_LINE_ADJ_REC.line_id.COUNT ) ;
    END IF;
    Insert_Tax_Records(p_post_insert => p_post_insert);
  END IF;
G_LINE_ADJ_REC.PRICE_ADJUSTMENT_ID.delete;
G_LINE_ADJ_REC.CREATED_BY.delete;
G_LINE_ADJ_REC.CREATION_DATE.delete;
G_LINE_ADJ_REC.LAST_UPDATE_DATE.delete;
G_LINE_ADJ_REC.LAST_UPDATED_BY.delete;
G_LINE_ADJ_REC.HEADER_ID.delete;
G_LINE_ADJ_REC.LINE_ID.delete;
G_LINE_ADJ_REC.TAX_CODE.delete;
G_LINE_ADJ_REC.OPERAND.delete;
G_LINE_ADJ_REC.ADJUSTED_AMOUNT.delete;
G_LINE_ADJ_REC.AUTOMATIC_FLAG.delete;
G_LINE_ADJ_REC.LIST_LINE_TYPE_CODE.delete;
G_LINE_ADJ_REC.ARITHMETIC_OPERATOR.delete;
G_LINE_ADJ_REC.TAX_RATE_ID.delete;
  G_TAX_LINE_ID  :=   G_MISS_TAX_NUMBER_TBL;
  G_TAX_LINE_VALUE := G_MISS_TAX_NUMBER_TBL;

IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'EXITING OE_BULK_TAX_UTIL.CALCULATE_TAX' ) ;
END IF;

EXCEPTION
  WHEN OTHERS THEN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'in others exception ' || SQLERRM);
  END IF;

  IF OE_BULK_MSG_PUB.check_msg_level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_BULK_MSG_PUB.add_exc_msg
    (G_PKG_NAME
    ,'Calcuate_Tax'
    );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Calculate_Tax;




PROCEDURE Extend_Adj_Rec
        (p_count               IN NUMBER
        ,p_adj_rec            IN OUT NOCOPY LINE_ADJ_REC_TYPE
        )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'ENTERING OE_BULK_TAX_UTIL.EXTEND_ADJ_REC' ) ;
 --  oe_debug_pub.add(  ' p_adj_rec.PRICE_ADJUSTMENT_ID :'|| p_adj_rec.PRICE_ADJUSTMENT_ID.count);
END IF;

p_adj_rec.PRICE_ADJUSTMENT_ID.extend(p_count);
p_adj_rec.CREATED_BY.extend(p_count);
p_adj_rec.CREATION_DATE.extend(p_count);
p_adj_rec.LAST_UPDATE_DATE.extend(p_count);
p_adj_rec.LAST_UPDATED_BY.extend(p_count);
p_adj_rec.HEADER_ID.extend(p_count);
p_adj_rec.LINE_ID.extend(p_count);
p_adj_rec.TAX_CODE.extend(p_count);
p_adj_rec.OPERAND.extend(p_count);
p_adj_rec.ADJUSTED_AMOUNT.extend(p_count);
p_adj_rec.AUTOMATIC_FLAG.extend(p_count);
p_adj_rec.LIST_LINE_TYPE_CODE.extend(p_count);
p_adj_rec.ARITHMETIC_OPERATOR.extend(p_count);
p_adj_rec.TAX_RATE_ID.extend(p_count);


IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'EXITING OE_BULK_TAX_UTIL.EXTEND_ADJ_REC' ) ;
END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'in others exception ' || SQLERRM);
    END IF;

    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Extend_Adj_Rec'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Extend_Adj_Rec;

PROCEDURE Insert_Tax_Records
          (p_post_insert            IN    BOOLEAN
          )
IS
l_start_time             NUMBER;
l_end_time               NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'ENTERING OE_BULK_TAX_UTIL.INSERT_TAX_RECORDS' ) ;
END IF;

 SELECT hsecs INTO l_start_time from v$timer;



begin
FORALL i IN 1..G_LINE_ADJ_REC.LINE_ID.COUNT --bug7685103
    DELETE FROM OE_PRICE_ADJUSTMENTS
    where  list_line_type_code = 'TAX'
            and LINE_ID   = G_LINE_ADJ_REC.LINE_ID(i);
Exception
	when others then
	IF l_debug_level  > 0 THEN
	  oe_debug_pub.add(  'Exception in delete existing tax records' ) ;
	END IF;
End ;


FORALL i IN 1..G_LINE_ADJ_REC.LINE_ID.COUNT
                   INSERT INTO OE_PRICE_ADJUSTMENTS
                    (       PRICE_ADJUSTMENT_ID
                    ,       CREATED_BY
                    ,       CREATION_DATE
                    ,       LAST_UPDATE_DATE
                    ,       LAST_UPDATED_BY
                    ,       HEADER_ID
                    ,       LINE_ID
                    ,       TAX_CODE
                    ,       OPERAND
                    ,       adjusted_amount
                    ,       automatic_flag
                    ,       list_line_type_code
                    ,       arithmetic_operator
		    ,       tax_rate_id --bug7685103
		    )
                    VALUES
                    (       oe_price_adjustments_s.nextval
                    ,        FND_GLOBAL.USER_ID
                    ,        SYSDATE
                    ,        SYSDATE
                    ,        FND_GLOBAL.USER_ID
                    ,        G_LINE_ADJ_REC.header_id(i)
                    ,        G_LINE_ADJ_REC.line_id(i)
                    ,        G_LINE_ADJ_REC.tax_code(i)
                    ,        G_LINE_ADJ_REC.operand(i)
                    ,        G_LINE_ADJ_REC.adjusted_amount(i)
                    ,        'N'
                    ,        'TAX'
                    ,        'AMT'
		    ,	     G_LINE_ADJ_REC.tax_rate_id(i) --bug7685103
		    );


 SELECT hsecs INTO l_end_time from v$timer;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent inserting adjustment records is (sec) '||((l_end_time-l_start_time)/100));

      --Need to Update TAX_VALUE on oe_order_lines_all if in post insert mode.
      IF p_post_insert AND G_Tax_Line_Id.COUNT > 0
      THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'post insert mode, so update tax on lines in base table' ) ;
        END IF;


	FORALL i IN 1..G_Tax_Line_Id.COUNT --bug7685103
          UPDATE OE_ORDER_LINES
          SET TAX_VALUE = 0
          WHERE LINE_ID = G_Tax_Line_Id(i);

        FORALL i IN 1..G_Tax_Line_Id.COUNT --bug7685103
          UPDATE OE_ORDER_LINES
          SET TAX_VALUE = TAX_VALUE + G_Tax_Line_Value(i)
          WHERE LINE_ID = G_Tax_Line_Id(i);


      END IF;


IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'EXITING OE_BULK_TAX_UTIL.INSERT_TAX_RECORDS' ) ;
END IF;


EXCEPTION
  WHEN OTHERS THEN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'in others exception ' || SQLERRM ) ;
  END IF;

  IF OE_BULK_MSG_PUB.check_msg_level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_BULK_MSG_PUB.add_exc_msg
    (G_PKG_NAME
    ,'Insert_Tax_Records'
    );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Tax_Records;


PROCEDURE Handle_Error
        (p_header_index               IN NUMBER
 --       ,p_line_index                 IN NUMBER
        )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'ENTERING OE_BULK_TAX_UTIL.HANDLE_ERROR' ) ;
END IF;

--OE_Bulk_Order_PVT.G_LINE_REC.lock_control(p_line_index) := -99;
OE_Bulk_Order_PVT.G_HEADER_REC.lock_control(p_header_index) := -99;
OE_BULK_ORDER_PVT.mark_header_error(p_header_index, OE_Bulk_Order_PVT.G_HEADER_REC);


IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'EXITING OE_BULK_TAX_UTIL.HANDLE_ERROR' ) ;
END IF;

EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'in others exception ' || SQLERRM ) ;
  END IF;

  IF OE_BULK_MSG_PUB.check_msg_level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_BULK_MSG_PUB.add_exc_msg
    (G_PKG_NAME
    ,'Handle_Error'
    );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Handle_Error;

PROCEDURE Handle_Tax_Code_Error(p_index IN NUMBER,
                                p_header_index IN NUMBER,
				x_index_inc OUT NOCOPY NUMBER)

IS
l_index_inc NUMBER := NULL;
l_remaining_lines NUMBER;
l_order_type_cache_key    NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'ENTERING OE_BULK_TAX_UTIL.HANDLE_TAX_CODE_ERROR' ) ;
END IF;

      OE_Bulk_Order_PVT.G_LINE_REC.tax_code(p_index) := null;

      IF nvl(OE_Bulk_Order_PVT.G_HEADER_REC.booked_flag(p_header_index), 'N') = 'Y'
              THEN


                IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'order was booked');
                END IF;

         l_order_type_cache_key := OE_BULK_CACHE.Load_Order_Type(OE_Bulk_Order_PVT.G_HEADER_REC.order_type_id(p_header_index));
        IF OE_Bulk_Cache.G_ORDER_TYPE_TBL(l_order_type_cache_key).tax_calculation_event IN ('ENTERING', 'BOOKING') THEN

          OE_BULK_MSG_PUB.Set_Msg_Context
		( p_entity_code                 => 'HEADER'
         	 ,p_entity_id                   => OE_Bulk_Order_PVT.G_HEADER_REC.header_id(p_header_index)
        	 ,p_header_id                   => OE_Bulk_Order_PVT.G_HEADER_REC.header_id(p_header_index)
        	 ,p_orig_sys_document_ref       => OE_Bulk_Order_PVT.G_HEADER_REC.orig_sys_document_ref(p_header_index)
        	 ,p_order_source_id             => OE_Bulk_Order_PVT.G_HEADER_REC.order_source_id(p_header_index)
                );

         FND_MESSAGE.SET_NAME('ONT','OE_VAL_TAX_CODE_REQD');
         OE_BULK_MSG_PUB.Add;
         Handle_Error( p_header_index);

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'tax code not found.  skipping header with header id: '|| OE_Bulk_Order_PVT.G_HEADER_REC.header_id(p_header_index));
         END IF;

         --Skip the remaining lines in this header
         l_remaining_lines := OE_Bulk_Order_PVT.G_HEADER_REC.end_line_index(p_header_index) - p_index;
         l_index_inc := l_remaining_lines + 1;
        END IF;  -- end of tax event in ENTERING or BOOKING

      END IF;  --end of IF booked_flag = 'Y'

      x_index_inc := l_index_inc;

IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'EXITING OE_BULK_TAX_UTIL.HANDLE_TAX_CODE_ERROR' ) ;
END IF;


EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'in others exception ' || SQLERRM ) ;
  END IF;

  IF OE_BULK_MSG_PUB.check_msg_level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_BULK_MSG_PUB.add_exc_msg
    (G_PKG_NAME
    ,'Handle_Tax_Code_Error'
    );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Handle_Tax_Code_Error;

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

END OE_BULK_TAX_UTIL;

/
