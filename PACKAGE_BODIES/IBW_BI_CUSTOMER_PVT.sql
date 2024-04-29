--------------------------------------------------------
--  DDL for Package Body IBW_BI_CUSTOMER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_BI_CUSTOMER_PVT" AS
/* $Header: ibwbcusb.pls 120.9 2006/02/24 06:08 gjothiku noship $ */
/**********************************************************************************************
 *  PROCEDURE   : GET_CUST_ACQUIS_TREND_SQL 																	                *
 *  PURPOSE     : This procedure is used to build the portlet query required                  *
 *                to render the Web Customer Acquisition Report.                              *
 *                                                                                            *
 *	PARAMETERS	:                                                                             *
 *					 p_param        varchar2 IN:  This is used to get the parameters                  *
 *                                         selected from the parameter portlet                *
 *					 x_custom_sql   varchar2 OUT  This is used to send the portlet query              *
 *					 x_cusom_output varchar2 OUT  This is used to send the bind variables             *
 *					                                                                                  *
**********************************************************************************************/

PROCEDURE GET_CUST_ACQUIS_TREND_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL )
IS
-- Generic Variables

  l_custom_sql          VARCHAR2(15000) ; --Final Sql.
  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_site                VARCHAR2(3200);  --Site Id
  l_period_type         VARCHAR2(1000);  --Period Type
  l_page                VARCHAR2(3200);  -- Page
  l_site_area           VARCHAR2(3200);  -- Site Area
  l_referral            VARCHAR2(3200); -- Referral Dimension
  l_campaign            VARCHAR2(3200);
  l_cust_class          VARCHAR2(3200); -- Customer Classification
  l_cust                VARCHAR2(3200); -- Customer
  l_prod_catg           VARCHAR2(3200); -- Product Category
  l_prod                VARCHAR2(3200); -- Product
  l_view_by             VARCHAR2(3200);
  l_site_from           VARCHAR2(3200);
  l_site_where          VARCHAR2(3200);
  l_from                VARCHAR2(3200);
  l_where               VARCHAR2(3200);
  l_outer_select        VARCHAR2(3200);
  l_outer_where         VARCHAR2(3200);

-- Specific Variables

  l_currency     VARCHAR2(3200) ; -- Currency
  l_gp_currency  VARCHAR2(15);    --Global Primary Currency
  l_gs_currency  VARCHAR2(15);    --Global Secondary Curr

  --FND Logging
  l_full_path   VARCHAR2(50);
  gaflog_value  VARCHAR2(10);


BEGIN

  --FND Logging
  l_full_path  := 'ibw.plsql.ibwbcusb.get_cust_acquis_trend_sql';
--Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');

--Fetch all the Parameters into the Local Variables.

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'BEGIN');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;

  IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
  (
    P_PMV_PARAMETERS   =>  p_pmv_parameters,
    X_PERIOD_TYPE	     =>  l_period_type,
    X_SITE             =>  l_site,
    X_CURRENCY_CODE    =>  l_currency,
    X_SITE_AREA        =>  l_site_area,  --Not Wanted
    X_PAGE             =>  l_page,       --Not Wanted
    X_VIEW_BY          =>  l_view_by,    --Not Wanted
    X_CAMPAIGN		     =>  l_campaign,   --Not Wanted
    X_REFERRAL         =>  l_referral,   --Not Wanted
    X_PROD_CAT         =>  l_prod_catg,  --Not Wanted
    X_PROD             =>  l_prod,       --Not Wanted
    X_CUST_CLASS       =>  l_cust_class,
    X_CUST             =>  l_cust        --Not Wanted
  );

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site ||' l_cust : '|| l_cust || ' l_currency : ' || l_currency || ' l_period_type : ' || l_period_type );
  END IF;

  --Initializing section starts
  l_gp_currency        := '''FII_GLOBAL1''' ;
  l_gs_currency        := '''FII_GLOBAL2''' ;
  l_where              := '';
  l_from               := '';
  l_site_where         := '';
  l_site_from          := '';
  l_outer_select       := '';
  l_outer_where        := '';
  l_custom_sql         := '';
  l_custom_rec		     :=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  --Initializing section completed

  --Get the Table List

  l_from   := ' IBW_VISIT_CUST_TIME_MV CUSTACQUIS_MV' ||
              ' ,FII_TIME_RPT_STRUCT_V CAL' ||
	 	          ' ,FII_PARTY_MKT_CLASS CUST_CLASS_MAP';    -- This is a mapping table between customer classification and customers ( party_id )

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_from : ' || l_from );
  END IF;

-- Initialising where clause based for time dimension

  l_where := l_where ||
					   ' cal.report_date	= dates.report_date AND
					     CUSTACQUIS_MV.time_id =	cal.time_id AND
					     CUSTACQUIS_MV.period_type_id = cal.period_type_id AND
					     bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id AND
               cal.CALENDAR_ID = -1 ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_where : ' || l_where );
  END IF;

-- Initialising where clause based on the parameter selection
-- The site where clause is kept in a seperate variable because New Web Customers through
-- all channels does not depend on site dimension.

  IF upper(l_site) <> 'ALL' THEN
    l_site_where    := l_site_where  ||
				                      ' AND CUSTACQUIS_MV.SITE_ID in (&SITE+SITE)' ;

  ELSE
    l_site_from     := l_site_from  || ', IBW_BI_MSITE_DIMN_V SITE';
    l_site_where    := l_site_where  ||
				                      ' AND CUSTACQUIS_MV.SITE_ID = SITE.ID ';
  END IF;

  IF upper(l_cust_class) <> 'ALL' THEN
    l_where    := l_where  ||
				                 ' AND CUSTACQUIS_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				                 ' AND CUST_CLASS_MAP.class_code in (&FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  ELSE
    l_from      := l_from || ' ,FII_TRADING_PARTNER_MKTCLASS_V CUSTCLASS';
    l_where     := l_where  ||
		                      ' AND CUSTACQUIS_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				                  ' AND CUST_CLASS_MAP.class_code = CUSTCLASS.ID ';
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,' l_from : ' || l_from || ' l_where : ' || l_where ||' l_site_from : '|| l_site_from ||' l_site_where : '|| l_site_where);
  END IF;

-- Initialising the outer select clause. For any ratios divide by zero issue is also handled

