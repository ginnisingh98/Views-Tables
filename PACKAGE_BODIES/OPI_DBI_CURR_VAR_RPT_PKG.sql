--------------------------------------------------------
--  DDL for Package Body OPI_DBI_CURR_VAR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_CURR_VAR_RPT_PKG" 
/*$Header: OPIDCUVRPTB.pls 120.0 2005/05/24 19:02:18 appldev noship $ */
as

 FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2, p_org in varchar2) return VARCHAR2;

 FUNCTION status_sql( p_fact_name in varchar2,
                      p_where_clause in varchar2,
		      p_join_tables in poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
                      p_use_windowing in varchar2,
                      p_col_name in poa_dbi_util_pkg.POA_DBI_COL_TBL
                     )   RETURN varchar2;

 PROCEDURE get_qty_columns(p_dim_name varchar2, p_description OUT NOCOPY varchar2, p_uom OUT NOCOPY varchar2, p_qty OUT NOCOPY varchar2);



 PROCEDURE curr_status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
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

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);
    l_org varchar(30);

    l_item_cat_flag varchar2(1) := '0';

    l_custom_rec BIS_QUERY_ATTRIBUTES;

  BEGIN

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    FOR i IN 1..p_param.COUNT
     LOOP
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
                                          'CUV',
                                          'NONE');


    -- The measure columns that need to be aggregated are
    -- STANDARD_VALUE_<b/g>, ACTUAL_VALUE_<b/g>
    -- If viewing by item as, then sum up
    -- ACTUAL_PRD_QTY
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'STANDARD_VALUE_' || l_cur_suffix,
                                 'STANDARD_VALUE');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'ACTUAL_VALUE_' || l_cur_suffix,
                                 'ACTUAL_VALUE');

    -- Quantity columns are only needed for Item viewby.
    IF (l_view_by = 'ITEM+ENI_ITEM_ORG') THEN

        poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'ACTUAL_PRD_QTY',
                                 'ACTUAL_PRD_QTY');

    END IF;


    -- construct the query
    l_query := get_status_sel_clause (l_view_by, l_org)
          || ' from ((
        ' || status_sql ('OPI_DBI_CURR_UNREC_VAR_F',
                         l_where_clause,
                         l_join_tbl,
                         'N',
                         l_col_tbl
                         );


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

  end curr_status_sql;



  FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2,  p_org in varchar2) return VARCHAR2
  IS

  l_sel_clause varchar2(4500);
  l_view_by_col_name varchar2(60);
  l_description varchar2(30);
  l_uom varchar2(30);
  l_qty varchar2(35);
  l_id varchar2(30);

  BEGIN

  /* Main Outer query */

  -- Column to get view by column name
  l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name(p_view_by_dim);

  -- Quantity column
  get_qty_columns(p_view_by_dim, l_description, l_uom, l_qty);

  l_sel_clause :=
    'SELECT
        '|| opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
         || l_view_by_col_name || ' OPI_ATTRIBUTE1,
        '|| l_description || ' 				OPI_ATTRIBUTE2,
        '|| l_uom || ' 					OPI_ATTRIBUTE3,';

 IF ((p_view_by_dim = 'ITEM+ENI_ITEM_ORG')  AND (UPPER(p_org)<>'ALL')) THEN
      l_sel_clause := l_sel_clause || ' ''pFunctionName=OPI_DBI_OPEN_JOB_DTL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'' OPI_ATTRIBUTE4 ,';
   ELSE
      l_sel_clause := l_sel_clause || 'NULL OPI_ATTRIBUTE4 ,';
   END IF;

  l_sel_clause :=   l_sel_clause || '
	oset.C_STANDARD_VALUE 				OPI_MEASURE1,
	oset.C_ACTUAL_VALUE 				OPI_MEASURE2,
	'|| l_qty || '					OPI_MEASURE3,
	oset.C_ACTUAL_VALUE - oset.C_STANDARD_VALUE 		OPI_MEASURE4,
        decode(oset.C_STANDARD_VALUE,0, to_number(null), ((oset.C_ACTUAL_VALUE - oset.C_STANDARD_VALUE)/oset.C_STANDARD_VALUE)*100)  OPI_MEASURE5,
	oset.C_STANDARD_VALUE_TOTAL 		OPI_MEASURE6,
	oset.C_ACTUAL_VALUE_TOTAL		OPI_MEASURE7,
	oset.C_ACTUAL_VALUE_TOTAL - oset.C_STANDARD_VALUE_TOTAL		OPI_MEASURE8,
	CASE WHEN oset.C_STANDARD_VALUE_TOTAL = 0 THEN to_number(NULL)
	     ELSE ((oset.C_ACTUAL_VALUE_TOTAL - oset.C_STANDARD_VALUE_TOTAL)/oset.C_STANDARD_VALUE_TOTAL)*100 END	OPI_MEASURE9 ';

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
                  p_qty := 'oset.C_ACTUAL_PRD_QTY';
                END;
          ELSE
              BEGIN
                  p_description := 'null';
                  p_uom := 'null';
                  p_qty := 'null';
              END;
      END CASE;
  END get_qty_columns;



  FUNCTION status_sql(p_fact_name in varchar2,
                      p_where_clause in varchar2,
		      p_join_tables in poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
                      p_use_windowing in varchar2,
                      p_col_name in poa_dbi_util_pkg.POA_DBI_COL_TBL
                     )   RETURN varchar2
  IS
	l_query varchar2(10000);
	l_col_names varchar2(10000);
	l_group_and_sel_clause varchar2(10000);
	l_from_clause varchar2(10000);
	l_where_clause  varchar2(10000);
        l_grpid_clause varchar2(200);
	l_compute_prior VARCHAR2(1) := 'N';
	l_compute_prev_prev VARCHAR(1) := 'N';

  BEGIN

   l_group_and_sel_clause := ' fact.' || p_join_tables(1).fact_column ;
   l_from_clause := p_join_tables(1).table_name || ' ' || p_join_tables(1).table_alias;

   l_where_clause := 'oset.' || p_join_tables(1).fact_column  || '=' ||
	p_join_tables(1).table_alias || '.' || p_join_tables(1).column_name;

   if (p_join_tables(1).dim_outer_join = 'Y') then
	l_where_clause := l_where_clause || '(+)';
   end if;

   if (p_join_tables(1).additional_where_clause is NOT NULL) then
	l_where_clause := l_where_clause || ' and ' || p_join_tables(1).additional_where_clause;
   end if;


   FOR i IN 2 .. p_join_tables.COUNT
   LOOP
	l_group_and_sel_clause := l_group_and_sel_clause || ', fact.'
		|| p_join_tables(i).fact_column;
	l_from_clause := l_from_clause || ', ' || p_join_tables(i).table_name ||
					' ' || p_join_tables(i).table_alias;


	l_where_clause := l_where_clause || ' and oset.'
		|| p_join_tables(i).fact_column  || '=' ||
		p_join_tables(i).table_alias || '.' || p_join_tables(i).column_name;
  	if (p_join_tables(i).dim_outer_join = 'Y') then
		l_where_clause := l_where_clause || '(+)';
  	end if;
  	if(p_join_tables(i).additional_where_clause is NOT NULL) then
		l_where_clause := l_where_clause || ' and ' || p_join_tables(i).additional_where_clause;
  	end if;
   END LOOP;

   FOR i IN 1 .. p_col_name.COUNT
   LOOP
      l_col_names := l_col_names || ',
		sum(' || p_col_name(i).column_name || ') c_' || p_col_name(i).column_alias;

	if(p_col_name(i).grand_total = 'Y') then
		l_col_names := l_col_names || ',
			sum(sum('
		 || p_col_name(i).column_name || ')) over () c_'
		 || p_col_name(i).column_alias || '_total ';
	end if;
   END LOOP;


   l_query := '(select ' || l_group_and_sel_clause  || l_col_names
           || '
              from ' || p_fact_name || ' fact
              where 1=1 '
           || p_where_clause;


	l_query := l_query || '
               group by ' || l_group_and_sel_clause || ') ) ) oset,
         ' || l_from_clause  || '
            where ' || l_where_clause;

   if(p_use_windowing = 'Y') then
     l_query := l_query || '
            and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)';
   end if;

   l_query := l_query || '
              &ORDER_BY_CLAUSE nulls last';

   return l_query;

  end status_sql;


end opi_dbi_curr_var_rpt_pkg;

/
