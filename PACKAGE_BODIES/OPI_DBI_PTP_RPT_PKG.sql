--------------------------------------------------------
--  DDL for Package Body OPI_DBI_PTP_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_PTP_RPT_PKG" AS
/* $Header: OPIDRPTPB.pls 120.0 2005/05/24 17:55:10 appldev noship $ */

PROCEDURE GET_TBL_SQL(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS
  l_formula_sql		VARCHAR2(4000) := '';
  l_inner_sql		VARCHAR2(8000) := '';
  l_stmt 		VARCHAR2(10240) := '';
  l_period_type         VARCHAR2(255)  := NULL;
  l_view_by		VARCHAR2(255)  := NULL;
  l_org 		VARCHAR2(255)  := NULL;
  l_org_where     	VARCHAR2(2000) := ' 1=1';
  l_org_security        VARCHAR2(2000) := ' AND 1=1';
  l_item		VARCHAR2(255)  := NULL;
  l_item_where		VARCHAR2(2000) := ' AND 1=1';
  l_inv_cat		VARCHAR2(255)  := NULL;
  l_inv_cat_where	VARCHAR2(2000) := ' AND 1=1';
  l_item_cat_flag	NUMBER; -- 0 for item and 1 for inv. category
  l_currency            VARCHAR2(30) := '';
  l_currency_code       VARCHAR2(2) := 'B';
  l_lang_code           VARCHAR2(20) := NULL;
  l_custom_rec 		BIS_QUERY_ATTRIBUTES;
  l_curr_asof_date      DATE;
  l_prev_asof_date      DATE;
  l_nested_pattern      NUMBER;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN  l_period_type := p_param(i).parameter_value;
    END IF;

    IF( p_param(i).parameter_name= 'VIEW_BY')
      THEN l_view_by := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org :=  p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
       IF ( p_param(i).parameter_value IS NULL OR p_param(i).parameter_value = 'All' ) THEN
         l_inv_cat :=  p_param(i).parameter_value;
       ELSE
         l_inv_cat := 'Selected';
       END IF;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
       IF ( p_param(i).parameter_value IS NULL OR p_param(i).parameter_value = 'All' ) THEN
         l_item :=  p_param(i).parameter_value;
       ELSE
         l_item := 'Selected';
       END IF;
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
       l_currency := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'AS_OF_DATE') then
       l_curr_asof_date := p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'BIS_P_ASOF_DATE') then
       l_prev_asof_date := p_param(i).period_date;
    END IF;
  END LOOP;

  IF(l_currency = '''FII_GLOBAL1''') then
        l_currency_code := 'G';
  ELSIF (l_currency = '''FII_GLOBAL2''') then
        l_currency_code := 'SG';
  END IF;

  l_lang_code := USERENV('LANG');

  IF ( l_org IS NULL OR l_org = 'All' ) THEN
    l_org_security := '
	    AND (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = f.organization_id)
		OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = f.organization_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';

  ELSE
    --do we allow mutliple selects of org here?
    --l_org_where := ' AND f.organization_id = &ORGANIZATION+ORGANIZATION';
    l_org_where := ' f.organization_id = '||l_org;
  END IF;

  IF ( l_inv_cat IS NULL OR l_inv_cat = 'All' ) THEN
    l_inv_cat_where :='';
  ELSE
    l_inv_cat_where := ' AND f.inv_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF ( l_item IS NULL OR l_item = 'All' ) THEN
    l_item_where :='';
  ELSE
    l_item_where := ' AND f.item_org_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_item IS NULL OR l_item = 'All') THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_ORG') THEN
	l_item_cat_flag := 0; -- item
      ELSIF (l_view_by = 'ITEM+ENI_ITEM_INV_CAT') THEN
	l_item_cat_flag := 1; -- category
      ELSE
	IF (l_inv_cat IS NULL OR l_inv_cat = 'All') THEN
	  l_item_cat_flag := 3; -- all
	ELSE
	  l_item_cat_flag := 1; -- category
	END IF;
      END IF;
  ELSE
    l_item_cat_flag := 0; -- item
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_formula_sql :='CURR_PLANNED_QUANTITY OPI_MEASURE1,
                   PREV_PLANNED_STANDARD_VALUE OPI_MEASURE2,
                   CURR_PLANNED_STANDARD_VALUE OPI_MEASURE3,
                   CURR_ACTUAL_QUANTITY OPI_MEASURE4,
                   PREV_ACTUAL_STANDARD_VALUE OPI_MEASURE5,
                   CURR_ACTUAL_STANDARD_VALUE OPI_MEASURE6,
                   PREV_ACTUAL_STANDARD_VALUE/decode(PREV_PLANNED_STANDARD_VALUE, 0, null, PREV_PLANNED_STANDARD_VALUE)*100 OPI_MEASURE7,
                   CURR_ACTUAL_STANDARD_VALUE/decode(CURR_PLANNED_STANDARD_VALUE, 0, null, CURR_PLANNED_STANDARD_VALUE)*100 OPI_MEASURE8,
                   (CURR_ACTUAL_STANDARD_VALUE/decode(CURR_PLANNED_STANDARD_VALUE, 0, null, CURR_PLANNED_STANDARD_VALUE) -
                   PREV_ACTUAL_STANDARD_VALUE/decode(PREV_PLANNED_STANDARD_VALUE, 0, null, PREV_PLANNED_STANDARD_VALUE))*100 OPI_MEASURE9,
                   PREV_ACTUAL_VALUE OPI_MEASURE10,
                   CURR_ACTUAL_VALUE OPI_MEASURE11,
                   (CURR_ACTUAL_VALUE - PREV_ACTUAL_VALUE)/decode(PREV_ACTUAL_VALUE, 0, null, abs(PREV_ACTUAL_VALUE))*100 OPI_MEASURE13,
                   SUM(CURR_PLANNED_STANDARD_VALUE) OVER () OPI_MEASURE14,
                   SUM(CURR_ACTUAL_STANDARD_VALUE) OVER() OPI_MEASURE15,
                   SUM(CURR_ACTUAL_STANDARD_VALUE) OVER ()/decode(SUM(CURR_PLANNED_STANDARD_VALUE) OVER (), 0, null, SUM(CURR_PLANNED_STANDARD_VALUE) OVER ())*100 OPI_MEASURE16,
                   (SUM(CURR_ACTUAL_STANDARD_VALUE) OVER ()/decode(SUM(CURR_PLANNED_STANDARD_VALUE) OVER (), 0, null, SUM(CURR_PLANNED_STANDARD_VALUE) OVER ()) -
                   SUM(PREV_ACTUAL_STANDARD_VALUE) OVER ()/decode(SUM(PREV_PLANNED_STANDARD_VALUE) OVER (), 0, null, SUM(PREV_PLANNED_STANDARD_VALUE) OVER ()))*100 OPI_MEASURE17,
                   SUM(CURR_ACTUAL_VALUE) OVER () OPI_MEASURE18,
                   (SUM(CURR_ACTUAL_VALUE) OVER () - SUM(PREV_ACTUAL_VALUE) OVER ())/decode(SUM(PREV_ACTUAL_VALUE) OVER (), 0, null, abs(SUM(PREV_ACTUAL_VALUE) OVER ()))*100 OPI_MEASURE19,
                   CURR_ACTUAL_STANDARD_VALUE/decode(CURR_PLANNED_STANDARD_VALUE, 0, null, CURR_PLANNED_STANDARD_VALUE)*100 OPI_MEASURE20,
                   PREV_ACTUAL_STANDARD_VALUE/decode(PREV_PLANNED_STANDARD_VALUE, 0, null, PREV_PLANNED_STANDARD_VALUE)*100 OPI_MEASURE21,
                   SUM(CURR_ACTUAL_STANDARD_VALUE) OVER ()/decode(SUM(CURR_PLANNED_STANDARD_VALUE) OVER (), 0, null, SUM(CURR_PLANNED_STANDARD_VALUE) OVER ())*100 OPI_MEASURE22,
                   SUM(PREV_ACTUAL_STANDARD_VALUE) OVER ()/decode(SUM(PREV_PLANNED_STANDARD_VALUE) OVER (), 0, null, SUM(PREV_PLANNED_STANDARD_VALUE) OVER ())*100 OPI_MEASURE23,
                   CURR_ACTUAL_VALUE OPI_MEASURE25,
                   PREV_ACTUAL_VALUE OPI_MEASURE26,
                   SUM(CURR_ACTUAL_VALUE) OVER () OPI_MEASURE28,
                   SUM(PREV_ACTUAL_VALUE) OVER () OPI_MEASURE29
