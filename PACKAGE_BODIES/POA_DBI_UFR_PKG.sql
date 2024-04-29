--------------------------------------------------------
--  DDL for Package Body POA_DBI_UFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_UFR_PKG" 
/* $Header: poadbiufrb.pls 120.3 2006/08/08 10:51:43 nchava noship $ */
AS
--
FUNCTION get_amt_sel_clause(
          p_view_by_dim in VARCHAR2
         ,p_view_by_col in VARCHAR2
	 , p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE)  return VARCHAR2;
FUNCTION get_sum_sel_clause(
          p_view_by_dim in VARCHAR2
         ,p_view_by_col in VARCHAR2) return VARCHAR2;
FUNCTION get_status_sel_clause(
	  p_view_by_dim in VARCHAR2
         ,p_view_by_col in VARCHAR2) return VARCHAR2;
FUNCTION get_age_sel_clause(
          p_view_by_dim in VARCHAR2
         ,p_view_by_col in VARCHAR2
	 , p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE)  return VARCHAR2;
FUNCTION get_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_amt_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_age_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_sum_rpt_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;


PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_query               varchar2(10000);
  l_view_by             varchar2(120);
  l_view_by_col         varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1);
  l_nested_pattern      number;
  l_cur_suffix          varchar2(2);
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  l_mv                  VARCHAR2(30);
  l_view_by_value       varchar2(30);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
BEGIN

  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_comparison_type := 'Y';
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
				      ,x_custom_output
                                      ,p_trend => 'N'
                                      ,p_func_area => 'PO'
                                      ,p_version => '7.1'
                                      ,p_role => 'VPP'
                                      ,p_mv_set => 'REQS');


  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unfulfilled_cnt'
			      , 'unfulf_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  poa_dbi_util_pkg.add_column(l_col_tbl
			      , 'unfulfilled_ped_cnt'
			      , 'unfulf_ped_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  poa_dbi_util_pkg.add_column(l_col_tbl
			      , 'unfulfilled_amt_' || l_cur_suffix
			      , 'unfulf_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  poa_dbi_util_pkg.add_column(l_col_tbl
			      , 'num_days_unfulfilled'
			      , 'num_days_unfulf'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'unfulfilled_qty'
                               ,'unfulf_qty'
			       , p_grand_total => 'N'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

  end if;

  l_query := get_status_sel_clause(l_view_by, l_view_by_col) || ' from '||
               poa_dbi_template_pkg.status_sql(
		  l_mv,
		  l_where_clause,
		  l_join_tbl,
		  p_use_windowing => 'P',
		  p_col_name => l_col_tbl,
		  p_use_grpid => 'N',
		  p_filter_where => get_status_filter_where(l_view_by),
		  p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;


 EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
  end status_sql;

  FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2
                                ,p_view_by_col in VARCHAR2) return VARCHAR2 IS
  l_sel_clause varchar2(4000);

  BEGIN

  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                            ,'7.1');


  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||
'	v.description POA_ATTRIBUTE1,	            --Description
        v2.description POA_ATTRIBUTE2,              --UOM
        oset.POA_MEASURE10 POA_MEASURE10,	    --Unfulfilled Quantity

'|| fnd_global.newline;

  else
    l_sel_clause :=  l_sel_clause
		|| fnd_global.newline
		||
'	null POA_ATTRIBUTE1,		--Description
 	null POA_ATTRIBUTE2,		--UOM
	null POA_MEASURE10,		--Quantity'
	|| fnd_global.newline;

  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE1 POA_MEASURE1,		--Unfulfilled Lines
 	oset.POA_PERCENT1 POA_PERCENT1,		--Percent of Total
	oset.POA_MEASURE1 POA_MEASURE5,		--Unfulfilled Lines for graph 2
	oset.POA_MEASURE2 POA_MEASURE2,		--Lines Past Expected Date
	oset.POA_MEASURE3 POA_MEASURE3,		--Unfulfilled Amount
	oset.POA_MEASURE4 POA_MEASURE4,		--Average Age Days
	oset.POA_MEASURE6 POA_MEASURE6,		--Grand Total Unfulfilled Lines
	oset.POA_PERCENT2 POA_PERCENT2,		--Grand Total Percent of Total
	oset.POA_MEASURE7 POA_MEASURE7,		--Grand Total Lines Past Exp Date
	oset.POA_MEASURE8 POA_MEASURE8,		--Grand Total Unfulfilled Amount
	oset.POA_MEASURE9 POA_MEASURE9,		--Grand Total Days Past
	oset.POA_MEASURE2 POA_MEASURE11,	--Lines past exp for graph';


   l_sel_clause := l_sel_clause || '
   ''pFunctionName=POA_DBI_UFR_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_PO_CAT&pParamIds=Y'' POA_ATTRIBUTE6,
   ''pFunctionName=POA_DBI_UFR_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_PO_CAT&pParamIds=Y'' POA_ATTRIBUTE7,
   ''pFunctionName=POA_DBI_UFR_PED_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1'' POA_ATTRIBUTE8,
   ''pFunctionName=POA_DBI_UFR_PED_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1'' POA_ATTRIBUTE9,
   ''pFunctionName=POA_DBI_UFR_AMT_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_PO_CAT'' POA_ATTRIBUTE10,
   ''pFunctionName=POA_DBI_UFR_AGE_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_PO_CAT'' POA_ATTRIBUTE11 ';


   l_sel_clause := l_sel_clause ||
   ' from (select * from (select * from
   (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;
 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
 end if;


l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE10';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE1,POA_PERCENT1,
                       POA_MEASURE2,POA_MEASURE3,
                       POA_PERCENT2,
                       POA_MEASURE6,POA_MEASURE7,
                       POA_MEASURE8,POA_MEASURE4,POA_MEASURE9
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_unfulf_qty,0)) POA_MEASURE10, ';

   end if;
 l_sel_clause := l_sel_clause || ' nvl(c_unfulf_cnt,0) POA_MEASURE1,
		'
