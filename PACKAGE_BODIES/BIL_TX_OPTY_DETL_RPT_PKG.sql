--------------------------------------------------------
--  DDL for Package Body BIL_TX_OPTY_DETL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_TX_OPTY_DETL_RPT_PKG" AS
/* $Header: biltxodb.pls 120.15 2006/01/03 15:32 syeddana ship $ */

 PROCEDURE OPP_DETL_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql         OUT  NOCOPY VARCHAR2
                    ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(100);
    l_where_clause              VARCHAR2(10000);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);
    l_period_set_name           VARCHAR2(500);
    l_conversion_type           VARCHAR2(500);
    l_cur_conv_missing          VARCHAR2(2000);



    BEGIN

    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_RPT_R';
       l_proc             := 'OPP_DETL_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';


        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;


       l_period_set_name  := NVL(FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR'), 'Accounting');
       l_conversion_type  := nvl(FND_PROFILE.VALUE('CRMBIS:GL_CONVERSION_TYPE'), 'Corporate');

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();


        -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;




   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Opportunity Name
	* BIL_TX_MEASURE2 = Sales Channel
  * BIL_TX_MEASURE3 = Close reason
	* BIL_TX_MEASURE4 = Opportunity Number
	* BIL_TX_MEASURE5 = Total Opportunity Amount
	* BIL_TX_MEASURE6 = Close date
	* BIL_TX_MEASURE7 = Customer Name
  * BIL_TX_MEASURE8 = Total Forecast Amount
	* BIL_TX_MEASURE9 = Creation Date
	* BIL_TX_MEASURE10 = Customer Address
	* BIL_TX_MEASURE11 = Currency
	* BIL_TX_MEASURE12 = Created By
	* BIL_TX_MEASURE13 = Status
	* BIL_TX_MEASURE14 = Methodology
	* BIL_TX_MEASURE15 = Updated date
	* BIL_TX_MEASURE16 = Win Probability
	* BIL_TX_MEASURE17 = Sales Stage
	* BIL_TX_MEASURE18 = Updated By

	*******************************************************************************/


  l_custom_sql := ' SELECT OpportunityEO.description BIL_TX_MEASURE1,  '||
      ' flv.meaning BIL_TX_MEASURE2,   '||
      ' FLV2.MEANING BIL_TX_MEASURE3,  '||
      ' OpportunityEO.lead_id BIL_TX_MEASURE4,   '||
      ' OpportunityEO.total_amount BIL_TX_MEASURE5,   '||
      ' OpportunityEO.decision_date BIL_TX_MEASURE6,  '||
      ' hp.party_name BIL_TX_MEASURE7,  '||
      ' (SELECT SUM(opp_forecast_amount) FROM as_sales_credits ascs  '||
      '   WHERE ascs.lead_id = OpportunityEO.lead_id AND ascs.credit_type_id = :l_credit_type_id ) BIL_TX_MEASURE8,  '||
      ' OpportunityEO.creation_date BIL_TX_MEASURE9,   '||
      ' hz_format_pub.format_address(hl.location_id, null, null, '', '', null, null,null, null) || decode(ftt.territory_short_name, null, null, '', ''||ftt.territory_short_name) BIL_TX_MEASURE10,  '||
      ' fc.name  BIL_TX_MEASURE11,  '||
      ' JTF_COMMON_PVT.GetUserInfo(OpportunityEO.CREATED_BY )  BIL_TX_MEASURE12,  '||
      ' astl.meaning  BIL_TX_MEASURE13,   '||
      ' asmt.sales_methodology_name  BIL_TX_MEASURE14,  '||
      ' OpportunityEO.LAST_UPDATE_DATE BIL_TX_MEASURE15,  '||
      ' OpportunityEO.win_probability BIL_TX_MEASURE16,   '||
      ' asst.name BIL_TX_MEASURE17,  '||
      ' JTF_COMMON_PVT.GetUserInfo(OpportunityEO.LAST_UPDATE_LOGIN) BIL_TX_MEASURE18  ';


l_where_clause :=    ' FROM as_leads_all OpportunityEO,  '||
   '      hz_parties hp,   '||
   '      hz_party_sites hps,  '||
   '      hz_locations hl,  '||
   '      fnd_territories_tl ftt, '||
   '      fnd_currencies_tl fc, '||
   '      fnd_lookup_values flv, '||
   '      fnd_lookup_values flv2, '||
   '      as_statuses_tl astl, '||
   '      as_sales_methodology_tl asmt, '||
   '      as_sales_stages_all_tl asst '||
   ' WHERE OpportunityEO.customer_id = hp.party_id   '||
   ' AND OpportunityEO.address_id = hps.party_site_id(+)   '||
   ' AND OpportunityEO.customer_id = hps.party_id (+) '||
   ' AND hps.location_id = hl.location_id (+)  '||
   ' AND hl.country = ftt.territory_code (+)  '||
   ' AND ftt.language (+) = USERENV(''LANG'')  '||
   ' AND OpportunityEO.currency_code = fc.CURRENCY_CODE(+) '||
   ' AND fc.LANGUAGE = USERENV(''LANG'') '||
   ' and OpportunityEO.channel_code = flv.lookup_code '||
   ' AND flv.enabled_flag = ''Y''   '||
   ' AND FLV.language = USERENV(''LANG'')  '||
   ' AND flv.lookup_type = ''SALES_CHANNEL''  '||
   ' AND flv.view_application_id = 660 '||
   ' AND trunc(nvl(flv.start_date_active, SYSDATE)) <= trunc(SYSDATE)  '||
   ' AND trunc(nvl(flv.end_date_active, SYSDATE)) >= trunc(SYSDATE)  '||
   ' AND OpportunityEO.close_reason = flv2.lookup_code(+) '||
   ' AND flv2.lookup_type(+) = ''ASN_OPPTY_CLOSE_REASON''  '||
   ' AND flv2.view_application_id(+) = 0 '||
   ' AND flv2.enabled_flag(+) = ''Y''  '||
   ' AND flv2.language(+) = USERENV(''LANG'') '||
   ' AND trunc(nvl(flv2.start_date_active, SYSDATE)) <= trunc(SYSDATE)  '||
   ' AND trunc(nvl(flv2.end_date_active, SYSDATE)) >= trunc(SYSDATE) '||
   ' AND opportunityEO.status = astl.status_code   '||
   ' AND astl.language = userenv(''LANG'')  '||
   ' AND OpportunityEO.sales_methodology_id = asmt.sales_methodology_id (+) '||
   ' AND asmt.language(+) = USERENV (''LANG'')  '||
   ' AND OpportunityEO.sales_stage_id  =  asst.sales_stage_id(+)  '||
   ' AND asst.language(+) = USERENV(''LANG'')    '||
   ' AND OpportunityEO.lead_id = :l_lead_id  ';



	     x_custom_sql :=  l_custom_sql ||l_where_clause  ;

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


        l_custom_rec.attribute_name :=':l_rpt_str';
        l_custom_rec.attribute_value :=l_rpt_str;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value := l_lead_id;
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


        l_custom_rec.attribute_name :=':l_viewby';
        l_custom_rec.attribute_value := l_viewby;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

END OPP_DETL_TAB;

PROCEDURE OPP_FLEX_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql         OUT  NOCOPY VARCHAR2
                    ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(100);
    l_where_clause              VARCHAR2(1000);
    l_lead_id                   VARCHAR2(100);
    l_cust_id                   VARCHAR2(100) ;
    l_credit_type_id            VARCHAR2(100);


    BEGIN


    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_FLEX_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_FLEX_RPT_R';
       l_proc             := 'OPP_FLEX_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';


        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;


       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();


        -- code for a procedure to get parameter values.
         BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;


   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = attribute1
	* BIL_TX_MEASURE2 = attribute2
  * BIL_TX_MEASURE3 = attribute3
	* BIL_TX_MEASURE4 = attribute4
	* BIL_TX_MEASURE5 = attribute5
	* BIL_TX_MEASURE6 = attribute6
	* BIL_TX_MEASURE7 = attribute7
  * BIL_TX_MEASURE8 = attribute8
	* BIL_TX_MEASURE9 = attribute9
	* BIL_TX_MEASURE10 = attribute10
	* BIL_TX_MEASURE11 = attribute11
	* BIL_TX_MEASURE12 = attribute12
	* BIL_TX_MEASURE13 = attribute13
	* BIL_TX_MEASURE14 = attribute14
	* BIL_TX_MEASURE15 = attribute15
	* BIL_TX_MEASURE16 = Attribute Category


	*******************************************************************************/




l_custom_sql := ' SELECT  OpportunityEO.attribute1 BIL_TX_MEASURE1,  '||
          ' OpportunityEO.attribute2 BIL_TX_MEASURE2,  '||
          ' OpportunityEO.attribute3 BIL_TX_MEASURE3,  '||
          ' OpportunityEO.attribute4 BIL_TX_MEASURE4,  '||
          ' OpportunityEO.attribute5 BIL_TX_MEASURE5,  '||
          ' OpportunityEO.attribute6 BIL_TX_MEASURE6,  '||
          ' OpportunityEO.attribute7 BIL_TX_MEASURE7,  '||
          ' OpportunityEO.attribute8 BIL_TX_MEASURE8,  '||
          ' OpportunityEO.attribute9 BIL_TX_MEASURE9,  '||
          ' OpportunityEO.attribute10 BIL_TX_MEASURE10,  '||
          ' OpportunityEO.attribute11 BIL_TX_MEASURE11,  '||
          ' OpportunityEO.attribute12 BIL_TX_MEASURE12,  '||
          ' OpportunityEO.attribute13 BIL_TX_MEASURE13,  '||
          ' OpportunityEO.attribute14 BIL_TX_MEASURE14,  '||
          ' OpportunityEO.attribute15 BIL_TX_MEASURE15,  '||
          ' OpportunityEO.attribute_category BIL_TX_MEASURE16  '||
          ' FROM as_leads_all OpportunityEO ' ||
          ' WHERE  OpportunityEO.lead_id = :l_lead_id  ';
    /*
      IF l_lead_id IS NULL THEN
         l_where_clause :=  ' WHERE  1 = 2 ';
      ELSE
         l_where_clause :=  ' WHERE  OpportunityEO.lead_id = :l_lead_id  ';
      END IF;
      */

	    -- x_custom_sql :=  l_custom_sql||l_where_clause ;

	     x_custom_sql :=  l_custom_sql;

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


        l_custom_rec.attribute_name :=':l_rpt_str';
        l_custom_rec.attribute_value :=l_rpt_str;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value := l_lead_id;
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

END OPP_FLEX_TAB;

PROCEDURE PRODUCTS_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                                 ,x_custom_sql         OUT  NOCOPY VARCHAR2
                                 ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(180);
    l_viewby                    VARCHAR2(180) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(500);
    l_view_param                VARCHAR2(500);
    l_page_period_type          VARCHAR2(100);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_to_currency               VARCHAR2(100);
    l_period_type               VARCHAR2(100);
    l_period_name               VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);
    l_period_set_name           VARCHAR2(500);
    l_conversion_type           VARCHAR2(500);
    l_sg_id                     VARCHAR2(200);

    BEGIN
    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_PROD_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_PROD_RPT_R';
       l_proc             := 'PRODUCTS_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';

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

        -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;


   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = lead Id
	* BIL_TX_MEASURE2 = Product category id
  * BIL_TX_MEASURE3 = Item id
	* BIL_TX_MEASURE4 = Product
	* BIL_TX_MEASURE5 = UOM
	* BIL_TX_MEASURE6 = Quantity
	* BIL_TX_MEASURE7 = Amount
	* BIL_TX_MEASURE8 = sales_group_id
	* BIL_TX_MEASURE9 = sales Group
	* BIL_TX_MEASURE10 = Forecast Owner
	* BIL_TX_MEASURE11 = Forecast_Type
	* BIL_TX_MEASURE12 = Best
	* BIL_TX_MEASURE13 = Forecast
	* BIL_TX_MEASURE14 = Worst
	* BIL_TX_MEASURE15 = CLOSE COMPETITOR ID
	* BIL_TX_MEASURE16 = COMPETITOR NAME
	* BIL_TX_MEASURE17 = Comp Product
	* BIL_TX_MEASURE18 = Win/Loss Status
	*******************************************************************************/

   l_custom_sql :=  ' SELECT ascd.lead_id  BIL_TX_MEASURE1   '||
                    ' ,ascd.PRODUCT_CATEGORY_ID  BIL_TX_MEASURE2    '||
                    ' ,ascd.ITEM_ID  BIL_TX_MEASURE3     '||
                    ' ,NVL(msit.description, mct.description)  BIL_TX_MEASURE4   '||
                    ' ,mumt.DESCRIPTION BIL_TX_MEASURE5    '||
                    ' ,ascd.QUANTITY BIL_TX_MEASURE6     '||
                    ' ,ascd.SALES_CREDIT_AMOUNT BIL_TX_MEASURE7    '||
                    ' ,ascd.sales_group_id  BIL_TX_MEASURE8    '||
                    ' ,jrgt.GROUP_NAME  BIL_TX_MEASURE9     '||
                    ' ,jrre.SOURCE_NAME  BIL_TX_MEASURE10    '||
                    ' ,osct.name  BIL_TX_MEASURE11    '||
                    ' ,ascd.OPP_BEST_FORECAST_AMOUNT BIL_TX_MEASURE12    '||
                    ' ,ascd.OPP_FORECAST_AMOUNT BIL_TX_MEASURE13    '||
                    ' ,ascd.OPP_WORST_FORECAST_AMOUNT  BIL_TX_MEASURE14    '||
                    ' ,ascd.CLOSE_COMPETITOR_ID  BIL_TX_MEASURE15    '||
                    ' ,hzpt.party_name  BIL_TX_MEASURE16   '||
                    ' ,acpt.COMPETITOR_PRODUCT_NAME  BIL_TX_MEASURE17    '||
                    ' ,INITCAP(alcp.WIN_LOSS_STATUS)  BIL_TX_MEASURE18    '||
                    ' FROM as_sales_credits_denorm ascd  '||
                    '  ,as_lead_comp_products alcp '||
                    '  ,ams_competitor_products_tl  acpt  '||
                    '  ,oe_sales_credit_types osct  '||
                    '  ,mtl_system_items_tl msit   '||
                    '  ,mtl_categories_tl mct  '||
                    '  ,mtl_units_of_measure_tl mumt  '||
                    '  ,ams_competitor_products_b acpb '||
                    '  ,hz_parties hzpt '||
                    '  ,jtf_rs_groups_tl jrgt  '||
                    '  ,jtf_rs_resource_extns jrre '||
                 ' WHERE ascd.LEAD_ID = :l_lead_id '||
                 '  AND  ascd.lead_id = alcp.LEad_id(+)  '||
                 '  AND  ascd.lead_line_id = alcp.lead_line_id(+)  '||
                 '  AND  alcp.competitor_product_id = acpt.competitor_product_id(+)  '||
                 '  AND  acpt.language(+) = USERENV(  ''LANG''  ) '||
                 '  AND  acpt.competitor_product_id = acpb.competitor_product_id(+) '||
                 '  AND  TRUNC(NVL(acpb.start_date, SYSDATE)) <=  TRUNC(SYSDATE) '||
                 '  AND  TRUNC(NVL(acpb.end_date, SYSDATE)) >=  TRUNC(SYSDATE) '||
                 '  AND  osct.SALES_CREDIT_TYPE_ID = ascd.CREDIT_TYPE_ID  '||
                 '  AND  osct.ENABLED_FLAG =   ''Y''  '||
                 '  AND  ascd.product_category_id = mct.category_id '||
                 '  AND  ascd.item_id = msit.inventory_item_id(+)  '||
                 '  AND  ascd.organization_id  = msit.organization_id(+)  '||
                 '  AND  msit.language(+) = USERENV(  ''LANG''  )   '||
                 '  AND  mct.language = USERENV( ''LANG''  )  '||
                 '  AND  acpb.competitor_party_ID = hzpt.party_id(+) '||
                 '  AND  jrgt.GROUP_ID  = ascd.sales_group_id '||
                 '  AND  jrgt.LANGUAGE = USERENV( ''LANG'' ) '||
                 '  AND  jrre.resource_id  = ascd.SALESFORCE_ID '||
                 '  AND  ascd.UOM_CODE = mumt.UOM_CODE(+) '||
                 '  AND  mumt.LANGUAGE(+) =  USERENV( ''LANG'' ) '||
                 ' ORDER BY ascd.PRODUCT_CATEGORY_ID  ' ;




	   x_custom_sql :=  l_custom_sql ;

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

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value :=l_lead_id;
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

