--------------------------------------------------------
--  DDL for Package Body IBW_BI_PROD_REF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_BI_PROD_REF_PVT" AS
/* $Header: ibwbrepb.pls 120.15 2006/07/21 07:10:07 gjothiku noship $ */

/**********************************************************************************************
 *  PROCEDURE   : GET_WEB_REF_SQL 																	                *
 *  PURPOSE     : This procedure is used to build the portlet query required                  *
 *                to render the Web Referral Analysis    Report.                              *
 *                                                                                            *
 *  PARAMETERS	:                                                                             *
 *		 p_param        varchar2 IN:  This is used to get the parameters              *
 *					      selected from the parameter portlet             *
 *		 x_custom_sql   varchar2 OUT  This is used to send the portlet query          *
 *		 x_cusom_output varchar2 OUT  This is used to send the bind variables         *
 *					                                                                                  *
**********************************************************************************************/

PROCEDURE GET_WEB_REF_SQL
( p_param         IN  BIS_PMV_PAGE_PARAMETER_TBL
, x_custom_sql    OUT NOCOPY VARCHAR2
, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
)
IS
--Generic Variables
  l_custom_sql      VARCHAR2(15000) ; --Final Sql.
  l_site            VARCHAR2(3200) ;  --Site Id
  l_period_type     VARCHAR2(3200) ;  --Period Type
  l_referral        VARCHAR2(3200) ; -- Referral Dimension
  l_cust_class      VARCHAR2(3200) ; -- Customer Classification
  l_currency        VARCHAR2(3200) ; -- Currency
  l_view_by         VARCHAR2(3200);  ----Either Referral category or Site
  l_from            VARCHAR2(3200) ;
  l_where           VARCHAR2(3200) ;
  l_outer_select    VARCHAR2(3000) ;
  l_inner_select    VARCHAR2(3000) ;
  l_custom_rec      BIS_QUERY_ATTRIBUTES;
  l_inner_group_by  VARCHAR2(1000);
  l_having          VARCHAR2(1000);

  --Un wanted Variables


  l_cust            VARCHAR2(3200) ;  -- Customer
  l_campaign        VARCHAR2(3200) ;  -- Campaign
  l_prod_catg       VARCHAR2(3200) ;  -- Product Category
  l_prod            VARCHAR2(3200) ;  -- Product
  l_page            VARCHAR2(3200) ;  --Page
  l_site_area       VARCHAR2(3200) ;  --Site Area

  --FND Logging
  l_full_path       VARCHAR2(50) ;
  gaflog_value      VARCHAR2(10) ;

  -- Currency  Variables
  l_gp_currency  VARCHAR2(15);	    --Global Primary Currency
  l_gs_currency  VARCHAR2(15);	    --Global Secondary Curr


  --Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level
BEGIN

  --Fetch all the Parameters into the Local Variables.
  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'begin');
  END IF;

  l_full_path := 'ibw.plsql.ibwbrepb.ref_analysis_sql'; --This would be stored in FND_LOG_MESSAGES.MODULE column
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');   --Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;

   --To get all the Page Parameters.
  IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
    (
        p_pmv_parameters  =>  p_param
      , x_period_type     =>  l_period_type    --Not Used
      , x_site            =>  l_site           --Site Id
      , x_currency_code   =>  l_currency       --Used
      , x_site_area       =>  l_site_area      --Not Used
      , x_page            =>  l_page           --Not Used
      , x_referral        =>  l_referral       --Used
      , x_prod_cat        =>  l_prod_catg      --Not Used
      , x_prod            =>  l_prod           --Not Used
      , x_cust_class      =>  l_cust_class     --Used
      , x_cust            =>  l_cust           --Not Used
      , x_campaign        =>  l_campaign       --Not Used
      , x_view_by         =>  l_view_by        --Either Site Id or Referral Category
      );

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site ||' l_site_area :  '|| l_site_area ||' l_page : '|| l_page || ' l_view_by : ' || l_view_by );
  END IF;

  --Initializing section.
  l_gp_currency        := '''FII_GLOBAL1''' ;
  l_gs_currency        := '''FII_GLOBAL2''' ;
  l_outer_select    := '';
  l_inner_select    := '';
  l_having          := '';
  l_from            := '';
  l_where           := '';
  l_inner_group_by  := '';
  l_custom_rec      :=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

 /*********************Bind Parameters used are****************************/

 /* &BIS_CURRENT_ASOF_DATE  :  AS OF DATE selected in the report          */
 /* &BIS_NESTED_PATTERN     :  Record Type Id of the Period Type selected */

  /************************************************************************/

  --The Outer Select statement is recorded in this variable.
  --Average Page View Duration := Page View Duration / Page Views

