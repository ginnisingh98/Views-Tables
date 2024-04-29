--------------------------------------------------------
--  DDL for Package Body PER_JP_EMPDET_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_EMPDET_REPORT_PKG" 
-- $Header: pejperpt.pkb 120.0.12010000.25 2009/09/29 13:38:10 mpothala noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pejperpt.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of per_jp_empdet_report_pkg
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   08-JUN-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * DATE        AUTHOR(S)  VERSION           BUG NO   DESCRIPTION
-- * -----------+---------+-----------------+---------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- * 17-APR-2009 SPATTEM    120.0.12010000.1  8574160  Creation
-- * 18-APR-2009 SPATTEM    120.0.12010000.8  8574160  Removed the usage of hr_locations table
-- *                                                   Included Employee Contact Information
-- * 23-JUN-2009 SPATTEM    120.0.12010000.9  8623733  included the condition for Organization Id is null in action_creation
-- * 01-JUL-2009 MDARBHA    120.1.12010000.10 8623733  Chnaged the 'action_creation' for Organization Hierarchy as per the bug 8623733
-- * 12-JUL-2009 MDARBHA    120.1.12010000.11 8574160  Changed the procedure Assact XML to fetch the lookup meaning.
-- * 12-JUL-2009 MDARBHA    120.1.12010000.12 8667163  Changed the procedure action creation to fetch the correct organzations if Organization Parameter is null
--                                                                                                       Removed the code adedd for Bug 8623733 as not required as per Bug  8667163
-- * 27-JUL-2009 MDARBHA    120.1.12010000.12 8666416  Chnaged the assact_xml procedure for date format issue in PDF
-- * 03-AUG-2009 MDARBHA    120.1.12010000.14 8740684  Changed the assact_xml procedure for ordering in asignment history
-- * 03-AUG-2009 MDARBHA    120.1.12010000.15 8740649  Changed the assact_xml procedure for previous job history
-- * 03-AUG-2009 MDARBHA    120.1.12010000.15 8740607  Changed the assact_xml procedure to display reason in termination reason.
-- * 04-AUG-2009 MDARBHA    120.1.12010000.16 8740684  Changed the assact_xml procedure for ordering in asignment history
-- * 04-AUG-2009 MDARBHA    120.1.12010000.17 8740684  Changed the assact_xml procedure for ordering in asignment history
-- * 04-AUG-2009 MDARBHA    120.1.12010000.18 8740684  Changed the assact_xml procedure for ordering in asignment history
-- * 04-AUG-2009 MDARBHA    120.1.12010000.19 8740684  Changed the assact_xml procedure for ordering in asignment history
-- * 19-AUG-2009 RDARASI    120.1.12010000.20 8766043  Changed sort_action Procedure
-- * 19-AUG-2009 RDARASI    120.1.12010000.20 8765317  Changed lcu_emp_det Cursor Query.
-- * 19-AUG-2009 RDARASI    120.1.12010000.20 8814075  Changed lcu_emp_det Cursor Query.
-- * 24-AUG-2009 RDARASI    120.1.12010000.21 8740649  Changed lcu_prev_job_hist Cursor Query.
-- * 09-Sep-2009 MPOTHALA   120.1.12010000.22 8843783  Added function to show correct previous job history.
-- * 14-Sep-2009 MPOTHALA   120.1.12010000.23 8843783  To Correct the function  for the bug get_previous_job_history
-- * 15-Sep-2009 MPOTHALA   120.1.12010000.24 8843783  To Correct the function  for the bug get_previous_job_history
-- * 15-Sep-2009 MPOTHALA   120.1.12010000.25 8843783  To Correct the function  for the bug get_previous_job_history
-- *******************************************************************************************************************************************************
AS
--
  g_write_xml             CLOB;
  g_xfdf_string           CLOB;
  gc_eol                  VARCHAR2(5)  := fnd_global.local_chr(10);
  gc_proc_name            VARCHAR2(240);
  gc_pkg_name             VARCHAR2(30) := 'per_jp_empdet_report_pkg.';
  gb_debug                BOOLEAN;
  gn_bg_id                NUMBER;
  gn_dummy                NUMBER       := -99 ;
  gn_all_exclusions_flag  NUMBER;
  gn_vctr                 NUMBER;

  gc_exception            EXCEPTION;
--
  FUNCTION cnv_str( p_text  IN  VARCHAR2
                  , p_start IN  NUMBER   DEFAULT NULL
                  , p_end   IN  NUMBER   DEFAULT NULL
                  )
  RETURN VARCHAR2
  --************************************************************************
  -- PROCEDURE
  --   cnv_str
  --
  -- DESCRIPTION
  --   This fucntion retunrs the string based on the start and end positions
  --   from the given text
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_text                     IN       This parameter passes Assignment Set Id
  -- p_start                    IN       This parameter passes Start Position
  -- p_end                      IN       This parameter passes End Position
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
    lc_text VARCHAR2(4000);
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location ('Entering CNV_STR',10);
    END IF;
--
    lc_text := LTRIM(RTRIM(REPLACE(p_text,TO_MULTI_BYTE(' '),' ')));
--
    IF p_start IS NOT NULL
    AND p_end IS NOT NULL THEN
      lc_text := SUBSTR(lc_text,p_start,p_end);
    END IF;
--
    IF gb_debug THEN
      hr_utility.set_location ('Leaving CNV_STR',10);
    END IF;
--
  RETURN lc_text;
--
  END cnv_str;
--
  FUNCTION htmlspchar(p_text IN VARCHAR2)
  RETURN VARCHAR2
  --************************************************************************
  -- PROCEDURE
  --   htmlspchar
  --
  -- DESCRIPTION
  --   This fucntion retunrs the string based on the start and end positions
  --   from the given text
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_text                     IN       This parameter passes Assignment Set Id
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
    lc_htmlspchar VARCHAR2(1) := 'N';
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location ('Entering htmlspchar',20);
    END IF;
--
    IF NVL(INSTR(p_text,'<'),0) > 0 THEN
      lc_htmlspchar := 'Y';
    END IF;
--
    IF lc_htmlspchar = 'N'
    AND NVL(INSTR(p_text,'>'),0) > 0 THEN
      lc_htmlspchar := 'Y';
    END IF;
--
    IF lc_htmlspchar = 'N'
    AND NVL(INSTR(p_text,'&'),0) > 0 THEN
      lc_htmlspchar := 'Y';
    END IF;
