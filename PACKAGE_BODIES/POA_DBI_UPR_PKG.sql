--------------------------------------------------------
--  DDL for Package Body POA_DBI_UPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_UPR_PKG" 
/* $Header: poadbiuprb.pls 120.6 2006/07/29 08:29:18 sriswami noship $ */
AS
--
   FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2
                                ,p_view_by_col in VARCHAR2) return VARCHAR2;
   FUNCTION get_amt_sel_clause(p_view_by_dim in VARCHAR2
                                ,p_view_by_col in VARCHAR2
                                , p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE)
                               return VARCHAR2;

   FUNCTION get_sum_sel_clause(p_view_by_dim in VARCHAR2
                           ,p_view_by_col in VARCHAR2) return VARCHAR2;
   FUNCTION get_age_sel_clause( p_view_by_dim in VARCHAR2
                               ,p_view_by_col in VARCHAR2
                               ,p_bucket_rec in  BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE)
                              return VARCHAR2;
   FUNCTION get_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
   FUNCTION get_amt_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
   FUNCTION get_age_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
   FUNCTION get_sum_rpt_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
--   FUNCTION get_dtl_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;

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
			      ,'num_days_unprocessed'
			      , 'num_days_unproc'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

   poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unprocessed_cnt'
			      , 'unproc_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unprocessed_ped_cnt'
			      , 'unproc_ped_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unprocessed_amt_' || l_cur_suffix
			      , 'unproc_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

 if(l_view_by = 'ITEM+POA_ITEMS') then
   poa_dbi_util_pkg.add_column(l_col_tbl
                              , 'unprocessed_qty'
                              , 'unproc_qty'
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
end;

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
'      v.description     POA_ATTRIBUTE1,	--Description
       v2.description	 POA_ATTRIBUTE2,	--UOM
       oset.POA_MEASURE8 POA_MEASURE8,		--Quantity'
       	|| fnd_global.newline;
   else
    l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||
'	null POA_ATTRIBUTE1,		--Description
	null POA_ATTRIBUTE2,		--UOM
	null POA_MEASURE8,		--Quantity'
	|| fnd_global.newline;
   end if;


   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE1 POA_MEASURE1,		--Unprocessed Lines
	oset.POA_PERCENT1 POA_PERCENT1,		--Percent of Total
	oset.POA_MEASURE1 POA_MEASURE7,		--Unprocessed Lines for graph 2
	oset.POA_MEASURE2 POA_MEASURE2,		--Lines Past Expected Date
	oset.POA_MEASURE3 POA_MEASURE3,		--Unprocessed Amount
	oset.POA_MEASURE10  POA_MEASURE10,	--Average Age (Days)
	oset.POA_MEASURE4 POA_MEASURE4,		--Grand Total Unfulfilled Lines
	oset.POA_PERCENT3 POA_PERCENT3,		--Grand Total Percent of Total
	oset.POA_MEASURE5 POA_MEASURE5,		--Grand Total Lines Past Exp Date
	oset.POA_MEASURE6 POA_MEASURE6,		--Grand Total Unprocessed Amount
	oset.POA_MEASURE11  POA_MEASURE11,	 --Grand Total Average Age Days
	oset.POA_MEASURE2 POA_MEASURE9,		 --Lines past exp for graph';


   l_sel_clause := l_sel_clause || '
   ''pFunctionName=POA_DBI_UPR_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_PO_CAT&pParamIds=Y'' POA_ATTRIBUTE7,
   ''pFunctionName=POA_DBI_UPR_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_PO_CAT&pParamIds=Y'' POA_ATTRIBUTE8,
   ''pFunctionName=POA_DBI_UPR_PED_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=6'' POA_ATTRIBUTE9,
   ''pFunctionName=POA_DBI_UPR_PED_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=6'' POA_ATTRIBUTE10,
   ''pFunctionName=POA_DBI_UPR_AMT_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_PO_CAT'' POA_ATTRIBUTE11,
   ''pFunctionName=POA_DBI_UPR_AGE_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_PO_CAT'' POA_ATTRIBUTE12 ';


   l_sel_clause := l_sel_clause ||
   ' from (select * from (select * from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
  l_sel_clause := l_sel_clause || ',base_uom';
 end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;

  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
   l_sel_clause := l_sel_clause ||
                    ' , base_uom,
                      POA_MEASURE8';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE1,POA_PERCENT1,
                       POA_MEASURE2,POA_MEASURE3,
		       POA_MEASURE4, POA_PERCENT3,
                       POA_MEASURE5,POA_MEASURE6,
                       POA_MEASURE10, POA_MEASURE11
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause := l_sel_clause || ' base_uom,
      decode(base_uom,null,to_number(null),nvl(c_unproc_qty,0)) POA_MEASURE8,';
    end if;

 l_sel_clause := l_sel_clause || ' nvl(c_unproc_cnt,0) POA_MEASURE1,
     		' || poa_dbi_util_pkg.rate_clause('c_unproc_cnt','c_unproc_cnt_total', 'P') || ' POA_PERCENT1,
                nvl(c_unproc_ped_cnt,0) POA_MEASURE2,
                nvl(c_unproc_amt,0) POA_MEASURE3,
		nvl(c_unproc_cnt_total,0) POA_MEASURE4,
		decode(c_unproc_cnt_total,0,null,100) POA_PERCENT3,
                nvl(c_unproc_ped_cnt_total,0) POA_MEASURE5,
                nvl(c_unproc_amt_total,0) POA_MEASURE6,
		' || poa_dbi_util_pkg.rate_clause('c_num_days_unproc','c_unproc_cnt', 'NP') || ' POA_MEASURE10,
	' || poa_dbi_util_pkg.rate_clause('c_num_days_unproc_total','c_unproc_cnt_total', 'NP') || ' POA_MEASURE11
';

   return l_sel_clause;
 END;


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
    l_col_tbl(5) := 'POA_MEASURE10';

 if(p_view_by = 'ITEM+POA_ITEMS') then
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE8';
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
    l_comparison_type :='Y';
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

   poa_dbi_util_pkg.add_bucket_columns(
                    p_short_name => 'POA_DBI_UPR_BUCKET'
                   ,p_col_tbl => l_col_tbl
                   ,p_col_name => 'unprocessed_amt_' || l_cur_suffix || '_age'
                   ,p_alias_name => 'unproc_amt_age'
                   ,x_bucket_rec => l_bucket_rec
                   ,p_grand_total => 'Y'
                   ,p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                   ,p_to_date_type => 'NA');

   poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unprocessed_amt_' || l_cur_suffix
			      , 'unproc_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_src_amt_' || l_cur_suffix
			      , 'pen_src_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_buyer_wk_amt_' || l_cur_suffix
			      , 'pen_buyer_wk_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_po_submit_amt_' || l_cur_suffix
			      , 'pen_po_submit_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_po_appr_amt_' || l_cur_suffix
			      , 'pen_po_appr_amt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

 if(l_view_by = 'ITEM+POA_ITEMS') then
   poa_dbi_util_pkg.add_column(l_col_tbl
                              , 'unprocessed_qty'
                              , 'unproc_qty'
                              , p_grand_total => 'N'
                              , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                              , p_to_date_type => 'NA');

 end if;

    l_query  := get_amt_sel_clause(l_view_by
                                  ,l_view_by_col
                                  ,l_bucket_rec) || ' from ' ||
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
end;

FUNCTION get_amt_sel_clause(p_view_by_dim in VARCHAR2
                          ,p_view_by_col in VARCHAR2
                          , p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE)
          return VARCHAR2
 IS
  l_sel_clause varchar2(8000);

  BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                            ,'7.1');


  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||
