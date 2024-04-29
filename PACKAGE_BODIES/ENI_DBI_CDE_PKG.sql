--------------------------------------------------------
--  DDL for Package Body ENI_DBI_CDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_CDE_PKG" AS
/*$Header: ENICDEPB.pls 120.2 2006/02/14 04:26:25 lparihar noship $*/

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
l_org_where            VARCHAR2(1000);
l_cat_where            VARCHAR2(1000);
l_item_where           VARCHAR2(1000);
l_temp                 VARCHAR2(1000);
l_lob                  VARCHAR2(1000);
l_for_cat              VARCHAR2(1000);
l_from_clause          VARCHAR2(1000);
l_where_clause         VARCHAR2(1000);
l_group_by_clause      VARCHAR2(500);
l_concat_var           varchar2(1000);
l_item_org             VARCHAR2(50);
l_item_temp            NUMBER;
l_org_master             NUMBER;
l_drill_to_item_page   VARCHAR2(1000);
l_component_category   VARCHAR2(200);
l_unassigned_desc      VARCHAR2(240); -- FND_LOOKUP_VALUES.DESCRIPTION IS VARCHAR2(240)

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
                                 , l_org_master
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

IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first .. p_page_parameter_tbl.last LOOP
        IF ((p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_ITM_CAT+ENI_ITEM_ITM_CAT') OR
         (p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT+ENI_ITEM_ITM_CAT')) THEN
           l_component_category := p_page_parameter_tbl(i).parameter_id;
    ELSIF ((p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT+ENI_ITEM_ITM_CAT')
          OR (p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT+ENI_ITEM_ITM_CAT'))
          THEN
           l_category := p_page_parameter_tbl(i).parameter_value;
    END IF;
    END LOOP;
END IF;

l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
x_custom_output := bis_query_attributes_tbl();

BEGIN
   select
     NVL(common_assembly_item_id,assembly_item_id),
     NVL(common_organization_id ,organization_id)
   INTO
     l_item,l_org
    from
      bom_bill_of_materials
   where
     assembly_item_id = l_item_temp and
     organization_id     = l_org_master and
     alternate_bom_designator IS NULL;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
           l_item := NULL; l_org := NULL;
END;

IF l_item IS NULL
THEN
    x_custom_sql :=' SELECT NULL AS VIEWBY,
                    1 AS ENI_MEASURE1,
                    2 AS ENI_MEASURE2,
                    3 AS ENI_MEASURE2,
                    4 AS ENI_MEASURE4,
                    6 AS ENI_MEASURE5 FROM DUAL where 1 = 2';
    RETURN;
END IF;

SELECT DESCRIPTION
INTO
    l_unassigned_desc
FROM
    FND_LOOKUP_VALUES
WHERE
    LOOKUP_TYPE = 'ITEM' AND LOOKUP_CODE = '-1'
    AND LANGUAGE = USERENV( 'LANG' );

l_item_where := ' AND pco.assembly_item_id = :ITEM';
l_item_where := l_item_where || ' AND pco.organization_id = :ORG';
l_item_where := l_item_where || ' AND star.inventory_item_id =  pco.component_item_id
                                  AND star.organization_id = :ORG_MASTER'; --Modified to fix Bug# 3493983
l_cat_where := ' AND NVL( star.item_catalog_group_id, -1 ) = :COMPONENT_CATEGORY';

l_drill_to_item_page := ' ''pFunctionName=EGO_ITEM_OVERVIEW&inventoryItemId='' || TO_CHAR(item_id)' ;
l_drill_to_item_page := l_drill_to_item_page || ' || ''&organizationId='' || TO_CHAR(org_id)';
l_drill_to_item_page := l_drill_to_item_page || ' || ''&revisionCode='' || TO_CHAR(revision)';

x_custom_sql :=  '
    SELECT
        item_name AS ENI_MEASURE1
        , DECODE(
            item_id
            , -1, :UNASSIGNED_DESC
            , MTI_TL.DESCRIPTION )
        AS ENI_MEASURE2
        , revision AS ENI_MEASURE3
        , status_code AS ENI_MEASURE4
        , ' || l_drill_to_item_page || '
        AS ENI_MEASURE5
        FROM
            ( SELECT
                ( rank() over ( &ORDER_BY_CLAUSE nulls last, pco.rowid ) - 1 ) AS rnk,
                star.value AS item_name,
                pco.component_item_id AS item_id,
                pco.organization_id AS org_id,
                star.organization_id AS base_org,
                NVL((select mir.revision from MTL_ITEM_REVISIONS_B mir
                     where mir.inventory_item_id = pco.component_item_id
                     and mir.organization_id = :ORG_MASTER
                     and mir.effectivity_date =
                              (select max(mir1.effectivity_date) from MTL_ITEM_REVISIONS_B mir1
                           where mir1.inventory_item_id = pco.component_item_id
                           and mir1.organization_id = :ORG_MASTER
                           and mir1.implementation_date IS NOT NULL
                           and trunc(mir1.effectivity_date) <= &BIS_CURRENT_ASOF_DATE )), -1) revision,
                (select msi.inventory_item_status_code from MTL_SYSTEM_ITEMS_B msi
                 where inventory_item_id = pco.component_item_id
                 and organization_id = :ORG_MASTER ) status_code
            FROM
                ENI_DBI_PART_COUNT_F pco
                , ( select value as ENI_MEASURE1, value, organization_id, inventory_item_id, item_catalog_group_id
                FROM ENI_OLTP_ITEM_STAR ) star
            WHERE
                (&BIS_CURRENT_ASOF_DATE BETWEEN
                     pco.effectivity_date AND pco.disable_date)
                ' || l_item_where || l_cat_where || '
            ) pcofact
            , MTL_SYSTEM_ITEMS_TL MTI_TL
        WHERE
            ( ( pcofact.rnk between &START_INDEX and &END_INDEX ) OR (&END_INDEX = -1) )
            and pcofact.base_org = MTI_TL.ORGANIZATION_ID(+)
            and pcofact.item_id = MTI_TL.INVENTORY_ITEM_ID(+)
            and MTI_TL.LANGUAGE(+) = USERENV( ''LANG'' )
        &ORDER_BY_CLAUSE NULLS LAST' ;
-- Dirty PMV HACK: when DisplayRows = 25 and displaying rows 26-50, for example,
-- sets START_INDEX = 25, END_INDEX = 51, so the above code returns 27 rows; 25 for display
-- and 2 to ensure PMV displays 'Next' and 'Previous' navigators

x_custom_output.extend;
l_custom_rec.attribute_name := ':UNASSIGNED_DESC';
l_custom_rec.attribute_value := l_unassigned_desc;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(1) := l_custom_rec;

x_custom_output.extend;
l_custom_rec.attribute_name := ':ORG_MASTER';
l_custom_rec.attribute_value := l_org_master;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(2) := l_custom_rec;

x_custom_output.extend;
l_custom_rec.attribute_name := ':ORG';
l_custom_rec.attribute_value := l_org;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(3) := l_custom_rec;

x_custom_output.extend;
l_custom_rec.attribute_name := ':ITEM';
l_custom_rec.attribute_value := l_item;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(4) := l_custom_rec;

x_custom_output.extend;
l_custom_rec.attribute_name := ':COMPONENT_CATEGORY';
l_custom_rec.attribute_value := l_component_category;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
x_custom_output(5) := l_custom_rec;

END GET_SQL;

END ENI_DBI_CDE_PKG;

/
