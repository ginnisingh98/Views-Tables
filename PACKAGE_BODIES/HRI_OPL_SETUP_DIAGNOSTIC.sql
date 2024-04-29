--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SETUP_DIAGNOSTIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SETUP_DIAGNOSTIC" AS
/* $Header: hripdgsp.pkb 120.7 2006/12/11 09:49:43 msinghai noship $ */

-- =========================================================================
--
-- OVERVIEW
-- --------
-- This package contains procedures to display the set up of DBI in
-- the system.
-- Checks is performed for the following:
--  (a) Profiles
--  (b) Fast Formulas
--  (c) Triggers
--  (d) Key DBI Tables
--  (e) Job Family and Job Function
--  (f) Geography
--
-- =========================================================================

TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE g_varchar2_ind_tab_type IS TABLE OF VARCHAR2(240) INDEX BY VARCHAR2(30);

TYPE g_impact_msg_rec IS RECORD
 (object_name    VARCHAR2(240),
  impact_msg     VARCHAR2(32000),
  doc_links_url  VARCHAR2(3200));

TYPE g_impact_msg_tab_type IS TABLE OF g_impact_msg_rec INDEX BY BINARY_INTEGER;

TYPE TOKEN_REC IS record(
     token varchar2(200)
);

g_empty_col_list          hri_bpl_conc_log.col_list_tab_type;
g_section_names           g_varchar2_ind_tab_type;
g_section_list            g_varchar2_tab_type;
g_concurrent_logging      BOOLEAN;
g_debugging               BOOLEAN;

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
-- Prints a message to the concurrent process log
-- ----------------------------------------------------------------------------
PROCEDURE output(p_text IN VARCHAR2) IS

BEGIN

  hri_bpl_conc_log.output(p_text);

END output;

-- ----------------------------------------------------------------------------
-- Procedure dbg decides whether to log the passed in message
-- depending on whether debug mode is set.
-- ----------------------------------------------------------------------------
PROCEDURE dbg(p_text IN VARCHAR2) IS
  --
BEGIN

  -- Output the message if debugging is on
  IF g_debugging THEN
    output(p_text);
  END IF;

END dbg;