|| poa_dbi_util_pkg.rate_clause('c_unfulf_cnt', 'c_unfulf_cnt_total', 'P') || ' POA_PERCENT1,
                nvl(c_unfulf_ped_cnt,0) POA_MEASURE2,
                nvl(c_unfulf_amt,0) POA_MEASURE3,
		nvl(c_unfulf_cnt_total,0) POA_MEASURE6,
		decode(c_unfulf_cnt_total, null, null, 100) POA_PERCENT2,
                nvl(c_unfulf_ped_cnt_total,0) POA_MEASURE7,
                nvl(c_unfulf_amt_total,0) POA_MEASURE8,
		' ||
poa_dbi_util_pkg.rate_clause('c_num_days_unfulf','c_unfulf_cnt', 'NP')|| ' POA_MEASURE4,
                ' ||
poa_dbi_util_pkg.rate_clause('c_num_days_unfulf_total','c_unfulf_cnt_total','NP')|| ' POA_MEASURE9
';

   return l_sel_clause;
 END get_status_sel_clause;

FUNCTION get_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
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
    l_col_tbl(4) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE4';

 if(p_view_by = 'ITEM+POA_ITEMS') then
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE10';
 end if;

   return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;


PROCEDURE amt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
        l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_query               varchar2(10000);
	l_view_by             varchar2(120);
	l_view_by_col         varchar2(120);
        l_as_of_date          date;
        l_prev_as_of_date     date;
        l_xtd                 varchar2(10);
        l_comparison_type     varchar2(1);
        l_nested_pattern      number;
        l_cur_suffix          varchar2(2);
        l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
	l_where_clause        VARCHAR2(2000);
	l_mv                  VARCHAR2(30);
	l_view_by_value       varchar2(30);
	l_bucket_rec          BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE;
        ERR_MSG               VARCHAR2(100);
        ERR_CDE               NUMBER;
BEGIN
      l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
      l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
      l_comparison_type := 'Y';
      poa_dbi_sutil_pkg.process_parameters(p_param
					, l_view_by
					, l_view_by_col
					, l_view_by_value
					, l_comparison_type
					, l_xtd
					, l_as_of_date
					, l_prev_as_of_date
					, l_cur_suffix
					, l_nested_pattern
					, l_where_clause
					, l_mv
					, l_join_tbl
					, l_in_join_tbl
   				        ,x_custom_output
					, p_trend => 'N'
					, p_func_area => 'PO'
					, p_version => '7.1'
					, p_role => 'VPP'
	                                , p_mv_set => 'REQS');
  poa_dbi_util_pkg.add_bucket_columns(
                    p_short_name => 'POA_DBI_UFR_BUCKET'
                   ,p_col_tbl => l_col_tbl
                   ,p_col_name => 'unfulfilled_amt_' || l_cur_suffix || '_age'
                   ,p_alias_name => 'unfulf_amt_age'
                   ,x_bucket_rec => l_bucket_rec
                   ,p_grand_total => 'Y'
                   ,p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                   ,p_to_date_type => 'NA');

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unfulfilled_amt_'|| l_cur_suffix
			      , 'unfulf_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_fulfill_amt_'|| l_cur_suffix
			      , 'pen_fulf_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'unfulfilled_qty'
                               ,'unfulf_qty'
			       , p_grand_total => 'N'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  end if;


  l_query := get_amt_sel_clause(
		  l_view_by
		, l_view_by_col,l_bucket_rec) || ' from' ||
		poa_dbi_template_pkg.status_sql(
					l_mv,
					l_where_clause,
					 l_join_tbl,
					 p_use_windowing => 'P',
					 p_col_name => l_col_tbl,
					 p_use_grpid => 'N',
					 p_filter_where => get_amt_filter_where(l_view_by),
					 p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
 END amt_sql;


 FUNCTION get_amt_sel_clause(
	  p_view_by_dim in VARCHAR2
	, p_view_by_col in VARCHAR2
	 , p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE)

return VARCHAR2
  IS
  l_sel_clause varchar2(4000);
  BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                           ,'7.1');


 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||  '
	v.description POA_ATTRIBUTE1,
        v2.description POA_ATTRIBUTE2,
        oset.POA_MEASURE1 POA_MEASURE1,

