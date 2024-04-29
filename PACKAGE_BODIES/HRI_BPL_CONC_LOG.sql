--------------------------------------------------------
--  DDL for Package Body HRI_BPL_CONC_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_CONC_LOG" AS
/* $Header: hribcncl.pkb 120.5 2006/06/05 12:38:41 anmajumd noship $ */
--
-- Array type of hri_adm_msg_log row
--
TYPE g_msg_log_array_type IS TABLE OF hri_adm_msg_log%rowtype INDEX BY BINARY_INTEGER;
--
-- Global array to store the information that is to be inserted in hri_adm_msg_log
--
g_msg_log_array g_msg_log_array_type;
--
-- To store the index in the global array at which the process infromation will be stored
--
g_index    NUMBER;
--
-- Whether to log messages
--
g_logging  VARCHAR2(30);
--
-- Variable to store the method action id of the current process
--
g_mthd_action_id  NUMBER;
--
--
-- Bug 4105868: Set to true to output to a concurrent log file
--
g_conc_request_id         NUMBER := fnd_global.conc_request_id;
--
-- Bug 4105868: Global flag which determines whether debugging is turned on
--
g_debug_flag             VARCHAR2(5) := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
--
-- Global constants
--
g_line_length            PLS_INTEGER := 77;
--
g_rtn                    VARCHAR2(5) := '
';
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output_html(p_text  VARCHAR2) IS
  --
BEGIN
  --
  g_conc_request_id := fnd_global.conc_request_id;
  --
  IF g_conc_request_id IS NOT NULL THEN
    --
    -- Write to the concurrent request log
    --
    fnd_file.put_line(fnd_file.output, p_text);
    --
  END IF;
  --
END output_html;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
  --
BEGIN
  --
  g_conc_request_id := fnd_global.conc_request_id;
  --
  IF g_conc_request_id IS NOT NULL THEN
    --
    -- Write to the concurrent request log
    --
    fnd_file.put_line(fnd_file.log, p_text);
    --
  ELSE
    --
    hr_utility.trace(p_text);
    --
  END IF;
  --
END output;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
--
PROCEDURE dbg(p_text  VARCHAR2) IS
  --
BEGIN
  --
  -- Get the value for the debug flag
  --
  g_debug_flag := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
  --
  IF g_debug_flag = 'Y'  THEN
    --
    -- Write to output
    --
    output(p_text);
    --
  END IF;
--
END dbg;
--
-- -----------------------------------------------------------------------------
-- Formats output lines by type
-- -----------------------------------------------------------------------------
--
FUNCTION format_line(p_text       IN VARCHAR2,
                     p_col_list   IN col_list_tab_type,
                     p_mode       IN VARCHAR2,
                     p_line_type  IN VARCHAR2,
                     p_format     IN VARCHAR2)
    RETURN VARCHAR2 IS

  l_text          VARCHAR2(32000);
  l_text1         VARCHAR2(32000);
  l_text2         VARCHAR2(32000);
  l_html_text     VARCHAR2(32000);
  l_pre_format    VARCHAR2(1000);
  l_post_format   VARCHAR2(1000);

BEGIN

  -- Extra HTML formatting
  IF (p_format IS NOT NULL AND
      p_mode = 'HTML') THEN
    l_pre_format := p_format;
    l_post_format := REPLACE(p_format, '<', '</');
  END IF;