-- ----------------------------------------------------------------------------
-- Function GET_MESSAGE takes the message name and returns back the
-- message text
--
-- INPUT PARAMETERS:
--       p_message: Name of the message.
-- ----------------------------------------------------------------------------
FUNCTION get_message(p_message IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN

  -- Return the message text
  fnd_message.set_name('HRI', p_message);
  RETURN fnd_message.get;

END get_message;

-- ----------------------------------------------------------------------------
-- Initialize global array
-- ----------------------------------------------------------------------------
PROCEDURE set_globals IS

BEGIN

  g_section_names('PROFILE') := hr_bis.bis_decode_lookup
                                 ('HRI_DGNSTC_SECTION', 'PROFILE');
  g_section_names('FORMULA') := hr_bis.bis_decode_lookup
                                 ('HRI_DGNSTC_SECTION', 'FORMULA');
  g_section_names('TRIGGER') := hr_bis.bis_decode_lookup
                                 ('HRI_DGNSTC_SECTION', 'TRIGGER');
  g_section_names('TABLE') := hr_bis.bis_decode_lookup
                               ('HRI_DGNSTC_SECTION', 'TABLE');
  g_section_names('JOB_HIERARCHY') := hr_bis.bis_decode_lookup
                                       ('HRI_DGNSTC_SECTION', 'JOB_HIERARCHY');
  g_section_names('GEOG_HIERARCHY') := hr_bis.bis_decode_lookup
                                        ('HRI_DGNSTC_SECTION', 'GEOG_HIERARCHY');
  g_section_names('BUCKET') := hr_bis.bis_decode_lookup
                                ('HRI_DGNSTC_SECTION', 'BUCKET');

  g_section_list(1) := 'PROFILE';
  g_section_list(2) := 'FORMULA';
  g_section_list(3) := 'TRIGGER';
  g_section_list(4) := 'TABLE';
  g_section_list(5) := 'JOB_HIERARCHY';
  g_section_list(6) := 'GEOG_HIERARCHY';
  g_section_list(7) := 'BUCKET';

END set_globals;

-- ----------------------------------------------------------------------------
-- Gets objects
-- ----------------------------------------------------------------------------
FUNCTION get_objects(p_object_type      IN VARCHAR2,
                     p_functional_area  IN VARCHAR2,
                     p_object_name      IN VARCHAR2 DEFAULT NULL)
    RETURN g_varchar2_tab_type IS

  -- Cursor returning all diagnostics for a given type
  -- and functional area
  CURSOR c_objects IS
  SELECT
   stp.object_name
  FROM
   hri_adm_dgnstc_setup   stp
  ,hri_adm_dgnstc_sbscrb  sbs
  WHERE stp.object_type= p_object_type
  AND stp.object_name = sbs.object_name
  AND stp.object_type = sbs.object_type
  AND sbs.functional_area_cd = p_functional_area
  AND (p_object_name IS NULL OR stp.object_name = p_object_name)
  AND stp.enabled_flag='Y'
  AND ((stp.foundation_hr_flag = 'Y' AND
        hri_bpl_system.is_full_hr_installed = 'N')
    OR hri_bpl_system.is_full_hr_installed = 'Y')
  ORDER BY 1;

  -- Cursor returning all diagnostics for a given type
  CURSOR c_objects_all IS
  SELECT stp.object_name
  FROM
   hri_adm_dgnstc_setup  stp
  WHERE stp.object_type= p_object_type
  AND (p_object_name IS NULL OR stp.object_name = p_object_name)
  AND stp.enabled_flag='Y'
  AND ((stp.foundation_hr_flag = 'Y' AND
        hri_bpl_system.is_full_hr_installed = 'N')
    OR hri_bpl_system.is_full_hr_installed = 'Y')
  ORDER BY 1;

  l_object_tab        g_varchar2_tab_type;

BEGIN

  -- Open appropriate cursor for given functional area
  IF (p_functional_area = 'ALL' OR
      p_functional_area IS NULL) THEN

    -- Populate  object table with all objects
    OPEN c_objects_all;
    FETCH c_objects_all BULK COLLECT INTO
     l_object_tab;
    CLOSE c_objects_all;

  ELSE

    -- Populate object table with objects for functional area
    OPEN c_objects;
    FETCH c_objects BULK COLLECT INTO
     l_object_tab;
    CLOSE c_objects;

  END IF;

  -- Return object list
  RETURN l_object_tab;

END get_objects;

-- ----------------------------------------------------------------------------
-- Gets sections
-- ----------------------------------------------------------------------------
FUNCTION get_sections(p_functional_area  IN VARCHAR2)
       RETURN g_varchar2_tab_type IS

  l_section_tab  g_varchar2_tab_type;
  l_index        PLS_INTEGER;
  l_object_tab   g_varchar2_tab_type;
  l_object_name  VARCHAR2(240);
  l_object_type  VARCHAR2(240);

BEGIN

  -- Initialize number of sections found
  l_index := 0;

  -- Loop through possible sections
  FOR i IN g_section_list.FIRST..g_section_list.LAST LOOP

    -- Set object name and type for check
    IF (g_section_list(i) = 'JOB_HIERARCHY') THEN
      l_object_type := 'TABLE';
      l_object_name := 'HRI_CS_JOBH_CT';
    ELSIF (g_section_list(i) = 'GEOG_HIERARCHY') THEN
      l_object_type := 'TABLE';
      l_object_name := 'HRI_CS_GEO_LOCHR_CT';
    ELSE
      l_object_type := g_section_list(i);
      l_object_name := NULL;
    END IF;

    -- Special case for fast formula
    IF (g_section_list(i) = 'FORMULA') THEN

      -- Get list of objects for section
      l_object_tab := get_objects
                       (p_functional_area => p_functional_area,
                        p_object_type => 'USER_DEFN_FAST_FORMULA');

      -- Check both types of formula if necessary
      IF (NOT l_object_tab.EXISTS(1)) THEN
      l_object_tab := get_objects
                       (p_functional_area => p_functional_area,
                        p_object_type => 'SEEDED_FAST_FORMULA');
      END IF;

    ELSE

      -- Get list of objects for section
      l_object_tab := get_objects
                       (p_functional_area => p_functional_area,
                        p_object_name => l_object_name,
                        p_object_type => l_object_type);
    END IF;

    -- If any objects to process in section, add to list
    IF (l_object_tab.EXISTS(1)) THEN
      l_index := l_index + 1;
      l_section_tab(l_index) := g_section_list(i);
    END IF;

  END LOOP;

  RETURN l_section_tab;

END get_sections;

-- ----------------------------------------------------------------------------
-- Prints a header for the output file
-- ----------------------------------------------------------------------------
PROCEDURE display_header(p_functional_area  IN VARCHAR2) IS

  l_header_msg   VARCHAR2(32000);
  l_title        VARCHAR2(80);
  l_section_tab  g_varchar2_tab_type;

BEGIN

  -- Print message to conc log
  output(get_message('HRI_407465_LOG_TO_OUTPUT'));

  -- Get title and header message
  l_title      := hr_bis.bis_decode_lookup('HRI_DGNSTC_TITLE', 'SYSTEM');
  l_header_msg := get_message('HRI_407180_SETUP_MSG');

  -- Print html header
  output(p_text      => l_title,
         p_line_type => 'TITLE');

  -- Display log header
  output(p_text      => l_title,
         p_line_type => 'HEADER1');

  output(p_text      => l_header_msg,
         p_line_type => 'PARAGRAPH');

  -- Get list of all sections to be displayed
  l_section_tab := get_sections(p_functional_area);

  -- Print list
  IF (l_section_tab.EXISTS(1)) THEN

    output(p_text => '',
           p_line_type => 'LIST_HEADER');

    FOR i IN l_section_tab.FIRST..l_section_tab.LAST LOOP
      output(p_text => '<a href="#' || l_section_tab(i) || '">' ||
                       g_section_names(l_section_tab(i)) || '</a>',
             p_line_type => 'LIST_ITEM');
    END LOOP;

    output(p_text => '',
           p_line_type => 'LIST_FOOTER');

  END IF;

END display_header;

-- ----------------------------------------------------------------------------
-- Prints a footer for the output file
-- ----------------------------------------------------------------------------
PROCEDURE display_footer IS

BEGIN

  -- Print html footer
  output(p_text      => null,
         p_line_type => 'FOOTER');

END display_footer;

-- ----------------------------------------------------------------------------
-- Prints output messages
-- ----------------------------------------------------------------------------
PROCEDURE display_impact_messages
 (p_impact_msg_tab   IN g_impact_msg_tab_type,
  p_index            IN PLS_INTEGER) IS

BEGIN

  -- Display the impact messages
  IF p_index > 0 THEN

    -- Print impact subheading
    output(p_text      => hr_bis.bis_decode_lookup('HRI_DGNSTC_SECTION', 'IMPACT'),
           p_line_type => 'HEADER3');

    -- Loop through impact messages
    FOR i IN 1..p_index LOOP

      -- Print impact messages
      output(p_text      => p_impact_msg_tab(i).object_name,
             p_line_type => 'HEADER4');
      output(p_text      => p_impact_msg_tab(i).impact_msg,
             p_line_type => 'TEXT');
      output(p_text      => p_impact_msg_tab(i).doc_links_url,
             p_line_type => 'PARAGRAPH');

    END LOOP;

  END IF;

END display_impact_messages;


-- ----------------------------------------------------------------------------
-- Procedure display_section_header prints a section header
-- ----------------------------------------------------------------------------
PROCEDURE display_section_header(p_text  IN VARCHAR2) IS

BEGIN

  output(p_text      => null,
         p_line_type => 'SPACER BAR');

  output(p_text      => '<a name="' || p_text || '">' ||
                        g_section_names(p_text) || '</a>',
         p_line_type => 'HEADER2');

END display_section_header;

-- ----------------------------------------------------------------------------
-- Procedure display_profiles checks the values for the profiles defined in the
-- set up diagnostics table.
-- ----------------------------------------------------------------------------
PROCEDURE display_profiles(p_functional_area  IN VARCHAR2) IS

  l_user_profile_name      VARCHAR2(240);
  l_profile_value          VARCHAR2(240);
  l_profile_tab            g_varchar2_tab_type;
  l_impact_msg_tab         g_impact_msg_tab_type;
  l_col_list               hri_bpl_conc_log.col_list_tab_type;
  l_impact                 BOOLEAN;
  l_impact_msg             VARCHAR2(32000);
  l_doc_links_url          VARCHAR2(32000);
  l_impact_index           PLS_INTEGER;

BEGIN

  -- Get list of profile options to process
  l_profile_tab := get_objects
                    (p_object_type => 'PROFILE',
                     p_functional_area => p_functional_area);

  -- Check there is something to do
  IF (l_profile_tab.EXISTS(1)) THEN

    -- Output the section header
    display_section_header('PROFILE');

    -- Set up the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'PROFILE_NAME');
    l_col_list(1).column_length := 54;
    l_col_list(2).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'VALUE');
    l_col_list(2).column_length := 20;

    -- Output the table header
    output(p_text      => null,
           p_line_type => 'TABLE_HEADER',
           p_col_list  => l_col_list);

    -- Initialize the impact table
    l_impact_index := 0;

    -- Loop through profile diagnostics
    FOR i IN l_profile_tab.FIRST..l_profile_tab.LAST LOOP

      -- Get the profile option details
      hri_bpl_setup_diagnostic.check_profile_option
       (p_profile_name      => l_profile_tab(i),
        p_functional_area   => p_functional_area,
        p_user_profile_name => l_user_profile_name,
        p_profile_value     => l_profile_value,
        p_impact            => l_impact,
        p_impact_msg        => l_impact_msg,
        p_doc_links_url     => l_doc_links_url);

      -- Display the profile name and value
      l_col_list(1).column_value  := l_user_profile_name;
      l_col_list(2).column_value  := l_profile_value;
      output(p_text      => null,
             p_line_type => 'TABLE_ROW',
             p_col_list  => l_col_list);

      -- Add impact to table
      IF l_impact THEN
        l_impact_index := l_impact_index + 1;
        l_impact_msg_tab(l_impact_index).object_name   := l_user_profile_name;
        l_impact_msg_tab(l_impact_index).impact_msg    := l_impact_msg;
        l_impact_msg_tab(l_impact_index).doc_links_url := l_doc_links_url;
      END IF;

    END LOOP;

    -- Output the table footer
    output(p_text      => null,
           p_line_type => 'TABLE_FOOTER');

  END IF;

  -- Display any impact messages
  display_impact_messages
   (p_impact_msg_tab => l_impact_msg_tab,
    p_index          => l_impact_index);

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_profiles');
  RAISE;