'      v.description     POA_ATTRIBUTE1,	--Description
       v2.description	 POA_ATTRIBUTE2,	--UOM
       oset.POA_MEASURE1 POA_MEASURE1,		--Quantity'
		|| fnd_global.newline;
   else
    l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||
'	null POA_ATTRIBUTE1,		--Description
 	null POA_ATTRIBUTE2,		--UOM
	null POA_MEASURE1,		--Quantity'
		|| fnd_global.newline;
   end if;


   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2 POA_MEASURE2,		--Unprocessed Lines Total
	oset.POA_MEASURE3 POA_MEASURE3,  	-- Lines Pending Sourcing
	oset.POA_MEASURE4 POA_MEASURE4,      -- Lines Pending Buyers Workbench
	oset.POA_MEASURE5 POA_MEASURE5,		--Lines Pending PO submit
	oset.POA_MEASURE6 POA_MEASURE6		--Lines Pending PO Approval '
        || fnd_global.newline
        || poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE7'
             , p_alias_name => 'POA_MEASURE7'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N')
        || fnd_global.newline
        || ' ,oset.POA_MEASURE8 POA_MEASURE8,    -- Grand Total for Total
             oset.POA_MEASURE9  POA_MEASURE9,    -- Grand Total for Pending Src
             oset.POA_MEASURE10 POA_MEASURE10,   -- Grand Total for Buyers Wkbnch
             oset.POA_MEASURE11 POA_MEASURE11,   -- Grand Total for PO Submit
             oset.POA_MEASURE12 POA_MEASURE12   -- Grand Total for PO Approval '
        || fnd_global.newline
        || poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE13'
             , p_alias_name => 'POA_MEASURE13'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N')
        || fnd_global.newline
        || ',oset.POA_MEASURE3 POA_MEASURE14,
            oset.POA_MEASURE4 POA_MEASURE15,
            oset.POA_MEASURE5 POA_MEASURE16,
            oset.POA_MEASURE6 POA_MEASURE17' ;


        l_sel_clause := l_sel_clause ||
   	  poa_dbi_util_pkg.get_bucket_drill_url(
		  p_bucket_rec
		, 'POA_ATTRIBUTE5'
		,
'''pFunctionName=POA_DBI_UPR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1&POA_BUCKET+REQUISITION_AGING='
		, ''''
		, p_add_bucket_num => 'Y') || ',';



    l_sel_clause := l_sel_clause || '
    ''pFunctionName=POA_DBI_UPR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1'' POA_ATTRIBUTE7,
    ''pFunctionName=POA_DBI_UPR_SRC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=2'' POA_ATTRIBUTE8,
    ''pFunctionName=POA_DBI_UPR_SRC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=2'' POA_ATTRIBUTE9,
    ''pFunctionName=POA_DBI_UPR_BW_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=3'' POA_ATTRIBUTE10,
    ''pFunctionName=POA_DBI_UPR_BW_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=3'' POA_ATTRIBUTE11,
    ''pFunctionName=POA_DBI_UPR_BSA_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=4'' POA_ATTRIBUTE12,
    ''pFunctionName=POA_DBI_UPR_BSA_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=4'' POA_ATTRIBUTE13,
    ''pFunctionName=POA_DBI_UPR_PA_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=5'' POA_ATTRIBUTE14,
    ''pFunctionName=POA_DBI_UPR_PA_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=5'' POA_ATTRIBUTE15 ';



  l_sel_clause := l_sel_clause || 'from
     (select * from (select * from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;


 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
  l_sel_clause := l_sel_clause || ',base_uom';
 end if;

   l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;

  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
   l_sel_clause := l_sel_clause ||
                    ' , base_uom,
                      POA_MEASURE1';
  end if;

   l_sel_clause := l_sel_clause || ',
                       POA_MEASURE2,POA_MEASURE3,
		       POA_MEASURE4, POA_MEASURE5,
                       POA_MEASURE6'
                      || fnd_global.newline
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'POA_MEASURE7'
                          , p_alias_name => 'POA_MEASURE7'
                          , p_prefix => ''
                          , p_suffix => ''
                          , p_total_flag => 'N')
                      || fnd_global.newline ||
                      ' , POA_MEASURE8, POA_MEASURE9,
                       POA_MEASURE10, POA_MEASURE11,
                       POA_MEASURE12 '
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'POA_MEASURE13'
                          , p_alias_name => 'POA_MEASURE13'
                          , p_prefix => ''
                          , p_suffix => ''
                          , p_total_flag => 'N')
                      || fnd_global.newline ||
