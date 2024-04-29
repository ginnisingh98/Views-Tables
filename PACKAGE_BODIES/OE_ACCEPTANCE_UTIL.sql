--------------------------------------------------------
--  DDL for Package Body OE_ACCEPTANCE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ACCEPTANCE_UTIL" AS
/* $Header: OEXUACCB.pls 120.16.12010000.3 2009/07/03 11:33:27 nitagarw ship $ */

--  Global constant holding the package name

G_PKG_NAME                 CONSTANT VARCHAR2(30) := 'OE_ACCEPTANCE_UTIL';

G_batch_source_id          NUMBER       := FND_API.G_MISS_NUM;
G_batch_source_name        VARCHAR2(50) := FND_API.G_MISS_CHAR;
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT;               -- Bug 8656395

PROCEDURE Register_Changed_Lines (
  p_line_id            IN NUMBER
, p_header_id          IN NUMBER
, p_line_type_id       IN NUMBER
, p_sold_to_org_id     IN NUMBER
, p_invoice_to_org_id  IN NUMBER
, p_inventory_item_id  IN NUMBER
, p_shippable_flag     IN VARCHAR2
, p_org_id             IN NUMBER
, p_accounting_rule_id IN NUMBER
, p_operation          IN VARCHAR2
, p_ship_to_org_id      IN NUMBER  DEFAULT NULL --For bug#8262992
) IS

l_line_index           NUMBER := 0;
l_mod_line_id          NUMBER;
l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Entering OE_ACCEPTANCE_UTIL.Register_Changed_Lines ' );
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Operation value is ' || p_operation );
  END IF;

  l_mod_line_id := MOD(p_line_id, G_BINARY_LIMIT);                                   -- Bug 8656395
  IF p_operation In (OE_GLOBALS.G_OPR_CREATE, OE_GLOBALS.G_OPR_UPDATE) THEN
     IF G_line_index_Tbl.exists(l_mod_line_id) THEN
        l_line_index := G_line_index_tbl(l_mod_line_id).line_index;                  -- Replaced p_line_id with l_mod_line_id 8656395
     ELSE
        l_line_index := G_line_id_tbl.count + 1;
        G_line_index_tbl(l_mod_line_id).line_index := l_line_index;
        END IF;

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Line Index value is ' || l_line_index );
     END IF;

     G_Line_id_tbl(l_line_index)           := nvl(p_line_id, -99);
     G_header_id_tbl(l_line_index)         := nvl(p_header_id, -99);
     G_line_type_id_tbl(l_line_index)      := nvl(p_line_type_id, -99);
     G_sold_to_org_id_tbl(l_line_index)    := nvl(p_sold_to_org_id, -99);
     G_invoice_to_org_id_tbl(l_line_index) := nvl(p_invoice_to_org_id, -99);
     G_inventory_item_id_tbl(l_line_index) := nvl(p_inventory_item_id, -99);
     G_shippable_flag_tbl(l_line_index)    := nvl(p_shippable_flag, -99);
     G_org_id_tbl(l_line_index)            := nvl(p_org_id, -99);
     G_accounting_rule_id_tbl(l_line_index) := nvl(p_accounting_rule_id, -99);
     --For Bug#8262992
     G_ship_to_org_id_tbl(l_line_index) := nvl(p_ship_to_org_id, -99);

  ELSIF p_operation = OE_GLOBALS.G_OPR_DELETE THEN

     IF G_line_index_tbl.exists(l_mod_line_id) THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Line Index value is ' || l_line_index );                   -- Replaced p_line_id with l_mod_line_id 8656395
        END IF;
        G_Line_id_tbl(G_line_index_tbl(l_mod_line_id).line_index) := -99;
        G_line_index_tbl.delete(l_mod_line_id);
     END IF;

  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Exiting OE_ACCEPTANCE_UTIL.Register_Changed_Lines ' );
  END IF;

END Register_Changed_Lines;

PROCEDURE Delete_Changed_Lines_Tbl IS
BEGIN
  G_line_index_tbl.delete;
  G_line_id_tbl.delete;
  G_header_id_tbl.delete;
  G_line_type_id_tbl.delete;
  G_sold_to_org_id_tbl.delete;
  G_invoice_to_org_id_tbl.delete;
  G_inventory_item_id_tbl.delete;
  G_org_id_tbl.delete;
  G_accounting_rule_id_tbl.delete;
  G_batch_source_id_tbl.delete;
  G_cust_trx_type_id_tbl.delete;
  G_invoice_to_customer_tbl.delete;
  G_invoice_to_site_tbl.delete;
  G_shippable_flag_tbl.delete;
  G_accounting_rule_id_tbl.delete;
  --For Bug#8262992
  G_ship_to_customer_tbl.delete;
  G_ship_to_org_id_tbl.delete;
  G_ship_to_site_tbl.delete;
END Delete_Changed_Lines_Tbl;

FUNCTION Get_batch_source_ID
  (p_batch_source_name VARCHAR2)
RETURN NUMBER IS

l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Entering OE_ACCEPTANCE_UTIL.Get_batch_source_ID ' );
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('IN Batch source name is ' || p_batch_source_name );
  END IF;

  IF p_batch_source_name IS NOT NULL THEN
     IF g_batch_source_name = FND_API.G_MISS_CHAR OR
        G_batch_source_name <> p_batch_source_name THEN

	SELECT batch_source_id,
               name
          INTO g_batch_source_id,
               g_batch_source_name
          FROM ra_batch_sources
         WHERE name = p_batch_source_name;

      END IF;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('OUT Batch source name: ' || g_batch_source_name||' :batch_source_id:'||g_batch_source_id );
         END IF;

      RETURN g_batch_source_id;
  ELSE
      RETURN -99;
  END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Exiting OE_ACCEPTANCE_UTIL.Get_batch_source_ID ' );
      END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     RETURN -99;