--
    IF lc_htmlspchar = 'N'
    AND NVL(INSTR(p_text,''''),0) > 0 THEN
      lc_htmlspchar := 'Y';
    END IF;
--
    IF lc_htmlspchar = 'N'
    AND NVL(INSTR(p_text,'"'),0) > 0 THEN
      lc_htmlspchar := 'Y';
    END IF;
--
    IF lc_htmlspchar = 'Y' then
      RETURN '<![CDATA['||p_text||']]>';
    ELSE
      RETURN p_text;
    END IF;
--
    IF gb_debug THEN
      hr_utility.set_location ('Leaving htmlspchar',20);
    END IF;
--
  END htmlspchar;
--
  PROCEDURE print_clob(p_clob CLOB)
  --************************************************************************
  -- PROCEDURE
  --   print_clob
  --
  -- DESCRIPTION
  --  This procedure prints contents of a CLOB object passed as  parameter.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_clob                     IN       This parameter passes clob object
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
  ln_chars  NUMBER;
  ln_offset NUMBER;
  lc_buf    VARCHAR2(255);
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location ('Entering print_clob',30);
    END IF;
--
    ln_chars := 240;
    ln_offset := 1;
    LOOP
      lc_buf := NULL;
      dbms_lob.read( p_clob
                   , ln_chars
                   , ln_offset
                   , lc_buf
                   );
      IF gb_debug THEN
        hr_utility.set_location(lc_buf,20);
      END IF;
      ln_offset := ln_offset + ln_chars;
    END LOOP;
--
    IF gb_debug THEN
      hr_utility.set_location ('Leaving print_clob',30);
    END IF;
--
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location ('No Data Found in Print Clob',999999);
    END IF;
  END print_clob;
--
 FUNCTION get_previous_job_history( p_mag_asg_action_id IN NUMBER)
  --************************************************************************
  -- FUNCTION
  -- get_job_history
  --
  -- DESCRIPTION
  --  Gets the job previous history for a person
  --  Added this function to resolve the bug 8843783
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN per_jp_empdet_report_pkg.gt_job_tbl
  AS
  CURSOR lcu_job_history(p_mag_asg_action_id NUMBER)
  IS
  SELECT  PJEDPJV.assignment_id
         ,PJEDPJV.company_name
         ,DECODE(PJEDPJV.employee_category,'REHIRE','*','')
         ||TO_CHAR(PJEDPJV.start_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''') start_date
         ,DECODE(TO_CHAR(PJEDPJV.end_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial'''),'H24.12.31',NULL
         ,TO_CHAR(PJEDPJV.end_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')) end_date
  FROM   per_jp_empdet_prev_job_v PJEDPJV
  WHERE  PJEDPJV.assignment_action_id = p_mag_asg_action_id
  AND    (PJEDPJV.employee_category  IS NULL OR PJEDPJV.employee_category <> 'REHIRE')
  ORDER BY PJEDPJV.end_date;
  --
  lt_job_id     per_jp_empdet_report_pkg.gt_job_tbl;
  lt_res_tb     per_jp_empdet_report_pkg.gt_job_tbl;
  ln_index      NUMBER := 0;
  ld_start_date VARCHAR2(20); -- Fix for the Bug 8843783
  ln_count      NUMBER:=0;

BEGIN

  FOR lr_job_history in lcu_job_history(p_mag_asg_action_id => p_mag_asg_action_id)
    LOOP
      ln_index := ln_index + 1;
      lt_job_id(ln_index).assignment_id  := lr_job_history.assignment_id;
      lt_job_id(ln_index).start_date     := lr_job_history.start_date;
      lt_job_id(ln_index).end_date       := lr_job_history.end_date;
      lt_job_id(ln_index).company_name   := lr_job_history.company_name;
      hr_utility.set_location('step1.... ',20);
       --
      IF gb_debug THEN
         hr_utility.set_location('p_mag_asg_action_id '||p_mag_asg_action_id,40);
         hr_utility.set_location('p_prev_assignment_id '||lr_job_history.assignment_id,40);
      END IF;

  END LOOP;
--
   hr_utility.set_location(ln_index,20);
   IF ln_index=1 THEN
     lt_res_tb(1).assignment_id   :=lt_job_id(1).assignment_id;
     lt_res_tb(1).start_date      :=lt_job_id(1).start_date;
     lt_res_tb(1).end_date        :=lt_job_id(1).end_date;
     lt_res_tb(1).company_name    :=lt_job_id(1).company_name;
     hr_utility.set_location('step2.... ',20);
   ELSE
      FOR i in 1..ln_index
        LOOP
          IF i<ln_index AND (lt_job_id(i).assignment_id=lt_job_id(i+1).assignment_id) THEN
            IF NVL(UPPER(lt_job_id(i).company_name),-999) <> NVL(UPPER(lt_job_id(i+1).company_name),-999) -- Added by RDARASI for BUG#8774235
              THEN
                IF i<>1 AND (lt_job_id(i).assignment_id = lt_job_id(i-1).assignment_id)
                        AND  NVL(UPPER(lt_job_id(i).company_name),-999) = NVL(UPPER(lt_job_id(i-1).company_name),-999) -- Added by RDARASI for BUG#8774235
                  THEN
                  lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                  lt_res_tb(i).start_date      :=ld_start_date;
                  lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                  lt_res_tb(i).company_name    :=lt_job_id(i).company_name;
                  ln_count:=0;
                  hr_utility.set_location('step3.... ',20);
               ELSE
                lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                lt_res_tb(i).start_date      :=lt_job_id(i).start_date;
                lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                lt_res_tb(i).company_name    :=lt_job_id(i).company_name;
                hr_utility.set_location('step4.... ',20);
              END IF;
            ELSE
               IF ln_count=0 THEN
                 ld_start_date:=lt_job_id(i).start_date;
                 hr_utility.set_location(' ld_start_date'||ld_start_date,20);
                 ln_count:=1;
               END IF;
            END IF;
          ELSE
            IF i<ln_index THEN
              IF (lt_job_id(i).assignment_id <> lt_job_id(i+1).assignment_id) THEN
                IF i<>1 AND (lt_job_id(i).assignment_id = lt_job_id(i-1).assignment_id)
                  AND  NVL(UPPER(lt_job_id(i).company_name),-999) = NVL(UPPER(lt_job_id(i-1).company_name),-999)-- Added by RDARASI for BUG#8774235
                  THEN
                    lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                    lt_res_tb(i).start_date      :=ld_start_date;
                    lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                    lt_res_tb(i).company_name    :=lt_job_id(i).company_name;
                    hr_utility.set_location('step5.... ',20);
                ELSE
                  lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                  lt_res_tb(i).start_date:=lt_job_id(i).start_date;
                  lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                  lt_res_tb(i).company_name:=lt_job_id(i).company_name;
                  hr_utility.set_location('step6.... ',20);
                END IF;
              END IF;
            ELSE
              IF (lt_job_id(i).assignment_id = lt_job_id(i-1).assignment_id)
                  AND  NVL(UPPER(lt_job_id(i).company_name),-999) = NVL(UPPER(lt_job_id(i-1).company_name),-999)-- Added by RDARASI for BUG#8774235
              THEN
                  lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                  lt_res_tb(i).start_date:=ld_start_date;
                  lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                  lt_res_tb(i).company_name:=lt_job_id(i).company_name;
                  hr_utility.set_location('step7.... ',20);
                  ELSE
                 lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                 lt_res_tb(i).start_date:=lt_job_id(i).start_date;
                 lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                 lt_res_tb(i).company_name:=lt_job_id(i).company_name;
                 hr_utility.set_location('step8.... ',20);
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;
    RETURN lt_res_tb;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in get_job_history',10);
    END IF;
    RETURN lt_res_tb;
  END get_previous_job_history;
--
PROCEDURE initialize(p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE )
--***************************************************************************
--   PROCEDURE
--   initialize
--
--  DESCRIPTION
--  This procedure is used to set global contexts
--
--   ACCESS
--   PUBLIC
--
--  PARAMETERS
--  ==========
--  NAME                       TYPE     DESCRIPTION
--  -----------------         -------- ---------------------------------------
--  p_payroll_action_id        IN       This parameter passes Payroll Action Id
--
--  PREREQUISITES
--   None
--
--  CALLED BY
--  initialization_code
--*************************************************************************
  IS
--
  CURSOR lcr_params(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
  IS
  SELECT fnd_number.canonical_to_number(pay_core_utils.get_parameter('PACTID',legislative_parameters)) payroll_action_id
        ,fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASETID',legislative_parameters)) assignment_set_id
        ,pay_core_utils.get_parameter('BG',legislative_parameters)                                     business_group_id
        ,pay_core_utils.get_parameter('ORG',legislative_parameters)                                    organization_id
        ,pay_core_utils.get_parameter('LOC',legislative_parameters)                                    location_id
        ,TO_DATE(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')            effective_date
        ,NVL(pay_core_utils.get_parameter('IOH',legislative_parameters),'Y')                           include_org_hierarchy
        ,pay_core_utils.get_parameter('ITE',legislative_parameters)                                    incl_term_emp
        ,TO_DATE(pay_core_utils.get_parameter('TEDF',legislative_parameters),'YYYY/MM/DD')             term_date_from
        ,TO_DATE(pay_core_utils.get_parameter('TEDT',legislative_parameters),'YYYY/MM/DD')             term_eff_date_to
        ,pay_core_utils.get_parameter('IMG',legislative_parameters)                                    img_display
        ,pay_core_utils.get_parameter('S1',legislative_parameters)                                     sort_order_1
        ,pay_core_utils.get_parameter('S2',legislative_parameters)                                     sort_order_2
        ,pay_core_utils.get_parameter('S3',legislative_parameters)                                     sort_order_3
  FROM  pay_payroll_actions PPA
  WHERE PPA.payroll_action_id  = p_payroll_action_id;
--
  -- Local Variables
  lc_procedure               VARCHAR2(200);
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      lc_procedure := gc_pkg_name||'initialize';
      hr_utility.set_location('Entering '||lc_procedure,40);
    END IF;
--
    -- Fetch the parameters passed by user into global variable.
    OPEN lcr_params(p_payroll_action_id);
    FETCH lcr_params into gr_parameters;
    CLOSE lcr_params;

    SELECT TO_DATE(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')
    INTO gr_parameters.effective_date
    FROM pay_payroll_actions PPA
    WHERE PPA.payroll_action_id  = gr_parameters.payroll_action_id;

--
    IF gb_debug THEN
      hr_utility.set_location('p_payroll_action_id.........           = ' || p_payroll_action_id,30);
      hr_utility.set_location('gr_parameters.payroll_action_id        = ' || gr_parameters.payroll_action_id,30);
      hr_utility.set_location('gr_parameters.assignment_set_id        = ' || gr_parameters.assignment_set_id,30);
      hr_utility.set_location('gr_parameters.organization_id......    = ' || gr_parameters.organization_id,30);
      hr_utility.set_location('gr_parameters.business_group_id....    = ' || gr_parameters.business_group_id,30);
      hr_utility.set_location('gr_parameters.location_id.......       = ' || gr_parameters.location_id,30);
      hr_utility.set_location('gr_parameters.effective_date.......    = ' || gr_parameters.effective_date,30);
      hr_utility.set_location('gr_parameters.include_org_hierarchy    = ' || gr_parameters.include_org_hierarchy,30);
      hr_utility.set_location('gr_parameters.incl_term_emp...  ...    = ' || gr_parameters.incl_term_emp,30);
      hr_utility.set_location('gr_parameters.term_eff_date_from...    = ' || gr_parameters.term_date_from,30);
      hr_utility.set_location('gr_parameters.term_eff_date_to.....    = ' || gr_parameters.term_date_to,30);
      hr_utility.set_location('gr_parameters.img_display              = ' || gr_parameters.img_display,30);
      hr_utility.set_location('gr_parameters.sort_order_1             = ' || gr_parameters.sort_order_1,30);
      hr_utility.set_location('gr_parameters.sort_order_2             = ' || gr_parameters.sort_order_2,30);
      hr_utility.set_location('gr_parameters.sort_order_3             = ' || gr_parameters.sort_order_3,30);
    END IF;
--
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,40);
    END IF;
--
  EXCEPTION
  WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in '||lc_procedure,999999);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    RAISE gc_exception;
  END initialize;
--
  PROCEDURE range_cursor( p_payroll_action_id IN         NUMBER
                        , p_sqlstr            OUT NOCOPY VARCHAR2
                        )
  --************************************************************************
  -- PROCEDURE
  --  range_cursor
  --
  -- DESCRIPTION
  --  This procedure defines a SQL statement to fetch all the people to be
  --  included in the report.This SQL statement is  used to define the
  --  'chunks' for multi-threaded operation.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ------------------------------------
  -- p_payroll_action_id        IN       This parameter passes payroll_action_id object
  -- p_sqlstr                   OUT      This parameter returns the SQL Statement
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  AS
    lc_proc_name             VARCHAR2(100);
  BEGIN
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      lc_proc_name := gc_pkg_name ||'range_cursor';
      hr_utility.set_location ('Entering '||lc_proc_name,50);
      hr_utility.set_location ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id,50);
    END IF;
--
    p_sqlstr := ' select distinct p.person_id'||
                ' from   per_people_f p,'||
                ' pay_payroll_actions pa'||
                ' where  pa.payroll_action_id = :payroll_action_id'||
                ' and    p.business_group_id = pa.business_group_id'||
                ' order by p.person_id ';
--
    g_mag_payroll_action_id := p_payroll_action_id;
--
    IF gb_debug THEN
      hr_utility.set_location ('Range cursor query : ' || p_sqlstr,50);
      hr_utility.set_location ('Leaving '||lc_proc_name,50);
    END IF;
  END range_cursor;
--
--Commented below as per the bug #8766043
/*
  PROCEDURE sort_action( p_payroll_action_id  IN            VARCHAR2
                       , sqlstr               IN OUT NOCOPY VARCHAR2
                       , len                     OUT NOCOPY NUMBER
                       )
  --************************************************************************
  -- PROCEDURE
  --  sort_action
  --
  -- DESCRIPTION
  --  This procedure defines a SQL statement to fetch all the people
  --  according to the sort order parameters.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ------------------------------------
  -- p_payroll_action_id        IN       This parameter passes payroll_action_id object
  -- p_sqlstr                   IN OUT   This parameter returns the SQL Statement
  -- len                           OUT   This parameter returns the length of the SQL string
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS

  lc_sort1            VARCHAR2(60);
  lc_sort2            VARCHAR2(60);
  lc_sort3            VARCHAR2(60);
  lc_term_flag        VARCHAR2(10);
  ld_term_strt_date   DATE;
  ld_term_end_date    DATE;
  ld_effective_date   DATE;
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location('Entering sort_action procedure',20);
    END IF;
--
    initialize(p_payroll_action_id);

    sqlstr :=  ' SELECT PAA.rowid
                 FROM per_assignments_f         PAF
                     ,pay_assignment_actions    PAA
                     ,per_people_f              PPF
                     ,hr_all_organization_units HAOU
                     ,per_periods_of_service    PPS
                 WHERE PAA.payroll_action_id         = :pactid
                 AND   PAF.assignment_id             = PAA.assignment_id
                 AND   PPF.person_id                 = PAF.person_id
                 AND   PAF.organization_id           = HAOU.organization_id
                 AND   PPS.period_of_service_id      = PAF.period_of_service_id
                 AND   NVL(TRUNC(PPS.actual_termination_date),'''||gr_parameters.effective_date||''') BETWEEN PPF.effective_start_date
                                                                                                          AND PPF.effective_end_date
                 AND   NVL(TRUNC(PPS.actual_termination_date),'''||gr_parameters.effective_date||''') BETWEEN PAF.effective_start_date
                                                                                                          AND PAF.effective_end_date
                 AND   ((   NVL('''||gr_parameters.incl_term_emp||''',''N'')       = ''Y''
                          AND(  PPS.actual_termination_date IS NULL
                           OR (TRUNC(PPS.actual_termination_date)  BETWEEN '''||gr_parameters.term_date_from||'''
                                                                       AND '''||gr_parameters.term_date_to||''')
                        )
                        )
                        OR
                        (   NVL('''||gr_parameters.incl_term_emp||''',''N'')       = ''N''
                        AND PPS.actual_termination_date IS NULL
                        )
                       )
                 ORDER BY DECODE('''||gr_parameters.sort_order_1||''',''EMPLOYEE_NAME'',PPF.full_name
                                                                     ,''ORGANIZATION_CODE'',HAOU.name
                                                                                           ,PPF.employee_number
                                )
                         ,DECODE('''||gr_parameters.sort_order_2||''',''EMPLOYEE_NAME'',PPF.full_name
                                                                     ,''ORGANIZATION_CODE'',HAOU.name
                                                                                           ,PPF.employee_number
                                )
                         ,DECODE('''||gr_parameters.sort_order_3||''',''EMPLOYEE_NAME'',PPF.full_name
                                                                     ,''ORGANIZATION_CODE'',HAOU.name
                                                                                           ,PPF.employee_number
                                )';

    len := length(sqlstr); -- return the length of the string
--
    IF gb_debug THEN
      hr_utility.set_location('End of the sort_Action cursor',20);
      hr_utility.set_location('Leaving sort_action procedure',20);
    END IF;
--
  END sort_action;
  */
-- Commented above as per the bug #8766043
--
-- Added below as per the bug #8766043
  PROCEDURE sort_action( p_payroll_action_id   IN     NUMBER
                        ,sqlstr                IN OUT NOCOPY VARCHAR2
                        ,len                   OUT   NOCOPY NUMBER
                       )
  --************************************************************************
  -- PROCEDURE
  --  sort_action
  --
  -- DESCRIPTION
  --  This procedure defines a SQL statement to fetch all the people
  --  according to the sort order parameters.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ------------------------------------
  -- p_payroll_action_id        IN       This parameter passes payroll_action_id object
  -- p_sqlstr                   IN OUT   This parameter returns the SQL Statement
  -- len                           OUT   This parameter returns the length of the SQL string
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  AS

  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.set_location('Entering sort_action procedure',20);
    END IF;
--
    hr_utility.trace('Beginning of the sort_action cursor');
--
    initialize(p_payroll_action_id);

    sqlstr :=  ' SELECT PAA.rowid
                 FROM per_assignments_f             PAF
                     ,pay_assignment_actions        PAA
                     ,per_people_f                  PPF
                     ,hr_all_organization_units_tl  HAOUT
                     ,hr_all_organization_units     HAOU
                     ,per_periods_of_service        PPS
                 WHERE PAA.payroll_action_id         = :pactid
                 AND   PAF.assignment_id             = PAA.assignment_id
                 AND   PPF.person_id                 = PAF.person_id
                 AND   PAF.organization_id           = HAOU.organization_id
                 AND   HAOUT.organization_id         = HAOU.organization_id
                 AND   HAOUT.language                = USERENV(''LANG'')
                 AND   PPS.period_of_service_id      = PAF.period_of_service_id
                 AND   NVL(TRUNC(PPS.actual_termination_date),'''||gr_parameters.effective_date||''') BETWEEN PPF.effective_start_date
                                                                                                          AND PPF.effective_end_date
                 AND   NVL(TRUNC(PPS.actual_termination_date),'''||gr_parameters.effective_date||''') BETWEEN PAF.effective_start_date
                                                                                                          AND PAF.effective_end_date
                 ORDER BY DECODE('''||gr_parameters.sort_order_1||''',''EMPLOYEE_NAME'',UPPER(PPF.last_name || '' '' || PPF.first_name)
                                                  ,''ORGANIZATION_CODE'',UPPER(HAOUT.name)
                                                                        ,UPPER(PPF.employee_number)
                                )
                         ,DECODE('''||gr_parameters.sort_order_2||''',''EMPLOYEE_NAME'',UPPER(PPF.last_name || '' '' || PPF.first_name)
                                                  ,''ORGANIZATION_CODE'',UPPER(HAOUT.name)
                                                                        ,UPPER(PPF.employee_number)
                                )
                         ,DECODE('''||gr_parameters.sort_order_3||''',''EMPLOYEE_NAME'',UPPER(PPF.last_name || '' '' || PPF.first_name)
                                                  ,''ORGANIZATION_CODE'',UPPER(HAOUT.name)
                                                                        ,UPPER(PPF.employee_number)
                                )';

    len := length(sqlstr);
    IF gb_debug
      THEN
      hr_utility.trace('End of the sort_Action cursor');
    END IF;
--
    EXCEPTION WHEN NO_DATA_FOUND THEN
      IF gb_debug THEN
        hr_utility.trace('Error in Sort Procedure - getting legislative param');
      END IF;
    RAISE;
--
END sort_action;
--
-- Added above as per the bug #8766043
--
  FUNCTION range_person_on
  --************************************************************************
  -- FUNCTION
  -- range_person_on
  --
  -- DESCRIPTION
  --  Checks if RANGE_PERSON_ID is enabled for
  --  Archive process.
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  assignment_action_code
  --************************************************************************
  RETURN BOOLEAN
  IS
--
  CURSOR lcu_action_parameter
  IS
  SELECT parameter_value
  FROM   pay_action_parameters
  WHERE  parameter_name = 'RANGE_PERSON_ID';
--
  lb_return           BOOLEAN;
  lc_action_param_val VARCHAR2(30);
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.set_location('Entering range_person_on',10);
    END IF;
--
    OPEN  lcu_action_parameter;
    FETCH lcu_action_parameter INTO lc_action_param_val;
    CLOSE lcu_action_parameter;
--
    IF lc_action_param_val = 'Y' THEN
      lb_return := TRUE;
      IF gb_debug THEN
        hr_utility.set_location('Range Person = True',10);
      END IF;
    ELSE
      lb_return := FALSE;
    END IF;
--
    IF gb_debug THEN
      hr_utility.set_location('Leaving range_person_on',10);
    END IF;
    RETURN lb_return;
--
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in range_person_on',10);
    END IF;
    lb_return := FALSE;
    RETURN lb_return;
  END range_person_on;
--
  PROCEDURE action_creation( p_payroll_action_id  IN NUMBER
                           , p_start_person_id    IN NUMBER
                           , p_end_person_id      IN NUMBER
                           , p_chunk              IN NUMBER
                           )
  --************************************************************************
  -- PROCEDURE
  --  action_creation
  --
  -- DESCRIPTION
  --  This procedure defines a SQL statement to fetch all the people to be
  --  included in the report.This SQL statement is  used to define the
  --  'chunks' for multi-threaded operation.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action ID
  -- p_start_person_id          IN       This parameter passes Start Person ID
  -- p_end_person_id            IN       This parameter passes End Person ID
  -- p_chunk                    IN       This parameter passes Chunk value
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  AS
--
  CURSOR lcu_assact_r( p_payroll_action_id_arch     pay_payroll_actions.payroll_action_id%TYPE
                     , p_business_group_id          per_assignments_f.business_group_id%TYPE
                     , p_organization_id            per_assignments_f.organization_id%TYPE
                     , p_location_id                per_assignments_f.location_id%TYPE
                     , p_include_term_flag          VARCHAR2
                     , p_term_eff_date_from         DATE
                     , p_term_eff_date_to           DATE
                     , p_effective_date             DATE
                     )
  IS
  SELECT PJEDV.assignment_id
       ,PJEDV.effective_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,per_jp_empdet_emp_v      PJEDV
        ,per_periods_of_service   PPOF
        ,pay_population_ranges    PPR
        ,pay_payroll_actions      PPA
  WHERE PAA.person_id                        = PAP.person_id
  AND   PPA.payroll_action_id                = PPR.payroll_action_id
  AND   PPA.payroll_action_id                = p_payroll_action_id
  AND   PPR.chunk_number                     = p_chunk
  AND   PPR.person_id                        = PAP.person_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   PAS.payroll_action_id                = p_payroll_action_id_arch
  AND   PPOF.person_id                       = PAP.person_id
  AND   PJEDV.assignment_action_id           = PAS.assignment_action_id
  AND   PJEDV.assignment_id                  = PAS.assignment_id
  AND   PAA.business_group_id                = p_business_group_id
  AND   PAA.organization_id                  = NVL(p_organization_id,PAA.organization_id)
  AND   NVL(PAA.location_id,0)               = NVL(p_location_id,NVL(PAA.location_id,0))
  AND   PAA.primary_flag                     = 'Y'
   AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAP.effective_start_date
                                                                       AND PAP.effective_end_date
  AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date)  BETWEEN PAA.effective_start_date
                                                                       AND PAA.effective_end_date
  AND   ((   NVL(p_include_term_flag,'N')        = 'Y'
         AND(  (PJEDV.terminate_flag       = 'C'
            AND((PPOF.actual_termination_date IS NULL AND p_effective_date > = PPOF.DATE_START)
                        OR (PPOF.actual_termination_date > = p_effective_date   AND p_effective_date > = PPOF.DATE_START )))
            OR ( PJEDV.terminate_flag        = 'T'
            AND TRUNC(PPOF.actual_termination_date) BETWEEN p_term_eff_date_from
                                                        AND p_term_eff_date_to)
             )
         )
        OR
         (  NVL(p_include_term_flag,'N')                     = 'N'
             AND PJEDV.terminate_flag       = 'C'
            AND ((PPOF.actual_termination_date IS NULL AND p_effective_date > = PPOF.DATE_START)
                          OR (PPOF.actual_termination_date > = p_effective_date AND p_effective_date > = PPOF.DATE_START ))
         )
        );
--
  CURSOR lcu_assact( p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE
                   , p_business_group_id  per_assignments_f.business_group_id%TYPE
                   , p_organization_id    per_assignments_f.organization_id%TYPE
                   , p_location_id        per_assignments_f.location_id%TYPE
                   , p_include_term_flag  VARCHAR2
                   , p_term_eff_date_from DATE
                   , p_term_eff_date_to   DATE
                   , p_effective_date     DATE
                  )
  IS
  SELECT PJEDV.assignment_id
        ,PJEDV.effective_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,per_periods_of_service   PPS
        ,per_jp_empdet_emp_v      PJEDV
  WHERE PAA.person_id                        = PAP.person_id
  AND   PAA.person_id                  BETWEEN p_start_person_id
                                           AND p_end_person_id
  AND   PAP.person_id                        = PPS.person_id
  AND   PPS.period_of_service_id             = PAA.period_of_service_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   PAS.payroll_action_id                = p_payroll_action_id
  AND   PJEDV.assignment_action_id           = PAS.assignment_action_id
  AND   PJEDV.assignment_id                  = PAS.assignment_id
  AND   PAA.business_group_id                = p_business_group_id
  AND   PAA.organization_id                  = NVL(p_organization_id,PAA.organization_id)
  AND   NVL(PAA.location_id,0)               = NVL(p_location_id,NVL(PAA.location_id,0))
  AND   PAA.primary_flag                     = 'Y'
  AND   NVL(TRUNC(PPS.actual_termination_date),p_effective_date) BETWEEN PAP.effective_start_date
                                                                     AND PAP.effective_end_date
  AND   NVL(TRUNC(PPS.actual_termination_date),p_effective_date) BETWEEN PAA.effective_start_date
                                                                     AND PAA.effective_end_date
  AND   ((   NVL(p_include_term_flag,'N')              = 'Y'
         AND((  ( (PPS.actual_termination_date IS NULL AND p_effective_date >  = PPS.DATE_START)
                      OR (PPS.actual_termination_date > = p_effective_date      AND p_effective_date > = PPS.DATE_START ))
             AND PJEDV.terminate_flag         = 'C'
             )
            OR
             (TRUNC(PPS.actual_termination_date)  BETWEEN p_term_eff_date_from
                                                      AND p_term_eff_date_to
              AND PJEDV.terminate_flag           = 'T'
             )
            )
         )
        OR
         (   NVL(p_include_term_flag,'N')          = 'N'
         AND ((PPS.actual_termination_date IS NULL AND p_effective_date > = PPS.DATE_START)
                OR (PPS.actual_termination_date > = p_effective_date    AND p_effective_date > = PPS.DATE_START ))
         AND PJEDV.terminate_flag         = 'C'
         )
        );
--
  ln_assact                 pay_assignment_actions.assignment_action_id%TYPE ;
  lt_org_id                 per_jp_report_common_pkg.gt_org_tbl;
  lc_proc_name              VARCHAR2(60);
  lc_legislative_parameters VARCHAR2(2000);
  lc_result1                VARCHAR2(30);
  lc_include_flag           VARCHAR2(1);
  ln_old_pact_id            NUMBER;
  ln_cur_pact               NUMBER;
  ln_ass_set_id             NUMBER;
  lb_result2                BOOLEAN;
--
  BEGIN
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      lc_proc_name := gc_pkg_name ||'action_creation';
      hr_utility.set_location ('Entering '||lc_proc_name,50);
    END IF;
--
    SELECT legislative_parameters
    INTO   lc_legislative_parameters
    FROM   pay_payroll_actions
    WHERE  payroll_action_id = p_payroll_action_id;
--
    ln_old_pact_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('PACTID',lc_legislative_parameters));
    ln_ass_set_id  := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASETID',lc_legislative_parameters));
--
    g_mag_payroll_action_id := p_payroll_action_id;
--
    IF gb_debug  THEN
      hr_utility.set_location ('Parameters ....',20);
      hr_utility.set_location ('P_PAYROLL_ACTION_ID     = '|| p_payroll_action_id,20);
      hr_utility.set_location ('P_START_PERSON_ID       = '|| p_start_person_id,20);
      hr_utility.set_location ('P_END_PERSON_ID         = '|| p_end_person_id,20);
      hr_utility.set_location ('P_CHUNK                 = '|| p_chunk,20);
      hr_utility.set_location ('P_OLD_PAYROLL_ACTION-ID = '|| ln_old_pact_id,20);
      hr_utility.set_location ('P_ASS_SET_ID            = '|| ln_ass_set_id,20);
    END IF;
--
     initialize(g_mag_payroll_action_id);
--
    IF gn_bg_id IS NULL THEN
      SELECT PPA.business_group_id
      INTO   gn_bg_id
      FROM   pay_payroll_actions PPA
      WHERE  PPA.payroll_action_id = p_payroll_action_id ;
    END IF ;
--
    IF gr_parameters.organization_id IS NOT NULL THEN
      -- Getting Organization ID's as per hierarchy
      lt_org_id := per_jp_report_common_pkg.get_org_hirerachy(p_business_group_id     => gr_parameters.business_group_id
                                                             ,p_organization_id       => gr_parameters.organization_id
                                                             ,p_include_org_hierarchy => gr_parameters.include_org_hierarchy
                                                             );
--
      FOR i in 1..lt_org_id.COUNT
        LOOP
--
          IF gb_debug  THEN
          hr_utility.set_location ('In org hierarchy loop',20);
          END IF;
--
          IF range_person_on THEN
--
            IF gb_debug THEN
            hr_utility.set_location('Inside Range person if condition, with org id',20);
            END IF;
--
            FOR lr_assact IN lcu_assact_r(ln_old_pact_id
                                          ,gr_parameters.business_group_id
                                          ,lt_org_id(i)
                                          ,gr_parameters.location_id
                                          ,gr_parameters.incl_term_emp
                                          ,gr_parameters.term_date_from
                                          ,gr_parameters.term_date_to
                                          ,gr_parameters.effective_date
                                          )
               LOOP
--
                 IF gb_debug  THEN
                   hr_utility.set_location ('In org - assact loop',20);
                 END IF;
--
            -- Added NVL to overcome NULL issue.
                 IF (NVL(ln_ass_set_id,0) = 0) THEN
              -- NO assignment set passed as parameter
                   SELECT pay_assignment_actions_s.nextval
                   INTO ln_assact
                   FROM dual;
                   hr_nonrun_asact.insact(ln_assact
                                         ,lr_assact.assignment_id
                                         ,p_payroll_action_id
                                         ,p_chunk
                                         ,NULL
                                         );
                 ELSE
              -- assignment set is passed as paramete r
                   lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => ln_ass_set_id
                                                                                   ,p_assignment_id     => lr_assact.assignment_id
                                                                                   ,p_effective_date    => gr_parameters.effective_date
                                                                                   );
                   IF lc_include_flag = 'Y' THEN
                    SELECT pay_assignment_actions_s.nextval
                    INTO ln_assact
                    FROM dual;
                    hr_nonrun_asact.insact(ln_assact
                                          ,lr_assact.assignment_id
                                          ,p_payroll_action_id
                                          ,p_chunk
                                          ,NULL
                                           );
                   END IF;
                 END IF;
              END LOOP; -- End loop for lcu_assact_r
          ELSE
            FOR lr_assact IN lcu_assact(ln_old_pact_id
                                       ,gr_parameters.business_group_id
                                       ,lt_org_id(i)
                                       ,gr_parameters.location_id
                                       ,gr_parameters.incl_term_emp
                                       ,gr_parameters.term_date_from
                                       ,gr_parameters.term_date_to
                                       ,gr_parameters.effective_date
                                       )
                LOOP
--
                  IF gb_debug  THEN
                    hr_utility.set_location ('In org - assact loop',20);
                  END IF;
--
            -- Added NVL to overcome NULL issue.
                  IF (NVL(ln_ass_set_id,0) = 0) THEN
              -- NO assignment set passed as parameter
                    SELECT pay_assignment_actions_s.nextval
                    INTO ln_assact
                    FROM dual;
                    hr_nonrun_asact.insact(ln_assact
                                           ,lr_assact.assignment_id
                                           ,p_payroll_action_id
                                           ,p_chunk
                                           ,NULL
                                           );
                  ELSE
              -- assignment set is passed as parameter
                     lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => ln_ass_set_id
                                                                                      ,p_assignment_id     => lr_assact.assignment_id
                                                                                      ,p_effective_date    => gr_parameters.effective_date
                                                                                      );
                    IF lc_include_flag = 'Y' THEN
                      SELECT pay_assignment_actions_s.nextval
                      INTO ln_assact
                      FROM dual;
                      hr_nonrun_asact.insact(ln_assact
                                             ,lr_assact.assignment_id
                                             ,p_payroll_action_id
                                             ,p_chunk
                                             ,NULL
                                             );
                    END IF;
                  END IF;
                END LOOP; -- End loop for lcu_assact
             END IF; -- End if for range person on
           END LOOP; -- End loop for Org hierarchy
--
    ELSE -- If org id is null
      IF range_person_on THEN
        IF gb_debug THEN
          hr_utility.set_location('Inside Range person if condition, with org id as null',20);
        END IF;
        FOR lr_assact IN lcu_assact_r(ln_old_pact_id
                                     ,gr_parameters.business_group_id
                                     ,NULL
                                     ,gr_parameters.location_id
                                     ,gr_parameters.incl_term_emp
                                     ,gr_parameters.term_date_from
                                     ,gr_parameters.term_date_to
                                     ,gr_parameters.effective_date
                                     )
          LOOP
            IF gb_debug  THEN
            hr_utility.set_location ('In org assact loop',20);
            END IF;
--
          -- Added NVL to overcome NULL issue.
           IF (NVL(ln_ass_set_id,0) = 0) THEN
--
            -- NO assignment set passed as parameter
             SELECT pay_assignment_actions_s.nextval
             INTO ln_assact
             FROM dual;
             hr_nonrun_asact.insact(ln_assact
                                  ,lr_assact.assignment_id
                                  ,p_payroll_action_id
                                  ,p_chunk
                                  ,NULL
                                  );
            ELSE
            -- assignment set is passed as parameter
            lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => ln_ass_set_id
                                                                            ,p_assignment_id     => lr_assact.assignment_id
                                                                            ,p_effective_date    => gr_parameters.effective_date
                                                                            );
            IF lc_include_flag = 'Y' THEN
              SELECT pay_assignment_actions_s.nextval
              INTO ln_assact
              FROM dual;
              hr_nonrun_asact.insact(ln_assact
                                    ,lr_assact.assignment_id
                                    ,p_payroll_action_id
                                    ,p_chunk
                                    ,NULL
                                    );
            END IF;
          END IF;
        END LOOP; -- for lcu_assact_r
      ELSE
            IF gb_debug THEN
             hr_utility.set_location('Range person returns false',20);
           END IF;
           --        Assignment Action for Current and Terminated Employe
            FOR lr_assact IN lcu_assact(ln_old_pact_id
                                   ,gr_parameters.business_group_id
                                   ,NULL
                                   ,gr_parameters.location_id
                                   ,gr_parameters.incl_term_emp
                                   ,gr_parameters.term_date_from
                                   ,gr_parameters.term_date_to
                                   ,gr_parameters.effective_date
                                   )
        LOOP
          IF gb_debug  THEN
            hr_utility.set_location ('In org assact loop',20);
          END IF;
--
          -- Added NVL to overcome NULL issue.
          IF (NVL(ln_ass_set_id,0) = 0) THEN
--
            -- NO assignment set passed as parameter
            SELECT pay_assignment_actions_s.nextval
            INTO ln_assact
            FROM dual;
            hr_nonrun_asact.insact(ln_assact
                                  ,lr_assact.assignment_id
                                  ,p_payroll_action_id
                                  ,p_chunk
                                  ,NULL
                                  );
          ELSE
            -- assignment set is passed as parameter
            lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => ln_ass_set_id
                                                                            ,p_assignment_id     => lr_assact.assignment_id
                                                                            ,p_effective_date    => gr_parameters.effective_date
                                                                            );
            IF lc_include_flag = 'Y' THEN
              SELECT pay_assignment_actions_s.nextval
              INTO ln_assact
              FROM dual;
              hr_nonrun_asact.insact(ln_assact
                                    ,lr_assact.assignment_id
                                    ,p_payroll_action_id
                                    ,p_chunk
                                    ,NULL
                                    );
            END IF;
          END IF;
        END LOOP; -- for lcu_assact
      END IF; -- for range person
    END IF; -- for org id is null
--
    IF gb_debug THEN
      hr_utility.set_location ('Leaving '||lc_proc_name,50);
    END IF;
--
  END action_creation;
--
  PROCEDURE init_code ( p_payroll_action_id  IN NUMBER)
  --************************************************************************
  -- PROCEDURE
  --  init_code
  --
  -- DESCRIPTION
  --  None
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action ID
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
  BEGIN
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location ('inside init_code ',20);
    END IF;
    g_mag_payroll_action_id := p_payroll_action_id;
    NULL;
  END init_code;
--
  PROCEDURE archive_code ( p_assignment_action_id IN NUMBER
                         , p_effective_date       IN DATE
                         )
  --************************************************************************
  -- PROCEDURE
  --  archive_code
  --
  -- DESCRIPTION
  --  None
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         --------  -----------------------------------
  -- p_assignment_action_id     IN       This parameter passes Payroll Action ID
  -- p_effective_date           IN       This parameter passes Effective Date
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
  BEGIN
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location ('inside archive_code ',20);
    END IF;
  END archive_code;
--

  PROCEDURE assact_xml(p_assignment_action_id  IN NUMBER)
  --************************************************************************
  -- PROCEDURE
  --  assact_xml
  --
  -- DESCRIPTION
  --  This procedure creates xml for the assignment_action_id passed
  --  as parameter. It then writes the xml into vXMLTable.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         --------  -----------------------------------
  -- p_assignment_action_id     IN       This parameter passes Payroll Action ID
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
  CURSOR lcu_emp_det(p_mag_asg_action_id NUMBER)
  IS
  SELECT  PJEDV.full_name_kana
         ,PJEDV.full_name_kanji
         ,PJEDV.date_of_birth
         ,DECODE(PJEDV.gender,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'SEX' AND lookup_code=PJEDV.gender)) gender
         ,SUBSTR(PJEDV.postal_code,1,3)||NVL2(PJEDV.postal_code,'-',' ')|| SUBSTR(PJEDV.postal_code,4)    postal_code  -- Changed by rdarasi for Bug# 8814075
         ,PJEDV.address_line1||' '||PJEDV.address_line2||' '||PJEDV.address_line3 address
         ,PJEDV.region1||' '||PJEDV.region2||' '||PJEDV.region3 address_kana
         ,PJEDV.address_line1
         ,PJEDV.address_line2
         ,PJEDV.address_line3
         ,PJEDV.country
         ,PJEDV.hire_date
         ,PJEDV.kind_of_business
         ,PJEDV.termination_date
         ,DECODE(PJEDV.termination_reason,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'LEAV_REAS' AND lookup_code= PJEDV.termination_reason)) termination_reason --   8740607
         ,PJEDV.hi_num
         ,SUBSTR(PJEDV.wp_num,1,4)||NVL2(PJEDV.wp_num,'-',' ')|| SUBSTR(PJEDV.wp_num,5)      wp_num       -- changed by rdarasi for Bug# 8765317
         ,PJEDV.wpf_num
         ,SUBSTR(PJEDV.ui_num,1,4)||NVL2(PJEDV.ui_num,'-',' ')|| SUBSTR(PJEDV.ui_num,5,6)||NVL2(PJEDV.ui_num,'-',' ')|| SUBSTR(PJEDV.ui_num,11)    ui_num       -- changed by rdarasi for bug# 8765317
         ,TO_CHAR(PJEDV.term_allowance_amt,'99G999G999') term_allowance_amt
         ,PJEDV.payment_date_term
         ,PJEDV.hi_qualified_date
         ,PJEDV.wp_qualified_date
         ,PJEDV.wpf_qualified_date
         ,PJEDV.ui_qualified_date
         ,PJEDV.terminate_flag
         ,PJEDV.employee_number
         ,PJEDV.effective_date
  FROM   per_jp_empdet_emp_v PJEDV
  WHERE  PJEDV.assignment_action_id = p_mag_asg_action_id;
--
  CURSOR lcu_prev_job_hist(p_mag_asg_action_id NUMBER)
  IS
  SELECT  PJEDPJV.company_name
         ,DECODE(PJEDPJV.employee_category,'REHIRE','*','')
         ||TO_CHAR(PJEDPJV.start_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''') start_date  -- Changed By RDARASI as per the Bug 8740649
         ,DECODE(TO_CHAR(PJEDPJV.end_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial'''),'H24.12.31',NULL
                ,TO_CHAR(PJEDPJV.end_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')) end_date
  FROM   per_jp_empdet_prev_job_v PJEDPJV
  WHERE  PJEDPJV.assignment_action_id = p_mag_asg_action_id
  ORDER BY PJEDPJV.start_date;
--
  CURSOR lcu_phone_det(p_mag_asg_action_id NUMBER)
  IS
  SELECT  PJEDPV.phone_home
         ,PJEDPV.phone_mobile
         ,PJEDPV.phone_work
  FROM   per_jp_empdet_phone_v  PJEDPV
  WHERE  PJEDPV.assignment_action_id = p_mag_asg_action_id;
--
  CURSOR lcu_education_det(p_mag_asg_action_id NUMBER)
  IS
  SELECT PJEEV.school_name
        ,PJEEV.school_name_kana
        ,PJEEV.faculty_name
        ,PJEEV.faculty_name_kana
        ,PJEEV.department_name
        ,PJEEV.graduation_date graduation_date
  FROM   per_jp_empdet_education_det_v  PJEEV
  WHERE  PJEEV.assignment_action_id = p_mag_asg_action_id
  ORDER BY PJEEV.graduation_date;
--
 CURSOR lcu_qualification_det(p_mag_asg_action_id NUMBER)
  IS
  SELECT PJEQV.type
        ,PJEQV.title
        ,PJEQV.status
        ,PJEQV.grade
        ,PJEQV.establishment
        ,PJEQV.license_number
        ,TO_CHAR(PJEQV.start_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''') start_date
        ,DECODE(TO_CHAR(PJEQV.end_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial'''),'H24.12.31',NULL
        ,TO_CHAR(PJEQV.end_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')) end_date
  FROM   per_jp_empdet_qualifications_v PJEQV
  WHERE  PJEQV.assignment_action_id = p_mag_asg_action_id
  ORDER BY PJEQV.start_date;
--
  CURSOR lcu_assignment_det(p_mag_asg_action_id NUMBER
                           )
  IS
  SELECT PJEAV.organization_name
        ,PJEAV.job
        ,PJEAV.position
        ,PJEAV.grade
        ,PJEAV.start_date
        ,DECODE(PJEAV.end_date,TO_DATE('12/31/4712','mm/dd/yyyy'),null,PJEAV.end_date) end_date
        ,PJEAV.assignment_number
  FROM   per_jp_empdet_assignments_v  PJEAV
  WHERE  PJEAV.assignment_action_id = p_mag_asg_action_id
  ORDER BY PJEAV.start_date;
--
  CURSOR lcu_contact_info(p_mag_asg_action_id NUMBER)
  IS
  SELECT PJECIV.full_name_kana
        ,PJECIV.full_name_kanji
        ,DECODE(PJECIV.relationship,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'CONTACT' AND lookup_code=PJECIV.relationship)) relationship
        ,DECODE(PJECIV.gender,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'SEX' AND lookup_code=PJECIV.gender)) gender
        ,TO_CHAR(PJECIV.birth_date, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''') birth_date
        ,PJECIV.age
        ,DECODE(PJECIV.primary_contact,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'YES_NO' AND lookup_code=PJECIV.primary_contact)) primary_contact
        ,DECODE(PJECIV.dependent,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'YES_NO' AND lookup_code=PJECIV.dependent)) dependent
        ,DECODE(PJECIV.shared_residence,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'YES_NO' AND lookup_code=PJECIV.shared_residence)) shared_residence
        ,PJECIV.sequence
        ,DECODE(PJECIV.household_head,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'YES_NO' AND lookup_code=PJECIV.household_head)) household_head
        ,DECODE(PJECIV.si_itax,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'YES_NO' AND lookup_code=PJECIV.si_itax)) si_itax
  FROM   per_jp_empdet_contact_info_v  PJECIV
  WHERE  PJECIV.assignment_action_id = p_mag_asg_action_id
  ORDER BY PJECIV.full_name_kana
          ,PJECIV.full_name_kanji;