END display_profiles;

-- ----------------------------------------------------------------------------
-- Procedure display_fast_formula checks the status of all the fast formulas
-- in the set up diagnostics table.
-- ----------------------------------------------------------------------------
PROCEDURE display_fast_formula(p_functional_area    IN VARCHAR2) IS

  l_formula_list           g_varchar2_tab_type;
  l_user_formula_list      g_varchar2_tab_type;
  l_impact_msg_tab         g_impact_msg_tab_type;
  l_col_list               hri_bpl_conc_log.col_list_tab_type;
  l_impact_index           PLS_INTEGER;
  l_formula_tab            hri_bpl_setup_diagnostic.fast_formula_tab_type;
  l_formula_impact         hri_bpl_setup_diagnostic.impact_msg_tab_type;
  l_msg_code               VARCHAR2(240);

BEGIN

  -- Initialize variables
  l_impact_index := 0;

  -- Get list of seeded fast formulas to process
  l_formula_list := get_objects
                     (p_object_type => 'SEEDED_FAST_FORMULA',
                      p_functional_area => p_functional_area);

  -- Get list of user defined fast formulas to process
  l_user_formula_list := get_objects
                          (p_object_type => 'USER_DEFN_FAST_FORMULA',
                           p_functional_area => p_functional_area);

  -- If there is any formulas to process
  IF (l_formula_list.EXISTS(1) OR
      l_user_formula_list.EXISTS(1)) THEN

    -- Print section header
    display_section_header('FORMULA');

  END IF;

  -- Display diagnostic output for any seeded fast formulas
  IF (l_formula_list.EXISTS(1)) THEN

    output(p_text      => hr_bis.bis_decode_lookup('HRI_DGNSTC_SECTION', 'SYSTEM'),
           p_line_type => 'HEADER3');

    -- Set up the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'FORMULA_NAME');
    l_col_list(1).column_length := 50;
    l_col_list(2).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'STATUS');
    l_col_list(2).column_length := 10;

    -- Print table header
    output(p_text      => null,
           p_line_type => 'TABLE_HEADER',
           p_col_list  => l_col_list);

    -- Loop through the seeded fast formulas in the diagnostics table
    FOR i IN l_formula_list.FIRST..l_formula_list.LAST LOOP

      -- Get formula information
      hri_bpl_setup_diagnostic.check_fast_formula
       (p_ff_name         => l_formula_list(i),
        p_functional_area => p_functional_area,
        p_type            => 'SEEDED',
        p_formula_tab     => l_formula_tab,
        p_impact_msg_tab  => l_formula_impact);

      -- Seeded fast formula expect only one record
      IF (l_formula_tab.EXISTS(1)) THEN

        -- Update the column structure
        l_col_list(1).column_value  := l_formula_list(i);
        l_col_list(2).column_value  := l_formula_tab(1).status;

        -- Output the row with seeded formula info
        output(p_text      => null,
               p_line_type => 'TABLE_ROW',
               p_col_list  => l_col_list);

        -- Store any impact message
        IF (l_formula_tab(1).impact_msg IS NOT NULL) THEN
          l_impact_index := l_impact_index + 1;
          l_impact_msg_tab(l_impact_index).object_name := l_formula_list(i);
          l_impact_msg_tab(l_impact_index).impact_msg  := l_formula_tab(1).impact_msg;
        END IF;

      END IF;

    END LOOP;

    -- Output the table footer
    output(p_text      => null,
           p_line_type => 'TABLE_FOOTER');

  END IF;

  -- Display diagnostic output for any user defined fast formulas
  IF (l_user_formula_list.EXISTS(1)) THEN

    -- Output section heading for user defined formulas
    output(p_text      => hr_bis.bis_decode_lookup('HRI_DGNSTC_SECTION', 'USER'),
           p_line_type => 'HEADER3');

    -- Set up the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'FORMULA_NAME');
    l_col_list(1).column_length := 30;
    l_col_list(2).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'BUSINESS_GROUP');
    l_col_list(2).column_length := 35;
    l_col_list(3).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'STATUS');
    l_col_list(3).column_length := 10;

    -- Output table header
    output(p_text      => null,
           p_line_type => 'TABLE_HEADER',
           p_col_list  => l_col_list);

    -- Loop through the user defined fast formulas in the diagnostics table
    FOR i IN l_user_formula_list.FIRST..l_user_formula_list.LAST LOOP

      -- Get formula information
      hri_bpl_setup_diagnostic.check_fast_formula
       (p_ff_name         => l_user_formula_list(i),
        p_functional_area => p_functional_area,
        p_type            => 'USER',
        p_formula_tab     => l_formula_tab,
        p_impact_msg_tab  => l_formula_impact);

      -- Loop through results
      IF (l_formula_tab.EXISTS(1)) THEN
        FOR j IN l_formula_tab.FIRST..l_formula_tab.LAST LOOP

          -- Update the column record
          l_col_list(1).column_value  := l_user_formula_list(i);
          l_col_list(2).column_value  := l_formula_tab(j).business_group_name;
          l_col_list(3).column_value  := l_formula_tab(j).status;

          -- Display the information about the user fast formula
          output(p_text      => null,
                 p_line_type => 'TABLE_ROW',
                 p_col_list  => l_col_list);

          -- Store any impact message
          IF (l_formula_tab(1).impact_msg IS NOT NULL) THEN
            l_impact_index := l_impact_index + 1;
            l_impact_msg_tab(l_impact_index).object_name := l_user_formula_list(i);
            l_impact_msg_tab(l_impact_index).impact_msg  := l_formula_tab(1).impact_msg;
          END IF;

        END LOOP;
      END IF;

      -- Store any general impact messages
      BEGIN
        l_msg_code := l_formula_impact.FIRST;
        WHILE l_msg_code IS NOT NULL LOOP
          l_impact_index := l_impact_index + 1;
          l_impact_msg_tab(l_impact_index).object_name := l_user_formula_list(i);
          l_impact_msg_tab(l_impact_index).impact_msg  :=
                  l_formula_impact(l_msg_code).impact_msg;
          l_impact_msg_tab(l_impact_index).doc_links_url :=
                  l_formula_impact(l_msg_code).doc_links_url;
          l_msg_code := l_formula_impact.NEXT(l_msg_code);
        END LOOP;
      EXCEPTION WHEN OTHERS THEN
        null;
      END;

    END LOOP;

    -- Output the table footer
    output(p_text      => null,
           p_line_type => 'TABLE_FOOTER');

  END IF;

  -- Display any impact messages
  display_impact_messages
   (p_impact_msg_tab => l_impact_msg_tab,
    p_index          => l_impact_index);

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_fast_formula');
  RAISE;

