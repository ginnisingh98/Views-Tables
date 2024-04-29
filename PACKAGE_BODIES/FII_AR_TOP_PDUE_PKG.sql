--------------------------------------------------------
--  DDL for Package Body FII_AR_TOP_PDUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_TOP_PDUE_PKG" AS
/*  $Header: FIIARDBITPDB.pls 120.11.12000000.1 2007/02/23 02:29:21 applrt ship $ */

--   This package will provide sql statements to retrieve data for Top Past Due Customers Report

PROCEDURE get_top_pdue_cst(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
top_pdue_cst_sql out NOCOPY VARCHAR2, top_pdue_cst_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  --Sql Statement
  sqlstmt			VARCHAR2(32767);

  --Variables for where clauses
  l_collector_where		VARCHAR2(300) := '';
  l_party_where		   VARCHAR2(32000) := '';

  --For Sorting
  l_order_by			varchar2(500);
  l_order_column		varchar2(100);
  l_parent_select    varchar2(500);
  l_security_profile_id NUMBER;
  l_security_org_id NUMBER;
  l_all_org_flag  	VARCHAR2(30);
  l_business_group_id 	NUMBER;
  l_org_where VARCHAR2(1000);
  l_org_specific_where VARCHAR2(1000);
  l_page_refresh_date varchar2(500);

BEGIN

   fii_ar_util_pkg.reset_globals;

   fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

   fii_ar_util_pkg.g_view_by := 'CUSTOMER+FII_CUSTOMERS';

   --populating page refresh date
   FII_AR_UTIL_PKG.get_page_refresh_date;

   IF fii_ar_util_pkg.g_is_hierarchical_flag = 'Y' THEN

	   fii_ar_util_pkg.g_cust_suffix := '_agrt';

   ELSE

	   fii_ar_util_pkg.g_cust_suffix := '_base';

   END IF;

 /*========================= Party Clause Start =====================================*/

  -- When Aggregate table is used

  if ( fii_ar_util_pkg.g_is_hierarchical_flag = 'Y') then

    --if more than one party is selected

    if (fii_ar_util_pkg.g_count_parent_party_id  > 1) then

      l_party_where := ' AND cust_next_level_party_id in ( &CUSTOMER+FII_CUSTOMERS )
                         and cust_parent_party_id <> cust_child_party_id ';

    -- if no party is selected

    elsif (fii_ar_util_pkg.g_party_id = '-111') then

        l_party_where := ' AND cust_parent_party_id = -999 ';

    else

    -- if only one party is selected

          l_party_where := ' AND cust_parent_party_id in (&CUSTOMER+FII_CUSTOMERS) ';

    end if;

  else --if base table is used

    if (fii_ar_util_pkg.g_party_id = '-111') then

      l_party_where :=  ' AND cust_parent_party_id = cust_child_party_id ';

    else

      l_party_where :=  ' AND cust_parent_party_id in  ( &CUSTOMER+FII_CUSTOMERS )';
    end if;

  end if;
/*========================= Party Clause End =====================================*/


  /*========================Org Security Clause Start===========================*/

  l_security_profile_id := fii_ar_util_pkg.get_sec_profile;
	l_security_org_id := fnd_profile.value('ORG_ID');


	 IF l_security_profile_id is not null AND l_security_profile_id <> -1 THEN

	    SELECT view_all_organizations_flag, business_group_id
    	INTO l_all_org_flag, l_business_group_id
    	FROM per_security_profiles
    	WHERE security_profile_id = l_security_profile_id;


    	IF fii_ar_util_pkg.g_org_id = -111 THEN
					l_org_specific_where := NULL;
			ELSE
					l_org_specific_where := ' AND per.organization_id= '||fii_ar_util_pkg.g_org_id;
			END IF;

			IF l_all_org_flag = 'Y' and l_business_group_id is NOT NULL THEN

				l_org_where := ' and f.org_id in (SELECT per.organization_id
												FROM hr_operating_units per, ar_system_parameters_all ar
												WHERE per.business_group_id = 	'||l_business_group_id ||'
			                  AND per.organization_id = ar.org_id '||l_org_specific_where||') ';

    	ELSIF l_all_org_flag = 'Y' and l_business_group_id is NULL THEN

        l_org_where := ' and f.org_id in  (SELECT per.organization_id
												FROM hr_operating_units per
												WHERE 1=1 '||l_org_specific_where||') ';

			ELSE

			  l_org_where := ' and f.org_id in  (SELECT organization_id
		   									FROM per_organization_list per, ar_system_parameters_all ar
			                  WHERE per.security_profile_id = '||l_security_profile_id ||'
			                   AND per.organization_id = ar.org_id '||l_org_specific_where||') ';
		  END IF;

	 ELSIF l_security_org_id is not null THEN

	    l_org_where := NULL;

	    IF fii_ar_util_pkg.g_org_id =-111 OR fii_ar_util_pkg.g_org_id = l_security_org_id THEN
				l_org_where := ' and f.org_id = '||l_security_org_id||' ';
			ELSE
				l_org_where	:=	' and f.org_id = -1  ';
			END IF;

	 ELSE
	    l_org_where	:=	' and f.org_id = -1  ';


	 END IF;


  /*===============================Org Security Clause End====================*/


  --Frame the order by clause for the report sql
   IF(instr(fii_ar_util_pkg.g_order_by,',') <> 0) THEN

    /*This means no particular sort column is selected in the report
    So sort on the default column in descending order
    NVL is added to make sure the null values appear last*/

    l_order_by := 'ORDER BY NVL(''FII_AR_PASTDUE_REC_AMT'', -999999999) DESC';

   ELSIF(instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0)THEN

    /*This means a particular sort column is clicked to have descending order
    in which case we would want all the null values to appear last in the
    report so add an NVL to that column*/

    l_order_column := substr(fii_ar_util_pkg.g_order_by,1,instr(fii_ar_util_pkg.g_order_by, ' DESC'));
    l_order_by := 'ORDER BY NVL('|| l_order_column ||', -999999999) DESC';

   ELSE

    /*This is the case when user has asked for an ascending order sort.
    Use PMV's order by clause*/

    l_order_by := '&ORDER_BY_CLAUSE';

   END IF;


 --getting page refresh date

 l_page_refresh_date := to_char(fii_ar_util_pkg.g_page_refresh_date,'dd/mm/yyyy');

   --Setting up the where clauses based on the Parameter for Collector Dimension
   IF (fii_ar_util_pkg.g_collector_id <> '-111') THEN
  	 l_collector_where := 'AND f.collector_id = :COLLECTOR_ID ';
   END IF;


