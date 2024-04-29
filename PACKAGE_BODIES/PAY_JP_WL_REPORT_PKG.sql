--------------------------------------------------------
--  DDL for Package Body PAY_JP_WL_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_WL_REPORT_PKG" AS
-- $Header: payjpwlreportpkg.pkb 120.0.12010000.23 2009/11/06 12:40:05 rdarasi noship $
-- **************************************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.                         *
-- * All rights reserved                                                                            *
-- **************************************************************************************************
-- *                                                                                                *
-- * PROGRAM NAME                                                                                   *
-- *  PAY_JP_WL_REPORT_PKG.pks                                                                      *
-- *                                                                                                *
-- * DESCRIPTION                                                                                    *
-- * This script creates the package specification of PAY_JP_WL_REPORT_PKG.                         *
-- *                                                                                                *
-- * USAGE                                                                                          *
-- *   To install       sqlplus <apps_user>/<apps_pwd> @PAYJPWLREPORTPKG.pkb                        *
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_WL_REPORT_PKG<procedure name>    *
-- *                                                                                                *
-- * PROGRAM LIST                                                                                   *
-- * ==========                                                                                     *
-- * NAME                 DESCRIPTION                                                               *
-- * -----------------    --------------------------------------------------                        *
-- * CHK_ASS_SET                                                                                    *
-- * GET_AMENDMENT_FLAG                                                                             *
-- * CHK_ASS_SET_MIXED                                                                              *
-- * CHK_ALL_EXCLUSIONS                                                                             *
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
-- * Concurrent Program JP WithHolding Book Report                                                  *
-- *                                                                                                *
-- * LAST UPDATE DATE                                                                               *
-- *   Date the program has been modified for the last time                                         *
-- *                                                                                                *
-- * HISTORY                                                                                        *
-- * =======                                                                                        *
-- *                                                                                                *
-- * VERSION DATE         AUTHOR(S)             DESCRIPTION                                         *
-- * ------- -----------  ----------------      ----------------------------                        *
-- * Draft  09/08/2009    RDARASI               intial                                              *
-- * Draft  20/08/2009    RDARASI               Changed as per Bugs                                 *
-- **************************************************************************************************
--
  g_write_xml             CLOB;
  g_xfdf_string           CLOB;
  gc_eol                  VARCHAR2(5) := fnd_global.local_chr(10);
  gc_proc_name            VARCHAR2(240);
  gc_pkg_name             VARCHAR2(30):= 'PAY_JP_WL_REPORT_PKG.';
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
         ,pay_core_utils.get_parameter('ASS_SETID',legislative_parameters)                                    assignment_set_id
         ,pay_core_utils.get_parameter('REP_GROUP',legislative_parameters)                                    rep_group
         ,pay_core_utils.get_parameter('REP_CAT',legislative_parameters)                                      rep_cat
         ,pay_core_utils.get_parameter('BG',legislative_parameters)                                           business_group_id
         ,NVL(pay_core_utils.get_parameter('IOH',legislative_parameters),'Y')                                 include_org_hierarchy
         ,pay_core_utils.get_parameter('ORG',legislative_parameters)                                          organization_id
         ,TO_DATE(pay_core_utils.get_parameter('EFFDATE',legislative_parameters),'YYYY/MM/DD')                effective_date
         ,pay_core_utils.get_parameter('SUB',legislative_parameters)                                          subject_yyyymm
         ,pay_core_utils.get_parameter('LOC',legislative_parameters)                                          location
         ,pay_core_utils.get_parameter('PAY',legislative_parameters)                                          payroll
         ,pay_core_utils.get_parameter('ITWA',legislative_parameters)                                         income_tax_withholding_agent
         ,pay_core_utils.get_parameter('OTE',legislative_parameters)                                          output_terminated_employees
         ,TO_DATE(pay_core_utils.get_parameter('TEDF',legislative_parameters),'YYYY/MM/DD')                   termination_date_from
         ,TO_DATE(pay_core_utils.get_parameter('TEDT',legislative_parameters),'YYYY/MM/DD')                   termination_date_to
         ,pay_core_utils.get_parameter('S1',legislative_parameters)                                           sort_order_1
         ,pay_core_utils.get_parameter('S2',legislative_parameters)                                           sort_order_2
         ,pay_core_utils.get_parameter('S3',legislative_parameters)                                           sort_order_3
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
-- This has to be taken care. by r Commented By RDARASI
/*    SELECT TO_DATE(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')
    INTO gr_parameters.effective_date
    FROM pay_payroll_actions PPA
    WHERE PPA.payroll_action_id  = gr_parameters.payroll_action_id;*/
    -- ADDED By rdarasi below
    SELECT LAST_DAY(TO_DATE(max(action_information1),'YYYYMM'))
    INTO gr_parameters.effective_date
    FROM pay_action_information
    WHERE action_information_category ='JP_WL_PACT'
    AND  TO_CHAR(TO_DATE(action_information1,'YYYYMM'),'YYYY') = gr_parameters.subject_yyyymm
    AND  action_context_type  = 'PA';
    -- ADDED By rdarasi above
--
    IF gb_debug THEN
      hr_utility.set_location('p_payroll_action_id                         = ' || p_payroll_action_id,30);
      hr_utility.set_location('gr_parameters.payroll_action_id             = ' || gr_parameters.payroll_action_id,30);
      hr_utility.set_location('gr_parameters.assignment_set_id             = ' || gr_parameters.ass_setid,30);
      hr_utility.set_location('gr_parameters.rep_group                     = ' || gr_parameters.rep_group,30);
      hr_utility.set_location('gr_parameters.rep_cat                       = ' || gr_parameters.rep_cat,30);
      hr_utility.set_location('gr_parameters.business_group_id             = ' || gr_parameters.business_group_id,30);
      hr_utility.set_location('gr_parameters.include_org_hierarchy         = ' || gr_parameters.include_org_hierarchy,30);
      hr_utility.set_location('gr_parameters.organization_id               = ' || gr_parameters.organization_id,30);
      hr_utility.set_location('gr_parameters.effective_date                = ' || gr_parameters.effective_date,30);
      hr_utility.set_location('gr_parameters.subject_yyyymm                = ' || gr_parameters.subject_yyyymm,30);
      hr_utility.set_location('gr_parameters.location                      = ' || gr_parameters.location,30);
      hr_utility.set_location('gr_parameters.payroll                       = ' || gr_parameters.payroll,30);
      hr_utility.set_location('gr_parameters.income_tax_withholding_agent  = ' || gr_parameters.income_tax_withholding_agent,30);
      hr_utility.set_location('gr_parameters.output_terminated_employees   = ' || gr_parameters.output_terminated_employees,30);
      hr_utility.set_location('gr_parameters.termination_date_from         = ' || gr_parameters.termination_date_from,30);
      hr_utility.set_location('gr_parameters.termination_date_to           = ' || gr_parameters.termination_date_to,30);
      hr_utility.set_location('gr_parameters.sort_order_1                  = ' || gr_parameters.sort_order_1,30);
      hr_utility.set_location('gr_parameters.sort_order_2                  = ' || gr_parameters.sort_order_2,30);
      hr_utility.set_location('gr_parameters.sort_order_3                  = ' || gr_parameters.sort_order_3,30);
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
    lc_buf      VARCHAR2(2000);
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
    ln_pact_id   := fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ACTION_ID',lc_legislative_parameters));

    hr_utility.set_location ('ln_cur_assact.. '||ln_cur_assact,20);
    hr_utility.set_location ('ln_cur_pact... '||ln_cur_pact,20);
    hr_utility.set_location ('ln_pact_id ..'||ln_pact_id,20);
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
    hr_utility.trace ('Phase of err');
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
                     , p_organization_id         per_assignments_f.organization_id%TYPE
                     , p_location_id             per_assignments_f.location_id%TYPE
                     , p_payroll_id              per_assignments_f.payroll_id%TYPE                  -- added by rdarasi
                     , p_with_hold_id            hr_all_organization_units_vl.organization_id%TYPE  -- added by rdarasi
                    -- , p_assignment_set_id       hr_assignment_sets.assignment_set_id%TYPE          -- REMOVED BY MAHESH
                     , p_effective_date          DATE
                     , p_termination_date_from   DATE
                     , p_termination_date_to     DATE
                     , p_include_term_flag       VARCHAR2
                     )
  IS
  SELECT DISTINCT PJWREV.assignment_id
        ,PJWREV.effective_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,pay_jp_wl_employee_details_v PJWREV
        ,per_periods_of_service   PPOF
        ,pay_population_ranges    PPR
        ,pay_payroll_actions      PPA
        ,hr_all_organization_units  HAOU     -- added by r
  WHERE PAA.person_id                        = PAP.person_id
  AND   PPA.payroll_action_id                = PPR.payroll_action_id
  AND   PPA.payroll_action_id                = p_payroll_action_id
  AND   PPR.chunk_number                     = p_chunk
  AND   PPR.person_id                        = PAP.person_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   HAOU.organization_id                 = PAA.organization_id   -- added by r
  AND   PAS.payroll_action_id                = p_payroll_action_id_arch
  AND   PPOF.person_id                       = PAP.person_id
  AND   PJWREV.assignment_action_id          = PAS.assignment_action_id
  AND   PJWREV.assignment_id                 = PAS.assignment_id
  AND   PAA.business_group_id                = p_business_group_id
  AND   PAA.organization_id                  = NVL(p_organization_id,PAA.organization_id)
--  AND   PAA.organization_id                  = NVL(p_with_hold_id,PAA.organization_id)  -- added by RDARASI
  AND   NVL(PAA.location_id,0)               = NVL(p_location_id,NVL( PAA.location_id,0))
  AND   NVL(PAA.payroll_id,0)                = NVL(p_payroll_id,NVL( PAA.payroll_id,0))   -- Changed by MAHESH
  -- AND   PAA.primary_flag                     = 'Y'  -- REMOVED BY MAHESH
  AND   NVL(pay_jp_wl_arch_pkg.get_with_hold_agent(PAA.assignment_id,p_effective_date),-999) = NVL(p_with_hold_id,NVL(pay_jp_wl_arch_pkg.get_with_hold_agent(PAA.assignment_id,p_effective_date),-999)) -- ADDED BY MAHESH
  AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAP.effective_start_date
                                                              AND PAP.effective_end_date
  AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAA.effective_start_date
                                                              AND PAA.effective_end_date
  AND   ((   NVL(p_include_term_flag,'N')       = 'Y'
             AND((NVL(PJWREV.termination_date,p_effective_date) <= p_effective_date
                 AND((PPOF.actual_termination_date IS NULL
                     AND p_effective_date > PPOF.DATE_START
                     )
                     OR NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) <= p_effective_date
                   )
                   AND  NVL(TRUNC(PPOF.actual_termination_date),p_termination_date_from)  BETWEEN p_termination_date_from
                                                                                          AND     p_termination_date_to
                   )
                 OR ( NVL(PJWREV.termination_date,p_effective_date) >= p_effective_date
                     AND NVL(TRUNC(PPOF.actual_termination_date),p_termination_date_from)  BETWEEN p_termination_date_from
                                                                                           AND p_termination_date_to)
             )
         )
        OR
         (  NVL(p_include_term_flag,'N')        = 'N'
            AND NVL(PJWREV.termination_date,p_effective_date) >= p_effective_date
             AND ((PPOF.actual_termination_date IS NULL
                   AND p_effective_date > PPOF.DATE_START)
                 OR NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) >= p_effective_date)
         )
        );
  --
  CURSOR lcu_assact( p_payroll_action_id_arch   pay_payroll_actions.payroll_action_id%TYPE
                   , p_business_group_id        per_assignments_f.business_group_id%TYPE
                   , p_organization_id          per_assignments_f.organization_id%TYPE
                   , p_location_id              per_assignments_f.location_id%TYPE
                   , p_payroll_id               per_assignments_f.payroll_id%TYPE                  -- added by rdarasi
                   , p_with_hold_id             hr_all_organization_units_vl.organization_id%TYPE  -- added by rdarasi
                --   , p_assignment_set_id        hr_assignment_sets.assignment_set_id%TYPE          -- REMOVED BY MAHESH
                   , p_effective_date           DATE
                   , p_termination_date_from    DATE
                   , p_termination_date_to      DATE
                   , p_include_term_flag        VARCHAR2
                   )
  IS
  SELECT DISTINCT PJWREV.assignment_id
        ,PJWREV.effective_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,pay_jp_wl_employee_details_v PJWREV
        ,per_periods_of_service   PPOF
        ,hr_all_organization_units  HAOU
  WHERE PAA.person_id                        = PAP.person_id
  AND   PAA.person_id                  BETWEEN p_start_person_id
                                         AND p_end_person_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   PAS.payroll_action_id                = p_payroll_action_id_arch
  AND   PPOF.person_id                       = PAP.person_id
  AND   PJWREV.assignment_action_id          = PAS.assignment_action_id
  AND   PJWREV.assignment_id                 = PAS.assignment_id
  AND   HAOU.organization_id                 = PAA.organization_id
  AND   PAA.business_group_id                = p_business_group_id
  AND   PAA.organization_id                  = NVL(p_organization_id,PAA.organization_id)
