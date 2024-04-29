--------------------------------------------------------
--  DDL for Package Body PAY_JP_UITE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_UITE_REPORT_PKG" AS
-- $Header: pyjpuirp.pkb 120.0.12010000.14 2010/06/02 12:33:20 mpothala noship $
-- **************************************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.                         *
-- * All rights reserved                                                                            *
-- **************************************************************************************************
-- *                                                                                                *
-- * PROGRAM NAME                                                                                   *
-- *  PAY_JP_UITE_REPORT_PKG.pks                                                                    *
-- *                                                                                                *
-- * DESCRIPTION                                                                                    *
-- * This script creates the package body of PAY_JP_UITE_REPORT_PKG.                                *
-- *                                                                                                *
-- * USAGE                                                                                          *
-- *   To Install       sqlplus <apps_user>/<apps_pwd> @PAYJPUITEREPORTPKG.pkb                      *
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_UITE_REPORT_PKG<procedure name>  *
-- *                                                                                                *
-- * PROGRAM LIST                                                                                   *
-- * ==========                                                                                     *
-- * NAME                 DESCRIPTION                                                               *
-- * -----------------    --------------------------------------------------                        *
-- * RANGE_CURSOR                                                                                   *
-- * ACTION_CREATION                                                                                *
-- * GEN_XML_HEADER                                                                                 *
-- * GENERATE_XML                                                                                   *
-- * PRINT_CLOB                                                                                     *
-- * GEN_XML_FOOTER                                                                                 *
-- * INIT_CODE                                                                                      *
-- * ARCHIVE_CODE                                                                                   *
-- * ASSACT_XML                                                                                     *
-- * GET_CP_XML                                                                                     *
-- * WRITETOCLOB                                                                                    *
-- * CALLED BY                                                                                      *
-- * Concurrent Program Japan, Terminated Employee Report                                           *
-- *                                                                                                *
-- * LAST UPDATE DATE                                                                               *
-- *   Date the program has been modified for the last time                                         *
-- *                                                                                                *
-- * HISTORY                                                                                        *
-- * =======                                                                                        *
-- *                                                                                                *
-- * VERSION            DATE         AUTHOR(S)             DESCRIPTION                              *
-- * -------            -----------  ----------------      ----------------------------             *
-- * Draft             17/02/2010    RDARASI               intial                                   *
-- * 120.0.12010000.8  11/05/2010    MPOTHALA              Bug 9648106                              *
-- * 120.0.12010000.9  14/05/2010    MPOTHALA              Bug 9648106                              *
-- * 120.0.12010000.10 14/05/2010    MPOTHALA              Bug 9648106                              *
-- * 120.0.12010000.11 21/05/2010    MPOTHALA              Bug 9728602                              *
-- * 120.0.12010000.12 26/05/2010    MPOTHALA              Bug 9728572                              *
-- * 120.0.12010000.13 26/05/2010    MPOTHALA              Bug 9764235                              *
-- * 120.0.12010000.14 02/06/2010    MPOTHALA              Bug 9764235                              *
-- **************************************************************************************************
--
  g_write_xml             CLOB;
  g_xfdf_string           CLOB;
  gc_eol                  VARCHAR2(5) := fnd_global.local_chr(10);
  gc_proc_name            VARCHAR2(240);
  gc_pkg_name             VARCHAR2(30):= 'PAY_JP_UITE_REPORT_PKG.';
  gb_debug                BOOLEAN;
  gn_dummy                NUMBER      := -99 ;
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
  -- FUNCTION
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
--
    IF gb_debug
    THEN
      hr_utility.trace ('Entering CNV_STR');
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
      hr_utility.trace ('Leaving CNV_STR');
    END IF;
--
    RETURN lc_text;
--
  END cnv_str;
--
  FUNCTION htmlspchar(p_text IN  VARCHAR2)
  RETURN VARCHAR2
  --************************************************************************
  -- FUNCTION
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
--
    IF gb_debug THEN
      hr_utility.trace ('Entering htmlspchar');
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
  END htmlspchar;
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
  --    action_creation
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
  PROCEDURE get_numbers  ( p_input      IN               NUMBER
                         , p_input1     IN               VARCHAR2
                         , p_output     OUT      NOCOPY  VARCHAR2
                         )
  --************************************************************************
  -- PROCEDURE
  --  get_numbers
  --
  -- DESCRIPTION
  --  This is used to split the values into 1 Character
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ------------------------------------
  -- p_input                    IN
  -- p_input1                   IN
  -- p_output                   OUT
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  AS
    lc_proc_name             VARCHAR2(100);
    ln_input_num             NUMBER;
    lc_input_value           VARCHAR2(100);
    lc_output_value          VARCHAR2(4000);
  BEGIN
--
    lc_proc_name := gc_pkg_name ||'GET_NUMBERS';
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.trace ('Entering '||lc_proc_name);
    END IF;

    lc_input_value := p_input1;
    ln_input_num   := p_input;
    lc_output_value := NULL;

    IF (lc_input_value IS NOT NULL) THEN

      FOR i in 1 .. LENGTH(lc_input_value)
      LOOP
        lc_output_value := lc_output_value || '<P'||ln_input_num||'-'||i||'>'||htmlspchar(cnv_str(SUBSTR(lc_input_value,i,1)))||'</P'||ln_input_num||'-'||i||'>'||gc_eol;

      END LOOP;
    ELSE
      FOR i in 1 .. 11
      LOOP
        lc_output_value := lc_output_value || '<P'||ln_input_num||'-'||i||'></P'||ln_input_num||'-'||i||'>'||gc_eol;

      END LOOP;

    END IF;

    p_output := lc_output_value;
--
    IF gb_debug THEN
      hr_utility.trace ('Leaving '||lc_proc_name);
    END IF;
--
  END get_numbers;
--
PROCEDURE initialize(p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE )
--***************************************************************************
--   PROCEDURE
--   initialize
--  DESCRIPTION
--  This procedure is used to set global contexts
--
--   ACCESS
--   PUBLIC
--
-- PARAMETERS
-- ==========
-- NAME                       TYPE     DESCRIPTION
-- -----------------         -------- ---------------------------------------
-- p_payroll_action_id        IN       This parameter passes Payroll Action Id
--
-- PREREQUISITES
--   None
--
-- CALLED BY
--  action_creation
--*************************************************************************
  IS
