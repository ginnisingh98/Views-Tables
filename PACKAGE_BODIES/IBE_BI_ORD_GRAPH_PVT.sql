--------------------------------------------------------
--  DDL for Package Body IBE_BI_ORD_GRAPH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_BI_ORD_GRAPH_PVT" AS
/* $Header: IBEVBIORDGRAB.pls 120.4 2005/10/17 20:52:36 narao ship $ */
PROCEDURE GET_ORDER_GRAPH_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL )
IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_timespan         NUMBER;
  l_sequence         NUMBER;
  l_cur_start        DATE;
  l_mid_start        DATE;
  l_prev_start       DATE;
  l_pprev_start      DATE;
  l_pcur_start       DATE;
  l_cur_year         NUMBER;
  l_prev_year        NUMBER;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type  VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;
  l_timetable        VARCHAR2(1000);
  l_whereclause      VARCHAR2(3200);
  l_msiteFilter      VARCHAR2(1000);
  l_tableList        VARCHAR2(1000);
  l_allSelect        VARCHAR2(1000);
  l_allWhere        VARCHAR2(1000);
dbg_msg           VARCHAR2(3200);
  l_g_p   VARCHAR2(15);
  l_g_s VARCHAR2(15) ;

  /**************************************************************************/
  /* These two variables are used to eliminate the Records corresponding to */
  /* those stores that the user does not have access to                     */
  /**************************************************************************/
