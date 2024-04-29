--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PME_KPI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PME_KPI_PKG" AS
/*$Header: ENIPMEPB.pls 120.4 2006/08/08 12:11:14 lparihar noship $*/
PROCEDURE get_sql
(
	p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql OUT NOCOPY VARCHAR2,
        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
)
IS
l_period_type VARCHAR2(100);
l_period_bitand NUMBER;
l_view_by VARCHAR2(100);
l_as_of_date DATE;
l_prev_as_of_date DATE;
l_report_start DATE;
l_cur_period NUMBER;
l_days_into_period NUMBER;
l_comp_type VARCHAR2(100);
l_category VARCHAR2(100);
l_item VARCHAR2(100);
l_org VARCHAR2(100);
l_id_column VARCHAR2(100);
l_order_by VARCHAR2(100);
l_drill VARCHAR2(100);
l_status VARCHAR2(100);
l_priority VARCHAR2(100);
l_reason VARCHAR2(100);
l_lifecycle_phase VARCHAR2(100);
l_currency VARCHAR2(100);
l_currency_rate VARCHAR2(30);
l_bom_type VARCHAR2(100);
l_type VARCHAR2(100);
l_manager VARCHAR2(100);
l_lob VARCHAR2(100);
l_from_clause VARCHAR2(1000);
l_where_clause VARCHAR2(1000);
l_group_by_clause VARCHAR2(1000);
l_err_msg VARCHAR2(32000);
-- The record structure for bind variable values
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_view_by_col VARCHAR2(100);
l_group_by_col VARCHAR2(100);
l_lookup VARCHAR2(100);
l_summary VARCHAR2(100);
l_item_pco NUMBER;
l_org_pco NUMBER;
l_org_exists NUMBER;