';

  l_inner_sql:='sum(decode(sign(report_date - &BIS_CURRENT_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.curr_asof_date, f.PLANNED_QUANTITY, 0))) CURR_PLANNED_QUANTITY,
                sum(decode(sign(report_date - &BIS_PREVIOUS_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.prev_asof_date, f.PLANNED_QUANTITY, 0))) PREV_PLANNED_QUANTITY,
                sum(decode(sign(report_date - &BIS_CURRENT_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.curr_asof_date, f.PLANNED_STANDARD_VALUE, 0))) CURR_PLANNED_STANDARD_VALUE,
                sum(decode(sign(report_date - &BIS_PREVIOUS_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.prev_asof_date, f.PLANNED_STANDARD_VALUE, 0))) PREV_PLANNED_STANDARD_VALUE,
                sum(decode(sign(report_date - &BIS_CURRENT_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.curr_asof_date, f.ACTUAL_QUANTITY, 0))) CURR_ACTUAL_QUANTITY,
                sum(decode(sign(report_date - &BIS_PREVIOUS_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.prev_asof_date, f.ACTUAL_QUANTITY, 0))) PREV_ACTUAL_QUANTITY,
                sum(decode(sign(report_date - &BIS_CURRENT_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.curr_asof_date, f.ACTUAL_STANDARD_VALUE, 0))) CURR_ACTUAL_STANDARD_VALUE,
                sum(decode(sign(report_date - &BIS_PREVIOUS_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.prev_asof_date, f.ACTUAL_STANDARD_VALUE, 0))) PREV_ACTUAL_STANDARD_VALUE,
                sum(decode(sign(report_date - &BIS_CURRENT_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.curr_asof_date, f.ACTUAL_VALUE, 0))) CURR_ACTUAL_VALUE,
                sum(decode(sign(report_date - &BIS_PREVIOUS_EFFECTIVE_START_DATE), -1, 0, decode(c.report_date, c.prev_asof_date, f.ACTUAL_VALUE, 0))) PREV_ACTUAL_VALUE
                FROM
                (select
                        f.ORGANIZATION_ID,
                        f.INVENTORY_ITEM_ID,
                        f.INV_CATEGORY_ID,
                        f.ITEM_ORG_ID,
                        f.UOM_CODE,
                        f.TIME_ID,
                        f.PERIOD_TYPE_ID,
                        0 ACTUAL_QUANTITY,
                        0 ACTUAL_VALUE,
                        f.ACTUAL_STANDARD_VALUE_'||l_currency_code||' ACTUAL_STANDARD_VALUE,
                        f.PLANNED_QUANTITY,
                        f.PLANNED_STANDARD_VALUE_'||l_currency_code||' PLANNED_STANDARD_VALUE
                 from   OPI_PTP_SUM_F_MV f
                 where
                        f.item_cat_flag = :OPI_ITEM_CAT_FLAG
	       '||l_inv_cat_where||l_item_where||
               ' union all
                 select
                        f.ORGANIZATION_ID,
                        f.INVENTORY_ITEM_ID,
                        f.INV_CATEGORY_ID,
                        f.ITEM_ORG_ID,
                        f.UOM_CODE,
                        f.TIME_ID,
                        f.PERIOD_TYPE_ID,
                        0 ACTUAL_QUANTITY,
                        0 ACTUAL_VALUE,
                        0 ACTUAL_STANDARD_VALUE,
                        f.PLANNED_QUANTITY,
                        f.PLANNED_STANDARD_VALUE_'||l_currency_code||' PLANNED_STANDARD_VALUE
                 from   OPI_PTP_SUM_STG_MV f
                 where
                        f.item_cat_flag = :OPI_ITEM_CAT_FLAG
               '||l_inv_cat_where||l_item_where||
               ' union all
                 select
                        f.ORGANIZATION_ID,
                        f.INVENTORY_ITEM_ID,
                        f.INV_CATEGORY_ID,
                        f.ITEM_ORG_ID,
                        f.UOM_CODE,
                        f.TIME_ID,
                        f.PERIOD_TYPE_ID,
                        nvl(f.PRODUCTION_QTY, 0) - nvl(f.SCRAP_QTY, 0) ACTUAL_QUANTITY,
                        nvl(f.PRODUCTION_VAL_'||l_currency_code||', 0) - nvl(f.SCRAP_VAL_'||l_currency_code||', 0) ACTUAL_VALUE,
                        0 ACTUAL_STANDARD_VALUE,
                        0 PLANNED_QUANTITY,
                        0 PLANNED_STANDARD_VALUE
                 from   OPI_SCRAP_SUM_MV f
                 where
                        f.item_cat_flag = :OPI_ITEM_CAT_FLAG
               '||l_inv_cat_where||l_item_where||
               ') f,
                OPI_DBI_PTP_TBL_TMP c
                WHERE   f.organization_id = c.organization_id
                  AND   f.time_id = c.time_id
                  AND   c.period_type_id = f.period_type_id '
               ;

  IF l_view_by = 'ITEM+ENI_ITEM_INV_CAT' THEN
    l_stmt := '	SELECT eni.value         	VIEWBY,
                fact.inv_category_id            VIEWBYID,
		eni.value                 	OPI_ATTRIBUTE1,
		null				OPI_ATTRIBUTE2,
		null				OPI_ATTRIBUTE3,
		null	                        OPI_ATTRIBUTE6,
		'||l_formula_sql||'
		FROM (SELECT /*+ push_pred(f) leading(c) */ f.inv_category_id,
		'||l_inner_sql||'
		group by f.inv_category_id) fact,
		ENI_ITEM_INV_CAT_V 	eni
		WHERE fact.inv_category_id = eni.id (+)
		&ORDER_BY_CLAUSE NULLS LAST';

  ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
     l_stmt := 'SELECT org.name 		VIEWBY,
		org.name			OPI_ATTRIBUTE1,
		null				OPI_ATTRIBUTE2,
		null				OPI_ATTRIBUTE3,
		null				OPI_ATTRIBUTE6,
	   	'||l_formula_sql||'
		FROM (SELECT /*+ push_pred(f) leading(c) */ f.organization_id,
		'||l_inner_sql||'
		group by f.organization_id) fact,
		HR_ALL_ORGANIZATION_UNITS_TL org
		WHERE org.organization_id = fact.organization_id
		AND org.language = :OPI_LANG_CODE
		&ORDER_BY_CLAUSE NULLS LAST' ;

  ELSE --l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
     l_stmt := 'SELECT items.value      	VIEWBY,
                items.id                        VIEWBYID,
		items.value               	OPI_ATTRIBUTE1,
		items.description		OPI_ATTRIBUTE2,
		uom.unit_of_measure		OPI_ATTRIBUTE3,';
		 IF((l_period_type = 'FII_TIME_WEEK' OR l_period_type =
                                    'FII_TIME_ENT_PERIOD') AND (UPPER(l_org)<>'ALL')) THEN
	            l_stmt := l_stmt || ' ''pFunctionName=OPI_DBI_PTP_JOB_DTL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y''  OPI_ATTRIBUTE6 ,';
                 ELSE
                    l_stmt := l_stmt || 'NULL  OPI_ATTRIBUTE6 ,';
                 END IF;
     l_stmt := l_stmt
		||l_formula_sql||'
		FROM (SELECT /*+ push_pred(f) leading(c) */ f.item_org_id, f.uom_code,
		'||l_inner_sql||'
		group by f.item_org_id,f.uom_code) fact,
		 ENI_ITEM_ORG_V 	items,
		 MTL_UNITS_OF_MEASURE_VL uom
  		WHERE  fact.item_org_id = items.id
		AND uom.uom_code = fact.uom_code
                AND uom.language = :OPI_LANG_CODE
		&ORDER_BY_CLAUSE NULLS LAST';
  END IF;

  BEGIN
   execute immediate '
    CREATE GLOBAL TEMPORARY TABLE OPI_DBI_PTP_TBL_TMP(
      organization_id number,
      time_id number,
      report_date date,
      curr_asof_date date,
      prev_asof_date date,
      period_type_id number
    ) ON COMMIT PRESERVE ROWS'
  ;
  EXCEPTION
  WHEN others THEN  null;
    execute immediate 'truncate table opi_dbi_ptp_tbl_tmp';
  END;
  BEGIN
  if(l_period_type = 'FII_TIME_ENT_YEAR') then
    l_nested_pattern := 119;
  elsif(l_period_type = 'FII_TIME_ENT_QTR') then
    l_nested_pattern := 55;
  elsif(l_period_type = 'FII_TIME_ENT_PERIOD') then
    l_nested_pattern := 23;
  elsif(l_period_type = 'FII_TIME_WEEK') then
    l_nested_pattern := 11;
  elsif(l_period_type = 'FII_TIME_DAY') then
    l_nested_pattern := 1;
  else
    l_nested_pattern := 119;
  end if;
  execute immediate '
  insert into OPI_DBI_PTP_TBL_TMP
      (organization_id,
      time_id,
      report_date,
      curr_asof_date,
      prev_asof_date,
      period_type_id
      )
  select
        bnd.organization_id,
        cal.time_id,
        cal.report_date,
        bnd.curr_asof_date,
        bnd.prev_asof_date,
        cal.period_type_id
   from
        FII_TIME_RPT_STRUCT_V cal,
        (select
              organization_id,
              decode(data_clean_date, NULL, :l_curr_asof_date, decode(sign(:l_curr_asof_date - data_clean_date), 1, data_clean_date, :l_curr_asof_date)) curr_asof_date,
              decode(data_clean_date, NULL, :l_prev_asof_date, decode(sign(:l_prev_asof_date - data_clean_date), 1, data_clean_date, :l_prev_asof_date)) prev_asof_date
         from
              opi_ptp_rpt_bnd_mv f
         where '||l_org_where||l_org_security||'
         ) bnd
   where  cal.report_date in (bnd.curr_asof_date, bnd.prev_asof_date)
     AND  bitand(cal.record_type_id, :l_nested_parttern) = cal.record_type_id
  '
  using l_curr_asof_date, l_curr_asof_date, l_curr_asof_date, l_prev_asof_date, l_prev_asof_date, l_prev_asof_date, l_nested_pattern;
  EXCEPTION
  WHEN others THEN null;
  END;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':OPI_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':OPI_LANG_CODE';
  l_custom_rec.attribute_value := l_lang_code;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

END GET_TBL_SQL;

PROCEDURE GET_TRD_SQL(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

  l_formula_sql		VARCHAR2(4000) := '';
  l_inner_sql		VARCHAR2(6000) := '';
  l_stmt 		VARCHAR2(10240):= '';
  l_period_type		VARCHAR2(255)  := NULL;
  l_org 		VARCHAR2(255)  := NULL;
  l_org_where     	VARCHAR2(2000) := ' AND 1=1';
  l_org_security        VARCHAR2(2000) := '1=1';
  l_item		VARCHAR2(255)  := NULL;
  l_item_where		VARCHAR2(2000) := ' AND 1=1';
  l_inv_cat		VARCHAR2(255)  := NULL;
  l_inv_cat_where	VARCHAR2(2000) := ' AND 1=1';
  l_item_cat_flag	NUMBER; -- 0 for item and 1 for inv. category
  l_currency            VARCHAR2(30) := '';
  l_currency_code       VARCHAR2(2) := 'B';
  l_nested_pattern      NUMBER;
  l_period_id           VARCHAR2(20);
  l_custom_rec 		BIS_QUERY_ATTRIBUTES;
  l_curr_asof_date      DATE;
  l_prev_asof_date      DATE;
  l_curr_rpt_start_date DATE;
  l_prev_rpt_start_date DATE;
BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN  l_period_type := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
       IF ( p_param(i).parameter_value IS NULL OR p_param(i).parameter_value = 'All' ) THEN
         l_inv_cat :=  p_param(i).parameter_value;
       ELSE
         l_inv_cat := 'Selected';
       END IF;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
       IF ( p_param(i).parameter_value IS NULL OR p_param(i).parameter_value = 'All' ) THEN
         l_item :=  p_param(i).parameter_value;
       ELSE
         l_item := 'Selected';
       END IF;
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
       l_currency := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'AS_OF_DATE') then
       l_curr_asof_date := p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'BIS_P_ASOF_DATE') then
       l_prev_asof_date := p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'BIS_CURRENT_REPORT_START_DATE') then
       l_curr_rpt_start_date := p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'BIS_PREVIOUS_REPORT_START_DATE') then
       l_prev_rpt_start_date := p_param(i).period_date;
    END IF;

  END LOOP;

  /* Use Global or Functional Currency */
  IF(l_currency = '''FII_GLOBAL1''') then
        l_currency_code := 'G';
  ELSIF (l_currency = '''FII_GLOBAL2''') then
        l_currency_code := 'SG';
  END IF;


  /* Security */
  IF ( l_org IS NULL OR l_org = 'All' ) THEN
    l_org_security := '
	    (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = f.organization_id)
		OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = f.organization_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';

  ELSE
    --do we allow mutliple selects of org here?
    l_org_where := ' AND f.organization_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF ( l_inv_cat IS NULL OR l_inv_cat = 'All' ) THEN
    l_inv_cat_where :='';
  ELSE
    l_inv_cat_where := ' AND f.inv_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF ( l_item IS NULL OR l_item = 'All' ) THEN
    l_item_where :='';
  ELSE
    l_item_where := ' AND f.item_org_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF((l_inv_cat IS NULL OR l_inv_cat = 'All' ) AND ( l_item IS NULL OR l_item = 'All')) THEN
    l_item_cat_flag := 3;  -- no grouping on item dimension
  ELSE
    IF (l_item IS NULL OR l_item = 'All') THEN
      l_item_cat_flag := 1; -- inv, category
    ELSE
      l_item_cat_flag := 0; -- item is needed
    END IF;
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_stmt :=
  'SELECT
           fii.NAME VIEWBY,
           fii.NAME OPI_ATTRIBUTE1,
	   PREV_PLANNED_STANDARD_VALUE OPI_MEASURE2,
	   CURR_PLANNED_STANDARD_VALUE OPI_MEASURE3,
	   PREV_ACTUAL_STANDARD_VALUE OPI_MEASURE4,
	   CURR_ACTUAL_STANDARD_VALUE OPI_MEASURE5,
	   PREV_ACTUAL_STANDARD_VALUE/decode(PREV_PLANNED_STANDARD_VALUE, 0,
	   null, PREV_PLANNED_STANDARD_VALUE)*100 OPI_MEASURE6,
  	   CURR_ACTUAL_STANDARD_VALUE/decode(CURR_PLANNED_STANDARD_VALUE, 0,
	   null, CURR_PLANNED_STANDARD_VALUE)*100 OPI_MEASURE7,
	   (CURR_ACTUAL_STANDARD_VALUE/decode(CURR_PLANNED_STANDARD_VALUE, 0,
	   null, CURR_PLANNED_STANDARD_VALUE) -
           PREV_ACTUAL_STANDARD_VALUE/decode(PREV_PLANNED_STANDARD_VALUE, 0,
	   null, PREV_PLANNED_STANDARD_VALUE))*100 OPI_MEASURE8,
	   PREV_ACTUAL_VALUE OPI_MEASURE9,
	   CURR_ACTUAL_VALUE OPI_MEASURE10,
	   (CURR_ACTUAL_VALUE - PREV_ACTUAL_VALUE)/
	   decode(PREV_ACTUAL_VALUE, 0, null,
	   abs(PREV_ACTUAL_VALUE))*100 OPI_MEASURE11
  FROM      (SELECT /*+ leading(cal) push_pred(fact) */
                    cal.start_date START_DATE,
   		    sum(CASE WHEN cal.curr_day < bnd.DATA_CLEAN_DATE then
        	    	decode(cal.report_date, cal.curr_day,nvl(
			fact.PLANNED_STANDARD_VALUE,0),0)
        		else 0
        		end) +
                    sum(CASE WHEN cal.curr_day = bnd.DATA_CLEAN_DATE then
        	    	decode(cal.report_date, cal.curr_day,nvl(
			fact.PLANNED_STANDARD_VALUE,0)/2,0)
        		else 0
        		end) +
   		    sum(CASE WHEN (cal.curr_day > bnd.DATA_CLEAN_DATE) and
        		(cal.start_date <= bnd.DATA_CLEAN_DATE) then
        		decode(cal.report_date, bnd.DATA_CLEAN_DATE,
			nvl(fact.PLANNED_STANDARD_VALUE,0),0)
        		else 0
        		end)    				CURR_PLANNED_STANDARD_VALUE,
  		    sum(decode(cal.report_date, cal.prev_day,
			nvl(fact.PLANNED_STANDARD_VALUE,0), 0)) PREV_PLANNED_STANDARD_VALUE,
   		    sum(CASE WHEN cal.curr_day < bnd.DATA_CLEAN_DATE then
        	    	decode(cal.report_date, cal.curr_day,nvl(
			fact.ACTUAL_STANDARD_VALUE,0),0)
        		else 0
        		end) +
                    sum(CASE WHEN cal.curr_day = bnd.DATA_CLEAN_DATE then
        	    	decode(cal.report_date, cal.curr_day,nvl(
			fact.ACTUAL_STANDARD_VALUE,0)/2,0)
        		else 0
        		end) +
   		    sum(CASE WHEN (cal.curr_day > bnd.DATA_CLEAN_DATE) and
        		(cal.start_date <= bnd.DATA_CLEAN_DATE) then
        		decode(cal.report_date, bnd.DATA_CLEAN_DATE,
			nvl(fact.ACTUAL_STANDARD_VALUE,0),0)
        		else 0
        		end)    				CURR_ACTUAL_STANDARD_VALUE,
  		    sum(decode(cal.report_date, cal.prev_day,
			nvl(fact.ACTUAL_STANDARD_VALUE,0), 0)) PREV_ACTUAL_STANDARD_VALUE,
   		    sum(CASE WHEN cal.curr_day < bnd.DATA_CLEAN_DATE then
        	    	decode(cal.report_date, cal.curr_day,nvl(
			fact.ACTUAL_VALUE,0),0)
        		else 0
        		end) +
                    sum(CASE WHEN cal.curr_day = bnd.DATA_CLEAN_DATE then
        	    	decode(cal.report_date, cal.curr_day,nvl(
			fact.ACTUAL_VALUE,0)/2,0)
        		else 0
        		end) +
   		    sum(CASE WHEN (cal.curr_day > bnd.DATA_CLEAN_DATE) and
        		(cal.start_date <= bnd.DATA_CLEAN_DATE) then
        		decode(cal.report_date, bnd.DATA_CLEAN_DATE,
			nvl(fact.ACTUAL_VALUE,0),0)
        		else 0
        		end)    				CURR_ACTUAL_VALUE,
  		    sum(decode(cal.report_date, cal.prev_day,
			nvl(fact.ACTUAL_VALUE,0), 0))  		PREV_ACTUAL_VALUE
  		FROM (select /*+ no_merge */
                        dates.start_date,
                        dates.name,
                        tmp.organization_id,
                        dates.curr_day,
                        dates.prev_day,
                        tmp.report_date,
                        tmp.time_id,
                        tmp.period_type_id
                      from
                      (SELECT curr.start_date START_DATE,
			curr.name NAME,
     			curr.day CURR_DAY,
     			prev.day PREV_DAY
    		      FROM (SELECT fii.start_date   START_DATE,
				fii.NAME NAME,
      				least(fii.end_date, &BIS_CURRENT_ASOF_DATE) DAY,
      				rownum    ID
      			    FROM '||l_period_type||' fii
      			    WHERE fii.start_date BETWEEN
			    &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
			    ORDER BY fii.start_date DESC) curr,
     		     	    (SELECT least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE) DAY,
      				rownum    ID
      			    FROM '||l_period_type||' fii
      			    WHERE fii.start_date BETWEEN
			    &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
			    ORDER BY fii.start_date DESC) prev
     			WHERE curr.id = prev.id(+))   dates,
                        OPI_DBI_PTP_TRD_TMP tmp
                        where decode(tmp.organization_id, -1, tmp.report_date, dates.curr_day) in (dates.curr_day, dates.prev_day)) cal,
		(select ORGANIZATION_ID,
			INVENTORY_ITEM_ID,
			INV_CATEGORY_ID,
			UOM_CODE,
			TIME_ID,
			PERIOD_TYPE_ID,
			ACTUAL_QUANTITY,
			ACTUAL_VALUE,
			ACTUAL_STANDARD_VALUE,
			PLANNED_QUANTITY,
			PLANNED_STANDARD_VALUE
		from
                (select
                        f.ORGANIZATION_ID,
                        f.INVENTORY_ITEM_ID,
                        f.INV_CATEGORY_ID,
                        f.UOM_CODE,
                        f.TIME_ID,
                        f.PERIOD_TYPE_ID,
                        0 ACTUAL_QUANTITY,
                        0 ACTUAL_VALUE,
                        f.ACTUAL_STANDARD_VALUE_'||l_currency_code||'  ACTUAL_STANDARD_VALUE,
                        f.PLANNED_QUANTITY,
                        f.PLANNED_STANDARD_VALUE_'||l_currency_code||'  PLANNED_STANDARD_VALUE
                 from   OPI_PTP_SUM_F_MV f
                 where
                        f.item_cat_flag = :OPI_ITEM_CAT_FLAG
               '||l_org_where||l_inv_cat_where||l_item_where||'
                 union all
                 select
                        f.ORGANIZATION_ID,
                        f.INVENTORY_ITEM_ID,
                        f.INV_CATEGORY_ID,
                        f.UOM_CODE,
                        f.TIME_ID,
                        f.PERIOD_TYPE_ID,
                        0 ACTUAL_QUANTITY,
                        0 ACTUAL_VALUE,
                        0 ACTUAL_STANDARD_VALUE,
                        f.PLANNED_QUANTITY,
                        f.PLANNED_STANDARD_VALUE_'||l_currency_code||'  PLANNED_STANDARD_VALUE
                 from   OPI_PTP_SUM_STG_MV f where
                        f.item_cat_flag = :OPI_ITEM_CAT_FLAG
               '||l_org_where||l_inv_cat_where||l_item_where||'
                union all
                 select
                        f.ORGANIZATION_ID,
                        f.INVENTORY_ITEM_ID,
                        f.INV_CATEGORY_ID,
                        f.UOM_CODE,
                        f.TIME_ID,
                        f.PERIOD_TYPE_ID,
                        nvl(f.PRODUCTION_QTY, 0) - nvl(f.SCRAP_QTY, 0) ACTUAL_QUANTITY,
                        nvl(f.PRODUCTION_VAL_'||l_currency_code||' , 0)
			- nvl(f.SCRAP_VAL_'||l_currency_code||'  , 0) ACTUAL_VALUE,
                        0 ACTUAL_STANDARD_VALUE,
                        0 PLANNED_QUANTITY,
                        0 PLANNED_STANDARD_VALUE
                 from   OPI_SCRAP_SUM_MV /*OPI_SCR_NEST_MV*/ f
                 where
                        f.item_cat_flag = :OPI_ITEM_CAT_FLAG
               '||l_org_where||l_inv_cat_where||l_item_where||'
               )f
		where '||l_org_security||
		')  fact,
    		OPI_PTP_RPT_BND_MV    	 bnd
  	WHERE fact.time_id = cal.time_id
        AND fact.period_type_id = cal.period_type_id
        AND fact.organization_id = decode(cal.organization_id, -1, fact.organization_id, cal.organization_id)
	AND fact.organization_id = bnd.organization_id
  	GROUP BY cal.start_date) f,
        '|| l_period_type ||' fii
        WHERE fii.start_date = f.start_date(+)
        AND fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
        AND &BIS_CURRENT_ASOF_DATE
        ORDER BY fii.start_date';

  BEGIN
   execute immediate '
    CREATE GLOBAL TEMPORARY TABLE OPI_DBI_PTP_TRD_TMP(
      organization_id number,
      report_date date,
      time_id number,
      period_type_id number
    ) ON COMMIT PRESERVE ROWS'
  ;
  EXCEPTION
  WHEN others THEN  null;
    execute immediate 'truncate table opi_dbi_ptp_trd_tmp';
  END;
  BEGIN
  if(l_period_type = 'FII_TIME_ENT_YEAR') then
    l_nested_pattern := 119;
  elsif(l_period_type = 'FII_TIME_ENT_QTR') then
    l_nested_pattern := 55;
  elsif(l_period_type = 'FII_TIME_ENT_PERIOD') then
    l_nested_pattern := 23;
  elsif(l_period_type = 'FII_TIME_WEEK') then
    l_nested_pattern := 11;
  elsif(l_period_type = 'FII_TIME_DAY') then
    l_nested_pattern := 1;
  else
    l_nested_pattern := 119;
  end if;
  execute immediate '
  insert into OPI_DBI_PTP_TRD_TMP
      (organization_id,
      report_date,
      time_id,
      period_type_id
      )
      select
        -1 organization_id,
        cal.report_date,
        cal.time_id,
        cal.period_type_id
            FROM
             (SELECT least(fii.end_date, :l_curr_asof_date) DAY
              FROM '||l_period_type||' fii
              WHERE fii.start_date BETWEEN
                    :l_curr_rpt_start_date AND :l_curr_asof_date
              union
              SELECT least(fii.end_date, :l_prev_asof_date) DAY
              FROM '||l_period_type||' fii
              WHERE fii.start_date BETWEEN
                    :l_prev_rpt_start_date AND :l_prev_asof_date
                )   dates,
              FII_TIME_RPT_STRUCT_V    cal
          WHERE cal.report_date = dates.day
            AND bitand(cal.record_type_id, :l_nested_pattern) = cal.record_type_id
      union all
      select
        bnd.organization_id,
        cal.report_date,
        cal.time_id,
        cal.period_type_id
      from
              FII_TIME_RPT_STRUCT_V    cal,
              OPI_PTP_RPT_BND_MV       bnd
          WHERE cal.report_date = bnd.DATA_CLEAN_DATE
            AND bitand(cal.record_type_id, :l_nested_pattern) = cal.record_type_id
  ' using l_curr_asof_date, l_curr_rpt_start_date, l_curr_asof_date, l_prev_asof_date, l_prev_rpt_start_date, l_prev_asof_date, l_nested_pattern, l_nested_pattern;
  EXCEPTION
  WHEN others THEN  null;
  END;
  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':OPI_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

