--------------------------------------------------------
--  DDL for Package Body POA_DBI_IAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_IAP_PKG" 
/* $Header: poadbiavgprb.pls 120.14 2006/05/05 10:50:40 sriswami noship $ */
AS


FUNCTION get_status_filter_where RETURN VARCHAR2 ;

FUNCTION get_status_sel_clause(p_view_by_col_name in VARCHAR2)
RETURN VARCHAR2 ;

FUNCTION get_iapd_filter_where RETURN VARCHAR2 ;

FUNCTION get_trend_sel_clause
  return VARCHAR2 ;

FUNCTION get_dtl_sts_filter_where RETURN VARCHAR2 ;

FUNCTION get_group_and_sel_clause(
	p_join_tables IN poa_dbi_util_pkg.poa_dbi_join_tbl
	, p_use_alias IN VARCHAR2
) RETURN VARCHAR2 ;

  FUNCTION dtl_status_sql (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                          VARCHAR2 := 'Y'
  , p_paren_count               IN       NUMBER := 4
  , p_filter_where              IN       VARCHAR2 := NULL
  , p_generate_viewby           IN       VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_in_join_tbl := NULL
  , p_uom_code                  IN VARCHAR2
  , p_view_by                   IN VARCHAR2
 ) RETURN VARCHAR2 ;


 FUNCTION get_dtl_sel_clause(p_view_by_col in VARCHAR2)
 RETURN VARCHAR2 ;

FUNCTION get_paren_str(p_paren_count IN NUMBER,
		p_filter_where IN VARCHAR2) RETURN VARCHAR2 ;

PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query varchar2(8000);
  l_view_by varchar2(120);
  l_view_by_col varchar2(120);
  l_as_of_date date;
  l_prev_as_of_date date;
  l_xtd varchar2(10);
  l_comparison_type varchar2(1) := 'Y';
  l_nested_pattern number;
  l_cur_suffix varchar2(3);
  l_url varchar2(300);
  l_custom_sql varchar2(4000);
  l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_where_clause VARCHAR2(2000);
  l_view_by_value VARCHAR2(100);
  l_mv VARCHAR2(30);
  l_context_code VARCHAR2(10);
  l_to_date_type VARCHAR2(10);
  l_file varchar2(500);
 BEGIN
  l_comparison_type      := 'Y';

   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
   l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

   poa_dbi_sutil_pkg.process_parameters (
                              p_param             => p_param,
                              p_view_by           => l_view_by,
                              p_view_by_col_name  => l_view_by_col ,
                              p_view_by_value     => l_view_by_value,
                              p_comparison_type   => l_comparison_type ,
                              p_xtd               => l_xtd,
                              p_as_of_date        => l_as_of_date ,
                              p_prev_as_of_date   => l_prev_as_of_date ,
                              p_cur_suffix        => l_cur_suffix ,
                              p_nested_pattern    => l_nested_pattern ,
                              p_where_clause      => l_where_clause ,
                              p_mv                => l_mv ,
                              p_join_tbl          => l_join_tbl ,
                              p_in_join_tbl       => l_in_join_tbl,
                              x_custom_output     => x_custom_output,
                              p_trend             => 'N',
                              p_func_area         => 'PO',
                              p_version           => '8.0',
                              p_role              => 'VPP',
                              p_mv_set            => 'POD');

   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);

   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

   poa_dbi_util_pkg.add_column(l_col_tbl,
                               'purchase_amt_' || l_cur_suffix,
                               'purchase_amt',
                                p_to_date_type => l_to_date_type);


   poa_dbi_util_pkg.add_column(l_col_tbl,
                               'nz_quantity',
                               'nz_quantity',
                                p_to_date_type => l_to_date_type);



  l_query := get_status_sel_clause(l_view_by_col)  ;

  l_query := l_query || ' from
              '|| poa_dbi_template_pkg.status_sql(
                                   l_mv,
                                   l_where_clause,
                                   l_join_tbl,
                                   p_use_windowing => 'Y',
                                   p_col_name => l_col_tbl,
				   p_use_grpid => 'N',
				   p_filter_where => get_status_filter_where,
                                p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

    poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

 END status_sql ;

----------------------------------------------------------------------------------

 FUNCTION get_status_filter_where RETURN VARCHAR2
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
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE12';

    RETURN poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END get_status_filter_where ;


