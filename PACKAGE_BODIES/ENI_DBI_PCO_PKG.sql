--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PCO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PCO_PKG" AS
/*$Header: ENIPCOPB.pls 120.3 2006/03/19 22:58:37 sdebroy noship $*/
PROCEDURE GET_SQL
(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
        , x_custom_sql        OUT NOCOPY VARCHAR2
        , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS
l_err 		       varchar2(3000);
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
l_comp_where           VARCHAR2(1000);
l_temp                 VARCHAR2(1000);
l_lob                  VARCHAR2(1000);
l_for_cat              VARCHAR2(1000);
l_where_clause         VARCHAR2(1000);
l_group_by_clause      VARCHAR2(500);
l_concat_var           VARCHAR2(1000);
l_item_1               NUMBER;
l_org_1                NUMBER;
l_drill_down_part_count VARCHAR2(2000);
l_component_cat_cond   VARCHAR2(100);
l_cat_cond             VARCHAR2(100);
l_org_exists           NUMBER;
l_org_temp             NUMBER;

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
                                 , l_item
                                 , l_org
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
l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
x_custom_output := bis_query_attributes_tbl();
l_org_temp := l_org;

Begin
   select
     NVL(common_assembly_item_id,assembly_item_id),
     NVL(common_organization_id,organization_id)
   INTO
     l_item,l_org
   from
     bom_bill_of_materials
   where
     assembly_item_id = l_item and
     organization_id  = l_org and
     alternate_bom_designator IS NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_item := null; l_org := null;
end;

IF (l_item IS NOT NULL) THEN
      -- Display the data only when the organization of the item exists
      -- in the org_temp table. Added for bug # 3669751

	SELECT count(*)
	INTO l_org_exists
	FROM eni_dbi_part_count_org_temp
	WHERE organization_id = l_org_temp;

	IF (l_org_exists = 0) THEN
		l_item := NULL;
		l_org := NULL;
	END IF;
END IF;

IF (l_item IS NULL) THEN  --  When no Item is selected, a single row of N/A is displayed
   x_custom_sql := '  SELECT NULL AS VIEWBY,
			     NULL AS ENI_MEASURE1,
		  	     NULL AS ENI_MEASURE2,
		  	     NULL AS ENI_MEASURE3,
		  	     NULL AS ENI_MEASURE4,
		  	     NULL AS ENI_MEASURE5,
		  	     NULL AS ENI_MEASURE6,
		  	     NULL AS ENI_MEASURE7,
			     NULL AS ENI_MEASURE9
		      FROM DUAL ';
   RETURN;
END IF;

l_drill_down_part_count := 'pFunctionName=ENI_DBI_CDE_R&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
l_component_cat_cond := '&ITEM+ENI_ITEM_ITM_CAT+ENI_ITEM_ITM_CAT=';
l_cat_cond := '&ITEM+ENI_ITEM_ITM_CAT+ENI_ITEM_VBH_CAT=' || l_category;

l_where_clause := 'pco.organization_id = :ORGANIZATION_ID '||         --Bug#5083708 || l_org ||
	       ' AND pco.assembly_item_id = :ASSEMBLY_ITEM_ID' ;      --Bug#5083708 || l_item;

l_where_clause := l_where_clause  ||
               ' AND eiv.organization_id = :ORGANIZATION_ID '||       --Bug#5083708 || l_org ||
	       ' AND eiv.inventory_item_id = pco.component_item_id';

x_custom_sql :=
	'  SELECT
		eic.VALUE as VIEWBY,
		eic.ID as VIEWBYID,
		b.current_pco as ENI_MEASURE1,
		b.prior_pco as ENI_MEASURE2,
		b.change_percent as ENI_MEASURE3,
		b.percent_of_total as ENI_MEASURE4,
		sum(b.current_pco) over() as ENI_MEASURE5,
		sum(b.change_percent) over() AS ENI_MEASURE6,
		sum(b.percent_of_total) over() as ENI_MEASURE7,
		:PCO_LIST_DRILL || :PCO_CAT_DRILL || :PCO_COMP_DRILL || TO_CHAR(eic.ID) AS ENI_MEASURE9
	   FROM (SELECT
			a.ITEM_CATALOG_GROUP_ID,
			a.current_pco ,
			a.prior_pco ,
			round(DECODE(a.prior_pco,0 , NULL, (((a.current_pco - a.prior_pco)/a.prior_pco)*100)),2)
							AS change_percent,
			sum(a.current_pco) over() as grand_current,
			round(DECODE((sum(a.current_pco) over()),0 , NULL, ((a.current_pco/(sum(a.current_pco) over()))*100)),2)
							AS percent_of_total
			FROM
			(SELECT NVL(eiv.ITEM_CATALOG_GROUP_ID,-1) as item_catalog_group_id,
				SUM(CASE WHEN ('||'&'|| 'BIS_CURRENT_ASOF_DATE -- Condition modified to fix the Bug 3151377
					BETWEEN pco.effectivity_date AND pco.disable_date)
					THEN 1 ELSE 0 END) AS current_pco,
				SUM(CASE WHEN ('||'&'|| 'BIS_PREVIOUS_ASOF_DATE  -- Condition modified to fix the Bug 3151377
					BETWEEN pco.effectivity_date AND pco.disable_date)
					THEN 1 ELSE 0 END) AS prior_pco
			FROM ENI_DBI_PART_COUNT_F pco, ENI_ITEM_ORG_V eiv WHERE
			'||l_where_clause||'
			GROUP BY NVL(eiv.item_catalog_group_id,-1)) a) b, ENI_ITEM_ITM_CAT_V eic
	    WHERE b.ITEM_CATALOG_GROUP_ID = eic.ID and
			     (NOT(b.current_pco = 0)) and     -- Condition added to to fix the Bug 3131408
		  eic.ID = NVL(TO_NUMBER(eic.NODE),-1)
	    GROUP BY VALUE, ID, current_pco, prior_pco, change_percent, percent_of_total
	    ORDER BY
		' ||l_order_by;

x_custom_output.extend;
l_custom_rec.attribute_name := ':PCO_LIST_DRILL';
l_custom_rec.attribute_value := l_drill_down_part_count;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(1) := l_custom_rec;

x_custom_output.extend;
l_custom_rec.attribute_name := ':PCO_COMP_DRILL';
l_custom_rec.attribute_value := l_component_cat_cond;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(2) := l_custom_rec;

x_custom_output.extend;
l_custom_rec.attribute_name := ':PCO_CAT_DRILL';
l_custom_rec.attribute_value := l_cat_cond;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(3) := l_custom_rec;

--Bug#5083708
x_custom_output.extend;
l_custom_rec.attribute_name := ':ORGANIZATION_ID';
l_custom_rec.attribute_value := replace(l_org,'''');
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(4) := l_custom_rec;

x_custom_output.extend;
l_custom_rec.attribute_name := ':ASSEMBLY_ITEM_ID';
l_custom_rec.attribute_value := replace(l_item,'''');
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(5) := l_custom_rec;
--Bug#5083708

END GET_SQL;
END ENI_DBI_PCO_PKG;

/
