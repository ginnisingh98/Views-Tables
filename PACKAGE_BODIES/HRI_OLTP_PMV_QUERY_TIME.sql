--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_QUERY_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_QUERY_TIME" AS
/* $Header: hriopqtm.pkb 120.1 2005/11/22 03:22:40 cbridge noship $ */
/*----------------------------------------------------------------------------*/
/* Procedure generates the in-line view of periods, utilized by the DBI trend
/* reports.  All Variables are passed by the AK SQL,
/*----------------------------------------------------------------------------*/

PROCEDURE GET_TIME_CLAUSE(
   p_projection_type     VARCHAR2 DEFAULT 'N'
  ,p_page_period_type    VARCHAR2
  ,p_page_comp_type      VARCHAR2
  ,o_trend_table         OUT NOCOPY VARCHAR2
  ,o_previous_periods    OUT NOCOPY VARCHAR2
  ,o_projection_periods  OUT NOCOPY VARCHAR2
  )
IS

BEGIN

   -- projection support is required for Budgeting report
  IF (p_projection_type = 'Y') THEN

   IF (p_page_period_type = 'FII_ROLLING_YEAR') THEN
   -- 5 periods ( 3 previous, current, 1 projected)
      o_previous_periods   := 4;
      o_projection_periods := 1;
   --
     ELSIF (p_page_period_type = 'FII_ROLLING_QTR') THEN
     -- 7 peiods ( 3 (4) previous, current, 3 projected)
       o_previous_periods   := 7;
       o_projection_periods := 3;
     ELSIF (p_page_period_type = 'FII_ROLLING_MONTH') THEN
     -- 12 periods (6 previous, current, 5 projected)
       o_previous_periods   := 11;
       o_projection_periods := 3;
     --
     ELSIF (p_page_period_type = 'FII_ROLLING_WEEK') THEN
     -- 13 seven day periods (12 previous, current, 6 projected)
       o_previous_periods   :=12;
       o_projection_periods :=4;
     --
   ELSE
      --
      o_previous_periods   :=0;
      o_projection_periods :=0;
      --
   END IF;
   --

    -- add a projection amount (days) to the offsets
    --Template Query
    --Frist Select returns previous and current periods.
    -- Second Select return's projected periods
    o_trend_table :=
      '   (SELECT
          TO_CHAR (' || '&' || 'BIS_CURRENT_ASOF_DATE + tro.offset, '''|| 'dd-Mon-YYYY' ||''')
                                                                value
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE + tro.offset       period_as_of_date
         ,' || '&' || 'BIS_PREVIOUS_ASOF_DATE + tro.offset      prev_period_as_of_date
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE + (tro.offset + tro.start_date_offset)
                                                                period_start_date
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE + tro.offset       period_end_date
         ,tro.period_number                                     period_number
         ,-tro.period_number                                     period_order
        FROM
          fii_time_rolling_offsets tro
        WHERE
            tro.period_type = :TIME_PERIOD_TYPE
        AND tro.comparison_type = :TIME_COMPARISON_TYPE
        AND tro.period_number <= :TIME_PERIOD_NUMBER
        UNION ALL
       SELECT
          TO_CHAR (' || '&' || 'BIS_CURRENT_ASOF_DATE - tro.offset, '''|| 'dd-Mon-YYYY' ||''')
                                                                value
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE - tro.offset       period_as_of_date
         ,' || '&' || 'BIS_PREVIOUS_ASOF_DATE - tro.offset      prev_period_as_of_date
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE - (tro.offset - tro.start_date_offset)
                                                                period_start_date
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE - tro.offset       period_end_date
         ,tro.period_number                                     period_number
         ,tro.period_number                                     period_order
        FROM
           fii_time_rolling_offsets tro
        WHERE
             tro.period_type = :TIME_PROJECT_PERIOD_TYPE
        AND tro.comparison_type = :TIME_PROJECT_COMPARISON_TYPE
        AND tro.period_number <= :TIME_PROJECT_PERIOD_NUMBER
        AND tro.period_number <> 0
       )
        ';
  ELSE -- not a projection type trend.
      IF (p_page_period_type = 'FII_ROLLING_YEAR') THEN
    -- 5 periods ( 3 previous, current, 0 projected)
      o_previous_periods   := 3;
    --
      ELSIF (p_page_period_type = 'FII_ROLLING_QTR') THEN
      --
        IF (p_page_comp_type = 'SEQUENTIAL') THEN
        -- 8 periods (7 previous, current, 0 projected)
           o_previous_periods   := 7;
        --
          ELSIF  (p_page_comp_type = 'YEARLY') THEN
        -- 8 periods (3 previous, current, 0 projected)           -
           o_previous_periods   := 3;
        --
        END If;
      --
      ELSIF (p_page_period_type = 'FII_ROLLING_MONTH') THEN
      -- 12 periods (6 previous, current, 0 projected)
         o_previous_periods   := 11;
      --
      ELSIF (p_page_period_type = 'FII_ROLLING_WEEK') THEN
      -- 13 seven day periods (6 previous, current, 0 projected)
         o_previous_periods   := 12;
      --
      ELSE
        o_previous_periods   := 0;
  END IF;
    -- offsets table without projection periods (default)
      o_trend_table :=
      '   (SELECT
          TO_CHAR (' || '&' || 'BIS_CURRENT_ASOF_DATE + tro.offset, '''|| 'dd-Mon-YYYY' ||''')
                                                                value
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE + tro.offset       period_as_of_date
         ,' || '&' || 'BIS_PREVIOUS_ASOF_DATE + tro.offset      prev_period_as_of_date
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE + (tro.offset + tro.start_date_offset)
                                                                period_start_date
         ,' || '&' || 'BIS_CURRENT_ASOF_DATE + tro.offset       period_end_date
         ,tro.period_number                                     period_number
         ,-tro.period_number                                     period_order
        FROM
          fii_time_rolling_offsets tro
        WHERE
            tro.period_type = :TIME_PERIOD_TYPE
        AND tro.comparison_type = :TIME_COMPARISON_TYPE
        AND tro.period_number <= :TIME_PERIOD_NUMBER
        )
     ';
  END IF;