--  Not returning value for IBW_VAL2 and returning value for IBW_VAL11 as per bug # 4772549.

  l_outer_select  := '   VIEW_BY VIEWBY, VIEWBYID, '||
                     '   nvl(c_visits,0) IBW_VAL1 '||
                     '  ,nvl(p_visits,0) IBW_VAL11 '||
                     ' , DECODE(nvl(c_visits,0),0,null, (page_views/ c_visits)) IBW_VAL3 ' ||--Avg Page Views
                     ' , nvl(web_registrations,0) IBW_VAL4 ' ||
		     ' , nvl(carts,0)	        IBW_VAL5 ' ||
		     ' , nvl(a_leads,0)	        IBW_VAL6 ' ||
		     ' , DECODE(nvl(carts,0),0,null,(orders/carts)*100)                IBW_VAL7 ' ||    --Fix for Bug 4654866 - issue # 11 G
		     ' , DECODE(nvl(c_visits,0),0,null,(orders_site_visits/c_visits)*100) IBW_VAL8 ' ||   --Fix for Bug 4654866 - issue # 11 H
    	             ' , nvl(booked_amt,0) IBW_VAL9 ' ||
                     ' , DECODE(nvl(orders,0),0,null,booked_amt/orders) IBW_VAL10 ' ||
                     --For Grand Totals
                     ' , SUM(nvl(c_visits,0)) OVER() IBW_G_TOT1 ' ||
                     ' ,  DECODE(sum(nvl(p_visits,0)) over(),0,null, ((sum(c_visits) over() - sum(p_visits) over() )/ sum(p_visits) over() )*100) IBW_G_TOT2 ' || --Fix for Bug 4654866 - issue # 11 C
                     ' , DECODE(sum(nvl(c_visits,0)) over() ,0,null, (sum(page_views) over() / sum(c_visits) over() )) IBW_G_TOT3 ' ||
                     ' , SUM(nvl(web_registrations,0)) OVER() IBW_G_TOT4 '||
		     ' , SUM(nvl(carts,0)) OVER() IBW_G_TOT5 '||
		     ' , SUM(nvl(a_leads,0)) OVER() IBW_G_TOT6 '||
		     ' , DECODE(sum(nvl(carts,0)) over() ,0,null ,(SUM(orders) over() /SUM(carts) over() )*100) IBW_G_TOT7 '||  --Fix for Bug 4654866 - issue # 11 G
		     ' , DECODE(sum(nvl(c_visits,0)) over() ,0,null,(sum(orders_site_visits) over() /sum(c_visits) over())*100) IBW_G_TOT8 '|| --Fix for Bug 4654866 - issue # 11 H
		     ' , SUM(nvl(booked_amt,0)) OVER() IBW_G_TOT9 '||
		     ' , DECODE(sum(nvl(orders,0)) over() ,0,null,sum(booked_amt) over() /sum(orders) over()) IBW_G_TOT10 '
		     ;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Outer Select ');
  END IF;

  --The Inner Select statement is recorded in this variable.

   l_inner_select  := ' SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,   visits   ,0)) c_visits ' ||
		     ' ,SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,visits,0)) p_visits ' ||
                     ' , SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,  page_views ,0)) page_views ' ||
		     ' , SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,   web_registrations ,0)) web_registrations ' ||
                     ' , sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,   carts ,0)) carts ' ||
		     ' , sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,  a_leads ,0)) a_leads ' ||
                     ' , sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,  orders ,0))  orders ' ||--for  Avg Web Order Value denomenator
		     ' , sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,  orders_site_visits ,0)) orders_site_visits ' ||--for browse to buy numerator
		     ' , sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,  decode(:l_currency,:l_gp_currency,BOOKED_AMT_G,:l_gs_currency,BOOKED_AMT_G1,CURRENCY_CD_F,BOOKED_AMT_F) ,0)) booked_amt'
		      ;
