--------------------------------------------------------
--  DDL for Package Body BIL_TX_OPTY_AGE_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_TX_OPTY_AGE_RPT_PKG" AS
/* $Header: biltxoab.pls 120.31.12010000.2 2010/02/16 05:17:05 annsrini ship $ */

 PROCEDURE OPTY_AGE_RPT (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql         OUT  NOCOPY VARCHAR2
                         ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_bind_ctr                  NUMBER;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_proc                      VARCHAR2(100);
    l_region_id                 VARCHAR2(50);
    g_pkg                       VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    -- sql statement related
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    l_outer_select0              VARCHAR2(4000);
    l_select_1                    VARCHAR2(15000);
    l_from                      VARCHAR2(15000);
    l_insert_stmnt              VARCHAR2(4000);
    l_where_clause_1              VARCHAR2(4000);
    l_where_clause_2              VARCHAR2(4000);
    l_group_by                  VARCHAR2(4000);
    l_order_by                  VARCHAR2(1000);
    -- parameters
    l_period_type               VARCHAR2(100);
    l_from_time_id              VARCHAR2(100);
    l_to_time_id                VARCHAR2(100);
    l_sales_group               VARCHAR2(4000);
    l_sales_group_flag          VARCHAR2(1);
    l_sales_person              VARCHAR2(4000);
    l_sales_person_flag         VARCHAR2(1);
    l_opty_name                 VARCHAR2(500);

    l_customer                  VARCHAR2(400);
    l_customer_flag             VARCHAR2(1);
    l_source                    VARCHAR2(4000);
    l_source_flag               VARCHAR2(4000);
    l_opp_status                VARCHAR2(4000);
    l_opp_status_flag           VARCHAR2(1);
    l_sales_channel             VARCHAR2(4000);
    l_sales_channel_flag        VARCHAR2(1);
    l_sales_stage               VARCHAR2(4000);
    l_sls_methodology           VARCHAR2(100);
    l_product_category          VARCHAR2(4000);  -- if only prod cat is passed
    l_product_category_flag     VARCHAR2(1);  -- if only prod cat is passed
    l_item_id                   VARCHAR2(4000);  -- may pass both item and prod.
    l_item_id_flag              VARCHAR2(1);  -- may pass both item and prod.
    l_partner              VARCHAR2(4000);
    l_partner_id                VARCHAR2(500);
    l_to_currency               VARCHAR2(500);
    l_report_by                 VARCHAR2(500);
    l_close_reason              VARCHAR2(500);
    l_competitor                VARCHAR2(100);
    l_opty_number               VARCHAR2(100);
    l_convsersion_type          VARCHAR2(100);
    l_period_set_name          VARCHAR2(100);
    l_from_date                 DATE;
    l_to_date                 DATE;
    l_total_opp_amount          VARCHAR2(100);
    l_total_opp_amt_opr         VARCHAR2(100);
    l_oppty_url1                VARCHAR2(1000);
    l_customer_url2             VARCHAR2(1000);
    l_url                       VARCHAR2(1000);
    l_credit_type_id            NUMBER;
    seq				NUMBER;
    CNT				NUMBER;
    des                          VARCHAR2(100);
    code                         VARCHAR2(100);
    l_status_days                VARCHAR2(4000);
    l_total_days                VARCHAR2(4000);
    l_measure_outer                VARCHAR2(4000);
    type t_stats_c is ref cursor;
    l_status_c  t_stats_c;
    l_sales_team_access         VARCHAR2(100);
    l_to_period_name         VARCHAR2(100);
    l_ok                      VARCHAR2(1);
    l_status                   VARCHAR2(1000);
    l_asn_Table       BIS_MAP_TBL;
    l_asn_Table_code  BIS_MAP_TBL;
    l_order			 VARCHAR2(100);
    l_win_probability           VARCHAR2(100);
    l_win_probability_opr       VARCHAR2(100);
    l_cur_conv_missing       VARCHAR2(1000);
    l_win_prob                  NUMBER(3);
    rc			number;
    l_log_param VARCHAR2(4000);


    BEGIN

    -- IF WE want we can get region and function from get page params
    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_AGE_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_AGE_RPT_R';
       l_proc             := 'OPTY_AGE_RPT.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_AGE_RPT_PKG.';
       l_convsersion_type :=  FND_PROFILE.VALUE('CRMBIS:GL_CONVERSION_TYPE');
       l_period_set_name :=  FND_PROFILE.VALUE('CRMBIS:PERIOD_SET_NAME');
       l_credit_type_id  :=  FND_PROFILE.VALUE('ASN_FRCST_CREDIT_TYPE_ID');
	  --Fix for bug 5469370,added replace function
       l_cur_conv_missing := replace(FND_MESSAGE.GET_STRING('BIL','BIL_TX_CUR_CONV_MIS'),'''','''''');
       l_select_1        := NULL;
       l_from        := NULL;
       l_where_clause_1        := NULL;
       l_where_clause_2         := NULL;




    l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();



    l_oppty_url1 := '''pFunctionName=ASN_OPPTYDETPG&addBreadCrumb=Y&ASNReqFrmOpptyId=''||ascd.lead_number';

    l_customer_url2 := '''pFunctionName=ASN_CUSTDETGWAYPG&ASNReqAcsErrInDlg=Y&addBreadCrumb=Y&ASNReqFrmCustId=''||ascd.CUSTOMER_ID ';

    BIL_TX_UTIL_RPT_PKG.GET_PAGE_PARAMS
                          (p_page_parameter_tbl      => p_page_parameter_tbl
                          ,p_region_id               => l_region_id
                          ,x_period_type             => l_period_type
                          ,x_to_currency             => l_to_currency
                          ,x_to_period_name          => l_to_period_name
                          ,x_sg_id                   => l_sales_group
                          ,x_resource_id             => l_sales_person
                          ,x_frcst_owner             => l_sales_team_access
                          ,x_prodcat_id              => l_product_category
                          ,x_item_id                 => l_item_id
                          ,x_parameter_valid         => l_parameter_valid
                          ,x_viewby                  => l_viewby
                          ,x_order                   => l_order
                          ,x_rptby                   => l_report_by
                          ,x_sls_chnl                => l_sales_channel
                          ,x_sls_stge                => l_sales_stage
                          ,x_opp_status              => l_opp_status
                          ,x_source                  => l_source
                          ,x_sls_methodology         => l_sls_methodology
                          ,x_win_probability         => l_win_probability
                          ,x_win_probability_opr      => l_win_probability_opr
                          ,x_close_reason            => l_close_reason
                          ,x_competitor              => l_competitor
                          ,x_opty_number             => l_opty_number
                          ,x_total_opp_amount        => l_total_opp_amount
                          ,x_total_opp_amt_opr       => l_total_opp_amt_opr
                          ,x_opty_name               => l_opty_name
                          ,x_customer                => l_customer
                          ,x_partner                 => l_partner_id
                          ,x_from_date               => l_from_date
                          ,x_to_date                 => l_to_date);


/*
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
                         'l_to_date =>'|| l_to_date;
*/





   /*** Query column mapping ******************************************************
        -- OUTER MOST SELECT IS NEEDED ONLY FOR THIS REPORT

Lead_id                         BIL_TX_MEASURE1
Opportunity Name                BIL_TX_MEASURE2
Customer ID                     BIL_TX_MEASURE3
Customer Name                   BIL_TX_MEASURE4
Sales Group ID                  BIL_TX_MEASURE5
Sales Group Name                BIL_TX_MEASURE6
Sales Person                    BIL_TX_MEASURE7
Win Probability %               BIL_TX_MEASURE8
Total Opportunity Amount        BIL_TX_MEASURE9
Status                          BIL_TX_MEASURE10
Close Date                      BIL_TX_MEASURE11
Days                            BIL_TX_MEASURE12
To Close                        BIL_TX_MEASURE13
Since Creation                  BIL_TX_MEASURE14
Past Close                      BIL_TX_MEASURE15
Days in Status                  BIL_TX_MEASURE16
Total Days                      BIL_TX_MEASURE21
LEAD_NUMBER BIL_TX_MEASURE24
CHANNEL_CODE BIL_TX_MEASURE25
OPPORTUNITY_LAST_UPDATE_DATE BIL_TX_MEASURE26
OPPORTUNITY_LAST_UPDATED_NAME BIL_TX_MEASURE27
OPPORTUNITY_CREATION_DATE BIL_TX_MEASURE28
OPPORTUNITY_CREATED_NAME BIL_TX_MEASURE29
CUSTOMER_CATEGORY BIL_TX_MEASURE30
WEIGHTED_AMOUNT BIL_TX_MEASURE31
CLOSE_REASON_MEANING BIL_TX_MEASURE32
Missing Currency Bubble Text  BIL_TX_MEASURE33
Missing Currency Bubble Text  BIL_TX_MEASURE34
*/


-- This method was suggested by Seema. Getting the same results as the oroginal method.

l_asn_Table := BIS_MAP_TBL();

l_asn_Table_code := BIS_MAP_TBL();


BIL_TX_UTIL_RPT_PKG.days_in_status_code (p_page_parameter_tbl,l_asn_Table_code);

IF l_asn_Table_code IS NOT NULL AND l_asn_Table_code.COUNT > 0 THEN
	FOR i IN l_asn_Table_code.first..l_asn_Table_code.last LOOP
	      --Fix for bug 5469370,added replace function
	 	l_status := replace(l_asn_Table_code(i).value,'''','''''');

         	l_status_days := l_status_days||', AVG(DECODE (UPPER(ss.status_code),UPPER( '''|| l_status  ||'''),ss.status_days)) BIL_TX_MEASURE16_B'||i ;

	--	l_total_days := l_total_days || 'NVL(BIL_TX_MEASURE16_B'||i||',0)+';
	--	l_measure_outer := l_measure_outer ||'BIL_TX_MEASURE16_B'||i||',';
	END LOOP;
 	/* l_total_days :=  ' '||substr(l_total_days,1,INSTR(l_total_days,'+',-1)-1);
--  	l_total_days := 'DECODE('||l_total_days||',0,NULL,'||l_total_days||')';
 	l_measure_outer :=  ', '||substr(l_measure_outer,1,INSTR(l_measure_outer,',',-1)-1); */

END IF;


BIL_TX_UTIL_RPT_PKG.days_in_status (p_page_parameter_tbl,l_asn_Table);

IF l_asn_Table IS NOT NULL AND l_asn_Table.COUNT > 0 THEN
	FOR i IN l_asn_Table.first..l_asn_Table.last LOOP
	      --Fix for bug 5469370,added replace function
	 --	l_status := replace(l_asn_Table(i).value,'''','''''');

         --	l_status_days := l_status_days||', AVG(DECODE (UPPER(ss.status_code),UPPER( '''|| l_status  ||'''),ss.status_days)) BIL_TX_MEASURE16_B'||i ;

		l_total_days := l_total_days || 'NVL(BIL_TX_MEASURE16_B'||i||',0)+';
		l_measure_outer := l_measure_outer ||'BIL_TX_MEASURE16_B'||i||',';
	END LOOP;
 	l_total_days :=  ' '||substr(l_total_days,1,INSTR(l_total_days,'+',-1)-1);
--  	l_total_days := 'DECODE('||l_total_days||',0,NULL,'||l_total_days||')';
 	l_measure_outer :=  ', '||substr(l_measure_outer,1,INSTR(l_measure_outer,',',-1)-1);

END IF;


  l_outer_select := 'SELECT BIL_TX_MEASURE1, BIL_TX_MEASURE2, BIL_TX_MEASURE3, '||
                        ' BIL_TX_MEASURE4, BIL_TX_MEASURE5, BIL_TX_MEASURE6, '||
                        ' BIL_TX_MEASURE7, BIL_TX_MEASURE8, BIL_TX_MEASURE9, BIL_TX_MEASURE10, ' ||
                        ' BIL_TX_MEASURE11, BIL_TX_MEASURE13 , '||
                        ' BIL_TX_MEASURE14, BIL_TX_MEASURE15 ' ||l_measure_outer||
                        ','||l_total_days||' BIL_TX_MEASURE21,'||
                        ' BIL_TX_MEASURE24, BIL_TX_MEASURE25, BIL_TX_MEASURE26, BIL_TX_MEASURE27, '||
                        ' BIL_TX_MEASURE28, BIL_TX_MEASURE29,'||
                    ' BIL_TX_MEASURE30, BIL_TX_MEASURE31, BIL_TX_MEASURE32,  BIL_TX_MEASURE33,BIL_TX_MEASURE34,  BIL_TX_URL1, BIL_TX_URL2 FROM';


 l_select_1 := ' ( SELECT  ascd.lead_id BIL_TX_MEASURE1 '||
               ' ,ascd.OPP_DESCRIPTION BIL_TX_MEASURE2 '||
               ' ,ascd.customer_id BIL_TX_MEASURE3 ,party.party_name BIL_TX_MEASURE4 ,'||
               ' ascd.sales_group_id BIL_TX_MEASURE5 ,jrgst.GROUP_NAME BIL_TX_MEASURE6 ,'||
               '  jrret.RESOURCE_NAME   BIL_TX_MEASURE7 ,ascd.win_probability BIL_TX_MEASURE8 ,'||
 	       ' (CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN (DECODE(m.CONVERSION_RATE, NULL ,ascd.TOTAL_AMOUNT , ascd.TOTAL_AMOUNT)) '||
                 ' ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ascd.TOTAL_AMOUNT*m.CONVERSION_RATE))  END ) BIL_TX_MEASURE9, '||
              ' status.meaning BIL_TX_MEASURE10 ,ascd.decision_date  BIL_TX_MEASURE11 ,'||
              ' decode( greatest(SYSDATE, ascd.DECISION_DATE), ascd.DECISION_DATE, to_char(trunc(ascd.DECISION_DATE)-trunc(SYSDATE)),0) BIL_TX_MEASURE13 ,'||
              ' (TRUNC(SYSDATE)-trunc(ascd.OPPORTUNITY_CREATION_DATE)) BIL_TX_MEASURE14 ,'||
              ' decode( greatest(SYSDATE, ascd.DECISION_DATE), SYSDATE, to_char(trunc(SYSDATE)-trunc(ascd.DECISION_DATE)),0) BIL_TX_MEASURE15 ' ||
              l_status_days ||
              ' ,0  BIL_TX_MEASURE21 '||
              ' , ascd.LEAD_NUMBER BIL_TX_MEASURE24 ,flvl2.meaning BIL_TX_MEASURE25 ,'||
              ' ascd.OPPORTUNITY_LAST_UPDATE_DATE BIL_TX_MEASURE26, '||
              ' JTF_COMMON_PVT.GetUserInfo(ascd.OPPORTUNITY_LAST_UPDATED_BY) BIL_TX_MEASURE27, '||
              ' ascd.OPPORTUNITY_CREATION_DATE BIL_TX_MEASURE28, '||
              ' JTF_COMMON_PVT.GetUserInfo(ascd.OPPORTUNITY_CREATED_BY) BIL_TX_MEASURE29, '||
              ' flvl1.meaning BIL_TX_MEASURE30, '||
	      ' ( CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN '||
              	' (DECODE(m.CONVERSION_RATE, NULL ,ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100),ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100))) '||
              	' ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100) *m.CONVERSION_RATE))  END ) BIL_TX_MEASURE31, '||
              ' flvl3.meaning BIL_TX_MEASURE32, '||
	      '  ''' || l_cur_conv_missing || '''  BIL_TX_MEASURE33, ' ||
	      '  ''' || l_cur_conv_missing || '''  BIL_TX_MEASURE34, ' ||
              l_oppty_url1||' BIL_TX_URL1 ,'||
              l_customer_url2||'  BIL_TX_URL2  ';


  -- FROM section
  l_from := ' FROM as_sales_credits_denorm ascd '||
                 ' ,jtf_rs_groups_denorm denorm  '||
                ' ,jtf_rs_group_usages usages  '||
                ' ,JTF_RS_RESOURCE_EXTNS_TL jrret'||
                ' ,jtf_rs_groups_tl jrgst'||
                ' ,gl_daily_rates m  '||
                ' ,as_statuses_tl  status  '||
                ' ,fnd_lookup_values flvl1'||
                ' ,fnd_lookup_values flvl2'||
                ' ,fnd_lookup_values flvl3'||
                ' ,hz_parties party'||
                ' ,AS_LLOG_STATUS_SUMMARY ss ';

l_where_clause_1 := ' WHERE ascd.decision_date BETWEEN :l_from_date AND :l_to_date  '||
                     ' AND  denorm.parent_group_id IN (&ORGANIZATION+JTF_ORG_SALES_GROUP) '||
                     ' AND denorm.LATEST_RELATIONSHIP_FLAG = ''Y'' '||
                     ' AND usages.usage =  ''SALES'''||
                     ' AND usages.group_id = denorm.group_id'||
                     ' AND ascd.sales_group_id = denorm.group_id'||
                     ' AND usages.group_id = ascd.sales_group_id'||
                     ' AND jrret.RESOURCE_ID = ascd.SALESFORCE_ID '||
                     ' AND party.party_id = ascd.customer_id '||
                     ' AND jrgst.GROUP_ID = ascd.sales_group_id '||
                     ' AND jrgst.LANGUAGE(+) =  USERENV('||'''LANG'''||') ' ||
                     ' AND jrret.LANGUAGE(+) =  USERENV('||'''LANG'''||') ' ||
                     ' AND m.CONVERSION_DATE(+)    =  ascd.decision_date'||
                     ' AND m.FROM_CURRENCY(+)   =  ascd.currency_code'||
                     ' AND m.TO_CURRENCY(+)     =  &CURRENCY+CURR'||
                     ' AND m.CONVERSION_TYPE(+) = :l_convsersion_type'||
                     ' AND ascd.credit_type_id = :l_credit_type_id'||
                     ' AND ascd.status_code = status.status_code'||
                     ' AND ascd.lead_id = ss.lead_id(+)'||
                     ' AND status.LANGUAGE(+) = USERENV('||'''LANG'''||') ' ||
                     ' AND  ascd.channel_code =  flvl1.lookup_code ' ||  -- channel code
                     ' AND  trunc(nvl(flvl1.start_date_active, SYSDATE)) <= trunc(SYSDATE)' ||  -- channel code
                    ' AND  trunc(nvl(flvl1.end_date_active, SYSDATE)) >= trunc(SYSDATE)  ' || -- channel code
                    ' AND  flvl1.enabled_flag = ''Y''  ' ||-- channel code
                    ' AND  flvl1.language = USERENV(''LANG'')' ||  -- channel code
                    ' AND  flvl1.lookup_type = ''SALES_CHANNEL'' ' ||-- channel code
                    ' AND  flvl1.view_application_id = 660 ' ||-- channel code
                    ' AND  ascd.CLOSE_REASON  = flvl2.lookup_code(+)   '||-- close reason
                    ' AND  trunc(nvl(flvl2.start_date_active(+), SYSDATE)) <= trunc(SYSDATE )  '||-- close reason
                    ' AND  trunc(nvl(flvl2.end_date_active(+), SYSDATE)) >= trunc(SYSDATE)  '||-- close reason
                    ' AND  flvl2.enabled_flag(+) = ''Y'' '||-- close reason
                    ' AND  flvl2.language(+) = USERENV(''LANG'')  '||-- close reaso
                    ' AND  flvl2.lookup_type(+) = ''ASN_OPPTY_CLOSE_REASON'' '||-- close reason
                    ' AND  flvl2.view_application_id(+) = 0   '||-- close reason
                    ' AND  ascd.CUSTOMER_CATEGORY_CODE = flvl3.lookup_code(+) '||
                    ' AND  trunc(nvl(flvl3.start_date_active(+), SYSDATE)) <= trunc(SYSDATE)   '||-- Customer category
                    ' AND  trunc(nvl(flvl3.end_date_active(+), SYSDATE)) >= trunc(SYSDATE)   '||-- Customer category
                    ' AND  flvl3.enabled_flag(+) = ''Y''  '||-- Customer category
                    ' AND  flvl3.language(+) = USERENV(''LANG'')  '|| --
                    ' AND  flvl3.lookup_type(+) = ''CUSTOMER_CATEGORY''  '||-- Customer category
                    ' AND  flvl3.view_application_id(+) = 222 ' ;




  IF l_product_category IS NOT NULL THEN
     l_from := l_from ||
         ',ENI_DENORM_HIERARCHIES edeh '||
               ',MTL_DEFAULT_CATEGORY_SETS mdcs ';

     l_where_clause_2 := ' AND mdcs.CATEGORY_SET_ID = edeh.OBJECT_ID
     		         AND mdcs.FUNCTIONAL_AREA_ID = 11
     		         AND edeh.OBJECT_TYPE = '|| '''CATEGORY_SET''
     		         AND edeh.PARENT_ID = :l_product_category
     		         AND edeh.OLTP_FLAG =  ''Y''
     		         AND mdcs.CATEGORY_SET_ID = ascd.PRODUCT_CAT_SET_ID
     		         AND edeh.CHILD_ID = ascd.PRODUCT_CATEGORY_ID ';
 END IF;
  -- WHERE section


  IF l_customer IS NOT NULL THEN
      l_where_clause_2 := l_where_clause_2 ||
         ' AND ascd.CUSTOMER_ID IN (&CUSTOMER+CUST) ';

  END IF;

  IF l_item_id IS NOT NULL THEN
      l_where_clause_2 := l_where_clause_2 ||
         ' AND ascd.ITEM_ID  =  :l_item_id ';

  END IF;

  -- Opportunity Status
  IF l_opp_status IS NOT NULL THEN
     		l_where_clause_2 := l_where_clause_2 ||
      		' AND ascd.STATUS_CODE IN (&OPP_STATUS+STAT) ';
  END IF;



 -- Sales Stage

  IF l_sales_stage IS NOT NULL THEN
     		l_where_clause_2 := l_where_clause_2 ||
      		' AND ascd.SALES_STAGE_ID IN (&SLS_STAGE+STAGE) ';
  END IF;

  -- Win Probability

  IF l_win_probability IS NOT NULL THEN
		 l_where_clause_2 := l_where_clause_2 ||
                ' AND ascd.WIN_PROBABILITY'|| l_win_probability_opr ||' to_number(:l_win_probability )';
        ELSE
		 l_where_clause_2  := l_where_clause_2 || ' AND 1 = 0 ';
	END IF;

   -- Opportunity/Lead Source
  IF l_source IS NOT NULL THEN
     l_where_clause_2 := l_where_clause_2 ||
      ' AND ascd.SOURCE_PROMOTION_ID IN (&SOURCE+SOUR)';
  END IF;

 -- Sales channel
  IF l_sales_channel IS NOT NULL THEN
     		l_where_clause_2 := l_where_clause_2 ||
      		' AND ascd.CHANNEL_CODE IN(&SLS_CHNL+CHNL)  ';
 END IF;

 -- Opportunity Name
  IF REPLACE (l_opty_name, '%',NULL) IS NOT NULL THEN
     l_where_clause_2 := l_where_clause_2 ||
      ' AND ascd.OPP_DESCRIPTION LIKE  :l_opty_name  ';
  END IF;


 -- Opportunity number
  IF l_opty_number IS NOT NULL THEN
     l_where_clause_2 := l_where_clause_2 ||
      ' AND ascd.LEAD_NUMBER LIKE &BIL_TX_OPP_NUMBER ';
  END IF;

 -- Sales Person
  IF l_sales_person IS NOT NULL THEN
     l_where_clause_2 := l_where_clause_2 ||
      ' AND ascd.SALESFORCE_ID IN  (&SLS_PRSON+PERSON) ';
  END IF;

  -- Sales Methodology
  IF l_sls_methodology IS NOT NULL THEN
     l_where_clause_2 := l_where_clause_2 ||
      ' AND ascd.SALES_METHODOLOGY_ID IN (&METHODOLOGY+METH) ';
  END IF;


  -- Partner Name
  IF l_partner_id IS NOT NULL THEN
      l_from :=  l_from ||
      ' ,( SELECT acc.lead_id ,   '||
      '  partner.party_id party_id  '||
      '  FROM HZ_PARTIES PARTNER,  '||
      '      AS_ACCESSES_ALL ACC,  '||
      '     JTF_RS_RESOURCE_EXTNS EXT,  '||
      '     hz_organization_profiles HZOP,  '||
      '     hz_relationships HZR  '||
      '    WHERE hzr.PARTY_ID = ACC.PARTNER_CUSTOMER_ID  '||
      '      AND EXT.RESOURCE_ID = ACC.SALESFORCE_ID  '||
      '      AND PARTNER.status IN (''A'' , ''I'')  '||
      '      AND HZR.subject_table_name = ''HZ_PARTIES''  '||
      '      AND HZR.object_table_name = ''HZ_PARTIES''  '||
      '      AND HZR.object_id = HZOP.party_id  '||
      '       AND HZOP.internal_flag = ''Y''  '||
      '       AND NVL(HZOP.status, ''A'') = ''A''  '||
      '       AND NVL(HZOP.effective_end_date, SYSDATE) >= SYSDATE  '||
      '       AND HZR.party_id = EXT.source_id  '||
      '       AND EXT.category = ''PARTNER''  '||
      '       AND HZR.subject_id = PARTNER.party_id  ) partner ';

     l_where_clause_2 := l_where_clause_2 || ' AND partner.party_id IN (&PARTNER+NAME) AND PARTNER.lead_id = ascd.lead_id';
  END IF;

-- GROUP BY SECTION
l_group_by := '  GROUP BY
ascd.lead_id
,ascd.OPP_DESCRIPTION
,ascd.customer_id , party.party_name
, ascd.sales_group_id, jrgst.GROUP_NAME
,jrret.RESOURCE_NAME  ,ascd.win_probability
,(CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN (DECODE(m.CONVERSION_RATE, NULL ,ascd.TOTAL_AMOUNT , ascd.TOTAL_AMOUNT))
                        ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ascd.TOTAL_AMOUNT*m.CONVERSION_RATE))  END )
