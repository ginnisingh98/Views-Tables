--------------------------------------------------------
--  DDL for Package Body HRI_OPL_DATA_SETUP_DGNSTC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_DATA_SETUP_DGNSTC" AS
/* $Header: hripdgdp.pkb 120.9 2006/12/11 09:54:35 msinghai noship $ */

-- =========================================================================
--
-- OVERVIEW
-- --------
-- This package contains procedures to display the data set up of DBI in
-- the system.
--
-- http://files.oraclecorp.com/content/AllPublic/SharedFolders/HRMS%20
-- Intelligence%20%28HRMSi%29%20-%20Documents-Public/Design%20
-- Specifications/hri_lld_dgn_data_stup.doc
--
-- =========================================================================

  TYPE g_sql_rec_type IS RECORD
   (sql_stmt      VARCHAR2(32000),
    section_code  VARCHAR2(240),
    section_name  VARCHAR2(240));

  TYPE g_sql_tab_type IS TABLE OF g_sql_rec_type
                         INDEX BY BINARY_INTEGER;

  g_concurrent_logging      BOOLEAN;
  g_debugging               BOOLEAN;
  g_empty_col_list          hri_bpl_conc_log.col_list_tab_type;
  g_rtn                     VARCHAR2(5) := '
';
  g_functional_area         varchar2(100);
  g_object_name             VARCHAR2(100);
-- ----------------------------------------------------------------------------
-- Switches debugging messages on or off. Setting to on will
-- mean extra debugging information will be generated when the
-- process is run.
-- ----------------------------------------------------------------------------
PROCEDURE set_debugging(p_on IN BOOLEAN) IS

BEGIN

  g_debugging := p_on;

END set_debugging;

-- ----------------------------------------------------------------------------
-- This procedure sets the global g_concurrent_logging to
-- the value passed in. If set log messages will be output
-- through fnd_file.put_line.
-- ----------------------------------------------------------------------------
PROCEDURE set_concurrent_logging(p_on IN BOOLEAN) IS

BEGIN

  g_concurrent_logging := p_on;

END set_concurrent_logging;

-- ----------------------------------------------------------------------------
-- Prints a message to the concurrent process log
-- ----------------------------------------------------------------------------
PROCEDURE output(p_text IN VARCHAR2) IS

BEGIN

  hri_bpl_conc_log.output(p_text);

END output;

-- ----------------------------------------------------------------------------
-- Prints a message to the concurrent process log and html output
-- ----------------------------------------------------------------------------
PROCEDURE output
 (p_text       IN VARCHAR2,
  p_line_type  IN VARCHAR2,
  p_col_list   IN hri_bpl_conc_log.col_list_tab_type DEFAULT g_empty_col_list,
  p_format     IN VARCHAR2 DEFAULT null) IS

BEGIN

  hri_bpl_conc_log.output
   (p_text      => p_text,
    p_col_list  => p_col_list,
    p_mode      => 'HTML',
    p_line_type => p_line_type,
    p_format    => p_format);

END output;

-- ----------------------------------------------------------------------------
-- Procedure dbg decides whether to log the passed in message
-- depending on whether debug mode is set.
-- ----------------------------------------------------------------------------
PROCEDURE dbg(p_text IN VARCHAR2) IS

BEGIN

  IF g_debugging THEN
    output(p_text);
  END IF;

END dbg;

-- ----------------------------------------------------------------------------
-- Function GET_MESSAGE takes the message name and returns back the
-- message text
-- ----------------------------------------------------------------------------
FUNCTION get_message(p_message    IN VARCHAR2,
                     p_start_date IN VARCHAR2,
                     p_end_date   IN VARCHAR2)
        RETURN VARCHAR2 IS

BEGIN

  fnd_message.set_name('HRI', p_message);

  -- Set the start and end date
  fnd_message.set_token('START_DATE',p_start_date);
  fnd_message.set_token('END_DATE',p_end_date);

  RETURN fnd_message.get;

END get_message;

