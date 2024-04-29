--------------------------------------------------------
--  DDL for Package Body OZF_ADJUSTMENT_EXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ADJUSTMENT_EXT_PVT" AS
   /*$Header: ozfvadeb.pls 120.55.12010000.7 2010/05/26 16:16:21 nirprasa ship $*/

-----------------------------------------------------------
-- PACKAGE
--    OZF_Adjustment_EXT_PVT
--
-- PROCEDURES
--  adjust_backdated_offer
--  process_offer_product
-- HISTORY
--    4/18/2002  Mumu Pande  Create.
--    10/17/2003 Ying Zhao    fix bug 3197570 - BACKDATED ADJUSTMENTS FOR AMOUNT TYPE DICOUNT RULE
--    12/14/2003 kdass        changed table name from ams_temp_eligibility to ozf_temp_eligibility
--    02/09/2004 yzhao        fix bug MASS1R1011510:REOP:VOLUME OFFER DISCOUNT LEVL NOT CHANGING EVEN AFTER REACHG VOL
--                                offer notes object should remain in AMS_OFFR, not OZF_OFFR
--    07/08/2004 kdass        changed the dynamic cursors in perform_adjustment to static cursors
--    07/19/2004 kdass        fix for 11.5.9 bug 3742174
--    16/11/2004 Ribha        Fix for bug 4013141 - Volume offer adjustment should get applied only when there is a tier-change.
--    17/11/2004 Ribha        Fix for bug 4015372 - Backdated adjustments should not get closed if not applied.
--    01/05/2005 kdass        fix for 11.5.9 bug 4033558 - handle volume offer adjustments for RMA order
--    01/31/2005 kdass        fix for 11.5.10 bug 4129759 - handle backdated adjustments for multi-tier discounts
--    05/05/2005 Ribha        fix for bug 4309014
--    05/11/2005 Ribha        fix for bug 4357772
--    05/11/2005 kdass        fix for 11.5.10 bug 4362575 - for all types of volume offers - offinvoice or accrual,
--                            consider list price instead of selling price
--    08/16/2005 feliu        fix backdated adjustment for third party accrual.
--                            Third party accrual support following offers:
--                            Accrual, off-invoice, trade deal.
--    12/09/2005 kdass        fix for bug 4872799
--    02/28/2006 kdass        fixed bug 5059735
--    03/31/2006 kdass        fixed bug 5101720
--    05/05/2006 kdass        fixed bugs 5205721, 5198547
--    06/21/2006 kdass        fixed bug 5337761
--    07/31/2006 kpatro       fixed bug 5375224 for SQL ID# 19125146
--    08/04/2006 kdass        fixed bug 5446622
--    08/24/2006 kdass        fixed bug 5485172
--    09/11/2006 kdass        fixed bug 5497876
--    12/04/2006 feliu        fixed bug 5675871,5671169,and 5689866
--    02/24/2007 kdass        fixed bug 5610124 - retroactive adjustments for volume offer before offer start date
--    04/04/2007 nirprasa     fix for bug 5944862
--    04/13/2007 nirprasa     fixed bug 5975203
--    04/13/2007 nirprasa     fixed bug 5767748
--    04/13/2007 nirprasa     fixed bug 5979971
--    05/11/2007 nirprasa     fixed bug 6021635 - added volume_offer_util_adjustment for utilized amount and
--                            changed adjustment_volume_retro for booked orders.
--    05/21/2007 kdass        fixed bug 6059036
--    05/28/2007 nirprasa     fixed bug 6077042
--    06/27/2007 nirprasa     fixed bug 6021538
--    08/16/2007 nirprasa     fixed bug 6345305
--    08/16/2007 nirprasa     fixed bug 6369218
--    04/21/2008 psomyaju     Bugfix 6278466 - FP:11510-R12 6051298 - FUNDS EARNED NOT RECOGNISED AS ELIGBLE FOR
--    08/01/2008 nirprasa     fixed bug 7030415
--    05/24/2009 kdass        fixed bug 8510774 - FP: 11.5.10-R12 8408922 - TMR4: OFFER ADJUSTMENTS FAIL AND NO OFFER ADJUSTMENTS
--    1/27/2010  nepanda      Fix for bug 9318975 - volume offer with discount amount tiers has no accrued earnings as there should
--    2/17/2010  nepanda      Bug 9131648 : multi currency changes
------------------------------------------------------------

   g_pkg_name       CONSTANT VARCHAR2 (30) := 'OZF_Adjustment_Ext_PVT';
   g_recal_flag     CONSTANT VARCHAR2(1) :=  NVL(fnd_profile.value('OZF_BUDGET_ADJ_ALLOW_RECAL'),'N');
   g_order_gl_phase CONSTANT VARCHAR2 (15) :=NVL(fnd_profile.VALUE ('OZF_ORDER_GLPOST_PHASE'), 'SHIPPED');
   g_debug_flag     VARCHAR2 (1) := 'N';
   G_DEBUG          BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   g_bulk_limit     CONSTANT NUMBER := 5000;

   TYPE amountTbl       IS TABLE OF ozf_funds_utilized_all_b.amount%TYPE;
   TYPE glDateTbl       IS TABLE OF ozf_funds_utilized_all_b.gl_date%TYPE;
   TYPE objectTypeTbl   IS TABLE OF ozf_funds_utilized_all_b.object_type%TYPE;
   TYPE objectIdTbl     IS TABLE OF ozf_funds_utilized_all_b.object_id%TYPE;
   TYPE priceAdjustmentIDTbl     IS TABLE OF ozf_funds_utilized_all_b.price_adjustment_id%TYPE;
   TYPE glPostedFlagTbl     IS TABLE OF ozf_funds_utilized_all_b.gl_posted_flag%TYPE;
   TYPE orderLineIdTbl     IS TABLE OF ozf_funds_utilized_all_b.order_line_id%TYPE;
   TYPE utilizationIdTbl IS TABLE OF ozf_funds_utilized_all_b.utilization_id%TYPE; --Added for bug 7030415

   TYPE order_line_rec_type IS RECORD(order_header_id               NUMBER
                                     ,order_line_id                 NUMBER
                                     ,inventory_item_id             NUMBER
                                     ,unit_list_price               NUMBER
                                     ,quantity                      NUMBER
                                     ,transactional_curr_code       oe_order_headers_all.transactional_curr_code%TYPE
                                     ,line_category_code            oe_order_lines_all.line_category_code%TYPE
                                     ,reference_line_id             NUMBER
                                     ,order_number                  NUMBER
                                     ,group_nos                     VARCHAR2(256)
                                     );

    TYPE order_line_tbl_type IS TABLE OF order_line_rec_type INDEX BY BINARY_INTEGER;
    TYPE offer_id_tbl IS TABLE OF NUMBER index by binary_integer;
    TYPE product_attr_val_cursor_type is ref cursor;
    g_offer_id_tbl offer_id_tbl;


-------------------------------------------------------------------
-- PROCEDURE
--    process_offer_product
-- PURPOSE
--
-- PARAMETERS
--   p_offer_adjustment_id    IN NUMBER
-- History
--    4/18/2002  Mumu Pande  Create.
----------------------------------------------------------------
   PROCEDURE process_offer_product (
      p_offer_adjustment_id  IN     NUMBER,
      x_return_status        OUT NOCOPY    VARCHAR2
   );

---------------------------------------------------------------------
-- PROCEDURE
--     perform_adjustment
--
-- PURPOSE
--
-- PARAMETERS
--   p_from_date     IN DATE
--   p_to_Date       IN DATE
--   p_qp_list_header_id      IN NUMBER
-- NOTES
-- HISTORY
--    4/18/2002  Mumu Pande  Create.
----------------------------------------------------------------------
   PROCEDURE perform_adjustment (
      p_from_date             IN       DATE,
      p_to_date               IN       DATE,
      p_qp_list_header_id     IN       NUMBER,
      p_offer_adjustment_id   IN       NUMBER,
      p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false,
      p_commit                IN       VARCHAR2 := fnd_api.g_false,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_msg_count             OUT NOCOPY      NUMBER,
      x_msg_data              OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------------
-- Procedure Name
--   write_con_log
-- Purpose
-- to write some debug message in the log file
-- History
-- 7/22/2002  mpande Created
-- 10/21/2002  mpande Changed for GSCC warnings
------------------------------------------------------------------------------
PROCEDURE write_conc_log ( p_text IN VARCHAR2)
                           IS
   BEGIN
      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log (p_text);
        --ozf_utility_pvt.debug_message(p_text);
      END IF;
   END;

---------------------------------------------------------------------
-- PROCEDURE
--    get_orders
-- PURPOSE
--    returns qualified orders (copy of ozf_net_accrual_engine_pvt.offer_adj_new_product)
-- HISTORY
-- 12/30/2005  kdass Created
----------------------------------------------------------------------
   PROCEDURE get_orders(
      p_api_version    IN  NUMBER
     ,p_init_msg_list  IN  VARCHAR2
     ,p_commit         IN  VARCHAR2
     ,x_return_status  OUT NOCOPY VARCHAR2
     ,x_msg_count      OUT NOCOPY NUMBER
     ,x_msg_data       OUT NOCOPY VARCHAR2
     ,p_list_header_id IN  NUMBER
     ,p_offer_org_id   IN  NUMBER
     ,p_offer_currency IN  VARCHAR2
     ,p_list_line_id   IN  VARCHAR2
     ,p_start_date     IN  DATE
     ,p_end_date       IN  DATE
     ,x_order_line_tbl OUT NOCOPY order_line_tbl_type)
   IS

      --kdass 05-MAY-2006 bug 5198547 - split cursor c_order_line into 2 for using hints suggested by perf team
      CURSOR c_order_line IS
         SELECT /*+ leading(temp) use_nl(temp line header) */
                line.header_id, line.line_id, line.inventory_item_id, line.unit_list_price,
                NVL(line.shipped_quantity, NVL(line.ordered_quantity, 0)) quantity,
                header.transactional_curr_code, line.invoice_to_org_id,
                line.sold_to_org_id, line.ship_to_org_id,line.line_category_code, line.reference_line_id,
                header.order_number, header.org_id
         FROM   oe_order_lines_all line, oe_order_headers_all header,
                (SELECT DISTINCT eligibility_id FROM ozf_temp_eligibility) temp
         WHERE  trunc(NVL(line.pricing_date, NVL(line.actual_shipment_date, line.fulfillment_date)))
                BETWEEN p_start_date AND p_end_date
         AND    line.booked_flag = 'Y'
         AND    line.cancelled_flag = 'N'
         --AND    line.line_category_code <> 'RETURN'
         AND    line.inventory_item_id = temp.eligibility_id
         AND    line.header_id = header.header_id;

      CURSOR c_order_line1 IS
         SELECT /*+ parallel(line) */
                line.header_id, line.line_id, line.inventory_item_id, line.unit_list_price,
                NVL(line.shipped_quantity, NVL(line.ordered_quantity, 0)) quantity,
                header.transactional_curr_code, line.invoice_to_org_id,
                line.sold_to_org_id, line.ship_to_org_id,line.line_category_code, line.reference_line_id,
                header.order_number, header.org_id
         FROM   oe_order_lines_all line, oe_order_headers_all header,
                (SELECT DISTINCT eligibility_id FROM ozf_temp_eligibility) temp
         WHERE  trunc(NVL(line.pricing_date, NVL(line.actual_shipment_date, line.fulfillment_date)))
                BETWEEN p_start_date AND p_end_date
         AND    line.booked_flag = 'Y'
         AND    line.cancelled_flag = 'N'
         --AND    line.line_category_code <> 'RETURN'
         AND    line.inventory_item_id = temp.eligibility_id
         AND    line.header_id = header.header_id;

      CURSOR c_count_temp IS
         SELECT COUNT(DISTINCT eligibility_id)
         FROM   ozf_temp_eligibility;

      -- Segment and buying group has no acct info. use party_id for validation
      CURSOR c_party_id(p_sold_to_org_id IN NUMBER) IS
         SELECT party_id
         FROM   hz_cust_accounts
         WHERE  cust_account_id = p_sold_to_org_id;

      CURSOR c_customer_qualified(p_invoice_to_org_id IN NUMBER, p_ship_to_org_id IN NUMBER, p_party_id NUMBER) IS
         SELECT 'Y', object_type, qp_qualifier_group
         FROM   ozf_activity_customers
         WHERE  (
                  (site_use_id = p_invoice_to_org_id AND site_use_code = 'BILL_TO') OR
                  (site_use_id = p_ship_to_org_id    AND site_use_code = 'SHIP_TO') OR
                  (party_id    = p_party_id          AND site_use_code IS NULL)     OR
                  (party_id = -1)
                )
         AND    object_class = 'OFFR'
         AND    object_id = p_list_header_id
         AND    ROWNUM = 1;

      CURSOR c_cust_acct_qualified(p_sold_to_org_id IN NUMBER, p_party_id NUMBER) IS
         SELECT 'Y', object_type, qp_qualifier_group
         FROM   ozf_activity_customers
         WHERE  (
                  (cust_account_id = p_sold_to_org_id) OR
                  (party_id        = p_party_id AND site_use_code IS NULL) OR
                  (party_id = -1)
                )
         AND    object_class = 'OFFR'
         AND    object_id = p_list_header_id
         AND    ROWNUM = 1;

      TYPE numberTbl             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE orderCurrTbl          IS TABLE OF oe_order_headers_all.transactional_curr_code%TYPE;
      TYPE lineCatCodeTbl        IS TABLE OF oe_order_lines_all.line_category_code%TYPE;
      TYPE groupNosTbl           IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;

      l_headerIdTbl              numberTbl;
      l_lineIdTbl                numberTbl;
      l_inventoryItemIdTbl       numberTbl;
      l_unitListPriceTbl         numberTbl;
      l_quantityTbl              numberTbl;
      l_orderCurrTbl             orderCurrTbl;
      l_invoiceToOrgIdTbl        numberTbl;
      l_soldToOrgIdTbl           numberTbl;
      l_shipToOrgIdTbl           numberTbl;
      l_lineCatCodeTbl           lineCatCodeTbl;
      l_refLineIdTbl             numberTbl;
      l_orderNumberTbl           numberTbl;
      l_group_nos                groupNosTbl;
      l_orgIdTbl                 numberTbl;

      l_party_id                 NUMBER;
      l_customer_qualified       VARCHAR2(1) := 'Y';
      l_tbl_index                NUMBER := 1;
      l_api_name                 CONSTANT VARCHAR2(30) := 'get_orders';

      l_stmt_denorm              VARCHAR2(32000) := NULL;
      l_denorm_csr               NUMBER;
      l_ignore                   NUMBER;
      l_product_stmt             VARCHAR2(32000) := NULL;
      l_count_temp               NUMBER;
      l_object_type              VARCHAR2(20);
      l_group                    NUMBER;
      l_group_string             VARCHAR2(256);
      l_org_match                VARCHAR2(1);
      l_currency_match           VARCHAR2(1);

   BEGIN

      IF Fnd_Api.to_boolean(p_init_msg_list) THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      x_return_status := Fnd_Api.g_ret_sts_success;

      --kdass 28-FEB-2006 fixed bug 5059735 - denorm offer's product eligibility to handle all types of product levels
      EXECUTE IMMEDIATE 'DELETE FROM ozf_temp_eligibility';

      FND_DSQL.init;
      FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, eligibility_id) ');
      FND_DSQL.add_text('(SELECT  ''OFFR'', product_id ' );
      FND_DSQL.add_text(' FROM ( ');

      /*kdass 05-MAY-2006 bug 5205721 - use refresh_products() as it considers excluded items
      l_temp_sql := ozf_offr_elig_prod_denorm_pvt.get_sql(p_context         => 'ITEM'
                                                         ,p_attribute       => p_product_attr
                                                         ,p_attr_value_from => p_product
                                                         ,p_attr_value_to   => NULL
                                                         ,p_comparison      => NULL
                                                         ,p_type            => 'PROD'
                                                         );
      */

      --kdass 21-JUN-2006 bug 5337761 - added exception handling code
      BEGIN
         SAVEPOINT refresh_prod;

         ozf_offr_elig_prod_denorm_pvt.refresh_products(p_api_version      => p_api_version
                                                       ,p_init_msg_list    => p_init_msg_list
                                                       ,p_commit           => p_commit
                                                       ,p_list_header_id   => p_list_header_id
                                                       ,p_calling_from_den => 'N'
                                                       ,x_return_status    => x_return_status
                                                       ,x_msg_count        => x_msg_count
                                                       ,x_msg_data         => x_msg_data
                                                       ,x_product_stmt     => l_product_stmt
                                                       ,p_lline_id         => p_list_line_id
                                                       );

         FND_DSQL.add_text('))');

         write_conc_log ('l_product_stmt: ' || l_product_stmt);

         l_denorm_csr := DBMS_SQL.open_cursor;
         FND_DSQL.set_cursor(l_denorm_csr);
         l_stmt_denorm := FND_DSQL.get_text(FALSE);
         DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
         FND_DSQL.do_binds;
         l_ignore := DBMS_SQL.execute(l_denorm_csr);

      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK TO refresh_prod;
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            write_conc_log ('unexpected exception in refresh_products');
      END;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      l_count_temp := 0;

      OPEN c_count_temp;
      FETCH c_count_temp INTO l_count_temp;
      CLOSE c_count_temp;

      IF l_count_temp < 6 THEN
         OPEN c_order_line;
      ELSE
         OPEN c_order_line1;
      END IF;

      LOOP

         IF l_count_temp < 6 THEN
            FETCH c_order_line BULK COLLECT INTO l_headerIdTbl, l_lineIdTbl, l_inventoryItemIdTbl,
                                                 l_unitListPriceTbl, l_quantityTbl, l_orderCurrTbl,
                                                 l_invoiceToOrgIdTbl, l_soldToOrgIdTbl, l_shipToOrgIdTbl,
                                                 l_lineCatCodeTbl, l_refLineIdTbl, l_orderNumberTbl, l_orgIdTbl
                               LIMIT g_bulk_limit;
         ELSE
            FETCH c_order_line1 BULK COLLECT INTO l_headerIdTbl, l_lineIdTbl, l_inventoryItemIdTbl,
                                                  l_unitListPriceTbl, l_quantityTbl, l_orderCurrTbl,
                                                  l_invoiceToOrgIdTbl, l_soldToOrgIdTbl, l_shipToOrgIdTbl,
                                                  l_lineCatCodeTbl, l_refLineIdTbl, l_orderNumberTbl, l_orgIdTbl
                                LIMIT g_bulk_limit;
         END IF;

         IF l_lineIdTbl.FIRST IS NULL THEN
            EXIT;
         END IF;

         FOR i IN l_lineIdTbl.FIRST .. l_lineIdTbl.LAST
         LOOP

            write_conc_log ('order_line_id: ' || l_lineIdTbl(i));
            write_conc_log ('order currency: ' || l_orderCurrTbl(i));
            write_conc_log ('order org: ' || l_orgIdTbl(i));

            --kdass bug 8510774 - added validation between Offer's OU and Order's OU
            l_org_match := 'Y';
            IF p_offer_org_id IS NOT NULL AND p_offer_org_id <> l_orgIdTbl(i) THEN
               l_org_match := 'N';
            END IF;

            --kdass bug 8510774 - added validation between Offer's currency and Order's currency
            l_currency_match := 'Y';
            IF p_offer_currency IS NOT NULL AND p_offer_currency <> l_orderCurrTbl(i) THEN
               l_currency_match := 'N';
            END IF;

            IF l_org_match = 'Y' AND l_currency_match = 'Y' THEN

            OPEN  c_party_id (l_soldToOrgIdTbl(i));
            FETCH c_party_id INTO l_party_id;
            CLOSE c_party_id;

            l_customer_qualified := 'N';

            l_group := NULL;
            l_group_string := NULL;

            IF l_invoiceToOrgIdTbl(i) IS NULL AND l_shipToOrgIdTbl(i) IS NULL THEN

               --kdass bug 5610124
               OPEN c_cust_acct_qualified(l_soldToOrgIdTbl(i), l_party_id);
               LOOP
                  FETCH c_cust_acct_qualified INTO l_customer_qualified, l_object_type, l_group;
                  EXIT WHEN c_cust_acct_qualified%NOTFOUND;

                  IF l_object_type = 'VOLUME_OFFER' AND l_group IS NOT NULL THEN
                     l_group_string := l_group_string || ',' || l_group;
                  END IF;

               END LOOP;
               CLOSE c_cust_acct_qualified;

            ELSE

               --kdass bug 5610124
               OPEN  c_customer_qualified(l_invoiceToOrgIdTbl(i), l_shipToOrgIdTbl(i), l_party_id);
               LOOP
                  FETCH c_customer_qualified INTO l_customer_qualified, l_object_type, l_group;
                  EXIT WHEN c_customer_qualified%NOTFOUND;

                  IF l_object_type = 'VOLUME_OFFER' AND l_group IS NOT NULL THEN
                     l_group_string := l_group_string || ',' || l_group;
                  END IF;

               END LOOP;
               CLOSE c_customer_qualified;

            END IF;

            IF l_group_string IS NOT NULL THEN
               l_group_nos(i) := substr(l_group_string,2); --remove first comma
            END IF;

            END IF;

            write_conc_log ('l_org_match ' || l_org_match);
            write_conc_log ('l_currency_match ' || l_currency_match);
            write_conc_log ('l_customer_qualified: ' || l_customer_qualified);

            IF l_customer_qualified = 'Y' AND l_org_match = 'Y' AND l_currency_match = 'Y' THEN
               x_order_line_tbl(l_tbl_index).order_header_id               := l_headerIdTbl(i);
               x_order_line_tbl(l_tbl_index).order_line_id                 := l_lineIdTbl(i);
               x_order_line_tbl(l_tbl_index).inventory_item_id             := l_inventoryItemIdTbl(i);
               x_order_line_tbl(l_tbl_index).unit_list_price               := l_unitListPriceTbl(i);
               x_order_line_tbl(l_tbl_index).quantity                      := l_quantityTbl(i);
               x_order_line_tbl(l_tbl_index).transactional_curr_code       := l_orderCurrTbl(i);
               x_order_line_tbl(l_tbl_index).line_category_code            := l_lineCatCodeTbl(i);
               x_order_line_tbl(l_tbl_index).reference_line_id             := l_refLineIdTbl(i);
               x_order_line_tbl(l_tbl_index).order_number                  := l_orderNumberTbl(i);

               IF l_group_string IS NOT NULL THEN
                  x_order_line_tbl(l_tbl_index).group_nos                     := l_group_nos(i);
               END IF;

               l_tbl_index := l_tbl_index + 1;
            END IF;
         END LOOP; --FOR i IN l_line_id_tbl.FIRST .. l_line_id_tbl.LAST

         IF l_count_temp < 6 THEN
            EXIT WHEN c_order_line%NOTFOUND;
         ELSE
            EXIT WHEN c_order_line1%NOTFOUND;
         END IF;

      END LOOP;

      IF l_count_temp < 6 THEN
        CLOSE c_order_line;
      ELSE
        CLOSE c_order_line1;
      END IF;

   END get_orders;

