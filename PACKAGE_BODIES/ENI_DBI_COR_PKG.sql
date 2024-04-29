--------------------------------------------------------
--  DDL for Package Body ENI_DBI_COR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_COR_PKG" AS
/*$Header: ENICORPB.pls 120.2 2006/03/23 04:37:02 pgopalar noship $*/

PROCEDURE get_sql
(
  p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
        , x_custom_sql        OUT NOCOPY VARCHAR2
        , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

  l_custom_rec   BIS_QUERY_ATTRIBUTES;
  l_err_msg   VARCHAR2(500);
  l_period_type   VARCHAR2(140);
  l_sql_stmt   VARCHAR2(15000);
  l_period_bitand  NUMBER;
  l_view_by   VARCHAR2(200);
  l_as_of_date   DATE;
  l_prev_as_of_date  DATE;
  l_report_start  DATE;
  l_cur_period   NUMBER;
  l_days_into_period  NUMBER;
  l_comp_type   VARCHAR2(200);
  l_category   VARCHAR2(200);
  l_item   VARCHAR2(200);
  l_org    VARCHAR2(200);
  l_id_column   VARCHAR2(130);
  l_order_by   VARCHAR2(200);
  l_drill   VARCHAR2(130);
  l_status   VARCHAR2(130);
  l_priority   VARCHAR2(130);
  l_reason   VARCHAR2(130);
  l_lifecycle_phase  VARCHAR2(130);
  l_currency   VARCHAR2(130);
  l_bom_type   VARCHAR2(130);
  l_type   VARCHAR2(130);
  l_manager   VARCHAR2(130);
  l_org_where   VARCHAR2(100);
  l_org_where_dn  VARCHAR2(100);
  l_item_where   VARCHAR2(100);
  l_item_where_dn  VARCHAR2(100);
  l_priority_where  VARCHAR2(100);
  l_priority_where_dn  VARCHAR2(100);
  l_status_where  VARCHAR2(100);
  l_status_where_dn  VARCHAR2(100);
  l_type_where   VARCHAR2(100);
  l_type_where_dn  VARCHAR2(100);
  l_reason_where  VARCHAR2(100);
  l_reason_where_dn  VARCHAR2(100);
  l_lob    VARCHAR2(1000);
  l_from_clause   VARCHAR2(1000);
  l_where_clause  VARCHAR2(500);
  l_where_clause_dn  VARCHAR2(500);
  l_group_by_clause  VARCHAR2(500);
  l_concat_var   VARCHAR2(1000);
  l_lookup   VARCHAR2(100);
  l_lookup_alias  VARCHAR2(100);
  l_group_by   VARCHAR2(100);
  l_select   VARCHAR2(100);
  l_select_id   VARCHAR2(100);
  l_cursor   INTEGER;
  l_new_url   VARCHAR2(1000);
  l_impl_url   VARCHAR2(1000);
  l_open_url   VARCHAR2(1000);
  l_canc_url   VARCHAR2(1000);
  l_new_url_time  VARCHAR2(1000);
  l_impl_url_time  VARCHAR2(1000);
  l_open_url_time  VARCHAR2(1000);
  l_canc_url_time  VARCHAR2(1000);
  l_avg_age_url   VARCHAR2(1000);
  l_cycle_url   VARCHAR2(1000);
  l_avg_age_url_time  VARCHAR2(1000);
  l_cycle_url_time  VARCHAR2(1000);
  l_item_from_clause  VARCHAR2(1000);
  l_select_id_list  VARCHAR2(1000);
  l_outer_join_condition VARCHAR2(1000);
  l_description   VARCHAR2(1000);
  l_outer_group_by  VARCHAR2(1000);


BEGIN

  -- TODO Change the nvl_date to bind parameter in Non TIME VIEWBY

l_open_url:='''pFunctionName=ENI_DBI_COL_OPEN_R&pCustomView=ENI_DBI_COL_CV1&REPORTED=OPEN&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y''';
l_new_url:= '''pFunctionName=ENI_DBI_COL_NEW_R&pCustomView=ENI_DBI_COL_CV3&REPORTED=NEW&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y''';
l_impl_url:='''pFunctionName=ENI_DBI_COL_IMPL_R&pCustomView=ENI_DBI_COL_CV2&REPORTED=IMPL&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y''';
l_canc_url:='''pFunctionName=ENI_DBI_COL_CANC_R&pCustomView=ENI_DBI_COL_CV5&REPORTED=CANC&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y''';
l_avg_age_url:='''pFunctionName=ENI_DBI_COA_R&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ENI_CHANGE_MGMT_TYPE+ENI_CHANGE_MGMT_TYPE&pParamIds=Y''';
l_cycle_url:='''pFunctionName=ENI_DBI_COC_R&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ENI_CHANGE_MGMT_TYPE+ENI_CHANGE_MGMT_TYPE&pParamIds=Y''';

/* Bug : 3465553
l_open_url_time:='''pFunctionName=ENI_DBI_COL_OPEN_R&pCustomView=ENI_DBI_COL_CV1&REPORTED=OPEN'||
'&start_date=''||to_char(s.start_date,''dd-mm-yyyy'')||''&end_date=''||to_char(s.c_end_date,''dd-mm-yyyy'')||''&''||''AS_OF_DATE=''||to_char(s.c_end_date,''dd-mm-yyyy'')';
l_new_url_time:= '''pFunctionName=ENI_DBI_COL_NEW_R&pCustomView=ENI_DBI_COL_CV3&REPORTED=NEW'||
'&start_date=''||to_char(s.start_date,''dd-mm-yyyy'')||''&end_date=''||to_char(s.c_end_date,''dd-mm-yyyy'')||''&''||''AS_OF_DATE=''||to_char(s.c_end_date,''dd-mm-yyyy'')';
l_impl_url_time:='''pFunctionName=ENI_DBI_COL_IMPL_R&pCustomView=ENI_DBI_COL_CV2&REPORTED=IMPL'||
'&start_date=''||to_char(s.start_date,''dd-mm-yyyy'')||''&end_date= ''||to_char(s.c_end_date,''dd-mm-yyyy'')||''&''||''AS_OF_DATE=''||to_char(s.c_end_date,''dd-mm-yyyy'')';
l_canc_url_time:='''pFunctionName=ENI_DBI_COL_CANC_R&pCustomView=ENI_DBI_COL_CV5&REPORTED=CANC'||
'&start_date=''||to_char(s.start_date,''dd-mm-yyyy'')||''&end_date= ''||to_char(s.c_end_date,''dd-mm-yyyy'')||''&''||''AS_OF_DATE=''||to_char(s.c_end_date,''dd-mm-yyyy'')';

Bug : 3465553
*/
l_open_url_time :=null;
l_new_url_time :=null;
l_impl_url_time :=null;
l_avg_age_url_time :=null;
l_cycle_url_time :=null;
/*l_avg_age_url_time:='''pFunctionName=ENI_DBI_COA_R'''||
'||''&''||''AS_OF_DATE=''||to_char(s.c_end_date,''dd-mm-yyyy'')||''&VIEW_BY=ENI_CHANGE_MGMT_TYPE+ENI_CHANGE_MGMT_TYPE''';
l_cycle_url_time:='''pFunctionName=ENI_DBI_COC_R'''||
'||''&''||''AS_OF_DATE=''||to_char(s.c_end_date,''dd-mm-yyyy'')||''&VIEW_BY=ENI_CHANGE_MGMT_TYPE+ENI_CHANGE_MGMT_TYPE''';
*/

  ENI_DBI_UTIL_PKG.get_parameters( p_page_parameter_tbl
                                 , l_period_type
                                 , l_period_bitand
                                 , l_view_by
                                 , l_as_of_date
                                 , l_prev_as_of_date
                                 , l_report_start
                                 , l_cur_period
                                 , l_days_into_period
                                 , l_comp_type
                                 , l_category
                                 , l_item
                                 , l_org
                                 , l_id_column
                                 , l_order_by
                                 , l_drill
                                 , l_status
                                 , l_priority
                                 , l_reason
                                 , l_lifecycle_phase
                                 , l_currency
                                 , l_bom_type
                                 , l_type
                                 , l_manager
                                 , l_lob
                                 );


  l_order_by := UPPER(l_order_by);
  IF INSTR(l_order_by,'.') > 0 THEN
    l_order_by := SUBSTR(l_order_by,INSTR(l_order_by,'.')+1);
  END IF;

  IF l_order_by like '%AS' THEN
     l_order_by := l_order_by||'C';
  ELSIF l_order_by like '%DES' THEN
     l_order_by := l_order_by || 'C';
  END IF;

  --If the item is null, then we return no rows
  if(l_view_by <> 'ITEM+ENI_ITEM_ORG')
  then
  IF l_item IS NULL OR l_item = 'All' THEN
    l_sql_stmt :=
      'SELECT null as VIEWBY,
        null as ENI_MEASURE64,
        null as ENI_MEASURE1,
        null as ENI_MEASURE12,
        null as ENI_MEASURE6,
        null as ENI_MEASURE2,
        null as ENI_MEASURE3,
        null as ENI_MEASURE7,
        null as ENI_MEASURE4,
        null as ENI_MEASURE5,
        null as ENI_MEASURE40,
        null as ENI_MEASURE41,
        null as ENI_MEASURE42,
        null as ENI_MEASURE9,
        null as ENI_MEASURE13,
        null as ENI_MEASURE8,
        null as ENI_MEASURE10,
        null as ENI_MEASURE14,
        null as ENI_MEASURE15,
        null as ENI_MEASURE27,
        null as ENI_MEASURE28,
        null as ENI_MEASURE16,
        null as ENI_MEASURE17,
        null as ENI_MEASURE20,
        null as ENI_MEASURE18,
        null as ENI_MEASURE21,
        null as ENI_MEASURE22,
        null as ENI_MEASURE23,
        null as ENI_MEASURE24,
        null as ENI_MEASURE25,
        null as ENI_MEASURE26,
        null as ENI_MEASURE43,
        null as ENI_MEASURE44,
        null as ENI_MEASURE45,
        null as ENI_MEASURE30,
        null as ENI_MEASURE31,
        null as ENI_MEASURE35,
        null as ENI_MEASURE36,
        null as ENI_MEASURE37,
        null as ENI_MEASURE38,
        null as ENI_MEASURE39,
 null as ENI_MEASURE47,
 null as ENI_MEASURE48,
 null as ENI_MEASURE49,
 null as ENI_MEASURE50,
 null as ENI_MEASURE56,
 null as ENI_MEASURE57,
 null as ENI_MEASURE58,
 null as ENI_MEASURE59,
 null as ENI_MEASURE61,
 null as ENI_MEASURE62,
 null as ENI_MEASURE63,
 null as ENI_MEASURE53,
 null as ENI_MEASURE54
 FROM DUAL';

  END IF;
END IF;
  -- set where clause
  IF l_org IS NOT NULL AND l_org <> 'All' THEN
  --Bug 5083876 -Start Code
    l_org_where    := ' AND edcs.organization_id(+) = :ORGANIZATION_ID';
    l_org_where_dn := ' AND edcs.organization_id = :ORGANIZATION_ID';
--    l_org_where    := ' AND edcs.organization_id(+) = ' || REPLACE(l_org,'''');
  --  l_org_where_dn := ' AND edcs.organization_id = ' || REPLACE(l_org,'''');
  --Bug 5083876 - End Code
  END IF;

  IF l_item IS NOT NULL AND l_item <> 'All' THEN
     l_item_where := ' AND edcs.item_id(+) = :ITEM_ID';
     l_item_where_dn := ' AND edcs.item_id = :ITEM_ID';
--    l_item_where := ' AND edcs.item_id(+) = ' || REPLACE(l_item,'''');
--    l_item_where_dn := ' AND edcs.item_id = ' || REPLACE(l_item,'''');
  END IF;

  IF (l_status IS NULL OR l_status = 'All') AND l_view_by LIKE '%STATUS' THEN
    l_status_where  := ' AND edcs.status_type IS NOT NULL';
    l_status  := '';
  ELSIF (l_status IS NULL OR l_status = 'All') THEN
    l_status_where    := ' AND edcs.status_type IS NULL';
    l_status_where_dn := '';
    l_status    := '';
  ELSE
    l_status_where    := ' AND edcs.status_type(+) = :STATUS_ID';
    l_status_where_dn := ' AND edcs.status_type = :STATUS_ID';
  END IF;

  IF (l_priority IS NULL OR l_priority = 'All') AND l_view_by LIKE '%PRIORITY' THEN
    l_priority_where := ' AND edcs.priority_code IS NOT NULL';
    l_priority   := '';
  ELSIF (l_priority IS NULL OR l_priority = 'All') THEN
    l_priority_where  := ' AND edcs.priority_code IS NULL';
    l_priority_where_dn  := '';
    l_priority    := '';
  ELSE
    l_priority_where  := ' AND edcs.priority_code(+) = :PRIORITY_ID';
    l_priority_where_dn  := ' AND edcs.priority_code = :PRIORITY_ID';
  END IF;

  IF (l_reason IS NULL OR l_reason = 'All') AND l_view_by LIKE '%REASON' THEN
    l_reason_where  := ' AND edcs.reason_code IS NOT NULL';
    l_reason  := '';
  ELSIF (l_reason IS NULL OR l_reason = 'All') THEN
    l_reason_where    := ' AND edcs.reason_code IS NULL';
    l_reason_where_dn  := '';
    l_reason    := '';
  ELSE
    l_reason_where    := ' AND edcs.reason_code(+) = :REASON_ID'; --|| l_priority;
    l_reason_where_dn  := ' AND edcs.reason_code = :REASON_ID'; --|| l_priority;
  END IF;

  IF (l_type IS NULL OR l_type = 'All') AND l_view_by LIKE '%TYPE' THEN
    l_type_where  := ' AND edcs.change_order_type_id IS NOT NULL';
    l_type    := '';
  ELSIF l_type IS NULL OR l_type = 'All' THEN
    l_type_where  := ' AND edcs.change_order_type_id IS NULL';
    l_type_where_dn := '';
    l_type := '';
  ELSE
    l_type_where  := ' AND edcs.change_order_type_id(+) = :TYPE_ID';
    l_type_where_dn := ' AND edcs.change_order_type_id = :TYPE_ID';
  END IF;

  l_where_clause_dn := l_item_where_dn
       || l_org_where_dn
       || l_status_where_dn
       || l_priority_where_dn
       || l_reason_where_dn
       || l_type_where_dn;

-- Time view by
  IF substr(l_view_by, 1, 5) = 'TIME+'  AND (l_item IS NOT NULL AND l_item <> 'All' ) THEN

    eni_dbi_util_pkg.get_time_clauses(
                        'A',
                        'edcs',
                        l_period_type,
                        l_period_bitand,
                        l_as_of_date,
                        l_prev_as_of_date,
                        l_report_start,
                        l_cur_period,
                        l_days_into_period,
                        l_comp_type,
                        l_id_column,
                        l_from_clause,
                        l_where_clause,
                        l_group_by_clause,
   'ROLLING'
                        );

    l_where_clause :=  l_where_clause || l_item_where
                                      || l_org_where
                                      || l_status_where
                                      || l_priority_where
                                      || l_reason_where
                                      || l_type_where;

    IF l_order_by like '%START_DATE%' THEN
      IF l_order_by like '%ASC' THEN
        l_order_by := 'S.TIME_ID ASC';
      ELSE
        l_order_by := 'S.TIME_ID DESC';
      END IF;
    ELSE
      l_order_by := 'S.TIME_ID ASC';
    END IF;

    l_sql_stmt := '
SELECT
  s.name AS VIEWBY
, NULL AS ENI_MEASURE64
, c.C_OPEN_SUM AS ENI_MEASURE1
, nvl(c.C_OPEN_SUM,0) AS ENI_MEASURE12
, c.P_OPEN_SUM AS ENI_MEASURE6
, (((c.C_OPEN_SUM - c.P_OPEN_SUM)
   /DECODE(c.P_OPEN_SUM,0,NULL,c.P_OPEN_SUM))* 100)
  AS ENI_MEASURE2
, (c.c_avg_age/DECODE(c.c_open_sum,0,NULL,c.c_open_sum))
  AS ENI_MEASURE3
, (c.p_avg_age/DECODE(c.p_open_sum,0,NULL,c.p_open_sum))
  AS ENI_MEASURE7
, ((((c.c_avg_age/DECODE(c.c_open_sum,0,NULL,c.c_open_sum))
    -(c.p_avg_age/DECODE(c.p_open_sum,0,NULL,c.p_open_sum)))
   /DECODE((c.p_avg_age
            /DECODE(c.p_open_sum,0,NULL,c.p_open_sum))
            ,0,NULL,
            (c.p_avg_age/DECODE(c.p_open_sum,0,NULL,c.p_open_sum)))) * 100)
  AS ENI_MEASURE4
, c.c_bucket1 AS ENI_MEASURE5
, c.c_bucket2 AS ENI_MEASURE40
, c.c_bucket3 AS ENI_MEASURE41
, c.c_bucket4 AS ENI_MEASURE42
, s.C_NEW_SUM AS ENI_MEASURE9
, nvl(s.C_NEW_SUM,0) AS ENI_MEASURE13
, s.P_NEW_SUM AS ENI_MEASURE8
, (((s.C_NEW_SUM - s.P_NEW_SUM)/DECODE(s.P_NEW_SUM,0,NULL,s.P_NEW_SUM))*100)
  AS ENI_MEASURE10
, s.C_CANL_SUM AS ENI_MEASURE14
, s.C_IMPL_SUM AS ENI_MEASURE15
, s.P_CANL_SUM AS ENI_MEASURE27
, s.P_CANL_SUM AS ENI_MEASURE28
, ((((s.C_CANL_SUM+s.C_IMPL_SUM)-(s.P_CANL_SUM+s.P_IMPL_SUM))
   /DECODE((s.P_CANL_SUM+s.P_IMPL_SUM),0,NULL,(s.P_CANL_SUM+s.P_IMPL_SUM))) * 100)
  AS ENI_MEASURE16
, s.C_CYCL_SUM/DECODE(s.C_CYCL_CNT,0,NULL,s.C_CYCL_CNT)
  AS ENI_MEASURE17
, s.P_CYCL_SUM/DECODE(s.P_CYCL_CNT,0,NULL,s.P_CYCL_CNT)
  AS ENI_MEASURE20
, ((((s.C_CYCL_SUM/DECODE(s.C_CYCL_CNT,0,NULL,s.C_CYCL_CNT)
     )
     -(s.P_CYCL_SUM/DECODE(s.P_CYCL_CNT,0,NULL,s.P_CYCL_CNT))
    )
    /DECODE((s.P_CYCL_SUM/DECODE(s.P_CYCL_CNT,0,NULL,s.P_CYCL_CNT)),0,NULL,
            (s.P_CYCL_SUM/DECODE(s.P_CYCL_CNT,0,NULL,s.P_CYCL_CNT)))
   )*100
  ) AS ENI_MEASURE18
, NVL(s.C_CANL_SUM,0)+NVL(s.C_IMPL_SUM,0) AS ENI_MEASURE21
, NULL AS ENI_MEASURE22
, NULL AS ENI_MEASURE23
, NULL AS ENI_MEASURE24
, NULL AS ENI_MEASURE25
, NULL AS ENI_MEASURE26
, NULL AS ENI_MEASURE43
, NULL AS ENI_MEASURE44
, NULL AS ENI_MEASURE45
, NULL AS ENI_MEASURE30
, NULL AS ENI_MEASURE31
, NULL AS ENI_MEASURE35
, NULL AS ENI_MEASURE36
, NULL AS ENI_MEASURE37
, NULL AS ENI_MEASURE38
, NULL AS ENI_MEASURE39
, NULL AS ENI_MEASURE47
, NULL AS ENI_MEASURE48
, NULL AS ENI_MEASURE49
, NULL AS ENI_MEASURE50
, NULL AS ENI_MEASURE56
, NULL AS ENI_MEASURE57
, NULL AS ENI_MEASURE58
, NULL as ENI_MEASURE59
, NULL as ENI_MEASURE61
, NULL as ENI_MEASURE62
, NULL as ENI_MEASURE63
, NULL as ENI_MEASURE53
, NULL as ENI_MEASURE54
FROM
 (SELECT
    t.name as name,t.start_date,t.c_end_date,t.c_end_date as time_id
  , SUM(CASE WHEN ftrs.report_date = t.c_end_date
             THEN edcs.new_sum
             ELSE null
        END)
    AS C_NEW_SUM
  , SUM(CASE WHEN ftrs.report_date = t.p_end_date
             THEN edcs.new_sum
             ELSE 0
        END)
    AS P_NEW_SUM
  , SUM(CASE WHEN ftrs.report_date = t.c_end_date
             THEN edcs.implemented_sum
             ELSE null
        END)
    AS C_IMPL_SUM
  , SUM(CASE WHEN ftrs.report_date = t.p_end_date
             THEN edcs.implemented_sum
             ELSE 0
        END)
    AS P_IMPL_SUM
  , SUM(CASE WHEN ftrs.report_date = t.c_end_date
             THEN edcs.cancelled_sum
             ELSE null
        END)
    AS C_CANL_SUM
  , SUM(CASE WHEN ftrs.report_date = t.p_end_date
             THEN edcs.cancelled_sum
             ELSE 0
        END)
    AS P_CANL_SUM
  , SUM(CASE WHEN ftrs.report_date = t.c_end_date
             THEN edcs.cycle_time_sum
             ELSE 0
        END)
    AS C_CYCL_SUM
  , SUM(CASE WHEN ftrs.report_date = t.p_end_date
             THEN edcs.cycle_time_sum
             ELSE 0
        END)
    AS P_CYCL_SUM
  , SUM(CASE WHEN ftrs.report_date = t.c_end_date
             THEN edcs.cycle_time_cnt
             ELSE 0
        END)
    AS C_CYCL_CNT
  , SUM(CASE WHEN ftrs.report_date = t.p_end_date
             THEN edcs.cycle_time_cnt
             ELSE 0
        END)
    AS P_CYCL_CNT
  FROM eni_dbi_co_sum_mv edcs
     , '|| l_from_clause ||
' WHERE '|| l_where_clause ||
' GROUP BY ' || l_group_by_clause||'
 ) s';

    eni_dbi_util_pkg.get_time_clauses(
                        'I',
                        'edcs',
                        l_period_type,
                        l_period_bitand,
                        l_as_of_date,
                        l_prev_as_of_date,
                        l_report_start,
                        l_cur_period,
                        l_days_into_period,
                        l_comp_type,
                        l_id_column,
                        l_from_clause,
                        l_where_clause,
                        l_group_by_clause,
   'ROLLING'
                        );

    l_sql_stmt := l_sql_stmt ||'
, (SELECT
     t.name,t.c_end_date AS time_id
   , SUM(CASE WHEN
         (NVL(edcs.cancellation_date, NVL(edcs.implementation_date,:NVL_DATE)
             ) >  t.c_end_date
         ) AND edcs.creation_date <= t.c_end_date
         THEN edcs.cnt ELSE null
         END) AS C_OPEN_SUM
   , SUM(CASE WHEN
         (NVL(edcs.cancellation_date, NVL(edcs.implementation_date,:NVL_DATE)
             ) >  t.p_end_date
         ) AND edcs.creation_date <= t.p_end_date
         THEN edcs.cnt ELSE 0
         END) AS P_OPEN_SUM
   , SUM(CASE WHEN
         NVL(edcs.cancellation_date,
             NVL(edcs.implementation_date,:NVL_DATE)
            ) >  t.c_end_date
         AND edcs.creation_date <= t.c_end_date
         THEN
         (CASE WHEN
          (LEAST(NVL(edcs.cancellation_date,
                     NVL(edcs.implementation_date,t.c_end_date)
                    ), t.c_end_date) - edcs.creation_date)
          BETWEEN 0 AND 1
          THEN edcs.CNT ELSE null END)
         ELSE null END)
     AS c_bucket1
   , SUM(CASE WHEN
         NVL(edcs.cancellation_date,
             NVL(edcs.implementation_date,:NVL_DATE)
            ) >  t.c_end_date
         AND edcs.creation_date <= t.c_end_date
         THEN
         (CASE WHEN
          (LEAST(NVL(edcs.cancellation_date,
                     NVL(edcs.implementation_date,t.c_end_date)
                    ), t.c_end_date) - edcs.creation_date)
          BETWEEN 2 AND 5
          THEN edcs.cnt ELSE null END)
         ELSE null END)
     AS c_bucket2
   , SUM(CASE WHEN
         NVL(edcs.cancellation_date,
             NVL(edcs.implementation_date,:NVL_DATE)
            ) >  t.c_end_date
         AND edcs.creation_date <= t.c_end_date
         THEN
         (CASE WHEN
          (LEAST(NVL(edcs.cancellation_date,
                     NVL(edcs.implementation_date,t.c_end_date)
                    ), t.c_end_date ) - edcs.creation_date)
          BETWEEN 6 and 10
          THEN edcs.cnt ELSE null END)
         ELSE null END)
     AS c_bucket3
   , SUM(CASE WHEN
         NVL(edcs.cancellation_date,
             NVL(edcs.implementation_date,:NVL_DATE)
            ) >  t.c_end_date
         AND edcs.creation_date <= t.c_end_date
         THEN
         (CASE WHEN
          (LEAST(NVL(edcs.cancellation_date,
                     NVL(edcs.implementation_date,t.c_end_date)
                    ), t.c_end_date) - edcs.creation_date)
          > 10
          THEN edcs.cnt ELSE null END)
         ELSE null END)
     AS c_bucket4
   , SUM(CASE WHEN
         NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          > t.c_end_date
          AND edcs.creation_date <= t.c_end_date
         THEN
         ((t.c_end_date - edcs.creation_date) * edcs.cnt)
         ELSE 0 END)
     AS c_avg_age
   , SUM(CASE WHEN
         NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          > t.p_end_date
          AND edcs.creation_date <= t.p_end_date
         THEN
         ((t.p_end_date - edcs.creation_date) * edcs.cnt)
         ELSE 0 END)
     AS p_avg_age
   FROM eni_dbi_co_dnum_mv edcs
      , '|| l_from_clause || '
   WHERE
    1 = 1
  AND
  edcs.creation_date <= &BIS_CURRENT_ASOF_DATE
  ' || l_where_clause_dn || '
   GROUP BY
    ' || l_group_by_clause || '
  ) c
WHERE
 s.time_id = c.time_id(+)
ORDER BY '||l_order_by;

  ELSIF ((l_view_by = 'ITEM+ENI_ITEM_ORG') OR(l_item IS NOT NULL  AND l_item <> 'All')) THEN -- non-time view-by

    l_where_clause :=  l_where_clause || l_item_where
                                      || l_org_where
                                      || l_status_where
                                      || l_priority_where
                                      || l_reason_where
                                      || l_type_where;


    IF l_view_by = 'ENI_CHANGE_MGMT_TYPE+ENI_CHANGE_MGMT_TYPE' THEN

      l_lookup :=  'eni_chg_mgmt_type_v ecmt';
      l_lookup_alias := 'ecmt';
      l_group_by := 'edcs.change_order_type_id';
      l_select  := 'ecmt.value';
      l_select_id := l_group_by;
      l_select_id_list := l_group_by || ' as viewby_id ';
      l_outer_join_condition:= 'dnum_sum.viewby_id = '|| l_lookup_alias || '.id(+)';
      l_description:=' null as ENI_MEASURE64 ';
      l_outer_group_by:= l_select ||' , viewby_id,'|| l_lookup_alias || '.id';

    ELSIF l_view_by = 'ENI_CHANGE_MGMT_STATUS+ENI_CHANGE_MGMT_STATUS' THEN

      l_lookup := 'eni_chg_mgmt_status_v ecms';
      l_lookup_alias := 'ecms';
      l_group_by := 'edcs.status_type';
      l_select := 'ecms.value';
      l_select_id := l_group_by;
      l_select_id_list := l_group_by || ' as viewby_id ';
      l_outer_join_condition:= 'dnum_sum.viewby_id = '|| l_lookup_alias || '.id(+)';
      l_description:=' null as ENI_MEASURE64 ';
      l_outer_group_by:= l_select ||' , viewby_id,'|| l_lookup_alias || '.id';


    ELSIF l_view_by = 'ENI_CHANGE_MGMT_REASON+ENI_CHANGE_MGMT_REASON' THEN

      l_lookup := 'eni_chg_mgmt_reason_v ecmr';
      l_lookup_alias := 'ecmr';
      l_group_by := 'edcs.reason_code';
      l_select := 'ecmr.value';
      l_select_id := l_group_by;
      l_select_id_list := l_group_by || ' as viewby_id ';
      l_outer_join_condition:= 'dnum_sum.viewby_id = '|| l_lookup_alias || '.id(+)';
      l_description:=' null as ENI_MEASURE64 ';
      l_outer_group_by:= l_select ||' , viewby_id,'|| l_lookup_alias || '.id';

    ELSIF l_view_by = 'ENI_CHANGE_MGMT_PRIORITY+ENI_CHANGE_MGMT_PRIORITY' THEN

      l_lookup := 'eni_chg_mgmt_priority_v ecmp';
      l_lookup_alias := 'ecmp';
      l_group_by := 'edcs.priority_code';
      l_select:=' ecmp.value ';
      l_select_id := l_group_by;
      l_select_id_list := l_group_by || ' as viewby_id ';
      l_outer_join_condition:= 'dnum_sum.viewby_id = '|| l_lookup_alias || '.id(+)';
      l_description:=' null as ENI_MEASURE64 ';
      l_outer_group_by:= l_select ||' , viewby_id,'|| l_lookup_alias || '.id';

    ELSIF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
 IF(l_item Is NULL  or l_item = 'All')
 THEN
  l_where_clause:=l_where_clause||' and edcs.organization_id(+) = ecmp.organization_id
        and edcs.item_id(+) = ecmp.inventory_item_id';
  l_where_clause_dn:=l_where_clause_dn||' and edcs.organization_id(+) = ecmp.organization_id
        and edcs.item_id(+) = ecmp.inventory_item_id';
  l_item_from_clause:=' , eni_item_org_v ecmp';
 END IF;
 l_lookup := 'eni_item_org_v ecmp';
 l_lookup_alias := 'ecmp';
 l_group_by := 'edcs.item_id,edcs.organization_id ';
 l_select := 'ecmp.value ';
 l_select_id := l_group_by;
 l_select_id_list := 'edcs.item_id  as viewby_id , edcs.organization_id as org_viewby_id ';
 l_outer_join_condition:='dnum_sum.viewby_id = ecmp.inventory_item_id(+) and
     dnum_sum.org_viewby_id = ecmp.organization_id(+) ';
        l_description:=' ecmp.description as ENI_MEASURE64 ';
 l_outer_group_by:= l_select ||' , viewby_id , ecmp.description ,'|| l_lookup_alias || '.id';

    END IF;

/*  adhachol :
 Bug : 3223904
   Modified the Grand Total calculation to do sum/cnt ..previously it was the respective
   sums/sums hence getting the wrong result
*/

  l_sql_stmt := '
SELECT ' || l_select || '
  AS VIEWBY
,  '||l_description||'
, '|| l_lookup_alias || '.id AS VIEWBYID
, SUM(c_open_sum) AS ENI_MEASURE1
, SUM(c_open_sum) AS ENI_MEASURE12
, SUM(p_open_sum) AS ENI_MEASURE6
, ((SUM(c_open_sum)-SUM(p_open_sum))
   /DECODE(SUM(p_open_sum),0,NULL,SUM(p_open_sum))
  ) * 100
  AS ENI_MEASURE2
, SUM(c_open_days_sum)
  /DECODE(SUM(c_open_sum),0,NULL,SUM(c_open_sum))
  AS ENI_MEASURE3
, SUM(p_open_days_sum)
  /DECODE(SUM(p_open_sum),0,NULL,SUM(p_open_sum))
  AS ENI_MEASURE7
, (((SUM(c_open_days_sum)
     /DECODE(SUM(c_open_sum),0,NULL,SUM(c_open_sum))
    )
    -(SUM(p_open_days_sum)/DECODE(SUM(p_open_sum),0,NULL,SUM(p_open_sum)))
   )
   /(DECODE(SUM(p_open_days_sum),0,NULL,SUM(p_open_days_sum))/DECODE(SUM(p_open_sum),0,NULL,SUM(p_open_sum)))
  ) * 100
  AS ENI_MEASURE4
, SUM(c_bucket1) AS ENI_MEASURE5
, SUM(c_bucket2) AS ENI_MEASURE40
, SUM(c_bucket3) AS ENI_MEASURE41
, SUM(c_bucket4) AS ENI_MEASURE42
, SUM(c_new_sum) AS ENI_MEASURE9
, SUM(c_new_sum) AS ENI_MEASURE13
, SUM(p_new_sum) AS ENI_MEASURE8
, ((SUM(c_new_sum)-SUM(p_new_sum))
   /DECODE(SUM(p_new_sum),0,NULL,SUM(p_new_sum))
  ) * 100
  AS ENI_MEASURE10
, SUM(c_cancelled_sum)   AS ENI_MEASURE14
, SUM(c_implemented_sum) AS ENI_MEASURE15
, SUM(p_cancelled_sum)   AS ENI_MEASURE27
, SUM(p_implemented_sum) AS ENI_MEASURE28
, (((NVL(SUM(c_cancelled_sum),0)+NVL(SUM(c_implemented_sum),0))
    -(NVL(SUM(p_cancelled_sum),0)+NVL(SUM(p_implemented_sum),0))
   )
   /DECODE(
    (NVL(SUM(p_cancelled_sum),0)
     +NVL(SUM(p_implemented_sum),0)),0,NULL,
     (NVL(SUM(p_cancelled_sum),0)+NVL(SUM(p_implemented_sum),0))
   )
  ) * 100
  AS ENI_MEASURE16
, SUM(c_cycle_time_sum)
  /DECODE(SUM(c_cycle_time_cnt),0,NULL,SUM(c_cycle_time_cnt))
  AS ENI_MEASURE17
, SUM(p_cycle_time_sum)
  /DECODE(SUM(p_cycle_time_cnt),0,NULL,SUM(p_cycle_time_cnt))
  AS ENI_MEASURE20
, (((SUM(c_cycle_time_sum)
     /DECODE(SUM(c_cycle_time_cnt),0,NULL,SUM(c_cycle_time_cnt))
    )
    -(SUM(p_cycle_time_sum)
      /DECODE(SUM(p_cycle_time_cnt),0,NULL,SUM(p_cycle_time_cnt))
     )
   )/(DECODE(SUM(p_cycle_time_sum),0,NULL,SUM(p_cycle_time_sum))
    /DECODE(SUM(p_cycle_time_cnt),0,NULL,SUM(p_cycle_time_cnt))
   )
  ) * 100
  AS ENI_MEASURE18
, NVL(SUM(c_cancelled_sum),0)+NVL(SUM(c_implemented_sum),0) AS ENI_MEASURE21
, SUM(SUM(c_open_sum)) OVER()
  AS ENI_MEASURE22
, (((SUM(SUM(c_open_sum)) OVER())-(SUM(SUM(p_open_sum)) OVER()))
   /DECODE(SUM(SUM(p_open_sum)) OVER(),0,NULL,SUM(SUM(p_open_sum)) OVER())
  ) * 100
  AS ENI_MEASURE23
, ((SUM(SUM(c_open_days_sum)) OVER())
   /DECODE(SUM(SUM(c_open_sum)) OVER(),0,NULL,SUM(SUM(c_open_sum)) OVER())
  )
  AS ENI_MEASURE24
, ((((SUM(SUM(c_open_days_sum)) OVER())
     /DECODE(SUM(SUM(c_open_sum)) OVER(),0,NULL,SUM(SUM(c_open_sum)) OVER()))
    -((SUM(SUM(p_open_days_sum)) OVER())
      /DECODE(SUM(SUM(p_open_sum)) OVER(),0,NULL,SUM(SUM(p_open_sum)) OVER()))
   )
   /DECODE(((SUM(SUM(p_open_days_sum)) OVER())
            /DECODE(SUM(SUM(p_open_sum)) OVER(),0,NULL,SUM(SUM(p_open_sum)) OVER()))
           ,0,NULL,
           ((SUM(SUM(p_open_days_sum)) OVER())
            /DECODE(SUM(SUM(p_open_sum)) OVER(),0,NULL,SUM(SUM(p_open_sum)) OVER()))
          )
  ) * 100
  AS ENI_MEASURE25
, SUM(SUM(c_bucket1)) OVER() as ENI_MEASURE26
, SUM(SUM(c_bucket2)) OVER() as ENI_MEASURE43
, SUM(SUM(c_bucket3)) OVER() as ENI_MEASURE44
, SUM(SUM(c_bucket4)) OVER() as ENI_MEASURE45
, SUM(SUM(c_new_sum)) OVER() as ENI_MEASURE30
, ((SUM(SUM(c_new_sum)) OVER()-SUM(SUM(p_new_sum)) OVER())
   /DECODE(SUM(SUM(p_new_sum)) OVER(),0,NULL,SUM(SUM(p_new_sum)) OVER())
  ) * 100
  AS ENI_MEASURE31
, SUM(SUM(c_cancelled_sum)) OVER() as ENI_MEASURE35
, SUM(SUM(c_implemented_sum)) OVER() as ENI_MEASURE36
, (((NVL(SUM(SUM(c_cancelled_sum)) OVER(),0)+NVL(SUM(SUM(c_implemented_sum)) OVER(),0))
    -(NVL(SUM(SUM(p_cancelled_sum)) OVER(),0)+NVL(SUM(SUM(p_implemented_sum)) OVER(),0))
   )
   /DECODE(
           (NVL(SUM(SUM(p_cancelled_sum)) OVER(),0)+NVL(SUM(SUM(p_implemented_sum)) OVER(),0)),0,NULL,
           (NVL(SUM(SUM(p_cancelled_sum)) OVER(),0)+NVL(SUM(SUM(p_implemented_sum)) OVER(),0))
          )
  ) * 100
  AS ENI_MEASURE37
, SUM(SUM(c_cycle_time_sum)) OVER()
  /DECODE(SUM(SUM(c_cycle_time_cnt)) OVER(),0,NULL,SUM(SUM(c_cycle_time_cnt)) OVER())
  AS ENI_MEASURE38
, (((SUM(SUM(c_cycle_time_sum)) OVER()
     /DECODE(SUM(SUM(c_cycle_time_cnt)) OVER(),0,NULL,SUM(SUM(c_cycle_time_cnt)) OVER())
    )
    -
    (
     SUM(SUM(p_cycle_time_sum)) OVER()
     /DECODE(SUM(SUM(p_cycle_time_cnt)) OVER(),0,NULL,SUM(SUM(p_cycle_time_cnt)) OVER())
    )
   )
   /DECODE(
     (SUM(SUM(p_cycle_time_sum)) OVER()
      /DECODE(SUM(SUM(p_cycle_time_cnt)) OVER(),0,NULL,SUM(SUM(p_cycle_time_cnt)) OVER())
     )
     ,0,NULL,
     (SUM(SUM(p_cycle_time_sum)) OVER()
      /DECODE(SUM(SUM(p_cycle_time_cnt)) OVER(),0,NULL,SUM(SUM(p_cycle_time_cnt)) OVER()))
    )
  ) * 100
  AS ENI_MEASURE39
, NULL AS ENI_MEASURE47
, NULL AS ENI_MEASURE48
, NULL AS ENI_MEASURE49
, NULL AS ENI_MEASURE50
, NULL AS ENI_MEASURE56
, NULL AS ENI_MEASURE57
, NULL AS ENI_MEASURE58
,(CASE WHEN SUM(c_open_sum) IS NULL
 OR SUM(c_open_sum)=0
 THEN NULL
 ELSE   '||l_open_url||' END) as ENI_MEASURE59
,(CASE WHEN SUM(c_new_sum) IS NULL
 OR SUM(c_new_sum)=0
 THEN NULL
 ELSE   '||l_new_url||' END) as ENI_MEASURE61
,(CASE WHEN SUM(c_implemented_sum) IS NULL
 OR SUM(c_implemented_sum)=0
 THEN NULL
 ELSE   '||l_impl_url||' END) as ENI_MEASURE62
,(CASE WHEN SUM(c_cancelled_sum) IS NULL
 OR SUM(c_cancelled_sum)=0
 THEN NULL
 ELSE   '||l_canc_url||' END) as ENI_MEASURE63
,(CASE WHEN SUM(c_open_sum) IS NULL
 OR SUM(c_open_sum)=0
 THEN NULL
 ELSE   '||l_avg_age_url||' END)  as ENI_MEASURE53
,(CASE WHEN SUM(c_implemented_sum) IS NULL
 OR SUM(c_implemented_sum)=0
 THEN NULL
 ELSE   '||l_cycle_url||' END) as ENI_MEASURE54
FROM
 ( SELECT '||l_select_id_list ||'
 , null c_open_sum
 , null p_open_sum
 , null c_open_days_sum
 , null p_open_days_sum
 , null c_bucket1
 , null c_bucket2
 , null c_bucket3
 , null c_bucket4
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
         THEN edcs.new_sum ELSE 0 END
   ) AS c_new_sum
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE
         THEN edcs.new_sum ELSE 0 END
   ) AS p_new_sum
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
         THEN edcs.cancelled_sum ELSE 0 END
   ) AS c_cancelled_sum
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE
         THEN edcs.cancelled_sum ELSE 0 END
   ) AS p_cancelled_sum
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
         THEN edcs.implemented_sum  ELSE 0 END
   ) AS c_implemented_sum
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE
         THEN edcs.implemented_sum ELSE 0 END
   ) AS p_implemented_sum
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
         THEN edcs.cycle_time_sum ELSE 0 END
   ) AS c_cycle_time_sum
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
         THEN edcs.cycle_time_cnt ELSE 0 END
   ) AS c_cycle_time_cnt
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE
         THEN edcs.cycle_time_sum ELSE 0 END
   ) AS p_cycle_time_sum
 , SUM(
    CASE WHEN ftrs.report_date = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE
         THEN edcs.cycle_time_cnt ELSE 0 END
   ) AS p_cycle_time_cnt
 FROM eni_dbi_co_sum_mv edcs
    , fii_time_structures ftrs'||l_item_from_clause||'
 WHERE
  edcs.time_id = ftrs.time_id
  AND edcs.period_type_id = ftrs.period_type_id
  AND(ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
      OR ftrs.report_Date = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE)
  AND BITAND(ftrs.record_type_id, :PERIODAND )=  :PERIODAND --Bug 5083876,5083652
  ' || l_where_clause || '
 GROUP BY
  ' || l_select_id || '
 UNION ALL
 SELECT '|| l_select_id_list || '
  , SUM(
     CASE WHEN '|| '&' ||'BIS_CURRENT_ASOF_DATE BETWEEN edcs.creation_date
               AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          THEN edcs.cnt ELSE 0 END
    ) AS c_open_sum
  , SUM(
     CASE WHEN '|| '&' ||'BIS_PREVIOUS_ASOF_DATE BETWEEN edcs.creation_date
               AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          THEN edcs.cnt ELSE 0 END
    ) AS p_open_sum
  , SUM(
     CASE WHEN '|| '&' ||'BIS_CURRENT_ASOF_DATE BETWEEN edcs.creation_date
               AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          THEN ('|| '&' ||'BIS_CURRENT_ASOF_DATE - edcs.creation_date ) * edcs.cnt
          ELSE 0 END
    ) AS c_open_days_sum
  , SUM(
     CASE WHEN '|| '&' ||'BIS_PREVIOUS_ASOF_DATE BETWEEN edcs.creation_date
               AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          THEN ('|| '&' ||'BIS_PREVIOUS_ASOF_DATE - edcs.creation_date ) * edcs.cnt
          ELSE 0 END
    ) AS p_open_days_sum
  , SUM(
     CASE WHEN '|| '&' ||'BIS_CURRENT_ASOF_DATE BETWEEN edcs.creation_date
               AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          THEN (CASE WHEN ('|| '&' ||'BIS_CURRENT_ASOF_DATE - edcs.creation_date)
                          BETWEEN 0 AND 1
                     THEN edcs.cnt ELSE 0 END
               )
          ELSE 0 END
    ) AS c_bucket1
  , SUM(
     CASE WHEN '|| '&' ||'BIS_CURRENT_ASOF_DATE BETWEEN edcs.creation_date
               AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          THEN (CASE WHEN ('|| '&' ||'BIS_CURRENT_ASOF_DATE - edcs.creation_date)
                          BETWEEN 2 AND 5
                     THEN edcs.cnt ELSE 0 END
               )
          ELSE 0 END
    ) AS c_bucket2
  , SUM(
     CASE WHEN '|| '&' ||'BIS_CURRENT_ASOF_DATE BETWEEN edcs.creation_date
               AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          THEN(CASE WHEN ('|| '&' ||'BIS_CURRENT_ASOF_DATE - edcs.creation_date)
                         BETWEEN 6 and 10
                    THEN edcs.cnt ELSE 0 END
              )
          ELSE 0 END
    ) AS c_bucket3
  , SUM(
     CASE WHEN '|| '&' ||'BIS_CURRENT_ASOF_DATE BETWEEN edcs.creation_date
               AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date),:NVL_DATE)
          THEN(CASE WHEN ('|| '&' ||'BIS_CURRENT_ASOF_DATE - edcs.creation_date) > 10
                    THEN edcs.cnt ELSE 0 END
              )
          ELSE 0 END
    ) AS c_bucket4
  , null c_new_sum
  , null p_new_sum
  , null c_cancelled_sum
  , null p_cancelled_sum
  , null c_implemented_sum
  , null p_implemented_sum
  , null c_cycle_time_sum
  , null c_cycle_time_cnt
  , null p_cycle_time_sum
  , null p_cycle_time_cnt
 FROM eni_dbi_co_dnum_mv edcs'||l_item_from_clause||'
 WHERE
  (('|| '&' ||'BIS_CURRENT_ASOF_DATE >= edcs.creation_date
   AND '|| '&' ||'BIS_CURRENT_ASOF_DATE < NVL(NVL(edcs.cancellation_date, edcs.implementation_date), 1 + '|| '&' ||'BIS_CURRENT_ASOF_DATE)
  )
  OR
  ('|| '&' ||'BIS_PREVIOUS_ASOF_DATE >= edcs.creation_date
   AND '|| '&' ||'BIS_PREVIOUS_ASOF_DATE < NVL(NVL(edcs.cancellation_date, edcs.implementation_date), 1 + '|| '&' ||'BIS_PREVIOUS_ASOF_DATE)
  )) ' || l_where_clause_dn || '
 GROUP BY
  ' || l_select_id || '
 ) dnum_sum
  , '|| l_lookup || '
 WHERE
  '||l_outer_join_condition||'
 GROUP BY '||l_outer_group_by||'
 ORDER BY ' || l_order_by;

