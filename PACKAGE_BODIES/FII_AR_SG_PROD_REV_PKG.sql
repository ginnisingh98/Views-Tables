--------------------------------------------------------
--  DDL for Package Body FII_AR_SG_PROD_REV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_SG_PROD_REV_PKG" AS
/* $Header: FIIARSGPRB.pls 120.1 2005/07/01 13:34:50 arcdixit noship $ */

PROCEDURE get_sg_prod_rev
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       get_sg_prod_rev_sql out NOCOPY VARCHAR2,
       get_sg_prod_rev_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS

    -- declaration section

sqlstmt			VARCHAR2(10000);
get_sg_prod_rev_rec	BIS_QUERY_ATTRIBUTES;
l_curr			VARCHAR2(100);
l_sgid			VARCHAR2(100);
l_prod_cat		VARCHAR2(100);
l_cust			VARCHAR2(100);
l_view_by		VARCHAR2(100);
l_period_type		VARCHAR2(100);
l_as_of_date		DATE;
l_record_type_id	NUMBER;
l_one_period_back	DATE;
l_two_period_back	DATE;
l_three_period_back	DATE;
l_inner_sql		VARCHAR2(10000);
l_sg_where     		VARCHAR2(240);
l_prod_cat_from		VARCHAR2(240);
l_prod_cat_where	VARCHAR2(1000);
l_cust_where		VARCHAR2(240);
l_viewby_col		VARCHAR2(200);
l_sg_sg			NUMBER;
l_sg_res		NUMBER;
l_cat_join		VARCHAR2(50);
l_mv_to_be_used		VARCHAR2(100);
l_curr_g		VARCHAR2(15) := '''FII_GLOBAL1''';
l_curr_suffix		VARCHAR2(120);
l_record_id		NUMBER;
l_pertype_for_booked	VARCHAR2(120);
l_cust_flag             NUMBER;
l_item_cat_flag         NUMBER;
l_flags                 VARCHAR2(120);

l_order                 varchar2(200);
l_sort                 varchar2(200);

BEGIN

-- Retrieve parameter info

FII_AR_Util.reset_globals;
FII_AR_Util.Get_Parameters(p_page_parameter_tbl);

l_curr := FII_AR_Util.p_curr;
l_sgid:= FII_AR_Util.p_sgid;
l_prod_cat := FII_AR_Util.p_prod_cat;
l_cust := FII_AR_Util.p_cust;
l_view_by := FII_AR_Util.p_view_by;
l_period_type := FII_AR_Util.p_period_type;
l_as_of_date := FII_AR_Util.p_as_of_date;
l_record_type_id := FII_AR_Util.p_record_type_id;




 IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'ORDERBY' THEN
          l_order := p_page_parameter_tbl(i).parameter_value;
       END IF;
     END LOOP;
  END IF;


-- If primary global currency chosen, then, use recognized_amt_g else use recognized_amt_g1

IF (l_curr = l_curr_g)
    THEN l_curr_suffix := 'g';
    ELSE l_curr_suffix := 'g1';
