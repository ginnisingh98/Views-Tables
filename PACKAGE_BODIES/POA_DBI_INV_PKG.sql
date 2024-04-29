--------------------------------------------------------
--  DDL for Package Body POA_DBI_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_INV_PKG" 
/* $Header: poadbiinvb.pls 120.5 2006/04/21 02:28:49 sdiwakar noship $ */
AS
-- -----------------------------------------------------------------------
-- |---------------------< get_status_sel_clause >-----------------------|
-- -----------------------------------------------------------------------
  FUNCTION get_status_sel_clause(p_view_by_dim   IN VARCHAR2
                                ,p_view_by_col   IN VARCHAR2
                                ,p_url           IN VARCHAR2
                                ,p_to_date_type IN VARCHAR2
                                ,p_sec_context IN VARCHAR2) RETURN VARCHAR2;
-- -----------------------------------------------------------------------
-- |------------------------< get_trend_sel_clause >---------------------|
-- -----------------------------------------------------------------------
  FUNCTION get_trend_sel_clause(p_type in varchar2 := 'trend') RETURN VARCHAR2;
FUNCTION get_status_filter_where return VARCHAR2;




-- -----------------------------------------------------------------------
-- |----------------------------< status_sql >---------------------------|
-- -----------------------------------------------------------------------
  PROCEDURE status_sql(p_param           IN          BIS_PMV_PAGE_PARAMETER_TBL
                      ,x_custom_sql      OUT NOCOPY  VARCHAR2
                      ,x_custom_output   OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query                 VARCHAR2(32000);
    l_view_by               VARCHAR2(120);
    l_view_by_col           VARCHAR2(120);
    l_as_of_date            DATE;
    l_prev_as_of_date       DATE;
    l_prev_prev_as_of_date  DATE;
    l_xtd                   VARCHAR2(10);
    l_comparison_type       VARCHAR2(1) :='Y';
    l_nested_pattern        NUMBER;
    l_cur_suffix            VARCHAR2(2);
    l_url                   VARCHAR2(300);
    l_view_by_value         VARCHAR2(30);
    l_col_tbl               POA_DBI_UTIL_PKG.POA_DBI_COL_TBL;
    l_join_tbl              POA_DBI_UTIL_PKG.POA_DBI_JOIN_TBL;
    l_in_join_tbl           POA_DBI_UTIL_PKG.POA_DBI_IN_JOIN_TBL;
    l_in_join_tbl2          POA_DBI_UTIL_PKG.POA_DBI_IN_JOIN_TBL;
    l_where_clause          VARCHAR2(2000);
    l_where_clause2         VARCHAR2(2000);
    l_mv                    VARCHAR2(30);
    l_mv2                   VARCHAR2(30);
    l_custom_rec            BIS_QUERY_ATTRIBUTES;
    ERR_MSG                 VARCHAR2(100);
    l_sec_context           varchar2(10);
    l_use_only_agg_mv       varchar2(1);
    l_mv_tbl                poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_to_date_type          VARCHAR2(3);
  BEGIN
    l_join_tbl    := POA_DBI_UTIL_PKG.POA_DBI_JOIN_TBL();
    l_col_tbl     := POA_DBI_UTIL_PKG.POA_DBI_COL_TBL();
    l_custom_rec  := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    --
    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM' or l_sec_context = 'SUPPLIER')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'API');

      l_prev_prev_as_of_date := poa_dbi_calendar_pkg.previous_period_asof_date(l_prev_as_of_date, l_xtd, l_comparison_type);
      IF(l_sec_context = 'OU' or l_sec_context = 'SUPPLIER') THEN
       l_to_date_type := 'RLX';
       poa_dbi_util_pkg.add_column(l_col_tbl, 'amount_' || l_cur_suffix, 'amount','Y',p_to_date_type => l_to_date_type);
      ELSE
       l_to_date_type := 'XTD';
       poa_dbi_util_pkg.add_column(l_col_tbl, 'amount_' || l_cur_suffix, 'amount','Y',poa_dbi_util_pkg.PREV_PREV,p_to_date_type => l_to_date_type);
      END IF;

      IF(l_view_by='ITEM+ENI_ITEM_PO_CAT') THEN
         l_url := 'pFunctionName=POA_DBI_INV_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y';
      ELSE
        l_url := null;
      END IF;

      l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_url,l_to_date_type, l_sec_context) || ' from ' ||
        poa_dbi_template_pkg.status_sql(
          p_fact_name      =>  l_mv,
          p_where_clause   =>  l_where_clause,
          p_join_tables    =>  l_join_tbl,
          p_use_windowing  =>  'Y',
          p_col_name       =>  l_col_tbl,
          p_use_grpid      =>  'N',
          p_filter_where   =>  get_status_filter_where,
          p_in_join_tables =>  l_in_join_tbl);
    elsif(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'PSM',
        p_mv_set             => 'APIA');

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'N',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'PSM',
          p_mv_set             => 'APIB');
      end if;


      l_prev_prev_as_of_date := poa_dbi_calendar_pkg.previous_period_asof_date(l_prev_as_of_date, l_xtd, l_comparison_type);

      poa_dbi_util_pkg.add_column(l_col_tbl, 'amount_' || l_cur_suffix, 'amount','Y',poa_dbi_util_pkg.PREV_PREV);

      IF(l_view_by='ITEM+ENI_ITEM_PO_CAT') THEN
          l_url := 'pFunctionName=POA_DBI_CC_INV_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y';
      ELSE
          l_url := null;
      END IF;

      if(l_use_only_agg_mv = 'N') then
        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';

        l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_url,'XTD', l_sec_context) || ' from (' ||
           poa_dbi_template_pkg.union_all_status_sql(
             p_mv             => l_mv_tbl,
             p_join_tables    => l_join_tbl,
             p_use_windowing  => 'Y',
             p_paren_count    => 3,
             p_filter_where   => get_status_filter_where,
             p_generate_viewby => 'Y',
             p_diff_measures => 'N');
      else
        l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_url,'XTD', l_sec_context) || ' from ' ||
           poa_dbi_template_pkg.status_sql(
             p_fact_name      =>  l_mv,
             p_where_clause   =>  l_where_clause,
             p_join_tables    =>  l_join_tbl,
             p_use_windowing  =>  'Y',
             p_col_name       =>  l_col_tbl,
             p_use_grpid      =>  'N',
             p_filter_where   =>  get_status_filter_where,
             p_in_join_tables =>  l_in_join_tbl);
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or 'OU/COM' or 'SUPPLIER' */

    x_custom_sql := l_query;

    l_custom_rec.attribute_name       := '&PREV_PREV_DATE';
    l_custom_rec.attribute_value      := TO_CHAR(l_prev_prev_as_of_date, 'DD/MM/YYYY');
    l_custom_rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  EXCEPTION
    WHEN OTHERS THEN
      ERR_MSG := SUBSTR(SQLERRM,1,400);
  END;


  FUNCTION get_status_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT2';

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;



