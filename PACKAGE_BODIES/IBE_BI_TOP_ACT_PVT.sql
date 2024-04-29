--------------------------------------------------------
--  DDL for Package Body IBE_BI_TOP_ACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_BI_TOP_ACT_PVT" AS
/* $Header: IBEVBITOPACTB.pls 120.7 2006/03/10 05:18:43 pakrishn ship $ */

PROCEDURE GET_TOP_ORDERS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL ) IS
  CURSOR FND_CURSOR IS
  SELECT LOOKUP_TYPE,LOOKUP_CODE, MEANING
  FROM FND_LOOKUPS
  WHERE LOOKUP_TYPE IN ('YES_NO', 'IBE_BI_GENERIC')
  ORDER BY LOOKUP_TYPE, LOOKUP_CODE;

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
  l_QuoteLabel       VARCHAR2(300);
  l_CartLabel        VARCHAR2(300);
  l_YesLabel         VARCHAR2(300);
  l_NoLabel          VARCHAR2(300);
  l_OrderBy          VARCHAR2(2000);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;
  l_fnd_rec            FND_CURSOR%ROWTYPE;
    dbg_msg           VARCHAR2(3200);

  l_global_primary    VARCHAR2(15);
  l_global_secondary  VARCHAR2(15) ;
BEGIN

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_orders_sql.begin','BEGIN');
END IF;

 -- initilization of variables

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
    ELSIF ( l_parameter_name = 'ORDERBY')
    THEN
      l_OrderBy := p_pmv_parameters(i).parameter_value;
    END IF;
  END LOOP;

  FOR l_fnd_rec IN fnd_cursor LOOP

    IF l_fnd_rec.lookup_type = 'IBE_BI_GENERIC' AND l_fnd_rec.lookup_code ='QUOTE' THEN
      l_QuoteLabel := l_fnd_rec.meaning;
    ELSIF l_fnd_rec.lookup_type = 'IBE_BI_GENERIC' AND l_fnd_rec.lookup_code ='CART' THEN
      l_CartLabel := l_fnd_rec.meaning;
    ELSIF l_fnd_rec.lookup_type = 'YES_NO' AND l_fnd_rec.lookup_code ='Y' THEN
      l_YesLabel := l_fnd_rec.meaning;
    ELSIF l_fnd_rec.lookup_type = 'YES_NO' AND l_fnd_rec.lookup_code ='N' THEN
      l_NoLabel := l_fnd_rec.meaning;
    END IF;

  END LOOP;


  l_record_type_id := IBE_BI_PMV_UTIL_PVT.GET_RECORD_TYPE_ID(l_period_type);


  l_prev_date :=  IBE_BI_PMV_UTIL_PVT.Get_Prev_Date(
                   p_asof_date        => l_asof_date,
                   p_period_type      => l_period_type,
                   p_comparison_type => l_comparison_type );

 dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_currency_code||
 ','||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||
 l_comparison_type||','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||
 l_minisite_id||','||'ORDER_BY:'||l_OrderBy||','||'LOOKUP_TYPE:'||
 l_fnd_rec.lookup_type||','||'QUOTE_LABEL:'||l_QuoteLabel||','||'CART_LABEL:'||
 l_CartLabel||','||'YES_LABEL:'||l_YesLabel||','||'NO_LABEL:'||l_NoLabel||','||
 'RECORD_TYPE_ID:'||l_record_type_id||','||'PREV_DATE:'||l_prev_date;
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_orders_sql.parameters',dbg_msg);
	END IF;

  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITES_V to IBW_BI_MSITE_DIMN_V.

  if (trim(l_minisite_id) is null) then
    l_tableList := ' IBE_BI_TOP_ORD_MV FACT, IBE_BI_ORDERS_MV ORD, '||
                  -- ' IBE_BI_MSITES_V MSITES, '||
                    ' IBW_BI_MSITE_DIMN_V MSITES, '||
                   ' FII_TIME_RPT_STRUCT_V CAL';

    l_msiteFilter :=' AND MSITES.ID = FACT.MINISITE_ID';

  else
    l_tableList := ' IBE_BI_TOP_ORD_MV FACT, IBE_BI_ORDERS_MV ORD, '||
                   ' FII_TIME_RPT_STRUCT_V CAL';

    l_msiteFilter := ' AND FACT.MINISITE_ID in (&SITE+SITE)';

   end if;

   /************************************************************************/
   /* IBE_VAL1          : Order Number                                     */
   /* IBE_VAL5          : Header Id                                        */
   /* IBE_ATTR1         : Customer Name                                    */
   /* IBE_ATTR2         : Order Source                                     */
   /* IBE_VAL2          : Booked Amount                                    */
   /* IBE_VAL3          : Discount Percentage                              */
   /* IBE_VAL4          : Number of Lines                                  */
   /* IBE_ATTR3         : Assisted/Unassisted                              */
   /************************************************************************/

                  --Changed the Position of IBE_VAL5 as per the Region Item Definition
                  --For Bug#:4654974-Issue#6.
  l_custom_sql := 'SELECT IBE_VAL1, IBE_VAL5, IBE_ATTR1, IBE_ATTR2, IBE_VAL2, IBE_VAL3,'||
                  ' IBE_VAL4, IBE_ATTR3 FROM ('||
                  ' SELECT '||
                  ' ORDERNUMBER IBE_VAL1, '||
                  ' CUST.VALUE IBE_ATTR1, '||
                  ' DECODE(SOURCE,''Y'',:l_QuoteLabel,:l_CartLabel) IBE_ATTR2, '||
                  ' BOOKEDAMOUNT IBE_VAL2, '||
                  ' DISCOUNT IBE_VAL3, '||
                  ' LINES IBE_VAL4, '||
                  ' DECODE(Assisted,''Y'',:l_YesLabel,:l_NoLabel) IBE_ATTR3, '||
		  ' OHEADER_ID IBE_VAL5 '||
                  ' FROM '||
		  ' ( '||
		    ' SELECT CUSTOMERID,'||
                    ' ORDERNUMBER,'||
		    ' SOURCE,'||
		    ' BOOKEDAMOUNT,'||
                    ' DISCOUNT,'||
		    ' LINES,'||
		    ' ASSISTED,'||
		    ' RANK,'||
		    ' OHEADER_ID'||
		    ' FROM '||
                    ' ( '||
                      ' SELECT FACT.CUSTOMERID,'||
		      ' FACT.ordernumber, '||
                      ' FACT.Source, '||
                      ' decode(:l_currency_code,:l_global_primary,fact.Booked_Amt_G,:l_global_secondary,fact.Booked_amt_G1,fact.currency_cd_f,fact.Booked_Amt_F) BookedAmount, '||
                      ' decode(:l_currency_code,:l_global_primary,fact.Discount_G,:l_global_secondary,fact.Discount_G1,fact.currency_cd_f,fact.Discount_F) Discount, '||
                      ' FACT.Lines, '||
                      ' FACT.Assisted , '||
                      ' RANK() OVER (ORDER BY decode(:l_currency_code,:l_global_primary,fact.Booked_Amt_G,:l_global_secondary,fact.Booked_Amt_G1,fact.currency_cd_f,fact.Booked_Amt_F) '||
		      ' DESC NULLS LAST) RANK, '||
		      ' ORD.HEADER_ID OHEADER_ID '||
                      ' FROM '||l_tableList||
                      ' WHERE  '||
                      ' CAL.calendar_id = -1'||
                      ' AND FACT.Time_Id = CAL.Time_Id'||
		      ' AND FACT.ORDERNUMBER = ORD.ORDER_NUMBER '||
                      ' AND FACT.Period_Type_id = CAL.Period_Type_Id'||
                      ' AND REPORT_DATE =  (:l_asof_date) '||
		      ' AND BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID '||l_msiteFilter||
                     ' ) FACT'||
		   ' WHERE FACT.RANK <= :l_rank) FACT1,'||
                  ' FII_CUSTOMERS_V CUST'||
                  ' WHERE FACT1.CustomerID = CUST.ID  )'||
		  ' &ORDER_BY_CLAUSE ' ; --Bug 5076452

		--  ' ORDER BY '||l_OrderBy;


  x_custom_sql  := l_custom_sql;


 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_orders_sql.query',l_custom_sql);
  END IF;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  x_custom_output.Extend(11);

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

  l_custom_rec.attribute_name := ':l_rank' ;
  l_custom_rec.attribute_value:= NVL(FND_PROFILE.VALUE('IBE_BI_TOP_ACT_NO_ROWS'),25);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_currency_code' ;
  l_custom_rec.attribute_value:= l_currency_code;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_QuoteLabel' ;
  l_custom_rec.attribute_value:= l_QuoteLabel;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_CartLabel' ;
  l_custom_rec.attribute_value:= l_CartLabel;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_YesLabel' ;
  l_custom_rec.attribute_value:= l_YesLabel;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_NoLabel' ;
  l_custom_rec.attribute_value:= l_NoLabel;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_primary' ;
  l_custom_rec.attribute_value:= l_global_primary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(10) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_secondary' ;
  l_custom_rec.attribute_value:= l_global_secondary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(11) := l_custom_rec;

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_orders_sql.end','END');
  END IF;