END display_fast_formula;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_triggers checks whether the triggers are generated and
-- enabled
-- ----------------------------------------------------------------------------
PROCEDURE display_triggers(p_functional_area   IN VARCHAR2) IS

  l_trigger_list           g_varchar2_tab_type;
  l_impact_msg_tab         g_impact_msg_tab_type;
  l_impact_index           PLS_INTEGER;
  l_col_list               hri_bpl_conc_log.col_list_tab_type;
  l_generated              VARCHAR2(240);
  l_enabled                VARCHAR2(240);
  l_status                 VARCHAR2(240);
  l_impact                 BOOLEAN;
  l_impact_msg             VARCHAR2(32000);
  l_doc_links_url          VARCHAR2(32000);

BEGIN

  -- Initialize variables
  l_impact_index := 0;

  -- Get list of triggers to process
  l_trigger_list := get_objects
                    (p_object_type => 'TRIGGER',
                     p_functional_area => p_functional_area);

  -- Display diagnostic output for any triggers
  IF (l_trigger_list.EXISTS(1)) THEN

    -- Print the section heading
    display_section_header('TRIGGER');

    -- Set up the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'TRIGGER_NAME');
    l_col_list(1).column_length := 40;
    l_col_list(2).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'GENERATED');
    l_col_list(2).column_length := 10;
    l_col_list(3).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'ENABLED');
    l_col_list(3).column_length := 8;
    l_col_list(4).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'STATUS');
    l_col_list(4).column_length := 10;

    -- Output the table header
    output(p_text      => null,
           p_line_type => 'TABLE_HEADER',
           p_col_list  => l_col_list);

    -- Loop through triggers to process
    FOR i IN l_trigger_list.FIRST..l_trigger_list.LAST LOOP

      -- Get the trigger info
      hri_bpl_setup_diagnostic.check_triggers
       (p_trigger_name    => l_trigger_list(i),
        p_functional_area => p_functional_area,
        p_generated       => l_generated,
        p_enabled         => l_enabled,
        p_status          => l_status,
        p_impact          => l_impact,
        p_impact_msg      => l_impact_msg,
        p_doc_links_url   => l_doc_links_url);

      -- Update the column structure
      l_col_list(1).column_value  :=  l_trigger_list(i);
      l_col_list(2).column_value  := l_generated;
      l_col_list(3).column_value  := l_enabled;
      l_col_list(4).column_value  := l_status;

      -- Display the trigger information
      output(p_text      => null,
             p_line_type => 'TABLE_ROW',
             p_col_list  => l_col_list);

      -- Store any impact messages
      IF l_impact THEN
        l_impact_index := l_impact_index + 1;
        l_impact_msg_tab(l_impact_index).object_name   := l_trigger_list(i);
        l_impact_msg_tab(l_impact_index).impact_msg    := l_impact_msg;
        l_impact_msg_tab(l_impact_index).doc_links_url := l_doc_links_url;
      END IF;

    END LOOP;

    -- Output the table footer
    output(p_text      => null,
           p_line_type => 'TABLE_FOOTER');

  END IF;

  -- Display any impact messages
  display_impact_messages
   (p_impact_msg_tab => l_impact_msg_tab,
    p_index          => l_impact_index);

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_triggers');
  RAISE;