END get_batch_source_ID;

PROCEDURE Default_Contingency_Attributes IS

l_debug_level               CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);

l_invoice_numbering_method  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('WSH_INVOICE_NUMBERING_METHOD'), 'A');
l_line_type_rec             OE_Order_Cache.line_type_Rec_Type;
l_order_type_rec            OE_Order_Cache.order_type_Rec_Type;

l_cust_trx_type_id          NUMBER;
l_invoice_source_id         NUMBER;
l_non_d_invoice_source_id   NUMBER;

l_cust_trx_type_id2         NUMBER;
l_invoice_source_id2        NUMBER;
l_non_d_invoice_source_id2  NUMBER;

l_line_id_old               NUMBER;
l_line_id_new               NUMBER;
l_inserted_lines            NUMBER;

CURSOR default_contingencies IS
  SELECT id, contingency_id, revrec_event_code, expiration_days
    FROM fun_rule_bulk_result_gt gt,
         ar_deferral_reasons dr
   WHERE gt.result_value = dr.contingency_id
   AND revrec_event_code in ('INVOICING', 'CUSTOMER_ACCEPTANCE')
ORDER BY id, revrec_event_code DESC, expiration_days, creation_date DESC;

BEGIN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Entering OE_ACCEPTANCE_UTIL.Default_Contingency_Attributes ' );
  END IF;

  FOR i in 1..g_Line_id_tbl.count LOOP

     IF g_line_id_tbl(i) = -99 THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Setting remaining attributes as -99');
        END IF;
        g_invoice_to_customer_tbl(i) := -99;
        g_invoice_to_site_tbl(i)     := -99;
        g_cust_trx_type_id_tbl(i)    := -99;
        g_batch_source_id_tbl(i)     := -99;
        --For Bug#8262992
	g_ship_to_customer_tbl(i)    := -99;
        g_ship_to_site_tbl(i)        := -99;
     ELSE
       -- populate customer account and customer account site
       BEGIN
         IF g_invoice_to_org_id_tbl(i) IS NOT NULL and g_invoice_to_org_id_tbl(i) <> -99 THEN
            SELECT acct_site.cust_account_id, site.cust_acct_site_id
              INTO g_invoice_to_customer_tbl(i),
                   g_invoice_to_site_tbl(i)
              FROM hz_cust_acct_sites_all acct_site,
                   hz_cust_site_uses_all site
             WHERE SITE.SITE_USE_CODE     = 'BILL_TO'
               AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
               AND SITE.SITE_USE_ID       = g_invoice_to_org_id_tbl(i);
         ELSE
           -- bug 4995169 when invoice to org id is NULL, error
            g_invoice_to_customer_tbl(i) := -99;
            g_invoice_to_site_tbl(i)     := -99;
         END IF;
        --For Bug#8262992
	         IF g_ship_to_org_id_tbl(i) IS NOT NULL and g_ship_to_org_id_tbl(i) <> -99 THEN
		             SELECT acct_site.cust_account_id, site.cust_acct_site_id
		               INTO g_ship_to_customer_tbl(i),
		                    g_ship_to_site_tbl(i)
		               FROM hz_cust_acct_sites_all acct_site,
		                    hz_cust_site_uses_all site
		              WHERE SITE.SITE_USE_CODE     = 'SHIP_TO'
		                AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
		                AND SITE.SITE_USE_ID       = g_ship_to_org_id_tbl(i);
		 ELSE
		            -- bug 4995169 when invoice to org id is NULL, error
		             g_ship_to_customer_tbl(i) := -99;
		             g_ship_to_site_tbl(i)     := -99;
	         END IF;
       --End of Bug#8262992
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            g_invoice_to_customer_tbl(i) := -99;
            g_invoice_to_site_tbl(i)     := -99;
            --For Bug#8262992
	    g_ship_to_customer_tbl(i) := -99;
	    g_ship_to_site_tbl(i)     := -99;
       END;

       -- Populate cust_trx_type_id, invoice_source_id, non_delivery_inoice_source_id
       l_line_type_rec           := oe_order_cache.load_line_type(g_line_type_id_tbl(i));
       l_cust_trx_type_id        := l_line_type_rec.cust_trx_type_id;
       l_invoice_source_id       := l_line_type_rec.invoice_source_id;
       l_non_d_invoice_source_id := l_line_type_rec.non_delivery_invoice_source_id;

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Line type details... ' );
         oe_debug_pub.add('Customer Transaction type   : ' || l_cust_trx_type_id );
         oe_debug_pub.add('Invoice Source              : ' || l_invoice_source_id );
         oe_debug_pub.add('Non Delivery Invoice Source : ' || l_non_d_invoice_source_id );
       END IF;

       IF l_cust_trx_type_id IS NULL OR
         (l_invoice_source_id IS NULL AND (g_shippable_flag_tbl(i) = 'Y' OR l_invoice_numbering_method = 'A')) OR
         (l_non_d_invoice_source_id IS NULL AND l_invoice_numbering_method = 'D' AND g_shippable_flag_tbl(i) = 'N') THEN

          l_order_type_rec           := oe_order_cache.load_order_type(OE_Order_Cache.g_header_rec.order_type_id);
          l_cust_trx_type_id2        := l_order_type_rec.cust_trx_type_id;
          l_invoice_source_id2       := l_order_type_rec.invoice_source_id;
          l_non_d_invoice_source_id2 := l_order_type_rec.non_delivery_invoice_source_id;
       END IF;

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Order type details... ' );
         oe_debug_pub.add('Customer Transaction type   : ' || l_cust_trx_type_id2 );
         oe_debug_pub.add('Invoice Source              : ' || l_invoice_source_id2 );
         oe_debug_pub.add('Non Delivery Invoice Source : ' || l_non_d_invoice_source_id2 );
       END IF;

       g_cust_trx_type_id_tbl(i) := NVL(l_cust_trx_type_id, NVL(l_cust_trx_type_id2, NVL(OE_SYS_PARAMETERS.VALUE('OE_INVOICE_TRANSACTION_TYPE_ID', g_org_id_tbl(i)), -99)));

       IF g_shippable_flag_tbl(i) = 'Y' OR l_invoice_numbering_method ='A' THEN
          g_batch_source_id_tbl(i) := NVL(l_invoice_source_id, NVL(l_invoice_source_id2, -99));

	  IF g_batch_source_id_tbl(i) = -99 AND OE_SYS_PARAMETERS.VALUE('OE_INVOICE_SOURCE', g_org_id_tbl(i)) IS NOT NULL THEN
             g_batch_source_id_tbl(i) := Get_batch_source_ID( OE_SYS_PARAMETERS.VALUE('OE_INVOICE_SOURCE', g_org_id_tbl(i)));
          END IF;
       ELSE
          g_batch_source_id_tbl(i) := NVL(l_non_d_invoice_source_id, NVL(l_non_d_invoice_source_id2, -99));

          IF g_batch_source_id_tbl(i) = -99 AND OE_SYS_PARAMETERS.VALUE('OE_NON_DELIVERY_INVOICE_SOURCE', g_org_id_tbl(i)) IS NOT NULL THEN
             g_batch_source_id_tbl(i) := Get_batch_source_ID( OE_SYS_PARAMETERS.VALUE('OE_NON_DELIVERY_INVOICE_SOURCE', g_org_id_tbl(i)));
	  END IF;
       END IF;

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('i:'||i);
         oe_debug_pub.add('g_line_id_tbl(i):'||g_line_id_tbl(i));
         oe_debug_pub.add('g_invoice_to_customer_tbl(i):'||g_invoice_to_customer_tbl(i));
         oe_debug_pub.add('G_invoice_to_site_tbl(i):'||G_invoice_to_site_tbl(i));
         oe_debug_pub.add('g_inventory_item_id_tbl(i):'||g_inventory_item_id_tbl(i));
         oe_debug_pub.add('Customer Transaction type : ' || g_cust_trx_type_id_tbl(i) );
         oe_debug_pub.add('Invoice Source            : ' || g_batch_source_id_tbl(i) );
         oe_debug_pub.add('org_id            : ' || g_org_id_tbl(i) );
         oe_debug_pub.add('accounting rule  : ' || g_accounting_rule_id_tbl(i) );

       END IF;

     END IF;
  END LOOP;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Inserting records in AR_RDR_PARAMETERS_GT ' );
     oe_debug_pub.add('g_Line_id_tbl.count: ' ||g_Line_id_tbl.count);
  END IF;

  --Populate global temporary table AR_RDR_PARAMETERS_GT