--
  CURSOR lcr_params(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
  IS
  SELECT  pay_core_utils.get_parameter('PAYROLL_ACTION_ID',legislative_parameters)                            payroll_action_id
         ,pay_core_utils.get_parameter('ASSETID',legislative_parameters)                                      assignment_set_id
         ,pay_core_utils.get_parameter('REP_GROUP',legislative_parameters)                                    rep_group
         ,pay_core_utils.get_parameter('REP_CAT',legislative_parameters)                                      rep_cat
         ,pay_core_utils.get_parameter('BG',legislative_parameters)                                           business_group_id
         ,pay_core_utils.get_parameter('SUB',legislative_parameters)                                          subject_year
         ,TO_DATE(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')                  effective_date
         ,pay_core_utils.get_parameter('PAY_ARCH',legislative_parameters)                                     payroll_arch
         ,pay_core_utils.get_parameter('SORT1',legislative_parameters)                                         sort_order
  FROM  pay_payroll_actions PPA
  WHERE PPA.payroll_action_id  = p_payroll_action_id;
--
-- Local Variables
  lc_procedure               VARCHAR2(200);
--
  BEGIN
--
    gb_debug :=hr_utility.debug_enabled ;
    IF gb_debug THEN
      lc_procedure := gc_pkg_name||'initialize';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
--
    -- Fetch the parameters passed by user into global variable.
--
    OPEN  lcr_params(p_payroll_action_id);
    FETCH lcr_params into gr_parameters;
    CLOSE lcr_params;

    -- ADDED By rdarasi above
--
    IF gb_debug THEN
      hr_utility.set_location('p_payroll_action_id                  = ' || p_payroll_action_id,30);
      hr_utility.set_location('gr_parameters.payroll_action_id      = ' || gr_parameters.payroll_action_id,30);
      hr_utility.set_location('gr_parameters.ass_setid              = ' || gr_parameters.ass_setid,30);
      hr_utility.set_location('gr_parameters.rep_group              = ' || gr_parameters.rep_group,30);
      hr_utility.set_location('gr_parameters.rep_cat                = ' || gr_parameters.rep_cat,30);
      hr_utility.set_location('gr_parameters.business_group_id      = ' || gr_parameters.business_group_id,30);
      hr_utility.set_location('gr_parameters.subject_year           = ' || gr_parameters.subject_year,30);
      hr_utility.set_location('gr_parameters.effective_date         = ' || gr_parameters.effective_date,30);
      hr_utility.set_location('gr_parameters.payroll_arch           = ' || gr_parameters.payroll_arch,30);
      hr_utility.set_location('gr_parameters.sort_order             = ' || gr_parameters.sort_order,30);
    END IF;
--
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
--
  EXCEPTION
    WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in '||lc_procedure,999999);
    END IF;
    RAISE;
    WHEN OTHERS THEN
      RAISE  gc_exception;
  END initialize;
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
--
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      lc_proc_name := gc_pkg_name || 'GEN_XML_HEADER';
      hr_utility.trace ('Entering '||lc_proc_name);
    END IF ;
--
    vxmltable.DELETE;
--

    lc_buf := gc_eol ||'<ROOT>'||gc_eol ;
--
    pay_core_files.write_to_magtape_lob(lc_buf);
--
    IF gb_debug THEN
      hr_utility.trace ('CLOB contents after appending header information');
      hr_utility.trace ('Leaving '||lc_proc_name);
    END IF ;
--
  END gen_xml_header;
--
  PROCEDURE gen_xml_footer
  --************************************************************************
  -- PROCEDURE
  --  gen_xml_footer
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
--
    IF gb_debug  THEN
      lc_proc_name := gc_pkg_name || 'GEN_XML_FOOTER';
      hr_utility.trace ('Entering '||lc_proc_name);
    END IF ;
    lc_buf := '</ROOT>' ;
--
    pay_core_files.write_to_magtape_lob(lc_buf);
--
    IF gb_debug THEN
      hr_utility.trace ('CLOB contents after appending footer information');
      hr_utility.trace ('Leaving '||lc_proc_name);
    END IF ;
--
  END gen_xml_footer;
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
    l_final_xml_string         CLOB;
    lc_xml_string1             VARCHAR2(2000);
    lc_proc_name               VARCHAR2(60);
    lc_legislative_parameters  VARCHAR(2000);
    ln_old_assact_id           NUMBER;
    ln_pact_id                 NUMBER;
    ln_cur_pact                NUMBER;
    ln_cur_assact              NUMBER ;
    ln_offset                  NUMBER;
    ln_amount                  NUMBER;
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug  THEN
      lc_proc_name := gc_pkg_name || 'GENERATE_XML';
      hr_utility.trace ('Entering '||lc_proc_name);
    END IF ;
--
    ln_cur_assact := pay_magtape_generic.get_parameter_value  ('TRANSFER_ACT_ID' );
    ln_cur_pact   := pay_magtape_generic.get_parameter_value  ('TRANSFER_PAYROLL_ACTION_ID' );
--
    SELECT legislative_parameters
    INTO   lc_legislative_parameters
    FROM   pay_payroll_actions
    WHERE  payroll_action_id = ln_cur_pact;
--
    ln_pact_id   := fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAY_ARCH',lc_legislative_parameters));

    hr_utility.set_location ('ln_cur_assact.. '||ln_cur_assact,20);
    hr_utility.set_location ('ln_cur_pact...  '||ln_cur_pact,20);
    hr_utility.set_location ('ln_pact_id ..   '||ln_pact_id,20);
--
    SELECT PAA1.assignment_action_id
    INTO   ln_old_assact_id
    FROM   pay_assignment_actions PAA,
           pay_assignment_actions PAA1
    WHERE  PAA.assignment_action_id = ln_cur_assact
    AND    PAA.assignment_id        = PAA1.assignment_id
    AND    PAA1.payroll_action_id   = ln_pact_id;
--
    hr_utility.set_location ('ln_old_assact_id ..'||ln_old_assact_id,20);
    get_cp_xml(ln_old_assact_id, l_final_xml_string);
--
    ln_offset := 1 ;
    ln_amount := 500;

--
    LOOP
      lc_xml_string1 := NULL;
      dbms_lob.read(l_final_xml_string,ln_amount,ln_offset,lc_xml_string1);
      pay_core_files.write_to_magtape_lob(lc_xml_string1);
      ln_offset := ln_offset + ln_amount ;
    END LOOP;
--
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF gb_debug  THEN
      hr_utility.set_location ('Leaving '||lc_proc_name,20);
    END IF ;
  WHEN gc_exception THEN
    IF gb_debug  THEN
      hr_utility.set_location('Error in '||lc_proc_name,999999);
      hr_utility.set_location('sqleerm ' || SQLERRM,20);
    END IF ;
      hr_utility.raise_error;
    RAISE;
  WHEN OTHERS THEN
    RAISE gc_exception;
--
  END generate_xml;
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
  -- p_payroll_action_id        IN        This parameter passes payroll_action_id object
  -- p_sqlstr                             OUT      This parameter returns the SQL Statement
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
--
    lc_proc_name := gc_pkg_name ||'RANGE_CURSOR';
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.trace ('Entering '||lc_proc_name);
      hr_utility.trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);
    END IF;
--
    p_sqlstr := ' select distinct p.person_id'||
                ' from   per_people_f p,'||
                ' pay_payroll_actions pa'||
                ' where  pa.payroll_action_id = :payroll_action_id'||
                ' and    p.business_group_id = pa.business_group_id'||
                ' order by p.person_id ';
--
    g_mag_payroll_action_id := P_PAYROLL_ACTION_ID;
--
    IF gb_debug THEN
      hr_utility.trace ('Range cursor query : ' || p_sqlstr);
      hr_utility.trace ('Leaving '||lc_proc_name);
    END IF;
--
  END range_cursor;

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
  CURSOR lcu_assact_r( p_payroll_action_id_arch  pay_payroll_actions.payroll_action_id%TYPE
                     , p_business_group_id       per_assignments_f.business_group_id%TYPE
                     )
  IS
  SELECT DISTINCT PJUIEV.assignment_id
        ,PJUIEV.termination_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,pay_jp_uite_emp_v        PJUIEV
        ,per_periods_of_service   PPOF
        ,pay_population_ranges    PPR
        ,pay_payroll_actions      PPA
        ,hr_all_organization_units  HAOU
  WHERE PAA.person_id                        = PAP.person_id
  AND   PPA.payroll_action_id                = PPR.payroll_action_id
  AND   PPR.person_id                        = PAP.person_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   HAOU.organization_id                 = PAA.organization_id
  AND   PPOF.person_id                       = PAP.person_id
  AND   PJUIEV.assignment_action_id          = PAS.assignment_action_id
  AND   PJUIEV.assignment_id                 = PAS.assignment_id
  AND   PPA.payroll_action_id                = p_payroll_action_id
  AND   PPR.chunk_number                     = p_chunk
  AND   PAS.payroll_action_id                = p_payroll_action_id_arch
  AND   PAA.business_group_id                = p_business_group_id
  AND   TRUNC(NVL(PPOF.actual_termination_date,PPOF.projected_termination_date)) BETWEEN PAP.effective_start_date
                                            AND PAP.effective_end_date
  AND   TRUNC(NVL(PPOF.actual_termination_date,PPOF.projected_termination_date)) BETWEEN PAA.effective_start_date
                                            AND PAA.effective_end_date; -- Bug 9728577


  --
  CURSOR lcu_assact( p_payroll_action_id_arch   pay_payroll_actions.payroll_action_id%TYPE
                   , p_business_group_id        per_assignments_f.business_group_id%TYPE
                   )
  IS
  SELECT DISTINCT PJUIEV.assignment_id
        ,PJUIEV.termination_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,pay_jp_uite_emp_v        PJUIEV
        ,per_periods_of_service   PPOF
        ,hr_all_organization_units  HAOU
  WHERE PAA.person_id                        = PAP.person_id
  AND   PAA.person_id                       BETWEEN p_start_person_id
                                            AND     p_end_person_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   PAS.payroll_action_id                = p_payroll_action_id_arch
  AND   PPOF.person_id                       = PAP.person_id
  AND   PJUIEV.assignment_action_id          = PAS.assignment_action_id
  AND   PJUIEV.assignment_id                 = PAS.assignment_id
  AND   HAOU.organization_id                 = PAA.organization_id
  AND   PAA.business_group_id                = p_business_group_id
  AND   TRUNC(NVL(PPOF.actual_termination_date,PPOF.projected_termination_date)) BETWEEN PAP.effective_start_date
                                            AND PAP.effective_end_date
  AND   TRUNC(NVL(PPOF.actual_termination_date,PPOF.projected_termination_date)) BETWEEN PAA.effective_start_date
                                            AND PAA.effective_end_date; -- Bug 9728577

  --
  ln_assact                 pay_assignment_actions.assignment_action_id%TYPE ;
  lc_proc_name              VARCHAR2(60);
  lc_legislative_parameters VARCHAR2(2000);
  ln_old_pact_id            NUMBER;
  ln_ass_set_id             NUMBER;
  lc_include_flag           VARCHAR2(1);
--
  BEGIN
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug
    THEN
      hr_utility.trace('Entering ACTION_CREATION');
    END IF;
--
    SELECT legislative_parameters
    INTO   lc_legislative_parameters
    FROM   pay_payroll_actions
    WHERE  payroll_action_id = p_payroll_action_id;
--
    ln_old_pact_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAY_ARCH',lc_legislative_parameters));
    ln_ass_set_id  := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASSETID',lc_legislative_parameters));
--
    g_mag_payroll_action_id:=p_payroll_action_id;
    gb_debug :=hr_utility.debug_enabled ;
--

    IF gb_debug  THEN
      lc_proc_name := gc_pkg_name ||'ACTION_CREATION';
      hr_utility.trace ('Entering '||lc_proc_name);
      hr_utility.trace ('Parameters ....');
      hr_utility.trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);
      hr_utility.trace ('P_START_PERSON_ID   = '|| p_start_person_id);
      hr_utility.trace ('P_END_PERSON_ID     = '|| p_end_person_id);
      hr_utility.trace ('P_CHUNK             = '|| p_chunk);
    END IF;
