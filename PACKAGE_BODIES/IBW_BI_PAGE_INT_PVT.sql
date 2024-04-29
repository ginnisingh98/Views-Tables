--------------------------------------------------------
--  DDL for Package Body IBW_BI_PAGE_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_BI_PAGE_INT_PVT" AS
/* $Header: ibwbpagb.pls 120.19 2006/02/24 06:08 gjothiku noship $ */
/**********************************************************************************************
 *  PROCEDURE   : GET_PAGE_INT_SQL 															          		                *
 *  PURPOSE     : This procedure is used to build the portlet query required                  *
 *                to render the Page Interest Report.                                         *
 *                                                                                            *
 *	PARAMETERS	:                                                                             *
 *					 p_param        varchar2 IN:  This is used to get the parameters                  *
 *                                         selected from the parameter portlet                *
 *					 x_custom_sql   varchar2 OUT  This is used to send the portlet query              *
 *					 x_cusom_output varchar2 OUT  This is used to send the bind variables             *
 *					                                                                                  *
**********************************************************************************************/

PROCEDURE get_page_int_sql
( p_param         IN  BIS_PMV_PAGE_PARAMETER_TBL
, x_custom_sql    OUT NOCOPY VARCHAR2
, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
)
IS
--Generic Variables
  l_custom_sql      VARCHAR2(15000) ; --Final Sql.
  l_site            VARCHAR2(3200) ;  --Site Id
  l_period_type     VARCHAR2(3200) ;  --Period Type
  l_page            VARCHAR2(3200) ;  -- Page
  l_site_area       VARCHAR2(3200) ;  -- Site Area
  l_view_by         VARCHAR2(3200);   ----Either Site Area Name or Page Name
  l_from            VARCHAR2(3200) ;
  l_where           VARCHAR2(3200) ;
  l_outer_select    VARCHAR2(3000) ;
	l_middle_select  VARCHAR2(3000);
  l_inner_select    VARCHAR2(3000) ;
		l_inner_select_sec VARCHAR2(3000);
	l_inner_from         VARCHAR2(3200);
  l_inner_where       VARCHAR2(3200);
	l_inner_group_by_sec VARCHAR2(3200);
	l_grouping_id_inner NUMBER;
	l_middle_where    VARCHAR2(3000);
	l_select_1 VARCHAR2(3000);
	l_where_1 VARCHAR2(3000);
	l_group_by_1 VARCHAR2(3000);
	l_having_1 VARCHAR2(3000);
	l_second_select   VARCHAR2(3000);
	l_second_group_by VARCHAR2(3000);
	l_third_select  VARCHAR2(3000);
	l_third_group_by  VARCHAR2(3000);
	l_select_3  VARCHAR2(3000);
	l_from_3  VARCHAR2(3000);
	l_where_3  VARCHAR2(3000);
	l_group_by_3  VARCHAR2(3000);
	l_select_2  VARCHAR2(3000);
	l_from_2  VARCHAR2(3000);
	l_where_2  VARCHAR2(3000);
	l_group_by_2  VARCHAR2(3000);
	l_select_q1 VARCHAR2(3000);
	l_from_q1    VARCHAR2(3000);
	l_where_q1 VARCHAR2(3000);
	l_group_by_q1 VARCHAR2(3000);
	l_select_q2 VARCHAR2(3000);
	l_from_q2 VARCHAR2(3000);
	l_where_q2 VARCHAR2(3000);
	l_group_by_q2 VARCHAR2(3000);


  l_custom_rec      BIS_QUERY_ATTRIBUTES;
  l_inner_group_by  VARCHAR2(3200);
  l_having          VARCHAR2(3200);
  l_grouping_id     NUMBER;


  --Un wanted Variables
  l_referral        VARCHAR2(3200) ; -- Referral Dimension
  l_cust_class      VARCHAR2(3200) ; -- Customer Classification
  l_cust            VARCHAR2(3200) ; -- Customer
  l_campaign        VARCHAR2(3200) ; -- Campaign
  l_currency        VARCHAR2(3200) ; -- Currency
  l_prod_catg       VARCHAR2(3200) ; -- Product Category
  l_prod            VARCHAR2(3200) ; -- Product

  --FND Logging
  l_full_path       VARCHAR2(50) ;
  gaflog_value      VARCHAR2(10) ;
  --Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level
