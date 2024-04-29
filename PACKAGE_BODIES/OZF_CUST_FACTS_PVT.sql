--------------------------------------------------------
--  DDL for Package Body OZF_CUST_FACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CUST_FACTS_PVT" AS
/*$Header: ozfvcftb.pls 120.12 2006/01/06 03:41:18 inanaiah ship $*/

PROCEDURE refresh_accts_and_products(
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                     p_report_date   IN DATE,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) AS

   /*
      Populate Accounts and Products only for leaf node quotas
   */
   CURSOR c_cust_prod IS
   SELECT  distinct
           b.cust_account_id       cust_account_id,
           b.site_use_id           site_use_id ,
           b.bill_to_site_use_id   bill_to_site_use_id,
           c.item_id               inventory_item_id ,
           c.item_id               item_id ,
           c.item_type             item_type
   FROM    ozf_funds_all_b a
          ,ozf_account_allocations b
          ,ozf_product_allocations c
   WHERE a.fund_type = 'QUOTA'
   --AND  p_report_date BETWEEN a.start_date_active
   --                       AND a.end_date_active
    AND   a.status_code <> 'CANCELLED'
    AND   b.allocation_for = 'FUND'
    AND   b.allocation_for_id = a.fund_id
    AND   NVL(b.account_status, 'X') <> 'D'
    AND   c.allocation_for = 'CUST'
    AND   c.allocation_for_id = b.account_allocation_id
    AND   a.parent_fund_id IS NOT NULL
    AND   NOT EXISTS ( SELECT 1
                      FROM  ozf_funds_all_b bb
                      WHERE bb.parent_fund_id = a.fund_id );

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'refresh_accts_and_products';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);


BEGIN

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   DELETE FROM ozf_cust_daily_facts
   WHERE report_date = p_report_date;

   -- Get only allocations for the Child Quotas

   FOR i IN c_cust_prod
   LOOP

   INSERT INTO ozf_cust_daily_facts (
                cust_daily_fact_id              ,
                report_date                     ,
                cust_account_id                 ,
                ship_to_site_use_id             ,
                bill_to_site_use_id             ,
                inventory_item_id               ,
                product_attr_value              ,
                product_attribute               ,
                creation_date                   ,
                created_by                      ,
                last_update_date                ,
                last_updated_by                 ,
                last_update_login               )
    VALUES   ( ozf_cust_daily_facts_s.nextval,
                trunc(p_report_date),
                i.cust_account_id,
                i.site_use_id,
                i.bill_to_site_use_id,
                i.inventory_item_id,
                i.item_id,
                i.item_type,
                SYSDATE,
                -1,
                SYSDATE,
                -1,
                -1 );
   END LOOP; --c_cust_prod

   -- for R12, insert records into OZF_RES_CUST_PROD table
   DELETE from OZF_RES_CUST_PROD;

   INSERT INTO OZF_RES_CUST_PROD
        (SELECT distinct
                fund.owner RESOURCE_ID,
                acct.parent_party_id PARTY_ID,
                acct.cust_account_id CUST_ACCOUNT_ID,
                acct.bill_to_site_use_id BILL_TO_SITE_USE_ID,
                acct.site_use_id SHIP_TO_SITE_USE_ID,
                prod.item_type PRODUCT_ATTRIBUTE,
                prod.item_id PRODUCT_ATTR_VALUE
        FROM  ozf_account_allocations acct,
                ozf_product_allocations prod,
                (SELECT DISTINCT a.owner
                   FROM ozf_funds_all_b a
                 WHERE a.fund_type = 'QUOTA'
                   AND a.status_code <> 'CANCELLED') fund
        WHERE prod.allocation_for = 'CUST'
          AND   prod.allocation_for_id = acct.account_allocation_id
          AND   acct.allocation_for = 'FUND'
          AND   NVL(acct.account_status, 'X') <> 'D'
          AND   acct.allocation_for_id in
                (SELECT aa.fund_id
                    FROM  ozf_funds_all_b aa
                  WHERE aa.owner = fund.owner
                       AND aa.fund_type   = 'QUOTA'
                       AND aa.status_code <> 'CANCELLED'
                       AND NOT EXISTS ( SELECT 1
                                            FROM  ozf_funds_all_b bb
                                            WHERE bb.parent_fund_id = aa.fund_id )
                 UNION ALL
                    SELECT aa.fund_id
                            FROM   ozf_funds_all_b aa
                            WHERE  aa.fund_type    = 'QUOTA'
                            AND aa.status_code  <> 'CANCELLED'
                            CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
                    START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                        FROM ozf_funds_all_b bb
                                        WHERE bb.owner= fund.owner
                                AND bb.fund_type   = 'QUOTA'
                                AND bb.status_code <> 'CANCELLED')
                        )
           AND prod.item_type <> 'OTHERS');

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
END refresh_accts_and_products;


PROCEDURE refresh_sales_info(
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                     p_report_date   IN DATE,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) AS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'refresh_sales_info';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   CURSOR daily_facts_csr IS
   SELECT cust_daily_fact_id,
          report_date,
          cust_account_id,
          ship_to_site_use_id,
          bill_to_site_use_id,
          product_attribute,
          product_attr_value,
          inventory_item_id
   FROM ozf_cust_daily_facts
   WHERE report_date =  p_report_date;

   CURSOR xtd_sales_csr (p_report_date         DATE,
                         p_cust_account_id     NUMBER,
                         p_ship_to_site_use_id NUMBER,
                         p_bill_to_site_use_id NUMBER,
                         p_inventory_item_id   NUMBER ) IS
   SELECT a.period_type_id,
          NVL(SUM(b.sales),0) tot_sales
   FROM ozf_time_rpt_struct a,
        ozf_order_sales_v b
   WHERE a.report_date = p_report_date
   AND BITAND(a.record_type_id, 119) = a.record_type_id
   AND a.time_id = b.time_id
   AND b.cust_account_id = p_cust_account_id
   AND b.ship_to_site_use_id = p_ship_to_site_use_id
   AND b.bill_to_site_use_id = DECODE(p_bill_to_site_use_id,
                                          -9996,b.bill_to_site_use_id,
                                                p_bill_to_site_use_id)
   AND b.inventory_item_id = p_inventory_item_id
   GROUP BY a.period_type_id ;

   CURSOR items_csr (p_item_type VARCHAR2,
                     p_item_id   NUMBER) IS
   SELECT inventory_item_id
   FROM mtl_item_categories mtl,
        eni_prod_denorm_hrchy_v eni
   WHERE mtl.category_set_id  = eni.category_set_id
   AND mtl.category_id = eni.child_id
   AND mtl.organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
   AND eni.parent_id = p_item_id
   AND 'PRICING_ATTRIBUTE2' = p_item_type
   UNION ALL
   SELECT p_item_id inventory_item_id
   FROM dual
   WHERE 'PRICING_ATTRIBUTE1' = p_item_type
   UNION ALL
   SELECT p_item_id inventory_item_id
   FROM dual
   WHERE 'OTHERS' = p_item_type;

   -- for R12, get the last year sales for Month, Quarter and Year as of the report_date
   CURSOR ly_sales_csr (p_report_date         DATE,
                         p_cust_account_id     NUMBER,
                         p_ship_to_site_use_id NUMBER,
                         p_bill_to_site_use_id NUMBER,
                         p_inventory_item_id   NUMBER,
        p_period_type_id NUMBER ) IS
      SELECT NVL(SUM(b.sales),0) tot_sales
      FROM ozf_time_rpt_struct a,
           ozf_order_sales_v b,
           ozf_time_day c
      WHERE c.report_date = p_report_date
        AND a.time_id = decode(p_period_type_id,32,c.ent_period_id,
                        64, c.ent_qtr_id,
                        128, c.ent_year_id)
        AND b.time_id = a.time_id
        AND b.cust_account_id = p_cust_account_id
        AND b.ship_to_site_use_id = p_ship_to_site_use_id
        AND b.bill_to_site_use_id = DECODE(p_bill_to_site_use_id,
                                          -9996,b.bill_to_site_use_id,
                                                p_bill_to_site_use_id)
        AND b.inventory_item_id = p_inventory_item_id;

   -- for R12, get the XTD baseline sales last year sales for Month, Quarter and Year as of the report_date
   CURSOR xtd_baseline_sales_csr (p_report_date         DATE,
                                  p_ship_to_site_use_id NUMBER,
                                  p_item_id       NUMBER ) IS
   SELECT b.period_type_id,
          NVL(SUM(b.baseline_sales),0) base_sales
     FROM ozf_time_rpt_struct a,
          ozf_baseline_sales_v b
    WHERE a.report_date = p_report_date
      AND BITAND(a.record_type_id, 119) = a.record_type_id
      AND a.time_id = b.time_id
      AND b.data_source = fnd_profile.value('OZF_DASH_BASELINE_SALES_SRC')
      AND b.market_type = 'SHIP_TO'
      AND b.market_id = p_ship_to_site_use_id
      AND b.item_level = 'PRICING_ATTRIBUTE1'
      AND b.item_id = p_ITEM_ID
    GROUP BY b.period_type_id;

   l_report_date DATE;
   l_ly_report_date DATE;

   l_day_total  NUMBER;
   l_week_total NUMBER;
   l_mth_total  NUMBER;
   l_qtr_total  NUMBER;

   l_ly_day_total  NUMBER;
   l_ly_week_total NUMBER;
   l_ly_mth_total  NUMBER;
   l_ly_qtr_total  NUMBER;

   -- Added for R12
   l_ly_sales NUMBER;
   l_ly_qtr_sales NUMBER;
   l_ly_mth_sales NUMBER;
   l_day_bsales  NUMBER;
   l_week_bsales NUMBER;
   l_mth_bsales  NUMBER;
   l_qtr_bsales  NUMBER;
   l_ytd_sales  NUMBER;
   l_ytd_bsales  NUMBER;
   l_qtd_sales NUMBER;
   l_qtd_bsales NUMBER;
   l_mtd_sales NUMBER;
   l_mtd_bsales NUMBER;

BEGIN

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   --
   l_report_date := p_report_date;
   l_ly_report_date :=  add_months(p_report_date, -12);

   FOR fact IN daily_facts_csr
   LOOP
     -- Initialize all variables
     l_day_total  := 0;
     l_week_total := 0;
     l_mth_total  := 0;
     l_qtr_total  := 0;

     l_ly_day_total  := 0;
     l_ly_week_total := 0;
     l_ly_mth_total  := 0;
     l_ly_qtr_total  := 0;

     l_day_bsales  := 0;
     l_week_bsales := 0;
     l_mth_bsales  := 0;
     l_qtr_bsales  := 0;
     l_ytd_sales := 0;
     l_ytd_bsales := 0;
     l_qtd_sales := 0;
     l_qtd_bsales := 0;
     l_mtd_sales := 0;
     l_mtd_bsales := 0;

     -- Calculate XTD totals

     -- If item_type is a category, then sum for all products in the category

     FOR prod IN items_csr( fact.product_attribute,
                            TO_NUMBER(fact.product_attr_value) )
     LOOP
         --
         FOR sale IN  xtd_sales_csr (l_report_date ,
                                     fact.cust_account_id ,
                                     fact.ship_to_site_use_id ,
                                     fact.bill_to_site_use_id ,
                                     prod.inventory_item_id )
         LOOP
         --
             IF sale.period_type_id = 1
             THEN
                 l_day_total := l_day_total + sale.tot_sales ;
             ELSIF sale.period_type_id = 16
             THEN
                 l_week_total := l_week_total + sale.tot_sales ;
             ELSIF sale.period_type_id = 32
             THEN
                 l_mth_total := l_mth_total + sale.tot_sales ;
             ELSIF sale.period_type_id = 64
             THEN
                 l_qtr_total := l_qtr_total + sale.tot_sales ;
             END IF;
          --
          END LOOP; -- xtd_sales_csr

          -- Calculate LYSP and LYTD totals

          FOR sale IN  xtd_sales_csr (l_ly_report_date ,
                                      fact.cust_account_id ,
                                      fact.ship_to_site_use_id ,
                                      fact.bill_to_site_use_id ,
                                      prod.inventory_item_id )
          LOOP
          --
              IF sale.period_type_id = 1
              THEN
                  l_ly_day_total := l_ly_day_total + sale.tot_sales ;
              ELSIF sale.period_type_id = 16
              THEN
                  l_ly_week_total := l_ly_week_total + sale.tot_sales ;
              ELSIF sale.period_type_id = 32
              THEN
                  l_ly_mth_total := l_ly_mth_total + sale.tot_sales ;
              ELSIF sale.period_type_id = 64
              THEN
                  l_ly_qtr_total := l_ly_qtr_total + sale.tot_sales ;
              END IF;
           --
           END LOOP; -- xtd_sales_csr


           --Added for R12 - baseline Sales
           --Calculate baseline sales total for all Products in the family
           FOR basesale IN xtd_baseline_sales_csr (l_report_date ,
                                          fact.ship_to_site_use_id,
                                          prod.inventory_item_id)
           LOOP
                  IF basesale.period_type_id = 1
                  THEN
                      l_day_bsales := l_day_bsales + basesale.base_sales ;
                  ELSIF basesale.period_type_id = 16
                  THEN
                      l_week_bsales := l_week_bsales + basesale.base_sales ;
                  ELSIF basesale.period_type_id = 32
                  THEN
                      l_mth_bsales := l_mth_bsales + basesale.base_sales ;
                  ELSIF basesale.period_type_id = 64
                  THEN
                      l_qtr_bsales := l_qtr_bsales + basesale.base_sales ;
                  END IF;

           END LOOP; -- xtd_baseline_sales_csr


           --Added for R12 - last year sales
           OPEN ly_sales_csr (l_ly_report_date ,
                                fact.cust_account_id ,
                                fact.ship_to_site_use_id ,
                                fact.bill_to_site_use_id ,
                                prod.inventory_item_id,
                                128 );
           FETCH ly_sales_csr INTO l_ly_sales;
           CLOSE ly_sales_csr;

           --Added for R12 - last year's same quarter sales
           OPEN ly_sales_csr (l_ly_report_date ,
                                fact.cust_account_id ,
                                fact.ship_to_site_use_id ,
                                fact.bill_to_site_use_id ,
                                prod.inventory_item_id,
                                64 );
           FETCH ly_sales_csr INTO l_ly_qtr_sales;
           CLOSE ly_sales_csr;

           --Added for R12 - last year's same month sales
           OPEN ly_sales_csr (l_ly_report_date ,
                                fact.cust_account_id ,
                                fact.ship_to_site_use_id ,
                                fact.bill_to_site_use_id ,
                                prod.inventory_item_id,
                                32 );
           FETCH ly_sales_csr INTO l_ly_mth_sales;
           CLOSE ly_sales_csr;

      END LOOP; -- item_csr

