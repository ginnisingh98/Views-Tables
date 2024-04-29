--------------------------------------------------------
--  DDL for Package Body BIL_TX_OPTY_LIST_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_TX_OPTY_LIST_RPT_PKG" AS
/* $Header: biltxolb.pls 120.25 2006/08/23 04:55:24 vselvapr ship $ */

 PROCEDURE OPTY_LIST_RPT (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql         OUT  NOCOPY VARCHAR2
                         ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_bind_ctr                  NUMBER;
    l_rpt_str                   VARCHAR2(180);
    l_viewby                    VARCHAR2(180) ;
    l_proc                      VARCHAR2(500);
    l_region_id                 VARCHAR2(150);
    g_pkg                       VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    l_sql_error_desc            VARCHAR2(4000);
    -- sql statement related
    l_custom_sql                VARCHAR2(32000);

    l_select1                    VARCHAR2(32000);
    l_select2                    VARCHAR2(32000);
    l_from                      VARCHAR2(5000);
    l_where_clause              VARCHAR2(20000);
    l_dummy_where_clause        VARCHAR2(5000);
    l_group_by                  VARCHAR2(5000);
    l_order_by                  VARCHAR2(5000);
    -- parameters
    l_period_type               VARCHAR2(5000);
    l_from_date                 DATE;
    l_to_date                   DATE;
    l_forecast_owner            VARCHAR2(5000);  -- sales credit id needs to be passed I think.
    l_sales_group               VARCHAR2(5000);
    l_sales_person              VARCHAR2(5000);
    l_opty_name                 VARCHAR2(1000);
    l_customer                  VARCHAR2(5000);
    l_source                    VARCHAR2(500);
    l_opp_status                VARCHAR2(5000);  -- multi select
    l_win_probability           VARCHAR2(100);
    l_win_probability_opr       VARCHAR2(100);
    l_sales_channel             VARCHAR2(5000);
    l_sales_stage               VARCHAR2(5000);
    l_sls_methodology           VARCHAR2(5000);
    l_product_category          VARCHAR2(5000);  -- if only prod cat is passed
    l_item_id                   VARCHAR2(5000);  -- may pass both item and prod.
    l_partner_id                VARCHAR2(5000);
    l_partner_name              VARCHAR2(5000);
    l_to_currency               VARCHAR2(5000);
    l_c_to_currency             VARCHAR2(5000);
    l_report_by                 VARCHAR2(5000);
    l_close_reason              VARCHAR2(5000);
    l_competitor                VARCHAR2(5000);
    l_opty_number               VARCHAR2(1000);
    l_total_opp_amount          VARCHAR2(1000);
    l_total_opp_amt_opr         VARCHAR2(1000);
    l_oppty_url1                VARCHAR2(1000);
    l_customer_url2             VARCHAR2(1000);
    l_url                       VARCHAR2(1000);
    l_sales_team_access         VARCHAR2(1000);
    l_credit_type_id            NUMBER;
    l_to_period_name            VARCHAR2(500);
    l_order                     VARCHAR2(5000);  -- Kiran
    l_period_set_name           VARCHAR2(500);
    l_conversion_type           VARCHAR2(500);
    l_cur_conv_missing          VARCHAR2(2000);


    BEGIN

    -- IF WE want we can get region and function from get page params
    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_LIST_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_LIST_RPT_R';
       l_proc             := 'OPTY_LIST_RPT.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_LIST_RPT_PKG.';
	    --Fix for bug 5469370,added replace function
       l_cur_conv_missing :=  replace(FND_MESSAGE.GET_STRING('BIL','BIL_TX_CUR_CONV_MIS'),'''','''''');


       l_period_set_name  := NVL(FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR'), 'Accounting');
       l_conversion_type  := nvl(FND_PROFILE.VALUE('CRMBIS:GL_CONVERSION_TYPE'), 'Corporate');


       -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;



    l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();


     l_oppty_url1 :='''pFunctionName=ASN_OPPTYDETPG&addBreadCrumb=Y&ASNReqFrmOpptyId=''||ascd.LEAD_NUMBER '; -- ASN Opportunity page link

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

           l_sales_team_access := REPLACE(l_sales_team_access , '''');

           IF l_sales_team_access = 'ST' THEN
              l_credit_type_id := FND_PROFILE.VALUE('ASN_FRCST_CREDIT_TYPE_ID');
           ELSE
                -- For now if it is not a sales team access only credit type id is passed.
              l_credit_type_id := TO_NUMBER(l_sales_team_access) ;
           END IF;

           IF l_credit_type_id IS NULL THEN
              l_credit_type_id := FND_PROFILE.VALUE('ASN_FRCST_CREDIT_TYPE_ID');
           END IF;




    -- Once PMV date fix is given change this call and defaults


     l_sql_error_desc :=
        'l_viewby			  => '||l_viewby||', '||
        'l_period_type 		  => '|| l_period_type ||', ' ||
        'l_sales_group	  => '|| l_sales_group ||', ' ||
        'l_sales_perso      => '|| l_sales_person ||', ' ||
        'l_product_category  => '|| l_product_category ||', ' ||
        'l_from_date       => '|| l_from_date ||','||
        'l_to_date       => '|| l_to_date ||','||
        'l_to_currency  => '||l_to_currency ||','||
        'l_close_reason  => '||l_close_reason ||','||
        'l_opty_number => '||l_opty_number ||','||
        'l_win_probability => '||l_win_probability||','||
        'l_win_probability_opr => '||l_win_probability_opr ||','||
        'l_total_opp_amount => '||l_total_opp_amount ||','||
        'l_total_opp_amt_opr => '||l_total_opp_amt_opr ||','||
        'l_competitor  => '||l_competitor ||','||
        'l_sales_team_access  => '||l_sales_team_access ||','||
        'l_credit_type_id => '||l_credit_type_id||','||
        'l_period_set_name => '||l_period_set_name||', '||
        'l_conversion_type => '||l_conversion_type ||', '||
        'l_report_by  => '||l_report_by;



       -- insert into zz values(l_sql_error_desc);
      --  commit;

     IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
	  	   BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
	                                    p_module => g_pkg || l_proc ,
                                      p_msg => '  Params are =>'||l_sql_error_desc);

        END IF;

   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Lead Id
	* BIL_TX_MEASURE2 = Opportunity Name
  * BIL_TX_MEASURE3 = Customer_id
	* BIL_TX_MEASURE4 = Customer Name
	* BIL_TX_MEASURE5 = Sales Id
	* BIL_TX_MEASURE6 = Sales Group
	* BIL_TX_MEASURE7 = Sales Person
	* BIL_TX_MEASURE8 = Days to close
  * BIL_TX_MEASURE9 = Win Probability
	* BIL_TX_MEASURE10 = Total Opportunity Amount
	* BIL_TX_MEASURE11 = Status
	* BIL_TX_MEASURE12 = close date  -- decision_date
  -- Product information
	* BIL_TX_MEASURE13 = Product_category_id
	* BIL_TX_MEASURE14 = Item_id
	* BIL_TX_MEASURE15 = Item description
	* BIL_TX_MEASURE16 = Amount
	* BIL_TX_MEASURE17 = Forecast Date
	* BIL_TX_MEASURE18 = Best Amount
	* BIL_TX_MEASURE19 = Forecast Amount
	* BIL_TX_MEASURE20 = Worst Amount
	-- Competitor Information
	* BIL_TX_MEASURE21 = Competitor_id  -- can be taken out
	* BIL_TX_MEASURE22 = Competitor_name
	* BIL_TX_MEASURE23 = Competitor Product_name
	* BIL_TX_MEASURE24 = Win Loss Status
	* BIL_TX_MEASURE25 =  Partner Name  Removed in 120.16
	* BIL_TX_MEASURE26 =  Close reason
	* BIL_TX_MEASURE27 =  Created Date
	* BIL_TX_MEASURE28 =  Created By
	* BIL_TX_MEASURE29 =  customer classification code
	* BIL_TX_MEASURE30 =  updated date
	* BIL_TX_MEASURE31 =  updated by
	* BIL_TX_MEASURE32 =  Opportunity Number
	* BIL_TX_MEASURE33 =  Weighted Amount
	* BIL_TX_MEASURE34 =  Sales Channel

 	* BIL_TX_URL1      = Link to Opportunity Name
 	* BIL_TX_URL2      = Link to Customer

	*******************************************************************************/

 -- SELECT SECTION





     l_select1 := 'SELECT ascd.lead_id  BIL_TX_MEASURE1 '||
       ' ,ascd.OPP_DESCRIPTION  BIL_TX_MEASURE2 '||
       ' ,ascd.CUSTOMER_ID  BIL_TX_MEASURE3 '||
       ' ,hzpt1.party_name  BIL_TX_MEASURE4 ';

     IF  l_sales_team_access = 'ST'  THEN
         l_select1 := l_select1 ||
           ' ,aca.sales_group_id  BIL_TX_MEASURE5 ';
     ELSE
        l_select1 := l_select1 ||
           ' ,ascd.sales_group_id  BIL_TX_MEASURE5 ';
     END IF;

       l_select1 := l_select1 ||
       ' ,jrgt.GROUP_NAME  BIL_TX_MEASURE6 '||
       ' ,jrre.SOURCE_NAME  BIL_TX_MEASURE7 '||
       ' ,decode( greatest(SYSDATE, ascd.DECISION_DATE), ascd.DECISION_DATE, to_char(trunc(ascd.DECISION_DATE)-trunc(SYSDATE)),NULL) BIL_TX_MEASURE8 '||
       ' ,ascd.WIN_PROBABILITY  BIL_TX_MEASURE9 '||
       ' ,( CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN (DECODE(m.CONVERSION_RATE, NULL ,ascd.TOTAL_AMOUNT , ascd.TOTAL_AMOUNT)) '||
       '   ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ascd.TOTAL_AMOUNT*m.CONVERSION_RATE))  END ) BIL_TX_MEASURE10 '||
       ' ,( CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN (DECODE(m.CONVERSION_RATE, NULL '||
       ' ,ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100) , ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100))) '||
       '    ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ROUND(ascd.TOTAL_AMOUNT*ascd.win_probability/100)*m.CONVERSION_RATE))  END ) BIL_TX_MEASURE33 '||
       ' ,asst.meaning BIL_TX_MEASURE11 '||
       ' ,ascd.DECISION_DATE  BIL_TX_MEASURE12 '||
       ' ,ascd.PRODUCT_CATEGORY_ID  BIL_TX_MEASURE13 '||
       ' ,ascd.ITEM_ID  BIL_TX_MEASURE14 '||
       ' ,NVL(msit.description,mct.description)  BIL_TX_MEASURE15 '||
       ' ,( CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN (DECODE(m.CONVERSION_RATE, NULL, ascd.SALES_CREDIT_AMOUNT, ascd.SALES_CREDIT_AMOUNT)) '||
       '    ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ascd.SALES_CREDIT_AMOUNT*m.CONVERSION_RATE))  END ) BIL_TX_MEASURE16 '||
       ' ,ascd.FORECAST_DATE  BIL_TX_MEASURE17 '||
       ' ,( CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN (DECODE(m.CONVERSION_RATE, NULL ,NVL(ascd.OPP_BEST_FORECAST_AMOUNT,0) , ascd.OPP_BEST_FORECAST_AMOUNT)) '||
       '    ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ascd.OPP_BEST_FORECAST_AMOUNT*m.CONVERSION_RATE))  END ) BIL_TX_MEASURE18 '||
       ' ,( CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN (DECODE(m.CONVERSION_RATE, NULL ,NVL(ascd.OPP_FORECAST_AMOUNT,0) , ascd.OPP_FORECAST_AMOUNT)) '||
       '    ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ascd.OPP_FORECAST_AMOUNT*m.CONVERSION_RATE))  END ) BIL_TX_MEASURE19 '||
       ' ,( CASE WHEN (ascd.currency_code = &CURRENCY+CURR)  THEN (DECODE(m.CONVERSION_RATE, NULL ,NVL(ascd.OPP_WORST_FORECAST_AMOUNT,0) , ascd.OPP_WORST_FORECAST_AMOUNT)) '||
       '    ELSE ( DECODE(m.CONVERSION_RATE, NULL, TO_NUMBER(NULL), ascd.OPP_WORST_FORECAST_AMOUNT*m.CONVERSION_RATE))  END ) BIL_TX_MEASURE20 '||
       ' ,ascd.CLOSE_COMPETITOR_ID  BIL_TX_MEASURE21 '||
       ' ,hzpt.party_name  BIL_TX_MEASURE22 '||
       ' ,acpt.COMPETITOR_PRODUCT_NAME  BIL_TX_MEASURE23 '||
       ' ,INITCAP(alcp.WIN_LOSS_STATUS)  BIL_TX_MEASURE24 '||
       ' ,flvl2.meaning   BIL_TX_MEASURE26 '||
       ' ,ascd.OPPORTUNITY_CREATION_DATE BIL_TX_MEASURE27 '||
       ' ,JTF_COMMON_PVT.GetUserInfo(ascd.OPPORTUNITY_CREATED_BY) BIL_TX_MEASURE28 '||
       ' ,flvl3.meaning   BIL_TX_MEASURE29 '||
       ' ,ascd.LAST_UPDATE_DATE BIL_TX_MEASURE30 '||
       ' ,JTF_COMMON_PVT.GetUserInfo(ascd.OPPORTUNITY_LAST_UPDATED_BY)  BIL_TX_MEASURE31 '||
       ' ,ascd.LEAD_NUMBER BIL_TX_MEASURE32 '||
       ' ,flvl1.meaning   BIL_TX_MEASURE34  '||  --ascd.CHANNEL_CODE
       ' ,ascd.credit_type_id BIL_TX_MEASURE44  ';


    l_select2 := ' , '''   ||l_cur_conv_missing || ''' BIL_TX_MEASURE46  ' ||
                 ' , '''   ||l_cur_conv_missing || ''' BIL_TX_MEASURE47  ' ||
                 ' , '''   ||l_cur_conv_missing || ''' BIL_TX_MEASURE48  ' ||
                 ' , '''   ||l_cur_conv_missing || ''' BIL_TX_MEASURE49  ' ||
                 ' , '''   ||l_cur_conv_missing || ''' BIL_TX_MEASURE50  ' ||
                 ' , '''   ||l_cur_conv_missing || ''' BIL_TX_MEASURE45  ' ||
                 ', '||l_oppty_url1||' BIL_TX_URL1'||
                 ', '||l_customer_url2||' BIL_TX_URL2 ';


     l_from := ' FROM  as_sales_credits_denorm ascd '||
       ' ,jtf_rs_groups_denorm denorm '||
       ' ,jtf_rs_group_usages usages '||
       ' ,GL_DAILY_RATES m '||
       ' ,as_lead_comp_products alcp '||
       ' ,ams_competitor_products_tl  acpt '||
       ' ,ams_competitor_products_b  acpb '||
       ' ,mtl_categories_tl mct ' ||
       ' ,mtl_system_items_tl msit  '||  -- Prod cat
       ' ,fnd_lookup_values  flvl1  '|| -- for chaneel code
       ' ,fnd_lookup_values  flvl2  '|| -- FOR close reason
       ' ,fnd_lookup_values flvl3  '||-- for customer category
       ' ,hz_parties hzpt  '||
       ' ,hz_parties hzpt1 '||
       ' ,as_statuses_tl asst '||
       ' ,jtf_rs_groups_tl jrgt '||
       ' ,jtf_rs_resource_extns jrre ';



    IF l_sales_team_access = 'ST'  THEN
        l_from :=  l_from ||  ' ,as_accesses_all aca ';
    END IF;

     -- Add only when Partner Id is passed
      IF l_partner_id IS NOT NULL THEN
           l_from :=  l_from ||
           ' ,( SELECT acc.lead_id ,   '||
           '           partner.party_id party_id  '||
           '  FROM HZ_PARTIES PARTNER,  '||
           '       AS_ACCESSES_ALL ACC,  '||
           '       JTF_RS_RESOURCE_EXTNS EXT,  '||
           '       hz_organization_profiles HZOP,  '||
           '       hz_relationships HZR  '||
           '    WHERE hzr.PARTY_ID = ACC.PARTNER_CUSTOMER_ID  '||
           '      AND EXT.RESOURCE_ID = ACC.SALESFORCE_ID  '||
           '      AND PARTNER.status IN (''A'' , ''I'')  '||
           '      AND HZR.subject_table_name = ''HZ_PARTIES''  '||
           '      AND HZR.object_table_name = ''HZ_PARTIES''  '||
           '      AND HZR.object_id = HZOP.party_id  '||
           '      AND HZOP.internal_flag = ''Y''  '||
           '      AND NVL(HZOP.status, ''A'') = ''A''  '||
           '      AND NVL(HZOP.effective_end_date, SYSDATE) >= SYSDATE  '||
           '      AND HZR.party_id = EXT.source_id  '||
           '      AND EXT.category = ''PARTNER''  '||
           '      AND HZR.subject_id = PARTNER.party_id  ) partner ';
       END IF;

   -- Dummy Where Clause
   l_dummy_where_clause := ' WHERE 1 = 2 ';


    -- WHERE section
	 IF l_report_by = 2 THEN
	     l_where_clause :=  ' WHERE  ascd.FORECAST_DATE BETWEEN  :l_from_date AND :l_to_date '||
	                        '   AND  m.conversion_date(+)    =  ascd.forecast_date ' ;
	 ELSE
	   	 l_where_clause :=  ' WHERE  ascd.DECISION_DATE BETWEEN  :l_from_date AND :l_to_date '||
	   	                    '   AND  m.conversion_date(+)    =  ascd.decision_date ' ;
	 END IF;

	  l_where_clause :=  l_where_clause ||
	       ' AND  denorm.parent_group_id IN  ( &ORGANIZATION+JTF_ORG_SALES_GROUP ) '||
         ' AND  denorm.latest_relationship_flag = ''Y''  '||
         ' AND  usages.usage = ''SALES'' '||
         ' AND  usages.group_id = denorm.group_id   '||
         ' AND  ascd.credit_type_id = :l_credit_type_id  '||
         ' AND  m.FROM_CURRENCY(+)   =  ascd.currency_code '||
         ' AND  m.TO_CURRENCY(+)     =  &CURRENCY+CURR '||
         ' AND  m.CONVERSION_TYPE(+)  = :l_conversion_type '||
         ' AND  ascd.lead_id = alcp.LEad_id(+) '||
         ' AND  ascd.lead_line_id = alcp.lead_line_id(+) '||
         ' AND  alcp.competitor_product_id =  acpt.competitor_product_id(+) '||
         ' AND  acpt.competitor_product_id = acpb.competitor_product_id(+) '||
         ' AND  acpt.language(+) = USERENV(''LANG'') '||
         ' AND  TRUNC(NVL(acpb.start_date, SYSDATE)) <=  TRUNC(SYSDATE) '||
         ' AND  TRUNC(NVL(acpb.end_date, SYSDATE)) >=  TRUNC(SYSDATE) '||
         ' AND  acpb.competitor_party_id = hzpt.party_id (+) '||
         ' AND  ascd.CUSTOMER_ID = hzpt1.party_id '||
        '  AND  ascd.item_id = msit.inventory_item_id(+) '||
        '  AND  ascd.organization_id  = msit.organization_id (+) '||
        '  AND  msit.language (+) = USERENV(''LANG'') '||
        '  AND  ascd.PRODUCT_CATEGORY_ID = mct.CATEGORY_ID '||   -- Product desc
        '  AND  mct.language = USERENV(''LANG'') '||   -- Product desc
        '  AND  jrgt.GROUP_ID  = denorm.group_id '||  -- For GRP
        '  AND  jrgt.LANGUAGE = USERENV( ''LANG'' ) '|| -- For GRP
        '  AND  ascd.channel_code =  flvl1.lookup_code '||  -- channel code
        '  AND  trunc(nvl(flvl1.start_date_active, SYSDATE)) <= trunc(SYSDATE)'||  -- channel code
        '  AND  trunc(nvl(flvl1.end_date_active, SYSDATE)) >= trunc(SYSDATE) '||  -- channel code
        '  AND  flvl1.enabled_flag = ''Y'' '||  -- channel code
        '  AND  flvl1.language = USERENV(''LANG'') '|| -- channel code
        '  AND  flvl1.lookup_type = ''SALES_CHANNEL'' '|| -- channel code
        '  AND  flvl1.view_application_id = 660  '|| -- channel code
        '  AND  ascd.STATUS_CODE = asst.status_code '|| --  status code
        '  AND  asst.language= userenv(''LANG'')  '|| -- status code
        '  AND  ascd.CLOSE_REASON  = flvl2.lookup_code(+) '||  -- close reason
        '  AND  trunc(nvl(flvl2.start_date_active(+), SYSDATE)) <= trunc(SYSDATE ) '|| -- close reason
        '  AND  trunc(nvl(flvl2.end_date_active(+), SYSDATE)) >= trunc(SYSDATE) '|| -- close reason
        '  AND  flvl2.enabled_flag(+) = ''Y'' '|| -- close reason
        '  AND  flvl2.language(+) = USERENV(''LANG'') '|| -- close reason
        '  AND  flvl2.lookup_type(+) = ''ASN_OPPTY_CLOSE_REASON'' '|| -- close reason
        '  AND  flvl2.view_application_id(+) = 0  '|| -- close reason
        '  AND  ascd.CUSTOMER_CATEGORY_CODE = flvl3.lookup_code(+) '||
        '  AND  trunc(nvl(flvl3.start_date_active(+), SYSDATE)) <= trunc(SYSDATE) '|| -- Customer category
        '  AND  trunc(nvl(flvl3.end_date_active(+), SYSDATE)) >= trunc(SYSDATE) '|| -- Customer category
        '  AND  flvl3.enabled_flag(+) = ''Y'' '|| -- Customer category
        '  AND  flvl3.language(+) = USERENV(''LANG'') '|| --
        '  AND  flvl3.lookup_type(+) = ''CUSTOMER_CATEGORY'' '|| -- Customer category
        '  AND  flvl3.view_application_id(+) = 222 ';      -- Customer category



     IF l_sales_team_access = 'ST'  THEN

        l_where_clause :=  l_where_clause ||
         ' AND  aca.sales_group_id = denorm.group_id '||
         ' AND  usages.group_id = aca.sales_group_id '||
         ' AND  aca.lead_id = ascd.lead_id '||
         ' AND  NVL(aca.OPEN_FLAG ,''N'') = ''Y'' '||
         ' AND  aca.LEAD_ID IS NOT NULL ' ||
         ' AND  jrre.resource_id  = ACA.SALESFORCE_ID ' ;

         IF l_partner_id IS NOT NULL THEN
            l_where_clause :=  l_where_clause ||
             ' AND  aca.lead_id = PARTNER.lead_id (+)  ';
         END IF;
    ELSE
        -- For revenue and Non revenue
        l_where_clause :=  l_where_clause ||
	       ' AND  ascd.sales_group_id = denorm.group_id '||
         ' AND  usages.group_id = ascd.sales_group_id '||
         ' AND  jrre.resource_id  = ascd.SALESFORCE_ID ' ;

       IF l_partner_id IS NOT NULL THEN
          l_where_clause :=  l_where_clause ||
             '  AND  ascd.lead_id = PARTNER.lead_id (+)  ';
       END IF;
    END IF;


  -- FROM section


  IF l_product_category IS NOT NULL THEN

     l_from := l_from ||
         ',ENI_DENORM_HIERARCHIES edeh '||
	       ',MTL_DEFAULT_CATEGORY_SETS mdcs ';
	END IF;


	IF l_product_category IS NOT NULL THEN

	   l_where_clause := l_where_clause ||
	       ' AND  mdcs.FUNCTIONAL_AREA_ID = 11 '||
	       ' AND  mdcs.CATEGORY_SET_ID = edeh.OBJECT_ID '||
	       ' AND  edeh.OBJECT_TYPE = ''CATEGORY_SET''  '||
         ' AND  edeh.PARENT_ID = :l_product_category  '||  -- pass product cat id.
         ' AND  edeh.OLTP_FLAG = ''Y'' '||
         ' AND  mdcs.CATEGORY_SET_ID = ascd.PRODUCT_CAT_SET_ID '||
         ' AND  edeh.CHILD_ID = ascd.PRODUCT_CATEGORY_ID ';
  END IF;
  IF l_item_id IS NOT NULL THEN
      l_where_clause := l_where_clause ||
         ' AND ascd.ITEM_ID  =  :l_item_id ';
  END IF;


  -- Sales Person (MULTI SELECT)
  IF l_sales_person IS NOT NULL THEN
      l_where_clause := l_where_clause ||
      ' AND  ascd.SALESFORCE_ID IN ( &SLS_PRSON+PERSON ) ';
  END IF;



  -- Opportunity Name
  IF l_opty_name IS NOT NULL THEN
     l_where_clause := l_where_clause ||
      ' AND ascd.OPP_DESCRIPTION LIKE    &BIL_TX_OPTY_NAME ';    --:l_opty_name ';
  END IF;

   -- Opportunity/Lead Source
  IF l_source IS NOT NULL THEN
     l_where_clause := l_where_clause ||
      ' AND ascd.SOURCE_PROMOTION_ID = &SOURCE+SOUR ';
  END IF;

  -- Opportunity Status (MS)
  IF l_opp_status IS NOT NULL THEN
     l_where_clause := l_where_clause ||
     ' AND ascd.STATUS_CODE IN ( &OPP_STATUS+STAT ) ';
  END IF;

  -- Win Probability
  IF l_win_probability IS NOT NULL THEN
     l_win_probability := TO_NUMBER(REPLACE(l_win_probability,',',NULL)); -- strip off commas

     l_where_clause := l_where_clause ||
     ' AND ascd.WIN_PROBABILITY  '|| l_win_probability_opr ||' :l_win_probability ';
  END IF;

  -- Sales channel (MS)
  IF l_sales_channel IS NOT NULL THEN
     l_where_clause := l_where_clause ||
     ' AND ascd.CHANNEL_CODE IN ( &SLS_CHNL+CHNL )';
  END IF;

  -- Sales Stage
  IF l_sales_stage IS NOT NULL THEN
     l_where_clause := l_where_clause ||
      ' AND ascd.SALES_STAGE_ID = &SLS_STAGE+STAGE ';
  END IF;


  -- Sales Methodology
  IF l_sls_methodology IS NOT NULL THEN
     l_where_clause := l_where_clause ||
      ' AND ascd.SALES_METHODOLOGY_ID = &METHODOLOGY+METH ';
  END IF;


  -- Close Reason
  IF l_close_reason IS NOT NULL THEN
     l_where_clause := l_where_clause ||
      ' AND ascd.CLOSE_REASON = &CLOSE+REASON ';
  END IF;

  -- Competitor
  IF l_competitor IS NOT NULL THEN
     l_where_clause := l_where_clause ||
      ' AND acpb.competitor_party_id = &COMPTETOR+COMP ';
  END IF;

  -- customer (MULTI SELECT)
  IF l_customer IS NOT NULL THEN
     l_where_clause := l_where_clause ||
     ' AND ascd.CUSTOMER_ID IN ( &CUSTOMER+CUST )';
  END IF;


  -- Opportunity Number  PARTIAL WILD CARD ALSO SHOULD WORK
  IF l_opty_number IS NOT NULL THEN
     l_where_clause := l_where_clause ||
     ' AND ascd.LEAD_NUMBER LIKE   &BIL_TX_OPP_NUMBER '; --  :l_opty_number ';
  END IF;


  IF l_total_opp_amount IS NOT NULL THEN

     l_total_opp_amount := TO_NUMBER(REPLACE(l_total_opp_amount,',',NULL));  -- strip off commas

     l_where_clause := l_where_clause ||
     ' AND ascd.TOTAL_AMOUNT  '|| l_total_opp_amt_opr  ||' :l_total_opp_amount ';
  END IF;

  -- Partner
  IF l_partner_id IS NOT NULL THEN
     l_where_clause := l_where_clause ||
     ' AND partner.party_id IN ( &PARTNER+NAME )  ';
  END IF;


    l_order_by := ' ORDER BY BIL_TX_MEASURE1, BIL_TX_MEASURE3, BIL_TX_MEASURE5, BIL_TX_MEASURE7, BIL_TX_MEASURE13,BIL_TX_MEASURE21 ';



   IF l_parameter_valid THEN
      x_custom_sql :=  l_custom_sql||l_select1||l_select2||l_from||l_where_clause||l_order_by ;
   ELSE
      x_custom_sql :=  l_custom_sql||l_select1||l_select2||l_from||l_dummy_where_clause ;
   END IF;


	 IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
		   BIL_TX_UTIL_RPT_PKG.writeQuery(p_pkg   => g_pkg,
				                              p_proc  => l_proc,
				                              p_query => x_custom_sql);
	 END IF;



	    l_bind_ctr := 1;

        l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_custom_rec.attribute_value := l_viewby;
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


        l_custom_rec.attribute_name :=':l_product_category';
        l_custom_rec.attribute_value :=l_product_category;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_item_id';
        l_custom_rec.attribute_value := l_item_id;
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



        l_custom_rec.attribute_name :=':l_period_set_name';
        l_custom_rec.attribute_value :=l_period_set_name;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


        l_custom_rec.attribute_name :=':l_conversion_type';
        l_custom_rec.attribute_value :=l_conversion_type;
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
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_total_opp_amt_opr';
        l_custom_rec.attribute_value :=l_total_opp_amt_opr;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_total_opp_amount';
        l_custom_rec.attribute_value := l_total_opp_amount;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_to_period_name';
        l_custom_rec.attribute_value :=l_to_period_name;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
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


        l_custom_rec.attribute_name :=':l_viewby';
        l_custom_rec.attribute_value := l_viewby;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

END OPTY_LIST_RPT;

END BIL_TX_OPTY_LIST_RPT_PKG;


/