--  Not returning value for IBW_VAL2 and IBW_VAL4 as per bug # 4772549.


  l_outer_select  :=     '  time_dim.NAME VIEWBY,
                            NVL(WEB_REG_P,0)                        IBW_VAL8, --Bug#4727078 Issue#:21
                            NVL(WEB_REG_C,0)                        IBW_VAL1,
                            NVL(WEB_CUST_P,0)                       IBW_VAL9,  --Bug#4727078 Issue#:21
                            NVL(WEB_CUST_C,0)                       IBW_VAL3,
                            (DECODE(NVL(WEB_CUST_ALL,0),0,null,
                            NVL(WEB_CUST_C,0)/WEB_CUST_ALL)*100)    IBW_VAL5,
                            NVL(BOOKED_AMOUNT_C,0)                  IBW_VAL6,
                            DECODE(NVL(BOOKED_ORDERS_C,0),0,null,
                            NVL(BOOKED_AMOUNT_C,0)/BOOKED_ORDERS_C) IBW_VAL7
                            FROM  (
                             SELECT
                               start_date START_DATE,
                               SUM(WEB_REG_C) WEB_REG_C,
                               SUM(WEB_REG_P) WEB_REG_P,
                               SUM(WEB_CUST_C) WEB_CUST_C,
                               SUM(WEB_CUST_P) WEB_CUST_P,
                               SUM(WEB_CUST_ALL) WEB_CUST_ALL,
                               SUM(BOOKED_AMOUNT_C) BOOKED_AMOUNT_C,
                               SUM(BOOKED_ORDERS_C) BOOKED_ORDERS_C ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_outer_select : ' || l_outer_select );
  END IF;

-- Initialising the outer where clause

  l_outer_where := ' time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE AND
                     time_dim.start_date = s.start_date(+) ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_outer_where : ' || l_outer_where );
  END IF;

 /*************************************************************************/
 /* IBW_VAL1                  : Web Registrations                         */
 /* IBE_VAL2                  : Change					                          */
 /* IBW_VAL3                  : New Web Customers                         */
 /* IBW_VAL4                  : Change					                          */
 /* IBW_VAL5                  : Percent New Web Customers                 */
 /* IBW_VAL6                  : Booked Web Orders Amount                  */
 /* IBW_VAL7                  : Average Web Order Value                   */
 /* IBW_VAL8                  : Prior Registrations                       */
 /* IBW_VAL9                  : Prior New Web Customers                   */
 /*************************************************************************/
 /*                 BIS parameters used                                   */
 /*************************************************************************/
 /* &BIS_CURRENT_ASOF_DATE	           Current as of date                 */
 /* &BIS_CURRENT_REPORT_START_DATE  	 Start date based on report compare */
 /*                                    to parameter                       */
 /* &BIS_PREVIOUS_ASOF_DATE	Previous   As of date                         */
 /* &BIS_PREVIOUS_REPORT_START_DATE	   Previous start date based on report*/
 /*                                    compare to parameter               */
 /* &BIS_NESTED_PATTERN 	             Used in the bitand function to     */
 /*                                    select appropriate record_type_id  */
 /*                                    based on the period selected       */
 /*************************************************************************/

-- The inner most select clause has two UNION ALLs
-- The first UNION ALL fetches Web Registrations,Change,New Web Customers,Change,Booked Web Orders Amount, Average Web Order Value
-- The second UNION ALL fetches new web customers through all channels which is used to calculate Percent New Web Customers

 l_custom_sql := ' SELECT '|| l_outer_select ||
			           ' FROM  ' ||
                      '(
                       SELECT
                       dates.start_date  START_DATE,
                       decode(dates.period, ''C'',web_registrations,0) WEB_REG_C,
                       decode(dates.period, ''P'',web_registrations,0) WEB_REG_P,
                       decode(dates.period, ''C'',new_web_customers,0) WEB_CUST_C,
                       decode(dates.period, ''P'',new_web_customers,0) WEB_CUST_P,
                       NULL WEB_CUST_ALL,
                       decode(dates.period, ''C'',
                       decode(:l_currency,:l_gp_currency,BOOKED_AMT_G,:l_gs_currency,BOOKED_AMT_G1,CURRENCY_CD_F,BOOKED_AMT_F),0) BOOKED_AMOUNT_C,
                       decode(dates.period, ''C'',booked_web_orders,0) BOOKED_ORDERS_C
                       FROM
                        (
                         SELECT
                         time_dim.start_date START_DATE,
                         ''C'' PERIOD,
                         least(time_dim.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
                         FROM '||l_period_type||'   time_dim
                         WHERE time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
                          UNION ALL
                         SELECT
                         p2.start_date START_DATE,
                         ''P'' PERIOD,
                         p1.report_date REPORT_DATE
                         FROM
                          (SELECT
                            least(time_dim.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE,
                            rownum ID
                            FROM ' ||l_period_type||'   time_dim
                            WHERE time_dim.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
                            ORDER BY time_dim.start_date DESC) p1,
                            (SELECT time_dim.start_date START_DATE,
                            rownum ID
                            FROM  ' ||l_period_type||'  time_dim
                            WHERE time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
                            ORDER BY time_dim.start_date DESC) p2
                        WHERE p1.id(+) = p2.id) dates, '||l_from || l_site_from ||'
                        WHERE ' || l_where	|| l_site_where ||
                ' UNION ALL
                  SELECT
                       dates.start_date  START_DATE,
                       null WEB_REG_C,
                       null WEB_REG_P,
                       null WEB_CUST_C,
                       null WEB_CUST_P,
                       DECODE(dates.period, ''C'',new_web_customers_all,null) WEB_CUST_ALL,
                       null BOOKED_AMOUNT_C,
                       null BOOKED_ORDERS_C
                       FROM
                        (
                         SELECT
                         time_dim.start_date START_DATE,
                         ''C'' PERIOD,
                         least(time_dim.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
                         FROM '||l_period_type||'   time_dim
                         WHERE time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
                          UNION ALL
            SELECT
              p2.start_date START_DATE,
              ''P'' PERIOD,
              p1.report_date REPORT_DATE
            FROM
              (
                SELECT
                  REPORT_DATE,
                  rownum id
                FROM
                (
                SELECT
                  least(time_dim.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
                FROM
                  ' ||l_period_type||'   time_dim
                WHERE
                  time_dim.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
                ORDER BY time_dim.start_date DESC
                )
              )  p1,
              (
              SELECT
                START_DATE,
                rownum id
              FROM
              (
                SELECT time_dim.start_date START_DATE
                FROM  ' ||l_period_type||'  time_dim
                WHERE time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
                ORDER BY time_dim.start_date DESC
                )
              ) p2
                        WHERE p1.id(+) = p2.id) dates, '|| l_from ||'
                        WHERE	 '|| l_where  ||
                        ' AND CUSTACQUIS_MV.site_id = -9999 )
                GROUP BY start_date
                ) s,'|| l_period_type||' time_dim
            WHERE '|| l_outer_where ||
            'ORDER BY time_dim.start_date';


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_custom_sql : ' || l_custom_sql );
  END IF;

  x_custom_sql  := l_custom_sql;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_custom_rec.attribute_name := ':l_currency' ;
  l_custom_rec.attribute_value:= l_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gp_currency' ;
  l_custom_rec.attribute_value:= l_gp_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gs_currency' ;
  l_custom_rec.attribute_value:= l_gs_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'END');
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;

END GET_CUST_ACQUIS_TREND_SQL;

/**********************************************************************************************
 *  PROCEDURE   : GET_CUST_ACTY_TREND_SQL 																	                  *
 *  PURPOSE     : This procedure is used to build the portlet query required                  *
 *                to render the Web Customer Activity Trend Report.                           *
 *                                                                                            *
 *	PRARAMETERS	:                                                                             *
 *					 p_param        varchar2 IN:  This is used to get the parameters                  *
 *                                         selected from the parameter portlet                *
 *					 x_custom_sql   varchar2 OUT  This is used to send the portlet query              *
 *					 x_cusom_output varchar2 OUT  This is used to send the bind variables             *
 *					                                                                                  *
**********************************************************************************************/

PROCEDURE GET_CUST_ACTY_TREND_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL)
IS
-- Generic Variables

  l_custom_sql          VARCHAR2(15000) ; --Final Sql.
  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_site                VARCHAR2(3200);  --Site Id
  l_period_type         VARCHAR2(1000);  --Period Type
  l_page                VARCHAR2(3200);  -- Page
  l_site_area           VARCHAR2(3200);  -- Site Area
  l_referral            VARCHAR2(3200); -- Referral Dimension
  l_campaign            VARCHAR2(3200);
  l_cust_class          VARCHAR2(3200); -- Customer Classification
  l_cust                VARCHAR2(3200); -- Customer
  l_prod_catg           VARCHAR2(3200); -- Product Category
  l_prod                VARCHAR2(3200); -- Product
  l_view_by             VARCHAR2(3200);
  l_site_from           VARCHAR2(3200);
  l_site_where          VARCHAR2(3200);
  l_from                VARCHAR2(3200);
  l_where               VARCHAR2(3200);
  l_outer_select        VARCHAR2(3200);
  l_outer_where         VARCHAR2(3200);

-- Specific Variables

  l_currency     VARCHAR2(3200) ; -- Currency
  l_gp_currency  VARCHAR2(15); --Global Primary Currency
  l_gs_currency  VARCHAR2(15); --Global Secondary Curr

  --FND Logging
  l_full_path   VARCHAR2(50);
  gaflog_value  VARCHAR2(10);


BEGIN

  --FND Logging
  l_full_path  := 'ibw.plsql.ibwbcusb.get_cust_acty_trend_sql';
--Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');

--Fetch all the Parameters into the Local Variables.

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'BEGIN');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;

  IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
  (
    P_PMV_PARAMETERS   =>  p_pmv_parameters,
    X_PERIOD_TYPE	     =>  l_period_type,
    X_SITE             =>  l_site,
    X_CURRENCY_CODE    =>  l_currency,
    X_SITE_AREA        =>  l_site_area,  --Not Wanted
    X_PAGE             =>  l_page,       --Not Wanted
    X_VIEW_BY          =>  l_view_by,    --Not Wanted
    X_CAMPAIGN		     =>  l_campaign,   --Not Wanted
    X_REFERRAL         =>  l_referral,   --Not Wanted
    X_PROD_CAT         =>  l_prod_catg,  --Not Wanted
    X_PROD             =>  l_prod,       --Not Wanted
    X_CUST_CLASS       =>  l_cust_class,
    X_CUST             =>  l_cust
  );

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site ||' l_cust : '|| l_cust ||' l_cust_class : '|| l_cust_class || ' l_currency : ' || l_currency || ' l_period_type : ' || l_period_type );
  END IF;

  --Initializing section starts

  l_gp_currency        := '''FII_GLOBAL1''' ;
  l_gs_currency        := '''FII_GLOBAL2''' ;
  l_where              := '';
  l_from               := '';
  l_site_where         := '';
  l_site_from          := '';
  l_custom_sql         := '';
  l_outer_select       := '';
  l_outer_where        := '';
  l_custom_rec		     :=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

