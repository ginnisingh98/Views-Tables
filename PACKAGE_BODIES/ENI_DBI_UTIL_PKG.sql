--------------------------------------------------------
--  DDL for Package Body ENI_DBI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_UTIL_PKG" AS
/*$Header: ENIUTILB.pls 120.1.12010000.2 2010/02/18 12:52:34 nendrapu ship $*/

  -- Following are global variables used to cache full/xtd translated
  -- string for period types.

  G_YTD_Label VARCHAR2(8);
  G_QTD_Label VARCHAR2(8);
  G_MTD_Label VARCHAR2(8);
  G_WTD_Label VARCHAR2(8);

  -- Global variables for primary and secondary currency

  g_curr_prim     CONSTANT FII_CURRENCIES_V.ID%TYPE := '''FII_GLOBAL1''';
  g_curr_sec      CONSTANT FII_CURRENCIES_V.ID%TYPE := '''FII_GLOBAL2''';


/* ------------------------------------------------------
   Function : GetXTDLabel
   The function returns YTD/QTD/PTD. This function is called
   from the PMV report and relies on cached values of variables
   called in the package init section.
   ------------------------------------------------------*/
-- Function GetXTDLabel Follows
  FUNCTION GetXTDLabel( p_page_parameter_tbl    IN BIS_PMV_PAGE_PARAMETER_TBL)
    RETURN VARCHAR2
    IS
      l_Time_Level_Value VARCHAR2(80);
      l_Label VARCHAR2(8);
    BEGIN

      G_YTD_Label :='YTD';
      G_QTD_Label :='QTD';
      G_MTD_Label :='MTD';
      G_WTD_Label :='WTD';

      FOR i IN 1..p_page_parameter_tbl.COUNT
      LOOP
        IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
          l_Time_Level_Value:=p_page_parameter_tbl(i).parameter_value;
        END IF;
      END LOOP;

      IF l_time_level_value IS NOT NULL THEN
        CASE (l_time_level_value)
          WHEN 'FII_TIME_ENT_YEAR' THEN
            l_Label:=G_YTD_Label;
          WHEN 'FII_TIME_ENT_QTR' THEN
            l_Label:=G_QTD_Label;
          WHEN 'FII_TIME_ENT_PERIOD' THEN
            l_Label:=G_MTD_Label;
          WHEN 'FII_TIME_WEEK' THEN
            l_Label:=G_WTD_Label;
        END CASE;


      ELSE
        l_Label:='';
      END IF;

      RETURN l_Label;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;

  END GetXTDLabel;





/* ------------------------------------------------------
   Added for BUG # 3394203
   Function : Rolling_Lab
   The function returns Rolling 7/30/90/365 Days. This function is called
   from the PMV report and relies on cached values of variables
   called in the package init section.
   ------------------------------------------------------*/
-- Function GetXTDLabel Follows
  FUNCTION Rolling_Lab( p_page_parameter_tbl    IN BIS_PMV_PAGE_PARAMETER_TBL)
    RETURN VARCHAR2
    IS
      l_Time_Level_Value VARCHAR2(80);
      l_Label VARCHAR2(50);
    BEGIN

      FOR i IN 1..p_page_parameter_tbl.COUNT
      LOOP
        IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
          l_Time_Level_Value:=p_page_parameter_tbl(i).parameter_value;
        END IF;
      END LOOP;

      IF l_time_level_value IS NOT NULL THEN
        CASE (l_time_level_value)
        WHEN 'FII_ROLLING_WEEK' THEN
          l_Label:='7 Days';
        WHEN 'FII_ROLLING_MONTH' THEN
          l_Label:='30 Days';
        WHEN 'FII_ROLLING_QTR' THEN
          l_Label:='90 Days';
        WHEN 'FII_ROLLING_YEAR' THEN
          l_Label:='365 Days';
        END CASE;

      ELSE
        l_Label:='';
      END IF;

      RETURN l_Label;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;

  END Rolling_Lab;