BEGIN

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_order_graph_sql.begin','BEGIN');
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

  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITES_V to IBW_BI_MSITE_DIMN_V.

  IF (trim(l_minisite_id) is null) then
    l_tableList := ' IBE_BI_CART_ORD_MV FACT,'||
                   --' IBE_BI_MSITES_V  MSITES';
                     ' IBW_BI_MSITE_DIMN_V  MSITES';

    l_msiteFilter :=' AND FACT.MINISITE_ID = MSITES.ID(+)';

    l_allSelect  := ' MINISITE_ID,ID,';
    l_allWhere   := ' AND nvl(decode(MINISITE_ID,NULL,NULL,nvl(ID,-999)),0)  <> -999 ';

  ELSE
    l_tableList := ' IBE_BI_CART_ORD_MV FACT';

    l_msiteFilter := ' AND FACT.MINISITE_ID in (&SITE+SITE) ';

  END IF;

 IF(l_period_type = 'FII_TIME_ENT_YEAR') THEN
  l_comparison_type := 'SEQUENTIAL';
  l_record_type_id := 119;
  l_timetable  := 'FII_TIME_ENT_YEAR';
  l_whereclause := ' AND   TIME_PERIOD.SEQUENCE BETWEEN :l_sequence-3 AND :l_sequence';

  IBE_BI_PMV_UTIL_PVT.ENT_YR_SPAN(p_asof_date => l_asof_date,
                x_timespan  => l_timespan,
                x_sequence  => l_sequence);

  ELSIF (l_period_type = 'FII_TIME_ENT_QTR') THEN
  l_record_type_id := 55;
  l_timetable  := 'FII_TIME_ENT_QTR';
  l_whereclause:= ' AND   TIME_PERIOD.start_date between :l_prev_start and :l_cur_start'||
                   ' AND   TIME_PERIOD.ent_year_id BETWEEN :l_prev_year AND :l_cur_year ';

  IBE_BI_PMV_UTIL_PVT.ENT_QTR_SPAN(
                  p_asof_date => l_asof_date,
                  p_comparator=> l_comparison_type,
                  x_cur_start => l_cur_start,
                  x_mid_start => l_mid_start,
                  x_prev_start=> l_prev_start,
                  x_cur_year  => l_cur_year,
                  x_prev_year => l_prev_year,
                  x_timespan  => l_timespan);

  ELSIF (l_period_type = 'FII_TIME_ENT_PERIOD') THEN
  l_record_type_id := 23;
  l_timetable  := 'FII_TIME_ENT_PERIOD';
  l_whereclause:= ' AND   TIME_PERIOD.start_date between :l_prev_start and :l_cur_start ';

 IBE_BI_PMV_UTIL_PVT.ENT_PRD_SPAN(
                    p_asof_date => l_asof_date,
                    p_comparator=> l_comparison_type,
                    x_cur_start => l_cur_start,
                    x_mid_start => l_mid_start,
                    x_prev_start=> l_prev_start,
                    x_cur_year  => l_cur_year,
                    x_prev_year => l_prev_year,
                    x_timespan  => l_timespan);

  IF(l_comparison_type = 'SEQUENTIAL') THEN
   l_prev_start := l_mid_start + 1;
  END IF;

  ELSIF (l_period_type = 'FII_TIME_WEEK') THEN
  l_record_type_id := 11;
  l_timetable  := 'FII_TIME_WEEK';
  l_whereclause:= ' AND   TIME_PERIOD.start_date between :l_prev_start and :l_cur_start ';

  IBE_BI_PMV_UTIL_PVT.WEEK_SPAN(
                p_asof_date => l_asof_date,
                p_comparator => l_comparison_type,
                x_cur_start => l_cur_start,
                x_prev_start => l_prev_start,
                x_pcur_start => l_pcur_start,
                x_pprev_start => l_pprev_start,
                x_timespan =>  l_timespan);
  l_mid_start := l_prev_start;

  END IF;

  dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_currency_code||
  ','||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||
  l_comparison_type||','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||
  l_minisite_id||','||'RECORD_TYPE_ID:'||l_record_type_id||','||'TIME_TABLE:'||
  l_timetable||','||'CURR_START_DATE:'||l_cur_start||','||'PREV_START_DATE:'||
  l_prev_start||','||'MID_START_DATE:'||l_mid_start||','||'CURR_YEAR:'||
  l_cur_year||','||'PREV_YEAR:'||l_prev_year||','||'TIME_SPAN:'||l_timespan;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_order_graph_sql.parameters',dbg_msg);
   END IF;

 IF(l_comparison_type = 'SEQUENTIAL') THEN

 /*************************************************************************/
 /* The following Query would work for all the Cases where Comparision    */
 /* type is sequential. Depending upon the Period Type selected the       */
 /* Value of TIME_PERIOD and the whereclause would change                 */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/


 l_custom_sql :='SELECT FACT.NAME VIEWBY,FACT.NAME IBE_ATTR1,'||
               ' SUM(NVL(AMOUNT_TOTAL,0)) IBE_VAL2,'||
               ' SUM(NVL(AMOUNT_ASSIST,0)) IBE_VAL4,'||
               ' SUM(NVL(AMOUNT_UNASSIST,0)) IBE_VAL6,'||
               ' NULL IBE_VAL1,'||
               ' NULL IBE_VAL3,'||
               ' NULL IBE_VAL5'||
               ' FROM  ('||
	       ' SELECT TIME.NAME,'||l_allSelect ||
	       ' NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
               ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
	       ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_TOTAL,'||
               ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
	       ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_ASSIST,'||
               ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
	       ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_UNASSIST,'||
               ' REPORT_DATE'||
               ' FROM'||
	          ' (SELECT' ||
                  ' TIME_PERIOD.NAME,'||
                  ' CAL.REPORT_DATE,'||
                  ' CAL.PERIOD_TYPE_ID,'||
                  ' CAL.TIME_ID'||
                  ' FROM'||
                  ' FII_TIME_RPT_STRUCT_V CAL,'||l_timetable||' TIME_PERIOD'||
                  ' WHERE BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                  ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE) ' ||l_whereclause|| ') TIME,'||
	        l_tableList||
                ' WHERE'||
                ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                ' AND FACT.PERIOD_TYPE_ID(+)= TIME.PERIOD_TYPE_ID'||
                l_msiteFilter||') FACT'||
                ' WHERE FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'|| l_allWhere ||
                ' GROUP BY FACT.NAME, REPORT_DATE ORDER BY REPORT_DATE';


 ELSE

 if l_period_type = 'FII_TIME_WEEK' THEN

 /*************************************************************************/
 /* The following Query would work when the Time Period is WEEK and the   */
 /* Comparison type is Year-To-Year.                                      */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/

 l_custom_sql := 'SELECT MAX(NAME) VIEWBY,MAX(NAME) IBE_ATTR1,'||
                ' SUM(NVL(CT_AMOUNT,0)) IBE_VAL2,'||
                ' SUM(NVL(CA_AMOUNT,0)) IBE_VAL4,'||
                ' SUM(NVL(CU_AMOUNT,0)) IBE_VAL6,'||
                ' SUM(NVL(PT_AMOUNT,0)) IBE_VAL1,'||
                ' SUM(NVL(PA_AMOUNT,0)) IBE_VAL3,'||
                ' SUM(NVL(PU_AMOUNT,0)) IBE_VAL5'||
                ' FROM ('||
                    ' SELECT'|| l_allSelect ||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN null else fact.name end) NAME,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN fact.year445_id+1 else fact.year445_id end) ENT_YEAR_ID,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.AMOUNT_TOTAL else 0 end) PT_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.AMOUNT_TOTAL else 0 end) CT_AMOUNT,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.AMOUNT_ASSISTED else 0 end) PA_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.AMOUNT_ASSISTED else 0 end) CA_AMOUNT,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.AMOUNT_UNASSISTED else 0 end) PU_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.AMOUNT_UNASSISTED else 0 end) CU_AMOUNT,'||
                    ' SEQUENCE'||
                    ' FROM ('||
                        ' SELECT'|| l_allSelect ||
		        ' NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_TOTAL,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_ASSISTED,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_UNASSISTED,'||
                        ' TIME.PERIOD_TYPE_ID,'||
		        ' TIME.TIME_ID,TIME.SEQUENCE,TIME.START_DATE,'||
		        ' TIME.YEAR445_ID,TIME.NAME'||
                        ' FROM'||
		            ' ( SELECT ' ||
                            ' TIME_PERIOD.NAME,'||
                            ' CAL.REPORT_DATE,'||
                            ' CAL.PERIOD_TYPE_ID,'||
                            ' CAL.TIME_ID, '||
                            ' TIME_PERIOD.SEQUENCE,'||
                            ' TIME_PERIOD.START_DATE,'||
                            ' TIME.year445_id'||
                            ' FROM '||
                            ' FII_TIME_RPT_STRUCT_V CAL,'||
                            ' FII_TIME_WEEK TIME_PERIOD,'||
                            ' FII_TIME_p445 TIME'||
                            ' WHERE '||
                            ' BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                            ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE)'||
                            ' AND (TIME_PERIOD.start_date between :l_pprev_start  and :l_pcur_start OR'||
		            ' TIME_PERIOD.start_date between :l_prev_start  and :l_cur_start)'||
                            ' AND TIME.period445_id = TIME_PERIOD.period445_id ) TIME,'||
		        l_tableList||
		        ' WHERE '||
		        ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                        ' AND FACT.PERIOD_TYPE_ID(+)= TIME.PERIOD_TYPE_ID'||
                        l_msiteFilter||' ) FACT'||
                ' WHERE'||
                ' FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'|| l_allWhere ||
            ' ) GROUP BY ENT_YEAR_ID,SEQUENCE'||
            ' ORDER BY ENT_YEAR_ID,SEQUENCE';

 ELSE

 /*************************************************************************/
 /* The following Query would work when the Time Period is anything other */
 /* than WEEK and the Comparison type is Year-To-Year.                    */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/

 l_custom_sql :='SELECT  MAX(NAME) VIEWBY,MAX(NAME) IBE_ATTR1,'||
                ' SUM(NVL(CT_AMOUNT,0)) IBE_VAL2,'||
                ' SUM(NVL(CA_AMOUNT,0)) IBE_VAL4,'||
                ' SUM(NVL(CU_AMOUNT,0)) IBE_VAL6,'||
                ' SUM(NVL(PT_AMOUNT,0)) IBE_VAL1,'||
                ' SUM(NVL(PA_AMOUNT,0)) IBE_VAL3,'||
                ' SUM(NVL(PU_AMOUNT,0)) IBE_VAL5'||
                ' FROM ('||
                    ' SELECT'||l_allSelect ||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN null else fact.name end) NAME,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN fact.ent_year_id+1 else fact.ent_year_id end) ENT_YEAR_ID,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.AMOUNT_TOTAL else 0 end) PT_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.AMOUNT_TOTAL else 0 end) CT_AMOUNT,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.AMOUNT_ASSISTED else 0 end) PA_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.AMOUNT_ASSISTED else 0 end) CA_AMOUNT,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.AMOUNT_UNASSISTED else 0 end) PU_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.AMOUNT_UNASSISTED else 0 end) CU_AMOUNT,'||
                    ' SEQUENCE'||
                    ' FROM ('||
                        ' SELECT'|| l_allSelect ||
		        ' NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_TOTAL,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_ASSISTED,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_UNASSISTED,'||
                        ' TIME.PERIOD_TYPE_ID,'||
		        ' TIME.TIME_ID,TIME.SEQUENCE,TIME.START_DATE,'||
		        ' TIME.ENT_YEAR_ID,TIME.NAME'||
                        ' FROM'||
	                    ' (SELECT' ||
                            ' TIME_PERIOD.NAME,'||
                            ' CAL.REPORT_DATE,'||
                            ' CAL.PERIOD_TYPE_ID,'||
                            ' CAL.TIME_ID,'||
                            ' TIME_PERIOD.SEQUENCE,'||
                            ' TIME_PERIOD.START_DATE,'||
		            ' TIME_PERIOD.ENT_YEAR_ID'||
                            ' FROM'||
                            ' FII_TIME_RPT_STRUCT_V CAL,'||l_timetable||' TIME_PERIOD'||
                        ' WHERE BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                        ' AND BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                        ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE) '|| l_whereclause|| ') TIME,'||
		    l_tableList||
                    ' WHERE'||
                    ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                    ' AND FACT.PERIOD_TYPE_ID (+)= TIME.PERIOD_TYPE_ID'||
                    l_msiteFilter ||') FACT'||
		    ' WHERE '||
                    ' FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'||l_allWhere ||
                ' ) GROUP BY ENT_YEAR_ID,SEQUENCE'||
                ' ORDER BY ENT_YEAR_ID, SEQUENCE';


 END IF;

