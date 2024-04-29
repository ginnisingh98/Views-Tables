--------------------------------------------------------
--  DDL for Package Body IBE_BI_CART_ORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_BI_CART_ORD_PVT" AS
/* $Header: IBEVBICARTORDB.pls 120.6 2006/06/26 08:57:42 gjothiku ship $ */
PROCEDURE GET_CART_ORD_PORT_SQL(
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
  l_msiteFilter      VARCHAR2(1000);
  l_tableList        VARCHAR2(1000);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;
  dbg_msg			VARCHAR2(3200);
  l_global_primary   VARCHAR2(15);
  l_global_secondary VARCHAR2(15);
BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_cart_ord_pvt.get_cart_ord_port_sql.begin','BEGIN');
    END IF;

    --initializing the variables

    l_custom_rec  := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
    l_global_primary         := '''FII_GLOBAL1''';
    l_global_secondary         := '''FII_GLOBAL2''';

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

  dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_currency_code||
  ','||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||
  l_comparison_type||','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||
  l_minisite_id||','||'RECORD_TYPE_ID:'||l_record_type_id||','||'PREV_DATE:'||
  l_prev_date;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_cart_ord_pvt.get_cart_ord_port_sql.parameters',dbg_msg);
  END IF;
  if (trim(l_minisite_id) is null) then
  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITES_V to IBW_BI_MSITE_DIMN_V.
    l_tableList := ' IBE_BI_CART_ORD_MV FACT,'||
                -- ' IBE_BI_MSITES_V  MSITES,'||
                   ' IBW_BI_MSITE_DIMN_V  MSITES,'||
                   ' FII_TIME_RPT_STRUCT_V CAL';

    l_msiteFilter :=' AND MSITES.ID = FACT.MINISITE_ID';

  else
    l_tableList := ' IBE_BI_CART_ORD_MV FACT,'||
                   ' FII_TIME_RPT_STRUCT_V CAL';

    l_msiteFilter := ' AND FACT.MINISITE_ID in (&SITE+SITE)';

  end if;

  /**************************************************************************/
  /* IBE_ATTR1              : Category                                      */
  /* IBE_VAL1               : Count                                         */
  /* IBE_VAL2               : Amount                                        */
  /* IBE_VAL3               : Change(Calculated in the AK region)           */
  /* IBE_VAL6               : Prior Order Amount                                  */
  /* IBE_VAL4               : Lines                                         */
  /* IBE_VAL5               : Conversion Ratio                              */
  /**************************************************************************/

   /*
   Changes done for Bug:4772549
    DECODE(OLD_AMT,0,NULL,((CUR_AMT - OLD_AMT)/OLD_AMT)*100) IBE_VAL3
    is changed to

    OLD_AMT IBE_VAL6
   */

-- Added nvl to the outer most select clause as part of bug 5253591

  l_custom_sql :='SELECT MEANING IBE_ATTR1,nvl(TOT_COUNT,0) IBE_VAL1,nvl(CUR_AMT,0) IBE_VAL2,'||
                 ' nvl(OLD_AMT,0) IBE_VAL6,nvl(NO_LINES,0) IBE_VAL4,'||
                 ' DECODE(nvl(TOT_COUNT,0),0,NULL,(CON_ORD/TOT_COUNT)*100) IBE_VAL5 from('||
                 ' SELECT decode(flkup.lookup_code,''IBE_ORD_ASSISTED'', 3,'||
                 ' ''IBE_ORD_UNASSISTED'',4,'||
                 ' ''IBE_ORD_TOTAL'',5,'||
                 ' ''IBE_ORD_CAMPAIGN'',7,'||
                 ' ''IBE_ORD_QUOTING'',9,'||
                 ' ''IBE_QOT_ASSISTED'', 0,'||
                 ' ''IBE_QOT_UNASSISTED'',1,'||
                 ' ''IBE_QOT_TOTAL'',2,'||
                 ' ''IBE_QOT_CAMPAIGN'',6,'||
                 ' ''IBE_QOT_QUOTING'',8 ) OB,'||
                 ' flkup.MEANING, SUM(TOT_COUNT) TOT_COUNT, SUM(NEW_VALUE) CUR_AMT,'||
                 ' SUM(OLD_VALUE) OLD_AMT,SUM(NO_LINES) NO_LINES,'||
                 ' SUM(con_ord) CON_ORD'||
                 ' FROM ('||
                       ' SELECT MEASURE_TYPE ,'||
                       ' SUM(CASE WHEN CAL.report_date =  :l_asof_date'||
                       ' THEN Tot_Count else 0 end) TOT_COUNT ,'||
                       ' SUM(CASE WHEN CAL.report_date =  :l_asof_date'||
                       ' THEN decode(:l_currency_code,:l_global_primary,Amount_g,:l_global_secondary,Amount_g1,CURRENCY_CD_F,Amount_f)'||
                       ' ELSE 0 END) new_value,'||
                       ' SUM(CASE WHEN CAL.report_date =  :l_prev_date'||
                       ' THEN decode(:l_currency_code,:l_global_primary,Amount_g,:l_global_secondary,Amount_g1,CURRENCY_CD_F,Amount_f)'||
                       ' ELSE 0 END) old_value,'||
                       ' SUM(CASE WHEN CAL.report_date =  :l_asof_date'||
                       ' THEN FACT.NO_LINES else 0 end) NO_LINES,'||
                       ' SUM(CASE WHEN CAL.report_date =  :l_asof_date'||
                       ' THEN con_ord'||
                       ' ELSE NULL END) con_ord'||
                       ' FROM '||l_tableList||
                       ' WHERE CAL.calendar_id = -1'||
                       ' AND FACT.Time_Id = CAL.Time_Id'||
                       ' AND FACT.Period_Type_id = CAL.Period_Type_Id'||
                       ' AND REPORT_DATE IN (:l_asof_date,:l_prev_date)'||l_msiteFilter||
                       ' AND BITAND(CAL.Record_Type_Id, :l_record_type_id) =   CAL.Record_Type_Id'||
                       ' GROUP BY MEASURE_TYPE) FACT1, '||
		 ' FND_LOOKUPS flkup'||
                 ' WHERE'||
                 ' flkup.LOOKUP_TYPE = ''IBE_BI_MEASURES'''||
                 ' AND flkup.LOOKUP_CODE = FACT1.MEASURE_TYPE(+)'||
                 ' GROUP BY flkup.meaning,decode(flkup.lookup_code,''IBE_ORD_ASSISTED'', 3,'||
                 '''IBE_ORD_UNASSISTED'',4,'||
                 '''IBE_ORD_TOTAL'',5,'||
                 '''IBE_ORD_CAMPAIGN'',7,'||
		 '''IBE_ORD_QUOTING'',9,'||
   		 '''IBE_QOT_ASSISTED'', 0,'||
                 '''IBE_QOT_UNASSISTED'',1,'||
                 '''IBE_QOT_TOTAL'',2,'||
                 '''IBE_QOT_CAMPAIGN'',6,'||
                 '''IBE_QOT_QUOTING'',8 )) ORDER BY OB';

  x_custom_sql  := l_custom_sql;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_cart_ord_pvt.get_cart_ord_port_sql.query',l_custom_sql);
   END IF;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  x_custom_output.Extend(6);

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

  l_custom_rec.attribute_name := ':l_currency_code' ;
  l_custom_rec.attribute_value:= l_currency_code;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(3) := l_custom_rec;


  l_custom_rec.attribute_name := ':l_record_type_id' ;
  l_custom_rec.attribute_value:= l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_primary' ;
  l_custom_rec.attribute_value:= l_global_primary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_secondary' ;
  l_custom_rec.attribute_value:= l_global_secondary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(6) := l_custom_rec;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_cart_ord_pvt.get_cart_ord_port_sql.end','END');
    END IF;

END GET_CART_ORD_PORT_SQL;

END IBE_BI_CART_ORD_PVT;

/