BEGIN

  --Fetch all the Parameters into the Local Variables.
  l_full_path := 'ibw.plsql.ibwrepab.page_int_nontrend_sql'; --This would be stored in FND_LOG_MESSAGES.MODULE column
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');        --Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'begin');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;

   --To get all the Page Parameters.
  IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
    (
        p_pmv_parameters  =>  p_param
      , x_period_type     =>  l_period_type    --Not Used
      , x_site            =>  l_site           --Site Id
      , x_currency_code   =>  l_currency       --Not used
      , x_site_area       =>  l_site_area      --Site Area Id
      , x_page            =>  l_page           --Page instance  Id
      , x_referral        =>  l_referral       --Not Used
      , x_prod_cat        =>  l_prod_catg      --Not Used
      , x_prod            =>  l_prod           --Not Used
      , x_cust_class      =>  l_cust_class     --Not Used
      , x_cust            =>  l_cust           --Not Used
      , x_campaign        =>  l_campaign       --Not Used
      , x_view_by         =>  l_view_by        --Either Site Area or Page
      );

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site ||' l_site_area :  '|| l_site_area ||' l_page : '|| l_page || ' l_view_by : ' || l_view_by );
  END IF;

  --Initializing all the values to Null.
  l_custom_sql      := '';
  l_outer_select    := '';
	l_middle_select := '';
  l_inner_select    := '';
  l_having          := '';
  l_from            := '';
  l_where           := '';
	l_middle_where := '';
  l_inner_group_by  := '';

	l_inner_select_sec :='';
	l_inner_from         :='';
  l_inner_where       :='';
	l_inner_group_by_sec :='';
	l_select_1 :='';
	l_where_1 := '';
	l_group_by_1 := '';
	l_having_1 := '';
	l_select_q1 :='';
	l_from_q1    :='';
	l_where_q1 :='';
	l_group_by_q1 :='';
	l_select_q2 :='';
	l_from_q2 :='';
	l_where_q2 :='';
	l_group_by_q2 :='';
	l_second_select :='' ;
	l_second_group_by := '';
	l_select_2  :='';
	l_from_2  :='' ;
	l_where_2  :='' ;
	l_group_by_2  :='' ;
	l_third_select  :='' ;
	l_third_group_by :='' ;
	l_select_3  :='' ;
	l_from_3  :='' ;
	l_where_3  :='' ;
	l_group_by_3  :='' ;

	  l_custom_rec      :=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  --------------------------------------------------------------------------------------------------------------
  /********************Metrics in Page Interest Report*********************/
 /* IBW_VAL1                  : Page Views                                */
 /* IBW_VAL2                  : Average Page View Duration					      */
 /* IBW_VAL3                  : Daily Unique Visitors                     */
 /* IBW_VAL4                  : Visits					                          */
 /* IBW_G_TOT1                : Sum of Page Views                         */
 /* IBW_G_TOT2                : Sum of Average Page View Duration         */
 /* IBW_G_TOT3                : Sum of Daily Unique Visitors              */
 /* IBW_G_TOT4                : Sum of Visits                             */
 /*********************Bind Parameters used are****************************/

 /* &BIS_CURRENT_ASOF_DATE  :  AS OF DATE selected in the report          */
 /* &BIS_NESTED_PATTERN     :  Record Type Id of the Period Type selected */

  /************************************************************************/

  --The Outer Select statement is recorded in this variable.
  --Average Page View Duration := Page View Duration / Page Views




  l_outer_select  := ' nvl(page_views,0) IBW_VAL1 '||
                     --If Page Views is Zero then Null is returned otherwise a Zero Divide would occur.
                     ' , DECODE(nvl(page_views,0),0,null, nvl(page_view_duration,0)/page_views) IBW_VAL2 ' ||
                     ' , nvl(daily_un_visitors,0) IBW_VAL3 ' ||
                     ' , nvl(visits,0) IBW_VAL4 ' ||
                     -- Added on 30/11/2005 for Bug# 4763103 Issue# 3
                     ' , DECODE(nvl(page_views,0),0,null, nvl(page_view_duration,0)/page_views) IBW_VAL5 ' ||
                     ' , nvl(page_views,0) IBW_VAL6 '||
                     --For Grand Totals
                     ' , SUM(nvl(page_views,0)) OVER() IBW_G_TOT1 ' ||
                     ' , DECODE(SUM(nvl(page_views,0)) OVER(),0,NULL,(SUM(PAGE_VIEW_DURATION) OVER()/ SUM(PAGE_VIEWS) OVER() )) IBW_G_TOT2 ' ;


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Outer Select ');
  END IF;

	l_middle_select := 'inner1.*'||
		',inner2.daily_unique_visitor_gt daily_unique_visitor_gt'||
		',inner3.visits_gt visits_gt';

  --The Inner Select statement is recorded in this variable.
  --Count(Distinct) is used as Daily Unique Visitors and Visits are non-additive measures across Site Area and Page



  l_inner_select  := ' NVL(SUM(page_views),0) page_views ' ||
                     ' , NVL(SUM(page_view_duration/60000),0) page_view_duration ' || --Milli Seconds converted into Minutes
                     ' , COUNT(DISTINCT(visitant_id)) daily_un_visitors ' ||
                     ' , COUNT(DISTINCT(visit_id)) visits ' ;

  --The Having Clause is required to ensure that those rows are filtered where all the Metrics are Zero.
  l_having        := ' NVL(SUM(page_views),0) > 0 ' ||
                     ' OR     NVL(SUM(page_view_duration/60000),0) > 0 ' ||
                     ' OR     COUNT(DISTINCT(visitant_id)) > 0 ' ||
                     ' OR     COUNT(DISTINCT(visit_id)) > 0 ' ;


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Inner Select ');
  END IF;

  --The From Clause is recorded in this variable
  --The MV : IBW_PAGE_SA_TIME_MV is the Top Level MV built for Page Interest Reports


  l_from          := ' IBW_PAGE_SA_TIME_MV PAGE_SA_MV, ' ||
                     ' FII_TIME_RPT_STRUCT_V CAL, ' ;



  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Initial From Clause '  );
  END IF;

  --The Where Clause is recorded in this variable.
  --This Where clause will have all the Basic Conditions to join between the PAGE_SA_MV and the Time Dimension table
  --&BIS_CURRENT_ASOF_DATE gives the AS OF DATE selected in the report.



  l_where         := ' CAL.report_date = &BIS_CURRENT_ASOF_DATE ' || --Equal Condition as Compare to is not present in the report.
                     ' AND CAL.period_type_id = PAGE_SA_MV.period_type_id ' ||
                     ' AND BITAND(CAL.RECORD_TYPE_ID,&BIS_NESTED_PATTERN)= CAL.RECORD_TYPE_ID '||
                     ' AND PAGE_SA_MV.TIME_ID = CAL.TIME_ID ' ||
                     ' AND CAL.CALENDAR_ID = -1 '; --Indicates Enterprise Calendar




  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Initial Where Clause ' );
  END IF;

  --This is to Assign respective grouping id for each of the view bys so that the appropriate records are picked up.
  IF l_view_by = 'IBW_PAGE+IBW_PAGES' THEN
    l_grouping_id := 0; --0 Indicates Grouping Set Id for Page
		l_grouping_id_inner := 8;
  ELSIF l_view_by = 'IBW_PAGE+IBW_SITE_AREAS' THEN
	    l_grouping_id_inner := 8;
	 IF upper(l_page ) ='ALL' THEN   --Included this IF condition so that data is fetched when viewed by sitearea and selecting a site area
       l_grouping_id := 8; --8 Indicates Grouping Set Id for Site Area
		else
		   l_grouping_id := 0; --0 Indicates Grouping Set Id for Page
 END IF ;
  END IF;



    l_select_1 := ' Q1.SITE_AREA_ID SITE_AREA_ID,Q1.PAGE_INSTANCE_ID PAGE_INSTANCE_ID,Q1.VIEW_BY VIEW_BY, Q1.VIEWBYID VIEWBYID ';

		l_where_1 := ' Q1.SITE_AREA_ID=Q2.SITE_AREA_ID   AND  Q1.VIEW_BY=Q2.VIEW_BY  '||
                       		  ' AND Q1.VIEWBYID=Q2.VIEWBYID ' ;
    IF l_grouping_id = 0 THEN
		  l_where_1 := l_where_1||' AND Q1.PAGE_INSTANCE_ID = Q2.PAGE_INSTANCE_ID ';
   END IF;

    l_group_by_1 := ' Q1.SITE_AREA_ID , Q1.PAGE_INSTANCE_ID , Q1.VIEW_BY , Q1.VIEWBYID ';

    l_having_1 := ' NVL (SUM (q1.page_views), 0) > 0  OR NVL (SUM (q1.page_view_duration / 60000), 0) > 0 ';





	  l_select_q1 :='PAGE_SA_MV.SITE_AREA_ID SITE_AREA_ID , 	PAGE_SA_MV.PAGE_INSTANCE_ID ' ;



		 l_from_q1 := 'IBW_PAGE_SA_TIME_MV PAGE_SA_MV,  FII_TIME_RPT_STRUCT_V CAL, IBW_BI_MSITE_DIMN_V SITE ';



    l_where_q1          := l_where || '  AND PAGE_SA_MV.GROUPING_SETS_ID = :l_grouping_id ';

		 IF UPPER(l_site) <> 'ALL'  THEN
    l_where_q1 := l_where_q1 || ' AND PAGE_SA_MV.SITE_ID IN (&SITE+SITE) '  || '  AND PAGE_SA_MV.SITE_ID = SITE.ID ';
		l_where_2  := l_where || ' AND PAGE_SA_MV.SITE_ID IN (&SITE+SITE) '  || '  AND PAGE_SA_MV.SITE_ID = SITE.ID ';
		l_where_3  := l_where || ' AND PAGE_SA_MV.SITE_ID IN (&SITE+SITE) '  || '  AND PAGE_SA_MV.SITE_ID = SITE.ID ';
		else
		 l_where_q1 := l_where_q1 || ' AND PAGE_SA_MV.SITE_ID = SITE.ID ';
		 l_where_2 := l_where || ' AND PAGE_SA_MV.SITE_ID = SITE.ID ';
		 l_where_3 := l_where || ' AND PAGE_SA_MV.SITE_ID = SITE.ID ';
		 END IF;




    l_group_by_q1  := l_group_by_q1 || ' PAGE_SA_MV.SITE_AREA_ID,PAGE_SA_MV.PAGE_INSTANCE_ID ';




  l_select_q2 := ' PAGE_SA_MV.SITE_AREA_ID SITE_AREA_ID,  PAGE_SA_MV.PAGE_INSTANCE_ID';


    IF UPPER(l_page) <> 'ALL' THEN
      l_where_q1 := l_where_q1 || ' AND PAGE_SA_MV.PAGE_INSTANCE_ID = (&IBW_PAGE+IBW_PAGES)';--Equality condition as Page is Single Select
    END IF;


    IF UPPER(l_site_area) <> 'ALL' THEN
      l_where_q1 := l_where_q1 || '  AND PAGE_SA_MV.SITE_AREA_ID = (&IBW_PAGE+IBW_SITE_AREAS) ' ;
			l_where_2 := l_where_2 ||  '  AND PAGE_SA_MV.SITE_AREA_ID = (&IBW_PAGE+IBW_SITE_AREAS) ' ;
			l_where_3 := l_where_3 ||  '  AND PAGE_SA_MV.SITE_AREA_ID = (&IBW_PAGE+IBW_SITE_AREAS) ' ;
	  END IF;