END PRODUCTS_TAB;


PROCEDURE SALES_TEAM_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                                 ,x_custom_sql         OUT  NOCOPY VARCHAR2
                                 ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(180);
    l_viewby                    VARCHAR2(180) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(500);
    l_view_param                VARCHAR2(500);
    l_page_period_type          VARCHAR2(100);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);

    BEGIN
    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_STEAM_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_STEAM_RPT_R';
       l_proc             := 'SALES_TEAM_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';


        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

        -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;



   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Sales Person
	* BIL_TX_MEASURE2 = Job Title
  * BIL_TX_MEASURE3 = Sales Group
	* BIL_TX_MEASURE4 = Phone
	* BIL_TX_MEASURE5 = Email
	* BIL_TX_MEASURE6 = Owner
	* BIL_TX_MEASURE7 = Contributor

	*******************************************************************************/



  l_custom_sql :=  ' SELECT jrt.resource_name BIL_TX_MEASURE1,  '||
             ' jrb.source_job_title  BIL_TX_MEASURE2, '||
             ' jrgt.group_name BIL_TX_MEASURE3 ,'||
             ' jrb.source_phone BIL_TX_MEASURE4, '||
             ' jrb.source_email BIL_TX_MEASURE5, '||
             ' DECODE(OpportunityAccessEO.owner_flag, ''Y'', ''bischeck.gif'',NULL) BIL_TX_MEASURE6, '||
             ' DECODE(OpportunityAccessEO.contributor_flag, ''Y'', ''bischeck.gif'',NULL) BIL_TX_MEASURE7 '||
             ' FROM    jtf_rs_resource_extns jrb, '||
             '         jtf_rs_resource_extns_tl jrt, '||
             '         jtf_rs_groups_tl jrgt, '||
             '         as_accesses_all  OpportunityAccessEO '||
             ' WHERE   OpportunityAccessEO.salesforce_id = jrb.resource_id '||
             ' AND     jrb.resource_id = jrt.resource_id '||
             ' AND     jrb.category  = jrt.category '||
             ' AND     jrt.language = USERENV(''LANG'') '||
             ' AND     OpportunityAccessEO.sales_lead_id IS NULL '||
             ' AND     OpportunityAccessEO.lead_id IS NOT NULL '||
             ' AND     jrb.category = ''EMPLOYEE'' '||
             ' AND     OpportunityAccessEO.sales_group_id = jrgt.GROUP_ID '||
             ' AND     jrgt.language = USERENV(''LANG'') '||
             ' AND     OpportunityAccessEO.lead_id = :l_lead_id ' ||
             ' ORDER BY BIL_TX_MEASURE1 ' ;




	   x_custom_sql :=  l_custom_sql ;


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

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value :=l_lead_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
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