END IF;

    x_custom_sql  := l_custom_sql;

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_order_graph_sql.query',l_custom_sql);
  END IF;

    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    x_custom_output.EXTEND(13);

    l_custom_rec.attribute_name := ':l_sequence';
    l_custom_rec.attribute_value := l_sequence;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

    x_custom_output(1) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_record_type_id' ;
    l_custom_rec.attribute_value:= l_record_type_id;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(2) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_prev_start' ;
    l_custom_rec.attribute_value:= to_char(l_prev_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(3) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_cur_start' ;
    l_custom_rec.attribute_value:= to_char(l_cur_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(4) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_prev_year' ;
    l_custom_rec.attribute_value:= l_prev_year;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(5) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_cur_year' ;
    l_custom_rec.attribute_value:= l_cur_year;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(6) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_timespan' ;
    l_custom_rec.attribute_value:= l_timespan;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(7) := l_custom_rec;


    l_custom_rec.attribute_name := ':l_mid_start' ;
    l_custom_rec.attribute_value:= to_char(l_mid_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(8) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_pprev_start' ;
    l_custom_rec.attribute_value:= to_char(l_pprev_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(9) := l_custom_rec;


    l_custom_rec.attribute_name := ':l_pcur_start' ;
    l_custom_rec.attribute_value:= to_char(l_pcur_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(10) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_currency_code' ;
    l_custom_rec.attribute_value:= l_currency_code;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    x_custom_output(11) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_g_p' ;
  l_custom_rec.attribute_value:= l_g_p;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(12) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_g_s' ;
  l_custom_rec.attribute_value:= l_g_s;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(13) := l_custom_rec;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_order_graph_sql.end','END');
	END IF;

END GET_ORDER_GRAPH_SQL;


PROCEDURE GET_AVG_ORD_GRAPH_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL )
IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_timespan         NUMBER;
  l_sequence         NUMBER;
  l_cur_start        DATE;
  l_mid_start        DATE;
  l_prev_start       DATE;
  l_pprev_start      DATE;
  l_pcur_start       DATE;
  l_cur_year         NUMBER;
  l_prev_year        NUMBER;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type  VARCHAR2(3200);
  l_currency_code    VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;
  l_timetable        VARCHAR2(1000);
  l_whereclause      VARCHAR2(3200);
  l_msiteFilter      VARCHAR2(1000);
  l_tableList        VARCHAR2(1000);
  l_allSelect        VARCHAR2(1000);
  l_allWhere        VARCHAR2(1000);
  dbg_msg           VARCHAR2(3200);
  l_g_p   VARCHAR2(15);
  l_g_s VARCHAR2(15) ;

  /**************************************************************************/
  /* These two variables are used to eliminate the Records corresponding to */
  /* those stores that the user does not have access to                     */
  /**************************************************************************/
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_avg_ord_graph_sql.begin','BEGIN');
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

  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITES_V to IBW_BI_MSITE_DIMN_V.

 IF (trim(l_minisite_id) is null) then
    l_tableList := ' IBE_BI_CART_ORD_MV FACT,'||
--                   ' IBE_BI_MSITES_V  MSITES';
                   ' IBW_BI_MSITE_DIMN_V  MSITES';

    l_msiteFilter :=' AND FACT.MINISITE_ID = MSITES.ID(+)';

    l_allSelect  := ' MINISITE_ID,ID,';
    l_allWhere   := ' AND nvl(decode(MINISITE_ID,NULL,NULL,nvl(ID,-999)),0)  <> -999 ';

  ELSE
    l_tableList := ' IBE_BI_CART_ORD_MV FACT';

    l_msiteFilter := ' AND FACT.MINISITE_ID  in (&SITE+SITE) ';

  END IF;


 IF(l_period_type = 'FII_TIME_ENT_YEAR') THEN
  l_comparison_type := 'SEQUENTIAL';
  l_record_type_id := 119;
  l_timetable  := 'FII_TIME_ENT_YEAR';
  l_whereclause := ' AND TIME_PERIOD.SEQUENCE BETWEEN :l_sequence-3 AND :l_sequence';

  IBE_BI_PMV_UTIL_PVT.ENT_YR_SPAN(p_asof_date => l_asof_date,
                x_timespan  => l_timespan,
                x_sequence  => l_sequence);

  ELSIF (l_period_type = 'FII_TIME_ENT_QTR') THEN
  l_record_type_id := 55;
  l_timetable  := 'FII_TIME_ENT_QTR';
  l_whereclause:= ' AND TIME_PERIOD.start_date between :l_prev_start and :l_cur_start'||
                   ' AND TIME_PERIOD.ent_year_id BETWEEN :l_prev_year AND :l_cur_year ';

  IBE_BI_PMV_UTIL_PVT.ENT_QTR_SPAN(
                  p_asof_date => l_asof_date,
                  p_comparator=> l_comparison_type,
                  x_cur_start => l_cur_start,
                  x_mid_start => l_mid_start,
                  x_prev_start=> l_prev_start,
                  x_cur_year  => l_cur_year,
                  x_prev_year => l_prev_year,
                  x_timespan  => l_timespan);

  ELSIF (l_period_type = 'FII_TIME_ENT_PERIOD') THEN
  l_record_type_id := 23;
  l_timetable  := 'FII_TIME_ENT_PERIOD';
  l_whereclause:= ' AND TIME_PERIOD.start_date between :l_prev_start and :l_cur_start ';

  IBE_BI_PMV_UTIL_PVT.ENT_PRD_SPAN(
                    p_asof_date => l_asof_date,
                    p_comparator=> l_comparison_type,
                    x_cur_start => l_cur_start,
                    x_mid_start => l_mid_start,
                    x_prev_start=> l_prev_start,
                    x_cur_year  => l_cur_year,
                    x_prev_year => l_prev_year,
                    x_timespan  => l_timespan);

  IF(l_comparison_type = 'SEQUENTIAL') THEN
   l_prev_start := l_mid_start + 1;
  END IF;

  ELSIF (l_period_type = 'FII_TIME_WEEK') THEN
  l_record_type_id := 11;
  l_timetable  := 'FII_TIME_WEEK';
  l_whereclause:= ' AND TIME_PERIOD.start_date between :l_prev_start and :l_cur_start ';

  IBE_BI_PMV_UTIL_PVT.WEEK_SPAN(
                p_asof_date => l_asof_date,
                p_comparator => l_comparison_type,
                x_cur_start => l_cur_start,
                x_prev_start => l_prev_start,
                x_pcur_start => l_pcur_start,
                x_pprev_start => l_pprev_start,
                x_timespan =>  l_timespan);

  l_mid_start := l_prev_start;


  END IF;

 dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_currency_code||
 ','||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||
 l_comparison_type||','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||
 l_minisite_id||','||'RECORD_TYPE_ID:'||l_record_type_id||','||'TIME_TABLE:'||
 l_timetable||','||'CURR_START_DATE:'||l_cur_start||','||'PREV_START_DATE:'||
 l_prev_start||','||'MID_START_DATE:'||l_mid_start||','||'CURR_YEAR:'||
 l_cur_year||','||'PREV_YEAR:'||l_prev_year||','||'TIME_SPAN:'||l_timespan;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_avg_ord_graph_sql.parameters',dbg_msg);
 END IF;

 IF(l_comparison_type = 'SEQUENTIAL') THEN

 /*************************************************************************/
 /* The following Query would work for all the Cases where Comparision    */
 /* type is sequential. Depending upon the Period Type selected the       */
 /* Value of TIME_PERIOD and the whereclause would change                 */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/


  l_custom_sql :='SELECT FACT.NAME VIEWBY,FACT.NAME IBE_ATTR1,'||
                ' decode(SUM(NVL(TOTAL_CNT,0)),0,0,(SUM(NVL(AMOUNT_TOTAL,0))/SUM(NVL(TOTAL_CNT,0)))) IBE_VAL2,'||
                ' decode(SUM(NVL(ASSIST_CNT,0)),0,0,(SUM(NVL(AMOUNT_ASSIST,0))/SUM(NVL(ASSIST_CNT,0)))) IBE_VAL4,'||
                ' decode(SUM(NVL(UNASSIST_CNT,0)),0,0,(SUM(NVL(AMOUNT_UNASSIST,0))/SUM(NVL(UNASSIST_CNT,0)))) IBE_VAL6,'||
                ' NULL IBE_VAL1,'||
                ' NULL IBE_VAL3,'||
                ' NULL IBE_VAL5'||
                ' FROM  ('||
                    ' SELECT '||l_allSelect ||
				' TIME.NAME, NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
 	            ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
 	            ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_TOTAL,'||
                    ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
 	            ' TOT_COUNT ,0) TOTAL_CNT,'||
                    ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
 	            ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_ASSIST,'||
                    ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
 	            ' TOT_COUNT ,0) ASSIST_CNT,'||
                    ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
 	            ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_UNASSIST,'||
                    ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
 	            ' TOT_COUNT ,0) UNASSIST_CNT,'||
                    ' TIME.PERIOD_TYPE_ID,TIME.TIME_ID,TIME.REPORT_DATE'||
                    ' FROM'||
 	               ' (SELECT'||
                       ' TIME_PERIOD.NAME,'||
                       ' CAL.REPORT_DATE,'||
                       ' CAL.PERIOD_TYPE_ID,'||
                       ' CAL.TIME_ID'||
                       ' FROM'||
                       ' FII_TIME_RPT_STRUCT_V CAL,'||l_timetable||' TIME_PERIOD'||
                       ' WHERE BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                       ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE) ' ||l_whereclause|| ') TIME,'||
	           l_tableList||
                   ' WHERE'||
                   ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                   ' AND FACT.PERIOD_TYPE_ID(+)= TIME.PERIOD_TYPE_ID'||
                   l_msiteFilter||') FACT'||
                   ' WHERE FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'|| l_allWhere ||
               ' GROUP BY FACT.NAME, REPORT_DATE ORDER BY REPORT_DATE';




 ELSE

 IF l_period_type = 'FII_TIME_WEEK' THEN

 /*************************************************************************/
 /* The following Query would work when the Time Period is WEEK and the   */
 /* Comparison type is Year-To-Year.                                      */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/


  l_custom_sql :='SELECT MAX(NAME) VIEWBY, MAX(NAME) IBE_ATTR1,'||
                ' decode(SUM(NVL(CT_COUNT,0)),0,0,(SUM(NVL(CT_AMOUNT,0))/SUM(CT_COUNT))) IBE_VAL2,'||
                ' decode(SUM(NVL(CA_COUNT,0)),0,0,(SUM(NVL(CA_AMOUNT,0))/SUM(CA_COUNT))) IBE_VAL4,'||
                ' decode(SUM(NVL(CU_COUNT,0)),0,0,(SUM(NVL(CU_AMOUNT,0))/SUM(CU_COUNT))) IBE_VAL6,'||
                ' decode(SUM(NVL(PT_COUNT,0)),0,0,(SUM(NVL(PT_AMOUNT,0))/SUM(PT_COUNT))) IBE_VAL1,'||
                ' decode(SUM(NVL(PA_COUNT,0)),0,0,(SUM(NVL(PA_AMOUNT,0))/SUM(PA_COUNT))) IBE_VAL3,'||
                ' decode(SUM(NVL(PU_COUNT,0)),0,0,(SUM(NVL(PU_AMOUNT,0))/SUM(PU_COUNT))) IBE_VAL5'||
                ' FROM ('||
                    ' SELECT'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN null else fact.name end) NAME,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN fact.year445_id+1 else fact.year445_id end) ENT_YEAR_ID,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.AMOUNT_TOTAL else 0 end) PT_AMOUNT,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.TOTAL_CNT else 0 end) PT_COUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.AMOUNT_TOTAL else 0 end) CT_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.TOTAL_CNT else 0 end) CT_COUNT,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.AMOUNT_ASSIST else 0 end) PA_AMOUNT,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.ASSIST_CNT else 0 end) PA_COUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.AMOUNT_ASSIST else 0 end) CA_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.ASSIST_CNT else 0 end) CA_COUNT,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.AMOUNT_UNASSIST else 0 end) PU_AMOUNT,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.UNASSIST_CNT else 0 end) PU_COUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.AMOUNT_UNASSIST else 0 end) CU_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.UNASSIST_CNT else 0 end) CU_COUNT,'||
                    ' REPORT_DATE,'||
                    ' SEQUENCE'||
                    ' FROM ('||
		        ' SELECT'|| l_allSelect ||
                        ' NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_TOTAL,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' TOT_COUNT,0) TOTAL_CNT,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_ASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' TOT_COUNT,0) ASSIST_CNT,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_UNASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' TOT_COUNT,0) UNASSIST_CNT,'||
                        ' TIME.PERIOD_TYPE_ID,'||
		        ' TIME.TIME_ID,TIME.SEQUENCE,TIME.START_DATE,'||
		        ' TIME.YEAR445_ID,TIME.NAME,TIME.REPORT_DATE'||
                        ' FROM '||
		            ' ( SELECT '||
                            ' TIME_PERIOD.NAME,'||
                            ' CAL.REPORT_DATE,'||
                            ' CAL.PERIOD_TYPE_ID,'||
                            ' CAL.TIME_ID, '||
                            ' TIME_PERIOD.SEQUENCE,'||
                            ' TIME_PERIOD.START_DATE,'||
                            ' TIME.year445_id'||
                            ' FROM '||
                            ' FII_TIME_RPT_STRUCT_V CAL,'||
                            ' FII_TIME_WEEK TIME_PERIOD,'||
                            ' FII_TIME_p445 TIME'||
                            ' WHERE '||
                            ' BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                            ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE)'||
                            ' AND (TIME_PERIOD.start_date between :l_pprev_start  and :l_pcur_start OR'||
		            ' TIME_PERIOD.start_date between :l_prev_start  and :l_cur_start)'||
                            ' AND TIME.period445_id = TIME_PERIOD.period445_id ) TIME,'||
		        l_tableList||
		        ' WHERE '||
		        ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                        ' AND FACT.PERIOD_TYPE_ID(+)= TIME.PERIOD_TYPE_ID'||
                        l_msiteFilter||' ) FACT'||
                   ' WHERE'||
                   ' FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'|| l_allWhere ||
               ' ) GROUP BY ENT_YEAR_ID,SEQUENCE'||
               ' ORDER BY ENT_YEAR_ID,SEQUENCE';


 ELSE

 /*************************************************************************/
 /* The following Query would work when the Time Period is anything other */
 /* than WEEK and the Comparison type is Year-To-Year.                    */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/

  l_custom_sql :='SELECT MAX(NAME) VIEWBY,MAX(NAME) IBE_ATTR1,'||
                ' decode(SUM(NVL(CT_COUNT,0)),0,0,(SUM(NVL(CT_AMOUNT,0))/SUM(CT_COUNT))) IBE_VAL2,'||
                ' decode(SUM(NVL(CA_COUNT,0)),0,0,(SUM(NVL(CA_AMOUNT,0))/SUM(CA_COUNT))) IBE_VAL4,'||
                ' decode(SUM(NVL(CU_COUNT,0)),0,0,(SUM(NVL(CU_AMOUNT,0))/SUM(CU_COUNT))) IBE_VAL6,'||
                ' decode(SUM(NVL(PT_COUNT,0)),0,0,(SUM(NVL(PT_AMOUNT,0))/SUM(PT_COUNT))) IBE_VAL1,'||
                ' decode(SUM(NVL(PA_COUNT,0)),0,0,(SUM(NVL(PA_AMOUNT,0))/SUM(PA_COUNT))) IBE_VAL3,'||
                ' decode(SUM(NVL(PU_COUNT,0)),0,0,(SUM(NVL(PU_AMOUNT,0))/SUM(PU_COUNT))) IBE_VAL5'||
                ' FROM ('||
                    ' SELECT'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN null else fact.name end) NAME,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN fact.ent_year_id+1 else fact.ent_year_id end) ENT_YEAR_ID,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.AMOUNT_TOTAL else 0 end) PT_AMOUNT,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.TOTAL_CNT else 0 end) PT_COUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.AMOUNT_TOTAL else 0 end) CT_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.TOTAL_CNT else 0 end) CT_COUNT,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.AMOUNT_ASSIST else 0 end) PA_AMOUNT,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.ASSIST_CNT else 0 end) PA_COUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.AMOUNT_ASSIST else 0 end) CA_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.ASSIST_CNT else 0 end) CA_COUNT,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.AMOUNT_UNASSIST else 0 end) PU_AMOUNT,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.UNASSIST_CNT else 0 end) PU_COUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.AMOUNT_UNASSIST else 0 end) CU_AMOUNT,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.UNASSIST_CNT else 0 end) CU_COUNT,'||
                    ' fact.REPORT_DATE,'||
                    ' fact.SEQUENCE'||
                    ' FROM ('||
                        ' SELECT'|| l_allSelect||
                        ' NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_TOTAL,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' TOT_COUNT,0) TOTAL_CNT,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_ASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' TOT_COUNT,0) ASSIST_CNT,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' decode(:l_currency_code,:l_g_p,AMOUNT_G,:l_g_s,AMOUNT_G1,CURRENCY_CD_F,AMOUNT_F),0) AMOUNT_UNASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' TOT_COUNT,0) UNASSIST_CNT,'||
                        ' TIME.PERIOD_TYPE_ID,'||
		        ' TIME.TIME_ID,TIME.SEQUENCE,TIME.START_DATE,'||
		        ' TIME.ENT_YEAR_ID,TIME.NAME,TIME.REPORT_DATE'||
                        ' FROM'||
	                    ' (SELECT'||
                            ' TIME_PERIOD.NAME,'||
                            ' CAL.REPORT_DATE,'||
                            ' CAL.PERIOD_TYPE_ID,'||
                            ' CAL.TIME_ID,'||
                            ' TIME_PERIOD.SEQUENCE,'||
                            ' TIME_PERIOD.START_DATE,'||
		            ' TIME_PERIOD.ENT_YEAR_ID'||
                            ' FROM '||
                            ' FII_TIME_RPT_STRUCT_V CAL,'||l_timetable||' TIME_PERIOD'||
                        ' WHERE BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                        ' AND BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                        ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE) '|| l_whereclause|| ') TIME,'||
		    l_tableList||
                    ' WHERE'||
                    ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                    ' AND FACT.PERIOD_TYPE_ID (+)= TIME.PERIOD_TYPE_ID'||
                    l_msiteFilter ||') FACT'||
		    ' WHERE '||
                    ' FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'||l_allWhere ||
                '  ) GROUP BY ENT_YEAR_ID,SEQUENCE'||
                ' ORDER BY ENT_YEAR_ID, SEQUENCE';



