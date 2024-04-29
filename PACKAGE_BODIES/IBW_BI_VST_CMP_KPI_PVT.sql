--------------------------------------------------------
--  DDL for Package Body IBW_BI_VST_CMP_KPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_BI_VST_CMP_KPI_PVT" AS
/* $Header: ibwbvckb.pls 120.19 2006/06/26 08:55:56 gjothiku noship $ */
-- Procedure for the Visitor Conversion Report

/*
----------------------------------------------------------------------------
Procedure name       : GET_VISTR_CONV_TRND_SQL
Parameters
IN                   : p_param        pl/sql table
OUT                  : x_custom_sql   varchar2
OUT                  : x_cusom_output pl/sql table

Description          : This procedure will be called from
                       the 'Web Analytics Visitor Conversion Trend portlet'
------------------------------------------------------------------------------
*/

PROCEDURE GET_VISTR_CONV_TRND_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL )
IS
-- Generic Variables

  l_custom_sql              VARCHAR2(15000) ; --Final Sql.
  l_asof_dt                 DATE;             --As of Date
  l_site                    VARCHAR2(3200) ;  --Site Id
  l_period_type             VARCHAR2(1000) ;  --Period Type
  l_parameter_name          VARCHAR2(3200) ;  --Parameter Name
  l_page                    VARCHAR2(3200) ;  -- Page  Not required for this report
  l_site_area               VARCHAR2(3200) ;  -- Site Area  Not required for this report
  l_view_by                 VARCHAR2(3200);   -- View By   Not required for this report
  l_rec_id                  NUMBER;
  l_table_list              VARCHAR2(3200) ;
  l_outer_where_clause      VARCHAR2(3200) ;
  l_custom_rec              BIS_QUERY_ATTRIBUTES;
  l_dimension_id            NUMBER;
  l_dimension_view          VARCHAR2(3200) ;
  l_dim_where               VARCHAR2(3200);
  l_group_by                VARCHAR2(1000);
  l_order_by                VARCHAR2(100);
  l_referral                VARCHAR2(3200) ;  -- Referral Dimension  Not required for this report
  l_campaign                VARCHAR2(3200) ;  --  Not required for this report


-- Specific for trend reports

  l_timetable        VARCHAR2(3200);
  l_timespan         NUMBER;
  l_sequence         NUMBER;
  l_cur_start        DATE;
  l_mid_start        DATE;
  l_prev_start       DATE;
  l_pprev_start      DATE;
  l_pcur_start       DATE;
  l_cur_year         NUMBER;
  l_prev_year        NUMBER;

-- Specific Variables

  l_cust_class   VARCHAR2(3200) ;   -- Customer Classification
  l_cust         VARCHAR2(3200) ;   -- Customer  Not required for this report
  l_currency     VARCHAR2(50) ;   -- Currency
  l_comp_to      VARCHAR2(50) ;   -- Compare To
  l_prev_date    DATE;            -- Previous Date
  l_prod_catg    VARCHAR2(50) ;   -- Product Category  Not required for this report
  l_prod         VARCHAR2(50) ;   -- Product  Not required for this report
  l_gp_currency  VARCHAR2(15) ;   -- Global Primary Currency
  l_gs_currency  VARCHAR2(15) ;   -- Global Secondary Curr
  l_f_currency   VARCHAR2(15) ;   -- Functional Currency
  l_gp_amount    NUMBER ;         -- Primary Currency Amount
  l_gs_amount    NUMBER ;         -- Secondary Currency Amount
  l_f_amount     NUMBER ;         -- Functional Amount


  --FND Logging
  l_full_path     VARCHAR2(50) ;
  --gaflog_value    CONSTANT VARCHAR2(10) ;
  gaflog_value     CONSTANT VARCHAR2(10) := fnd_profile.value('AFLOG_ENABLED');
  --Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level

BEGIN

 --gaflog_value   := fnd_profile.value('AFLOG_ENABLED');

 IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'Visitor Conversion Trend Report BEGIN');
  END IF;


-- initilization

  l_gp_currency   := '''FII_GLOBAL1''' ; --Global Primary Currency
  l_gs_currency   := '''FII_GLOBAL2''' ; --Global Secondary Curr

  l_full_path    := 'ibw.plsql.ibwbvcob.get_visitor_conv_trend_sql';
  --gaflog_value   := fnd_profile.value('AFLOG_ENABLED');

--Fetch all the Parameters into the Local Variables.


  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package to get parameter values');
  END IF;

 IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
   (
     P_PMV_PARAMETERS   =>  p_pmv_parameters,
     X_PERIOD_TYPE	    =>  l_period_type,
     X_SITE             =>  l_site,
     X_CURRENCY_CODE    =>  l_currency,   --Not Wanted
     X_SITE_AREA        =>  l_site_area,  --Not Wanted
     X_PAGE             =>  l_page,       --Not Wanted
     X_REFERRAL         =>  l_referral,   --Not Wanted
     X_PROD_CAT         =>  l_prod_catg,  --Not Wanted
     X_PROD             =>  l_prod,       --Not Wanted
     X_CUST_CLASS       =>  l_cust_class,
     X_CUST             =>  l_cust,        --Not Wanted
     X_CAMPAIGN		      =>  l_campaign,   --Not Wanted
     X_VIEW_BY          =>  l_view_by     --Not Wanted
    );

 IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
 END IF;

 IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site || ' l_cust_class : ' || l_cust_class );
 END IF;


  --Initializing section starts

  l_outer_where_clause  := '';
  l_custom_rec		:=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  --Initializing section completed

  --Get the Table List

  l_table_list   := ' IBW_VISIT_CUST_TIME_MV VISIT_MV' ||  --  To be replaced by the mv when it is ready
                    ' ,FII_TIME_RPT_STRUCT_V CAL' ||
	 	    ' ,FII_PARTY_MKT_CLASS CUST_CLASS_MAP';




