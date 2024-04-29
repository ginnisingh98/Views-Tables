--------------------------------------------------------
--  DDL for Package Body OPI_DBI_SCRAP_REASON_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_SCRAP_REASON_RPT_PKG" AS
/*$Header: OPIDSBRRPTB.pls 120.0 2005/09/18 22:10 sberi noship $ */
FUNCTION GET_SCRAP_REASON_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
RETURN VARCHAR2;


/* -------------------------------------------------------------------------------------------
   Procedure Name: GET_SCRAP_REASON_SQL
   Parameters    : p_param(IN parameter), x_custom_sql (OUT parameter)
   Purpose       : This procedure calls process parameters of the OPI util package to get things
                   like MV name, aggregation flag, View By and p_param (the parameter portlet).
		   It also forms the report query by calling the function GET_SCRAP_REASON_SEL_
		   CLAUSE
----------------------------------------------------------------------------------------------
*/
PROCEDURE GET_SCRAP_REASON_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_query                     VARCHAR2(15000);
        l_view_by                   VARCHAR2(120);
        l_view_by_col               VARCHAR2 (120);
        l_xtd                       VARCHAR2(10);
	l_comparison_type           VARCHAR2(1);
        l_cur_suffix                VARCHAR2(5);
        l_custom_sql                VARCHAR2 (10000);
	l_subinv_val                VARCHAR2 (120) := NULL;
        l_col_tbl                   poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause              VARCHAR2 (2000);
	l_mv                        VARCHAR2 (30);
        l_aggregation_level_flag    VARCHAR2(10);
        l_custom_rec                BIS_QUERY_ATTRIBUTES;
	l_mv_tbl 		    poa_dbi_util_pkg.poa_dbi_mv_tbl;

	BEGIN
	-- initialization block
        l_comparison_type := 'Y';
        l_aggregation_level_flag := '0';

        -- clear out the column and Join info tables.
        l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
	l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

        -- get all the query parameters
        opi_dbi_rpt_util_pkg.process_parameters (
                                         p_param            => p_param,
                                         p_view_by          => l_view_by,
                                         p_view_by_col_name => l_view_by_col,
                                         p_comparison_type  => l_comparison_type,
                                         p_xtd              => l_xtd,
                                         p_cur_suffix       => l_cur_suffix,
                                         p_where_clause     => l_where_clause,
                                         p_mv               => l_mv,
                                         p_join_tbl         => l_join_tbl,
                                         p_mv_level_flag    => l_aggregation_level_flag,
                                         p_trend            => 'N',
                                         p_func_area        => 'OPI',
                                         p_version          => '8.0',
                                         p_role             => '',
                                         p_mv_set           => 'SBR',
                                         p_mv_flag_type     => 'TRX_REASON_LEVEL');
-- Add measure columns that need to be aggregated

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     =>'scrap_val_' || l_cur_suffix,
                                     p_alias_name   =>'scrap_val',
				     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
				     p_grand_total  => 'Y',
				     p_to_date_type => 'XTD'
				     );

      l_query := GET_SCRAP_REASON_SEL_CLAUSE (p_view_by_dim => l_view_by,
                                             p_join_tbl    => l_join_tbl)
                || ' from
              ' || poa_dbi_template_pkg.status_sql (p_fact_name           => l_mv,
                                                        p_where_clause    => l_where_clause,
                                                        p_join_tables     => l_join_tbl,
                                                    	p_use_windowing   => 'Y',
                                                    	p_col_name        => l_col_tbl,
                                                    	p_use_grpid       => 'N',
                                                    	p_paren_count     => 3,
                                                    	p_filter_where    => NULL,
                                                    	p_generate_viewby => 'Y',
                                                    	p_in_join_tables  => NULL);
	-- prepare output for bind variables
	x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
	-- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

-- Passing OPI_AGGREGATION_LEVEL_FLAGS to PMV
	l_custom_rec.attribute_name     := ':OPI_TRX_REASON_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
	x_custom_output(x_custom_output.count) := l_custom_rec;
	commit;
        x_custom_sql := l_query;
    END GET_SCRAP_REASON_SQL;

 /*
----------------------------------------------------------------------------------------------
   Function Name: GET_SCRAP_REASON_SEL_CLAUSE
   Parameters    : p_view_by_dim(IN parameter), p_join_tbl (IN parameter)
   Purpose       : This function helps in constructing the report query of the Scrap By Reason
                   Report. It defines each attribute and measure and how we would source them
		   in our query.
----------------------------------------------------------------------------------------------
*/

FUNCTION GET_SCRAP_REASON_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
RETURN VARCHAR2
IS
        l_sel_clause                VARCHAR2(15000);
        l_view_by_col_name          VARCHAR2(120);
        l_view_by_fact_col          VARCHAR2(400);
BEGIN
	      l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                    (p_view_by_dim);
	      l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                    (p_join_tbl);
         l_sel_clause :=
        'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline;

         l_sel_clause := l_sel_clause ||
			 ' OPI_MEASURE1
			  ,OPI_MEASURE2
		          ,OPI_MEASURE3
			  ,OPI_MEASURE4
		          ,OPI_MEASURE5
			  ,OPI_MEASURE6
		          ,OPI_MEASURE7'|| fnd_global.newline;

        l_sel_clause := l_sel_clause ||
	'FROM ( SELECT
		     rank() over (&ORDER_BY_CLAUSE nulls last '||', '||l_view_by_fact_col||') - 1 rnk
	           ,'||l_view_by_fact_col;

	 l_sel_clause := l_sel_clause ||
	                 ',OPI_MEASURE1
			 ,OPI_MEASURE2
		         ,OPI_MEASURE3
			 ,OPI_MEASURE4
		         ,OPI_MEASURE5
			 ,OPI_MEASURE6
		         ,OPI_MEASURE7'|| fnd_global.newline;

	 l_sel_clause := l_sel_clause ||
        'FROM ( SELECT  '  || fnd_global.newline ||
                         l_view_by_fact_col || fnd_global.newline ||
	  ',' || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'p_scrap_val',
                           p_default_val => 0) || ' OPI_MEASURE1,
           '  || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_scrap_val',
                           p_default_val => 0) || ' OPI_MEASURE2,
           '  || opi_dbi_rpt_util_pkg.change_str (
                           p_new_numerator   => 'c_scrap_val',
                           p_old_numerator   => 'p_scrap_val',
                           p_denominator     => 'p_scrap_val',
                           p_measure_name    => 'OPI_MEASURE3')|| ',
	   '  || opi_dbi_rpt_util_pkg.percent_str(
                           p_numerator      => 'c_scrap_val',
                           p_denominator    => 'c_scrap_val_total',
                           p_measure_name   => 'OPI_MEASURE4')|| ',
	   '  || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_scrap_val_total',
                           p_default_val => 0) || ' OPI_MEASURE5,
           '  || opi_dbi_rpt_util_pkg.change_str (
                           p_new_numerator   => 'c_scrap_val_total',
                           p_old_numerator   => 'p_scrap_val_total',
                           p_denominator     => 'p_scrap_val_total',
                           p_measure_name    => 'OPI_MEASURE6')|| ',
	   '  || opi_dbi_rpt_util_pkg.percent_str(
                           p_numerator      => 'c_scrap_val_total',
                           p_denominator    => 'c_scrap_val_total',
                           p_measure_name   => 'OPI_MEASURE7');

     RETURN l_sel_clause;

END GET_SCRAP_REASON_SEL_CLAUSE;

END OPI_DBI_SCRAP_REASON_RPT_PKG;

/