--The above statement has been changed for Fix for Bug 4654866 - issue # 11 E


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Inner Select ');
  END IF;

  --The From Clause is recorded in this variable

  l_from          := ' ibw_refanalysis_time_mv ref_mv ' ||
                     ' ,fii_time_rpt_struct_v cal '||
		     ' ,ibw_bi_msite_dimn_v  site ' ||   --Fix for Bug 4654866 - issue # 11 A , 11 B
		     ' ,ibw_ref_cat_v ref_dim '||
		     ' ,fii_party_mkt_class cust_class_map '; -- This is a mapping table between customer classification and customers ( party_id )

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Initial From Clause '  );
  END IF;

  --The Where Clause is recorded in this variable.
  --This Where clause will have all the Basic Conditions to join between the IBW_REFANALYSIS_TIME_MV and the Time Dimension table
  --&BIS_CURRENT_ASOF_DATE gives the AS OF DATE selected in the report.

  l_where         := '  cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) ' || --In Condition as Compare to is present in the report.
                     ' and cal.period_type_id = ref_mv.period_type_id ' ||
                     ' and bitand(cal.record_type_id,&BIS_NESTED_PATTERN)= cal.record_type_id '||
                     ' and ref_mv.time_id = cal.time_id ' ||
                     ' and cal.calendar_id = -1 '|| --Indicates Enterprise Calendar
		     ' and ref_mv.site_id = site.id '||   --Fix for Bug 4654866 - issue #11 A , 11 B
                     ' and ref_mv.referral_category_id = ref_dim.ID  '||
		     ' and ref_mv.customer_id =cust_class_map.party_id ';

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Initial Where Clause ' );
  END IF;

  --------------------------------------------------------------------------------------------------------------


  IF l_view_by = 'IBW_REFERRAL_CATEGORY+IBW_REF_CAT' THEN --View by is Referral Category

    l_inner_select    := ' ref_dim.VALUE VIEW_BY, ref_dim.ID VIEWBYID, '||
                         l_inner_select;

   /*l_from            := l_from || ' ,ibw_ref_cat_v ref_dim ';
    l_where           := l_where || ' AND ref_mv.referral_category_id = ref_dim.ID ' ; */   --Commented for  Fix for Bug 4654866 - issue # 11 B

    l_inner_group_by  := l_inner_group_by || ' ref_dim.VALUE ,ref_dim.ID ';



  ELSIF l_view_by ='SITE+SITE' THEN --View by is Site

    l_inner_select    := ' site.value view_by, site.id viewbyid, ' || l_inner_select;

   /* l_from            := l_from || ' ,ibw_bi_msite_dimn_v site ';
    l_where           := l_where ||' and  ref_mv.site_id =site.id and ref_mv.referral_category_id is not null ';*/   --Commented for  Fix for Bug 4654866 - issue # 11 A

    l_where           := l_where ||'  and   ref_mv.referral_category_id is not null '; --added for   Fix for Bug 4654866 - issue # 11 A

    l_inner_group_by  := l_inner_group_by || '  site.value, site.id ';




  END IF; --End if for l_view_by



    IF UPPER(l_site) <> 'ALL' THEN
      l_where := l_where || ' AND ref_mv.site_id in (&SITE+SITE) ';
    END IF;

    IF UPPER(l_referral) <> 'ALL' THEN
      l_where := l_where || ' AND ref_mv.referral_category_id in  (&IBW_REFERRAL_CATEGORY+IBW_REF_CAT) ';
    END IF;


    IF UPPER(l_cust_class) <> 'ALL' THEN
  --  l_from  := l_from ||  ' ,fii_party_mkt_class cust_class_map ';
      l_where := l_where || '  and cust_class_map.class_code in (&FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS) ';
    END IF;



  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After View by Comparisons ' );
  END IF;



  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Site Id Validations ' );
  END IF;


  l_custom_sql  := ' SELECT ' || l_outer_select ||
                   ' FROM ' ||
                    ' (SELECT '   || l_inner_select ||
                    ' FROM '     || l_from ||
                    ' WHERE '    || l_where ||
                    ' GROUP BY '  || l_inner_group_by ||
                   ')' ||
             ' &ORDER_BY_CLAUSE ';

   --For Debug Purpose
   IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement,l_full_path,'The Final Query is ' || l_custom_sql);
   END IF;

   x_custom_sql := l_custom_sql; --This sql is returned back to the PMV.




   --Build the Tokens
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
END GET_WEB_REF_SQL;

PROCEDURE GET_PROD_INT_SQL
(
                            p_param           IN  BIS_PMV_PAGE_PARAMETER_TBL   ,
                            x_custom_sql    OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL  )
IS