END display_triggers;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_dbi_tables to check if the key DBI tables are populated
-- ----------------------------------------------------------------------------
PROCEDURE display_dbi_tables(p_functional_area   IN VARCHAR2) IS

  l_table_list             g_varchar2_tab_type;
  l_impact_msg_tab         g_impact_msg_tab_type;
  l_impact_index           PLS_INTEGER;
  l_col_list               hri_bpl_conc_log.col_list_tab_type;
  l_status                 VARCHAR2(240);
  l_impact                 BOOLEAN;
  l_impact_msg             VARCHAR2(32000);
  l_doc_links_url          VARCHAR2(32000);

BEGIN

  -- Initialize variables
  l_impact_index := 0;

  -- Get list of tables to process
  l_table_list := get_objects
                  (p_object_type => 'TABLE',
                   p_functional_area => p_functional_area);

  -- Display diagnostic output for any tables
  IF (l_table_list.EXISTS(1)) THEN

    -- Print the section heading
    display_section_header('TABLE');

    -- Set up the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'TABLE_NAME');
    l_col_list(1).column_length := 40;
    l_col_list(2).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'STATUS');
    l_col_list(2).column_length := 10;

    -- Output the table header
    output(p_text      => null,
           p_line_type => 'TABLE_HEADER',
           p_col_list  => l_col_list);

    -- Loop through tables to process
    FOR i IN l_table_list.FIRST..l_table_list.LAST LOOP

      -- Get the table info
      hri_bpl_setup_diagnostic.check_dbi_tables
       (p_table_name      => l_table_list(i),
        p_functional_area => p_functional_area,
        p_status          => l_status,
        p_impact          => l_impact,
        p_impact_msg      => l_impact_msg,
        p_doc_links_url   => l_doc_links_url);

      -- Update the column structure
      l_col_list(1).column_value  := l_table_list(i);
      l_col_list(2).column_value  := l_status;

      -- Display the table information
      output(p_text      => null,
             p_line_type => 'TABLE_ROW',
             p_col_list  => l_col_list);

      -- Only display first impact message to avoid repetition
      IF (l_impact AND l_impact_index = 0) THEN
        l_impact_index := l_impact_index + 1;
        l_impact_msg_tab(l_impact_index).impact_msg    := l_impact_msg;
        l_impact_msg_tab(l_impact_index).doc_links_url := l_doc_links_url;
      END IF;

    END LOOP;

    -- Output the table footer
    output(p_text      => null,
           p_line_type => 'TABLE_FOOTER');

  END IF;

  -- Display any impact messages
  display_impact_messages
   (p_impact_msg_tab => l_impact_msg_tab,
    p_index          => l_impact_index);

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_dbi_tables');
  RAISE;