'    from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause := l_sel_clause || ' base_uom,
      decode(base_uom,null,null,nvl(c_unproc_qty,0)) POA_MEASURE1,';
    end if;
 l_sel_clause := l_sel_clause || ' nvl(c_unproc_amt,0) POA_MEASURE2,
		nvl(c_pen_src_amt,0) POA_MEASURE3,
		nvl(c_pen_buyer_wk_amt,0) POA_MEASURE4,
		nvl(c_pen_po_submit_amt,0) POA_MEASURE5,
		nvl(c_pen_po_appr_amt,0) POA_MEASURE6
';

 l_sel_clause := l_sel_clause || fnd_global.newline
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'c_unproc_amt_age'
                          , p_alias_name => 'POA_MEASURE7'
                          , p_prefix => 'nvl('
                          , p_suffix => ',0)'
                          , p_total_flag => 'N')
                      || fnd_global.newline || ',
                  nvl(c_unproc_amt_total,0) POA_MEASURE8,
                  nvl(c_pen_src_amt_total,0) POA_MEASURE9,
                  nvl(c_pen_buyer_wk_amt_total,0) POA_MEASURE10,
                  nvl(c_pen_po_submit_amt_total,0) POA_MEASURE11,
                  nvl(c_pen_po_appr_amt_total,0) POA_MEASURE12'
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'c_unproc_amt_age'
                          , p_alias_name => 'POA_MEASURE13'
                          , p_prefix => 'nvl('
                          , p_suffix => ',0)'
                          , p_total_flag => 'Y')
                      || fnd_global.newline ;

   return l_sel_clause;
 END;


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

   poa_dbi_util_pkg.add_bucket_columns(
                    p_short_name => 'POA_DBI_UPR_BUCKET'
                   ,p_col_tbl => l_col_tbl
                   ,p_col_name => 'unprocessed_cnt_age'
                   ,p_alias_name => 'unproc_cnt_age'
                   ,x_bucket_rec => l_bucket_rec
                   ,p_grand_total => 'Y'
                   ,p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                   ,p_to_date_type => 'NA');

   poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'num_days_unprocessed'
			      , 'num_days_unproc'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unprocessed_cnt'
			      , 'unproc_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


 if(l_view_by = 'ITEM+POA_ITEMS') then
   poa_dbi_util_pkg.add_column(l_col_tbl
                              , 'unprocessed_qty'
                              , 'unproc_qty'
                              , p_grand_total => 'N'
                              , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                              , p_to_date_type => 'NA');

 end if;
    l_query  := get_age_sel_clause(l_view_by
                                  ,l_view_by_col
                                  ,l_bucket_rec) || ' from ' ||
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