-- ----------------------------------------------------------------------------
-- Function GET_MESSAGE takes the message name and returns back the
-- message text
--
--
-- Modified by : Saurav Mohapatra
-- Date        : 16-Nov-2006
-- Description : Function made scalable to parse tokens in messages
--
--
-- ----------------------------------------------------------------------------
FUNCTION get_message(p_message    IN VARCHAR2)
        RETURN VARCHAR2 IS

BEGIN

  fnd_message.set_name('HRI', p_message);
  --
  IF HRI_BPL_SETUP_DIAGNOSTIC.is_token_exist(p_message,'PRODUCT_NAME') THEN
    --
    fnd_message.set_token('PRODUCT_NAME'
                          ,HRI_BPL_SETUP_DIAGNOSTIC.get_product_name(p_object_name => g_object_name));
    --
  END IF;
  --
  RETURN fnd_message.get;
  --
END get_message;

-- ----------------------------------------------------------------------------
-- Function GET_MESSAGE_ALERT takes the message name and returns back the
-- message text
-- ----------------------------------------------------------------------------
FUNCTION get_message_alert(p_message    IN VARCHAR2)
        RETURN VARCHAR2 IS

BEGIN

  fnd_message.set_name('HRI', p_message);

  RETURN fnd_message.get;

END get_message_alert;

-- ----------------------------------------------------------------------------
-- PROCEDURE trim_msg removes blank spaces and enter characters from the string
-- ----------------------------------------------------------------------------
FUNCTION trim_msg(p_text IN VARCHAR2)
     RETURN VARCHAR2 IS

  l_text VARCHAR2(20000);

BEGIN

  -- Remove blank spaces
  l_text := TRIM(both ' ' FROM p_text);

  RETURN l_text;

END trim_msg;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_parameters outputs the parameters
-- ----------------------------------------------------------------------------
PROCEDURE display_parameters(p_start_date  IN VARCHAR2,
                             p_end_date    IN VARCHAR2,
                             p_mode        IN VARCHAR2,
                             p_section     IN VARCHAR2,
                             p_subsection  IN VARCHAR2,
                             p_show_data   IN VARCHAR2) IS

  l_col_list               hri_bpl_conc_log.col_list_tab_type;

BEGIN

  -- Display the parameters passed to the concurrent program
  output(p_text      => 'Parameters',
         p_line_type => 'HEADER3');

  -- Set up parameter table
  l_col_list(1).column_value  := 'Parameter';
  l_col_list(2).column_value  := 'Value';

  -- Output the table header
  output(p_text      => null,
         p_line_type => 'TABLE_HEADER',
         p_col_list  => l_col_list);

  -- Update parameter table
  l_col_list(1).column_value  := 'Start Date';
  l_col_list(2).column_value  := p_start_date;

  -- Output the row
  output(p_text      => null,
         p_line_type => 'TABLE_ROW',
         p_col_list  => l_col_list);

  -- Update parameter table
  l_col_list(1).column_value  := 'End Date';
  l_col_list(2).column_value  := p_end_date;

  -- Output the row
  output(p_text      => null,
         p_line_type => 'TABLE_ROW',
         p_col_list  => l_col_list);

  -- Update parameter table
  l_col_list(1).column_value  := 'Mode';
  l_col_list(2).column_value  := hr_general.decode_lookup
                                  ('HRI_MODE',p_mode);

  -- Output the row
  output(p_text      => null,
         p_line_type => 'TABLE_ROW',
         p_col_list  => l_col_list);

  -- Update parameter table
  l_col_list(1).column_value  := 'Section';
  l_col_list(2).column_value  := hr_general.decode_lookup
                                  ('HRI_SECTION',p_section);

  -- Output the row
  output(p_text      => null,
         p_line_type => 'TABLE_ROW',
         p_col_list  => l_col_list);

  -- Update parameter table
  l_col_list(1).column_value  := 'Subsection';
  l_col_list(2).column_value  := hr_general.decode_lookup
                                  ('HRI_SUBSECTION',p_subsection);

  -- Output the row
  output(p_text      => null,
         p_line_type => 'TABLE_ROW',
         p_col_list  => l_col_list);

  -- Output the table footer
  output(p_text      => null,
         p_line_type => 'TABLE_FOOTER');