'|| fnd_global.newline;

  else
    l_sel_clause :=  l_sel_clause
		|| fnd_global.newline
		||  '
	null POA_ATTRIBUTE1,
 	null POA_ATTRIBUTE2,
	null POA_MEASURE1, '
|| fnd_global.newline;

  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2 POA_MEASURE2,	--unfulf amt
	oset.POA_MEASURE3 POA_MEASURE3,  -- unfulf amt pend process
	oset.POA_MEASURE4 POA_MEASURE4 -- pending fulf'
	|| fnd_global.newline
        || poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE5'
             , p_alias_name => 'POA_MEASURE5'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N')
        || fnd_global.newline
        || ',
	oset.POA_MEASURE6 POA_MEASURE6, --unfulf amt total
	oset.POA_MEASURE7 POA_MEASURE7,	 -- pend process total
        oset.POA_MEASURE8 POA_MEASURE8	-- unfulf amt pend fulf total'
	|| fnd_global.newline
        || poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE9'
             , p_alias_name => 'POA_MEASURE9'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N')
        || fnd_global.newline
	||
',
	oset.POA_MEASURE3 POA_ATTRIBUTE4, --unful amt-pending proc for graph
	oset.POA_MEASURE4 POA_ATTRIBUTE5 --unful amt-pending fulf for graph '
|| fnd_global.newline ;


        l_sel_clause := l_sel_clause ||
   	  poa_dbi_util_pkg.get_bucket_drill_url(
		  p_bucket_rec
		, 'POA_ATTRIBUTE7'
		,
'''pFunctionName=POA_DBI_UFR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=-2&POA_BUCKET+REQUISITION_AGING='
		, ''''
		, p_add_bucket_num => 'Y') || ',';


    l_sel_clause := l_sel_clause || '
    ''pFunctionName=POA_DBI_UFR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=-2'' POA_ATTRIBUTE9,
    ''pFunctionName=POA_DBI_UFR_PR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=2'' POA_ATTRIBUTE11,
    ''pFunctionName=POA_DBI_UFR_FR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=3'' POA_ATTRIBUTE12,
    ''pFunctionName=POA_DBI_UFR_PR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=2'' POA_ATTRIBUTE13,
    ''pFunctionName=POA_DBI_UFR_FR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=3'' POA_ATTRIBUTE14 ';


  l_sel_clause := l_sel_clause || ' from
    (select * from (select * from (select
      (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
 end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE1';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE2,POA_MEASURE3,
                       POA_MEASURE4 '
		       || fnd_global.newline
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'POA_MEASURE5'
                          , p_alias_name => 'POA_MEASURE5'
                          , p_prefix => ''
                          , p_suffix => ''
                          , p_total_flag => 'N')
                      || fnd_global.newline ||
		      ' ,POA_MEASURE6,
                       POA_MEASURE7,POA_MEASURE8'
		       || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'POA_MEASURE9'
                          , p_alias_name => 'POA_MEASURE9'
                          , p_prefix => ''
                          , p_suffix => ''
                          , p_total_flag => 'N')
                      || fnd_global.newline || '
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_unfulf_qty,0)) POA_MEASURE1, ';

   end if;
l_sel_clause := l_sel_clause
	|| ' nvl(c_unfulf_amt,0)	 POA_MEASURE2,
             (nvl(c_unfulf_amt,0)-nvl(c_pen_fulf_amt,0)) POA_MEASURE3,
	     nvl(c_pen_fulf_amt,0)	 POA_MEASURE4';
 l_sel_clause := l_sel_clause || fnd_global.newline
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'c_unfulf_amt_age'
                          , p_alias_name => 'POA_MEASURE5'
                          , p_prefix => 'nvl('
                          , p_suffix => ',0)'
                          , p_total_flag => 'N')
                      || fnd_global.newline || ',

	     nvl(c_unfulf_amt_total,0)   POA_MEASURE6,
	     (nvl(c_unfulf_amt_total,0)-nvl(c_pen_fulf_amt_total,0)) POA_MEASURE7,
	     nvl(c_pen_fulf_amt_total,0) POA_MEASURE8'
	     || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'c_unfulf_amt_age'
                          , p_alias_name => 'POA_MEASURE9'
                          , p_prefix => 'nvl('
                          , p_suffix => ',0)'
                          , p_total_flag => 'Y')
	|| fnd_global.newline;