END display_dbi_tables;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_job checks if the set up for Job Family and Job Function. It
-- checks all the structures in Job Flexfield for Job Family and Function
-- segments
-- ----------------------------------------------------------------------------
PROCEDURE display_job (p_functional_area  IN VARCHAR2) IS

  l_table_list             g_varchar2_tab_type;
  l_impact_msg_tab         g_impact_msg_tab_type;
  l_impact_index           PLS_INTEGER;
  l_index                  VARCHAR2(240);
  l_col_list               hri_bpl_conc_log.col_list_tab_type;
  l_job_family_mode        VARCHAR2(30);
  l_job_function_mode      VARCHAR2(30);
  l_flex_structure_tab     hri_bpl_setup_diagnostic.job_flex_tab_type;
  l_status                 VARCHAR2(240);
  l_impact                 BOOLEAN;
  l_impact_msg             VARCHAR2(32000);
  l_doc_links_url          VARCHAR2(32000);

BEGIN

  -- Initialize variables
  l_impact_index := 0;

  -- Get list of tables to process
  l_table_list := get_objects
                   (p_object_type => 'TABLE',
                    p_functional_area => p_functional_area,
                    p_object_name => 'HRI_CS_JOBH_CT');

  -- Display diagnostic output if job table is in list
  IF (l_table_list.EXISTS(1)) THEN

    -- Print the section heading
    display_section_header('JOB_HIERARCHY');

    -- Set up the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'FLEXFIELD_STRUCTURE');
    l_col_list(1).column_length := 28;
    l_col_list(2).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'JOB_FAMILY');
    l_col_list(2).column_length := 13;
    l_col_list(3).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'JOB_FUNCTION');
    l_col_list(3).column_length := 13;

    -- Output the table header
    output(p_text      => null,
           p_line_type => 'TABLE_HEADER',
           p_col_list  => l_col_list);

    -- Get the job structure details
    hri_bpl_setup_diagnostic.check_job
     (p_job_family_mode    => l_job_family_mode,
      p_job_function_mode  => l_job_function_mode,
      p_flex_structure_tab => l_flex_structure_tab,
      p_impact             => l_impact,
      p_impact_msg         => l_impact_msg,
      p_doc_links_url      => l_doc_links_url);

    -- Update the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'FLEXFIELD_TYPE');
    l_col_list(2).column_value  := l_job_family_mode;
    l_col_list(3).column_value  := l_job_function_mode;

    -- Display the flexfield type information
    output(p_text      => null,
           p_line_type => 'TABLE_ROW',
           p_col_list  => l_col_list);

    -- Loop through all the structures returned
    BEGIN

      -- Set index to first structure
      l_index := l_flex_structure_tab.FIRST;

      -- Loop through structures
      WHILE l_index IS NOT NULL LOOP

        -- Update the column structure
        l_col_list(1).column_value  :=
                   l_flex_structure_tab(l_index).structure_name;
        l_col_list(2).column_value  :=
                   l_flex_structure_tab(l_index).job_family_defined_msg;
        l_col_list(3).column_value  :=
                   l_flex_structure_tab(l_index).job_function_defined_msg;

        -- Display the flexfield structure information
        output(p_text      => null,
               p_line_type => 'TABLE_ROW',
               p_col_list  => l_col_list);

        -- Move index on
        l_index := l_flex_structure_tab.NEXT(l_index);

      END LOOP;

    -- Trap exceptions when no structures are returned
    EXCEPTION WHEN OTHERS THEN
      null;
    END;

    -- Store any impact message
    IF l_impact THEN
      l_impact_index := l_impact_index + 1;
      l_impact_msg_tab(l_impact_index).impact_msg  := l_impact_msg;
      l_impact_msg_tab(l_impact_index).doc_links_url := l_doc_links_url;
    END IF;

    -- Output the table footer
    output(p_text      => null,
           p_line_type => 'TABLE_FOOTER');

  END IF;

  -- Display any impact messages
  display_impact_messages
   (p_impact_msg_tab => l_impact_msg_tab,
    p_index          => l_impact_index);

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_job');
  RAISE;