---------------------------------------------------------------------
-- PROCEDURE
--    adjustment_net_accrual
-- PURPOSE
--    adjustment for new product and retroactive adjustment before offer start date
-- HISTORY
-- 4/22/2004  kdass Created
----------------------------------------------------------------------
   PROCEDURE adjustment_net_accrual (p_api_version              IN NUMBER
                                    ,p_offer_type               IN VARCHAR2
                                    ,p_original_discount        IN NUMBER
                                    ,p_modified_discount        IN NUMBER
                                    ,p_arithmetic_operator      IN VARCHAR2
                                    ,p_start_date               IN DATE
                                    ,p_end_date                 IN DATE
                                    ,p_list_header_id           IN NUMBER
                                    ,p_offer_org_id             IN NUMBER
                                    ,p_offer_currency           IN VARCHAR2
                                    ,p_list_line_id             IN VARCHAR2
                                    ,p_offer_adjustment_id      IN NUMBER
                                    ,p_type                     IN VARCHAR2
                                    ,x_return_status            IN OUT NOCOPY VARCHAR2
                                    ,x_msg_count                IN OUT NOCOPY NUMBER
                                    ,x_msg_data                 IN OUT NOCOPY VARCHAR2
                                    )
   IS

      CURSOR c_offer_info IS
         SELECT nvl(transaction_currency_code,fund_request_curr_code)offer_currency_code
               ,transaction_currency_code
               , beneficiary_account_id,autopay_party_attr,autopay_party_id -- Added for bug 7030415, correct org_id in accrual records
           FROM ozf_offers
          WHERE qp_list_header_id = p_list_header_id;

      CURSOR c_cust_number (p_header_id IN NUMBER) IS
         SELECT cust.cust_account_id
            FROM hz_cust_acct_sites_all acct_site,
                 hz_cust_site_uses_all site_use,
                 hz_cust_accounts  cust,
                 oe_order_headers_all header
            WHERE header.header_id = p_header_id
              AND acct_site.cust_acct_site_id = site_use.cust_acct_site_id
              AND acct_site.cust_account_id = cust.cust_account_id
              AND site_use.site_use_id = header.invoice_to_org_id ;

       --nirprasa, 12.1.1 enhancement, replace amount with plan_curr_amount column.
      --This is a bug since the original accrual is in offer currency.
      CURSOR c_order_adjustment_amt (p_object_id IN NUMBER, p_order_line_id IN NUMBER, p_prod_id IN NUMBER) IS
         SELECT SUM(plan_curr_amount)
            FROM ozf_funds_utilized_all_b
            WHERE plan_type = 'OFFR'
              AND plan_id = p_list_header_id
              AND object_type = 'ORDER'
              AND object_id = p_object_id
              AND order_line_id = p_order_line_id
              AND product_level_type = 'PRODUCT'
              AND product_id = p_prod_id
              AND utilization_type NOT IN ('REQUEST', 'TRANSFER'); --kdass 29-MAR-2006 bug 5120491
              --AND utilization_type = 'ADJUSTMENT';

        --nirprasa, 12.1.1 enhancement, replace amount with plan_curr_amount column.

        CURSOR c_orig_order_adj_amt (p_order_line_id IN NUMBER) IS
         SELECT SUM(plan_curr_amount)
         FROM ozf_funds_utilized_all_b
         WHERE plan_type = 'OFFR'
         AND plan_id = p_list_header_id
         AND order_line_id = p_order_line_id
         AND utilization_type NOT IN ('REQUEST', 'TRANSFER');

        CURSOR c_order_line (p_order_line_id IN NUMBER) IS
         SELECT NVL(invoiced_quantity, NVL(shipped_quantity, 0)) quantity,
                ship_to_org_id, invoice_to_org_id
         FROM   oe_order_lines_all
         WHERE  line_id = p_order_line_id;

      l_order_org_id              NUMBER;
      l_exchange_rate_type        VARCHAR2(30) := FND_API.G_MISS_CHAR;
      l_autopay_party_id          NUMBER;
      l_autopay_party_attr        VARCHAR2(30);
      l_org_id                    NUMBER; -- site's lorg id

      -- Added for bug 7030415. get order's org_id
      CURSOR c_order_org_id (p_line_id IN NUMBER) IS
         SELECT header.org_id
         FROM oe_order_lines_all line, oe_order_headers_all header
         WHERE line_id = p_line_id
         AND line.header_id = header.header_id;

      -- get conversion type
      CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;

       -- get sites org id type
      CURSOR c_org_id (p_site_use_id IN NUMBER) IS
         SELECT org_id
         FROM hz_cust_site_uses_all
         WHERE site_use_id = p_site_use_id;

      CURSOR c_offer_type (p_offer_id IN NUMBER) IS
         SELECT autopay_party_attr,autopay_party_id
         FROM   ozf_offers
         WHERE  qp_list_header_id = p_offer_id;

      l_offer_info           c_offer_info%ROWTYPE;

      l_util_amount          NUMBER;
      l_rate                 NUMBER;
      l_act_budget_id        NUMBER;
      l_total_price          NUMBER;
      l_cust_number          NUMBER;
      l_qp_list_header_id    NUMBER;
      l_error_location       NUMBER;
      l_line_ctr             NUMBER := 1;
      l_adj_amount           NUMBER := 0;

      l_act_budgets_rec      ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec         ozf_actbudgets_pvt.act_util_rec_type;
      l_modifier_list_rec    ozf_offer_pvt.modifier_list_rec_type;
      l_modifier_line_tbl    ozf_offer_pvt.modifier_line_tbl_type;
      l_order_line_tbl       order_line_tbl_type;

      l_api_name             VARCHAR2(50)   := 'adjustment_net_accrual';
      l_full_name   CONSTANT VARCHAR2(90)   :=  g_pkg_name || '.' || l_api_name;
      l_justification        VARCHAR2(50);
      l_conv_util_amount     NUMBER;
      l_orig_util_amount     NUMBER;
      l_orig_order_qty       NUMBER;
      l_ship_to_org_id       NUMBER;
      l_invoice_to_org_id    NUMBER;

      --nirprasa,12.2
      l_converted_util_amount NUMBER;
   BEGIN

      OPEN c_offer_info;
      FETCH c_offer_info INTO l_offer_info;
      CLOSE c_offer_info;

      write_conc_log ('p_type: ' || p_type);
      write_conc_log ('offer_id: ' || p_list_header_id);
      write_conc_log ('p_start_date: ' || p_start_date);
      write_conc_log ('p_end_date: ' || p_end_date);
      write_conc_log ('p_offer_adjustment_id: ' || p_offer_adjustment_id);
      write_conc_log ('p_list_line_id: ' || p_list_line_id);

      --get the qualified orders
      get_orders(p_api_version    => p_api_version
                ,p_init_msg_list  => FND_API.G_FALSE
                ,p_commit         => FND_API.G_FALSE
                ,x_return_status  => x_return_status
                ,x_msg_count      => x_msg_count
                ,x_msg_data       => x_msg_data
                ,p_list_header_id => p_list_header_id
                ,p_offer_org_id   => p_offer_org_id   --kdass bug 8510774 - pass offer's OU
                ,p_offer_currency => p_offer_currency --kdass bug 8510774 - pass offer's currency code
                /*kdass 05-MAY-2006 bug 5205721
                ,p_product        => p_product
                ,p_product_attr   => p_product_attr
                */
                ,p_list_line_id   => p_list_line_id
                ,p_start_date     => p_start_date
                ,p_end_date       => p_end_date
                ,x_order_line_tbl => l_order_line_tbl
                );

      write_conc_log ('x_return_status: ' || x_return_status);
      write_conc_log ('number of orders: ' || l_order_line_tbl.count);

      /*kdass 04-AUG-2006 fixed bug 5446622
      IF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      */
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      IF p_type = 'product' THEN
         write_conc_log ('adjustment for new product');
         l_justification := 'Offer adjustment for new product';

         /*removed code for future dated adjustments since offers team will be taking care of this.
         original code in version 120.19
         */
      ELSE
         write_conc_log (l_full_name || ' adjustment before offer start date');
         l_justification := 'Offer adjustment before offer start date';
      END IF;

      IF l_order_line_tbl.count > 0 THEN

         l_act_budgets_rec.act_budget_used_by_id := p_list_header_id;
         l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
         l_act_budgets_rec.budget_source_type := 'OFFR';
         l_act_budgets_rec.budget_source_id := p_list_header_id;
         --nirprasa,ER 8399134 comment out these two columns and assign them with transactional curr
         -- assign fund_request_currency_code column with offer's currency.
         --l_act_budgets_rec.request_currency := l_offer_info.transaction_currency_code;
         --l_act_budgets_rec.approved_in_currency  := l_offer_info.transaction_currency_code;
         l_act_util_rec.fund_request_currency_code := l_offer_info.offer_currency_code;
         --end,ER 8399134
         l_act_budgets_rec.request_date := SYSDATE;
         l_act_budgets_rec.status_code := 'APPROVED';
         l_act_budgets_rec.user_status_id := ozf_Utility_Pvt.get_default_user_status (
                                                    'OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);

         l_act_budgets_rec.approval_date := SYSDATE;
         l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
         l_act_budgets_rec.justification := l_justification;
         l_act_budgets_rec.transfer_type := 'UTILIZED';

         l_act_util_rec.utilization_type :='ADJUSTMENT';
         l_act_util_rec.product_level_type := 'PRODUCT';
         --nirprasa,ER 8399134 replace sysdate by OZF_ACCRUAL_ENGINE.G_FAE_START_DATE
         l_act_util_rec.adjustment_date := OZF_ACCRUAL_ENGINE.G_FAE_START_DATE; --SYSDATE;
         l_act_util_rec.cust_account_id := l_offer_info.beneficiary_account_id;

         FOR j IN l_order_line_tbl.first .. l_order_line_tbl.last
         LOOP

            write_conc_log('order header id: ' || l_order_line_tbl(j).order_header_id);
            write_conc_log('order line id: ' || l_order_line_tbl(j).order_line_id);
            write_conc_log('inventory item id: ' || l_order_line_tbl(j).inventory_item_id);

            l_act_util_rec.product_id  := l_order_line_tbl(j).inventory_item_id;
            l_act_util_rec.object_type :='ORDER';
            l_act_util_rec.object_id := l_order_line_tbl(j).order_header_id;
            l_act_util_rec.order_line_id := l_order_line_tbl(j).order_line_id;

            OPEN c_cust_number (l_order_line_tbl(j).order_header_id);
            FETCH c_cust_number INTO l_cust_number;
            CLOSE c_cust_number;

            l_act_util_rec.billto_cust_account_id := l_cust_number;

            IF l_offer_info.beneficiary_account_id IS NULL THEN
               l_act_util_rec.cust_account_id := l_cust_number;
            END IF;

            write_conc_log ('billto_cust_account_id: ' || l_act_util_rec.billto_cust_account_id);
            write_conc_log ('cust_account_id: ' || l_act_util_rec.cust_account_id);
            write_conc_log ('unit_list_price: ' || l_order_line_tbl(j).unit_list_price);
            write_conc_log ('quantity: ' || l_order_line_tbl(j).quantity);
            write_conc_log ('p_modified_discount: ' || p_modified_discount);
            write_conc_log ('p_original_discount: ' || p_original_discount);
            write_conc_log ('p_arithmetic_operator: ' || p_arithmetic_operator);

            /*
            If you enter 5 for discount, then the following would result for the various discount types
            Amount = $5.00 off the price per unit
            Percent = 5% off the price per unit
            New Price = the new price per unit is $5.00
            Lumpsum = a flat $5.00 off an order for that product regardless of quantity
            */
            l_total_price := l_order_line_tbl(j).unit_list_price * l_order_line_tbl(j).quantity;

                 -- 7030415 , get the order's org_id to get the exchange rate.
                 OPEN c_order_org_id(l_order_line_tbl(j).order_line_id);
                 FETCH c_order_org_id INTO l_order_org_id;
                 CLOSE c_order_org_id;

                 OPEN c_offer_type(p_list_header_id);
                 FETCH c_offer_type INTO l_autopay_party_attr,l_autopay_party_id;
                 CLOSE c_offer_type;

                  write_conc_log ('l_order_org_id: ' || l_order_org_id);
                  l_act_util_rec.org_id := l_order_org_id;

                  IF l_act_util_rec.cust_account_id IS NULL THEN
                    IF l_offer_info.beneficiary_account_id IS NOT NULL THEN
                      IF l_autopay_party_attr <> 'CUSTOMER' AND l_autopay_party_attr IS NOT NULL THEN
                        --Added c_org_id for bugfix 6278466
                        OPEN c_org_id (l_autopay_party_id);
                        FETCH c_org_id INTO l_org_id;
                        CLOSE c_org_id;
                        l_act_util_rec.org_id := l_org_id;
                      END IF;
                    END IF;
                  END IF;

            IF p_arithmetic_operator = 'AMT' THEN
               l_util_amount := p_modified_discount * l_order_line_tbl(j).quantity;
            ELSIF p_arithmetic_operator = '%' THEN
            write_conc_log ('p_modified_discount ' || p_modified_discount);
            write_conc_log ('l_total_price ' || l_total_price);
               l_util_amount := p_modified_discount * l_total_price / 100;

ozf_utility_pvt.write_conc_log('offer curr: '||l_offer_info.transaction_currency_code);
               ozf_utility_pvt.write_conc_log('order curr: '||l_order_line_tbl(j).transactional_curr_code);

               --nirprasa,12.1.1 remove conversion. keep the utilization in order currency.
               --kdass 31-MAR-2006 bug 5101720 convert from order currency to offer currency
               IF l_offer_info.transaction_currency_code IS NOT NULL
                 AND l_offer_info.transaction_currency_code <> l_order_line_tbl(j).transactional_curr_code THEN

                  ozf_utility_pvt.write_conc_log('order curr: ' || l_order_line_tbl(j).transactional_curr_code);
                  ozf_utility_pvt.write_conc_log('offer curr: ' || l_offer_info.transaction_currency_code);
                  ozf_utility_pvt.write_conc_log('l_util_amount: ' || l_util_amount);


                 OPEN c_get_conversion_type(l_act_util_rec.org_id);
                 FETCH c_get_conversion_type INTO l_exchange_rate_type;
                 CLOSE c_get_conversion_type;


                  ozf_utility_pvt.convert_currency (x_return_status => x_return_status
                                                   ,p_from_currency => l_order_line_tbl(j).transactional_curr_code
                                                   ,p_to_currency   => l_offer_info.transaction_currency_code
                                                   ,p_conv_type     => l_exchange_rate_type
                                                   ,p_conv_date     => OZF_ACCRUAL_ENGINE.G_FAE_START_DATE
                                                   ,p_from_amount   => l_util_amount
                                                   ,x_to_amount     => l_conv_util_amount
                                                   ,x_rate          => l_rate
                                                   );

                  ozf_utility_pvt.write_conc_log('x_return_status: ' || x_return_status);
                  IF x_return_status <> fnd_api.g_ret_sts_success THEN
                     RETURN;
                  END IF;

                  l_util_amount := l_conv_util_amount;

                  write_conc_log ('util amt after currency conversion: ' || l_util_amount);

               ELSE
                  l_util_amount := ozf_utility_pvt.currround(l_util_amount, l_order_line_tbl(j).transactional_curr_code);
                  ozf_utility_pvt.write_conc_log('l_util_amount: '||l_util_amount);
               END IF;
            ELSIF p_arithmetic_operator = 'NEWPRICE' THEN
               l_util_amount := (l_order_line_tbl(j).unit_list_price - p_modified_discount) * l_order_line_tbl(j).quantity;
            ELSIF p_arithmetic_operator = 'LUMPSUM' THEN
               l_util_amount := p_modified_discount;
            END IF;
            --nirprasa,ER 8399134 for null currency offer the transaction currency will be order currency
            --all other cases, it will be offer currency(Arrows case included)
            write_conc_log ('null currency offer?: ' || l_offer_info.transaction_currency_code);

            IF l_offer_info.transaction_currency_code IS NULL THEN
               l_act_util_rec.plan_currency_code := l_order_line_tbl(j).transactional_curr_code;
               l_act_budgets_rec.request_currency := l_order_line_tbl(j).transactional_curr_code;
               l_act_budgets_rec.approved_in_currency  := l_order_line_tbl(j).transactional_curr_code;
               l_util_amount := ozf_utility_pvt.currround(l_util_amount, l_order_line_tbl(j).transactional_curr_code);
            ELSE
               l_act_util_rec.plan_currency_code := l_offer_info.transaction_currency_code;
               l_act_budgets_rec.request_currency := l_offer_info.transaction_currency_code;
               l_act_budgets_rec.approved_in_currency  := l_offer_info.transaction_currency_code;
               l_util_amount := ozf_utility_pvt.currround(l_util_amount, l_offer_info.transaction_currency_code);
            END IF;
            --end ER 8399134

            write_conc_log ('adjustment amount: ' || l_util_amount);

            l_ship_to_org_id := NULL;
            l_invoice_to_org_id := NULL;

            -- handle RMA order to fix bug 5147399.
            IF l_order_line_tbl(j).line_category_code ='RETURN' THEN
               IF l_order_line_tbl(j).reference_line_id is NOT NULL THEN
                  OPEN  c_orig_order_adj_amt (l_order_line_tbl(j).reference_line_id);
                  FETCH c_orig_order_adj_amt INTO l_orig_util_amount;
                  CLOSE c_orig_order_adj_amt;

                  --kdass 24-AUG-2006 fix for bug 5485172
                  OPEN  c_order_line (l_order_line_tbl(j).reference_line_id);
                  FETCH c_order_line INTO l_orig_order_qty, l_ship_to_org_id, l_invoice_to_org_id;
                  CLOSE c_order_line;

                  write_conc_log ('l_orig_util_amount: ' || l_orig_util_amount);
                  write_conc_log ('l_orig_order_qty: ' || l_orig_order_qty);

                  IF l_orig_order_qty = 0 THEN
                     write_conc_log ('l_orig_order_qty is 0, exit loop');
                     GOTO l_endoforderloop;
                  END IF;

                  --calculate utilization amount in proportion of the number of items returned
                  l_util_amount := l_orig_util_amount / l_orig_order_qty * l_order_line_tbl(j).quantity;

                  write_conc_log ('l_util_amount: ' || l_util_amount);

                  IF l_util_amount > l_orig_util_amount THEN
                     l_util_amount := l_orig_util_amount;
                     write_conc_log ('greater than orig amount - l_util_amount: ' || l_util_amount);
                  END IF;

               END IF;

               l_util_amount := - l_util_amount;
               write_conc_log ('adjustment amount for RMA: ' || l_util_amount);

            END IF; -- l_order_line_tbl(j).line_category_code ='RETURN'

            IF l_ship_to_org_id IS NULL THEN
               OPEN  c_order_line (l_order_line_tbl(j).order_line_id);
               FETCH c_order_line INTO l_orig_order_qty, l_ship_to_org_id, l_invoice_to_org_id;
               CLOSE c_order_line;
            END IF;

            l_act_util_rec.ship_to_site_use_id  := l_ship_to_org_id;
            l_act_util_rec.bill_to_site_use_id  := l_invoice_to_org_id;

            --kdass 20-JUL-05 Bug 4489233 - gets the previous adjusted amount for the order line
            OPEN c_order_adjustment_amt (l_order_line_tbl(j).order_header_id, l_order_line_tbl(j).order_line_id, l_order_line_tbl(j).inventory_item_id);
            FETCH c_order_adjustment_amt INTO l_adj_amount;
            CLOSE c_order_adjustment_amt;
             write_conc_log ('l_adj_amount : '||l_adj_amount);

            l_util_amount := NVL(l_util_amount,0) - NVL(l_adj_amount,0);

            write_conc_log ('remaining adjustment amount: ' || l_util_amount);

            IF l_util_amount > 0 THEN
               l_act_util_rec.adjustment_type :='STANDARD'; -- Seeded Data for Backdated Positive Adj
               l_act_util_rec.adjustment_type_id := -5; -- Seeded Data for Backdated Positive Adj
               --nirprasa,ER 8399134
               l_act_util_rec.exchange_rate_date := OZF_ACCRUAL_ENGINE.G_FAE_START_DATE;
            ELSE
               l_act_util_rec.adjustment_type :='DECREASE_EARNED'; -- Seeded Data for Backdated Negative Adj
               l_act_util_rec.adjustment_type_id := -4; -- Seeded Data for Backdated Negative Adj
               l_act_util_rec.exchange_rate_date := OZF_ACCRUAL_ENGINE.G_FAE_START_DATE;
            END IF;



            IF l_util_amount <> 0 THEN

               l_act_budgets_rec.request_amount := l_util_amount;
               l_act_budgets_rec.approved_amount := l_util_amount;
               write_conc_log(l_full_name || ': ozf_fund_adjustment_pvt.process_act_budgets');

               ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => x_return_status
                                                          ,x_msg_count       => x_msg_count
                                                          ,x_msg_data        => x_msg_data
                                                          ,p_act_budgets_rec => l_act_budgets_rec
                                                          ,p_act_util_rec    => l_act_util_rec
                                                          ,x_act_budget_id   => l_act_budget_id
                                                          );

               write_conc_log('process_act_budgets returns: ' || x_return_status);

               IF x_return_status <> fnd_api.g_ret_sts_success THEN
                  RETURN;
               END IF;

            END IF;

            <<l_endoforderloop>>
            write_conc_log('adjustment_net_accrual returns: ' || x_return_status);

         END LOOP;
      END IF;

  END adjustment_net_accrual;


---------------------------------------------------------------------
-- PROCEDURE
--    adjustment_volume_retro
-- PURPOSE
--    adjustment for retroactive adjustment before offer start date for volume offer
-- HISTORY
-- 2/16/2007  kdass Created for bug 5610124
----------------------------------------------------------------------
 PROCEDURE adjustment_volume_retro(p_api_version         IN NUMBER
                                  ,p_start_date          IN DATE
                                  ,p_end_date            IN DATE
                                  ,p_list_header_id      IN NUMBER
                                  ,p_offer_org_id        IN NUMBER
                                  ,p_offer_currency      IN VARCHAR2
                                  ,p_offer_adjustment_id IN NUMBER
                                  ,x_return_status       IN OUT NOCOPY VARCHAR2
                                  ,x_msg_count           IN OUT NOCOPY NUMBER
                                  ,x_msg_data            IN OUT NOCOPY VARCHAR2
                                  )
   IS

      --query to retrieve list_line_id
       CURSOR c_list_line (p_offer_id IN NUMBER, p_product_id IN VARCHAR2) IS
         SELECT oq.list_line_id, op.product_attribute, op.product_attr_value
         FROM   ozf_offer_discount_products op, ozf_qp_discounts oq
         WHERE  (op.product_attr_value = p_product_id OR op.product_attr_value = 'ALL')
           AND  op.offer_id = p_offer_id
           AND  op.offer_discount_line_id = oq.offer_discount_line_id
           AND  rownum = 1;

      CURSOR c_order_line_details (p_line_id IN NUMBER) IS
        SELECT actual_shipment_date, shipped_quantity, flow_status_code, invoice_interface_status_code,
               invoiced_quantity, sold_to_org_id, invoice_to_org_id, ship_to_org_id, shipping_quantity_uom,
               order_quantity_uom, unit_selling_price, org_id, ordered_quantity
        FROM oe_order_lines_all
        WHERE line_id = p_line_id;

      CURSOR c_invoice_date(p_line_id IN NUMBER, p_order_number IN VARCHAR2) IS
        SELECT  cust.trx_date     -- transaction(invoice) date
        FROM ra_customer_trx_all cust
           , ra_customer_trx_lines_all cust_lines
        WHERE cust.customer_trx_id = cust_lines.customer_trx_id
        AND cust_lines.sales_order = p_order_number -- added condition for partial index for bug fix 3917556
        AND cust_lines.interface_line_attribute6 = TO_CHAR(p_line_id);

      CURSOR party_id_csr(p_cust_account_id IN NUMBER) IS
         SELECT party_id
         FROM hz_cust_accounts
         WHERE cust_account_id = p_cust_account_id;

      CURSOR party_site_id_csr(p_account_site_id IN NUMBER) IS
         SELECT a.party_site_id
         FROM hz_cust_acct_sites_all a,
              hz_cust_site_uses_all b
         WHERE b.site_use_id = p_account_site_id
         AND   b.cust_acct_site_id = a.cust_acct_site_id;

      CURSOR sales_transation_csr(p_line_id IN NUMBER) IS
         SELECT 1 FROM DUAL WHERE EXISTS
         ( SELECT 1
           FROM ozf_sales_transactions_all trx
           WHERE trx.line_id = p_line_id
           AND source_code = 'OM');

      CURSOR c_adjustment_exists (p_list_header_id IN NUMBER, p_order_line_id IN NUMBER) IS
         SELECT 1
         FROM ozf_funds_utilized_all_b
         WHERE plan_id = p_list_header_id
         AND   plan_type = 'OFFR'
         AND order_line_id = p_order_line_id;

      CURSOR c_offer_info (p_list_header_id IN NUMBER) IS
         SELECT nvl(transaction_currency_code,fund_request_curr_code) offer_currency_code
               ,
transaction_currency_code
               , beneficiary_account_id, offer_id
           FROM ozf_offers
          WHERE qp_list_header_id = p_list_header_id;

      CURSOR c_cust_number (p_header_id IN NUMBER) IS
         SELECT cust.cust_account_id
            FROM hz_cust_acct_sites_all acct_site,
                 hz_cust_site_uses_all site_use,
                 hz_cust_accounts  cust,
                 oe_order_headers_all header
            WHERE header.header_id = p_header_id
              AND acct_site.cust_acct_site_id = site_use.cust_acct_site_id
              AND acct_site.cust_account_id = cust.cust_account_id
              AND site_use.site_use_id = header.invoice_to_org_id ;

      CURSOR c_apply_discount(p_offer_id IN NUMBER,p_product_id IN VARCHAR2) IS
        SELECT NVL(apply_discount_flag,'N')
        FROM ozf_offer_discount_products
        WHERE offer_id = p_offer_id
        AND product_attr_value = p_product_id;

      CURSOR c_get_items_type(p_list_header_id number,p_inventory_item_id IN NUMBER) IS
        select item_type, ITEMS_CATEGORY
        from ozf_activity_products
        where object_id = p_list_header_id
        and item=p_inventory_item_id;


     CURSOR c_get_cond_id_column(p_prod_attr varchar2) IS
        select condition_id_column
        from ozf_denorm_queries
        where context='ITEM'
        and attribute =p_prod_attr and rownum = 1;


  CURSOR c_discount_header(p_discount_line_id IN NUMBER) IS
         SELECT discount_type,volume_type
          FROM ozf_offer_discount_lines
          WHERE offer_discount_line_id = p_discount_line_id
          AND tier_type = 'PBH';

     CURSOR c_get_group(p_order_line_id IN NUMBER,p_list_header_id IN NUMBER) IS
       SELECT group_no,pbh_line_id,include_volume_flag
        FROM ozf_order_group_prod
        WHERE order_line_id = p_order_line_id
        AND qp_list_header_id = p_list_header_id;

     CURSOR c_market_option(p_list_header_id IN NUMBER, p_group_id IN NUMBER) IS
       SELECT opt.retroactive_flag
        FROM ozf_offr_market_options opt
        WHERE opt.GROUP_NUMBER= p_group_id
        AND opt.qp_list_header_id = p_list_header_id;

         CURSOR c_current_discount(p_volume IN NUMBER, p_parent_discount_id IN NUMBER) IS
         SELECT discount
        FROM ozf_offer_discount_lines
        WHERE p_volume > volume_from
             AND p_volume <= volume_to
         AND parent_discount_line_id = p_parent_discount_id;

          CURSOR  c_get_tier_limits (p_parent_discount_id IN NUMBER) IS
       SELECT MIN(volume_from),MAX(volume_to)
       FROM ozf_offer_discount_lines
       WHERE parent_discount_line_id = p_parent_discount_id;

     CURSOR  c_get_max_tier (p_max_volume_to IN NUMBER,p_parent_discount_id IN NUMBER)    IS
        SELECT  discount
        FROM ozf_offer_discount_lines
        WHERE volume_to =p_max_volume_to
        AND parent_discount_line_id = p_parent_discount_id;