,status.meaning  ,ascd.decision_date
,decode( greatest(SYSDATE, ascd.DECISION_DATE), ascd.DECISION_DATE, to_char(trunc(ascd.DECISION_DATE)-trunc(SYSDATE)),0)
,(TRUNC(SYSDATE)-trunc(ascd.OPPORTUNITY_CREATION_DATE))
,decode( greatest(SYSDATE, ascd.DECISION_DATE), SYSDATE, to_char(trunc(SYSDATE)-trunc(ascd.DECISION_DATE)),0)
,0
, ascd.LEAD_NUMBER
,  flvl2.meaning
,ascd.OPPORTUNITY_LAST_UPDATE_DATE
,JTF_COMMON_PVT.GetUserInfo(ascd.OPPORTUNITY_LAST_UPDATED_BY)
,ascd.OPPORTUNITY_CREATION_DATE
, JTF_COMMON_PVT.GetUserInfo(ascd.OPPORTUNITY_CREATED_BY)
,flvl1.meaning
, ( CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN
        (DECODE(m.CONVERSION_RATE, NULL ,ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100),ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100)))
            ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100) *m.CONVERSION_RATE))  END )
, flvl3.meaning
,''' || l_cur_conv_missing || '''
,''' || l_cur_conv_missing || '''  ' ;