--
    initialize(g_mag_payroll_action_id);
--
--
    IF range_person_on THEN
--                          Range person is enabled
      IF gb_debug THEN
        hr_utility.set_location('Inside Range person if condition',20);
      END IF;
--                         Assignment Action for Current and Terminated Employees
      FOR lr_assact IN lcu_assact_r( ln_old_pact_id
                                   , gr_parameters.business_group_id
                                   )
      LOOP
-- Added NVL to overcome NULL issue.
--
        IF (NVL(ln_ass_set_id ,0) = 0) THEN
        -- NO assignment set passed as parameter
          hr_utility.trace ('ass_id = '||lr_assact.assignment_id);
--
          SELECT pay_assignment_actions_s.nextval
          INTO ln_assact
          FROM dual;
          hr_nonrun_asact.insact (ln_assact
                                 ,lr_assact.assignment_id
                                 ,p_payroll_action_id
                                 ,p_chunk
                                 ,NULL
                                 );
        ELSE
        -- assignment set is passed as parameter
          lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => ln_ass_set_id
                                                                          ,p_assignment_id     => lr_assact.assignment_id
                                                                          ,p_effective_date    => lr_assact.termination_date
                                                                          ,p_populate_fs_flag  => 'Y'  -- added for the bug #9652329
                                                                          );
          IF lc_include_flag = 'Y' THEN