END SALES_TEAM_TAB;

PROCEDURE PARTNER_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                                 ,x_custom_sql         OUT  NOCOPY VARCHAR2
                                 ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(180);
    l_viewby                    VARCHAR2(180) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(500);
    l_view_param                VARCHAR2(500);
    l_page_period_type          VARCHAR2(100);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);


    BEGIN

    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_PTNR_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_PTNR_RPT_R';
       l_proc             := 'PARTNER_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';



        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();


         -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;

   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Lead Id
	* BIL_TX_MEASURE2 = Partner Customer Id
  * BIL_TX_MEASURE3 = Partner Name
	* BIL_TX_MEASURE4 = Address
	* BIL_TX_MEASURE5 = Level
	* BIL_TX_MEASURE6 = Type
	* BIL_TX_MEASURE7 = Last Offered Date
	* BIL_TX_MEASURE8 = Prefereed
	* BIL_TX_MEASURE9 = Contact
	* BIL_TX_MEASURE10 = Assignment Status

	*******************************************************************************/


 l_custom_sql := ' SELECT  PvExternalSalesteamEO.lead_id BIL_TX_MEASURE1, '||
        ' PvExternalSalesteamEO.PARTNER_CUSTOMER_ID BIL_TX_MEASURE2, '||
        ' PARTNER.PARTY_NAME  BIL_TX_MEASURE3, '||
        ' ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS_LABEL(Null, HZL.ADDRESS1, HZL.ADDRESS2, HZL.ADDRESS3, HZL.ADDRESS4, HZL.CITY, HZL.COUNTY, '||
        ' HZL.STATE, HZL.PROVINCE, HZL.POSTAL_CODE, HZL.COUNTRY, HZL.COUNTRY, Null, Null, Null, Null, Null, Null, NULL, NULL, 2000, '||
        ' 1, 1) BIL_TX_MEASURE4, '||
        '  T.DESCRIPTION   BIL_TX_MEASURE5, '||
        ' PV_MATCH_V3_PUB.get_partner_types(PvExternalSalesteamEO.PARTNER_CUSTOMER_ID) BIL_TX_MEASURE6, '||
        ' to_char(PVPP.oppty_last_offered_date, FND_PROFILE.VALUE(''ICX_DATE_FORMAT_MASK'')) BIL_TX_MEASURE7, '||
        ' DECODE( PV_MATCH_V3_PUB.pref_partner_flag(PvExternalSalesteamEO.LEAD_ID, PvExternalSalesteamEO.PARTNER_CUSTOMER_ID), ''Y'', ''bischeck.gif'',NULL) BIL_TX_MEASURE8, '||
        ' Decode(PARTNER.primary_phone_country_code,NULL, '''',PARTNER.primary_phone_country_code||''-'')|| Decode(PARTNER.primary_phone_area_code, '||
        ' NULL, '''',PARTNER.primary_phone_area_code||''-'')|| DECODE(PARTNER.primary_phone_number, NULL, '''', '||
        ' PARTNER.primary_phone_number||''-'')|| DECODE(PARTNER.primary_phone_extension, NULL, '''',PARTNER.primary_phone_extension) BIL_TX_MEASURE9, '||
        ' PV_MATCH_V3_PUB.get_assign_status_meaning( PvExternalSalesteamEO.lead_id, PvExternalSalesteamEO.PARTNER_CUSTOMER_ID) BIL_TX_MEASURE10 '||
