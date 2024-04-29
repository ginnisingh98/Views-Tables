--------------------------------------------------------
--  DDL for Package Body POA_DBI_NEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_NEG_PKG" 
/* $Header: poadbinegb.pls 120.12 2006/08/27 19:13:42 sriswami noship $ */
AS
  --
  FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2, p_view_by_col in VARCHAR2, p_url in VARCHAR2) return VARCHAR2;
  FUNCTION get_awd_status_sel_clause(p_view_by_dim in VARCHAR2, p_view_by_col in VARCHAR2) return VARCHAR2;
  FUNCTION get_avg_cycle_time_sel_clause(p_view_by_dim in VARCHAR2, p_view_by_col in VARCHAR2) return VARCHAR2;
  FUNCTION get_realized_status_sel_clause(p_view_by_dim in VARCHAR2, p_view_by_col in VARCHAR2) return VARCHAR2;
  FUNCTION get_awd_trend_sel_clause return VARCHAR2;
  FUNCTION get_avg_cycle_trend_sel_clause return VARCHAR2;
  FUNCTION get_prj_svng_trend_sel_clause return VARCHAR2;
  FUNCTION get_prj_ln_trend_sel_clause return VARCHAR2;
  FUNCTION get_real_svng_trend_sel_clause return VARCHAR2;
  FUNCTION get_neg_po_trend_sel_clause return VARCHAR2;
  FUNCTION get_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
  FUNCTION get_awd_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
  FUNCTION get_avg_cycle_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
  FUNCTION get_real_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
  FUNCTION get_awd_dtl_filter_clause return VARCHAR2;

/*  Procedure Name : status_sql
    This procedure returns the SQL query to display the measures such as Award Amount, Projected
    Savings Amount, Average Cycle time and their corresponding Changes. This SQL is called by the
    Sourcing Summary Report
*/

 PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
 BEGIN

  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'N'
                                      ,'NEG'
                                      , '8.0'
                                      , 'NEG'
                                      ,'NEG');

  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'award_amt_' || l_cur_suffix
                             ,'award_amt'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'current_amt_' || l_cur_suffix
                             ,'current_amt'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'proj_savings_amt_' || l_cur_suffix
                             ,'proj_savings_amt'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'preparation_time'
                             ,'preparation_time'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'bidding_time'
                             ,'bidding_time'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'analysis_time'
                             ,'analysis_time'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'award_time'
                             ,'award_time'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'c_total'
                             ,'count'
                             ,p_to_date_type => l_to_date_type);



  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'award_qty'
                               ,'award_qty'
                               ,p_to_date_type => l_to_date_type);
  end if;

  l_url := 'pFunctionName=POA_DBI_NEG_SUM_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y';

  l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_url) || ' from ' ||
                                   poa_dbi_template_pkg.status_sql(l_mv,
					l_where_clause,
					l_join_tbl,
					p_use_windowing => 'Y',
					p_col_name => l_col_tbl,
					p_use_grpid => 'N',
					p_filter_where => get_status_filter_where(l_view_by),
					p_in_join_tables => l_in_join_tbl);
  x_custom_sql := l_query;

 EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
  end;

/*  Function Name : get_status_filter_where
    This function is called by the status_sql to append a coalesce statement to the SQL query
    such that if all the measures mentioned in the list have a 0 or a null value, then that row
    will be completely filtered out of the displayed result.
 */

FUNCTION get_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_PERCENT3';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE6';

 if(p_view_by = 'ITEM+POA_ITEMS') then

    l_col_tbl.extend;
    l_col_tbl(9) := 'POA_MEASURE1';
  end if;


    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