--  FORALL i in g_line_id_tbl.FIRST..g_line_id_tbl.LAST
  FORALL i in 1..g_Line_id_tbl.count
    INSERT INTO ar_rdr_parameters_gt
          (source_line_id,
           batch_source_id,
        -- profile_class_id,
           cust_account_id,
           cust_acct_site_id,
           cust_trx_type_id,
        -- item_category_id,
           inventory_item_id,
           org_id,
           accounting_rule_id,
        -- memo_line_id
           ship_to_cust_acct_id,
           ship_to_site_use_id
          )
    SELECT g_line_id_tbl(i),
           DECODE(g_batch_source_id_tbl(i),-99, NULL, g_batch_source_id_tbl(i)),
        -- profile_class_id,
           DECODE(g_invoice_to_customer_tbl(i), -99, NULL, g_invoice_to_customer_tbl(i)) ,
        -- DECODE(G_invoice_to_site_tbl(i),-99, NULL, G_invoice_to_site_tbl(i)),
           DECODE(g_invoice_to_org_id_tbl(i),-99,NULL,g_invoice_to_org_id_tbl(i)), -- for Bug#8262992
           DECODE(g_cust_trx_type_id_tbl(i), -99, NULL, g_cust_trx_type_id_tbl(i)),
        -- item_category_id,
           DECODE(g_inventory_item_id_tbl(i), -99, NULL, g_inventory_item_id_tbl(i)),
           DECODE(g_org_id_tbl(i), -99, NULL, g_org_id_tbl(i)),
           DECODE(G_accounting_rule_id_tbl(i), -99, NULL, G_accounting_rule_id_tbl(i)),
           -- memo_line_id
           --For Bug#8262992
	   DECODE(g_ship_to_customer_tbl(i), -99, NULL, g_ship_to_customer_tbl(i)) ,
           DECODE(g_ship_to_org_id_tbl(i),-99,NULL,g_ship_to_org_id_tbl(i))

      FROM dual
     WHERE g_line_id_tbl(i) <> -99;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('done inserting records' );
  END IF;

  l_inserted_lines := SQL%ROWCOUNT;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'INSERTED '||l_inserted_lines||' records' , 3 ) ;
  END IF;

