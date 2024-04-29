--------------------------------------------------------
--  DDL for Package Body POA_DBI_REJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_REJ_PKG" 
/* $Header: poadbirejb.pls 120.1 2005/08/04 06:14:15 sriswami noship $ */
AS
-- Initial declarations
-- -----------------------------------------------------------------------
-- |---------------------< get_status_sel_clause >-----------------------|
-- -----------------------------------------------------------------------
  FUNCTION get_status_sel_clause(p_view_by_dim   IN VARCHAR2
                                ,p_view_by_col   IN VARCHAR2
                                ,p_url           IN VARCHAR2) RETURN VARCHAR2;
-- -----------------------------------------------------------------------
-- |---------------------< get_reason_sel_clause >-----------------------|
-- -----------------------------------------------------------------------
  FUNCTION get_reason_sel_clause(p_view_by_dim   IN VARCHAR2
                                ,p_view_by_col   IN VARCHAR2
                                ,p_url           IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2;
FUNCTION get_reason_filter_where return VARCHAR2;



-- -----------------------------------------------------------------------
-- |-------------------------< status_sql >------------------------------|
-- -----------------------------------------------------------------------
  PROCEDURE status_sql(p_param           IN          BIS_PMV_PAGE_PARAMETER_TBL
                      ,x_custom_sql      OUT NOCOPY  VARCHAR2
                      ,x_custom_output   OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query               VARCHAR2(20000);
    l_view_by             VARCHAR2(120);
    l_view_by_col         VARCHAR2(120);
    l_as_of_date          DATE;
    l_prev_as_of_date     DATE;
    l_xtd                 VARCHAR2(10);
    l_comparison_type     VARCHAR2(1) :='Y';
    l_nested_pattern      NUMBER;
    l_cur_suffix          VARCHAR2(2);
    l_url                 VARCHAR2(300);
    l_view_by_value       VARCHAR2(30);
    l_col_tbl             POA_DBI_UTIL_PKG.POA_DBI_COL_TBL;
    l_join_tbl            POA_DBI_UTIL_PKG.POA_DBI_JOIN_TBL;
    l_in_join_tbl         POA_DBI_UTIL_PKG.POA_DBI_IN_JOIN_TBL;
    l_where_clause        VARCHAR2(2000);
    l_mv                  VARCHAR2(30);
    ERR_MSG               VARCHAR2(100);
    l_context_code        VARCHAR2(10);
    l_to_date_type        VARCHAR2(10);
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();

    poa_dbi_sutil_pkg.process_parameters(P_PARAM              => p_param
                                        ,P_VIEW_BY            => l_view_by
                                        ,P_VIEW_BY_COL_NAME   => l_view_by_col
                                        ,P_VIEW_BY_VALUE      => l_view_by_value
                                        ,P_COMPARISON_TYPE    => l_comparison_type
                                        ,P_XTD                => l_xtd
                                        ,P_AS_OF_DATE         => l_as_of_date
                                        ,P_PREV_AS_OF_DATE    => l_prev_as_of_date
                                        ,P_CUR_SUFFIX         => l_cur_suffix
                                        ,P_NESTED_PATTERN     => l_nested_pattern
                                        ,P_WHERE_CLAUSE       => l_where_clause
                                        ,P_MV                 => l_mv
                                        ,P_JOIN_TBL           => l_join_tbl
                                        ,P_IN_JOIN_TBL        => l_in_join_tbl
					,X_CUSTOM_OUTPUT      => x_custom_output
                                        ,P_TREND              => 'N'
                                        ,P_FUNC_AREA          => 'PO'
                                        ,P_VERSION            => '6.0'
                                        ,P_ROLE               => 'COM'
                                        ,P_MV_SET             => 'RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'amt_reject_' || l_cur_suffix
                               ,'amt_reject'
                               ,p_to_date_type => l_to_date_type);

    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'amt_receipt_' || l_cur_suffix
                               ,'amt_receipt'
                               ,p_to_date_type => l_to_date_type);

    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'amt_receipt_reject_' || l_cur_suffix
                               ,'amt_receipt_reject'
                               ,p_to_date_type => l_to_date_type);

    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'amt_inspected_' || l_cur_suffix
                               ,'amt_inspected'
                               ,p_to_date_type => l_to_date_type);

    if(l_view_by = 'ITEM+POA_ITEMS') then
      poa_dbi_util_pkg.add_column(l_col_tbl
                                 ,'qty_reject'
                                 ,'qty_reject'
                                 ,p_to_date_type => l_to_date_type);

      poa_dbi_util_pkg.add_column(l_col_tbl
                                 ,'qty_receipt'
                                 ,'qty_receipt'
                                 ,p_to_date_type => l_to_date_type);

    end if;

    if(l_view_by='ITEM+ENI_ITEM_PO_CAT' or l_view_by='ITEM+POA_ITEMS') then
      l_url := 'pFunctionName=POA_DBI_REJ_REASON_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=LOOKUP+RETURN_REASON&pParamIds=Y';
    else
      l_url := 'pFunctionName=POA_DBI_REJ_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_PO_CAT&pParamIds=Y';
    end if;
    --
    l_query := get_status_sel_clause(l_view_by
                                    ,l_view_by_col
                                    ,l_url)
               || ' FROM ' ||
               poa_dbi_template_pkg.status_sql(p_fact_name      =>  l_mv
                                              ,p_where_clause   =>  l_where_clause
                                              ,p_join_tables    =>  l_join_tbl
                                              ,p_use_windowing  =>  'Y'
                                              ,p_col_name       =>  l_col_tbl
					      ,p_filter_where   => get_status_filter_where(l_view_by)
					      , p_use_grpid => 'N'
                                              ,p_in_join_tables =>  l_in_join_tbl);
    --
    x_custom_sql := l_query;
    --
  EXCEPTION
    WHEN OTHERS THEN
      ERR_MSG := SUBSTR(SQLERRM,1,400);
  END status_sql;