--  AND   PAA.organization_id                  = NVL(p_with_hold_id,PAA.organization_id)  -- added by RDARASI
  AND   NVL(PAA.location_id,0)               = NVL(p_location_id,NVL( PAA.location_id,0))
  AND   NVL(PAA.payroll_id,0)                = NVL(p_payroll_id,NVL( PAA.payroll_id,0))     -- CHANGED BY MAHESH
  -- AND   PAA.primary_flag                     = 'Y'   -- REMOVED BY MAHESH
  AND   NVL(pay_jp_wl_arch_pkg.get_with_hold_agent(PAA.assignment_id,p_effective_date),-999) = NVL(p_with_hold_id,NVL(pay_jp_wl_arch_pkg.get_with_hold_agent(PAA.assignment_id,p_effective_date),-999)) -- ADDED BY MAHESH
  AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAP.effective_start_date
                                                              AND PAP.effective_end_date
  AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAA.effective_start_date
                                                              AND PAA.effective_end_date
  AND   ((   NVL(p_include_term_flag,'N')       = 'Y'
             AND((NVL(PJWREV.termination_date,p_effective_date) <= p_effective_date
                 AND((PPOF.actual_termination_date IS NULL
                     AND p_effective_date > PPOF.DATE_START
                     )
                     OR NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) <= p_effective_date
                   )
                   AND  NVL(TRUNC(PPOF.actual_termination_date),p_termination_date_from)  BETWEEN p_termination_date_from
                                                                                          AND     p_termination_date_to
                   )
                 OR ( NVL(PJWREV.termination_date,p_effective_date) >= p_effective_date
                     AND NVL(TRUNC(PPOF.actual_termination_date),p_termination_date_from)  BETWEEN p_termination_date_from
                                                                                           AND p_termination_date_to)
             )
         )
        OR
         (  NVL(p_include_term_flag,'N')        = 'N'
            AND NVL(PJWREV.termination_date,p_effective_date) >= p_effective_date
             AND ((PPOF.actual_termination_date IS NULL
                   AND p_effective_date > PPOF.DATE_START)
                 OR NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) >= p_effective_date)
         )
        );
  --
  ln_assact                 pay_assignment_actions.assignment_action_id%TYPE ;
  lc_proc_name              VARCHAR2(60);
  lc_legislative_parameters VARCHAR2(2000);
  lc_result1                VARCHAR2(30);
  ln_old_pact_id            NUMBER;
  ln_cur_pact               NUMBER;
  ln_ass_set_id             NUMBER;
  ln_formula_id             NUMBER;
  lb_result2                BOOLEAN;
  lc_include_flag           VARCHAR2(1);
  lt_org_id                 per_jp_report_common_pkg.gt_org_tbl;
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
    ln_old_pact_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ACTION_ID',lc_legislative_parameters));
    ln_ass_set_id  := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASS_SETID',lc_legislative_parameters));
--
    g_mag_payroll_action_id:=p_payroll_action_id;
    gb_debug :=hr_utility.debug_enabled ;
--

    IF gb_debug  THEN
      lc_proc_name := gc_pkg_name ||'ACTION_CREATION';
      hr_utility.trace ('Entering '||lc_proc_name);
      hr_utility.trace ('Parameters ....');
      hr_utility.trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);
      hr_utility.trace ('P_START_PERSON_ID = '|| p_start_person_id);
      hr_utility.trace ('P_END_PERSON_ID = '|| p_end_person_id);
      hr_utility.trace ('P_CHUNK = '|| p_chunk);
    END IF;
--
    initialize(g_mag_payroll_action_id);
--
     IF gr_parameters.organization_id IS NOT NULL THEN
      -- Getting Organization ID's as per hierarchy
       IF gr_parameters.include_org_hierarchy = 'Y' THEN -- Added if on 08/09/09
         lt_org_id := per_jp_report_common_pkg.get_org_hirerachy( p_business_group_id     => gr_parameters.business_group_id
                                                                ,p_organization_id       => gr_parameters.organization_id
                                                                ,p_include_org_hierarchy => gr_parameters.include_org_hierarchy
                                                                );
       ELSE                                              -- Added below on 08/09/09
         lt_org_id(1) := gr_parameters.organization_id;
       END IF;
       -- Added above on 08/09/09

       FOR i in 1..lt_org_id.COUNT
         LOOP
--
           IF range_person_on THEN
--                                 Range person is enabled
             IF gb_debug THEN
               hr_utility.set_location('Inside Range person if condition',20);
             END IF;
--                                Assignment Action for Current and Terminated Employees
             FOR lr_assact IN lcu_assact_r( ln_old_pact_id
                                          , gr_parameters.business_group_id
                                          , lt_org_id(i)
                                          , gr_parameters.location
                                          , gr_parameters.payroll                                    --Added by RDARASI
                                          , gr_parameters.income_tax_withholding_agent               --Added by RDARASI
                                     --     , gr_parameters.assignment_set_id                          --REMOVED BY MAHESH
                                          , gr_parameters.effective_date
                                          , gr_parameters.termination_date_from
                                          , gr_parameters.termination_date_to
                                          , gr_parameters.output_terminated_employees
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
                 lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id =>ln_ass_set_id
                                                                                 ,p_assignment_id     => lr_assact.assignment_id
                                                                                 ,p_effective_date    => gr_parameters.effective_date
                                                                                  );
                 IF lc_include_flag = 'Y' THEN
--
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
             END LOOP;-- End loop for assignment details cursor
           ELSE
                         -- Range person is not enabled
             IF gb_debug THEN
               hr_utility.set_location('Range person returns false',20);
               hr_utility.set_location(ln_old_pact_id,20);
               hr_utility.set_location(lt_org_id(i),20);
             END IF;
             --        Assignment Action for Current and Terminated Employe
             FOR lr_assact IN lcu_assact ( ln_old_pact_id
                                         , gr_parameters.business_group_id
                                         , lt_org_id(i)
                                         , gr_parameters.location
                                         , gr_parameters.payroll                               --Added by RDARASI
                                         , gr_parameters.income_tax_withholding_agent          --Added by RDARASI
                                    --     , gr_parameters.assignment_set_id                     --REMOVED BY MAHESH
                                         , gr_parameters.effective_date
                                         , gr_parameters.termination_date_from
                                         , gr_parameters.termination_date_to
                                         , gr_parameters.output_terminated_employees
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
                 hr_nonrun_asact.insact(ln_assact
                                        ,lr_assact.assignment_id
                                        ,p_payroll_action_id
                                        ,p_chunk
                                        ,NULL
                                        );
               ELSE
                -- assignment set is pa ssed as parameter
                 lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id =>ln_ass_set_id
                                                                                  ,p_assignment_id     => lr_assact.assignment_id
                                                                                  ,p_effective_date    => gr_parameters.effective_date
                                                                                  );
                 IF lc_include_flag = 'Y' THEN
--
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
             END LOOP;-- End loop for assignment details cursor
           END IF; -- End If for range_person_on
         END LOOP;--End Loop for Organization
        --
      ELSE --Org id is null
        IF range_person_on THEN
        -- Assignment Action for Current and Terminated Employees
          IF gb_debug THEN
            hr_utility.set_location('Inside Range person if condition',20);
            hr_utility.set_location('ln_old_pact_id...'||ln_old_pact_id,20);
            hr_utility.set_location('gr_parameters.business_group_id...'||gr_parameters.business_group_id,20);
            hr_utility.set_location('gr_parameters.location...'||gr_parameters.location,20);
            hr_utility.set_location('gr_parameters.effective_date...'||gr_parameters.effective_date,20);
            hr_utility.set_location('gr_parameters.termination_date_from...'||gr_parameters.termination_date_from,20);
            hr_utility.set_location('gr_parameters.termination_date_to...'||gr_parameters.termination_date_to,20);
            hr_utility.set_location('gr_parameters.output_terminated_employees...'||gr_parameters.output_terminated_employees,20);
          END IF;
--        Assignment Action for Current and Terminated Employees
--
        FOR lr_assact IN lcu_assact_r( ln_old_pact_id
                                     , gr_parameters.business_group_id
                                     , null
                                     , gr_parameters.location
                                     , gr_parameters.payroll                              --Added by RDARASI
                                     , gr_parameters.income_tax_withholding_agent         --Added by RDARASI
                              --     , gr_parameters.assignment_set_id                    --REMOVED BY MAHESH
                                     , gr_parameters.effective_date
                                     , gr_parameters.termination_date_from
                                     , gr_parameters.termination_date_to
                                     , gr_parameters.output_terminated_employees
                                     )
        LOOP
             -- Added NVL to overcome NULL issue.
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
            lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate (p_assignment_set_id => ln_ass_set_id
                                                                             ,p_assignment_id     => lr_assact.assignment_id
                                                                             ,p_effective_date    => gr_parameters.effective_date
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
--
      ELSE
        IF gb_debug THEN
          hr_utility.set_location('Range person returns false',20);
        END IF;
        --        Assignment Action for Current and Terminated Employe
--
          FOR lr_assact IN lcu_assact( ln_old_pact_id
                                     , gr_parameters.business_group_id
                                     , null
                                     , gr_parameters.location
                                     , gr_parameters.payroll                               --Added by RDARASI
                                     , gr_parameters.income_tax_withholding_agent          --Added by RDARASI
                              --     , gr_parameters.assignment_set_id                     --REMOVED BY MAHESH
                                     , gr_parameters.effective_date
                                     , gr_parameters.termination_date_from
                                     , gr_parameters.termination_date_to
                                     , gr_parameters.output_terminated_employees
                                     )
          LOOP
           -- Added NVL to overcome NULL issue.
            IF (NVL(ln_ass_set_id ,0) = 0) THEN
              -- NO assignment set passed as parameter
              hr_utility.trace ('ass_id = '||lr_assact.assignment_id);
--
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
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id =>ln_ass_set_id
                                                                               ,p_assignment_id     => lr_assact.assignment_id
                                                                               ,p_effective_date    => gr_parameters.effective_date
                                                                               );
              IF lc_include_flag = 'Y' THEN
--
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
          END LOOP;-- End loop for assignment details cursor