/*
--Moved this inside item_csr because baseline mv now doesnt have data for categories---------
      --Calculate baseline sales total for all Products in the family
      FOR basesale IN xtd_baseline_sales_csr (l_report_date ,
                                     fact.ship_to_site_use_id,
                                     fact.product_attribute,
                                     fact.inventory_item_id )
      LOOP
             IF basesale.period_type_id = 1
             THEN
                 l_day_bsales := l_day_bsales + basesale.base_sales ;
             ELSIF basesale.period_type_id = 16
             THEN
                 l_week_bsales := l_week_bsales + basesale.base_sales ;
             ELSIF basesale.period_type_id = 32
             THEN
                 l_mth_bsales := l_mth_bsales + basesale.base_sales ;
             ELSIF basesale.period_type_id = 64
             THEN
                 l_qtr_bsales := l_qtr_bsales + basesale.base_sales ;
             END IF;

      END LOOP; -- xtd_baseline_sales_csr
------------------------------------------------------------------------------------------
*/

      l_mtd_sales := l_day_total + l_week_total ;
      l_mtd_bsales := l_day_bsales + l_week_bsales ;
      l_qtd_sales := l_mtd_sales + l_mth_total;
      l_qtd_bsales := l_mtd_bsales + l_mth_bsales;
      l_ytd_sales := l_qtd_sales + l_qtr_total ;
      l_ytd_bsales := l_qtd_bsales + l_qtr_bsales ;

      /* MTD Baseline (lesser of: forecasted baseline or MTD sales) */
      IF l_mtd_sales < l_mtd_bsales THEN
               l_mtd_bsales := l_mtd_sales ;
      END IF ;

      /* QTD Baseline (lesser of: forecasted baseline or QTD sales) */
      IF l_qtd_sales < l_qtd_bsales THEN
               l_qtd_bsales := l_qtd_sales ;
      END IF ;

      /* YTD Baseline (lesser of: forecasted baseline or YTD sales) */
      IF l_ytd_sales < l_ytd_bsales THEN
               l_ytd_bsales := l_ytd_sales ;
      END IF ;

         -- ozf_utility_pvt.write_conc_log( 'Fact Id : '||fact.cust_daily_fact_id);
         -- ozf_utility_pvt.write_conc_log( 'Day     : '|| l_day_total);
         -- ozf_utility_pvt.write_conc_log( 'Week    : '|| l_week_total);
         -- ozf_utility_pvt.write_conc_log( 'Month   : '|| l_mth_total);
         -- ozf_utility_pvt.write_conc_log( 'Quarter : '|| l_qtr_total);

      -- Modified for R12
      UPDATE ozf_cust_daily_facts
      SET  ptd_sales =  l_mtd_sales
          ,qtd_sales =  l_day_total + l_week_total + l_mth_total
          ,ytd_sales =  l_ytd_sales
          ,lptd_sales = l_ly_day_total + l_ly_week_total
          ,lqtd_sales = l_ly_day_total + l_ly_week_total + l_ly_mth_total
          ,lysp_sales = l_ly_mth_sales
          ,lysq_sales = l_ly_qtr_sales
          ,ly_sales = l_ly_sales
          ,lytd_sales = l_ly_day_total + l_ly_week_total + l_ly_mth_total + l_ly_qtr_total
          ,mtd_basesales = l_mtd_bsales
          ,qtd_basesales = l_qtd_bsales
          ,ytd_basesales = l_ytd_bsales
      WHERE cust_daily_fact_id = fact.cust_daily_fact_id;

   END LOOP;
   --
   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
END refresh_sales_info;


PROCEDURE refresh_orders_info(
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                     p_report_date   IN DATE,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) AS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'refresh_orders_info';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   CURSOR last_day_csr IS
   SELECT b.end_date
   FROM   ozf_time_day a,
          ozf_time_ent_period b
   WHERE  a.report_date = p_report_date
   AND    a.ent_period_id = b.ent_period_id;


   CURSOR items_csr (p_item_type VARCHAR2,
                     p_item_id   NUMBER) IS
   SELECT inventory_item_id
   FROM mtl_item_categories mtl,
        eni_prod_denorm_hrchy_v eni
   WHERE mtl.category_set_id  = eni.category_set_id
   AND mtl.category_id = eni.child_id
   AND mtl.organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
   AND eni.parent_id = p_item_id
   AND 'PRICING_ATTRIBUTE2' = p_item_type
   UNION ALL
   SELECT p_item_id inventory_item_id
   FROM dual
   WHERE 'PRICING_ATTRIBUTE1' = p_item_type
   UNION ALL
   SELECT p_item_id inventory_item_id
   FROM dual
   WHERE 'OTHERS' = p_item_type;

   CURSOR daily_facts_csr IS
   SELECT cust_daily_fact_id,
          report_date,
          cust_account_id,
          ship_to_site_use_id,
          bill_to_site_use_id,
          product_attribute,
          product_attr_value,
          inventory_item_id
   FROM ozf_cust_daily_facts
   WHERE report_date =  p_report_date;

   /*
      - Convert Order quantity to common uom
      - Convert Order amount to common currency
   */
   CURSOR open_orders_csr( p_ship_to_site_use_id NUMBER,
                           p_bill_to_site_use_id NUMBER,
                           p_inventory_item_id   NUMBER) IS
   SELECT a.line_id,
          a.request_date,
          a.promise_date,
          a.schedule_ship_date,
          DECODE( ozf_tp_util_queries.get_quota_unit,
                 'A', gl_currency_api.convert_amount_sql( b.transactional_curr_code,
                                                          fnd_profile.value('OZF_TP_COMMON_CURRENCY'),
                                                          a.request_date,
                                                          fnd_profile.value('OZF_CURR_CONVERSION_TYPE'),
                                                          (a.ordered_quantity*a.unit_selling_price)
                                                        )
                    , inv_convert.inv_um_convert(a.inventory_item_id,
                                                 NULL,
                                                 a.ordered_quantity,
                                                 a.order_quantity_uom,
                                                 fnd_profile.value('OZF_TP_COMMON_UOM') ,
                                                 NULL,
                                                 NULL)
                 ) order_unit,
         DECODE (ozf_tp_util_queries.get_quota_unit,
                  'A', b.transactional_curr_code
                     , a.order_quantity_uom) from_unit,
         DECODE (ozf_tp_util_queries.get_quota_unit,
                  'A', fnd_profile.value('OZF_TP_COMMON_CURRENCY')
                     , fnd_profile.value('OZF_TP_COMMON_UOM') ) to_unit,
         DECODE (ozf_tp_util_queries.get_quota_unit,
                  'A', (a.ordered_quantity*a.unit_selling_price)
                     ,  a.ordered_quantity ) unit
   FROM  oe_order_lines_all a,
         oe_order_headers_all b
   WHERE a.open_flag = 'Y'
   AND   a.cancelled_flag = 'N'
   AND   a.booked_flag = 'Y'
   AND   a.ship_to_org_id = p_ship_to_site_use_id
   AND   a.invoice_to_org_id = DECODE(p_bill_to_site_use_id,-9996, a.invoice_to_org_id,p_bill_to_site_use_id)
   AND   a.inventory_item_id = p_inventory_item_id
   AND   a.header_id = b.header_id ;

   CURSOR backorder_csr( p_line_id NUMBER) IS
   SELECT  NVL(
           SUM(
           DECODE (ozf_tp_util_queries.get_quota_unit,
                   'A', gl_currency_api.convert_amount_sql( a.currency_code,
                                                            fnd_profile.value('OZF_TP_COMMON_CURRENCY'),
                                                            a.date_requested,
                                                            fnd_profile.value('OZF_CURR_CONVERSION_TYPE'),
                                                            (a.requested_quantity*a.unit_price))
                       , inv_convert.inv_um_convert(a.inventory_item_id,
                                                    NULL,
                                                    a.requested_quantity,
                                                    a.requested_quantity_uom,
                                                    fnd_profile.value('OZF_TP_COMMON_UOM') ,
                                                    NULL,
                                                    NULL)
                    )
              ) , 0 ) requested_quantity
   FROM   wsh_deliverables_v a
   WHERE  a.source_line_id = p_line_id
   AND    a.released_status = 'B';

   l_last_day_of_period DATE;

   l_past_due_qty      NUMBER;
   l_backordered_qty   NUMBER;
   l_future_order_qty  NUMBER;
   l_current_order_qty NUMBER;

   l_temp_bo_qty       NUMBER;

BEGIN

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   --

   -- Get Last Day of the Period
   OPEN last_day_csr;
   FETCH last_day_csr INTO l_last_day_of_period;
   CLOSE last_day_csr;

   FOR fact IN daily_facts_csr
   LOOP
      -- Initialize all variables
      l_past_due_qty      := 0;
      l_backordered_qty   := 0;
      l_future_order_qty  := 0;
      l_current_order_qty := 0;

      -- For every site-product get the orders info

     FOR prod IN items_csr(fact.product_attribute,
                           TO_NUMBER(fact.product_attr_value))
     LOOP
         --

         FOR ord IN open_orders_csr(fact.ship_to_site_use_id,
                                    fact.bill_to_site_use_id,
                                    prod.inventory_item_id)
         LOOP

             IF ( ord.order_unit < 0 )
             THEN

             /*
              FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_MISSING_CONVERSIONS');
              FND_MESSAGE.Set_Token('TYPE', 'UOM');
              FND_MESSAGE.Set_Token('FROM_VALUE', err.uom_code);
              FND_MESSAGE.Set_Token('TO_VALUE', err.common_uom_code);
              FND_MESSAGE.Set_Token('DATE', err.transaction_date);
              l_mesg := FND_MESSAGE.Get;
              */
               ozf_utility_pvt.write_conc_log('Cannot convert ' || ord.from_unit || ' to ' || ord.to_unit );
               ozf_utility_pvt.write_conc_log('This value will be ignored ' || ord.unit );

               GOTO NEXT_ORDER;
             END IF;

             IF ( SIGN(TRUNC(ord.promise_date) - TRUNC(p_report_date) ) = -1 )
             THEN
                 -- This Order Line is past the due date
                 -- Check if it is backordered
                 OPEN backorder_csr(ord.line_id);
                 FETCH backorder_csr INTO l_temp_bo_qty ;
                 CLOSE backorder_csr;
                 --
                 IF l_temp_bo_qty = 0
                 THEN
                    -- Order is due but not backorderd
                    l_past_due_qty := l_past_due_qty + ord.order_unit ;
                 ELSE
                    -- Order has been backordered
                    l_backordered_qty := l_backordered_qty + l_temp_bo_qty ;
                 END IF;
                 --
             END IF;

             IF ( SIGN(l_last_day_of_period - TRUNC(ord.schedule_ship_date) ) = -1 )
             THEN
                 -- This is a future Order
                 l_future_order_qty := l_future_order_qty + ord.order_unit;
             END IF;

             IF ( SIGN(l_last_day_of_period - TRUNC(ord.schedule_ship_date) ) >= 0  )
             THEN
                 -- This Order is due in the current period
                 l_current_order_qty := l_current_order_qty + ord.order_unit;
             END IF;

            <<NEXT_ORDER>>
             NULL;
           END LOOP; -- open_orders_csr

      END LOOP; -- items_csr

      UPDATE ozf_cust_daily_facts
      SET  past_due_order_qty       = l_past_due_qty
          ,current_period_order_qty = l_current_order_qty
          ,backordered_qty          = l_backordered_qty
          ,booked_for_future_qty    = l_future_order_qty
      WHERE cust_daily_fact_id      = fact.cust_daily_fact_id;

   END LOOP;
   --
   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
END refresh_orders_info;

-- This function is used in DashboardAccountVO

FUNCTION get_cust_target ( p_party_id            IN NUMBER,
                           p_bill_to_site_use_id IN NUMBER,
                           p_site_use_id         IN NUMBER,
                           p_col                 IN VARCHAR2,
                           p_sales               IN NUMBER,
                           p_report_date         IN DATE,
                           p_resource_id         IN NUMBER )
RETURN NUMBER IS

  CURSOR cust_target_csr IS
   SELECT NVL( DECODE(p_col, 'YEAR_QUOTA', SUM(f.current_year_target),
                        'PERIOD_QUOTA', SUM(f.current_period_target),
                        'QTR_QUOTA', SUM(f.current_qtr_target) ) ,0)
   FROM ozf_cust_daily_facts f ,
        hz_cust_accounts h
   WHERE f.report_date = p_report_date
   AND   f.cust_account_id = h.cust_account_id
   AND   f.bill_to_site_use_id = NVL(p_bill_to_site_use_id, f.bill_to_site_use_id)
   AND   f.ship_to_site_use_id = NVL(p_site_use_id, f.ship_to_site_use_id)
   AND   h.party_id = p_party_id
   AND   f.product_attribute = 'OTHERS'
   AND  EXISTS ( SELECT 1
                  FROM ams_party_market_segments b,
                       jtf_terr_rsc_all a,
                       jtf_terr_rsc_access_all c
                  WHERE  b.market_qualifier_type = 'TERRITORY'
                  AND b.market_qualifier_reference = a.terr_id
                  AND a.resource_id = p_resource_id
                  --AND a.primary_contact_flag = 'Y'
                  AND a.terr_rsc_id = c.terr_rsc_id
                  AND c.access_type = 'OFFER'
                  AND c.trans_access_code = 'PRIMARY_CONTACT'
                  AND b.site_use_code = 'SHIP_TO'
                  AND b.site_use_id = f.ship_to_site_use_id) ;

l_return_value NUMBER := 0 ;

BEGIN

 OPEN cust_target_csr;
 FETCH cust_target_csr INTO l_return_value;
 CLOSE cust_target_csr;

 --Remove the calculation. This can be done in UI query
 /* IF ( p_col IN ('PCT_YEAR_MET', 'PCT_PERIOD_MET') )
 THEN
   IF (l_return_value) <> 0
   THEN
       l_return_value := ROUND((p_sales*100)/l_return_value ,2) ;
   END IF;
 END IF; */

 RETURN l_return_value;

EXCEPTION
WHEN OTHERS THEN
  l_return_value := 0;
  RETURN l_return_value;
END get_cust_target;



FUNCTION get_cust_target ( p_site_use_id IN NUMBER,
                           p_bill_to_site_use_id IN NUMBER,
                           p_period_type_id IN NUMBER ,
                           p_time_id IN NUMBER ,
                           p_report_date IN DATE)
RETURN NUMBER IS

-- One NVL if target record exists but with null value
-- Second NVL if no target records exist. Not sure if this can ever happen..

-- bill to site_use_id is never null in ozf_account_allocations
-- it will be -9996 if not available
-- so bill_to_site_use_id in ozf_cust_daily_facts will also be -9996

CURSOR target_csr IS
                SELECT NVL(SUM(NVL(c1.target,0)),0)
                  FROM ozf_account_allocations b1
                      ,ozf_time_allocations c1
                      ,ozf_funds_all_b d1
                  WHERE b1.allocation_for = 'FUND'
                  AND   b1.allocation_for_id   = d1.fund_id
                  AND   b1.site_use_id         = p_site_use_id
                  AND   b1.bill_to_site_use_id = p_bill_to_site_use_id
                  AND   c1.allocation_for      = 'CUST'
                  AND   c1.allocation_for_id   = b1.account_allocation_id
                  AND   c1.period_type_id      = p_period_type_id
                  AND   c1.time_id             = p_time_id
                  AND   d1.fund_type = 'QUOTA'
                  AND   d1.status_code <> 'CANCELLED'
                  AND   d1.parent_fund_id IS NOT NULL
                  -- AND   p_report_date BETWEEN d1.start_date_active AND d1.end_date_active
                  AND   NOT EXISTS ( SELECT 1
                                     FROM ozf_funds_all_b dd1
                                     WHERE dd1.parent_fund_id = d1.fund_id);

l_target NUMBER := 0;

BEGIN

OPEN target_csr ;
FETCH target_csr INTO l_target;
CLOSE target_csr;

RETURN l_target ;

EXCEPTION
  WHEN OTHERS THEN
      RETURN l_target ;
END get_cust_target;

