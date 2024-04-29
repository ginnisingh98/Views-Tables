--------------------------------------------------------
--  DDL for Package Body POA_DBI_APM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_APM_PKG" 
/* $Header: poadbiapmib.pls 120.1 2005/08/04 06:11:51 sriswami noship $ */

AS

FUNCTION get_status_sel_clause(p_view_by_col_name in VARCHAR2, p_url in VARCHAR2) return VARCHAR2;
FUNCTION get_trend_sel_clause return VARCHAR2;
FUNCTION get_status_filter_where return VARCHAR2;
FUNCTION get_kpi_filter_where return VARCHAR2;

----
---- public methods
----

  PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
	l_query varchar2(4000);
        l_view_by varchar2(120);
	l_view_by_col varchar2(120);
        l_as_of_date date;
        l_prev_as_of_date date;
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_nested_pattern number;
        l_cur_suffix varchar2(2);
        l_url varchar2(300);
        l_custom_sql varchar2(4000);
        l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_where_clause VARCHAR2(2000);
	l_view_by_value VARCHAR2(100);
	l_mv VARCHAR2(30);
        l_context_code VARCHAR2(30);
        l_to_date_type VARCHAR2(30);
  BEGIN
   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
   l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

   poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value, l_comparison_type,
                                        l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern,
                                        l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,
                                        x_custom_output,'N','AP','5.0','VPP','MID');

   /* Get the Context Code of the Dashboard and set the Period Type to be XTD or Rolling */
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

   poa_dbi_util_pkg.add_column(l_col_tbl, 'manual_dist_count', 'manual_dist_count',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'dist_count', 'dist_count',p_to_date_type => l_to_date_type);

   if((l_view_by = 'HRI_PERSON+HRI_PER') and (l_view_by_value is not null) and (instr(l_view_by_value,',') = 0)) then
    l_url := null;
   else
    l_url := 'pFunctionName=POA_DBI_APM_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=HRI_PERSON+HRI_PER&pParamIds=Y';
   end if;

   l_query := get_status_sel_clause(l_view_by_col, l_url) || ' from
               '|| poa_dbi_template_pkg.status_sql(l_mv,
	                                            l_where_clause,
                                            	    l_join_tbl,
                                                    p_use_windowing => 'Y',
                                                    p_col_name => l_col_tbl,
					            p_use_grpid => 'N',
					            p_filter_where => get_status_filter_where,
                                                    p_in_join_tables => l_in_join_tbl);
   x_custom_sql := l_query;
 END;


  PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
	l_query varchar2(32767);
        l_view_by varchar2(120);
	l_view_by_col varchar2(120);
        l_as_of_date date;
        l_prev_as_of_date date;
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_nested_pattern number;
        l_cur_suffix varchar2(2);
        l_custom_sql varchar2(4000);
        l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_mv VARCHAR2(30);
	l_where_clause VARCHAR2(4000);
	l_view_by_value VARCHAR2(100);
        l_context_code VARCHAR2(30);
        l_to_date_type VARCHAR2(30);
  BEGIN
     l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
     l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

     poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value,l_comparison_type,
                                          l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern,
                                          l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,x_custom_output,
                                          'Y','AP','5.0','VPP','MID');
     l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
     /* Get the Context Code of the Dashboard and set the Period Type to be XTD or Rolling */
     IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
        l_to_date_type := 'RLX';
     ELSE
        l_to_date_type := 'XTD';
     END IF;
     poa_dbi_util_pkg.add_column(l_col_tbl, 'manual_dist_count', 'manual_dist_count', 'N',p_to_date_type => l_to_date_type);
     poa_dbi_util_pkg.add_column(l_col_tbl, 'dist_count', 'dist_count', 'N',p_to_date_type => l_to_date_type);

     l_query := get_trend_sel_clause || ' from
                '|| poa_dbi_template_pkg.trend_sql(
                                                     l_xtd,
                                                     l_comparison_type,
   		                                     l_mv,
				                     l_where_clause,
                                                     l_col_tbl,
					             p_use_grpid => 'N',
                                                     p_in_join_tables => l_in_join_tbl);
     x_custom_sql := l_query;
  END;


  PROCEDURE kpi_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                    x_custom_sql  OUT NOCOPY VARCHAR2,
                    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
       l_query varchar2(4000);
       l_view_by varchar2(120);
       l_view_by_col varchar2(120);
       l_as_of_date date;
       l_prev_as_of_date date;
       l_xtd varchar2(10);
       l_comparison_type varchar2(1) := 'Y';
       l_nested_pattern number;
       l_org_where varchar2(500);
       l_cur_suffix varchar2(2);
       l_custom_sql varchar2(4000);
       l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
       l_where_clause varchar2(1000);
       l_mv varchar2(30);
       l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;
       l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
       l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
       l_custom_rec BIS_QUERY_ATTRIBUTES;
       l_view_by_value VARCHAR2(100);
       l_context_code VARCHAR2(30);
       l_to_date_type VARCHAR2(30);
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value,l_comparison_type,
                                         l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern,
                                         l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,x_custom_output,
                                         'N','AP', '5.0', 'VPP','MID');
    /* Get the Context Code of the Dashboard and set the Period Type to be XTD or Rolling */
    l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
    IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
      l_to_date_type := 'RLX';
    ELSE
      l_to_date_type := 'XTD';
    END IF;
    poa_dbi_util_pkg.add_column(l_col_tbl, 'manual_dist_count', 'manual_dist_count',p_to_date_type => l_to_date_type);
    poa_dbi_util_pkg.add_column(l_col_tbl, 'dist_count', 'dist_count',p_to_date_type => l_to_date_type);

    l_query :=
    'select v.value VIEWBY,
            v.id VIEWBYID,
            oset.POA_PERCENT1 POA_PERCENT1,
            oset.POA_PERCENT2 POA_PERCENT2,
            oset.POA_MEASURE1 POA_MEASURE1,
            oset.POA_MEASURE2 POA_MEASURE2
     from
     (select * from
       (select ' || l_view_by_col || ',
             ' || poa_dbi_util_pkg.rate_clause('c_manual_dist_count','c_dist_count') || ' POA_PERCENT1,
             ' || poa_dbi_util_pkg.rate_clause('p_manual_dist_count','p_dist_count') || ' POA_PERCENT2,
             ' || poa_dbi_util_pkg.rate_clause('c_manual_dist_count_total','c_dist_count_total') || ' POA_MEASURE1,
             ' || poa_dbi_util_pkg.rate_clause('p_manual_dist_count_total','p_dist_count_total') || ' POA_MEASURE2
        from
        ' || poa_dbi_template_pkg.status_sql(l_mv,
                                              l_where_clause,
                                              l_join_tbl,
                                              p_use_windowing => 'N',
                                              p_col_name => l_col_tbl,
					      p_use_grpid => 'N',
    					      p_filter_where => get_kpi_filter_where,
                                              p_in_join_tables => l_in_join_tbl);

     x_custom_sql := l_query;
   END;


FUNCTION get_kpi_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;



FUNCTION get_status_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE3';

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;



FUNCTION get_status_sel_clause(p_view_by_col_name in VARCHAR2, p_url in VARCHAR2) return VARCHAR2
  IS
  l_sel_clause varchar2(4000);

BEGIN

  l_sel_clause := 'select ' || case p_view_by_col_name
               when 'inv_d_created_by' then 'decode(v.value, null, fnd_message.get_string(''POA'', ''POA_DBI_APL_UNASSIGNED''), v.value) '
               else 'v.value ' end ||
           'VIEWBY,
	decode(v.id, null, -1, v.id) VIEWBYID,
	oset.POA_MEASURE1 POA_MEASURE1,		--Manual Distributions
	oset.POA_PERCENT1 POA_PERCENT1, 	--Change
	oset.POA_MEASURE3 POA_MEASURE3,		--Distributions
	oset.POA_PERCENT2 POA_PERCENT2,		--Manual Distribution Rate
	oset.POA_MEASURE4 POA_MEASURE4, 	--Total Manual Distributions
	oset.POA_MEASURE5 POA_MEASURE5,		--Total Distributions
	oset.POA_MEASURE6 POA_MEASURE6, 	--Total Change
	oset.POA_MEASURE7 POA_MEASURE7,		--Total Manual Distribution Rate
        ''' || p_url || ''' POA_MEASURE8
     from
     (select (rank() over
                   (&ORDER_BY_CLAUSE nulls last, '||p_view_by_col_name||')) - 1 rnk, '||
           p_view_by_col_name ||',
           POA_MEASURE1, POA_PERCENT1, POA_MEASURE3, POA_PERCENT2, POA_MEASURE4,
           POA_MEASURE5, POA_MEASURE6, POA_MEASURE7 from
     (select '||p_view_by_col_name||', '||
             p_view_by_col_name ||' VIEWBY,
           nvl(c_manual_dist_count,0) POA_MEASURE1,
		   ' || poa_dbi_util_pkg.change_clause('c_manual_dist_count','p_manual_dist_count') || ' POA_PERCENT1,
           nvl(c_dist_count,0) POA_MEASURE3,
		   ' || poa_dbi_util_pkg.rate_clause('c_manual_dist_count','c_dist_count') || ' POA_PERCENT2,
           nvl(c_manual_dist_count_total,0) POA_MEASURE4,
           nvl(c_dist_count_total,0) POA_MEASURE5,
		   ' || poa_dbi_util_pkg.change_clause('c_manual_dist_count_total','p_manual_dist_count_total') || ' POA_MEASURE6,
		   ' || poa_dbi_util_pkg.rate_clause('c_manual_dist_count_total','c_dist_count_total') || ' POA_MEASURE7';
  return l_sel_clause;

end;

FUNCTION get_trend_sel_clause return VARCHAR2
  IS
  l_sel_clause varchar2(4000);

BEGIN

  l_sel_clause :=
  'select cal.name VIEWBY,
             nvl(p_manual_dist_count,0) POA_MEASURE1,
             nvl(c_manual_dist_count,0) POA_MEASURE2,
	     nvl(p_manual_dist_count,0) POA_PERCENT1,
          ' || poa_dbi_util_pkg.change_clause('c_manual_dist_count','p_manual_dist_count') || ' POA_PERCENT3,
	     nvl(c_manual_dist_count,0) POA_PERCENT2';

  return l_sel_clause;

END;


FUNCTION get_view_by_col(view_by varchar2) return varchar2
is
BEGIN
   return (case view_by
                when 'ORGANIZATION+FII_OPERATING_UNITS' then 'org_id'
	   	when 'HRI_PERSON+HRI_PER' then 'inv_d_created_by'
	   	when 'SUPPLIER+POA_SUPPLIERS' then 'supplier_id'
	   	when 'SUPPLIER+POA_SUPPLIER_SITES' then 'supplier_site_id'
	   	else ''
	   end);
END;

end poa_dbi_apm_pkg;

/