--Get the Table List

  l_from   := ' IBW_VISIT_CUST_TIME_MV CUSTACQUIS_MV' ||
              ' ,FII_TIME_RPT_STRUCT_V CAL' ||
	 	          ' ,FII_PARTY_MKT_CLASS CUST_CLASS_MAP';  -- This is a mapping table between customer classification and customers ( party_id )

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_from : ' || l_from );
  END IF;

-- Initialising where clause based for time dimension

  l_where := l_where ||
					   ' cal.report_date	= dates.report_date AND
					     CUSTACQUIS_MV.time_id =	cal.time_id AND
					     CUSTACQUIS_MV.period_type_id = cal.period_type_id AND
					     bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id AND
               cal.CALENDAR_ID = -1 ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_where : ' || l_where);
  END IF;

-- Initialising where clause based on the parameter selection
-- The site where clause is kept in a seperate variable because Total Booked Orders Amount
-- and Total Booked Orders do not depend on site dimension.

  IF upper(l_site) <> 'ALL' THEN
    l_site_where    := l_site_where  ||
				                      ' AND CUSTACQUIS_MV.SITE_ID in (&SITE+SITE)' ;

  ELSE
    l_site_from     := l_site_from  || ', IBW_BI_MSITE_DIMN_V SITE';
    l_site_where    := l_site_where  ||
				                      ' AND CUSTACQUIS_MV.SITE_ID = SITE.ID ';
  END IF;

  IF upper(l_cust_class) <> 'ALL' THEN
    l_where    := l_where  ||
				                 ' AND CUSTACQUIS_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				                 ' AND CUST_CLASS_MAP.class_code in (&FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  ELSE
    l_from      := l_from || ' ,FII_TRADING_PARTNER_MKTCLASS_V CUSTCLASS';
    l_where     := l_where  ||
		                      ' AND CUSTACQUIS_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				                  ' AND CUST_CLASS_MAP.class_code = CUSTCLASS.ID ';
  END IF;

  IF upper(l_cust) <> 'ALL' THEN
    l_where    := l_where  ||
				                 ' AND CUSTACQUIS_MV.CUSTOMER_ID in (&CUSTOMER+PROSPECT)';
  ELSE
    l_from      := l_from || ' ,ASO_BI_PROSPECT_V CUST';
    l_where     := l_where  ||
				                 ' AND CUSTACQUIS_MV.CUSTOMER_ID = CUST.ID ';
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,' l_from : ' || l_from || ' l_where : ' || l_where ||' l_site_from : '|| l_site_from ||' l_site_where : '|| l_site_where);
  END IF;