----------------------------------------------------------------------------------

 FUNCTION get_status_sel_clause(p_view_by_col_name in VARCHAR2)
 RETURN VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN

   if(p_view_by_col_name = 'commodity_id') then
     l_sel_clause := 'select decode(v.name,null,
     fnd_message.get_string(''POA'', ''POA_DBI_APL_UNASSIGNED''), v.name) VIEWBY,
     decode(v.commodity_id,null, -1, v.commodity_id) VIEWBYID,';
  else
     l_sel_clause := 'select v.value VIEWBY, v.id VIEWBYID, ';
  end if;

    l_sel_clause :=  l_sel_clause || '
                    v.description POA_ATTRIBUTE1,
                    v2.description POA_ATTRIBUTE2,
                    oset.POA_MEASURE12 POA_MEASURE12,
                    oset.POA_MEASURE1 POA_MEASURE1,
                    oset.POA_PERCENT1 POA_PERCENT1 ,
                    oset.POA_MEASURE2 POA_MEASURE2 ,
                    oset.POA_PERCENT2 POA_PERCENT2 ,
                    oset.POA_MEASURE3 POA_MEASURE3 ,
                    oset.POA_PERCENT3 POA_PERCENT3 ,
                    v2.unit_of_measure POA_ATTRIBUTE9
     from
     (select (rank() over
                   (&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col_name || ', base_uom )) - 1 rnk,'
        || p_view_by_col_name || ', base_uom ,
           POA_MEASURE12, POA_PERCENT1, POA_MEASURE1, POA_PERCENT2, POA_MEASURE2,
           POA_MEASURE3, POA_PERCENT3
           from
           (select ' || p_view_by_col_name || ',
             ' || p_view_by_col_name || ' VIEWBY, base_uom,
           decode(base_uom,null,to_number(null),nvl(c_nz_quantity,0)) POA_MEASURE12,
           nvl(c_purchase_amt,0)/decode(c_nz_quantity,0,null,c_nz_quantity) POA_MEASURE1,
           (((nvl(c_purchase_amt,0)/decode(c_nz_quantity,0,null,c_nz_quantity)) -
           (nvl(p_purchase_amt,0)/decode(p_nz_quantity,0,null,p_nz_quantity)))/
            (nvl(p_purchase_amt,0)/decode(p_nz_quantity,0,null,p_nz_quantity))) * 100 POA_PERCENT1,
            nvl(c_purchase_amt,0) POA_MEASURE2,
            ((nvl(c_purchase_amt,0)- nvl(p_purchase_amt,0)) /
             decode(p_purchase_amt,0,null,p_purchase_amt))*100  POA_PERCENT2,
             nvl(c_purchase_amt_total,0) POA_MEASURE3,
             ((nvl(c_purchase_amt_total,0)-nvl(p_purchase_amt_total,0))/
              (decode(p_purchase_amt_total,0,null,p_purchase_amt_total))) * 100 POA_PERCENT3  ' ;


  return l_sel_clause;

  END get_status_sel_clause ;


----------------------------------------------------------------------------------

 FUNCTION get_iapd_filter_where RETURN VARCHAR2
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

    RETURN poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END get_iapd_filter_where ;

----------------------------------------------------------------------------------
PROCEDURE iapd_dtl_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
  l_query varchar2(8000);
  l_view_by varchar2(120);
  l_view_by_col varchar2(120);
  l_as_of_date date;
  l_prev_as_of_date date;
  l_xtd varchar2(10);
  l_comparison_type varchar2(1) := 'Y';
  l_nested_pattern number;
  l_cur_suffix varchar2(3);
  l_url varchar2(300);
  l_custom_sql varchar2(4000);
  l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_where_clause VARCHAR2(2000);
  l_view_by_value VARCHAR2(100);
  l_mv VARCHAR2(30);
  l_context_code VARCHAR2(10);
  l_to_date_type VARCHAR2(10);
  l_file varchar2(500);
  l_uom VARCHAR2(200);
  l_custom_rec BIS_QUERY_ATTRIBUTES;
BEGIN

   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
   l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);

   FOR i in 1..p_param.last
   LOOP
      IF p_param(i).parameter_name = 'LOOKUP+UOMCODE' THEN
         l_uom := p_param(i).parameter_value ;
      END IF ;
   END LOOP ;


      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param        => p_param,
        p_cur_suffix   => l_cur_suffix,
        p_where_clause => l_where_clause,
        p_in_join_tbl  => l_in_join_tbl,
        p_func_area    => 'PO',
        p_version      => '8.0',
        p_role         => 'VPP',
        p_mv_set       => 'POD');


    x_custom_sql := 'Select
      poh.segment1 POA_ATTRIBUTE1,
      poorg.name      POA_ATTRIBUTE8,
      uom.description POA_ATTRIBUTE10,
      substrb(perf.first_name,1,1) || ''. ''|| perf.last_name POA_ATTRIBUTE3,
      POA_MEASURE12,
      POA_MEASURE1,
      POA_MEASURE5,
      POA_MEASURE4,
      POA_MEASURE2,
      POA_MEASURE13,
      POA_MEASURE3,
      i.po_header_id POA_ATTRIBUTE6,
        ''pFunctionName=POA_DBI_ISP_DRILL&PoHeaderId=''||poh.po_header_id||''&addBreadCrumb=Y&retainAM=Y''  POA_ATTRIBUTE4
     from
        (select (rank() over
            (&ORDER_BY_CLAUSE nulls last, po_header_id,org_id,buyer_id,base_uom)) - 1 rnk,
            po_header_id,
            org_id,
            buyer_id,
            base_uom,
            decode(base_uom,null,to_number(null),nvl(POA_MEASURE12,0)) POA_MEASURE12,
            POA_MEASURE3 / decode(POA_MEASURE13, 0, null, POA_MEASURE13) POA_MEASURE1,
            POA_MEASURE5, POA_MEASURE4, nvl(POA_MEASURE2,0) POA_MEASURE2,
            POA_MEASURE13, nvl(POA_MEASURE3,0) POA_MEASURE3
            from
             (select po_header_id, base_uom, buyer_id, org_id,
              decode(base_uom,null,to_number(null),nvl(quantity,0)) POA_MEASURE12,
              total_purch_amt /decode(total_quantity,0,null,total_quantity) POA_MEASURE1,
              purch_amt / decode(quantity,0,null, quantity) POA_MEASURE5,
              (purch_amt / decode(quantity,0,null, quantity) -
              total_purch_amt /decode(total_quantity,0,null,total_quantity)) POA_MEASURE4,
              purch_amt POA_MEASURE2,
              decode(base_uom,null,to_number(null),nvl(total_quantity,0)) POA_MEASURE13,
              total_purch_amt   POA_MEASURE3
              from
                (select fact.po_header_id,
                  fact.base_uom,
                  fact.buyer_id,
                  fact.org_id,
                  sum(quantity) quantity,
                  sum(purchase_amt_' || l_cur_suffix || ') purch_amt,
                  sum(sum(quantity)) over () total_quantity,
                  sum(sum(purchase_amt_' || l_cur_suffix || ')) over () total_purch_amt
                from poa_dbi_pod_f_v fact
                where fact.approved_date between &BIS_CURRENT_EFFECTIVE_START_DATE
                      and &BIS_CURRENT_ASOF_DATE
                     and fact.consigned_code <> 1
                     and fact.purchase_amt_'|| l_cur_suffix || ' > 0
                     and fact.base_uom = &BASEUOM '|| l_where_clause ||'
                group by fact.po_header_id, fact.base_uom,  fact.org_id , fact.buyer_id))
             where coalesce( decode(POA_MEASURE5,0,null,POA_MEASURE5),
                             decode(POA_MEASURE2,0,null,POA_MEASURE2)) is not null )
              i,
              po_headers_all poh,
              per_all_people_f perf,
              mtl_units_of_measure_vl uom,
              hr_all_organization_units_vl poorg
        where i.po_header_id = poh.po_header_id
          and i.buyer_id  =  perf.person_id
          and sysdate between perf.effective_start_date and perf.effective_end_date
          and i.base_uom = uom.unit_of_measure(+)
          and i.org_id = poorg.organization_id
          and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
        ORDER BY rnk ' ;

    poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

    l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
    l_custom_rec.attribute_name := '&BASEUOM';
    l_custom_rec.attribute_value := l_uom;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

END iapd_dtl_sql ;


----------------------------------------------------------------------------------

PROCEDURE iap_trend_rpt_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
  l_query varchar2(8000);
  l_view_by varchar2(120);
  l_view_by_col varchar2(120);
  l_as_of_date date;
  l_prev_as_of_date date;
  l_xtd varchar2(10);
  l_comparison_type varchar2(1) := 'Y';
  l_nested_pattern number;
  l_cur_suffix varchar2(3);
  l_url varchar2(300);
  l_custom_sql varchar2(4000);
  l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_where_clause VARCHAR2(2000);
  l_view_by_value VARCHAR2(100);
  l_mv VARCHAR2(30);
  l_context_code VARCHAR2(10);
  l_to_date_type VARCHAR2(10);
  l_file varchar2(500);
  l_uom VARCHAR2(200);
  l_view_by_col_name  VARCHAR2(250);
  l_mv_tbl              poa_dbi_util_pkg.poa_dbi_mv_tbl;
BEGIN

l_col_tbl  := poa_dbi_util_pkg.poa_dbi_col_tbl();
l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();

FOR i in 1..p_param.last
LOOP
   IF p_param(i).parameter_name = 'LOOKUP+UOMCODE' THEN
      l_uom := p_param(i).parameter_value ;
      l_uom := nvl(l_uom,'-1');
   END IF ;
END LOOP ;

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
                                         l_where_clause,
                                         l_mv,
                                         l_join_tbl,
                                         l_in_join_tbl,
                                         x_custom_output,
                                         p_trend => 'Y',
                                         p_func_area => 'PO',
                                         p_version => '8.0',
                                         p_role => 'VPP',
                                         p_mv_set => 'POD');

  l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
 IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
   l_to_date_type := 'RLX';
 ELSE
   l_to_date_type := 'XTD';
 END IF;
    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'purchase_amt_'  || l_cur_suffix
                    , 'purchase_amt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type =>  l_to_date_type );

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'nz_quantity'
                    , 'nz_quantity'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type =>  l_to_date_type );


 ---Now populate the MV table list
    l_mv_tbl.extend;
    l_mv_tbl(1).mv_name := l_mv;
    l_mv_tbl(1).mv_col := l_col_tbl;
    l_mv_tbl(1).mv_where := l_where_clause;
    l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
    l_mv_tbl(1).use_grp_id := 'N';
    l_mv_tbl(1).mv_hint := poa_dbi_sutil_pkg.get_fact_hint(l_mv);
    l_mv_tbl(1).mv_xtd := l_xtd;

    l_where_clause := l_where_clause ||
                       ' and nvl(fact.base_uom ,''-1'') = ''' || l_uom || '''' ;


    l_query := get_trend_sel_clause || ' from '|| fnd_global.newline ||
                 poa_dbi_template_pkg.trend_sql(
                   p_xtd             => l_xtd,
                   p_comparison_type => l_comparison_type,
                   p_fact_name       => l_mv,
                   p_where_clause    => l_where_clause,
                   p_col_name        => l_col_tbl,
                   p_use_grpid       => 'N',
                   p_in_join_tables  => l_in_join_tbl);

    x_custom_sql := l_query ;

END iap_trend_rpt_sql ;
----------------------------------------------------------------------------------

FUNCTION get_trend_sel_clause
  return VARCHAR2
 IS
   l_sel_clause VARCHAR2(4000);
 BEGIN
   l_sel_clause := 'select cal.name VIEWBY,';
   l_sel_clause := l_sel_clause ||
   ' nvl(c_purchase_amt,0)/decode(c_nz_quantity,0,null,c_nz_quantity) POA_MEASURE1,
   (((nvl(c_purchase_amt,0)/decode(c_nz_quantity,0,null,c_nz_quantity)) -
   (nvl(p_purchase_amt,0)/decode(p_nz_quantity,0,null,p_nz_quantity)))/
    (nvl(p_purchase_amt,0)/decode(p_nz_quantity,0,null,p_nz_quantity))) * 100 POA_PERCENT1 ,
    nvl(c_nz_quantity,0) POA_MEASURE12,  ' ||
    poa_dbi_util_pkg.change_clause('c_nz_quantity','p_nz_quantity') || ' POA_PERCENT2,
    nvl(c_purchase_amt,0) POA_MEASURE2, ' ||
    poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_PERCENT3 ,
    nvl(p_purchase_amt,0)/decode(p_nz_quantity,0,null,p_nz_quantity) POA_MEASURE3 ,
    (nvl(p_purchase_amt,0)) POA_MEASURE4 ,
    nvl(p_nz_quantity,0) POA_MEASURE5 ' ;


  RETURN l_sel_clause;
 END get_trend_sel_clause ;

----------------------------------------------------------------------------------

PROCEDURE iapd_rpt_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql OUT NOCOPY VARCHAR2
                     ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  l_query varchar2(8000);
  l_view_by varchar2(120);
  l_view_by_col varchar2(120);
  l_as_of_date date;
  l_prev_as_of_date date;
  l_xtd varchar2(10);
  l_comparison_type varchar2(1) := 'Y';
  l_nested_pattern number;
  l_cur_suffix varchar2(3);
  l_url varchar2(300);
  l_custom_sql varchar2(4000);
  l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_where_clause VARCHAR2(2000);
  l_view_by_value VARCHAR2(100);
  l_mv VARCHAR2(30);
  l_context_code VARCHAR2(10);
  l_to_date_type VARCHAR2(10);
  l_file varchar2(500);
  l_uom VARCHAR2(200);
  l_from_clause VARCHAR2(500);
  l_where_clause2 VARCHAR2(500);
  l_sel_clause varchar2(4000);
 BEGIN
  l_comparison_type      := 'Y';


FOR i in 1..p_param.last
LOOP
   IF p_param(i).parameter_name = 'LOOKUP+UOMCODE' THEN
      l_uom := p_param(i).parameter_value ;
      l_uom := nvl(l_uom,'-1');
   END IF ;
END LOOP ;


   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
   l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);


   poa_dbi_sutil_pkg.process_parameters(p_param,
                                        l_view_by,
                                        l_view_by_col,
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
                                        'N','PO', '8.0', 'VPP','POD');


   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

   poa_dbi_util_pkg.add_column(l_col_tbl,
                               'purchase_amt_' || l_cur_suffix,
                               'purchase_amt',
                                p_to_date_type => l_to_date_type);


   poa_dbi_util_pkg.add_column(l_col_tbl,
                               'nz_quantity',
                               'nz_quantity',
                                p_to_date_type => l_to_date_type);


  l_query := get_dtl_sel_clause(l_view_by_col)  ;

  l_query := l_query || ' from
              '|| dtl_status_sql(
                                   l_mv,
                                   l_where_clause,
                                   l_join_tbl,
                                   p_use_windowing => 'Y',
                                   p_col_name => l_col_tbl,
				   p_use_grpid => 'N',
				   p_filter_where => get_dtl_sts_filter_where,
                                   p_in_join_tables => l_in_join_tbl,
                                   p_uom_code => l_uom ,
                                   p_view_by => l_view_by );

  x_custom_sql := l_query;

    poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

END iapd_rpt_sql ;

----------------------------------------------------------------------------------

 FUNCTION get_dtl_sts_filter_where RETURN VARCHAR2
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
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE12';

    RETURN poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END get_dtl_sts_filter_where ;

----------------------------------------------------------------------------------

  FUNCTION dtl_status_sql (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                          VARCHAR2 := 'Y'
  , p_paren_count               IN       NUMBER := 4
  , p_filter_where              IN       VARCHAR2 := NULL
  , p_generate_viewby           IN       VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_in_join_tbl := NULL
  , p_uom_code                  IN VARCHAR2
  , p_view_by                  IN VARCHAR2
 )
    RETURN VARCHAR2
  IS
    l_query                  VARCHAR2 (10000);
    l_col_names              VARCHAR2 (10000);
    l_group_and_sel_clause   VARCHAR2 (10000);
    l_from_clause            VARCHAR2 (10000);
    l_full_where_clause           VARCHAR2 (10000);
    l_grpid_clause           VARCHAR2 (200);
    l_compute_prior          VARCHAR2 (1)     := 'N';
    l_compute_prev_prev      VARCHAR2 (1)     := 'N';
    l_paren_str              VARCHAR2 (2000);
    l_compute_opening_bal    VARCHAR2(1)     := 'N';
    l_inlist                 VARCHAR2 (300);
    l_inlist_bmap            NUMBER           := 0;
    l_total_col_names        VARCHAR2 (10000);
    l_viewby_rank_where      VARCHAR2 (10000);
    l_in_join_tables         VARCHAR2 (1000) := '';
    l_filter_where           VARCHAR2 (1000);
    l_join_tables	     VARCHAR2 (10000);
    l_col_calc_tbl	     poa_dbi_util_pkg.poa_dbi_col_calc_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl ;
    l_join_rec               poa_dbi_util_pkg.POA_DBI_JOIN_REC ;
    l_group_by               varchar2(100);
    l_add_sel_col            varchar2(100);

  BEGIN

    IF (p_use_grpid = 'Y')
    THEN
      l_grpid_clause    := 'and fact.grp_id = decode(cal.period_type_id,1,14,16,13,32,11,64,7)';
    ELSIF (p_use_grpid = 'R')
    THEN
      	l_grpid_clause    := 'and fact.grp_id = decode(cal.period_type_id,1,0,16,1,32,3,64,7)';
    END IF;
   l_group_and_sel_clause    := get_group_and_sel_clause(p_join_tables, p_use_alias => 'Y');

    IF(p_in_join_tables is not null) then

      FOR i in 1 .. p_in_join_tables.COUNT
      LOOP
        l_in_join_tables := l_in_join_tables || ', ' ||  p_in_join_tables(i).table_name || ' ' || p_in_join_tables(i).table_alias;
      END LOOP;
    END IF;

    poa_dbi_template_pkg.get_status_col_calc(  p_col_name
			, l_col_calc_tbl
			, l_inlist_bmap
			, l_compute_prior
			, l_compute_prev_prev
			, l_compute_opening_bal);

    l_col_names := '';

    FOR i IN 1 .. l_col_calc_tbl.COUNT
    LOOP
	l_col_names := l_col_names
		|| ', '
		|| l_col_calc_tbl(i).calc_begin
		|| l_col_calc_tbl(i).date_decode_begin
		|| l_col_calc_tbl(i).column_name
		|| l_col_calc_tbl(i).date_decode_end
		|| l_col_calc_tbl(i).calc_end
		|| ' '
		|| l_col_calc_tbl(i).alias_begin
		|| l_col_calc_tbl(i).alias_end
		|| fnd_global.newline;
    END LOOP;


    -- 0 (0 0 0) = neither XTD or XED
    -- 1 (0 0 1) = XED
    -- 2 (0 1 0) = XTD
    -- 3 (0 1 1) = both XTD and XED
    -- 4 (1 0 0) = YTD
    -- 5 (1 0 1) = YTD and XED
    -- 6 (1 1 0) = YTD and XTD)
    -- 7 (1 1 1) = YTD and XTD and XED

    l_inlist                  :=
          '('
       || CASE
            WHEN -- if one or more columns had XED
                 BITAND (l_inlist_bmap
                       , poa_dbi_template_pkg.g_inlist_xed) = poa_dbi_template_pkg.g_inlist_xed
              THEN -- alway append current
                       poa_dbi_template_pkg.g_c_period_end_date
                    || CASE -- append prev date if needed
                         WHEN l_compute_prior = 'Y'
                           THEN ',' || poa_dbi_template_pkg.g_p_period_end_date
                       END
          END
       || CASE -- when XED and (XTD or YTD) exist
            WHEN l_inlist_bmap IN (3, 5, 7)
              THEN ','
          END
       || CASE -- if one or more columns had XTD
            WHEN (   BITAND (l_inlist_bmap
                           , poa_dbi_template_pkg.g_inlist_xtd) = poa_dbi_template_pkg.g_inlist_xtd
                  OR BITAND (l_inlist_bmap
                           , poa_dbi_template_pkg.g_inlist_ytd) = poa_dbi_template_pkg.g_inlist_ytd)
              THEN -- alway append current
                       poa_dbi_template_pkg.g_c_as_of_date
                    || CASE -- append prev date if needed
                         WHEN l_compute_prior = 'Y'
                           THEN ',' || poa_dbi_template_pkg.g_p_as_of_date
                       END
          END
       || case
            when bitand(l_inlist_bmap, poa_dbi_template_pkg.g_inlist_rlx) = poa_dbi_template_pkg.g_inlist_rlx then
              poa_dbi_template_pkg.g_c_period_end_date
              || case -- append prev date if needed
                   when l_compute_prior = 'Y' then
                     ',' || poa_dbi_template_pkg.g_p_period_end_date
                   end
          end
       || case
            when bitand(l_inlist_bmap, poa_dbi_template_pkg.g_inlist_bal) = poa_dbi_template_pkg.g_inlist_bal then
              poa_dbi_template_pkg.g_c_as_of_date_balance
              || case -- append prev date if needed
                   when l_compute_prior = 'Y' then
                     ',' || poa_dbi_template_pkg.g_p_as_of_date_balance
                   end
              || case
                   when l_compute_opening_bal = 'Y' then
                     ',' || poa_dbi_template_pkg.g_c_as_of_date_o_balance
                   end
          end
       || CASE
            WHEN l_compute_prev_prev = 'Y'
              THEN ', &PREV_PREV_DATE'
          END
       || ')';


    IF p_filter_where is not null
    THEN
   l_filter_where := ' where ' || p_filter_where;
    END IF;

   -- Determine how many closing parens we need
    l_paren_str := get_paren_str(p_paren_count,
		l_filter_where);

    if( bitand(l_inlist_bmap, poa_dbi_template_pkg.g_inlist_rlx) = poa_dbi_template_pkg.g_inlist_rlx) then
	l_join_tables := ', fii_time_structures cal '|| l_in_join_tables;
	l_full_where_clause := ' where fact.time_id = cal.time_id '
			|| 'and fact.period_type_id = cal.period_type_id '
			|| fnd_global.newline
			|| p_where_clause
			|| fnd_global.newline
       			|| 'and cal.report_date in '
    			|| l_inlist
	            -- &RLX_NESTED_PATTERN should be replaced with some
		    -- &BIS bind substitution when available from fii/bis team.
       			|| fnd_global.newline
			|| 'and bitand(cal.record_type_id, &RLX_NESTED_PATTERN) = '
			|| '&RLX_NESTED_PATTERN ';
    elsif( bitand(l_inlist_bmap, poa_dbi_template_pkg.g_inlist_bal) = poa_dbi_template_pkg.g_inlist_bal) then
	l_join_tables := '';
	l_full_where_clause := ' where fact.report_date in '
				|| l_inlist
       				|| p_where_clause;
   elsif( l_inlist_bmap = 0) then  --for status sqls with no as-of date or compare to
	l_join_tables := l_in_join_tables;
	if(p_where_clause is not null) then
		l_full_where_clause := ' where ' || p_where_clause;
	end if;
   else
	l_join_tables := ', fii_time_rpt_struct_v cal'
			|| fnd_global.newline
			|| l_in_join_tables;
	l_full_where_clause :=' where fact.time_id = cal.time_id '
       			|| p_where_clause
       			|| fnd_global.newline
			|| ' and cal.report_date in '
       			|| l_inlist
       			|| fnd_global.newline
			|| ' and bitand(cal.record_type_id, '
       			|| CASE -- if one or more columns = YTD then use nested pattern
            		WHEN BITAND (l_inlist_bmap, poa_dbi_template_pkg.g_inlist_ytd) = poa_dbi_template_pkg.g_inlist_ytd
              		THEN '&YTD_NESTED_PATTERN'
            		ELSE '&BIS_NESTED_PATTERN'
         		END
       			|| ') = cal.record_type_id ';
    end if;

    IF (p_view_by <> 'ITEM+POA_ITEMS')
    THEN
       l_group_by := ' group by fact.base_uom, ' ;
       l_add_sel_col := ' fact.base_uom, ' ;
    ELSE
       l_group_by := 'group by ' ;
       l_add_sel_col := null ;
    END IF ;
      l_query := '(select '
        || l_add_sel_col
        || l_group_and_sel_clause
        || l_col_names
        || fnd_global.newline||' from '
        || p_fact_name
        || ' fact'
        || l_join_tables
        || l_full_where_clause
        || ' and nvl(fact.base_uom ,''-1'') = ''' || p_uom_code || ''''
        || l_grpid_clause
        || fnd_global.newline
        || l_group_by
        || l_group_and_sel_clause
        || l_paren_str;



  IF(p_generate_viewby = 'Y')
  THEN
    l_viewby_rank_where :='';

    if(p_use_windowing <> 'P') then
	l_viewby_rank_where := l_viewby_rank_where ||
		',' || fnd_global.newline;
    end if;

    l_join_tbl := p_join_tables ;

   IF (p_view_by <> 'ITEM+POA_ITEMS' )
   THEN
    l_join_rec.table_name := 'mtl_units_of_measure_vl';
    l_join_rec.table_alias := 'v2';
    l_join_rec.fact_column :='base_uom';
    l_join_rec.column_name := 'unit_of_measure';
    l_join_rec.dim_outer_join := 'Y';
    l_join_tbl.extend;
    l_join_tbl(l_join_tbl.count) := l_join_rec;
  END IF ;

    l_viewby_rank_where := l_viewby_rank_where ||
       poa_dbi_template_pkg.get_viewby_rank_clause (
          p_join_tables       => l_join_tbl
        , p_use_windowing     => p_use_windowing);
  END IF;

    l_query := l_query || l_viewby_rank_where;

    RETURN l_query;
  END dtl_status_sql;


----------------------------------------------------------------------------------

 FUNCTION get_dtl_sel_clause(p_view_by_col in VARCHAR2)
 RETURN VARCHAR2
 IS
  l_sel_clause varchar2(4000);
 BEGIN

   if(p_view_by_col = 'commodity_id') then
     l_sel_clause := 'select decode(v.name,null,
     fnd_message.get_string(''POA'', ''POA_DBI_APL_UNASSIGNED''), v.name) VIEWBY,
     decode(v.commodity_id,null, -1, v.commodity_id) VIEWBYID,';
  else
     l_sel_clause := 'select v.value VIEWBY, v.id VIEWBYID, ';
  end if;

    l_sel_clause  := l_sel_clause || ' v2.description  POA_ATTRIBUTE10,
                    oset.POA_MEASURE12 POA_MEASURE12,
                    oset.POA_MEASURE13 POA_MEASURE13,
                    oset.POA_MEASURE1 POA_MEASURE1,
                    oset.POA_PERCENT1 POA_PERCENT1 ,
                    oset.POA_MEASURE2 POA_MEASURE2 ,
                    oset.POA_PERCENT2 POA_PERCENT2 ,
                    oset.POA_MEASURE3 POA_MEASURE3 ,
                    oset.POA_PERCENT3 POA_PERCENT3 ,
                    oset.POA_MEASURE4 POA_MEASURE4 ,
                    oset.POA_MEASURE5 POA_MEASURE5 ,
                    oset.POA_MEASURE6  POA_MEASURE6,
                    oset.POA_PERCENT4  POA_PERCENT4
     from
     (select (rank() over
                   (&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col || ')) - 1 rnk,'
        || p_view_by_col || ', base_uom ,
           POA_MEASURE12, POA_MEASURE13, POA_PERCENT1, POA_MEASURE1, POA_PERCENT2, POA_MEASURE2,
           POA_MEASURE3, POA_PERCENT3 , POA_MEASURE4, POA_MEASURE5 , POA_MEASURE6,
            POA_PERCENT4
	    from
	    ( select ' || p_view_by_col || ', base_uom ,
           POA_MEASURE12, POA_MEASURE13, POA_PERCENT1, POA_MEASURE1, POA_PERCENT2, POA_MEASURE2,
           POA_MEASURE3, POA_PERCENT3 , (POA_MEASURE2 - POA_MEASURE12*min_avg) POA_MEASURE4,
           (POA_MEASURE3 - POA_MEASURE13*min_avg) POA_MEASURE5 ,
           (POA_MEASURE3/decode(POA_MEASURE13,0,null,POA_MEASURE13)) POA_MEASURE6,
            POA_PERCENT4
           from
              (select ' || p_view_by_col || ', base_uom ,
                ' || p_view_by_col || ' VIEWBY,
              decode(base_uom,null,to_number(null), nvl(c_nz_quantity,0)) POA_MEASURE12,
              decode(base_uom,null,to_number(null),nvl(c_nz_quantity_total,0)) POA_MEASURE13,
              min(nvl(c_purchase_amt,0)/decode(c_nz_quantity,0,null,c_nz_quantity)) over() min_avg ,
              nvl(c_purchase_amt,0)/decode(c_nz_quantity,0,null,c_nz_quantity) POA_MEASURE1,
              (((nvl(c_purchase_amt,0)/decode(c_nz_quantity,0,null,c_nz_quantity)) -
              (nvl(p_purchase_amt,0)/decode(p_nz_quantity,0,null,p_nz_quantity)))/
               (nvl(p_purchase_amt,0)/decode(p_nz_quantity,0,null,p_nz_quantity)))*100 POA_PERCENT1,
               nvl(c_purchase_amt,0) POA_MEASURE2,
               ((nvl(c_purchase_amt,0)- nvl(p_purchase_amt,0)) /
                (decode(p_purchase_amt,0,null,p_purchase_amt)))*100 POA_PERCENT2,
                nvl(c_purchase_amt_total,0) POA_MEASURE3,
                ((nvl(c_purchase_amt_total,0)-nvl(p_purchase_amt_total,0))/
                 (decode(p_purchase_amt_total,0,null,p_purchase_amt_total))) * 100 POA_PERCENT3  ,
              (((nvl(c_purchase_amt_total,0)/decode(c_nz_quantity_total,0,null,c_nz_quantity_total)) -
              (nvl(p_purchase_amt_total,0)/decode(p_nz_quantity_total,0,null,p_nz_quantity_total)))/
               (nvl(p_purchase_amt_total,0)/decode(p_nz_quantity_total,0,null,p_nz_quantity_total)))*100 POA_PERCENT4
' ;

 RETURN l_sel_clause ;
 END  get_dtl_sel_clause ;


FUNCTION get_group_and_sel_clause(
	p_join_tables IN poa_dbi_util_pkg.poa_dbi_join_tbl
	, p_use_alias IN VARCHAR2
) RETURN VARCHAR2
IS
   l_group_and_sel_clause    	VARCHAR2 (500);
   l_alias			VARCHAR2 (200);
BEGIN
    l_alias := '';
    if(p_use_alias = 'Y') then
	if(p_join_tables(1).inner_alias is not null) then
	    l_alias := p_join_tables(1).inner_alias || '.';
	else
	    l_alias   := 'fact.';
	end if;
    end if;

    l_group_and_sel_clause    := ' ' || l_alias || p_join_tables (1).fact_column;


    FOR i IN 2 .. p_join_tables.COUNT
    LOOP

       l_alias := '';
       if(p_use_alias = 'Y') then
	   if(p_join_tables(i).inner_alias is not null) then
	       l_alias := p_join_tables(i).inner_alias || '.';
	   else
	       l_alias   := 'fact.';
	   end if;
       end if;

 	l_group_and_sel_clause := l_group_and_sel_clause
				||', ' || l_alias
				|| p_join_tables(i).fact_column;
    END LOOP;

    return l_group_and_sel_clause;
END get_group_and_sel_clause;



FUNCTION get_paren_str(p_paren_count IN NUMBER,
		p_filter_where IN VARCHAR2) RETURN VARCHAR2
IS
 l_paren_str	VARCHAR2 (10000);
BEGIN
    IF p_paren_count = 2
    THEN
      l_paren_str    := ' ) oset05 ' || p_filter_where || ') oset ';
    ELSIF p_paren_count = 3
    THEN
      l_paren_str    := ' ) ) ' || p_filter_where || ' ) oset ';
    ELSIF p_paren_count = 4
    THEN
      l_paren_str    := ' ) ) ) ' || p_filter_where || ' ) oset ';
    ELSIF p_paren_count = 5
    THEN
      l_paren_str    := ' ) oset05) oset10) oset15) oset20 '
         || p_filter_where || ')oset ';
    ELSIF p_paren_count = 6
    THEN
      l_paren_str    := ' ) oset05) oset10) oset15) oset20) oset25 '
         || p_filter_where || ' )oset ';
    ELSIF p_paren_count = 7
    THEN
      l_paren_str    := ' ) oset05) oset10) oset13) oset15) oset20) '
         || p_filter_where || ' )oset ';
    END IF;

    return l_paren_str;
END get_paren_str;

END poa_dbi_iap_pkg;

/