--
            SELECT pay_assignment_actions_s.nextval
            INTO ln_assact
            FROM dual;
            hr_nonrun_asact.insact (ln_assact
                                   ,lr_assact.assignment_id
                                   ,p_payroll_action_id
                                   ,p_chunk
                                   ,NULL
                                   );

          END IF;
        END IF;
      END LOOP;-- End loop for assignment details cursor
    ELSE
                  -- Range person is not enabled
      IF gb_debug THEN
        hr_utility.set_location('Range person returns false',20);
        hr_utility.set_location(ln_old_pact_id,20);
      END IF;
      --        Assignment Action for Current and Terminated Employe
      FOR lr_assact IN lcu_assact ( ln_old_pact_id
                                  , gr_parameters.business_group_id
                                  )
      LOOP
          -- Added NVL to overcome NULL issue.
--
        IF (NVL(ln_ass_set_id ,0) = 0) THEN
        -- NO assignment set passed as parameter
          hr_utility.trace ('ass_id = '||lr_assact.assignment_id);
--
          SELECT pay_assignment_actions_s.nextval
          INTO ln_assact
          FROM dual;
          hr_nonrun_asact.insact( ln_assact
                                 ,lr_assact.assignment_id
                                 ,p_payroll_action_id
                                 ,p_chunk
                                 ,NULL
                                 );
        ELSE
         -- assignment set is passed as parameter
          lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate (p_assignment_set_id => ln_ass_set_id
                                                                           ,p_assignment_id     => lr_assact.assignment_id
                                                                           ,p_effective_date    => lr_assact.termination_date
                                                                           );
          IF lc_include_flag = 'Y' THEN
            SELECT pay_assignment_actions_s.nextval
            INTO ln_assact
            FROM dual;
            hr_nonrun_asact.insact( ln_assact
                                   ,lr_assact.assignment_id
                                   ,p_payroll_action_id
                                   ,p_chunk
                                   ,NULL
                                   );
          END IF;

        END IF;
      END LOOP;-- End loop for assignment details cursor
    END IF; -- End If for range_person_on
--
    IF gb_debug
    THEN
      hr_utility.trace('Leaving ACTION_CREATION');
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
--
    IF gb_debug THEN
      hr_utility.trace ('inside INIT_CODE ');
    END IF;
--
    g_mag_payroll_action_id := p_payroll_action_id;
--
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
--
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug
    THEN
      hr_utility.trace ('Inside ARCHIVE_CODE ');
    END IF;
--
  END archive_code;