-- Generic Variables

  l_custom_sql          VARCHAR2(15000) ; --Final Sql.
  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_site                VARCHAR2(3200);  --Site Id
  l_period_type         VARCHAR2(1000);  --Period Type
  l_prod_catg           VARCHAR2(3200); -- Product Category
  l_prod                VARCHAR2(3200); -- Product
  l_view_by             VARCHAR2(3200);
  l_from1                VARCHAR2(3200);
  l_where1               VARCHAR2(3200);
  l_from2                VARCHAR2(3200);
  l_where2               VARCHAR2(3200);
  l_group_by            VARCHAR2(1000);
  l_outer_select        VARCHAR2(3200);
  l_grand_tot_select    VARCHAR2(3200);
  l_grand_tot_from      VARCHAR2(3200);
  l_grand_tot_where      VARCHAR2(3200);
  l_outer_where         VARCHAR2(3200);
  l_inner_select1	VARCHAR2(3000) ;
  l_inner_select2	VARCHAR2(3000) ;
  l_inner_select0	VARCHAR2(3000) ;
  l_inner_group_by	VARCHAR2(1000);
  l_inner_group_by1 VARCHAR2(1000);          --- Change New Bug 5373132
  l_inner_select0_group_by  VARCHAR2(1000);
  l_having		VARCHAR2(5000);
  l_url_str_prod        VARCHAR2(5000);
  l_url_str_prodcatg    VARCHAR2(5000);

  --Un wanted Variables
  l_page                VARCHAR2(3200);  -- Page
  l_site_area           VARCHAR2(3200);  -- Site Area
  l_referral            VARCHAR2(3200);  -- Referral Dimension
  l_campaign            VARCHAR2(3200);  -- Campaign
  l_cust_class          VARCHAR2(3200);  -- Customer Classification
  l_cust                VARCHAR2(3200);  -- Customer


-- Specific Variables

  l_currency     VARCHAR2(3200) ; -- Currency
  l_gp_currency  VARCHAR2(15) := '''FII_GLOBAL1''' ; --Global Primary Currency
  l_gs_currency  VARCHAR2(15) := '''FII_GLOBAL2''' ; --Global Secondary Curr
  l_f_currency   VARCHAR2(15);   -- Functional Currency

  --FND Logging
  l_full_path   VARCHAR2(50);
  gaflog_value  VARCHAR2(10);


BEGIN


  --Fetch all the Parameters into the Local Variables.
  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'begin');
  END IF;

  l_full_path := 'ibw.plsql.ibwrepab.ref_analysis_sql'; --This would be stored in FND_LOG_MESSAGES.MODULE column
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');    --Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;


  IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
  (
    P_PMV_PARAMETERS   =>  p_param ,
    X_PERIOD_TYPE      =>  l_period_type,
    X_SITE             =>  l_site,
    X_CURRENCY_CODE    =>  l_currency,
    X_SITE_AREA        =>  l_site_area,  --Not Wanted
    X_PAGE             =>  l_page,       --Not Wanted
    X_VIEW_BY          =>  l_view_by,    --Not Wanted
    X_CAMPAIGN	       =>  l_campaign,   --Not Wanted
    X_REFERRAL         =>  l_referral,   --Not Wanted
    X_PROD_CAT         =>  l_prod_catg,  --Product Category
    X_PROD             =>  l_prod,       --Product
    X_CUST_CLASS       =>  l_cust_class, --Not Wanted
    X_CUST             =>  l_cust        --Not Wanted
  );

 IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site ||' l_site_area :  '|| l_site_area ||' l_page : '|| l_page || ' l_view_by : ' || l_view_by );
  END IF;

  l_outer_select    := '';
  l_inner_select0   := '';
  l_inner_select1    := '';
  l_inner_select2    := '';

  l_having          := '';
  l_from1            := '';
  l_where1           := '';
  l_from2            := '';
  l_where2           := '';
  l_inner_group_by  := '';
  l_inner_group_by1 := '';
  l_custom_rec      :=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  l_url_str_prod    := 'pFunctionName=IBW_BI_PRDCTINTRST_RPT&pParamIds=Y&VIEW_BY=IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM&VIEW_BY_NAME=VIEW_BY_ID';
  l_url_str_prodcatg :='pFunctionName=IBW_BI_PRDCTINTRST_RPT&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID';





  --The Outer Select statement is recorded in this variable.



  l_outer_select  := '   VIEW_BY VIEWBY, VIEWBYID,prod_descr IBW_ATTR1, nvl(page_views,0) IBW_VAL1 '||
                     ' , DECODE( nvl(visits,0),0,null, ((product_visit/ visits)*100)) IBW_VAL2 ' ||--Percent Product Visits
                     ' , nvl(duv,0) IBW_VAL3 ' ||--Daily Unique Visitor
                     ' , nvl(carts,0) IBW_VAL4 ' ||--Carts
		     ' , DECODE( nvl(carts,0),0,null, (ordered_carts/carts)*100) IBW_VAL5 ' ||--Cart Conversion
		     ' , nvl(booked_orders,0)    IBW_VAL6 ' ||
		     ' , nvl(booked_amt,0)       IBW_VAL7 ' ||
		     ' , DECODE(nvl(product_visit,0),0,null,(orders_site_visits/product_visit)*100) IBW_VAL8 ' ||--Browse to buy
           --Changes for the ER 4760433
                ' , nvl(carts,0) IBW_VAL10 ' ||
                ' , nvl(page_views,0) IBW_VAL9 '||
            --Changes for the ER 4760433
    	                 --For Grand Totals
                     ' , SUM(nvl(page_views,0)) OVER() IBW_G_TOT1 ' ||
                     ' , DECODE(nvl(visits,0),0,null, ( g_product_visit / visits )*100)  IBW_G_TOT2 ' ||
                     ' , sum(nvl(duv,0)) over() IBW_G_TOT3 ' ||
                     ' , nvl(g_carts,0) IBW_G_TOT4 '||
		     ' , DECODE( nvl(g_carts,0),0,null, (g_ordered_carts/g_carts)*100) IBW_G_TOT5 '||
		     ' , nvl(g_booked_orders,0) IBW_G_TOT6 '||
		     ' , sum(nvl(booked_amt,0)) over() IBW_G_TOT7'||
		     ' , DECODE( nvl(g_product_visit,0) ,0,null,(g_orders_site_visits/g_product_visit )*100) IBW_G_TOT8 ';




  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Outer Select ');
  END IF;