--
        END IF; -- End If for range_person_on
      END IF;
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
      hr_utility.trace ('inside ARCHIVE_CODE ');
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

  CURSOR cur_wl_emp(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJWREV.ORGANIZATION_ID
       , PJWREV.PAYROLL_ID
       , PJWREV.WITHHOLDING_AGENT_ID
       , PJWREV.LOCATION_ID
       , PJWREV.PERSON_ID
       , PJWREV.FULL_NAME_KANA
       , PJWREV.FULL_NAME_KANJI
       , PJWREV.PAYROLL_NAME
       , PJWREV.AGE
       , PJWREV.HEALTH_INSURANCE_NUMBER
       , PJWREV.WELFARE_PENSION_INS_NUMBER
       , SUBSTR(PJWREV.BASIC_PENSION_NUMBER,1,4)||NVL2(PJWREV.BASIC_PENSION_NUMBER,'-',' ')|| SUBSTR(PJWREV.BASIC_PENSION_NUMBER,5)   BASIC_PENSION_NUMBER   --Changed by RDARASI
       , SUBSTR(PJWREV.UNEMPLOYMENT_INSURANCE_NUMBER,1,4)||NVL2(PJWREV.UNEMPLOYMENT_INSURANCE_NUMBER,'-',' ')
       || SUBSTR(PJWREV.UNEMPLOYMENT_INSURANCE_NUMBER,5,6)||NVL2(PJWREV.UNEMPLOYMENT_INSURANCE_NUMBER,'-',' ')
       || SUBSTR(PJWREV.UNEMPLOYMENT_INSURANCE_NUMBER,11)  UNEMPLOYMENT_INSURANCE_NUMBER --Changed by RDARASI
       , TO_CHAR(PJWREV.HIRE_DATE, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')         HIRE_DATE
       , PJWREV.YEARS_OF_SERVICE
       , PJWREV.TAX_CLASS
       , TO_CHAR(PJWREV.TERMINATION_DATE, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')  TERMINATION_DATE
       , PJWREV.TERMINATION_DATE   TERM_DATE -- added on 07/09/09
       , PJWREV.ORGANIZATION_NAME
       , PJWREV.GENDER
       , PJWREV.JOB_NAME
       , SUBSTR(PJWREV.POSTAL_CODE,1,3)||NVL2(PJWREV.POSTAL_CODE,'-',' ')|| SUBSTR(PJWREV.POSTAL_CODE,4)   POSTAL_CODE  --Changed by RDARASI
       , PJWREV.ADDRESS_LINE1
       , PJWREV.ADDRESS_LINE2
       , PJWREV.ADDRESS_LINE3
       , TO_CHAR(PJWREV.DATE_OF_BIRTH, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')     DATE_OF_BIRTH
       , PJWREV.EMPLOYEE_NUMBER
       , PJWREV.PHONE
       , PJWREV.ADDRESS_LINE1_KANA
       , PJWREV.ADDRESS_LINE2_KANA
       , PJWREV.ADDRESS_LINE3_KANA
  FROM   pay_jp_wl_employee_details_v PJWREV
  WHERE  PJWREV.assignment_action_id = p_mag_asg_action_id;

  CURSOR cur_wl_mnt_sal_info(p_mag_asg_action_id  NUMBER
                            ,p_month              NUMBER)
  IS
  SELECT PJWMPIV.PERSON_ID
       , PJWMPIV.PAYMENT_DATE
       , PJWMPIV.TOTAL_PAYMENT_AMOUNT
       , PJWMPIV.NON_TAXABLE_PAYMENT_AMOUNT
       , PJWMPIV.TOTAL_EARNINGS_PER_MONTH
       , PJWMPIV.SI_DEDUCTION_AMOUNTAMOUNT_SI
       , PJWMPIV.HI_DEDUCTION_AMOUNT
       , PJWMPIV.WP_DEDUCTION_AMOUNT
       , PJWMPIV.WPFI_DEDUCTION_AMOUNT
       , PJWMPIV.UI_DEDUCTION_AMOUNT
       , PJWMPIV.TOTAL_SI_AMOUNT
       , PJWMPIV.TOTAL_PAY_AMOUNT_AFTER_SI
       , PJWMPIV.NO_OF_DEPENDENTS
       , PJWMPIV.TAX_RATE
       , PJWMPIV.COMPUTED_TAX_AMOUNT
       , PJWMPIV.CI_AMOUNT
       , PJWMPIV.LOCAL_TAX_AMOUNT
       , PJWMPIV.OVER_AND_SHORT_AMOUNT
       , PJWMPIV.COLLECTED_TAX_AMOUNT
       , PJWMPIV.TOTAL_DEDUCTION_AMOUNT  -- added on 14/09/09
       , PJWMPIV.NET_BALANCE_AMOUNT      -- added on 14/09/09
  FROM   pay_jp_wl_mnth_pay_info_v   PJWMPIV
  WHERE  PJWMPIV.assignment_action_id = p_mag_asg_action_id
  AND    TO_CHAR(PJWMPIV.PAYMENT_DATE,'MM') = p_month;

  CURSOR cur_wl_sal_earn(p_mag_asg_action_id  NUMBER
                        ,p_item_rep_seq       NUMBER)
  IS
  SELECT PJWSEV.TYPE
       , PJWSEV.ITEM_ID
       , PJWSEV.ITEM_TYPE
       , PJWSEV.ITEM_REP_NAME
       , PJWSEV.ITEM_REP_SEQ
       , PJWSEV.MONTH1_AMOUNT
       , PJWSEV.MONTH2_AMOUNT
       , PJWSEV.MONTH3_AMOUNT
       , PJWSEV.MONTH4_AMOUNT
       , PJWSEV.MONTH5_AMOUNT
       , PJWSEV.MONTH6_AMOUNT
       , PJWSEV.MONTH7_AMOUNT
       , PJWSEV.MONTH8_AMOUNT
       , PJWSEV.MONTH9_AMOUNT
       , PJWSEV.MONTH10_AMOUNT
       , PJWSEV.MONTH11_AMOUNT
       , PJWSEV.MONTH12_AMOUNT
       , PJWSEV.TOTAL_AMOUNT
  FROM   pay_jp_wl_sal_earn_v   PJWSEV
  WHERE  PJWSEV.assignment_action_id = p_mag_asg_action_id
  AND    PJWSEV.item_rep_seq         = p_item_rep_seq;


  CURSOR cur_wl_sal_dct(p_mag_asg_action_id  NUMBER
                       ,p_item_rep_seq       NUMBER)
  IS
  SELECT PJWSDV.TYPE
       , PJWSDV.ITEM_ID
       , PJWSDV.ITEM_TYPE
       , PJWSDV.ITEM_REP_NAME
       , PJWSDV.ITEM_REP_SEQ
       , PJWSDV.MONTH1_AMOUNT
       , PJWSDV.MONTH2_AMOUNT
       , PJWSDV.MONTH3_AMOUNT
       , PJWSDV.MONTH4_AMOUNT
       , PJWSDV.MONTH5_AMOUNT
       , PJWSDV.MONTH6_AMOUNT
       , PJWSDV.MONTH7_AMOUNT
       , PJWSDV.MONTH8_AMOUNT
       , PJWSDV.MONTH9_AMOUNT
       , PJWSDV.MONTH10_AMOUNT
       , PJWSDV.MONTH11_AMOUNT
       , PJWSDV.MONTH12_AMOUNT
       , PJWSDV.TOTAL_AMOUNT
  FROM   pay_jp_wl_sal_dct_v   PJWSDV
  WHERE  PJWSDV.assignment_action_id = p_mag_asg_action_id
  AND    PJWSDV.item_rep_seq         = p_item_rep_seq;
/*
  CURSOR cur_wl_bon_earn(p_mag_asg_action_id  NUMBER
                        ,p_item_rep_seq       NUMBER)
  IS
  SELECT PJWBEV.BON_TYPE
       , PJWBEV.TYPE
       , PJWBEV.ITEM_ID
       , PJWBEV.ITEM_TYPE
       , PJWBEV.ITEM_REP_NAME
       , PJWBEV.ITEM_REP_SEQ
       , PJWBEV.MONTH1_AMOUNT
       , PJWBEV.MONTH2_AMOUNT
       , PJWBEV.MONTH3_AMOUNT
       , PJWBEV.MONTH4_AMOUNT
       , PJWBEV.MONTH5_AMOUNT
       , PJWBEV.MONTH6_AMOUNT
       , PJWBEV.MONTH7_AMOUNT
       , PJWBEV.MONTH8_AMOUNT
       , PJWBEV.MONTH9_AMOUNT
       , PJWBEV.MONTH10_AMOUNT
       , PJWBEV.MONTH11_AMOUNT
       , PJWBEV.MONTH12_AMOUNT
       , PJWBEV.TOTAL_AMOUNT
  FROM   pay_jp_wl_bon_earn_v   PJWBEV
  WHERE  PJWBEV.assignment_action_id = p_mag_asg_action_id
  AND    PJWBEV.item_rep_seq         = p_item_rep_seq;

  CURSOR cur_wl_bon_dct(p_mag_asg_action_id  NUMBER
                       ,p_item_rep_seq       NUMBER)
  IS
  SELECT PJWBDV.BON_TYPE
       , PJWBDV.TYPE
       , PJWBDV.ITEM_ID
       , PJWBDV.ITEM_TYPE
       , PJWBDV.ITEM_REP_NAME
       , PJWBDV.ITEM_REP_SEQ
       , PJWBDV.MONTH1_AMOUNT
       , PJWBDV.MONTH2_AMOUNT
       , PJWBDV.MONTH3_AMOUNT
       , PJWBDV.MONTH4_AMOUNT
       , PJWBDV.MONTH5_AMOUNT
       , PJWBDV.MONTH6_AMOUNT
       , PJWBDV.MONTH7_AMOUNT
       , PJWBDV.MONTH8_AMOUNT
       , PJWBDV.MONTH9_AMOUNT
       , PJWBDV.MONTH10_AMOUNT
       , PJWBDV.MONTH11_AMOUNT
       , PJWBDV.MONTH12_AMOUNT
       , PJWBDV.TOTAL_AMOUNT
  FROM   pay_jp_wl_bon_dct_v   PJWBDV
  WHERE  PJWBDV.assignment_action_id = p_mag_asg_action_id
  AND    PJWBDV.item_rep_seq         = p_item_rep_seq;
*/

  CURSOR cur_wl_bon_earn_dec(p_mag_asg_action_id  NUMBER
                            ,p_item_rep_seq       NUMBER
                            ,p_date               VARCHAR2
                            ,p_element_set        VARCHAR2)
  IS
  SELECT DECODE(p_date,'01', PJWBEV.MONTH1_AMOUNT
                      ,'02', PJWBEV.MONTH2_AMOUNT
                      ,'03', PJWBEV.MONTH3_AMOUNT
                      ,'04', PJWBEV.MONTH4_AMOUNT
                      ,'05', PJWBEV.MONTH5_AMOUNT
                      ,'06', PJWBEV.MONTH6_AMOUNT
                      ,'07', PJWBEV.MONTH7_AMOUNT
                      ,'08', PJWBEV.MONTH8_AMOUNT
                      ,'09', PJWBEV.MONTH9_AMOUNT
                      ,'10', PJWBEV.MONTH10_AMOUNT
                      ,'11', PJWBEV.MONTH11_AMOUNT
                      ,'12', PJWBEV.MONTH12_AMOUNT) value1
        , PJWBEV.ITEM_REP_NAME                               -- added on 07/09/09
  FROM   pay_jp_wl_bon_earn_v   PJWBEV
  WHERE  PJWBEV.assignment_action_id = p_mag_asg_action_id
  AND    PJWBEV.item_rep_seq         = p_item_rep_seq
  AND    PJWBEV.element_set          = p_element_set;

  CURSOR cur_wl_bon_dct_dec(p_mag_asg_action_id  NUMBER
                           ,p_item_rep_seq       NUMBER
                           ,p_date               VARCHAR2
                           ,p_element_set        VARCHAR2)
  IS
  SELECT DECODE(p_date,'01', PJWBDV.MONTH1_AMOUNT
                      ,'02', PJWBDV.MONTH2_AMOUNT
                      ,'03', PJWBDV.MONTH3_AMOUNT
                      ,'04', PJWBDV.MONTH4_AMOUNT
                      ,'05', PJWBDV.MONTH5_AMOUNT
                      ,'06', PJWBDV.MONTH6_AMOUNT
                      ,'07', PJWBDV.MONTH7_AMOUNT
                      ,'08', PJWBDV.MONTH8_AMOUNT
                      ,'09', PJWBDV.MONTH9_AMOUNT
                      ,'10', PJWBDV.MONTH10_AMOUNT
                      ,'11', PJWBDV.MONTH11_AMOUNT
                      ,'12', PJWBDV.MONTH12_AMOUNT) value1
        , PJWBDV.ITEM_REP_NAME                              -- added on 07/09/09
  FROM   pay_jp_wl_bon_dct_v   PJWBDV
  WHERE  PJWBDV.assignment_action_id = p_mag_asg_action_id
  AND    PJWBDV.item_rep_seq         = p_item_rep_seq
  AND    PJWBDV.element_set          = p_element_set;

  CURSOR cur_wl_wrk_hours_days(p_mag_asg_action_id  NUMBER
                              ,p_item_rep_seq       NUMBER)
  IS
  SELECT PJWWHD.TYPE
       , PJWWHD.ITEM_ID
       , PJWWHD.ITEM_TYPE
       , PJWWHD.ITEM_REP_NAME
       , PJWWHD.ITEM_REP_SEQ
       , PJWWHD.INFORMATION1
       , PJWWHD.INFORMATION2
       , PJWWHD.INFORMATION3
       , PJWWHD.INFORMATION4
       , PJWWHD.INFORMATION5
       , PJWWHD.INFORMATION6
       , PJWWHD.INFORMATION7
       , PJWWHD.INFORMATION8
       , PJWWHD.INFORMATION9
       , PJWWHD.INFORMATION10
       , PJWWHD.INFORMATION11
       , PJWWHD.INFORMATION12
       , PJWWHD.TOTAL
  FROM   pay_jp_wl_wrk_hours_days_v   PJWWHD
  WHERE  PJWWHD.assignment_action_id = p_mag_asg_action_id
  AND    PJWWHD.item_rep_seq         = p_item_rep_seq;

  CURSOR cur_wl_bon_pay_info(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJWBPIV.PERSON_ID
       , PJWBPIV.BONUS_PAYMENT_DATE
       , PJWBPIV.TOTAL_PAYMENT_AMOUNT
       , PJWBPIV.NON_TAXABLE_PAYMENT_AMOUNT
       , PJWBPIV.TOTAL_EARNINGS_PER_MONTH
       , PJWBPIV.SI_DEDUCTION_AMOUNT
       , PJWBPIV.HI_DEDUCTION_AMOUNT
       , PJWBPIV.WP_DEDUCTION_AMOUNT
       , PJWBPIV.WPFI_DEDUCTION_AMOUNT
       , PJWBPIV.UI_DEDUCTION_AMOUNT
       , PJWBPIV.TOTAL_SI_AMOUNT
       , PJWBPIV.TOTAL_PAY_AMOUNT_AFTER_SI
       , PJWBPIV.NO_OF_DEPENDENTS
       , PJWBPIV.TAX_RATE
       , PJWBPIV.COMPUTED_TAX_AMOUNT
       , PJWBPIV.OVER_AND_SHORT_AMOUNT
       , PJWBPIV.COLLECTED_TAX_AMOUNT
       , PJWBPIV.CI_AMOUNT
       , PJWBPIV.LOCAL_TAX_AMOUNT
       , PJWBPIV.TOTAL_DEDUCTION_AMOUNT  -- added on 14/09/09
       , PJWBPIV.NET_BALANCE_AMOUNT      -- added on 14/09/09
       , PJWBPIV.element_set
  FROM   pay_jp_wl_bon_pay_info_v   PJWBPIV
  WHERE  PJWBPIV.assignment_action_id = p_mag_asg_action_id
  ORDER BY PJWBPIV.BONUS_PAYMENT_DATE;-- added on 07/09/09

  CURSOR cur_wl_dec_dep_info(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJWDDIV.PERSON_ID
       , PJWDDIV.EXISTENCE_OF_DECLARATION
       , PJWDDIV.EXISTENCE_OF_SPOUSE
       , PJWDDIV.GENERALLY_QUALIFIED_SPOUSE
       , PJWDDIV.ELDERLY_QUALIFIED_SPOUSE
       , PJWDDIV.GENERAL_DEPENDENTS
       , PJWDDIV.SPECIFIC_DEPENDENTS
       , PJWDDIV.ELDER_DEPENDENTS_LIV_TOGETHER
       , PJWDDIV.ELDER_DEPENDENTS_OTHERS
       , PJWDDIV.GENERAL_DISABLED
       , PJWDDIV.SPECIAL_DISABLED
       , PJWDDIV.SPECIAL_DISABLED_LIV_TOGETHER
       , PJWDDIV.AGED
       , PJWDDIV.WIDOW
       , PJWDDIV.WORKING_STUDENT
       , PJWDDIV.DEPENDENT_INFO_SEC_SOURCE
  FROM   pay_jp_wl_dec_dep_info_v   PJWDDIV
  WHERE  PJWDDIV.assignment_action_id = p_mag_asg_action_id;

  CURSOR cur_wl_pre_emp(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJWPJD.PERSON_ID
       , PJWPJD.PREVIOUS_COMPANY
       , PJWPJD.EMPLOYER_ADDRESS_KANA
       , PJWPJD.TAXABLE_INCOME
       , PJWPJD.SOCIAL_INSURANCE_PREMIUM
       , PJWPJD.MUTUAL_AID_PREM
       , PJWPJD.WITHHOLDING_TAX
       , TO_CHAR(PJWPJD.RETIREMENT_DATE, 'EYY.MM.DD', 'NLS_CALENDAR=''Japanese Imperial''')  RETIREMENT_DATE
  FROM  pay_jp_wl_prev_job_details_v  PJWPJD
  WHERE PJWPJD.assignment_action_id = p_mag_asg_action_id;

-- added below on 18/09/09

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
  AND    HOI.org_information1        = 'JPWAGELEDGERREPORT'
  AND    HOI.organization_id         =  p_business_group_id
  AND    HOI.org_information3        =  p_info_type
  AND    p_effective_date      BETWEEN  NVL(FND_DATE.canonical_to_date(HOI.org_information5),p_effective_date)  -- changed by rdarasi on 29/09/09
                                   AND  NVL(FND_DATE.canonical_to_date(HOI.org_information6),p_effective_date); -- changed by rdarasi on 29/09/09
-- added above on 18/09/09

  CURSOR cur_wl_extra_info(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJWEIV.ADDITIONAL_INFORMATION1
       , PJWEIV.ADDITIONAL_INFORMATION2
       , PJWEIV.ADDITIONAL_INFORMATION3
       , PJWEIV.ADDITIONAL_INFORMATION4
       , PJWEIV.ADDITIONAL_INFORMATION5
       , PJWEIV.ADDITIONAL_INFORMATION6
       , PJWEIV.ADDITIONAL_INFORMATION7
       , PJWEIV.ADDITIONAL_INFORMATION8
       , PJWEIV.ADDITIONAL_INFORMATION9
       , PJWEIV.ADDITIONAL_INFORMATION10
       , PJWEIV.ADDITIONAL_INFORMATION11
       , PJWEIV.ADDITIONAL_INFORMATION12
       , PJWEIV.ADDITIONAL_INFORMATION13
       , PJWEIV.ADDITIONAL_INFORMATION14
       , PJWEIV.ADDITIONAL_INFORMATION15
       , PJWEIV.ADDITIONAL_INFORMATION16
       , PJWEIV.ADDITIONAL_INFORMATION17
       , PJWEIV.ADDITIONAL_INFORMATION18
       , PJWEIV.ADDITIONAL_INFORMATION19
       , PJWEIV.ADDITIONAL_INFORMATION20
       , PJWEIV.ADDITIONAL_INFORMATION21
       , PJWEIV.ADDITIONAL_INFORMATION22
       , PJWEIV.ADDITIONAL_INFORMATION23
       , PJWEIV.ADDITIONAL_INFORMATION24
       , PJWEIV.ADDITIONAL_INFORMATION25
       , PJWEIV.ADDITIONAL_INFORMATION26
       , PJWEIV.ADDITIONAL_INFORMATION27
       , PJWEIV.ADDITIONAL_INFORMATION28
       , PJWEIV.ADDITIONAL_INFORMATION29
       , PJWEIV.ADDITIONAL_INFORMATION30
  FROM   pay_jp_wl_extra_info_v    PJWEIV
  WHERE  PJWEIV.assignment_action_id = p_mag_asg_action_id;

--added per by r
  CURSOR cur_wl_yea_info(p_mag_asg_action_id  NUMBER)
  IS
  SELECT PJWYIV.PERSON_ID
       , PJWYIV.SAL_AMT
       , PJWYIV.BON_AMT
       , PJWYIV.TAXABLE_INCOME
       , PJWYIV.SAL_TAX
       , PJWYIV.BON_TAX
       , PJWYIV.NET_INCOME
       , PJWYIV.SI_DEDUCTION
       , PJWYIV.SI_PREM
       , PJWYIV.DEP_EXEMPTION
       , PJWYIV.LI_PREM
       , PJWYIV.EI_PREM
       , PJWYIV.SPOUSE_SP_EXEMPT
       , PJWYIV.SPOUSE_INCOME
       , PJWYIV.PP_PREM
       , PJWYIV.LONG_TERM_AI_PREM
       , PJWYIV.MUTUAL_AID_PREM
       , PJWYIV.NPI_PREMIUM
       , PJWYIV.HOUSING_LOAN_DEDUCTION
       , PJWYIV.YEA_ANNUAL_TAX
       , PJWYIV.OVER_AND_SHORT_TAX
       , PJWYIV.DEP_SPOUSE_EXEMPTION
       , PJWYIV.DEPENDENT_EXEMPTION
       , PJWYIV.BASIS_EXEMPTION
       , PJWYIV.DEP_DISABLED_EXEMPTION
       , PJWYIV.TOTAL_SE_DE_BE_DISE
       , PJWYIV.TOTAL_INCOME_DEDUCTION
       , PJWYIV.NET_ASS_SAL_INCOME_MONEY
       , PJWYIV.CALCULATED_TAX
  FROM   pay_jp_wl_yea_info_v    PJWYIV
  WHERE  PJWYIV.assignment_action_id = p_mag_asg_action_id;
  --
  lr_wl_emp               cur_wl_emp%ROWTYPE;
  lr_wl_mnt_sal_info      cur_wl_mnt_sal_info%ROWTYPE;
  lr_wl_sal_earn          cur_wl_sal_earn%ROWTYPE;
  lr_wl_sal_dct           cur_wl_sal_dct%ROWTYPE;
--  lr_wl_bon_earn          cur_wl_bon_earn%ROWTYPE;
--  lr_wl_bon_dct           cur_wl_bon_dct%ROWTYPE;
  lr_wl_wrk_hours_days    cur_wl_wrk_hours_days%ROWTYPE;
  lr_wl_bon_pay_info      cur_wl_bon_pay_info%ROWTYPE;
  lr_wl_dec_dep_info      cur_wl_dec_dep_info%ROWTYPE;
  lr_wl_pre_emp           cur_wl_pre_emp%ROWTYPE;
  lr_wl_extra_info        cur_wl_extra_info%ROWTYPE;
  lr_wl_yea_info          cur_wl_yea_info%ROWTYPE;
  lr_wl_bon_earn_dec      cur_wl_bon_earn_dec%ROWTYPE;
  lr_wl_bon_dct_dec       cur_wl_bon_dct_dec%ROWTYPE;
  lr_proc_info            lcu_proc_info%ROWTYPE; -- added on 18/09/09
   --Variables-----
  l_xml                   CLOB;
  l_xml2                  CLOB;
  l_common_xml            CLOB;
  l_xml_begin             VARCHAR2(200);
  l_mag_asg_action_id     pay_assignment_actions.assignment_action_id%TYPE;
  l_emp_no                VARCHAR2(80);
  l_job_hist_xml          VARCHAR2(4000) ;
  l_profile_value         VARCHAR2(100);
  l_additional_info_xml   VARCHAR2(4000);
  l_add_msg_xml           VARCHAR2(4000);
  seque                   NUMBER;
  l_offset                NUMBER := 1;

  ln_total_payment_amount       NUMBER;
  ln_non_taxable_payment_amount NUMBER;
  ln_total_earnings_per_month   NUMBER;
  ln_total_earnings_per_bon     NUMBER;
  ln_amount_si                  NUMBER;
  ln_hi_deduction_amount        NUMBER;
  ln_wp_deduction_amount        NUMBER;
  ln_wpfi_deduction_amount      NUMBER;
  ln_ui_deduction_amount        NUMBER;
  ln_total_si_amount            NUMBER;
  ln_total_pay_amount_after_si  NUMBER;
  ln_no_of_dependents           NUMBER;
  ln_computed_tax_amount        NUMBER;
  ln_total_deduction_amount     NUMBER;
  ln_net_balance_amount         NUMBER;
  ln_ci_amount                  NUMBER;
  ln_local_tax_amount           NUMBER;
  ln_over_and_short_amount      NUMBER;
  ln_collected_tax_amount       NUMBER;
  loop_cnt                      NUMBER;

  ln_amount1                    NUMBER;
  ln_amount2                    NUMBER;
  ln_amount3                    NUMBER;
  ln_amount4                    NUMBER;
  ln_amount5                    NUMBER;
  ln_amount6                    NUMBER;
  ln_amount7                    NUMBER;
  ln_amount8                    NUMBER;
  ln_amount9                    NUMBER;
  ln_amount10                   NUMBER;
  ln_amount_dct1                NUMBER;
  ln_amount_dct2                NUMBER;
  ln_amount_dct3                NUMBER;
  ln_amount_dct4                NUMBER;
  ln_amount_dct5                NUMBER;

  total                         NUMBER;

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
    l_job_hist_xml:=null;
--
    IF gb_debug THEN
      hr_utility.trace('wl_xml');
    END IF;
--
    l_mag_asg_action_id := p_assignment_action_id;
--
    initialize(g_mag_payroll_action_id);
--
--  Fetching the employee details.
    OPEN  cur_wl_emp(l_mag_asg_action_id);
    FETCH cur_wl_emp INTO lr_wl_emp;


--
    IF (cur_wl_emp%FOUND) THEN
--
      l_xml_begin := '<wlrpt>'||gc_eol;
      vXMLTable(gn_vctr).xmlstring :=  l_xml_begin;
      gn_vctr := gn_vctr + 1;
--
      hr_utility.trace ('Phase1 ...');

-- added below on 07/09/09
      IF TO_CHAR(lr_wl_emp.TERM_DATE,'DD/MM/YYYY') > TO_CHAR(gr_parameters.termination_date_to,'DD/MM/YYYY') THEN
        lr_wl_emp.TERMINATION_DATE := NULL;
      END IF;
-- added above on 07/09/09

      l_common_xml := '<YR>'||htmlspchar(cnv_str(gr_parameters.subject_yyyymm))||'</YR>'
                    ||'<A1>'||htmlspchar(cnv_str(lr_wl_emp.ORGANIZATION_ID))||'</A1>'||gc_eol
                    ||'<A2>'||htmlspchar(cnv_str(lr_wl_emp.PAYROLL_ID))||'</A2>'||gc_eol
                    ||'<A3>'||htmlspchar(cnv_str(lr_wl_emp.WITHHOLDING_AGENT_ID))||'</A3>'||gc_eol
                    ||'<A4>'||htmlspchar(cnv_str(lr_wl_emp.LOCATION_ID))||'</A4>'||gc_eol
                    ||'<A5>'||htmlspchar(cnv_str(lr_wl_emp.PERSON_ID))||'</A5>'||gc_eol
                    ||'<A6>'||htmlspchar(cnv_str(lr_wl_emp.FULL_NAME_KANA))||'</A6>'||gc_eol
                    ||'<A7>'||htmlspchar(cnv_str(lr_wl_emp.FULL_NAME_KANJI))||'</A7>'||gc_eol
                    ||'<A8>'||htmlspchar(cnv_str(lr_wl_emp.PAYROLL_NAME))||'</A8>'||gc_eol
                    ||'<A9>('||htmlspchar(cnv_str(lr_wl_emp.AGE))||')</A9>'||gc_eol
                    ||'<A10>'||htmlspchar(cnv_str(lr_wl_emp.HEALTH_INSURANCE_NUMBER))||'</A10>'||gc_eol
                    ||'<A11>'||htmlspchar(cnv_str(lr_wl_emp.WELFARE_PENSION_INS_NUMBER))||'</A11>'||gc_eol
                    ||'<A12>'||htmlspchar(cnv_str(lr_wl_emp.BASIC_PENSION_NUMBER))||'</A12>'||gc_eol
                    ||'<A13>'||htmlspchar(cnv_str(lr_wl_emp.UNEMPLOYMENT_INSURANCE_NUMBER))||'</A13>'||gc_eol
                    ||'<A14>'||htmlspchar(cnv_str(lr_wl_emp.HIRE_DATE))||'</A14>'||gc_eol
                    ||'<A15>'||htmlspchar(cnv_str(lr_wl_emp.YEARS_OF_SERVICE))||'</A15>'||gc_eol
                    ||'<A16>'||htmlspchar(cnv_str(lr_wl_emp.TAX_CLASS))||'</A16>'||gc_eol
                    ||'<A17>'||htmlspchar(cnv_str(lr_wl_emp.TERMINATION_DATE))||'</A17>'||gc_eol
                    ||'<A18>'||htmlspchar(cnv_str(lr_wl_emp.ORGANIZATION_NAME))||'</A18>'||gc_eol
                    ||'<A19>'||htmlspchar(cnv_str(lr_wl_emp.GENDER))||'</A19>'||gc_eol
                    ||'<A20>'||htmlspchar(cnv_str(lr_wl_emp.JOB_NAME))||'</A20>'||gc_eol
                    ||'<A21>'||htmlspchar(cnv_str(lr_wl_emp.POSTAL_CODE))||'</A21>'||gc_eol
                    ||'<A22>'||htmlspchar(cnv_str(lr_wl_emp.ADDRESS_LINE1))||'</A22>'||gc_eol
                    ||'<A23>'||htmlspchar(cnv_str(lr_wl_emp.ADDRESS_LINE2))||'</A23>'||gc_eol
                    ||'<A24>'||htmlspchar(cnv_str(lr_wl_emp.ADDRESS_LINE3))||'</A24>'||gc_eol
                    ||'<A25>'||htmlspchar(cnv_str(lr_wl_emp.DATE_OF_BIRTH))||'</A25>'||gc_eol
                    ||'<A26>'||htmlspchar(cnv_str(lr_wl_emp.EMPLOYEE_NUMBER))||'</A26>'||gc_eol
                    ||'<A27>'||htmlspchar(cnv_str(lr_wl_emp.PHONE))||'</A27>'||gc_eol
                    ||'<A28>'||htmlspchar(cnv_str(lr_wl_emp.ADDRESS_LINE1_KANA))||'</A28>'||gc_eol
                    ||'<A29>'||htmlspchar(cnv_str(lr_wl_emp.ADDRESS_LINE2_KANA))||'</A29>'||gc_eol
                    ||'<A30>'||htmlspchar(cnv_str(lr_wl_emp.ADDRESS_LINE3_KANA))||'</A30>'||gc_eol
                    ||'<ASSIGN>'||htmlspchar(cnv_str(l_mag_asg_action_id))||'</ASSIGN>'||gc_eol;

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;
      ln_total_payment_amount       := 0;
      ln_non_taxable_payment_amount := 0;
      ln_total_earnings_per_month   := 0;
      ln_amount_si                  := 0;
      ln_hi_deduction_amount        := 0;
      ln_wp_deduction_amount        := 0;
      ln_wpfi_deduction_amount      := 0;
      ln_ui_deduction_amount        := 0;
      ln_total_si_amount            := 0;
      ln_total_pay_amount_after_si  := 0;
      ln_no_of_dependents           := 0;
      ln_computed_tax_amount        := 0;
      ln_ci_amount                  := 0;
      ln_local_tax_amount           := 0;
      ln_over_and_short_amount      := 0;
      ln_collected_tax_amount       := 0;
      ln_total_deduction_amount     := 0;
      ln_net_balance_amount         := 0;

      FOR i in 1 .. 12
      LOOP
        OPEN  cur_wl_mnt_sal_info(l_mag_asg_action_id,i );
        FETCH cur_wl_mnt_sal_info INTO lr_wl_mnt_sal_info ;
        CLOSE cur_wl_mnt_sal_info;
          l_common_xml := l_common_xml||'<B'||i||'-1>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.PERSON_ID))||'</B'||i||'-1>'||gc_eol
                                      ||'<B'||i||'-2>'||TO_CHAR(lr_wl_mnt_sal_info.PAYMENT_DATE,'yyyy-mm-dd')  ||TO_CHAR(lr_wl_mnt_sal_info.PAYMENT_DATE,'hh:mm:ss-HH:MM')||'</B'||i||'-2>'||gc_eol
                                      ||'<B'||i||'-3>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.TOTAL_PAYMENT_AMOUNT))||'</B'||i||'-3>'||gc_eol
                                      ||'<B'||i||'-4>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.NON_TAXABLE_PAYMENT_AMOUNT))||'</B'||i||'-4>'||gc_eol
                                      ||'<B'||i||'-5>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.TOTAL_EARNINGS_PER_MONTH))||'</B'||i||'-5>'||gc_eol
                                      ||'<B'||i||'-6>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.SI_DEDUCTION_AMOUNTAMOUNT_SI))||'</B'||i||'-6>'||gc_eol
                                      ||'<B'||i||'-7>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.HI_DEDUCTION_AMOUNT))||'</B'||i||'-7>'||gc_eol
                                      ||'<B'||i||'-8>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.WP_DEDUCTION_AMOUNT))||'</B'||i||'-8>'||gc_eol
                                      ||'<B'||i||'-9>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.WPFI_DEDUCTION_AMOUNT))||'</B'||i||'-9>'||gc_eol
                                      ||'<B'||i||'-10>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.UI_DEDUCTION_AMOUNT))||'</B'||i||'-10>'||gc_eol
                                      ||'<B'||i||'-11>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.TOTAL_SI_AMOUNT))||'</B'||i||'-11>'||gc_eol
                                      ||'<B'||i||'-12>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.TOTAL_PAY_AMOUNT_AFTER_SI))||'</B'||i||'-12>'||gc_eol
                                      ||'<B'||i||'-13>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.NO_OF_DEPENDENTS))||'</B'||i||'-13>'||gc_eol
                                      ||'<B'||i||'-14>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.TAX_RATE))||'</B'||i||'-14>'||gc_eol
                                      ||'<B'||i||'-15>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.COMPUTED_TAX_AMOUNT))||'</B'||i||'-15>'||gc_eol;

        IF lr_wl_mnt_sal_info.CI_AMOUNT IS NOT NULL THEN
          l_common_xml := l_common_xml||'<B'||i||'-16>('||TO_CHAR(lr_wl_mnt_sal_info.CI_AMOUNT
                                                         ,fnd_currency.GET_FORMAT_MASK('ja',3*length(lr_wl_mnt_sal_info.CI_AMOUNT)))||')</B'||i||'-16>'||gc_eol;
        ELSE
          l_common_xml := l_common_xml||'<B'||i||'-16>'||TO_CHAR(lr_wl_mnt_sal_info.CI_AMOUNT
                                                         ,fnd_currency.GET_FORMAT_MASK('ja',3*length(lr_wl_mnt_sal_info.CI_AMOUNT)))||'</B'||i||'-16>'||gc_eol;
        END IF;

          l_common_xml := l_common_xml||'<B'||i||'-17>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.LOCAL_TAX_AMOUNT))||'</B'||i||'-17>'||gc_eol
                                      ||'<B'||i||'-18>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.OVER_AND_SHORT_AMOUNT))||'</B'||i||'-18>'||gc_eol
                                      ||'<B'||i||'-19>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.COLLECTED_TAX_AMOUNT))||'</B'||i||'-19>'
                                      ||'<B'||i||'-20>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.TOTAL_DEDUCTION_AMOUNT))||'</B'||i||'-20>'
                                      ||'<B'||i||'-21>'||htmlspchar(cnv_str(lr_wl_mnt_sal_info.NET_BALANCE_AMOUNT))||'</B'||i||'-21>';

          ln_total_payment_amount       := ln_total_payment_amount + nvl(lr_wl_mnt_sal_info.total_payment_amount,0);
          ln_non_taxable_payment_amount := ln_non_taxable_payment_amount + nvl(lr_wl_mnt_sal_info.non_taxable_payment_amount,0);
          ln_total_earnings_per_month   := ln_total_earnings_per_month + nvl(lr_wl_mnt_sal_info.total_earnings_per_month,0);
          ln_amount_si                  := ln_amount_si + nvl(lr_wl_mnt_sal_info.si_deduction_amountamount_si,0);
          ln_hi_deduction_amount        := ln_hi_deduction_amount + nvl(lr_wl_mnt_sal_info.hi_deduction_amount,0);
          ln_wp_deduction_amount        := ln_wp_deduction_amount + nvl(lr_wl_mnt_sal_info.wp_deduction_amount,0);
          ln_wpfi_deduction_amount      := ln_wpfi_deduction_amount + nvl(lr_wl_mnt_sal_info.wpfi_deduction_amount,0);
          ln_ui_deduction_amount        := ln_ui_deduction_amount + nvl(lr_wl_mnt_sal_info.ui_deduction_amount,0);
          ln_total_si_amount            := ln_total_si_amount + nvl(lr_wl_mnt_sal_info.total_si_amount,0);
          ln_total_pay_amount_after_si  := ln_total_pay_amount_after_si + nvl(lr_wl_mnt_sal_info.total_pay_amount_after_si,0);
          ln_no_of_dependents           := ln_no_of_dependents + nvl(lr_wl_mnt_sal_info.no_of_dependents,0);
          ln_computed_tax_amount        := ln_computed_tax_amount + nvl(lr_wl_mnt_sal_info.computed_tax_amount,0);
          ln_ci_amount                  := ln_ci_amount + nvl(lr_wl_mnt_sal_info.ci_amount,0);
          ln_local_tax_amount           := ln_local_tax_amount + nvl(lr_wl_mnt_sal_info.local_tax_amount,0);
          ln_over_and_short_amount      := ln_over_and_short_amount + nvl(lr_wl_mnt_sal_info.over_and_short_amount,0);
          ln_collected_tax_amount       := ln_collected_tax_amount + nvl(lr_wl_mnt_sal_info.collected_tax_amount,0);
          ln_total_deduction_amount     := ln_total_deduction_amount + nvl(lr_wl_mnt_sal_info.total_deduction_amount,0);
          ln_net_balance_amount         := ln_net_balance_amount + nvl(lr_wl_mnt_sal_info.net_balance_amount,0);

          lr_wl_mnt_sal_info := null;
      END LOOP;

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;

      hr_utility.trace ('Phase2 ...');

      l_common_xml := '<BT-1>'||htmlspchar(cnv_str(ln_total_payment_amount))||'</BT-1>'||gc_eol
                    ||'<BT-2>'||htmlspchar(cnv_str(ln_non_taxable_payment_amount))||'</BT-2>'||gc_eol
                    ||'<BT-3>'||htmlspchar(cnv_str(ln_total_earnings_per_month))||'</BT-3>'||gc_eol
                    ||'<BT-4>'||htmlspchar(cnv_str(ln_amount_si))||'</BT-4>'||gc_eol
                    ||'<BT-5>'||htmlspchar(cnv_str(ln_hi_deduction_amount))||'</BT-5>'||gc_eol
                    ||'<BT-6>'||htmlspchar(cnv_str(ln_wp_deduction_amount))||'</BT-6>'||gc_eol
                    ||'<BT-7>'||htmlspchar(cnv_str(ln_wpfi_deduction_amount))||'</BT-7>'||gc_eol
                    ||'<BT-8>'||htmlspchar(cnv_str(ln_ui_deduction_amount))||'</BT-8>'||gc_eol
                    ||'<BT-9>'||htmlspchar(cnv_str(ln_total_si_amount))||'</BT-9>'||gc_eol
                    ||'<BT-10>'||htmlspchar(cnv_str(ln_total_pay_amount_after_si))||'</BT-10>'||gc_eol
                    ||'<BT-11>'||htmlspchar(cnv_str(ln_no_of_dependents))||'</BT-11>'||gc_eol
                    ||'<BT-12>'||htmlspchar(cnv_str(ln_computed_tax_amount))||'</BT-12>'||gc_eol;

    IF ln_ci_amount IS NOT NULL THEN
      l_common_xml := l_common_xml||'<BT-13>('||TO_CHAR(ln_ci_amount
                                             ,fnd_currency.GET_FORMAT_MASK('ja',3*length(ln_ci_amount)))||')</BT-13>'||gc_eol;
    ELSE
      l_common_xml := l_common_xml||'<BT-13>'||TO_CHAR(ln_ci_amount
                                            ,fnd_currency.GET_FORMAT_MASK('ja',3*length(ln_ci_amount)))||'</BT-13>'||gc_eol;
    END IF;

      l_common_xml := l_common_xml||'<BT-14>'||htmlspchar(cnv_str(ln_local_tax_amount))||'</BT-14>'||gc_eol
                                  ||'<BT-15>'||htmlspchar(cnv_str(ln_over_and_short_amount))||'</BT-15>'||gc_eol
                                  ||'<BT-16>'||htmlspchar(cnv_str(ln_collected_tax_amount))||'</BT-16>'||gc_eol
                                  ||'<BT-17>'||htmlspchar(cnv_str(ln_total_deduction_amount))||'</BT-17>'||gc_eol
                                  ||'<BT-18>'||htmlspchar(cnv_str(ln_net_balance_amount))||'</BT-18>';

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;

      FOR seque in 1 .. 10
      LOOP
        OPEN  cur_wl_sal_earn(l_mag_asg_action_id,seque);
        FETCH cur_wl_sal_earn INTO lr_wl_sal_earn;
        CLOSE cur_wl_sal_earn;

          l_common_xml :=l_common_xml||'<Be1-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.TYPE))||'</Be1-'||seque||'>'||gc_eol
                                     ||'<Be2-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.ITEM_ID))||'</Be2-'||seque||'>'||gc_eol
                                     ||'<Be3-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.ITEM_TYPE))||'</Be3-'||seque||'>'||gc_eol
                                     ||'<Be4-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.ITEM_REP_NAME))||'</Be4-'||seque||'>'||gc_eol
                                     ||'<Be5-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.ITEM_REP_SEQ))||'</Be5-'||seque||'>'||gc_eol
                                     ||'<Be6-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH1_AMOUNT))||'</Be6-'||seque||'>'||gc_eol
                                     ||'<Be7-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH2_AMOUNT))||'</Be7-'||seque||'>'||gc_eol
                                     ||'<Be8-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH3_AMOUNT))||'</Be8-'||seque||'>'||gc_eol
                                     ||'<Be9-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH4_AMOUNT))||'</Be9-'||seque||'>'||gc_eol
                                     ||'<Be10-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH5_AMOUNT))||'</Be10-'||seque||'>'||gc_eol
                                     ||'<Be11-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH6_AMOUNT))||'</Be11-'||seque||'>'||gc_eol
                                     ||'<Be12-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH7_AMOUNT))||'</Be12-'||seque||'>'||gc_eol
                                     ||'<Be13-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH8_AMOUNT))||'</Be13-'||seque||'>'||gc_eol
                                     ||'<Be14-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH9_AMOUNT))||'</Be14-'||seque||'>'||gc_eol
                                     ||'<Be15-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH10_AMOUNT))||'</Be15-'||seque||'>'||gc_eol
                                     ||'<Be16-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH11_AMOUNT))||'</Be16-'||seque||'>'||gc_eol
                                     ||'<Be17-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.MONTH12_AMOUNT))||'</Be17-'||seque||'>'||gc_eol
                                     --||'<Be18-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_earn.TOTAL_AMOUNT))||'</Be18-'||seque||'>'; -- commented by rdarasi for Bug #8815036
                                     ||'<Be18-'||seque||'>'||htmlspchar(cnv_str(NVL(lr_wl_sal_earn.MONTH1_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH2_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH3_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH4_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH5_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH6_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH7_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH8_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH9_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH10_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH11_AMOUNT,0)
                                                                               +NVL(lr_wl_sal_earn.MONTH12_AMOUNT,0)))||'</Be18-'||seque||'>'; -- added by rdarasi for Bug #8815036

        lr_wl_sal_earn := NULL;
        END LOOP;


hr_utility.trace ('Phase3 ...');

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;

      FOR seque in 1 .. 5
      LOOP

        OPEN  cur_wl_sal_dct(l_mag_asg_action_id,seque);
        FETCH cur_wl_sal_dct INTO lr_wl_sal_dct;
        CLOSE cur_wl_sal_dct;

          l_common_xml := l_common_xml ||'<Bd1-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.TYPE))||'</Bd1-'||seque||'>'||gc_eol
                                       ||'<Bd2-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.ITEM_ID))||'</Bd2-'||seque||'>'||gc_eol
                                       ||'<Bd3-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.ITEM_TYPE))||'</Bd3-'||seque||'>'||gc_eol
                                       ||'<Bd4-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.ITEM_REP_NAME))||'</Bd4-'||seque||'>'||gc_eol
                                       ||'<Bd5-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.ITEM_REP_SEQ))||'</Bd5-'||seque||'>'||gc_eol
                                       ||'<Bd6-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH1_AMOUNT))||'</Bd6-'||seque||'>'||gc_eol
                                       ||'<Bd7-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH2_AMOUNT))||'</Bd7-'||seque||'>'||gc_eol
                                       ||'<Bd8-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH3_AMOUNT))||'</Bd8-'||seque||'>'||gc_eol
                                       ||'<Bd9-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH4_AMOUNT))||'</Bd9-'||seque||'>'||gc_eol
                                       ||'<Bd10-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH5_AMOUNT))||'</Bd10-'||seque||'>'||gc_eol
                                       ||'<Bd11-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH6_AMOUNT))||'</Bd11-'||seque||'>'||gc_eol
                                       ||'<Bd12-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH7_AMOUNT))||'</Bd12-'||seque||'>'||gc_eol
                                       ||'<Bd13-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH8_AMOUNT))||'</Bd13-'||seque||'>'||gc_eol
                                       ||'<Bd14-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH9_AMOUNT))||'</Bd14-'||seque||'>'||gc_eol
                                       ||'<Bd15-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH10_AMOUNT))||'</Bd15-'||seque||'>'||gc_eol
                                       ||'<Bd16-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH11_AMOUNT))||'</Bd16-'||seque||'>'||gc_eol
                                       ||'<Bd17-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.MONTH12_AMOUNT))||'</Bd17-'||seque||'>'||gc_eol
                                       --||'<Bd18-'||seque||'>'||htmlspchar(cnv_str(lr_wl_sal_dct.TOTAL_AMOUNT))||'</Bd18-'||seque||'>'; -- commented by rdarasi for Bug #8815036
                                       ||'<Bd18-'||seque||'>'||htmlspchar(cnv_str(NVL(lr_wl_sal_dct.MONTH1_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH2_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH3_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH4_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH5_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH6_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH7_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH8_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH9_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH10_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH11_AMOUNT,0)
                                                                                 +NVL(lr_wl_sal_dct.MONTH12_AMOUNT,0)))||'</Bd18-'||seque||'>'; -- added by rdarasi for Bug #8815036

       lr_wl_sal_dct := NULL;
       END LOOP;

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;
      seque        := 1;

hr_utility.trace ('Phase4 ...');
/*
      FOR seque in 1 .. 10
      LOOP

      OPEN  cur_wl_bon_earn(l_mag_asg_action_id,seque);
      FETCH cur_wl_bon_earn INTO lr_wl_bon_earn;
      CLOSE cur_wl_bon_earn;

        l_common_xml := l_common_xml||'<Ce1-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.BON_TYPE))||'</Ce1-'||seque||'>'||gc_eol
                                    ||'<Ce2-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.TYPE))||'</Ce2-'||seque||'>'||gc_eol
                                    ||'<Ce3-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.ITEM_ID))||'</Ce3-'||seque||'>'||gc_eol
                                    ||'<Ce4-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.ITEM_TYPE))||'</Ce4-'||seque||'>'||gc_eol
                                    ||'<Ce5-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.ITEM_REP_NAME))||'</Ce5-'||seque||'>'||gc_eol
                                    ||'<Ce6-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.ITEM_REP_SEQ))||'</Ce6-'||seque||'>'||gc_eol
                                    ||'<Ce7-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH1_AMOUNT))||'</Ce7-'||seque||'>'||gc_eol
                                    ||'<Ce8-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH2_AMOUNT))||'</Ce8-'||seque||'>'||gc_eol
                                    ||'<Ce9-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH3_AMOUNT))||'</Ce9-'||seque||'>'||gc_eol
                                    ||'<Ce10-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH4_AMOUNT))||'</Ce10-'||seque||'>'||gc_eol
                                    ||'<Ce11-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH5_AMOUNT))||'</Ce11-'||seque||'>'||gc_eol
                                    ||'<Ce12-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH6_AMOUNT))||'</Ce12-'||seque||'>'||gc_eol
                                    ||'<Ce13-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH7_AMOUNT))||'</Ce13-'||seque||'>'||gc_eol
                                    ||'<Ce14-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH8_AMOUNT))||'</Ce14-'||seque||'>'||gc_eol
                                    ||'<Ce15-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH9_AMOUNT))||'</Ce15-'||seque||'>'||gc_eol
                                    ||'<Ce16-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH10_AMOUNT))||'</Ce16-'||seque||'>'||gc_eol
                                    ||'<Ce17-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH11_AMOUNT))||'</Ce17-'||seque||'>'||gc_eol
                                    ||'<Ce18-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.MONTH12_AMOUNT))||'</Ce18-'||seque||'>'||gc_eol
                                    --||'<Ce19-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_earn.TOTAL_AMOUNT))||'</Ce19-'||seque||'>';
                                    ||'<Ce19-'||seque||'>'||htmlspchar(cnv_str(NVL(lr_wl_bon_earn.MONTH1_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH2_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH3_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH4_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH5_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH6_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH7_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH8_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH9_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH10_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH11_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_earn.MONTH12_AMOUNT,0)))||'</Ce19-'||seque||'>'; -- added by rdarasi for Bug #8815036


      lr_wl_bon_earn := NULL;
      END LOOP;


hr_utility.trace ('Phase5 ...');

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;

      FOR seque in 1 .. 5
      LOOP

      OPEN  cur_wl_bon_dct(l_mag_asg_action_id,seque);
      FETCH cur_wl_bon_dct INTO lr_wl_bon_dct;
      CLOSE cur_wl_bon_dct;

        l_common_xml := l_common_xml||'<Cd1-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.BON_TYPE))||'</Cd1-'||seque||'>'||gc_eol
                                    ||'<Cd2-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.TYPE))||'</Cd2-'||seque||'>'||gc_eol
                                    ||'<Cd3-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.ITEM_ID))||'</Cd3-'||seque||'>'||gc_eol
                                    ||'<Cd4-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.ITEM_TYPE))||'</Cd4-'||seque||'>'||gc_eol
                                    ||'<Cd5-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.ITEM_REP_NAME))||'</Cd5-'||seque||'>'||gc_eol
                                    ||'<Cd6-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.ITEM_REP_SEQ))||'</Cd6-'||seque||'>'||gc_eol
                                    ||'<Cd7-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH1_AMOUNT))||'</Cd7-'||seque||'>'||gc_eol
                                    ||'<Cd8-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH2_AMOUNT))||'</Cd8-'||seque||'>'||gc_eol
                                    ||'<Cd9-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH3_AMOUNT))||'</Cd9-'||seque||'>'||gc_eol
                                    ||'<Cd10-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH4_AMOUNT))||'</Cd10-'||seque||'>'||gc_eol
                                    ||'<Cd11-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH5_AMOUNT))||'</Cd11-'||seque||'>'||gc_eol
                                    ||'<Cd12-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH6_AMOUNT))||'</Cd12-'||seque||'>'||gc_eol
                                    ||'<Cd13-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH7_AMOUNT))||'</Cd13-'||seque||'>'||gc_eol
                                    ||'<Cd14-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH8_AMOUNT))||'</Cd14-'||seque||'>'||gc_eol
                                    ||'<Cd15-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH9_AMOUNT))||'</Cd15-'||seque||'>'||gc_eol
                                    ||'<Cd16-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH10_AMOUNT))||'</Cd16-'||seque||'>'||gc_eol
                                    ||'<Cd17-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH11_AMOUNT))||'</Cd17-'||seque||'>'||gc_eol
                                    ||'<Cd18-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.MONTH12_AMOUNT))||'</Cd18-'||seque||'>'||gc_eol
                                    --||'<Cd19-'||seque||'>'||htmlspchar(cnv_str(lr_wl_bon_dct.TOTAL_AMOUNT))||'</Cd19-'||seque||'>';
                                    ||'<Cd19-'||seque||'>'||htmlspchar(cnv_str(NVL(lr_wl_bon_dct.MONTH1_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH2_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH3_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH4_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH5_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH6_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH7_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH8_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH9_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH10_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH11_AMOUNT,0)
                                                                              +NVL(lr_wl_bon_dct.MONTH12_AMOUNT,0)))||'</Cd19-'||seque||'>'; -- added by rdarasi for Bug #8815036

      lr_wl_bon_dct := NULL;
      END LOOP;


hr_utility.trace ('Phase6 ...');

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;
*/
      l_common_xml := null;

      seque := 1;

      ln_total_payment_amount       := 0;
      ln_non_taxable_payment_amount := 0;
      ln_total_earnings_per_bon     := NULL;
      ln_amount_si                  := 0;
      ln_hi_deduction_amount        := 0;
      ln_wp_deduction_amount        := 0;
      ln_wpfi_deduction_amount      := 0;
      ln_ui_deduction_amount        := 0;
      ln_total_si_amount            := 0;
      ln_total_pay_amount_after_si  := 0;
      ln_no_of_dependents           := 0;
      ln_computed_tax_amount        := 0;
      ln_ci_amount                  := 0;
      ln_local_tax_amount           := 0;
      ln_over_and_short_amount      := 0;
      ln_collected_tax_amount       := 0;
      ln_total_deduction_amount     := 0;
      ln_net_balance_amount         := 0;

      ln_amount1                    := 0;
      ln_amount2                    := 0;
      ln_amount3                    := 0;
      ln_amount4                    := 0;
      ln_amount5                    := 0;
      ln_amount6                    := 0;
      ln_amount7                    := 0;
      ln_amount8                    := 0;
      ln_amount9                    := 0;
      ln_amount10                   := 0;
      ln_amount_dct1                := 0;
      ln_amount_dct2                := 0;
      ln_amount_dct3                := 0;
      ln_amount_dct4                := 0;
      ln_amount_dct5                := 0;


      OPEN  cur_wl_bon_pay_info(l_mag_asg_action_id );
      LOOP
      FETCH cur_wl_bon_pay_info INTO lr_wl_bon_pay_info ;
      EXIT WHEN cur_wl_bon_pay_info%NOTFOUND;
          IF cur_wl_bon_pay_info%NOTFOUND THEN
            lr_wl_bon_pay_info := null;
          END IF;
        l_common_xml := l_common_xml||'<C'||seque||'-1>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.PERSON_ID))||'</C'||seque||'-1>'||gc_eol
                                    ||'<C'||seque||'-2>'||TO_CHAR(lr_wl_bon_pay_info.BONUS_PAYMENT_DATE,'yyyy-mm-dd')  ||TO_CHAR(lr_wl_bon_pay_info.BONUS_PAYMENT_DATE,'hh:mm:ss-HH:MM')||'</C'||seque||'-2>'||gc_eol
                                    ||'<C'||seque||'-3>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.TOTAL_PAYMENT_AMOUNT))||'</C'||seque||'-3>'||gc_eol
                                    ||'<C'||seque||'-4>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.NON_TAXABLE_PAYMENT_AMOUNT))||'</C'||seque||'-4>'||gc_eol
                                    ||'<C'||seque||'-5>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.TOTAL_EARNINGS_PER_MONTH))||'</C'||seque||'-5>'||gc_eol
                                    ||'<C'||seque||'-6>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.SI_DEDUCTION_AMOUNT))||'</C'||seque||'-6>'||gc_eol
                                    ||'<C'||seque||'-7>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.HI_DEDUCTION_AMOUNT))||'</C'||seque||'-7>'||gc_eol
                                    ||'<C'||seque||'-8>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.WP_DEDUCTION_AMOUNT))||'</C'||seque||'-8>'||gc_eol
                                    ||'<C'||seque||'-9>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.WPFI_DEDUCTION_AMOUNT))||'</C'||seque||'-9>'||gc_eol
                                    ||'<C'||seque||'-10>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.UI_DEDUCTION_AMOUNT))||'</C'||seque||'-10>'||gc_eol
                                    ||'<C'||seque||'-11>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.TOTAL_SI_AMOUNT))||'</C'||seque||'-11>'||gc_eol
                                    ||'<C'||seque||'-12>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.TOTAL_PAY_AMOUNT_AFTER_SI))||'</C'||seque||'-12>'||gc_eol
                                    ||'<C'||seque||'-13>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.NO_OF_DEPENDENTS))||'</C'||seque||'-13>'||gc_eol
                                    ||'<C'||seque||'-14>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.TAX_RATE))||'</C'||seque||'-14>'||gc_eol
                                    ||'<C'||seque||'-15>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.COMPUTED_TAX_AMOUNT))||'</C'||seque||'-15>'||gc_eol
                                    ||'<C'||seque||'-16>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.OVER_AND_SHORT_AMOUNT))||'</C'||seque||'-16>'||gc_eol
                                    ||'<C'||seque||'-17>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.COLLECTED_TAX_AMOUNT))||'</C'||seque||'-17>'||gc_eol;

IF lr_wl_bon_pay_info.CI_AMOUNT IS NOT NULL THEN
        l_common_xml := l_common_xml||'<C'||seque||'-18>('||TO_CHAR(lr_wl_bon_pay_info.CI_AMOUNT
                                                         ,fnd_currency.GET_FORMAT_MASK('ja',3*length(lr_wl_bon_pay_info.CI_AMOUNT)))||')</C'||seque||'-18>'||gc_eol;
ELSE
        l_common_xml := l_common_xml||'<C'||seque||'-18>'||TO_CHAR(lr_wl_bon_pay_info.CI_AMOUNT
                                                         ,fnd_currency.GET_FORMAT_MASK('ja',3*length(lr_wl_bon_pay_info.CI_AMOUNT)))||'</C'||seque||'-18>'||gc_eol;
END IF;

        l_common_xml := l_common_xml||'<C'||seque||'-19>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.LOCAL_TAX_AMOUNT))||'</C'||seque||'-19>'||gc_eol
                                    ||'<C'||seque||'-20>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.TOTAL_DEDUCTION_AMOUNT))||'</C'||seque||'-20>'||gc_eol
                                    ||'<C'||seque||'-21>'||htmlspchar(cnv_str(lr_wl_bon_pay_info.NET_BALANCE_AMOUNT))||'</C'||seque||'-21>';


        ln_total_payment_amount       := ln_total_payment_amount + nvl(lr_wl_bon_pay_info.total_payment_amount,0);
        ln_non_taxable_payment_amount := ln_non_taxable_payment_amount + nvl(lr_wl_bon_pay_info.non_taxable_payment_amount,0);

        IF lr_wl_bon_pay_info.total_earnings_per_month IS NOT NULL THEN
          ln_total_earnings_per_bon     := NVL(ln_total_earnings_per_bon,0) + lr_wl_bon_pay_info.total_earnings_per_month;
        END IF;

        ln_amount_si                  := ln_amount_si + nvl(lr_wl_bon_pay_info.si_deduction_amount,0);
        ln_hi_deduction_amount        := ln_hi_deduction_amount + nvl(lr_wl_bon_pay_info.hi_deduction_amount,0);
        ln_wp_deduction_amount        := ln_wp_deduction_amount + nvl(lr_wl_bon_pay_info.wp_deduction_amount,0);
        ln_wpfi_deduction_amount      := ln_wpfi_deduction_amount + nvl(lr_wl_bon_pay_info.wpfi_deduction_amount,0);
        ln_ui_deduction_amount        := ln_ui_deduction_amount + nvl(lr_wl_bon_pay_info.ui_deduction_amount,0);
        ln_total_si_amount            := ln_total_si_amount + nvl(lr_wl_bon_pay_info.total_si_amount,0);
        ln_total_pay_amount_after_si  := ln_total_pay_amount_after_si + nvl(lr_wl_bon_pay_info.total_pay_amount_after_si,0);
        ln_no_of_dependents           := ln_no_of_dependents + nvl(lr_wl_bon_pay_info.no_of_dependents,0);
        ln_computed_tax_amount        := ln_computed_tax_amount + nvl(lr_wl_bon_pay_info.computed_tax_amount,0);
        ln_ci_amount                  := ln_ci_amount + nvl(lr_wl_bon_pay_info.ci_amount,0);
        ln_local_tax_amount           := ln_local_tax_amount + nvl(lr_wl_bon_pay_info.local_tax_amount,0);
        ln_over_and_short_amount      := ln_over_and_short_amount + nvl(lr_wl_bon_pay_info.over_and_short_amount,0);
        ln_collected_tax_amount       := ln_collected_tax_amount + nvl(lr_wl_bon_pay_info.collected_tax_amount,0);
        ln_total_deduction_amount     := ln_total_deduction_amount + nvl(lr_wl_bon_pay_info.total_deduction_amount,0);
        ln_net_balance_amount         := ln_net_balance_amount + nvl(lr_wl_bon_pay_info.net_balance_amount,0);
-- added below by rdarasi
      FOR seque1 in 1 .. 10
      LOOP

      OPEN  cur_wl_bon_earn_dec(l_mag_asg_action_id,seque1,TO_CHAR(lr_wl_bon_pay_info.BONUS_PAYMENT_DATE,'mm'),lr_wl_bon_pay_info.element_set);
      FETCH cur_wl_bon_earn_dec INTO lr_wl_bon_earn_dec;
      CLOSE cur_wl_bon_earn_dec;

        l_common_xml := l_common_xml||'<Ce'||seque||'-'||seque1||'>'||htmlspchar(cnv_str(lr_wl_bon_earn_dec.value1))||'</Ce'||seque||'-'||seque1||'>';
      CASE
          WHEN seque1= 1 THEN ln_amount1:= ln_amount1+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 2 THEN ln_amount2:= ln_amount2+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 3 THEN ln_amount3:= ln_amount3+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 4 THEN ln_amount4:= ln_amount4+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 5 THEN ln_amount5:= ln_amount5+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 6 THEN ln_amount6:= ln_amount6+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 7 THEN ln_amount7:= ln_amount7+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 8 THEN ln_amount8:= ln_amount8+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 9 THEN ln_amount9:= ln_amount9+NVL(lr_wl_bon_earn_dec.value1,0);
          WHEN seque1= 10 THEN ln_amount10:= ln_amount10+NVL(lr_wl_bon_earn_dec.value1,0);
      END CASE;
-- added below on 07/09/09
      IF seque = 1 THEN
        l_common_xml := l_common_xml||'<Ce5-'||seque1||'>'||htmlspchar(cnv_str(lr_wl_bon_earn_dec.ITEM_REP_NAME))||'</Ce5-'||seque1||'>';
      END IF;
-- added above on 07/09/09
      lr_wl_bon_earn_dec := NULL;
      END LOOP;

hr_utility.trace ('Phase5 ...');

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;

      FOR seque1 in 1 .. 5
      LOOP

      OPEN  cur_wl_bon_dct_dec(l_mag_asg_action_id,seque1,TO_CHAR(lr_wl_bon_pay_info.BONUS_PAYMENT_DATE,'mm'),lr_wl_bon_pay_info.element_set);
      FETCH cur_wl_bon_dct_dec INTO lr_wl_bon_dct_dec;
      CLOSE cur_wl_bon_dct_dec;

        l_common_xml := l_common_xml||'<Cd'||seque||'-'||seque1||'>'||htmlspchar(cnv_str(lr_wl_bon_dct_dec.value1))||'</Cd'||seque||'-'||seque1||'>';
      CASE
          WHEN seque1= 1 THEN ln_amount_dct1:= ln_amount_dct1+NVL(lr_wl_bon_dct_dec.value1,0);
          WHEN seque1= 2 THEN ln_amount_dct2:= ln_amount_dct2+NVL(lr_wl_bon_dct_dec.value1,0);
          WHEN seque1= 3 THEN ln_amount_dct3:= ln_amount_dct3+NVL(lr_wl_bon_dct_dec.value1,0);
          WHEN seque1= 4 THEN ln_amount_dct4:= ln_amount_dct4+NVL(lr_wl_bon_dct_dec.value1,0);
          WHEN seque1= 5 THEN ln_amount_dct5:= ln_amount_dct5+NVL(lr_wl_bon_dct_dec.value1,0);
      END CASE;
-- added below on 07/09/09
      IF seque = 1 THEN
        l_common_xml := l_common_xml||'<Cd5-'||seque1||'>'||htmlspchar(cnv_str(lr_wl_bon_dct_dec.ITEM_REP_NAME))||'</Cd5-'||seque1||'>';
      END IF;
-- added above on 07/09/09
      lr_wl_bon_dct_dec := NULL;
      END LOOP;

-- added above by rdarasi
        seque := seque + 1;
      END LOOP;
      CLOSE cur_wl_bon_pay_info;

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;

      l_common_xml := '<CT-1>'||htmlspchar(cnv_str(ln_total_payment_amount))||'</CT-1>'||gc_eol
                    ||'<CT-2>'||htmlspchar(cnv_str(ln_non_taxable_payment_amount))||'</CT-2>'||gc_eol
                    ||'<CT-3>'||htmlspchar(cnv_str(NVL(ln_total_earnings_per_bon,0)))||'</CT-3>'||gc_eol
                    ||'<CT-4>'||htmlspchar(cnv_str(ln_amount_si))||'</CT-4>'||gc_eol
                    ||'<CT-5>'||htmlspchar(cnv_str(ln_hi_deduction_amount))||'</CT-5>'||gc_eol
                    ||'<CT-6>'||htmlspchar(cnv_str(ln_wp_deduction_amount))||'</CT-6>'||gc_eol
                    ||'<CT-7>'||htmlspchar(cnv_str(ln_wpfi_deduction_amount))||'</CT-7>'||gc_eol
                    ||'<CT-8>'||htmlspchar(cnv_str(ln_ui_deduction_amount))||'</CT-8>'||gc_eol
                    ||'<CT-9>'||htmlspchar(cnv_str(ln_total_si_amount))||'</CT-9>'||gc_eol
                    ||'<CT-10>'||htmlspchar(cnv_str(ln_total_pay_amount_after_si))||'</CT-10>'||gc_eol
                    ||'<CT-11>'||htmlspchar(cnv_str(ln_no_of_dependents))||'</CT-11>'||gc_eol
                    ||'<CT-12>'||htmlspchar(cnv_str(ln_computed_tax_amount))||'</CT-12>'||gc_eol;

    IF ln_ci_amount IS NOT NULL THEN
      l_common_xml := l_common_xml||'<CT-13>('||TO_CHAR(ln_ci_amount
                                             ,fnd_currency.GET_FORMAT_MASK('ja',3*length(ln_ci_amount)))||')</CT-13>'||gc_eol;
    ELSE
      l_common_xml := l_common_xml||'<CT-13>'||TO_CHAR(ln_ci_amount
                                             ,fnd_currency.GET_FORMAT_MASK('ja',3*length(ln_ci_amount)))||'</CT-13>'||gc_eol;
    END IF;

      l_common_xml := l_common_xml||'<CT-14>'||htmlspchar(cnv_str(ln_local_tax_amount))||'</CT-14>'||gc_eol
                                  ||'<CT-15>'||htmlspchar(cnv_str(ln_over_and_short_amount))||'</CT-15>'||gc_eol
                                  ||'<CT-16>'||htmlspchar(cnv_str(ln_collected_tax_amount))||'</CT-16>'||gc_eol
                                  ||'<CT-17>'||htmlspchar(cnv_str(ln_total_deduction_amount))||'</CT-17>'||gc_eol
                                  ||'<CT-18>'||htmlspchar(cnv_str(ln_net_balance_amount))||'</CT-18>'||gc_eol
                                  ||'<CTe1>'||htmlspchar(cnv_str(ln_amount1))||'</CTe1>'||gc_eol
                                  ||'<CTe2>'||htmlspchar(cnv_str(ln_amount2))||'</CTe2>'||gc_eol
                                  ||'<CTe3>'||htmlspchar(cnv_str(ln_amount3))||'</CTe3>'||gc_eol
                                  ||'<CTe4>'||htmlspchar(cnv_str(ln_amount4))||'</CTe4>'||gc_eol
                                  ||'<CTe5>'||htmlspchar(cnv_str(ln_amount5))||'</CTe5>'||gc_eol
                                  ||'<CTe6>'||htmlspchar(cnv_str(ln_amount6))||'</CTe6>'||gc_eol
                                  ||'<CTe7>'||htmlspchar(cnv_str(ln_amount7))||'</CTe7>'||gc_eol
                                  ||'<CTe8>'||htmlspchar(cnv_str(ln_amount8))||'</CTe8>'||gc_eol
                                  ||'<CTe9>'||htmlspchar(cnv_str(ln_amount9))||'</CTe9>'||gc_eol
                                  ||'<CTe10>'||htmlspchar(cnv_str(ln_amount10))||'</CTe10>'||gc_eol
                                  ||'<CTd1>'||htmlspchar(cnv_str(ln_amount_dct1))||'</CTd1>'||gc_eol
                                  ||'<CTd2>'||htmlspchar(cnv_str(ln_amount_dct2))||'</CTd2>'||gc_eol
                                  ||'<CTd3>'||htmlspchar(cnv_str(ln_amount_dct3))||'</CTd3>'||gc_eol
                                  ||'<CTd4>'||htmlspchar(cnv_str(ln_amount_dct4))||'</CTd4>'||gc_eol
                                  ||'<CTd5>'||htmlspchar(cnv_str(ln_amount_dct5))||'</CTd5>';

hr_utility.trace ('Phase7 ...');

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;

      FOR seque in 1 .. 10
      LOOP
      OPEN  cur_wl_wrk_hours_days(l_mag_asg_action_id,seque);
      FETCH cur_wl_wrk_hours_days INTO lr_wl_wrk_hours_days;
      CLOSE cur_wl_wrk_hours_days;

          l_common_xml := l_common_xml||'<Di1-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.TYPE))||'</Di1-'||seque||'>'||gc_eol
                                      ||'<Di2-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.ITEM_ID))||'</Di2-'||seque||'>'||gc_eol
                                      ||'<Di3-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.ITEM_TYPE))||'</Di3-'||seque||'>'||gc_eol
                                      ||'<Di4-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.ITEM_REP_NAME))||'</Di4-'||seque||'>'||gc_eol
                                      ||'<Di5-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.ITEM_REP_SEQ))||'</Di5-'||seque||'>'||gc_eol
                                      ||'<Di6-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION1))||'</Di6-'||seque||'>'||gc_eol
                                      ||'<Di7-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION2))||'</Di7-'||seque||'>'||gc_eol
                                      ||'<Di8-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION3))||'</Di8-'||seque||'>'||gc_eol
                                      ||'<Di9-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION4))||'</Di9-'||seque||'>'||gc_eol
                                      ||'<Di10-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION5))||'</Di10-'||seque||'>'||gc_eol
                                      ||'<Di11-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION6))||'</Di11-'||seque||'>'||gc_eol
                                      ||'<Di12-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION7))||'</Di12-'||seque||'>'||gc_eol
                                      ||'<Di13-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION8))||'</Di13-'||seque||'>'||gc_eol
                                      ||'<Di14-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION9))||'</Di14-'||seque||'>'||gc_eol
                                      ||'<Di15-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION10))||'</Di15-'||seque||'>'||gc_eol
                                      ||'<Di16-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION11))||'</Di16-'||seque||'>'||gc_eol
                                      ||'<Di17-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.INFORMATION12))||'</Di17-'||seque||'>'||gc_eol
                                      --||'<Di18-'||seque||'>'||htmlspchar(cnv_str(lr_wl_wrk_hours_days.TOTAL))||'</Di18-'||seque||'>';
                                      ||'<Di18-'||seque||'>'||htmlspchar(cnv_str(NVL(lr_wl_wrk_hours_days.INFORMATION1,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION2,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION3,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION4,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION5,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION6,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION7,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION8,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION9,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION10,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION11,0)
                                                                                +NVL(lr_wl_wrk_hours_days.INFORMATION12,0)))||'</Di18-'||seque||'>'; -- added by rdarasi for Bug #8815036

      lr_wl_wrk_hours_days := NULL;
      END LOOP;

hr_utility.trace ('Phase8 ...');

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      l_common_xml := null;

      seque := 1;

      OPEN  cur_wl_dec_dep_info(l_mag_asg_action_id);
      FETCH cur_wl_dec_dep_info INTO lr_wl_dec_dep_info;
      CLOSE cur_wl_dec_dep_info;

      l_common_xml := '<E1>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.PERSON_ID))||'</E1>'||gc_eol
                    ||'<E2>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.EXISTENCE_OF_DECLARATION))||'</E2>'||gc_eol
                    ||'<E3>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.EXISTENCE_OF_SPOUSE))||'</E3>'||gc_eol
                    ||'<E4>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.GENERALLY_QUALIFIED_SPOUSE))||'</E4>'||gc_eol
                    ||'<E5>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.ELDERLY_QUALIFIED_SPOUSE))||'</E5>'||gc_eol
                    ||'<E6>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.GENERAL_DEPENDENTS))||'</E6>'||gc_eol
                    ||'<E7>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.SPECIFIC_DEPENDENTS))||'</E7>'||gc_eol
                    ||'<E8>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.ELDER_DEPENDENTS_LIV_TOGETHER))||'</E8>'||gc_eol
                    ||'<E9>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.ELDER_DEPENDENTS_OTHERS))||'</E9>'||gc_eol
                    ||'<E10>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.GENERAL_DISABLED))||'</E10>'||gc_eol
                    ||'<E11>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.SPECIAL_DISABLED))||'</E11>'||gc_eol
                    ||'<E12>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.SPECIAL_DISABLED_LIV_TOGETHER))||'</E12>'||gc_eol
                    ||'<E13>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.AGED))||'</E13>'||gc_eol
                    ||'<E14>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.WIDOW))||'</E14>'||gc_eol
                    ||'<E15>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.WORKING_STUDENT))||'</E15>'||gc_eol
                    ||'<E16>'||htmlspchar(cnv_str(lr_wl_dec_dep_info.DEPENDENT_INFO_SEC_SOURCE))||'</E16>';
hr_utility.trace ('Phase9 ...');

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      lr_wl_dec_dep_info := NULL;
      l_common_xml       := null;

      seque := 1;

      OPEN  cur_wl_pre_emp(l_mag_asg_action_id);
      LOOP
      FETCH cur_wl_pre_emp INTO lr_wl_pre_emp;
      EXIT WHEN cur_wl_pre_emp%NOTFOUND;

      l_common_xml := l_common_xml||'<G'||seque||'-1>'||htmlspchar(cnv_str(lr_wl_pre_emp.PERSON_ID))||'</G'||seque||'-1>'||gc_eol
                                  ||'<G'||seque||'-2>'||htmlspchar(cnv_str(lr_wl_pre_emp.PREVIOUS_COMPANY))||'</G'||seque||'-2>'||gc_eol
                                  ||'<G'||seque||'-3>'||htmlspchar(cnv_str(lr_wl_pre_emp.EMPLOYER_ADDRESS_KANA))||'</G'||seque||'-3>'||gc_eol
                                  ||'<G'||seque||'-4>'||htmlspchar(cnv_str(lr_wl_pre_emp.TAXABLE_INCOME))||'</G'||seque||'-4>'||gc_eol
                                  ||'<G'||seque||'-5>'||htmlspchar(cnv_str(lr_wl_pre_emp.SOCIAL_INSURANCE_PREMIUM))||'</G'||seque||'-5>'||gc_eol
                                  ||'<G'||seque||'-6>'||htmlspchar(cnv_str(lr_wl_pre_emp.MUTUAL_AID_PREM))||'</G'||seque||'-6>'||gc_eol
                                  ||'<G'||seque||'-7>'||htmlspchar(cnv_str(lr_wl_pre_emp.WITHHOLDING_TAX))||'</G'||seque||'-7>'||gc_eol
                                  ||'<G'||seque||'-8>'||htmlspchar(cnv_str(lr_wl_pre_emp.RETIREMENT_DATE))||'</G'||seque||'-8>';
      seque := seque + 1;

      END LOOP;
      CLOSE cur_wl_pre_emp;

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;


      lr_wl_pre_emp := NULL;
      l_common_xml  := NULL;

      OPEN  cur_wl_yea_info(l_mag_asg_action_id);
      FETCH cur_wl_yea_info INTO lr_wl_yea_info;
      CLOSE cur_wl_yea_info;
-- added below on 17/09/09
      IF lr_wl_yea_info.person_id IS NULL THEN
        ln_total_earnings_per_bon := NULL;
      END IF;
-- added above on 17/09/09

      IF lr_wl_yea_info.SAL_TAX IS NULL AND lr_wl_yea_info.BON_TAX IS NULL
      THEN
        total := NULL;
      ELSE
        total := NVL(lr_wl_yea_info.SAL_TAX,0) + NVL(lr_wl_yea_info.BON_TAX,0);
      END IF;

      l_common_xml := '<Y1>'||htmlspchar(cnv_str(lr_wl_yea_info.PERSON_ID))||'</Y1>'||gc_eol
                    ||'<Y2>'||htmlspchar(cnv_str(lr_wl_yea_info.SAL_AMT))||'</Y2>'||gc_eol    -- commented by rdarasi for Bug #8815036
                    --||'<Y2>'||htmlspchar(cnv_str(ln_total_earnings_per_month))||'</Y2>'||gc_eol -- added by rdarasi for Bug #8815036
                    --||'<Y3>'||htmlspchar(cnv_str(lr_wl_yea_info.BON_AMT))||'</Y3>'||gc_eol    -- commented by rdarasi for Bug #8815036
                    ||'<Y3>'||htmlspchar(cnv_str(ln_total_earnings_per_bon))||'</Y3>'||gc_eol  -- added by rdarasi for Bug #8815036
                    ||'<Y3T>'||htmlspchar(cnv_str(NVL(ln_total_earnings_per_month,0) + NVL(ln_total_earnings_per_bon,0)))||'</Y3T>'||gc_eol
                    ||'<Y4>'||htmlspchar(cnv_str(lr_wl_yea_info.TAXABLE_INCOME))||'</Y4>'||gc_eol
                    ||'<Y5>'||htmlspchar(cnv_str(lr_wl_yea_info.SAL_TAX))||'</Y5>'||gc_eol
                    ||'<Y6>'||htmlspchar(cnv_str(lr_wl_yea_info.BON_TAX))||'</Y6>'||gc_eol
                    ||'<Y5T>'||htmlspchar(cnv_str(total))||'</Y5T>'||gc_eol -- added on 08/09/09
                    ||'<Y7>'||htmlspchar(cnv_str(lr_wl_yea_info.NET_INCOME))||'</Y7>'||gc_eol
                    ||'<Y8>'||htmlspchar(cnv_str(lr_wl_yea_info.SI_DEDUCTION))||'</Y8>'||gc_eol
                    ||'<Y9>'||htmlspchar(cnv_str(lr_wl_yea_info.SI_PREM))||'</Y9>'||gc_eol
                    ||'<Y10>'||htmlspchar(cnv_str(lr_wl_yea_info.DEP_EXEMPTION))||'</Y10>'||gc_eol
                    ||'<Y11>'||htmlspchar(cnv_str(lr_wl_yea_info.LI_PREM))||'</Y11>'||gc_eol
                    ||'<Y12>'||htmlspchar(cnv_str(lr_wl_yea_info.EI_PREM))||'</Y12>'||gc_eol
                    ||'<Y13>'||htmlspchar(cnv_str(lr_wl_yea_info.SPOUSE_SP_EXEMPT))||'</Y13>'||gc_eol
                    ||'<Y14>'||htmlspchar(cnv_str(lr_wl_yea_info.SPOUSE_INCOME))||'</Y14>'||gc_eol
                    ||'<Y15>'||htmlspchar(cnv_str(lr_wl_yea_info.PP_PREM))||'</Y15>'||gc_eol
                    ||'<Y16>'||htmlspchar(cnv_str(lr_wl_yea_info.LONG_TERM_AI_PREM))||'</Y16>'||gc_eol
                    ||'<Y17>'||htmlspchar(cnv_str(lr_wl_yea_info.MUTUAL_AID_PREM))||'</Y17>'||gc_eol
                    ||'<Y17-1>'||htmlspchar(cnv_str(lr_wl_yea_info.MUTUAL_AID_PREM))||'</Y17-1>'||gc_eol
                    ||'<Y18>'||htmlspchar(cnv_str(lr_wl_yea_info.NPI_PREMIUM))||'</Y18>'||gc_eol
                    ||'<Y19>'||htmlspchar(cnv_str(lr_wl_yea_info.HOUSING_LOAN_DEDUCTION))||'</Y19>'||gc_eol
                    ||'<Y20>'||htmlspchar(cnv_str(lr_wl_yea_info.YEA_ANNUAL_TAX))||'</Y20>'||gc_eol
                    ||'<Y21>'||htmlspchar(cnv_str(lr_wl_yea_info.OVER_AND_SHORT_TAX))||'</Y21>'||gc_eol
                    ||'<Y22>'||htmlspchar(cnv_str(lr_wl_yea_info.DEP_SPOUSE_EXEMPTION))||'</Y22>'||gc_eol
                    ||'<Y23>'||htmlspchar(cnv_str(lr_wl_yea_info.DEPENDENT_EXEMPTION))||'</Y23>'||gc_eol
                    ||'<Y24>'||htmlspchar(cnv_str(lr_wl_yea_info.BASIS_EXEMPTION))||'</Y24>'||gc_eol
                    ||'<Y25>'||htmlspchar(cnv_str(lr_wl_yea_info.DEP_DISABLED_EXEMPTION))||'</Y25>'||gc_eol
                    ||'<Y26>'||htmlspchar(cnv_str(lr_wl_yea_info.TOTAL_SE_DE_BE_DISE))||'</Y26>'||gc_eol
                    ||'<Y27>'||htmlspchar(cnv_str(lr_wl_yea_info.TOTAL_INCOME_DEDUCTION))||'</Y27>'||gc_eol
                    ||'<Y28>'||htmlspchar(cnv_str(lr_wl_yea_info.NET_ASS_SAL_INCOME_MONEY))||'</Y28>'||gc_eol
                    ||'<Y29>'||htmlspchar(cnv_str(lr_wl_yea_info.CALCULATED_TAX))||'</Y29>';

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;

      lr_wl_yea_info := NULL;
      l_common_xml   := NULL;
-- added below on 18/09/09

      OPEN lcu_proc_info('MESG'
                        , gr_parameters.business_group_id
                        , gr_parameters.effective_date
                        );
      FETCH  lcu_proc_info INTO lr_proc_info;
      CLOSE  lcu_proc_info;
--
      IF lr_proc_info.org_information7 IS NOT NULL THEN

        l_common_xml := '<MESG>'||htmlspchar(cnv_str(lr_proc_info.org_information7))||'</MESG>'||gc_eol;

        l_xml :=gc_eol||l_common_xml||gc_eol;
        vXMLTable(gn_vctr).xmlstring := l_xml;
        gn_vctr := gn_vctr + 1;

      END IF;

      l_common_xml := NULL;

      OPEN lcu_proc_info('ADDINFO'
                        , gr_parameters.business_group_id
                        , gr_parameters.effective_date
                        );
      FETCH  lcu_proc_info INTO lr_proc_info;
      CLOSE  lcu_proc_info;
--
      IF  lr_proc_info.org_information4 IS NOT NULL THEN
--
      OPEN  cur_wl_extra_info(l_mag_asg_action_id);
      FETCH cur_wl_extra_info INTO lr_wl_extra_info;
      CLOSE cur_wl_extra_info;

      l_common_xml := '<X1>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION1))||'</X1>'||gc_eol
                    ||'<X2>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION2))||'</X2>'||gc_eol
                    ||'<X3>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION3))||'</X3>'||gc_eol
                    ||'<X4>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION4))||'</X4>'||gc_eol
                    ||'<X5>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION5))||'</X5>'||gc_eol
                    ||'<X6>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION6))||'</X6>'||gc_eol
                    ||'<X7>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION7))||'</X7>'||gc_eol
                    ||'<X8>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION8))||'</X8>'||gc_eol
                    ||'<X9>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION9))||'</X9>'||gc_eol
                    ||'<X10>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION10))||'</X10>'||gc_eol
                    ||'<X11>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION11))||'</X11>'||gc_eol
                    ||'<X12>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION12))||'</X12>'||gc_eol
                    ||'<X13>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION13))||'</X13>'||gc_eol
                    ||'<X14>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION14))||'</X14>'||gc_eol
                    ||'<X15>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION15))||'</X15>'||gc_eol
                    ||'<X16>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION16))||'</X16>'||gc_eol
                    ||'<X17>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION17))||'</X17>'||gc_eol
                    ||'<X18>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION18))||'</X18>'||gc_eol
                    ||'<X19>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION19))||'</X19>'||gc_eol
                    ||'<X20>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION20))||'</X20>'||gc_eol
                    ||'<X21>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION21))||'</X21>'||gc_eol
                    ||'<X22>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION22))||'</X22>'||gc_eol
                    ||'<X23>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION23))||'</X23>'||gc_eol
                    ||'<X24>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION24))||'</X24>'||gc_eol
                    ||'<X25>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION25))||'</X25>'||gc_eol
                    ||'<X26>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION26))||'</X26>'||gc_eol
                    ||'<X27>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION27))||'</X27>'||gc_eol
                    ||'<X28>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION28))||'</X28>'||gc_eol
                    ||'<X29>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION29))||'</X29>'||gc_eol
                    ||'<X30>'||htmlspchar(cnv_str(lr_wl_extra_info.ADDITIONAL_INFORMATION30))||'</X30>';
--
      hr_utility.trace ('Phase10 ...');
      l_xml :=gc_eol||l_common_xml||gc_eol;
      hr_utility.trace ('Phase11 ...');
--
--    Checking if additional message is entered by the user.
--    writing first part of xml to vXMLtable

         vXMLTable(gn_vctr).xmlstring := l_xml;
         gn_vctr := gn_vctr + 1;
hr_utility.trace ('Phase12 ...');
      END IF;
-- added above on 18/09/09

--
--
         lr_wl_extra_info := NULL;
         l_xml2 :='</wlrpt>'||gc_eol ;
hr_utility.trace ('Phase13 ...');
--
         vXMLTable(gn_vctr).xmlstring := l_xml2;
         gn_vctr := gn_vctr + 1;
hr_utility.trace ('Phase14 ...');
       END IF;
     lr_wl_emp := NULL;

     CLOSE cur_wl_emp;
--
     IF gb_debug
       THEN
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
    hr_utility.trace ('Phase of error1...');
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

  pay_archive.remove_report_actions(p_payroll_action_id);

END deinitialise;

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

END PAY_JP_WL_REPORT_PKG;

/