END IF;

END IF;

  x_custom_sql  := l_custom_sql;

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_avg_ord_graph_sql.query',l_custom_sql);
  END IF;

    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    x_custom_output.EXTEND(13);

    l_custom_rec.attribute_name := ':l_sequence';
    l_custom_rec.attribute_value := l_sequence;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

    x_custom_output(1) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_record_type_id' ;
    l_custom_rec.attribute_value:= l_record_type_id;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(2) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_prev_start' ;
    l_custom_rec.attribute_value:= to_char(l_prev_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(3) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_cur_start' ;
    l_custom_rec.attribute_value:= to_char(l_cur_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(4) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_prev_year' ;
    l_custom_rec.attribute_value:= l_prev_year;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(5) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_cur_year' ;
    l_custom_rec.attribute_value:= l_cur_year;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(6) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_timespan' ;
    l_custom_rec.attribute_value:= l_timespan;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(7) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_mid_start' ;
    l_custom_rec.attribute_value:= to_char(l_mid_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(8) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_pprev_start' ;
    l_custom_rec.attribute_value:= to_char(l_pprev_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(9) := l_custom_rec;


    l_custom_rec.attribute_name := ':l_pcur_start' ;
    l_custom_rec.attribute_value:= to_char(l_pcur_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(10) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_currency_code' ;
    l_custom_rec.attribute_value:= l_currency_code;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    x_custom_output(11) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_g_p' ;
  l_custom_rec.attribute_value:= l_g_p;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(12) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_g_s' ;
  l_custom_rec.attribute_value:= l_g_s;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(13) := l_custom_rec;

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_avg_ord_graph_sql.end','END');
    END IF;

END GET_AVG_ORD_GRAPH_SQL;

PROCEDURE GET_AVG_DISC_GRAPH_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL )
IS
  l_custom_sql       VARCHAR2(4000);
  l_parameter_name   VARCHAR2(3200);
  l_asof_date        DATE;
  l_prev_date        DATE;
  l_timespan         NUMBER;
  l_sequence         NUMBER;
  l_cur_start        Date;
  l_mid_start        Date;
  l_prev_start       Date;
  l_pprev_start      Date;
  l_pcur_start       DATE;
  l_cur_year         NUMBER;
  l_prev_year        NUMBER;
  l_record_type_id   NUMBER;
  l_period_type      VARCHAR2(3200);
  l_comparison_type  VARCHAR2(3200);
  l_c_d              VARCHAR2(3200);
  l_minisite         VARCHAR2(3200);
  l_minisite_id      VARCHAR2(3200);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;
  l_timetable        VARCHAR2(1000);
  l_whereclause      VARCHAR2(3200);
  l_msiteFilter      VARCHAR2(1000);
  l_tableList        VARCHAR2(1000);
  l_allSelect        VARCHAR2(1000);
  l_allWhere        VARCHAR2(1000);
   dbg_msg           VARCHAR2(3200);

  l_g_p   VARCHAR2(15);
  l_g_s VARCHAR2(15);


  /**************************************************************************/
  /* These two variables are used to eliminate the Records corresponding to */
  /* those stores that the user does not have access to                     */
  /**************************************************************************/


BEGIN

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_avg_disc_graph_sql.begin','BEGIN');
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

  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITES_V to IBW_BI_MSITE_DIMN_V.

  IF (trim(l_minisite_id) is null) then
    l_tableList := ' IBE_BI_CART_ORD_MV FACT,'||
                   --' IBE_BI_MSITES_V  MSITES';
                   ' IBW_BI_MSITE_DIMN_V  MSITES';

    l_msiteFilter :=' AND FACT.MINISITE_ID = MSITES.ID(+)';

	l_allSelect  := ' MINISITE_ID,ID,';
	l_allWhere   := ' AND nvl(decode(MINISITE_ID,NULL,NULL,nvl(ID,-999)),0)  <> -999 ';

  ELSE
    l_tableList := ' IBE_BI_CART_ORD_MV FACT';

    l_msiteFilter := ' AND FACT.MINISITE_ID  in (&SITE+SITE) ';

  END IF;


 IF(l_period_type = 'FII_TIME_ENT_YEAR') THEN
  l_comparison_type := 'SEQUENTIAL';
  l_record_type_id := 119;
  l_timetable  := 'FII_TIME_ENT_YEAR';
  l_whereclause := ' AND   TIME_PERIOD.SEQUENCE BETWEEN :l_sequence-3 AND :l_sequence';

  IBE_BI_PMV_UTIL_PVT.ENT_YR_SPAN(p_asof_date => l_asof_date,
                x_timespan  => l_timespan,
                x_sequence  => l_sequence);

  ELSIF (l_period_type = 'FII_TIME_ENT_QTR') THEN
  l_record_type_id := 55;
  l_timetable  := 'FII_TIME_ENT_QTR';
  l_whereclause:=  ' AND   TIME_PERIOD.start_date between :l_prev_start and :l_cur_start'||
                   ' AND   TIME_PERIOD.ent_year_id BETWEEN :l_prev_year AND :l_cur_year ';

  IBE_BI_PMV_UTIL_PVT.ENT_QTR_SPAN(
                  p_asof_date => l_asof_date,
                  p_comparator=> l_comparison_type,
                  x_cur_start => l_cur_start,
                  x_mid_start => l_mid_start,
                  x_prev_start=> l_prev_start,
                  x_cur_year  => l_cur_year,
                  x_prev_year => l_prev_year,
                  x_timespan  => l_timespan);

  ELSIF (l_period_type = 'FII_TIME_ENT_PERIOD') THEN
  l_record_type_id := 23;
  l_timetable  := 'FII_TIME_ENT_PERIOD';
  l_whereclause:= ' AND   TIME_PERIOD.start_date between :l_prev_start and :l_cur_start ';

  IBE_BI_PMV_UTIL_PVT.ENT_PRD_SPAN(
                    p_asof_date => l_asof_date,
                    p_comparator=> l_comparison_type,
                    x_cur_start => l_cur_start,
                    x_mid_start => l_mid_start,
                    x_prev_start=> l_prev_start,
                    x_cur_year  => l_cur_year,
                    x_prev_year => l_prev_year,
                    x_timespan  => l_timespan);
  IF(l_comparison_type = 'SEQUENTIAL') THEN
   l_prev_start := l_mid_start + 1;
  END IF;

  ELSIF (l_period_type = 'FII_TIME_WEEK') THEN
  l_record_type_id := 11;
  l_timetable  := 'FII_TIME_WEEK';
  l_whereclause:= ' AND   TIME_PERIOD.start_date between :l_prev_start and :l_cur_start ';

  IBE_BI_PMV_UTIL_PVT.WEEK_SPAN(
                p_asof_date => l_asof_date,
                p_comparator => l_comparison_type,
                x_cur_start => l_cur_start,
                x_prev_start => l_prev_start,
                x_pcur_start => l_pcur_start,
                x_pprev_start => l_pprev_start,
                x_timespan =>  l_timespan);
  l_mid_start := l_prev_start;

  END IF;

   dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_c_d||
   ','||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||
   l_comparison_type||','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||
   l_minisite_id||','||'RECORD_TYPE_ID:'||l_record_type_id||','||
   'TIME_TABLE:'||l_timetable||','||'CURR_START_DATE:'||l_cur_start||','||
   'PREV_START_DATE:'||l_prev_start||','||'MID_START_DATE:'||l_mid_start||
   ','||'CURR_YEAR:'||l_cur_year||','||'PREV_YEAR:'||l_prev_year||','||
   'TIME_SPAN:'||l_timespan;

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_avg_disc_graph_sql.parameters',dbg_msg);
	 END IF;

  IF(l_comparison_type = 'SEQUENTIAL') THEN

 /*************************************************************************/
 /* The following Query would work for all the Cases where Comparision    */
 /* type is sequential. Depending upon the Period Type selected the       */
 /* Value of TIME_PERIOD and the whereclause would change                 */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/


  l_custom_sql :='SELECT FACT.NAME VIEWBY,FACT.NAME IBE_ATTR1,'||
                 ' decode(SUM(NVL(LIST_TOTAL,0)),0,0,(SUM(NVL(DISC_TOTAL,0))/SUM(LIST_TOTAL)))*100 IBE_VAL2,'||
                 ' decode(SUM(NVL(LIST_ASSIST,0)),0,0,(SUM(NVL(DISC_ASSIST,0))/SUM(LIST_ASSIST)))*100 IBE_VAL4,'||
                 ' decode(SUM(NVL(LIST_UNASSIST,0)),0,0,(SUM(NVL(DISC_UNASSIST,0))/SUM(LIST_UNASSIST)))*100 IBE_VAL6,'||
                 ' NULL IBE_VAL1,'||
                 ' NULL IBE_VAL3,'||
                 ' NULL IBE_VAL5'||
                 ' FROM  ('||
                     ' SELECT '||l_allSelect ||
				 ' TIME.NAME, NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
	             ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
	             ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,CURRENCY_CD_F,DISC_AMOUNT_F),0) DISC_TOTAL,'||
                     ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
	             ' decode(:l_c_d,:l_g_p,LIST_AMOUNT_G,:l_g_s,LIST_AMOUNT_G1,CURRENCY_CD_F,LIST_AMOUNT_F),0) LIST_TOTAL,'||
                     ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
	             ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,CURRENCY_CD_F,DISC_AMOUNT_F),0) DISC_ASSIST,'||
                     ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
	             ' decode(:l_c_d,:l_g_p,LIST_AMOUNT_G,:l_g_s,LIST_AMOUNT_G1,CURRENCY_CD_F,LIST_AMOUNT_F),0) LIST_ASSIST,'||
                     ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
	             ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,CURRENCY_CD_F,DISC_AMOUNT_F),0) DISC_UNASSIST,'||
                     ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
	             ' decode(:l_c_d,:l_g_p,LIST_AMOUNT_G,:l_g_s,LIST_AMOUNT_G1,CURRENCY_CD_F,LIST_AMOUNT_F),0) LIST_UNASSIST,'||
                     ' TIME.PERIOD_TYPE_ID,TIME.TIME_ID, TIME.REPORT_DATE'||
                     ' FROM'||
	                 ' (SELECT'||
                         ' TIME_PERIOD.NAME,'||
                         ' CAL.REPORT_DATE,'||
                         ' CAL.PERIOD_TYPE_ID,'||
                         ' CAL.TIME_ID'||
                         ' FROM'||
                         ' FII_TIME_RPT_STRUCT_V CAL,'||l_timetable||' TIME_PERIOD'||
                     ' WHERE BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                     ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE) ' ||l_whereclause|| ') TIME,'||
	         l_tableList||
                 ' WHERE'||
                 ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                 ' AND FACT.PERIOD_TYPE_ID(+)= TIME.PERIOD_TYPE_ID'||
                 l_msiteFilter||') FACT'||
                 ' WHERE FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'|| l_allWhere ||
                 ' GROUP BY FACT.NAME, REPORT_DATE ORDER BY REPORT_DATE';



 ELSE

 IF l_period_type = 'FII_TIME_WEEK' THEN

 /*************************************************************************/
 /* The following Query would work when the Time Period is WEEK and the   */
 /* Comparison type is Year-To-Year.                                      */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/

 l_custom_sql := 'SELECT MAX(NAME) VIEWBY, MAX(NAME) IBE_ATTR1,'||
                ' decode(SUM(NVL(CT_LIST,0)),0,0,(SUM(NVL(CT_DISC,0))/SUM(CT_LIST)))*100 IBE_VAL2,'||
                ' decode(SUM(NVL(CA_LIST,0)),0,0,(SUM(NVL(CA_DISC,0))/SUM(CA_LIST)))*100 IBE_VAL4,'||
                ' decode(SUM(NVL(CU_LIST,0)),0,0,(SUM(NVL(CU_DISC,0))/SUM(CU_LIST)))*100 IBE_VAL6,'||
                ' decode(SUM(NVL(PT_LIST,0)),0,0,(SUM(NVL(PT_DISC,0))/SUM(PT_LIST)))*100 IBE_VAL1,'||
                ' decode(SUM(NVL(PA_LIST,0)),0,0,(SUM(NVL(PA_DISC,0))/SUM(PA_LIST)))*100 IBE_VAL3,'||
                ' decode(SUM(NVL(PU_LIST,0)),0,0,(SUM(NVL(PU_DISC,0))/SUM(PU_LIST)))*100 IBE_VAL5'||
                ' FROM ('||
                    ' SELECT'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN null else fact.name end) NAME,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN fact.year445_id+1 else fact.year445_id end) ENT_YEAR_ID,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.DISC_TOTAL else 0 end) PT_DISC,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.LIST_TOTAL else 0 end) PT_LIST,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.DISC_TOTAL else 0 end) CT_DISC,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.LIST_TOTAL else 0 end) CT_LIST,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.DISC_ASSIST else 0 end) PA_DISC,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.LIST_ASSIST else 0 end) PA_LIST,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.DISC_ASSIST else 0 end) CA_DISC,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.LIST_ASSIST else 0 end) CA_LIST,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.DISC_UNASSIST else 0 end) PU_DISC,'||
                    ' (CASE WHEN fact.start_date < :l_mid_start'||
                    ' THEN FACT.LIST_UNASSIST else 0 end) PU_LIST,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.DISC_UNASSIST else 0 end) CU_DISC,'||
                    ' (CASE WHEN fact.start_date  >= :l_mid_start'||
                    ' THEN FACT.LIST_UNASSIST else 0 end) CU_LIST,'||
                    ' FACT.REPORT_DATE,'||
                    ' FACT.SEQUENCE'||
                    ' FROM ('||
                        ' SELECT'||l_allSelect ||
                        ' NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,CURRENCY_CD_F,DISC_AMOUNT_F),0) DISC_TOTAL,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' decode(:l_c_d,:l_g_p,LIST_AMOUNT_G,:l_g_s,LIST_AMOUNT_G1,CURRENCY_CD_F,LIST_AMOUNT_F),0) LIST_TOTAL,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,CURRENCY_CD_F,DISC_AMOUNT_F),0) DISC_ASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' decode(:l_c_d,:l_g_p,LIST_AMOUNT_G,:l_g_s,LIST_AMOUNT_G1,CURRENCY_CD_F,LIST_AMOUNT_F),0) LIST_ASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,CURRENCY_CD_F,DISC_AMOUNT_F),0) DISC_UNASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' decode(:l_c_d,:l_g_p,LIST_AMOUNT_G,:l_g_s,LIST_AMOUNT_G1,CURRENCY_CD_F,LIST_AMOUNT_F),0) LIST_UNASSIST,'||
                        ' TIME.PERIOD_TYPE_ID,'||
		        ' TIME.TIME_ID,TIME.SEQUENCE,TIME.START_DATE,'||
		        ' TIME.YEAR445_ID,TIME.NAME,TIME.REPORT_DATE'||
                        ' FROM'||
		            ' ( SELECT '||
                            ' TIME_PERIOD.NAME,'||
                            ' CAL.REPORT_DATE,'||
                            ' CAL.PERIOD_TYPE_ID,'||
                            ' CAL.TIME_ID, '||
                            ' TIME_PERIOD.SEQUENCE,'||
                            ' TIME_PERIOD.START_DATE,'||
                            ' TIME.year445_id'||
                            ' FROM '||
                            ' FII_TIME_RPT_STRUCT_V CAL,'||
                            ' FII_TIME_WEEK TIME_PERIOD,'||
                            ' FII_TIME_p445 TIME'||
                            ' WHERE '||
                            ' BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                            ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE)'||
                            ' AND (TIME_PERIOD.start_date between :l_pprev_start  and :l_pcur_start OR'||
		            ' TIME_PERIOD.start_date between :l_prev_start  and :l_cur_start)'||
                            ' AND TIME.period445_id = TIME_PERIOD.period445_id ) TIME,'||
		        l_tableList||
		        ' WHERE '||
		        ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                        ' AND FACT.PERIOD_TYPE_ID(+)= TIME.PERIOD_TYPE_ID'||
                        l_msiteFilter||' ) FACT'||
                    ' WHERE'||
                    ' FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'||l_allWhere ||
                 ' ) GROUP BY ENT_YEAR_ID,SEQUENCE'||
                 ' ORDER BY ENT_YEAR_ID,SEQUENCE';


 ELSE

 /*************************************************************************/
 /* The following Query would work when the Time Period is anything other */
 /* than WEEK and the Comparison type is Year-To-Year.                    */
 /*************************************************************************/

 /*************************************************************************/
 /* VIEWBY                    : Period Name                               */
 /* IBE_ATTR1                 : Period Name                               */
 /* IBE_VAL1                  : Previous Total                            */
 /* IBE_VAL2                  : Current Total                             */
 /* IBE_VAL3                  : Previous Assisted                         */
 /* IBE_VAL4                  : Current Assisted                          */
 /* IBE_VAL5                  : Previous Unassisted                       */
 /* IBE_VAL6                  : Current Unassisted                        */
 /*************************************************************************/

 l_custom_sql := 'SELECT MAX(NAME) VIEWBY, MAX(NAME) IBE_ATTR1,'||
                ' decode(SUM(NVL(CT_LIST,0)),0,0,(SUM(NVL(CT_DISC,0))/SUM(CT_LIST)))*100 IBE_VAL2,'||
                ' decode(SUM(NVL(CA_LIST,0)),0,0,(SUM(NVL(CA_DISC,0))/SUM(CA_LIST)))*100 IBE_VAL4,'||
                ' decode(SUM(NVL(CU_LIST,0)),0,0,(SUM(NVL(CU_DISC,0))/SUM(CU_LIST)))*100 IBE_VAL6,'||
                ' decode(SUM(NVL(PT_LIST,0)),0,0,(SUM(NVL(PT_DISC,0))/SUM(PT_LIST)))*100 IBE_VAL1,'||
                ' decode(SUM(NVL(PA_LIST,0)),0,0,(SUM(NVL(PA_DISC,0))/SUM(PA_LIST)))*100 IBE_VAL3,'||
                ' decode(SUM(NVL(PU_LIST,0)),0,0,(SUM(NVL(PU_DISC,0))/SUM(PU_LIST)))*100 IBE_VAL5'||
                ' FROM ('||
                    ' SELECT'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN null else fact.name end) NAME,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN fact.ent_year_id+1 else fact.ent_year_id end) ENT_YEAR_ID,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.DISC_TOTAL else 0 end) PT_DISC,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.LIST_TOTAL else 0 end) PT_LIST,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.DISC_TOTAL else 0 end) CT_DISC,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.LIST_TOTAL else 0 end) CT_LIST,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.DISC_ASSIST else 0 end) PA_DISC,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.LIST_ASSIST else 0 end) PA_LIST,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.DISC_ASSIST else 0 end) CA_DISC,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.LIST_ASSIST else 0 end) CA_LIST,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.DISC_UNASSIST else 0 end) PU_DISC,'||
                    ' (CASE WHEN fact.start_date <= :l_mid_start'||
                    ' THEN FACT.LIST_UNASSIST else 0 end) PU_LIST,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.DISC_UNASSIST else 0 end) CU_DISC,'||
                    ' (CASE WHEN fact.start_date  > :l_mid_start'||
                    ' THEN FACT.LIST_UNASSIST else 0 end) CU_LIST,'||
                    ' fact.REPORT_DATE,'||
                    ' fact.SEQUENCE'||
                    ' FROM ('||
                        ' SELECT'|| l_allSelect ||
                        ' NVL(MEASURE_TYPE,''NULL'') MEASURE_TYPE,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,currency_cd_f,DISC_AMOUNT_F),0) DISC_TOTAL,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_TOTAL'','||
		        ' decode(:l_c_d,:l_g_p,LIST_AMOUNT_G,:l_g_s,LIST_AMOUNT_G1,currency_cd_f,LIST_AMOUNT_F),0) LIST_TOTAL,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,currency_cd_f,DISC_AMOUNT_F),0) DISC_ASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_ASSISTED'','||
		        ' decode(:l_c_d,:l_g_p,LIST_AMOUNT_G,:l_g_s,LIST_AMOUNT_G1,currency_cd_f,LIST_AMOUNT_F),0) LIST_ASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' decode(:l_c_d,:l_g_p,list_amount_g,:l_g_s,LIST_AMOUNT_G1,currency_cd_f,LIST_AMOUNT_F),0) LIST_UNASSIST,'||
                        ' decode(MEASURE_TYPE,''IBE_ORD_UNASSISTED'','||
		        ' decode(:l_c_d,:l_g_p,DISC_AMOUNT_G,:l_g_s,DISC_AMOUNT_G1,currency_cd_f,DISC_AMOUNT_F),0) DISC_UNASSIST,'||
                        ' TIME.PERIOD_TYPE_ID,'||
		        ' TIME.TIME_ID,TIME.SEQUENCE,TIME.START_DATE,'||
		        ' TIME.ENT_YEAR_ID,TIME.NAME,TIME.REPORT_DATE'||
                        ' FROM'||
	                    ' (SELECT'||
                            ' TIME_PERIOD.NAME,'||
                            ' CAL.REPORT_DATE,'||
                            ' CAL.PERIOD_TYPE_ID,'||
                            ' CAL.TIME_ID,'||
                            ' TIME_PERIOD.SEQUENCE,'||
                            ' TIME_PERIOD.START_DATE,'||
		            ' TIME_PERIOD.ENT_YEAR_ID'||
                            ' FROM'||
                            ' FII_TIME_RPT_STRUCT_V CAL,'||l_timetable||' TIME_PERIOD'||
                            ' WHERE BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                            ' AND BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                            ' AND CAL.Report_Date = LEAST(TIME_PERIOD.END_date,&BIS_CURRENT_ASOF_DATE) '|| l_whereclause|| ') TIME,'||
		        l_tableList||
                        ' WHERE'||
                        ' FACT.TIME_ID (+)= TIME.TIME_ID'||
                        ' AND FACT.PERIOD_TYPE_ID (+)= TIME.PERIOD_TYPE_ID'||
                        l_msiteFilter ||') FACT'||
		    ' WHERE '||
                    ' FACT.MEASURE_TYPE IN (''IBE_ORD_TOTAL'',''IBE_ORD_ASSISTED'',''IBE_ORD_UNASSISTED'',''NULL'')'||l_allWhere ||
                ' ) GROUP BY ENT_YEAR_ID,SEQUENCE'||
                ' ORDER BY ENT_YEAR_ID, SEQUENCE';