return l_sel_clause;
END get_amt_sel_clause;

FUNCTION get_amt_filter_where(p_view_by in VARCHAR2) return VARCHAR2
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

 if(p_view_by = 'ITEM+POA_ITEMS') then
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE1';
 end if;

   return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;


PROCEDURE sum_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
        l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_query               varchar2(10000);
	l_view_by             varchar2(120);
	l_view_by_col         varchar2(120);
        l_as_of_date          date;
        l_prev_as_of_date     date;
        l_xtd                 varchar2(10);
        l_comparison_type     varchar2(1);
        l_nested_pattern      number;
        l_cur_suffix          varchar2(2);
        l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
	l_where_clause        VARCHAR2(2000);
	l_mv                  VARCHAR2(30);
	l_view_by_value       varchar2(30);
        ERR_MSG               VARCHAR2(100);
        ERR_CDE               NUMBER;
BEGIN
      l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
      l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
      l_comparison_type := 'Y';
      poa_dbi_sutil_pkg.process_parameters(p_param
					, l_view_by
					, l_view_by_col
					, l_view_by_value
					, l_comparison_type
					, l_xtd
					, l_as_of_date
					, l_prev_as_of_date
					, l_cur_suffix
					, l_nested_pattern
					, l_where_clause
					, l_mv
					, l_join_tbl
					, l_in_join_tbl
					, x_custom_output
					, p_trend => 'N'
					, p_func_area => 'PO'
					, p_version => '7.1'
					, p_role => 'VPP'
	                                , p_mv_set => 'REQS');

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unfulfilled_cnt'
			      , 'unfulf_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
 poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_fulfill_cnt'
			      , 'pen_fulf_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unfulfilled_ped_cnt'
			      , 'unfulf_ped_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unful_po_revisions'
			      , 'unful_po_revisions'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'unfulfilled_qty'
                               ,'unfulf_qty'
			       , p_grand_total => 'N'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  end if;

  l_query := get_sum_sel_clause(
		  l_view_by
		, l_view_by_col) || ' from' ||
		poa_dbi_template_pkg.status_sql(
					l_mv,
					l_where_clause,
					 l_join_tbl,
					 p_use_windowing => 'P',
					 p_col_name => l_col_tbl,
					 p_use_grpid => 'N',
					 p_filter_where => get_sum_rpt_filter_where(l_view_by),
					 p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
END sum_rpt_sql;




FUNCTION get_sum_sel_clause(
	  p_view_by_dim in VARCHAR2
	, p_view_by_col in VARCHAR2
	) return VARCHAR2
  IS
  l_sel_clause varchar2(4000);
  BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                           ,'7.1');


 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||  '
	v.description POA_ATTRIBUTE1,	            --Description
        v2.description POA_ATTRIBUTE2,              --UOM
        oset.POA_MEASURE1 POA_MEASURE1,	            --Unfulfilled Quantity

'|| fnd_global.newline;

  else
    l_sel_clause :=  l_sel_clause
		|| fnd_global.newline
		||  '
	null POA_ATTRIBUTE1,		--Description
 	null POA_ATTRIBUTE2,		--UOM
	null POA_MEASURE1,		--Unfulfilled Quantity'