FUNCTION get_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE7';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE8';
    if(p_view_by= 'ITEM+POA_ITEMS') then
	l_col_tbl.extend;
	l_col_tbl(8) := 'POA_MEASURE1';
	l_col_tbl.extend;
	l_col_tbl(9) := 'POA_MEASURE2';
    end if;
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;



-- -----------------------------------------------------------------------
-- |---------------------< get_status_sel_clause >-----------------------|
-- -----------------------------------------------------------------------
  FUNCTION get_status_sel_clause(p_view_by_dim  IN VARCHAR2
                                ,p_view_by_col  IN VARCHAR2
                                ,p_url          IN VARCHAR2) RETURN VARCHAR2 IS
    l_sel_clause VARCHAR2(8000);
  BEGIN
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(P_VIEWBY     =>  p_view_by_dim
                                                              ,P_FUNC_AREA  =>  'PO'
                                                              ,P_VERSION    =>  '6.0');
    IF(p_view_by_dim = 'ITEM+POA_ITEMS') THEN
      l_sel_clause := l_sel_clause || '
			v.description POA_ATTRIBUTE1, 		--Description
                      v2.description POA_ATTRIBUTE2,	--UOM
                      oset.POA_MEASURE1 POA_MEASURE1,		--Reject Quantity
                      oset.POA_MEASURE2 POA_MEASURE2, 		--Receipt Quantity
';
    ELSE
      l_sel_clause := l_sel_clause || ' null POA_ATTRIBUTE1,	--Description
                      null POA_ATTRIBUTE2,	--UOM
                      null POA_MEASURE1,	--Reject Quantity
                      null POA_MEASURE2,	--Receipt Quantity