--
  CURSOR lcu_proc_info(p_info_type         VARCHAR2
                      ,p_business_group_id NUMBER
                      ,p_effective_date    DATE
                      )
  IS
  SELECT HOI.org_information3
        ,HOI.org_information4
        ,HOI.org_information7
  FROM   hr_organization_information HOI
  WHERE  HOI.org_information_context = 'JP_REPORTS_ADDITIONAL_INFO'
  AND    HOI.org_information1        = 'JPEMPLDETAILSREPORT'
  AND    HOI.organization_id         =  p_business_group_id
  AND    HOI.org_information3        =  p_info_type
  AND    p_effective_date      BETWEEN  FND_DATE.canonical_to_date(HOI.org_information5)
                                   AND  FND_DATE.canonical_to_date(HOI.org_information6);
--
  CURSOR lcu_emp_add_info(p_mag_asg_action_id NUMBER)
  IS
  SELECT PJEDAI.additional_information1
        ,PJEDAI.additional_information2
        ,PJEDAI.additional_information3
        ,PJEDAI.additional_information4
        ,PJEDAI.additional_information5
        ,PJEDAI.additional_information6
        ,PJEDAI.additional_information7
        ,PJEDAI.additional_information8
        ,PJEDAI.additional_information9
        ,PJEDAI.additional_information10
        ,PJEDAI.additional_information11
        ,PJEDAI.additional_information12
        ,PJEDAI.additional_information13
        ,PJEDAI.additional_information14
        ,PJEDAI.additional_information15
        ,PJEDAI.additional_information16
        ,PJEDAI.additional_information17
        ,PJEDAI.additional_information18
        ,PJEDAI.additional_information19
        ,PJEDAI.additional_information20
        ,PJEDAI.additional_information21
        ,PJEDAI.additional_information22
        ,PJEDAI.additional_information23
        ,PJEDAI.additional_information24
        ,PJEDAI.additional_information25
        ,PJEDAI.additional_information26
        ,PJEDAI.additional_information27
        ,PJEDAI.additional_information28
        ,PJEDAI.additional_information29
        ,PJEDAI.additional_information30
  FROM  per_jp_wrkreg_extra_info_v  PJEDAI
  WHERE PJEDAI.assignment_action_id = p_mag_asg_action_id;
