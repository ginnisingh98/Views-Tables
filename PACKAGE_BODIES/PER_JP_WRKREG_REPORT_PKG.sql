--------------------------------------------------------
--  DDL for Package Body PER_JP_WRKREG_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_WRKREG_REPORT_PKG" 
-- $Header: pejpwrpt.pkb 120.1.12010000.25 2009/08/19 14:41:40 rdarasi noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pejpwrpt.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of per_jp_wrkreg_report_pkg
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   11-JUN-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * DATE        AUTHOR(S)   VERSION             BUG NO            DESCRIPTION
-- * -----------+-----------+-------------------+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- * 19-MAR-2009 MDARBHA     120.0.12010000.1    8558615             Creation
-- * 11-JUN-2009 MDARBHA     120.1.12010000.6    8558615             Changed as per review Comments
--*  24-JUN-2009 MDARBHA     120.1.12010000.10   8608463,8623767     Changed Procedure 'action_creation' for Organization Hierarchy as per the bug 8623767
--                                                                                                                             Changed Procedure 'assact_xml' for Job History
--* 01-JUL-2009 MDARBHA     120.1.12010000.11    8623733             Chnaged the 'action_creation' for Organization Hierarchy as per the bug 8623733
--*  12-JUL-2009 MDARBHA    120.1.12010000.12    8666468             Changed the procedure Assact XML to fetch the lookup meaning for Termination Reason and Death Cause
--*  12-JUL-2009 MDARBHA    120.1.12010000.12    8667163             Changed the procedure action creation to fetch the correct organzations if Organization Parameter is null
--                                                                                                                   Removed the code adedd for Bug 8623733 as not required as per Bug  8667163
--*  12-JUL-2009 MDARBHA    120.1.12010000.12    8667702             Changed the procedure Assact XML .Added space between Address Line1 ,Address Line2  and Address Line3.
--*  13-JUL-2009 MDARBHA    120.1.12010000.13    8679904             Changed action creation to consider future terminated employees.
--*  20-JUL-2009 MDARBHA    120.1.12010000.14    8686503             Changed the date format in Assact XML
--*  31-JUL-2009 MDARBHA    120.1.12010000.15    8691511             Changed the sort action cursor
--*  31-JUL-2009 MDARBHA    120.1.12010000.16    8691511             Changed the sort action cursor
--*  31-JUL-2009 MDARBHA    120.1.12010000.17    8721997             Changed the  action creation for rehired employees scenario
--*  31-JUL-2009 MDARBHA    120.1.12010000.18    8721997             Changed the action creation for rehired employees scenario
--*  31-JUL-2009 MDARBHA    120.1.12010000.19    8691511             Changed the sort action cursor
--*  04-AUG-2009 MDARBHA    120.1.12010000.20    8691511             Changed the sort action cursor
--*  13-AUG-2009 RDARASI    120.1.12010000.21    8774489             Changed the sort action Cursor
--*  14-AUG-2009 RDARASI    120.1.12010000.22    8774489             Changed the sort action Cursor
--*  19-AUG-2009 RDARASI    120.1.12010000.23    8814071             Changed the cur_wrk_reg_emp Cursor
-- *************************************************************************************************************************************************************
AS
--
  g_write_xml             CLOB;
  g_xfdf_string           CLOB;
  gc_eol                  VARCHAR2(5) := fnd_global.local_chr(10);
  gc_proc_name            VARCHAR2(240);
  gc_pkg_name             VARCHAR2(30):= 'per_jp_wrkreg_report_pkg.';
  gb_debug                BOOLEAN;
  gn_dummy                NUMBER := -99 ;
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
  SELECT fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ACTION_ID',legislative_parameters)) payroll_action_id
         ,fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASS_SETID',legislative_parameters))        ass_setid
         ,pay_core_utils.get_parameter('BG',legislative_parameters)                                               business_group_id
         ,NVL(pay_core_utils.get_parameter('IOH',legislative_parameters),'Y')                                     include_org_hierarchy
         ,pay_core_utils.get_parameter('ORG',legislative_parameters)                                              organization_id
         ,pay_core_utils.get_parameter('LOC',legislative_parameters)                                              location_id
         ,FND_DATE.canonical_to_date(pay_core_utils.get_parameter('EFFDATE',legislative_parameters))              effective_date
         ,NVL(pay_core_utils.get_parameter('S1',legislative_parameters),'ZZ')                                     sort_order_1
         ,NVL(pay_core_utils.get_parameter('S2',legislative_parameters),'ZZ')                                     sort_order_2
         ,NVL(pay_core_utils.get_parameter('S3',legislative_parameters),'ZZ')                                     sort_order_3
         ,pay_core_utils.get_parameter('ITE',legislative_parameters)                                              incl_term_emp
         ,TO_DATE(pay_core_utils.get_parameter('TEDF',legislative_parameters),'YYYY/MM/DD')                       term_eff_date_from
         ,TO_DATE(pay_core_utils.get_parameter('TEDT',legislative_parameters),'YYYY/MM/DD')                       term_eff_date_to
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
--
    SELECT TO_DATE(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')
    INTO gr_parameters.effective_date
    FROM pay_payroll_actions PPA
    WHERE PPA.payroll_action_id  = gr_parameters.payroll_action_id;
--
    IF gb_debug THEN
      hr_utility.set_location('p_payroll_action_id.........                   = ' || p_payroll_action_id,30);
      hr_utility.set_location('gr_parameters.payroll_action_id  . .           = ' || gr_parameters.payroll_action_id,30);
      hr_utility.set_location('gr_parameters. ass_setid...............  .     = ' || gr_parameters. ass_setid,30);
      hr_utility.set_location('gr_parameters.include_org_hierarchy  . .       = ' || gr_parameters.include_org_hierarchy,30);
      hr_utility.set_location('gr_parameters.organization_id...............  .= ' || gr_parameters.organization_id,30);
      hr_utility.set_location('gr_parameters.business_group_id.......         = ' || gr_parameters.business_group_id,30);
      hr_utility.set_location('gr_parameters.location_id.......               = ' || gr_parameters.location_id,30);
      hr_utility.set_location('gr_parameters.effective_date..........         = ' || gr_parameters.effective_date,30);
      hr_utility.set_location('gr_parameters.incl_term_emp......              = ' || gr_parameters.incl_term_emp,30);
      hr_utility.set_location('gr_parameters.term_eff_date_from......         = ' || gr_parameters.term_eff_date_from,30);
      hr_utility.set_location('gr_parameters.term_eff_date_to......           = ' || gr_parameters.term_eff_date_to,30);
      hr_utility.set_location('gr_parameters.sort_order_1......               = ' || gr_parameters.sort_order_1,30);
      hr_utility.set_location('gr_parameters.sort_order_2......               = ' || gr_parameters.sort_order_2,30);
      hr_utility.set_location('gr_parameters.sort_order_3......               = ' || gr_parameters.sort_order_3,30);

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
--
    lc_proc_name := gc_pkg_name ||'RANGE_CURSOR';
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
      hr_utility.trace ('Entering '||lc_proc_name);
      hr_utility.trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);
    END IF;