';
    END IF;
    --
    l_sel_clause := l_sel_clause || '
		    oset.POA_MEASURE3 POA_MEASURE3,		--Rejection Amount
                    oset.POA_PERCENT1 POA_PERCENT1,		--Change
                    oset.POA_MEASURE4 POA_MEASURE4,		--Receipt Amount
                    oset.POA_MEASURE5 POA_MEASURE5,		--Receipt Rejection Amount
                    oset.POA_PERCENT2 POA_PERCENT2,		--Rejection Rate
                    oset.POA_MEASURE7 POA_MEASURE7,		--Receipt Inspected Amount
                    oset.POA_MEASURE8 POA_MEASURE8,		--Receipt Inspected Rejection Rate
                    oset.POA_MEASURE9 POA_MEASURE9,		--Grand Total for Rejection Amount
                    oset.POA_MEASURE10 POA_MEASURE10,		--Grand Total for Change
                    oset.POA_MEASURE11 POA_MEASURE11,		--Grand Total for Receipt Rejection Amount
                    oset.POA_MEASURE12 POA_MEASURE12,		--Grand Total for Receipt Rejection Amount
                    oset.POA_MEASURE13 POA_MEASURE13,		--Grand Total for Rejection Rate
                    oset.POA_MEASURE14 POA_MEASURE14,		--Grand Total for Receipt Inspected Amount
                    oset.POA_MEASURE15 POA_MEASURE15,		--Grand Total for Receipt Inspected Rejection Rate
                    ''' || p_url || ''' POA_ATTRIBUTE3,
                    oset.POA_PERCENT3 POA_PERCENT3,     -- KPI - Compare TO measure
                    oset.POA_PERCENT4 POA_PERCENT4     -- KPI - Compare to Grand Total
    FROM
    (SELECT (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
    --
    IF(p_view_by_dim = 'ITEM+POA_ITEMS') THEN
      l_sel_clause := l_sel_clause || ',
                      base_uom,
                      POA_MEASURE1,
                      POA_MEASURE2';
    END IF;
    --
    l_sel_clause := l_sel_clause || ',POA_MEASURE3,POA_PERCENT1,
                      POA_MEASURE4,POA_MEASURE5,
                      POA_PERCENT2,POA_MEASURE7,
                      POA_MEASURE8,POA_MEASURE9,
                      POA_MEASURE10,POA_MEASURE11,
                      POA_MEASURE12,POA_MEASURE13,
                      POA_MEASURE14,POA_MEASURE15,
                      POA_PERCENT3, POA_PERCENT4
    FROM   (SELECT ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
    --
    IF(p_view_by_dim = 'ITEM+POA_ITEMS') THEN
      l_sel_clause := l_sel_clause || ' base_uom,
                        decode(base_uom,null,to_number(null),nvl(c_qty_reject,0)) POA_MEASURE1,
                        decode(base_uom,null,to_number(null),nvl(c_qty_receipt,0)) POA_MEASURE2, ';
    END IF;
    --
    l_sel_clause := l_sel_clause || ' nvl(c_amt_reject,0) POA_MEASURE3,
                             '|| poa_dbi_util_pkg.change_clause('c_amt_reject','p_amt_reject') || ' POA_PERCENT1,
                             '|| 'nvl(c_amt_receipt,0) POA_MEASURE4,
                                  nvl(c_amt_receipt_reject,0) POA_MEASURE5,
                             '|| poa_dbi_util_pkg.rate_clause('c_amt_receipt_reject','c_amt_receipt') || ' POA_PERCENT2,
                             '||'nvl(c_amt_inspected,0) POA_MEASURE7,
                             '|| poa_dbi_util_pkg.rate_clause('c_amt_reject','c_amt_inspected') || ' POA_MEASURE8,
                             '|| 'nvl(c_amt_reject_total,0) POA_MEASURE9,
                             '|| poa_dbi_util_pkg.change_clause('c_amt_reject_total','p_amt_reject_total') || ' POA_MEASURE10,
                             '||' nvl(c_amt_receipt_total,0) POA_MEASURE11,
                                  nvl(c_amt_receipt_reject_total,0) POA_MEASURE12,
                             '|| poa_dbi_util_pkg.rate_clause('c_amt_receipt_reject_total','c_amt_receipt_total') || ' POA_MEASURE13,
                             '|| ' nvl(c_amt_inspected_total,0) POA_MEASURE14,
                             '|| poa_dbi_util_pkg.rate_clause('c_amt_reject_total','c_amt_inspected_total') || ' POA_MEASURE15,
                             '|| poa_dbi_util_pkg.rate_clause('p_amt_receipt_reject','p_amt_receipt') || ' POA_PERCENT3,
                             '|| poa_dbi_util_pkg.rate_clause('p_amt_receipt_reject_total','p_amt_receipt_total') || ' POA_PERCENT4
                             ';
    --
    RETURN l_sel_clause;
  END get_status_sel_clause;



-- -----------------------------------------------------------------------
-- |---------------------------< rej_rsn_sql >---------------------------|
-- -----------------------------------------------------------------------
  PROCEDURE rej_rsn_sql(p_param           IN          BIS_PMV_PAGE_PARAMETER_TBL
                       ,x_custom_sql      OUT NOCOPY  VARCHAR2
                       ,x_custom_output   OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query             VARCHAR2(10000);
    l_view_by           VARCHAR2(120);
    l_view_by_col       VARCHAR2(120);
    l_as_of_date        DATE;
    l_prev_as_of_date   DATE;
    l_xtd               VARCHAR2(10);
    l_comparison_type   VARCHAR2(1) :='Y';
    l_nested_pattern    NUMBER;
    l_cur_suffix        VARCHAR2(2);
    l_url               VARCHAR2(300);
    l_view_by_value     VARCHAR2(30);
    l_where_clause      VARCHAR2(2000);
    l_mv                VARCHAR2(30);
    l_col_tbl           POA_DBI_UTIL_PKG.POA_DBI_COL_TBL;
    l_join_tbl          POA_DBI_UTIL_PKG.POA_DBI_JOIN_TBL;
    l_in_join_tbl       POA_DBI_UTIL_PKG.POA_DBI_IN_JOIN_TBL;
    ERR_MSG             VARCHAR2(100);
    l_context_code      VARCHAR2(10);
    l_to_date_type      VARCHAR2(10);
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
    --
    poa_dbi_sutil_pkg.process_parameters(p_param              => p_param
                                        ,p_view_by            => l_view_by
                                        ,p_view_by_col_name   => l_view_by_col
                                        ,p_view_by_value      => l_view_by_value
                                        ,p_comparison_type    => l_comparison_type
                                        ,p_xtd                => l_xtd
                                        ,p_as_of_date         => l_as_of_date
                                        ,p_prev_as_of_date    => l_prev_as_of_date
                                        ,p_cur_suffix         => l_cur_suffix
                                        ,p_nested_pattern     => l_nested_pattern
                                        ,p_where_clause       => l_where_clause
                                        ,p_mv                 => l_mv
                                        ,p_join_tbl           => l_join_tbl
                                        ,p_in_join_tbl        => l_in_join_tbl
					,x_custom_output     => x_custom_output
                                        ,p_trend              => 'N'
                                        ,p_func_area          => 'PO'
                                        ,p_version            => '6.0'
                                        ,p_role               => 'COM'
                                        ,p_mv_set             => 'RTX');
    --
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;
    poa_dbi_util_pkg.add_column(l_col_tbl,'amt_reject_' || l_cur_suffix,'amt_reject',p_to_date_type => l_to_date_type);
    poa_dbi_util_pkg.add_column(l_col_tbl,'amt_receipt_reject_' || l_cur_suffix,'amt_receipt_reject',p_to_date_type => l_to_date_type);
    l_query := get_reason_sel_clause(P_VIEW_BY_DIM    =>  l_view_by
                                    ,P_VIEW_BY_COL    =>  l_view_by_col
                                    ,P_URL            =>  null)
                || ' FROM ' ||
                poa_dbi_template_pkg.status_sql(p_fact_name      => l_mv
                                               ,p_where_clause   => l_where_clause
                                               ,p_join_tables    => l_join_tbl
                                               ,p_use_windowing  => 'Y'
                                               ,p_col_name       => l_col_tbl
					       ,p_filter_where   => get_reason_filter_where
						, p_use_grpid => 'N'
                                               ,p_in_join_tables => l_in_join_tbl);
    x_custom_sql := l_query;
    --
  EXCEPTION
    WHEN OTHERS THEN
      ERR_MSG := SUBSTR(SQLERRM,1,400);
  END rej_rsn_sql;


FUNCTION get_reason_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_PERCENT2';

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;


-- -----------------------------------------------------------------------
-- |---------------------< get_reason_sel_clause >-----------------------|
-- -----------------------------------------------------------------------
  FUNCTION get_reason_sel_clause(p_view_by_dim  IN VARCHAR2
                                ,p_view_by_col  IN VARCHAR2
                                ,p_url          IN VARCHAR2) RETURN VARCHAR2
  IS
    l_sel_clause VARCHAR2(4000);
  BEGIN
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(P_VIEWBY       =>  p_view_by_dim
                                                              ,P_FUNC_AREA    =>  'PO'
                                                              ,P_VERSION      =>  '6.0');
    --
    l_sel_clause := l_sel_clause || 'oset.reason_id POA_ATTRIBUTE1,' ;
    --
    l_sel_clause := l_sel_clause || '
                     oset.POA_MEASURE1 POA_MEASURE1,	--Rejection Amount
                     oset.POA_PERCENT1 POA_PERCENT1,	--Change
                     oset.POA_PERCENT2 POA_PERCENT2,	--Percent of Total
                     oset.POA_MEASURE2 POA_MEASURE2,	--Grand Total for Rejection Amount
                     oset.POA_MEASURE3 POA_MEASURE3,	--Grand Total for Change
                     oset.POA_MEASURE4 POA_MEASURE4,	--Grand Total for Percent of Total
                     oset.POA_MEASURE1 POA_MEASURE5,	--Rejection Amount
                     oset.POA_MEASURE2 POA_MEASURE6 	--Grand Total for Rejection Amount for Pie
                FROM (SELECT (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col || ')) - 1 rnk,' || p_view_by_col || ',';
    --
    l_sel_clause := l_sel_clause || '
                      reason_id POA_ATTRIBUTE1,
                      POA_MEASURE1,POA_PERCENT1,
                      POA_PERCENT2,POA_MEASURE2,
                      POA_MEASURE3,POA_MEASURE4
                    FROM   (SELECT ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ' || p_view_by_col || ' POA_ATTRIBUTE1,';
    l_sel_clause := l_sel_clause || '
                     nvl(c_amt_reject,0) POA_MEASURE1,
                     ' || poa_dbi_util_pkg.change_clause('c_amt_reject','p_amt_reject') || ' POA_PERCENT1,
                     ' || poa_dbi_util_pkg.rate_clause('c_amt_reject','c_amt_reject_total') || 'POA_PERCENT2,
                     ' || ' c_amt_reject_total POA_MEASURE2,
                     ' || poa_dbi_util_pkg.change_clause('c_amt_reject_total','p_amt_reject_total') || ' POA_MEASURE3,
                     ' || poa_dbi_util_pkg.rate_clause('c_amt_reject_total','c_amt_reject_total') || ' POA_MEASURE4
                     ';
  RETURN l_sel_clause;
  END get_reason_sel_clause;
  --
END poa_dbi_rej_pkg;

/
