--------------------------------------------------------
--  DDL for Package Body OZF_FUND_ALLOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_ALLOCATIONS_PVT" AS
/* $Header: ozfvalcb.pls 120.6.12010000.2 2008/08/08 08:53:37 ateotia ship $*/
   g_pkg_name     CONSTANT VARCHAR2(30) := 'OZF_Fund_allocations_Pvt';

   -- yzhao 04/08/2003  fix bug 2897460 - RESOURCE GROUPS IN TERRITORY ADMIN NOT WORKING IN OMO
   --       corresponds to JTF_TERR_RSC_ALL.RESOURCE_TYPE
   G_RS_EMPLOYEE_TYPE  CONSTANT VARCHAR2(30) := 'RS_EMPLOYEE';
   G_RS_GROUP_TYPE  CONSTANT VARCHAR2(30) := 'RS_GROUP';

   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

   TYPE node_info_type IS RECORD (
        node_name       VARCHAR2(240)
      , owner           NUMBER
      , parent_node_id  NUMBER
   );
   TYPE worksheet_record_type IS RECORD (
        node_id         NUMBER
      , parent_node_id  NUMBER
      , level_depth     NUMBER
      , total_amount    NUMBER
      , hb_amount       NUMBER
      , total_pct       NUMBER
      , hb_pct          NUMBER
   );
   TYPE node_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE worksheet_table_type IS TABLE OF worksheet_record_type INDEX BY BINARY_INTEGER;
   TYPE fundIdRec IS RECORD (
        fact_id   NUMBER,
        fund_id   NUMBER,
        owner     NUMBER);
   TYPE fundIdTableType IS TABLE OF fundIdRec INDEX BY BINARY_INTEGER;
   TYPE factLevelRec IS RECORD (
        fact_id         NUMBER
      , level_depth     NUMBER
   );
   TYPE factLevelTableType IS TABLE OF factLevelRec INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- FUNCTION
--   get_max_end_level
--
-- PURPOSE
--    returns g_max_end_level
--    called by BudgetTopbotAdmEO.java
-- HISTORY
--    01/28/04  kdass  Created.
-- PARAMETERS
--
---------------------------------------------------------------------
FUNCTION get_max_end_level RETURN NUMBER IS
BEGIN
   RETURN g_max_end_level;
END;

---------------------------------------------------------------------
-- PROCEDURE
--   get_node_info
--
-- PURPOSE
--    private api to get node's detail information etc.
-- HISTORY
--    05/20/02  yzhao  Created.
-- PARAMETERS
--
---------------------------------------------------------------------