--
    initialize(p_payroll_action_id);
--
    p_sqlstr := ' select distinct p.person_id'||
                ' from   per_people_f p,'||
                ' pay_payroll_actions pa'||
                ' where  pa.payroll_action_id = :payroll_action_id'||
                ' and    p.business_group_id = pa.business_group_id'||
                ' order by p.person_id ';
    g_mag_payroll_action_id:=P_PAYROLL_ACTION_ID;
--
    IF gb_debug THEN
      hr_utility.trace ('Range cursor query : ' || p_sqlstr);
      hr_utility.trace ('Leaving '||lc_proc_name);
    END IF;
--
  END range_cursor;
--
  PROCEDURE sort_action( p_payroll_action_id   IN     NUMBER
                        ,sqlstr                IN OUT NOCOPY VARCHAR2
                        ,len                   OUT   NOCOPY NUMBER
                       )
  --************************************************************************
  -- PROCEDURE
  --  sort_action
  --
  -- DESCRIPTION
  --  This procedure sorts the assignments actions according to the user entered
  --  sort orders 1,2,3.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ------------------------------------
  -- p_payroll_action_id        IN             This parameter passes payroll_action_id object
  -- sqlstr                                 IN OUT    This parameter returns the SQL Statement
  --  len                                    OUT          This parameter returns the length of the SQL Statement
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
--     Bug 8691511
    sqlstr :=  ' SELECT PAA.rowid
                 FROM per_assignments_f         PAF
                     ,pay_assignment_actions    PAA
                     ,per_people_f              PPF
                     ,hr_all_organization_units_tl HAOUT
                     ,hr_all_organization_units  HAOU
                     ,per_periods_of_service    PPS
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
                 /*AND   ((   NVL('''||gr_parameters.incl_term_emp||''',''N'')       = ''Y''
                          AND(  PPS.actual_termination_date IS NULL
                           OR (TRUNC(PPS.actual_termination_date)  BETWEEN '''||gr_parameters.term_eff_date_from||'''
                                                                       AND '''||gr_parameters.term_eff_date_to||''')
                        )
                        )
                        OR
                        (   NVL('''||gr_parameters.incl_term_emp||''',''N'')       = ''N''
                        AND PPS.actual_termination_date IS NULL
                        )
                       )*/
                 ORDER BY DECODE('''||gr_parameters.sort_order_1||''',''EMPLOYEE_NAME'',UPPER(PPF.last_name || '' '' || PPF.first_name)  -- changed by RDARASI for BUG# 8774489
                                                  ,''ORGANIZATION_CODE'',UPPER(HAOUT.name)              -- Added UPPER by RDARASI for BUG# 8774489
                                                                        ,UPPER(PPF.employee_number)     -- Added UPPER by RDARASI for BUG# 8774489
                                )
                         ,DECODE('''||gr_parameters.sort_order_2||''',''EMPLOYEE_NAME'',UPPER(PPF.last_name || '' '' || PPF.first_name) -- changed by RDARASI for BUG# 8774489
                                                  ,''ORGANIZATION_CODE'',UPPER(HAOUT.name)              -- Added UPPER by RDARASI for BUG# 8774489
                                                                        ,UPPER(PPF.employee_number)     -- Added UPPER by RDARASI for BUG# 8774489
                                )
                         ,DECODE('''||gr_parameters.sort_order_3||''',''EMPLOYEE_NAME'',UPPER(PPF.last_name || '' '' || PPF.first_name) -- changed by RDARASI for BUG# 8774489
                                                  ,''ORGANIZATION_CODE'',UPPER(HAOUT.name)              -- Added UPPER by RDARASI for BUG# 8774489
                                                                        ,UPPER(PPF.employee_number)     -- Added UPPER by RDARASI for BUG# 8774489
                                )';
--Bug 8691511
    len := length(sqlstr); -- return the length of the string.
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
  CURSOR lcu_assact_r( p_payroll_action_id_arch  pay_payroll_actions.payroll_action_id%TYPE
                   ,p_business_group_id  per_assignments_f.business_group_id%TYPE
                   ,p_organization_id    per_assignments_f.organization_id%TYPE
                   ,p_location_id        per_assignments_f.location_id%TYPE
                   ,p_effective_date     DATE
                   ,p_term_eff_date_from DATE
                   ,p_term_eff_date_to DATE
                   ,p_include_term_flag VARCHAR2
                    )
  IS
  SELECT PJWREV.assignment_id
         ,PJWREV.effective_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,per_jp_wrkreg_emp_v      PJWREV
        ,per_periods_of_service   PPOF
        ,pay_population_ranges    PPR
        ,pay_payroll_actions      PPA
        ,hr_all_organization_units  HAOU
  WHERE PAA.person_id                        = PAP.person_id
  AND   PPA.payroll_action_id                = PPR.payroll_action_id
  AND   PPA.payroll_action_id                = p_payroll_action_id
  AND   PPR.chunk_number                     = p_chunk
  AND   PPR.person_id                        = PAP.person_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   HAOU.organization_id                 = PAA.organization_id
  AND   PAS.payroll_action_id                = p_payroll_action_id_arch
  AND   PPOF.person_id                       = PAP.person_id
  AND   PJWREV.assignment_action_id          = PAS.assignment_action_id
  AND   PJWREV.assignment_id                 = PAS.assignment_id
  AND   PAA.business_group_id                = p_business_group_id
  AND   PAA.organization_id                  = NVL(p_organization_id,PAA.organization_id)
  AND   NVL(PAA.location_id,0)               = NVL(p_location_id,NVL( PAA.location_id,0))
  AND   PAA.primary_flag                     = 'Y'
   AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAP.effective_start_date
                                                               AND PAP.effective_end_date
   AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAA.effective_start_date
                                                               AND PAA.effective_end_date
   AND   ((   NVL(p_include_term_flag,'N')        = 'Y'
          AND(  (PJWREV.terminate_flag       = 'C'
                     AND ((PPOF.actual_termination_date IS NULL AND p_effective_date > = PPOF.DATE_START)
                         OR (PPOF.actual_termination_date > = p_effective_date  AND p_effective_date > = PPOF.DATE_START )))
             OR ( PJWREV.terminate_flag        = 'T'
                         AND TRUNC(PPOF.actual_termination_date)  BETWEEN p_term_eff_date_from
                                                          AND p_term_eff_date_to)
              )
          )
         OR
          (  NVL(p_include_term_flag,'N')                     = 'N'
                      AND PJWREV.terminate_flag       = 'C'
              AND ((PPOF.actual_termination_date IS NULL AND p_effective_date > = PPOF.DATE_START)
                             OR (PPOF.actual_termination_date > = p_effective_date      AND p_effective_date > = PPOF.DATE_START ))
          )
        );