--
  lr_emp_det                   lcu_emp_det%ROWTYPE;
  lr_proc_info                 lcu_proc_info%ROWTYPE;
  lr_emp_add_info              lcu_emp_add_info%ROWTYPE;
   --Local Variables
  ln_mag_asg_action_id         pay_assignment_actions.assignment_action_id%TYPE;
  lblob_image                  per_images.image%TYPE;
  lc_xml                       CLOB;
  lc_xml2                      CLOB;
  lc_common_xml                CLOB;
  lc_xml_begin                 VARCHAR2(200);
  lc_emp_no                    VARCHAR2(80);
  lc_job_hist_xml              CLOB;
  lc_profile_value             VARCHAR2(100);
  lc_additional_info_xml       CLOB;
  lc_add_msg_xml               CLOB;
  lc_phone_det_xml             CLOB;
  lc_edu_det_xml               CLOB;
  lc_qua_det_xml               CLOB;
  lc_ass_det_xml               CLOB;
  lc_contact_xml               CLOB;
  ln_cnt                       NUMBER(2);
  l_index                      NUMBER:=0;-- Bug 8740684
  l_asmnt_count                NUMBER;
  i                            NUMBER;
  j                            NUMBER:=0;-- Bug 8843783
  --
  TYPE asmt_hist_type IS RECORD(  assignment_number per_assignments_f.assignment_number%TYPE
                                 ,organization_name   hr_organization_units.name%TYPE
                                 ,job            per_jobs_tl.name %TYPE
                                 ,position       per_positions.name%TYPE
                                 ,grade          per_grades_tl.name%TYPE
                                 ,start_date     per_assignments_f.effective_start_date%TYPE
                                 ,end_date       per_assignments_f.effective_end_date%TYPE
                                );--8740684
  TYPE gt_asmnt_tbl IS TABLE OF asmt_hist_type INDEX BY binary_integer;       --  8740684
  lt_asmnt_tbl  gt_asmnt_tbl;--8740684
  lt_res_tb                     per_jp_empdet_report_pkg.gt_job_tbl;         --  Bug No 8843783
  lt_dis_res_tb                 per_jp_empdet_report_pkg.gt_job_tbl;         --  Bug No 8843783