' FROM AS_ACCESSES_ALL PvExternalSalesteamEO, '||
     ' HZ_PARTIES PARTNER, '||
     ' PV_PARTNER_PROFILES PVPP, '||
     ' HZ_PARTY_SITES HZPS, '||
     ' HZ_LOCATIONS HZL, '||
     ' FND_LOOKUP_VALUES fndlv ,   '||
     ' PV_ATTRIBUTE_CODES_TL T ,  '||
     ' PV_ATTRIBUTE_CODES_B B '||
  ' WHERE PVPP.PARTNER_ID = PvExternalSalesteamEO.PARTNER_CUSTOMER_ID    '||
  ' AND  PVPP.PARTNER_RESOURCE_ID = PvExternalSalesteamEO.SALESFORCE_ID    '||
  ' AND  PVPP.PARTNER_PARTY_ID = PARTNER.party_id    '||
  ' AND  HZPS.party_site_id(+) = PvExternalSalesteamEO.PARTNER_ADDRESS_ID    '||
  ' AND  HZPS.location_id = HZL.location_id (+)   '||
  ' AND  fndlv.lookup_code(+) = PARTNER.certification_level   '||
  ' AND  fndlv.lookup_type(+) = ''HZ_PARTY_CERT_LEVEL''   '||
  ' AND  fndlv.LANGUAGE(+) = USERENV(''LANG'')   '||
  ' AND  PvExternalSalesteamEO.PERSON_ID IS NULL   '||
  ' AND  PvExternalSalesteamEO.PARTNER_CONT_PARTY_ID IS NULL  '||
  ' AND  PvExternalSalesteamEO.LEAD_ID = :l_lead_id '||
  ' AND  PVPP.partner_level = T.ATTR_CODE_ID(+) '||   -- changed code
  ' AND  B.ATTR_CODE_ID(+) = T.ATTR_CODE_ID '||
  ' AND  T.LANGUAGE(+) = userenv(''LANG'') '||
  ' AND  B.attribute_id(+) = 19  '||
  ' AND  B.ENABLED_FLAG(+) = ''Y''  '||
  ' ORDER BY BIL_TX_MEASURE3 ' ;



	   x_custom_sql :=  l_custom_sql ;

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

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value :=l_lead_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
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