-- Use p_measure_type = 'A' for aggregate measures and 'I' for instantaneous measures

  PROCEDURE get_time_clauses
    ( p_measure_type IN VARCHAR2,
      p_summary_alias in VARCHAR2,
      p_period_type IN VARCHAR2,
      p_period_bitand IN NUMBER,
      p_as_of_date  IN DATE,
      p_prev_as_of_date IN DATE,
      p_report_start IN DATE,
      p_cur_period IN NUMBER,
      p_days_into_period IN NUMBER,
      p_comp_type IN VARCHAR2,
      p_id_column IN VARCHAR2,
      p_from_clause OUT NOCOPY VARCHAR2,
      p_where_clause OUT NOCOPY VARCHAR2,
      p_group_by_clause OUT NOCOPY VARCHAR2,
      p_rolling IN VARCHAR2 DEFAULT 'ENTERPRISE' -- Added for Bug 3394203 for conversion to rolling periods.
    )
    IS

      l_comp_where VARCHAR2(100);
      l_err_msg    VARCHAR2(100);
      l_time_table VARCHAR2(20);
      l_id_column VARCHAR2(30);
      l_common_clause VARCHAR2(4000);
      l_offset_factor NUMBER;
      l_num_rows NUMBER;
      l_period_type_id NUMBER;
      l_comp_type VARCHAR2(50);
      l_period_type VARCHAR2(50);

    BEGIN

      IF (p_rolling = 'ROLLING') THEN

        l_period_type := '''' || p_period_type || '''';
        l_comp_type := '''' || p_comp_type || '''';

        -- Returning the SQL for Rolling Periods.

        l_common_clause :=
          '(select
                 TO_CHAR('|| '&' || 'BIS_CURRENT_ASOF_DATE + offset , ''dd-Mon-yyyy'')
              AS name,
                 ' || '&' || 'BIS_CURRENT_ASOF_DATE + offset + start_date_offset
              AS start_date,
                 ' || '&' || 'BIS_CURRENT_ASOF_DATE + offset AS c_end_date,
                 ' || '&' || 'BIS_PREVIOUS_ASOF_DATE + offset AS p_end_date
           from fii_time_rolling_offsets
           where period_type = :PERIODTYPE --Bug 5083652
                  AND comparison_type = :COMPARETYPE )t'; --Bug 5083652

        IF p_measure_type = 'A' THEN
          -- aggregate measures
          p_from_clause :=  '
                  '|| l_common_clause ||', fii_time_structures ftrs';
          p_where_clause := ' bitand(ftrs.record_type_id,:PERIODAND) = :PERIODAND --Bug 5083652
            AND (t.c_end_date = ftrs.report_date OR t.p_end_date = ftrs.report_date)
            AND '|| p_summary_alias ||'.time_id (+) = ftrs.time_id
            AND '||p_summary_alias||'.period_type_id (+) = ftrs.period_type_id';
          p_group_by_clause :=   '
            t.name,
            t.start_date,
            t.c_end_date ';

        ELSE
          -- instantaneous measures
          p_from_clause := l_common_clause;
          p_where_clause :=  ' 1 = 1 ';
          p_group_by_clause := '
          t.name,
          t.start_date,
          t.c_end_date ';
        END IF;

      ELSE

        -- Returning the SQL for Enterprise Periods.

        IF p_comp_type = 'SEQUENTIAL' THEN
          l_comp_where := 'AND c.start_date = p.end_date + 1';
        ELSIF p_period_type = 'FII_TIME_WEEK' THEN
          l_comp_where := 'AND c.week_id = p.week_id + 10000';
        ELSIF p_period_type = 'FII_TIME_ENT_PERIOD' THEN
          l_comp_where := 'AND c.ent_period_id = p.ent_period_id + 1000';
        ELSIF p_period_type = 'FII_TIME_ENT_QTR' THEN
          l_comp_where := 'AND c.ent_qtr_id = p.ent_qtr_id + 10';
        ELSIF p_period_type = 'FII_TIME_ENT_YEAR' THEN
          l_comp_where := 'AND c.ent_year_id = p.ent_year_id + 1';
        END IF;

        -- aggregate measures
        IF p_measure_type = 'A' THEN

          p_from_clause :=  '
      fii_time_rpt_struct ftrs,
      (
       SELECT
        c.name,
        c.'||p_id_column||',
        c.start_date AS start_date,
        (case when  '|| '&' || 'BIS_CURRENT_ASOF_DATE < c.end_date
        then  '|| '&' || 'BIS_CURRENT_ASOF_DATE else c.end_date end ) AS c_end_date,
        (case when  '|| '&' || 'BIS_PREVIOUS_ASOF_DATE < p.end_date
        then  '|| '&' || 'BIS_PREVIOUS_ASOF_DATE else p.end_date end ) AS p_end_date
       FROM
        ' || p_period_type ||' c, ' || p_period_type || ' p
       WHERE
        c.start_date >= ' || '&' || 'BIS_CURRENT_REPORT_START_DATE
        AND c.'||p_id_column||' <= :CUR_PERIOD_ID --Bug 5083652
        AND p.start_date >= ' || '&' || 'BIS_PREVIOUS_REPORT_START_DATE
        ' || l_comp_where || '
      ) t';

          p_where_clause := '
         (t.c_end_date = ftrs.report_date OR t.p_end_date = ftrs.report_date)
      AND '|| p_summary_alias ||'.time_id (+) = ftrs.time_id
      AND '||p_summary_alias||'.period_type_id (+) = ftrs.period_type_id
      AND BITAND(ftrs.record_type_id, :PERIODAND) = ftrs.record_type_id'; --Bug 5083652

          p_group_by_clause :=   '
      t.name,
      t.start_date,
      t.c_end_date
     ';

        -- instantaneous measures
        ELSE
          p_from_clause := '
        (
       SELECT
        c.name,
        c.'||p_id_column||',
        c.start_date AS start_date,
        (case when  '|| '&' || 'BIS_CURRENT_ASOF_DATE < c.end_date
        then  '|| '&' || 'BIS_CURRENT_ASOF_DATE else c.end_date end ) AS c_end_date,
        (case when  '|| '&' || 'BIS_PREVIOUS_ASOF_DATE < p.end_date
        then  '|| '&' || 'BIS_PREVIOUS_ASOF_DATE else p.end_date end ) AS p_end_date
       FROM
        ' || p_period_type ||' c, ' || p_period_type || ' p
       WHERE
        c.start_date >= ' || '&' || 'BIS_CURRENT_REPORT_START_DATE
        AND c.'||p_id_column||' <= :CUR_PERIOD_ID --Bug 5083652
        AND p.start_date >= ' || '&' || 'BIS_PREVIOUS_REPORT_START_DATE
        ' || l_comp_where || '
     ) t';

          p_where_clause :=  ' 1 = 1 ';

          p_group_by_clause := '
      t.name,
      t.start_date,
      t.c_end_date ';

        END IF;
      END IF;

    EXCEPTION

      WHEN OTHERS THEN
        NULL;

  END get_time_clauses;