|| fnd_global.newline;

  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2  POA_MEASURE2,         --Total Requisition Lines
	oset.POA_MEASURE3  POA_MEASURE3,	 --Lines Pending Processing
	oset.POA_MEASURE4  POA_MEASURE4,	 --Lines Processed Pending Fulfillment
	oset.POA_MEASURE5  POA_MEASURE5,         --Lines Past Expected Date
	oset.POA_MEASURE6  POA_MEASURE6,         --PO Revisions
	oset.POA_MEASURE7  POA_MEASURE7,	 --Grand Total for Total Column
	oset.POA_MEASURE8  POA_MEASURE8,	 --Grand Total for Pending Processing
        oset.POA_MEASURE9  POA_MEASURE9,	 --Grand Total for Processed Pending Fulfillment
	oset.POA_MEASURE10 POA_MEASURE10,	 --Grand Total for Lines Past Expected Date
	oset.POA_MEASURE11 POA_MEASURE11,        --Grand total for PO Revisions
	oset.POA_MEASURE3 POA_ATTRIBUTE4,        --Pending Processing for graph
	oset.POA_MEASURE4 POA_ATTRIBUTE5,        --Processed Pending Fulfillment for graph
	oset.POA_MEASURE2 POA_ATTRIBUTE6,        --Unfulfilled Lines for graph
	oset.POA_MEASURE5 POA_ATTRIBUTE7,        --Lines Past Expected Date for graph';

   l_sel_clause := l_sel_clause || '
   ''pFunctionName=POA_DBI_UFR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=-2'' POA_ATTRIBUTE11,
   ''pFunctionName=POA_DBI_UFR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=-2'' POA_ATTRIBUTE13,
   ''pFunctionName=POA_DBI_UFR_PR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=2'' POA_ATTRIBUTE14,
   ''pFunctionName=POA_DBI_UFR_PR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=2'' POA_ATTRIBUTE15,
   ''pFunctionName=POA_DBI_UFR_FR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=3'' POA_ATTRIBUTE16,
   ''pFunctionName=POA_DBI_UFR_FR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=3'' POA_ATTRIBUTE17,
   ''pFunctionName=POA_DBI_UFR_PED_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1'' POA_ATTRIBUTE18,
   ''pFunctionName=POA_DBI_UFR_PED_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1'' POA_ATTRIBUTE19,
   ''pFunctionName=POA_DBI_UFR_POR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=-2'' POA_ATTRIBUTE20 ';


   l_sel_clause := l_sel_clause ||
   ' from
    (select * from (select * from (select
     (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;
if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
 end if;
l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE1';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE2,POA_MEASURE3,
                       POA_MEASURE4,POA_MEASURE5,
                       POA_MEASURE7,POA_MEASURE8,POA_MEASURE9,POA_MEASURE10,POA_MEASURE6,POA_MEASURE11
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_unfulf_qty,0)) POA_MEASURE1, ';

   end if;
l_sel_clause := l_sel_clause
	|| ' nvl(c_unfulf_cnt,0)	       POA_MEASURE2,
             (nvl(c_unfulf_cnt,0)-nvl(c_pen_fulf_cnt,0)) POA_MEASURE3,
	     nvl(c_pen_fulf_cnt,0)	       POA_MEASURE4,
             nvl(c_unfulf_ped_cnt,0)	       POA_MEASURE5,
	     nvl(c_unfulf_cnt_total,0)         POA_MEASURE7,
            (nvl(c_unfulf_cnt_total,0)-nvl(c_pen_fulf_cnt_total,0)) POA_MEASURE8,
	     nvl(c_pen_fulf_cnt_total,0)       POA_MEASURE9,
	     nvl(c_unfulf_ped_cnt_total,0)     POA_MEASURE10,
	     nvl(c_unful_po_revisions,0)       POA_MEASURE6,
	     nvl(c_unful_po_revisions_total,0) POA_MEASURE11
	   ';

return l_sel_clause;
END get_sum_sel_clause;

FUNCTION get_sum_rpt_filter_where(p_view_by in VARCHAR2) return VARCHAR2
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

PROCEDURE age_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
        l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_query               varchar2(10000);
	l_view_by             varchar2(120);
	l_view_by_col         varchar2(120);
        l_as_of_date          date;
        l_prev_as_of_date     date;
        l_xtd                 varchar2(10);
        l_comparison_type     varchar2(1);
        l_nested_pattern      number;
        l_cur_suffix          varchar2(2);
        l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
	l_where_clause        VARCHAR2(2000);
	l_mv                  VARCHAR2(30);
	l_view_by_value       varchar2(30);
	l_bucket_rec          BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE;
        ERR_MSG               VARCHAR2(100);
        ERR_CDE               NUMBER;
BEGIN
      l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
      l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();
      l_comparison_type := 'Y';
      poa_dbi_sutil_pkg.process_parameters(p_param
					, l_view_by
					, l_view_by_col
					, l_view_by_value
					, l_comparison_type
					, l_xtd
					, l_as_of_date
					, l_prev_as_of_date
					, l_cur_suffix
					, l_nested_pattern
					, l_where_clause
					, l_mv
					, l_join_tbl
					, l_in_join_tbl
					, x_custom_output
					, p_trend => 'N'
					, p_func_area => 'PO'
					, p_version => '7.1'
					, p_role => 'VPP'
	                                , p_mv_set => 'REQS');
  poa_dbi_util_pkg.add_bucket_columns(
                    p_short_name => 'POA_DBI_UFR_BUCKET'
                   ,p_col_tbl => l_col_tbl
                   ,p_col_name => 'unfulfilled_cnt_age'
                   ,p_alias_name => 'unfulf_cnt_age'
                   ,x_bucket_rec => l_bucket_rec
                   ,p_grand_total => 'Y'
                   ,p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                   ,p_to_date_type => 'NA');

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unfulfilled_cnt'
			      , 'unfulf_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'num_days_unfulfilled'
			      , 'num_days_unfulf'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'unfulfilled_qty'
                               ,'unfulf_qty'
			       , p_grand_total => 'N'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');
  end if;


  l_query := get_age_sel_clause(
		  l_view_by
		, l_view_by_col,l_bucket_rec) || ' from' ||
		poa_dbi_template_pkg.status_sql(
					l_mv,
					l_where_clause,
					 l_join_tbl,
					 p_use_windowing => 'P',
					 p_col_name => l_col_tbl,
					 p_use_grpid => 'N',
					 p_filter_where => get_age_filter_where(l_view_by),
					 p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
 END age_sql;


 FUNCTION get_age_sel_clause(
	  p_view_by_dim in VARCHAR2
	, p_view_by_col in VARCHAR2
	 , p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE)

return VARCHAR2
  IS
  l_sel_clause varchar2(4000);
  BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                           ,'7.1');

 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||  '
	v.description POA_ATTRIBUTE1,	            --Description
        v2.description POA_ATTRIBUTE2,              --UOM
        oset.POA_MEASURE1 POA_MEASURE1,	            --Unfulfilled Quantity

'|| fnd_global.newline;

  else
    l_sel_clause :=  l_sel_clause
		|| fnd_global.newline
		||  '
	null POA_ATTRIBUTE1,		--Description
 	null POA_ATTRIBUTE2,		--UOM
	null POA_MEASURE1,		--Unfulfilled Quantity'

|| fnd_global.newline;

  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2 POA_MEASURE2,		--Average Age (Days)
	oset.POA_MEASURE3 POA_MEASURE3		--Unfulfilled Lines'

	|| fnd_global.newline
        || poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE4'
             , p_alias_name => 'POA_MEASURE4'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N')
        || fnd_global.newline
        || ',

	oset.POA_MEASURE5 POA_MEASURE5,		--Grand Total for Average Age (Days)
	oset.POA_MEASURE6 POA_MEASURE6          --Grand Total for Unfulfilled Lines'
	|| fnd_global.newline
        || poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE7'
             , p_alias_name => 'POA_MEASURE7'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N')
	|| fnd_global.newline ;


        l_sel_clause := l_sel_clause ||
   	  poa_dbi_util_pkg.get_bucket_drill_url(
		  p_bucket_rec
		, 'POA_ATTRIBUTE5'
		,
'''pFunctionName=POA_DBI_UFR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=-2&POA_BUCKET+REQUISITION_AGING='
		, ''''
		, p_add_bucket_num => 'Y') || ',';
     l_sel_clause := l_sel_clause || '
      ''pFunctionName=POA_DBI_UFR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=-2'' POA_ATTRIBUTE6 ';


  l_sel_clause := l_sel_clause || ' from
     (select * from (select * from (select
	(rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
 end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE1';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE2,POA_MEASURE3'

		       || fnd_global.newline
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'POA_MEASURE4'
                          , p_alias_name => 'POA_MEASURE4'
                          , p_prefix => ''
                          , p_suffix => ''
                          , p_total_flag => 'N')
                      || fnd_global.newline ||
		      ' ,POA_MEASURE5,
                       POA_MEASURE6'
		       || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'POA_MEASURE7'
                          , p_alias_name => 'POA_MEASURE7'
                          , p_prefix => ''
                          , p_suffix => ''
                          , p_total_flag => 'N')
                      || fnd_global.newline || '
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_unfulf_qty,0)) POA_MEASURE1, ';

   end if;
l_sel_clause := l_sel_clause
	|| ' nvl(c_num_days_unfulf,0)/decode(c_unfulf_cnt,0,null,c_unfulf_cnt) POA_MEASURE2,
             nvl(c_unfulf_cnt,0)	 POA_MEASURE3';

 l_sel_clause := l_sel_clause || fnd_global.newline
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'c_unfulf_cnt_age'
                          , p_alias_name => 'POA_MEASURE4'
                          , p_prefix => 'nvl('
                          , p_suffix => ',0)'
                          , p_total_flag => 'N')
                      || fnd_global.newline || ',
             nvl(c_num_days_unfulf_total,0)/decode(c_unfulf_cnt_total,0,null,c_unfulf_cnt_total) POA_MEASURE5,

             nvl(c_unfulf_cnt_total,0)	 POA_MEASURE6'

	     || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'c_unfulf_cnt_age'
                          , p_alias_name => 'POA_MEASURE7'
                          , p_prefix => 'nvl('
                          , p_suffix => ',0)'
                          , p_total_flag => 'Y')
	|| fnd_global.newline;