-- Initialising the outer select clause

  l_outer_select  :=     ' time_dim.NAME VIEWBY,
                            NVL(VISITS,0)                              IBW_VAL1,
                            NVL(CARTS,0)                               IBW_VAL2,
                            NVL(A_LEADS,0)                             IBW_VAL3,
                            DECODE(NVL(CARTS,0)
                            ,0,null,
                            (NVL(ORDERS,0)/
                            NVL(CARTS,0))*100)                         IBW_VAL4,
                            NVL(BOOKED_ORDERS,0)                       IBW_VAL5,
                            DECODE(NVL(P_BOOKED_ORDERS_ALL,0),0,null,
                            (NVL(P_BOOKED_ORDERS,0)/
                            NVL(P_BOOKED_ORDERS_ALL,0))*100)           IBW_VAL17,  --4727078 Issue#21
                            DECODE(NVL(BOOKED_ORDERS_ALL,0),0,null,
                            (NVL(BOOKED_ORDERS,0)/
                            NVL(BOOKED_ORDERS_ALL,0))*100)             IBW_VAL6,
                            DECODE(NVL(BOOKED_ORDERS,0),0,null,
                            (NVL(ASSISTED_ORDERS,0)/
                            NVL(BOOKED_ORDERS,0))*100)                 IBW_VAL7,
                            NVL(P_BOOKED_AMOUNT,0)                     IBW_VAL18, --4727078 Issue#21
                            NVL(BOOKED_AMOUNT,0)                       IBW_VAL8,
                            NVL(BOOKED_AMOUNT_ALL,0)                   IBW_VAL9,
                            NVL(TOTAL_ORDER_INQUIRIES,0)               IBW_VAL10,
                            NVL(TOTAL_INVOICE_INQUIRIES,0)             IBW_VAL11,
                            NVL(TOTAL_PAYMENT_INQUIRIES,0)             IBW_VAL12
                            FROM  (
                              SELECT
                               start_date START_DATE,
                               SUM(VISITS) VISITS,
                               SUM(CARTS) CARTS,
                               SUM(A_LEADS) A_LEADS,
                               SUM(ORDERS) ORDERS,
                               SUM(BOOKED_ORDERS) BOOKED_ORDERS,
                               SUM(BOOKED_ORDERS_ALL) BOOKED_ORDERS_ALL,
                               SUM(ASSISTED_ORDERS) ASSISTED_ORDERS,
                               SUM(BOOKED_AMOUNT) BOOKED_AMOUNT,
                               SUM(BOOKED_AMOUNT_ALL) BOOKED_AMOUNT_ALL,
                               SUM(TOTAL_ORDER_INQUIRIES) TOTAL_ORDER_INQUIRIES,
                               SUM(TOTAL_INVOICE_INQUIRIES) TOTAL_INVOICE_INQUIRIES,
                               SUM(TOTAL_PAYMENT_INQUIRIES) TOTAL_PAYMENT_INQUIRIES,
                               SUM(P_BOOKED_AMOUNT) P_BOOKED_AMOUNT, --4727078 Issue#21
                               SUM(P_BOOKED_ORDERS) P_BOOKED_ORDERS, --4727078 Issue#21
                               SUM(P_BOOKED_ORDERS_ALL) P_BOOKED_ORDERS_ALL --4727078 Issue#21
                               ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_outer_select : ' || l_outer_select);
  END IF;

-- Initialising the outer where clause

  l_outer_where := ' time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE AND
                     time_dim.start_date = s.start_date(+) ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_outer_where : ' || l_outer_where);
  END IF;

 /*************************************************************************/
 /* IBW_VAL1                  : Visits                                    */
 /* IBE_VAL2                  : Carts                                     */
 /* IBW_VAL3                  : A Leads                                   */
 /* IBW_VAL4                  : Cart Conversion                           */
 /* IBW_VAL5                  : Booked Orders                             */
 /* IBW_VAL17                 : Prior                                     */
 /* IBW_VAL6                  : Percent Web Orders                        */
 /* IBW_VAL7                  : Assisted Orders                           */
 /* IBW_VAL18                 : Prior                                     */
 /* IBW_VAL8                  : Booked Orders Amount                      */
 /* IBW_VAL9                  : Total Booked Orders Amount                */
 /* IBW_VAL10                 : Order Status                              */
 /* IBW_VAL11                 : Invoice                                   */
 /* IBW_VAL12                 : Payment                                   */
 /*************************************************************************/
 /*                 BIS parameters used                                   */
 /*************************************************************************/
 /* &BIS_CURRENT_ASOF_DATE	           Current as of date                 */
 /* &BIS_CURRENT_REPORT_START_DATE  	 Start date based on report compare */
 /*                                    to parameter                       */
 /* &BIS_PREVIOUS_ASOF_DATE	Previous   As of date                         */
 /* &BIS_PREVIOUS_REPORT_START_DATE	   Previous start date based on report*/
 /*                                    compare to parameter               */
 /* &BIS_NESTED_PATTERN 	             Used in the bitand function to     */
 /*                                    select appropriate record_type_id  */
 /*                                    based on the period selected       */
 /*************************************************************************/
-- The inner most select clause has two UNION ALLs
-- The first UNION ALL fetches Visits,Carts,A Leads,Cart Conversion,Booked Orders,Assisted Orders,Booked Orders Amount,Order Status,Invoice,Payment
-- The second UNION ALL fetches Total Booked Orders which is used to calculate Percent Web Orders and Total Booked Orders Amount


 l_custom_sql := ' SELECT '|| l_outer_select ||
			           ' FROM  ' ||
                      '(
                       SELECT
                       dates.start_date  START_DATE,
                       decode(dates.period, ''C'',visits,0) VISITS,
                       decode(dates.period, ''C'',carts,0) CARTS,
                       decode(dates.period, ''C'',a_leads,0) A_LEADS,
                       decode(dates.period, ''C'',orders,0) ORDERS,
                       decode(dates.period, ''C'',booked_web_orders,0) BOOKED_ORDERS,
                       NULL BOOKED_ORDERS_ALL,
                       decode(dates.period, ''C'',assisted_web_orders,0) ASSISTED_ORDERS,
                       decode(dates.period, ''C'',
                       decode(:l_currency,:l_gp_currency,booked_amt_g,:l_gs_currency,booked_amt_g1,currency_cd_f,booked_amt_f),0) BOOKED_AMOUNT,
                       NULL BOOKED_AMOUNT_ALL,
                       decode(dates.period, ''C'',total_order_inquiries,0) TOTAL_ORDER_INQUIRIES,
                       decode(dates.period, ''C'',total_invoice_inquiries,0) TOTAL_INVOICE_INQUIRIES,
                       decode(dates.period, ''C'',total_payment_inquiries,0) TOTAL_PAYMENT_INQUIRIES ,
                       decode(dates.period, ''P'',
                       decode(:l_currency,:l_gp_currency,booked_amt_g,:l_gs_currency,booked_amt_g1,currency_cd_f,booked_amt_f),0) P_BOOKED_AMOUNT, --4727078 Issue#21
                       decode(dates.period, ''P'',booked_web_orders,0) P_BOOKED_ORDERS,  --4727078 Issue#21
                       NULL P_BOOKED_ORDERS_ALL --4727078 Issue#21
                       FROM
                        (
                         SELECT
                         time_dim.start_date START_DATE,
                         ''C'' PERIOD,
                         least(time_dim.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
                         FROM '||l_period_type||'   time_dim
                         WHERE time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
                          UNION ALL
            SELECT
              p2.start_date START_DATE,
              ''P'' PERIOD,
              p1.report_date REPORT_DATE
            FROM
              (
                SELECT
                  REPORT_DATE,
                  rownum id
                FROM
                (
                SELECT
                  least(time_dim.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
                FROM
                  ' ||l_period_type||'   time_dim
                WHERE
                  time_dim.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
                ORDER BY time_dim.start_date DESC
                )
              )  p1,
              (
              SELECT
                START_DATE,
                rownum id
              FROM
              (
                SELECT time_dim.start_date START_DATE
                FROM  ' ||l_period_type||'  time_dim
                WHERE time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
                ORDER BY time_dim.start_date DESC
                )
              ) p2
                        WHERE p1.id(+) = p2.id) dates, '||l_from || l_site_from ||'
                        WHERE ' || l_where	|| l_site_where ||
                ' UNION ALL
                  SELECT
                       dates.start_date  START_DATE,
                       NULL VISITS,
                       NULL CARTS,
                       NULL A_LEADS,
                       NULL ORDERS,
                       NULL BOOKED_ORDERS,
                       decode(dates.period, ''C'',total_booked_orders,0) BOOKED_ORDERS_ALL,
                       NULL ASSISTED_ORDERS,
                       NULL BOOKED_AMOUNT,
                       decode(dates.period, ''C'',
                       decode(:l_currency,:l_gp_currency,total_booked_amt_g,:l_gs_currency,total_booked_amt_g1,currency_cd_f,total_booked_amt_f),0) BOOKED_AMOUNT_ALL,
                       NULL TOTAL_ORDER_INQUIRIES,
                       NULL TOTAL_INVOICE_INQUIRIES,
                       NULL TOTAL_PAYMENT_INQUIRIES,
                       NULL P_BOOKED_AMOUNT, --4727078 Issue#21
                       NULL P_BOOKED_ORDERS, --4727078 Issue#21
                       decode(dates.period, ''P'',total_booked_orders,0) P_BOOKED_ORDERS_ALL --4727078 Issue#21
                       FROM
                        (
                         SELECT
                         time_dim.start_date START_DATE,
                         ''C'' PERIOD,
                         least(time_dim.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
                         FROM '||l_period_type||'   time_dim
                         WHERE time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
                          UNION ALL
            SELECT
              p2.start_date START_DATE,
              ''P'' PERIOD,
              p1.report_date REPORT_DATE
            FROM
              (
                SELECT
                  REPORT_DATE,
                  rownum id
                FROM
                (
                SELECT
                  least(time_dim.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
                FROM
                  ' ||l_period_type||'   time_dim
                WHERE
                  time_dim.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
                ORDER BY time_dim.start_date DESC
                )
              )  p1,
              (
              SELECT
                START_DATE,
                rownum id
              FROM
              (
                SELECT time_dim.start_date START_DATE
                FROM  ' ||l_period_type||'  time_dim
                WHERE time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
                ORDER BY time_dim.start_date DESC
                )
              ) p2
                        WHERE p1.id(+) = p2.id) dates, '|| l_from ||'
                        WHERE	 '|| l_where  ||
                        ' AND CUSTACQUIS_MV.site_id = -9999 )
                GROUP BY start_date
                ) s,'|| l_period_type||' time_dim
            WHERE '|| l_outer_where ||
            'ORDER BY time_dim.start_date';


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_custom_sql : ' || l_custom_sql );
  END IF;

  x_custom_sql  := l_custom_sql;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_custom_rec.attribute_name := ':l_currency' ;
  l_custom_rec.attribute_value:= l_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gp_currency' ;
  l_custom_rec.attribute_value:= l_gp_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gs_currency' ;
  l_custom_rec.attribute_value:= l_gs_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'END');
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;

END GET_CUST_ACTY_TREND_SQL;

/**********************************************************************************************
 *  PROCEDURE   : GET_CUST_ACTY_SQL 																	                        *
 *  PURPOSE     : This procedure is used to build the portlet query required                  *
 *                to render the Web Customer Activity Report.                                 *
 *                                                                                            *
 *	PRARAMETERS	:                                                                             *
 *					 p_param        varchar2 IN:  This is used to get the parameters                  *
 *                                         selected from the parameter portlet                *
 *					 x_custom_sql   varchar2 OUT  This is used to send the portlet query              *
 *					 x_cusom_output varchar2 OUT  This is used to send the bind variables             *
 *					                                                                                  *
**********************************************************************************************/

PROCEDURE GET_CUST_ACTY_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL)
IS
-- Generic Variables

  l_custom_sql          VARCHAR2(15000) ; --Final Sql.
  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_site                VARCHAR2(3200);  --Site Id
  l_period_type         VARCHAR2(1000);  --Period Type
  l_page                VARCHAR2(3200);  -- Page
  l_site_area           VARCHAR2(3200);  -- Site Area
  l_referral            VARCHAR2(3200); -- Referral Dimension
  l_campaign            VARCHAR2(3200);
  l_cust_class          VARCHAR2(3200); -- Customer Classification
  l_cust                VARCHAR2(3200); -- Customer
  l_prod_catg           VARCHAR2(3200); -- Product Category
  l_prod                VARCHAR2(3200); -- Product
  l_view_by             VARCHAR2(3200);
  l_site_from           VARCHAR2(3200);
  l_site_where          VARCHAR2(3200);
  l_from                VARCHAR2(3200);
  l_where               VARCHAR2(3200);
  l_outer_select        VARCHAR2(32000);
  l_inner_select        VARCHAR2(3200);
  l_inner_select_all    VARCHAR2(3200);
  l_inner_group_by      VARCHAR2(3200);
  l_from_all            VARCHAR2(3200);
  l_where_all           VARCHAR2(3200);
  l_middle_select       VARCHAR2(3200);
  l_middle_group_by     VARCHAR2(3200);
  l_having              VARCHAR2(3200);

-- Specific Variables

  l_currency     VARCHAR2(3200) ; -- Currency
  l_gp_currency  VARCHAR2(15); --Global Primary Currency
  l_gs_currency  VARCHAR2(15); --Global Secondary Curr

  --FND Logging
  l_full_path   VARCHAR2(50);
  gaflog_value  VARCHAR2(10);


BEGIN

  --FND Logging
  l_full_path  := 'ibw.plsql.ibwbcusb.get_cust_acty_sql';
--Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');

--Fetch all the Parameters into the Local Variables.

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'BEGIN');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;

  IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
  (
    P_PMV_PARAMETERS   =>  p_pmv_parameters,
    X_PERIOD_TYPE	     =>  l_period_type,
    X_SITE             =>  l_site,
    X_CURRENCY_CODE    =>  l_currency,
    X_SITE_AREA        =>  l_site_area,  --Not Wanted
    X_PAGE             =>  l_page,       --Not Wanted
    X_VIEW_BY          =>  l_view_by,    --Not Wanted
    X_CAMPAIGN		     =>  l_campaign,   --Not Wanted
    X_REFERRAL         =>  l_referral,   --Not Wanted
    X_PROD_CAT         =>  l_prod_catg,  --Not Wanted
    X_PROD             =>  l_prod,       --Not Wanted
    X_CUST_CLASS       =>  l_cust_class,
    X_CUST             =>  l_cust
  );

    IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site ||' l_cust : '|| l_cust ||' l_cust_class : '|| l_cust_class || ' l_currency : ' || l_currency || ' l_view_by : ' || l_view_by );
  END IF;

  --Initializing section starts

  l_gp_currency        := '''FII_GLOBAL1''' ;
  l_gs_currency        := '''FII_GLOBAL2''' ;
  l_site_from           := '';
  l_site_where          := '';
  l_from                := '';
  l_where               := '';
  l_outer_select        := '';
  l_inner_select        := '';
  l_inner_select_all    := '';
  l_inner_group_by      := '';
  l_from_all            := '';
  l_where_all           := '';
  l_middle_select       := '';
  l_middle_group_by     := '';
  l_having              := '';
  l_custom_rec		     :=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;