end;


FUNCTION get_age_sel_clause(p_view_by_dim in VARCHAR2
                          ,p_view_by_col in VARCHAR2
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
		||
'      v.description     POA_ATTRIBUTE1,	--Description
       v2.description	 POA_ATTRIBUTE2,	--UOM
       oset.POA_MEASURE1 POA_MEASURE1,		--Quantity'
		|| fnd_global.newline;
   else
    l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||
'	null POA_ATTRIBUTE1,		--Description
 	null POA_ATTRIBUTE2,		--UOM
	null POA_MEASURE1,		--Quantity'
		|| fnd_global.newline;
   end if;


   l_sel_clause := l_sel_clause ||
 '      oset.POA_MEASURE7 POA_MEASURE7,		-- Avg Age (days)
	oset.POA_MEASURE2 POA_MEASURE2  	-- Unprocessed Lines'
        || fnd_global.newline
        || poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE3'
             , p_alias_name => 'POA_MEASURE3'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N')
        || fnd_global.newline || ',
	oset.POA_MEASURE8 POA_MEASURE8,      --  Grand Total by Avg Days
	oset.POA_MEASURE4 POA_MEASURE4		-- Grand Total Unprocessed Lns'
        || fnd_global.newline
        || poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE5'
             , p_alias_name => 'POA_MEASURE5'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N')
        || fnd_global.newline ;

        l_sel_clause := l_sel_clause ||
   	  poa_dbi_util_pkg.get_bucket_drill_url(
		  p_bucket_rec
		, 'POA_ATTRIBUTE5'
		,
'''pFunctionName=POA_DBI_UPR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1&POA_BUCKET+REQUISITION_AGING='
		, ''''
		, p_add_bucket_num => 'Y') || ',';


     l_sel_clause := l_sel_clause || '
      ''pFunctionName=POA_DBI_UPR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_BUCKET+REQUISITION_AGING=&POA_ATTRIBUTE10=1'' POA_ATTRIBUTE7 ';

  l_sel_clause := l_sel_clause || ' from
	 (select * from (select * from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
  l_sel_clause := l_sel_clause || ',base_uom';
 end if;
l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;

  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
   l_sel_clause := l_sel_clause ||
                    ' , base_uom,
                      POA_MEASURE1';
  end if;
   l_sel_clause := l_sel_clause || ',
                       POA_MEASURE7,POA_MEASURE2'
                      || fnd_global.newline
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'POA_MEASURE3'
                          , p_alias_name => 'POA_MEASURE3'
                          , p_prefix => ''
                          , p_suffix => ''
                          , p_total_flag => 'N')
                      || fnd_global.newline ||
                      ' , POA_MEASURE8, POA_MEASURE4'
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'POA_MEASURE5'
                          , p_alias_name => 'POA_MEASURE5'
                          , p_prefix => ''
                          , p_suffix => ''
                          , p_total_flag => 'N')
                      || fnd_global.newline ||
'    from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause := l_sel_clause || ' base_uom,
      decode(base_uom,null,to_number(null),nvl(c_unproc_qty,0)) POA_MEASURE1,';
    end if;
 l_sel_clause := l_sel_clause || ' nvl(c_num_days_unproc,0)/decode(c_unproc_cnt,0,null,c_unproc_cnt) POA_MEASURE7,
		nvl(c_unproc_cnt,0) POA_MEASURE2
';

 l_sel_clause := l_sel_clause || fnd_global.newline
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'c_unproc_cnt_age'
                          , p_alias_name => 'POA_MEASURE3'
                          , p_prefix => 'nvl('
                          , p_suffix => ',0)'
                          , p_total_flag => 'N')
                      || fnd_global.newline || ',
                  nvl(c_num_days_unproc_total,0)/decode(c_unproc_cnt_total,0,null,c_unproc_cnt_total) POA_MEASURE8,
                  nvl(c_unproc_cnt_total,0) POA_MEASURE4'
                      || poa_dbi_util_pkg.get_bucket_outer_query(
                            p_bucket_rec
                          , p_col_name => 'c_unproc_cnt_age'
                          , p_alias_name => 'POA_MEASURE5'
                          , p_prefix => 'nvl('
                          , p_suffix => ',0)'
                          , p_total_flag => 'Y')
                      || fnd_global.newline ;

   return l_sel_clause;
 END;