END display_parameters;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_rpt_heading is used for dispalying the parameters passed
-- by the concurrent program
-- ----------------------------------------------------------------------------
PROCEDURE display_rpt_heading (p_start_date  IN VARCHAR2,
                               p_end_date    IN VARCHAR2,
                               p_mode        IN VARCHAR2,
                               p_section     IN VARCHAR2,
                               p_subsection  IN VARCHAR2,
                               p_show_data   IN VARCHAR2) IS

  l_header_msg             VARCHAR2(32000);
  l_title                  VARCHAR2(80);
  l_start_date             VARCHAR2(80);
  l_end_date               VARCHAR2(80);

BEGIN

  -- Print message to conc log
  output(get_message('HRI_407465_LOG_TO_OUTPUT'));

  -- Get the start/end dates
  l_start_date := fnd_date.date_to_displaydt
                   (fnd_date.canonical_to_date(p_start_date));
  l_end_date := fnd_date.date_to_displaydt
                 (fnd_date.canonical_to_date(p_end_date));

  -- Data diagnostics mode
  IF p_show_data = 'Y' THEN

    -- Output parameters in debug mode
    IF (g_debugging) THEN

      display_parameters
       (p_start_date => l_start_date,
        p_end_date   => l_end_date,
        p_mode       => p_mode,
        p_section    => p_section,
        p_subsection => p_subsection,
        p_show_data  => p_show_data);

    END IF;

    -- Get the title
    l_title := hr_bis.bis_decode_lookup
                ('HRI_DGNSTC_TITLE', 'DATA');

    -- Display the page heading
    output(p_text      => l_title,
           p_line_type => 'TITLE');

    -- Display the report heading
    output(p_text      => l_title,
           p_line_type => 'HEADER1');

    -- Display the message that the system was diagnosed for DBI set up
    l_header_msg := get_message('HRI_407224_DATA_SETUP_MSG',
                                l_start_date,
                                l_end_date);
    output(p_text      => l_header_msg,
           p_line_type => 'PARAGRAPH');
  ELSE

    -- Get the title
    l_title := hr_bis.bis_decode_lookup
                ('HRI_DGNSTC_TITLE', 'COLLECTION');

    -- Display the page heading
    output(p_text      => l_title,
           p_line_type => 'TITLE');

    -- Display the report heading
    output(p_text      => l_title,
           p_line_type => 'HEADER1');

    -- Display the message that the system was diagnosed for DBI set up
    l_header_msg := get_message_alert('HRI_407285_COLL_SETUP_MSG');

    output(p_text      => l_header_msg,
           p_line_type => 'PARAGRAPH');
  END IF;

END display_rpt_heading;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_title_desc displays the title and description. The
-- title can be of a section heading or subsection heading or the column heading
-- in COUNT mode
-- ----------------------------------------------------------------------------

PROCEDURE display_title_desc(p_title IN VARCHAR2,
                             p_desc  IN VARCHAR2,
                             p_type  IN VARCHAR2) IS

BEGIN

  -- Split by type
  IF p_type = 'SECTION' THEN

    -- Spacer Line
    output(p_text      => null,
           p_line_type => 'SPACER BAR');

    -- Section title
    output(p_text      => p_title,
           p_line_type => 'HEADER2');

    -- Section description
    IF p_desc IS NOT NULL THEN
      output(p_text      => p_desc,
             p_line_type => 'PARAGRAPH');
    END IF;

  ELSIF p_type = 'SUBSECTION' THEN

    -- Subsection title
    output(p_text      => p_title,
           p_line_type => 'HEADER3');

    -- Subsection description
    IF p_title IS NOT NULL THEN
      output(p_text      => p_desc,
             p_line_type => 'PARAGRAPH');
    END IF;

  END IF;

END display_title_desc;

-- ----------------------------------------------------------------------------
-- PROCEDURE debug_sup_loops prints out the person details for every person
-- in a supervisor loop
-- ----------------------------------------------------------------------------
PROCEDURE debug_sup_loops
  (p_results_tab  IN hri_bpl_data_setup_dgnstc.data_results_tab_type) IS

  l_loop_tab     hri_bpl_data_setup_dgnstc.loop_results_tab_type;
  l_text         VARCHAR2(2000);