END GET_TIME_CLAUSE ; -- GET_TIME_CLAUSE PROCEDURE

--
-- -------------------------------------------------------------------------
-- Get the trend periods only
-- -------------------------------------------------------------------------
--
FUNCTION get_time_clause(p_past_trend   IN VARCHAR2 DEFAULT 'Y',
                         p_future_trend IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2 IS
  --
  l_past_trend_sql   VARCHAR2(1000);
  l_future_trend_sql VARCHAR2(1000);
  l_trend_sql        VARCHAR2(1000);
  --
BEGIN
  --
  l_past_trend_sql :=
'SELECT /*+ NOPARALLEL(toff) */
 TO_CHAR(&BIS_CURRENT_ASOF_DATE + offset, '''|| 'dd-Mon-YYYY' ||''') value
,&BIS_CURRENT_ASOF_DATE + offset period_as_of_date
,&BIS_PREVIOUS_ASOF_DATE + offset prev_period_as_of_date
,&BIS_CURRENT_ASOF_DATE + (offset + start_date_offset) period_start_date
,&BIS_CURRENT_ASOF_DATE + offset period_end_date
,period_number period_number
,-period_number period_order
FROM
 fii_time_rolling_offsets toff
WHERE period_type = :TIME_PERIOD_TYPE
AND comparison_type = :TIME_COMPARISON_TYPE
AND period_number <= :TIME_PERIOD_NUMBER';
  --
  l_future_trend_sql :=
'SELECT
 TO_CHAR(&BIS_CURRENT_ASOF_DATE - offset, '''|| 'dd-Mon-YYYY' ||''') value
,&BIS_CURRENT_ASOF_DATE - offset period_as_of_date
,&BIS_PREVIOUS_ASOF_DATE - offset prev_period_as_of_date
,&BIS_CURRENT_ASOF_DATE - (offset - start_date_offset) period_start_date
,&BIS_CURRENT_ASOF_DATE - offset period_end_date
,period_number period_number
,period_number period_order
FROM fii_time_rolling_offsets
WHERE period_type = :TIME_PROJECT_PERIOD_TYPE
AND comparison_type = :TIME_PROJECT_COMPARISON_TYPE
AND period_number <= :TIME_PROJECT_PERIOD_NUMBER
AND period_number <> 0';
  --
  IF p_past_trend = 'Y' THEN
    --
    l_trend_sql := l_past_trend_sql;
    --
    IF p_future_trend = 'Y' THEN
      --
      l_trend_sql :=
 l_trend_sql ||'
UNION ALL
' || l_future_trend_sql;
      --
    END IF;
    --
  ELSIF p_future_trend = 'Y' THEN
    --
    l_trend_sql := l_future_trend_sql;
    --
  END IF;
  --
  RETURN l_trend_sql;
  --
END get_time_clause;

PROCEDURE get_period_binds
          (p_projection_type     VARCHAR2 DEFAULT 'N'
          ,p_page_period_type    VARCHAR2
          ,p_page_comp_type      VARCHAR2
          ,o_previous_periods    OUT NOCOPY NUMBER
          ,o_projection_periods  OUT NOCOPY NUMBER) IS

BEGIN

   -- projection support is required for Budgeting report
  IF (p_projection_type = 'Y') THEN

   IF (p_page_period_type = 'FII_ROLLING_YEAR') THEN
   -- 5 periods ( 3 previous, current, 1 projected)
      o_previous_periods   := 4;
      o_projection_periods := 1;
   --
     ELSIF (p_page_period_type = 'FII_ROLLING_QTR') THEN
     -- 7 peiods ( 3 (4) previous, current, 3 projected)
       o_previous_periods   := 7;
       o_projection_periods := 3;
     ELSIF (p_page_period_type = 'FII_ROLLING_MONTH') THEN
     -- 12 periods (6 previous, current, 5 projected)
       o_previous_periods   := 11;
       o_projection_periods := 3;
     --
     ELSIF (p_page_period_type = 'FII_ROLLING_WEEK') THEN
     -- 13 seven day periods (12 previous, current, 6 projected)
       o_previous_periods   :=12;
       o_projection_periods :=4;
     --
   ELSE
      --
      o_previous_periods   :=0;
      o_projection_periods :=0;
      --
   END IF;
   --

  ELSE -- not a projection type trend.
      IF (p_page_period_type = 'FII_ROLLING_YEAR') THEN
    -- 4 periods ( 3 previous, current, 0 projected)
      o_previous_periods   := 3;
    --
      ELSIF (p_page_period_type = 'FII_ROLLING_QTR') THEN
      --
        IF (p_page_comp_type = 'SEQUENTIAL') THEN
        -- 8 periods (7 previous, current, 0 projected)
           o_previous_periods   := 7;
        --
          ELSIF  (p_page_comp_type = 'YEARLY') THEN
        -- 4 periods (3 previous, current, 0 projected)           -
           o_previous_periods   := 3;
        --
        END If;
      --
      ELSIF (p_page_period_type = 'FII_ROLLING_MONTH') THEN
      -- 12 periods (11 previous, current, 0 projected)
         o_previous_periods   := 11;
      --
      ELSIF (p_page_period_type = 'FII_ROLLING_WEEK') THEN
      -- 13 seven day periods (12 previous, current, 0 projected)
         o_previous_periods   := 12;
      --
      ELSE
        o_previous_periods   := 0;
      END IF;
  END IF;

END get_period_binds;

END HRI_OLTP_PMV_QUERY_TIME;


/