/*  Function Name : get_status_sel_clause
    This function is called by the procedure, status_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

  FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2
                                ,p_view_by_col in VARCHAR2
                                ,p_url in VARCHAR2) return VARCHAR2 IS
  l_sel_clause varchar2(8000);
  --
  BEGIN
  --
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                            ,'8.0');
  --
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause || '
	v.description POA_ATTRIBUTE2,		--Description
        v2.description POA_ATTRIBUTE3,          --UOM
        oset.POA_MEASURE1 POA_MEASURE1,	        --Award Quantity
';
  else
    l_sel_clause := l_sel_clause || '
	null POA_ATTRIBUTE2,		--Description
        null POA_ATTRIBUTE3,            --UOM
        null POA_MEASURE1,	        --Award Quantity
';
  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2 POA_MEASURE2,		--Award Amount
	oset.POA_PERCENT1 POA_PERCENT1,		--Growth Rate
	oset.POA_MEASURE3 POA_MEASURE3,		--Current Amount
	oset.POA_MEASURE4 POA_MEASURE4,		--Projected Savings Amount
	oset.POA_PERCENT2 POA_PERCENT2,		--Change
        oset.POA_PERCENT3 POA_PERCENT3,         --Rate
	oset.POA_MEASURE5 POA_MEASURE5,         --Change
	oset.POA_MEASURE6 POA_MEASURE6,         --Average Cycle Time
	oset.POA_MEASURE7 POA_MEASURE7,         --Change
	oset.POA_MEASURE8 POA_MEASURE8,         --Grand Total Awarded Amount
	oset.POA_PERCENT4 POA_PERCENT4,         --Grand Total Growth Rate
	oset.POA_MEASURE9 POA_MEASURE9,         --Grand Total Current Amount
	oset.POA_MEASURE10 POA_MEASURE10,       --Grand Total Projected Savings Amount
	oset.POA_PERCENT5 POA_PERCENT5,         --Grand Total Change
	oset.POA_PERCENT6 POA_PERCENT6,         --Grand Total Projected Savings Rate
	oset.POA_MEASURE11 POA_MEASURE11,       --Grand Total Projected Savings Rate Change
	oset.POA_MEASURE12 POA_MEASURE12,       --Grand Total Average Cycle Time
	oset.POA_MEASURE13 POA_MEASURE13,       --Grand Total Change
	oset.POA_MEASURE14 POA_MEASURE14,       --KPI - Prior Awarded Amount
	oset.POA_MEASURE15 POA_MEASURE15,       --KPI - Prior Average Cycle Time
	oset.POA_MEASURE17 POA_MEASURE17,       --KPI - Projected Savings Amount
	oset.POA_MEASURE18 POA_MEASURE18,       --KPI - Prior Projected Savings Amount
	oset.POA_PERCENT9 POA_PERCENT9,         --KPI - Projected Savings Rate
	oset.POA_PERCENT10 POA_PERCENT10,       --KPI - Prior Projected Savings Rate
	oset.POA_MEASURE20 POA_MEASURE20,       --Grand Total - KPI - Projected Savings Amount
	oset.POA_PERCENT11 POA_PERCENT11,       --Grand Total - KPI - Projected Savings Rate
	oset.POA_MEASURE21 POA_MEASURE21,       --Grand Total - KPI - Prior Awarded Amount
	oset.POA_MEASURE22 POA_MEASURE22,       --Grand Total - KPI - Prior Average Cycle Time
	oset.POA_MEASURE23 POA_MEASURE23,       --Grand Total - KPI - Prior Projected Savings Amount
	oset.POA_PERCENT12 POA_PERCENT12        --Grand Total - KPI - Prior Projected Savings Rate
    from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE1 ';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE2,POA_PERCENT1,
                       POA_MEASURE3,POA_MEASURE4,
                       POA_PERCENT2,POA_PERCENT3,
		       POA_MEASURE5,POA_MEASURE6,
		       POA_MEASURE7,POA_MEASURE8,
		       POA_PERCENT4,POA_MEASURE9,
		       POA_MEASURE10,POA_PERCENT5,
		       POA_PERCENT6,POA_MEASURE11,
		       POA_MEASURE12,POA_MEASURE13,
                       POA_MEASURE14,POA_MEASURE15,
		       POA_MEASURE17,POA_MEASURE18,
		       POA_PERCENT9,POA_PERCENT10,
		       POA_MEASURE20,POA_PERCENT11,
		       POA_MEASURE21,POA_MEASURE22,
		       POA_MEASURE23,POA_PERCENT12
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
  --
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_award_qty,0)) POA_MEASURE1, ';
   end if;
  --
 l_sel_clause := l_sel_clause || ' nvl(c_award_amt,0) POA_MEASURE2,
                            ' || poa_dbi_util_pkg.change_clause('c_award_amt','p_award_amt') || ' POA_PERCENT1,
                             c_current_amt POA_MEASURE3,
			     c_proj_savings_amt POA_MEASURE4,
                            ' || poa_dbi_util_pkg.change_clause('c_proj_savings_amt','p_proj_savings_amt') || ' POA_PERCENT2,
                            ' || poa_dbi_util_pkg.rate_clause('c_proj_savings_amt','c_current_amt') || ' POA_PERCENT3,
                            ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_proj_savings_amt','c_current_amt'),
			                                        poa_dbi_util_pkg.rate_clause('p_proj_savings_amt','p_current_amt'),'P')  || ' POA_MEASURE5,
			    nvl((c_preparation_time + c_bidding_time + c_analysis_time + c_award_time),0)/decode(c_count,0,null,c_count) POA_MEASURE6,
                            ((nvl((c_preparation_time + c_bidding_time + c_analysis_time + c_award_time),0)/decode(c_count,0,null,c_count)) -
			          (nvl((p_preparation_time + p_bidding_time + p_analysis_time + p_award_time),0))/decode(p_count,0,null,p_count)) POA_MEASURE7,
                            nvl(c_award_amt_total,0) POA_MEASURE8,
                            ' || poa_dbi_util_pkg.change_clause('c_award_amt_total','p_award_amt_total') || ' POA_PERCENT4,
                             c_current_amt_total POA_MEASURE9,
			     c_proj_savings_amt_total POA_MEASURE10,
                            ' || poa_dbi_util_pkg.change_clause('c_proj_savings_amt_total','p_proj_savings_amt_total') || ' POA_PERCENT5,
                            ' || poa_dbi_util_pkg.rate_clause('c_proj_savings_amt_total','c_current_amt_total') || ' POA_PERCENT6,
                            ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_proj_savings_amt_total','c_current_amt_total'),
			                                        poa_dbi_util_pkg.rate_clause('p_proj_savings_amt_total','p_current_amt_total'),'P')  || ' POA_MEASURE11,
			    nvl((c_preparation_time_total + c_bidding_time_total + c_analysis_time_total + c_award_time_total),0)/decode(c_count_total,0,null,c_count_total) POA_MEASURE12,
                            ((nvl((c_preparation_time_total + c_bidding_time_total + c_analysis_time_total + c_award_time_total),0)/decode(c_count_total,0,null,c_count_total)) -
			          (nvl((p_preparation_time_total + p_bidding_time_total + p_analysis_time_total + p_award_time_total),0))/decode(p_count_total,0,null,p_count_total)) POA_MEASURE13,
                             nvl(p_award_amt,0) POA_MEASURE14,
			     nvl((p_preparation_time + p_bidding_time + p_analysis_time + p_award_time),0)/decode(p_count,0,null,p_count) POA_MEASURE15,
                             c_proj_savings_amt POA_MEASURE17,
			     p_proj_savings_amt POA_MEASURE18,
                            ' || poa_dbi_util_pkg.rate_clause('c_proj_savings_amt','c_current_amt') || ' POA_PERCENT9,
                            ' || poa_dbi_util_pkg.rate_clause('p_proj_savings_amt','p_current_amt') || ' POA_PERCENT10,
                            c_proj_savings_amt_total POA_MEASURE20,
                            ' || poa_dbi_util_pkg.rate_clause('c_proj_savings_amt_total','c_current_amt_total') || ' POA_PERCENT11,
			    nvl(p_award_amt_total,0) POA_MEASURE21,
			    nvl((p_preparation_time_total + p_bidding_time_total + p_analysis_time_total + p_award_time_total),0)/decode(p_count_total,0,null,p_count_total) POA_MEASURE22,
			    p_proj_savings_amt_total POA_MEASURE23,
                            ' || poa_dbi_util_pkg.rate_clause('p_proj_savings_amt_total','p_current_amt_total') || ' POA_PERCENT12 ';
       return l_sel_clause;
 END;
  --

/*  Procedure Name : awd_status_sql
    This procedure returns the SQL query to display the measures such as Award Amount, Projected Savings per Line,
    and their corresponding change measures. This SQL is called by the Award Summary Report.
*/

 PROCEDURE awd_status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
 BEGIN

  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'N'
                                      ,'NEG'
                                      , '8.0'
                                      , 'NEG'
                                      ,'NEG');

  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'award_amt_' || l_cur_suffix
                             ,'award_amt'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'negotiated_lines'
                             ,'negotiated_lines'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'neg_lines_with_cp'
                             ,'neg_lines_with_cp'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'proj_savings_amt_' || l_cur_suffix
                             ,'proj_savings_amt'
                             ,p_to_date_type => l_to_date_type);

  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'award_qty'
                               ,'award_qty'
                               ,p_to_date_type => l_to_date_type);
  end if;

  l_query := get_awd_status_sel_clause(l_view_by, l_view_by_col) || ' from ' ||
                                   poa_dbi_template_pkg.status_sql(l_mv,
					l_where_clause,
					l_join_tbl,
					p_use_windowing => 'Y',
					p_col_name => l_col_tbl,
					p_use_grpid => 'N',
					p_filter_where => get_awd_status_filter_where(l_view_by),
					p_in_join_tables => l_in_join_tbl);
  x_custom_sql := l_query;

 EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
  end;