END display_job;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_geography checks if the set up for Region. It
-- checks all the structures in Addistional Location Details for the Region
-- segment.
-- ----------------------------------------------------------------------------
PROCEDURE display_geography(p_functional_area   IN VARCHAR2) IS

  l_table_list             g_varchar2_tab_type;
  l_impact_msg_tab         g_impact_msg_tab_type;
  l_impact_index           PLS_INTEGER;
  l_col_list               hri_bpl_conc_log.col_list_tab_type;
  l_context_name           VARCHAR2(240);
  l_flex_column            VARCHAR2(240);
  l_status                 VARCHAR2(240);
  l_impact                 BOOLEAN;
  l_impact_msg             VARCHAR2(32000);

BEGIN

  -- Initialize variables
  l_impact_index := 0;

  -- Get list of tables to process
  l_table_list := get_objects
                   (p_object_type => 'TABLE',
                    p_functional_area => p_functional_area,
                    p_object_name => 'HRI_CS_GEO_LOCHR_CT');

  -- Display diagnostic output if geography table is in list
  IF (l_table_list.EXISTS(1)) THEN

    -- Print the section heading
    display_section_header('GEOG_HIERARCHY');

    -- Set up the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'FLEXFIELD_STRUCTURE');
    l_col_list(1).column_length := 25;
    l_col_list(2).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'GEOG_REGION_SEGMENT');
    l_col_list(2).column_length := 16;
    l_col_list(3).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'STATUS');
    l_col_list(3).column_length := 10;

    -- Output the table header
    output(p_text      => null,
           p_line_type => 'TABLE_HEADER',
           p_col_list  => l_col_list);

    -- Get the diagnostic information
    hri_bpl_setup_diagnostic.check_geography
     (p_context_name => l_context_name,
      p_flex_column  => l_flex_column,
      p_status       => l_status,
      p_impact       => l_impact,
      p_impact_msg   => l_impact_msg);

    -- Update the column structure
    l_col_list(1).column_value  := l_context_name;
    l_col_list(2).column_value  := l_flex_column;
    l_col_list(3).column_value  := l_status;

    -- Display geography information
    output(p_text      => null,
           p_line_type => 'TABLE_ROW',
           p_col_list  => l_col_list);

    -- Store any impact message
    IF l_impact THEN
      l_impact_index := l_impact_index + 1;
      l_impact_msg_tab(l_impact_index).impact_msg  := l_impact_msg;
    END IF;

    -- Output the table footer
    output(p_text      => null,
           p_line_type => 'TABLE_FOOTER');

  END IF;

  -- Display any impact messages
  display_impact_messages
   (p_impact_msg_tab => l_impact_msg_tab,
    p_index          => l_impact_index);

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_geography');
  RAISE;

