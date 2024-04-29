--------------------------------------------------------
--  DDL for Package Body HRI_BPL_DATA_SETUP_DGNSTC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_DATA_SETUP_DGNSTC" AS
/* $Header: hribdgdp.pkb 120.9 2006/12/13 05:44:45 msinghai noship $ */

-- =========================================================================
--
-- OVERVIEW
-- --------
-- This package contains the procedure to test the data setup for DBI.
-- The checks that are included in the seeded diagnostics table are
-- performed
--
-- DOCUMENT REFERENCE
-- ------------------
-- http://files.oraclecorp.com/content/AllPublic/SharedFolders/HRMS%20
-- Intelligence%20(HRMSi)%20-%20Documents-Public/Design%20Specifications/
-- hri_lld_dgn_data_stup.doc
--
-- =========================================================================

TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(240)
                            INDEX BY BINARY_INTEGER;
g_object_name          VARCHAR2(100);

-- ----------------------------------------------------------------------------
-- PROCEDURE output writes a message to the concurrent log
-- ----------------------------------------------------------------------------
PROCEDURE output(p_text  IN VARCHAR2) IS

BEGIN

  hri_bpl_conc_log.output(p_text);

END output;

-- ----------------------------------------------------------------------------
-- PROCEDURE trim_msg removes blank spaces and enter characters from the string
--
-- INPUT PARAMETERS:
--          p_text: The text that has to be trimmed
-- ----------------------------------------------------------------------------
FUNCTION trim_msg(p_text IN VARCHAR2) RETURN VARCHAR2 IS

  l_text VARCHAR2(20000);

BEGIN

  -- Remove blank spaces
  l_text := TRIM(both ' ' FROM p_text);

  -- Remove Enter characters
  l_text := TRIM(both fnd_global.local_chr(10) FROM l_text);

  RETURN l_text;

END trim_msg;