--Get the Table List

  l_from   := ' IBW_VISIT_CUST_TIME_MV CUSTACTY_MV' ||
              ' ,FII_TIME_RPT_STRUCT_V CAL' ||
	 	          ' ,FII_PARTY_MKT_CLASS CUST_CLASS_MAP';  -- This is a mapping table between customer classification and customers ( party_id )

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_from : ' || l_from );
  END IF;

-- Initialising where clause based for time dimension

  l_where         := ' CAL.report_date = &BIS_CURRENT_ASOF_DATE ' ||
                     ' AND CAL.period_type_id = CUSTACTY_MV.period_type_id ' ||
                     ' AND BITAND(CAL.RECORD_TYPE_ID,&BIS_NESTED_PATTERN)= CAL.RECORD_TYPE_ID '||
                     ' AND CUSTACTY_MV.TIME_ID = CAL.TIME_ID ' ||
                     ' AND CAL.CALENDAR_ID = -1 ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_where : ' || l_where );
  END IF;

  l_where_all     := l_where;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_where_all : ' || l_where_all );
  END IF;

  --The Outer Select statement is recorded in this variable.
  -- IBW_G_TOT9 : Grand total for Total Web Orders Amount is non additive across site
  -- and additive across customer classification and customer. So when view by is site
  -- sum Over()is not done and for other view bys sum over() is done

  l_outer_select  :=  ' VIEW_BY                                       VIEWBY,
                        VIEW_BY_ID                                    VIEWBYID,
                        NVL(VISITS,0)                                 IBW_VAL1,
                        NVL(CARTS,0)                                  IBW_VAL2,
                        NVL(A_LEADS,0)                                IBW_VAL3,
                        DECODE(NVL(CARTS,0)
                        ,0,null,
                        (NVL(ORDERS,0)/
                        NVL(CARTS,0))*100)                            IBW_VAL4,
                        NVL(BOOKED_ORDERS,0)                          IBW_VAL5,
                        DECODE(NVL(BOOKED_ORDERS_ALL,0),0,null,
                        (NVL(BOOKED_ORDERS,0)/
                        NVL(BOOKED_ORDERS_ALL,0))*100)                IBW_VAL6,
                        DECODE(NVL(BOOKED_ORDERS,0),0,null,
                        (NVL(ASSISTED_ORDERS,0)/
                        NVL(BOOKED_ORDERS,0))*100)                    IBW_VAL7,
                        NVL(BOOKED_AMOUNT,0)                          IBW_VAL8,
                        NVL(BOOKED_AMOUNT_ALL,0)                      IBW_VAL9,
                        NVL(TOTAL_ORDER_INQUIRIES,0)                  IBW_VAL10,
                        NVL(TOTAL_INVOICE_INQUIRIES,0)                IBW_VAL11,
                        NVL(TOTAL_PAYMENT_INQUIRIES,0)                IBW_VAL12,
                        SUM(NVL(VISITS,0)) over ()                    IBW_G_TOT1,
                        SUM(NVL(CARTS,0)) over ()                     IBW_G_TOT2,
                        SUM(NVL(A_LEADS,0)) over ()                   IBW_G_TOT3,
                        DECODE(SUM(NVL(CARTS,0)) over(),0,null,
                        (SUM(NVL(ORDERS,0)) over()/
                        SUM(NVL(CARTS,0)) over())*100)                IBW_G_TOT4,
                        SUM(NVL(BOOKED_ORDERS,0)) over ()             IBW_G_TOT5,
                        DECODE(DECODE('''|| l_view_by ||''',''SITE+SITE'',
                        NVL(BOOKED_ORDERS_ALL,0),
                        SUM(NVL(BOOKED_ORDERS_ALL,0)) over ())
                        ,0,null,
                        (SUM(NVL(BOOKED_ORDERS,0)) over()/
                        DECODE('''|| l_view_by ||''',''SITE+SITE'',
                        NVL(BOOKED_ORDERS_ALL,0),
                        SUM(NVL(BOOKED_ORDERS_ALL,0)) over ()))*100)  IBW_G_TOT6,  -- Changed grandtotal so that BOOKED_ORDERS_ALL is not summed up when view by is Site
                        DECODE(SUM(NVL(BOOKED_ORDERS,0)) over()
                        ,0,null,
                        (SUM(NVL(ASSISTED_ORDERS,0)) over()/
                        SUM(NVL(BOOKED_ORDERS,0)) over())*100)        IBW_G_TOT7,
                        SUM(NVL(BOOKED_AMOUNT,0)) over ()             IBW_G_TOT8,
                        DECODE('''|| l_view_by ||''',''SITE+SITE'',
                        NVL(BOOKED_AMOUNT_ALL,0),
                        SUM(NVL(BOOKED_AMOUNT_ALL,0)) over ())        IBW_G_TOT9,
                        SUM(NVL(TOTAL_ORDER_INQUIRIES,0)) over ()     IBW_G_TOT10,
                        SUM(NVL(TOTAL_INVOICE_INQUIRIES,0)) over ()   IBW_G_TOT11,
                        SUM(NVL(TOTAL_PAYMENT_INQUIRIES,0)) over ()   IBW_G_TOT12 ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_outer_select : ' || l_outer_select );
  END IF;

  --The middle Select statement is recorded in this variable.

  l_middle_select    := ' VIEW_BY VIEW_BY,
                          VIEW_BY_ID VIEW_BY_ID,
                           SUM(VISITS) VISITS,
                           SUM(CARTS) CARTS,
                           SUM(A_LEADS) A_LEADS,
                           SUM(ORDERS) ORDERS,
                           SUM(BOOKED_ORDERS) BOOKED_ORDERS,
                           SUM(BOOKED_ORDERS_ALL) BOOKED_ORDERS_ALL,
                           SUM(ASSISTED_ORDERS) ASSISTED_ORDERS,
                           SUM(BOOKED_AMOUNT) BOOKED_AMOUNT,
                           SUM(BOOKED_AMOUNT_ALL) BOOKED_AMOUNT_ALL,
                           SUM(TOTAL_ORDER_INQUIRIES) TOTAL_ORDER_INQUIRIES,
                           SUM(TOTAL_INVOICE_INQUIRIES) TOTAL_INVOICE_INQUIRIES,
                           SUM(TOTAL_PAYMENT_INQUIRIES) TOTAL_PAYMENT_INQUIRIES ';

  -- If all the columns in a row are 0 then the whole row is discarded

  l_having           :=  ' NVL(SUM(VISITS),0) > 0
                           OR NVL(SUM(CARTS),0) > 0
                           OR NVL(SUM(A_LEADS),0) > 0
                           OR NVL(SUM(ORDERS),0) > 0
                           OR NVL(SUM(BOOKED_ORDERS),0) > 0
                           OR NVL(SUM(BOOKED_ORDERS_ALL),0) > 0
                           OR NVL(SUM(ASSISTED_ORDERS),0) > 0
                           OR NVL(SUM(BOOKED_AMOUNT),0) > 0
                           OR NVL(SUM(BOOKED_AMOUNT_ALL),0) > 0
                           OR NVL(SUM(TOTAL_ORDER_INQUIRIES),0) > 0
                           OR NVL(SUM(TOTAL_INVOICE_INQUIRIES),0) > 0
                           OR NVL(SUM(TOTAL_PAYMENT_INQUIRIES),0) > 0 ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_middle_select : ' || l_middle_select );
  END IF;