BEGIN

		eni_dbi_util_pkg.get_parameters
		(
                        p_page_parameter_tbl,
                        l_period_type,
                        l_period_bitand,
                        l_view_by,
                        l_as_of_date,
                        l_prev_as_of_date,
                        l_report_start,
                        l_cur_period,
                        l_days_into_period,
                        l_comp_type,
                        l_category,
                        l_item,
                        l_org,
                        l_id_column,
                        l_order_by,
                        l_drill,
                        l_status,
                        l_priority,
                        l_reason,
                        l_lifecycle_phase,
                        l_currency,
                        l_bom_type,
                        l_type,
                        l_manager,
                        l_lob
            );

            eni_dbi_util_pkg.get_time_clauses
            (
                        'I',
			'fgbm',
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
			l_group_by_clause ,
			'ROLLING'
            );

  -- Set currency rate based on currency chosen by user

    l_currency_rate :=
      CASE l_currency
        WHEN ENI_DBI_UTIL_PKG.get_curr_sec
                THEN 'secondary_currency_rate'   -- secondary global currency
        ELSE 'primary_currency_rate'             -- primary global currency (default)
      END;

      BEGIN
	select
	     NVL(common_assembly_item_id,assembly_item_id),
	     NVL(common_organization_id ,organization_id)
	INTO
	     l_item_pco,l_org_pco
	from
	     bom_bill_of_materials
	where
	     assembly_item_id = l_item and
	     organization_id  =  l_org and
	     alternate_bom_designator IS NULL;
        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      l_item_pco := NULL; l_org_pco := NULL;
       END;

	IF (l_item_pco IS NULL) THEN
		l_item_pco := -9999;
		l_org_pco := -9999;
	ELSE  -- Display the data only when the organization of the item exists
	      -- in the org_temp table. Added for bug # 3669751
		SELECT count(*)
		INTO l_org_exists
		FROM eni_dbi_part_count_org_temp
		WHERE organization_id = l_org;
		IF (l_org_exists = 0) THEN
			l_item_pco := -9999;
			l_org_pco := -9999;
		END IF;
	END IF;

	    IF (l_item ='' OR l_item IS NULL OR l_item = 'ALL') THEN

	    	x_custom_sql := '
		SELECT
			null AS ENI_MEASURE1,
			null AS ENI_MEASURE2,
			null AS ENI_MEASURE3,
			null AS ENI_MEASURE4,
			null AS ENI_MEASURE5,
			null AS ENI_MEASURE6,
			null AS ENI_MEASURE7,
			null AS ENI_MEASURE8,
			null AS ENI_MEASURE9,
			null AS ENI_MEASURE10,
			null AS ENI_MEASURE11,
			null AS ENI_MEASURE12,
			null AS ENI_MEASURE13,
			null AS ENI_MEASURE14,
                    null as ENI_MEASURE22,
                    null as ENI_MEASURE23,
                    null as ENI_MEASURE24,
                    null as ENI_MEASURE25,
                    null as ENI_MEASURE26,
                    null as ENI_MEASURE27,
                    null as ENI_MEASURE28,
                    null as ENI_MEASURE29,
                    null as ENI_MEASURE30,
                    null as ENI_MEASURE31,
                    null as ENI_MEASURE32,
                    null as ENI_MEASURE33,
                    null as ENI_MEASURE34,
                    null as ENI_MEASURE35
		FROM dual';
		x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
		l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
		RETURN;

	    END IF;

	    x_custom_sql :=
		' SELECT
				SUM(ENI_MEASURE1) AS ENI_MEASURE1,
				SUM(ENI_MEASURE2) AS ENI_MEASURE2,
				SUM(ENI_MEASURE3) AS ENI_MEASURE3,
				SUM(ENI_MEASURE4) AS ENI_MEASURE4,
				SUM(ENI_MEASURE5) AS ENI_MEASURE5,
				SUM(ENI_MEASURE6) AS ENI_MEASURE6,
				SUM(ENI_MEASURE7) AS ENI_MEASURE7,
				SUM(ENI_MEASURE8) AS ENI_MEASURE8,
				SUM(ENI_MEASURE9) AS ENI_MEASURE9,
				SUM(ENI_MEASURE10) AS ENI_MEASURE10,
				SUM(ENI_MEASURE11) AS ENI_MEASURE11,
				SUM(ENI_MEASURE12) AS ENI_MEASURE12,
				SUM(ENI_MEASURE13) AS ENI_MEASURE13,
				SUM(ENI_MEASURE14) AS ENI_MEASURE14,
				SUM(ENI_MEASURE1) AS ENI_MEASURE22,
				SUM(ENI_MEASURE2) AS ENI_MEASURE23,
				SUM(ENI_MEASURE3) AS ENI_MEASURE24,
				SUM(ENI_MEASURE4) AS ENI_MEASURE25,
				SUM(ENI_MEASURE5) AS ENI_MEASURE26,
				SUM(ENI_MEASURE6) AS ENI_MEASURE27,
				SUM(ENI_MEASURE7) AS ENI_MEASURE28,
				SUM(ENI_MEASURE8) AS ENI_MEASURE29,
				SUM(ENI_MEASURE9) AS ENI_MEASURE30,
				SUM(ENI_MEASURE10) AS ENI_MEASURE31,
				SUM(ENI_MEASURE11) AS ENI_MEASURE32,
				SUM(ENI_MEASURE12) AS ENI_MEASURE33,
				SUM(ENI_MEASURE13) AS ENI_MEASURE34,
				SUM(ENI_MEASURE14) AS ENI_MEASURE35
			FROM
			(
				SELECT -- unit cost KPI
					SUM
					(
						CASE WHEN edic.effective_date = c.effective_date
						THEN
							item_cost * ' || l_currency_rate || '
						ELSE
							NULL
						END
					) AS ENI_MEASURE1, -- unit cost current
					SUM
					(
						CASE WHEN edic.effective_date = p.effective_date
						THEN
							item_cost * ' || l_currency_rate || '
						ELSE
							NULL
						END
					) AS ENI_MEASURE2, -- unit cost prior
					SUM(NULL) AS ENI_MEASURE3, -- part count current
					SUM(NULL) AS ENI_MEASURE4, -- part count prior
					SUM(NULL) AS ENI_MEASURE5, -- mfg steps current
					SUM(NULL) AS ENI_MEASURE6, -- mfg steps prior
					SUM(NULL) AS ENI_MEASURE7, -- new change orders current
					SUM(NULL) AS ENI_MEASURE8, -- new change orders prior
					SUM(NULL) AS ENI_MEASURE9, -- open change orders current
					SUM(NULL) AS ENI_MEASURE10, -- open change orders prior
					SUM(NULL) AS ENI_MEASURE11, -- change order cycle time current
					SUM(NULL) AS ENI_MEASURE12, -- change order cycle time prior
					SUM(NULL) AS ENI_MEASURE13, -- max BOM Levels current
					SUM(NULL) AS ENI_MEASURE14 --  max BOM Levels prior
				FROM
					eni_dbi_item_cost_f edic,
					(
						SELECT
							max(effective_date) AS effective_date
						FROM
							eni_dbi_item_cost_f
						WHERE
							--inventory_item_id = ' || l_item || ' Bug 5083900
							inventory_item_id = :ITEM
							--AND organization_id = ' || l_org || ' Bug 5083900
							AND organization_id = :ORG
							AND effective_date <= ' || '&' || 'BIS_CURRENT_ASOF_DATE
					) c,
					(
						SELECT
							max(effective_date) AS effective_date
						FROM
							eni_dbi_item_cost_f
						WHERE
							--inventory_item_id = ' || l_item || ' Bug 5083900
							inventory_item_id = :ITEM
							--AND organization_id = ' || l_org || ' Bug 5083900
							AND organization_id = :ORG
							AND effective_date <= ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
					) p
				WHERE
					--edic.inventory_item_id = ' || l_item || ' Bug 5083900
					edic.inventory_item_id = :ITEM
					--AND edic.organization_id = ' || l_org || ' Bug 5083900
					AND edic.organization_id = :ORG
					AND
					(
						edic.effective_date = c.effective_date
						OR edic.effective_date = p.effective_date
					)
				UNION ALL
				SELECT -- part count
					SUM(NULL) AS ENI_MEASURE1, -- unit cost current
					SUM(NULL) AS ENI_MEASURE2, -- unit cost prior
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_CURRENT_ASOF_DATE
							BETWEEN trunc(effectivity_date)
							AND
							nvl(trunc(disable_date),' || '&' || 'BIS_CURRENT_ASOF_DATE + 1)
						THEN
							part_count
						ELSE
							NULL
						END
					) AS ENI_MEASURE3, -- part count current
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
							BETWEEN trunc(effectivity_date)
							AND
							nvl(trunc(disable_date),' || '&' || 'BIS_PREVIOUS_ASOF_DATE + 1)
						THEN
							part_count
						ELSE
							NULL
						END
					) AS ENI_MEASURE4, -- part count prior
					SUM(NULL) AS ENI_MEASURE5, -- mfg steps current
					SUM(NULL) AS ENI_MEASURE6, -- mfg steps prior
					SUM(NULL) AS ENI_MEASURE7, -- new change orders current
					SUM(NULL) AS ENI_MEASURE8, -- new change orders prior
					SUM(NULL) AS ENI_MEASURE9, -- open change orders current
					SUM(NULL) AS ENI_MEASURE10, -- open change orders prior
					SUM(NULL) AS ENI_MEASURE11, -- change order cycle time current
					SUM(NULL) AS ENI_MEASURE12,-- change order cycle time prior
					MAX
					(
						CASE WHEN ' || '&' || 'BIS_CURRENT_ASOF_DATE
							BETWEEN trunc(effectivity_date)
							AND
							nvl(trunc(disable_date),' || '&' || 'BIS_CURRENT_ASOF_DATE + 1)
						THEN
							max_bom_level
						ELSE
							NULL
						END
					) AS ENI_MEASURE13, -- max BOM Levels current,
					MAX
					(
						CASE WHEN ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
							BETWEEN trunc(effectivity_date)
							AND
							nvl(trunc(disable_date),' || '&' || 'BIS_PREVIOUS_ASOF_DATE + 1)
						THEN
							max_bom_level
						ELSE
							NULL
						END
					) AS ENI_MEASURE14 -- max BOM Levels prior
				FROM
					eni_dbi_part_count_mv edpc
				WHERE
					--edpc.assembly_item_id = ' || l_item_pco || ' Bug 5083900
					edpc.assembly_item_id = :ITEMPCO
					--AND edpc.organization_id =  ' || l_org_pco || ' Bug 5083900
					AND edpc.organization_id = :ORGPCO
					AND
					(
						' || '&' || 'BIS_CURRENT_ASOF_DATE
							BETWEEN trunc(effectivity_date) AND nvl(trunc(disable_date),' || '&' || 'BIS_CURRENT_ASOF_DATE + 1)
						OR
						' || '&' || 'BIS_PREVIOUS_ASOF_DATE
							BETWEEN trunc(effectivity_date) AND nvl(trunc(disable_date),' || '&' || 'BIS_PREVIOUS_ASOF_DATE + 1)
					)
				UNION ALL
				SELECT -- mfg steps
					SUM(NULL) AS ENI_MEASURE1, -- unit cost current
					SUM(NULL) AS ENI_MEASURE2, -- unit cost prior
					SUM(NULL) AS ENI_MEASURE3, -- part count current
					SUM(NULL) AS ENI_MEASURE4, -- part count prior
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_CURRENT_ASOF_DATE
							BETWEEN trunc(effectivity_date)
							AND
							nvl(trunc(disable_date),' || '&' || 'BIS_CURRENT_ASOF_DATE)
						THEN
							mfgsteps_count
						ELSE
							NULL
						END
					) AS ENI_MEASURE5, -- mfg steps current
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
							BETWEEN trunc(effectivity_date)
							AND
							nvl(trunc(disable_date),' || '&' || 'BIS_PREVIOUS_ASOF_DATE)
						THEN
							mfgsteps_count
						ELSE
							NULL
						END
					) AS ENI_MEASURE6, -- mfg steps prior
					SUM(NULL) AS ENI_MEASURE7, -- new change orders current
					SUM(NULL) AS ENI_MEASURE8, -- new change orders prior
					SUM(NULL) AS ENI_MEASURE9, -- open change orders current
					SUM(NULL) AS ENI_MEASURE10, -- open change orders prior
					SUM(NULL) AS ENI_MEASURE11, -- change order cycle time current
					SUM(NULL) AS ENI_MEASURE12, -- change order cycle time prior
					SUM(NULL) AS ENI_MEASURE13, -- max BOM Levels current
					SUM(NULL) AS ENI_MEASURE14 --  max BOM Levels prior
				FROM
					eni_dbi_mfg_steps_join_mv
				WHERE
					--item_id = ' || l_item || ' Bug 5083900
					item_id = :ITEM
					--AND organization_id = ' || l_org || ' Bug 5083900
					AND organization_id = :ORG
					AND
					(
						' || '&' || 'BIS_CURRENT_ASOF_DATE
							BETWEEN trunc(effectivity_date) AND nvl(trunc(disable_date),' || '&' || 'BIS_CURRENT_ASOF_DATE)
						OR
						' || '&' || 'BIS_PREVIOUS_ASOF_DATE
							BETWEEN trunc(effectivity_date) AND nvl(trunc(disable_date),' || '&' || 'BIS_PREVIOUS_ASOF_DATE)
					)
				UNION ALL
				SELECT -- new change orders
					SUM(NULL) AS ENI_MEASURE1, -- unit cost current
					SUM(NULL) AS ENI_MEASURE2, -- unit cost prior
					SUM(NULL) AS ENI_MEASURE3, -- part count current
					SUM(NULL) AS ENI_MEASURE4, -- part count prior
					SUM(NULL) AS ENI_MEASURE5, -- mfg steps current
					SUM(NULL) AS ENI_MEASURE6, -- mfg steps prior
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_CURRENT_ASOF_DATE = ftrs.report_date
						THEN
							new_sum
						ELSE
							NULL
						END
					) AS ENI_MEASURE7, -- new change orders current
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_PREVIOUS_ASOF_DATE = ftrs.report_date
						THEN
							new_sum
						ELSE
							NULL
						END
					) AS ENI_MEASURE8, -- new change orders prior
					SUM(NULL) AS ENI_MEASURE9, -- open change orders current
					SUM(NULL) AS ENI_MEASURE10, -- open change orders prior
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_CURRENT_ASOF_DATE = ftrs.report_date
						THEN
							cycle_time_sum
						ELSE
							NULL
						END
					)
					/
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_CURRENT_ASOF_DATE = ftrs.report_date
						THEN
							implemented_sum
						ELSE
							null
						END
					) AS ENI_MEASURE11, -- change order cycle time current
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_PREVIOUS_ASOF_DATE = ftrs.report_date
						THEN
							cycle_time_sum
						ELSE
							NULL
						END
					)
					/
					SUM
					(
						CASE WHEN ' || '&' || 'BIS_PREVIOUS_ASOF_DATE = ftrs.report_date
						THEN
							implemented_sum
						ELSE
							null
						END
					) AS ENI_MEASURE12, -- change order cycle time prior
					SUM(NULL) AS ENI_MEASURE13, -- max BOM Levels current
					SUM(NULL) AS ENI_MEASURE14 -- max BOM Levels prior
				FROM
					eni_dbi_co_sum_mv fgbm,
					fii_time_structures ftrs
				WHERE
					(
						ftrs.report_date = ' || '&' || 'BIS_CURRENT_ASOF_DATE
						OR ftrs.report_date = ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
					)
					AND fgbm.time_id(+) = ftrs.time_id
					AND fgbm.period_type_id(+) = ftrs.period_type_id
					--AND BITAND(ftrs.record_type_id, ' || l_period_bitand || ') = ' || l_period_bitand || ' Bug 5083900
					AND BITAND(ftrs.record_type_id, :PERIODAND) =  :PERIODAND --Bug 5083652
					--AND item_id = ''' || l_item || ''' Bug 5083900
					AND item_id = :ITEM
					--AND organization_id = ' || l_org || ' Bug 5083900
					AND organization_id = :ORG
					AND fgbm.status_type is null
					AND fgbm.reason_code is null
					AND fgbm.change_order_type_id is null
					AND fgbm.priority_code is null
				UNION ALL
				SELECT -- open change orders
					SUM(NULL) AS ENI_MEASURE1, -- unit cost current
					SUM(NULL) AS ENI_MEASURE2, -- unit cost prior
					SUM(NULL) AS ENI_MEASURE3, -- part count current
					SUM(NULL) AS ENI_MEASURE4, -- part count prior
					SUM(NULL) AS ENI_MEASURE5, -- mfg steps current
					SUM(NULL) AS ENI_MEASURE6, -- mfg steps prior
					SUM(NULL) AS ENI_MEASURE7, -- new change orders current
					SUM(NULL) AS ENI_MEASURE8, -- new change orders prior
					SUM
					(
						CASE WHEN
							trunc(creation_date) <= ' || '&' || 'BIS_CURRENT_ASOF_DATE AND
							(
								(
									trunc(implementation_date) IS NULL
									OR trunc(implementation_date) > ' || '&' || 'BIS_CURRENT_ASOF_DATE
								)
								AND
								(
									trunc(cancellation_date) IS NULL
									OR trunc(cancellation_date) > ' || '&' || 'BIS_CURRENT_ASOF_DATE
								)
							)
						THEN
							CNT
						ELSE
							NULL
						END
					) AS ENI_MEASURE9, -- open change orders current
					SUM
					(
						CASE WHEN
							trunc(creation_date) <= ' || '&' || 'BIS_PREVIOUS_ASOF_DATE AND
							(
								(
									trunc(implementation_date) IS NULL
									OR trunc(implementation_date) > ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
								)
								AND
								(
									trunc(cancellation_date) IS NULL
									OR trunc(cancellation_date) > ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
								)
							)
						THEN
							CNT
						ELSE
							NULL
						END
					) AS ENI_MEASURE10, -- open change orders prior
					SUM(NULL) AS ENI_MEASURE11, -- change order cycle time current
					SUM(NULL) AS ENI_MEASURE12, -- change order cycle time prior
					SUM(NULL) AS ENI_MEASURE13, -- max BOM Levels current
					SUM(NULL) AS ENI_MEASURE14 --  max BOM Levels prior
				FROM
					eni_dbi_co_dnum_mv
				WHERE
					--item_id = ''' || l_item || ''' Bug 5083900
					item_id = :ITEM
					--AND organization_id = ' || l_org || '  Bug 5083900
					AND organization_id = :ORG
					AND
					(
						(
							(
								trunc(creation_date) <= ' || '&' || 'BIS_CURRENT_ASOF_DATE
								AND
								(
									(
										trunc(implementation_date) IS NULL
										OR trunc(implementation_date) > ' || '&' || 'BIS_CURRENT_ASOF_DATE
									)
									AND
									(
										trunc(cancellation_date) IS NULL
										OR trunc(cancellation_date) > ' || '&' || 'BIS_CURRENT_ASOF_DATE
									)
								)
							)
						)
						OR
						(
							trunc(creation_date) <= ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
							AND
							(
								(
									trunc(implementation_date) IS NULL
									OR trunc(implementation_date) > ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
								)
								AND
								(
									trunc(cancellation_date) IS NULL
									OR trunc(cancellation_date) > ' || '&' || 'BIS_PREVIOUS_ASOF_DATE
								)
							)
						)
					)
			)

		';

	x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ITEM';
 l_custom_rec.attribute_value := replace(l_item,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(1) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ORG';
 l_custom_rec.attribute_value :=replace(l_org,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(2) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ITEMPCO';
 l_custom_rec.attribute_value := replace(l_item_pco,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(3) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ORGPCO';
 l_custom_rec.attribute_value :=replace(l_org_pco,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(4) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':PERIODAND';--Bug 5083652
 l_custom_rec.attribute_value := replace(l_period_bitand,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(5) := l_custom_rec;

 --Bug 5083652 -- Start Code

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODTYPE';
  l_custom_rec.attribute_value := REPLACE(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(6) := l_custom_rec;

   x_custom_output.extend;
  l_custom_rec.attribute_name := ':COMPARETYPE';
  l_custom_rec.attribute_value := REPLACE(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(7) := l_custom_rec;


  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(8) := l_custom_rec;

--Bug 5083652 -- End Code

END get_sql;
END eni_dbi_pme_kpi_pkg;

/