END PARTNER_TAB;


PROCEDURE CONTACTS_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                                 ,x_custom_sql         OUT  NOCOPY VARCHAR2
                                 ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(180);
    l_viewby                    VARCHAR2(180) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(500);
    l_view_param                VARCHAR2(500);
    l_page_period_type          VARCHAR2(100);
    l_lead_id                   VARCHAR2(100) ;
    l_customer_id               VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);


    BEGIN

    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_CONT_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_CONT_RPT_R';
       l_proc             := 'CONTACTS_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';


        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();


         -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_customer_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;

   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Party Id
	* BIL_TX_MEASURE2 = Name
  * BIL_TX_MEASURE3 = Job Title
	* BIL_TX_MEASURE4 = Phone
	* BIL_TX_MEASURE5 = Email
	* BIL_TX_MEASURE6 = Role (still to fix this)
	* BIL_TX_MEASURE7 = SUBJECT ID
	* BIL_TX_MEASURE8 = Object ID
	* BIL_TX_MEASURE9 = Party ID
	* BIL_TX_MEASURE10  = Relationship ID

	*******************************************************************************/


    l_custom_sql := ' SELECT hzpt.party_id BIL_TX_MEASURE1,  '||
      ' hzpt.party_name BIL_TX_MEASURE2,   '||
      ' hoc1.job_title BIL_TX_MEASURE3,   '||
      ' DECODE(hoc.phone_country_code,NULL,'''', hoc.phone_country_code || ''-'')   '||
      ' || DECODE(hoc.phone_area_code,NULL,'''',hoc.phone_area_code|| ''-'')   '||
      ' ||  DECODE(hoc.phone_number,NULL,'''',hoc.phone_number)   '||
      ' || DECODE(hoc.phone_extension,NULL,'''',''x'' ||hoc.phone_extension)  BIL_TX_MEASURE4,   '||
      ' hzpt.EMAIL_ADDRESS BIL_TX_MEASURE5,   '||
      ' fndl.meaning BIL_TX_MEASURE6,  '||
      ' hr.subject_id BIL_TX_MEASURE7,   '||
      ' hr.object_id  BIL_TX_MEASURE8,   '||
      ' hr.party_id BIL_TX_MEASURE9,   '||
      ' hr.relationship_id  BIL_TX_MEASURE10   '||
     ' FROM as_lead_contacts_all alca,   '||
     ' hz_contact_points hoc,   '||
     ' hz_relationships hr, '||
     ' hz_parties hzpt,  '||
     ' hz_org_contacts hoc1, '||
     ' fnd_lookups fndl '||
' WHERE alca.contact_party_id = hoc.owner_table_id(+)  '||
  ' AND hoc.owner_table_name(+) = ''HZ_PARTIES''  '||
  ' AND hoc.primary_flag(+) = ''Y''  '||
  ' AND hoc.contact_point_type(+) = ''PHONE''  '||
  ' AND alca.contact_party_id = hr.party_id  '||
  ' AND alca.customer_id = hr.object_id  '||
  ' AND hr.object_table_name = ''HZ_PARTIES''  '||
  ' AND hzpt.party_id = alca.contact_party_id  '||
  ' AND hr.relationship_id = hoc1.party_relationship_id (+)  '||
  ' AND alca.rank = fndl.lookup_code (+) '||
  ' AND fndl.lookup_type(+) = ''ASN_CONTACT_ROLE''  '||
  ' AND alca.lead_id =  :l_lead_id '||
  ' ORDER BY BIL_TX_MEASURE2  ';


	   x_custom_sql :=  l_custom_sql ;

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

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value :=l_lead_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_customer_id';
        l_custom_rec.attribute_value :=l_customer_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
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

END CONTACTS_TAB;


PROCEDURE PROPOSAL_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                                 ,x_custom_sql         OUT  NOCOPY VARCHAR2
                                 ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(180);
    l_viewby                    VARCHAR2(180) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(500);
    l_view_param                VARCHAR2(500);
    l_page_period_type          VARCHAR2(100);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);


    BEGIN

    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_PROP_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_PROP_RPT_R';
       l_proc             := 'PROPOSAL_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';



        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();


         -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;

   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Proposal Id
	* BIL_TX_MEASURE2 = Proposal Name
  * BIL_TX_MEASURE3 = Description
	* BIL_TX_MEASURE4 = Owner
	* BIL_TX_MEASURE5 = Due Date
	* BIL_TX_MEASURE6 = Status

	*******************************************************************************/



  l_custom_sql :=  ' SELECT  pp.proposal_id BIL_TX_MEASURE1, '||
                   '  pp.proposal_name BIL_TX_MEASURE2, '||
                   '  pp.proposal_desc BIL_TX_MEASURE3, '||
                   '  jrt.resource_name BIL_TX_MEASURE4, '||
                   '  pp.due_date BIL_TX_MEASURE5, '||
                   '  fl.meaning BIL_TX_MEASURE6 '||
                   ' FROM prp_proposals  pp, '||
                   '      prp_proposal_objects ppo, '||
                   '      fnd_lookups  fl, '||
                   '      jtf_rs_resource_extns jrb, '||
                   '      jtf_rs_resource_extns_tl jrt '||
                   ' WHERE  pp.proposal_status = fl.lookup_code '||
                   ' AND    fl.lookup_type = ''PRP_PROPOSAL_STATUS'' '||
                   ' AND    ppo.object_type = ''OPPORTUNITY'' '||
                   ' AND    ppo.proposal_id = pp.proposal_id '||
                   ' AND    pp.user_id = jrb.user_id(+) '||
                   ' AND    jrb.category = jrt.category(+) '||
                   ' AND    jrb.resource_id = jrt.resource_id (+) '||
                   ' AND    jrt.language(+) = USERENV(''LANG'') '||
                   ' AND    ppo.object_id = :l_lead_id  ' ||
                   ' ORDER BY BIL_TX_MEASURE2  ';


	   x_custom_sql :=  l_custom_sql ;

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

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value :=l_lead_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
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

END PROPOSAL_TAB;