IF upper(l_page ) ='ALL' THEN
      l_second_select :=  ' SUM(DAILY_UNIQUE_VISITOR_GT) DAILY_UNIQUE_VISITOR_GT ';
			l_third_select := ' SUM(VISITS_GT) VISITS_GT ';
			l_select_2  := ' COUNT ( DISTINCT VISITANT_ID )  DAILY_UNIQUE_VISITOR_GT ';
			l_select_3 := ' COUNT ( DISTINCT VISIT_ID )  VISITS_GT ';
			l_from_2 := '  IBW_PAGE_SA_TIME_MV PAGE_SA_MV , FII_TIME_RPT_STRUCT_V CAL, IBW_BI_MSITE_DIMN_V SITE ';
      l_from_3 := l_from_2;
			l_where_2 := l_where_2|| '  AND PAGE_SA_MV.GROUPING_SETS_ID = :l_grouping_id_inner ';
			l_where_3 := l_where_3|| '  AND PAGE_SA_MV.GROUPING_SETS_ID = :l_grouping_id_inner ';
			l_group_by_2 := ' TRANSACTION_DATE';
			l_middle_where := ' INNER1.DAILY_UN_VISITORS>0 OR INNER1.VISITS>0 ';
     IF UPPER(l_site_area) <> 'ALL' THEN
        l_second_select := ' SITE_AREA_ID , '||l_second_select;
        l_third_select := ' SITE_AREA_ID , '||l_third_select;
				l_select_2   := ' SITE_AREA_ID , '||l_select_2;
				l_select_3   := ' SITE_AREA_ID , '||l_select_3;
				l_group_by_3 := ' SITE_AREA_ID ';
				l_second_group_by := '  SITE_AREA_ID ';
				l_third_group_by := ' SITE_AREA_ID ';
				l_middle_where :=  ' INNER1.SITE_AREA_ID=INNER2.SITE_AREA_ID AND 	INNER1.SITE_AREA_ID=INNER3.SITE_AREA_ID AND '||l_middle_where;
				l_group_by_2 :=  l_group_by_2 || ' , SITE_AREA_ID ';   -- Fix for Issue #23 in Bug #4702283
     END IF;