IF l_inserted_lines > 0 THEN
  --Call AR API
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Entering AR_DEFERRAL_REASONS_GRP.default_reasons ' );
  END IF;
  ar_deferral_reasons_grp.default_reasons (
     p_api_version    => 1.0,
     p_mode           => 'OM',
     x_return_status  => l_return_status,
     x_msg_count      => l_msg_count,
     x_msg_data       => l_msg_data);

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Exiting AR_DEFERRAL_REASONS_GRP.default_reasons ' );
  END IF;

  --join fun_rule_bulk_result_gt with ar_deferral_reasons to get all the AR attributes
  --pick  one pre-billing or post-billing contingency

  --1. Pre-billing deferral reason has precedence over post-billing one
  --2. If there are two pre-billing deferral reasons(or two post-blling without prebilling), we pick the one that has less number of expiration days.
  --3. If even the number of expiration days is the same, we pick the one that was created later.

  l_line_id_old   := 0;
  l_line_id_new   := 0;

  IF l_debug_level  > 0 THEN -- for debugging purpose
     oe_debug_pub.add('Records returned by AR');
     FOR default_contingencies_rec IN default_contingencies LOOP
        oe_debug_pub.add('id:'||default_contingencies_rec.id);
        oe_debug_pub.add('contingency_id:'||default_contingencies_rec.contingency_id);
        oe_debug_pub.add('revrec_event_code:'||default_contingencies_rec.revrec_event_code);
        oe_debug_pub.add('revrec_expiration_days:'||default_contingencies_rec.expiration_days);
     END LOOP;
  END IF;


  FOR default_contingencies_rec IN default_contingencies LOOP
      l_line_id_new := default_contingencies_rec.id;

      IF l_line_id_new <> l_line_id_old THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Updating records in OE_ORDER_LINES_ALL ' );
      END IF;
         UPDATE OE_ORDER_LINES_ALL
            SET contingency_id         = default_contingencies_rec.contingency_id,
                revrec_event_code      = default_contingencies_rec.revrec_event_code,
                revrec_expiration_days = default_contingencies_rec.expiration_days
          WHERE line_id = default_contingencies_rec.id;

         l_line_id_old := l_line_id_new;
      END IF;

  END LOOP;
END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Deleting the changed lines table once the lines are processed ' );
  END IF;

  Delete_Changed_Lines_Tbl;

EXCEPTION
WHEN OTHERS THEN
     OE_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
           ,  'Default_Contingency_Attributes'
          );
END Default_Contingency_Attributes;

PROCEDURE Default_Parent_Accept_Details
(
  p_line_rec IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
 )
IS
l_order_line_id              NUMBER;
l_return_status              VARCHAR2(1);
l_service_reference_line_id  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_accepted_quantity NUMBER;
l_revrec_signature VARCHAR2(240);
l_revrec_signature_date DATE;
l_revrec_reference_document VARCHAR2(240);
l_revrec_comments VARCHAR2(2000);
l_revrec_implicit_flag VARCHAR2(1);
l_accepted_by NUMBER;
l_top_model_line_id NUMBER;
l_item_type_code VARCHAR2(30);

BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_ACCEPTANCE_UTIL.Default_Parent_Accept_Details' ) ;
   END IF;
     IF p_line_rec.item_type_code = 'SERVICE' THEN
        IF p_line_rec.service_reference_type_code = 'CUSTOMER_PRODUCT' AND
             p_line_rec.service_reference_line_id IS NOT NULL THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS A CUSTOMER PRODUCT' ) ;
           END IF;
           OE_SERVICE_UTIL.Get_Cust_Product_Line_Id
           ( x_return_status    => l_return_status
           , p_reference_line_id => p_line_rec.service_reference_line_id
           , p_customer_id       => p_line_rec.sold_to_org_id
           , x_cust_product_line_id => l_order_line_id
           );
           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'SERVICE LINE ID IS ' || L_ORDER_LINE_ID ) ;
                      END IF;
              l_service_reference_line_id := l_order_line_id;
           ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'NOT ABLE TO RETRIEVE CUST PRODUCT LINE ID' ) ;
              END IF;
                      FND_MESSAGE.SET_NAME('ONT','ONT_NO_CUST_PROD_LINE');
                      OE_MSG_PUB.ADD;
                      --RAISE NO_DATA_FOUND;
           END IF;
       ELSE -- not a customer product
        l_service_reference_line_id := p_line_rec.service_reference_line_id;
       END IF;
   END IF;

     IF l_service_reference_line_id IS NOT NULL THEN

         SELECT accepted_quantity
                ,Revrec_signature
		,Revrec_signature_date
                ,Revrec_reference_document
                ,Revrec_comments
                ,Revrec_implicit_flag
                ,accepted_by
                ,item_type_code
                ,top_model_line_id
         INTO  l_accepted_quantity
               , l_revrec_signature
               , l_revrec_signature_date
               , l_revrec_reference_document
               , l_revrec_comments
               , l_revrec_implicit_flag
               , l_accepted_by
               , l_item_type_code
               , l_top_model_line_id
        FROM    oe_order_lines_all
        WHERE   line_id = l_service_reference_line_id;

     IF  l_item_type_code IN ('MODEL', 'STANDARD') or (l_item_type_code='KIT' AND
           l_top_model_line_id = l_service_reference_line_id) AND
	   l_accepted_quantity is not null THEN -- parent is a top model and is accepted already
           if nvl(l_accepted_quantity,0) = 0 then --if parent is rejected or not accepted
              p_line_rec.accepted_quantity := l_accepted_quantity;
	   else
              p_line_rec.accepted_quantity := nvl(p_line_rec.fulfilled_quantity,nvl(p_line_rec.shipped_quantity,nvl(p_line_rec.ordered_quantity,0)));
	   end if;
                       p_line_rec.Revrec_signature:=l_revrec_signature;
                       p_line_rec.Revrec_signature_date:=l_revrec_signature_date;
                       p_line_rec.revrec_reference_document:= l_revrec_reference_document;
                       p_line_rec.revrec_comments:= l_revrec_comments;
                       p_line_rec.revrec_implicit_flag:=l_revrec_implicit_flag;
                       p_line_rec.accepted_by:= l_accepted_by;
      ELSIF  l_top_model_line_id IS NOT NULL AND  l_accepted_quantity is not null THEN -- parent is a child line and is accepted

         SELECT         Accepted_quantity
                       ,Revrec_signature
                       ,Revrec_signature_date
                       ,Revrec_reference_document
                       ,Revrec_comments
                       ,Revrec_implicit_flag
                       ,accepted_by
		       ,item_type_code
		       ,top_model_line_id
        INTO
                        l_accepted_quantity
                       , l_revrec_signature
                       , l_revrec_signature_date
                       , l_revrec_reference_document
                       , l_revrec_comments
                       , l_revrec_implicit_flag
                        ,l_accepted_by
                       , l_item_type_code
                       , l_top_model_line_id
        FROM      oe_order_lines_all
        WHERE     line_id= l_top_model_line_id;

           if nvl(l_accepted_quantity,0) = 0 then --if parent is rejected or not accepted
              p_line_rec.accepted_quantity := l_accepted_quantity;
	   else
              p_line_rec.accepted_quantity := nvl(p_line_rec.fulfilled_quantity,nvl(p_line_rec.shipped_quantity,nvl(p_line_rec.ordered_quantity,0)));
	   end if;
                       p_line_rec.Revrec_signature:=l_revrec_signature;
                       p_line_rec.Revrec_signature_date:=l_revrec_signature_date;
                       p_line_rec.revrec_reference_document:= l_revrec_reference_document;
                       p_line_rec.revrec_comments:= l_revrec_comments;
                       p_line_rec.revrec_implicit_flag:=l_revrec_implicit_flag;
                       p_line_rec.accepted_by:= l_accepted_by;



    END IF;