/*  Function Name : get_awd_status_filter_where
    This function is called by the awd_status_sql to append a coalesce statement to the SQL query
    such that if all the measures mentioned in the list have a 0 or a null value, then that row
    will be completely filtered out of the displayed result.
 */

  FUNCTION get_awd_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_PERCENT3';

   if(p_view_by = 'ITEM+POA_ITEMS') then
     l_col_tbl.extend;
     l_col_tbl(7) := 'POA_MEASURE1';
   end if;

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;


/*  Function Name : get_awd_status_sel_clause
    This function is called by the procedure, awd_status_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

  FUNCTION get_awd_status_sel_clause(p_view_by_dim in VARCHAR2
                                    ,p_view_by_col in VARCHAR2
                                    ) return VARCHAR2 IS
  l_sel_clause varchar2(8000);
  --
  BEGIN
  --
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'NEG'
                                                            ,'8.0');
  --
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause || '
	v.description POA_ATTRIBUTE2,		--Description
        v2.description POA_ATTRIBUTE3,          --UOM
        oset.POA_MEASURE1 POA_MEASURE1,	        --Award Quantity
';
  else
    l_sel_clause := l_sel_clause || '
	null POA_ATTRIBUTE2,		--Description
        null POA_ATTRIBUTE3,            --UOM
        null POA_MEASURE1,	        --Award Quantity
';
  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2 POA_MEASURE2,		--Award Amount
	oset.POA_PERCENT1 POA_PERCENT1,		--Growth Rate
	oset.POA_MEASURE3 POA_MEASURE3,		--Negotiated Lines
	oset.POA_PERCENT2 POA_PERCENT2,		--Change
	oset.POA_MEASURE4 POA_MEASURE4,         --Projected Savings per Line
	oset.POA_PERCENT3 POA_PERCENT3,         --Change
	oset.POA_MEASURE5 POA_MEASURE5,         --Grand Total Awarded Amount
	oset.POA_PERCENT4 POA_PERCENT4,         --Grand Total Growth Rate
	oset.POA_MEASURE6 POA_MEASURE6,         --Grand Total Negotiated Lines
	oset.POA_PERCENT5 POA_PERCENT5,         --Grand Total Change
	oset.POA_MEASURE7 POA_MEASURE7,         --Grand Total Projected Savings per Line
	oset.POA_PERCENT6 POA_PERCENT6,         --Grand Total Change
	oset.POA_MEASURE8 POA_MEASURE8,         --KPI - Prior Projected Savings Amount per Line
	oset.POA_MEASURE9 POA_MEASURE9          --Grand Total - KPI - Prior Projected Savings Amount per Line
    from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE1 ';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE2,POA_PERCENT1,
                       POA_MEASURE3,POA_PERCENT2,
		       POA_MEASURE4,POA_PERCENT3,
		       POA_MEASURE5,POA_PERCENT4,
		       POA_MEASURE6,POA_PERCENT5,
		       POA_MEASURE7,POA_PERCENT6,
		       POA_MEASURE8,POA_MEASURE9
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
  --
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_award_qty,0)) POA_MEASURE1, ';
   end if;
  --
 l_sel_clause := l_sel_clause || ' nvl(c_award_amt,0) POA_MEASURE2,
                            ' || poa_dbi_util_pkg.change_clause('c_award_amt','p_award_amt') || ' POA_PERCENT1,
                             nvl(c_negotiated_lines,0) POA_MEASURE3,
                            ' || poa_dbi_util_pkg.change_clause('c_negotiated_lines','p_negotiated_lines') || ' POA_PERCENT2,
                            ' || poa_dbi_util_pkg.rate_clause('c_proj_savings_amt','c_neg_lines_with_cp','NP') || ' POA_MEASURE4,
			    ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_proj_savings_amt','c_neg_lines_with_cp','NP'),
			                                        poa_dbi_util_pkg.rate_clause('p_proj_savings_amt','p_neg_lines_with_cp','NP')) || ' POA_PERCENT3,
			     nvl(c_award_amt_total,0) POA_MEASURE5,
                            ' || poa_dbi_util_pkg.change_clause('c_award_amt_total','p_award_amt_total') || ' POA_PERCENT4,
                             nvl(c_negotiated_lines_total,0) POA_MEASURE6,
                            ' || poa_dbi_util_pkg.change_clause('c_negotiated_lines_total','p_negotiated_lines_total') || ' POA_PERCENT5,
                            ' || poa_dbi_util_pkg.rate_clause('c_proj_savings_amt_total','c_neg_lines_with_cp_total','NP') || ' POA_MEASURE7,
			    ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_proj_savings_amt_total','c_neg_lines_with_cp_total','NP'),
			                                        poa_dbi_util_pkg.rate_clause('p_proj_savings_amt_total','p_neg_lines_with_cp_total','NP')) || ' POA_PERCENT6,
                            ' || poa_dbi_util_pkg.rate_clause('p_proj_savings_amt','p_neg_lines_with_cp','NP') || ' POA_MEASURE8,
                            ' || poa_dbi_util_pkg.rate_clause('p_proj_savings_amt_total','p_neg_lines_with_cp_total','NP') || ' POA_MEASURE9 ';
       return l_sel_clause;
 END;

/*  Procedure Name : avg_cycle_time_sql
    This procedure returns the SQL query to display the measures such as Average Cycle Time and it's
    phases such as Preparation Time, Bidding Time and Award and Analysis Time. It also displays the
    Negotiation Line Count.
*/

 PROCEDURE avg_cycle_time_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
 BEGIN

  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'N'
                                      ,'NEG'
                                      , '8.0'
                                      , 'NEG'
                                      ,'NEG');

  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'c_total'
                             ,'count'
                             ,p_to_date_type => l_to_date_type
			     ,p_prior_code => 1);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'preparation_time'
                             ,'preparation_time'
                             ,p_to_date_type => l_to_date_type
     			     ,p_prior_code => 1);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'bidding_time'
                             ,'bidding_time'
                             ,p_to_date_type => l_to_date_type
     			     ,p_prior_code => 1);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'analysis_time'
                             ,'analysis_time'
                             ,p_to_date_type => l_to_date_type
     			     ,p_prior_code => 1);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'award_time'
                             ,'award_time'
                             ,p_to_date_type => l_to_date_type
     			     ,p_prior_code => 1);
  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'award_qty'
                               ,'award_qty'
                               ,p_to_date_type => l_to_date_type
      			       ,p_prior_code => 1);
  end if;

  l_query := get_avg_cycle_time_sel_clause(l_view_by, l_view_by_col) || ' from ' ||
                                   poa_dbi_template_pkg.status_sql(l_mv,
					l_where_clause,
					l_join_tbl,
					p_use_windowing => 'Y',
					p_col_name => l_col_tbl,
					p_use_grpid => 'N',
					p_filter_where => get_avg_cycle_filter_where(l_view_by),
					p_in_join_tables => l_in_join_tbl);
  x_custom_sql := l_query;

 EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
  end;