END IF;




  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'The value of l_grouping_id ' || l_grouping_id );
  END IF;

  --Fetching Site Area Name or Page Name according to the View by

  IF l_view_by = 'IBW_PAGE+IBW_PAGES' THEN --View by is Page

    -- Business Context stores either PRODUCT, SECTION or NONE and  CONTEXT_INSTANCE_CODE will have the
    --Product Code(Inventory Item Code - Master Inventory Org Code - Child Inventory Org Code) or the Section Code

     --Changed for Bug#:4776957
     --l_outer_select    := ' VIEW_BY VIEWBY, VIEWBYID, INITCAP(NULLIF(BUSINESS_CONTEXT,''NONE'')) IBW_ATTR1, CONTEXT_INSTANCE_CODE IBW_ATTR2, ' || l_outer_select;
     l_outer_select    := ' VIEW_BY VIEWBY, VIEWBYID, ' ||
                          ' NULLIF(MEANING , ' ||
                                   '(SELECT MEANING FROM FND_LOOKUP_VALUES LOOKUP2 ' ||
                                   ' WHERE LOOKUP2.LOOKUP_TYPE = ''IBW_BUSINESS_CONTEXT'' '||
                                   ' AND LOOKUP2.LOOKUP_CODE   = ''NONE''' ||
                                   ' AND LOOKUP2.LANGUAGE      = USERENV(''LANG'') ' ||
                          ')) IBW_ATTR1 , ' ||
                          ' CONTEXT_INSTANCE_CODE IBW_ATTR2, ' || l_outer_select;

     --Changed for Bug#:4776957
		l_select_q1 := l_select_q1|| '  , PAGE.VALUE VIEW_BY , PAGE.ID VIEWBYID, '||
                             'PAGE.BUSINESS_CONTEXT BUSINESS_CONTEXT, PAGE.CONTEXT_INSTANCE_CODE CONTEXT_INSTANCE_CODE, ' ||
                             'LOOKUP.MEANING';
     --Changed for Bug#:4776957
    l_select_q2 := l_select_q2||' ,  PAGE.VALUE VIEW_BY, PAGE.ID VIEWBYID, '||
                            'PAGE.BUSINESS_CONTEXT BUSINESS_CONTEXT, PAGE.CONTEXT_INSTANCE_CODE CONTEXT_INSTANCE_CODE, ' ||
                            'LOOKUP.MEANING';

     --Changed for Bug#:4776957
     --l_from_q1  := l_from_q1 || ' ,   IBW_PAGE_V PAGE ';
     l_from_q1  := l_from_q1 || ' ,   IBW_PAGE_V PAGE, FND_LOOKUP_VALUES LOOKUP ';

     --Changed for Bug#:4776957

		 --l_where_q1 := l_where_q1|| ' AND PAGE_SA_MV.PAGE_INSTANCE_ID = PAGE.ID '  ;
     l_where_q1 := l_where_q1|| ' AND PAGE_SA_MV.PAGE_INSTANCE_ID = PAGE.ID '  ||
                                ' AND PAGE.BUSINESS_CONTEXT  = LOOKUP.LOOKUP_CODE '||
                                ' AND LOOKUP.LANGUAGE  = USERENV(''LANG'') ' ||
                                ' AND LOOKUP.LOOKUP_TYPE = ''IBW_BUSINESS_CONTEXT''' ;

		 l_where_1 := l_where_1||' AND Q1.BUSINESS_CONTEXT=Q2.BUSINESS_CONTEXT ';--  AND Q1.CONTEXT_INSTANCE_CODE=Q2.CONTEXT_INSTANCE_CODE ' ;

     --Changed for Bug#:4776957
		 l_group_by_q1 := l_group_by_q1||' , PAGE.VALUE ,PAGE.ID, PAGE.BUSINESS_CONTEXT, PAGE.CONTEXT_INSTANCE_CODE, ' ||
                                     '   LOOKUP.MEANING';
     --Changed for Bug#:4776957
		 l_group_by_1 := l_group_by_1||'  , Q1.BUSINESS_CONTEXT , Q1.CONTEXT_INSTANCE_CODE, ' ||
                                   ' Q1.MEANING';

     --4776957
		 l_select_1 := l_select_1 || ' , Q1.BUSINESS_CONTEXT BUSINESS_CONTEXT, Q1.CONTEXT_INSTANCE_CODE CONTEXT_INSTANCE_CODE, ' ||
                                 ' Q1.MEANING ';

     --Included NULLIF in the above statement to avoid NONE being displayed in the report.
  ELSIF l_view_by ='IBW_PAGE+IBW_SITE_AREAS' THEN --View by is Site Area

    --Display And Code columns are not shown in the report when view by is site area.
    --hence these two are assigned as Null below

    l_outer_select    := ' VIEW_BY VIEWBY, VIEWBYID, NULL IBW_ATTR1 , NULL IBW_ATTR2, ' || l_outer_select ;


     l_select_q1   := l_select_q1||' , SITE_AREA.VALUE VIEW_BY, SITE_AREA.ID  VIEWBYID ';

		 l_select_q2   := l_select_q2||' , SITE_AREA.VALUE VIEW_BY, SITE_AREA.ID  VIEWBYID ';

		  l_from_q1  := l_from_q1 || ' ,   IBW_SITE_AREA_V  SITE_AREA ';

			 l_where_q1   := l_where_q1 ||' AND PAGE_SA_MV.SITE_AREA_ID = SITE_AREA.ID ';

			 l_group_by_q1  := l_group_by_q1 || '  , SITE_AREA.VALUE, SITE_AREA.ID ';

     END IF; --End if for l_view_by

  l_select_q1 := l_select_q1||' , NVL (SUM (PAGE_VIEWS), 0) PAGE_VIEWS, '||
                             'NVL (SUM (PAGE_VIEW_DURATION / 60000), 0) PAGE_VIEW_DURATION,  NULL DAILY_UN_VISITORS,  COUNT (DISTINCT (VISIT_ID)) VISITS ';

  l_select_q2 := l_select_q2|| ' , NULL PAGE_VIEWS, '||
                            ' NULL PAGE_VIEW_DURATION, COUNT ( DISTINCT (VISITANT_ID)) DAILY_UN_VISITORS, NULL VISITS' ;

  l_select_1 := l_select_1|| ' , Q1.PAGE_VIEWS PAGE_VIEWS, '||
                             'Q1.PAGE_VIEW_DURATION PAGE_VIEW_DURATION, SUM(Q2.DAILY_UN_VISITORS) DAILY_UN_VISITORS,  Q1.VISITS VISITS ';

  l_where_q2 := l_where_q1;

	l_group_by_1 := l_group_by_1||  '  , Q1.PAGE_VIEWS , Q1.PAGE_VIEW_DURATION  ,Q1.VISITS ';


	l_group_by_q2  := ' PAGE_SA_MV.TRANSACTION_DATE,  ' ||l_group_by_q1;

 	IF upper(l_page ) ='ALL' THEN
		    l_outer_select    :=  l_outer_select|| ' , DAILY_UNIQUE_VISITOR_GT IBW_G_TOT3 ' ||' , VISITS_GT  IBW_G_TOT4 ';
	ELSE
		   l_outer_select    :=l_outer_select||'  , DAILY_UN_VISITORS IBW_G_TOT3, VISITS IBW_G_TOT4 ';
  END IF;


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After View by Comparisons ' );
  END IF;

  --------------------------------------------------------------------------------------------------------------
  --Site Id Validation
  IF UPPER(l_site) <> 'ALL' THEN --TBC
    l_where := l_where || ' AND PAGE_SA_MV.SITE_ID IN (&SITE+SITE) ' ; --In condition as Site is Multi Select
		IF upper(l_page ) ='ALL' THEN
		l_inner_where := l_inner_where|| ' AND PAGE_SA_MV.SITE_ID IN (&SITE+SITE) ' ;
		END IF;
  ELSE
    l_from  := l_from || ', IBW_BI_MSITE_DIMN_V SITE';
    l_where := l_where || ' AND PAGE_SA_MV.SITE_ID = SITE.ID ';
		IF upper(l_page ) ='ALL' THEN
		l_inner_where := l_inner_where|| ' AND PAGE_SA_MV.SITE_ID = SITE.ID ';
		l_inner_from := l_inner_from|| ', IBW_BI_MSITE_DIMN_V SITE';
		END IF;
  END IF; --End if for l_site
    --------------------------------------------------------------------------------------------------------------
   --Validation of values if selected in Page and Site Area Dimension.

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'After Site Id Validations ' );
  END IF;

  IF upper(l_page ) ='ALL' THEN
	   IF UPPER(l_site_area) <> 'ALL' THEN
	   l_custom_sql := 'SELECT ' || l_outer_select ||
		                               ' FROM ' ||
                                   ' (SELECT '   || l_middle_select ||
																	    ' FROM ' ||
 																	 ' (SELECT '   || l_select_1 ||
																	    ' FROM '     ||
                                   ' (SELECT '   || l_select_q1 ||
																	    ' FROM  '     || l_from_q1||
                                      ' WHERE '    || l_where_q1 ||
                                     ' GROUP BY '  || l_group_by_q1 ||' )  q1 , '||
                                   ' (SELECT '   || l_select_q2 ||
																	    ' FROM  '     || l_from_q1||
                                      ' WHERE '    || l_where_q2 ||
                                     ' GROUP BY '  || l_group_by_q2 ||' )  q2  '||
																		 ' WHERE '|| l_where_1||
                                      ' GROUP BY '  || l_group_by_1 ||
																			' HAVING '|| l_having_1|| ' )  inner1 , '||
                                     ' (SELECT '   || l_second_select ||
																	    ' FROM ' ||
																			' (SELECT '   || l_select_2 ||
																	    ' FROM  '     || l_from_2||
                                      ' WHERE '    || l_where_2 ||
                                     ' GROUP BY '  || l_group_by_2 ||' ) '||
																		  ' GROUP BY '  || l_second_group_by ||' ) inner2 , '||
                                       ' (SELECT '   || l_third_select ||
																	    ' FROM ' ||
																			' (SELECT '   || l_select_3 ||
																	    ' FROM  '     || l_from_3||
                                      ' WHERE '    || l_where_3 ||
                                     ' GROUP BY '  || l_group_by_3 ||' ) '||
																		 ' GROUP BY '  || l_third_group_by ||' ) inner3 ' ||
																		 '  WHERE ' || l_middle_where ||' ) '||
																			 ' &ORDER_BY_CLAUSE ';
      ELSE
			   l_custom_sql := 'SELECT ' || l_outer_select ||
		                               ' FROM ' ||
                                   ' (SELECT '   || l_middle_select ||
																	    ' FROM ' ||
 																	 ' (SELECT '   || l_select_1 ||
																	    ' FROM '     ||
                                   ' (SELECT '   || l_select_q1 ||
																	    ' FROM  '     || l_from_q1||
                                      ' WHERE '    || l_where_q1 ||
                                     ' GROUP BY '  || l_group_by_q1 ||' )  q1 , '||
                                   ' (SELECT '   || l_select_q2 ||
																	    ' FROM  '     || l_from_q1||
                                      ' WHERE '    || l_where_q2 ||
                                     ' GROUP BY '  || l_group_by_q2 ||' )  q2  '||
																		 ' WHERE '|| l_where_1||
                                      ' GROUP BY '  || l_group_by_1 ||
																			' HAVING '|| l_having_1|| ' )  inner1 , '||
                                     ' (SELECT '   || l_second_select ||
																	    ' FROM ' ||
																			' (SELECT '   || l_select_2 ||
																	    ' FROM  '     || l_from_2||
                                      ' WHERE '    || l_where_2 ||
                                     ' GROUP BY '  || l_group_by_2 ||' ) ) '||
																		  '  inner2 , '||
                                       ' (SELECT '   || l_third_select ||
																	    ' FROM ' ||
																			' (SELECT '   || l_select_3 ||
																	    ' FROM  '     || l_from_3||
                                      ' WHERE '    || l_where_3 || ' ) '||
																		  ' ) inner3 '||
																		 '  WHERE ' || l_middle_where ||' ) '||
																			 ' &ORDER_BY_CLAUSE ';


      END IF;
   ELSE
	    l_custom_sql  :=   'SELECT ' || l_outer_select ||
		                               ' FROM ' ||
                                  	 ' (SELECT '   || l_select_1 ||
																	    ' FROM '     ||
                                   ' (SELECT '   || l_select_q1 ||
																	    ' FROM  '     || l_from_q1||
                                      ' WHERE '    || l_where_q1 ||
                                     ' GROUP BY '  || l_group_by_q1 ||' )  q1 , '||
                                   ' (SELECT '   || l_select_q2 ||
																	    ' FROM  '     || l_from_q1||
                                      ' WHERE '    || l_where_q2 ||
                                     ' GROUP BY '  || l_group_by_q2 ||' )  q2  '||
																		 ' WHERE '|| l_where_1||
                                      ' GROUP BY '  || l_group_by_1 ||
																			' HAVING '|| l_having_1|| ' ) '||
                                      ' &ORDER_BY_CLAUSE ';
    END IF;




   --For Debug Purpose
   IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement,l_full_path,'The Final Query is ' || l_custom_sql);
   END IF;

   x_custom_sql := l_custom_sql; --This sql is returned back to the PMV.


   --Build the Tokens
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_custom_rec.attribute_name := ':l_grouping_id' ;
  l_custom_rec.attribute_value:= l_grouping_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;


	l_custom_rec.attribute_name := ':l_grouping_id_inner' ;
  l_custom_rec.attribute_value:= l_grouping_id_inner;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;


  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'END');
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;
END get_page_int_sql;