END GET_TOP_ORDERS_SQL;


PROCEDURE GET_TOP_CARTS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL ) IS
  CURSOR FND_CURSOR IS
  SELECT LOOKUP_TYPE,LOOKUP_CODE, MEANING
  FROM FND_LOOKUPS
  WHERE LOOKUP_TYPE IN ('YES_NO', 'IBE_BI_GENERIC')
  ORDER BY LOOKUP_TYPE, LOOKUP_CODE;

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
  l_YesLabel         VARCHAR2(300);
  l_NoLabel          VARCHAR2(300);
  l_OrderableLabel   VARCHAR2(300);
  l_ExpiredLabel     VARCHAR2(300);
  l_OrderBy          VARCHAR2(2000);
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
   l_fnd_rec            FND_CURSOR%ROWTYPE;
 dbg_msg           VARCHAR2(3200);
 l_global_primary    VARCHAR2(15);
 l_global_secondary  VARCHAR2(15);
BEGIN

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_carts_sql.begin','BEGIN');
    END IF;

 -- initilization of variables

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
    ELSIF ( l_parameter_name = 'ORDERBY')
    THEN
      l_OrderBy := p_pmv_parameters(i).parameter_value;
    END IF;
  END LOOP;

 FOR l_fnd_rec IN fnd_cursor LOOP

    IF l_fnd_rec.lookup_type = 'IBE_BI_GENERIC' AND l_fnd_rec.lookup_code ='ORDERABLE' THEN
      l_OrderableLabel := l_fnd_rec.meaning;
    ELSIF l_fnd_rec.lookup_type = 'IBE_BI_GENERIC' AND l_fnd_rec.lookup_code ='EXPIRED' THEN
      l_ExpiredLabel := l_fnd_rec.meaning;
    ELSIF l_fnd_rec.lookup_type = 'YES_NO' AND l_fnd_rec.lookup_code ='Y' THEN
      l_YesLabel := l_fnd_rec.meaning;
    ELSIF l_fnd_rec.lookup_type = 'YES_NO' AND l_fnd_rec.lookup_code ='N' THEN
      l_NoLabel := l_fnd_rec.meaning;
    END IF;

 END LOOP;



  l_record_type_id := IBE_BI_PMV_UTIL_PVT.GET_RECORD_TYPE_ID(l_period_type);


  l_prev_date :=  IBE_BI_PMV_UTIL_PVT.Get_Prev_Date(
                   p_asof_date        => l_asof_date,
                   p_period_type      => l_period_type,
                   p_comparison_type => l_comparison_type );


 dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_currency_code||
 ','||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||
 l_comparison_type||','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||
 l_minisite_id||','||'ORDER_BY:'||l_OrderBy||','||'LOOKUP_TYPE:'||
 l_fnd_rec.lookup_type||','||'ORDERABLE_LABEL:'||l_OrderableLabel||','||
 'EXPIRED_LABEL:'||l_ExpiredLabel||','||'YES_LABEL:'||l_YesLabel||','||
 'NO_LABEL:'||l_NoLabel||','||'RECORD_TYPE_ID:'||l_record_type_id||','||
 'PREV_DATE:'||l_prev_date;

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_carts_sql.parameters',dbg_msg);
	 END IF;

  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITES_V to IBW_BI_MSITE_DIMN_V.

  if (trim(l_minisite_id) is null) then
    l_tableList := ' IBE_BI_TOP_CART_MV FACT, '||
                  -- ' IBE_BI_MSITES_V MSITES, '||
                   ' IBW_BI_MSITE_DIMN_V MSITES, '||
                   ' FII_TIME_RPT_STRUCT_V CAL';

    l_msiteFilter :=' AND MSITES.ID = FACT.MINISITE_ID';

  else
    l_tableList := ' IBE_BI_TOP_CART_MV FACT,'||
                   ' FII_TIME_RPT_STRUCT_V CAL';

    l_msiteFilter := ' AND FACT.MINISITE_ID in (&SITE+SITE)';

   end if;

   /************************************************************************/
   /* IBE_VAL1          : Cart Number                                      */
   /* IBE_ATTR1         : Customer Name                                    */
   /* IBE_VAL2          : Cart Amount                                      */
   /* IBE_VAL3          : Number of Lines                                  */
   /* IBE_VAL4          : Age in Days                                      */
   /* IBE_ATTR3         : Assisted/Unassisted                              */
   /************************************************************************/

  l_custom_sql := 'SELECT IBE_VAL1, IBE_ATTR1, IBE_VAL2, IBE_VAL3,'||
                  ' IBE_ATTR2, IBE_VAL4, IBE_ATTR3 FROM ( '||
                  ' SELECT'||
                  ' CARTNUMBER IBE_VAL1,'||
                  ' CUST.VALUE IBE_ATTR1,'||
                  ' AMOUNT IBE_VAL2,'||
                  ' LINES IBE_VAL3,'||
                  ' STATUS IBE_ATTR2,'||
                  ' AGEINDAYS IBE_VAL4,'||
                  ' DECODE(ASSISTED,''Y'',:l_YesLabel,''N'',:l_NoLabel) IBE_ATTR3'||
                  ' FROM'||
		  ' ('||
		   ' SELECT CARTNUMBER,'||
                   ' CUSTOMER,'||
		   ' AMOUNT,'||
		   ' LINES,'||
		   ' STATUS,'||
		   ' AGEINDAYS,'||
		   ' ASSISTED,'||
		   ' RANK'||
		   ' FROM '||
                   ' ('||
                    ' SELECT '||
                    ' CARTNUMBER,'||
                    ' CUSTOMER, '||
                    ' decode(:l_currency_code,:l_global_primary,FACT.BOOKED_AMT_G,:l_global_secondary,FACT.BOOKED_AMT_G1,FACT.currency_cd_f, FACT.BOOKED_AMT_F) AMOUNT,'||
                    ' LINES,'||
                    ' decode(sign(FACT.QUOTE_EXPIRATION_DATE - trunc(SYSDATE)),-1,:l_ExpiredLabel,:l_OrderableLabel) Status,'||
                    ' decode(sign(FACT.QUOTE_EXPIRATION_DATE - trunc(SYSDATE)),-1,FACT.QUOTE_EXPIRATION_DATE-FACT.CREATION_DATE,'||
                    ' trunc(SYSDATE)-FACT.CREATION_DATE) AgeinDays,'||
                    ' FACT.RESOURCE_FLAG Assisted,'||
                    ' RANK() OVER (ORDER BY BOOKED_AMT_G DESC NULLS LAST) RANK'||
                    ' FROM '||l_tableList||
                    ' WHERE '||
                    ' CAL.calendar_id = -1'||
                    ' AND FACT.Time_Id = CAL.Time_Id'||
                    ' AND FACT.Period_Type_id = CAL.Period_Type_Id'||
                    ' AND REPORT_DATE = (:l_asof_date) '||
                    ' AND BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID '||l_msiteFilter||
                  ' ) FACT '||
		  ' WHERE RANK <= :l_rank ) FACT1,'||
		  ' FII_CUSTOMERS_V CUST'||
                  ' WHERE FACT1.CUSTOMER = CUST.ID )'||
		  ' &ORDER_BY_CLAUSE ' ;  --Bug 5076452

		--  ' ORDER BY '||l_OrderBy;


  x_custom_sql  := l_custom_sql;

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_carts_sql.query',l_custom_sql);
    END IF;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  x_custom_output.Extend(11);

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

  l_custom_rec.attribute_name := ':l_rank' ;
  l_custom_rec.attribute_value:=  NVL(FND_PROFILE.VALUE('IBE_BI_TOP_ACT_NO_ROWS'),25);

  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_currency_code' ;
  l_custom_rec.attribute_value:= l_currency_code;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(5) := l_custom_rec;

 l_custom_rec.attribute_name := ':l_ExpiredLabel' ;
  l_custom_rec.attribute_value:= l_ExpiredLabel;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_OrderableLabel' ;
  l_custom_rec.attribute_value:= l_OrderableLabel;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_YesLabel' ;
  l_custom_rec.attribute_value:= l_YesLabel;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_NoLabel' ;
  l_custom_rec.attribute_value:= l_NoLabel;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_primary' ;
  l_custom_rec.attribute_value:= l_global_primary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(10) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_secondary' ;
  l_custom_rec.attribute_value:= l_global_secondary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(11) := l_custom_rec;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_carts_sql.end','END');
  END IF;