END IF; -- service reference is not null

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
END Default_Parent_Accept_Details;

PROCEDURE Get_Contingency_Attributes
(p_line_rec               IN OE_ORDER_PUB.Line_Rec_Type
,x_contingency_id         OUT NOCOPY NUMBER
,x_revrec_event_code      OUT NOCOPY VARCHAR2
,x_revrec_expiration_days OUT NOCOPY NUMBER)
IS
 l_service_reference_line_id NUMBER;
 l_return_status VARCHAR2(1);
 l_item_type_code VARCHAR2(30);
 l_order_line_id NUMBER;
 l_top_model_line_id NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   x_contingency_id := NULL;
   x_revrec_event_code := NULL;
   x_revrec_expiration_days := NULL;

 IF  p_line_rec.item_type_code = 'RETURN' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Return Line, Return ' );
      END IF;
      RETURN;

 ELSIF p_line_rec.source_document_type_id = 10 THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Internal Order Line, Return');
      END IF;
      RETURN;

 ELSIF p_line_rec.order_source_id=27 AND p_line_rec.retrobill_request_id IS NOT NULL THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Retrobill Line, Return ' );
      END IF;
      RETURN;

 ELSIF p_line_rec.item_type_code IN ('CONFIG','CLASS','OPTION','INCLUDED')
	    OR  (p_line_rec.item_type_code = 'KIT' and p_line_rec.top_model_line_id <> p_line_rec.line_id) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Item_type_code:'||p_line_rec.item_type_code||' Get from parent:'||p_line_rec.top_model_line_id );
      END IF;
      IF p_line_rec.top_model_line_id IS NOT NULL THEN
       SELECT contingency_id, revrec_event_code, revrec_expiration_days
       INTO x_contingency_id, x_revrec_event_code,x_revrec_expiration_days
       FROM oe_order_lines_all
       WHERE line_id = p_line_rec.top_model_line_id;
      END IF;
 ELSIF p_line_rec.item_type_code = 'SERVICE' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' -  Get from service parent' );
      END IF;
      IF p_line_rec.service_reference_type_code = 'CUSTOMER_PRODUCT' AND
           p_line_rec.service_reference_line_id IS NOT NULL THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS A CUSTOMER PRODUCT' ) ;
           END IF;
           OE_SERVICE_UTIL.Get_Cust_Product_Line_Id
           ( x_return_status    => l_return_status
           , p_reference_line_id => p_line_rec.service_reference_line_id
           , p_customer_id       => p_line_rec.sold_to_org_id
           , x_cust_product_line_id => l_order_line_id
           );
           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'SERVICE LINE ID IS ' || L_ORDER_LINE_ID ) ;
                      END IF;
              l_service_reference_line_id := l_order_line_id;
           ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'NOT ABLE TO RETRIEVE CUST PRODUCT LINE ID' ) ;
              END IF;
                      FND_MESSAGE.SET_NAME('ONT','ONT_NO_CUST_PROD_LINE');
                      OE_MSG_PUB.ADD;
		      RAISE NO_DATA_FOUND;
           END IF;
      ELSE
            l_service_reference_line_id := p_line_rec.service_reference_line_id;
      END IF;

      IF l_service_reference_line_id IS NOT NULL THEN
            SELECT contingency_id,revrec_event_code,revrec_expiration_days,item_type_code,top_model_line_id
            INTO x_contingency_id,x_revrec_event_code,x_revrec_expiration_days,l_item_type_code,l_top_model_line_id
            FROM oe_order_lines_all
            WHERE line_id= l_service_reference_line_id;

           IF l_item_type_code IN ('MODEL','STANDARD') OR
	       (l_item_type_code = 'KIT' AND l_top_model_line_id=l_service_reference_line_id) THEN
	      --service attached to a parent already assigned
              NULL;
           ELSIF l_top_model_line_id IS NOT NULL THEN -- service attached to a child line
                 SELECT contingency_id, revrec_event_code, revrec_expiration_days
                 INTO x_contingency_id, x_revrec_event_code, x_revrec_expiration_days
                 FROM oe_order_lines_all
                 WHERE line_id=l_top_model_line_id;
           END IF;
      END IF;
  ELSE -- standard line or top model
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' top_model_line_id:'||p_line_rec.top_model_line_id );
      END IF;
         x_contingency_id := p_line_rec.contingency_id;
         x_revrec_event_code := p_line_rec.revrec_event_code;
         x_revrec_expiration_days:= p_line_rec.revrec_expiration_days;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
         x_contingency_id := NULL;
         x_revrec_event_code := NULL;
         x_revrec_expiration_days:= NULL;

         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  'Get_Contingency_Attributes'
            );