END IF;


  l_sg_sg   := to_number(replace(substr(l_sgid,instr(l_sgid,'.') + 1),''''));
  l_sg_res  := to_number(replace(substr(l_sgid,1,instr(l_sgid,'.') - 1),''''));

 IF (l_sg_res IS NULL) -- when a sales group is chosen
    THEN
      IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'
        THEN
          l_sg_where := '
                AND f.parent_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP)
                AND f.grp_marker <> ''TOP GROUP'''; -- exclude the top groups when ViewBy = Sales Group
	ELSE -- other view bys
          l_sg_where := '
                AND f.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP)
                AND f.resource_id IS NULL';
	END IF;
 ELSE -- when the LOV parameter is a Sales Rep
	l_sg_where := '
                AND f.sales_grp_id = :FII_SG_SG
                AND f.resource_id = :FII_SG_RES ';
 END IF;


 IF (l_cust IS NULL) THEN
    l_cust_where:='';

    IF(l_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_cust_flag := 0;
    ELSE
       l_cust_flag := 1; -- do not need customer id
    END IF;
  ELSE
    l_cust_where :='
                AND f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
    l_cust_flag := 0; -- customer level
 END IF;


  IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' OR l_prod_cat IS NOT NULL)
    THEN l_item_cat_flag := 0; -- Product Category
    ELSE l_item_cat_flag := 1; -- All
  END IF;



IF (l_view_by <> 'CUSTOMER+FII_CUSTOMERS' AND l_cust IS NULL) THEN -- use double rollup MV without customer dimension

    l_mv_to_be_used := 'ISC_DBI_SCR_002_MV';
    IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN

      l_prod_cat_from := ',
                        ENI_DENORM_HIERARCHIES          eni_cat,
                        MTL_DEFAULT_CATEGORY_SETS       mdcs';
        IF (l_prod_cat IS NULL) THEN
                l_prod_cat_where := '
                AND f.cat_top_node_flag = ''Y''
                AND f.item_category_id = eni_cat.imm_child_id
                AND eni_cat.top_node_flag = ''Y''
                AND eni_cat.dbi_flag = ''Y''
                AND eni_cat.object_type = ''CATEGORY_SET''
                AND eni_cat.object_id = mdcs.category_set_id
                AND mdcs.functional_area_id = 11';
        ELSE l_prod_cat_where := '
                AND f.item_category_id = eni_cat.imm_child_id
                AND ((eni_cat.leaf_node_flag = ''N'' and
                        eni_cat.child_id <> eni_cat.parent_id and imm_child_id = child_id)
                        OR (eni_cat.leaf_node_flag = ''Y''))
                AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
                AND eni_cat.dbi_flag = ''Y''
                AND eni_cat.object_type = ''CATEGORY_SET''
                AND eni_cat.object_id = mdcs.category_set_id
                AND mdcs.functional_area_id = 11';
        END IF;

    ELSE -- view by <> category

      l_prod_cat_from := '';

      IF (l_prod_cat IS NULL) THEN --
		l_prod_cat_where :=' AND f.cat_top_node_flag = ''Y''';
      ELSE -- view by sales group, product category selected
		l_prod_cat_where :=' AND f.item_category_id IN (&ITEM+ENI_ITEM_VBH_CAT)';
      END IF;

    END IF;

  ELSE -- use single rollup with customer dimension

    l_flags := '
                AND f.item_cat_flag = :FII_ITEM_CAT_FLAG
                AND f.customer_flag = :FII_CUST  ';


    l_mv_to_be_used := 'ISC_DBI_SCR_001_MV';
    IF (l_prod_cat IS NULL) THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
        l_prod_cat_from := ',
                ENI_DENORM_HIERARCHIES          eni_cat,
                MTL_DEFAULT_CATEGORY_SETS       mdcs';
        l_prod_cat_where := '
            AND f.item_category_id = eni_cat.child_id
            AND eni_cat.top_node_flag = ''Y''
            AND eni_cat.dbi_flag = ''Y''
            AND eni_cat.object_type = ''CATEGORY_SET''
            AND eni_cat.object_id = mdcs.category_set_id
            AND mdcs.functional_area_id = 11';
      ELSE
        l_prod_cat_from := '';
        l_prod_cat_where := '';
      END IF;

    ELSE -- a prod cat has been selected
       l_prod_cat_from := ',
                ENI_DENORM_HIERARCHIES          eni_cat,
                MTL_DEFAULT_CATEGORY_SETS       mdcs';
       l_prod_cat_where := '
            AND f.item_category_id = eni_cat.child_id
            AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
            AND eni_cat.dbi_flag = ''Y''
            AND eni_cat.object_type = ''CATEGORY_SET''
            AND eni_cat.object_id = mdcs.category_set_id
            AND mdcs.functional_area_id = 11';

   END IF;

  END IF;

-- CASE statement below assigns dates to different variables(in order to go one,two or three periods back)

    CASE l_period_type

      WHEN 'FII_TIME_WEEK'	THEN
		l_one_period_back := NULL;
		l_two_period_back := NULL;
		l_three_period_back := NULL;
		l_record_id := 1;
		l_pertype_for_booked := 'wk';

      WHEN 'FII_TIME_ENT_PERIOD'	THEN
		l_one_period_back:= NULL;
		l_two_period_back := NULL;
		l_three_period_back:= NULL;
		l_record_id := 1;
		l_pertype_for_booked := 'pe';

      WHEN 'FII_TIME_ENT_QTR'    THEN
		l_one_period_back := fii_time_api.ent_pper_end (l_as_of_date);
		l_two_period_back := fii_time_api.ent_pper_end (l_one_period_back);
		l_three_period_back := NULL;
		l_record_id := 64;
		l_pertype_for_booked := 'qr';

      WHEN 'FII_TIME_ENT_YEAR'   THEN
		l_one_period_back := fii_time_api.ent_pqtr_end(l_as_of_date);
		l_two_period_back := fii_time_api.ent_pqtr_end(l_one_period_back);
		l_three_period_back:= fii_time_api.ent_pqtr_end(l_two_period_back);
		l_record_id := 128;
		l_pertype_for_booked := 'yr';

    END CASE;



IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN

	l_viewby_col :='resource_id, sales_grp_id';

ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN

	IF (l_prod_cat IS NULL) THEN

		l_viewby_col := 'parent_id';
	ElSE
		l_viewby_col :='imm_child_id';
	END IF;

ELSIF (l_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN

		l_viewby_col :='customer_id';
END IF;


-- l_order := ORDER_BY_CLAUSE;

IF INSTR(l_order,'ASC')  > 0
   THEN l_sort := 'ASC';
 ELSE
        l_sort := 'DESC';
END IF;

/*----------------------------------------------------------------------------------------------+
 |      VIEWBY			- Either Sales Group / Product Category / Customer		|
 |      VIEWBYID		- Either sales group id / product category id / customer id	|
 |	FII_SALES_GROUP_DRILL	- Drill on Sales Group						|
 |	FII_PROD_CAT_DRILL	- Drill on Product Category					|
 |      FII_HIST_COL1		- First column for historical data				|
 |      FII_HIST_COL2		- Second column for historical data				|
 |      FII_HIST_COL3		- Third column for historical data				|
 |      FII_HIST_COL4		- Fourth column for historical data				|
 |      FII_XTD_REV		- Period-to-date Revenue amount					|
 |      FII_PRIOR_XTD_REV	- Prior Period-to-date Revenue amount				|
 |	FII_XTD_BOOKED		- Period-to-date Booked amount					|
 |	FII_PRIOR_XTD_BOOKED	- Prior Period-to-date Booked amount				|
 |      FII_GT_HIST_COL1	- Grand Total of FII_HIST_COL1					|
 |      FII_GT_HIST_COL2	- Grand Total of FII_HIST_COL2					|
 |      FII_GT_HIST_COL3	- Grand Total of FII_HIST_COL3					|
 |      FII_GT_HIST_COL4	- Grand Total of FII_HIST_COL4					|
 |      FII_GT_XTD_REV		- Grand Total of FII_XTD_REV					|
 |      FII_GT_CHANGE		- Grand Total of Change column for revenue amount		|
 |	FII_GT_XTD_BOOKED	- Grand Total of FII_XTD_BOOKED					|
 |	FII_GT_CHANGE_BOOKED	- Grand Total of Change column for Booked amount		|
 +---------------------------------------------------------------------------------------------*/

-- Construct the inner sql (to be used inside the main sql)

-- for period type week and period, we do not show historical data so no need to do any UNION ALL. Here, we just get
-- values for PTD revenue, prior period PTD revenue(used to calculate change),
-- Booked revenue for current period and booked revenue for prior period(for change calculation)

	CASE l_period_type

	WHEN 'FII_TIME_WEEK' 	THEN

l_inner_sql := ' SUM(FII_HIST_COL1)         FII_HIST_COL1,
                SUM(FII_HIST_COL2)         FII_HIST_COL2,
                SUM(FII_HIST_COL3)         FII_HIST_COL3,
                SUM(FII_HIST_COL4)         FII_HIST_COL4,
                SUM(FII_XTD_REV)           FII_XTD_REV,
                SUM(FII_CHANGE)            FII_CHANGE,
                SUM(FII_PRIOR_XTD_REV)     FII_PRIOR_XTD_REV,
                SUM(FII_XTD_BOOKED)        FII_XTD_BOOKED,
                SUM(FII_CHANGE_BOOKED)     FII_CHANGE_BOOKED,
                SUM(FII_PRIOR_XTD_BOOKED)  FII_PRIOR_XTD_BOOKED,
		SUM(FII_BOOKED_PRIOR_XTD)  FII_BOOKED_PRIOR_XTD,
		SUM(FII_BOOKED_PRIOR_CHANGE)  FII_BOOKED_PRIOR_CHANGE,
                SUM(FII_GT_HIST_COL1)         FII_GT_HIST_COL1,
                SUM(FII_GT_HIST_COL2)         FII_GT_HIST_COL2,
                SUM(FII_GT_HIST_COL3)         FII_GT_HIST_COL3,
                SUM(FII_GT_HIST_COL4)         FII_GT_HIST_COL4,
                SUM(FII_GT_XTD_REV)           FII_GT_XTD_REV,
                SUM(FII_GT_XTD_BOOKED)     FII_GT_XTD_BOOKED,
                SUM(FII_GT_CHANGE)        FII_GT_CHANGE,
                SUM(FII_GT_CHANGE_BOOKED)  FII_GT_CHANGE_BOOKED,
		SUM(FII_GT_XTD_PRIOR_BOOKED)  FII_GT_XTD_PRIOR_BOOKED,
		SUM(FII_GT_PRIOR_BOOKED_CHANGE)  FII_GT_PRIOR_BOOKED_CHANGE
        FROM(
                SELECT          '||l_viewby_col||',
		SUM(FII_HIST_COL1)	FII_HIST_COL1,
		SUM(FII_HIST_COL2)	FII_HIST_COL2,
		SUM(FII_HIST_COL3)	FII_HIST_COL3,
		SUM(FII_HIST_COL4)	FII_HIST_COL4,
		SUM(FII_XTD_REV)	FII_XTD_REV,
                (((SUM(FII_XTD_REV) - SUM(PRIOR_REV)) / DECODE(SUM(PRIOR_REV),
                       0,NULL,SUM(PRIOR_REV))) *   100)        FII_CHANGE,
		SUM(PRIOR_REV)		FII_PRIOR_XTD_REV,
		SUM(FII_XTD_BOOKED)	FII_XTD_BOOKED,
                (((SUM(FII_XTD_BOOKED)  - SUM(PRIOR_BOOKED)) / DECODE(SUM(PRIOR_BOOKED),0,
                    NULL,SUM(PRIOR_BOOKED))) * 100)       FII_CHANGE_BOOKED,
		SUM(PRIOR_BOOKED)	FII_PRIOR_XTD_BOOKED,
		(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) FII_BOOKED_PRIOR_XTD,
		((((SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) - (SUM(PRIOR_REV)- SUM(PRIOR_BOOKED))) / DECODE((SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)),
                       0,NULL,(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)))) *   100)        FII_BOOKED_PRIOR_CHANGE,
                SUM(SUM(FII_HIST_COL1)) OVER ()      FII_GT_HIST_COL1,
                SUM(SUM(FII_HIST_COL2)) OVER ()      FII_GT_HIST_COL2,
                SUM(SUM(FII_HIST_COL3)) OVER ()      FII_GT_HIST_COL3,
                SUM(SUM(FII_HIST_COL4)) OVER ()      FII_GT_HIST_COL4,
                SUM(SUM(FII_XTD_REV)) OVER ()        FII_GT_XTD_REV,
                SUM(SUM(FII_XTD_BOOKED)) OVER ()     FII_GT_XTD_BOOKED,
               ((SUM(SUM(FII_XTD_REV)) OVER () - SUM(SUM(PRIOR_REV)) OVER ()) / DECODE(SUM(SUM(PRIOR_REV)) OVER (),
			0,NULL,SUM(SUM(PRIOR_REV)) OVER ()) *      100)                    FII_GT_CHANGE,
               ((SUM(SUM(FII_XTD_BOOKED)) OVER () - SUM(SUM(PRIOR_BOOKED)) OVER ()) / DECODE(SUM(SUM(PRIOR_BOOKED)) OVER (),
			0,NULL,SUM(SUM(PRIOR_BOOKED))      OVER ()) * 100)       FII_GT_CHANGE_BOOKED,
      		SUM(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) OVER ()     FII_GT_XTD_PRIOR_BOOKED,
		(((SUM(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) OVER() - SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER()) / DECODE(SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER(),
                       0,NULL,SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER())) *   100)        FII_GT_PRIOR_BOOKED_CHANGE,
               ( rank() over (ORDER BY SUM(FII_XTD_REV) '||l_sort||' nulls last, '||l_viewby_col||')) - 1  rnk
	FROM (

		SELECT		'||l_viewby_col||',
				0	FII_HIST_COL1,
				0	FII_HIST_COL2,
				0	FII_HIST_COL3,
				0	FII_HIST_COL4,

				SUM(CASE WHEN cal.report_date in (&BIS_CURRENT_ASOF_DATE)
					then f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  FII_XTD_REV,
				SUM(CASE WHEN cal.report_date in (&BIS_PREVIOUS_ASOF_DATE)
					then f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  PRIOR_REV,
				SUM(CASE WHEN cal.report_date in (&BIS_CURRENT_ASOF_DATE)
					then f.booked_rev_wk_'||l_curr_suffix||'  ELSE 0 END)  FII_XTD_BOOKED,
				SUM(CASE WHEN cal.report_date in (&BIS_PREVIOUS_ASOF_DATE)
					then f.booked_rev_wk_'||l_curr_suffix||'  ELSE 0 END) 	PRIOR_BOOKED

		FROM		'||l_mv_to_be_used ||'  f,
				fii_time_structures cal'
				||l_prod_cat_from||'

		WHERE		f.time_id = cal.time_id
				AND	f.period_type_id = cal.period_type_id
				AND     bitand(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
          			AND     cal.report_date in ((&BIS_PREVIOUS_ASOF_DATE),(&BIS_CURRENT_ASOF_DATE))
				AND	f.recognized_amt_'||l_curr_suffix||' <> 0
				'||l_flags||l_sg_where||l_prod_cat_where||l_cust_where||'

                GROUP BY        '||l_viewby_col||') c  group by '||l_viewby_col||') f,' ;

	WHEN 'FII_TIME_ENT_PERIOD' THEN

l_inner_sql := '
		SUM(FII_HIST_COL1)	   FII_HIST_COL1,
		SUM(FII_HIST_COL2)	   FII_HIST_COL2,
		SUM(FII_HIST_COL3)	   FII_HIST_COL3,
		SUM(FII_HIST_COL4)	   FII_HIST_COL4,
		SUM(FII_XTD_REV)	   FII_XTD_REV,
                SUM(FII_CHANGE)            FII_CHANGE,
		SUM(FII_PRIOR_XTD_REV)	   FII_PRIOR_XTD_REV,
		SUM(FII_XTD_BOOKED)	   FII_XTD_BOOKED,
                SUM(FII_CHANGE_BOOKED)     FII_CHANGE_BOOKED,
                SUM(FII_PRIOR_XTD_BOOKED)  FII_PRIOR_XTD_BOOKED,
		SUM(FII_BOOKED_PRIOR_XTD)  FII_BOOKED_PRIOR_XTD,
		SUM(FII_BOOKED_PRIOR_CHANGE)  FII_BOOKED_PRIOR_CHANGE,
                SUM(FII_GT_HIST_COL1)         FII_GT_HIST_COL1,
                SUM(FII_GT_HIST_COL2)         FII_GT_HIST_COL2,
                SUM(FII_GT_HIST_COL3)         FII_GT_HIST_COL3,
                SUM(FII_GT_HIST_COL4)         FII_GT_HIST_COL4,
                SUM(FII_GT_XTD_REV)           FII_GT_XTD_REV,
                SUM(FII_GT_XTD_BOOKED)     FII_GT_XTD_BOOKED,
                SUM(FII_GT_CHANGE)        FII_GT_CHANGE,
                SUM(FII_GT_CHANGE_BOOKED)  FII_GT_CHANGE_BOOKED,
		SUM(FII_GT_XTD_PRIOR_BOOKED)  FII_GT_XTD_PRIOR_BOOKED,
		SUM(FII_GT_PRIOR_BOOKED_CHANGE)  FII_GT_PRIOR_BOOKED_CHANGE
	FROM(
		SELECT		'||l_viewby_col||',
		SUM(FII_HIST_COL1)	FII_HIST_COL1,
		SUM(FII_HIST_COL2)	FII_HIST_COL2,
		SUM(FII_HIST_COL3)	FII_HIST_COL3,
		SUM(FII_HIST_COL4)	FII_HIST_COL4,
		SUM(FII_XTD_REV)	FII_XTD_REV,
                (((SUM(FII_XTD_REV) - SUM(PRIOR_REV)) / DECODE(SUM(PRIOR_REV),
                       0,NULL,SUM(PRIOR_REV))) *   100)        FII_CHANGE,
		SUM(PRIOR_REV)		FII_PRIOR_XTD_REV,
		SUM(FII_XTD_BOOKED)	FII_XTD_BOOKED,
                 (((SUM(FII_XTD_BOOKED)  - SUM(PRIOR_BOOKED)) / DECODE(SUM(PRIOR_BOOKED),0,
                    NULL,SUM(PRIOR_BOOKED))) * 100)       FII_CHANGE_BOOKED,
		SUM(PRIOR_BOOKED)	FII_PRIOR_XTD_BOOKED,
				(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) FII_BOOKED_PRIOR_XTD,
		((((SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) - (SUM(PRIOR_REV)- SUM(PRIOR_BOOKED))) / DECODE((SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)),
                       0,NULL,(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)))) *   100)        FII_BOOKED_PRIOR_CHANGE,
                SUM(SUM(FII_HIST_COL1)) OVER ()      FII_GT_HIST_COL1,
                SUM(SUM(FII_HIST_COL2)) OVER ()      FII_GT_HIST_COL2,
                SUM(SUM(FII_HIST_COL3)) OVER ()      FII_GT_HIST_COL3,
                SUM(SUM(FII_HIST_COL4)) OVER ()      FII_GT_HIST_COL4,
                SUM(SUM(FII_XTD_REV)) OVER ()        FII_GT_XTD_REV,
                SUM(SUM(FII_XTD_BOOKED)) OVER ()     FII_GT_XTD_BOOKED,
               ((SUM(SUM(FII_XTD_REV)) OVER () - SUM(SUM(PRIOR_REV)) OVER ()) / DECODE(SUM(SUM(PRIOR_REV)) OVER (),
			0,NULL,SUM(SUM(PRIOR_REV)) OVER ()) *      100)                    FII_GT_CHANGE,
               ((SUM(SUM(FII_XTD_BOOKED)) OVER () - SUM(SUM(PRIOR_BOOKED)) OVER ()) / DECODE(SUM(SUM(PRIOR_BOOKED)) OVER (),
			0,NULL,SUM(SUM(PRIOR_BOOKED))      OVER ()) * 100)       FII_GT_CHANGE_BOOKED,
      		SUM(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) OVER ()     FII_GT_XTD_PRIOR_BOOKED,
		(((SUM(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) OVER() - SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER()) / DECODE(SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER(),
                       0,NULL,SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER())) *   100)        FII_GT_PRIOR_BOOKED_CHANGE,
               ( rank() over (ORDER BY SUM(FII_XTD_REV) '||l_sort||'  nulls last, '||l_viewby_col||')) - 1  rnk
	FROM (

		SELECT		'||l_viewby_col||',
				0	FII_HIST_COL1,
				0	FII_HIST_COL2,
				0	FII_HIST_COL3,
				0	FII_HIST_COL4,
				SUM(CASE WHEN cal.report_date in (&BIS_CURRENT_ASOF_DATE)
					then f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  FII_XTD_REV,
				SUM(CASE WHEN cal.report_date in (&BIS_PREVIOUS_ASOF_DATE)
					then f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  PRIOR_REV,
				SUM(CASE WHEN cal.report_date in (&BIS_CURRENT_ASOF_DATE)
					then f.booked_rev_pe_'||l_curr_suffix||'  ELSE 0 END)  FII_XTD_BOOKED,
				SUM(CASE WHEN cal.report_date in (&BIS_PREVIOUS_ASOF_DATE)
					then f.booked_rev_pe_'||l_curr_suffix||'  ELSE 0 END) 	PRIOR_BOOKED

		FROM		'||l_mv_to_be_used ||'  f,
				fii_time_structures cal'
				||l_prod_cat_from||'

		WHERE		f.time_id = cal.time_id
				AND	f.period_type_id = cal.period_type_id
				AND     bitand(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
          			AND     cal.report_date in ((&BIS_PREVIOUS_ASOF_DATE),(&BIS_CURRENT_ASOF_DATE))
				AND	f.recognized_amt_'||l_curr_suffix||' <> 0
				'||l_flags||l_sg_where||l_prod_cat_where||l_cust_where||'

		GROUP BY	'||l_viewby_col||') c  group by '||l_viewby_col||') f,' ;

	ELSE

-- for period type quarter and year, We use UNION ALL. First sql gives historical data while
-- second sql gets values for PTD revenue, prior period PTD revenue(used to calculate change),
-- Booked revenue for current period and booked revenue for prior period(for change calculation)
l_inner_sql := '
                SUM(FII_HIST_COL1)         FII_HIST_COL1,
                SUM(FII_HIST_COL2)         FII_HIST_COL2,
                SUM(FII_HIST_COL3)         FII_HIST_COL3,
                SUM(FII_HIST_COL4)         FII_HIST_COL4,
                SUM(FII_XTD_REV)           FII_XTD_REV,
                SUM(FII_CHANGE)            FII_CHANGE,
                SUM(FII_PRIOR_XTD_REV)     FII_PRIOR_XTD_REV,
                SUM(FII_XTD_BOOKED)        FII_XTD_BOOKED,
                SUM(FII_CHANGE_BOOKED)     FII_CHANGE_BOOKED,
                SUM(FII_PRIOR_XTD_BOOKED)  FII_PRIOR_XTD_BOOKED,
	        SUM(FII_BOOKED_PRIOR_XTD)  FII_BOOKED_PRIOR_XTD,
		SUM(FII_BOOKED_PRIOR_CHANGE)  FII_BOOKED_PRIOR_CHANGE,
                SUM(FII_GT_HIST_COL1)         FII_GT_HIST_COL1,
                SUM(FII_GT_HIST_COL2)         FII_GT_HIST_COL2,
                SUM(FII_GT_HIST_COL3)         FII_GT_HIST_COL3,
                SUM(FII_GT_HIST_COL4)         FII_GT_HIST_COL4,
                SUM(FII_GT_XTD_REV)           FII_GT_XTD_REV,
                SUM(FII_GT_XTD_BOOKED)     FII_GT_XTD_BOOKED,
                SUM(FII_GT_CHANGE)        FII_GT_CHANGE,
                SUM(FII_GT_CHANGE_BOOKED)  FII_GT_CHANGE_BOOKED,
		SUM(FII_GT_XTD_PRIOR_BOOKED)  FII_GT_XTD_PRIOR_BOOKED,
		SUM(FII_GT_PRIOR_BOOKED_CHANGE)  FII_GT_PRIOR_BOOKED_CHANGE
FROM (
                SELECT          '||l_viewby_col||',
		SUM(FII_HIST_COL1)	FII_HIST_COL1,
		SUM(FII_HIST_COL2)	FII_HIST_COL2,
		SUM(FII_HIST_COL3)	FII_HIST_COL3,
		SUM(FII_HIST_COL4)	FII_HIST_COL4,
		SUM(FII_XTD_REV)	FII_XTD_REV,
                (((SUM(FII_XTD_REV) - SUM(PRIOR_REV)) / DECODE(SUM(PRIOR_REV),
                       0,NULL,SUM(PRIOR_REV))) *   100)        FII_CHANGE,
		SUM(PRIOR_REV)		FII_PRIOR_XTD_REV,
		SUM(FII_XTD_BOOKED)	FII_XTD_BOOKED,
                (((SUM(FII_XTD_BOOKED)  - SUM(PRIOR_BOOKED)) / DECODE(SUM(PRIOR_BOOKED),0,
                    NULL,SUM(PRIOR_BOOKED))) * 100)       FII_CHANGE_BOOKED,
		SUM(PRIOR_BOOKED)	FII_PRIOR_XTD_BOOKED,
		(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) FII_BOOKED_PRIOR_XTD,
		((((SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) - (SUM(PRIOR_REV)- SUM(PRIOR_BOOKED))) / DECODE((SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)),
                       0,NULL,(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)))) *   100)        FII_BOOKED_PRIOR_CHANGE,
                SUM(SUM(FII_HIST_COL1)) OVER ()      FII_GT_HIST_COL1,
                SUM(SUM(FII_HIST_COL2)) OVER ()      FII_GT_HIST_COL2,
                SUM(SUM(FII_HIST_COL3)) OVER ()      FII_GT_HIST_COL3,
                SUM(SUM(FII_HIST_COL4)) OVER ()      FII_GT_HIST_COL4,
                SUM(SUM(FII_XTD_REV)) OVER ()        FII_GT_XTD_REV,
                SUM(SUM(FII_XTD_BOOKED)) OVER ()     FII_GT_XTD_BOOKED,
	        ((SUM(SUM(FII_XTD_REV)) OVER () - SUM(SUM(PRIOR_REV)) OVER ()) / DECODE(SUM(SUM(PRIOR_REV)) OVER (),
			0,NULL,SUM(SUM(PRIOR_REV)) OVER ()) *      100)                    FII_GT_CHANGE,
               ((SUM(SUM(FII_XTD_BOOKED)) OVER () - SUM(SUM(PRIOR_BOOKED)) OVER ()) / DECODE(SUM(SUM(PRIOR_BOOKED)) OVER (),
			0,NULL,SUM(SUM(PRIOR_BOOKED))      OVER ()) * 100)       FII_GT_CHANGE_BOOKED,
      		SUM(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) OVER ()     FII_GT_XTD_PRIOR_BOOKED,
		(((SUM(SUM(FII_XTD_REV) -  SUM(FII_XTD_BOOKED)) OVER() - SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER()) / DECODE(SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER(),
                       0,NULL,SUM(SUM(PRIOR_REV)- SUM(PRIOR_BOOKED)) OVER())) *   100)        FII_GT_PRIOR_BOOKED_CHANGE,
               ( rank() over (ORDER BY SUM(FII_XTD_REV)  '||l_sort||' nulls last, '||l_viewby_col||')) - 1  rnk

	FROM (
		SELECT		'||l_viewby_col||',
				SUM(CASE WHEN cal.report_date in to_date(:FII_THREE_PERIOD_BACK,''DD-MM-YYYY'')
					THEN  f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  FII_HIST_COL1,
				SUM(CASE WHEN cal.report_date in to_date(:FII_TWO_PERIOD_BACK,''DD-MM-YYYY'')
					THEN  f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  FII_HIST_COL2,
				SUM(CASE WHEN cal.report_date in to_date(:FII_ONE_PERIOD_BACK,''DD-MM-YYYY'')
					THEN  f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  FII_HIST_COL3,
				SUM(CASE WHEN cal.report_date in (&BIS_CURRENT_ASOF_DATE)
					THEN  f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  FII_HIST_COL4,
				0	FII_XTD_REV,
				0	PRIOR_REV,
				0	FII_XTD_BOOKED,
				0	PRIOR_BOOKED

		FROM		'||l_mv_to_be_used ||'  f,
				fii_time_structures cal'
				||l_prod_cat_from||'

		WHERE		f.time_id = cal.time_id
				AND	f.period_type_id = cal.period_type_id
				AND     bitand(cal.record_type_id, :FII_RECORD_ID) = :FII_RECORD_ID
          			AND     cal.report_date in (to_date(:FII_THREE_PERIOD_BACK,''DD-MM-YYYY''),to_date(:FII_TWO_PERIOD_BACK,''DD-MM-YYYY''),to_date(:FII_ONE_PERIOD_BACK,''DD-MM-YYYY''),
							(&BIS_CURRENT_ASOF_DATE))
				AND	f.recognized_amt_'||l_curr_suffix||' <> 0
				'||l_flags||l_sg_where||l_prod_cat_where||l_cust_where||'

		GROUP BY	'||l_viewby_col||'

		UNION ALL

		SELECT		'||l_viewby_col||',
				0	FII_HIST_COL1,
				0	FII_HIST_COL2,
				0	FII_HIST_COL3,
				0	FII_HIST_COL4,
				SUM(CASE WHEN cal.report_date in (&BIS_CURRENT_ASOF_DATE)
					then f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  FII_XTD_REV,
				SUM(CASE WHEN cal.report_date in (&BIS_PREVIOUS_ASOF_DATE)
					then f.recognized_amt_'||l_curr_suffix||'  ELSE 0 END)  PRIOR_REV,
				SUM(CASE WHEN cal.report_date in (&BIS_CURRENT_ASOF_DATE)
					then f.booked_rev_'||l_pertype_for_booked||'_'||l_curr_suffix||'  ELSE 0 END)  FII_XTD_BOOKED,
				SUM(CASE WHEN cal.report_date in (&BIS_PREVIOUS_ASOF_DATE)
					then f.booked_rev_'||l_pertype_for_booked||'_'||l_curr_suffix||'  ELSE 0 END) 	PRIOR_BOOKED
		FROM		'||l_mv_to_be_used ||'  f,
				fii_time_structures cal'
				||l_prod_cat_from||'

		WHERE		f.time_id = cal.time_id
				AND	f.period_type_id = cal.period_type_id
				AND     bitand(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
          			AND     cal.report_date in ((&BIS_PREVIOUS_ASOF_DATE),(&BIS_CURRENT_ASOF_DATE))
				AND	f.recognized_amt_'||l_curr_suffix||' <> 0
				'||l_flags||l_sg_where||l_prod_cat_where||l_cust_where||'

               GROUP BY        '||l_viewby_col||') c  group by '||l_viewby_col||') f,' ;
	END CASE;


IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN

     sqlstmt := '
		SELECT	DECODE(f.resource_id,NULL,g.group_name,
			r.resource_name)  	VIEWBY,
			DECODE(f.resource_id,NULL,to_char(f.sales_grp_id),
			f.resource_id||''.''||f.sales_grp_id)
					VIEWBYID,
			DECODE(sum(fii_xtd_rev),0,null,decode(f.resource_id, NULL,
			''pFunctionName=FII_AR_SG_PROD_REV&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'',
			NULL))	FII_SALES_GROUP_DRILL,
			NULL	FII_PROD_CAT_DRILL,
			'||l_inner_sql||'
			JTF_RS_GROUPS_VL		g,
			JTF_RS_RESOURCE_EXTNS_VL	r
		WHERE	f.sales_grp_id = g.group_id
			AND f.resource_id = r.resource_id(+)
		        AND ((rnk between &START_INDEX and &END_INDEX) or (&END_INDEX = -1))
		GROUP BY f.resource_id,g.group_name,r.resource_name,f.sales_grp_id
	        &ORDER_BY_CLAUSE ' ;

ELSIF l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' THEN

    IF (l_prod_cat IS NULL) THEN
	l_cat_join := 'AND f.parent_id = ecat.id';
    ElSE
	l_cat_join := 'AND f.imm_child_id = ecat.id';
    END IF;

	sqlstmt := '

		SELECT	ecat.value 		VIEWBY,
			ecat.id			VIEWBYID,
			NULL			FII_SALES_GROUP_DRILL, -- Drill - Sales Group
			DECODE(SUM(fii_xtd_rev),0,NULL,DECODE(ecat.leaf_node_flag, ''Y'',NULL,
			''pFunctionName=FII_AR_SG_PROD_REV&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y''))
						FII_PROD_CAT_DRILL,    -- Drill - Prod Category
			'||l_inner_sql||'
			ENI_ITEM_VBH_NODES_V 		ecat
		WHERE	ecat.parent_id = ecat.child_id
			'||l_cat_join||'
		        AND ((rnk between &START_INDEX and &END_INDEX) or (&END_INDEX = -1))
		GROUP BY ecat.value,ecat.id,ecat.leaf_node_flag
	        &ORDER_BY_CLAUSE ';


ELSE -- l_view_by = 'CUSTOMER+FII_CUSTOMERS'

     sqlstmt := '
		SELECT	cust.value	VIEWBY,
			cust.id			VIEWBYID,
			NULL	  		FII_SALES_GROUP_DRILL,
			NULL			FII_PROD_CAT_DRILL, '
			||l_inner_sql||'
			FII_CUSTOMERS_V 	cust
		WHERE	f.customer_id = cust.id
		AND     ((rnk between &START_INDEX and &END_INDEX) or (&END_INDEX = -1))
		GROUP BY cust.value,cust.id
	        &ORDER_BY_CLAUSE ';


  END IF;

-- Binding Section

   get_sg_prod_rev_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   get_sg_prod_rev_output := BIS_QUERY_ATTRIBUTES_TBL();
   get_sg_prod_rev_sql := sqlstmt;

   get_sg_prod_rev_output.EXTEND;
   get_sg_prod_rev_rec.attribute_name := ':RECORD_TYPE_ID';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_record_type_id);
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':VIEW_BY';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_view_by);
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_SG_SG';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_sg_sg);
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_SG_RES';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_sg_res);
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_ITEM_CAT_FLAG';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_item_cat_flag);
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_CUST';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_cust_flag);
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_RECORD_ID';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_record_id);
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_ONE_PERIOD_BACK';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_one_period_back,'DD-MM-YYYY');
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_TWO_PERIOD_BACK';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_two_period_back,'DD-MM-YYYY');
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_THREE_PERIOD_BACK';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_three_period_back,'DD-MM-YYYY');
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

   get_sg_prod_rev_rec.attribute_name := ':FII_SORT';
   get_sg_prod_rev_rec.attribute_value := TO_CHAR(l_sort);
   get_sg_prod_rev_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   get_sg_prod_rev_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   get_sg_prod_rev_output(get_sg_prod_rev_output.COUNT) := get_sg_prod_rev_rec;
   get_sg_prod_rev_output.EXTEND;

END get_sg_prod_rev;

END fii_ar_sg_prod_rev_pkg;

/