PROCEDURE QUOTE_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql         OUT  NOCOPY VARCHAR2
                    ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(100);
    l_where_clause              VARCHAR2(1000);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);


    BEGIN



    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_QUOTE_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_QUOTE_RPT_R';
       l_proc             := 'QUOTE_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';


        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

        -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;



   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Quote name
	* BIL_TX_MEASURE2 = Quote header Id
  * BIL_TX_MEASURE3 = Quote Number
	* BIL_TX_MEASURE4 = Owner
	* BIL_TX_MEASURE5 = Quote status
	* BIL_TX_MEASURE6 = Creation Date
	* BIL_TX_MEASURE7 = Expiration
  * BIL_TX_MEASURE8 = Amount
	* BIL_TX_MEASURE9 = currency code
	* BIL_TX_MEASURE10 = currency name
	* BIL_TX_MEASURE11 = order number

	*******************************************************************************/



    -- query complete pass lead _id
    l_custom_sql := ' SELECT  aqha.quote_name BIL_TX_MEASURE1,  '||
       ' aqha.quote_header_id  BIL_TX_MEASURE2,  '||
       ' aqha.quote_number BIL_TX_MEASURE3,  '||
       ' jrst.resource_name  BIL_TX_MEASURE4, '||
       ' aqst.meaning BIL_TX_MEASURE5 ,  '||
       ' aqha.creation_date BIL_TX_MEASURE6,  '||
       ' aqha.quote_expiration_date BIL_TX_MEASURE7, '||
       ' aqha.total_quote_price BIL_TX_MEASURE8,  '||
       ' aqha.currency_code  BIL_TX_MEASURE9,  '||
       ' fct.name BIL_TX_MEASURE10,  '||
       ' aqha.order_id BIL_TX_MEASURE11  '||
       ' FROM   aso_quote_related_objects aqro, '||
       '  aso_quote_headers_all aqha, '||
       '  aso_quote_statuses_tl aqst, '||
       '  jtf_rs_resource_extns_tl  jrst, '||
       '  fnd_currencies_tl fct '||
       'WHERE   aqro.quote_object_type_code = ''HEADER''   '||
       ' AND    aqro.relationship_type_code = ''OPP_QUOTE''   '||
       ' AND    aqro.quote_object_id = aqha.quote_header_id '||
       ' AND    aqha.quote_status_id = aqst.quote_status_id '||
       ' AND    aqst.language = USERENV(''LANG'') '||
       ' AND    aqha.resource_id = jrst.resource_id  '||
       ' AND    jrst.language  = aqst.language '||
       ' AND    aqha.resource_id IS NOT NULL '||
       ' AND    NVL(aqha.quote_type, ''Q'') = ''Q'' '||
       ' AND    NVL(aqha.max_version_flag,''Y'') = ''Y'' '||
       ' AND    aqha.currency_code = fct.currency_code '||
       ' AND    fct.language = aqst.language '||
     --  ' AND    NVL(aqha.org_id, NVL(TO_NUMBER(DECODE(SUBSTRB '||
     --  ' (USERENV(''CLIENT_INFO''), 1 , 1), '''', NULL,  '||
     --  ' SUBSTRB(USERENV(''CLIENT_INFO''), 1, 10))), -99)) =  '||
     --  ' NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV(''CLIENT_INFO''), 1, 1), '''', NULL,  '||
    --   ' SUBSTRB(USERENV(''CLIENT_INFO''), 1, 10))), -99)  '||
       ' AND    aqro.object_id = :l_lead_id ' ||
       ' ORDER BY BIL_TX_MEASURE1  ';



	  x_custom_sql :=  l_custom_sql ;

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


        l_custom_rec.attribute_name :=':l_rpt_str';
        l_custom_rec.attribute_value :=l_rpt_str;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value :=l_lead_id;
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

END QUOTE_TAB;

-- Except for passing param it is complete.

PROCEDURE PROJECTS_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql         OUT  NOCOPY VARCHAR2
                    ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(100);
    l_where_clause              VARCHAR2(1000);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);


    BEGIN



    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_PROJ_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_PROJ_RPT_R';
       l_proc             := 'PROJECTS_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';


        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

        -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;



   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Segment Id
	* BIL_TX_MEASURE2 = Project name
  * BIL_TX_MEASURE3 = Project Number
	* BIL_TX_MEASURE4 = Organization Id
	* BIL_TX_MEASURE5 = Organization Name
	* BIL_TX_MEASURE6 = Manager ID
	* BIL_TX_MEASURE7 = Manager
	* BIL_TX_MEASURE8 = Start Date
	* BIL_TX_MEASURE9 = Completion Date
  * BIL_TX_MEASURE10 = Project Type
	* BIL_TX_MEASURE11 = status code
	* BIL_TX_MEASURE12 = Status Name


	*******************************************************************************/

   l_custom_sql := ' SELECT ppa.segment1 BIL_TX_MEASURE1, '||
       ' ppa.name BIL_TX_MEASURE2, '||
       ' ppa.project_id BIL_TX_MEASURE3,  '||
       ' ppa.carrying_out_organization_id BIL_TX_MEASURE4, '||
       ' hou.name BIL_TX_MEASURE5, '||
       ' ppp.person_id BIL_TX_MEASURE6, '||
       ' ppf.full_name BIL_TX_MEASURE7, '||
       ' ppa.start_date BIL_TX_MEASURE8, '||
       ' ppa.completion_date BIL_TX_MEASURE9, '||
       ' ppa.project_type BIL_TX_MEASURE10, '||
       ' ppa.project_status_code  BIL_TX_MEASURE11, '||
       ' pps.project_status_name BIL_TX_MEASURE12 '||
  ' FROM pa_projects_all   ppa ,  '||
      ' hr_all_organization_units_tl  hou  ,  '||
      ' pa_project_statuses    pps,  '||
      ' pa_project_players ppp ,  '||
      ' per_people_f ppf  '||