l_inner_select0  :=  '  SUM(page_views) page_views ' ||
		     ' , SUM(product_visit) product_visit ' || --Numerator for percent product visits and denominator for Browse to Buy
                     ' , SUM(visits) visits ' ||--Denominator for percent product visits
		     ' , SUM(duv) duv ' ||--Daily unique visitor
                     ' , SUM(carts)  carts ' ||--for carts and carts converesion denominator
		     ' , SUM(ordered_carts) ordered_carts ' ||--for cart conversion numerator
		     ' , SUM(booked_orders) booked_orders ' ||
		     ' , sum(booked_amt) booked_amt'||
		     ' , SUM(orders_site_visits) orders_site_visits '--Browse to buy numerator
		      ;



   --The Inner Select statement is recorded in this variable.
 l_inner_select1  := '  SUM(page_views) page_views ' ||
		     ' , count(distinct visit_id) product_visit ' || --Numerator for percent product visits and denominator for Browse to Buy
                     ' , null  visits ' ||--Denominator for percent product visits
		     ' , count(visitant_id) duv ' ||--Daily unique visitor
                     ' , count(distinct cart_id)  carts ' ||--for carts and carts converesion denominator
		     ' , count(distinct qot_order_id) ordered_carts ' ||--for cart conversion numerator
		     ' , count(distinct order_id) booked_orders ' ||
		     ' , sum(decode(:l_currency,:l_gp_currency,BOOKED_AMT_G,:l_gs_currency,BOOKED_AMT_G1,CURRENCY_CD_F,BOOKED_AMT_F)) booked_amt'||
		     ' , count(distinct orders_site_visits) orders_site_visits '--Browse to buy numerator
		      ;

l_inner_select2  := '    null page_views ' ||
		     ' , null product_visit ' || --Numerator for percent product visits and denominator for Browse to Buy
                     ' , SUM(no_visits) visits ' ||--Denominator for percent product visits
		     ' , null duv ' ||--Daily unique visitor
                     ' , null  carts ' ||--for carts and carts converesion denominator
		     ' , null ordered_carts ' ||--for cart conversion numerator
		     ' , null booked_orders ' ||
		     ' , null booked_amt'||
		     ' , null orders_site_visits '--Browse to buy numerator
		      ;



IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Inner Select ');
  END IF;

  --The From Clause is recorded in this variable

  l_from1          := ' ibw_product_time_mv prod_mv, ' ||
                      'ibw_bi_msite_dimn_v  site, ' ||
                     ' fii_time_rpt_struct_v cal ';
  l_from2          := l_from1;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Initial From Clause '  );
  END IF;

  --The Where Clause is recorded in this variable.
  --&BIS_CURRENT_ASOF_DATE gives the AS OF DATE selected in the report.

  l_where1         := ' cal.report_date = (&BIS_CURRENT_ASOF_DATE) ' ||
                     ' and cal.period_type_id = prod_mv.period_type_id ' ||
                     ' and bitand(cal.record_type_id,&BIS_NESTED_PATTERN)= cal.record_type_id '||
                     ' and prod_mv.time_id = cal.time_id ' ||
                     ' and cal.calendar_id = -1 '  ||  --Indicates Enterprise Calendar
		     ' and prod_mv.site_id = site.id ' ;

  l_where2         :=l_where1||
			' and  prod_mv.leaf_categ_id=-9999 '||
			' and  prod_mv.product_id=-9999 ';

  l_having          := ' SUM (page_views) is not null  '||
		        'or SUM (product_visit) is not null '||
			'or SUM (duv ) is not null '||
			'or SUM (carts) is not null '||
			'or SUM (ordered_carts) is not null '||
			'or SUM (booked_orders) is not null '||
			'or SUM (booked_amt) is not null '||
			'or SUM (orders_site_visits) is not null' ;


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Initial Where Clause ' );
  END IF;

  --------------------------------------------------------------------------------------------------------------
  --Fetching Site Area Name or Page Name according to the View by

  IF l_view_by ='ITEM+ENI_ITEM_VBH_CAT' THEN --View by is Prodcut Category

    l_outer_select  := l_outer_select||' , DECODE(leaf_node_flag,''Y'','||''''||l_url_str_prod||''''||','||''''||l_url_str_prodcatg||''''||' ) IBW_URL1   ';

