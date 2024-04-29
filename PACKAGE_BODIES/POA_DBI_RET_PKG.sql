--------------------------------------------------------
--  DDL for Package Body POA_DBI_RET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_RET_PKG" 
/* $Header: poadbiretb.pls 120.2 2006/06/27 23:43:03 sdiwakar noship $ */
AS
  --
  FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2, p_view_by_col in VARCHAR2, p_url in VARCHAR2) return VARCHAR2;
  FUNCTION get_reason_sel_clause(p_view_by_dim in VARCHAR2, p_view_by_col in VARCHAR2, p_url in VARCHAR2) return VARCHAR2;
  FUNCTION get_trend_sel_clause return VARCHAR2;
FUNCTION get_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_retdist_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;

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
                                      , '6.0'
                                      , 'COM'
                                      ,'RTX');
    l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'amt_return_' || l_cur_suffix
                             ,'amt_return'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'amt_receipt_and_dropship_' || l_cur_suffix
                             ,'amt_receipt'
                             ,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl
                             ,'amt_receipt_return_' || l_cur_suffix
                             ,'amt_receipt_return'
                             ,p_to_date_type => l_to_date_type);

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'num_txns_return_cnt'
			      ,'cnt_return'
            ,p_to_date_type => l_to_date_type);

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'num_txns_receipt_return_cnt'
			      ,'cnt_receipt_return'
            ,p_to_date_type => l_to_date_type);

  poa_dbi_util_pkg.add_column(l_col_tbl
			      ,'num_txns_receipt_cnt'
			      ,'cnt_receipt'
            ,p_to_date_type => l_to_date_type);


  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'qty_return'
                               ,'qty_return'
                               ,p_to_date_type => l_to_date_type);
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'qty_receipt_and_dropship'
                               ,'qty_receipt'
                               ,p_to_date_type => l_to_date_type);
  end if;

  l_url := 'pFunctionName=POA_DBI_RET_REASON_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_PO_CAT&pParamIds=Y';

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


FUNCTION get_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE13';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_PERCENT3';


 if(p_view_by = 'ITEM+POA_ITEMS') then

    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(9) := 'POA_MEASURE5';
  end if;


    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

  FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2
                                ,p_view_by_col in VARCHAR2
                                ,p_url in VARCHAR2) return VARCHAR2 IS
  l_sel_clause varchar2(8000);
  --
  BEGIN
  --
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                            ,'PO'
                                                            ,'6.0');
  --
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause || '
	v.description POA_ATTRIBUTE1,		--Description
    v2.description POA_ATTRIBUTE2,      --UOM
    oset.POA_MEASURE4 POA_MEASURE4,	    --Return Quantity
	oset.POA_MEASURE5 POA_MEASURE5, 	--Receipt Quantity
';
  else
    l_sel_clause := l_sel_clause || '
	null POA_ATTRIBUTE1,		--Description
	null POA_ATTRIBUTE2,		--UOM
	null POA_MEASURE4,		--Return Quantity
	null POA_MEASURE5,		--Receipt Quantity