-- -----------------
-- Headers / Footers
-- -----------------

  -- Format line according to type
  IF (p_line_type = 'TITLE' AND
      p_text IS NOT NULL) THEN

    l_html_text := '<html>' || g_rtn ||
                   '<head><title>' || p_text || '</title></head>' || g_rtn ||
                   '<body>';

  ELSIF (p_line_type = 'HEADER1' AND
         p_text IS NOT NULL) THEN

    l_text := ' ' || g_rtn || RPAD('*', LENGTH(p_text) + 6, '*') || g_rtn ||
              '** ' ||  p_text || ' **' || g_rtn ||
              RPAD('*', LENGTH(p_text) + 6, '*');

    l_html_text := '<p><h1>' || p_text || '</h1>';

  ELSIF (p_line_type = 'HEADER2' AND
         p_text IS NOT NULL) THEN

    l_text := RPAD('-', g_line_length, '-') || g_rtn ||
              upper(p_text) || g_rtn || RPAD('-', g_line_length, '-');

    l_html_text := '<p><h2>' || p_text || '</h2>';

  ELSIF (p_line_type = 'HEADER3' AND
         p_text IS NOT NULL) THEN

    l_text := ' ' || g_rtn || p_text || g_rtn || RPAD('-', LENGTH(p_text), '-');

    l_html_text := '<p><h3>' || p_text || '</h3>';

  ELSIF (p_line_type = 'HEADER4' AND
         p_text IS NOT NULL) THEN

    l_text := ' ' || g_rtn || p_text || g_rtn || RPAD('-', LENGTH(p_text), '-');

    l_html_text := '<p><b><u>' || p_text || '</u></b><br>';

  ELSIF (p_line_type = 'FOOTER') THEN

    l_html_text := '</body>';

-- -----
-- Lists
-- -----

  ELSIF (p_line_type = 'LIST_HEADER') THEN

    l_html_text := '<ul>';

  ELSIF (p_line_type = 'LIST_ITEM') THEN

    l_html_text := '<li>' || p_text || '</li>';

  ELSIF (p_line_type = 'LIST_FOOTER') THEN

    l_html_text := '</ul>';


-- ------
-- Tables
-- ------

  ELSIF (p_line_type = 'TABLE_HEADER') THEN

    l_html_text := '<p><table border=1>' || g_rtn ||
                   '     <tr>' || g_rtn;

    FOR i IN p_col_list.FIRST..p_col_list.LAST LOOP

      l_text1 := l_text1 || RPAD(p_col_list(i).column_value,
                                p_col_list(i).column_length, ' ');
      l_text2 := l_text2 || RPAD('-',
                                p_col_list(i).column_length - 1, '-') || ' ';

      l_html_text := l_html_text ||
                   '       <td><b>' || p_col_list(i).column_value ||
                   '</b></td>' || g_rtn;
    END LOOP;

    l_text := l_text1 || g_rtn || l_text2;

    l_html_text := l_html_text || '     </tr>';

  ELSIF (p_line_type = 'TABLE_ROW') THEN

    l_html_text := '     <tr>' || g_rtn;

    FOR i IN p_col_list.FIRST..p_col_list.LAST LOOP
      IF (p_col_list(i).column_value IS NOT NULL) THEN

        l_text := l_text || RPAD(p_col_list(i).column_value,
                                 p_col_list(i).column_length, ' ');

        l_html_text := l_html_text ||
                     '       <td>' || p_col_list(i).column_value ||
                     '</td>' || g_rtn;
      ELSE

        l_text := l_text || RPAD(' ', p_col_list(i).column_length, ' ');

        l_html_text := l_html_text || '       <td>&nbsp</td>' || g_rtn;

      END IF;
    END LOOP;

    l_html_text := l_html_text || '     </tr>';

  ELSIF (p_line_type = 'TABLE_FOOTER') THEN

    l_html_text := '   </table><br>';

-- -------
-- Spacers
-- -------

  ELSIF (p_line_type = 'SPACER') THEN

    l_text := ' ';

    l_html_text := '<p>&nbsp' || g_rtn;

  ELSIF (p_line_type = 'SPACER BAR') THEN

    l_text := ' ' || g_rtn || RPAD('-', g_line_length, '-') || g_rtn || ' ';

    l_html_text := '<br><p><hr align=left size=6 width="75%">' || g_rtn;

-- ------------
-- Special Text
-- ------------

  ELSIF (p_line_type = 'HYPERLINK') THEN

    l_text := ' ' || g_rtn || p_text;

    l_html_text := '<a href="' || p_text ||
                   '">Click here for more information</a><br>';

  ELSIF (p_line_type = 'PREFORMAT' AND
         p_text IS NOT NULL) THEN

    l_text := ' ' || g_rtn || p_text;

    l_html_text := '<p><pre>' || p_text || '</pre><br>';

