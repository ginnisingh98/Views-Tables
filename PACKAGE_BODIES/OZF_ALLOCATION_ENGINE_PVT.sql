--------------------------------------------------------
--  DDL for Package Body OZF_ALLOCATION_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ALLOCATION_ENGINE_PVT" AS
/* $Header: ozfvaegb.pls 120.6.12010000.3 2008/12/31 16:51:44 psomyaju ship $  */
-- g_version    CONSTANT CHAR(80) := '$Header: ozfvaegb.pls 120.6.12010000.3 2008/12/31 16:51:44 psomyaju ship $';
   g_pkg_name   CONSTANT VARCHAR2(30):='OZF_ALLOCATION_ENGINE_PVT';

   OZF_DEBUG_HIGH_ON CONSTANT BOOLEAN   := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   OZF_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
   OZF_DEBUG_LOW_ON CONSTANT BOOLEAN    := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
   G_DEBUG_LEVEL BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

   g_phase           VARCHAR2(500);
   g_user_id         NUMBER;
   g_login_id        NUMBER;

   TYPE G_GenericCurType IS REF CURSOR;

   OZF_TP_INVALID_PARAM          EXCEPTION;
   OZF_TP_BLANK_PERIOD_TBL       EXCEPTION;
   OZF_TP_DIFF_TIME_SPREAD       EXCEPTION;
   OZF_TP_OPER_NOT_ALLOWED       EXCEPTION;
   OZF_TP_CHG_PS_NOT_ALLOWED     EXCEPTION;
   OZF_TP_ADDITEM_NOT_ALLOWED    EXCEPTION;
   OZF_TP_DELITEM_NOT_ALLOWED    EXCEPTION;


-- ------------------------
-- Private Function
-- ------------------------

--Bugfix 7540057
FUNCTION get_org_id (p_terr_id NUMBER)
RETURN NUMBER IS

 l_org_id       NUMBER;

 CURSOR c_org_id IS
 SELECT org_id
 FROM   jtf_terr_all
 WHERE  terr_id = p_terr_id;

BEGIN

   OPEN  c_org_id;
   FETCH c_org_id INTO l_org_id;
   CLOSE c_org_id;

   RETURN l_org_id;

END get_org_id;
-- ------------------------------------------------------------------
-- Name: Generate new Time allocation ID from SEQ
-- Desc:
--
--
--
-- -----------------------------------------------------------------
 FUNCTION get_time_allocation_id
   RETURN NUMBER IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_time_allocation_id';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR time_seq_csr IS
          SELECT  ozf_time_allocations_s.NEXTVAL
          FROM DUAL;

   CURSOR time_alloc_count_csr(p_time_alloc_id in number) IS
          SELECT count(t.time_allocation_id)
          FROM   ozf_time_allocations t
          WHERE  t.time_allocation_id = p_time_alloc_id;

   l_count number := -1;
   l_time_alloc_id  number := -1;

  BEGIN

   --OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   OPEN time_seq_csr;
   FETCH time_seq_csr INTO l_time_alloc_id;
   CLOSE time_seq_csr;

   LOOP
    OPEN time_alloc_count_csr(l_time_alloc_id);
    FETCH time_alloc_count_csr into l_count;
    CLOSE time_alloc_count_csr;

    EXIT WHEN l_count = 0;

    OPEN time_seq_csr;
    FETCH time_seq_csr INTO l_time_alloc_id;
    CLOSE time_seq_csr;

   END LOOP;

   return l_time_alloc_id;

   EXCEPTION
     WHEN OTHERS THEN
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));
  END get_time_allocation_id;



-- ------------------------
-- Private Function
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Generate new Product allocation ID from SEQ
-- Desc:
--
--
--
-- -----------------------------------------------------------------
 FUNCTION get_product_allocation_id
   RETURN NUMBER IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_product_allocation_id';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR product_seq_csr IS
          SELECT  ozf_product_allocations_s.NEXTVAL
          FROM DUAL;

   CURSOR product_alloc_count_csr(p_product_alloc_id in number) IS
          SELECT count(p.product_allocation_id)
          FROM   ozf_product_allocations p
          WHERE  p.product_allocation_id = p_product_alloc_id;

   l_count number := -1;
   l_product_alloc_id  number := -1;

  BEGIN

   --OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   OPEN product_seq_csr;
   FETCH product_seq_csr INTO l_product_alloc_id;
   CLOSE product_seq_csr;

   LOOP
    OPEN product_alloc_count_csr(l_product_alloc_id);
    FETCH product_alloc_count_csr into l_count;
    CLOSE product_alloc_count_csr;

    EXIT WHEN l_count = 0;

    OPEN product_seq_csr;
    FETCH product_seq_csr INTO l_product_alloc_id;
    CLOSE product_seq_csr;

   END LOOP;

   return l_product_alloc_id;

   EXCEPTION
     WHEN OTHERS THEN
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));
  END get_product_allocation_id;




-- ------------------------
-- Private Function
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Generate new Account allocation ID from SEQ
-- Desc:
--
--
--
-- -----------------------------------------------------------------
 FUNCTION get_account_allocation_id
   RETURN NUMBER IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_account_allocation_id';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR account_seq_csr IS
          SELECT  ozf_account_allocations_s.NEXTVAL
          FROM DUAL;

   CURSOR account_alloc_count_csr(p_account_alloc_id in number) IS
          SELECT count(account_allocation_id)
          FROM   ozf_account_allocations
          WHERE  account_allocation_id = p_account_alloc_id;

   l_count number := -1;
   l_account_alloc_id  number := -1;

  BEGIN

   --OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   OPEN account_seq_csr;
   FETCH account_seq_csr INTO l_account_alloc_id;
   CLOSE account_seq_csr;

   LOOP
    OPEN account_alloc_count_csr(l_account_alloc_id);
    FETCH account_alloc_count_csr into l_count;
    CLOSE account_alloc_count_csr;

    EXIT WHEN l_count = 0;

    OPEN account_seq_csr;
    FETCH account_seq_csr INTO l_account_alloc_id;
    CLOSE account_seq_csr;

   END LOOP;

   return l_account_alloc_id;

   EXCEPTION
     WHEN OTHERS THEN
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));
  END get_account_allocation_id;


-- ------------------------
-- Public Function
-- ------------------------
-- ------------------------------------------------------------------
-- Name: get_LYSP_Sales
-- Desc: Called from Product Spread UI and from private apis.
--       This function will calculate and return LYSP sales of the newly
--       added Product or Category on the Product Spread UI for ROOT fund
--       for or any ShipTo Customer
-- Note: Distinct object types are = { ROOT, CUST }
-- ------------------------------------------------------------------
 FUNCTION GET_SALES
 (
    p_object_type        IN          VARCHAR2,
    p_object_id          IN          NUMBER,
    p_item_id            IN          NUMBER,
    p_item_type          IN          VARCHAR2,
    p_time_id            IN          NUMBER
 ) RETURN NUMBER IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_lysp_sales';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_object_type            VARCHAR2(100);
   l_object_id              NUMBER;
   l_item_id                NUMBER;
   l_item_type              VARCHAR2(100);
   l_time_id                NUMBER;

   l_fund_id                NUMBER;
   l_site_use_id            NUMBER;
   l_territory_id           NUMBER;
   l_lysp_sales             NUMBER;


CURSOR account_spread_csr
       (l_account_allocation_id  number) IS
   SELECT
       a.allocation_for_id,
       a.site_use_id
   FROM
       ozf_account_allocations a
   WHERE
       a.account_allocation_id = l_account_allocation_id;

l_account_spread_rec account_spread_csr%ROWTYPE;

CURSOR territory_csr_1 (l_fund_id  NUMBER) IS
 SELECT
  fund.node_id territory_id
 FROM
  ozf_funds_all_vl fund
 WHERE
     fund.fund_id = l_fund_id;

CURSOR territory_csr (l_fund_id  NUMBER) IS
 SELECT
  j.terr_id territory_id
 FROM
  ozf_funds_all_vl fund, jtf_terr_rsc_all j, jtf_terr_rsc_access_all j2
 WHERE
     fund.fund_id = l_fund_id
 AND j.resource_id = fund.owner
-- AND j.primary_contact_flag = 'Y' ;
 AND j2.terr_rsc_id = j.terr_rsc_id
 AND j2.access_type = 'OFFER'
 AND j2.trans_access_code = 'PRIMARY_CONTACT';

CURSOR product_lysp_sales_csr
                        (l_product_id    NUMBER,
             l_territory_id  NUMBER,
             l_site_use_id   NUMBER,
             l_time_id       NUMBER) IS
 SELECT
   SUM(bsmv.sales) sales
 FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
 WHERE
     a.market_qualifier_reference = l_territory_id
 AND a.market_qualifier_type='TERRITORY'
 AND a.site_use_id = NVL(l_site_use_id, a.site_use_id)
 AND bsmv.ship_to_site_use_id = a.site_use_id
 AND bsmv.inventory_item_id = l_product_id
 AND bsmv.time_id = l_time_id;

CURSOR fund_category_lysp_sales_csr
                               (l_category_id    NUMBER,
                                l_territory_id   NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
 SELECT
  SUM(bsmv.sales) sales
 FROM
  ozf_order_sales_v bsmv,
  ams_party_market_segments a
 WHERE
     a.market_qualifier_reference = l_territory_id
 AND a.market_qualifier_type='TERRITORY'
 AND bsmv.ship_to_site_use_id = a.site_use_id
 AND bsmv.time_id = l_time_id
 AND bsmv.inventory_item_id IN
                             ( SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                               FROM   MTL_ITEM_CATEGORIES     MIC,
                                      ENI_PROD_DENORM_HRCHY_V DENORM
                               WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                                AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                                AND   DENORM.PARENT_ID     = l_category_id
                              MINUS
                              SELECT a.inventory_item_id
                              FROM  ams_act_products a
                              WHERE act_product_used_by_id = l_fund_id
                               AND arc_act_product_used_by = 'FUND'
                               AND level_type_code = 'PRODUCT'
                               AND excluded_flag IN  ('Y', 'N')
                            );

CURSOR cust_category_lysp_sales_csr
                         (l_category_id    NUMBER,
              l_territory_id   NUMBER,
              l_site_use_id    NUMBER,
              l_time_id        NUMBER,
              l_fund_id        NUMBER) IS
 SELECT
   SUM(bsmv.sales) sales
 FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
 WHERE
     a.market_qualifier_reference = l_territory_id
 AND a.market_qualifier_type='TERRITORY'
 AND a.site_use_id = l_site_use_id
 AND bsmv.ship_to_site_use_id = a.site_use_id
 AND bsmv.time_id = l_time_id
 AND bsmv.inventory_item_id IN
                      (SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                       FROM   MTL_ITEM_CATEGORIES     MIC,
                              ENI_PROD_DENORM_HRCHY_V DENORM
                       WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                        AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                        AND   DENORM.PARENT_ID     = l_category_id
               MINUS
               SELECT p.item_id
               FROM   ozf_product_allocations p
               WHERE  p.fund_id = l_fund_id
              AND p.item_type = 'PRICING_ATTRIBUTE1'
             );

CURSOR fund_others_lysp_sales_csr
                             (l_territory_id   NUMBER,
                              l_time_id        NUMBER,
                              l_fund_id        NUMBER) IS
 SELECT
  SUM(bsmv.sales) sales
 FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
 WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND NOT EXISTS
  (
  ( SELECT prod.inventory_item_id
    FROM ams_act_products prod
    WHERE
        prod.level_type_code = 'PRODUCT'
    AND prod.arc_act_product_used_by = 'FUND'
    AND prod.act_product_used_by_id = l_fund_id
    AND prod.excluded_flag = 'N'
    AND prod.inventory_item_id = bsmv.inventory_item_id
    UNION ALL
    SELECT MIC.INVENTORY_ITEM_ID
    FROM   MTL_ITEM_CATEGORIES MIC,
           ENI_PROD_DENORM_HRCHY_V DENORM,
           AMS_ACT_PRODUCTS prod
    WHERE
          prod.level_type_code = 'FAMILY'
      AND prod.arc_act_product_used_by = 'FUND'
      AND prod.act_product_used_by_id = l_fund_id
      AND prod.excluded_flag = 'N'
      AND prod.category_id = DENORM.PARENT_ID
      AND MIC.CATEGORY_SET_ID = DENORM.CATEGORY_SET_ID
      AND MIC.CATEGORY_ID = DENORM.CHILD_ID
      AND MIC.INVENTORY_ITEM_ID = bsmv.inventory_item_id
  )
  MINUS
  SELECT prod.inventory_item_id
  FROM ams_act_products prod
  where
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'Y'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  );


  CURSOR cust_others_lysp_sales_csr
                               (l_territory_id   NUMBER,
                                l_site_use_id    NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND NOT EXISTS
  (
  ( SELECT p.item_id
    FROM ozf_product_allocations p
    WHERE
        p.fund_id = l_fund_id
    AND p.item_type = 'PRICING_ATTRIBUTE1'
    AND p.item_id = bsmv.inventory_item_id
    UNION ALL
    SELECT MIC.INVENTORY_ITEM_ID
    FROM   MTL_ITEM_CATEGORIES MIC,
           ENI_PROD_DENORM_HRCHY_V DENORM,
           OZF_PRODUCT_ALLOCATIONS p
    WHERE p.FUND_ID = l_fund_id
      AND p.ITEM_TYPE = 'PRICING_ATTRIBUTE2'
      AND p.ITEM_ID = DENORM.PARENT_ID
      AND MIC.CATEGORY_SET_ID = DENORM.CATEGORY_SET_ID
      AND MIC.CATEGORY_ID = DENORM.CHILD_ID
      AND MIC.INVENTORY_ITEM_ID = bsmv.inventory_item_id
  )
  MINUS
  SELECT prod.inventory_item_id
  FROM ams_act_products prod
  where
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'Y'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  );

 BEGIN

   l_object_type := p_object_type;
   l_object_id := p_object_id;
   l_item_id := p_item_id;
   l_item_type := p_item_type;
   l_time_id := p_time_id;

/*
   OZF_UTILITY_PVT.debug_message('API Parameters For:---->: ' || l_full_api_name);
   OZF_UTILITY_PVT.debug_message('1. l_object_type------->: ' || l_object_type);
   OZF_UTILITY_PVT.debug_message('2. l_object_id--------->: ' || l_object_id);
   OZF_UTILITY_PVT.debug_message('3. l_item_id----------->: ' || l_item_id);
   OZF_UTILITY_PVT.debug_message('4. l_item_type--------->: ' || l_item_type);
   OZF_UTILITY_PVT.debug_message('5. l_time_id----------->: ' || l_time_id);
*/


   IF     l_object_type IN ('ROOT', 'CUST')
      AND l_object_id > 0
      AND l_item_type IN ('PRICING_ATTRIBUTE1','PRICING_ATTRIBUTE2', 'OTHERS')
      AND l_time_id > 0
   THEN
     NULL;
   ELSE
     RAISE OZF_TP_INVALID_PARAM;
   END IF;

   IF l_object_type = 'CUST'
   THEN

     OPEN account_spread_csr(l_object_id);
     FETCH account_spread_csr INTO l_account_spread_rec;
     CLOSE account_spread_csr;
     l_fund_id := l_account_spread_rec.allocation_for_id;
     l_site_use_id := l_account_spread_rec.site_use_id;
   ELSE
     l_fund_id := l_object_id;
     l_site_use_id := NULL;
   END IF;

   OPEN territory_csr_1(l_fund_id);
   FETCH territory_csr_1 INTO l_territory_id;
   CLOSE territory_csr_1 ;

   IF l_territory_id IS NULL THEN
      OPEN territory_csr(l_fund_id);
      FETCH territory_csr INTO l_territory_id;
      CLOSE territory_csr ;
   END IF;

   l_lysp_sales := 0;

   IF l_object_type = 'ROOT'
   THEN

       IF l_item_type = 'PRICING_ATTRIBUTE1'
       THEN
           OPEN product_lysp_sales_csr(l_item_id,
                                       l_territory_id,
                                       l_site_use_id,
                                       l_time_id
                                      );
           FETCH product_lysp_sales_csr INTO l_lysp_sales;
           CLOSE product_lysp_sales_csr;
       ELSIF l_item_type = 'PRICING_ATTRIBUTE2'
       THEN
           OPEN fund_category_lysp_sales_csr
                                       (l_item_id,
                                        l_territory_id,
                                        l_time_id,
                                        l_fund_id
                                       );
           FETCH fund_category_lysp_sales_csr INTO l_lysp_sales;
           CLOSE fund_category_lysp_sales_csr;
       ELSIF l_item_type = 'OTHERS'
       THEN
        OPEN fund_others_lysp_sales_csr
                                  (l_territory_id,
                                   l_time_id,
                                   l_fund_id
                                  );
        FETCH fund_others_lysp_sales_csr INTO l_lysp_sales;
        CLOSE fund_others_lysp_sales_csr;
       END IF;
   ELSIF l_object_type = 'CUST'
   THEN

       IF l_item_type = 'PRICING_ATTRIBUTE1'
       THEN
           OPEN product_lysp_sales_csr(l_item_id,
                                       l_territory_id,
                                       l_site_use_id,
                                       l_time_id
                                      );
           FETCH product_lysp_sales_csr INTO l_lysp_sales;
           CLOSE product_lysp_sales_csr;
       ELSIF l_item_type = 'PRICING_ATTRIBUTE2'
       THEN
           OPEN cust_category_lysp_sales_csr
                                       (l_item_id,
                                        l_territory_id,
                                        l_site_use_id,
                                        l_time_id,
                                        l_fund_id
                                       );
           FETCH cust_category_lysp_sales_csr INTO l_lysp_sales;
           CLOSE cust_category_lysp_sales_csr;
       ELSIF l_item_type = 'OTHERS'
       THEN
        OPEN cust_others_lysp_sales_csr
                                  (l_territory_id,
                                   l_site_use_id,
                                   l_time_id,
                                   l_fund_id
                                  );
        FETCH cust_others_lysp_sales_csr INTO l_lysp_sales;
        CLOSE cust_others_lysp_sales_csr;
       END IF;
   END IF;

   l_lysp_sales := NVL(l_lysp_sales, 0);

   RETURN l_lysp_sales;

 EXCEPTION
     WHEN OTHERS THEN
          RETURN NULL;
 END GET_SALES;



-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: raise_business_event
-- Desc: This prodcedure will fix RAISE Business events for Targets.
--       1.
--       2.
--       3.
-- -----------------------------------------------------------------
PROCEDURE raise_business_event(p_object_id IN NUMBER)
 IS

  l_item_key        varchar2(30);
  l_event_name      varchar2(80);
  l_parameter_list  wf_parameter_list_t;

 BEGIN
  l_item_key       := p_object_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();
  l_event_name     :=  'oracle.apps.ozf.quota.TargetApproval';

  ozf_utility_pvt.debug_message('-> Raising Bussiness EVENT for Account Allocation Id == '||p_object_id||' ; ' );
  ozf_utility_pvt.debug_message('-> ITEM KEY == '||l_item_key||' ; ' );

  wf_event.AddParameterToList(p_name           => 'P_ACCOUNT_ALLOCATION_ID',
                              p_value          => p_object_id,
                              p_parameterlist  => l_parameter_list);

  wf_event.raise( p_event_name => l_event_name,
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);


 EXCEPTION
   WHEN OTHERS THEN
        RAISE Fnd_Api.g_exc_error;
        ozf_utility_pvt.debug_message('Exception in raising business event for Target Approval');
END;








-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: fix product rounding err
-- Desc: This prodcedure will fix product rounding error for
--       1. Root Product Spread
--       2. Fact Product Spread
--       3. Ship-To Product Spread
-- -----------------------------------------------------------------
 PROCEDURE fix_product_rounding_err
 (
    p_object_type        IN          VARCHAR2,
    p_object_id          IN          NUMBER,
    p_diff_target        IN          NUMBER
 ) IS

   l_api_name      CONSTANT VARCHAR2(30) := 'fix_product_rounding_err';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_object_type            VARCHAR2(30) := null;
   l_object_id              NUMBER;
   l_diff_target            NUMBER;
   l_temp_product_allocation_id NUMBER;


 BEGIN

   l_object_type := p_object_type;
   l_object_id   := p_object_id;
   l_diff_target := p_diff_target;


   IF     l_object_type IN ('FACT', 'CUST', 'FUND')
      AND l_object_id > 0
      AND l_diff_target <> 0
   THEN


            l_temp_product_allocation_id := 0;

            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id)
                                            FROM OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'PROD'
                                            AND x.allocation_for_id IN ( SELECT max(p.product_allocation_id)
                                                                         FROM  OZF_PRODUCT_ALLOCATIONS p
                                                                         WHERE p.allocation_for = l_object_type
                                                                           AND p.allocation_for_id = l_object_id
                                                                           AND p.target =
                                                                              (SELECT max(xz.target)
                                                                               FROM OZF_PRODUCT_ALLOCATIONS xz
                                                                               WHERE xz.allocation_for = l_object_type
                                                                               AND xz.allocation_for_id = l_object_id
                                                                               )

                                                                         )
                                           AND x.target =
                                               (SELECT max(zx.target)
                                                FROM OZF_TIME_ALLOCATIONS zx
                                                WHERE  zx.allocation_for = 'PROD'
                                                AND zx.allocation_for_id IN (SELECT max(pz.product_allocation_id)
                                                                             FROM  OZF_PRODUCT_ALLOCATIONS pz
                                                                             WHERE pz.allocation_for = l_object_type
                                                                               AND pz.allocation_for_id = l_object_id
                                                                               AND pz.target =
                                                                                (SELECT max(xz.target)
                                                                                 FROM OZF_PRODUCT_ALLOCATIONS xz
                                                                                WHERE xz.allocation_for = l_object_type
                                                                                AND xz.allocation_for_id = l_object_id
                                                                                )

                                                                             )
                                               )
                                           )
              RETURNING t.allocation_for_id INTO l_temp_product_allocation_id;


              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_ROUNDING_TIME_ERR');
                    fnd_message.set_token('OZF_TP_OBJECT_TYPE_TOKEN',l_object_type);
                    fnd_message.set_token('OZF_TP_OBJECT_ID_TOKEN',l_object_id);
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

         UPDATE OZF_PRODUCT_ALLOCATIONS p
                SET p.TARGET = p.TARGET + l_diff_target,
                    p.object_version_number = p.object_version_number + 1,
                    p.last_update_date = SYSDATE,
                    p.last_updated_by = FND_GLOBAL.USER_ID,
                    p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE p.product_allocation_id = l_temp_product_allocation_id;

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_ROUNDING_PROD_ERR');
                    fnd_message.set_token('OZF_TP_OBJECT_TYPE_TOKEN',l_object_type);
                    fnd_message.set_token('OZF_TP_OBJECT_ID_TOKEN',l_object_id);
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

/*---------------------------------------------------------------------------------------------------
            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id) from OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'PROD'
                                            AND x.allocation_for_id IN ( SELECT p.product_allocation_id
                                                                         FROM  OZF_PRODUCT_ALLOCATIONS p
                                                                         WHERE p.allocation_for = 'CUST'
                                                                           AND p.allocation_for_id = l_account_allocation_id
                                                                           AND p.item_id = -9999 )
                                           );


              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

         UPDATE OZF_PRODUCT_ALLOCATIONS p
                SET p.TARGET = p.TARGET + l_diff_target,
                    p.object_version_number = p.object_version_number + 1,
                    p.last_update_date = SYSDATE,
                    p.last_updated_by = FND_GLOBAL.USER_ID,
                    p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE p.allocation_for = 'CUST'
                AND p.allocation_for_id = l_account_allocation_id
        AND p.item_id = -9999;

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;
---------------------------------------------------------------------------------------------------
*/



   ELSE
     null;
   END IF;
 END fix_product_rounding_err;






-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: create fact product spread
-- Desc: C O M M E N T I N G on May 17th, 2004.
--       Check the new Prodedure below.
--       Uncomment this if Root's Product Spread is to be considered
--       as the basis of creating Facts Product Spread.
-- -----------------------------------------------------------------
 PROCEDURE create_old_fact_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fact_id            IN          NUMBER
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'create_old_fact_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; --:= TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));  Bugfix7540057
   l_fact_id                NUMBER;
   l_fund_id                NUMBER;
   l_start_date             VARCHAR2(30) := null;
   l_end_date               VARCHAR2(30) := null;
   l_period_type_id         NUMBER;
   l_in_clause              VARCHAR2(1000) := null;
   l_lysp_in_clause         VARCHAR2(1000) := null;
   l_total_target           NUMBER;
   l_territory_id           NUMBER;
   l_resource_id            NUMBER;
   l_lysp_sales             NUMBER;
   l_total_lysp_sales       NUMBER;
   l_total_root_quota       NUMBER;
   l_time_quota             NUMBER;
   l_total_quota            NUMBER;
   l_multiplying_factor     NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;
   l_diff_target            NUMBER;
   l_diff_target_1          NUMBER;
   l_diff_target_2          NUMBER;

   l_period_tbl          OZF_TIME_API_PVT.G_period_tbl_type;
   l_lysp_period_tbl     OZF_TIME_API_PVT.G_period_tbl_type;

   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;


  CURSOR fact_csr
         (l_fact_id        number) IS
  SELECT
      activity_metric_fact_id,
      act_metric_used_by_id,
      arc_act_metric_used_by,
      activity_metric_id,
      hierarchy_id,
      hierarchy_type,
      node_id,
      previous_fact_id,
      recommend_total_amount,
      status_code
  FROM
      OZF_ACT_METRIC_FACTS_ALL
  WHERE
      activity_metric_fact_id = l_fact_id;

  l_fact_rec      fact_csr%ROWTYPE;

  CURSOR allocation_csr
         (l_allocation_id        number) IS
  SELECT
     activity_metric_id,
     arc_act_metric_used_by,
     act_metric_used_by_id,
     product_spread_time_id  period_type_id,  -- (eg.. 32 for monthly, 64 for quarterly),
     published_flag,
     status_code,
     start_period_name,
     end_period_name,
     from_date,
     to_date
  FROM
      OZF_ACT_METRICS_ALL
  WHERE
      activity_metric_id = l_allocation_id;

  l_allocation_rec      allocation_csr%ROWTYPE;


  CURSOR fund_csr (l_fund_id  NUMBER) IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
   FROM
    ozf_funds_all_vl
   WHERE
    fund_id = l_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;

/*
  CURSOR get_total_target_csr
        (l_fund_id   NUMBER,
     l_in_clause VARCHAR2) IS
   SELECT SUM(t.target)
   FROM
       ozf_time_allocations t,
       ozf_product_allocations p
   WHERE
       p.fund_id = l_fund_id
   AND t.allocation_for_id   = p.product_allocation_id
   AND t.allocation_for      = 'PROD'
   AND t.time_id IN (l_in_clause);
*/

  l_get_total_target_sql VARCHAR2(30000) :=
   ' SELECT SUM(t.target) '||
   ' FROM '||
   '     ozf_time_allocations t,'||
   '     ozf_product_allocations p'||
   ' WHERE'||
   '     p.fund_id = :l_fund_id'||
   ' AND t.allocation_for_id   = p.product_allocation_id'||
   ' AND t.allocation_for      = ''PROD'' '||
   ' AND t.time_id IN (';
--l_in_clause);

  get_total_target_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable)


   CURSOR root_product_spread_csr
         (l_fund_id        number) IS
    SELECT
       p.product_allocation_id,
       p.item_id,
       p.item_type
    FROM
       ozf_product_allocations p
    WHERE
       p.fund_id = l_fund_id;

   l_root_product_rec     root_product_spread_csr%rowtype;

   CURSOR root_time_spread_csr
         (l_product_allocation_id       number,
          l_time_id                     number) IS
   SELECT t.target
   FROM
       ozf_time_allocations t
   WHERE
       t.allocation_for_id = l_product_allocation_id
   AND t.allocation_for = 'PROD'
   AND t.time_id = l_time_id;

   l_root_time_rec     root_time_spread_csr%rowtype;


  CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                                 l_territory_id  NUMBER,
                                 l_time_id       NUMBER) IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ams_party_market_segments a
   WHERE
        a.market_qualifier_reference = l_territory_id
    AND a.market_qualifier_type='TERRITORY'
    AND a.site_use_id = bsmv.ship_to_site_use_id
    AND bsmv.inventory_item_id = l_product_id
    AND bsmv.time_id = l_time_id;


  CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                  l_territory_id   NUMBER,
                                  l_time_id        NUMBER,
                                  l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND bsmv.inventory_item_id IN
                             ( SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                               FROM   MTL_ITEM_CATEGORIES     MIC,
                                      ENI_PROD_DENORM_HRCHY_V DENORM
                               WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                                AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                                AND   DENORM.PARENT_ID     = l_category_id
                               MINUS
                               SELECT p.item_id
                               FROM   ozf_product_allocations p
                               WHERE  p.fund_id = l_fund_id
                                  AND p.item_type = 'PRICING_ATTRIBUTE1'
                             );


  CURSOR others_lysp_sales_csr (l_territory_id   NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND NOT EXISTS
  (
  ( SELECT p.item_id
    FROM ozf_product_allocations p
    WHERE
        p.fund_id = l_fund_id
    AND p.item_type = 'PRICING_ATTRIBUTE1'
    AND p.item_id = bsmv.inventory_item_id
    UNION ALL
    SELECT MIC.INVENTORY_ITEM_ID
    FROM   MTL_ITEM_CATEGORIES MIC,
           ENI_PROD_DENORM_HRCHY_V DENORM,
           OZF_PRODUCT_ALLOCATIONS p
    WHERE p.FUND_ID = l_fund_id
      AND p.ITEM_TYPE = 'PRICING_ATTRIBUTE2'
      AND p.ITEM_ID = DENORM.PARENT_ID
      AND MIC.CATEGORY_SET_ID = DENORM.CATEGORY_SET_ID
      AND MIC.CATEGORY_ID = DENORM.CHILD_ID
      AND MIC.INVENTORY_ITEM_ID = bsmv.inventory_item_id
  )
  MINUS
  SELECT prod.inventory_item_id
  FROM ams_act_products prod
  where
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'Y'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  );



 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT create_old_fact_product_spread;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fact_id := p_fact_id;

   OPEN fact_csr(l_fact_id);
   FETCH fact_csr INTO l_fact_rec;
   CLOSE fact_csr ;

   l_territory_id := l_fact_rec.node_id;

   l_org_id := get_org_id(l_territory_id);    --Bugfix 7540057

   OPEN allocation_csr(l_fact_rec.activity_metric_id);
   FETCH allocation_csr INTO l_allocation_rec;
   CLOSE allocation_csr ;

   l_fund_id := l_allocation_rec.act_metric_used_by_id; -- this is ROOT's Fund_id
   l_period_type_id := l_allocation_rec.period_type_id;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   IF l_period_type_id <> l_fund_rec.period_type_id THEN
      RAISE OZF_TP_DIFF_TIME_SPREAD;
   END IF;

   l_start_date := to_char(l_allocation_rec.from_date, 'YYYY/MM/DD');
   l_end_date   := to_char(l_allocation_rec.to_date, 'YYYY/MM/DD');

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Getting Time_ids Between '
                                                 ||l_start_date||' AND '||l_end_date||' ; '
                                                 ||' Period_Type_id = '||l_period_type_id||' ; ');

   IF l_start_date IS NULL OR
      l_end_date IS NULL OR
      l_period_type_id IS NULL
   THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   l_period_tbl := OZF_TIME_API_PVT.get_period_tbl
                                    (l_start_date,
                                     l_end_date,
                                     l_period_type_id);


   IF l_period_tbl IS NULL OR l_period_tbl.COUNT <= 0 THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Getting Time_ids Between '||l_start_date
                                         ||' AND '||l_end_date||' ; ');
   IF l_period_tbl IS NOT NULL THEN
    IF l_period_tbl.COUNT > 0 THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
        IF l_period_tbl.exists(l_idx) THEN

         l_lysp_period_tbl(l_idx) := OZF_TIME_API_PVT.get_lysp_id (l_period_tbl(l_idx), l_period_type_id);

         OZF_UTILITY_PVT.debug_message(SubStr('l_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_period_tbl(l_idx)), 1,255));
         OZF_UTILITY_PVT.debug_message(SubStr('l_lysp_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_lysp_period_tbl(l_idx)), 1,255));
        END IF;
      END LOOP;
    END IF;
   END IF;

   --OZF_UTILITY_PVT.debug_message(' out of  lysp period table');

   --l_in_clause := '(';
   l_in_clause := NULL;
   IF l_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
          IF l_in_clause IS NULL THEN
             l_in_clause := LTRIM(' '||l_period_tbl(l_idx));
          ELSE
             l_in_clause := l_in_clause ||','|| l_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_in_clause := l_in_clause||')';

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': l_in_clause == '||l_in_clause);

   --l_lysp_in_clause := '(';
   l_lysp_in_clause := NULL;
   IF l_lysp_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_lysp_period_tbl.first..l_lysp_period_tbl.last
      LOOP
          IF l_lysp_in_clause IS NULL THEN
             l_lysp_in_clause := LTRIM(' '||l_lysp_period_tbl(l_idx));
          ELSE
             l_lysp_in_clause := l_lysp_in_clause ||','|| l_lysp_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_lysp_in_clause := l_lysp_in_clause||')';

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': l_lysp_in_clause == '||l_lysp_in_clause);

   l_get_total_target_sql := l_get_total_target_sql||l_in_clause ||')';

   OPEN get_total_target_csr FOR l_get_total_target_sql USING l_fund_id;
   FETCH get_total_target_csr INTO l_total_root_quota;
   CLOSE get_total_target_csr ;


   l_total_root_quota := NVL(l_total_root_quota, 0);

   IF l_total_root_quota > 0 THEN
      l_multiplying_factor :=  NVL(l_fact_rec.recommend_total_amount, 0) / l_total_root_quota;
   ELSE
      l_multiplying_factor := 0;
   END IF;


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Multiplying Factor is '||  l_multiplying_factor);


------- Insert rows for PRODUCT and TIME Allocation Records for given FACT ------------------------------


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Populating Product and Time Allocations Records'
                                         || 'FOR Fact_id = '|| l_fact_id || ' ; ');

   FOR root_product_rec IN root_product_spread_csr(l_fund_id)
   LOOP

       p_prod_alloc_rec := NULL;

       l_product_allocation_id := get_product_allocation_id;

       p_prod_alloc_rec.allocation_for := 'FACT';
       p_prod_alloc_rec.allocation_for_id := l_fact_id;
       p_prod_alloc_rec.item_type := root_product_rec.item_type;
       p_prod_alloc_rec.item_id := root_product_rec.item_id;
       p_prod_alloc_rec.selected_flag := 'N';
       p_prod_alloc_rec.target := 0;
       p_prod_alloc_rec.lysp_sales := 0;


       Ozf_Product_Allocations_Pkg.Insert_Row(
          px_product_allocation_id  => l_product_allocation_id,
          p_allocation_for  => p_prod_alloc_rec.allocation_for,
          p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
          p_fund_id  => p_prod_alloc_rec.fund_id,
          p_item_type  => p_prod_alloc_rec.item_type,
          p_item_id  => p_prod_alloc_rec.item_id,
          p_selected_flag  => p_prod_alloc_rec.selected_flag,
          p_target  => NVL(p_prod_alloc_rec.target, 0),
          p_lysp_sales  => NVL(p_prod_alloc_rec.lysp_sales, 0),
          p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_attribute_category  => p_prod_alloc_rec.attribute_category,
          p_attribute1  => p_prod_alloc_rec.attribute1,
          p_attribute2  => p_prod_alloc_rec.attribute2,
          p_attribute3  => p_prod_alloc_rec.attribute3,
          p_attribute4  => p_prod_alloc_rec.attribute4,
          p_attribute5  => p_prod_alloc_rec.attribute5,
          p_attribute6  => p_prod_alloc_rec.attribute6,
          p_attribute7  => p_prod_alloc_rec.attribute7,
          p_attribute8  => p_prod_alloc_rec.attribute8,
          p_attribute9  => p_prod_alloc_rec.attribute9,
          p_attribute10  => p_prod_alloc_rec.attribute10,
          p_attribute11  => p_prod_alloc_rec.attribute11,
          p_attribute12  => p_prod_alloc_rec.attribute12,
          p_attribute13  => p_prod_alloc_rec.attribute13,
          p_attribute14  => p_prod_alloc_rec.attribute14,
          p_attribute15  => p_prod_alloc_rec.attribute15,
          px_org_id  => l_org_id
        );


       l_total_lysp_sales := 0;
       l_total_quota := 0;


       FOR l_idx IN l_period_tbl.first..l_period_tbl.last
       LOOP
        IF l_period_tbl.exists(l_idx) THEN

           p_time_alloc_rec := NULL;

           OPEN root_time_spread_csr(root_product_rec.product_allocation_id, l_period_tbl(l_idx));
           FETCH root_time_spread_csr INTO l_root_time_rec;
           CLOSE root_time_spread_csr ;


           l_root_time_rec.target := NVL(l_root_time_rec.target, 0);

           l_time_quota := ROUND( (NVL(l_root_time_rec.target, 0) * l_multiplying_factor), 0);
           l_total_quota := l_total_quota + l_time_quota;

           l_lysp_sales := 0;

           IF root_product_rec.item_type = 'PRICING_ATTRIBUTE1' THEN
              OPEN product_lysp_sales_csr(root_product_rec.item_id,
                                          l_territory_id,
                                          l_lysp_period_tbl(l_idx)
                                         );
              FETCH product_lysp_sales_csr INTO l_lysp_sales;
              CLOSE product_lysp_sales_csr;
           ELSIF root_product_rec.item_type = 'PRICING_ATTRIBUTE2' THEN
               OPEN category_lysp_sales_csr(root_product_rec.item_id,
                                            l_territory_id,
                                            l_lysp_period_tbl(l_idx),
                                            l_fund_id
                                           );
               FETCH category_lysp_sales_csr INTO l_lysp_sales;
               CLOSE category_lysp_sales_csr;
           ELSIF root_product_rec.item_type = 'OTHERS' THEN
               OPEN others_lysp_sales_csr(l_territory_id,
                                          l_lysp_period_tbl(l_idx),
                                          l_fund_id
                                         );
               FETCH others_lysp_sales_csr INTO l_lysp_sales;
               CLOSE others_lysp_sales_csr;
           END IF;

           l_lysp_sales := NVL(l_lysp_sales, 0);
           l_total_lysp_sales := l_total_lysp_sales + l_lysp_sales;

           l_time_allocation_id := get_time_allocation_id;

           p_time_alloc_rec.allocation_for := 'PROD';
           p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
           p_time_alloc_rec.time_id := l_period_tbl(l_idx);
           p_time_alloc_rec.period_type_id := l_period_type_id;
           p_time_alloc_rec.target := NVL(l_time_quota, 0);
           p_time_alloc_rec.lysp_sales := NVL(l_lysp_sales, 0);


           Ozf_Time_Allocations_Pkg.Insert_Row(
              px_time_allocation_id  => l_time_allocation_id,
              p_allocation_for  => p_time_alloc_rec.allocation_for,
              p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
              p_time_id  => p_time_alloc_rec.time_id,
              p_period_type_id => p_time_alloc_rec.period_type_id,
              p_target  => NVL(p_time_alloc_rec.target, 0),
              p_lysp_sales  => NVL(p_time_alloc_rec.lysp_sales, 0),
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_time_alloc_rec.attribute_category,
              p_attribute1  => p_time_alloc_rec.attribute1,
              p_attribute2  => p_time_alloc_rec.attribute2,
              p_attribute3  => p_time_alloc_rec.attribute3,
              p_attribute4  => p_time_alloc_rec.attribute4,
              p_attribute5  => p_time_alloc_rec.attribute5,
              p_attribute6  => p_time_alloc_rec.attribute6,
              p_attribute7  => p_time_alloc_rec.attribute7,
              p_attribute8  => p_time_alloc_rec.attribute8,
              p_attribute9  => p_time_alloc_rec.attribute9,
              p_attribute10  => p_time_alloc_rec.attribute10,
              p_attribute11  => p_time_alloc_rec.attribute11,
              p_attribute12  => p_time_alloc_rec.attribute12,
              p_attribute13  => p_time_alloc_rec.attribute13,
              p_attribute14  => p_time_alloc_rec.attribute14,
              p_attribute15  => p_time_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


         END IF;
       END LOOP;

       UPDATE OZF_PRODUCT_ALLOCATIONS p
       SET p.lysp_sales = l_total_lysp_sales,
           p.target = ROUND( l_total_quota, 0),
           p.object_version_number = p.object_version_number + 1,
           p.last_update_date = SYSDATE,
           p.last_updated_by = FND_GLOBAL.USER_ID,
           p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
       WHERE p.product_allocation_id = l_product_allocation_id;

   END LOOP;


-------BEGIN: ORIGINAL FIX for difference due to ROUNDING --------------------------------------------------|

         l_diff_target   := 0;
         l_diff_target_1 := 0;

     BEGIN


              SELECT SUM(p.TARGET) INTO l_diff_target_1
              FROM OZF_PRODUCT_ALLOCATIONS p
               WHERE p.allocation_for = 'FACT'
                 AND p.allocation_for_id = l_fact_id;

             l_diff_target := ROUND((NVL(l_fact_rec.recommend_total_amount, 0) - NVL(l_diff_target_1, 0)), 0);

         EXCEPTION
            WHEN OTHERS THEN
                 l_diff_target := 0;
         END;

     IF l_diff_target <> 0 THEN

            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id) from OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'PROD'
                                            AND x.allocation_for_id IN ( SELECT p.product_allocation_id
                                                                         FROM  OZF_PRODUCT_ALLOCATIONS p
                                                                         WHERE p.allocation_for = 'FACT'
                                                                           AND p.allocation_for_id = l_fact_id
                                                                           AND p.item_id = -9999 )
                                           );

             IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_ROUNDING_TIME_ERR');
                    fnd_message.set_token('OZF_TP_OBJECT_TYPE_TOKEN','FACT');
                    fnd_message.set_token('OZF_TP_OBJECT_ID_TOKEN',l_fact_id);
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
             END IF;


         UPDATE OZF_PRODUCT_ALLOCATIONS p
                SET p.TARGET = p.TARGET + l_diff_target,
                    p.object_version_number = p.object_version_number + 1,
                    p.last_update_date = SYSDATE,
                    p.last_updated_by = FND_GLOBAL.USER_ID,
                    p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE p.allocation_for = 'FACT'
                AND p.allocation_for_id = l_fact_id
        AND p.item_id = -9999;

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_ROUNDING_PROD_ERR');
                    fnd_message.set_token('OZF_TP_OBJECT_TYPE_TOKEN','FACT');
                    fnd_message.set_token('OZF_TP_OBJECT_ID_TOKEN',l_fact_id);
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

      END IF;

--------END: ORIGINAL FIX for difference due to ROUNDING --------------------------------------------------|



   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Populating Product and Time Allocations Records'
                                         || 'FOR Fact_id = '|| l_fact_id || ' ; ');

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN OZF_TP_DIFF_TIME_SPREAD THEN
          ROLLBACK TO create_old_fact_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_DIFF_TIME_SPREAD_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : TIME SPREAD MISMATCH EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_DIFF_TIME_SPREAD_TXT'));

     WHEN OZF_TP_BLANK_PERIOD_TBL THEN
          ROLLBACK TO create_old_fact_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_BLANK_PERIOD_TBL_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : BLANK PERIOD TABLE EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_BLANK_PERIOD_TBL_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO create_old_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO create_old_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO create_old_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END create_old_fact_product_spread;




-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: create fact product spread
-- Desc: Setup product spread for a given Fact
--       This Allocation WorkSheet Fact emerged from an Allocation done
--       by a Root Node or Creator Node
--       Updated on May17th,2004 -
--          Per new requirements in Bug 3594874.
--          Facts Product Spread should not be based on Root's Product Spread.
--          Instead, it should be based on that Territories LYSP sales.
-- -----------------------------------------------------------------
 PROCEDURE create_fact_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fact_id            IN          NUMBER
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'create_fact_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; -- := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)); --Bugfix7540057
   l_fact_id                NUMBER;
   l_fund_id                NUMBER;
   l_start_date             VARCHAR2(30) := null;
   l_end_date               VARCHAR2(30) := null;
   l_period_type_id         NUMBER;
   l_in_clause              VARCHAR2(1000) := null;
   l_lysp_in_clause         VARCHAR2(1000) := null;
   l_total_target           NUMBER;
   l_territory_id           NUMBER;
   l_resource_id            NUMBER;
   l_lysp_sales             NUMBER;
   l_total_lysp_sales       NUMBER;
   l_grand_total_lysp_sales NUMBER;
   l_denominator            NUMBER;
   l_total_root_quota       NUMBER;
   l_time_quota             NUMBER;
   l_total_quota            NUMBER;
   l_multiplying_factor     NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;
   l_diff_target            NUMBER;
   l_diff_target_1          NUMBER;
   l_diff_target_2          NUMBER;

   l_period_tbl          OZF_TIME_API_PVT.G_period_tbl_type;
   l_lysp_period_tbl     OZF_TIME_API_PVT.G_period_tbl_type;

   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;


  CURSOR fact_csr
         (l_fact_id        number) IS
  SELECT
      activity_metric_fact_id,
      act_metric_used_by_id,
      arc_act_metric_used_by,
      activity_metric_id,
      hierarchy_id,
      hierarchy_type,
      node_id,
      previous_fact_id,
      recommend_total_amount,
      status_code
  FROM
      OZF_ACT_METRIC_FACTS_ALL
  WHERE
      activity_metric_fact_id = l_fact_id;

  l_fact_rec      fact_csr%ROWTYPE;

  CURSOR allocation_csr
         (l_allocation_id        number) IS
  SELECT
     activity_metric_id,
     arc_act_metric_used_by,
     act_metric_used_by_id,
     product_spread_time_id  period_type_id,  -- (eg.. 32 for monthly, 64 for quarterly),
     published_flag,
     status_code,
     start_period_name,
     end_period_name,
     from_date,
     to_date
  FROM
      OZF_ACT_METRICS_ALL
  WHERE
      activity_metric_id = l_allocation_id;

  l_allocation_rec      allocation_csr%ROWTYPE;


  CURSOR fund_csr (l_fund_id  NUMBER) IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
    FROM
    ozf_funds_all_vl
   WHERE
    fund_id = l_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;

/*
  CURSOR get_total_target_csr
        (l_fund_id   NUMBER,
     l_in_clause VARCHAR2) IS
   SELECT SUM(t.target)
   FROM
       ozf_time_allocations t,
       ozf_product_allocations p
   WHERE
       p.fund_id = l_fund_id
   AND t.allocation_for_id   = p.product_allocation_id
   AND t.allocation_for      = 'PROD'
   AND t.time_id IN (l_in_clause);
*/

  l_get_total_target_sql VARCHAR2(30000) :=
   ' SELECT SUM(t.target) '||
   ' FROM '||
   '     ozf_time_allocations t,'||
   '     ozf_product_allocations p'||
   ' WHERE'||
   '     p.fund_id = :l_fund_id'||
   ' AND t.allocation_for_id   = p.product_allocation_id'||
   ' AND t.allocation_for      = ''PROD'' '||
   ' AND t.time_id IN (';
--l_in_clause);

  get_total_target_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable)


   CURSOR root_product_spread_csr
         (l_fund_id        number) IS
    SELECT
       p.product_allocation_id,
       p.item_id,
       p.item_type
    FROM
       ozf_product_allocations p
    WHERE
       p.fund_id = l_fund_id;

   l_root_product_rec     root_product_spread_csr%rowtype;

   CURSOR root_time_spread_csr
         (l_product_allocation_id       number,
          l_time_id                     number) IS
   SELECT t.target
   FROM
       ozf_time_allocations t
   WHERE
       t.allocation_for_id = l_product_allocation_id
   AND t.allocation_for = 'PROD'
   AND t.time_id = l_time_id;

   l_root_time_rec     root_time_spread_csr%rowtype;


  CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                                 l_territory_id  NUMBER,
                                 l_time_id       NUMBER) IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ams_party_market_segments a
   WHERE
        a.market_qualifier_reference = l_territory_id
    AND a.market_qualifier_type='TERRITORY'
    AND a.site_use_id = bsmv.ship_to_site_use_id
    AND bsmv.inventory_item_id = l_product_id
    AND bsmv.time_id = l_time_id;


  CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                  l_territory_id   NUMBER,
                                  l_time_id        NUMBER,
                                  l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND bsmv.inventory_item_id IN
                             ( SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                               FROM   MTL_ITEM_CATEGORIES     MIC,
                                      ENI_PROD_DENORM_HRCHY_V DENORM
                               WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                                AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                                AND   DENORM.PARENT_ID     = l_category_id
                               MINUS
                               SELECT p.item_id
                               FROM   ozf_product_allocations p
                               WHERE  p.fund_id = l_fund_id
                                  AND p.item_type = 'PRICING_ATTRIBUTE1'
                             );


  CURSOR others_lysp_sales_csr (l_territory_id   NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND NOT EXISTS
  (
  ( SELECT p.item_id
    FROM ozf_product_allocations p
    WHERE
        p.fund_id = l_fund_id
    AND p.item_type = 'PRICING_ATTRIBUTE1'
    AND p.item_id = bsmv.inventory_item_id
    UNION ALL
    SELECT MIC.INVENTORY_ITEM_ID
    FROM   MTL_ITEM_CATEGORIES MIC,
           ENI_PROD_DENORM_HRCHY_V DENORM,
           OZF_PRODUCT_ALLOCATIONS p
    WHERE p.FUND_ID = l_fund_id
      AND p.ITEM_TYPE = 'PRICING_ATTRIBUTE2'
      AND p.ITEM_ID = DENORM.PARENT_ID
      AND MIC.CATEGORY_SET_ID = DENORM.CATEGORY_SET_ID
      AND MIC.CATEGORY_ID = DENORM.CHILD_ID
      AND MIC.INVENTORY_ITEM_ID = bsmv.inventory_item_id
  )
  MINUS
  SELECT prod.inventory_item_id
  FROM ams_act_products prod
  where
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'Y'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  );



 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT create_fact_product_spread;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fact_id := p_fact_id;

   OPEN fact_csr(l_fact_id);
   FETCH fact_csr INTO l_fact_rec;
   CLOSE fact_csr ;

   l_territory_id := l_fact_rec.node_id;

   l_org_id := get_org_id(l_territory_id);    --Bugfix 7540057

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Territory Id => '
                                                 || l_territory_id ||' ; ');

   OPEN allocation_csr(l_fact_rec.activity_metric_id);
   FETCH allocation_csr INTO l_allocation_rec;
   CLOSE allocation_csr ;

   l_fund_id := l_allocation_rec.act_metric_used_by_id; -- this is ROOT's Fund_id
   l_period_type_id := l_allocation_rec.period_type_id;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   IF l_period_type_id <> l_fund_rec.period_type_id THEN
      RAISE OZF_TP_DIFF_TIME_SPREAD;
   END IF;

   l_start_date := to_char(l_allocation_rec.from_date, 'YYYY/MM/DD');
   l_end_date   := to_char(l_allocation_rec.to_date, 'YYYY/MM/DD');

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Getting Time_ids Between '
                                                 ||l_start_date||' AND '||l_end_date||' ; '
                                                 ||' Period_Type_id = '||l_period_type_id||' ; ');

   IF l_start_date IS NULL OR
      l_end_date IS NULL OR
      l_period_type_id IS NULL
   THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   l_period_tbl := OZF_TIME_API_PVT.get_period_tbl
                                    (l_start_date,
                                     l_end_date,
                                     l_period_type_id);


   IF l_period_tbl IS NULL OR l_period_tbl.COUNT <= 0 THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Getting Time_ids Between '||l_start_date
                                         ||' AND '||l_end_date||' ; ');
   IF l_period_tbl IS NOT NULL THEN
    IF l_period_tbl.COUNT > 0 THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
        IF l_period_tbl.exists(l_idx) THEN

         l_lysp_period_tbl(l_idx) := OZF_TIME_API_PVT.get_lysp_id (l_period_tbl(l_idx), l_period_type_id);

         OZF_UTILITY_PVT.debug_message(SubStr('l_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_period_tbl(l_idx)), 1,255));
         OZF_UTILITY_PVT.debug_message(SubStr('l_lysp_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_lysp_period_tbl(l_idx)), 1,255));
        END IF;
      END LOOP;
    END IF;
   END IF;

   --OZF_UTILITY_PVT.debug_message(' out of  lysp period table');

   --l_in_clause := '(';
   l_in_clause := NULL;
   IF l_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
          IF l_in_clause IS NULL THEN
             l_in_clause := LTRIM(' '||l_period_tbl(l_idx));
          ELSE
             l_in_clause := l_in_clause ||','|| l_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_in_clause := l_in_clause||')';

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': l_in_clause == '||l_in_clause);

   --l_lysp_in_clause := '(';
   l_lysp_in_clause := NULL;
   IF l_lysp_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_lysp_period_tbl.first..l_lysp_period_tbl.last
      LOOP
          IF l_lysp_in_clause IS NULL THEN
             l_lysp_in_clause := LTRIM(' '||l_lysp_period_tbl(l_idx));
          ELSE
             l_lysp_in_clause := l_lysp_in_clause ||','|| l_lysp_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_lysp_in_clause := l_lysp_in_clause||')';

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': l_lysp_in_clause == '||l_lysp_in_clause);

--//00000 May17th,2004 - as per new requirements in Bug 3594874 000000000000000000000000000000000000
/*
   l_get_total_target_sql := l_get_total_target_sql||l_in_clause ||')';

   OPEN get_total_target_csr FOR l_get_total_target_sql USING l_fund_id;
   FETCH get_total_target_csr INTO l_total_root_quota;
   CLOSE get_total_target_csr ;


   l_total_root_quota := NVL(l_total_root_quota, 0);

   IF l_total_root_quota > 0 THEN
      l_multiplying_factor :=  NVL(l_fact_rec.recommend_total_amount, 0) / l_total_root_quota;
   ELSE
      l_multiplying_factor := 0;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Multiplying Factor is '||  l_multiplying_factor);
*/
--//0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000


------- Insert rows for PRODUCT and TIME Allocation Records for given FACT ------------------------------


   l_grand_total_lysp_sales := 0;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Populating Product and Time Allocations Records'
                                         || 'FOR Fact_id = '|| l_fact_id || ' ; ');

   FOR root_product_rec IN root_product_spread_csr(l_fund_id)
   LOOP

       p_prod_alloc_rec := NULL;

       l_product_allocation_id := get_product_allocation_id;

       p_prod_alloc_rec.allocation_for := 'FACT';
       p_prod_alloc_rec.allocation_for_id := l_fact_id;
       p_prod_alloc_rec.item_type := root_product_rec.item_type;
       p_prod_alloc_rec.item_id := root_product_rec.item_id;
       p_prod_alloc_rec.selected_flag := 'N';
       p_prod_alloc_rec.target := 0;
       p_prod_alloc_rec.lysp_sales := 0;


       Ozf_Product_Allocations_Pkg.Insert_Row(
          px_product_allocation_id  => l_product_allocation_id,
          p_allocation_for  => p_prod_alloc_rec.allocation_for,
          p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
          p_fund_id  => p_prod_alloc_rec.fund_id,
          p_item_type  => p_prod_alloc_rec.item_type,
          p_item_id  => p_prod_alloc_rec.item_id,
          p_selected_flag  => p_prod_alloc_rec.selected_flag,
          p_target  => NVL(p_prod_alloc_rec.target, 0),
          p_lysp_sales  => NVL(p_prod_alloc_rec.lysp_sales, 0),
          p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_attribute_category  => p_prod_alloc_rec.attribute_category,
          p_attribute1  => p_prod_alloc_rec.attribute1,
          p_attribute2  => p_prod_alloc_rec.attribute2,
          p_attribute3  => p_prod_alloc_rec.attribute3,
          p_attribute4  => p_prod_alloc_rec.attribute4,
          p_attribute5  => p_prod_alloc_rec.attribute5,
          p_attribute6  => p_prod_alloc_rec.attribute6,
          p_attribute7  => p_prod_alloc_rec.attribute7,
          p_attribute8  => p_prod_alloc_rec.attribute8,
          p_attribute9  => p_prod_alloc_rec.attribute9,
          p_attribute10  => p_prod_alloc_rec.attribute10,
          p_attribute11  => p_prod_alloc_rec.attribute11,
          p_attribute12  => p_prod_alloc_rec.attribute12,
          p_attribute13  => p_prod_alloc_rec.attribute13,
          p_attribute14  => p_prod_alloc_rec.attribute14,
          p_attribute15  => p_prod_alloc_rec.attribute15,
          px_org_id  => l_org_id
        );


       l_total_lysp_sales := 0;
       l_total_quota := 0;


       FOR l_idx IN l_period_tbl.first..l_period_tbl.last
       LOOP
        IF l_period_tbl.exists(l_idx) THEN

           p_time_alloc_rec := NULL;

--//00000 May17th,2004 - as per new requirements in Bug 3594874 000000000000000000000000000000000000
/*
           OPEN root_time_spread_csr(root_product_rec.product_allocation_id, l_period_tbl(l_idx));
           FETCH root_time_spread_csr INTO l_root_time_rec;
           CLOSE root_time_spread_csr ;


           l_root_time_rec.target := NVL(l_root_time_rec.target, 0);

           l_time_quota := ROUND( (NVL(l_root_time_rec.target, 0) * l_multiplying_factor), 0);
           l_total_quota := l_total_quota + l_time_quota;
*/
--//000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

           l_lysp_sales := 0;

           IF root_product_rec.item_type = 'PRICING_ATTRIBUTE1' THEN
              OPEN product_lysp_sales_csr(root_product_rec.item_id,
                                          l_territory_id,
                                          l_lysp_period_tbl(l_idx)
                                         );
              FETCH product_lysp_sales_csr INTO l_lysp_sales;
              CLOSE product_lysp_sales_csr;
           ELSIF root_product_rec.item_type = 'PRICING_ATTRIBUTE2' THEN
               OPEN category_lysp_sales_csr(root_product_rec.item_id,
                                            l_territory_id,
                                            l_lysp_period_tbl(l_idx),
                                            l_fund_id
                                           );
               FETCH category_lysp_sales_csr INTO l_lysp_sales;
               CLOSE category_lysp_sales_csr;
           ELSIF root_product_rec.item_type = 'OTHERS' THEN
               OPEN others_lysp_sales_csr(l_territory_id,
                                          l_lysp_period_tbl(l_idx),
                                          l_fund_id
                                         );
               FETCH others_lysp_sales_csr INTO l_lysp_sales;
               CLOSE others_lysp_sales_csr;
           END IF;

           l_lysp_sales := NVL(l_lysp_sales, 0);
           l_total_lysp_sales := l_total_lysp_sales + l_lysp_sales;

           l_time_allocation_id := get_time_allocation_id;

           p_time_alloc_rec.allocation_for := 'PROD';
           p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
           p_time_alloc_rec.time_id := l_period_tbl(l_idx);
           p_time_alloc_rec.period_type_id := l_period_type_id;
           p_time_alloc_rec.target := 0;  --------NVL(l_time_quota, 0);
           p_time_alloc_rec.lysp_sales := NVL(l_lysp_sales, 0);


           Ozf_Time_Allocations_Pkg.Insert_Row(
              px_time_allocation_id  => l_time_allocation_id,
              p_allocation_for  => p_time_alloc_rec.allocation_for,
              p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
              p_time_id  => p_time_alloc_rec.time_id,
              p_period_type_id => p_time_alloc_rec.period_type_id,
              p_target  => NVL(p_time_alloc_rec.target, 0),
              p_lysp_sales  => NVL(p_time_alloc_rec.lysp_sales, 0),
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_time_alloc_rec.attribute_category,
              p_attribute1  => p_time_alloc_rec.attribute1,
              p_attribute2  => p_time_alloc_rec.attribute2,
              p_attribute3  => p_time_alloc_rec.attribute3,
              p_attribute4  => p_time_alloc_rec.attribute4,
              p_attribute5  => p_time_alloc_rec.attribute5,
              p_attribute6  => p_time_alloc_rec.attribute6,
              p_attribute7  => p_time_alloc_rec.attribute7,
              p_attribute8  => p_time_alloc_rec.attribute8,
              p_attribute9  => p_time_alloc_rec.attribute9,
              p_attribute10  => p_time_alloc_rec.attribute10,
              p_attribute11  => p_time_alloc_rec.attribute11,
              p_attribute12  => p_time_alloc_rec.attribute12,
              p_attribute13  => p_time_alloc_rec.attribute13,
              p_attribute14  => p_time_alloc_rec.attribute14,
              p_attribute15  => p_time_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


         END IF;
       END LOOP;

       UPDATE OZF_PRODUCT_ALLOCATIONS p
       SET p.lysp_sales = l_total_lysp_sales,
           p.object_version_number = p.object_version_number + 1,
           p.last_update_date = SYSDATE,
           p.last_updated_by = FND_GLOBAL.USER_ID,
           p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
       WHERE p.product_allocation_id = l_product_allocation_id;

       l_grand_total_lysp_sales := l_grand_total_lysp_sales + l_total_lysp_sales;

   END LOOP;


------ Updating Target ----------------------------------------------------------------

   l_multiplying_factor := 0;
   IF l_grand_total_lysp_sales > 0 THEN
      l_multiplying_factor := NVL(l_fact_rec.recommend_total_amount, 0) / l_grand_total_lysp_sales;
   ELSE
      l_multiplying_factor := 0;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Multiplying Factor is '||  l_multiplying_factor);

   UPDATE OZF_TIME_ALLOCATIONS t
   SET t.TARGET = ROUND((NVL(t.LYSP_SALES, 0) * l_multiplying_factor), 0),
       t.object_version_number = t.object_version_number + 1,
       t.last_update_date = SYSDATE,
       t.last_updated_by = FND_GLOBAL.USER_ID,
       t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE  t.allocation_for = 'PROD'
   AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                 FROM  OZF_PRODUCT_ALLOCATIONS p
                                 WHERE p.allocation_for = 'FACT'
                                   AND p.allocation_for_id = l_fact_id );

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
         fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   UPDATE OZF_PRODUCT_ALLOCATIONS p
   SET p.TARGET = (SELECT SUM(ti.TARGET)
                     FROM OZF_TIME_ALLOCATIONS ti
                    WHERE ti.ALLOCATION_FOR = 'PROD'
                      AND ti.ALLOCATION_FOR_ID = p.PRODUCT_ALLOCATION_ID),
       p.object_version_number = p.object_version_number + 1,
       p.last_update_date = SYSDATE,
       p.last_updated_by = FND_GLOBAL.USER_ID,
       p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE p.allocation_for = 'FACT'
     AND p.allocation_for_id = l_fact_id;

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
         fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;



   -- Handling Corner Case : If all products including others have ZERO lysp sales, then
   --                        OTHERS get all the Quota. It is equally distributed in all
   --                        time periods.

   IF l_multiplying_factor = 0 THEN

      l_denominator := l_period_tbl.COUNT;

/*
      UPDATE OZF_PRODUCT_ALLOCATIONS p
      SET p.TARGET = ROUND(NVL(l_fact_rec.recommend_total_amount, 0),0),
          p.object_version_number = p.object_version_number + 1,
          p.last_update_date = SYSDATE,
          p.last_updated_by = FND_GLOBAL.USER_ID,
          p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE p.allocation_for = 'FACT'
        AND p.allocation_for_id = l_fact_id
        AND p.item_id = -9999;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
      UPDATE OZF_TIME_ALLOCATIONS t
      SET t.TARGET = ROUND((NVL(l_fact_rec.recommend_total_amount, 0) / l_denominator), 0),
          t.object_version_number = t.object_version_number + 1,
          t.last_update_date = SYSDATE,
          t.last_updated_by = FND_GLOBAL.USER_ID,
          t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE  t.allocation_for = 'PROD'
      AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                    FROM  OZF_PRODUCT_ALLOCATIONS p
                                    WHERE p.allocation_for = 'FACT'
                                      AND p.allocation_for_id = l_fact_id
                                      AND p.item_id = -9999 );

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      UPDATE OZF_PRODUCT_ALLOCATIONS p
      SET p.TARGET = (SELECT SUM(ti.TARGET)
                        FROM OZF_TIME_ALLOCATIONS ti
                       WHERE ti.ALLOCATION_FOR = 'PROD'
                         AND ti.ALLOCATION_FOR_ID = p.PRODUCT_ALLOCATION_ID),
          p.object_version_number = p.object_version_number + 1,
          p.last_update_date = SYSDATE,
          p.last_updated_by = FND_GLOBAL.USER_ID,
          p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE p.allocation_for = 'FACT'
        AND p.allocation_for_id = l_fact_id
        AND p.item_id = -9999;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


   END IF;



---BEGIN: ORIGINAL FIX for difference due to ROUNDING --------------------------------------------------|

   l_diff_target   := 0;
   l_diff_target_1 := 0;

   BEGIN

       SELECT SUM(p.TARGET) INTO l_diff_target_1
       FROM OZF_PRODUCT_ALLOCATIONS p
       WHERE p.allocation_for = 'FACT'
       AND p.allocation_for_id = l_fact_id;

       l_diff_target := (NVL(l_fact_rec.recommend_total_amount, 0) - NVL(l_diff_target_1, 0));

   EXCEPTION
       WHEN OTHERS THEN
            l_diff_target := 0;
   END;

   IF ABS(l_diff_target) >= 1 THEN

      IF SIGN(l_diff_target) = -1 THEN
         l_diff_target := CEIL(l_diff_target); -- (So, -1.5 will become -1 )
      ELSE
         l_diff_target := FLOOR(l_diff_target); -- (So, +1.5 will become +1)
      END IF;

      fix_product_rounding_err('FACT', l_fact_id, l_diff_target);

/*
            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id) from OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'PROD'
                                            AND x.allocation_for_id IN ( SELECT p.product_allocation_id
                                                                         FROM  OZF_PRODUCT_ALLOCATIONS p
                                                                         WHERE p.allocation_for = 'FACT'
                                                                           AND p.allocation_for_id = l_fact_id
                                                                           AND p.item_id = -9999 )
                                           );


              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

         UPDATE OZF_PRODUCT_ALLOCATIONS p
                SET p.TARGET = p.TARGET + l_diff_target,
                    p.object_version_number = p.object_version_number + 1,
                    p.last_update_date = SYSDATE,
                    p.last_updated_by = FND_GLOBAL.USER_ID,
                    p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE p.allocation_for = 'FACT'
                AND p.allocation_for_id = l_fact_id
        AND p.item_id = -9999;

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;
*/


   END IF;

---END: ORIGINAL FIX for difference due to ROUNDING --------------------------------------------------|



   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Populating Product and Time Allocations Records'
                                         || 'FOR Fact_id = '|| l_fact_id || ' ; ');

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN OZF_TP_DIFF_TIME_SPREAD THEN
          ROLLBACK TO create_fact_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_DIFF_TIME_SPREAD_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : TIME SPREAD MISMATCH EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_DIFF_TIME_SPREAD_TXT'));

     WHEN OZF_TP_BLANK_PERIOD_TBL THEN
          ROLLBACK TO create_fact_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_BLANK_PERIOD_TBL_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : BLANK PERIOD TABLE EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_BLANK_PERIOD_TBL_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO create_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO create_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO create_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END create_fact_product_spread;







-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: create root product spread
-- Desc: Setup product spread for Root Node or any Creator Node
-- -----------------------------------------------------------------
 PROCEDURE create_root_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id            IN          NUMBER
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'create_root_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER ; --:= TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));   --Bugfix7540057
   l_fund_id                NUMBER;
   l_start_date             VARCHAR2(30) := null;
   l_end_date               VARCHAR2(30) := null;
   l_period_type_id         NUMBER;
   l_in_clause              VARCHAR2(1000) := null;
   l_territory_id           NUMBER;
   l_resource_id            NUMBER;
   l_lysp_sales             NUMBER;
   l_total_lysp_sales       NUMBER;
   l_grand_total_lysp_sales NUMBER;
   l_total_root_quota       NUMBER;
   l_multiplying_factor     NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;
   l_denominator            NUMBER;
   l_diff_target            NUMBER;
   l_diff_target_1          NUMBER;
   l_diff_target_2          NUMBER;

   l_period_tbl          OZF_TIME_API_PVT.G_period_tbl_type;
   l_lysp_period_tbl     OZF_TIME_API_PVT.G_period_tbl_type;

   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;


CURSOR fund_csr (l_fund_id  NUMBER) IS
 SELECT
  owner,
  start_period_id,
  end_period_id,
  start_date_active,
  end_date_active,
  status_code,
  original_budget,
  transfered_in_amt,
  transfered_out_amt,
  node_id, -- (=territory id)
  product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
 FROM
  ozf_funds_all_vl
 WHERE
  fund_id = l_fund_id;

l_fund_rec    fund_csr%ROWTYPE;

CURSOR territory_csr (l_resource_id NUMBER) IS
 SELECT
  j.terr_id territory_id
 FROM
  jtf_terr_rsc_all j, jtf_terr_rsc_access_all j2
 WHERE
     j.resource_id = l_resource_id
-- AND j.primary_contact_flag = 'Y' ;
 AND j2.terr_rsc_id = j.terr_rsc_id
 AND j2.access_type = 'OFFER'
 AND j2.trans_access_code = 'PRIMARY_CONTACT';

l_territory_rec territory_csr%ROWTYPE;

CURSOR product_elig_csr (l_fund_id NUMBER) IS
 SELECT
  inventory_item_id
 FROM
  ams_act_products
 WHERE
     act_product_used_by_id = l_fund_id
 AND arc_act_product_used_by = 'FUND'
 AND level_type_code = 'PRODUCT'
 AND NVL(excluded_flag,'N') = 'N';

CURSOR category_elig_csr (l_fund_id NUMBER) IS
 SELECT
  category_id
 FROM
  ams_act_products
 WHERE
     act_product_used_by_id = l_fund_id
 AND arc_act_product_used_by = 'FUND'
 AND level_type_code = 'FAMILY'
 AND NVL(excluded_flag,'N') = 'N';


CURSOR excluded_product_elig_csr (l_fund_id NUMBER) IS
 SELECT
  inventory_item_id
 FROM
  ams_act_products
 WHERE
     act_product_used_by_id = l_fund_id
 AND arc_act_product_used_by = 'FUND'
 AND level_type_code = 'PRODUCT'
 AND excluded_flag ='Y';

CURSOR excluded_category_elig_csr (l_fund_id NUMBER) IS
 SELECT
  category_id
 FROM
  ams_act_products
 WHERE
     act_product_used_by_id = l_fund_id
 AND arc_act_product_used_by = 'FUND'
 AND level_type_code = 'FAMILY'
 AND excluded_flag ='Y';


CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                               l_territory_id  NUMBER,
                               l_time_id       NUMBER) IS
 SELECT
  SUM(bsmv.sales) sales
 FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
 WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.inventory_item_id = l_product_id
  AND bsmv.time_id = l_time_id;


CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                l_territory_id   NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
SELECT
 SUM(bsmv.sales) sales
FROM
 ozf_order_sales_v bsmv,
 ams_party_market_segments a
WHERE
    a.market_qualifier_reference = l_territory_id
AND a.market_qualifier_type='TERRITORY'
AND bsmv.ship_to_site_use_id = a.site_use_id
AND bsmv.time_id = l_time_id
AND bsmv.inventory_item_id IN
                           ( SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                             FROM   MTL_ITEM_CATEGORIES     MIC,
                                    ENI_PROD_DENORM_HRCHY_V DENORM
                             WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                              AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                              AND   DENORM.PARENT_ID     = l_category_id
                             MINUS
                             SELECT a.inventory_item_id
                             FROM  ams_act_products a
                             WHERE act_product_used_by_id = l_fund_id
                              AND arc_act_product_used_by = 'FUND'
                              AND level_type_code = 'PRODUCT'
                              AND excluded_flag IN  ('Y', 'N')
                           );


CURSOR others_lysp_sales_csr (l_territory_id   NUMBER,
                              l_time_id        NUMBER,
                              l_fund_id        NUMBER) IS
SELECT
 SUM(bsmv.sales) sales
FROM
 ozf_order_sales_v bsmv,
 ams_party_market_segments a
WHERE
    a.market_qualifier_reference = l_territory_id
AND a.market_qualifier_type='TERRITORY'
AND bsmv.ship_to_site_use_id = a.site_use_id
AND bsmv.time_id = l_time_id
AND NOT EXISTS
(
( SELECT prod.inventory_item_id
  FROM ams_act_products prod
  WHERE
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'N'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  UNION ALL
  SELECT MIC.INVENTORY_ITEM_ID
  FROM   MTL_ITEM_CATEGORIES MIC,
         ENI_PROD_DENORM_HRCHY_V DENORM,
         AMS_ACT_PRODUCTS prod
  WHERE
    prod.level_type_code = 'FAMILY'
AND prod.arc_act_product_used_by = 'FUND'
AND prod.act_product_used_by_id = l_fund_id
AND prod.excluded_flag = 'N'
AND prod.category_id = DENORM.PARENT_ID
AND MIC.CATEGORY_SET_ID = DENORM.CATEGORY_SET_ID
AND MIC.CATEGORY_ID = DENORM.CHILD_ID
AND MIC.INVENTORY_ITEM_ID = bsmv.inventory_item_id
)
MINUS
SELECT prod.inventory_item_id
FROM ams_act_products prod
where
    prod.level_type_code = 'PRODUCT'
AND prod.arc_act_product_used_by = 'FUND'
AND prod.act_product_used_by_id = l_fund_id
AND prod.excluded_flag = 'Y'
AND prod.inventory_item_id = bsmv.inventory_item_id
);


 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT create_root_product_spread;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fund_id := p_fund_id;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   l_resource_id := l_fund_rec.owner;
   l_territory_id := l_fund_rec.node_id;

   IF l_territory_id IS NULL THEN
      OPEN territory_csr(l_resource_id);
      FETCH territory_csr INTO l_territory_id;
      CLOSE territory_csr ;
   END IF;

   l_org_id := get_org_id(l_territory_id);    --Bugfix 7540057

   l_start_date := to_char(l_fund_rec.start_date_active, 'YYYY/MM/DD');
   l_end_date   := to_char(l_fund_rec.end_date_active, 'YYYY/MM/DD');
   l_period_type_id := l_fund_rec.period_type_id;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Getting Time_ids Between '
                                                 ||l_start_date||' AND '||l_end_date||' ; '
                                                 ||' Period_Type_id = '||l_period_type_id||' ; ');

   IF l_start_date IS NULL OR
      l_end_date IS NULL OR
      l_period_type_id IS NULL
   THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   l_period_tbl := OZF_TIME_API_PVT.get_period_tbl
                                    (l_start_date,
                                     l_end_date,
                                     l_period_type_id);

   IF l_period_tbl IS NULL OR l_period_tbl.COUNT <= 0 THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Getting Time_ids Between '||l_start_date
                                         ||' AND '||l_end_date||' ; ');
   IF l_period_tbl IS NOT NULL THEN
    IF l_period_tbl.COUNT > 0 THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
        IF l_period_tbl.exists(l_idx) THEN

         l_lysp_period_tbl(l_idx) := OZF_TIME_API_PVT.get_lysp_id (l_period_tbl(l_idx), l_period_type_id);

         OZF_UTILITY_PVT.debug_message(SubStr('l_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_period_tbl(l_idx)), 1,255));
         OZF_UTILITY_PVT.debug_message(SubStr('l_lysp_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_lysp_period_tbl(l_idx)), 1,255));
        END IF;
      END LOOP;
    END IF;
   END IF;


   l_in_clause := '(';
   IF l_lysp_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_lysp_period_tbl.first..l_lysp_period_tbl.last
      LOOP
        IF l_lysp_period_tbl.exists(l_idx) THEN
          IF l_in_clause = '(' THEN
             l_in_clause := l_in_clause || l_lysp_period_tbl(l_idx);
          ELSE
             l_in_clause := l_in_clause ||','|| l_lysp_period_tbl(l_idx);
          END IF;
        END IF;
      END LOOP;
   END IF;
   l_in_clause := l_in_clause||')';

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': l_in_clause == '||l_in_clause);

------- Insert rows for PRODUCTS  ------------------------------------------------

   l_grand_total_lysp_sales := 0;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Populating Product and Time Allocations Records'
                                         || 'FOR Fund_id = '|| l_fund_id || ' ; ');

   FOR product_rec IN product_elig_csr(l_fund_id)
   LOOP
       p_prod_alloc_rec := NULL;

       l_product_allocation_id := get_product_allocation_id;

       p_prod_alloc_rec.allocation_for := 'FUND';
       p_prod_alloc_rec.allocation_for_id := l_fund_id;
       p_prod_alloc_rec.fund_id := l_fund_id;
       p_prod_alloc_rec.item_type := 'PRICING_ATTRIBUTE1';
       p_prod_alloc_rec.item_id := product_rec.inventory_item_id;
       p_prod_alloc_rec.selected_flag := 'N';
       p_prod_alloc_rec.target := 0;
       p_prod_alloc_rec.lysp_sales := 0;


       Ozf_Product_Allocations_Pkg.Insert_Row(
          px_product_allocation_id  => l_product_allocation_id,
          p_allocation_for  => p_prod_alloc_rec.allocation_for,
          p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
          p_fund_id  => p_prod_alloc_rec.fund_id,
          p_item_type  => p_prod_alloc_rec.item_type,
          p_item_id  => p_prod_alloc_rec.item_id,
          p_selected_flag  => p_prod_alloc_rec.selected_flag,
          p_target  => NVL(p_prod_alloc_rec.target, 0),
          p_lysp_sales  => NVL(p_prod_alloc_rec.lysp_sales, 0),
          p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_attribute_category  => p_prod_alloc_rec.attribute_category,
          p_attribute1  => p_prod_alloc_rec.attribute1,
          p_attribute2  => p_prod_alloc_rec.attribute2,
          p_attribute3  => p_prod_alloc_rec.attribute3,
          p_attribute4  => p_prod_alloc_rec.attribute4,
          p_attribute5  => p_prod_alloc_rec.attribute5,
          p_attribute6  => p_prod_alloc_rec.attribute6,
          p_attribute7  => p_prod_alloc_rec.attribute7,
          p_attribute8  => p_prod_alloc_rec.attribute8,
          p_attribute9  => p_prod_alloc_rec.attribute9,
          p_attribute10  => p_prod_alloc_rec.attribute10,
          p_attribute11  => p_prod_alloc_rec.attribute11,
          p_attribute12  => p_prod_alloc_rec.attribute12,
          p_attribute13  => p_prod_alloc_rec.attribute13,
          p_attribute14  => p_prod_alloc_rec.attribute14,
          p_attribute15  => p_prod_alloc_rec.attribute15,
          px_org_id  => l_org_id
        );


       l_total_lysp_sales := 0;

       FOR l_idx IN l_period_tbl.first..l_period_tbl.last
       LOOP
        IF l_period_tbl.exists(l_idx) THEN

           p_time_alloc_rec := NULL;

           l_lysp_sales := 0;
           OPEN product_lysp_sales_csr(product_rec.inventory_item_id,
                                       l_territory_id,
                                       l_lysp_period_tbl(l_idx)
                                      );
           FETCH product_lysp_sales_csr INTO l_lysp_sales;
           CLOSE product_lysp_sales_csr;

           l_lysp_sales := NVL(l_lysp_sales, 0);

           l_total_lysp_sales := l_total_lysp_sales + l_lysp_sales;

           l_time_allocation_id := get_time_allocation_id;

           p_time_alloc_rec.allocation_for := 'PROD';
           p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
           p_time_alloc_rec.time_id := l_period_tbl(l_idx);
           p_time_alloc_rec.period_type_id := l_period_type_id;
           p_time_alloc_rec.target := 0;
           p_time_alloc_rec.lysp_sales := l_lysp_sales;


           Ozf_Time_Allocations_Pkg.Insert_Row(
              px_time_allocation_id  => l_time_allocation_id,
              p_allocation_for  => p_time_alloc_rec.allocation_for,
              p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
              p_time_id  => p_time_alloc_rec.time_id,
              p_period_type_id => p_time_alloc_rec.period_type_id,
              p_target  =>NVL( p_time_alloc_rec.target, 0),
              p_lysp_sales  => NVL(p_time_alloc_rec.lysp_sales, 0),
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_time_alloc_rec.attribute_category,
              p_attribute1  => p_time_alloc_rec.attribute1,
              p_attribute2  => p_time_alloc_rec.attribute2,
              p_attribute3  => p_time_alloc_rec.attribute3,
              p_attribute4  => p_time_alloc_rec.attribute4,
              p_attribute5  => p_time_alloc_rec.attribute5,
              p_attribute6  => p_time_alloc_rec.attribute6,
              p_attribute7  => p_time_alloc_rec.attribute7,
              p_attribute8  => p_time_alloc_rec.attribute8,
              p_attribute9  => p_time_alloc_rec.attribute9,
              p_attribute10  => p_time_alloc_rec.attribute10,
              p_attribute11  => p_time_alloc_rec.attribute11,
              p_attribute12  => p_time_alloc_rec.attribute12,
              p_attribute13  => p_time_alloc_rec.attribute13,
              p_attribute14  => p_time_alloc_rec.attribute14,
              p_attribute15  => p_time_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


         END IF;
       END LOOP;

       UPDATE OZF_PRODUCT_ALLOCATIONS p
       SET p.lysp_sales = NVL(l_total_lysp_sales,0),
           p.object_version_number = p.object_version_number + 1,
           p.last_update_date = SYSDATE,
           p.last_updated_by = FND_GLOBAL.USER_ID,
           p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
       WHERE p.product_allocation_id = l_product_allocation_id;

       l_grand_total_lysp_sales := l_grand_total_lysp_sales + l_total_lysp_sales;
   END LOOP;


------- Insert rows for CATEGORIES  ----------------------------------------------


   FOR category_rec IN category_elig_csr(l_fund_id)
   LOOP

       p_prod_alloc_rec := NULL;

       l_product_allocation_id := get_product_allocation_id;


       p_prod_alloc_rec.allocation_for := 'FUND';
       p_prod_alloc_rec.allocation_for_id := l_fund_id;
       p_prod_alloc_rec.fund_id := l_fund_id;
       p_prod_alloc_rec.item_type := 'PRICING_ATTRIBUTE2';
       p_prod_alloc_rec.item_id := category_rec.category_id;
       p_prod_alloc_rec.selected_flag := 'N';
       p_prod_alloc_rec.target := 0;
       p_prod_alloc_rec.lysp_sales := 0;


       Ozf_Product_Allocations_Pkg.Insert_Row(
          px_product_allocation_id  => l_product_allocation_id,
          p_allocation_for  => p_prod_alloc_rec.allocation_for,
          p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
          p_fund_id  => p_prod_alloc_rec.fund_id,
          p_item_type  => p_prod_alloc_rec.item_type,
          p_item_id  => p_prod_alloc_rec.item_id,
          p_selected_flag  => p_prod_alloc_rec.selected_flag,
          p_target  => NVL(p_prod_alloc_rec.target,0),
          p_lysp_sales  => NVL(p_prod_alloc_rec.lysp_sales, 0),
          p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_attribute_category  => p_prod_alloc_rec.attribute_category,
          p_attribute1  => p_prod_alloc_rec.attribute1,
          p_attribute2  => p_prod_alloc_rec.attribute2,
          p_attribute3  => p_prod_alloc_rec.attribute3,
          p_attribute4  => p_prod_alloc_rec.attribute4,
          p_attribute5  => p_prod_alloc_rec.attribute5,
          p_attribute6  => p_prod_alloc_rec.attribute6,
          p_attribute7  => p_prod_alloc_rec.attribute7,
          p_attribute8  => p_prod_alloc_rec.attribute8,
          p_attribute9  => p_prod_alloc_rec.attribute9,
          p_attribute10  => p_prod_alloc_rec.attribute10,
          p_attribute11  => p_prod_alloc_rec.attribute11,
          p_attribute12  => p_prod_alloc_rec.attribute12,
          p_attribute13  => p_prod_alloc_rec.attribute13,
          p_attribute14  => p_prod_alloc_rec.attribute14,
          p_attribute15  => p_prod_alloc_rec.attribute15,
          px_org_id  => l_org_id
        );

       l_total_lysp_sales := 0;

       FOR l_idx IN l_period_tbl.first..l_period_tbl.last
       LOOP
        IF l_period_tbl.exists(l_idx) THEN

           p_time_alloc_rec := NULL;

           l_lysp_sales := 0;
           OPEN category_lysp_sales_csr(category_rec.category_id,
                                        l_territory_id,
                                        l_lysp_period_tbl(l_idx),
                                        l_fund_id
                                       );
           FETCH category_lysp_sales_csr INTO l_lysp_sales;
           CLOSE category_lysp_sales_csr;

           l_lysp_sales := NVL(l_lysp_sales, 0);

           l_total_lysp_sales := l_total_lysp_sales + l_lysp_sales;

           l_time_allocation_id := get_time_allocation_id;

           p_time_alloc_rec.allocation_for := 'PROD';
           p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
           p_time_alloc_rec.time_id := l_period_tbl(l_idx);
           p_time_alloc_rec.period_type_id := l_period_type_id;
           p_time_alloc_rec.target := 0;
           p_time_alloc_rec.lysp_sales := l_lysp_sales;


           Ozf_Time_Allocations_Pkg.Insert_Row(
              px_time_allocation_id  => l_time_allocation_id,
              p_allocation_for  => p_time_alloc_rec.allocation_for,
              p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
              p_time_id  => p_time_alloc_rec.time_id,
              p_period_type_id => p_time_alloc_rec.period_type_id,
              p_target  => NVL(p_time_alloc_rec.target, 0),
              p_lysp_sales  => NVL(p_time_alloc_rec.lysp_sales, 0),
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_time_alloc_rec.attribute_category,
              p_attribute1  => p_time_alloc_rec.attribute1,
              p_attribute2  => p_time_alloc_rec.attribute2,
              p_attribute3  => p_time_alloc_rec.attribute3,
              p_attribute4  => p_time_alloc_rec.attribute4,
              p_attribute5  => p_time_alloc_rec.attribute5,
              p_attribute6  => p_time_alloc_rec.attribute6,
              p_attribute7  => p_time_alloc_rec.attribute7,
              p_attribute8  => p_time_alloc_rec.attribute8,
              p_attribute9  => p_time_alloc_rec.attribute9,
              p_attribute10  => p_time_alloc_rec.attribute10,
              p_attribute11  => p_time_alloc_rec.attribute11,
              p_attribute12  => p_time_alloc_rec.attribute12,
              p_attribute13  => p_time_alloc_rec.attribute13,
              p_attribute14  => p_time_alloc_rec.attribute14,
              p_attribute15  => p_time_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


         END IF;
       END LOOP;

       UPDATE OZF_PRODUCT_ALLOCATIONS p
       SET p.lysp_sales = NVL(l_total_lysp_sales, 0),
           p.object_version_number = p.object_version_number + 1,
           p.last_update_date = SYSDATE,
           p.last_updated_by = FND_GLOBAL.USER_ID,
           p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
       WHERE p.product_allocation_id = l_product_allocation_id;

       l_grand_total_lysp_sales := l_grand_total_lysp_sales + l_total_lysp_sales;
   END LOOP;



------- Insert rows for OTHERS ---------------------------------------------------

       p_prod_alloc_rec := NULL;

       l_product_allocation_id := get_product_allocation_id;

       p_prod_alloc_rec.allocation_for := 'FUND';
       p_prod_alloc_rec.allocation_for_id := l_fund_id;
       p_prod_alloc_rec.fund_id := l_fund_id;
       p_prod_alloc_rec.item_type := 'OTHERS';
       p_prod_alloc_rec.item_id := -9999;
       p_prod_alloc_rec.selected_flag := 'N';
       p_prod_alloc_rec.target := 0;
       p_prod_alloc_rec.lysp_sales := 0;


       Ozf_Product_Allocations_Pkg.Insert_Row(
          px_product_allocation_id  => l_product_allocation_id,
          p_allocation_for  => p_prod_alloc_rec.allocation_for,
          p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
          p_fund_id  => p_prod_alloc_rec.fund_id,
          p_item_type  => p_prod_alloc_rec.item_type,
          p_item_id  => p_prod_alloc_rec.item_id,
          p_selected_flag  => p_prod_alloc_rec.selected_flag,
          p_target  => NVL(p_prod_alloc_rec.target, 0),
          p_lysp_sales  => NVL(p_prod_alloc_rec.lysp_sales, 0),
          p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_attribute_category  => p_prod_alloc_rec.attribute_category,
          p_attribute1  => p_prod_alloc_rec.attribute1,
          p_attribute2  => p_prod_alloc_rec.attribute2,
          p_attribute3  => p_prod_alloc_rec.attribute3,
          p_attribute4  => p_prod_alloc_rec.attribute4,
          p_attribute5  => p_prod_alloc_rec.attribute5,
          p_attribute6  => p_prod_alloc_rec.attribute6,
          p_attribute7  => p_prod_alloc_rec.attribute7,
          p_attribute8  => p_prod_alloc_rec.attribute8,
          p_attribute9  => p_prod_alloc_rec.attribute9,
          p_attribute10  => p_prod_alloc_rec.attribute10,
          p_attribute11  => p_prod_alloc_rec.attribute11,
          p_attribute12  => p_prod_alloc_rec.attribute12,
          p_attribute13  => p_prod_alloc_rec.attribute13,
          p_attribute14  => p_prod_alloc_rec.attribute14,
          p_attribute15  => p_prod_alloc_rec.attribute15,
          px_org_id  => l_org_id
        );
   l_total_lysp_sales := 0;

   FOR l_idx IN l_period_tbl.first..l_period_tbl.last
   LOOP
     IF l_period_tbl.exists(l_idx) THEN

        p_time_alloc_rec := NULL;

        l_lysp_sales := 0;
        OPEN others_lysp_sales_csr(l_territory_id,
                                   l_lysp_period_tbl(l_idx),
                                   l_fund_id
                                  );
        FETCH others_lysp_sales_csr INTO l_lysp_sales;
        CLOSE others_lysp_sales_csr;

        l_lysp_sales := NVL(l_lysp_sales, 0);

        l_total_lysp_sales := l_total_lysp_sales + l_lysp_sales;

        l_time_allocation_id := get_time_allocation_id;

        p_time_alloc_rec.allocation_for := 'PROD';
        p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
        p_time_alloc_rec.time_id := l_period_tbl(l_idx);
        p_time_alloc_rec.period_type_id := l_period_type_id;
        p_time_alloc_rec.target := 0;
        p_time_alloc_rec.lysp_sales := l_lysp_sales;


        Ozf_Time_Allocations_Pkg.Insert_Row(
           px_time_allocation_id  => l_time_allocation_id,
           p_allocation_for  => p_time_alloc_rec.allocation_for,
           p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
           p_time_id  => p_time_alloc_rec.time_id,
           p_period_type_id => p_time_alloc_rec.period_type_id,
           p_target  => NVL(p_time_alloc_rec.target, 0),
           p_lysp_sales  => NVL(p_time_alloc_rec.lysp_sales, 0),
           px_object_version_number  => l_object_version_number,
           p_creation_date  => SYSDATE,
           p_created_by  => FND_GLOBAL.USER_ID,
           p_last_update_date  => SYSDATE,
           p_last_updated_by  => FND_GLOBAL.USER_ID,
           p_last_update_login  => FND_GLOBAL.conc_login_id,
           p_attribute_category  => p_time_alloc_rec.attribute_category,
           p_attribute1  => p_time_alloc_rec.attribute1,
           p_attribute2  => p_time_alloc_rec.attribute2,
           p_attribute3  => p_time_alloc_rec.attribute3,
           p_attribute4  => p_time_alloc_rec.attribute4,
           p_attribute5  => p_time_alloc_rec.attribute5,
           p_attribute6  => p_time_alloc_rec.attribute6,
           p_attribute7  => p_time_alloc_rec.attribute7,
           p_attribute8  => p_time_alloc_rec.attribute8,
           p_attribute9  => p_time_alloc_rec.attribute9,
           p_attribute10  => p_time_alloc_rec.attribute10,
           p_attribute11  => p_time_alloc_rec.attribute11,
           p_attribute12  => p_time_alloc_rec.attribute12,
           p_attribute13  => p_time_alloc_rec.attribute13,
           p_attribute14  => p_time_alloc_rec.attribute14,
           p_attribute15  => p_time_alloc_rec.attribute15,
           px_org_id  => l_org_id
         );


      END IF;
    END LOOP;

    UPDATE OZF_PRODUCT_ALLOCATIONS p
    SET p.lysp_sales = NVL(l_total_lysp_sales, 0),
        p.object_version_number = p.object_version_number + 1,
        p.last_update_date = SYSDATE,
        p.last_updated_by = FND_GLOBAL.USER_ID,
        p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
    WHERE p.product_allocation_id = l_product_allocation_id;

    l_grand_total_lysp_sales := l_grand_total_lysp_sales + l_total_lysp_sales;



   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Populating Product and Time Allocations Records'
                                         || 'FOR Fund_id = '|| l_fund_id || ' ; ');

------ Updating Target ----------------------------------------------------------------

   l_total_root_quota := 0;
   l_total_root_quota := NVL(l_fund_rec.original_budget, 0) + NVL(l_fund_rec.transfered_in_amt, 0);

   l_total_root_quota := NVL(l_total_root_quota, 0);

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Total Root Quota'
                                         || 'FOR Fund_id = '|| l_fund_id || 'is == ' ||l_total_root_quota||' ;');

   l_multiplying_factor := 0;
   IF l_grand_total_lysp_sales > 0 THEN
      l_multiplying_factor := l_total_root_quota / l_grand_total_lysp_sales;
   ELSE
      l_multiplying_factor := 0;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Multiplying Factor == '
                                         ||l_multiplying_factor||' ;');
/*
   UPDATE OZF_PRODUCT_ALLOCATIONS p
   SET p.TARGET = ROUND( (NVL(p.LYSP_SALES, 0) * l_multiplying_factor), 0),
       p.object_version_number = p.object_version_number + 1,
       p.last_update_date = SYSDATE,
       p.last_updated_by = FND_GLOBAL.USER_ID,
       p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE p.allocation_for = 'FUND'
     AND p.allocation_for_id = l_fund_id;

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
         fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
*/

   UPDATE OZF_TIME_ALLOCATIONS t
   SET t.TARGET = ROUND((NVL(t.LYSP_SALES, 0) * l_multiplying_factor), 0),
       t.object_version_number = t.object_version_number + 1,
       t.last_update_date = SYSDATE,
       t.last_updated_by = FND_GLOBAL.USER_ID,
       t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE  t.allocation_for = 'PROD'
   AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                 FROM  OZF_PRODUCT_ALLOCATIONS p
                                 WHERE p.allocation_for = 'FUND'
                                   AND p.allocation_for_id = l_fund_id );

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
         fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   UPDATE OZF_PRODUCT_ALLOCATIONS p
   SET p.TARGET = (SELECT SUM(ti.TARGET)
                     FROM OZF_TIME_ALLOCATIONS ti
                    WHERE ti.ALLOCATION_FOR = 'PROD'
                      AND ti.ALLOCATION_FOR_ID = p.PRODUCT_ALLOCATION_ID),
       p.object_version_number = p.object_version_number + 1,
       p.last_update_date = SYSDATE,
       p.last_updated_by = FND_GLOBAL.USER_ID,
       p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE p.allocation_for = 'FUND'
     AND p.allocation_for_id = l_fund_id;

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
         fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;





   -- Handling Corner Case : If all products including others have ZERO lysp sales, then
   --                        OTHERS get all the Quota. It is equally distributed in all
   --                        time periods.

   IF l_multiplying_factor = 0 THEN

      l_denominator := l_period_tbl.COUNT;
/*
      UPDATE OZF_PRODUCT_ALLOCATIONS p
      SET p.TARGET = ROUND( l_total_root_quota, 0),
          p.object_version_number = p.object_version_number + 1,
          p.last_update_date = SYSDATE,
          p.last_updated_by = FND_GLOBAL.USER_ID,
          p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE p.allocation_for = 'FUND'
        AND p.allocation_for_id = l_fund_id
        AND p.item_id = -9999;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
      UPDATE OZF_TIME_ALLOCATIONS t
      SET t.TARGET = ROUND((l_total_root_quota / l_denominator), 0),
          t.object_version_number = t.object_version_number + 1,
          t.last_update_date = SYSDATE,
          t.last_updated_by = FND_GLOBAL.USER_ID,
          t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE  t.allocation_for = 'PROD'
      AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                    FROM  OZF_PRODUCT_ALLOCATIONS p
                                    WHERE p.allocation_for = 'FUND'
                                      AND p.allocation_for_id = l_fund_id
                                      AND p.item_id = -9999 );

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      UPDATE OZF_PRODUCT_ALLOCATIONS p
      SET p.TARGET = (SELECT SUM(ti.TARGET)
                        FROM OZF_TIME_ALLOCATIONS ti
                       WHERE ti.ALLOCATION_FOR = 'PROD'
                         AND ti.ALLOCATION_FOR_ID = p.PRODUCT_ALLOCATION_ID),
          p.object_version_number = p.object_version_number + 1,
          p.last_update_date = SYSDATE,
          p.last_updated_by = FND_GLOBAL.USER_ID,
          p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE p.allocation_for = 'FUND'
        AND p.allocation_for_id = l_fund_id
        AND p.item_id = -9999;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


-------BEGIN: ORIGINAL FIX for difference due to ROUNDING --------------------------------------------------|


/*
      IF (MOD(l_total_root_quota,l_denominator) <> 0) THEN

         l_diff_target := 0;

         BEGIN

              SELECT p.TARGET INTO l_diff_target_1
              FROM OZF_PRODUCT_ALLOCATIONS p
               WHERE p.allocation_for = 'FUND'
                 AND p.allocation_for_id = l_fund_id
                 AND p.item_id = -9999;


              SELECT SUM(t.TARGET) INTO l_diff_target_2
              FROM OZF_TIME_ALLOCATIONS t
              WHERE  t.allocation_for = 'PROD'
                 AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                              FROM  OZF_PRODUCT_ALLOCATIONS p
                                              WHERE p.allocation_for = 'FUND'
                                                AND p.allocation_for_id = l_fund_id
                                                AND p.item_id = -9999 );

             l_diff_target := NVL(l_diff_target_1, 0) - NVL(l_diff_target_2, 0);

         EXCEPTION
            WHEN OTHERS THEN
                 l_diff_target := 0;
         END;
*/
   END IF;


/*
-------THIS Works---------------------------------------------------------------------
            SELECT (a.target-b.target) INTO l_diff_target
            FROM
            (
              SELECT p.TARGET target
              FROM OZF_PRODUCT_ALLOCATIONS p
               WHERE p.allocation_for = 'FUND'
                 AND p.allocation_for_id = l_fund_id
                 AND p.item_id = -9999
            ) a,
            (
              SELECT SUM(t.TARGET) target
              FROM OZF_TIME_ALLOCATIONS t
              WHERE  t.allocation_for = 'PROD'
                 AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                              FROM  OZF_PRODUCT_ALLOCATIONS p
                                              WHERE p.allocation_for = 'FUND'
                                                AND p.allocation_for_id = l_fund_id
                                                AND p.item_id = -9999 )
            ) b;

*/

/*
         BEGIN
            SELECT
            (
              SELECT p.TARGET
              FROM OZF_PRODUCT_ALLOCATIONS p
               WHERE p.allocation_for = 'FUND'
                 AND p.allocation_for_id = l_fund_id
                 AND p.item_id = -9999
            )
            -
            (
              SELECT SUM(t.TARGET)
              FROM OZF_TIME_ALLOCATIONS t
              WHERE  t.allocation_for = 'PROD'
                 AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                              FROM  OZF_PRODUCT_ALLOCATIONS p
                                              WHERE p.allocation_for = 'FUND'
                                                AND p.allocation_for_id = l_fund_id
                                                AND p.item_id = -9999 )
            ) diff_target INTO l_diff_target
            FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
                 l_diff_target := 0;
         END;

         OPEN fix_rounding_csr(fund_id);
         FETCH fix_rounding_csr INTO l_diff_target;
         CLOSE fix_rounding_csr;
         l_diff_target := NVL(l_diff_target, 0);
*/



       l_diff_target   := 0;
       l_diff_target_1 := 0;

       BEGIN

           SELECT SUM(p.TARGET) INTO l_diff_target_1
           FROM OZF_PRODUCT_ALLOCATIONS p
           WHERE p.allocation_for = 'FUND'
           AND p.allocation_for_id = l_fund_id;

           l_diff_target := (NVL(l_total_root_quota, 0) - NVL(l_diff_target_1, 0));

       EXCEPTION
           WHEN OTHERS THEN
                l_diff_target := 0;
       END;


       IF ABS(l_diff_target) >= 1 THEN

          IF SIGN(l_diff_target) = -1 THEN
             l_diff_target := CEIL(l_diff_target); -- (So, -1.5 will become -1 )
          ELSE
             l_diff_target := FLOOR(l_diff_target); -- (So, +1.5 will become +1)
          END IF;

          fix_product_rounding_err('FUND', l_fund_id, l_diff_target);

       END IF;

--------END: ORIGINAL FIX for difference due to ROUNDING --------------------------------------------------|


/*
--------BEGIN : NEW FIX for difference due to ROUNDING --------------------------------------------------|

      l_diff_target := 0;
      l_diff_target := MOD(l_total_root_quota,l_denominator);

      IF l_diff_target <> 0 THEN
          UPDATE OZF_TIME_ALLOCATIONS t
            SET t.TARGET = t.TARGET + l_diff_target,
                t.object_version_number = t.object_version_number + 1,
                t.last_update_date = SYSDATE,
                t.last_updated_by = FND_GLOBAL.USER_ID,
                t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
          WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id) from OZF_TIME_ALLOCATIONS x
                                        WHERE  x.allocation_for = 'PROD'
                                        AND x.allocation_for_id IN ( SELECT p.product_allocation_id
                                                                     FROM  OZF_PRODUCT_ALLOCATIONS p
                                                                     WHERE p.allocation_for = 'FUND'
                                                                       AND p.allocation_for_id = l_fund_id
                                                                       AND p.item_id = -9999 )
                                       );

          IF (SQL%NOTFOUND) THEN
             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
                fnd_msg_pub.ADD;
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;

--------END : NEW FIX for difference due to ROUNDING --------------------------------------------------|
*/



   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN OZF_TP_BLANK_PERIOD_TBL THEN
          ROLLBACK TO create_root_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_BLANK_PERIOD_TBL_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : BLANK PERIOD TABLE EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_BLANK_PERIOD_TBL_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO create_root_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO create_root_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO create_root_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END create_root_product_spread;








-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: publish fact product spread
-- Desc: Update all Product allocation records of given fact_id with new Fund_id
--       >  when Fact is Published (first time)   OR
--       >  when Fact is activated (subsequently)
-- -----------------------------------------------------------------
 PROCEDURE publish_fact_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fact_id            IN          NUMBER
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'publish_fact_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_fact_id                 NUMBER;
   l_fund_id                 NUMBER;
   l_status_code             OZF_ACT_METRIC_FACTS_ALL.status_code%TYPE;


  CURSOR fact_csr
       (l_fact_id        number) IS
  SELECT
      activity_metric_fact_id,
      act_metric_used_by_id,
      arc_act_metric_used_by,
      activity_metric_id,
      hierarchy_id,
      hierarchy_type,
      node_id,
      previous_fact_id,
      recommend_total_amount,
      status_code
  FROM
      OZF_ACT_METRIC_FACTS_ALL
  WHERE
      activity_metric_fact_id = l_fact_id;

  l_fact_rec      fact_csr%ROWTYPE;

 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT publish_fact_product_spread;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fact_id := p_fact_id;

   OPEN fact_csr(l_fact_id);
   FETCH fact_csr INTO l_fact_rec;
   CLOSE fact_csr ;

   l_status_code := l_fact_rec.status_code;

   IF l_status_code IN ('ACTIVE', 'PLANNED') THEN
      null;

--=========>>> Can do some more validation here to check if the caller JTT Quota page is not calling this by mistake
--=========>>> It should call this only after Updating the FACT record with the Newly created FUND id

   ELSE
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': STATUS of Fact Number : ' ||l_fact_id|| ' is : '||
                           l_status_code);
      RAISE OZF_TP_OPER_NOT_ALLOWED;
   END IF;


------- Start Publishing Product Allocation Records for allocations of l_fact_id -----------------------

   l_fund_id := l_fact_rec.act_metric_used_by_id;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Publishing Product Allocations Records'
                                         || 'FOR Fact_id = '|| l_fact_id || ' with NEW Fund_id = '||l_fund_id||' ; ');

   UPDATE ozf_product_allocations p
   SET p.fund_id = l_fund_id,
       p.object_version_number = p.object_version_number + 1,
       p.last_update_date = SYSDATE,
       p.last_updated_by = FND_GLOBAL.USER_ID,
       p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE p.allocation_for = 'FACT'
     AND p.allocation_for_id = l_fact_id;


/*
***** LATER: Check here  ======>  DO YOU ALSO NEED to create account spread for this newly addON-ed fact_id
                                  to the existing fund_id (for the newly added period)

*/


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Publishing Product Allocations Records'
                                         || 'FOR Fact_id = '|| l_fact_id || ' with NEW Fund_id = '||l_fund_id||' ; ');

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN OZF_TP_OPER_NOT_ALLOWED THEN
          ROLLBACK TO publish_fact_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_OPER_NOT_ALLOWED_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_OPER_NOT_ALLOWED_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO publish_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO publish_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO publish_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END publish_fact_product_spread;


-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------------
-- Name: delete fact product spread
-- Desc: Delete all Product and Time allocation records for a given fact_id
-- ------------------------------------------------------------------------
 PROCEDURE delete_fact_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fact_id            IN          NUMBER
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'delete_fact_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);
   l_fact_id                NUMBER;

   CURSOR fact_product_spread_csr
         (l_fact_id        number) IS
   SELECT DISTINCT
       p.product_allocation_id
   FROM
       ozf_product_allocations p
   WHERE
       p.allocation_for  = 'FACT'
   AND p.allocation_for_id = l_fact_id;


 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT delete_fact_product_spread;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fact_id := p_fact_id;

------- Start Deleting Product and Time Allocation Records -----------------------

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Deleting Product and Time Allocations Records'
                                         || 'FOR Fact_id = '|| l_fact_id || ' ; ');

   FOR fact_product_spread_rec IN fact_product_spread_csr(l_fact_id)
   LOOP
      DELETE ozf_time_allocations t
      WHERE t.allocation_for_id = fact_product_spread_rec.product_allocation_id
        AND t.allocation_for = 'PROD';
   END LOOP;

   DELETE ozf_product_allocations p
   WHERE  p.allocation_for  = 'FACT'
      AND p.allocation_for_id = l_fact_id;


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Deleting Product and Time Allocations Records'
                                         || 'FOR Fact_id = '|| l_fact_id || ' ; ');
   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO delete_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO delete_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO delete_fact_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END delete_fact_product_spread;


-- ------------------------
-- Private Procedure
-- ------------------------
-- --------------------------------------------------------------------
-- Name: delete cascade product spread
-- Desc: Delete all Product and Time Allocation records when Root Node
--       changes its Product_Spread_Time_Id (Monthly, Quarterly etc)
-- --------------------------------------------------------------------
 PROCEDURE delete_cascade_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id            IN          NUMBER
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'delete_cascade_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_fund_id                NUMBER;
   l_territory_id           NUMBER;
   l_resource_id            NUMBER;
   l_status_code            OZF_FUNDS_ALL_VL.status_code%TYPE;


  CURSOR fund_csr(l_fund_id  NUMBER) IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
   FROM
    ozf_funds_all_vl
   WHERE
    fund_id = l_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;

  CURSOR allocation_csr
        (l_fund_id        number) IS
  SELECT
     activity_metric_id,
     arc_act_metric_used_by,
     act_metric_used_by_id,
     product_spread_time_id  period_type_id,  -- (eg.. 32 for monthly, 64 for quarterly),
     published_flag,
     status_code,
     start_period_name,
     end_period_name,
     from_date,
     to_date
  FROM
      OZF_ACT_METRICS_ALL
  WHERE
      arc_act_metric_used_by = 'FUND'
  AND act_metric_used_by_id = l_fund_id;


  CURSOR fact_csr
       (l_allocation_id        number) IS
  SELECT
      activity_metric_fact_id,
      act_metric_used_by_id,
      arc_act_metric_used_by,
      activity_metric_id,
      hierarchy_id,
      hierarchy_type,
      node_id,
      previous_fact_id,
      recommend_total_amount,
      status_code
  FROM
      OZF_ACT_METRIC_FACTS_ALL
  WHERE
      activity_metric_id = l_allocation_id;

  CURSOR fund_product_spread_csr
         (l_fund_id        number) IS
   SELECT DISTINCT
       p.product_allocation_id
   FROM
       ozf_product_allocations p
   WHERE
       p.allocation_for  = 'FUND'
   AND p.allocation_for_id = l_fund_id
   AND p.fund_id = l_fund_id;


 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT delete_cascade_product_spread;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fund_id := p_fund_id;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   l_status_code := l_fund_rec.status_code;


   IF l_status_code IN ('DRAFT', 'PLANNING') THEN
      null;
   ELSE
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': STATUS of Root Fund Number : ' ||l_fund_id|| ' is : '||
                           l_status_code);
      RAISE OZF_TP_CHG_PS_NOT_ALLOWED;
   END IF;


------- Start Deleting Product and Time Allocation Records for allocations of l_fund_id -----------------------

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Deleting Product and Time Allocations Records'
                                         || 'FOR Allocations of Fund_id = '|| l_fund_id || ' ; ');

   FOR allocation_rec IN allocation_csr(l_fund_id)
   LOOP
       FOR fact_rec IN fact_csr(allocation_rec.activity_metric_id)
       LOOP
           delete_fact_product_spread
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fact_id            => fact_rec.activity_metric_fact_id
                         );
       END LOOP;
   END LOOP;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Deleting Product and Time Allocations Records'
                                         || 'FOR Allocations of Fund_id = '|| l_fund_id || ' ; ');

------- Start Deleting Product and Time Allocation Records for ROOT i.e. l_fund_id ----------------------


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Deleting Product and Time Allocations Records'
                                         || 'FOR Fund_id = '|| l_fund_id || ' ; ');

   FOR fund_product_spread_rec IN fund_product_spread_csr(l_fund_id)
   LOOP
      DELETE ozf_time_allocations t
      WHERE t.allocation_for_id = fund_product_spread_rec.product_allocation_id
        AND t.allocation_for = 'PROD';
   END LOOP;

   DELETE ozf_product_allocations p
   WHERE  p.allocation_for  = 'FUND'
      AND p.allocation_for_id = l_fund_id
      AND p.fund_id = l_fund_id;


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Deleting Product and Time Allocations Records'
                                         || 'FOR Fund_id = '|| l_fund_id || ' ; ');


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN OZF_TP_CHG_PS_NOT_ALLOWED THEN
          ROLLBACK TO delete_cascade_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_CHG_PS_NOT_ALLOWED_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_CHG_PS_NOT_ALLOWED_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO delete_cascade_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO delete_cascade_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO delete_cascade_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END delete_cascade_product_spread;


-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Add cascade product spread
-- Desc: When Root Node adds a Product to his Product Spread, cascade new product
--       to all facts for all his allocations. Use that facts
--       Product Spread Time Id (Monthly, Quarterly etc)
--       Note : Products for the Root Node will be added from OA UI.
-- -----------------------------------------------------------------
 PROCEDURE add_cascade_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id            IN          NUMBER,
    p_item_id            IN          NUMBER,
    p_item_type          IN          VARCHAR2
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'add_cascade_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_fund_id                NUMBER;
   l_item_id                NUMBER;
   l_item_type              VARCHAR2(30);
   l_fact_id                NUMBER;
   l_territory_id           NUMBER;
   l_status_code            OZF_FUNDS_ALL_VL.status_code%TYPE;
   l_lysp_sales             NUMBER;
   l_total_lysp_sales       NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;
   l_lysp_time_id           NUMBER;
   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; -- := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));  --Bugfix7540057

   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;


  CURSOR fund_csr(l_fund_id  NUMBER) IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
   FROM
    ozf_funds_all_vl
   WHERE
    fund_id = l_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;

  CURSOR allocation_csr
        (l_fund_id        number) IS
  SELECT
     activity_metric_id,
     arc_act_metric_used_by,
     act_metric_used_by_id,
     product_spread_time_id  period_type_id,  -- (eg.. 32 for monthly, 64 for quarterly),
     published_flag,
     status_code,
     start_period_name,
     end_period_name,
     from_date,
     to_date
  FROM
      OZF_ACT_METRICS_ALL
  WHERE
      arc_act_metric_used_by = 'FUND'
  AND act_metric_used_by_id = l_fund_id;


  CURSOR fact_csr
       (l_allocation_id        number) IS
  SELECT
      activity_metric_fact_id,
      act_metric_used_by_id,
      arc_act_metric_used_by,
      activity_metric_id,
      hierarchy_id,
      hierarchy_type,
      node_id,  ---  this is territory_id of this FACT ******* confirm this *********
      previous_fact_id,
      recommend_total_amount,
      status_code
  FROM
      OZF_ACT_METRIC_FACTS_ALL
  WHERE
      activity_metric_id = l_allocation_id;


   CURSOR prod_alloc_csr
       (l_fact_id        number) IS
   SELECT product_allocation_id,
          allocation_for,
          allocation_for_id,
          fund_id,
          item_id,
          item_type,
          target,
          lysp_sales
   FROM OZF_PRODUCT_ALLOCATIONS
   WHERE allocation_for = 'FACT'
    AND allocation_for_id = l_fact_id
    AND item_id = -9999;

   l_prod_alloc_rec  prod_alloc_csr%ROWTYPE;

   CURSOR time_alloc_csr
       (l_prod_alloc_id    number) IS
   SELECT time_allocation_id,
          allocation_for,
          allocation_for_id,
          time_id,
          period_type_id,
          target,
          lysp_sales
   FROM OZF_TIME_ALLOCATIONS
   WHERE allocation_for = 'PROD'
    AND allocation_for_id = l_prod_alloc_id;

   l_time_alloc_rec  time_alloc_csr%ROWTYPE;


   CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                                  l_territory_id  NUMBER,
                                  l_time_id       NUMBER) IS
    SELECT
     SUM(bsmv.sales) sales
    FROM
      ozf_order_sales_v bsmv,
      ams_party_market_segments a
    WHERE
         a.market_qualifier_reference = l_territory_id
     AND a.market_qualifier_type='TERRITORY'
     AND bsmv.ship_to_site_use_id = a.site_use_id
     AND bsmv.inventory_item_id = l_product_id
     AND bsmv.time_id = l_time_id;


   CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                   l_territory_id   NUMBER,
                                   l_time_id        NUMBER,
                                   l_fund_id        NUMBER) IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
    ozf_order_sales_v bsmv,
    ams_party_market_segments a
   WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY'
   AND bsmv.ship_to_site_use_id = a.site_use_id
   AND bsmv.time_id = l_time_id
   AND bsmv.inventory_item_id IN
                             (  SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                                FROM   MTL_ITEM_CATEGORIES     MIC,
                                       ENI_PROD_DENORM_HRCHY_V DENORM
                                WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                                 AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                                 AND   DENORM.PARENT_ID     = l_category_id
                                MINUS
                                SELECT a.inventory_item_id
                                FROM  ams_act_products a
                                WHERE act_product_used_by_id = l_fund_id
                                 AND arc_act_product_used_by = 'FUND'
                                 AND level_type_code = 'PRODUCT'
                                 AND excluded_flag IN  ('Y', 'N')
                              );


 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT add_cascade_product_spread;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fund_id := p_fund_id;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   l_status_code := l_fund_rec.status_code;


   IF l_status_code IN ('DRAFT', 'PLANNING') THEN
      null;
   ELSE
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': STATUS of Root Fund Number : ' ||l_fund_id|| ' is : '||
                           l_status_code);
      RAISE OZF_TP_ADDITEM_NOT_ALLOWED;
   END IF;


------- Start Adding Product and Time Allocation Records for allocations of l_fund_id -----------------------

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Adding Product and Time Allocations Records'
                                         || 'FOR Allocations of Fund_id = '|| l_fund_id || ' ; ');

   FOR allocation_rec IN allocation_csr(l_fund_id)
   LOOP
       FOR fact_rec IN fact_csr(allocation_rec.activity_metric_id)
       LOOP

           l_fact_id := fact_rec.activity_metric_fact_id;
           l_territory_id := fact_rec.node_id;
           l_org_id := get_org_id(l_territory_id);    --Bugfix 7540057

           OPEN prod_alloc_csr(l_fact_id);
           FETCH prod_alloc_csr INTO l_prod_alloc_rec;
           IF prod_alloc_csr%NOTFOUND THEN
              CLOSE prod_alloc_csr;
              OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': NO Product and Time Allocations Records exist'
                                                    || 'FOR Fact_id = '|| l_fact_id || ' ; ');
              GOTO next_fact_iteration;
           END IF;
           CLOSE prod_alloc_csr;

            OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Adding Product and Time Allocations Records'
                                                  || 'FOR Fact_ID = '|| l_fact_id || ' ; ');

            p_prod_alloc_rec := NULL;

            l_product_allocation_id := get_product_allocation_id;

            p_prod_alloc_rec.allocation_for := l_prod_alloc_rec.allocation_for;  -- same as 'FACT'
            p_prod_alloc_rec.allocation_for_id := l_prod_alloc_rec.allocation_for_id;  -- same as l_fact_id
            p_prod_alloc_rec.fund_id := l_prod_alloc_rec.fund_id;
            p_prod_alloc_rec.item_type := l_item_type;
            p_prod_alloc_rec.item_id := l_item_id;
            p_prod_alloc_rec.selected_flag := 'N';
            p_prod_alloc_rec.target := 0;
            p_prod_alloc_rec.lysp_sales := 0;


            Ozf_Product_Allocations_Pkg.Insert_Row(
               px_product_allocation_id  => l_product_allocation_id,
               p_allocation_for  => p_prod_alloc_rec.allocation_for,
               p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
               p_fund_id  => p_prod_alloc_rec.fund_id,
               p_item_type  => p_prod_alloc_rec.item_type,
               p_item_id  => p_prod_alloc_rec.item_id,
               p_selected_flag  => p_prod_alloc_rec.selected_flag,
               p_target  => NVL(p_prod_alloc_rec.target, 0),
               p_lysp_sales  => NVL(p_prod_alloc_rec.lysp_sales, 0),
               p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
               px_object_version_number  => l_object_version_number,
               p_creation_date  => SYSDATE,
               p_created_by  => FND_GLOBAL.USER_ID,
               p_last_update_date  => SYSDATE,
               p_last_updated_by  => FND_GLOBAL.USER_ID,
               p_last_update_login  => FND_GLOBAL.conc_login_id,
               p_attribute_category  => p_prod_alloc_rec.attribute_category,
               p_attribute1  => p_prod_alloc_rec.attribute1,
               p_attribute2  => p_prod_alloc_rec.attribute2,
               p_attribute3  => p_prod_alloc_rec.attribute3,
               p_attribute4  => p_prod_alloc_rec.attribute4,
               p_attribute5  => p_prod_alloc_rec.attribute5,
               p_attribute6  => p_prod_alloc_rec.attribute6,
               p_attribute7  => p_prod_alloc_rec.attribute7,
               p_attribute8  => p_prod_alloc_rec.attribute8,
               p_attribute9  => p_prod_alloc_rec.attribute9,
               p_attribute10  => p_prod_alloc_rec.attribute10,
               p_attribute11  => p_prod_alloc_rec.attribute11,
               p_attribute12  => p_prod_alloc_rec.attribute12,
               p_attribute13  => p_prod_alloc_rec.attribute13,
               p_attribute14  => p_prod_alloc_rec.attribute14,
               p_attribute15  => p_prod_alloc_rec.attribute15,
               px_org_id  => l_org_id
             );


            l_total_lysp_sales := 0;

            FOR time_alloc_rec IN time_alloc_csr(l_prod_alloc_rec.product_allocation_id)
            LOOP
                p_time_alloc_rec := NULL;

                l_lysp_time_id :=  OZF_TIME_API_PVT.get_lysp_id(time_alloc_rec.time_id, time_alloc_rec.period_type_id);

                l_lysp_sales := 0;
                IF l_item_type = 'PRICING_ATTRIBUTE1' THEN
                   OPEN product_lysp_sales_csr(l_item_id,
                                               l_territory_id,
                                               l_lysp_time_id
                                              );
                   FETCH product_lysp_sales_csr INTO l_lysp_sales;
                ELSIF l_item_type = 'PRICING_ATTRIBUTE2' THEN
                   OPEN category_lysp_sales_csr(l_item_id,
                                                l_territory_id,
                                                l_lysp_time_id,
                                                l_fund_id
                                               );
                   FETCH category_lysp_sales_csr INTO l_lysp_sales;
                   CLOSE category_lysp_sales_csr;
                END IF;

                l_total_lysp_sales := l_total_lysp_sales + l_lysp_sales;

                l_time_allocation_id := get_time_allocation_id;

                p_time_alloc_rec.allocation_for := time_alloc_rec.allocation_for;
                p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
                p_time_alloc_rec.time_id := time_alloc_rec.time_id;
                p_time_alloc_rec.period_type_id := time_alloc_rec.period_type_id;
                p_time_alloc_rec.target := 0;
                p_time_alloc_rec.lysp_sales := l_lysp_sales;


                Ozf_Time_Allocations_Pkg.Insert_Row(
                   px_time_allocation_id  => l_time_allocation_id,
                   p_allocation_for  => p_time_alloc_rec.allocation_for,
                   p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
                   p_time_id  => p_time_alloc_rec.time_id,
                   p_period_type_id => p_time_alloc_rec.period_type_id,
                   p_target  => NVL(p_time_alloc_rec.target, 0),
                   p_lysp_sales  => NVL(p_time_alloc_rec.lysp_sales, 0),
                   px_object_version_number  => l_object_version_number,
                   p_creation_date  => SYSDATE,
                   p_created_by  => FND_GLOBAL.USER_ID,
                   p_last_update_date  => SYSDATE,
                   p_last_updated_by  => FND_GLOBAL.USER_ID,
                   p_last_update_login  => FND_GLOBAL.conc_login_id,
                   p_attribute_category  => p_time_alloc_rec.attribute_category,
                   p_attribute1  => p_time_alloc_rec.attribute1,
                   p_attribute2  => p_time_alloc_rec.attribute2,
                   p_attribute3  => p_time_alloc_rec.attribute3,
                   p_attribute4  => p_time_alloc_rec.attribute4,
                   p_attribute5  => p_time_alloc_rec.attribute5,
                   p_attribute6  => p_time_alloc_rec.attribute6,
                   p_attribute7  => p_time_alloc_rec.attribute7,
                   p_attribute8  => p_time_alloc_rec.attribute8,
                   p_attribute9  => p_time_alloc_rec.attribute9,
                   p_attribute10  => p_time_alloc_rec.attribute10,
                   p_attribute11  => p_time_alloc_rec.attribute11,
                   p_attribute12  => p_time_alloc_rec.attribute12,
                   p_attribute13  => p_time_alloc_rec.attribute13,
                   p_attribute14  => p_time_alloc_rec.attribute14,
                   p_attribute15  => p_time_alloc_rec.attribute15,
                   px_org_id  => l_org_id
                 );


            END LOOP;

            UPDATE OZF_PRODUCT_ALLOCATIONS p
            SET p.lysp_sales = l_total_lysp_sales,
                p.object_version_number = p.object_version_number + 1,
                p.last_update_date = SYSDATE,
                p.last_updated_by = FND_GLOBAL.USER_ID,
                p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
            WHERE p.product_allocation_id = l_product_allocation_id;

            OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Adding Product and Time Allocations Records'
                                                  || 'FOR Fact_ID = '|| l_fact_id || ' ; ');

            <<next_fact_iteration>>
            NULL;
       END LOOP;
   END LOOP;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Adding Product and Time Allocations Records'
                                         || 'FOR Allocations of Fund_id = '|| l_fund_id || ' ; ');

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN OZF_TP_ADDITEM_NOT_ALLOWED THEN
          ROLLBACK TO add_cascade_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_ADDITEM_NOT_ALLOWED_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_ADDITEM_NOT_ALLOWED_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO add_cascade_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO add_cascade_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO add_cascade_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END add_cascade_product_spread;



-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Delete Single Product
-- Desc: When Root Node (= p_fund_id) deletes a product from his Product Spread,
--       cascade the Deletion to all facts for all his allocations.
--       So, delete that Product from everywhere and INCREMENT Quota
--       for OTHERS for that FACT_id
--       Note: Deletion of Product from Root and incrementing Root-OTHERS
--             will be done in OA UI.
-- -----------------------------------------------------------------
 PROCEDURE delete_single_product
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id            IN          NUMBER,
    p_item_id            IN          NUMBER,
    p_item_type          IN          VARCHAR2
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'delete_single_product';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_fund_id                NUMBER;
   l_item_id                NUMBER;
   l_item_type              VARCHAR2(30);
   l_fact_id                NUMBER;
   l_territory_id           NUMBER;
   l_status_code            OZF_FUNDS_ALL_VL.status_code%TYPE;
   l_lysp_sales             NUMBER;
   l_total_lysp_sales       NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;
   l_lysp_time_id           NUMBER;
   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; --  := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));  --Bugfix7540057

   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;

  CURSOR fund_csr(l_fund_id  NUMBER) IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
   FROM
    ozf_funds_all_vl
   WHERE
    fund_id = l_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;

  CURSOR allocation_csr
        (l_fund_id        number) IS
  SELECT
     activity_metric_id,
     arc_act_metric_used_by,
     act_metric_used_by_id,
     product_spread_time_id  period_type_id,  -- (eg.. 32 for monthly, 64 for quarterly),
     published_flag,
     status_code,
     start_period_name,
     end_period_name,
     from_date,
     to_date
  FROM
      OZF_ACT_METRICS_ALL
  WHERE
      arc_act_metric_used_by = 'FUND'
  AND act_metric_used_by_id = l_fund_id;


  CURSOR fact_csr
       (l_allocation_id        number) IS
  SELECT
      activity_metric_fact_id,
      act_metric_used_by_id,
      arc_act_metric_used_by,
      activity_metric_id,
      hierarchy_id,
      hierarchy_type,
      node_id,  ---  this is territory_id of this FACT ******* confirm this *********
      previous_fact_id,
      recommend_total_amount,
      status_code
  FROM
      OZF_ACT_METRIC_FACTS_ALL
  WHERE
      activity_metric_id = l_allocation_id;


   CURSOR prod_alloc_csr
       (l_fact_id        number,
        l_item_id        number,
        l_item_type      varchar2 ) IS
   SELECT product_allocation_id,
          allocation_for,
          allocation_for_id,
          fund_id,
          item_id,
          item_type,
          target,
          lysp_sales
   FROM OZF_PRODUCT_ALLOCATIONS
   WHERE allocation_for = 'FACT'
    AND allocation_for_id = l_fact_id
    AND item_id = l_item_id
    AND item_type = l_item_type;

   l_prod_alloc_rec         prod_alloc_csr%ROWTYPE;
   l_others_prod_alloc_rec  prod_alloc_csr%ROWTYPE;

   CURSOR time_alloc_csr
       (l_prod_alloc_id    number) IS
   SELECT time_allocation_id,
          allocation_for,
          allocation_for_id,
          time_id,
          period_type_id,
          target,
          lysp_sales
   FROM OZF_TIME_ALLOCATIONS
   WHERE allocation_for = 'PROD'
    AND allocation_for_id = l_prod_alloc_id;

   l_time_alloc_rec  time_alloc_csr%ROWTYPE;


   CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                                  l_territory_id  NUMBER,
                                  l_time_id       NUMBER) IS
    SELECT
     SUM(bsmv.sales) sales
    FROM
      ozf_order_sales_v bsmv,
      ams_party_market_segments a
    WHERE
         a.market_qualifier_reference = l_territory_id
     AND a.market_qualifier_type='TERRITORY'
     AND bsmv.ship_to_site_use_id = a.site_use_id
     AND bsmv.inventory_item_id = l_product_id
     AND bsmv.time_id = l_time_id;


   CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                   l_territory_id   NUMBER,
                                   l_time_id        NUMBER,
                                   l_fund_id        NUMBER) IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
    ozf_order_sales_v bsmv,
    ams_party_market_segments a
   WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY'
   AND bsmv.ship_to_site_use_id = a.site_use_id
   AND bsmv.time_id = l_time_id
   AND bsmv.inventory_item_id IN
                             ( SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                               FROM   MTL_ITEM_CATEGORIES     MIC,
                                      ENI_PROD_DENORM_HRCHY_V DENORM
                               WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                                AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                                AND   DENORM.PARENT_ID     = l_category_id
                                MINUS
                                SELECT a.inventory_item_id
                                FROM  ams_act_products a
                                WHERE act_product_used_by_id = l_fund_id
                                 AND arc_act_product_used_by = 'FUND'
                                 AND level_type_code = 'PRODUCT'
                                 AND excluded_flag IN  ('Y', 'N')
                              );


 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT delete_single_product;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fund_id := p_fund_id;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   l_status_code := l_fund_rec.status_code;


   IF l_status_code IN ('DRAFT', 'PLANNING') THEN
      null;
   ELSE
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': STATUS of Root Fund Number : '
                                            ||l_fund_id|| ' is : '||l_status_code);
      RAISE OZF_TP_DELITEM_NOT_ALLOWED;
   END IF;



------- Start Deleting Product and Time Allocation Records for allocations of l_fact_id -----------------------

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Deleting Product and Time Allocations Records'
                                         || 'FOR Allocations of Fund_id = '|| l_fund_id || ' ; ');

   FOR allocation_rec IN allocation_csr(l_fund_id)
   LOOP
       FOR fact_rec IN fact_csr(allocation_rec.activity_metric_id)
       LOOP

           l_fact_id := fact_rec.activity_metric_fact_id;
           l_territory_id := fact_rec.node_id;

           OPEN prod_alloc_csr(l_fact_id, l_item_id, l_item_type);
           FETCH prod_alloc_csr INTO l_prod_alloc_rec;
           IF prod_alloc_csr%NOTFOUND THEN
              CLOSE prod_alloc_csr;
              OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': NO Product and Time Allocations Records exist'
                                                    || 'FOR Fact_id = '|| l_fact_id || ' ; ');
              GOTO next_fact_iteration;
           END IF;
           CLOSE prod_alloc_csr;

           OPEN prod_alloc_csr(l_fact_id, -9999, 'OTHERS');
           FETCH prod_alloc_csr INTO l_others_prod_alloc_rec;
           IF prod_alloc_csr%NOTFOUND THEN
              CLOSE prod_alloc_csr;
              OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': NO OTHERS Product and Time Allocations Records exist'
                                                    || 'FOR Fact_id = '|| l_fact_id || ' ; ');
              GOTO next_fact_iteration;
           END IF;
           CLOSE prod_alloc_csr;


            OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                                  ': Begin - Updating OTHERS Product and Time Allocations Records'
                                  || 'FOR Fact_ID = '|| l_fact_id || ' ; ');

            FOR time_alloc_rec IN time_alloc_csr(l_prod_alloc_rec.product_allocation_id)
            LOOP

                UPDATE ozf_time_allocations t -- Update Others Quota for Jul03, Aug03, Sep03 etc
                   SET t.target = t.target + NVL(time_alloc_rec.target, 0),
                       t.object_version_number = t.object_version_number + 1,
                       t.last_update_date = SYSDATE,
                       t.last_updated_by = FND_GLOBAL.USER_ID,
                       t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
                 WHERE
                       t.time_id = time_alloc_rec.time_id
                   AND t.allocation_for_id = l_others_prod_alloc_rec.product_allocation_id
                   AND t.allocation_for = 'PROD';

            END LOOP;

            UPDATE ozf_product_allocations p -- Update Others Quota for Q3-03 etc
            SET p.target = p.target + NVL(l_prod_alloc_rec.target, 0),
                p.object_version_number = p.object_version_number + 1,
                p.last_update_date = SYSDATE,
                p.last_updated_by = FND_GLOBAL.USER_ID,
                p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
            WHERE p.product_allocation_id = l_others_prod_alloc_rec.product_allocation_id;


            OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Updating OTHERS Product and Time Allocations Records'
                                                  || 'FOR Fact_ID = '|| l_fact_id || ' ; ');


            DELETE ozf_time_allocations t
            WHERE t.allocation_for_id = l_prod_alloc_rec.product_allocation_id
              AND t.allocation_for = 'PROD';

            DELETE ozf_product_allocations p
            WHERE  p.product_allocation_id = l_prod_alloc_rec.product_allocation_id;


            <<next_fact_iteration>>
            NULL;
       END LOOP;
   END LOOP;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Deleting Product and Time Allocations Records'
                                         || 'FOR Allocations of Fund_id = '|| l_fund_id || ' ; ');

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN OZF_TP_DELITEM_NOT_ALLOWED THEN
          ROLLBACK TO delete_single_product;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_DELITEM_NOT_ALLOWED_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_DELITEM_NOT_ALLOWED_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO delete_single_product;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO delete_single_product;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO delete_single_product;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END delete_single_product;

-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------------
-- Name: delete target allocation
-- Desc: Delete all Account, Product and Time allocation records
--       for a given fund_id
--       Note that this will wipe all targets for a given fund_id.
-- ------------------------------------------------------------------------
 PROCEDURE delete_target_allocation
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id            IN          NUMBER
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'delete_target_allocation';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);
   l_fund_id                NUMBER;

   CURSOR fund_account_spread_csr
         (l_fund_id        number) IS
   SELECT DISTINCT
       p.account_allocation_id
   FROM
       ozf_account_allocations p
   WHERE
       p.allocation_for  = 'FUND'
   AND p.allocation_for_id = l_fund_id;

   CURSOR acct_product_spread_csr
         (l_acct_allocation_id        number) IS
   SELECT DISTINCT
       p.product_allocation_id
   FROM
       ozf_product_allocations p
   WHERE
       p.allocation_for  = 'CUST'
   AND p.allocation_for_id = l_acct_allocation_id;


 BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   -- Standard Start of API savepoint
   SAVEPOINT delete_target_allocation;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   l_fund_id := p_fund_id;

------- Start Deleting Product and Time Allocation Records -----------------------

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                         ': Begin - Deleting Account, Product and Time Allocations Records'
                         || 'FOR Fund_id = '|| l_fund_id || ' ; ');

   FOR account_rec IN fund_account_spread_csr(l_fund_id)
   LOOP
      DELETE ozf_time_allocations t
      WHERE t.allocation_for_id = account_rec.account_allocation_id
        AND t.allocation_for = 'CUST';

      FOR product_rec IN acct_product_spread_csr(account_rec.account_allocation_id)
      LOOP
         DELETE ozf_time_allocations t
         WHERE t.allocation_for_id = product_rec.product_allocation_id
           AND t.allocation_for = 'PROD';
      END LOOP;

      DELETE ozf_product_allocations p
      WHERE  p.allocation_for  = 'CUST'
         AND p.allocation_for_id = account_rec.account_allocation_id;

   END LOOP;

   DELETE ozf_account_allocations p
   WHERE  p.allocation_for  = 'FUND'
      AND p.allocation_for_id = l_fund_id;


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                         ': End - Deleting Account, Product and Time Allocations Records'
                         || 'FOR Fund_id = '|| l_fund_id || ' ; ');

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO delete_target_allocation;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO delete_target_allocation;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO delete_target_allocation;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END delete_target_allocation;



-- ------------------------
-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: OLD ALLOCATE TARGET FIRST TIME
-- Desc: 1. Allocate Target across Accounts and Products for Sales Rep
--          when the Fact is published for the first time and a fund_id
--          is created.
--
--  This is obsoleted as of May17th, 2004.
--  and has been renamed old_old_allocate_target_first_time.
-- -----------------------------------------------------------------
PROCEDURE old_allocate_target_first_time
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id            IN          NUMBER
) IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'old_allocate_target_first_time';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_fund_id                NUMBER;

   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; -- := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));    --Bugfix7540057

   l_start_date             VARCHAR2(30) := null;
   l_end_date               VARCHAR2(30) := null;
   l_period_type_id         NUMBER;
   l_lysp_in_clause         VARCHAR2(1000) := null;
   l_in_clause              VARCHAR2(1000) := null;
   l_territory_id           NUMBER;
   l_resource_id            NUMBER;

   l_total_lysp_sales       NUMBER;

   l_total_account_sales    NUMBER;
   l_account_sales          NUMBER;
   l_total_account_target   NUMBER;
   l_account_target         NUMBER;

   l_total_product_sales    NUMBER;
   l_product_sales          NUMBER;
   l_total_product_target   NUMBER;
   l_product_target         NUMBER;

   l_total_root_quota       NUMBER;
   l_total_fund_quota       NUMBER;
   l_time_fund_target       NUMBER;

   l_multiplying_factor     NUMBER;
   l_prod_mltply_factor     NUMBER;

   l_account_allocation_id  NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;

   l_denominator            NUMBER;
   l_total_target_unalloc   NUMBER;
   l_time_target_unalloc    NUMBER;

   l_diff_target            NUMBER;
   l_diff_target_1          NUMBER;
   l_diff_target_2          NUMBER;

   l_period_tbl          OZF_TIME_API_PVT.G_period_tbl_type;
   l_lysp_period_tbl     OZF_TIME_API_PVT.G_period_tbl_type;

   p_acct_alloc_rec      ozf_account_allocations%ROWTYPE;
   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;



  CURSOR fund_csr (l_fund_id  NUMBER)
  IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
   FROM
    ozf_funds_all_vl
   WHERE
    fund_id = l_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;

  CURSOR territory_csr (l_resource_id NUMBER) IS
   SELECT
    j.terr_id territory_id
   FROM
    jtf_terr_rsc_all j, jtf_terr_rsc_access_all j2
   WHERE
       j.resource_id = l_resource_id
  -- AND j.primary_contact_flag = 'Y' ;
   AND j2.terr_rsc_id = j.terr_rsc_id
   AND j2.access_type = 'OFFER'
   AND j2.trans_access_code = 'PRIMARY_CONTACT';

/*
  CURSOR total_lysp_sales_csr (l_territory_id  NUMBER,
                               l_in_clause     VARCHAR2)
   IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ams_party_market_segments a
   WHERE
        a.market_qualifier_reference = l_territory_id
    AND a.market_qualifier_type='TERRITORY'
    AND bsmv.ship_to_site_use_id = a.site_use_id
    AND bsmv.time_id IN (l_in_clause);
*/

  l_total_lysp_sales_sql varchar2(30000) :=
   ' SELECT'||
   '  SUM(bsmv.sales) sales'||
   ' FROM'||
   '   ozf_order_sales_v bsmv,'||
   '   ams_party_market_segments a'||
   ' WHERE'||
   '      a.market_qualifier_reference = :l_territory_id    '||
   '  AND a.market_qualifier_type=''TERRITORY''  '||
   '  AND bsmv.ship_to_site_use_id = a.site_use_id'||
   '  AND bsmv.time_id IN (';

  total_lysp_sales_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable)


  CURSOR account_csr
        (l_territory_id    number)
  IS
  SELECT
    a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id,
    a.site_use_code                                          site_use_code,
    OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    NVL(a.bill_to_site_use_id, -9996)                        bill_to_site_use_id,
    OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    a.party_id                                               parent_party_id,
    NVL(a.rollup_party_id, a.party_id)                       rollup_party_id
  FROM
    ams_party_market_segments a
  WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id IS NOT NULL;

/*
  SELECT
    a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id,
    a.site_use_code                                          site_use_code,
    OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    a.bill_to_site_use_id                                    bill_to_site_use_id,
    OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    a.party_id                                               parent_party_id,
    a.rollup_party_id                                        rollup_party_id
  FROM
    ams_party_market_segments a
  WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY';
*/

/*
  CURSOR account_total_sales_csr
         (l_site_use_id         number,
          l_in_clause           varchar2)
  IS
  SELECT
      SUM(bsmv.sales) account_sales
  FROM
      ozf_order_sales_v bsmv
  WHERE
      bsmv.ship_to_site_use_id = l_site_use_id
  AND bsmv.time_id IN (l_in_clause);

*/

  l_account_total_sales_sql varchar2(30000) :=
  ' SELECT '||
  '     SUM(bsmv.sales) account_sales'||
  ' FROM '||
  '     ozf_order_sales_v bsmv'||
  ' WHERE '||
  '     bsmv.ship_to_site_use_id = :l_site_use_id'||
  ' AND bsmv.time_id IN (' ;
  --l_in_clause);

  account_total_sales_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable


  CURSOR account_sales_csr
         (l_site_use_id         number,
          l_time_id             number)
  IS
  SELECT
      SUM(bsmv.sales) account_sales
  FROM
      ozf_order_sales_v bsmv
  WHERE
      bsmv.ship_to_site_use_id = l_site_use_id
  AND bsmv.time_id = l_time_id;

/*
  CURSOR get_total_target_csr
        (l_fund_id   NUMBER,
     l_in_clause VARCHAR2) IS
   SELECT SUM(t.target)
   FROM
       ozf_time_allocations t,
       ozf_product_allocations p
   WHERE
       p.fund_id = l_fund_id
   AND t.allocation_for_id   = p.product_allocation_id
   AND t.allocation_for      = 'PROD'
   AND t.time_id IN (l_in_clause);
*/

  l_get_total_target_sql VARCHAR2(30000) :=
   ' SELECT SUM(t.target) '||
   ' FROM '||
   '     ozf_time_allocations t,'||
   '     ozf_product_allocations p'||
   ' WHERE'||
   '     p.fund_id = :l_fund_id'||
   ' AND t.allocation_for_id   = p.product_allocation_id'||
   ' AND t.allocation_for      = ''PROD'' '||
   ' AND t.time_id IN (';
--l_in_clause);

  get_total_target_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable)


  CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                                 l_territory_id  NUMBER,
                                 l_site_use_id   NUMBER,
                                 l_time_id       NUMBER) IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ams_party_market_segments a
   WHERE
        a.market_qualifier_reference = l_territory_id
    AND a.market_qualifier_type='TERRITORY'
    AND a.site_use_id = l_site_use_id
    AND bsmv.ship_to_site_use_id = a.site_use_id
    AND bsmv.inventory_item_id = l_product_id
    AND bsmv.time_id = l_time_id;


  CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                  l_territory_id   NUMBER,
                                  l_site_use_id    NUMBER,
                                  l_time_id        NUMBER,
                                  l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND bsmv.inventory_item_id IN
                             ( SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                               FROM   MTL_ITEM_CATEGORIES     MIC,
                                      ENI_PROD_DENORM_HRCHY_V DENORM
                               WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                                AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                                AND   DENORM.PARENT_ID     = l_category_id
                               MINUS
                               SELECT p.item_id
                               FROM   ozf_product_allocations p
                               WHERE  p.fund_id = l_fund_id
                                  AND p.item_type = 'PRICING_ATTRIBUTE1'
                             );


  CURSOR others_lysp_sales_csr (l_territory_id   NUMBER,
                                l_site_use_id    NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND NOT EXISTS
  (
  ( SELECT p.item_id
    FROM ozf_product_allocations p
    WHERE
        p.fund_id = l_fund_id
    AND p.item_type = 'PRICING_ATTRIBUTE1'
    AND p.item_id = bsmv.inventory_item_id
    UNION ALL
    SELECT MIC.INVENTORY_ITEM_ID
    FROM   MTL_ITEM_CATEGORIES MIC,
           ENI_PROD_DENORM_HRCHY_V DENORM,
           OZF_PRODUCT_ALLOCATIONS p
    WHERE p.FUND_ID = l_fund_id
      AND p.ITEM_TYPE = 'PRICING_ATTRIBUTE2'
      AND p.ITEM_ID = DENORM.PARENT_ID
      AND MIC.CATEGORY_SET_ID = DENORM.CATEGORY_SET_ID
      AND MIC.CATEGORY_ID = DENORM.CHILD_ID
      AND MIC.INVENTORY_ITEM_ID = bsmv.inventory_item_id
  )
  MINUS
  SELECT prod.inventory_item_id
  FROM ams_act_products prod
  where
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'Y'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  );

  CURSOR fund_product_spread_csr
         (l_fund_id        number) IS
    SELECT
       p.product_allocation_id,
       p.item_id,
       p.item_type,
       p.target
    FROM
       ozf_product_allocations p
    WHERE
       p.fund_id = l_fund_id;

   l_fund_product_rec     fund_product_spread_csr%rowtype;

   CURSOR fund_time_spread_csr
         (l_product_allocation_id       number,
          l_time_id                     number) IS
   SELECT t.target
   FROM
       ozf_time_allocations t
   WHERE
       t.allocation_for_id = l_product_allocation_id
   AND t.allocation_for = 'PROD'
   AND t.time_id = l_time_id;


 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT old_allocate_target_first_time;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   l_fund_id := p_fund_id;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   l_resource_id := l_fund_rec.owner;
   l_territory_id := l_fund_rec.node_id;

   IF l_territory_id IS NULL THEN
      OPEN territory_csr(l_resource_id);
      FETCH territory_csr INTO l_territory_id;
      CLOSE territory_csr ;
   END IF;

   l_org_id := get_org_id(l_territory_id);    --Bugfix 7540057

   l_start_date := to_char(l_fund_rec.start_date_active, 'YYYY/MM/DD');
   l_end_date   := to_char(l_fund_rec.end_date_active, 'YYYY/MM/DD');
   l_period_type_id := l_fund_rec.period_type_id;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Getting Time_ids Between '
                                                 ||l_start_date||' AND '||l_end_date||' ; '
                                                 ||' Period_Type_id = '||l_period_type_id||' ; ');

   IF l_start_date IS NULL OR
      l_end_date IS NULL OR
      l_period_type_id IS NULL
   THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   l_period_tbl := OZF_TIME_API_PVT.get_period_tbl
                                    (l_start_date,
                                     l_end_date,
                                     l_period_type_id);

   IF l_period_tbl IS NULL OR l_period_tbl.COUNT <= 0 THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Getting Time_ids Between '||l_start_date
                                         ||' AND '||l_end_date||' ; ');
   IF l_period_tbl IS NOT NULL THEN
    IF l_period_tbl.COUNT > 0 THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
        IF l_period_tbl.exists(l_idx) THEN

         l_lysp_period_tbl(l_idx) := OZF_TIME_API_PVT.get_lysp_id (l_period_tbl(l_idx), l_period_type_id);

         OZF_UTILITY_PVT.debug_message(SubStr('l_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_period_tbl(l_idx)), 1,255));
        END IF;
      END LOOP;
    END IF;
   END IF;

   --l_in_clause := '(';
   l_in_clause := NULL;
   IF l_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
          IF l_in_clause IS NULL THEN
             l_in_clause := LTRIM(' '||l_period_tbl(l_idx));
          ELSE
             l_in_clause := l_in_clause ||','|| l_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_in_clause := l_in_clause||')';

   l_lysp_in_clause := NULL;
   IF l_lysp_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_lysp_period_tbl.first..l_lysp_period_tbl.last
      LOOP
          IF l_lysp_in_clause IS NULL THEN
             l_lysp_in_clause := LTRIM(' '||l_lysp_period_tbl(l_idx));
          ELSE
             l_lysp_in_clause := l_lysp_in_clause ||','|| l_lysp_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_lysp_in_clause := l_lysp_in_clause||')';


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Time_ids between '||l_start_date
                                         ||' AND '||l_end_date||' ARE : '||l_in_clause||' ; ');
   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': LYSP-Time_ids between '||l_start_date
                                         ||' AND '||l_end_date||' ARE : '||l_lysp_in_clause||' ; ');


   l_total_lysp_sales_sql := l_total_lysp_sales_sql||l_lysp_in_clause||')';

   OPEN total_lysp_sales_csr FOR l_total_lysp_sales_sql USING l_territory_id;
--   OPEN total_lysp_sales_csr(l_territory_id,l_lysp_in_clause);
   FETCH total_lysp_sales_csr INTO l_total_lysp_sales;
   CLOSE total_lysp_sales_csr;
   l_total_lysp_sales := NVL(l_total_lysp_sales, 0);

   l_total_root_quota := NVL(l_fund_rec.original_budget,0) + NVL(l_fund_rec.transfered_in_amt,0);

   l_total_target_unalloc := 0;
   l_time_target_unalloc := 0;
   l_multiplying_factor := 0;

   IF l_total_lysp_sales > 0 THEN
      l_multiplying_factor := l_total_root_quota / l_total_lysp_sales;
   ELSE
      l_multiplying_factor := 0;
      l_denominator := l_period_tbl.COUNT;

      l_total_target_unalloc := l_total_root_quota;
      l_time_target_unalloc := l_total_root_quota / l_denominator;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Multiplying Factor = '
                                                 || l_multiplying_factor || ' ; ');

------ for product allocations: based upon Funds product spread ------------------

   l_get_total_target_sql := l_get_total_target_sql||l_in_clause ||')';

   OPEN get_total_target_csr FOR l_get_total_target_sql USING l_fund_id;
   FETCH get_total_target_csr INTO l_total_fund_quota;
   CLOSE get_total_target_csr ;

   l_total_fund_quota := NVL(l_total_fund_quota, 0);

------- Insert rows for ACCOUNTS  ------------------------------------------------

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name
                              || ': Begin - Populating Account and Time Allocations Records'
                              || ' FOR Fund_id = '|| l_fund_id
                              || ' AND Territory_id = '|| l_territory_id
                              || ' ; ');


   l_account_total_sales_sql := l_account_total_sales_sql||l_lysp_in_clause ||')';

   <<account_loop>>
   FOR account_rec IN account_csr(l_territory_id)
   LOOP
       p_acct_alloc_rec := NULL;

       OPEN account_total_sales_csr FOR l_account_total_sales_sql USING account_rec.site_use_id;
--       OPEN account_total_sales_csr (account_rec.site_use_id, l_lysp_in_clause);
       FETCH account_total_sales_csr into l_total_account_sales;
       CLOSE account_total_sales_csr;

       l_total_account_sales := NVL(l_total_account_sales, 0);
       l_total_account_target := ROUND( (l_total_account_sales * l_multiplying_factor), 0);

       p_acct_alloc_rec.allocation_for := 'FUND';
       p_acct_alloc_rec.allocation_for_id := l_fund_id;
       p_acct_alloc_rec.cust_account_id := account_rec.cust_account_id;
       p_acct_alloc_rec.site_use_id := account_rec.site_use_id;
       p_acct_alloc_rec.site_use_code := account_rec.site_use_code;
       p_acct_alloc_rec.location_id := account_rec.location_id;
       p_acct_alloc_rec.bill_to_site_use_id := account_rec.bill_to_site_use_id;
       p_acct_alloc_rec.bill_to_location_id := account_rec.bill_to_location_id;
       p_acct_alloc_rec.parent_party_id := account_rec.parent_party_id;
       p_acct_alloc_rec.rollup_party_id := account_rec.rollup_party_id;
       p_acct_alloc_rec.selected_flag := 'Y';
       p_acct_alloc_rec.target := l_total_account_target;
       p_acct_alloc_rec.lysp_sales := l_total_account_sales;

       l_account_allocation_id := get_account_allocation_id;

       Ozf_Account_Allocations_Pkg.Insert_Row(
          px_Account_allocation_id        => l_account_allocation_id,
          p_allocation_for                => p_acct_alloc_rec.allocation_for,
          p_allocation_for_id             => p_acct_alloc_rec.allocation_for_id,
          p_cust_account_id               => p_acct_alloc_rec.cust_account_id,
          p_site_use_id                   => p_acct_alloc_rec.site_use_id,
          p_site_use_code                 => p_acct_alloc_rec.site_use_code,
          p_location_id                   => p_acct_alloc_rec.location_id,
          p_bill_to_site_use_id           => p_acct_alloc_rec.bill_to_site_use_id,
          p_bill_to_location_id           => p_acct_alloc_rec.bill_to_location_id,
          p_parent_party_id               => p_acct_alloc_rec.parent_party_id,
          p_rollup_party_id               => p_acct_alloc_rec.rollup_party_id,
          p_selected_flag                 => p_acct_alloc_rec.selected_flag,
          p_target                        => p_acct_alloc_rec.target,
          p_lysp_sales                    => p_acct_alloc_rec.lysp_sales,
          p_parent_Account_allocation_id  => p_acct_alloc_rec.parent_Account_allocation_id,
          px_object_version_number        => l_object_version_number,
          p_creation_date                 => SYSDATE,
          p_created_by                    => FND_GLOBAL.USER_ID,
          p_last_update_date              => SYSDATE,
          p_last_updated_by               => FND_GLOBAL.USER_ID,
          p_last_update_login             => FND_GLOBAL.conc_login_id,
          p_attribute_category            => p_acct_alloc_rec.attribute_category,
          p_attribute1                    => p_acct_alloc_rec.attribute1,
          p_attribute2                    => p_acct_alloc_rec.attribute2,
          p_attribute3                    => p_acct_alloc_rec.attribute3,
          p_attribute4                    => p_acct_alloc_rec.attribute4,
          p_attribute5                    => p_acct_alloc_rec.attribute5,
          p_attribute6                    => p_acct_alloc_rec.attribute6,
          p_attribute7                    => p_acct_alloc_rec.attribute7,
          p_attribute8                    => p_acct_alloc_rec.attribute8,
          p_attribute9                    => p_acct_alloc_rec.attribute9,
          p_attribute10                   => p_acct_alloc_rec.attribute10,
          p_attribute11                   => p_acct_alloc_rec.attribute11,
          p_attribute12                   => p_acct_alloc_rec.attribute12,
          p_attribute13                   => p_acct_alloc_rec.attribute13,
          p_attribute14                   => p_acct_alloc_rec.attribute14,
          p_attribute15                   => p_acct_alloc_rec.attribute15,
          px_org_id                       => l_org_id
        );

       <<account_time_loop>>
       FOR l_idx IN l_period_tbl.first..l_period_tbl.last
       LOOP
        IF l_period_tbl.exists(l_idx) THEN

           p_time_alloc_rec := NULL;
           l_account_sales := 0;

           OPEN account_sales_csr (account_rec.site_use_id, l_lysp_period_tbl(l_idx));
           FETCH account_sales_csr into l_account_sales;
           CLOSE account_sales_csr;

           l_account_sales := NVL(l_account_sales, 0);
           l_account_target := ROUND((l_account_sales * l_multiplying_factor), 0);


           p_time_alloc_rec.allocation_for := 'CUST';
           p_time_alloc_rec.allocation_for_id := l_account_allocation_id;
           p_time_alloc_rec.time_id := l_period_tbl(l_idx);
           p_time_alloc_rec.period_type_id := l_period_type_id;
           p_time_alloc_rec.target := l_account_target;
           p_time_alloc_rec.lysp_sales := l_account_sales;

           l_time_allocation_id := get_time_allocation_id;

           Ozf_Time_Allocations_Pkg.Insert_Row(
              px_time_allocation_id  => l_time_allocation_id,
              p_allocation_for  => p_time_alloc_rec.allocation_for,
              p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
              p_time_id  => p_time_alloc_rec.time_id,
              p_period_type_id => p_time_alloc_rec.period_type_id,
              p_target  => p_time_alloc_rec.target,
              p_lysp_sales  => p_time_alloc_rec.lysp_sales,
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_time_alloc_rec.attribute_category,
              p_attribute1  => p_time_alloc_rec.attribute1,
              p_attribute2  => p_time_alloc_rec.attribute2,
              p_attribute3  => p_time_alloc_rec.attribute3,
              p_attribute4  => p_time_alloc_rec.attribute4,
              p_attribute5  => p_time_alloc_rec.attribute5,
              p_attribute6  => p_time_alloc_rec.attribute6,
              p_attribute7  => p_time_alloc_rec.attribute7,
              p_attribute8  => p_time_alloc_rec.attribute8,
              p_attribute9  => p_time_alloc_rec.attribute9,
              p_attribute10  => p_time_alloc_rec.attribute10,
              p_attribute11  => p_time_alloc_rec.attribute11,
              p_attribute12  => p_time_alloc_rec.attribute12,
              p_attribute13  => p_time_alloc_rec.attribute13,
              p_attribute14  => p_time_alloc_rec.attribute14,
              p_attribute15  => p_time_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


         END IF;
       END LOOP account_time_loop;

------- Insert rows for PRODUCT and TIME Allocation Records for given ACCOUNT ---------------------------


       OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                             ': Begin - Populating Product and Time Allocations Records'
                              || 'FOR site_use_id = '|| account_rec.site_use_id || ' ; ');


       l_total_fund_quota := NVL(l_total_fund_quota, 0);

       IF l_total_fund_quota > 0 THEN
          l_prod_mltply_factor := l_total_account_target / l_total_fund_quota;
       ELSE
          l_prod_mltply_factor := 0;
       END IF;

       <<account_product_loop>>
       FOR fund_product_rec IN fund_product_spread_csr(l_fund_id)
       LOOP

           p_prod_alloc_rec := NULL;
           l_total_product_target := ROUND( (NVL(fund_product_rec.target ,0) * l_prod_mltply_factor), 0);

           p_prod_alloc_rec.allocation_for := 'CUST';
           p_prod_alloc_rec.allocation_for_id := l_account_allocation_id;
           p_prod_alloc_rec.item_type := fund_product_rec.item_type;
           p_prod_alloc_rec.item_id := fund_product_rec.item_id;
           p_prod_alloc_rec.selected_flag := 'N';
           p_prod_alloc_rec.target := l_total_product_target;
           p_prod_alloc_rec.lysp_sales := 0;

           l_product_allocation_id := get_product_allocation_id;

           Ozf_Product_Allocations_Pkg.Insert_Row(
              px_product_allocation_id  => l_product_allocation_id,
              p_allocation_for  => p_prod_alloc_rec.allocation_for,
              p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
              p_fund_id  => p_prod_alloc_rec.fund_id,
              p_item_type  => p_prod_alloc_rec.item_type,
              p_item_id  => p_prod_alloc_rec.item_id,
              p_selected_flag  => p_prod_alloc_rec.selected_flag,
              p_target  => p_prod_alloc_rec.target,
              p_lysp_sales  => p_prod_alloc_rec.lysp_sales,
              p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_prod_alloc_rec.attribute_category,
              p_attribute1  => p_prod_alloc_rec.attribute1,
              p_attribute2  => p_prod_alloc_rec.attribute2,
              p_attribute3  => p_prod_alloc_rec.attribute3,
              p_attribute4  => p_prod_alloc_rec.attribute4,
              p_attribute5  => p_prod_alloc_rec.attribute5,
              p_attribute6  => p_prod_alloc_rec.attribute6,
              p_attribute7  => p_prod_alloc_rec.attribute7,
              p_attribute8  => p_prod_alloc_rec.attribute8,
              p_attribute9  => p_prod_alloc_rec.attribute9,
              p_attribute10  => p_prod_alloc_rec.attribute10,
              p_attribute11  => p_prod_alloc_rec.attribute11,
              p_attribute12  => p_prod_alloc_rec.attribute12,
              p_attribute13  => p_prod_alloc_rec.attribute13,
              p_attribute14  => p_prod_alloc_rec.attribute14,
              p_attribute15  => p_prod_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


           l_total_product_sales := 0;

           <<account_product_time_loop>>
           FOR l_idx IN l_period_tbl.first..l_period_tbl.last
           LOOP
            IF l_period_tbl.exists(l_idx) THEN

               p_time_alloc_rec := NULL;


               OPEN fund_time_spread_csr(fund_product_rec.product_allocation_id, l_period_tbl(l_idx));
               FETCH fund_time_spread_csr INTO l_time_fund_target;
               CLOSE fund_time_spread_csr ;

               l_time_fund_target := NVL(l_time_fund_target, 0);

               l_product_target := ROUND( (l_time_fund_target * l_prod_mltply_factor), 0 );

               l_product_sales := 0;

               IF fund_product_rec.item_type = 'PRICING_ATTRIBUTE1' THEN
                  OPEN product_lysp_sales_csr(fund_product_rec.item_id,
                                              l_territory_id,
                                              account_rec.site_use_id,
                                              l_lysp_period_tbl(l_idx)
                                             );
                  FETCH product_lysp_sales_csr INTO l_product_sales;
                  CLOSE product_lysp_sales_csr;
               ELSIF fund_product_rec.item_type = 'PRICING_ATTRIBUTE2' THEN
                   OPEN category_lysp_sales_csr(fund_product_rec.item_id,
                                                l_territory_id,
                                                account_rec.site_use_id,
                                                l_lysp_period_tbl(l_idx),
                                                l_fund_id
                                               );
                   FETCH category_lysp_sales_csr INTO l_product_sales;
                   CLOSE category_lysp_sales_csr;
               ELSIF fund_product_rec.item_type = 'OTHERS' THEN
                   OPEN others_lysp_sales_csr(l_territory_id,
                                              account_rec.site_use_id,
                                              l_lysp_period_tbl(l_idx),
                                              l_fund_id
                                             );
                   FETCH others_lysp_sales_csr INTO l_product_sales;
                   CLOSE others_lysp_sales_csr;
               END IF;

               l_product_sales := NVL(l_product_sales, 0);
               l_total_product_sales := l_total_product_sales + l_product_sales;

               p_time_alloc_rec.allocation_for := 'PROD';
               p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
               p_time_alloc_rec.time_id := l_period_tbl(l_idx);
               p_time_alloc_rec.period_type_id := l_period_type_id;
               p_time_alloc_rec.target := l_product_target;
               p_time_alloc_rec.lysp_sales := l_product_sales;

               l_time_allocation_id := get_time_allocation_id;

               Ozf_Time_Allocations_Pkg.Insert_Row(
                  px_time_allocation_id  => l_time_allocation_id,
                  p_allocation_for  => p_time_alloc_rec.allocation_for,
                  p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
                  p_time_id  => p_time_alloc_rec.time_id,
                  p_period_type_id => p_time_alloc_rec.period_type_id,
                  p_target  => p_time_alloc_rec.target,
                  p_lysp_sales  => p_time_alloc_rec.lysp_sales,
                  px_object_version_number  => l_object_version_number,
                  p_creation_date  => SYSDATE,
                  p_created_by  => FND_GLOBAL.USER_ID,
                  p_last_update_date  => SYSDATE,
                  p_last_updated_by  => FND_GLOBAL.USER_ID,
                  p_last_update_login  => FND_GLOBAL.conc_login_id,
                  p_attribute_category  => p_time_alloc_rec.attribute_category,
                  p_attribute1  => p_time_alloc_rec.attribute1,
                  p_attribute2  => p_time_alloc_rec.attribute2,
                  p_attribute3  => p_time_alloc_rec.attribute3,
                  p_attribute4  => p_time_alloc_rec.attribute4,
                  p_attribute5  => p_time_alloc_rec.attribute5,
                  p_attribute6  => p_time_alloc_rec.attribute6,
                  p_attribute7  => p_time_alloc_rec.attribute7,
                  p_attribute8  => p_time_alloc_rec.attribute8,
                  p_attribute9  => p_time_alloc_rec.attribute9,
                  p_attribute10  => p_time_alloc_rec.attribute10,
                  p_attribute11  => p_time_alloc_rec.attribute11,
                  p_attribute12  => p_time_alloc_rec.attribute12,
                  p_attribute13  => p_time_alloc_rec.attribute13,
                  p_attribute14  => p_time_alloc_rec.attribute14,
                  p_attribute15  => p_time_alloc_rec.attribute15,
                  px_org_id  => l_org_id
                );


             END IF;
           END LOOP account_product_time_loop;

           UPDATE OZF_PRODUCT_ALLOCATIONS p
           SET p.lysp_sales = l_total_product_sales,
               p.object_version_number = p.object_version_number + 1,
               p.last_update_date = SYSDATE,
               p.last_updated_by = FND_GLOBAL.USER_ID,
               p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
           WHERE p.product_allocation_id = l_product_allocation_id;

       END LOOP account_product_loop;























       OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                             ': End - Populating Product and Time Allocations Records'
                             || 'FOR site_use_id = '|| account_rec.site_use_id || ' ; ');


   END LOOP account_loop;


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Populating UNALLOCATED Allocations Records'
                                         || 'FOR FUND_Id = '|| l_fund_id || ' ; ');

   p_acct_alloc_rec := NULL;

   p_acct_alloc_rec.allocation_for := 'FUND';
   p_acct_alloc_rec.allocation_for_id := l_fund_id;
   p_acct_alloc_rec.cust_account_id := -9999;
   p_acct_alloc_rec.site_use_id := -9999;
   p_acct_alloc_rec.bill_to_site_use_id := -9999;
   p_acct_alloc_rec.parent_party_id := -9999;
   p_acct_alloc_rec.rollup_party_id := -9999;
   p_acct_alloc_rec.selected_flag := 'N';
   p_acct_alloc_rec.target := ROUND( (NVL(l_total_target_unalloc, 0)), 0);
   p_acct_alloc_rec.lysp_sales := 0;

   l_account_allocation_id := get_account_allocation_id;

   Ozf_Account_Allocations_Pkg.Insert_Row(
      px_Account_allocation_id        => l_account_allocation_id,
      p_allocation_for                => p_acct_alloc_rec.allocation_for,
      p_allocation_for_id             => p_acct_alloc_rec.allocation_for_id,
      p_cust_account_id               => p_acct_alloc_rec.cust_account_id,
      p_site_use_id                   => p_acct_alloc_rec.site_use_id,
      p_site_use_code                 => p_acct_alloc_rec.site_use_code,
      p_location_id                   => p_acct_alloc_rec.location_id,
      p_bill_to_site_use_id           => p_acct_alloc_rec.bill_to_site_use_id,
      p_bill_to_location_id           => p_acct_alloc_rec.bill_to_location_id,
      p_parent_party_id               => p_acct_alloc_rec.parent_party_id,
      p_rollup_party_id               => p_acct_alloc_rec.rollup_party_id,
      p_selected_flag                 => p_acct_alloc_rec.selected_flag,
      p_target                        => p_acct_alloc_rec.target,
      p_lysp_sales                    => p_acct_alloc_rec.lysp_sales,
      p_parent_Account_allocation_id  => p_acct_alloc_rec.parent_Account_allocation_id,
      px_object_version_number        => l_object_version_number,
      p_creation_date                 => SYSDATE,
      p_created_by                    => FND_GLOBAL.USER_ID,
      p_last_update_date              => SYSDATE,
      p_last_updated_by               => FND_GLOBAL.USER_ID,
      p_last_update_login             => FND_GLOBAL.conc_login_id,
      p_attribute_category            => p_acct_alloc_rec.attribute_category,
      p_attribute1                    => p_acct_alloc_rec.attribute1,
      p_attribute2                    => p_acct_alloc_rec.attribute2,
      p_attribute3                    => p_acct_alloc_rec.attribute3,
      p_attribute4                    => p_acct_alloc_rec.attribute4,
      p_attribute5                    => p_acct_alloc_rec.attribute5,
      p_attribute6                    => p_acct_alloc_rec.attribute6,
      p_attribute7                    => p_acct_alloc_rec.attribute7,
      p_attribute8                    => p_acct_alloc_rec.attribute8,
      p_attribute9                    => p_acct_alloc_rec.attribute9,
      p_attribute10                   => p_acct_alloc_rec.attribute10,
      p_attribute11                   => p_acct_alloc_rec.attribute11,
      p_attribute12                   => p_acct_alloc_rec.attribute12,
      p_attribute13                   => p_acct_alloc_rec.attribute13,
      p_attribute14                   => p_acct_alloc_rec.attribute14,
      p_attribute15                   => p_acct_alloc_rec.attribute15,
      px_org_id                       => l_org_id
    );

   <<unalloc_time_loop>>
   FOR l_idx IN l_period_tbl.first..l_period_tbl.last
   LOOP
    IF l_period_tbl.exists(l_idx) THEN

       p_prod_alloc_rec := NULL;

       p_time_alloc_rec.allocation_for := 'CUST';
       p_time_alloc_rec.allocation_for_id := l_account_allocation_id;
       p_time_alloc_rec.time_id := l_period_tbl(l_idx);
       p_time_alloc_rec.period_type_id := l_period_type_id;
       p_time_alloc_rec.target := ROUND( (NVL(l_time_target_unalloc, 0)), 0);
       p_time_alloc_rec.lysp_sales := 0;

       l_time_allocation_id := get_time_allocation_id;

       Ozf_Time_Allocations_Pkg.Insert_Row(
          px_time_allocation_id  => l_time_allocation_id,
          p_allocation_for  => p_time_alloc_rec.allocation_for,
          p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
          p_time_id  => p_time_alloc_rec.time_id,
          p_period_type_id => p_time_alloc_rec.period_type_id,
          p_target  => p_time_alloc_rec.target,
          p_lysp_sales  => p_time_alloc_rec.lysp_sales,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_attribute_category  => p_time_alloc_rec.attribute_category,
          p_attribute1  => p_time_alloc_rec.attribute1,
          p_attribute2  => p_time_alloc_rec.attribute2,
          p_attribute3  => p_time_alloc_rec.attribute3,
          p_attribute4  => p_time_alloc_rec.attribute4,
          p_attribute5  => p_time_alloc_rec.attribute5,
          p_attribute6  => p_time_alloc_rec.attribute6,
          p_attribute7  => p_time_alloc_rec.attribute7,
          p_attribute8  => p_time_alloc_rec.attribute8,
          p_attribute9  => p_time_alloc_rec.attribute9,
          p_attribute10  => p_time_alloc_rec.attribute10,
          p_attribute11  => p_time_alloc_rec.attribute11,
          p_attribute12  => p_time_alloc_rec.attribute12,
          p_attribute13  => p_time_alloc_rec.attribute13,
          p_attribute14  => p_time_alloc_rec.attribute14,
          p_attribute15  => p_time_alloc_rec.attribute15,
          px_org_id  => l_org_id
        );


     END IF;
   END LOOP unalloc_time_loop;

-------BEGIN: FIX for difference due to ROUNDING --------------------------------------------------|

   IF (MOD(l_total_target_unalloc, l_denominator) <> 0) THEN

         l_diff_target := 0;

         BEGIN

              SELECT a.TARGET INTO l_diff_target_1
              FROM OZF_ACCOUNT_ALLOCATIONS a
               WHERE a.allocation_for = 'FUND'
                 AND a.allocation_for_id = l_fund_id
                 AND a.parent_party_id = -9999;

              SELECT SUM(t.TARGET) INTO l_diff_target_2
              FROM OZF_TIME_ALLOCATIONS t
              WHERE  t.allocation_for = 'CUST'
                 AND t.allocation_for_id IN ( SELECT a.account_allocation_id
                                              FROM  OZF_ACCOUNT_ALLOCATIONS a
                                              WHERE a.allocation_for = 'FUND'
                                                AND a.allocation_for_id = l_fund_id
                                                AND a.parent_party_id = -9999 );

             l_diff_target := NVL(l_diff_target_1, 0) - NVL(l_diff_target_2, 0);

         EXCEPTION
            WHEN OTHERS THEN
                 l_diff_target := 0;
         END;


         IF l_diff_target <> 0 THEN

            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id) from OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'CUST'
                                            AND x.allocation_for_id IN ( SELECT a.account_allocation_id
                                                                         FROM  OZF_ACCOUNT_ALLOCATIONS a
                                                                         WHERE a.allocation_for = 'FUND'
                                                                           AND a.allocation_for_id = l_fund_id
                                                                           AND a.parent_party_id = -9999 )
                                           );

             IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_ROUNDING_TIME_ERR');
                    fnd_message.set_token('OZF_TP_OBJECT_TYPE_TOKEN','UNALLOCATED FUND');
                    fnd_message.set_token('OZF_TP_OBJECT_ID_TOKEN',l_fund_id);
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
             END IF;

         END IF;
   END IF;

-------END: FIX for difference due to ROUNDING --------------------------------------------------|

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Populating UNALLOCATED Allocations Records'
                                         || 'FOR FUND_Id = '|| l_fund_id || ' ; ');





   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN OZF_TP_INVALID_PARAM THEN
          ROLLBACK TO old_allocate_target_first_time;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_INVALID_PARAM_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : INVALID PARAMETER EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO old_allocate_target_first_time;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO old_allocate_target_first_time;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO old_allocate_target_first_time;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END old_allocate_target_first_time;



-- ------------------------
-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: ALLOCATE TARGET FIRST TIME
-- Desc: 1. Allocate Target across Accounts and Products for Sales Rep
--          when the Fact is published for the first time and a fund_id
--          is created.
--          May 18th, 2004:  The Product Spread for each Site is now
--                           based on its Year Ago Sales.
--                           (and Not on that Leaf Funds Product Spread).
-- -----------------------------------------------------------------
PROCEDURE allocate_target_first_time
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id            IN          NUMBER
) IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'allocate_target_first_time';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_fund_id                NUMBER;

   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; -- := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));    --Bugfix7540057

   l_start_date             VARCHAR2(30) := null;
   l_end_date               VARCHAR2(30) := null;
   l_period_type_id         NUMBER;
   l_lysp_in_clause         VARCHAR2(1000) := null;
   l_in_clause              VARCHAR2(1000) := null;
   l_territory_id           NUMBER;
   l_resource_id            NUMBER;

   l_total_lysp_sales       NUMBER;

   l_total_account_sales    NUMBER;
   l_account_sales          NUMBER;
   l_total_account_target   NUMBER;
   l_account_target         NUMBER;

   l_total_product_sales    NUMBER;
   l_product_sales          NUMBER;
   l_total_product_target   NUMBER;
   l_product_target         NUMBER;
   l_p_grand_total_lysp_sales NUMBER;
   l_p_denominator            NUMBER;

   l_total_root_quota       NUMBER;
   l_total_fund_quota       NUMBER;
   l_time_fund_target       NUMBER;

   l_multiplying_factor     NUMBER;
   l_prod_mltply_factor     NUMBER;

   l_account_allocation_id  NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;

   l_denominator            NUMBER;
   l_total_target_unalloc   NUMBER;
   l_time_target_unalloc    NUMBER;

   l_diff_target            NUMBER;
   l_diff_target_1          NUMBER;
   l_diff_target_2          NUMBER;

   l_temp_account_allocation_id NUMBER;
   l_temp_product_allocation_id NUMBER;

   l_period_tbl          OZF_TIME_API_PVT.G_period_tbl_type;
   l_lysp_period_tbl     OZF_TIME_API_PVT.G_period_tbl_type;

   p_acct_alloc_rec      ozf_account_allocations%ROWTYPE;
   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;



  CURSOR fund_csr (l_fund_id  NUMBER)
  IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
   FROM
    ozf_funds_all_vl
   WHERE
    fund_id = l_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;

  CURSOR territory_csr (l_resource_id NUMBER) IS
   SELECT
    j.terr_id territory_id
   FROM
    jtf_terr_rsc_all j, jtf_terr_rsc_access_all j2
   WHERE
       j.resource_id = l_resource_id
  -- AND j.primary_contact_flag = 'Y' ;
   AND j2.terr_rsc_id = j.terr_rsc_id
   AND j2.access_type = 'OFFER'
   AND j2.trans_access_code = 'PRIMARY_CONTACT';


/*
  CURSOR total_lysp_sales_csr (l_territory_id  NUMBER,
                               l_in_clause     VARCHAR2)
   IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ams_party_market_segments a
   WHERE
        a.market_qualifier_reference = l_territory_id
    AND a.market_qualifier_type='TERRITORY'
    AND bsmv.ship_to_site_use_id = a.site_use_id
    AND bsmv.time_id IN (l_in_clause);
*/

  l_total_lysp_sales_sql varchar2(30000) :=
   ' SELECT'||
   '  SUM(bsmv.sales) sales'||
   ' FROM'||
   '   ozf_order_sales_v bsmv,'||
   '   ams_party_market_segments a'||
   ' WHERE'||
   '      a.market_qualifier_reference = :l_territory_id    '||
   '  AND a.market_qualifier_type=''TERRITORY''  '||
   '  AND bsmv.ship_to_site_use_id = a.site_use_id'||
   '  AND bsmv.time_id IN (';

  total_lysp_sales_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable)


  CURSOR account_csr
        (l_territory_id    number)
  IS
  SELECT
    a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id,
    a.site_use_code                                          site_use_code,
    OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    NVL(a.bill_to_site_use_id, -9996)                        bill_to_site_use_id,
    OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    a.party_id                                               parent_party_id,
    NVL(a.rollup_party_id, a.party_id)                       rollup_party_id
  FROM
    ams_party_market_segments a
  WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id IS NOT NULL;

/*
  SELECT
    a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id,
    a.site_use_code                                          site_use_code,
    OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    a.bill_to_site_use_id                                    bill_to_site_use_id,
    OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    a.party_id                                               parent_party_id,
    a.rollup_party_id                                        rollup_party_id
  FROM
    ams_party_market_segments a
  WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY';
*/

/*
  CURSOR account_total_sales_csr
         (l_site_use_id         number,
          l_in_clause           varchar2)
  IS
  SELECT
      SUM(bsmv.sales) account_sales
  FROM
      ozf_order_sales_v bsmv
  WHERE
      bsmv.ship_to_site_use_id = l_site_use_id
  AND bsmv.time_id IN (l_in_clause);

*/

  l_account_total_sales_sql varchar2(30000) :=
  ' SELECT '||
  '     SUM(bsmv.sales) account_sales'||
  ' FROM '||
  '     ozf_order_sales_v bsmv'||
  ' WHERE '||
  '     bsmv.ship_to_site_use_id = :l_site_use_id'||
  ' AND bsmv.time_id IN (' ;
  --l_in_clause);

  account_total_sales_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable


  CURSOR account_sales_csr
         (l_site_use_id         number,
          l_time_id             number)
  IS
  SELECT
      SUM(bsmv.sales) account_sales
  FROM
      ozf_order_sales_v bsmv
  WHERE
      bsmv.ship_to_site_use_id = l_site_use_id
  AND bsmv.time_id = l_time_id;

/*
  CURSOR get_total_target_csr
        (l_fund_id   NUMBER,
     l_in_clause VARCHAR2) IS
   SELECT SUM(t.target)
   FROM
       ozf_time_allocations t,
       ozf_product_allocations p
   WHERE
       p.fund_id = l_fund_id
   AND t.allocation_for_id   = p.product_allocation_id
   AND t.allocation_for      = 'PROD'
   AND t.time_id IN (l_in_clause);
*/

  l_get_total_target_sql VARCHAR2(30000) :=
   ' SELECT SUM(t.target) '||
   ' FROM '||
   '     ozf_time_allocations t,'||
   '     ozf_product_allocations p'||
   ' WHERE'||
   '     p.fund_id = :l_fund_id'||
   ' AND t.allocation_for_id   = p.product_allocation_id'||
   ' AND t.allocation_for      = ''PROD'' '||
   ' AND t.time_id IN (';
--l_in_clause);

  get_total_target_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable)


  CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                                 l_territory_id  NUMBER,
                                 l_site_use_id   NUMBER,
                                 l_time_id       NUMBER) IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ams_party_market_segments a
   WHERE
        a.market_qualifier_reference = l_territory_id
    AND a.market_qualifier_type='TERRITORY'
    AND a.site_use_id = l_site_use_id
    AND bsmv.ship_to_site_use_id = a.site_use_id
    AND bsmv.inventory_item_id = l_product_id
    AND bsmv.time_id = l_time_id;


  CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                  l_territory_id   NUMBER,
                                  l_site_use_id    NUMBER,
                                  l_time_id        NUMBER,
                                  l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND bsmv.inventory_item_id IN
                             ( SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                               FROM   MTL_ITEM_CATEGORIES     MIC,
                                      ENI_PROD_DENORM_HRCHY_V DENORM
                               WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                                AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                                AND   DENORM.PARENT_ID     = l_category_id
                               MINUS
                               SELECT p.item_id
                               FROM   ozf_product_allocations p
                               WHERE  p.fund_id = l_fund_id
                                  AND p.item_type = 'PRICING_ATTRIBUTE1'
                             );


  CURSOR others_lysp_sales_csr (l_territory_id   NUMBER,
                                l_site_use_id    NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND NOT EXISTS
  (
  ( SELECT p.item_id
    FROM ozf_product_allocations p
    WHERE
        p.fund_id = l_fund_id
    AND p.item_type = 'PRICING_ATTRIBUTE1'
    AND p.item_id = bsmv.inventory_item_id
    UNION ALL
    SELECT MIC.INVENTORY_ITEM_ID
    FROM   MTL_ITEM_CATEGORIES MIC,
           ENI_PROD_DENORM_HRCHY_V DENORM,
           OZF_PRODUCT_ALLOCATIONS p
    WHERE p.FUND_ID = l_fund_id
      AND p.ITEM_TYPE = 'PRICING_ATTRIBUTE2'
      AND p.ITEM_ID = DENORM.PARENT_ID
      AND MIC.CATEGORY_SET_ID = DENORM.CATEGORY_SET_ID
      AND MIC.CATEGORY_ID = DENORM.CHILD_ID
      AND MIC.INVENTORY_ITEM_ID = bsmv.inventory_item_id
  )
  MINUS
  SELECT prod.inventory_item_id
  FROM ams_act_products prod
  where
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'Y'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  );

  CURSOR fund_product_spread_csr
         (l_fund_id        number) IS
    SELECT
       p.product_allocation_id,
       p.item_id,
       p.item_type,
       p.target
    FROM
       ozf_product_allocations p
    WHERE
       p.fund_id = l_fund_id;

   l_fund_product_rec     fund_product_spread_csr%rowtype;

   CURSOR fund_time_spread_csr
         (l_product_allocation_id       number,
          l_time_id                     number) IS
   SELECT t.target
   FROM
       ozf_time_allocations t
   WHERE
       t.allocation_for_id = l_product_allocation_id
   AND t.allocation_for = 'PROD'
   AND t.time_id = l_time_id;


 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT allocate_target_first_time;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   l_fund_id := p_fund_id;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   l_resource_id := l_fund_rec.owner;
   l_territory_id := l_fund_rec.node_id;

   IF l_territory_id IS NULL THEN
      OPEN territory_csr(l_resource_id);
      FETCH territory_csr INTO l_territory_id;
      CLOSE territory_csr ;
   END IF;

   l_org_id := get_org_id(l_territory_id);    --Bugfix 7540057

   l_start_date := to_char(l_fund_rec.start_date_active, 'YYYY/MM/DD');
   l_end_date   := to_char(l_fund_rec.end_date_active, 'YYYY/MM/DD');
   l_period_type_id := l_fund_rec.period_type_id;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Getting Time_ids Between '
                                                 ||l_start_date||' AND '||l_end_date||' ; '
                                                 ||' Period_Type_id = '||l_period_type_id||' ; ');

   IF l_start_date IS NULL OR
      l_end_date IS NULL OR
      l_period_type_id IS NULL
   THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   l_period_tbl := OZF_TIME_API_PVT.get_period_tbl
                                    (l_start_date,
                                     l_end_date,
                                     l_period_type_id);

   IF l_period_tbl IS NULL OR l_period_tbl.COUNT <= 0 THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Getting Time_ids Between '||l_start_date
                                         ||' AND '||l_end_date||' ; ');
   IF l_period_tbl IS NOT NULL THEN
    IF l_period_tbl.COUNT > 0 THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
        IF l_period_tbl.exists(l_idx) THEN

         l_lysp_period_tbl(l_idx) := OZF_TIME_API_PVT.get_lysp_id (l_period_tbl(l_idx), l_period_type_id);

         OZF_UTILITY_PVT.debug_message(SubStr('l_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_period_tbl(l_idx)), 1,255));
        END IF;
      END LOOP;
    END IF;
   END IF;

   --l_in_clause := '(';
   l_in_clause := NULL;
   IF l_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
          IF l_in_clause IS NULL THEN
             l_in_clause := LTRIM(' '||l_period_tbl(l_idx));
          ELSE
             l_in_clause := l_in_clause ||','|| l_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_in_clause := l_in_clause||')';

   l_lysp_in_clause := NULL;
   IF l_lysp_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_lysp_period_tbl.first..l_lysp_period_tbl.last
      LOOP
          IF l_lysp_in_clause IS NULL THEN
             l_lysp_in_clause := LTRIM(' '||l_lysp_period_tbl(l_idx));
          ELSE
             l_lysp_in_clause := l_lysp_in_clause ||','|| l_lysp_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_lysp_in_clause := l_lysp_in_clause||')';


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Time_ids between '||l_start_date
                                         ||' AND '||l_end_date||' ARE : '||l_in_clause||' ; ');
   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': LYSP-Time_ids between '||l_start_date
                                         ||' AND '||l_end_date||' ARE : '||l_lysp_in_clause||' ; ');


   l_total_lysp_sales_sql := l_total_lysp_sales_sql||l_lysp_in_clause||')';

   OPEN total_lysp_sales_csr FOR l_total_lysp_sales_sql USING l_territory_id;
--   OPEN total_lysp_sales_csr(l_territory_id,l_lysp_in_clause);
   FETCH total_lysp_sales_csr INTO l_total_lysp_sales;
   CLOSE total_lysp_sales_csr;
   l_total_lysp_sales := NVL(l_total_lysp_sales, 0);

   l_total_root_quota := NVL(l_fund_rec.original_budget,0) + NVL(l_fund_rec.transfered_in_amt,0);

   l_total_target_unalloc := 0;
   l_time_target_unalloc := 0;
   l_multiplying_factor := 0;

   IF l_total_lysp_sales > 0 THEN
      l_multiplying_factor := l_total_root_quota / l_total_lysp_sales;
   ELSE
      l_multiplying_factor := 0;
      l_denominator := l_period_tbl.COUNT;

      l_total_target_unalloc := l_total_root_quota;
      l_time_target_unalloc := l_total_root_quota / l_denominator;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Multiplying Factor = '
                                                 || l_multiplying_factor || ' ; ');

------ for product allocations: based upon Funds product spread ------------------

   l_get_total_target_sql := l_get_total_target_sql||l_in_clause ||')';

   OPEN get_total_target_csr FOR l_get_total_target_sql USING l_fund_id;
   FETCH get_total_target_csr INTO l_total_fund_quota;
   CLOSE get_total_target_csr ;

   l_total_fund_quota := NVL(l_total_fund_quota, 0);

------- Insert rows for ACCOUNTS  ------------------------------------------------

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name
                              || ': Begin - Populating Account and Time Allocations Records'
                              || ' FOR Fund_id = '|| l_fund_id
                              || ' AND Territory_id = '|| l_territory_id
                              || ' ; ');


   l_account_total_sales_sql := l_account_total_sales_sql||l_lysp_in_clause ||')';

   <<account_loop>>
   FOR account_rec IN account_csr(l_territory_id)
   LOOP
       p_acct_alloc_rec := NULL;

       OPEN account_total_sales_csr FOR l_account_total_sales_sql USING account_rec.site_use_id;
--       OPEN account_total_sales_csr (account_rec.site_use_id, l_lysp_in_clause);
       FETCH account_total_sales_csr into l_total_account_sales;
       CLOSE account_total_sales_csr;

       l_total_account_sales := NVL(l_total_account_sales, 0);
       l_total_account_target := ROUND( (l_total_account_sales * l_multiplying_factor), 0);

       p_acct_alloc_rec.allocation_for := 'FUND';
       p_acct_alloc_rec.allocation_for_id := l_fund_id;
       p_acct_alloc_rec.cust_account_id := account_rec.cust_account_id;
       p_acct_alloc_rec.site_use_id := account_rec.site_use_id;
       p_acct_alloc_rec.site_use_code := account_rec.site_use_code;
       p_acct_alloc_rec.location_id := account_rec.location_id;
       p_acct_alloc_rec.bill_to_site_use_id := account_rec.bill_to_site_use_id;
       p_acct_alloc_rec.bill_to_location_id := account_rec.bill_to_location_id;
       p_acct_alloc_rec.parent_party_id := account_rec.parent_party_id;
       p_acct_alloc_rec.rollup_party_id := account_rec.rollup_party_id;
       p_acct_alloc_rec.selected_flag := 'Y';
       p_acct_alloc_rec.target := l_total_account_target;
       p_acct_alloc_rec.lysp_sales := l_total_account_sales;

       l_account_allocation_id := get_account_allocation_id;

       Ozf_Account_Allocations_Pkg.Insert_Row(
          px_Account_allocation_id        => l_account_allocation_id,
          p_allocation_for                => p_acct_alloc_rec.allocation_for,
          p_allocation_for_id             => p_acct_alloc_rec.allocation_for_id,
          p_cust_account_id               => p_acct_alloc_rec.cust_account_id,
          p_site_use_id                   => p_acct_alloc_rec.site_use_id,
          p_site_use_code                 => p_acct_alloc_rec.site_use_code,
          p_location_id                   => p_acct_alloc_rec.location_id,
          p_bill_to_site_use_id           => p_acct_alloc_rec.bill_to_site_use_id,
          p_bill_to_location_id           => p_acct_alloc_rec.bill_to_location_id,
          p_parent_party_id               => p_acct_alloc_rec.parent_party_id,
          p_rollup_party_id               => p_acct_alloc_rec.rollup_party_id,
          p_selected_flag                 => p_acct_alloc_rec.selected_flag,
          p_target                        => p_acct_alloc_rec.target,
          p_lysp_sales                    => p_acct_alloc_rec.lysp_sales,
          p_parent_Account_allocation_id  => p_acct_alloc_rec.parent_Account_allocation_id,
          px_object_version_number        => l_object_version_number,
          p_creation_date                 => SYSDATE,
          p_created_by                    => FND_GLOBAL.USER_ID,
          p_last_update_date              => SYSDATE,
          p_last_updated_by               => FND_GLOBAL.USER_ID,
          p_last_update_login             => FND_GLOBAL.conc_login_id,
          p_attribute_category            => p_acct_alloc_rec.attribute_category,
          p_attribute1                    => p_acct_alloc_rec.attribute1,
          p_attribute2                    => p_acct_alloc_rec.attribute2,
          p_attribute3                    => p_acct_alloc_rec.attribute3,
          p_attribute4                    => p_acct_alloc_rec.attribute4,
          p_attribute5                    => p_acct_alloc_rec.attribute5,
          p_attribute6                    => p_acct_alloc_rec.attribute6,
          p_attribute7                    => p_acct_alloc_rec.attribute7,
          p_attribute8                    => p_acct_alloc_rec.attribute8,
          p_attribute9                    => p_acct_alloc_rec.attribute9,
          p_attribute10                   => p_acct_alloc_rec.attribute10,
          p_attribute11                   => p_acct_alloc_rec.attribute11,
          p_attribute12                   => p_acct_alloc_rec.attribute12,
          p_attribute13                   => p_acct_alloc_rec.attribute13,
          p_attribute14                   => p_acct_alloc_rec.attribute14,
          p_attribute15                   => p_acct_alloc_rec.attribute15,
          px_org_id                       => l_org_id
        );

       <<account_time_loop>>
       FOR l_idx IN l_period_tbl.first..l_period_tbl.last
       LOOP
        IF l_period_tbl.exists(l_idx) THEN

           p_time_alloc_rec := NULL;
           l_account_sales := 0;

           OPEN account_sales_csr (account_rec.site_use_id, l_lysp_period_tbl(l_idx));
           FETCH account_sales_csr into l_account_sales;
           CLOSE account_sales_csr;

           l_account_sales := NVL(l_account_sales, 0);
           l_account_target := ROUND((l_account_sales * l_multiplying_factor), 0);


           p_time_alloc_rec.allocation_for := 'CUST';
           p_time_alloc_rec.allocation_for_id := l_account_allocation_id;
           p_time_alloc_rec.time_id := l_period_tbl(l_idx);
           p_time_alloc_rec.period_type_id := l_period_type_id;
           p_time_alloc_rec.target := l_account_target;
           p_time_alloc_rec.lysp_sales := l_account_sales;

           l_time_allocation_id := get_time_allocation_id;

           Ozf_Time_Allocations_Pkg.Insert_Row(
              px_time_allocation_id  => l_time_allocation_id,
              p_allocation_for  => p_time_alloc_rec.allocation_for,
              p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
              p_time_id  => p_time_alloc_rec.time_id,
              p_period_type_id => p_time_alloc_rec.period_type_id,
              p_target  => p_time_alloc_rec.target,
              p_lysp_sales  => p_time_alloc_rec.lysp_sales,
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_time_alloc_rec.attribute_category,
              p_attribute1  => p_time_alloc_rec.attribute1,
              p_attribute2  => p_time_alloc_rec.attribute2,
              p_attribute3  => p_time_alloc_rec.attribute3,
              p_attribute4  => p_time_alloc_rec.attribute4,
              p_attribute5  => p_time_alloc_rec.attribute5,
              p_attribute6  => p_time_alloc_rec.attribute6,
              p_attribute7  => p_time_alloc_rec.attribute7,
              p_attribute8  => p_time_alloc_rec.attribute8,
              p_attribute9  => p_time_alloc_rec.attribute9,
              p_attribute10  => p_time_alloc_rec.attribute10,
              p_attribute11  => p_time_alloc_rec.attribute11,
              p_attribute12  => p_time_alloc_rec.attribute12,
              p_attribute13  => p_time_alloc_rec.attribute13,
              p_attribute14  => p_time_alloc_rec.attribute14,
              p_attribute15  => p_time_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


         END IF;
       END LOOP account_time_loop;


   -- For a Given ShipTo, Account Level Target SHOULD be exactly equal to SUM of its Time Level Targets
   --                     Basically, get rid of any Rounding error.

   BEGIN

      SELECT SUM(ti.TARGET) into l_total_account_target
       FROM  OZF_TIME_ALLOCATIONS ti
      WHERE  ti.ALLOCATION_FOR = 'CUST'
        AND  ti.ALLOCATION_FOR_ID = l_account_allocation_id;

      UPDATE OZF_ACCOUNT_ALLOCATIONS a
      SET a.TARGET = l_total_account_target,
          a.object_version_number = a.object_version_number + 1,
          a.last_update_date = SYSDATE,
          a.last_updated_by = FND_GLOBAL.USER_ID,
          a.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE a.account_allocation_id = l_account_allocation_id;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   EXCEPTION
     WHEN OTHERS THEN
          null;
   END;



------- Insert rows for PRODUCT and TIME Allocation Records for given ACCOUNT ---------------------------


       OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                             ': Begin - Populating Product and Time Allocations Records'
                              || 'FOR site_use_id = '|| account_rec.site_use_id || ' ; ');


--//00000 May17th,2004 - as per new requirements in Bug 3594874 000000000000000000000000000000000000
/*
       l_total_fund_quota := NVL(l_total_fund_quota, 0);

       IF l_total_fund_quota > 0 THEN
          l_prod_mltply_factor := l_total_account_target / l_total_fund_quota;
       ELSE
          l_prod_mltply_factor := 0;
       END IF;
*/
--//0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

       l_p_grand_total_lysp_sales := 0;

       <<account_product_loop>>
       FOR fund_product_rec IN fund_product_spread_csr(l_fund_id)
       LOOP

           p_prod_alloc_rec := NULL;

           --l_total_product_target := ROUND( (NVL(fund_product_rec.target ,0) * l_prod_mltply_factor), 0);

           p_prod_alloc_rec.allocation_for := 'CUST';
           p_prod_alloc_rec.allocation_for_id := l_account_allocation_id;
           p_prod_alloc_rec.item_type := fund_product_rec.item_type;
           p_prod_alloc_rec.item_id := fund_product_rec.item_id;
           p_prod_alloc_rec.selected_flag := 'N';
           p_prod_alloc_rec.target := 0; --- l_total_product_target;
           p_prod_alloc_rec.lysp_sales := 0;

           l_product_allocation_id := get_product_allocation_id;

           Ozf_Product_Allocations_Pkg.Insert_Row(
              px_product_allocation_id  => l_product_allocation_id,
              p_allocation_for  => p_prod_alloc_rec.allocation_for,
              p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
              p_fund_id  => p_prod_alloc_rec.fund_id,
              p_item_type  => p_prod_alloc_rec.item_type,
              p_item_id  => p_prod_alloc_rec.item_id,
              p_selected_flag  => p_prod_alloc_rec.selected_flag,
              p_target  => p_prod_alloc_rec.target,
              p_lysp_sales  => p_prod_alloc_rec.lysp_sales,
              p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_prod_alloc_rec.attribute_category,
              p_attribute1  => p_prod_alloc_rec.attribute1,
              p_attribute2  => p_prod_alloc_rec.attribute2,
              p_attribute3  => p_prod_alloc_rec.attribute3,
              p_attribute4  => p_prod_alloc_rec.attribute4,
              p_attribute5  => p_prod_alloc_rec.attribute5,
              p_attribute6  => p_prod_alloc_rec.attribute6,
              p_attribute7  => p_prod_alloc_rec.attribute7,
              p_attribute8  => p_prod_alloc_rec.attribute8,
              p_attribute9  => p_prod_alloc_rec.attribute9,
              p_attribute10  => p_prod_alloc_rec.attribute10,
              p_attribute11  => p_prod_alloc_rec.attribute11,
              p_attribute12  => p_prod_alloc_rec.attribute12,
              p_attribute13  => p_prod_alloc_rec.attribute13,
              p_attribute14  => p_prod_alloc_rec.attribute14,
              p_attribute15  => p_prod_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


           l_total_product_sales := 0;

           <<account_product_time_loop>>
           FOR l_idx IN l_period_tbl.first..l_period_tbl.last
           LOOP
            IF l_period_tbl.exists(l_idx) THEN

               p_time_alloc_rec := NULL;

--//00000 May17th,2004 - as per new requirements in Bug 3594874 000000000000000000000000000000000000
/*
               OPEN fund_time_spread_csr(fund_product_rec.product_allocation_id, l_period_tbl(l_idx));
               FETCH fund_time_spread_csr INTO l_time_fund_target;
               CLOSE fund_time_spread_csr ;

               l_time_fund_target := NVL(l_time_fund_target, 0);

               l_product_target := ROUND( (l_time_fund_target * l_prod_mltply_factor), 0 );
*/
--//00000 May17th,2004 - as per new requirements in Bug 3594874 000000000000000000000000000000000000

               l_product_sales := 0;

               IF fund_product_rec.item_type = 'PRICING_ATTRIBUTE1' THEN
                  OPEN product_lysp_sales_csr(fund_product_rec.item_id,
                                              l_territory_id,
                                              account_rec.site_use_id,
                                              l_lysp_period_tbl(l_idx)
                                             );
                  FETCH product_lysp_sales_csr INTO l_product_sales;
                  CLOSE product_lysp_sales_csr;
               ELSIF fund_product_rec.item_type = 'PRICING_ATTRIBUTE2' THEN
                   OPEN category_lysp_sales_csr(fund_product_rec.item_id,
                                                l_territory_id,
                                                account_rec.site_use_id,
                                                l_lysp_period_tbl(l_idx),
                                                l_fund_id
                                               );
                   FETCH category_lysp_sales_csr INTO l_product_sales;
                   CLOSE category_lysp_sales_csr;
               ELSIF fund_product_rec.item_type = 'OTHERS' THEN
                   OPEN others_lysp_sales_csr(l_territory_id,
                                              account_rec.site_use_id,
                                              l_lysp_period_tbl(l_idx),
                                              l_fund_id
                                             );
                   FETCH others_lysp_sales_csr INTO l_product_sales;
                   CLOSE others_lysp_sales_csr;
               END IF;

               l_product_sales := NVL(l_product_sales, 0);
               l_total_product_sales := l_total_product_sales + l_product_sales;

               p_time_alloc_rec.allocation_for := 'PROD';
               p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
               p_time_alloc_rec.time_id := l_period_tbl(l_idx);
               p_time_alloc_rec.period_type_id := l_period_type_id;
               p_time_alloc_rec.target := 0;  ---------l_product_target;
               p_time_alloc_rec.lysp_sales := l_product_sales;

               l_time_allocation_id := get_time_allocation_id;

               Ozf_Time_Allocations_Pkg.Insert_Row(
                  px_time_allocation_id  => l_time_allocation_id,
                  p_allocation_for  => p_time_alloc_rec.allocation_for,
                  p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
                  p_time_id  => p_time_alloc_rec.time_id,
                  p_period_type_id => p_time_alloc_rec.period_type_id,
                  p_target  => p_time_alloc_rec.target,
                  p_lysp_sales  => p_time_alloc_rec.lysp_sales,
                  px_object_version_number  => l_object_version_number,
                  p_creation_date  => SYSDATE,
                  p_created_by  => FND_GLOBAL.USER_ID,
                  p_last_update_date  => SYSDATE,
                  p_last_updated_by  => FND_GLOBAL.USER_ID,
                  p_last_update_login  => FND_GLOBAL.conc_login_id,
                  p_attribute_category  => p_time_alloc_rec.attribute_category,
                  p_attribute1  => p_time_alloc_rec.attribute1,
                  p_attribute2  => p_time_alloc_rec.attribute2,
                  p_attribute3  => p_time_alloc_rec.attribute3,
                  p_attribute4  => p_time_alloc_rec.attribute4,
                  p_attribute5  => p_time_alloc_rec.attribute5,
                  p_attribute6  => p_time_alloc_rec.attribute6,
                  p_attribute7  => p_time_alloc_rec.attribute7,
                  p_attribute8  => p_time_alloc_rec.attribute8,
                  p_attribute9  => p_time_alloc_rec.attribute9,
                  p_attribute10  => p_time_alloc_rec.attribute10,
                  p_attribute11  => p_time_alloc_rec.attribute11,
                  p_attribute12  => p_time_alloc_rec.attribute12,
                  p_attribute13  => p_time_alloc_rec.attribute13,
                  p_attribute14  => p_time_alloc_rec.attribute14,
                  p_attribute15  => p_time_alloc_rec.attribute15,
                  px_org_id  => l_org_id
                );


             END IF;
           END LOOP account_product_time_loop;

           UPDATE OZF_PRODUCT_ALLOCATIONS p
           SET p.lysp_sales = l_total_product_sales,
               p.object_version_number = p.object_version_number + 1,
               p.last_update_date = SYSDATE,
               p.last_updated_by = FND_GLOBAL.USER_ID,
               p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
           WHERE p.product_allocation_id = l_product_allocation_id;

           l_p_grand_total_lysp_sales := l_p_grand_total_lysp_sales + l_total_product_sales;

       END LOOP account_product_loop;


------ Updating Target --Added on May 18th, 2004 --------------------------------------
------------------------ for each ShipTos Product Spread ------------------------------

   l_prod_mltply_factor := 0;
   IF l_p_grand_total_lysp_sales > 0 THEN
      l_prod_mltply_factor := NVL(l_total_account_target, 0) / l_p_grand_total_lysp_sales;
   ELSE
      l_prod_mltply_factor := 0;
   END IF;

-- OZF_UTILITY_PVT.debug_message('1. mkothari --'||' -- l_prod_mltply_factor==> '||l_prod_mltply_factor || ' ; ');
-- OZF_UTILITY_PVT.debug_message('2. mkothari --'||' l_total_account_target===> '||l_total_account_target);
-- OZF_UTILITY_PVT.debug_message('3. mkothari --'||' l_p_grand_total_lysp_sales='||l_p_grand_total_lysp_sales);

   UPDATE OZF_TIME_ALLOCATIONS t
   SET t.TARGET = ROUND((NVL(t.LYSP_SALES, 0) * l_prod_mltply_factor), 0),
       t.object_version_number = t.object_version_number + 1,
       t.last_update_date = SYSDATE,
       t.last_updated_by = FND_GLOBAL.USER_ID,
       t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE  t.allocation_for = 'PROD'
   AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                 FROM  OZF_PRODUCT_ALLOCATIONS p
                                 WHERE p.allocation_for = 'CUST'
                                   AND p.allocation_for_id = l_account_allocation_id);

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
         fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   UPDATE OZF_PRODUCT_ALLOCATIONS p
   SET p.TARGET = (SELECT SUM(ti.TARGET)
                     FROM OZF_TIME_ALLOCATIONS ti
                    WHERE ti.ALLOCATION_FOR = 'PROD'
                      AND ti.ALLOCATION_FOR_ID = p.PRODUCT_ALLOCATION_ID),
       p.object_version_number = p.object_version_number + 1,
       p.last_update_date = SYSDATE,
       p.last_updated_by = FND_GLOBAL.USER_ID,
       p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE p.allocation_for = 'CUST'
     AND p.allocation_for_id = l_account_allocation_id;

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
         fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
   END IF;



   -- Handling Corner Case : If all products including others have ZERO lysp sales, then
   --                        OTHERS get all the Quota. It is equally distributed in all
   --                        time periods.

   IF l_prod_mltply_factor = 0 THEN

      l_p_denominator := l_period_tbl.COUNT;

/*
      UPDATE OZF_PRODUCT_ALLOCATIONS p
      SET p.TARGET = ROUND(NVL(l_total_account_target, 0),0),
          p.object_version_number = p.object_version_number + 1,
          p.last_update_date = SYSDATE,
          p.last_updated_by = FND_GLOBAL.USER_ID,
          p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE p.allocation_for = 'CUST'
        AND p.allocation_for_id = l_account_allocation_id
        AND p.item_id = -9999;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/

      UPDATE OZF_TIME_ALLOCATIONS t
      SET t.TARGET = ROUND((NVL(l_total_account_target, 0) / l_p_denominator), 0),
          t.object_version_number = t.object_version_number + 1,
          t.last_update_date = SYSDATE,
          t.last_updated_by = FND_GLOBAL.USER_ID,
          t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE  t.allocation_for = 'PROD'
      AND t.allocation_for_id IN ( SELECT p.product_allocation_id
                                    FROM  OZF_PRODUCT_ALLOCATIONS p
                                    WHERE p.allocation_for = 'CUST'
                                      AND p.allocation_for_id = l_account_allocation_id
                                      AND p.item_id = -9999 );

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      UPDATE OZF_PRODUCT_ALLOCATIONS p
      SET p.TARGET = (SELECT SUM(ti.TARGET)
                        FROM OZF_TIME_ALLOCATIONS ti
                       WHERE ti.ALLOCATION_FOR = 'PROD'
                         AND ti.ALLOCATION_FOR_ID = p.PRODUCT_ALLOCATION_ID),
          p.object_version_number = p.object_version_number + 1,
          p.last_update_date = SYSDATE,
          p.last_updated_by = FND_GLOBAL.USER_ID,
          p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE p.allocation_for = 'CUST'
        AND p.allocation_for_id = l_account_allocation_id
        AND p.item_id = -9999;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



   END IF;


-------BEGIN: FIX for difference due to ROUNDING FOR each ShipTos Product Spread ------------------|

         l_diff_target   := 0;
         l_diff_target_1 := 0;

     BEGIN


              SELECT SUM(p.TARGET) INTO l_diff_target_1
              FROM OZF_PRODUCT_ALLOCATIONS p
               WHERE p.allocation_for = 'CUST'
                 AND p.allocation_for_id = l_account_allocation_id;

             l_diff_target := (NVL(l_total_account_target, 0) - NVL(l_diff_target_1, 0));

-- OZF_UTILITY_PVT.debug_message('mkothari -- l_diff_target => '||l_diff_target || ' ; ');

         EXCEPTION
            WHEN OTHERS THEN
                 l_diff_target := 0;
         END;

     IF ABS(l_diff_target) >= 1 THEN

            IF SIGN(l_diff_target) = -1 THEN
               l_diff_target := CEIL(l_diff_target); -- (So, -1.5 will become -1 )
            ELSE
               l_diff_target := FLOOR(l_diff_target); -- (So, +1.5 will become +1)
            END IF;

            fix_product_rounding_err('CUST', l_account_allocation_id, l_diff_target);


/*
            l_temp_product_allocation_id := 0;

            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id)
                                            FROM OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'PROD'
                                            AND x.allocation_for_id IN ( SELECT max(p.product_allocation_id)
                                                                         FROM  OZF_PRODUCT_ALLOCATIONS p
                                                                         WHERE p.allocation_for = 'CUST'
                                                                           AND p.allocation_for_id = l_account_allocation_id
                                                                           AND p.target =
                                                                              (SELECT max(xz.target)
                                                                               FROM OZF_PRODUCT_ALLOCATIONS xz
                                                                               WHERE xz.allocation_for = 'CUST'
                                                                               AND xz.allocation_for_id = l_account_allocation_id
                                                                               )

                                                                         )
                                           AND x.target =
                                               (SELECT max(zx.target)
                                                FROM OZF_TIME_ALLOCATIONS zx
                                                WHERE  zx.allocation_for = 'PROD'
                                                AND zx.allocation_for_id IN (SELECT max(pz.product_allocation_id)
                                                                             FROM  OZF_PRODUCT_ALLOCATIONS pz
                                                                             WHERE pz.allocation_for = 'CUST'
                                                                               AND pz.allocation_for_id = l_account_allocation_id
                                                                               AND pz.target =
                                                                                (SELECT max(xz.target)
                                                                                 FROM OZF_PRODUCT_ALLOCATIONS xz
                                                                                WHERE xz.allocation_for = 'CUST'
                                                                                AND xz.allocation_for_id = l_account_allocation_id
                                                                                )

                                                                             )
                                               )
                                           )
              RETURNING t.allocation_for_id INTO l_temp_product_allocation_id;


              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

         UPDATE OZF_PRODUCT_ALLOCATIONS p
                SET p.TARGET = p.TARGET + l_diff_target,
                    p.object_version_number = p.object_version_number + 1,
                    p.last_update_date = SYSDATE,
                    p.last_updated_by = FND_GLOBAL.USER_ID,
                    p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE p.product_allocation_id = l_temp_product_allocation_id;

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;
*/


/*---------------------------------------------------------------------------------------------------
            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id) from OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'PROD'
                                            AND x.allocation_for_id IN ( SELECT p.product_allocation_id
                                                                         FROM  OZF_PRODUCT_ALLOCATIONS p
                                                                         WHERE p.allocation_for = 'CUST'
                                                                           AND p.allocation_for_id = l_account_allocation_id
                                                                           AND p.item_id = -9999 )
                                           );


              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

         UPDATE OZF_PRODUCT_ALLOCATIONS p
                SET p.TARGET = p.TARGET + l_diff_target,
                    p.object_version_number = p.object_version_number + 1,
                    p.last_update_date = SYSDATE,
                    p.last_updated_by = FND_GLOBAL.USER_ID,
                    p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE p.allocation_for = 'CUST'
                AND p.allocation_for_id = l_account_allocation_id
        AND p.item_id = -9999;

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;
---------------------------------------------------------------------------------------------------
*/

      END IF;

--------END: FIX for difference due to ROUNDING FOR each ShipTos Product Spread ------------------|


       OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                             ': End - Populating Product and Time Allocations Records'
                             || 'FOR site_use_id = '|| account_rec.site_use_id || ' ; ');


   END LOOP account_loop;


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Begin - Populating UNALLOCATED Allocations Records'
                                         || 'FOR FUND_Id = '|| l_fund_id || ' ; ');

   p_acct_alloc_rec := NULL;

   p_acct_alloc_rec.allocation_for := 'FUND';
   p_acct_alloc_rec.allocation_for_id := l_fund_id;
   p_acct_alloc_rec.cust_account_id := -9999;
   p_acct_alloc_rec.site_use_id := -9999;
   p_acct_alloc_rec.bill_to_site_use_id := -9999;
   p_acct_alloc_rec.parent_party_id := -9999;
   p_acct_alloc_rec.rollup_party_id := -9999;
   p_acct_alloc_rec.selected_flag := 'N';
   p_acct_alloc_rec.target := ROUND( (NVL(l_total_target_unalloc, 0)), 0);
   p_acct_alloc_rec.lysp_sales := 0;

   l_account_allocation_id := get_account_allocation_id;

   Ozf_Account_Allocations_Pkg.Insert_Row(
      px_Account_allocation_id        => l_account_allocation_id,
      p_allocation_for                => p_acct_alloc_rec.allocation_for,
      p_allocation_for_id             => p_acct_alloc_rec.allocation_for_id,
      p_cust_account_id               => p_acct_alloc_rec.cust_account_id,
      p_site_use_id                   => p_acct_alloc_rec.site_use_id,
      p_site_use_code                 => p_acct_alloc_rec.site_use_code,
      p_location_id                   => p_acct_alloc_rec.location_id,
      p_bill_to_site_use_id           => p_acct_alloc_rec.bill_to_site_use_id,
      p_bill_to_location_id           => p_acct_alloc_rec.bill_to_location_id,
      p_parent_party_id               => p_acct_alloc_rec.parent_party_id,
      p_rollup_party_id               => p_acct_alloc_rec.rollup_party_id,
      p_selected_flag                 => p_acct_alloc_rec.selected_flag,
      p_target                        => p_acct_alloc_rec.target,
      p_lysp_sales                    => p_acct_alloc_rec.lysp_sales,
      p_parent_Account_allocation_id  => p_acct_alloc_rec.parent_Account_allocation_id,
      px_object_version_number        => l_object_version_number,
      p_creation_date                 => SYSDATE,
      p_created_by                    => FND_GLOBAL.USER_ID,
      p_last_update_date              => SYSDATE,
      p_last_updated_by               => FND_GLOBAL.USER_ID,
      p_last_update_login             => FND_GLOBAL.conc_login_id,
      p_attribute_category            => p_acct_alloc_rec.attribute_category,
      p_attribute1                    => p_acct_alloc_rec.attribute1,
      p_attribute2                    => p_acct_alloc_rec.attribute2,
      p_attribute3                    => p_acct_alloc_rec.attribute3,
      p_attribute4                    => p_acct_alloc_rec.attribute4,
      p_attribute5                    => p_acct_alloc_rec.attribute5,
      p_attribute6                    => p_acct_alloc_rec.attribute6,
      p_attribute7                    => p_acct_alloc_rec.attribute7,
      p_attribute8                    => p_acct_alloc_rec.attribute8,
      p_attribute9                    => p_acct_alloc_rec.attribute9,
      p_attribute10                   => p_acct_alloc_rec.attribute10,
      p_attribute11                   => p_acct_alloc_rec.attribute11,
      p_attribute12                   => p_acct_alloc_rec.attribute12,
      p_attribute13                   => p_acct_alloc_rec.attribute13,
      p_attribute14                   => p_acct_alloc_rec.attribute14,
      p_attribute15                   => p_acct_alloc_rec.attribute15,
      px_org_id                       => l_org_id
    );

   <<unalloc_time_loop>>
   FOR l_idx IN l_period_tbl.first..l_period_tbl.last
   LOOP
    IF l_period_tbl.exists(l_idx) THEN

       p_prod_alloc_rec := NULL;

       p_time_alloc_rec.allocation_for := 'CUST';
       p_time_alloc_rec.allocation_for_id := l_account_allocation_id;
       p_time_alloc_rec.time_id := l_period_tbl(l_idx);
       p_time_alloc_rec.period_type_id := l_period_type_id;
       p_time_alloc_rec.target := ROUND( (NVL(l_time_target_unalloc, 0)), 0);
       p_time_alloc_rec.lysp_sales := 0;

       l_time_allocation_id := get_time_allocation_id;

       Ozf_Time_Allocations_Pkg.Insert_Row(
          px_time_allocation_id  => l_time_allocation_id,
          p_allocation_for  => p_time_alloc_rec.allocation_for,
          p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
          p_time_id  => p_time_alloc_rec.time_id,
          p_period_type_id => p_time_alloc_rec.period_type_id,
          p_target  => p_time_alloc_rec.target,
          p_lysp_sales  => p_time_alloc_rec.lysp_sales,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_attribute_category  => p_time_alloc_rec.attribute_category,
          p_attribute1  => p_time_alloc_rec.attribute1,
          p_attribute2  => p_time_alloc_rec.attribute2,
          p_attribute3  => p_time_alloc_rec.attribute3,
          p_attribute4  => p_time_alloc_rec.attribute4,
          p_attribute5  => p_time_alloc_rec.attribute5,
          p_attribute6  => p_time_alloc_rec.attribute6,
          p_attribute7  => p_time_alloc_rec.attribute7,
          p_attribute8  => p_time_alloc_rec.attribute8,
          p_attribute9  => p_time_alloc_rec.attribute9,
          p_attribute10  => p_time_alloc_rec.attribute10,
          p_attribute11  => p_time_alloc_rec.attribute11,
          p_attribute12  => p_time_alloc_rec.attribute12,
          p_attribute13  => p_time_alloc_rec.attribute13,
          p_attribute14  => p_time_alloc_rec.attribute14,
          p_attribute15  => p_time_alloc_rec.attribute15,
          px_org_id  => l_org_id
        );


     END IF;
   END LOOP unalloc_time_loop;

-------BEGIN: FIX for difference due to ROUNDING in Unallocated Rows only ------------------------|

   IF (MOD(l_total_target_unalloc, l_denominator) <> 0) THEN

         l_diff_target := 0;

         BEGIN

              SELECT a.TARGET INTO l_diff_target_1
              FROM OZF_ACCOUNT_ALLOCATIONS a
               WHERE a.allocation_for = 'FUND'
                 AND a.allocation_for_id = l_fund_id
                 AND a.parent_party_id = -9999;

              SELECT SUM(t.TARGET) INTO l_diff_target_2
              FROM OZF_TIME_ALLOCATIONS t
              WHERE  t.allocation_for = 'CUST'
                 AND t.allocation_for_id IN ( SELECT a.account_allocation_id
                                              FROM  OZF_ACCOUNT_ALLOCATIONS a
                                              WHERE a.allocation_for = 'FUND'
                                                AND a.allocation_for_id = l_fund_id
                                                AND a.parent_party_id = -9999 );

             l_diff_target := NVL(l_diff_target_1, 0) - NVL(l_diff_target_2, 0);

-- OZF_UTILITY_PVT.debug_message('mkothari --- UNALLOCATED l_diff_target => '||l_diff_target || ' ; ');

         EXCEPTION
            WHEN OTHERS THEN
                 l_diff_target := 0;
         END;


         IF ABS(l_diff_target) >= 1 THEN

            IF SIGN(l_diff_target) = -1 THEN
               l_diff_target := CEIL(l_diff_target); -- (So, -1.5 will become -1 )
            ELSE
               l_diff_target := FLOOR(l_diff_target); -- (So, +1.5 will become +1)
            END IF;

            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id) from OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'CUST'
                                            AND x.allocation_for_id IN ( SELECT a.account_allocation_id
                                                                         FROM  OZF_ACCOUNT_ALLOCATIONS a
                                                                         WHERE a.allocation_for = 'FUND'
                                                                           AND a.allocation_for_id = l_fund_id
                                                                           AND a.parent_party_id = -9999 )
                                           );

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_ROUNDING_TIME_ERR');
                    fnd_message.set_token('OZF_TP_OBJECT_TYPE_TOKEN','UNALLOCATED FUND');
                    fnd_message.set_token('OZF_TP_OBJECT_ID_TOKEN',l_fund_id);
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

         END IF;
   END IF;

-------END: FIX for difference due to ROUNDING --------------------------------------------------|

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': End - Populating UNALLOCATED Allocations Records'
                                         || 'FOR FUND_Id = '|| l_fund_id || ' ; ');





-------BEGIN: FIX for difference due to ROUNDING for ALL Targets taken together -------------------|


   l_diff_target   := 0;
   l_diff_target_1 := 0;

   BEGIN

        SELECT SUM(a.TARGET) INTO l_diff_target_1
        FROM OZF_ACCOUNT_ALLOCATIONS a
        WHERE a.allocation_for = 'FUND'
          AND a.allocation_for_id = l_fund_id;

        l_diff_target := (NVL(l_total_root_quota, 0) - NVL(l_diff_target_1, 0));

 -- OZF_UTILITY_PVT.debug_message('mkothari-- ALL TARGETS l_diff_target => '||l_diff_target || ' ; ');

   EXCEPTION
      WHEN OTHERS THEN
           l_diff_target := 0;
   END;

/*
         IF l_diff_target > 0 THEN

            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id) from OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'CUST'
                                            AND x.allocation_for_id IN ( SELECT a.account_allocation_id
                                                                         FROM  OZF_ACCOUNT_ALLOCATIONS a
                                                                         WHERE a.allocation_for = 'FUND'
                                                                           AND a.allocation_for_id = l_fund_id
                                                                           AND a.parent_party_id = -9999)
                                           );

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;


              UPDATE OZF_ACCOUNT_ALLOCATIONS a
              SET a.TARGET = a.TARGET + l_diff_target,
                  a.object_version_number = a.object_version_number + 1,
                  a.last_update_date = SYSDATE,
                  a.last_updated_by = FND_GLOBAL.USER_ID,
                  a.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE a.allocation_for = 'FUND'
                AND a.allocation_for_id = l_fund_id
                AND a.parent_party_id = -9999;

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;

                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;
*/


   ----Fixing for Account Targets -----------------------
   IF ABS(l_diff_target) >= 1 THEN

            IF SIGN(l_diff_target) = -1 THEN
               l_diff_target := CEIL(l_diff_target); -- (So, -1.5 will become -1 )
            ELSE
               l_diff_target := FLOOR(l_diff_target); -- (So, +1.5 will become +1)
            END IF;

-- OZF_UTILITY_PVT.debug_message('222. mkothari-- ALL TARGETS l_diff_target => '||l_diff_target || ' ; ');

            l_temp_account_allocation_id := 0;

            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT MAX(x.time_allocation_id)
                                            FROM OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'CUST'
                                            AND x.allocation_for_id IN ( SELECT MAX(a.account_allocation_id)
                                                                         FROM  OZF_ACCOUNT_ALLOCATIONS a
                                                                         WHERE a.allocation_for = 'FUND'
                                                                           AND a.allocation_for_id = l_fund_id
                                                                           AND a.target = (SELECT MAX(xyz.target)
                                                                                            FROM  OZF_ACCOUNT_ALLOCATIONS xyz
                                                                                            WHERE xyz.allocation_for = 'FUND'
                                                                                              AND xyz.allocation_for_id = l_fund_id)
                                                                        )
                                            AND x.target = (SELECT MAX(xyz2.target)
                                                            FROM  OZF_TIME_ALLOCATIONS xyz2
                                                            WHERE xyz2.allocation_for = 'CUST'
                                                              AND xyz2.allocation_for_id IN
                                                                                    ( SELECT MAX(ax.account_allocation_id)
                                                                                      FROM  OZF_ACCOUNT_ALLOCATIONS ax
                                                                                      WHERE ax.allocation_for = 'FUND'
                                                                                        AND ax.allocation_for_id = l_fund_id
                                                                                        AND ax.target =
                                                                                            (SELECT MAX(yz.target)
                                                                                             FROM  OZF_ACCOUNT_ALLOCATIONS yz
                                                                                             WHERE yz.allocation_for = 'FUND'
                                                                                               AND yz.allocation_for_id = l_fund_id)
                                                                                    )
                                                           )
                                           )
              RETURNING t.allocation_for_id INTO l_temp_account_allocation_id;

             IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_ROUNDING_TIME_ERR');
                    fnd_message.set_token('OZF_TP_OBJECT_TYPE_TOKEN','QUOTA');
                    fnd_message.set_token('OZF_TP_OBJECT_ID_TOKEN',l_fund_id);
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
             END IF;


             -- OZF_UTILITY_PVT.debug_message('4.mkothari--'||'ALL TARGETS AccAllocID=> '||l_temp_account_allocation_id|| ';');

              UPDATE OZF_ACCOUNT_ALLOCATIONS a
              SET a.TARGET = a.TARGET + l_diff_target,
                  a.object_version_number = a.object_version_number + 1,
                  a.last_update_date = SYSDATE,
                  a.last_updated_by = FND_GLOBAL.USER_ID,
                  a.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE a.account_allocation_id = l_temp_account_allocation_id;

             IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_ROUNDING_ACCT_ERR');
                    fnd_message.set_token('OZF_TP_OBJECT_TYPE_TOKEN', 'ACCOUNT ALLOCATION');
                    fnd_message.set_token('OZF_TP_OBJECT_ID_TOKEN', l_temp_account_allocation_id);
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
             END IF;



     -------Now fix the corresponding Product Spread for Rounding Adjustment.--------------------

      fix_product_rounding_err('CUST', l_temp_account_allocation_id, l_diff_target);


/*
            l_temp_product_allocation_id := 0;

            UPDATE OZF_TIME_ALLOCATIONS t
                SET t.TARGET = t.TARGET + l_diff_target,
                    t.object_version_number = t.object_version_number + 1,
                    t.last_update_date = SYSDATE,
                    t.last_updated_by = FND_GLOBAL.USER_ID,
                    t.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE t.time_allocation_id = (SELECT max(x.time_allocation_id)
                                            FROM OZF_TIME_ALLOCATIONS x
                                            WHERE  x.allocation_for = 'PROD'
                                            AND x.allocation_for_id IN ( SELECT max(p.product_allocation_id)
                                                                         FROM  OZF_PRODUCT_ALLOCATIONS p
                                                                         WHERE p.allocation_for = 'CUST'
                                                                           AND p.allocation_for_id = l_temp_account_allocation_id
                                                                           AND p.target =
                                                                              (SELECT max(xz.target)
                                                                               FROM OZF_PRODUCT_ALLOCATIONS xz
                                                                               WHERE xz.allocation_for = 'CUST'
                                                                               AND xz.allocation_for_id = l_temp_account_allocation_id
                                                                               )

                                                                         )
                                           AND x.target =
                                               (SELECT max(zx.target)
                                                FROM OZF_TIME_ALLOCATIONS zx
                                                WHERE  zx.allocation_for = 'PROD'
                                                AND zx.allocation_for_id IN (SELECT max(pz.product_allocation_id)
                                                                             FROM  OZF_PRODUCT_ALLOCATIONS pz
                                                                             WHERE pz.allocation_for = 'CUST'
                                                                               AND pz.allocation_for_id = l_temp_account_allocation_id
                                                                               AND pz.target =
                                                                                (SELECT max(xz.target)
                                                                                 FROM OZF_PRODUCT_ALLOCATIONS xz
                                                                                WHERE xz.allocation_for = 'CUST'
                                                                                AND xz.allocation_for_id = l_temp_account_allocation_id
                                                                                )

                                                                             )
                                               )
                                           )
              RETURNING t.allocation_for_id INTO l_temp_product_allocation_id;


              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_TIMEALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

         UPDATE OZF_PRODUCT_ALLOCATIONS p
                SET p.TARGET = p.TARGET + l_diff_target,
                    p.object_version_number = p.object_version_number + 1,
                    p.last_update_date = SYSDATE,
                    p.last_updated_by = FND_GLOBAL.USER_ID,
                    p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
              WHERE p.product_allocation_id = l_temp_product_allocation_id;

              IF (SQL%NOTFOUND) THEN
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name ('OZF', 'OZF_TP_PRODALLOC_NOT_FOUND_TXT');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

*/


   END IF; -- end of "IF l_diff_target <> 0 THEN"


-------END: FIX for difference due to ROUNDING for ALL Targets taken together--------------------|

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN OZF_TP_INVALID_PARAM THEN
          ROLLBACK TO allocate_target_first_time;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_INVALID_PARAM_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : INVALID PARAMETER EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO allocate_target_first_time;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO allocate_target_first_time;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO allocate_target_first_time;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END allocate_target_first_time;


-- ------------------------
-- ------------------------
-- Private Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: ALLOCATE TARGET ADDON
-- Desc: 1. When activating an ADD-ON Fact_id, call this API for each
--          Fact_id/Fund_id combination. Target Allocation records
--          are to be created for the newly added period which is
--          calculated by :
--          (time-ids from old-start-date to new-end-date) minus (pre-exisiting-time_ids)
--          Note : 1. Period_type_ids has to be the same.
--             2. The new-start-date can be anyDate greater then old-start-date
--                 3. The new end-date can be any date greater then old-end-date.
--
--   R E M E M B E R to chnage this one too for May17-18, 2004 Chnages
--
-- -----------------------------------------------------------------
PROCEDURE allocate_target_addon
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id            IN          NUMBER,
    p_old_start_date     IN          DATE,
    p_new_end_date       IN          DATE,
    p_addon_fact_id      IN          NUMBER,
    p_addon_amount       IN          NUMBER
) IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'allocate_target_addon';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_fund_id                NUMBER;
   l_old_start_date         DATE;
   l_new_end_date           DATE;
   l_addon_fact_id          NUMBER;
   l_addon_amount           NUMBER;

   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER;-- := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));     --Bugfix7540057

   l_start_date             VARCHAR2(30) := null;
   l_end_date               VARCHAR2(30) := null;

   l_period_type_id         NUMBER;
   l_lysp_in_clause         VARCHAR2(1000) := null;
   l_in_clause              VARCHAR2(1000) := null;
   l_territory_id           NUMBER;
   l_resource_id            NUMBER;
   l_index                  NUMBER := 0;

   l_total_lysp_sales       NUMBER;

   l_total_account_sales    NUMBER;
   l_account_sales          NUMBER;
   l_total_account_target   NUMBER;
   l_account_target         NUMBER;

   l_total_product_sales    NUMBER;
   l_product_sales          NUMBER;
   l_total_product_target   NUMBER;
   l_product_target         NUMBER;

   l_total_root_quota       NUMBER;
   l_total_fund_quota       NUMBER;
   l_time_fund_target       NUMBER;

   l_multiplying_factor     NUMBER;
   l_prod_mltply_factor     NUMBER;

   l_account_allocation_id  NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;

   l_denominator            NUMBER;
   l_total_target_unalloc   NUMBER;
   l_time_target_unalloc    NUMBER;
   l_fund_product_rec_exists BOOLEAN;

   l_period_tbl          OZF_TIME_API_PVT.G_period_tbl_type;
   l_new_period_tbl      OZF_TIME_API_PVT.G_period_tbl_type;
   l_lysp_period_tbl     OZF_TIME_API_PVT.G_period_tbl_type;

   l_new_ozf_period_tbl  OZF_PERIOD_TBL_TYPE;
   l_old_ozf_period_tbl  OZF_PERIOD_TBL_TYPE;

   p_acct_alloc_rec      ozf_account_allocations%ROWTYPE;
   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;



  CURSOR fund_csr (l_fund_id  NUMBER)
  IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
   FROM
    ozf_funds_all_vl
   WHERE
    fund_id = l_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;

  CURSOR territory_csr (l_resource_id NUMBER) IS
   SELECT
    j.terr_id territory_id
   FROM
    jtf_terr_rsc_all j, jtf_terr_rsc_access_all j2
   WHERE
       j.resource_id = l_resource_id
  -- AND j.primary_contact_flag = 'Y' ;
   AND j2.terr_rsc_id = j.terr_rsc_id
   AND j2.access_type = 'OFFER'
   AND j2.trans_access_code = 'PRIMARY_CONTACT';

  CURSOR total_lysp_sales_csr (l_fund_id       NUMBER,
                               l_in_clause     VARCHAR2)
   IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ozf_account_allocations a
   WHERE
        a.allocation_for = 'FUND'
    AND a.allocation_for_id = l_fund_id
    AND bsmv.ship_to_site_use_id = a.site_use_id
    AND bsmv.time_id IN (l_in_clause);


  CURSOR account_csr
        (l_fund_id    number)
  IS
  SELECT
    a.account_allocation_id account_allocation_id,
    a.cust_account_id       cust_account_id,
    a.site_use_id           site_use_id,
    a.site_use_code         site_use_code,
    a.location_id           location_id,
    a.bill_to_site_use_id   bill_to_site_use_id,
    a.bill_to_location_id   bill_to_location_id,
    a.parent_party_id       parent_party_id,
    a.rollup_party_id       rollup_party_id
  FROM
    ozf_account_allocations a
  WHERE
        a.allocation_for = 'FUND'
    AND a.allocation_for_id = l_fund_id;


  CURSOR account_total_sales_csr
         (l_site_use_id         number,
          l_in_clause           varchar2)
  IS
  SELECT
      SUM(bsmv.sales) account_sales
  FROM
      ozf_order_sales_v bsmv
  WHERE
      bsmv.ship_to_site_use_id = l_site_use_id
  AND bsmv.time_id IN (l_in_clause);


  CURSOR account_sales_csr
         (l_site_use_id         number,
          l_time_id             number)
  IS
  SELECT
      SUM(bsmv.sales) account_sales
  FROM
      ozf_order_sales_v bsmv
  WHERE
      bsmv.ship_to_site_use_id = l_site_use_id
  AND bsmv.time_id = l_time_id;


/*
  CURSOR get_total_target_csr
        (l_fund_id   NUMBER,
     l_in_clause VARCHAR2) IS
   SELECT SUM(t.target)
   FROM
       ozf_time_allocations t,
       ozf_product_allocations p
   WHERE
       p.fund_id = l_fund_id
   AND t.allocation_for_id   = p.product_allocation_id
   AND t.allocation_for      = 'PROD'
   AND t.time_id IN (l_in_clause);
*/

  l_get_total_target_sql VARCHAR2(30000) :=
   ' SELECT SUM(t.target) '||
   ' FROM '||
   '     ozf_time_allocations t,'||
   '     ozf_product_allocations p'||
   ' WHERE'||
   '     p.fund_id = :l_fund_id'||
   ' AND t.allocation_for_id   = p.product_allocation_id'||
   ' AND t.allocation_for      = ''PROD'' '||
   ' AND t.time_id IN (';
--l_in_clause);

  get_total_target_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable)

  CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                                 l_territory_id  NUMBER,
                                 l_site_use_id   NUMBER,
                                 l_time_id       NUMBER) IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ams_party_market_segments a
   WHERE
        a.market_qualifier_reference = l_territory_id
    AND a.market_qualifier_type='TERRITORY'
    AND a.site_use_id = l_site_use_id
    AND bsmv.ship_to_site_use_id = a.site_use_id
    AND bsmv.inventory_item_id = l_product_id
    AND bsmv.time_id = l_time_id;


  CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                  l_territory_id   NUMBER,
                                  l_site_use_id    NUMBER,
                                  l_time_id        NUMBER,
                                  l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND bsmv.inventory_item_id IN
                             ( SELECT  mtl.inventory_item_id
                               FROM    mtl_item_categories mtl
                               WHERE   mtl.category_id = l_category_id
                               MINUS
                               SELECT p.item_id
                               FROM   ozf_product_allocations p
                               WHERE  p.fund_id = l_fund_id
                                  AND p.item_type = 'PRICING_ATTRIBUTE1'
                             );


  CURSOR others_lysp_sales_csr (l_territory_id   NUMBER,
                                l_site_use_id    NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND NOT EXISTS
  (
  ( SELECT p.item_id
    FROM ozf_product_allocations p
    WHERE
        p.fund_id = l_fund_id
    AND p.item_type = 'PRICING_ATTRIBUTE1'
    AND p.item_id = bsmv.inventory_item_id
    UNION ALL
    SELECT mtl.inventory_item_id
    FROM ozf_product_allocations p,
         mtl_item_categories mtl
    WHERE
      p.fund_id = l_fund_id
  AND p.item_type = 'PRICING_ATTRIBUTE2'
  AND p.item_id = mtl.category_id
  AND mtl.inventory_item_id = bsmv.inventory_item_id
  )
  MINUS
  SELECT prod.inventory_item_id
  FROM ams_act_products prod
  where
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'Y'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  );

  CURSOR account_product_spread_csr
       (l_account_allocation_id        number) IS
    SELECT
       p.product_allocation_id,
       p.item_id,
       p.item_type,
       p.target
    FROM
       ozf_product_allocations p
    WHERE
         p.allocation_for = 'CUST'
     AND p.allocation_for_id = l_account_allocation_id;

   l_account_product_rec     account_product_spread_csr%rowtype;

   CURSOR account_time_spread_csr
         (l_product_allocation_id       number,
          l_time_id                     number) IS
   SELECT t.target
   FROM
       ozf_time_allocations t
   WHERE
       t.allocation_for_id = l_product_allocation_id
   AND t.allocation_for = 'PROD'
   AND t.time_id = l_time_id;

  CURSOR fund_product_spread_csr
         (l_fund_id        number,
          l_addon_fact_id  number,
          l_item_id        number,
          l_item_type      varchar2) IS
    SELECT
       p.product_allocation_id,
       p.target
    FROM
       ozf_product_allocations p
    WHERE
        p.fund_id = l_fund_id
    AND p.allocation_for = 'FACT'
    AND p.allocation_for_id = l_addon_fact_id
    AND p.item_id = l_item_id
    AND p.item_type = l_item_type;

   l_fund_product_rec     fund_product_spread_csr%rowtype;

   CURSOR fund_time_spread_csr
         (l_product_allocation_id       number,
          l_time_id                     number) IS
   SELECT t.target
   FROM
       ozf_time_allocations t
   WHERE
       t.allocation_for_id = l_product_allocation_id
   AND t.allocation_for = 'PROD'
   AND t.time_id = l_time_id;

   CURSOR get_old_period_csr
          (l_fund_id   NUMBER) IS
      SELECT DISTINCT t.time_id
      FROM
          ozf_time_allocations t,
          ozf_account_allocations a
      WHERE
          a.allocation_for = 'FUND'
      AND a.allocation_for_id = l_fund_id
      AND t.allocation_for_id = a.account_allocation_id
      AND t.allocation_for    = 'CUST';


 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT allocate_target_addon;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- start');

   l_fund_id          := p_fund_id;
   l_old_start_date   := p_old_start_date;
   l_new_end_date     := p_new_end_date;
   l_addon_fact_id    := p_addon_fact_id;
   l_addon_amount     := p_addon_amount;

   OPEN fund_csr(l_fund_id);
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   l_resource_id := l_fund_rec.owner;
   l_territory_id := l_fund_rec.node_id;

   IF l_territory_id IS NULL THEN
      OPEN territory_csr(l_resource_id);
      FETCH territory_csr INTO l_territory_id;
      CLOSE territory_csr ;
   END IF;

   l_org_id := get_org_id(l_territory_id);    --Bugfix 7540057

   l_start_date := to_char(l_old_start_date, 'YYYY/MM/DD');
   l_end_date   := to_char(l_new_end_date, 'YYYY/MM/DD');
   l_period_type_id := 32; -- l_fund_rec.period_type_id;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                         ': Begin - Getting ADDON Time_ids Between '
                        ||l_start_date||' AND '||l_end_date||' ; ');

   l_new_period_tbl := OZF_TIME_API_PVT.get_period_tbl
                                    (l_start_date,
                                     l_end_date,
                                     l_period_type_id);
   FOR i IN l_new_period_tbl.FIRST..l_new_period_tbl.LAST
   LOOP
      l_new_ozf_period_tbl.EXTEND;
      l_new_ozf_period_tbl(i) :=  l_new_period_tbl(i);
   END LOOP;

   l_index := 1;
   FOR old_period_rec in get_old_period_csr(l_fund_id)
   LOOP
      l_old_ozf_period_tbl.EXTEND;
      l_old_ozf_period_tbl(l_index) := old_period_rec.time_id;
      l_index := l_index + 1;
   END LOOP;

   BEGIN
     SELECT * BULK COLLECT INTO l_period_tbl
     FROM
         ( SELECT * FROM TABLE(CAST(l_new_ozf_period_tbl as OZF_PERIOD_TBL_TYPE))
           MINUS
           SELECT * FROM TABLE(CAST(l_old_ozf_period_tbl as OZF_PERIOD_TBL_TYPE))
          );
     EXCEPTION
        WHEN OTHERS THEN
             ROLLBACK TO allocate_target_addon;
             x_return_status := FND_API.g_ret_sts_unexp_error ;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
             END IF;
             FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                        p_data  => x_error_message);
             OZF_UTILITY_PVT.debug_message(l_full_api_name||' : COLLECTION UNNESTING: OTHERS EXCEPTION = '||sqlerrm(sqlcode));

             IF l_period_tbl IS NULL OR l_period_tbl.COUNT <= 0 THEN
                RAISE OZF_TP_BLANK_PERIOD_TBL;
             END IF;
   END;


   IF l_period_tbl IS NULL OR l_period_tbl.COUNT <= 0 THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                         ': End - Getting ADDON Time_ids Between '
                        ||l_start_date||' AND '||l_end_date||' ; ');


   IF l_period_tbl IS NOT NULL THEN
    IF l_period_tbl.COUNT > 0 THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
        IF l_period_tbl.exists(l_idx) THEN

         l_lysp_period_tbl(l_idx) := OZF_TIME_API_PVT.get_lysp_id (l_period_tbl(l_idx), l_period_type_id);

         OZF_UTILITY_PVT.debug_message(SubStr('l_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_period_tbl(l_idx)), 1,255));
        END IF;
      END LOOP;
    END IF;
   END IF;

   --l_in_clause := '(';
   l_in_clause := NULL;
   IF l_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
          IF l_in_clause IS NULL THEN
             l_in_clause := LTRIM(' '||l_period_tbl(l_idx));
          ELSE
             l_in_clause := l_in_clause ||','|| l_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_in_clause := l_in_clause||')';

   l_lysp_in_clause := NULL;
   IF l_lysp_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_lysp_period_tbl.first..l_lysp_period_tbl.last
      LOOP
          IF l_lysp_in_clause IS NULL THEN
             l_lysp_in_clause := LTRIM(' '||l_lysp_period_tbl(l_idx));
          ELSE
             l_lysp_in_clause := l_lysp_in_clause ||','|| l_lysp_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_lysp_in_clause := l_lysp_in_clause||')';


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': Time_ids between '||l_start_date
                                         ||' AND '||l_end_date||' ARE : '||l_in_clause||' ; ');
   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ': LYSP-Time_ids between '||l_start_date
                                         ||' AND '||l_end_date||' ARE : '||l_lysp_in_clause||' ; ');

   OPEN total_lysp_sales_csr(l_fund_id,l_lysp_in_clause);
   FETCH total_lysp_sales_csr INTO l_total_lysp_sales;
   CLOSE total_lysp_sales_csr;

   l_total_root_quota := l_addon_amount;

   l_total_target_unalloc := 0;
   l_time_target_unalloc := 0;
   l_multiplying_factor := 0;

   IF l_total_lysp_sales > 0 THEN
      l_multiplying_factor := l_total_root_quota / l_total_lysp_sales;
   ELSE
      l_multiplying_factor := 0;
      l_denominator := l_period_tbl.COUNT;

      l_total_target_unalloc := ROUND(l_total_root_quota, 0);
      l_time_target_unalloc := ROUND ((l_total_root_quota / l_denominator), 0);
   END IF;

------ for product allocations: based upon Funds product spread ------------------
   l_get_total_target_sql := l_get_total_target_sql||l_in_clause ||')';

   OPEN get_total_target_csr FOR l_get_total_target_sql USING l_fund_id;
   FETCH get_total_target_csr INTO l_total_fund_quota;
   CLOSE get_total_target_csr ;


------- Insert rows for ACCOUNT-TIME Allocations and Update rows for Account Allocations ---------

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                         ': Begin - Updating Account and Populating Time Allocations Records'
                         || 'FOR Fund_id = '|| l_fund_id || ' ; ');
   <<account_loop>>
   FOR account_rec IN account_csr(l_fund_id)
   LOOP

       l_account_allocation_id := account_rec.account_allocation_id;

       OPEN account_total_sales_csr (account_rec.site_use_id, l_lysp_in_clause);
       FETCH account_total_sales_csr into l_total_account_sales;
       CLOSE account_total_sales_csr;

       l_total_account_sales := NVL(l_total_account_sales, 0);
       l_total_account_target := ROUND( (l_total_account_sales * l_multiplying_factor), 0);

       UPDATE ozf_account_allocations a
       SET a.target = a.target + l_total_account_target,
           a.lysp_sales = a.lysp_sales + l_total_account_sales,
           a.object_version_number = a.object_version_number + 1,
           a.last_update_date = SYSDATE,
           a.last_updated_by = FND_GLOBAL.USER_ID,
           a.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
       WHERE a.account_allocation_id = l_account_allocation_id;

       <<account_time_loop>>
       FOR l_idx IN l_period_tbl.first..l_period_tbl.last
       LOOP
        IF l_period_tbl.exists(l_idx) THEN

           p_time_alloc_rec := NULL;
           l_account_sales := 0;

           OPEN account_sales_csr (account_rec.site_use_id, l_lysp_period_tbl(l_idx));
           FETCH account_sales_csr into l_account_sales;
           CLOSE account_sales_csr;

           l_account_target := ROUND( (l_account_sales * l_multiplying_factor), 0);

           p_time_alloc_rec.allocation_for := 'CUST';
           p_time_alloc_rec.allocation_for_id := l_account_allocation_id;
           p_time_alloc_rec.time_id := l_period_tbl(l_idx);
           p_time_alloc_rec.period_type_id := l_period_type_id;
           p_time_alloc_rec.target := NVL(l_account_target, 0);
           p_time_alloc_rec.lysp_sales := NVL(l_account_sales, 0);

           l_time_allocation_id := get_time_allocation_id;

           Ozf_Time_Allocations_Pkg.Insert_Row(
              px_time_allocation_id  => l_time_allocation_id,
              p_allocation_for  => p_time_alloc_rec.allocation_for,
              p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
              p_time_id  => p_time_alloc_rec.time_id,
              p_period_type_id => p_time_alloc_rec.period_type_id,
              p_target  => p_time_alloc_rec.target,
              p_lysp_sales  => p_time_alloc_rec.lysp_sales,
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_time_alloc_rec.attribute_category,
              p_attribute1  => p_time_alloc_rec.attribute1,
              p_attribute2  => p_time_alloc_rec.attribute2,
              p_attribute3  => p_time_alloc_rec.attribute3,
              p_attribute4  => p_time_alloc_rec.attribute4,
              p_attribute5  => p_time_alloc_rec.attribute5,
              p_attribute6  => p_time_alloc_rec.attribute6,
              p_attribute7  => p_time_alloc_rec.attribute7,
              p_attribute8  => p_time_alloc_rec.attribute8,
              p_attribute9  => p_time_alloc_rec.attribute9,
              p_attribute10  => p_time_alloc_rec.attribute10,
              p_attribute11  => p_time_alloc_rec.attribute11,
              p_attribute12  => p_time_alloc_rec.attribute12,
              p_attribute13  => p_time_alloc_rec.attribute13,
              p_attribute14  => p_time_alloc_rec.attribute14,
              p_attribute15  => p_time_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );


         END IF;
       END LOOP account_time_loop;


------- Insert rows for Product-Time Allocations and Update rows for Account Allocations ---------


       OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                             ': Begin - Updating Product and Populating Time Allocations Records'
                             || 'FOR site_use_id = '|| account_rec.site_use_id || ' ; ');


       IF l_total_fund_quota > 0 THEN
          l_prod_mltply_factor := l_total_account_target / l_total_fund_quota;
       ELSE
          l_prod_mltply_factor := 0;
       END IF;

       <<account_product_loop>>
       FOR account_product_rec IN account_product_spread_csr(l_account_allocation_id)
       LOOP

           l_product_allocation_id := account_product_rec.product_allocation_id;

           OPEN fund_product_spread_csr(l_fund_id,
                                        l_addon_fact_id,
                                        account_product_rec.item_id,
                                        account_product_rec.item_type);
           FETCH fund_product_spread_csr INTO l_fund_product_rec;
           IF fund_product_spread_csr%FOUND THEN
              l_fund_product_rec_exists := TRUE;
           END IF;
           CLOSE fund_product_spread_csr;

           l_total_product_target := 0;
           l_total_product_sales := 0;

           <<account_product_time_loop>>
           FOR l_idx IN l_period_tbl.first..l_period_tbl.last
           LOOP
            IF l_period_tbl.exists(l_idx) THEN

               p_time_alloc_rec := NULL;

               l_time_fund_target := 0;
               IF l_fund_product_rec_exists = TRUE THEN
                  OPEN fund_time_spread_csr(l_fund_product_rec.product_allocation_id, l_period_tbl(l_idx));
                  FETCH fund_time_spread_csr INTO l_time_fund_target;
                  CLOSE fund_time_spread_csr ;
               END IF;

               l_product_target := ROUND( (l_time_fund_target * l_prod_mltply_factor), 0);
               l_total_product_target := l_total_product_target + l_product_target;

               l_product_sales := 0;

               IF account_product_rec.item_type = 'PRODUCT' THEN
                  OPEN product_lysp_sales_csr(account_product_rec.item_id,
                                              l_territory_id,
                                              account_rec.site_use_id,
                                              l_lysp_period_tbl(l_idx)
                                             );
                  FETCH product_lysp_sales_csr INTO l_product_sales;
                  CLOSE product_lysp_sales_csr;
               ELSIF account_product_rec.item_type = 'PRICING_ATTRIBUTE2' THEN
                   OPEN category_lysp_sales_csr(account_product_rec.item_id,
                                                l_territory_id,
                                                account_rec.site_use_id,
                                                l_lysp_period_tbl(l_idx),
                                                l_fund_id
                                               );
                   FETCH category_lysp_sales_csr INTO l_product_sales;
                   CLOSE category_lysp_sales_csr;
               ELSIF account_product_rec.item_type = 'OTHERS' THEN
                   OPEN others_lysp_sales_csr(l_territory_id,
                                              account_rec.site_use_id,
                                              l_lysp_period_tbl(l_idx),
                                              l_fund_id
                                             );
                   FETCH others_lysp_sales_csr INTO l_product_sales;
                   CLOSE others_lysp_sales_csr;
               END IF;

               l_total_product_sales := l_total_product_sales + l_product_sales;

               p_time_alloc_rec.allocation_for := 'PROD';
               p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
               p_time_alloc_rec.time_id := l_period_tbl(l_idx);
               p_time_alloc_rec.period_type_id := l_period_type_id;
               p_time_alloc_rec.target := NVL(l_product_target, 0);
               p_time_alloc_rec.lysp_sales := NVL(l_product_sales, 0);

               l_time_allocation_id := get_time_allocation_id;

               Ozf_Time_Allocations_Pkg.Insert_Row(
                  px_time_allocation_id  => l_time_allocation_id,
                  p_allocation_for  => p_time_alloc_rec.allocation_for,
                  p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
                  p_time_id  => p_time_alloc_rec.time_id,
                  p_period_type_id => p_time_alloc_rec.period_type_id,
                  p_target  => p_time_alloc_rec.target,
                  p_lysp_sales  => p_time_alloc_rec.lysp_sales,
                  px_object_version_number  => l_object_version_number,
                  p_creation_date  => SYSDATE,
                  p_created_by  => FND_GLOBAL.USER_ID,
                  p_last_update_date  => SYSDATE,
                  p_last_updated_by  => FND_GLOBAL.USER_ID,
                  p_last_update_login  => FND_GLOBAL.conc_login_id,
                  p_attribute_category  => p_time_alloc_rec.attribute_category,
                  p_attribute1  => p_time_alloc_rec.attribute1,
                  p_attribute2  => p_time_alloc_rec.attribute2,
                  p_attribute3  => p_time_alloc_rec.attribute3,
                  p_attribute4  => p_time_alloc_rec.attribute4,
                  p_attribute5  => p_time_alloc_rec.attribute5,
                  p_attribute6  => p_time_alloc_rec.attribute6,
                  p_attribute7  => p_time_alloc_rec.attribute7,
                  p_attribute8  => p_time_alloc_rec.attribute8,
                  p_attribute9  => p_time_alloc_rec.attribute9,
                  p_attribute10  => p_time_alloc_rec.attribute10,
                  p_attribute11  => p_time_alloc_rec.attribute11,
                  p_attribute12  => p_time_alloc_rec.attribute12,
                  p_attribute13  => p_time_alloc_rec.attribute13,
                  p_attribute14  => p_time_alloc_rec.attribute14,
                  p_attribute15  => p_time_alloc_rec.attribute15,
                  px_org_id  => l_org_id
                );


             END IF;
           END LOOP account_product_time_loop;

           UPDATE OZF_PRODUCT_ALLOCATIONS p
           SET p.lysp_sales = p.lysp_sales + l_total_product_sales,
               p.target = p.target + l_total_product_target,
               p.object_version_number = p.object_version_number + 1,
               p.last_update_date = SYSDATE,
               p.last_updated_by = FND_GLOBAL.USER_ID,
               p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
           WHERE p.product_allocation_id = l_product_allocation_id;

       END LOOP account_product_loop;



       OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                             ': End - Updating Product and Populating Time Allocations Records'
                             || 'FOR site_use_id = '|| account_rec.site_use_id || ' ; ');


   END LOOP account_loop;


------- Insert rows for Unalloc-Time Allocations and Update rows for Unalloc Allocations ---------


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                         ': Begin - Updating UNALLOCATED Account and Populating Time Allocations Records'
                         || 'FOR FUND_Id = '|| l_fund_id || ' ; ');

   UPDATE ozf_account_allocations a
   SET a.target = a.target + l_total_target_unalloc,
       a.object_version_number = a.object_version_number + 1,
       a.last_update_date = SYSDATE,
       a.last_updated_by = FND_GLOBAL.USER_ID,
       a.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE a.allocation_for = 'FUND'
    AND a.allocation_for_id = l_fund_id
    AND a.site_use_id = -9999
   RETURNING account_allocation_id INTO l_account_allocation_id;

   <<unalloc_time_loop>>
   FOR l_idx IN l_period_tbl.first..l_period_tbl.last
   LOOP
    IF l_period_tbl.exists(l_idx) THEN

       p_time_alloc_rec := NULL;

       p_time_alloc_rec.allocation_for := 'CUST';
       p_time_alloc_rec.allocation_for_id := l_account_allocation_id;
       p_time_alloc_rec.time_id := l_period_tbl(l_idx);
       p_time_alloc_rec.period_type_id := l_period_type_id;
       p_time_alloc_rec.target := NVL(l_time_target_unalloc, 0);
       p_time_alloc_rec.lysp_sales := 0;

       l_time_allocation_id := get_time_allocation_id;

       Ozf_Time_Allocations_Pkg.Insert_Row(
          px_time_allocation_id  => l_time_allocation_id,
          p_allocation_for  => p_time_alloc_rec.allocation_for,
          p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
          p_time_id  => p_time_alloc_rec.time_id,
          p_period_type_id => p_time_alloc_rec.period_type_id,
          p_target  => p_time_alloc_rec.target,
          p_lysp_sales  => p_time_alloc_rec.lysp_sales,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_attribute_category  => p_time_alloc_rec.attribute_category,
          p_attribute1  => p_time_alloc_rec.attribute1,
          p_attribute2  => p_time_alloc_rec.attribute2,
          p_attribute3  => p_time_alloc_rec.attribute3,
          p_attribute4  => p_time_alloc_rec.attribute4,
          p_attribute5  => p_time_alloc_rec.attribute5,
          p_attribute6  => p_time_alloc_rec.attribute6,
          p_attribute7  => p_time_alloc_rec.attribute7,
          p_attribute8  => p_time_alloc_rec.attribute8,
          p_attribute9  => p_time_alloc_rec.attribute9,
          p_attribute10  => p_time_alloc_rec.attribute10,
          p_attribute11  => p_time_alloc_rec.attribute11,
          p_attribute12  => p_time_alloc_rec.attribute12,
          p_attribute13  => p_time_alloc_rec.attribute13,
          p_attribute14  => p_time_alloc_rec.attribute14,
          p_attribute15  => p_time_alloc_rec.attribute15,
          px_org_id  => l_org_id
        );


     END IF;
   END LOOP unalloc_time_loop;


   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name ||
                         ': End - Updating UNALLOCATED Account and Populating Time Allocations Records'
                         || 'FOR FUND_Id = '|| l_fund_id || ' ; ');



   OZF_UTILITY_PVT.debug_message('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN OZF_TP_INVALID_PARAM THEN
          ROLLBACK TO allocate_target_addon;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_INVALID_PARAM_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : INVALID PARAMETER EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO allocate_target_addon;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO allocate_target_addon;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO allocate_target_addon;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END allocate_target_addon;








-- ------------------------
-- Public Function
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Called from Quota Create APIs
-- Desc: This is for checking if product allocation for a particular
--       fund is already done.
--
-- -----------------------------------------------------------------

 FUNCTION GET_PROD_ALLOC_COUNT
    (p_fund_id  IN number)
  RETURN NUMBER IS

 l_count number;
 CURSOR prod_alloc_count_csr (l_fund_id NUMBER)
   IS
   select count(product_allocation_id)
   from ozf_product_allocations
   where fund_id = l_fund_id;

 BEGIN

   OPEN prod_alloc_count_csr (p_fund_id);
   FETCH prod_alloc_count_csr into l_count;
   CLOSE prod_alloc_count_csr;

   return NVL(l_count, 0);

 EXCEPTION
   WHEN OTHERS THEN
     return 0;
 END;




----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

-- ------------------------
-- Public Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: SETUP PRODUCT SPREAD
-- Desc: 1. Setup product spread for Root Node, Normal Node and Facts
--          in the Worksheet.
--       2. Update or Delete the product spread
--       3. Add-on Quota on subsequent call
-- -----------------------------------------------------------------
 PROCEDURE setup_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_mode               IN          VARCHAR2,
    p_obj_id             IN          NUMBER,
    p_context            IN          VARCHAR2
 ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'setup_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);
   l_mode                   VARCHAR2(30);
   l_obj_id                 NUMBER;
   l_context                VARCHAR2(30);

 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT setup_product_spread;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   OZF_UTILITY_PVT.debug_message('Public API: ' || l_full_api_name || ' -- start');

   l_mode := p_mode;
   l_obj_id := p_obj_id;
   l_context:= p_context;

   OZF_UTILITY_PVT.debug_message('API Parameters For:---->: ' || l_full_api_name);
   OZF_UTILITY_PVT.debug_message('1. l_mode ------------->: ' || l_mode);
   OZF_UTILITY_PVT.debug_message('2. l_Object_id--------->: ' || l_obj_id);
   OZF_UTILITY_PVT.debug_message('3. l_context----------->: ' || l_context);


   IF     l_mode IN ('CREATE', 'DELETE', 'PUBLISH', 'ADD')
      AND l_obj_id > 0
      AND l_context IN ('ROOT', 'FACT')
   THEN
     NULL;
   ELSE
     RAISE OZF_TP_INVALID_PARAM;
   END IF;


   IF l_mode = 'CREATE' AND l_context = 'ROOT' THEN

      IF (GET_PROD_ALLOC_COUNT(l_obj_id) <= 0) THEN
         create_root_product_spread
                             (p_api_version        => p_api_version,
                              x_return_status      => x_return_status,
                              x_error_number       => x_error_number,
                              x_error_message      => x_error_message,
                              p_fund_id            => l_obj_id
                             );
      END IF;

   ELSIF l_mode = 'CREATE' AND l_context = 'FACT' THEN

     create_fact_product_spread
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fact_id            => l_obj_id
                         );

   ELSIF l_mode = 'DELETE' AND l_context = 'ROOT' THEN

     delete_cascade_product_spread
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fund_id            => l_obj_id
                         );

   ELSIF l_mode = 'DELETE' AND l_context = 'FACT' THEN

     delete_fact_product_spread
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fact_id            => l_obj_id
                         );

   ELSIF l_mode = 'PUBLISH' AND l_context = 'FACT' THEN

     publish_fact_product_spread
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fact_id            => l_obj_id
                         );
   END IF;


   -- If any errors happen abort API.
   IF    x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   OZF_UTILITY_PVT.debug_message('Public API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN OZF_TP_INVALID_PARAM THEN
          ROLLBACK TO setup_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_INVALID_PARAM_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : INVALID PARAMETER EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO setup_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO setup_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO setup_product_spread;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END setup_product_spread;





----------------------------------------------------------------------------------------------------------

-- ------------------------
-- Public Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: CASCADE PRODUCT SPREAD
-- Desc: 1. Cascade product spread for Creator Node to all other Nodes
--          who are part of same hierarchy.
--       2. This will be called only when a SINGLE product is added or deleted
--          in the root product spread.
-- -----------------------------------------------------------------
PROCEDURE cascade_product_spread
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_mode               IN          VARCHAR2,
    p_fund_id            IN          NUMBER,
    p_item_id            IN          NUMBER,
    p_item_type          IN          VARCHAR2
) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'cascade_product_spread';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);
   l_mode                   VARCHAR2(30);
   l_fund_id                NUMBER;
   l_item_id                NUMBER;
   l_item_type              VARCHAR2(30);

 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT cascade_product_spread;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   OZF_UTILITY_PVT.debug_message('Public API: ' || l_full_api_name || ' -- start');

   l_mode := p_mode;
   l_fund_id := p_fund_id;
   l_item_id := p_item_id;
   l_item_type := p_item_type;

   OZF_UTILITY_PVT.debug_message('API Parameters For:---->: ' || l_full_api_name);
   OZF_UTILITY_PVT.debug_message('1. l_mode ------------->: ' || l_mode);
   OZF_UTILITY_PVT.debug_message('2. l_fund_id ---------->: ' || l_fund_id);
   OZF_UTILITY_PVT.debug_message('3. l_item_id ---------->: ' || l_item_id);
   OZF_UTILITY_PVT.debug_message('4. l_item_type--------->: ' || l_item_type);

   IF     l_mode IN ('ADD', 'DELETE')
      AND l_fund_id > 0
      AND l_item_id > 0
      AND l_item_type IN ('PRICING_ATTRIBUTE1', 'PRICING_ATTRIBUTE2')
   THEN
     NULL;
   ELSE
     RAISE OZF_TP_INVALID_PARAM;
   END IF;


   IF l_mode = 'ADD' THEN

     add_cascade_product_spread
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fund_id            => l_fund_id,
                          p_item_id            => l_item_id,
                          p_item_type          => l_item_type
                         );

   ELSIF l_mode = 'DELETE' THEN  -- this will remove ONE product only and adjust the OTHERS quota for all FACTS

     delete_single_product
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fund_id            => l_fund_id,
                          p_item_id            => l_item_id,
                          p_item_type          => l_item_type
                         );

   END IF;


   -- If any errors happen abort API.
   IF    x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   OZF_UTILITY_PVT.debug_message('Public API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN OZF_TP_INVALID_PARAM THEN
          ROLLBACK TO cascade_product_spread;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_INVALID_PARAM_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : INVALID PARAMETER EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO cascade_product_spread;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO cascade_product_spread;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO cascade_product_spread;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END cascade_product_spread;



----- Target Allocation APIs -------------------------------------------------------------------------------
-- ------------------------
-- Public Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: ALLOCATE TARGET
-- Desc: 1. Allocate Target across Accounts and Products for Sales Rep
--       2. Add-on Target on subsequent call
-- -----------------------------------------------------------------
PROCEDURE allocate_target
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_mode               IN          VARCHAR2,
    p_fund_id            IN          NUMBER,
    p_old_start_date     IN          DATE,
    p_new_end_date       IN          DATE,
    p_addon_fact_id      IN          NUMBER,
    p_addon_amount       IN          NUMBER
) IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'allocate_target';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);
   l_mode                   VARCHAR2(30);
   l_fund_id                NUMBER;
   l_old_start_date         DATE;
   l_new_end_date           DATE;
   l_addon_fact_id          NUMBER;
   l_addon_amount           NUMBER;


 CURSOR acct_alloc_bes_csr (l_fund_id NUMBER)
   IS
   select account_allocation_id
   from ozf_account_allocations
   where allocation_for = 'FUND'
     AND allocation_for_id = l_fund_id
     AND parent_party_id > 0;

 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT allocate_target;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   OZF_UTILITY_PVT.debug_message('Public API: ' || l_full_api_name || ' -- start');

   l_mode := p_mode;
   l_fund_id := p_fund_id;
   l_old_start_date := p_old_start_date;
   l_new_end_date := p_new_end_date;
   l_addon_fact_id:= p_addon_fact_id;
   l_addon_amount:= p_addon_amount;

   OZF_UTILITY_PVT.debug_message('API Parameters For:---->: ' || l_full_api_name);
   OZF_UTILITY_PVT.debug_message('1. l_mode ------------->: ' || l_mode);
   OZF_UTILITY_PVT.debug_message('2. l_fund_id----------->: ' || l_fund_id);
   OZF_UTILITY_PVT.debug_message('3. l_old_start_date---->: ' || to_char(l_old_start_date, 'YYYY/MM/DD'));
   OZF_UTILITY_PVT.debug_message('4. l_new_end_date------>: ' || to_char(l_new_end_date, 'YYYY/MM/DD'));
   OZF_UTILITY_PVT.debug_message('5. l_addon_fact_id----->: ' || l_addon_fact_id);
   OZF_UTILITY_PVT.debug_message('6. l_addon_amount------>: ' || l_addon_amount);

   IF l_mode IN ('FIRSTTIME', 'ADDON', 'DELETE') AND l_fund_id > 0 THEN
      NULL;
   ELSE
      RAISE OZF_TP_INVALID_PARAM;
   END IF;

   IF l_mode = 'ADDON' THEN
      IF l_addon_fact_id > 0 THEN
         NULL;
      ELSE
         RAISE OZF_TP_INVALID_PARAM;
      END IF;
   END IF;


   IF l_mode = 'FIRSTTIME' THEN

     allocate_target_first_time
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fund_id            => l_fund_id
                         );


     FOR acct_alloc_bes_rec IN acct_alloc_bes_csr(l_fund_id)
     LOOP
        raise_business_event(acct_alloc_bes_rec.account_allocation_id);
     END LOOP;


   ELSIF l_mode = 'ADDON' THEN

     allocate_target_addon
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fund_id            => l_fund_id,
                          p_old_start_date     => l_old_start_date,
                          p_new_end_date       => l_new_end_date,
                          p_addon_fact_id      => l_addon_fact_id,
                          p_addon_amount       => l_addon_amount
                         );

   ELSIF l_mode = 'DELETE' THEN

     delete_target_allocation
                         (p_api_version        => p_api_version,
                          x_return_status      => x_return_status,
                          x_error_number       => x_error_number,
                          x_error_message      => x_error_message,
                          p_fund_id            => l_fund_id
                         );

   END IF;


   -- If any errors happen abort API.
   IF    x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   OZF_UTILITY_PVT.debug_message('Public API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN OZF_TP_INVALID_PARAM THEN
          ROLLBACK TO allocate_target;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_INVALID_PARAM_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : INVALID PARAMETER EXCEPTION = '||sqlerrm(sqlcode));
          OZF_UTILITY_PVT.debug_message(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO allocate_target;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO allocate_target;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO allocate_target;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END allocate_target;



----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

-- ------------------------
-- Public Function
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Called from Account Spread and Product Spread UI
-- Desc: This is part of the tweaking to swap DB rows to UI columns
--       after brainstorming with ATG, Performance, Arch teams.
-- Note: Distinct allocation_for are = { CUST, PROD }
--
--
--
-- -----------------------------------------------------------------

 FUNCTION GET_TARGET
    (p_allocation_for_id      IN number,
     p_time_id                IN number,
     p_allocation_for         IN varchar2 DEFAULT 'PROD'
    ) RETURN NUMBER IS

 l_target  number;

 BEGIN

   IF p_time_id = null or p_time_id < 0 THEN
      return -1;
   ELSE
     SELECT
       target into l_target
     FROM
       OZF_TIME_ALLOCATIONS
     WHERE
           allocation_for = p_allocation_for
       AND allocation_for_id = p_allocation_for_id
       AND time_id = p_time_id;

     return l_target;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     return null;
 END;


-- ------------------------
-- Public Function
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Called from Account Spread and Product Spread UI
-- Desc: This is part of the tweaking to swap DB rows to UI columns
--       after brainstorming with ATG, Performance, Arch teams.
-- Note: Distinct allocation_for are = { CUST, PROD }
--
--
--
-- -----------------------------------------------------------------

 FUNCTION GET_TARGET_PKEY
    (p_allocation_for_id      IN number,
     p_time_id                IN number,
     p_allocation_for         IN varchar2 DEFAULT 'PROD'
    ) RETURN NUMBER IS

 l_time_allocation_id  number;

 BEGIN

   IF p_time_id = null or p_time_id < 0 THEN
      return -1;
   ELSE
     SELECT
       time_allocation_id into l_time_allocation_id
     FROM
       OZF_TIME_ALLOCATIONS
     WHERE
           allocation_for = p_allocation_for
       AND allocation_for_id = p_allocation_for_id
       AND time_id = p_time_id;

     return l_time_allocation_id;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     return null;
 END;

-- ------------------------
-- Public Function
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Called from Account Spread and Product Spread UI
-- Desc: This is part of the tweaking to swap DB rows to UI columns
--       after brainstorming with ATG, Performance, Arch teams.
-- Note: Distinct allocation_for are = { CUST, PROD }
--
--
--
-- -----------------------------------------------------------------

 FUNCTION GET_SALES
    (p_allocation_for_id      IN number,
     p_time_id                IN number,
     p_allocation_for         IN varchar2 DEFAULT 'PROD'
    ) RETURN NUMBER IS

 l_lysp_sales number;

 BEGIN

   IF p_time_id = null or p_time_id < 0 THEN
      return -1;
   ELSE
     SELECT
       lysp_sales into l_lysp_sales
     FROM
       OZF_TIME_ALLOCATIONS
     WHERE
           allocation_for = p_allocation_for
       AND allocation_for_id = p_allocation_for_id
       AND time_id = p_time_id;

     return l_lysp_sales;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     return null;
 END;


-- ------------------------
-- ------------------------
-- Private  Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: adjust_target_for_acct_added
-- Desc: 1. Create new target allocation records,
--          when an account is newly assigned to a territory
--       2. Note that FACT Product Spread is NOT effected due to xFer of ship_to
-- -----------------------------------------------------------------
PROCEDURE adjust_target_for_acct_added
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id              IN          NUMBER,
    p_corr_fund_id         IN          NUMBER,
    p_terr_id              IN          NUMBER,
    p_ship_to_site_use_id  IN          NUMBER
) IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'adjust_target_for_acct_added';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; -- := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));    --Bugfix7540057

   l_start_date             VARCHAR2(30) := null;
   l_end_date               VARCHAR2(30) := null;
   l_period_type_id         NUMBER;
   l_lysp_in_clause         VARCHAR2(1000) := null;
   l_in_clause              VARCHAR2(1000) := null;

   l_total_lysp_sales       NUMBER;
   l_total_product_sales    NUMBER;
   l_product_sales          NUMBER;

   l_account_allocation_id  NUMBER;
   l_product_allocation_id  NUMBER;
   l_time_allocation_id     NUMBER;

   l_period_tbl          OZF_TIME_API_PVT.G_period_tbl_type;
   l_lysp_period_tbl     OZF_TIME_API_PVT.G_period_tbl_type;

   p_acct_alloc_rec      ozf_account_allocations%ROWTYPE;
   p_prod_alloc_rec      ozf_product_allocations%ROWTYPE;
   p_time_alloc_rec      ozf_time_allocations%ROWTYPE;


  CURSOR fund_csr
  IS
   SELECT
    owner,
    start_period_id,
    end_period_id,
    start_date_active,
    end_date_active,
    status_code,
    original_budget,
    transfered_in_amt,
    transfered_out_amt,
    node_id, -- (=territory id)
    product_spread_time_id period_type_id -- (= minor_scale_id i.e. qtrly or monthly)
   FROM
    ozf_funds_all_vl
   WHERE
    fund_id = p_fund_id;

  l_fund_rec    fund_csr%ROWTYPE;


  CURSOR product_lysp_sales_csr (l_product_id    NUMBER,
                                 l_territory_id  NUMBER,
                                 l_site_use_id   NUMBER,
                                 l_time_id       NUMBER) IS
   SELECT
    SUM(bsmv.sales) sales
   FROM
     ozf_order_sales_v bsmv,
     ams_party_market_segments a
   WHERE
        a.market_qualifier_reference = l_territory_id
    AND a.market_qualifier_type='TERRITORY'
    AND a.site_use_id = l_site_use_id
    AND bsmv.ship_to_site_use_id = a.site_use_id
    AND bsmv.inventory_item_id = l_product_id
    AND bsmv.time_id = l_time_id;


  CURSOR category_lysp_sales_csr (l_category_id    NUMBER,
                                  l_territory_id   NUMBER,
                                  l_site_use_id    NUMBER,
                                  l_time_id        NUMBER,
                                  l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND bsmv.inventory_item_id IN
                             ( SELECT DISTINCT MIC.INVENTORY_ITEM_ID
                               FROM   MTL_ITEM_CATEGORIES     MIC,
                                      ENI_PROD_DENORM_HRCHY_V DENORM
                               WHERE  MIC.CATEGORY_SET_ID  = DENORM.CATEGORY_SET_ID
                                AND   MIC.CATEGORY_ID      = DENORM.CHILD_ID
                                AND   DENORM.PARENT_ID     = l_category_id
                               MINUS
                               SELECT p.item_id
                               FROM   ozf_product_allocations p
                               WHERE  p.fund_id = l_fund_id
                                  AND p.item_type = 'PRICING_ATTRIBUTE1'
                             );


  CURSOR others_lysp_sales_csr (l_territory_id   NUMBER,
                                l_site_use_id    NUMBER,
                                l_time_id        NUMBER,
                                l_fund_id        NUMBER) IS
  SELECT
   SUM(bsmv.sales) sales
  FROM
   ozf_order_sales_v bsmv,
   ams_party_market_segments a
  WHERE
      a.market_qualifier_reference = l_territory_id
  AND a.market_qualifier_type='TERRITORY'
  AND a.site_use_id = l_site_use_id
  AND bsmv.ship_to_site_use_id = a.site_use_id
  AND bsmv.time_id = l_time_id
  AND NOT EXISTS
  (
  ( SELECT p.item_id
    FROM ozf_product_allocations p
    WHERE
        p.fund_id = l_fund_id
    AND p.item_type = 'PRICING_ATTRIBUTE1'
    AND p.item_id = bsmv.inventory_item_id
    UNION ALL
    SELECT MIC.INVENTORY_ITEM_ID
    FROM   MTL_ITEM_CATEGORIES MIC,
           ENI_PROD_DENORM_HRCHY_V DENORM,
           OZF_PRODUCT_ALLOCATIONS p
    WHERE p.FUND_ID = l_fund_id
      AND p.ITEM_TYPE = 'PRICING_ATTRIBUTE2'
      AND p.ITEM_ID = DENORM.PARENT_ID
      AND MIC.CATEGORY_SET_ID = DENORM.CATEGORY_SET_ID
      AND MIC.CATEGORY_ID = DENORM.CHILD_ID
      AND MIC.INVENTORY_ITEM_ID = bsmv.inventory_item_id
  )
  MINUS
  SELECT prod.inventory_item_id
  FROM ams_act_products prod
  where
      prod.level_type_code = 'PRODUCT'
  AND prod.arc_act_product_used_by = 'FUND'
  AND prod.act_product_used_by_id = l_fund_id
  AND prod.excluded_flag = 'Y'
  AND prod.inventory_item_id = bsmv.inventory_item_id
  );

  CURSOR fund_product_spread_csr
         (l_fund_id        number) IS
    SELECT
       p.product_allocation_id,
       p.item_id,
       p.item_type,
       p.target
    FROM
       ozf_product_allocations p
    WHERE
       p.fund_id = l_fund_id;

   l_fund_product_rec     fund_product_spread_csr%rowtype;


  CURSOR corr_time_alloc_rec (l_alloc_for_id NUMBER) IS
  SELECT *
  FROM  ozf_time_allocations tt
  WHERE tt.allocation_for = 'CUST'
    AND tt.allocation_for_id = l_alloc_for_id; -- p_acct_alloc_rec.account_allocation_id;


  CURSOR corr_prod_alloc_rec
         (l_acct_alloc_id        number) IS
    SELECT *
    FROM
       ozf_product_allocations p
    WHERE
       p.allocation_for = 'CUST'
   AND p.allocation_for_id = l_acct_alloc_id; -- p_acct_alloc_rec.account_allocation_id;


  CURSOR corr_prod_time_alloc_rec (l_alloc_for_id NUMBER) IS
  SELECT *
  FROM  ozf_time_allocations tt
  WHERE tt.allocation_for = 'PROD'
    AND tt.allocation_for_id = l_alloc_for_id; -- p_prod_alloc_rec.product_allocation_id;


 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT adjust_target_for_acct_added;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ' -- start');

   Ozf_Utility_pvt.write_conc_log('- Parameter - p_fund_id ==> '      || p_fund_id);
   Ozf_Utility_pvt.write_conc_log('- Parameter - p_corr_fund_id ==> ' || p_corr_fund_id);
   Ozf_Utility_pvt.write_conc_log('- Parameter - p_terr_id ==> '      || p_terr_id);
   Ozf_Utility_pvt.write_conc_log('- Parameter - p_ship_to_site_use_id ==> ' || p_ship_to_site_use_id);


   OPEN fund_csr;
   FETCH fund_csr INTO l_fund_rec;
   CLOSE fund_csr ;

   l_org_id := get_org_id(l_fund_rec.node_id);    --Bugfix 7540057

   l_start_date := to_char(l_fund_rec.start_date_active, 'YYYY/MM/DD');
   l_end_date   := to_char(l_fund_rec.end_date_active, 'YYYY/MM/DD');
   l_period_type_id := l_fund_rec.period_type_id;

   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ': Begin - Getting Time_ids Between '
                                                 ||l_start_date||' AND '||l_end_date||' ; '
                                                 ||' Period_Type_id = '||l_period_type_id||' ; ');

   IF l_start_date IS NULL OR
      l_end_date IS NULL OR
      l_period_type_id IS NULL
   THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   l_period_tbl := OZF_TIME_API_PVT.get_period_tbl
                                    (l_start_date,
                                     l_end_date,
                                     l_period_type_id);

   IF l_period_tbl IS NULL OR l_period_tbl.COUNT <= 0 THEN
      RAISE OZF_TP_BLANK_PERIOD_TBL;
   END IF;

   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ': End - Getting Time_ids Between '||l_start_date
                                         ||' AND '||l_end_date||' ; ');
   IF l_period_tbl IS NOT NULL THEN
    IF l_period_tbl.COUNT > 0 THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
        IF l_period_tbl.exists(l_idx) THEN

         l_lysp_period_tbl(l_idx) := OZF_TIME_API_PVT.get_lysp_id (l_period_tbl(l_idx), l_period_type_id);

         Ozf_Utility_pvt.write_conc_log(SubStr('l_period_tbl('||TO_CHAR(l_idx)||') = '
                               ||TO_CHAR(l_period_tbl(l_idx)), 1,255));
        END IF;
      END LOOP;
    END IF;
   END IF;

   --l_in_clause := '(';
   l_in_clause := NULL;
   IF l_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_period_tbl.first..l_period_tbl.last
      LOOP
          IF l_in_clause IS NULL THEN
             l_in_clause := LTRIM(' '||l_period_tbl(l_idx));
          ELSE
             l_in_clause := l_in_clause ||','|| l_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_in_clause := l_in_clause||')';

   l_lysp_in_clause := NULL;
   IF l_lysp_period_tbl IS NOT NULL THEN
      FOR l_idx IN l_lysp_period_tbl.first..l_lysp_period_tbl.last
      LOOP
          IF l_lysp_in_clause IS NULL THEN
             l_lysp_in_clause := LTRIM(' '||l_lysp_period_tbl(l_idx));
          ELSE
             l_lysp_in_clause := l_lysp_in_clause ||','|| l_lysp_period_tbl(l_idx);
          END IF;
      END LOOP;
   END IF;
   --l_lysp_in_clause := l_lysp_in_clause||')';


   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ': Time_ids between '||l_start_date
                                         ||' AND '||l_end_date||' ARE : '||l_in_clause||' ; ');
   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ': LYSP-Time_ids between '||l_start_date
                                         ||' AND '||l_end_date||' ARE : '||l_lysp_in_clause||' ; ');


-- 1. CREATING NEW SHIPTO ACCOUNT HEADER RECORD ....

p_acct_alloc_rec := null;

IF p_corr_fund_id IS NOT NULL
THEN

---read the corr funds existing account rows -----
  SELECT * INTO p_acct_alloc_rec
  FROM ozf_account_allocations aa
  WHERE aa.allocation_for = 'FUND'
    and allocation_for_id = p_corr_fund_id
    and site_use_code = 'SHIP_TO'
    and site_use_id = p_ship_to_site_use_id;
ELSE

-- read the unallocated row for p_fund_id
  SELECT * INTO p_acct_alloc_rec
  FROM ozf_account_allocations aa
  WHERE aa.allocation_for = 'FUND'
    and allocation_for_id = p_fund_id
    and site_use_id = -9999;

---then get the newly added account for p_terr_id and new_ship_to_id
  SELECT
    a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id,
    a.site_use_code                                          site_use_code,
    OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    NVL(a.bill_to_site_use_id, -9996)                        bill_to_site_use_id,
    OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    a.party_id                                               parent_party_id,
    NVL(a.rollup_party_id, a.party_id)                       rollup_party_id
  INTO
    p_acct_alloc_rec.cust_account_id,
    p_acct_alloc_rec.site_use_id,
    p_acct_alloc_rec.site_use_code,
    p_acct_alloc_rec.location_id,
    p_acct_alloc_rec.bill_to_site_use_id,
    p_acct_alloc_rec.bill_to_location_id,
    p_acct_alloc_rec.parent_party_id,
    p_acct_alloc_rec.rollup_party_id
  FROM
    ams_party_market_segments a
  WHERE
       a.market_qualifier_reference = p_terr_id
   AND a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id IS NOT NULL
   AND a.site_use_id = p_ship_to_site_use_id;


  p_acct_alloc_rec.selected_flag                 := 'Y';
  p_acct_alloc_rec.target                        := 0;
  p_acct_alloc_rec.lysp_sales                    := 0;
  p_acct_alloc_rec.parent_Account_allocation_id  := NULL;


END IF;

l_account_allocation_id := get_account_allocation_id;

Ozf_Account_Allocations_Pkg.Insert_Row(
  px_Account_allocation_id        => l_account_allocation_id,
  p_allocation_for                => p_acct_alloc_rec.allocation_for,
  p_allocation_for_id             => p_fund_id,
  p_cust_account_id               => p_acct_alloc_rec.cust_account_id,
  p_site_use_id                   => p_acct_alloc_rec.site_use_id,
  p_site_use_code                 => p_acct_alloc_rec.site_use_code,
  p_location_id                   => p_acct_alloc_rec.location_id,
  p_bill_to_site_use_id           => p_acct_alloc_rec.bill_to_site_use_id,
  p_bill_to_location_id           => p_acct_alloc_rec.bill_to_location_id,
  p_parent_party_id               => p_acct_alloc_rec.parent_party_id,
  p_rollup_party_id               => p_acct_alloc_rec.rollup_party_id,
  p_selected_flag                 => p_acct_alloc_rec.selected_flag,
  p_target                        => 0,
  p_lysp_sales                    => p_acct_alloc_rec.lysp_sales,
  p_parent_Account_allocation_id  => p_acct_alloc_rec.parent_account_allocation_id,
  px_object_version_number        => l_object_version_number,
  p_creation_date                 => SYSDATE,
  p_created_by                    => FND_GLOBAL.USER_ID,
  p_last_update_date              => SYSDATE,
  p_last_updated_by               => FND_GLOBAL.USER_ID,
  p_last_update_login             => FND_GLOBAL.conc_login_id,
  p_attribute_category            => p_acct_alloc_rec.attribute_category,
  p_attribute1                    => p_acct_alloc_rec.attribute1,
  p_attribute2                    => p_acct_alloc_rec.attribute2,
  p_attribute3                    => p_acct_alloc_rec.attribute3,
  p_attribute4                    => p_acct_alloc_rec.attribute4,
  p_attribute5                    => p_acct_alloc_rec.attribute5,
  p_attribute6                    => p_acct_alloc_rec.attribute6,
  p_attribute7                    => p_acct_alloc_rec.attribute7,
  p_attribute8                    => p_acct_alloc_rec.attribute8,
  p_attribute9                    => p_acct_alloc_rec.attribute9,
  p_attribute10                   => p_acct_alloc_rec.attribute10,
  p_attribute11                   => p_acct_alloc_rec.attribute11,
  p_attribute12                   => p_acct_alloc_rec.attribute12,
  p_attribute13                   => p_acct_alloc_rec.attribute13,
  p_attribute14                   => p_acct_alloc_rec.attribute14,
  p_attribute15                   => p_acct_alloc_rec.attribute15,
  px_org_id                       => l_org_id
);


-- 2. CREATING NEW SHIPTO ACCOUNT - TIME RECORDS ....

FOR p_time_alloc_rec IN corr_time_alloc_rec (p_acct_alloc_rec.account_allocation_id)
LOOP
           l_time_allocation_id := get_time_allocation_id;
           Ozf_Time_Allocations_Pkg.Insert_Row(
              px_time_allocation_id  => l_time_allocation_id,
              p_allocation_for  => p_time_alloc_rec.allocation_for,
              p_allocation_for_id  => l_account_allocation_id,
              p_time_id  => p_time_alloc_rec.time_id,
              p_period_type_id => p_time_alloc_rec.period_type_id,
              p_target  => p_time_alloc_rec.target,
              p_lysp_sales  => p_time_alloc_rec.lysp_sales,
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_time_alloc_rec.attribute_category,
              p_attribute1  => p_time_alloc_rec.attribute1,
              p_attribute2  => p_time_alloc_rec.attribute2,
              p_attribute3  => p_time_alloc_rec.attribute3,
              p_attribute4  => p_time_alloc_rec.attribute4,
              p_attribute5  => p_time_alloc_rec.attribute5,
              p_attribute6  => p_time_alloc_rec.attribute6,
              p_attribute7  => p_time_alloc_rec.attribute7,
              p_attribute8  => p_time_alloc_rec.attribute8,
              p_attribute9  => p_time_alloc_rec.attribute9,
              p_attribute10  => p_time_alloc_rec.attribute10,
              p_attribute11  => p_time_alloc_rec.attribute11,
              p_attribute12  => p_time_alloc_rec.attribute12,
              p_attribute13  => p_time_alloc_rec.attribute13,
              p_attribute14  => p_time_alloc_rec.attribute14,
              p_attribute15  => p_time_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );
END LOOP; -- end of account - time records


IF p_corr_fund_id IS NOT NULL THEN

-- 3. UPDATING NEW SHIPTO ACCOUNT TIME RECORDS  - PAST periods....

  -- CURRENT AND FUTURE TARGETS ARE carried with the account (already done above)

  -- NOW, MAKE PAST TARGETS ZERO
  update  ozf_time_allocations tt
  set tt.target = 0
  WHERE tt.allocation_for = 'CUST'
    AND tt.allocation_for_id = l_account_allocation_id
    and EXISTS
            (select 'x'
            from ozf_time_ent_period period
            where period.ent_period_id = tt.time_id
            and period.end_date < trunc(sysdate)
            and tt.period_type_id = 32
            UNION
            select 'x'
            from ozf_time_ent_qtr qtr
            where qtr.ent_qtr_id = tt.time_id
            and qtr.end_date < trunc(sysdate)
            and tt.period_type_id = 64
            );

-- 4. UPDATING UNALLOCATED TIME RECORDS  - CURR and FUTURE periods....

  -- PAST UNALLOCATED remains unchanged
  -- Adjust CURRRENT AND FUTURE Targets for UNALLOCATED row
  update  ozf_time_allocations tta
  set tta.target = tta.target - (
                                SELECT ttb.target
                                FROM ozf_time_allocations ttb
                                WHERE ttb.allocation_for = 'CUST'
                                AND ttb.allocation_for_id = l_account_allocation_id
                                AND ttb.time_id = tta.time_id
                                )
  where
        tta.allocation_for = 'CUST'
    AND tta.allocation_for_id = ( SELECT aa.account_allocation_id
                                FROM ozf_account_allocations aa
                                WHERE aa.allocation_for = 'FUND'
                                and aa.allocation_for_id = p_fund_id
                                and aa.site_use_id = -9999)
    and EXISTS
            (select 'x'
            from ozf_time_ent_period period
            where period.ent_period_id = tta.time_id
            and period.end_date >= trunc(sysdate)
            and tta.period_type_id = 32
            UNION
            select 'x'
            from ozf_time_ent_qtr qtr
            where qtr.ent_qtr_id = tta.time_id
            and qtr.end_date >= trunc(sysdate)
            and tta.period_type_id = 64
            );

/*
  update  ozf_time_allocations tta,  ozf_time_allocations ttb
  set tta.target = tta.target - ttb.target
  where ttb.allocation_for = 'CUST'
    AND ttb.allocation_for_id = l_account_allocation_id
    AND tta.time_id = ttb.time_id
    AND tta.allocation_for = 'CUST'
    AND tta.allocation_for_id ( SELECT aa.account_allocation_id
                                FROM ozf_account_allocations aa
                                WHERE aa.allocation_for = 'FUND'
                                and aa.allocation_for_id = p_fund_id
                                and aa.site_use_id = -9999)
    and EXISTS
            (select 'x'
            from ozf_time_ent_period period
            where period.ent_period_id = tta.time_id
            and period.start_date >= trunc(sysdate)
            and tta.period_type_id = 32
            UNION
            select 'x'
            from ozf_time_ent_qtr qtr
            where qtr.ent_qtr_id = tta.time_id
            and qtr.start_date >= trunc(sysdate)
            and tta.period_type_id = 64
            );
*/

ELSE

-- When corr quota is not found  i.e. this is brand new account

-- 5. UPDATING NEW SHIPTO ACCOUNT TIME RECORDS  - All periods....

  update  ozf_time_allocations tt
  set tt.target = 0,
  tt.lysp_sales = (
                  SELECT SUM(bsmv.sales)
                  FROM ozf_order_sales_v bsmv
                  WHERE bsmv.ship_to_site_use_id = p_ship_to_site_use_id
                  AND bsmv.time_id = OZF_TIME_API_PVT.get_lysp_id(tt.time_id, tt.period_type_id)
                  )
  WHERE tt.allocation_for = 'CUST'
    AND tt.allocation_for_id = l_account_allocation_id;


END IF;


-- Rollup the time targets to the acount target level for 2 rows
--   i) for newly created row for l_ship_to
--  (ii) for unallocated row

-- 6. UPDATING NEW SHIPTO and UNALLOCATED ACCOUNT Header RECORDS  ....

  UPDATE OZF_ACCOUNT_ALLOCATIONS aa
  SET (aa.TARGET, aa.LYSP_SALES) = (
                  SELECT SUM(ti.TARGET), SUM(ti.lysp_sales)
                  FROM  OZF_TIME_ALLOCATIONS ti
                  WHERE  ti.ALLOCATION_FOR = 'CUST'
                  AND  ti.ALLOCATION_FOR_ID = aa.account_allocation_id
                 ),
    aa.object_version_number = aa.object_version_number + 1,
    aa.last_update_date = SYSDATE,
    aa.last_updated_by = FND_GLOBAL.USER_ID,
    aa.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
  WHERE
    (aa.account_allocation_id = l_account_allocation_id)
    OR
    (
        aa.allocation_for = 'FUND'
    and aa.allocation_for_id = p_fund_id
    and aa.site_use_id = -9999
    );


-- 7. UPDATING SHIPTOs Product Allocation Records  ...


    -- IF There is corr QUOTA THEN move its product allocation for l_ship_to
  IF p_corr_fund_id IS NOT NULL THEN

  -- 8. CREATING SHIPTOs Product Spread Header Records ....

    FOR p_prod_alloc_rec IN corr_prod_alloc_rec (p_acct_alloc_rec.account_allocation_id)
    LOOP

           l_product_allocation_id := get_product_allocation_id;

           Ozf_Product_Allocations_Pkg.Insert_Row(
              px_product_allocation_id  => l_product_allocation_id,
              p_allocation_for  => p_prod_alloc_rec.allocation_for,
              p_allocation_for_id  => l_account_allocation_id,
              p_fund_id  => p_fund_id,
              p_item_type  => p_prod_alloc_rec.item_type,
              p_item_id  => p_prod_alloc_rec.item_id,
              p_selected_flag  => p_prod_alloc_rec.selected_flag,
              p_target  => p_prod_alloc_rec.target,
              p_lysp_sales  => p_prod_alloc_rec.lysp_sales,
              p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
              px_object_version_number  => l_object_version_number,
              p_creation_date  => SYSDATE,
              p_created_by  => FND_GLOBAL.USER_ID,
              p_last_update_date  => SYSDATE,
              p_last_updated_by  => FND_GLOBAL.USER_ID,
              p_last_update_login  => FND_GLOBAL.conc_login_id,
              p_attribute_category  => p_prod_alloc_rec.attribute_category,
              p_attribute1  => p_prod_alloc_rec.attribute1,
              p_attribute2  => p_prod_alloc_rec.attribute2,
              p_attribute3  => p_prod_alloc_rec.attribute3,
              p_attribute4  => p_prod_alloc_rec.attribute4,
              p_attribute5  => p_prod_alloc_rec.attribute5,
              p_attribute6  => p_prod_alloc_rec.attribute6,
              p_attribute7  => p_prod_alloc_rec.attribute7,
              p_attribute8  => p_prod_alloc_rec.attribute8,
              p_attribute9  => p_prod_alloc_rec.attribute9,
              p_attribute10  => p_prod_alloc_rec.attribute10,
              p_attribute11  => p_prod_alloc_rec.attribute11,
              p_attribute12  => p_prod_alloc_rec.attribute12,
              p_attribute13  => p_prod_alloc_rec.attribute13,
              p_attribute14  => p_prod_alloc_rec.attribute14,
              p_attribute15  => p_prod_alloc_rec.attribute15,
              px_org_id  => l_org_id
            );

  -- 9. CREATING SHIPTOs Product Spread - TIME  Records ....
        FOR p_time_alloc_rec IN corr_prod_time_alloc_rec (p_prod_alloc_rec.product_allocation_id)
        LOOP
                   l_time_allocation_id := get_time_allocation_id;
                   Ozf_Time_Allocations_Pkg.Insert_Row(
                      px_time_allocation_id  => l_time_allocation_id,
                      p_allocation_for  => p_time_alloc_rec.allocation_for,
                      p_allocation_for_id  => l_product_allocation_id,
                      p_time_id  => p_time_alloc_rec.time_id,
                      p_period_type_id => p_time_alloc_rec.period_type_id,
                      p_target  => p_time_alloc_rec.target,
                      p_lysp_sales  => p_time_alloc_rec.lysp_sales,
                      px_object_version_number  => l_object_version_number,
                      p_creation_date  => SYSDATE,
                      p_created_by  => FND_GLOBAL.USER_ID,
                      p_last_update_date  => SYSDATE,
                      p_last_updated_by  => FND_GLOBAL.USER_ID,
                      p_last_update_login  => FND_GLOBAL.conc_login_id,
                      p_attribute_category  => p_time_alloc_rec.attribute_category,
                      p_attribute1  => p_time_alloc_rec.attribute1,
                      p_attribute2  => p_time_alloc_rec.attribute2,
                      p_attribute3  => p_time_alloc_rec.attribute3,
                      p_attribute4  => p_time_alloc_rec.attribute4,
                      p_attribute5  => p_time_alloc_rec.attribute5,
                      p_attribute6  => p_time_alloc_rec.attribute6,
                      p_attribute7  => p_time_alloc_rec.attribute7,
                      p_attribute8  => p_time_alloc_rec.attribute8,
                      p_attribute9  => p_time_alloc_rec.attribute9,
                      p_attribute10  => p_time_alloc_rec.attribute10,
                      p_attribute11  => p_time_alloc_rec.attribute11,
                      p_attribute12  => p_time_alloc_rec.attribute12,
                      p_attribute13  => p_time_alloc_rec.attribute13,
                      p_attribute14  => p_time_alloc_rec.attribute14,
                      p_attribute15  => p_time_alloc_rec.attribute15,
                      px_org_id  => l_org_id
                    );
        END LOOP; -- end of product - time records


  -- 10. Updating SHIPTOs Product Spread - TIME  Records ....PAST PERIODS....

    -- CURRENT AND FUTURE TARGETS ARE carried with the product (above)
    -- MAKE PAST TARGETS ZERO
      update  ozf_time_allocations tt
      set tt.target = 0
      WHERE tt.allocation_for = 'PROD'
        AND tt.allocation_for_id = l_product_allocation_id
        and EXISTS
                (select 'x'
                from ozf_time_ent_period
                where ent_period_id = tt.time_id
                and end_date < trunc(sysdate)
                and tt.period_type_id = 32
                UNION
                select 'x'
                from ozf_time_ent_qtr
                where ent_qtr_id = tt.time_id
                and end_date < trunc(sysdate)
                and tt.period_type_id = 64
                );

  --  Unallocated is automatically shown in the header of the product spread

  -- 11. Updating SHIPTOs Product Spread - Header Records ....

  -- Rollup the target numbers to the product record
     UPDATE OZF_PRODUCT_ALLOCATIONS p
     SET p.TARGET = (SELECT SUM(ti.TARGET)
                       FROM OZF_TIME_ALLOCATIONS ti
                      WHERE ti.ALLOCATION_FOR = 'PROD'
                        AND ti.ALLOCATION_FOR_ID = p.product_allocation_id),
         p.object_version_number = p.object_version_number + 1,
         p.last_update_date = SYSDATE,
         p.last_updated_by = FND_GLOBAL.USER_ID,
         p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
     WHERE p.product_allocation_id = l_product_allocation_id;

    END LOOP; --- FOR p_prod_alloc_rec IN corr_prod_alloc_rec


  ELSE

  -- if there is NO corr QUOTA THEN create brand new product allocation rows

  -- 13. CREATING SHIPTOs Product Spread - Header Records ....

         <<account_product_loop>>
         FOR fund_product_rec IN fund_product_spread_csr(p_fund_id)
         LOOP

             p_prod_alloc_rec := NULL;
             p_prod_alloc_rec.allocation_for := 'CUST';
             p_prod_alloc_rec.allocation_for_id := l_account_allocation_id;
             p_prod_alloc_rec.item_type := fund_product_rec.item_type;
             p_prod_alloc_rec.item_id := fund_product_rec.item_id;
             p_prod_alloc_rec.selected_flag := 'N';
             p_prod_alloc_rec.target := 0; --- l_total_product_target;
             p_prod_alloc_rec.lysp_sales := 0;

             l_product_allocation_id := get_product_allocation_id;

             Ozf_Product_Allocations_Pkg.Insert_Row(
                px_product_allocation_id  => l_product_allocation_id,
                p_allocation_for  => p_prod_alloc_rec.allocation_for,
                p_allocation_for_id  => p_prod_alloc_rec.allocation_for_id,
                p_fund_id  => p_fund_id,
                p_item_type  => p_prod_alloc_rec.item_type,
                p_item_id  => p_prod_alloc_rec.item_id,
                p_selected_flag  => p_prod_alloc_rec.selected_flag,
                p_target  => p_prod_alloc_rec.target,
                p_lysp_sales  => p_prod_alloc_rec.lysp_sales,
                p_parent_product_allocation_id  => p_prod_alloc_rec.parent_product_allocation_id,
                px_object_version_number  => l_object_version_number,
                p_creation_date  => SYSDATE,
                p_created_by  => FND_GLOBAL.USER_ID,
                p_last_update_date  => SYSDATE,
                p_last_updated_by  => FND_GLOBAL.USER_ID,
                p_last_update_login  => FND_GLOBAL.conc_login_id,
                p_attribute_category  => p_prod_alloc_rec.attribute_category,
                p_attribute1  => p_prod_alloc_rec.attribute1,
                p_attribute2  => p_prod_alloc_rec.attribute2,
                p_attribute3  => p_prod_alloc_rec.attribute3,
                p_attribute4  => p_prod_alloc_rec.attribute4,
                p_attribute5  => p_prod_alloc_rec.attribute5,
                p_attribute6  => p_prod_alloc_rec.attribute6,
                p_attribute7  => p_prod_alloc_rec.attribute7,
                p_attribute8  => p_prod_alloc_rec.attribute8,
                p_attribute9  => p_prod_alloc_rec.attribute9,
                p_attribute10  => p_prod_alloc_rec.attribute10,
                p_attribute11  => p_prod_alloc_rec.attribute11,
                p_attribute12  => p_prod_alloc_rec.attribute12,
                p_attribute13  => p_prod_alloc_rec.attribute13,
                p_attribute14  => p_prod_alloc_rec.attribute14,
                p_attribute15  => p_prod_alloc_rec.attribute15,
                px_org_id  => l_org_id
              );


             l_total_product_sales := 0;

  -- 14. CREATING SHIPTOs Product Spread - TIME Records ....

             <<account_product_time_loop>>
             FOR l_idx IN l_period_tbl.first..l_period_tbl.last
             LOOP
              IF l_period_tbl.exists(l_idx) THEN

                 p_time_alloc_rec := NULL;
                 l_product_sales := 0;

                 IF fund_product_rec.item_type = 'PRICING_ATTRIBUTE1' THEN
                    OPEN product_lysp_sales_csr(fund_product_rec.item_id,
                                                p_terr_id,
                                                p_ship_to_site_use_id,
                                                l_lysp_period_tbl(l_idx)
                                               );
                    FETCH product_lysp_sales_csr INTO l_product_sales;
                    CLOSE product_lysp_sales_csr;
                 ELSIF fund_product_rec.item_type = 'PRICING_ATTRIBUTE2' THEN
                     OPEN category_lysp_sales_csr(fund_product_rec.item_id,
                                                  p_terr_id,
                                                  p_ship_to_site_use_id,
                                                  l_lysp_period_tbl(l_idx),
                                                  p_fund_id
                                                 );
                     FETCH category_lysp_sales_csr INTO l_product_sales;
                     CLOSE category_lysp_sales_csr;
                 ELSIF fund_product_rec.item_type = 'OTHERS' THEN
                     OPEN others_lysp_sales_csr(p_terr_id,
                                                p_ship_to_site_use_id,
                                                l_lysp_period_tbl(l_idx),
                                                p_fund_id
                                               );
                     FETCH others_lysp_sales_csr INTO l_product_sales;
                     CLOSE others_lysp_sales_csr;
                 END IF;

                 l_product_sales := NVL(l_product_sales, 0);
                 l_total_product_sales := l_total_product_sales + l_product_sales;

                 p_time_alloc_rec.allocation_for := 'PROD';
                 p_time_alloc_rec.allocation_for_id := l_product_allocation_id;
                 p_time_alloc_rec.time_id := l_period_tbl(l_idx);
                 p_time_alloc_rec.period_type_id := l_period_type_id;
                 p_time_alloc_rec.target := 0;  ---------l_product_target;
                 p_time_alloc_rec.lysp_sales := l_product_sales;

                 l_time_allocation_id := get_time_allocation_id;

                 Ozf_Time_Allocations_Pkg.Insert_Row(
                    px_time_allocation_id  => l_time_allocation_id,
                    p_allocation_for  => p_time_alloc_rec.allocation_for,
                    p_allocation_for_id  => p_time_alloc_rec.allocation_for_id,
                    p_time_id  => p_time_alloc_rec.time_id,
                    p_period_type_id => p_time_alloc_rec.period_type_id,
                    p_target  => p_time_alloc_rec.target,
                    p_lysp_sales  => p_time_alloc_rec.lysp_sales,
                    px_object_version_number  => l_object_version_number,
                    p_creation_date  => SYSDATE,
                    p_created_by  => FND_GLOBAL.USER_ID,
                    p_last_update_date  => SYSDATE,
                    p_last_updated_by  => FND_GLOBAL.USER_ID,
                    p_last_update_login  => FND_GLOBAL.conc_login_id,
                    p_attribute_category  => p_time_alloc_rec.attribute_category,
                    p_attribute1  => p_time_alloc_rec.attribute1,
                    p_attribute2  => p_time_alloc_rec.attribute2,
                    p_attribute3  => p_time_alloc_rec.attribute3,
                    p_attribute4  => p_time_alloc_rec.attribute4,
                    p_attribute5  => p_time_alloc_rec.attribute5,
                    p_attribute6  => p_time_alloc_rec.attribute6,
                    p_attribute7  => p_time_alloc_rec.attribute7,
                    p_attribute8  => p_time_alloc_rec.attribute8,
                    p_attribute9  => p_time_alloc_rec.attribute9,
                    p_attribute10  => p_time_alloc_rec.attribute10,
                    p_attribute11  => p_time_alloc_rec.attribute11,
                    p_attribute12  => p_time_alloc_rec.attribute12,
                    p_attribute13  => p_time_alloc_rec.attribute13,
                    p_attribute14  => p_time_alloc_rec.attribute14,
                    p_attribute15  => p_time_alloc_rec.attribute15,
                    px_org_id  => l_org_id
                  );


               END IF;
             END LOOP account_product_time_loop;


  -- 15. UPDATING SHIPTOs Product Spread - Header Record ....

             UPDATE OZF_PRODUCT_ALLOCATIONS p
             SET p.lysp_sales = l_total_product_sales,
                 p.object_version_number = p.object_version_number + 1,
                 p.last_update_date = SYSDATE,
                 p.last_updated_by = FND_GLOBAL.USER_ID,
                 p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
             WHERE p.product_allocation_id = l_product_allocation_id;

         END LOOP account_product_loop;

  END IF;

   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN OZF_TP_INVALID_PARAM THEN
          ROLLBACK TO adjust_target_for_acct_added;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_INVALID_PARAM_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          Ozf_Utility_pvt.write_conc_log(l_full_api_name||' : INVALID PARAMETER EXCEPTION = '||sqlerrm(sqlcode));
          Ozf_Utility_pvt.write_conc_log(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO adjust_target_for_acct_added;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO adjust_target_for_acct_added;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO adjust_target_for_acct_added;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          Ozf_Utility_pvt.write_conc_log(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END adjust_target_for_acct_added;

-- ------------------------
-- ------------------------
-- Private  Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: adjust_target_for_acct_deleted
-- Desc: 1. Adjust Old target allocation records,
--          when an account is moved away from a territory
--       2. Note that FACT Product Spread is NOT effected due to xFer of ship_to
-- -----------------------------------------------------------------
PROCEDURE adjust_target_for_acct_deleted
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_fund_id              IN          NUMBER,
    p_ship_to_site_use_id  IN          NUMBER
) IS
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'adjust_target_for_acct_deleted';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);
   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; -- := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));    --Bugfix7540057
   l_account_allocation_id  NUMBER;
   l_unalloc_acct_alloc_id  NUMBER;

 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT adjust_target_for_acct_deleted;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ' -- start');

   IF p_fund_id IS NULL OR p_ship_to_site_use_id IS NULL
   THEN
      RAISE OZF_TP_INVALID_PARAM;
   END IF;


  BEGIN

  SELECT aa.account_allocation_id INTO l_account_allocation_id
  FROM ozf_account_allocations aa
  WHERE aa.allocation_for = 'FUND'
    and aa.allocation_for_id = p_fund_id
    and aa.site_use_code = 'SHIP_TO'
    and aa.site_use_id = p_ship_to_site_use_id;


  SELECT aa.account_allocation_id INTO l_unalloc_acct_alloc_id
  FROM ozf_account_allocations aa
  WHERE aa.allocation_for = 'FUND'
    and aa.allocation_for_id = p_fund_id
    and aa.site_use_id = -9999;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
       GOTO end_of_atfad;
  END;

   IF l_account_allocation_id IS NULL OR l_unalloc_acct_alloc_id IS NULL
   THEN
      RAISE OZF_TP_INVALID_PARAM;
   END IF;


-- 1. ADJUSTING  UNALLOCATED Time records....

   BEGIN
   Ozf_Utility_pvt.write_conc_log(' - '||l_full_api_name|| ' - 1. ADJUSTING  UNALLOCATED Time records....');

  -- Increase the Unallocated for Current and Future Periods
  update  ozf_time_allocations tta
  set tta.target = tta.target + (
                                SELECT ttb.target
                                FROM ozf_time_allocations ttb
                                WHERE ttb.allocation_for = 'CUST'
                                AND ttb.allocation_for_id = l_account_allocation_id
                                AND ttb.time_id = tta.time_id
                                )
  where
        tta.allocation_for = 'CUST'
    AND tta.allocation_for_id = l_unalloc_acct_alloc_id
    and EXISTS
            (select 'x'
            from ozf_time_ent_period period
            where period.ent_period_id = tta.time_id
            and period.end_date >= trunc(sysdate)
            and tta.period_type_id = 32
            UNION
            select 'x'
            from ozf_time_ent_qtr qtr
            where qtr.ent_qtr_id = tta.time_id
            and qtr.end_date >= trunc(sysdate)
            and tta.period_type_id = 64
            );
   END;

-- 1(b). ADJUSTING  UNALLOCATED Account record ....
   BEGIN
   Ozf_Utility_pvt.write_conc_log(' - '||l_full_api_name|| ' - 1(b). ADJUSTING  UNALLOCATED Account record....');

  -- Rollup the total targets to the unallocated records
  UPDATE OZF_ACCOUNT_ALLOCATIONS aa
  SET (aa.TARGET, aa.LYSP_SALES) = (
                  SELECT SUM(ti.TARGET), SUM(ti.lysp_sales)
                  FROM  OZF_TIME_ALLOCATIONS ti
                  WHERE  ti.ALLOCATION_FOR = 'CUST'
                  AND  ti.ALLOCATION_FOR_ID = aa.account_allocation_id
                 ),
    aa.object_version_number = aa.object_version_number + 1,
    aa.last_update_date = SYSDATE,
    aa.last_updated_by = FND_GLOBAL.USER_ID,
    aa.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
  WHERE aa.account_allocation_id = l_unalloc_acct_alloc_id;
  END;

-- 2. ADJUSTING  SHIP TO  Time records. - Curr and Future Periods ...

   BEGIN
   Ozf_Utility_pvt.write_conc_log(' - '||l_full_api_name|| ' - 2. ADJUSTING SHIP TO Time records....');

  -- Past Targets stay with the shipTo
  -- Make ShipTos Current and Future Periods Targets ZERO
  update  ozf_time_allocations ttb
  set ttb.target = 0,
      ttb.account_status = 'D'
  WHERE ttb.allocation_for = 'CUST'
  AND ttb.allocation_for_id = l_account_allocation_id
  AND EXISTS
            (select 'x'
            from ozf_time_ent_period period
            where period.ent_period_id = ttb.time_id
            and period.end_date >= trunc(sysdate)
            and ttb.period_type_id = 32
            UNION
            select 'x'
            from ozf_time_ent_qtr qtr
            where qtr.ent_qtr_id = ttb.time_id
            and qtr.end_date >= trunc(sysdate)
            and ttb.period_type_id = 64
            );
   END;

-- 2(b). ADJUSTING  SHIP TO  Account record ....
   BEGIN
   Ozf_Utility_pvt.write_conc_log(' - '||l_full_api_name|| ' - 2(b). ADJUSTING SHIP TO Account record....');

  -- Rollup the total targets to the shipTo record
  UPDATE OZF_ACCOUNT_ALLOCATIONS aa
  SET (aa.TARGET, aa.LYSP_SALES) = (
                  SELECT SUM(ti.TARGET), SUM(ti.lysp_sales)
                  FROM  OZF_TIME_ALLOCATIONS ti
                  WHERE  ti.ALLOCATION_FOR = 'CUST'
                  AND  ti.ALLOCATION_FOR_ID = aa.account_allocation_id
                 ),
    aa.account_status = 'D',
    aa.object_version_number = aa.object_version_number + 1,
    aa.last_update_date = SYSDATE,
    aa.last_updated_by = FND_GLOBAL.USER_ID,
    aa.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
  WHERE
    aa.account_allocation_id = l_account_allocation_id;
  END;

-- 3. ADJUSTING  ShipTos PRODUCT SPREAD Time records ....

   BEGIN
   Ozf_Utility_pvt.write_conc_log(' - '||l_full_api_name|| ' - 3. ADJUSTING  ShipTos Product Spread Time Records....');

-- CURRENT AND FUTURE TARGETS of this Shiptos products are made ZERO
    update  ozf_time_allocations tt
    set tt.target = 0,
        tt.account_status = 'D'
    WHERE tt.allocation_for = 'PROD'
      AND tt.allocation_for_id IN (
                                  SELECT pp.product_allocation_id
                                  FROM ozf_product_allocations pp
                                  WHERE pp.allocation_for = 'CUST'
                                    AND pp.allocation_for_id = l_account_allocation_id
                                  )
      and EXISTS
              (select 'x'
              from ozf_time_ent_period
              where ent_period_id = tt.time_id
              and end_date >= trunc(sysdate)
              and tt.period_type_id = 32
              UNION
              select 'x'
              from ozf_time_ent_qtr
              where ent_qtr_id = tt.time_id
              and end_date >= trunc(sysdate)
              and tt.period_type_id = 64
              );
   END;
--  Unallocated is automatically shown in the header of the product spread

-- 5. ADJUSTING  ShipTos PRODUCT SPREAD Header records ....
   BEGIN
   Ozf_Utility_pvt.write_conc_log(' - '||l_full_api_name|| ' - 5. ADJUSTING  ShipTos Product Spread Header Records....');

-- Rollup the target numbers to the product record
   UPDATE OZF_PRODUCT_ALLOCATIONS p
   SET p.TARGET = (SELECT SUM(ti.TARGET)
                     FROM OZF_TIME_ALLOCATIONS ti
                    WHERE ti.ALLOCATION_FOR = 'PROD'
                      AND ti.ALLOCATION_FOR_ID = p.product_allocation_id),
       p.account_status = 'D',
       p.object_version_number = p.object_version_number + 1,
       p.last_update_date = SYSDATE,
       p.last_updated_by = FND_GLOBAL.USER_ID,
       p.last_update_login = FND_GLOBAL.CONC_LOGIN_ID
   WHERE p.product_allocation_id IN (
                                    SELECT pp.product_allocation_id
                                    FROM ozf_product_allocations pp
                                    WHERE pp.allocation_for = 'CUST'
                                      AND pp.allocation_for_id = l_account_allocation_id
                                    );
   END;



   <<end_of_atfad>>

   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN OZF_TP_INVALID_PARAM THEN
          ROLLBACK TO adjust_target_for_acct_deleted;
          FND_MESSAGE.set_name('OZF', 'OZF_TP_INVALID_PARAM_TXT');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);
          Ozf_Utility_pvt.write_conc_log(l_full_api_name||' : INVALID PARAMETER EXCEPTION = '||sqlerrm(sqlcode));
          Ozf_Utility_pvt.write_conc_log(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO adjust_target_for_acct_deleted;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO adjust_target_for_acct_deleted;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO adjust_target_for_acct_deleted;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          Ozf_Utility_pvt.write_conc_log(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END adjust_target_for_acct_deleted;


-- ------------------------
-- ------------------------
-- Public  Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: ADJUST_ACCOUNT_TARGETS
-- Desc: 1. Create new target allocation records,
--          when an account is newly assigned to a territory
--       2. Adjust old target allocation records,
--          when an account is moved away from a territory
-- History
--   09-SEP-05       mkothari    created
--
-- -----------------------------------------------------------------
PROCEDURE adjust_account_targets
(
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_terr_id            IN          NUMBER := NULL
) IS
   p_api_version             CONSTANT NUMBER       := 1.0;
   x_return_status           VARCHAR2(1) ;
   l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'adjust_account_targets';
   l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER; -- := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10));    --Bugfix7540057
   l_corr_quota_id          NUMBER;
   l_node_id                NUMBER;
   l_previous_fact_id       NUMBER;
   l_activity_metric_fact_id  NUMBER;

CURSOR terr_list_csr
IS
SELECT DISTINCT
 FF.NODE_ID
FROM OZF_FUNDS_ALL_b FF
WHERE
      FF.FUND_TYPE = 'QUOTA'
  AND FF.STATUS_CODE <> 'CANCELLED'
  AND FF.NODE_ID = NVL(p_terr_id, FF.NODE_ID)
  AND EXISTS
       (SELECT 'x'
        FROM OZF_ACCOUNT_ALLOCATIONS AA
        WHERE AA.ALLOCATION_FOR = 'FUND'
          AND AA.ALLOCATION_FOR_ID = FF.FUND_ID
       );


/*

-- Use following cursor later ------------------------------------------------------
-- also change terr denorm such that adjust_acct is called only from LOAD_ procedure
------------------------------------------------------------------------------------

SELECT DISTINCT FF.NODE_ID
FROM OZF_FUNDS_ALL_b FF
WHERE
      FF.FUND_TYPE = 'QUOTA'
  AND FF.STATUS_CODE <> 'CANCELLED'
  AND FF.NODE_ID = NVL(p_terr_id, FF.NODE_ID)
  AND EXISTS
       (SELECT 'x'
        FROM OZF_ACCOUNT_ALLOCATIONS AA
        WHERE AA.ALLOCATION_FOR = 'FUND'
          AND AA.ALLOCATION_FOR_ID = FF.FUND_ID
       )
----------
UNION ALL
----------
SELECT DISTINCT FF.NODE_ID
FROM OZF_FUNDS_ALL_b FF
WHERE
      FF.FUND_TYPE = 'QUOTA'
  AND FF.STATUS_CODE <> 'CANCELLED'
  AND EXISTS
       (SELECT 'x'
        FROM OZF_ACCOUNT_ALLOCATIONS AA
        WHERE AA.ALLOCATION_FOR = 'FUND'
          AND AA.ALLOCATION_FOR_ID = FF.FUND_ID
       )
AND FF.NODE_ID IN
(
select  distinct node_id
from    ozf_funds_all_b outer
where   not exists (select 'x' from ozf_funds_all_b inner where inner.parent_fund_id = outer.fund_id)
connect by prior fund_id = parent_fund_id
start with parent_fund_id = (select inner2.fund_id
                             from ozf_funds_all_b inner2
                            where inner2.node_id = p_terr_id -- 3104
                              and inner2.fund_type = 'QUOTA'
                              and inner2.status_code <> 'CANCELLED'
                              and rownum = 1
                            )
);

Very Important Note:
Make sure that the first terr_node which is processed is the one
where accounts are added and not the one which is loosing the accounts
Otherwise, new added accounts will have zero targets. other stuff will work fine.
-------------------------------------------------------------
*/






CURSOR added_accounts_csr (l_territory_id    number)
IS
SELECT
    'A'                                                       account_status_code,
    ---a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id
    ---a.site_use_code                                          site_use_code,
    ---OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    ---NVL(a.bill_to_site_use_id, -9996)                        bill_to_site_use_id,
    ---OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    ---a.party_id                                               parent_party_id,
    ---NVL(a.rollup_party_id, a.party_id)                       rollup_party_id
  FROM
    ams_party_market_segments a
  WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id IS NOT NULL
 ------------
  MINUS
 ------------
   SELECT
    'A'                                                       account_status_code,
    ---a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id
    ---a.site_use_code                                          site_use_code,
    ---OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    ---NVL(a.bill_to_site_use_id, -9996)                        bill_to_site_use_id,
    ---OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    ---a.party_id                                               parent_party_id,
    ---NVL(a.rollup_party_id, a.party_id)                       rollup_party_id
  FROM
    ozf_party_market_segments_t a
  WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id IS NOT NULL;


 CURSOR deleted_accounts_csr (l_territory_id    number)
 IS
 SELECT
    'D'                                                       account_status_code,
    ---a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id
    ---a.site_use_code                                          site_use_code,
    ---OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    ---NVL(a.bill_to_site_use_id, -9996)                        bill_to_site_use_id,
    ---OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    ---a.party_id                                               parent_party_id,
    ---NVL(a.rollup_party_id, a.party_id)                       rollup_party_id
  FROM
    ozf_party_market_segments_t a
  WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id IS NOT NULL
 ------------
  MINUS
 ------------
   SELECT
    'D'                                                       account_status_code,
    ---a.cust_account_id                                        cust_account_id,
    a.site_use_id                                            site_use_id
    ---a.site_use_code                                          site_use_code,
    ---OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
    ---NVL(a.bill_to_site_use_id, -9996)                        bill_to_site_use_id,
    ---OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
    ---a.party_id                                               parent_party_id,
    ---NVL(a.rollup_party_id, a.party_id)                       rollup_party_id
  FROM
    ams_party_market_segments a
  WHERE
       a.market_qualifier_reference = l_territory_id
   AND a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id IS NOT NULL;


CURSOR add_quota_list_csr (l_terr_id NUMBER, l_ship_to_id NUMBER) IS
SELECT
 FF.FUND_ID
FROM OZF_FUNDS_ALL_b FF
WHERE
      FF.FUND_TYPE = 'QUOTA'
  AND FF.STATUS_CODE <> 'CANCELLED'
  AND FF.NODE_ID = l_terr_id
  AND EXISTS
       (SELECT 'x'
        FROM OZF_ACCOUNT_ALLOCATIONS AA
        WHERE AA.ALLOCATION_FOR = 'FUND'
          AND AA.ALLOCATION_FOR_ID = FF.FUND_ID
          AND AA.site_use_id <> l_ship_to_id -- newly added to the FUND
       );

CURSOR del_quota_list_csr (l_terr_id NUMBER, l_ship_to_id NUMBER) IS
SELECT
 FF.FUND_ID
FROM OZF_FUNDS_ALL_b FF
WHERE
      FF.FUND_TYPE = 'QUOTA'
  AND FF.STATUS_CODE <> 'CANCELLED'
  AND FF.NODE_ID = l_terr_id
  AND EXISTS
       (SELECT 'x'
        FROM OZF_ACCOUNT_ALLOCATIONS AA
        WHERE AA.ALLOCATION_FOR = 'FUND'
          AND AA.ALLOCATION_FOR_ID = FF.FUND_ID
          AND AA.site_use_id = l_ship_to_id -- the one deleted from the FUND targets
       );

CURSOR allocation_list_csr (l_fund_id NUMBER)
IS
SELECT
a.activity_metric_id,
a.level_depth,
a.node_id,
a.previous_fact_id,
a.activity_metric_fact_id
from ozf_act_metric_facts_all a
where a.arc_act_metric_used_by = 'FUND'
and a.act_metric_used_by_id = l_fund_id
order by a.activity_metric_id desc;


CURSOR corr_quota_csr
      (l_allocation_id        NUMBER,
       l_ship_to_site_use_id  NUMBER
      )
IS
SELECT
a.act_metric_used_by_id,
a.node_id,
a.previous_fact_id,
a.activity_metric_fact_id
from ozf_act_metric_facts_all a, OZF_FUNDS_ALL_b FF
where a.arc_act_metric_used_by = 'FUND'
and a.activity_metric_id = l_allocation_id
--and a.level_depth = l_level_depth
and a.node_id = FF.NODE_ID
AND FF.FUND_TYPE = 'QUOTA'
AND FF.STATUS_CODE <> 'CANCELLED'
AND FF.FUND_ID =  a.act_metric_used_by_id
AND EXISTS
     (SELECT 'x'
      FROM OZF_ACCOUNT_ALLOCATIONS AA
      WHERE AA.ALLOCATION_FOR = 'FUND'
        AND AA.ALLOCATION_FOR_ID = FF.FUND_ID
        AND AA.site_use_id = l_ship_to_site_use_id -- new added
     )
AND EXISTS
(SELECT  'x'
 FROM
 (
 SELECT
    'D' account_status_code,
    a.market_qualifier_reference territory_id,
    a.site_use_id site_use_id
  FROM
    ozf_party_market_segments_t a
  WHERE
       a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id = l_ship_to_site_use_id
 ------------
  MINUS
 ------------
   SELECT
    'D' account_status_code,
    a.market_qualifier_reference territory_id,
    a.site_use_id site_use_id
  FROM
    ams_party_market_segments a
  WHERE
       a.market_qualifier_type='TERRITORY'
   AND a.site_use_code = 'SHIP_TO'
   AND a.party_id IS NOT NULL
   AND a.site_use_id = l_ship_to_site_use_id
 )
);

 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT adjust_account_targets;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if l_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( l_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.g_ret_sts_success;

   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ' -- start');

   FOR terr IN terr_list_csr
   LOOP
    ---1. PROCESS ADDITION OF ACCOUNTS
     FOR new_accounts IN added_accounts_csr (terr.node_id)
     LOOP

       FOR quota in add_quota_list_csr(terr.node_id, new_accounts.site_use_id)
       LOOP

         FOR quota_allocation in allocation_list_csr (quota.fund_id)
         LOOP

           IF G_DEBUG_LEVEL THEN
            Ozf_Utility_pvt.write_conc_log('- '||l_full_api_name||'- Process Added Accounts for Quota Id =>'||quota.fund_id);
           END IF;
           -- FIND the corr_quota, such that there exists a corr_terr which lost that ship_to
           OPEN corr_quota_csr (quota_allocation.activity_metric_id, new_accounts.site_use_id);
           FETCH corr_quota_csr INTO l_corr_quota_id, l_node_id, l_previous_fact_id, l_activity_metric_fact_id;
           CLOSE corr_quota_csr;

--        -> Create account_allocation records for new ship_to based upon the old quota id
          adjust_target_for_acct_added (
                                      p_api_version        => p_api_version,
                                      x_return_status      => x_return_status,
                                      x_error_number       => x_error_number,
                                      x_error_message      => x_error_message,
                                      p_fund_id            => quota.fund_id,
                                      p_corr_fund_id       => l_corr_quota_id,
                                      p_terr_id            => terr.node_id,
                                      p_ship_to_site_use_id => new_accounts.site_use_id
                                      );

           IF    x_return_status = FND_API.g_ret_sts_error
           THEN
                 RAISE FND_API.g_exc_error;
           ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
           END IF;

         END LOOP; -- allocation_list_csr(quota.fund_id)

       END LOOP; -- add_quota_list_csr(terr.node_id, new_accounts.site_use_id)

     END LOOP; --add_quota_list_csr(terr.node_id, new_accounts.site_use_id)


    --2. PROCESS DELETION OF ACCOUNTS

     FOR del_accounts IN deleted_accounts_csr (terr.node_id)
     LOOP

       FOR quota IN del_quota_list_csr(terr.node_id, del_accounts.site_use_id)
       LOOP
         IF G_DEBUG_LEVEL THEN
           Ozf_Utility_pvt.write_conc_log('- '||l_full_api_name||'- Process Deleted Accounts for Site Use Id   =>'||del_accounts.site_use_id);
         END IF;
         adjust_target_for_acct_deleted (
                                      p_api_version        => p_api_version,
                                      x_return_status      => x_return_status,
                                      x_error_number       => x_error_number,
                                      x_error_message      => x_error_message,
                                      p_fund_id            => quota.fund_id,
                                      p_ship_to_site_use_id => del_accounts.site_use_id
                                      );

         IF    x_return_status = FND_API.g_ret_sts_error
         THEN
               RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
         END IF;

       END LOOP; -- del_quota_list_csr(terr.node_id, del_accounts.site_use_id)

     END LOOP; -- deleted_accounts_csr (terr.node_id)

-- 3. UPDATE ACCOUNT ALLOCATION account details based upon latest information from Terr (i.e from TCA )
     IF G_DEBUG_LEVEL THEN
        Ozf_Utility_pvt.write_conc_log('- '||l_full_api_name||'- UPDATE ACCOUNT ALLOCATION Table''s account details based upon latest information from Terr (i.e from TCA).');
     END IF;


--- Jan 5th, 2005
--- Uncomment following later so that TCA's latest shipto-partyid info can be updated in TP allocation tables
/*
    UPDATE
      (SELECT
          FF.NODE_ID territory_id,
          aa.account_allocation_id,
          aa.site_use_id,
          aa.site_use_code,
          aa.cust_account_id,
          aa.location_id,
          aa.bill_to_site_use_id,
          aa.bill_to_location_id,
          aa.parent_party_id,
          aa.rollup_party_id
      FROM ozf_account_allocations aa, ozf_funds_all_b ff
      WHERE FF.FUND_TYPE = 'QUOTA'
        AND FF.STATUS_CODE <> 'CANCELLED'
        AND aa.allocation_for = 'FUND'
        AND aa.allocation_for_id = FF.FUND_ID
        AND FF.NODE_ID = terr.node_id
        AND aa.parent_party_id IS NOT NULL
        AND aa.parent_party_id > 0
      ) alloc
    SET
      (
        alloc.cust_account_id,
        alloc.location_id,
        alloc.bill_to_site_use_id,
        alloc.bill_to_location_id,
        alloc.parent_party_id,
        alloc.rollup_party_id
      )
      = (
         SELECT
            a.cust_account_id                                        cust_account_id,
            OZF_LOCATION_PVT.get_location_id(a.site_use_id)          location_id,
            NVL(a.bill_to_site_use_id, -9996)                        bill_to_site_use_id,
            OZF_LOCATION_PVT.get_location_id(a.bill_to_site_use_id)  bill_to_location_id,
            a.party_id                                               parent_party_id,
            NVL(a.rollup_party_id, a.party_id)                       rollup_party_id
         FROM
            ams_party_market_segments a
         WHERE
            a.market_qualifier_reference = alloc.territory_id
            AND a.market_qualifier_reference = terr.node_id
            AND a.market_qualifier_type='TERRITORY'
            AND a.site_use_code = 'SHIP_TO'
            AND a.party_id IS NOT NULL
            AND a.site_use_id IS NOT NULL
            AND a.site_use_id = alloc.site_use_id
            AND a.site_use_code = alloc.site_use_code
        );

*/


   END LOOP; -- terr_list_csr

   Ozf_Utility_pvt.write_conc_log('Private API: ' || l_full_api_name || ' -- end');

 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO adjust_account_targets;
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_count   => x_error_number,
                                     p_data    => x_error_message);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO adjust_account_targets;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);

     WHEN OTHERS THEN
          ROLLBACK TO adjust_account_targets;

          FND_MESSAGE.set_name('OZF', 'OZF_TP_OTHERS_ERROR_TXT');
          FND_MESSAGE.set_token('OZF_TP_SQLERRM_TOKEN',SQLERRM);
          FND_MESSAGE.set_token('OZF_TP_SQLCODE_TOKEN',SQLCODE);
          FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_unexp_error ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_error_number,
                                     p_data  => x_error_message);
          Ozf_Utility_pvt.write_conc_log(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));

 END adjust_account_targets;


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

END OZF_ALLOCATION_ENGINE_PVT;

/