IF UPPER(l_prod_catg) <> 'ALL' THEN
    l_inner_select1    :=  ' p.VALUE view_by, edh.imm_child_id viewbyid, '||    -- Change New  Bug 5373132
                           ' edh.leaf_node_flag  leaf_node_flag,null prod_descr , '||      ---  Change New  Bug 5373132
                         l_inner_select1;                                   -- Change New  Bug 5373132
    l_inner_select2    := ' p.value VIEW_BY, p.id  VIEWBYID, p.leaf_node_flag leaf_node_flag,null prod_descr , '||      --- Change  Bug 5373132
                         l_inner_select2;                       -- Change  Bug 5373132
ELSE
    l_inner_select1    := ' p.value VIEW_BY, p.parent_id  VIEWBYID, p.leaf_node_flag leaf_node_flag,null prod_descr , '||      ---  Change  Bug 5373132
                         l_inner_select1;                                                                                      ---  Change  Bug 5373132
    l_inner_select2    := ' p.value VIEW_BY, p.parent_id  VIEWBYID, p.leaf_node_flag leaf_node_flag,null prod_descr , '||      --- Change  Bug 5373132
                         l_inner_select2;          -- Change  Bug 5373132
END IF;


    l_inner_select0  := ' view_by,viewbyid,leaf_node_flag,prod_descr, '||l_inner_select0;

    l_inner_select0_group_by := ' view_by,viewbyid,leaf_node_flag,prod_descr ';



    l_from1            := l_from1 || ' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
    l_where1           := l_where1 || ' AND prod_mv.leaf_categ_id = edh.child_id '||
				    ' AND edh.object_type = ''CATEGORY_SET'' '||
				    ' AND edh.object_id = mdc.category_set_id '||
				    ' AND mdc.functional_area_id = 11 '||
				    ' AND edh.dbi_flag = ''Y'' '
				    ;

IF UPPER(l_prod_catg) = 'ALL' THEN                                      --- Change New  Bug 5373132
     l_where1 := l_where1 || ' AND edh.parent_id = p.child_id '||         --- Change New  Bug 5373132
            ' AND edh.top_node_flag = ''Y''';                                 --- Change New  Bug 5373132
     l_where2  := l_where2 ||                         --- Change   New  Bug 5373132
      ' AND p.top_node_flag = ''Y'' '||                -- Change    New  Bug 5373132
      ' AND p.child_id = p.parent_id ';                --- Change    New  Bug 5373132
 END IF;                                                                    --- Change  New  Bug 5373132






    IF (upper(l_prod_catg) ='ALL') THEN      /*Catgeory  equal to all*/
       l_from1            := l_from1 || ' , eni_item_prod_cat_lookup_v  p ';   -- Change  Bug 5373132

        l_from2            := l_from2  || '  , eni_item_prod_cat_lookup_v  p  ';   -- Change  Bug 5373132

  l_inner_group_by  := l_inner_group_by||'  p.value,p.parent_id,p.leaf_node_flag ';   -- Change  New  Bug 5373132

    elsif (upper(l_prod_catg) <> 'ALL') THEN /*Catgeory not equal to all*/

       l_from1            := l_from1 || ' , eni_item_prod_cat_lookup_v  p, eni_item_v item  ';   -- Change  Bug 5373132

       l_from2           := l_from2 || ' , eni_item_prod_cat_lookup_v  p ';   -- Change  Bug 5373132

  l_inner_group_by  := l_inner_group_by||' p.VALUE, edh.imm_child_id , edh.leaf_node_flag  ';   -- Change  New  Bug 5373132


    END IF;


  ELSIF l_view_by = 'IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM' THEN --View by is Product

     l_outer_select  := l_outer_select||' , null IBW_URL1 ';

    l_inner_select1    := ' item.value view_by, item.id viewbyid,item.description prod_descr , ' || l_inner_select1;

    l_inner_select2    := ' item.value view_by, item.id viewbyid,item.description prod_descr , ' || l_inner_select2;

    l_inner_select0  := ' view_by,viewbyid,prod_descr, '||l_inner_select0;

    l_inner_select0_group_by := ' view_by,viewbyid,prod_descr ';

    l_from1            := l_from1 || ' ,eni_item_v item ';
    l_where1           := l_where1 ||' and  prod_mv.product_id = item.id ';

    l_from2            := l_from2 || ' ,eni_item_v item ';
  --  l_where2           := l_where2 ||' and  prod_mv.product_id = item.id ';

    l_inner_group_by  := l_inner_group_by || '  item.value, item.id,item.description ';




  END IF; --End if for l_view_by



    IF UPPER(l_site) <> 'ALL' THEN
      l_where1  := l_where1 || ' AND prod_mv.site_id in (&SITE+SITE)';
      l_where2  := l_where2 || ' AND prod_mv.site_id in (&SITE+SITE)';
    END IF;

    IF UPPER(l_prod_catg) <> 'ALL' THEN
	IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