-- -------------
-- Ordinary Text
-- -------------

  ELSIF (p_line_type = 'PARAGRAPH' AND
         p_text IS NOT NULL) THEN

    l_text := ' ' || g_rtn || p_text;

    l_html_text := '<p>' || l_pre_format ||
                   REPLACE(p_text, g_rtn, '<br>' || g_rtn) || '<br>' ||
                   l_post_format;

  ELSIF (p_text IS NOT NULL) THEN

    l_text := p_text;

    l_html_text := l_pre_format ||
                   REPLACE(p_text, g_rtn, '<br>' || g_rtn) || '<br>' ||
                   l_post_format;
  END IF;

  -- Output string according to type
  IF (p_mode = 'HTML') THEN
    RETURN l_html_text;
  ELSE
    RETURN l_text;
  END IF;

  RETURN l_text;

END format_line;
--
-- -----------------------------------------------------------------------------
-- Generic output procedure
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text       IN VARCHAR2,
                 p_mode       IN VARCHAR2,
                 p_line_type  IN VARCHAR2,
                 p_col_list   IN col_list_tab_type DEFAULT g_empty_col_list,
                 p_format     IN VARCHAR2 DEFAULT null) IS

  l_text           VARCHAR2(32000);
  l_write_string   VARCHAR2(1000);
  l_remainder      VARCHAR2(32000);
  l_break          PLS_INTEGER;
  l_space          PLS_INTEGER;
  l_loop           PLS_INTEGER;

BEGIN

  -- Format line according to type
  l_text := format_line
             (p_text => p_text,
              p_col_list => p_col_list,
              p_mode => p_mode,
              p_line_type => p_line_type,
              p_format => p_format);

  -- Output string according to type
  IF (p_mode = 'HTML' AND
      l_text IS NOT NULL) THEN

    output_html(l_text);

  -- Log output needs to be chopped up
  ELSIF (l_text IS NOT NULL) THEN

    -- Initialize variables
    l_write_string := null;
    l_remainder    := l_text;

    -- Chop up p_text string into display width lines
    WHILE (length(l_remainder) > 0) LOOP

      -- Loop check
      l_loop := length(l_remainder);

      -- Set position of next break
      l_break := INSTR(l_remainder, g_rtn);

      -- Set position of last white space
      l_space := INSTR(SUBSTR(l_remainder, 1, g_line_length + 1), ' ', -1, 1);

      -- First check for line breaks
      IF (l_break > 0 AND
          l_break - 1 <= g_line_length) THEN
        l_write_string := SUBSTR(l_remainder, 1, l_break - 1);
        l_remainder    := SUBSTR(l_remainder, l_break + 1);

      -- Then break by word
      ELSIF (l_space > 0 AND
             length(l_remainder) > g_line_length) THEN
        l_write_string := SUBSTR(l_remainder, 1, l_space - 1);
        l_remainder    := SUBSTR(l_remainder, l_space + 1);

      -- Otherwise chop the line
      ELSE
        l_write_string := SUBSTR(l_remainder, 1, g_line_length);
        l_remainder    := SUBSTR(l_remainder, g_line_length + 1);
      END IF;

      -- Write to the log
      output(l_write_string);

      -- Make sure loop variable is decreasing otherwise force exit
      IF (l_loop IS NULL OR
          length(l_remainder) >= l_loop) THEN
        l_remainder := '';
      END IF;

    END LOOP;

  END IF;

END output;
--
-- -----------------------------------------------------------------------------
-- Looks up in the log table the last collect to date of the concurrent
-- process. If no information is found in the log table then the earlier of
-- DBC Global Start Date or 5 years ago is returned.
-- -----------------------------------------------------------------------------
--
FUNCTION get_last_collect_to_date
                 (p_process_code    IN VARCHAR2
                 ,p_table_name      IN VARCHAR2
                 )
