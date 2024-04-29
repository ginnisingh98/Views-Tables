--------------------------------------------------------
--  DDL for Package Body FII_AR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_UTIL_PKG" AS
/* $Header: FIIARUTILB.pls 120.50 2006/12/13 17:00:15 vkazhipu ship $ */

g_min_start_date date;
-- -------------------------------------------------
-- Re-set the globals variables to NULL
-- -------------------------------------------------
PROCEDURE reset_globals IS
BEGIN

g_as_of_date            := NULL;
g_page_period_type      := NULL;
g_currency              := NULL;
g_view_by               := NULL;
g_region_code		:= NULL;
g_session_id		:= NULL;
g_time_comp             := NULL;
g_party_id 	        := NULL;
g_cust_account_id       := '-111';
g_org_id		:= '-111';
g_collector_id		:= '-111';
g_industry_id		:= '-111';
g_curr_suffix		:= NULL;
g_cust_suffix		:= NULL;
g_cust_view_by		:= NULL;
g_curr_per_start        := NULL;
g_curr_per_end          := NULL;
g_prior_per_start       := NULL;
g_prior_per_end         := NULL;
g_curr_month_start      := NULL;
g_bitand		:= NULL;
g_dso_bitand	:= NULL;
g_bitand_inc_todate	:= NULL;
g_bitand_rolling_30_days := NULL;
g_self_msg		:= NULL;
g_previous_asof_date	:= NULL;
g_is_hierarchical_flag  := NULL;
g_count_parent_party_id	:= NULL;
g_dso_period		:= NULL;
g_industry_class_type   := NULL;
g_security_profile_id 	:= NULL;
g_security_org_id	:= NULL;
g_operating_unit	:= NULL;
g_prim_global_currency_code := get_prim_global_currency_code;
g_sec_global_currency_code  := get_sec_global_currency_code;
g_det_ou_lov		:= NULL;
g_business_group_id 	:= NULL;
g_all_operating_unit 	:= NULL;
g_order_by	 	:= NULL;
g_sd_prior		:= NULL;
g_sd_prior_prior	:= NULL;
g_sd_curr_sdate		:= NULL;
g_function_name         := NULL;
g_col_curr_suffix       := NULL;
g_cash_receipt_id	:= Null;
g_cust_trx_id           := NULL;
g_tran_num		:= NULL;
g_tran_class		:= NULL;
g_cust_account		:= NULL;
g_account_num		:= NULL;
g_app_cust_trx_id           := NULL;
g_bucket_num		:= NULL;
g_page_refresh_date := NULL;

END reset_globals;

PROCEDURE get_parameters (
  p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL) IS

  l_retcode              NUMBER;
  is_hierarchical   VARCHAR2(100);