PROCEDURE refresh_target_info(
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                     p_report_date   IN DATE,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) AS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'refresh_target_info';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   CURSOR daily_facts_csr IS
   SELECT cust_daily_fact_id,
          report_date,
          cust_account_id,
          ship_to_site_use_id,
          bill_to_site_use_id,
          product_attribute,
          product_attr_value
   FROM ozf_cust_daily_facts
   WHERE report_date =  p_report_date;

  -- The 'OTHERS' record will have the total customer target in cust_daily_facts
  -- remove p_report_date between start_date and end_date

  --   C1  P1      T1 100
  --               T2 150
  --       P2      T1 200
  --               T2 125
  --       OTHERS     575
  --   C1 will have targets from all products
  --   So C1 should always belong to only one leaf node territory with only
  --   one owner

  CURSOR target_csr (p_item_type           VARCHAR2,
                     p_item_id             NUMBER,
                     p_ship_to_site_use_id NUMBER,
                     p_bill_to_site_use_id NUMBER,
                     p_period_type_id      NUMBER,
                     p_time_id             NUMBER) IS
  SELECT SUM(
        DECODE( prod.item_type, 'OTHERS', ozf_cust_facts_pvt.get_cust_target (
                                                         cust.site_use_id,
                                                         cust.bill_to_site_use_id,
                                                         time.period_type_id ,
                                                         time.time_id,
                                                         p_report_date)
                                     , NVL(time.target,0) )
            )
  FROM ozf_account_allocations cust
      ,ozf_product_allocations prod
      ,ozf_time_allocations    time
      ,ozf_funds_all_b         quota
  WHERE
  --      Customer Filter
  --      cust.site_use_code       = 'SHIP_TO'
        cust.allocation_for      = 'FUND'
  AND   cust.allocation_for_id   = quota.fund_id
  AND   cust.site_use_id         = p_ship_to_site_use_id
  AND   cust.bill_to_site_use_id = p_bill_to_site_use_id
  -- Product Filter
  AND   prod.allocation_for        = 'CUST'
  AND   prod.allocation_for_id     = cust.account_allocation_id
  AND   prod.item_type             = p_item_type
  AND   prod.item_id               = p_item_id
  -- Time Filter
  AND   time.allocation_for    = 'PROD'
  AND   time.allocation_for_id = prod.product_allocation_id
  AND   time.period_type_id    = p_period_type_id
  AND   time.time_id           = p_time_id
  -- Cancelled Quota allocations must be ignored
  AND   quota.fund_type        =  'QUOTA'
  AND   quota.status_code      <> 'CANCELLED'
  -- This date filter must be removed because users can have quota for
  -- Q1, Q2, Q3, Q4 and in Q4 the total year quota
  -- must be the sum of all these quotas
  -- AND   p_report_date BETWEEN quota.start_date_active AND quota.end_date_active
  AND   quota.parent_fund_id   IS NOT NULL
  -- Pick only quotas for leaf nodes.
  -- This filter is not required since quotas are always generated for leaf nodes
  AND   NOT EXISTS ( SELECT 1
                     FROM  ozf_funds_all_b dd
                     WHERE  dd.parent_fund_id = quota.fund_id );

  CURSOR period_time_id_csr IS
  SELECT ent_period_id,
         ent_qtr_id,
         ent_year_id
  FROM ozf_time_day
  WHERE report_date = p_report_date;

  l_current_period_time_id NUMBER;
  l_current_qtr_time_id    NUMBER;
  l_current_year_time_id   NUMBER;

  l_current_period_target NUMBER;
  l_current_qtr_target    NUMBER;
  l_current_year_target   NUMBER;

  l_current_temp_qtr_target  NUMBER;
  l_current_temp_year_target NUMBER;

  CURSOR period_id_csr(p_qtr_id NUMBER) IS
  SELECT ent_period_id
  FROM   ozf_time_ent_period
  WHERE  ent_qtr_id = p_qtr_id;

  CURSOR qtr_id_csr(p_year_id NUMBER) IS
  SELECT ent_qtr_id
  FROM   ozf_time_ent_qtr
  WHERE  ent_year_id = p_year_id;

  CURSOR period_id_yr_csr(p_year_id NUMBER) IS
  SELECT ent_period_id
  FROM   ozf_time_ent_period
  WHERE  ent_year_id = p_year_id;

BEGIN

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
   --

   -- Updates the following columns
   --    current_period_target
   --    current_qtr_target
   --    current_year_target

   -- Pseudo code
   ---------------------------------------------
   -- Get current period_id, quarter_id, year_id
   -- We only support Month(32), Quarter(64) and Year Spreads(128)
   --
   -- Get target for current period
   --
   -- Get target for current quarter.
   -- IF no data found for quarter
   -- Then get it for all the months in a Quarter

   -- Get target for current year
   -- IF no data found for year
   -- Then get it for all Quarters in a Year
   -- IF still no data found
   -- Then get it for all months in a Year
   ----------------------------------------------

   -- Fetch current period, quarter,year time_ids
   OPEN period_time_id_csr;
   FETCH period_time_id_csr INTO l_current_period_time_id,
                                 l_current_qtr_time_id,
                                 l_current_year_time_id ;
   CLOSE period_time_id_csr;


   FOR fact IN daily_facts_csr
   LOOP
      --
      -- Get target for current period
      --

      OPEN target_csr (fact.product_attribute,
                       fact.product_attr_value,
                       fact.ship_to_site_use_id,
                       fact.bill_to_site_use_id,
                       32,
                       l_current_period_time_id);
      FETCH target_csr INTO l_current_period_target;
      CLOSE target_csr;

      --
      -- Get target for current quarter
      --
      OPEN target_csr (fact.product_attribute,
                       fact.product_attr_value,
                       fact.ship_to_site_use_id,
                       fact.bill_to_site_use_id,
                       64,
                       l_current_qtr_time_id);
      FETCH target_csr INTO l_current_qtr_target;
      CLOSE target_csr;

      IF l_current_qtr_target  IS NULL
      THEN
         -- Get sum of all periods in the quarter
         l_current_temp_qtr_target := 0;
         FOR period IN period_id_csr(l_current_qtr_time_id)
         LOOP
            --
            OPEN target_csr (fact.product_attribute,
                             fact.product_attr_value,
                             fact.ship_to_site_use_id,
                             fact.bill_to_site_use_id,
                             32,
                             period.ent_period_id);
            FETCH target_csr INTO l_current_temp_qtr_target;
            CLOSE target_csr;

            l_current_qtr_target :=  NVL(l_current_qtr_target,0)
                                   + NVL(l_current_temp_qtr_target,0);
            --
         END LOOP;
         --
      END IF;

      --
      -- Get target for current year
      --
      -- Targets available in months + Targets available in qtrs
      -- Targets cannot be allocated in Years ?

      l_current_temp_year_target := 0;
      -- Get all available targets in months for the current year
      FOR period IN period_id_yr_csr(l_current_year_time_id)
      LOOP
         OPEN target_csr (fact.product_attribute,
                          fact.product_attr_value,
                          fact.ship_to_site_use_id,
                          fact.bill_to_site_use_id,
                          32,
                          period.ent_period_id);
         FETCH target_csr INTO l_current_temp_year_target;
         CLOSE target_csr;
         l_current_year_target :=   NVL(l_current_year_target,0)
                                  + NVL(l_current_temp_year_target,0);
      END LOOP;


      -- Get all available targets in Quarters for the current year
      FOR qtr IN qtr_id_csr(l_current_year_time_id)
      LOOP
         OPEN target_csr (fact.product_attribute,
                          fact.product_attr_value,
                          fact.ship_to_site_use_id,
                          fact.bill_to_site_use_id,
                          64,
                          qtr.ent_qtr_id);
         FETCH target_csr INTO l_current_temp_year_target ;
         CLOSE target_csr;
         l_current_year_target :=  NVL(l_current_year_target,0)
                                 + NVL(l_current_temp_year_target,0);
      END LOOP;

      UPDATE ozf_cust_daily_facts
      SET  current_period_target = NVL(l_current_period_target,0)
          ,current_qtr_target    = l_current_qtr_target
          ,current_year_target   = l_current_year_target
      WHERE cust_daily_fact_id = fact.cust_daily_fact_id;

      l_current_period_target := NULL;
      l_current_qtr_target    := NULL;
      l_current_year_target   := NULL;

   END LOOP;
   --
   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
END refresh_target_info;



PROCEDURE insert_kpi(
                     p_resource_id           IN NUMBER,
                     p_report_date           IN DATE,
                     p_current_period_target IN NUMBER,
                     p_current_qtr_target    IN NUMBER,
                     p_current_year_target   IN NUMBER,
                     p_current_period_sales  IN NUMBER,
                     p_current_qtr_sales     IN NUMBER,
                     p_current_year_sales    IN NUMBER ) AS

   CURSOR period_name_csr IS
   SELECT ent_period_id,
          ozf_time_api_pvt.get_period_name(ent_period_id, 32) period_name,
          ent_qtr_id,
          ozf_time_api_pvt.get_period_name(ent_qtr_id, 64) qtr_name,
          ent_year_id,
          ozf_time_api_pvt.get_period_name(ent_year_id, 128) year_name
   FROM ozf_time_day
   WHERE report_date = p_report_date;

   l_kpi_rec_count   NUMBER;
   l_ent_period_id   NUMBER;
   l_ent_period_name VARCHAR2(100);
   l_ent_qtr_id      NUMBER;
   l_ent_qtr_name    VARCHAR2(100);
   l_ent_year_id     NUMBER;
   l_ent_year_name   VARCHAR2(100);

   l_period_type_id NUMBER;
   l_time_id        NUMBER;
   l_kpi_name       VARCHAR2(100);
   l_kpi_value      NUMBER;

   l_quota     VARCHAR2(100):= FND_MESSAGE.GET_STRING('OZF','OZF_DASHB_KPI_QUOTA');
   l_quota_met VARCHAR2(100):= FND_MESSAGE.GET_STRING('OZF','OZF_DASHB_KPI_QUOTA_MET');
   l_mtd_sales VARCHAR2(100):= FND_MESSAGE.GET_STRING('OZF','OZF_DASHB_KPI_MTD_SALES');
   l_qtd_sales VARCHAR2(100):= FND_MESSAGE.GET_STRING('OZF','OZF_DASHB_KPI_QTD_SALES');
   l_ytd_sales VARCHAR2(100):= FND_MESSAGE.GET_STRING('OZF','OZF_DASHB_KPI_YTD_SALES');

BEGIN

   ozf_utility_pvt.write_conc_log('Private API: ' || 'Insert_Kpi' || ' (-)') ;

   -- inanaiah: bug 4912723 - commented as deletion happens in refresh_kpi_info
   /*
   DELETE FROM ozf_dashb_daily_kpi
   WHERE report_date = p_report_date
   AND   resource_id = p_resource_id;
    */

   OPEN period_name_csr;
   FETCH period_name_csr INTO l_ent_period_id,
                              l_ent_period_name,
                              l_ent_qtr_id,
                              l_ent_qtr_name,
                              l_ent_year_id,
                              l_ent_year_name;
   CLOSE period_name_csr;

   ozf_utility_pvt.write_conc_log('-- p_resource_id            : '|| p_resource_id ) ;
   ozf_utility_pvt.write_conc_log('-- p_current_period_target  : '|| p_current_period_target ) ;
   ozf_utility_pvt.write_conc_log('-- p_current_qtr_target     : '|| p_current_qtr_target ) ;
   ozf_utility_pvt.write_conc_log('-- p_current_year_target    : '|| p_current_year_target ) ;
   ozf_utility_pvt.write_conc_log('-- p_current_period_sales   : '|| p_current_period_sales ) ;
   ozf_utility_pvt.write_conc_log('-- p_current_qtr_sales      : '|| p_current_qtr_sales ) ;
   ozf_utility_pvt.write_conc_log('-- p_current_year_sales     : '|| p_current_year_sales ) ;

   l_kpi_rec_count := 0;
   LOOP
        l_kpi_rec_count := l_kpi_rec_count + 1;
        IF l_kpi_rec_count > 9
        THEN
           EXIT;
        END IF;

        IF l_kpi_rec_count = 1
        THEN
            -- Period Quota
             l_kpi_name       := l_ent_period_name || ' '|| l_quota ;
             l_kpi_value      := NVL(p_current_period_target,0) ;
             l_period_type_id := 32 ;
             l_time_id        := l_ent_period_id ;
            --
        ELSIF l_kpi_rec_count = 2
        THEN
            -- Period Sales
             l_kpi_name       := l_mtd_sales ;
             l_kpi_value      := NVL(p_current_period_sales,0) ;
             l_period_type_id := 32 ;
             l_time_id        := l_ent_period_id ;
            --
        ELSIF l_kpi_rec_count = 3
        THEN
            -- % Period Quota Met
             l_kpi_name := l_ent_period_name|| ' ' || l_quota_met;
             IF NVL(p_current_period_target,0) > 0
             THEN
                 l_kpi_value :=  round((100*NVL(p_current_period_sales,0)/p_current_period_target),2) ;
             ELSE
                 l_kpi_value := 0;
             END IF;
             l_period_type_id := 32;
             l_time_id        := l_ent_period_id;
            --
        ELSIF l_kpi_rec_count = 4
        THEN
            -- Quarter Quota
             l_kpi_name       := l_ent_qtr_name || ' ' || l_Quota ;
             l_kpi_value      := NVL(p_current_qtr_target,0);
             l_period_type_id := 64;
             l_time_id        := l_ent_qtr_id;
            --
        ELSIF l_kpi_rec_count = 5
        THEN
            -- Quarter Sales
             l_kpi_name       := l_QTD_Sales;
             l_kpi_value      := NVL(p_current_qtr_sales,0) ;
             l_period_type_id := 64;
             l_time_id        := l_ent_qtr_id;
            --
        ELSIF l_kpi_rec_count = 6
        THEN
            -- Quarter Quota % Met
             l_kpi_name := l_ent_qtr_name || ' ' || l_Quota_Met;
             IF NVL(p_current_qtr_target,0) > 0
             THEN
                 l_kpi_value :=  round((100*NVL(p_current_qtr_sales,0)/p_current_qtr_target),2) ;
             ELSE
                 l_kpi_value := 0;
             END IF;
             l_period_type_id := 64;
             l_time_id        := l_ent_qtr_id;
            --
        ELSIF l_kpi_rec_count = 7
        THEN
            -- Year Quota
             l_kpi_name       := l_ent_year_name ||  ' ' || l_Quota;
             l_kpi_value      := NVL(p_current_year_target,0);
             l_period_type_id := 128;
             l_time_id        := l_ent_year_id;
            --
        ELSIF l_kpi_rec_count = 8
        THEN
            --
             l_kpi_name       := l_YTD_Sales;
             l_kpi_value      := NVL(p_current_year_sales,0);
             l_period_type_id := 128;
             l_time_id        := l_ent_year_id;
            --
        ELSIF l_kpi_rec_count = 9
        THEN
            --
             l_kpi_name := l_ent_year_name ||  ' ' || l_Quota_Met;
             IF NVL(p_current_year_target,0) > 0
             THEN
                 l_kpi_value :=  round((100*NVL(p_current_year_sales,0)/p_current_year_target),2) ;
             ELSE
                 l_kpi_value := 0;
             END IF;
             l_period_type_id := 128;
             l_time_id        := l_ent_year_id;
            --
        END IF;

        INSERT INTO ozf_dashb_daily_kpi(
                           dashb_daily_kpi_id,
                           report_date,
                           resource_id,
                           period_type_id,
                           time_id,
                           sequence_number,
                           kpi_name,
                           kpi_value )
        VALUES (ozf_dashb_daily_kpi_s.nextval,
                p_report_date,
                p_resource_id,
                l_period_type_id,
                l_time_id,
                l_kpi_rec_count,
                l_kpi_name,
                l_kpi_value );

    END LOOP;

   --
   ozf_utility_pvt.write_conc_log('Private API: ' || 'Insert_Kpi' || ' (+)');

END insert_kpi;