/*  Function Name : get_avg_cycle_filter_where
    This function is called by the avg_cycle_time_sql to append a coalesce statement to the SQL query
    such that if all the measures mentioned in the list have a 0 or a null value, then that row
    will be completely filtered out of the displayed result.
 */

  FUNCTION get_avg_cycle_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE6';
   if(p_view_by = 'ITEM+POA_ITEMS') then
     l_col_tbl.extend;
     l_col_tbl(6) := 'POA_MEASURE1';
   end if;

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;

/*  Function Name : get_avg_cycle_time_sel_clause
    This function is called by the procedure, avg_cycle_time_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

  FUNCTION get_avg_cycle_time_sel_clause(p_view_by_dim in VARCHAR2
                                    ,p_view_by_col in VARCHAR2
                                    ) return VARCHAR2 IS
  l_sel_clause varchar2(8000);
  --
  BEGIN
  --
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'NEG'
                                                            ,'8.0');
  --
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause || '
	v.description POA_ATTRIBUTE2,		--Description
        v2.description POA_ATTRIBUTE3,          --UOM
        oset.POA_MEASURE1 POA_MEASURE1,	        --Award Quantity
';
  else
    l_sel_clause := l_sel_clause || '
	null POA_ATTRIBUTE2,		--Description
        null POA_ATTRIBUTE3,            --UOM
        null POA_MEASURE1,	        --Award Quantity
';
  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2 POA_MEASURE2,		--Negotiated Lines including RFI
        oset.POA_MEASURE3 POA_MEASURE3,         --Preparation Time
        oset.POA_MEASURE4 POA_MEASURE4,         --Bidding Time
        oset.POA_MEASURE5 POA_MEASURE5,         --Analysis Award Time
        oset.POA_MEASURE6 POA_MEASURE6,         --Total Time
	';
    IF (p_view_by_dim = 'SUPPLIER+POA_SUPPLIERS') THEN
      l_sel_clause := l_sel_clause || '
        NULL POA_MEASURE7,         --Grand Total Negotiated Lines including RFI
        NULL POA_MEASURE8,         --Grand Total Preparation Time
        NULL POA_MEASURE9,         --Grand Total Bidding Time
        NULL POA_MEASURE10,       --Grand Total Analysis and Award Time
        NULL POA_MEASURE11        --Grand Total Total Time
      ';
    ELSE
      l_sel_clause := l_sel_clause || '
        oset.POA_MEASURE7 POA_MEASURE7,         --Grand Total Negotiated Lines including RFI
        oset.POA_MEASURE8 POA_MEASURE8,         --Grand Total Preparation Time
        oset.POA_MEASURE9 POA_MEASURE9,         --Grand Total Bidding Time
        oset.POA_MEASURE10 POA_MEASURE10,       --Grand Total Analysis and Award Time
        oset.POA_MEASURE11 POA_MEASURE11        --Grand Total Total Time
     ';
    END IF;
   l_sel_clause := l_sel_clause || ' from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE1 ';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE2,POA_MEASURE3,
                       POA_MEASURE4,POA_MEASURE5,
		       POA_MEASURE6,POA_MEASURE7,
		       POA_MEASURE8,POA_MEASURE9,
		       POA_MEASURE10,POA_MEASURE11
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
  --
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_award_qty,0)) POA_MEASURE1, ';
   end if;
  --
 l_sel_clause := l_sel_clause || ' c_count POA_MEASURE2,
                            ' || poa_dbi_util_pkg.rate_clause('c_preparation_time','c_count','NP') || ' POA_MEASURE3,
			    ' || poa_dbi_util_pkg.rate_clause('c_bidding_time','c_count','NP') || ' POA_MEASURE4,
			    ' || poa_dbi_util_pkg.rate_clause('(c_analysis_time + c_award_time)','c_count','NP') || ' POA_MEASURE5,
		              nvl((c_preparation_time + c_bidding_time + c_analysis_time+ c_award_time),0)/decode(c_count,0,null,c_count) POA_MEASURE6,
			      nvl(c_count_total,0) POA_MEASURE7,
			    ' || poa_dbi_util_pkg.rate_clause('c_preparation_time_total','c_count_total','NP') || ' POA_MEASURE8,
			    ' || poa_dbi_util_pkg.rate_clause('c_bidding_time_total','c_count_total','NP') || ' POA_MEASURE9,
			    ' || poa_dbi_util_pkg.rate_clause('(c_analysis_time_total + c_award_time_total)','c_count_total','NP') || ' POA_MEASURE10,
		              nvl((c_preparation_time_total + c_bidding_time_total + c_analysis_time_total + c_award_time_total),0)/decode(c_count_total,0,null,c_count_total) POA_MEASURE11 ';
       return l_sel_clause;
 END;

/*  Procedure Name : realized_status_sql
    This procedure returns the SQL query to display the measures such as Realized Savings, Negotiated
    Amount, Non-Negotiated Amount and Percent Purchases Negotiated.
*/

 PROCEDURE realized_status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
 BEGIN

  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'N'
                                      ,'PO'
                                      , '8.0'
                                      , 'PO'
                                      ,'POD');

  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'real_svngs_amt_' || l_cur_suffix
                             ,'real_svngs_amt'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'purchase_amt_' || l_cur_suffix
                             ,'purchase_amt'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'neg_purchase_amt_' || l_cur_suffix
                             ,'neg_purchase_amt'
                             ,p_to_date_type => l_to_date_type);

  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'quantity'
                               ,'quantity'
                               ,p_to_date_type => l_to_date_type);
  end if;


  l_query := get_realized_status_sel_clause(l_view_by, l_view_by_col) || ' from ' ||
                                   poa_dbi_template_pkg.status_sql(l_mv,
					l_where_clause,
					l_join_tbl,
					p_use_windowing => 'Y',
					p_col_name => l_col_tbl,
					p_use_grpid => 'N',
					p_filter_where => get_real_status_filter_where(l_view_by),
					p_in_join_tables => l_in_join_tbl);
  x_custom_sql := l_query;

 EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
  end;

/*  Function Name : get_real_status_filter_where
    This function is called by the realized_status_sql to append a coalesce statement to the SQL query
    such that if all the measures mentioned in the list have a 0 or a null value, then that row
    will be completely filtered out of the displayed result.
 */

FUNCTION get_real_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_PERCENT3';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_PERCENT4';
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_PERCENT5';
    l_col_tbl.extend;
    l_col_tbl(9) := 'POA_MEASURE5';

 if(p_view_by = 'ITEM+POA_ITEMS') then
    l_col_tbl.extend;
    l_col_tbl(10) := 'POA_MEASURE1';
  end if;


    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