RETURN VARCHAR2 IS
  --
  l_sql_stmt            VARCHAR2(500);
  l_full_refresh_code   VARCHAR2(30);
  l_date_to_return      DATE;
  l_process_start_date  DATE;
  l_process_end_date    DATE;
  l_collect_from_date   DATE;
  l_collect_to_date     DATE;
  --
BEGIN
  --
  bis_collection_utilities.get_last_refresh_dates
          (p_object_name  => p_process_code
          ,p_start_date   => l_process_start_date
          ,p_end_date     => l_process_end_date
          ,p_period_from  => l_collect_from_date
          ,p_period_to    => l_collect_to_date
          );
  --
  l_full_refresh_code := hri_bpl_conc_admin.get_full_refresh_code(p_table_name);
  --
  -- If mode is Incremental Update (data in table)
  --
  IF (l_full_refresh_code = 'N') THEN
    --
    -- If the last collect to date is in the log table use it
    --
    IF (l_collect_to_date IS NOT NULL) THEN
      --
      l_date_to_return := l_collect_to_date;
      --
      -- Otherwise collect for the last month
      --
    ELSE
      --
      l_date_to_return := ADD_MONTHS(TRUNC(SYSDATE),-1);
      --
    END IF;
    --
    -- Otherwise mode is Full Refresh (no data in table)
    --
  ELSE
    --
    -- Collect earlier of DBC Global Start Date or 5 years ago
    --
    l_date_to_return := LEAST(ADD_MONTHS(TRUNC(SYSDATE),-60),
                              hri_bpl_parameter.get_bis_global_start_date);
    --
  END IF;
  --
  -- 4303724, Added the parameter value 'FND_NO_CONVERT' in function call
  --
  -- RETURN fnd_date.date_to_displaydt(l_date_to_return,'FND_NO_CONVERT');
  --
  --
  -- Bug 5217834, used fnd_date.date_to_displaydate to return value
  -- to value set FND_STANDARD_DATE.
  --
     RETURN fnd_date.date_to_displaydate(l_date_to_return);
  --
  --
END get_last_collect_to_date;
--
-- -----------------------------------------------------------------------------
-- Removes all records in the log table for the concurrent process
-- -----------------------------------------------------------------------------
--
PROCEDURE delete_process_log( p_process_code    IN VARCHAR2 ) IS
--
BEGIN
  --
  bis_collection_utilities.deleteLogForObject(p_object_name => p_process_code);
  --
END delete_process_log;
--
-- Fix for 4043240
-- --------------------------------------------------------------------------
-- Log the process start information into the mthd actions table
-- --------------------------------------------------------------------------
--
PROCEDURE record_process_start(p_process_code         IN VARCHAR2)  IS
  --
BEGIN
  --
  bis_collection_utilities.g_object_name := p_process_code;
  bis_collection_utilities.g_start_date  := sysdate;
  --
  -- Log the information only if the logging profile is set
  --
  IF NVL(fnd_profile.value('HRI_LOG_PRCSS_INFO'),'Y') = 'N' THEN
    --
    RETURN;
    --
  END IF;
  --
  -- Create a record in the methods actions table and get the mthd
  -- action id for it
  --
  IF g_mthd_action_id IS NULL THEN
    --
    g_mthd_action_id := hri_opl_multi_thread.get_mthd_action_id
                                (p_program    => p_process_code
                                ,p_start_time => bis_collection_utilities.g_start_date
                                );
    --
  END IF;
  --
  COMMIT;
  --