sqlstmt := 'SELECT inline_view.view_by VIEWBY,
		     		inline_view.viewby_code VIEWBYID,
            inline_view.view_by FII_AR_TOP_PDUE_VIEW_BY,
            SUM(FII_AR_PASTDUE_REC_AMT) FII_AR_PASTDUE_REC_AMT,
            (SUM(FII_AR_DISPUTE_AMT)/NULLIF(SUM(FII_AR_PASTDUE_REC_AMT),0))*100 FII_AR_DISPUTE_PER,
            (SUM(FII_AR_PASTDUE_REC_AMT) * to_number(to_char(:PAGE_REFRESH_DATE , ''J'')) -  SUM(FII_AR_WEIGHTED_DDSO_NUM))/NULLIF(SUM(FII_AR_PASTDUE_REC_AMT),0) FII_AR_WEIGHTED_DDSO,
            (SUM(FII_AR_PASTDUE_REC_AMT)/NULLIF((SUM(FII_AR_PASTDUE_REC_AMT) + to_number(SUM(FII_AR_CURRENT_OPEN_AMT))),0)) *100 FII_AR_OPEN_REC_PER,
            (SUM(FII_AR_PASTDUE_REC_AMT) + SUM(FII_AR_CURRENT_OPEN_AMT)) FII_AR_OPEN_REC_AMT,
            (SUM(FII_AR_WEIGHTED_TO_NUM)/NULLIF((SUM(FII_AR_PASTDUE_REC_AMT) + SUM(FII_AR_CURRENT_OPEN_AMT)),0)) FII_AR_WEIGHTED_TO,
            SUM(SUM(FII_AR_PASTDUE_REC_AMT)) over() FII_AR_GT_PASTDUE_REC_AMT,
            (SUM(SUM(FII_AR_DISPUTE_AMT))over()/NULLIF(SUM(SUM(FII_AR_PASTDUE_REC_AMT))over(),0))*100 FII_AR_GT_DISPUTE_PCT_TOTAL,
            (SUM(SUM(FII_AR_PASTDUE_REC_AMT)) over() * to_number(to_char(:PAGE_REFRESH_DATE , ''J'')) -  SUM(SUM(FII_AR_WEIGHTED_DDSO_NUM)) over())/NULLIF(SUM(SUM(FII_AR_PASTDUE_REC_AMT)) OVER(),0) FII_AR_GT_WEIGHTED_DDSO,
            (SUM(SUM(FII_AR_PASTDUE_REC_AMT)) OVER()/NULLIF((SUM(SUM(FII_AR_PASTDUE_REC_AMT)) OVER() + SUM(SUM(FII_AR_CURRENT_OPEN_AMT)) OVER()),0)) *100 FII_AR_GT_PER_OPEN_REC,
            (SUM(SUM(FII_AR_PASTDUE_REC_AMT)) over() + SUM(SUM(FII_AR_CURRENT_OPEN_AMT)) over()) FII_AR_GT_OPEN_REC_AMT,
            (SUM(SUM(FII_AR_WEIGHTED_TO_NUM)) OVER()/NULLIF((SUM(SUM(FII_AR_PASTDUE_REC_AMT)) OVER() + SUM(SUM(FII_AR_CURRENT_OPEN_AMT)) OVER()),0)) FII_AR_GT_WEIGHTED_TO,
            DECODE(SUM(FII_AR_PASTDUE_REC_AMT),0,'''',DECODE(NVL(SUM(FII_AR_PASTDUE_REC_AMT), -99999),-99999, '''',''pFunctionName=FII_AR_PASTDUE_REC_AGING'||
            '&FII_CUSTOMER=VIEWBYID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&BIS_PMV_DRILL_CODE_AS_OF_DATE='||l_page_refresh_date||'&pParamIds=Y'')) FII_AR_PDUE_REC_DRILL,
            DECODE((SUM(FII_AR_PASTDUE_REC_AMT) + SUM(FII_AR_CURRENT_OPEN_AMT)),0,'''',
            DECODE(NVL((SUM(FII_AR_PASTDUE_REC_AMT) +
            SUM(FII_AR_CURRENT_OPEN_AMT)), -99999),-99999, '''',''pFunctionName=FII_AR_OPEN_REC_SUMMARY&FII_CUSTOMER=VIEWBYID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS'||
            '&BIS_PMV_DRILL_CODE_AS_OF_DATE='||l_page_refresh_date||'&pParamIds=Y'')) FII_AR_OPEN_REC_DRILL,
            DECODE(inline_view.is_self_flag, ''Y'' , '''', DECODE(inline_view.is_leaf_flag, ''Y'','''', ''pFunctionName=FII_AR_TOP_PDUE_CUSTOMER&FII_CUSTOMER=VIEWBYID&VIEW_BY=CUSTOMER+FII_CUSTOMERS&pParamIds=Y'')) FII_AR_CUST_SELF_DRILL
      from (
           SELECT VIEW_BY view_by, viewby_code,
                  is_self_flag is_self_flag,
                  is_leaf_flag is_leaf_flag,
                  sum(past_due_open_amount'||fii_ar_util_pkg.g_col_curr_suffix||')   FII_AR_PASTDUE_REC_AMT,
                  sum(wtd_terms_out_open_num'||fii_ar_util_pkg.g_col_curr_suffix||') FII_AR_WEIGHTED_TO_NUM,
                  sum(wtd_ddso_due_num'||fii_ar_util_pkg.g_col_curr_suffix||')       FII_AR_WEIGHTED_DDSO_NUM,
                  sum(current_open_amount'||fii_ar_util_pkg.g_col_curr_suffix||')    FII_AR_CURRENT_OPEN_AMT,
                  sum(past_due_dispute_amount'||fii_ar_util_pkg.g_col_curr_suffix||') FII_AR_DISPUTE_AMT
            FROM FII_AR_TPDUE'|| fii_ar_util_pkg.g_cust_suffix ||'_F f
            WHERE 1=1
            '||l_party_where||l_collector_where||l_org_where||'
       			GROUP BY  viewby_code, VIEW_BY, is_self_flag, is_leaf_flag
  					)inline_view
       GROUP BY  viewby_code, VIEW_BY, is_self_flag, is_leaf_flag '||l_order_by;


fii_ar_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, top_pdue_cst_sql, top_pdue_cst_output);

 END get_top_pdue_cst;

END fii_ar_top_pdue_pkg;


/