BEGIN

  -- Process only if results exist (from collection)
  IF (p_results_tab.EXISTS(1)) THEN

    -- Print title
    output(p_text => hr_bis.bis_decode_lookup
                      ('HRI_DGNSTC_SECTION','SUP_LOOP_DETAIL'),
           p_line_type => 'HEADER3');

    -- Loop through instances of supervisor loops
    FOR i IN p_results_tab.FIRST..p_results_tab.LAST LOOP

      -- Get details of supervisor loop
      hri_bpl_data_setup_dgnstc.debug_sup_loop
       (p_person_id => p_results_tab(i)(5),
        p_effective_date => p_results_tab(i)(4),
        p_loop_tab => l_loop_tab);

      -- Process only if loop exists (on system now)
      IF (l_loop_tab.EXISTS(1)) THEN

        -- Print loop heading
        output(p_text => p_results_tab(i)(1),
               p_line_type => 'HEADER4');

        -- Print loop details
        FOR j IN l_loop_tab.FIRST..l_loop_tab.LAST LOOP

          l_text := l_loop_tab(j).person_name       || ' (' ||
                    l_loop_tab(j).person_number     || ') -> ' ||
                    l_loop_tab(j).supervisor_name   || ' (' ||
                    l_loop_tab(j).supervisor_number || ')';

          output(p_text => l_text,
                 p_line_type => 'TEXT');

        END LOOP;

      END IF;  -- loop still exists on system

    END LOOP;

  END IF;  -- loop exists from collection

END debug_sup_loops;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_sql prints out all the SQL statements used
-- ----------------------------------------------------------------------------
PROCEDURE display_sql(p_sql_list  IN g_sql_tab_type) IS

  l_sql_stmt       VARCHAR2(32000);

BEGIN

  IF p_sql_list.EXISTS(1) THEN

    -- Spacer Line
    output(p_text      => null,
           p_line_type => 'SPACER BAR');

    -- Section title
    output(p_text      => hr_bis.bis_decode_lookup
                           ('HRI_DGNSTC_SECTION', 'SQL'),
           p_line_type => 'HEADER2');

    -- Loop through sql table
    FOR i IN p_sql_list.FIRST..p_sql_list.LAST LOOP

      -- Format sql
      l_sql_stmt := p_sql_list(i).sql_stmt;

      -- Check there is a SQL stmt
      IF (l_sql_stmt IS NOT NULL) THEN

        -- Output section reference
        output(p_text      => '<a name="SQL_' || p_sql_list(i).section_code || '">' ||
                              get_message(p_sql_list(i).section_name) || '</a>',
               p_line_type => 'HEADER3');

        -- Output sql
        output(p_text      => l_sql_stmt,
               p_line_type => 'PREFORMAT');

      END IF;

    END LOOP;

  END IF;