return l_sel_clause;
END get_age_sel_clause;

FUNCTION get_age_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE3';

 if(p_view_by = 'ITEM+POA_ITEMS') then
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE1';
 end if;

   return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;


  PROCEDURE dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
		       x_custom_sql  OUT NOCOPY VARCHAR2,
		       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
	l_query varchar2(10000);
	l_option number;
	l_cur_suffix varchar2(2);
	l_where_clause varchar2(2000);
	l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_in_join_tables    VARCHAR2(240) ;
	l_context number;
	l_bucket varchar2(400);
	l_context_where VARCHAR2(240);
	l_aging_where VARCHAR2(440) ;
        l_rownum_where varchar2(300);
        l_vo_max_fetch_size varchar2(100);
   BEGIN
  l_aging_where := ' ';
   poa_dbi_sutil_pkg.drill_process_parameters(p_param, l_cur_suffix,
	l_where_clause, l_in_join_tbl, 'PO', '7.1', 'VPP','REQS');

  IF(l_in_join_tbl is not null) then
     FOR i in 1 .. l_in_join_tbl.COUNT
       LOOP
          l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
       END LOOP;
  END IF;

 FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'POA_ATTRIBUTE10')
      THEN l_context := p_param(i).parameter_id;
    END IF;
    IF (p_param(i).parameter_name = 'POA_BUCKET+REQUISITION_AGING')
	THEN l_bucket := p_param(i).parameter_id;
    END IF;
  END LOOP;