PROCEDURE get_node_info(
    p_hierarchy_id       IN       NUMBER
  , p_hierarchy_type     IN       VARCHAR2
  , p_node_id            IN       NUMBER
  , x_node_info          OUT NOCOPY      node_info_type
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS

  l_node_info            node_info_type := NULL;

  -- cursors for territory
  CURSOR c_get_terr_name IS
    SELECT node_value, parent_id
    FROM   ozf_terr_v
    WHERE  hierarchy_id = p_hierarchy_id
    AND    node_id = p_node_id;

--R12 - Modified for Primary Contact - bug 4643041
  CURSOR c_get_terr_owner IS
     SELECT resource_id
     FROM  jtf_terr_rsc_all jtra,
           jtf_terr_rsc_access_all jtraa
     WHERE jtraa.terr_rsc_id = jtra.terr_rsc_id
       AND jtraa.access_type = 'OFFER'
       AND jtraa.trans_access_code = 'PRIMARY_CONTACT'
--     WHERE  primary_contact_flag = 'Y'
       AND jtra.resource_type = G_RS_EMPLOYEE_TYPE    -- yzhao: 04/09/2003 resource can be employee or group. Only employee can be used as budget owner
       AND    jtra.terr_id = p_node_id;

  -- cursors for budget hierarchy
  CURSOR c_get_budget_name IS
    SELECT short_name, owner, parent_fund_id
    FROM   ozf_funds_all_vl
    WHERE  fund_id = p_node_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- dbms_output.put_line('get_node_info: hier_type=' || p_hierarchy_type || ' node=' || p_node_id || ' hier_id=' || p_hierarchy_id);
  IF (p_hierarchy_type = 'TERRITORY') THEN
      -- territory
      OPEN c_get_terr_name;
      FETCH c_get_terr_name INTO l_node_info.node_name, l_node_info.parent_node_id;
      CLOSE c_get_terr_name;

      OPEN c_get_terr_owner;
      FETCH c_get_terr_owner INTO l_node_info.owner;
      CLOSE c_get_terr_owner;
  ELSIF (p_hierarchy_type = 'BUDGET_HIER') THEN
      -- budget
      OPEN c_get_budget_name;
      FETCH c_get_budget_name INTO l_node_info.node_name, l_node_info.owner, l_node_info.parent_node_id;
      CLOSE c_get_budget_name;

  /* for future release
  ELSIF (p_hierarchy_type = 'BUDGET_CATEGORY') THEN
  ELSIF (p_hierarchy_type = 'GEOGRAPHY') THEN
  ELSIF (p_hierarchy_type = 'HR_ORG') THEN
  */
  END IF;

  x_node_info := l_node_info;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
-- dbms_output.put_line('get_node_info: UNEXP exception ' || substr(sqlerrm, 1, 150));
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END get_node_info;


---------------------------------------------------------------------
-- PROCEDURE
--   get_node_children
--
-- PURPOSE
--    private api to get node's children etc.
-- HISTORY
--    05/20/02  yzhao  Created.
-- PARAMETERS
--    p_fund_rec: the fund record.
---------------------------------------------------------------------

PROCEDURE get_node_children(
    p_hierarchy_id       IN       NUMBER
  , p_hierarchy_type     IN       VARCHAR2
  , p_node_id            IN       NUMBER
  , x_child_node_tbl     OUT NOCOPY      node_table_type
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS

  l_index               NUMBER;
  l_child_node_tbl      node_table_type;

  -- cursors for territory
  CURSOR c_get_terr_child IS
    SELECT node_id
    FROM   ozf_terr_v
    WHERE  hierarchy_id = p_hierarchy_id
    AND    parent_id = p_node_id
    -- Bug # 5723438 fixed by ateotia (+)
    AND decode(end_date_active,'',sysdate,end_date_active) > = sysdate;
    -- Bug # 5723438 fixed by ateotia (-)

  -- cursors for budget hierarchy
  CURSOR c_get_budget_child IS
    SELECT fund_id
    FROM   ozf_funds_all_b
    WHERE  parent_fund_id = p_node_id
    AND    status_code = 'ACTIVE';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_index := 1;

-- dbms_output.put_line('get_node_children: hier_type=' || p_hierarchy_type || ' node=' || p_node_id || ' hier_id=' || p_hierarchy_id);
  IF (p_hierarchy_type = 'TERRITORY') THEN
     -- territory
     FOR child_rec IN c_get_terr_child LOOP
        l_child_node_tbl(l_index) := child_rec.node_id;
        l_index := l_index + 1;
     END LOOP;

  ELSIF (p_hierarchy_type = 'BUDGET_HIER') THEN
     FOR child_rec IN c_get_budget_child LOOP
        l_child_node_tbl(l_index) := child_rec.fund_id;
        l_index := l_index + 1;
     END LOOP;

  /* for future release
  ELSIF (p_hierarchy_type = 'BUDGET_CATEGORY') THEN
  ELSIF (p_hierarchy_type = 'GEOGRAPHY') THEN
  ELSIF (p_hierarchy_type = 'HR_ORG') THEN
  */
  END IF;

  x_child_node_tbl := l_child_node_tbl;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
-- dbms_output.put_line('get_node_children: UNEXP exception ' || substr(sqlerrm, 1, 150));
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END get_node_children;


---------------------------------------------------------------------
-- PROCEDURE
--   get_prior_year_sales
--
-- PURPOSE
--    public api to get prior year's total sales amount for one territory node
--    called by compute_worksheet and UI worksheet page
--
-- HISTORY
--    10/16/02  yzhao  Created.
--    14/07/03  nkumar  Modified.
--
-- PARAMETERS
---------------------------------------------------------------------

PROCEDURE get_prior_year_sales(
    p_hierarchy_id       IN       NUMBER
  , p_node_id            IN       NUMBER
  , p_basis_year         IN       NUMBER
  , p_alloc_id           IN       NUMBER
  , x_self_amount        OUT NOCOPY      NUMBER
  , x_rollup_amount      OUT NOCOPY      NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_start_date           DATE := NULL;
  l_end_date             DATE := NULL;
  l_temp_start_date           DATE := NULL;
  l_temp_end_date             DATE := NULL;
  l_date             DATE DEFAULT SYSDATE;
  l_curr_code            VARCHAR2(30);
  l_return_status        VARCHAR2(30);
  l_rate                 NUMBER;
  l_r_amount            NUMBER;
  l_s_amount          NUMBER;


  /* Prior year date is derived as follows
     - If Allocation has a start date (for eg: 15-MAR-2004)
       Then

           Start date is  15-MAR-<<Basis Year>>

       Else

          Check If Budget has a start date.

          If Yes (for eg: 01-MAR-2004)
          Then

              Start date is 01-MAR-<<Basis Year>>

          Else

              Start Date is '01-JAN-<<Basis year>>

     -- Same Logic for End Date
  */

  CURSOR c_prior_year_parameters(p_node_id NUMBER)
  IS
    SELECT  f.currency_code_tc,
            NVL(m.from_date, f.start_date_active),
            NVL(m.to_date, f.end_date_active)
/*
	    TO_DATE(
		     TO_CHAR( NVL(
                                    NVL(m.from_date,f.start_date_active)
				    ,TO_DATE('01-01-2004','DD-MM-YYYY')
			         )
			    ,'DD-MM') || '-' || m.basis_year
	           , 'DD-MM-YYYY'
                   ) derived_start_date,
            TO_DATE(
                     TO_CHAR( NVL(
                                    NVL(m.to_date,f.end_date_active)
                                    ,TO_DATE('31-12-2004','DD-MM-YYYY')
                                 )
                            ,'DD-MM') || '-' || m.basis_year
                   , 'DD-MM-YYYY'
                   ) derived_end_date
*/
    FROM   ozf_funds_all_b f,
           ozf_act_metrics_all m
    WHERE  m.activity_metric_id = p_alloc_id
    AND    m.arc_act_metric_used_by = 'FUND'
    AND    m.act_metric_used_by_id = f.fund_id ;

   CURSOR c_get_terr_self_accts (p_node_id IN NUMBER)
   IS
     SELECT DISTINCT cust_account_id
     FROM ams_party_market_segments
     WHERE market_qualifier_type = 'TERRITORY'
     AND   market_qualifier_reference = p_node_id;

   CURSOR c_get_terr_rollup_accts (p_node_id IN NUMBER)
   IS
     SELECT DISTINCT pms.cust_account_id
     FROM ams_party_market_segments pms,
          ozf_terr_v terr
     WHERE  pms.market_qualifier_type = 'TERRITORY'
     AND    pms.market_qualifier_reference = terr.node_id
     AND    terr.parent_id = ( SELECT terr1.parent_id
                               FROM   ozf_terr_v terr1
                               WHERE terr1.node_id = p_node_id);

   CURSOR c_get_year_to_date_sales( p_as_of_date      IN DATE ,
                                    p_cust_account_id IN NUMBER)
   IS
     SELECT NVL(SUM(b.sales_amt),0) tot_sales
     FROM ozf_time_rpt_struct a,
          ozf_order_sales_sumry_mv b
     WHERE a.report_date = p_as_of_date
     AND BITAND(a.record_type_id, 119) = a.record_type_id
     AND a.time_id = b.time_id
     AND b.sold_to_cust_account_id  = p_cust_account_id ;

     l_sales_as_of_end_date     NUMBER := 0;
     l_sales_as_of_start_date   NUMBER := 0;
     l_sales_for_cust           NUMBER := 0;
     l_total_terr_self_amount   NUMBER := 0;
     l_total_terr_rollup_amount NUMBER := 0;

     -- All data in the ozf_order_sales_sumry_mv is already converted
     -- to this currency code;
     l_common_currency_code VARCHAR2(30) := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');

     l_st VARCHAR2(10);
     l_end VARCHAR2(10);

BEGIN
  x_self_amount := 0;
  x_rollup_amount := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch currency_code, start_date and end_date
  OPEN c_prior_year_parameters(p_node_id);
  FETCH c_prior_year_parameters INTO l_curr_code, l_temp_start_date, l_temp_end_date;
  CLOSE c_prior_year_parameters;

  l_st  := NVL(TO_CHAR(l_temp_start_date, 'mm-dd'), '01-01');
  l_end := NVL(TO_CHAR(l_temp_end_date, 'mm-dd'), '12-31') ;

  l_start_date := to_date(p_basis_year || l_st, 'yyyy-mm-dd');
  l_end_date := to_date(p_basis_year || l_end, 'yyyy-mm-dd');

  --l_start_date := to_date(p_basis_year || '01-01', 'yyyy-mm-dd');
  --l_end_date := to_date(p_basis_year || '12-31', 'yyyy-mm-dd');

  -- For Self amount
  FOR cust IN c_get_terr_self_accts(p_node_id)
  LOOP

      -- Get the Sales for the customer as of end date
      OPEN  c_get_year_to_date_sales ( l_end_date, cust.cust_account_id);
      FETCH c_get_year_to_date_sales INTO l_sales_as_of_end_date ;
      CLOSE c_get_year_to_date_sales;

      -- Get the Sales for the customer as of start date
      OPEN c_get_year_to_date_sales ( l_start_date, cust.cust_account_id);
      FETCH c_get_year_to_date_sales INTO l_sales_as_of_start_date ;
      CLOSE c_get_year_to_date_sales;

      -- Actual sales between the Start and End Dates is....
      l_sales_for_cust := l_sales_as_of_end_date - l_sales_as_of_start_date ;

      l_total_terr_self_amount := l_total_terr_self_amount + l_sales_for_cust;

  END LOOP;

  -- For Rollup amount

  l_sales_as_of_end_date   := 0;
  l_sales_as_of_start_date := 0;
  l_sales_for_cust         := 0;

  FOR cust IN c_get_terr_rollup_accts(p_node_id)
  LOOP

      -- Get the Sales for the customer as of end date
      OPEN  c_get_year_to_date_sales ( l_end_date, cust.cust_account_id);
      FETCH c_get_year_to_date_sales INTO l_sales_as_of_end_date ;
      CLOSE c_get_year_to_date_sales;

      -- Get the Sales for the customer as of start date
      OPEN c_get_year_to_date_sales ( l_start_date, cust.cust_account_id);
      FETCH c_get_year_to_date_sales INTO l_sales_as_of_start_date ;
      CLOSE c_get_year_to_date_sales ;

      -- Actual sales between the Start and End Dates is....
      l_sales_for_cust := l_sales_as_of_end_date - l_sales_as_of_start_date ;

      l_total_terr_rollup_amount := l_total_terr_self_amount + l_sales_for_cust;

  END LOOP;

  --x_self_amount := l_total_terr_self_amount;
  --x_rollup_amount :=  l_total_terr_rollup_amount ;
  -- Convert the self amount

     Ozf_utility_pvt.convert_currency
                              (x_return_status => l_return_status
                              ,p_from_currency => l_common_currency_code
                              ,p_to_currency   => l_curr_code
                              ,p_from_amount   => l_total_terr_self_amount
                              ,x_to_amount     => x_self_amount
			      ,x_rate          => l_rate);

      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
            RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
            RAISE fnd_api.g_exc_unexpected_error;
      END IF;

  -- Convert the rollup amount

      Ozf_utility_pvt.convert_currency
                              (x_return_status => l_return_status
                              ,p_from_currency => l_common_currency_code
                              ,p_to_currency   => l_curr_code
                              ,p_from_amount   => l_total_terr_rollup_amount
                              ,x_to_amount     => x_rollup_amount
			      ,x_rate          => l_rate);

      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
            RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
            RAISE fnd_api.g_exc_unexpected_error;
      END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
-- dbms_output.put_line('get_prior_year_sales: UNEXP exception ' || substr(sqlerrm, 1, 150));
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END get_prior_year_sales;


---------------------------------------------------------------------
-- PROCEDURE
---   compute_worksheet
--
-- PURPOSE
--    Compute worksheet using allocation method.
--    Traverse hierarchy from current node down till end level
--    Specifically, for each level, to avoid computing round up error like bug 2413219,
--       the last node alloc amount = parent alloc down amount - sum(sibling alloc amount)
--
-- HISTORY
--    05/20/02  yzhao  Created.
--
-- PARAMETERS
--    p_alloc_down_amount: parent's allocation down amount
--    p_alloc_amount:      if it is not null, use this amount as node's allocation amount, do not compute
--    p_alloc_pct:         if it is not null, use this amount as node's allocation percentage, do not compute
---------------------------------------------------------------------
PROCEDURE compute_worksheet(
    p_api_version        IN       NUMBER    := 1.0
  , p_alloc_id           IN       NUMBER
  , p_alloc_down_amount  IN       NUMBER
  , p_alloc_amount       IN       NUMBER    := NULL
  , p_alloc_pct          IN       NUMBER    := NULL
  , p_parent_node_id     IN       NUMBER    := NULL
  , p_sibling_count      IN       NUMBER    := NULL
  , p_hierarchy_id       IN       NUMBER
  , p_hierarchy_type     IN       VARCHAR2
  , p_node_id            IN       NUMBER
  , p_curr_level         IN       NUMBER
  , p_end_level          IN       NUMBER    := g_max_end_level
  , p_method_code        IN       VARCHAR2
  , p_basis_year         IN       NUMBER
  , x_worksheet_tbl      OUT NOCOPY      worksheet_table_type
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  CURSOR c_get_holdback_info IS
    SELECT fent.formula_entry_operator, fent.formula_entry_value
    FROM   ozf_act_metric_formulas form, ozf_act_metric_form_ent fent
    WHERE  form.activity_metric_id=p_alloc_id
    AND    form.formula_type = 'HOLDBACK'
    AND    form.level_depth = p_curr_level
    AND    form.formula_id = fent.formula_id
    AND    fent.formula_entry_type = 'CONSTANT';

  l_worksheet_rec       worksheet_record_type;
  l_worksheet_tbl       worksheet_table_type;
  l_child_worksheet_tbl worksheet_table_type;
  l_child_node_tbl      node_table_type;
  l_return_status       VARCHAR2(2);
  l_hb_type             VARCHAR2(30);
  l_hb_value            NUMBER;
  l_fact_id             NUMBER;
  l_sum_amount          NUMBER;
  l_tmp_amount          NUMBER;
  l_sum_pct             NUMBER;
  l_tmp_pct             NUMBER;
  l_index               NUMBER          := 1;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_worksheet_rec.node_id := p_node_id;
  l_worksheet_rec.parent_node_id := p_parent_node_id;
  l_worksheet_rec.level_depth := p_curr_level;

  -- compute allocation amount and percentage
  IF (p_sibling_count IS NULL) THEN
     -- top level node
     l_worksheet_rec.total_amount := p_alloc_down_amount;
     l_worksheet_rec.total_pct := 100;
  ELSIF p_alloc_amount IS NOT NULL THEN
     -- last node: alloc amount = parent alloc down amount - sum(sibling alloc amount)
     l_worksheet_rec.total_amount := p_alloc_amount;
     l_worksheet_rec.total_pct := p_alloc_pct;
  ELSE
     -- non top level, non last node
     IF (p_method_code = 'MANUAL') THEN
        l_worksheet_rec.total_amount := NULL;
        l_worksheet_rec.total_pct := NULL;
        l_worksheet_rec.hb_amount := NULL;
        l_worksheet_rec.hb_pct := NULL;
     ELSIF (p_method_code = 'EVEN') THEN
        l_worksheet_rec.total_amount := p_alloc_down_amount / p_sibling_count;
        l_worksheet_rec.total_pct := 100/p_sibling_count;
     ELSIF (p_method_code = 'PRIOR_SALES_TOTAL') THEN
        get_prior_year_sales(p_hierarchy_id       => p_hierarchy_id
                           , p_node_id            => p_node_id
                           , p_basis_year         => p_basis_year
			   , p_alloc_id           => p_alloc_id
			   , x_self_amount        => l_tmp_amount
                           , x_rollup_amount      => l_sum_amount
                           , x_return_status      => l_return_status
                           , x_msg_count          => x_msg_count
                           , x_msg_data           => x_msg_data);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
-- dbms_output.put_line('compute_worksheet: get_prior_year_sales returns' || x_return_status);

        IF (l_sum_amount = 0) THEN
            l_worksheet_rec.total_pct := 0;
        ELSE
            l_worksheet_rec.total_pct := l_tmp_amount / l_sum_amount * 100;
        END IF;

	l_worksheet_rec.total_amount := ROUND((p_alloc_down_amount)*(l_worksheet_rec.total_pct)/100);
     /* for future release
     ELSIF (p_method_code = 'PRIOR_BUDGET' THEN)
     ELSIF (p_method_code = 'PRIOR_BUDGET_SPENT') THEN
      */
     END IF;
  END IF;
-- dbms_output.put_line('compute_worksheet: total_amount=' || l_worksheet_rec.total_amount || ' total_pct=' || l_worksheet_rec.total_pct);

  IF (p_method_code <> 'MANUAL') THEN
      -- compute holdback amount and percentage, for territory and geography only
      l_worksheet_rec.hb_amount := 0;
      l_worksheet_rec.hb_pct := 0;
      IF (p_hierarchy_type = 'TERRITORY' OR p_hierarchy_type = 'GEOGRAPHY') THEN
          OPEN c_get_holdback_info;
          FETCH c_get_holdback_info INTO l_hb_type, l_hb_value;
          CLOSE c_get_holdback_info;

          IF (l_hb_value IS NOT NULL) THEN
              -- holdback information is defined for this level
              IF (l_hb_type = 'PERCENT') THEN
                  -- holdback percentage is defined for this level
                  l_worksheet_rec.hb_amount := l_worksheet_rec.total_amount * l_hb_value / 100;
                  l_worksheet_rec.hb_pct := l_hb_value;
              ELSE
                  -- holdback amount is defined for this level
                  l_worksheet_rec.hb_amount := l_hb_value;
                  IF (l_worksheet_rec.total_amount = 0) THEN
                      l_worksheet_rec.hb_pct := 0;
                  ELSE
                      l_worksheet_rec.hb_pct := l_hb_value/l_worksheet_rec.total_amount * 100;
                  END IF;
              END IF;
          END IF;
      END IF;
  END IF;
-- dbms_output.put_line('compute_worksheet: hb_value=' || l_worksheet_rec.hb_amount || ' hb_total_pct=' || l_worksheet_rec.hb_pct);

  l_worksheet_tbl(l_index) := l_worksheet_rec;
--dbms_output.put_line('compute_woksheet node_id=' || p_node_id || '  level=' || p_curr_level || ' before child table.index=' || l_index || ' COUNT=' || l_worksheet_tbl.COUNT);
  IF (p_curr_level IS NULL OR p_curr_level < p_end_level) THEN
      get_node_children(p_hierarchy_id       => p_hierarchy_id
                      , p_hierarchy_type     => p_hierarchy_type
                      , p_node_id            => p_node_id
                      , x_child_node_tbl     => l_child_node_tbl
                      , x_return_status      => l_return_status
                      , x_msg_count          => x_msg_count
                      , x_msg_data           => x_msg_data
                      );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
--dbms_output.put_line('compute_worksheet: child count=' || l_child_node_tbl.COUNT);

      -- compute worksheet for children. recursive call
      IF (l_child_node_tbl IS NOT NULL AND l_child_node_tbl.COUNT > 0) THEN
         l_sum_amount := 0;
         l_sum_pct := 0;
         FOR I IN l_child_node_tbl.FIRST .. l_child_node_tbl.LAST LOOP
             IF I = l_child_node_tbl.LAST THEN
                l_tmp_amount := l_worksheet_rec.total_amount - l_worksheet_rec.hb_amount - l_sum_amount;
                l_tmp_pct := 100 - l_sum_pct;
             ELSE
                l_tmp_amount := NULL;
                l_tmp_pct := NULL;
             END IF;

             compute_worksheet(p_api_version       => p_api_version
                             , p_alloc_id          => p_alloc_id
                             , p_alloc_down_amount => (l_worksheet_rec.total_amount - l_worksheet_rec.hb_amount)
                             , p_alloc_amount      => l_tmp_amount
                             , p_alloc_pct         => l_tmp_pct
                             , p_parent_node_id    => p_node_id
                             , p_sibling_count     => l_child_node_tbl.COUNT
                             , p_hierarchy_id      => p_hierarchy_id
                             , p_hierarchy_type    => p_hierarchy_type
                             , p_node_id           => l_child_node_tbl(I)
                             , p_curr_level        => (p_curr_level + 1)
                             , p_end_level         => p_end_level
                             , p_method_code       => p_method_code
                             , p_basis_year        => p_basis_year
                             , x_worksheet_tbl     => l_child_worksheet_tbl
                             , x_return_status     => x_return_status
                             , x_msg_count         => x_msg_count
                             , x_msg_data          => x_msg_data
                             );
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             IF (l_child_worksheet_tbl.COUNT IS NOT NULL AND l_child_worksheet_tbl.COUNT > 0) THEN
                l_sum_amount := l_sum_amount + l_child_worksheet_tbl(1).total_amount;
                l_sum_pct := l_sum_pct + l_child_worksheet_tbl(1).total_pct;
                FOR I IN l_child_worksheet_tbl.FIRST .. l_child_worksheet_tbl.LAST LOOP
                    l_index := l_index + 1;
                    l_worksheet_tbl(l_index) := l_child_worksheet_tbl(I);
    -- dbms_output.put_line('compute_worksheet node_id=' || p_node_id || '  level=' || p_curr_level || ' append child table.index=' || l_index || ' COUNT=' || l_worksheet_tbl.COUNT);
                END LOOP;
             END IF;
         END LOOP;  -- end for child loop
      END IF;  -- end IF having child node(s)
  END IF;

  x_worksheet_tbl := l_worksheet_tbl;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    -- dbms_output.put_line('compute_worksheet(node_id=' || p_node_id || '): exception - ' || substr(sqlerrm, 1, 200));
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END compute_worksheet;

---------------------------------------------------------------------
-- PROCEDURE
---   create_alloc_hierarchy
--
-- PURPOSE
--    Create allocation worksheet hierarchy.
--
-- HISTORY
--    05/20/02  yzhao  Created.
--
-- PARAMETERS
---------------------------------------------------------------------
PROCEDURE create_alloc_hierarchy(
    p_api_version        IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2
  , p_commit             IN       VARCHAR2
  , p_alloc_id           IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'create_alloc_hierarchy';
  l_return_status  VARCHAR2(2);
  l_fact_rec       Ozf_Actmetricfact_Pvt.act_metric_fact_rec_type;
  l_fund_id        ozf_act_metrics_all.act_metric_used_by_id%TYPE;
  l_alloc_amount   ozf_act_metrics_all.func_actual_value%TYPE;
  l_hierarchy_id   ozf_act_metrics_all.hierarchy_id%TYPE;
  l_hierarchy_type ozf_act_metrics_all.hierarchy_type%TYPE;
  l_start_node     ozf_act_metrics_all.start_node%TYPE;
  l_from_level     ozf_act_metrics_all.from_level%TYPE;
  l_to_level       ozf_act_metrics_all.to_level%TYPE;
  l_from_date      ozf_act_metrics_all.from_date%TYPE;
  l_to_date        ozf_act_metrics_all.to_date%TYPE;
  l_status_code    ozf_act_metrics_all.status_code%TYPE;
  l_method_code    ozf_act_metrics_all.method_code%TYPE;
  l_basis_year     ozf_act_metrics_all.basis_year%TYPE;
  l_ex_start_node  ozf_act_metrics_all.ex_start_node%TYPE;
  l_fact_id        ozf_act_metric_facts_all.activity_metric_fact_id%TYPE;
  l_worksheet_tbl  worksheet_table_type;

  CURSOR c_get_alloc_details IS
    SELECT act_metric_used_by_id, func_actual_value,
           hierarchy_id, hierarchy_type, start_node, from_level, NVL(to_level, g_max_end_level),
           from_date, to_date, status_code, method_code, basis_year, ex_start_node
    FROM   ozf_act_metrics_all
    WHERE  activity_metric_id = p_alloc_id;

  CURSOR c_get_parent_fact_id(p_node_id NUMBER, p_level_depth NUMBER) IS
    SELECT activity_metric_fact_id
    FROM   ozf_act_metric_facts_all
    WHERE  activity_metric_id = p_alloc_id
    AND    node_id = p_node_id
    AND    level_depth = p_level_depth;

BEGIN
  SAVEPOINT create_alloc_hierarchy_sp;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (fnd_api.to_boolean(p_init_msg_list)) THEN
     fnd_msg_pub.initialize;
  END IF;

  IF (NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)) THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  IF G_DEBUG THEN
     Ozf_Utility_Pvt.Debug_Message('create_alloc_hierarchy() start ');
  END IF;

  OPEN c_get_alloc_details;
  FETCH c_get_alloc_details
  INTO l_fund_id, l_alloc_amount,
       l_hierarchy_id, l_hierarchy_type, l_start_node, l_from_level, l_to_level,
       l_from_date, l_to_date, l_status_code, l_method_code, l_basis_year, l_ex_start_node;
  IF c_get_alloc_details%NOTFOUND THEN
     CLOSE c_get_alloc_details;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
        fnd_msg_pub.add;
     END IF;
     RAISE fnd_api.g_exc_error;
  END IF;
  CLOSE c_get_alloc_details;

  compute_worksheet(p_alloc_id           => p_alloc_id
                  , p_alloc_down_amount  => l_alloc_amount
                  , p_alloc_amount       => NULL
                  , p_alloc_pct          => NULL
                  , p_parent_node_id     => NULL
                  , p_sibling_count      => NULL
                  , p_hierarchy_id       => l_hierarchy_id
                  , p_hierarchy_type     => l_hierarchy_type
                  , p_node_id            => l_start_node
                  , p_curr_level         => l_from_level
                  , p_end_level          => l_to_level
                  , p_method_code        => l_method_code
                  , p_basis_year         => l_basis_year
                  , x_worksheet_tbl      => l_worksheet_tbl
                  , x_return_status      => l_return_status
                  , x_msg_count          => x_msg_count
                  , x_msg_data           => x_msg_data
                    );
  -- dbms_output.put_line('create_alloc_hierarchy: compute_worksheet returns ' || l_return_status || ' fact count=' || l_worksheet_tbl.COUNT);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_worksheet_tbl.COUNT IS NOT NULL AND l_worksheet_tbl.COUNT > 0) THEN
      FOR I IN l_worksheet_tbl.FIRST .. l_worksheet_tbl.LAST LOOP
          l_fact_rec := NULL;
          l_fact_rec.object_version_number := 1;
          l_fact_rec.act_metric_used_by_id := l_fund_id;
          l_fact_rec.arc_act_metric_used_by := 'FUND';
          l_fact_rec.activity_metric_id := p_alloc_id;
          l_fact_rec.status_code := 'NEW';
          l_fact_rec.hierarchy_type := l_hierarchy_type;
          l_fact_rec.hierarchy_id := l_hierarchy_id;
          l_fact_rec.node_id := l_worksheet_tbl(I).node_id;
          l_fact_rec.level_depth := l_worksheet_tbl(I).level_depth;
          l_fact_rec.recommend_total_amount := l_worksheet_tbl(I).total_amount;
          l_fact_rec.base_total_pct := l_worksheet_tbl(I).total_pct;
          l_fact_rec.recommend_hb_amount := l_worksheet_tbl(I).hb_amount;
          l_fact_rec.base_hb_pct := l_worksheet_tbl(I).hb_pct;
          l_fact_rec.fact_value := 0;  -- I'm not using fact_value, but it is a required field for fact table
          l_fact_rec.previous_fact_id := NULL;
          OPEN c_get_parent_fact_id(l_worksheet_tbl(I).parent_node_id, l_worksheet_tbl(I).level_depth-1);
          FETCH c_get_parent_fact_id INTO l_fact_rec.previous_fact_id;
          CLOSE c_get_parent_fact_id;

          -- yzhao: 02/18/2003 set fact type as 'EXCLUDE' if start node is excluded
          IF l_fact_rec.previous_fact_id IS NULL AND l_ex_start_node = 'Y' THEN
             l_fact_rec.fact_type := 'EXCLUDE';
          END IF;

          -- write fact record to table
          OZF_ActMetricFact_PVT.Create_ActMetricFact
                 ( p_api_version              => p_api_version
                 , x_return_status            => l_return_status
                 , x_msg_count                => x_msg_count
                 , x_msg_data                 => x_msg_data
                 , p_act_metric_fact_rec      => l_fact_rec
                 , x_activity_metric_fact_id  => l_fact_id
                 );
  -- dbms_output.put_line('create_alloc_herarchy: create_actmetricfact returns ' || l_return_status || '  fact_id=' || l_fact_id);
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO create_alloc_hierarchy_sp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- dbms_output.put_line('create_alloc_hierarchy: exception - ' || substr(sqlerrm, 1, 200));
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END create_alloc_hierarchy;


---------------------------------------------------------------------
-- PROCEDURE
---   create_budget_for_one_node
--
-- PURPOSE
--    Create budget for one node,
--    copy root budget's market and product eligibility
--    grant allocator access to the budget
--    private api called by publish_allocation() only
--
-- HISTORY
--    05/30/02  yzhao  Created.
--
-- PARAMETERS
---------------------------------------------------------------------
PROCEDURE create_budget_for_one_node(
    p_api_version        IN       NUMBER    := 1.0
  , p_fund_id            IN       NUMBER
  , p_resource_id        IN       NUMBER    := NULL
  , p_fund_rec           IN       ozf_funds_pvt.fund_rec_type
  , x_fund_id            OUT NOCOPY      NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
) IS
  l_new_fund_id               NUMBER;
  l_return_id                 NUMBER;
  l_return_status             VARCHAR2(2);
  -- for non-standard out params in copy_act_access
  l_errnum                    NUMBER;
  l_errcode                   VARCHAR2(30);
  l_errmsg                    VARCHAR2(4000);
  l_access_exists             NUMBER;
  l_access_rec                ams_access_pvt.access_rec_type;
  l_mktelig_rec               ams_act_market_segments_pvt.mks_rec_type;
  l_segments_rec              ams_act_market_segments_pvt.mks_rec_type;
  l_terr_resource_id          NUMBER;
  l_terr_resource_type        jtf_terr_rsc_all.resource_type%TYPE;
  l_access_type               ams_act_access.arc_user_or_role_type%TYPE;

  CURSOR c_check_access_exists(p_fund_id NUMBER, p_resource_id NUMBER, p_resource_type VARCHAR2) IS
  SELECT 1
    FROM ams_act_access
   WHERE act_access_to_object_id = p_fund_id
      AND arc_act_access_to_object = 'FUND'
      AND user_or_role_id = p_resource_id
      AND arc_user_or_role_type = p_resource_type
      AND delete_flag = 'N';

--R12 - Modified for Primary Contact - bug 4643041
  CURSOR c_get_territory_resource(p_terr_id NUMBER, p_primary_flag VARCHAR2) IS
     SELECT jtra.resource_id, jtra.resource_type
     FROM   jtf_terr_rsc_all jtra,
            jtf_terr_rsc_access_all jtraa
--     WHERE  primary_contact_flag = p_primary_flag
     WHERE jtraa.terr_rsc_id = jtra.terr_rsc_id
       AND jtraa.access_type = 'OFFER'
       AND DECODE(jtraa.trans_access_code,'PRIMARY_CONTACT','Y','NONE','N','DEFAULT','N','N')=p_primary_flag
       AND jtra.terr_id = p_terr_id;

  CURSOR c_check_marketelig_unique(p_market_id NUMBER, p_fund_id NUMBER) IS
      SELECT 1
      FROM   ams_act_market_segments
      WHERE  arc_act_market_segment_used_by = 'FUND'
        AND  act_market_segment_used_by_id = p_fund_id
        AND  market_segment_id = p_market_id
        AND  segment_type = 'TERRITORY';

   CURSOR c_segments_cur(p_fund_id NUMBER, p_hierarchy_id NUMBER) IS
      SELECT *
        FROM ams_act_market_segments seg
      WHERE  arc_act_market_segment_used_by = 'FUND'
        AND  act_market_segment_used_by_id = p_fund_id
        AND  (segment_type <> 'TERRITORY'
         OR  (segment_type = 'TERRITORY'
              AND NOT EXISTS (SELECT 1 FROM ozf_terr_v WHERE hierarchy_id = p_hierarchy_id AND node_id = seg.market_segment_id))
             );

BEGIN
  SAVEPOINT create_budget_for_one_node_sp;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- create child fund for the node
  ozf_funds_pvt.create_fund( p_api_version       => p_api_version
                           , p_init_msg_list     => fnd_api.g_false
                           , p_commit            => fnd_api.g_false
                           , p_validation_level  => fnd_api.g_valid_level_full
                           , x_return_status     => l_return_status
                           , x_msg_count         => x_msg_count
                           , x_msg_data          => x_msg_data
                           , p_fund_rec          => p_fund_rec
                           , x_fund_id           => l_new_fund_id
                           );
-- dbms_output.put_line('create_budget_for_one_node(): create fund for node returns ' || l_return_status);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_resource_id IS NOT NULL THEN
     l_access_exists := NULL;
     OPEN c_check_access_exists(l_new_fund_id, p_resource_id, 'USER');
     FETCH c_check_access_exists INTO l_access_exists;
     CLOSE c_check_access_exists;

     IF l_access_exists IS NULL THEN
        -- add allocator to fund access list if s/he is not owner
         l_access_rec.act_access_to_object_id := l_new_fund_id;
         l_access_rec.arc_act_access_to_object := 'FUND';
         l_access_rec.user_or_role_id := p_resource_id;
         l_access_rec.arc_user_or_role_type := 'USER';
         l_access_rec.admin_flag := 'Y';
         l_access_rec.owner_flag := 'N';
         ams_access_pvt.create_access(
                 p_api_version       => p_api_version
               , p_init_msg_list     => fnd_api.g_true
               , p_validation_level  => fnd_api.g_valid_level_full
               , p_commit            => fnd_api.g_false
               , p_access_rec        => l_access_rec
               , x_return_status     => l_return_status
               , x_msg_count         => x_msg_count
               , x_msg_data          => x_msg_data
               , x_access_id         => l_return_id
               );
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
  END IF;

  l_terr_resource_type := NULL;
  OPEN c_get_territory_resource(p_fund_rec.node_id, 'Y');
  FETCH c_get_territory_resource INTO l_terr_resource_id, l_terr_resource_type;
  CLOSE c_get_territory_resource;

  /* yzhao: 04/08/2003 fix bug 2897460 - if territory node's primary contact is group, grant access to the group */
  IF l_terr_resource_type IS NOT NULL AND l_terr_resource_type = G_RS_GROUP_TYPE THEN
     l_access_exists := NULL;
     OPEN c_check_access_exists(l_new_fund_id, l_terr_resource_id, 'GROUP');
     FETCH c_check_access_exists INTO l_access_exists;
     CLOSE c_check_access_exists;
     IF l_access_exists IS NULL THEN
        l_access_rec.act_access_to_object_id := l_new_fund_id;
        l_access_rec.arc_act_access_to_object := 'FUND';
        l_access_rec.user_or_role_id := l_terr_resource_id;
        l_access_rec.arc_user_or_role_type := 'GROUP';
        l_access_rec.admin_flag := 'N';
        l_access_rec.owner_flag := 'N';
        ams_access_pvt.create_access(
             p_api_version       => p_api_version
           , p_init_msg_list     => fnd_api.g_true
           , p_validation_level  => fnd_api.g_valid_level_full
           , p_commit            => fnd_api.g_false
           , x_return_status     => l_return_status
           , x_msg_count         => x_msg_count
           , x_msg_data          => x_msg_data
           , p_access_rec        => l_access_rec
           , x_access_id         => l_return_id
           );
        IF l_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
     END IF;
  END IF;

  /* yzhao: 12/27/2002 grant fund access to territory node's non-primary contacts */
  FOR resource_rec IN c_get_territory_resource(p_fund_rec.node_id, 'N') LOOP
      l_access_exists := NULL;
      IF resource_rec.resource_type = G_RS_EMPLOYEE_TYPE THEN
         l_access_type := 'USER';
      ELSE
         l_access_type := 'GROUP';
      END IF;
      OPEN c_check_access_exists(l_new_fund_id, resource_rec.resource_id, l_access_type);
      FETCH c_check_access_exists INTO l_access_exists;
      CLOSE c_check_access_exists;
      /* yzhao: 12/27/2002 fix bug 2728235 create access for sales representative only if he has no access to the budget.
       *        if s/he is one of its ancestor budget owner, create_access() returns error. So check beforehand to avoid that
       */
      IF l_access_exists IS NULL THEN
         l_access_rec.act_access_to_object_id := l_new_fund_id;
         l_access_rec.arc_act_access_to_object := 'FUND';
         l_access_rec.user_or_role_id := resource_rec.resource_id;
         l_access_rec.arc_user_or_role_type := l_access_type;
         l_access_rec.admin_flag := 'N';
         l_access_rec.owner_flag := 'N';
         ams_access_pvt.create_access(
                 p_api_version       => p_api_version
               , p_init_msg_list     => fnd_api.g_true
               , p_validation_level  => fnd_api.g_valid_level_full
               , p_commit            => fnd_api.g_false
               , x_return_status     => l_return_status
               , x_msg_count         => x_msg_count
               , x_msg_data          => x_msg_data
               , p_access_rec        => l_access_rec
               , x_access_id         => l_return_id
         );
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
  END LOOP;

  /* yzhao: child budget inherits its parent's market eligibility and product eligibility
            fix bug 3384488, however if root budget has the territory root this allocation is created for, the child should not inherit it
   */
  -- copy root budget's market eligibility:
  /* l_errnum := 0;
     l_errcode := NULL;
     l_errmsg := NULL;
     ams_copyelements_pvt.copy_act_market_segments (
         p_src_act_type   => 'FUND',
         p_new_act_type   => 'FUND',
         p_src_act_id     => p_fund_id,
         p_new_act_id     => l_new_fund_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
  );
-- dbms_output.put_line(l_full_name || 'create market eligibility for new fund(' || l_child_fund_id || ') returns ' || l_errnum || ' errcode=' || l_errcode || ' errmsg=' || l_errmsg);
  IF (l_errnum <> 0) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  */

  FOR segments_rec IN c_segments_cur(p_fund_id, p_fund_rec.hierarchy_id) LOOP
      l_segments_rec.object_version_number := 1;
      l_segments_rec.act_market_segment_used_by_id := l_new_fund_id;
      l_segments_rec.arc_act_market_segment_used_by := 'FUND';
      l_segments_rec.market_segment_id := segments_rec.market_segment_id;
      l_segments_rec.attribute_category := segments_rec.attribute_category;
      l_segments_rec.attribute1 := segments_rec.attribute1;
      l_segments_rec.attribute2 := segments_rec.attribute2;
      l_segments_rec.attribute3 := segments_rec.attribute3;
      l_segments_rec.attribute4 := segments_rec.attribute4;
      l_segments_rec.attribute5 := segments_rec.attribute5;
      l_segments_rec.attribute6 := segments_rec.attribute6;
      l_segments_rec.attribute7 := segments_rec.attribute7;
      l_segments_rec.attribute8 := segments_rec.attribute8;
      l_segments_rec.attribute9 := segments_rec.attribute9;
      l_segments_rec.attribute10 := segments_rec.attribute10;
      l_segments_rec.attribute11 := segments_rec.attribute11;
      l_segments_rec.attribute12 := segments_rec.attribute12;
      l_segments_rec.attribute13 := segments_rec.attribute13;
      l_segments_rec.attribute14 := segments_rec.attribute14;
      l_segments_rec.attribute15 := segments_rec.attribute15;
      l_segments_rec.segment_type := segments_rec.segment_type;
      l_segments_rec.exclude_flag := segments_rec.exclude_flag;
      l_segments_rec.group_code   := segments_rec.group_code;
      ams_act_market_segments_pvt.create_market_segments (
           p_api_version       => p_api_version
         , p_init_msg_list     => fnd_api.g_true
         , p_commit            => fnd_api.g_false
         , p_validation_level  => fnd_api.g_valid_level_full
         , x_return_status     => l_return_status
         , x_msg_count         => x_msg_count
         , x_msg_data          => x_msg_data
         ,  p_mks_rec          => l_segments_rec
         ,  x_act_mks_id       => l_return_id
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END LOOP;


  -- copy root budget's product eligibility
  l_errnum := 0;
  l_errcode := NULL;
  l_errmsg := NULL;
  ams_copyelements_pvt.copy_act_prod (
         p_src_act_type  => 'FUND',
         p_new_act_type  => 'FUND',
         p_src_act_id    => p_fund_id,
         p_new_act_id    => l_new_fund_id,
         p_errnum        => l_errnum,
         p_errcode       => l_errcode,
         p_errmsg        => l_errmsg
  );
-- dbms_output.put_line(l_full_name || 'create product eligibility for new fund(' || l_child_fund_id || ') returns ' || l_errnum || ' errcode=' || l_errcode || ' errmsg=' || l_errmsg);
  IF (l_errnum <> 0) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* yzhao: 04/09/2002 fix bug 2653078: 1158.9FP:MAPREL68: ALLOCATED BUDGET DOES NOT SHOW TERRITORY UNDER MARKET ELIGIBI */
  l_errnum := NULL;
  OPEN c_check_marketelig_unique(p_fund_rec.node_id, l_new_fund_id);
  FETCH c_check_marketelig_unique INTO l_errnum;
  CLOSE c_check_marketelig_unique;
  -- add territory market eligibility to fund if it's not there
  IF l_errnum IS NULL THEN
     l_mktelig_rec.market_segment_id := p_fund_rec.node_id;
     l_mktelig_rec.arc_act_market_segment_used_by := 'FUND';
     l_mktelig_rec.act_market_segment_used_by_id := l_new_fund_id;
     l_mktelig_rec.segment_type := 'TERRITORY';
     l_mktelig_rec.exclude_flag := 'N';
     l_mktelig_rec.group_code := 'TERRITORY' || p_fund_rec.node_id;
     ams_act_market_segments_pvt.create_market_segments(
                       p_api_version       => p_api_version
                     , p_init_msg_list     => fnd_api.g_true
                     , p_commit            => fnd_api.g_false
                     , p_validation_level  => fnd_api.g_valid_level_full
                     , x_return_status     => l_return_status
                     , x_msg_count         => x_msg_count
                     , x_msg_data          => x_msg_data
                     , p_mks_rec           => l_mktelig_rec
                     , x_act_mks_id        => l_errnum
              );
     -- dbms_output.put_line('create_market_segments returns ' || l_return_status);
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;
  /* yzhao: 11/01/2002 fix bug 2653078 ends */

  x_fund_id := l_new_fund_id;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO create_budget_for_one_node_sp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    -- dbms_output.put_line('create_budget_for_one_node(): exception - ' || substr(sqlerrm, 1, 200));
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END create_budget_for_one_node;


----------------------------------------------------------------------------------------
-- This Procedure will create approved budget transfer from parent to child           --
--   Private api called by activate_one_node() and publish_allocation()               --
--           for allocation action code 'TRANSFER_TO_BUDGET' only                     --
--   Action: create an approved actbudget transfer from parent to child               --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_child_fund_id            the child fund id                                       --
-- p_approved_total           approved total amount                                   --
----------------------------------------------------------------------------------------
Procedure transfer_approved_budget(p_api_version         IN     NUMBER    := 1.0,
                                   p_child_fund_id       IN     NUMBER,
                                   p_approved_total      IN     NUMBER,
                                   x_return_status       OUT NOCOPY    VARCHAR2,
                                   x_msg_count           OUT NOCOPY    NUMBER,
                                   x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_return_status            VARCHAR2(2);
  l_parent_fund_id           NUMBER;
  l_requestor_id             NUMBER;
  l_act_budget_id            NUMBER;
  l_act_budget_rec           ozf_actbudgets_pvt.act_budgets_rec_type;

  CURSOR c_get_fund_owner(p_fund_id NUMBER) IS
    SELECT owner, parent_fund_id
    FROM   ozf_funds_all_b
    WHERE  fund_id = p_fund_id;

BEGIN
  OPEN c_get_fund_owner(p_child_fund_id);
  FETCH c_get_fund_owner INTO l_requestor_id, l_parent_fund_id;
  CLOSE c_get_fund_owner;

  -- first create a NEW actbudget transfer record
  l_act_budget_rec.status_code := 'NEW';
  l_act_budget_rec.user_status_id :=
        ozf_utility_pvt.get_default_user_status('OZF_BUDGETSOURCE_STATUS', l_act_budget_rec.status_code);
  l_act_budget_rec.arc_act_budget_used_by := 'FUND';
  l_act_budget_rec.act_budget_used_by_id := p_child_fund_id;
  l_act_budget_rec.requester_id := l_requestor_id;
  l_act_budget_rec.request_amount := p_approved_total;   --- in transferring to fund currency
  l_act_budget_rec.budget_source_type := 'FUND';
  l_act_budget_rec.budget_source_id := l_parent_fund_id;
  l_act_budget_rec.justification := null;
  l_act_budget_rec.transfer_type := 'TRANSFER';
  l_act_budget_rec.transaction_type := null;
  ozf_actbudgets_pvt.create_act_budgets(
         p_api_version     => p_api_version
       , p_act_budgets_rec => l_act_budget_rec
       , x_return_status   => l_return_status
       , x_msg_count       => x_msg_count
       , x_msg_data        => x_msg_data
       , x_act_budget_id   => l_act_budget_id);
-- dbms_output.put_line('transfer_approved_budget: create_act_Budget returns ' || l_return_status || ' act_budget_id=' || l_act_budget_id);
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- update actbudget record as APPROVED
  ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budget_rec);
  l_act_budget_rec.activity_budget_id := l_act_budget_id;
  l_act_budget_rec.object_version_number := 1;
  l_act_budget_rec.status_code := 'APPROVED';
  l_act_budget_rec.approved_amount := p_approved_total;
  l_act_budget_rec.user_status_id :=
     ozf_utility_pvt.get_default_user_status('OZF_BUDGETSOURCE_STATUS', l_act_budget_rec.status_code);
  ozf_actbudgets_pvt.update_act_budgets(
      p_api_version            => p_api_version
    , p_init_msg_list          => fnd_api.g_true
    , p_commit                 => fnd_api.g_false
    , p_act_budgets_rec        => l_act_budget_rec
    , p_child_approval_flag    => fnd_api.g_false       -- false since child budget already active
    , p_requestor_owner_flag   => 'Y'                   -- set it to bypass approval
    , x_return_status          => l_return_status
    , x_msg_count              => x_msg_count
    , x_msg_data               => x_msg_data);
-- dbms_output.put_line('transfer_approved_budget: update_act_Budget approved returns ' || l_return_status || ' act_budget_id=' || l_act_budget_id);
  IF l_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;


EXCEPTION
  WHEN OTHERS THEN
-- dbms_output.put_line('transfer_approved_budget: exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END transfer_approved_budget;


----------------------------------------------------------------------------------------
-- This Procedure will publish allocation worksheet                                   --
--   create draft or active child funds for the allocation                            --
--          child funds inherit parent funds's market and product eligibity           --
--   OR transfer budget to existing budget                                            --
--   update node status as 'ACTIVE' or 'PLANNED'                                      --
--   send notification to child budget owner                                          --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_alloc_id      allocation id in ozf_act_metrics_all table                         --
-- p_alloc_status  new allocation status, either 'PLANNED' or 'ACTIVE'                --
----------------------------------------------------------------------------------------
Procedure publish_allocation(p_api_version         IN     NUMBER,
                             p_init_msg_list       IN     VARCHAR2,
                             p_commit              IN     VARCHAR2,
                             p_validation_level    IN     NUMBER,
                             p_alloc_id            IN     NUMBER,
                             p_alloc_status        IN     VARCHAR2,
                             p_alloc_obj_ver       IN     NUMBER,
                             x_return_status       OUT NOCOPY    VARCHAR2,
                             x_msg_count           OUT NOCOPY    NUMBER,
                             x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_index                     NUMBER;
  l_return_id                 NUMBER;
  l_full_name                 VARCHAR2(120) := g_pkg_name || ': publish_allocation() ';
  l_return_status             VARCHAR2(2);
  l_resource_id               NUMBER;
  l_alloc_status              VARCHAR2(30);
  l_alloc_from_date           DATE := NULL;
  l_alloc_to_date             DATE := NULL;
  l_alloc_action_code         VARCHAR2(30);
  l_alloc_fund_status         VARCHAR2(30);
  l_fund_id                   NUMBER;
  l_fund_owner                NUMBER;
  l_fund_start_date           DATE := NULL;
  l_fund_currency             VARCHAR2(15);
  l_fund_type                 VARCHAR2(30);
  l_fund_org_id               NUMBER;
  l_fund_ledger_id            NUMBER;
  l_fund_dept_id              NUMBER;
  l_fund_short_name           ozf_funds_all_tl.short_name%TYPE;
  l_fund_status_code          ozf_funds_all_b.status_code%TYPE;
  l_fund_number               ozf_funds_all_b.fund_number%TYPE;
  l_fund_category_id          NUMBER;
  l_fund_cust_setup_id        NUMBER;
  l_parent_fund_id            NUMBER;
  l_parent_fund_owner         NUMBER;
  l_child_fund_id             NUMBER;
  l_child_fund_owner          NUMBER;
  l_child_fund_name           VARCHAR2(240);
  l_tmp_id                    NUMBER;
  l_tmp_char                  VARCHAR2(1);
  l_notif_subject             VARCHAR2(400);
  l_notif_body                VARCHAR2(4000);
  l_node_info                 node_info_type;
  l_fund_rec                  ozf_funds_pvt.fund_rec_type;
  l_metric_rec                ozf_actmetric_pvt.act_metric_rec_type;
  l_metric_fact_rec           ozf_actmetricfact_Pvt.act_metric_fact_rec_type;
  l_fund_id_table             fundIdTableType;
  l_temp_status               VARCHAR2(1);
  l_fund_meaning              VARCHAR2(240) := NULL;

  CURSOR c_get_metric_info IS
     SELECT act_metric_used_by_id, from_date, to_date, action_code
     FROM   ozf_act_metrics_all
     WHERE  activity_metric_id = p_alloc_id;

  CURSOR c_get_fund_info(p_fund_id NUMBER) IS
     SELECT fu.owner, fu.start_date_active, fu.currency_code_tc, fu.fund_type,
            fu.org_id, fu.ledger_id, fu.department_id, fu.short_name, fu.status_code,
            fu.fund_number, fu.category_id, fu.custom_setup_id
     FROM ozf_funds_all_vl fu
     where fund_id = p_fund_id;

  CURSOR c_get_fund_owner(p_fund_id NUMBER) IS
    SELECT owner, short_name
    FROM   ozf_funds_all_vl
    WHERE  fund_id = p_fund_id;

  CURSOR c_get_res_id IS
     SELECT resource_id
     FROM   ams_jtf_rs_emp_v
     WHERE  user_id = FND_GLOBAL.User_Id;

  CURSOR c_get_worksheet_info(p_fund_id NUMBER) IS
     SELECT activity_metric_fact_id, object_version_number,
            hierarchy_id, hierarchy_type, level_depth, node_id, previous_fact_id,
            recommend_total_amount, recommend_hb_amount, fact_type
     FROM   ozf_act_metric_facts_all
     WHERE  act_metric_used_by_id = p_fund_id
     AND    arc_act_metric_used_by = 'FUND'
     AND    activity_metric_id = p_alloc_id
     AND    status_code = 'NEW'
     ORDER BY level_depth, node_id;

  CURSOR c_get_user_status_id(p_status_code VARCHAR2) IS
     SELECT user_status_id
     FROM   ams_user_statuses_vl
     WHERE  UPPER(system_status_code) = UPPER(p_status_code)
     AND    system_status_type = 'OZF_FUND_STATUS'
     AND    enabled_flag = 'Y';

BEGIN

  SAVEPOINT publish_allocation_sp;
  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message(l_full_name || ': start');
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;

  OPEN c_get_metric_info;
  FETCH c_get_metric_info INTO l_fund_id, l_alloc_from_date, l_alloc_to_date, l_alloc_action_code;
  CLOSE c_get_metric_info;

  OPEN c_get_fund_info(l_fund_id);
  FETCH c_get_fund_info INTO l_fund_owner, l_fund_start_date, l_fund_currency, l_fund_type,
                             l_fund_org_id, l_fund_ledger_id, l_fund_dept_id, l_fund_short_name, l_fund_status_code,
                             l_fund_number, l_fund_category_id, l_fund_cust_setup_id;
  CLOSE c_get_fund_info;

  /* TO DO: add 'DRAFT_ALLOC' to lookup OZF_FUND_STATUS and add use_status_id */
  IF (p_alloc_status = 'ACTIVE') THEN
      IF l_fund_status_code <> 'ACTIVE' THEN
         -- can not make allocaiton active if root budget is not active
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             IF (l_fund_type = 'QUOTA') THEN
               FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_ALLOCACTIVE_ERROR');
             ELSE
               FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_ALLOCACTIVE_ERROR');
             END IF;
            FND_MSG_PUB.Add;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_alloc_fund_status := p_alloc_status;
      l_alloc_status := p_alloc_status;
  ELSE
      l_alloc_fund_status := 'DRAFT';   -- remember to change to 'DRAFT_ALLOC'
      l_alloc_status := 'PLANNED';
  END IF;

  l_fund_short_name := l_fund_short_name || '-' || p_alloc_id;
  /* use allocation start date. If it is null, use budget's start date.
     always use allocation end date */
  IF l_alloc_from_date IS NULL THEN
     l_alloc_from_date := l_fund_start_date;
  END IF;

  OPEN c_get_res_id;
  FETCH c_get_res_id INTO l_resource_id;
  CLOSE c_get_res_id;

  l_index := 1;
  FOR l_worksheet_rec IN c_get_worksheet_info(l_fund_id) LOOP
-- dbms_output.put_line(l_full_name || 'index=' || l_index);
     ozf_actmetricfact_pvt.init_actmetricfact_rec(l_metric_fact_rec);
     IF (l_alloc_action_code = 'TRANSFER_TO_BUDGET') THEN
         -- add onto existing budget
         l_child_fund_id := l_worksheet_rec.node_id;
         OPEN c_get_fund_owner(l_child_fund_id);
         FETCH c_get_fund_owner INTO l_child_fund_owner, l_child_fund_name;
         CLOSE c_get_fund_owner;

         IF (l_alloc_status = 'ACTIVE') THEN
             -- create budget transfer record from parent to child if it is active
             -- however do not create transfer if it's top level and exclude start flag is ON
             IF l_worksheet_rec.fact_type IS NULL OR
                l_worksheet_rec.fact_type <> 'EXCLUDE' THEN
                transfer_approved_budget(p_api_version          => p_api_version
                                       , p_child_fund_id        => l_child_fund_id
                                       , p_approved_total       => l_worksheet_rec.recommend_total_amount
                                       , x_return_status        => l_return_status
                                       , x_msg_count            => x_msg_count
                                       , x_msg_data             => x_msg_data
                                        );
                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;
         END IF;  -- IF (l_alloc_status = 'ACTIVE') THEN
     ELSE
         -- create new budget
         l_parent_fund_id := NULL;
         IF l_worksheet_rec.previous_fact_id IS NULL THEN
            -- top level node
            l_parent_fund_id := l_fund_id;
            l_parent_fund_owner := l_fund_owner;
            IF l_worksheet_rec.fact_type = 'EXCLUDE' THEN
               -- do not create budget for start node if it is excluded
               l_index := l_index + 1;
               l_fund_id_table(l_index).fact_id := l_worksheet_rec.activity_metric_fact_id;
               l_fund_id_table(l_index).fund_id := l_fund_id;
               l_fund_id_table(l_index).owner := l_fund_owner;
               l_child_fund_id := l_fund_id;
               l_child_fund_owner := l_fund_owner;
               GOTO LOOP_UPDATE_STATUS;
            END IF;
         ELSE
            /* non-top level: find parent fund id */
            FOR I IN l_fund_id_table.FIRST .. l_fund_id_table.LAST LOOP
              IF l_fund_id_table(I).fact_id = l_worksheet_rec.previous_fact_id THEN
                 l_parent_fund_id := l_fund_id_table(I).fund_id;
                 l_parent_fund_owner := l_fund_id_table(I).owner;
                 EXIT;
              END IF;
            END LOOP;
         END IF;

         get_node_info( p_hierarchy_id       => l_worksheet_rec.hierarchy_id
                      , p_hierarchy_type     => l_worksheet_rec.hierarchy_type
                      , p_node_id            => l_worksheet_rec.node_id
                      , x_node_info          => l_node_info
                      , x_return_status      => l_return_status
                      , x_msg_count          => x_msg_count
                      , x_msg_data           => x_msg_data
                      );

         /* use parent fund owner if the node has no primary contact */
         IF l_node_info.owner IS NULL THEN
            l_node_info.owner := l_fund_owner;
         END IF;
         l_fund_rec.owner := l_node_info.owner;
         l_fund_rec.parent_node_id := l_node_info.parent_node_id;
         l_fund_rec.short_name := substr(l_fund_short_name || '-' || l_node_info.node_name, 1, 80);
         l_child_fund_name := l_fund_rec.short_name;
         l_fund_rec.parent_fund_id := l_parent_fund_id;
	 --kpatro 26/09/2006  fix bug 5569140
         l_fund_rec.category_id := l_fund_category_id;
         l_fund_rec.fund_number := substr(ams_sourcecode_pvt.get_source_code( p_category_id    => l_fund_rec.category_id
                                                                             , p_arc_object_for => 'FUND'), 1, 30);
         l_fund_rec.original_budget := l_worksheet_rec.recommend_total_amount;
         l_fund_rec.holdback_amt := l_worksheet_rec.recommend_hb_amount;
         l_fund_rec.hierarchy_id := l_worksheet_rec.hierarchy_id;
         l_fund_rec.node_id := l_worksheet_rec.node_id;
         l_fund_rec.hierarchy_level := l_worksheet_rec.level_depth;
         l_fund_rec.status_code := l_alloc_fund_status;
         OPEN c_get_user_status_id(l_fund_rec.status_code);
         FETCH c_get_user_status_id INTO l_fund_rec.user_status_id;
         CLOSE c_get_user_status_id;
         l_fund_rec.currency_code_tc := l_fund_currency;
         l_fund_rec.org_id := l_fund_org_id;
         l_fund_rec.ledger_id := l_fund_ledger_id;
         l_fund_rec.department_id := l_fund_dept_id;
         l_fund_rec.custom_setup_id := l_fund_cust_setup_id;
         l_fund_rec.fund_type := l_fund_type;
         l_fund_rec.start_date_active := l_alloc_from_date;
         l_fund_rec.end_date_active := l_alloc_to_date;
         l_fund_rec.fund_usage := 'ALLOC';           -- set special flag for budgets created by allocation

    -- dbms_output.put_line(l_full_name || ' about to create fund for node ' || l_node_info.node_name || ' owner=' || l_fund_rec.owner );
    -- dbms_output.put_line('    parent_fund_id=' || l_fund_rec.parent_fund_id || ' status=' || l_fund_rec.status_code);

         /* add the allocator to the access list if it's neither this budget owner nor the parent budget owner
          * ozf_funds_pvt.create_fund() takes care of parent budget owner's access
          */
         IF l_resource_id = l_fund_rec.owner OR
            l_resource_id = l_parent_fund_owner THEN
            l_resource_id := NULL;
         END IF;

         -- create child fund for the node
         create_budget_for_one_node(p_api_version       => p_api_version
                                  , p_fund_id           => l_fund_id
                                  , p_resource_id       => l_resource_id
                                  , p_fund_rec          => l_fund_rec
                                  , x_fund_id           => l_child_fund_id
                                  , x_return_status     => l_return_status
                                  , x_msg_count         => x_msg_count
                                  , x_msg_data          => x_msg_data
                                  );
    -- dbms_output.put_line(l_full_name || ' create fund for node ' || l_node_info.node_name || ' returns ' || l_return_status || '  new fund id=' || l_child_fund_id);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_index := l_index + 1;
         l_fund_id_table(l_index).fact_id := l_worksheet_rec.activity_metric_fact_id;
         l_fund_id_table(l_index).fund_id := l_child_fund_id;
         l_fund_id_table(l_index).owner := l_fund_rec.owner;
         l_child_fund_owner := l_fund_rec.owner;
     END IF;  -- IF p_alloc_action = 'TRANSFER_TO_BUDGET'

     <<LOOP_UPDATE_STATUS>>
     /* update fact table used_by_id as the child budget id, set status as ACTIVE or PLANNED */
     l_metric_fact_rec.activity_metric_fact_id := l_worksheet_rec.activity_metric_fact_id;
     l_metric_fact_rec.object_version_number := l_worksheet_rec.object_version_number;
     l_metric_fact_rec.act_metric_used_by_id := l_child_fund_id;
     l_metric_fact_rec.status_code := l_alloc_status;
     IF (l_alloc_status = 'ACTIVE') THEN
         -- for active publish, set actual_total_amount, actual_hb_amount, approval_date
         l_metric_fact_rec.actual_total_amount := l_worksheet_rec.recommend_total_amount;
         l_metric_fact_rec.actual_hb_amount := NVL(l_worksheet_rec.recommend_hb_amount, 0);
         l_metric_fact_rec.approval_date := sysdate;
     END IF;
     ozf_actmetricfact_Pvt.Update_ActMetricFact( p_api_version                => p_api_version
                         , p_init_msg_list              => FND_API.G_FALSE
                         , p_commit                     => FND_API.G_FALSE
                         , p_validation_level           => p_validation_level
                         , x_return_status              => l_return_status
                         , x_msg_count                  => x_msg_count
                         , x_msg_data                   => x_msg_data
                         , p_act_metric_fact_rec        => l_metric_fact_rec
                         );
-- dbms_output.put_line(l_full_name || 'update metric fact status ' || l_return_status);
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /* send notification to child budget owner */
     IF l_fund_type = 'QUOTA' THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'QUOTA',
                            x_return_status => l_temp_status,
                            x_meaning       => l_fund_meaning);
      ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
        ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                            p_lookup_code   => 'BUDGET',
                            x_return_status => l_temp_status,
                            x_meaning       => l_fund_meaning);
      END IF;
     fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_PUBLISH_SUB');
     fnd_message.set_token('BUDGET_NAME', l_child_fund_name);
     fnd_message.set_token('ALLOC_ID', p_alloc_id);
     fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
     l_notif_subject := substrb(fnd_message.get, 1, 400);
     fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_PUBLISH_BODY');
     fnd_message.set_token ('BUDGET_NAME', l_child_fund_name);
     fnd_message.set_token ('ALLOC_ID', p_alloc_id);
     fnd_message.set_token ('ALLOC_STATUS', l_alloc_status);
     fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
     l_notif_body := substrb(fnd_message.get, 1, 4000);

     ozf_utility_pvt.send_wf_standalone_message(
        p_subject            =>  l_notif_subject
      , p_body               =>  l_notif_body
      , p_send_to_res_id     =>  l_child_fund_owner
      , x_notif_id           =>  l_return_id
      , x_return_status      =>  l_return_status
      );
-- dbms_output.put_line(l_full_name || 'send notificaiton returns ' || l_return_status);
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  END LOOP;

  /* set allocation as 'PLANNED' or 'ACTIVE' */
  Ozf_Actmetric_Pvt.Init_ActMetric_Rec(l_metric_rec);
  l_metric_rec.activity_metric_id := p_alloc_id;
  l_metric_rec.status_code := l_alloc_status;
  l_metric_rec.object_version_number := p_alloc_obj_ver;
  IF l_alloc_status = 'ACTIVE' THEN
     -- set approval date.
     l_metric_rec.act_metric_date := sysdate;
  END IF;

  /* it is important not to do some validation since allocation amount already deducted from fund,
     so validation will fail. should < jtf_plsql_api.G_VALID_LEVEL_RECORD CONSTANT NUMBER:= 80.
     set to 70 here.
   */
   Ozf_Actmetric_Pvt.update_Actmetric( p_api_version    => p_api_version
                                     , p_init_msg_list     => FND_API.G_FALSE
                                     , p_commit            => FND_API.G_FALSE
                                     , p_validation_level  => 70
                                     , x_return_status     => l_return_status
                                     , x_msg_count         => x_msg_count
                                     , x_msg_data          => x_msg_data
                                     , p_act_metric_rec    => l_metric_rec
                                     );
-- dbms_output.put_line(l_full_name || 'set new alloc status returns ' || l_return_status);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     commit;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
-- dbms_output.put_line(l_full_name || 'exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      ROLLBACK TO publish_allocation_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

END publish_allocation;


----------------------------------------------------------------------------------------
-- This private Procedure will validate:                                              --
--     allocation amount  <= budget available amount                                  --
--     holdback amount <= allocation amount                                           --
----------------------------------------------------------------------------------------
Procedure check_budget_available_amount( p_fund_id             IN     NUMBER
                                       , p_alloc_amount        IN     NUMBER
                                       , p_hb_amount           IN     NUMBER   := NULL
                                       , x_return_status       OUT NOCOPY    VARCHAR2
                                       , x_msg_count           OUT NOCOPY    NUMBER
                                       , x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_avail_amount              NUMBER;

  --asylvia 11-May-2006 bug 5199719 - SQL ID  17778551
  CURSOR c_get_fund_amount IS
  SELECT ((NVL(original_budget,0)-NVL(holdback_amt,0))+(NVL(transfered_in_amt,0)-NVL(transfered_out_amt,0)))
  FROM ozf_funds_all_b
	WHERE FUND_id = p_fund_id ;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  OPEN c_get_fund_amount;
  FETCH c_get_fund_amount INTO l_avail_amount;
  CLOSE c_get_fund_amount;
  -- dbms_output.put_line('top level: budget available amount=' || l_avail_amount || '  recommend total=' || p_alloc_amount);
  IF p_alloc_amount > l_avail_amount THEN
     -- top level allocation amount can not exceed fund's available amount
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_INV_CHILD_AMT');
        FND_MESSAGE.Set_Token('SUMAMT', p_alloc_amount);
        FND_MESSAGE.Set_Token('NODEVALUE', 'FUND');
        FND_MESSAGE.Set_Token('PAMT', l_avail_amount);
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_hb_amount > p_alloc_amount THEN
       -- holdback amount can not exceed allocation amount
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_HOLDBACKAMT_ERROR');
          FND_MESSAGE.Set_Token('HOLDBACK', p_hb_amount);
          FND_MESSAGE.Set_Token('ALLOCAMT', p_alloc_amount);
          FND_MSG_PUB.Add;
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION
 WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END check_budget_available_amount;


----------------------------------------------------------------------------------------
-- This private Procedure will update base_total_pct, base_hb_pct for the whole worksheet  --
--   according to the new recommendation amount                                       --
--   private api called by update_worksheet_amount() only                             --
----------------------------------------------------------------------------------------
Procedure update_basepct_info( p_api_version         IN     NUMBER     := 1.0,
                               p_alloc_id            IN     NUMBER,
                               x_return_status       OUT NOCOPY    VARCHAR2,
                               x_msg_count           OUT NOCOPY    NUMBER,
                               x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  CURSOR c_get_alloc_info IS
    SELECT from_level
    FROM   ozf_act_metrics_all
    WHERE  activity_metric_id = p_alloc_id;

  CURSOR c_get_worksheetfacts IS
    SELECT fact.activity_metric_fact_id, fact.object_version_number
         , fact.level_depth, fact.previous_fact_id
         , fact.recommend_total_amount, fact.recommend_hb_amount
         , fact.base_total_pct, fact.base_hb_pct
    FROM   ozf_act_metric_facts_all fact
    WHERE  fact.activity_metric_id = p_alloc_id
    ORDER BY fact.level_depth asc;

  CURSOR c_get_alloc_down(p_parent_fact_id NUMBER) IS
    SELECT recommend_total_amount - NVL(recommend_hb_amount, 0)
    FROM   ozf_act_metric_facts_all
    WHERE  activity_metric_fact_id = p_parent_fact_id;

  l_alloc_from_level          NUMBER;
  l_parent_alloc_down         NUMBER;
  l_new_total_pct             NUMBER;
  l_new_hb_pct                NUMBER;
  l_return_status             VARCHAR2(2);
  l_fact_rec                  ozf_actmetricfact_Pvt.act_metric_fact_rec_type;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  OPEN c_get_alloc_info;
  FETCH c_get_alloc_info INTO l_alloc_from_level;
  CLOSE c_get_alloc_info;

  FOR worksheet_rec IN c_get_worksheetfacts LOOP
    IF worksheet_rec.level_depth = l_alloc_from_level THEN
       -- For start node, percentage should always be 100.
       l_new_total_pct := 100;
    ELSE
       -- compute non-start node total percentage.
       OPEN c_get_alloc_down(worksheet_rec.previous_fact_id);
       FETCH c_get_alloc_down INTO l_parent_alloc_down;
       CLOSE c_get_alloc_down;
       --Fix for Bug 3603302
       IF (l_parent_alloc_down IS NOT NULL AND l_parent_alloc_down <> 0) THEN
           l_new_total_pct := worksheet_rec.recommend_total_amount / l_parent_alloc_down * 100;
      END IF;
    END IF;

    IF (worksheet_rec.recommend_total_amount IS NOT NULL AND worksheet_rec.recommend_total_amount <> 0) THEN
       l_new_hb_pct := worksheet_rec.recommend_hb_amount / worksheet_rec.recommend_total_amount * 100;
    END IF;

    IF (l_new_total_pct IS NOT NULL AND worksheet_rec.base_total_pct IS NULL) OR
       (l_new_total_pct IS NULL AND worksheet_rec.base_total_pct IS NOT NULL) OR
       l_new_total_pct <> worksheet_rec.base_total_pct OR
       (l_new_hb_pct IS NOT NULL AND worksheet_rec.base_hb_pct IS NULL) OR
       (l_new_hb_pct IS NULL AND worksheet_rec.base_hb_pct IS NOT NULL) OR
       l_new_hb_pct <> worksheet_rec.base_hb_pct THEN
       Ozf_Actmetricfact_Pvt.Init_ActMetricFact_Rec(x_fact_rec => l_fact_rec);
       l_fact_rec.activity_metric_fact_id := worksheet_rec.activity_metric_fact_id;
       l_fact_rec.object_version_number := worksheet_rec.object_version_number;
       l_fact_rec.base_total_pct := l_new_total_pct;
       l_fact_rec.base_hb_pct := l_new_hb_pct;
       -- update table ozf_act_metric_facts
       ozf_actmetricfact_Pvt.update_actmetricfact(
         p_api_version                => p_api_version,
         p_init_msg_list              => fnd_api.g_false,
         p_commit                     => fnd_api.g_false,
         p_validation_level           => fnd_api.g_valid_level_full,
         x_return_status              => l_return_status,
         x_msg_count                  => x_msg_count,
         x_msg_data                   => x_msg_data,
         p_act_metric_fact_rec        => l_fact_rec
       );
       -- dbms_output.put_line('update fact percentage ' || l_fact_rec.activity_metric_fact_id || ' returns ' || l_return_status);
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END update_basepct_info;


----------------------------------------------------------------------------------------
-- This Procedure will sort fact changes by level ascendantly                         --
--   private api called by update_worksheet_amount() only                                    --
---------------------------------PARAMETERS---------------------------------------------
-- p_fact_table   amount changes by user                                              --
----------------------------------------------------------------------------------------
Procedure sort_changes_by_level(p_fact_table          IN     fact_table_type,
                                x_sorted_fact_ids     OUT NOCOPY    factLevelTableType,
                                x_return_status       OUT NOCOPY    VARCHAR2,
                                x_msg_count           OUT NOCOPY    NUMBER,
                                x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_index                     NUMBER;
  l_sorted_fact_ids           factLevelTableType;
  l_tmp_fact_ids              factLevelTableType;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF p_fact_table.FIRST IS NULL THEN
      RETURN;
   END IF;

   l_index := p_fact_table.FIRST;
   l_tmp_fact_ids(l_index).fact_id := p_fact_table(l_index).activity_metric_fact_id;
   l_tmp_fact_ids(l_index).level_depth := p_fact_table(l_index).level_depth;

   IF (p_fact_table.NEXT(l_index) IS NULL) THEN
       l_sorted_fact_ids := l_tmp_fact_ids;
   ELSE
       FOR I IN p_fact_table.NEXT(l_index) .. p_fact_table.LAST LOOP
           l_index := l_tmp_fact_ids.FIRST;
           WHILE (l_index <= l_tmp_fact_ids.LAST AND
                  p_fact_table(I).level_depth >= l_tmp_fact_ids(l_index).level_depth) LOOP
               l_sorted_fact_ids(l_index).fact_id := l_tmp_fact_ids(l_index).fact_id;
               l_sorted_fact_ids(l_index).level_depth := l_tmp_fact_ids(l_index).level_depth;
               l_index := l_tmp_fact_ids.NEXT(l_index);
           END LOOP;
           IF (l_index IS NULL) THEN
               -- end of the tmp list, append here
               l_index := l_tmp_fact_ids.LAST + 1;
               l_sorted_fact_ids(l_index).fact_id := p_fact_table(I).activity_metric_fact_id;
               l_sorted_fact_ids(l_index).level_depth := p_fact_table(I).level_depth;
           ELSE
               -- insert the node in the middle
               l_sorted_fact_ids(l_index).fact_id := p_fact_table(I).activity_metric_fact_id;
               l_sorted_fact_ids(l_index).level_depth := p_fact_table(I).level_depth;
               FOR K IN l_index .. l_tmp_fact_ids.LAST LOOP
                   l_sorted_fact_ids(K+1).fact_id := l_tmp_fact_ids(K).fact_id;
                   l_sorted_fact_ids(K+1).level_depth := l_tmp_fact_ids(K).level_depth;
               END LOOP;
           END IF;
           l_tmp_fact_ids := l_sorted_fact_ids;
       END LOOP;
   END IF;

   x_sorted_fact_ids := l_sorted_fact_ids;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     fnd_api.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
     );
END sort_changes_by_level;


----------------------------------------------------------------------------------------
-- This Procedure will cascade recommend amount changes down the sub-tree             --
--   private api called by update_worksheet_amount() only                             --
---------------------------------PARAMETERS---------------------------------------------
-- p_start_fact_id      fact id for the sub-tree's root, not necessarily the allocation start node --
-- p_alloc_status_code  allocation status code                                        --
----------------------------------------------------------------------------------------
Procedure cascade_down_subtree(p_api_version         IN     NUMBER     := 1.0,
                               p_alloc_id            IN     NUMBER,
                               p_alloc_status_code   IN     VARCHAR2,
                               p_alloc_action_code   IN     VARCHAR2,
                               p_start_fact_id       IN     NUMBER,
                               x_visited_node_set    OUT NOCOPY    node_table_type,
                               x_return_status       OUT NOCOPY    VARCHAR2,
                               x_msg_count           OUT NOCOPY    NUMBER,
                               x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_return_status             VARCHAR2(2);
  l_parent_fact_id            NUMBER;
  l_recommend_total           NUMBER;
  l_recommend_hb              NUMBER;
  l_sibling_sum_amount        NUMBER;
  l_parent_amount             NUMBER;
  l_fund_id                   NUMBER;
  l_hierarchy_id              NUMBER;
  l_hierarchy_type            VARCHAR2(30);
  l_node_id                   NUMBER;
  l_index                     NUMBER;
  l_fact_rec                  ozf_actmetricfact_Pvt.act_metric_fact_rec_type;
  l_fund_rec                  ozf_funds_pvt.fund_rec_type;
  l_node_info                 node_info_type;
  l_visited_node_set          node_table_type;

  CURSOR c_get_subtree_root IS
     SELECT previous_fact_id, recommend_total_amount, recommend_hb_amount,
            act_metric_used_by_id
     FROM   ozf_act_metric_facts_all
     WHERE  activity_metric_fact_id = p_start_fact_id;

  -- get allocation amount summary of this node's children
  CURSOR c_get_child_sum(p_parent_fact_id NUMBER) IS
       --01/19/2004  kdass fixed bug 3371034
       --SELECT SUM(NVL(recommend_total_amount, 0))
       SELECT TRUNC(SUM(NVL(recommend_total_amount, 0)))
       FROM   ozf_act_metric_facts_all  fact
       WHERE  activity_metric_id = p_alloc_id
       AND    previous_fact_id = p_parent_fact_id;

  CURSOR c_get_node_info(p_fact_id NUMBER) IS
     SELECT hierarchy_id, hierarchy_type, node_id
     FROM   ozf_act_metric_facts_all fact
     WHERE  activity_metric_fact_id = p_fact_id;

  CURSOR c_get_subtree_worksheet IS
     SELECT activity_metric_fact_id, object_version_number,
            previous_fact_id, recommend_total_amount, recommend_hb_amount,
            base_total_pct, base_hb_pct
     FROM   ozf_act_metric_facts_all
     CONNECT BY prior activity_metric_fact_id = previous_fact_id
     START WITH previous_fact_id = p_start_fact_id
     ORDER BY level_depth;

  CURSOR c_get_allocdown_amount(p_fact_id NUMBER) IS
     SELECT recommend_total_amount - NVL(recommend_hb_amount, 0)
     FROM   ozf_act_metric_facts_all
     WHERE  activity_metric_fact_id = p_fact_id;

  CURSOR c_get_fund_info(l_fact_id IN NUMBER) IS
     SELECT fund_id, object_version_number
     FROM   ozf_funds_all_b
     WHERE  fund_id = (SELECT act_metric_used_by_id
                       FROM   ozf_act_metric_facts_all
                       WHERE  activity_metric_fact_id = l_fact_id);

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  -- validate the new recommended amount
  OPEN c_get_subtree_root;
  FETCH c_get_subtree_root INTO l_parent_fact_id, l_recommend_total, l_recommend_hb, l_fund_id;
  CLOSE c_get_subtree_root;

  IF l_parent_fact_id IS NOT NULL THEN
     -- we're not checking top level node against root budget as update_worksheet_amount() already does that before calling cascade
     -- holdback amount can not exceed allocation amount
    IF l_recommend_hb > l_recommend_total THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_HOLDBACKAMT_ERROR');
          FND_MESSAGE.Set_Token('HOLDBACK', l_recommend_hb);
          FND_MESSAGE.Set_Token('ALLOCAMT', l_recommend_total);
          FND_MSG_PUB.Add;
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- sum(sibling allocation amount) can not exceed parent allocation down amount
    OPEN c_get_child_sum(l_parent_fact_id);
    FETCH c_get_child_sum INTO l_sibling_sum_amount;
    CLOSE c_get_child_sum;
    OPEN c_get_allocdown_amount(l_parent_fact_id);
    FETCH c_get_allocdown_amount INTO l_parent_amount;
    CLOSE c_get_allocdown_amount;
    IF l_sibling_sum_amount > l_parent_amount THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          OPEN c_get_node_info(l_parent_fact_id);
          FETCH c_get_node_info INTO l_hierarchy_id, l_hierarchy_type, l_node_id;
          CLOSE c_get_node_info;
          get_node_info( p_hierarchy_id       => l_hierarchy_id
                       , p_hierarchy_type     => l_hierarchy_type
                       , p_node_id            => l_node_id
                       , x_node_info          => l_node_info
                       , x_return_status      => l_return_status
                       , x_msg_count          => x_msg_count
                       , x_msg_data           => x_msg_data
                      );
          FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_INV_CHILD_AMT');
          FND_MESSAGE.Set_Token('SUMAMT', l_sibling_sum_amount);
          FND_MESSAGE.Set_Token('NODEVALUE', l_node_info.node_name);
          FND_MESSAGE.Set_Token('PAMT', l_parent_amount);
          FND_MSG_PUB.Add;
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;  -- IF l_parent_fact_id IS NOT NULL THEN

   -- cascade changes
   l_index := 0;
   FOR worksheet_rec IN c_get_subtree_worksheet LOOP
         Ozf_Actmetricfact_Pvt.Init_ActMetricFact_Rec(x_fact_rec => l_fact_rec);
         l_fact_rec.activity_metric_fact_id := worksheet_rec.activity_metric_fact_id;
         l_fact_rec.object_version_number := worksheet_rec.object_version_number;
         OPEN c_get_allocdown_amount(worksheet_rec.previous_fact_id);
         FETCH c_get_allocdown_amount INTO l_parent_amount;
         CLOSE c_get_allocdown_amount;
         l_fact_rec.recommend_total_amount := l_parent_amount * worksheet_rec.base_total_pct / 100;
         l_fact_rec.recommend_hb_amount := l_fact_rec.recommend_total_amount * worksheet_rec.base_hb_pct / 100;
         ozf_actmetricfact_Pvt.update_actmetricfact(
             p_api_version                => p_api_version,
             p_init_msg_list              => fnd_api.g_false,
             p_commit                     => fnd_api.g_false,
             p_validation_level           => fnd_api.g_valid_level_full,
             x_return_status              => l_return_status,
             x_msg_count                  => x_msg_count,
             x_msg_data                   => x_msg_data,
             p_act_metric_fact_rec        => l_fact_rec
         );
         -- dbms_output.put_line('cascade_down_subtree() update fact ' || l_fact_rec.activity_metric_fact_id || ' total=' || l_fact_rec.recommend_total_amount || ' holdback=' || l_fact_rec.recommend_hb_amount || ' returns ' || l_return_status);
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_index := l_index + 1;
         l_visited_node_set(l_index) := worksheet_rec.activity_metric_fact_id;

         IF p_alloc_status_code = 'PLANNED' AND
            p_alloc_action_code = 'CREATE_NEW_BUDGET' THEN
            -- update the corresponding child budget's total and holdback amount for published allocation
            -- yzhao: 02/04/2003 update only when 'create new budget', do not update if it is 'adding onto existing budget'
             ozf_funds_pvt.init_fund_rec (l_fund_rec);
             OPEN c_get_fund_info(l_fact_rec.activity_metric_fact_id);
             FETCH c_get_fund_info INTO l_fund_rec.fund_id, l_fund_rec.object_version_number;
             CLOSE c_get_fund_info;
             l_fund_rec.original_budget := l_fact_rec.recommend_total_amount;
             l_fund_rec.holdback_amt := l_fact_rec.recommend_hb_amount;
             ozf_funds_pvt.update_fund( p_api_version        => p_api_version
                                      , p_init_msg_list      => fnd_api.g_false
                                      , p_commit             => fnd_api.g_false
                                      /* yzhao: 12/17/2002 disable validation here since for cascading, parent budget got updated
                                                before child budget, which may cause amount validation failure
                                      , p_validation_level   => fnd_api.g_valid_level_full
                                       */
                                      , p_validation_level   => fnd_api.g_valid_level_none
                                      , p_fund_rec           => l_fund_rec
                                      , x_return_status      => l_return_status
                                      , x_msg_count          => x_msg_count
                                      , x_msg_data           => x_msg_data
                                        );
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
         END IF;  -- IF p_alloc_status_code = 'PLANNED' THEN

     END LOOP;

  x_visited_node_set := l_visited_node_set;
-- dbms_output.put_line('cascade_down_subtree: visited_node_set.COUNT=' || x_visited_node_set.COUNT);

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     fnd_api.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
     );
END cascade_down_subtree;


----------------------------------------------------------------------------------------
-- This Procedure will validate an allocation worksheet recommended amount            --
-- For start level node:                                                              --
--     recommend total amount <= budget available amount                              --
-- For each node:                                                                     --
--     Sum(child recommend total amount) <= this node's recommend total amount - holdback amount
--   since I'm traversing the hierarchy, it's not necessary to do the following check any more:
--     Sum(this node and its sibling's allocation amount) <=                          --
--          parent allocation amount - holdback amount                                --
---------------------------------PARAMETERS---------------------------------------------
-- p_alloc_id    allocation id in ozf_act_metrics_all table                           --
----------------------------------------------------------------------------------------
Procedure validate_worksheet(p_api_version         IN     NUMBER,
                             p_init_msg_list       IN     VARCHAR2,
                             p_commit              IN     VARCHAR2,
                             p_validation_level    IN     NUMBER,
                             p_alloc_id            IN     NUMBER,
                             x_return_status       OUT NOCOPY    VARCHAR2,
                             x_msg_count           OUT NOCOPY    NUMBER,
                             x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_fund_id                   NUMBER;
  l_avail_amount              NUMBER;
  l_alloc_from_level          NUMBER;
  l_child_sum_amount          NUMBER;
  l_return_status             VARCHAR2(2);
  l_node_info                 node_info_type;
  l_alloc_status_code         VARCHAR2(30);

  CURSOR c_get_alloc_info IS
    SELECT act_metric_used_by_id, from_level, status_code
    FROM   ozf_act_metrics_all
    WHERE  activity_metric_id = p_alloc_id;

  CURSOR c_get_worksheetfacts IS
    SELECT fact.activity_metric_fact_id, fact.hierarchy_id, fact.hierarchy_type
         , fact.node_id, fact.level_depth
         , fact.recommend_total_amount, fact.recommend_hb_amount
    FROM   ozf_act_metric_facts_all fact
    WHERE  fact.activity_metric_id = p_alloc_id
    ORDER BY fact.level_depth, fact.node_id asc;

  -- get allocation amount summary of this node's children
  CURSOR c_get_child_sum(p_parent_fact_id NUMBER) IS
       --01/19/2004  kdass fixed bug 3371034
       --SELECT SUM(NVL(recommend_total_amount, 0))
       SELECT TRUNC(SUM(NVL(recommend_total_amount, 0)))
       FROM   ozf_act_metric_facts_all  fact
       WHERE  activity_metric_id = p_alloc_id
       AND    previous_fact_id = p_parent_fact_id;

BEGIN
  IF G_DEBUG THEN
     OZF_Utility_PVT.debug_message('Validate_worksheet: start');
  END IF;

  IF FND_API.To_Boolean (p_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  OPEN c_get_alloc_info;
  FETCH c_get_alloc_info INTO l_fund_id, l_alloc_from_level, l_alloc_status_code;
  CLOSE c_get_alloc_info;

  FOR worksheet_rec IN c_get_worksheetfacts LOOP

     /* yzhao: 01/26/2004 fix bug 3362218 - CHILD ALLOCATIONS IN BUDGET ALLOCATION ERROR OUT
               do not validate against root budget if allocation is already active
     */
     IF worksheet_rec.level_depth = l_alloc_from_level AND
        l_alloc_status_code <> 'ACTIVE' THEN
       -- top level node: check against root budget
       check_budget_available_amount( p_fund_id           => l_fund_id
                                    , p_alloc_amount      => worksheet_rec.recommend_total_amount
                                    , p_hb_amount         => worksheet_rec.recommend_hb_amount
                                    , x_return_status     => l_return_status
                                    , x_msg_count         => x_msg_count
                                    , x_msg_data          => x_msg_data);
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSE
        -- for each node: holdback amount can not exceed allocation amount
        IF worksheet_rec.recommend_hb_amount > worksheet_rec.recommend_total_amount THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_HOLDBACKAMT_ERROR');
              FND_MESSAGE.Set_Token('HOLDBACK', worksheet_rec.recommend_hb_amount);
              FND_MESSAGE.Set_Token('ALLOCAMT', worksheet_rec.recommend_total_amount);
              FND_MSG_PUB.Add;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;  -- IF l_worksheet_rec.level_depth = l_alloc_from_level THEN

    -- for each node: check its allocation down amount against its children's allocation sum
    OPEN c_get_child_sum(worksheet_rec.activity_metric_fact_id);
    FETCH c_get_child_sum INTO l_child_sum_amount;
    CLOSE c_get_child_sum;
    l_avail_amount := worksheet_rec.recommend_total_amount - NVL(worksheet_rec.recommend_hb_amount, 0);
    IF l_child_sum_amount > (l_avail_amount + g_max_ignorable_amount) THEN
       -- sum of this node's children's allocation amount can not exceed this node's available amount
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          get_node_info( p_hierarchy_id       => worksheet_rec.hierarchy_id
                       , p_hierarchy_type     => worksheet_rec.hierarchy_type
                       , p_node_id            => worksheet_rec.node_id
                       , x_node_info          => l_node_info
                       , x_return_status      => l_return_status
                       , x_msg_count          => x_msg_count
                       , x_msg_data           => x_msg_data
                      );
          FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_INV_CHILD_AMT');
          FND_MESSAGE.Set_Token('SUMAMT', l_child_sum_amount);
          FND_MESSAGE.Set_Token('NODEVALUE', l_node_info.node_name);
          FND_MESSAGE.Set_Token('PAMT', l_avail_amount);
          FND_MSG_PUB.Add;
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
  END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     fnd_api.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END validate_worksheet;


----------------------------------------------------------------------------------------
-- This Procedure will update an allocation worksheet                                 --
--   Public api called by worksheet update and publish button                         --
--   Only called by allocation in 'NEW' OR 'PLANNED' status                           --
--   It first updates fact amount according to the input                              --
--   then if 'cascade' flag is set, cascade changes down the whole hierarchy          --
--   it also update the corresponding allocation budget's original and holdback amount--
--   if base percentage is null in table, set base percentage
--   cascade is allowed for recommended amount change only                            --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_alloc_id    allocation id in ozf_act_metrics_all table                           --
-- p_fact_table  table of fact records to be changed                                  --
--               required fields are: activity_metric_fact_id, object_version_number, --
--                                    recommend_total_amount, recommend_hb_amount,    --
--                                    node_id, level_depth                            --
----------------------------------------------------------------------------------------
Procedure update_worksheet_amount(p_api_version         IN     NUMBER,
                           p_init_msg_list       IN     VARCHAR2,
                           p_commit              IN     VARCHAR2,
                           p_validation_level    IN     NUMBER,
                           p_alloc_id            IN     NUMBER,
                           p_alloc_obj_ver       IN     NUMBER,
                           p_cascade_flag        IN     VARCHAR2,
                           p_fact_table          IN     fact_table_type,
                           x_return_status       OUT NOCOPY    VARCHAR2,
                           x_msg_count           OUT NOCOPY    NUMBER,
                           x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_full_name                 VARCHAR2(120) := g_pkg_name || ': update_worksheet_amount() ';
  l_index                     NUMBER := 0;
  l_return_status             VARCHAR2(2);
  l_fund_id                   NUMBER;
  l_alloc_start_node          NUMBER;
  l_alloc_amount              NUMBER;
  l_alloc_status_code         VARCHAR2(30);
  l_alloc_action_code         VARCHAR2(30);
  l_parent_amount             NUMBER;
  l_not_visited_flag          BOOLEAN := true;
  l_sorted_fact_ids           factLevelTableType;
  l_fact_rec                  ozf_actmetricfact_Pvt.act_metric_fact_rec_type;
  l_metric_rec                Ozf_Actmetric_Pvt.act_metric_rec_type;
  l_fund_rec                  ozf_funds_pvt.fund_rec_type;
  l_visited_node_set          node_table_type;
  l_new_visited_node_set      node_table_type;

  CURSOR c_get_alloc_info IS
     SELECT status_code, start_node, func_actual_value, act_metric_used_by_id, action_code
     FROM   ozf_act_metrics_all
     WHERE  activity_metric_id = p_alloc_id;

  CURSOR c_get_fund_info(l_fact_id IN NUMBER) IS
     SELECT fund_id, object_version_number
     FROM   ozf_funds_all_b
     WHERE  fund_id = (SELECT act_metric_used_by_id
                       FROM   ozf_act_metric_facts_all
                       WHERE  activity_metric_fact_id = l_fact_id);
BEGIN
  SAVEPOINT update_worksheet_amount_sp;

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message(l_full_name || ': start');
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;

  OPEN c_get_alloc_info;
  FETCH c_get_alloc_info
  INTO l_alloc_status_code, l_alloc_start_node, l_alloc_amount, l_fund_id,   l_alloc_action_code;
  CLOSE c_get_alloc_info;

  IF p_fact_table.COUNT <= 0 OR l_alloc_status_code NOT IN ('NEW', 'PLANNED', 'ACTIVE') THEN
     RETURN;
  END IF;

  FOR l_index IN p_fact_table.FIRST .. p_fact_table.LAST LOOP

      l_fact_rec := p_fact_table(l_index);

      -- kdass: 01/19/2004 fix bug 3379926 - the allocation worksheet should not accept negative amounts for allocation
      IF NVL(p_fact_table(l_index).recommend_total_amount,0) < 0 THEN   -- check for recommended total amount
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
           fnd_message.set_name('OZF', 'OZF_FUND_ALLOCAMT_NEG_ERROR');
           fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- kdass: 01/23/2004 fix bug 3392738 - the allocation worksheet should not accept negative amounts for holdback amounts
      IF NVL(p_fact_table(l_index).recommend_hb_amount,0) < 0 THEN   -- check for recommended holdback amount
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
           fnd_message.set_name('OZF', 'OZF_FUND_NO_HOLDBACK_BUDGET');
           fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF p_fact_table(l_index).node_id = l_alloc_start_node THEN
         -- start node
         -- validation: allocation amount <= budget available amount
         --                        holdback amount <= allocation amount
         check_budget_available_amount( p_fund_id           => l_fund_id
                                      , p_alloc_amount      => p_fact_table(l_index).recommend_total_amount
                                      , p_hb_amount         => p_fact_table(l_index).recommend_hb_amount
                                      , x_return_status     => l_return_status
                                      , x_msg_count         => x_msg_count
                                      , x_msg_data          => x_msg_data);
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF l_alloc_amount <> p_fact_table(l_index).recommend_total_amount THEN
         -- top level's total amount is changed, need to update metric record
            Ozf_Actmetric_Pvt.Init_ActMetric_Rec(l_metric_rec);
            l_metric_rec.activity_metric_id := p_alloc_id;
            l_metric_rec.object_version_number := p_alloc_obj_ver;
            l_metric_rec.func_actual_value := p_fact_table(l_index).recommend_total_amount;

            /* it is important not to do some validation since allocation amount already deducted from fund,
               so validation will fail. should < jtf_plsql_api.G_VALID_LEVEL_RECORD CONSTANT NUMBER:= 80.
               set to 70 here.
             */
            Ozf_Actmetric_Pvt.update_Actmetric( p_api_version       => p_api_version
                                                 , p_init_msg_list     => FND_API.G_FALSE
                                                 , p_commit            => FND_API.G_FALSE
                                                 , p_validation_level  => 70
                                                 , x_return_status     => l_return_status
                                                 , x_msg_count         => x_msg_count
                                                 , x_msg_data          => x_msg_data
                                                 , p_act_metric_rec    => l_metric_rec
                                                 );
            -- dbms_output.put_line(l_full_name || 'update allocation amount returns ' || l_return_status);
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;  -- IF l_alloc_amount <> p_fact_table(l_index).recommend_total_amount THEN
      END IF;  -- IF p_fact_table(l_index).node_id = l_alloc_start_node THEN

      -- update table ozf_act_metric_facts
      ozf_actmetricfact_Pvt.update_actmetricfact(
         p_api_version                => p_api_version,
         p_init_msg_list              => fnd_api.g_false,
         p_commit                     => fnd_api.g_false,
         p_validation_level           => fnd_api.g_valid_level_full,
         x_return_status              => l_return_status,
         x_msg_count                  => x_msg_count,
         x_msg_data                   => x_msg_data,
         p_act_metric_fact_rec        => l_fact_rec
      );
      -- dbms_output.put_line(l_full_name || 'update fact ' || l_index || ' returns ' || l_return_status);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END LOOP;

  IF p_cascade_flag = 'N' THEN
     -- validate worksheet update if it's not cascade
     validate_worksheet(p_api_version         => p_api_version,
                        p_init_msg_list       => fnd_api.g_false,
                        p_commit              => fnd_api.g_false,
                        p_validation_level    => fnd_api.g_valid_level_full,
                        p_alloc_id            => p_alloc_id,
                        x_return_status       => l_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);
      -- dbms_output.put_line(l_full_name || 'validate_worksheet returns ' || l_return_status);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_alloc_status_code = 'PLANNED' AND
         l_alloc_action_code = 'CREATE_NEW_BUDGET' THEN
         -- update the corresponding child budget's total and holdback amount for published allocation
         -- yzhao: 02/04/2003 update only when 'create new budget', do not update if it is 'adding onto existing budget'
         FOR l_index IN p_fact_table.FIRST .. p_fact_table.LAST LOOP
             ozf_funds_pvt.init_fund_rec (l_fund_rec);
             OPEN c_get_fund_info(p_fact_table(l_index).activity_metric_fact_id);
             FETCH c_get_fund_info INTO l_fund_rec.fund_id, l_fund_rec.object_version_number;
             CLOSE c_get_fund_info;
             l_fund_rec.original_budget := p_fact_table(l_index).recommend_total_amount;
             l_fund_rec.holdback_amt := p_fact_table(l_index).recommend_hb_amount;
             ozf_funds_pvt.update_fund( p_api_version        => p_api_version
                                      , p_init_msg_list      => fnd_api.g_false
                                      , p_commit             => fnd_api.g_false
                                      , p_validation_level   => fnd_api.g_valid_level_full
                                      , p_fund_rec           => l_fund_rec
                                      , x_return_status      => l_return_status
                                      , x_msg_count          => x_msg_count
                                      , x_msg_data           => x_msg_data
                                        );
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
         END LOOP;
      END IF;

  ELSE
     -- sort passed in fact records by level depepth ascendantly
     sort_changes_by_level(p_fact_table        => p_fact_table,
                           x_sorted_fact_ids   => l_sorted_fact_ids,
                           x_return_status     => l_return_status,
                           x_msg_count         => x_msg_count,
                           x_msg_data          => x_msg_data);
      -- dbms_output.put_line(l_full_name || ' sort fact changes by level returns ' || l_return_status);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -- cascade recommend total and holdback amount changes.
     -- start from the toppest level. If update multiple levels under the same node, higher level change superceds lower level change
     FOR I IN NVL(l_sorted_fact_ids.FIRST, 1) .. NVL(l_sorted_fact_ids.LAST, -1) LOOP
       l_not_visited_flag := TRUE;
       FOR J IN NVL(l_visited_node_set.FIRST, 1) .. NVL(l_visited_node_set.LAST, -1) LOOP
           IF l_visited_node_set(J) = l_sorted_fact_ids(I).fact_id THEN
              -- this node has already been cascaded, so its ancester's change supercedes its
              l_not_visited_flag := FALSE;
              EXIT;
           END IF;
       END LOOP;

       IF l_not_visited_flag THEN
         cascade_down_subtree(p_api_version         => p_api_version,
                                p_alloc_id            => p_alloc_id,
                                p_alloc_status_code   => l_alloc_status_code,
                                p_alloc_action_code   => l_alloc_action_code,
                                p_start_fact_id       => l_sorted_fact_ids(I).fact_id,
                                x_visited_node_set    => l_new_visited_node_set,
                                x_return_status       => l_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);
         -- dbms_output.put_line(l_full_name || ' cascade down subtree returns ' || l_return_status || ' subtree node count=' || l_new_visited_node_set.COUNT);
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_index := NVL(l_visited_node_set.LAST, 0);
         FOR J IN NVL(l_new_visited_node_set.FIRST, 1) .. NVL(l_new_visited_node_set.LAST, -1) LOOP
             -- append new visited nodes
             l_index := l_index + 1;
             l_visited_node_set(l_index) := l_new_visited_node_set(J);
         END LOOP;
       END IF;  -- IF NOT l_not_visited_flag THEN
     END LOOP;

  END IF;

  -- update base total and holdback percentage according to new recommendation amounts
  update_basepct_info( p_api_version       => p_api_version,
                       p_alloc_id          => p_alloc_id,
                       x_return_status     => l_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data);
  -- dbms_output.put_line(l_full_name || 'update worksheet percentage returns ' || l_return_status);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     commit;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK TO update_worksheet_amount_sp;
-- dbms_output.put_line(l_full_name || 'exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END update_worksheet_amount;


----------------------------------------------------------------------------------------
-- This Procedure will activate one fact record of allocation                         --
--   Private api called by activate_allocation() and approve_levels()                 --
--   Validation: all validation should already be done by caller                      --
--   Action: set the allocation fact and corresponding budget to active               --
--           send notification to child budget owner                                  --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_child_fact_id            the child fact to be approved                           --
-- p_child_fact_obj_ver                                                               --
-- p_approved_total           approved total amount                                   --
-- p_approved_hb              approved holdback amount                                --
----------------------------------------------------------------------------------------
Procedure activate_one_node(p_api_version         IN     NUMBER    := 1.0,
                            p_alloc_id            IN     NUMBER,
                            p_child_fact_id       IN     NUMBER,
                            p_child_fact_obj_ver  IN     NUMBER,
                            p_approved_total      IN     NUMBER,
                            p_approved_hb         IN     NUMBER,
                            p_alloc_action_code   IN     VARCHAR2,
                            x_return_status       OUT NOCOPY    VARCHAR2,
                            x_msg_count           OUT NOCOPY    NUMBER,
                            x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_child_fund_id             NUMBER;
  l_child_fund_obj_ver        NUMBER;
  l_child_fund_owner          NUMBER;
  l_child_fund_name           ozf_funds_all_tl.short_name%TYPE;
  l_child_fund_currency       ozf_funds_all_b.currency_code_tc%TYPE;
  l_child_requested_total     NUMBER;
  l_notif_subject             VARCHAR2(400);
  l_notif_body                VARCHAR2(4000);
  l_return_id                 NUMBER;
  l_tmp_id                    NUMBER;
  l_tmp_char                  VARCHAR2(1);
  l_metric_fact_rec           ozf_actmetricfact_Pvt.act_metric_fact_rec_type;
  l_fund_rec                  ozf_funds_pvt.fund_rec_type;
  l_fund_type                 VARCHAR2(30) := NULL;
  l_fund_meaning              VARCHAR2(240) := NULL;
  l_temp_status               VARCHAR2(1);

  CURSOR c_get_child_info IS
  SELECT fund.fund_id, fund.object_version_number, fund.owner, fund.short_name, fund.currency_code_tc
       , fact.request_total_amount, fund.fund_type
  FROM   ozf_funds_all_vl fund, ozf_act_metric_facts_all fact
  WHERE  fund.fund_id = fact.act_metric_used_by_id
  AND    fact.activity_metric_fact_id = p_child_fact_id
  AND    fact.arc_act_metric_used_by = 'FUND';

BEGIN
  -- update child node status as ACTIVE
  ozf_actmetricfact_pvt.init_actmetricfact_rec(l_metric_fact_rec);
  l_metric_fact_rec.activity_metric_fact_id := p_child_fact_id;
  l_metric_fact_rec.object_version_number := p_child_fact_obj_ver;
  l_metric_fact_rec.status_code := 'ACTIVE';
  -- set actual_total_amount, actual_hb_amount, approval_date
  l_metric_fact_rec.actual_total_amount := p_approved_total;
  l_metric_fact_rec.actual_hb_amount := NVL(p_approved_hb, 0);
  l_metric_fact_rec.approval_date := sysdate;
  ozf_actmetricfact_Pvt.Update_ActMetricFact( p_api_version                => p_api_version
                     , p_init_msg_list              => fnd_api.g_true
                     , p_commit                     => fnd_api.g_false
                     , p_validation_level           => fnd_api.g_valid_level_full
                     , p_act_metric_fact_rec        => l_metric_fact_rec
                     , x_return_status              => x_return_status
                     , x_msg_count                  => x_msg_count
                     , x_msg_data                   => x_msg_data
                     );
-- dbms_output.put_line('activate_one_node: update child node fact id=' || p_child_fact_id || '  active returns ' || x_return_status);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN c_get_child_info;
  FETCH c_get_child_info INTO l_child_fund_id, l_child_fund_obj_ver, l_child_fund_owner, l_child_fund_name
                            , l_child_fund_currency, l_child_requested_total, l_fund_type;
  CLOSE c_get_child_info;
  IF (p_alloc_action_code = 'CREATE_NEW_BUDGET') THEN
      -- activate the child budget
      ozf_funds_pvt.init_fund_rec (l_fund_rec);
      l_fund_rec.fund_id := l_child_fund_id;
      l_fund_rec.object_version_number := l_child_fund_obj_ver;
      l_fund_rec.original_budget := p_approved_total;
      l_fund_rec.holdback_amt := p_approved_hb;
      l_fund_rec.status_code := 'ACTIVE';
      ozf_funds_pvt.update_fund( p_api_version        => p_api_version
                               , p_init_msg_list      => fnd_api.g_true
                               , p_commit             => fnd_api.g_false
                               , p_validation_level   => fnd_api.g_valid_level_full
                               , p_fund_rec           => l_fund_rec
                               , x_return_status      => x_return_status
                               , x_msg_count          => x_msg_count
                               , x_msg_data           => x_msg_data
                               );
    -- dbms_output.put_line('activate_one_node: update_fund to active returns ' || x_return_status || ' budget id=' || l_fund_rec.fund_id || ' request_amount=' || p_approved_total);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  ELSIF (p_alloc_action_code = 'TRANSFER_TO_BUDGET') THEN
      -- create an approved budget transfer from parent to child
      transfer_approved_budget(p_api_version          => p_api_version
                             , p_child_fund_id        => l_child_fund_id
                             , p_approved_total       => p_approved_total
                             , x_return_status        => x_return_status
                             , x_msg_count            => x_msg_count
                             , x_msg_data             => x_msg_data
                              );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

  /* send notification to child budget owner */
  IF l_fund_type = 'QUOTA' THEN
    ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                                        p_lookup_code   => 'QUOTA',
                                        x_return_status => l_temp_status,
                                        x_meaning       => l_fund_meaning);
  ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
    ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                                        p_lookup_code   => 'BUDGET',
                                        x_return_status => l_temp_status,
                                        x_meaning       => l_fund_meaning);
  END IF;
  fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_APPROVAL_SUB');
  fnd_message.set_token('BUDGET_NAME', l_child_fund_name);
  fnd_message.set_token('ALLOC_ID', p_alloc_id);
  fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
  l_notif_subject := substrb(fnd_message.get, 1, 400);
  fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_APPROVAL_BODY');
  fnd_message.set_token ('BUDGET_NAME', l_child_fund_name);
  fnd_message.set_token ('ALLOC_ID', p_alloc_id);
  fnd_message.set_token ('ALLOC_STATUS', 'ACTIVE');
  fnd_message.set_token ('CURRENCY_CODE', l_child_fund_currency);
  fnd_message.set_token ('REQUESTED_TOTAL_AMOUNT', ams_utility_pvt.CurrRound(nvl(l_child_requested_total,0),l_child_fund_currency));
  fnd_message.set_token ('APPROVED_TOTAL_AMOUNT', ams_utility_pvt.CurrRound(nvl(p_approved_total,0),l_child_fund_currency));
  fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
  l_notif_body := substrb(fnd_message.get, 1, 4000);

  ozf_utility_pvt.send_wf_standalone_message(
    p_subject            =>  l_notif_subject
  , p_body               =>  l_notif_body
  , p_send_to_res_id     =>  l_child_fund_owner
  , x_notif_id           =>  l_return_id
  , x_return_status      =>  x_return_status
  );
-- dbms_output.put_line('activate_one_node: send notificaiton returns ' || x_return_status);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
-- dbms_output.put_line('activate_one_node: exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END activate_one_node;


----------------------------------------------------------------------------------------
-- This Procedure will activate an allocation. Called when allocation status changed to active --
--   Private api called by update_alloc_status() only                                 --
--   Validation: only the top level user can do the activation                        --
--               the budget must be active to activate an allocation                  --
--               only PLANNED allcation can be made active.                           --
--   Action: set the metric to active                                                 --
--           set the top level allocation and budget active,                          --
--              and create active budget transfer record from root to top level       --
--              send notification to child budget owner                               --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_alloc_id    allocation id in ozf_act_metrics_all table                           --
----------------------------------------------------------------------------------------
Procedure activate_allocation(p_api_version         IN     NUMBER    := 1.0,
                              p_alloc_id            IN     NUMBER,
                              p_alloc_obj_ver       IN     NUMBER,
                              x_return_status       OUT NOCOPY    VARCHAR2,
                              x_msg_count           OUT NOCOPY    NUMBER,
                              x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_full_name                 VARCHAR2(120) := g_pkg_name || ': activate_allocation() ';
  l_alloc_creator             NUMBER;
  l_alloc_old_status          VARCHAR2(30);
  l_alloc_action_code         VARCHAR2(30);
  l_fund_id                   NUMBER;
  l_fund_status_code          VARCHAR2(30);
  l_fund_type                 VARCHAR2(30);
  l_child_fund_id             NUMBER;
  l_child_fund_name           ozf_funds_all_tl.short_name%TYPE;
  l_fact_id                   NUMBER;
  l_fact_obj_ver              NUMBER;
  l_recommend_total           NUMBER;
  l_recommend_hb              NUMBER;
  l_notif_subject             VARCHAR2(400);
  l_notif_body                VARCHAR2(4000);
  l_return_id                 NUMBER;
  l_tmp_id                    NUMBER;
  l_tmp_char                  VARCHAR2(1);
  l_ex_start_node             ozf_act_metrics_all.ex_start_node%TYPE;
  l_metric_rec                ozf_actmetric_pvt.act_metric_rec_type;

  CURSOR c_get_metric_info IS
     SELECT act_metric_used_by_id, created_by, status_code, action_code, ex_start_node
     FROM   ozf_act_metrics_all
     WHERE  activity_metric_id = p_alloc_id;

  CURSOR c_get_fund_info(p_fund_id NUMBER) IS
     SELECT fu.status_code, fu.fund_type
     FROM   ozf_funds_all_b fu
     WHERE  fund_id = p_fund_id;

  CURSOR c_get_alloc_topnode IS
     SELECT m.activity_metric_fact_id, m.object_version_number
          , m.recommend_total_amount, m.recommend_hb_amount
     FROM   ozf_act_metric_facts_all m
     WHERE  activity_metric_id = p_alloc_id
     AND    previous_fact_id IS NULL;

  CURSOR c_get_alloc_toplevels(p_previous_fact_id IN NUMBER) IS
     SELECT m.activity_metric_fact_id, m.object_version_number
          , m.recommend_total_amount, m.recommend_hb_amount
     FROM   ozf_act_metric_facts_all m
     WHERE  activity_metric_id = p_alloc_id
     AND    previous_fact_id = p_previous_fact_id;

BEGIN
  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message(l_full_name || ': start');
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  OPEN c_get_metric_info;
  FETCH c_get_metric_info INTO l_fund_id, l_alloc_creator, l_alloc_old_status, l_alloc_action_code, l_ex_start_node;
  CLOSE c_get_metric_info;

  OPEN c_get_fund_info(l_fund_id);
  FETCH c_get_fund_info INTO l_fund_status_code, l_fund_type;
  CLOSE c_get_fund_info;

  -- only the allocation creator can activate allocation
  IF l_alloc_creator <> NVL(fnd_global.user_id, -1) THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        IF l_fund_type = 'QUOTA' THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_ALLOCNOTOWNER_ERROR');
        ELSE
           FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_ALLOCNOTOWNER_ERROR');
        END IF;
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- statuses other than PLANNED are not allowed changed to ACTIVE
  IF l_alloc_old_status <> 'PLANNED' THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_ALLOCSTATUS_ERROR');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;



  -- can not make allocaiton active if root budget is not active
  IF l_fund_status_code <> 'ACTIVE' THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        IF l_fund_type = 'QUOTA' THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_ALLOCACTIVE_ERROR');
        ELSE
           FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_ALLOCACTIVE_ERROR');
        END IF;
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* allocation status 'PLANNED' -> 'ACTIVE' */
  Ozf_Actmetric_Pvt.Init_ActMetric_Rec(l_metric_rec);
  l_metric_rec.activity_metric_id := p_alloc_id;
  l_metric_rec.status_code := 'ACTIVE';
  l_metric_rec.object_version_number := p_alloc_obj_ver;
  l_metric_rec.act_metric_date := sysdate;
  Ozf_Actmetric_Pvt.update_Actmetric( p_api_version    => p_api_version
                                     , p_init_msg_list     => fnd_api.g_false
                                     , p_commit            => fnd_api.g_false
                                     , p_validation_level  => fnd_api.g_valid_level_full
                                     , x_return_status     => x_return_status
                                     , x_msg_count         => x_msg_count
                                     , x_msg_data          => x_msg_data
                                     , p_act_metric_rec    => l_metric_rec
                                     );
-- dbms_output.put_line(l_full_name || 'set alloc status ACTIVE returns ' || x_return_status);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_fact_id := NULL;
  l_fact_obj_ver := NULL;
  OPEN c_get_alloc_topnode;
  FETCH c_get_alloc_topnode INTO l_fact_id, l_fact_obj_ver, l_recommend_total, l_recommend_hb;
  CLOSE c_get_alloc_topnode;
  IF (l_ex_start_node IS NULL OR l_ex_start_node = 'N') THEN
      -- start node is included, so activate the top node
    -- dbms_output.put_line(l_full_name || 'top node fact_id=' || l_fact_id || ' ver=' || l_fact_obj_ver);
      -- activate top node allocation and budget, create fund request between root budget and top node, send notification to top node owner
      activate_one_node(p_api_version         => p_api_version,
                        p_alloc_id            => p_alloc_id,
                        p_child_fact_id       => l_fact_id,
                        p_child_fact_obj_ver  => l_fact_obj_ver,
                        p_approved_total      => l_recommend_total,
                        p_approved_hb         => l_recommend_hb,
                        p_alloc_action_code   => l_alloc_action_code,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);
    -- dbms_output.put_line(l_full_name || 'activate top level node returns ' || x_return_status);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  ELSE
      -- start node is excluded, so activate all nodes in the top level
      FOR fact_rec IN c_get_alloc_toplevels(l_fact_id) LOOP
          -- activate top level allocation and budget, create fund request between root budget and top level node, send notification to top level node owner
          activate_one_node(p_api_version         => p_api_version,
                            p_alloc_id            => p_alloc_id,
                            p_child_fact_id       => fact_rec.activity_metric_fact_id,
                            p_child_fact_obj_ver  => fact_rec.object_version_number,
                            p_approved_total      => fact_rec.recommend_total_amount,
                            p_approved_hb         => fact_rec.recommend_hb_amount,
                            p_alloc_action_code   => l_alloc_action_code,
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data);
        -- dbms_output.put_line(l_full_name || 'activate top level node returns ' || x_return_status);
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
-- dbms_output.put_line(l_full_name || 'exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END activate_allocation;


----------------------------------------------------------------------------------------
-- This Procedure will cancel an allocation. Called when allocation status changed to CANCELLED --
--   Private api called by update_alloc_status() only                                 --
--   Validation: only the top level user can do the cancellation                      --
--               only NEW or PLANNED allcation can be cancelled                       --
--   Action: set the metric to cancelled                                              --
--           set all facts(if any) status to canncelled                               --
--           if already published, notify child budget owners of cancellation         --
--           if CREATE_NEW_BUDGET, mark all children budget as CANCELLED              --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_alloc_id    allocation id in ozf_act_metrics_all table                           --
----------------------------------------------------------------------------------------
Procedure cancel_allocation(p_api_version         IN     NUMBER    := 1.0,
                            p_alloc_id            IN     NUMBER,
                            p_alloc_obj_ver       IN     NUMBER,
                            x_return_status       OUT NOCOPY    VARCHAR2,
                            x_msg_count           OUT NOCOPY    NUMBER,
                            x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_full_name                 VARCHAR2(120) := g_pkg_name || ': cancel_allocation() ';
  l_alloc_creator             NUMBER;
  l_alloc_old_status          VARCHAR2(30);
  l_alloc_action_code         VARCHAR2(30);
  l_root_fund_id              NUMBER;
  l_fund_obj_ver              ozf_funds_all_b.object_version_number%TYPE;
  l_fund_owner                ozf_funds_all_b.owner%TYPE;
  l_fund_name                 ozf_funds_all_tl.short_name%TYPE;
  l_notif_subject             VARCHAR2(400);
  l_notif_body                VARCHAR2(4000);
  l_return_id                 NUMBER;
  l_metric_rec                ozf_actmetric_pvt.act_metric_rec_type;
  l_metric_fact_rec           ozf_actmetricfact_Pvt.act_metric_fact_rec_type;
  l_fund_rec                  ozf_funds_pvt.fund_rec_type;
  l_fund_type                 VARCHAR2(30) := NULL;
  l_root_fund_type            VARCHAR2(30) := NULL;
  l_fund_meaning              VARCHAR2(240) := NULL;
  l_temp_status               VARCHAR2(1);

  CURSOR c_get_metric_info IS
     SELECT created_by, status_code, action_code, act_metric_used_by_id
     FROM   ozf_act_metrics_all
     WHERE  activity_metric_id = p_alloc_id;

  CURSOR c_get_all_facts IS
     SELECT activity_metric_fact_id, object_version_number, act_metric_used_by_id
     FROM   ozf_act_metric_facts_all
     WHERE  activity_metric_id = p_alloc_id;

  CURSOR c_get_fund_info(p_fund_id NUMBER) IS
     SELECT object_version_number, owner, short_name, fund_type
     FROM   ozf_funds_all_vl
     WHERE  fund_id = p_fund_id;

 CURSOR c_get_root_fund_info(p_fund_id NUMBER) IS
     SELECT  fund_type
     FROM   ozf_funds_all_vl
     WHERE  fund_id = p_fund_id;

BEGIN
  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message(l_full_name || ': start');
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  OPEN c_get_metric_info;
  FETCH c_get_metric_info INTO l_alloc_creator, l_alloc_old_status, l_alloc_action_code, l_root_fund_id;
  CLOSE c_get_metric_info;

  OPEN c_get_root_fund_info(l_root_fund_id);
  FETCH c_get_root_fund_info INTO  l_root_fund_type;
  CLOSE c_get_root_fund_info;


  -- only the allocation creator can activate allocation
  IF l_alloc_creator <> NVL(fnd_global.user_id, -1) THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        IF l_root_fund_type = 'QUOTA' THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_ALLOCNOTOWNER_ERROR');
        ELSE
           FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_ALLOCNOTOWNER_ERROR');
        END IF;
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- statuses other than NEW or PLANNED are not allowed changed to CANCELLED
  IF l_alloc_old_status <> 'NEW' AND l_alloc_old_status <> 'PLANNED' THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_ALLOCSTATUS_ERROR');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* allocation status 'NEW' or 'PLANNED' -> 'CANCELLED' */
  Ozf_Actmetric_Pvt.Init_ActMetric_Rec(l_metric_rec);
  l_metric_rec.activity_metric_id := p_alloc_id;
  l_metric_rec.status_code := 'CANCELLED';
  l_metric_rec.object_version_number := p_alloc_obj_ver;
  l_metric_rec.act_metric_date := sysdate;
  Ozf_Actmetric_Pvt.update_Actmetric( p_api_version    => p_api_version
                                     , p_init_msg_list     => fnd_api.g_false
                                     , p_commit            => fnd_api.g_false
                                     , p_validation_level  => fnd_api.g_valid_level_full
                                     , x_return_status     => x_return_status
                                     , x_msg_count         => x_msg_count
                                     , x_msg_data          => x_msg_data
                                     , p_act_metric_rec    => l_metric_rec
                                     );
  -- dbms_output.put_line(l_full_name || 'set alloc status CANCELLED returns ' || x_return_status);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FOR fact_rec IN c_get_all_facts LOOP
      -- update child fact status as CANCELLED
      ozf_actmetricfact_pvt.init_actmetricfact_rec(l_metric_fact_rec);
      l_metric_fact_rec.activity_metric_fact_id := fact_rec.activity_metric_fact_id;
      l_metric_fact_rec.object_version_number := fact_rec.object_version_number;
      l_metric_fact_rec.status_code := 'CANCELLED';
      ozf_actmetricfact_Pvt.Update_ActMetricFact( p_api_version                => p_api_version
                         , p_init_msg_list              => fnd_api.g_true
                         , p_commit                     => fnd_api.g_false
                         , p_validation_level           => fnd_api.g_valid_level_full
                         , p_act_metric_fact_rec        => l_metric_fact_rec
                         , x_return_status              => x_return_status
                         , x_msg_count                  => x_msg_count
                         , x_msg_data                   => x_msg_data
                         );
      -- dbms_output.put_line(l_full_name || ': update child node fact id=' || fact_rec.activity_metric_fact_id || '  cancelled returns ' || x_return_status);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- if allocation already published, notify child budget owners
      -- if new budgets already created, update budgets as CANCELLED
      IF (l_alloc_old_status = 'PLANNED' AND fact_rec.act_metric_used_by_id <> l_root_fund_id) THEN
          -- however, do not cancel root budget. This is possible only when exclude_start_node is checked
          OPEN c_get_fund_info(fact_rec.act_metric_used_by_id);
          FETCH c_get_fund_info INTO l_fund_obj_ver, l_fund_owner, l_fund_name, l_fund_type;
          CLOSE c_get_fund_info;
          IF (l_alloc_action_code = 'CREATE_NEW_BUDGET') THEN
              -- cancell the child budget
              ozf_funds_pvt.init_fund_rec (l_fund_rec);
              l_fund_rec.fund_id := fact_rec.act_metric_used_by_id;
              l_fund_rec.object_version_number := l_fund_obj_ver;
              l_fund_rec.status_code := 'CANCELLED';
              ozf_funds_pvt.update_fund( p_api_version        => p_api_version
                                       , p_init_msg_list      => fnd_api.g_true
                                       , p_commit             => fnd_api.g_false
                                       , p_validation_level   => fnd_api.g_valid_level_full
                                       , p_fund_rec           => l_fund_rec
                                       , x_return_status      => x_return_status
                                       , x_msg_count          => x_msg_count
                                       , x_msg_data           => x_msg_data
                                       );
            -- dbms_output.put_line(l_full_name || ': update_fund to cancelled returns ' || x_return_status || ' budget id=' || l_fund_rec.fund_id);
              IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END IF;

          /* send notification to child budget owner */
          IF l_fund_type = 'QUOTA' THEN
            ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
            p_lookup_code   => 'QUOTA',
            x_return_status => l_temp_status,
            x_meaning       => l_fund_meaning);
          ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
            ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                                                p_lookup_code   => 'BUDGET',
                                                x_return_status => l_temp_status,
                                                x_meaning       => l_fund_meaning);
          END IF;
          fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_CANCEL_SUB');
          fnd_message.set_token('BUDGET_NAME', l_fund_name);
          fnd_message.set_token('ALLOC_ID', p_alloc_id);
          fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
          l_notif_subject := substrb(fnd_message.get, 1, 400);
          fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_CANCEL_BODY');
          fnd_message.set_token ('BUDGET_NAME', l_fund_name);
          fnd_message.set_token ('ALLOC_ID', p_alloc_id);
          fnd_message.set_token ('ALLOC_STATUS', 'CANCELLED');
          fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
          l_notif_body := substrb(fnd_message.get, 1, 4000);

          ozf_utility_pvt.send_wf_standalone_message(
            p_subject            =>  l_notif_subject
          , p_body               =>  l_notif_body
          , p_send_to_res_id     =>  l_fund_owner
          , x_notif_id           =>  l_return_id
          , x_return_status      =>  x_return_status
          );
        -- dbms_output.put_line(l_full_name || ': send notificaiton returns ' || x_return_status);
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;  -- IF (l_alloc_old_status == 'PLANNED') THEN
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
      -- dbms_output.put_line(l_full_name || 'exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END cancel_allocation;


---------------------------------------------------------------------
-- PROCEDURE
---   update_alloc_status
--
-- PURPOSE
--    Update allocation status
--    public api called by worksheet page update button
--
-- HISTORY
--    09/23/02  yzhao  Created.
--
-- PARAMETERS
---------------------------------------------------------------------
PROCEDURE update_alloc_status(
    p_api_version        IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2
  , p_commit             IN       VARCHAR2
  , p_validation_level   IN       NUMBER
  , p_alloc_id           IN       NUMBER
  , p_alloc_status       IN       VARCHAR2
  , p_alloc_obj_ver      IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
)
IS
  l_old_alloc_status     VARCHAR2(30);
  l_valid_change         BOOLEAN;

  CURSOR c_get_alloc_status IS
     SELECT status_code
     FROM   ozf_act_metrics_all
     WHERE  activity_metric_id = p_alloc_id;
BEGIN
  SAVEPOINT update_alloc_status_sp;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;

  OPEN c_get_alloc_status;
  FETCH c_get_alloc_status INTO l_old_alloc_status;
  CLOSE c_get_alloc_status;

-- dbms_output.put_line('zy: update_alloc_status(): old_status=' || l_old_alloc_status || '  new_status='  || p_alloc_status);
  IF (p_alloc_status = l_old_alloc_status) THEN
     -- no status change, does nothing.
     RETURN;
  END IF;

  l_valid_change := FALSE;
  -- Following status are allowed: NEW -> CANCELLED; PLANNED -> ACTIVE/CANCELLED
  IF l_old_alloc_status = 'NEW' THEN
     IF p_alloc_status = 'ACTIVE' THEN
        -- workaround: NEW -> ACTIVE is not allowed. But not throw error, just do nothing.
        l_valid_change := TRUE;
     ELSIF p_alloc_status = 'CANCELLED' THEN
        l_valid_change := TRUE;
        cancel_allocation(p_api_version         => p_api_version,
                          p_alloc_id            => p_alloc_id,
                          p_alloc_obj_ver       => p_alloc_obj_ver,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data);
     END IF;
  ELSIF l_old_alloc_status = 'PLANNED' THEN
     IF p_alloc_status = 'ACTIVE' THEN
        l_valid_change := TRUE;
        activate_allocation(p_api_version         => p_api_version,
                            p_alloc_id            => p_alloc_id,
                            p_alloc_obj_ver       => p_alloc_obj_ver,
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data);
     ELSIF p_alloc_status = 'CANCELLED' THEN
        l_valid_change := TRUE;
        cancel_allocation(p_api_version         => p_api_version,
                          p_alloc_id            => p_alloc_id,
                          p_alloc_obj_ver       => p_alloc_obj_ver,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data);
     END IF;
  END IF;

  IF not l_valid_change THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_ALLOCSTATUS_ERROR');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     commit;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO update_alloc_status_sp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- dbms_output.put_line('update_alloc_status: exception - ' || substr(sqlerrm, 1, 200));
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END update_alloc_status;


----------------------------------------------------------------------------------------
-- This Procedure will approve a published allocation called by bottom-up budgeting   --
--   the approver's fact record must be active to approve its children                --
--   approve all levels below, or next level only                                     --
--   create budget transfer record                                                    --
--   update child node status as 'ACTIVE'                                             --
--   send notification to child budget owner                                          --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_approver_fact_id  the approver's fact id. null means approver is the root budget --
-- p_approve_all_flag  Y - approve all levels below; N - approve the next level only  --
-- p_factid_table      children fact ids to be approved                               --
----------------------------------------------------------------------------------------
Procedure approve_levels(p_api_version         IN     NUMBER,
                         p_init_msg_list       IN     VARCHAR2,
                         p_commit              IN     VARCHAR2,
                         p_validation_level    IN     NUMBER,
                         p_approver_factid     IN     NUMBER,
                         p_approve_all_flag    IN     VARCHAR2,
                         p_factid_table        IN     factid_table_type,
                         x_return_status       OUT NOCOPY    VARCHAR2,
                         x_msg_count           OUT NOCOPY    NUMBER,
                         x_msg_data            OUT NOCOPY    VARCHAR2
)
IS
  l_return_status            VARCHAR2(2);
  l_alloc_action_code        VARCHAR2(30);
  l_approver_status          VARCHAR2(30) := null;
  l_approved_total           NUMBER;
  l_approved_hb              NUMBER;
  l_parent_fund_id           NUMBER;
  l_parent_fact_id           NUMBER;
  l_fund_id                  NUMBER;
  l_fact_id                  NUMBER;
  l_alloc_id                 NUMBER;
  l_fact_status              VARCHAR2(30);
  l_recommend_total          NUMBER;
  l_recommend_hb             NUMBER;
  l_request_total            NUMBER;
  l_request_hb               NUMBER;

  CURSOR c_get_alloc_status(p_fact_id NUMBER) IS
    SELECT status_code, action_code, activity_metric_id
    FROM   ozf_act_metrics_all
    WHERE  activity_metric_id = (SELECT activity_metric_id
                                 FROM   ozf_act_metric_facts_all
                                 WHERE  activity_metric_fact_id = p_fact_id);

  CURSOR c_get_fact_status(p_fact_id NUMBER) IS
    SELECT status_code
    FROM   ozf_act_metric_facts_all
    WHERE  activity_metric_fact_id = p_fact_id;

  CURSOR c_get_one_level(p_fact_id NUMBER) IS
    SELECT status_code, act_metric_used_by_id, previous_fact_id
         , recommend_total_amount, recommend_hb_amount
         , request_total_amount, request_hb_amount
    FROM   ozf_act_metric_facts_all
    WHERE  activity_metric_fact_id = p_fact_id
    AND    previous_fact_id = p_approver_factid;    -- to guarantee it approves next level only

  CURSOR c_get_all_levels(p_fact_id NUMBER) IS
    SELECT activity_metric_fact_id, object_version_number
         , status_code, act_metric_used_by_id, previous_fact_id
         , recommend_total_amount, recommend_hb_amount
         , request_total_amount, request_hb_amount
    FROM   ozf_act_metric_facts_all
    CONNECT BY prior activity_metric_fact_id = previous_fact_id
    START WITH previous_fact_id = p_fact_id
    ORDER BY level_depth;

BEGIN
  SAVEPOINT approve_levels_sp;
  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('approve_levels(): start');
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  IF p_factid_table.COUNT = 0 THEN
     RETURN;
  END IF;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;

  OPEN c_get_alloc_status(p_factid_table(p_factid_table.FIRST).fact_id);
  FETCH c_get_alloc_status INTO l_approver_status, l_alloc_action_code, l_alloc_id;
  CLOSE c_get_alloc_status;

  IF (p_approver_factid IS NOT NULL) THEN
     -- root budget is not the approver, so get actual approver fact status
     OPEN c_get_fact_status(p_approver_factid);
     FETCH c_get_fact_status INTO l_approver_status;
     CLOSE c_get_fact_status;
  END IF;

  -- approver's status must be active to approve allocation
  IF l_approver_status <> 'ACTIVE' THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name ('OZF', 'OZF_FUND_ALLOCAPPROVE_ERROR');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR I IN p_factid_table.FIRST .. p_factid_table.LAST LOOP
      l_fact_status := NULL;
      OPEN c_get_one_level(p_factid_table(I).fact_id);
      FETCH c_get_one_level
      INTO l_fact_status, l_fund_id, l_parent_fact_id
         , l_recommend_total, l_recommend_hb
         , l_request_total, l_request_hb;
      CLOSE c_get_one_level;

      IF (l_fact_status = 'PLANNED' OR l_fact_status = 'REJECTED' OR l_fact_status = 'SUBMITTED') THEN
          IF (p_factid_table(I).approve_recommend = 'Y') THEN
              l_approved_total := l_recommend_total;
              l_approved_hb := l_recommend_hb;
          ELSE
              l_approved_total := l_request_total;
              l_approved_hb := l_request_hb;
          END IF;
          -- activate child fact, create fund request between parent budget and child budget, send notification to child budget owner
          activate_one_node( p_api_version         => p_api_version,
                             p_alloc_id            => l_alloc_id,
                             p_child_fact_id       => p_factid_table(I).fact_id,
                             p_child_fact_obj_ver  => p_factid_table(I).fact_obj_ver,
                             p_approved_total      => l_approved_total,
                             p_approved_hb         => l_approved_hb,
                             p_alloc_action_code   => l_alloc_action_code,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data);
          -- dbms_output.put_line('approve_levels(): one node ' || p_factid_table(I).fact_id || ' returns ' || x_return_status);
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          l_fact_status := 'ACTIVE';
      END IF;

      IF p_approve_all_flag = 'Y' AND l_fact_status = 'ACTIVE' THEN
          FOR fact_rec IN c_get_all_levels(p_factid_table(I).fact_id) LOOP
              IF (fact_rec.status_code = 'PLANNED' OR fact_rec.status_code = 'REJECTED' OR fact_rec.status_code = 'SUBMITTED') THEN
                  IF (p_factid_table(I).approve_recommend = 'Y') THEN
                      l_approved_total := fact_rec.recommend_total_amount;
                      l_approved_hb := fact_rec.recommend_hb_amount;
                  ELSE
                      l_approved_total := fact_rec.request_total_amount;
                      l_approved_hb := fact_rec.request_hb_amount;
                  END IF;
                  -- activate child fact, create fund request between parent budget and child budget, send notification to child budget owner
                  activate_one_node(p_api_version         => p_api_version,
                                    p_alloc_id            => l_alloc_id,
                                    p_child_fact_id       => fact_rec.activity_metric_fact_id,
                                    p_child_fact_obj_ver  => fact_rec.object_version_number,
                                    p_approved_total      => l_approved_total,
                                    p_approved_hb         => l_approved_hb,
                                    p_alloc_action_code   => l_alloc_action_code,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => x_msg_count,
                                    x_msg_data            => x_msg_data);
                  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
              END IF;
          END LOOP;
      END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
-- dbms_output.put_line('approve_levels(): exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      ROLLBACK TO approve_levels_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END approve_levels;


----------------------------------------------------------------------------------------
-- This Procedure will submit user's requested total and holdback amount              --
--   only allocation in 'PLANNED' or 'REJECTED' status can user submit request        --
--   update this node allocation status as 'SUBMITTED'                                --
--   send notification to parent budget owner                                         --
--   record justificaiton note if any                                                 --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_fact_id         fact id                                                          --
-- p_fact_obj_ver    fact object version number                                       --
-- p_note            justification note if any                                        --
----------------------------------------------------------------------------------------
Procedure submit_request(p_api_version         IN     NUMBER,
                         p_init_msg_list       IN     VARCHAR2,
                         p_commit              IN     VARCHAR2,
                         p_validation_level    IN     NUMBER,
                         p_fact_id             IN     NUMBER,
                         p_fact_obj_ver        IN     NUMBER,
                         p_note                IN     VARCHAR2,
                         x_return_status       OUT NOCOPY    VARCHAR2,
                         x_msg_count           OUT NOCOPY    NUMBER,
                         x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_alloc_status         VARCHAR2(30);
  l_alloc_id             NUMBER;
  l_parent_fact_id       NUMBER;
  l_parent_budget_owner  NUMBER;
  l_fund_name            ozf_funds_all_tl.short_name%TYPE;
  l_currency_code        ozf_funds_all_b.currency_code_tc%TYPE;
  l_request_total        NUMBER;
  l_request_hb           NUMBER;
  l_return_status        VARCHAR2(2);
  l_notif_subject        VARCHAR2(400);
  l_notif_body           VARCHAR2(4000);
  l_return_id            NUMBER;
  l_fact_rec             Ozf_Actmetricfact_Pvt.act_metric_fact_rec_type;
  l_fund_type            VARCHAR2(30) := NULL;
  l_fund_meaning         VARCHAR2(240) := NULL;
  l_temp_status          VARCHAR2(1);

  CURSOR c_get_fact_info IS
    SELECT  fact.status_code, fact.previous_fact_id, fact.activity_metric_id
          , fact.request_total_amount, fact.request_hb_amount, fund.short_name, fund.fund_type
    FROM    ozf_act_metric_facts_all fact, ozf_funds_all_vl fund
    WHERE   fact.activity_metric_fact_id = p_fact_id
    AND     fact.act_metric_used_by_id = fund.fund_id;

  CURSOR c_get_fact_budget_owner(p_lfact_id NUMBER) IS
    SELECT owner, currency_code_tc
    FROM   ozf_funds_all_b
    WHERE  fund_id = (SELECT act_metric_used_by_id
                      FROM   ozf_act_metric_facts_all
                      WHERE  activity_metric_fact_id = p_lfact_id
                      AND    arc_act_metric_used_by = 'FUND');

  CURSOR c_get_alloc_budget_owner(p_lalloc_id NUMBER) IS
    SELECT owner, currency_code_tc
    FROM   ozf_funds_all_b
    WHERE  fund_id = (SELECT act_metric_used_by_id
                      FROM   ozf_act_metrics_all
                      WHERE  activity_metric_id = p_lalloc_id
                      AND    arc_act_metric_used_by = 'FUND');

BEGIN
  SAVEPOINT submit_request_sp;
  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('submit_request(): start');
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;

  OPEN c_get_fact_info;
  FETCH c_get_fact_info INTO l_alloc_status, l_parent_fact_id, l_alloc_id, l_request_total, l_request_hb, l_fund_name, l_fund_type;
  CLOSE c_get_fact_info;

  -- only allocation in 'PLANNED' or 'REJECTED' status can user submit request
  --  not returning error message here since submit is not exposted to user from UI for this case
  IF (l_alloc_status <> 'PLANNED' AND l_alloc_status <> 'REJECTED') THEN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message('submit_request(): only planned or rejected can submit. status=' || l_alloc_status);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- update this node allocation status as 'SUBMITTED'
   Ozf_Actmetricfact_Pvt.Init_ActMetricFact_Rec(x_fact_rec => l_fact_rec);
   l_fact_rec.activity_metric_fact_id := p_fact_id;
   l_fact_rec.object_version_number := p_fact_obj_ver;
   l_fact_rec.status_code := 'SUBMITTED';
   -- update table ozf_act_metric_facts
   ozf_actmetricfact_Pvt.update_actmetricfact(
     p_api_version                => p_api_version,
     p_init_msg_list              => fnd_api.g_false,
     p_commit                     => fnd_api.g_false,
     p_validation_level           => fnd_api.g_valid_level_full,
     x_return_status              => l_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_act_metric_fact_rec        => l_fact_rec
   );
   -- dbms_output.put_line('update fact percentage ' || l_fact_rec.activity_metric_fact_id || ' returns ' || l_return_status);
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  --  send notification to parent budget owner
  IF l_parent_fact_id IS NULL THEN
      OPEN c_get_alloc_budget_owner(l_alloc_id);
      FETCH c_get_alloc_budget_owner INTO l_parent_budget_owner, l_currency_code;
      CLOSE c_get_alloc_budget_owner;
  ELSE
      OPEN c_get_fact_budget_owner(l_parent_fact_id);
      FETCH c_get_fact_budget_owner INTO l_parent_budget_owner, l_currency_code;
      CLOSE c_get_fact_budget_owner;
  END IF;

  -- create note
  IF p_note IS NOT NULL THEN
     jtf_notes_pub.create_note (
            p_api_version        => 1.0
           ,p_source_object_id   => p_fact_id
           ,p_source_object_code => 'AMS_ALCT'
           ,p_notes              => p_note
           ,p_note_status        => NULL
           ,p_entered_by         => fnd_global.user_id
           ,p_entered_date       => SYSDATE
           ,p_last_updated_by    => fnd_global.user_id
           ,x_jtf_note_id        => l_return_id
           ,p_note_type          => 'AMS_JUSTIFICATION'
           ,p_last_update_date   => SYSDATE
           ,p_creation_date      => SYSDATE
           ,x_return_status      => l_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
         );

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;
  END IF;

  /* send request notice to parent budget owner  */
  IF l_fund_type = 'QUOTA' THEN
    ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                                        p_lookup_code   => 'QUOTA',
                                        x_return_status => l_temp_status,
                                        x_meaning       => l_fund_meaning);
  ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
    ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                                        p_lookup_code   => 'BUDGET',
                                        x_return_status => l_temp_status,
                                        x_meaning       => l_fund_meaning);
  END IF;
  l_notif_body := NULL;
  fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_SUBMIT_SUB');
  fnd_message.set_token('BUDGET_NAME', l_fund_name);
  fnd_message.set_token('ALLOC_ID', l_alloc_id);
  fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
  l_notif_subject := substrb(fnd_message.get, 1, 400);
  fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_SUBMIT_BODY');
  fnd_message.set_token ('BUDGET_NAME', l_fund_name);
  fnd_message.set_token('ALLOC_ID', l_alloc_id);
  fnd_message.set_token ('CURRENCY_CODE', l_currency_code);
  fnd_message.set_token ('TOTAL_AMOUNT', l_request_total);
  fnd_message.set_token ('REQUESTOR_NOTE', p_note);
  fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
  l_notif_body := substrb(fnd_message.get, 1, 4000);

  ozf_utility_pvt.send_wf_standalone_message(
      p_subject            =>  l_notif_subject
    , p_body               =>  l_notif_body
    , p_send_to_res_id     =>  l_parent_budget_owner
    , x_notif_id           =>  l_return_id
    , x_return_status      =>  l_return_status
    );
  -- dbms_output.put_line('submit_request(): send notificaiton returns ' || l_return_status);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
-- dbms_output.put_line('submit_request(): exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      ROLLBACK TO submit_request_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END submit_request;


----------------------------------------------------------------------------------------
-- This Procedure will reject user's requested total and holdback amount              --
--   only allocation in 'PLANNED' or 'ACTIVE' status can user reject request          --
--   called by top or bottom level user                                               --
--   update the child node allocation status as 'REJECTED'                            --
--   send notification to child budget owners                                         --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_rejector_fact_id     rejector's fact id. If null, means the root budget          --
-- p_factid_table         child fact ids to be rejected                               --
----------------------------------------------------------------------------------------
Procedure reject_request(p_api_version         IN     NUMBER,
                         p_init_msg_list       IN     VARCHAR2,
                         p_commit              IN     VARCHAR2,
                         p_validation_level    IN     NUMBER,
                         p_rejector_factid     IN     NUMBER,
                         p_factid_table        IN     factid_table_type,
                         x_return_status       OUT NOCOPY    VARCHAR2,
                         x_msg_count           OUT NOCOPY    NUMBER,
                         x_msg_data            OUT NOCOPY    VARCHAR2)
IS
  l_budget_owner         NUMBER;
  l_budget_name          ozf_funds_all_tl.short_name%TYPE;
  l_budget_currency      ozf_funds_all_b.currency_code_tc%TYPE;
  l_alloc_id             NUMBER;
  l_fact_old_status      VARCHAR2(30);
  l_request_total        NUMBER;
  l_request_hb           NUMBER;
  l_return_status        VARCHAR2(2);
  l_notif_subject        VARCHAR2(400);
  l_notif_body           VARCHAR2(4000);
  l_return_id            NUMBER;
  l_fact_rec             Ozf_Actmetricfact_Pvt.act_metric_fact_rec_type;
  l_fund_type            VARCHAR2(30) := NULL;
  l_fund_meaning         VARCHAR2(240) := NULL;
  l_temp_status          VARCHAR2(1);

  CURSOR c_get_fact_info(p_fact_id NUMBER) IS
    SELECT  fund.owner, fund.short_name, fund.currency_code_tc
          , fact.status_code, fact.request_total_amount, fact.request_hb_amount
          , fact.activity_metric_id, fund.fund_type
    FROM    ozf_act_metric_facts_all fact, ozf_funds_all_vl fund
    WHERE   fact.activity_metric_fact_id = p_fact_id
    AND     fact.arc_act_metric_used_by = 'FUND'
    AND     fact.act_metric_used_by_id = fund.fund_id;

BEGIN
  SAVEPOINT reject_request_sp;
  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('reject_request(): start');
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;

  /* only allocation in 'PLANNED' or 'ACTIVE' status can user reject request
  IF (l_alloc_status <> 'PLANNED' AND l_alloc_status <> 'APPROVED') THEN
      return;
  END IF;
  */

  FOR i IN p_factid_table.FIRST .. p_factid_table.LAST LOOP
      -- update this node allocation status as 'REJECTED'

      OPEN c_get_fact_info(p_factid_table(i).fact_id);
      FETCH c_get_fact_info INTO l_budget_owner, l_budget_name, l_budget_currency
                               , l_fact_old_status, l_request_total, l_request_hb, l_alloc_id, l_fund_type;
      CLOSE c_get_fact_info;

      -- do nothing if user rejects an already rejected/active node
      IF l_fact_old_status <> 'REJECTED' AND l_fact_old_status <> 'ACTIVE' THEN
          Ozf_Actmetricfact_Pvt.Init_ActMetricFact_Rec(x_fact_rec => l_fact_rec);
          l_fact_rec.activity_metric_fact_id := p_factid_table(i).fact_id;
          l_fact_rec.object_version_number := p_factid_table(i).fact_obj_ver;
          l_fact_rec.status_code := 'REJECTED';
          -- update table ozf_act_metric_facts
          ozf_actmetricfact_Pvt.update_actmetricfact(
             p_api_version                => p_api_version,
             p_init_msg_list              => fnd_api.g_false,
             p_commit                     => fnd_api.g_false,
             p_validation_level           => fnd_api.g_valid_level_full,
             x_return_status              => l_return_status,
             x_msg_count                  => x_msg_count,
             x_msg_data                   => x_msg_data,
             p_act_metric_fact_rec        => l_fact_rec
          );
          -- dbms_output.put_line('update fact as rejected ' || l_fact_rec.activity_metric_fact_id || ' returns ' || l_return_status);
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          --  send notification to child budget owner of rejection
          IF l_fund_type = 'QUOTA' THEN
            ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                                                p_lookup_code   => 'QUOTA',
                                                x_return_status => l_temp_status,
                                                x_meaning       => l_fund_meaning);
          ELSIF l_fund_type IN ('FIXED', 'FULLY_ACCRUED') THEN
            ozf_utility_pvt.get_lookup_meaning (p_lookup_type   => 'OZF_FUND_NTF_TYPE',
                                                p_lookup_code   => 'BUDGET',
                                                x_return_status => l_temp_status,
                                                x_meaning       => l_fund_meaning);
          END IF;
          fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_REJECT_SUB');
          fnd_message.set_token('BUDGET_NAME', l_budget_name);
          fnd_message.set_token('ALLOC_ID', l_alloc_id);
          fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
          l_notif_subject := substrb(fnd_message.get, 1, 400);
          fnd_message.set_name('OZF', 'OZF_NTF_ALLOC_REJECT_BODY');
          fnd_message.set_token ('BUDGET_NAME', l_budget_name);
          fnd_message.set_token('ALLOC_ID', l_alloc_id);
          fnd_message.set_token ('ALLOC_STATUS', 'REJECTED');
          fnd_message.set_token ('CURRENCY_CODE', l_budget_currency);
          fnd_message.set_token ('REQUESTED_TOTAL_AMOUNT', ams_utility_pvt.CurrRound(l_request_total,l_budget_currency));
          fnd_message.set_token ('FUND_TYPE', l_fund_meaning, FALSE);
          l_notif_body := substrb(fnd_message.get, 1, 4000);

          ozf_utility_pvt.send_wf_standalone_message(
              p_subject            =>  l_notif_subject
            , p_body               =>  l_notif_body
            , p_send_to_res_id     =>  l_budget_owner
            , x_notif_id           =>  l_return_id
            , x_return_status      =>  l_return_status
            );
          -- dbms_output.put_line('reject_request(): send notificaiton returns ' || l_return_status);
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
-- dbms_output.put_line('reject_request(): exception errcode=' || sqlcode || ' :' || substr(sqlerrm, 1, 150));
      ROLLBACK TO reject_request_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => x_msg_count
        , p_data => x_msg_data);
END reject_request;


END OZF_Fund_allocations_Pvt;


/