END record_process_start;
--
-- Fix for 4043240
-- ----------------------------------------------------------------------------
-- PROCEDURE log_process_info to store the eror/warning messages generated by
-- the HRI processes
-- ----------------------------------------------------------------------------
--
PROCEDURE log_process_info
                 (p_msg_type              VARCHAR2
                 ,p_package_name          VARCHAR2 DEFAULT NULL
                 ,p_msg_group             VARCHAR2 DEFAULT NULL
                 ,p_msg_sub_group         VARCHAR2 DEFAULT NULL
                 ,p_sql_err_code          VARCHAR2 DEFAULT NULL
                 ,p_note                  VARCHAR2 DEFAULT NULL
                 ,p_effective_date        DATE     DEFAULT TRUNC(SYSDATE)
                 ,p_assignment_id         NUMBER   DEFAULT NULL
                 ,p_person_id             NUMBER   DEFAULT NULL
                 ,p_job_id                NUMBER   DEFAULT NULL
                 ,p_location_id           NUMBER   DEFAULT NULL
                 ,p_event_id              NUMBER   DEFAULT NULL
                 ,p_supervisor_id         NUMBER   DEFAULT NULL
                 ,p_person_type_id        NUMBER   DEFAULT NULL
                 ,p_formula_id            NUMBER   DEFAULT NULL
                 ,p_other_ref_id          NUMBER   DEFAULT NULL
                 ,p_other_ref_column      VARCHAR2 DEFAULT NULL
                 ,p_fnd_msg_name          VARCHAR2 DEFAULT NULL
                 )
IS
  --
  -- The variable to store the message log id for the table
  -- hri_adm_msg_log. The id is generated froma sequence
  --
  l_msg_log_id	NUMBER;
  --
BEGIN
  --
  -- Log the information only if the logging profile is set
  --
  IF NVL(fnd_profile.value('HRI_LOG_PRCSS_INFO'),'Y') = 'N' THEN
    --
    RETURN;
    --
  END IF;
  --
  dbg('In log_process_info');
  --
  -- Initialize the index from which the global array will start storing the records
  --
  IF g_index IS NULL THEN
    --
    g_index := 0;
    --
  END IF;
  --
  -- Get the next message log id from the sequence
  --
  SELECT hri_adm_msg_log_s.nextval
  INTO   l_msg_log_id
  FROM   dual;
  --
  -- Increment the array index at which the infromation is stored
  --
  g_index := g_index+1;
  --
  -- Store the log information generated by the HRI process in a global array
  -- The information stored in this array will be flushed into the
  -- hri_adm_msg_log table when the procedure log_process_end will be
  -- called
  --
  g_msg_log_array(g_index).msg_log_id           := l_msg_log_id;
  g_msg_log_array(g_index).msg_type             := p_msg_type;
  g_msg_log_array(g_index).package_name         := p_package_name;
  g_msg_log_array(g_index).effective_date       := p_effective_date;
  g_msg_log_array(g_index).person_id            := p_person_id;
  g_msg_log_array(g_index).assignment_id        := p_assignment_id;
  g_msg_log_array(g_index).job_id               := p_job_id;
  g_msg_log_array(g_index).location_id          := p_location_id;
  g_msg_log_array(g_index).event_id             := p_event_id;
  g_msg_log_array(g_index).supervisor_id        := p_supervisor_id;
  g_msg_log_array(g_index).person_type_id       := p_person_type_id;
  g_msg_log_array(g_index).formula_id           := p_formula_id;
  g_msg_log_array(g_index).other_ref_id         := p_other_ref_id;
  g_msg_log_array(g_index).other_ref_column     := p_other_ref_column;
  g_msg_log_array(g_index).msg_group            := p_msg_group;
  g_msg_log_array(g_index).msg_sub_group        := p_msg_sub_group;
  g_msg_log_array(g_index).sql_err_code         := p_sql_err_code;
  g_msg_log_array(g_index).fnd_msg_name         := p_fnd_msg_name;
  g_msg_log_array(g_index).note                 := p_note;
  --
  dbg('Exiting log_process_info');
  --
END log_process_info;
--
-- Flush the process infromation stored in the global array into
-- the hri_adm_msg_log table
--
PROCEDURE flush_process_info(p_package_name   IN VARCHAR2) IS