' WHERE ppa.carrying_out_organization_id    = hou.organization_id  '||
 ' AND  hou.language   = userenv(''lang'')  '||
 ' AND  ppa.project_status_code = pps.project_status_code  '||
 ' AND  ppa.project_id = ppp.project_id  '||
 ' AND  ppp.project_role_type  = ''PROJECT MANAGER''  '||
 ' AND  ppp.person_id  = ppf.person_id  '||
 ' AND  (trunc(sysdate) >= ppf.effective_start_date  '||
 ' AND  trunc(sysdate) <= ppf.effective_end_date)  '||
 ' AND  ppa.project_id in ( SELECT    object_id_to1  '||
      '  FROM ( SELECT  object_type_to,  '||
             '  object_id_to1  '||
       ' FROM  pa_object_relationships  '||
       ' WHERE relationship_type = ''A''  '||
       ' AND   relationship_subtype = ''PROJECT_REQUEST''  '||
       ' START WITH     (object_type_from = ''AS_LEADS''  '||
       '  AND  object_id_from1 = :l_lead_id)  '||
       '  CONNECT BY     (prior object_id_to1 = object_id_from1  '||
       '  AND prior object_type_to = object_type_from  '||
       '  AND prior object_id_from1 <> object_id_to1)) a  '||
   ' WHERE  a.object_type_to = ''PA_PROJECTS'') ' ||
   ' ORDER BY BIL_TX_MEASURE2  ';


	  x_custom_sql :=  l_custom_sql ;

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

         l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value := l_lead_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

END PROJECTS_TAB;

PROCEDURE TASKS_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql         OUT  NOCOPY VARCHAR2
                    ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(100);
    l_where_clause              VARCHAR2(1000);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);

    BEGIN



    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_TASK_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_TASK_RPT_R';
       l_proc             := 'TASKS_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';



        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

        -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;




   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Task ID --
	* BIL_TX_MEASURE2 = Source Object ID --
  * BIL_TX_MEASURE3 = Subject  -- Task Name
	* BIL_TX_MEASURE4 = Due Date
	* BIL_TX_MEASURE5 = Type
	* BIL_TX_MEASURE6 = Status
	* BIL_TX_MEASURE7 = Created By
	* BIL_TX_MEASURE8 = Owner
	* BIL_TX_MEASURE9 = Description --
  * BIL_TX_MEASURE10 = Assignee

	*******************************************************************************/
   -- work on query


     l_custom_sql := ' SELECT TaskEO.TASK_ID  BIL_TX_MEASURE1, '||
                     ' TaskEO.SOURCE_OBJECT_ID  BIL_TX_MEASURE2, '||
                     ' jtl.TASK_NAME BIL_TX_MEASURE3, '||
                     ' TaskEO.PLANNED_END_DATE BIL_TX_MEASURE4, '||
                     ' tt.NAME   BIL_TX_MEASURE5, '||
                     ' ts.NAME  BIL_TX_MEASURE6, '||
                     ' Rscreator.SOURCE_NAME BIL_TX_MEASURE7, '||
                     ' JTF_TASK_UTL.get_owner(TaskEO.OWNER_TYPE_CODE, TaskEO.OWNER_ID) BIL_TX_MEASURE8, '||
                     ' jtl.DESCRIPTION BIL_TX_MEASURE9, '||
                     ' JTF_TASK_UTL.get_owner(Assign.RESOURCE_TYPE_CODE, Assign.RESOURCE_ID) BIL_TX_MEASURE10 '||
                ' FROM jtf_tasks_b TaskEO,  '||
                   ' jtf_task_statuses_tl ts,  '||
                   ' jtf_task_types_tl tt,   '||
                   ' jtf_tasks_tl jtl,   '||
                   ' JTF_RS_RESOURCE_EXTNS Rscreator,   '||
                   ' JTF_TASK_ALL_ASSIGNMENTS Assign   '||
                ' WHERE Assign.task_id (+) = TaskEO.task_id  '||
                ' AND TaskEO.created_by = Rscreator.user_id(+)  '||
                ' AND TaskEO.entity = ''TASK''  '||
                ' AND TaskEO.source_object_type_code in (select object_code from jtf_objects_b where enter_from_task = ''Y'')  '||
                ' AND NVL(TaskEO.deleted_flag,''N'') = ''N''  '||
                ' AND TaskEO.task_id = jtl.task_id  '||
                ' AND jtl.language = USERENV(''LANG'')  '||
                ' AND TaskEO.task_status_id = ts.task_status_id  '||
                ' AND ts.language = userenv(''LANG'')  '||
                ' AND TaskEO.task_type_id = tt.task_type_id  '||
                ' AND tt.language = userenv(''LANG'')  '||
                ' AND TaskEO.SOURCE_OBJECT_ID = :l_lead_id ' ||
                ' ORDER BY BIL_TX_MEASURE3 ';






	  x_custom_sql :=  l_custom_sql ;

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


        l_custom_rec.attribute_name :=':l_rpt_str';
        l_custom_rec.attribute_value :=l_rpt_str;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value := l_lead_id;
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

END TASKS_TAB;