';
  end if;

   l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE1 POA_MEASURE1,		--Return Amount
	oset.POA_PERCENT1 POA_PERCENT1,		--Change
	oset.POA_MEASURE2 POA_MEASURE2,		--Receipt Amount
	oset.POA_MEASURE3 POA_MEASURE3,		--Receipt Returned Amount
	oset.POA_PERCENT2 POA_PERCENT2,		--Return Rate
	oset.POA_MEASURE6 POA_MEASURE6,		--Grand Total Return Amount
	oset.POA_MEASURE7 POA_MEASURE7,		--Grand Total Change
	oset.POA_MEASURE8 POA_MEASURE8,		--Grand Total Receipt Amount
	oset.POA_MEASURE9 POA_MEASURE9,		--Grand Total Receipt Returned Amount
        oset.POA_MEASURE10 POA_MEASURE10,	--Grand Total Return Rate
     oset.POA_MEASURE13 POA_MEASURE13,		--Return Txns
     oset.POA_PERCENT3 POA_PERCENT3,		--Change
     oset.POA_MEASURE14 POA_MEASURE14,		--Grand Total Return Txns
     oset.POA_PERCENT4 POA_PERCENT4,		--Grand Total Change
     ''' || p_url || ''' POA_MEASURE11,
     ''' || p_url || ''' POA_ATTRIBUTE5,
    oset.poa_percent5 poa_percent5,       -- KPI - Prior Receipt Return Rate
    oset.poa_percent6 poa_percent6,       -- KPI - Grand Total Prior receipt return rate
    oset.poa_measure16 poa_measure16,     -- KPI - Receipt Return Transactions
    oset.poa_measure17 poa_measure17,     -- KPI - Grand Total for Receipt Return transactions
    oset.poa_measure18 poa_measure18,     -- KPI - Prior Receipt Return Transactions
    oset.poa_measure19 poa_measure19      -- KPI - Grand Total for Receipt Return Transactions
    from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE4,
                       POA_MEASURE5';
  end if;

   l_sel_clause := l_sel_clause || ',POA_MEASURE1,POA_PERCENT1,
                       POA_MEASURE2,POA_MEASURE3,
                       POA_PERCENT2,POA_MEASURE6,
                       POA_MEASURE7,POA_MEASURE8,
                       POA_MEASURE9,POA_MEASURE10,
     poa_measure13, poa_percent3,
     poa_measure14, poa_percent4,
     poa_percent5, poa_percent6,
     POA_MEASURE16, POA_MEASURE17,
     POA_MEASURE18, POA_MEASURE19
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
  --
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_qty_return,0)) POA_MEASURE4,
                         decode(base_uom,null,to_number(null),nvl(c_qty_receipt,0)) POA_MEASURE5, ';
   end if;
  --
 l_sel_clause := l_sel_clause || ' nvl(c_amt_return,0) POA_MEASURE1,
						 ' || poa_dbi_util_pkg.change_clause('c_amt_return','p_amt_return') || ' POA_PERCENT1,
                         nvl(c_amt_receipt,0) POA_MEASURE2,
                         nvl(c_amt_receipt_return,0) POA_MEASURE3,
						 ' || poa_dbi_util_pkg.rate_clause('c_amt_receipt_return','c_amt_receipt') || ' POA_PERCENT2,
                         nvl(c_amt_return_total,0) POA_MEASURE6,
						 ' || poa_dbi_util_pkg.change_clause('c_amt_return_total','p_amt_return_total') || ' POA_MEASURE7,
                         nvl(c_amt_receipt_total,0) POA_MEASURE8,
                         nvl(c_amt_receipt_return_total,0) POA_MEASURE9,
   ' || poa_dbi_util_pkg.rate_clause('c_amt_receipt_return_total','c_amt_receipt_total') || ' POA_MEASURE10,
   Nvl(c_cnt_return,0) POA_MEASURE13,
   ' || poa_dbi_util_pkg.change_clause('c_cnt_return','p_cnt_return') || 'POA_PERCENT3,
   Nvl(c_cnt_return_total,0) POA_MEASURE14,
   ' || poa_dbi_util_pkg.change_clause('c_cnt_return_total','p_cnt_return_total') || ' POA_PERCENT4,
   ' || poa_dbi_util_pkg.rate_clause('p_amt_receipt_return','p_amt_receipt') || ' POA_PERCENT5,
   ' || poa_dbi_util_pkg.rate_clause('p_amt_receipt_return_total','p_amt_receipt_total') || ' POA_PERCENT6,
   ' || poa_dbi_util_pkg.rate_clause('c_cnt_receipt_return','c_cnt_receipt') || ' POA_MEASURE16,
   ' || poa_dbi_util_pkg.rate_clause('c_cnt_receipt_return_total','c_cnt_receipt_total') || ' POA_MEASURE17,
   ' || poa_dbi_util_pkg.rate_clause('p_cnt_receipt_return','p_cnt_receipt') || ' POA_MEASURE18,
   ' || poa_dbi_util_pkg.rate_clause('p_cnt_receipt_return_total','p_cnt_receipt_total') || ' POA_MEASURE19 ';
   return l_sel_clause;
 END;
  --