END GET_TRD_SQL;

PROCEDURE GET_CMLTV_TRD_SQL(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS
  l_formula_sql		VARCHAR2(4000) := '';
  l_inner_sql		VARCHAR2(6000) := '';
  l_stmt 		VARCHAR2(8000) := '';
  l_period_type		VARCHAR2(255)  := NULL;
  l_org 		VARCHAR2(255)  := NULL;
  l_org_where     	VARCHAR2(2000) := ' AND 1=1';
  l_org_security        VARCHAR2(2000) := '1=1';
  l_item		VARCHAR2(255)  := NULL;
  l_item_where		VARCHAR2(2000) := ' AND 1=1';
  l_inv_cat		VARCHAR2(255)  := NULL;
  l_inv_cat_where	VARCHAR2(2000) := ' AND 1=1';
  l_item_cat_flag	NUMBER; -- 0 for item and 1 for inv. category
  l_currency            VARCHAR2(30) := '';
  l_currency_code       VARCHAR2(2) := 'B';
  l_period_detail       VARCHAR2(30);
  l_nested_pattern      NUMBER;
  l_period_id           VARCHAR2(20);
  l_custom_rec 		BIS_QUERY_ATTRIBUTES;
  l_pmv_nested_pattern  NUMBER;
  l_curr_asof_date      DATE;
  l_curr_eft_start_date DATE;
  l_curr_eft_end_date   DATE;
  l_period_end_date date;
  l_period_select varchar2(200):=NULL;

  l_error varchar2(255);
BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN  l_period_type := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
       IF ( p_param(i).parameter_value IS NULL OR p_param(i).parameter_value = 'All' ) THEN
         l_inv_cat :=  p_param(i).parameter_value;
       ELSE
         l_inv_cat := 'Selected';
       END IF;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
       IF ( p_param(i).parameter_value IS NULL OR p_param(i).parameter_value = 'All' ) THEN
         l_item :=  p_param(i).parameter_value;
       ELSE
         l_item := 'Selected';
       END IF;
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
       l_currency := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'AS_OF_DATE') then
       l_curr_asof_date := p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'BIS_CURRENT_EFFECTIVE_END_DATE') then
       l_curr_eft_end_date := p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'BIS_CURRENT_EFFECTIVE_START_DATE') then
       l_curr_eft_start_date := p_param(i).period_date;
    END IF;
  END LOOP;

  IF(l_currency = '''FII_GLOBAL1''') then
        l_currency_code := 'G';
  ELSIF (l_currency = '''FII_GLOBAL2''') then
        l_currency_code := 'SG';
  END IF;

  IF l_period_type = 'FII_TIME_WEEK' THEN
    l_period_detail := 'FII_TIME_DAY_V';
    l_period_id := 'WEEK_ID';
    l_nested_pattern := 1;
    l_pmv_nested_pattern := 11;
    l_period_end_date:=fii_time_api.cwk_start(l_curr_asof_date);
    l_period_select:= ' (bucket.start_date - :l_period_end_date) +1 name, ';
  ELSIF l_period_type = 'FII_TIME_ENT_PERIOD' THEN
    l_period_detail := 'FII_TIME_DAY_V';
    l_period_id := 'ENT_PERIOD_ID';
    l_nested_pattern := 1;
    --l_nested_pattern := 11;
    l_pmv_nested_pattern := 23;
    l_period_end_date :=fii_time_api.ent_cper_start(l_curr_asof_date);
    l_period_select:=' (bucket.start_date - :l_period_end_date) +1  name, ';
  ELSIF l_period_type = 'FII_TIME_ENT_QTR' THEN
    l_period_detail := 'FII_TIME_DAY_V';
    l_period_id := 'ENT_QTR_ID';
    l_nested_pattern := 1;
    --l_nested_pattern := 11;
    l_pmv_nested_pattern := 55;
    l_period_end_date :=fii_time_api.ent_cqtr_end(l_curr_asof_date) ;
    l_period_select :=' (bucket.start_date - :l_period_end_date) -1 name, ';
  ELSE
    l_period_detail := 'FII_TIME_ENT_PERIOD_V';
    l_period_id := 'ENT_YEAR_ID';
    l_nested_pattern := 23;
    l_pmv_nested_pattern := 119;
    l_period_end_date:=NULL;
    l_period_select := ' substr(bucket.name,1,3 ) || :l_period_end_date  name, ';
  END IF;

  IF ( l_org IS NULL OR l_org = 'All' ) THEN
    l_org_security := '
	    (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = f.organization_id)
		OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = f.organization_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';

  ELSE
    --do we allow mutliple selects of org here?
    l_org_where := ' AND f.organization_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF ( l_inv_cat IS NULL OR l_inv_cat = 'All' ) THEN
    l_inv_cat_where :='';
  ELSE
    l_inv_cat_where := ' AND f.inv_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF ( l_item IS NULL OR l_item = 'All' ) THEN
    l_item_where :='';
  ELSE
    l_item_where := ' AND f.item_org_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF((l_inv_cat IS NULL OR l_inv_cat = 'All' ) AND ( l_item IS NULL OR l_item = 'All')) THEN
    l_item_cat_flag := 3;  -- no grouping on item dimension
  ELSE
    IF (l_item IS NULL OR l_item = 'All') THEN
      l_item_cat_flag := 1; -- inv, category
    ELSE
      l_item_cat_flag := 0; -- item is needed
    END IF;
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_stmt :='SELECT fact.name VIEWBY,
                   CURR_ACTUAL_STANDARD_VALUE OPI_MEASURE1,
                   CURR_PLANNED_STANDARD_VALUE OPI_MEASURE2,
                   decode(sign(fact.start_date - &BIS_CURRENT_ASOF_DATE), 1, null, SUM(nvl(CURR_ACTUAL_STANDARD_VALUE, 0)) OVER (ORDER BY fact.start_date ASC ROWS UNBOUNDED PRECEDING)) AS OPI_MEASURE3,
                   SUM(nvl(CURR_PLANNED_STANDARD_VALUE, 0)) OVER (ORDER BY fact.start_date ASC ROWS UNBOUNDED PRECEDING) AS OPI_MEASURE4
            FROM ( SELECT /*+ leading(c) push_pred(f) */
                          c.start_date,
                          c.name,
                          sum(decode(sign(&BIS_CURRENT_ASOF_DATE - c.start_date), -1, null, decode(sign(&BIS_CURRENT_ASOF_DATE - c.report_date), -1, 0, f.ACTUAL_STANDARD_VALUE))) CURR_ACTUAL_STANDARD_VALUE,
                          sum(decode(c.report_date, c.end_date, f.PLANNED_STANDARD_VALUE, 0)) CURR_PLANNED_STANDARD_VALUE
                     FROM
                     (select ORGANIZATION_ID,
                             INVENTORY_ITEM_ID,
                             INV_CATEGORY_ID,
                             TIME_ID,
                             PERIOD_TYPE_ID,
                             ACTUAL_STANDARD_VALUE,
                             PLANNED_STANDARD_VALUE
                      from
                             (select
                                     f.ORGANIZATION_ID,
                                     f.INVENTORY_ITEM_ID,
                                     f.INV_CATEGORY_ID,
                                     f.TIME_ID,
                                     f.PERIOD_TYPE_ID,
                                     f.ACTUAL_STANDARD_VALUE_'||l_currency_code||' ACTUAL_STANDARD_VALUE,
                                     f.PLANNED_STANDARD_VALUE_'||l_currency_code||' PLANNED_STANDARD_VALUE
                              from   OPI_PTP_SUM_F_MV f
                              where
                                     f.item_cat_flag = :OPI_ITEM_CAT_FLAG
                            '||l_org_where||l_inv_cat_where||l_item_where||
                            ' union all
                              select
                                     f.ORGANIZATION_ID,
                                     f.INVENTORY_ITEM_ID,
                                     f.INV_CATEGORY_ID,
                                     f.TIME_ID,
                                     f.PERIOD_TYPE_ID,
                                     0 ACTUAL_STANDARD_VALUE,
                                     f.PLANNED_STANDARD_VALUE_'||l_currency_code||' PLANNED_STANDARD_VALUE
                              from   OPI_PTP_SUM_STG_MV f
                              where
                                     f.item_cat_flag = :OPI_ITEM_CAT_FLAG
                            '||l_org_where||l_inv_cat_where||l_item_where||
                            ') f
                      where '||l_org_security||
                    ') f,
                     OPI_DBI_PTP_CMLTV_TMP c
                     WHERE   f.time_id (+) = c.time_id
                       AND   f.period_type_id (+) = c.period_type_id
                    GROUP BY
                             c.start_date,
                             c.name
                    ORDER BY start_date ASC
                 ) fact';

  BEGIN
   execute immediate '
    CREATE GLOBAL TEMPORARY TABLE OPI_DBI_PTP_CMLTV_TMP (
      start_date DATE,
      end_date DATE,
      name VARCHAR2(100),
      time_id NUMBER,
      report_date DATE,
      period_type_id NUMBER,
      report_start_date DATE
    ) ON COMMIT PRESERVE ROWS'
  ;
  EXCEPTION
  WHEN others THEN  null;
    execute immediate 'truncate table opi_dbi_ptp_cmltv_tmp';
  END;
  BEGIN
  execute immediate '
  insert into OPI_DBI_PTP_CMLTV_TMP
      (start_date,
      end_date,
      name,
      time_id,
      report_date,
      period_type_id,
      report_start_date
      )
  select
         bucket.start_date,
         bucket.end_date,
      --   bucket.name,
         '|| l_period_select || '
         cal.time_id,
         cal.report_date,
         cal.period_type_id,
         bucket.report_start_date report_start_date
  from
         FII_TIME_RPT_STRUCT_V cal,
         (SELECT t1.start_date       START_DATE,
                 least(t1.end_date, :l_eft_end_date) END_DATE,
                 t1.value            NAME,
                 least(t1.end_date, :l_eft_end_date) PDAY,
                 least(t1.end_date, :l_curr_asof_date) ADAY,
                 :l_eft_start_date REPORT_START_DATE
            FROM '||l_period_detail||' t1
           WHERE t1.start_date BETWEEN :l_eft_start_date AND :l_eft_end_date
              OR
                 t1.end_date BETWEEN :l_eft_start_date AND :l_eft_end_date
         ) bucket
  where  cal.report_date in (bucket.pday, bucket.aday)
  AND    decode(sign(bucket.start_date - bucket.report_start_date), -1, bitand(cal.record_type_id, :l_pmv_nested_pattern), bitand(cal.record_type_id, :l_nested_pattern)) = cal.record_type_id
  ' using l_period_end_date,l_curr_eft_end_date, l_curr_eft_end_date, l_curr_asof_date, l_curr_eft_start_date, l_curr_eft_start_date, l_curr_eft_end_date, l_curr_eft_start_date, l_curr_eft_end_date, l_pmv_nested_pattern, l_nested_pattern;
  EXCEPTION
  WHEN others THEN null;
  END;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':OPI_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':OPI_NESTED_PATTERN';
  l_custom_rec.attribute_value := l_nested_pattern;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value := 'TIME+'||substrb(l_period_detail, 1, instrb(l_period_detail, '_', -1, 1)-1);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

END GET_CMLTV_TRD_SQL;

END OPI_DBI_PTP_RPT_PKG;

/