/**********************************************************************************************
 *  PROCEDURE   : GET_PAGE_INT_TREND_SQL												          		                *
 *  PURPOSE     : This procedure is used to build the portlet query required                  *
 *                to render the Page Interest Trend Report.                                   *
 *                                                                                            *
 *	PARAMETERS	:                                                                             *
 *					 p_param        varchar2 IN:  This is used to get the parameters                  *
 *                                         selected from the parameter portlet                *
 *					 x_custom_sql   varchar2 OUT  This is used to send the portlet query              *
 *					 x_cusom_output varchar2 OUT  This is used to send the bind variables             *
 *					                                                                                  *
**********************************************************************************************/
PROCEDURE get_page_int_trend_sql
(
   p_param           IN  BIS_PMV_PAGE_PARAMETER_TBL
   , x_custom_sql    OUT NOCOPY VARCHAR2
   , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

  --Generic Variables
  l_custom_sql      VARCHAR2(15000) ; --Final Sql.
  l_site            VARCHAR2(3200) ;  --Site Id
  l_period_type     VARCHAR2(3200) ;  --Period Type
  l_page            VARCHAR2(3200) ;  -- Page
  l_site_area       VARCHAR2(3200) ;  -- Site Area
  l_view_by         VARCHAR2(3200);   --Either Site Area Name or Page Name
  l_from            VARCHAR2(3200) ;
  l_where           VARCHAR2(3200) ;
  l_select_col_name VARCHAR2(100);
  l_custom_rec      BIS_QUERY_ATTRIBUTES;


  --Un wanted Variables
  l_referral        VARCHAR2(3200) ; -- Referral Dimension
  l_cust_class      VARCHAR2(3200) ; -- Customer Classification
  l_cust            VARCHAR2(3200) ; -- Customer
  l_campaign        VARCHAR2(3200) ; -- Campaign
  l_currency        VARCHAR2(3200) ; -- Currency
  l_prod_catg       VARCHAR2(3200) ; -- Product Category
  l_prod            VARCHAR2(3200) ; -- Product

  --FND Logging
  l_full_path       VARCHAR2(50);
  gaflog_value      VARCHAR2(10);
BEGIN

  --Profiles for FND Debugging are  : FND: Log Enabled , FND: Log Level
  l_full_path  := 'ibw.plsql.ibwrepab.page_int_nontrend_sql'; --This would be stored in FND_LOG_MESSAGES.MODULE column
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'Begin');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'Before the Call to UTL Package');
  END IF;

   --To get all the Page Parameters.
  IBW_BI_UTL_PVT.GET_PAGE_PARAMETERS
    (
        p_pmv_parameters  =>  p_param
      , x_period_type     =>  l_period_type    --Not Used
      , x_site            =>  l_site           --Site Id
      , x_currency_code   =>  l_currency       --Not used
      , x_site_area       =>  l_site_area      --Site Area Id
      , x_page            =>  l_page           --Page Id
      , x_referral        =>  l_referral       --Not Used
      , x_prod_cat        =>  l_prod_catg      --Not Used
      , x_prod            =>  l_prod           --Not Used
      , x_cust_class      =>  l_cust_class     --Not Used
      , x_cust            =>  l_cust           --Not Used
      , x_campaign        =>  l_campaign       --Not Used
      , x_view_by         =>  l_view_by        --Not Used
      );

  IF gaflog_value ='Y' AND (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_full_path,'After the Call to UTL Package');
  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,l_full_path,'l_site : ' || l_site ||' l_site_area :  '|| l_site_area ||' l_page : '|| l_page );
  END IF;

  --Initializing the variables to Null
  l_from            := '';
  l_where           := '';
  l_select_col_name := '';
  l_custom_sql      := '';
  l_custom_rec      :=  BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;


  l_from := ' IBW_PAGE_SA_TIME_MV PAGE_SA_MV, ' ||
            ' FII_TIME_RPT_STRUCT_V CAL ';

  -- Initialising where clause based on the parameter selection
  --The Where Clause is recorded in this variable.
  --This Where clause will have all the Basic Conditions to join between the PAGE_SA_MV and the Time Dimension table
  --&BIS_CURRENT_ASOF_DATE gives the AS OF DATE selected in the report.

  l_where         := ' AND CAL.period_type_id = PAGE_SA_MV.period_type_id ' || --To check  CAL.report_date = &BIS_CURRENT_ASOF_DATE  ||
                     ' AND BITAND(CAL.RECORD_TYPE_ID,&BIS_NESTED_PATTERN)= CAL.RECORD_TYPE_ID '||
                     ' AND PAGE_SA_MV.TIME_ID = CAL.TIME_ID ' ||
                     ' AND CAL.CALENDAR_ID = -1 '; --Indicates Enterprise Calendar


  --------------------------------------------------------------------------------------------------------------
  --Site Id Validation
  IF UPPER(l_site) <> 'ALL' THEN
    l_where := l_where || ' AND PAGE_SA_MV.SITE_ID IN (&SITE+SITE) ' ; --In condition as Site is Multi Select
  ELSE
    l_from  := l_from || ', IBW_BI_MSITE_DIMN_V SITE';
    l_where := l_where || ' AND PAGE_SA_MV.SITE_ID = SITE.ID ';
  END IF; --End if for l_site
  --------------------------------------------------------------------------------------------------------------
   --Page Dimension Validation
   IF UPPER(l_page) <> 'ALL' THEN
     l_where := l_where || ' AND PAGE_SA_MV.PAGE_INSTANCE_ID = (&IBW_PAGE+IBW_PAGES)';--Equality condition as Page is Single Select
   ELSE
     l_from   := l_from  || ' , IBW_PAGE_V PAGE ';
     l_where  := l_where || ' AND PAGE_SA_MV.PAGE_INSTANCE_ID = PAGE.ID';
   END IF;

   --Site Area Validation.
   IF UPPER(l_site_area) <> 'ALL' THEN
     l_where := l_where || ' AND PAGE_SA_MV.SITE_AREA_ID = (&IBW_PAGE+IBW_SITE_AREAS)'; --Equality condition as Site Area is Single Select
		                                                                                                                                                                             --Removed Close brace as the report was erring out
   ELSE
     l_from  := l_from || ' , IBW_SITE_AREA_V SITE_AREA ';
     l_where := l_where || ' AND PAGE_SA_MV.SITE_AREA_ID = SITE_AREA . ID ';
   END IF;

  --------------------------------------------------------------------------------------------------------------
  /********************Metrics in Page Interest Report*********************/
  /* IBW_VAL7                  : Prior Page Views                          */
  /* IBW_VAL1                  : Page Views                                */
  /* IBW_VAL2                  : Change                          		       */
  /* IBW_VAL8                  : Prior Average View Duration    		       */
  /* IBW_VAL3                  : Average View Duration (minutes)           */
  /* IBW_VAL4                  : Change  				                           */
  /* IBW_VAL5                  : Daily Unique Visitors                     */
  /* IBW_VAL6                  : Visits                                    */

  /*********************Bind Parameters used are****************************/

  /* &BIS_CURRENT_ASOF_DATE  :  AS OF DATE selected in the report          */
  /* &BIS_NESTED_PATTERN     :  Record Type Id of the Period Type selected */

  /************************************************************************/


  IF l_period_type ='FII_TIME_DAY' THEN
    l_select_col_name := 'TIME_DIM.REPORT_DATE'; --In Day Dimension level Table NAME Column does not exist and hence using Report_Date Column.
  ELSE
    l_select_col_name := 'TIME_DIM.NAME';
  END IF;

  /*

  Logic for Average Page View Duration is :
     =  decode(p,0,null,(c-p)/p)

    where
    p=previous_page_duration/previous_page_views
    c=current_page_duration/current_page_views.

    ----------------------------------------------------------------------------
    Current Page Views is          - page_views_c
    Previous Page Views is         - page_views_p
    Current Page View Duration is  - page_view_duration_c
    Previous Page View Duration is - page_view_duration_p
    ----------------------------------------------------------------------------
    And this Translates to

    p=decode(page_views_p,0,null,nvl(page_view_duration_p,0)/page_views_p)
    c=decode(page_views_c,0,null,nvl(page_view_duration_c,0)/page_views_c)
    decode
           (
              decode(page_views_p,0,null,nvl(page_view_duration_p,0)/page_views_p),0,null,
              (
                decode(page_views_c,0,null,nvl(page_view_duration_c,0)/page_views_c)-
                decode(page_views_p,0,null,nvl(page_view_duration_p,0)/page_views_p)
              )
              /
              (
                decode(page_views_p,0,null,nvl(page_view_duration_p,0)/page_views_p)
              )
            )
  */