PROCEDURE rtn_rsn_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
 l_query varchar2(10000);
 l_view_by varchar2(120);
 l_view_by_col varchar2(120);
 l_as_of_date date;
 l_prev_as_of_date date;
 l_xtd varchar2(10);
 l_comparison_type varchar2(1) :='Y';
 l_nested_pattern number;
 l_cur_suffix varchar2(2);
 l_url varchar2(300);
 l_custom_sql varchar2(10000);
 l_view_by_value varchar2(30);
 l_where_clause VARCHAR2(2000);
 l_mv VARCHAR2(30);
 l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
 l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
 l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
 l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;
 ERR_MSG VARCHAR2(100);
 ERR_CDE NUMBER;
 l_context_code VARCHAR2(10);
 l_to_date_type VARCHAR2(10);
  BEGIN

  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();

  poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value,l_comparison_type,l_xtd,l_as_of_date,l_prev_as_of_date,l_cur_suffix,l_nested_pattern,l_where_clause,l_mv,l_join_tbl,l_in_join_tbl,
x_custom_output,
                                       'N','PO', '6.0', 'COM','RTX');

   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

  poa_dbi_util_pkg.add_column(l_col_tbl,'amt_return_' || l_cur_suffix,'amt_return',p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl,'amt_receipt_return_' || l_cur_suffix,'amt_receipt_return',p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl,'num_txns_return_cnt','cnt_return',p_to_date_type => l_to_date_type);
  if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'qty_return'
                               ,'qty_return'
                               ,p_to_date_type => l_to_date_type);
  end if;
  l_query := get_reason_sel_clause(l_view_by, l_view_by_col,null) || ' from '
	||  poa_dbi_template_pkg.status_sql(l_mv,
					l_where_clause,
					l_join_tbl,
					p_use_windowing => 'Y',
					p_col_name => l_col_tbl,
					p_use_grpid => 'N',
					p_filter_where => get_retdist_filter_where(l_view_by),
					p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

 EXCEPTION
   WHEN OTHERS THEN
     ERR_MSG := SUBSTR(SQLERRM,1,400);
  end;


  FUNCTION get_reason_sel_clause(p_view_by_dim in VARCHAR2, p_view_by_col in VARCHAR2, p_url in VARCHAR2) return VARCHAR2
  IS
   l_sel_clause varchar2(4000);

  BEGIN

  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim,'PO','6.0');

  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause || '
       v.description POA_ATTRIBUTE1,	   --Description
       v2.description POA_ATTRIBUTE4,      --UOM
       oset.POA_MEASURE14 POA_MEASURE14,   --Return Quantity
';
  else
    l_sel_clause := l_sel_clause || '
       null POA_ATTRIBUTE3,		--Description
       null POA_ATTRIBUTE4,		--UOM
       null POA_MEASURE14,		--Return Quantity
';
  end if;



  l_sel_clause := l_sel_clause ||