END Get_Contingency_Attributes;


FUNCTION Pre_billing_acceptance_on(p_line_rec IN OE_Order_PUB.Line_Rec_Type ) RETURN BOOLEAN
IS
 l_service_reference_line_id NUMBER;
 l_return_status VARCHAR2(1);
 l_item_type_code VARCHAR2(30);
 l_order_line_id NUMBER;
 l_top_model_line_id NUMBER;
 l_contingency_id NUMBER;
 l_revrec_event_code VARCHAR2(30);
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

   IF p_line_rec.line_category_code = 'RETURN' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Return Line, Return FALSE' );
      END IF;
      RETURN FALSE;

ELSIF p_line_rec.source_document_type_id = 10 THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Internal Order Line, Return FALSE' );
      END IF;
      RETURN FALSE;

ELSIF p_line_rec.order_source_id = 27 AND p_line_rec.retrobill_request_id IS NOT NULL THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Retrobill Line, Return FALSE' );
      END IF;
      RETURN FALSE;

ELSIF p_line_rec.item_type_code IN ('CONFIG', 'CLASS', 'OPTION', 'INCLUDED')
 	    OR (p_line_rec.item_type_code = 'KIT' and p_line_rec.top_model_line_id <> p_line_rec.line_id) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' -  Get from parent:'||p_line_rec.top_model_line_id );
      END IF;
      IF p_line_rec.top_model_line_id IS NOT NULL THEN
       SELECT contingency_id, revrec_event_code
       INTO l_contingency_id, l_revrec_event_code
       FROM oe_order_lines_all
       WHERE line_id = p_line_rec.top_model_line_id;
      END IF;

           IF  l_contingency_id IS NOT NULL AND l_revrec_event_code='INVOICING' THEN
                   RETURN TRUE;
           ELSE
                   RETURN FALSE;
           END IF;
ELSIF p_line_rec.item_type_code = 'SERVICE' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' -  Get from service parent' );
        END IF;
       IF  p_line_rec.service_reference_type_code='CUSTOMER_PRODUCT' AND
        p_line_rec.service_reference_line_id IS NOT NULL THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS A CUSTOMER PRODUCT' ) ;
           END IF;
           OE_SERVICE_UTIL.Get_Cust_Product_Line_Id
           ( x_return_status    => l_return_status
           , p_reference_line_id => p_line_rec.service_reference_line_id
           , p_customer_id       => p_line_rec.sold_to_org_id
           , x_cust_product_line_id => l_order_line_id
           );
           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'SERVICE LINE ID IS ' || L_ORDER_LINE_ID ) ;
                      END IF;
              l_service_reference_line_id := l_order_line_id;
           ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'NOT ABLE TO RETRIEVE CUST PRODUCT LINE ID' ) ;
              END IF;
                      FND_MESSAGE.SET_NAME('ONT','ONT_NO_CUST_PROD_LINE');
                      OE_MSG_PUB.ADD;
                      --RAISE NO_DATA_FOUND;
           END IF;
       ELSE
        l_service_reference_line_id := p_line_rec.service_reference_line_id;
       END IF;

     IF l_service_reference_line_id IS NOT NULL THEN
        SELECT contingency_id, revrec_event_code,item_type_code,  top_model_line_id
        INTO l_contingency_id, l_revrec_event_code,l_item_type_code,  l_top_model_line_id
        FROM oe_order_lines_all
        WHERE line_id= l_service_reference_line_id;

           IF l_item_type_code IN ('MODEL', 'STANDARD') OR
	    (l_item_type_code = 'KIT' AND l_top_model_line_id=l_service_reference_line_id) THEN --service attached to a parent
                IF  l_contingency_id IS NOT NULL AND l_revrec_event_code='INVOICING' THEN
                   RETURN TRUE;
                ELSE
                   RETURN FALSE;
                END IF;
           ELSIF l_top_model_line_id IS NOT NULL THEN -- service attached to a child line
              SELECT contingency_id, revrec_event_code
              INTO l_contingency_id, l_revrec_event_code
              FROM oe_order_lines_all
              WHERE line_id=l_top_model_line_id;
           END IF;
           IF  l_contingency_id IS NOT NULL AND l_revrec_event_code='INVOICING' THEN
                   RETURN TRUE;
           ELSE
                   RETURN FALSE;
           END IF;
     ELSE -- if service_reference_line_id is null
         RETURN FALSE;
     END IF;
ELSE -- standard line or top model
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' top_model_line_id:'||p_line_rec.top_model_line_id );
      END IF;
             IF  p_line_rec.contingency_id IS NOT NULL AND p_line_rec.revrec_event_code='INVOICING' THEN
                   RETURN TRUE;
             ELSE
                   RETURN FALSE;
             END IF;
END IF;

RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  ' Pre_billing_acceptance_on'
            );
	 RETURN FALSE;

END Pre_billing_acceptance_on;

--Overloaded to accept line_id as parameter
FUNCTION Pre_billing_acceptance_on (p_line_id IN NUMBER) RETURN BOOLEAN
IS
   l_line_rec OE_ORDER_PUB.line_rec_type;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   OE_Line_Util.Query_Row(p_line_id => p_line_id,x_line_rec => l_line_rec);
   RETURN Pre_billing_acceptance_on (p_line_rec => l_line_rec);

EXCEPTION
  WHEN OTHERS THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  ' Pre_billing_acceptance_on'
            );
	 RETURN FALSE;