FUNCTION get_age_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE7';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE2';

 if(p_view_by = 'ITEM+POA_ITEMS') then
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE1';
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
			      ,'pen_src_cnt'
			      ,'pen_src_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


   poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_buyer_wk_cnt'
			      ,'pen_buyer_wk_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


   poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_po_submit_cnt'
			      ,'pen_po_submit_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


   poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'pen_po_appr_cnt'
			      ,'pen_po_appr_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');



   poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unprocessed_cnt'
			      , 'unproc_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');


  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unprocessed_ped_cnt'
			      , 'unproc_ped_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

 poa_dbi_util_pkg.add_column(l_col_tbl
 			      ,'unprocessed_emer_cnt'
			      , 'unproc_emer_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'unprocessed_urg_cnt'
			      , 'unproc_urg_cnt'
			      , p_grand_total => 'Y'
			      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
			      , p_to_date_type => 'NA');

 if(l_view_by = 'ITEM+POA_ITEMS') then
   poa_dbi_util_pkg.add_column(l_col_tbl
                              , 'unprocessed_qty'
                              , 'unproc_qty'
                              , p_grand_total => 'N'
                              , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                              , p_to_date_type => 'NA');

 end if;
  l_query := get_sum_sel_clause(l_view_by, l_view_by_col) || ' from '||
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

end;

FUNCTION get_sum_sel_clause(p_view_by_dim in VARCHAR2
                           ,p_view_by_col in VARCHAR2) return VARCHAR2 IS
  l_sel_clause varchar2(10000);

  BEGIN

  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                            ,'7.1');


  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||
'      v.description     POA_ATTRIBUTE1,	--Description
       v2.description	 POA_ATTRIBUTE2,	--UOM
       oset.POA_MEASURE1 POA_MEASURE1,		--Quantity'
		|| fnd_global.newline;
   else
    l_sel_clause := l_sel_clause
		|| fnd_global.newline
		||
