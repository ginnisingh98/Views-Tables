--------------------------------------------------------
--  DDL for Package Body POA_DBI_SPND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_SPND_PKG" 
/* $Header: poadbispndb.pls 120.2 2005/11/30 15:31:53 nnewadka noship $ */
AS
  --




 FUNCTION get_trend_sel_clause (p_view_by IN VARCHAR2)
  RETURN VARCHAR2 ;


 PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               VARCHAR2(32000);
  l_view_by             VARCHAR2(120);
  l_view_by_col_name    VARCHAR2(120);
  l_as_of_date          DATE;
  l_prev_as_of_date     DATE;
  l_xtd                 VARCHAR2(10);
  l_nested_pattern      NUMBER;
  l_comparison_type     VARCHAR2(1) ;
  l_cur_suffix          VARCHAR2(10);
  l_url                 VARCHAR2(300);
  l_view_by_value       VARCHAR2(30);
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

  l_col_tbl1                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_col_tbl2                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_col_tbl3                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_col_tbl4                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_where_clause1             VARCHAR2 (2000);
  l_where_clause2             VARCHAR2 (2000);
  l_where_clause3             VARCHAR2 (2000);
  l_where_clause4             VARCHAR2 (2000);
  l_mv1                       VARCHAR2 (30);
  l_mv2                       VARCHAR2 (30);
  l_mv3                       VARCHAR2 (30);
  l_mv4                       VARCHAR2 (30);
  l_in_join_tbl1        poa_dbi_util_pkg.poa_dbi_in_join_tbl;
  l_in_join_tbl2        poa_dbi_util_pkg.poa_dbi_in_join_tbl;
  l_in_join_tbl3        poa_dbi_util_pkg.poa_dbi_in_join_tbl;
  l_in_join_tbl4        poa_dbi_util_pkg.poa_dbi_in_join_tbl;
  l_mv_tbl              poa_dbi_util_pkg.poa_dbi_mv_tbl;

 l_file varchar2(500);
 BEGIN
  l_comparison_type      := 'Y';

  l_col_tbl1  := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_col_tbl2  := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_col_tbl3  := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_col_tbl4  := poa_dbi_util_pkg.poa_dbi_col_tbl();

  l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();

 ---Get the Invoice Amount Entered Measure
  poa_dbi_sutil_pkg.process_parameters(p_param,
                                         l_view_by,
                                         l_view_by_col_name,
                                         l_view_by_value,
                                         l_comparison_type,
                                         l_xtd,
                                         l_as_of_date,
                                         l_prev_as_of_date,
                                         l_cur_suffix,
                                         l_nested_pattern,
                                         l_where_clause1,
                                         l_mv1,
                                         l_join_tbl,
                                         l_in_join_tbl1,
                                         x_custom_output,
                                         p_trend => 'Y',
                                         p_func_area => 'PO',
                                         p_version => '8.0',
                                         p_role => 'VPP',
                                         p_mv_set => 'FIIIV');

  poa_dbi_util_pkg.add_column(l_col_tbl1
                    , 'invoice_amt_entered_'  || l_cur_suffix
                    , 'invoice_entered_amt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

 ---Get the Paid Amount Measure
  poa_dbi_sutil_pkg.process_parameters(p_param,
                                         l_view_by,
                                         l_view_by_col_name,
                                         l_view_by_value,
                                         l_comparison_type,
                                         l_xtd,
                                         l_as_of_date,
                                         l_prev_as_of_date,
                                         l_cur_suffix,
                                         l_nested_pattern,
                                         l_where_clause2,
                                         l_mv2,
                                         l_join_tbl,
                                         l_in_join_tbl2,
                                         x_custom_output,
                                         p_trend => 'Y',
                                         p_func_area => 'PO',
                                         p_version => '8.0',
                                         p_role => 'VPP',
                                         p_mv_set => 'FIIPA');

    poa_dbi_util_pkg.add_column(l_col_tbl2
                    , 'paid_amt_'  || l_cur_suffix
                    , 'paid_amt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    ---Get the Purchased Amt. Measure
    poa_dbi_sutil_pkg.process_parameters(p_param,
                                         l_view_by,
                                         l_view_by_col_name,
                                         l_view_by_value,
                                         l_comparison_type,
                                         l_xtd,
                                         l_as_of_date,
                                         l_prev_as_of_date,
                                         l_cur_suffix,
                                         l_nested_pattern,
                                         l_where_clause3,
                                         l_mv3,
                                         l_join_tbl,
                                         l_in_join_tbl3,
                                         x_custom_output,
                                         p_trend => 'Y',
                                         p_func_area => 'PO',
                                         p_version => '8.0',
                                         p_role => 'VPP',
                                         p_mv_set => 'POD');

    poa_dbi_util_pkg.add_column(l_col_tbl3
                    , 'purchase_amt_'  || l_cur_suffix
                    , 'purchase_amt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    --Get the Invoice Amt. which is Matched to PO mesaure
    poa_dbi_sutil_pkg.process_parameters(p_param,
                                         l_view_by,
                                         l_view_by_col_name,
                                         l_view_by_value,
                                         l_comparison_type,
                                         l_xtd,
                                         l_as_of_date,
                                         l_prev_as_of_date,
                                         l_cur_suffix,
                                         l_nested_pattern,
                                         l_where_clause4,
                                         l_mv4,
                                         l_join_tbl,
                                         l_in_join_tbl4,
                                         x_custom_output,
                                         p_trend => 'Y',
                                         p_func_area => 'PO',
                                         p_version => '8.0',
                                         p_role => 'VPP',
                                         p_mv_set => 'API');

    poa_dbi_util_pkg.add_column(l_col_tbl4
                    , 'amount_'  || l_cur_suffix
                    , 'invoice_matched_amt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    ---Now populate the MV table list
    l_mv_tbl.extend;
    l_mv_tbl(1).mv_name := l_mv1;
    l_mv_tbl(1).mv_col := l_col_tbl1;
    l_mv_tbl(1).mv_where := l_where_clause1;
    l_mv_tbl(1).in_join_tbls := l_in_join_tbl1;
    l_mv_tbl(1).use_grp_id := 'N';
    l_mv_tbl(1).mv_hint := poa_dbi_sutil_pkg.get_fact_hint(l_mv1);
    l_mv_tbl(1).mv_xtd := l_xtd;

    l_mv_tbl.extend;
    l_mv_tbl(2).mv_name := l_mv2;
    l_mv_tbl(2).mv_col := l_col_tbl2;
    l_mv_tbl(2).mv_where := l_where_clause2;
    l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
    l_mv_tbl(2).use_grp_id := 'N';
    l_mv_tbl(2).mv_hint := poa_dbi_sutil_pkg.get_fact_hint(l_mv2);
    l_mv_tbl(2).mv_xtd := l_xtd;

    l_mv_tbl.extend;
    l_mv_tbl(3).mv_name := l_mv3;
    l_mv_tbl(3).mv_col := l_col_tbl3;
    l_mv_tbl(3).mv_where := l_where_clause3;
    l_mv_tbl(3).in_join_tbls := l_in_join_tbl3;
    l_mv_tbl(3).use_grp_id := 'N';
    l_mv_tbl(3).mv_hint := poa_dbi_sutil_pkg.get_fact_hint(l_mv3);
    l_mv_tbl(3).mv_xtd := l_xtd;

    l_mv_tbl.extend;
    l_mv_tbl(4).mv_name := l_mv4;
    l_mv_tbl(4).mv_col := l_col_tbl4;
    l_mv_tbl(4).mv_where := l_where_clause4;
    l_mv_tbl(4).in_join_tbls := l_in_join_tbl4;
    l_mv_tbl(4).use_grp_id := 'N';
    l_mv_tbl(4).mv_hint := poa_dbi_sutil_pkg.get_fact_hint(l_mv4);
    l_mv_tbl(4).mv_xtd := l_xtd;


    l_query := get_trend_sel_clause(l_view_by) ||
                   ' from ' ||
    poa_dbi_template_pkg.union_all_trend_sql (
                        p_mv                => l_mv_tbl,
                        p_comparison_type   => l_comparison_type,
                        p_filter_where      => NULL);

   x_custom_sql := l_query ;


 END trend_sql ;

 FUNCTION get_trend_sel_clause (p_view_by IN VARCHAR2)
  return VARCHAR2
 IS
   l_sel_clause VARCHAR2(4000);
 BEGIN
   l_sel_clause := 'select cal_name VIEWBY,';
   l_sel_clause := l_sel_clause ||
   'c_purchase_amt POA_MEASURE1,
    c_invoice_entered_amt POA_MEASURE2,
    c_invoice_matched_amt POA_MEASURE3,
    c_paid_amt POA_MEASURE4,'
     ||
    poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_PERCENT1, ' ||
    poa_dbi_util_pkg.change_clause('c_invoice_entered_amt','p_invoice_entered_amt') || ' POA_PERCENT2,'
  || poa_dbi_util_pkg.change_clause('c_invoice_matched_amt','p_invoice_matched_amt') || ' POA_PERCENT3,'
  || poa_dbi_util_pkg.change_clause('c_paid_amt','p_paid_amt') || ' POA_PERCENT4 ' ;

  RETURN l_sel_clause;
 END get_trend_sel_clause ;

END poa_dbi_spnd_pkg;

/