END IF;

END IF;

    x_custom_sql  := l_custom_sql;



   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_avg_disc_graph_sql',l_custom_sql);
    END IF;

    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    x_custom_output.EXTEND(13);

    l_custom_rec.attribute_name := ':l_sequence';
    l_custom_rec.attribute_value := l_sequence;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

    x_custom_output(1) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_record_type_id' ;
    l_custom_rec.attribute_value:= l_record_type_id;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(2) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_prev_start' ;
    l_custom_rec.attribute_value:= to_char(l_prev_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(3) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_cur_start' ;
    l_custom_rec.attribute_value:= to_char(l_cur_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(4) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_prev_year' ;
    l_custom_rec.attribute_value:= l_prev_year;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(5) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_cur_year' ;
    l_custom_rec.attribute_value:= l_cur_year;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(6) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_timespan' ;
    l_custom_rec.attribute_value:= l_timespan;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

    x_custom_output(7) := l_custom_rec;


    l_custom_rec.attribute_name := ':l_mid_start' ;
    l_custom_rec.attribute_value:= to_char(l_mid_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(8) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_pprev_start' ;
    l_custom_rec.attribute_value:= to_char(l_pprev_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(9) := l_custom_rec;


    l_custom_rec.attribute_name := ':l_pcur_start' ;
    l_custom_rec.attribute_value:= to_char(l_pcur_start,'dd/mm/yyyy');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

    x_custom_output(10) := l_custom_rec;

    l_custom_rec.attribute_name := ':l_c_d' ;
    l_custom_rec.attribute_value:= l_c_d;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    x_custom_output(11) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_g_p' ;
  l_custom_rec.attribute_value:= l_g_p;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(12) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_g_s' ;
  l_custom_rec.attribute_value:= l_g_s;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(13) := l_custom_rec;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_ord_graph_pvt.get_avg_disc_graph_sql.end','END');
    END IF;


END GET_AVG_DISC_GRAPH_SQL;

END IBE_BI_ORD_GRAPH_PVT;

/
