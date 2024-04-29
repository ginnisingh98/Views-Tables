--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_DYNSQLGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_DYNSQLGEN" AS
/* $Header: hriopsql.pkb 120.5 2006/02/02 06:11:17 cbridge noship $ */

g_debug               VARCHAR2(5) := 'FALSE';

g_temp_no_rollup      VARCHAR2(30) := NULL;
g_temp_no_value       VARCHAR2(30) := hri_oltp_view_message.get_unassigned_msg;
g_all_msg             VARCHAR2(30) := hri_oltp_view_message.get_all_msg;

/* Hierarchy Column Metadata */
g_suph                VARCHAR2(30) := 'HRI_CS_SUPH';
g_suph_id             VARCHAR2(30) := 'PERSON_ID';
g_suph_level_col      VARCHAR2(30) := 'RELATIVE_LEVEL';
g_orgh                VARCHAR2(30) := 'HRI_CS_ORGH';
g_orgh_id             VARCHAR2(30) := 'ORGANIZATION_ID';
g_orgh_level_col      VARCHAR2(30) := 'ORG_RELATIVE_LEVEL';
g_posh                VARCHAR2(30) := 'HRI_CS_POSH';
g_posh_id             VARCHAR2(30) := 'POSITION_ID';
g_posh_level_col      VARCHAR2(30) := 'RELATIVE_LEVEL';

/* Hierarchy Column Naming Standards */
g_sub_prefix          VARCHAR2(30) := 'SUB_';
g_subro_prefix        VARCHAR2(30) := 'SUBRO_';
g_view_suffix         VARCHAR2(30) := '_V';
g_crrnt_view_suffix   VARCHAR2(30) := '_X_V';
g_rollup_suffix       VARCHAR2(30) := 'RO';

/* Default Start and End Dates */
g_start_of_time       DATE := hr_general.start_of_time;
g_end_of_time         DATE := hr_general.end_of_time;

/* New Line */
g_rtn                 VARCHAR2(30) := '
';

TYPE g_sort_record_type IS RECORD
     (column_name     VARCHAR2(60),
      sort_direction  VARCHAR2(30));

TYPE g_measure_type IS RECORD
     (column_name     VARCHAR2(60),
      aggregation     VARCHAR2(30));

TYPE g_sort_record_tabtype IS TABLE OF g_sort_record_type
           INDEX BY BINARY_INTEGER;

TYPE g_measure_tabtype IS TABLE OF g_measure_type
           INDEX BY BINARY_INTEGER;

/******************************************************************************/
/* Given the dimension level code this function returns the dimension level   */
/* view. The dimension level code is in the format DIMENSION+DIMENSION_LEVEL  */
/******************************************************************************/
FUNCTION get_level_view_name(p_dim_level_code   IN VARCHAR2)
               RETURN VARCHAR2 IS

/* Cursor returning the dimension level view for a given level */
  CURSOR viewby_view_csr(v_lvl_short_name   IN VARCHAR2) IS
  SELECT level_values_view_name   view_name
  FROM bisbv_dimension_levels  lvl
  WHERE lvl.dimension_level_short_name = v_lvl_short_name;

  l_view_name   VARCHAR2(30);

BEGIN

/* Open the cursor with the DIMENSION_LEVEL part of the input code */
  OPEN viewby_view_csr(SUBSTR(p_dim_level_code,INSTR(p_dim_level_code,'+')+1));
  FETCH viewby_view_csr INTO l_view_name;
  CLOSE viewby_view_csr;

  RETURN l_view_name;

EXCEPTION WHEN OTHERS THEN
  CLOSE viewby_view_csr;
  RAISE;
END get_level_view_name;

/******************************************************************************/
/* Get (hard coded) hierarchy details                                         */
/******************************************************************************/
PROCEDURE get_hierarchy_details(p_ak_level_code          IN VARCHAR2,
                                p_hierarchy_view         OUT NOCOPY VARCHAR2,
                                p_hierarchy_view_suffix  OUT NOCOPY VARCHAR2,
                                p_hierarchy_level        OUT NOCOPY VARCHAR2,
                                p_hierarchy_col          OUT NOCOPY VARCHAR2) IS

BEGIN

/* Find out which hierarchy view and join column to use */
  IF (p_ak_level_code = 'HRI_ORGANIZATION+HISTORIC') THEN
    p_hierarchy_view := g_orgh;
    p_hierarchy_view_suffix := g_view_suffix;
    p_hierarchy_level  := g_orgh_level_col;
    p_hierarchy_col  := g_orgh_id;
  ELSIF (p_ak_level_code = 'HRI_POSITION+HISTORIC') THEN
    p_hierarchy_view := g_posh;
    p_hierarchy_view_suffix := g_view_suffix;
    p_hierarchy_level  := g_posh_level_col;
    p_hierarchy_col  := g_posh_id;
  ELSIF (p_ak_level_code = 'HRI_SUPERVISOR+HISTORIC') THEN
    p_hierarchy_view := g_suph;
    p_hierarchy_view_suffix := g_view_suffix;
    p_hierarchy_level  := g_suph_level_col;
    p_hierarchy_col  := g_suph_id;
  ELSIF (p_ak_level_code = 'HRI_SUPERVISOR+CURRENT') THEN
    p_hierarchy_view := g_suph;
    p_hierarchy_view_suffix := g_crrnt_view_suffix;
    p_hierarchy_level  := g_suph_level_col;
    p_hierarchy_col  := g_suph_id;
  END IF;

END get_hierarchy_details;

/******************************************************************************/
/* Get (hard coded) details if the viewby is a hierarchy                      */
/******************************************************************************/
PROCEDURE get_viewby_hierarchy_details( p_viewby_level_code     IN VARCHAR2,
                                        p_hierarchy_col         IN VARCHAR2,
                                        p_hierarchy_level       IN VARCHAR2,
                                        p_hierarchy_join        IN OUT NOCOPY VARCHAR2,
                                        p_hierarchy_view_suffix IN OUT NOCOPY VARCHAR2,
                                        p_viewby_select         IN OUT NOCOPY VARCHAR2,
                                        p_viewby_col            IN OUT NOCOPY VARCHAR2,
                                        p_hierarchy_condition   OUT NOCOPY VARCHAR2,
                                        p_order_by_clause       OUT NOCOPY VARCHAR2,
                                        p_group_by_clause       OUT NOCOPY VARCHAR2) IS

BEGIN