--nirprasa,12.2 replace amount by plan_curr_amount
          CURSOR c_order_adjustment_amt (p_object_id IN NUMBER, p_order_line_id IN NUMBER, p_prod_id IN NUMBER) IS
 SELECT SUM(plan_curr_amount)
            FROM ozf_funds_utilized_all_b
            WHERE plan_type = 'OFFR'
              AND plan_id = p_list_header_id
              AND object_type = 'ORDER'
              AND object_id = p_object_id
              AND order_line_id = p_order_line_id
              AND product_level_type = 'PRODUCT'
              AND product_id = p_prod_id
              AND utilization_type NOT IN ('REQUEST', 'TRANSFER');



    CURSOR c_order_adj_amount ( p_prod_id IN NUMBER) IS
         SELECT SUM(amount)
            FROM ozf_funds_utilized_all_b
            WHERE plan_type = 'OFFR'
              AND plan_id = p_list_header_id
              AND object_type = 'ORDER'
             -- AND object_id = p_object_id
              AND product_level_type = 'PRODUCT'
              AND product_id = p_prod_id
              AND utilization_type NOT IN ('REQUEST', 'TRANSFER');

  CURSOR  c_prior_tiers(p_parent_discount_id  IN NUMBER, p_volume IN NUMBER ) IS
       SELECT  offer_discount_line_id ,volume_from ,volume_to, discount
         FROM  ozf_offer_discount_lines
         WHERE   parent_discount_line_id = p_parent_discount_id
         AND   p_volume >= volume_from
         ORDER BY volume_from  DESC;

  CURSOR c_preset_tier(p_pbh_line_id IN NUMBER, p_qp_list_header_id IN NUMBER,p_group_id IN NUMBER) IS
       SELECT a.discount
       FROM   ozf_offer_discount_lines a, ozf_market_preset_tiers b, ozf_offr_market_options c
       WHERE  a.offer_discount_line_id = b.dis_offer_discount_id
       AND    b.pbh_offer_discount_id = p_pbh_line_id
       AND    b.offer_market_option_id = c.offer_market_option_id
       AND    c.qp_list_header_id = p_qp_list_header_id
       AND    c.group_number = p_group_id;


  CURSOR c_exchange_rate_type(p_org_id IN NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;


      l_offer_info         c_offer_info%ROWTYPE;
      l_act_budgets_rec    ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec       ozf_actbudgets_pvt.act_util_rec_type;
      l_cust_number        NUMBER;
      l_order_line_tbl     order_line_tbl_type;
      l_req_line_attrs_tbl qp_runtime_source.accum_req_line_attrs_tbl;
      l_index              NUMBER := 1;
      l_dummy              NUMBER;
      l_list_line_id       NUMBER;
      l_order_header_id    NUMBER;
      l_order_line_id      NUMBER;
      l_string             VARCHAR2(1024);
      l_first_pos          NUMBER := 1;
      l_last_pos           NUMBER := 0;
      l_value              VARCHAR2(1024);
      l_cntr               NUMBER          := 0;
      l_num_chars          VARCHAR2(1024);
      l_sales_transaction_rec   OZF_SALES_TRANSACTIONS_PVT.SALES_TRANSACTION_REC_TYPE;
      l_order_gl_phase     CONSTANT VARCHAR2 (15) := NVL(fnd_profile.VALUE ('OZF_ORDER_GLPOST_PHASE'), 'SHIPPED');
      l_sales_transaction_id NUMBER;
      l_gl_date            DATE;
      l_shipment_date      DATE;
      l_shipped_qty        NUMBER;
      l_flow_status_code   VARCHAR2(30);
      l_invoice_status_code VARCHAR2(30);
      l_invoiced_quantity  NUMBER;
      l_order_number       NUMBER;
      l_sold_to_org_id     NUMBER;
      l_invoice_to_org_id  NUMBER;
      l_ship_to_org_id     NUMBER;
      l_shipping_quantity_uom  VARCHAR2(30);
      l_order_quantity_uom VARCHAR2(30);
      l_unit_selling_price NUMBER;
      l_org_id             NUMBER;
      l_sales_trans        NUMBER;
      l_adjustment_exists  NUMBER;
      l_act_budget_id      NUMBER;
      l_apply_discount     VARCHAR2(1);

      l_prod_attr          VARCHAR2(50);
      l_prod_attr_val      VARCHAR2(20);
      l_item               VARCHAR2(240);
      l_cond_id_column     varchar2(240) := null;
      l_product_val_cursor product_attr_val_cursor_type;
      l_category_id        NUMBER;
      l_stmt               VARCHAR2(3000);


      l_group_id                NUMBER;
      l_pbh_line_id             NUMBER;
      l_included_vol_flag       VARCHAR2(1);
      l_retroactive             VARCHAR2(1) ;
      l_discount_type           VARCHAR2(30);
      l_volume_type             VARCHAR2(30);
      l_return_status           VARCHAR2 (20) :=  fnd_api.g_ret_sts_success;
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (2000)        := NULL;
      l_source_code             VARCHAR2(30);
      l_volume                  NUMBER;
      l_ordered_qty             NUMBER;
      l_utilization_amount      NUMBER;
      l_new_discount            NUMBER;
      l_min_tier                NUMBER;
      l_max_tier                NUMBER;
      l_adj_amount              NUMBER;


      l_current_offer_tier_id   NUMBER;
      y1                        NUMBER; -- Initial Adjsutment
      l_current_max_tier        NUMBER;
      l_current_min_tier        NUMBER;
      l_current_tier_value      NUMBER;
      l_previous_tier_max       NUMBER;
      l_preset_tier             NUMBER;
      l_conv_type       ozf_funds_utilized_all_b.exchange_rate_type%TYPE;
      l_conv_price              NUMBER;
      l_rate                    NUMBER;

   BEGIN

      write_conc_log ('in adjustment_volume_retro');

      --get the qualified orders
      get_orders(p_api_version    => p_api_version
                ,p_init_msg_list  => FND_API.G_FALSE
                ,p_commit         => FND_API.G_FALSE
                ,x_return_status  => x_return_status
                ,x_msg_count      => x_msg_count
                ,x_msg_data       => x_msg_data
                ,p_list_header_id => p_list_header_id
                ,p_offer_org_id   => p_offer_org_id
                ,p_offer_currency => p_offer_currency
                ,p_list_line_id   => NULL
                ,p_start_date     => p_start_date
                ,p_end_date       => p_end_date
                ,x_order_line_tbl => l_order_line_tbl
                );

      write_conc_log ('x_return_status: ' || x_return_status);
      write_conc_log ('number of orders: ' || l_order_line_tbl.count);

        l_volume:=0;
        l_utilization_amount := 0;


      IF l_order_line_tbl.count > 0 THEN

         FOR j IN l_order_line_tbl.first .. l_order_line_tbl.last
         LOOP



            write_conc_log ('==============');
            write_conc_log ('order number: ' || l_order_line_tbl(j).order_number);
            write_conc_log ('order line: ' || l_order_line_tbl(j).order_line_id);
            write_conc_log ('==============');


            --fix for bug # 5944862
            OPEN c_offer_info (p_list_header_id);
            FETCH c_offer_info INTO l_offer_info;
            CLOSE c_offer_info;
            -- -----
             write_conc_log('p_list_header_id: '||p_list_header_id);
             write_conc_log('l_order_line_tbl(j).inventory_item_id '||l_order_line_tbl(j).inventory_item_id);

            OPEN c_get_items_type(p_list_header_id,l_order_line_tbl(j).inventory_item_id);
            FETCH c_get_items_type INTO l_prod_attr, l_prod_attr_val;
            CLOSE c_get_items_type;

            write_conc_log('l_prod_attr: '||l_prod_attr);
            write_conc_log('l_prod_attr_val: '||l_prod_attr_val);

            OPEN c_get_cond_id_column(l_prod_attr);
            FETCH c_get_cond_id_column INTO l_cond_id_column;
            CLOSE c_get_cond_id_column;

            write_conc_log('l_cond_id_column: '||l_cond_id_column);
            -- fix for bug 5767748

            IF l_prod_attr_val IS NULL THEN -- if not item category

                l_prod_attr_val :=l_order_line_tbl(j).inventory_item_id;
                IF l_cond_id_column IS NOT NULL THEN --if product context

                  l_stmt := 'select ' || l_cond_id_column ||
                  ' from mtl_system_items  where ORGANIZATION_ID = FND_PROFILE.VALUE(''QP_ORGANIZATION_ID'') and inventory_item_id =:1 and  rownum = 1';
                  write_conc_log(l_stmt);

                  OPEN l_product_val_cursor FOR l_stmt using l_prod_attr_val;
                  LOOP
                  FETCH l_product_val_cursor INTO l_prod_attr_val;
                  EXIT WHEN l_product_val_cursor%NOTFOUND;
                  END LOOP;

                --ELSE -- if inventory item
                --l_prod_attr_val :=l_order_line_tbl(j).inventory_item_id;
                END IF;
            END IF;

             write_conc_log('l_prod_attr_val: '||l_prod_attr_val);
             write_conc_log('l_offer_info.offer_id: '||l_offer_info.offer_id);


            OPEN  c_list_line (l_offer_info.offer_id,l_prod_attr_val);
            FETCH c_list_line INTO l_list_line_id,l_prod_attr,l_prod_attr_val;
            CLOSE c_list_line;


             write_conc_log('l_list_line_id: '||l_list_line_id);
             write_conc_log('l_prod_attr: '||l_prod_attr);
             write_conc_log('ll_prod_attr_val: '||l_prod_attr_val);
            -- -----


            l_index := 1;
            -- product
            l_req_line_attrs_tbl(l_index).line_index := 1;
            l_req_line_attrs_tbl(l_index).attribute_type := 'PRODUCT';
            l_req_line_attrs_tbl(l_index).context := NULL;
            l_req_line_attrs_tbl(l_index).attribute := l_prod_attr;
            l_req_line_attrs_tbl(l_index).value := l_prod_attr_val; -- inventory_item_id
            l_req_line_attrs_tbl(l_index).grouping_no := NULL;


            l_cntr := 0;
            l_last_pos := 0;
            l_first_pos := 1;
            l_num_chars := 0;

            write_conc_log ('l_order_line_tbl(j).group_nos: ' || l_order_line_tbl(j).group_nos);

            IF l_order_line_tbl(j).group_nos IS NOT NULL THEN

               --loop to get individual group number from the comma seperated list
               l_string := l_order_line_tbl(j).group_nos;
               LOOP
                  l_last_pos := INSTR(l_string,',',1,l_cntr+1);
                  l_num_chars := l_last_pos - l_first_pos;
                  IF l_last_pos = 0 THEN
                     l_value := SUBSTR(l_string, l_first_pos);
                  ELSE
                     l_value := substr(l_string, l_first_pos,l_num_chars);
                     l_first_pos := l_last_pos + 1;
                  END IF;
                  l_cntr := l_cntr + 1;

                  -- qualifier
                  l_index := l_index + 1;
                  l_req_line_attrs_tbl(l_index).line_index := 1;
                  l_req_line_attrs_tbl(l_index).attribute_type := 'QUALIFIER';
                  l_req_line_attrs_tbl(l_index).context := NULL;
                  l_req_line_attrs_tbl(l_index).attribute := NULL;
                  l_req_line_attrs_tbl(l_index).value := NULL;
                  l_req_line_attrs_tbl(l_index).grouping_no := l_value;

                  write_conc_log('group no: ' || l_value);

                  IF l_last_pos = 0 THEN
                     EXIT;
                  END IF;
               END LOOP;

            END IF;



            write_conc_log('l_list_line_id: ' || l_list_line_id);
            write_conc_log('calling OZF_VOLUME_CALCULATION_PUB.get_numeric_attribute_value');

            --simulation of pricing engine call while booking order
            l_dummy := OZF_VOLUME_CALCULATION_PUB.get_numeric_attribute_value
                       (p_list_line_id         => l_list_line_id
                       ,p_list_line_no         => NULL
                       ,p_order_header_id      => l_order_line_tbl(j).order_header_id
                       ,p_order_line_id        => l_order_line_tbl(j).order_line_id
                       ,p_price_effective_date => NULL
                       ,p_req_line_attrs_tbl   => l_req_line_attrs_tbl
                       ,p_accum_rec            => NULL
                      );

            write_conc_log('calling OZF_VOLUME_CALCULATION_PUB.get_numeric_attribute_value returns: ' || l_dummy);

            l_gl_date := NULL;

            OPEN c_order_line_details (l_order_line_tbl(j).order_line_id);
            FETCH c_order_line_details into l_shipment_date, l_shipped_qty, l_flow_status_code, l_invoice_status_code,
                                            l_invoiced_quantity, l_sold_to_org_id, l_invoice_to_org_id, l_ship_to_org_id,
                                            l_shipping_quantity_uom, l_order_quantity_uom, l_unit_selling_price, l_org_id, l_ordered_qty;
            CLOSE c_order_line_details;

              write_conc_log ('order org: ' || l_org_id);

            IF ( l_order_gl_phase = 'SHIPPED' AND l_order_line_tbl(j).line_category_code <> 'RETURN' AND
               NVL(l_shipped_qty,0) <> 0 AND l_flow_status_code = 'SHIPPED') THEN

               l_gl_date := l_shipment_date;
               l_sales_transaction_rec.quantity  := l_shipped_qty;
               l_sales_transaction_rec.transfer_type := 'IN';

               write_conc_log('gl date is shipment date: ' || l_gl_date);

            END IF;

            IF l_gl_date IS NULL THEN
               IF (l_invoice_status_code = 'YES' OR NVL(l_invoiced_quantity,0) <> 0) THEN
                  OPEN c_invoice_date(l_order_line_tbl(j).order_line_id, l_order_line_tbl(j).order_number);
                  FETCH c_invoice_date INTO l_gl_date;
                  CLOSE c_invoice_date;

                  write_conc_log('gl date is invoice date: ' || l_gl_date);

                  IF l_gl_date IS NULL THEN
                     l_gl_date := sysdate;
                     write_conc_log('gl date is sysdate: ' || l_gl_date);
                  END IF;

                  l_sales_transaction_rec.quantity   := l_invoiced_quantity;

               END IF;
            END IF;

            write_conc_log('gl date: ' || l_gl_date);
            write_conc_log('line id: ' || l_order_line_tbl(j).order_line_id);

            IF l_gl_date IS NOT NULL THEN
               OPEN sales_transation_csr(l_order_line_tbl(j).order_line_id);
               FETCH sales_transation_csr INTO l_sales_trans;
               CLOSE sales_transation_csr;

               write_conc_log('l_sales_trans: ' || l_sales_trans);

               l_sales_transaction_rec.sold_to_cust_account_id := l_sold_to_org_id;

               OPEN party_id_csr(l_sales_transaction_rec.sold_to_cust_account_id);
               FETCH party_id_csr INTO l_sales_transaction_rec.sold_to_party_id;
               CLOSE party_id_csr;

               OPEN party_site_id_csr(l_invoice_to_org_id);
               FETCH party_site_id_csr INTO l_sales_transaction_rec.sold_to_party_site_id;
               CLOSE party_site_id_csr;

               l_sales_transaction_rec.ship_to_site_use_id  := l_ship_to_org_id;
               l_sales_transaction_rec.bill_to_site_use_id  := l_invoice_to_org_id;
               l_sales_transaction_rec.uom_code:= NVL(l_shipping_quantity_uom, l_order_quantity_uom);
               l_sales_transaction_rec.amount   := l_unit_selling_price * l_sales_transaction_rec.quantity;
               l_sales_transaction_rec.currency_code  := l_order_line_tbl(j).transactional_curr_code;
               l_sales_transaction_rec.inventory_item_id := l_order_line_tbl(j).inventory_item_id;
               l_sales_transaction_rec.header_id  :=   l_order_line_tbl(j).order_header_id;
               l_sales_transaction_rec.line_id  := l_order_line_tbl(j).order_line_id;
               l_sales_transaction_rec.source_code := 'OM';

               IF l_order_line_tbl(j).line_category_code <> 'RETURN' THEN
                  l_sales_transaction_rec.transfer_type := 'IN';
               ELSE
                  l_sales_transaction_rec.transfer_type := 'OUT';
               END IF;

               l_sales_transaction_rec.transaction_date  := l_gl_date;
               l_sales_transaction_rec.org_id := l_org_id;
               l_sales_transaction_rec.qp_list_header_id := p_list_header_id;

               write_conc_log('calling Create_Transaction');

               OZF_SALES_TRANSACTIONS_PVT.Create_Transaction(p_api_version      => 1.0
                                                            ,p_init_msg_list    => FND_API.G_FALSE
                                                            ,p_commit           => FND_API.G_FALSE
                                                            ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                                                            ,p_transaction_rec  => l_sales_transaction_rec
                                                            ,x_sales_transaction_id => l_sales_transaction_id
                                                            ,x_return_status    => x_return_status
                                                            ,x_msg_data         => x_msg_data
                                                            ,x_msg_count        => x_msg_count
                                                            );

               write_conc_log('Create_Transaction returns: ' || x_return_status);
               write_conc_log('l_sales_transaction_id: ' || l_sales_transaction_id);

               IF x_return_status <> fnd_api.g_ret_sts_success THEN
                  RETURN;
               END IF;

                 END IF; --IF l_gl_date IS NOT NULL THEN

                 -- As booked orders are also considered so closed the "IF l_gl_date IS NOT NULL THEN" condition here
                 -- fix for bug 6021635

               --OPEN c_apply_discount(l_offer_info.offer_id, l_order_line_tbl(j).inventory_item_id);
               OPEN c_apply_discount(l_offer_info.offer_id, l_prod_attr_val);
               FETCH c_apply_discount INTO l_apply_discount;
               CLOSE c_apply_discount;

               IF l_apply_discount = 'N' THEN
                  write_conc_log('no discount since apply discount flag is unchecked: '|| l_order_line_tbl(j).inventory_item_id);
                  GOTO l_endofOrderloop;
               END IF;

               OPEN c_adjustment_exists (p_list_header_id, l_order_line_tbl(j).order_line_id);
               FETCH c_adjustment_exists INTO l_adjustment_exists;
               CLOSE c_adjustment_exists;

               l_adjustment_exists := 0;

               -- create adjustment record for the order line if it doesn't exists, otherwise
               -- volume_offer_adjustment will not consider this order line
              -- IF NVL(l_adjustment_exists,0) <> 1 THEN

                  l_act_budgets_rec.act_budget_used_by_id := p_list_header_id;
                  l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                  l_act_budgets_rec.budget_source_type := 'OFFR';
                  l_act_budgets_rec.budget_source_id := p_list_header_id;
                  --nirprasa,12.2 If condition to handle null currency offers
                  --else will work fine for Arrow's case as well.
                  IF l_offer_info.transaction_currency_code IS NULL THEN
                     l_act_budgets_rec.request_currency := l_order_line_tbl(j).transactional_curr_code;
                     l_act_budgets_rec.approved_in_currency := l_order_line_tbl(j).transactional_curr_code;
                     l_act_util_rec.plan_currency_code := l_order_line_tbl(j).transactional_curr_code;
                  ELSE
                     l_act_budgets_rec.request_currency := l_offer_info.transaction_currency_code;
                     l_act_budgets_rec.approved_in_currency := l_offer_info.transaction_currency_code;
                     l_act_util_rec.plan_currency_code := l_order_line_tbl(j).transactional_curr_code;
                  END IF;
                  l_act_util_rec.fund_request_currency_code := l_offer_info.transaction_currency_code;
                  --nirprasa,12.2
                  l_act_budgets_rec.request_date := SYSDATE;
                  l_act_budgets_rec.status_code := 'APPROVED';
                  l_act_budgets_rec.user_status_id := ozf_Utility_Pvt.get_default_user_status (
                                                            'OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);

                  l_act_budgets_rec.approval_date := SYSDATE;
                  l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
                  l_act_budgets_rec.justification := 'Offer adjustment before offer start date';
                  l_act_budgets_rec.transfer_type := 'UTILIZED';

                  l_act_util_rec.utilization_type :='ADJUSTMENT';
                  l_act_util_rec.product_level_type := 'PRODUCT';
                  l_act_util_rec.adjustment_date := SYSDATE;
                  l_act_util_rec.cust_account_id := l_offer_info.beneficiary_account_id;
                  l_act_util_rec.ship_to_site_use_id  := l_sales_transaction_rec.ship_to_site_use_id;
                  l_act_util_rec.bill_to_site_use_id  := l_sales_transaction_rec.bill_to_site_use_id;

                  l_act_util_rec.product_id  := l_order_line_tbl(j).inventory_item_id;
                  l_act_util_rec.object_type :='ORDER';
                  l_act_util_rec.object_id := l_order_line_tbl(j).order_header_id;
                  l_act_util_rec.order_line_id := l_order_line_tbl(j).order_line_id;
                  l_act_util_rec.price_adjustment_id := -1;
                  l_act_util_rec.org_id := l_org_id; --nirprasa, added for bug 7030415


                  OPEN c_cust_number (l_order_line_tbl(j).order_header_id);
                  FETCH c_cust_number INTO l_cust_number;
                  CLOSE c_cust_number;

                  l_act_util_rec.billto_cust_account_id := l_cust_number;

                  IF l_offer_info.beneficiary_account_id IS NULL THEN
                     l_act_util_rec.cust_account_id := l_cust_number;
                  END IF;

                  l_act_util_rec.adjustment_type :='STANDARD'; -- Seeded Data for Backdated Positive Adj
                  l_act_util_rec.adjustment_type_id := -5; -- Seeded Data for Backdated Positive Adj


                   --For booked orders get the total volume and the discount based on the
                   --tiers then create the utilization


                  OPEN c_get_group(l_order_line_tbl(j).order_line_id,p_list_header_id);
                  FETCH c_get_group INTO l_group_id,l_pbh_line_id,l_included_vol_flag;
                  CLOSE c_get_group;

                  IF G_DEBUG THEN
                    ozf_utility_pvt.debug_message(' l_group_id:  '|| l_group_id );
                    ozf_utility_pvt.debug_message(' l_pbh_line_id:  '|| l_pbh_line_id );
                    ozf_utility_pvt.debug_message(' l_included_vol_flag:  '|| l_included_vol_flag );
                  END IF;
                  write_conc_log(' l_group_id:  '|| l_group_id );
                  write_conc_log(' l_pbh_line_id:  '|| l_pbh_line_id );
                  write_conc_log(' l_included_vol_flag:  '|| l_included_vol_flag );

                  IF l_group_id is NULL OR l_pbh_line_id is NULL THEN
                     GOTO l_endofOrderloop;
                  END IF;

                  OPEN c_market_option(p_list_header_id,l_group_id);
                  FETCH c_market_option INTO l_retroactive;
                  CLOSE c_market_option;

                  OPEN c_discount_header(l_pbh_line_id);
                  FETCH c_discount_header INTO l_discount_type,l_volume_type;
                  CLOSE c_discount_header;

                    write_conc_log('l_retroactive: '||l_retroactive);
                    write_conc_log('p_qp_list_header_id: '||p_list_header_id);
                    write_conc_log('l_order_line_tbl(j).order_line_id: '||l_order_line_tbl(j).order_line_id);


                        l_volume:=l_volume+NVL(l_ordered_qty,0);

                         OPEN c_order_adjustment_amt (l_order_line_tbl(j).order_header_id, l_order_line_tbl(j).order_line_id, l_order_line_tbl(j).inventory_item_id);
                         FETCH c_order_adjustment_amt INTO l_adj_amount;
                         CLOSE c_order_adjustment_amt;

                     write_conc_log('l_volume: '||l_volume);
                     write_conc_log('l_adj_amount : '||l_adj_amount);
                  --12.2, multi-currency enhancement. added for Arrow's case
                  IF l_offer_info.transaction_currency_code IS NOT NULL
                  AND l_offer_info.transaction_currency_code <> l_order_line_tbl(j).transactional_curr_code THEN

                     --Added for bug 7030415
                     OPEN c_exchange_rate_type(l_org_id);
                     FETCH c_exchange_rate_type INTO l_conv_type;
                     CLOSE c_exchange_rate_type;

                     ozf_utility_pvt.write_conc_log('order curr: ' || l_order_line_tbl(j).transactional_curr_code);
                     ozf_utility_pvt.write_conc_log('offer curr: ' || l_offer_info.transaction_currency_code);
                     ozf_utility_pvt.write_conc_log('selling price: ' || l_unit_selling_price);
                     ozf_utility_pvt.write_conc_log('l_conv_type: ' || l_conv_type);

                     --Since it is increased earned always so no change for
                     ozf_utility_pvt.convert_currency (x_return_status => l_return_status
                                                      ,p_conv_type     => l_conv_type --7030415
                                                      ,p_conv_date     => OZF_ACCRUAL_ENGINE.G_FAE_START_DATE
                                                      ,p_from_currency => l_order_line_tbl(j).transactional_curr_code
                                                      ,p_to_currency   => l_offer_info.transaction_currency_code
                                                      ,p_from_amount   => l_unit_selling_price
                                                      ,x_to_amount     => l_conv_price
                                                      ,x_rate          => l_rate
                                                      );

                     IF l_return_status = fnd_api.g_ret_sts_error THEN
                        RAISE fnd_api.g_exc_error;
                     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                     END IF;

                     l_unit_selling_price := l_conv_price;
                     write_conc_log ('selling price after currency conversion: ' || l_unit_selling_price);

                  END IF;
                  --12.2 end
                   IF l_retroactive = 'Y' THEN

                  OPEN c_current_discount(l_volume,l_pbh_line_id);
                  FETCH c_current_discount INTO l_new_discount;
                  CLOSE c_current_discount;
                       write_conc_log('l_new_discount 111: '||l_new_discount);

                  IF l_new_discount  is NULL THEN
                     OPEN c_get_tier_limits(l_pbh_line_id);
                     FETCH c_get_tier_limits INTO l_min_tier,l_max_tier;
                     CLOSE c_get_tier_limits;
                     IF l_volume < l_min_tier THEN
                        l_new_discount := 0;
                     ELSE
                        OPEN c_get_max_tier(l_max_tier,l_pbh_line_id);
                        FETCH c_get_max_tier INTO l_new_discount;
                        CLOSE c_get_max_tier;
                     END IF;
                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message(' l_new_discount:  '|| l_new_discount );
                     END IF;
                     write_conc_log(' l_new_discount:  '|| l_new_discount );
                  END IF;

                 l_preset_tier := NULL;

                  OPEN c_preset_tier(l_pbh_line_id,p_list_header_id,l_group_id);
                  FETCH c_preset_tier INTO l_preset_tier;
                  CLOSE c_preset_tier;

                   write_conc_log( ' l_preset_tier=' || l_preset_tier);
                   write_conc_log( ' l_new_discount=' || l_new_discount);

                   IF l_preset_tier is NOT NULL AND l_preset_tier > l_new_discount THEN
                    l_new_discount := l_preset_tier;
                    IF G_DEBUG THEN
                       ozf_utility_pvt.debug_message('not reach preset tier:  ');
                    END IF;
                    write_conc_log(' not reach preset tier:');
                  END IF;


                 write_conc_log(' l_new_discount:  '|| l_new_discount );
                    IF l_discount_type = '%' THEN
                        IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                           l_utilization_amount := l_ordered_qty * l_new_discount / 100;
                        ELSE -- % is for unit price. need to multiple when range in quantity.
                           l_utilization_amount := l_ordered_qty *  l_unit_selling_price * l_new_discount / 100;
                        END IF;
                     ELSIF l_discount_type = 'AMT' THEN
                        IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                           -- amt is for unit pirce. need to divide when range in amount.
                           l_utilization_amount :=l_ordered_qty / l_unit_selling_price * l_new_discount ;
                        ELSE
                           l_utilization_amount :=l_ordered_qty  * l_new_discount ;
                        END IF;
                     END IF;

                  --end

                  END IF; --  end of IF l_retroactive = 'Y' THEN



                  --for non retro same as volume offer adjustment


                    IF NVL(l_retroactive, 'N') = 'N' THEN

                    l_utilization_amount:=0;

                  IF l_included_vol_flag = 'Y' THEN
                        l_previous_tier_max := l_volume;
                     ELSE
                        /*
                          logic here is to add current order line's volume to offer's volume for adjustment.
                          eg:  offer's volume=2.
                               order line's volume = 5, then total volume = 7.
                        */
                        l_previous_tier_max := l_volume + l_ordered_qty;
                     END IF;

                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message( ' l_ordered_qty=' || l_ordered_qty);
                     END IF;
                     write_conc_log( ' l_value=' || l_ordered_qty);
                     l_preset_tier := NULL;

                     OPEN  c_prior_tiers(l_pbh_line_id, l_volume);
                     LOOP
                       FETCH c_prior_tiers INTO l_current_offer_tier_id,l_current_min_tier,l_current_max_tier,l_current_tier_value;
                       EXIT WHEN c_prior_tiers%NOTFOUND;

                       write_conc_log( ' l_current_offer_tier_id=' || l_current_offer_tier_id);



                        OPEN c_preset_tier(l_pbh_line_id,p_list_header_id,l_group_id);
                        FETCH c_preset_tier INTO l_preset_tier;
                        CLOSE c_preset_tier;


                        write_conc_log( ' l_preset_tier=' || l_preset_tier);
                        write_conc_log( ' l_current_tier_value=' || l_current_tier_value);

                        IF l_preset_tier is NOT NULL AND l_preset_tier > l_current_tier_value THEN
                        l_current_tier_value := l_preset_tier;
                        IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message('not reach preset tier:  ');
                          END IF;
                        write_conc_log(' not reach preset tier:');
                        END IF;


                       y1 := LEAST((l_previous_tier_max-l_current_min_tier),l_ordered_qty) ;
                       l_ordered_qty := l_ordered_qty - y1;
                       IF l_discount_type = '%' THEN
                          IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                             l_utilization_amount := l_utilization_amount +  y1* l_current_tier_value / 100;
                          ELSE
                             l_utilization_amount := l_utilization_amount +  y1*  l_unit_selling_price * l_current_tier_value / 100;
                          END IF;
                       ELSIF l_discount_type = 'AMT' THEN
                          IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                              l_utilization_amount := l_utilization_amount + y1 / l_unit_selling_price * l_current_tier_value ;
                          ELSE
                              l_utilization_amount := l_utilization_amount + y1* l_current_tier_value ;
                          END IF;
                       END IF;

                       --l_previous_tier_max := l_current_min_tier - 1 ;
                       l_previous_tier_max := l_current_min_tier;

                       IF G_DEBUG THEN
                          ozf_utility_pvt.debug_message(' retroactive flag is N, computing for prior tier id=' || l_current_offer_tier_id
                                      || ' y1='  || y1 || '     tier_min=' || l_current_min_tier
                                      || '     tier_max=' || l_current_max_tier || ' l_previous_tier_max: ' || l_previous_tier_max
                                      || '  l_new_utilization: ' || l_utilization_amount);
                       END IF;
                          write_conc_log(' retroactive flag is N, computing for prior tier id=' || l_current_offer_tier_id
                                      || ' y1='  || y1 || '     tier_min=' || l_current_min_tier
                                      || '     tier_max=' || l_current_max_tier || ' l_previous_tier_max: ' || l_previous_tier_max
                                      || '  l_new_utilization: ' || l_utilization_amount);

                       EXIT WHEN l_ordered_qty <= 0;

                     END LOOP;  -- end of loop for c_prior_tiers
                     CLOSE c_prior_tiers;

                  END IF; --  IF NVL(l_retroactive, 'N') = 'N' THEN


                  write_conc_log('l_utilization_amount : '||l_utilization_amount);


               l_utilization_amount := NVL(l_utilization_amount,0) - NVL(l_adj_amount,0);

                  l_act_budgets_rec.request_amount := l_utilization_amount;
                  l_act_budgets_rec.approved_amount := l_utilization_amount;
                  l_act_util_rec.exchange_rate_date := OZF_ACCRUAL_ENGINE.G_FAE_START_DATE;

                  ----end of booked orders

                  write_conc_log('calling ozf_fund_adjustment_pvt.process_act_budgets');

                  ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => x_return_status
                                                             ,x_msg_count       => x_msg_count
                                                             ,x_msg_data        => x_msg_data
                                                             ,p_act_budgets_rec => l_act_budgets_rec
                                                             ,p_act_util_rec    => l_act_util_rec
                                                             ,x_act_budget_id   => l_act_budget_id
                                                             );

                  write_conc_log('process_act_budgets returns: ' || x_return_status);

                  IF x_return_status <> fnd_api.g_ret_sts_success THEN
                     RETURN;
                  END IF;

               --END IF; --IF NVL(l_adjustment_exists,0) <> 1 THEN

           -- END IF; --IF l_gl_date IS NOT NULL THEN

            <<l_endofOrderloop>>
            NULL;

         END LOOP; --FOR j IN l_order_line_tbl.first .. l_order_line_tbl.last

      END IF; --IF l_order_line_tbl.count > 0 THEN

   END adjustment_volume_retro;
---------------------------------------------------------------------
-- PROCEDURE
--    adjust_backdated_offer
--
-- PURPOSE
--        This API is called from the concurrent process Post Backdated Adjusted Offer
-- PARAMETERS
--                  x_errbuf  OUT NOCOPY VARCHAR2 STANDARD OUT NOCOPY PARAMETER
--                  x_retcode OUT NOCOPY NUMBER STANDARD OUT NOCOPY PARAMETER
-- NOTES
-- HISTORY
--    4/18/2002  Mumu Pande  Create.
--    07/05/2005 feliu  fix following issues
--                          1. update discount in QP only when sysdate pass effective date.
----------------------------------------------------------------------
   PROCEDURE adjust_backdated_offer (x_errbuf OUT NOCOPY VARCHAR2,
                                     x_retcode OUT NOCOPY NUMBER,
                                     p_debug IN VARCHAR2    := 'N' ) IS
      l_return_status        VARCHAR2 (20);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2 (2000)        := NULL;
      l_api_name             VARCHAR2 (50)          := 'adjust_backdated_offer';
      l_full_name   CONSTANT VARCHAR2 (90)          :=    g_pkg_name
                                                       || '.'
                                                       || l_api_name;
      l_api_version  NUMBER := 1;
      l_index        NUMBER := 1;

      CURSOR c_adjusted_offer_cur IS
         SELECT offer_adjustment_id,
                list_header_id,
                effective_date,
                approved_date
           FROM ozf_offer_adjustments_b
          WHERE status_code = 'ACTIVE'
          AND NVL(budget_adjusted_flag,'N') = 'N'
          AND effective_date < approved_date; --query only backdated adjustments

      --get the products for an adjustment
      CURSOR c_adjusted_line_cur (p_offer_adjustment_id IN NUMBER) IS
         SELECT adj.original_discount, adj.modified_discount, lines.arithmetic_operator,
                adj.created_from_adjustments, lines.list_line_id, rltd.to_list_line_id
           FROM ozf_offer_adjustment_lines adj, qp_list_lines lines, ozf_offer_adj_rltd_lines rltd
          WHERE adj.offer_adjustment_id = p_offer_adjustment_id
            AND lines.list_line_type_code = 'DIS'
            AND lines.list_line_id = adj.list_line_id
            AND rltd.from_list_line_id = adj.list_line_id
            AND rltd.offer_adjustment_id = adj.offer_adjustment_id;

      CURSOR c_offer_info (p_list_header_id IN NUMBER) IS
         SELECT off.offer_id, qp.description, qp.NAME,
                nvl(off.transaction_currency_code,fund_request_curr_code) transaction_currency_code,
                off.reusable, off.offer_type,
                --kdass 09-DEC-2005 fix for bug 4872799
                trunc(off.start_date) start_date
                ,off.volume_offer_type
                ,qp.orig_org_id offer_org_id, off.transaction_currency_code offer_currency
        FROM qp_list_headers_all qp, ozf_offers off
          WHERE qp.list_header_id = p_list_header_id
            AND qp.list_header_id = off.qp_list_header_id;

      l_offer_info           c_offer_info%ROWTYPE;
      l_adjusted_line_cur    c_adjusted_line_cur%ROWTYPE;
      l_end_date             DATE;
      l_type                 VARCHAR2(7) := NULL;

      TYPE offerAdjustmentIdTbl IS TABLE OF ozf_offer_adjustments_b.offer_adjustment_id%TYPE;
      TYPE listHeaderIdTbl      IS TABLE OF ozf_offer_adjustments_b.list_header_id%TYPE;
      TYPE effectiveDateTbl     IS TABLE OF ozf_offer_adjustments_b.effective_date%TYPE;
      TYPE approvedDateTbl      IS TABLE OF ozf_offer_adjustments_b.approved_date%TYPE;

      l_offerAdjustmentIdTbl    offerAdjustmentIdTbl;
      l_listHeaderIdTbl         listHeaderIdTbl;
      l_effectiveDateTbl        effectiveDateTbl;
      l_approvedDateTbl         approvedDateTbl;


   BEGIN
      g_debug_flag := p_debug ;
      write_conc_log (' /*************************** ADJUST BD START *************************/');
      fnd_msg_pub.initialize;
      SAVEPOINT adjust_backdated_offer;
      --Get All Active Backdated Offer where budget adjusted flag = 'N'
      g_offer_id_tbl.delete;

      OPEN c_adjusted_offer_cur;
      LOOP

         FETCH c_adjusted_offer_cur BULK COLLECT INTO l_offerAdjustmentIdTbl, l_listHeaderIdTbl,
                                                      l_effectiveDateTbl, l_approvedDateTbl
                                    LIMIT g_bulk_limit;

         FOR i IN NVL(l_offerAdjustmentIdTbl.FIRST, 1) .. NVL(l_offerAdjustmentIdTbl.LAST, 0) LOOP

            SAVEPOINT new_adjustment;

            --get the offer id
            OPEN c_offer_info (l_listHeaderIdTbl(i));
            FETCH c_offer_info INTO l_offer_info;
            CLOSE c_offer_info;

            write_conc_log (
               '/******** '
            || 'Begin Adjusting For Offer NAME '''
            || l_offer_info.description
            || ''' SOURCE CODE '''
            || l_offer_info.NAME
            || ''' ******/'
            );

            /*removed code for future dated adjustments since offers team will be taking care of this.
            original code in version 120.19 */
            l_return_status :=fnd_api.g_ret_sts_success;
            write_conc_log (   l_full_name || ' : ' || 'Back Dated Adjusting ' || l_listHeaderIdTbl(i));
            -- Perform Adjustments for the already executed offer (for the orders raised between Effective Date and Approved Date)
            -- Fixed 10/23/2002 mpande
            IF l_offer_info.offer_type <> 'VOLUME_OFFER' THEN
                perform_adjustment(p_from_date=> l_effectiveDateTbl(i)
                                 ,p_to_date=> l_approvedDateTbl(i)
                                 ,p_qp_list_header_id=> l_listHeaderIdTbl(i)
                                 ,p_offer_adjustment_id=> l_offerAdjustmentIdTbl(i)
                                 ,x_return_status=> l_return_status
                                 ,x_msg_count=> l_msg_count
                                 ,x_msg_data=> l_msg_data
                                 );


                write_conc_log (   l_full_name || ' : ' || 'Return Status For perform_adjustment '  || l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                   ozf_utility_pvt.write_conc_log ('/****** '
                                               || 'Offer Adjustment Failed For Offer'
                                               || l_offer_info.description
                                               || ' SOURCE CODE '
                                               || l_offer_info.NAME
                                               || '" Offer Adjustment Id  "'
                                               || l_offerAdjustmentIdTbl(i)
                                               || ' with the following Errors *******/'
                                              );
                   ozf_utility_pvt.write_conc_log;
                   fnd_msg_pub.initialize;
                   ROLLBACK TO new_adjustment;
                   GOTO l_endofloop;
                END IF;
            END IF;

            --adjust orders between adjustment effective date and approval date

            ozf_utility_pvt.write_conc_log ('adjusted_rec.offer_adjustment_id: ' || l_offerAdjustmentIdTbl(i));

            OPEN c_adjusted_line_cur (l_offerAdjustmentIdTbl(i));
            LOOP
               FETCH c_adjusted_line_cur INTO l_adjusted_line_cur;
               EXIT WHEN c_adjusted_line_cur%NOTFOUND;

               ozf_utility_pvt.write_conc_log ('l_adjusted_line_cur.original_discount: ' || l_adjusted_line_cur.original_discount);

               l_type := NULL;

               --if new product
               IF l_adjusted_line_cur.created_from_adjustments = 'Y' THEN

                  /*kdass 20-JUL-05 Bug 4489233
                    For new product with:
                    1) adjustment effective date < adjustment approval date
                       adjust orders between adjustment effective date and adjustment approval date
                    2) adjustment approval date <= effective date <= sysdate
                       adjust orders between adjustment effective date and sysdate and set QP to new discount
                  */
                  l_end_date := l_approvedDateTbl(i);
                  l_type := 'product';

               --not a new product
               ELSIF (l_effectiveDateTbl(i) <= l_offer_info.start_date) THEN

                     --l_end_date := l_offer_info.start_date - 1;
                     l_end_date := l_offer_info.start_date;
                     l_type := 'retro';

               END IF;

               IF l_type IS NOT NULL AND l_offer_info.offer_type <> 'VOLUME_OFFER' THEN
                  --retroactive adjustment before offer start date or adjustment for new product
                  adjustment_net_accrual(p_api_version         => l_api_version
                                        ,p_offer_type          => l_offer_info.offer_type
                                        /*kdass 05-MAY-2006 bug 5205721
                                        ,p_product             => l_adjusted_line_cur.product_attr_value
                                        ,p_product_attr        => l_adjusted_line_cur.product_attribute
                                        */
                                        ,p_original_discount   => l_adjusted_line_cur.original_discount
                                        ,p_modified_discount   => l_adjusted_line_cur.modified_discount
                                        ,p_arithmetic_operator => l_adjusted_line_cur.arithmetic_operator
                                        ,p_start_date          => l_effectiveDateTbl(i)
                                        ,p_end_date            => l_end_date
                                        ,p_list_header_id      => l_listHeaderIdTbl(i)
                                        --kdass bug 8510774 - pass offer's OU and currency code
                                        ,p_offer_org_id        => l_offer_info.offer_org_id
                                        ,p_offer_currency      => l_offer_info.offer_currency
                                        ,p_list_line_id        => l_adjusted_line_cur.to_list_line_id
                                        ,p_offer_adjustment_id => l_offerAdjustmentIdTbl(i)
                                        ,p_type                => l_type
                                        ,x_return_status       => l_return_status
                                        ,x_msg_count           => l_msg_count
                                        ,x_msg_data            => l_msg_data
                                        );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     write_conc_log (' /*************************** DEBUG MESSAGE END *************************/');
                     ozf_utility_pvt.write_conc_log (' /****** '
                                                 || 'Backdated Offer Adjustment Failed For Offer'
                                                 || l_offer_info.description
                                                 || ' SOURCE CODE '
                                                 || l_offer_info.NAME
                                                 || '" Offer Adjustment Id  "'
                                                 || l_offerAdjustmentIdTbl(i)
                                                 || ' with the following Errors *******/'
                                                 );
                     ozf_utility_pvt.write_conc_log;
                     fnd_msg_pub.initialize;
                     ROLLBACK TO new_adjustment;
                     --kdass 21-JUN-2006 bug 5337761 - closed cursor on error
                     CLOSE c_adjusted_line_cur;
                     GOTO l_endofloop;
                  END IF;
               END IF;

            END LOOP;
            CLOSE c_adjusted_line_cur;

            --END IF;
            -- if every thing goes correct then commit this adjustment
            -- only close the adjustment whose effective date less than sysdate to fix bug 4015372

            IF l_return_status = fnd_api.g_ret_sts_success THEN --AND TRUNC(SYSDATE) >= l_effectiveDateTbl(i) THEN

               IF l_offer_info.offer_type = 'VOLUME_OFFER' THEN

                  --kdass bug 5610124 - retroactive adjustments for volume offer before offer start date
                  adjustment_volume_retro(p_api_version         => l_api_version
                                         ,p_start_date          => l_effectiveDateTbl(i)
                                         ,p_end_date            => l_offer_info.start_date
                                         ,p_list_header_id      => l_listHeaderIdTbl(i)
                                         --kdass bug 8510774 - pass offer's OU and currency code
                                         ,p_offer_org_id        => l_offer_info.offer_org_id
                                         ,p_offer_currency      => l_offer_info.offer_currency
                                         ,p_offer_adjustment_id => l_offerAdjustmentIdTbl(i)
                                         ,x_return_status       => l_return_status
                                         ,x_msg_count           => l_msg_count
                                         ,x_msg_data            => l_msg_data
                                         );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     ozf_utility_pvt.write_conc_log (' /****** '
                                                    || 'Backdated Offer Adjustment Failed For Offer'
                                                    || l_offer_info.description
                                                    || ' SOURCE CODE '
                                                    || l_offer_info.NAME
                                                    || '" Offer Adjustment Id  "'
                                                    || l_offerAdjustmentIdTbl(i)
                                                    || ' with the following Errors *******/'
                                                    );
                     ozf_utility_pvt.write_conc_log;
                     fnd_msg_pub.initialize;
                     ROLLBACK TO new_adjustment;
                     GOTO l_endofloop;
                  END IF;

                  volume_offer_adjustment(p_qp_list_header_id=> l_listHeaderIdTbl(i)
                                         ,p_vol_off_type    =>l_offer_info.volume_offer_type
                                         ,x_return_status=> l_return_status
                                         ,x_msg_count=> l_msg_count
                                         ,x_msg_data=> l_msg_data
                                         );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     ozf_utility_pvt.write_conc_log ('volume adjustment Failed'
                                                    || l_offer_info.description
                                                    || ' SOURCE CODE '
                                                    || l_offer_info.NAME
                                                    || '" Offer Adjustment Id  "'
                                                    || l_offerAdjustmentIdTbl(i)
                                                    || ' with the following Errors /'
                                                    );
                     ozf_utility_pvt.write_conc_log;
                     fnd_msg_pub.initialize;
                     ROLLBACK TO new_adjustment;
                     GOTO l_endofloop;
                  END IF;


                   ------------
                  volume_offer_util_adjustment(p_qp_list_header_id=> l_listHeaderIdTbl(i)
                                         ,x_return_status=> l_return_status
                                         ,x_msg_count=> l_msg_count
                                         ,x_msg_data=> l_msg_data
                                         );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     ozf_utility_pvt.write_conc_log ('volume utilization adjustment  Failed'
                                                    || l_offer_info.description
                                                    || ' SOURCE CODE '
                                                    || l_offer_info.NAME
                                                    || '" Offer Adjustment Id  "'
                                                    || l_offerAdjustmentIdTbl(i)
                                                    || ' with the following Errors /'
                                                    );
                     ozf_utility_pvt.write_conc_log;
                     fnd_msg_pub.initialize;
                     ROLLBACK TO new_adjustment;
                     GOTO l_endofloop;
                  END IF;
                  ------------

                  g_offer_id_tbl(l_index) := l_listHeaderIdTbl(i);
                  l_index := l_index + 1;

                  ozf_utility_pvt.write_conc_log ('after calling volume_offer_adjustment: ' || l_return_status);

               END IF; -- l_offer_info.offer_type = 'VOLUME_OFFER' THEN

               UPDATE ozf_offer_adjustments_b
               SET budget_adjusted_flag = 'Y',
                   object_version_number = object_version_number + 1,
                   status_code = 'CLOSED'
                   WHERE offer_adjustment_id = l_offerAdjustmentIdTbl(i);

               x_retcode                  := 0;
               x_errbuf                   := l_msg_data;
               COMMIT;

            END IF;  -- end of l_return_status = fnd_api.g_ret_sts_success

            <<l_endofloop>>

             write_conc_log( 'Return Status After Adjustment' || l_return_status);

         END LOOP; -- FOR i IN NVL(l_offerAdjustmentIdTbl.FIRST, 1) .. NVL(l_offerAdjustmentIdTbl.LAST, 0) LOOP

         EXIT WHEN c_adjusted_offer_cur%NOTFOUND;

      END LOOP; -- bulk fetch loop for c_adjusted_offer_cur
      write_conc_log (' /*************************** ADJUST BD END *************************/');
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO adjust_backdated_offer;
         x_retcode                  := 1;
         x_errbuf                   := l_msg_data;
         ozf_utility_pvt.write_conc_log;
         ozf_utility_pvt.write_conc_log (x_errbuf);
   END adjust_backdated_offer;


---------------------------------------------------------------------
   -- PROCEDURE
   --
   --
   -- PURPOSE
   --
   -- PARAMETERS
   --   p_from_date     IN DATE
   --   p_to_Date       IN DATE
   --   p_qp_list_header_id      IN NUMBER
   -- NOTES
   -- HISTORY
   --    4/18/2002  Mumu Pande  Create.
   --    11/11/2002 mkothari    Updated to handle adjustments for
   --                           Multi Tier (Accrual and Off Invoice)
   --                           Prom Goods,Order Value,Volume Offer
   --                           and Trade Deal.
--    07/05/2005 feliu  fix following issues
--                          1. change logic to calculate for adjustment. calculate the total adjustment based on
--                               new discount and original discount when utilization is created from accrual engine.
--                          2.  change the adjusmtent calculation for NEWPRICE.
--                          3.  Add adjustment for promotional offer.
----------------------------------------------------------------------
   PROCEDURE perform_adjustment (
      p_from_date             IN       DATE,
      p_to_date               IN       DATE,
      p_qp_list_header_id     IN       NUMBER,
      p_offer_adjustment_id   IN       NUMBER,
      p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false,
      p_commit                IN       VARCHAR2 := fnd_api.g_false,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_msg_count             OUT NOCOPY      NUMBER,
      x_msg_data              OUT NOCOPY      VARCHAR2
   ) IS
      l_act_budget_id          NUMBER;
      l_act_budgets_rec        ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec           ozf_actbudgets_pvt.act_util_rec_type;
      l_return_status          VARCHAR2 (1);
      l_util_amount            NUMBER;
      l_api_name               VARCHAR2 (50)                           := 'perform_adjustment';
      l_full_name     CONSTANT VARCHAR2 (90)                           :=    g_pkg_name
                                                                          || '.'
                                                                          || l_api_name;
      l_to_date                 DATE := p_to_date + 0.99999;
      l_org_id                  NUMBER; -- := TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10)) ;

      --kpatro 31-JUL-2006 bug 5375224 SQL ID# 19125146 - removed trunc from adjustment_date
      --for all cursors and added it to index OZF_FUNDS_UTILIZED_ALL_B_N24 to decrease the cost
      --and shared memory of the queries
      --nirprasa, 12.2 enhancement, replace amount with plan_curr_amount column.
      CURSOR c_bdadj_all_types IS
        SELECT  util.utilization_id,
                util.object_type,
                util.object_id,
                util.order_line_id,
                util.product_id,
                util.billto_cust_account_id,
                util.cust_account_id,
                util.fund_id,
                util.plan_currency_code,
                util.currency_code,
                util.price_adjustment_id,
                --NULL,
                DECODE (oe.arithmetic_operator,
                -- julou 03/30/2007 fix bug 5849584 "original discount = 0" causes "divisor is 0" exception
                       'NEWPRICE', DECODE(oe.adjusted_amount_per_pqty, 0, (ol.unit_selling_price - adjl.modified_discount) * ol.pricing_quantity, ((oe.operand - adjl.modified_discount) * plan_curr_amount /-oe.adjusted_amount_per_pqty)),
                       '%', DECODE(oe.operand, 0, adjl.modified_discount * ol.unit_selling_price * ol.pricing_quantity / 100, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand),
                       'AMT', DECODE(oe.operand, 0, adjl.modified_discount * ol.pricing_quantity, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand),
                       'LUMPSUM', DECODE(oe.operand, 0, adjl.modified_discount, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand)
--                                    'NEWPRICE', ((oe.operand - adjl.modified_discount) * amount /-oe.adjusted_amount_per_pqty),
--                                                            ((adjl.modified_discount - oe.operand)  * amount / oe.operand)
                       ) plan_curr_amount
                ,util.org_id
                ,util.ship_to_site_use_id
                ,util.bill_to_site_use_id
                ,util.reference_type
                ,util.reference_id
                ,util.exchange_rate_type
        FROM    ozf_funds_utilized_all_b util,
                ozf_temp_eligibility temp,
                ozf_offer_adjustment_lines adjl,
                oe_order_lines_all ol,
                oe_price_adjustments oe
        WHERE   util.plan_type = 'OFFR'
              AND product_id IS NOT NULL
              AND util.plan_id = p_qp_list_header_id
              AND util.product_id = DECODE (temp.eligibility_id, -1, util.product_id, temp.eligibility_id)
              AND temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
              -- yzhao 01/13/2006 fix bug 4939453 offer adjustment creates new list_line_id
              -- AND adjl.list_line_id = oe.list_line_id
              AND oe.list_line_id IN (SELECT from_list_line_id
                                      FROM   ozf_offer_adj_rltd_lines  adjr
                                      START WITH adjr.from_list_line_id = adjl.list_line_id
                                      AND   adjr.offer_adjustment_id = adjl.offer_adjustment_id
                                      CONNECT BY PRIOR adjr.from_list_line_id = adjr.to_list_line_id
                                     )
              AND adjl.offer_adjustment_id = p_offer_adjustment_id
              AND util.object_type = 'ORDER'
              AND util.price_adjustment_id = oe.price_adjustment_id
              AND oe.list_line_type_code <> 'PBH'
              AND adjustment_date BETWEEN p_from_date AND l_to_date
              AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT')
              AND ol.line_id = oe.line_id

        UNION ALL
        --for third party accrual.
        SELECT  util.utilization_id,
                util.object_type,
                util.object_id,
                util.order_line_id,
                util.product_id,
                util.billto_cust_account_id,
                util.cust_account_id,
                util.fund_id,
                util.plan_currency_code,
                util.currency_code,
                util.price_adjustment_id,
                --NULL,
                DECODE (oe.operand_calculation_code,
                                    'NEWPRICE', ((oe.operand - adjl.modified_discount) * plan_curr_amount /-oe.operand),
                                                            ((adjl.modified_discount - oe.operand)  * plan_curr_amount / oe.operand)
                       ) plan_curr_amount
                ,util.org_id
                ,util.ship_to_site_use_id
                ,util.bill_to_site_use_id
                ,util.reference_type
                ,util.reference_id
                ,util.exchange_rate_type
        FROM    ozf_funds_utilized_all_b util,
                ozf_temp_eligibility temp,
                ozf_offer_adjustment_lines adjl,
                OZF_RESALE_ADJUSTMENTS_ALL oe
        WHERE   util.plan_type = 'OFFR'
              AND product_id IS NOT NULL
              AND util.plan_id = p_qp_list_header_id
              AND util.product_id = DECODE (temp.eligibility_id, -1, util.product_id, temp.eligibility_id)
              AND temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
              AND adjl.list_line_id = oe.list_line_id
              AND util.price_adjustment_id = oe.resale_adjustment_id
              AND adjustment_date BETWEEN p_from_date AND l_to_date
              AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT')
              -- yzhao 01/13/2006 fix bug 4939453 offer adjustment creates new list_line_id
              AND adjl.offer_adjustment_id = p_offer_adjustment_id
              AND util.object_type = 'TP_ORDER';
        -- kdass  01/31/2005 fix for bug 4129759 - handle backdated adjustments for multi-tier discounts
      /*
        UNION ALL
        SELECT  util.utilization_id,
                util.object_type,
                util.object_id,
                util.order_line_id,
                util.product_id,
                util.billto_cust_account_id,
                util.cust_account_id,
                util.fund_id,
                util.plan_currency_code,
                assocs.price_adjustment_id,
                --NULL,
                DECODE (oe.arithmetic_operator,
                  'NEWPRICE', ((oe.operand - adjl.modified_discount) * amount /-oe.adjusted_amount_per_pqty),
                                               ((adjl.modified_discount - oe.operand)  * amount / oe.operand)
                       ) amount
        FROM    ozf_funds_utilized_all_b util,
                oe_price_adj_assocs assocs,
                oe_price_adjustments oe,
                ozf_offer_adjustment_lines adjl,
                ozf_temp_eligibility temp
        WHERE   util.plan_id = p_qp_list_header_id
            AND util.product_id = DECODE (temp.eligibility_id, -1, util.product_id, temp.eligibility_id)
            AND temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
            AND util.plan_type = 'OFFR'
            AND util.price_adjustment_id = assocs.price_adjustment_id
            AND oe.price_adjustment_id = assocs.rltd_price_adj_id
            AND oe.adjusted_amount IS NOT NULL
            AND oe.list_line_id = adjl.list_line_id
            AND oe.operand <> adjl.modified_discount
            AND adjustment_date BETWEEN p_from_date AND l_to_date
              AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT');
       --- (-1) is inserted in ozf_temp_eligibility for 'ALL' items, refer query above and query below
*/
       CURSOR c_bdadj_trade_deal IS
        SELECT   util.utilization_id,
                 util.object_type,
                 util.object_id,
                 util.order_line_id,
                 util.product_id,
                 util.billto_cust_account_id,           -- yzhao: 11.5.10 added billto_cust_account_id
                 util.cust_account_id,
                 util.fund_id,
                 util.plan_currency_code,
                 util.currency_code,
                 util.price_adjustment_id,
                 --NULL,
                 DECODE (oe.arithmetic_operator,
                -- julou 03/30/2007 fix bug 5849584 "original discount = 0" causes "divisor is 0" exception
                       'NEWPRICE', DECODE(oe.adjusted_amount_per_pqty, 0, (ol.unit_selling_price - adjl.modified_discount) * ol.pricing_quantity,  ((oe.operand - adjl.modified_discount) * plan_curr_amount /-oe.adjusted_amount_per_pqty)),
                       '%', DECODE(oe.operand, 0, adjl.modified_discount * ol.unit_selling_price * ol.pricing_quantity / 100, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand),
                       'AMT', DECODE(oe.operand, 0, adjl.modified_discount * ol.pricing_quantity, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand),
                       'LUMPSUM', DECODE(oe.operand, 0, adjl.modified_discount, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand)
--                                'NEWPRICE', ((oe.operand - adjl.modified_discount) * amount /-oe.adjusted_amount_per_pqty),
--                                                           ((adjl.modified_discount - oe.operand)  * amount / oe.operand)
                        ) plan_curr_amount
                ,util.org_id
                ,util.ship_to_site_use_id
                ,util.bill_to_site_use_id
                ,util.reference_type
                ,util.reference_id
                ,util.exchange_rate_type
        FROM     ozf_funds_utilized_all_b util,
                 ozf_temp_eligibility temp,
                 ozf_offer_adjustment_lines adjl,
                 oe_order_lines_all ol,
                 oe_price_adjustments oe
        WHERE    util.plan_type = 'OFFR'
             AND product_id IS NOT NULL
             AND util.plan_id = p_qp_list_header_id
             AND util.product_id = DECODE (temp.eligibility_id, -1, util.product_id, temp.eligibility_id)
             AND temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
             -- kdass 31-MAR-2006 fix bug 5101720 offer adjustment creates new list_line_id
             -- AND adjl.list_line_id = oe.list_line_id
             AND oe.list_line_id IN (SELECT from_list_line_id
                                     FROM   ozf_offer_adj_rltd_lines  adjr
                                     START WITH adjr.from_list_line_id = adjl.list_line_id
                                     AND   adjr.offer_adjustment_id = adjl.offer_adjustment_id
                                     CONNECT BY PRIOR adjr.from_list_line_id = adjr.to_list_line_id
                                    )
             AND adjl.offer_adjustment_id = p_offer_adjustment_id
             AND util.object_type = 'ORDER'
             AND util.price_adjustment_id = oe.price_adjustment_id
             AND adjustment_date BETWEEN p_from_date AND l_to_date
             AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT')
             AND ol.line_id = oe.line_id
        UNION ALL
                --for accrual in third party accrual.
        SELECT  util.utilization_id,
                util.object_type,
                util.object_id,
                util.order_line_id,
                util.product_id,
                util.billto_cust_account_id,
                util.cust_account_id,
                util.fund_id,
                util.plan_currency_code,
                util.currency_code,
                util.price_adjustment_id,
                --NULL,
                DECODE (oe.operand_calculation_code,
                                    'NEWPRICE', ((oe.operand - adjl.modified_discount) * plan_curr_amount /-oe.operand),
                                                            ((adjl.modified_discount - oe.operand)  * plan_curr_amount / oe.operand)
                       ) plan_curr_amount
                ,util.org_id
                ,util.ship_to_site_use_id
                ,util.bill_to_site_use_id
                ,util.reference_type
                ,util.reference_id
                ,util.exchange_rate_type
        FROM    ozf_funds_utilized_all_b util,
                ozf_temp_eligibility temp,
                ozf_offer_adjustment_lines adjl,
                OZF_RESALE_ADJUSTMENTS_ALL oe
        WHERE   util.plan_type = 'OFFR'
              AND product_id IS NOT NULL
              AND util.plan_id = p_qp_list_header_id
              AND util.product_id = DECODE (temp.eligibility_id, -1, util.product_id, temp.eligibility_id)
              AND temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
              AND adjl.list_line_id = oe.list_line_id
              AND util.price_adjustment_id = oe.resale_adjustment_id
              AND adjustment_date BETWEEN p_from_date AND l_to_date
              AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT')
              -- yzhao 01/13/2006 fix bug 4939453 offer adjustment creates new list_line_id
             AND adjl.offer_adjustment_id = p_offer_adjustment_id
             AND util.object_type = 'TP_ORDER'

        UNION -- for off invoice in direct sales
        SELECT   util.utilization_id,
                 util.object_type,
                 util.object_id,
                 util.order_line_id,
                 util.product_id,
                 util.billto_cust_account_id,           -- yzhao: 11.5.10 added billto_cust_account_id
                 util.cust_account_id,
                 util.fund_id,
                 util.plan_currency_code,
                 util.currency_code,
                 util.price_adjustment_id,
                 --NULL ,
                 DECODE (oe.arithmetic_operator,
                -- julou 03/30/2007 fix bug 5849584 "original discount = 0" causes "divisor is 0" exception
                       'NEWPRICE', DECODE(oe.adjusted_amount_per_pqty, 0, (ol.unit_selling_price - adjl.modified_discount) * ol.pricing_quantity,  ((oe.operand - adjl.modified_discount) * plan_curr_amount /-oe.adjusted_amount_per_pqty)),
                       '%', DECODE(oe.operand, 0, adjl.modified_discount * ol.unit_selling_price * ol.pricing_quantity / 100, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand),
                       'AMT', DECODE(oe.operand, 0, adjl.modified_discount * ol.pricing_quantity, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand),
                       'LUMPSUM', DECODE(oe.operand, 0, adjl.modified_discount, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand)
--                            'NEWPRICE', ((oe.operand - adjl.modified_discount) * amount /-oe.adjusted_amount_per_pqty),
--                                                            ((adjl.modified_discount_td - oe.operand)  * amount / oe.operand)
                        ) plan_curr_amount
                ,util.org_id
                ,util.ship_to_site_use_id
                ,util.bill_to_site_use_id
                ,util.reference_type
                ,util.reference_id
                ,util.exchange_rate_type
        FROM     ozf_funds_utilized_all_b util,
                 ozf_temp_eligibility temp,
                 ozf_offer_adjustment_lines adjl,
                 oe_order_lines_all ol,
                 oe_price_adjustments oe
        WHERE    util.plan_type = 'OFFR'
             AND product_id IS NOT NULL
             AND util.plan_id = p_qp_list_header_id
             AND util.product_id = DECODE (temp.eligibility_id, -1, util.product_id, temp.eligibility_id)
             AND temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
             -- kdass 31-MAR-2006 fix bug 5101720 offer adjustment creates new list_line_id
             -- AND adjl.list_line_id = oe.list_line_id
             AND oe.list_line_id IN (SELECT from_list_line_id
                                     FROM   ozf_offer_adj_rltd_lines  adjr
                                     START WITH adjr.from_list_line_id = adjl.list_line_id
                                     AND   adjr.offer_adjustment_id = adjl.offer_adjustment_id
                                     CONNECT BY PRIOR adjr.from_list_line_id = adjr.to_list_line_id
                                    )
             AND adjl.offer_adjustment_id = p_offer_adjustment_id
             AND util.object_type = 'ORDER'
             AND util.price_adjustment_id = oe.price_adjustment_id
             AND adjustment_date BETWEEN p_from_date AND l_to_date
             AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT')
             AND ol.line_id = oe.line_id

        UNION
                --for off invoice in third party accrual.
        SELECT  util.utilization_id,
                util.object_type,
                util.object_id,
                util.order_line_id,
                util.product_id,
                util.billto_cust_account_id,
                util.cust_account_id,
                util.fund_id,
                util.plan_currency_code,
                util.currency_code,
                util.price_adjustment_id,
                --NULL,
                DECODE (oe.operand_calculation_code,
                                    'NEWPRICE', ((oe.operand - adjl.modified_discount) * plan_curr_amount /-oe.operand),
                                                            ((adjl.modified_discount - oe.operand)  * plan_curr_amount / oe.operand)
                       ) plan_curr_amount
                ,util.org_id
                ,util.ship_to_site_use_id
                ,util.bill_to_site_use_id
                ,util.reference_type
                ,util.reference_id
                ,util.exchange_rate_type
        FROM    ozf_funds_utilized_all_b util,
                ozf_temp_eligibility temp,
                ozf_offer_adjustment_lines adjl,
                OZF_RESALE_ADJUSTMENTS_ALL oe
        WHERE   util.plan_type = 'OFFR'
              AND product_id IS NOT NULL
              AND util.plan_id = p_qp_list_header_id
              AND util.product_id = DECODE (temp.eligibility_id, -1, util.product_id, temp.eligibility_id)
              AND temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
              AND adjl.list_line_id_td = oe.list_line_id
              AND util.price_adjustment_id = oe.resale_adjustment_id
              AND adjustment_date BETWEEN p_from_date AND l_to_date
              AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT')
              -- yzhao 01/13/2006 fix bug 4939453 offer adjustment creates new list_line_id
              AND adjl.offer_adjustment_id = p_offer_adjustment_id
              AND util.object_type = 'TP_ORDER';


      CURSOR c_bdadj_order_value IS
        SELECT   util.utilization_id,
                 util.object_type,
                 util.object_id,
                 util.order_line_id,
                 util.product_id,
                 util.billto_cust_account_id,           -- yzhao: 11.5.10 added billto_cust_account_id
                 util.cust_account_id,
                 util.fund_id,
                 util.plan_currency_code,
                 util.currency_code,
                 util.price_adjustment_id,
                 --NULL,
                 DECODE(oe.operand, 0, adjl.modified_discount * ol.pricing_quantity, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand) plan_curr_amount
                ,util.org_id
                ,util.ship_to_site_use_id
                ,util.bill_to_site_use_id
                ,util.reference_type
                ,util.reference_id
                ,util.exchange_rate_type
        FROM     ozf_funds_utilized_all_b util,
                 ozf_offer_adjustment_lines adjl,
                 oe_order_lines_all ol,
                 oe_price_adjustments oe
        WHERE    util.plan_type = 'OFFR'
             AND util.plan_id  = p_qp_list_header_id
              -- kdass 31-MAR-2006 fix bug 5101720 offer adjustment creates new list_line_id
              -- AND adjl.list_line_id = oe.list_line_id
             AND oe.list_line_id IN (SELECT from_list_line_id
                                     FROM   ozf_offer_adj_rltd_lines  adjr
                                     START WITH adjr.from_list_line_id = adjl.list_line_id
                                     AND   adjr.offer_adjustment_id = adjl.offer_adjustment_id
                                     CONNECT BY PRIOR adjr.from_list_line_id = adjr.to_list_line_id
                                    )
             AND adjl.offer_adjustment_id = p_offer_adjustment_id
             AND util.object_type = 'ORDER'
             AND util.price_adjustment_id = oe.price_adjustment_id
             AND adjustment_date BETWEEN p_from_date AND l_to_date
             AND oe.line_id = ol.line_id
             AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT');

      CURSOR c_bdadj_promotion_value IS
        SELECT  util.utilization_id,
                util.object_type,
                util.object_id,
                util.order_line_id,
                util.product_id,
                util.billto_cust_account_id,
                util.cust_account_id,
                util.fund_id,
                util.plan_currency_code,
                util.currency_code,
                util.price_adjustment_id,
                --NULL,
                DECODE (oe.arithmetic_operator,
                -- julou 03/30/2007 fix bug 5849584 "original discount = 0" causes "divisor is 0" exception
                'NEWPRICE', DECODE(oe.adjusted_amount_per_pqty, 0, (ol.unit_selling_price - adjl.modified_discount) * ol.pricing_quantity,  ((oe.operand - adjl.modified_discount) * plan_curr_amount /-oe.adjusted_amount_per_pqty)),
                '%', DECODE(oe.operand, 0, adjl.modified_discount * ol.unit_selling_price * oe.range_break_quantity / 100, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand),
                'AMT', DECODE(oe.operand, 0, adjl.modified_discount * oe.range_break_quantity, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand),
                'LUMPSUM', DECODE(oe.operand, 0, adjl.modified_discount, (adjl.modified_discount - oe.operand) * plan_curr_amount / oe.operand)
--                'NEWPRICE', ((oe.operand - adjl.modified_discount) * amount /-oe.adjusted_amount_per_pqty),
--                (adjl.modified_discount * oe.range_break_quantity - oe.operand * oe.range_break_quantity)  * amount / (oe.operand *oe.range_break_quantity)
                       ) plan_curr_amount
                ,util.org_id
                ,util.ship_to_site_use_id
                ,util.bill_to_site_use_id
                ,util.reference_type
                ,util.reference_id
                ,util.exchange_rate_type
        FROM    ozf_funds_utilized_all_b util,
                ozf_temp_eligibility temp,
                ozf_offer_adjustment_lines adjl,
                oe_order_lines_all ol,
                oe_price_adjustments oe
        WHERE   util.plan_type = 'OFFR'
              AND product_id IS NOT NULL
              AND util.plan_id = p_qp_list_header_id
              AND util.product_id = DECODE (temp.eligibility_id, -1, util.product_id, temp.eligibility_id)
              AND temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
              -- kdass 31-MAR-2006 fix bug 5101720 offer adjustment creates new list_line_id
              -- AND adjl.list_line_id = oe.list_line_id
              AND oe.list_line_id IN (SELECT from_list_line_id
                                      FROM   ozf_offer_adj_rltd_lines  adjr
                                      START WITH adjr.from_list_line_id = adjl.list_line_id
                                      AND   adjr.offer_adjustment_id = adjl.offer_adjustment_id
                                      CONNECT BY PRIOR adjr.from_list_line_id = adjr.to_list_line_id
                                     )
              AND adjl.offer_adjustment_id = p_offer_adjustment_id
              AND util.object_type = 'ORDER'
              AND util.price_adjustment_id = oe.price_adjustment_id
              AND adjustment_date BETWEEN p_from_date AND l_to_date
              AND oe.line_id = ol.line_id
              AND util.utilization_type NOT IN('ADJUSTMENT','LEAD_ADJUSTMENT');

       TYPE backdate_adj_rec_type IS RECORD
       (
           utilization_id NUMBER,
           object_type VARCHAR2(20),
           object_id NUMBER,
           order_line_id NUMBER,
           product_id NUMBER,
           billto_cust_account_id NUMBER,
           cust_account_id NUMBER,
           fund_id NUMBER,
           --nirprasa, 12.1.1 enhancement, replace amount with plan_curr_amount
           plan_currency_code VARCHAR2(15),--nirprasa, query plan_curr_amount
           currency_code VARCHAR2(15),
           price_adjustment_id NUMBER,
           --volume_offer_tiers_id NUMBER,
           plan_curr_amount NUMBER := 0,
           org_id  NUMBER
          ,ship_to_site_use_id  NUMBER
          ,bill_to_site_use_id  NUMBER
          ,reference_type  VARCHAR2(20)
          ,reference_id   NUMBER
          ,exchange_rate_type  VARCHAR2(30)
       );

       TYPE backdate_adj_rec_tbl IS TABLE OF backdate_adj_rec_type INDEX BY BINARY_INTEGER;

       backdate_adj_rec backdate_adj_rec_tbl;

       CURSOR c_offer_info IS
         SELECT nvl(transaction_currency_code,fund_request_curr_code) transaction_currency_code,
                reusable,
                offer_type
         FROM   ozf_offers
         WHERE  qp_list_header_id = p_qp_list_header_id;

        -- added by feliu to fix  bug 4451500 and 4015372.
        --nirprasa, 12.1.1 enhancement, replace amount with plan_curr_amount
       CURSOR c_adj_amount(p_utilization_id IN NUMBER) IS
         SELECT  sum(plan_curr_amount)  adj_amt
         FROM ozf_funds_utilized_all_b
         --12/16/2005 changed by Feng
         WHERE orig_utilization_id = p_utilization_id
         --WHERE price_adjustment_id = p_price_adj_id
         --AND fund_id = p_fund_id
         --AND utilization_type ='ADJUSTMENT'
         AND utilization_type IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND  adjustment_type_id in(-4,-5,-1);

      --Added for bugfix 6278466
      CURSOR c_org_id (p_utilization_id IN NUMBER) IS
         SELECT org_id
         FROM   ozf_funds_utilized_all_b
         WHERE  utilization_id = p_utilization_id;

      -- get conversion type (nirprasa 12.1.1 fix)
      CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;
      l_offer_info             c_offer_info%ROWTYPE;
      l_index                  NUMBER                                  := 1;
      l_rate                   NUMBER;
      l_arithmetic_operator    VARCHAR2 (30);
      l_adj_amt                NUMBER;
      --nirprasa, 12.1.1 enhancement
      l_converted_util_amount  NUMBER;
      l_exchange_rate_type     VARCHAR2(30) := FND_API.G_MISS_CHAR;

   BEGIN
      write_conc_log (   l_full_name
                                      || ' : '
                                      || 'Adjusting From Date '
                                      || p_from_date
                                      || 'Adjusting To Date'
                                      || l_to_date);
      SAVEPOINT perform_adjustment;
      x_return_status            := fnd_api.g_ret_sts_success;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (': begin ');
      END IF;
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      OPEN c_offer_info;
      FETCH c_offer_info INTO l_offer_info;
      CLOSE c_offer_info;

      write_conc_log (   l_full_name
                                      || ' : '
                                      || 'Before Processing Product For Offer Adjustment Id '
                                      || p_offer_adjustment_id);


      --process_offer_product
      process_offer_product (p_offer_adjustment_id => p_offer_adjustment_id, x_return_status => l_return_status);
      write_conc_log (   l_full_name
                                      || ' : '
                                      || 'After Process Product Return Status'
                                      || l_return_status);


      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --IF l_source_from_par_flag = 'N' THEN

      -- updated by mkothari : 10-28-2002
      -- enhancement for 11.5.9: added BD adjustment for multi-tier accrual and off-invoice  AND
      --                         order_value(ORDER), trade deal(DEAL), promotional goods(OID) and volume offer(VOLUME_OFFER)

      IF l_offer_info.offer_type = 'DEAL' THEN --(for 'TRADE DEAL' , use a different cursor)
         write_conc_log ('Processing TRADE DEAL offer ...');
         OPEN c_bdadj_trade_deal;
      ELSIF l_offer_info.offer_type = 'ORDER' THEN --(for 'ORDER VALUE' , use a different cursor)
         write_conc_log ('Processing ORDER VALUE offer ...');
         OPEN c_bdadj_order_value;
      ELSIF l_offer_info.offer_type = 'OID' THEN --(for 'promotional  OFFER' , use a different cursor)
        write_conc_log ('Processing promotional OFFER offer ...');
       OPEN c_bdadj_promotion_value;
      ELSE
         write_conc_log ('Processing OID or ACCRUAL or OFF_INVOICE or Multi_Tier offer ...');
         OPEN c_bdadj_all_types;
      END IF;

      LOOP
         IF l_offer_info.offer_type = 'DEAL' THEN
            FETCH c_bdadj_trade_deal BULK COLLECT INTO backdate_adj_rec LIMIT g_bulk_limit;
         ELSIF l_offer_info.offer_type = 'ORDER' THEN
            FETCH c_bdadj_order_value BULK COLLECT INTO backdate_adj_rec LIMIT g_bulk_limit;
         ELSIF l_offer_info.offer_type = 'OID' THEN
           FETCH c_bdadj_promotion_value BULK COLLECT INTO backdate_adj_rec LIMIT g_bulk_limit;
         ELSE
            FETCH c_bdadj_all_types BULK COLLECT INTO backdate_adj_rec LIMIT g_bulk_limit;
         END IF;

         FOR i IN NVL(backdate_adj_rec.FIRST, 1) .. NVL(backdate_adj_rec.LAST, 0) LOOP

            write_conc_log (   'backdate_adj_rec.price_adjustment_id'
                                         || ' : '  || backdate_adj_rec(i).price_adjustment_id);

            -- added by feliu on 06/30/2005 .
            --OPEN c_adj_amount (backdate_adj_rec(i).price_adjustment_id,backdate_adj_rec(i).fund_id);
            OPEN c_adj_amount (backdate_adj_rec(i).utilization_id);
            FETCH c_adj_amount INTO l_adj_amt;
            CLOSE c_adj_amount;

            --Added for bugfix 6278466
            OPEN c_org_id(backdate_adj_rec(i).utilization_id);
            FETCH c_org_id INTO l_org_id;
            CLOSE c_org_id;

            l_util_amount := ozf_utility_pvt.currround(backdate_adj_rec(i).plan_curr_amount,backdate_adj_rec(i).plan_currency_code); -- in transactional currency
            write_conc_log (   l_full_name
                                         || ' : '
                                         || 'Inside LOOP, Util Amount '
                                         || l_util_amount || 'Adj Amount '||l_adj_amt);

            -- new utilization amount  minus existing utilization amount.
            l_util_amount := l_util_amount - NVL(l_adj_amt,0);

            write_conc_log (   l_full_name
                                         || ' : '
                                         || 'Inside LOOP, Util Amount '
                                         || l_util_amount);

            IF l_util_amount <> 0 THEN
               l_act_budgets_rec := NULL;
               l_act_util_rec  := NULL;
               l_act_budgets_rec.request_amount := l_util_amount;
               l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount;
                --nirprasa,12.2
                OPEN c_get_conversion_type(backdate_adj_rec(i).org_id);
                FETCH c_get_conversion_type INTO backdate_adj_rec(i).exchange_rate_type;
                CLOSE c_get_conversion_type;

                --nirprasa, 12.2 enhancement, convert the adjustment from transaction
                --to budget currency.

                IF g_debug_flag = 'Y' THEN
                   write_conc_log ('backdate_adj_rec(i).currency_code '||backdate_adj_rec(i).currency_code);
                   write_conc_log ('backdate_adj_rec(i).plan_currency_code '||backdate_adj_rec(i).plan_currency_code);
                END IF;

               IF backdate_adj_rec(i).currency_code = backdate_adj_rec(i).plan_currency_code THEN
                l_act_budgets_rec.parent_src_apprvd_amt := ozf_utility_pvt.currround(l_util_amount,backdate_adj_rec(i).currency_code);
               ELSE

                ozf_utility_pvt.convert_currency (
                        x_return_status => l_return_status,
                        p_from_currency => backdate_adj_rec(i).plan_currency_code,
                        p_to_currency   => backdate_adj_rec(i).currency_code,
                        p_conv_type     => backdate_adj_rec(i).exchange_rate_type, -- nirprasa added for bug 7030415
                        p_conv_date     => OZF_ACCRUAL_ENGINE.G_FAE_START_DATE,
                        p_from_amount   => l_util_amount,
                        x_to_amount     => l_converted_util_amount,
                        x_rate          => l_rate
                );

                IF g_debug_flag = 'Y' THEN
                   write_conc_log ('l_converted_util_amount '||l_converted_util_amount);
                END IF;

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log ('   D: post_adjust_to_budget() convert currency failed. No posting to budget. Return');
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
                END IF;
                l_act_budgets_rec.parent_src_apprvd_amt := l_converted_util_amount;

               END IF;
               --end nirprasa, 12.2 enhancement

               write_conc_log (l_full_name || ' : '
                                           || 'In Process Ozf_Act_budgets offer id'
                                           || p_qp_list_header_id);

               l_act_budgets_rec.act_budget_used_by_id := p_qp_list_header_id;
               l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
               l_act_budgets_rec.budget_source_type := 'OFFR';
               l_act_budgets_rec.budget_source_id := p_qp_list_header_id;
               l_act_budgets_rec.request_currency := backdate_adj_rec(i).plan_currency_code;
               l_act_budgets_rec.request_date := SYSDATE;
               l_act_budgets_rec.status_code := 'APPROVED';
               l_act_budgets_rec.user_status_id :=  ozf_Utility_Pvt.get_default_user_status (
                                                    'OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);
               l_act_budgets_rec.transfer_type := 'UTILIZED';
               l_act_budgets_rec.approval_date := SYSDATE;
               l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
               write_conc_log (l_full_name || ' : '
                                           || 'resourceid  '
                                           || l_act_budgets_rec.approver_id);

               l_act_budgets_rec.justification := fnd_message.get_string ('OZF', 'OZF_BACKDATE_AMOUNT_ADJUSTMENT');

               l_act_budgets_rec.parent_source_id := backdate_adj_rec(i).fund_id;
               l_act_budgets_rec.parent_src_curr := backdate_adj_rec(i).currency_code;
               l_act_util_rec.utilization_type :='ADJUSTMENT';

               IF l_util_amount > 0 THEN
                  l_act_util_rec.adjustment_type :='STANDARD'; -- Seeded Data for Backdated Positive Adj
                  l_act_util_rec.adjustment_type_id := -5; -- Seeded Data for Backdated Positive Adj
               ELSE
                  l_act_util_rec.adjustment_type :='DECREASE_EARNED'; -- Seeded Data for Backdated Negative Adj
                  l_act_util_rec.adjustment_type_id := -4; -- Seeded Data for Backdated Negative Adj
               END IF;

               l_act_util_rec.product_level_type := 'PRODUCT';
               l_act_util_rec.product_id  := backdate_adj_rec(i).product_id;
               -- yzhao: 02/23/2004 11.5.10 added billto_cust_account_id
               l_act_util_rec.billto_cust_account_id := backdate_adj_rec(i).billto_cust_account_id;
               l_act_util_rec.cust_account_id := backdate_adj_rec(i).cust_account_id;
               l_act_util_rec.org_id := l_org_id;                      -- Added for bugfix 6278466
               l_act_util_rec.price_adjustment_id := backdate_adj_rec(i).price_adjustment_id;
               --l_act_util_rec.volume_offer_tiers_id := backdate_adj_rec(i).volume_offer_tiers_id;
               --nirprasa,12.2 instead of sysdate use OZF_ACCRUAL_ENGINE.G_FAE_START_DATE
               l_act_util_rec.adjustment_date := OZF_ACCRUAL_ENGINE.G_FAE_START_DATE;
--SYSDATE;
               -- yzhao: 07/06/2004 11.5.10 populate order id, line id, original utilization id
               l_act_util_rec.object_type := backdate_adj_rec(i).object_type;
               l_act_util_rec.object_id := backdate_adj_rec(i).object_id;
               l_act_util_rec.order_line_id := backdate_adj_rec(i).order_line_id;
               l_act_util_rec.orig_utilization_id := backdate_adj_rec(i).utilization_id;
               l_act_util_rec.org_id := backdate_adj_rec(i).org_id;
               l_act_util_rec.ship_to_site_use_id  := backdate_adj_rec(i).ship_to_site_use_id;
               l_act_util_rec.bill_to_site_use_id  := backdate_adj_rec(i).bill_to_site_use_id;
               l_act_util_rec.reference_type  := backdate_adj_rec(i).reference_type;
               l_act_util_rec.reference_id   := backdate_adj_rec(i).reference_id;
               --nirprasa,12.2
               l_act_util_rec.currency_code              := backdate_adj_rec(i).currency_code;
               l_act_util_rec.plan_currency_code         := backdate_adj_rec(i).plan_currency_code;
               l_act_util_rec.fund_request_currency_code := l_offer_info.transaction_currency_code;
               l_act_util_rec.exchange_rate_type         := backdate_adj_rec(i).exchange_rate_type;
               --nirprasa,12.2
               -- l_act_util_rec.gl_date     := SYSDATE;

               ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => l_return_status
                                                          ,x_msg_count       => x_msg_count
                                                          ,x_msg_data        => x_msg_data
                                                          ,p_act_budgets_rec => l_act_budgets_rec
                                                          ,p_act_util_rec    => l_act_util_rec
                                                          ,x_act_budget_id   => l_act_budget_id
                                                          );
            END IF;
            write_conc_log (l_full_name || ' : '
                                        || 'Message :'
                                        || x_msg_data
                                        || 'Msg count'
                                        || x_msg_count
                                        || 'Return Status'
                                        || l_return_status
                           );
            --DBMS_OUTPUT.put_line (   'MESSAGE 11.5.9 (perform_adjustment) - BEGIN 2 :' || x_msg_data || 'msg count'|| x_msg_count || l_return_status);
            /* FOR_DEBUGGING
            --           IF l_return_status <> 'S' THEN
                           IF(x_msg_count > 0)THEN
                             FOR I IN 1 .. x_msg_count LOOP
                              fnd_msg_pub.GET
                              (p_msg_index      => FND_MSG_PUB.G_NEXT,
                               p_encoded        => FND_API.G_FALSE,
                               p_data           => x_msg_data,
                               p_msg_index_out  => l_index);
                               --ozf_utility_pvt.write_conc_log(l_full_name||' : '||i||x_msg_data);
                               DBMS_OUTPUT.put_line('****(PA):'||x_msg_data);
                             END LOOP;
                             fnd_msg_pub.initialize;
                           END IF;
            --           END IF;
            END FOR_DEBUGGING */
            --DBMS_OUTPUT.put_line (   'MESSAGE 11.5.9 (perform_adjustment) - END 2 :' || x_msg_data || 'msg count'|| x_msg_count || l_return_status);

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

         END LOOP; --FOR i IN NVL(backdate_adj_rec.FIRST, 1) .. NVL(backdate_adj_rec.LAST, 0) LOOP

         IF l_offer_info.offer_type = 'DEAL' THEN
            EXIT WHEN c_bdadj_trade_deal%NOTFOUND;
         ELSIF l_offer_info.offer_type = 'ORDER' THEN
            EXIT WHEN c_bdadj_order_value%NOTFOUND;
         ELSIF l_offer_info.offer_type = 'OID' THEN
           EXIT WHEN c_bdadj_promotion_value%NOTFOUND;
         ELSE
            EXIT WHEN c_bdadj_all_types%NOTFOUND;
         END IF;

      END LOOP;

      IF l_offer_info.offer_type = 'DEAL' THEN
         CLOSE c_bdadj_trade_deal;
      ELSIF l_offer_info.offer_type = 'ORDER' THEN
         CLOSE c_bdadj_order_value;
      ELSIF l_offer_info.offer_type = 'OID' THEN
        CLOSE c_bdadj_promotion_value;
      ELSE
         CLOSE c_bdadj_all_types;
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO perform_adjustment;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO perform_adjustment;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS THEN
         ROLLBACK TO perform_adjustment;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END perform_adjustment;

   -------------------------------------------------------------------
-- NAME
--    process_offer_product
-- PURPOSE
--
-- History
--    4/18/2002  Mumu Pande  Create.
--    05/09/2003 feliu  use bind variable for dynamic sql.
----------------------------------------------------------------
   PROCEDURE process_offer_product (p_offer_adjustment_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
      l_adjustment_product_sql   VARCHAR2 (32000) := NULL;
      l_temp_sql                 VARCHAR2 (32000) := NULL;
      l_return_status            VARCHAR2 (20);
      l_msg_count                NUMBER;
      l_msg_data                 VARCHAR2 (2000)  := NULL;
      l_api_name                 VARCHAR2 (60)    := 'process_offer_product';
      l_full_name                VARCHAR2 (100)   :=    g_pkg_name
                                                     || '.process_offer_product';
      l_denorm_csr             NUMBER;
      l_ignore                 NUMBER;
      l_stmt_denorm       VARCHAR2(32000) := NULL;

      -- get budget's product id and product family id
      CURSOR c_off_adj_lines IS
         SELECT offer_adjustment_line_id,
                qppa.product_attribute,
                qppa.product_attr_value
           FROM ozf_offer_adjustment_lines adjl, qp_pricing_attributes qppa
          WHERE adjl.offer_adjustment_id = p_offer_adjustment_id AND adjl.list_line_id = qppa.list_line_id;
   BEGIN
      -- ozf_utility_pvt.debug_message('enter validate_product_budget obj_id=' || p_object_id || ' budget_id=' || p_budget_id);

      x_return_status            := fnd_api.g_ret_sts_success;
      EXECUTE IMMEDIATE 'DELETE FROM ozf_temp_eligibility';
      write_conc_log (   l_full_name
                                      || ' : '
                                      || 'In Process Product '
                                      || p_offer_adjustment_id);
      ----DBMS_output.put_line (   'In Process Product'  || p_offer_adjustment_id);
      -- Get all product qualifiers for 'FUND'
      FOR product_rec IN c_off_adj_lines
      LOOP

        FND_DSQL.init;
        FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id,offer_adjustment_line_id) ');
        FND_DSQL.add_text('(SELECT  ''FUND'', ''N'', product_id,' );
        FND_DSQL.add_text(product_rec.offer_adjustment_line_id );
    FND_DSQL.add_text(' FROM ( ');

     -- For ALL items do a special processing , we donot eant to populate ozf_temp_wligibility
         -- with all items but insert -1 instead
         ----DBMS_output.put_line (   'product_rec.product_attribute '  || product_rec.product_attribute);
         ----DBMS_output.put_line (   'product_rec.product_attr_value '   || product_rec.product_attr_value);
         IF  product_rec.product_attribute = 'PRICING_ATTRIBUTE3' AND product_rec.product_attr_value = 'ALL' THEN
            --l_temp_sql                 := 'SELECT -1 product_id FROM DUAL';
            FND_DSQL.add_text('SELECT -1 product_id FROM DUAL');
        ----DBMS_output.put_line (' IN ALL products ');
         ELSE
            l_temp_sql                 := ozf_offr_elig_prod_denorm_pvt.get_sql (
                                             p_context=> 'ITEM',
                                             p_attribute=> product_rec.product_attribute,
                                             p_attr_value_from=> product_rec.product_attr_value, -- product_id
                                             --                  p_attr_value_from=> 199,
                                             p_attr_value_to=> NULL,
                                             p_comparison=> NULL,
                                             p_type=> 'PROD'
                                          );
         END IF;
         FND_DSQL.add_text('))');
     write_conc_log (   l_full_name
                                         || ' : '
                                         || 'Get Sql Returns'
                                         || l_temp_sql);
         ----DBMS_output.put_line (   'get sql returns'   || l_temp_sql);
         /*
     l_adjustment_product_sql   :=    'INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id,offer_adjustment_line_id) '
                                       || '(SELECT  ''FUND'', ''N'', product_id,'
                                       || product_rec.offer_adjustment_line_id
                                       || ' FROM ( '
                                       || l_temp_sql
                                       || '))';
        */

        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        --ozf_utility_pvt.debug_message('offer query: '|| l_stmt_denorm);
    write_conc_log (   l_full_name
                                         || ' : '
                                         || 'Insert Sql'
                                         || l_stmt_denorm);
         ----DBMS_output.put_line (   'sql'   || l_adjustment_product_sql);
         --EXECUTE IMMEDIATE l_adjustment_product_sql;
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);

      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_error;
   END process_offer_product;
   ---------------------------------------------------------------------
-- PROCEDURE
--  PROCESS_ACCRUAL
--
-- PURPOSE
--
-- PARAMETERS
--      p_earned_amt              IN       NUMBER -- in offer currency
--      p_qp_list_header_id   IN       NUMBER -- Offer Id
-- NOTES
-- HISTORY
--    4/18/2002  Mumu Pande  Create.
----------------------------------------------------------------------
   PROCEDURE process_accrual (
      p_earned_amt          IN       NUMBER,
      p_qp_list_header_id   IN       NUMBER,
      p_act_util_rec        IN       ozf_actbudgets_pvt.act_util_rec_type,
      p_act_budgets_rec     IN       ozf_actbudgets_pvt.act_budgets_rec_type:= NULL,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --    ADJUST_VOLUME_OFFER
   --
   -- PURPOSE
   --
   -- PARAMETERS
   --                  x_errbuf  OUT NOCOPY VARCHAR2 STANDARD OUT NOCOPY PARAMETER
   --                  x_retcode OUT NOCOPY NUMBER STANDARD OUT NOCOPY PARAMETER
   -- NOTES
   -- HISTORY
   --    7/30/2002  Mumu Pande  Create.
   --    06/02/2005 Feliu rewrite to fix following issue:
   --    1. First tier starts from 0.
  --     2. The calculation for tier amount is based on unit selling price, not on  unit list price.
  --     3. Partial shipment for volume offer.
  --     4. Returned order for volume offer.
  --     5. Order quantity is over max tier amount or quantity.

   ----------------------------------------------------------------------

   PROCEDURE adjust_volume_offer(
      x_errbuf        OUT NOCOPY      VARCHAR2
     ,x_retcode       OUT NOCOPY      NUMBER
     ,p_debug         IN VARCHAR2    := 'N')
     IS

     CURSOR  c_volume_off IS
      SELECT qp_list_header_id, volume_offer_type
       FROM ozf_offers
       WHERE offer_type = 'VOLUME_OFFER'
       AND status_code = 'ACTIVE';

     l_api_name                 CONSTANT VARCHAR2(30)   := 'adjust_volume_offer';
     l_full_name               VARCHAr2(70):= g_pkg_name ||'.'||l_api_name ||' : ';
     l_api_version              CONSTANT NUMBER                 := 1.0;
     l_return_status           VARCHAR2 (20);
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2 (2000)        := NULL;

     TYPE qpListHeaderIdTbl    IS TABLE OF ozf_offers.qp_list_header_id%TYPE;
     TYPE volumeOfferTypeTbl   IS TABLE OF ozf_offers.volume_offer_type%TYPE;

     l_qpListHeaderIdTbl       qpListHeaderIdTbl;
     l_volumeOfferTypeTbl      volumeOfferTypeTbl;

   BEGIN

      write_conc_log (' /*************************** DEBUG MESSAGE START *************************/' || l_api_name);
      SAVEPOINT adjust_volume_offer;

      --Get All Active Volume Offer, volume_type
      OPEN c_volume_off;
      LOOP
         FETCH c_volume_off BULK COLLECT INTO l_qpListHeaderIdTbl, l_volumeOfferTypeTbl
                            LIMIT g_bulk_limit;

         FOR i IN NVL(l_qpListHeaderIdTbl.FIRST, 1) .. NVL(l_qpListHeaderIdTbl.LAST, 0) LOOP

            FND_MSG_PUB.initialize;
            l_msg_count:= 0;
            l_msg_data := NULL;
            l_return_status := FND_API.g_ret_sts_success;

            write_conc_log(l_full_name ||'VOLUME OFFER ID'|| l_qpListHeaderIdTbl(i));

            BEGIN
            SAVEPOINT volume_offer;

               volume_offer_adjustment(p_qp_list_header_id => l_qpListHeaderIdTbl(i)
                                      ,p_vol_off_type      => l_volumeOfferTypeTbl(i)
                                      ,p_init_msg_list     => fnd_api.g_false
                                      ,p_commit            => fnd_api.g_false
                                      ,x_return_status     => l_return_status
                                      ,x_msg_count         => l_msg_count
                                      ,x_msg_data          => l_msg_data
                                      );

               write_conc_log(l_full_name ||'x_return_status'|| l_return_status);

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;

                ----------------------------------------
                volume_offer_util_adjustment(p_qp_list_header_id => l_qpListHeaderIdTbl(i)
                                      ,x_return_status     => l_return_status
                                      ,x_msg_count         => l_msg_count
                                      ,x_msg_data          => l_msg_data
                                      );

               write_conc_log(l_full_name ||'x_return_status'|| l_return_status);

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
               ----------------------------------------

            EXCEPTION
               WHEN FND_API.G_EXC_ERROR THEN
                  ROLLBACK TO VOLUME_OFFER;
                  OZF_UTILITY_PVT.write_conc_log(l_full_name ||' Volume Offer Adjustment Failed EX ==>'||'VOLUME OFFER '|| l_qpListHeaderIdTbl(i));
                  OZF_UTILITY_PVT.write_conc_log;
                  OZF_UTILITY_PVT.write_conc_log(' ');

               WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  ROLLBACK TO VOLUME_OFFER;
                  OZF_UTILITY_PVT.write_conc_log(l_full_name ||' Volume Offer Adjustment Failed UNEX ==>'||'VOLUME OFFER '|| l_qpListHeaderIdTbl(i));
                  OZF_UTILITY_PVT.write_conc_log;
                  OZF_UTILITY_PVT.write_conc_log(' ');

               WHEN OTHERS THEN
                  ROLLBACK TO VOLUME_OFFER;
                  OZF_UTILITY_PVT.write_conc_log(l_full_name ||' Volume Offer Adjustment Failed OT ==>'||'VOLUME OFFER '|| l_qpListHeaderIdTbl(i));
                  fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
                  OZF_UTILITY_PVT.write_conc_log;
                  OZF_UTILITY_PVT.write_conc_log(' ');
            END;

         END LOOP; --FOR i IN NVL(l_qpListHeaderIdTbl.FIRST, 1) .. NVL(l_qpListHeaderIdTbl.LAST, 0) LOOP

        EXIT WHEN c_volume_off%NOTFOUND;

      END LOOP; -- end volume offer bulk fetch loop

      write_conc_log (' /*************************** DEBUG MESSAGE END *************************/' || l_api_name );
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO adjust_volume_offer;
         OZF_UTILITY_PVT.write_conc_log;
         x_ERRBUF  := l_msg_data;
         x_RETCODE := 1;

      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO adjust_volume_offer;
         OZF_UTILITY_PVT.write_conc_log;
         x_ERRBUF  := l_msg_data;
         x_RETCODE := 1;

      WHEN OTHERS THEN
         ROLLBACK TO adjust_volume_offer;
         OZF_UTILITY_PVT.write_conc_log;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         x_ERRBUF  := l_msg_data;
         x_RETCODE := 1;

   END adjust_volume_offer;

   ---------------------------------------------------------------------
-- PROCEDURE
--  PROCESS_ACCRUAL
--
-- PURPOSE
--
-- PARAMETERS
--      p_earned_amt              IN       NUMBER -- in offer currency
--      p_qp_list_header_id   IN       NUMBER -- Offer Id
-- NOTES
-- HISTORY
--    7/31/2002  Mumu Pande  Create.
----------------------------------------------------------------------
   PROCEDURE process_accrual (
      p_earned_amt          IN       NUMBER,
      p_qp_list_header_id   IN       NUMBER,
      p_act_util_rec        IN       ozf_actbudgets_pvt.act_util_rec_type,
      p_act_budgets_rec     IN       ozf_actbudgets_pvt.act_budgets_rec_type := NULL,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2
   ) IS
      l_fund_amt_tbl            ozf_accrual_engine.ozf_fund_amt_tbl_type;
      l_api_name                VARCHAR2(30):= 'process_accrual';
      l_full_name               VARCHAR2(60):= g_pkg_name ||'.'||l_api_name||' : ' ;
      l_act_budgets_rec         ozf_actbudgets_pvt.act_budgets_rec_type := p_act_budgets_rec;
      l_act_util_rec            ozf_actbudgets_pvt.act_util_rec_type    := p_act_util_rec;
      l_earned_amount           NUMBER;
      l_old_earned_amount       NUMBER;
      l_header_id               NUMBER; -- order or invoice id
      l_line_id                 NUMBER; -- order or invoice id
      l_remaining_amt           NUMBER;
      l_count                   NUMBER                                  := 1;
      l_rate                    NUMBER;
      l_util_curr               VARCHAR2 (30);
      l_adj_amount              NUMBER;
      l_converted_adj_amount    NUMBER;
      j                         NUMBER; --loop counter
      l_off_name                VARCHAR2(240);
      l_off_description         VARCHAR2(2000);
      l_act_budget_id           NUMBER;
      l_earned_amount           NUMBER;

      CURSOR c_offer_info (p_list_header_id IN NUMBER) IS
         ----- fix bug 5675871
         SELECT qp.description, qp.name ,nvl(ofr.transaction_currency_code, ofr.fund_request_curr_code)
           FROM qp_list_headers_vl qp, ozf_offers ofr
           WHERE qp.list_header_id = p_list_header_id
             AND qp.list_header_id = ofr.qp_list_header_id;
/*
         SELECT description, name ,currency_code
           FROM qp_list_headers_vl
           WHERE list_header_id = p_list_header_id;
*/
      CURSOR c_adj_info (p_price_adj_id IN NUMBER,p_object_type VARCHAR2,p_order_line_id IN NUMBER) IS
         SELECT distinct billto_cust_account_id, cust_account_id,product_id,object_id,object_type,org_id
                ,ship_to_site_use_id,bill_to_site_use_id,exchange_rate_type --Added for bug 7030415
           FROM ozf_funds_utilized_all_b
           WHERE price_adjustment_id = p_price_adj_id
           AND object_type = p_object_type
           AND order_line_id = p_order_line_id;

      CURSOR c_tp_adj_info (p_price_adj_id IN NUMBER,p_object_type VARCHAR2) IS
         SELECT distinct billto_cust_account_id, cust_account_id,product_id,object_id,object_type,org_id
                ,ship_to_site_use_id,bill_to_site_use_id,exchange_rate_type --Added for bug 7030415
           FROM ozf_funds_utilized_all_b
           WHERE price_adjustment_id = p_price_adj_id
           AND object_type = p_object_type;

 -- Added for bug 7030415, cursor for currency conversion type.
      CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;

        l_exchange_rate_type VARCHAR2(30) := FND_API.G_MISS_CHAR;



       l_adj_info  c_adj_info%ROWTYPE;

   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
      SAVEPOINT process_accrual;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ('   Start'|| g_pkg_name||'.'||l_api_name);
      END IF;

      IF l_act_util_rec.object_type = 'TP_ORDER' THEN
         OPEN c_tp_adj_info (l_act_util_rec.price_adjustment_id,l_act_util_rec.object_type);
         FETCH c_tp_adj_info INTO l_adj_info;
         CLOSE c_tp_adj_info;
      ELSE
         OPEN c_adj_info (l_act_util_rec.price_adjustment_id,l_act_util_rec.object_type,l_act_util_rec.order_line_id);
         FETCH c_adj_info INTO l_adj_info;
         CLOSE c_adj_info;
      END IF;

      ozf_accrual_engine.calculate_accrual_amount (
         x_return_status=> x_return_status,
         p_src_id=> p_qp_list_header_id,
         p_earned_amt=> p_earned_amt,
         -- yzhao: 02/23/2004 11.5.10 added following 3 parameters to return customer-product qualified budgets only
         --        if none budget qualifies, then post to all budgets
         p_cust_account_type => 'BILL_TO',
         p_cust_account_id   => l_adj_info.billto_cust_account_id,
         p_product_item_id   => l_adj_info.product_id,
         x_fund_amt_tbl=> l_fund_amt_tbl
         );

      --dbms_output.put_line(' cal Status '||x_return_status);
      write_conc_log(l_full_name ||'Calculate Accrual Amt Return Status ' ||x_return_status);
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (l_full_name ||'Return Status' ||x_return_status);
      END IF;
      -- fetch offer info
      OPEN c_offer_info ( p_qp_list_header_id);
      FETCH c_offer_info INTO l_off_description, l_off_name,l_util_curr ;
      CLOSE c_offer_info;

      --- if this is not funded by a parent campaign or any budget the error out saying no budgte found
      IF l_fund_amt_tbl.COUNT = 0 OR x_return_status <> 'S' THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_FUND_NO_BUDGET_FOUND');
            fnd_message.set_token ('OFFER_NAME', l_off_name);
            fnd_msg_pub.ADD;
         END IF;
         --dbms_output.put_line(' In error ');
         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      ELSE
         --if some row is returned to adjust then
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message ('Begin Processing For Offer Adjustment: '||l_off_name);
         END IF;
         IF  (l_fund_amt_tbl.COUNT > 0) AND x_return_status = fnd_api.g_ret_sts_success THEN
             l_adj_amount               := 0; -- in offer currency
             l_remaining_amt            :=  ozf_utility_pvt.currround (
                                            p_earned_amt,
              --nirprasa,12.1.1             l_util_curr ); -- in offer currency
                                            l_act_util_rec.plan_currency_code); -- in transaction currency

              --nirprasa,12.1.1
            <<earned_adj_loop>>
            FOR j IN l_fund_amt_tbl.FIRST .. l_fund_amt_tbl.LAST
            LOOP
               IF g_recal_flag = 'N' THEN
                  IF l_fund_amt_tbl (j).earned_amount = 0 THEN
                      IF G_DEBUG THEN
                         ozf_utility_pvt.debug_message ('    D: 0 earned amount' );
                      END IF;
                      GOTO l_endofearadjloop;
                  END IF;
               END IF;
               IF ABS(l_remaining_amt) >= l_fund_amt_tbl (j).earned_amount THEN
                   l_adj_amount               := l_fund_amt_tbl (j).earned_amount; -- this is in offer and order currency
               ELSE
                  l_adj_amount               := l_remaining_amt;
               END IF;
               l_adj_amount            :=  ozf_utility_pvt.currround (
                                    l_adj_amount,
               --nirprasa,12.1.1    l_util_curr  ); -- in offer currency
                                    l_act_util_rec.plan_currency_code); -- in transaction currency
               --nirprasa,12.1.1

               l_remaining_amt            := l_remaining_amt - l_adj_amount;
                  -- conver the adjustment amount from offer currency to fund currency
                  --use l_adj_info


               --nirprasa,12.1.1 IF l_util_curr <> l_fund_amt_tbl (j).budget_currency THEN
               IF l_act_util_rec.plan_currency_code <> l_fund_amt_tbl (j).budget_currency THEN
                        ozf_utility_pvt.convert_currency (
                           x_return_status=> x_return_status,
                           p_from_currency=> l_act_util_rec.plan_currency_code, --nirprasa,12.1.1 l_util_curr,
                           p_to_currency=> l_fund_amt_tbl (j).budget_currency,
                           p_conv_date=> l_act_util_rec.exchange_rate_date,
                           p_conv_type=> l_adj_info.exchange_rate_type, --Added for bug 7030415
                           p_from_amount=> l_adj_amount,
                           x_to_amount=> l_converted_adj_amount,
                           x_rate=> l_rate
                        );
               END IF;
               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message( '   Adj amount coverted '|| l_converted_adj_amount
                        || ' l_adj amount'   || l_adj_amount);
               END IF;

               IF x_return_status <> fnd_api.g_ret_sts_success THEN
                  IF G_DEBUG THEN
                     -- ozf_utility_pvt.error_message( '  Convert Currency '||x_return_status);
                     ozf_utility_pvt.debug_message( '  Convert Currency '||x_return_status);
                  END IF;
                  IF x_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
               END IF;
               IF x_return_status = fnd_api.g_ret_sts_success THEN
                  IF l_act_util_rec.plan_currency_code = l_fund_amt_tbl (j).budget_currency THEN
                     l_act_budgets_rec.parent_src_apprvd_amt :=
                                 ozf_utility_pvt.currround (
                                    l_adj_amount,
                  --nirprasa,12.1.1 l_util_curr             );
                                    l_act_util_rec.plan_currency_code);
                  --nirprasa,12.1.1
                  ELSE
                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message('in not equal currency');
                     END IF;
                     l_act_budgets_rec.parent_src_apprvd_amt :=
                                 ozf_utility_pvt.currround (
                                    l_converted_adj_amount,
                                    l_fund_amt_tbl (j).budget_currency );
                  END IF;

                  l_act_util_rec.product_id := l_adj_info.product_id;
                  l_act_util_rec.object_type := l_adj_info.object_type;
                  l_act_util_rec.object_id   := l_adj_info.object_id;
                  l_act_util_rec.product_level_type := 'PRODUCT';
                  -- yzhao: 11.5.10 02/23/2004 added billto_cust_account_id
                  l_act_util_rec.billto_cust_account_id := l_adj_info.billto_cust_account_id;
                  l_act_util_rec.cust_account_id := l_adj_info.cust_account_id;
                  l_act_util_rec.utilization_type := 'ADJUSTMENT';
                  l_act_util_rec.org_id := l_adj_info.org_id;
                  l_act_util_rec.ship_to_site_use_id := l_adj_info.ship_to_site_use_id;
                  l_act_util_rec.bill_to_site_use_id := l_adj_info.bill_to_site_use_id;

                  l_act_budgets_rec.justification := fnd_message.get_string ('OZF', 'OZF_ACR_VOL_BDADJ');
                  l_act_budgets_rec.transfer_type := 'UTILIZED';
                  l_act_budgets_rec.request_date := SYSDATE;
                  l_act_budgets_rec.status_code := 'APPROVED';
                  l_act_budgets_rec.user_status_id :=
                            ozf_utility_pvt.get_default_user_status (
                                'OZF_BUDGETSOURCE_STATUS',
                                l_act_budgets_rec.status_code  );
                  l_act_budgets_rec.budget_source_type := 'OFFR';
                  l_act_budgets_rec.budget_source_id := p_qp_list_header_id;
                  l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                  l_act_budgets_rec.act_budget_used_by_id := p_qp_list_header_id;
                  l_act_budgets_rec.parent_src_curr := l_fund_amt_tbl (j).budget_currency;
                  l_act_budgets_rec.parent_source_id := l_fund_amt_tbl (j).ofr_src_id;
                  l_act_budgets_rec.request_amount :=
ozf_utility_pvt.currround (l_adj_amount, l_act_util_rec.plan_currency_code);
                  --nirprasa,12.2 ozf_utility_pvt.currround (l_adj_amount, l_util_curr);

                  l_act_budgets_rec.request_currency := l_act_util_rec.plan_currency_code; --l_util_curr;
                  l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount;
                  l_act_budgets_rec.approved_in_currency := l_act_util_rec.plan_currency_code; --l_util_curr;
                  l_act_util_rec.fund_request_currency_code := l_util_curr;
                  --nirprasa,12.2 end.

                  IF l_adj_amount > 0 THEN
                     l_act_util_rec.adjustment_type :='STANDARD'; -- Seeded Data for Backdated Positive Adj
                     l_act_util_rec.adjustment_type_id := -7; -- Seeded Data for Backdated Positive Adj
                  ELSE
                     l_act_util_rec.adjustment_type :='DECREASE_EARNED'; -- Seeded Data for Backdated Negative Adj
                     l_act_util_rec.adjustment_type_id := -6; -- Seeded Data for Backdated Negative Adj
                  END IF;

                 IF l_act_budgets_rec.request_amount <> 0 THEN -- fix bug 4720113
                    ozf_fund_Adjustment_pvt.process_Act_budgets(
                                 x_return_status=> x_return_status,
                                 x_msg_count=> x_msg_count,
                                 x_msg_data=> x_msg_data,
                                 p_act_budgets_rec=> l_act_budgets_rec,
                                 p_act_util_rec=> l_act_util_rec,
                                 x_act_budget_id=> l_act_budget_id
                             );
                  write_conc_log(l_full_name ||'Process Act Budget' ||x_return_status);
                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message('create utlization '|| x_return_status);
                  END IF;

                  IF x_return_status <> fnd_api.g_ret_sts_success THEN
                     IF x_return_status = fnd_api.g_ret_sts_error THEN
                        RAISE fnd_api.g_exc_error;
                     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                     END IF;
                  END IF;
                END IF;  --l_act_budgets_rec.request_amount <> 0
            --- quit when the total earned amount is adjusted
              END IF;
            <<l_endofearadjloop>>
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message ( 'l_remaining_amt ' || l_remaining_amt
                        || 'l_adj amount' || l_adj_amount || 'fund_id '|| l_fund_amt_tbl (j).ofr_src_id );
            END IF;
            EXIT WHEN l_remaining_amt = 0;
            END LOOP earned_adj_loop;
         END IF; --end of check for table count >0
      END IF; -- end of check for count
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO process_accrual;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO process_accrual;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS THEN
         ROLLBACK TO process_accrual;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);

   END process_accrual;

   ---------------------------------------------------------------------
-- PROCEDURE
--
--
-- PURPOSE
--
-- PARAMETERS
--   p_from_date     IN DATE
--        p_qp_list_header_id      IN NUMBER
-- NOTES
-- HISTORY
--    4/18/2002  Mumu Pande  Create.
----------------------------------------------------------------------
   PROCEDURE process_claim_autopay (
      p_from_date           IN       DATE,
      p_qp_list_header_id   IN       NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2
   ) /*
     select product_id , cust_account_id , fund_id , sum(DECODE(adjl.arithmetic_operator,'AMOUNT', (adjl.modified_discount - adjl.original_discount),
       (( adjl.modified_discount - adjl.original_discount)* amount/adjl.original_discount))) AMount
      from ozf_funds_utilized_all_vl util , ozf_temp_eligibility  temp,
      ozf_offer_adjustment_lines adjl
      where util.plan_type = 'OFFR'
      and product_id IS NOT NULL and util.plan_id = 7909
      and util.product_id = temp.eligibility_id
      and temp.offer_adjustment_line_id = adjl.offer_adjustment_line_id
      and adjustment_date BETWEEN from_date and to_date
      group by util.fund_id, util.product_id, util.fund_id,util.cust_account_id
      */ IS
   /******************Also pass the adjsutment_type_id */
   BEGIN
      NULL;
   /*
         get the last autppay date
     get the amount cursor from the from_date to  the last autopay date
     Call claims Autopay API to settle the claim with proper date
     Perform Error Handling
     */
   END process_claim_autopay;


   ---------------------------------------------------------------------
-- FUNCTION
--  get_order_amount_quantity
--
-- PURPOSE -- Called from Offers UI
--
-- PARAMETERS
--                    p_list_header_id IN NUMBER,
--                    x_order_amount OUT NOCOPY NUMBER,
-- NOTES
-- HISTORY
--    10/18/2002  Mumu Pande  Create.
----------------------------------------------------------------------

   FUNCTION get_order_amount_quantity(  p_list_header_id IN NUMBER
                    )
                    RETURN NUMBER
   IS
   l_new_discount  NUMBER;
   l_new_operator  VARCHAR2(30);
   l_old_discount  NUMBER;
   l_old_operator  VARCHAR2(30);
   l_return_status VARCHAR2(1);
   l_order_amount_quantity NUMBER;
   l_volume_type    VARCHAR2(30);

   BEGIN

      l_order_amount_quantity:= get_order_amount_quantity(
                    p_list_header_id => p_list_header_id ,
                    x_order_amount_quantity => l_order_amount_quantity,
                    x_new_discount =>l_new_discount,
                    x_new_operator => l_new_operator,
                    x_old_discount =>l_old_discount,
                    x_old_operator =>l_old_operator,
                    x_volume_type =>l_volume_type,
                    x_return_status =>l_return_status
                    );
      RETURN l_order_amount_quantity ;
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
      RETURN 0;
   END;

   ---------------------------------------------------------------------
-- FUNCTION
--  get_order_amount_quntity
--
-- PURPOSE
--
-- PARAMETERS
--                    p_list_header_id IN NUMBER,
--                    x_order_amount OUT NOCOPY NUMBER,
--                    x_new_discount OUT NOCOPY NUMBER,
--                    x_new_operator OUT NOCOPY VARCHAR2,
--                    x_old_discount OUT NOCOPY NUMBER,
--                    x_old_operator OUT NOCOPY VARCHAR2,
--                    x_return_status OUT NOCOPY VARCHAR2
-- NOTES
-- HISTORY
--    8/6/2002  Mumu Pande  Create.
--    06/08/2005  feliu  change cursor to handle case when g_order_gl_phase ='INVOICED';
----------------------------------------------------------------------

   FUNCTION get_order_amount_quantity(  p_list_header_id IN NUMBER,
                    x_order_amount_quantity OUT NOCOPY NUMBER,
                    x_new_discount OUT NOCOPY NUMBER,
                    x_new_operator OUT NOCOPY VARCHAR2,
                    x_old_discount OUT NOCOPY NUMBER,
                    x_old_operator OUT NOCOPY VARCHAR2,
                    x_volume_type  OUT NOCOPY VARCHAR2,
                    x_return_status OUT NOCOPY VARCHAR2
                    ) RETURN NUMBER
   IS
     l_api_name                VARCHAr2(30):= 'get_order_amount';

     /*
     kdass 19-JUL-2004 Fix for 11.5.9 Bug 3742174
     Currently volume offer adjustment only considers shipped quantity. If total shipped quantity reaches new tier,
     the tier is adjusted. However for 'bill-only' order, there is no shipment involved, so shipped quantity is null,
     tier is never adjusted.
     To handle all possible scenarios,
     A) If profile 'OZF: Create GL Entries for Orders' is set to 'Shipped'
       1) if order line status is 'CLOSED' or 'INVOICED',
         a) if invoiced_quantity is not null, use invoiced_quantity
         b) else if shipped_quantity is not null, use shipped_quantity
         c) else, use nvl(ordered_quantity, 0)
       2) if order line status is 'SHIPPED',
         a) shipped_quantity is not null, use shipped_quantity
         b) else, use nvl(ordered_quantity, 0)
     B) A) If profile 'OZF: Create GL Entries for Orders' is set to 'Invoiced'
       1) if order line status is 'CLOSED' or 'INVOICED',
         a) if invoiced_quantity is not null, use invoiced_quantity
         b) else if shipped_quantity is not null, use shipped_quantity
         c) else, use nvl(ordered_quantity, 0)
     This cursor returns the order amount or order quantity depending on the value of the parameter p_amt_qty
     */

     CURSOR  c_order_amount_qty (p_list_header_id IN NUMBER, p_amt_qty IN VARCHAR2) IS
      --kdass 11-MAY-2005 Bug 4362575 changed unit_selling_price to unit_list_price
      SELECT SUM(DECODE(p_amt_qty, 'amt', line.unit_list_price, 1)*
                      NVL(line.invoiced_quantity, NVL(line.shipped_quantity, NVL(line.ordered_quantity, 0)))
                ), header.transactional_curr_code
      FROM oe_order_lines_all line, oe_price_Adjustments adj, oe_order_headers_all header
      WHERE  line.line_id = adj.line_id
         AND line.header_id = header.header_id
         AND line.header_id = adj.header_id
         AND adj.list_header_id = p_list_header_id
         AND adj.applied_flag = 'Y'
         AND line.cancelled_flag = 'N'
         AND line.booked_flag = 'Y'
         GROUP BY header.transactional_curr_code;
         --AND flow_status_code in ('CLOSED','INVOICED','SHIPPED');

     -- For g_order_gl_phase ='INVOICED', only calculate order amount when flow_status_code = 'INVOICED'.
    -- and 'CLOSED').
     CURSOR  c_invoice_amount_qty (p_list_header_id IN NUMBER, p_amt_qty IN VARCHAR2) IS
      --kdass 11-MAY-2005 Bug 4362575 changed unit_selling_price to unit_list_price
      SELECT SUM(DECODE(p_amt_qty, 'amt', line.unit_list_price, 1)*
                      NVL(line.invoiced_quantity, NVL(line.shipped_quantity, NVL(line.ordered_quantity, 0)))
                ), header.transactional_curr_code
      FROM oe_order_lines_all line, oe_price_Adjustments adj, oe_order_headers_all header
      WHERE  line.line_id = adj.line_id
         AND line.header_id = header.header_id
         AND line.header_id = adj.header_id
         AND adj.list_header_id = p_list_header_id
         AND adj.applied_flag = 'Y'
         AND line.cancelled_flag = 'N'
         AND line.booked_flag = 'Y'
         AND line.flow_status_code in ('CLOSED','INVOICED')
         GROUP BY header.transactional_curr_code;

/* remove it since we need to query tier in calling procedure. by feliu on 06/08/2005.
     CURSOR  c_current_discount (p_list_header_id IN NUMBER,
                                  p_order_amount IN NUMBER)    IS
      SELECT discount,
             discount_type_code
        FROM ozf_volume_offer_tiers
       WHERE p_order_amount BETWEEN
             tier_value_from AND  tier_value_to
         AND qp_list_header_id = p_list_header_id;
*/
     CURSOR  c_old_discount (p_list_header_id IN NUMBER)   IS
      SELECT distinct operand,
             arithmetic_operator
        FROM qp_modifier_summary_v qp
       WHERE list_header_id = p_list_header_id;

     CURSOR  c_volume_type (p_list_header_id IN NUMBER)   IS
      SELECT distinct volume_type
        FROM ozf_volume_offer_tiers tier
       WHERE qp_list_header_id = p_list_header_id;

     CURSOR c_offer_curr IS
      SELECT nvl(transaction_currency_code,fund_request_curr_code)
        FROM ozf_offers
       WHERE qp_list_header_id = p_list_header_id;

     l_volume_type  VARCHAR2(30);
     l_offer_curr   VARCHAR2(30);
     l_order_curr   VARCHAR2(30);
     l_conv_amount  NUMBER;
     l_rate         NUMBER;

     --profile: 'OZF: Create GL Entries for Orders'    -- change as global constant by feliu on 06/21/2005
   --  l_order_gl_phase CONSTANT VARCHAR2 (15) := NVL(fnd_profile.VALUE ('OZF_ORDER_GLPOST_PHASE'), 'SHIPPED');

   BEGIN
         x_return_status            := fnd_api.g_ret_sts_success;

         OPEN c_volume_type(p_list_header_id);
         FETCH c_volume_type  INTO l_volume_type;
         CLOSE c_volume_type;
         x_volume_type := l_volume_type;

         OPEN c_offer_curr;
         FETCH c_offer_curr INTO l_offer_curr;
         CLOSE c_offer_curr;

         -- pricing_attr12 = AMOUNT
         IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
              IF g_order_gl_phase ='SHIPPED' THEN
                  OPEN c_order_amount_qty(p_list_header_id, 'amt');
                  FETCH c_order_amount_qty  INTO x_order_amount_quantity, l_order_curr;
                  CLOSE c_order_amount_qty;
              ELSE
                  OPEN c_invoice_amount_qty(p_list_header_id, 'amt');
                  FETCH c_invoice_amount_qty  INTO x_order_amount_quantity, l_order_curr;
                  CLOSE c_invoice_amount_qty;
            END IF;

            --kdass 31-MAR-2006 bug 5101720 convert from order currency to offer currency
            IF l_offer_curr <> l_order_curr THEN

               ozf_utility_pvt.write_conc_log('order curr: ' || l_order_curr);
               ozf_utility_pvt.write_conc_log('offer curr: ' || l_offer_curr);
               ozf_utility_pvt.write_conc_log('order amount: ' || x_order_amount_quantity);

               ozf_utility_pvt.convert_currency (x_return_status => x_return_status
                                                ,p_from_currency => l_order_curr
                                                ,p_to_currency   => l_offer_curr
                                                ,p_from_amount   => x_order_amount_quantity
                                                ,x_to_amount     => l_conv_amount
                                                ,x_rate          => l_rate
                                                );

               IF x_return_status <> fnd_api.g_ret_sts_success THEN
                  ozf_utility_pvt.write_conc_log('x_return_status: ' || x_return_status);
                  RETURN NULL;
               END IF;

               x_order_amount_quantity := l_conv_amount;
               write_conc_log ('order amount after currency conversion: ' || x_order_amount_quantity);

            END IF;

         ELSE -- quantity
            IF g_order_gl_phase ='SHIPPED' THEN
                OPEN c_order_amount_qty(p_list_header_id, 'qty');
                 FETCH c_order_amount_qty  INTO x_order_amount_quantity, l_order_curr;
                 CLOSE c_order_amount_qty;
            ELSE
                OPEN c_invoice_amount_qty(p_list_header_id, 'qty');
                FETCH c_invoice_amount_qty  INTO x_order_amount_quantity, l_order_curr;
                CLOSE c_invoice_amount_qty;
            END IF;
         END IF;

/*
         OPEN c_current_discount(p_list_header_id,x_order_amount_quantity);
         FETCH c_current_discount  INTO x_new_discount,x_new_operator;
         CLOSE c_current_discount;
  */
         --Get the existing Tier % or amount value executing in QP x2 .
         OPEN c_old_discount(p_list_header_id);
         FETCH c_old_discount  INTO x_old_discount,x_old_operator;
         CLOSE c_old_discount;

         RETURN x_order_amount_quantity;


   EXCEPTION
   WHEN OTHERS THEN
     x_return_status            := fnd_api.g_ret_sts_error;
     RETURN  NULL;
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
     END IF;
   END ;


   ---------------------------------------------------------------------
-- PROCEDURE
--     volume_offer_adjustment
--
-- PURPOSE
--  adjustment for volume offer.

-- PARAMETERS
--   p_qp_list_header_id      IN NUMBER
--   p_offer_adjustment_id   IN       NUMBER,
--   p_retroactive             IN       VARCHAR2,
--  p_vol_off_type           IN        VARCHAR2

-- NOTES
-- HISTORY
--    6/10/2005  feliu  Create.
-- for backdated adjustment, only make volume adjustment for these orders after effective date.
----------------------------------------------------------------------

   PROCEDURE volume_offer_adjustment (
      p_qp_list_header_id     IN       NUMBER,
      p_vol_off_type          IN        VARCHAR2,
      p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false,
      p_commit                IN       VARCHAR2 := fnd_api.g_false,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_msg_count             OUT NOCOPY      NUMBER,
      x_msg_data              OUT NOCOPY      VARCHAR2
   ) IS

     CURSOR  c_old_price_Adj(p_list_header_id IN NUMBER)  IS
      SELECT old_Adj_amt,order_line_id, price_adjustment_id,gl_date,object_type
             ,object_id, gl_posted_flag, utilization_id FROM
      ( SELECT  sum(plan_curr_amount)  old_Adj_amt
            , order_line_id
            ,min(price_adjustment_id) price_adjustment_id
            ,min(gl_date) gl_date
             ,object_type
             ,object_id
            ,'Y' gl_posted_flag
            ,min(utilization_id) utilization_id
        FROM ozf_funds_utilized_all_b
        WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
        -- AND gl_date is not NULL -- only process shipped or invoiced order.
         AND gl_posted_flag IN('Y','F')
         AND utilization_type IN ( 'ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
         GROUP BY order_line_id,object_type,object_id
         UNION ALL
         SELECT  sum(plan_curr_amount)  old_Adj_amt
            , order_line_id
            ,min(price_adjustment_id) price_adjustment_id
            ,min(gl_date) gl_date
             ,object_type
             ,object_id
             ,'X' gl_posted_flag
             ,min(utilization_id) utilization_id
         FROM ozf_funds_utilized_all_b
         WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND gl_posted_flag = 'X'
         AND utilization_type IN ('SALES_ACCRUAL','ADJUSTMENT','ACCRUAL')
         AND price_adjustment_id IS NOT NULL
         GROUP BY order_line_id,object_type,object_id
         UNION ALL
         SELECT  sum(plan_curr_amount)  old_Adj_amt
            , order_line_id
            ,min(price_adjustment_id) price_adjustment_id
            ,min(gl_date) gl_date
             ,object_type
             ,object_id
             ,NULL gl_posted_flag
             ,min(utilization_id) utilization_id
         FROM ozf_funds_utilized_all_b
         WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND gl_posted_flag IS NULL
         AND utilization_type IN ('UTILIZED','ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
         GROUP BY order_line_id,object_type,object_id)
         ORDER BY gl_date;

     CURSOR  c_order_line_info(p_order_line_id IN NUMBER)  IS
        SELECT DECODE(line.line_category_code,'ORDER',line.ordered_quantity,
                                                                            'RETURN', -line.ordered_quantity) ordered_quantity,
             DECODE(line.line_category_code,'ORDER',NVL(line.shipped_quantity,line.ordered_quantity),
                                                                            'RETURN', line.invoiced_quantity,
                                                                            line.ordered_quantity) shipped_quantity,
             line.invoiced_quantity,
             line.unit_list_price,
             line.line_id,
             line.actual_shipment_date,
             line.fulfillment_date,  -- invoiced date ?????
             line.inventory_item_id,
             header.transactional_curr_code
        FROM oe_order_lines_all line, oe_order_headers_all header
        WHERE line.line_id = p_order_line_id
          AND line.header_id = header.header_id;


     CURSOR  c_resale_line_info(p_resale_line_id IN NUMBER, p_adj_id IN NUMBER)  IS
   /*     SELECT quantity ordered_quantity ,
             quantity shipped_quantity,
             quantity invoiced_quantity,
             purchase_price unit_list_price,
             resale_line_id line_id,
             NVL(date_shipped, date_ordered) actual_shipment_date,
             NVL(date_shipped, date_ordered) fulfillment_date,  -- invoiced date ?????
             inventory_item_id,
             currency_code --dummy column
        FROM OZF_RESALE_LINES_ALL
        WHERE resale_line_id = p_resale_line_id;
*/
        ----- fix bug 5671169
        SELECT line.quantity ordered_quantity ,
             line.quantity shipped_quantity,
             line.quantity invoiced_quantity,
             adj.priced_unit_price unit_list_price,
             line.resale_line_id line_id,
             NVL(line.date_shipped, line.date_ordered) actual_shipment_date,
             NVL(line.date_shipped, line.date_ordered) fulfillment_date,  -- invoiced date ?????
             line.inventory_item_id,
             line.currency_code --dummy column
        FROM OZF_RESALE_LINES_ALL line,ozf_resale_adjustments_all adj
        WHERE line.resale_line_id = p_resale_line_id
        AND adj.resale_adjustment_id = p_adj_id
        AND line.resale_line_id = adj.resale_line_id;


     CURSOR  c_prior_tiers(p_parent_discount_id  IN NUMBER, p_volume IN NUMBER ) IS
       SELECT  offer_discount_line_id ,volume_from ,volume_to, discount
         FROM  ozf_offer_discount_lines
         WHERE   parent_discount_line_id = p_parent_discount_id
         AND   p_volume >= volume_from
         ORDER BY volume_from  DESC;


     CURSOR c_discount_header(p_discount_line_id IN NUMBER) IS
         SELECT discount_type,volume_type
          FROM ozf_offer_discount_lines
          WHERE offer_discount_line_id = p_discount_line_id
          AND tier_type = 'PBH';

     CURSOR c_get_group(p_order_line_id IN NUMBER,p_list_header_id IN NUMBER) IS
       SELECT group_no,pbh_line_id,include_volume_flag
        FROM ozf_order_group_prod
        WHERE order_line_id = p_order_line_id
        AND qp_list_header_id = p_list_header_id;

     CURSOR c_market_option(p_list_header_id IN NUMBER, p_group_id IN NUMBER) IS
       SELECT opt.retroactive_flag
        FROM ozf_offr_market_options opt
        WHERE opt.GROUP_NUMBER= p_group_id
        AND opt.qp_list_header_id = p_list_header_id;

--fix for bug 5975203
     CURSOR c_current_discount(p_volume IN NUMBER, p_parent_discount_id IN NUMBER) IS
         SELECT discount
        FROM ozf_offer_discount_lines
        WHERE p_volume > volume_from
             AND p_volume <= volume_to
         AND parent_discount_line_id = p_parent_discount_id;

/*    CURSOR c_max_volume(p_order_line_id IN NUMBER, p_qp_list_header_id IN NUMBER,p_source_code IN VARCHAR2) IS
       SELECT summ.individual_volume
       FROM ozf_volume_detail det,ozf_volume_summary summ
       WHERE det.order_line_id = p_order_line_id
       AND det.qp_list_header_id = p_qp_list_header_id
       AND det.volume_track_type = summ.individual_type
       AND det.qp_list_header_id = summ.qp_list_header_id
       AND det.source_code = p_source_code;
*/
     CURSOR c_preset_tier(p_pbh_line_id IN NUMBER, p_qp_list_header_id IN NUMBER,p_group_id IN NUMBER) IS
       SELECT a.discount
       FROM   ozf_offer_discount_lines a, ozf_market_preset_tiers b, ozf_offr_market_options c
       WHERE  a.offer_discount_line_id = b.dis_offer_discount_id
       AND    b.pbh_offer_discount_id = p_pbh_line_id
       AND    b.offer_market_option_id = c.offer_market_option_id
       AND    c.qp_list_header_id = p_qp_list_header_id
       AND    c.group_number = p_group_id;

    CURSOR c_sales_accrual(p_list_header_id  IN NUMBER) IS
       SELECT 'X' from ozf_funds_all_b
       WHERE plan_id= p_list_header_id
       AND accrual_basis = 'SALES'
       UNION
       SELECT 'X' from ozf_funds_all_b
       WHERE plan_id = p_list_header_id
       AND accrual_basis = 'CUSTOMER'
       AND liability_flag = 'N';

    CURSOR c_unit_discount(p_order_line_id  IN NUMBER, p_price_adjust_id NUMBER) IS
       SELECT SUM(adjusted_amount_per_pqty)
       FROM oe_price_adjustments
       WHERE line_id = p_order_line_id
       AND accrual_flag = 'N'
       AND applied_flag = 'Y'
       AND list_line_type_code IN ('DIS', 'SUR', 'PBH', 'FREIGHT_CHARGE')
       and pricing_group_sequence <
       (SELECT pricing_group_sequence FROM oe_price_adjustments
         WHERE price_Adjustment_id = p_price_adjust_id) ;

    CURSOR c_discount(p_order_line_id  IN NUMBER, p_price_adjust_id NUMBER) IS
       SELECT SUM(adjusted_amount_per_pqty)
       FROM oe_price_adjustments
       WHERE line_id = p_order_line_id
       AND accrual_flag = 'N'
       AND applied_flag = 'Y'
       AND list_line_type_code IN ('DIS', 'SUR', 'PBH', 'FREIGHT_CHARGE');

    CURSOR  c_get_tier_limits (p_parent_discount_id IN NUMBER) IS
       SELECT MIN(volume_from),MAX(volume_to)
       FROM ozf_offer_discount_lines
       WHERE parent_discount_line_id = p_parent_discount_id;

     CURSOR  c_get_max_tier (p_max_volume_to IN NUMBER,p_parent_discount_id IN NUMBER)    IS
        SELECT  discount
        FROM ozf_offer_discount_lines
        WHERE volume_to =p_max_volume_to
        AND parent_discount_line_id = p_parent_discount_id;

     CURSOR c_offer_curr IS
      SELECT nvl(transaction_currency_code,fund_request_curr_code),
             transaction_currency_code,
             offer_id
        FROM ozf_offers
       WHERE qp_list_header_id = p_qp_list_header_id;

     --22-FEB-2007 kdass bug 5759350 - changed datatype of p_product_id from NUMBER to VARCHAR2 based on Feng's suggestion
     --fix for bug 5979971
   CURSOR c_apply_discount(p_offer_id IN NUMBER,p_line_id IN NUMBER) IS
        SELECT NVL(apply_discount_flag,'N')
        FROM ozf_order_group_prod
        WHERE offer_id = p_offer_id
          AND order_line_id = p_line_id;


     l_api_name                CONSTANT VARCHAR2(30)   := 'volume_offer_adjustment';
     l_full_name               VARCHAR2(70):= g_pkg_name ||'.'||l_api_name ||' : ';
     l_api_version             CONSTANT NUMBER                 := 1.0;
     l_return_status           VARCHAR2 (20) :=  fnd_api.g_ret_sts_success;
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2 (2000)        := NULL;
     l_volume_offer_tier_id    NUMBER;
     l_current_offer_tier_id   NUMBER;
     l_order_amount            NUMBER;
     l_old_discount            NUMBER;
     l_new_discount            NUMBER;--
     l_new_operator            VARCHAR2(30);
     l_old_operator            VARCHAR2(30);
     y1                        NUMBER; -- Initial Adjsutment
     l_current_max_tier        NUMBER;
     l_current_min_tier        NUMBER;
     l_act_util_rec            ozf_actbudgets_pvt.act_util_rec_type    ;
     l_adj_amount              NUMBER;
     l_volume_type             VARCHAR2(30);
     l_current_tier_value      NUMBER;
     l_total                   NUMBER;
     l_value                   NUMBER;
     l_previous_tier_max       NUMBER;
     l_new_utilization         NUMBER;
     l_total_order             NUMBER;
     l_total_amount            NUMBER;
     l_returned_flag           BOOLEAN := false;
     l_qp_list_header_id       NUMBER := p_qp_list_header_id;
     l_retroactive             VARCHAR2(1) ;
     l_trx_date                DATE;
     l_volume                  NUMBER;
     l_group_id                NUMBER;
     l_pbh_line_id             NUMBER;
     l_discount_type           VARCHAR2(30);
     l_source_code             VARCHAR2(30);
     l_preset_tier             NUMBER;
     l_order_line_info         c_order_line_info%ROWTYPE;
     l_order_line_id           NUMBER;
     l_order_type              VARCHAR2(30);
     l_sales_accrual_flag      VARCHAR2 (3);
     l_volume_offer_type       VARCHAR2(30) := p_vol_off_type;
     l_selling_price           NUMBER;
     l_unit_discount           NUMBER;
     l_min_tier                NUMBER;
     l_max_tier                NUMBER;
     l_offer_curr              VARCHAR2(30);
     l_conv_price              NUMBER;
     l_rate                    NUMBER;
     l_included_vol_flag       VARCHAR2(1);
     l_amountTbl               amountTbl ;
     l_glDateTbl               glDateTbl ;
     l_objectTypeTbl           objectTypeTbl ;
     l_objectIdTbl             objectIdTbl;
     l_priceAdjustmentIDTbl    priceAdjustmentIDTbl ;
     l_glPostedFlagTbl         glPostedFlagTbl;
     l_orderLineIdTbl          orderLineIdTbl;


     l_offer_id                NUMBER;
     l_apply_discount          VARCHAR2(1) ;
     l_transaction_currency_code  VARCHAR2(30);

     -- julou bug 6348078. cursor to get transaction_date for IDSM line.
     CURSOR c_trx_date(p_line_id NUMBER) IS
     SELECT transaction_date
     FROM   ozf_sales_transactions
     WHERE  source_code = 'IS'
     AND    line_id = p_line_id;

     --Added for bug 7030415
     l_utilizationIdTbl        utilizationIdTbl;
     CURSOR c_utilization_details(l_utilization_id IN NUMBER) IS
        SELECT exchange_rate_type, org_id
        FROM ozf_funds_utilized_all_b
        WHERE utilization_id=l_utilization_id;

     l_conv_type       ozf_funds_utilized_all_b.exchange_rate_type%TYPE;
     l_org_id          NUMBER;



   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(' /*************************** DEBUG MESSAGE START *************************/' || l_api_name);
      END IF;
         write_conc_log(' /*************************** DEBUG MESSAGE START *************************/' || l_api_name);

      SAVEPOINT volume_offer_adjustment;

      IF g_offer_id_tbl.FIRST IS NOT NULL THEN
         FOR i IN g_offer_id_tbl.FIRST .. g_offer_id_tbl.LAST
         LOOP
            IF g_offer_id_tbl(i) = l_qp_list_header_id THEN
               write_conc_log (' no adjustment for offer: ' || l_qp_list_header_id);
               GOTO l_endoffloop;
            END IF;
         END LOOP;
      END IF;

      OPEN c_sales_accrual(l_qp_list_header_id);
      FETCH c_sales_accrual INTO l_sales_accrual_flag;
      CLOSE c_sales_accrual;

      IF l_sales_accrual_flag is NOT NULL THEN
         l_order_type := 'SHIPPED'; --'BOOKED'; -- set to shipped for sales accrual untill decision has been made.
      ELSIF g_order_gl_phase ='SHIPPED' AND l_volume_offer_type = 'ACCRUAL' THEN
         l_order_type := 'SHIPPED';
      ELSIF g_order_gl_phase ='INVOICED' AND l_volume_offer_type = 'ACCRUAL' THEN
         l_order_type := 'INVOICED';
      ELSIF  l_volume_offer_type = 'OFF_INVOICE' THEN
         l_order_type := 'INVOICED';
      END IF;

           l_total_order := 0;  -- total ordered amount for offer.
           l_total_amount := 0; --- total utilization amount for offer.

           OPEN c_old_price_adj(l_qp_list_header_id);
           --FOR l_old_price_adj IN c_old_price_adj(l_qp_list_header_id)
           LOOP
             FETCH c_old_price_adj BULK COLLECT INTO l_amountTbl, l_orderLineIdTbl
                                                       , l_priceAdjustmentIDTbl, l_glDateTbl
                                                       , l_objectTypeTbl, l_objectIdTbl, l_glPostedFlagTbl, l_utilizationIdTbl --Added for bug 7030415
                                                       LIMIT g_bulk_limit;
               FOR i IN NVL(l_priceAdjustmentIDTbl.FIRST, 1) .. NVL(l_priceAdjustmentIDTbl.LAST, 0) LOOP
                  IF l_objectTypeTbl(i) ='ORDER' THEN
                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message(' order_line_id:  '|| l_orderLineIdTbl(i) );
                     END IF;
                     write_conc_log(' order_line_id:  '|| l_orderLineIdTbl(i) );

                     l_source_code := 'OM';
                     l_order_line_id := l_orderLineIdTbl(i);
                     OPEN c_order_line_info(l_order_line_id);
                     FETCH c_order_line_info INTO l_order_line_info;
                     CLOSE c_order_line_info;

                     IF l_priceAdjustmentIDTbl(i) = -1 THEN
                        OPEN c_discount(l_order_line_id,l_priceAdjustmentIDTbl(i));
                        FETCH c_discount INTO l_unit_discount;
                        CLOSE c_discount;
                     ELSE
                        OPEN c_unit_discount(l_order_line_id,l_priceAdjustmentIDTbl(i));
                        FETCH c_unit_discount INTO l_unit_discount;
                        CLOSE c_unit_discount;
                     END IF;

                     write_conc_log(' l_unit_discount:  '|| l_unit_discount);

                  ELSE
                     IF G_DEBUG THEN
                       ozf_utility_pvt.debug_message(' resale_line_id:  '|| l_objectIdTbl(i) );
                     END IF;
                     write_conc_log(' resale_line_id:  '|| l_objectIdTbl(i));

                     l_source_code := 'IS';
                     l_order_line_id := l_objectIdTbl(i);
                     OPEN c_resale_line_info(l_order_line_id,l_priceAdjustmentIDTbl(i));
                     FETCH c_resale_line_info INTO l_order_line_info;
                     CLOSE c_resale_line_info;
                  END IF;

                  l_selling_price := l_order_line_info.unit_list_price + NVL(l_unit_discount,0); -- discount is negative
                  write_conc_log(' l_selling_price:  '|| l_selling_price);

                  OPEN c_offer_curr;
                  FETCH c_offer_curr INTO l_offer_curr, l_transaction_currency_code, l_offer_id;
                  CLOSE c_offer_curr;

                  IF l_amountTbl(i) = 0 THEN -- fix bug 5689866
                     --21-MAY-07 kdass fixed bug 6059036 - added condition for direct and indirect orders
                     IF l_objectTypeTbl(i) ='ORDER' THEN
                        OPEN c_apply_discount(l_offer_id, l_orderLineIdTbl(i));
                        FETCH c_apply_discount INTO l_apply_discount;
                        CLOSE c_apply_discount;
                     ELSE
                        OPEN c_apply_discount(l_offer_id, l_objectIdTbl(i));
                        FETCH c_apply_discount INTO l_apply_discount;
                        CLOSE c_apply_discount;
                     END IF;

                     write_conc_log('l_apply_discount:  ' || l_apply_discount);

                     IF l_apply_discount ='N' THEN
                       IF G_DEBUG THEN
                          ozf_utility_pvt.debug_message('not apply discount:  ' || l_order_line_info.inventory_item_id);
                       END IF;
                       write_conc_log(' not apply discount:'|| l_order_line_info.inventory_item_id);
                       GOTO l_endoffloop;
                     END IF;
                  END IF; -- bug  5689866

                    --Added for bug 7030415
                     OPEN c_utilization_details(l_utilizationIdTbl(i));
                     FETCH c_utilization_details INTO l_conv_type,l_org_id;
                     CLOSE c_utilization_details;

                     l_act_util_rec.org_id := l_org_id;

          --12.2, multi-currency enhancement.
          IF l_transaction_currency_code IS NOT NULL
          AND l_transaction_currency_code <> l_order_line_info.transactional_curr_code THEN

             ozf_utility_pvt.write_conc_log('order curr: ' || l_order_line_info.transactional_curr_code);
             ozf_utility_pvt.write_conc_log('offer curr: ' || l_transaction_currency_code);
             ozf_utility_pvt.write_conc_log('selling price: ' || l_selling_price);



                     ozf_utility_pvt.write_conc_log('l_conv_type: ' || l_conv_type);


             ozf_utility_pvt.convert_currency (x_return_status => l_return_status
                                              ,p_conv_type     => l_conv_type --7030415
                                              ,p_conv_date     => OZF_ACCRUAL_ENGINE.G_FAE_START_DATE
                                              --l_order_line_info.actual_shipment_date
                                              ,p_from_currency => l_order_line_info.transactional_curr_code
                                              ,p_to_currency   => l_transaction_currency_code
                                              ,p_from_amount   => l_selling_price
                                              ,x_to_amount     => l_conv_price
                                              ,x_rate          => l_rate
                                              );

                     IF l_return_status = fnd_api.g_ret_sts_error THEN
                        RAISE fnd_api.g_exc_error;
                     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                     END IF;

                     l_selling_price := l_conv_price;
                     write_conc_log ('selling price after currency conversion: ' || l_selling_price);

                  END IF;

/*                  IF g_order_gl_phase = 'SHIPPED' THEN
                     l_trx_date :=  l_order_line_info.actual_shipment_date;
                  ELSE
                     l_trx_date :=  l_order_line_info.fulfillment_date;
                  END IF;
*/
              -- for testing
/*              IF l_volume = 0 THEN

                 l_volume := get_order_amount_quantity( l_qp_list_header_id ,
                           l_order_amount,
                           l_new_discount,
                           l_new_operator,
                           l_old_discount,  -- discount in QP.
                           l_old_operator,
                           l_volume_type,
                           l_return_status
                           );
              write_conc_log(' l_volume from test:  '|| l_volume );

              END IF;
*/

                  OPEN c_get_group(l_order_line_id,l_qp_list_header_id);
                  FETCH c_get_group INTO l_group_id,l_pbh_line_id,l_included_vol_flag;
                  CLOSE c_get_group;

                  IF G_DEBUG THEN
                    ozf_utility_pvt.debug_message(' l_group_id:  '|| l_group_id );
                    ozf_utility_pvt.debug_message(' l_pbh_line_id:  '|| l_pbh_line_id );
                    ozf_utility_pvt.debug_message(' l_included_vol_flag:  '|| l_included_vol_flag );
                  END IF;
                  write_conc_log(' l_group_id:  '|| l_group_id );
                  write_conc_log(' l_pbh_line_id:  '|| l_pbh_line_id );
                  write_conc_log(' l_included_vol_flag:  '|| l_included_vol_flag );

                  IF l_group_id is NULL OR l_pbh_line_id is NULL THEN
                     GOTO l_endoffloop;
                  END IF;

                  OPEN c_market_option(l_qp_list_header_id,l_group_id);
                  FETCH c_market_option INTO l_retroactive;
                  CLOSE c_market_option;

                  OPEN c_discount_header(l_pbh_line_id);
                  FETCH c_discount_header INTO l_discount_type,l_volume_type;
                  CLOSE c_discount_header;

/*                  IF l_retroactive = 'Y' THEN -- for retroactive, always takes the max volume.
                     OPEN c_max_volume(l_order_line_id,l_qp_list_header_id,l_source_code);
                     FETCH c_max_volume INTO l_volume;
                     CLOSE c_max_volume;-- not work for non-include volume product since query return null. 12/11/06 by feliu
                  ELSE
  */

                  IF l_retroactive = 'Y' THEN
                     ozf_volume_calculation_pub.get_volume
                                         (p_init_msg_list =>fnd_api.g_false
                                          ,p_api_version =>1.0
                                          ,p_commit  =>fnd_api.g_false
                                          ,x_return_status =>l_return_status
                                          ,x_msg_count => l_msg_count
                                          ,x_msg_data  => l_msg_data
                                          ,p_qp_list_header_id => l_qp_list_header_id
                                          ,p_order_line_id =>l_order_line_id
                                          ,p_trx_date   =>sysdate+1
                                          ,p_source_code => l_source_code
                                          ,x_acc_volume => l_volume
                                          );
                  ELSE
                    -- julou bug 6348078. can't use gl_date for IDSM line. it's different from transaction_date
                    IF l_source_code = 'IS' THEN
                      write_conc_log('calculating transaction_date for non-retro offer, IS line_id: ' || l_order_line_id);
                      OPEN  c_trx_date(l_order_line_id);
                      FETCH c_trx_date INTO l_trx_date;
                      CLOSE c_trx_date;
                    ELSE
                      l_trx_date := l_glDateTbl(i);
                    END IF;
                    write_conc_log('transaction_date after conversion: ' || TO_CHAR(l_trx_date, 'YYYY-MM-DD HH:MI:SS'));
                     ozf_volume_calculation_pub.get_volume
                                         (p_init_msg_list =>fnd_api.g_false
                                          ,p_api_version =>1.0
                                          ,p_commit  =>fnd_api.g_false
                                          ,x_return_status =>l_return_status
                                          ,x_msg_count => l_msg_count
                                          ,x_msg_data  => l_msg_data
                                          ,p_qp_list_header_id => l_qp_list_header_id
                                          ,p_order_line_id =>l_order_line_id
                                          --,p_trx_date   =>l_glDateTbl(i)
                                          ,p_trx_date   => l_trx_date
                                          ,p_source_code => l_source_code
                                          ,x_acc_volume => l_volume
                                          );
                  END IF;

                  IF l_return_status = fnd_api.g_ret_sts_error THEN
                    RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
    --              END IF; --l_retroactive = 'Y'

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message(' l_volume:  '|| l_volume );
                  END IF;
                  write_conc_log(' l_volume:  '|| l_volume );

                 -- l_new_discount := 0;
                  OPEN c_current_discount(l_volume,l_pbh_line_id);
                  FETCH c_current_discount INTO l_new_discount;
                  CLOSE c_current_discount;

                  -- fix bug 5055425 by feliu on 02/23/2006
                  IF l_new_discount  is NULL THEN
                     OPEN c_get_tier_limits(l_pbh_line_id);
                     FETCH c_get_tier_limits INTO l_min_tier,l_max_tier;
                     CLOSE c_get_tier_limits;
                     IF l_volume < l_min_tier THEN
                        l_new_discount := 0;
                     ELSE
                        OPEN c_get_max_tier(l_max_tier,l_pbh_line_id);
                        FETCH c_get_max_tier INTO l_new_discount;
                        CLOSE c_get_max_tier;
                     END IF;
                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message(' l_new_discount:  '|| l_new_discount );
                     END IF;
                     write_conc_log(' l_new_discount:  '|| l_new_discount );
                  END IF;

                  l_preset_tier := NULL;
                  OPEN c_preset_tier(l_pbh_line_id,l_qp_list_header_id,l_group_id);
                  FETCH c_preset_tier INTO l_preset_tier;
                  CLOSE c_preset_tier;

                   write_conc_log( ' l_preset_tier=' || l_preset_tier);
                   write_conc_log( ' l_new_discount=' || l_new_discount);


                  IF l_preset_tier is NOT NULL AND l_preset_tier > l_new_discount THEN
                  l_new_discount := l_preset_tier;
                    IF G_DEBUG THEN
                       ozf_utility_pvt.debug_message('not reach preset tier:  ');
                    END IF;
                    write_conc_log(' not reach preset tier:');
                  END IF;

                  l_new_utilization := 0;
                  l_value :=0;
                  l_adj_amount := 0;

                  IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN -- volume type = AMOUNT
                     IF l_order_type = 'SHIPPED' THEN
                        l_value := l_order_line_info.shipped_quantity * l_selling_price ;
                     ELSIF  l_order_type = 'INVOICED' THEN
                        l_value := l_order_line_info.invoiced_quantity * l_selling_price ;
                     ELSE
                        l_value := l_order_line_info.ordered_quantity * l_selling_price ;
                     END IF;
                  ELSE
                     IF l_order_type = 'SHIPPED' THEN
                        l_value := l_order_line_info.shipped_quantity ;
                     ELSIF  l_order_type = 'INVOICED' THEN
                        l_value := l_order_line_info.invoiced_quantity ;
                     ELSE
                        l_value := l_order_line_info.ordered_quantity ;
                     END IF;
                  END IF;

                  --For retroactive volume offer.need to make adjustment for all of orders in this offer.
                  IF l_retroactive = 'Y' THEN
                     IF l_discount_type = '%' THEN
                        IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                           l_new_utilization := l_value* l_new_discount / 100;
                        ELSE -- % is for unit price. need to multiple when range in quantity.
                           l_new_utilization := l_value*  l_selling_price * l_new_discount / 100;
                        END IF;
                     ELSIF l_discount_type = 'AMT' THEN
                        IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                           -- amt is for unit pirce. need to divide when range in amount.
                           -- Fix for bug 9318975 - when l_selling price is zero, need not divide by selling price
                           IF l_selling_price <> 0 THEN
                           l_new_utilization :=l_value / l_selling_price * l_new_discount ;
                                write_conc_log ('l_selling_price <> 0, l_new_utilization1 = '||l_new_utilization);
                           ELSE
                                l_new_utilization := l_value;
                                write_conc_log ('l_selling_price = 0, l_new_utilization1 = '||l_new_utilization);
                           END IF;
                        ELSE
                           l_new_utilization :=l_value  * l_new_discount ;
                        END IF;
                     END IF;

                     l_adj_amount := l_new_utilization - l_amountTbl(i);

                     IF G_DEBUG THEN
                         ozf_utility_pvt.debug_message(l_full_name ||' retroactive flag is Y. ' || ' l_volume_type=' || l_volume_type
                                     || ' l_new_discount='  || l_new_discount
                                     || ' l_new_utilization='  || l_new_utilization
                                     || ' l_amountTbl=' || l_amountTbl(i)
                                     || ' l_adj_amount='  || l_adj_amount);
                     END IF;
                     write_conc_log(l_full_name ||' retroactive flag is Y. ' || ' l_volume_type=' || l_volume_type
                                     || ' l_new_discount='  || l_new_discount
                                     || ' l_new_utilization='  || l_new_utilization
                                     || ' l_amountTbl=' || l_amountTbl(i)
                                     || ' l_adj_amount='  || l_adj_amount);

                  END IF;  --l_retroactive

                  --For non-retroactive volume offer.
                   -- adjusment need to be make for all of orders when considering returned order.
                  IF NVL(l_retroactive, 'N') = 'N' THEN
                     IF l_included_vol_flag = 'Y' THEN
                        l_previous_tier_max := l_volume;
                     ELSE
                        /*
                          logic here is to add current order line's volume to offer's volume for adjustment.
                          eg:  offer's volume=2.
                               order line's volume = 5, then total volume = 7.
                        */
                        l_previous_tier_max := l_volume + l_value;
                     END IF;

/*
                     1-10    1
                     10-20   2
                     20-30   3

                     l_volume = 25
                     l_value = 10

                     1st loop: l_previous_tier_max = 25,   y1= 5  l_value = 5   l_new_utilization = 5 * 3 = 15   l_previous_tier_max = 20
                     2st loop: l_previous_tier_max = 20,   y1= 5  l_value = 0   l_new_utilization = 5 * 2 = 10   l_previous_tier_max  = 10
                     by feliu on 12/14/06. pre_qualify tier is only for retroactive. not for non-retroactive.
*/
                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message( ' l_value=' || l_value);
                     END IF;

                     --fix for bug 6021538
                       IF l_max_tier IS NULL THEN
                          OPEN c_get_tier_limits(l_pbh_line_id);
                          FETCH c_get_tier_limits INTO l_min_tier,l_max_tier;
                          CLOSE c_get_tier_limits;
                       END IF;

                       write_conc_log( ' l_value=' || l_value);
                      write_conc_log( ' l_volume=' || l_volume);
                       write_conc_log( ' l_max_tier=' || l_max_tier);


                       IF l_volume > l_max_tier THEN
                          l_value:= l_max_tier -l_volume + l_value;
                          IF l_value<0 THEN
                             l_value:=0;
                          END IF;
                        END IF;

                     --end bug 6021538
                      l_preset_tier := NULL;
                     OPEN  c_prior_tiers(l_pbh_line_id, l_volume);
                     LOOP
                       FETCH c_prior_tiers INTO l_current_offer_tier_id,l_current_min_tier,l_current_max_tier,l_current_tier_value;
                       EXIT WHEN c_prior_tiers%NOTFOUND;

                       write_conc_log( ' l_current_offer_tier_id=' || l_current_offer_tier_id);

                          -- handle over tier cap. not applicable for R12.
                 /*      IF l_current_max_tier < l_previous_tier_max THEN
                          l_previous_tier_max := l_current_max_tier;
                       END IF;
                 */

                        OPEN c_preset_tier(l_pbh_line_id,l_qp_list_header_id,l_group_id);
                        FETCH c_preset_tier INTO l_preset_tier;
                        CLOSE c_preset_tier;

                   write_conc_log( ' l_preset_tier=' || l_preset_tier);
                   write_conc_log( ' l_current_tier_value=' || l_current_tier_value);


                  IF l_preset_tier is NOT NULL AND l_preset_tier > l_current_tier_value THEN
                  l_current_tier_value := l_preset_tier;
                    IF G_DEBUG THEN
                       ozf_utility_pvt.debug_message('not reach preset tier:  ');
                    END IF;
                    write_conc_log(' not reach preset tier:');
                  END IF;

                        -- logic here is:
                        -- start from top tier, calculate amount in each tier, until order amount has been calculated.
                      -- y1 := LEAST((l_previous_tier_max-l_current_min_tier + 1),l_value) ;
                       y1 := LEAST((l_previous_tier_max-l_current_min_tier),l_value) ;
                       l_value := l_value - y1;
                       IF l_discount_type = '%' THEN
                          IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                             l_new_utilization := l_new_utilization +  y1* l_current_tier_value / 100;
                          ELSE
                             l_new_utilization := l_new_utilization +  y1*  l_selling_price * l_current_tier_value / 100;
                          END IF;
                       ELSIF l_discount_type = 'AMT' THEN
                          IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                          -- Fix for bug 9318975 - when l_selling price is zero, need not divide by selling price
                            IF l_selling_price <> 0 THEN
                              l_new_utilization := l_new_utilization + y1 / l_selling_price * l_current_tier_value ;
                              write_conc_log ('l_selling_price <> 0, l_new_utilization3 = '||l_new_utilization);
                            ELSE
                                l_new_utilization :=l_new_utilization + y1;
                                write_conc_log ('l_selling_price = 0, l_new_utilization3 = '||l_new_utilization);
                            END IF;
                          ELSE
                              l_new_utilization := l_new_utilization + y1* l_current_tier_value ;
                          END IF;
                       END IF;

                       --l_previous_tier_max := l_current_min_tier - 1 ;
                       l_previous_tier_max := l_current_min_tier;

                       IF G_DEBUG THEN
                          ozf_utility_pvt.debug_message(' retroactive flag is N, computing for prior tier id=' || l_current_offer_tier_id
                                      || ' y1='  || y1 || '     tier_min=' || l_current_min_tier
                                      || '     tier_max=' || l_current_max_tier || ' l_previous_tier_max: ' || l_previous_tier_max
                                      || '  l_new_utilization: ' || l_new_utilization);
                       END IF;
                          write_conc_log(' retroactive flag is N, computing for prior tier id=' || l_current_offer_tier_id
                                      || ' y1='  || y1 || '     tier_min=' || l_current_min_tier
                                      || '     tier_max=' || l_current_max_tier || ' l_previous_tier_max: ' || l_previous_tier_max
                                      || '  l_new_utilization: ' || l_new_utilization);

                       EXIT WHEN l_value <= 0;

                     END LOOP;  -- end of loop for c_prior_tiers
                     CLOSE c_prior_tiers;
                    -- For R12,  returned order for different customers. ????????
                      --For returned order,  create positive record for return line, then
                      -- make adjustment based on the difference of total utilization for previous orders.
                     IF l_returned_flag = true THEN
                        l_total_amount :=   l_total_amount + l_amountTbl(i) ;
                        l_adj_amount := l_new_utilization - l_total_amount;
                     ELSE  -- for non-returned order, make adjustment based on difference of total utilization for specified price adjustment id.
                        l_adj_amount := l_new_utilization - l_amountTbl(i);
                        l_total_amount :=   l_total_amount + l_amountTbl(i) + l_adj_amount;
                     END IF;

                  END IF;  -- end of non-retroactive adjustment.

                  l_act_util_rec.price_Adjustment_id     := l_priceAdjustmentIDTbl(i);
                  l_act_util_rec.order_line_id  := l_orderLineIdTbl(i);
                  l_act_util_rec.gl_posted_flag := l_glPostedFlagTbl(i);
                  l_act_util_rec.object_type := l_objectTypeTbl(i);
                  --nirprasa, 12.2 assign the currencies.
                  IF l_transaction_currency_code IS NULL THEN
                     l_act_util_rec.plan_currency_code := l_order_line_info.transactional_curr_code;
                  ELSE
                     l_act_util_rec.plan_currency_code := l_offer_curr;
                  END IF;
                  l_act_util_rec.fund_request_currency_code := l_offer_curr;
                  l_act_util_rec.exchange_rate_date := OZF_ACCRUAL_ENGINE.G_FAE_START_DATE;
                  --nirprasa, 12.2 end assign the currencies.

                  IF NVL(l_adj_amount,0) <> 0 THEN
                     process_accrual (
                       p_earned_amt          =>l_adj_amount,
                       p_qp_list_header_id   =>l_qp_list_header_id,
                       p_act_util_rec        =>l_act_util_rec,
                       x_return_status       =>l_return_status,
                       x_msg_count           =>l_msg_count,
                       x_msg_data            =>l_msg_data );

                     IF l_return_status = fnd_api.g_ret_sts_error THEN
                       RAISE fnd_api.g_exc_error;
                     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                       RAISE fnd_api.g_exc_unexpected_error;
                     END IF;
                  END IF;

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message(
                         l_full_name ||' Process Accrual Msg count '||l_msg_count||' Msg data'||l_msg_data||' Return status'||l_return_status
                      );
                  END IF;
                  write_conc_log(
                     l_full_name ||' Process Accrual Msg count '||l_msg_count||' Msg data'||l_msg_data||' Return status'||l_return_status
                  );

                  <<l_endoffloop>>
                  NULL;
               END LOOP; -- loop for For
               EXIT WHEN c_old_price_adj%NOTFOUND;
           END LOOP; -- end price adj loop
           CLOSE c_old_price_adj;

           IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           <<l_endoffloop>>
           NULL;

           IF G_DEBUG THEN
             ozf_utility_pvt.debug_message(' /*************************** DEBUG MESSAGE END *************************/' || l_api_name );
           END IF;
           write_conc_log(' /*************************** DEBUG MESSAGE END *************************/' || l_api_name );

           fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);

           x_return_status := l_return_status;

        EXCEPTION
           WHEN fnd_api.g_exc_error THEN
               ROLLBACK TO volume_offer_adjustment;
               x_return_status            := fnd_api.g_ret_sts_error;
               fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
           WHEN fnd_api.g_exc_unexpected_error THEN
               ROLLBACK TO volume_offer_adjustment;
               x_return_status            := fnd_api.g_ret_sts_unexp_error;
               fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
           WHEN OTHERS THEN
               ROLLBACK TO volume_offer_adjustment;
               x_return_status            := fnd_api.g_ret_sts_unexp_error;
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                  fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
               END IF;
               fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);

   END volume_offer_adjustment;


---------------------------------------------------------------------
-- PROCEDURE
--    volume_offer_util_adjustment
-- PURPOSE
--    adjustment of utilization amount  for backdated adjustments and split orders.
-- HISTORY
-- 2/16/2007  nirprasa Created for bug 6021635
----------------------------------------------------------------------


PROCEDURE   volume_offer_util_adjustment(
                        p_qp_list_header_id   IN NUMBER,
                        x_return_status       OUT NOCOPY      VARCHAR2,
                        x_msg_count             OUT NOCOPY    NUMBER,
                        x_msg_data              OUT NOCOPY    VARCHAR2
   ) IS

  CURSOR  c_old_price_Adj(p_list_header_id IN NUMBER)  IS
       SELECT  sum(plan_curr_amount)  old_Adj_amt
            , order_line_id
            ,min(price_adjustment_id) price_adjustment_id
             ,object_type
             ,object_id
             ,min(gl_date) gl_date
             ,min(utilization_id) utilization_id
        FROM ozf_funds_utilized_all_b
        WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
         GROUP BY order_line_id,object_type,object_id
         ORDER BY gl_date;





   /* CURSOR  c_order_line_qty(p_order_line_id IN NUMBER)  IS
        SELECT DECODE(line.line_category_code,'ORDER',line.ordered_quantity,
        'RETURN', -line.ordered_quantity) ordered_quantity
        FROM oe_order_lines_all line
        WHERE line.line_id = p_order_line_id;*/


         /* CURSOR c_all_orders (p_list_header_id IN NUMBER)  IS
          select sum(ordered_quantity)
          FROM (
         select sum(ordered_quantity) ordered_quantity from oe_order_lines_all
         where line_id IN
          (SELECT order_line_id FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
          )
          UNION
         select sum(quantity) ordered_quantity from OZF_RESALE_LINES_INT_ALL
         where resale_batch_id IN
          (SELECT reference_id FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
          )
          );*/


          CURSOR c_all_orders (p_list_header_id IN NUMBER)  IS
          select sum(ordered_quantity)
          FROM (
           SELECT SUM(DECODE(line_category_code,'ORDER',ordered_quantity,
                                                                            'RETURN', -ordered_quantity)) ordered_quantity
           from oe_order_lines_all oe,
           (SELECT distinct order_line_id FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
          ) orders
          where   oe.line_id = orders.order_line_id
          UNION
         select sum(quantity) ordered_quantity from OZF_RESALE_LINES_INT_ALL ol ,
          (SELECT distinct reference_id FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
          ) orders
          where ol.resale_batch_id = orders.reference_id

          );


     CURSOR c_discount_header(p_discount_line_id IN NUMBER) IS
         SELECT discount_type,volume_type
          FROM ozf_offer_discount_lines
          WHERE offer_discount_line_id = p_discount_line_id
          AND tier_type = 'PBH';

     CURSOR c_get_group(p_order_line_id IN NUMBER,p_list_header_id IN NUMBER) IS
       SELECT group_no,pbh_line_id,include_volume_flag
        FROM ozf_order_group_prod
        WHERE order_line_id = p_order_line_id
        AND qp_list_header_id = p_list_header_id;

     CURSOR c_market_option(p_list_header_id IN NUMBER, p_group_id IN NUMBER) IS
       SELECT opt.retroactive_flag
        FROM ozf_offr_market_options opt
        WHERE opt.GROUP_NUMBER= p_group_id
        AND opt.qp_list_header_id = p_list_header_id;

    CURSOR c_current_discount(p_volume IN NUMBER, p_parent_discount_id IN NUMBER) IS
        SELECT discount
        FROM ozf_offer_discount_lines
        WHERE p_volume > volume_from
             AND p_volume <= volume_to
         AND parent_discount_line_id = p_parent_discount_id;

    CURSOR  c_get_tier_limits (p_parent_discount_id IN NUMBER) IS
       SELECT MIN(volume_from),MAX(volume_to)
       FROM ozf_offer_discount_lines
       WHERE parent_discount_line_id = p_parent_discount_id;

     CURSOR  c_get_max_tier (p_max_volume_to IN NUMBER,p_parent_discount_id IN NUMBER)    IS
        SELECT  discount
        FROM ozf_offer_discount_lines
        WHERE volume_to =p_max_volume_to
        AND parent_discount_line_id = p_parent_discount_id;

         CURSOR  c_order_line_info(p_order_line_id IN NUMBER)  IS
        SELECT DECODE(line.line_category_code,'ORDER',line.ordered_quantity,
                                                                            'RETURN', -line.ordered_quantity) ordered_quantity,
             DECODE(line.line_category_code,'ORDER',NVL(line.shipped_quantity,line.ordered_quantity),
                                                                            'RETURN', line.invoiced_quantity,
                                                                            line.ordered_quantity) shipped_quantity,
             line.invoiced_quantity,
             line.unit_selling_price,
             line.line_id,
             line.actual_shipment_date,
             line.fulfillment_date,  -- invoiced date ?????
             line.inventory_item_id,
             header.transactional_curr_code,
             header.header_id
        FROM oe_order_lines_all line, oe_order_headers_all header
        WHERE line.line_id = p_order_line_id
          AND line.header_id = header.header_id;


 CURSOR  c_resale_line_info(p_resale_line_id IN NUMBER, p_adj_id IN NUMBER)  IS
        SELECT line.quantity ordered_quantity ,
             line.quantity shipped_quantity,
             line.quantity invoiced_quantity,
             adj.priced_unit_price unit_list_price,
             line.resale_line_id line_id,
             NVL(line.date_shipped, line.date_ordered) actual_shipment_date,
             NVL(line.date_shipped, line.date_ordered) fulfillment_date,  -- invoiced date ?????
             line.inventory_item_id,
             line.currency_code, --dummy column
             line.resale_header_id
        FROM OZF_RESALE_LINES_ALL line,ozf_resale_adjustments_all adj
        WHERE line.resale_line_id = p_resale_line_id
        AND adj.resale_adjustment_id = p_adj_id
        AND line.resale_line_id = adj.resale_line_id;

          CURSOR c_offer_curr IS
      SELECT nvl(transaction_currency_code,fund_request_curr_code), offer_id
        FROM ozf_offers
       WHERE qp_list_header_id = p_qp_list_header_id;

     --22-FEB-2007 kdass bug 5759350 - changed datatype of p_product_id from NUMBER to VARCHAR2 based on Feng's suggestion
     --fix for bug 5979971
   CURSOR c_apply_discount(p_offer_id IN NUMBER,p_line_id IN NUMBER) IS
        SELECT NVL(apply_discount_flag,'N')
        FROM ozf_order_group_prod
        WHERE offer_id = p_offer_id
          AND order_line_id = p_line_id;

    CURSOR c_offer_info (p_list_header_id IN NUMBER) IS
         SELECT nvl(transaction_currency_code,fund_request_curr_code) transaction_currency_code
               , beneficiary_account_id, offer_id
           FROM ozf_offers
          WHERE qp_list_header_id = p_list_header_id;

   CURSOR c_order_line_details (p_line_id IN NUMBER) IS
        SELECT invoice_to_org_id, ship_to_org_id
        FROM oe_order_lines_all
        WHERE line_id = p_line_id;

          CURSOR c_cust_number (p_header_id IN NUMBER) IS
         SELECT cust.cust_account_id
            FROM hz_cust_acct_sites_all acct_site,
                 hz_cust_site_uses_all site_use,
                 hz_cust_accounts  cust,
                 oe_order_headers_all header
            WHERE header.header_id = p_header_id
              AND acct_site.cust_acct_site_id = site_use.cust_acct_site_id
              AND acct_site.cust_account_id = cust.cust_account_id
              AND site_use.site_use_id = header.invoice_to_org_id ;


  CURSOR  c_prior_tiers(p_parent_discount_id  IN NUMBER, p_volume IN NUMBER ) IS
       SELECT  offer_discount_line_id ,volume_from ,volume_to, discount
         FROM  ozf_offer_discount_lines
         WHERE   parent_discount_line_id = p_parent_discount_id
         AND   p_volume >= volume_from
         ORDER BY volume_from  DESC;

  CURSOR c_preset_tier(p_pbh_line_id IN NUMBER, p_qp_list_header_id IN NUMBER,p_group_id IN NUMBER) IS
       SELECT a.discount
       FROM   ozf_offer_discount_lines a, ozf_market_preset_tiers b, ozf_offr_market_options c
       WHERE  a.offer_discount_line_id = b.dis_offer_discount_id
       AND    b.pbh_offer_discount_id = p_pbh_line_id
       AND    b.offer_market_option_id = c.offer_market_option_id
       AND    c.qp_list_header_id = p_qp_list_header_id
       AND    c.group_number = p_group_id;


CURSOR c_volume_detail (p_order_line_id IN NUMBER,p_source_code IN VARCHAR2) IS
  SELECT billto_cust_account_id, bill_to_site_use_id, ship_to_site_use_id
  FROM   ozf_funds_utilized_all_b
  WHERE  (p_source_code = 'OM' AND object_type = 'ORDER' AND order_line_id = p_order_line_id)
  OR     (p_source_code = 'IS' AND object_type = 'TP_ORDER' AND object_id = p_order_line_id);

  CURSOR c_all_cust_orders (p_list_header_id IN NUMBER, p_cust_account_id IN NUMBER)  IS
          select sum(ordered_quantity)
          FROM (
           SELECT SUM (DECODE(line_category_code,'ORDER',ordered_quantity,
                                                                            'RETURN', -ordered_quantity)) ordered_quantity
           from oe_order_lines_all oe,
           (SELECT distinct order_line_id FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
         AND cust_account_id = p_cust_account_id
          ) orders
          where   oe.line_id = orders.order_line_id
          UNION
         select sum(quantity) ordered_quantity from OZF_RESALE_LINES_INT_ALL ol ,
          (SELECT distinct reference_id FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
         AND cust_account_id = p_cust_account_id
          ) orders
          where ol.resale_batch_id = orders.reference_id

          );


        CURSOR c_all_cust_orders2 (p_list_header_id IN NUMBER, p_cust_account_id IN NUMBER, p_transaction_date IN DATE)  IS
          select sum(ordered_quantity)
          FROM (
           SELECT SUM (DECODE(line_category_code,'ORDER',ordered_quantity,
                                                                            'RETURN', -ordered_quantity)) ordered_quantity
           from oe_order_lines_all oe,
           (SELECT distinct order_line_id FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
         AND cust_account_id = p_cust_account_id
         AND gl_date <= p_transaction_date
          ) orders
          where   oe.line_id = orders.order_line_id
          UNION
         select sum(quantity) ordered_quantity from OZF_RESALE_LINES_INT_ALL ol ,
          (SELECT distinct reference_id FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
         AND cust_account_id = p_cust_account_id
         AND gl_date <= p_transaction_date
          ) orders
          where ol.resale_batch_id = orders.reference_id

          );

        CURSOR c_is_util_correct(p_list_header_id IN NUMBER) IS
           SELECT 1 FROM DUAL WHERE EXISTS
         ( SELECT 1
           FROM
           ( SELECT  sum(plan_curr_amount)  old_Adj_amt
            , order_line_id
            ,min(price_adjustment_id) price_adjustment_id
             ,object_type
             ,object_id
             ,min(gl_date) gl_date
        FROM ozf_funds_utilized_all_b
        WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
         AND NVL(gl_posted_flag,'Y')='Y'
         GROUP BY order_line_id,object_type,object_id
         ORDER BY gl_date) earned,
         ( SELECT  sum(plan_curr_amount)  old_Adj_amt
            , order_line_id
            ,min(price_adjustment_id) price_adjustment_id
             ,object_type
             ,object_id
             ,min(gl_date) gl_date
        FROM ozf_funds_utilized_all_b
        WHERE plan_id = p_list_header_id
         AND plan_type = 'OFFR'
         AND utilization_type IN ( 'ACCRUAL','SALES_ACCRUAL','LEAD_ACCRUAL','UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
         AND price_adjustment_id IS NOT NULL
        -- AND gl_posted_flag in ('Y','N')
         GROUP BY order_line_id,object_type,object_id
         ORDER BY gl_date) utilized

           WHERE utilized.old_Adj_amt <> earned.old_Adj_amt
           AND utilized.order_line_id=earned.order_line_id
           );



     l_api_name                CONSTANT VARCHAR2(30)   := 'volume_offer_util_adjustment';
     l_retroactive             VARCHAR2(1) ;
     l_total_ordered_qty       NUMBER;
     l_line_ordered_qty        NUMBER;
     l_volume                  NUMBER;
     l_group_id                NUMBER;
     l_pbh_line_id             NUMBER;
     l_value                   NUMBER;
     l_included_vol_flag       VARCHAR2(1);
     l_discount_type           VARCHAR2(30);
     l_volume_type             VARCHAR2(30);
     l_adj_amount              NUMBER;
     l_utilization_amount      NUMBER;
     l_min_tier                NUMBER;
     l_max_tier                NUMBER;
     l_new_discount            NUMBER;
     l_offer_curr              VARCHAR2(30);
     l_offer_id                NUMBER;
     l_selling_price           NUMBER;
     l_apply_discount          VARCHAR2(1) ;
     l_return_status           VARCHAR2 (20) :=  fnd_api.g_ret_sts_success;
     l_conv_price              NUMBER;
     l_rate                    NUMBER;
     l_new_utilization         NUMBER;
     l_invoice_to_org_id       NUMBER;
     l_ship_to_org_id          NUMBER;
     l_cust_number             NUMBER;
     l_act_budget_id           NUMBER;
     l_act_budgets_rec         ozf_actbudgets_pvt.act_budgets_rec_type;
     l_act_util_rec            ozf_actbudgets_pvt.act_util_rec_type;
     l_offer_info              c_offer_info%ROWTYPE;
     l_order_line_info         c_order_line_info%ROWTYPE;
     l_amountTbl               amountTbl ;
     l_objectTypeTbl           objectTypeTbl ;
     l_objectIdTbl             objectIdTbl;
     l_priceAdjustmentIDTbl    priceAdjustmentIDTbl ;
     l_orderLineIdTbl          orderLineIdTbl;
     l_glDateTbl               glDateTbl;
     l_order_line_id            NUMBER;

     --Added for bug 7030415
     l_utilizationIdTbl        utilizationIdTbl;
     CURSOR c_utilization_details(l_utilization_id IN NUMBER) IS
        SELECT exchange_rate_type, org_id
        FROM ozf_funds_utilized_all_b
        WHERE utilization_id=l_utilization_id;

     l_conv_type       ozf_funds_utilized_all_b.exchange_rate_type%TYPE;
     l_org_id          NUMBER;



      l_current_offer_tier_id   NUMBER;
      y1                        NUMBER; -- Initial Adjsutment
      l_current_max_tier        NUMBER;
      l_current_min_tier        NUMBER;
      l_current_tier_value      NUMBER;
      l_previous_tier_max       NUMBER;
      l_preset_tier             NUMBER;
      l_cust_account_id         NUMBER;
      l_bill_to                 NUMBER;
      l_ship_to                 NUMBER;
      l_source_code             VARCHAR2(30);
      l_util_correct            NUMBER;


   BEGIN

   write_conc_log(' /*************************** DEBUG MESSAGE START *************************/' || l_api_name);
   write_conc_log(' p_qp_list_header_id: ' || p_qp_list_header_id);

    OPEN c_all_orders (p_qp_list_header_id);
    FETCH c_all_orders INTO l_total_ordered_qty;
    CLOSE c_all_orders;

    write_conc_log(' l_total_ordered_qty: ' || l_total_ordered_qty);

    l_volume:=0;
    l_new_utilization := 0;

    OPEN c_is_util_correct(p_qp_list_header_id);
    FETCH c_is_util_correct INTO l_util_correct;
    CLOSE c_is_util_correct;

    write_conc_log(' l_util_correct: ' || l_util_correct);

   IF NVL(l_util_correct,0)<>0 THEN
   OPEN c_old_price_adj(p_qp_list_header_id);
           LOOP
             FETCH c_old_price_adj BULK COLLECT INTO l_amountTbl, l_orderLineIdTbl
                                                       , l_priceAdjustmentIDTbl
                                                       , l_objectTypeTbl, l_objectIdTbl, l_glDateTbl, l_utilizationIdTbl
                                                       LIMIT g_bulk_limit;

              FOR i IN NVL(l_priceAdjustmentIDTbl.FIRST, 1) .. NVL(l_priceAdjustmentIDTbl.LAST, 0) LOOP

               write_conc_log(' l_objectTypeTbl(i): ' || l_objectTypeTbl(i));


               IF l_objectTypeTbl(i) ='ORDER' THEN
                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message(' order_line_id:  '|| l_orderLineIdTbl(i) );
                     END IF;
                     write_conc_log(' order_line_id:  '|| l_orderLineIdTbl(i) );

                     l_order_line_id:=l_orderLineIdTbl(i);

                     OPEN c_order_line_info(l_orderLineIdTbl(i));
                     FETCH c_order_line_info INTO l_order_line_info;
                     CLOSE c_order_line_info;

                ELSE
                     IF G_DEBUG THEN
                       ozf_utility_pvt.debug_message(' resale_line_id:  '|| l_objectIdTbl(i) );
                     END IF;
                     write_conc_log(' resale_line_id:  '|| l_objectIdTbl(i));

                     l_order_line_id:=l_objectIdTbl(i);

                     OPEN c_resale_line_info(l_objectIdTbl(i),l_priceAdjustmentIDTbl(i));
                     FETCH c_resale_line_info INTO l_order_line_info;
                     CLOSE c_resale_line_info;
                END IF;

                l_selling_price := NVL(l_order_line_info.unit_selling_price,0) ; -- discount is negative

                write_conc_log(' l_selling_price:  '|| l_selling_price);

                  OPEN c_offer_curr;
                  FETCH c_offer_curr INTO l_offer_curr, l_offer_id;
                  CLOSE c_offer_curr;


                IF l_objectTypeTbl(i) ='ORDER' THEN
                  l_source_code := 'OM';
                ELSE
                  l_source_code := 'IS';
                END IF;

                  IF l_amountTbl(i) = 0 THEN -- fix bug 5689866
                    -- OPEN c_apply_discount(l_offer_id,l_order_line_info.inventory_item_id);
                     IF l_objectTypeTbl(i) ='ORDER' THEN

                        OPEN c_apply_discount(l_offer_id, l_orderLineIdTbl(i));
                        FETCH c_apply_discount INTO l_apply_discount;
                        CLOSE c_apply_discount;
                     ELSE
                        OPEN c_apply_discount(l_offer_id, l_objectIdTbl(i));
                        FETCH c_apply_discount INTO l_apply_discount;
                        CLOSE c_apply_discount;
                     END IF;

                     IF l_apply_discount ='N' THEN
                       IF G_DEBUG THEN
                          ozf_utility_pvt.debug_message('not apply discount:  ' || l_order_line_info.inventory_item_id);
                       END IF;
                       write_conc_log(' not apply discount:'|| l_order_line_info.inventory_item_id);
                       GOTO l_endoffloop;
                     END IF;
                  END IF; -- bug  5689866

                  --kdass 31-MAR-2006 bug 5101720 convert from order currency to offer currency
                  IF l_offer_curr <> l_order_line_info.transactional_curr_code THEN

                     ozf_utility_pvt.write_conc_log('order curr: ' || l_order_line_info.transactional_curr_code);
                     ozf_utility_pvt.write_conc_log('offer curr: ' || l_offer_curr);
                     ozf_utility_pvt.write_conc_log('selling price: ' || l_selling_price);

                     -- Added for bug 7030415
                     OPEN c_utilization_details(l_utilizationIdTbl(i));
                     FETCH c_utilization_details INTO l_conv_type, l_org_id;
                     CLOSE c_utilization_details;
                     l_act_util_rec.org_id := l_org_id;

                     ozf_utility_pvt.write_conc_log('l_conv_type: ' || l_conv_type);

                     ozf_utility_pvt.convert_currency (x_return_status => l_return_status
                                                      ,p_conv_type     => l_conv_type -- 7030415
                                                      ,p_conv_date     => l_order_line_info.actual_shipment_date
                                                      ,p_from_currency => l_order_line_info.transactional_curr_code
                                                      ,p_to_currency   => l_offer_curr
                                                      ,p_from_amount   => l_selling_price
                                                      ,x_to_amount     => l_conv_price
                                                      ,x_rate          => l_rate
                                                      );

                     IF l_return_status = fnd_api.g_ret_sts_error THEN
                        RAISE fnd_api.g_exc_error;
                     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                     END IF;

                     l_selling_price := NVL(l_conv_price,0);
                     write_conc_log ('selling price after currency conversion: ' || l_selling_price);

                  END IF;
                  /*ozf_utility_pvt.write_conc_log('l_orderLineIdTbl(i): ' || l_orderLineIdTbl(i));
                  OPEN c_order_line_qty(l_orderLineIdTbl(i));
                  FETCH c_order_line_qty INTO l_line_ordered_qty;
                  CLOSE c_order_line_qty;*/

                   l_line_ordered_qty := l_order_line_info.ordered_quantity;

                   ozf_utility_pvt.write_conc_log('l_line_ordered_qty: ' || l_line_ordered_qty);
                   ozf_utility_pvt.write_conc_log('l_orderLineIdTbl(i): ' || l_orderLineIdTbl(i));
                   ozf_utility_pvt.write_conc_log('p_qp_list_header_id: ' || p_qp_list_header_id);




                  OPEN c_get_group(l_orderLineIdTbl(i),p_qp_list_header_id);
                  FETCH c_get_group INTO l_group_id,l_pbh_line_id,l_included_vol_flag;
                  CLOSE c_get_group;

                  IF G_DEBUG THEN
                    ozf_utility_pvt.debug_message(' l_group_id:  '|| l_group_id );
                    ozf_utility_pvt.debug_message(' l_pbh_line_id:  '|| l_pbh_line_id );
                    ozf_utility_pvt.debug_message(' l_included_vol_flag:  '|| l_included_vol_flag );
                  END IF;

                  write_conc_log(' l_group_id:  '|| l_group_id );
                  write_conc_log(' l_pbh_line_id:  '|| l_pbh_line_id );
                  write_conc_log(' l_included_vol_flag:  '|| l_included_vol_flag );

                  IF l_group_id is NULL OR l_pbh_line_id is NULL THEN
                     GOTO l_endoffloop;
                  END IF;

                  OPEN c_market_option(p_qp_list_header_id,l_group_id);
                  FETCH c_market_option INTO l_retroactive;
                  CLOSE c_market_option;

                  write_conc_log(' l_retroactive:  '|| l_retroactive );



                --if retroactive
                IF l_retroactive = 'Y' THEN
                        OPEN c_volume_detail(l_orderLineIdTbl(i),l_source_code);
                        FETCH c_volume_detail INTO l_cust_account_id,l_ship_to,l_bill_to;
                        CLOSE c_volume_detail;

                        OPEN c_all_cust_orders(p_qp_list_header_id,l_cust_account_id);
                        FETCH c_all_cust_orders INTO l_total_ordered_qty;
                        CLOSE c_all_cust_orders;

                        l_volume:=NVL(l_total_ordered_qty,0);

                ELSE

                        OPEN c_volume_detail(l_orderLineIdTbl(i),l_source_code);
                        FETCH c_volume_detail INTO l_cust_account_id,l_ship_to,l_bill_to;
                        CLOSE c_volume_detail;

                        OPEN c_all_cust_orders2(p_qp_list_header_id,l_cust_account_id,l_glDateTbl(i));
                        FETCH c_all_cust_orders2 INTO l_total_ordered_qty;
                        CLOSE c_all_cust_orders2;

                        --l_volume:=NVL(l_volume,0)+NVL(l_line_ordered_qty,0);

                        l_volume:=NVL(l_total_ordered_qty,0);


                END IF;

                   write_conc_log(' l_volume:  '|| l_volume );

                  OPEN c_discount_header(l_pbh_line_id);
                  FETCH c_discount_header INTO l_discount_type,l_volume_type;
                  CLOSE c_discount_header;

                 -- fix for bug 6345305
                 IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                 l_volume := l_volume * l_selling_price;
                 END IF;

                 OPEN c_current_discount(l_volume,l_pbh_line_id);
                 FETCH c_current_discount INTO l_new_discount;
                 CLOSE c_current_discount;

                  write_conc_log(' l_volume_type:  '|| l_volume_type );
                  write_conc_log(' l_discount_type:  '|| l_discount_type );
                  write_conc_log(' l_new_discount:  '|| l_new_discount );

                  IF l_new_discount  is NULL THEN
                     OPEN c_get_tier_limits(l_pbh_line_id);
                     FETCH c_get_tier_limits INTO l_min_tier,l_max_tier;
                     CLOSE c_get_tier_limits;
                       write_conc_log(' l_min_tier:  '|| l_min_tier );
                       write_conc_log(' l_max_tier:  '|| l_max_tier );
                       write_conc_log(' l_volume:  '|| l_volume );
                     IF l_volume < l_min_tier THEN
                        l_new_discount := 0;
                     ELSE
                        OPEN c_get_max_tier(l_max_tier,l_pbh_line_id);
                        FETCH c_get_max_tier INTO l_new_discount;
                        CLOSE c_get_max_tier;

                     END IF;
                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message(' l_new_discount:  '|| l_new_discount );
                     END IF;
                     write_conc_log(' l_new_discount:  '|| l_new_discount );
                  END IF;


                   write_conc_log(' l_selling_price:  '|| l_selling_price );
                  IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN -- volume type = AMOUNT
                        l_value := NVL(l_line_ordered_qty,0) * l_selling_price ;
                  ELSE
                        l_value := NVL(l_line_ordered_qty,0) ;
                  END IF;

                  write_conc_log(' l_value:  '|| l_value );
                  write_conc_log(' l_retroactive:  '|| l_retroactive );
                  write_conc_log(' l_volume_type:  '|| l_volume_type );
                  write_conc_log(' l_discount_type:  '|| l_discount_type );
                  write_conc_log(' l_selling_price:  '|| l_selling_price );

                  l_preset_tier := NULL;

                  OPEN c_preset_tier(l_pbh_line_id,p_qp_list_header_id,l_group_id);
                  FETCH c_preset_tier INTO l_preset_tier;
                  CLOSE c_preset_tier;

                  write_conc_log( ' l_preset_tier=' || l_preset_tier);
                  write_conc_log( ' l_new_discount=' || l_new_discount);


                  IF l_preset_tier is NOT NULL AND l_preset_tier > l_new_discount THEN
                  l_new_discount := l_preset_tier;
                    IF G_DEBUG THEN
                       ozf_utility_pvt.debug_message('not reach preset tier:  ');
                    END IF;
                    write_conc_log(' not reach preset tier:');
                  END IF;


                   IF l_retroactive = 'Y' THEN
                     IF l_discount_type = '%' THEN
                        IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                           l_new_utilization := l_value* l_new_discount / 100;
                        ELSE -- % is for unit price. need to multiple when range in quantity.
                           l_new_utilization := l_value*  l_selling_price * l_new_discount / 100;
                        END IF;
                     ELSIF l_discount_type = 'AMT' THEN
                        IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                           -- amt is for unit pirce. need to divide when range in amount.
                           -- Fix for bug 9318975 - when l_selling price is zero, need not divide by selling price
                         IF l_selling_price <> 0 THEN
                           l_new_utilization :=l_value / l_selling_price * l_new_discount ;
                                write_conc_log ('l_selling_price <> 0, l_new_utilization2 = '||l_new_utilization);
                         ELSE
                                l_new_utilization := l_value;
                                write_conc_log ('l_selling_price = 0, l_new_utilization2 = '||l_new_utilization);
                         END IF;
                        ELSE
                           l_new_utilization :=l_value  * l_new_discount ;
                        END IF;
                     END IF;
                    END IF;  --l_retroactive


                  IF NVL(l_retroactive, 'N') = 'N' THEN

                     l_new_utilization := 0;

                  IF l_included_vol_flag = 'Y' THEN
                        l_previous_tier_max := l_volume;
                  ELSE
                        /*
                          logic here is to add current order line's volume to offer's volume for adjustment.
                          eg:  offer's volume=2.
                               order line's volume = 5, then total volume = 7.
                        */
                        l_previous_tier_max :=l_line_ordered_qty + l_volume ;
                   END IF;

                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message( ' l_line_ordered_qty=' || l_line_ordered_qty);
                     END IF;
                     write_conc_log( ' l_line_ordered_qty=' || l_line_ordered_qty);
                     --fix for bug 6021538

                       IF l_max_tier IS NULL THEN
                          OPEN c_get_tier_limits(l_pbh_line_id);
                          FETCH c_get_tier_limits INTO l_min_tier,l_max_tier;
                          CLOSE c_get_tier_limits;
                       END IF;

                      write_conc_log( ' l_value=' || l_value);
                      write_conc_log( ' l_volume=' || l_volume);
                      write_conc_log( ' l_max_tier=' || l_max_tier);


                       IF l_volume > l_max_tier THEN
                          l_line_ordered_qty:= l_max_tier -l_volume + l_line_ordered_qty;
                          IF l_line_ordered_qty<0 THEN
                             l_line_ordered_qty:=0;
                          END IF;
                        END IF;

                     --end bug 6021538

                     l_preset_tier := NULL;



                     OPEN  c_prior_tiers(l_pbh_line_id, l_volume);
                     LOOP
                       FETCH c_prior_tiers INTO l_current_offer_tier_id,l_current_min_tier,l_current_max_tier,l_current_tier_value;
                       EXIT WHEN c_prior_tiers%NOTFOUND;

                       write_conc_log( ' l_current_offer_tier_id=' || l_current_offer_tier_id);


                        OPEN c_preset_tier(l_pbh_line_id,p_qp_list_header_id,l_group_id);
                        FETCH c_preset_tier INTO l_preset_tier;
                        CLOSE c_preset_tier;

                        write_conc_log( ' l_preset_tier=' || l_preset_tier);
                        write_conc_log( ' l_current_tier_value=' || l_current_tier_value);


                        IF l_preset_tier is NOT NULL AND l_preset_tier > l_current_tier_value THEN
                        l_current_tier_value := l_preset_tier;
                        IF G_DEBUG THEN
                                ozf_utility_pvt.debug_message('not reach preset tier:  ');
                        END IF;
                        write_conc_log(' not reach preset tier:');
                        END IF;



                       y1 := LEAST((l_previous_tier_max-l_current_min_tier),l_line_ordered_qty) ;
                       l_line_ordered_qty := l_line_ordered_qty - y1;
                       IF l_discount_type = '%' THEN
                          IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                             l_new_utilization := l_new_utilization +  y1* l_current_tier_value / 100;
                          ELSE
                             l_new_utilization := l_new_utilization +  y1*  l_selling_price * l_current_tier_value / 100;
                          END IF;
                       ELSIF l_discount_type = 'AMT' THEN
                          IF l_volume_type = 'PRICING_ATTRIBUTE12' THEN
                              l_new_utilization := l_new_utilization + y1 / l_selling_price * l_current_tier_value ;
                          ELSE
                              l_new_utilization := l_new_utilization + y1* l_current_tier_value ;
                          END IF;
                       END IF;

                       --l_previous_tier_max := l_current_min_tier - 1 ;
                       l_previous_tier_max := l_current_min_tier;

                       IF G_DEBUG THEN
                          ozf_utility_pvt.debug_message(' retroactive flag is N, computing for prior tier id=' || l_current_offer_tier_id
                                      || ' y1='  || y1 || '     tier_min=' || l_current_min_tier
                                      || '     tier_max=' || l_current_max_tier || ' l_previous_tier_max: ' || l_previous_tier_max
                                      || '  l_new_utilization: ' || l_utilization_amount);
                       END IF;
                          write_conc_log(' retroactive flag is N, computing for prior tier id=' || l_current_offer_tier_id
                                      || ' y1='  || y1 || '     tier_min=' || l_current_min_tier
                                      || '     tier_max=' || l_current_max_tier || ' l_previous_tier_max: ' || l_previous_tier_max
                                      || '  l_new_utilization: ' || l_utilization_amount);

                       EXIT WHEN l_line_ordered_qty <= 0;

                     END LOOP;  -- end of loop for c_prior_tiers
                     CLOSE c_prior_tiers;

                  END IF; --  IF NVL(l_retroactive, 'N') = 'N' THEN


                    write_conc_log(' l_amountTbl(i):  '|| l_amountTbl(i) );
                    write_conc_log(' l_new_utilization:  '|| l_new_utilization );

                     --IF l_amountTbl(i)<= l_new_utilization THEN

                     l_adj_amount := l_new_utilization - l_amountTbl(i);

                     write_conc_log(' l_adj_amount:  '|| l_adj_amount );

                       OPEN c_offer_info (p_qp_list_header_id);
                       FETCH c_offer_info INTO l_offer_info;
                       CLOSE c_offer_info;

                       OPEN c_order_line_details (l_orderLineIdTbl(i));
                       FETCH c_order_line_details into l_invoice_to_org_id, l_ship_to_org_id;
                       CLOSE c_order_line_details;

                       write_conc_log(' l_invoice_to_org_id:  '|| l_invoice_to_org_id );
                        write_conc_log(' l_ship_to_org_id:  '|| l_ship_to_org_id );



                     --create records
                  l_act_budgets_rec.act_budget_used_by_id := p_qp_list_header_id;
                  l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                  l_act_budgets_rec.budget_source_type := 'OFFR';
                  l_act_budgets_rec.budget_source_id := p_qp_list_header_id;
                  l_act_budgets_rec.request_currency := l_offer_info.transaction_currency_code;
                  l_act_budgets_rec.request_date := SYSDATE;
                  l_act_budgets_rec.status_code := 'APPROVED';
                  l_act_budgets_rec.user_status_id := ozf_Utility_Pvt.get_default_user_status (
                                                            'OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);
                  l_act_budgets_rec.approved_in_currency  := l_offer_info.transaction_currency_code;
                  l_act_budgets_rec.approval_date := SYSDATE;
                  l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
                  l_act_budgets_rec.justification := 'Offer adjustment before offer start date';
                  l_act_budgets_rec.transfer_type := 'UTILIZED';

                  l_act_util_rec.utilization_type :='ADJUSTMENT';
                  l_act_util_rec.product_level_type := 'PRODUCT';
                  l_act_util_rec.adjustment_date := SYSDATE;
                  l_act_util_rec.cust_account_id := l_offer_info.beneficiary_account_id;
                  l_act_util_rec.ship_to_site_use_id  := l_ship_to_org_id;
                  l_act_util_rec.bill_to_site_use_id  := l_invoice_to_org_id;

                  l_act_util_rec.product_id  := l_order_line_info.inventory_item_id;
                  l_act_util_rec.object_type :='ORDER';
                  l_act_util_rec.object_id := l_order_line_info.header_id;
                  l_act_util_rec.order_line_id := l_order_line_id;
                  l_act_util_rec.price_adjustment_id := -1;
                  l_act_util_rec.orig_utilization_id:= -1;


                  write_conc_log(' l_order_line_info.header_id:  '|| l_order_line_info.header_id );
                  OPEN c_cust_number (l_order_line_info.header_id);
                  FETCH c_cust_number INTO l_cust_number;
                  CLOSE c_cust_number;

                  l_act_util_rec.billto_cust_account_id := l_cust_number;

                  IF l_offer_info.beneficiary_account_id IS NULL THEN
                     l_act_util_rec.cust_account_id := l_cust_number;
                  END IF;


                  -- this adjustment is to adjust utilized amount in all cases so its not backdated adjustment
                  -- also it is not for earned so it is not volume offer adjustment either.
                  -- set to backdated until decision is made.
                IF l_adj_amount > 0 THEN
                     l_act_util_rec.adjustment_type :='STANDARD'; -- Seeded Data for Backdated Positive Adj
                     l_act_util_rec.adjustment_type_id := -5; -- Seeded Data for Backdated Positive Adj
                  ELSE
                     l_act_util_rec.adjustment_type :='DECREASE_EARNED'; -- Seeded Data for Backdated Negative Adj
                     l_act_util_rec.adjustment_type_id := -4; -- Seeded Data for Backdated Negative Adj
                  END IF;

                  l_act_util_rec.gl_posted_flag:= 'N';

                  l_act_budgets_rec.request_amount := l_adj_amount;
                  l_act_budgets_rec.approved_amount := l_adj_amount;

                     ----------------------


                      IF  NVL(l_adj_amount,0) <> 0 THEN
                      ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => x_return_status
                                                             ,x_msg_count       => x_msg_count
                                                             ,x_msg_data        => x_msg_data
                                                             ,p_act_budgets_rec => l_act_budgets_rec
                                                             ,p_act_util_rec    => l_act_util_rec
                                                             ,x_act_budget_id   => l_act_budget_id
                                                             );

                     write_conc_log('process_act_budgets returns: ' || x_return_status);
                     IF l_return_status = fnd_api.g_ret_sts_error THEN
                       RAISE fnd_api.g_exc_error;
                     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                       RAISE fnd_api.g_exc_unexpected_error;
                     END IF;
                    END IF;
                   -- END IF;

               <<l_endoffloop>>
                  NULL;
               END LOOP; -- loop for For
                EXIT WHEN c_old_price_adj%NOTFOUND;
             END LOOP; -- end price adj loop

   CLOSE c_old_price_adj;
   END IF;

   END volume_offer_util_adjustment;




END ozf_adjustment_ext_pvt;


/