PROCEDURE ATTACHMENTS_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql         OUT  NOCOPY VARCHAR2
                    ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(100);
    l_where_clause              VARCHAR2(1000);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_to_currency               VARCHAR2(100);
    l_period_type               VARCHAR2(100);
    l_period_name               VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);
    l_sg_id                     VARCHAR2(200);


    BEGIN



    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_ATCH_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_ATCH_RPT_R';
       l_proc             := 'ATTACHMENTS_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';


        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

        -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;



   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Attached Document ID
	* BIL_TX_MEASURE2 = Document Id
  * BIL_TX_MEASURE3 = Name
	* BIL_TX_MEASURE4 = Description
	* BIL_TX_MEASURE5 = Attachment Type
	* BIL_TX_MEASURE6 = Category
	* BIL_TX_MEASURE7 = Updated By
	* BIL_TX_MEASURE8 = Updated Date
  * BIL_TX_MEASURE9 = Usage

	*******************************************************************************/


 l_custom_sql := ' SELECT  ad.ATTACHED_DOCUMENT_ID BIL_TX_MEASURE1,  '||
                 ' ad.DOCUMENT_ID BIL_TX_MEASURE2,  '||
                 ' decode(d.FILE_NAME, null, (select message_text from fnd_new_messages  '||
                 ' where message_name = ''FND_UNDEFINED''  '||
                 ' and application_id = 0 and language_code = userenv(''LANG'')), D.FILE_NAME) BIL_TX_MEASURE3,  '||
                 ' dL.DESCRIPTION BIL_TX_MEASURE4,  '||
                 ' DD.USER_NAME BIL_TX_MEASURE5,  '||
                 ' cl.user_name BIL_TX_MEASURE6,  '||
                 '  u.USER_NAME BIL_TX_MEASURE7,  '||
                 ' ad.LAST_UPDATE_DATE BIL_TX_MEASURE8 ,  '||
                 ' L.MEANING  BIL_TX_MEASURE9  '||
                 ' FROM FND_DOCUMENTS D ,  '||
                 '  FND_DOCUMENTS_TL DL,  '||
                 '  FND_DOCUMENT_DATATYPES DD, '||
                 '  FND_LOOKUP_VALUES L,  '||
                 '  FND_ATTACHED_DOCUMENTS ad,  '||
                 '  FND_USER u,  '||
                 '  FND_DOCUMENT_CATEGORIES_TL cl  '||
                 ' WHERE ad.DOCUMENT_ID = d.DOCUMENT_ID   '||
                 '   and ad.LAST_UPDATED_BY = u.USER_ID(+)   '||
                 '   and cl.language = userenv(''LANG'')  '||
                 '   and cl.category_id = decode(ad.category_id, null, d.category_id, ad.category_id)  '||
                 '   and ad.ENTITY_NAME = ''AS_OPPORTUNITY_ATTCH''  '||
                 '   and D.DOCUMENT_ID = DL.DOCUMENT_ID  '||
                 '   AND DL.LANGUAGE= USERENV(''LANG'')  '||
                 '   AND D.DATATYPE_ID = DD.DATATYPE_ID  '||
                 '   AND DD.LANGUAGE = USERENV(''LANG'')  '||
                 '   AND D.USAGE_TYPE = L.LOOKUP_CODE '||
                 '   AND L.LANGUAGE = USERENV(''LANG'')   '||
                 '   AND L.LOOKUP_TYPE = ''ATCHMT_DOCUMENT_TYPE''  '||
                 '   and ad.PK1_VALUE = :l_lead_id  '||
                 '  ORDER BY BIL_TX_MEASURE3 ';




	  x_custom_sql :=  l_custom_sql ;

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

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value := l_lead_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

END ATTACHMENTS_TAB;

PROCEDURE NOTES_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql         OUT  NOCOPY VARCHAR2
                    ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS



    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_proc                      VARCHAR2(100);
    l_custom_sql                VARCHAR2(32000);
    l_outer_select              VARCHAR2(4000);
    g_pkg                       VARCHAR2(100);
    l_where_clause              VARCHAR2(1000);
    l_source_object_code        VARCHAR2(100);
    l_lead_id                   VARCHAR2(100) ;
    l_cust_id                   VARCHAR2(100);
    l_to_currency               VARCHAR2(100);
    l_period_type               VARCHAR2(100);
    l_period_name               VARCHAR2(100);
    l_credit_type_id            VARCHAR2(100);
    l_sg_id                     VARCHAR2(200);

    BEGIN



    -- Initializing variables as per new standard

       l_region_id        := 'BIL_TX_OPTY_DETL_NOTES_RPT';
       l_parameter_valid  :=  FALSE;
       l_rpt_str          := 'BIL_TX_OPTY_DETL_NOTES_RPT_R';
       l_proc             := 'NOTES_TAB.';
       g_pkg              := 'asn.patch.115.sql.BIL_TX_OPTY_DETL_RPT_PKG.';



        -- FND logging standard
       IF  BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN

	         BIL_TX_UTIL_RPT_PKG.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
				                                p_module 	  => g_pkg || l_proc || 'begin',
				                                p_msg 	  => 'Start of Procedure '|| l_proc );
	     END IF;

       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
       x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

        -- code for a procedure to get parameter values.
        BIL_TX_UTIL_RPT_PKG.GET_DETAIL_PAGE_PARAMS
               (p_page_parameter_tbl  =>   p_page_parameter_tbl,
                p_region_id           =>   l_region_id,
                x_parameter_valid    =>    l_parameter_valid,
                x_viewby              =>   l_viewby,
                x_lead_id            =>    l_lead_id,
                x_cust_id            =>    l_cust_id,
                x_credit_type_id =>  l_credit_type_id
                ) ;



   /*** Query column mapping ******************************************************

	* BIL_TX_MEASURE1 = Entered Date
	* BIL_TX_MEASURE2 = Created By
  * BIL_TX_MEASURE3 = Type
	* BIL_TX_MEASURE4 = Status
	* BIL_TX_MEASURE5 = Notes


	*******************************************************************************/


    l_custom_sql :=   ' SELECT JNB.ENTERED_DATE  BIL_TX_MEASURE1,   '||
                      ' JTF_COMMON_PVT.GetUserInfo(JNB.ENTERED_BY) BIL_TX_MEASURE2,  '||
                      ' FLS.MEANING BIL_TX_MEASURE3,    '||
                      ' FLP.MEANING BIL_TX_MEASURE4,   '||
                      ' JNT.NOTES  BIL_TX_MEASURE5      '||
                      ' FROM JTF_NOTES_B JNB ,   '||
                      '      JTF_NOTES_TL JNT ,   '||
                      '      FND_LOOKUPS FLS ,   '||
                      '      FND_LOOKUPS FLP     '||
                      ' WHERE JNB.JTF_NOTE_ID = JNT.JTF_NOTE_ID   '||
                      ' AND JNT.LANGUAGE = USERENV(''LANG'')   '||
                      ' AND  FLS.LOOKUP_TYPE(+) = ''JTF_NOTE_TYPE''   '||
                      ' AND  FLS.LOOKUP_CODE(+) = JNB.NOTE_TYPE    '||
                      ' AND  FLP.lookup_type = ''JTF_NOTE_STATUS''  '||
                      ' AND  FLP.lookup_code = JNB.note_status  '||
                      ' AND  JNB.SOURCE_OBJECT_CODE = ''OPPORTUNITY''  '||
                      ' AND  JNB.SOURCE_OBJECT_ID  = :l_lead_id  '||
                      ' ORDER BY  BIL_TX_MEASURE1    ';



	  x_custom_sql :=  l_custom_sql ;

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


        l_custom_rec.attribute_name :=':l_rpt_str';
        l_custom_rec.attribute_value :=l_rpt_str;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_lead_id';
        l_custom_rec.attribute_value := l_lead_id;
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

END NOTES_TAB;

END BIL_TX_OPTY_DETL_RPT_PKG;


/