/*  Function Name : get_realized_status_sel_clause
    This function is called by the procedure, realized_status_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

  FUNCTION get_realized_status_sel_clause(p_view_by_dim in VARCHAR2
                                         ,p_view_by_col in VARCHAR2
                                         ) return VARCHAR2 IS
  l_sel_clause varchar2(8000);
  --
  BEGIN
  --
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                            ,'8.0');
  --
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause || '
	v.description POA_ATTRIBUTE1,		--Description
        v2.description POA_ATTRIBUTE2,          --UOM
        oset.POA_MEASURE1 POA_MEASURE1,	        --Award Quantity
';
  else
    l_sel_clause := l_sel_clause || '
	null POA_ATTRIBUTE2,		--Description
        null POA_ATTRIBUTE3,            --UOM
        null POA_MEASURE1,	        --Award Quantity
';
  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2 POA_MEASURE2,		--Realized Savings Amount
	oset.POA_PERCENT1 POA_PERCENT1,		--Change
	oset.POA_PERCENT2 POA_PERCENT2,		--Rate
	oset.POA_MEASURE3 POA_MEASURE3,		--PO Amount
	oset.POA_PERCENT3 POA_PERCENT3,		--Change
	oset.POA_MEASURE4 POA_MEASURE4,		--Negotiated Purchases Amount
	oset.POA_PERCENT4 POA_PERCENT4,		--Change
	oset.POA_PERCENT5 POA_PERCENT5,		--Percent Purchases Negotiated
	oset.POA_MEASURE5 POA_MEASURE5,		--Change
	oset.POA_MEASURE6 POA_MEASURE6,		--Grand Total Realized Savings Amount
	oset.POA_PERCENT6 POA_PERCENT6,		--Grand Total Change
	oset.POA_PERCENT7 POA_PERCENT7,		--Grand Total Rate
	oset.POA_MEASURE7 POA_MEASURE7,		--Grand Total PO Amount
	oset.POA_PERCENT8 POA_PERCENT8,		--Grand Total Change
	oset.POA_MEASURE8 POA_MEASURE8,		--Grand Total Negotiated Purchases Amount
	oset.POA_PERCENT9 POA_PERCENT9,		--Grand Total Change
	oset.POA_PERCENT10 POA_PERCENT10,	--Grand Total Percent Purchases Negotiated
	oset.POA_MEASURE9 POA_MEASURE9,		--Grand Total Change
	oset.POA_PERCENT11 POA_PERCENT11,       --KPI - Prior Percent Purchases Negotiated
        oset.POA_MEASURE11 POA_MEASURE11,       --KPI - Prior Total PO Amount
	oset.POA_MEASURE12 POA_MEASURE12,       --KPI - Realized Savings Amount
	oset.POA_MEASURE13 POA_MEASURE13,       --KPI - Prior Realized Savings Amount
	oset.POA_MEASURE14 POA_MEASURE14,       --Grand Total - KPI - Realized Savings Amount
	oset.POA_PERCENT14 POA_PERCENT14,       --Grand Total - KPI - Prior Percent Purchases Negotiated
        oset.POA_MEASURE15 POA_MEASURE15,       --Grand Total - KPI - Prior Total PO Amount
	oset.POA_MEASURE16 POA_MEASURE16,       --Grand Total - KPI - Prior Realized Savings Amount
        oset.POA_MEASURE2 POA_MEASURE17,        --Realized Savings Amount in Portlet
	oset.POA_MEASURE6 POA_MEASURE18         --Grand Total - Realized Savings Amount
    from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE1 ';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE2,POA_PERCENT1,
                       POA_PERCENT2,POA_MEASURE3,
		       POA_PERCENT3,POA_MEASURE4,
		       POA_PERCENT4,POA_PERCENT5,
		       POA_MEASURE5,POA_MEASURE6,
		       POA_PERCENT6,POA_PERCENT7,
		       POA_MEASURE7,POA_PERCENT8,
		       POA_MEASURE8,POA_PERCENT9,
		       POA_PERCENT10,POA_MEASURE9,
                       POA_PERCENT11,POA_MEASURE11,
		       POA_MEASURE12,POA_MEASURE13,
		       POA_MEASURE14,POA_PERCENT14,
		       POA_MEASURE15,POA_MEASURE16
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
  --
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_quantity,0)) POA_MEASURE1, ';
   end if;
  --
 l_sel_clause := l_sel_clause || ' c_real_svngs_amt POA_MEASURE2,
                            ' || poa_dbi_util_pkg.change_clause('c_real_svngs_amt','p_real_svngs_amt') || ' POA_PERCENT1,
                            ' || poa_dbi_util_pkg.rate_clause('c_real_svngs_amt','c_purchase_amt','P') || ' POA_PERCENT2,
			    nvl(c_purchase_amt,0) POA_MEASURE3,
                            ' || poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_PERCENT3,
			    nvl(c_neg_purchase_amt,0) POA_MEASURE4,
			    ' || poa_dbi_util_pkg.change_clause('c_neg_purchase_amt','p_neg_purchase_amt') || ' POA_PERCENT4,
			    ' || poa_dbi_util_pkg.rate_clause('c_neg_purchase_amt','c_purchase_amt') || ' POA_PERCENT5,
			    ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_neg_purchase_amt','c_purchase_amt'),
			                                        poa_dbi_util_pkg.rate_clause('p_neg_purchase_amt','p_purchase_amt'),
								'P') || ' POA_MEASURE5,
                             c_real_svngs_amt_total POA_MEASURE6,
                            ' || poa_dbi_util_pkg.change_clause('c_real_svngs_amt_total','p_real_svngs_amt_total') || ' POA_PERCENT6,
                            ' || poa_dbi_util_pkg.rate_clause('c_real_svngs_amt_total','c_purchase_amt_total','P') || ' POA_PERCENT7,
			    nvl(c_purchase_amt_total,0) POA_MEASURE7,
                            ' || poa_dbi_util_pkg.change_clause('c_purchase_amt_total','p_purchase_amt_total') || ' POA_PERCENT8,
			    nvl(c_neg_purchase_amt_total,0) POA_MEASURE8,
			    ' || poa_dbi_util_pkg.change_clause('c_neg_purchase_amt_total','p_neg_purchase_amt_total') || ' POA_PERCENT9,
			    ' || poa_dbi_util_pkg.rate_clause('c_neg_purchase_amt_total','c_purchase_amt_total') || ' POA_PERCENT10,
			    ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_neg_purchase_amt_total','c_purchase_amt_total'),
			                                        poa_dbi_util_pkg.rate_clause('p_neg_purchase_amt_total','p_purchase_amt_total'),
								'P') || ' POA_MEASURE9,
			    ' || poa_dbi_util_pkg.rate_clause('p_neg_purchase_amt','p_purchase_amt') || ' POA_PERCENT11,
			    nvl(p_purchase_amt,0) POA_MEASURE11,
                            c_real_svngs_amt POA_MEASURE12,
			    p_real_svngs_amt POA_MEASURE13,
                            c_real_svngs_amt_total POA_MEASURE14,
			    ' || poa_dbi_util_pkg.rate_clause('p_neg_purchase_amt_total','p_purchase_amt_total') || ' POA_PERCENT14,
			    nvl(p_purchase_amt_total,0) POA_MEASURE15,
			    p_real_svngs_amt_total POA_MEASURE16
			    ';

       return l_sel_clause;
 END;
  --

/*  Procedure Name : awd_trend_sql
    This procedure returns the SQL query to display the awarded amount as a trend.
*/

  PROCEDURE awd_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'Y'
                                      ,'NEG'
                                      ,'8.0'
                                      ,'NEG'
                                      ,'NEG');

  poa_dbi_util_pkg.add_column(l_col_tbl, 'award_amt_' || l_cur_suffix, 'award_amt','N',3,p_to_date_type => l_to_date_type);

  l_query := get_awd_trend_sel_clause || '
                    from '
                    || poa_dbi_template_pkg.trend_sql(
                        l_xtd,
                        l_comparison_type,
                        l_mv,
                        l_where_clause,
                        l_col_tbl,
			p_use_grpid => 'N',
                        p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

 END;

/*  Function Name : get_awd_trend_sel_clause
    This function is called by the procedure, awd_trend_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

 FUNCTION get_awd_trend_sel_clause return VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN
  l_sel_clause := 'select cal.name VIEWBY,';
  l_sel_clause := l_sel_clause || '
	    nvl(c_award_amt,0) POA_MEASURE1,
	    nvl(p_award_amt,0) POA_MEASURE2,
	    ' || poa_dbi_util_pkg.change_clause('c_award_amt','p_award_amt') || ' POA_PERCENT1 ';
  return l_sel_clause;
 END;
  --

/*  Procedure Name : avg_cycle_trend_sql
    This procedure returns the SQL query to display the average cycle time measures as a trend.
*/

  PROCEDURE avg_cycle_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'Y'
                                      ,'NEG'
                                      ,'8.0'
                                      ,'NEG'
                                      ,'NEG');

  poa_dbi_util_pkg.add_column(l_col_tbl, 'preparation_time', 'preparation_time','N',3,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl, 'bidding_time', 'bidding_time','N',3,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl, 'analysis_time', 'analysis_time','N',3,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl, 'award_time', 'award_time','N',3,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl, 'c_total', 'count','N',3,p_to_date_type => l_to_date_type);

  l_query := get_avg_cycle_trend_sel_clause || '
                    from '
                    || poa_dbi_template_pkg.trend_sql(
                        l_xtd,
                        l_comparison_type,
                        l_mv,
                        l_where_clause,
                        l_col_tbl,
			p_use_grpid => 'N',
                        p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

 END;

/*  Function Name : get_avg_cycle_trend_sel_clause
    This function is called by the procedure, avg_cycle_trend_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

 FUNCTION get_avg_cycle_trend_sel_clause return VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN
  l_sel_clause := 'select cal.name VIEWBY,';
  l_sel_clause := l_sel_clause || '
                   nvl((c_preparation_time + c_bidding_time + c_analysis_time + c_award_time),0)/decode(c_count,0,null,c_count) POA_MEASURE1,
                   ((nvl((c_preparation_time + c_bidding_time + c_analysis_time + c_award_time),0)/decode(c_count,0,null,c_count)) -
		        (nvl((p_preparation_time + p_bidding_time + p_analysis_time + p_award_time),0)/decode(p_count,0,null,p_count))) POA_MEASURE2,
                   nvl((p_preparation_time + p_bidding_time + p_analysis_time + p_award_time),0)/decode(p_count,0,null,p_count) POA_MEASURE3 ';
  return l_sel_clause;
 END;
--

/*  Procedure Name : prj_svng_trend_sql
    This procedure returns the SQL query to display the Projected Savings measures as a trend.
*/

  PROCEDURE prj_svng_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'Y'
                                      ,'NEG'
                                      ,'8.0'
                                      ,'NEG'
                                      ,'NEG');

  poa_dbi_util_pkg.add_column(l_col_tbl, 'proj_savings_amt_' || l_cur_suffix, 'proj_savings_amt','N',3,p_to_date_type => l_to_date_type);

  l_query := get_prj_svng_trend_sel_clause || '
                    from '
                    || poa_dbi_template_pkg.trend_sql(
                        l_xtd,
                        l_comparison_type,
                        l_mv,
                        l_where_clause,
                        l_col_tbl,
			p_use_grpid => 'N',
                        p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

 END;

/*  Function Name : get_prj_svng_trend_sel_clause
    This function is called by the procedure, prj_svng_trend_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

 FUNCTION get_prj_svng_trend_sel_clause return VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN
  l_sel_clause := 'select cal.name VIEWBY,';
  l_sel_clause := l_sel_clause || '
	    c_proj_savings_amt POA_MEASURE1,
	    p_proj_savings_amt POA_MEASURE2,
	    ' || poa_dbi_util_pkg.change_clause('c_proj_savings_amt','p_proj_savings_amt') || ' POA_PERCENT1 ';
  return l_sel_clause;
 END;
  --

/*  Procedure Name : prj_svng_ln_trend_sql
    This procedure returns the SQL query to display the Projected Savings per Line measures as a trend.
    It also displays the Negotiation Lines count used to derive at the Savings per Line measure.
*/

  PROCEDURE prj_svng_ln_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'Y'
                                      ,'NEG'
                                      ,'8.0'
                                      ,'NEG'
                                      ,'NEG');

  poa_dbi_util_pkg.add_column(l_col_tbl, 'proj_savings_amt_' || l_cur_suffix, 'proj_savings_amt','N',3,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl, 'neg_lines_with_cp', 'neg_lines_with_cp','N',3,p_to_date_type => l_to_date_type);

  l_query := get_prj_ln_trend_sel_clause || '
                    from '
                    || poa_dbi_template_pkg.trend_sql(
                        l_xtd,
                        l_comparison_type,
                        l_mv,
                        l_where_clause,
                        l_col_tbl,
			p_use_grpid => 'N',
                        p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

 END;

/*  Function Name : get_prj_ln_trend_sel_clause
    This function is called by the procedure, prj_svng_ln_trend_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

 FUNCTION get_prj_ln_trend_sel_clause return VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN
  l_sel_clause := 'select cal.name VIEWBY,';
  l_sel_clause := l_sel_clause || '
              nvl(c_neg_lines_with_cp,0) POA_MEASURE1,
	    ' || poa_dbi_util_pkg.change_clause('c_neg_lines_with_cp','p_neg_lines_with_cp') || ' POA_PERCENT1,
            ' || poa_dbi_util_pkg.rate_clause('c_proj_savings_amt','c_neg_lines_with_cp','NP') || ' POA_MEASURE2,
            ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_proj_savings_amt','c_neg_lines_with_cp','NP'),
			                        poa_dbi_util_pkg.rate_clause('p_proj_savings_amt','p_neg_lines_with_cp','NP')) || ' POA_PERCENT2,
            nvl(p_neg_lines_with_cp,0) POA_MEASURE3,
            ' || poa_dbi_util_pkg.rate_clause('p_proj_savings_amt','p_neg_lines_with_cp','NP') || ' POA_MEASURE4 ';
  return l_sel_clause;
 END;
  --

/*  Procedure Name : real_svng_trend_sql
    This procedure returns the SQL query to display the Realized Savings measure as a trend
*/

  PROCEDURE real_svng_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'Y'
                                      ,'PO'
                                      ,'8.0'
                                      ,'PO'
                                      ,'POD');

  poa_dbi_util_pkg.add_column(l_col_tbl, 'real_svngs_amt_' || l_cur_suffix, 'real_svngs_amt','N',3,p_to_date_type => l_to_date_type);

  l_query := get_real_svng_trend_sel_clause || '
                    from '
                    || poa_dbi_template_pkg.trend_sql(
                        l_xtd,
                        l_comparison_type,
                        l_mv,
                        l_where_clause,
                        l_col_tbl,
			p_use_grpid => 'N',
                        p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

 END;

/*  Function Name : get_real_svng_trend_sel_clause
    This function is called by the procedure, real_svng_trend_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

 FUNCTION get_real_svng_trend_sel_clause return VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN
  l_sel_clause := 'select cal.name VIEWBY,';
  l_sel_clause := l_sel_clause || '
	    c_real_svngs_amt POA_MEASURE1,
	    p_real_svngs_amt POA_MEASURE2,
	    ' || poa_dbi_util_pkg.change_clause('c_real_svngs_amt','p_real_svngs_amt') || ' POA_PERCENT1 ';
  return l_sel_clause;
 END;
  --

/*  Procedure Name : neg_po_trend_sql
    This procedure returns the SQL query to display the Negotiated and Non-Negotiated Purchases Trend
*/

  PROCEDURE neg_po_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) :='Y';
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(10000);
  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.process_parameters(p_param
                                      ,l_view_by
                                      ,l_view_by_col
                                      ,l_view_by_value
                                      ,l_comparison_type
                                      ,l_xtd
                                      ,l_as_of_date
                                      ,l_prev_as_of_date
                                      ,l_cur_suffix
                                      ,l_nested_pattern
                                      ,l_where_clause
                                      ,l_mv
                                      ,l_join_tbl
                                      ,l_in_join_tbl
				      , x_custom_output
                                      ,'Y'
                                      ,'PO'
                                      ,'8.0'
                                      ,'PO'
                                      ,'POD');

  poa_dbi_util_pkg.add_column(l_col_tbl, 'neg_purchase_amt_' || l_cur_suffix, 'neg_purchase_amt','N',3,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt','N',3,p_to_date_type => l_to_date_type);

  l_query := get_neg_po_trend_sel_clause || '
                    from '
                    || poa_dbi_template_pkg.trend_sql(
                        l_xtd,
                        l_comparison_type,
                        l_mv,
                        l_where_clause,
                        l_col_tbl,
			p_use_grpid => 'N',
                        p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

 END;

/*  Function Name : get_neg_po_trend_sel_clause
    This function is called by the procedure, neg_po_trend_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

 FUNCTION get_neg_po_trend_sel_clause return VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN
  l_sel_clause := 'select cal.name VIEWBY,';
  l_sel_clause := l_sel_clause || '
            nvl(c_neg_purchase_amt,0) POA_MEASURE1,
	    ' || poa_dbi_util_pkg.change_clause('c_neg_purchase_amt','p_neg_purchase_amt') || ' POA_PERCENT1,
	    (nvl(c_purchase_amt,0) - nvl(c_neg_purchase_amt,0)) POA_MEASURE2,
            (((nvl(c_purchase_amt,0) - nvl(c_neg_purchase_amt,0)) - (nvl(p_purchase_amt,0) - nvl(p_neg_purchase_amt,0))) /
	     decode((nvl(p_purchase_amt,0) - nvl(p_neg_purchase_amt,0)), 0, null, (nvl(p_purchase_amt,0) - nvl(p_neg_purchase_amt,0))) * 100) POA_PERCENT2,
            ' || poa_dbi_util_pkg.rate_clause('p_neg_purchase_amt','p_purchase_amt') || ' POA_PERCENT4,
            ' || poa_dbi_util_pkg.rate_clause('c_neg_purchase_amt','c_purchase_amt') || ' POA_PERCENT3,
	    ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_neg_purchase_amt','c_purchase_amt'),
                                                poa_dbi_util_pkg.rate_clause('p_neg_purchase_amt','p_purchase_amt'),
						'P') || ' POA_MEASURE3,
	    nvl(c_neg_purchase_amt,0) POA_MEASURE4,
            (nvl(c_purchase_amt,0) - nvl(c_neg_purchase_amt,0)) POA_MEASURE5 ';
  return l_sel_clause;
 END;


/*  Procedure Name : dtl_sql
    This procedure returns the SQL query to display the Awarded and Completed Negotiation Lines detail.
*/

 PROCEDURE  dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(32000);
  l_cur_suffix          varchar2(2);
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_filter_rfi          VARCHAR2(400);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_number      NUMBER;
  l_to_date_type        VARCHAR2(10);
BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_to_date_type := 'XTD';
  poa_dbi_sutil_pkg.drill_process_parameters(
                        p_param,
                        l_cur_suffix,
                        l_where_clause,
                        l_in_join_tbl,
                        'NEG',
                        '8.0',
                        'NEG',
                        'NEG'
                      );

FOR i IN 1..p_param.COUNT
LOOP
    IF (p_param(i).parameter_name = 'POA_ATTRIBUTE13') THEN
      l_context_number := p_param(i).parameter_id;
    END IF;
END LOOP;

IF (l_context_number = 1) THEN
  l_filter_rfi := ' AND fact.award_status not in (''NO'', ''QUALIFIED'')
                    AND fact.award_complete_date IS NOT NULL ';
ELSE
  l_filter_rfi := ' AND fact.award_status <> ''NO'' ';
END IF;

l_query :=
'SELECT
  ponh.document_number POA_ATTRIBUTE2,
  ponip.disp_line_number POA_ATTRIBUTE3,
  item.value POA_ATTRIBUTE4,
  negorg.name POA_ATTRIBUTE5,
  doctl.name POA_ATTRIBUTE6,
  hrv.value POA_ATTRIBUTE7,
  supv.value POA_ATTRIBUTE8,
  decode(i.contract_type, ''BLANKET'', ''Blanket Agreement'',''STANDARD'', ''Standard PO'',''CONTRACT'',''Contract Agreement'' ) POA_ATTRIBUTE9,
  poh.segment1 POA_ATTRIBUTE10,
  uom.description POA_ATTRIBUTE11,
  i.POA_MEASURE1 POA_MEASURE1,
  i.POA_MEASURE2 POA_MEASURE2,
  i.POA_MEASURE3 POA_MEASURE3,
  ''pFunctionName=POA_DBI_NEG_DRILL&AuctionId=''||i.auction_header_id||''&addBreadCrumb=Y&retainAM=Y'' POA_ATTRIBUTE14,
  decode(i.po_header_id, null, null,
    decode(poh.authorization_status,''APPROVED'',
      ''pFunctionName=POA_DBI_ISP_DRILL&PoHeaderId=''||i.po_header_id||''&addBreadCrumb=Y&retainAM=Y'',
      ''pFunctionName=POA_DBI_PDF_DRILL&DocumentId='' || i.po_header_id || ''&RevisionNum=''
		        || poh.revision_num || ''&LanguageCode='' || userenv(''LANG'') || ''&DocumentType=PO&DocumentSubtype=STANDARD&OrgId='' || poh.org_id
			|| ''&UserSecurity=Y&StoreFlag=N&ViewOrCommunicate=View&CallFromForm=N''
          )) POA_ATTRIBUTE15,
  i.POA_ATTRIBUTE16 POA_ATTRIBUTE16,
  i.POA_ATTRIBUTE17 POA_ATTRIBUTE17
FROM
(
SELECT
(rank() over(&ORDER_BY_CLAUSE nulls last, auction_header_id, auction_line_number,
              bid_number, bid_line_number, org_id, po_item_id, base_uom)) - 1 rnk,
  auction_header_id,
  auction_line_number,
  bid_number,
  bid_line_number,
  doctype_id,
  po_item_id,
  org_id,
  negotiation_creator_id,
  supplier_id,
  POA_MEASURE1,
  POA_MEASURE2,
  POA_MEASURE3,
  contract_type,
  po_header_id,
  base_uom,
  POA_ATTRIBUTE16,
  POA_ATTRIBUTE17
  FROM
(SELECT
  fact.auction_header_id,
  fact.auction_header_id POA_ATTRIBUTE2,
  fact.auction_line_number,
  fact.bid_number,
  fact.bid_line_number,
  fact.doctype_id,
  fact.po_item_id,
  fact.org_id,
  fact.negotiation_creator_id,
  fact.supplier_id,
  sum(fact.award_qty) POA_MEASURE1,
  sum(fact.award_amount_' || l_cur_suffix || ') POA_MEASURE2, -- Add currency suffix
  sum(sum(fact.award_amount_' || l_cur_suffix || ')) over() POA_MEASURE3,
  fact.contract_type,
  fact.po_header_id,
  fact.base_uom,
  fact.auction_creation_date POA_ATTRIBUTE16, -- Add creation date
  nvl(fact.rfi_complete_date,fact.award_complete_date) POA_ATTRIBUTE17    -- Add completed date
from
  poa_dbi_neg_f_v fact
where
  trunc(nvl(fact.rfi_complete_date, fact.award_complete_date)) between &BIS_CURRENT_EFFECTIVE_START_DATE  and &BIS_CURRENT_ASOF_DATE
   ' || fnd_global.newline || l_filter_rfi || l_where_clause || '
group by
  fact.auction_header_id,
  fact.auction_line_number,
  fact.bid_number,
  fact.bid_line_number,
  fact.doctype_id,
  fact.po_item_id,
  fact.org_id,
  fact.negotiation_creator_id,
  fact.supplier_id,
  fact.contract_type,
  fact.po_header_id,
  fact.base_uom,
  fact.auction_creation_date,
  nvl(fact.rfi_complete_date,fact.award_complete_date)
 )
  where ' || get_awd_dtl_filter_clause || '
) i ,
pon_auction_headers_all ponh,
pon_auction_item_prices_all ponip,
pon_bid_headers ponbh,
pon_bid_item_prices ponbip,
poa_items_v item,
poa_suppliers_v supv,
hri_cl_per_v hrv,
mtl_units_of_measure_vl uom,
hr_all_organization_units_vl negorg,
pon_auc_doctypes_tl doctl,
po_headers_all poh
WHERE
 i.auction_header_id = ponh.auction_header_id
 and i.auction_line_number = ponip.line_number
 and ponh.auction_header_id = ponip.auction_header_id
 and decode(ponh.award_status, ''QUALIFIED'', null, ponh.auction_header_id) = ponbh.auction_header_id(+) /* Include only the Auction Record of RFI and not the Responses */
 and ponbh.auction_header_id = ponbip.auction_header_id(+) /* For Bidded Transactions Only */
 and ponbh.bid_number = ponbip.bid_number(+)
 and nvl(ponbip.auction_line_number,ponip.line_number) = ponip.line_number /* Filter to give unique record */
 AND nvl(ponbh.bid_number,nvl(i.bid_number,-99)) = nvl(i.bid_number,-99)
 AND nvl(ponbip.line_number, nvl(i.bid_line_number,-99)) = nvl(i.bid_line_number,-99)
 and nvl(ponbh.bid_status,''ACTIVE'') = ''ACTIVE''             /* If a Supplier changes bids, they store ARCHIVED. Ignore them. */
 and nvl(ponbip.award_status,''-999'') <> ''REJECTED''         /* Cannot be NULL or REJECTED */
 and nvl(ponh.award_status,''-999'') <> ''NO''
 and ponh.doctype_id = doctl.doctype_id
 and i.po_item_id = item.id
 and i.supplier_id = supv.id(+)
 and i.negotiation_creator_id = hrv.id
 AND SYSDATE BETWEEN hrv.start_date AND hrv.end_date
 and i.base_uom = uom.unit_of_measure(+)
 and i.org_id = negorg.organization_id
 AND i.po_header_id = poh.po_header_id(+)
 AND i.doctype_id = doctl.doctype_id
 AND doctl.LANGUAGE = USERENV(''LANG'')
 AND (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
 ORDER BY rnk ';

 x_custom_sql := l_query;
 poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
END;


/*  Function Name : get_awd_dtl_filter_clause
    This function is called by the procedure, dtl_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

 FUNCTION get_awd_dtl_filter_clause return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_ATTRIBUTE2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE3';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);
  END;

/*  Function Name : get_dtl_filter
    This function is called by the procedure, dtl_sql, and it has the computations to be done
    on the columns that will be selected from the Materialized View. Also, the mapping of these
    results to the AK Region Items is done in this function.
*/

 FUNCTION get_dtl_filter(p_doctype_id IN VARCHAR2, show_rfi IN VARCHAR2) return VARCHAR2
  IS
   l_dtl_filter VARCHAR2(100);
   l_selected_doctype VARCHAR2(10);
 BEGIN
   IF (show_rfi = '1') THEN
     SELECT count(*) INTO l_selected_doctype FROM POA_NEG_DOCTYPES_V WHERE INTERNAL_NAME NOT IN ('REQUEST_FOR_INFORMATION')
      AND ID = p_doctype_id;
   ELSE
     RETURN '1';
   END IF;
   IF(l_selected_doctype > 0) THEN
      RETURN '1';
   ELSE
      RETURN '0';
   END IF;
 END;
end poa_dbi_neg_pkg;

/