--           l_from1            := l_from1 || ' ,eni_item_v item,eni_item_prod_cat_lookup_v p '; --4776922     -- Change  Bug 5373132
	   l_where1           := l_where1 ||' and prod_mv.product_id = item.ID '||
--					 ' and item.vbh_category_id=p.child_id '||
             ' AND p.id = edh.imm_child_id '||                     -- Change Bug 5373132
             ' AND p.ID = p.child_id '||                           -- Change Bug 5373132
             ' AND ((p.leaf_node_flag = ''N'' AND p.parent_id <> p.ID) '||     -- Change Bug 5373132
             '    OR p.leaf_node_flag = ''Y''  '||                        -- Change Bug 5373132
             '    )  '||                                       -- Change Bug 5373132
					  ' and p.parent_id =(&ITEM+ENI_ITEM_VBH_CAT)'||   -- Change Bug 5373132
            ' AND p.parent_id = edh.parent_id ';            -- Change Bug 5373132


      l_where2 := l_where2 ||                -- Change  New Bug 5373132
      ' AND p.ID = p.child_id  '||                  -- Change  New Bug 5373132
      ' AND (   (    p.leaf_node_flag = ''N'' '||      -- Change  New Bug 5373132
      ' AND p.parent_id <> p.ID '||                    -- Change  New Bug 5373132
      ' ) '||                                            -- Change  New Bug 5373132
      ' OR p.leaf_node_flag = ''Y'' '||                    -- Change  New Bug 5373132
      ' ) '||                                       -- Change Bug 5373132
					  ' and p.parent_id =(&ITEM+ENI_ITEM_VBH_CAT)';  -- Change Bug 5373132


	ELSIF (l_view_by ='IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM' ) THEN
	   l_from1            := l_from1 || ' ,eni_item_prod_cat_lookup_v p '; --4776922
	   l_where1           := l_where1 ||' and item.vbh_category_id=p.child_id '||
					  ' and p.parent_id =(&ITEM+ENI_ITEM_VBH_CAT)';

	END IF;

    END IF;


    IF UPPER(l_prod) <> 'ALL' THEN
     l_where1 := l_where1 || ' and prod_mv.product_id = (&IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM)';
  --   l_where2  := l_where2 || ' AND prod_mv.product_id = (&IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM)';
    END IF;



  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After View by Comparisons ' );
  END IF;



  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Site Id Validations ' );
  END IF;



  --Grand Total Logic
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

l_grand_tot_select := 	'  count(distinct visit_id) g_product_visit ' || --Numerator for percent product visits and denominator for Browse to Buy
                     ' , count(visitant_id)  g_duv ' ||--Daily unique visitor
                     ' , count(distinct cart_id)   g_carts ' ||--for carts and carts converesion denominator
		     ' , count(distinct qot_order_id)  g_ordered_carts ' ||--for cart conversion numerator
		     ' , count(distinct order_id)  g_booked_orders ' ||
		     ' , count(distinct orders_site_visits)  g_orders_site_visits '; --Browse to buy numerator

l_grand_tot_from :=' ibw_product_time_mv prod_mv, ' ||
                     'ibw_bi_msite_dimn_v  site,  ' ||
                     ' fii_time_rpt_struct_v cal, ' ||
		     ' eni_denorm_hierarchies edh, '||
		     ' mtl_default_category_sets mdc ';