PROCEDURE refresh_kpi_info(
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                     p_report_date   IN DATE,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) AS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'refresh_target_info';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   -- Cursor to get all resources
   CURSOR active_resources_csr IS
   SELECT DISTINCT a.owner
   FROM ozf_funds_all_b a
   WHERE a.fund_type = 'QUOTA'
   AND   a.status_code <> 'CANCELLED' ;


 -- Get Time Level Target Allocation for all quotas of a user
  CURSOR target_for_quota_csr (  p_resource_id    NUMBER,
                                 p_period_type_id NUMBER,
                                 p_time_id        NUMBER ) IS
  SELECT SUM(b.target)
  FROM ozf_account_allocations a,
       ozf_time_allocations b
  WHERE
        b.allocation_for    = 'CUST'
  AND   b.allocation_for_id = a.account_allocation_id
  AND   b.period_type_id    = p_period_type_id
  AND   b.time_id           =  p_time_id
  AND   a.allocation_for    = 'FUND'
  AND   NVL(a.account_status, 'X') <> 'D'
 -- R12: Do not consider UnAllocated Rows
  AND   a.parent_party_id   <> -9999
  AND   a.allocation_for_id IN ( -- Get leaf node quotas for this resource owns
                                 SELECT aa.fund_id
                                 FROM   ozf_funds_all_b aa
                                 WHERE  aa.owner       = p_resource_id
                                 AND    aa.fund_type   = 'QUOTA'
                                 AND    aa.status_code <> 'CANCELLED'
                                 AND    NOT EXISTS ( SELECT 1
                                                     FROM  ozf_funds_all_b bb
                                                     WHERE bb.parent_fund_id = aa.fund_id )
                                 --
                                 UNION ALL -- Get all leaf node quotas in the hierarchy of this resource
                                 --
                                 SELECT aa.fund_id
                                 FROM   ozf_funds_all_b aa
                                 WHERE  aa.fund_type    = 'QUOTA'
                                 AND    aa.status_code  <> 'CANCELLED'
                                 CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
                                 START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                                                   FROM ozf_funds_all_b bb
                                                                   WHERE bb.owner       = p_resource_id
                                                                   AND   bb.fund_type   = 'QUOTA'
                                                                   AND   bb.status_code <> 'CANCELLED' )
                              );


 /*
  CURSOR sales_for_quota_csr( p_resource_id NUMBER,
                              p_report_date DATE) IS
  SELECT  SUM(fact.ptd_sales)                  MTD_SALES,
          SUM(fact.qtd_sales)                  QTD_SALES,
          SUM(fact.ytd_sales)                  YTD_SALES
  FROM ozf_cust_daily_facts fact,
        (
          SELECT DISTINCT c.site_use_id
          FROM jtf_terr_rsc_all b
              ,ams_party_market_segments c
          WHERE b.resource_id = p_resource_id
          AND b.primary_contact_flag = 'Y'
          AND c.market_qualifier_type = 'TERRITORY'
          AND c.market_qualifier_reference = b.terr_id
          AND c.site_use_code = 'SHIP_TO'
       ) site
   WHERE fact.report_date = p_report_date
   AND   fact.ship_to_site_use_id = site.site_use_id
   AND   fact.product_attribute <> 'OTHERS' ;
   */

  CURSOR sales_for_quota_csr(p_resource_id NUMBER,
                             p_report_date DATE) IS
  SELECT
          SUM(fact.ptd_sales)                  MTD_SALES,
          SUM(fact.qtd_sales)                  QTD_SALES,
          SUM(fact.ytd_sales)                  YTD_SALES
  FROM ozf_cust_daily_facts fact,
       ozf_account_allocations site,
       ozf_product_allocations prod
   WHERE fact.report_date = p_report_date
   AND   fact.ship_to_site_use_id = site.site_use_id
   AND   fact.product_attribute <> 'OTHERS'
   AND   fact.product_attribute = prod.item_type
   AND   fact.product_attr_value = prod.item_id
   AND   prod.allocation_for = 'CUST'
   AND   prod.allocation_for_id = site.account_allocation_id
   AND   site.allocation_for = 'FUND'
   AND   NVL(site.account_status, 'X') <> 'D'
 -- R12: Do not consider UnAllocated Rows
   AND   site.parent_party_id   <> -9999
   AND   site.allocation_for_id in (
                                 SELECT aa.fund_id
                                 FROM   ozf_funds_all_b aa
                                 WHERE  aa.owner       = p_resource_id
                                 AND    aa.fund_type   = 'QUOTA'
                                 AND    aa.status_code <> 'CANCELLED'
                                 AND    NOT EXISTS ( SELECT 1
                                                     FROM  ozf_funds_all_b bb
                                                     WHERE bb.parent_fund_id = aa.fund_id )
                                 --
                                 UNION ALL -- Get all leaf node quotas in the hierarchy of this resource
                                 --
                                 SELECT aa.fund_id
                                 FROM   ozf_funds_all_b aa
                                 WHERE  aa.fund_type    = 'QUOTA'
                                 AND    aa.status_code  <> 'CANCELLED'
                                 CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
                                 START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                                                   FROM ozf_funds_all_b bb
                                                                   WHERE bb.owner       = p_resource_id
                                                                   AND   bb.fund_type   = 'QUOTA'
                                                                   AND   bb.status_code <> 'CANCELLED' )
                                  ) ;



  -- Time Cursors

  -- Get Current period, quarter, year ids
  CURSOR period_time_id_csr IS
  SELECT ent_period_id,
         ent_qtr_id,
         ent_year_id
  FROM ozf_time_day
  WHERE report_date = p_report_date;

  -- Periods in a Quarter
  CURSOR period_id_csr(p_qtr_id NUMBER) IS
  SELECT ent_period_id
  FROM   ozf_time_ent_period
  WHERE  ent_qtr_id = p_qtr_id;

  -- Quarters in a Year
  CURSOR qtr_id_csr(p_year_id NUMBER) IS
  SELECT ent_qtr_id
  FROM   ozf_time_ent_qtr
  WHERE  ent_year_id = p_year_id;

  -- Periods in a Year
  CURSOR period_id_yr_csr(p_year_id NUMBER) IS
  SELECT ent_period_id
  FROM   ozf_time_ent_period
  WHERE  ent_year_id = p_year_id;

  l_current_period_time_id NUMBER;
  l_current_qtr_time_id    NUMBER;
  l_current_year_time_id   NUMBER;

  l_current_temp_qtr_target  NUMBER;
  l_current_temp_year_target NUMBER;

  l_current_period_target NUMBER;
  l_current_qtr_target    NUMBER;
  l_current_year_target   NUMBER;

  l_current_period_sales NUMBER;
  l_current_qtr_sales    NUMBER;
  l_current_year_sales   NUMBER;

BEGIN

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -- Fetch current periods

   OPEN period_time_id_csr;
   FETCH period_time_id_csr INTO l_current_period_time_id,
                                 l_current_qtr_time_id,
                                 l_current_year_time_id;
   CLOSE period_time_id_csr;

   -- inanaiah: bug 4912723 - delete all the records otherwise target info for cancelled quotas
   -- will exist in ozf_dashb_daily_kpi and thus get populated into OZF_RES_CUST_PROD_FACTS.
   -- Removed the deletion based on report_date and resource_id in insert_kpi proc.
   DELETE FROM ozf_dashb_daily_kpi
   WHERE report_date = p_report_date;

   -- Process KPI for each resource
   FOR res IN active_resources_csr
   LOOP
          --
          -- Fetch Quota Information for the User
          --
          l_current_period_target := 0;
          l_current_qtr_target    := 0;
          l_current_year_target   := 0;
          l_current_period_sales  := 0;
          l_current_qtr_sales     := 0;
          l_current_year_sales    := 0;

          -- Get any targets for the current time period
          OPEN target_for_quota_csr(res.owner,
                                    32,
                                    l_current_period_time_id);
          FETCH target_for_quota_csr INTO l_current_period_target;
          CLOSE target_for_quota_csr;

          -- Get any targets for the current quarter
          OPEN target_for_quota_csr(res.owner,
                                    64,
                                    l_current_qtr_time_id);
          FETCH target_for_quota_csr INTO l_current_qtr_target;
          CLOSE target_for_quota_csr;

          -- Check if targets exist for months in the current quarter and quarter itself
          -- This can be possible if a user has two quotas.
          -- One in Months, One in Quarter

          l_current_temp_qtr_target := 0;
          FOR period IN period_id_csr(l_current_qtr_time_id)
          LOOP
              OPEN target_for_quota_csr ( res.owner,
                                          32,
                                          period.ent_period_id);
              FETCH target_for_quota_csr INTO l_current_temp_qtr_target;
              CLOSE target_for_quota_csr;

              -- Consolidate the period target with quarter target, if any
              l_current_qtr_target :=  NVL(l_current_qtr_target,0)
                                     + NVL(l_current_temp_qtr_target,0);
          END LOOP;

          -- Get all available targets in months for the current year
          l_current_temp_year_target := 0;
          FOR period IN period_id_yr_csr(l_current_year_time_id)
          LOOP
              OPEN target_for_quota_csr (res.owner,
                                         32,
                                         period.ent_period_id);
              FETCH target_for_quota_csr INTO l_current_temp_year_target;
              CLOSE target_for_quota_csr;

              l_current_year_target :=   NVL(l_current_year_target,0)
                                       + NVL(l_current_temp_year_target,0);
           END LOOP;


           -- Get all available targets in Quarters for the current year
           FOR qtr IN qtr_id_csr(l_current_year_time_id)
           LOOP
                 OPEN target_for_quota_csr ( res.owner,
                                             64,
                                             qtr.ent_qtr_id);
                 FETCH target_for_quota_csr INTO l_current_temp_year_target ;
                 CLOSE target_for_quota_csr;

                 l_current_year_target :=  NVL(l_current_year_target,0)
                                         + NVL(l_current_temp_year_target,0);
           END LOOP;

          --
          --  Fetch Sales Information for the User
          --

          OPEN sales_for_quota_csr( res.owner,
                                    p_report_date);
          FETCH sales_for_quota_csr INTO l_current_period_sales,
                                         l_current_qtr_sales,
                                         l_current_year_sales;
          CLOSE sales_for_quota_csr;

          --
          -- Insert KPI data
          --

          insert_kpi ( res.owner,
                       p_report_date,
                       l_current_period_target,
                       l_current_qtr_target,
                       l_current_year_target,
                       l_current_period_sales,
                       l_current_qtr_sales,
                       l_current_year_sales);

   END LOOP; -- Process next resource

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

END refresh_kpi_info;


PROCEDURE update_sales_info(
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                     p_report_date   IN DATE,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) AS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'update_sales_info';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);


   CURSOR leaf_level_quotas_csr IS
   SELECT a.fund_id
   FROM   ozf_funds_all_b a
   WHERE  a.status_code = 'ACTIVE'
   AND    a.fund_type = 'QUOTA'
   -- and a.fund_id in ( 10746 , 10745)
   AND    NOT EXISTS ( SELECT 1
                       FROM ozf_funds_all_b b
                       WHERE b.parent_fund_id = a.fund_id);

   CURSOR quota_acct_allocs_csr (p_fund_id NUMBER) IS
   SELECT account_allocation_id,
          site_use_id
   FROM   ozf_account_allocations
   WHERE allocation_for = 'FUND'
   AND   allocation_for_id = p_fund_id
   AND   cust_account_id <> -9999;

   CURSOR acct_prod_allocs_csr ( p_account_allocation_id NUMBER) IS
   SELECT product_allocation_id,
          item_type,
          item_id
   FROM ozf_product_allocations
   WHERE allocation_for = 'CUST'
   AND allocation_for_id = p_account_allocation_id
   ORDER BY item_id DESC ;

   CURSOR prod_time_allocs_csr ( p_product_allocation_id  NUMBER) IS
   SELECT time_allocation_id,
          time_id,
          period_type_id
   FROM  ozf_time_allocations
   WHERE allocation_for = 'PROD'
   AND   allocation_for_id = p_product_allocation_id;

   CURSOR current_periods_csr IS
   SELECT ent_period_id,
          ent_qtr_id
   FROM ozf_time_day
   WHERE report_date = p_report_date;

   CURSOR sales_csr( p_time_id NUMBER,
                     p_site_use_id NUMBER,
                     p_inventory_item_id NUMBER ) IS
   SELECT NVL(SUM(sales),0)
   FROM ozf_order_sales_v
   WHERE time_id = p_time_id
   AND   ship_to_site_use_id = p_site_use_id
   AND   inventory_item_id = DECODE(p_inventory_item_id,-9999,inventory_item_id,p_inventory_item_id);

   CURSOR xtd_sales_csr ( p_record_type_id NUMBER,
                          p_site_use_id    NUMBER,
                          p_inventory_item_id NUMBER) IS
   SELECT NVL(SUM(sales),0)
   FROM  ozf_time_rpt_struct a,
         ozf_order_sales_v b
   WHERE a.report_date = p_report_date
   AND   BITAND(a.record_type_id, p_record_type_id) = a.record_type_id
   AND   a.time_id = b.time_id
   AND   b.ship_to_site_use_id = p_site_use_id
   AND   b.inventory_item_id   = DECODE(p_inventory_item_id,-9999, b.inventory_item_id,p_inventory_item_id);

   CURSOR items_csr (p_item_type VARCHAR2,
                     p_item_id   NUMBER) IS
   SELECT inventory_item_id
   FROM mtl_item_categories mtl,
        eni_prod_denorm_hrchy_v eni
   WHERE mtl.category_set_id  = eni.category_set_id
   AND mtl.category_id = eni.child_id
   AND mtl.organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
   AND eni.parent_id = p_item_id
   AND 'PRICING_ATTRIBUTE2' = p_item_type
   UNION ALL
   SELECT p_item_id inventory_item_id
   FROM dual
   WHERE 'PRICING_ATTRIBUTE1' = p_item_type
   UNION ALL
   SELECT p_item_id inventory_item_id
   FROM dual
   WHERE 'OTHERS' = p_item_type;

   CURSOR acct_time_sales_csr ( p_account_allocation_id NUMBER,
                                p_time_id NUMBER ) IS
   SELECT NVL(SUM(c.lysp_sales),0)
   FROM ozf_account_allocations a,
        ozf_product_allocations b,
        ozf_time_allocations c
   WHERE a.account_allocation_id = p_account_allocation_id
   AND   b.allocation_for = 'CUST'
   AND   b.allocation_for_id = a.account_allocation_id
   AND   b.item_type <> 'OTHERS'
   AND   c.allocation_for = 'PROD'
   AND   c.allocation_for_id = b.product_allocation_id
   AND   c.time_id = p_time_id;

   -- Local Variables

   l_current_period_id NUMBER;
   l_current_qtr_id    NUMBER;
   l_record_type_id    NUMBER;
   l_sales             NUMBER;
   l_item_sales        NUMBER;
   l_product_sales     NUMBER;
   l_acct_sales        NUMBER;
   l_quota_sales       NUMBER;
   l_acct_time_sales   NUMBER;

BEGIN
   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
   -- Package Body Start

   -- Get the current period and quarter's time_ids
   OPEN current_periods_csr;
   FETCH current_periods_csr INTO l_current_period_id, l_current_qtr_id;
   CLOSE current_periods_csr;

-- dbms_output.put_line(' p_report_date l_current_period_id , l_current_qtr_id '|| p_report_date || ' ' || l_current_period_id || ' ' || l_current_qtr_id);

   FOR quota IN leaf_level_quotas_csr
   LOOP
-- dbms_output.put_line(' fund_id '|| quota.fund_id );
       --
       l_quota_sales := 0;
       FOR acct IN quota_acct_allocs_csr (quota.fund_id)
       LOOP
           --
           l_acct_sales := 0;
           FOR prod IN acct_prod_allocs_csr (acct.account_allocation_id)
           LOOP
               --
               l_product_sales := 0;
               FOR time IN prod_time_allocs_csr(prod.product_allocation_id)
               LOOP

                   l_sales := 0;
                   l_item_sales := 0;

                   FOR i IN items_csr( prod.item_type, prod.item_id)
                   LOOP
                     --
                     -- Allocations can exist only for Periods and Quarters
                     -- If current, then sales in mv will not exist for the time_id
                     -- Instead, we need to XTD sales ie MTD or QTD sales
                     --

                     IF (
                         (time.period_type_id = 32 AND time.time_id = l_current_period_id)
                          OR
                         (time.period_type_id = 64 AND time.time_id = l_current_qtr_id)
                        )
                     THEN
                         --
                         -- Get XTD Sales for time_di
                         IF time.period_type_id = 32
                         THEN
                             l_record_type_id := 23;
                         ELSE
                             l_record_type_id := 55;
                         END IF;

                         OPEN xtd_sales_csr( l_record_type_id ,
                                             acct.site_use_id ,
                                             i.inventory_item_id );
                         FETCH xtd_sales_csr INTO l_item_sales;
                         CLOSE xtd_sales_csr;

                      ELSE
                         OPEN  sales_csr( time.time_id ,
                                          acct.site_use_id ,
                                          i.inventory_item_id );
                         FETCH sales_csr INTO l_item_sales;
                         CLOSE sales_csr;

                      END IF;
                      --
                      l_sales := l_sales + l_item_sales;
                      --
                      -- dbms_output.put_line('l_sales ' || time.time_id ||' ' || acct.site_use_id || ' ' || prod.item_id || ' ' || l_sales);
                   END LOOP; -- End items_csr

                   IF prod.item_type = 'OTHERS'
                   THEN

                      OPEN acct_time_sales_csr(acct.account_allocation_id,
                                               time.time_id);
                      FETCH acct_time_sales_csr INTO l_acct_time_sales;
                      CLOSE acct_time_sales_csr;

                      -- dbms_output.put_line('l_acct_time_sales ' ||  l_acct_time_sales);

                      l_sales := l_sales -  l_acct_time_sales;
                      -- dbms_output.put_line('l_sales for others '|| l_sales );

                   END IF;

                   UPDATE ozf_time_allocations
                   SET  lysp_sales = l_sales
                   WHERE time_allocation_id = time.time_allocation_id;

                   l_product_sales := l_product_sales + l_sales;

               END LOOP; -- End of prod_time_allocs_csr
               --
               UPDATE ozf_product_allocations
               SET lysp_sales = l_product_sales
               WHERE product_allocation_id = prod.product_allocation_id;

               l_acct_sales := l_acct_sales + l_product_sales;
               --
               -- dbms_output.put_line('l_product_sales '||  prod.product_allocation_id  || ' ' ||  l_product_sales);
           END LOOP; -- End of acct_prod_allocs_csr
           --
           UPDATE ozf_account_allocations
           SET lysp_sales = l_acct_sales
           WHERE account_allocation_id = acct.account_allocation_id;

           l_quota_sales := l_quota_sales + l_acct_sales;
           --
           -- dbms_output.put_line('l_acct_sales '||  acct.account_allocation_id || ' ' || l_acct_sales);
           -- Before moving to next acccout, update the time allocations
           -- for this account.

           UPDATE ozf_time_allocations c
           SET lysp_sales = ( SELECT sum(b.lysp_sales)
                              FROM ozf_product_allocations a,
                                   ozf_time_allocations b
                              WHERE a.allocation_for = 'CUST'
                              AND   a.allocation_for_id = acct.account_allocation_id
                              AND   b.allocation_for = 'PROD'
                              AND  b.allocation_for_id = a.product_allocation_id
                              AND   b.time_id = c.time_id )
           WHERE c.allocation_for = 'CUST'
           AND c.allocation_for_id = acct.account_allocation_id  ;


       END LOOP; -- End of quota_acct_allocs_csr
       --
       UPDATE ozf_funds_all_b
       SET utilized_amt =  l_quota_sales
       WHERE fund_id = quota.fund_id;
       --
       -- dbms_output.put_line('l_quota_sales '|| l_quota_sales);

   END LOOP; -- End of leaf_level_quotas_csr

   -- Now that all leaf level quotas have been proceesed, parents will be just rollups



   -- End Package Body
   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

