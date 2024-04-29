--------------------------------------------------------
--  DDL for Package Body PAY_JP_IWHT_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_IWHT_REPORT_PKG" AS
-- $Header: pyjpiwrt.pkb 120.0.12010000.8 2010/05/13 07:00:58 mpothala noship $
-- **************************************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.                         *
-- * All rights reserved                                                                            *
-- **************************************************************************************************
-- *                                                                                                *
-- * PROGRAM NAME                                                                                   *
-- *  PAY_JP_IWHT_REPORT_PKG.pks                                                                    *
-- *                                                                                                *
-- * DESCRIPTION                                                                                    *
-- * This script creates the package specification of PAY_JP_IWHT_REPORT_PKG.                       *
-- *                                                                                                *
-- * USAGE                                                                                          *
-- *   To install       sqlplus <apps_user>/<apps_pwd> @PAYJPIWHTREPORTPKG.pkb                      *
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_IWHT_REPORT_PKG<procedure name>  *
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
-- * Concurrent Program Japan, Withholding Income Tax Report for Termination Income                 *
-- *                                                                                                *
-- * LAST UPDATE DATE                                                                               *
-- *   Date the program has been modified for the last time                                         *
-- *                                                                                                *
-- * HISTORY                                                                                        *
-- * =======                                                                                        *
-- *                                                                                                *
-- * VERSION                DATE         AUTHOR(S)             DESCRIPTION                          *
-- * -------             -----------  ----------------      ----------------------------            *
-- *  Draft               24/02/2010    RDARASI               Intial                                *
-- *  120.0.12010000.8    12/05/2010    MPOTHALA              Fixed Assignment set issue            *
-- **************************************************************************************************
--
  g_write_xml             CLOB;
  g_xfdf_string           CLOB;
  gc_eol                  VARCHAR2(5) := fnd_global.local_chr(10);
  gc_proc_name            VARCHAR2(240);
  gc_pkg_name             VARCHAR2(30):= 'PAY_JP_IWHT_REPORT_PKG.';
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
  PROCEDURE get_values  ( p_input      IN               NUMBER
                        , p_output1    OUT   NOCOPY     VARCHAR2
                        , p_output2    OUT   NOCOPY     VARCHAR2
                        , p_output3    OUT   NOCOPY     VARCHAR2
                        )
  --************************************************************************
  -- PROCEDURE
  --  get_values
  --
  -- DESCRIPTION
  --  This is used to split the values into 3 digit numbers
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ------------------------------------
  -- p_input                    IN
  -- p_output1                  OUT
  -- p_output2                  OUT
  -- p_output3                  OUT
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  AS
    lc_proc_name             VARCHAR2(100);
    ln_input                 NUMBER;
    lc_input                 VARCHAR2(10);
    ln_output1               NUMBER;
    ln_output2               NUMBER;
    ln_output3               NUMBER;
  BEGIN
--
    lc_proc_name := gc_pkg_name ||'GET_VALUES';
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.trace ('Entering '||lc_proc_name);
    END IF;
    ln_input := TO_NUMBER(p_input,'999999999');
    lc_input := TO_CHAR(ln_input);

    IF (length(lc_input) < 3) THEN
      p_output3 := ln_input;

      IF ln_input = 0 THEN
        p_output3 := NULL;
      END IF;

    ELSE
      p_output3 := SUBSTR(lc_input,-3);
    END IF;

    ln_output1 := MOD(ln_input,1000);
    ln_input := ln_input - ln_output1;
    ln_input := ln_input/1000;
    lc_input := TO_CHAR(ln_input);

    IF (length(lc_input) < 3) THEN
      p_output2 := ln_input;

      IF ln_input = 0 THEN
        p_output2 := NULL;
      END IF;

    ELSE
      p_output2 := SUBSTR(ln_input,-3);
    END IF;

    ln_output2 := MOD(ln_input,1000);
    ln_input := ln_input - ln_output2;
    ln_input := ln_input/1000;
    lc_input := TO_CHAR(ln_input);

    IF (length(lc_input) < 3) THEN
      p_output1 := ln_input;

      IF ln_input = 0 THEN
        p_output1 := NULL;
      END IF;

    ELSE
      p_output1 := SUBSTR(ln_input,-3);
    END IF;