END Pre_billing_acceptance_on;

FUNCTION Post_billing_acceptance_on (p_line_rec IN OE_Order_PUB.Line_Rec_Type) RETURN BOOLEAN IS
 l_service_reference_line_id NUMBER;
 l_return_status VARCHAR2(1);
 l_item_type_code VARCHAR2(30);
 l_order_line_id NUMBER;
 l_top_model_line_id NUMBER;
 l_contingency_id NUMBER;
 l_revrec_event_code VARCHAR2(30);
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

   IF p_line_rec.line_category_code = 'RETURN' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Return Line, Return FALSE' );
      END IF;
      RETURN FALSE;

ELSIF p_line_rec.source_document_type_id = 10 THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Internal Order Line, Return FALSE' );
      END IF;
      RETURN FALSE;

ELSIF p_line_rec.order_source_id = 27 AND p_line_rec.retrobill_request_id IS NOT NULL THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Retrobill Line, Return FALSE' );
      END IF;
      RETURN FALSE;

ELSIF p_line_rec.item_type_code IN ('CONFIG', 'CLASS', 'OPTION', 'INCLUDED')
  	    OR (p_line_rec.item_type_code = 'KIT' and p_line_rec.top_model_line_id <> p_line_rec.line_id) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' -  Get from parent:'||p_line_rec.top_model_line_id );
      END IF;
      IF p_line_rec.top_model_line_id IS NOT NULL THEN
       SELECT contingency_id, revrec_event_code
       INTO l_contingency_id, l_revrec_event_code
       FROM oe_order_lines_all
       WHERE line_id = p_line_rec.top_model_line_id;
      END IF;

           IF  l_contingency_id IS NOT NULL AND l_revrec_event_code='CUSTOMER_ACCEPTANCE' THEN
                   RETURN TRUE;
           ELSE
                   RETURN FALSE;
           END IF;
ELSIF p_line_rec.item_type_code = 'SERVICE' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' -  Get from service parent' );
        END IF;
       IF  p_line_rec.service_reference_type_code='CUSTOMER_PRODUCT' AND
        p_line_rec.service_reference_line_id IS NOT NULL THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS A CUSTOMER PRODUCT' ) ;
           END IF;
           OE_SERVICE_UTIL.Get_Cust_Product_Line_Id
           ( x_return_status    => l_return_status
           , p_reference_line_id => p_line_rec.service_reference_line_id
           , p_customer_id       => p_line_rec.sold_to_org_id
           , x_cust_product_line_id => l_order_line_id
           );
           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'SERVICE LINE ID IS ' || L_ORDER_LINE_ID ) ;
                      END IF;
              l_service_reference_line_id := l_order_line_id;
           ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'NOT ABLE TO RETRIEVE CUST PRODUCT LINE ID' ) ;
              END IF;
                      FND_MESSAGE.SET_NAME('ONT','ONT_NO_CUST_PROD_LINE');
                      OE_MSG_PUB.ADD;
                      --RAISE NO_DATA_FOUND;
           END IF;
       ELSE
        l_service_reference_line_id := p_line_rec.service_reference_line_id;
       END IF;

     IF l_service_reference_line_id IS NOT NULL THEN
        SELECT contingency_id, revrec_event_code,item_type_code,  top_model_line_id
        INTO l_contingency_id, l_revrec_event_code,l_item_type_code,  l_top_model_line_id
        FROM oe_order_lines_all
        WHERE line_id= l_service_reference_line_id;

           IF l_item_type_code IN ('MODEL', 'STANDARD') OR
	    (l_item_type_code = 'KIT' AND l_top_model_line_id=l_service_reference_line_id) THEN --service attached to a parent
                IF  l_contingency_id IS NOT NULL AND l_revrec_event_code='CUSTOMER_ACCEPTANCE' THEN
                   RETURN TRUE;
                ELSE
                   RETURN FALSE;
                END IF;
           ELSIF l_top_model_line_id IS NOT NULL THEN -- service attached to a child line
              SELECT contingency_id, revrec_event_code
              INTO l_contingency_id, l_revrec_event_code
              FROM oe_order_lines_all
              WHERE line_id=l_top_model_line_id;
           END IF;
           IF  l_contingency_id IS NOT NULL AND l_revrec_event_code='CUSTOMER_ACCEPTANCE' THEN
                   RETURN TRUE;
           ELSE
                   RETURN FALSE;
           END IF;
     ELSE -- service_refernce_line_id null
          RETURN FALSE;
     END IF;
ELSE -- standard line or top model
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' top_model_line_id:'||p_line_rec.top_model_line_id );
      END IF;
             IF  p_line_rec.contingency_id IS NOT NULL AND p_line_rec.revrec_event_code='CUSTOMER_ACCEPTANCE' THEN
                   RETURN TRUE;
             ELSE
                   RETURN FALSE;
             END IF;
END IF;

RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  ' Post_billing_acceptance_on'
            );
	 RETURN FALSE;
END Post_billing_acceptance_on;

--Overloaded to accept line_id as parameter
FUNCTION Post_billing_acceptance_on (p_line_id IN NUMBER) RETURN BOOLEAN
IS
l_line_rec OE_ORDER_PUB.line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
      OE_Line_Util.Query_Row(p_line_id => p_line_id,
                 x_line_rec => l_line_rec);

      RETURN Post_billing_acceptance_on (p_line_rec => l_line_rec);
EXCEPTION
  WHEN OTHERS THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  ' Post_billing_acceptance_on'
            );
	 RETURN FALSE;
END Post_billing_acceptance_on;

FUNCTION Customer_acceptance_Eligible (p_line_rec IN OE_Order_PUB.Line_Rec_Type) RETURN BOOLEAN IS
l_count NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF p_line_rec.line_category_code = 'RETURN' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Return Line, Return FALSE' );
      END IF;
      RETURN FALSE;