END update_sales_info;


PROCEDURE update_quota_sales_info(
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                     p_report_date   IN DATE,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) AS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'update_quota_sales_info';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);


   CURSOR leaf_node_quotas_csr IS
   SELECT a.fund_id,
          start_date_active,
          end_date_active
   FROM ozf_funds_all_b a
   WHERE fund_type = 'QUOTA'
   AND   a.status_code  = 'ACTIVE'
   AND   NOT EXISTS ( SELECT 1
                      FROM ozf_funds_all_b b
                      WHERE b.parent_fund_id = a.fund_id );

   CURSOR parent_quotas_csr IS
   SELECT a.fund_id,
          start_date_active,
          end_date_active
   FROM ozf_funds_all_b a
   WHERE fund_type = 'QUOTA'
   AND   status_code = 'ACTIVE'
   AND   EXISTS ( SELECT 1
                  FROM ozf_funds_all_b b
                  WHERE b.parent_fund_id = a.fund_id );

   CURSOR all_leaf_node_quotas_csr( p_fund_id NUMBER ) IS
   SELECT a.fund_id,
          NVL(a.utilized_amt,0) utilized_amt
   FROM    ozf_funds_all_b a
   WHERE   NOT EXISTS ( SELECT 'x'
                        FROM ozf_funds_all_b b
                        WHERE b.parent_fund_id = a.fund_id
                        AND b.status_code = 'ACTIVE' )
   AND  a.status_code = 'ACTIVE'
   CONNECT BY PRIOR a.fund_id = a.parent_fund_id
   START WITH a.parent_fund_id = p_fund_id;


   CURSOR xtd_sales_csr (p_fund_id    NUMBER,
                         p_as_of_date DATE )
   IS
   SELECT  NVL(SUM(b.sales),0) tot_sales
   FROM ozf_time_rpt_struct a,
        ozf_order_sales_v b,
        ozf_account_allocations c
   WHERE c.allocation_for = 'FUND'
   AND   c.allocation_for_id = p_fund_id
   AND   b.ship_to_site_use_id = c.site_use_id
   AND   b.time_id = a.time_id
   AND a.report_date = p_as_of_date
   AND BITAND(a.record_type_id, 119) = a.record_type_id ;

   l_xtd_end_date   NUMBER;
   l_xtd_start_date NUMBER;

   l_parent_quota_sales     NUMBER;
   l_tot_parent_quota_sales NUMBER;

BEGIN
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      FND_MSG_PUB.initialize;

      -- Debug Message
      ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' (-)');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Procedure body start
      FOR quota IN leaf_node_quotas_csr
      LOOP

         OPEN  xtd_sales_csr ( quota.fund_id, quota.end_date_active );
         FETCH xtd_sales_csr INTO l_xtd_end_date ;
         CLOSE xtd_sales_csr ;

         OPEN xtd_sales_csr ( quota.fund_id, quota.start_date_active );
         FETCH xtd_sales_csr INTO l_xtd_start_date ;
         CLOSE xtd_sales_csr;

         IF (l_xtd_end_date > l_xtd_start_date )
         THEN
               UPDATE ozf_funds_all_b
               SET    utilized_amt = (l_xtd_end_date - l_xtd_start_date )
               WHERE fund_id = quota.fund_id ;
         END IF;

      END LOOP; -- End of leaf_node_quotas_csr

      -- Now update all parent quota sales as sum of all leaf level quotas for each parent

      FOR quota IN parent_quotas_csr
      LOOP

           l_parent_quota_sales := 0;

           FOR i IN all_leaf_node_quotas_csr(quota.fund_id)
           LOOP
                l_parent_quota_sales := l_parent_quota_sales + i.utilized_amt ;
           END LOOP;

           UPDATE ozf_funds_all_b
           SET utilized_amt = l_parent_quota_sales
           WHERE fund_id = quota.fund_id;

      END LOOP; -- End of parent_quotas_csr

      -- Procedure body end
      ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