BEGIN

  -- -------------------------------------------------
  -- Parse thru the parameter table and set globals
  -- -------------------------------------------------
  IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

      IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
        g_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'BIS_PREVIOUS_ASOF_DATE' THEN
        g_previous_asof_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
        g_page_period_type := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
        g_currency := substr(p_page_parameter_tbl(i).parameter_id,2,11);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
        g_view_by :=  p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'BIS_REGION_CODE' THEN
        g_region_code :=  p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME_COMPARISON_TYPE' THEN
        g_time_comp := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS' THEN
        g_party_id := nvl(replace(p_page_parameter_tbl(i).parameter_id, '''', null), '-111');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS'  THEN
        g_cust_account_id := nvl(p_page_parameter_tbl(i).parameter_id,'-111');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
	g_org_id := nvl(replace(p_page_parameter_tbl(i).parameter_id, '''', null), '-111');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_COLLECTOR+FII_COLLECTOR' THEN
        g_collector_id := NVL(p_page_parameter_tbl(i).parameter_id,'-111');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN
        g_industry_id := NVL(p_page_parameter_tbl(i).parameter_id,'-111');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'ORDERBY' THEN
        g_order_by := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'BIS_FXN_NAME' THEN
         g_function_name := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_AR_CASH_RECEIPT_ID' THEN
         g_cash_receipt_id := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_AR_CUST_TRX_ID' THEN
         g_cust_trx_id := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_AR_TRAN_NUM' THEN
         g_tran_num := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_AR_TRAN_CLASS' THEN
        g_tran_class := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_AR_CUST_ACCOUNT' THEN
        g_cust_account := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_AR_ACCOUNT_NUM' THEN
        g_account_num := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'BIS_ICX_SESSION_ID' THEN
        g_session_id := NVL(p_page_parameter_tbl(i).parameter_value,0);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_AR_APP_CUST_TRX_ID' THEN
         g_app_cust_trx_id := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_AR_BUCKET_NUM' THEN
         g_bucket_num := p_page_parameter_tbl(i).parameter_value;

      END IF;
    END LOOP;
  END IF;

-- Done for bug# 5089114
IF g_function_name = 'FII_AR_DSO_TREND_GRAPH' THEN
	g_page_period_type := 'FII_TIME_ENT_PERIOD';
END IF;

IF g_collector_id = 'All' THEN
	g_collector_id := '-111';
END IF;

IF g_org_id = 'All'  THEN
	g_org_id := '-111';
ELSIF g_org_id='null' THEN
	g_org_id := '-999';
END IF;

IF g_party_id = 'All' OR g_party_id IS NULL THEN
	g_party_id := '-111';
END IF;
IF g_industry_id = 'All' THEN
	g_industry_id := '-111';
END IF;


/* This code is written to default  the view by to OU, in the case when any other viewby is chosen other than
below mentioned. We need to populate GT table with OU data in the case when viewby chosen is Month/Time etc */

IF g_view_by is null or
   (g_view_by <> 'CUSTOMER+FII_CUSTOMERS'
	AND g_view_by <> 'CUSTOMER+FII_CUSTOMER_ACCOUNTS'
	AND g_view_by <> 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS'
	AND g_view_by <> 'FII_COLLECTOR+FII_COLLECTOR'
	AND g_view_by <> 'ORGANIZATION+FII_OPERATING_UNITS') THEN

g_view_by := 'ORGANIZATION+FII_OPERATING_UNITS';

END IF;

/* If user views in primary global, use 1st view which SELECTs the primary amount.  For secondary global
currency, use 2nd view which SELECTs secondary amount for Functional currency, use 3rd view which
SELECTs functional amount. */

IF g_currency = 'FII_GLOBAL1' THEN
      g_curr_suffix := '_p_v';
      g_col_curr_suffix := '_prim';
ELSIF g_currency = 'FII_GLOBAL2' THEN
      g_curr_suffix := '_s_v';
      g_col_curr_suffix := '_sec';
ELSE
      g_curr_suffix := '_f_v';
      g_col_curr_suffix := '_func';
END IF;


/* FND PROFILE for Customer Hierarchy: will be created through Bug 4637815 */
is_hierarchical := nvl(fnd_profile.value('BIS_CUST_HIER_TYPE'), 'N');

IF is_hierarchical = 'N' THEN
        g_is_hierarchical_flag := 'N';
ELSE
        g_is_hierarchical_flag :='Y';
END IF;

g_industry_class_type := nvl(fnd_profile.value('BIS_CUST_CLASS_TYPE'), -1);

/* The following procedure parses the g_party_id i.e. party_id parameter value passed by
BIS from PMV parameter region. After that in the case of customers defined is hierarchical
and if both parent and children are chosen together from customer parameter then only the
parent should be stored in g_party_id variable. */

fii_ar_util_pkg.populate_party_id;

SELECT nvl(min(start_date), trunc(sysdate)) INTO g_min_start_date
FROM	 fii_time_ent_period;

SELECT nvl(min(start_date), g_min_start_date) INTO g_curr_month_start
FROM	 fii_time_ent_period
WHERE  g_as_of_date between start_date and END_date;


IF g_previous_asof_date IS NULL THEN
     g_previous_asof_date := g_min_start_date;
END IF;

/* Bitand for inception to-date */
g_bitand_inc_todate := 512;

/* Bitand for rolling 30 days */
g_bitand_rolling_30_days := 2048;

CASE g_page_period_type

WHEN  'FII_TIME_WEEK' THEN
      g_bitand := 32;

      SELECT NVL(fii_time_api.pwk_end(g_as_of_date-84),g_min_start_date) INTO g_sd_prior FROM DUAL;
      SELECT NVL(fii_time_api.ent_sd_lysper_end(fii_time_api.ent_sd_lysper_end(g_as_of_date)),g_min_start_date)  INTO g_sd_prior_prior FROM DUAL;
      SELECT NVL(fii_time_api.cwk_start(g_sd_prior), g_min_start_date) INTO g_sd_curr_sdate FROM DUAL;

      SELECT NVL(fii_time_api.cwk_start(g_as_of_date), g_min_start_date) INTO g_curr_per_start FROM DUAL;
      SELECT NVL(fii_time_api.cwk_end(g_as_of_date), g_min_start_date) INTO g_curr_per_end FROM DUAL;
      SELECT NVL(fii_time_api.pwk_start(g_previous_asof_date), g_min_start_date) INTO g_prior_per_start FROM DUAL;
      SELECT NVL(fii_time_api.pwk_end(g_previous_asof_date), g_min_start_date) INTO g_prior_per_end FROM DUAL;

WHEN 'FII_TIME_ENT_PERIOD' THEN
      g_bitand := 64;

      IF g_time_comp = 'SEQUENTIAL' THEN
                SELECT NVL(fii_time_api.ent_sd_pper_end(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
      ELSE
                SELECT NVL(fii_time_api.ent_sd_lysper_END(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
      END IF;

     SELECT NVL(fii_time_api.ent_sd_lysper_end(g_as_of_date), g_min_start_date) INTO g_sd_prior FROM DUAL;
     SELECT NVL(fii_time_api.ent_sd_lysper_end(g_sd_prior), g_min_start_date) INTO g_sd_prior_prior FROM DUAL;
     SELECT fii_time_api.ent_cper_end(g_sd_prior)+1 INTO g_sd_curr_sdate  FROM DUAL;


      SELECT NVL(fii_time_api.ent_cper_start(g_as_of_date), g_min_start_date) INTO g_curr_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cper_end(g_as_of_date), g_min_start_date) INTO g_curr_per_end FROM DUAL;
      SELECT NVL(fii_time_api.ent_cper_start(g_previous_asof_date), g_min_start_date) INTO g_prior_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cper_end(g_previous_asof_date), g_min_start_date) INTO g_prior_per_end FROM DUAL;


WHEN 'FII_TIME_ENT_QTR' THEN
      g_bitand := 128;

      IF g_time_comp = 'SEQUENTIAL' THEN
                SELECT NVL(fii_time_api.ent_sd_pqtr_end(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
      ELSE
                SELECT NVL(fii_time_api.ent_sd_lysqtr_end(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
      END IF;

      SELECT NVL(fii_time_api.ent_sd_lysqtr_end(g_as_of_date),g_min_start_date) INTO g_sd_prior FROM dual;
      SELECT NVL(fii_time_api.ent_sd_lysqtr_end(g_sd_prior),g_min_start_date) INTO g_sd_prior_prior FROM dual;
      SELECT fii_time_api.ent_cqtr_end(g_sd_prior)+1 INTO g_sd_curr_sdate FROM dual;

      SELECT NVL(fii_time_api.ent_cqtr_start(g_as_of_date), g_min_start_date) INTO g_curr_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cqtr_end(g_as_of_date), g_min_start_date) INTO g_curr_per_end FROM DUAL;
      SELECT NVL(fii_time_api.ent_cqtr_start(g_previous_asof_date), g_min_start_date) INTO g_prior_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cqtr_end(g_previous_asof_date), g_min_start_date) INTO g_prior_per_end FROM DUAL;

WHEN 'FII_TIME_ENT_YEAR' THEN
      g_bitand := 256;

      SELECT NVL(fii_time_api.ent_pyr_end(fii_time_api.ent_pyr_end(fii_time_api.ent_pyr_end(fii_time_api.ent_pyr_end(g_as_of_date)))), g_min_start_date) INTO g_sd_prior FROM DUAL;
      SELECT NVL(fii_time_api.ent_pyr_end(g_sd_prior), g_min_start_date) INTO g_sd_prior_prior  FROM DUAL;

      SELECT NVL(fii_time_api.ent_cyr_start(g_as_of_date), g_min_start_date) INTO g_curr_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cyr_end(g_as_of_date), g_min_start_date) INTO g_curr_per_end FROM DUAL;
      SELECT NVL(fii_time_api.ent_cyr_start(g_previous_asof_date), g_min_start_date) INTO g_prior_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cyr_end(g_previous_asof_date), g_min_start_date) INTO g_prior_per_end FROM DUAL;

ELSE  g_bitand := 64;
END CASE;

IF g_sd_prior IS NULL THEN
  SELECT NVL(fii_time_api.ent_sd_lysper_end(g_as_of_date), g_min_start_date) INTO g_sd_prior FROM DUAL;
  SELECT NVL(fii_time_api.ent_sd_lysper_end(g_sd_prior), g_min_start_date) INTO g_sd_prior_prior FROM DUAL;
  SELECT fii_time_api.ent_cper_end(g_sd_prior)+1 INTO g_sd_curr_sdate  FROM DUAL;
END IF;

g_self_msg := FND_MESSAGE.get_string('FII', 'FII_AR_SELF');

CASE g_view_by
  WHEN 'CUSTOMER+FII_CUSTOMERS' THEN
	IF g_is_hierarchical_flag = 'Y' THEN
		g_cust_suffix := '_agrt';
	ELSE
		g_cust_suffix := '_base';
	END IF;
	g_cust_view_by := 'VIEW_BY_CUST';
  WHEN 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
	g_cust_suffix := '_base';
	g_cust_view_by := 'VIEW_BY_ACCT';
  ELSE
	g_cust_suffix := '_base';
	g_cust_view_by := NULL;
END CASE;

SELECT fii_ar_util_pkg.get_dso_period_profile
INTO g_dso_period
FROM dual;

CASE
	WHEN g_dso_period = 365 THEN
	        g_dso_bitand := 8192;
	WHEN g_dso_period = 180 THEN
	        g_dso_bitand := 65536;
	WHEN g_dso_period = 90 THEN
	        g_dso_bitand := 4096;
	WHEN g_dso_period = 60 THEN
	        g_dso_bitand := 32768;
	WHEN g_dso_period = 45 THEN
	        g_dso_bitand := 16384;
	WHEN g_dso_period = 30 THEN
	        g_dso_bitand := 2048;
END CASE;

END get_parameters;



/*
PROCEDURE get_viewby_id(p_viewby_id OUT NOCOPY VARCHAR2) IS

BEGIN

CASE g_view_by
  WHEN 'CUSTOMER+FII_CUSTOMERS' THEN
    	p_viewby_id := 'f.party_id';
  WHEN 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
	p_viewby_id := 'f.cust_account_id';
  WHEN 'ORGANIZATION+FII_OPERATING_UNITS' THEN
    	p_viewby_id := 'f.org_id';
  WHEN 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN
	p_viewby_id := 'f.class_code';
  WHEN 'FII_COLLECTOR+FII_COLLECTOR' THEN
	p_viewby_id := 'f.collector_id';
  END CASE;
END get_viewby_id;
*/

FUNCTION get_trend_viewby return VARCHAR2 IS
BEGIN

    IF g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
        return(fnd_message.get_string('FII', 'FII_AR_DBI_YEAR'));
    ELSIF g_page_period_type = 'FII_TIME_ENT_QTR' THEN
        return(fnd_message.get_string('FII', 'FII_AR_DBI_QUARTER'));
    ELSIF g_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
        return(fnd_message.get_string('FII', 'FII_AR_DBI_MONTH'));
    ELSIF g_page_period_type = 'FII_TIME_WEEK' THEN
        return(fnd_message.get_string('FII', 'FII_AR_DBI_WEEK'));
    END IF;

END get_trend_viewby;


PROCEDURE Bind_Variable (p_sqlstmt IN Varchar2,
                         p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_sql_output OUT NOCOPY Varchar2,
                         p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

l_bind_rec BIS_QUERY_ATTRIBUTES;

BEGIN

       p_bind_output_table := BIS_QUERY_ATTRIBUTES_TBL();
       l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
       p_sql_output := p_sqlstmt;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ASOF_DATE';
       l_bind_rec.attribute_value := to_char(g_as_of_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREVIOUS_ASOF_DATE';
       l_bind_rec.attribute_value := to_char(g_previous_asof_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURRENCY';
       l_bind_rec.attribute_value := to_char(g_currency);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

/*
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
       l_bind_rec.attribute_value := g_view_by;
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
*/

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PARTY_ID';
       l_bind_rec.attribute_value := to_char(g_party_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CUST_ACCOUNT_ID';
       l_bind_rec.attribute_value := to_char(g_cust_account_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ORG_ID';
       l_bind_rec.attribute_value := to_char(g_org_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':COLLECTOR_ID';
       l_bind_rec.attribute_value := to_char(g_collector_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':INDUSTRY_ID';
       l_bind_rec.attribute_value := to_char(g_industry_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_PERIOD_START';
       l_bind_rec.attribute_value := to_char(g_curr_per_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_PERIOD_END';
       l_bind_rec.attribute_value := to_char(g_curr_per_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PRIOR_PERIOD_START';
       l_bind_rec.attribute_value := to_char(g_prior_per_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PRIOR_PERIOD_END';
       l_bind_rec.attribute_value := to_char(g_prior_per_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_MONTH_START';
       l_bind_rec.attribute_value := to_char(g_curr_month_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BITAND';
       l_bind_rec.attribute_value := to_char(g_bitand);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':DSO_BITAND';
       l_bind_rec.attribute_value := to_char(g_dso_bitand);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BITAND_INC_TODATE';
       l_bind_rec.attribute_value := to_char(g_bitand_inc_todate);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BITAND_ROLLING_30_DAYS';
       l_bind_rec.attribute_value := to_char(g_bitand_rolling_30_days);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SELF_MSG';
       l_bind_rec.attribute_value := to_char(g_self_msg);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;


       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_SUFIX';
       l_bind_rec.attribute_value := to_char(g_curr_suffix);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':DSO_PERIOD';
       l_bind_rec.attribute_value := to_char(g_dso_period);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SD_PRIOR';
       l_bind_rec.attribute_value := to_char(g_sd_prior, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SD_PRIOR_PRIOR';
       l_bind_rec.attribute_value := to_char(g_sd_prior_prior, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SD_SDATE';
       l_bind_rec.attribute_value := to_char(g_sd_curr_sdate, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CASH_RECEIPT_ID';
       l_bind_rec.attribute_value := to_char(g_cash_receipt_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CUST_TRX_ID';
       l_bind_rec.attribute_value := to_char(g_cust_trx_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':TRAN_NUM';
       l_bind_rec.attribute_value := to_char(g_tran_num);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':TRAN_CLASS';
       l_bind_rec.attribute_value := to_char(g_tran_class);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CUST_ACCOUNT';
       l_bind_rec.attribute_value := to_char(g_cust_account);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':APP_CUST_TRX_ID';
       l_bind_rec.attribute_value := to_char(g_app_cust_trx_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PAGE_REFRESH_DATE';
       l_bind_rec.attribute_value := to_char(g_page_refresh_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

END bind_variable;

FUNCTION get_sec_profile RETURN NUMBER IS
  stmt NUMBER;
BEGIN
  stmt := nvl(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'), -1);
  RETURN stmt;
END get_sec_profile;

FUNCTION get_dso_period_profile RETURN NUMBER IS
  stmt NUMBER;
BEGIN
  stmt := nvl(fnd_profile.value('FII_AR_DSO_PERIOD'), -1);
  RETURN stmt;
END get_dso_period_profile;


FUNCTION get_dso_setup_value(p_category IN VARCHAR2) RETURN VARCHAR2 IS
  l_flag VARCHAR2(1) DEFAULT 'N';

BEGIN
  SELECT dso_value INTO l_flag FROM FII_AR_DSO_SETUP WHERE dso_type = p_category;
  RETURN l_flag;

END get_dso_setup_value;


PROCEDURE get_dso_table_values IS
l_dso_sql VARCHAR2(100);
BEGIN
	l_dso_sql :=	' SELECT dso_type,dso_value FROM FII_AR_DSO_SETUP ';
	EXECUTE IMMEDIATE l_dso_sql BULK COLLECT INTO g_dso_table;

END get_dso_table_values;


FUNCTION determine_OU_LOV RETURN NUMBER IS
    	l_all_org_flag  VARCHAR2(30);
    	l_business_group_id NUMBER;

BEGIN
		g_security_profile_id := fii_ar_util_pkg.get_sec_profile;

		g_security_org_id := fnd_profile.value('ORG_ID');

	IF g_security_profile_id is NOT NULL AND g_security_profile_id <> -1 THEN
		SELECT view_all_organizations_flag, business_group_id
		INTO l_all_org_flag, l_business_group_id
		FROM per_security_profiles
		WHERE security_profile_id = g_security_profile_id;

	/* 'MO: Security Profile' is defined with a global view all security profile.*/
		IF l_all_org_flag = 'Y' and l_business_group_id is NULL THEN
			return 1;
	/* 'MO: Security Profile' is defined with a business group view all security profile.*/
		ELSIF l_all_org_flag = 'Y' and l_business_group_id is NOT NULL THEN
			return 2;
		ELSE
	/* 'MO: Security Profile' is not defined with a view all security profile.*/
			return 3;
		END IF;
	ELSE
	/* 'MO: Security Profile' is not defined. */
		return 4;
	END IF;

END determine_OU_LOV;

FUNCTION get_business_group RETURN NUMBER IS
	l_business_group_id NUMBER;
BEGIN
		g_security_profile_id := fii_ar_util_pkg.get_sec_profile;

	SELECT business_group_id
	INTO l_business_group_id
	FROM per_security_profiles
	WHERE security_profile_id = g_security_profile_id;

	return NVL(l_business_group_id,-1);
EXCEPTION
  when too_many_rows then
    return -1;
  when others then
   return -1;

END get_business_group;

FUNCTION get_display_currency(p_selected_operating_unit      IN VARCHAR2) RETURN VARCHAR2 IS
l_org_id NUMBER;
BEGIN
    IF g_security_profile_id is null then
        g_security_profile_id := nvl(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'), -1);
    END IF;

    	g_det_ou_lov := determine_OU_LOV;

        g_business_group_id := fii_ar_util_pkg.get_business_group;

    IF(p_selected_operating_unit <> 'ALL') then
        IF (g_operating_unit is null or g_operating_unit <> p_selected_operating_unit) THEN
           g_operating_unit := p_selected_operating_unit;

  	   select currency_code
           into g_functional_currency_code
           from ar_system_parameters_all fsp,
                gl_sets_of_books gsob
           where fsp.org_id = p_selected_operating_unit
           and fsp.set_of_books_id = gsob.set_of_books_id;
     	END IF;

	IF (g_functional_currency_code = g_prim_global_currency_code) OR
		(g_functional_currency_code = g_sec_global_currency_code) THEN
	return NULL;
	ELSE
        return g_functional_currency_code;
	END IF;

    ELSE  -- operating unit is 'All'
--        IF g_all_operating_unit is null THEN
--           g_all_operating_unit := p_selected_operating_unit;

IF 	g_det_ou_lov=1  THEN

	 select distinct currency_code
           into g_common_functional_currency
           from ar_system_parameters_all fsp,
             	gl_sets_of_books gsob
           where fsp.set_of_books_id = gsob.set_of_books_id
		and  fsp.org_id = fsp.org_id ;

ELSIF 	g_det_ou_lov=2  THEN
	select distinct currency_code
           into g_common_functional_currency
           from ar_system_parameters_all fsp,
             gl_sets_of_books gsob
           where fsp.set_of_books_id = gsob.set_of_books_id
	 	AND fsp.org_id in (SELECT organization_id
				FROM hr_operating_units
				WHERE business_group_id = fii_ar_util_pkg.g_business_group_id) ;

ELSIF 	g_det_ou_lov=3  THEN
	select distinct currency_code
           into g_common_functional_currency
           from ar_system_parameters_all fsp,
             gl_sets_of_books gsob
           where fsp.set_of_books_id = gsob.set_of_books_id
		AND fsp.org_id in (SELECT organization_id
				FROM per_organization_list
				WHERE security_profile_id = g_security_profile_id) ;

ELSIF 	g_det_ou_lov=4  THEN
l_org_id := nvl(fnd_profile.value('ORG_ID'), -1);
	select distinct currency_code
           into g_common_functional_currency
           from ar_system_parameters_all fsp,
             gl_sets_of_books gsob
           where fsp.set_of_books_id = gsob.set_of_books_id
		AND fsp.org_id = l_org_id ;

END IF;

/*
 select distinct currency_code
           into g_common_functional_currency
           from ar_system_parameters_all fsp,
             gl_sets_of_books_v gsob
           where fsp.set_of_books_id = gsob.set_of_books_id
        AND (
                (
                        g_det_ou_lov=1 AND fsp.org_id = fsp.org_id
                )
                OR (
                        g_det_ou_lov=2
                        AND fsp.org_id in (
                                SELECT organization_id
                                FROM hr_operating_units
                                WHERE business_group_id = fii_ar_util_pkg.g_business_group_id
                        )
                )
                OR (
                        g_det_ou_lov=3
                        AND fsp.org_id in (
                                SELECT organization_id
                                FROM per_organization_list
                                WHERE security_profile_id = g_security_profile_id
                        )
                )
                OR(
                        g_det_ou_lov=4 AND fsp.org_id = nvl(fnd_profile.value('ORG_ID'), -1)
                )
        );

*/
--        END IF;


	IF (g_common_functional_currency =  g_prim_global_currency_code) OR
		(g_common_functional_currency = g_sec_global_currency_code) THEN
	return NULL;
	ELSE
        return g_common_functional_currency;
	END IF;

    END IF;

EXCEPTION
  when too_many_rows then
    g_common_functional_currency := 'N/A';
    return 'N/A';
  when others then
    return 'N/A';
END get_display_currency;


FUNCTION get_curr RETURN VARCHAR2 IS
   stmt                VARCHAR2(240);

BEGIN
  SELECT id INTO stmt FROM fii_currencies_v WHERE id = 'FII_GLOBAL1';
  RETURN stmt;

END get_curr;


/* This procedure is for populating global temporary table FII_AR_SUMMARY_GT. */
PROCEDURE populate_summary_gt_tables IS

l_schema_name		VARCHAR2(10);
l_cust_account_id	VARCHAR2(100);
l_org_count		NUMBER;
l_org_from		VARCHAR2(1000):=NULL;
l_org_list		VARCHAR2(240):=NULL;
l_group_by		VARCHAR2(240):=NULL;
l_party_select		VARCHAR2(500):=NULL;
l_party_from		VARCHAR2(500):=NULL;
l_party_where		VARCHAR2(2000):=NULL;
l_party_group_by	VARCHAR2(500):=NULL;
l_industry_group_by VARCHAR2(500):=NULL;
l_cust_account_where	VARCHAR2(240):=NULL;
l_org_select		VARCHAR2(240):=NULL;
l_select		VARCHAR2(1500):=NULL;
l_select2		VARCHAR2(1500):=NULL;
l_collector_select	VARCHAR2(100):=NULL;
l_collector_where	VARCHAR2(1000):=NULL;
l_org_group_by 		VARCHAR2(100):=NULL;
l_org_specific_where	VARCHAR2(100):=NULL;
l_parent_select 	VARCHAR2(500):=NULL;
l_parent_group_by	VARCHAR2(100):=NULL;
l_industry_from		VARCHAR2(240):=NULL;
l_industry_where	VARCHAR2(500):=NULL;
l_industry_select	VARCHAR2(500):=NULL;
l_all_org_flag  	VARCHAR2(30);
l_business_group_id 	NUMBER;
l_org_count		NUMBER;
l_debug_mode    VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
l_unid_message VARCHAR2(30) := FND_MESSAGE.get_string('FII', 'FII_AR_UNID_CUSTOMER');
l_unassigned_message VARCHAR2(30) := FND_MESSAGE.get_string('BIS', 'EDW_UNASSIGNED');

i number;

TYPE larray IS TABLE OF VARCHAR2(3000) INDEX BY BINARY_INTEGER;

tbl_parent_party_id 	larray;
tbl_party_id   		larray;
tbl_cust_account_id 	larray;
tbl_org_id		larray;
tbl_collector_id	larray;
tbl_view_by		larray;
tbl_viewby_code		larray;
tbl_is_leaf_flag	larray;
tbl_class_code		larray;
tbl_class_category	larray;
tbl_is_self_flag	larray;

l_table_count NUMBER;

BEGIN

l_schema_name := FII_UTIL.get_schema_name('FII');

EXECUTE IMMEDIATE 'truncate table '||l_schema_name||'.fii_ar_summary_gt';


/* This dynamic select in the case of customer dimension is hierarchical checks if the
party chosen is leaf node. If True it gets the immediate parent_party_id  from
fii_customer_hierarches.*/

IF  	g_is_hierarchical_flag  = 'Y'
	AND (g_view_by = 'CUSTOMER+FII_CUSTOMERS' or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS')
	AND (g_count_parent_party_id  = 1  AND g_party_id <> '-111' ) THEN

	l_parent_select := ' f.next_level_is_leaf_flag,(SELECT decode (x.next_level_is_leaf_flag,
     ''Y'', x.parent_party_id, f.child_party_id)
     FROM fii_customer_hierarchies x
     WHERE x.next_level_party_id = f.child_party_id
     AND x.child_party_id = f.child_party_id
     AND x.child_party_id <> x.parent_party_id) parent_party_id ';

	l_parent_group_by := '';--', f.next_level_is_leaf_flag, f.child_party_id ';

ELSIF 	g_is_hierarchical_flag  = 'Y'
	AND (g_view_by = 'CUSTOMER+FII_CUSTOMERS' or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS')
	AND (g_count_parent_party_id > 1 AND g_party_id <> '-111') Then

	l_parent_select := ' f.next_level_is_leaf_flag,(SELECT decode (x.next_level_is_leaf_flag,
     ''Y'', x.parent_party_id, f.child_party_id)
     FROM fii_customer_hierarchies x
     WHERE x.next_level_party_id = f.child_party_id
     AND x.child_party_id = f.child_party_id
     AND x.child_party_id <> x.parent_party_id) parent_party_id ';

	l_parent_group_by := '';--', f.next_level_is_leaf_flag, f.child_party_id ';

ELSIF g_is_hierarchical_flag  = 'Y'
      AND (g_view_by = 'CUSTOMER+FII_CUSTOMERS' or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS')
      AND (g_party_id = '-111') Then

	l_parent_select := ' f.next_level_is_leaf_flag,(SELECT decode (x.next_level_is_leaf_flag,
     ''Y'', x.parent_party_id, f.child_party_id)
     FROM fii_customer_hierarchies x
     WHERE x.next_level_party_id = f.child_party_id
     AND x.child_party_id = f.child_party_id
     AND x.child_party_id <> x.parent_party_id) parent_party_id ';

	l_parent_group_by := '';--', f.next_level_is_leaf_flag, f.child_party_id ';

	--l_parent_select := ' f.next_level_is_leaf_flag, f.parent_party_id ';
	--l_parent_group_by := ', f.next_level_is_leaf_flag, f.parent_party_id ';

ELSIF g_is_hierarchical_flag  = 'N'
	  AND (g_view_by = 'CUSTOMER+FII_CUSTOMERS' or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') Then

	l_parent_select := 'f.next_level_is_leaf_flag, f.parent_party_id  parent_party_id  ' ;
	l_parent_group_by := ' ';--', f.next_level_is_leaf_flag, f.parent_party_id ';

ELSE
	l_parent_select := 'NULL is_leaf_flag, NULL  parent_party_id ' ;
	l_parent_group_by := NULL;

END IF;


/*The below if condition handles the where clause to show rolled up amount for parent
party, when the user chooses multiple parties and out of which one is child of another
party selected. In the case when only 1 party is chosen, the where clause is built to
show both parent self record and all its child parties.*/


IF  g_is_hierarchical_flag  = 'Y' AND g_count_parent_party_id  > 1 THEN

  IF  g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN

	l_party_select := ' ,f.child_party_id child_party_id ';
	l_party_where := ' f.next_level_party_id IN ('||g_party_id||')
		AND	f.parent_party_id <> f.child_party_id  ';

	l_party_from :=' fii_customer_hierarchies f';
	l_party_group_by := '';--'f.child_party_id, p.organization_id, p.name ';

  ELSIF g_view_by = 'CUSTOMER+FII_CUSTOMERS'
	    or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
	l_party_select := ' ,f.child_party_id child_party_id ';
	l_party_where := ' f.next_level_party_id IN ('||g_party_id||')
		AND	f.parent_party_id <> f.child_party_id
		AND	f.next_level_party_id = hz.party_id ';

	l_party_from :=' fii_customer_hierarchies f, hz_parties hz ';
	l_party_group_by := '';--'f.parent_party_id, f.child_party_id, hz.party_name, hz.party_id ';

  ELSIF g_view_by = 'FII_COLLECTOR+FII_COLLECTOR' THEN
	l_party_select := ' ,f.child_party_id child_party_id ';
	l_party_where := ' f.next_level_party_id IN ('||g_party_id||')
		AND	f.parent_party_id <> f.child_party_id ';
		--AND	f.next_level_party_id = hz.party_id ';

	--l_party_from :=' fii_customer_hierarchies f, fii_collectors hz, ar_collectors c ';
        --l_party_from :=' fii_customer_hierarchies f, ar_collectors c ';
        l_party_from :=' fii_customer_hierarchies f, fii_ar_help_collectors c ';
	l_party_group_by := ' ';--' f.child_party_id, c.collector_id,c.name ';

  ELSIF g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN
	l_party_select := ' ,f.child_party_id child_party_id ';
	l_party_where := ' f.next_level_party_id IN ('||g_party_id||')
		AND	f.parent_party_id <> f.child_party_id ';
		--AND	f.next_level_party_id = hz.party_id ';

	--l_party_from :=' fii_customer_hierarchies f, fii_party_mkt_class hz, fnd_lookup_values c ';
        l_party_from :=' fii_customer_hierarchies f, fii_ar_help_mkt_classes c ';
        l_party_group_by := ' ';--' f.child_party_id, c.class_name, c.class_code ';

  END IF;

ELSE

  IF  g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN

    IF g_party_id = '-111' THEN
	l_party_select := ' ,NULL child_party_id ';
	l_party_where := NULL;
	l_party_from := NULL;
	l_party_group_by := NULL;
     ELSE

	l_party_select := ' ,f.child_party_id child_party_id ';
	if g_party_id = '-2' then
		--Bug 5088391
		l_party_where := ' f.child_party_id IN  ('||g_party_id||' ) ';
	else
		l_party_where := ' f.parent_party_id IN  ('||g_party_id||' ) ';
	end if;

	l_party_from :=' fii_customer_hierarchies f ';
	l_party_group_by := '';--'f.child_party_id, p.organization_id,p.name ';
     END IF;
  ELSIF  g_view_by = 'CUSTOMER+FII_CUSTOMERS'
	    or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN

     l_party_select := ' ,f.child_party_id child_party_id ';
     IF g_party_id = '-111' THEN
	IF  g_is_hierarchical_flag  = 'Y' THEN
	l_party_where := '  f.parent_party_id = -999 ';
	ELSE
	l_party_where := '  f.parent_party_id = f.child_party_id ';
	END IF;
     ELSE
	l_party_where := ' f.parent_party_id IN  ('||g_party_id||' ) ';
     END IF;
     	l_party_where := l_party_where||' AND f.next_level_party_id = hz.party_id ';
	l_party_from :=' fii_customer_hierarchies f, hz_parties hz ';
     	l_party_group_by := '';--'f.parent_party_id, f.child_party_id, hz.party_name, hz.party_id ';

  ELSIF g_view_by = 'FII_COLLECTOR+FII_COLLECTOR' THEN
    IF g_party_id = '-111' THEN
	l_party_select := ' ,NULL child_party_id ';
	l_party_where := NULL;
	l_party_from := ' ar_collectors c ';
     	l_party_group_by := ' ';--'c.collector_id,c.name ';
     ELSE
	l_party_select := ' ,f.child_party_id child_party_id ';
        l_party_where := ' f.parent_party_id IN  ('||g_party_id||' ) ';
			 --AND f.child_party_id = hz.party_id ';
	--l_party_from :=' fii_customer_hierarchies f, fii_collectors hz, ar_collectors c ';
        --l_party_from :=' fii_customer_hierarchies f, ar_collectors c ';
        l_party_from :=' fii_customer_hierarchies f, fii_ar_help_collectors c ';
     	l_party_group_by := ' ';--' f.child_party_id, c.collector_id,c.name ';
     END IF;

  ELSIF g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN

    IF g_party_id = '-111' THEN
	l_party_select := ' ,NULL child_party_id ';
	l_party_where := NULL;
	--l_party_from := ' fii_party_mkt_class hz, fnd_lookup_values c ';
        l_party_from := ' fii_ar_help_mkt_classes c ';
     	l_party_group_by := ' c.class_name, c.class_code ';
     ELSE
	l_party_select := ' ,f.child_party_id child_party_id ';
        l_party_where := ' f.parent_party_id IN  ('||g_party_id||' ) ';
	--l_party_from :=' fii_customer_hierarchies f, fii_party_mkt_class hz, fnd_lookup_values c ';
        l_party_from :=' fii_customer_hierarchies f, fii_ar_help_mkt_classes c ';
     	l_party_group_by := ' ';--' f.child_party_id, c.class_name, c.class_code ';
      END IF;

  END IF;

END IF;


/* Handles Org related SELECT, FROM and WHERE clause */

	g_security_profile_id := fii_ar_util_pkg.get_sec_profile;
	g_security_org_id := fnd_profile.value('ORG_ID');

/* Security is dictated by 'MO: Security Profile'. */

 IF g_security_profile_id is not null AND g_security_profile_id <> -1 THEN


    	SELECT view_all_organizations_flag, business_group_id
    	INTO l_all_org_flag, l_business_group_id
    	FROM per_security_profiles
    	WHERE security_profile_id = g_security_profile_id;

	IF g_org_id = -111 THEN
		l_org_specific_where := NULL;
	ELSE
		l_org_specific_where := ' AND per.organization_id= '||g_org_id;
	END IF;


  IF l_all_org_flag = 'Y' and l_business_group_id is NOT NULL THEN

   	l_org_select	:=	' p.organization_id, ';
	l_org_group_by := ' , p.organization_id ';

	IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN

        		l_org_from := ' ( SELECT per.organization_id,hr.name
    			FROM hr_operating_units per, ar_system_parameters_all ar, hr_all_organization_units hr
    			WHERE per.business_group_id = '||l_business_group_id ||'
    			AND per.organization_id = ar.org_id
    			AND per.organization_id = hr.organization_id '||l_org_specific_where||') p ';

	ELSE
	       		l_org_from := ' (SELECT per.organization_id
			FROM hr_operating_units per, ar_system_parameters_all ar
			WHERE per.business_group_id = 	'||l_business_group_id ||'
			AND per.organization_id = ar.org_id '||l_org_specific_where||') p ';

	END IF;
  ELSIF l_all_org_flag = 'Y' and l_business_group_id is NULL THEN

   	l_org_select	:=	' p.organization_id, ';
	l_org_group_by := ' , p.organization_id ';

	IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN

        		l_org_from := ' ( SELECT per.organization_id,hr.name
    			FROM hr_operating_units per, hr_all_organization_units hr
    			WHERE per.organization_id = hr.organization_id '||l_org_specific_where||') p ';

	ELSE
	       		l_org_from := ' (SELECT per.organization_id
			FROM hr_operating_units per
			WHERE 1=1 '||l_org_specific_where||') p ';

	END IF;
  ELSE

	l_org_select	:=	' p.organization_id, ';
	l_org_group_by := ' , p.organization_id ';

	IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN

        		l_org_from := ' ( SELECT per.organization_id,hr.name
    			FROM per_organization_list per, ar_system_parameters_all ar, hr_all_organization_units hr
    			WHERE per.security_profile_id = '||g_security_profile_id||'
    			AND per.organization_id = ar.org_id
    			AND per.organization_id = hr.organization_id '||l_org_specific_where||') p ';

	ELSE
        		l_org_from := ' (SELECT organization_id
		   	FROM per_organization_list per, ar_system_parameters_all ar
			WHERE per.security_profile_id = '||g_security_profile_id ||'
			AND per.organization_id = ar.org_id '||l_org_specific_where||') p ';
	END IF;

  END IF;

/*g_security_profile_id IS NULL i.e. no security profile defined , user has acces to single org*/
 ELSIF g_security_org_id is not null THEN

	IF g_org_id =-111 OR g_org_id = g_security_org_id THEN
		l_org_select	:=	g_security_org_id||' organization_id, ';
	ELSE
		l_org_select	:=	'-1 organization_id, ';
	END IF;

	IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
		l_org_from := ' (SELECT organization_id, name
		FROM hr_all_organization_units
		WHERE organization_id ='||g_security_org_id||') p ';
	ELSE
		l_org_from := NULL;
	END IF;
 ELSE
	/*User has access to no organizations.*/
	l_org_select	:=	'-1 organization_id, ';
	l_org_group_by := NULL;

	IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
		l_org_from :=' (SELECT organization_id, name
			FROM hr_all_organization_units
			WHERE organization_id =-1) p ';
	ELSE
		l_org_from := NULL;
	END IF;
 END IF;


/* Handles the select clause for Collectors */

IF g_view_by = 'FII_COLLECTOR+FII_COLLECTOR' THEN
	l_collector_select := ' c.collector_id, ';
        IF g_party_id = '-111' THEN
           l_collector_where := null;
        ELSE
           l_collector_where := ' exists (select ''x''
                                       from fii_collectors hz
                                       where hz.collector_id = c.collector_id
                                       and hz.party_id = f.child_party_id) ';
        END IF;

	/*
        l_collector_where := ' exists (select ''x''
                                       from fii_collectors hz
                                       where hz.collector_id = c.collector_id '||
                               case when g_party_id <> '-111' then 'AND hz.party_id = f.child_party_id' else '' end||') ';
        */

	IF g_collector_id <> '-111' then
                if l_collector_where is not null then
                  l_collector_where := l_collector_where||' AND c.collector_id = '||g_collector_id;
                else
                  l_collector_where := ' c.collector_id = '||g_collector_id;
                end if;
	END IF;
ELSE
	l_collector_select := NULL;
	l_collector_where := NULL;

	IF g_collector_id = '-111' then
		l_collector_select := ' NULL collector_id, ';
	ELSE
		l_collector_select := g_collector_id||' collector_id, ';
	END IF;
END IF;

/* Handles the where clause for Industry */

IF g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN
	/*
        l_industry_select := ' hz.class_code class_code, hz.class_category class_category, ';
        l_industry_where := ' hz.class_category = c.lookup_type (+)
			     AND   hz.class_code = c.lookup_code (+)
				 AND   nvl(c.language,userenv(''LANG'')) = userenv(''LANG'')
			     AND   nvl(c.view_application_id,222) = 222 ';
        */

        l_industry_select := ' c.class_code class_code, c.class_category class_category, ';
        IF g_party_id = '-111' THEN
           l_industry_where := null;
        ELSE
           l_industry_where := ' exists (select ''x''
                                       from fii_party_mkt_class hz
                                       where hz.class_code = c.class_code
                                       and hz.party_id = f.child_party_id) ';
        END IF;
        /*
	if g_industry_id <> '-111' then
	    l_industry_where := l_industry_where ||'AND hz.class_code='||g_industry_id||' and hz.class_category='''||g_industry_class_type||''' ';
	end if;
        */
	IF g_industry_id <> '-111' then
                if l_industry_where is not null then
                  l_industry_where := l_industry_where ||'AND c.class_code='||g_industry_id||' and c.class_category='''||g_industry_class_type||''' ';
                else
                  l_industry_where := ' c.class_code='||g_industry_id||' and c.class_category='''||g_industry_class_type||''' ';
                end if;
	END IF;

	l_party_group_by := ' ';--l_party_group_by||', c.class_code, c.class_category';
ELSE

  IF g_industry_id = '-111' THEN
	l_industry_select := ' NULL class_code, NULL class_category, ';
    l_industry_from := NULL;
    l_industry_where := NULL;
    l_industry_group_by := ' ';
  ELSE
    IF g_view_by = 'CUSTOMER+FII_CUSTOMERS'
	    or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
		l_industry_select := ' '||g_industry_id||', '''||g_industry_class_type||''', ';
	    l_industry_from := ', fii_party_mkt_class m ';
	    l_industry_where := ' f.child_party_id = m.party_id
    	                      AND m.class_code='||g_industry_id||' and m.class_category='''||g_industry_class_type||'''';
	    l_industry_group_by := ' ';--', m.class_code, m.class_category';
	ELSE
		l_industry_select := ' '||g_industry_id||' class_code, '||''''||g_industry_class_type||''''||' class_category,';
	    l_industry_where := ' m.class_code='||g_industry_id||' and m.class_category='''||g_industry_class_type||'''';

	END IF;
  END IF;

END IF;

/* Code for appending comma, WHERE, AND, GROUP BY clauses to the dynamic SELECT clause */

	IF l_party_from IS NOT NULL AND l_org_from IS NOT NULL THEN
		l_org_from := ','||l_org_from;
	END IF;

	IF l_party_where IS NOT NULL THEN
	   l_party_where := ' WHERE '||l_party_where;
	END IF;

	IF l_collector_where IS NOT NULL and l_party_where IS NULL THEN
	   l_collector_where := ' WHERE '||l_collector_where;
	ELSIF l_collector_where IS NOT NULL and l_party_where IS NOT NULL THEN
	   l_collector_where := ' AND '||l_collector_where;
	END IF;

	IF l_industry_where IS NOT NULL and l_party_where IS NULL THEN
	   l_industry_where := ' WHERE '||l_industry_where;
	ELSIF l_industry_where IS NOT NULL and l_party_where IS NOT NULL THEN
	   l_industry_where := ' AND '||l_industry_where;
	END IF;

	IF l_party_group_by IS NOT NULL THEN
	   l_party_group_by := ' GROUP BY '||l_party_group_by;
	ELSIF l_parent_group_by IS NOT NULL THEN
	   l_parent_group_by := ' GROUP BY '||l_parent_group_by;
	END IF;


--For cases where view by is not Industry, we dont need to use group by
/*If g_view_by = 'CUSTOMER+FII_CUSTOMERS'
	    or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS'
            or g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS'
            or g_view_by = 'FII_COLLECTOR+FII_COLLECTOR' THEN
*/
  l_party_group_by := ' ';
  l_parent_group_by := ' ';
  l_org_group_by := ' ';
  l_industry_group_by := ' ';

--END IF;



/* VIEW BY CUSTOMERS */

IF g_view_by = 'CUSTOMER+FII_CUSTOMERS'
   or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
/*
l_select := ' 	SELECT '||l_parent_select||l_party_select||', '
		||l_org_select||l_collector_select||l_industry_select||
		' hz.party_name view_by FROM '||l_party_from||l_org_from||l_party_where||
		l_party_group_by||l_parent_group_by||l_org_group_by;
*/

l_select := 'SELECT '||l_parent_select||l_party_select||', '
		||l_org_select||l_collector_select||l_industry_select||
		' case when f.parent_party_id = hz.party_id
 				 and f.next_level_is_leaf_flag <> ''Y''
			   then hz.party_name||'' '||g_self_msg||
		 	 ''' else hz.party_name end view_by,
		hz.party_id viewby_code,
		case when f.parent_party_id = hz.party_id
 				 and f.next_level_is_leaf_flag <> ''Y''
			   then ''Y''
		 	 else ''N'' end is_self_flag FROM '||l_party_from||l_org_from||l_industry_from||l_party_where||l_industry_where||
		l_party_group_by||l_parent_group_by||l_org_group_by||l_industry_group_by;

END IF;


/* VIEW BY INDUSTRY */

IF g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN

l_select := ' 	SELECT	'||l_parent_select||l_party_select||', '||l_org_select||l_collector_select||l_industry_select||' c.class_name view_by,
		c.class_code viewby_code, null is_self_flag FROM '||l_party_from||l_org_from||l_industry_from||l_party_where||l_industry_where||
		l_party_group_by||l_org_group_by||l_parent_group_by;

END IF;


/* VIEW BY OPERATING UNIT */

IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN

l_select := ' 	SELECT '||l_parent_select||l_party_select||', '||l_org_select||l_collector_select||l_industry_select||
			' p.name viewby, p.organization_id viewby_code, null is_self_flag FROM '||l_party_from||l_org_from||l_party_where||l_party_group_by||l_parent_group_by;

END IF;


/* VIEW BY COLLECTOR */

IF g_view_by = 'FII_COLLECTOR+FII_COLLECTOR' THEN

l_select := ' 	SELECT 	'||l_parent_select||l_party_select||', '
			||l_org_select||l_collector_select||l_industry_select||' c.name     view_by,
		c.collector_id viewby_code, null is_self_flag FROM '||l_party_from||l_org_from||l_party_where||l_collector_where||
		l_party_group_by||l_org_group_by||l_parent_group_by;

END IF;

IF l_debug_mode = 'Y' THEN

	SELECT	COUNT(*) INTO l_table_count
	FROM	all_tables
	WHERE	table_name = 'FII_AR_DEBUG_STATEMENTS'
	and owner = l_schema_name;

	IF l_table_count  = 0 THEN

		EXECUTE IMMEDIATE 'CREATE TABLE '||l_schema_name||'.FII_AR_DEBUG_STATEMENTS (PACKAGE  VARCHAR2(50),
					                PROCEDURE           VARCHAR2(50),
							SESSION_ID          NUMBER,
							REGION_CODE         VARCHAR2(50),
                                                        SQL_STATEMENT       VARCHAR2(50),
                                                        VALUE               VARCHAR2(1500))';

                EXECUTE IMMEDIATE 'CREATE INDEX '||l_schema_name||'.FII_AR_DEBUG_STATEMENTS_N1 ON '||l_schema_name||'.FII_AR_DEBUG_STATEMENTS
                                          (region_code,
                                           session_id)';

	ELSE
		EXECUTE IMMEDIATE 'DELETE FROM '||l_schema_name||'.FII_AR_DEBUG_STATEMENTS WHERE REGION_CODE = '''||g_region_code||''' AND SESSION_ID = '||g_session_id;

	END IF;

        EXECUTE IMMEDIATE 'INSERT INTO '||l_schema_name||'.FII_AR_DEBUG_STATEMENTS (package,
						                procedure,
								session_id,
								region_code,
								sql_statement,
								value)
				VALUES	       (''FII_AR_UTIL_PKG'',
						''POPULATE_SUMMARY_GT_TABLES'',
						'||g_session_id||','''||g_region_code||''' ,
                                                ''l_select'',
                                                '''||REPLACE(l_select, '''', '''''')||''')';
        commit;

END IF;

/*
EXECUTE IMMEDIATE l_select BULK COLLECT INTO tbl_is_leaf_flag, tbl_parent_party_id, tbl_party_id,
tbl_org_id, tbl_collector_id, tbl_class_code, tbl_class_category, tbl_view_by, tbl_viewby_code, tbl_is_self_flag;

FORALL i in 1 .. tbl_party_id.count
   INSERT INTO  fii_ar_summary_gt (parent_party_id, party_id, org_id, collector_id, viewby, viewby_code, is_leaf_flag, class_code, class_category, is_self_flag)
   VALUES
   (tbl_parent_party_id(i), tbl_party_id(i), tbl_org_id(i), tbl_collector_id(i),
tbl_view_by(i), tbl_viewby_code(i), tbl_is_leaf_flag(i), tbl_class_code(i), tbl_class_category(i), tbl_is_self_flag(i));
*/

EXECUTE IMMEDIATE 'INSERT INTO FII_AR_SUMMARY_GT
            (is_leaf_flag, parent_party_id, party_id, org_id, collector_id, class_code, class_category, viewby, viewby_code, is_self_flag) '
             || l_select;

commit;

--Bug 5055449,5071096, 5173574
------------------------------
IF --g_region_code = 'FII_AR_UNAPP_RCT_SUMMARY'
   (g_view_by = 'CUSTOMER+FII_CUSTOMERS'
	    or g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS')
   AND (g_party_id = '-111' or g_party_id = '-2') THEN

	IF l_org_from is not null THEN

		l_select2 := 'SELECT ''Y'' is_leaf_flag, -999 parent_party_id, -2 party_id, '
				||l_org_select||l_collector_select||' -1 class_code, '''||g_industry_class_type||''', '||
				' '''||l_unid_message||''' view_by,
				 -2 viewby_code,
				 ''N'' is_self_flag FROM '|| LTRIM(l_org_from, ',');
    ELSE

		l_select2 := 'SELECT ''Y'' is_leaf_flag, -999 parent_party_id, -2 party_id, '
				||l_org_select||l_collector_select||' -1 class_code, '''||g_industry_class_type||''', '||
				' '''||l_unid_message||''' view_by,
				 -2 viewby_code,
				 ''N'' is_self_flag FROM dual';

	END IF;
/*
	EXECUTE IMMEDIATE l_select2 BULK COLLECT INTO tbl_is_leaf_flag, tbl_parent_party_id, tbl_party_id,
	tbl_org_id, tbl_collector_id, tbl_class_code, tbl_class_category, tbl_view_by, tbl_viewby_code, tbl_is_self_flag;


	FORALL i in 1 .. tbl_party_id.count
	   INSERT INTO  fii_ar_summary_gt (parent_party_id, party_id, org_id, collector_id, class_code, class_category, viewby, viewby_code, is_leaf_flag, is_self_flag)
	   VALUES
	   (tbl_parent_party_id(i), tbl_party_id(i), tbl_org_id(i), tbl_collector_id(i), tbl_class_code(i), tbl_class_category(i),
	    tbl_view_by(i), tbl_viewby_code(i), tbl_is_leaf_flag(i), tbl_is_self_flag(i));
*/
        EXECUTE IMMEDIATE 'INSERT INTO FII_AR_SUMMARY_GT
            (is_leaf_flag, parent_party_id, party_id, org_id, collector_id, class_code, class_category, viewby, viewby_code, is_self_flag) '
             || l_select2;

ELSIF  g_view_by = 'FII_COLLECTOR+FII_COLLECTOR'
           AND ((g_collector_id = '-111' AND g_party_id = '-111')
                or g_party_id = '-2')  THEN

	IF l_org_from is not null THEN

		l_select2 := 'SELECT null is_leaf_flag, null parent_party_id, '||case when g_party_id = '-2' then '-2' else 'null' end||' party_id, '
				||l_org_select||' -1 collector_id, '||l_industry_select||
				' '''||l_unid_message||''' view_by,
				 -1 viewby_code,
				 null is_self_flag FROM '|| LTRIM(l_org_from, ',');
    ELSE

		l_select2 := 'SELECT null is_leaf_flag, null parent_party_id, '||case when g_party_id = '-2' then '-2' else 'null' end||' party_id, '
				||l_org_select||' -1 collector_id, '||l_industry_select||
				' '''||l_unid_message||''' view_by,
				 -1 viewby_code,
				 null is_self_flag FROM dual';

	END IF;

/*
	EXECUTE IMMEDIATE l_select2 BULK COLLECT INTO tbl_is_leaf_flag, tbl_parent_party_id, tbl_party_id,
	tbl_org_id, tbl_collector_id, tbl_class_code, tbl_class_category, tbl_view_by, tbl_viewby_code, tbl_is_self_flag;


	FORALL i in 1 .. tbl_party_id.count
	   INSERT INTO  fii_ar_summary_gt (parent_party_id, party_id, org_id, collector_id, class_code, class_category, viewby, viewby_code, is_leaf_flag, is_self_flag)
	   VALUES
	   (tbl_parent_party_id(i), tbl_party_id(i), tbl_org_id(i), tbl_collector_id(i), tbl_class_code(i), tbl_class_category(i),
	    tbl_view_by(i), tbl_viewby_code(i), tbl_is_leaf_flag(i), tbl_is_self_flag(i));
*/
        EXECUTE IMMEDIATE 'INSERT INTO FII_AR_SUMMARY_GT
            (is_leaf_flag, parent_party_id, party_id, org_id, collector_id, class_code, class_category, viewby, viewby_code, is_self_flag) '
             || l_select2;


ELSIF  g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS'
           AND g_party_id = '-2' THEN

	IF l_org_from is not null THEN

		l_select2 := 'SELECT ''Y'' is_leaf_flag, -999 parent_party_id, -2 party_id, '
				||l_org_select||l_collector_select||' -1 class_code, '''||g_industry_class_type||''', '||
				' '''||l_unid_message||''' view_by,
				 -2 viewby_code,
				 ''N'' is_self_flag FROM '|| LTRIM(l_org_from, ',');
    ELSE

		l_select2 := 'SELECT ''Y'' is_leaf_flag, -999 parent_party_id, -2 party_id, '
				||l_org_select||l_collector_select||' -1 class_code, '''||g_industry_class_type||''', '||
				' '''||l_unid_message||''' view_by,
				 -2 viewby_code,
				 ''N'' is_self_flag FROM dual';

	END IF;
/*
	EXECUTE IMMEDIATE l_select2 BULK COLLECT INTO tbl_is_leaf_flag, tbl_parent_party_id, tbl_party_id,
	tbl_org_id, tbl_collector_id, tbl_class_code, tbl_class_category, tbl_view_by, tbl_viewby_code, tbl_is_self_flag;


	FORALL i in 1 .. tbl_party_id.count
	   INSERT INTO  fii_ar_summary_gt (parent_party_id, party_id, org_id, collector_id, class_code, class_category, viewby, viewby_code, is_leaf_flag, is_self_flag)
	   VALUES
	   (tbl_parent_party_id(i), tbl_party_id(i), tbl_org_id(i), tbl_collector_id(i), tbl_class_code(i), tbl_class_category(i),
	    tbl_view_by(i), tbl_viewby_code(i), tbl_is_leaf_flag(i), tbl_is_self_flag(i));
*/
        EXECUTE IMMEDIATE 'INSERT INTO FII_AR_SUMMARY_GT
            (is_leaf_flag, parent_party_id, party_id, org_id, collector_id, class_code, class_category, viewby, viewby_code, is_self_flag) '
             || l_select2;


END IF;

IF l_debug_mode = 'Y' THEN
	insert_into_debug_table;

        EXECUTE IMMEDIATE 'INSERT INTO '||l_schema_name||'.FII_AR_DEBUG_STATEMENTS (package,
						                procedure,
								session_id,
								region_code,
								sql_statement,
								value)
				VALUES	       (''FII_AR_UTIL_PKG'',
						''POPULATE_SUMMARY_GT_TABLES'',
						'||g_session_id||','''||g_region_code||''' ,
                                                ''l_select2'',
                                                '''||REPLACE(l_select2, '''', '''''')||''')';

	 commit;

END IF;

END populate_summary_gt_tables;



PROCEDURE insert_into_debug_table IS
/* logic for this api...
1. We first search for existence of debug table. If it doesn't exist, we create it else we delete the records inserted for the same session_id and region code.
2. We then insert all columns of corresponding gt table + session_id and report_region_code into debug tables.
*/

l_table_count NUMBER := 0;
l_schema_name	VARCHAR2(10) := FII_UTIL.get_schema_name('FII');

BEGIN

	SELECT	COUNT(*) INTO l_table_count
	FROM	all_tables
	WHERE	table_name = 'FII_AR_DEBUG_SUMMARY'
	and owner = l_schema_name;

	IF l_table_count  = 0 THEN

		EXECUTE IMMEDIATE 'CREATE TABLE '||l_schema_name||'.FII_AR_DEBUG_SUMMARY (PARENT_PARTY_ID     NUMBER(15),
					        PARTY_ID            NUMBER(15),
							ORG_ID              NUMBER(15),
							COLLECTOR_ID        NUMBER(15),
							IS_LEAF_FLAG        VARCHAR2(10),
							IS_SELF_FLAG        VARCHAR2(10),
							CLASS_CODE          VARCHAR2(30),
							CLASS_CATEGORY      VARCHAR2(30),
							VIEWBY              VARCHAR2(360),
							VIEWBY_CODE         VARCHAR2(30),
							SESSION_ID          NUMBER,
							REGION_CODE		    VARCHAR2(50))';

                EXECUTE IMMEDIATE 'CREATE INDEX '||l_schema_name||'.FII_AR_DEBUG_SUMMARY_N1 ON '||l_schema_name||'.FII_AR_DEBUG_SUMMARY
                                          (region_code,
                                           session_id)';

	ELSE
		EXECUTE IMMEDIATE 'DELETE FROM '||l_schema_name||'.FII_AR_DEBUG_SUMMARY WHERE REGION_CODE = '''||g_region_code||''' AND SESSION_ID = '||g_session_id;

	END IF;

		EXECUTE IMMEDIATE 'INSERT INTO '||l_schema_name||'.FII_AR_DEBUG_SUMMARY (PARENT_PARTY_ID,
						        PARTY_ID,
								ORG_ID,
								COLLECTOR_ID,
								IS_LEAF_FLAG,
								IS_SELF_FLAG,
								CLASS_CODE,
								CLASS_CATEGORY,
								VIEWBY,
								VIEWBY_CODE,
								SESSION_ID,
								REGION_CODE)
				SELECT		gt.PARENT_PARTY_ID,
						    gt.PARTY_ID,
							gt.ORG_ID,
							gt.COLLECTOR_ID,
							gt.IS_LEAF_FLAG,
							gt.IS_SELF_FLAG,
							gt.CLASS_CODE,
							gt.CLASS_CATEGORY,
							gt.VIEWBY,
							gt.VIEWBY_CODE,
							'||g_session_id||','''||g_region_code||'''
				FROM		fii_ar_summary_gt gt';

END insert_into_debug_table;


/*The following procedure parses the g_party_id i.e. party_id parameter value passed by BIS from
PMV parameter region. After that in the case of customers defined is hierarchical and if both
parent and children are chosen together from customer parameter then only the parent should be
stored in g_party_id variable.*/

PROCEDURE populate_party_id AS

  l_parse_party_id 	VARCHAR2(5000):=NULL;
  l_party_id 		VARCHAR2(5000):=NULL;
  l_tmp_party_id	VARCHAR2(5000):=NULL;
  l_new_party_id 	VARCHAR2(5000):=NULL;

  l_select		VARCHAR2(10000);
  l_count_party_id	NUMBER:=1;
  l_substr_start	NUMBER:=1;
  l_occur		NUMBER:=1;
  l_position		NUMBER;
  l_str_length		NUMBER;
  l_substr_val		NUMBER;

TYPE larray IS TABLE OF VARCHAR2(3000) INDEX BY BINARY_INTEGER;
tbl_parent_party_id 	larray;


BEGIN

IF g_party_id IS NOT NULL THEN /* Check party_id not Null  */
  LOOP

	SELECT INSTR(g_party_id,',', 1, l_occur)  into l_position FROM DUAL;
   	   IF l_position =0 THEN
    		SELECT LENGTH(g_party_id) INTO l_str_length  FROM DUAL;
    		l_substr_val := l_str_length - (l_substr_start-1);
	   ELSE
  		l_substr_val := l_position - l_substr_start;
	   END IF;
	SELECT SUBSTR(g_party_id, l_substr_start, l_substr_val)  into l_tmp_party_id FROM DUAL;

	   IF l_parse_party_id IS NULL THEN
		l_parse_party_id := l_tmp_party_id;
	   ELSE
		l_parse_party_id := l_parse_party_id||','||l_tmp_party_id;
	        l_count_party_id := l_count_party_id +1;
	   END IF;
	l_occur := l_occur+1;
	l_substr_start := l_position+1;
  EXIT when l_position=0;
  END LOOP;


g_count_parent_party_id := 0;
IF g_is_hierarchical_flag = 'Y'  and l_count_party_id  > 1 THEN

l_select := ' SELECT parent_party_id FROM fii_customer_hierarchies p
		WHERE p.parent_party_id=p.next_level_party_id
		AND p.next_level_party_id = p.child_party_id
		AND p.child_party_id IN ('||l_parse_party_id||')
		AND NOT EXISTS (SELECT  c.child_party_id FROM fii_customer_hierarchies c
			WHERE c.child_party_id IN ('||l_parse_party_id||')
			AND   c.parent_party_id IN ('||l_parse_party_id||')
			AND c.parent_party_id <> c.next_level_party_id
			and c.child_party_id = p.child_party_id) ';

EXECUTE IMMEDIATE l_select BULK COLLECT INTO tbl_parent_party_id;

FOR a IN tbl_parent_party_id.FIRST..tbl_parent_party_id.LAST LOOP
	IF   l_party_id IS NULL THEN
		l_party_id := tbl_parent_party_id(a);

	ELSE
		l_party_id := l_party_id||','||tbl_parent_party_id(a);

	END IF;
	g_count_parent_party_id := g_count_parent_party_id +1;

END LOOP;

ELSE
	l_party_id := l_parse_party_id;
	g_count_parent_party_id := l_count_party_id;
END IF;

g_party_id := l_party_id;

END IF; /* Check party_id not Null  */

END populate_party_id;

FUNCTION get_prim_global_currency_code RETURN VARCHAR2 IS
BEGIN
  RETURN bis_common_parameters.get_currency_code;
END get_prim_global_currency_code;

FUNCTION get_sec_global_currency_code RETURN VARCHAR2 IS
BEGIN
  RETURN bis_common_parameters.get_secondary_currency_code;
END get_sec_global_currency_code;

FUNCTION get_from_statement RETURN VARCHAR2 IS
BEGIN
  IF g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
   	RETURN 'fii_ar_summary_gt_v';
  ELSE
	RETURN 'fii_ar_summary_gt';
  END IF;
END get_from_statement;

FUNCTION get_where_statement RETURN VARCHAR2 IS
BEGIN
	RETURN '1=1';
END get_where_statement;

FUNCTION get_mv_where_statement RETURN VARCHAR2 IS
BEGIN

 IF g_cust_suffix = '_base' THEN
    IF g_region_code IN  ('FII_AR_DISCOUNT_SUMMARY',
                          		'FII_AR_COLL_EFF_INDEX',
                         			'FII_AR_DSO',
                          		'FII_AR_DSO_TREND',
                          		'FII_AR_BILLING_ACTIVITY',
                          		'FII_AR_BILL_ACTIVITY_TABLE',
                          		'FII_AR_UNAPP_RCT_SUMMARY',
                          		'FII_AR_UNAPP_RCT_SUMM_TBL',
                          		'FII_AR_NET_REC_SUM',
                          		'FII_AR_CURR_REC_SUMMARY',
                          		'FII_AR_PDUE_REC_TREND',
                          		'FII_AR_RECEIVABLES_AGING',
                          		'FII_AR_PASTDUE_REC_AGING',
                          		'FII_AR_TOP_PDUE_CUSTOMER',
                          		'FII_AR_OPEN_REC_SUMMARY',
                          		'FII_AR_OPEN_REC_PDUE')  THEN

IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN

    IF  (g_org_id <> '-111' AND g_party_id = '-111' AND g_collector_id = '-111'
       AND g_industry_id = '-111')
    THEN
       RETURN 'gid = 1271' ;
    ELSIF (g_org_id = '-111' AND g_party_id = '-111' AND g_collector_id = '-111'
         AND g_industry_id = '-111')
    THEN
        RETURN 'gid = 1271 ';
    ELSE
       RETURN 'gid = 1025' ;
   END IF;

ELSE

    RETURN 'gid = 1025';

 END IF;

    ELSIF g_region_code IN  ('FII_AR_REC_ACTIVITY_TREND',
                              'FII_AR_REC_ACTIVITY',
                              'FII_AR_COLL_EFFECTIVENESS',
                              'FII_AR_UNAPP_RCT_TREND',
                              'FII_AR_COLL_EFF_TREND')  THEN

IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN

  IF  (g_org_id <> '-111' AND g_party_id = '-111' AND g_collector_id = '-111'
       AND g_industry_id = '-111')
  THEN
       RETURN 'gid = 246' ;
  ELSIF (g_org_id = '-111' AND g_party_id = '-111' AND g_collector_id = '-111'
        AND g_industry_id = '-111')
  THEN RETURN 'gid = 246 ';
  ELSE
       RETURN 'gid = 0';
  END IF;

ELSE

    RETURN 'gid = 0';

 END IF;

 ELSIF
       g_region_code IN  ('FII_AR_RECEIVABLES_AGING') THEN
            IF g_party_id = '-111' AND g_collector_id = '-111' AND g_org_id <> '-111'
            THEN

              RETURN 'gid = 1271';
            ELSIF g_party_id = '-111' AND g_collector_id = '-111' AND g_org_id = '-111'
              THEN RETURN 'gid=1271';
            ELSE

              RETURN 'gid = 1025';

            END IF;

   ELSE  --If the region code does not match

      RETURN '1=1';

   END IF;


   ELSIF g_cust_suffix = '_agrt' THEN
   IF g_region_code IN  ('FII_AR_DISCOUNT_SUMMARY',
                          		'FII_AR_COLL_EFF_INDEX',
                         			'FII_AR_DSO',
                          		'FII_AR_DSO_TREND',
                          		'FII_AR_BILLING_ACTIVITY',
                          		'FII_AR_BILL_ACTIVITY_TABLE',
                          		'FII_AR_UNAPP_RCT_SUMMARY',
                          		'FII_AR_UNAPP_RCT_SUMM_TBL',
                          		'FII_AR_NET_REC_SUM',
                          		'FII_AR_CURR_REC_SUMMARY',
                          		'FII_AR_PDUE_REC_TREND',
                          		'FII_AR_RECEIVABLES_AGING',
                          		'FII_AR_PASTDUE_REC_AGING',
                          		'FII_AR_TOP_PDUE_CUSTOMER',
                          		'FII_AR_OPEN_REC_SUMMARY',
                          		'FII_AR_OPEN_REC_PDUE') THEN


       	     RETURN 'gid = 1025';

   ELSIF g_region_code IN  ('FII_AR_REC_ACTIVITY_TREND',
                              'FII_AR_REC_ACTIVITY',
                              'FII_AR_COLL_EFFECTIVENESS',
                              'FII_AR_UNAPP_RCT_TREND',
                              'FII_AR_COLL_EFF_TREND')  THEN

       	    RETURN 'gid = 0';

   ELSE  --If the region code does not match

     RETURN '1=1';

   END IF;
   END IF;



END get_mv_where_statement;

FUNCTION get_rct_mv_where_statement RETURN VARCHAR2 IS
BEGIN

    IF g_cust_suffix = '_base'  THEN

      IF g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
          IF  (g_org_id <> '-111' AND g_party_id = '-111' AND g_collector_id = '-111'
               AND g_industry_id = '-111')
          THEN
              RETURN 'gid = 123' ;
          ELSIF (g_org_id = '-111' AND g_party_id = '-111' AND g_collector_id = '-111'
               AND g_industry_id = '-111') THEN
              RETURN 'gid = 123';
          ELSE
              RETURN 'gid = 0';
          END IF;
      ELSE
         RETURN 'gid = 0';
       END IF;
    ELSE
      RETURN '1=1';
    END IF;


END get_rct_mv_where_statement;

PROCEDURE get_page_refresh_date  IS

BEGIN

select nvl(last_refresh_date,sysdate) INTO g_page_refresh_date
from bis_obj_properties
where object_name = 'FII_AR_STATUS_DASHBOARD'
and object_type = 'PAGE';
EXCEPTION
WHEN OTHERS THEN
g_page_refresh_date := sysdate;
END get_page_refresh_date;

END fii_ar_util_pkg;

/