--
  BEGIN
--
    vXMLTable.DELETE;
    gn_vctr         := 0;
    lc_job_hist_xml := null;
--
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location ('Entering assact_xml',20);
      hr_utility.set_location('empdet_xml',20);
    END IF;
--
    ln_mag_asg_action_id := p_assignment_action_id;
--
    initialize(g_mag_payroll_action_id);
--
    OPEN  lcu_emp_det(ln_mag_asg_action_id);
    FETCH lcu_emp_det INTO lr_emp_det;
--
    IF lcu_emp_det%FOUND THEN
      lc_xml_begin                 := '<EMPDET>'||gc_eol;
      vXMLTable(gn_vctr).xmlstring :=  lc_xml_begin;
      gn_vctr                      := gn_vctr + 1;
      lc_common_xml := '<c1>'  ||htmlspchar(cnv_str(lr_emp_det.full_name_kana))    ||'</c1>' ||gc_eol
                     ||'<c2>'  ||htmlspchar(cnv_str(lr_emp_det.full_name_kanji))   ||'</c2>' ||gc_eol
                     ||'<c3_m>'  ||TO_CHAR(lr_emp_det.date_of_birth,'yyyy-mm-dd')  ||TO_CHAR(lr_emp_det.date_of_birth,'hh:mm:ss-HH:MM')   ||'</c3_m>' ||gc_eol
                     ||'<c3_d>'  ||TO_CHAR(lr_emp_det.date_of_birth,'yyyy-mm-dd') ||TO_CHAR(lr_emp_det.date_of_birth,'hh:mm:ss-HH:MM')    ||'</c3_d>' ||gc_eol
                     ||'<c3_era>'||TO_CHAR(lr_emp_det.date_of_birth, 'EEYY','NLS_CALENDAR=''Japanese Imperial''') ||'</c3_era>' ||gc_eol
                     ||'<c4>'  ||htmlspchar(cnv_str(lr_emp_det.gender))            ||'</c4>' ||gc_eol
                     ||'<c5>'  ||htmlspchar(cnv_str(lr_emp_det.postal_code))       ||'</c5>' ||gc_eol
                     ||'<c6>'  ||htmlspchar(cnv_str(lr_emp_det.address))           ||'</c6>' ||gc_eol
                     ||'<c7>'  ||htmlspchar(cnv_str(lr_emp_det.address_kana))      ||'</c7>' ||gc_eol
                     ||'<c8_m>'  ||TO_CHAR(lr_emp_det.hire_date,'yyyy-mm-dd')  ||TO_CHAR(lr_emp_det.hire_date,'hh:mm:ss-HH:MM')       ||'</c8_m>' ||gc_eol
                     ||'<c8_d>'  ||TO_CHAR(lr_emp_det.hire_date,'yyyy-mm-dd')   ||TO_CHAR(lr_emp_det.hire_date,'hh:mm:ss-HH:MM')       ||'</c8_d>' ||gc_eol
                     ||'<c8_era>'||TO_CHAR(lr_emp_det.hire_date, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''')    ||'</c8_era>' ||gc_eol
                     ||'<c9>'  ||htmlspchar(cnv_str(lr_emp_det.kind_of_business))  ||'</c9>' ||gc_eol
                     ||'<c10>' ||htmlspchar(cnv_str(lr_emp_det.hi_num))            ||'</c10>'||gc_eol
                     ||'<c11_m>'  ||TO_CHAR(lr_emp_det.hi_qualified_date,'yyyy-mm-dd')||TO_CHAR(lr_emp_det.hi_qualified_date,'hh:mm:ss-HH:MM')||'</c11_m>' ||gc_eol
                     ||'<c11_d>'  ||TO_CHAR(lr_emp_det.hi_qualified_date,'yyyy-mm-dd')||TO_CHAR(lr_emp_det.hi_qualified_date,'hh:mm:ss-HH:MM')||'</c11_d>' ||gc_eol
                     ||'<c11_era>'||TO_CHAR(lr_emp_det.hi_qualified_date, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''')    ||'</c11_era>' ||gc_eol
                     ||'<c12>' ||htmlspchar(cnv_str(lr_emp_det.wp_num))||'</c12>'||gc_eol
                     ||'<c13_m>'  ||TO_CHAR(lr_emp_det.wp_qualified_date,'yyyy-mm-dd') ||TO_CHAR(lr_emp_det.wp_qualified_date,'hh:mm:ss-HH:MM')||'</c13_m>' ||gc_eol
                     ||'<c13_d>'  ||TO_CHAR(lr_emp_det.wp_qualified_date,'yyyy-mm-dd') ||TO_CHAR(lr_emp_det.wp_qualified_date,'hh:mm:ss-HH:MM')||'</c13_d>' ||gc_eol
                     ||'<c13_era>'||TO_CHAR(lr_emp_det.wp_qualified_date, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''')    ||'</c13_era>' ||gc_eol
                     ||'<c14>' ||htmlspchar(cnv_str(lr_emp_det.wpf_num))           ||'</c14>'||gc_eol
                     ||'<c15_m>'  ||TO_CHAR(lr_emp_det.wpf_qualified_date,'yyyy-mm-dd')||TO_CHAR(lr_emp_det.wpf_qualified_date,'hh:mm:ss-HH:MM')||'</c15_m>' ||gc_eol
                     ||'<c15_d>'  ||TO_CHAR(lr_emp_det.wpf_qualified_date,'yyyy-mm-dd') ||TO_CHAR(lr_emp_det.wpf_qualified_date,'hh:mm:ss-HH:MM')||'</c15_d>' ||gc_eol
                     ||'<c15_era>'||TO_CHAR(lr_emp_det.wpf_qualified_date, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''')    ||'</c15_era>' ||gc_eol
                     ||'<c16>' ||htmlspchar(cnv_str( lr_emp_det.ui_num))||'</c16>'||gc_eol
                     ||'<c17_m>'  ||TO_CHAR(lr_emp_det.ui_qualified_date,'yyyy-mm-dd')||TO_CHAR(lr_emp_det.ui_qualified_date,'hh:mm:ss-HH:MM')||'</c17_m>' ||gc_eol
                     ||'<c17_d>'  ||TO_CHAR(lr_emp_det.ui_qualified_date,'yyyy-mm-dd')||TO_CHAR(lr_emp_det.ui_qualified_date,'hh:mm:ss-HH:MM')||'</c17_d>' ||gc_eol
                     ||'<c17_era>'||TO_CHAR(lr_emp_det.ui_qualified_date, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''')    ||'</c17_era>' ||gc_eol
                     ||'<c18_m>' ||TO_CHAR(lr_emp_det.termination_date,'yyyy-mm-dd') ||TO_CHAR(lr_emp_det.termination_date,'hh:mm:ss-HH:MM') ||'</c18_m>'||gc_eol
                     ||'<c18_d>' ||TO_CHAR(lr_emp_det.termination_date,'yyyy-mm-dd') ||TO_CHAR(lr_emp_det.termination_date,'hh:mm:ss-HH:MM') ||'</c18_d>'||gc_eol
                     ||'<c18_era>'||TO_CHAR(lr_emp_det.termination_date, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''')    ||'</c18_era>' ||gc_eol
                     ||'<c19>' ||htmlspchar(cnv_str(lr_emp_det.termination_reason))||'</c19>'||gc_eol
                     ||'<c20>' ||htmlspchar(cnv_str(lr_emp_det.term_allowance_amt))||'</c20>'||gc_eol
                     ||'<c21_m>' ||TO_CHAR(lr_emp_det.payment_date_term,'yyyy-mm-dd') ||TO_CHAR(lr_emp_det.payment_date_term,'hh:mm:ss-HH:MM')||'</c21_m>'||gc_eol
                     ||'<c21_d>' ||TO_CHAR(lr_emp_det.payment_date_term,'yyyy-mm-dd')||TO_CHAR(lr_emp_det.payment_date_term,'hh:mm:ss-HH:MM') ||'</c21_d>'||gc_eol
                     ||'<c21_era>'||TO_CHAR(lr_emp_det.payment_date_term, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''')    ||'</c21_era>' ||gc_eol
                     ||'<c22>' ||htmlspchar(cnv_str(lr_emp_det.employee_number))   ||'</c22>'||gc_eol
                     ||'<c23_m>' ||TO_CHAR(lr_emp_det.effective_date,'yyyy-mm-dd') ||TO_CHAR(lr_emp_det.effective_date,'hh:mm:ss-HH:MM')  ||'</c23_m>'||gc_eol
                     ||'<c23_d>' ||TO_CHAR(lr_emp_det.effective_date,'yyyy-mm-dd')  ||TO_CHAR(lr_emp_det.effective_date,'hh:mm:ss-HH:MM')   ||'</c23_d>'||gc_eol
                     ||'<c23_era>'||TO_CHAR(lr_emp_det.effective_date, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''')    ||'</c23_era>' ||gc_eol
                     ||'<c24>' ||htmlspchar(cnv_str(lr_emp_det.address_line1))     ||'</c24>'||gc_eol
                     ||'<c25>' ||htmlspchar(cnv_str(lr_emp_det.address_line2))     ||'</c25>'||gc_eol
                     ||'<c26>' ||htmlspchar(cnv_str(lr_emp_det.address_line3))     ||'</c26>'||gc_eol
                     ||'<c27>' ||htmlspchar(cnv_str(lr_emp_det.country))           ||'</c27>'||gc_eol;