IF(l_context = 1) THEN   	-- Past Expected Date
   l_context_where := ' and fact.expected_date <= to_date(&REQ_FACT_UPDATE_DATE,''DD/MM/YYYY HH24:MI:SS'') ';
   poa_dbi_sutil_pkg.bind_reqfact_date(x_custom_output);
ELSIF(l_context=2) THEN		-- Pending Processing
   l_context_where := ' and fact.po_approved_date is null';
ELSIF(l_context = 3) THEN 	-- Processed Pending Fulfill
   l_context_where := ' and fact.po_approved_date is not null';
END IF;

if(l_bucket is not null) then
	l_aging_where := 'and (&RANGE_LOW is null or '
		|| '(to_date(&REQ_FACT_UPDATE_DATE,''DD/MM/YYYY HH24:MI:SS'')-fact.req_approved_date)'
		|| ' >= &RANGE_LOW)'
		|| fnd_global.newline
		||' and (&RANGE_HIGH is null or '
		||'(to_date(&REQ_FACT_UPDATE_DATE,''DD/MM/YYYY HH24:MI:SS'')-fact.req_approved_date)'
		|| ' < &RANGE_HIGH)';

	poa_dbi_util_pkg.bind_low_high(p_param
		, 'POA_DBI_UFR_BUCKET'
		, 'POA_BUCKET+REQUISITION_AGING'
		, '&RANGE_LOW'
		, '&RANGE_HIGH'
		, x_custom_output);
else
         l_aging_where := '';
end if;

 poa_dbi_sutil_pkg.bind_reqfact_date(x_custom_output);

    /* Determine the l_rownum_where. If VO_MAX_FETCH_SIZE is null then dont filter any rows */
    select fnd_profile.value('VO_MAX_FETCH_SIZE')
    into l_vo_max_fetch_size
    from dual;

    if (l_vo_max_fetch_size is not null) then
      l_rownum_where := ' where rownum < '||l_vo_max_fetch_size||' + 1 ';
    else
      l_rownum_where := ' ';
    end if;

    x_custom_sql :=