-- ----------------------------------------------------------------------------
-- Function GET_MESSAGE takes the message name and returns back the
-- message text
--
-- INPUT PARAMETERS:
--       p_message: Name of the message.
--
-- ----------------------------------------------------------------------------
FUNCTION get_message(p_message IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN

  IF p_message IS NULL THEN
    RETURN NULL;
  END IF;

  fnd_message.set_name('HRI', p_message);
  --
   IF HRI_BPL_SETUP_DIAGNOSTIC.is_token_exist(p_message,'PRODUCT_NAME') THEN
    --
    fnd_message.set_token('PRODUCT_NAME'
                          ,HRI_BPL_SETUP_DIAGNOSTIC.get_product_name(p_object_name => g_object_name));
    --
  END IF;
  --
  RETURN trim_msg(fnd_message.get);

END get_message;

-- ----------------------------------------------------------------------------
-- Debugs a given supervisor loop
-- ----------------------------------------------------------------------------
PROCEDURE debug_sup_loop
     (p_person_id       IN NUMBER,
      p_effective_date  IN DATE,
      p_loop_tab        OUT NOCOPY loop_results_tab_type) IS

  CURSOR sup_csr(p_psn_id   NUMBER,
                 p_date     DATE) IS
  SELECT
   sub.full_name       sub_person_name
  ,NVL(sub.employee_number, sub.npw_number)
                       sub_emp_cwk_number
  ,sup.full_name       sup_person_name
  ,NVL(sup.employee_number, sup.npw_number)
                       sup_emp_cwk_number
  ,assg.supervisor_id  supervisor_id
  FROM
   per_all_assignments_f        assg
  ,per_assignment_status_types  ast
  ,per_people_x                 sup
  ,per_people_x                 sub
  WHERE assg.person_id = p_psn_id
  AND p_date BETWEEN assg.effective_start_date
             AND assg.effective_end_date
  AND assg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status <> 'TERM_ASSIGN'
  AND assg.primary_flag = 'Y'
  AND assg.assignment_type IN ('E','C')
  AND assg.person_id = sub.person_id
  AND assg.supervisor_id = sup.person_id;

  l_loop_tab            loop_results_tab_type;
  l_loop_rec            loop_results_rec_type;
  l_sup_cache           g_varchar2_tab_type;
  exit_loop             BOOLEAN;
  l_person_id           NUMBER;
  l_supervisor_id       NUMBER;
  l_index               PLS_INTEGER;

BEGIN

  -- Loop variable - will be set to true when a loop is encountered
  --                 or when the end of the supervisor chains is reached
  exit_loop := FALSE;

  -- Person to sample manager of
  l_person_id := p_person_id;

  -- Update cache for encountering this person
  l_sup_cache(l_person_id) := 'Y';

  -- Number of records in loop table
  l_index := 0;

  -- Loop through supervisor levels
  WHILE NOT exit_loop LOOP

    -- Fetch supervisor details for current person
    OPEN sup_csr(l_person_id, p_effective_date);
    FETCH sup_csr INTO
      l_loop_rec.person_name,
      l_loop_rec.person_number,
      l_loop_rec.supervisor_name,
      l_loop_rec.supervisor_number,
      l_supervisor_id;

    -- Set next person id
    IF (sup_csr%NOTFOUND OR sup_csr%NOTFOUND IS NULL) THEN
      l_person_id := NULL;
    ELSE
      l_person_id := l_supervisor_id;
      l_index := l_index + 1;
      l_loop_tab(l_index) := l_loop_rec;
    END IF;

    CLOSE sup_csr;

    BEGIN
      -- Exit loop if no supervisor or a repeated supervisor
      IF (l_person_id IS NULL) THEN
        exit_loop := TRUE;
      ELSIF (l_sup_cache(l_person_id) = 'Y') THEN
        exit_loop := TRUE;
      ELSE
        RAISE NO_DATA_FOUND;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      l_sup_cache(l_person_id) := 'Y';
    END;

  END LOOP;

  -- Output loop results
  p_loop_tab := l_loop_tab;

END debug_sup_loop;

-- ----------------------------------------------------------------------------
-- Function returning the dynamic sql for the diagnostic
-- ----------------------------------------------------------------------------
FUNCTION get_dynamic_sql(p_dyn_sql_type   IN VARCHAR2,
                         p_dyn_sql        IN VARCHAR2)
            RETURN VARCHAR2 IS

  l_sql_string    VARCHAR2(32000);
  l_sql_stmt      VARCHAR2(32000);

BEGIN

  -- Check the sql type
  IF (p_dyn_sql_type = 'API') THEN

    l_sql_stmt := 'SELECT ' || p_dyn_sql || ' FROM dual';

    BEGIN
      EXECUTE IMMEDIATE l_sql_stmt INTO l_sql_string;
    EXCEPTION WHEN OTHERS THEN
      output('Error executing:  ' || l_sql_stmt);
      RAISE;
    END;

  ELSE

    l_sql_string := p_dyn_sql;

  END IF;

  RETURN l_sql_string;

END get_dynamic_sql;

-- ----------------------------------------------------------------------------
-- PROCEDURE set_bind_variables is used to set the bind variables that are
-- passed present in the dynamic sql.
-- ----------------------------------------------------------------------------
FUNCTION set_bind_variables(p_dyn_sql      IN VARCHAR2,
                            p_start_date   IN DATE DEFAULT NULL,
                            p_end_date     IN DATE DEFAULT NULL,
                            p_obj_name     IN VARCHAR2 DEFAULT NULL)
           RETURN VARCHAR2 IS

  l_start_date    VARCHAR2(80);
  l_end_date      VARCHAR2(80);
  l_dyn_sql       VARCHAR2(32000);

BEGIN

  l_start_date := 'to_date(''' || to_char(p_start_date, 'DD/MM/YYYY') ||
                           ''',''DD/MM/YYYY'')';
  l_end_date := 'to_date(''' || to_char(p_end_date, 'DD/MM/YYYY') ||
                         ''',''DD/MM/YYYY'')';

  l_dyn_sql := p_dyn_sql;
  l_dyn_sql := replace(l_dyn_sql,':p_start_date', l_start_date);
  l_dyn_sql := replace(l_dyn_sql,':p_end_date',   l_end_date);
  l_dyn_sql := replace(l_dyn_sql,':p_obj_name',  '''' || p_obj_name || '''');
  l_dyn_sql := replace(l_dyn_sql,':p_non_null',  '''x''');

  RETURN l_dyn_sql;

END set_bind_variables;

-- ----------------------------------------------------------------------------
-- Runs a data diagnostic
-- ----------------------------------------------------------------------------
PROCEDURE run_diagnostic
     (p_object_name   IN VARCHAR2,
      p_object_type   IN VARCHAR2,
      p_mode          IN VARCHAR2,
      p_start_date    IN DATE,
      p_end_date      IN DATE,
      p_row_limit     IN PLS_INTEGER,
      p_results_tab   OUT NOCOPY data_results_tab_type,
      p_impact        OUT NOCOPY BOOLEAN,
      p_impact_msg    OUT NOCOPY VARCHAR2,
      p_doc_links_url OUT NOCOPY VARCHAR2,
      p_sql_stmt      OUT NOCOPY VARCHAR2) IS

  -- Cursor to get the diagnostic details
  CURSOR diagnostic_csr IS
  SELECT
   stp.dynamic_sql
  ,stp.dynamic_sql_type
  ,stp.report_type
  ,stp.default_mode
  ,stp.impact_msg_name
  FROM
   hri_adm_dgnstc_setup  stp
  WHERE stp.object_name = p_object_name
  AND stp.object_type = p_object_type;

  -- Reference type cursor is used in Detail mode
  TYPE ref_cursor_type   IS REF CURSOR;
  c_records              ref_cursor_type;

  -- Column of results type
  TYPE col_tab_type IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

  -- Tables for results
  l_results_tab     data_results_tab_type;
  l_col1_tab        col_tab_type;
  l_col2_tab        col_tab_type;
  l_col3_tab        col_tab_type;
  l_col4_tab        col_tab_type;
  l_col5_tab        col_tab_type;

  l_row_limit       PLS_INTEGER;
  l_sql_stmt        VARCHAR2(32000);
  l_order_by_pos    PLS_INTEGER;
  l_count           PLS_INTEGER;

BEGIN

  -- Open diagnostic cursor
  FOR diag_rec IN diagnostic_csr LOOP

    g_object_name := p_object_name;
    -- Get the sql statement
    IF (diag_rec.dynamic_sql IS NOT NULL) THEN
      l_sql_stmt := get_dynamic_sql
                     (p_dyn_sql_type => diag_rec.dynamic_sql_type,
                      p_dyn_sql      => diag_rec.dynamic_sql);
    ELSIF (diag_rec.report_type = 'ALERT') THEN
      l_sql_stmt := hri_apl_dgnstc_core.get_alert_sql;
    END IF;

    -- Set bind variables
    l_sql_stmt := set_bind_variables
                   (p_dyn_sql      => l_sql_stmt,
                    p_start_date   => p_start_date,
                    p_end_date     => p_end_date,
                    p_obj_name     => p_object_name);

    -- Return SQL statement for display
    -- Do not display the generic ALERT SQL
    IF (diag_rec.dynamic_sql IS NOT NULL) THEN
      p_sql_stmt := l_sql_stmt;
    ELSIF (p_object_name = 'SUP_LOOP') THEN
      p_sql_stmt := hri_apl_dgnstc_wrkfc.get_sup_loop_details;
    END IF;

    -- Run the SQL in the appropriate mode
    IF (diag_rec.default_mode = 'COUNT' OR
         (diag_rec.default_mode = 'DETAIL_RESTRICT_COUNT' AND
          p_mode = 'COUNT')) THEN

      -- In COUNT mode the dynamic sql should already be a count
      -- otherwise add a count(*) and remove order clause
      IF (diag_rec.default_mode <> 'COUNT') THEN

	-- Find the last occurance of ORDER BY
	l_order_by_pos := INSTR(UPPER(l_sql_stmt), 'ORDER BY', -1, 1);

	-- Remove order by if it exists
	IF (l_order_by_pos > 0) THEN
	  l_sql_stmt := SUBSTR(l_sql_stmt, 1, l_order_by_pos - 1);
	END IF;

	-- Add count
        l_sql_stmt := 'SELECT COUNT(*) FROM (' || l_sql_stmt || ')';

      END IF;

      -- Run the count
      EXECUTE IMMEDIATE l_sql_stmt
      INTO l_count;

      -- Store the count value
      l_results_tab(1)(1) := to_char(l_count);

      -- If impact mesage is not null then store it
      IF (diag_rec.impact_msg_name IS NOT NULL AND
          l_count > 0) THEN

        -- Store impact
        p_impact := TRUE;
        p_impact_msg := get_message(diag_rec.impact_msg_name);

      ELSE

        -- No impact
        p_impact := FALSE;

      END IF;

    -- In DETAIL mode
    ELSE

      -- Add a row limit to the sql statement
      IF (p_row_limit IS NOT NULL) THEN
        l_row_limit := p_row_limit;
      ELSE
        l_row_limit := 2000;
      END IF;

      -- Open the cursor for the results
      OPEN c_records
      FOR l_sql_stmt;

      -- store the column values
      FETCH c_records BULK COLLECT
      INTO  l_col1_tab,
            l_col2_tab,
            l_col3_tab,
            l_col4_tab,
            l_col5_tab
      LIMIT l_row_limit;

      -- Close cursor
      CLOSE c_records;

      -- Transfer results to master table
      IF (l_col1_tab.EXISTS(1)) THEN
        FOR i IN 1..l_col1_tab.LAST LOOP
          l_results_tab(i)(1) := l_col1_tab(i);
          l_results_tab(i)(2) := l_col2_tab(i);
          l_results_tab(i)(3) := l_col3_tab(i);
          l_results_tab(i)(4) := l_col4_tab(i);
          l_results_tab(i)(5) := l_col5_tab(i);
        END LOOP;
      END IF;

      -- Store any impact
      IF (diag_rec.impact_msg_name IS NOT NULL AND
          l_count > 0) THEN

        -- Impact
        p_impact := TRUE;
        p_impact_msg := get_message(diag_rec.impact_msg_name);

      ELSE

        -- No impact
        p_impact := FALSE;

      END IF;

    END IF;

  END LOOP;

  -- Return the results table
  p_results_tab := l_results_tab;

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in check_dbi_data_set_up');
  output(SQLERRM);
  output(SQLCODE);
  RAISE;

END run_diagnostic;

END hri_bpl_data_setup_dgnstc;

/