--
      FOR lr_phone_det IN lcu_phone_det(ln_mag_asg_action_id)
      LOOP
        lc_phone_det_xml := lc_phone_det_xml||
                            '<phone_home>'||htmlspchar(cnv_str(lr_phone_det.phone_home))||'</phone_home>'||gc_eol
                          ||'<phone_mobile>'||htmlspchar(cnv_str(lr_phone_det.phone_mobile))||'</phone_mobile>'||gc_eol
                          ||'<phone_work>'||htmlspchar(cnv_str(lr_phone_det.phone_work))||'</phone_work>'||gc_eol;
      END LOOP;
      lc_common_xml := lc_common_xml || lc_phone_det_xml;
--
      ln_cnt := 0;
      FOR lr_education_det IN lcu_education_det(ln_mag_asg_action_id)
      LOOP
        ln_cnt         := ln_cnt + 1;
        lc_edu_det_xml := lc_edu_det_xml
                         ||'<ced'||ln_cnt||'>'||htmlspchar(cnv_str(lr_education_det.graduation_date))||'</ced'||ln_cnt||'>'||gc_eol
                         ||'<ce'||ln_cnt||'>'||htmlspchar(cnv_str(lr_education_det.school_name))||' '||htmlspchar(cnv_str(lr_education_det.faculty_name))||' '||htmlspchar(cnv_str(lr_education_det.department_name))||'</ce'||ln_cnt||'>'||gc_eol;
      END LOOP;
      lc_common_xml := lc_common_xml || lc_edu_det_xml;
      --
      -- The below code added for bug number 8843783
      lt_res_tb :=get_previous_job_history(ln_mag_asg_action_id);
      j := lt_res_tb.count;
      ln_cnt := 0;
      IF j <=4  THEN
      i := lt_res_tb.first;
      ln_cnt := 0;
      WHILE  i IS NOT NULL LOOP
      ln_cnt         := ln_cnt + 1;
      lc_job_hist_xml:=lc_job_hist_xml
                         ||'<cpjsd'||ln_cnt||'>'||htmlspchar(cnv_str(lt_res_tb(i).start_date))||'</cpjsd'||ln_cnt||'>'||gc_eol
                         ||'<cpjed'||ln_cnt||'>'||htmlspchar(cnv_str(lt_res_tb(i).end_date))  ||'</cpjed'||ln_cnt||'>'||gc_eol
                         ||'<cpj'  ||ln_cnt||'>'||htmlspchar(cnv_str(lt_res_tb(i).company_name))||'</cpj'||ln_cnt||'>'||gc_eol;
      i:=lt_res_tb.next(i);
      END LOOP;
      lc_common_xml := lc_common_xml || lc_job_hist_xml;
      ELSIF j > 4  THEN
        i := lt_res_tb.last;
        ln_cnt := 0;
        WHILE  i <> 0
        LOOP
          ln_cnt         := ln_cnt + 1;
          lt_dis_res_tb(ln_cnt).start_date   := lt_res_tb(i).start_date;
          lt_dis_res_tb(ln_cnt).end_date     := lt_res_tb(i).end_date;
          lt_dis_res_tb(ln_cnt).company_name := lt_res_tb(i).company_name;
          EXIT WHEN ln_cnt >= 4;
          i := lt_res_tb.prior(i);
        END LOOP;
          i := lt_dis_res_tb.last;
          ln_cnt := 0;
          WHILE  i <> 0
          LOOP
            ln_cnt         := ln_cnt + 1;
            lc_job_hist_xml:=lc_job_hist_xml
                         ||'<cpjsd'||ln_cnt||'>'||htmlspchar(cnv_str(lt_dis_res_tb(i).start_date))||'</cpjsd'||ln_cnt||'>'||gc_eol
                         ||'<cpjed'||ln_cnt||'>'||htmlspchar(cnv_str(lt_dis_res_tb(i).end_date))  ||'</cpjed'||ln_cnt||'>'||gc_eol
                         ||'<cpj'  ||ln_cnt||'>'||htmlspchar(cnv_str(lt_dis_res_tb(i).company_name))||'</cpj'||ln_cnt||'>'||gc_eol;
            i := lt_dis_res_tb.prior(i);
          END LOOP;
          lc_common_xml := lc_common_xml || lc_job_hist_xml;
      END IF;
      --
      ln_cnt := 0;
      FOR lr_qualification_det  IN lcu_qualification_det(ln_mag_asg_action_id)
      LOOP
        ln_cnt         := ln_cnt + 1;
        lc_qua_det_xml := lc_qua_det_xml
                        ||'<cqt'||ln_cnt||'>'||htmlspchar(cnv_str(lr_qualification_det.type))          ||'</cqt'||ln_cnt||'>'||gc_eol
                        ||'<cqtl'||ln_cnt||'>'||htmlspchar(cnv_str(lr_qualification_det.title))         ||'</cqtl'||ln_cnt||'>'||gc_eol
                        ||'<cqs'||ln_cnt||'>'||htmlspchar(cnv_str(lr_qualification_det.status))        ||'</cqs'||ln_cnt||'>'||gc_eol
                        ||'<cqg'||ln_cnt||'>'||htmlspchar(cnv_str(lr_qualification_det.grade))         ||'</cqg'||ln_cnt||'>'||gc_eol
                        ||'<cqd'||ln_cnt||'>'||htmlspchar(cnv_str(lr_qualification_det.start_date))    ||'</cqd'||ln_cnt||'>'||gc_eol;
      END LOOP;
      lc_common_xml := lc_common_xml || lc_qua_det_xml;