END update_quota_sales_info;

 -- Added in R12 - Used to populate the OZF_RES_CUST_PROD_FACTS table
 PROCEDURE populate_res_cust_prod_facts (
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                     p_report_date   IN DATE,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) AS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'populate_res_cust_prod_facts';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

  BEGIN

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   DELETE FROM OZF_RES_CUST_PROD_FACTS
   WHERE report_date = p_report_date;

   INSERT INTO OZF_RES_CUST_PROD_FACTS
   (SELECT OZF.OZF_RES_CUST_PROD_FACTS_S.nextval,
    resource_id,
    report_date,
    fact_row_for,
    party_id,
    cust_account_id,
    bill_to_site_use_id,
    ship_to_site_use_id,
    product_attribute,
    product_attr_value,
    ptd_sales,
    qtd_sales,
    ytd_sales,
    lptd_sales,
    lqtd_sales,
    lytd_sales,
    lysp_sales,
    lysq_sales,
    ly_sales,
    period_quota,
    qtr_quota,
    year_quota,
    mtd_basesales,
    qtd_basesales,
    ytd_basesales,
    outstanding_orders,
    current_orders,
    back_orders,
    future_orders,
    tot_ship_psbl_peroid,
    ytd_fund_utilized,
    ytd_fund_earned,
    ytd_fund_paid,
    qtd_fund_utilized,
    qtd_fund_earned,
    qtd_fund_paid,
    mtd_fund_utilized,
    mtd_fund_earned,
    mtd_fund_paid,
    fund_unpaid,
    open_claims,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
   FROM
   ----FOR PARTY ---
   (SELECT
    kpi.resource_id resource_id,
    c.report_date report_date,
    'PARTY' FACT_ROW_FOR,
    x.party_id party_id,
    NULL CUST_ACCOUNT_ID,
    NULL BILL_TO_SITE_USE_ID,
    NULL SHIP_TO_SITE_USE_ID,
    NULL PRODUCT_ATTRIBUTE,
    NULL PRODUCT_ATTR_VALUE,
    SUM(ptd_sales) PTD_SALES,
    SUM(qtd_sales)  QTD_SALES,
    SUM(ytd_sales)  YTD_SALES,
    SUM(lysp_sales) LPTD_SALES,
    SUM(lqtd_sales) LQTD_SALES,
    SUM(lytd_sales) LYTD_SALES,
    SUM(lysp_sales)  LYSP_SALES,
    SUM(lysq_sales)  LYSQ_SALES,
    SUM(ly_sales)  LY_SALES,
    0 PERIOD_QUOTA,
    0 QTR_QUOTA,
    0 YEAR_QUOTA,
    SUM(mtd_basesales) MTD_BASESALES,
    SUM(qtd_basesales) QTD_BASESALES,
    SUM(ytd_basesales) YTD_BASESALES,
    SUM(past_due_order_qty)         OUTSTANDING_ORDERS,
    SUM(current_period_order_qty)   CURRENT_ORDERS,
    SUM(backordered_qty)            BACK_ORDERS,
    SUM(booked_for_future_qty)      FUTURE_ORDERS,
    SUM(ptd_sales)+SUM(past_due_order_qty)+SUM(current_period_order_qty)+SUM(backordered_qty) TOT_SHIP_PSBL_PEROID,
    SUM(YTD_FUND_UTILIZED) YTD_FUND_UTILIZED,
    SUM(YTD_FUND_EARNED) YTD_FUND_EARNED,
    SUM(YTD_FUND_PAID) YTD_FUND_PAID,
    SUM(QTD_FUND_UTILIZED) QTD_FUND_UTILIZED,
    SUM(QTD_FUND_EARNED) QTD_FUND_EARNED,
    SUM(QTD_FUND_PAID) QTD_FUND_PAID,
    SUM(MTD_FUND_UTILIZED) MTD_FUND_UTILIZED,
    SUM(MTD_FUND_EARNED) MTD_FUND_EARNED,
    SUM(MTD_FUND_PAID) MTD_FUND_PAID,
    SUM(FUND_UNPAID) FUND_UNPAID,
    SUM(OPEN_CLAIMS) OPEN_CLAIMS,
    sysdate  CREATION_DATE,
    -1  CREATED_BY,
    sysdate  LAST_UPDATE_DATE,
    -1  LAST_UPDATED_BY,
    -1  LAST_UPDATE_LOGIN
    FROM ozf_cust_daily_facts c,
         hz_cust_accounts x,
         ozf_dashb_daily_kpi kpi,
      (SELECT DISTINCT a.owner
       FROM ozf_funds_all_b a
       WHERE a.fund_type = 'QUOTA'
       AND   a.status_code <> 'CANCELLED') fund
    WHERE c.cust_account_id = x.cust_account_id
    AND   c.product_attribute <> 'OTHERS'
    AND  kpi.resource_id = fund.owner
    AND  kpi.sequence_number = 1
    AND  Kpi.report_date = c.report_date
    AND EXISTS (
      SELECT 1
      FROM ozf_account_allocations acct,
           ozf_product_allocations prod
      WHERE acct.site_use_id = c.ship_to_site_use_id
      AND   prod.item_type = c.product_attribute
      AND   prod.item_id = c.product_attr_value
      AND   prod.allocation_for = 'CUST'
      AND   prod.allocation_for_id = acct.account_allocation_id
      AND   acct.allocation_for = 'FUND'
      AND   acct.allocation_for_id in
           (SELECT aa.fund_id
            FROM   ozf_funds_all_b aa
            WHERE  aa.owner       = kpi.resource_id
            AND    aa.fund_type   = 'QUOTA'
            AND    aa.status_code <> 'CANCELLED'
            AND    NOT EXISTS ( SELECT 1
                                FROM  ozf_funds_all_b bb
                                WHERE bb.parent_fund_id = aa.fund_id )
            UNION ALL
            SELECT aa.fund_id
            FROM   ozf_funds_all_b aa
            WHERE  aa.fund_type    = 'QUOTA'
            AND    aa.status_code  <> 'CANCELLED'
            CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
            START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                              FROM ozf_funds_all_b bb
                                              WHERE bb.owner       = kpi.resource_id
                                              AND   bb.fund_type   = 'QUOTA'
                                              AND   bb.status_code <> 'CANCELLED')
            ))
    AND c.report_date = p_report_date
    AND fund.owner = kpi.resource_id
    GROUP BY
    kpi.resource_id,
    c.report_date,
    'PARTY',
    x.party_id

    UNION ALL

    --- FOR BILL_TO----

    SELECT
    kpi.resource_id resource_id,
    c.report_date report_date,
    'BILL_TO' FACT_ROW_FOR,
    x.party_id party_id,
    c.CUST_ACCOUNT_ID CUST_ACCOUNT_ID,
    c.bill_to_site_use_id BILL_TO_SITE_USE_ID,
    0 SHIP_TO_SITE_USE_ID,
    NULL PRODUCT_ATTRIBUTE,
    NULL PRODUCT_ATTR_VALUE,
    SUM(ptd_sales) PTD_SALES,
    SUM(qtd_sales)  QTD_SALES,
    SUM(ytd_sales)  YTD_SALES,
    SUM(lysp_sales) LPTD_SALES,
    SUM(lqtd_sales) LQTD_SALES,
    SUM(lytd_sales) LYTD_SALES,
    SUM(lysp_sales)  LYSP_SALES,
    SUM(lysq_sales)  LYSQ_SALES,
    SUM(ly_sales)  LY_SALES,
    0 PERIOD_QUOTA,
    0 QTR_QUOTA,
    0 YEAR_QUOTA,
    SUM(mtd_basesales) MTD_BASESALES,
    SUM(qtd_basesales) QTD_BASESALES,
    SUM(ytd_basesales) YTD_BASESALES,
    SUM(past_due_order_qty)         OUTSTANDING_ORDERS,
    SUM(current_period_order_qty)   CURRENT_ORDERS,
    SUM(backordered_qty)            BACK_ORDERS,
    SUM(booked_for_future_qty)      FUTURE_ORDERS,
    SUM(ptd_sales)+SUM(past_due_order_qty)+SUM(current_period_order_qty)+SUM(backordered_qty) TOT_SHIP_PSBL_PEROID,
    SUM(YTD_FUND_UTILIZED) YTD_FUND_UTILIZED,
    SUM(YTD_FUND_EARNED) YTD_FUND_EARNED,
    SUM(YTD_FUND_PAID) YTD_FUND_PAID,
    SUM(QTD_FUND_UTILIZED) QTD_FUND_UTILIZED,
    SUM(QTD_FUND_EARNED) QTD_FUND_EARNED,
    SUM(QTD_FUND_PAID) QTD_FUND_PAID,
    SUM(MTD_FUND_UTILIZED) MTD_FUND_UTILIZED,
    SUM(MTD_FUND_EARNED) MTD_FUND_EARNED,
    SUM(MTD_FUND_PAID) MTD_FUND_PAID,
    SUM(FUND_UNPAID) FUND_UNPAID,
    SUM(OPEN_CLAIMS) OPEN_CLAIMS,
    sysdate  CREATION_DATE,
    -1  CREATED_BY,
    sysdate  LAST_UPDATE_DATE,
    -1  LAST_UPDATED_BY,
    -1  LAST_UPDATE_LOGIN
    FROM ozf_cust_daily_facts c,
         hz_cust_accounts x,
         ozf_dashb_daily_kpi kpi,
      (SELECT DISTINCT a.owner
       FROM ozf_funds_all_b a
       WHERE a.fund_type = 'QUOTA'
       AND   a.status_code <> 'CANCELLED') fund
    WHERE c.cust_account_id = x.cust_account_id
    AND   c.product_attribute <> 'OTHERS'
    AND  kpi.resource_id = fund.owner
    AND  kpi.sequence_number = 1
    AND  Kpi.report_date = c.report_date
    AND EXISTS (
      SELECT 1
      FROM ozf_account_allocations acct,
           ozf_product_allocations prod
      WHERE acct.site_use_id = c.ship_to_site_use_id
      AND   prod.item_type = c.product_attribute
      AND   prod.item_id = c.product_attr_value
      AND   prod.allocation_for = 'CUST'
      AND   prod.allocation_for_id = acct.account_allocation_id
      AND   acct.allocation_for = 'FUND'
      AND   acct.allocation_for_id in
           (SELECT aa.fund_id
            FROM   ozf_funds_all_b aa
            WHERE  aa.owner       = kpi.resource_id
            AND    aa.fund_type   = 'QUOTA'
            AND    aa.status_code <> 'CANCELLED'
            AND    NOT EXISTS ( SELECT 1
                                FROM  ozf_funds_all_b bb
                                WHERE bb.parent_fund_id = aa.fund_id )
            UNION ALL
            SELECT aa.fund_id
            FROM   ozf_funds_all_b aa
            WHERE  aa.fund_type    = 'QUOTA'
            AND    aa.status_code  <> 'CANCELLED'
            CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
            START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                              FROM ozf_funds_all_b bb
                                              WHERE bb.owner       = kpi.resource_id
                                              AND   bb.fund_type   = 'QUOTA'
                                              AND   bb.status_code <> 'CANCELLED')
            ))
    AND c.report_date = p_report_date
    AND fund.owner = kpi.resource_id
    GROUP BY
    kpi.resource_id,
    c.report_date,
    'BILL_TO',
    x.party_id,
    c.CUST_ACCOUNT_ID,
    c.bill_to_site_use_id

    UNION ALL
    --- FOR SHIP_TO----
    SELECT
    kpi.resource_id resource_id,
    c.report_date report_date,
    'SHIP_TO' FACT_ROW_FOR,
    x.party_id party_id,
    c.CUST_ACCOUNT_ID CUST_ACCOUNT_ID,
    c.bill_to_site_use_id BILL_TO_SITE_USE_ID,
    c.ship_to_site_use_id SHIP_TO_SITE_USE_ID,
    NULL PRODUCT_ATTRIBUTE,
    NULL PRODUCT_ATTR_VALUE,
    SUM(ptd_sales) PTD_SALES,
    SUM(qtd_sales)  QTD_SALES,
    SUM(ytd_sales)  YTD_SALES,
    SUM(lysp_sales) LPTD_SALES,
    SUM(lqtd_sales) LQTD_SALES,
    SUM(lytd_sales) LYTD_SALES,
    SUM(lysp_sales)  LYSP_SALES,
    SUM(lysq_sales)  LYSQ_SALES,
    SUM(ly_sales)  LY_SALES,
    0 PERIOD_QUOTA,
    0 QTR_QUOTA,
    0 YEAR_QUOTA,
    SUM(mtd_basesales) MTD_BASESALES,
    SUM(qtd_basesales) QTD_BASESALES,
    SUM(ytd_basesales) YTD_BASESALES,
    SUM(past_due_order_qty)         OUTSTANDING_ORDERS,
    SUM(current_period_order_qty)   CURRENT_ORDERS,
    SUM(backordered_qty)            BACK_ORDERS,
    SUM(booked_for_future_qty)      FUTURE_ORDERS,
    SUM(ptd_sales)+SUM(past_due_order_qty)+SUM(current_period_order_qty)+SUM(backordered_qty) TOT_SHIP_PSBL_PEROID,
    SUM(YTD_FUND_UTILIZED) YTD_FUND_UTILIZED,
    SUM(YTD_FUND_EARNED) YTD_FUND_EARNED,
    SUM(YTD_FUND_PAID) YTD_FUND_PAID,
    SUM(QTD_FUND_UTILIZED) QTD_FUND_UTILIZED,
    SUM(QTD_FUND_EARNED) QTD_FUND_EARNED,
    SUM(QTD_FUND_PAID) QTD_FUND_PAID,
    SUM(MTD_FUND_UTILIZED) MTD_FUND_UTILIZED,
    SUM(MTD_FUND_EARNED) MTD_FUND_EARNED,
    SUM(MTD_FUND_PAID) MTD_FUND_PAID,
    SUM(FUND_UNPAID) FUND_UNPAID,
    SUM(OPEN_CLAIMS) OPEN_CLAIMS,
    sysdate  CREATION_DATE,
    -1  CREATED_BY,
    sysdate  LAST_UPDATE_DATE,
    -1  LAST_UPDATED_BY,
    -1  LAST_UPDATE_LOGIN
    FROM ozf_cust_daily_facts c,
         hz_cust_accounts x,
         ozf_dashb_daily_kpi kpi,
      (SELECT DISTINCT a.owner
       FROM ozf_funds_all_b a
       WHERE a.fund_type = 'QUOTA'
       AND   a.status_code <> 'CANCELLED') fund
    WHERE c.cust_account_id = x.cust_account_id
    AND   c.product_attribute <> 'OTHERS'
    AND  kpi.resource_id = fund.owner
    AND  kpi.sequence_number = 1
    AND  Kpi.report_date = c.report_date
    AND EXISTS (
      SELECT 1
      FROM ozf_account_allocations acct,
           ozf_product_allocations prod
      WHERE acct.site_use_id = c.ship_to_site_use_id
      AND   prod.item_type = c.product_attribute
      AND   prod.item_id = c.product_attr_value
      AND   prod.allocation_for = 'CUST'
      AND   prod.allocation_for_id = acct.account_allocation_id
      AND   acct.allocation_for = 'FUND'
      AND   acct.allocation_for_id in
           (SELECT aa.fund_id
            FROM   ozf_funds_all_b aa
            WHERE  aa.owner       = kpi.resource_id
            AND    aa.fund_type   = 'QUOTA'
            AND    aa.status_code <> 'CANCELLED'
            AND    NOT EXISTS ( SELECT 1
                                FROM  ozf_funds_all_b bb
                                WHERE bb.parent_fund_id = aa.fund_id )
            UNION ALL
            SELECT aa.fund_id
            FROM   ozf_funds_all_b aa
            WHERE  aa.fund_type    = 'QUOTA'
            AND    aa.status_code  <> 'CANCELLED'
            CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
            START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                              FROM ozf_funds_all_b bb
                                              WHERE bb.owner       = kpi.resource_id
                                              AND   bb.fund_type   = 'QUOTA'
                                              AND   bb.status_code <> 'CANCELLED')
            ))
    AND c.report_date = p_report_date
    AND fund.owner = kpi.resource_id
    GROUP BY
    kpi.resource_id,
    c.report_date,
    'SHIP_TO',
    x.party_id,
    c.CUST_ACCOUNT_ID,
    c.bill_to_site_use_id,
    c.ship_to_site_use_id

    UNION ALL
    --- FOR PRODUCT----
    SELECT
    kpi.resource_id resource_id,
     c.report_date report_date,
     'PRODUCT' FACT_ROW_FOR,
     0 party_id,
     0 CUST_ACCOUNT_ID,
     0 BILL_TO_SITE_USE_ID,
     0 SHIP_TO_SITE_USE_ID,
    c.product_attribute PRODUCT_ATTRIBUTE,
    c.product_attr_value PRODUCT_ATTR_VALUE,
    SUM(ptd_sales) PTD_SALES,
    SUM(qtd_sales)  QTD_SALES,
    SUM(ytd_sales)  YTD_SALES,
    SUM(lysp_sales) LPTD_SALES,
    SUM(lqtd_sales) LQTD_SALES,
    SUM(lytd_sales) LYTD_SALES,
    SUM(lysp_sales)  LYSP_SALES,
    SUM(lysq_sales)  LYSQ_SALES,
    SUM(ly_sales)  LY_SALES,
    SUM(current_period_target)      PERIOD_QUOTA,
    SUM(current_qtr_target) QTR_QUOTA,
    SUM(current_year_target)        YEAR_QUOTA,
    SUM(mtd_basesales) MTD_BASESALES,
    SUM(qtd_basesales) QTD_BASESALES,
    SUM(ytd_basesales) YTD_BASESALES,
    SUM(past_due_order_qty)         OUTSTANDING_ORDERS,
    SUM(current_period_order_qty)   CURRENT_ORDERS,
    SUM(backordered_qty)            BACK_ORDERS,
    SUM(booked_for_future_qty)      FUTURE_ORDERS,
    SUM(ptd_sales)+SUM(past_due_order_qty)+SUM(current_period_order_qty)+SUM(backordered_qty) TOT_SHIP_PSBL_PEROID,
    SUM(YTD_FUND_UTILIZED) YTD_FUND_UTILIZED,
    SUM(YTD_FUND_EARNED) YTD_FUND_EARNED,
    SUM(YTD_FUND_PAID) YTD_FUND_PAID,
    SUM(QTD_FUND_UTILIZED) QTD_FUND_UTILIZED,
    SUM(QTD_FUND_EARNED) QTD_FUND_EARNED,
    SUM(QTD_FUND_PAID) QTD_FUND_PAID,
    SUM(MTD_FUND_UTILIZED) MTD_FUND_UTILIZED,
    SUM(MTD_FUND_EARNED) MTD_FUND_EARNED,
    SUM(MTD_FUND_PAID) MTD_FUND_PAID,
    SUM(FUND_UNPAID) FUND_UNPAID,
    SUM(OPEN_CLAIMS) OPEN_CLAIMS,
    sysdate  CREATION_DATE,
    -1  CREATED_BY,
    sysdate  LAST_UPDATE_DATE,
    -1  LAST_UPDATED_BY,
    -1  LAST_UPDATE_LOGIN
    FROM ozf_cust_daily_facts c ,
         ozf_dashb_daily_kpi kpi,
      (SELECT DISTINCT a.owner
       FROM ozf_funds_all_b a
       WHERE a.fund_type = 'QUOTA'
       AND   a.status_code <> 'CANCELLED') fund
    WHERE
          kpi.sequence_number = 1
    AND   kpi.report_date = c.report_date
    AND   c.product_attribute <> 'OTHERS'
    AND EXISTS (
      SELECT 1
      FROM ozf_account_allocations acct,
           ozf_product_allocations prod
      WHERE acct.site_use_id = c.ship_to_site_use_id
      AND   prod.item_type = c.product_attribute
      AND   prod.item_id = c.product_attr_value
      AND   prod.allocation_for = 'CUST'
      AND   prod.allocation_for_id = acct.account_allocation_id
      AND   acct.allocation_for = 'FUND'
      AND   acct.allocation_for_id in
           (SELECT aa.fund_id
            FROM   ozf_funds_all_b aa
            WHERE  aa.owner       = kpi.resource_id
            AND    aa.fund_type   = 'QUOTA'
            AND    aa.status_code <> 'CANCELLED'
            AND    NOT EXISTS ( SELECT 1
                                FROM  ozf_funds_all_b bb
                                WHERE bb.parent_fund_id = aa.fund_id )
            UNION ALL
            SELECT aa.fund_id
            FROM   ozf_funds_all_b aa
            WHERE  aa.fund_type    = 'QUOTA'
            AND    aa.status_code  <> 'CANCELLED'
            CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
            START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                              FROM ozf_funds_all_b bb
                                              WHERE bb.owner       = kpi.resource_id
                                              AND   bb.fund_type   = 'QUOTA'
                                              AND   bb.status_code <> 'CANCELLED')
            ))
    AND c.report_date = p_report_date
    AND fund.owner = kpi.resource_id
    GROUP BY
    kpi.resource_id,
    c.report_date,
    'PRODUCT',
    c.product_attribute,
    c.product_attr_value)
  );

    -- inanaiah: updating PERIOD_QUOTA, QTR_QUOTA, YEAR_QUOTA that was set to 0
    -- in the above insert stmt. This is done as part of bug 4887783 fix.

    -- PARTY
    UPDATE ozf_res_cust_prod_facts outer
    Set (PERIOD_QUOTA, QTR_QUOTA, YEAR_QUOTA)
    =
    (
        SELECT
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, NULL, NULL,
                                               'PERIOD_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) PERIOD_QUOTA,
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, NULL, NULL,
                                               'QTR_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) QTR_QUOTA,
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, NULL, NULL,
                                               'YEAR_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) YEAR_QUOTA
        FROM dual
    )
    WHERE outer.fact_row_for = 'PARTY'
    AND outer.report_date = p_report_date;

    -- BILL_TO
    UPDATE ozf_res_cust_prod_facts outer
    Set (PERIOD_QUOTA, QTR_QUOTA, YEAR_QUOTA)
    =
    (
        SELECT
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, outer.bill_to_site_use_id,
                                               NULL, 'PERIOD_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) PERIOD_QUOTA,
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, outer.bill_to_site_use_id,
                                               NULL, 'QTR_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) QTR_QUOTA,
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, outer.bill_to_site_use_id,
                                               NULL, 'YEAR_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) YEAR_QUOTA
        FROM dual
    )
    WHERE outer.fact_row_for = 'BILL_TO'
    AND outer.report_date = p_report_date;

    -- SHIP_TO
    UPDATE ozf_res_cust_prod_facts outer
    Set (PERIOD_QUOTA, QTR_QUOTA, YEAR_QUOTA)
    =
    (
        SELECT
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, outer.bill_to_site_use_id,
                                               outer.ship_to_site_use_id, 'PERIOD_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) PERIOD_QUOTA,
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, outer.bill_to_site_use_id,
                                               outer.ship_to_site_use_id, 'QTR_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) QTR_QUOTA,
            ozf_cust_facts_pvt.get_cust_target( outer.party_id, outer.bill_to_site_use_id,
                                               outer.ship_to_site_use_id, 'YEAR_QUOTA', 0,
                                               outer.report_date,outer.resource_id
                                             ) YEAR_QUOTA
        FROM dual
    )
    WHERE outer.fact_row_for = 'SHIP_TO'
    AND outer.report_date = p_report_date;

  ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
  END populate_res_cust_prod_facts;

  -- for R12, proc to get the budget and claims info and update the ozf_res_cust_prod_facts
  PROCEDURE refresh_budget_and_claims_info (
       p_api_version   IN NUMBER,
                         p_init_msg_list IN VARCHAR2  := FND_API.g_false,
                         p_report_date   IN DATE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2) AS
       l_api_version   CONSTANT NUMBER       := 1.0;
       l_api_name      CONSTANT VARCHAR2(30) := 'refresh_budget_and_claims_info';
       l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
       l_return_status          VARCHAR2(1);

    BEGIN

       ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

       IF FND_API.to_boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;

       IF NOT FND_API.compatible_api_call(l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name)
       THEN
         RAISE FND_API.g_exc_unexpected_error;
       END IF;
       x_return_status := FND_API.g_ret_sts_success;

    --YTD budget amounts for 'PARTY'
    UPDATE ozf_res_cust_prod_facts outer
      Set (YTD_FUND_utilized, YTD_FUND_earned, YTD_FUND_paid)
     =
     (
       SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
       ozf_cust_fund_summary_mv b,
       ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
       AND a.report_date = outer.report_date
       AND a.ent_year_id = b.time_id
       AND b.status_code = 'ACTIVE'
       AND b.party_id = outer.party_id
       AND b.party_id = c.party_id
       AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
       AND
       (
        (
         b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
         AND b.product_id = c.product_attr_value
        )
        OR
        (
         b.product_level_type IS NULL
         AND b.product_id IS NULL
         AND EXISTS (SELECT 'X'
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id)
        )
      )
    )
    WHERE outer.fact_row_for = 'PARTY'
    AND outer.report_date = p_report_date ;

    --YTD amounts for 'BILL_TO'
    Update ozf_res_cust_prod_facts outer
      Set (YTD_FUND_utilized, YTD_FUND_earned, YTD_FUND_paid)
     =
     (
       SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
       ozf_cust_fund_summary_mv b,
       ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_year_id = b.time_id
       AND b.status_code = 'ACTIVE'
       AND b.party_id = outer.party_id
       AND b.party_id = c.party_id
       AND b.bill_to_site_use_id = outer.bill_to_site_use_id
       AND b.bill_to_site_use_id = c.bill_to_site_use_id
      AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
       AND
       (
        (
         b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
         AND b.product_id = c.product_attr_value
        )
        OR
        (
         b.product_level_type IS NULL
         AND b.product_id IS NULL
         AND EXISTS (SELECT 'X'
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id)
        )
      )
    )
    WHERE outer.fact_row_for = 'BILL_TO'
    AND outer.report_date = p_report_date ;

    --YTD amounts for 'SHIP_TO'
    Update ozf_res_cust_prod_facts outer
      Set (YTD_FUND_utilized, YTD_FUND_earned, YTD_FUND_paid)
     =
     (
      SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
        ozf_cust_fund_summary_mv b,
        ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_year_id = b.time_id
       AND b.status_code = 'ACTIVE'
       AND b.party_id = outer.party_id
       AND b.party_id = c.party_id
       AND b.bill_to_site_use_id = outer.bill_to_site_use_id
       AND b.bill_to_site_use_id = c.bill_to_site_use_id
       AND b.ship_to_site_use_id = outer.ship_to_site_use_id
       AND b.ship_to_site_use_id = c.ship_to_site_use_id
       AND (
        ( b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
            AND b.product_id = c.product_attr_value
        )
        or
        ( b.product_level_type IS NULL
            AND b.product_id IS NULL
            AND EXISTS (SELECT 'X'
                FROM ams_act_access_denorm
                WHERE object_type = b.plan_type
                AND object_id = b.plan_id
                AND resource_id = outer.resource_id)
        )
       )
    )
    WHERE outer.fact_row_for = 'SHIP_TO'
    AND outer.report_date = p_report_date ;

    --QTD amounts for 'PARTY'
    Update ozf_res_cust_prod_facts outer
      Set (QTD_FUND_utilized, QTD_FUND_earned, QTD_FUND_paid)
     =
    (
     SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
        ozf_cust_fund_summary_mv b,
        ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_qtr_id = b.time_id
       AND b.status_code = 'ACTIVE'
       AND b.party_id = outer.party_id
       AND b.party_id = c.party_id
       AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
       AND
       (
        (
         b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
         AND b.product_id = c.product_attr_value
        )
        OR
        (
         b.product_level_type IS NULL
         AND b.product_id IS NULL
         AND EXISTS (SELECT 'X'
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id)
        )
      )
    )
    WHERE outer.fact_row_for = 'PARTY'
    AND outer.report_date = p_report_date ;

    --QTD amounts for 'BILL_TO'
    Update ozf_res_cust_prod_facts outer
    Set (QTD_FUND_utilized, QTD_FUND_earned, QTD_FUND_paid)
    =
    (
      SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
       ozf_cust_fund_summary_mv b,
       ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_qtr_id = b.time_id
       AND b.status_code = 'ACTIVE'
       AND b.party_id = outer.party_id
       AND b.party_id = c.party_id
       AND b.bill_to_site_use_id = outer.bill_to_site_use_id
       AND b.bill_to_site_use_id = c.bill_to_site_use_id
       AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
       AND
       (
        (
         b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
         AND b.product_id = c.product_attr_value
        )
        OR
        (
         b.product_level_type IS NULL
         AND b.product_id IS NULL
         AND EXISTS (SELECT 'X'
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id)
        )
      )
    )
    WHERE outer.fact_row_for = 'BILL_TO'
    AND outer.report_date = p_report_date ;

    --QTD amounts for 'SHIP_TO'
    Update ozf_res_cust_prod_facts outer
      Set (QTD_FUND_utilized, QTD_FUND_earned, QTD_FUND_paid)
     =
     (
       SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
       ozf_cust_fund_summary_mv b,
       ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_qtr_id = b.time_id
        AND b.status_code = 'ACTIVE'
        AND b.party_id = outer.party_id
        AND b.party_id = c.party_id
        AND b.bill_to_site_use_id = outer.bill_to_site_use_id
        AND b.bill_to_site_use_id = c.bill_to_site_use_id
        AND b.ship_to_site_use_id = outer.ship_to_site_use_id
        AND b.ship_to_site_use_id = c.ship_to_site_use_id
        AND
          (
            ( b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
                AND b.product_id = c.product_attr_value
            )
            OR
            ( b.product_level_type IS NULL
                AND b.product_id IS NULL
                AND EXISTS (SELECT count(object_id)
                    FROM ams_act_access_denorm
                    WHERE object_type = b.plan_type
                    AND object_id = b.plan_id
                    AND resource_id = outer.resource_id)
            )
           )
        )
    WHERE outer.fact_row_for = 'SHIP_TO'
    AND outer.report_date = p_report_date;

    --MTD amounts for 'PARTY'
    Update ozf_res_cust_prod_facts outer
      Set (MTD_FUND_utilized, MTD_FUND_earned, MTD_FUND_paid)
     =
     (
      SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
            ozf_cust_fund_summary_mv b,
            ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_period_id = b.time_id
        AND b.status_code = 'ACTIVE'
        AND b.party_id = outer.party_id
        AND b.party_id = c.party_id
        AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
       AND
       (
        (
         b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
         AND b.product_id = c.product_attr_value
        )
        OR
        (
         b.product_level_type IS NULL
         AND b.product_id IS NULL
         AND EXISTS (SELECT 'X'
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id)
        )
      )
    )
    WHERE outer.fact_row_for = 'PARTY'
    AND outer.report_date = p_report_date;

    --MTD amounts for 'BILL_TO'
    Update ozf_res_cust_prod_facts outer
      Set (MTD_FUND_utilized, MTD_FUND_earned, MTD_FUND_paid)
     =
     (
       SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
            ozf_cust_fund_summary_mv b,
            ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_period_id = b.time_id
        AND b.status_code = 'ACTIVE'
        AND b.party_id = outer.party_id
        AND b.party_id = c.party_id
        AND b.bill_to_site_use_id = outer.bill_to_site_use_id
        AND b.bill_to_site_use_id = c.bill_to_site_use_id
        AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
        AND
        (
         (
            b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
            AND b.product_id = c.product_attr_value
         )
         OR
         (
            b.product_level_type IS NULL
            AND b.product_id IS NULL
            AND EXISTS (SELECT 'X'
                FROM ams_act_access_denorm
                WHERE object_type = b.plan_type
                AND object_id = b.plan_id
                AND resource_id = outer.resource_id)
         )
       )
    )
    WHERE outer.fact_row_for = 'BILL_TO'
    AND outer.report_date = p_report_date ;

    --MTD amounts for 'SHIP_TO'
    Update ozf_res_cust_prod_facts outer
      Set (MTD_FUND_utilized, MTD_FUND_earned, MTD_FUND_paid)
     =
     (
       SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
            ozf_cust_fund_summary_mv b,
            ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_period_id = b.time_id
        AND b.status_code = 'ACTIVE'
        AND b.party_id = outer.party_id
        AND b.party_id = c.party_id
        AND b.bill_to_site_use_id = outer.bill_to_site_use_id
        AND b.bill_to_site_use_id = c.bill_to_site_use_id
        AND b.ship_to_site_use_id = outer.ship_to_site_use_id
        AND b.ship_to_site_use_id = c.ship_to_site_use_id
        AND
        (
          ( b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
           AND b.product_id = c.product_attr_value
          )
         OR
         ( b.product_level_type IS NULL
          AND b.product_id IS NULL
          AND EXISTS (SELECT 'X'
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id)
         )
       )
    )
    WHERE outer.fact_row_for = 'SHIP_TO'
    AND outer.report_date = p_report_date ;

    --UNPAID amount for 'PARTY'
    Update ozf_res_cust_prod_facts outer
      Set (FUND_unpaid)
     =
     (
      SELECT (NVL(SUM(earned_amt),0) - NVL(SUM(paid_amt),0)) tot_unpaid
       FROM ozf_cust_fund_summary_mv b,
                ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND b.time_id = -1
        AND b.period_type_id = 256
        AND b.status_code = 'ACTIVE'
        AND b.party_id = c.party_id
        AND b.party_id = outer.party_id
        AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
        AND
        (
          (
            b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
            AND b.product_id = c.product_attr_value
          )
          OR
          (
            b.product_level_type IS NULL
            AND b.product_id IS NULL
            AND EXISTS (SELECT 'X'
                FROM ams_act_access_denorm
                WHERE object_type = b.plan_type
                AND object_id = b.plan_id
                AND resource_id = outer.resource_id)
          )
        )
    )
    WHERE outer.fact_row_for = 'PARTY'
    AND outer.report_date = p_report_date ;

    --UNPAID amount for 'BILL_TO'
    Update ozf_res_cust_prod_facts outer
      Set (fund_unpaid)
     =
     (
        SELECT (NVL(SUM(earned_amt),0) - NVL(SUM(paid_amt),0)) tot_unpaid
        FROM ozf_cust_fund_summary_mv b,
            ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND b.time_id = -1
        AND b.period_type_id = 256
        AND b.status_code = 'ACTIVE'
        AND b.party_id = outer.party_id
        AND b.party_id = c.party_id
        AND b.bill_to_site_use_id = outer.bill_to_site_use_id
        AND b.bill_to_site_use_id = c.bill_to_site_use_id
        AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
        AND
        (
          (
            b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
            AND b.product_id = c.product_attr_value
          )
          OR
          (
            b.product_level_type IS NULL
            AND b.product_id IS NULL
            AND EXISTS (SELECT 'X'
                FROM ams_act_access_denorm
                WHERE object_type = b.plan_type
                AND object_id = b.plan_id
                AND resource_id = outer.resource_id)
          )
        )
    )
    WHERE outer.fact_row_for = 'BILL_TO'
    AND outer.report_date = p_report_date ;

    --UNPAID amount for 'SHIP_TO'
    Update ozf_res_cust_prod_facts outer
      Set (fund_unpaid)
     =
     (
        SELECT (NVL(SUM(earned_amt),0) - NVL(SUM(paid_amt),0)) tot_unpaid
        FROM ozf_cust_fund_summary_mv b,
            ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND b.time_id = -1
        AND b.period_type_id = 256
        AND b.status_code = 'ACTIVE'
        AND b.party_id = outer.party_id
        AND b.party_id = c.party_id
        AND b.bill_to_site_use_id = outer.bill_to_site_use_id
        AND b.bill_to_site_use_id = c.bill_to_site_use_id
        AND b.ship_to_site_use_id = outer.ship_to_site_use_id
        AND b.ship_to_site_use_id = c.ship_to_site_use_id
        AND
        (
          ( b.product_level_type = DECODE(c.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
            AND b.product_id = c.product_attr_value
          )
          OR
          ( b.product_level_type IS NULL
            AND b.product_id IS NULL
            AND EXISTS (SELECT 'X'
                FROM ams_act_access_denorm
                WHERE object_type = b.plan_type
                AND object_id = b.plan_id
                AND resource_id = outer.resource_id)
          )
        )
    )
    WHERE outer.fact_row_for = 'SHIP_TO'
    AND outer.report_date = p_report_date ;

    --YTD budget amount for 'PRODUCT'
    Update ozf_res_cust_prod_facts outer
      Set (YTD_FUND_utilized, YTD_FUND_earned, YTD_FUND_paid)
     =
     (
       SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
       FROM ozf_time_day a,
            ozf_cust_fund_summary_mv b,
            ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
       AND a.report_date = outer.report_date
       AND a.ent_year_id = b.time_id
       AND b.status_code = 'ACTIVE'
       AND b.product_level_type = DECODE(outer.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
       AND b.product_id = outer.PRODUCT_ATTR_VALUE
       AND c.product_attr_value = b.product_id
       AND c.product_attribute = DECODE(b.product_level_type, 'FAMILY','PRICING_ATTRIBUTE2','PRICING_ATTRIBUTE1')
       AND b.party_id = c.party_id
       AND NVL(b.bill_to_site_use_id, c.bill_to_site_use_id) = c.bill_to_site_use_id
       AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
    )
    WHERE outer.fact_row_for = 'PRODUCT'
    AND outer.report_date = p_report_date ;

    --QTD budget amount for 'PRODUCT'
    Update ozf_res_cust_prod_facts outer
      Set (QTD_FUND_utilized, QTD_FUND_earned, QTD_FUND_paid)
     =
     (
         SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
          FROM ozf_time_day a,
            ozf_cust_fund_summary_mv b,
            ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
        AND a.report_date = outer.report_date
        AND a.ent_qtr_id = b.time_id
        AND b.status_code = 'ACTIVE'
        AND b.product_level_type = DECODE(outer.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
        AND b.product_id = outer.PRODUCT_ATTR_VALUE
        AND c.product_attr_value = b.product_id
        AND c.product_attribute = DECODE(b.product_level_type, 'FAMILY','PRICING_ATTRIBUTE2','PRICING_ATTRIBUTE1')
        AND b.party_id = c.party_id
        AND NVL(b.bill_to_site_use_id, c.bill_to_site_use_id) = c.bill_to_site_use_id
        AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
    )
    WHERE outer.fact_row_for = 'PRODUCT'
    AND outer.report_date = p_report_date ;

    --MTD budget amount for 'PRODUCT'
    Update ozf_res_cust_prod_facts outer
      Set (MTD_FUND_utilized, MTD_FUND_earned, MTD_FUND_paid)
     =
     (
         SELECT NVL(SUM(utilized_amt),0) tot_utilized,
          NVL(SUM(earned_amt),0) tot_earned,
          NVL(SUM(paid_amt),0) tot_paid
          FROM ozf_time_day a,
                ozf_cust_fund_summary_mv b,
                ozf_res_cust_prod c
        WHERE c.resource_id = outer.resource_id
           AND a.report_date = outer.report_date
           AND a.ent_period_id = b.time_id
           AND b.status_code = 'ACTIVE'
           AND b.product_level_type = DECODE(outer.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
           AND b.product_id = outer.PRODUCT_ATTR_VALUE
           AND c.product_attr_value = b.product_id
           AND c.product_attribute = DECODE(b.product_level_type, 'FAMILY','PRICING_ATTRIBUTE2','PRICING_ATTRIBUTE1')
           AND b.party_id = c.party_id
           AND NVL(b.bill_to_site_use_id, c.bill_to_site_use_id) = c.bill_to_site_use_id
           AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
    )
    WHERE outer.fact_row_for = 'PRODUCT'
    AND outer.report_date = p_report_date ;

    --Unpaid budget amount for 'PRODUCT'
    Update ozf_res_cust_prod_facts outer
      Set (fund_unpaid)
     =
     (
        SELECT (NVL(SUM(earned_amt),0) - NVL(SUM(paid_amt),0)) tot_unpaid
          FROM ozf_cust_fund_summary_mv b,
               ozf_res_cust_prod c
       WHERE c.resource_id = outer.resource_id
          AND b.time_id = -1
          AND b.period_type_id = 256
          AND b.status_code = 'ACTIVE'
          AND b.product_level_type = DECODE(outer.product_attribute, 'PRICING_ATTRIBUTE2','FAMILY','PRODUCT')
          AND b.product_id = outer.PRODUCT_ATTR_VALUE
          AND c.product_attr_value = b.product_id
          AND c.product_attribute = DECODE(b.product_level_type, 'FAMILY','PRICING_ATTRIBUTE2','PRICING_ATTRIBUTE1')
          AND b.party_id = c.party_id
          AND NVL(b.bill_to_site_use_id, c.bill_to_site_use_id) = c.bill_to_site_use_id
          AND NVL(b.ship_to_site_use_id, DECODE((SELECT count(object_id)
            FROM ams_act_access_denorm
            WHERE object_type = b.plan_type
            AND object_id = b.plan_id
            AND resource_id = outer.resource_id), 0, 0, c.ship_to_site_use_id)) = c.ship_to_site_use_id
    )
    WHERE outer.fact_row_for = 'PRODUCT'
    AND outer.report_date = p_report_date ;

    --Open Claims amount for 'PARTY'
    Update ozf_res_cust_prod_facts outer
      Set (OPEN_CLAIMS)
     =
     (
        SELECT NVL(SUM(amount_remaining),0)
     FROM ozf_claims_all b,
        (SELECT DISTINCT resource_id, party_id, cust_account_id, ship_to_site_use_id FROM ozf_res_cust_prod) c
      WHERE c.resource_id = outer.resource_id
        AND c.party_id = outer.party_id
        AND b.cust_account_id = c.cust_account_id
        AND b.claim_date <= outer.report_date
        AND b.status_code = 'OPEN'
        AND b.claim_class <> 'GROUP'
        AND
          (
            (b.cust_shipto_acct_site_id = c.ship_to_site_use_id )
            OR
            (b.cust_shipto_acct_site_id IS NULL)
          )
    )
    WHERE outer.fact_row_for = 'PARTY'
    AND outer.report_date = p_report_date ;

    --Open Claims amount for 'BILL_TO'
    Update ozf_res_cust_prod_facts outer
      Set (OPEN_CLAIMS)
     =
     (
         SELECT NVL(SUM(amount_remaining),0)
         FROM ozf_claims_all b,
              (SELECT DISTINCT resource_id, party_id, cust_account_id, bill_to_site_use_id, ship_to_site_use_id FROM ozf_res_cust_prod) c
      WHERE c.resource_id = outer.resource_id
        AND c.party_id = outer.party_id
        AND c.bill_to_site_use_id = outer.bill_to_site_use_id
        AND b.cust_billto_acct_site_id = outer.bill_to_site_use_id
        AND b.cust_account_id = c.cust_account_id
        AND b.claim_date <= outer.report_date
        AND b.status_code = 'OPEN'
        AND b.claim_class <> 'GROUP'
        AND
          (
            (b.cust_shipto_acct_site_id = c.ship_to_site_use_id )
            OR
            (b.cust_shipto_acct_site_id IS NULL)
          )
    )
    WHERE outer.fact_row_for = 'BILL_TO'
    AND outer.report_date = p_report_date ;

    --Open Claims amount for 'SHIP_TO'
    Update ozf_res_cust_prod_facts outer
      Set (OPEN_CLAIMS)
     =
     (
        SELECT NVL(SUM(amount_remaining),0)
          FROM ozf_claims_all b,
               (SELECT DISTINCT resource_id, party_id, cust_account_id, bill_to_site_use_id, ship_to_site_use_id FROM ozf_res_cust_prod) c
      WHERE c.resource_id = outer.resource_id
        AND c.party_id = outer.party_id
        AND c.bill_to_site_use_id = outer.bill_to_site_use_id
        AND b.cust_billto_acct_site_id = outer.bill_to_site_use_id
        AND c.ship_to_site_use_id = outer.ship_to_site_use_id
        AND b.cust_shipto_acct_site_id = outer.ship_to_site_use_id
        AND b.cust_account_id = c.cust_account_id
        AND b.claim_date <= outer.report_date
        AND b.status_code = 'OPEN'
        AND b.claim_class <> 'GROUP'
    )
    WHERE outer.fact_row_for = 'SHIP_TO'
    AND outer.report_date = p_report_date ;

    ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

    EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.g_ret_sts_error ;
              FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                         p_count   => x_msg_count,
                                         p_data    => x_msg_data);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.g_ret_sts_unexp_error ;
              FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                         p_count => x_msg_count,
                                         p_data  => x_msg_data);

         WHEN OTHERS THEN
              x_return_status := FND_API.g_ret_sts_unexp_error ;
              FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                         p_count => x_msg_count,
                                         p_data  => x_msg_data);
    END refresh_budget_and_claims_info;


 PROCEDURE load_daily_facts( ERRBUF                  OUT NOCOPY VARCHAR2,
                            RETCODE                 OUT NOCOPY NUMBER,
                            p_report_date           IN   VARCHAR2 )
IS

    l_api_version             CONSTANT NUMBER       := 1.0;
    p_api_version             CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'load_daily_facts';
    l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(240);
    x_return_status           VARCHAR2(1) ;
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;

    l_report_date DATE;

BEGIN

     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      FND_MSG_PUB.initialize;

      -- Debug Message
      ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' (-)');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_report_date := trunc(to_date(p_report_date,'YYYY/MM/DD HH24:MI:SS'));

      IF l_report_date IS NULL
      THEN
          l_report_date := TRUNC(SYSDATE);
      END IF;

      ozf_utility_pvt.write_conc_log(' -- report_date is  : ' || l_report_date );
      --
      --  Refresh Account and Products
      --

      refresh_accts_and_products(
                     l_api_version ,
                     l_init_msg_list ,
                     l_report_date   ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      );

      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

      --
      -- Refresh Sales Info
      --