--    p_output3 := TO_CHAR(ln_output1);
--    p_output2 := TO_CHAR(ln_output2);
--    p_output1 := TO_CHAR(ln_output3);

--
    IF gb_debug THEN
      hr_utility.trace ('Leaving '||lc_proc_name);
    END IF;
--
  END get_values;


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
  SELECT  pay_core_utils.get_parameter('REP_GROUP',legislative_parameters)                                    rep_group
         ,pay_core_utils.get_parameter('REP_CAT',legislative_parameters)                                      rep_cat
         ,pay_core_utils.get_parameter('BG',legislative_parameters)                                           business_group_id
         ,TO_DATE(pay_core_utils.get_parameter('EFFDATE',legislative_parameters),'YYYY/MM/DD')                effective_date
         ,pay_core_utils.get_parameter('SUB',legislative_parameters)                                          subject_year
         ,pay_core_utils.get_parameter('ITWA',legislative_parameters)                                         withholding_agent
         ,pay_core_utils.get_parameter('SORT_ORDER',legislative_parameters)                                   sort_order
         ,TO_DATE(pay_core_utils.get_parameter('TEDF',legislative_parameters),'YYYY/MM/DD')                   termination_date_from
         ,TO_DATE(pay_core_utils.get_parameter('TEDT',legislative_parameters),'YYYY/MM/DD')                   termination_date_to
         ,pay_core_utils.get_parameter('ASS_SETID',legislative_parameters)                                    ass_setid
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

    IF gb_debug THEN
      hr_utility.set_location('gr_parameters.rep_group             = ' || gr_parameters.rep_group,30);
      hr_utility.set_location('gr_parameters.rep_cat               = ' || gr_parameters.rep_cat,30);
      hr_utility.set_location('gr_parameters.business_group_id     = ' || gr_parameters.business_group_id,30);
      hr_utility.set_location('gr_parameters.effective_date        = ' || gr_parameters.effective_date,30);
      hr_utility.set_location('gr_parameters.subject_year          = ' || gr_parameters.subject_year,30);
      hr_utility.set_location('gr_parameters.withholding_agent     = ' || gr_parameters.withholding_agent,30);
      hr_utility.set_location('gr_parameters.sort_order            = ' || gr_parameters.sort_order,30);
      hr_utility.set_location('gr_parameters.termination_date_from = ' || gr_parameters.termination_date_from,30);
      hr_utility.set_location('gr_parameters.termination_date_to   = ' || gr_parameters.termination_date_to,30);
      hr_utility.set_location('gr_parameters.ass_setid             = ' || gr_parameters.ass_setid,30);
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
    ln_assignment_id           NUMBER;

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


    hr_utility.set_location ('ln_cur_assact.. '||ln_cur_assact,20);
    hr_utility.set_location ('ln_cur_pact... '||ln_cur_pact,20);