'	oset.POA_MEASURE1 POA_MEASURE1,		--Return Amount
	oset.POA_PERCENT1 POA_PERCENT1,		--Change
	oset.POA_MEASURE2 POA_MEASURE2,		--Receipt Returned Amount
	oset.POA_PERCENT2 POA_PERCENT2,		--Percent of Total
	oset.POA_MEASURE3 POA_MEASURE3,		--Grand Total of Return Amount
	oset.POA_MEASURE4 POA_MEASURE4,		--Grand Total of Change
	oset.POA_MEASURE5 POA_MEASURE5,		--Grand Total of Receipt Returned Amount
	oset.POA_MEASURE6 POA_MEASURE6,		--Grand Total of Percent of Total
        oset.POA_MEASURE9 POA_MEASURE9,	        --Return Transactions
	oset.POA_MEASURE10 poa_measure10,	--Grand Total for Return Transactions
    oset.poa_percent3 poa_percent3,      -- Change
    oset.poa_percent4 poa_percent4,      -- Percent of Total
    oset.poa_percent5 poa_percent5,      -- Grand Total Change
    oset.poa_percent6 poa_percent6,      -- Grand Total Percent of Total
    oset.poa_percent2 poa_measure15,     -- label for % of Total Return Amount
    oset.poa_percent4 poa_measure16      -- label for % of Total Return Transactions
      from (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col ;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col || ',';
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || '
                       base_uom,
                       poa_measure14,';
  end if;

  l_sel_clause := l_sel_clause || '
                    POA_MEASURE1,POA_PERCENT1,
                    POA_MEASURE2,POA_PERCENT2,
                    POA_MEASURE3,POA_MEASURE4,
                    POA_MEASURE5,poa_measure6,
	    poa_measure9,poa_percent3,
	    poa_measure10,poa_percent5,
	    poa_percent4,poa_percent6
	    from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID,';
    --
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_qty_return,0)) poa_measure14, ';
   end if;
    --
		    l_sel_clause := l_sel_clause || '

                     nvl(c_amt_return,0) POA_MEASURE1,
					 ' || poa_dbi_util_pkg.change_clause('c_amt_return','p_amt_return') || ' POA_PERCENT1,
                     c_amt_receipt_return POA_MEASURE2,
					 ' || poa_dbi_util_pkg.rate_clause('c_amt_return','c_amt_return_total') || ' POA_PERCENT2,
                     nvl(c_amt_return_total,0) POA_MEASURE3,
					 ' || poa_dbi_util_pkg.change_clause('c_amt_return_total','p_amt_return_total') || ' POA_MEASURE4,
                     c_amt_receipt_return_total POA_MEASURE5,
 			                 ' || poa_dbi_util_pkg.rate_clause('c_amt_return_total','c_amt_return_total') || ' POA_MEASURE6 ,
		     Nvl(c_cnt_return,0) POA_MEASURE9,
			                 ' || poa_dbi_util_pkg.change_clause('c_cnt_return','p_cnt_return') || 'POA_PERCENT3,
		     Nvl(c_cnt_return_total,0) POA_MEASURE10,
                                         ' || poa_dbi_util_pkg.change_clause('c_cnt_return_total','p_cnt_return_total') || ' POA_PERCENT5,
                                         ' || poa_dbi_util_pkg.rate_clause('c_cnt_return','c_cnt_return_total') || ' POA_PERCENT4,
                                         ' || poa_dbi_util_pkg.rate_clause('c_cnt_return_total','c_cnt_return_total') || '  POA_PERCENT6
    ';

 return l_sel_clause;
 END;