-- -----------------------------------------------------------------------
-- |--------------------< get_status_sel_clause >------------------------|
-- -----------------------------------------------------------------------
  FUNCTION get_status_sel_clause(p_view_by_dim  IN VARCHAR2
                                ,p_view_by_col  IN VARCHAR2
                                ,p_url          IN VARCHAR2
                                ,p_to_date_type IN VARCHAR2
                                ,p_sec_context IN VARCHAR2) RETURN VARCHAR2 IS
    l_sel_clause VARCHAR2(10000);
  BEGIN
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                              ,'PO'
                                                              ,'6.0');
    IF(p_view_by_dim = 'ITEM+POA_ITEMS') THEN
      l_sel_clause := l_sel_clause || ' v.description POA_ATTRIBUTE1, --Description
 ';
    ELSE
      l_sel_clause := l_sel_clause || ' null POA_ATTRIBUTE1,		--Description
 ';
    END IF;
    --
    l_sel_clause := l_sel_clause || '
                      oset.POA_MEASURE1 POA_MEASURE1,		--Invoice Amount
                      oset.POA_PERCENT1 POA_PERCENT1,		--Growth Rate
                      oset.POA_PERCENT2 POA_PERCENT2,		--Percent of Total
                      oset.POA_MEASURE2 POA_MEASURE2,		--Change
                      oset.POA_MEASURE3 POA_MEASURE3,		--Grand Total for Invoice Amount
                      oset.POA_MEASURE4 POA_MEASURE4,		--Grand Total for Growth Rate
                      oset.POA_MEASURE5 POA_MEASURE5,		--Grand Total for Percent of Total
                      oset.POA_PERCENT3 POA_PERCENT3,		--KPI Current Rate
                      oset.POA_PERCENT4 POA_PERCENT4,		--KPI Previous Rate
                      oset.POA_MEASURE4 POA_MEASURE7,
                      oset.POA_MEASURE8 POA_MEASURE8,
                      ''' || p_url || ''' POA_ATTRIBUTE4,';

   if (p_view_by_dim = 'FII_COMPANIES+FII_COMPANIES' or
       p_view_by_dim = 'ORGANIZATION+HRI_CL_ORGCC') then
     l_sel_clause := l_sel_clause || '
       decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_INV_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE5,
       decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_INV_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE6,';
   else
     l_sel_clause := l_sel_clause || '
       null POA_ATTRIBUTE5,
       null POA_ATTRIBUTE6,';
   end if;

   if (p_sec_context = 'COMP') then
     l_sel_clause := l_sel_clause || '
       ''pFunctionName=POA_DBI_CC_INV_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE7,';
   else
     l_sel_clause := l_sel_clause || '
       ''pFunctionName=POA_DBI_INV_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE7,';
   end if;

   l_sel_clause := l_sel_clause || '
                      oset.POA_MEASURE10 POA_MEASURE10,
                      oset.POA_MEASURE11 POA_MEASURE11
   FROM
    (SELECT (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
    end if;

    l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
    --
    IF(p_view_by_dim = 'ITEM+POA_ITEMS') THEN
      l_sel_clause := l_sel_clause || ',
                         base_uom';
    END IF;
    --
    l_sel_clause := l_sel_clause || ',POA_MEASURE1,POA_PERCENT1,
                                      POA_PERCENT2, POA_MEASURE2,
                                      POA_MEASURE3, POA_MEASURE4,
                                      POA_MEASURE5, POA_PERCENT3,
                                      POA_PERCENT4, POA_MEASURE8,
                                      POA_MEASURE10, POA_MEASURE11
       FROM   (SELECT ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
    IF(p_view_by_dim = 'ITEM+POA_ITEMS') THEN
      l_sel_clause := l_sel_clause || 'base_uom,';
    END IF;
    l_sel_clause := l_sel_clause ||
                        ' nvl(c_amount,0) POA_MEASURE1,
                        ' || poa_dbi_util_pkg.change_clause('c_amount','p_amount') || ' POA_PERCENT1,
                        ' || poa_dbi_util_pkg.rate_clause('c_amount','c_amount_total') || ' POA_PERCENT2,
                        ' || poa_dbi_util_pkg.change_clause(
                            poa_dbi_util_pkg.rate_clause('c_amount','c_amount_total'),
                            poa_dbi_util_pkg.rate_clause('p_amount','p_amount_total'),
                            'P') || ' POA_MEASURE2,
                         ' || ' nvl(c_amount_total,0) POA_MEASURE3,
                         ' || poa_dbi_util_pkg.change_clause('c_amount_total','p_amount_total') || ' POA_MEASURE4,
                         ' || poa_dbi_util_pkg.rate_clause('c_amount_total','c_amount_total') || ' POA_MEASURE5,
                         ' || poa_dbi_util_pkg.change_clause('c_amount','p_amount') || ' POA_PERCENT3,';
      IF(p_to_date_type = 'XTD') THEN
        l_sel_clause := l_sel_clause || poa_dbi_util_pkg.change_clause('p_amount','p2_amount') || ' POA_PERCENT4 ,
                         ' || poa_dbi_util_pkg.change_clause('p_amount_total', 'p2_amount_total') || ' POA_MEASURE8,
                        nvl(p_amount,0) POA_MEASURE10,
                        nvl(p_amount_total,0) POA_MEASURE11 ';
      ELSE
         l_sel_clause := l_sel_clause || ' null POA_PERCENT4 ,
                        null POA_MEASURE8,
                        nvl(p_amount,0) POA_MEASURE10,
                        nvl(p_amount_total,0) POA_MEASURE11 ';
      END IF;

    RETURN l_sel_clause;
  END;
-- -----------------------------------------------------------------------
-- |-----------------------------< trend_sql >---------------------------|
-- -----------------------------------------------------------------------
  PROCEDURE trend_sql(p_param           IN          BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql      OUT NOCOPY  VARCHAR2
                     ,x_custom_output   OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query               VARCHAR2(10000);
    l_view_by             VARCHAR2(120);
    l_view_by_col_name    VARCHAR2(120);
    l_view_by_value       VARCHAR2(30);
    l_as_of_date          DATE;
    l_prev_as_of_date     DATE;
    l_xtd                 VARCHAR2(10);
    l_comparison_type     VARCHAR2(1) := 'Y';
    l_nested_pattern      NUMBER;
    l_where_clause        VARCHAR2(2000);
    l_where_clause2       VARCHAR2(2000);
    l_cur_suffix          VARCHAR2(2);
    l_url                 VARCHAR2(300);
    l_col_tbl             POA_DBI_UTIL_PKG.POA_DBI_COL_TBL;
    l_join_tbl            POA_DBI_UTIL_PKG.POA_DBI_JOIN_TBL;
    l_in_join_tbl         POA_DBI_UTIL_PKG.POA_DBI_IN_JOIN_TBL;
    l_in_join_tbl2        POA_DBI_UTIL_PKG.POA_DBI_IN_JOIN_TBL;
    l_mv                  VARCHAR2(30);
    l_mv2                 VARCHAR2(30);
    ERR_MSG               VARCHAR2(100);
    l_sec_context         varchar2(10);
    l_use_only_agg_mv     varchar2(1);
    l_mv_tbl                poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_to_date_type        varchar2(3);
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if(l_sec_context = 'OU' or l_sec_context = 'OU/COM' or l_sec_context = 'SUPPLIER' ) then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col_name,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
	x_custom_output      => x_custom_output,
        p_trend              => 'Y',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'API');

        IF(l_sec_context = 'OU' or l_sec_context = 'SUPPLIER') THEN
           l_to_date_type := 'RLX';
        ELSE
	   l_to_date_type := 'XTD';
        END IF;

      poa_dbi_util_pkg.add_column(l_col_tbl,'amount_' || l_cur_suffix,'amount','N', p_to_date_type => l_to_date_type);

      l_query := get_trend_sel_clause || '
                    from '
          || poa_dbi_template_pkg.trend_sql(
		p_xtd             =>  l_xtd
                ,p_comparison_type =>  l_comparison_type
                ,p_fact_name       =>  l_mv
                ,p_where_clause    =>  l_where_clause
                ,p_col_name        =>  l_col_tbl
		,p_use_grpid	   =>  'N'
                ,p_in_join_tables  =>  l_in_join_tbl);

    elsif(l_sec_context = 'COMP') then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col_name,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
	x_custom_output      => x_custom_output,
        p_trend              => 'Y',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'PSM',
        p_mv_set             => 'APIA');
      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col_name,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
	  x_custom_output      => x_custom_output,
          p_trend              => 'Y',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'PSM',
          p_mv_set             => 'APIB');
      end if;

      poa_dbi_util_pkg.add_column(l_col_tbl,'amount_' || l_cur_suffix,'amount','N');

      if(l_use_only_agg_mv = 'N') then
        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';
        l_mv_tbl(1).mv_xtd := l_xtd;

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';
        l_mv_tbl(2).mv_xtd := l_xtd;

        l_query := get_trend_sel_clause('union') || '
                    from '
          || poa_dbi_template_pkg.union_all_trend_sql(
                p_mv               => l_mv_tbl,
                p_comparison_type  => l_comparison_type,
                p_diff_measures    => 'N');
      else
        l_query := get_trend_sel_clause || '
                    from '
          || poa_dbi_template_pkg.trend_sql(
		p_xtd             =>  l_xtd,
                p_comparison_type =>  l_comparison_type,
                p_fact_name       =>  l_mv,
                p_where_clause    =>  l_where_clause,
                p_col_name        =>  l_col_tbl,
		p_use_grpid	  =>  'N',
                p_in_join_tables  =>  l_in_join_tbl);

      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or 'OU/COM' or 'SUPPLIER' */
    x_custom_sql := l_query;
    EXCEPTION
      WHEN OTHERS THEN
        ERR_MSG := SUBSTR(SQLERRM,1,400);
  END;
-- -----------------------------------------------------------------------
-- |-------------------< get_trend_sel_clause >--------------------------|
-- -----------------------------------------------------------------------
  FUNCTION get_trend_sel_clause(p_type in varchar2 := 'trend')  return VARCHAR2
  IS
    l_sel_clause VARCHAR2(4000);
  BEGIN
    if (p_type = 'trend') then
      l_sel_clause := 'select cal.name VIEWBY,';
    else
      l_sel_clause := 'select cal_name VIEWBY,';
    end if;
    l_sel_clause := l_sel_clause || '
    nvl(c_amount,0) POA_MEASURE2,
    p_amount POA_MEASURE1,
    ' ||  poa_dbi_util_pkg.change_clause('c_amount','p_amount') || ' POA_PERCENT1';
    --
    RETURN l_sel_clause;
  END get_trend_sel_clause;

END poa_dbi_inv_pkg;

/
