--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PCM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PCM_PKG" AS
/*$Header: ENIPCMPB.pls 120.3 2006/03/23 04:40:19 pgopalar noship $*/
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
     organization_id  = l_org_temp and
     alternate_bom_designator IS NULL;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_item := null; l_org := null;
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

l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
x_custom_output := bis_query_attributes_tbl();

IF (l_item_temp IS NULL)
THEN
   x_custom_sql :=' SELECT NULL AS VIEWBY,
                NULL AS ENI_MEASURE1,
                NULL AS ENI_MEASURE2,
                NULL AS ENI_MEASURE4,
                NULL AS ENI_MEASURE5  FROM DUAL ';
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
	' SELECT
		name as VIEWBY,
		SUM(ENI_MEASURE1) AS ENI_MEASURE1,
		SUM(ENI_MEASURE2) AS ENI_MEASURE2,
		SUM(ENI_MEASURE4) AS ENI_MEASURE4,
		SUM(ENI_MEASURE5) AS ENI_MEASURE5
	  FROM
	  (
		SELECT
			t.start_date,
			t.name,
			SUM
			(
				CASE WHEN t.c_end_date BETWEEN pco.effectivity_date
				AND pco.disable_date
				THEN
					part_count
				ELSE
					NULL
				END
			) AS ENI_MEASURE1, -- part count current
			SUM
			(
				CASE WHEN t.p_end_date BETWEEN pco.effectivity_date
				AND pco.disable_date
				THEN
					part_count
				ELSE
					NULL
				END
			) AS ENI_MEASURE2, -- part count prior
			SUM(NULL) AS ENI_MEASURE4, -- mfg steps current
			SUM(NULL) AS ENI_MEASURE5 -- mfg steps prior
		FROM
			eni_dbi_part_count_mv pco , '||l_from_clause||'
		WHERE
			pco.assembly_item_id = :ITEM       --|| l_item || : Bug 5083568
			AND pco.organization_id = :ORG     --|| l_org ||  : Bug 5083568
			AND
			(
				t.c_end_date BETWEEN pco.effectivity_date AND pco.disable_date
				OR
				t.p_end_date BETWEEN pco.effectivity_date AND pco.disable_date
			)
		group by t.start_date,t.name
		UNION ALL
		SELECT -- mfg steps
			t.start_date,
			t.name,
			SUM(NULL) AS ENI_MEASURE1, -- part count current
			SUM(NULL) AS ENI_MEASURE2, -- part count prior
			SUM
			(
				CASE WHEN t.c_end_date
				BETWEEN trunc(effectivity_date)	AND
				nvl(trunc(disable_date),t.c_end_date+1)
				THEN
					mfgsteps_count
				ELSE
					NULL
				END
			) AS ENI_MEASURE4, -- mfg steps current
			SUM
			(
				CASE WHEN t.p_end_date
				BETWEEN trunc(effectivity_date) AND
				nvl(trunc(disable_date),t.p_end_date+1)
				THEN
					mfgsteps_count
				ELSE
					NULL
				END
			) AS ENI_MEASURE5 -- mfg steps prior
		FROM
			eni_dbi_mfg_steps_join_mv mfg , '||l_from_clause||'
		WHERE
			mfg.item_id = :ITEM_TEMP                --|| l_item_temp || : Bug 5083568
			AND mfg.organization_id = :ORG_TEMP     --|| l_org_temp ||  : Bug 5083568
			AND
			(
				t.c_end_date BETWEEN trunc(effectivity_date) AND
				nvl(trunc(disable_date),t.c_end_date + 1)
				OR
				t.p_end_date BETWEEN trunc(effectivity_date) AND
				nvl(trunc(disable_date),t.p_end_date + 1)
			)
		group by t.start_date,t.name
		UNION ALL
		SELECT
			t.start_date,
			t.name,
			NULL AS ENI_MEASURE1, -- part count current
			NULL AS ENI_MEASURE2, -- part count prior
			NULL AS ENI_MEASURE4, -- mfg steps current
			NULL AS ENI_MEASURE5 -- mfg steps prior
		FROM
			'||l_from_clause||'
		WHERE
			NOT(
				(EXISTS(select * from eni_dbi_part_count_mv
				 where assembly_item_id = :ITEM AND      --||l_item|| AND : Bug 5083568
				 organization_id = :ORG AND              --||l_org|| AND  : Bug 5083568
				 (t.c_end_date BETWEEN effectivity_date AND disable_date
				 OR t.p_end_date BETWEEN effectivity_date AND disable_date)))
			  OR
				(EXISTS(select * from eni_dbi_mfg_steps_join_mv
				 where item_id = :ITEM_TEMP AND          --||l_item_temp|| AND : Bug 5083568
				 organization_id = :ORG_TEMP AND         --||l_org_temp|| AND  : Bug 5083568
	       			 (t.c_end_date BETWEEN trunc(effectivity_date) AND
                                 nvl(trunc(disable_date),t.c_end_date + 1)
				 OR t.p_end_date BETWEEN trunc(effectivity_date) AND
                                 nvl(trunc(disable_date),t.p_end_date + 1)) ))
                           ))
		group by start_date,name
                order by '||l_order_by ;

   -- Bug 5083568: Added the following Bind Values
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
   l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   x_custom_output(2) := l_custom_rec;

   x_custom_output.extend;
   l_custom_rec.attribute_name := ':ITEM_TEMP';
   l_custom_rec.attribute_value := replace(l_item_temp,'''');
   l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   x_custom_output(3) := l_custom_rec;

   x_custom_output.extend;
   l_custom_rec.attribute_name := ':ORG_TEMP';
   l_custom_rec.attribute_value := replace(l_org_temp,'''');
   l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   x_custom_output(4) := l_custom_rec;

   --Bug 5083652 -- Start Code

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODTYPE';
  l_custom_rec.attribute_value := REPLACE(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(5) := l_custom_rec;

   x_custom_output.extend;
  l_custom_rec.attribute_name := ':COMPARETYPE';
  l_custom_rec.attribute_value := REPLACE(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(6) := l_custom_rec;


  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODAND';
  l_custom_rec.attribute_value := REPLACE(l_period_bitand,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(7) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(8) := l_custom_rec;

--Bug 5083652 -- End Code

 END IF;

END GET_SQL;
END ENI_DBI_PCM_PKG;

/