--

    SELECT assignment_id
    INTO   ln_assignment_id
    FROM   pay_assignment_actions PAA
    WHERE  PAA.assignment_action_id = ln_cur_assact;

  get_cp_xml(ln_assignment_id,l_final_xml_string);
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

  --
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
  CURSOR lcu_assact_r( p_business_group_id        per_assignments_f.business_group_id%TYPE
                     , p_subject_year             NUMBER
                     , p_withholding_agent        hr_all_organization_units_vl.organization_id%TYPE
                     , p_termination_date_from    DATE
                     , p_termination_date_to      DATE
                     )
  IS
  SELECT DISTINCT PJIWTV.assignment_id
        ,PJIWTV.term_payment_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,pay_jp_iwht_tax_v        PJIWTV
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
  AND   PJIWTV.assignment_action_id          = PAS.assignment_action_id
  AND   PJIWTV.assignment_id                 = PAS.assignment_id
  AND   PPR.chunk_number                     = p_chunk
  AND   PAA.business_group_id                = p_business_group_id
  AND   NVL(TRUNC(PPOF.actual_termination_date),PJIWTV.term_payment_date) BETWEEN PAP.effective_start_date
                                                                          AND PAP.effective_end_date
  AND   NVL(TRUNC(PPOF.actual_termination_date),PJIWTV.term_payment_date) BETWEEN PAA.effective_start_date
                                                                          AND PAA.effective_end_date
  AND   TO_CHAR(PJIWTV.term_payment_date,'YYYY') = p_subject_year
  AND   NVL(PAY_JP_IWHT_ARCH_PKG.get_with_hold_agent(PAA.assignment_id,PJIWTV.term_payment_date),-999) = NVL(p_withholding_agent,NVL(PAY_JP_IWHT_ARCH_PKG.get_with_hold_agent(PAA.assignment_id,PJIWTV.term_payment_date),-999))
  AND   ( TRUNC(PPOF.actual_termination_date) BETWEEN  NVL(p_termination_date_from,PPOF.actual_termination_date)
                                              AND      NVL(p_termination_date_to,PPOF.actual_termination_date)
           OR --PPOF.actual_termination_date IS NULL                                       -- commented for the bug #9527198
           (p_termination_date_from IS NULL AND p_termination_date_to IS NULL));
  --
  CURSOR lcu_assact( p_business_group_id        per_assignments_f.business_group_id%TYPE
                   , p_subject_year             NUMBER
                   , p_withholding_agent        hr_all_organization_units_vl.organization_id%TYPE
                   , p_termination_date_from    DATE
                   , p_termination_date_to      DATE
                   )
  IS
  SELECT DISTINCT PJIWTV.assignment_id
        ,PJIWTV.term_payment_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,pay_jp_iwht_tax_v        PJIWTV
        ,per_periods_of_service   PPOF
        ,hr_all_organization_units  HAOU
  WHERE PAA.person_id                        = PAP.person_id
  AND   PAA.person_id                       BETWEEN p_start_person_id
                                            AND     p_end_person_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   PPOF.person_id                       = PAP.person_id
  AND   PJIWTV.assignment_action_id          = PAS.assignment_action_id
  AND   PJIWTV.assignment_id                 = PAS.assignment_id
  AND   HAOU.organization_id                 = PAA.organization_id
  AND   PAA.business_group_id                = p_business_group_id
  AND   NVL(TRUNC(PPOF.actual_termination_date),PJIWTV.term_payment_date) BETWEEN PAP.effective_start_date
                                                                          AND PAP.effective_end_date
  AND   NVL(TRUNC(PPOF.actual_termination_date),PJIWTV.term_payment_date) BETWEEN PAA.effective_start_date
                                                                          AND PAA.effective_end_date
  AND   TO_CHAR(PJIWTV.term_payment_date,'YYYY') = p_subject_year
  AND   NVL(PAY_JP_IWHT_ARCH_PKG.get_with_hold_agent(PAA.assignment_id,PJIWTV.term_payment_date),-999) = NVL(p_withholding_agent,NVL(PAY_JP_IWHT_ARCH_PKG.get_with_hold_agent(PAA.assignment_id,PJIWTV.term_payment_date),-999))
  AND   ( TRUNC(PPOF.actual_termination_date) BETWEEN  NVL(p_termination_date_from,PPOF.actual_termination_date)
                                             AND      NVL(p_termination_date_to,PPOF.actual_termination_date)
           OR --PPOF.actual_termination_date IS NULL                                   -- commented for the bug #9527198
           (p_termination_date_from IS NULL AND p_termination_date_to IS NULL));
  --
  ln_assact                 pay_assignment_actions.assignment_action_id%TYPE ;
  lc_proc_name              VARCHAR2(60);
  lc_legislative_parameters VARCHAR2(2000);
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
    ln_ass_set_id  := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASS_SETID',lc_legislative_parameters));