-- Initialising where clause based on the parameter selection

  IF upper(l_site) <> 'ALL' THEN
    l_outer_where_clause   := l_outer_where_clause ||
				' AND VISIT_MV.SITE_ID in (&SITE+SITE)' ;

  ELSE
    l_table_list := l_table_list  || ', IBW_BI_MSITE_DIMN_V SITE ';
    l_outer_where_clause   := l_outer_where_clause ||
				' AND VISIT_MV.SITE_ID = SITE.ID ';
  END IF;

  IF upper(l_cust_class) <> 'ALL' THEN

    l_outer_where_clause   := l_outer_where_clause ||
				' AND VISIT_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				' AND CUST_CLASS_MAP.class_code in (&FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  ELSE
    l_table_list      := l_table_list || ' ,FII_TRADING_PARTNER_MKTCLASS_V CUSTCLASS';
    l_outer_where_clause    := l_outer_where_clause ||
				' AND VISIT_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				' AND CUST_CLASS_MAP.class_code = CUSTCLASS.ID ';
  END IF;



 /*********************************************************************************/
 /* Metrics used in Visit Trend Report:                                           */
 /* IBW_VAL1                  : Visits                                            */
 /* IBE_VAL2                  : Anonymous Carts				                            */
 /* IBW_VAL3                  : Registrations                                     */
 /* IBW_VAL4                  : Registered Carts                                  */
 /* IBW_VAL5                  : 'A' Leads                                         */
 /* IBW_VAL6                  : Cart Conversion                                   */
 /* IBW_VAL7                  : Booked Orders                                     */
 /* IBW_VAL8                  : Repeat Orders                                     */
 /* IBW_VAL9                  : Browse to Buy                                     */
 /* IBW_VAL10                 : Booked Orders Amount                              */
  /*********************Bind Parameters used are***********************************/
 /*                                                                               */
 /* &BIS_CURRENT_ASOF_DATE          :  AS OF DATE selected in the report          */
 /* &BIS_PREVIOUS_ASOF_DATE         : Previous period as of date                  */
 /* &BIS_CURRENT_REPORT_START_DATE  : Current period start date                   */
 /* &BIS_PREVIOUS_REPORT_START_DATE : Previous period startdate                   */
 /* &BIS_NESTED_PATTERN             :  Record Type Id of the Period Type selected */
 /*********************************************************************************/




   l_custom_sql:= 'SELECT  fii.NAME VIEWBY,
	                   nvl(VISITS_CUR,0)                                                      IBW_VAL1,
                     nvl(ANONYMOUS_CARTS_CUR,0)                                             IBW_VAL2,
                     nvl(WEB_REGISTRATIONS_CUR,0)                                           IBW_VAL3,
                     (nvl(CARTS_CUR,0) - nvl(ANONYMOUS_CARTS_CUR,0))                        IBW_VAL4,
                     nvl(A_LEADS_CUR,0)                                                     IBW_VAL5,
                     decode(nvl(CARTS_CUR,0),0
                             ,null -- 0
                             ,(nvl(ORDERS_CUR,0)/nvl(CARTS_CUR,0))*100)                     IBW_VAL6,    --Changed by AANNAMAL to Consider Total Carts instead of Registered Carts
                     nvl(TOTAL_BOOKED_ORDERS_CUR,0)                                         IBW_VAL7,
                     nvl(REPEAT_WEB_ORDERS_CUR,0)                                           IBW_VAL8,
                     decode(nvl(VISITS_CUR,0),0,null,(ORDERS_SITE_VISITS_CUR/VISITS_CUR)*100)  IBW_VAL9,    -- Returned null instead of 0 for bug 5253591
                     nvl(BOOKED_AMOUNT_CUR,0)                                               IBW_VAL10
	     FROM (        SELECT START_DATE,
			   sum(nvl(visits_c,0)) VISITS_CUR,
			   sum(nvl(visits_p,0)) VISITS_PRE,
			   sum(nvl(anonymous_carts_c,0)) ANONYMOUS_CARTS_CUR,
			   sum(nvl(web_registrations_c,0)) WEB_REGISTRATIONS_CUR,
			   sum(nvl(carts_c,0)) CARTS_CUR,
			   sum(nvl(a_leads_c,0)) A_LEADS_CUR,
			   sum(nvl(orders_c,0)) ORDERS_CUR,
			   sum(nvl(total_booked_orders_C,0)) TOTAL_BOOKED_ORDERS_CUR,
			   sum(nvl(repeat_web_orders_C,0)) REPEAT_WEB_ORDERS_CUR,
			   sum(nvl(orders_site_visits_C,0)) ORDERS_SITE_VISITS_CUR,
			   sum(nvl(booked_amount_c,0)) BOOKED_AMOUNT_CUR
		       FROM (SELECT
			     dates.start_date  START_DATE,
			     decode(dates.period, ''C'',visits,0) visits_C,
			     decode(dates.period, ''P'',visits,0) visits_P,
			     decode(dates.period, ''C'',anonymous_carts,0) anonymous_carts_C,
			     decode(dates.period, ''C'',web_registrations,0) web_registrations_C,
			     decode(dates.period, ''C'',carts,0) carts_C,
			     decode(dates.period, ''C'',a_leads,0) a_leads_C,
			     decode(dates.period, ''C'',orders,0) orders_C,
			     decode(dates.period, ''C'',BOOKED_WEB_ORDERS,0) total_booked_orders_C,
			     decode(dates.period, ''C'',repeat_web_orders,0) repeat_web_orders_C,
			     decode(dates.period, ''C'',orders_site_visits,0) orders_site_visits_C,
			     decode(dates.period, ''C'',decode(:l_currency,:l_gp_currency,booked_amt_g,:l_gs_currency,booked_amt_g1
					 ,currency_cd_f,booked_amt_f),0) BOOKED_AMOUNT_C  /* Change for issue 20 bug 4636308)  */
				FROM
				      ( SELECT
					   fii.start_date START_DATE,
					   ''C'' PERIOD,
					   least(fii.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
					   FROM '||l_period_type||'   fii
					   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
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
					  WHERE p1.id(+) = p2.id) dates, '|| l_table_list ||'
				WHERE
				   cal.report_date	  = dates.report_date AND
				   VISIT_MV.time_id  =	cal.time_id AND
				   VISIT_MV.period_type_id = cal.period_type_id AND
				   bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'|| l_outer_where_clause ||')
		          GROUP BY START_DATE
                       ) s,'|| l_period_type||' fii
WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE AND
fii.start_date = s.start_date(+)
ORDER BY fii.start_date';


--IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
--    fnd_log.string(fnd_log.level_unexpected,l_full_path,'Visitor Conversion Trend Portlet Query : ' || l_custom_sql);
-- END IF;


    x_custom_sql  := l_custom_sql;


  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  x_custom_output.Extend(3);

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

 --IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
 --   fnd_log.string(fnd_log.level_unexpected,l_full_path,'Visitor Conversion Trend Portlet Query ended');
-- END IF;

 EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;
END GET_VISTR_CONV_TRND_SQL;




-- Procedure for the Visit Trend Report

/*
------------------------------------------------------------
Procedure name       : GET_VISIT_TREND_SQL
Parameters
IN                   : p_param        pl/sql table
OUT                  : x_custom_sql   varchar2
OUT                  : x_cusom_output pl/sql table

Description          : This procedure will be called from
                       the 'Web Analytics Visit Trend portlet'
------------------------------------------------------------
*/
PROCEDURE GET_VISIT_TREND_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL )
IS
-- Generic Variables

  l_custom_sql            VARCHAR2(15000) ; --Final Sql.
  l_asof_dt               DATE;             --As of Date
  l_site                  VARCHAR2(3200) ;  --Site Id
  l_period_type           VARCHAR2(1000) ;  --Period Type
  l_parameter_name        VARCHAR2(3200) ;  --Parameter Name
  l_page                  VARCHAR2(3200) ;  -- Page  Not required for this report
  l_site_area             VARCHAR2(3200) ;  -- Site Area  Not required for this report
  l_view_by               VARCHAR2(3200);   -- View By   Not required for this report
  l_rec_id                NUMBER;
  l_table_list            VARCHAR2(3200) ;
  l_inner_where_clause    VARCHAR2(3200) ;
  l_outer_where_clause    VARCHAR2(3200) ;
  l_custom_rec            BIS_QUERY_ATTRIBUTES;
  l_dimension_id          NUMBER;
  l_dimension_view        VARCHAR2(3200);
  l_dim_where             VARCHAR2(3200);
  l_group_by              VARCHAR2(1000);
  l_order_by              VARCHAR2(100);
  l_referral              VARCHAR2(3200) ; -- Referral Dimension  Not required for this report
  l_campaign              VARCHAR2(3200) ;  --  Not required for this report


-- Specific for trend reports

  l_timetable        VARCHAR2(3200);
  l_timespan         NUMBER;
  l_sequence         NUMBER;
  l_cur_start        DATE;
  l_mid_start        DATE;
  l_prev_start       DATE;
  l_pprev_start      DATE;
  l_pcur_start       DATE;
  l_cur_year         NUMBER;
  l_prev_year        NUMBER;

-- Specific Variables

  l_cust_class   VARCHAR2(3200) ; -- Customer Classification
  l_cust         VARCHAR2(3200) ; -- Customer  Not required for this report
  l_currency     VARCHAR2(3200) ; -- Currency  Not required for this report
  l_comp_to      VARCHAR2(3200) ; -- Compare To
  l_prev_date    DATE;            -- Previous Date
  l_prod_catg    VARCHAR2(3200) ; -- Product Category  Not required for this report
  l_prod         VARCHAR2(3200) ; -- Product  Not required for this report
  l_gp_currency  VARCHAR2(15) ; --Global Primary Currency  Not required for this report
  l_gs_currency  VARCHAR2(15) ; --Global Secondary Curr  Not required for this report
  l_f_currency   VARCHAR2(15) ;   -- Functional Currency  Not required for this report
  l_gp_amount    NUMBER ;         -- Primary Currency Amount  Not required for this report
  l_gs_amount    NUMBER ;         -- Secondary Currency Amount  Not required for this report
  l_f_amount     NUMBER ;         -- Functional Amount  Not required for this report


  --FND Logging
  l_full_path   VARCHAR2(50) ;
  --gaflog_value    CONSTANT VARCHAR2(10);

  gaflog_value     CONSTANT VARCHAR2(10) := fnd_profile.value('AFLOG_ENABLED');
  --Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level

BEGIN

  --gaflog_value   := fnd_profile.value('AFLOG_ENABLED');

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'Visit Trend Report BEGIN');
  END IF;

  --initialization

  l_gp_currency   := '''FII_GLOBAL1''' ; --Global Primary Currency  Not required for this report
  l_gs_currency   := '''FII_GLOBAL2''' ; --Global Secondary Curr  Not required for this report

   l_full_path    := 'ibw.plsql.ibwbvtrb.get_visit_trend_sql';
   --gaflog_value   := fnd_profile.value('AFLOG_ENABLED');