l_grand_tot_where  := ' cal.report_date = (&BIS_CURRENT_ASOF_DATE) ' ||
                     ' and cal.period_type_id = prod_mv.period_type_id ' ||
                     ' and bitand(cal.record_type_id,&BIS_NESTED_PATTERN)= cal.record_type_id '||
                     ' and prod_mv.time_id = cal.time_id ' ||
                     ' and cal.calendar_id = -1 '  ||  --Indicates Enterprise Calendar
		     ' and prod_mv.site_id = site.id ' ||
 		     ' AND prod_mv.leaf_categ_id = edh.child_id '||----
		     ' AND edh.object_type = ''CATEGORY_SET'' '||
		     ' AND edh.object_id = mdc.category_set_id '||
		     ' AND mdc.functional_area_id = 11 '||
		     ' AND edh.dbi_flag = ''Y'' '||
--		     ' AND edh.parent_id = p.id '||                      -- Change Bug 5373132
         ' AND p.id = edh.imm_child_id '||                     -- Change Bug 5373132
         ' AND p.ID = p.child_id  '||                          -- Change Bug 5373132
         ' AND ((p.leaf_node_flag = ''N'' AND p.parent_id <> p.ID) '||     -- Change Bug 5373132
         '   OR p.leaf_node_flag = ''Y'' '||                         -- Change Bug 5373132
         '   )  '    ;


    IF (upper(l_prod_catg) ='ALL') THEN
          l_grand_tot_from   := l_grand_tot_from ||' , eni_item_prod_cat_lookup_v  p ';		   -- Change Bug 5373132

    else
--	        l_grand_tot_from   := l_grand_tot_from || ' , eni_item_prod_cat_lookup_v  p ';		   -- Change Bug 5373132
            null;   -- Change

    end if;

     IF UPPER(l_site) <> 'ALL' THEN
	 l_grand_tot_where    := l_grand_tot_where   || ' AND prod_mv.site_id in (&SITE+SITE) ';
     END IF;

     IF UPPER(l_prod_catg) <> 'ALL' THEN
	 l_grand_tot_from            := l_grand_tot_from  || ' ,eni_item_v item,eni_item_prod_cat_lookup_v p '; --4776922
	 l_grand_tot_where           := l_grand_tot_where ||' and prod_mv.product_id = item.ID '||
--					  ' and item.vbh_category_id=p.child_id '||          -- Change
					  ' and p.parent_id =(&ITEM+ENI_ITEM_VBH_CAT)';
     end if;

     IF UPPER(l_prod) <> 'ALL' THEN
	l_grand_tot_where   := l_grand_tot_where   || ' and prod_mv.product_id = (&IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM)';
     END IF;



IF l_view_by ='ITEM+ENI_ITEM_VBH_CAT' THEN    -- Change New Bug 5373132
   if (upper(l_prod_catg) <> 'ALL')   THEN    -- Change New Bug 5373132
       l_inner_group_by1 := ' p.VALUE, p.id, p.leaf_node_flag ';    -- Change New  Bug 5373132
   ELSE                                                         -- Change New Bug 5373132
       l_inner_group_by1 := l_inner_group_by;                   -- Change New Bug 5373132
   END if;                                               -- Change New Bug 5373132
ELSE                                                      -- Change New Bug 5373132
        l_inner_group_by1 := l_inner_group_by;           -- Change New Bug 5373132
END if;                                                  -- Change New Bug 5373132








  l_custom_sql  := ' SELECT ' || l_outer_select ||
                   ' FROM ' ||
		    ' ( SELECT '|| l_inner_select0 ||
		    ' FROM '||
                    ' (SELECT '   || l_inner_select1 ||
                    ' FROM '     || l_from1 ||
                    ' WHERE '    || l_where1 ||
                    ' GROUP BY '  || l_inner_group_by ||
		    ' UNION ALL ' ||
		    ' SELECT  '   || l_inner_select2 ||
		     ' FROM '     || l_from2 ||
		     ' WHERE '    || l_where2 ||
		     ' GROUP BY '  || l_inner_group_by1 ||          --- Change Bug 5373132
                   ')' ||
		   ' GROUP BY '|| l_inner_select0_group_by ||
		   ' HAVING ' || l_having ||' ), ( '||
		   ' SELECT '|| l_grand_tot_select ||--SELECT CALUSE FOR GRAND TOTAL RETRICES ONE ROW
		   ' FROM   '|| l_grand_tot_from ||
		   ' WHERE '|| l_grand_tot_where ||
		   ' ) ' ||
             ' &ORDER_BY_CLAUSE ';

   --For Debug Purpose
   IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement,l_full_path,'The Final Query is ' || l_custom_sql);
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


EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;

END GET_PROD_INT_SQL;


END IBW_BI_PROD_REF_PVT;

/