l_group_by := l_group_by || ', ' ||l_oppty_url1 || ',' ||l_customer_url2;



 -- ORDER BY section
   -- sarma
   IF l_order IS NULL THEN
       l_order := '  NLSSORT(BIL_TX_MEASURE2, ''NLS_SORT=BINARY'') ';
   END IF;

    l_order_by := ' ORDER BY  '||l_order ;  -- Opportunity Name

x_custom_sql :=  l_outer_select ||l_select_1|| l_from||  l_where_clause_1||
     l_where_clause_2||l_group_by;
 x_custom_sql := x_custom_sql ||')' || l_order_by;

-- x_custom_sql :=  l_select_1|| l_from||  l_where_clause_1||
     -- l_where_clause_2||l_group_by || l_order_by;




-- insert into x1 values ('l_outer_select = ' || l_outer_select,sysdate); commit;
-- insert into x1 values ('l_select_1 = ' || l_select_1,sysdate); commit;
-- insert into x1 values ('l_from = ' || l_from,sysdate); commit;
-- insert into x1 values ('l_where_clause_1 = ' || l_where_clause_1,sysdate); commit;
-- insert into x1 values ('l_where_clause_2 = ' || l_where_clause_2,sysdate); commit;


        l_bind_ctr := 1;

        l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_custom_rec.attribute_value := l_viewby;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


	IF   REPLACE (l_opty_name, '%',NULL) IS NOT NULL  THEN
        	l_custom_rec.attribute_name :=':l_opty_name';
        	l_custom_rec.attribute_value := l_opty_name;
        	l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        	l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        	x_custom_attr.Extend();
        	x_custom_attr(l_bind_ctr):=l_custom_rec;
        	l_bind_ctr:=l_bind_ctr+1;
	END IF;
                l_custom_rec.attribute_name :=':l_period_set_name';
                l_custom_rec.attribute_value :=l_period_set_name;
                l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
                l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                x_custom_attr.Extend();
                x_custom_attr(l_bind_ctr):=l_custom_rec;
                l_bind_ctr:=l_bind_ctr+1;



        IF l_convsersion_type  IS NOT NULL THEN
                l_custom_rec.attribute_name :=':l_convsersion_type';
                l_custom_rec.attribute_value :=l_convsersion_type;
                l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
                l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                x_custom_attr.Extend();
                x_custom_attr(l_bind_ctr):=l_custom_rec;
                l_bind_ctr:=l_bind_ctr+1;
        END IF;

        IF l_opty_number  IS NOT NULL THEN
                l_custom_rec.attribute_name :=':l_opty_number';
                        l_custom_rec.attribute_value := l_opty_number;
                        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
                        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                        x_custom_attr.Extend();
                        x_custom_attr(l_bind_ctr):=l_custom_rec;
                        l_bind_ctr:=l_bind_ctr+1;
        END IF;


                l_custom_rec.attribute_name :=':l_to_period_name';
                        l_custom_rec.attribute_value := l_to_period_name;
                        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
                        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                        x_custom_attr.Extend();
                        x_custom_attr(l_bind_ctr):=l_custom_rec;
                        l_bind_ctr:=l_bind_ctr+1;


	IF l_item_id  IS NOT NULL THEN
		l_custom_rec.attribute_name :=':l_item_id';
        		l_custom_rec.attribute_value := l_item_id;
        		l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        		l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        		x_custom_attr.Extend();
        		x_custom_attr(l_bind_ctr):=l_custom_rec;
        		l_bind_ctr:=l_bind_ctr+1;
	END IF;


	IF l_product_category  IS NOT NULL THEN
        	l_custom_rec.attribute_name :=':l_product_category';
        	l_custom_rec.attribute_value := l_product_category;
        	l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        	l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        	x_custom_attr.Extend();
        	x_custom_attr(l_bind_ctr):=l_custom_rec;
        	l_bind_ctr:=l_bind_ctr+1;
	END IF;

                l_custom_rec.attribute_name :=':l_period_type';
                l_custom_rec.attribute_value := l_period_type;
                l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
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

        l_custom_rec.attribute_name :=':l_win_probability';
        l_custom_rec.attribute_value := l_win_probability;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


       l_custom_rec.attribute_name :=':l_credit_type_id';
       l_custom_rec.attribute_value := l_credit_type_id;
       l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
       l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       x_custom_attr.Extend();
       x_custom_attr(l_bind_ctr):=l_custom_rec;
       l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_from_date';
        l_custom_rec.attribute_value := TO_CHAR(l_from_date,'dd/MM/yyyy')  ;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_to_date';
        l_custom_rec.attribute_value := TO_CHAR(l_to_date,'dd/MM/yyyy') ;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


        l_custom_rec.attribute_name :=':l_rpt_str';
        l_custom_rec.attribute_value :=l_rpt_str;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;



END OPTY_AGE_RPT;
END BIL_TX_OPTY_AGE_RPT_PKG;

/
