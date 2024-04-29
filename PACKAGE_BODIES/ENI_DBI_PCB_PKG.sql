--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PCB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PCB_PKG" AS
/*$Header: ENIPCBPB.pls 120.5 2006/03/23 22:33:39 pfarkade noship $*/

PROCEDURE get_sql
(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
        , x_custom_sql        OUT NOCOPY VARCHAR2
        , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS
l_err                  varchar2(3000);
l_custom_rec           BIS_QUERY_ATTRIBUTES;
l_err_msg              VARCHAR2(500);
l_period_type          VARCHAR2(40);
l_period_bitand        NUMBER;
l_view_by              VARCHAR2(200);
l_as_of_date           DATE;
l_prev_as_of_date      DATE;
l_report_start         DATE;
l_cur_period           NUMBER;
l_days_into_period     NUMBER;
l_comp_type            VARCHAR2(100);
l_category             VARCHAR2(100);
l_item                 VARCHAR2(100);
l_org                  VARCHAR2(100);
l_item_temp            VARCHAR2(100);
l_org_temp             VARCHAR2(100);
l_id_column            VARCHAR2(30);
l_order_by             VARCHAR2(100);
l_drill                VARCHAR2(30);
l_status               VARCHAR2(30);
l_priority             VARCHAR2(30);
l_reason               VARCHAR2(30);
l_lifecycle_phase      VARCHAR2(30);
l_currency             VARCHAR2(30);
l_bom_type             VARCHAR2(30);
l_type                 VARCHAR2(30);
l_manager              VARCHAR2(30);
l_temp                 VARCHAR2(1000);
l_lob                  VARCHAR2(1000);
l_for_cat              VARCHAR2(1000);
l_from_clause          VARCHAR2(1000);
l_where_clause         VARCHAR2(1000);
l_group_by_clause      VARCHAR2(500);
l_concat_var           varchar2(1000);
l_item_1               NUMBER;
l_org_1                NUMBER;
l_item_org_clause      VARCHAR2(1000);
l_org_exists           NUMBER;
BEGIN
   ENI_DBI_UTIL_PKG.get_parameters( p_page_parameter_tbl
                                 , l_period_type
                                 , l_period_bitand
                                 , l_view_by
                                 , l_as_of_date
                                 , l_prev_as_of_date
                                 , l_report_start
                                 , l_cur_period
                                 , l_days_into_period
                                 , l_comp_type
                                 , l_category
                                 , l_item_temp
                                 , l_org_temp
                                 , l_id_column
                                 , l_order_by
                                 , l_drill
                                 , l_status
                                 , l_priority
                                 , l_reason
                                 , l_lifecycle_phase
                                 , l_currency
                                 , l_bom_type
                                 , l_type
                                 , l_manager
                                 , l_lob
                                 );
       eni_dbi_util_pkg.get_time_clauses
            (
                        'I',
                        'edms',
                        l_period_type,
                        l_period_bitand,
                        l_as_of_date,
                        l_prev_as_of_date,
                        l_report_start,
                        l_cur_period,
                        l_days_into_period,
                        l_comp_type,
                        l_id_column,
                        l_from_clause,
                        l_where_clause,
                        l_group_by_clause,
			'ROLLING'
            );
  -- set where clauses
Begin
   select
     NVL(common_assembly_item_id,assembly_item_id),
     NVL(common_organization_id ,organization_id)
   INTO
     l_item,l_org
   from
     bom_bill_of_materials
   where
     assembly_item_id = l_item_temp and
     organization_id = l_org_temp and
     alternate_bom_designator IS NULL;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_item := NULL; l_org := NULL;
End;

IF (l_item IS NULL) THEN
	l_item := -9999;
	l_org := -9999;
ELSE  -- Display the data only when the organization of the item exists
      -- in the org_temp table. Added for bug # 3669751
	SELECT count(*)
	INTO l_org_exists
	FROM eni_dbi_part_count_org_temp
	WHERE organization_id = l_org_temp;
	IF (l_org_exists = 0) THEN
		l_item := -9999;
		l_org := -9999;
	END IF;
END IF;

IF (l_item_temp IS NULL OR l_item_temp = '' OR l_item_temp = 'All')
THEN
    IF (l_org_temp IS NOT NULL) THEN
         --l_item_org_clause := ' AND eiv.organization_id = '||l_org;
         l_item_org_clause := ' AND eiv.organization_id = :ORG';                             --Bug 5083920
        -- l_item_org_clause := l_item_org_clause || ' AND pco.organization_id = '||l_org';
         l_item_org_clause := l_item_org_clause || ' AND pco.organization_id = :ORG';        --Bug 5083920
    ELSE
         l_item_org_clause:= ' AND eiv.id = pco.item_org_id';
    END IF;
    l_item_1 := -1;
ELSE
    --l_item_org_clause  := ' AND pco.organization_id = '||l_org;
    l_item_org_clause  := ' AND pco.organization_id = :ORG';                                 --Bug 5083920
    --l_item_org_clause := l_item_org_clause || ' AND pco.assembly_item_id = '||l_item;
    l_item_org_clause := l_item_org_clause || ' AND pco.assembly_item_id = :ITEM';           --Bug 5083920
    l_item_1 := l_item;
    l_org_1 := l_org;
END IF;

  -- return sql based on the viewby

IF substr(l_view_by, 1, 5) = 'TIME+'
THEN
    IF (l_item_temp IS NULL OR l_item_temp = '' OR l_item_temp = 'All')
    THEN
       x_custom_sql :=' SELECT NULL AS VIEWBY,
                    NULL AS ENI_MEASURE1,
                    NULL AS ENI_MEASURE2,
                    NULL AS ENI_MEASURE4,
                    NULL AS ENI_MEASURE5,
                    NULL AS ENI_ATTRIBUTE11,
                    NULL AS ENI_ATTRIBUTE2 FROM DUAL';
    ELSE
       --  Setting the Order By Clause.
       IF (UPPER(l_order_by) LIKE '%START_DATE%ASC%') THEN
            l_order_by := 'START_DATE ASC';
       ELSIF (UPPER(l_order_by) LIKE '%START_DATE%DESC%') THEN
            l_order_by := 'START_DATE DESC';
       ELSIF (UPPER(l_order_by) LIKE '%START_DATE%') THEN
            l_order_by := 'START_DATE';
       END IF;
       x_custom_sql :=
           'SELECT
                   name AS VIEWBY,
                   current_pco AS ENI_MEASURE1,
                   prior_pco AS ENI_MEASURE2,
                   current_bom_levels AS ENI_MEASURE4,
                   prior_bom_levels AS ENI_MEASURE5,
                   current_pco AS ENI_ATTRIBUTE11,
                   current_bom_levels AS ENI_ATTRIBUTE2
           FROM ((select
                   sum(case when (t.c_end_date BETWEEN
                           pco.effectivity_date AND pco.disable_date)
                           then part_count
                           else NULL end) as current_pco,
                   sum(case when (t.p_end_date BETWEEN
                           pco.effectivity_date AND pco.disable_date)
                           then part_count
                           else NULL end) as prior_pco,
                   max(case when (t.c_end_date BETWEEN
                           pco.effectivity_date AND pco.disable_date)
                           then max_bom_level
                           else NULL end) as current_bom_levels,
                   max(case when (t.p_end_date BETWEEN
                           pco.effectivity_date AND pco.disable_date)
                           then max_bom_level
                           else NULL end) as prior_bom_levels,
                   t.name,
                   t.start_date
                   from
                           eni_dbi_part_count_mv pco,
                           ' || l_from_clause || '
                   where
                           '||l_where_clause|| '
                           '||l_item_org_clause||'
              group by
                           t.name,t.start_date)
          UNION ALL
                   (select NULL AS current_pco,
                           NULL AS prior_pco,
                           NULL AS current_bom_levels,
                           NULL AS prior_bom_levels,
                           t.name,
                           t.start_date
                   from
			   ' || l_from_clause || '
                   where
                           (NOT EXISTS(select * from eni_dbi_part_count_mv where
                                 assembly_item_id = :LITEM
                                  and organization_id = :LORG)) and '           --Bug 5083920
			         || l_where_clause ||'))
          order by
                   '||l_order_by;
     END IF;
END IF;
/*  -- For ITEM VIEWBY
IF (l_view_by = 'ITEM+ENI_ITEM_ORG') THEN
   IF (l_order_by like '%VIEW%ASC') THEN
        l_order_by := 'VIEWBY ASC';
   ELSIF (l_order_by like '%VIEW%DESC') THEN
        l_order_by := 'VIEWBY DESC';
   ELSIF (l_order_by like '%VIEW%') THEN
        l_order_by := 'VIEWBY ASC';
   END IF;
   x_custom_sql :=
          '(select
                   eiv.value as VIEWBY,
                   sum(case when ('||'&'||'BIS_CURRENT_ASOF_DATE BETWEEN
                           trunc(pco.effectivity_date) AND
                           NVL(trunc(pco.disable_date),to_date(''01-01-3000'',''DD-MM-YYYY'')))
                           then part_count
                           else NULL end) as ENI_MEASURE1,
                   sum(case when ('||'&'||'BIS_PREVIOUS_ASOF_DATE BETWEEN
                           trunc(pco.effectivity_date) AND
                           NVL(trunc(pco.disable_date),to_date(''01-01-3000'',''DD-MM-YYYY'')))
                           then part_count
                           else NULL end) as ENI_MEASURE2,
                   max(case when ('||'&'||'BIS_CURRENT_ASOF_DATE BETWEEN
                           trunc(pco.effectivity_date) AND
                           NVL(trunc(pco.disable_date),to_date(''01-01-3000'',''DD-MM-YYYY'')))
                           then max_bom_level
                           else NULL end) as ENI_MEASURE4,
                   max(case when ('||'&'||'BIS_PREVIOUS_ASOF_DATE BETWEEN
                           trunc(pco.effectivity_date) AND
                           NVL(trunc(pco.disable_date),to_date(''01-01-3000'',''DD-MM-YYYY'')))
                           then max_bom_level
                           else NULL end) as ENI_MEASURE5,
                   sum(case when ('||'&'||'BIS_CURRENT_ASOF_DATE BETWEEN
                           trunc(pco.effectivity_date) AND
                           NVL(trunc(pco.disable_date),to_date(''01-01-3000'',''DD-MM-YYYY'')))
                           then part_count
                           else NULL end) as ENI_ATTRIBUTE11,
                   max(case when ('||'&'||'BIS_CURRENT_ASOF_DATE BETWEEN
                           trunc(pco.effectivity_date) AND
                           NVL(trunc(pco.disable_date),to_date(''01-01-3000'',''DD-MM-YYYY'')))
                           then max_bom_level
                           else NULL end) as ENI_ATTRIBUTE2
                   from
                           eni_dbi_part_count_mv pco, ENI_ITEM_ORG_V eiv
                   where
                           (' || '&'|| 'BIS_CURRENT_ASOF_DATE BETWEEN
                           trunc(pco.effectivity_date) AND
                           NVL(trunc(pco.disable_date),to_date(''01-01-3000'', ''DD-MM-YYYY''))
                           OR
                           ' || '&'|| 'BIS_PREVIOUS_ASOF_DATE BETWEEN
                           trunc(pco.effectivity_date) AND
                           NVL(trunc(pco.disable_date),to_date(''01-01-3000'', ''DD-MM-YYYY'')))
                           '||l_item_org_clause||'
                   group by
                           eiv.value
          UNION ALL
                   select eiv.value as VIEWBY,
                           NULL as ENI_MEASURE1,
                           NULL AS ENI_MEASURE2,
                           NULL AS ENI_MEASURE4,
                           NULL AS ENI_MEASURE5,
                           NULL AS ENI_ATTRIBUTE11,
                           NULL AS ENI_ATTRIBUTE2
                   from
                           eni_item_org_v eiv
                   where
                           eiv.inventory_item_id = '||l_item_1||' and
                           eiv.organization_id = '||l_org_1||' and
                           ( NOT EXISTS (select * from eni_dbi_part_count_mv pco
                                     where
                                        item_id = '|| l_item_1 || ' and
                                        organization_id = '|| l_org_1 || ' and
                                        (' || '&'|| 'BIS_CURRENT_ASOF_DATE BETWEEN
                                            trunc(pco.effectivity_date) AND
                                            NVL(trunc(pco.disable_date),to_date(''01-01-3000'', ''DD-MM-YYYY''))
                                        OR
                                           ' || '&'|| 'BIS_PREVIOUS_ASOF_DATE BETWEEN
                                            trunc(pco.effectivity_date) AND
                                            NVL(trunc(pco.disable_date),to_date(''01-01-3000'', ''DD-MM-YYYY''))))))
          order by '
                   ||l_order_by;
END IF; */

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

--Start Bug 5083920
  x_custom_output.extend;
 l_custom_rec.attribute_name := ':ITEM';
 l_custom_rec.attribute_value := replace(l_item,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(1) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ORG';
 l_custom_rec.attribute_value := replace(l_org,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(2) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':LITEM';
 l_custom_rec.attribute_value := replace(l_item_1,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(3) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':LORG';
 l_custom_rec.attribute_value := replace(l_org_1,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(4) := l_custom_rec;

 --End Bug 5083920
 --Bug 5083652 -- Start Code

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODTYPE';
  l_custom_rec.attribute_value := replace(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(5) := l_custom_rec;

   x_custom_output.extend;
  l_custom_rec.attribute_name := ':COMPARETYPE';
  l_custom_rec.attribute_value := replace(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(6) := l_custom_rec;


  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODAND';
  l_custom_rec.attribute_value := replace(l_period_bitand,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(7) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := replace(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(8) := l_custom_rec;

--Bug 5083652 -- End Code

END GET_SQL;

/* ------------------------------------------------------
   Function : GetLabel
   The function returns YTD/QTD/PTD/WTD/Measure Name. This function is called
   from the PMV report and relies on cached values of variables
   called in the package init section.
   ------------------------------------------------------*/

FUNCTION GetLabel(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                  , measure_label IN NUMBER)
RETURN VARCHAR2
IS
    l_Time_Level_Value VARCHAR2(80);
    l_View_By   VARCHAR2(30);
    l_Label     VARCHAR2(10);
    L_YTD_Label VARCHAR2(8):='YTD';
    L_QTD_Label VARCHAR2(8):='QTD';
    L_MTD_Label VARCHAR2(8):='MTD';
    L_WTD_Label VARCHAR2(8):='WTD';
BEGIN
    FOR i IN 1..p_page_parameter_tbl.COUNT LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
           l_Time_Level_Value:=p_page_parameter_tbl(i).parameter_value;
       ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
           l_View_By:=p_page_parameter_tbl(i).parameter_value;
       END IF;
    END LOOP;
    IF (l_View_By LIKE '%ENI_ITEM_ORG%') THEN
        IF l_time_level_value IS NOT NULL THEN
           CASE (l_time_level_value)
              WHEN 'FII_TIME_ENT_YEAR' THEN
                   l_Label:=L_YTD_Label;
              WHEN 'FII_TIME_ENT_QTR' THEN
                   l_Label:=L_QTD_Label;
              WHEN 'FII_TIME_ENT_PERIOD' THEN
                   l_Label:=L_MTD_Label;
              WHEN 'FII_TIME_WEEK' THEN
                   l_Label:=L_WTD_Label;
           END CASE;
        ELSE
           l_Label:='';
        END IF;
    ELSE
        IF (measure_label = 1) THEN
             l_Label := 'Part Count';
        ELSE
             l_Label := 'BOM Levels';
        END IF;
    END IF;
    RETURN l_Label;
    EXCEPTION
        WHEN OTHERS THEN RETURN NULL;
END GetLabel;

END ENI_DBI_PCB_PKG;

/