END display_geography;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_bucket checks if buckets have the correct number of ranges
-- ----------------------------------------------------------------------------
PROCEDURE display_bucket(p_functional_area  IN VARCHAR2) IS

  l_bucket_list            g_varchar2_tab_type;
  l_impact_msg_tab         g_impact_msg_tab_type;
  l_impact_index           PLS_INTEGER;
  l_col_list               hri_bpl_conc_log.col_list_tab_type;
  l_user_bucket_name       VARCHAR2(240);
  l_status                 VARCHAR2(240);
  l_impact                 BOOLEAN;
  l_impact_msg             VARCHAR2(32000);
  l_doc_links_url          VARCHAR2(32000);

BEGIN

  -- Initialize variables
  l_impact_index := 0;

  -- Get list of tables to process
  l_bucket_list := get_objects
                    (p_object_type => 'BUCKET',
                     p_functional_area => p_functional_area);

  -- Display diagnostic output for any buckets
  IF (l_bucket_list.EXISTS(1)) THEN

    -- Print the section heading
    display_section_header('BUCKET');

    -- Set up the column structure
    l_col_list(1).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'BUCKET_NAME');
    l_col_list(1).column_length := 60;
    l_col_list(2).column_value  := hr_bis.bis_decode_lookup
                                    ('HRI_DGNSTC_SECTION', 'STATUS');
    l_col_list(2).column_length := 10;

    -- Output the table header
    output(p_text      => null,
           p_line_type => 'TABLE_HEADER',
           p_col_list  => l_col_list);

    -- Loop through buckets to process
    FOR i IN l_bucket_list.FIRST..l_bucket_list.LAST LOOP

      -- Get the bucket info
      hri_bpl_setup_diagnostic.check_buckets
       (p_bucket_name      => l_bucket_list(i),
        p_functional_area  => p_functional_area,
        p_user_bucket_name => l_user_bucket_name,
        p_status           => l_status,
        p_impact           => l_impact,
        p_impact_msg       => l_impact_msg,
        p_doc_links_url    => l_doc_links_url);

      -- Update the column structure
      l_col_list(1).column_value  := l_user_bucket_name;
      l_col_list(2).column_value  := l_status;

      -- Display the table information
      output(p_text      => null,
             p_line_type => 'TABLE_ROW',
             p_col_list  => l_col_list);

      -- Store any impact messages
      IF l_impact THEN
        l_impact_index := l_impact_index + 1;
        l_impact_msg_tab(l_impact_index).object_name   := l_user_bucket_name;
        l_impact_msg_tab(l_impact_index).impact_msg    := l_impact_msg;
        l_impact_msg_tab(l_impact_index).doc_links_url := l_doc_links_url;
      END IF;

    END LOOP;

    -- Output the table footer
    output(p_text      => null,
           p_line_type => 'TABLE_FOOTER');

  END IF;

  -- Display any impact messages
  display_impact_messages
   (p_impact_msg_tab => l_impact_msg_tab,
    p_index          => l_impact_index);

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_bucket');
  RAISE;

END display_bucket;

-- ----------------------------------------------------------------------------
-- PROCEDURE display_setup is called from the concurrent manager which in
-- turn calls the other procedures for the displaying dbi set up
-- ----------------------------------------------------------------------------
PROCEDURE display_setup (errbuf             OUT NOCOPY VARCHAR2,
                         retcode            OUT NOCOPY VARCHAR2,
                         p_functional_area  IN VARCHAR2) IS

BEGIN

  -- Set the global variables
  set_concurrent_logging(TRUE);
  set_debugging(FALSE);
  set_globals;
  HRI_BPL_SETUP_DIAGNOSTIC.pplt_obj_farea_tab;
  -- Print a header
  display_header
   (p_functional_area => p_functional_area);

  -- Check the profiles
  display_profiles
   (p_functional_area => p_functional_area);

  -- Check the fast formulas
  display_fast_formula
   (p_functional_area => p_functional_area);

  -- Check the triggers
  display_triggers
   (p_functional_area => p_functional_area);

  -- Check the tables
  display_dbi_tables
   (p_functional_area => p_functional_area);

  -- Check job set up
  display_job
   (p_functional_area => p_functional_area);

  -- Check geography set up
  display_geography
   (p_functional_area => p_functional_area);

  -- Check the bucket setup
  display_bucket
   (p_functional_area => p_functional_area);

  -- Print footer
  display_footer;

EXCEPTION WHEN OTHERS THEN

  output('Exception Raised in display_setup');
  output(SQLERRM);
  output(SQLCODE);
  RAISE;

END display_setup;

END hri_opl_setup_diagnostic;

/