FUNCTION get_retdist_filter_where(p_view_by IN VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE9';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_PERCENT3';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_PERCENT4';

  if(p_view_by = 'ITEM+POA_ITEMS') then
 	l_col_tbl.extend;
    	l_col_tbl(7) := 'POA_MEASURE14';
  end if;
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;

  PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(10000);
  l_view_by             varchar2(120);
  l_view_by_col_name    varchar2(120);
  l_as_of_date          date;

  l_prev_as_of_date     date;
  l_org                 varchar2(100);
  l_category            varchar2(2000);
  l_commodity           varchar2(2000);
  l_commodity_where     varchar2(2000);
  l_item                varchar2(2000);
  l_buyer               varchar2(2000);
  l_mv                  VARCHAR2(90);
  l_supplier            varchar2(2000);
  l_supplier_site       VARCHAR2(2000);
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) := 'Y';
  l_nested_pattern      number;

  l_dim_bmap            number;
  l_org_where           varchar2(240);
  l_category_where      varchar2(120);
  l_item_where          varchar2(120);
  l_buyer_where         varchar2(1000);
  l_supplier_where      varchar2(120);
  l_supplier_site_where varchar2(120);
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_impact_amount       varchar2(15);
  l_leakage_amount      varchar2(25);
  l_purchase_amount     varchar2(25);
  l_custom_sql          varchar2(9000);

  l_view_by_value       varchar2(30);
  l_dim_in_tbl          poa_dbi_util_pkg.POA_DBI_DIM_TBL;
  l_dim_out_tbl         poa_dbi_util_pkg.POA_DBI_DIM_TBL;
  l_col_rec             poa_dbi_util_pkg.POA_DBI_COL_REC;
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_total_col_tbl       poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_where_clause        VARCHAR2(2000);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
 BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

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
                                       l_where_clause,
                                       l_mv,
                                       l_join_tbl,
                                       l_in_join_tbl,
				       x_custom_output,
                                       'Y',
                                       'PO',
                                       '6.0',
                                       'COM',
                                       'RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

  poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_return_' || l_cur_suffix, 'amt_return','N',3,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl,'num_txns_return_cnt','cnt_return','N',3,p_to_date_type => l_to_date_type);

  l_query := get_trend_sel_clause || '
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

 PROCEDURE kpi_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql  OUT NOCOPY VARCHAR2,
                     x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query               varchar2(10000);
  l_view_by             varchar2(120);
  l_view_by_col_name    varchar2(120);
  l_as_of_date          date;
  l_prev_as_of_date     date;
  l_org                 varchar2(100);
  l_category            varchar2(2000);
  l_commodity           varchar2(2000);
  l_item                varchar2(2000);
  l_buyer               varchar2(2000);
  l_mv                  VARCHAR2(90);
  l_supplier            varchar2(2000);
  l_supplier_site       VARCHAR2(2000);
  l_xtd                 varchar2(10);
  l_comparison_type     varchar2(1) := 'Y';
  l_nested_pattern      number;

  l_dim_bmap            number;
  l_cur_suffix          varchar2(2);
  l_url                 varchar2(300);
  l_custom_sql          varchar2(9000);

  l_view_by_value       varchar2(30);
  l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_where_clause        VARCHAR2(2000);
  ERR_MSG               VARCHAR2(100);
  ERR_CDE               NUMBER;
  l_context_code        VARCHAR2(10);
  l_to_date_type        VARCHAR2(10);
 BEGIN

  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

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
                                       l_where_clause,
                                       l_mv,
                                       l_join_tbl,
                                       l_in_join_tbl,
					x_custom_output,
                                       'Y',
                                       'PO',
                                       '6.0',
                                       'COM',
                                       'RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

  poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_return_' || l_cur_suffix, 'amt_return','Y',3,p_to_date_type => l_to_date_type);
  poa_dbi_util_pkg.add_column(l_col_tbl,'num_txns_return_cnt','cnt_return','Y',3, p_to_date_type => l_to_date_type);

  l_query :=  poa_dbi_sutil_pkg.get_viewby_select_clause(l_view_by, 'PO','6.0');

  l_query := l_query || '
    oset.POA_MEASURE1 POA_MEASURE1,		-- Return Amount
    oset.POA_MEASURE2 poa_measure2,		-- Prior Return Amount
    oset.POA_MEASURE5 poa_measure5,		-- Total Return Amount
    oset.POA_MEASURE6 poa_measure6,		-- Total Prior Return Amount
    oset.POA_MEASURE3 poa_measure3,		-- Return Transactions
    oset.POA_MEASURE4 poa_measure4,		-- Prior Return Transactions
    oset.POA_MEASURE8 poa_measure8,		-- Total Return Trasactions
    oset.POA_MEASURE9 poa_measure9    		-- Total Prior Return Transactions
          from
          (select * from
           (select ' || l_view_by_col_name || ',';
  if ( l_view_by = 'ITEM+POA_ITEMS' ) then
    l_query := l_query || ' base_uom, ';
  end if;
  l_query := l_query || '
                   nvl(c_amt_return,0) POA_MEASURE1,
	           nvl(p_amt_return,0) poa_measure2,
	           nvl(c_amt_return_total,0) poa_measure5,
	           nvl(p_amt_return_total,0) poa_measure6,
                   nvl(c_cnt_return,0) POA_MEASURE3,
	           nvl(p_cnt_return,0) poa_measure4,
                   nvl(c_cnt_return_total,0) POA_MEASURE8,
	           nvl(p_cnt_return_total,0) poa_measure9
                   from '
    || poa_dbi_template_pkg.status_sql(
                    l_mv,
                    l_where_clause,
                    l_join_tbl,
                    p_use_windowing => 'N',
                    p_col_name => l_col_tbl,
		    p_use_grpid => 'N',
                    p_in_join_tables => l_in_join_tbl);

 x_custom_sql := l_query;

 END;

 FUNCTION get_trend_sel_clause return VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN
  l_sel_clause := 'select cal.name VIEWBY,';
  l_sel_clause := l_sel_clause || '
	    nvl(c_amt_return,0) POA_MEASURE1,
	    p_amt_return POA_MEASURE2,
	    ' || poa_dbi_util_pkg.change_clause('c_amt_return','p_amt_return') || ' poa_percent1,
	    Nvl(c_cnt_return,0) poa_measure4,
	    p_cnt_return poa_measure5,
	    ' || poa_dbi_util_pkg.change_clause('c_cnt_return','p_cnt_return') || ' poa_percent2'
	    ;
  return l_sel_clause;
 END;

end poa_dbi_ret_pkg;

/