--Fetch all the Parameters into the Local Variables.

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package to get parameter values');
  END IF;

    IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
   (
     P_PMV_PARAMETERS   =>  p_pmv_parameters,
     X_PERIOD_TYPE	    =>  l_period_type,
     X_SITE             =>  l_site,
     X_CURRENCY_CODE    =>  l_currency,   --Not Wanted
     X_SITE_AREA        =>  l_site_area,  --Not Wanted
     X_PAGE             =>  l_page,       --Not Wanted
     X_REFERRAL         =>  l_referral,   --Not Wanted
     X_PROD_CAT         =>  l_prod_catg,  --Not Wanted
     X_PROD             =>  l_prod,       --Not Wanted
     X_CUST_CLASS       =>  l_cust_class,
     X_CUST             =>  l_cust,        --Not Wanted
     X_CAMPAIGN		      =>  l_campaign,   --Not Wanted
     X_VIEW_BY          =>  l_view_by     --Not Wanted
    );

 IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
 END IF;

 IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site || ' l_cust_class : ' || l_cust_class );
 END IF;



  --Initializing section starts

  l_outer_where_clause  := '';
  l_custom_rec		:=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  --Initializing section completed

  --Get the Table List

  l_table_list   := ' IBW_VISIT_CUST_TIME_MV VISIT_MV' ||  --  To be replaced by the mv when it is ready
                    ' ,FII_TIME_RPT_STRUCT_V CAL' ||
	 	    ' ,FII_PARTY_MKT_CLASS CUST_CLASS_MAP';

--  l_inner_where_clause (time specific)