--
      l_index:=0;
--      8740684
      FOR lr_assignment_det  IN lcu_assignment_det(ln_mag_asg_action_id)
         LOOP
           l_index:=l_index+1;
           lt_asmnt_tbl(l_index).assignment_number:=lr_assignment_det.assignment_number;
           lt_asmnt_tbl(l_index).organization_name:=lr_assignment_det.organization_name;
           lt_asmnt_tbl(l_index).job:=lr_assignment_det.job;
           lt_asmnt_tbl(l_index).position:=lr_assignment_det.position;
           lt_asmnt_tbl(l_index).grade:=lr_assignment_det.grade;
           lt_asmnt_tbl(l_index).start_date:=lr_assignment_det.start_date;
           lt_asmnt_tbl(l_index).end_date:=lr_assignment_det.end_date;
      END LOOP;
--      8740684
      ln_cnt := 0;
      IF l_index < 15 THEN
        FOR i IN  1..l_index
        LOOP
          ln_cnt         := ln_cnt + 1;
          lc_ass_det_xml := lc_ass_det_xml
                        ||'<canum'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).assignment_number))||'</canum'||ln_cnt||'>'||gc_eol
                        ||'<caorg'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).organization_name))||'</caorg'||ln_cnt||'>'||gc_eol
                        ||'<caj'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).job))                ||'</caj'||ln_cnt||'>'||gc_eol
                        ||'<cap'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).position))           ||'</cap'||ln_cnt||'>'||gc_eol
                        ||'<cag'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).grade))              ||'</cag'||ln_cnt||'>'||gc_eol
                        ||'<casd'||ln_cnt||'>'||htmlspchar(cnv_str(TO_CHAR(lt_asmnt_tbl(i).start_date,'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')))        ||'</casd'||ln_cnt||'>'||gc_eol
                        ||'<caed'||ln_cnt||'>'||htmlspchar(cnv_str(TO_CHAR(lt_asmnt_tbl(i).end_date,'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')))          ||'</caed'||ln_cnt||'>'||gc_eol;
         END LOOP;
      ELSE
        l_asmnt_count:=  l_index-15;
        FOR i in (l_asmnt_count+1)..l_index
          LOOP
            ln_cnt         := ln_cnt + 1;
            lc_ass_det_xml := lc_ass_det_xml
                                    ||'<canum'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).assignment_number))||'</canum'||ln_cnt||'>'||gc_eol
                                    ||'<caorg'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).organization_name))||'</caorg'||ln_cnt||'>'||gc_eol
                                    ||'<caj'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).job))                ||'</caj'||ln_cnt||'>'||gc_eol
                                    ||'<cap'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).position))           ||'</cap'||ln_cnt||'>'||gc_eol
                                    ||'<cag'||ln_cnt||'>'||htmlspchar(cnv_str(lt_asmnt_tbl(i).grade))              ||'</cag'||ln_cnt||'>'||gc_eol
                                    ||'<casd'||ln_cnt||'>'||htmlspchar(cnv_str(TO_CHAR(lt_asmnt_tbl(i).start_date,'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')))  ||'</casd'||ln_cnt||'>'||gc_eol
                                    ||'<caed'||ln_cnt||'>'||htmlspchar(cnv_str(TO_CHAR(lt_asmnt_tbl(i).end_date,'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')))    ||'</caed'||ln_cnt||'>'||gc_eol;
         END LOOP;
--
      END IF;--8740684
--
        lc_common_xml := lc_common_xml || lc_ass_det_xml;
--
      ln_cnt := 0;
      FOR lr_contact_info IN lcu_contact_info(ln_mag_asg_action_id)
      LOOP
        ln_cnt         := ln_cnt + 1;
        lc_contact_xml := lc_contact_xml
                        ||'<cckana'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.full_name_kana))      ||'</cckana'||ln_cnt||'>'||gc_eol
                        ||'<cckanji'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.full_name_kanji))    ||'</cckanji'||ln_cnt||'>'||gc_eol
                        ||'<ccrel'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.relationship))    ||'</ccrel'||ln_cnt||'>'||gc_eol
                        ||'<ccgen'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.gender))          ||'</ccgen'||ln_cnt||'>'||gc_eol
                        ||'<ccbd'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.birth_date))       ||'</ccbd'||ln_cnt||'>'||gc_eol
                        ||'<ccage'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.age))             ||'</ccage'||ln_cnt||'>'||gc_eol
                        ||'<ccpc'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.primary_contact))  ||'</ccpc'||ln_cnt||'>'||gc_eol
                        ||'<ccdep'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.dependent))       ||'</ccdep'||ln_cnt||'>'||gc_eol
                        ||'<ccshr'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.shared_residence))||'</ccshr'||ln_cnt||'>'||gc_eol
                        ||'<ccseq'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.sequence))        ||'</ccseq'||ln_cnt||'>'||gc_eol
                        ||'<cchhd'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.household_head))  ||'</cchhd'||ln_cnt||'>'||gc_eol
                        ||'<ccsitax'||ln_cnt||'>'||htmlspchar(cnv_str(lr_contact_info.si_itax))       ||'</ccsitax'||ln_cnt||'>'||gc_eol;
      END LOOP;
      lc_common_xml := lc_common_xml || lc_contact_xml;
--
      lc_xml := gc_eol || lc_common_xml || gc_eol;
--
      OPEN lcu_proc_info('MESG'
                        , gr_parameters.business_group_id
                        , gr_parameters.effective_date
                        );
      FETCH  lcu_proc_info INTO lr_proc_info;
      CLOSE  lcu_proc_info;
--
      IF lr_proc_info.org_information7 IS NOT NULL THEN
        lc_add_msg_xml := '<MESG>'||htmlspchar(cnv_str(lr_proc_info.org_information7))||'</MESG>'||gc_eol;
        lc_xml := lc_xml || lc_add_msg_xml || gc_eol;
      END IF;

      OPEN lcu_proc_info('ADDINFO'
                        , gr_parameters.business_group_id
                        , gr_parameters.effective_date
                        );
      FETCH  lcu_proc_info INTO lr_proc_info;
      CLOSE  lcu_proc_info;
--
      IF  lr_proc_info.org_information4 IS NOT NULL THEN
--
        OPEN lcu_emp_add_info(ln_mag_asg_action_id);
        FETCH  lcu_emp_add_info into lr_emp_add_info;
        CLOSE  lcu_emp_add_info;
--
        lc_additional_info_xml:= '<x1>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION1))  ||'</x1>' ||gc_eol
                               ||'<x2>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION2))  ||'</x2>' ||gc_eol
                               ||'<x3>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION3))  ||'</x3>' ||gc_eol
                               ||'<x4>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION4))  ||'</x4>' ||gc_eol
                               ||'<x5>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION5))  ||'</x5>' ||gc_eol
                               ||'<x6>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION6))  ||'</x6>' ||gc_eol
                               ||'<x7>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION7))  ||'</x7>' ||gc_eol
                               ||'<x8>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION8))  ||'</x8>' ||gc_eol
                               ||'<x9>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION9))  ||'</x9>' ||gc_eol
                               ||'<x10>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION10))||'</x10>'||gc_eol
                               ||'<x11>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION11))||'</x11>'||gc_eol
                               ||'<x12>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION12))||'</x12>'||gc_eol
                               ||'<x13>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION13))||'</x13>'||gc_eol
                               ||'<x14>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION14))||'</x14>'||gc_eol
                               ||'<x15>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION15))||'</x15>'||gc_eol
                               ||'<x16>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION16))||'</x16>'||gc_eol
                               ||'<x17>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION17))||'</x17>'||gc_eol
                               ||'<x18>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION18))||'</x18>'||gc_eol
                               ||'<x19>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION19))||'</x19>'||gc_eol
                               ||'<x20>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION20))||'</x20>'||gc_eol
                               ||'<x21>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION21))||'</x21>'||gc_eol
                               ||'<x22>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION22))||'</x22>'||gc_eol
                               ||'<x23>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION23))||'</x23>'||gc_eol
                               ||'<x24>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION24))||'</x24>'||gc_eol
                               ||'<x25>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION25))||'</x25>'||gc_eol
                               ||'<x26>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION26))||'</x26>'||gc_eol
                               ||'<x27>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION27))||'</x27>'||gc_eol
                               ||'<x28>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION28))||'</x28>'||gc_eol
                               ||'<x29>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION29))||'</x29>'||gc_eol
                               ||'<x30>'||htmlspchar(cnv_str(lr_emp_add_info.ADDITIONAL_INFORMATION30))||'</x30>'||gc_eol;