--The Inner Select statement is recorded in this variable.
-- The select clause fetches Visits,Carts,A Leads,Cart Conversion,Booked Orders,Assisted Orders,Booked Orders Amount,Order Status,Invoice,Payment
  l_inner_select     :=  ' SUM(VISITS) VISITS,
                           SUM(CARTS) CARTS,
                           SUM(A_LEADS) A_LEADS,
                           SUM(ORDERS) ORDERS,
                           SUM(BOOKED_WEB_ORDERS) BOOKED_ORDERS,
                           NULL BOOKED_ORDERS_ALL,
                           SUM(ASSISTED_WEB_ORDERS) ASSISTED_ORDERS,
                           SUM(decode(:l_currency,:l_gp_currency,booked_amt_g,:l_gs_currency,booked_amt_g1,currency_cd_f,booked_amt_f)) BOOKED_AMOUNT,
                           NULL BOOKED_AMOUNT_ALL,
                           SUM(TOTAL_ORDER_INQUIRIES) TOTAL_ORDER_INQUIRIES,
                           SUM(TOTAL_INVOICE_INQUIRIES) TOTAL_INVOICE_INQUIRIES,
                           SUM(TOTAL_PAYMENT_INQUIRIES) TOTAL_PAYMENT_INQUIRIES ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_inner_select : ' || l_inner_select );
  END IF;