/* Finish the hierarchy join ('AND fact.column = hrchy.') */
/* Get the viewby column and doctor the viewby display column in the select */
/* clause if the top node is selected. Also doctor the column order to make */
/* the top node appear first if selected. Apply the relevant conditions to */
/* the hierarchy view to include top, enable rollup or include subordinates */
  IF (p_viewby_level_code = 'HRI_VIEWBY_ORGH+HRI_DRCTS_ROLLUP_INC' OR
      p_viewby_level_code = 'HRI_VIEWBY_SUPH+HRI_DRCTS_ROLLUP_INC') THEN
    p_hierarchy_join := p_hierarchy_join || g_subro_prefix || p_hierarchy_col;
    p_viewby_col := 'hrchy.' || g_sub_prefix || p_hierarchy_col;
    p_viewby_select :=
     '  DECODE(hrchy.' || g_sub_prefix || p_hierarchy_level || ',' || g_rtn ||
     '           0, viewby.value || ''' || g_temp_no_rollup || ''',' || g_rtn ||
     '         viewby.value)           VIEWBY';
    p_hierarchy_condition :=
     'AND (hrchy.' || g_sub_prefix || p_hierarchy_level || ' = 1' || g_rtn ||
     ' OR (hrchy.' || g_sub_prefix || p_hierarchy_level || ' = 0' ||
     ' AND hrchy.' || g_subro_prefix || g_sub_prefix || p_hierarchy_level
       || ' = 0))' || g_rtn;
    p_order_by_clause :=
     '  DECODE(hrchy.' || g_sub_prefix || p_hierarchy_level ||
     ',0,1,2)';
    p_group_by_clause :=
     ' ,DECODE(hrchy.' || g_sub_prefix || p_hierarchy_level ||
     ',0,1,2)' || g_rtn ||
     ' ,DECODE(hrchy.' || g_sub_prefix || p_hierarchy_level || ',' || g_rtn ||
     '           0, viewby.value || ''' || g_temp_no_rollup || ''',' || g_rtn ||
     '         viewby.value)' || g_rtn;
    p_hierarchy_view_suffix := g_rollup_suffix || p_hierarchy_view_suffix;
  ELSIF (p_viewby_level_code = 'HRI_VIEWBY_ORGH+HRI_DRCTS_ROLLUP' OR
         p_viewby_level_code = 'HRI_VIEWBY_SUPH+HRI_DRCTS_ROLLUP') THEN
    p_hierarchy_join := p_hierarchy_join || g_subro_prefix || p_hierarchy_col;
    p_viewby_col := 'hrchy.' || g_sub_prefix ||p_hierarchy_col;
    p_hierarchy_condition := 'AND hrchy.' || g_sub_prefix || p_hierarchy_level
                          || ' = 1' || g_rtn;
    p_hierarchy_view_suffix := g_rollup_suffix || p_hierarchy_view_suffix;
  ELSIF (p_viewby_level_code = 'HRI_VIEWBY_ORGH+HRI_ALL_INC' OR
         p_viewby_level_code = 'HRI_VIEWBY_SUPH+HRI_ALL_INC') THEN
    p_hierarchy_join := p_hierarchy_join || g_sub_prefix || p_hierarchy_col;
    p_viewby_col := 'hrchy.' || g_sub_prefix || p_hierarchy_col;
  ELSIF (p_viewby_level_code = 'HRI_VIEWBY_ORGH+HRI_ALL' OR
         p_viewby_level_code = 'HRI_VIEWBY_SUPH+HRI_ALL') THEN
    p_hierarchy_join := p_hierarchy_join || g_sub_prefix || p_hierarchy_col;
    p_viewby_col := 'hrchy.' || g_sub_prefix || p_hierarchy_col;
    p_hierarchy_condition := 'AND hrchy.' || g_sub_prefix || p_hierarchy_level
                          || ' > 0' || g_rtn;
  END IF;

END get_viewby_hierarchy_details;

/******************************************************************************/
/* This is the procedure which builds up the main SQL statement. It queries   */
/* the parameter table of values passed into the package, and gets all the    */
/* information in the AK Region for the report. It combines this information  */
/* to form the SQL query.                                                     */
/*                                                                            */
/* Some special cases are also handled by this procedure. The most basic PMV  */
/* reports can be handled generically without referring to specific objects.  */
/* However reports using the time dimension need special treatment. Also in   */
/* the "special" category are hierarchical parameters not yet supported.      */
/******************************************************************************/
FUNCTION build_sql_stmt(p_region_code      IN VARCHAR2,
                        p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
                 RETURN VARCHAR2 IS

/* Loop counter */
  l_counter                   NUMBER;  -- used to go through sort record table

/* Information about ORDERBY parameter */
  l_orderby_column            VARCHAR2(1000);   -- column name passed in for sort

/* Information about VIEWBY object */
  l_viewby_view               VARCHAR2(30);   -- view name of viewby view
  l_viewby_level              VARCHAR2(60);   -- viewby DIMENSION+LEVEL name
  l_viewby_col                VARCHAR2(30);   -- fact column joins to viewby id
  l_viewby_select             VARCHAR2(2000); -- doctored viewby display column

/* Information about TIME object */
  l_time_view                 VARCHAR2(60);  -- view name of time view
  l_time_level                VARCHAR2(60);  -- time DIMENSION+LEVEL name
  l_time_col                  VARCHAR2(60);  -- fact column joins to time level
  l_time_from_date            DATE;          -- time from period start date
  l_time_to_date              DATE;          -- time to period end date
  l_report_start_date         DATE;          -- report date - period type
  l_report_date               DATE;          -- report date to
  l_viewby_time_condition     VARCHAR2(500); -- time condition on time view
  l_no_viewby_time_condition  VARCHAR2(500); -- time condition on fact view

/* Information about hierarchy object */
  l_hierarchy_view            VARCHAR2(60);  -- view name of hierarchy object
  l_hierarchy_view_suffix     VARCHAR2(60);  -- "_X_V" current "_V" historic
  l_hierarchy_col             VARCHAR2(60);  -- fact column joins to hierarchy
  l_hierarchy_level           VARCHAR2(30);  -- hierarchy DIMENSION+LEVEL name
  l_hierarchy_join            VARCHAR2(500); -- hierarchy - fact join condition
  l_hierarchy_condition       VARCHAR2(500); -- include top node condition
  l_hierarchy_order_by        VARCHAR2(500); -- orders by top node first

/* AK Base Object */
  l_db_object_name            VARCHAR2(30);  -- Database object from AK Object

/* Variables for SQL query */
  l_sql_query                 VARCHAR2(4000); -- holds SQL to return
  l_params_header             VARCHAR2(2000); -- debug output header
  l_select_clause             VARCHAR2(2000); -- main SELECT
  l_from_clause               VARCHAR2(2000); -- main FROM
  l_where_clause              VARCHAR2(2000); -- main WHERE
  l_group_by_clause           VARCHAR2(2000); -- main GROUP BY
  l_order_by_clause           VARCHAR2(2000); -- main ORDER BY
  l_outer_select              VARCHAR2(2000); -- allows default time periods
  l_union_select              VARCHAR2(2000); -- allows default time periods
  l_union_clause              VARCHAR2(2000); -- allows default time periods
  l_sort_record_tab           g_sort_record_tabtype; -- allows alternative sort
  l_measure_tab               g_measure_tabtype; -- stores measures
  l_calc_measure              VARCHAR2(2000); -- builds up calculated measures

/* Cursor returning all AK Region Items for a given region */
  CURSOR ak_region_info_csr IS
  SELECT
   itm.attribute1                   column_type
  ,itm.attribute2                   level_code
  ,lower(itm.attribute3)            column_name
  ,itm.attribute_code               item_code
  ,itm.attribute9                   aggregation
  ,itm.node_display_flag            display_flag
  ,itm.attribute15                  lov_table
  ,itm.attribute4                   lov_where_clause
  ,itm.attribute11                  hrchy_view_override
  ,itm.order_sequence               order_sequence
  ,itm.order_direction              order_direction
  ,lower(reg.database_object_name)  object_name
  ,reg.attribute11                  region_where_clause
  ,itm.display_sequence             display_sequence
  FROM
   ak_region_items  itm
  ,ak_regions       reg
  WHERE reg.region_code = p_region_code
  AND reg.region_application_id = 453
  AND itm.region_code = reg.region_code
  AND reg.region_application_id = itm.region_application_id
/* Must have hidden parameters first so that hierarchy can be extracted */
/* before other parts of the sql statement are built up. */
/* Calculated measures must be returned after view column measures */
/* which is done by the 3rd column
/* Also depending on HRI_PERIOD_TYPE dimension being extracted before */
/* HRI_REPORT_DATE which is done by the last order by column */
  ORDER BY DECODE(itm.attribute1,
                    'HIDE PARAMETER', 1,
                    'HIDE VIEW BY DIMENSION', 2,
                  3)
  ,DECODE(SUBSTR(itm.attribute_code,1,12),
             'HRI_P_HIERAR',1,
             'HRI_P_VIEWBY',2,
           3)
  ,DECODE(SUBSTR(itm.attribute3,1,1),'"',2,1)
  ,itm.attribute2;

BEGIN

/******************************************************************************/
/* LOCAL VARIABLE INITIALIZATION */
/*********************************/

/* Default the viewby select column so that if */
/* the value is null a "no value" label is displayed */
  l_viewby_select :=
            '  DECODE(viewby.id, ' || g_rtn ||
            '           ''-1'', ''' || g_temp_no_value || ''',' || g_rtn ||
            '           ''NA_EDW'',''' || g_temp_no_value || ''',' || g_rtn ||
            '         viewby.value)          VIEWBY';

/* Build a SQL header with debug information - all parameters passed in */
/* Initialize the header */
  l_params_header := '-- AK REGION: ' || p_region_code || g_rtn ||
                     '-- Parameter Name:   Parameter Value' || g_rtn;


/******************************************************************************/
/* PARAMETER TABLE LOOP 1 - GET VIEWBY/TIME PARAMETERS */
/*******************************************************/

/* Loop through parameters to get the parameter special cases */
  FOR i IN p_params_tbl.first..p_params_tbl.last LOOP
  /* Bug  4633221 - Translation problem with 'All' */
  IF (p_params_tbl(i).parameter_value = g_all_msg) THEN
  /* Add parameter information to debug header */
    l_params_header := l_params_header || '-- ' ||
                       p_params_tbl(i).parameter_name  || ':  ' ||
                       'All' || g_rtn;
  ELSE
  /* Add parameter information to debug header */
    l_params_header := l_params_header || '-- ' ||
                       p_params_tbl(i).parameter_name  || ':  ' ||
                       p_params_tbl(i).parameter_value || g_rtn;
  END IF;

  /* Retrieve information parameter special cases */
  /* Pull out information about the VIEWBY dimension */
    IF (p_params_tbl(i).parameter_name = 'VIEW_BY') THEN
    /* Get the viewby view from the dimension metadata (may be null) */
      l_viewby_view := get_level_view_name(p_params_tbl(i).parameter_value);
    /* Record the viewby DIMENSION+LEVEL name */
      l_viewby_level  := p_params_tbl(i).parameter_value;

  /* Pull out information about the ORDERBY object */
    ELSIF (p_params_tbl(i).parameter_name = 'ORDERBY') THEN
      l_orderby_column := LTRIM(p_params_tbl(i).parameter_value);

  /* Pull out information about the TIME dimension */
    ELSIF (substr(p_params_tbl(i).parameter_name,1,4) = 'TIME') THEN
      IF substr(p_params_tbl(i).parameter_name,-5,5)='_FROM' THEN
      /* Get the start date */
        l_time_from_date     := p_params_tbl(i).period_date;
      /* Add the condition for the start date */
        l_viewby_time_condition := l_viewby_time_condition ||
            'AND tim.start_date >= to_date(''' ||
             to_char(l_time_from_date,'DD-MM-YYYY') ||
            ''',''DD-MM-YYYY'')' || g_rtn;
      ELSIF substr(p_params_tbl(i).parameter_name,-3,3)='_TO' THEN
      /* Get the end date */
        l_time_to_date       := p_params_tbl(i).period_date;
      /* Add the condition for the end date */
        l_viewby_time_condition := l_viewby_time_condition ||
            'AND tim.end_date   <= to_date(''' ||
             to_char(l_time_to_date,'DD-MM-YYYY') ||
            ''',''DD-MM-YYYY'')' || g_rtn;
      END IF;

  /* Pull out information about the TIME dimension level */
    ELSIF (p_params_tbl(i).parameter_name = 'PERIOD_TYPE') THEN
      l_time_view   := get_level_view_name(p_params_tbl(i).parameter_value);
      l_time_level  := 'TIME+' || p_params_tbl(i).parameter_value;

  /* Pull out information about the HRI REPORT DATE dimension */
    ELSIF (p_params_tbl(i).parameter_name = 'HRI_NO_JOIN_DATE+HRI_REPORT_DATE') THEN
      l_report_date := p_params_tbl(i).period_date;

  /* Pull out information about the HRI PERIOD TYPE dimension */
    ELSIF (p_params_tbl(i).parameter_name = 'HRI_NO_JOIN_PERIOD+HRI_PERIOD_TYPE') THEN
    /* Set the report start date as l_report_date - l_period type */
      IF (p_params_tbl(i).parameter_id = '''Y''') THEN
        l_report_start_date := add_months(l_report_date, -12);
      ELSIF (p_params_tbl(i).parameter_id = '''Q''') THEN
        l_report_start_date := add_months(l_report_date, -3);
      ELSIF (p_params_tbl(i).parameter_id = '''CM''') THEN
        l_report_start_date := add_months(l_report_date, -1);
      END IF;
    END IF;

  END LOOP;


/******************************************************************************/
/* AK Region Loop - Builds up SQL Statement */
/********************************************/

/* Get AK Region Items Information */
  FOR measure_rec IN ak_region_info_csr LOOP

  /* The base view name - same on every cursor row */
    IF (l_db_object_name IS NULL) THEN
      l_db_object_name := measure_rec.object_name;
    /* 115.1 - add the region where clause only if there is one defined */
      IF (measure_rec.region_where_clause IS NOT NULL) THEN
        l_where_clause := l_where_clause || measure_rec.region_where_clause || g_rtn;
      END IF;
    END IF;

  /***************/
  /* AK MEASURES */
  /***************/
    IF (measure_rec.column_type = 'MEASURE' OR
        measure_rec.column_type IS NULL) THEN
    /* Ignore measures which are calculated AK Region Items */
      IF (SUBSTR(measure_rec.column_name,1,1) <> '"' AND
          measure_rec.aggregation IS NOT NULL) THEN
      /* Store information about the measure */
        l_measure_tab(measure_rec.display_sequence).column_name :=
                                                 measure_rec.column_name;
        l_measure_tab(measure_rec.display_sequence).aggregation :=
                                                 measure_rec.aggregation;
      /* Check for non-default sort order */
        IF (measure_rec.order_sequence IS NOT NULL) THEN
          l_sort_record_tab(measure_rec.order_sequence).column_name :=
                                                 measure_rec.item_code;
          l_sort_record_tab(measure_rec.order_sequence).sort_direction :=
                                                 measure_rec.order_direction;
        END IF;
        IF (measure_rec.display_flag = 'Y') THEN
        /* SELECT CLAUSE BUILD - add all non AK calculated measure columns */
          l_select_clause := l_select_clause || g_rtn ||
          ' ,' || measure_rec.aggregation || '(fact.' || measure_rec.column_name
               || ')     "' || measure_rec.item_code || '"';
          l_union_select := l_union_select || g_rtn || ' ,0';
          l_outer_select := l_outer_select || g_rtn || ' ,SUM(' ||
                      measure_rec.item_code || ')   ' || measure_rec.item_code;
        END IF;

/* Bug 2670163 - If the order by is a calculated measure, substitute the */
/* calculation for the order by column */
      ELSIF (measure_rec.item_code = SUBSTR(l_orderby_column,1,
                                            INSTR(l_orderby_column,' ')-1)) THEN
      /* Else if a displayed calculated measure */
        l_calc_measure := measure_rec.column_name;
      /* Put quotes around any character which could possibly appear */
      /* next to a column name in the calculated measure string */
        l_calc_measure := REPLACE(l_calc_measure,'(','"("');
        l_calc_measure := REPLACE(l_calc_measure,')','")"');
        l_calc_measure := REPLACE(l_calc_measure,'+','"+"');
        l_calc_measure := REPLACE(l_calc_measure,'-','"-"');
        l_calc_measure := REPLACE(l_calc_measure,'/','"/"');
        l_calc_measure := REPLACE(l_calc_measure,'*','"*"');
      /* Loop through the single column measures and swap in the column */
      /* names and aggregation */
        l_counter := l_measure_tab.first;
        WHILE (l_counter IS NOT NULL) LOOP
          l_calc_measure := REPLACE(l_calc_measure,
                      '"' || l_measure_tab(l_counter).column_name||'"',
                      l_measure_tab(l_counter).aggregation ||
                      '(fact.'||l_measure_tab(l_counter).column_name||')');
          l_counter := l_measure_tab.next(l_counter);
        END LOOP;
     /* Remove any excess quotes */
        l_calc_measure := REPLACE(l_calc_measure,'"');
     /* Set the order by column to the calculated measure */
        l_orderby_column := l_calc_measure ||
                          SUBSTR(l_orderby_column,INSTR(l_orderby_column,' '));
      END IF;

  /****************************************************************/
  /* AK DIMENSIONS - Hierarchy Item / Report Date / Time / Viewby */
  /****************************************************************/
    ELSE
    /* HRI_P_HIERARCHY item will crop up first as the cursor */
    /* is ordered to return HIDE PARAMETER items first */
      IF (measure_rec.item_code = 'HRI_P_HIERARCHY') THEN
      /* Get (hard coded) hierarchy details */
        get_hierarchy_details
          (p_ak_level_code => measure_rec.level_code,
           p_hierarchy_view => l_hierarchy_view,
           p_hierarchy_view_suffix => l_hierarchy_view_suffix,
           p_hierarchy_level => l_hierarchy_level,
           p_hierarchy_col => l_hierarchy_col);
      /* Start building up the hierarchy join using the fact column */
        l_hierarchy_join := 'AND fact.' || measure_rec.column_name || ' = hrchy.';

    /* HRI_REPORT_DATE will crop up next as the cursor is ordered */
    /* to return HIDE VIEWBY PARAMETER items second */
      ELSIF (measure_rec.item_code = 'HRI_P_REPORTING_DATE') THEN
        IF (INSTR(measure_rec.column_name,'.') > 0) THEN
          l_time_col := measure_rec.column_name;
        ELSE
          l_time_col := 'fact.' || measure_rec.column_name;
        END IF;

    /* Time Dimension */
      ELSIF (l_time_level = measure_rec.level_code) THEN
        l_time_col := measure_rec.column_name;
        IF (measure_rec.column_type = 'HIDE VIEW BY DIMENSION') THEN
          l_no_viewby_time_condition :=
            'AND fact.' || l_time_col ||
            ' BETWEEN  to_date(''' ||
             to_char(NVL(l_time_from_date,g_start_of_time),'DD-MM-YYYY') ||
              ''',''DD-MM-YYYY'')' || g_rtn ||
            '      AND to_date(''' ||
             to_char(NVL(l_time_to_date,g_end_of_time),'DD-MM-YYYY') ||
              ''',''DD-MM-YYYY'')' || g_rtn;
        END IF;
      END IF; -- AK Dimension Split Out

    /* Viewby Dimension */
      IF (l_viewby_level = measure_rec.level_code) THEN
      /* If an LOV Table has been specified, override the viewby view */
        l_viewby_view := NVL(measure_rec.lov_table, l_viewby_view);
      /* Get the fact column to join to the viewby view */
        l_viewby_col := measure_rec.column_name;
      /* Check the viewby special cases - HIERARCHYs */
        IF (SUBSTR(l_viewby_level,1,10) = 'HRI_VIEWBY') THEN
          get_viewby_hierarchy_details
             (p_viewby_level_code => l_viewby_level,
              p_hierarchy_col => l_hierarchy_col,
              p_hierarchy_level => l_hierarchy_level,
              p_hierarchy_join => l_hierarchy_join,
              p_hierarchy_view_suffix => l_hierarchy_view_suffix,
              p_viewby_col => l_viewby_col,
              p_viewby_select => l_viewby_select,
              p_hierarchy_condition => l_hierarchy_condition,
              p_order_by_clause => l_order_by_clause,
              p_group_by_clause => l_group_by_clause);
        ELSE
        /* l_hierarchy_join is already of the form 'AND fact.column = hrchy.' */
          l_hierarchy_join := l_hierarchy_join || g_sub_prefix || l_hierarchy_col;
        END IF;

      END IF;  -- Viewby Dimension

    /*******************************************************/
    /* PARAMETER TABLE LOOP 2 - Match Dimension Parameters */
    /*******************************************************/
      FOR i IN p_params_tbl.first..p_params_tbl.last LOOP
      /* If the parameter is a dimension level with values selected */
      /* then add it to the WHERE clause */
        IF (p_params_tbl(i).parameter_name = measure_rec.level_code AND
            p_params_tbl(i).parameter_value <> 'All' AND
     /* Bug  4633221 - Translation problem with 'All' */
	    p_params_tbl(i).parameter_value <> g_all_msg AND
            p_params_tbl(i).parameter_value IS NOT NULL AND
            SUBSTR(p_params_tbl(i).parameter_name,1,11) <> 'HRI_NO_JOIN') THEN
         /* WHERE CLAUSE BUILD - Simple Dimension Parameter Value */
          IF (INSTR(measure_rec.column_name,'.') > 0) THEN
            l_where_clause := l_where_clause ||
                   'AND ' || measure_rec.column_name ||
                   ' IN (&' || p_params_tbl(i).parameter_name || ')' || g_rtn;
          ELSE
            l_where_clause := l_where_clause ||
                   'AND fact.' || measure_rec.column_name ||
                   ' IN (&' || p_params_tbl(i).parameter_name || ')' || g_rtn;
          END IF;
        END IF;

      END LOOP; -- Parameter Table

    END IF; -- AK Measure or Dimension

  END LOOP; -- AK Region Items

/******************************************************************************/
/* BUILD UP SQL STATEMENT */
/**************************/

/* The SELECT clause always picks a VIEWBY column and the list of measure */
/* columns already built up */
  l_select_clause :=  'SELECT'                           || g_rtn ||
                       l_viewby_select                   ||
                       l_select_clause                   || g_rtn;

/* The FROM clause always picks the database object from the AK region and */
/* the list of values view for the VIEWBY level */
  l_from_clause :=    'FROM' || g_rtn ||
                      '  '   || l_db_object_name || '   fact'   || g_rtn ||
                      ' ,'   || l_viewby_view    || '   viewby' || g_rtn ||
                       l_from_clause;

/* The WHERE clause always has the VIEWBY join condition and any */
/* conditions already built up from the parameter values */
  IF (INSTR(l_viewby_col,'.') > 0) THEN
    l_where_clause :=   'WHERE viewby.id = ' || l_viewby_col || g_rtn ||
                         l_where_clause;
  ELSE
    l_where_clause :=   'WHERE viewby.id = fact.' || l_viewby_col || g_rtn ||
                         l_where_clause;
  END IF;

/* Add reporting date condition to where clause if relevant */
  IF (l_report_start_date IS NOT NULL) THEN
    l_where_clause := l_where_clause ||
                      'AND ' || l_time_col ||
                      ' BETWEEN to_date(''' || to_char(l_report_start_date,'DD-MM-YYYY') ||
                      ''',''DD-MM-YYYY'') AND to_date(''' || to_char(l_report_date,'DD-MM-YYYY') ||
                      ''',''DD-MM-YYYY'')' || g_rtn;
  END IF;

/* The VIEWBY value and id columns are always in the GROUP BY clause */
  l_group_by_clause := 'GROUP BY' || g_rtn ||
                       '  DECODE(viewby.id, ' || g_rtn ||
                       '           ''-1'', ''' || g_temp_no_value || ''',' || g_rtn ||
                       '           ''NA_EDW'',''' || g_temp_no_value || ''',' || g_rtn ||
                       '         viewby.value)' || g_rtn ||
                       ' ,viewby.value' || g_rtn ||
                       ' ,viewby.id' || g_rtn ||
                       l_group_by_clause;

/* Unless the VIEWBY is time, the order by clause is: */
  l_counter := l_sort_record_tab.first;
/* If there is no sort order passed in parameters */
  IF (l_orderby_column IS NULL) THEN

  /* If there is a sort order defined on the region */
    IF (l_counter IS NOT NULL) THEN
    /* Populate order by clause with the stored sort columns */
      WHILE (l_counter IS NOT NULL) LOOP
        IF (l_order_by_clause IS NULL) THEN
          l_order_by_clause := l_sort_record_tab(l_counter).column_name ||
                               ' ' || l_sort_record_tab(l_counter).sort_direction;
        ELSE
          l_order_by_clause := l_order_by_clause || g_rtn ||
                               ' ,' || l_sort_record_tab(l_counter).column_name ||
                               ' ' || l_sort_record_tab(l_counter).sort_direction;
        END IF;
        l_counter := l_sort_record_tab.next(l_counter);
      END LOOP;
      l_order_by_clause := 'ORDER BY' || g_rtn || l_order_by_clause;
    ELSE -- No sort order defined on region
      IF (l_order_by_clause IS NULL) THEN
        l_order_by_clause := 'ORDER BY viewby.value';
      ELSE
        l_order_by_clause := 'ORDER BY ' || l_order_by_clause || g_rtn ||
                             ' ,viewby.value';
      END IF;
    END IF;

  ELSE -- Sort order passed in parameter table

    IF (l_order_by_clause IS NOT NULL) THEN
      l_order_by_clause := 'ORDER BY ' || l_order_by_clause || g_rtn ||
                           ' ,' || l_orderby_column || g_rtn ||
                           ' ,viewby.value';
    ELSE
      l_order_by_clause := 'ORDER BY ' || l_orderby_column || g_rtn ||
                           ' ,viewby.value';
    END IF;

  END IF;

/* Alter above clauses depending on parameters selected */
/* If the query is restricted by the time parameter, and the TIME level is */
/* different to the VIEWBY level */
  IF (l_time_level IS NOT NULL AND
      l_time_level <> l_viewby_level AND
     (l_time_from_date IS NOT NULL OR l_time_to_date IS NOT NULL)) THEN

    IF (l_no_viewby_time_condition IS NOT NULL) THEN
      l_where_clause :=  l_where_clause || l_no_viewby_time_condition;
    ELSE
    /* Add the TIME view to the FROM clause */
      l_from_clause :=   l_from_clause ||
                        ' ,' || l_time_view      || '   tim' || g_rtn;
    /* Add the TIME-FACT join and TIME condition to the WHERE clause */
      l_where_clause :=  l_where_clause ||
                        'AND tim.id = fact.'   || l_time_col || g_rtn ||
                         l_viewby_time_condition;
    END IF;

  END IF;

/* If the VIEWBY level is a time dimension level */
  IF (SUBSTR(l_viewby_level,1,5) = 'TIME+' AND
      l_time_from_date IS NOT NULL AND
      l_time_to_date IS NOT NULL) THEN

  /* Create an outer SELECT statement so that the query results can be */
  /* combined with a set of default values for every time period - this */
  /* enables trend reporting */
    l_outer_select := 'SELECT' || g_rtn ||
                      ' VIEWBY         VIEWBY' ||
                       l_outer_select || g_rtn ||
                      'FROM (' || g_rtn;

  /* Add the ORDERBY attribute to the SELECT clause to order the results */
  /* by time period start date */
    l_select_clause :=  l_select_clause ||
                       ' ,viewby.start_date     ORDERBY' || g_rtn;

  /* If the TIME and VIEWBY levels are the same */
    IF (l_viewby_level = l_time_level) THEN
    /* Add the TIME condition to the WHERE clause changing it to refer to */
    /* the VIEWBY view instead of the TIME view */
      l_where_clause := l_where_clause ||
                      REPLACE(l_viewby_time_condition,'tim','viewby');
    END IF;

  /* Add the ORDERBY attribute to the GROUP BY clause */
    l_group_by_clause := l_group_by_clause || ' ,viewby.start_date' || g_rtn;

  /* Construct a UNION ALL clause containing all the available time periods */
    l_union_clause := 'UNION ALL'      || g_rtn ||
                      'SELECT' || g_rtn ||
                      '  viewby.value          VIEWBY'  ||
                       l_union_select  || g_rtn ||
                      ' ,viewby.start_date     ORDERBY' || g_rtn ||
                      'FROM'           || g_rtn ||
                      '  ' || l_viewby_view || '   viewby' || g_rtn ||
                      'WHERE 1=1' || g_rtn ||
                       REPLACE(l_viewby_time_condition,'tim','viewby') ||
                      ')' || g_rtn ||
                      'GROUP BY VIEWBY, ORDERBY' || g_rtn;
  /* Move the ORDER BY clause to the outer SELECT statement */
    l_order_by_clause := 'ORDER BY ORDERBY';
  ELSE

  /* Remove the outer select statement */
    l_outer_select := NULL;

  END IF;

/* If the hierarchy parameter is populated */
  IF (l_hierarchy_view IS NOT NULL) THEN

  /* Add the hierarchy view to the FROM clause */
    l_from_clause := l_from_clause ||
                   ' ,' || l_hierarchy_view || l_hierarchy_view_suffix || '   hrchy' || g_rtn;

  /* Add the hierarchy join and condition to the WHERE clause */
    l_where_clause := l_where_clause || l_hierarchy_join || g_rtn ||
                      l_hierarchy_condition;

  END IF;

/* Build query from components */
  l_sql_query := l_outer_select    ||
                 l_select_clause   ||
                 l_from_clause     ||
                 l_where_clause    ||
                 l_group_by_clause ||
                 l_union_clause    ||
                 l_order_by_clause;

/* Return the query */
  RETURN --l_params_header ||
           l_sql_query;

EXCEPTION
 WHEN OTHERS THEN
  IF (ak_region_info_csr%ISOPEN) THEN
    CLOSE ak_region_info_csr;
  END IF;
  RETURN l_params_header ||
         '-- ' || SQLERRM || g_rtn ||
         '-- ' || SQLCODE;
END build_sql_stmt;


/******************************************************************************/
/* This is the procedure which builds up the main SQL statement for no viewby */
/* reports. It is very similar to the build_sql_stmt function                 */
/******************************************************************************/
FUNCTION build_no_viewby_sql_stmt(p_region_code      IN VARCHAR2,
                                  p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
                 RETURN VARCHAR2 IS

/* AK Base Object */
  l_db_object_name        VARCHAR2(30);

/* Variables for SQL query */
  l_sql_query             VARCHAR2(4000);
  l_params_header         VARCHAR2(2000);
  l_select_clause         VARCHAR2(2000);
  l_from_clause           VARCHAR2(2000);
  l_where_clause          VARCHAR2(2000);
  l_order_by_clause       VARCHAR2(2000);

/* Sort order variables */
  l_sort_record_tab       g_sort_record_tabtype;
  l_counter               NUMBER;

/* Cursor returning all AK Region Items for a given region */
  CURSOR ak_region_info_csr IS
  SELECT
   itm.attribute1                   column_type
  ,itm.attribute2                   level_code
  ,lower(itm.attribute3)            column_name
  ,itm.attribute_code               item_code
  ,itm.attribute9                   aggregation
  ,itm.node_display_flag            display_flag
  ,itm.attribute15                  lov_table
  ,itm.attribute4                   lov_where_clause
  ,itm.attribute11                  hrchy_view_override
  ,itm.order_sequence               order_sequence
  ,itm.order_direction              order_direction
  ,lower(reg.database_object_name)  object_name
  FROM
   ak_region_items  itm
  ,ak_regions       reg
  WHERE reg.region_code = p_region_code
  AND reg.region_application_id = 453
  AND itm.region_code = reg.region_code
  AND reg.region_application_id = itm.region_application_id
  ORDER BY itm.display_sequence;

BEGIN

/* Build a SQL header with debug information - all parameters passed in */
/* Initialize the header */
  l_params_header := '-- Parameter Name:   Parameter Value' || g_rtn;

/* Loop through parameters to get the parameter special cases */
  FOR i IN p_params_tbl.first..p_params_tbl.last LOOP
  /* Bug 4633221 */
  IF (p_params_tbl(i).parameter_value = g_all_msg) THEN
  /* Add parameter information to debug header */
    l_params_header := l_params_header || '-- ' ||
                       p_params_tbl(i).parameter_name  || ':  ' ||
                       'All' || g_rtn;
  ELSE
      l_params_header := l_params_header || '-- ' ||
                       p_params_tbl(i).parameter_name  || ':  ' ||
                       p_params_tbl(i).parameter_value || g_rtn;
  END IF;

  END LOOP;

/* Get AK Region Items Information */
  FOR measure_rec IN ak_region_info_csr LOOP

  /* The base view name - same on every cursor row */
    l_db_object_name := measure_rec.object_name;

  /* Build up the select clauses containing all measure columns */
    IF (l_select_clause IS NULL) THEN
      l_select_clause := ' ( fact.' || measure_rec.column_name || ' )   ' || measure_rec.item_code;
    ELSE
      l_select_clause := l_select_clause || g_rtn ||
         ' ,( fact.' || measure_rec.column_name || ' )   ' || measure_rec.item_code;
    END IF;

    /* Check for non-default sort order */
     IF (measure_rec.order_sequence IS NOT NULL) THEN
       l_sort_record_tab(measure_rec.order_sequence).column_name := measure_rec.item_code;
       l_sort_record_tab(measure_rec.order_sequence).sort_direction := measure_rec.order_direction;
     END IF;

  END LOOP;

  l_from_clause := 'FROM ' || l_db_object_name || '  fact';

/* The order by clause is: */
  l_counter := l_sort_record_tab.first;
  IF (l_counter IS NOT NULL) THEN
    WHILE (l_counter IS NOT NULL) LOOP
      IF (l_order_by_clause IS NULL) THEN
        l_order_by_clause := 'ORDER BY ' || l_sort_record_tab(l_counter).column_name ||
                             ' ' || l_sort_record_tab(l_counter).sort_direction;
      ELSE
        l_order_by_clause := 'ORDER BY ' || l_order_by_clause || g_rtn ||
                             ' ,' || l_sort_record_tab(l_counter).column_name ||
                             ' ' || l_sort_record_tab(l_counter).sort_direction;
      END IF;
      l_counter := l_sort_record_tab.next(l_counter);
    END LOOP;
  ELSE
    l_order_by_clause := 'ORDER BY 1';
  END IF;

/* Build query from components */
  l_sql_query := 'SELECT' || g_rtn ||
                  l_select_clause || g_rtn ||
                  l_from_clause || g_rtn ||
                 'WHERE 1=1' || g_rtn ||
                  l_order_by_clause;

/* Return the query */
  RETURN --l_params_header ||
         l_sql_query;

EXCEPTION
 WHEN OTHERS THEN
  IF (ak_region_info_csr%ISOPEN) THEN
    CLOSE ak_region_info_csr;
  END IF;
  RETURN l_params_header ||
         '-- ' || SQLERRM || g_rtn ||
         '-- ' || SQLCODE;
END build_no_viewby_sql_stmt;


/******************************************************************************/
/* This is the procedure which builds up the main SQL statement for a drill   */
/* into report. A parameter table of values is passed into the function, and  */
/* it gets all the information in the AK Region for the report. It combines   */
/* this information to form the SQL query.                                    */
/*                                                                            */
/* Some special cases are also handled by this procedure. The most basic PMV  */
/* reports can be handled generically without referring to specific objects.  */
/* However reports using the time dimension need special treatment. Also in   */
/* the "special" category are hierarchical parameters not yet supported.      */
/******************************************************************************/
FUNCTION build_drill_into_sql_stmt(p_params_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                  ,p_ak_region_code   IN VARCHAR2)
                 RETURN VARCHAR2 IS

/* Loop counter */
  l_counter                   NUMBER;  -- used to go through sort record table

/* Dummy Variable */
  l_dummy                     VARCHAR2(100);  -- Dummy passed into functions

/* Information about HRI_VIEWBY parameter */
  l_actl_drll_frm_vwby        VARCHAR2(60);   -- HRI_VIEWBY level passed in
  l_effct_drll_frm_vwby       VARCHAR2(60);   -- Effective HRI_VIEWBY level
  l_hri_viewby_id             VARCHAR2(60);   -- Parameter_id of viewby

/* Information about ORDERBY parameter */
  l_orderby_column            VARCHAR2(1000);   -- column passed in to order by

/* Information about VIEWBY object */
  l_viewby_view               VARCHAR2(30);   -- view name of viewby view
  l_viewby_level              VARCHAR2(60);   -- viewby DIMENSION+LEVEL name
  l_viewby_col                VARCHAR2(30);   -- fact column joins to viewby id
  l_viewby_select             VARCHAR2(2000); -- doctored viewby display column

/* Information about TIME object */
  l_time_view                 VARCHAR2(60);  -- view name of time view
  l_time_level                VARCHAR2(60);  -- time DIMENSION+LEVEL name
  l_time_col                  VARCHAR2(60);  -- fact column joins to time level
  l_time_from_date            DATE;          -- time from period start date
  l_time_to_date              DATE;          -- time to period end date
  l_report_start_date         DATE;          -- report date - period type
  l_report_date               DATE;          -- report date to
  l_time_condition            VARCHAR2(500); -- time condition on fact view

/* Information about hierarchy object */
  l_hierarchy_view            VARCHAR2(60);  -- view name of hierarchy object
  l_hierarchy_view_suffix     VARCHAR2(60);  -- "_X_V" current "_V" historic
  l_hierarchy_col             VARCHAR2(60);  -- fact column joins to hierarchy
  l_hierarchy_level           VARCHAR2(30);  -- hierarchy DIMENSION+LEVEL name
  l_hierarchy_join            VARCHAR2(500); -- hierarchy - fact join condition
  l_hierarchy_condition       VARCHAR2(500); -- include top node condition
  l_hierarchy_order_by        VARCHAR2(500); -- orders by top node first
  l_fact_col_hrchy            VARCHAR2(30);  -- fact column joining to hierarchy

/* AK Base Objects */
  l_db_object_name            VARCHAR2(30);  -- Database object from AK Object

/* Variables for SQL query */
  l_sql_query                 VARCHAR2(4000); -- holds SQL to return
  l_params_header             VARCHAR2(2000); -- debug output header
  l_select_clause             VARCHAR2(2000); -- main SELECT
  l_from_clause               VARCHAR2(2000); -- main FROM
  l_where_clause              VARCHAR2(2000); -- main WHERE
  l_order_by_clause           VARCHAR2(2000); -- main ORDER BY
  l_sort_record_tab           g_sort_record_tabtype; -- allows alternative sort

/* Cursor returning all AK Region Items for a given region */
  CURSOR ak_region_info_csr IS
  SELECT
   reg.region_code                  region_code
  ,itm.attribute1                   column_type
  ,itm.attribute2                   level_code
  ,lower(itm.attribute3)            column_name
  ,itm.attribute_code               item_code
  ,itm.attribute9                   aggregation
  ,itm.node_display_flag            display_flag
  ,itm.attribute15                  lov_table
  ,itm.attribute4                   lov_where_clause
  ,itm.attribute11                  hrchy_view_override
  ,itm.order_sequence               order_sequence
  ,itm.order_direction              order_direction
  ,itm.attribute14                  column_datatype
  ,lower(reg.database_object_name)  object_name
  ,reg.attribute11                  region_where_clause
  ,itm.display_sequence             display_sequence
  FROM
   ak_region_items  itm
  ,ak_regions       reg
  WHERE reg.region_code = p_ak_region_code
  AND reg.region_application_id = 453
  AND itm.region_code = reg.region_code
  AND reg.region_application_id = itm.region_application_id
/* Must have hidden parameters first so that hierarchy can be extracted */
/* before other parts of the sql statement are built up. Also depending */
/* on HRI_PERIOD_TYPE dimension being extracted before HRI_REPORT_DATE */
/* which is done by the second order by column */
/* Must have hidden parameters first so that hierarchy can be extracted */
/* before other parts of the sql statement are built up. */
/* Calculated measures must be returned after view column measures */
/* which is done by the 3rd column
/* Also depending on HRI_PERIOD_TYPE dimension being extracted before */
/* HRI_REPORT_DATE which is done by the last order by column */
  ORDER BY DECODE(itm.attribute1,
                    'HIDE PARAMETER', 1,
                    'HIDE VIEW BY DIMENSION', 2,
                  3)
  ,DECODE(SUBSTR(itm.attribute_code,1,12),
             'HRI_P_HIERAR',1,
             'HRI_P_VIEWBY',2,
           3)
  ,DECODE(SUBSTR(itm.attribute3,1,1),'"',2,1)
  ,itm.display_sequence;
  -- cbridge removed for bug 3919506 -- ,itm.attribute2;

BEGIN

/******************************************************************************/
/* LOCAL VARIABLE INITIALIZATION */
/*********************************/

/* Initialize the HRI_VIEWBY level variables */
  l_actl_drll_frm_vwby  := 'NONE';
  l_effct_drll_frm_vwby := 'NONE';

/* Default the viewby select column so that if */
/* the value is null a "no value" label is displayed */
  l_viewby_select :=
            '  DECODE(viewby.id, ' || g_rtn ||
            '           ''-1'', ''' || g_temp_no_value || ''',' || g_rtn ||
            '           ''NA_EDW'',''' || g_temp_no_value || ''',' || g_rtn ||
            '         viewby.value)          VIEWBY';

/* Build a SQL header with debug information - all parameters passed in */
/* Initialize the header */
  l_params_header := '-- AK REGION: ' || p_ak_region_code || g_rtn ||
                     '-- Parameter Name:   Parameter Value' || g_rtn;


/******************************************************************************/
/* PARAMETER TABLE LOOP 1 - GET VIEWBY/TIME PARAMETERS */
/*******************************************************/

/* Loop through parameters to get the parameter special cases */
  FOR i IN p_params_tbl.first..p_params_tbl.last LOOP
  /*Bug 4633221 */
  IF (p_params_tbl(i).parameter_value = g_all_msg) THEN
  /* Add parameter information to debug header */
    l_params_header := l_params_header || '-- ' ||
                       p_params_tbl(i).parameter_name  || ':  ' ||
                       'All' || g_rtn;
  ELSE
    l_params_header := l_params_header || '-- ' ||
                       p_params_tbl(i).parameter_name  || ':  ' ||
                       p_params_tbl(i).parameter_value || g_rtn;
  END IF;

  /* Retrieve information parameter special cases */
  /* Pull out information about the VIEWBY dimension */
    IF (p_params_tbl(i).parameter_name = 'VIEW_BY') THEN
    /* Get the viewby view from the dimension metadata (may be null) */
      l_viewby_view := get_level_view_name(p_params_tbl(i).parameter_value);
    /* Record the viewby DIMENSION+LEVEL name */
      l_viewby_level  := p_params_tbl(i).parameter_value;

  /* Pull out information about the ORDERBY object */
    ELSIF (p_params_tbl(i).parameter_name = 'ORDERBY') THEN
      l_orderby_column := p_params_tbl(i).parameter_value;

  /* Pull out information about the TIME dimension */
    ELSIF (substr(p_params_tbl(i).parameter_name,1,4) = 'TIME') THEN
      IF substr(p_params_tbl(i).parameter_name,-5,5)='_FROM' THEN
      /* Get the start date */
        l_time_from_date     := p_params_tbl(i).period_date;
      ELSIF substr(p_params_tbl(i).parameter_name,-3,3)='_TO' THEN
      /* Get the end date */
        l_time_to_date       := p_params_tbl(i).period_date;
      END IF;

  /* Pull out information about the TIME dimension level */
    ELSIF (p_params_tbl(i).parameter_name = 'PERIOD_TYPE') THEN
      l_time_level  := 'TIME+' || p_params_tbl(i).parameter_value;

  /* Pull out information about the HRI REPORT DATE dimension */
    ELSIF (p_params_tbl(i).parameter_name = 'HRI_NO_JOIN_DATE+HRI_REPORT_DATE') THEN
      l_report_date := p_params_tbl(i).period_date;

  /* Pull out information about the HRI PERIOD TYPE dimension */
    ELSIF (p_params_tbl(i).parameter_name =
                   'HRI_NO_JOIN_PERIOD+HRI_PERIOD_TYPE') THEN
    /* Set the report start date as l_report_date - l_period type */
      IF (p_params_tbl(i).parameter_id = '''Y''') THEN
        l_report_start_date := add_months(l_report_date, -12);
      ELSIF (p_params_tbl(i).parameter_id = '''Q''') THEN
        l_report_start_date := add_months(l_report_date, -3);
      ELSIF (p_params_tbl(i).parameter_id = '''CM''') THEN
        l_report_start_date := add_months(l_report_date, -1);
      END IF;
  /* Pull out information about the Hierarchy Viewby */
    ELSIF (substr(p_params_tbl(i).parameter_name,1,10) = 'HRI_VIEWBY'
           AND p_params_tbl(i).parameter_id IS NOT NULL) -- bug 4566643
         THEN
      l_actl_drll_frm_vwby  := p_params_tbl(i).parameter_name;
      l_effct_drll_frm_vwby := p_params_tbl(i).parameter_name;
      l_hri_viewby_id := p_params_tbl(i).parameter_id;
  /* Get the indicator corresponding to the column drilled from */
    ELSIF (p_params_tbl(i).parameter_name =  'HRI_INDICATOR_COL') THEN
      l_where_clause := 'AND fact.' || p_params_tbl(i).parameter_value ||
                        ' = 1' || g_rtn;
    END IF;

  END LOOP;


/******************************************************************************/
/* AK Region Loop - Builds up SQL Statement */
/********************************************/

/* Get AK Region Items Information */
  FOR measure_rec IN ak_region_info_csr LOOP

  /******************/
  /* Current Region */
  /******************/
  /* The base view name - same on every cursor row */
    IF (l_db_object_name IS NULL) THEN
      l_db_object_name := measure_rec.object_name;
    /* 115.1 - add the region where clause only if there is one defined */
      IF (measure_rec.region_where_clause IS NOT NULL) THEN
        l_where_clause := l_where_clause ||
                          measure_rec.region_where_clause || g_rtn;
      END IF;
    END IF;

  /* Display columns - Measures */
    IF (measure_rec.column_type = 'MEASURE' OR
        measure_rec.column_type IS NULL) THEN
    /* Ignore measures which are calculated AK Region Items */
      IF (SUBSTR(measure_rec.column_name,1,1) <> '"') THEN
      /* Check for non-default sort order */
        IF (measure_rec.order_sequence IS NOT NULL) THEN
          l_sort_record_tab(measure_rec.order_sequence).column_name :=
               measure_rec.item_code;
          l_sort_record_tab(measure_rec.order_sequence).sort_direction :=
               measure_rec.order_direction;
        END IF;
      /* SELECT CLAUSE BUILD - add all non AK calculated measure columns */
        IF (measure_rec.column_datatype = 'C') THEN
          l_select_clause := l_select_clause || g_rtn ||
             ' ,' || measure_rec.aggregation || '(fact.' ||
             measure_rec.column_name || ')     ' || measure_rec.item_code;
        ELSE
          l_select_clause := l_select_clause || g_rtn ||
             ' ,' || measure_rec.aggregation || '( to_char(fact.' ||
             measure_rec.column_name || '))     ' || measure_rec.item_code;
        END IF;
      END IF;

  /* Hierarchy Item / Report Date / Time / Viewby / Dimension */
    ELSE
    /* HRI_P_HIERARCHY item will crop up first as the cursor */
    /* is ordered to return HIDE PARAMETER items first */
      IF (measure_rec.item_code = 'HRI_P_HIERARCHY') THEN
      /* Store fact column which joins to hierarchy */
        l_fact_col_hrchy := measure_rec.column_name;
        IF (l_actl_drll_frm_vwby <> 'HRI_VIEWBY_ORGH+HRI_ALL_INC' AND
            l_actl_drll_frm_vwby <> 'HRI_VIEWBY_SUPH+HRI_ALL_INC') THEN
        /* Get (hard coded) hierarchy details */
          get_hierarchy_details
            (p_ak_level_code => measure_rec.level_code,
             p_hierarchy_view => l_hierarchy_view,
             p_hierarchy_view_suffix => l_hierarchy_view_suffix,
             p_hierarchy_level => l_hierarchy_level,
             p_hierarchy_col => l_hierarchy_col);
        /* Start building up the hierarchy join using the fact column */
          l_hierarchy_join := 'AND fact.' || measure_rec.column_name ||
                              ' = hrchy.' || g_sub_prefix || l_hierarchy_col;
        END IF;
    /* Time Dimension */
      ELSIF (l_time_level = measure_rec.level_code) THEN
        IF (l_time_from_date IS NOT NULL) THEN
          l_time_condition := l_time_condition ||
        'AND fact.' || measure_rec.column_name || ' >= to_date(''' ||
        to_char(l_time_from_date,'DD-MM-YYYY') || ''',''DD-MM-YYYY'')' || g_rtn;
        END IF;
        IF (l_time_to_date IS NOT NULL) THEN
          l_time_condition := l_time_condition ||
          'AND fact.' || measure_rec.column_name || ' <= to_date(''' ||
          to_char(l_time_to_date,'DD-MM-YYYY') || ''',''DD-MM-YYYY'')' || g_rtn;
        END IF;
     /* Viewby Dimension */
      ELSIF (l_viewby_level = measure_rec.level_code) THEN
      /* If an LOV Table has been specified, override the viewby view */
        l_viewby_view := NVL(measure_rec.lov_table, l_viewby_view);
      /* Get the fact column to join to the viewby view */
        l_viewby_col := measure_rec.column_name;
      /* Check the viewby special cases - HIERARCHYs */
        IF (SUBSTR(l_viewby_level,1,10) = 'HRI_VIEWBY') THEN
          get_viewby_hierarchy_details
             (p_viewby_level_code => l_viewby_level,
              p_hierarchy_col => l_hierarchy_col,
              p_hierarchy_level => l_hierarchy_level,
              p_hierarchy_join => l_hierarchy_join,
              p_hierarchy_view_suffix => l_hierarchy_view_suffix,
              p_viewby_col => l_viewby_col,
              p_viewby_select => l_viewby_select,
              p_hierarchy_condition => l_hierarchy_condition,
              p_order_by_clause => l_order_by_clause,
              p_group_by_clause => l_dummy);
        END IF;

      ELSE -- Other Dimension (Not HRI_P_HIERARCHY, TIME or VIEWBY parameter)

      /*******************************************************/
      /* PARAMETER TABLE LOOP 2 - Match Dimension Parameters */
      /*******************************************************/
        FOR i IN p_params_tbl.first..p_params_tbl.last LOOP
        /* If the parameter is a dimension level with values selected */
        /* then add it to the WHERE clause */
          IF (p_params_tbl(i).parameter_name = measure_rec.level_code AND
              p_params_tbl(i).parameter_value <> 'All' AND
        /* Bug 4633221 */
              p_params_tbl(i).parameter_value <> g_all_msg AND
              p_params_tbl(i).parameter_value IS NOT NULL AND
              measure_rec.column_name IS NOT NULL AND
              SUBSTR(p_params_tbl(i).parameter_name,1,11) <> 'HRI_NO_JOIN') THEN
          /* WHERE CLAUSE BUILD - Simple Dimension Parameter Value */
          /* Bug 2702283 - Put hierarchy related conditions in l_hierarchy_condition */
            IF (INSTR(measure_rec.column_name,'.') > 0) THEN
            /* If the drill is from the top level directs rollup */
              IF ((l_actl_drll_frm_vwby = 'HRI_VIEWBY_ORGH+HRI_DRCTS_ROLLUP_INC' OR
                   l_actl_drll_frm_vwby = 'HRI_VIEWBY_SUPH+HRI_DRCTS_ROLLUP_INC') AND
                   p_params_tbl(i).parameter_id = l_hri_viewby_id) THEN
              /* Switch the effective mode to "No Rollup Include Subs" */
                l_effct_drll_frm_vwby := SUBSTR(l_actl_drll_frm_vwby,1,16) || 'HRI_ALL_INC';
              /* Dump the hierarchy */
                l_hierarchy_view := NULL;
              END IF;
              IF (l_effct_drll_frm_vwby = 'HRI_VIEWBY_ORGH+HRI_ALL_INC' AND
                  SUBSTR(p_params_tbl(i).parameter_name,1,12) = 'ORGANIZATION')
              THEN
                IF (l_hierarchy_view IS NULL) THEN
                  l_where_clause := l_where_clause ||
                   'AND fact.' || l_fact_col_hrchy ||
                   ' IN (&' || l_actl_drll_frm_vwby || ')' || g_rtn;
                ELSE
                  l_where_clause := l_where_clause ||
                         'AND ' || measure_rec.column_name ||
                         ' IN (&' || l_actl_drll_frm_vwby || ')' || g_rtn;
                END IF;
              ELSIF (l_effct_drll_frm_vwby = 'HRI_VIEWBY_ORGH+HRI_DRCTS_ROLLUP_INC' AND
                  SUBSTR(p_params_tbl(i).parameter_name,1,12) = 'ORGANIZATION')
              THEN
                l_hierarchy_condition := l_hierarchy_condition ||
                       'AND ' || measure_rec.column_name ||
                       ' IN (&' || l_actl_drll_frm_vwby || ')' || g_rtn;
              ELSIF (l_effct_drll_frm_vwby = 'HRI_VIEWBY_SUPH+HRI_ALL_INC' AND
                  SUBSTR(p_params_tbl(i).parameter_name,1,10) = 'HRI_PERSON')
              THEN
                IF (l_hierarchy_view IS NULL) THEN
                  l_where_clause := l_where_clause ||
                   'AND fact.' || l_fact_col_hrchy ||
                   ' IN (&' || l_actl_drll_frm_vwby || ')' || g_rtn;
                ELSE
                  l_where_clause := l_where_clause ||
                         'AND ' || measure_rec.column_name ||
                         ' IN (&' || l_actl_drll_frm_vwby || ')' || g_rtn;
                END IF;
              ELSIF (l_effct_drll_frm_vwby = 'HRI_VIEWBY_SUPH+HRI_DRCTS_ROLLUP_INC' AND
                  SUBSTR(p_params_tbl(i).parameter_name,1,10) = 'HRI_PERSON')
              THEN
                l_hierarchy_condition := l_hierarchy_condition ||
                       'AND ' || measure_rec.column_name ||
                       ' IN (&' || l_actl_drll_frm_vwby || ')' || g_rtn;
              ELSIF (l_effct_drll_frm_vwby <> 'HRI_VIEWBY_ORGH+HRI_ALL_INC' AND
                     l_effct_drll_frm_vwby <> 'HRI_VIEWBY_SUPH+HRI_ALL_INC') THEN
                l_hierarchy_condition := l_hierarchy_condition ||
                   'AND ' || measure_rec.column_name ||
                  ' IN (&' || p_params_tbl(i).parameter_name || ')' || g_rtn;
              END IF;
            ELSE
              l_where_clause := l_where_clause ||
                     'AND fact.' || measure_rec.column_name ||
                     ' IN (&' || p_params_tbl(i).parameter_name || ')' || g_rtn;
            END IF;

          END IF;

        END LOOP; -- Parameter Table

      END IF;

    END IF; -- Current Region Measure or Dimension

  END LOOP; -- AK Region Items

/******************************************************************************/
/* BUILD UP SQL STATEMENT */
/**************************/

/* The SELECT clause always picks a VIEWBY column and the list of measure */
/* columns already built up */
  l_select_clause :=  'SELECT'                           || g_rtn ||
                       l_viewby_select                   ||
                       l_select_clause                   || g_rtn;

/* The FROM clause always picks the database object from the AK region and */
/* the list of values view for the VIEWBY level */
  l_from_clause :=    'FROM' || g_rtn ||
                      '  '   || l_db_object_name || '   fact'   || g_rtn ||
                      ' ,'   || l_viewby_view    || '   viewby' || g_rtn ||
                       l_from_clause;

/* The WHERE clause always has the VIEWBY join condition and any */
/* conditions already built up from the parameter values */
  IF (INSTR(l_viewby_col,'.') > 0) THEN
    l_where_clause :=   'WHERE viewby.id = ' || l_viewby_col || g_rtn ||
                         l_where_clause;
  ELSE
    l_where_clause :=   'WHERE viewby.id = fact.' || l_viewby_col || g_rtn ||
                         l_where_clause;
  END IF;

/* Add reporting date condition to where clause if relevant */
  IF (l_report_start_date IS NOT NULL) THEN
    l_where_clause := l_where_clause ||
      'AND ' || l_time_col ||
      ' BETWEEN to_date(''' || to_char(l_report_start_date,'DD-MM-YYYY') ||
      ''',''DD-MM-YYYY'') AND to_date(''' || to_char(l_report_date,'DD-MM-YYYY')
   || ''',''DD-MM-YYYY'')' || g_rtn;
  END IF;

/* Unless the VIEWBY is time, the order by clause is: */
  l_counter := l_sort_record_tab.first;
/* If there is no sort order passed in parameters */
  IF (l_orderby_column IS NULL) THEN

  /* If there is a sort order defined on the region */
    IF (l_counter IS NOT NULL) THEN
    /* Populate order by clause with the stored sort columns */
      WHILE (l_counter IS NOT NULL) LOOP
        IF (l_order_by_clause IS NULL) THEN
          l_order_by_clause := l_sort_record_tab(l_counter).column_name ||
                               ' ' || l_sort_record_tab(l_counter).sort_direction;
        ELSE
          l_order_by_clause := l_order_by_clause || g_rtn ||
                               ' ,' || l_sort_record_tab(l_counter).column_name ||
                               ' ' || l_sort_record_tab(l_counter).sort_direction;
        END IF;
        l_counter := l_sort_record_tab.next(l_counter);
      END LOOP;
      l_order_by_clause := 'ORDER BY' || g_rtn || l_order_by_clause;
    ELSE -- No sort order defined on region
      IF (l_order_by_clause IS NULL) THEN
        l_order_by_clause := 'ORDER BY viewby.value';
      ELSE
        l_order_by_clause := 'ORDER BY ' || l_order_by_clause || g_rtn ||
                             ' ,viewby.value';
      END IF;
    END IF;

  ELSE -- Sort order passed in parameter table

    IF (l_order_by_clause IS NOT NULL) THEN
      l_order_by_clause := 'ORDER BY ' || l_order_by_clause || g_rtn ||
                           ' ,' || l_orderby_column || g_rtn ||
                           ' ,viewby.value';
    ELSE
      l_order_by_clause := 'ORDER BY ' || l_orderby_column || g_rtn ||
                           ' ,viewby.value';
    END IF;

  END IF;

/* Alter above clauses depending on parameters selected */
/* If the query is restricted by the time parameter, and the TIME level is */
/* different to the VIEWBY level */
  IF (l_time_condition IS NOT NULL) THEN
    l_where_clause :=  l_where_clause || l_time_condition;
  END IF;

/* If the hierarchy parameter is populated */
  IF (l_hierarchy_view IS NOT NULL) THEN

  /* Add the hierarchy view to the FROM clause */
    l_from_clause := l_from_clause ||
                   ' ,' || l_hierarchy_view || l_hierarchy_view_suffix || '   hrchy' || g_rtn;

  /* Add the hierarchy join and condition to the WHERE clause */
    l_where_clause := l_where_clause || l_hierarchy_join || g_rtn ||
                      l_hierarchy_condition;

  END IF;

/* Build query from components */
  l_sql_query := l_select_clause   ||
                 l_from_clause     ||
                 l_where_clause    ||
                 l_order_by_clause;

/* Return the query */
  RETURN -- l_params_header ||
          l_sql_query;

EXCEPTION
 WHEN OTHERS THEN
  IF (ak_region_info_csr%ISOPEN) THEN
    CLOSE ak_region_info_csr;
  END IF;
  RETURN l_params_header ||
         '-- ' || SQLERRM || g_rtn ||
         '-- ' || SQLCODE;
END build_drill_into_sql_stmt;

/******************************************************************************/
/* Builds a SQL header to help identify the SQL start                         */
/******************************************************************************/
FUNCTION make_sql_header RETURN VARCHAR2 IS

  l_sql_header   VARCHAR2(500);

BEGIN

  l_sql_header :=  '-- '                                      || g_rtn ||
                   '-- /****************************************/' || g_rtn ||
                   '-- /* Start of SQL Statement               */' || g_rtn ||
                   '-- /* Generated by HRI_OLTP_PMV_DYNSQLGEN  */' || g_rtn ||
                   '-- /***************************************/' || g_rtn ||
                   '-- ';

  RETURN l_sql_header;

END make_sql_header;

/******************************************************************************/
/* Builds a SQL footer to help identify the SQL end                           */
/******************************************************************************/
FUNCTION make_sql_footer RETURN VARCHAR2 IS

  l_sql_footer   VARCHAR2(500);

BEGIN

  l_sql_footer :=  '-- '                                || g_rtn ||
                   '-- /*****************************/' || g_rtn ||
                   '-- /* End of SQL Statement      */' || g_rtn ||
                   '-- /*****************************/' || g_rtn ||
                   '-- ';

  RETURN l_sql_footer;

END make_sql_footer;


/******************************************************************************/
/*                  PUBLIC Procdures and Functions                            */
/******************************************************************************/

/******************************************************************************/
/* Main function which inputs the parameters and the query AK Region and      */
/* dynamically builds the SQL statement which forms the basis of the query.   */
/******************************************************************************/
FUNCTION get_query(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
                   p_ak_region_code   IN VARCHAR2)
                  return varchar2 IS

  l_sql_text          VARCHAR2(4000);
  l_sql_header        VARCHAR2(500);
  l_sql_query         VARCHAR2(4000);
  l_sql_footer        VARCHAR2(500);

BEGIN

  l_sql_query  := build_sql_stmt(p_ak_region_code, p_params_tbl);
  l_sql_header := make_sql_header;
  l_sql_footer := make_sql_footer;
  l_sql_text   := l_sql_header || g_rtn || l_sql_query || g_rtn || l_sql_footer;

  RETURN l_sql_text;

EXCEPTION
/* On error return the Error Message and Error Code */
 WHEN OTHERS THEN
   RETURN  '-- ' || SQLERRM || g_rtn ||
           '-- ' || SQLCODE;
END get_query;

/******************************************************************************/
/* Main function which inputs the parameters and the query AK Region and      */
/* dynamically builds the SQL statement which forms the basis of the query.   */
/******************************************************************************/
FUNCTION get_no_viewby_query(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_ak_region_code   IN VARCHAR2)
                  return varchar2 IS

  l_sql_text          VARCHAR2(4000);
  l_sql_header        VARCHAR2(500);
  l_sql_query         VARCHAR2(4000);
  l_sql_footer        VARCHAR2(500);

BEGIN

  l_sql_query  := build_no_viewby_sql_stmt(p_ak_region_code, p_params_tbl);
  l_sql_header := make_sql_header;
  l_sql_footer := make_sql_footer;
  l_sql_text   := l_sql_header || g_rtn || l_sql_query || g_rtn || l_sql_footer;

  RETURN l_sql_text;

EXCEPTION
/* On error return the Error Message and Error Code */
 WHEN OTHERS THEN
   RETURN  '-- ' || SQLERRM || g_rtn ||
           '-- ' || SQLCODE;
END get_no_viewby_query;

/******************************************************************************/
/* Main function which inputs the parameters and the query AK Region and      */
/* dynamically builds the SQL statement which forms the basis of the query.   */
/******************************************************************************/
FUNCTION get_drill_into_query(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
                              p_ak_region_code   IN VARCHAR2)
                  return varchar2 IS

  l_sql_text          VARCHAR2(4000);
  l_sql_header        VARCHAR2(500);
  l_sql_query         VARCHAR2(4000);
  l_sql_footer        VARCHAR2(500);

BEGIN

  l_sql_query  := build_drill_into_sql_stmt(p_params_tbl,p_ak_region_code);
  l_sql_header := make_sql_header;
  l_sql_footer := make_sql_footer;
  l_sql_text   := l_sql_header || g_rtn ||
                    '-- Made by drill into query' || g_rtn ||
                    l_sql_query || g_rtn ||
                    l_sql_footer;

  RETURN l_sql_text;

EXCEPTION
/* On error return the Error Message and Error Code */
 WHEN OTHERS THEN
   RETURN  '-- ' || SQLERRM || g_rtn ||
           '-- ' || SQLCODE;
END get_drill_into_query;

END HRI_OLTP_PMV_DYNSQLGEN;

/