--
  CURSOR lcu_assact( p_payroll_action_id_arch  pay_payroll_actions.payroll_action_id%TYPE
                   ,p_business_group_id  per_assignments_f.business_group_id%TYPE
                   ,p_organization_id    per_assignments_f.organization_id%TYPE
                   ,p_location_id        per_assignments_f.location_id%TYPE
                   ,p_effective_date     DATE
                   ,p_term_eff_date_from DATE
                   ,p_term_eff_date_to DATE
                   ,p_include_term_flag VARCHAR2
                   )
  IS
  SELECT PJWREV.assignment_id
        ,PJWREV.effective_date
  FROM   per_assignments_f        PAA
        ,per_people_f             PAP
        ,pay_assignment_actions   PAS
        ,per_jp_wrkreg_emp_v      PJWREV
        ,per_periods_of_service   PPOF
        ,hr_all_organization_units  HAOU
  WHERE PAA.person_id                        = PAP.person_id
  AND   PAA.person_id                  BETWEEN p_start_person_id
                                           AND p_end_person_id
  AND   PAS.assignment_id                    = PAA.assignment_id
  AND   PAS.payroll_action_id                = p_payroll_action_id_arch
  AND   PPOF.person_id                       = PAP.person_id
  AND   PJWREV.assignment_action_id          = PAS.assignment_action_id
  AND   PJWREV.assignment_id                  = PAS.assignment_id
  AND   HAOU.organization_id                  = PAA.organization_id
  AND   PAA.business_group_id                = p_business_group_id
  AND   PAA.organization_id                  = NVL(p_organization_id,PAA.organization_id)
  AND   NVL(PAA.location_id,0)               = NVL(p_location_id,NVL( PAA.location_id,0))
  AND   PAA.primary_flag                     = 'Y'
  AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAP.effective_start_date
                                                              AND PAP.effective_end_date
  AND   NVL(TRUNC(PPOF.actual_termination_date),p_effective_date) BETWEEN PAA.effective_start_date
                                                              AND PAA.effective_end_date
  AND   ((   NVL(p_include_term_flag,'N')        = 'Y'
         AND(  (PJWREV.terminate_flag       = 'C'
                    AND ((PPOF.actual_termination_date IS NULL AND p_effective_date > = PPOF.DATE_START)
                        OR (PPOF.actual_termination_date > = p_effective_date   AND p_effective_date > = PPOF.DATE_START )))
            OR ( PJWREV.terminate_flag        = 'T'
                        AND TRUNC(PPOF.actual_termination_date)  BETWEEN p_term_eff_date_from
                                                         AND p_term_eff_date_to)
             )
         )
        OR
         (  NVL(p_include_term_flag,'N')                     = 'N'
                     AND PJWREV.terminate_flag       = 'C'
             AND ((PPOF.actual_termination_date IS NULL AND p_effective_date > = PPOF.DATE_START)
                            OR (PPOF.actual_termination_date > = p_effective_date       AND p_effective_date > = PPOF.DATE_START ))
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
--
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
      lt_org_id := per_jp_report_common_pkg.get_org_hirerachy(p_business_group_id     => gr_parameters.business_group_id
                                                              ,p_organization_id       => gr_parameters.organization_id
                                                              ,p_include_org_hierarchy => gr_parameters.include_org_hierarchy
                                                              );
       FOR i in 1..lt_org_id.COUNT
         LOOP
--
           IF range_person_on THEN
--                                 Range person is enabled
             IF gb_debug THEN
               hr_utility.set_location('Inside Range person if condition',20);
             END IF;
--                                Assignment Action for Current and Terminated Employees
             FOR lr_assact IN lcu_assact_r(ln_old_pact_id
                                         ,gr_parameters.business_group_id
                                         ,lt_org_id(i)
                                         ,gr_parameters.location_id
                                         ,gr_parameters.effective_date
                                         ,gr_parameters.term_eff_date_from
                                         ,gr_parameters.term_eff_date_to
                                         ,gr_parameters.incl_term_emp
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
                   ELSE
                         -- Range person is not enabled
             IF gb_debug THEN
               hr_utility.set_location('Range person returns false',20);
                             hr_utility.set_location(ln_old_pact_id,20);
                                   hr_utility.set_location(lt_org_id(i),20);
             END IF;
             --        Assignment Action for Current and Terminated Employe
               FOR lr_assact IN lcu_assact(ln_old_pact_id
                                           ,gr_parameters.business_group_id
                                           ,lt_org_id(i)
                                           ,gr_parameters.location_id
                                           ,gr_parameters.effective_date
                                           ,gr_parameters.term_eff_date_from
                                           ,gr_parameters.term_eff_date_to
                                           ,gr_parameters.incl_term_emp
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
        ELSE--Org id is null
          IF range_person_on THEN
        -- Assignment Action for Current and Terminated Employees
             IF gb_debug THEN
           hr_utility.set_location('Inside Range person if condition',20);
         END IF;
--         Assignment Action for Current and Terminated Employees
--
         FOR lr_assact IN lcu_assact_r(ln_old_pact_id
                                      ,gr_parameters.business_group_id
                                      ,null
                                      ,gr_parameters.location_id
                                      ,gr_parameters.effective_date
                                      ,gr_parameters.term_eff_date_from
                                      ,gr_parameters.term_eff_date_to
                                      ,gr_parameters.incl_term_emp
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
--
          ELSE
        IF gb_debug THEN
          hr_utility.set_location('Range person returns false',20);
        END IF;
        --        Assignment Action for Current and Terminated Employe
--
          FOR lr_assact IN lcu_assact(ln_old_pact_id
                                      ,gr_parameters.business_group_id
                                      ,null
                                      ,gr_parameters.location_id
                                      ,gr_parameters.effective_date
                                      ,gr_parameters.term_eff_date_from
                                      ,gr_parameters.term_eff_date_to
                                      ,gr_parameters.incl_term_emp
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
    IF gb_debug
      THEN
        hr_utility.trace ('inside INIT_CODE ');
        END IF;
--
        g_mag_payroll_action_id:=p_payroll_action_id;
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
  --Bug #8667702.Added space for Address Line1,Address Line2,Address Line3
  CURSOR cur_wrk_reg_emp(p_mag_asg_action_id NUMBER
                        )
  IS
  SELECT  PJWREV.FULL_NAME_KANA
         ,PJWREV.FULL_NAME_KANJI
         ,PJWREV.DATE_OF_BIRTH
         ,DECODE(PJWREV.GENDER,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'SEX' AND lookup_code= PJWREV.GENDER)) GENDER
         ,SUBSTR(PJWREV.POSTAL_CODE,1,3)||NVL2(PJWREV.POSTAL_CODE,'-',' ')|| SUBSTR(PJWREV.POSTAL_CODE,4)  POSTAL_CODE  -- added by rdarasi for Bug #8814071
         ,PJWREV.ADDRESS_LINE1||' '||pjwrev.ADDRESS_LINE2||' '||pjwrev.ADDRESS_LINE3 Address
         ,PJWREV.REGION1||PJWREV.REGION2||PJWREV.REGION3   Address_kana
         ,PJWREV.KIND_OF_BUSINESS
         ,PJWREV.HIRE_DATE
         ,PJWREV.TERMINATION_DATE
         ,DECODE(PJWREV.TERMINATION_REASON,NULL,NULL,(SELECT meaning FROM hr_lookups WHERE lookup_type = 'LEAV_REAS' AND lookup_code= PJWREV.TERMINATION_REASON)) TERMINATION_REASON
         ,PJWREV.DATE_OF_DEATH
         ,PJWREV.EMPLOYEE_NUMBER
         ,PJWREV.EFFECTIVE_DATE
  FROM   per_jp_wrkreg_emp_v PJWREV
  WHERE  PJWREV.assignment_action_id = p_mag_asg_action_id;
  --
  wrk_reg_emp_c cur_wrk_reg_emp%ROWTYPE;
  --
  --Cursor to pick the Job history of an employee
  CURSOR cur_wrk_reg_job_hist_emp(p_mag_asg_action_id NUMBER
                                 )
  IS
  SELECT PJWRGHV.POSITION
        ,PJWRGHV.JOB
        ,PJWRGHV.START_DATE
        ,DECODE(PJWRGHV.END_DATE,TO_DATE('12/31/4712','mm/dd/yyyy'),null,PJWRGHV.END_DATE) END_DATE
        ,PJWRGHV.ORGANIZATION
  FROM  per_jp_wrkreg_job_v PJWRGHV
  WHERE PJWRGHV.assignment_action_id = p_mag_asg_action_id
  ORDER BY PJWRGHV.START_DATE DESC,PJWRGHV.END_DATE DESC;
--
--Cursor to pick the Previous Job History of an Employee
  CURSOR cur_wrk_reg_prev_job_hist(p_mag_asg_action_id NUMBER
                                  )
  IS
  SELECT PJWPJV.COMPANY_NAME
        ,PJWPJV.START_DATE
        ,PJWPJV.END_DATE
        ,PJWPJV.JOB
  FROM  per_jp_wrkreg_prev_job_v PJWPJV
  WHERE pjwpjv.assignment_action_id = p_mag_asg_action_id
  ORDER BY PJWPJV.START_DATE DESC,PJWPJV.END_DATE DESC;
--
--Cursor to pick the additional information
  CURSOR cur_wrk_add_info(p_mag_asg_action_id NUMBER
                        )
  IS
  SELECT PJWRAI.ADDITIONAL_INFORMATION1
         ,PJWRAI.ADDITIONAL_INFORMATION2
         ,PJWRAI.ADDITIONAL_INFORMATION3
         ,PJWRAI.ADDITIONAL_INFORMATION4
         ,PJWRAI.ADDITIONAL_INFORMATION5
         ,PJWRAI.ADDITIONAL_INFORMATION6
         ,PJWRAI.ADDITIONAL_INFORMATION7
         ,PJWRAI.ADDITIONAL_INFORMATION8
         ,PJWRAI.ADDITIONAL_INFORMATION9
         ,PJWRAI.ADDITIONAL_INFORMATION10
         ,PJWRAI.ADDITIONAL_INFORMATION11
         ,PJWRAI.ADDITIONAL_INFORMATION12
         ,PJWRAI.ADDITIONAL_INFORMATION13
         ,PJWRAI.ADDITIONAL_INFORMATION14
         ,PJWRAI.ADDITIONAL_INFORMATION15
         ,PJWRAI.ADDITIONAL_INFORMATION16
         ,PJWRAI.ADDITIONAL_INFORMATION17
         ,PJWRAI.ADDITIONAL_INFORMATION18
         ,PJWRAI.ADDITIONAL_INFORMATION19
         ,PJWRAI.ADDITIONAL_INFORMATION20
         ,PJWRAI.ADDITIONAL_INFORMATION21
         ,PJWRAI.ADDITIONAL_INFORMATION22
         ,PJWRAI.ADDITIONAL_INFORMATION23
         ,PJWRAI.ADDITIONAL_INFORMATION24
         ,PJWRAI.ADDITIONAL_INFORMATION25
         ,PJWRAI.ADDITIONAL_INFORMATION26
         ,PJWRAI.ADDITIONAL_INFORMATION27
         ,PJWRAI.ADDITIONAL_INFORMATION28
         ,PJWRAI.ADDITIONAL_INFORMATION29
         ,PJWRAI.ADDITIONAL_INFORMATION30
  FROM   per_jp_wrkreg_extra_info_v  PJWRAI
  WHERE  PJWRAI.assignment_action_id = p_mag_asg_action_id;
 --
  wrk_reg_add_info  cur_wrk_add_info%ROWTYPE;
  --
  --Cursor to Check if the user has entered the Organization level additional information.
  CURSOR cur_wrk_org_add_info(p_info_type VARCHAR2
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
  AND    p_effective_date      BETWEEN  fnd_date.canonical_to_date(HOI.org_information5)
                                   AND  fnd_date.canonical_to_date(HOI.org_information6);
--
  wrk_reg_org_add_info  cur_wrk_org_add_info%ROWTYPE;
--
   --Variables-----
  l_xml                   CLOB;
  l_xml2                  CLOB;
  l_common_xml            CLOB;
  l_xml_begin             VARCHAR2(200);
  l_mag_asg_action_id pay_assignment_actions.assignment_action_id%TYPE;
  l_emp_no                VARCHAR2(80);
  l_job_hist_xml          CLOB ;
  l_additional_info_xml   CLOB;
  l_add_msg_xml           CLOB;
  l_cnt                   NUMBER;
  l_cnte                  NUMBER;
--Added for Job History for bug 8608463
  TYPE job_hist_type IS RECORD(position       per_positions.name%TYPE
                              ,job            per_jobs_tl.name %TYPE
                              ,organization   hr_organization_units.name%TYPE
                              ,start_date     per_assignments_f.effective_start_date%TYPE
                              ,end_date       per_assignments_f.effective_end_date%TYPE
                              );

  TYPE prev_job_hist_type IS RECORD(company_name  per_previous_employers.employer_name%TYPE
                                   ,start_date    per_assignments_f.effective_start_date%TYPE
                                   ,end_date      per_assignments_f.effective_end_date%TYPE
                                   ,job           per_jobs_tl.name %TYPE
                                   );
 TYPE gt_job_tbl IS TABLE of job_hist_type INDEX BY binary_integer;
 TYPE gt_prev_job_tbl IS TABLE of prev_job_hist_type INDEX BY binary_integer;
 lt_job_tbl  gt_job_tbl;
 lt_prev_job_tbl gt_prev_job_tbl;
 l_index NUMBER;
 l_prev_job_count NUMBER;
 l_curr_job_count NUMBER;
--End for bug 8608463
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
    l_index:=0;
--
    IF gb_debug THEN
      hr_utility.trace('wrkreg_xml');
    END IF;
--
    l_mag_asg_action_id :=p_assignment_action_id;
--
    initialize(g_mag_payroll_action_id);
--
--  Fetching the employee details.
    OPEN cur_wrk_reg_emp(l_mag_asg_action_id
                        );
    FETCH cur_wrk_reg_emp INTO wrk_reg_emp_c;
--
    IF cur_wrk_reg_emp%FOUND THEN
--
      l_xml_begin := '<wrkreg>'||gc_eol;
      vXMLTable(gn_vctr).xmlstring :=  l_xml_begin;
      gn_vctr := gn_vctr + 1;
--
      l_common_xml := '<c1>' ||htmlspchar(cnv_str(wrk_reg_emp_c.FULL_NAME_KANA))||'</c1>' ||gc_eol --Full Name Kana
                    ||'<c2>'||htmlspchar(cnv_str(wrk_reg_emp_c.FULL_NAME_KANJI))||'</c2>' ||gc_eol --Full Name Kanji
                    ||'<c3>' ||htmlspchar(cnv_str(wrk_reg_emp_c.KIND_OF_BUSINESS))||'</c3>' ||gc_eol --Kind of Employ Business
                    ||'<c4_m>'||TO_CHAR(wrk_reg_emp_c.DATE_OF_BIRTH,'yyyy-mm-dd')||TO_CHAR(wrk_reg_emp_c.DATE_OF_BIRTH,'hh:mm:ss-HH:MM')||'</c4_m>' ||gc_eol -- Date Of Birth --For Bug 8608463  ,8686503
                    ||'<c4_d>'||TO_CHAR(wrk_reg_emp_c.DATE_OF_BIRTH,'yyyy-mm-dd')||TO_CHAR(wrk_reg_emp_c.DATE_OF_BIRTH,'hh:mm:ss-HH:MM')||'</c4_d>' ||gc_eol
                    ||'<c4_era>'||TO_CHAR(wrk_reg_emp_c.DATE_OF_BIRTH, 'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</c4_era>' ||gc_eol -- Date Of Birth Era Format --For Bug 8608463
                    ||'<c5>' ||htmlspchar(cnv_str(wrk_reg_emp_c.GENDER)) ||'</c5>' ||gc_eol --Gender
                    ||'<c6>' ||htmlspchar(cnv_str(wrk_reg_emp_c.POSTAL_CODE)) ||'</c6>' ||gc_eol --Postal Code
                    ||'<c7>' ||htmlspchar(cnv_str(wrk_reg_emp_c.Address)) ||'</c7>' ||gc_eol --Address
                    ||'<c8>' ||htmlspchar(cnv_str(wrk_reg_emp_c.Address_Kana)) ||'</c8>' ||gc_eol --Address Kana
                    ||'<c9_m>' ||TO_CHAR(wrk_reg_emp_c.HIRE_DATE,'yyyy-mm-dd')||TO_CHAR(wrk_reg_emp_c.HIRE_DATE,'hh:mm:ss-HH:MM')||'</c9_m>' ||gc_eol --Hire Date --For Bug 8608463 ,   8686503
                    ||'<c9_d>' ||TO_CHAR(wrk_reg_emp_c.HIRE_DATE,'yyyy-mm-dd')||TO_CHAR(wrk_reg_emp_c.HIRE_DATE,'hh:mm:ss-HH:MM')||'</c9_d>' ||gc_eol
                    ||'<c9_era>'||TO_CHAR(wrk_reg_emp_c.HIRE_DATE,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</c9_era>'||gc_eol; -- Hire DateEra Format  --For Bug 8608463
--
      IF  wrk_reg_emp_c.DATE_OF_DEATH IS NULL THEN
        l_common_xml := l_common_xml
                        ||'<c10_m>' ||TO_CHAR(wrk_reg_emp_c.TERMINATION_DATE,'yyyy-mm-dd')||TO_CHAR(wrk_reg_emp_c.TERMINATION_DATE,'hh:mm:ss-HH:MM') ||'</c10_m>' ||gc_eol --For Bug 8608463  , 8686503
                        ||'<c10_d>' ||TO_CHAR(wrk_reg_emp_c.TERMINATION_DATE,'yyyy-mm-dd')||TO_CHAR(wrk_reg_emp_c.TERMINATION_DATE,'hh:mm:ss-HH:MM') ||'</c10_d>' ||gc_eol
                        ||'<c10_era>'||TO_CHAR(wrk_reg_emp_c.TERMINATION_DATE, 'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</c10_era>' ||gc_eol -- Termination DateEra Format  --For Bug 8608463
                        ||'<c11>' ||htmlspchar(cnv_str(wrk_reg_emp_c.TERMINATION_REASON)) ||'</c11>' ||gc_eol;
      ELSE
        l_common_xml := l_common_xml
                        ||'<c10_m>' ||TO_CHAR(wrk_reg_emp_c.DATE_OF_DEATH,'yyyy-mm-dd')||TO_CHAR(wrk_reg_emp_c.DATE_OF_DEATH,'hh:mm:ss-HH:MM') ||'</c10_m>' ||gc_eol  --For Bug 8608463  ,      8686503
                        ||'<c10_d>' ||TO_CHAR(wrk_reg_emp_c.DATE_OF_DEATH,'yyyy-mm-dd')||TO_CHAR(wrk_reg_emp_c.DATE_OF_DEATH,'hh:mm:ss-HH:MM') ||'</c10_d>' ||gc_eol  --For Bug 8608463  ,      8686503
                        ||'<c10_era>'||TO_CHAR(wrk_reg_emp_c.DATE_OF_DEATH,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</c10_era>' ||gc_eol -- Date Of Death Era Format  --For Bug 8608463
                        ||'<c11></c11>'||gc_eol;
      END IF;
--
      l_common_xml := l_common_xml||'<c12_m>' ||TO_CHAR(wrk_reg_emp_c.EFFECTIVE_DATE,'yyyy-mm-dd') ||TO_CHAR(wrk_reg_emp_c.EFFECTIVE_DATE,'hh:mm:ss-HH:MM')||'</c12_m>' ||gc_eol --For Bug 8608463  ,   8686503
                      ||'<c12_d>' ||TO_CHAR(wrk_reg_emp_c.EFFECTIVE_DATE,'yyyy-mm-dd') ||TO_CHAR(wrk_reg_emp_c.EFFECTIVE_DATE,'hh:mm:ss-HH:MM')||'</c12_d>' ||gc_eol --For Bug 8608463  ,   8686503
                      ||'<c12_era>'||TO_CHAR(wrk_reg_emp_c.EFFECTIVE_DATE,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</c12_era>' ||gc_eol -- Effective Date --For Bug 8608463
                      ||'<c13>' ||htmlspchar(cnv_str(wrk_reg_emp_c.EMPLOYEE_NUMBER)) ||'</c13>' ||gc_eol;
--
      l_cnt:=1;
--
--    Added for job history in bug 8608463
      FOR lr_prev_job  IN cur_wrk_reg_prev_job_hist(l_mag_asg_action_id)
      LOOP
        IF cur_wrk_reg_prev_job_hist%ROWCOUNT<4 THEN
          l_index:=l_index+1;
          lt_prev_job_tbl(l_index).company_name:=lr_prev_job.COMPANY_NAME;
          lt_prev_job_tbl(l_index).start_date:=lr_prev_job.START_DATE;
          lt_prev_job_tbl(l_index).end_date:=lr_prev_job.END_DATE;
          lt_prev_job_tbl(l_index).job:=lr_prev_job.JOB;
        END IF;
      END LOOP;
--
      l_prev_job_count:=l_index;
--
      IF l_index <> 0 THEN
        FOR i IN REVERSE 1..l_index
        LOOP
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'_m>'||TO_CHAR(lt_prev_job_tbl(i).start_date,'yyyy-mm-dd')
                                        ||TO_CHAR(lt_prev_job_tbl(i).start_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_m>'||gc_eol
                                        ||'<cj'||l_cnt||'_d>'||TO_CHAR(lt_prev_job_tbl(i).start_date,'yyyy-mm-dd')
                                                                                ||TO_CHAR(lt_prev_job_tbl(i).start_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_d>'||gc_eol
                                        ||'<cj'||l_cnt||'_era>'||'*'||TO_CHAR(lt_prev_job_tbl(i).start_date,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</cj'||l_cnt||'_era>'||gc_eol;
          l_cnt:=l_cnt+1;
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'_m>'||TO_CHAR(lt_prev_job_tbl(i).end_date,'yyyy-mm-dd')
                                        ||TO_CHAR(lt_prev_job_tbl(i).end_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_m>'||gc_eol
                                        ||'<cj'||l_cnt||'_d>'||TO_CHAR(lt_prev_job_tbl(i).end_date,'yyyy-mm-dd')
                                                                                ||TO_CHAR(lt_prev_job_tbl(i).end_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_d>'||gc_eol
                                        ||'<cj'||l_cnt||'_era>'||TO_CHAR(lt_prev_job_tbl(i).end_date,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</cj'||l_cnt||'_era>'||gc_eol;
          l_cnt:=l_cnt+1;
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||htmlspchar(cnv_str(lt_prev_job_tbl(i).company_name))||'</cj'||l_cnt||'>'||gc_eol;
          l_cnt:=l_cnt+1;
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||htmlspchar(cnv_str(lt_prev_job_tbl(i).job))||'</cj'||l_cnt||'>'||gc_eol;
          l_cnt:=l_cnt+1;
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||'</cj'||l_cnt||'>'||gc_eol;
          l_cnt:=l_cnt+1;
        END LOOP;
      END IF;
--
      IF l_prev_job_count<3 THEN
        l_curr_job_count:=8-(l_prev_job_count);
      ELSE
        l_curr_job_count:=5;
      END IF;
--
      l_index:=0;
      FOR lr_job_hist  IN cur_wrk_reg_job_hist_emp(l_mag_asg_action_id
                                                  )
      LOOP
        l_index:=l_index+1;
        lt_job_tbl(l_index).job:=lr_job_hist.JOB;
        lt_job_tbl(l_index).position:=lr_job_hist.POSITION;
        lt_job_tbl(l_index).organization:=lr_job_hist.ORGANIZATION;
        lt_job_tbl(l_index).start_date:=lr_job_hist.START_DATE;
        lt_job_tbl(l_index).end_date:=lr_job_hist.END_DATE;
      END LOOP;
--
      IF (l_index<5 OR (l_index < l_curr_job_count)) AND (l_index <> 0) THEN
        FOR i IN REVERSE 1..l_index
        LOOP
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'_m>'||TO_CHAR(lt_job_tbl(i).start_date,'yyyy-mm-dd')
                                        ||TO_CHAR(lt_job_tbl(i).start_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_m>'||gc_eol
                                        ||'<cj'||l_cnt||'_d>'||TO_CHAR(lt_job_tbl(i).start_date,'yyyy-mm-dd')
                                                                                ||TO_CHAR(lt_job_tbl(i).start_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_d>'||gc_eol
                                        ||'<cj'||l_cnt||'_era>'||' '||TO_CHAR(lt_job_tbl(i).start_date,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</cj'||l_cnt||'_era>'||gc_eol;
          l_cnt:=l_cnt+1;
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'_m>'||TO_CHAR(lt_job_tbl(i).end_date,'yyyy-mm-dd')
                                        ||TO_CHAR(lt_job_tbl(i).end_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_m>'||gc_eol
                                        ||'<cj'||l_cnt||'_d>'||TO_CHAR(lt_job_tbl(i).end_date,'yyyy-mm-dd')
                                                                                ||TO_CHAR(lt_job_tbl(i).end_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_d>'||gc_eol
                                        ||'<cj'||l_cnt||'_era>'||TO_CHAR(lt_job_tbl(i).end_date,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</cj'||l_cnt||'_era>'||gc_eol;
          l_cnt:=l_cnt+1;
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||htmlspchar(cnv_str(lt_job_tbl(i).organization))||'</cj'||l_cnt||'>'||gc_eol;
          l_cnt:=l_cnt+1;
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||htmlspchar(cnv_str(lt_job_tbl(i).job))||'</cj'||l_cnt||'>'||gc_eol;
          l_cnt:=l_cnt+1;
          l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||htmlspchar(cnv_str(lt_job_tbl(i).position))||'</cj'||l_cnt||'>'||gc_eol;
          l_cnt:=l_cnt+1;
        END LOOP;
      ELSE
        IF (l_index <> 0) THEN
          FOR i IN REVERSE 1..l_curr_job_count
          LOOP
            l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'_m>'||TO_CHAR(lt_job_tbl(i).start_date,'yyyy-mm-dd')
                                          ||TO_CHAR(lt_job_tbl(i).start_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_m>'||gc_eol
                                          ||'<cj'||l_cnt||'_d>'||TO_CHAR(lt_job_tbl(i).start_date,'yyyy-mm-dd')
                                                                                  ||TO_CHAR(lt_job_tbl(i).start_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_d>'||gc_eol
                                          ||'<cj'||l_cnt||'_era>'||' '||TO_CHAR(lt_job_tbl(i).start_date,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</cj'||l_cnt||'_era>'||gc_eol;
            l_cnt:=l_cnt+1;
            l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'_m>'||TO_CHAR(lt_job_tbl(i).end_date,'yyyy-mm-dd')
                                          ||TO_CHAR(lt_job_tbl(i).end_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_m>'||gc_eol
                                          ||'<cj'||l_cnt||'_d>'||TO_CHAR(lt_job_tbl(i).end_date,'yyyy-mm-dd')
                                                                                  ||TO_CHAR(lt_job_tbl(i).end_date,'hh:mm:ss-HH:MM')||'</cj'||l_cnt||'_d>'||gc_eol
                                          ||'<cj'||l_cnt||'_era>'||TO_CHAR(lt_job_tbl(i).end_date,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</cj'||l_cnt||'_era>'||gc_eol;
            l_cnt:=l_cnt+1;
            l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||htmlspchar(cnv_str(lt_job_tbl(i).organization))||'</cj'||l_cnt||'>'||gc_eol;
            l_cnt:=l_cnt+1;
            l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||htmlspchar(cnv_str(lt_job_tbl(i).job))||'</cj'||l_cnt||'>'||gc_eol;
            l_cnt:=l_cnt+1;
            l_job_hist_xml:=l_job_hist_xml||'<cj'||l_cnt||'>'||htmlspchar(cnv_str(lt_job_tbl(i).position))||'</cj'||l_cnt||'>'||gc_eol;
            l_cnt:=l_cnt+1;
          END LOOP;
          l_cnte:=1;
          FOR i IN REVERSE  ( l_curr_job_count+1)..l_index
          LOOP
            l_job_hist_xml:=l_job_hist_xml||'<cje'||l_cnte||'_m>'||TO_CHAR(lt_job_tbl(i).start_date,'yyyy-mm-dd')
                                          ||TO_CHAR(lt_job_tbl(i).start_date,'hh:mm:ss-HH:MM')||'</cje'||l_cnte||'_m>'||gc_eol
                                          ||'<cje'||l_cnte||'_d>'||TO_CHAR(lt_job_tbl(i).start_date,'yyyy-mm-dd')
                                                                                  ||TO_CHAR(lt_job_tbl(i).start_date,'hh:mm:ss-HH:MM')||'</cje'||l_cnte||'_d>'||gc_eol
                                          ||'<cje'||l_cnte||'_era>'||TO_CHAR(lt_job_tbl(i).start_date,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</cje'||l_cnte||'_era>'||gc_eol;
            l_cnte:=l_cnte+1;
            l_job_hist_xml:=l_job_hist_xml||'<cje'||l_cnte||'_m>'||TO_CHAR(lt_job_tbl(i).end_date,'yyyy-mm-dd')
                                          ||TO_CHAR(lt_job_tbl(i).end_date,'hh:mm:ss-HH:MM')||'</cje'||l_cnte||'_m>'||gc_eol
                                          ||'<cje'||l_cnte||'_d>'||TO_CHAR(lt_job_tbl(i).end_date,'yyyy-mm-dd')
                                                                                  ||TO_CHAR(lt_job_tbl(i).end_date,'hh:mm:ss-HH:MM')||'</cje'||l_cnte||'_d>'||gc_eol
                                          ||'<cje'||l_cnte||'_era>'||TO_CHAR(lt_job_tbl(i).end_date,'EEYY','NLS_CALENDAR=''Japanese Imperial''')||'</cje'||l_cnte||'_era>'||gc_eol;
            l_cnte:=l_cnte+1;
            l_job_hist_xml:=l_job_hist_xml||'<cje'||l_cnte||'>'||htmlspchar(cnv_str(lt_job_tbl(i).organization))||'</cje'||l_cnte||'>'||gc_eol;
            l_cnte:=l_cnte+1;
            l_job_hist_xml:=l_job_hist_xml||'<cje'||l_cnte||'>'||htmlspchar(cnv_str(lt_job_tbl(i).job))||'</cje'||l_cnte||'>'||gc_eol;
            l_cnte:=l_cnte+1;
            l_job_hist_xml:=l_job_hist_xml||'<cje'||l_cnte||'>'||htmlspchar(cnv_str(lt_job_tbl(i).position))||'</cje'||l_cnte||'>'||gc_eol;
            l_cnte:=l_cnte+1;
          END LOOP;
        END IF;
      END IF;
--End For for bug 8608463
      l_common_xml:=l_common_xml||l_job_hist_xml;
--
      l_xml :=gc_eol||l_common_xml||gc_eol;
--
--    Checking if additional message is entered by the user.
      OPEN cur_wrk_org_add_info('MESG'
                                ,gr_parameters.business_group_id
                                ,gr_parameters.effective_date
                               );
      FETCH  cur_wrk_org_add_info into wrk_reg_org_add_info;
      CLOSE  cur_wrk_org_add_info;

      IF wrk_reg_org_add_info.org_information7 IS NOT NULL THEN
        l_add_msg_xml:='<m>'||htmlspchar(cnv_str(wrk_reg_org_add_info.org_information7))||'</m>'||gc_eol;
        l_xml :=l_xml||gc_eol||l_add_msg_xml||gc_eol;
      END IF;
--    Checking if Additional Information is entered by the user.
      OPEN cur_wrk_org_add_info(   'ADDINFO'
                                   ,gr_parameters.business_group_id
                                   ,gr_parameters.effective_date);
      FETCH  cur_wrk_org_add_info into wrk_reg_org_add_info;
      CLOSE  cur_wrk_org_add_info;

      IF  wrk_reg_org_add_info.org_information4 IS NOT NULL THEN
        OPEN cur_wrk_add_info(    l_mag_asg_action_id
                             );
        FETCH  cur_wrk_add_info into wrk_reg_add_info;
        CLOSE  cur_wrk_add_info;

        l_additional_info_xml:='<x1>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION1))||'</x1>' ||gc_eol||
                               '<x2>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION2))||'</x2>'||gc_eol||
                               '<x3>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION3))||'</x3>' ||gc_eol||
                               '<x4>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION4))||'</x4>'||gc_eol||
                               '<x5>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION5))||'</x5>' ||gc_eol||
                               '<x6>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION6))||'</x6>'||gc_eol||
                               '<x7>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION7))||'</x7>' ||gc_eol||
                               '<x8>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION8))||'</x8>' ||gc_eol||
                               '<x9>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION9))||'</x9>'||gc_eol||
                               '<x10>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION10))||'</x10>' ||gc_eol||
                               '<x11>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION11))||'</x11>' ||gc_eol||
                               '<x12>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION12))||'</x12>'||gc_eol||
                               '<x13>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION13))||'</x13>' ||gc_eol||
                               '<x14>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION14))||'</x14>'||gc_eol||
                               '<x15>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION15))||'</x15>' ||gc_eol||
                               '<x16>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION16))||'</x16>'||gc_eol||
                               '<x17>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION17))||'</x17>' ||gc_eol||
                               '<x18>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION18))||'</x18>' ||gc_eol||
                               '<x19>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION19))||'</x19>'||gc_eol||
                               '<x20>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION20))||'</x20>' ||gc_eol||
                               '<x21>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION21))||'</x21>' ||gc_eol||
                               '<x22>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION22))||'</x22>'||gc_eol||
                               '<x23>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION23))||'</x23>' ||gc_eol||
                               '<x24>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION24))||'</x24>'||gc_eol||
                               '<x25>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION25))||'</x25>' ||gc_eol||
                               '<x26>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION26))||'</x26>'||gc_eol||
                               '<x27>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION27))||'</x27>' ||gc_eol||
                               '<x28>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION28))||'</x28>' ||gc_eol||
                               '<x29>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION29))||'</x29>'||gc_eol||
                               '<x30>'||htmlspchar(cnv_str(wrk_reg_add_info.ADDITIONAL_INFORMATION30))||'</x30>';

             l_xml :=l_xml||gc_eol||l_additional_info_xml||gc_eol;
         END IF;
--                    writing first part of xml to vXMLtable
         vXMLTable(gn_vctr).xmlstring := l_xml;
         gn_vctr := gn_vctr + 1;
--
         l_xml2 :='</wrkreg>'||gc_eol ;
--
         vXMLTable(gn_vctr).xmlstring := l_xml2;
         gn_vctr := gn_vctr + 1;
       END IF;
     CLOSE cur_wrk_reg_emp;
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
    IF gb_debug
      THEN
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
    IF gb_debug
      THEN
        hr_utility.set_location('Out of loop ', 99);
        END IF;
--
    dbms_lob.close(g_xfdf_string);
    IF gb_debug
      THEN
        hr_utility.trace('Leaving WRITETOCLOB');
    END IF;
--
 EXCEPTION
     WHEN gc_exception THEN
           IF gb_debug
         THEN
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
    IF gb_debug
      THEN
        hr_utility.trace('Entering GET_CP_XML');
        END IF;
--
    assact_xml(p_assignment_action_id);
    writetoclob (p_xml);
--
        IF gb_debug
      THEN
        hr_utility.trace('Leaving GET_CP_XML');
        END IF;
--
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
--
    SELECT PAA1.assignment_action_id
    INTO   ln_old_assact_id
    FROM   pay_assignment_actions PAA,
           pay_assignment_actions PAA1
    WHERE  PAA.assignment_action_id = ln_cur_assact
    AND    PAA.assignment_id        = PAA1.assignment_id
    AND    PAA1.payroll_action_id   = ln_pact_id;
--
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
    vxmltable.DELETE; -- delete the pl/sql table
--
    --lc_buf := '<:1xml version="1.0" encoding="UTF-8":2>'||gc_eol ;
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
PROCEDURE deinitialise (p_payroll_action_id IN NUMBER)
IS
--
  BEGIN
--
 --pay_archive.remove_report_actions(p_payroll_action_id);
 null;
--
END deinitialise;

END per_jp_wrkreg_report_pkg;

/
