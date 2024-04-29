--------------------------------------------------------
--  DDL for Package Body IBE_BI_SM_KPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_BI_SM_KPI_PVT" AS
/* $Header: IBEVBISMKPIB.pls 120.8 2006/06/26 08:57:11 gjothiku ship $ */

PROCEDURE GET_NEW_CUST_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS
  l_custom_sql       VARCHAR2(15000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type  VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;-- :=
                    -- BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  dbg_msg           VARCHAR2(3200);
  l_g_p    VARCHAR2(30);
  l_g_s    VARCHAR2(30);

  l_c_filter  VARCHAR2(1000);
  l_outer_where_clause    VARCHAR2(3200) ;

BEGIN

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_sm_kpi_pvt.get_new_cust_kpi_sql.begin','BEGIN');
  END IF;

 -- initilization of variables

l_custom_rec  := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
l_g_p         := '''FII_GLOBAL1''';
l_g_s         := '''FII_GLOBAL2''';

  FOR i IN p_pmv_parameters.FIRST..p_pmv_parameters.LAST
  LOOP
    l_parameter_name := p_pmv_parameters(i).parameter_name ;

    IF( l_parameter_name = 'AS_OF_DATE')
    THEN
      l_asof_date :=
        TO_DATE(p_pmv_parameters(i).parameter_value,'DD/MM/YYYY');
    ELSIF( l_parameter_name = 'IBW_WEB_ANALYTICS_GROUP1+FII_CURRENCIES')
    THEN
      l_currency_code :=  p_pmv_parameters(i).parameter_id;
    ELSIF( l_parameter_name = 'PERIOD_TYPE')
    THEN
      l_period_type := p_pmv_parameters(i).parameter_value;
    ELSIF( l_parameter_name = 'TIME_COMPARISON_TYPE')
    THEN
      l_comparison_type := p_pmv_parameters(i).parameter_value;
    ELSIF( l_parameter_name = 'SITE+SITE')
    THEN
      l_minisite := p_pmv_parameters(i).parameter_value;
      l_minisite_id := p_pmv_parameters(i).parameter_id;
    END IF;
   END LOOP;

  l_record_type_id := IBE_BI_PMV_UTIL_PVT.GET_RECORD_TYPE_ID(l_period_type);


  l_prev_date :=  IBE_BI_PMV_UTIL_PVT.GET_PREV_DATE(
                   p_asof_date        => l_asof_date,
                   p_period_type      => l_period_type,
                   p_comparison_type => l_comparison_type );

 dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_currency_code||','
 ||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||l_comparison_type||
 ','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||l_minisite_id||','||
 'RECORD_TYPE_ID:'||l_record_type_id||','||'PREV_DATE:'||l_prev_date;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_sm_kpi_pvt.get_new_cust_kpi_sql.parameters',dbg_msg);
 END IF;

/**********************************************************************************/
/* VIEWBYID                         : Minisite ID                                 */
/* VIEWBY                           : Minisite Name                               */
/* IBE_VAL1                         : Minisite ID                                 */
/* IBE_VAL2                         : Number of New Customers for Current Period  */
/* IBE_VAL3                         : Number of New Customers for Previous Period */
/**********************************************************************************/
  l_c_filter := '';
  l_outer_where_clause := '';


  /*IF ((l_currency_code = l_g_p) OR (l_currency_code = l_g_s)) THEN
     l_c_filter := '';
  ELSIF (l_minisite_id <> 'All') THEN
     l_c_filter := ' AND FACT.MINISITE_ID in (&SITE+SITE) ';
  END IF;

    Above code is prior to R12
     Based on Bug # 4660266    ,we need to put 'AND FACT.MINISITE_ID in (&SITE+SITE)"

  */

  -- Initialising where clause based on the site parameter selection
  -- Based on Bug # 4660266

  IF upper(l_minisite_id) <> 'ALL' THEN
    l_outer_where_clause   := l_outer_where_clause ||
				                      ' AND FACT.MINISITE_ID in (&SITE+SITE) ' ;
  END IF;



  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITE_DIMN_V to IBW_BI_MSITE_DIMN_V.

  l_custom_sql := 'SELECT MSITES.ID VIEWBYID, MSITES.VALUE VIEWBY,'||
                  ' MSITES.ID IBE_VAL1, '||
                  ' SUM (CASE WHEN CAL.report_date =  :l_asof_date '||
                  ' THEN nvl(Total,0) ELSE 0 end) IBE_VAL2, '||
                  ' SUM(CASE WHEN CAL.report_date =  :l_prev_date '||
                  ' THEN nvl(Total,0) ELSE 0 end) IBE_VAL3, '||
                  ' SUM(SUM (CASE WHEN CAL.report_date =  :l_asof_date '||
                  ' THEN nvl(Total,0) ELSE 0 end)) over() IBE_VAL5, '||
                  ' sum(SUM(CASE WHEN CAL.report_date =  :l_prev_date '||
                  ' THEN nvl(Total,0) ELSE 0 end)) over() IBE_VAL6 '||
                  ' FROM '||
                  ' IBE_BI_CUSTTIME_MV FACT, '||
                  ' IBW_BI_MSITE_DIMN_V  MSITES, '||
                  ' FII_TIME_RPT_STRUCT_V CAL '||
                  ' WHERE CAL.calendar_id = -1 '||
                  ' AND FACT.Time_Id = CAL.Time_Id '||
                  ' AND FACT.Period_Type_id = CAL.Period_Type_Id '||
                  ' AND BITAND(CAL.Record_Type_Id, :l_record_type_id) = CAL.Record_Type_Id '||
                  ' AND CAL.Report_Date in (:l_asof_date,:l_prev_date) '|| l_c_filter ||
                  ' AND MSITES.ID = FACT.MINISITE_ID '|| l_outer_where_clause || --4660266
                  ' GROUP BY MSITES.ID,MSITES.VALUE';

  x_custom_sql  := l_custom_sql;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_sm_kpi_pvt.get_new_cust_kpi_sql.query',l_custom_sql);
END IF;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  x_custom_output.Extend(4);

  l_custom_rec.attribute_name := ':l_asof_date' ;
  l_custom_rec.attribute_value:= to_char(l_asof_date,'dd/mm/yyyy');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_prev_date' ;
  l_custom_rec.attribute_value:= to_char(l_prev_date,'dd/mm/yyyy');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_record_type_id' ;
  l_custom_rec.attribute_value:= l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

  x_custom_output(3) := l_custom_rec;

 /*
  l_custom_rec.attribute_name := ':l_minisite_id' ;
  l_custom_rec.attribute_value:= l_minisite_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(4) := l_custom_rec;
*/

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_sm_kpi_pvt.get_new_cust_kpi_sql.end','END');
END IF;

END GET_NEW_CUST_KPI_SQL;


PROCEDURE GET_CART_ORD_KPIS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS
  l_custom_sql       VARCHAR2(15000); --4660266
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type  VARCHAR2(3200);
  l_c_d              VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_assist_type      VARCHAR2(3200) ;
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
  dbg_msg           VARCHAR2(3200);
  l_g_p    VARCHAR2(30);
  l_g_s    VARCHAR2(30);
  l_c_filter  VARCHAR2(1000);
  l_outer_where_clause    VARCHAR2(3200) ;


BEGIN
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_sm_kpi_pvt.get_cart_ord_kpi_sql.begin','BEGIN');
  END IF;

   -- initilization of variables

l_custom_rec  := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
l_assist_type := 'IBE_ORD_TOTAL';
l_g_p         := '''FII_GLOBAL1''';
l_g_s         := '''FII_GLOBAL2''';

  FOR i IN p_pmv_parameters.FIRST..p_pmv_parameters.LAST
  LOOP
    l_parameter_name := p_pmv_parameters(i).parameter_name ;

    IF( l_parameter_name = 'AS_OF_DATE')
    THEN
      l_asof_date :=
        TO_DATE(p_pmv_parameters(i).parameter_value,'DD/MM/YYYY');
    ELSIF( l_parameter_name = 'IBW_WEB_ANALYTICS_GROUP1+FII_CURRENCIES')
    THEN
      l_c_d :=  p_pmv_parameters(i).parameter_id;

    ELSIF( l_parameter_name = 'PERIOD_TYPE')
    THEN
      l_period_type := p_pmv_parameters(i).parameter_value;
    ELSIF( l_parameter_name = 'TIME_COMPARISON_TYPE')
    THEN
      l_comparison_type := p_pmv_parameters(i).parameter_value;
    ELSIF( l_parameter_name = 'SITE+SITE')
    THEN
      l_minisite := p_pmv_parameters(i).parameter_value;
      l_minisite_id := p_pmv_parameters(i).parameter_id;
    END IF;
   END LOOP;

  l_record_type_id := IBE_BI_PMV_UTIL_PVT.GET_RECORD_TYPE_ID(l_period_type);

  l_c_filter := '';

  /*
  IF ((l_c_d = l_g_p) OR (l_c_d = l_g_s)) THEN
     l_c_filter := '';
  ELSIF (l_minisite_id <> 'All') THEN
     l_c_filter := ' AND FACT.MINISITE_ID in (&SITE+SITE)';
  END IF;

   Above code is prior to R12
   Based on Bug # 4660266    ,we need to put 'AND FACT.MINISITE_ID in (&SITE+SITE)"

  */

  -- Initialising where clause based on the site parameter selection
  -- Based on Bug # 4660266

  IF upper(l_minisite_id) <> 'ALL' THEN
    l_outer_where_clause   := l_outer_where_clause ||
				' AND FACT.MINISITE_ID in (&SITE+SITE)' ;
  END IF;


  l_prev_date :=  IBE_BI_PMV_UTIL_PVT.GET_PREV_DATE(
                   p_asof_date        => l_asof_date,
                   p_period_type      => l_period_type,
                   p_comparison_type => l_comparison_type );

 dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_c_d||','
 ||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||l_comparison_type||
 ','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||l_minisite_id||','||
 'RECORD_TYPE_ID:'||l_record_type_id||','||'PREV_DATE:'||l_prev_date;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_sm_kpi_pvt.get_cart_ord_kpi_sql.parameters',dbg_msg);
END IF;

/*********************************************************************************/
/* VIEWBYID                         : Minisite ID                                */
/* VIEWBY                           : Minisite Name                              */
/* IBE_VAL1                         : Minisite ID                                */
/* IBE_VAL2                         : Avg Order Value for Current Period         */
/* IBE_VAL3                         : Avg Order Value for Previous Period        */
/*********************************************************************************/

  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITE_DIMN_V to IBW_BI_MSITE_DIMN_V.

-- Added nvl to the outer most select clause a part of bug 5253591

 l_custom_sql := 'SELECT ID VIEWBYID, VALUE VIEWBY, '||
                 'id IBE_VAL1,  '||
	         'nvl(c_total,0) IBE_VAL2,'||
	         'nvl(p_total,0) IBE_VAL3,'||
	         'sum(nvl(c_total,0)) over()  IBE_VAL21,'||
	         'sum(nvl(p_total,0)) over() IBE_VAL22,'||
                 'decode(nvl(c_total,0),0,null,c_ord/c_total)*100 IBE_VAL4,'||
	         'decode(nvl(p_total,0),0,null,p_ord/p_total)*100 IBE_VAL5,'||
                 'decode(sum(nvl(c_total,0)) over(),0,null,(sum(c_ord) over()/sum(c_total)over()))*100 IBE_VAL6,'||
	         'decode(sum(nvl(p_total,0)) over(),0,null,(sum(p_ord) over()/sum(p_total)over()))*100 IBE_VAL7,'||
                 'decode(nvl(Count_Curr,0),0,NULL,Amount_Curr/Count_Curr) IBE_VAL8, '||
                 'decode(nvl(Count_Prev,0),0,NULL,Amount_Prev/Count_Prev) IBE_VAL9,'||
                 'decode(sum(nvl(Count_Curr,0)) over(), 0, NULL, sum(Amount_Curr) over()/sum(Count_Curr) over()) IBE_VAL10,'||
	         'decode(sum(nvl(Count_Prev,0)) over(), 0, NULL, sum(Amount_Prev) over()/sum(Count_Prev) over()) IBE_VAL11,'||
                 'decode(nvl(c_list_amt,0),0,null,c_disc_amt/c_list_amt)*100 IBE_VAL12, '||
	         'decode(nvl(p_list_amt,0),0,null,p_disc_amt/p_list_amt)*100 IBE_VAL13,'||
                 'decode(sum(nvl(c_list_amt,0)) over(),0,null,(sum(c_disc_amt) over ()/sum(c_list_amt) over()))*100 IBE_VAL14, '||
	         'decode(sum(nvl(p_list_amt,0)) over(),0,null,(sum(p_disc_amt) over ()/sum(p_list_amt) over()))*100 IBE_VAL15,'||
	         'nvl(Amount_Curr,0) IBE_VAL16,'||
	         'nvl(Amount_Prev,0) IBE_VAL17, '||
	         'sum(nvl(Amount_Curr,0)) over() IBE_VAL27,'||
	         'sum(nvl(Amount_Prev,0)) over() IBE_VAL28, '||
	         'nvl(c_camp_amt,0) IBE_VAL18,'||
              'nvl(p_camp_amt,0) IBE_VAL19,'||
	         'sum(nvl(c_camp_amt,0)) over() IBE_VAL30,'||
              'sum(nvl(p_camp_amt,0)) over() IBE_VAL31'||

        ' FROM ( '||
               'SELECT MSITES.ID id, MSITES.VALUE VALUE,'||
               'SUM((CASE WHEN (report_date =  :l_asof_date and MEASURE_TYPE = ''IBE_ORD_TOTAL'') '||
               'THEN decode(:l_c_d,:l_g_p,Amount_g,:l_g_s,Amount_g1,currency_cd_f,amount_f) ELSE 0 end)) Amount_Curr, '||
               'SUM((CASE WHEN (report_date =  :l_asof_date and MEASURE_TYPE = ''IBE_ORD_TOTAL'')'||
               'THEN Tot_Count ELSE 0 end)) Count_Curr, '||
               'SUM((CASE WHEN (report_date =  :l_prev_date and MEASURE_TYPE = ''IBE_ORD_TOTAL'')'||
               'THEN decode(:l_c_d,:l_g_p,Amount_g,:l_g_s,Amount_g1,currency_cd_f,amount_f) ELSE 0 end)) Amount_Prev, '||
               'SUM((CASE WHEN (report_date =  :l_prev_date and MEASURE_TYPE = ''IBE_ORD_TOTAL'')'||
               'THEN Tot_Count ELSE 0 end))Count_Prev,'||
	       'SUM((CASE WHEN (report_date =  :l_asof_date and MEASURE_TYPE = ''IBE_ORD_TOTAL'')'||
  'THEN decode(:l_c_d,:l_g_p,List_Amount_g,:l_g_s,list_amount_g1,currency_cd_f,List_Amount_f) ELSE 0 end)) c_list_amt, '||
	       'SUM((CASE WHEN (report_date =  :l_asof_date and MEASURE_TYPE = ''IBE_ORD_TOTAL'')'||
  'THEN decode(:l_c_d,:l_g_p,Disc_Amount_g,:l_g_s,Disc_Amount_g1,currency_cd_f,Disc_amount_f) ELSE 0 end)) c_disc_amt, '||
	       'SUM((CASE WHEN (report_date =  :l_prev_date and MEASURE_TYPE = ''IBE_ORD_TOTAL'')'||
 'THEN decode(:l_c_d,:l_g_p,List_Amount_g,:l_g_s,List_Amount_g1,currency_cd_f,List_Amount_f) ELSE 0 end)) p_list_amt, '||
               'SUM((CASE WHEN (report_date =  :l_prev_date and MEASURE_TYPE = ''IBE_ORD_TOTAL'')'||
   'THEN decode(:l_c_d,:l_g_p,Disc_amount_g,:l_g_s,Disc_Amount_g1,currency_cd_f,Disc_Amount_f) ELSE 0 end)) p_disc_amt,'||
	       'SUM((CASE WHEN (report_date =  :l_asof_date and MEASURE_TYPE = ''IBE_ORD_CAMPAIGN'')'||
	       'THEN decode(:l_c_d,:l_g_p,Amount_g,:l_g_s,Amount_g1,currency_cd_f,amount_f) ELSE 0 end)) c_camp_amt,'||
	       'SUM((CASE WHEN (report_date =  :l_prev_date  and MEASURE_TYPE = ''IBE_ORD_CAMPAIGN'')'||
               'THEN decode(:l_c_d,:l_g_p,Amount_g,:l_g_s,Amount_g1,currency_cd_f,Amount_f) ELSE 0 end)) p_camp_amt,'||
	       'SUM((CASE WHEN (report_date =  :l_asof_date and MEASURE_TYPE = ''IBE_QOT_TOTAL'')'||
  	       'THEN con_ord ELSE 0 end)) c_ord, '||
 	       'SUM((CASE WHEN (report_date =  :l_asof_date and MEASURE_TYPE = ''IBE_QOT_TOTAL'')'||
	       'THEN tot_count ELSE 0 end)) c_total, '||
               'SUM((CASE WHEN (report_date =  :l_prev_date and MEASURE_TYPE = ''IBE_QOT_TOTAL'')'||
	       'THEN con_ord ELSE 0 end)) p_ord, '||
	       'SUM((CASE WHEN (report_date =  :l_prev_date and MEASURE_TYPE = ''IBE_QOT_TOTAL'')'||
	       'THEN tot_count ELSE 0 end)) p_total    '||
               'FROM IBE_BI_CART_ORD_MV FACT, IBW_BI_MSITE_DIMN_V  MSITES,'||
               'FII_TIME_RPT_STRUCT_V CAL '||
               'WHERE  FACT.MINISITE_ID = MSITES.ID '||
               'AND CAL.calendar_id = -1 '||
               'AND FACT.Time_Id = CAL.Time_Id '||
               'AND FACT.Period_Type_id = CAL.Period_Type_Id '||
               'AND MEASURE_TYPE in (''IBE_ORD_TOTAL'',''IBE_ORD_CAMPAIGN'',''IBE_QOT_TOTAL'')'||
               'AND REPORT_DATE IN (:l_asof_date,:l_prev_date) '|| l_outer_where_clause || --4660266
               'AND BITAND(CAL.Record_Type_Id, :l_record_type_id) = CAL.Record_Type_Id '|| l_c_filter ||
               'GROUP BY MSITES.ID, MSITES.value)';


  x_custom_sql  := l_custom_sql;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_sm_kpi_pvt.get_cart_ord_kpi_sql.query',l_custom_sql);
  END IF;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  x_custom_output.Extend(8);

  l_custom_rec.attribute_name := ':l_asof_date' ;
  l_custom_rec.attribute_value:= to_char(l_asof_date,'dd/mm/yyyy');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_prev_date' ;
  l_custom_rec.attribute_value:= to_char(l_prev_date,'dd/mm/yyyy');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_c_d' ;
  l_custom_rec.attribute_value:= l_c_d;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_assist_type' ;
  l_custom_rec.attribute_value:= l_assist_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_record_type_id' ;
  l_custom_rec.attribute_value:= l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_g_p' ;
  l_custom_rec.attribute_value:= l_g_p;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_g_s' ;
  l_custom_rec.attribute_value:= l_g_s;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(7) := l_custom_rec;
/*
  l_custom_rec.attribute_name := ':l_minisite_id' ;
  l_custom_rec.attribute_value:= l_minisite_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(8) := l_custom_rec;
*/





  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_sm_kpi_pvt.get_cart_ord_kpi_sql.end','END');
    END IF;

END GET_CART_ORD_KPIS_SQL;


PROCEDURE GET_AVG_ORD_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type  VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_assist_type      VARCHAR2(3200) ;
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
   dbg_msg           VARCHAR2(3200);
BEGIN
NULL;
END GET_AVG_ORD_KPI_SQL;


PROCEDURE GET_BOOK_ORD_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_assist_type      VARCHAR2(3200) ;
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
 dbg_msg           VARCHAR2(3200);
BEGIN

  NULL;
END GET_BOOK_ORD_KPI_SQL;



PROCEDURE GET_CARTS_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_assist_type      VARCHAR2(3200);
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
 dbg_msg           VARCHAR2(3200);

BEGIN
 NULL;
END GET_CARTS_KPI_SQL;


PROCEDURE GET_CARTS_CONV_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_assist_type      VARCHAR2(3200) ;
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
  dbg_msg           VARCHAR2(3200);

BEGIN

   NULL;
END GET_CARTS_CONV_KPI_SQL;



PROCEDURE GET_AVG_DISC_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_assist_type      VARCHAR2(3200);
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
  dbg_msg           VARCHAR2(3200);
BEGIN

NULL;
END GET_AVG_DISC_KPI_SQL;


PROCEDURE GET_CAMP_ORD_KPI_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_assist_type      VARCHAR2(3200) ;
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
   dbg_msg           VARCHAR2(3200);

BEGIN

NULL;
END GET_CAMP_ORD_KPI_SQL;


END IBE_BI_SM_KPI_PVT;

/