'	null POA_ATTRIBUTE1,		--Description
 	null POA_ATTRIBUTE2,		--UOM
	null POA_MEASURE1,		--Quantity'
		|| fnd_global.newline;
   end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE2  POA_MEASURE2,		--Unprocessed Lines Total
	oset.POA_MEASURE3  POA_MEASURE3,		--Unprocessed Lines Pending Sourcing
	oset.POA_MEASURE4  POA_MEASURE4,		--Unprocessed Lines Pending Buyers Workbench
	oset.POA_MEASURE5  POA_MEASURE5,		--Unprocessed Lines Pending Buyer Submission for Approval
	oset.POA_MEASURE6  POA_MEASURE6,		--Unprocessed Lines Pending PO Approval
	oset.POA_MEASURE7  POA_MEASURE7,		--Past Expected Date
	oset.POA_MEASURE8  POA_MEASURE8,		--Emergency
	oset.POA_MEASURE9  POA_MEASURE9,		--Urgent
	oset.POA_MEASURE10 POA_MEASURE10,		--Grand Total Unprocessed Lines Total
	oset.POA_MEASURE11  POA_MEASURE11,		--Grand Total Unprocessed Lines Pending Sourcing
	oset.POA_MEASURE12  POA_MEASURE12,		--Grand Total Unprocessed Lines Pending Buyers Workbench
	oset.POA_MEASURE13  POA_MEASURE13,		--Grand Total Unprocessed Lines Pending Buyer Submission for Approval
	oset.POA_MEASURE14  POA_MEASURE14,		--Grand Total Unprocessed Lines Pending PO Approval
	oset.POA_MEASURE15  POA_MEASURE15,		--Grand Total Past Expected Date
	oset.POA_MEASURE16  POA_MEASURE16,		--Grand Total Emergency
	oset.POA_MEASURE17  POA_MEASURE17,		--Grand Total Urgent
	oset.POA_MEASURE3  POA_ATTRIBUTE4,		--Graph Unprocessed Lines Pending Sourcing
	oset.POA_MEASURE4  POA_ATTRIBUTE5,		--Graph Unprocessed Lines Pending Buyers Workbench
	oset.POA_MEASURE5  POA_ATTRIBUTE6,		--Graph Unprocessed Lines Pending Buyer Submission for Approval
	oset.POA_MEASURE6  POA_ATTRIBUTE7,		--Graph Unprocessed Lines Pending PO Approval
	oset.POA_MEASURE2  POA_ATTRIBUTE8,              --Graph Unprocessed Lines Total
	oset.POA_MEASURE7  POA_ATTRIBUTE9, ';


     l_sel_clause := l_sel_clause || '
     ''pFunctionName=POA_DBI_UPR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1''  POA_ATTRIBUTE14,
     ''pFunctionName=POA_DBI_UPR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1'' POA_ATTRIBUTE15,
     ''pFunctionName=POA_DBI_UPR_SRC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=2'' POA_ATTRIBUTE16,
     ''pFunctionName=POA_DBI_UPR_SRC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=2'' POA_ATTRIBUTE17,
     ''pFunctionName=POA_DBI_UPR_BW_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=3'' POA_ATTRIBUTE18,
     ''pFunctionName=POA_DBI_UPR_BW_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=3'' POA_ATTRIBUTE19,
     ''pFunctionName=POA_DBI_UPR_BSA_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=4'' POA_ATTRIBUTE20,
     ''pFunctionName=POA_DBI_UPR_BSA_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=4'' POA_ATTRIBUTE21,
     ''pFunctionName=POA_DBI_UPR_PA_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=5'' POA_ATTRIBUTE22,
     ''pFunctionName=POA_DBI_UPR_PA_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=5'' POA_ATTRIBUTE23,
     ''pFunctionName=POA_DBI_UPR_PED_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=6'' POA_ATTRIBUTE24,
     ''pFunctionName=POA_DBI_UPR_PED_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=6'' POA_ATTRIBUTE25,
     ''pFunctionName=POA_DBI_UPR_EMG_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=7'' POA_ATTRIBUTE26,
     ''pFunctionName=POA_DBI_UPR_URG_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=8'' POA_ATTRIBUTE27 ';



   l_sel_clause := l_sel_clause || '
    from
	 (select * from (select * from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
  l_sel_clause := l_sel_clause || ',base_uom';
 end if;
l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;

  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
   l_sel_clause := l_sel_clause ||
                    ' , base_uom,
                      POA_MEASURE1';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE2,
                   POA_MEASURE3, POA_MEASURE4,
		   POA_MEASURE5, POA_MEASURE6,
		   POA_MEASURE7, POA_MEASURE8,
		   POA_MEASURE9, POA_MEASURE10,
		   POA_MEASURE11, POA_MEASURE12,
		   POA_MEASURE13, POA_MEASURE14,
		   POA_MEASURE15, POA_MEASURE16,
		   POA_MEASURE17
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause := l_sel_clause || ' base_uom,
      decode(base_uom,null,to_number(null),nvl(c_unproc_qty,0)) POA_MEASURE1,';
    end if;
 l_sel_clause := l_sel_clause || '
                nvl(c_unproc_cnt,0)              POA_MEASURE2,
		nvl(c_pen_src_cnt,0)             POA_MEASURE3,
		nvl(c_pen_buyer_wk_cnt,0)        POA_MEASURE4,
		nvl(c_pen_po_submit_cnt,0)       POA_MEASURE5,
		nvl(c_pen_po_appr_cnt,0)         POA_MEASURE6,
		nvl(c_unproc_ped_cnt,0)          POA_MEASURE7,
		nvl(c_unproc_emer_cnt,0)         POA_MEASURE8,
		nvl(c_unproc_urg_cnt,0)          POA_MEASURE9,
		nvl(c_unproc_cnt_total,0)        POA_MEASURE10,
		nvl(c_pen_src_cnt_total,0)       POA_MEASURE11,
		nvl(c_pen_buyer_wk_cnt_total,0)  POA_MEASURE12,
		nvl(c_pen_po_submit_cnt_total,0) POA_MEASURE13,
		nvl(c_pen_po_appr_cnt_total,0)   POA_MEASURE14,
		nvl(c_unproc_ped_cnt_total,0)    POA_MEASURE15,
		nvl(c_unproc_emer_cnt_total,0)   POA_MEASURE16,
		nvl(c_unproc_urg_cnt_total,0)    POA_MEASURE17
';

   return l_sel_clause;
 END;


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
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE7';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE8';
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE9';

 if(p_view_by = 'ITEM+POA_ITEMS') then
    l_col_tbl.extend;
    l_col_tbl(9) := 'POA_MEASURE1';
 end if;

   return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;


  PROCEDURE dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
	l_query varchar2(10000);
        l_cur_suffix varchar2(2);
        l_where_clause varchar2(2000);
        l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
        l_in_join_tables    VARCHAR2(240) ;
        l_context NUMBER;
        l_context_where VARCHAR2(240);
        l_bucket VARCHAR2(50);
        l_bucket_where VARCHAR2(440);
        l_rownum_where varchar2(300);
        l_vo_max_fetch_size varchar2(100);
   BEGIN
   poa_dbi_sutil_pkg.drill_process_parameters(p_param, l_cur_suffix, l_where_clause, l_in_join_tbl, 'PO', '7.1',
'VPP','REQS');

  IF(l_in_join_tbl is not null) then
     FOR i in 1 .. l_in_join_tbl.COUNT
       LOOP
          l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
       END LOOP;
  END IF;

    FOR i IN 1..p_param.COUNT
    LOOP

    IF (p_param(i).parameter_name = 'POA_ATTRIBUTE10')
      THEN l_context:= p_param(i).parameter_id;
    END IF;
    IF (p_param(i).parameter_name = 'POA_BUCKET+REQUISITION_AGING')
     THEN l_bucket := p_param(i).parameter_id;
    END IF;
    END LOOP;

    l_context_where := CASE
                         WHEN l_context=1 THEN
                          ' and  fact.po_approved_date is null '
                         WHEN l_context=2 THEN
                          ' and fact.po_creation_date is null and fact.sourcing_flag=''Y'' '
                               -- Add on Req flag and Auction Header clause
                         WHEN l_context=3 THEN
                          ' and fact.po_creation_date is null  and fact.sourcing_flag=''N'' '
                         WHEN l_context=4 THEN
                          ' and fact.po_creation_date <= to_date(&REQ_FACT_UPDATE_DATE,''DD/MM/YYYY HH24:MI:SS'') and fact.po_submit_date is null '
                         WHEN l_context=5 THEN
                          ' and fact.po_submit_date <= to_date(&REQ_FACT_UPDATE_DATE,''DD/MM/YYYY HH24:MI:SS'') '
                         WHEN l_context=6 THEN
                          ' and (fact.expected_date <= to_date(&REQ_FACT_UPDATE_DATE,''DD/MM/YYYY HH24:MI:SS'') or fact.unproc_ped_flag = ''Y'' ) '
                         WHEN l_context=7 THEN
                          ' and nvl(fact.emergency_flag,''N'')=''Y'' '
                         WHEN l_context=8 THEN
                          ' and nvl(fact.urgent_flag,''N'')=''Y'' '
                       ELSE
                          ''
                       END;

if(l_bucket is not null) then
	l_bucket_where := 'and (&RANGE_LOW is null or '
		|| '(to_date(&REQ_FACT_UPDATE_DATE,''DD/MM/YYYY HH24:MI:SS'')-fact.req_approved_date)'
		|| ' >= &RANGE_LOW)'
		|| fnd_global.newline
		||' and (&RANGE_HIGH is null or '
		||'(to_date(&REQ_FACT_UPDATE_DATE,''DD/MM/YYYY HH24:MI:SS'')-fact.req_approved_date)'
		|| ' < &RANGE_HIGH)';

	poa_dbi_util_pkg.bind_low_high(p_param
		, 'POA_DBI_UPR_BUCKET'
		, 'POA_BUCKET+REQUISITION_AGING'
		, '&RANGE_LOW'
		, '&RANGE_HIGH'
		, x_custom_output);
else
         l_bucket_where := '';
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
    x_custom_sql := '   select
		       prh.segment1 POA_MEASURE1,      -- Requisition Number
		       prl.line_num POA_MEASURE2,      -- Line Num
		       rorg.name POA_ATTRIBUTE1,       -- Req Creation OU
		       substrb(perf.first_name,1,1) || ''. '' || perf.last_name POA_ATTRIBUTE2,  -- Requestor Name
		       POA_ATTRIBUTE3 POA_ATTRIBUTE3, -- Req Approved Date
		       POA_ATTRIBUTE4 POA_ATTRIBUTE4, -- Expected Date
		       item.value POA_ATTRIBUTE5,      -- Item Name
		       supplier.value POA_ATTRIBUTE6,  -- Supplier Name
      		       nvl(i.POA_MEASURE3,0) POA_MEASURE3,    -- Amount
		    ';

 if(l_context=2) then
   x_custom_sql := x_custom_sql ||  '
   		       decode(prl.auction_display_number,null,''RFQ'',prl.auction_display_number) POA_MEASURE4, -- Sourcing Document Number
		       decode(pll.po_release_id,null,
                              poh.segment1,
                              poh.segment1||''-''||por.release_num) POA_MEASURE5,      -- PO Number
		       ponorg.name POA_ATTRIBUTE7,       -- Sourcing Org Value
                      ';
 else
   x_custom_sql := x_custom_sql ||  '
   		       decode(i.sourcing_flag,''Y'',
		            decode(prl.auction_display_number,null,''RFQ'',prl.auction_display_number),null) POA_MEASURE4, -- Sourcing Document Number
		       decode(pll.po_release_id,null,
                              poh.segment1,
                              poh.segment1||''-''||por.release_num) POA_MEASURE5,      -- PO Number
		       porg.name  POA_ATTRIBUTE7,       -- PO Value Value
		      ';
 end if;
 x_custom_sql := x_custom_sql || '  nvl(i.POA_MEASURE6,0) POA_MEASURE6,    -- Grand Total Amount
                       i.req_header_id POA_ATTRIBUTE11, -- Req Header ID for drill down to ip Report
		    ';
 if(l_context=2) then
   x_custom_sql := x_custom_sql || ' decode(prl.auction_display_number,null,null,decode(pon.auction_status, ''DRAFT'',null,
		       ''pFunctionName=POA_DBI_NEG_DRILL&AuctionId=''||prl.auction_display_number ||''&addBreadCrumb=Y&retainAM=Y'')) POA_ATTRIBUTE12, ';
 else
   x_custom_sql := x_custom_sql || ' null POA_ATTRIBUTE12,';
 end if;
 x_custom_sql := x_custom_sql ||  '
    ( case when poh.segment1 is null
           then null
           when pll.po_release_id is null
           then ( case when poh.type_lookup_code = ''PLANNED''
                  then null
                  else ''pFunctionName=POA_DBI_PDF_DRILL&DocumentId='' || poh.po_header_id || ''&RevisionNum=''
                      || poh.revision_num || ''&LanguageCode='' || userenv(''LANG'') || ''&DocumentType=PO&DocumentSubtype=STANDARD&OrgId='' || poh.org_id
                      || ''&UserSecurity=Y&StoreFlag=N&ViewOrCommunicate=View&CallFromForm=N''
                  end
                )
           else ''pFunctionName=POA_DBI_PDF_DRILL&DocumentId='' || por.po_release_id || ''&RevisionNum=''
                || por.revision_num || ''&LanguageCode='' || userenv(''LANG'') || ''&DocumentType=RELEASE&DocumentSubtype=BLANKET&OrgId='' || por.org_id
                || ''&UserSecurity=Y&StoreFlag=N&ViewOrCommunicate=View&CallFromForm=N''
      end
    ) POA_ATTRIBUTE13
		   from    (select * from (select * from
		    (select (rank() over
		            (&ORDER_BY_CLAUSE nulls last, req_header_id,
                            req_line_id))-1 rnk,
			    req_header_id,
			    req_line_id,
			    req_creation_ou_id,
			    requester_id,
			    POA_ATTRIBUTE3 POA_ATTRIBUTE3,
			    POA_ATTRIBUTE4 POA_ATTRIBUTE4,
			    po_item_id,
			    supplier_id,
			    nvl(POA_MEASURE3,0) POA_MEASURE3,
			    nvl(POA_MEASURE6,0) POA_MEASURE6,
		            po_line_location_id,
			    po_creation_ou_id,
			    sourcing_flag
		     from
		    (
		      select
		        fact.req_header_id,
			fact.req_line_id,
			fact.req_creation_ou_id,
			fact.requester_id,
			fact.req_approved_date POA_ATTRIBUTE3,
			fact.expected_date POA_ATTRIBUTE4,
			fact.po_item_id,
			fact.supplier_id,
			fact.line_amount_' || l_cur_suffix || ' POA_MEASURE3,
			sum(fact.line_amount_' || l_cur_suffix || ') over() POA_MEASURE6,
			fact.po_line_location_id,
			fact.po_creation_ou_id,
			fact.sourcing_flag
	      from
	        poa_dbi_req_f fact '  || l_in_join_tables || '
          where
		     fact.req_approved_date is not null
		 and fact.po_approved_date is null '
		 || l_where_clause || fnd_global.newline ||
		 l_context_where || fnd_global.newline ||
         l_bucket_where ||
			')) i2 where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)) i3 '||l_rownum_where||' ) i,
		        po_requisition_headers_all prh,
			po_requisition_lines_all prl,
			po_headers_all poh,
			po_line_locations_all pll,
			poa_items_v item,
			poa_suppliers_v supplier,
			per_all_people_f perf,
			hr_all_organization_units_vl rorg,
			hr_all_organization_units_vl porg,
                        po_releases_all por ';
   if(l_context=2) then
       x_custom_sql := x_custom_sql || '
                       , pon_auction_headers_all pon
		       , hr_all_organization_units_vl ponorg ';
   end if;
    x_custom_sql := x_custom_sql || 'where
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
                    and pll.po_header_id = por.po_header_id(+)
                    and pll.po_release_id = por.po_release_id(+) ';
    if(l_context=2) then
      x_custom_sql := x_custom_sql || '
                        and prl.auction_header_id=pon.auction_header_id(+)
			and pon.org_id= ponorg.organization_id(+) ';
    end if;

      x_custom_sql := x_custom_sql || '
    ORDER BY rnk';
poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);

end;
end poa_dbi_upr_pkg;

/