-- The select clause fetches Total Booked Orders which is used to calculate Percent Web Orders and Total Booked Orders Amount

  l_inner_select_all :=  ' NULL VISITS,
                           NULL CARTS,
                           NULL A_LEADS,
                           NULL ORDERS,
                           NULL BOOKED_ORDERS,
                           SUM(TOTAL_BOOKED_ORDERS) BOOKED_ORDERS_ALL,
                           NULL ASSISTED_ORDERS,
                           NULL BOOKED_AMOUNT,
                           SUM(decode(:l_currency,:l_gp_currency,total_booked_amt_g,:l_gs_currency,total_booked_amt_g1,currency_cd_f,total_booked_amt_f)) BOOKED_AMOUNT_ALL,
                           NULL TOTAL_ORDER_INQUIRIES,
                           NULL TOTAL_INVOICE_INQUIRIES,
                           NULL TOTAL_PAYMENT_INQUIRIES ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_inner_select_all : ' || l_inner_select_all );
  END IF;

-- Initialising where clause based on the view by parameter
-- Since these two measures Total Booked Orders Amount,Total Booked Orders are not dependent on site dimension
-- the following algorithm is followed for the second union all in the inner nost select clause
-- View by Customer Classification or Customer and sites = 'All'
    -- Join with Customer Classification / Customer dimensions but not with Site dimension
    -- Where Clause has : MV.site_id = -9999 which indicates records in the MV that hold datathat are independent of site
-- View by Customer Classification / Customer and specific site is selected
    -- Join with Customer Classification and Customer dimensions but not with Site dimension
    -- Where Clause has : MV.site_id = -9999 which indicates records in the MV that hold datathat are independent of site
-- View by Site and sites = 'All'
    -- Join with Site dimension
    -- Where Clause has : MV.site_id = -9999 which indicates records in the MV that hold datathat are independent of site
-- View by Site and specific site is selected
    -- Join with Site dimension
    -- Where Clause has : MV.site_id = -9999 which indicates records in the MV that hold datathat are independent of site
    --  and Site_Dimension.site_id = (<<selected sites>>)

  l_where_all       := l_where_all || ' AND CUSTACTY_MV.SITE_ID = -9999';

  IF l_view_by = 'SITE+SITE' THEN --View by is Site

    l_inner_select    := ' SITE.VALUE VIEW_BY,SITE.ID VIEW_BY_ID, ' || l_inner_select;
    l_inner_select_all:= ' SITE.VALUE VIEW_BY,SITE.ID VIEW_BY_ID, ' || l_inner_select_all;
    l_from            := l_from  || ' ,IBW_BI_MSITE_DIMN_V SITE ';
    l_where           := l_where || ' AND CUSTACTY_MV.SITE_ID = SITE.ID ';
    l_inner_group_by  := l_inner_group_by || ' SITE.VALUE,SITE.ID ';

  ELSIF l_view_by ='FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN --View by is Customer Classification

    l_inner_select    := ' CUSTCLASS.VALUE VIEW_BY,CUSTCLASS.ID VIEW_BY_ID, ' || l_inner_select;
    l_inner_select_all:= ' CUSTCLASS.VALUE VIEW_BY,CUSTCLASS.ID VIEW_BY_ID, ' || l_inner_select_all;

    l_from            := l_from  || ' ,FII_TRADING_PARTNER_MKTCLASS_V CUSTCLASS ';
    l_where           := l_where || ' AND CUSTACTY_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				                            ' AND CUST_CLASS_MAP.class_code = CUSTCLASS.ID ';
    l_where_all       := l_where_all || ' AND CUSTACTY_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				                                ' AND CUST_CLASS_MAP.class_code = CUSTCLASS.ID ';
    l_inner_group_by  := l_inner_group_by || ' CUSTCLASS.VALUE,CUSTCLASS.ID ';

  ELSIF l_view_by ='CUSTOMER+PROSPECT' THEN --View by is Customer

    l_inner_select    := ' CUST.VALUE VIEW_BY,CUST.ID VIEW_BY_ID, ' || l_inner_select;
    l_inner_select_all:= ' CUST.VALUE VIEW_BY,CUST.ID VIEW_BY_ID, ' || l_inner_select_all;

    l_from            := l_from  || ' ,ASO_BI_PROSPECT_V CUST ';
    l_where           := l_where || ' AND CUSTACTY_MV.CUSTOMER_ID = CUST.ID ';
    l_where_all       := l_where_all || ' AND CUSTACTY_MV.CUSTOMER_ID = CUST.ID ';
    l_inner_group_by  := l_inner_group_by || ' CUST.VALUE,CUST.ID ';

  END IF; --End if for l_view_by

  l_from_all         := l_from_all || l_from;