--
    g_mag_payroll_action_id := p_payroll_action_id;
    gb_debug                := hr_utility.debug_enabled ;
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
      FOR lr_assact IN lcu_assact_r( gr_parameters.business_group_id
                                   , gr_parameters.subject_year
                                   , gr_parameters.withholding_agent
                                   , gr_parameters.termination_date_from
                                   , gr_parameters.termination_date_to
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
                                                                          ,p_effective_date    => lr_assact.term_payment_date
                                                                          ,p_populate_fs_flag  => 'Y'  -- #Bug No 9508028
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
      END IF;
      --        Assignment Action for Current and Terminated Employe
      FOR lr_assact IN lcu_assact ( gr_parameters.business_group_id
                                  , gr_parameters.subject_year
                                  , gr_parameters.withholding_agent
                                  , gr_parameters.termination_date_from
                                  , gr_parameters.termination_date_to
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
                                                                           ,p_effective_date    => lr_assact.term_payment_date
                                                                           ,p_populate_fs_flag  => 'Y'  -- #Bug No 9508028
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
      hr_utility.trace ('inside ARCHIVE_CODE ');
    END IF;
--
  END archive_code;
--
--
  PROCEDURE assact_xml (p_assignment_id  IN NUMBER)
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

  CURSOR cur_iwht_emp(p_assignment_id  NUMBER)
  IS
  SELECT PJIWEV.employee_number
       , PJIWEV.last_name_kana
       , PJIWEV.first_name_kana
       , PJIWEV.last_name
       , PJIWEV.first_name
       , PJIWEV.district_code
       , PJIWEV.address_line1
       , PJIWEV.address_line2
       , PJIWEV.address_line3
       , PJIWEV.district_code_1stjan
       , PJIWEV.address_line1_1stjan
       , PJIWEV.address_line2_1stjan
       , PJIWEV.address_line3_1stjan
       , TO_CHAR(PJIWEV.hire_date, 'EYY MM DD', 'NLS_CALENDAR=''Japanese Imperial''')                   HIRE_DATE
       , TO_CHAR(PJIWEV.hire_date, 'EYY', 'NLS_CALENDAR=''Japanese Imperial''')                         HIRE_DATE_YY
       , TO_CHAR(PJIWEV.hire_date, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')                          HIRE_DATE_MM
       , TO_CHAR(PJIWEV.hire_date, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')                          HIRE_DATE_DD
       , TO_CHAR(PJIWEV.termination_date, 'EYY MM DD', 'NLS_CALENDAR=''Japanese Imperial''')            TERMINATION_DATE
       , TO_CHAR(PJIWEV.termination_date, 'EYY', 'NLS_CALENDAR=''Japanese Imperial''')                  TERMINATION_DATE_YY
       , TO_CHAR(PJIWEV.termination_date, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')                   TERMINATION_DATE_MM
       , TO_CHAR(PJIWEV.termination_date, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')                   TERMINATION_DATE_DD
       , PJIWEV.service_years
       , PJIWEV.itax_organization_id
       , PJIWEV.employer_name
       , PJIWEV.employer_address_line1
       , PJIWEV.employer_address_line2
       , PJIWEV.employer_address_line3
       , PJIWEV.employer_phone_number
       , PJIWEV.description1
       , PJIWEV.description2
       , PJIWEV.assignment_action_id
  FROM   pay_jp_iwht_emp_v PJIWEV
  WHERE  PJIWEV.assignment_id = p_assignment_id;

  CURSOR cur_iwht_tax(p_assignment_id  NUMBER)
  IS
  SELECT PJIWTV.notification_submited
       , PJIWTV.termination_payment_amount
       , PJIWTV.with_holding_tax
       , PJIWTV.muncipal_tax
       , PJIWTV.prefectural_tax
       , (PJIWTV.termination_income_deduction/10000)                                                    TERMINATION_INCOME_DEDUCTION
       , TO_CHAR(PJIWTV.term_payment_date, 'EYY MM DD', 'NLS_CALENDAR=''Japanese Imperial''')           TERM_PAYMENT_DATE
       , TO_CHAR(PJIWTV.term_payment_date, 'YY', 'NLS_CALENDAR=''Japanese Imperial''')                  TERM_PAYMENT_DATE_YY
       , TO_CHAR(PJIWTV.term_payment_date, 'MM', 'NLS_CALENDAR=''Japanese Imperial''')                  TERM_PAYMENT_DATE_MM
       , TO_CHAR(PJIWTV.term_payment_date, 'DD', 'NLS_CALENDAR=''Japanese Imperial''')                  TERM_PAYMENT_DATE_DD
       , TO_CHAR(PJIWTV.date_earned, 'EYY MM DD', 'NLS_CALENDAR=''Japanese Imperial''')                 DATE_EARNED
  FROM   pay_jp_iwht_tax_v    PJIWTV
  WHERE  PJIWTV.assignment_id = p_assignment_id;

  --
  lr_iwht_emp             cur_iwht_emp%ROWTYPE;
  lr_iwht_tax             cur_iwht_tax%ROWTYPE;

   --Variables-----
  l_xml                   CLOB;
  l_xml2                  CLOB;
  l_common_xml            CLOB;
  l_xml_begin             VARCHAR2(200);
  seq                     NUMBER;
  seque                   NUMBER;
  l_mag_asg_action_id     pay_assignment_actions.assignment_action_id%TYPE;
  lc_value1               VARCHAR2(10);
  lc_value2               VARCHAR2(10);
  lc_value3               VARCHAR2(10);


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
--    l_mag_asg_action_id := p_assignment_action_id;
--
    l_mag_asg_action_id := NULL;
    initialize(g_mag_payroll_action_id);
--
--  Fetching the employee details.
    OPEN  cur_iwht_emp(p_assignment_id);
    FETCH cur_iwht_emp INTO lr_iwht_emp;

--
    IF (cur_iwht_emp%FOUND) THEN
--
      l_xml_begin := '<iwhtrpt>'||gc_eol;
      vXMLTable(gn_vctr).xmlstring :=  l_xml_begin;
      gn_vctr := gn_vctr + 1;
--
    FOR seq in 1 .. 4
    LOOP

      hr_utility.trace ('lr_iwht_emp.assignment_action_id '||lr_iwht_emp.assignment_action_id);

      OPEN  cur_iwht_tax(p_assignment_id);
      FETCH cur_iwht_tax INTO lr_iwht_tax;
      CLOSE cur_iwht_tax;

      IF (NVL(lr_iwht_tax.notification_submited,'N') = 'Y') THEN
        seque := 5;
      ELSE
        seque := 7;
      END IF;

      l_common_xml := '<A1-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_tax.term_payment_date))||'</A1-'|| seq ||'>'||gc_eol
                    ||'<A1-'|| seq ||'-YY>'||htmlspchar(cnv_str(lr_iwht_tax.term_payment_date_yy))||'</A1-'|| seq ||'-YY>'||gc_eol
                    ||'<A1-'|| seq ||'-MM>'||htmlspchar(cnv_str(lr_iwht_tax.term_payment_date_mm))||'</A1-'|| seq ||'-MM>'||gc_eol
                    ||'<A1-'|| seq ||'-DD>'||htmlspchar(cnv_str(lr_iwht_tax.term_payment_date_dd))||'</A1-'|| seq ||'-DD>'||gc_eol
                    ||'<A2-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.address_line1||lr_iwht_emp.address_line2||lr_iwht_emp.address_line3))||'</A2-'|| seq ||'>'||gc_eol                         -- changed as per the bug#9524757
                    ||'<A3-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.address_line1_1stjan||lr_iwht_emp.address_line2_1stjan||lr_iwht_emp.address_line3_1stjan))||'</A3-'|| seq ||'>'||gc_eol    -- changed as per the bug#9524757
                    ||'<A4-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.last_name_kana||' '||lr_iwht_emp.first_name_kana))||'</A4-'|| seq ||'>'||gc_eol
                    ||'<A5-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.last_name||' '||lr_iwht_emp.first_name))||'</A5-'|| seq ||'>'||gc_eol;
      get_values( lr_iwht_tax.termination_payment_amount
                , lc_value1
                , lc_value2
                , lc_value3);

      l_common_xml := l_common_xml||'<A'||seque||'-1-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_tax.termination_payment_amount))||'</A'||seque||'-1-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-1-1-'|| seq ||'>'||htmlspchar(cnv_str(lc_value1))||'</A'||seque||'-1-1-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-1-2-'|| seq ||'>'||htmlspchar(cnv_str(lc_value2))||'</A'||seque||'-1-2-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-1-3-'|| seq ||'>'||htmlspchar(cnv_str(lc_value3))||'</A'||seque||'-1-3-'|| seq ||'>'||gc_eol;
      lc_value1 := NULL;
      lc_value2 := NULL;
      lc_value3 := NULL;
      get_values( lr_iwht_tax.with_holding_tax
                , lc_value1
                , lc_value2
                , lc_value3);

-- added below by rdarasi for the bug #9554613
      IF (NVL(lr_iwht_tax.termination_payment_amount,0) <> 0)  THEN
        IF (NVL(lr_iwht_tax.with_holding_tax,0) = 0 )THEN
          lc_value3 := 0;
        END IF;
      END IF;
-- added above by rdarasi

      l_common_xml := l_common_xml||'<A'||seque||'-2-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_tax.with_holding_tax))||'</A'||seque||'-2-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-2-1-'|| seq ||'>'||htmlspchar(cnv_str(lc_value1))||'</A'||seque||'-2-1-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-2-2-'|| seq ||'>'||htmlspchar(cnv_str(lc_value2))||'</A'||seque||'-2-2-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-2-3-'|| seq ||'>'||htmlspchar(cnv_str(lc_value3))||'</A'||seque||'-2-3-'|| seq ||'>'||gc_eol;
      lc_value1 := NULL;
      lc_value2 := NULL;
      lc_value3 := NULL;
      get_values( lr_iwht_tax.muncipal_tax
                , lc_value1
                , lc_value2
                , lc_value3);

-- added below by rdarasi for the bug #9554613
      IF (NVL(lr_iwht_tax.termination_payment_amount,0) <> 0) THEN
        IF (NVL(lr_iwht_tax.muncipal_tax,0) = 0) THEN
          lc_value3 := 0;
        END IF;
      END IF;
-- added above by rdarasi

      l_common_xml := l_common_xml||'<A'||seque||'-3-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_tax.muncipal_tax))||'</A'||seque||'-3-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-3-1-'|| seq ||'>'||htmlspchar(cnv_str(lc_value1))||'</A'||seque||'-3-1-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-3-2-'|| seq ||'>'||htmlspchar(cnv_str(lc_value2))||'</A'||seque||'-3-2-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-3-3-'|| seq ||'>'||htmlspchar(cnv_str(lc_value3))||'</A'||seque||'-3-3-'|| seq ||'>'||gc_eol;
      lc_value1 := NULL;
      lc_value2 := NULL;
      lc_value3 := NULL;
      get_values( lr_iwht_tax.prefectural_tax
                , lc_value1
                , lc_value2
                , lc_value3);

-- added below by rdarasi for the bug #9554613
      IF (NVL(lr_iwht_tax.termination_payment_amount,0) <> 0) THEN
        IF (NVL(lr_iwht_tax.prefectural_tax,0) = 0) THEN
          lc_value3 := 0;
        END IF;
      END IF;
-- added above by rdarasi

      l_common_xml := l_common_xml||'<A'||seque||'-4-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_tax.prefectural_tax))||'</A'||seque||'-4-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-4-1-'|| seq ||'>'||htmlspchar(cnv_str(lc_value1))||'</A'||seque||'-4-1-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-4-2-'|| seq ||'>'||htmlspchar(cnv_str(lc_value2))||'</A'||seque||'-4-2-'|| seq ||'>'||gc_eol
                     ||'<A'||seque||'-4-3-'|| seq ||'>'||htmlspchar(cnv_str(lc_value3))||'</A'||seque||'-4-3-'|| seq ||'>'||gc_eol
                    ||'<A8-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_tax.termination_income_deduction))||'</A8-'|| seq ||'>'||gc_eol
                    ||'<A9-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.service_years))||'</A9-'|| seq ||'>'||gc_eol
                    ||'<A10-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.hire_date))||'</A10-'|| seq ||'>'||gc_eol
                    ||'<A10-'|| seq ||'_YY>'||htmlspchar(cnv_str(lr_iwht_emp.hire_date_yy))||'</A10-'|| seq ||'_YY>'||gc_eol
                    ||'<A10-'|| seq ||'_MM>'||htmlspchar(cnv_str(lr_iwht_emp.hire_date_mm))||'</A10-'|| seq ||'_MM>'||gc_eol
                    ||'<A10-'|| seq ||'_DD>'||htmlspchar(cnv_str(lr_iwht_emp.hire_date_dd))||'</A10-'|| seq ||'_DD>'||gc_eol
                    ||'<A11-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.termination_date))||'</A11-'|| seq ||'>'||gc_eol
                    ||'<A11-'|| seq ||'_YY>'||htmlspchar(cnv_str(lr_iwht_emp.termination_date_yy))||'</A11-'|| seq ||'_YY>'||gc_eol
                    ||'<A11-'|| seq ||'_MM>'||htmlspchar(cnv_str(lr_iwht_emp.termination_date_mm))||'</A11-'|| seq ||'_MM>'||gc_eol
                    ||'<A11-'|| seq ||'_DD>'||htmlspchar(cnv_str(lr_iwht_emp.termination_date_dd))||'</A11-'|| seq ||'_DD>'||gc_eol
                    ||'<A12-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.description1||lr_iwht_emp.description2))||'</A12-'|| seq ||'>'||gc_eol
                    ||'<A13-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.employer_address_line1||lr_iwht_emp.employer_address_line2||lr_iwht_emp.employer_address_line3))||'</A13-'|| seq ||'>'||gc_eol
                    ||'<A14-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.employer_name))||'</A14-'|| seq ||'>'||gc_eol
                    ||'<A15-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.employer_phone_number))||'</A15-'|| seq ||'>'||gc_eol
                    ||'<A21-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_emp.itax_organization_id))||'</A21-'|| seq ||'>'||gc_eol
                    ||'<T8-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_tax.date_earned))||'</T8-'|| seq ||'>'||gc_eol
                    ||'<YY-'|| seq ||'>'||htmlspchar(cnv_str(lr_iwht_tax.term_payment_date_yy))||'</YY-'|| seq ||'>'||gc_eol;

      lc_value1 := NULL;
      lc_value2 := NULL;
      lc_value3 := NULL;

      l_xml :=gc_eol||l_common_xml||gc_eol;
      vXMLTable(gn_vctr).xmlstring := l_xml;
      gn_vctr := gn_vctr + 1;
    END LOOP;

      lr_iwht_tax    := NULL;
      l_common_xml   := NULL;
      lr_iwht_emp    := NULL;

      l_xml2 :='</iwhtrpt>'||gc_eol ;
      vXMLTable(gn_vctr).xmlstring := l_xml2;
      gn_vctr := gn_vctr + 1;

    END IF;

    CLOSE cur_iwht_emp;
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
  PROCEDURE get_cp_xml(p_assignment_id           IN  NUMBER
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
--    assact_xml(p_assignment_action_id);
      assact_xml(p_assignment_id);
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
-- Added below for the Bug # 9569078
    IF (gr_parameters.sort_order = 'EMPLOYEE_NUMBER') THEN
      lc_order_by := 'UPPER(PPF.employee_number), PJIWEV.district_code' ;
    ELSE
      lc_order_by := 'PJIWEV.district_code,UPPER(PPF.employee_number)' ;
    END IF;
-- Added above for the Bug # 9569078

    sqlstr :=  ' SELECT PAA.rowid
                 FROM per_assignments_f             PAF
                     ,pay_assignment_actions        PAA
                     ,per_people_f                  PPF
                     ,hr_all_organization_units_tl  HAOUT
                     ,hr_all_organization_units     HAOU
                     ,per_periods_of_service        PPS
                     ,pay_jp_iwht_emp_v             PJIWEV
                     ,pay_jp_iwht_tax_v             PJIWTV
                 WHERE PAA.payroll_action_id         = :pactid
                 AND   PAF.assignment_id             = PAA.assignment_id
                 AND   PPF.person_id                 = PAF.person_id
                 AND   PAF.organization_id           = HAOU.organization_id
                 AND   HAOUT.organization_id         = HAOU.organization_id
                 AND   HAOUT.language                = USERENV(''LANG'')
                 AND   PPS.period_of_service_id      = PAF.period_of_service_id
                 AND   NVL(TRUNC(PPS.actual_termination_date),PJIWTV.term_payment_date) BETWEEN PPF.effective_start_date
                                                          AND PPF.effective_end_date
                 AND   NVL(TRUNC(PPS.actual_termination_date),PJIWTV.term_payment_date) BETWEEN PAF.effective_start_date
                                                          AND PAF.effective_end_date
                 AND   PJIWEV.assignment_id                 = PAA.assignment_id
                 AND   PJIWTV.assignment_id                 = PAA.assignment_id
                 ORDER BY '||lc_order_by; -- changed for the Bug# 9569078

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

END PAY_JP_IWHT_REPORT_PKG;

/