--
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
  --Cursor to pick the employee details

  CURSOR cur_uite_emp(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJUIEV.employee_number
       , PJUIEV.insured_number                                                                  INSURED_NUMBER
       , PJUIEV.last_name_kana
       , PJUIEV.first_name_kana
       , PJUIEV.last_name
       , PJUIEV.first_name
       , TO_CHAR(PJUIEV.termination_date, 'YY MM DD', 'NLS_CALENDAR=''Japanese Imperial''')     TERMINATION_DATE
       , TO_CHAR(PJUIEV.termination_date, 'YY', 'NLS_CALENDAR=''Japanese Imperial''')           TERMINATION_DATE_YY
       , TO_CHAR(PJUIEV.termination_date, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')           TERMINATION_DATE_MM
       , TO_CHAR(PJUIEV.termination_date, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')           TERMINATION_DATE_DD
       , TO_CHAR(PJUIEV.termination_date + 1, 'YY MM DD', 'NLS_CALENDAR=''Japanese Imperial''') FOLLOWING_DATE_TERM
       , TO_CHAR(PJUIEV.termination_date + 1, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')       FOLLOWING_DATE_TERM_MM
       , TO_CHAR(PJUIEV.termination_date + 1, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')       FOLLOWING_DATE_TERM_DD
       , SUBSTR(PJUIEV.postal_code,1,3)||NVL2(PJUIEV.postal_code,'-',' ')|| SUBSTR(PJUIEV.postal_code,4)   POSTAL_CODE -- changed as per the bug#9648063
       , PJUIEV.address_line1
       , PJUIEV.address_line2
       , PJUIEV.address_line3
       , PJUIEV.phone_number
  FROM   pay_jp_uite_emp_v PJUIEV
  WHERE  PJUIEV.assignment_action_id = p_mag_asg_action_id;

  CURSOR cur_uite_office(p_payroll_action_id  NUMBER)
  IS
  SELECT  PJUIOV.location_number                                                                LOCATION_NUMBER
        , PJUIOV.location_name
        , PJUIOV.loc_address_line1
        , PJUIOV.loc_address_line2
        , PJUIOV.loc_address_line3
        , PJUIOV.loc_phone_number
        , PJUIOV.employer_full_name
        , PJUIOV.employer_address_line1
        , PJUIOV.employer_address_line2
        , PJUIOV.employer_address_line3
        , PJUIOV.employer_name                                                                 -- Added as per the bug#9648053
  FROM   pay_jp_uite_office_v    PJUIOV
  WHERE  PJUIOV.payroll_action_id = p_payroll_action_id;

  CURSOR cur_uite_sal(p_mag_asg_action_id  NUMBER)
  IS
  SELECT TO_CHAR(PJUISV.payment_date, 'YY MM DD', 'NLS_CALENDAR=''Japanese Imperial''')          PAYMENT_DATE
       , TO_CHAR(PJUISV.ins_period_start_date, 'YY MM DD', 'NLS_CALENDAR=''Japanese Imperial''') INS_PERIOD_START_DATE
       , TO_CHAR(PJUISV.ins_period_start_date, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')       INS_PERIOD_START_DATE_MM
       , TO_CHAR(PJUISV.ins_period_start_date, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')       INS_PERIOD_START_DATE_DD
       , TO_CHAR(PJUISV.ins_period_end_date, 'YY MM DD', 'NLS_CALENDAR=''Japanese Imperial''')   INS_PERIOD_END_DATE
       , TO_CHAR(PJUISV.ins_period_end_date, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')         INS_PERIOD_END_DATE_MM
       , TO_CHAR(PJUISV.ins_period_end_date, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')         INS_PERIOD_END_DATE_DD
       , PJUISV.ins_period_base_days
       , TO_CHAR(PJUISV.pay_period_start_date, 'YY MM DD', 'NLS_CALENDAR=''Japanese Imperial''') PAY_PERIOD_START_DATE
       , TO_CHAR(PJUISV.pay_period_start_date, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')       PAY_PERIOD_START_DATE_MM
       , TO_CHAR(PJUISV.pay_period_start_date, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')       PAY_PERIOD_START_DATE_DD
       , TO_CHAR(PJUISV.pay_period_end_date, 'YY MM DD', 'NLS_CALENDAR=''Japanese Imperial''')   PAY_PERIOD_END_DATE
       , TO_CHAR(PJUISV.pay_period_end_date, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')         PAY_PERIOD_END_DATE_MM
       , TO_CHAR(PJUISV.pay_period_end_date, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')         PAY_PERIOD_END_DATE_DD
       , PJUISV.pay_period_base_days
       , PJUISV.wage_amount_a
       , PJUISV.wage_amount_b
       , PJUISV.wage_amount_total
       , PJUISV.remarks
       , PJUISV.exclude_period
       , PJUISV.line_number
  FROM   pay_jp_uite_sal_v PJUISV
  WHERE  PJUISV.assignment_action_id = p_mag_asg_action_id
  AND    PJUISV.exclude_period       = 'N'
  ORDER BY PJUISV.line_number;  -- Added for the Bug# 9648278

  CURSOR cur_uite_term(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJUITV.termination_reason
       , PJUITV.concrete_circumstance1
       , PJUITV.concrete_circumstance2
  FROM   pay_jp_uite_term_v PJUITV
  WHERE  PJUITV.assignment_action_id = p_mag_asg_action_id;

  CURSOR cur_uite_wage(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJUIIV.wage_instruction1
       , PJUIIV.wage_instruction2
  FROM   PAY_JP_UITE_INSTR_V PJUIIV
  WHERE  PJUIIV.assignment_action_id = p_mag_asg_action_id;

  --
  lr_uite_emp             cur_uite_emp%ROWTYPE;
  lr_uite_office          cur_uite_office%ROWTYPE;
  lr_uite_sal             cur_uite_sal%ROWTYPE;
  lr_uite_term            cur_uite_term%ROWTYPE;
  lr_uite_wage            cur_uite_wage%ROWTYPE;

   --Variables-----
  l_xml                   CLOB;
  l_xml2                  CLOB;
  l_common_xml            CLOB;
  l_emp_xml               CLOB;
  l_sal_xml               CLOB;
  l_term_xml              CLOB;
  l_wage_xml              CLOB;
  l_xml_begin             VARCHAR2(200);
  l_mag_asg_action_id     pay_assignment_actions.assignment_action_id%TYPE;
  seque                   NUMBER;
  lc_insured_number       VARCHAR2(4000);
  lc_location_number      VARCHAR2(4000);
  ln_termination_value    NUMBER;
  ln_row_count            NUMBER:=0;  --bug 9764235
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.trace ('Entering assact_xml');
    END IF;
--
    vXMLTable.DELETE;
    gn_vctr := 0;

--
    l_mag_asg_action_id := p_assignment_action_id;
--
    initialize(g_mag_payroll_action_id);
--
--  Fetching the employee details.
    OPEN  cur_uite_emp(l_mag_asg_action_id);
    FETCH cur_uite_emp INTO lr_uite_emp;

--
    IF (cur_uite_emp%FOUND) THEN
--
      l_xml_begin := '<uiterpt>'||gc_eol;
      vXMLTable(gn_vctr).xmlstring :=  l_xml_begin;
      gn_vctr := gn_vctr + 1;

--
      OPEN  cur_uite_office(gr_parameters.payroll_arch);
      FETCH cur_uite_office INTO lr_uite_office;
      CLOSE cur_uite_office;

        get_numbers(1,lr_uite_emp.insured_number,lc_insured_number);

        get_numbers(2,lr_uite_office.location_number,lc_location_number);


      l_common_xml := lc_insured_number||lc_location_number||'<YR>'||htmlspchar(cnv_str(gr_parameters.subject_year))||'</YR>'
                    ||'<P1>'||htmlspchar(cnv_str(lr_uite_emp.insured_number))||'</P1>'||gc_eol
                    ||'<P2>'||htmlspchar(cnv_str(lr_uite_office.location_number))||'</P2>'||gc_eol
                    ||'<P3>'||htmlspchar(cnv_str(lr_uite_emp.last_name_kana||' '||lr_uite_emp.first_name_kana))||'</P3>'||gc_eol
                    ||'<P4>'||htmlspchar(cnv_str(lr_uite_emp.last_name||' '||lr_uite_emp.first_name))||'</P4>'||gc_eol
                    ||'<P5>'||htmlspchar(cnv_str(lr_uite_emp.termination_date))||'</P5>'||gc_eol
                    ||'<P5_YY>'||htmlspchar(cnv_str(lr_uite_emp.termination_date_yy))||'</P5_YY>'||gc_eol
                    ||'<P5_MM>'||htmlspchar(cnv_str(lr_uite_emp.termination_date_mm))||'</P5_MM>'||gc_eol
                    ||'<P5_DD>'||htmlspchar(cnv_str(lr_uite_emp.termination_date_dd))||'</P5_DD>'||gc_eol
                    ||'<P6>'||htmlspchar(cnv_str(lr_uite_office.location_name))||'</P6>'||gc_eol
                    ||'<P7>'||htmlspchar(cnv_str(lr_uite_office.loc_address_line1||lr_uite_office.loc_address_line2||lr_uite_office.loc_address_line3))||'</P7>'||gc_eol
                    ||'<P8>'||htmlspchar(cnv_str(lr_uite_office.loc_phone_number))||'</P8>'||gc_eol
                    ||'<P9>'||htmlspchar(cnv_str(lr_uite_emp.address_line1||lr_uite_emp.address_line2||lr_uite_emp.address_line3))||'</P9>'||gc_eol
                    ||'<P10>'||htmlspchar(cnv_str(lr_uite_emp.phone_number))||'</P10>'||gc_eol
                    ||'<P11>'||htmlspchar(cnv_str(lr_uite_office.employer_address_line1||lr_uite_office.employer_address_line2||lr_uite_office.employer_address_line3))||'</P11>'||gc_eol
                    ||'<P12>'||htmlspchar(cnv_str(lr_uite_office.employer_full_name))||'</P12>'||gc_eol
                    ||'<P13>'||htmlspchar(cnv_str(lr_uite_emp.following_date_term))||'</P13>'||gc_eol
                    ||'<P13_MM>'||htmlspchar(cnv_str(lr_uite_emp.following_date_term_mm))||'</P13_MM>'||gc_eol
                    ||'<P13_DD>'||htmlspchar(cnv_str(lr_uite_emp.following_date_term_dd))||'</P13_DD>'||gc_eol
                    ||'<P14>'||htmlspchar(cnv_str(lr_uite_emp.employee_number))||'</P14>'||gc_eol
                    ||'<P15>'||htmlspchar(cnv_str(lr_uite_emp.postal_code))||'</P15>'||gc_eol
                    ||'<P16>'||htmlspchar(cnv_str(lr_uite_office.employer_name))||'</P16>'||gc_eol; -- Added as per the bug#9648053

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;
      -- Bug 9648106 start
      l_emp_xml := lc_insured_number||lc_location_number||'<YR>'||htmlspchar(cnv_str(gr_parameters.subject_year))||'</YR>'
                    ||'<P1>'||htmlspchar(cnv_str(lr_uite_emp.insured_number))||'</P1>'||gc_eol
                    ||'<P2>'||htmlspchar(cnv_str(lr_uite_office.location_number))||'</P2>'||gc_eol
                    ||'<P3>'||htmlspchar(cnv_str(lr_uite_emp.last_name_kana||' '||lr_uite_emp.first_name_kana))||'</P3>'||gc_eol
                    ||'<P4>'||htmlspchar(cnv_str(lr_uite_emp.last_name||' '||lr_uite_emp.first_name))||'</P4>'||gc_eol
                    ||'<P5>'||htmlspchar(cnv_str(lr_uite_emp.termination_date))||'</P5>'||gc_eol
                    ||'<P5_YY>'||htmlspchar(cnv_str(lr_uite_emp.termination_date_yy))||'</P5_YY>'||gc_eol
                    ||'<P5_MM>'||htmlspchar(cnv_str(lr_uite_emp.termination_date_mm))||'</P5_MM>'||gc_eol
                    ||'<P5_DD>'||htmlspchar(cnv_str(lr_uite_emp.termination_date_dd))||'</P5_DD>'||gc_eol
                    ||'<P6></P6>'||gc_eol
                    ||'<P7></P7>'||gc_eol
                    ||'<P8></P8>'||gc_eol
                    ||'<P9></P9>'||gc_eol
                    ||'<P10></P10>'||gc_eol
                     ||'<P11>'||htmlspchar(cnv_str(lr_uite_office.employer_address_line1||lr_uite_office.employer_address_line2||lr_uite_office.employer_address_line3))||'</P11>'||gc_eol
                    ||'<P12>'||htmlspchar(cnv_str(lr_uite_office.employer_full_name))||'</P12>'||gc_eol
                    ||'<P13>'||htmlspchar(cnv_str(lr_uite_emp.following_date_term))||'</P13>'||gc_eol
                    ||'<P13_MM>'||htmlspchar(cnv_str(lr_uite_emp.following_date_term_mm))||'</P13_MM>'||gc_eol
                    ||'<P13_DD>'||htmlspchar(cnv_str(lr_uite_emp.following_date_term_dd))||'</P13_DD>'||gc_eol
                    ||'<P14>'||htmlspchar(cnv_str(lr_uite_emp.employee_number))||'</P14>'||gc_eol
                    ||'<P15></P15>'||gc_eol
                    ||'<P16>'||htmlspchar(cnv_str(lr_uite_office.employer_name))||'</P16>'||gc_eol;
      -- Bug 9648106 end
      --
      lr_uite_office := NULL;
      l_common_xml   := NULL;
      l_term_xml     := NULL;
      seque       := 1;


      OPEN  cur_uite_term(l_mag_asg_action_id);
      FETCH cur_uite_term INTO lr_uite_term;
      CLOSE cur_uite_term;


      CASE
      WHEN lr_uite_term.termination_reason = '1_1' THEN ln_termination_value := 1;
      WHEN lr_uite_term.termination_reason = '1_2' THEN ln_termination_value := 2;
      WHEN lr_uite_term.termination_reason = '2_1' THEN ln_termination_value := 3;
      WHEN lr_uite_term.termination_reason = '2_2' THEN ln_termination_value := 4;
      WHEN lr_uite_term.termination_reason = '2_3' THEN ln_termination_value := 5;
      WHEN lr_uite_term.termination_reason = '2_4' THEN ln_termination_value := 6;
      WHEN lr_uite_term.termination_reason = '2_5' THEN ln_termination_value := 7;
      WHEN lr_uite_term.termination_reason = '3_1' THEN ln_termination_value := 8;
      WHEN lr_uite_term.termination_reason = '3_2' THEN ln_termination_value := 9;
      WHEN lr_uite_term.termination_reason = '3_3_1' THEN ln_termination_value := 10;
      WHEN lr_uite_term.termination_reason = '3_3_2' THEN ln_termination_value := 11;
      WHEN lr_uite_term.termination_reason = '4_1_1' THEN ln_termination_value := 12;
      WHEN lr_uite_term.termination_reason = '4_1_2' THEN ln_termination_value := 13;
      WHEN lr_uite_term.termination_reason = '4_1_3' THEN ln_termination_value := 14;
      WHEN lr_uite_term.termination_reason = '4_1_4' THEN ln_termination_value := 15;
      WHEN lr_uite_term.termination_reason = '4_1_5' THEN ln_termination_value := 16;
      WHEN lr_uite_term.termination_reason = '4_1_6' THEN ln_termination_value := 17;
      WHEN lr_uite_term.termination_reason = '4_2' THEN ln_termination_value := 18;
      WHEN lr_uite_term.termination_reason = '5' THEN ln_termination_value := 19;
      ELSE ln_termination_value := 0;
      END CASE;

      FOR i in 1 .. 19
      LOOP
        IF i = ln_termination_value THEN
          l_common_xml := l_common_xml||'<T'||i||'>'||htmlspchar(cnv_str('O'))||'</T'||i||'>'||gc_eol; -- changed as per the bug #9648122
        ELSE
          l_common_xml := l_common_xml||'<T'||i||'></T'||i||'>'||gc_eol;
        END IF;
      END LOOP;

      l_common_xml := l_common_xml||'<T20>'||htmlspchar(cnv_str(lr_uite_term.concrete_circumstance1||lr_uite_term.concrete_circumstance2))||'</T20>'||gc_eol;

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      ln_termination_value := NULL;
      lr_uite_term   := NULL;
      l_common_xml   := NULL;

      OPEN  cur_uite_wage(l_mag_asg_action_id);
      FETCH cur_uite_wage INTO lr_uite_wage;
      CLOSE cur_uite_wage;

      l_common_xml := '<W1>'||htmlspchar(cnv_str(lr_uite_wage.wage_instruction1 || lr_uite_wage.wage_instruction2))||'</W1>'||gc_eol;
      l_wage_xml:= '<W1>'||htmlspchar(cnv_str(lr_uite_wage.wage_instruction1 || lr_uite_wage.wage_instruction2))||'</W1>'||gc_eol;

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      lr_uite_wage   := NULL;
      l_common_xml   := NULL;



      OPEN  cur_uite_sal(l_mag_asg_action_id);
      LOOP
      FETCH cur_uite_sal INTO lr_uite_sal;
      EXIT WHEN (seque = 15 AND cur_uite_sal%NOTFOUND);

        IF cur_uite_sal%NOTFOUND THEN
          lr_uite_sal := NULL;
        END IF;
        -- Changed by 9728602 --
         IF (lr_uite_sal.line_number >= 13 AND seque = 14) THEN
            seque := 2;
            l_common_xml := l_common_xml || l_sal_xml ;

            l_term_xml := l_wage_xml;

            FOR i in 1 .. 20
            LOOP
             l_term_xml := l_term_xml||'<T'||i||'></T'||i||'>'||gc_eol;
            END LOOP;
            l_common_xml := l_common_xml || l_term_xml;
            l_common_xml := l_common_xml || l_emp_xml;
            l_sal_xml  := NULL;
            l_term_xml := NULL;

            IF l_common_xml IS NOT NULL THEN
              l_xml :=gc_eol||l_common_xml||gc_eol;
              vXMLTable(gn_vctr).xmlstring := l_xml;
              gn_vctr := gn_vctr + 1;
            END IF;
            l_common_xml := NULL;

         END IF;
         -- Changed for 9728602 --

        IF seque <= 13 THEN
          l_sal_xml := l_sal_xml ||'<S'||seque||'-1>'||htmlspchar(cnv_str(lr_uite_sal.ins_period_start_date))||'</S'||seque||'-1>'||gc_eol
                                       ||'<S'||seque||'-1_MM>'||htmlspchar(cnv_str(lr_uite_sal.ins_period_start_date_mm))||'</S'||seque||'-1_MM>'||gc_eol
                                       ||'<S'||seque||'-1_DD>'||htmlspchar(cnv_str(lr_uite_sal.ins_period_start_date_dd))||'</S'||seque||'-1_DD>'||gc_eol
                                       ||'<S'||seque||'-2>'||htmlspchar(cnv_str(lr_uite_sal.ins_period_end_date))||'</S'||seque||'-2>'||gc_eol
                                       ||'<S'||seque||'-2_MM>'||htmlspchar(cnv_str(lr_uite_sal.ins_period_end_date_mm))||'</S'||seque||'-2_MM>'||gc_eol
                                       ||'<S'||seque||'-2_DD>'||htmlspchar(cnv_str(lr_uite_sal.ins_period_end_date_dd))||'</S'||seque||'-2_DD>'||gc_eol
                                       ||'<S'||seque||'-3>'||htmlspchar(cnv_str(lr_uite_sal.ins_period_base_days))||'</S'||seque||'-3>'||gc_eol
                                       ||'<S'||seque||'-4>'||htmlspchar(cnv_str(lr_uite_sal.pay_period_start_date))||'</S'||seque||'-4>'||gc_eol
                                       ||'<S'||seque||'-4_MM>'||htmlspchar(cnv_str(lr_uite_sal.pay_period_start_date_mm))||'</S'||seque||'-4_MM>'||gc_eol
                                       ||'<S'||seque||'-4_DD>'||htmlspchar(cnv_str(lr_uite_sal.pay_period_start_date_dd))||'</S'||seque||'-4_DD>'||gc_eol
                                       ||'<S'||seque||'-5>'||htmlspchar(cnv_str(lr_uite_sal.pay_period_end_date))||'</S'||seque||'-5>'||gc_eol
                                       ||'<S'||seque||'-5_MM>'||htmlspchar(cnv_str(lr_uite_sal.pay_period_end_date_mm))||'</S'||seque||'-5_MM>'||gc_eol
                                       ||'<S'||seque||'-5_DD>'||htmlspchar(cnv_str(lr_uite_sal.pay_period_end_date_dd))||'</S'||seque||'-5_DD>'||gc_eol
                                       ||'<S'||seque||'-6>'||htmlspchar(cnv_str(lr_uite_sal.pay_period_base_days))||'</S'||seque||'-6>'||gc_eol
                                       ||'<S'||seque||'-7>'||htmlspchar(cnv_str(lr_uite_sal.wage_amount_a))||'</S'||seque||'-7>'||gc_eol
                                       ||'<S'||seque||'-8>'||htmlspchar(cnv_str(lr_uite_sal.wage_amount_b))||'</S'||seque||'-8>'||gc_eol
                                       ||'<S'||seque||'-9>'||htmlspchar(cnv_str(lr_uite_sal.wage_amount_total))||'</S'||seque||'-9>'||gc_eol
                                       ||'<S'||seque||'-10>'||htmlspchar(cnv_str(lr_uite_sal.remarks))||'</S'||seque||'-10>'||gc_eol
                                       ||'<S'||seque||'-11>'||htmlspchar(cnv_str(lr_uite_sal.exclude_period))||'</S'||seque||'-11>'||gc_eol
                                       ||'<S'||seque||'-12>'||htmlspchar(cnv_str(lr_uite_sal.line_number))||'</S'||seque||'-12>';

        END IF;
        seque := seque + 1;

      END LOOP;
      CLOSE cur_uite_sal;



      l_xml :=gc_eol||l_sal_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      lr_uite_sal  := NULL;
      l_emp_xml    := NULL;
      l_common_xml := NULL;
      l_sal_xml    := NULL;
      l_wage_xml   := NULL;

      l_xml2 :='</uiterpt>'||gc_eol ;
      vXMLTable(gn_vctr).xmlstring := l_xml2;
      gn_vctr := gn_vctr + 1;

    END IF;
    lr_uite_emp := NULL;

    CLOSE cur_uite_emp;
--
--
     IF gb_debug THEN
       hr_utility.trace ('Leaving assact_xml');
     END IF;
--
    EXCEPTION
     WHEN gc_exception THEN
       IF gb_debug  THEN
         hr_utility.set_location('Error in assact_xml ',999999);
         hr_utility.set_location('sqleerm ' || SQLERRM,20);
         hr_utility.raise_error;
       END IF;
     WHEN OTHERS THEN
       RAISE  gc_exception;
  END assact_xml;
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
--
    IF gb_debug THEN
      hr_utility.trace ('Entering PRINT_CLOB');
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
      hr_utility.trace(lc_buf);
      ln_offset := ln_offset + ln_chars;
    END LOOP;
--
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.trace ('CLOB contents end.');
    END IF;
--
  END print_clob;
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
  BEGIN
--
   gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.trace('Entering WRITETOCLOB');
    END IF;
--
    dbms_lob.createtemporary(g_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(g_xfdf_string,dbms_lob.lob_readwrite);
    --
    FOR ln_ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST
    LOOP
      dbms_lob.writeAppend(g_xfdf_string
                          ,LENGTH(vxmltable(ln_ctr_table).xmlstring)
                          ,vxmltable(ln_ctr_table).xmlstring );
    END LOOP;
    p_write_xml := g_xfdf_string;
--
    IF gb_debug THEN
      hr_utility.set_location('Out of loop ', 99);
    END IF;
--
    dbms_lob.close(g_xfdf_string);
    IF gb_debug THEN
      hr_utility.trace('Leaving WRITETOCLOB');
    END IF;
--
  EXCEPTION
    WHEN gc_exception THEN
      IF gb_debug THEN
        hr_utility.set_location('Error in writetoclob ',999999);
        hr_utility.set_location('sqleerm ' || SQLERRM,20);
        hr_utility.raise_error;
      END IF;
    WHEN OTHERS THEN
      RAISE  gc_exception;
--
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
--
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.trace('Entering GET_CP_XML');
    END IF;
--
    assact_xml(p_assignment_action_id);
    writetoclob (p_xml);
--
    IF gb_debug THEN
      hr_utility.trace('Leaving GET_CP_XML');
    END IF;
--
  END get_cp_xml;
--

--
  PROCEDURE deinitialise (p_payroll_action_id IN NUMBER)
  IS
  --
  BEGIN

    --pay_archive.remove_report_actions(p_payroll_action_id);
    NULL;

  END deinitialise;

  PROCEDURE sort_action( p_payroll_action_id   IN     NUMBER
                       , sqlstr                IN OUT NOCOPY VARCHAR2
                       , len                   OUT   NOCOPY NUMBER
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
    lc_order_by       VARCHAR2(100);

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


    IF (gr_parameters.sort_order = 'EMPLOYEE_NUMBER') THEN
      lc_order_by := 'UPPER(PPF.employee_number), NVL(PPS.actual_termination_date,PPS.projected_termination_date)' ;   -- Bug 9728577
    ELSE
      lc_order_by := 'NVL(PPS.actual_termination_date,PPS.projected_termination_date),UPPER(PPF.employee_number)' ;
    END IF;

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
                 AND   TRUNC(NVL(PPS.actual_termination_date,PPS.projected_termination_date)) BETWEEN PPF.effective_start_date
                                                          AND PPF.effective_end_date
                 AND   TRUNC(NVL(PPS.actual_termination_date,PPS.projected_termination_date)) BETWEEN PAF.effective_start_date
                                                          AND PAF.effective_end_date
                 ORDER BY '||lc_order_by;   -- Bug 9728577

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

END PAY_JP_UITE_REPORT_PKG;

/