-- Initialising where clause based on the parameter selection in dimensions

  IF upper(l_site) <> 'ALL' THEN
    IF l_view_by = 'SITE+SITE' THEN
      l_where_all := l_where_all || ' AND SITE.ID in (&SITE+SITE)';
    END IF;
    l_where    := l_where  || ' AND CUSTACTY_MV.SITE_ID in (&SITE+SITE)' ;
  ELSE
    IF l_view_by <> 'SITE+SITE' THEN
      l_from            := l_from  || ' ,IBW_BI_MSITE_DIMN_V SITE ';
      l_where           := l_where || ' AND CUSTACTY_MV.SITE_ID = SITE.ID ';
    END IF;
  END IF;

  IF upper(l_cust_class) <> 'ALL' THEN
    l_where    := l_where  ||
				                 ' AND CUSTACTY_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
 				                 ' AND CUST_CLASS_MAP.class_code in (&FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
    l_where_all:= l_where_all  ||
				                 ' AND CUSTACTY_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
 				                 ' AND CUST_CLASS_MAP.class_code in (&FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  ELSE
    IF l_view_by <> 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN --View by is Customer Classification
      l_from            := l_from  || ' ,FII_TRADING_PARTNER_MKTCLASS_V CUSTCLASS ';
      l_where           := l_where || ' AND CUSTACTY_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				                            ' AND CUST_CLASS_MAP.class_code = CUSTCLASS.ID ';
      l_from_all        := l_from_all  || ' ,FII_TRADING_PARTNER_MKTCLASS_V CUSTCLASS ';
      l_where_all       := l_where_all || ' AND CUSTACTY_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				                            ' AND CUST_CLASS_MAP.class_code = CUSTCLASS.ID ';
    END IF;
  END IF;

  IF upper(l_cust) <> 'ALL' THEN
    l_where    := l_where  ||
				                 ' AND CUSTACTY_MV.CUSTOMER_ID in (&CUSTOMER+PROSPECT)';
    l_where_all := l_where_all  ||
				                 ' AND CUSTACTY_MV.CUSTOMER_ID in (&CUSTOMER+PROSPECT)';
  ELSE
    IF l_view_by <> 'CUSTOMER+PROSPECT' THEN --View by is Customer
      l_from            := l_from  || ' ,ASO_BI_PROSPECT_V CUST ';
      l_where           := l_where || ' AND CUSTACTY_MV.CUSTOMER_ID = CUST.ID ';
      l_from_all        := l_from_all  || ' ,ASO_BI_PROSPECT_V CUST ';
      l_where_all       := l_where_all || ' AND CUSTACTY_MV.CUSTOMER_ID = CUST.ID ';
    END IF;
  END IF;

  l_middle_group_by := ' VIEW_BY,VIEW_BY_ID ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_inner_select : ' || l_inner_select ||
   'l_inner_select_all : ' || l_inner_select_all || 'l_from : ' || l_from || 'l_where : ' ||
   l_where || 'l_from_all : ' || l_from_all || 'l_where_all : ' || l_where_all || 'l_inner_group_by : '
   || l_inner_select_all || 'l_middle_group_by : ' || l_middle_group_by );
  END IF;

 /*************************************************************************/
 /* IBW_VAL1                  : Visits                                    */
 /* IBE_VAL2                  : Carts                                     */
 /* IBW_VAL3                  : A Leads                                   */
 /* IBW_VAL4                  : Cart Conversion                           */
 /* IBW_VAL5                  : Booked Orders                             */
 /* IBW_VAL6                  : Percent Web Orders                        */
 /* IBW_VAL7                  : Assisted Orders                           */
 /* IBW_VAL8                  : Booked Orders Amount                      */
 /* IBW_VAL9                  : Total Booked Orders Amount                */
 /* IBW_VAL10                 : Order Status                              */
 /* IBW_VAL11                 : Invoice                                   */
 /* IBW_VAL12                 : Payment                                   */
 /*************************************************************************/
 /*                 BIS parameters used                                   */
 /*************************************************************************/
 /* &BIS_CURRENT_ASOF_DATE	           Current as of date                 */
 /* &BIS_NESTED_PATTERN 	             Used in the bitand function to     */
 /*                                    select appropriate record_type_id  */
 /*                                    based on the period selected       */
 /*************************************************************************/


  l_custom_sql := 'SELECT ' || l_outer_select ||
                  ' FROM ' ||
                    ' (SELECT ' || l_middle_select ||
                    ' FROM ' ||
                      ' (SELECT '  || l_inner_select ||
                      ' FROM '     || l_from ||
                      ' WHERE '    || l_where ||
                      ' GROUP BY ' || l_inner_group_by ||
                      ' UNION ALL ' ||
                      ' SELECT '   || l_inner_select_all ||
                      ' FROM '     || l_from_all ||
                      ' WHERE '    || l_where_all ||
                      ' GROUP BY ' || l_inner_group_by ||
                      ' ) ' ||
                    ' GROUP BY ' || l_middle_group_by ||
                    ' HAVING '   || l_having ||
                  ' ) ' ||
                  ' &ORDER_BY_CLAUSE ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_custom_sql : ' || l_custom_sql );
  END IF;

  x_custom_sql  := l_custom_sql;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_custom_rec.attribute_name := ':l_currency' ;
  l_custom_rec.attribute_value:= l_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gp_currency' ;
  l_custom_rec.attribute_value:= l_gp_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gs_currency' ;
  l_custom_rec.attribute_value:= l_gs_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'END');
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;

END GET_CUST_ACTY_SQL;

END IBW_BI_CUSTOMER_PVT;

/