END GET_TOP_CARTS_SQL;


PROCEDURE GET_TOP_CUSTOMERS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL ) IS
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
  l_OrderBy          VARCHAR2(2000);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;
  dbg_msg           VARCHAR2(3200);
  l_global_primary   VARCHAR2(15) ;
  l_global_secondary VARCHAR2(15) ;
BEGIN

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_customers_sql.begin','BEGIN');
  END IF;

 -- initilization of variables

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
    ELSIF ( l_parameter_name = 'ORDERBY')
    THEN
      l_OrderBy := p_pmv_parameters(i).parameter_value;
    END IF;
  END LOOP;


  l_record_type_id := IBE_BI_PMV_UTIL_PVT.GET_RECORD_TYPE_ID(l_period_type);

  l_prev_date :=  IBE_BI_PMV_UTIL_PVT.Get_Prev_Date(
                   p_asof_date        => l_asof_date,
                   p_period_type      => l_period_type,
                   p_comparison_type => l_comparison_type );


 dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_currency_code||
 ','||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||
 l_comparison_type||','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||
 l_minisite_id||','||'ORDER_BY:'||l_OrderBy||','||'RECORD_TYPE_ID:'||
 l_record_type_id||','||'PREV_DATE:'||l_prev_date;
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_customers_sql.parameters',dbg_msg);
	END IF;

  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITES_V to IBW_BI_MSITE_DIMN_V.

  if (trim(l_minisite_id) is null) then
    l_tableList := ' IBE_BI_TOP_CUST_MV MV,'||
                   --' IBE_BI_MSITES_V  MSITES,'||
                   ' IBW_BI_MSITE_DIMN_V  MSITES,'||
                   ' FII_TIME_RPT_STRUCT_V  cal';

    l_msiteFilter :=' AND MSITES.ID = MV.MINISITE_ID';

  else
    l_tableList := ' IBE_BI_TOP_CUST_MV MV,'||
                   ' FII_TIME_RPT_STRUCT_V  cal';

    l_msiteFilter := ' AND MV.MINISITE_ID in (&SITE+SITE)';

   end if;

   /************************************************************************/
   /* IBE_ATTR1         : Customer Name                                    */
   /* IBE_VAL1          : Booked Amount                                    */
   /* IBE_VAL2          : Percentage Change(Calculated in the AK Region)   */
   /* IBE_VAL7          : Prior Booked Amount                              */
   /* IBE_VAL3          : Assisted/Unassisted                              */
   /* IBE_VAL4          : Number of Orders                                 */
   /* IBE_VAL5          : Average Order Value                              */
   /* IBE_VAL6          : Discount Percentage                              */
   /************************************************************************/

   /*
   Changes done for Bug:4772549
   ' decode(P_AMOUNT,0,NULL,((C_AMOUNT-P_AMOUNT)/P_AMOUNT))*100 CHANGE,'||
   is changed to
   ' P_AMOUNT P_AMOUNT,'||
   */


  l_custom_sql := 'SELECT IBE_ATTR1, IBE_VAL1,'||
                  ' IBE_VAL7, IBE_VAL3,IBE_VAL4,IBE_VAL5, IBE_VAL6'||
                  ' FROM ( SELECT CUST.VALUE IBE_ATTR1,'||
                  ' MV.BOOKED_AMOUNT IBE_VAL1,'||
                  ' MV.P_AMOUNT IBE_VAL7, '||
                  ' MV.ASSISTED IBE_VAL3,'||
                  ' MV.NUM_OF_ORDERS IBE_VAL4,'||
                  ' to_number(MV.AVG_ORD_VAL) IBE_VAL5,'||
                  ' MV.DISCOUNT IBE_VAL6 '||
                  ' FROM ('||
                    ' SELECT CUSTOMER_ID,'||
                    ' C_AMOUNT BOOKED_AMOUNT,'||
                    ' P_AMOUNT P_AMOUNT,'||
                    ' decode(C_AMOUNT,0,NULL,(ASSISTED_AMOUNT/C_AMOUNT))*100 ASSISTED,'||
                    ' NUM_OF_ORDERS,'||
                    ' decode(NUM_OF_ORDERS,0,NULL,C_AMOUNT/NUM_OF_ORDERS) AVG_ORD_VAL,'||
                    ' decode(LIST_AMOUNT,0,NULL,(DISC_AMOUNT/LIST_AMOUNT))*100 DISCOUNT'||
                    ' FROM'||
                    ' ('||
                      ' SELECT MV.CUSTOMER_ID,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN'||
                      ' decode(:l_currency_code,:l_global_primary,AMOUNT_G,:l_global_secondary,AMOUNT_G1,CURRENCY_CD_F, AMOUNT_F) ELSE 0 END) C_AMOUNT,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_prev_date THEN'||
                      ' decode(:l_currency_code,:l_global_primary,AMOUNT_G,:l_global_secondary,AMOUNT_G1,CURRENCY_CD_F, AMOUNT_F) ELSE 0 END) P_AMOUNT,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN'||
                      ' decode(:l_currency_code,:l_global_primary,ASSISTED_AMT_G,:l_global_secondary,ASSISTED_AMT_G1, CURRENCY_CD_F,ASSISTED_AMT_F) ELSE 0 END) ASSISTED_AMOUNT,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN'||
                      ' ORDERS_CNT ELSE 0 END) NUM_OF_ORDERS,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN'||
                      ' decode(:l_currency_code,:l_global_primary,LIST_AMOUNT_G,:l_global_secondary,LIST_AMOUNT_G1,CURRENCY_CD_F, LIST_AMOUNT_F) ELSE 0 END) LIST_AMOUNT,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN'||
                      ' decode(:l_currency_code,:l_global_primary,DISC_AMOUNT_G,:l_global_secondary,DISC_AMOUNT_G1, CURRENCY_CD_F,DISC_AMOUNT_F) ELSE 0 END) DISC_AMOUNT,'||
                      ' RANK () OVER (ORDER BY SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN'||
                      ' decode(:l_currency_code,:l_global_primary,AMOUNT_G,:l_global_secondary,AMOUNT_G1,CURRENCY_CD_F, AMOUNT_F) ELSE 0 END) DESC) RANK'||
                      ' FROM '||l_tableList||
                      ' WHERE MV.TIME_ID = CAL.TIME_ID '||l_msiteFilter||
                      ' AND CAL.REPORT_DATE IN (:l_asof_date, :l_prev_date)'||
                      ' AND CAL.PERIOD_TYPE_ID = MV.PERIOD_TYPE_ID'||
                      ' AND BITAND(CAL.RECORD_TYPE_ID, :l_record_type_id) = CAL.RECORD_TYPE_ID'||
                      ' GROUP BY mv.CUSTOMER_ID'||
                    ' ) WHERE RANK <= :l_rank'||
                    ' ORDER BY RANK)  mv, FII_CUSTOMERS_V cust'||
                  ' WHERE MV.CUSTOMER_ID = CUST.ID ) '||
		   ' &ORDER_BY_CLAUSE ' ;   -- Bug 5076452

		  --'ORDER BY '||l_OrderBy;


  x_custom_sql  := l_custom_sql;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_customers_sql.query',l_custom_sql);
  END IF;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  x_custom_output.Extend(7);

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

  l_custom_rec.attribute_name := ':l_rank' ;
  l_custom_rec.attribute_value:=  NVL(FND_PROFILE.VALUE('IBE_BI_TOP_ACT_NO_ROWS'),25);

  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_currency_code' ;
  l_custom_rec.attribute_value:= l_currency_code;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_primary' ;
  l_custom_rec.attribute_value:= l_global_primary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_secondary' ;
  l_custom_rec.attribute_value:= l_global_secondary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(7) := l_custom_rec;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_customers_sql.end','END');
 END IF;