END display_sql;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_setup is called from the concurrent manager. This
-- procedure is used for displaying the Diagnostics Data Setup information as
-- is returned by the BPL layer.
--
-- INPUT PARAMETERS:
--       p_start_date : The date from which the setup is to be checked
--       p_end_date   : The date to which the setup is to be checked
--       p_mode       : The mode in which the report should run
--       p_section    : The section that has to be shown in te detail format
--       p_subsection : The subsection that has to be shown in detail format
-- ----------------------------------------------------------------------------
PROCEDURE display_data_setup(errbuf             OUT NOCOPY VARCHAR2,
                             retcode            OUT NOCOPY VARCHAR2,
                             p_functional_area  IN VARCHAR2,
                             p_start_date       IN VARCHAR2,
                             p_end_date         IN VARCHAR2,
                             p_mode             IN VARCHAR2,
                             p_section          IN VARCHAR2,
                             p_subsection       IN VARCHAR2,
                             p_show_alerts      IN VARCHAR2,
                             p_show_data        IN VARCHAR2) IS

  -- Cursor to get all diagnostics to run
  CURSOR diagnostic_csr IS
  SELECT
   stp.object_type                  section_code
  ,stp.object_type_msg_name         section_heading
  ,CASE WHEN p_mode = 'COUNT'
        THEN NVL(stp.object_type_desc,
                 DECODE(stp.object_name_msg_name,
                        NULL, stp.object_name_desc, NULL))
        ELSE NVL(stp.object_type_dtl_desc_msg_name,
                 DECODE(stp.object_name_msg_name,
                        NULL, stp.object_name_dtl_desc_msg_name, NULL))
   END                              section_description
  ,stp.object_name                  subsection_code
  ,stp.object_name_msg_name         subsection_heading
  ,CASE WHEN p_mode = 'COUNT'
        THEN stp.object_name_desc
        ELSE stp.object_name_dtl_desc_msg_name
   END                              subsection_description
  ,stp.default_mode
  ,stp.report_type
  ,stp.count_heading
  ,stp.col_heading1
  ,stp.col_heading2
  ,stp.col_heading3
  ,stp.col_heading4
  ,stp.col_heading5
  ,stp.object_type_msg_name
  ,stp.object_name_msg_name
  ,stp.object_type_dtl_desc_msg_name
  ,stp.object_type_desc
  ,stp.object_name_dtl_desc_msg_name
  ,stp.object_name_desc
  ,stp.dynamic_sql
  ,stp.dynamic_sql_type
  ,stp.impact_msg_name
  ,stp.seq_num
  FROM
   hri_adm_dgnstc_setup   stp
  WHERE stp.enabled_flag = 'Y'
  AND ((stp.report_type = 'DATA' AND p_show_data = 'Y')
    OR (stp.report_type = 'ALERT' AND p_show_alerts = 'Y' AND
        NVL(fnd_profile.value('HRI_LOG_PRCSS_INFO'),'Y') = 'Y'))
  AND ((stp.foundation_hr_flag ='Y' AND hri_bpl_system.is_full_hr_installed='N')
    OR hri_bpl_system.is_full_hr_installed='Y' )
  AND EXISTS
    (SELECT null
     FROM dual
     WHERE (p_functional_area = 'ALL'
       OR EXISTS
        (SELECT null
         FROM hri_adm_dgnstc_sbscrb  sbs
         WHERE sbs.functional_area_cd = p_functional_area
         AND sbs.object_name = stp.object_name
         AND sbs.object_type = stp.object_type)))
  ORDER BY
   DECODE(stp.functional_area_cd,
           'PPL_MNGMNT', null,
          stp.functional_area_cd)  ASC NULLS FIRST
  ,stp.report_type desc
  ,stp.seq_num;

  l_col_list           hri_bpl_conc_log.col_list_tab_type;
  l_no_cols            PLS_INTEGER;
  l_row_limit          PLS_INTEGER;
  l_count              PLS_INTEGER;
  l_previous_section   VARCHAR2(240);
  l_sql_list           g_sql_tab_type;
  l_results_tab        hri_bpl_data_setup_dgnstc.data_results_tab_type;
  l_impact             BOOLEAN;
  l_impact_msg         VARCHAR2(32000);
  l_doc_links_url      VARCHAR2(32000);
  l_subsection_code    VARCHAR2(240);
  l_section_code       VARCHAR2(240);
  l_show_detail        BOOLEAN;