-- Initialising where clause based on the parameter selection

  IF upper(l_site) <> 'ALL' THEN
    l_outer_where_clause   := l_outer_where_clause ||
				' AND VISIT_MV.SITE_ID in (&SITE+SITE)' ;

  ELSE
    l_table_list := l_table_list  || ', IBW_BI_MSITE_DIMN_V SITE';
    l_outer_where_clause   := l_outer_where_clause ||
				' AND VISIT_MV.SITE_ID = SITE.ID ';
  END IF;

  IF upper(l_cust_class) <> 'ALL' THEN

    l_outer_where_clause   := l_outer_where_clause ||
				' AND VISIT_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				' AND CUST_CLASS_MAP.class_code in (&FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  ELSE
    l_table_list      := l_table_list || ' ,FII_TRADING_PARTNER_MKTCLASS_V CUSTCLASS';
    l_outer_where_clause    := l_outer_where_clause ||
				' AND VISIT_MV.CUSTOMER_ID = CUST_CLASS_MAP.PARTY_ID '||
				' AND CUST_CLASS_MAP.class_code = CUSTCLASS.ID ';
  END IF;


 /*************************************************************************/
 /* Metrics used in Visit Trend Report:                                   */
 /* IBW_VAL10                 : Prior                                     */
 /* IBW_VAL1                  : Visits                                    */
 /* IBW_VAL2                  : Change					                          */
 /* IBW_VAL3                  : Repeat Visits                             */
 /* IBW_VAL4                  : Average Visit Duartion (minutes)          */
 /* IBW_VAL5                  : Average Page Views                        */
 /* IBW_VAL6                  : Daily Unique Visitors                     */
 /* IBW_VAL7                  : Opt Outs                                  */
 /* IBW_VAL11                 : Prior                                     */
 /* IBW_VAL8                  : Browse to Buy                             */
 /* IBW_VAL9                  : Change                                    */
 /*                                                                       */
 /*********************Bind Parameters used are****************************/
 /*                                                                               */
 /* &BIS_CURRENT_ASOF_DATE          :  AS OF DATE selected in the report          */
 /* &BIS_PREVIOUS_ASOF_DATE         : Previous period as of date                  */
 /* &BIS_CURRENT_REPORT_START_DATE  : Current period start date                   */
 /* &BIS_PREVIOUS_REPORT_START_DATE : Previous period startdate                   */
 /* &BIS_NESTED_PATTERN             :  Record Type Id of the Period Type selected */
 /*********************************************************************************/


--  Not returning value for IBW_VAL2 and IBW_VAL9 as per bug # 4772549.

l_custom_sql:= 'SELECT  fii.NAME VIEWBY,
               nvl(VISITS_PRE,0)  IBW_VAL10, --Bug#4727078 Issue#:21
	             nvl(VISITS_CUR,0)  IBW_VAL1,
               nvl(REPEAT_VISITS_CUR,0) IBW_VAL3,
		           decode(nvl(visit_duration_cur,0),0,null,(nvl(visit_duration_cur,0)/nvl(visits_cur,0))/60000) IBW_VAL4, --Bug#5014704 Issue# 1.  Returned null instead of 0 for bug 5253591
               decode(nvl(visits_cur,0),0,null, nvl(page_views_cur,0)/nvl(visits_cur,0)) IBW_VAL5,      -- Returned null instead of 0 for bug 5253591
               nvl(DAILY_UNIQ_VISITORS_CUR,0) IBW_VAL6,
               nvl(OPT_OUTS_CUR,0) IBW_VAL7,
               decode(nvl(visits_pre,0),0,null, (nvl(orders_site_visits_pre,0) /nvl(visits_pre,0))*100)  IBW_VAL11, --Bug#4727078 Issue#:21    Returned null instead of 0 for bug 5253591
               decode(nvl(visits_cur,0),0,null, (nvl(orders_site_visits_cur,0) /nvl(visits_cur,0))*100)  IBW_VAL8    -- Returned null instead of 0 for bug 5253591
	     FROM (
               SELECT
                 START_DATE,
                 sum(visits_c) VISITS_CUR,
                 sum(visits_p) VISITS_PRE,
                 sum(repeat_visits_c) REPEAT_VISITS_CUR,
                 sum(visit_duration_c) VISIT_DURATION_CUR,
                 sum(page_views_c) page_views_cur,
                 sum(daily_uniq_visitors_c) DAILY_UNIQ_VISITORS_CUR,
                 sum(opt_outs_c) OPT_OUTS_CUR,
                 sum(orders_site_visits_C) orders_site_visits_cur,
                 sum(orders_site_visits_P) orders_site_visits_pre
		           FROM
			         (
                 SELECT
                   dates.start_date  START_DATE,
                   decode(dates.period, ''C'',visits,0) visits_C,
                   decode(dates.period, ''P'',visits,0) visits_P,
                   decode(dates.period, ''C'',repeat_visits,0) repeat_visits_c,
                   decode(dates.period, ''C'',visit_duration,0) visit_duration_c,
                   decode(dates.period, ''C'',page_views,0) page_views_c,
                   decode(dates.period, ''C'',daily_uniq_visitors,0) daily_uniq_visitors_c,
                   decode(dates.period, ''C'',opt_outs,0) opt_outs_c,
                   decode(dates.period, ''C'',orders_site_visits,0) orders_site_visits_C,
                   decode(dates.period, ''P'',orders_site_visits,0) orders_site_visits_P
				         FROM
				         (
                   SELECT
                   fii.start_date START_DATE,
                   ''C'' PERIOD,
                   least(fii.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
                   FROM '||l_period_type||'   fii
                   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
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
					  WHERE p1.id(+) = p2.id) dates, '|| l_table_list ||'
				WHERE
				   cal.report_date	  = dates.report_date AND
				   VISIT_MV.time_id  =	cal.time_id AND
				   VISIT_MV.period_type_id = cal.period_type_id AND
				   bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'|| l_outer_where_clause ||')
		          GROUP BY START_DATE
                       ) s,'|| l_period_type||' fii
WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE AND
fii.start_date = s.start_date(+)
ORDER BY fii.start_date';

-- IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
--    fnd_log.string(fnd_log.level_unexpected,l_full_path,'Visit Trend Portlet Query : ' || l_custom_sql);
-- END IF;



    x_custom_sql  := l_custom_sql;






EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;
END GET_VISIT_TREND_SQL;


-- Procedure for the Web Campaign Analysis Report

/*
------------------------------------------------------------
Procedure name       : GET_WEB_CAMPAIGN_SQL
Parameters           :
IN                   : p_param        pl/sql table
OUT                  : x_custom_sql   varchar2
OUT                  : x_cusom_output pl/sql table

Description          : This procedure will be called from the Campaign Analysis report

Modification History :
Date        Name       Desc
----------  ---------  ----------------------------------
03/08/2005  Narao      Campaign Analysis Report UI Query.

------------------------------------------------------------
*/

PROCEDURE GET_WEB_CAMPAIGN_SQL  ---  change name to campaign_nontrend_sql
( p_param         IN  BIS_PMV_PAGE_PARAMETER_TBL
, x_custom_sql    OUT NOCOPY VARCHAR2
, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
)
IS
--Generic Variables
  l_custom_sql     VARCHAR2(15000) ; --Final Sql.
  l_asof_dt        DATE            ; --As of Date
  l_site           VARCHAR2(3200)  ; --Site Id
  l_period_type    VARCHAR2(3200)  ; --Period Type
  l_parameter_name VARCHAR2(3200)  ; --Parameter Name
  l_page           VARCHAR2(3200)  ; -- Page
  l_site_area      VARCHAR2(3200)  ; -- Site Area
  l_view_by        VARCHAR2(3200)  ;
  l_rec_id         NUMBER          ;
  l_from           VARCHAR2(32000) ;
  l_where          VARCHAR2(32000) ;
  l_outer_select   VARCHAR2(30000) ;
  l_inner_select   VARCHAR2(30000) ;
  l_custom_rec     BIS_QUERY_ATTRIBUTES;
  l_dimension_id   NUMBER  ;
  l_dimension_view VARCHAR2(3200) ;
  l_dim_where      VARCHAR2(3200) ;
  l_view_by_name   VARCHAR2(100)  ;     --Either Campaign or Site
  l_group_by       VARCHAR2(1000) ;
  l_inner_group_by VARCHAR2(1000) ;
  l_outer_group_by VARCHAR2(1000) ;
  l_order_by       VARCHAR2(100)  ;
  l_url_str        VARCHAR2(1000) ; --For URL String Construction.
  l_gp_currency    VARCHAR2(30) := '''FII_GLOBAL1''' ; --Global Primary Currency
  l_gs_currency    VARCHAR2(30) := '''FII_GLOBAL2''' ; --Global Secondary Curr
  l_f_currency     VARCHAR2(30) ;   -- Functional Currency
  l_f_amount       NUMBER ;         -- Functional Amount
  l_having         VARCHAR2(2000);

  --Un wanted Variables

  l_referral       VARCHAR2(3200) ; -- Referral Dimension
  l_cust_class     VARCHAR2(3200) ; -- Customer Classification
  l_cust           VARCHAR2(3200) ; -- Customer
  l_campaign       VARCHAR2(3200) ; -- Campaign
  l_currency       VARCHAR2(3200) ; -- Currency
  l_comp_to        VARCHAR2(3200) ; -- Compare To
  l_ord_by         VARCHAR2(3200) ; -- Order By
  l_prev_date      DATE;            -- Previous Date
  l_prod_catg      VARCHAR2(3200) ; -- Product Category
  l_prod           VARCHAR2(3200) ; -- Product
  --FND Logging
  l_full_path      VARCHAR2(50) ;

  --Profile is : FND: Debug Log Enabled
  gaflog_value     CONSTANT VARCHAR2(10) := fnd_profile.value('AFLOG_ENABLED');


BEGIN


  /*
  Open issues :
  1. fnd_log.string(fnd_log.level_unexpected,l_full_path,l_custom_sql);  to be removed
  2. gaflog_value     CONSTANT VARCHAR2(10) := fnd_profile.value('AFLOG_ENABLED') to be removed
  3. Sum of Grand Totals with Division to be handled.

  */

  --Fetch all the Parameters into the Local Variables.
  if gaflog_value ='Y' and (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,l_full_path,'begin');
  end if;


  l_full_path := 'ibw.plsql.ibwrepab.page_int_nontrend_sql'; --This is the path which would be referred in fnd_log_messages.module

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;

  --To get all the Page Parameters.
  IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
    (
        p_pmv_parameters  =>  p_param
      , x_period_type     =>  l_period_type    --Period type
      , x_site            =>  l_site           --Site Id
      , x_currency_code   =>  l_currency       --Currency
      , x_site_area       =>  l_site_area      --Not used
      , x_page            =>  l_page           --Not used
      , x_referral        =>  l_referral       --Not Used
      , x_prod_cat        =>  l_prod_catg      --Not Used
      , x_prod            =>  l_prod           --Not Used
      , x_cust_class      =>  l_cust_class     --Not Used
      , x_cust            =>  l_cust           --Not Used
      , x_campaign        =>  l_campaign       --Campaign
      , x_view_by         =>  l_view_by        --Either Campaign or Site.
    );

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  if gaflog_value ='Y' and (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_site' || l_site ||' l_view_by '|| l_view_by ||' l_campaign: '|| l_campaign||' l_currency '|| l_currency );
  end if;


  l_where           := '';
  l_url_str         := null; --Initialising the String to Null
  l_custom_rec      :=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  --Initializing section starts
  /********************Metrics in Campaign Analysis Report*********************/
   /* IBW_VAL1                  : Visits                                */
   /* IBW_VAL2                  : Average Visit Duration					      */
   /* IBW_VAL3                  : Average Page Views                    */
   /* IBW_VAL4                  : Daily Unique Visitors					        */
   /* IBW_VAL5                  : Registrations                         */
   /* IBW_VAL6                  : A Leads					                      */
   /* IBW_VAL7                  : Carts                                 */
   /* IBW_VAL8                  : Cart Conversion Ratio					        */
   /* IBW_VAL9                  : Booked Orders Amount 					        */
   /* IBW_G_TOT1                : Sum of Visits                         */
   /* IBW_G_TOT2                : Sum of Average Visit Duration         */
   /* IBW_G_TOT3                : Sum of Average Page Views             */
   /* IBW_G_TOT4                : Sum of Daily Unique Visitors          */
   /* IBW_G_TOT5                : Sum of Registrations                  */
   /* IBW_G_TOT6                : Sum of A Leads                        */
   /* IBW_G_TOT7                : Sum of Carts                          */
   /* IBW_G_TOT8                : Sum of Cart Conversion Ratio	        */
   /* IBW_G_TOT9                : Sum of Booked Orders Amount 	        */
   /*********************Bind Parameters used are****************************/

   /* &BIS_CURRENT_ASOF_DATE  :  AS OF DATE selected in the report          */
   /* &BIS_NESTED_PATTERN     :  Record Type Id of the Period Type selected */

    /************************************************************************/

  -- Added by pipandey for Bug# 4687647 Issue# 3
  -- Changed Average Visit Duration - added division by 60000,Cart Conversion  multiply by 100
  --------------------------------------------------------------------------------------------------------------
  l_outer_select  := ' nvl(visits,0) IBW_VAL1, ' ||                                                --Visits
                     ' DECODE(visits,0,null,null,null,((visit_duration/visits)/60000)) IBW_VAL2, ' || --Average Visit Duration
                     ' DECODE(visits,0,null,null,null,page_views/ visits) IBW_VAL3, ' ||    --Average Page Views
                     ' nvl(daily_uniq_visitors,0) IBW_VAL4, ' ||                                   --Daily Unique Visitors
                     ' nvl(web_registrations,0) IBW_VAL5, ' ||                                     --Registrations
                     ' nvl(a_leads,0) IBW_VAL6, ' ||                                               --A Leads
                     ' nvl(carts,0) IBW_VAL7, ' ||                                                 --Carts
                     ' DECODE(carts,0,null,null,null, ((orders/carts)*100)) IBW_VAL8, ' ||          --Cart Conversion Ratio.
                     ' nvl(booked_orders_amount,0) IBW_VAL9, ' ||                                  --Booked Orders Amount
                     --Changes for the ER 4760433
                      ' nvl(booked_orders_amount,0) IBW_VAL11, ' ||
                       ' nvl(a_leads,0) IBW_VAL10, ' ||
                     --Changes for the ER 4760433
                      --For Grand Totals
                     ' SUM(nvl(visits,0)) OVER() IBW_G_TOT1, ' ||
                     --' SUM(DECODE(visits,0,null,null,null, visit_duration / visits)) OVER() IBW_G_TOT2, '||    Grand Total Change
                     --' SUM(DECODE(visits,0,null,null,null,page_views/ visits)) OVER() IBW_G_TOT3, ' ||         Grand Total Change
                     ' DECODE(SUM(visits) over(),0,null,null,null, (((SUM(visit_duration) over() / SUM(visits) over()))/60000)) IBW_G_TOT2, '||
                     ' DECODE(SUM(visits) over(),0,null,null,null,(SUM(page_views) over()/ SUM(visits) over())) IBW_G_TOT3, ' ||
                     ' SUM(nvl(daily_uniq_visitors,0)) OVER() IBW_G_TOT4, '||
                     ' SUM(nvl(web_registrations,0)) OVER() IBW_G_TOT5, ' ||
                     ' SUM(nvl(a_leads,0)) OVER() IBW_G_TOT6, '||
                     ' SUM(nvl(carts,0)) OVER() IBW_G_TOT7, ' ||
                     --' SUM(DECODE(Carts,0,null,null,null, orders / carts)) OVER() IBW_G_TOT8, '||  Grand Total Change
                     ' DECODE(SUM(Carts) over(),0,null,null,null, ((SUM(orders) over() / SUM(Carts) over())*100))  IBW_G_TOT8, '||
                     ' SUM(nvl(booked_orders_amount,0)) OVER() IBW_G_TOT9 ';

  if gaflog_value ='Y' and (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Outer Select'  );
  end if;

  l_inner_select  := ' SUM(visits) visits, SUM(visit_duration) visit_duration, ' ||
                     ' SUM(page_views) page_views,  SUM(daily_uniq_visitors) daily_uniq_visitors, ' ||
                     ' SUM(web_registrations) web_registrations, SUM(a_leads) a_leads, ' ||
                     ' SUM(carts) carts, SUM(orders) orders, ' ||
                     ' SUM(decode(:l_currency,:l_gp_currency,booked_amt_g,:l_gs_currency,booked_amt_g1,cmp_mv.currency_cd_f,booked_amt_f)) booked_orders_amount ';
                     --' SUM( booked_amt_g ) a_booked_orders_amount ';
  l_having        := ' SUM(visits) > 0 ' ||
                     ' OR SUM(visit_duration) > 0 ' ||
                     ' OR SUM(page_views) > 0 ' ||
                     ' OR SUM(daily_uniq_visitors) > 0 ' ||
                     ' OR SUM(web_registrations) > 0 ' ||
                     ' OR SUM(a_leads) > 0 ' ||
                     ' OR SUM(carts) > 0 '   ||
                     ' OR SUM(orders) > 0 ' ||
                     ' OR SUM(decode(:l_currency,:l_gp_currency,booked_amt_g,:l_gs_currency,booked_amt_g1,cmp_mv.currency_cd_f,booked_amt_f)) > 0 ' ;

  if gaflog_value ='Y' and (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Inner Select'  );
  end if;

  l_from          := ' IBW_CMPANLYS_CMPDIM_TIME_MV CMP_MV ' ||
                     ' , FII_TIME_RPT_STRUCT_V      CAL    ';

   l_where         := ' CAL.report_date = &BIS_CURRENT_ASOF_DATE ' ||
                      ' AND CAL.period_type_id = CMP_MV.period_type_id ' ||
                      ' AND BITAND(CAL.RECORD_TYPE_ID,&BIS_NESTED_PATTERN)= CAL.RECORD_TYPE_ID '||
                      ' AND CMP_MV.TIME_ID = CAL.TIME_ID ' ||
                      ' AND CAL.CALENDAR_ID = -1 '; --Indicates Enterprise Calendar

  if gaflog_value ='Y' and (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,l_full_path,'Before the View By Condition'  );
  end if;

  -- Fetching Site Name or Campaign Name according to the View by
  IF l_view_by = 'SITE+SITE'   THEN --View by is Site

      l_url_str         := ' , NULL ';
      l_inner_select    := ' SITE.VALUE VIEW_BY , SITE.ID VIEWBYID, ' || l_inner_select;  --SITE.VALUE will give the Site Name.
      l_outer_select    := ' VIEW_BY VIEWBY,VIEWBYID,  NULL IBW_ATTR1, ' || l_outer_select || l_url_str || ' IBW_URL1 ' ; --IBW_ATTR1 would be hidden when View by is Site.
      l_from            := l_from || ' , IBW_BI_MSITE_DIMN_V SITE '; --Site Dimension View.
      l_where           := l_where || ' AND CMP_MV.SITE_ID = SITE.ID ';
      l_inner_group_by  := ' SITE.VALUE , SITE.ID';


      IF UPPER(l_site) <> 'ALL' THEN
        l_where := l_where || ' AND CMP_MV.SITE_ID IN (&SITE+SITE) ' ; --In condition as Site is Multi Select
        --Else is not required as the join of CMP_MV.SITE_ID = SITE.ID is already done.
      END IF;

      --Added by pipandey for Bug# 4687647 Issue# 3
      IF UPPER(l_campaign) <> 'ALL' THEN
        l_where := l_where || 'AND CMP_MV.PRIOR_ID = (&CAMPAIGN+CAMPAIGN) '; --Equal condition as Campaign dimension is single select
      ELSE
        l_where := l_where || 'AND CMP_MV.PRIOR_ID IS NULL ';
      END IF;

  ELSIF l_view_by = 'CAMPAIGN+CAMPAIGN' THEN --View by is Campaign

      l_url_str:='pFunctionName=IBW_BI_CMPGNANLYS_RPT&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
      l_url_str         :=' ,DECODE(nvl(object_type,'||''''||'CSCH'||''''||'),'||''''||'CSCH'||''''||',NULL,'||''''||l_url_str||''''||' ) ';
      l_inner_select    := ' CAMPAIGN.NAME VIEW_BY , CAMPAIGN.SOURCE_CODE_ID VIEWBYID ,CAMPAIGN.OBJECT_TYPE_MEAN CAMPAIGN_TYPE, CAMPAIGN.OBJECT_TYPE OBJECT_TYPE, ' || l_inner_select;  --Campaign Name and Campaign Type
      l_outer_select    := ' VIEW_BY VIEWBY ,VIEWBYID,DECODE(object_type,''CSCH'',''N'',''Y'') DRILLPIVOTVB, CAMPAIGN_TYPE IBW_ATTR1, ' ||l_outer_select || l_url_str || ' IBW_URL1 ' ;
      l_from            := l_from || ' , BIM_I_OBJ_NAME_MV CAMPAIGN ' ;
      l_where           := l_where || ' AND CMP_MV.PARENT_SOURCE_CODE_ID = CAMPAIGN.SOURCE_CODE_ID AND CAMPAIGN.language = USERENV(''LANG'') ';
      l_inner_group_by  := ' CAMPAIGN.NAME ,   CAMPAIGN.SOURCE_CODE_ID, CAMPAIGN.OBJECT_TYPE_MEAN, CAMPAIGN.OBJECT_TYPE ' ;

      IF UPPER(l_campaign) <> 'ALL' THEN
        l_where := l_where || 'AND CMP_MV.PRIOR_ID = (&CAMPAIGN+CAMPAIGN) '; --Equal condition as Campaign dimension is single select
      ELSE
        l_where := l_where || 'AND CMP_MV.PRIOR_ID IS NULL ';
      END IF;

      IF UPPER(l_site) <> 'ALL' THEN
        l_where := l_where || ' AND CMP_MV.SITE_ID IN (&SITE+SITE) ' ; --In condition as Site is Multi Select
      ELSE
        l_from  := l_from || ', IBW_BI_MSITE_DIMN_V SITE ';
        l_where := l_where || ' AND CMP_MV.SITE_ID = SITE.ID ';
      END IF;

  END IF; --End if for l_view_by

  -- Final Query
  l_custom_sql := 'SELECT ' || l_outer_select ||
             ' FROM ' ||
                    ' (SELECT '   || l_inner_select ||
                    ' FROM '     || l_from ||
                    ' WHERE '    || l_where ||
                    ' GROUP BY ' || l_inner_group_by ||
                    ' HAVING '   || l_having ||
                   ' ) '  ||
             ' &ORDER_BY_CLAUSE ' ;

  --fnd_log.string(fnd_log.level_unexpected,l_full_path,l_custom_sql);  --To be removed Later


 if gaflog_value ='Y' and (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_outer_select' || l_outer_select);
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_inner_select' || l_inner_select);
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_from' || l_from);
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_where' || l_where);
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_inner_group_by ' || l_inner_group_by);
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_custom_sql' || l_custom_sql);
  end if;


   --Build the Tokens
   -- Out parameters

  x_custom_sql := l_custom_sql;

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

 if gaflog_value ='Y' and (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
   fnd_log.string(fnd_log.level_statement,l_full_path,'end');
 end if;

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;
END GET_WEB_CAMPAIGN_SQL;

-- Procedure for the KPI's

/*
----------------------------------------------------------------------------
Procedure name       : GET_KPI_SQL
Parameters
IN                   : p_param        pl/sql table
OUT                  : x_custom_sql   varchar2
OUT                  : x_cusom_output pl/sql table

Description          : This procedure will be called from
                       the 'KPI in the Site Management Dashboard '
------------------------------------------------------------------------------
*/

PROCEDURE GET_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL )
IS

-- Generic Variables

  l_custom_sql            VARCHAR2(15000) ; --Final Sql.
  l_custom_sql1           VARCHAR2(15000) ; --Final Sql.
  l_custom_sql2           VARCHAR2(15000) ; --Final Sql.
  l_asof_dt               DATE;             --As of Date
  l_site                  VARCHAR2(3200) ;  --Site Id
  l_period_type           VARCHAR2(1000) ;  --Period Type
  l_parameter_name        VARCHAR2(3200) ;  --Parameter Name
  l_page                  VARCHAR2(3200) ;  -- Page  Not required for this report
  l_site_area             VARCHAR2(3200) ;  -- Site Area  Not required for this report
  l_view_by               VARCHAR2(3200);   -- View By   Not required for this report
  l_rec_id                NUMBER;
  l_table_list            VARCHAR2(3200) ;
  l_inner_where_clause    VARCHAR2(3200) ;  --??????
  l_outer_where_clause    VARCHAR2(3200) ; --?????
  l_custom_rec            BIS_QUERY_ATTRIBUTES;
  l_dimension_id          NUMBER;
  l_dimension_view        VARCHAR2(3200);
  l_dim_where             VARCHAR2(3200);
  l_group_by              VARCHAR2(1000);
  l_order_by              VARCHAR2(100);
  l_referral              VARCHAR2(3200) ; -- Referral Dimension  Not required for this report
  l_campaign	            VARCHAR2(3200) ;  --  Not required for this report


-- Specific for trend reports

  l_timetable        VARCHAR2(3200);
  l_timespan         NUMBER;
  l_sequence         NUMBER;
  l_cur_start        DATE;
  l_mid_start        DATE;
  l_prev_start       DATE;
  l_pprev_start      DATE;
  l_pcur_start       DATE;
  l_cur_year         NUMBER;
  l_prev_year        NUMBER;

-- Specific Variables

  l_cust_class   VARCHAR2(3200) ; -- Customer Classification  Not required for this report
  l_cust         VARCHAR2(3200) ; -- Customer  Not required for this report
  l_currency     VARCHAR2(3200) ; -- Currency
  l_comp_to      VARCHAR2(3200) ; -- Compare To
  l_prev_date    DATE;            -- Previous Date
  l_prod_catg    VARCHAR2(3200) ; -- Product Category  Not required for this report
  l_prod         VARCHAR2(3200) ; -- Product  Not required for this report
  l_gp_currency  VARCHAR2(30) ; --Global Primary Currency
  l_gs_currency  VARCHAR2(30)  ; --Global Secondary Curr
  l_f_currency   VARCHAR2(15) ;   -- Functional Currency
  l_gp_amount    NUMBER ;         -- Primary Currency Amount
  l_gs_amount    NUMBER ;         -- Secondary Currency Amount
  l_f_amount     NUMBER ;         -- Functional Amount

  l_full_path       VARCHAR2(50);
  gaflog_value      VARCHAR2(10);


BEGIN

  --Profiles for FND Debugging are  : FND: Log Enabled , FND: Log Level
  l_full_path  := 'ibw.plsql.ibwbvckb.GET_KPI_SQL'; --This would be stored in FND_LOG_MESSAGES.MODULE column
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');

-- initialization

  l_gp_currency   := '''FII_GLOBAL1''' ;
  l_gs_currency   := '''FII_GLOBAL2''' ;

--Fetch all the Parameters into the Local Variables.

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'Begin');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;

    IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
   (
     P_PMV_PARAMETERS   =>  p_pmv_parameters,
     X_PERIOD_TYPE	    =>  l_period_type,
     X_SITE             =>  l_site,
     X_CURRENCY_CODE    =>  l_currency,
     X_SITE_AREA        =>  l_site_area,  --Not Wanted
     X_PAGE             =>  l_page,       --Not Wanted
     X_REFERRAL         =>  l_referral,   --Not Wanted
     X_PROD_CAT         =>  l_prod_catg,  --Not Wanted
     X_PROD             =>  l_prod,       --Not Wanted
     X_CUST_CLASS       =>  l_cust_class,  --Not Wanted
     X_CUST             =>  l_cust,        --Not Wanted
     X_CAMPAIGN		      =>  l_campaign,   --Not Wanted
     X_VIEW_BY          =>  l_view_by     --Not Wanted
    );

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site ||' l_currency :  '|| l_currency );
  END IF;
  --Initializing section starts

  l_outer_where_clause  := '';
  l_custom_rec		:=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  --Initializing section completed

  --Get the Table List

  l_table_list   := ' IBW_KPI_METRICS_TIME_MV  FACT' ||
                    ' ,FII_TIME_RPT_STRUCT_V CAL' ;


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_table_list: ' || l_table_list);
  END IF;

  -- Initialising where clause based on the site parameter selection
  --Added for Bug#:4660266
  IF upper(l_site) <> 'ALL' THEN
    l_outer_where_clause   := l_outer_where_clause || ' AND FACT.SITE_ID in (&SITE+SITE) ' ;
   --The Else Condition is not needed here as the same is used already in the custom_sql below.
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_outer_where_clause: ' || l_outer_where_clause);
  END IF;

l_custom_sql1:= 'SELECT ID VIEWBYID, SITE_VAL VIEWBY, ID  IBW_VAL1,
       nvl(Visits_cur,0) IBW_VAL2,
       nvl(Visits_pre,0) IBW_VAL3,
       sum(nvl(Visits_cur,0)) over() IBW_VAL5,
       sum(nvl(Visits_pre,0)) over() IBW_VAL6,
       nvl(WEB_REGISTRATIONS_cur,0) IBW_VAL7,
       nvl(WEB_REGISTRATIONS_PRE,0)  IBW_VAL8,
       sum(nvl(WEB_REGISTRATIONS_cur,0)) over() IBW_VAL10,
       sum(nvl(WEB_REGISTRATIONS_PRE,0)) over() IBW_VAL11,
       nvl(BOOKED_WEB_ORDERS_cur,0) IBW_VAL17,
       nvl(BOOKED_WEB_ORDERS_pre,0) IBW_VAL18,
       sum(nvl(BOOKED_WEB_ORDERS_cur,0)) over() IBW_VAL20,
       sum(nvl(BOOKED_WEB_ORDERS_pre,0)) over() IBW_VAL21,
       decode(nvl(Visits_cur,0),0,null,(nvl(ORDERS_SITE_VISITS_cur,0)/visits_cur)*100) IBW_VAL22,   -- Returned null instead of 0 for bug 5253591
       decode(nvl(Visits_pre,0),0,null,(nvl(ORDERS_SITE_VISITS_pre,0)/visits_pre)*100) IBW_VAL23,   -- Returned null instead of 0 for bug 5253591
       decode(SUM(nvl(Visits_cur,0)) over(),0,null,(SUM(nvl(ORDERS_SITE_VISITS_cur,0)) over()/SUM(nvl(Visits_cur,0)) over())*100)  IBW_VAL25,  -- Returned null instead of 0 for bug 5253591
       decode(SUM(nvl(Visits_pre,0)) over(),0,null,(SUM(nvl(ORDERS_SITE_VISITS_pre,0)) over()/SUM(nvl(Visits_pre,0)) over())*100)  IBW_VAL26,  -- Returned null instead of 0 for bug 5253591
       nvl(NEW_WEB_CUSTOMERS_cur,0) IBW_VAL27,
       nvl(NEW_WEB_CUSTOMERS_pre,0)  IBW_VAL28,
       sum(nvl(NEW_WEB_CUSTOMERS_cur,0)) over() IBW_VAL30,
       sum(nvl(NEW_WEB_CUSTOMERS_pre,0)) over() IBW_VAL31,
       decode(nvl(TOTAL_BOOKED_ORDERS_cur,0),0,null, (nvl(BOOKED_WEB_ORDERS_cur,0)/TOTAL_BOOKED_ORDERS_cur)*100) IBW_VAL37,     -- Returned null instead of 0 for bug 5253591
       decode(nvl(TOTAL_BOOKED_ORDERS_pre,0),0,null, (nvl(BOOKED_WEB_ORDERS_pre,0)/TOTAL_BOOKED_ORDERS_pre)*100) IBW_VAL38,      -- Returned null instead of 0 for bug 5253591
       decode(NVL(TOTAL_BOOKED_ORDERS_cur,0),0,null, (SUM(nvl(BOOKED_WEB_ORDERS_cur,0)) over()/NVL(TOTAL_BOOKED_ORDERS_cur,0))*100) IBW_VAL40,   -- Returned null instead of 0 for bug 5253591
       decode(NVL(TOTAL_BOOKED_ORDERS_pre,0),0,null, (SUM(nvl(BOOKED_WEB_ORDERS_pre,0)) over()/NVL(TOTAL_BOOKED_ORDERS_pre,0))*100) IBW_VAL41,   -- Returned null instead of 0 for bug 5253591
       nvl(REPEAT_WEB_ORDERS_cur,0) IBW_VAL42,
       nvl(REPEAT_WEB_ORDERS_pre,0)  IBW_VAL43,
       sum(nvl(REPEAT_WEB_ORDERS_cur,0)) over() IBW_VAL45,
       sum(nvl(REPEAT_WEB_ORDERS_pre,0)) over() IBW_VAL46,
       nvl(REGISTERED_CARTS_cur,0) IBW_VAL47,
       nvl(REGISTERED_CARTS_pre,0)  IBW_VAL48,
       sum(nvl(REGISTERED_CARTS_cur,0)) over() IBW_VAL50,
       sum(nvl(REGISTERED_CARTS_pre,0)) over() IBW_VAL51 ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_custom_sql1: ' || l_custom_sql1);
  END IF;

l_custom_sql2:=' FROM (
       SELECT ID, SITE_VAL,
       sum(Visits_cur) Visits_cur,
       sum(Visits_pre) Visits_pre,
       sum(WEB_REGISTRATIONS_cur) WEB_REGISTRATIONS_cur,
       sum(WEB_REGISTRATIONS_pre) WEB_REGISTRATIONS_pre,
       sum(CARTS_cur) CARTS_cur,
       sum(CARTS_pre) CARTS_pre,
       sum(BOOKED_WEB_ORDERS_cur) BOOKED_WEB_ORDERS_cur,
       sum(BOOKED_WEB_ORDERS_pre) BOOKED_WEB_ORDERS_pre,
       sum(ORDERS_SITE_VISITS_cur) ORDERS_SITE_VISITS_cur,
       sum(ORDERS_SITE_VISITS_pre) ORDERS_SITE_VISITS_pre,
       sum(NEW_WEB_CUSTOMERS_cur) NEW_WEB_CUSTOMERS_cur,
       sum(NEW_WEB_CUSTOMERS_pre) NEW_WEB_CUSTOMERS_pre,
       sum(AMT_cur) AMT_cur,
       sum(AMT_pre ) AMT_pre,
       sum(TOTAL_BOOKED_ORDERS_cur)TOTAL_BOOKED_ORDERS_cur ,
       sum(TOTAL_BOOKED_ORDERS_pre) TOTAL_BOOKED_ORDERS_pre,
       sum(REPEAT_WEB_ORDERS_cur) REPEAT_WEB_ORDERS_cur,
       sum(REPEAT_WEB_ORDERS_pre) REPEAT_WEB_ORDERS_pre,
       sum(REGISTERED_CARTS_cur) REGISTERED_CARTS_cur,
       sum(REGISTERED_CARTS_pre) REGISTERED_CARTS_pre
       FROM(
       SELECT SITE.ID ID,SITE.VALUE SITE_VAL,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,fact.visits,0)) Visits_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,fact.visits,0)) Visits_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,fact.WEB_REGISTRATIONS,0)) WEB_REGISTRATIONS_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,fact.WEB_REGISTRATIONS,0)) WEB_REGISTRATIONS_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,fact.CARTS,0)) CARTS_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,fact.CARTS,0)) CARTS_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,fact.BOOKED_WEB_ORDERS,0)) BOOKED_WEB_ORDERS_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,fact.BOOKED_WEB_ORDERS,0)) BOOKED_WEB_ORDERS_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,fact.ORDERS_SITE_VISITS,0)) ORDERS_SITE_VISITS_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,fact.ORDERS_SITE_VISITS,0)) ORDERS_SITE_VISITS_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,fact.NEW_WEB_CUSTOMERS,0)) NEW_WEB_CUSTOMERS_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,fact.NEW_WEB_CUSTOMERS,0)) NEW_WEB_CUSTOMERS_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,decode(:l_currency,:l_gp_currency,BOOKED_AMT_G,:l_gs_currency,BOOKED_AMT_G1,CURRENCY_CD_F,BOOKED_AMT_F,0),0)) AMT_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,decode(:l_currency,:l_gp_currency,BOOKED_AMT_G,:l_gs_currency,BOOKED_AMT_G1,CURRENCY_CD_F,BOOKED_AMT_F,0),0)) AMT_pre,
       NULL TOTAL_BOOKED_ORDERS_cur,
       NULL TOTAL_BOOKED_ORDERS_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,fact.REPEAT_WEB_ORDERS,0)) REPEAT_WEB_ORDERS_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,fact.REPEAT_WEB_ORDERS,0)) REPEAT_WEB_ORDERS_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,(nvl(fact.CARTS,0) - nvl(fact.ANONYMOUS_CARTS,0)),0)) REGISTERED_CARTS_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,(nvl(fact.CARTS,0) - nvl(fact.ANONYMOUS_CARTS,0)),0)) REGISTERED_CARTS_pre