-- ozf_utility_pvt.write_conc_log('-22');
      refresh_sales_info(
                     l_api_version ,
                     l_init_msg_list ,
                     l_report_date   ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      );

      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

      refresh_target_info(
                     l_api_version ,
                     l_init_msg_list ,
                     l_report_date   ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      );

      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

-- ozf_utility_pvt.write_conc_log('-33');
      --
      -- Refresh Order Info
      --

      refresh_orders_info(
                     l_api_version ,
                     l_init_msg_list ,
                     l_report_date   ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      );

      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

      --
      -- Refresh KPI Info
      --

-- ozf_utility_pvt.write_conc_log('-44');

      refresh_kpi_info(
                     l_api_version ,
                     l_init_msg_list ,
                     l_report_date   ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      );

      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;


      populate_res_cust_prod_facts (l_api_version ,
                     l_init_msg_list ,
                     l_report_date,
                     x_return_status,
                     x_msg_count,
                     x_msg_data);

      IF x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

      refresh_budget_and_claims_info(l_api_version ,
                     l_init_msg_list,
                     l_report_date,
                     x_return_status,
                     x_msg_count,
                     x_msg_data);

      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

-- ozf_utility_pvt.write_conc_log('- End');

    /*
    update_sales_info(
                     l_api_version   ,
                     l_init_msg_list ,
                     l_report_date   ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      ) ;
    */

    update_quota_sales_info(
                     l_api_version   ,
                     l_init_msg_list ,
                     l_report_date   ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      ) ;

      ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' (+)');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Expected Error');

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Error');

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Others');