BEGIN
  --
  IF g_mthd_action_id IS NULL THEN
    g_mthd_action_id := hri_opl_multi_thread.get_mthd_action_id
                                (p_program    => p_package_name
                                ,p_start_time => sysdate);
  END IF;
  --
  IF g_logging IS NULL THEN
    g_logging := NVL(fnd_profile.value('HRI_LOG_PRCSS_INFO'),'Y');
  END IF;
  --
  -- Log the information only if the logging profile is set
  --
  IF (g_index > 0 AND
      g_logging = 'Y') THEN
    --
    -- Insert all the  messages stored in the global
    -- array into the table hri_adm_msg_log
    --
    FOR i IN 1..g_index LOOP
      INSERT INTO hri_adm_msg_log
             (msg_log_id
             ,mthd_action_id
             ,msg_type
             ,package_name
             ,effective_date
             ,person_id
             ,assignment_id
             ,job_id
             ,location_id
             ,event_id
             ,supervisor_id
             ,person_type_id
             ,formula_id
             ,other_ref_id
             ,other_ref_column
             ,msg_group
             ,msg_sub_group
             ,sql_err_code
             ,fnd_msg_name
             ,note
             )
      VALUES
             (g_msg_log_array(i).msg_log_id
             ,g_mthd_action_id
             ,g_msg_log_array(i).msg_type
             ,g_msg_log_array(i).package_name
             ,g_msg_log_array(i).effective_date
             ,g_msg_log_array(i).person_id
             ,g_msg_log_array(i).assignment_id
             ,g_msg_log_array(i).job_id
             ,g_msg_log_array(i).location_id
             ,g_msg_log_array(i).event_id
             ,g_msg_log_array(i).supervisor_id
             ,g_msg_log_array(i).person_type_id
             ,g_msg_log_array(i).formula_id
             ,g_msg_log_array(i).other_ref_id
             ,g_msg_log_array(i).other_ref_column
             ,g_msg_log_array(i).msg_group
             ,g_msg_log_array(i).msg_sub_group
             ,g_msg_log_array(i).sql_err_code
             ,g_msg_log_array(i).fnd_msg_name
             ,g_msg_log_array(i).note
             );
    END LOOP;
    --
    commit;
    --
  END IF;

  -- Reset the index
  g_index := 0;

END flush_process_info;
--
-- -------------------------------------------------------------------------
-- Inserts into the log table the information about the concurrent process
-- run - start and end times, rows processed, errors and parameters
-- -------------------------------------------------------------------------
--
PROCEDURE log_process_end
                  (p_status        IN BOOLEAN
                  ,p_count         IN NUMBER   DEFAULT 0
                  ,p_message       IN VARCHAR2 DEFAULT NULL
                  ,p_period_from   IN DATE     DEFAULT to_date(NULL)
                  ,p_period_to     IN DATE     DEFAULT to_date(NULL)
                  ,p_attribute1    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute2    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute3    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute4    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute5    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute6    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute7    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute8    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute9    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute10   IN VARCHAR2 DEFAULT NULL
                  --
                  -- New parameters for bug fix 4043240
                  --
                  ,p_process_type  IN VARCHAR2 DEFAULT NULL
                  ,p_package_name  IN VARCHAR2 DEFAULT NULL
                  ,p_full_refresh  IN VARCHAR2 DEFAULT NULL
                  ,p_attribute11   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute12   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute13   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute14   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute15   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute16   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute17   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute18   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute19   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute20   IN VARCHAR2 DEFAULT NULL
                  )
IS
  --
  -- Variable to identify if and error has been logged in
  -- hri_adm_msg_log
  --
  l_error                VARCHAR2(5);
  --
  -- Variable to store the status of the process
  --
  l_status               VARCHAR2(30);
  --
  -- Cursor returning whether an error or warning has occurred
  --
  CURSOR error_csr(v_mthd_action_id  NUMBER) IS
  SELECT 'Y'
  FROM dual
  WHERE EXISTS
   (SELECT null
    FROM hri_adm_msg_log
    WHERE mthd_action_id = v_mthd_action_id
    AND msg_type in ('ERROR','WARNING'));
  --