--  Not returning value for IBW_VAL2 and IBW_VAL4 as per bug # 4772549.

  l_custom_sql :=
     'SELECT
       ' || l_select_col_name || '                          VIEWBY
      , NVL(page_views_p,0)                                 IBW_VAL7 --Bug#4727078 Issue#:21
      , NVL(page_views_c,0)                                 IBW_VAL1
      , DECODE(page_views_p,null,null,0,null,
        (NVL(page_view_duration_p,0)/page_views_p))         IBW_VAL8 --Bug#4727078 Issue#:21
      , DECODE(page_views_c,null,null,0,null,
        (NVL(page_view_duration_c,0)/page_views_c))         IBW_VAL3
      , nvl(daily_un_visitors_c,0)                                 IBW_VAL5
      , nvl(visit_id_c,0)                                          IBW_VAL6
      , DECODE(page_views_c,null,null,0,null,(NVL(page_view_duration_c,0)/page_views_c)) IBW_VAL9 --NARAO for 	4916959
      FROM (
	       select
	  		inner1.*,
			   inner2.daily_un_visitors_c daily_un_visitors_c
      FROM (
        SELECT
          start_date																																		start_date
          , SUM(page_views_c)																								 page_views_c
          , SUM(page_views_p)																							 page_views_p
          , SUM(page_view_duration_c)/60000                   page_view_duration_c
          , SUM(page_view_duration_p)/60000                    page_view_duration_p
           , COUNT(DISTINCT(visit_id_c))															visit_id_c
        FROM
        (
          SELECT
            dates.start_date																																start_date
            , decode(dates.period,''C'',page_views,0)									page_views_c
            , decode(dates.period,''P'',page_views,0)									page_views_p
            , decode(dates.period,''C'',page_view_duration,0)		 page_view_duration_c
            , decode(dates.period,''P'',page_view_duration,0)		page_view_duration_p
            , decode(dates.period,''C'',visit_id,null)														 visit_id_c   -- Fix for Bug 4916772
          FROM
          (
            SELECT
              time_dim.start_date START_DATE,
              ''C''          PERIOD,
              least(time_dim.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
            FROM
              '||l_period_type||'   time_dim
            WHERE
              time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
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
              WHERE
              p1.id(+) = p2.id
          ) dates , ' || l_from ||'
          WHERE
            cal.report_date = dates.report_date  ' || l_where || '
           )
        GROUP BY start_date
        )  inner1,
				(
       SELECT
          start_date																														 start_date
          , sum(daily_un_visitors_c)															daily_un_visitors_c
		  from (
        SELECT
          start_date																														 start_date
          , COUNT(DISTINCT(daily_un_visitors_c))     daily_un_visitors_c
        FROM
        (
          SELECT
            dates.start_date   								  start_date
			     , transaction_date
            , decode(dates.period,''C'',visitant_id,null)         daily_un_visitors_c  -- Fix for Bug 4916772
          FROM
          (
            SELECT
              time_dim.start_date START_DATE,
              ''C''          PERIOD,
              least(time_dim.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
            FROM
              '||l_period_type||'   time_dim
            WHERE
              time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
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
              WHERE
              p1.id(+) = p2.id
          ) dates ,  '|| l_from ||'
          WHERE
            cal.report_date = dates.report_date  ' || l_where || '
        )
        GROUP BY
			  start_date,
			  transaction_date
        )
		GROUP BY
		start_date
		) inner2
		where
			 inner1.start_date = inner2.start_date
		)
    s,'|| l_period_type||' time_dim
     WHERE
      time_dim.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
      AND  time_dim.start_date = s.start_date(+)
    ORDER BY time_dim.start_date ';




   IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,l_full_path,'l_custom_sql : ' || l_custom_sql);
   END IF;

   x_custom_sql := l_custom_sql;


   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;

END get_page_int_trend_sql;

END IBW_BI_PAGE_INT_PVT;

/
