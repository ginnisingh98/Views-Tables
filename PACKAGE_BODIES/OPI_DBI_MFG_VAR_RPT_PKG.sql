--------------------------------------------------------
--  DDL for Package Body OPI_DBI_MFG_VAR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_MFG_VAR_RPT_PKG" 
/*$Header: OPIDMCVRPTB.pls 120.0 2005/05/24 17:46:20 appldev noship $ */
as

 FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2, p_period_type in VARCHAR2, p_org in VARCHAR2) return VARCHAR2;
 FUNCTION get_trend_sel_clause return VARCHAR2;
 PROCEDURE get_qty_columns(p_dim_name varchar2, p_description OUT NOCOPY varchar2, p_uom OUT NOCOPY varchar2, p_qty OUT NOCOPY varchar2);


 PROCEDURE mfg_status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS

    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_as_of_date DATE;
    l_prev_as_of_date DATE;
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1) := 'Y';
    l_nested_pattern NUMBER;
    l_cur_suffix VARCHAR2(2);
    l_custom_sql VARCHAR2 (10000);
    l_period_type VARCHAR2(255)  := NULL;
    l_org         VARCHAR2(255)  := NULL;

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);

    l_item_cat_flag varchar2(1) := '0';

    l_custom_rec BIS_QUERY_ATTRIBUTES;

  BEGIN

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

    FOR i IN 1..p_param.COUNT
     LOOP
       IF(p_param(i).parameter_name = 'PERIOD_TYPE')
        THEN  l_period_type := p_param(i).parameter_value;
       END IF;
       IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
        THEN l_org :=  p_param(i).parameter_id;
       END IF;
    END LOOP;


    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param,
                                          l_view_by,
                                          l_view_by_col,
                                          l_comparison_type,
                                          l_xtd,
                                          l_cur_suffix,
                                          l_where_clause,
                                          l_mv,
                                          l_join_tbl,
                                          l_item_cat_flag,
                                          'N',
                                          'OPI',
                                          '6.0',
                                          '',
                                          'MCV',
                                          'ITEM_CAT');

    -- The measure columns that need to be aggregated are
    -- Std_value_<b/g>, Act_value_<b/g>
    -- If viewing by item, then sum up
    -- Actual_Qty_Completed
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'Std_value_' || l_cur_suffix,
                                 'Std_value');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'Act_value_' || l_cur_suffix,
                                 'Act_value');


    -- Quantity columns are only needed for Item viewby.
    IF (l_view_by = 'ITEM+ENI_ITEM_ORG') THEN

        poa_dbi_util_pkg.add_column (l_col_tbl,
                                     'Actual_Qty_Completed',
                                     'Act_Qty_Compl');
    END IF;

    -- construct the query
    l_query := get_status_sel_clause (l_view_by, l_period_type, l_org)
          || ' from ((
        ' || poa_dbi_template_pkg.status_sql (l_mv,
                                              l_where_clause,
                                              l_join_tbl,
                                              'N',
                                              l_col_tbl,
                                              'N');

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    -- Passing OPI_ITEM_CAT_FLAG to PMV
    l_custom_rec.attribute_name := ':OPI_ITEM_CAT_FLAG';
    l_custom_rec.attribute_value := l_item_cat_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    commit;

    x_custom_sql := l_query;

  end mfg_status_sql;


  FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2, p_period_type in VARCHAR2, p_org in VARCHAR2) return VARCHAR2
  IS

   l_sel_clause varchar2(4500);
   l_view_by_col_name varchar2(60);
   l_description varchar2(30);
   l_uom varchar2(30);
   l_qty varchar2(35);

  BEGIN

  /* Main Outer query */

   -- Column to get view by column name
   l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name(p_view_by_dim);

   get_qty_columns(p_view_by_dim, l_description, l_uom, l_qty);

   l_sel_clause :=
    'SELECT
       ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
         || l_view_by_col_name || ' OPI_ATTRIBUTE1,
        '|| l_description || ' OPI_ATTRIBUTE2,
        '|| l_uom || ' OPI_ATTRIBUTE3,';

   IF ((p_view_by_dim = 'ITEM+ENI_ITEM_ORG') AND (p_period_type = 'FII_TIME_WEEK' OR p_period_type =
  'FII_TIME_ENT_PERIOD') AND (UPPER(p_org)<>'ALL')) THEN
      l_sel_clause := l_sel_clause || ' ''pFunctionName=OPI_DBI_MFG_CST_JOB_DTL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'' OPI_ATTRIBUTE4 ,';
   ELSE
      l_sel_clause := l_sel_clause || 'NULL OPI_ATTRIBUTE4 ,';
   END IF;

   l_sel_clause := l_sel_clause ||
       'oset.C_STD_VALUE 				OPI_MEASURE1,
	oset.C_ACT_VALUE 				OPI_MEASURE2,
	oset.P_STD_VALUE				OPI_MEASURE3,
	oset.P_ACT_VALUE				OPI_MEASURE4,
	'|| l_qty || '					OPI_MEASURE5,
        oset.P_ACT_VALUE - oset.P_STD_VALUE		OPI_MEASURE20,
        oset.C_ACT_VALUE - oset.C_STD_VALUE		OPI_MEASURE6,
	CASE WHEN oset.P_ACT_VALUE - oset.P_STD_VALUE = 0 THEN to_number(NULL)
             ELSE (((oset.C_ACT_VALUE - oset.C_STD_VALUE) - (oset.P_ACT_VALUE - oset.P_STD_VALUE))/ABS(oset.P_ACT_VALUE - oset.P_STD_VALUE))*100 END  OPI_MEASURE7,
        decode(oset.P_STD_VALUE, 0, to_number(null), ((oset.P_ACT_VALUE - oset.P_STD_VALUE)/oset.P_STD_VALUE)*100)    OPI_MEASURE21,
        decode(oset.C_STD_VALUE, 0, to_number(null), ((oset.C_ACT_VALUE - oset.C_STD_VALUE)/oset.C_STD_VALUE)*100)    OPI_MEASURE8,
	CASE WHEN oset.C_STD_VALUE = 0 THEN to_number(NULL)
	     WHEN oset.P_STD_VALUE = 0 THEN to_number(NULL)
	     ELSE (((oset.C_ACT_VALUE - oset.C_STD_VALUE)/oset.C_STD_VALUE)*100 - ((oset.P_ACT_VALUE - oset.P_STD_VALUE)/oset.P_STD_VALUE)*100) END  OPI_MEASURE9,
	oset.C_STD_VALUE_TOTAL          OPI_MEASURE10,
	oset.C_ACT_VALUE_TOTAL 	        OPI_MEASURE11,
        oset.C_ACT_VALUE_TOTAL - oset.C_STD_VALUE_TOTAL  OPI_MEASURE12,
	CASE WHEN oset.P_ACT_VALUE_TOTAL - oset.P_STD_VALUE_TOTAL = 0 THEN to_number(NULL)
             ELSE (((oset.C_ACT_VALUE_TOTAL - oset.C_STD_VALUE_TOTAL) - (oset.P_ACT_VALUE_TOTAL - oset.P_STD_VALUE_TOTAL))/ABS(oset.P_ACT_VALUE_TOTAL - oset.P_STD_VALUE_TOTAL))*100 END  OPI_MEASURE13,
	CASE WHEN oset.C_STD_VALUE_TOTAL = 0 THEN to_number(NULL)
	     ELSE ((oset.C_ACT_VALUE_TOTAL - oset.C_STD_VALUE_TOTAL)/oset.C_STD_VALUE_TOTAL)*100 END	OPI_MEASURE14,
	CASE WHEN oset.C_STD_VALUE_TOTAL = 0 THEN to_number(NULL)
	     WHEN oset.P_STD_VALUE_TOTAL = 0 THEN to_number(NULL)
	     ELSE ((oset.C_ACT_VALUE_TOTAL - oset.C_STD_VALUE_TOTAL)*100)/(oset.C_STD_VALUE_TOTAL) -
		  ((oset.P_ACT_VALUE_TOTAL - oset.P_STD_VALUE_TOTAL)*100)/(oset.P_STD_VALUE_TOTAL) END OPI_MEASURE15,
        decode(oset.C_STD_VALUE,0, to_number(null), ((oset.C_ACT_VALUE - oset.C_STD_VALUE)/oset.C_STD_VALUE)*100) OPI_MEASURE16,
        decode(oset.P_STD_VALUE,0, to_number(null), ((oset.P_ACT_VALUE - oset.P_STD_VALUE)/oset.P_STD_VALUE)*100) OPI_MEASURE17,
	CASE WHEN oset.C_STD_VALUE_TOTAL = 0 THEN to_number(NULL)
	     ELSE ((oset.C_ACT_VALUE_TOTAL - oset.C_STD_VALUE_TOTAL)/oset.C_STD_VALUE_TOTAL)*100 END	OPI_MEASURE18,
	CASE WHEN oset.P_STD_VALUE_TOTAL = 0 THEN to_number(NULL)
	     ELSE ((oset.P_ACT_VALUE_TOTAL - oset.P_STD_VALUE_TOTAL)/oset.P_STD_VALUE_TOTAL)*100 END	OPI_MEASURE19 ';

   return l_sel_clause;

  END get_status_sel_clause;


  PROCEDURE get_qty_columns(p_dim_name varchar2, p_description OUT NOCOPY varchar2, p_uom OUT NOCOPY varchar2, p_qty OUT NOCOPY varchar2)
  IS
   l_description varchar2(30);
   l_uom varchar2(30);
   l_qty varchar2(30);
  BEGIN
      CASE
	  WHEN p_dim_name = 'ITEM+ENI_ITEM_ORG' THEN
                BEGIN
                  p_description := 'v.description';
                  p_uom := 'v2.unit_of_measure';
                  p_qty := 'oset.C_Act_Qty_Compl';
                END;
          ELSE
              BEGIN
                  p_description := 'null';
                  p_uom := 'null';
                  p_qty := 'null';
              END;
      END CASE;
  END get_qty_columns;


  PROCEDURE mfg_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_as_of_date DATE;
    l_prev_as_of_date DATE;
    l_xtd varchar2(10);
    l_comparison_type VARCHAR2(1) := 'Y';
    l_nested_pattern NUMBER;
    l_cur_suffix VARCHAR2(2);
    l_custom_sql VARCHAR2(4000);
    l_mv VARCHAR2 (30);
    l_where_clause VARCHAR2 (4000) := '';

    l_item_cat_flag VARCHAR2(1) := '0';

    l_custom_rec BIS_QUERY_ATTRIBUTES;

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

  BEGIN

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param,
                                          l_view_by,
                                          l_view_by_col,
                                          l_comparison_type,
                                          l_xtd,
                                          l_cur_suffix,
                                          l_where_clause,
                                          l_mv,
                                          l_join_tbl,
                                          l_item_cat_flag,
                                          'Y',
                                          'OPI',
                                          '6.0',
                                          '',
                                          'MCV',
                                          'ITEM_CAT');


    -- The measure columns that need to be aggregated are
    -- Std_value_<b/g>, Act_value_<b/g>
    -- No Grand totals required.
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                'Std_value_' || l_cur_suffix,
                                'Std_value',
                                'N');
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'Act_value_' || l_cur_suffix,
                                 'Act_value',
                                 'N');


    -- Joining Outer and Inner Query
    l_query := get_trend_sel_clause ||
               ' from ' ||
               poa_dbi_template_pkg.trend_sql (
                    l_xtd,
                    l_comparison_type,
                    l_mv,
                    l_where_clause,
                    l_col_tbl,
                    'N');


    -- Prepare PMV bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- get all the basic binds used by POA queries
    -- Do this before adding any of our binds, since the procedure
    -- reinitializes the output table
    poa_dbi_util_pkg.get_custom_trend_binds (l_xtd, l_comparison_type,
                                             x_custom_output);

    -- put the custom OPI binds in
    l_custom_rec.attribute_name := ':OPI_ITEM_CAT_FLAG';
    l_custom_rec.attribute_value := l_item_cat_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    commit;

    x_custom_sql := l_query;

  END mfg_trend_sql;


  FUNCTION get_trend_sel_clause return VARCHAR2
  IS
      l_sel_clause varchar2(4000);
  BEGIN

      l_sel_clause :=
      'Select
        cal.name                                VIEWBY,
	iset.C_STD_VALUE 			OPI_MEASURE1,
	iset.C_ACT_VALUE 			OPI_MEASURE2,
	iset.P_STD_VALUE			OPI_MEASURE3,
	iset.P_ACT_VALUE			OPI_MEASURE4,
	iset.P_ACT_VALUE - iset.P_STD_VALUE 	OPI_MEASURE5,
	iset.C_ACT_VALUE - iset.C_STD_VALUE 	OPI_MEASURE6,
	CASE WHEN iset.P_ACT_VALUE - iset.P_STD_VALUE = 0 THEN to_number(NULL)
             ELSE (((iset.C_ACT_VALUE - iset.C_STD_VALUE) - (iset.P_ACT_VALUE - iset.P_STD_VALUE))/ABS(iset.P_ACT_VALUE - iset.P_STD_VALUE))*100 END  OPI_MEASURE7,
        decode(iset.P_STD_VALUE, 0, to_number(null), ((iset.P_ACT_VALUE - iset.P_STD_VALUE)/iset.P_STD_VALUE)*100) OPI_MEASURE8,
        decode(iset.C_STD_VALUE, 0, to_number(null), ((iset.C_ACT_VALUE - iset.C_STD_VALUE)/iset.C_STD_VALUE)*100) OPI_MEASURE9,
	CASE WHEN iset.C_STD_VALUE = 0 THEN to_number(NULL)
	     WHEN iset.P_STD_VALUE = 0 THEN to_number(NULL)
	     ELSE ((iset.C_ACT_VALUE - iset.C_STD_VALUE)/iset.C_STD_VALUE)*100 - ((iset.P_ACT_VALUE - iset.P_STD_VALUE)/iset.P_STD_VALUE)*100 END OPI_MEASURE10  ';

      return l_sel_clause;

  END get_trend_sel_clause ;


end opi_dbi_mfg_var_rpt_pkg;

/