BEGIN
  --
  dbg('In log_process_end');
  --
  -- Bug 4105868
  -- When this procedure is called by a program using the multithreading utility
  -- the wrapup process should not be called if g_mthd_action_id is not populated.
  -- This means that one of the child thread is updating the log table. The master
  -- threads only should be updating BIS_REFRESH_LOG table.
  --
  IF g_mthd_action_id is not null THEN
    --
    bis_collection_utilities.wrapup
            (p_status      => p_status
            ,p_count       => p_count
            ,p_message     => p_message
            ,p_period_from => p_period_from
            ,p_period_to   => p_period_to
            ,p_attribute1  => p_attribute1
            ,p_attribute2  => p_attribute2
            ,p_attribute3  => p_attribute3
            ,p_attribute4  => p_attribute4
            ,p_attribute5  => p_attribute5
            ,p_attribute6  => p_attribute6
            ,p_attribute7  => p_attribute7
            ,p_attribute8  => p_attribute8
            ,p_attribute9  => p_attribute9
            ,p_attribute10 => p_attribute10
            );
  ELSE
    --
    g_mthd_action_id := hri_opl_multi_thread.get_mthd_action_id
                                (p_program    => p_package_name
                                ,p_start_time => sysdate
                                );
    --
  END IF;
  --
  -- Flush the process infromation stored in the global array into
  -- the hri_adm_msg_log table
  --
  flush_process_info
   (p_package_name => p_package_name);

  -- If an error/warning message is encountered then the main process
  -- should have 'Error' status
  --
  OPEN error_csr(g_mthd_action_id);
  FETCH error_csr INTO l_error;
  CLOSE error_csr;
  --
  -- If the global array has a record which is of error/warning type
  -- or p_status is set to false then the status of the main process should
  -- be set to 'ERROR'
  --
  IF l_error = 'Y' OR
     p_status = false THEN
    --
    l_status := 'ERROR';
    --
  ELSE
    --
    l_status := 'PROCESSED';
    --
  END IF;
  --
  -- Update the row in hri_adm_mthd_actions to store the
  -- process information
  --
  UPDATE hri_adm_mthd_actions
  SET    status              =  l_status,
         end_time            =  sysdate,
         collect_from_date   =  p_period_from,
         collect_to_date     =  p_period_to,
         process_type        =  p_process_type,
         program             =  p_package_name,
         full_refresh_flag   =  p_full_refresh,
         attribute1          =  p_attribute1,
         attribute2          =  p_attribute2,
         attribute3          =  p_attribute3,
         attribute4          =  p_attribute4,
         attribute5          =  p_attribute5,
         attribute6          =  p_attribute6,
         attribute7          =  p_attribute7,
         attribute8          =  p_attribute8,
         attribute9          =  p_attribute9,
         attribute10         =  p_attribute10,
         attribute11         =  p_attribute11,
         attribute12         =  p_attribute12,
         attribute13         =  p_attribute13,
         attribute14         =  p_attribute14,
         attribute15         =  p_attribute15,
         attribute16         =  p_attribute16,
         attribute17         =  p_attribute17,
         attribute18         =  p_attribute18,
         attribute19         =  p_attribute19,
         attribute20         =  p_attribute20
  WHERE mthd_action_id       =  g_mthd_action_id;
  --
  COMMIT;
  --
  dbg('Exiting log_process_end');
  --
END log_process_end;
--
-- -------------------------------------------------------------------------
-- Procedure to be called by the obsoleted concurrent programs
-- -------------------------------------------------------------------------
--
PROCEDURE obsoleted_message
                  (errbuf          OUT NOCOPY  VARCHAR2
                  ,retcode         OUT  NOCOPY VARCHAR2
                  )
IS
  --
BEGIN
  --
  fnd_message.set_name('HRI','HRI_407286_OBSOLETED_CONC_PRGM');
  --
  fnd_file.put_line(fnd_file.LOG,fnd_message.get);
  --
END obsoleted_message;
--
END hri_bpl_conc_log;

/