from IBW_KPI_METRICS_TIME_MV  FACT ,
     FII_TIME_RPT_STRUCT_V CAL,
     IBW_BI_MSITE_DIMN_V SITE
where CAL.calendar_id = -1
  AND FACT.Time_Id = CAL.Time_Id
  AND FACT.Period_Type_id = CAL.Period_Type_Id
  AND REPORT_DATE IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
  AND BITAND(CAL.Record_Type_Id, &BIS_NESTED_PATTERN) = CAL.Record_Type_Id
 AND FACT.SITE_ID = SITE.ID
 '|| l_outer_where_clause ||' --4660266
GROUP BY SITE.ID, SITE.VALUE
UNION ALL
SELECT SITE.ID ID,SITE.VALUE SITE_VAL,
       NULL Visits_cur,
       NULL Visits_pre,
       NULL WEB_REGISTRATIONS_cur,
       NULL WEB_REGISTRATIONS_pre,
       NULL CARTS_cur,
       NULL CARTS_pre,
       NULL BOOKED_WEB_ORDERS_cur,
       NULL BOOKED_WEB_ORDERS_pre,
       NULL ORDERS_SITE_VISITS_cur,
       NULL ORDERS_SITE_VISITS_pre,
       NULL NEW_WEB_CUSTOMERS_cur,
       NULL NEW_WEB_CUSTOMERS_pre,
       NULL AMT_cur,
       NULL AMT_pre,
       sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,fact.TOTAL_BOOKED_ORDERS,0)) TOTAL_BOOKED_ORDERS_cur,
       sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,fact.TOTAL_BOOKED_ORDERS,0)) TOTAL_BOOKED_ORDERS_pre,
       NULL REPEAT_WEB_ORDERS_cur,
       NULL REPEAT_WEB_ORDERS_pre,
       NULL REGISTERED_CARTS_cur,
       NULL REGISTERED_CARTS_pre
