--------------------------------------------------------
--  DDL for Package Body BIL_TX_OPTY_SMRY_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_TX_OPTY_SMRY_RPT_PKG" AS
/*$Header: biltxosb.pls 120.17 2006/08/23 04:54:05 vselvapr noship $*/

PROCEDURE OPTY_SMRY_RPT (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql      OUT  NOCOPY VARCHAR2
                         ,x_custom_attr     OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_bind_ctr                  NUMBER;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_proc                      VARCHAR2(100);
    l_region_id                 VARCHAR2(50);
    g_pkg                       VARCHAR2(100);
    l_parameter_valid           BOOLEAN;


  -- sql statement related
    l_with_cls                  VARCHAR2(32000);
    l_outer_cls                 VARCHAR2(32000);
    l_outer_cls1                VARCHAR2(32000);
    l_custom_sql                VARCHAR2(32000);
    l_custom_sql1               VARCHAR2(32000);
    l_sgrp_frm_cls    		VARCHAR2(4000);
    l_srep_frm_cls              VARCHAR2(4000);
    l_where_com_cls             VARCHAR2(4000);
    l_where_period_cls          VARCHAR2(4000);
    l_where_prod_sgrp_cls       VARCHAR2(4000);
    l_where_prod_srep_cls       VARCHAR2(4000);
    l_comm_sel                  VARCHAR2(4000);
    l_sgrp_sel                  VARCHAR2(4000);
    l_srep_sel                  VARCHAR2(4000);
    l_where_dt_cls		VARCHAR2(4000);
    l_grp_by                    VARCHAR2(4000);
    l_order_by                  VARCHAR2(4000);
    -- parameters
    l_period_type               VARCHAR2(4000);
    l_from_date                 DATE;
    l_to_date                   DATE;
    l_forecast_owner            VARCHAR2(4000);  -- sales credit id needs to be passed I think.
    l_sales_group               VARCHAR2(4000);
    l_sales_person              VARCHAR2(4000);
    l_source                    VARCHAR2(4000);
    l_competitor                VARCHAR2(4000);
    l_win_probability           VARCHAR2(4000);
    l_sales_channel             VARCHAR2(4000);
    l_sales_stage               VARCHAR2(4000);
    l_opty_number               VARCHAR2(4000);
    l_total_opp_amount          NUMBER;
    l_opty_name                 VARCHAR2(4000);
    l_customer                  VARCHAR2(4000);
    l_opp_status                VARCHAR2(4000);
    l_sls_methodology           VARCHAR2(4000);
    l_product_category          VARCHAR2(4000);  -- if only prod cat is passed
    l_item_id                   VARCHAR2(4000);  -- may pass both item and prod.
    l_to_currency               VARCHAR2(4000);
    l_report_by                 VARCHAR2(4000);
    l_close_reason              VARCHAR2(4000);
    l_oppty_url1                VARCHAR2(4000);
    l_oppty_url2                VARCHAR2(4000);
    l_oppty_url3                VARCHAR2(4000);
    l_oppty_url4                VARCHAR2(4000);
    l_oppty_url5                VARCHAR2(4000);
    l_oppty_url6                VARCHAR2(4000);
    l_oppty_url7                VARCHAR2(4000);
    l_oppty_url8                VARCHAR2(4000);
    l_oppty_url9                VARCHAR2(4000);
    l_log_param			VARCHAR2(4000);
    l_from_dt			date;
    l_to_dt			date;
    l_len			number;
    l_to_period_name            VARCHAR2(4000);
    l_frcst_owner               VARCHAR2(4000);
    l_partner                   VARCHAR2(4000);
    l_total_opp_amt_opr         VARCHAR2(4000);
    l_win_probability_opr       VARCHAR2(4000);
    l_from_prd_id               VARCHAR2(4000);
    l_schema                    VARCHAR2(4000);
    l_period_set_name           VARCHAR2(500);
    l_org_id                    NUMBER;


    ---Product category parsing ---

    l_product_category1 VARCHAR2(4000);
    l_prodcat_id VARCHAR2(4000);

   -- sorting parameters ---
   l_order		VARCHAR2(4000);
   l_orderBy            VARCHAR2(4000);
   l_sortBy             VARCHAR2(4000);

   l_win_probability_val VARCHAR2(4000);


   --- Status code Parameters ---

   l_pip_st     VARCHAR2(4000);
   l_wt_pip_st  VARCHAR2(4000);
   l_open_st    VARCHAR2(4000);
   l_Won_st     VARCHAR2(4000);
   l_lost_st    VARCHAR2(4000);
   l_No_Opp_st  VARCHAR2(4000);

  -- Error Message Parameter --
    l_err_msg VARCHAR2(4000);



  BEGIN

    -- IF WE want we can get region and function from get page params
    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_SMRY_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_SMRY_RPT';
       l_proc             := 'OPTY_SMRY_RPT.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_SMRY_RPT_PKG.';
       l_schema           := 'BIL';
	    --Fix for bug 5469370,added replace function
       l_err_msg          := replace(FND_MESSAGE.GET_STRING('BIL','BIL_TX_CUR_CONV_MIS'),'''','''''');
	  l_period_set_name  := NVL(FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR'), 'Accounting');
       l_org_id   := fnd_profile.value('ORG_ID');

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

        -- FND logging --
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)
       THEN
          BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				       p_module    => g_pkg || l_proc || 'begin',
				       p_msg 	   => 'Start of Procedure '|| l_proc );
	END IF;



   -- Getting the Status Codes based on the Status Flags --

   l_pip_st     :=  BIL_TX_UTIL_RPT_PKG.GET_STATS_CODS_OPTY_FLGS('__Y');
   l_wt_pip_st  := BIL_TX_UTIL_RPT_PKG.GET_STATS_CODS_OPTY_FLGS('__Y');
   l_open_st    := BIL_TX_UTIL_RPT_PKG.GET_STATS_CODS_OPTY_FLGS('NYY');
   l_Won_st     := BIL_TX_UTIL_RPT_PKG.GET_STATS_CODS_OPTY_FLGS('WNY' );
   l_lost_st    := BIL_TX_UTIL_RPT_PKG.GET_STATS_CODS_OPTY_FLGS('LNN');
   l_No_Opp_st  := BIL_TX_UTIL_RPT_PKG.GET_STATS_CODS_OPTY_FLGS('NNN');


     -- Page Parameters --

       BIL_TX_UTIL_RPT_PKG.GET_PAGE_PARAMS
                          (p_page_parameter_tbl      => p_page_parameter_tbl
                          ,p_region_id               => l_region_id
                          ,x_period_type             => l_period_type
                          ,x_to_currency             => l_to_currency
                          ,x_to_period_name          => l_to_period_name
                          ,x_sg_id                   => l_sales_group
                          ,x_resource_id             => l_sales_person
                          ,x_frcst_owner             => l_frcst_owner
                          ,x_prodcat_id              => l_product_category
                          ,x_item_id                 => l_item_id
                          ,x_parameter_valid         => l_parameter_valid
                          ,x_viewby                  => l_viewby
                          ,x_order                  =>  l_order
                          ,x_rptby                   => l_report_by
                          ,x_sls_chnl                => l_sales_channel
                          ,x_sls_stge                => l_sales_stage
                          ,x_opp_status              => l_opp_status
                          ,x_source                  => l_source
                          ,x_sls_methodology         => l_sls_methodology
                          ,x_win_probability         => l_win_probability
                          ,x_win_probability_opr     => l_win_probability_opr
                          ,x_close_reason            => l_close_reason
                          ,x_competitor              => l_competitor
                          ,x_opty_number             => l_opty_number
                          ,x_total_opp_amount        => l_total_opp_amount
                          ,x_total_opp_amt_opr       => l_total_opp_amt_opr
                          ,x_opty_name               => l_opty_name
                          ,x_customer                => l_customer
                          ,x_partner                 => l_partner
                          ,x_from_date               => l_from_date
                          ,x_to_date                 => l_to_date);



    l_from_date :=  BIL_TX_UTIL_RPT_PKG.GET_FROM_DATE(l_to_period_name);
    l_to_date := BIL_TX_UTIL_RPT_PKG.GET_TO_DATE(l_to_period_name);



    -- Getting the Product category parameter --
    -- This loop to be removed once Util Pkg is modified
    --  to pass PC as multiple values

     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last
     LOOP

       IF p_page_parameter_tbl(i).parameter_name = 'PROD_CAT+CAT'
       THEN
          l_product_category    := p_page_parameter_tbl(i).parameter_id;

       END IF;

      IF p_page_parameter_tbl(i).parameter_name = 'TO_PRD+TO'
       THEN
          l_from_prd_id       := REPLACE(p_page_parameter_tbl(i).parameter_id,'''');

       END IF;

     END LOOP;





       --- Drill across Links --

       l_oppty_url1 := '''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y'||
                        '&BIL_TX_STATUS='||l_pip_st||'&BIL_TX_FROM_PRD='|| l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';
       l_oppty_url2 := '''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y'||
                        '&BIL_TX_STATUS='||l_wt_pip_st||'&BIL_TX_FROM_PRD='|| l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';
      l_oppty_url3 :='''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y'||
                         '&BIL_TX_STATUS='||l_open_st||'&BIL_TX_FROM_PRD='|| l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';
      l_oppty_url4 := '''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y'||
                         '&BIL_TX_STATUS='||l_Won_st||'&BIL_TX_FROM_PRD='|| l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';
      l_oppty_url5 := '''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y'||
                         '&BIL_TX_STATUS='||l_lost_st||'&BIL_TX_FROM_PRD='|| l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';
      l_oppty_url6 := '''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y'||
                         '&BIL_TX_STATUS='||l_No_Opp_st||'&BIL_TX_FROM_PRD='|| l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';
      l_oppty_url7 := '''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y&BIL_TX_FROM_PRD='                        || l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';
      l_oppty_url8 := '''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y&BIL_TX_FROM_PRD='                       || l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';
      l_oppty_url9 := '''pFunctionName=BIL_TX_OPTY_LIST_RPT_R&pForceRun=Y&pParameters=pParamIds&BIL_TX_PROD_CAT=''||prod_id||''&pParamIds=Y&BIL_TX_FROM_PRD='                      || l_from_prd_id||'&BIL_TX_TO_PRD='|| l_from_prd_id||'''';




      --- Logging of Parameters --

         l_log_param :=  'l_period_type =>' ||l_period_type|| ' , '||
                         'l_to_period_name  =>' ||l_to_period_name || ' , '||
                         'l_to_currency=>' || l_to_currency|| ' , '||
                         'l_sales_group =>'|| l_sales_group|| ' , '||
                         'l_sales_person =>'|| l_sales_person|| ' , '||
                         'l_product_category =>'|| l_product_category|| ' , '||
                         'l_item_id =>'|| l_item_id|| ' , '||
                         'l_viewby =>'|| l_viewby|| ' , '||
                         'l_report_by =>'|| l_report_by|| ' , '||
                         'l_sales_channel =>'|| l_sales_channel|| ' , '||
                         'l_sales_stage =>'|| l_sales_stage|| ' , '||
                         'l_sls_methodology =>'|| l_sls_methodology|| ' , '||
                         'l_win_probability =>'|| l_win_probability|| ' , '||
                         'l_win_probability_opr =>'|| l_win_probability_opr || ' , '||
                         'l_from_date    =>'|| l_from_date|| ' , '||
                         'l_to_date =>'|| l_to_date|| ' , '||
                         'l_order =>'||l_order|| ' , '||
                         ' l_orderBy =>'||l_orderBy|| ' , '||
                         ' l_sortBy  =>'||l_sortBy|| ' , '||
                         'l_frcst_owner =>' ||l_frcst_owner;

   IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)
        THEN
          BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				       p_module    => g_pkg || l_proc,
				       p_msg 	   => '  Params are =>'||l_log_param );
	END IF;



    IF l_order IS NULL THEN

       l_order := '  NLSSORT(BIL_TX_MEASURE9, ''NLS_SORT=BINARY'') ';

   END IF;


   --deletion of records from the Global Temporary Table --

   EXECUTE IMMEDIATE  'TRUNCATE TABLE'||' '||l_schema||'.'||'BIL_TX_PROD_TMP ';


    --- product category  parsing -----

    IF l_product_category IS NOT NULL
    THEN
     BEGIN
       LOOP
          l_len := instr(l_product_category,',');

         IF l_len <> 0 THEN
             l_product_category1:= substr(l_product_category,1, l_len-1) ;
         ELSE
             l_product_category1 := l_product_category;
         END IF;

         l_prodcat_id := l_product_category1;

         BIL_TX_UTIL_RPT_PKG.PARSE_PRODCAT_ITEM_ID(l_prodcat_id,l_item_id) ;

         IF l_item_id is null THEN
            INSERT INTO BIL_TX_PROD_TMP(attr1,attr2,attr3)  VALUES(l_prodcat_id,l_item_id,'C');
         ELSE
            INSERT INTO BIL_TX_PROD_TMP(attr1,attr2,attr3)  VALUES(l_prodcat_id,l_item_id,'P');
         END IF;

        l_product_category  := substr(l_product_category, l_len+1);

        EXIT WHEN l_len = 0;

       END LOOP;

     END;
    END IF;


  -- With clause for fetching the Product Categories --

  l_with_cls :=  'WITH
 	          child_pc AS
		    (SELECT a.object_id category_set_id
		            , a.parent_id
		            , a.child_id
		            ,tl.description prodcat_name
	              FROM eni_denorm_hierarchies a
	  	           , mtl_default_category_sets b
		           , BIL_TX_PROD_TMP cat
		           , mtl_categories_tl  tl
		      WHERE b.functional_area_id = 11
		       AND  b.category_set_id = a.object_id
		       AND  a.object_type = ''CATEGORY_SET''
	               AND a.parent_id = cat.ATTR1
	               AND a.oltp_flag = ''Y''
		       AND cat.ATTR3 = ''C''
		       AND  tl.category_id = cat.ATTR1
		       AND  tl.language = userenv(''LANG'') )' ;



  /*** Query column mapping ******************************************************

	*   BIL_TX_MEASURE1    -  Pipeline
	*   BIL_TX_MEASURE2    - Open
	*   BIL_TX_MEASURE3    - Won
	*   BIL_TX_MEASURE4    - Lost
	*   BIL_TX_MEASURE5    - No Opportunity
	*   BIL_TX_MEASURE6    -  Forecast Best
 	*   BIL_TX_MEASURE7    - Forecast Forecast
	*   BIL_TX_MEASURE8    -  Forecast Worst
	*   BIL_TX_MEASURE9    -  Product Cat Desc
        *   BIL_TX_MEASURE11   - Weighted Pipeline
        *   BIL_TX_URL1        -  Pipeline Url
        *   BIL_TX_URL2        -  Weighted Pipeline Url
        *   BIL_TX_URL3        -  Open Url
        *   BIL_TX_URL4        -  Won Url
        *   BIL_TX_URL5        -  Lost Url
        *   BIL_TX_URL6        -  No Opportunity Url
        *   BIL_TX_URL7        -  Forecast - Best Url
        *   BIL_TX_URL8        -  Forecast Url
        *   BIL_TX_URL9        -  Forecast - Worst Url
        *   BIL_TX_MEASURE12   -  Grand Total(Pipeline)
        *   BIL_TX_MEASURE13   -  Grand Total(Weighted Pipeline)
        *   BIL_TX_MEASURE14   -  Grand Total(Open)
        *   BIL_TX_MEASURE15   -  Grand Total(Won)
        *   BIL_TX_MEASURE16   -  Grand Total(Lost)
        *   BIL_TX_MEASURE17   -  Grand Total(No Opportunity)
        *   BIL_TX_MEASURE18   -  Grand Total(Forecast Best)
        *   BIL_TX_MEASURE19   -  Grand Total(Forecast)
        *   BIL_TX_MEASURE20   -  Grand Total(Forecast Worst)
        *   BIL_TX_MEASURE21   -  Error Message

	*******************************************************************************/


  -- Outer Select Statement --

  l_outer_cls  :=  'SELECT     prod_dec  BIL_TX_MEASURE9
	               	      ,pipe_opty_amt  BIL_TX_MEASURE1
                              ,wat_amnt       BIL_TX_MEASURE11
			      ,open_opty_amt  BIL_TX_MEASURE2
			      ,won_opty_amt BIL_TX_MEASURE3
			      ,lost_opty_amt   BIL_TX_MEASURE4
			      ,no_opp_opty_amt BIL_TX_MEASURE5
			      ,opp_forcast_best_amount BIL_TX_MEASURE6
			      ,opp_forcast_amount BIL_TX_MEASURE7
			      ,opp_forecast_worst_amnt BIL_TX_MEASURE8
                              ,'||l_oppty_url1||' BIL_TX_URL1
                              ,'||l_oppty_url2||'  BIL_TX_URL2
                              ,'||l_oppty_url3||'  BIL_TX_URL3
                              ,'||l_oppty_url4||' BIL_TX_URL4
                              ,'||l_oppty_url5||'  BIL_TX_URL5
                              ,'||l_oppty_url6||'  BIL_TX_URL6
                              ,'||l_oppty_url7||'  BIL_TX_URL7
                              ,'||l_oppty_url8||'  BIL_TX_URL8
                              ,'||l_oppty_url9||'  BIL_TX_URL9
                              ,SUM(pipe_opty_amt)OVER() BIL_TX_MEASURE12
                              ,SUM(wat_amnt)OVER() BIL_TX_MEASURE13
                              ,SUM(open_opty_amt)OVER() BIL_TX_MEASURE14
                              ,SUM(won_opty_amt)OVER() BIL_TX_MEASURE15
                              ,SUM(lost_opty_amt)OVER() BIL_TX_MEASURE16
                              ,SUM(no_opp_opty_amt)OVER() BIL_TX_MEASURE17
                              ,SUM(opp_forcast_best_amount)OVER() BIL_TX_MEASURE18
                              ,SUM(opp_forcast_amount)OVER() BIL_TX_MEASURE19
                              ,SUM(opp_forecast_worst_amnt)OVER() BIL_TX_MEASURE20
                              ,DECODE(conversion_status_flag, 0,NULL ,''' || l_err_msg ||''' ) BIL_TX_MEASURE21

             	  FROM (  ' ;



    -- Sales Group Query From clause --

   l_sgrp_frm_cls := '  FROM  as_sales_credits_denorm ascd
                              ,child_pc h
	                      ,jtf_rs_group_usages usg1
                              ,as_period_days p ';


  -- Sales Rep Query From clause --


   l_srep_frm_cls := '  FROM  as_sales_credits_denorm ascd
                            ,bil_tx_prod_tmp prod
                          ,mtl_system_items_tl tl
	                  ,jtf_rs_group_usages usg1
                          ,as_period_days p ';
   -- Report By --

   IF instr(l_report_by ,'1') > 0
   THEN
      l_where_dt_cls := ' ascd.decision_date ' ;
   ELSIF  instr(l_report_by,'2') > 0
    THEN
      l_where_dt_cls := ' NVL(ascd.forecast_date , ascd.decision_date) ' ;
   END IF;

   -- Common where clause for Sales Group and Sales Rep --

   l_where_com_cls :=  '  WHERE   '||l_where_dt_cls ||'  between  :l_from_date    and  :l_to_date   '||
	  	       '  AND   ascd.SALES_GROUP_ID  IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
		          AND   ascd.salesforce_id = &SLS_PRSON+PERSON
	  	          AND   ascd.SALES_GROUP_ID = usg1.group_id
		          AND   usg1.usage = ''SALES''
                          AND   P.period_day = ascd.decision_date
                          AND   p.period_type = &PRD_TYPE+TYPE
		          AND   p.period_set_name = :l_period_set_name ';


   -- Sales Methodolgy --
  IF l_sls_methodology IS NOT NULL THEN
     l_where_com_cls :=    l_where_com_cls || '  AND SALES_METHODOLOGY_ID = &METHODOLOGY+METH ' ;
  END IF ;

  -- Sales Stage --
  IF l_sales_stage IS NOT NULL THEN
     l_where_com_cls :=    l_where_com_cls || '  AND SALES_STAGE_ID = &SLS_STAGE+STAGE  ' ;
  END IF ;

   -- Sales Channel --
   IF l_sales_channel IS NOT NULL THEN
      l_where_com_cls :=    l_where_com_cls || '  AND CHANNEL_CODE  IN  (&SLS_CHNL+CHNL)  ' ;
   END IF ;

   IF l_sales_channel IS NULL THEN
      l_where_com_cls :=    l_where_com_cls ||
        '  AND  channel_code =  flvl.lookup_code '||  -- channel code
        '  AND  trunc(nvl(flvl.start_date_active, SYSDATE)) <= trunc(SYSDATE)'||  -- channel code
        '  AND  trunc(nvl(flvl.end_date_active, SYSDATE)) >= trunc(SYSDATE) '||  -- channel code
        '  AND  flvl.enabled_flag = ''Y'' '||  -- channel code
        '  AND  flvl.language = USERENV(''LANG'') '|| -- channel code
        '  AND  flvl.lookup_type = ''SALES_CHANNEL'' '|| -- channel code
        '  AND  flvl.view_application_id = 660  '; -- channel code

      l_sgrp_frm_cls := l_sgrp_frm_cls || ' ,fnd_lookup_values  flvl  ' ; -- for channel code
      l_srep_frm_cls := l_srep_frm_cls || ' ,fnd_lookup_values  flvl  ' ; -- for channel code

   END IF ;

  -- Win Probability --
   IF l_win_probability IS NOT NULL THEN
      l_where_com_cls :=    l_where_com_cls || ' AND ascd.WIN_PROBABILITY  '|| l_win_probability_opr ||' :l_win_probability ';
   END IF;


  -- ForeCast Type
   IF l_frcst_owner IS NOT NULL THEN
      l_where_com_cls :=    l_where_com_cls || ' AND ascd.CREDIT_TYPE_ID  =  &FRCST_ONER+ONER   ';
   END IF;

   -- Period Where clause --

   l_where_period_cls := ' AND  p.period_name = m.period_name
		    AND  p.period_set_name = m.period_set_name
		    AND  p.period_type = m.period_type
		    AND  m.to_currency = &CURRENCY+CURR
		    AND  p.period_type = &PRD_TYPE+TYPE
		    AND  p.period_set_name = :l_period_set_name
		    AND  m.from_currency = qry.currency_code
		    AND  p.period_day = qry.decision_date';

  -- Producat category criteria for Sales Group --


  l_where_prod_sgrp_cls :=  ' AND   h.child_id = ascd.product_category_id
	                      AND  h.category_set_id = ascd.product_cat_set_id ';

 -- Producat category criteria for Sales Rep --


  l_where_prod_srep_cls :=  '  AND  prod.ATTR1 = ascd.product_category_id
                              AND   prod.ATTR2 =  ascd.item_id
		              AND   tl.INVENTORY_ITEM_ID = prod.ATTR2
		              AND   tl.ORGANIZATION_ID = :l_org_id
                              AND   tl.language = userenv(''LANG'')
		              AND   prod.ATTR3 = ''P''';



  -- Common Select statment for fetching the Measures based on the flags --

  l_comm_sel :=  ' SELECT
	 	     SUM(CASE WHEN win_loss_indicator||opp_open_status_flag||forecast_rollup_flag =''NYY''
			       THEN ( (sales_credit_amount/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
			       ELSE NULL
			  END) open_opty_amt
	            ,SUM(CASE WHEN win_loss_indicator||opp_open_status_flag||forecast_rollup_flag =''WNY''
			       THEN ((sales_credit_amount/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
			       ELSE NULL
		         END) won_opty_amt
		    ,SUM(CASE WHEN win_loss_indicator||opp_open_status_flag||forecast_rollup_flag =''LNN''
	                       THEN ((sales_credit_amount/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
			        ELSE NULL
			 END) lost_opty_amt
		    ,SUM(CASE WHEN win_loss_indicator||opp_open_status_flag||forecast_rollup_flag =''NNN''
	                      THEN ((sales_credit_amount/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
			      ELSE NULL
		         END) no_opp_opty_amt
		    ,SUM(CASE WHEN win_loss_indicator||forecast_rollup_flag IN (''NY'',''WY'')
	                      THEN ((sales_credit_amount/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
			      ELSE NULL
			  END) pipe_opty_amt
		    ,SUM( nvl( (CASE WHEN win_loss_indicator||forecast_rollup_flag =''WY''
	                             THEN (( (sales_credit_amount * win_probability/100)  /NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
				     ELSE NULL
				END),
                             0)  +
		          nvl( (CASE WHEN win_loss_indicator||forecast_rollup_flag =''NY''
	                             THEN (((sales_credit_amount* win_probability/100)/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE )
				     ELSE NULL
				END),
                             0)
                        ) wat_amnt
                     ,SUM(CASE WHEN forecast_rollup_flag =''Y''
	                      THEN ((OPP_BEST_FORECAST_AMOUNT/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
			      ELSE NULL
			  END)  opp_forcast_best_amount
                     ,SUM(CASE WHEN forecast_rollup_flag =''Y''
	                      THEN ((OPP_FORECAST_AMOUNT/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
			      ELSE NULL
			  END) opp_forcast_amount
                      ,SUM(CASE WHEN forecast_rollup_flag =''Y''
	                      THEN ((OPP_WORST_FORECAST_AMOUNT/NVL(m.DENOMINATOR_RATE,1))*m.NUMERATOR_RATE)
			      ELSE NULL
			  END) opp_forecast_worst_amnt
	   	    , prod_id
		   , prod_dec
                   ,SUM(nvl(conversion_status_flag,1))  conversion_status_flag   FROM (  ';


  -- Selected columns for the Sales Group --

   l_sgrp_sel := 'SELECT sales_credit_amount,
			 opp_best_forecast_amount,
			 opp_forecast_amount,
			 opp_worst_forecast_amount,
			 H.parent_id||''.001'' prod_id,
			 H.prodcat_name prod_dec ,
			 win_probability,
			 win_loss_indicator,
			 forecast_rollup_flag,
			 opp_open_status_flag,
			 ascd.decision_date,
			 ascd.currency_code,
                         period_set_name,
                         period_type,
                         period_name ' ;

  -- Selected columns for the Sales Rep --

   l_srep_sel :=  'SELECT sales_credit_amount,
			 opp_best_forecast_amount,
			 opp_forecast_amount,
			 opp_worst_forecast_amount,
			 PROD.ATTR1 ||''.''||PROD.ATTR2 prod_id,
		         tl.DESCRIPTION  prod_dec,
			 win_probability,
			 win_loss_indicator,
			 forecast_rollup_flag,
			 opp_open_status_flag,
			 ascd.decision_date,
			 ascd.currency_code,
                         period_set_name,
                         period_type,
                         period_name  ' ;

  -- Group by --

   l_grp_by := '    group by prod_id , prod_dec  ' ;



   l_outer_cls1 := '   )q,  as_period_rates m
                      where
			    m.period_name(+) = q.period_name
		       AND  m.period_set_name(+) = q.period_set_name
		       AND  m.period_type(+) = q.period_type
		       AND  m.to_currency(+) = &CURRENCY+CURR
		       AND  m.from_currency(+) = q.currency_code
		          group by prod_id , prod_dec
		        )' ;




     -- Sales Group level final Query --

     l_custom_sql  :=   l_sgrp_sel || ' '|| l_sgrp_frm_cls ||' '|| l_where_com_cls||l_where_prod_sgrp_cls ;

     -- Sales Rep level final Query --

     l_custom_sql1  :=  l_srep_sel || ' '|| l_srep_frm_cls ||' '|| l_where_com_cls||l_where_prod_srep_cls;


     x_custom_sql :=  l_with_cls|| ' '||l_outer_cls || '  '|| l_comm_sel || '  ' ||l_custom_sql || 'union all  ' || l_custom_sql1 ||'  ' || l_outer_cls1||                           '   ' || '  order by   ' || l_order ;

        -- Parameters binding --

        l_bind_ctr := 1;
        l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_custom_rec.attribute_value := l_viewby;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_from_date';
        l_custom_rec.attribute_value :=TO_CHAR(l_from_date,'DD/MM/YYYY') ;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_to_date';
        l_custom_rec.attribute_value :=TO_CHAR(l_to_date,'dd/MM/yyyy') ;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_win_probability';
        l_custom_rec.attribute_value :=l_win_probability;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_win_probability_opr';
        l_custom_rec.attribute_value :=l_win_probability_opr;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_period_set_name';
        l_custom_rec.attribute_value :=l_period_set_name;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


        l_custom_rec.attribute_name :=':l_org_id';
        l_custom_rec.attribute_value :=l_org_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


        l_custom_rec.attribute_name :=':l_viewby';
        l_custom_rec.attribute_value := l_viewby;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

END  OPTY_SMRY_RPT;

END BIL_TX_OPTY_SMRY_RPT_PKG;


/
