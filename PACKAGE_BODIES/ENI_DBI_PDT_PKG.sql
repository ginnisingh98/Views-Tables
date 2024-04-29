--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PDT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PDT_PKG" AS
/*$Header: ENIPDTPB.pls 120.1 2006/03/23 04:40:45 pgopalar noship $*/
PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

l_custom_rec  BIS_QUERY_ATTRIBUTES;
l_period_type  VARCHAR2(1000);
l_period_bitand  NUMBER;
l_view_by  VARCHAR2(1000);
l_as_of_date  DATE;
l_prev_as_of_date DATE;
l_report_start  DATE;
l_cur_period  NUMBER;
l_days_into_period NUMBER;
l_comp_type  VARCHAR2(100);
l_category  VARCHAR2(100);
l_item   VARCHAR2(100);
l_org   VARCHAR2(100);
l_id_column  VARCHAR2(100);
l_order_by  VARCHAR2(1000);
l_drill   VARCHAR2(100);
l_status          VARCHAR2(100);
l_priority  VARCHAR2(100);
l_reason          VARCHAR2(100);
l_lifecycle_phase VARCHAR2(100);
l_currency  VARCHAR2(100);
l_bom_type  VARCHAR2(100);
l_type   VARCHAR2(100);
l_manager  VARCHAR2(100);
l_lob   VARCHAR2(1000);
l_org_where   VARCHAR2(400);
l_item_where  VARCHAR2(400);
l_priority_where VARCHAR2(400);
l_reason_where VARCHAR2(400);
l_type_where VARCHAR2(400);
l_status_where VARCHAR2(400);
l_open_url  VARCHAR2(400);
l_from_clause VARCHAR2(1000);
l_where_clause    VARCHAR2(1000);
l_group_by_clause VARCHAR2(1000);
l_outer_from  VARCHAR2(200);
l_outer_where VARCHAR2(1000);
l_order   VARCHAR2(20);

BEGIN

  x_custom_output := bis_query_attributes_tbl();

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

/* Bug: 3394222  Rolling Period Conversion. New requirements specific to 7.0 */