from IBW_KPI_METRICS_TIME_MV  FACT ,
     FII_TIME_RPT_STRUCT_V CAL,
     IBW_BI_MSITE_DIMN_V SITE
where CAL.calendar_id = -1
  AND FACT.Time_Id = CAL.Time_Id
  AND FACT.Period_Type_id = CAL.Period_Type_Id
  AND REPORT_DATE IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
  AND BITAND(CAL.Record_Type_Id, &BIS_NESTED_PATTERN) = CAL.Record_Type_Id
 AND FACT.SITE_ID = -9999
 GROUP BY SITE.ID, SITE.VALUE
)
GROUP BY ID,SITE_VAL
)';

IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
  fnd_log.string(fnd_log.level_statement,l_full_path,'l_custom_sql2: ' || l_custom_sql2);
END IF;

    x_custom_sql  := l_custom_sql1 ||l_custom_sql2;



 x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  x_custom_output.Extend(3);

  l_custom_rec.attribute_name := ':l_currency' ;
  l_custom_rec.attribute_value:= l_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gp_currency' ;
  l_custom_rec.attribute_value:= l_gp_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gs_currency' ;
  l_custom_rec.attribute_value:= l_gs_currency;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(3) := l_custom_rec;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'End ' );
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    if gaflog_value ='Y' AND (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;

END GET_KPI_SQL;

END IBW_BI_VST_CMP_KPI_PVT;

/