'select  prh.segment1 POA_MEASURE1,		-- Requisition Number
        prl.line_num POA_MEASURE2,		-- Requisition Line Num
        rorg.name POA_ATTRIBUTE1,		-- Req OU
	substrb(perf.first_name,1,1) || ''. ''|| perf.last_name POA_ATTRIBUTE2,	-- Requester
	i.POA_ATTRIBUTE3 POA_ATTRIBUTE3,	-- Req Approved Date
        i.POA_ATTRIBUTE8 POA_ATTRIBUTE8,	-- Processed Date
        i.POA_ATTRIBUTE4 POA_ATTRIBUTE4,	-- Expected Date
	item.value POA_ATTRIBUTE5,		-- Item
	supplier.value POA_ATTRIBUTE6,		-- Supplier
	i.POA_MEASURE3 POA_MEASURE3,		-- amount
        decode(por.po_release_id,null,
	       poh.segment1,
               poh.segment1||''-''||por.release_num) POA_MEASURE4,-- PO Number
	porg.name POA_ATTRIBUTE7,		-- PO Org
	i.POA_MEASURE5 POA_MEASURE5,		-- PO Revisions
	i.POA_MEASURE6 POA_MEASURE6,		-- Amount total
	i.POA_MEASURE7 POA_MEASURE7,		-- Revisions Total
        i.req_header_id POA_ATTRIBUTE13,       -- Req Header Id
	decode(poh.segment1,null,null,
	   decode(i.POA_ATTRIBUTE8,null,
              decode(pll.po_release_id,null,
                       ''pFunctionName=POA_DBI_PDF_DRILL&DocumentId='' || poh.po_header_id || ''&RevisionNum=''
		        || poh.revision_num || ''&LanguageCode='' || userenv(''LANG'')||''&DocumentType=PO&DocumentSubtype=STANDARD&OrgId='' || poh.org_id
			|| ''&UserSecurity=Y&StoreFlag=N&ViewOrCommunicate=View&CallFromForm=N'',
                       ''pFunctionName=POA_DBI_PDF_DRILL&DocumentId='' || por.po_release_id || ''&RevisionNum=''
		        || por.revision_num || ''&LanguageCode='' || userenv(''LANG'')||''&DocumentType=RELEASE&DocumentSubtype=BLANKET&OrgId='' || por.org_id
			|| ''&UserSecurity=Y&StoreFlag=N&ViewOrCommunicate=View&CallFromForm=N'')
	         ,''pFunctionName=POA_DBI_ISP_DRILL&PoHeaderId=''||poh.po_header_id ||''&PoReleaseId=''||pll.po_release_id
		        ||''&addBreadCrumb=Y&retainAM=Y'')) POA_ATTRIBUTE14,
	decode(i.POA_ATTRIBUTE8,null,null,''pFunctionName=POA_DBI_PCH_DRILL&CorePO=Y&CompareTo=ALL&addBreadCrumb=Y&retainAM=Y&PoHeaderId=''
|| poh.po_header_id
||''&PoReleaseId=''||pll.po_release_id
|| ''&PoNum='' || decode(por.po_release_id, null, poh.segment1, poh.segment1 || ''-'' || por.release_num)
|| ''&RevisionNum=''||i.POA_MEASURE5) POA_ATTRIBUTE15
from
(select * from (select * from
	(select (rank() over
		(&ORDER_BY_CLAUSE nulls last, req_header_id ,
		req_line_id))-1 rnk,
		req_header_id,
		req_line_id,
		req_creation_ou_id,
		requester_id,
		POA_ATTRIBUTE3 POA_ATTRIBUTE3,
		POA_ATTRIBUTE4 POA_ATTRIBUTE4,
		POA_ATTRIBUTE8 POA_ATTRIBUTE8,
		po_item_id,
		supplier_id,
		nvl(POA_MEASURE3,0) POA_MEASURE3,
		nvl(POA_MEASURE5,0) POA_MEASURE5,
		nvl(POA_MEASURE6,0) POA_MEASURE6,
		nvl(POA_MEASURE7,0) POA_MEASURE7,
		po_line_location_id,
		po_creation_ou_id
	from(
		select
			fact.req_header_id ,
			fact.req_line_id,
			fact.req_creation_ou_id,
			fact.requester_id,
			fact.req_approved_date POA_ATTRIBUTE3,
			fact.expected_date POA_ATTRIBUTE4,
			fact.po_approved_date POA_ATTRIBUTE8,
			fact.po_item_id,
			fact.supplier_id,
			fact.line_amount_'
|| l_cur_suffix ||
' POA_MEASURE3,
			po_revisions POA_MEASURE5,
			sum(fact.line_amount_'
|| l_cur_suffix || 	') over() POA_MEASURE6,
	       		sum(po_revisions)over() POA_MEASURE7,
			fact.po_line_location_id,
			fact.po_creation_ou_id
		  from
			poa_dbi_req_f fact '  || l_in_join_tables || '
   where
                     fact.req_approved_date is not null
		 and fact.req_fulfilled_date is null' ||  '
  		 and fact.include_in_ufr=''Y'' ' ||  l_where_clause || fnd_global.newline ||
		 l_context_where || fnd_global.newline ||
         l_aging_where ||
			')) i2 where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1) ) i3 '||l_rownum_where||' ) i,
			po_requisition_headers_all prh,
			po_requisition_lines_all prl,
			po_headers_all poh,
			po_line_locations_all pll,
			poa_items_v item,
			poa_suppliers_v supplier,
			per_all_people_f perf,
			hr_all_organization_units_vl rorg,
			hr_all_organization_units_vl porg,
                        po_releases_all por
		     where
		    i.req_header_id=prh.requisition_header_id
		    and i.req_line_id=prl.requisition_line_id
		    and prh.requisition_header_id=prl.requisition_header_id
		    and i.po_item_id=item.id
		    and i.req_creation_ou_id=rorg.organization_id
		    and i.requester_id=perf.person_id
		    and sysdate between perf.effective_start_date and perf.effective_end_date
		    and i.supplier_id=supplier.id(+)
		    and i.po_line_location_id=pll.line_location_id(+)
		    and pll.po_header_id=poh.po_header_id(+)
		    and poh.org_id=porg.organization_id(+)
                    and pll.po_header_id=por.po_header_id(+)
                    and pll.po_release_id=por.po_release_id(+)
		    ORDER BY rnk';

poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);

end;


end poa_dbi_ufr_pkg;


/