ELSIF p_line_rec.source_document_type_id = 10 THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Internal Order Line, Return FALSE' );
      END IF;
      RETURN FALSE;

ELSIF p_line_rec.order_source_id = 27 AND p_line_rec.retrobill_request_id IS NOT NULL THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Retrobill Line, Return FALSE' );
      END IF;
      RETURN FALSE;
ELSIF p_line_rec.item_type_code IN ('CONFIG', 'CLASS', 'OPTION', 'INCLUDED')
	 OR  (p_line_rec.item_type_code = 'KIT' and p_line_rec.top_model_line_id <> p_line_rec.line_id) THEN --child line

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code);
      END IF;
      RETURN FALSE;
ELSIF p_line_rec.item_type_code = 'SERVICE' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' -  Get from service parent' );
        END IF;
        IF  p_line_rec.service_reference_type_code='ORDER' THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE is a service with reference type ORDER' ) ;
           END IF;
           RETURN FALSE;
         -- Acceptance of customer product services should not be allowed through UI.
         -- But explicit acceptance should be allowed
        ELSIF p_line_rec.service_reference_type_code='CUSTOMER_PRODUCT' THEN
               IF p_line_rec.flow_status_code in ('PRE-BILLING_ACCEPTANCE', 'POST-BILLING_ACCEPTANCE') THEN
                    RETURN TRUE;
               ELSE
                   RETURN FALSE;
              END IF;
        END IF;
ELSE -- Now it could be a model, kit or standard line
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Item_type_code:'||p_line_rec.item_type_code||' top_model_line_id'|| p_line_rec.top_model_line_id);
      END IF;
     IF p_line_rec.top_model_line_id IS NOT NULL AND p_line_rec.top_model_line_id = p_line_rec.line_id THEN
        IF p_line_rec.flow_status_code NOT IN ('PRE-BILLING_ACCEPTANCE', 'POST-BILLING_ACCEPTANCE') THEN
           RETURN FALSE;
        ELSE
	--top model line use exists
                  SELECT count(*)
                  INTO l_count
                  FROM oe_order_lines_all
                  WHERE header_id = p_line_rec.header_id
                  AND top_model_line_id = p_line_rec.line_id
                  AND flow_status_code NOT IN ('PRE-BILLING_ACCEPTANCE', 'POST-BILLING_ACCEPTANCE')
                  AND nvl(open_flag, 'Y') = 'Y';

                  IF l_count = 0 THEN
                       RETURN TRUE;
                 ELSE
                       RETURN FALSE;
                 END IF;
        END IF;
       ELSE -- standard line
            IF p_line_rec.flow_status_code in ('PRE-BILLING_ACCEPTANCE', 'POST-BILLING_ACCEPTANCE') THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
      END IF;
END IF;

RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  'Customer_acceptance_Eligible'
            );
	 RETURN FALSE;
END Customer_acceptance_Eligible;

--Overloaded to accept line_id as parameter
FUNCTION Customer_Acceptance_Eligible (p_line_id IN NUMBER) RETURN BOOLEAN IS
l_line_rec OE_ORDER_PUB.line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
      OE_Line_Util.Query_Row(p_line_id => p_line_id,
                 x_line_rec => l_line_rec);

      RETURN Customer_Acceptance_Eligible(p_line_rec => l_line_rec);

 EXCEPTION
  WHEN OTHERS THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  'Customer_acceptance_Eligible'
            );
	 RETURN FALSE;
END Customer_Acceptance_Eligible;

FUNCTION Acceptance_Status(p_line_rec IN OE_Order_PUB.Line_Rec_Type) RETURN VARCHAR2 IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF p_line_rec.accepted_quantity IS NULL OR  p_line_rec.accepted_quantity = FND_API.G_MISS_NUM THEN
     -- consider closed lines as accepted because parent line might have been closed
     -- without acceptance (ex: from progress order when system param turned off)
     IF nvl(p_line_rec.open_flag, 'Y') = 'N' THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('returning as accepted because line '||p_line_rec.line_id||' is already closed');
        END IF;
        RETURN 'ACCEPTED';
     ELSE
        RETURN 'NOT_ACCEPTED';
     END IF;
  ELSIF p_line_rec.accepted_quantity = 0 THEN
          RETURN 'REJECTED';
  ELSE
           RETURN 'ACCEPTED';
  END IF;

END Acceptance_Status;

--Overloaded to accept line_id as parameter

FUNCTION Acceptance_Status(p_line_id IN NUMBER) RETURN VARCHAR2 IS
l_accepted_quantity NUMBER;
l_open_flag VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     SELECT accepted_quantity, open_flag
     INTO l_accepted_quantity, l_open_flag
     FROM oe_order_lines_all
     WHERE line_id = p_line_id;

      IF l_accepted_quantity is NULL OR  l_accepted_quantity = FND_API.G_MISS_NUM THEN
     -- consider closed lines as accepted because parent line might have been closed
     -- without acceptance (ex: from progress order when system param turned off)
        IF nvl(l_open_flag, 'Y') = 'N' THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('returning as accepted because line '||p_line_id||' is already closed');
           END IF;
           RETURN 'ACCEPTED';
        ELSE
           RETURN 'NOT_ACCEPTED';
        END IF;
      ELSIF l_accepted_quantity = 0 THEN
          RETURN 'REJECTED';
      ELSE
           RETURN 'ACCEPTED';
      END IF;
 EXCEPTION
  WHEN OTHERS THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  'Acceptance_Status'
            );
	 RETURN 'NOT_ACCEPTED';

END Acceptance_Status;

END OE_ACCEPTANCE_UTIL;

/