END GET_TOP_CUSTOMERS_SQL;


PROCEDURE GET_TOP_PRODUCTS_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL ) IS
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
  l_OrderBy          VARCHAR2(2000);
  l_custom_rec       BIS_QUERY_ATTRIBUTES ;
 dbg_msg           VARCHAR2(3200);
  l_global_primary   VARCHAR2(15) ;
  l_global_secondary VARCHAR2(15) ;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_products_sql.begin','BEGIN');
 END IF;

  -- initilization of variables

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
    ELSIF ( l_parameter_name = 'ORDERBY')
    THEN
      l_OrderBy := p_pmv_parameters(i).parameter_value;
    END IF;
  END LOOP;

  l_record_type_id := IBE_BI_PMV_UTIL_PVT.GET_RECORD_TYPE_ID(l_period_type);

  l_prev_date :=  IBE_BI_PMV_UTIL_PVT.Get_Prev_Date(
                   p_asof_date        => l_asof_date,
                   p_period_type      => l_period_type,
                   p_comparison_type => l_comparison_type );


 dbg_msg := 'AS_OF_DATE:'||l_asof_date||','||'CURR_CODE:'||l_currency_code||
 ','||'PERIOD_TYPE:'||l_period_type||','||'COMPARISION_TYPE:'||
 l_comparison_type||','||'MINISITE:'||l_minisite||','||'MINISITE_ID:'||
 l_minisite_id||','||'ORDER_BY:'||l_OrderBy||','||'RECORD_TYPE_ID:'||
 l_record_type_id||','||'PREV_DATE:'||l_prev_date;
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_products_sql.parameters',dbg_msg);
END IF;

  --Change in View done for Bug#:4654974. Issue#12 by narao
  --The Site Dimension now refers to IBW_BI_MSITE_DIMN_V
  --And hence the MSITES View is changed from IBE_BI_MSITES_V to IBW_BI_MSITE_DIMN_V.

  if (trim(l_minisite_id) is null) then
    l_tableList :=  ' IBE_BI_TOP_PROD_MV FACT,'||
                   -- ' IBE_BI_MSITES_V  MSITES,'||
                    ' IBW_BI_MSITE_DIMN_V  MSITES,'||
                    ' FII_TIME_RPT_STRUCT_V CAL';


    l_msiteFilter :=' AND MSITES.ID = FACT.MINISITE_ID';

  else
    l_tableList :=  ' IBE_BI_TOP_PROD_MV FACT,'||
                    ' FII_TIME_RPT_STRUCT_V CAL';

    l_msiteFilter := ' AND FACT.MINISITE_ID in (&SITE+SITE)';

   end if;

   /************************************************************************/
   /* IBE_ATTR1     : Product Code                                      */
   /* IBE_ATTR3     : Product Description                               */
   /* IBE_VAL1      : Percentage Conversion                             */
   /* IBE_VAL2      : Order Amount                                      */
   /* IBE_VAL3      : Percentage Change(Calculated now on the AK Region)*/
   /* IBE_VAL8      : Prior Order Amount                                */
   /* IBE_VAL4      : Percentage Assisted                               */
   /* IBE_VAL5      : Average Order Value                               */
   /* IBE_VAL6      : Average Discount                                  */
   /* IBE_VAL7      : Number of Lines                                   */
   /************************************************************************/
   /*
   Changes done for Bug:4772549
   ' decode(P_AMOUNT,0,NULL,((C_AMOUNT-P_AMOUNT)/P_AMOUNT))*100 IBE_VAL3,'||
    is changed to
   ' P_AMOUNT IBE_VAL8,'||
   */

  l_custom_sql := 'SELECT IBE_ATTR1, IBE_ATTR3, IBE_VAL1, IBE_VAL2, IBE_VAL8, IBE_VAL4, '||
                  ' IBE_VAL5, IBE_VAL6, IBE_VAL7 FROM ('||
                  ' SELECT VALUE IBE_ATTR1, DESCRIPTION IBE_ATTR3,'||
                  ' IBE_VAL1,IBE_VAL2,IBE_VAL8,IBE_VAL4,to_number(IBE_VAL5) IBE_VAL5,'||
                  ' IBE_VAL6,IBE_VAL7 FROM'||
                  ' ('||
                    ' SELECT'||
                    ' decode(TOTAL_CARTS,0,NULL,(TOTAL_CONV_CARTS/TOTAL_CARTS))*100 IBE_VAL1,'||
                    ' C_AMOUNT IBE_VAL2,'||
                    ' P_AMOUNT IBE_VAL8,'||
                    ' decode(C_AMOUNT,0,NULL,(ASSISTED_AMOUNT/C_AMOUNT))*100 IBE_VAL4,'||
                    ' decode(TOTAL_ORDERS,0,NULL,C_AMOUNT/TOTAL_ORDERS) IBE_VAL5,'||
                    ' decode(LIST_AMOUNT,0,NULL,(DISC_AMOUNT/LIST_AMOUNT))*100 IBE_VAL6,'||
                    ' NUM_OF_LINES IBE_VAL7,'||
                    ' ITEM_ID,'||
                    ' RANK'||
                    ' FROM'||
                    ' ('||
                      ' SELECT FACT.ITEM_ID,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN TOT_CART_COUNT ELSE 0 END) TOTAL_CARTS,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN CON_ORD ELSE 0 END) TOTAL_CONV_CARTS,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date '||
                      ' THEN decode(:l_currency_code,:l_global_primary,BOOKED_AMOUNT_G,:l_global_secondary,BOOKED_AMOUNT_G1,CURRENCY_CD_F, BOOKED_AMOUNT_F) ELSE 0 END) C_AMOUNT,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_prev_date  '||
                      ' THEN decode(:l_currency_code,:l_global_primary,BOOKED_AMOUNT_G,:l_global_secondary,BOOKED_AMOUNT_G1,CURRENCY_CD_F, BOOKED_AMOUNT_F) ELSE 0 END) P_AMOUNT,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN decode(RESOURCE_FLAG,''Y'','||
                      ' decode(:l_currency_code,:l_global_primary,BOOKED_AMOUNT_G,:l_global_secondary,BOOKED_AMOUNT_G1,CURRENCY_CD_F, BOOKED_AMOUNT_F),0) ELSE 0 END) ASSISTED_AMOUNT,	 '||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date THEN TOT_ORD_COUNT ELSE 0 END) TOTAL_ORDERS,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date '||
                      ' THEN decode(:l_currency_code,:l_global_primary,BOOKED_LIST_AMT_G,:l_global_secondary,BOOKED_LIST_AMT_G1,CURRENCY_CD_F, BOOKED_LIST_AMT_F) ELSE 0 END) LIST_AMOUNT,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date  '||
                      ' THEN decode(:l_currency_code,:l_global_primary,DISCOUNT_AMOUNT_G,:l_global_secondary,DISCOUNT_AMOUNT_G1, CURRENCY_CD_F,DISCOUNT_AMOUNT_F) ELSE 0 END) DISC_AMOUNT,'||
                      ' SUM(CASE WHEN REPORT_DATE = :l_asof_date '||
                      ' THEN NUM_OF_ORD_LINES ELSE 0 END) NUM_OF_LINES,'||
                      ' RANK() OVER(ORDER BY SUM(CASE WHEN REPORT_DATE = :l_asof_date'||
                      ' THEN decode(:l_currency_code,:l_global_primary,BOOKED_AMOUNT_G,:l_global_secondary,BOOKED_AMOUNT_G1,CURRENCY_CD_F, BOOKED_AMOUNT_F) ELSE 0 END) DESC) RANK '||
                      ' FROM '|| l_tableList ||
                      ' WHERE CAL.calendar_id = -1'||
                      ' AND FACT.Time_Id = CAL.Time_Id'||
                      ' AND FACT.Period_Type_id = CAL.Period_Type_Id '||l_msiteFilter||
                      ' AND REPORT_DATE IN (:l_asof_date,:l_prev_date)'||
                      ' AND BITAND(CAL.Record_Type_Id, :l_record_type_id) = CAL.Record_Type_Id'||
                      ' GROUP BY '||
                      ' FACT.ITEM_ID'||
                    ' ) WHERE RANK <= :l_rank'||
                  ' ) FACT ,ENI_ITEM_V ENI'||
                  ' WHERE '||
                  ' FACT.ITEM_ID = ENI.ID)'||
		   ' &ORDER_BY_CLAUSE ' ;   --Bug 5076452

		  --' ORDER BY '||l_orderBy;


  x_custom_sql  := l_custom_sql;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_products_sql.query',l_custom_sql);
  END IF;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  x_custom_output.Extend(7);

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

  l_custom_rec.attribute_name := ':l_rank' ;
  l_custom_rec.attribute_value:=  NVL(FND_PROFILE.VALUE('IBE_BI_TOP_ACT_NO_ROWS'),25);

  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;

  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_currency_code' ;
  l_custom_rec.attribute_value:= l_currency_code;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_primary' ;
  l_custom_rec.attribute_value:= l_global_primary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_global_secondary' ;
  l_custom_rec.attribute_value:= l_global_secondary;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

  x_custom_output(7) := l_custom_rec;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_top_act_pvt.get_top_products_sql.end','END');
  END IF;

END GET_TOP_PRODUCTS_SQL;

END IBE_BI_TOP_ACT_PVT;

/