BEGIN

  -- Set the global varibales
  set_concurrent_logging(TRUE);
  set_debugging(FALSE);
  l_count := 0;

  g_functional_area := p_functional_area;
  -- Populate the global table to carry the flags for the
  -- Present objects in Diagnostics Subscription table.
  --

  HRI_BPL_SETUP_DIAGNOSTIC.pplt_obj_farea_tab;  -- Procedure call to populate the Global table.

  -- Get the section code from the parameters
  IF (p_section IS NULL OR
      p_section = 'NA_EDW') THEN
    l_section_code := NULL;
  ELSE
    l_section_code := SUBSTR(p_section, INSTR(p_section, '|') + 1);
  END IF;



  -- Get the subsection code from the parameters
  IF (p_subsection IS NULL OR
      p_subsection = 'NA_EDW') THEN
    l_subsection_code := NULL;
  ELSE
    l_subsection_code := p_subsection;
  END IF;

  -- Display the parameters passed to the concurrent program
  display_rpt_heading(p_start_date,
                      p_end_date,
                      p_mode,
                      p_section,
                      p_subsection,
                      p_show_data);

  -- Display section navigation list
  output(p_text => '',
         p_line_type => 'LIST_HEADER');

  -- Loop through the diagnostics to run
  FOR diag_rec IN diagnostic_csr LOOP
    -- Set the Global Object Name
    g_object_name := diag_rec.subsection_code ;

    -- If section or subsection is specified filter out unwanted diagnostics
    IF ((l_section_code IS NULL OR
         l_section_code = diag_rec.section_code) AND
        (l_subsection_code IS NULL OR
         l_subsection_code = diag_rec.subsection_code)) THEN

      -- Print section heading if a new section is encountered
      IF (diag_rec.section_heading IS NOT NULL AND
          (l_previous_section IS NULL OR
           l_previous_section <> diag_rec.section_code)) THEN

        output(p_text => '<a href="#' || diag_rec.section_code || '">' ||
                          get_message(diag_rec.section_heading) || '</a>',
               p_line_type => 'LIST_ITEM');

      END IF;

      -- Keep track of section
      l_previous_section := diag_rec.section_code;

    END IF;

  END LOOP;


  output(p_text => '',
         p_line_type => 'LIST_FOOTER');

  -- Reset variables
  l_previous_section := NULL;

  -- Loop through the diagnostics to run
  FOR diag_rec IN diagnostic_csr LOOP
    -- Set the Global Object Name
    g_object_name := diag_rec.subsection_code ;
    -- If section or subsection is specified filter out unwanted diagnostics
    IF ((l_section_code IS NULL OR
         l_section_code = diag_rec.section_code) AND
        (l_subsection_code IS NULL OR
         l_subsection_code = diag_rec.subsection_code)) THEN

      -- Initialize variables
      l_col_list := g_empty_col_list;
      l_count    := l_count + 1;
      l_sql_list(l_count).section_name := 'SECTION NOT FOUND';
      l_sql_list(l_count).section_code := 'NA_EDW';

      -- Set the detail level based on whether the section is specified
      IF (l_section_code = diag_rec.section_code AND
          (l_section_code = diag_rec.subsection_code OR
           l_subsection_code = diag_rec.subsection_code)) THEN
        l_show_detail := TRUE;
        l_row_limit := 2000;
      ELSE
        l_show_detail := FALSE;
        l_row_limit := 50;
      END IF;

      -- Print section heading if a new section is encountered
      IF (diag_rec.section_heading IS NOT NULL AND
          (l_previous_section IS NULL OR
           l_previous_section <> diag_rec.section_code)) THEN

        display_title_desc
         (p_title => '<a name="' || diag_rec.section_code || '">' ||
                     get_message(diag_rec.section_heading) || '</a>',
          p_desc  => get_message(diag_rec.section_description),
          p_type  => 'SECTION');

        -- Store the current section
        l_sql_list(l_count).section_name := diag_rec.section_heading;
        l_sql_list(l_count).section_code := diag_rec.section_code;

      END IF;

      -- Keep track of section
      l_previous_section := diag_rec.section_code;

      -- Print subsection heading
      IF (diag_rec.subsection_heading IS NOT NULL) THEN

        display_title_desc
         (p_title => get_message(diag_rec.subsection_heading),
          p_desc  => get_message(diag_rec.subsection_description),
          p_type  => 'SUBSECTION');


        -- Store the current subsection
        l_sql_list(l_count).section_name := diag_rec.subsection_heading;
        l_sql_list(l_count).section_code := diag_rec.subsection_code;

      END IF;

      -- Print collection alert message
      IF (diag_rec.report_type = 'ALERT') THEN
        output(p_text      => get_message('HRI_407417_DGN_CLLCTN_ALRT'),
               p_line_type => 'PARAGRAPH');
      END IF;

      -- Set up the output table
      IF (diag_rec.count_heading IS NOT NULL AND
          (diag_rec.default_mode = 'COUNT' OR
           (diag_rec.default_mode = 'DETAIL_RESTRICT_COUNT' AND
            p_mode = 'COUNT'))) THEN

        -- Set up the column structure
        l_col_list(1).column_value  := get_message(diag_rec.count_heading);

      ELSE

        -- The first column heading must be provided
        l_col_list(1).column_value  := get_message(diag_rec.col_heading1);

        -- Check the rest of the columns
        IF (diag_rec.col_heading2 IS NOT NULL) THEN
          l_col_list(2).column_value  := get_message(diag_rec.col_heading2);
        END IF;
        IF (diag_rec.col_heading3 IS NOT NULL) THEN
          l_col_list(3).column_value  := get_message(diag_rec.col_heading3);
        END IF;
        IF (diag_rec.col_heading4 IS NOT NULL) THEN
          l_col_list(4).column_value  := get_message(diag_rec.col_heading4);
        END IF;
        IF (diag_rec.col_heading5 IS NOT NULL) THEN
          l_col_list(5).column_value  := get_message(diag_rec.col_heading5);
        END IF;

      END IF;

      -- Get number of columns to display
      l_no_cols := l_col_list.LAST;

      -- Output the table header
      output(p_text      => null,
             p_line_type => 'TABLE_HEADER',
             p_col_list  => l_col_list);

      -- Get the diagnostic results
      hri_bpl_data_setup_dgnstc.run_diagnostic
       (p_object_name   => diag_rec.subsection_code,
        p_object_type   => diag_rec.section_code,
        p_mode          => p_mode,
        p_start_date    => fnd_date.canonical_to_date(p_start_date),
        p_end_date      => fnd_date.canonical_to_date(p_end_date),
        p_row_limit     => l_row_limit,
        p_results_tab   => l_results_tab,
        p_impact        => l_impact,
        p_impact_msg    => l_impact_msg,
        p_doc_links_url => l_doc_links_url,
        p_sql_stmt      => l_sql_list(l_count).sql_stmt);


      -- Output the results
      BEGIN

        -- Loop through the rows returned
        FOR i IN l_results_tab.FIRST..l_results_tab.LAST LOOP

          -- Update the column array
          FOR j IN 1..l_no_cols LOOP
            l_col_list(j).column_value  := l_results_tab(i)(j);
          END LOOP;

          -- Output the row
          output(p_text      => null,
                 p_line_type => 'TABLE_ROW',
                 p_col_list  => l_col_list);

        END LOOP;

      -- Trap errors when no data is returned
      EXCEPTION WHEN OTHERS THEN
        null;
      END;

      -- Output the table footer
      output(p_text      => null,
             p_line_type => 'TABLE_FOOTER');

      -- Print link to sql
      IF (l_sql_list(l_count).sql_stmt IS NOT NULL) THEN

        output(p_text => '<a href="#SQL_' || l_sql_list(l_count).section_code || '">' ||
                         get_message('HRI_407464_SQL_LINK') || '</a>',
               p_line_type => 'TEXT');

      END IF;

      -- Output any impact message
      IF l_impact THEN

        -- Print impact subheading
        output(p_text      => hr_bis.bis_decode_lookup
                               ('HRI_DGNSTC_SECTION', 'IMPACT'),
               p_line_type => 'HEADER4');

        -- Print impact messages
        output(p_text      => l_impact_msg,
               p_line_type => 'TEXT');
        output(p_text      => l_doc_links_url,
               p_line_type => 'PARAGRAPH');
      END IF;

      -- Special case, supervisor loops
      IF (diag_rec.subsection_code = 'SUP_LOOP' AND
          l_show_detail) THEN
        debug_sup_loops
         (p_results_tab => l_results_tab);

      END IF;

    END IF;  -- Diagnostics to process

  END LOOP;  -- All diagnostics for area


  -- Output message if no diagnostics were found
  IF (l_count = 0) THEN
    output(p_text      => get_message('HRI_407416_NO_DIAG_FOUND'),
           p_line_type => 'PARAGRAPH');

  -- Otherwise output all the SQL statements
  ELSE

    display_sql
     (p_sql_list => l_sql_list);

  END IF;

  -- Output footer
  output(p_text      => null,
         p_line_type => 'FOOTER');

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_setup');
  output(SQLERRM);
  output(SQLCODE);
  RAISE;

END display_data_setup;

END hri_opl_data_setup_dgnstc;

/