/*
  Modified Date  :  May-28-2003
  Description    :  modified to include the parameters of product management engineering report

*/
  PROCEDURE get_parameters
    ( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
      p_period_type          OUT NOCOPY VARCHAR2,
      p_period_bitand        OUT NOCOPY NUMBER,
      p_view_by              OUT NOCOPY VARCHAR2,
      p_as_of_date           OUT NOCOPY DATE,
      p_prev_as_of_date      OUT NOCOPY DATE,
      p_report_start         OUT NOCOPY DATE,
      p_cur_period           OUT NOCOPY NUMBER,
      p_days_into_period     OUT NOCOPY NUMBER,
      p_comp_type            OUT NOCOPY VARCHAR2,
      p_category             OUT NOCOPY VARCHAR2,
      p_item                 OUT NOCOPY VARCHAR2,
      p_org                  OUT NOCOPY VARCHAR2,
      p_id_column            OUT NOCOPY VARCHAR2,
      p_order_by             OUT NOCOPY VARCHAR2,
      p_drill                OUT NOCOPY VARCHAR2,
      p_status   OUT NOCOPY VARCHAR2,
      p_priority   OUT NOCOPY VARCHAR2,
      p_reason   OUT NOCOPY VARCHAR2,
      p_lifecycle_phase  OUT NOCOPY VARCHAR2,
      p_currency   OUT NOCOPY VARCHAR2,
      p_bom_type   OUT NOCOPY VARCHAR2,
      p_type   OUT NOCOPY VARCHAR2,
      p_manager   OUT NOCOPY VARCHAR2,
      p_lob     OUT NOCOPY VARCHAR2
    )
    IS

      l_currency             VARCHAR2(50);
      l_length               NUMBER;
      l_dash_index           NUMBER;
      l_err_msg              VARCHAR2(100);
      l_org         VARCHAR2(4000);
      l_rolling              VARCHAR2(15);
    BEGIN

      l_rolling := 'ROLLING';
      p_drill := 'N';

      IF (p_page_parameter_tbl.count > 0) THEN
        FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
          IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
            p_period_type := p_page_parameter_tbl(i).parameter_value;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
            p_view_by := p_page_parameter_tbl(i).parameter_value;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
            p_currency := p_page_parameter_tbl(i).parameter_id;
          ELSIF p_page_parameter_tbl(i).parameter_name= 'AS_OF_DATE' THEN
            p_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
          ELSIF p_page_parameter_tbl(i).parameter_name= 'BIS_PREVIOUS_ASOF_DATE' THEN
            p_prev_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
          ELSIF p_page_parameter_tbl(i).parameter_name= 'BIS_CURRENT_REPORT_START_DATE' THEN
            p_report_start := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
          ELSIF p_page_parameter_tbl(i).parameter_name= 'TIME_COMPARISON_TYPE' THEN
            p_comp_type := p_page_parameter_tbl(i).parameter_value;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT' THEN
            p_category := p_page_parameter_tbl(i).parameter_id;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_ORG'
            OR p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM' THEN
            -- note: parameter_id will be "'8000-200'" where 8000 is item_id, 200 is org, and single quotes enclose it
            l_length := length(p_page_parameter_tbl(i).parameter_id);
            l_dash_index := instr(p_page_parameter_tbl(i).parameter_id, '-');
            IF l_dash_index > 0 THEN
              p_item := substr(p_page_parameter_tbl(i).parameter_id, 2, l_dash_index-2);
              l_org := substr(p_page_parameter_tbl(i).parameter_id, l_dash_index+1, l_length-l_dash_index-1);
            END IF;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_WEEK_FROM' THEN
            p_cur_period := p_page_parameter_tbl(i).parameter_id;
            p_id_column := 'week_id';
            l_rolling := 'ENTERPRISE';
          ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
            p_cur_period := p_page_parameter_tbl(i).parameter_id;
            p_id_column := 'ent_period_id';
            l_rolling := 'ENTERPRISE';
          ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
            p_cur_period := p_page_parameter_tbl(i).parameter_id;
            p_id_column := 'ent_qtr_id';
            l_rolling := 'ENTERPRISE';
          ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
            p_cur_period := p_page_parameter_tbl(i).parameter_id;
            p_id_column := 'ent_year_id';
            l_rolling := 'ENTERPRISE';
          ELSIF p_page_parameter_tbl(i).parameter_name = 'ORDERBY' THEN
            p_order_by := p_page_parameter_tbl(i).parameter_value;

            IF substr(rtrim(ltrim(p_order_by)), 1, 3) = 'VBT' THEN
              p_order_by := 't.' || substr(p_page_parameter_tbl(i).parameter_value,
              instr(p_page_parameter_tbl(i).parameter_value, '.', 1) + 1,
              length(p_page_parameter_tbl(i).parameter_value) - 2 );
            ELSE
              null;
            END IF;

          ELSIF p_page_parameter_tbl(i).parameter_name = 'ISD' THEN
            p_drill := 'Y';
            -- For now, if 'All' is selected for organization, p_org is defaulted to 207.
            -- Eventually we should set p_org to null, and handle null orgs in our sql
          ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+ORGANIZATION' THEN
            IF (l_org IS NULL) THEN
              IF p_page_parameter_tbl(i).parameter_id IS NULL THEN
                l_org := NULL;
              ELSE
                l_org := TRIM(both '''' from p_page_parameter_tbl(i).parameter_id);
              END IF;
            END IF;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'ENI_CHANGE_MGMT_STATUS+ENI_CHANGE_MGMT_STATUS' THEN
            p_status := p_page_parameter_tbl(i).parameter_id;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'ENI_CHANGE_MGMT_PRIORITY+ENI_CHANGE_MGMT_PRIORITY' THEN
            p_priority := p_page_parameter_tbl(i).parameter_id;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'ENI_CHANGE_MGMT_REASON+ENI_CHANGE_MGMT_REASON' THEN
            p_reason   := p_page_parameter_tbl(i).parameter_id;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'LIFECYCLE_PHASE' THEN
            p_lifecycle_phase := p_page_parameter_tbl(i).parameter_value;
          --ELSIF p_page_parameter_tbl(i).parameter_name = 'CURRENCY' THEN
          --  p_currency  := p_page_parameter_tbl(i).parameter_value;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'BOM_TYPE' THEN
            p_bom_type  := p_page_parameter_tbl(i).parameter_value;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'ENI_CHANGE_MGMT_TYPE+ENI_CHANGE_MGMT_TYPE' THEN
            p_type := p_page_parameter_tbl(i).parameter_id;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'MANAGER' THEN
            p_manager := p_page_parameter_tbl(i).parameter_value;
          ELSIF p_page_parameter_tbl(i).parameter_name = 'LOB+FII_LOB' THEN
            p_lob := p_page_parameter_tbl(i).parameter_value;
          END IF;
        END LOOP;
      END IF;

      -- if viewing by time, we should never sort by VIEWBY, only by t.start_date
      IF substr(p_view_by,1,5) = 'TIME+' THEN

        p_order_by := replace(p_order_by, 'VIEWBY', 't.start_date');

        -- Bug 3966048: PMV messes up its sorting logic and passes NLSSORT DESC for our Time viewbys

        -- Bug 9357647 : Start
        -- Below If condition should be executed only for Trend reports
        -- IF (p_order_by like '%NLSSORT%') THEN
        IF (p_order_by like '%NLSSORT(t.start_date%') THEN
        -- Bug 9357647 : End

          p_order_by := 't.start_date ASC';

        END IF;

      END IF;

      -- Bitmasks for the period types
      --  (from Time Dimension DLD, http://ap103fam.us.oracle.com:9999/servlet/page?_pageid=4889'&'_dad=portal30'&'_schema=PORTAL30)
      --  11 week
      --  23 month
      --  55 qtr
      --  119 year
      --  1143 project (247?)

      IF p_period_type IS NOT NULL THEN
        CASE p_period_type
          WHEN 'FII_TIME_WEEK' THEN
            p_period_bitand := 11;
            select (p_as_of_date - start_date) into p_days_into_period from fii_time_week where week_id = p_cur_period;
          WHEN 'FII_TIME_ENT_PERIOD' THEN
            p_period_bitand := 23;
            select (p_as_of_date - start_date) into p_days_into_period from fii_time_ent_period where ent_period_id = p_cur_period;
          WHEN 'FII_TIME_ENT_QTR' THEN
            p_period_bitand := 55;
            select (p_as_of_date - start_date) into p_days_into_period from fii_time_ent_qtr where ent_qtr_id = p_cur_period;
          WHEN 'FII_TIME_ENT_YEAR'   THEN
            p_period_bitand := 119;
            select (p_as_of_date - start_date) into p_days_into_period from fii_time_ent_year where ent_year_id = p_cur_period;
          WHEN 'FII_ROLLING_WEEK' THEN
            p_period_bitand := 1024;
            p_days_into_period := 7;   -- Added to fix Bug # 3472006
          WHEN 'FII_ROLLING_MONTH' THEN
            p_period_bitand := 2048;
            p_days_into_period := 30;   -- Added to fix Bug # 3472006
          WHEN 'FII_ROLLING_QTR' THEN
            p_period_bitand :=4096;
            p_days_into_period := 90;   -- Added to fix Bug # 3472006
          WHEN 'FII_ROLLING_YEAR'   THEN
            p_period_bitand := 8192;
            p_days_into_period := 365;   -- Added to fix Bug # 3472006
          ELSE
            null;
        END CASE;
      ELSE
        IF (l_rolling = 'ROLLING') THEN
          p_period_bitand := 1024;
        ELSE
          p_period_bitand := 11;
        END IF;
      END IF;
      p_org := l_org;

    EXCEPTION

      WHEN OTHERS THEN
        NULL;

  END get_parameters;


  -- This procedure provides a level of indirection between
  -- the standard DBI logging procedure and the ENI collection
  -- packages.
  -- For now, the procedure and parameters have the same meaning as those
  -- in BIS_COLLECTION_UTILITIES.LOG.
  PROCEDURE log(p_message VARCHAR2,
         p_indenting NUMBER DEFAULT 0)
  IS

  BEGIN
    -- for now, we simply pass the parameters through
    bis_collection_utilities.log(p_message, p_indenting);

  END log;

  -- This procedure provides a level of indirection between
  -- the standard DBI logging procedure and the ENI collection
  -- packages.
  -- For now, the procedure and parameters have the same meaning as those
  -- in BIS_COLLECTION_UTILITIES.debug.
  PROCEDURE debug(p_message VARCHAR2,
           p_indenting NUMBER DEFAULT 0)
  IS

  BEGIN

    -- for now, we simply pass the parameters through
    bis_collection_utilities.debug(p_message, p_indenting);

  END debug;

  -- This procedure initializes the debug logging for our
  -- PL/SQL report packages.
  --
  -- Parameters
  -- p_rpt_name: The FND function name of the report
  --             which is to be debugged
  PROCEDURE init_rpt(p_rpt_func_name VARCHAR2)
  IS

  BEGIN

    null;

  END init_rpt;

  -- This procedure writes a debug message to the
  -- file previously opened by the init procedure
  --
  -- Parameters
  -- p_message: The string which is to be written into
  --            the log
  PROCEDURE debug_rpt(p_message VARCHAR2)
  IS

  BEGIN

    null;

  END debug_rpt;


  --   This wrapper function supplies the mandatory time dimension parameters
  --   in addition to those returned by the bil_bi_util_pkg.get_dbi_params.
  --   Form function for the page has been modified to call
  --   this function instead of bil_bi_util_pkg.get_dbi_params
  --   Created to fix bug - bug# 3771850

  FUNCTION get_all_dbi_params(p_region_code varchar2) return varchar2 as

    params_string varchar2(4000);

  begin

/*
     Remove the call to avoid nesting and dependency on sales pkg
                        params_string := bil_bi_util_pkg.get_dbi_params(p_region_code);
*/
   params_string := '&JTF_ORG_SALES_GROUP=' || JTF_RS_DBI_CONC_PUB.GET_SG_ID() || '&BIS_ENI_ITEM_VBH_CAT=All';
                 params_string := params_string ||
   '&FII_TIME_ENT_PERIOD=TIME+FII_TIME_ENT_QTR' || -- Period type default argument
   -- PERIOD TYPE CONVERTED TO QTR FOR BUG#3951523
   '&YEARLY=TIME_COMPARISON_TYPE+YEARLY' ; -- Comparision type default argument
    return params_string;

  end get_all_dbi_params;

  FUNCTION get_curr_prim RETURN VARCHAR2 AS
    BEGIN
      return g_curr_prim;
  END get_curr_prim;

  FUNCTION get_curr_sec RETURN VARCHAR2 AS
    BEGIN
      return g_curr_sec;
  END get_curr_sec;

END ENI_DBI_UTIL_PKG;

/