--
        lc_xml := lc_xml || lc_additional_info_xml;
      END IF;
      -- writing first part of xml to vXMLtable
      vXMLTable(gn_vctr).xmlstring := lc_xml;
      gn_vctr := gn_vctr + 1;
--
    END IF;
    CLOSE lcu_emp_det;
--
    IF gb_debug THEN
      hr_utility.set_location ('Leaving assact_xml',20);
    END IF;
--
  EXCEPTION
  WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in assact_xml ',999999);
      hr_utility.set_location('sqleerm ' || SQLERRM,20);
    END IF;
    hr_utility.raise_error;
    RAISE;
  WHEN OTHERS THEN
    RAISE gc_exception;
  END assact_xml;
--
PROCEDURE writetoclob (p_write_xml OUT NOCOPY CLOB)
  --************************************************************************
  -- PROCEDURE
  --  writetoclob
  --
  -- DESCRIPTION
  --  This procedure selects the xml from vxmltable and writes it
  --  into a clob variable. This clob variable is then returned
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE      DESCRIPTION
  -- -----------------          --------  ----------------------------------
  -- p_write_xml                OUT       This parameter returns XML String
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
    g_xfdf_string       CLOB;
    l_tempclob          CLOB;
    ln_ctr_table        NUMBER;
    lc_xml2             CLOB;
  BEGIN
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location('Entering writetoclob',20);
    END IF;
    dbms_lob.createtemporary(g_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(g_xfdf_string,dbms_lob.lob_readwrite);
--
    FOR ln_ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST
    LOOP
      dbms_lob.writeAppend(g_xfdf_string
                          ,LENGTH(vxmltable(ln_ctr_table).xmlstring)
                          ,vxmltable(ln_ctr_table).xmlstring );
    END LOOP;
--
    p_write_xml := g_xfdf_string;
    dbms_lob.close(g_xfdf_string);
    IF gb_debug THEN
      hr_utility.set_location('Out of loop ',99);
      hr_utility.set_location('Leaving writetoclob',20);
    END IF;
--
  EXCEPTION
  WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in writetoclob ',999999);
      hr_utility.set_location('sqleerm ' || SQLERRM,20);
    END IF;
    hr_utility.raise_error;
    RAISE;
  WHEN OTHERS THEN
    RAISE gc_exception;
  END writetoclob;
--
  PROCEDURE get_cp_xml(p_assignment_action_id    IN  NUMBER
                      ,p_xml                     OUT NOCOPY CLOB
                      )
  --************************************************************************
  -- PROCEDURE
  --  get_cp_xml
  --
  -- DESCRIPTION
  --  This procedure creates and returns the xml for the
  --  assignment_action_id passed as parameter
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE      DESCRIPTION
  -- -----------------          --------  ----------------------------------
  -- p_assignment_action_id     IN        This parameter passes assignment Action ID
  -- p_xml                      OUT       This parameter returns XML
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
--
  BEGIN
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      hr_utility.set_location('Entering get_cp_xml',20);
      hr_utility.set_location('Leaving get_cp_xml',20);
    END IF;
    assact_xml(p_assignment_action_id);
    writetoclob (p_xml);
  END get_cp_xml;
--
  PROCEDURE generate_xml
  --************************************************************************
  -- PROCEDURE
  --  generate_xml
  --
  -- DESCRIPTION
  --  This procedure fetches archived data, converts it to XML
  --  format and appends to pay_mag_tape.g_clob_value.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  --   None
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  AS

  CURSOR lcu_get_image(p_assignment_id NUMBER)
  IS
  SELECT PIMG.parent_id
        ,PIMG.image
  FROM   per_images   PIMG
  WHERE  PIMG.parent_id =  (SELECT DISTINCT PPF.person_id
                            FROM   per_assignments_f PPF
                            WHERE  PPF.assignment_id = p_assignment_id
                           );
--
  CURSOR lcu_emp_det_blob(p_mag_asg_action_id NUMBER)
  IS
  SELECT PJEDV.assignment_id
  FROM   per_jp_empdet_emp_v PJEDV
  WHERE  PJEDV.assignment_action_id = p_mag_asg_action_id;
--
    l_final_xml_string         CLOB;
    lblob_image                per_images.image%TYPE;
    lc_xml_string1             VARCHAR2(2000);
    lc_proc_name               VARCHAR2(60);
    lc_legislative_parameters  VARCHAR(2000);
    ln_assignment_id           NUMBER;
    ln_old_assact_id           NUMBER;
    ln_pact_id                 NUMBER;
    ln_cur_pact                NUMBER;
    ln_cur_assact              NUMBER;
    ln_offset                  NUMBER;
    ln_amount                  NUMBER;
    ln_amount_blob             BINARY_INTEGER;
    ln_offset_blob             INTEGER;
    ln_parent_id               NUMBER;
    lc_xml_raw                 RAW(45);
    lc_xml_varchar             VARCHAR2(2000);

--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug  THEN
      lc_proc_name := gc_pkg_name || 'generate_xml';
      hr_utility.set_location ('Entering '||lc_proc_name,20);
    END IF;
--
    ln_cur_assact := pay_magtape_generic.get_parameter_value  ('TRANSFER_ACT_ID' );
    ln_cur_pact   := pay_magtape_generic.get_parameter_value  ('TRANSFER_PAYROLL_ACTION_ID' );
--
    SELECT legislative_parameters
    INTO   lc_legislative_parameters
    FROM   pay_payroll_actions
    WHERE  payroll_action_id = ln_cur_pact;
--
    ln_pact_id   := fnd_number.canonical_to_number(pay_core_utils.get_parameter('PACTID',lc_legislative_parameters));
--
    SELECT PAA1.assignment_action_id
    INTO   ln_old_assact_id
    FROM   pay_assignment_actions  PAA
          ,pay_assignment_actions  PAA1
    WHERE  PAA.assignment_action_id = ln_cur_assact
    AND    PAA.assignment_id        = PAA1.assignment_id
    AND    PAA1.payroll_action_id   = ln_pact_id;
--
    get_cp_xml(ln_old_assact_id, l_final_xml_string);
--
    ln_offset := 1 ;
    ln_amount := 500;
--
    BEGIN
      LOOP
        lc_xml_string1 := NULL;
        dbms_lob.read(l_final_xml_string,ln_amount,ln_offset,lc_xml_string1);
        pay_core_files.write_to_magtape_lob(lc_xml_string1);
        ln_offset := ln_offset + ln_amount;
      END LOOP;
    EXCEPTION
    WHEN no_data_found THEN
      IF gb_debug  THEN
        hr_utility.set_location ('exiting from loop',20);
      END IF;
    END;
--
    IF gr_parameters.img_display = 'Y' THEN
--
      lc_xml_string1 :='<IMG>';
      pay_core_files.write_to_magtape_lob(lc_xml_string1);
--

      OPEN  lcu_emp_det_blob(ln_old_assact_id);
      FETCH lcu_emp_det_blob INTO ln_assignment_id;
      CLOSE lcu_emp_det_blob;

      IF ln_assignment_id IS NOT NULL THEN
        OPEN  lcu_get_image(ln_assignment_id);
        FETCH lcu_get_image INTO ln_parent_id
                                 ,lblob_image;
        CLOSE lcu_get_image;
      END IF;

      IF ln_parent_id IS NOT NULL THEN

        ln_offset_blob := 1;
        ln_amount_blob := 45;
        --
        BEGIN
          LOOP
            lc_xml_raw     := '';
            lc_xml_varchar := NULL;
            dbms_lob.read(lblob_image,ln_amount_blob,ln_offset_blob,lc_xml_raw);
            lc_xml_varchar := utl_raw.cast_to_varchar2(utl_encode.base64_encode(lc_xml_raw));
            pay_core_files.write_to_magtape_lob(lc_xml_varchar);
            ln_offset_blob := ln_offset_blob + ln_amount_blob;
          END LOOP;
        EXCEPTION
        WHEN no_data_found THEN
          IF gb_debug  THEN
            hr_utility.set_location ('exiting from loop',20);
          END IF;
        END;
      END IF;

      lc_xml_string1 := '</IMG>'||gc_eol||'</EMPDET>'||gc_eol ;
      pay_core_files.write_to_magtape_lob(lc_xml_string1);
    ELSE
      lc_xml_string1 :='</EMPDET>'||gc_eol ;
      pay_core_files.write_to_magtape_lob(lc_xml_string1);
    END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF gb_debug  THEN
      hr_utility.set_location ('Leaving '||lc_proc_name,20);
    END IF;
  WHEN gc_exception THEN
    IF gb_debug  THEN
      hr_utility.set_location('Error in '||lc_proc_name,999999);
      hr_utility.set_location('sqleerm ' || SQLERRM,20);
    END IF;
    hr_utility.raise_error;
    RAISE;
  WHEN OTHERS THEN
    RAISE gc_exception;
  END generate_xml;
--
  PROCEDURE gen_xml_header
  --************************************************************************
  -- PROCEDURE
  --  gen_xml_header
  --
  -- DESCRIPTION
  --  This procedure generates XML header information and appends to
  --  pay_mag_tape.g_clob_value
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  --   None
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  AS
    lc_proc_name VARCHAR2(100);
    lc_buf       VARCHAR2(2000);
--
  BEGIN
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug THEN
      lc_proc_name := gc_pkg_name || 'gen_xml_header';
      hr_utility.set_location ('Entering '||lc_proc_name,20);
    END IF ;
--
    vxmltable.DELETE; -- delete the pl/sql table
--
    lc_buf := gc_eol ||'<ROOT>'||gc_eol ;
--
    pay_core_files.write_to_magtape_lob(lc_buf);
--
    IF gb_debug THEN
      hr_utility.set_location ('CLOB contents after appending header information',20);
      hr_utility.set_location ('Leaving '||lc_proc_name,20);
    END IF ;
--
  END gen_xml_header;
--
  PROCEDURE gen_xml_footer
  --************************************************************************
  -- PROCEDURE
  --  gen_xml_header
  --
  -- DESCRIPTION
  --  This procedure generates XML Footer information and appends to
  --  pay_mag_tape.g_clob_value
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  --   None
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  AS
    lc_buf       VARCHAR2(2000) ;
    lc_proc_name VARCHAR2(100);
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
    IF gb_debug  THEN
      lc_proc_name := gc_pkg_name || 'gen_xml_footer';
      hr_utility.set_location ('Entering '||lc_proc_name,20);
    END IF ;
    lc_buf := '</ROOT>' ;
--
    pay_core_files.write_to_magtape_lob(lc_buf);
--
    IF gb_debug THEN
      hr_utility.set_location ('CLOB contents after appending footer information',20);
      hr_utility.set_location ('Leaving '||lc_proc_name,20);
    END IF ;
--
  END gen_xml_footer;
--
  PROCEDURE deinitialise (p_payroll_action_id IN NUMBER)
  --************************************************************************
  -- PROCEDURE
  --  deinitialise
  --
  -- DESCRIPTION
  --  This procedure deletes the temporary archive data
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE      DESCRIPTION
  -- -----------------          --------  ----------------------------------
  -- p_assignment_action_id     IN        This parameter passes assignment Action ID
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
  BEGIN
    pay_archive.remove_report_actions(p_payroll_action_id);
  END deinitialise;

END per_jp_empdet_report_pkg;

/