/* achampan: for bug 3151655, I modified the login in the where clause directly above
    from BETWEEN edcs.creation_date AND NVL(NVL(edcs.cancellation_date, edcs.implementation_date), as_of_date)
    to   >= edcs.creation_date AND < NVL(NVL(edcs.cancellation_date, edcs.implementation_date), 1 + as_of_date)
   otherwise, the query counts an ECO that was closed on as_of_date as still open.
*/
  /* eletuchy: for bug 4099352, I changed the c_bucket1..4 logic to use edcs.cnt instead of 1
    otherwise, the query counts the rows of the denum view instead of the change orders those
    rows represent.
  */

  END IF;

  x_custom_sql := l_sql_stmt;


  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();
  x_custom_output.extend;
  l_custom_rec.attribute_name := ':STATUS_ID';
  l_custom_rec.attribute_value := REPLACE(l_status,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(1) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PRIORITY_ID';
  l_custom_rec.attribute_value := l_priority;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(2) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':TYPE_ID';
  l_custom_rec.attribute_value := REPLACE(l_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(3) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':REASON_ID';
  l_custom_rec.attribute_value := l_reason;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(4) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':NVL_DATE';
  l_custom_rec.attribute_value := '31/12/3000';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output(5) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':ITEM_ID';
  l_custom_rec.attribute_value := l_item;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(6) := l_custom_rec;

--Bug 5083876 - Start Code
  x_custom_output.extend;
  l_custom_rec.attribute_name := ':ORGANIZATION_ID';
  l_custom_rec.attribute_value := REPLACE(l_org,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(7) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODAND'; --Bug 5083652
  l_custom_rec.attribute_value := REPLACE(l_period_bitand,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(8) := l_custom_rec;
--Bug 5083876 - End Code

--Bug 5083652 -- Start Code
  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODTYPE';
  l_custom_rec.attribute_value := REPLACE(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(9) := l_custom_rec;

   x_custom_output.extend;
  l_custom_rec.attribute_name := ':COMPARETYPE';
  l_custom_rec.attribute_value := REPLACE(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(10) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(11) := l_custom_rec;

--Bug 5083652 -- End Code

EXCEPTION

  WHEN OTHERS THEN
  l_err_msg := SQLERRM;
    -- TODO: log this somewhere!
    NULL;
END GET_SQL;

END ENI_DBI_COR_PKG;

/