/* Bug Fix: 3380925
     Added ENI_MEASURE6,ENI_MEASURE7
     Reverted the calculation to (current_date - need_by_date)

*/

  eni_dbi_util_pkg.get_time_clauses
              (
                         'I',
    'pdo',
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


 IF  INSTR(l_order_by,' DESC') > 0 THEN
  l_order := ' DESC';
 ELSE
  l_order := ' ASC';
 END IF;

 l_outer_where := ' AND t.name = ftrs.name (+)
             AND t.start_date between  &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE ';

 l_open_url :='null';


 IF (l_priority IS NULL OR l_priority = '' OR l_priority = 'All')
 THEN
  l_priority_where:= '';
 ELSE
  l_priority_where := ' and pdo.priority_code = :PRIORITY';
 END IF;


 IF (l_type IS NULL OR l_type = '' OR l_type = 'All')
 THEN
  l_type_where := '';
 ELSE
  l_type_where := ' and pdo.change_order_type_id = :TYPE';
 END IF;


 IF (l_reason IS NULL OR l_reason = '' OR l_reason = 'All')
 THEN
  l_reason_where := '';
 ELSE
  l_reason_where := ' and pdo.reason_code  = :REASON';
 END IF;


 IF (l_status IS NULL OR l_status = '' OR l_status = 'All')
 THEN
  l_status_where := '';
 ELSE
  l_status_where := ' and pdo.status_type  = :STATUS';
 END IF;


 IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
 THEN
  l_org_where := '';
 ELSE
  l_org_where := ' AND pdo.organization_id = :ORG';
 END IF;


 IF (l_item IS NULL OR l_item = '' OR l_item = 'All')
 THEN
   X_CUSTOM_SQL:='
    SELECT NULL AS VIEWBY,
     NULL AS ENI_MEASURE1,
     NULL AS ENI_MEASURE9,
     NULL AS       ENI_MEASURE10,
     NULL AS ENI_MEASURE3,
     NULL AS      ENI_MEASURE6,
     NULL AS      ENI_MEASURE7,
     NULL AS ENI_MEASURE11,
     NULL AS ENI_MEASURE31,
     NULL AS ENI_MEASURE32,
     NULL AS ENI_MEASURE33,
     NULL AS ENI_MEASURE34,
     NULL AS ENI_MEASURE41,
     NULL AS ENI_MEASURE42,
     NULL AS ENI_MEASURE43,
     NULL AS ENI_MEASURE44,
     NULL AS   ENI_MEASURE36
    FROM DUAL';
    RETURN;
 ELSE
  l_item_where := ' AND pdo.item_id = :ITEM';
 END IF;

 x_custom_sql := '
  select t.name as VIEWBY
    ,curr_open_cnt as ENI_MEASURE1
    ,prev_open_cnt as ENI_MEASURE9
    ,NVL(curr_open_cnt,0) as ENI_MEASURE10
    ,curr_open_days_cnt/DECODE(curr_open_cnt,0,NULL,curr_open_cnt) as ENI_MEASURE3
    ,prev_open_days_cnt/DECODE(prev_open_cnt,0,NULL,prev_open_cnt) as ENI_MEASURE11
    ,curr_past_open_days_cnt/DECODE(curr_open_cnt,0,NULL,curr_open_cnt) as ENI_MEASURE6
    ,prev_past_open_days_cnt/DECODE(prev_open_cnt,0,NULL,prev_open_cnt) as ENI_MEASURE7
    ,avg1_cnt as ENI_MEASURE31
    ,avg2_cnt as ENI_MEASURE32
    ,avg3_cnt as ENI_MEASURE33
    ,avg4_cnt as ENI_MEASURE34
    ,NULL AS ENI_MEASURE41
    ,NULL AS ENI_MEASURE42
    ,NULL AS ENI_MEASURE43
    ,NULL AS ENI_MEASURE44
    ,NULL as ENI_MEASURE36
from
(
 SELECT t.name,
   t.start_date,
   t.c_end_date,
 SUM(
     case
  When pdo.creation_date <= t.c_end_date
       AND pdo.need_by_date < t.c_end_date
        AND (NVL(IMPLEMENTATION_DATE,
                 NVL(CANCELLATION_DATE,t.c_end_date+1))) > t.c_end_date
  Then pdo.cnt
  Else NULL
  end
    ) curr_open_cnt,
 SUM(
   case
   When pdo.creation_date <= t.p_end_date
    AND pdo.need_by_date < t.p_end_date
      AND (NVL(IMPLEMENTATION_DATE,
           NVL(CANCELLATION_DATE,t.p_end_date+1))) > t.p_end_date
  Then pdo.cnt
  Else NULL
  End
    ) prev_open_cnt,
 SUM(
  case
  When pdo.creation_date <= t.c_end_date
       AND pdo.need_by_date < t.c_end_date
        AND (NVL(IMPLEMENTATION_DATE,
                 NVL(CANCELLATION_DATE,t.c_end_date+1))) > t.c_end_date
  Then ((t.c_end_date - pdo.creation_date)*pdo.cnt)
  Else NULL
  end
    ) curr_open_days_cnt,
 SUM(
  case
   When pdo.creation_date <= t.p_end_date
    AND pdo.need_by_date < t.p_end_date
      AND (NVL(IMPLEMENTATION_DATE,
           NVL(CANCELLATION_DATE,t.p_end_date+1))) > t.p_end_date
  Then ((t.p_end_date-pdo.creation_date)*pdo.cnt)
  Else NULL
  End
    ) prev_open_days_cnt,
 SUM(
  case
  When pdo.creation_date <= t.c_end_date
       AND pdo.need_by_date < t.c_end_date
        AND (NVL(IMPLEMENTATION_DATE,
                 NVL(CANCELLATION_DATE,t.c_end_date+1))) > t.c_end_date
  Then ((t.c_end_date -pdo.need_by_date)*pdo.cnt)
  Else NULL
  end
    ) curr_past_open_days_cnt,
 SUM(
  case
   When pdo.creation_date <= t.p_end_date
    AND pdo.need_by_date < t.p_end_date
      AND (NVL(IMPLEMENTATION_DATE,
           NVL(CANCELLATION_DATE,t.p_end_date+1))) > t.p_end_date
  Then ((t.p_end_date-pdo.need_by_date)*pdo.cnt)
  Else NULL
  End
    ) prev_past_open_days_cnt,
 SUM(
     case
  When pdo.creation_date <= t.c_end_date
       AND pdo.need_by_date < t.c_end_date
        AND (NVL(IMPLEMENTATION_DATE,
                 NVL(CANCELLATION_DATE,t.c_end_date+1))) > t.c_end_date
    AND (t.c_end_date-pdo.need_by_date) between 0 and 1
  Then pdo.cnt
  Else NULL
  end
    ) avg1_cnt,
 SUM(
     case
  When pdo.creation_date <= t.c_end_date
       AND pdo.need_by_date < t.c_end_date
        AND (NVL(IMPLEMENTATION_DATE,
                 NVL(CANCELLATION_DATE,t.c_end_date+1))) > t.c_end_date
    AND (t.c_end_date-pdo.need_by_date)  between 2 and 5
  Then pdo.cnt
  Else NULL
  end
    ) avg2_cnt,
 SUM(
     case
  When pdo.creation_date <= t.c_end_date
       AND pdo.need_by_date < t.c_end_date
        AND (NVL(IMPLEMENTATION_DATE,
                 NVL(CANCELLATION_DATE,t.c_end_date+1))) > t.c_end_date
    AND (t.c_end_date-pdo.need_by_date)  between 6 and 10
  Then pdo.cnt
  Else NULL
  end
    ) avg3_cnt,
 SUM(
     case
  When pdo.creation_date <= t.c_end_date
       AND pdo.need_by_date < t.c_end_date
        AND (NVL(IMPLEMENTATION_DATE,
                 NVL(CANCELLATION_DATE,t.c_end_date+1))) > t.c_end_date
    AND (t.c_end_date-pdo.need_by_date)  > 10
  Then pdo.cnt
  Else NULL
  end
    ) avg4_cnt

 FROM
  eni_dbi_co_dnum_mv pdo,' ||
  l_from_clause || '
 WHERE
      pdo.creation_date <= &BIS_CURRENT_ASOF_DATE
  AND pdo.need_by_date is not null' ||
      l_item_where ||
      l_priority_where ||
      l_type_where ||
      l_reason_where ||
      l_status_where ||
      l_org_where || '
 GROUP BY
    ' || l_group_by_clause || '
)ftrs,' || l_from_clause || '
WHERE
1 = 1
and t.name = ftrs.name(+)
ORDER BY  t.start_date' || l_order;




 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
 x_custom_output := bis_query_attributes_tbl();

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ITEM';
 l_custom_rec.attribute_value := l_item;
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(1) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ORG';
 l_custom_rec.attribute_value := replace(l_org,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
 x_custom_output(2) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':REASON';
 l_custom_rec.attribute_value := l_reason;
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(3) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':PRIORITY';
 l_custom_rec.attribute_value := l_priority;
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(4) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':TYPE';
 l_custom_rec.attribute_value := replace(l_type,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(5) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':STATUS';
 l_custom_rec.attribute_value := replace(l_status,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(6) := l_custom_rec;

 --Bug 5083652 -- Start Code

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODTYPE';
  l_custom_rec.attribute_value := REPLACE(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(7) := l_custom_rec;

   x_custom_output.extend;
  l_custom_rec.attribute_name := ':COMPARETYPE';
  l_custom_rec.attribute_value := REPLACE(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(8) := l_custom_rec;


  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODAND';
  l_custom_rec.attribute_value := REPLACE(l_period_bitand,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(9) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(10) := l_custom_rec;

--Bug 5083652 -- End Code

END GET_SQL;

END ENI_DBI_PDT_PKG;

/