END load_daily_facts;



 PROCEDURE get_dates ( p_period_type_id IN NUMBER,
                       p_time_id        IN NUMBER,
                       x_record_type_id OUT NOCOPY NUMBER,
                       x_start_date     OUT NOCOPY DATE,
                       x_end_date       OUT NOCOPY DATE)  IS


 BEGIN
    IF p_period_type_id = 64
    THEN
       --
       x_record_type_id := 55;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_ent_qtr
       WHERE ent_qtr_id = p_time_id;
       --
    ELSIF p_period_type_id = 32
    THEN
       --
       x_record_type_id := 23;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_ent_period
       WHERE ent_period_id = p_time_id;
       --
    ELSIF p_period_type_id = 16
    THEN
       --
       x_record_type_id := 11;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_week
       WHERE week_id = p_time_id;
       --
    ELSIF p_period_type_id = 1
    THEN
       --
       x_record_type_id := 1;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_day
       WHERE report_date_julian = p_time_id;
       --
    END IF;
  END get_dates;

-- This function is called from Sales Performance Graphs

 FUNCTION get_xtd_total( p_period_type_id        IN   NUMBER,
                         p_time_id               IN   NUMBER,
                         p_start_date            IN   DATE,
                         p_end_date              IN   DATE,
                         p_type                  IN   VARCHAR2)
 RETURN NUMBER IS


  CURSOR sales_csr (p_as_of_date     IN DATE,
                    p_record_type_id IN NUMBER) IS
   SELECT SUM(sales.sales)
    FROM ozf_search_selections_t acct,
         ozf_search_selections_t prod,
         ozf_order_sales_v       sales,
         ozf_time_rpt_struct     rpt
    where acct.search_type = 'QUALIFIER'
    and prod.search_type = 'ITEM'
    and acct.attribute_value = sales.ship_to_site_use_id
    and prod.attribute_value = sales.inventory_item_id
    and rpt.report_date = p_as_of_date
    and BITAND(rpt.record_type_id, p_record_type_id) = rpt.record_type_id
    and rpt.time_id = sales.time_id ;

    -- Get Quota for the give time period
/*
  CURSOR quota_csr IS
  SELECT  ozf_cust_facts_pvt.get_cust_target ( b.site_use_id,
                                               b.bill_to_site_use_id,
                                               c.period_type_id ,
                                               c.time_id) target
  FROM ozf_product_allocations a
      ,ozf_account_allocations b
      ,ozf_time_allocations c
      ,ozf_search_selections_t acct
      ,ozf_search_selections_t prod
  WHERE acct.search_type = 'QUALIFIER'
  AND   prod.search_type = 'ITEM'
  AND   a.allocation_for = 'CUST'
  AND   a.item_type = prod.attribute_id
  AND   a.item_id   = prod.attribute_value
  AND   b.account_allocation_id = a.allocation_for_id
  AND   b.site_use_code = 'SHIP_TO'
  AND   b.site_use_id = prod.attribute_value
  AND   c.allocation_for = 'PROD'
  AND   c.allocation_for_id = a.product_allocation_id
  AND   c.period_type_id = p_period_type_id
  AND   c.time_id        = p_time_id;
*/

     CURSOR quota_csr IS
     SELECT SUM(NVL(b.target,0))
     FROM ozf_account_allocations a,
          ozf_time_allocations b
     WHERE a.allocation_for = 'FUND'
     AND   a.allocation_for_id IN  (
                                    SELECT fund_id
                                    FROM ozf_funds_all_b
                                    WHERE parent_fund_id IS NOT NULL
                                    AND start_date_active >= p_start_date
                                    AND end_date_active <= p_end_date )
     AND b.allocation_for = 'CUST'
     AND b.allocation_for_id = a.account_allocation_id
     AND NVL(b.account_status, 'X') <> 'D'
     AND b.period_type_id = p_period_type_id
     AND b.time_id = p_time_id ;


    l_record_type_id NUMBER;
    l_start_date     DATE;
    l_end_date       DATE;
    ly_start_date    DATE;
    ly_end_date      DATE;

    l_end_xtd      NUMBER;
    l_start_xtd      NUMBER;
    l_xtd_sales      NUMBER;

 BEGIN

     get_dates ( p_period_type_id ,
                 p_time_id        ,
                 l_record_type_id ,
                 l_start_date     ,
                 l_end_date     )  ;

    IF p_type = 'XTD'
    THEN
    --

       IF p_start_date > l_start_date
       THEN
          -- Start Date is middle of month
          -- Sales for month = (XTD for l_end_date) - (XTD for p_start_date)
         OPEN sales_csr(l_end_date, l_record_type_id);
         FETCH sales_csr INTO l_end_xtd;
         CLOSE sales_csr;

         OPEN sales_csr(p_end_date, l_record_type_id);
         FETCH sales_csr INTO l_start_xtd;
         CLOSE sales_csr;

         l_xtd_sales := l_end_xtd - l_start_xtd;
      ELSE
         -- In all other cases. Just get XTD

         OPEN sales_csr(l_end_date, l_record_type_id);
         FETCH sales_csr INTO l_xtd_sales;
         CLOSE sales_csr;

      END IF;

    --
    ELSIF p_type = 'LYSP'
    THEN
        --
        ly_start_date := add_months(p_start_date, -12);
        ly_end_date   := add_months(p_end_date, -12);
        l_start_date := add_months(l_start_date , -12);
        l_end_date   := add_months(l_end_date, -12) ;

        IF ly_start_date > l_start_date
        THEN
           -- Start Date is middle of month
           -- Sales for month = (XTD for l_end_date) - (XTD for ly_start_date)
          OPEN sales_csr(l_end_date, l_record_type_id);
          FETCH sales_csr INTO l_end_xtd;
          CLOSE sales_csr;

          OPEN sales_csr(ly_end_date, l_record_type_id);
          FETCH sales_csr INTO l_start_xtd;
          CLOSE sales_csr;

          l_xtd_sales := l_end_xtd - l_start_xtd;
       ELSE
          -- In all other cases. Just get XTD

          OPEN sales_csr(l_end_date, l_record_type_id);
          FETCH sales_csr INTO l_xtd_sales;
          CLOSE sales_csr;
       END IF;
       --
    ELSIF p_type = 'QUOTA'
    THEN
       OPEN quota_csr;
       FETCH quota_csr INTO l_xtd_sales;
       CLOSE quota_csr;
    END IF;

    RETURN l_xtd_sales;
 EXCEPTION
    WHEN OTHERS THEN
      RETURN -999;
 END get_xtd_total ;

-- This function to display Dashboard Graph

 FUNCTION get_xtd_total( p_resource_id           IN   NUMBER,
                         p_period_type_id        IN   NUMBER,
                         p_time_id               IN   NUMBER,
                         p_type                  IN   VARCHAR2 )
 RETURN NUMBER IS

 CURSOR sales_csr (p_as_of_date IN DATE,
                   p_record_type_id IN NUMBER) IS
 SELECT NVL(SUM(NVL(sales.sales,0)),0)
 FROM ozf_account_allocations acct,
      ozf_product_allocations prod,
      ozf_order_sales_v       sales,
      ozf_time_rpt_struct     rpt
 WHERE
       rpt.report_date       = p_as_of_date
  AND  BITAND(rpt.record_type_id, p_record_type_id )
                             = rpt.record_type_id
  AND sales.time_id          = rpt.time_id
  AND sales.ship_to_site_use_id = acct.site_use_id
  AND sales.inventory_item_id   = prod.item_id
  AND prod.allocation_for    = 'CUST'
  AND prod.allocation_for_id = acct.account_allocation_id
  AND acct.allocation_for    = 'FUND'
  AND NVL(acct.account_status, 'X') <> 'D'
 -- R12: Do not consider UnAllocated Rows
  AND acct.parent_party_id   <> -9999
  AND acct.allocation_for_id IN (
                                 SELECT aa.fund_id
                                 FROM   ozf_funds_all_b aa
                                 WHERE  aa.owner       = p_resource_id
                                 AND    aa.fund_type   = 'QUOTA'
                                 AND    aa.status_code <> 'CANCELLED'
                                 AND    NOT EXISTS ( SELECT 1
                                                     FROM  ozf_funds_all_b bb
                                                     WHERE bb.parent_fund_id = aa.fund_id )
                                 --
                                 UNION ALL-- Get all leaf node quotas in the hierarchy of this resource
                                 --
                                 SELECT aa.fund_id
                                 FROM   ozf_funds_all_b aa
                                 WHERE  aa.fund_type    = 'QUOTA'
                                 AND    aa.status_code  <> 'CANCELLED'
                                 CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
                                 START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                                                   FROM ozf_funds_all_b bb
                                                                   WHERE bb.owner       = p_resource_id
                                                                   AND   bb.fund_type   = 'QUOTA'
                                                                   AND   bb.status_code <> 'CANCELLED' )
                                );

  -- Same cursor as refesh_kpi
  CURSOR quota_csr IS
  SELECT SUM(b.target)
  FROM ozf_account_allocations a,
       ozf_time_allocations b
  WHERE
        b.allocation_for    = 'CUST'
  AND   b.allocation_for_id =  a.account_allocation_id
  AND   b.period_type_id    =  p_period_type_id
  AND   b.time_id           =  p_time_id
  AND   a.allocation_for    = 'FUND'
  AND   NVL(a.account_status, 'X') <> 'D'
 -- R12: Do not consider UnAllocated Rows
  AND   a.parent_party_id   <> -9999
  AND   a.allocation_for_id IN ( -- Get leaf node quotas for this resource owns
                                 SELECT aa.fund_id
                                 FROM   ozf_funds_all_b aa
                                 WHERE  aa.owner       = p_resource_id
                                 AND    aa.fund_type   = 'QUOTA'
                                 AND    aa.status_code <> 'CANCELLED'
                                 AND    NOT EXISTS ( SELECT 1
                                                     FROM  ozf_funds_all_b bb
                                                     WHERE bb.parent_fund_id = aa.fund_id )
                                 --
                                 UNION ALL -- Get all leaf node quotas in the hierarchy of this resource
                                 --
                                 SELECT aa.fund_id
                                 FROM   ozf_funds_all_b aa
                                 WHERE  aa.fund_type    = 'QUOTA'
                                 AND    aa.status_code  <> 'CANCELLED'
                                 CONNECT BY PRIOR aa.fund_id = aa.parent_fund_id
                                 START WITH aa.parent_fund_id IN ( SELECT bb.fund_id
                                                                   FROM ozf_funds_all_b bb
                                                                   WHERE bb.owner       = p_resource_id
                                                                   AND   bb.fund_type   = 'QUOTA'
                                                                   AND   bb.status_code <> 'CANCELLED' )
                              );


    l_record_type_id NUMBER;
    l_start_date     DATE;
    l_end_date       DATE;

    l_end_xtd      NUMBER;
    l_start_xtd      NUMBER;
    l_xtd_sales      NUMBER;

    l_return_value   NUMBER;

 BEGIN

    get_dates (  p_period_type_id ,
                 p_time_id        ,
                 l_record_type_id ,
                 l_start_date     ,
                 l_end_date     )  ;

    IF p_type = 'XTD'
    THEN

        OPEN sales_csr(l_end_date, l_record_type_id);
        FETCH sales_csr INTO l_return_value ;
        CLOSE sales_csr;

    ELSIF p_type = 'LYSP'
    THEN

       l_end_date := add_months(l_end_date, -12) ;

       OPEN sales_csr(l_end_date, l_record_type_id);
       FETCH sales_csr INTO l_return_value;
       CLOSE sales_csr;

    ELSIF p_type = 'QUOTA'
    THEN

        OPEN quota_csr;
        FETCH quota_csr INTO l_return_value;
        CLOSE quota_csr;

    END IF;

   RETURN l_return_value;

 EXCEPTION
    WHEN OTHERS THEN
      RETURN -9999;
 END  get_xtd_total ;

END ozf_cust_facts_pvt;

/
