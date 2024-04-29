--------------------------------------------------------
--  DDL for Package Body PAY_JP_WL_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_WL_ARCH_PKG" AS
-- $Header: payjpwlarchpkg.pkb 120.0.12010000.28 2009/11/06 11:26:56 mpothala noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  PAYJLWL.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of PAY_JP_WL_ARCH_PKG
-- *
-- * USAGE
-- *   To install       sqlplus <apps_user>/<apps_pwd> @PAYJPWLARCHPKG.pkb
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_WL_ARCH_PKG.<procedure name>
-- *
-- * PROGRAM LIST
-- * ==========
-- * NAME                 DESCRIPTION
-- * -----------------    --------------------------------------------------
-- * RANGE_CODE
-- * INITIALIZATION_CODE
-- * ASSIGNMENT_ACTION_CODE
-- * ARCHIVE_CODE
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   09-Aug-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * VERSION             DATE        AUTHOR(S)             DESCRIPTION
-- * ------- ----------- -----------------------------------------------------------
-- * 120.0.12010000.1  09-Aug-2009   MPOTHALA               Creation
-- * 120.0.12010000.2  11-Aug-2009   MPOTHALA               Updation
-- * 120.0.12010000.3  17-Aug-2009   MPOTHALA               Updation for bug 8805830
-- * 120.0.12010000.4  17-Aug-2009   MPOTHALA               Updation for bug 8805830
-- * 120.0.12010000.5  17-Aug-2009   MPOTHALA               Updation for bug 8805830
-- * 120.0.12010000.6  17-Aug-2009   MPOTHALA               Updation for bug 8805830
-- * 120.0.12010000.7  27-Aug-2009   MPOTHALA               Updation for bug 8805830
-- * 120.0.12010000.8  27-Aug-2009   MPOTHALA               Updation for bug 8830592
-- * 120.0.12010000.9  28-Aug-2009   MPOTHALA               Updation for bug 8830605
-- * 120.0.12010000.10 31-Aug-2009   MPOTHALA               Updation for bug 8830491
--                                                          and other related bugs
-- * 120.0.12010000.11 01-Sep-2009   MPOTHALA               Updation for bug 8858762
--                                                          and other related bugs
-- * 120.0.12010000.12 02-Sep-2009   MPOTHALA               Updation for bug 8858762
--                                                          and other related bugs
-- * 120.0.12010000.13 07-Sep-2009   MPOTHALA               Updation for bug 8830491
--                                                          and other related bugs
-- * 120.0.12010000.14 07-Sep-2009   MPOTHALA               Updation for bug 8869183
-- * 120.0.12010000.15 07-Sep-2009   MPOTHALA               Updation for bug 8874389
-- * 120.0.12010000.16 07-Sep-2009   MPOTHALA               Updation for bug 8865186
-- * 120.0.12010000.17 14-Sep-2009   MPOTHALA               Updation for bug 8883201
-- * 120.0.12010000.18 14-Sep-2009   MPOTHALA               Updation for bug 8883201
-- * 120.0.12010000.19 15-Sep-2009   MPOTHALA               Updation for bug 8883201
-- * 120.0.12010000.20 16-Sep-2009   MPOTHALA               Updation for bug 8911344
-- * 120.0.12010000.21 17-Sep-2009   MPOTHALA               Updation for bug 8915846
-- * 120.0.12010000.22 28-Sep-2009   keyazawa               bug fix 8897528, 8910016, 8914785, 8931394
-- * 120.0.12010000.23 29-Sep-2009   MPOTHALA               bug fix 8915846
-- * 120.0.12010000.24 09-Oct-2009   MPOTHALA               bug fix 8931518
-- * 120.0.12010000.25 15-Oct-2009   MPOTHALA               bug fix 9014185
-- * 120.0.12010000.26 21-Oct-2009   MPOTHALA               bug fix 8931350,8911281
-- * 120.0.12010000.27 21-Oct-2009   MPOTHALA               bug fix 9044516
-- * 120.0.12010000.28 04-Nov-2009	 MPOTHALA			bug fix 9031713
-- *********************************************************************************
  --Declaration of constant global variables
  --
  gc_package                  CONSTANT VARCHAR2(60) := 'PAY_JP_WL_ARCH_PKG.';
  --
  --  Global to store package name for tracing.
  --  Declaration of global variables
  gn_arc_payroll_action_id    pay_payroll_actions.payroll_action_id%type;
  gn_business_group_id        hr_all_organization_units.organization_id%type;
  gn_payroll_action_id        pay_payroll_actions.payroll_action_id%TYPE;
  gb_debug                    BOOLEAN;
  gd_end_date                 DATE;
  gd_start_date               DATE;
  --
  PROCEDURE RANGE_CODE ( p_payroll_action_id  IN         pay_payroll_actions.payroll_action_id%TYPE
                        ,p_sql                OUT NOCOPY VARCHAR2
                       )
  --***************************************************************************
  -- PROCEDURE
  --   RANGE_CODE
  --
  -- DESCRIPTION
  --   This procedure returns a sql string to select a range
  --  of assignments eligible for archival
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id         IN      This parameter passes Payroll Action Id.
  -- p_sql                       OUT     This parameter retunrs SQL Query.
  --
  -- PREREQUISITES
  --  None
  --
  -- CALLED BY
  --  None
  --*************************************************************************
  IS

  lc_procedure                VARCHAR2(200);

  BEGIN
    --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
     lc_procedure := gc_package||'RANGE_CODE';
     hr_utility.set_location('Entering '||lc_procedure,1);
    END IF ;
    -------------------------------------------------------------------------
    -- Archive the payroll action level data and EIT defintions.
    -- sql string to SELECT a range of assignments eligible for archival.
    -------------------------------------------------------------------------
    p_sql := ' SELECT distinct p.person_id'                             ||
             ' FROM   per_people_f p,'                                  ||
                    ' pay_payroll_actions pa'                           ||
             ' WHERE  pa.payroll_action_id = :payroll_action_id'        ||
             ' AND    p.business_group_id = pa.business_group_id'       ||
             ' ORDER BY p.person_id';
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    IF gb_debug THEN
      hr_utility.set_location(lc_procedure,10);
    END IF;
    --
  END RANGE_CODE;
  --
  PROCEDURE initialize ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE )
  --*************************************************************************
  -- PROCEDURE
  --   initialize
  --
  -- DESCRIPTION
  --   This procedure is used to set global contexts
  --
  -- ACCESS
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
  --  INITIALIZATION_CODE
  --*************************************************************************
  IS
  --
  CURSOR lcr_params(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
  --*************************************************************************
  --
  -- CURSOR lcr_params
  --
  -- DESCRIPTION
  --  Fetches User Parameters from legislative_paramters column.
  --
  -- PARAMETERS
  -- ==========
  -- NAME                TYPE     DESCRIPTION
  -------------------   -------- ---------------------------------------------
  -- p_payroll_action_id IN       This parameter passes the Payroll Action Id.
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   initialize procedure
  --
  --**********************************************************************
  IS
  SELECT pay_core_utils.get_parameter('BG',legislative_parameters)
        ,pay_core_utils.get_parameter('SUB',legislative_parameters)
        ,pay_core_utils.get_parameter('ASSSETID',legislative_parameters)
        ,pay_core_utils.get_parameter('PAY',legislative_parameters)
        ,pay_core_utils.get_parameter('WTH',legislative_parameters)
        ,pay_core_utils.get_parameter('ARCH',legislative_parameters)
        ,TO_DATE(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')
  FROM  pay_payroll_actions PPA
  WHERE PPA.payroll_action_id  =  p_payroll_action_id;
  --
  --*************************************************************************
  --
  -- CURSOR lcu_wage_ledger_info
  --
  -- DESCRIPTION
  --  Fetches User Wage Ledger Information defined at Withholding Agent Level
  --
  -- PARAMETERS
  -- ==========
  -- NAME                TYPE     DESCRIPTION
  -------------------   -------- ---------------------------------------------
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   initialize procedure
  --
  --**********************************************************************
  CURSOR lcu_wage_ledger_info
  IS
  SELECT org_information_id
         ,organization_id
         ,org_information1
         ,org_information2
         ,org_information3
         ,org_information4
         ,org_information5
         ,org_information6
         ,org_information7
         ,org_information8
         ,org_information9
         ,org_information10
         ,org_information11
         ,org_information12
         ,org_information13
  FROM  hr_organization_information HOI
  WHERE HOI.org_information_context= 'JP_WAGE_LEDGER_INFO'
  ORDER BY org_information1;
  --
  -- Local Variables
  lc_procedure               VARCHAR2(200);
  i                          NUMBER := 0;
  --
  BEGIN
    --
    gb_debug :=hr_utility.debug_enabled ;
    lc_procedure := gc_package||'initialize';
    --
    IF gb_debug THEN
       hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    -------------------------------------------------------------------------
    -- initialization_code to  set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    -------------------------------------------------------------------------
    gn_arc_payroll_action_id := p_payroll_action_id;
    -------------------------------------------------------------------------
    -- Fetch the parameters passed by user into global variable.
    -------------------------------------------------------------------------
    OPEN lcr_params(p_payroll_action_id);
    FETCH lcr_params
    INTO  gr_parameters.business_group_id
          ,gr_parameters.subject_yyyymm
          ,gr_parameters.assignment_set_id
          ,gr_parameters.payroll_id
          ,gr_parameters.withholding_agent_id
          ,gr_parameters.archive_option
          ,gr_parameters.effective_date;
    CLOSE lcr_params;
    --
    IF gb_debug THEN
       hr_utility.set_location('p_payroll_action_id.........          = ' || p_payroll_action_id,30);
       hr_utility.set_location('gr_parameters.business_group_id.......= ' || gr_parameters.business_group_id,30);
       hr_utility.set_location('gr_parameters.subject_yyyymm..........= ' || gr_parameters.subject_yyyymm,30);
       hr_utility.set_location('gr_parameters.assignment_set_id.......= ' || gr_parameters.assignment_set_id,30);
       hr_utility.set_location('gr_parameters.payroll_id.............= '  || gr_parameters.payroll_id,30);
       hr_utility.set_location('gr_parameters.withholding_agent_id.......= ' || gr_parameters.withholding_agent_id,30);
       hr_utility.set_location('gr_parameters.archive_option.......= ' || gr_parameters.archive_option,30);
       hr_utility.set_location('gr_parameters.effective_date.......= ' || gr_parameters.effective_date,30);
    END IF;
    --
    gn_business_group_id := gr_parameters.business_group_id ;
    gn_payroll_action_id := p_payroll_action_id;
    -------------------------------------------------------------------------
    -- Fetch the Organization information into global type
    -------------------------------------------------------------------------
    FOR lr_wage_ledger_r IN lcu_wage_ledger_info
    LOOP
      --
      EXIT WHEN lcu_wage_ledger_info%NOTFOUND;
      i := i + 1;
      gt_wage_ledger(i).org_information_id := lr_wage_ledger_r.org_information_id;
      gt_wage_ledger(i).organization_id    := lr_wage_ledger_r.organization_id;
      gt_wage_ledger(i).org_information1   := lr_wage_ledger_r.org_information1;
      gt_wage_ledger(i).org_information2   := lr_wage_ledger_r.org_information2;
      gt_wage_ledger(i).org_information3   := lr_wage_ledger_r.org_information3;
      gt_wage_ledger(i).org_information4   := lr_wage_ledger_r.org_information4;
      gt_wage_ledger(i).org_information5   := lr_wage_ledger_r.org_information5;
      gt_wage_ledger(i).org_information6   := lr_wage_ledger_r.org_information6;
      gt_wage_ledger(i).org_information7   := lr_wage_ledger_r.org_information7;
      gt_wage_ledger(i).org_information8   := lr_wage_ledger_r.org_information8;
      gt_wage_ledger(i).org_information9   := lr_wage_ledger_r.org_information9;
      gt_wage_ledger(i).org_information10  := lr_wage_ledger_r.org_information10;
      gt_wage_ledger(i).org_information11  := lr_wage_ledger_r.org_information11;
      gt_wage_ledger(i).org_information12  := lr_wage_ledger_r.org_information12;
      gt_wage_ledger(i).org_information13  := lr_wage_ledger_r.org_information13;
      --
    END LOOP;
    --
    -- Set end date variable .This value is used to fetch latest assignment details of
    -- employee for archival.In case of archive start date/end date - archive end date
    -- taken and pact_id/period_end_date , period end date is picked.
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END initialize;
  --
  PROCEDURE INITIALIZATION_CODE ( p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE )
  --***************************************************************************
  -- PROCEDURE
  --   INITIALIZATION_CODE
  --
  -- DESCRIPTION
  --   This procedure is used to set global contexts
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --***********************************************************************
  IS
  -- Local Variables
  lc_procedure               VARCHAR2(200);
  --
  BEGIN
    --
    gb_debug :=hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'INITIALIZATION_CODE';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    -----------------------------------------------------------
    -- initialization_code to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    -----------------------------------------------------------
    gn_arc_payroll_action_id := p_payroll_action_id;
    -----------------------------------------------------------
    -- Fetch the parameters passed by user into global variable
    -- initialize procedure
    -----------------------------------------------------------
    initialize(p_payroll_action_id);
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END INITIALIZATION_CODE;
  --
  PROCEDURE DELETE_ASSACT ( p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE
                           ,p_assignment_id      IN per_all_assignments_f.assignment_id%TYPE)
  --***************************************************************************
  -- PROCEDURE
  --   DELETE_ASSACT
  --
  -- DESCRIPTION
  --   This procedure is used to set global contexts
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  -- p_assignment_id            IN       This parameter passes Assignment Id
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --***********************************************************************
  IS
  -- Local Variables
  CURSOR lcu_action_information_id(p_payroll_action_id            pay_payroll_actions.payroll_action_id%type
                                  ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE)

  IS
  SELECT PAI.object_version_number
        ,PAI.action_information_id
  FROM pay_action_information  PAI
      ,pay_assignment_actions   PAC
  WHERE PAI.action_context_id = PAC.assignment_action_id
  AND   PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id
  AND   PAI.action_context_type = 'AAP';
  --
  lc_procedure               VARCHAR2(200);
  --
  BEGIN
    --
    gb_debug :=hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'DELETE_ASSACT';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    -----------------------------------------------------------
    -- initialization_code to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    -----------------------------------------------------------
    gn_arc_payroll_action_id := p_payroll_action_id;
    -----------------------------------------------------------
    -- Fetch the parameters passed by user into global variable
    -- initialize procedure
    -----------------------------------------------------------
    -- initialize(p_payroll_action_id);
    --
    FOR lr_emp_assignment_det in lcu_action_information_id(p_payroll_action_id
                                                          ,p_assignment_id      )
    LOOP
     pay_action_information_api.delete_action_information
     ( p_validate => FALSE
      ,p_action_information_id => lr_emp_assignment_det.action_information_id
      ,p_object_version_number => lr_emp_assignment_det.object_version_number);
    END LOOP;
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END DELETE_ASSACT ;
  --
  FUNCTION proc_lookup_meaning( p_lookup_type        IN hr_lookups.lookup_type%TYPE
                                ,p_lookup_code        IN hr_lookups.lookup_code%TYPE)
  RETURN VARCHAR2 IS
  --***************************************************************************
  -- PROCEDURE
  --   DELETE_ASSACT
  --
  -- DESCRIPTION
  --   This procedure is used to return meaning
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_lookup_type              IN     hr_lookups.lookup_type%TYPE
  -- p_lookup_code              IN     hr_lookups.lookup_code%TYPE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --***********************************************************************
  -- Local Variables
  CURSOR lcu_lookup_meaning(p_lookup_type         hr_lookups.lookup_type%TYPE
                           ,p_lookup_code         hr_lookups.lookup_code%TYPE)
  IS
  SELECT meaning
  FROM   hr_lookups
  WHERE lookup_type = p_lookup_type
  AND lookup_code   = p_lookup_code;
  --
  lc_procedure               VARCHAR2(200);
  lc_meaning                 hr_lookups.meaning%TYPE;
  --
  BEGIN
    --
    gb_debug :=hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'proc_lookup_meaning';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    -----------------------------------------------------------
    -- Fetch the parameters passed by user into global variable
    -- initialize procedure
    -----------------------------------------------------------
    --
    OPEN  lcu_lookup_meaning(p_lookup_type
                            ,p_lookup_code
                            );
    FETCH lcu_lookup_meaning INTO lc_meaning;
    CLOSE lcu_lookup_meaning;
    --
    RETURN lc_meaning;
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END proc_lookup_meaning;
  --
FUNCTION get_with_hold_agent(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                            ,p_effective_date        IN   DATE)
  --************************************************************************
  -- FUNCTION
  -- pay_balance_result_value
  --
  -- DESCRIPTION
  --  To Retrive Pay Run Result Values
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN NUMBER
  IS
  --
  lc_procedure               VARCHAR2(200);
  ln_with_hold_agent         NUMBER;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'get_with_holding_id';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    ln_with_hold_agent     :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                       ,p_input_value_name => 'WITHHOLD_AGENT'
                                                                       ,p_assignment_id    => p_assignment_id
                                                                       ,p_effective_date   => p_effective_date -- Bug 9044516
                                                                       );

    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN ln_with_hold_agent;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in ln_with_hold_agent',10);
    END IF;
    RETURN NULL;
    --
   WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END get_with_hold_agent;
  --
  --Function pay_balance_result_value
  --
  FUNCTION pay_run_result_value(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                               ,p_payroll_period        IN   per_time_periods.time_period_id%TYPE
                               ,p_element_type_id       IN   pay_element_types_f.element_type_id%TYPE
                               ,p_input_value_id        IN   pay_input_values_f.input_value_id%TYPE)
  --************************************************************************
  -- FUNCTION
  -- pay_run_result_value
  --
  -- DESCRIPTION
  --  To Retrive Pay Run Result Values
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN VARCHAR2
  IS
  --
  CURSOR lcu_pay_run_result(p_assignment_id          per_all_assignments_f.assignment_id%TYPE
                           ,p_payroll_period         VARCHAR2
                           ,p_element_type_id        pay_element_types_f.element_type_id%TYPE
                           ,p_input_value_id         pay_input_values_f.input_value_id%TYPE)
  IS
  SELECT  SUM(NVL(prrv.result_value,0))
  FROM     pay_assignment_actions         PAA
          ,pay_run_results                PRR
          ,pay_payroll_actions            PPA
          ,pay_run_result_values          PRRV
  WHERE  PAA.assignment_id         = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    PAA.assignment_action_id   = PRR.assignment_action_id
  AND    PRR.element_type_id        = p_element_type_id
  AND    PRR.status IN ('P','PA')
  AND    PRR.run_result_id          = PRRV.run_result_id
  AND    PRRV.input_value_id        = p_input_value_id
  AND    PPA.effective_date BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B');
  --
  lc_pay_value   VARCHAR2(240);
  lc_procedure   VARCHAR2(200);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'pay_run_result_value';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN  lcu_pay_run_result(p_assignment_id
                            ,p_payroll_period
                            ,p_element_type_id
                            ,p_input_value_id);
    FETCH lcu_pay_run_result INTO lc_pay_value;
    CLOSE lcu_pay_run_result;
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN lc_pay_value;
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in pay_run_result_value',10);
    END IF;
    --
    RETURN NULL;
    WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
    --
  END pay_run_result_value;
  --
  --
  FUNCTION pay_run_result_value(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                               ,p_payroll_period        IN   per_time_periods.time_period_id%TYPE
                               ,p_element_name          IN   pay_element_types_f.element_name%TYPE
                               ,p_input_name            IN   pay_input_values_f.name%TYPE)
  --************************************************************************
  -- FUNCTION
  -- pay_run_result_value
  --
  -- DESCRIPTION
  --  To Retrive Pay Run Result Values
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN VARCHAR2
  IS
  --
  CURSOR lcu_pay_run_result(p_assignment_id          per_all_assignments_f.assignment_id%TYPE
                           ,p_payroll_period         VARCHAR2
                           ,p_element_name           pay_element_types_f.element_name%TYPE
                           ,p_input_name             pay_input_values_f.name%TYPE)
  IS
  SELECT   SUM(NVL(prrv.result_value,0))
  FROM     pay_assignment_actions         PAA
          ,pay_element_types_f            PETF
          ,pay_run_results                PRR
          ,pay_payroll_actions            PPA
          ,pay_input_values_f             PIVF
          ,pay_run_result_values          PRRV
  WHERE  PAA.assignment_id         = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    PAA.assignment_action_id   = PRR.assignment_action_id
  AND    PRR.element_type_id        = PETF.element_type_id
  AND    PETF.element_name          = p_element_name
  AND    PRR.status IN ('P','PA')
  AND    TRUNC(PPA.effective_date )  BETWEEN  PETF.effective_start_date AND PETF.effective_end_date
  AND    TRUNC(PPA.effective_date )  BETWEEN  PIVF.effective_start_date and PIVF.effective_end_date
  AND    PRR.run_result_id          = PRRV.run_result_id
  AND    PRRV.input_value_id        = PIVF.input_value_id
  AND    PIVF.name                  = p_input_name
  AND    PPA.effective_date BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B');
  --
  lc_pay_value   VARCHAR2(240);
  lc_procedure   VARCHAR2(200);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'pay_run_result_value';
       hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN  lcu_pay_run_result(p_assignment_id
                            ,p_payroll_period
                            ,p_element_name
                            ,p_input_name);
    FETCH lcu_pay_run_result INTO lc_pay_value;
    CLOSE lcu_pay_run_result;
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN lc_pay_value;
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in pay_run_result_value',10);
    END IF;
    RETURN NULL;
    --
    WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
    --
  END pay_run_result_value;
  --
 FUNCTION tax_rate_value(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                               ,p_payroll_period        IN   per_time_periods.time_period_id%TYPE
                               ,p_element_name          IN   pay_element_types_f.element_name%TYPE
                               ,p_input_name            IN   pay_input_values_f.name%TYPE)
  --************************************************************************
  -- FUNCTION
  -- pay_run_result_value
  --
  -- DESCRIPTION
  --  To Retrive Pay Run Result Values
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN VARCHAR2
  IS
  --
  CURSOR lcu_pay_run_result(p_assignment_id          per_all_assignments_f.assignment_id%TYPE
                           ,p_payroll_period         VARCHAR2
                           ,p_element_name           pay_element_types_f.element_name%TYPE
                           ,p_input_name             pay_input_values_f.name%TYPE)
  IS
  SELECT   prrv.result_value
  FROM     pay_assignment_actions         PAA
          ,pay_element_types_f            PETF
          ,pay_run_results                PRR
          ,pay_payroll_actions            PPA
          ,pay_input_values_f             PIVF
          ,pay_run_result_values          PRRV
  WHERE  PAA.assignment_id         = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    PAA.assignment_action_id   = PRR.assignment_action_id
  AND    PRR.element_type_id        = PETF.element_type_id
  AND    PETF.element_name          = p_element_name
  AND    PRR.status IN ('P','PA')
  AND    TRUNC(PPA.effective_date )  BETWEEN  PETF.effective_start_date AND PETF.effective_end_date
  AND    TRUNC(PPA.effective_date )  BETWEEN  PIVF.effective_start_date and PIVF.effective_end_date
  AND    PRR.run_result_id          = PRRV.run_result_id
  AND    PRRV.input_value_id        = PIVF.input_value_id
  AND    PIVF.name                  = p_input_name
  AND    PPA.effective_date BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B');
  --
  lc_pay_value   VARCHAR2(240);
  lc_procedure   VARCHAR2(200);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'pay_run_result_value';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN  lcu_pay_run_result(p_assignment_id
                            ,p_payroll_period
                            ,p_element_name
                            ,p_input_name);
    FETCH lcu_pay_run_result INTO lc_pay_value;
    CLOSE lcu_pay_run_result;
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN lc_pay_value;
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in tax_rate_value',10);
    END IF;
    --
    RETURN NULL;
  WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END tax_rate_value;
  --Function tax_rate_value
  --
  FUNCTION pay_balance_result_value(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                                   ,p_payroll_period        IN   per_time_periods.time_period_id%TYPE
                                   ,p_element_set_name      IN   pay_element_sets.element_set_name%TYPE
                                   ,p_balance_type_id       IN   pay_balance_types.balance_type_id%TYPE
                                   ,p_balance_dimension_id  IN   pay_balance_dimensions.balance_dimension_id%TYPE)
  --************************************************************************
  -- FUNCTION
  -- pay_balance_result_value
  --
  -- DESCRIPTION
  --  To Retrive Pay Run Result Values
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN NUMBER
  IS
  --
  CURSOR lcu_assignment_action_id(p_assignment_id          per_all_assignments_f.assignment_id%TYPE
                                 ,p_payroll_period         VARCHAR2
                                 ,p_element_set_name       pay_element_sets.element_set_name%TYPE)
  IS
  SELECT   PAA.assignment_action_id
  FROM     pay_assignment_actions         PAA
          ,pay_payroll_actions            PPA
          ,pay_element_sets               PES
  WHERE  PAA.assignment_id        = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    PPA.effective_date BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B')
  AND    PPA.element_set_id      = PES.element_set_id
  AND    PES.element_set_name    = p_element_set_name
  AND    PES.legislation_code    = 'JP';
  --
  CURSOR lcu_define_balance_id(p_balance_tye_id          pay_balance_types.balance_type_id%TYPE
                              ,p_balance_dimension_id    pay_balance_dimensions.balance_dimension_id%TYPE)
  IS
  SELECT PDB.defined_balance_id
  FROM   pay_defined_balances   PDB
        ,pay_balance_types      PBT
        ,pay_balance_dimensions PBD
  WHERE PBT.balance_type_id      = PDB.balance_type_id
  AND   PDB.balance_dimension_id = PBD.balance_dimension_id
  AND   PDB.balance_type_id      = p_balance_tye_id
  AND   PBD.balance_dimension_id = p_balance_dimension_id;
  --
  ln_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  ln_def_bal_id            pay_defined_balances.defined_balance_id%TYPE;
  --
  ln_pay_value             NUMBER  DEFAULT NULL; -- Bug 9031713
  lc_procedure             VARCHAR2(200);
  ln_amount                NUMBER  DEFAULT NULL;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'pay_balance_result_value';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN  lcu_define_balance_id(p_balance_type_id,p_balance_dimension_id);
    FETCH lcu_define_balance_id INTO ln_def_bal_id;
    CLOSE lcu_define_balance_id;
    --
    -- Bug 9031713
    IF ln_def_bal_id IS NOT NULL THEN
    OPEN  lcu_assignment_action_id(p_assignment_id
                                  ,p_payroll_period
                                  ,p_element_set_name);
    LOOP
    FETCH lcu_assignment_action_id INTO ln_assignment_action_id;
    EXIT WHEN lcu_assignment_action_id%NOTFOUND;
    --
    pay_balance_pkg.set_context('BUSINESS_GROUP_ID',TO_CHAR(gr_parameters.business_group_id));
    pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',TO_CHAR(ln_assignment_action_id));
    ln_amount := pay_balance_pkg.get_value(ln_def_bal_id,ln_assignment_action_id);
    ln_pay_value := NVL(ln_pay_value,0) + NVL(ln_amount,0);
    --
    END LOOP;
    CLOSE lcu_assignment_action_id;
    --
    END IF; -- Bug 9031713
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN ln_pay_value;
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in pay_run_result_value',10);
    END IF;
    --
    RETURN NULL;
    --
  WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
   --
  END pay_balance_result_value;
  --
  --Function get_person_address_type
  --
  FUNCTION get_person_address_type(p_person_id  IN   per_all_people_f.person_id%TYPE)
  --************************************************************************
  -- FUNCTION
  -- get_person_address_type
  --
  -- DESCRIPTION
  --  To Retrive get_person_address_type
  --  to fix bug Bug 8911281
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN VARCHAR2
  IS
  --
  CURSOR lcu_address_type(p_person_id  VARCHAR2)
  IS
  SELECT address_type
  FROM per_addresses
  WHERE person_id= p_person_id
  AND ((address_type = 'JP_R')
       or (address_type = 'JP_C'))
  ORDER BY address_type desc;
  --
  lc_address_type          per_addresses.address_type%type DEFAULT NULL;
  lc_procedure             VARCHAR2(200);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'get_person_address_type';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN  lcu_address_type(p_person_id);
    FETCH lcu_address_type INTO lc_address_type;
    CLOSE lcu_address_type;
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN lc_address_type ;
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in get_person_address_type',10);
    END IF;
    --
    RETURN NULL;
    --
  WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END get_person_address_type;
 --
 --
 -- This function is added for the bug 8830360
 --
FUNCTION pay_bon_balance_result_value(p_assignment_id          IN   per_all_assignments_f.assignment_id%TYPE
                                   ,p_payroll_period        IN   per_time_periods.time_period_id%TYPE
                                   ,p_balance_name          IN   pay_balance_types.balance_name%TYPE
                                   ,p_dimension_name        IN   pay_balance_dimensions.dimension_name%TYPE
                                   ,p_element_set_name      IN   pay_element_sets.element_set_name%TYPE)
  --************************************************************************
  -- FUNCTION
  -- pay_bon_balance_result_value
  --
  -- DESCRIPTION
  --  To Retrive Pay Run Result Values
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN NUMBER
  IS
  --
  CURSOR lcu_assignment_action_id(p_assignment_id          per_all_assignments_f.assignment_id%TYPE
                                 ,p_payroll_period         VARCHAR2
                                 ,p_element_set_name       pay_element_sets.element_set_name%TYPE)
  IS
  SELECT   PAA.assignment_action_id
  FROM     pay_assignment_actions         PAA
          ,pay_payroll_actions            PPA
          ,pay_element_sets               PES
  WHERE  PAA.assignment_id        = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    PPA.effective_date BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B')
  AND    PPA.element_set_id      = PES.element_set_id
  AND    PES.element_set_name    IN ('BON','SPB')
  AND    PES.legislation_code    = 'JP'
  AND   PES.element_set_name    = p_element_set_name;
  --
  CURSOR lcu_define_balance_id(p_balance_name            pay_balance_types.balance_name%TYPE
                              ,p_dimension_name          pay_balance_dimensions.dimension_name%TYPE)
  IS
  SELECT PDB.defined_balance_id
  FROM   pay_defined_balances   PDB
        ,pay_balance_types      PBT
        ,pay_balance_dimensions PBD
  WHERE PBT.balance_name         =  p_balance_name
  AND   PDB.balance_dimension_id = PBD.balance_dimension_id
  AND   PDB.balance_type_id      = PBT.balance_type_id
  AND   PBD.database_item_suffix = p_dimension_name;
  --
  ln_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  ln_def_bal_id            pay_defined_balances.defined_balance_id%TYPE;
  --
  ln_pay_value             NUMBER  DEFAULT NULL; -- Bug 9031713
  lc_procedure             VARCHAR2(200);
  ln_amount                NUMBER  DEFAULT NULL;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'pay_balance_result_value';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN  lcu_define_balance_id(p_balance_name,p_dimension_name);
    FETCH lcu_define_balance_id INTO ln_def_bal_id;
    CLOSE lcu_define_balance_id;
    --
    -- Bug 9031713
    IF ln_def_bal_id IS NOT NULL THEN
    OPEN  lcu_assignment_action_id(p_assignment_id
                                  ,p_payroll_period
                                  ,p_element_set_name);
    LOOP
    FETCH lcu_assignment_action_id INTO ln_assignment_action_id;
    EXIT WHEN lcu_assignment_action_id%NOTFOUND;
    --
    pay_balance_pkg.set_context('BUSINESS_GROUP_ID',TO_CHAR(gr_parameters.business_group_id));
    pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',TO_CHAR(ln_assignment_action_id));
    ln_amount := pay_balance_pkg.get_value(ln_def_bal_id,ln_assignment_action_id);
    ln_pay_value := NVL(ln_pay_value,0) + NVL(ln_amount,0);
    --
    END LOOP;
    CLOSE lcu_assignment_action_id;
    --
    END IF; -- Bug 9031713
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN ln_pay_value;
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in pay_bon_run_result_value',10);
    END IF;
    --
    RETURN NULL;
    --
  WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END pay_bon_balance_result_value;
 --
 -- This function is added for the bug 8830491
 --
 FUNCTION pay_sal_balance_result_value(p_assignment_id          IN   per_all_assignments_f.assignment_id%TYPE
                                   ,p_payroll_period        IN   per_time_periods.time_period_id%TYPE
                                   ,p_balance_name          IN   pay_balance_types.balance_name%TYPE
                                   ,p_dimension_name        IN   pay_balance_dimensions.dimension_name%TYPE)
  --************************************************************************
  -- FUNCTION
  -- pay_sal_balance_result_value
  --
  -- DESCRIPTION
  --  To Retrive Pay Run Result Values
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN NUMBER
  IS
  --
  CURSOR lcu_assignment_action_id(p_assignment_id          per_all_assignments_f.assignment_id%TYPE
                                 ,p_payroll_period         VARCHAR2)
  IS
  SELECT   PAA.assignment_action_id
  FROM     pay_assignment_actions         PAA
          ,pay_payroll_actions            PPA
          ,pay_element_sets               PES
   WHERE  PAA.assignment_id        = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    PPA.effective_date BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B')
  AND    PPA.element_set_id      = PES.element_set_id
  AND    PES.element_set_name    = 'SAL'
  AND    PES.legislation_code    = 'JP';
  --
  CURSOR lcu_define_balance_id(p_balance_name            pay_balance_types.balance_name%TYPE
                              ,p_dimension_name          pay_balance_dimensions.dimension_name%TYPE)
  IS
  SELECT PDB.defined_balance_id
  FROM   pay_defined_balances   PDB
        ,pay_balance_types      PBT
        ,pay_balance_dimensions PBD
  WHERE PBT.balance_name         =  p_balance_name
  AND   PDB.balance_dimension_id = PBD.balance_dimension_id
  AND   PDB.balance_type_id      = PBT.balance_type_id
  AND   PBD.database_item_suffix = p_dimension_name;
  --
  ln_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  ln_def_bal_id            pay_defined_balances.defined_balance_id%TYPE;
  --
  ln_pay_value             NUMBER  DEFAULT NULL; -- Bug 9031713
  lc_procedure             VARCHAR2(200);
  ln_amount                NUMBER  DEFAULT NULL;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'pay_sal_balance_result_value';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN  lcu_define_balance_id(p_balance_name,p_dimension_name);
    FETCH lcu_define_balance_id INTO ln_def_bal_id;
    CLOSE lcu_define_balance_id;
    --
    -- Bug 9031713
    IF ln_def_bal_id IS NOT NULL THEN
    OPEN  lcu_assignment_action_id(p_assignment_id
                                  ,p_payroll_period
                                   );
    LOOP
    FETCH lcu_assignment_action_id INTO ln_assignment_action_id;
    EXIT WHEN lcu_assignment_action_id%NOTFOUND;
    --
    pay_balance_pkg.set_context('BUSINESS_GROUP_ID',TO_CHAR(gr_parameters.business_group_id));
    pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',TO_CHAR(ln_assignment_action_id));
    ln_amount := pay_balance_pkg.get_value(ln_def_bal_id,ln_assignment_action_id);
    ln_pay_value := NVL(ln_pay_value,0) + NVL(ln_amount,0);
    --
    END LOOP;
    CLOSE lcu_assignment_action_id;
    --
    END IF; -- Bug 9031713
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN ln_pay_value;
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in pay_sal_run_result_value',10);
    END IF;
    --
    RETURN NULL;
    --
  WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END pay_sal_balance_result_value;
  --
  --Function pay_sal_balance_result_value
  --
 FUNCTION pay_yea_balance_result_value(p_assignment_id          IN   per_all_assignments_f.assignment_id%TYPE
                                   ,p_payroll_period        IN   per_time_periods.time_period_id%TYPE
                                   ,p_balance_name          IN   pay_balance_types.balance_name%TYPE
                                   ,p_dimension_name        IN   pay_balance_dimensions.dimension_name%TYPE)
  --************************************************************************
  -- FUNCTION
  -- pay_yea_balance_result_value
  --
  -- DESCRIPTION
  --  To Retrive Pay Run Result Values
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN VARCHAR2
  IS
  --
  -- actually yea assact id ln_yea_assignment_action_id should be passed to check the action id again here.
  CURSOR lcu_assignment_action_id(p_assignment_id          per_all_assignments_f.assignment_id%TYPE
                                 ,p_payroll_period         VARCHAR2)
  IS
  SELECT   PAA.assignment_action_id
  FROM     pay_assignment_actions         PAA
          ,pay_payroll_actions            PPA
  WHERE  PAA.assignment_id          = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  and    paa.action_status = 'C'
  AND    PPA.effective_date BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  -- actually it should refer to pay_jp_wic_assacts_v (pay_jp_pre_tax, not sure design if pre tax archiver is mandatory or not)
  -- so this has performance issue because no index for pay_payroll_actions.element_type_id (should refer to run result)
  -- and issue for itax category change
  and  ((exists(
    select null
    from   pay_element_types_f pet
    where  ppa.action_type = 'B'
    and    pet.element_name in ('YEA_ITX', 'REY_ITX')
    and    pet.legislation_code = 'JP'
    and    ppa.effective_date
           between pet.effective_start_date and pet.effective_end_date
    and    ppa.element_type_id = pet.element_type_id))
    or (exists(
    select null
    from   pay_element_sets pes
    where  ppa.action_type in ('R','Q')
    and    pes.element_set_name in ('YEA','REY')
    and    pes.legislation_code = 'JP'
    and    ppa.element_set_id = pes.element_set_id)))
  order by paa.action_sequence desc;
  --
  CURSOR lcu_define_balance_id(p_balance_name            pay_balance_types.balance_name%TYPE
                              ,p_dimension_name          pay_balance_dimensions.dimension_name%TYPE)
  IS
  SELECT PDB.defined_balance_id
  FROM   pay_defined_balances   PDB
        ,pay_balance_types      PBT
        ,pay_balance_dimensions PBD
  WHERE PBT.balance_name         =  p_balance_name
  AND   PDB.balance_dimension_id = PBD.balance_dimension_id
  AND   PDB.balance_type_id      = PBT.balance_type_id
  AND   PBD.database_item_suffix = p_dimension_name;
  --
  ln_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  ln_def_bal_id            pay_defined_balances.defined_balance_id%TYPE;
  --
  lc_pay_value             VARCHAR2(240);
  lc_procedure             VARCHAR2(200);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'pay_yea_balance_result_value';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN  lcu_assignment_action_id(p_assignment_id,p_payroll_period);
    FETCH lcu_assignment_action_id INTO ln_assignment_action_id;
    CLOSE lcu_assignment_action_id;
    --
    OPEN  lcu_define_balance_id(p_balance_name,p_dimension_name);
    FETCH lcu_define_balance_id INTO ln_def_bal_id;
    CLOSE lcu_define_balance_id;
    --
    pay_balance_pkg.set_context('BUSINESS_GROUP_ID',TO_CHAR(gr_parameters.business_group_id));
    pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',TO_CHAR(ln_assignment_action_id));
    lc_pay_value := pay_balance_pkg.get_value(ln_def_bal_id,ln_assignment_action_id);
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN lc_pay_value;
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in pay_run_result_value',10);
    END IF;
    --
    RETURN NULL;
    --
  WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END pay_yea_balance_result_value;
  --
  --Function pay_yea_balance_result_value
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
 PROCEDURE UPDATE_ARCH( p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE
                       ,p_payroll_action_id    IN pay_payroll_actions.payroll_action_id%TYPE
                       ,p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
                       ,p_effective_date       IN pay_payroll_actions.effective_date%TYPE)
  --***************************************************************************
  -- PROCEDURE
  --   DELETE_ASSACT
  --
  -- DESCRIPTION
  --   This procedure is used to set global contexts
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  -- p_assignment_id            IN       This parameter passes Assignment Id
  -- p_effective_date           IN       This Paramter Passes  Date
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --***********************************************************************
  IS
  -- Local Variables
  CURSOR lcu_employee_details ( p_assignment_id     NUMBER
                              , p_effective_date    DATE
                              )
  IS
  SELECT HOU.organization_id                                      organization_id
       , PAAF.payroll_id                                          payroll_id
       , PAAF.location_id                                         location_id
       , PPF.person_id                                            person_id
       , PPF.last_name ||' '||PPF.first_name                      full_name_kana
       , HL_S.meaning                                             gender
       , PPOS.date_start                                          hire_date
       , PPOS.actual_termination_date                             termination_date
       , HOU.name                                                 organization_name
       , PPF.per_information18||' '|| PPF.per_information19       full_name_kanji
       , PJS.name                                                 job_title
       , PAD.postal_code                                          postal_code
       , PAD.address_line1                                        address_line1
       , PAD.address_line2                                        address_line2
       , PAD.address_line3                                        address_line3
       , PAD.telephone_number_1                                   phone_number
       , PPF.date_of_birth                                        date_of_birth
       , PPF.employee_number                                      employee_number
       , PAAF.assignment_id                                       assignment_id
       , PAAF.employment_category                                 employment_category
       , PAY.payroll_name                                         payroll_name
       , PAY.prl_information1                                     dpnt_ref_type
       , PPF.last_name                                            last_name_kana
       , PPF.per_information18                                    last_name_kanji
       , PAD.region_1                                             address_line1_kana
       , PAD.region_2                                             address_line2_kana
       , PAD.region_3                                             address_line3_kana
       , PPF.sex                                                  sex
       , PPOS.leaving_reason                                      leaving_reason
  FROM   per_people_f                    PPF
       , per_assignments_f               PAAF
       , per_addresses                   PAD
       , per_periods_of_service          PPOS
       , hr_all_organization_units_tl    HOU
       , per_jobs_tl                     PJS
       , pay_payrolls_f                  PAY
       , hr_lookups                      HL_S
  WHERE PAAF.person_id                     = PPF.person_id
  AND   PAD.person_id(+)                   = PPF.person_id
  AND   PPOS.person_id                     = PPF.person_id
  AND   HOU.organization_id(+)             = PAAF.organization_id
  AND   PJS.job_id(+)                      = PAAF.job_id
  AND   NVL(PPOS.actual_termination_date,p_effective_date) BETWEEN PPF.effective_start_date  AND PPF.effective_end_date
  AND   NVL(PPOS.actual_termination_date,p_effective_date) BETWEEN PAAF.effective_start_date AND PAAF.effective_end_date
  AND   PAAF.assignment_id                 =  p_assignment_id
  AND   HOU.language(+)                    = USERENV('LANG')
  AND   PJS.language(+)                    = USERENV('LANG')
  AND   PAD.address_type(+)                = get_person_address_type(PPF.person_id)
  AND   PAY.payroll_id(+)                  = PAAF.payroll_id
  AND   NVL(PPOS.actual_termination_date,p_effective_date)   BETWEEN TRUNC(NVL(PAD.date_from,PPOS.date_start)) AND NVL(PAD.date_to,TO_DATE('31/12/4712','DD/MM/YYYY'))
  AND   HL_S.lookup_type(+)                   = 'SEX'
  AND   HL_S.lookup_code(+)                   = PPF.sex
  AND   NVL(PPOS.actual_termination_date,p_effective_date) BETWEEN TRUNC(NVL(PAY.effective_start_date,PPOS.date_start)) AND NVL(PAY.effective_end_date,TO_DATE('31/12/4712','DD/MM/YYYY'))
  ORDER BY PPF.person_id,PPF.effective_start_date;
  ----------------------------------------------------------------
  -- Cursor to Fetch reporting name for Elements
  ----------------------------------------------------------------
  CURSOR lcu_element_report_name(p_element_type_id  pay_element_types_f.element_type_id%TYPE
                                ,p_effective_date   DATE)
  IS
  SELECT PETFTL.reporting_name
  FROM pay_element_types_f PETF
      ,pay_element_types_f_tl PETFTL
  WHERE PETFTL.element_type_id = PETF.element_type_id
  AND   PETF.element_type_id   = p_element_type_id
  AND   PETFTL.Language = USERENV('LANG')
  AND   TRUNC (p_effective_date) BETWEEN  PETF.effective_start_date AND PETF.effective_end_date;
  --------------------------------------------------------------------
  -- Cursor to Fetch fetch the Master Assignment Action Id
  --------------------------------------------------------------------
  CURSOR lcu_org_action_id(p_payroll_action_id            pay_payroll_actions.payroll_action_id%type
                          ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE)

  IS
  SELECT PAC.assignment_action_id
  FROM  pay_assignment_actions   PAC
  WHERE PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id;
  ----------------------------------------------------------------
  -- Cursor to fetch element type id
  ----------------------------------------------------------------
  CURSOR lcu_element_type_id(p_element_name pay_element_types_f.element_name%TYPE
                            ,p_effective_date   DATE)
  IS
  SELECT PETF.element_type_id
  FROM pay_element_types_f PETF
  WHERE PETF.element_name = p_element_name
  AND   TRUNC (p_effective_date) BETWEEN  PETF.effective_start_date AND PETF.effective_end_date;
 ----------------------------------------------------------------
  -- Cursor to fetch element input value id
  ----------------------------------------------------------------
  CURSOR lcu_input_value_id(p_element_type_id pay_element_types_f.element_name%TYPE
                           ,p_name            pay_input_values_f.name%TYPE
                           ,p_effective_date   DATE)
  IS
  SELECT PIVF.input_value_id
  FROM   pay_input_values_f PIVF
  WHERE PIVF.element_type_id = p_element_type_id
  AND   PIVF.name            = p_name
  AND   TRUNC (p_effective_date) BETWEEN  PIVF.effective_start_date AND PIVF.effective_end_date;
  ----------------------------------------------------------------
  -- Cursor to fetch balance reporting name
  ----------------------------------------------------------------
  CURSOR lcu_balance_report_name(p_balance_type_id      pay_balance_types.balance_type_id%TYPE)
  IS
  SELECT PBTTL.reporting_name
  FROM pay_balance_types PBT
      ,pay_balance_types_tl PBTTL
  WHERE  PBTTL.balance_type_id = PBT.balance_type_id
  AND    PBT.balance_type_id   = p_balance_type_id
  AND    PBTTL.Language = USERENV('LANG');
  ----------------------------------------------------------------
  -- Cursor to fetch payment action date
  ----------------------------------------------------------------
  CURSOR lcu_payment_action_date (p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                                 ,p_payroll_start_period         VARCHAR2
                                 ,p_payroll_end_period           VARCHAR2
                                  )
  IS
  SELECT   PPA.effective_date
          ,PES.element_set_name
          ,PAA.assignment_action_id
  FROM     per_assignments_f              PAAF
          ,pay_assignment_actions         PAA
          ,pay_payroll_actions            PPA
          ,pay_element_sets               PES
  WHERE  PAAF.assignment_id         = p_assignment_id
  AND    PAAF.assignment_id         = PAA.assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    TRUNC(PPA.effective_date)  BETWEEN  PAAF.effective_start_date and PAAF.effective_end_date
  AND    TRUNC(PPA.effective_date)  BETWEEN TO_DATE(p_payroll_start_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_end_period,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B')
  AND    PPA.element_set_id(+) = PES.element_set_id
  AND    PES.element_set_type(+)  = 'R'
  ORDER BY PPA.effective_date;
  ----------------------------------------------------------------
  -- Cursor to Fetch procedure name to fetch the Extra Information
  ----------------------------------------------------------------
  CURSOR lcu_proc_name (p_effective_date DATE)
  IS
  SELECT MAX(FND_DATE.canonical_to_date(HOI.org_information5)) start_date
        ,HOI.org_information4                                  proc_name
  FROM   hr_organization_information HOI
  WHERE  HOI.org_information_context    = 'JP_REPORTS_ADDITIONAL_INFO'
  AND    HOI.org_information1           = 'JPWAGELEDGERREPORT'
  AND    HOI.org_information3           = 'ADDINFO'
  AND    p_effective_date         BETWEEN FND_DATE.canonical_to_date(HOI.org_information5)
                                      AND FND_DATE.canonical_to_date(HOI.org_information6)
  GROUP BY HOI.org_information4;
  --
  --------------------------------------------------------------------
  -- Cursor to Fetch procedure name to fetch the Action Information Id
  --------------------------------------------------------------------
  CURSOR lcu_action_information_id(p_action_information_category  pay_action_information.action_information_category%TYPE
                                  ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                                  ,p_payroll_action_id            pay_payroll_actions.payroll_action_id%type)
  IS
  SELECT PAI.object_version_number
        ,PAI.action_information_id
  FROM pay_action_information  PAI
      ,pay_assignment_actions   PAC
  WHERE PAI.action_information_category =  p_action_information_category
  AND   PAI.action_context_id = PAC.assignment_action_id
  AND   PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id
  AND   PAI.action_context_type = 'AAP';
  --------------------------------------------------------------------
  -- Cursor to Fetch procedure name to fetch the Action Information Id
  --------------------------------------------------------------------
  CURSOR lcu_item_action_info_id(p_action_information_category    pay_action_information.action_information_category%TYPE
                                  ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                                  ,p_payroll_action_id            pay_payroll_actions.payroll_action_id%type
                                  ,p_action_information2          pay_action_information.action_information2%TYPE)
  IS
  SELECT PAI.object_version_number
        ,PAI.action_information_id
        ,fnd_number.canonical_to_number(action_information6)
        ,fnd_number.canonical_to_number(action_information7)
        ,fnd_number.canonical_to_number(action_information8)
        ,fnd_number.canonical_to_number(action_information9)
        ,fnd_number.canonical_to_number(action_information10)
        ,fnd_number.canonical_to_number(action_information11)
        ,fnd_number.canonical_to_number(action_information12)
        ,fnd_number.canonical_to_number(action_information13)
        ,fnd_number.canonical_to_number(action_information14)
        ,fnd_number.canonical_to_number(action_information15)
        ,fnd_number.canonical_to_number(action_information16)
        ,fnd_number.canonical_to_number(action_information17)
  FROM pay_action_information  PAI
      ,pay_assignment_actions   PAC
  WHERE PAI.action_information_category =  p_action_information_category
  AND   PAI.action_context_id = PAC.assignment_action_id
  AND   PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id
  AND   PAI.action_information2 = p_action_information2
  AND   PAI.action_context_type = 'AAP';
  --------------------------------------------------------------------
  -- Cursor to Fetch procedure name to fetch the Action Information Id
  --------------------------------------------------------------------
  CURSOR lcu_pay_action_info_id(p_action_information_category    pay_action_information.action_information_category%TYPE
                                  ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                                  ,p_payroll_action_id            pay_payroll_actions.payroll_action_id%type
                                  ,p_action_information2          pay_action_information.action_information2%TYPE)
  IS
  SELECT PAI.object_version_number
        ,PAI.action_information_id
  FROM pay_action_information  PAI
      ,pay_assignment_actions   PAC
  WHERE PAI.action_information_category =  p_action_information_category
  AND   PAI.action_context_id = PAC.assignment_action_id
  AND   PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id
  AND   PAI.action_information2 = p_action_information2
  AND   PAI.action_context_type = 'AAP';
  --
  --------------------------------------------------------------------
  -- Cursor to Fetch procedure name to fetch the Action Information Id
  --------------------------------------------------------------------
  CURSOR lcu_bon_action_info_id(p_action_information_category    pay_action_information.action_information_category%TYPE
                                  ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                                  ,p_payroll_action_id            pay_payroll_actions.payroll_action_id%type
                                  ,p_action_information3          pay_action_information.action_information3%TYPE)
  IS
  SELECT PAI.object_version_number
        ,PAI.action_information_id
        ,fnd_number.canonical_to_number(action_information7)
        ,fnd_number.canonical_to_number(action_information8)
        ,fnd_number.canonical_to_number(action_information9)
        ,fnd_number.canonical_to_number(action_information10)
        ,fnd_number.canonical_to_number(action_information11)
        ,fnd_number.canonical_to_number(action_information12)
        ,fnd_number.canonical_to_number(action_information13)
        ,fnd_number.canonical_to_number(action_information14)
        ,fnd_number.canonical_to_number(action_information15)
        ,fnd_number.canonical_to_number(action_information16)
        ,fnd_number.canonical_to_number(action_information17)
        ,fnd_number.canonical_to_number(action_information18)
  FROM pay_action_information  PAI
      ,pay_assignment_actions   PAC
  WHERE PAI.action_information_category =  p_action_information_category
  AND   PAI.action_context_id = PAC.assignment_action_id
  AND   PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id
  AND   PAI.action_information3 = p_action_information3
  AND   PAI.action_context_type = 'AAP';
  --------------------------------------------------------------------
  -- Cursor to Fetch procedure name to fetch the Master Payroll Action Id
  --------------------------------------------------------------------
  CURSOR lcu_get_pact_info( p_subject_yyyymm VARCHAR2
                           ,p_assignment_id  per_all_assignments_f.assignment_id%TYPE
                           )
  IS
  SELECT fnd_number.canonical_to_number(PCI.action_information3)
  FROM   pay_action_information        PCI
        ,pay_assignment_actions        PAA
  WHERE  PCI.action_information_category = 'JP_WL_PACT'
  AND    TO_CHAR(TO_DATE(PCI.action_information1,'YYYYMM'),'YYYY') =  TO_CHAR(TO_DATE(p_subject_yyyymm,'YYYYMM'),'YYYY')
  AND    PCI.action_information8         = 'Y'
  AND    PCI.action_context_type  = 'PA'
  AND    PAA.payroll_action_id    = PCI.action_context_id
  AND    PAA.assignment_id        = p_assignment_id;
  --
  --------------------------------------------------------------------------
  -- Cursor to fetch YEA Assignment Action Id
  --------------------------------------------------------------------------
  CURSOR lcu_yea_info_id(p_payroll_period               VARCHAR2
                        ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE)
  IS
  SELECT     PAA.assignment_action_id
            ,PPA.effective_date
            ,PPA.date_earned
  FROM      pay_assignment_actions         PAA
           ,pay_payroll_actions            PPA
  WHERE    PAA.assignment_id          = p_assignment_id
  AND      PAA.payroll_action_id      = PPA.payroll_action_id
  and      paa.action_status = 'C'
  AND      PPA.effective_date BETWEEN TRUNC(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),'YEAR') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  -- actually it should refer to pay_jp_wic_assacts_v (pay_jp_pre_tax, not sure design if pre tax archiver is mandatory or not)
  -- so this has performance issue because no index for pay_payroll_actions.element_type_id (should refer to run result)
  -- and issue for itax category change
  and  ((exists(
    select null
    from   pay_element_types_f pet
    where  ppa.action_type = 'B'
    and    pet.element_name in ('YEA_ITX', 'REY_ITX')
    and    pet.legislation_code = 'JP'
    and    ppa.effective_date
           between pet.effective_start_date and pet.effective_end_date
    and    ppa.element_type_id = pet.element_type_id))
    or (exists(
    select null
    from   pay_element_sets pes
    where  ppa.action_type in ('R','Q')
    and    pes.element_set_name in ('YEA','REY')
    and    pes.legislation_code = 'JP'
    and    ppa.element_set_id = pes.element_set_id)))
  order by paa.action_sequence desc;
  --------------------------------------------------------------------------
  -- Cursor to fetch Total Dependent Exemption
  --------------------------------------------------------------------------
   CURSOR lcu_tot_dep_exem(p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                         ,p_subject_yyyymm               VARCHAR2
                         ,p_assignment_action_id         pay_assignment_actions.assignment_action_id%TYPE)
  IS
  SELECT   SUM(NVL(prrv.result_value,0))
  FROM     pay_assignment_actions         PAA
          ,pay_element_types_f            PETF
          ,pay_run_results                PRR
          ,pay_payroll_actions            PPA
          ,pay_run_result_values          PRRV
  WHERE  PAA.assignment_id          = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    PAA.assignment_action_id   = PRR.assignment_action_id
  AND    PRR.element_type_id        = PETF.element_type_id
  AND    PETF.element_name          = 'YEA_DEP_EXM_RSLT'
  AND    PRR.status IN ('P','PA')
  AND    TRUNC(PPA.effective_date )  BETWEEN  PETF.effective_start_date AND PETF.effective_end_date
  AND    PRR.run_result_id          = PRRV.run_result_id
  AND    PPA.effective_date BETWEEN TO_DATE(p_subject_yyyymm,'YYYYMM') AND LAST_DAY(TO_DATE(p_subject_yyyymm,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B')
  AND    PAA.assignment_action_id = p_assignment_action_id;
  --------------------------------------------------------------------------
  -- Cursor to fetch Over and short tax Assignment Action Id
  --------------------------------------------------------------------------
  CURSOR lcu_over_short_tax_id(p_payroll_period               VARCHAR2
                              ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE)
  IS
  SELECT RUN_PAA.assignment_action_id
        ,RUN_PPA.effective_date
  FROM  pay_payroll_actions    PPA
       ,pay_assignment_actions PAA
       ,pay_assignment_actions RUN_PAA
       ,pay_payroll_actions    RUN_PPA
       ,pay_action_interlocks  PAI
       ,pay_element_sets       PES
       ,pay_element_types_f    PETF
  WHERE PAA.assignment_id             = p_assignment_id
  AND   PAA.payroll_action_id         = PPA.payroll_action_id
  AND   TRUNC(PPA.effective_date)     BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND   PPA.action_type               IN ('P','U')
  AND   PAI.locking_action_id         = PAA.assignment_action_id
  AND   PAI.locked_action_id          = RUN_PAA.assignment_action_id
  AND   PAA.assignment_id             = RUN_PAA.assignment_id
  AND   RUN_PAA.payroll_action_id     = RUN_PPA.payroll_action_id
  AND ((    RUN_PPA.action_type  = 'B'
            AND PETF.element_name IN  ( 'REY_ITX','YEA_ITX')
            AND PETF.legislation_code = 'JP'
            AND RUN_PPA.element_type_id = PETF.element_type_id
            AND NVL(RUN_PPA.element_set_id,PES.element_set_id) = PES.element_set_id
            AND PES.element_set_name  = 'YEA'
            )
     OR (  PES.element_set_name   = 'YEA'
           AND     PES.legislation_code    = 'JP'
           AND     RUN_PPA.action_type IN ('Q','R')
           AND     RUN_PPA.element_set_id = PES.element_set_id
           AND     NVL(RUN_PPA.element_type_id,PETF.element_type_id) = PETF.element_type_id
           AND     PETF.element_name IN  ( 'REY_ITX','YEA_ITX')
           AND     PETF.legislation_code = 'JP'
            ));
  --------------------------------------------------------------------------
  -- Cursor to fetch Over and short tax Assignment Action Id
  --------------------------------------------------------------------------
  CURSOR lcu_over_short_tax_amount(p_payment_date                 DATE
                                  ,p_assignment_action_id         pay_assignment_actions.assignment_action_id%TYPE)
  IS
  SELECT   SUM(NVL(prrv.result_value,0))
  FROM     pay_element_types_f            PETF
          ,pay_run_results                PRR
          ,pay_input_values_f             PIVF
          ,pay_run_result_values          PRRV
  WHERE  PRR.assignment_action_id  =  p_assignment_action_id
  AND    PRR.element_type_id        = PETF.element_type_id
  AND    PETF.element_name         IN  ( 'REY_ITX','YEA_ITX')
  AND    PRR.status IN ('P','PA')
  AND    TRUNC(p_payment_date)  BETWEEN  PETF.effective_start_date AND PETF.effective_end_date
  AND    TRUNC(p_payment_date)  BETWEEN  PIVF.effective_start_date and PIVF.effective_end_date
  AND    PRR.run_result_id          = PRRV.run_result_id
  AND    PRRV.input_value_id        = PIVF.input_value_id
  AND    PIVF.name                  = 'Pay Value';
  --------------------------------------------------------------------------
  -- Cursor to fetch Over and short tax Assignment Action Id
  --------------------------------------------------------------------------
  CURSOR lcu_over_short_check(p_payroll_period                VARCHAR2
                              ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                              ,p_element_set_name             pay_element_sets.element_set_name%TYPE)
  IS
  SELECT RUN_PAA.assignment_action_id
  FROM  pay_payroll_actions    PPA
       ,pay_assignment_actions PAA
       ,pay_assignment_actions RUN_PAA
       ,pay_payroll_actions    RUN_PPA
       ,pay_action_interlocks  PAI
       ,pay_element_sets       PES
  WHERE PAA.assignment_id             = p_assignment_id
  AND   PAA.payroll_action_id         = PPA.payroll_action_id
  AND   TRUNC(PPA.effective_date)     BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND   PPA.action_type               IN ('P','U')
  AND   PAI.locking_action_id         = PAA.assignment_action_id
  AND   PAI.locked_action_id          = RUN_PAA.assignment_action_id
  AND   PAA.assignment_id             = RUN_PAA.assignment_id
  AND   RUN_PAA.payroll_action_id     = RUN_PPA.payroll_action_id
  AND   RUN_PPA.action_type           IN ('Q','R')
  AND   RUN_PPA.element_set_id        = PES.element_set_id
  AND   PES.element_set_name          = p_element_set_name;
  --------------------------------------------------------------------------
  -- Cursor bonus element set
  --------------------------------------------------------------------------
  CURSOR lcu_bonus_element_set(p_element_type_id          pay_element_types_f.element_type_id%TYPE)
  IS
  SELECT  'Y'
  FROM  pay_element_set_members PESM
         ,pay_element_sets       PES
  WHERE PES.element_set_id     = PESM.element_set_id
  AND   PESM.element_type_id   =  p_element_type_id
  AND   PES.element_set_name   = 'SPB';

  --
  TYPE extra_info IS RECORD (extra_info1      VARCHAR2(240)
                            ,extra_info2      VARCHAR2(240)
                            ,extra_info3      VARCHAR2(240)
                            ,extra_info4      VARCHAR2(240)
                            ,extra_info5      VARCHAR2(240)
                            ,extra_info6      VARCHAR2(240)
                            ,extra_info7      VARCHAR2(240)
                            ,extra_info8      VARCHAR2(240)
                            ,extra_info9      VARCHAR2(240)
                            ,extra_info10     VARCHAR2(240)
                            ,extra_info11     VARCHAR2(240)
                            ,extra_info12     VARCHAR2(240)
                            ,extra_info13     VARCHAR2(240)
                            ,extra_info14     VARCHAR2(240)
                            ,extra_info15     VARCHAR2(240)
                            ,extra_info16     VARCHAR2(240)
                            ,extra_info17     VARCHAR2(240)
                            ,extra_info18     VARCHAR2(240)
                            ,extra_info19     VARCHAR2(240)
                            ,extra_info20     VARCHAR2(240)
                            ,extra_info21     VARCHAR2(240)
                            ,extra_info22     VARCHAR2(240)
                            ,extra_info23     VARCHAR2(240)
                            ,extra_info24     VARCHAR2(240)
                            ,extra_info25     VARCHAR2(240)
                            ,extra_info26     VARCHAR2(240)
                            ,extra_info27     VARCHAR2(240)
                            ,extra_info28     VARCHAR2(240)
                            ,extra_info29     VARCHAR2(240)
                            ,extra_info30     VARCHAR2(240)
                            );
  -- Local Variables
  lc_procedure                    VARCHAR2(200);
  lc_itx_type                     pay_element_entry_values_f.screen_entry_value%TYPE;
  lc_itx_type_meaning             hr_lookups.meaning%TYPE;
  lc_subject_yyyymm               VARCHAR2(240);
  lc_submission_required_flag     VARCHAR2(1);
  lc_salary_payer_name_kanji      VARCHAR2(240);
  lc_plsql_block                  VARCHAR2(2000);
  lc_itax_yea_category            pay_element_entry_values_f.screen_entry_value%TYPE;
  lc_widow_type                   VARCHAR2(240);
  lC_spouse_type                  VARCHAR2(240);
  lc_disable_type                 VARCHAR2(240);
  lc_working_student              VARCHAR2(240);
  lc_existence_declaration        VARCHAR2(1) DEFAULT 'N';
  lC_spouse_exists                VARCHAR2(1) DEFAULT 'N';
  lC_general_qualified_spouse     VARCHAR2(1) DEFAULT 'N';
  lC_aged_spouse                  VARCHAR2(1) DEFAULT 'N';
  lc_aged_employee                VARCHAR2(240);
  lc_aged_employee_flag           VARCHAR2(1) DEFAULT 'N';
  lc_action_info_category         pay_action_information.action_information_category%TYPE;
  lc_payroll_period_id            VARCHAR2(20);
  lc_element_set_name             pay_element_sets.element_set_name%TYPE;
  lc_month                        VARCHAR2(10);
  lc_payroll_start_period         VARCHAR2(20);
  lc_action_period                VARCHAR2(20);
  lc_termination_date             VARCHAR2(60);
  lc_tax_rate                     VARCHAR2(60);
  lc_spouse_exists_meaning        VARCHAR2(60);
  lC_general_qual_meaning         VARCHAR2(60);
  lC_aged_spouse_meaning          VARCHAR2(60);
  lc_aged_employee_meaning        VARCHAR2(60);
  lc_existence_meaning            VARCHAR2(60);
  lc_disable_type_meaning         VARCHAR2(60);
  lc_widow_type_meaning           VARCHAR2(60);
  lc_working_student_meaning      VARCHAR2(60);
  lc_hi_card_num                  VARCHAR2(20);
  lc_wpf_members_num              VARCHAR2(20);
  lc_basic_pension_num            VARCHAR2(20);
  lc_ei_num                       VARCHAR2(20);
  lc_nres_flag                    VARCHAR2(10);
  lc_spb_flag                     VARCHAR2(10);
  lc_dis_set_name                 VARCHAR2(10);
  lc_check_element_set_name       pay_element_sets.element_set_name%TYPE DEFAULT NULL;
  lc_check_month                   VARCHAR2(10) DEFAULT NULL;
  --
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_yea_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_yea_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_sal_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_sal_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_bon_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_bon_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_bn_action_info_id          pay_action_information.action_information_id%TYPE;
  ln_bn_obj_version_num         pay_action_information.object_version_number%TYPE;
  ln_pay_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_pay_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_emp_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_emp_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_prev_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_prev_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_dep_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_dep_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_ext_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_ext_obj_version_num        pay_action_information.object_version_number%TYPE;
  --
  ln_action_info_id1            pay_action_information.action_information_id%TYPE;
  ln_obj_version_num1           pay_action_information.object_version_number%TYPE;
  ln_assignment_id              per_all_assignments_f.assignment_id%TYPE := p_assignment_id;
  ln_next_assignment_action_id  NUMBER;
  ln_assignment_action_id       NUMBER:= NULL;
  ln_taxable_income             NUMBER;
  ln_si_prem                    NUMBER;
  ln_mutual_aid_prem            NUMBER;
  ln_itax                       NUMBER;
  i                             NUMBER;
  ln_with_hold_agent            NUMBER;
  ln_general_dependents         NUMBER;
  ln_specific_dependents        NUMBER;
  ln_elder_parents              NUMBER;
  ln_elder_dependents           NUMBER;
  ln_generally_disabled         NUMBER;
  ln_specially_dependents       NUMBER;
  ln_specially_dependents_lt    NUMBER;
  ln_payroll_id                 pay_payrolls_f.payroll_id%TYPE;
  ln_element_type_id            pay_element_types_f.element_type_id%TYPE;
  ln_input_value_id             pay_input_values_f.input_value_id%TYPE;
  ln_user_input_count           NUMBER:=0;
  lc_reporting_name             pay_element_types_f_tl.reporting_name%TYPE;
  ln_dependents                 NUMBER:=0;
  ln_tax_rate                   NUMBER:=0;
  ln_sal_si_premium             NUMBER:=0;
  ln_sal_total_earnings         NUMBER:=0;
  ln_sal_wpf_premium            NUMBER:=0;
  ln_sal_wp_premium             NUMBER:=0;
  ln_sal_ei_premium             NUMBER:=0;
  ln_sal_hi_premium             NUMBER:=0;
  ln_tot_si_premium             NUMBER:=0;
  ln_computed_tax_amount        NUMBER:=0;
  ln_bon_si_premium             NUMBER:=0;
  ln_bon_total_earnings         NUMBER:=0;
  ln_bon_wpf_premium            NUMBER:=0;
  ln_bon_wp_premium             NUMBER:=0;
  ln_bon_ei_premium             NUMBER:=0;
  ln_bon_hi_premium             NUMBER:=0;
  ln_element_set_id             NUMBER:=0;
  ln_yea_sal                    NUMBER:=0;
  ln_yea_bonus                  NUMBER:=0;
  ln_yea_sal_tax                NUMBER:=0;
  ln_yea_bon_tax                NUMBER:=0;
  ln_yea_sal_with_ded           NUMBER:=0;
  ln_yea_sal_deducion           NUMBER:=0;
  ln_yea_si_prem                NUMBER:=0;
  ln_yea_samll_comp_prem        NUMBER:=0;
  ln_yea_li_prem                NUMBER:=0;
  ln_yea_ei_prem                NUMBER:=0;
  ln_yea_spouse_income          NUMBER:=0;
  ln_yea_annual_tax             NUMBER:=0;
  ln_yea_over_short_tax         NUMBER:=0;
  ln_yea_tot_deduction_amt      NUMBER:=0;
  ln_yea_net_asseble_amt        NUMBER:=0;
  ln_yea_comptued_tax_amount    NUMBER:=0;
  ln_old_long_non_li_prem       NUMBER:=0;
  ln_sal_ci_premium             NUMBER:=0;
  ln_bon_ci_premium             NUMBER:=0;
  ln_amount                     NUMBER;
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
  ln_amount11                   NUMBER;
  ln_amount12                   NUMBER;
  ln_item_id                    NUMBER;
  ln_age                        NUMBER;
  ln_service_years              NUMBER;
  ln_yea_assignment_action_id   NUMBER;
  ln_pp_prem                    NUMBER;
  ln_npi_prem                   NUMBER;
  ln_housing_loan_credit        NUMBER;
  ln_spouse_sp_exempt           NUMBER;
  ln_basis_exmpt                NUMBER;
  ln_dependent_exmpt            NUMBER;
  ln_gen_spouse_exmpt           NUMBER;
  ln_gen_disable_exmpt          NUMBER;
  ln_total_exempt               NUMBER;
  ln_yea_tot_taxable_amt        NUMBER;
  ln_non_taxable_amount         NUMBER;
  ln_local_tax                  NUMBER;
  ln_tot_afte_si_ded            NUMBER;
  ln_sal_taxable_amount         NUMBER;
  ln_short_over_tax             NUMBER;
  ln_bon_taxable_amount         NUMBER;
  ln_otsu_depts                 NUMBER;
  ln_prev_job_income            NUMBER;
  ln_adj_emp_income             NUMBER;
  ln_prev_job_itax              NUMBER;
  ln_adj_emp_tax                NUMBER;
  ln_collected_tax_amount       NUMBER;
  ln_grace_tax                  NUMBER;
  ln_total_ded_amt              NUMBER;
  ln_net_balance                NUMBER;
  ln_ostax_action_id            NUMBER;
  ln_short_over_check_id        NUMBER;
  --
  ln_master_pact_id             NUMBER;
  ln_org_assign_act_id          NUMBER;
  --
  ld_termination_date           DATE;
  ld_effective_start_date       DATE;
  ld_payment_date               DATE;
  ld_wg_effective_date          DATE;
  ld_yea_effective_date         DATE;
  ld_yea_date_earned            DATE;
  ld_ostax_date                 DATE;
  --
  lr_proc_name                  lcu_proc_name%ROWTYPE;
  lr_extra_info                 extra_info;
  --
  lt_prev_jobs                  pay_jp_wic_pkg.t_prev_jobs;
  lt_prev_job_info              pay_jp_wic_pkg.t_prev_job_info;
  lt_certificate_info           pay_jp_wic_pkg.t_tax_info;
  lt_tax_info                   pay_jp_wic_pkg.t_tax_info;
  lt_wage_ledger                t_wage_ledger;
  lt_pay_wage_ledger            t_wage_ledger;
  lt_get_certificate_info	  pay_jp_wic_pkg.t_certificate_info;
  --
  l_itw_user_desc_kanji		  VARCHAR2(32767);
  l_itw_descriptions		  pay_jp_wic_pkg.t_descriptions;
  l_wtm_user_desc			  VARCHAR2(32767);
  l_wtm_user_desc_kanji		  VARCHAR2(32767);
  l_wtm_user_desc_kana		  VARCHAR2(32767);
  l_wtm_descriptions		  pay_jp_wic_pkg.t_descriptions;
  --
  l_itw_system_desc1_kanji	  VARCHAR2(32767);
  l_itw_system_desc2_kanji	  VARCHAR2(32767);
  l_wtm_system_desc_kanji	  VARCHAR2(32767);
  l_wtm_system_desc_kana	  VARCHAR2(32767);
  l_varchar2_tbl			  hr_jp_standard_pkg.t_varchar2_tbl;
  --
  BEGIN
    --
    gb_debug := hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'UPDATE_ARCH';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    lt_wage_ledger := gt_wage_ledger;
    ln_master_pact_id := p_payroll_action_id;
    --
    -- Fetch the Procedure Name
    --
    OPEN  lcu_proc_name ( TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'));
        FETCH lcu_proc_name INTO lr_proc_name;
    CLOSE lcu_proc_name;
    --
    IF gb_debug THEN
      hr_utility.set_location('Opening Employee Details cursor for ARCHIVE Assignment Id = '||ln_assignment_id,30);
      hr_utility.set_location('Update Employee Details Master Pact Id = ' || ln_master_pact_id ,30);
    END IF;
    --

    FOR lr_emp_rec  IN lcu_employee_details(ln_assignment_id,LAST_DAY(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM')))
    LOOP
    --
      -- initialize local arguments
    --
      ln_yea_assignment_action_id := null;
      ld_yea_effective_date := to_date(null);
      ld_yea_date_earned := to_date(null);
      ln_total_exempt := null;
      ln_yea_obj_version_num := null;
      ln_yea_action_info_id := null;
    --
      --
      OPEN  lcu_org_action_id(ln_master_pact_id,ln_assignment_id);
       FETCH lcu_org_action_id INTO ln_org_assign_act_id;
      CLOSE lcu_org_action_id;
      --
      IF TRUNC(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),'YEAR') >= TRUNC(lr_emp_rec.hire_date) THEN
         ld_effective_start_date := TRUNC(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),'YEAR');
      ELSE
       ld_effective_start_date := TRUNC(lr_emp_rec.hire_date);
      END IF;
      --
      ld_wg_effective_date := NVL(lr_emp_rec.termination_date,LAST_DAY(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM')));
      --
      IF lr_emp_rec.termination_date > lr_emp_rec.termination_date THEN
         lc_termination_date := NULL;
      ELSE
         lc_termination_date := fnd_date.date_to_canonical(lr_emp_rec.termination_date);
      END IF;
      --
      IF   gr_parameters.archive_option = 'UPDATE' THEN
      lc_hi_card_num        :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                                       ,p_input_value_name => 'HI_CARD_NUM'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                        );
      lc_basic_pension_num  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                                       ,p_input_value_name => 'BASIC_PENSION_NUM'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_wpf_members_num    :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                                       ,p_input_value_name => 'WPF_MEMBERS_NUM'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_ei_num             :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_LI_INFO'
                                                                       ,p_input_value_name => 'EI_NUM'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_itx_type            := pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                       ,p_input_value_name => 'ITX_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_with_hold_agent     :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                       ,p_input_value_name => 'WITHHOLD_AGENT'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_itax_yea_category   :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                       ,p_input_value_name => 'YEA_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lC_spouse_type         :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'SPOUSE_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_general_dependents  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_DEP'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_specific_dependents :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_SPECIFIC_DEP'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_elder_parents       := pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_ELDER_PARENT_LT'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_elder_dependents    :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_ELDER_DEP'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_generally_disabled  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_GEN_DISABLED'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_specially_dependents    :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_SEV_DISABLED'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_specially_dependents_lt  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_SEV_DISABLED_LT'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_widow_type               :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'WIDOW_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_disable_type             :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'DISABLE_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_working_student          :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'WORKING_STUDENT_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_aged_employee            :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'ELDER_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      --
      ln_age := TRUNC((TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM') - lr_emp_rec.date_of_birth)/365);
      --
      ln_service_years := ROUND((TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM') - lr_emp_rec.hire_date)/365);
        --
        OPEN  lcu_action_information_id(p_action_information_category => 'JP_WL_EMPLOYEE_DETAILS'
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id);
          FETCH lcu_action_information_id INTO ln_emp_obj_version_num,ln_emp_action_info_id;
        CLOSE lcu_action_information_id;
        --
        lc_itx_type_meaning := proc_lookup_meaning('JP_ITAX_TYPE',lc_itx_type);
        --
        IF ln_emp_action_info_id IS NOT NULL THEN
        pay_action_information_api.update_action_information
        (
         p_validate                       => FALSE
        ,p_action_information_id          => ln_emp_action_info_id
        ,p_object_version_number          => ln_emp_obj_version_num
        ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.organization_id)
        ,p_action_information2            => fnd_number.number_to_canonical(lr_emp_rec.payroll_id)
        ,p_action_information3            => fnd_number.number_to_canonical(ln_with_hold_agent)
        ,p_action_information4            => fnd_number.number_to_canonical(lr_emp_rec.location_id)
        ,p_action_information5            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
        ,p_action_information6            => lr_emp_rec.full_name_kana
        ,p_action_information7            => lr_emp_rec.full_name_kanji
        ,p_action_information8            => lr_emp_rec.payroll_name
        ,p_action_information9            => fnd_number.number_to_canonical(ln_age)
        ,p_action_information10           => lc_hi_card_num
        ,p_action_information11           => lc_wpf_members_num
        ,p_action_information12           => lc_basic_pension_num
        ,p_action_information13           => lc_ei_num
        ,p_action_information14           => fnd_date.date_to_canonical(lr_emp_rec.hire_date)
        ,p_action_information15           => fnd_number.number_to_canonical(ln_service_years)
        ,p_action_information16           => lc_itx_type_meaning
        ,p_action_information17           => lc_termination_date
        ,p_action_information18           => lr_emp_rec.organization_name
        ,p_action_information19           => lr_emp_rec.gender
        ,p_action_information20           => lr_emp_rec.job_title
        ,p_action_information21           => lr_emp_rec.postal_code
        ,p_action_information22           => lr_emp_rec.address_line1
        ,p_action_information23           => lr_emp_rec.address_line2
        ,p_action_information24           => lr_emp_rec.address_line3
        ,p_action_information25           => fnd_date.date_to_canonical(lr_emp_rec.date_of_birth)
        ,p_action_information26           => lr_emp_rec.employee_number
        ,p_action_information27           => lr_emp_rec.phone_number
        ,p_action_information28           => lr_emp_rec.address_line1_kana
        ,p_action_information29           => lr_emp_rec.address_line2_kana
        ,p_action_information30           => lr_emp_rec.address_line3_kana
        );
       END IF;
      -- Previous Employee Details
      --
      IF gb_debug THEN
        hr_utility.set_location('Before pay_jp_wic_pkg.get_certificate_info',30);
      END IF;
      --
     pay_jp_wic_pkg.get_certificate_info
      (
       p_assignment_action_id     => NULL
      ,p_assignment_id            => ln_assignment_id
      ,p_action_sequence          => NULL
      ,p_effective_date           => ld_wg_effective_date
      ,p_itax_organization_id     => ln_with_hold_agent
      ,p_itax_category            => lc_itx_type
      ,p_itax_yea_category        => NULL
      ,p_employment_category      => lr_emp_rec.employment_category
      ,p_person_id                => lr_emp_rec.person_id
      ,p_business_group_id        => gn_business_group_id
      ,p_date_earned              => ld_wg_effective_date
      ,p_certificate_info         => lt_certificate_info
      ,p_submission_required_flag => lc_submission_required_flag
      ,p_withholding_tax_info     => lt_tax_info
      ,p_prev_jobs                => lt_prev_jobs
      );
      --
      IF gb_debug THEN
        hr_utility.set_location('After pay_jp_wic_pkg.get_certificate_info',30);
      END IF;
      --
        i := lt_prev_jobs.first;
        WHILE  i IS NOT NULL LOOP
        --
        IF gb_debug THEN
           hr_utility.set_location('Inside Previous Employee Details loop',30);
        END IF;
        --

          OPEN  lcu_action_information_id(p_action_information_category => 'JP_WL_PREVIOUS_JOB_DETAILS'
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id);
          FETCH lcu_action_information_id INTO ln_prev_obj_version_num,ln_prev_action_info_id;
          CLOSE lcu_action_information_id;
          --

          IF ln_prev_action_info_id IS NOT NULL THEN
          pay_action_information_api.update_action_information
          (
           p_validate                       => FALSE
          ,p_action_information_id          => ln_prev_action_info_id
          ,p_object_version_number          => ln_prev_obj_version_num
          ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
          ,p_action_information2            => lt_prev_jobs(i).salary_payer_name_kanji
          ,p_action_information3            => lt_prev_jobs(i).salary_payer_address_kana
          ,p_action_information4            => fnd_number.number_to_canonical(lt_prev_jobs(i).taxable_income)
          ,p_action_information5            => fnd_number.number_to_canonical(lt_prev_jobs(i).si_prem)
          ,p_action_information6            => fnd_number.number_to_canonical(lt_prev_jobs(i).mutual_aid_prem)
          ,p_action_information7            => fnd_number.number_to_canonical(lt_prev_jobs(i).itax)
          ,p_action_information8            => fnd_date.date_to_canonical(lt_prev_jobs(i).termination_date)
          );
          END IF;
         --
        ln_prev_job_income  := NVL(ln_prev_job_income,0)+NVL(lt_prev_jobs(i).taxable_income,0);
        ln_prev_job_itax    := NVL(ln_prev_job_itax,0) + NVL(lt_prev_jobs(i).itax,0);
        i := lt_prev_jobs.next(i);
        --
        END LOOP;
        --
        IF gb_debug THEN
          hr_utility.set_location('After the Previous Employee Details loop',30);
        END IF;
        --
        -- End Previous Employee Details
        --
        --
        END IF; -- End only update option
        -- Payroll Information
        --
        IF gb_debug THEN
          hr_utility.set_location('Before the Payroll Information',30);
        END IF;
        --
        IF lr_emp_rec.payroll_id IS NOT NULL THEN
        --
        i := lt_wage_ledger.first;
        WHILE  i IS NOT NULL LOOP
          --
          IF gb_debug THEN
            hr_utility.set_location('In side the Pay wage ledger loop ',30);
          END IF;
          --
          IF lt_wage_ledger(i).org_information1 = lr_emp_rec.payroll_id  THEN
            --
            lt_pay_wage_ledger(i).org_information_id := lt_wage_ledger(i).org_information_id;
            lt_pay_wage_ledger(i).organization_id    := lt_wage_ledger(i).organization_id;
            lt_pay_wage_ledger(i).org_information1   := lt_wage_ledger(i).org_information1;
            lt_pay_wage_ledger(i).org_information2   := lt_wage_ledger(i).org_information2;
            lt_pay_wage_ledger(i).org_information3   := lt_wage_ledger(i).org_information3;
            lt_pay_wage_ledger(i).org_information4   := lt_wage_ledger(i).org_information4;
            lt_pay_wage_ledger(i).org_information5   := lt_wage_ledger(i).org_information5;
            lt_pay_wage_ledger(i).org_information6   := lt_wage_ledger(i).org_information6;
            lt_pay_wage_ledger(i).org_information7   := lt_wage_ledger(i).org_information7;
            lt_pay_wage_ledger(i).org_information8   := lt_wage_ledger(i).org_information8;
            lt_pay_wage_ledger(i).org_information9   := lt_wage_ledger(i).org_information9;
            lt_pay_wage_ledger(i).org_information10  := lt_wage_ledger(i).org_information10;
            lt_pay_wage_ledger(i).org_information11  := lt_wage_ledger(i).org_information11;
            lt_pay_wage_ledger(i).org_information12  := lt_wage_ledger(i).org_information12;
            lt_pay_wage_ledger(i).org_information13  := lt_wage_ledger(i).org_information13;
            --
          ELSIF ((lt_wage_ledger(i).org_information1 IS NULL) AND (lt_wage_ledger(i).organization_id = ln_with_hold_agent )) THEN
            --
            lt_pay_wage_ledger(i).org_information_id := lt_wage_ledger(i).org_information_id;
            lt_pay_wage_ledger(i).organization_id    := lt_wage_ledger(i).organization_id;
            lt_pay_wage_ledger(i).org_information1   := lt_wage_ledger(i).org_information1;
            lt_pay_wage_ledger(i).org_information2   := lt_wage_ledger(i).org_information2;
            lt_pay_wage_ledger(i).org_information3   := lt_wage_ledger(i).org_information3;
            lt_pay_wage_ledger(i).org_information4   := lt_wage_ledger(i).org_information4;
            lt_pay_wage_ledger(i).org_information5   := lt_wage_ledger(i).org_information5;
            lt_pay_wage_ledger(i).org_information6   := lt_wage_ledger(i).org_information6;
            lt_pay_wage_ledger(i).org_information7   := lt_wage_ledger(i).org_information7;
            lt_pay_wage_ledger(i).org_information8   := lt_wage_ledger(i).org_information8;
            lt_pay_wage_ledger(i).org_information9   := lt_wage_ledger(i).org_information9;
            lt_pay_wage_ledger(i).org_information10  := lt_wage_ledger(i).org_information10;
            lt_pay_wage_ledger(i).org_information11  := lt_wage_ledger(i).org_information11;
            lt_pay_wage_ledger(i).org_information12  := lt_wage_ledger(i).org_information12;
            lt_pay_wage_ledger(i).org_information13  := lt_wage_ledger(i).org_information13;
            --
          END IF;
            ln_user_input_count := ln_user_input_count + 1;
            --
          i := lt_wage_ledger.next(i);
        END LOOP;
        --
        IF gb_debug THEN
            hr_utility.set_location('ln_user_input_count =', ln_user_input_count);
        END IF;
        --
        lc_payroll_period_id := gr_parameters.subject_yyyymm;
           --
           IF ln_user_input_count > 0 THEN
           --
           i := lt_pay_wage_ledger.first;
           WHILE  i IS NOT NULL LOOP
           --
           OPEN  lcu_payment_action_date (p_assignment_id             =>   ln_assignment_id
                                         ,p_payroll_start_period   => lc_payroll_period_id
                                         ,p_payroll_end_period     => lc_payroll_period_id
                                        );
           LOOP
           FETCH lcu_payment_action_date INTO ld_payment_date,lc_element_set_name,ln_assignment_action_id;
           EXIT WHEN lcu_payment_action_date%NOTFOUND;
           --
           IF lc_element_set_name IN ('SAL','BON','SPB') THEN  -- Bug No 8911344
             --
             lc_month := TO_CHAR(ld_payment_date,'MM');
             lc_action_period := TO_CHAR(ld_payment_date,'YYYYMM');  -- Added for bug 8830343
             IF ( ((lc_month<> lc_check_month) OR lc_check_month IS NULL OR lc_check_element_set_name IS NULL) OR (lc_month = lc_check_month AND lc_check_element_set_name <> lc_element_set_name))THEN -- Bug 9031713
               lc_check_month := lc_month;
               lc_check_element_set_name := lc_element_set_name;

             --
             IF lt_pay_wage_ledger(i).org_information5 = 'ELEMENT' THEN
             --
             ln_amount := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                             ,p_payroll_period   => lc_action_period  -- Changed for bug 8830343
                                             ,p_element_type_id  => fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information7)
                                             ,p_input_value_id   => fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information8)
                                            );
             --
             --Getting reporting name
             --
             ln_item_id := lt_pay_wage_ledger(i).org_information7;
             --
             IF lt_wage_ledger(i).org_information12  IS NULL THEN
               OPEN   lcu_element_report_name(fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information7)
                                             ,TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'));
                 FETCH lcu_element_report_name INTO lc_reporting_name;
               CLOSE lcu_element_report_name;
             ELSE
               lc_reporting_name := lt_wage_ledger(i).org_information12;
             END IF;
             --
             ELSIF lt_pay_wage_ledger(i).org_information5 = 'BALANCE' THEN
             --

               ln_amount := pay_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                      ,p_payroll_period       => lc_action_period  -- Changed for bug 8830343
                                                      ,p_element_set_name     => lc_element_set_name
                                                      ,p_balance_type_id      => fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information10)
                                                      ,p_balance_dimension_id => fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information11));
             --Getting reporting name
             --
             ln_item_id := lt_pay_wage_ledger(i).org_information10;
             --
             IF lt_wage_ledger(i).org_information12  IS NULL THEN
               OPEN   lcu_balance_report_name(fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information10));
                 FETCH lcu_balance_report_name INTO lc_reporting_name;
               CLOSE lcu_balance_report_name;
             ELSE
               lc_reporting_name := lt_wage_ledger(i).org_information12;
             END IF;
             --
          END IF;
          --
          CASE
              WHEN lc_month = '01' THEN ln_amount1:=  ln_amount;
              WHEN lc_month = '02' THEN ln_amount2:=  ln_amount;
              WHEN lc_month = '03' THEN ln_amount3:=  ln_amount;
              WHEN lc_month = '04' THEN ln_amount4:=  ln_amount;
              WHEN lc_month = '05' THEN ln_amount5:=  ln_amount;
              WHEN lc_month = '06' THEN ln_amount6:=  ln_amount;
              WHEN lc_month = '07' THEN ln_amount7:=  ln_amount;
              WHEN lc_month = '08' THEN ln_amount8:=  ln_amount;
              WHEN lc_month = '09' THEN ln_amount9:=  ln_amount;
              WHEN lc_month = '10' THEN ln_amount10:=  ln_amount;
              WHEN lc_month = '11' THEN ln_amount11:=  ln_amount;
              WHEN lc_month = '12' THEN ln_amount12:=  ln_amount;
              ELSE  lc_month := NULL;
          END CASE;
          --
          CASE
            WHEN  lt_pay_wage_ledger(i).org_information2 = 'SAL_EARN' THEN lc_action_info_category := 'JP_WL_SAL_EARN';

            WHEN  lt_pay_wage_ledger(i).org_information2 = 'SAL_DCT'  THEN lc_action_info_category := 'JP_WL_SAL_DCT';

            WHEN  lt_pay_wage_ledger(i).org_information2 = 'WRK_DAYS' THEN lc_action_info_category := 'JP_WL_WRK_HOURS_DAYS';


            WHEN  lt_pay_wage_ledger(i).org_information2 = 'BON_EARN' THEN lc_action_info_category := 'JP_WL_BON_EARN';


            WHEN  lt_pay_wage_ledger(i).org_information2 = 'BON_DCT'  THEN lc_action_info_category := 'JP_WL_BON_DCT';
            ELSE  lc_action_info_category := NULL;
          END CASE;
          --
          END IF; -- Bug No 9031713
          END IF; -- Bug No 8911344

          END LOOP;
          CLOSE lcu_payment_action_date;
          --
          IF gb_debug THEN
            hr_utility.set_location('ln_assignment_id ='||ln_assignment_id,30);
            hr_utility.set_location('lc_action_info_category  ='||lc_action_info_category ,31);
            hr_utility.set_location('ln_item_id ='||ln_item_id,30);
            hr_utility.set_location('Before UPDATE API',30);
          END IF;
          --
          ln_action_info_id  := NULL;
          ln_obj_version_num := NULL;
          ln_pay_action_info_id := NULL;
          ln_bn_action_info_id  := NULL;
          --
          IF (lc_action_info_category ='JP_WL_SAL_EARN' OR lc_action_info_category = 'JP_WL_SAL_DCT' OR lc_action_info_category = 'JP_WL_WRK_HOURS_DAYS') THEN
            --
              OPEN  lcu_item_action_info_id(p_action_information_category => lc_action_info_category
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id
                                       ,p_action_information2         => ln_item_id);
              FETCH lcu_item_action_info_id INTO ln_pay_obj_version_num
                                                ,ln_pay_action_info_id
                                                ,ln_amount1
                                                ,ln_amount2
                                                ,ln_amount3
                                                ,ln_amount4
                                                ,ln_amount5
                                                ,ln_amount6
                                                ,ln_amount7
                                                ,ln_amount8
                                                ,ln_amount9
                                                ,ln_amount10
                                                ,ln_amount11
                                                ,ln_amount12;

              CLOSE lcu_item_action_info_id;
              --
              CASE
              WHEN lc_month = '01' THEN ln_amount1:=  ln_amount;
              WHEN lc_month = '02' THEN ln_amount2:=  ln_amount;
              WHEN lc_month = '03' THEN ln_amount3:=  ln_amount;
              WHEN lc_month = '04' THEN ln_amount4:=  ln_amount;
              WHEN lc_month = '05' THEN ln_amount5:=  ln_amount;
              WHEN lc_month = '06' THEN ln_amount6:=  ln_amount;
              WHEN lc_month = '07' THEN ln_amount7:=  ln_amount;
              WHEN lc_month = '08' THEN ln_amount8:=  ln_amount;
              WHEN lc_month = '09' THEN ln_amount9:=  ln_amount;
              WHEN lc_month = '10' THEN ln_amount10:=  ln_amount;
              WHEN lc_month = '11' THEN ln_amount11:=  ln_amount;
              WHEN lc_month = '12' THEN ln_amount12:=  ln_amount;
              ELSE  lc_month := NULL;
             END CASE;
              --
             IF ln_pay_action_info_id IS NOT NULL THEN

             pay_action_information_api.update_action_information
            (
             p_validate                       => FALSE
            ,p_action_information_id          => ln_pay_action_info_id
            ,p_object_version_number          => ln_pay_obj_version_num
            ,p_action_information1            => lt_wage_ledger(i).org_information3
            ,p_action_information2            => fnd_number.number_to_canonical(ln_item_id)
            ,p_action_information3            => lt_wage_ledger(i).org_information5
            ,p_action_information4            => lc_reporting_name
            ,p_action_information5            => fnd_number.number_to_canonical(lt_wage_ledger(i).org_information13)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_amount1)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_amount2)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_amount3)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_amount4)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_amount5)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_amount6)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_amount7)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_amount8)
            ,p_action_information14           => fnd_number.number_to_canonical(ln_amount9)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_amount10)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_amount11)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_amount12)
            ,p_action_information18          => NULL -- ln_secondary_dependents
              );
           END IF;
           --
          ELSIF (lc_action_info_category ='JP_WL_BON_EARN' OR lc_action_info_category = 'JP_WL_BON_DCT') THEN
            --

            OPEN  lcu_bon_action_info_id(p_action_information_category => lc_action_info_category
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id
                                       ,p_action_information3         => ln_item_id);
            FETCH lcu_bon_action_info_id INTO ln_bn_obj_version_num
                                                ,ln_bn_action_info_id
                                                ,ln_amount1
                                                ,ln_amount2
                                                ,ln_amount3
                                                ,ln_amount4
                                                ,ln_amount5
                                                ,ln_amount6
                                                ,ln_amount7
                                                ,ln_amount8
                                                ,ln_amount9
                                                ,ln_amount10
                                                ,ln_amount11
                                                ,ln_amount12;
            CLOSE lcu_bon_action_info_id;
            --
            CASE
              WHEN lc_month = '01' THEN ln_amount1:=  ln_amount;
              WHEN lc_month = '02' THEN ln_amount2:=  ln_amount;
              WHEN lc_month = '03' THEN ln_amount3:=  ln_amount;
              WHEN lc_month = '04' THEN ln_amount4:=  ln_amount;
              WHEN lc_month = '05' THEN ln_amount5:=  ln_amount;
              WHEN lc_month = '06' THEN ln_amount6:=  ln_amount;
              WHEN lc_month = '07' THEN ln_amount7:=  ln_amount;
              WHEN lc_month = '08' THEN ln_amount8:=  ln_amount;
              WHEN lc_month = '09' THEN ln_amount9:=  ln_amount;
              WHEN lc_month = '10' THEN ln_amount10:=  ln_amount;
              WHEN lc_month = '11' THEN ln_amount11:=  ln_amount;
              WHEN lc_month = '12' THEN ln_amount12:=  ln_amount;
              ELSE  lc_month := NULL;
            END CASE;
            --
            ln_action_info_id  := NULL;
            ln_obj_version_num := NULL;
            --
            OPEN   lcu_bonus_element_set(ln_item_id);
               FETCH  lcu_bonus_element_set INTO lc_spb_flag;
            CLOSE  lcu_bonus_element_set;
            --
            IF lc_spb_flag IS NULL THEN
                lc_dis_set_name :='BON';
             ELSE
               lc_dis_set_name :='SPB';
            END IF;
            --
            IF ln_bn_action_info_id IS NOT NULL THEN
            --
            pay_action_information_api.update_action_information
           (
                 p_validate                       => FALSE
            ,p_action_information_id          => ln_bn_action_info_id
            ,p_object_version_number          => ln_bn_obj_version_num
            ,p_action_information1            => lt_wage_ledger(i).org_information2
            ,p_action_information2            => lt_wage_ledger(i).org_information3
            ,p_action_information3            => fnd_number.number_to_canonical(ln_item_id)
            ,p_action_information4            => lt_wage_ledger(i).org_information5
            ,p_action_information5            => lc_reporting_name
            ,p_action_information6            => fnd_number.number_to_canonical(lt_wage_ledger(i).org_information13)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_amount1)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_amount2)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_amount3)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_amount4)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_amount5)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_amount6)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_amount7)
            ,p_action_information14           => fnd_number.number_to_canonical(ln_amount8)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_amount9)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_amount10)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_amount11)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_amount12)
            ,p_action_information19           => NULL
            ,p_action_information20           => lc_dis_set_name
            );
           END IF;
           --
          END IF;
          --
          ln_amount1 := NULL;
          ln_amount2 := NULL;
          ln_amount3 := NULL;
          ln_amount4 := NULL;
          ln_amount5 := NULL;
          ln_amount6 := NULL;
          ln_amount7 := NULL;
          ln_amount8 := NULL;
          ln_amount9 := NULL;
          ln_amount10 := NULL;
          ln_amount11 := NULL;
          ln_amount12 := NULL;
          ln_amount   := NULL;
          lc_spb_flag := NULL;
          i := lt_pay_wage_ledger.next(i);
        END LOOP;
        --
        END IF;  -- End if of ln_user_input_count
        -- End Payroll Information
        --
        lc_payroll_period_id := gr_parameters.subject_yyyymm;
        --
        OPEN  lcu_payment_action_date (   p_assignment_id          =>  ln_assignment_id
                                         ,p_payroll_start_period   =>  lc_payroll_period_id
                                         ,p_payroll_end_period     =>  lc_payroll_period_id
                                        );
        LOOP
        --
          -- initialize local arguments
        --
          ln_ostax_action_id := null;
          ld_ostax_date := to_date(null);
          ln_short_over_check_id := null;
          ln_short_over_tax := null;
        --
        FETCH lcu_payment_action_date INTO ld_payment_date,lc_element_set_name,ln_assignment_action_id;
        EXIT WHEN lcu_payment_action_date%NOTFOUND;

        lc_month := TO_CHAR(ld_payment_date,'MM');

        IF ( ((lc_month<> lc_check_month) OR lc_check_month IS NULL OR lc_check_element_set_name IS NULL) OR (lc_month = lc_check_month AND lc_check_element_set_name <> lc_element_set_name))THEN -- 9031713
        lc_check_month := lc_month;
        lc_check_element_set_name := lc_element_set_name;
        lc_action_period := TO_CHAR(ld_payment_date,'YYYYMM');


        -- Start Monthly Payroll Deductions and Tax Information
        --
          --
          -- Fetching Number of dependents
          --
          IF gb_debug THEN
            hr_utility.set_location('ln_assignment_id ='||ln_assignment_id,30);
            hr_utility.set_location('ld_payment_date ='||ld_payment_date,30);
            hr_utility.set_location('lc_element_set_name ='||lc_element_set_name,30);
            hr_utility.set_location('Before Monthly Salary Information',30);
          END IF;
          --
          IF  lc_element_set_name = 'SAL' THEN
          --
          --
          IF gb_debug THEN
            hr_utility.set_location('Inside Salary Loop',30);
            hr_utility.set_location('lc_action_period =' ||lc_action_period,30);
          END IF;
          --
          ln_dependents :=   pay_jp_balance_pkg.get_result_value_number (p_element_name  =>  'SAL_ITX'
                                                     ,p_input_value_name    => 'NUM_OF_DEP'
                                                     ,p_assignment_action_id => ln_assignment_action_id
                                                     );
          --
          -- Fetching Payment Date
          --
          --
          ln_sal_ci_premium := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                                ,p_payroll_period   => lc_action_period
                                                ,p_element_name  => 'SAL_CI_PREM_EE'
                                                ,p_input_name    => 'Pay Value');

          ln_computed_tax_amount :=   pay_sal_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                                ,p_payroll_period       => lc_action_period
                                                                ,p_balance_name         => 'B_SAL_ITX'
                                                               ,p_dimension_name       => '_ASG_RUN'
                                                              );
          ln_sal_si_premium := pay_sal_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                         ,p_payroll_period       => lc_action_period
                                                         ,p_balance_name         => 'B_SAL_SI_PREM'
                                                         ,p_dimension_name       => '_ASG_RUN'
                                                         );

          ln_sal_total_earnings := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_ERN'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );
          ln_sal_wpf_premium   := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_WPF_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );

          ln_sal_wp_premium   := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_WP_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );
          ln_sal_ei_premium   := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_EI_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );
          ln_sal_hi_premium   := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_HI_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );
          ln_sal_taxable_amount :=  pay_sal_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_SAL_TXBL_ERN_MONEY'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              );

          ln_local_tax := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                                ,p_payroll_period  => lc_action_period
                                                ,p_element_name  => 'SAL_LTX'
                                                ,p_input_name    => 'Pay Value');

         ln_total_ded_amt := pay_sal_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                            ,p_payroll_period       => lc_action_period
                                                            ,p_balance_name         => 'B_SAL_DCT'
                                                            ,p_dimension_name       => '_ASG_RUN'
                                                            );

          --
          -- Over and Tax Amount
          --
          OPEN  lcu_over_short_tax_id (p_assignment_id        => ln_assignment_id
                                      ,p_payroll_period       => lc_action_period
                               );
          FETCH lcu_over_short_tax_id  INTO ln_ostax_action_id
                                           ,ld_ostax_date;
          CLOSE lcu_over_short_tax_id;
          --
          IF ln_ostax_action_id IS NOT NULL THEN
            --
            OPEN   lcu_over_short_check(p_payroll_period    =>    lc_action_period
                                       ,p_assignment_id     =>    ln_assignment_id
                                       ,p_element_set_name  =>    lc_element_set_name);

            FETCH lcu_over_short_check INTO ln_short_over_check_id;
            CLOSE lcu_over_short_check;
            --
            IF ln_short_over_check_id  IS NOT NULL THEN
              --
              OPEN  lcu_over_short_tax_amount(p_payment_date           => ld_ostax_date
                                           ,p_assignment_action_id   => ln_ostax_action_id
                                           );
              FETCH lcu_over_short_tax_amount INTO ln_short_over_tax ;
              CLOSE lcu_over_short_tax_amount;
              --
            END IF;
            --
          END IF;
          --
        --
         ln_tot_si_premium := NVL(ln_sal_wp_premium,0)  + NVL(ln_sal_hi_premium,0) + NVL(ln_sal_wpf_premium,0) + NVL(ln_sal_ei_premium,0);
         ln_non_taxable_amount := NVL(ln_sal_total_earnings,0) - NVL(ln_sal_taxable_amount,0);
         ln_collected_tax_amount := NVL(ln_computed_tax_amount,0) + NVL(ln_short_over_tax,0);
         ln_net_balance := NVL(ln_sal_total_earnings,0)-NVL(ln_total_ded_amt,0);
         ln_tot_afte_si_ded  := NVL(ln_sal_total_earnings,0) - NVL(ln_tot_si_premium,0);
          --
            OPEN  lcu_pay_action_info_id(p_action_information_category => 'JP_WL_MNTH_PAY_INFO'
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id
                                       ,p_action_information2         => fnd_date.date_to_canonical(ld_payment_date));
            FETCH lcu_pay_action_info_id INTO ln_sal_obj_version_num,ln_sal_action_info_id;
            CLOSE lcu_pay_action_info_id;
            --
         IF ln_sal_action_info_id IS NOT NULL THEN
            pay_action_information_api.update_action_information
           (
                 p_validate                       => FALSE
            ,p_action_information_id          => ln_sal_action_info_id
            ,p_object_version_number          => ln_sal_obj_version_num
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_date.date_to_canonical(ld_payment_date)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_sal_taxable_amount)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_non_taxable_amount)
            ,p_action_information5            => fnd_number.number_to_canonical(ln_sal_total_earnings)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_sal_si_premium)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_sal_hi_premium)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_sal_wp_premium)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_sal_wpf_premium)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_sal_ei_premium)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_tot_si_premium)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_tot_afte_si_ded)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_dependents)
            ,p_action_information14           => NULL --fnd_number.number_to_canonical(lc_tax_rate)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_computed_tax_amount)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_short_over_tax)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_collected_tax_amount)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_sal_ci_premium)
            ,p_action_information19           => fnd_number.number_to_canonical(ln_local_tax)
            ,p_action_information20           => fnd_number.number_to_canonical(ln_total_ded_amt)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_net_balance)
            );
           ELSIF (ln_sal_action_info_id IS NULL AND   gr_parameters.archive_option = 'ADD') THEN
             pay_action_information_api.create_action_information
             (
             p_validate                       => FALSE
            ,p_action_context_id              => ln_org_assign_act_id
            ,p_action_context_type            => 'AAP'
            ,p_action_information_category    => 'JP_WL_MNTH_PAY_INFO'
            ,p_tax_unit_id                    => NULL
            ,p_jurisdiction_code              => NULL
            ,p_source_id                      => NULL
            ,p_source_text                    => NULL
            ,p_tax_group                      => NULL
            ,p_effective_date                 => p_effective_date
            ,p_assignment_id                  => ln_assignment_id
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_date.date_to_canonical(ld_payment_date)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_sal_taxable_amount)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_non_taxable_amount)
            ,p_action_information5            => fnd_number.number_to_canonical(ln_sal_total_earnings)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_sal_si_premium)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_sal_hi_premium)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_sal_wp_premium)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_sal_wpf_premium)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_sal_ei_premium)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_tot_si_premium)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_tot_afte_si_ded)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_dependents)
            ,p_action_information14           => NULL --fnd_number.number_to_canonical(ln_tax_rate)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_computed_tax_amount)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_short_over_tax)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_collected_tax_amount)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_sal_ci_premium)
            ,p_action_information19           => fnd_number.number_to_canonical(ln_local_tax)
            ,p_action_information20           => fnd_number.number_to_canonical(ln_total_ded_amt)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_net_balance)
            ,p_action_information_id          => ln_sal_action_info_id
            ,p_object_version_number          => ln_sal_obj_version_num
            );
           END IF;
           --
          IF gb_debug THEN
            hr_utility.set_location('After Salary Loop',30);
            hr_utility.set_location('lc_action_period =' ||lc_action_period,30);
          END IF;
          --

          ELSIF (lc_element_set_name = 'BON'  OR  lc_element_set_name = 'SPB')  THEN

          IF gb_debug THEN
            hr_utility.set_location('Inside Bonus Loop',30);
            hr_utility.set_location('lc_action_period =' ||lc_action_period,30);
          END IF;
          --
          ln_bon_wp_premium  := NULL;
          ln_bon_wpf_premium := NULL;
          ln_bon_hi_premium  := NULL;
          ln_bon_ci_premium  := NULL;
          ln_bon_si_premium  := NULL;
          --
          IF lc_element_set_name = 'BON'  THEN
             --
             ln_total_ded_amt := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                               ,p_payroll_period       => lc_action_period
                                                               ,p_balance_name         => 'B_BON_DCT'
                                                               ,p_dimension_name       => '_ASG_RUN'
                                                               ,p_element_set_name     => lc_element_set_name
                                                              );
             lc_tax_rate := tax_rate_value( p_assignment_id    => ln_assignment_id
                                                ,p_payroll_period   => lc_action_period
                                                ,p_element_name  => 'BON_ITX'
                                                ,p_input_name    => 'ITX_RATE');

             ln_bon_ci_premium := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                                ,p_payroll_period   => lc_action_period
                                                ,p_element_name  => 'BON_CI_PREM_EE'
                                                ,p_input_name    => 'Pay Value');

              ln_dependents :=   pay_jp_balance_pkg.get_result_value_number (p_element_name  =>  'BON_ITX'
                                                     ,p_input_value_name    => 'NUM_OF_DEP'
                                                     ,p_assignment_action_id => ln_assignment_action_id
                                                     );

            ln_computed_tax_amount := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_BON_ITX'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                             );
           ln_bon_si_premium := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                         ,p_payroll_period       => lc_action_period
                                                         ,p_balance_name         => 'B_BON_SI_PREM'
                                                         ,p_dimension_name       => '_ASG_RUN'
                                                         ,p_element_set_name     => lc_element_set_name
                                                        );

           ln_bon_total_earnings := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_BON_ERN'
                                                             ,p_dimension_name       => '_ASG_RUN'
                                                             ,p_element_set_name     => lc_element_set_name
                                                           );
           ln_bon_wpf_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                            ,p_payroll_period       => lc_action_period
                                                            ,p_balance_name         => 'B_BON_WPF_PREM'
                                                            ,p_dimension_name       => '_ASG_RUN'
                                                            ,p_element_set_name     => lc_element_set_name
                                                           );
           ln_bon_wp_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                           ,p_payroll_period       => lc_action_period
                                                           ,p_balance_name         => 'B_BON_WP_PREM'
                                                           ,p_dimension_name       => '_ASG_RUN'
                                                            ,p_element_set_name     => lc_element_set_name
                                                          );
           ln_bon_ei_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                           ,p_payroll_period       => lc_action_period
                                                           ,p_balance_name         => 'B_BON_EI_PREM'
                                                           ,p_dimension_name       => '_ASG_RUN'
                                                           ,p_element_set_name     => lc_element_set_name
                                                           );
           ln_bon_hi_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                           ,p_payroll_period       =>  lc_action_period
                                                           ,p_balance_name         => 'B_BON_HI_PREM'
                                                           ,p_dimension_name       => '_ASG_RUN'
                                                           ,p_element_set_name     => lc_element_set_name
                                                           );
           ln_bon_taxable_amount :=  pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_BON_TXBL_ERN_MONEY'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                              );

          ELSE
            --
              ln_total_ded_amt := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                                ,p_payroll_period       => lc_action_period
                                                                ,p_balance_name         => 'B_SPB_DCT'
                                                                ,p_dimension_name       => '_ASG_RUN'
                                                                ,p_element_set_name     => lc_element_set_name
                                                               );
             lc_tax_rate := tax_rate_value( p_assignment_id    => ln_assignment_id
                                        ,p_payroll_period   => lc_action_period
                                        ,p_element_name  => 'SPB_ITX'
                                        ,p_input_name    => 'ITX_RATE');


             ln_dependents :=   pay_jp_balance_pkg.get_result_value_number (p_element_name  =>  'SPB_ITX'
                                                     ,p_input_value_name    => 'NUM_OF_DEP'
                                                     ,p_assignment_action_id => ln_assignment_action_id
                                                     );

             ln_computed_tax_amount := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_SPB_ITX'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                             );

             ln_bon_total_earnings := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_SPB_ERN'
                                                             ,p_dimension_name       => '_ASG_RUN'
                                                             ,p_element_set_name     => lc_element_set_name
                                                           );
             ln_bon_ei_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                           ,p_payroll_period       => lc_action_period
                                                           ,p_balance_name         => 'B_SPB_EI_PREM'
                                                           ,p_dimension_name       => '_ASG_RUN'
                                                           ,p_element_set_name     => lc_element_set_name
                                                           );
             ln_bon_taxable_amount :=  pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_SPB_TXBL_ERN_MONEY'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                              );


            --
          END IF;
          --
          --
          -- Over and Tax Amount
          --
          OPEN  lcu_over_short_tax_id (p_assignment_id        => ln_assignment_id
                                      ,p_payroll_period       => lc_action_period
                               );
          FETCH lcu_over_short_tax_id  INTO ln_ostax_action_id
                                           ,ld_ostax_date;
          CLOSE lcu_over_short_tax_id;
          --
          IF ln_ostax_action_id IS NOT NULL THEN
            --
            OPEN   lcu_over_short_check(p_payroll_period    =>    lc_action_period
                                       ,p_assignment_id     =>    ln_assignment_id
                                       ,p_element_set_name  =>    lc_element_set_name);

            FETCH lcu_over_short_check INTO ln_short_over_check_id;
            CLOSE lcu_over_short_check;
            --
            IF ln_short_over_check_id  IS NOT NULL THEN
              --
              OPEN  lcu_over_short_tax_amount(p_payment_date           => ld_ostax_date
                                           ,p_assignment_action_id   => ln_ostax_action_id
                                           );
              FETCH lcu_over_short_tax_amount INTO ln_short_over_tax ;
              CLOSE lcu_over_short_tax_amount;
              --
            END IF;
            --
          END IF;
          --
          ln_non_taxable_amount := NVL(ln_bon_total_earnings,0) - NVL(ln_bon_taxable_amount,0);
          ln_tot_si_premium := NVL(ln_bon_wp_premium,0)  + NVL(ln_bon_hi_premium,0) + NVL(ln_bon_wpf_premium,0) + NVL(ln_bon_ei_premium,0);
          ln_collected_tax_amount := NVL(ln_computed_tax_amount,0) + NVL(ln_short_over_tax,0);
          ln_net_balance := NVL(ln_bon_total_earnings,0)-NVL(ln_total_ded_amt,0);
          ln_tot_afte_si_ded  := NVL(ln_bon_total_earnings,0) - NVL(ln_tot_si_premium,0);
          --

            OPEN  lcu_pay_action_info_id(p_action_information_category =>  'JP_WL_BON_PAY_INFO'
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id
                                       ,p_action_information2            => fnd_date.date_to_canonical(ld_payment_date));
            FETCH lcu_pay_action_info_id INTO ln_bon_obj_version_num,ln_bon_action_info_id;
            CLOSE lcu_pay_action_info_id;
            --
            IF ln_bon_action_info_id IS NOT NULL THEN
            --
            pay_action_information_api.update_action_information
           (
             p_validate                       => FALSE
            ,p_action_information_id          => ln_bon_action_info_id
            ,p_object_version_number          => ln_bon_obj_version_num
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_date.date_to_canonical(ld_payment_date)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_bon_taxable_amount)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_non_taxable_amount )
            ,p_action_information5            => fnd_number.number_to_canonical(ln_bon_total_earnings)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_bon_si_premium)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_bon_hi_premium)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_bon_wp_premium)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_bon_wpf_premium)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_bon_ei_premium)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_tot_si_premium)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_tot_afte_si_ded)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_dependents)
            ,p_action_information14           => lc_tax_rate
            ,p_action_information15           => fnd_number.number_to_canonical(ln_computed_tax_amount)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_short_over_tax)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_collected_tax_amount)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_bon_ci_premium)
            ,p_action_information19           => NULL
            ,p_action_information20           => fnd_number.number_to_canonical(ln_total_ded_amt)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_net_balance)
            ,p_action_information22           => lc_element_set_name
            );
            ELSIF (ln_bon_action_info_id IS NULL AND   gr_parameters.archive_option = 'ADD') THEN
              pay_action_information_api.create_action_information
             (
             p_validate                       => FALSE
            ,p_action_context_id              => ln_org_assign_act_id
            ,p_action_context_type            => 'AAP'
            ,p_action_information_category    => 'JP_WL_BON_PAY_INFO'
            ,p_tax_unit_id                    => NULL
            ,p_jurisdiction_code              => NULL
            ,p_source_id                      => NULL
            ,p_source_text                    => NULL
            ,p_tax_group                      => NULL
            ,p_effective_date                 => p_effective_date
            ,p_assignment_id                  => ln_assignment_id
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_date.date_to_canonical(ld_payment_date)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_bon_taxable_amount)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_non_taxable_amount )
            ,p_action_information5            => fnd_number.number_to_canonical(ln_bon_total_earnings)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_bon_si_premium)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_bon_hi_premium)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_bon_wp_premium)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_bon_wpf_premium)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_bon_ei_premium)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_tot_si_premium)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_tot_afte_si_ded)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_dependents)
            ,p_action_information14           => lc_tax_rate
            ,p_action_information15           => fnd_number.number_to_canonical(ln_computed_tax_amount)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_short_over_tax)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_collected_tax_amount)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_bon_ci_premium)
            ,p_action_information19           => NULL
            ,p_action_information20           => fnd_number.number_to_canonical(ln_total_ded_amt)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_net_balance)
            ,p_action_information22           => lc_element_set_name
            ,p_action_information_id          => ln_bon_action_info_id
            ,p_object_version_number          => ln_bon_obj_version_num
            );
            END IF;
          --
          IF gb_debug THEN
            hr_utility.set_location('After Bonus Loop',30);
            hr_utility.set_location('lc_action_period =' ||lc_action_period,30);
          END IF;

           END IF;  -- End if for Monthly Payroll and Bonus information
          --
           END IF;
          END LOOP;
          --
        CLOSE lcu_payment_action_date ;

        END IF; -- End if for payroll id
        --
        --
        --End Monthly Payroll Deductions and Tax Information
        IF gb_debug THEN
          hr_utility.set_location('After the Payroll Information',30);
        END IF;
        --
        IF   ( gr_parameters.archive_option = 'UPDATE' OR  gr_parameters.archive_option = 'ADD')THEN
        --
        IF gb_debug THEN
          hr_utility.set_location('Before the YEA Information',30);
        END IF;
          --
        OPEN  lcu_yea_info_id(p_payroll_period       => lc_payroll_period_id
                               ,p_assignment_id      => ln_assignment_id
                               );
        FETCH lcu_yea_info_id INTO ln_yea_assignment_action_id
                                  ,ld_yea_effective_date
                                  ,ld_yea_date_earned;
        CLOSE lcu_yea_info_id;

         IF ln_yea_assignment_action_id IS NOT NULL THEN
          --
          -- Added for bug no  8830562
          --
          lc_submission_required_flag:= NULL;
          lt_tax_info                := NULL;
          lc_action_period := TO_CHAR(ld_yea_effective_date,'YYYYMM');
          --
          pay_jp_wic_pkg.get_certificate_info(
			  	 p_assignment_action_id		=> ln_yea_assignment_action_id
				,p_assignment_id			=> ln_assignment_id
				,p_action_sequence		=> NULL
				,p_business_group_id		=> gn_business_group_id
				,p_effective_date		      => ld_yea_effective_date
				,p_date_earned			=> ld_yea_date_earned
				,p_itax_organization_id		=> ln_with_hold_agent
				,p_itax_category			=> lc_itx_type
				,p_itax_yea_category		=> lc_itax_yea_category
				,p_dpnt_ref_type			=> gn_business_group_id
				,p_dpnt_effective_date		=> ld_yea_effective_date
				,p_person_id			=> lr_emp_rec.person_id
				,p_sex				=> lr_emp_rec.sex
				,p_date_of_birth			=> lr_emp_rec.date_of_birth
				,p_leaving_reason		      => lr_emp_rec.leaving_reason
				,p_last_name_kanji		=> lr_emp_rec.last_name_kanji
				,p_last_name_kana		      => lr_emp_rec.last_name_kana
				,p_employment_category		=> lr_emp_rec.employment_category
				,p_certificate_info           => lt_get_certificate_info
                        ,p_submission_required_flag   => lc_submission_required_flag
                        ,p_prev_job_info              => lt_prev_job_info
                        ,p_withholding_tax_info       => lt_tax_info
                        ,p_itw_description		=> l_itw_user_desc_kanji
				,p_itw_descriptions		=> l_itw_descriptions
				,p_wtm_description		=> l_wtm_user_desc
				,p_wtm_descriptions		=> l_wtm_descriptions
				);
          --
          ln_yea_sal_deducion     := lt_get_certificate_info.tax_info.si_prem;
          ln_old_long_non_li_prem := lt_get_certificate_info.long_ai_prem;
          ln_pp_prem              := lt_get_certificate_info.pp_prem;
          ln_mutual_aid_prem      := lt_get_certificate_info.tax_info.mutual_aid_prem;
          ln_npi_prem             := lt_get_certificate_info.national_pens_prem;
          ln_housing_loan_credit  := lt_get_certificate_info.housing_tax_reduction;
          ln_spouse_sp_exempt     := lt_get_certificate_info.spouse_sp_exempt;
          ln_yea_li_prem          := lt_get_certificate_info.li_prem_exempt;
          --
          -- Start Bug No 9063339
          OPEN  lcu_payment_action_date (p_assignment_id          =>   ln_assignment_id
                                         ,p_payroll_start_period   => lc_payroll_start_period
                                         ,p_payroll_end_period     => lc_payroll_period_id
                                        );
           LOOP
           FETCH lcu_payment_action_date INTO ld_payment_date,lc_element_set_name,ln_assignment_action_id;
           EXIT WHEN lcu_payment_action_date%NOTFOUND;
           IF lc_element_set_name IN ('SAL') THEN
             ln_amount:=   pay_sal_balance_result_value (    p_assignment_id        => ln_assignment_id
                                                            ,p_payroll_period       => TO_CHAR(ld_payment_date,'YYYYMM')
                                                            ,p_balance_name         => 'B_SAL_ITX'
                                                             ,p_dimension_name       => '_ASG_RUN'
                                                              );

             lc_nres_flag  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                ,p_input_value_name => 'NRES_FLAG'
                                                                ,p_assignment_id    => ln_assignment_id
                                                                ,p_effective_date   => ld_payment_date
                                                                       );
            IF lc_nres_flag= 'N' THEN
              ln_yea_sal_tax := NVL(ln_yea_sal_tax,0) +NVL(ln_amount,0);
            END IF;

          ELSIF lc_element_set_name IN ('BON','SPB') THEN
              IF lc_element_set_name = 'BON' THEN

               ln_amount:=       pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => TO_CHAR(ld_payment_date,'YYYYMM')
                                                              ,p_balance_name         => 'B_BON_ITX'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                             );
             ELSE
              ln_amount:=       pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => TO_CHAR(ld_payment_date,'YYYYMM')
                                                              ,p_balance_name         => 'B_SPB_ITX'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                             );

             END IF;

             lc_nres_flag  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                ,p_input_value_name => 'NRES_FLAG'
                                                                ,p_assignment_id    => ln_assignment_id
                                                                ,p_effective_date   => ld_payment_date
                                                                       );
             IF lc_nres_flag = 'N' THEN
              ln_yea_bon_tax := NVL(ln_yea_bon_tax,0) +NVL(ln_amount,0);
            END IF;
           END IF;
          END LOOP;
          CLOSE lcu_payment_action_date ;  -- End Bug No 9063339
          --
          OPEN  lcu_tot_dep_exem(p_assignment_id      => ln_assignment_id
                                ,p_subject_yyyymm     => gr_parameters.subject_yyyymm
                                ,p_assignment_action_id => ln_yea_assignment_action_id  -- BUG 9014185
                               );
          FETCH lcu_tot_dep_exem INTO ln_total_exempt;
          CLOSE lcu_tot_dep_exem;
          --
          ln_yea_sal       :=   pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                          ,p_payroll_period       => lc_action_period
                                                          ,p_balance_name         => 'B_SAL_TXBL_ERN_MONEY'
                                                          ,p_dimension_name       => '_ASG_YTD'
                                                         );

          ln_yea_bonus     :=   pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                          ,p_payroll_period       => lc_action_period
                                                          ,p_balance_name         => 'B_BON_ERN'
                                                          ,p_dimension_name       => '_ASG_RUN'
                                                         );

          ln_yea_tot_taxable_amt := pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                          ,p_payroll_period       => lc_action_period
                                                          ,p_balance_name         => 'B_YEA_TXBL_ERN_MONEY'
                                                          ,p_dimension_name       =>  '_ASG_YTD'                       --Bug No 8830562
                                                         );
          ln_yea_sal_with_ded  :=       pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                                  ,p_payroll_period       => lc_action_period
                                                                  ,p_balance_name         => 'B_YEA_AMT_AFTER_EMP_INCOME_DCT'  --Bug No 8830562
                                                                  ,p_dimension_name       => '_ASG_RUN'
                                                                  );
          ln_yea_annual_tax               := pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_NET_ANNUAL_TAX'  -- Bug No 8910016
                                                             ,p_dimension_name       => '_ASG_RUN'
                                                             );

          ln_yea_over_short_tax           :=  pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_TAX_PAY'
                                                             ,p_dimension_name       =>  '_ASG_YTD'
                                                             );

          ln_yea_tot_deduction_amt          :=  pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_INCOME_EXM'
                                                             ,p_dimension_name       =>  '_ASG_RUN'
                                                             );

          ln_yea_net_asseble_amt            :=  pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_NET_TXBL_INCOME'
                                                             ,p_dimension_name       =>  '_ASG_RUN'
                                                             );
          ln_yea_comptued_tax_amount            :=  pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_ANNUAL_TAX'
                                                             ,p_dimension_name       =>   '_ASG_RUN'
                                                             );

         ln_basis_exmpt := pay_jp_balance_pkg.get_result_value_number (
                                                 p_element_name  =>  'YEA_DEP_EXM_RSLT'
                                                ,p_input_value_name    => 'BASIC_EXM'
                                                ,p_assignment_action_id => ln_yea_assignment_action_id
                                               );
          ln_dependent_exmpt := pay_jp_balance_pkg.get_result_value_number (
                                                 p_element_name  =>  'YEA_DEP_EXM_RSLT'
                                                ,p_input_value_name    => 'GEN_DEP_EXM'
                                                ,p_assignment_action_id => ln_yea_assignment_action_id
                                               );
          ln_gen_spouse_exmpt := pay_jp_balance_pkg.get_result_value_number (
                                                      p_element_name  =>  'YEA_DEP_EXM_RSLT'
                                                     ,p_input_value_name    =>  'GEN_SPOUSE_EXM'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_gen_disable_exmpt := pay_jp_balance_pkg.get_result_value_number (
                                                      p_element_name  =>  'YEA_DEP_EXM_RSLT'
                                                     ,p_input_value_name    => 'GEN_DISABLED_EXM'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_yea_si_prem := pay_jp_balance_pkg.get_result_value_number (p_element_name  => 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT'
                                                     ,p_input_value_name    => 'DECLARE_SI_PREM'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_yea_ei_prem := pay_jp_balance_pkg.get_result_value_number ( p_element_name  => 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT'
                                                     ,p_input_value_name    => 'NONLIFE_INS_PREM_EXM'
                                                    ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_yea_spouse_income:= pay_jp_balance_pkg.get_result_value_number (p_element_name  => 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT'
                                                     ,p_input_value_name    => 'SPOUSE_INCOME'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_yea_samll_comp_prem  := pay_jp_balance_pkg.get_result_value_number ( p_element_name  => 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT'
                                                     ,p_input_value_name    => 'DECLARE_SMALL_COMPANY_MUTUAL_AID_PREM'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );

          ln_adj_emp_income        := pay_jp_balance_pkg.get_result_value_number (
                                                        p_element_name  => 'YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT'
                                                       ,p_input_value_name    => 'ADJ_EMP_INCOME'
                                                       ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_adj_emp_tax          := pay_jp_balance_pkg.get_result_value_number (
                                                     p_element_name  => 'YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT'
                                                     ,p_input_value_name    => 'ADJ_ITX'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );


          --
          ln_yea_sal_deducion  := NVL(ln_yea_sal_deducion,0)  - (NVL(ln_yea_samll_comp_prem,0)+NVL(ln_yea_si_prem,0));
          ln_yea_tot_taxable_amt := NVL(ln_yea_tot_taxable_amt,0) + NVL(ln_prev_job_income,0)+NVL(ln_adj_emp_income,0);
          ln_mutual_aid_prem := NVL(ln_mutual_aid_prem,0) - NVL(ln_yea_samll_comp_prem,0);
          ln_yea_sal := NVL(ln_yea_sal,0) + NVL(ln_prev_job_income,0)+NVL(ln_adj_emp_income,0);
          ln_yea_net_asseble_amt  := TRUNC(ln_yea_net_asseble_amt,-3);
          ln_yea_annual_tax       := TRUNC(ln_yea_annual_tax,-2);
          ln_yea_comptued_tax_amount := TRUNC(ln_yea_comptued_tax_amount);
          ln_yea_sal_tax          := NVL(ln_yea_sal_tax,0) + NVL(ln_adj_emp_tax,0)+ NVL(ln_prev_job_itax,0);
          --
            OPEN  lcu_action_information_id(p_action_information_category => 'JP_WL_YEA_INFO'
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id);
            FETCH lcu_action_information_id INTO ln_yea_obj_version_num,ln_yea_action_info_id;
            CLOSE lcu_action_information_id;
            --
            IF ln_yea_action_info_id IS NOT NULL THEN
             pay_action_information_api.update_action_information
           (
                 p_validate                       => FALSE
            ,p_action_information_id          => ln_yea_action_info_id
            ,p_object_version_number          => ln_yea_obj_version_num
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_number.number_to_canonical(ln_yea_sal)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_yea_bonus)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_yea_tot_taxable_amt)
            ,p_action_information5            => fnd_number.number_to_canonical(ln_yea_sal_tax)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_yea_bon_tax)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_yea_sal_with_ded)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_yea_sal_deducion)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_yea_si_prem)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_yea_samll_comp_prem)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_yea_li_prem)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_yea_ei_prem)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_spouse_sp_exempt)
            ,p_action_information14           => fnd_number.number_to_canonical(ln_yea_spouse_income)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_pp_prem)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_old_long_non_li_prem)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_mutual_aid_prem)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_npi_prem)
            ,p_action_information19           => fnd_number.number_to_canonical(ln_housing_loan_credit)
            ,p_action_information20           => fnd_number.number_to_canonical(ln_yea_annual_tax)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_yea_over_short_tax)
            ,p_action_information22           => fnd_number.number_to_canonical(ln_gen_spouse_exmpt)
            ,p_action_information23           => fnd_number.number_to_canonical(ln_dependent_exmpt)
            ,p_action_information24           => fnd_number.number_to_canonical(ln_basis_exmpt)
            ,p_action_information25           => fnd_number.number_to_canonical(ln_gen_disable_exmpt)
            ,p_action_information26           => fnd_number.number_to_canonical(ln_total_exempt)
            ,p_action_information27           => fnd_number.number_to_canonical(ln_yea_tot_deduction_amt)
            ,p_action_information28           => fnd_number.number_to_canonical(ln_yea_net_asseble_amt)
            ,p_action_information29           => fnd_number.number_to_canonical(ln_yea_comptued_tax_amount)
            );
          ELSIF (ln_yea_action_info_id IS NULL AND   gr_parameters.archive_option = 'ADD') THEN
            --
           pay_action_information_api.create_action_information
             (
             p_validate                       => FALSE
            ,p_action_context_id              => ln_org_assign_act_id
            ,p_action_context_type            => 'AAP'
            ,p_action_information_category    => 'JP_WL_YEA_INFO'
            ,p_tax_unit_id                    => NULL
            ,p_jurisdiction_code              => NULL
            ,p_source_id                      => NULL
            ,p_source_text                    => NULL
            ,p_tax_group                      => NULL
            ,p_effective_date                 => p_effective_date
            ,p_assignment_id                  => ln_assignment_id
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_number.number_to_canonical(ln_yea_sal)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_yea_bonus)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_yea_tot_taxable_amt)
            ,p_action_information5            => fnd_number.number_to_canonical(ln_yea_sal_tax)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_yea_bon_tax)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_yea_sal_with_ded)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_yea_sal_deducion)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_yea_si_prem)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_yea_samll_comp_prem)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_yea_li_prem)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_yea_ei_prem)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_spouse_sp_exempt)
            ,p_action_information14           => fnd_number.number_to_canonical(ln_yea_spouse_income)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_pp_prem)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_old_long_non_li_prem)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_mutual_aid_prem)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_npi_prem)
            ,p_action_information19           => fnd_number.number_to_canonical(ln_housing_loan_credit)
            ,p_action_information20           => fnd_number.number_to_canonical(ln_yea_annual_tax)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_yea_over_short_tax)
            ,p_action_information22           => fnd_number.number_to_canonical(ln_gen_spouse_exmpt)
            ,p_action_information23           => fnd_number.number_to_canonical(ln_dependent_exmpt)
            ,p_action_information24           => fnd_number.number_to_canonical(ln_basis_exmpt)
            ,p_action_information25           => fnd_number.number_to_canonical(ln_gen_disable_exmpt)
            ,p_action_information26           => fnd_number.number_to_canonical(ln_total_exempt)
            ,p_action_information27           => fnd_number.number_to_canonical(ln_yea_tot_deduction_amt)
            ,p_action_information28           => fnd_number.number_to_canonical(ln_yea_net_asseble_amt)
            ,p_action_information29           => fnd_number.number_to_canonical(ln_yea_comptued_tax_amount)
            ,p_action_information_id          => ln_yea_action_info_id
            ,p_object_version_number          => ln_yea_obj_version_num
            );

           END IF;
           --
        END IF;
             --
        IF gb_debug THEN
          hr_utility.set_location('After the YEA Information',30);
        END IF;
        -- -- Dependents Information
        --
        IF gb_debug THEN
          hr_utility.set_location('Before the Dependents Information context',30);
        END IF;
        --
        IF lc_itx_type LIKE '%KOU%' THEN
           lc_existence_declaration := 'Y';
        END IF;
        --
        CASE
          WHEN  lC_spouse_type = '0' THEN lC_spouse_exists := 'N';
          WHEN  lC_spouse_type = '1' THEN lC_spouse_exists := 'Y';
          WHEN  lC_spouse_type = '2' THEN lC_general_qualified_spouse :='Y';
                                          lC_spouse_exists := 'Y';
          WHEN  lC_spouse_type = '3' THEN lC_aged_spouse := 'Y';
                                     lC_spouse_exists := 'Y';
          ELSE  lC_spouse_exists := 'N';
        END CASE;
        --
        IF lc_aged_employee = '1' THEN
           lc_aged_employee_flag := 'Y';
        END IF;
        --
        lc_spouse_exists_meaning  :=  proc_lookup_meaning('YES_NO',lC_spouse_exists);
        lC_general_qual_meaning   :=  proc_lookup_meaning('YES_NO',lC_general_qualified_spouse );
        lC_aged_spouse_meaning    :=  proc_lookup_meaning('YES_NO',lC_aged_spouse );
        lc_existence_meaning      :=  proc_lookup_meaning('YES_NO',lc_existence_declaration);
        lc_widow_type_meaning         :=  proc_lookup_meaning('JP_WIDOW_EE_STATUS',lc_widow_type);
        lc_working_student_meaning    :=  proc_lookup_meaning('JP_WORKING_STUDENT_EE_STATUS',lc_working_student);
        lc_disable_type_meaning       :=  proc_lookup_meaning('JP_DISABLED_EE_STATUS',lc_disable_type);
        --
        IF lc_itx_type LIKE '%OTSU%' THEN
          --
          ln_otsu_depts := ln_general_dependents;
          --
        END IF;
        --
        OPEN  lcu_action_information_id(p_action_information_category => 'JP_WHB_DEC_DEP_INFO'
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id);
        FETCH lcu_action_information_id INTO ln_dep_obj_version_num,ln_dep_action_info_id;
        CLOSE lcu_action_information_id;
        --
        IF   gr_parameters.archive_option = 'UPDATE' THEN
          --
          IF ln_dep_action_info_id IS NOT NULL THEN
          --
          pay_action_information_api.update_action_information
         (
          p_validate                       => FALSE
         ,p_action_information_id          => ln_dep_action_info_id
         ,p_object_version_number          => ln_dep_obj_version_num
         ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
         ,p_action_information2            => lc_existence_meaning
         ,p_action_information3            => lc_spouse_exists_meaning
         ,p_action_information4            => lC_general_qual_meaning
         ,p_action_information5            => lC_aged_spouse_meaning
         ,p_action_information6            => fnd_number.number_to_canonical(ln_general_dependents)
         ,p_action_information7            => fnd_number.number_to_canonical(ln_specific_dependents)
         ,p_action_information8            => fnd_number.number_to_canonical(ln_elder_parents)
         ,p_action_information9            => fnd_number.number_to_canonical(ln_elder_dependents)
         ,p_action_information10           => fnd_number.number_to_canonical(ln_generally_disabled)
         ,p_action_information11           => fnd_number.number_to_canonical(ln_specially_dependents)
         ,p_action_information12           => fnd_number.number_to_canonical(ln_specially_dependents_lt)
         ,p_action_information13           => lc_disable_type_meaning
         ,p_action_information14           => lc_widow_type_meaning
         ,p_action_information15           => lc_working_student_meaning
         ,p_action_information16           => ln_otsu_depts
         );
          END IF;
          --
        END IF;
        --
        -- End Dependents Information
        --
        IF gb_debug THEN
          hr_utility.set_location('After the Dependents Information context',30);
        END IF;
        --
        IF lr_proc_name.proc_name IS NOT NULL THEN
          --
          IF gb_debug THEN
            hr_utility.set_location('Dynamic PL/SQL block invokes subprogram parameters:',30);
          END IF;
          --
          lc_plsql_block := '(p_assignment_id  => :assignment_id
                           ,p_effective_date => :eff_date
                           ,x_info1          => :1
                           ,x_info2          => :2
                           ,x_info3          => :3
                           ,x_info4          => :4
                           ,x_info5          => :5
                           ,x_info6          => :6
                           ,x_info7          => :7
                           ,x_info8          => :8
                           ,x_info9          => :9
                           ,x_info10         => :10
                           ,x_info11         => :11
                           ,x_info12         => :12
                           ,x_info13         => :13
                           ,x_info14         => :14
                           ,x_info15         => :15
                           ,x_info16         => :16
                           ,x_info17         => :17
                           ,x_info18         => :18
                           ,x_info19         => :19
                           ,x_info20         => :20
                           ,x_info21         => :21
                           ,x_info22         => :22
                           ,x_info23         => :23
                           ,x_info24         => :24
                           ,x_info25         => :25
                           ,x_info26         => :26
                           ,x_info27         => :27
                           ,x_info28         => :28
                           ,x_info29         => :29
                           ,x_info30         => :30
                          );';
          --
          IF gb_debug THEN
            hr_utility.set_location('After the YEA Information',30);
          END IF;
          --
          IF gb_debug THEN
            hr_utility.set_location('Calling Extra info plug in procedure using dynamic SQL',30);
          END IF;
          --
          EXECUTE IMMEDIATE 'BEGIN '||lr_proc_name.proc_name||lc_plsql_block||' END;'
          USING   IN  ln_assignment_id
              , IN  TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM')
              , OUT lr_extra_info.extra_info1
              , OUT lr_extra_info.extra_info2
              , OUT lr_extra_info.extra_info3
              , OUT lr_extra_info.extra_info4
              , OUT lr_extra_info.extra_info5
              , OUT lr_extra_info.extra_info6
              , OUT lr_extra_info.extra_info7
              , OUT lr_extra_info.extra_info8
              , OUT lr_extra_info.extra_info9
              , OUT lr_extra_info.extra_info10
              , OUT lr_extra_info.extra_info11
              , OUT lr_extra_info.extra_info12
              , OUT lr_extra_info.extra_info13
              , OUT lr_extra_info.extra_info14
              , OUT lr_extra_info.extra_info15
              , OUT lr_extra_info.extra_info16
              , OUT lr_extra_info.extra_info17
              , OUT lr_extra_info.extra_info18
              , OUT lr_extra_info.extra_info19
              , OUT lr_extra_info.extra_info20
              , OUT lr_extra_info.extra_info21
              , OUT lr_extra_info.extra_info22
              , OUT lr_extra_info.extra_info23
              , OUT lr_extra_info.extra_info24
              , OUT lr_extra_info.extra_info25
              , OUT lr_extra_info.extra_info26
              , OUT lr_extra_info.extra_info27
              , OUT lr_extra_info.extra_info28
              , OUT lr_extra_info.extra_info29
              , OUT lr_extra_info.extra_info30;
          --
          IF gb_debug THEN
            hr_utility.set_location('Archiving Employee Extra Information',30);
          END IF;
          --

            OPEN  lcu_action_information_id(p_action_information_category => 'JP_WL_EXTRA_INFO'
                                       ,p_assignment_id               => ln_assignment_id
                                       ,p_payroll_action_id           => ln_master_pact_id);
            FETCH lcu_action_information_id INTO ln_ext_obj_version_num,ln_ext_action_info_id;
            CLOSE lcu_action_information_id;
            --
             IF ln_ext_action_info_id IS NOT NULL THEN
            pay_action_information_api.update_action_information
           (
             p_validate                     => FALSE
           ,p_action_information_id        => ln_ext_action_info_id
           ,p_object_version_number        => ln_ext_obj_version_num
           , p_action_information1          => lr_extra_info.extra_info1
           , p_action_information2          => lr_extra_info.extra_info2
           , p_action_information3          => lr_extra_info.extra_info3
           , p_action_information4          => lr_extra_info.extra_info4
           , p_action_information5          => lr_extra_info.extra_info5
           , p_action_information6          => lr_extra_info.extra_info6
           , p_action_information7          => lr_extra_info.extra_info7
           , p_action_information8          => lr_extra_info.extra_info8
           , p_action_information9          => lr_extra_info.extra_info9
           , p_action_information10         => lr_extra_info.extra_info10
           , p_action_information11         => lr_extra_info.extra_info11
           , p_action_information12         => lr_extra_info.extra_info12
           , p_action_information13         => lr_extra_info.extra_info13
           , p_action_information14         => lr_extra_info.extra_info14
           , p_action_information15         => lr_extra_info.extra_info15
           , p_action_information16         => lr_extra_info.extra_info16
           , p_action_information17         => lr_extra_info.extra_info17
           , p_action_information18         => lr_extra_info.extra_info18
           , p_action_information19         => lr_extra_info.extra_info19
           , p_action_information20         => lr_extra_info.extra_info20
           , p_action_information21         => lr_extra_info.extra_info21
           , p_action_information22         => lr_extra_info.extra_info22
           , p_action_information23         => lr_extra_info.extra_info23
           , p_action_information24         => lr_extra_info.extra_info24
           , p_action_information25         => lr_extra_info.extra_info25
           , p_action_information26         => lr_extra_info.extra_info26
           , p_action_information27         => lr_extra_info.extra_info27
           , p_action_information28         => lr_extra_info.extra_info28
           , p_action_information29         => lr_extra_info.extra_info29
           , p_action_information30         => lr_extra_info.extra_info30
           );
          END IF;
          END IF; -- End IF for Employee Details
       END IF;
    --
    END LOOP;
    --
    UPDATE pay_assignment_actions
    SET action_status ='C'
    WHERE assignment_action_id = ln_org_assign_act_id; -- Bug 8931350
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1);
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    --
    UPDATE pay_assignment_actions
    SET action_status ='E'
    WHERE assignment_action_id = ln_org_assign_act_id; -- Bug 8931350
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END UPDATE_ARCH;
  --
  PROCEDURE ASSIGNMENT_ACTION_CODE ( p_payroll_action_id IN pay_payroll_actions.payroll_action_id%type
                                    ,p_start_person      IN per_all_people_f.person_id%type
                                    ,p_end_person        IN per_all_people_f.person_id%type
                                    ,p_chunk             IN NUMBER
                                   )
  --************************************************************************
  --   PROCEDURE
  --   ASSIGNMENT_ACTION_CODE
  --
  --   DESCRIPTION
  --   This procedure further restricts the assignment_id's returned by range_code
  --   This procedure gets the parameters given by user and restricts
  --   the assignments to be archived
  --   it then calls hr_nonrun.insact to create an assignment action id
  --   it then archives Payroll Run assignment action id  details
  --   in pay_Action_information with context 'AU_ARCHIVE_ASG_DETAILS'
  --   for each assignment.
  --   There are different cursors for choosing the assignment ids.
  --   Depending on the parameters passed,the appropriate cursor is used.
  --
  --   ACCESS
  --   PUBLIC
  --
  --   PARAMETERS
  --  ==========
  --  NAME                       TYPE     DESCRIPTION
  --  -----------------         -------- ---------------------------------------
  --  p_payroll_action_id        IN       This parameter passes Payroll Action Id
  --  p_start_person             IN       This parameter passes Start Person Id
  --  p_end_person               IN       This parameter passes End Person Id
  --  p_chunk                    OUT      This parameter passes Chunk Number
  --
  --  PREREQUISITES
  --   None
  --
  --  CALLED BY
  --   PYUGEN process
  --***********************************************************************/
  IS
  --
  CURSOR lcu_emp_assignment_det_r(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE
                                 ,p_business_group_id  per_assignments_f.business_group_id%TYPE
                                 ,p_effective_date     DATE
                                 ,p_payroll_id         pay_payrolls_f.payroll_id%TYPE
                                 ,p_with_hold_id       hr_all_organization_units.organization_id%TYPE
                                 )
  IS
  SELECT PAF.assignment_id
  FROM   per_assignments_f            PAF
        ,per_people_f                 PPF
        ,per_periods_of_service       PPS
        ,pay_population_ranges        PPR
        ,pay_payroll_actions          PPA
  WHERE  PAF.person_id              = PPF.person_id
  AND    PPF.person_id              = PPS.person_id
  AND    PPA.payroll_action_id      = p_payroll_action_id
  AND    PPA.payroll_action_id      = PPR.payroll_action_id
  AND    PPR.chunk_number           = p_chunk
  AND    PPR.person_id              = PPF.person_id
  AND    PAF.business_group_id      = p_business_group_id
  AND    PPS.period_of_service_id   = PAF.period_of_service_id
  AND    NVL(PAF.payroll_id,-999)   = NVL(p_payroll_id,NVL(PAF.payroll_id,-999))
  AND    NVL(get_with_hold_agent(PAF.assignment_id,p_effective_date),-999) = NVL(p_with_hold_id,NVL(get_with_hold_agent(PAF.assignment_id,p_effective_date),-999))
  AND    NVL(pps.actual_termination_date,TRUNC(p_effective_date)) BETWEEN PAF.effective_start_date AND PAF.effective_end_date
  AND    NVL(pps.actual_termination_date,TRUNC(p_effective_date)) BETWEEN PPF.effective_start_date AND PPF.effective_end_date
  ORDER BY PAF.assignment_id;
  --
  CURSOR lcu_emp_assignment_det ( p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE
                                 ,p_start_person_id    per_all_people_f.person_id%TYPE
                                 ,p_end_person_id      per_all_people_f.person_id%TYPE
                                 ,p_business_group_id  per_assignments_f.business_group_id%TYPE
                                 ,p_effective_date     DATE
                                 ,p_payroll_id         pay_payrolls_f.payroll_id%TYPE
                                 ,p_with_hold_id        hr_all_organization_units.organization_id%TYPE
                                 )
  IS
  SELECT PAF.assignment_id
  FROM   per_assignments_f            PAF
        ,per_people_f                 PPF
        ,per_periods_of_service       PPS
  WHERE  PAF.person_id             = PPF.person_id
  AND    PPF.person_id             = PPS.person_id
  AND    PAF.business_group_id     = p_business_group_id
  AND    PPS.period_of_service_id  = PAF.period_of_service_id
  AND    NVL(PAF.payroll_id,-999)  = NVL(p_payroll_id,NVL(PAF.payroll_id,-999))
  AND    NVL(get_with_hold_agent(PAF.assignment_id,p_effective_date),-999) = NVL(p_with_hold_id,NVL(get_with_hold_agent(PAF.assignment_id,p_effective_date),-999))
  AND    PPF.person_id BETWEEN p_start_person_id AND p_end_person_id
  AND    NVL(pps.actual_termination_date,TRUNC(p_effective_date)) BETWEEN PAF.effective_start_date AND PAF.effective_end_date
  AND    NVL(pps.actual_termination_date,TRUNC(p_effective_date)) BETWEEN PPF.effective_start_date AND PPF.effective_end_date
  ORDER BY PAF.assignment_id;
  --
  CURSOR lcu_get_pact_info ( p_subject_yyyymm VARCHAR2
                            )
  IS
  SELECT    'Y'
  FROM  pay_action_information  PAI
  WHERE pai.action_information_category = 'JP_WL_PACT'
  AND         pai.action_context_type = 'PA'
  AND       pai.action_information1 = p_subject_yyyymm
  AND      (pai.action_information2 = 'RENEW' OR  pai.action_information2 = 'ADD' OR pai.action_information2 = 'UPDATE');
  --
  CURSOR lcu_get_update_pact_info( p_subject_yyyymm VARCHAR2
                                 )
  IS
  SELECT    'Y'
  FROM  pay_action_information  PAI
  WHERE pai.action_information_category = 'JP_WL_PACT'
  AND         pai.action_context_type = 'PA'
  AND       TO_DATE(pai.action_information1,'YYYYMM') >= TO_DATE(p_subject_yyyymm,'YYYYMM')
  AND      (pai.action_information2 = 'RENEW' OR  pai.action_information2 = 'ADD' OR pai.action_information2 = 'UPDATE');
  --
  CURSOR lcu_get_master_pact( p_subject_yyyymm VARCHAR2
                             ,p_assignment_id  per_all_assignments_f.assignment_id%TYPE
                           )
  IS
  SELECT fnd_number.canonical_to_number(PCI.action_information3)
  FROM   pay_action_information        PCI
        ,pay_assignment_actions        PAA
  WHERE  PCI.action_information_category = 'JP_WL_PACT'
  AND    TO_CHAR(TO_DATE(PCI.action_information1,'YYYYMM'),'YYYY') =  TO_CHAR(TO_DATE(p_subject_yyyymm,'YYYYMM'),'YYYY')
  AND    PCI.action_information8         = 'Y'
  AND    PCI.action_context_type  = 'PA'
  AND    PAA.payroll_action_id    = PCI.action_context_id
  AND    PAA.assignment_id        = p_assignment_id;
  --
  CURSOR lcu_get_org_pact ( p_subject_yyyymm VARCHAR2
                            )
  IS
  SELECT fnd_number.canonical_to_number(PCI.action_information3)
  FROM   pay_action_information        PCI
  WHERE  PCI.action_information_category = 'JP_WL_PACT'
  AND   TO_CHAR(TO_DATE(PCI.action_information1,'YYYYMM'),'YYYY') =  TO_CHAR(TO_DATE(p_subject_yyyymm,'YYYYMM'),'YYYY')
  AND    PCI.action_information8         = 'Y'
  AND   PCI.action_context_type  = 'PA';
  --
  CURSOR lcu_next_action_id
  IS
  SELECT pay_assignment_actions_s.NEXTVAL
  FROM   dual;
  --
  -- Local Variables
  lc_procedure                  VARCHAR2(200);
  lc_subject_yyyymm             VARCHAR2(240);
  lc_archive_exists             VARCHAR2(1) := 'N';
  lc_previous_month             VARCHAR2(10);
  lc_include_flag               VARCHAR2(1) := 'N';
  --
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_master_pact_id             NUMBER;
  ln_next_assignment_action_id  NUMBER;
  ln_org_pact_id                NUMBER;
  lt_wage_ledger                t_wage_ledger;
  --
  BEGIN
    --
    gb_debug := hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'assignment_action_code';
      hr_utility.set_location('Entering ' || lc_procedure,1);
      hr_utility.set_location('Person Range '||p_start_person||' - '||p_end_person,1);
    END IF;
    --
    -- initialization_code to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    --
    initialize(p_payroll_action_id);
    --
    gn_business_group_id := gr_parameters.business_group_id ;
    gn_payroll_action_id := p_payroll_action_id;
    lt_wage_ledger := gt_wage_ledger;
    --
    IF gb_debug THEN
       hr_utility.set_location('to_date=' ||TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),300);
    END IF;
    --
    OPEN  lcu_get_org_pact (gr_parameters.subject_yyyymm);
    FETCH lcu_get_org_pact INTO ln_org_pact_id;
    CLOSE lcu_get_org_pact;
    --
    ln_org_pact_id := NVL(ln_org_pact_id,p_payroll_action_id);
    --
    IF (gr_parameters.archive_option = 'UPDATE') THEN
      --
      OPEN  lcu_get_update_pact_info(gr_parameters.subject_yyyymm);
      FETCH lcu_get_update_pact_info INTO lc_archive_exists;
      CLOSE lcu_get_update_pact_info;
      --
    ELSIF (gr_parameters.archive_option = 'ADD') THEN
      --
      IF TO_CHAR(add_months(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),-1),'YYYY') =  TO_CHAR(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),'YYYY') THEN
        --
        lc_previous_month := TO_CHAR(add_months(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),-1),'YYYYMM');
        OPEN  lcu_get_pact_info(lc_previous_month);
        FETCH lcu_get_pact_info INTO lc_archive_exists;
        CLOSE lcu_get_pact_info;
        --
      END IF;
      --
    ELSE
      --
      lc_archive_exists := 'Y';
      --
    END IF;
    --
    IF (lc_archive_exists ='Y') THEN
    --
      IF range_person_on THEN
      --
      FOR lr_emp_assignment_det_r in lcu_emp_assignment_det_r(p_payroll_action_id
                                                             ,gr_parameters.business_group_id
                                                             ,LAST_DAY(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'))
                                                             ,gr_parameters.payroll_id
                                                             ,gr_parameters.withholding_agent_id
                                                             )
      LOOP
        --
        ln_master_pact_id := NULL; -- Added for bug 8858762
        --
        OPEN  lcu_next_action_id;
        FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
        CLOSE lcu_next_action_id;
        --
        IF gb_debug THEN
          hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
          hr_utility.set_location('l_next_assignment_action_id..= '||ln_next_assignment_action_id,20);
          hr_utility.set_location('lr_emp_assignment_det_r.assignment_id...= '||lr_emp_assignment_det_r.assignment_id,20);
        END IF;
        --
        OPEN  lcu_get_master_pact(gr_parameters.subject_yyyymm,lr_emp_assignment_det_r.assignment_id);
        FETCH lcu_get_master_pact INTO ln_master_pact_id;
        CLOSE lcu_get_master_pact;
        --
        IF (ln_master_pact_id IS NOT NULL) THEN -- changed for bug 8858762
           --
           ln_master_pact_id:= p_payroll_action_id;
           --
        END IF;
        --
        IF gb_debug THEN
          hr_utility.set_location(' ln_master_pact_id in Assignment action code.........= '||ln_master_pact_id,20);
          hr_utility.set_location(' ln_org_pact_id.........= '||ln_org_pact_id,20);
          hr_utility.set_location('lc_include_flag .= '||lc_include_flag ,20);
        END IF;
        -- Create the archive assignment actions
        --
        IF NVL(gr_parameters.assignment_set_id,0) = 0 THEN

              -- Create the archive assignment actions

               hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det_r.assignment_id
                                      ,NVL(ln_master_pact_id,ln_org_pact_id)
                                      ,p_chunk
                                     );
               --
               IF  (ln_master_pact_id IS NULL AND ln_org_pact_id <> p_payroll_action_id)  THEN  -- Bug No 8915846
                 --
                 OPEN  lcu_next_action_id;
                   FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                 CLOSE lcu_next_action_id;
                 --
                 hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det_r.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                     );
                 --
               END IF;        -- Bug No Bug No 8915846
               --
            ELSE
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => gr_parameters.assignment_set_id
                                                                              ,p_assignment_id     => lr_emp_assignment_det_r.assignment_id
                                                                              ,p_effective_date    => LAST_DAY(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'))
                                                                              );

              IF gb_debug THEN
                  hr_utility.set_location('lc_include_flag after check.= '||lc_include_flag ,20);
              END IF;
              --
              IF lc_include_flag = 'Y' THEN

                -- Create the archive assignment actions
                hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det_r.assignment_id
                                      ,NVL(ln_master_pact_id,ln_org_pact_id)
                                      ,p_chunk
                                     );
                IF (ln_master_pact_id IS NULL AND ln_org_pact_id <> p_payroll_action_id) THEN  -- Bug No 8915846
                 --
                 OPEN  lcu_next_action_id;
                   FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                 CLOSE lcu_next_action_id;
                 --
                 hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det_r.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                     );
                 --
               END IF;        -- Bug No Bug No 8915846
                 --
             END IF;
         END IF;
        --
      END LOOP;
      --
    ELSE
      --
      IF gb_debug THEN
         hr_utility.set_location('range_person_on_loop2',302);
      END IF;
      --
      FOR lr_emp_assignment_det in lcu_emp_assignment_det(p_payroll_action_id
                                                         ,p_start_person
                                                         ,p_end_person
                                                         ,gr_parameters.business_group_id
                                                         ,LAST_DAY(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'))
                                                         ,gr_parameters.payroll_id
                                                         ,gr_parameters.withholding_agent_id
                                                         )
      LOOP
        --
        ln_master_pact_id := NULL; -- Added for bug 8858762
        --
        OPEN  lcu_next_action_id;
        FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
        CLOSE lcu_next_action_id;
        --
        IF gb_debug THEN
          hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
          hr_utility.set_location('l_next_assignment_action_id.= '||ln_next_assignment_action_id,20);
          hr_utility.set_location('lr_emp_assignment_det.assignment_id.......= '||lr_emp_assignment_det.assignment_id,20);
        END IF;
        --
        OPEN  lcu_get_master_pact(gr_parameters.subject_yyyymm,lr_emp_assignment_det.assignment_id);
        FETCH lcu_get_master_pact INTO ln_master_pact_id;
        CLOSE lcu_get_master_pact;
        --
        IF (ln_master_pact_id IS NOT NULL) THEN
          --
          ln_master_pact_id:= p_payroll_action_id;
          --
        END IF;
        --
        IF gb_debug THEN
          hr_utility.set_location(' ln_master_pact_id in Assignment action code.........= '||ln_master_pact_id,20);
          hr_utility.set_location(' ln_org_pact_id.........= '||ln_org_pact_id,20);
          hr_utility.set_location('lc_include_flag .= '||lc_include_flag ,20);
        END IF;
        -- Create the archive assignment actions
        --
        IF NVL(gr_parameters.assignment_set_id,0) = 0 THEN

              -- Create the archive assignment actions

               hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,NVL(ln_master_pact_id,ln_org_pact_id)
                                      ,p_chunk
                                     );
               --
               IF (ln_master_pact_id IS NULL AND ln_org_pact_id <> p_payroll_action_id) THEN  -- Bug No 8915846
                 --
                 OPEN  lcu_next_action_id;
                   FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                 CLOSE lcu_next_action_id;
                 --
                 hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                     );
                 --
               END IF;        -- Bug No Bug No 8915846
               --
            ELSE
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => gr_parameters.assignment_set_id
                                                                              ,p_assignment_id     => lr_emp_assignment_det.assignment_id
                                                                              ,p_effective_date    => LAST_DAY(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'))
                                                                              );
              IF gb_debug THEN
                  hr_utility.set_location('lc_include_flag after check.= '||lc_include_flag ,20);
              END IF;
              --
              IF lc_include_flag = 'Y' THEN

                -- Create the archive assignment actions
                hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,NVL(ln_master_pact_id,ln_org_pact_id)
                                      ,p_chunk
                                     );
               --
               IF (ln_master_pact_id IS NULL AND ln_org_pact_id <> p_payroll_action_id)  THEN  -- Bug No 8915846
                 --
                 OPEN  lcu_next_action_id;
                   FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                 CLOSE lcu_next_action_id;
                 --
                 hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                     );
                 --
               END IF;        -- Bug No Bug No 8915846
               --
             END IF;
         END IF;
        --
      END LOOP;
      --
      END IF;
      --
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END ASSIGNMENT_ACTION_CODE;
  --
  PROCEDURE ARCHIVE_CODE ( p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%type
                         , p_effective_date        IN pay_payroll_actions.effective_date%type
                         )
  --************************************************************************
  --   PROCEDURE
  --   ARCHIVE_CODE
  --
  --   DESCRIPTION
  --   If employee details not previously archived,proc archives employee
  --   details in pay_Action_information with context 'JP_EMPOYEE_DETAILS'
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_assignment_action_id      IN       This parameter passes Assignment Action Id
  -- p_effective_date            IN       This parameter passes Effective Date
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************/
  IS
  --
  CURSOR lcu_get_assignment_id ( p_assignment_action_id pay_assignment_actions.assignment_action_id%type )
  IS
  SELECT assignment_id
  FROM   pay_assignment_actions
  WHERE  assignment_action_id = p_assignment_action_id;
  --
  CURSOR lcu_employee_details ( p_assignment_id     NUMBER
                              , p_effective_date    DATE
                              )
  IS
  SELECT HOU.organization_id                                      organization_id
       , PAAF.payroll_id                                          payroll_id
       , PAAF.location_id                                         location_id
       , PPF.person_id                                            person_id
       , PPF.last_name ||' '||PPF.first_name                      full_name_kana
       , HL_S.meaning                                             gender
       , PPOS.date_start                                          hire_date
       , PPOS.actual_termination_date                             termination_date
       , HOU.name                                                 organization_name
       , PPF.per_information18||' '|| PPF.per_information19       full_name_kanji
       , PJS.name                                                 job_title
       , PAD.postal_code                                          postal_code
       , PAD.address_line1                                        address_line1
       , PAD.address_line2                                        address_line2
       , PAD.address_line3                                        address_line3
       , PAD.telephone_number_1                                   phone_number
       , PPF.date_of_birth                                        date_of_birth
       , PPF.employee_number                                      employee_number
       , PAAF.assignment_id                                       assignment_id
       , PAAF.employment_category                                 employment_category
       , PAY.payroll_name                                         payroll_name
       , PAY.prl_information1                                     dpnt_ref_type
       , PPF.last_name                                            last_name_kana
       , PPF.per_information18                                    last_name_kanji
       , PPOS.leaving_reason                                      leaving_reason
       , PAD.region_1                                             address_line1_kana
       , PAD.region_2                                             address_line2_kana
       , PAD.region_3                                             address_line3_kana
       , PPF.sex                                                  sex
  FROM   per_people_f                    PPF
       , per_assignments_f               PAAF
       , per_addresses                   PAD
       , per_periods_of_service          PPOS
       , hr_all_organization_units_tl    HOU
       , per_jobs_tl                     PJS
       , pay_payrolls_f                  PAY
       , hr_lookups                      HL_S
  WHERE PAAF.person_id                     = PPF.person_id
  AND   PAD.person_id(+)                   = PPF.person_id
  AND   PPOS.person_id                     = PPF.person_id
  AND   HOU.organization_id(+)             = PAAF.organization_id
  AND   PJS.job_id(+)                      = PAAF.job_id
  AND   NVL(PPOS.actual_termination_date,p_effective_date) BETWEEN PPF.effective_start_date  AND PPF.effective_end_date
  AND   NVL(PPOS.actual_termination_date,p_effective_date) BETWEEN PAAF.effective_start_date AND PAAF.effective_end_date
  AND   PAAF.assignment_id                 =  p_assignment_id
  AND   HOU.language(+)                    = USERENV('LANG')
  AND   PJS.language(+)                    = USERENV('LANG')
  AND   PAD.address_type(+)                = get_person_address_type(PPF.person_id)
  AND   PAY.payroll_id(+)                  = PAAF.payroll_id
  AND   NVL(PPOS.actual_termination_date,p_effective_date)   BETWEEN TRUNC(NVL(PAD.date_from,PPOS.date_start)) AND NVL(PAD.date_to,TO_DATE('31/12/4712','DD/MM/YYYY'))
  AND   HL_S.lookup_type(+)                   = 'SEX'
  AND   HL_S.lookup_code(+)                   = PPF.sex
  AND   NVL(PPOS.actual_termination_date,p_effective_date) BETWEEN TRUNC(NVL(PAY.effective_start_date,PPOS.date_start)) AND NVL(PAY.effective_end_date,TO_DATE('31/12/4712','DD/MM/YYYY'))
  ORDER BY PPF.person_id,PPF.effective_start_date;
  ----------------------------------------------------------------
  -- Cursor to Fetch reporting name for Elements
  ----------------------------------------------------------------
  CURSOR lcu_element_report_name(p_element_type_id  pay_element_types_f.element_type_id%TYPE
                                ,p_effective_date   DATE)
  IS
  SELECT PETFTL.reporting_name
  FROM pay_element_types_f PETF
      ,pay_element_types_f_tl PETFTL
  WHERE PETFTL.element_type_id = PETF.element_type_id
  AND   PETF.element_type_id   = p_element_type_id
  AND   PETFTL.Language = USERENV('LANG')
  AND   TRUNC (p_effective_date) BETWEEN  PETF.effective_start_date AND PETF.effective_end_date;
  ----------------------------------------------------------------
  -- Cursor to fetch element type id
  ----------------------------------------------------------------
  CURSOR lcu_element_type_id(p_element_name pay_element_types_f.element_name%TYPE
                            ,p_effective_date   DATE)
  IS
  SELECT PETF.element_type_id
  FROM pay_element_types_f PETF
  WHERE PETF.element_name = p_element_name
  AND   TRUNC (p_effective_date) BETWEEN  PETF.effective_start_date AND PETF.effective_end_date;
 ----------------------------------------------------------------
  -- Cursor to fetch element input value id
  ----------------------------------------------------------------
  CURSOR lcu_input_value_id(p_element_type_id pay_element_types_f.element_name%TYPE
                           ,p_name            pay_input_values_f.name%TYPE
                           ,p_effective_date   DATE)
  IS
  SELECT PIVF.input_value_id
  FROM   pay_input_values_f PIVF
  WHERE PIVF.element_type_id = p_element_type_id
  AND   PIVF.name            = p_name
  AND   TRUNC (p_effective_date) BETWEEN  PIVF.effective_start_date AND PIVF.effective_end_date;
  ----------------------------------------------------------------
  -- Cursor to fetch balance reporting name
  ----------------------------------------------------------------
  CURSOR lcu_balance_report_name(p_balance_type_id      pay_balance_types.balance_type_id%TYPE)
  IS
  SELECT PBTTL.reporting_name
  FROM pay_balance_types PBT
      ,pay_balance_types_tl PBTTL
  WHERE  PBTTL.balance_type_id = PBT.balance_type_id
  AND    PBT.balance_type_id   = p_balance_type_id
  AND    PBTTL.Language = USERENV('LANG');
  ----------------------------------------------------------------
  -- Cursor to fetch payment action date
  ----------------------------------------------------------------
  CURSOR lcu_payment_action_date (p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                                 ,p_payroll_start_period         VARCHAR2
                                 ,p_payroll_end_period           VARCHAR2
                                  )
  IS
  SELECT   PPA.effective_date
          ,PES.element_set_name
          ,PAA.assignment_action_id
  FROM     per_assignments_f              PAAF
          ,pay_assignment_actions         PAA
          ,pay_payroll_actions            PPA
          ,pay_element_sets               PES
  WHERE  PAAF.assignment_id         = p_assignment_id
  AND    PAAF.assignment_id         = PAA.assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    TRUNC(PPA.effective_date)  BETWEEN  PAAF.effective_start_date and PAAF.effective_end_date
  AND    TRUNC(PPA.effective_date)  BETWEEN TO_DATE(p_payroll_start_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_end_period,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B')
  AND    PPA.element_set_id(+) = PES.element_set_id
  AND    PES.element_set_type(+)  = 'R'
  ORDER BY PPA.effective_date;
  ----------------------------------------------------------------
  -- Cursor to Fetch procedure name to fetch the Extra Information
  ----------------------------------------------------------------
  CURSOR lcu_proc_name (p_effective_date DATE)
  IS
  SELECT MAX(FND_DATE.canonical_to_date(HOI.org_information5)) start_date
        ,HOI.org_information4                                  proc_name
  FROM   hr_organization_information HOI
  WHERE  HOI.org_information_context    = 'JP_REPORTS_ADDITIONAL_INFO'
  AND    HOI.org_information1           = 'JPWAGELEDGERREPORT'
  AND    HOI.org_information3           = 'ADDINFO'
  AND    p_effective_date         BETWEEN FND_DATE.canonical_to_date(HOI.org_information5)
                                      AND FND_DATE.canonical_to_date(HOI.org_information6)
  GROUP BY HOI.org_information4;
  --
  --------------------------------------------------------------------
  -- Cursor to Fetch the Action Information Id
  --------------------------------------------------------------------
  CURSOR lcu_action_information_id(p_action_information_category  pay_action_information.action_information_category%TYPE
                                  ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                                  ,p_payroll_action_id            pay_payroll_actions.payroll_action_id%type)
  IS
  SELECT PAI.object_version_number
        ,PAI.action_information_id
  FROM pay_action_information  PAI
      ,pay_assignment_actions   PAC
  WHERE PAI.action_information_category =  p_action_information_category
  AND   PAI.action_context_id = PAC.assignment_action_id
  AND   PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id
  AND   PAI.action_context_type = 'AAP';
  --------------------------------------------------------------------
  -- Cursor to Fetch  the Master Payroll Action Id
  --------------------------------------------------------------------
  CURSOR lcu_get_pact_info( p_subject_yyyymm VARCHAR2
                           ,p_assignment_id  per_all_assignments_f.assignment_id%TYPE
                           )
  IS
  SELECT fnd_number.canonical_to_number(PCI.action_information3)
  FROM   pay_action_information        PCI
        ,pay_assignment_actions        PAA
  WHERE  PCI.action_information_category = 'JP_WL_PACT'
  AND    TO_CHAR(TO_DATE(PCI.action_information1,'YYYYMM'),'YYYY') =  TO_CHAR(TO_DATE(p_subject_yyyymm,'YYYYMM'),'YYYY')
  AND    PCI.action_information8         = 'Y'
  AND    PCI.action_context_type  = 'PA'
  AND    PAA.payroll_action_id    = PCI.action_context_id
  AND    PAA.assignment_id        = p_assignment_id;
  --------------------------------------------------------------------
  -- Cursor to Fetch fetch the Master Assignment Action Id
  --------------------------------------------------------------------
  CURSOR lcu_org_action_id(p_payroll_action_id            pay_payroll_actions.payroll_action_id%type
                          ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE)

  IS
  SELECT PAC.assignment_action_id
  FROM  pay_assignment_actions   PAC
  WHERE PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id;
  --------------------------------------------------------------------------
  -- Cursor to Fetch fetch the Master Assignment Action Id -- Bug No 8915846
  --------------------------------------------------------------------------
  CURSOR lcu_add_action_id(p_payroll_action_id            pay_payroll_actions.payroll_action_id%type
                          ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE)

  IS
  SELECT PAC.assignment_action_id
  FROM  pay_assignment_actions   PAC
       , pay_action_information  PAI
  WHERE PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id = p_payroll_action_id
  AND   PAC.assignment_action_id = PAI.action_context_id
  AND   PAI.action_information_category = 'JP_WL_EMPLOYEE_DETAILS';
  --------------------------------------------------------------------------
  -- Cursor to fetch YEA Assignment Action Id
  --------------------------------------------------------------------------
  CURSOR lcu_yea_info_id(p_payroll_period               VARCHAR2
                        ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE)
  IS
  SELECT     PAA.assignment_action_id
            ,PPA.effective_date
            ,PPA.date_earned
  FROM      pay_assignment_actions         PAA
           ,pay_payroll_actions            PPA
  WHERE    PAA.assignment_id          = p_assignment_id
  AND      PAA.payroll_action_id      = PPA.payroll_action_id
  and      paa.action_status = 'C'
  AND      PPA.effective_date BETWEEN TRUNC(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),'YEAR') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  -- actually it should refer to pay_jp_wic_assacts_v (pay_jp_pre_tax, not sure design if pre tax archiver is mandatory or not)
  -- so this has performance issue because no index for pay_payroll_actions.element_type_id (should refer to run result)
  -- and issue for itax category change
  and  ((exists(
    select null
    from   pay_element_types_f pet
    where  ppa.action_type = 'B'
    and    pet.element_name in ('YEA_ITX', 'REY_ITX')
    and    pet.legislation_code = 'JP'
    and    ppa.effective_date
           between pet.effective_start_date and pet.effective_end_date
    and    ppa.element_type_id = pet.element_type_id))
    or (exists(
    select null
    from   pay_element_sets pes
    where  ppa.action_type in ('R','Q')
    and    pes.element_set_name in ('YEA','REY')
    and    pes.legislation_code = 'JP'
    and    ppa.element_set_id = pes.element_set_id)))
  order by paa.action_sequence desc;
  --------------------------------------------------------------------------
  -- Cursor to fetch Total Dependent Exemption
  --------------------------------------------------------------------------
  CURSOR lcu_tot_dep_exem(p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                         ,p_subject_yyyymm               VARCHAR2
                         ,p_assignment_action_id         pay_assignment_actions.assignment_action_id%TYPE)
  IS
  SELECT   SUM(NVL(prrv.result_value,0))
  FROM     pay_assignment_actions         PAA
          ,pay_element_types_f            PETF
          ,pay_run_results                PRR
          ,pay_payroll_actions            PPA
          ,pay_run_result_values          PRRV
  WHERE  PAA.assignment_id          = p_assignment_id
  AND    PAA.payroll_action_id      = PPA.payroll_action_id
  AND    PAA.assignment_action_id   = PRR.assignment_action_id
  AND    PRR.element_type_id        = PETF.element_type_id
  AND    PETF.element_name          = 'YEA_DEP_EXM_RSLT'
  AND    PRR.status IN ('P','PA')
  AND    TRUNC(PPA.effective_date )  BETWEEN  PETF.effective_start_date AND PETF.effective_end_date
  AND    PRR.run_result_id          = PRRV.run_result_id
  AND    PPA.effective_date BETWEEN TO_DATE(p_subject_yyyymm,'YYYYMM') AND LAST_DAY(TO_DATE(p_subject_yyyymm,'YYYYMM'))
  AND    PPA.action_type  IN ( 'Q','R','V','B')
  AND    PAA.assignment_action_id = p_assignment_action_id;
  --
  --------------------------------------------------------------------------
  -- Cursor to fetch Over and short tax Assignment Action Id
  --------------------------------------------------------------------------
  CURSOR lcu_over_short_tax_id(p_payroll_period               VARCHAR2
                              ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE)
  IS
  SELECT RUN_PAA.assignment_action_id
        ,RUN_PPA.effective_date
  FROM  pay_payroll_actions    PPA
       ,pay_assignment_actions PAA
       ,pay_assignment_actions RUN_PAA
       ,pay_payroll_actions    RUN_PPA
       ,pay_action_interlocks  PAI
       ,pay_element_sets       PES
       ,pay_element_types_f    PETF
  WHERE PAA.assignment_id             = p_assignment_id
  AND   PAA.payroll_action_id         = PPA.payroll_action_id
  AND   TRUNC(PPA.effective_date)     BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND   PPA.action_type               IN ('P','U')
  AND   PAI.locking_action_id         = PAA.assignment_action_id
  AND   PAI.locked_action_id          = RUN_PAA.assignment_action_id
  AND   PAA.assignment_id             = RUN_PAA.assignment_id
  AND   RUN_PAA.payroll_action_id     = RUN_PPA.payroll_action_id
  AND ((    RUN_PPA.action_type  = 'B'
            AND PETF.element_name IN  ( 'REY_ITX','YEA_ITX')
            AND PETF.legislation_code = 'JP'
            AND RUN_PPA.element_type_id = PETF.element_type_id
            AND NVL(RUN_PPA.element_set_id,PES.element_set_id) = PES.element_set_id
            AND PES.element_set_name  = 'YEA'
            )
     OR (  PES.element_set_name   = 'YEA'
           AND     PES.legislation_code    = 'JP'
           AND     RUN_PPA.action_type IN ('Q','R')
           AND     RUN_PPA.element_set_id = PES.element_set_id
           AND     NVL(RUN_PPA.element_type_id,PETF.element_type_id) = PETF.element_type_id
           AND     PETF.element_name IN  ( 'REY_ITX','YEA_ITX')
           AND     PETF.legislation_code = 'JP'
            ));
  --------------------------------------------------------------------------
  -- Cursor to fetch Over and short tax Assignment Action Id
  --------------------------------------------------------------------------
  CURSOR lcu_over_short_tax_amount(p_payment_date                 DATE
                                  ,p_assignment_action_id         pay_assignment_actions.assignment_action_id%TYPE)
  IS
  SELECT   SUM(NVL(prrv.result_value,0))
  FROM     pay_element_types_f            PETF
          ,pay_run_results                PRR
          ,pay_input_values_f             PIVF
          ,pay_run_result_values          PRRV
  WHERE  PRR.assignment_action_id  =  p_assignment_action_id
  AND    PRR.element_type_id        = PETF.element_type_id
  AND    PETF.element_name           IN  ( 'REY_ITX','YEA_ITX')
  AND    PRR.status IN ('P','PA')
  AND    TRUNC(p_payment_date)  BETWEEN  PETF.effective_start_date AND PETF.effective_end_date
  AND    TRUNC(p_payment_date)  BETWEEN  PIVF.effective_start_date and PIVF.effective_end_date
  AND    PRR.run_result_id          = PRRV.run_result_id
  AND    PRRV.input_value_id        = PIVF.input_value_id
  AND    PIVF.name                  = 'Pay Value';
  --
  --------------------------------------------------------------------------
  -- Cursor to fetch Over and short tax Assignment Action Id
  --------------------------------------------------------------------------
  CURSOR lcu_over_short_check(p_payroll_period                VARCHAR2
                              ,p_assignment_id                per_all_assignments_f.assignment_id%TYPE
                              ,p_element_set_name             pay_element_sets.element_set_name%TYPE)
  IS
  SELECT RUN_PAA.assignment_action_id
  FROM  pay_payroll_actions    PPA
       ,pay_assignment_actions PAA
       ,pay_assignment_actions RUN_PAA
       ,pay_payroll_actions    RUN_PPA
       ,pay_action_interlocks  PAI
       ,pay_element_sets       PES
  WHERE PAA.assignment_id             = p_assignment_id
  AND   PAA.payroll_action_id         = PPA.payroll_action_id
  AND   TRUNC(PPA.effective_date)     BETWEEN TO_DATE(p_payroll_period,'YYYYMM') AND LAST_DAY(TO_DATE(p_payroll_period,'YYYYMM'))
  AND   PPA.action_type               IN ('P','U')
  AND   PAI.locking_action_id         = PAA.assignment_action_id
  AND   PAI.locked_action_id          = RUN_PAA.assignment_action_id
  AND   PAA.assignment_id             = RUN_PAA.assignment_id
  AND   RUN_PAA.payroll_action_id     = RUN_PPA.payroll_action_id
  AND   RUN_PPA.action_type           IN ('Q','R')
  AND   RUN_PPA.element_set_id        = PES.element_set_id
  AND   PES.element_set_name          = p_element_set_name;
  --
  --------------------------------------------------------------------------
  -- Cursor bonus element set
  --------------------------------------------------------------------------
  CURSOR lcu_bonus_element_set(p_element_type_id          pay_element_types_f.element_type_id%TYPE)
  IS
  SELECT  'Y'
  FROM  pay_element_set_members PESM
         ,pay_element_sets       PES
  WHERE PES.element_set_id     = PESM.element_set_id
  AND   PESM.element_type_id   =  p_element_type_id
  AND   PES.element_set_name   = 'SPB';
  --
  TYPE extra_info IS RECORD (extra_info1      VARCHAR2(240)
                            ,extra_info2      VARCHAR2(240)
                            ,extra_info3      VARCHAR2(240)
                            ,extra_info4      VARCHAR2(240)
                            ,extra_info5      VARCHAR2(240)
                            ,extra_info6      VARCHAR2(240)
                            ,extra_info7      VARCHAR2(240)
                            ,extra_info8      VARCHAR2(240)
                            ,extra_info9      VARCHAR2(240)
                            ,extra_info10     VARCHAR2(240)
                            ,extra_info11     VARCHAR2(240)
                            ,extra_info12     VARCHAR2(240)
                            ,extra_info13     VARCHAR2(240)
                            ,extra_info14     VARCHAR2(240)
                            ,extra_info15     VARCHAR2(240)
                            ,extra_info16     VARCHAR2(240)
                            ,extra_info17     VARCHAR2(240)
                            ,extra_info18     VARCHAR2(240)
                            ,extra_info19     VARCHAR2(240)
                            ,extra_info20     VARCHAR2(240)
                            ,extra_info21     VARCHAR2(240)
                            ,extra_info22     VARCHAR2(240)
                            ,extra_info23     VARCHAR2(240)
                            ,extra_info24     VARCHAR2(240)
                            ,extra_info25     VARCHAR2(240)
                            ,extra_info26     VARCHAR2(240)
                            ,extra_info27     VARCHAR2(240)
                            ,extra_info28     VARCHAR2(240)
                            ,extra_info29     VARCHAR2(240)
                            ,extra_info30     VARCHAR2(240)
                            );
  -- Local Variables
  lc_procedure                    VARCHAR2(200);
  lc_itx_type                     pay_element_entry_values_f.screen_entry_value%TYPE;
  lc_subject_yyyymm               VARCHAR2(240);
  lc_submission_required_flag     VARCHAR2(1);
  lc_salary_payer_name_kanji      VARCHAR2(240);
  lc_plsql_block                  VARCHAR2(2000);
  lc_itax_yea_category            pay_element_entry_values_f.screen_entry_value%TYPE;
  lc_widow_type                   VARCHAR2(240);
  lC_spouse_type                  VARCHAR2(240);
  lc_disable_type                 VARCHAR2(240);
  lc_working_student              VARCHAR2(240);
  lc_existence_declaration        VARCHAR2(1) DEFAULT 'N';
  lC_spouse_exists                VARCHAR2(1) DEFAULT 'N';
  lC_general_qualified_spouse     VARCHAR2(1) DEFAULT 'N';
  lC_aged_spouse                  VARCHAR2(1) DEFAULT 'N';
  lc_aged_employee                VARCHAR2(240);
  lc_aged_employee_flag           VARCHAR2(1) DEFAULT 'N';
  lc_action_info_category         pay_action_information.action_information_category%TYPE;
  lc_payroll_period_id            VARCHAR2(20);
  lc_element_set_name             pay_element_sets.element_set_name%TYPE;
  lc_check_element_set_name        pay_element_sets.element_set_name%TYPE DEFAULT NULL;
  lc_month                        VARCHAR2(10);
  lc_payroll_start_period         VARCHAR2(20);
  lc_action_period                VARCHAR2(20);
  lc_renew_flag                   VARCHAR2(1):= 'N';
  lc_update_flag                  VARCHAR2(1):= 'N';
  lc_termination_date             VARCHAR2(20);
  lc_tax_rate                     VARCHAR2(60);
  lc_itx_type_meaning             hr_lookups.meaning%TYPE;
  lc_spouse_exists_meaning        VARCHAR2(60);
  lC_general_qual_meaning         VARCHAR2(60);
  lC_aged_spouse_meaning          VARCHAR2(60);
  lc_aged_employee_meaning        VARCHAR2(60);
  lc_existence_meaning            VARCHAR2(60);
  lc_disable_type_meaning         VARCHAR2(60);
  lc_widow_type_meaning           VARCHAR2(60);
  lc_working_student_meaning      VARCHAR2(60);
  lc_hi_card_num                  VARCHAR2(20);
  lc_wpf_members_num              VARCHAR2(20);
  lc_basic_pension_num            VARCHAR2(20);
  lc_ei_num                       VARCHAR2(20);
  lc_nres_flag                    VARCHAR2(10);
  lc_spb_flag                     VARCHAR2(10);
  lc_dis_set_name                 VARCHAR2(10);
  lc_check_month                  VARCHAR2(10) DEFAULT NULL;
    --
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_yea_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_yea_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_sal_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_sal_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_bon_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_bon_obj_version_num        pay_action_information.object_version_number%TYPE;

  ln_action_info_id1            pay_action_information.action_information_id%TYPE;
  ln_obj_version_num1           pay_action_information.object_version_number%TYPE;
  ln_assignment_id              per_all_assignments_f.assignment_id%TYPE;
  ln_next_assignment_action_id  NUMBER;
  ln_assignment_action_id       NUMBER:= NULL;
  ln_taxable_income             NUMBER;
  ln_si_prem                    NUMBER;
  ln_mutual_aid_prem            NUMBER;
  ln_itax                       NUMBER;
  i                             NUMBER;
  ln_with_hold_agent            NUMBER;
  ln_general_dependents         NUMBER;
  ln_specific_dependents        NUMBER;
  ln_elder_parents              NUMBER;
  ln_elder_dependents           NUMBER;
  ln_generally_disabled         NUMBER;
  ln_specially_dependents       NUMBER;
  ln_specially_dependents_lt    NUMBER;
  ln_payroll_id                 pay_payrolls_f.payroll_id%TYPE;
  ln_element_type_id            pay_element_types_f.element_type_id%TYPE;
  ln_input_value_id             pay_input_values_f.input_value_id%TYPE;
  ln_user_input_count           NUMBER :=0;
  lc_reporting_name             pay_element_types_f_tl.reporting_name%TYPE;
  ln_dependents                 NUMBER:=0;
  ln_tax_rate                   NUMBER:=0;
  ln_sal_si_premium             NUMBER:=0;
  ln_sal_total_earnings         NUMBER:=0;
  ln_sal_wpf_premium            NUMBER:=0;
  ln_sal_wp_premium             NUMBER:=0;
  ln_sal_ei_premium             NUMBER:=0;
  ln_sal_hi_premium             NUMBER:=0;
  ln_tot_si_premium             NUMBER:=0;
  ln_computed_tax_amount        NUMBER:=0;
  ln_bon_si_premium             NUMBER:=0;
  ln_bon_total_earnings         NUMBER:=0;
  ln_bon_wpf_premium            NUMBER:=0;
  ln_bon_wp_premium             NUMBER:=0;
  ln_bon_ei_premium             NUMBER:=0;
  ln_bon_hi_premium             NUMBER:=0;
  ln_element_set_id             NUMBER:=0;
  ln_yea_sal                    NUMBER:=0;
  ln_yea_bonus                  NUMBER:=0;
  ln_yea_sal_tax                NUMBER:=0;
  ln_yea_bon_tax                NUMBER:=0;
  ln_yea_sal_with_ded           NUMBER:=0;
  ln_yea_sal_deducion           NUMBER:=0;
  ln_yea_si_prem                NUMBER:=0;
  ln_yea_samll_comp_prem        NUMBER:=0;
  ln_yea_li_prem                NUMBER:=0;
  ln_yea_ei_prem                NUMBER:=0;
  ln_yea_spouse_income          NUMBER:=0;
  ln_yea_annual_tax             NUMBER:=0;
  ln_yea_over_short_tax         NUMBER:=0;
  ln_yea_tot_deduction_amt      NUMBER:=0;
  ln_yea_net_asseble_amt        NUMBER:=0;
  ln_yea_comptued_tax_amount    NUMBER:=0;
  ln_old_long_non_li_prem       NUMBER:=0;
  ln_sal_ci_premium             NUMBER:=0;
  ln_bon_ci_premium             NUMBER:=0;
  ln_yea_tot_taxable_amt        NUMBER;
  ln_amount                     NUMBER;
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
  ln_amount11                   NUMBER;
  ln_amount12                   NUMBER;
  ln_item_id                    NUMBER;
  ln_age                        NUMBER;
  ln_service_years              NUMBER;
  ln_yea_assignment_action_id   NUMBER;
  ln_pp_prem                    NUMBER;
  ln_npi_prem                   NUMBER;
  ln_housing_loan_credit        NUMBER;
  ln_spouse_sp_exempt           NUMBER;
  ln_basis_exmpt                NUMBER;
  ln_dependent_exmpt            NUMBER;
  ln_gen_spouse_exmpt           NUMBER;
  ln_gen_disable_exmpt          NUMBER;
  ln_total_exempt               NUMBER;
  ln_non_taxable_amount         NUMBER;
  ln_local_tax                  NUMBER;
  ln_tot_afte_si_ded            NUMBER;
  ln_sal_taxable_amount         NUMBER;
  ln_short_over_tax             NUMBER;
  ln_bon_taxable_amount         NUMBER;
  ln_otsu_depts                 NUMBER;
  ln_prev_job_income            NUMBER;
  ln_prev_job_itax              NUMBER;
  ln_adj_emp_income             NUMBER;
  ln_adj_emp_tax                NUMBER;
  ln_collected_tax_amount       NUMBER;
  ln_grace_tax                  NUMBER;
  ln_ostax_action_id            NUMBER;
  ln_short_over_check_id        NUMBER;
  ln_add_assign_act_id          NUMBER;
  --
  ln_master_pact_id             NUMBER;
  ln_org_assign_act_id          NUMBER;
  ln_net_balance                NUMBER;
  ln_total_ded_amt              NUMBER;
  --
  ld_termination_date           DATE;
  ld_effective_start_date       DATE;
  ld_payment_date               DATE;
  ld_wg_effective_date          DATE;
  ld_yea_effective_date         DATE;
  ld_yea_date_earned            DATE;
  ld_ostax_date                 DATE;
  --
  lr_proc_name                  lcu_proc_name%ROWTYPE;
  lr_extra_info                 extra_info;
  --
  lt_prev_jobs                  pay_jp_wic_pkg.t_prev_jobs;
  lt_certificate_info           pay_jp_wic_pkg.t_tax_info;
  lt_tax_info                   pay_jp_wic_pkg.t_tax_info;
  lt_wage_ledger                t_wage_ledger;
  lt_pay_wage_ledger            t_wage_ledger;
  lt_prev_job_info              pay_jp_wic_pkg.t_prev_job_info;
  lt_get_certificate_info       pay_jp_wic_pkg.t_certificate_info;
  --
  l_itw_user_desc_kanji		  VARCHAR2(32767);
  l_itw_descriptions		  pay_jp_wic_pkg.t_descriptions;
  l_wtm_user_desc			  VARCHAR2(32767);
  l_wtm_user_desc_kanji		  VARCHAR2(32767);
  l_wtm_user_desc_kana		  VARCHAR2(32767);
  l_wtm_descriptions		  pay_jp_wic_pkg.t_descriptions;
  --
  l_itw_system_desc1_kanji	  VARCHAR2(32767);
  l_itw_system_desc2_kanji	  VARCHAR2(32767);
  l_wtm_system_desc_kanji	  VARCHAR2(32767);
  l_wtm_system_desc_kana	  VARCHAR2(32767);
  l_varchar2_tbl			  hr_jp_standard_pkg.t_varchar2_tbl;
  --
  BEGIN
    --
    gb_debug := hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
      --
      lc_procedure := gc_package||'ARCHIVE_CODE';
      hr_utility.set_location('Entering ' || lc_procedure,1);
      --
    END IF;
    -- initialization_code to to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    --
    lt_wage_ledger := gt_wage_ledger;
    --
    -- Fetch the Assignemnt Id
    --
    OPEN  lcu_get_assignment_id(p_assignment_action_id);
    FETCH lcu_get_assignment_id INTO ln_assignment_id;
    CLOSE lcu_get_assignment_id;
    --
    -- Fetch the Master Payroll Action Id
    --
    OPEN  lcu_get_pact_info(gr_parameters.subject_yyyymm,ln_assignment_id);
    FETCH lcu_get_pact_info INTO ln_master_pact_id;
    CLOSE lcu_get_pact_info;
    --
    IF ln_master_pact_id IS NOT NULL   THEN
      --
      IF (gr_parameters.archive_option = 'RENEW') THEN
        --

       DELETE_ASSACT(ln_master_pact_id,ln_assignment_id);
       OPEN  lcu_org_action_id(ln_master_pact_id,ln_assignment_id);
       FETCH lcu_org_action_id INTO ln_org_assign_act_id;
       CLOSE lcu_org_action_id;
       lc_renew_flag := 'Y';
        --
      ELSIF (gr_parameters.archive_option = 'ADD') THEN
      --
        OPEN  lcu_org_action_id(ln_master_pact_id,ln_assignment_id);
        FETCH lcu_org_action_id INTO ln_org_assign_act_id;
        CLOSE lcu_org_action_id;
        --
        OPEN  lcu_add_action_id(ln_master_pact_id,ln_assignment_id);  --  bug No 8915846
        FETCH lcu_add_action_id INTO ln_add_assign_act_id;
        CLOSE lcu_add_action_id;
        --
        IF gb_debug THEN
        --
         hr_utility.set_location('ln_add_assign_act_id = ' || ln_add_assign_act_id,1);
         hr_utility.set_location('ln_master_pact_id = ' || ln_master_pact_id,2);
         --
        END IF;
       --
       IF ln_add_assign_act_id IS NOT NULL THEN
         --
         lc_update_flag := 'Y';
         --
       ELSE
         --
         lc_renew_flag := 'Y';
         --
        END IF;
        --
      END IF;
      --
    ELSE
      --
      ln_org_assign_act_id := p_assignment_action_id;
      lc_renew_flag := 'Y';
      --
    END IF;
    --
    IF  gr_parameters.archive_option = 'UPDATE' THEN
      --
      lc_update_flag := 'Y';
      --
    END IF;
    -- Fetch the Procedure Name
    --
    OPEN  lcu_proc_name ( p_effective_date );
        FETCH lcu_proc_name INTO lr_proc_name;
    CLOSE lcu_proc_name;
    --
    IF gb_debug THEN
      hr_utility.set_location('Opening Employee Details cursor for ARCHIVE Assignment Id = '||ln_assignment_id,30);
      hr_utility.set_location('lc_update_flag ='|| lc_update_flag ,30);
      hr_utility.set_location('lc_renew_flag = '||lc_renew_flag,30);
    END IF;
    --
    IF  lc_update_flag = 'Y' THEN
        --
        update_arch(p_assignment_action_id,ln_master_pact_id,ln_assignment_id,p_effective_date);
        --
    ELSIF  lc_renew_flag = 'Y' THEN
       --
    FOR lr_emp_rec  IN lcu_employee_details(ln_assignment_id,LAST_DAY(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM')))
    LOOP
    --
      -- initialize local arguments
    --
      ln_yea_assignment_action_id := null;
      ld_yea_effective_date := to_date(null);
      ld_yea_date_earned := to_date(null);
      ln_total_exempt := null;
      ln_yea_obj_version_num := null;
      ln_yea_action_info_id := null;
    --
      --
      IF TRUNC(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),'YEAR') >= TRUNC(lr_emp_rec.hire_date) THEN
         ld_effective_start_date := TRUNC(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),'YEAR');
      ELSE
       ld_effective_start_date := TRUNC(lr_emp_rec.hire_date);
      END IF;
      --
      ld_wg_effective_date := nvl(lr_emp_rec.termination_date,LAST_DAY(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM')));
      --
      IF lr_emp_rec.termination_date > lr_emp_rec.termination_date THEN
         lc_termination_date := NULL;
      ELSE
         lc_termination_date := fnd_date.date_to_canonical(lr_emp_rec.termination_date);
      END IF;
      --

      lc_hi_card_num        :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                                       ,p_input_value_name => 'HI_CARD_NUM'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                        );
      lc_basic_pension_num  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                                       ,p_input_value_name => 'BASIC_PENSION_NUM'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_wpf_members_num    :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                                       ,p_input_value_name => 'WPF_MEMBERS_NUM'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_ei_num             :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_LI_INFO'
                                                                       ,p_input_value_name => 'EI_NUM'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_itx_type            := pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                       ,p_input_value_name => 'ITX_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_with_hold_agent     :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                       ,p_input_value_name => 'WITHHOLD_AGENT'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_itax_yea_category   :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                       ,p_input_value_name => 'YEA_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lC_spouse_type         :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'SPOUSE_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_general_dependents  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_DEP'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_specific_dependents :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_SPECIFIC_DEP'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_elder_parents       := pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_ELDER_PARENT_LT'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_elder_dependents    :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_ELDER_DEP'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_generally_disabled  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_GEN_DISABLED'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_specially_dependents    :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_SEV_DISABLED'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      ln_specially_dependents_lt  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'NUM_OF_SEV_DISABLED_LT'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_widow_type               :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'WIDOW_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_disable_type             :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'DISABLE_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_working_student          :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'WORKING_STUDENT_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );
      lc_aged_employee            :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'YEA_DEP_EXM_PROC'
                                                                       ,p_input_value_name => 'ELDER_TYPE'
                                                                       ,p_assignment_id    => lr_emp_rec.assignment_id
                                                                       ,p_effective_date   => ld_wg_effective_date
                                                                       );

      ln_age := TRUNC((TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM') - lr_emp_rec.date_of_birth)/365);
      --
      ln_service_years := ROUND((TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM') - lr_emp_rec.hire_date)/365);
      --
      lc_itx_type_meaning := proc_lookup_meaning('JP_ITAX_TYPE',lc_itx_type);
      --
      pay_action_information_api.create_action_information
      (
        p_validate                       => FALSE
       ,p_action_context_id              => ln_org_assign_act_id
       ,p_action_context_type            => 'AAP'
       ,p_action_information_category    => 'JP_WL_EMPLOYEE_DETAILS'
       ,p_tax_unit_id                    => NULL
       ,p_jurisdiction_code              => NULL
       ,p_source_id                      => NULL
       ,p_source_text                    => NULL
       ,p_tax_group                      => NULL
       ,p_effective_date                 => p_effective_date
       ,p_assignment_id                  => fnd_number.number_to_canonical(lr_emp_rec.assignment_id)
       ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.organization_id)
       ,p_action_information2            => fnd_number.number_to_canonical(lr_emp_rec.payroll_id)
       ,p_action_information3            => fnd_number.number_to_canonical(ln_with_hold_agent)
       ,p_action_information4            => fnd_number.number_to_canonical(lr_emp_rec.location_id)
       ,p_action_information5            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
       ,p_action_information6            => lr_emp_rec.full_name_kana
       ,p_action_information7            => lr_emp_rec.full_name_kanji
       ,p_action_information8            => lr_emp_rec.payroll_name
       ,p_action_information9            => fnd_number.number_to_canonical(ln_age)
       ,p_action_information10           => lc_hi_card_num
       ,p_action_information11           => lc_wpf_members_num
       ,p_action_information12           => lc_basic_pension_num
       ,p_action_information13           => lc_ei_num
       ,p_action_information14           => fnd_date.date_to_canonical(lr_emp_rec.hire_date)
       ,p_action_information15           => fnd_number.number_to_canonical(ln_service_years)
       ,p_action_information16           => lc_itx_type_meaning
       ,p_action_information17           => fnd_date.date_to_canonical(lr_emp_rec.termination_date)
       ,p_action_information18           => lr_emp_rec.organization_name
       ,p_action_information19           => lr_emp_rec.gender
       ,p_action_information20           => lr_emp_rec.job_title
       ,p_action_information21           => lr_emp_rec.postal_code
       ,p_action_information22           => lr_emp_rec.address_line1
       ,p_action_information23           => lr_emp_rec.address_line2
       ,p_action_information24           => lr_emp_rec.address_line3
       ,p_action_information25           => fnd_date.date_to_canonical(lr_emp_rec.date_of_birth)
       ,p_action_information26           => lr_emp_rec.employee_number
       ,p_action_information27           => lr_emp_rec.phone_number
       ,p_action_information28           => lr_emp_rec.address_line1_kana
       ,p_action_information29           => lr_emp_rec.address_line2_kana
       ,p_action_information30           => lr_emp_rec.address_line3_kana
       ,p_action_information_id          => ln_action_info_id
       ,p_object_version_number          => ln_obj_version_num
       );
      -- Previous Employee Details
      --
      IF gb_debug THEN
        hr_utility.set_location('Before pay_jp_wic_pkg.get_certificate_info',30);
      END IF;
      --
     pay_jp_wic_pkg.get_certificate_info
      (
       p_assignment_action_id     => NULL
      ,p_assignment_id            => ln_assignment_id
      ,p_action_sequence          => NULL
      ,p_effective_date           => ld_wg_effective_date
      ,p_itax_organization_id     => ln_with_hold_agent
      ,p_itax_category            => lc_itx_type
      ,p_itax_yea_category        => NULL
      ,p_employment_category      => lr_emp_rec.employment_category
      ,p_person_id                => lr_emp_rec.person_id
      ,p_business_group_id        => gn_business_group_id
      ,p_date_earned              => ld_wg_effective_date
      ,p_certificate_info         => lt_certificate_info
      ,p_submission_required_flag => lc_submission_required_flag
      ,p_withholding_tax_info     => lt_tax_info
      ,p_prev_jobs                => lt_prev_jobs
      );
      --
      IF gb_debug THEN
        hr_utility.set_location('After pay_jp_wic_pkg.get_certificate_info',30);
      END IF;
      --
        i := lt_prev_jobs.first;
        WHILE  i IS NOT NULL LOOP
        --
        IF gb_debug THEN
           hr_utility.set_location('Inside Previous Employee Details loop',30);
        END IF;
        --
        pay_action_information_api.create_action_information
          (
           p_validate                       => FALSE
          ,p_action_context_id              => ln_org_assign_act_id
          ,p_action_context_type            => 'AAP'
          ,p_action_information_category    => 'JP_WL_PREVIOUS_JOB_DETAILS'
          ,p_tax_unit_id                    => NULL
          ,p_jurisdiction_code              => NULL
          ,p_source_id                      => NULL
          ,p_source_text                    => NULL
          ,p_tax_group                      => NULL
          ,p_effective_date                 => p_effective_date
          ,p_assignment_id                  => ln_assignment_id
          ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
          ,p_action_information2            => lt_prev_jobs(i).salary_payer_name_kanji
          ,p_action_information3            => lt_prev_jobs(i).salary_payer_address_kana
          ,p_action_information4            => fnd_number.number_to_canonical(lt_prev_jobs(i).taxable_income)
          ,p_action_information5            => fnd_number.number_to_canonical(lt_prev_jobs(i).si_prem)
          ,p_action_information6            => fnd_number.number_to_canonical(lt_prev_jobs(i).mutual_aid_prem)
          ,p_action_information7            => fnd_number.number_to_canonical(lt_prev_jobs(i).itax)
          ,p_action_information8            => fnd_date.date_to_canonical(lt_prev_jobs(i).termination_date)
          ,p_action_information_id          => ln_action_info_id
          ,p_object_version_number          => ln_obj_version_num
          );
          --
        ln_prev_job_income  := NVL(ln_prev_job_income,0)  + NVL(lt_prev_jobs(i).taxable_income,0);     -- Bug 8830491
        ln_prev_job_itax    := NVL(ln_prev_job_itax,0) + NVL(lt_prev_jobs(i).itax,0);
        i := lt_prev_jobs.next(i);
        --
        END LOOP;
        --
        IF gb_debug THEN
          hr_utility.set_location('After the Previous Employee Details loop',30);
        END IF;
        --
        -- End Previous Employee Details
        --

        -- Payroll Information
        --
        IF gb_debug THEN
          hr_utility.set_location('Before the Payroll Information',30);
        END IF;
        --
        IF lr_emp_rec.payroll_id IS NOT NULL THEN
        --
        i := lt_wage_ledger.first;
        WHILE  i IS NOT NULL LOOP
          --
          IF gb_debug THEN
            hr_utility.set_location('In side the Pay wage ledger loop ',30);
          END IF;
          --
          IF lt_wage_ledger(i).org_information1 = lr_emp_rec.payroll_id  THEN
            --
            lt_pay_wage_ledger(i).org_information_id := lt_wage_ledger(i).org_information_id;
            lt_pay_wage_ledger(i).organization_id    := lt_wage_ledger(i).organization_id;
            lt_pay_wage_ledger(i).org_information1   := lt_wage_ledger(i).org_information1;
            lt_pay_wage_ledger(i).org_information2   := lt_wage_ledger(i).org_information2;
            lt_pay_wage_ledger(i).org_information3   := lt_wage_ledger(i).org_information3;
            lt_pay_wage_ledger(i).org_information4   := lt_wage_ledger(i).org_information4;
            lt_pay_wage_ledger(i).org_information5   := lt_wage_ledger(i).org_information5;
            lt_pay_wage_ledger(i).org_information6   := lt_wage_ledger(i).org_information6;
            lt_pay_wage_ledger(i).org_information7   := lt_wage_ledger(i).org_information7;
            lt_pay_wage_ledger(i).org_information8   := lt_wage_ledger(i).org_information8;
            lt_pay_wage_ledger(i).org_information9   := lt_wage_ledger(i).org_information9;
            lt_pay_wage_ledger(i).org_information10  := lt_wage_ledger(i).org_information10;
            lt_pay_wage_ledger(i).org_information11  := lt_wage_ledger(i).org_information11;
            lt_pay_wage_ledger(i).org_information12  := lt_wage_ledger(i).org_information12;
            lt_pay_wage_ledger(i).org_information13  := lt_wage_ledger(i).org_information13;
            --
          ELSIF ((lt_wage_ledger(i).org_information1 IS NULL) AND (lt_wage_ledger(i).organization_id = ln_with_hold_agent )) THEN
            --
            lt_pay_wage_ledger(i).org_information_id := lt_wage_ledger(i).org_information_id;
            lt_pay_wage_ledger(i).organization_id    := lt_wage_ledger(i).organization_id;
            lt_pay_wage_ledger(i).org_information1   := lt_wage_ledger(i).org_information1;
            lt_pay_wage_ledger(i).org_information2   := lt_wage_ledger(i).org_information2;
            lt_pay_wage_ledger(i).org_information3   := lt_wage_ledger(i).org_information3;
            lt_pay_wage_ledger(i).org_information4   := lt_wage_ledger(i).org_information4;
            lt_pay_wage_ledger(i).org_information5   := lt_wage_ledger(i).org_information5;
            lt_pay_wage_ledger(i).org_information6   := lt_wage_ledger(i).org_information6;
            lt_pay_wage_ledger(i).org_information7   := lt_wage_ledger(i).org_information7;
            lt_pay_wage_ledger(i).org_information8   := lt_wage_ledger(i).org_information8;
            lt_pay_wage_ledger(i).org_information9   := lt_wage_ledger(i).org_information9;
            lt_pay_wage_ledger(i).org_information10  := lt_wage_ledger(i).org_information10;
            lt_pay_wage_ledger(i).org_information11  := lt_wage_ledger(i).org_information11;
            lt_pay_wage_ledger(i).org_information12  := lt_wage_ledger(i).org_information12;
            lt_pay_wage_ledger(i).org_information13  := lt_wage_ledger(i).org_information13;
            --
          END IF;
            ln_user_input_count := ln_user_input_count + 1;
             --
          i := lt_wage_ledger.next(i);
        END LOOP;
        --
        IF gb_debug THEN
            hr_utility.set_location('ln_user_input_count =',ln_user_input_count);
        END IF;
        --
        lc_payroll_period_id := gr_parameters.subject_yyyymm;
        --
        IF (gr_parameters.archive_option = 'RENEW') THEN
                --
                lc_payroll_start_period :=  TO_CHAR(TRUNC(TO_DATE(gr_parameters.subject_yyyymm,'YYYYMM'),'YEAR'),'YYYYMM');
                --
        ELSE
          --
          lc_payroll_start_period  := lc_payroll_period_id;
          --
        END IF;
        --
           IF ln_user_input_count > 0 THEN
           --
           i := lt_pay_wage_ledger.first;
           WHILE  i IS NOT NULL LOOP
           --
           OPEN  lcu_payment_action_date (p_assignment_id          =>   ln_assignment_id
                                         ,p_payroll_start_period   => lc_payroll_start_period
                                         ,p_payroll_end_period     => lc_payroll_period_id
                                        );
           LOOP
           FETCH lcu_payment_action_date INTO ld_payment_date,lc_element_set_name,ln_assignment_action_id;
           EXIT WHEN lcu_payment_action_date%NOTFOUND;
           IF lc_element_set_name IN ('SAL','BON','SPB') THEN  -- Bug No 8911344
             --
             lc_month := TO_CHAR(ld_payment_date,'MM');

             IF ( ((lc_month<> lc_check_month) OR lc_check_month IS NULL OR lc_check_element_set_name IS NULL) OR (lc_month = lc_check_month AND lc_check_element_set_name <> lc_element_set_name))THEN -- 9031713
             lc_check_month := lc_month;                       -- Bug 9031713
             lc_check_element_set_name := lc_element_set_name; -- Bug 9031713
             lc_action_period := TO_CHAR(ld_payment_date,'YYYYMM');  -- Added for bug 8830343
              --
              IF gb_debug THEN
                hr_utility.set_location('lc_action_period before payroll' ||lc_action_period,30);
                hr_utility.set_location('lc_element_set_name='||lc_element_set_name,30);
              END IF;
             --
             IF lt_pay_wage_ledger(i).org_information5 = 'ELEMENT' THEN
             --
             ln_amount := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                             ,p_payroll_period   => lc_action_period  -- Changed for bug 8830343
                                             ,p_element_type_id  => fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information7)
                                             ,p_input_value_id   => fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information8)
                                            );
             --
             --Getting reporting name
             --
             ln_item_id := lt_pay_wage_ledger(i).org_information7;
             --
             IF lt_wage_ledger(i).org_information12  IS NULL THEN
               OPEN   lcu_element_report_name(fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information7)
                                             ,p_effective_date);
                 FETCH lcu_element_report_name INTO lc_reporting_name;
               CLOSE lcu_element_report_name;
             ELSE
               lc_reporting_name := lt_wage_ledger(i).org_information12;
             END IF;
             --
           ELSIF lt_pay_wage_ledger(i).org_information5 = 'BALANCE' THEN
             --
                    ln_amount := pay_balance_result_value(  p_assignment_id    => ln_assignment_id
                                                           ,p_payroll_period       => lc_action_period  -- Changed for bug 8830343
                                                           ,p_element_set_name     => lc_element_set_name
                                                           ,p_balance_type_id      => fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information10)
                                                           ,p_balance_dimension_id => fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information11)
                                                           );

             --
             --Getting reporting name
             --
             ln_item_id := lt_pay_wage_ledger(i).org_information10;
             --
             IF lt_wage_ledger(i).org_information12  IS NULL THEN
               OPEN   lcu_balance_report_name(fnd_number.canonical_to_number(lt_pay_wage_ledger(i).org_information10));
                 FETCH lcu_balance_report_name INTO lc_reporting_name;
               CLOSE lcu_balance_report_name;
             ELSE
               lc_reporting_name := lt_wage_ledger(i).org_information12;
             END IF;
             --
          END IF;
          --
          CASE
              WHEN lc_month = '01' THEN ln_amount1:=  ln_amount;
              WHEN lc_month = '02' THEN ln_amount2:=  ln_amount;
              WHEN lc_month = '03' THEN ln_amount3:=  ln_amount;
              WHEN lc_month = '04' THEN ln_amount4:=  ln_amount;
              WHEN lc_month = '05' THEN ln_amount5:=  ln_amount;
              WHEN lc_month = '06' THEN ln_amount6:=  ln_amount;
              WHEN lc_month = '07' THEN ln_amount7:=  ln_amount;
              WHEN lc_month = '08' THEN ln_amount8:=  ln_amount;
              WHEN lc_month = '09' THEN ln_amount9:=  ln_amount;
              WHEN lc_month = '10' THEN ln_amount10:=  ln_amount;
              WHEN lc_month = '11' THEN ln_amount11:=  ln_amount;
              WHEN lc_month = '12' THEN ln_amount12:=  ln_amount;
              ELSE  lc_month := NULL;
          END CASE;
          --
          CASE
            WHEN  lt_pay_wage_ledger(i).org_information2 = 'SAL_EARN' THEN lc_action_info_category := 'JP_WL_SAL_EARN';

            WHEN  lt_pay_wage_ledger(i).org_information2 = 'SAL_DCT'  THEN lc_action_info_category := 'JP_WL_SAL_DCT';

            WHEN  lt_pay_wage_ledger(i).org_information2 = 'WRK_DAYS' THEN lc_action_info_category := 'JP_WL_WRK_HOURS_DAYS';


            WHEN  lt_pay_wage_ledger(i).org_information2 = 'BON_EARN' THEN lc_action_info_category := 'JP_WL_BON_EARN';


            WHEN  lt_pay_wage_ledger(i).org_information2 = 'BON_DCT'  THEN lc_action_info_category := 'JP_WL_BON_DCT';
            ELSE  lc_action_info_category := NULL;
          END CASE;
          --
          ln_amount := NULL;
          --
          END IF; -- 9031713

          END IF; -- Bug No 8911344
          END LOOP;
          CLOSE lcu_payment_action_date;
          --
          ln_action_info_id  := NULL;
          ln_obj_version_num := NULL;
          --
          IF (lc_action_info_category ='JP_WL_SAL_EARN' OR lc_action_info_category = 'JP_WL_SAL_DCT' OR lc_action_info_category = 'JP_WL_WRK_HOURS_DAYS') THEN
            --
            pay_action_information_api.create_action_information
             (
             p_validate                       => FALSE
            ,p_action_context_id              => ln_org_assign_act_id
            ,p_action_context_type            => 'AAP'
            ,p_action_information_category    => lc_action_info_category
            ,p_tax_unit_id                    => NULL
            ,p_jurisdiction_code              => NULL
            ,p_source_id                      => NULL
            ,p_source_text                    => NULL
            ,p_tax_group                      => NULL
            ,p_effective_date                 => p_effective_date
            ,p_assignment_id                  => ln_assignment_id
            ,p_action_information1            => lt_wage_ledger(i).org_information3
            ,p_action_information2            => fnd_number.number_to_canonical(ln_item_id)
            ,p_action_information3            => lt_wage_ledger(i).org_information5
            ,p_action_information4            => lc_reporting_name
            ,p_action_information5            => fnd_number.number_to_canonical(lt_wage_ledger(i).org_information13)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_amount1)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_amount2)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_amount3)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_amount4)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_amount5)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_amount6)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_amount7)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_amount8)
            ,p_action_information14           => fnd_number.number_to_canonical(ln_amount9)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_amount10)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_amount11)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_amount12)
            ,p_action_information18           => NULL -- ln_secondary_dependents
            ,p_action_information_id          => ln_action_info_id
            ,p_object_version_number          => ln_obj_version_num
            );
            --
          ELSIF (lc_action_info_category ='JP_WL_BON_EARN' OR lc_action_info_category = 'JP_WL_BON_DCT') THEN
           --
             OPEN   lcu_bonus_element_set(ln_item_id);
               FETCH  lcu_bonus_element_set INTO lc_spb_flag;
             CLOSE  lcu_bonus_element_set;
             --
             IF lc_spb_flag IS NULL THEN
                lc_dis_set_name :='BON';
             ELSE
               lc_dis_set_name :='SPB';
             END IF;
             --
              pay_action_information_api.create_action_information
              (
              p_validate                       => FALSE
             ,p_action_context_id              => ln_org_assign_act_id
             ,p_action_context_type            => 'AAP'
             ,p_action_information_category    => lc_action_info_category
             ,p_tax_unit_id                    => NULL
             ,p_jurisdiction_code              => NULL
             ,p_source_id                      => NULL
             ,p_source_text                    => NULL
             ,p_tax_group                      => NULL
             ,p_effective_date                 => p_effective_date
             ,p_assignment_id                  => ln_assignment_id
             ,p_action_information1            => lt_wage_ledger(i).org_information2
             ,p_action_information2            => lt_wage_ledger(i).org_information3
             ,p_action_information3            => fnd_number.number_to_canonical(ln_item_id)
             ,p_action_information4            => lt_wage_ledger(i).org_information5
             ,p_action_information5            => lc_reporting_name
             ,p_action_information6            => fnd_number.number_to_canonical(lt_wage_ledger(i).org_information13)
             ,p_action_information7            => fnd_number.number_to_canonical(ln_amount1)
             ,p_action_information8            => fnd_number.number_to_canonical(ln_amount2)
             ,p_action_information9            => fnd_number.number_to_canonical(ln_amount3)
             ,p_action_information10           => fnd_number.number_to_canonical(ln_amount4)
             ,p_action_information11           => fnd_number.number_to_canonical(ln_amount5)
             ,p_action_information12           => fnd_number.number_to_canonical(ln_amount6)
             ,p_action_information13           => fnd_number.number_to_canonical(ln_amount7)
             ,p_action_information14           => fnd_number.number_to_canonical(ln_amount8)
             ,p_action_information15           => fnd_number.number_to_canonical(ln_amount9)
             ,p_action_information16           => fnd_number.number_to_canonical(ln_amount10)
             ,p_action_information17           => fnd_number.number_to_canonical(ln_amount11)
             ,p_action_information18           => fnd_number.number_to_canonical(ln_amount12)
             ,p_action_information19           => NULL
             ,p_action_information20           => lc_dis_set_name
             ,p_action_information_id          => ln_action_info_id
             ,p_object_version_number          => ln_obj_version_num
             );
              --
          END IF;
          --
          ln_amount1 := NULL;
          ln_amount2 := NULL;
          ln_amount3 := NULL;
          ln_amount4 := NULL;
          ln_amount5 := NULL;
          ln_amount6 := NULL;
          ln_amount7 := NULL;
          ln_amount8 := NULL;
          ln_amount9 := NULL;
          ln_amount10 := NULL;
          ln_amount11 := NULL;
          ln_amount12 := NULL;
          ln_amount   := NULL;
          lc_spb_flag:= NULL;
          i := lt_pay_wage_ledger.next(i);
        END LOOP;
        --
        END IF;  -- End if of ln_user_input_count
        -- End Payroll Information
        --
        lc_check_month := NULL;
        lc_check_element_set_name := NULL;
        lc_payroll_period_id := gr_parameters.subject_yyyymm;
        --
        OPEN  lcu_payment_action_date (   p_assignment_id          =>  ln_assignment_id
                                         ,p_payroll_start_period   =>  lc_payroll_start_period
                                         ,p_payroll_end_period     =>  lc_payroll_period_id
                                        );
        LOOP
        --
          -- initialize local arguments
        --
          ln_ostax_action_id := null;
          ld_ostax_date := to_date(null);
          ln_short_over_check_id := null;
          ln_short_over_tax := null;
        --
        FETCH lcu_payment_action_date INTO ld_payment_date,lc_element_set_name,ln_assignment_action_id;
        EXIT WHEN lcu_payment_action_date%NOTFOUND;

        lc_month := TO_CHAR(ld_payment_date,'MM');

        IF ( ((lc_month<> lc_check_month) OR lc_check_month IS NULL OR lc_check_element_set_name IS NULL) OR (lc_month = lc_check_month AND lc_check_element_set_name <> lc_element_set_name))THEN -- 9031713
        lc_check_month := lc_month;
        lc_check_element_set_name := lc_element_set_name;
        lc_action_period := TO_CHAR(ld_payment_date,'YYYYMM');
        --
        -- Start Monthly Payroll Deductions and Tax Information
        -- Fetching Number of dependents
          --
          IF gb_debug THEN
            hr_utility.set_location('ln_assignment_id ='||ln_assignment_id,30);
            hr_utility.set_location('ld_payment_date ='||ld_payment_date,30);
            hr_utility.set_location('lc_element_set_name ='||lc_element_set_name,30);
            hr_utility.set_location('lc_payroll_start_period ='||lc_payroll_start_period ,30);
            hr_utility.set_location('lc_payroll_period_id='||lc_payroll_period_id,30);
            hr_utility.set_location('gr_parameters.subject_yyyymm_SAL='||gr_parameters.subject_yyyymm,30);
            hr_utility.set_location('Before Monthly Salary Information',30);
          END IF;
          --
          IF  lc_element_set_name = 'SAL' THEN
          --
          IF gb_debug THEN
            hr_utility.set_location('Inside Salary Loop',30);
            hr_utility.set_location('lc_action_period =' ||lc_action_period,30);
          END IF;
          --
          ln_dependents :=   pay_jp_balance_pkg.get_result_value_number (p_element_name  =>  'SAL_ITX'
                                                     ,p_input_value_name    => 'NUM_OF_DEP'
                                                     ,p_assignment_action_id => ln_assignment_action_id
                                                     );
          --
          -- Fetching Payment Date
          --
          --
          ln_tax_rate := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                                ,p_payroll_period  => lc_action_period
                                                ,p_element_name  => 'SAL_ITX'
                                                ,p_input_name    => 'Pay Value');


          ln_sal_ci_premium := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                                ,p_payroll_period   => lc_action_period
                                                ,p_element_name  => 'SAL_CI_PREM_EE'
                                                ,p_input_name    => 'Pay Value');

          ln_computed_tax_amount :=   pay_sal_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                                ,p_payroll_period       => lc_action_period
                                                                ,p_balance_name         => 'B_SAL_ITX'
                                                               ,p_dimension_name       => '_ASG_RUN'
                                                              );

          ln_sal_si_premium := pay_sal_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_SI_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );

          ln_sal_total_earnings := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_ERN'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );
          ln_sal_wpf_premium   := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_WPF_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );

          ln_sal_wp_premium   := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_WP_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );
          ln_sal_ei_premium   := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_EI_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );
          ln_sal_hi_premium   := pay_sal_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                   ,p_payroll_period       => lc_action_period
                                                   ,p_balance_name         => 'B_SAL_HI_PREM'
                                                   ,p_dimension_name       => '_ASG_RUN'
                                                  );
          ln_sal_taxable_amount :=  pay_sal_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_SAL_TXBL_ERN_MONEY'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              );
          ln_local_tax := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                                ,p_payroll_period  => lc_action_period
                                                ,p_element_name  => 'SAL_LTX'
                                                ,p_input_name    => 'Pay Value');

          ln_total_ded_amt := pay_sal_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                            ,p_payroll_period       => lc_action_period
                                                            ,p_balance_name         => 'B_SAL_DCT'
                                                            ,p_dimension_name       => '_ASG_RUN'
                                                            );
          OPEN  lcu_over_short_tax_id (p_assignment_id        => ln_assignment_id
                                      ,p_payroll_period       => lc_action_period
                               );
          FETCH lcu_over_short_tax_id  INTO ln_ostax_action_id
                                           ,ld_ostax_date;
          CLOSE lcu_over_short_tax_id;
          --
          IF ln_ostax_action_id IS NOT NULL THEN
            --
            OPEN   lcu_over_short_check(p_payroll_period    =>    lc_action_period
                                       ,p_assignment_id     =>    ln_assignment_id
                                       ,p_element_set_name  =>    lc_element_set_name);

            FETCH lcu_over_short_check INTO ln_short_over_check_id;
            CLOSE lcu_over_short_check;
            --
            IF gb_debug THEN
                --
                hr_utility.set_location('ln_short_over_check_id = ' || ln_short_over_check_id,30);
                --
            END IF;
            --
            IF ln_short_over_check_id  IS NOT NULL THEN
              --
              OPEN  lcu_over_short_tax_amount(p_payment_date           => ld_ostax_date
                                             ,p_assignment_action_id   => ln_ostax_action_id
                                           );
              FETCH lcu_over_short_tax_amount INTO ln_short_over_tax ;
              CLOSE lcu_over_short_tax_amount;
              --
            END IF;
            --
          END IF;
          --
          ln_tot_si_premium := NVL(ln_sal_wp_premium,0)  + NVL(ln_sal_hi_premium,0) + NVL(ln_sal_wpf_premium,0) + NVL(ln_sal_ei_premium,0);
          ln_non_taxable_amount := NVL(ln_sal_total_earnings,0) - NVL(ln_sal_taxable_amount,0);
          ln_collected_tax_amount := NVL(ln_computed_tax_amount,0) + NVL(ln_short_over_tax,0);
          ln_net_balance := NVL(ln_sal_total_earnings,0)-NVL(ln_total_ded_amt,0);
          ln_tot_afte_si_ded  := NVL(ln_sal_total_earnings,0) - NVL(ln_tot_si_premium,0);
          --
          pay_action_information_api.create_action_information
             (
             p_validate                       => FALSE
            ,p_action_context_id              => ln_org_assign_act_id
            ,p_action_context_type            => 'AAP'
            ,p_action_information_category    => 'JP_WL_MNTH_PAY_INFO'
            ,p_tax_unit_id                    => NULL
            ,p_jurisdiction_code              => NULL
            ,p_source_id                      => NULL
            ,p_source_text                    => NULL
            ,p_tax_group                      => NULL
            ,p_effective_date                 => p_effective_date
            ,p_assignment_id                  => ln_assignment_id
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_date.date_to_canonical(ld_payment_date)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_sal_taxable_amount)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_non_taxable_amount)
            ,p_action_information5            => fnd_number.number_to_canonical(ln_sal_total_earnings)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_sal_si_premium)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_sal_hi_premium)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_sal_wp_premium)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_sal_wpf_premium)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_sal_ei_premium)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_tot_si_premium)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_tot_afte_si_ded)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_dependents)
            ,p_action_information14           => NULL --fnd_number.number_to_canonical(ln_tax_rate)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_computed_tax_amount)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_short_over_tax)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_collected_tax_amount)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_sal_ci_premium)
            ,p_action_information19           => fnd_number.number_to_canonical(ln_local_tax)
            ,p_action_information20           => fnd_number.number_to_canonical(ln_total_ded_amt)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_net_balance)
            ,p_action_information_id          => ln_sal_action_info_id
            ,p_object_version_number          => ln_sal_obj_version_num
            );

          IF gb_debug THEN
            hr_utility.set_location('After Salary Loop',30);
            hr_utility.set_location('lc_action_period =' ||lc_action_period,30);
          END IF;
           --
         ELSIF (lc_element_set_name = 'BON'  OR  lc_element_set_name = 'SPB')  THEN
           --
          IF gb_debug THEN
            hr_utility.set_location('Inside Bonus Loop',30);
            hr_utility.set_location('lc_action_period =' ||lc_action_period,30);
          END IF;
          --
          ln_bon_wp_premium  := NULL;
          ln_bon_wpf_premium := NULL;
          ln_bon_hi_premium  := NULL;
          ln_bon_ci_premium  := NULL;
          ln_bon_si_premium  := NULL;
          --
        IF lc_element_set_name = 'BON'  THEN
           --
           ln_total_ded_amt := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                               ,p_payroll_period       => lc_action_period
                                                               ,p_balance_name         => 'B_BON_DCT'
                                                               ,p_dimension_name       => '_ASG_RUN'
                                                               ,p_element_set_name     => lc_element_set_name
                                                              );
           lc_tax_rate := tax_rate_value( p_assignment_id    => ln_assignment_id
                                        ,p_payroll_period   => lc_action_period
                                        ,p_element_name  => 'BON_ITX'
                                        ,p_input_name    => 'ITX_RATE');

           ln_bon_ci_premium := pay_run_result_value( p_assignment_id    => ln_assignment_id
                                                    ,p_payroll_period   => lc_action_period
                                                    ,p_element_name  => 'BON_CI_PREM_EE'
                                                    ,p_input_name    => 'Pay Value');

           ln_dependents :=   pay_jp_balance_pkg.get_result_value_number (p_element_name  =>  'BON_ITX'
                                                     ,p_input_value_name    => 'NUM_OF_DEP'
                                                     ,p_assignment_action_id => ln_assignment_action_id
                                                     );
           ln_computed_tax_amount := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_BON_ITX'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                             );
           ln_bon_si_premium := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                         ,p_payroll_period       => lc_action_period
                                                         ,p_balance_name         => 'B_BON_SI_PREM'
                                                         ,p_dimension_name       => '_ASG_RUN'
                                                         ,p_element_set_name     => lc_element_set_name
                                                        );

           ln_bon_total_earnings := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_BON_ERN'
                                                             ,p_dimension_name       => '_ASG_RUN'
                                                             ,p_element_set_name     => lc_element_set_name
                                                           );
           ln_bon_wpf_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                            ,p_payroll_period       => lc_action_period
                                                            ,p_balance_name         => 'B_BON_WPF_PREM'
                                                            ,p_dimension_name       => '_ASG_RUN'
                                                            ,p_element_set_name     => lc_element_set_name
                                                           );
           ln_bon_wp_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                           ,p_payroll_period       => lc_action_period
                                                           ,p_balance_name         => 'B_BON_WP_PREM'
                                                           ,p_dimension_name       => '_ASG_RUN'
                                                            ,p_element_set_name     => lc_element_set_name
                                                          );
           ln_bon_ei_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                           ,p_payroll_period       => lc_action_period
                                                           ,p_balance_name         => 'B_BON_EI_PREM'
                                                           ,p_dimension_name       => '_ASG_RUN'
                                                           ,p_element_set_name     => lc_element_set_name
                                                           );
           ln_bon_hi_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                           ,p_payroll_period       =>  lc_action_period
                                                           ,p_balance_name         => 'B_BON_HI_PREM'
                                                           ,p_dimension_name       => '_ASG_RUN'
                                                           ,p_element_set_name     => lc_element_set_name
                                                           );
           ln_bon_taxable_amount :=  pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_BON_TXBL_ERN_MONEY'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                              );
          ELSE
            --
              ln_total_ded_amt := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                                ,p_payroll_period       => lc_action_period
                                                                ,p_balance_name         => 'B_SPB_DCT'
                                                                ,p_dimension_name       => '_ASG_RUN'
                                                                ,p_element_set_name     => lc_element_set_name
                                                               );
              lc_tax_rate := tax_rate_value( p_assignment_id    => ln_assignment_id
                                        ,p_payroll_period   => lc_action_period
                                        ,p_element_name  => 'SPB_ITX'
                                        ,p_input_name    => 'ITX_RATE');

              ln_dependents :=   pay_jp_balance_pkg.get_result_value_number (p_element_name  =>  'SPB_ITX'
                                                     ,p_input_value_name    => 'NUM_OF_DEP'
                                                     ,p_assignment_action_id => ln_assignment_action_id
                                                     );
             ln_computed_tax_amount := pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_SPB_ITX'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                             );

             ln_bon_total_earnings := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_SPB_ERN'
                                                             ,p_dimension_name       => '_ASG_RUN'
                                                             ,p_element_set_name     => lc_element_set_name
                                                           );
             ln_bon_ei_premium   := pay_bon_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                           ,p_payroll_period       => lc_action_period
                                                           ,p_balance_name         => 'B_SPB_EI_PREM'
                                                           ,p_dimension_name       => '_ASG_RUN'
                                                           ,p_element_set_name     => lc_element_set_name
                                                           );
             ln_bon_taxable_amount :=  pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => lc_action_period
                                                              ,p_balance_name         => 'B_SPB_TXBL_ERN_MONEY'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                              );
            --
          END IF;
          --
          -- Over and Tax Amount
          --
          OPEN  lcu_over_short_tax_id (p_assignment_id        => ln_assignment_id
                                      ,p_payroll_period       => lc_action_period
                               );
          FETCH lcu_over_short_tax_id  INTO ln_ostax_action_id
                                           ,ld_ostax_date;
          CLOSE lcu_over_short_tax_id;
          --
          IF ln_ostax_action_id IS NOT NULL THEN
            --
            OPEN   lcu_over_short_check(p_payroll_period    =>    lc_action_period
                                       ,p_assignment_id     =>    ln_assignment_id
                                       ,p_element_set_name  =>    lc_element_set_name);

            FETCH lcu_over_short_check INTO ln_short_over_check_id;
            CLOSE lcu_over_short_check;
            --
            IF gb_debug THEN
                --
                hr_utility.set_location('ln_short_over_check_id = ' || ln_short_over_check_id,30);
                --
            END IF;
            --
            IF ln_short_over_check_id  IS NOT NULL THEN
              --
              OPEN  lcu_over_short_tax_amount(p_payment_date           => ld_ostax_date
                                           ,p_assignment_action_id   => ln_ostax_action_id
                                           );
              FETCH lcu_over_short_tax_amount INTO ln_short_over_tax;
              CLOSE lcu_over_short_tax_amount;
              --
            END IF;
            --
          END IF;
          --
          ln_non_taxable_amount := NVL(ln_bon_total_earnings,0) - NVL(ln_bon_taxable_amount,0);
          ln_tot_si_premium := NVL(ln_bon_wp_premium,0)  + NVL(ln_bon_hi_premium,0) + NVL(ln_bon_wpf_premium,0) + NVL(ln_bon_ei_premium,0);
          ln_collected_tax_amount := NVL(ln_computed_tax_amount,0) + NVL(ln_short_over_tax,0);
          ln_net_balance := NVL(ln_bon_total_earnings,0)- NVL(ln_total_ded_amt,0);
          ln_tot_afte_si_ded  := NVL(ln_bon_total_earnings,0) - NVL(ln_tot_si_premium,0);
          --
          pay_action_information_api.create_action_information
             (
             p_validate                       => FALSE
            ,p_action_context_id              => ln_org_assign_act_id
            ,p_action_context_type            => 'AAP'
            ,p_action_information_category    => 'JP_WL_BON_PAY_INFO'
            ,p_tax_unit_id                    => NULL
            ,p_jurisdiction_code              => NULL
            ,p_source_id                      => NULL
            ,p_source_text                    => NULL
            ,p_tax_group                      => NULL
            ,p_effective_date                 => p_effective_date
            ,p_assignment_id                  => ln_assignment_id
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_date.date_to_canonical(ld_payment_date)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_bon_taxable_amount)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_non_taxable_amount )
            ,p_action_information5            => fnd_number.number_to_canonical(ln_bon_total_earnings)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_bon_si_premium)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_bon_hi_premium)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_bon_wp_premium)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_bon_wpf_premium)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_bon_ei_premium)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_tot_si_premium)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_tot_afte_si_ded)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_dependents)
            ,p_action_information14           => lc_tax_rate
            ,p_action_information15           => fnd_number.number_to_canonical(ln_computed_tax_amount)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_short_over_tax)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_collected_tax_amount)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_bon_ci_premium)
            ,p_action_information19           => NULL
            ,p_action_information20           => fnd_number.number_to_canonical(ln_total_ded_amt)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_net_balance)
            ,p_action_information22           => lc_element_set_name
            ,p_action_information_id          => ln_bon_action_info_id
            ,p_object_version_number          => ln_bon_obj_version_num
            );
            --
          END IF;  -- End if for Monthly Payroll and Bonus information
             --
          IF gb_debug THEN
            hr_utility.set_location('After Bonus Loop',30);
            hr_utility.set_location('lc_action_period =' ||lc_action_period,30);
          END IF;

          END IF; -- 9031713

          END LOOP;
          --
        CLOSE lcu_payment_action_date ;

        END IF; -- End if for payroll id
        --
        --
        --End Monthly Payroll Deductions and Tax Information
        IF gb_debug THEN
          hr_utility.set_location('After the Payroll Information',30);
        END IF;
        --
        IF gb_debug THEN
          hr_utility.set_location('Before the YEA Information',30);
        END IF;
        --
        OPEN  lcu_yea_info_id(p_payroll_period       => lc_payroll_period_id
                               ,p_assignment_id      => ln_assignment_id
                               );
        FETCH lcu_yea_info_id INTO ln_yea_assignment_action_id
                                  ,ld_yea_effective_date
                                  ,ld_yea_date_earned;
        CLOSE lcu_yea_info_id;

        IF ln_yea_assignment_action_id IS NOT NULL THEN
          --
          -- Added for bug no  8830562
          --
          lc_submission_required_flag:= NULL;
          lt_tax_info                := NULL;
          lc_action_period := TO_CHAR(ld_yea_effective_date,'YYYYMM');
          --
          pay_jp_wic_pkg.get_certificate_info(
			  	 p_assignment_action_id		=> ln_yea_assignment_action_id
				,p_assignment_id			=> ln_assignment_id
				,p_action_sequence		=> NULL
				,p_business_group_id		=> gn_business_group_id
				,p_effective_date		      => ld_yea_effective_date
				,p_date_earned			=> ld_yea_date_earned
				,p_itax_organization_id		=> ln_with_hold_agent
				,p_itax_category			=> lc_itx_type
				,p_itax_yea_category		=> lc_itax_yea_category
				,p_dpnt_ref_type			=> gn_business_group_id
				,p_dpnt_effective_date		=> ld_yea_effective_date
				,p_person_id			=> lr_emp_rec.person_id
				,p_sex				=> lr_emp_rec.sex
				,p_date_of_birth			=> lr_emp_rec.date_of_birth
				,p_leaving_reason		      => lr_emp_rec.leaving_reason
				,p_last_name_kanji		=> lr_emp_rec.last_name_kanji
				,p_last_name_kana		      => lr_emp_rec.last_name_kana
				,p_employment_category		=> lr_emp_rec.employment_category
				,p_certificate_info           => lt_get_certificate_info
                        ,p_submission_required_flag   => lc_submission_required_flag
                        ,p_prev_job_info              => lt_prev_job_info
                        ,p_withholding_tax_info       => lt_tax_info
                        ,p_itw_description		=> l_itw_user_desc_kanji
				,p_itw_descriptions		=> l_itw_descriptions
				,p_wtm_description		=> l_wtm_user_desc
				,p_wtm_descriptions		=> l_wtm_descriptions
				);
          --
          ln_yea_sal_deducion     := lt_get_certificate_info.tax_info.si_prem;
          ln_old_long_non_li_prem := lt_get_certificate_info.long_ai_prem;
          ln_pp_prem              := lt_get_certificate_info.pp_prem;
          ln_mutual_aid_prem      := lt_get_certificate_info.tax_info.mutual_aid_prem;
          ln_npi_prem             := lt_get_certificate_info.national_pens_prem;
          ln_housing_loan_credit  := lt_get_certificate_info.housing_tax_reduction;
          ln_spouse_sp_exempt     := lt_get_certificate_info.spouse_sp_exempt;
          ln_yea_li_prem          := lt_get_certificate_info.li_prem_exempt;
          --
          -- Start Bug No 9063339
          OPEN  lcu_payment_action_date (p_assignment_id          =>   ln_assignment_id
                                         ,p_payroll_start_period   => lc_payroll_start_period
                                         ,p_payroll_end_period     => lc_payroll_period_id
                                        );
           LOOP
           FETCH lcu_payment_action_date INTO ld_payment_date,lc_element_set_name,ln_assignment_action_id;
           EXIT WHEN lcu_payment_action_date%NOTFOUND;
           IF lc_element_set_name IN ('SAL') THEN
             ln_amount:=   pay_sal_balance_result_value (    p_assignment_id        => ln_assignment_id
                                                            ,p_payroll_period       => TO_CHAR(ld_payment_date,'YYYYMM')
                                                            ,p_balance_name         => 'B_SAL_ITX'
                                                             ,p_dimension_name       => '_ASG_RUN'
                                                              );

             lc_nres_flag  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                ,p_input_value_name => 'NRES_FLAG'
                                                                ,p_assignment_id    => ln_assignment_id
                                                                ,p_effective_date   => ld_payment_date
                                                                       );
            IF lc_nres_flag= 'N' THEN
              ln_yea_sal_tax := NVL(ln_yea_sal_tax,0) +NVL(ln_amount,0);
            END IF;

          ELSIF lc_element_set_name IN ('BON','SPB') THEN
              IF lc_element_set_name = 'BON' THEN

               ln_amount:=       pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => TO_CHAR(ld_payment_date,'YYYYMM')
                                                              ,p_balance_name         => 'B_BON_ITX'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                             );
             ELSE
              ln_amount:=       pay_bon_balance_result_value(  p_assignment_id        => ln_assignment_id
                                                              ,p_payroll_period       => TO_CHAR(ld_payment_date,'YYYYMM')
                                                              ,p_balance_name         => 'B_SPB_ITX'
                                                              ,p_dimension_name       => '_ASG_RUN'
                                                              ,p_element_set_name     => lc_element_set_name
                                                             );

             END IF;

             lc_nres_flag  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_ITX_INFO'
                                                                ,p_input_value_name => 'NRES_FLAG'
                                                                ,p_assignment_id    => ln_assignment_id
                                                                ,p_effective_date   => ld_payment_date
                                                                       );
             IF lc_nres_flag = 'N' THEN
              ln_yea_bon_tax := NVL(ln_yea_bon_tax,0) +NVL(ln_amount,0);
            END IF;
           END IF;
          END LOOP;
          CLOSE lcu_payment_action_date ;  -- End Bug No 9063339
          --
          OPEN  lcu_tot_dep_exem(p_assignment_id      => ln_assignment_id
                                ,p_subject_yyyymm     => gr_parameters.subject_yyyymm
                                ,p_assignment_action_id => ln_yea_assignment_action_id  -- BUG 9014185
                               );
          FETCH lcu_tot_dep_exem INTO ln_total_exempt;
          CLOSE lcu_tot_dep_exem;
          --
          ln_yea_sal       :=   pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                          ,p_payroll_period       => lc_action_period
                                                          ,p_balance_name         => 'B_SAL_TXBL_ERN_MONEY'
                                                          ,p_dimension_name       => '_ASG_YTD'
                                                         );

          ln_yea_bonus     :=   pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                          ,p_payroll_period       => lc_action_period
                                                          ,p_balance_name         => 'B_BON_ERN'
                                                          ,p_dimension_name       => '_ASG_RUN'
                                                         );

          ln_yea_tot_taxable_amt := pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                          ,p_payroll_period       => lc_action_period
                                                          ,p_balance_name         => 'B_YEA_TXBL_ERN_MONEY'
                                                          ,p_dimension_name       =>  '_ASG_YTD'                       --Bug No 8830562
                                                         );


          ln_yea_sal_with_ded  :=       pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                                  ,p_payroll_period       => lc_action_period
                                                                  ,p_balance_name         => 'B_YEA_AMT_AFTER_EMP_INCOME_DCT'  --Bug No 8830562
                                                                  ,p_dimension_name       => '_ASG_RUN'
                                                                  );
          ln_yea_annual_tax               := pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id         -- Bug No 8910016
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_NET_ANNUAL_TAX'
                                                             ,p_dimension_name       => '_ASG_RUN'
                                                             );

          ln_yea_over_short_tax           :=  pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_TAX_PAY'
                                                             ,p_dimension_name       =>  '_ASG_YTD'
                                                             );

          ln_yea_tot_deduction_amt          :=  pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_INCOME_EXM'
                                                             ,p_dimension_name       =>  '_ASG_RUN'
                                                             );

          ln_yea_net_asseble_amt            :=  pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_NET_TXBL_INCOME'
                                                             ,p_dimension_name       =>  '_ASG_RUN'
                                                             );
          ln_yea_comptued_tax_amount            :=  pay_yea_balance_result_value(  p_assignment_id  => ln_assignment_id
                                                             ,p_payroll_period       => lc_action_period
                                                             ,p_balance_name         => 'B_YEA_ANNUAL_TAX'
                                                             ,p_dimension_name       =>   '_ASG_RUN'
                                                             );
           --
          ln_basis_exmpt := pay_jp_balance_pkg.get_result_value_number (
                                                 p_element_name  =>  'YEA_DEP_EXM_RSLT'
                                                ,p_input_value_name    => 'BASIC_EXM'
                                                ,p_assignment_action_id => ln_yea_assignment_action_id
                                               );
          ln_dependent_exmpt := pay_jp_balance_pkg.get_result_value_number (
                                                 p_element_name  =>  'YEA_DEP_EXM_RSLT'
                                                ,p_input_value_name    => 'GEN_DEP_EXM'
                                                ,p_assignment_action_id => ln_yea_assignment_action_id
                                               );
          ln_gen_spouse_exmpt := pay_jp_balance_pkg.get_result_value_number (
                                                      p_element_name  =>  'YEA_DEP_EXM_RSLT'
                                                     ,p_input_value_name    =>  'GEN_SPOUSE_EXM'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_gen_disable_exmpt := pay_jp_balance_pkg.get_result_value_number (
                                                      p_element_name  =>  'YEA_DEP_EXM_RSLT'
                                                     ,p_input_value_name    => 'GEN_DISABLED_EXM'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_yea_si_prem := pay_jp_balance_pkg.get_result_value_number (p_element_name  => 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT'
                                                     ,p_input_value_name    => 'DECLARE_SI_PREM'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_yea_ei_prem := pay_jp_balance_pkg.get_result_value_number ( p_element_name  => 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT'
                                                     ,p_input_value_name    => 'NONLIFE_INS_PREM_EXM'
                                                    ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_yea_spouse_income:= pay_jp_balance_pkg.get_result_value_number (p_element_name  => 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT'
                                                     ,p_input_value_name    => 'SPOUSE_INCOME'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_yea_samll_comp_prem  := pay_jp_balance_pkg.get_result_value_number ( p_element_name  => 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT'
                                                     ,p_input_value_name    => 'DECLARE_SMALL_COMPANY_MUTUAL_AID_PREM'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );

          ln_adj_emp_income        := pay_jp_balance_pkg.get_result_value_number (
                                                        p_element_name  => 'YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT'
                                                       ,p_input_value_name    => 'ADJ_EMP_INCOME'
                                                       ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          ln_adj_emp_tax          := pay_jp_balance_pkg.get_result_value_number (
                                                     p_element_name  => 'YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT'
                                                     ,p_input_value_name    => 'ADJ_ITX'
                                                     ,p_assignment_action_id => ln_yea_assignment_action_id
                                                     );
          --
          ln_yea_sal_deducion     := NVL(ln_yea_sal_deducion,0)  - (NVL(ln_yea_samll_comp_prem,0)+NVL(ln_yea_si_prem,0));
          ln_yea_tot_taxable_amt  := NVL(ln_yea_tot_taxable_amt,0) + NVL(ln_prev_job_income,0)+NVL(ln_adj_emp_income,0);
          ln_mutual_aid_prem      := NVL(ln_mutual_aid_prem,0) - NVL(ln_yea_samll_comp_prem,0);
          ln_yea_sal              := NVL(ln_yea_sal,0) + NVL(ln_prev_job_income,0)+NVL(ln_adj_emp_income,0);
          ln_yea_net_asseble_amt  := TRUNC(ln_yea_net_asseble_amt,-3);
          ln_yea_annual_tax       := TRUNC(ln_yea_annual_tax,-2);
          ln_yea_comptued_tax_amount := TRUNC(ln_yea_comptued_tax_amount);
          ln_yea_sal_tax          := NVL(ln_yea_sal_tax,0) + NVL(ln_adj_emp_tax,0)+ NVL(ln_prev_job_itax,0);
          --
          IF gb_debug THEN
             hr_utility.set_location('YEA Person_id = ' ||lr_emp_rec.person_id,30);
          END IF;
          --
          pay_action_information_api.create_action_information
             (
             p_validate                       => FALSE
            ,p_action_context_id              => ln_org_assign_act_id
            ,p_action_context_type            => 'AAP'
            ,p_action_information_category    => 'JP_WL_YEA_INFO'
            ,p_tax_unit_id                    => NULL
            ,p_jurisdiction_code              => NULL
            ,p_source_id                      => NULL
            ,p_source_text                    => NULL
            ,p_tax_group                      => NULL
            ,p_effective_date                 => p_effective_date
            ,p_assignment_id                  => ln_assignment_id
            ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
            ,p_action_information2            => fnd_number.number_to_canonical(ln_yea_sal)
            ,p_action_information3            => fnd_number.number_to_canonical(ln_yea_bonus)
            ,p_action_information4            => fnd_number.number_to_canonical(ln_yea_tot_taxable_amt)
            ,p_action_information5            => fnd_number.number_to_canonical(ln_yea_sal_tax)
            ,p_action_information6            => fnd_number.number_to_canonical(ln_yea_bon_tax)
            ,p_action_information7            => fnd_number.number_to_canonical(ln_yea_sal_with_ded)
            ,p_action_information8            => fnd_number.number_to_canonical(ln_yea_sal_deducion)
            ,p_action_information9            => fnd_number.number_to_canonical(ln_yea_si_prem)
            ,p_action_information10           => fnd_number.number_to_canonical(ln_yea_samll_comp_prem)
            ,p_action_information11           => fnd_number.number_to_canonical(ln_yea_li_prem)
            ,p_action_information12           => fnd_number.number_to_canonical(ln_yea_ei_prem)
            ,p_action_information13           => fnd_number.number_to_canonical(ln_spouse_sp_exempt)
            ,p_action_information14           => fnd_number.number_to_canonical(ln_yea_spouse_income)
            ,p_action_information15           => fnd_number.number_to_canonical(ln_pp_prem)
            ,p_action_information16           => fnd_number.number_to_canonical(ln_old_long_non_li_prem)
            ,p_action_information17           => fnd_number.number_to_canonical(ln_mutual_aid_prem)
            ,p_action_information18           => fnd_number.number_to_canonical(ln_npi_prem)
            ,p_action_information19           => fnd_number.number_to_canonical(ln_housing_loan_credit)
            ,p_action_information20           => fnd_number.number_to_canonical(ln_yea_annual_tax)
            ,p_action_information21           => fnd_number.number_to_canonical(ln_yea_over_short_tax)
            ,p_action_information22           => fnd_number.number_to_canonical(ln_gen_spouse_exmpt)
            ,p_action_information23           => fnd_number.number_to_canonical(ln_dependent_exmpt)
            ,p_action_information24           => fnd_number.number_to_canonical(ln_basis_exmpt)
            ,p_action_information25           => fnd_number.number_to_canonical(ln_gen_disable_exmpt)
            ,p_action_information26           => fnd_number.number_to_canonical(ln_total_exempt)
            ,p_action_information27           => fnd_number.number_to_canonical(ln_yea_tot_deduction_amt)
            ,p_action_information28           => fnd_number.number_to_canonical(ln_yea_net_asseble_amt)
            ,p_action_information29           => fnd_number.number_to_canonical(ln_yea_comptued_tax_amount)
            ,p_action_information_id          => ln_yea_action_info_id
            ,p_object_version_number          => ln_yea_obj_version_num
            );
           --
        END IF;
        --
        IF gb_debug THEN
          hr_utility.set_location('After the YEA Information',30);
        END IF;
        --
        -- Dependents Information
        --
        IF gb_debug THEN
          hr_utility.set_location('Before the Dependents Information context',30);
        END IF;
        --
        IF lc_itx_type LIKE '%KOU%' THEN
           lc_existence_declaration := 'Y';
        END IF;
        --
        CASE
          WHEN  lC_spouse_type = '0' THEN lC_spouse_exists := 'N';
          WHEN  lC_spouse_type = '1' THEN lC_spouse_exists := 'Y';
          WHEN  lC_spouse_type = '2' THEN lC_general_qualified_spouse :='Y';
                                          lC_spouse_exists := 'Y';
          WHEN  lC_spouse_type = '3' THEN lC_aged_spouse := 'Y';
                                     lC_spouse_exists := 'Y';
          ELSE  lC_spouse_exists := 'N';
        END CASE;
        --
        IF lc_aged_employee = '1' THEN
           lc_aged_employee_flag := 'Y';
        END IF;
        --
        lc_spouse_exists_meaning      :=  proc_lookup_meaning('YES_NO',lC_spouse_exists);
        lC_general_qual_meaning       :=  proc_lookup_meaning('YES_NO',lC_general_qualified_spouse );
        lC_aged_spouse_meaning        :=  proc_lookup_meaning('YES_NO',lC_aged_spouse );
        lc_existence_meaning          :=  proc_lookup_meaning('YES_NO',lc_existence_declaration);
        lc_widow_type_meaning         :=  proc_lookup_meaning('JP_WIDOW_EE_STATUS',lc_widow_type);
        lc_working_student_meaning    :=  proc_lookup_meaning('JP_WORKING_STUDENT_EE_STATUS',lc_working_student);
        lc_disable_type_meaning       :=  proc_lookup_meaning('JP_DISABLED_EE_STATUS',lc_disable_type);
        --
        IF lc_itx_type LIKE '%OTSU%' THEN
          --
          ln_otsu_depts := ln_general_dependents;
          --
        END IF;
        --
       pay_action_information_api.create_action_information
       (
        p_validate                      => FALSE
        ,p_action_context_id             => ln_org_assign_act_id
        ,p_action_context_type            => 'AAP'
        ,p_action_information_category    => 'JP_WL_DECL_DEP_INFO'
        ,p_tax_unit_id                    => NULL
        ,p_jurisdiction_code              => NULL
        ,p_source_id                      => NULL
        ,p_source_text                    => NULL
        ,p_tax_group                      => NULL
        ,p_effective_date                 => p_effective_date
        ,p_assignment_id                  => ln_assignment_id
        ,p_action_information1            => fnd_number.number_to_canonical(lr_emp_rec.person_id)
        ,p_action_information2            => lc_existence_meaning
        ,p_action_information3            => lc_spouse_exists_meaning
        ,p_action_information4            => lC_general_qual_meaning
        ,p_action_information5            => lC_aged_spouse_meaning
        ,p_action_information6            => fnd_number.number_to_canonical(ln_general_dependents)
        ,p_action_information7            => fnd_number.number_to_canonical(ln_specific_dependents)
        ,p_action_information8            => fnd_number.number_to_canonical(ln_elder_parents)
        ,p_action_information9            => fnd_number.number_to_canonical(ln_elder_dependents)
        ,p_action_information10           => fnd_number.number_to_canonical(ln_generally_disabled)
        ,p_action_information11           => fnd_number.number_to_canonical(ln_specially_dependents)
        ,p_action_information12           => fnd_number.number_to_canonical(ln_specially_dependents_lt)
        ,p_action_information13           => lc_disable_type_meaning
        ,p_action_information14           => lc_widow_type_meaning
        ,p_action_information15           => lc_working_student_meaning
        ,p_action_information16           => ln_otsu_depts
        ,p_action_information_id          => ln_action_info_id
        ,p_object_version_number          => ln_obj_version_num
        );
        --
        -- End Dependents Information
        --
        IF gb_debug THEN
          hr_utility.set_location('After the Dependents Information context',30);
        END IF;

        IF lr_proc_name.proc_name IS NOT NULL THEN
          --
          IF gb_debug THEN
            hr_utility.set_location('Dynamic PL/SQL block invokes subprogram parameters:',30);
          END IF;
          --
          lc_plsql_block := '(p_assignment_id  => :assignment_id
                           ,p_effective_date => :eff_date
                           ,x_info1          => :1
                           ,x_info2          => :2
                           ,x_info3          => :3
                           ,x_info4          => :4
                           ,x_info5          => :5
                           ,x_info6          => :6
                           ,x_info7          => :7
                           ,x_info8          => :8
                           ,x_info9          => :9
                           ,x_info10         => :10
                           ,x_info11         => :11
                           ,x_info12         => :12
                           ,x_info13         => :13
                           ,x_info14         => :14
                           ,x_info15         => :15
                           ,x_info16         => :16
                           ,x_info17         => :17
                           ,x_info18         => :18
                           ,x_info19         => :19
                           ,x_info20         => :20
                           ,x_info21         => :21
                           ,x_info22         => :22
                           ,x_info23         => :23
                           ,x_info24         => :24
                           ,x_info25         => :25
                           ,x_info26         => :26
                           ,x_info27         => :27
                           ,x_info28         => :28
                           ,x_info29         => :29
                           ,x_info30         => :30
                          );';
          --
          IF gb_debug THEN
            hr_utility.set_location('After the YEA Information',30);
          END IF;
          --
          IF gb_debug THEN
            hr_utility.set_location('Calling Extra info plug in procedure using dynamic SQL',30);
          END IF;
          --
          EXECUTE IMMEDIATE 'BEGIN '||lr_proc_name.proc_name||lc_plsql_block||' END;'
          USING   IN  ln_assignment_id
              , IN  p_effective_date
              , OUT lr_extra_info.extra_info1
              , OUT lr_extra_info.extra_info2
              , OUT lr_extra_info.extra_info3
              , OUT lr_extra_info.extra_info4
              , OUT lr_extra_info.extra_info5
              , OUT lr_extra_info.extra_info6
              , OUT lr_extra_info.extra_info7
              , OUT lr_extra_info.extra_info8
              , OUT lr_extra_info.extra_info9
              , OUT lr_extra_info.extra_info10
              , OUT lr_extra_info.extra_info11
              , OUT lr_extra_info.extra_info12
              , OUT lr_extra_info.extra_info13
              , OUT lr_extra_info.extra_info14
              , OUT lr_extra_info.extra_info15
              , OUT lr_extra_info.extra_info16
              , OUT lr_extra_info.extra_info17
              , OUT lr_extra_info.extra_info18
              , OUT lr_extra_info.extra_info19
              , OUT lr_extra_info.extra_info20
              , OUT lr_extra_info.extra_info21
              , OUT lr_extra_info.extra_info22
              , OUT lr_extra_info.extra_info23
              , OUT lr_extra_info.extra_info24
              , OUT lr_extra_info.extra_info25
              , OUT lr_extra_info.extra_info26
              , OUT lr_extra_info.extra_info27
              , OUT lr_extra_info.extra_info28
              , OUT lr_extra_info.extra_info29
              , OUT lr_extra_info.extra_info30;
          --
          IF gb_debug THEN
            hr_utility.set_location('Archiving Employee Extra Information',30);
          END IF;
          --
          pay_action_information_api.create_action_information
          ( p_action_information_id        => ln_action_info_id
          , p_action_context_id            => ln_org_assign_act_id
          , p_action_context_type          => 'AAP'
          , p_object_version_number        => ln_obj_version_num
          , p_effective_date               => p_effective_date
          , p_assignment_id                => ln_assignment_id
          , p_source_id                    => NULL
          , p_source_text                  => NULL
          , p_action_information_category  => 'JP_WL_EXTRA_INFO'
          , p_action_information1          => lr_extra_info.extra_info1
          , p_action_information2          => lr_extra_info.extra_info2
          , p_action_information3          => lr_extra_info.extra_info3
          , p_action_information4          => lr_extra_info.extra_info4
          , p_action_information5          => lr_extra_info.extra_info5
          , p_action_information6          => lr_extra_info.extra_info6
          , p_action_information7          => lr_extra_info.extra_info7
          , p_action_information8          => lr_extra_info.extra_info8
          , p_action_information9          => lr_extra_info.extra_info9
          , p_action_information10         => lr_extra_info.extra_info10
          , p_action_information11         => lr_extra_info.extra_info11
          , p_action_information12         => lr_extra_info.extra_info12
          , p_action_information13         => lr_extra_info.extra_info13
          , p_action_information14         => lr_extra_info.extra_info14
          , p_action_information15         => lr_extra_info.extra_info15
          , p_action_information16         => lr_extra_info.extra_info16
          , p_action_information17         => lr_extra_info.extra_info17
          , p_action_information18         => lr_extra_info.extra_info18
          , p_action_information19         => lr_extra_info.extra_info19
          , p_action_information20         => lr_extra_info.extra_info20
          , p_action_information21         => lr_extra_info.extra_info21
          , p_action_information22         => lr_extra_info.extra_info22
          , p_action_information23         => lr_extra_info.extra_info23
          , p_action_information24         => lr_extra_info.extra_info24
          , p_action_information25         => lr_extra_info.extra_info25
          , p_action_information26         => lr_extra_info.extra_info26
          , p_action_information27         => lr_extra_info.extra_info27
          , p_action_information28         => lr_extra_info.extra_info28
          , p_action_information29         => lr_extra_info.extra_info29
          , p_action_information30         => lr_extra_info.extra_info30
          );
        END IF;
        --
    END LOOP;
    --
    --
    IF gb_debug THEN
      hr_utility.set_location('Before Update Statement '||ln_org_assign_act_id,30);
    END IF;
    --
    UPDATE pay_assignment_actions
    SET action_status ='C'
    WHERE assignment_action_id = ln_org_assign_act_id;  -- Bug 8931350
    --
    END IF;
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1);
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    --
    UPDATE pay_assignment_actions
    SET action_status ='E'
    WHERE assignment_action_id = ln_org_assign_act_id;  -- Bug 8931350
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END ARCHIVE_CODE;
  --
PROCEDURE deinitialize_code(p_payroll_action_id IN NUMBER)
--************************************************************************
  --   PROCEDURE
  --   deinitialize_code
  --
  --   DESCRIPTION
  --   This package is used to remove temporary action codes
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_payroll_action_id       IN       This parameter passes Assignment Action Id
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************/

IS
  --
  CURSOR lcu_assacts IS
  SELECT        PAA.assignment_action_id
  FROM  pay_assignment_actions  PAA
  WHERE PAA.payroll_action_id = p_payroll_action_id
  AND   PAA.action_status = 'C'
  AND   NOT EXISTS(
                        SELECT NULL
                        FROM    pay_action_information  PAI
                        WHERE   pai.action_context_id = paa.assignment_action_id
                        AND     pai.action_context_type = 'AAP');
--
  CURSOR lcu_get_pact_info ( p_subject_yyyymm VARCHAR2
                            )
  IS
  SELECT fnd_number.canonical_to_number(PCI.action_information3)
  FROM   pay_action_information        PCI
  WHERE  PCI.action_information_category = 'JP_WL_PACT'
  AND   TO_CHAR(TO_DATE(PCI.action_information1,'YYYYMM'),'YYYY') =  TO_CHAR(TO_DATE(p_subject_yyyymm,'YYYYMM'),'YYYY')
  AND   PCI.action_information8         = 'Y'
  AND   PCI.action_context_type  = 'PA';

--
lc_proc                 CONSTANT VARCHAR2(61) := gc_package || 'deinitialise_code';
lc_master_flag          VARCHAR2(1);
--
ln_master_pact_id       NUMBER;
ln_action_info_id       pay_action_information.action_information_id%TYPE;
ln_obj_version_num      pay_action_information.object_version_number%TYPE;
--
BEGIN
  --
    gb_debug := hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
           hr_utility.set_location('Entering: ' || lc_proc, 10);
    END IF;
    --
    --
    -- initialization_code to to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    --
    initialize(p_payroll_action_id);

    --today

    OPEN  lcu_get_pact_info(gr_parameters.subject_yyyymm);
    FETCH lcu_get_pact_info INTO ln_master_pact_id;
    --
    IF ln_master_pact_id IS NULL THEN
       --
       lc_master_flag := 'Y';
       ln_master_pact_id  :=  p_payroll_action_id;
       --
     ELSE
       --
       lc_master_flag := 'N';
       --
    END IF;
     --
    pay_action_information_api.create_action_information
    (
        p_validate                       => FALSE
       ,p_action_context_id              => p_payroll_action_id
       ,p_action_context_type            => 'PA'
       ,p_action_information_category    => 'JP_WL_PACT'
       ,p_tax_unit_id                    => NULL
       ,p_jurisdiction_code              => NULL
       ,p_source_id                      => NULL
       ,p_source_text                    => NULL
       ,p_tax_group                      => NULL
       ,p_effective_date                 => gr_parameters.effective_date
       ,p_action_information1            => gr_parameters.subject_yyyymm
       ,p_action_information2            => gr_parameters.archive_option
       ,p_action_information3            => fnd_number.number_to_canonical(ln_master_pact_id)
       ,p_action_information4            => fnd_number.number_to_canonical(gr_parameters.payroll_id)
       ,p_action_information5            => fnd_number.number_to_canonical(gr_parameters.withholding_agent_id)
       ,p_action_information6            => fnd_number.number_to_canonical(gr_parameters.assignment_set_id)
       ,p_action_information7            => 'P'
       ,p_action_information8            => lc_master_flag
       ,p_action_information_id          => ln_action_info_id
       ,p_object_version_number          => ln_obj_version_num
     );
    --today
    --
    FOR l_rec IN lcu_assacts LOOP
                py_rollback_pkg.rollback_ass_action(l_rec.assignment_action_id);
    END LOOP;
    --

    IF gb_debug THEN
           hr_utility.set_location('Leaving: ' || lc_proc, 10);
    END IF;

    --
END deinitialize_code;
--
END pay_jp_wl_arch_pkg;

/
