--------------------------------------------------------
--  DDL for Package Body PER_JP_EMPDET_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_EMPDET_ARCHIVE_PKG" 
-- $Header: pejpearc.pkb 120.4.12010000.29 2009/09/09 11:54:18 mpothala noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pejpearc.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of per_jp_empdet_archive_pkg
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   08-Jun-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * DATE        AUTHOR(S)  VERSION             BUG NO    DESCRIPTION
-- * -----------+---------+-------------------+----------+--------------------------------------------------------------------------------------
-- * 19-MAR-2009 SPATTEM    120.0.12010000.1    8558615   Creation
-- * 16-JUN-2009 MDARBHA    120.4.12010000.11   8558615   Changed as per review Comments
-- * 18-JUN-2009 SPATTEM    120.4.12010000.13   8574160   Removed the usage of hr_locations table
--                                                        Changed lcu_assignment_details, lcu_chk_terminate cursors
--                                                        Included Employee Contacts Information
-- * 23-JUN-2009 SPATTEM    120.4.12010000.14   8623733   Included Hierarchy for business group
--*  30-JUN-2009 MDARBHA    120.4.12010000.15   8644256   Added a date conversion in procedure archive_code
--*  12-JUL-2009 MDARBHA    120.4.12010000.16   8643285   Removed a date conversion in procedure archive_code for cursor 'lcu_education_details'
--*  13-JUL-2009 MDARBHA    120.4.12010000.17   8679904   Changed action creation to consider future terminated employees.
--*  20-JUL-2009 MDARBHA    120.4.12010000.18   8686617   Changed Job history function
--*                                            ,8683975   changed archive code to add date condition for employees.
--*  20-JUL-2009 MDARBHA    120.4.12010000.20   8721997   Changed Action Creation to consider rehired employees.
--*  31-JUL-2009 MDARBHA    120.4.12010000.21   8721997   Changed Changed Action Creation to consider a scenario for rehired employees
--*  31-JUL-2009 MDARBHA    120.4.12010000.22   8740684   Changed Changed Archive Code assignments cursor.
--*  31-JUL-2009 MDARBHA    120.4.12010000.23   8740684   Changed Changed Archive Code assignments cursor.
--*  04-AUG-2009 MDARBHA    120.4.12010000.24   8765197   Changed Changed Archive Code previous job cursor
--*  13-AUG-2009 RDARASI    120.4.12010000.25   8774235   Changed get_job_history Function.
--*  14-Aug-2009 MPOTHALA   120.4.12010000.26	8766629   Changed  Termination Allowance Query
--*  28-Aug-2009 MPOTHALA   120.4.12010000.26	8766629   Changed  Termination Allowance Query
--*  28-Aug-2009 MPOTHALA   120.4.12010000.27	8766629   Changed  Termination Allowance Query
--*  28-Aug-2009 MPOTHALA   120.4.12010000.28	8766629   Changed  Termination Allowance Query
--*  09-Sep-2009 MPOTHALA   120.4.12010000.29	8838517   Add condition to fetch Termination Allowance
-- *******************************************************************************************************************************************
AS
--
  --Declaration of constant global variables
  gc_package           CONSTANT VARCHAR2(60) := 'per_jp_empdet_archive_pkg.';  -- Global to store package name for tracing.
--
  --Declaration of global variables
  gn_payroll_action_id        pay_payroll_actions.payroll_action_id%TYPE;
  gn_business_group_id        hr_all_organization_units.organization_id%TYPE;
  gb_debug                    BOOLEAN;
  gd_end_date                 DATE;
  gd_start_date               DATE;
  gc_exception                EXCEPTION;
  --
  PROCEDURE range_code ( p_payroll_action_id  IN         pay_payroll_actions.payroll_action_id%TYPE
                        ,p_sql                OUT NOCOPY VARCHAR2
                       )
  --************************************************************************
  -- PROCEDURE
  --   range_code
  --
  -- DESCRIPTION
  --   This procedure returns a sql string to select a range
  --   of assignments eligible for archival
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_payroll_action_id         IN      This parameter passes Payroll Action Id.
  -- p_sql                       OUT     This parameter retunrs SQL Query.
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
--
  lc_procedure                VARCHAR2(200);
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled;
--
    IF gb_debug THEN
     lc_procedure := gc_package||'range_code';
     hr_utility.set_location('Entering '||lc_procedure,1);
    END IF ;
--
    -- Archive the payroll action level data and EIT defintions.
    -- sql string to SELECT a range of assignments eligible for archival.
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
  END range_code;
--
  PROCEDURE initialize ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE )
  --************************************************************************
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
  --  initialization_code
  --************************************************************************
  IS
--
  CURSOR lcr_params(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
  IS
  SELECT pay_core_utils.get_parameter('BG',legislative_parameters)                            business_group_id
        ,pay_core_utils.get_parameter('ORG',legislative_parameters)                           organization_id
        ,pay_core_utils.get_parameter('LOC',legislative_parameters)                           location_id
        ,pay_core_utils.get_parameter('ASSSET',legislative_parameters)                        assignment_set_id
        ,TO_DATE(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   effective_date
        ,NVL(pay_core_utils.get_parameter('IOH',legislative_parameters),'Y')                  include_org_hierarchy
        ,pay_core_utils.get_parameter('ITE',legislative_parameters)                           include_term_emp
        ,TO_DATE(pay_core_utils.get_parameter('TEDF',legislative_parameters),'YYYY/MM/DD')    term_date_from
        ,TO_DATE(pay_core_utils.get_parameter('TEDT',legislative_parameters),'YYYY/MM/DD')    term_date_to
  FROM  pay_payroll_actions PPA
  WHERE PPA.payroll_action_id  =  p_payroll_action_id;
--
  -- Local Variables
  lc_procedure               VARCHAR2(200);
--
  BEGIN
--
    gb_debug :=hr_utility.debug_enabled ;
    IF gb_debug THEN
      lc_procedure := gc_package||'initialize';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
--
    -- initialization_code to to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    -- Fetch the parameters passed by user into global variable.
    OPEN lcr_params(p_payroll_action_id);
    FETCH lcr_params into gr_parameters;
    CLOSE lcr_params;
--
    IF gb_debug THEN
      hr_utility.set_location('p_payroll_action_id.........       = ' || p_payroll_action_id,30);
      hr_utility.set_location('gr_parameters.org_id............. .= ' || gr_parameters.organization_id,30);
      hr_utility.set_location('gr_parameters.business_group_id....= ' || gr_parameters.business_group_id,30);
      hr_utility.set_location('gr_parameters.effective_date.......= ' || gr_parameters.effective_date,30);
      hr_utility.set_location('gr_parameters.location_id..........= ' || gr_parameters.location_id,30);
      hr_utility.set_location('gr_parameters.include_org_hierarchy= ' || gr_parameters.include_org_hierarchy,30);
      hr_utility.set_location('gr_parameters.assignment_set_id....= ' || gr_parameters.assignment_set_id,30);
      hr_utility.set_location('gr_parameters.include_term_emp  . .= ' || gr_parameters.include_term_emp,30);
      hr_utility.set_location('gr_parameters.term_date_from    . .= ' || gr_parameters.term_date_from,30);
      hr_utility.set_location('gr_parameters.term_date_to.    .. .= ' || gr_parameters.term_date_to,30);
    END IF;
--
    gn_business_group_id := gr_parameters.business_group_id ;
    gn_payroll_action_id := p_payroll_action_id;
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
  WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in '||lc_procedure,999999);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    RAISE  gc_exception;
  END initialize;
--
  PROCEDURE initialization_code ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE )
  --************************************************************************
  -- PROCEDURE
  --   initialization_code
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
  --   None
  --************************************************************************
  IS
  -- Local Variables
  lc_procedure               VARCHAR2(200);
--
  BEGIN
  --
    gb_debug :=hr_utility.debug_enabled ;
    IF gb_debug THEN
      lc_procedure := gc_package||'initialization_code';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
--
    -- initialization_code to to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    -- Fetch the parameters passed by user into global variable
    -- initialize procedure
--
    initialize(p_payroll_action_id);
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
  END initialization_code;
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
  PROCEDURE assignment_action_code ( p_payroll_action_id IN pay_payroll_actions.payroll_action_id%type
                                    ,p_start_person      IN per_all_people_f.person_id%type
                                    ,p_end_person        IN per_all_people_f.person_id%type
                                    ,p_chunk             IN NUMBER
                                   )
  --************************************************************************
  -- PROCEDURE
  --   assignment_action_code
  --
  -- DESCRIPTION
  --   This procedure further restricts the assignment_id's returned by range_code
  --   This procedure gets the parameters given by user and restricts
  --   the assignments to be archived
  --   it then calls hr_nonrun.insact to create an assignment action id
  --   it then archives Payroll Run assignment action id  details
  --   for each assignment.
  --   There are different cursors for choosing the assignment ids.
  --   Depending on the parameters passed,the appropriate cursor is used.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  -- p_start_person             IN       This parameter passes Start Person Id
  -- p_end_person               IN       This parameter passes End Person Id
  -- p_chunk                    OUT      This parameter passes Chunk Number
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   PYUGEN process
  --************************************************************************
  IS
--
  CURSOR lcu_emp_assignment_det_r ( p_business_group_id  per_assignments_f.business_group_id%TYPE
                                   ,p_organization_id    per_assignments_f.organization_id%TYPE
                                   ,p_location_id        per_assignments_f.location_id%TYPE
                                   ,p_terminate_flag     VARCHAR2
                                   ,p_effective_date     DATE
                                   ,p_start_date         DATE
                                   ,p_end_date           DATE
                                  )
  IS
  SELECT PAF.assignment_id
  FROM   per_people_f             PPF
        ,per_assignments_f        PAF
        ,per_periods_of_service   PPS
        ,pay_population_ranges    PPR
        ,pay_payroll_actions      PPA
  WHERE PPF.person_id              = PAF.person_id
  AND   PPF.person_id              = PPS.person_id
  AND   PPA.payroll_action_id      = p_payroll_action_id
  AND   PPA.payroll_action_id      = PPR.payroll_action_id
  AND   PPR.chunk_number           = p_chunk
  AND   PPR.person_id              = PPF.person_id
  AND   PAF.business_group_id      = p_business_group_id
  AND   PPA.business_group_id      = PAF.business_group_id
  AND   PAF.organization_id        = NVL(p_organization_id,PAF.organization_id)
  AND   NVL(PAF.location_id,0)     = NVL(p_location_id,NVL( PAF.location_id,0))
  AND   PPS.period_of_service_id   = PAF.period_of_service_id
  AND   NVL(TRUNC(PPS.actual_termination_date),p_effective_date) BETWEEN PPF.effective_start_date
                                                              AND PPF.effective_end_date
  AND   NVL(TRUNC(PPS.actual_termination_date),p_effective_date) BETWEEN PAF.effective_start_date
                                                              AND PAF.effective_end_date
 AND   ((   NVL(p_terminate_flag,'N')        = 'Y'
          AND( (PPS.actual_termination_date IS NULL AND p_effective_date > = PPS.DATE_START)
            OR (PPS.actual_termination_date > = p_effective_date        AND p_effective_date > = PPS.DATE_START )
             OR TRUNC(PPS.actual_termination_date)  BETWEEN p_start_date
                                                        AND p_end_date
             )
          )
         OR
          (  NVL(p_terminate_flag,'N')                    = 'N'
         AND ((PPS.actual_termination_date IS NULL AND p_effective_date > = PPS.DATE_START)
                OR (PPS.actual_termination_date > = p_effective_date    AND p_effective_date > = PPS.DATE_START ))
          )
         )
   AND   PAF.primary_flag           ='Y'
  ORDER BY PAF.assignment_id;
--
  CURSOR lcu_emp_assignment_det ( p_start_person_id    per_all_people_f.person_id%TYPE
                                 ,p_end_person_id      per_all_people_f.person_id%TYPE
                                 ,p_business_group_id  per_assignments_f.business_group_id%TYPE
                                 ,p_organization_id    per_assignments_f.organization_id%TYPE
                                 ,p_location_id        per_assignments_f.location_id%TYPE
                                 ,p_terminate_flag     VARCHAR2
                                 ,p_effective_date     DATE
                                 ,p_start_date         DATE
                                 ,p_end_date           DATE
                                )
  IS
  SELECT PAF.assignment_id
  FROM   per_people_f             PPF
        ,per_assignments_f        PAF
        ,per_periods_of_service   PPS
  WHERE PPF.person_id              = PAF.person_id
  AND   PPF.person_id              = PPS.person_id
  AND   PAF.business_group_id      = p_business_group_id
  AND   PAF.organization_id        = NVL(p_organization_id,PAF.organization_id)
  AND   NVL(PAF.location_id,0)     = NVL(p_location_id,NVL( PAF.location_id,0))
  AND   PPF.person_id        BETWEEN p_start_person_id
                                 AND p_end_person_id
  AND   PPS.period_of_service_id   = PAF.period_of_service_id
  AND   NVL(TRUNC(PPS.actual_termination_date),p_effective_date) BETWEEN PPF.effective_start_date
                                                              AND PPF.effective_end_date
  AND   NVL(TRUNC(PPS.actual_termination_date),p_effective_date) BETWEEN PAF.effective_start_date
                                                              AND PAF.effective_end_date
  AND   ((   NVL(p_terminate_flag,'N')        = 'Y'
         AND( (PPS.actual_termination_date IS NULL AND p_effective_date > = PPS.DATE_START)
            OR (PPS.actual_termination_date > = p_effective_date        AND p_effective_date > = PPS.DATE_START )
            OR TRUNC(PPS.actual_termination_date)  BETWEEN p_start_date
                                                       AND p_end_date
            )
         )
        OR
         (  NVL(p_terminate_flag,'N')                    = 'N'
        AND ((PPS.actual_termination_date IS NULL AND p_effective_date > = PPS.DATE_START)
                OR (PPS.actual_termination_date > = p_effective_date    AND p_effective_date > = PPS.DATE_START ))
         )
        )
  AND   PAF.primary_flag           ='Y'
  ORDER BY PAF.assignment_id;
--
  CURSOR lcu_next_action_id
  IS
  SELECT pay_assignment_actions_s.NEXTVAL
  FROM   dual;
--
  -- Local Variables
  lt_org_id                     per_jp_report_common_pkg.gt_org_tbl;
  lc_procedure                  VARCHAR2(200);
  lc_include_flag               VARCHAR2(1);
  ld_start_date                 DATE;
  ln_next_assignment_action_id  NUMBER;
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled ;
--
    IF gb_debug THEN
      lc_procedure := gc_package||'assignment_action_code';
      hr_utility.set_location('Entering ' || lc_procedure,20);
      hr_utility.set_location('Entering assignment_action_code',20);
      hr_utility.set_location('Person Range '||p_start_person||' - '||p_end_person,20);
      hr_utility.set_location('p_payroll_action_id - '||p_payroll_action_id,20);
      hr_utility.set_location('p_chunk - '||p_chunk,20);
    END IF;
--
    -- initialization_code to to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
--
    initialize(p_payroll_action_id);
--
    IF gr_parameters.organization_id IS NOT NULL THEN
      -- Getting Organization ID's as per hierarchy
      lt_org_id := per_jp_report_common_pkg.get_org_hirerachy(p_business_group_id     => gr_parameters.business_group_id
                                                             ,p_organization_id       => gr_parameters.organization_id
                                                             ,p_include_org_hierarchy => gr_parameters.include_org_hierarchy
                                                             );
-- bug # 8623733 - Hirarchy for Business group, if org is NULL
    ELSE
      lt_org_id := per_jp_report_common_pkg.get_org_hirerachy(p_business_group_id     => gr_parameters.business_group_id
                                                             ,p_organization_id       => gr_parameters.business_group_id
                                                             ,p_include_org_hierarchy => gr_parameters.include_org_hierarchy
                                                             );
    END IF;       -- End if for chk org id parameter.
-- end for bug # 8623733
      FOR i in 1..lt_org_id.COUNT
      LOOP

        IF range_person_on THEN
--
          IF gb_debug THEN
            hr_utility.set_location('Inside Range person if condition',20);
          END IF;
--        -- Assignment Action for Current and Terminated Employees
          FOR lr_emp_assignment_det IN lcu_emp_assignment_det_r(gr_parameters.business_group_id
                                                               ,lt_org_id(i)
                                                               ,gr_parameters.location_id
                                                               ,gr_parameters.include_term_emp
                                                               ,gr_parameters.effective_date
                                                               ,gr_parameters.term_date_from
                                                               ,gr_parameters.term_date_to
                                                               )
          LOOP
            IF NVL(gr_parameters.assignment_set_id,0) = 0 THEN
              OPEN  lcu_next_action_id;
              FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
              CLOSE lcu_next_action_id;
              --
              IF gb_debug THEN
                hr_utility.set_location('p_payroll_action_id.........        = '||p_payroll_action_id,20);
                hr_utility.set_location('l_next_assignment_action_id.        = '||ln_next_assignment_action_id,20);
                hr_utility.set_location('lr_emp_assignment_det.assignment_id.= '||lr_emp_assignment_det.assignment_id,20);
              END IF;
--
              -- Create the archive assignment actions
              hr_nonrun_asact.insact(ln_next_assignment_action_id
                                    ,lr_emp_assignment_det.assignment_id
                                    ,p_payroll_action_id
                                    ,p_chunk
                                    );
            ELSE
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => gr_parameters.assignment_set_id
                                                                              ,p_assignment_id     => lr_emp_assignment_det.assignment_id
                                                                              ,p_effective_date    => gr_parameters.effective_date
                                                                              );
              IF lc_include_flag = 'Y' THEN
                OPEN  lcu_next_action_id;
                FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                CLOSE lcu_next_action_id;
                --
                IF gb_debug THEN
                  hr_utility.set_location('p_payroll_action_id.........        = '||p_payroll_action_id,20);
                  hr_utility.set_location('l_next_assignment_action_id.        = '||ln_next_assignment_action_id,20);
                  hr_utility.set_location('lr_emp_assignment_det.assignment_id.= '||lr_emp_assignment_det.assignment_id,20);
                END IF;
--
                -- Create the archive assignment actions
                hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                      );
              END IF;
            END IF;
          END LOOP; -- End loop for assignment details cursor
        ELSE -- Range person is not on
          IF gb_debug THEN
            hr_utility.set_location('Range person returns false',20);
          END IF;
--        -- Assignment Action for Current and Terminated Employees
          FOR lr_emp_assignment_det IN lcu_emp_assignment_det(p_start_person
                                                             ,p_end_person
                                                             ,gr_parameters.business_group_id
                                                             ,lt_org_id(i)
                                                             ,gr_parameters.location_id
                                                             ,gr_parameters.include_term_emp
                                                             ,gr_parameters.effective_date
                                                             ,gr_parameters.term_date_from
                                                             ,gr_parameters.term_date_to
                                                             )
          LOOP
            IF NVL(gr_parameters.assignment_set_id,0) = 0 THEN
              OPEN  lcu_next_action_id;
              FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
              CLOSE lcu_next_action_id;
              --
              IF gb_debug THEN
                hr_utility.set_location('p_payroll_action_id.........        = '||p_payroll_action_id,20);
                hr_utility.set_location('l_next_assignment_action_id.        = '||ln_next_assignment_action_id,20);
                hr_utility.set_location('lr_emp_assignment_det.assignment_id.= '||lr_emp_assignment_det.assignment_id,20);
              END IF;
--
              -- Create the archive assignment actions
              hr_nonrun_asact.insact(ln_next_assignment_action_id
                                    ,lr_emp_assignment_det.assignment_id
                                    ,p_payroll_action_id
                                    ,p_chunk
                                    );
            ELSE
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => gr_parameters.assignment_set_id
                                                                              ,p_assignment_id     => lr_emp_assignment_det.assignment_id
                                                                              ,p_effective_date    => gr_parameters.effective_date
                                                                              );
              IF lc_include_flag = 'Y' THEN
                OPEN  lcu_next_action_id;
                FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                CLOSE lcu_next_action_id;
                --
                IF gb_debug THEN
                  hr_utility.set_location('p_payroll_action_id.........        = '||p_payroll_action_id,20);
                  hr_utility.set_location('l_next_assignment_action_id.        = '||ln_next_assignment_action_id,20);
                  hr_utility.set_location('lr_emp_assignment_det.assignment_id.= '||lr_emp_assignment_det.assignment_id,20);
                END IF;
--
                -- Create the archive assignment actions
                hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                      );
              END IF;
            END IF;
          END LOOP; -- End loop for assignment details cursor
        END IF;     -- End If for range_person_on
      END LOOP;     -- End loop for Org
--
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,999999);
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
  END assignment_action_code;
--

 FUNCTION get_job_history(p_person_id IN per_people_f.person_id%TYPE
                         ,p_effective_date IN DATE)
  --************************************************************************
  -- FUNCTION
  -- get_job_history
  --
  -- DESCRIPTION
  --  Gets the job history for a person

  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN per_jp_empdet_archive_pkg.gt_job_tbl
  AS
  CURSOR lcu_job_history
  IS
  SELECT  PAAF.position_id                          position_id
         ,PAAF.job_id                               job_id
         ,TRUNC(PAAF.effective_start_date)          start_date
         ,TRUNC(PAAF.effective_end_date)            end_date
         ,PAAF.assignment_id
         ,PP.name                                   position
         ,PJ.name                                   job
         ,HOUT.name                                 organization
         ,HOUT.organization_id                      organization_id -- Added by RDARASI for BUG#8774235
  FROM    per_assignments_f PAAF
         ,per_positions                PP
         ,per_jobs_tl                  PJ
         ,hr_all_organization_units    HOU
         ,hr_all_organization_units_tl HOUT
         ,per_periods_of_service       PPS
  WHERE   PJ.job_id (+)        = PAAF.job_id
  AND     PJ.language(+)       = USERENV('LANG')
  AND     PAAF.position_id     = PP.position_id(+)
  AND     PAAF.person_id       = p_person_id
  AND     PPS.period_of_service_id   = PAAF.period_of_service_id
  AND     HOU.organization_id  = PAAF.organization_id
  AND     HOUT.organization_id = HOU.organization_id
  AND     HOUT.language        = USERENV('LANG')
  AND    TRUNC(p_effective_date) > = PAAF.effective_start_date
  AND    (TRUNC(p_effective_date) > = PPS.date_start AND( PPS.actual_termination_date IS NULL OR PPS.actual_termination_date > = p_effective_date))
  ORDER BY assignment_id,start_date,end_date;

  lt_job_id    per_jp_empdet_archive_pkg.gt_job_tbl;
  lt_res_tb    per_jp_empdet_archive_pkg.gt_job_tbl;
  ln_index     NUMBER := 0;
  ld_start_date per_assignments_f.effective_end_date%TYPE;
  ln_count    NUMBER:=0;

BEGIN

  FOR lr_job_history in lcu_job_history
    LOOP
      ln_index := ln_index + 1;
      lt_job_id(ln_index).assignment_id  := lr_job_history.assignment_id;
      lt_job_id(ln_index).position_id    := lr_job_history.position_id;
      lt_job_id(ln_index).job_id         := lr_job_history.job_id;
      lt_job_id(ln_index).start_date     := lr_job_history.start_date;
      lt_job_id(ln_index).end_date       := lr_job_history.end_date;
      lt_job_id(ln_index).position       := lr_job_history.position;
      lt_job_id(ln_index).job            := lr_job_history.job;
      lt_job_id(ln_index).organization   := lr_job_history.organization;
      lt_job_id(ln_index).organization_id:= lr_job_history.organization_id; -- Added by RDARASI for BUG#8774235
      hr_utility.set_location('step1.... ',20);
  END LOOP;
--
   hr_utility.set_location(ln_index,20);
   IF ln_index=1 THEN
     lt_res_tb(1).assignment_id   :=lt_job_id(1).assignment_id;
     lt_res_tb(1).job_id          :=lt_job_id(1).job_id;
     lt_res_tb(1).position_id     :=lt_job_id(1).position_id;
     lt_res_tb(1).start_date      :=lt_job_id(1).start_date;
     lt_res_tb(1).end_date        :=lt_job_id(1).end_date;
     lt_res_tb(1).position        :=lt_job_id(1).position;
     lt_res_tb(1).job             :=lt_job_id(1).job;
     lt_res_tb(1).organization    :=lt_job_id(1).organization;
     lt_res_tb(1).organization_id := lt_job_id(1).organization_id; -- Added by RDARASI for BUG#8774235
     hr_utility.set_location('step2.... ',20);
   ELSE
      FOR i in 1..ln_index
        LOOP
          IF i<ln_index AND (lt_job_id(i).assignment_id=lt_job_id(i+1).assignment_id) THEN
            IF (NVL(lt_job_id(i).job_id,-999) <> NVL(lt_job_id(i+1).job_id,-999))
                        OR  (NVL(lt_job_id(i).position_id,-999) <> NVL(lt_job_id(i+1).position_id,-999))
                        OR  (NVL(lt_job_id(i).organization_id,-999) <> NVL(lt_job_id(i+1).organization_id,-999)) -- Added by RDARASI for BUG#8774235
              THEN
                IF i<>1 AND (lt_job_id(i).assignment_id = lt_job_id(i-1).assignment_id)
                        AND ((NVL(lt_job_id(i).job_id,-999) = NVL(lt_job_id(i-1).job_id,-999))
                        AND  (NVL(lt_job_id(i).position_id,-999) = NVL(lt_job_id(i-1).position_id,-999))
                        AND  (NVL(lt_job_id(i).organization_id,-999) = NVL(lt_job_id(i-1).organization_id,-999))) -- Added by RDARASI for BUG#8774235
                  THEN
                  lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                  lt_res_tb(i).job_id          :=lt_job_id(i).job_id;
                  lt_res_tb(i).position_id     :=lt_job_id(i).position_id;
                  lt_res_tb(i).start_date      :=ld_start_date;
                  lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                  lt_res_tb(i).position        :=lt_job_id(i).position;
                  lt_res_tb(i).job             :=lt_job_id(i).job;
                  lt_res_tb(i).organization    :=lt_job_id(i).organization;
                  lt_res_tb(i).organization_id := lt_job_id(i).organization_id; -- Added by RDARASI for BUG#8774235
                  ln_count:=0;
                  hr_utility.set_location('step3.... ',20);
               ELSE
                lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                lt_res_tb(i).job_id          :=lt_job_id(i).job_id;
                lt_res_tb(i).position_id     :=lt_job_id(i).position_id;
                lt_res_tb(i).start_date      :=lt_job_id(i).start_date;
                lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                lt_res_tb(i).position        :=lt_job_id(i).position;
                lt_res_tb(i).job             :=lt_job_id(i).job;
                lt_res_tb(i).organization    :=lt_job_id(i).organization;
                lt_res_tb(i).organization_id :=lt_job_id(i).organization_id; -- Added by RDARASI for BUG#8774235
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
                  AND ((NVL(lt_job_id(i).job_id,-999) = NVL(lt_job_id(i-1).job_id,-999))
                  AND  (NVL(lt_job_id(i).position_id,-999) = NVL(lt_job_id(i-1).position_id,-999))
                  AND  (NVL(lt_job_id(i).organization_id,-999) = NVL(lt_job_id(i-1).organization_id,-999)))-- Added by RDARASI for BUG#8774235
                  THEN
                    lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                    lt_res_tb(i).job_id          :=lt_job_id(i).job_id;
                    lt_res_tb(i).position_id     :=lt_job_id(i).position_id;
                    lt_res_tb(i).start_date      :=ld_start_date;
                    lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                    lt_res_tb(i).position        :=lt_job_id(i).position;
                    lt_res_tb(i).job             :=lt_job_id(i).job;
                    lt_res_tb(i).organization    :=lt_job_id(i).organization;
                    lt_res_tb(i).organization_id := lt_job_id(i).organization_id; -- Added by RDARASI for BUG#8774235
                    hr_utility.set_location('step5.... ',20);
                ELSE
                  lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                  lt_res_tb(i).job_id:=lt_job_id(i).job_id;
                  lt_res_tb(i).position_id:=lt_job_id(i).position_id;
                  lt_res_tb(i).start_date:=lt_job_id(i).start_date;
                  lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                  lt_res_tb(i).position:=lt_job_id(i).position;
                  lt_res_tb(i).job:=lt_job_id(i).job;
                  lt_res_tb(i).organization:=lt_job_id(i).organization;
                  lt_res_tb(i).organization_id:=lt_job_id(i).organization_id; -- Added by RDARASI for BUG#8774235
                  hr_utility.set_location('step6.... ',20);
                END IF;
              END IF;
            ELSE
              IF (lt_job_id(i).assignment_id = lt_job_id(i-1).assignment_id)
                 AND ((NVL(lt_job_id(i).job_id,-999) = NVL(lt_job_id(i-1).job_id,-999))
                 AND  (NVL(lt_job_id(i).position_id,-999) = NVL(lt_job_id(i-1).position_id,-999))
                 AND  (NVL(lt_job_id(i).organization_id,-999) = NVL(lt_job_id(i-1).organization_id,-999)))-- Added by RDARASI for BUG#8774235
              THEN
                  lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                  lt_res_tb(i).job_id:=lt_job_id(i).job_id;
                  lt_res_tb(i).position_id:=lt_job_id(i).position_id;
                  lt_res_tb(i).start_date:=ld_start_date;
                  lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                  lt_res_tb(i).position:=lt_job_id(i).position;
                  lt_res_tb(i).job:=lt_job_id(i).job;
                  lt_res_tb(i).organization:=lt_job_id(i).organization;
                  lt_res_tb(i).organization_id:=lt_job_id(i).organization_id;-- Added by RDARASI for BUG#8774235
                  hr_utility.set_location('step7.... ',20);
                  ELSE
                 lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                 lt_res_tb(i).job_id:=lt_job_id(i).job_id;
                 lt_res_tb(i).position_id:=lt_job_id(i).position_id;
                 lt_res_tb(i).start_date:=lt_job_id(i).start_date;
                 lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                 lt_res_tb(i).position:=lt_job_id(i).position;
                 lt_res_tb(i).job:=lt_job_id(i).job;
                 lt_res_tb(i).organization:=lt_job_id(i).organization;
                 lt_res_tb(i).organization_id:=lt_job_id(i).organization_id;-- Added by RDARASI for BUG#8774235
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
  END get_job_history;
  --
  FUNCTION get_assign_history(p_person_id IN per_people_f.person_id%TYPE
                              ,p_effective_date IN DATE
                              , p_start_date    IN DATE
                              , p_end_date      IN  DATE
                              , p_terminate_flag  IN VARCHAR2
                              , p_date_start     IN DATE )
  --************************************************************************
  -- FUNCTION
  -- get_assign_history
  --
  -- DESCRIPTION
  --  Gets the job history for a person
  -- Added for bug 8761443
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN per_jp_empdet_archive_pkg.assign_job_tbl
  AS
  --
  CURSOR lcu_assignment_details ( p_person_id      NUMBER
                                , p_effective_date DATE
                                , p_start_date     DATE
                                , p_end_date       DATE
                                , p_terminate_flag VARCHAR2
                                , p_date_start     DATE       -- Added for BUG#
                                )
  IS
  SELECT PAF.assignment_id
        ,PAF.assignment_number
        ,HOUT.name             organization
        ,PJB.name              job
        ,PPS.name              position
        ,PGS.name              grade
        ,TRUNC(PAF.effective_start_date)          start_date
        ,TRUNC(PAF.effective_end_date)            end_date
        ,PAF.grade_id
        ,PAF.organization_id
        ,PAF.job_id
        ,PAF.position_id
  FROM per_assignments_f            PAF
      ,hr_all_organization_units_tl HOUT
      ,hr_all_organization_units        HOU
      ,per_jobs_tl                  PJB
      ,per_positions                PPS
      ,per_grades_tl                PGS
      ,per_assignment_status_types  PAST
  WHERE PAF.person_id              = p_person_id
  AND   PAF.organization_id        = HOU.organization_id
  AND   HOU.organization_id        = HOUT.organization_id
  AND   HOUT.language(+)           = USERENV('LANG')
  AND   PAF.job_id                 = PJB.job_id(+)
  AND   PJB.language(+)            = USERENV('LANG')
  AND   PAF.position_id            = PPS.position_id(+)
  AND   PAF.grade_id               = PGS.grade_id(+)
  AND   PGS.language(+)            = USERENV('LANG')
  AND   PAF.effective_start_date BETWEEN  TRUNC(p_date_start) AND TRUNC(p_effective_date)   -- Added by MPOTHALA for BUG#8766511
  AND   PAST.assignment_status_type_id = PAF.assignment_status_type_id                      -- Added by MPOTHALA for BUG#8843644
  AND   PAST.per_system_status <> 'TERM_ASSIGN'                                                -- Added by MPOTHALA for BUG#8843644
  ORDER BY PAF.effective_start_date;                                                        -- Added by MPOTHALA for BUG#8820022
  --
  lt_job_id    per_jp_empdet_archive_pkg.assign_job_tbl;
  lt_res_tb    per_jp_empdet_archive_pkg.assign_job_tbl;
  ln_index     NUMBER := 0;
  ld_start_date per_assignments_f.effective_end_date%TYPE;
  ln_count    NUMBER:=0;

BEGIN

  FOR lr_job_history in lcu_assignment_details ( p_person_id      => p_person_id
                                               , p_effective_date => p_effective_date
                                               , p_start_date     => p_start_date
                                               , p_end_date       => p_end_date
                                               , p_terminate_flag => p_terminate_flag
                                               , p_date_start     => p_date_start
                                                )

    LOOP
      ln_index := ln_index + 1;
      lt_job_id(ln_index).assignment_id  := lr_job_history.assignment_id;
      lt_job_id(ln_index).position_id    := lr_job_history.position_id;
      lt_job_id(ln_index).job_id         := lr_job_history.job_id;
      lt_job_id(ln_index).start_date     := lr_job_history.start_date;
      lt_job_id(ln_index).end_date       := lr_job_history.end_date;
      lt_job_id(ln_index).position       := lr_job_history.position;
      lt_job_id(ln_index).job            := lr_job_history.job;
      lt_job_id(ln_index).organization   := lr_job_history.organization;
      lt_job_id(ln_index).organization_id:= lr_job_history.organization_id;
      lt_job_id(ln_index).grade_id       := lr_job_history.grade_id;
      lt_job_id(ln_index).grade          := lr_job_history.grade;
      lt_job_id(ln_index).assignment_number  := lr_job_history.assignment_number;
      hr_utility.set_location('step1.... ',20);
  END LOOP;
--
   hr_utility.set_location(ln_index,20);
   IF ln_index=1 THEN
     lt_res_tb(1).assignment_id   :=lt_job_id(1).assignment_id;
     lt_res_tb(1).job_id          :=lt_job_id(1).job_id;
     lt_res_tb(1).position_id     :=lt_job_id(1).position_id;
     lt_res_tb(1).start_date      :=lt_job_id(1).start_date;
     lt_res_tb(1).end_date        :=lt_job_id(1).end_date;
     lt_res_tb(1).position        :=lt_job_id(1).position;
     lt_res_tb(1).job             :=lt_job_id(1).job;
     lt_res_tb(1).organization    :=lt_job_id(1).organization;
     lt_res_tb(1).organization_id := lt_job_id(1).organization_id; -- Added by RDARASI for BUG#8774235
     lt_res_tb(1).organization    :=lt_job_id(1).organization;
     lt_res_tb(1).organization_id := lt_job_id(1).organization_id; -- Added by RDARASI for BUG#8774235
     lt_res_tb(1).grade_id        := lt_job_id(1).grade_id;
     lt_res_tb(1).grade           := lt_job_id(1).grade;
     lt_res_tb(1).assignment_number  := lt_job_id(1).assignment_number;
     hr_utility.set_location('step2.... ',20);
   ELSE
      FOR i in 1..ln_index
        LOOP
          IF i<ln_index AND (lt_job_id(i).assignment_id=lt_job_id(i+1).assignment_id) THEN
            IF (NVL(lt_job_id(i).job_id,-999) <> NVL(lt_job_id(i+1).job_id,-999))
                        OR  (NVL(lt_job_id(i).position_id,-999) <> NVL(lt_job_id(i+1).position_id,-999))
                        OR  (NVL(lt_job_id(i).organization_id,-999) <> NVL(lt_job_id(i+1).organization_id,-999))
                        OR  (NVL(lt_job_id(i).grade_id,-999) <> NVL(lt_job_id(i+1).grade_id,-999))  -- Added by RDARASI for BUG#8774235
              THEN
                IF i<>1 AND (lt_job_id(i).assignment_id = lt_job_id(i-1).assignment_id)
                        AND ((NVL(lt_job_id(i).job_id,-999) = NVL(lt_job_id(i-1).job_id,-999))
                        AND  (NVL(lt_job_id(i).position_id,-999) = NVL(lt_job_id(i-1).position_id,-999))
                        AND  (NVL(lt_job_id(i).organization_id,-999) = NVL(lt_job_id(i-1).organization_id,-999)))
                        AND  (NVL(lt_job_id(i).grade_id,-999) = NVL(lt_job_id(i-1).grade_id,-999))   -- Changed by MPOTHALA for BUG#8820022
                  THEN
                  lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                  lt_res_tb(i).job_id          :=lt_job_id(i).job_id;
                  lt_res_tb(i).position_id     :=lt_job_id(i).position_id;
                  lt_res_tb(i).start_date      :=ld_start_date;
                  lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                  lt_res_tb(i).position        :=lt_job_id(i).position;
                  lt_res_tb(i).job             :=lt_job_id(i).job;
                  lt_res_tb(i).organization    :=lt_job_id(i).organization;
                  lt_res_tb(i).organization_id := lt_job_id(i).organization_id; -- Added by RDARASI for BUG#8774235
                  lt_res_tb(i).grade_id        := lt_job_id(i).grade_id;
                  lt_res_tb(i).grade           := lt_job_id(i).grade;
                  lt_res_tb(i).assignment_number  := lt_job_id(i).assignment_number;
                  ln_count:=0;
                  hr_utility.set_location('step3.... ',20);
               ELSE
                lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                lt_res_tb(i).job_id          :=lt_job_id(i).job_id;
                lt_res_tb(i).position_id     :=lt_job_id(i).position_id;
                lt_res_tb(i).start_date      :=lt_job_id(i).start_date;
                lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                lt_res_tb(i).position        :=lt_job_id(i).position;
                lt_res_tb(i).job             :=lt_job_id(i).job;
                lt_res_tb(i).organization    :=lt_job_id(i).organization;
                lt_res_tb(i).organization_id :=lt_job_id(i).organization_id; -- Added by RDARASI for BUG#8774235
                lt_res_tb(i).grade_id        := lt_job_id(i).grade_id;
                lt_res_tb(i).grade           := lt_job_id(i).grade;
                lt_res_tb(i).assignment_number  := lt_job_id(i).assignment_number;
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
                  AND ((NVL(lt_job_id(i).job_id,-999) = NVL(lt_job_id(i-1).job_id,-999))
                  AND  (NVL(lt_job_id(i).position_id,-999) = NVL(lt_job_id(i-1).position_id,-999))
                  AND  (NVL(lt_job_id(i).organization_id,-999) = NVL(lt_job_id(i-1).organization_id,-999)))
                  AND  (NVL(lt_job_id(i).grade_id,-999) = NVL(lt_job_id(i-1).grade_id,-999))   -- Added by RDARASI for BUG#8774235
                  THEN
                    lt_res_tb(i).assignment_id   :=lt_job_id(i).assignment_id;
                    lt_res_tb(i).job_id          :=lt_job_id(i).job_id;
                    lt_res_tb(i).position_id     :=lt_job_id(i).position_id;
                    lt_res_tb(i).start_date      :=ld_start_date;
                    lt_res_tb(i).end_date        :=lt_job_id(i).end_date;
                    lt_res_tb(i).position        :=lt_job_id(i).position;
                    lt_res_tb(i).job             :=lt_job_id(i).job;
                    lt_res_tb(i).organization    :=lt_job_id(i).organization;
                    lt_res_tb(i).organization_id := lt_job_id(i).organization_id; -- Added by RDARASI for BUG#8774235
                    lt_res_tb(i).grade_id        := lt_job_id(i).grade_id;
                    lt_res_tb(i).grade           := lt_job_id(i).grade;
                    lt_res_tb(i).assignment_number  := lt_job_id(i).assignment_number;
                    hr_utility.set_location('step5.... ',20);
                ELSE
                  lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                  lt_res_tb(i).job_id:=lt_job_id(i).job_id;
                  lt_res_tb(i).position_id:=lt_job_id(i).position_id;
                  lt_res_tb(i).start_date:=lt_job_id(i).start_date;
                  lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                  lt_res_tb(i).position:=lt_job_id(i).position;
                  lt_res_tb(i).job:=lt_job_id(i).job;
                  lt_res_tb(i).organization:=lt_job_id(i).organization;
                  lt_res_tb(i).organization_id:=lt_job_id(i).organization_id; -- Added by RDARASI for BUG#8774235
                  lt_res_tb(i).grade_id        := lt_job_id(i).grade_id;
                  lt_res_tb(i).grade           := lt_job_id(i).grade;
                  lt_res_tb(i).assignment_number  := lt_job_id(i).assignment_number;
                  hr_utility.set_location('step6.... ',20);
                END IF;
              END IF;
            ELSE
              IF (lt_job_id(i).assignment_id = lt_job_id(i-1).assignment_id)
                 AND ((NVL(lt_job_id(i).job_id,-999) = NVL(lt_job_id(i-1).job_id,-999))
                 AND  (NVL(lt_job_id(i).position_id,-999) = NVL(lt_job_id(i-1).position_id,-999))
                 AND  (NVL(lt_job_id(i).organization_id,-999) = NVL(lt_job_id(i-1).organization_id,-999)))
                 AND  (NVL(lt_job_id(i).grade_id,-999) = NVL(lt_job_id(i-1).grade_id,-999))   -- Added by RDARASI for BUG#8774235
              THEN
                  lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                  lt_res_tb(i).job_id:=lt_job_id(i).job_id;
                  lt_res_tb(i).position_id:=lt_job_id(i).position_id;
                  lt_res_tb(i).start_date:=ld_start_date;
                  lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                  lt_res_tb(i).position:=lt_job_id(i).position;
                  lt_res_tb(i).job:=lt_job_id(i).job;
                  lt_res_tb(i).organization:=lt_job_id(i).organization;
                  lt_res_tb(i).organization_id:=lt_job_id(i).organization_id;-- Added by RDARASI for BUG#8774235
                  lt_res_tb(i).grade_id        := lt_job_id(i).grade_id;
                  lt_res_tb(i).grade           := lt_job_id(i).grade;
                  lt_res_tb(i).assignment_number  := lt_job_id(i).assignment_number;

                  hr_utility.set_location('step7.... ',20);
                  ELSE
                 lt_res_tb(i).assignment_id:=lt_job_id(i).assignment_id;
                 lt_res_tb(i).job_id:=lt_job_id(i).job_id;
                 lt_res_tb(i).position_id:=lt_job_id(i).position_id;
                 lt_res_tb(i).start_date:=lt_job_id(i).start_date;
                 lt_res_tb(i).end_date:=lt_job_id(i).end_date;
                 lt_res_tb(i).position:=lt_job_id(i).position;
                 lt_res_tb(i).job:=lt_job_id(i).job;
                 lt_res_tb(i).organization:=lt_job_id(i).organization;
                 lt_res_tb(i).organization_id:=lt_job_id(i).organization_id;-- Added by RDARASI for BUG#8774235
                 lt_res_tb(i).grade_id        := lt_job_id(i).grade_id;
                 lt_res_tb(i).grade           := lt_job_id(i).grade;
                 lt_res_tb(i).assignment_number  := lt_job_id(i).assignment_number;
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
      hr_utility.set_location('No Data Found Exception in get_assign_history',10);
    END IF;
    RETURN lt_res_tb;
  END get_assign_history;
  --
  PROCEDURE archive_code ( p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%type
                         , p_effective_date        IN pay_payroll_actions.effective_date%type
                         )
  --************************************************************************
  -- PROCEDURE
  --   archive_code
  --
  -- DESCRIPTION
  -- If employee details not previously archived,proc archives employee
  -- details in pay_Action_information with context 'JP_EMPOYEE_DETAILS'
  --
  -- ACCESS
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
  --************************************************************************
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
                              , p_chk_assignment_id NUMBER
                              , p_start_date        DATE
                              , p_end_date          DATE
                              )
  IS
  SELECT PPF.last_name||' '||PPF.first_name                               full_name_kana
       , PPF.per_information18||' '||PPF.per_information19                full_name_kanji
       , PPF.date_of_birth
       , HLU.lookup_code                                                    gender
       , PAD.address_line1
       , PAD.address_line2
       , PAD.address_line3
       , PAD.region_1
       , PAD.region_2
       , PAD.region_3
       , PAD.town_or_city
       , PAD.country
       , PAD.postal_code
       , DECODE(ppf.date_of_death,NULL,ppof.actual_termination_date,NULL) termination_date
       , DECODE(ppf.date_of_death,NULL,ppof.leaving_reason,NULL)          termination_reason
       , fnd_date.date_to_canonical(DECODE(ppof.actual_termination_date,NULL,ppf.date_of_death,NULL)) death_date
       , DECODE(ppf.date_of_death,NULL,NULL,ppof.leaving_reason)          death_cause
       , PJS.name                                                         kind_of_business
       , PPOF.date_start                                                  hire_date
       , PAF.assignment_id
       , PPF.employee_number
       , PPF.person_id
       , PPOF.actual_termination_date                                     actual_termination_date -- Added for BUG#8766511
       , PPOF.date_start                                                  date_start              -- Added for BUG#8766511
  FROM   per_people_f                 PPF
       , per_assignments_f            PAF
       , per_addresses                PAD
       , per_periods_of_service       PPOF
       , per_jobs_tl                  PJS
       , hr_lookups                   HLU
  WHERE PAF.person_id                      = PPF.person_id
  AND   PAD.person_id(+)                   = PPF.person_id
  AND   PAD.address_type(+)                = 'JP_C'
  AND   TRUNC(p_effective_date) BETWEEN TRUNC(NVL(pad.date_from,PPOF.date_start)) AND TRUNC(NVL(pad.date_to,TO_DATE('31/12/4712','dd/mm/yyyy')))
  AND   PPF.person_id                      = PPOF.person_id
  AND   PPOF.period_of_service_id          = PAF.period_of_service_id
  AND   PJS.job_id(+)                      = PAF.job_id
  AND   PJS.language(+)                    = USERENV ('LANG')
  AND   HLU.lookup_type                    = 'SEX'
  AND   HLU.lookup_code                    = PPF.sex
  AND   NVL(PPOF.actual_termination_date,p_effective_date) BETWEEN PPF.effective_start_date
                                                               AND PPF.effective_end_date
  AND   NVL(PPOF.actual_termination_date,p_effective_date) BETWEEN PAF.effective_start_date
                                                               AND PAF.effective_end_date
  AND   ((    p_chk_assignment_id          IS NOT NULL
         AND(( (PPOF.actual_termination_date IS NULL AND p_effective_date > = PPOF.DATE_START)
              OR (PPOF.actual_termination_date > = p_effective_date     AND p_effective_date > = PPOF.DATE_START ))
            OR TRUNC(PPOF.actual_termination_date)  BETWEEN TRUNC(p_start_date)
                                                 AND TRUNC(p_end_date)
            )
         )
        OR
         (  p_chk_assignment_id          IS NULL
        AND ((PPOF.actual_termination_date IS NULL AND p_effective_date > = PPOF.DATE_START)
                OR ( PPOF.actual_termination_date > = p_effective_date AND p_effective_date > = PPOF.DATE_START ))
         )
        )
  AND   PAF.assignment_id                  = p_assignment_id
  AND   PAD.primary_flag(+)                = 'Y'
  ORDER BY PPF.effective_start_date;
-- Home, Mobile, Work
-- Cursor to Fetch Employee Phone Number Details
  CURSOR lcu_phone_details ( p_person_id      NUMBER
                           , p_effective_date DATE
                           )
  IS
  SELECT HLU.meaning
        ,HLU.lookup_code
        ,PPH.phone_number
  FROM   per_phones PPH
        ,hr_lookups HLU
  WHERE  PPH.parent_id                          = p_person_id
  AND    HLU.lookup_type                        = 'PHONE_TYPE'
  AND    HLU.lookup_code                        = PPH.phone_type
  AND    TRUNC(p_effective_date)          BETWEEN TRUNC(PPH.date_from)
                                              AND NVL(PPH.date_to,TRUNC(p_effective_date))
  ORDER BY HLU.meaning;
--
  -- Cursor to Fetch Employee Education Details
  --Added  fnd_date.canonical_to_date conversion for bug 8644256
  CURSOR lcu_education_details ( p_person_id      NUMBER
                               , p_effective_date DATE
                               )
  IS
  SELECT PAC.segment3 school_name
        ,PAC.segment4 school_name_kana
        ,PAC.segment5 faculty
        ,PAC.segment6 faculty_kana
        ,PAC.segment7 department_name
        ,PAC.segment8 graduation_date
  FROM   per_person_analyses         PPA
        ,per_analysis_criteria       PAC
        ,fnd_id_flex_structures      FIFS
  WHERE  PPA.id_flex_num             = PAC.id_flex_num
  AND    PPA.id_flex_num             = FIFS.id_flex_num
  AND    FIFS.application_id         = 800
  AND    FIFS.id_flex_code           = 'PEA'
  AND    FIFS.id_flex_structure_code = 'JP_EDUC_BKGRD'
  AND    PPA.person_id               = p_person_id
  AND    PPA.analysis_criteria_id    = PAC.analysis_criteria_id
  AND    PAC.segment10               = 'Y'
  AND    PAC.enabled_flag            = 'Y'
  ORDER BY PAC.segment3;
--
  -- Cursor to Fetch Employee Previous Job Details
  CURSOR lcu_prev_job_details ( p_person_id      NUMBER )
  IS
  SELECT PPE.employer_name
        ,PPE.start_date
        ,PPE.end_date
        ,PPJ.job_name
        ,PPJ.employment_category
  FROM   per_previous_employers PPE
        ,per_previous_jobs      PPJ
  WHERE  PPE.person_id            =  p_person_id
  AND    PPE.previous_employer_id =  PPJ.previous_employer_id(+) --8765197
  AND    NVL(PPJ.start_date,SYSDATE) = (SELECT NVL(MAX(IPPJ.start_date),SYSDATE)
                                     FROM  per_previous_jobs IPPJ
                                     WHERE IPPJ.previous_employer_id =  PPJ.previous_employer_id
                                    );
 --
  -- Cursor to Fetch Employee Qualification Details
  CURSOR lcu_qualification_details ( p_person_id      NUMBER )
  IS
  SELECT QTT.name                                         type
        ,QT.title
        ,hr_general.decode_lookup ('PER_SUBJECT_STATUSES'
                                   ,QUA.status
                                  )                       status
        ,QT.grade_attained                                grade
        ,NVL (ESA.establishment, EST.name)                establishment
        ,QUA.license_number
        ,QUA.start_date
        ,QUA.end_date
  FROM per_qualifications QUA
      ,per_qualifications_tl QT
      ,per_qualification_types_tl QTT
      ,per_establishment_attendances ESA
      ,per_establishments EST
      ,per_qualification_types QUT
  WHERE QUA.qualification_type_id        = QTT.qualification_type_id
  AND   QTT.language                     = USERENV ('LANG')
  AND   QUT.qualification_type_id        = QUA.qualification_type_id
  AND   QUA.attendance_id                = ESA.attendance_id(+)
  AND   ESA.establishment_id             = EST.establishment_id(+)
  AND   QT.qualification_id              = QUA.qualification_id
  AND   QT.language                      = USERENV ('LANG')
  AND   NVL(QUA.person_id,ESA.person_id) = p_person_id
  ORDER BY QUA.awarded_date;
--
  -- Cursor to Fetch Employee Conctact Information
  CURSOR lcu_contact_info ( p_person_id      NUMBER
                          , p_effective_date DATE
                          )
  IS
  SELECT PPF.last_name||' '||PPF.first_name                                     full_name_kana
        ,PPF.per_information18||' '||PPF.per_information19                      full_name_kanji
        ,HLU1.lookup_code                                                       relationship
        ,HLU.lookup_code                                                        gender
        ,PPF.date_of_birth                                                      birth_date
        ,TRUNC ( MONTHS_BETWEEN ( p_effective_date,PPF.date_of_birth ) / 12 )   age
        ,HLU2.lookup_code                                                       primary_contact
        ,HLU3.lookup_code                                                       dependent
        ,HLU4.lookup_code                                                       shared_residence
        ,TO_NUMBER(PCR.cont_information2)                                       sequence
        ,HLU5.lookup_code                                                       household_head
        ,HLU6.lookup_code                                                       si_itax
  FROM per_contact_relationships PCR
      ,per_people_f              PPF
      ,hr_lookups                HLU
      ,hr_lookups                HLU1
      ,hr_lookups                HLU2
      ,hr_lookups                HLU3
      ,hr_lookups                HLU4
      ,hr_lookups                HLU5
      ,hr_lookups                HLU6
  WHERE PCR.person_id                = p_person_id
  AND   PCR.contact_person_id        = PPF.person_id
  AND   HLU.lookup_type(+)              = 'SEX'
  AND   HLU.lookup_code(+)              = PPF.sex
  AND   HLU1.lookup_type             = 'CONTACT'
  AND   HLU1.lookup_code             = PCR.contact_type
  AND   HLU2.lookup_type             = 'YES_NO'
  AND   HLU2.lookup_code             = PCR.primary_contact_flag
  AND   HLU3.lookup_type             = 'YES_NO'
  AND   HLU3.lookup_code             = PCR.dependent_flag
  AND   HLU4.lookup_type             = 'YES_NO'
  AND   HLU4.lookup_code             = PCR.rltd_per_rsds_w_dsgntr_flag
  AND   HLU5.lookup_type             = 'YES_NO'
  AND   HLU5.lookup_code             = PCR.cont_information3
  AND   HLU6.lookup_type             = 'YES_NO'
  AND   HLU6.lookup_code             = PCR.cont_information1;

  --
  --Cursor to Check Teminated Employee Assignment
  CURSOR lcu_chk_terminate (p_assignment_id     NUMBER
                           ,p_business_group_id NUMBER
                           ,p_start_date        DATE
                           ,p_end_date          DATE
                           ,p_effective_date    DATE
                           )
  IS
  SELECT PAF.assignment_id
  FROM   per_assignments_f        PAF
        ,per_periods_of_service   PPS
  WHERE PAF.assignment_id                  = p_assignment_id
  AND   PAF.person_id                      = PPS.person_id
  AND   PPS.period_of_service_id           = NVL(PAF.period_of_service_id,PPS.period_of_service_id) -- Bug 8838517
  AND   NVL(TRUNC(PPS.actual_termination_date),p_effective_date)  BETWEEN PAF.effective_start_date
                                                                      AND PAF.effective_end_date
  AND   TRUNC(PPS.actual_termination_date)  BETWEEN TRUNC(p_start_date)   --Bug 8838517
                                                AND TRUNC(p_end_date);    --Bug 8838517
  --
  -- Cursor to Fetch procedure name to fetch the Extra Information
  CURSOR lcu_proc_name (p_effective_date DATE)
  IS
  SELECT MAX(FND_DATE.canonical_to_date(HOI.org_information5)) start_date
        ,HOI.org_information4                                  proc_name
  FROM   hr_organization_information HOI
  WHERE  HOI.org_information_context    = 'JP_REPORTS_ADDITIONAL_INFO'
  AND    HOI.org_information1           = 'JPEMPLDETAILSREPORT'
  AND    HOI.org_information3           = 'ADDINFO'
  AND    p_effective_date         BETWEEN FND_DATE.canonical_to_date(HOI.org_information5)
                                      AND FND_DATE.canonical_to_date(HOI.org_information6)
  GROUP BY HOI.org_information4;
--
  -- Cursor to Fetch Assignment Action Id and Effective Date for Balance
  CURSOR lcu_get_assact_bal (p_person_id NUMBER
                            ,p_effective_date DATE
                            ,p_date_start     DATE
                            )
  IS
  SELECT PAA.assignment_action_id
        ,PPA.effective_date
  FROM per_periods_of_service PPOS
      ,pay_assignment_actions PAA
      ,pay_payroll_actions    PPA
      ,per_assignments_f      PAF
      ,pay_element_sets      PES
  WHERE PPOS.person_id               = p_person_id
  AND   PPOS.person_id               = PAF.person_id
  AND   PPOS.period_of_service_id    = PAF.period_of_service_id
  AND   PAF.assignment_id            = PAA.assignment_id
  AND   PAA.payroll_action_id        = PPA.payroll_action_id
  AND   NVL(PPOS.actual_termination_date,TRUNC(p_effective_date)) BETWEEN PAF.effective_start_date  -- Added by MPOTHALA for BUG#8766629
                                   AND PAF.effective_end_date
  AND   PPA.effective_date     BETWEEN NVL(PPOS.actual_termination_date,TRUNC(p_effective_date))
                                   AND NVL(PPOS.final_process_date,TRUNC(p_effective_date))
  AND   TRUNC(PPOS.date_start)  = TRUNC(p_date_start)
  AND   PPA.action_type  IN ( 'Q','R','V','B')
  AND   PPA.element_set_id      = PES.element_set_id
  AND   PES.element_set_name    = 'TRM'
  AND   PES.legislation_code    = 'JP'; -- Added by MPOTHALA for BUG#8843566
  --
  -- Cursor to Fetch Defined Balance Id
  CURSOR lcu_get_bal_amt
  IS
  SELECT PDB.defined_balance_id
  FROM   pay_balance_types_tl      PBT
        ,pay_balance_dimensions_tl PBD
        ,pay_defined_balances      PDB
  WHERE   PBT.balance_name         = 'B_ Term_ Total Earning Amount'
  AND     PBD.dimension_name       = '_A_ Current Payroll Process'
  AND     PBT.balance_type_id      = PDB.balance_type_id
  AND     PBD.balance_dimension_id = PDB.balance_dimension_id;
  --
  --Cursor to Fetch the actual termination dates of a person.
  CURSOR lcu_pjob_hist(p_person_id NUMBER
                       ,p_effective_date DATE)
  IS
  SELECT actual_termination_date
  FROM per_periods_of_service
  WHERE person_id= p_person_id
  AND ( actual_termination_date IS NOT NULL OR actual_termination_date < p_effective_date);

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
--
  -- Local Variables
  lr_employee_details           lcu_employee_details%ROWTYPE;
  lr_proc_name                  lcu_proc_name%ROWTYPE;
  lr_extra_info                 extra_info;
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_assignment_id              per_all_assignments_f.assignment_id%TYPE;
  ln_chk_assignment_id          per_all_assignments_f.assignment_id%TYPE;
  ln_def_balance_id             pay_defined_balances.defined_balance_id%TYPE;
  lc_hi_num                     VARCHAR2(60);
  lc_bp_num                     VARCHAR2(60);
  lc_wpf_num                    VARCHAR2(60);
  lc_uei_num                    VARCHAR2(60);
  lc_hi_date                    VARCHAR2(60);
  lc_bp_date                    VARCHAR2(60);
  lc_wpf_date                   VARCHAR2(60);
  lc_uei_date                   VARCHAR2(60);
  lc_plsql_block                VARCHAR2(2000);
  lc_procedure                  VARCHAR2(200);
  lc_pkg_name                   VARCHAR2(30);
  lc_procedure_name             VARCHAR2(30);
  lc_object_name                VARCHAR2(30);
  lc_phone_home                 VARCHAR2(60);
  lc_phone_mobile               VARCHAR2(60);
  lc_phone_work                 VARCHAR2(60);
  lc_terminate_flag             VARCHAR2(1);
  ln_term_allowance_amt         NUMBER;
  ln_amt                        NUMBER;
  ld_payment_date               DATE;
  i                             NUMBER;
  ld_prev_job                   DATE;
  lt_res_tb                     per_jp_empdet_archive_pkg.gt_job_tbl;
  lt_assign_tb                  per_jp_empdet_archive_pkg.assign_job_tbl;
  ld_effective_date             DATE;
  --
  BEGIN
--
    gb_debug := hr_utility.debug_enabled ;
    -- initialization_code to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
--
    initialize(gn_payroll_action_id);
--
    IF gb_debug THEN
      lc_procedure  := gc_package||'archive_code';
      hr_utility.set_location('Entering '||lc_procedure,1);
      hr_utility.set_location('p_assignment_action_id......= '|| p_assignment_action_id,10);
      hr_utility.set_location('p_effective_date............= '|| TO_CHAR(p_effective_date,'DD-MON-YYYY'),10);
    END IF;
--
    -- Fetch the assignment id
    OPEN  lcu_get_assignment_id(p_assignment_action_id);
    FETCH lcu_get_assignment_id INTO ln_assignment_id;
    CLOSE lcu_get_assignment_id;
--
    -- Fetch the assignment id to check Terminated Employee
    OPEN  lcu_chk_terminate(ln_assignment_id
                           ,gn_business_group_id
                           ,gr_parameters.term_date_from
                           ,gr_parameters.term_date_to
                           ,gr_parameters.effective_date);
    FETCH lcu_chk_terminate INTO ln_chk_assignment_id;
    CLOSE lcu_chk_terminate;
--
    OPEN  lcu_proc_name ( p_effective_date );
    FETCH lcu_proc_name INTO lr_proc_name;--,ld_end_date;
    CLOSE lcu_proc_name;
--
    IF gb_debug THEN
      hr_utility.set_location('Opening Employee Details cursor for ARCHIVE',30);
      hr_utility.set_location('Archiving EMPLOYEE DETAILS',30);
    END IF;
--
    OPEN  lcu_employee_details(ln_assignment_id
                              ,p_effective_date
                              ,ln_chk_assignment_id
                              ,gr_parameters.term_date_from
                              ,gr_parameters.term_date_to
                              );
    FETCH lcu_employee_details INTO lr_employee_details;
--
    IF lcu_employee_details%FOUND THEN
--
      IF ln_chk_assignment_id IS NULL THEN
        lc_terminate_flag := 'C';
      ELSE
         IF p_effective_date < lr_employee_details.actual_termination_date
           THEN
             lc_terminate_flag := 'C';
             lr_employee_details.termination_date := NULL;
             lr_employee_details.termination_reason := NULL;
             lr_employee_details.death_date := NULL;
          ELSE
             lc_terminate_flag := 'T';
         END IF;
      END IF;
--
     IF gb_debug THEN
        hr_utility.set_location('Employee_number:'||lr_employee_details.employee_number,30);
      END IF;
--
      IF gb_debug THEN
        hr_utility.set_location('Fetching SI Information',30);
      END IF;
--
      lc_hi_num  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                            ,p_input_value_name => 'HI_CARD_NUM'
                                                            ,p_assignment_id    => lr_employee_details.assignment_id
                                                            ,p_effective_date   => p_effective_date
                                                            );
      lc_bp_num  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                            ,p_input_value_name => 'BASIC_PENSION_NUM'
                                                            ,p_assignment_id    => lr_employee_details.assignment_id
                                                            ,p_effective_date   => p_effective_date
                                                            );
      lc_wpf_num :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_SI_INFO'
                                                            ,p_input_value_name => 'WPF_MEMBERS_NUM'
                                                            ,p_assignment_id    => lr_employee_details.assignment_id
                                                            ,p_effective_date   => p_effective_date
                                                            );
      lc_uei_num :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_LI_INFO'
                                                            ,p_input_value_name => 'EI_NUM'
                                                            ,p_assignment_id    => lr_employee_details.assignment_id
                                                            ,p_effective_date   => p_effective_date
                                                            );
      lc_hi_date  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_HI_QUALIFY_INFO'
                                                             ,p_input_value_name => 'QUALIFY_DATE'
                                                             ,p_assignment_id    => lr_employee_details.assignment_id
                                                             ,p_effective_date   => p_effective_date
                                                             );
      lc_bp_date  :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_WP_QUALIFY_INFO'
                                                             ,p_input_value_name => 'QUALIFY_DATE'
                                                             ,p_assignment_id    => lr_employee_details.assignment_id
                                                             ,p_effective_date   => p_effective_date
                                                             );
      lc_wpf_date :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_WPF_QUALIFY_INFO'
                                                             ,p_input_value_name => 'QUALIFY_DATE'
                                                             ,p_assignment_id    => lr_employee_details.assignment_id
                                                             ,p_effective_date   => p_effective_date
                                                             );
      lc_uei_date :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_EI_QUALIFY_INFO'
                                                             ,p_input_value_name => 'QUALIFY_DATE'
                                                             ,p_assignment_id    => lr_employee_details.assignment_id
                                                             ,p_effective_date   => p_effective_date
                                                             );
      --
      IF gb_debug THEN
        hr_utility.set_location('Fetching Termination Allowance Amount',30);
      END IF;
      --
      OPEN  lcu_get_bal_amt;
      FETCH lcu_get_bal_amt INTO ln_def_balance_id;
      CLOSE lcu_get_bal_amt;
      --
      IF ln_def_balance_id IS NOT NULL
      AND lr_employee_details.actual_termination_date IS NOT NULL THEN
      --
        IF TRUNC(p_effective_date) >= TRUNC(lr_employee_details.actual_termination_date)  THEN  -- Added for Bug 8838517
        --
        FOR lr_get_assact_bal IN lcu_get_assact_bal(lr_employee_details.person_id
                                                   ,p_effective_date
                                                   ,lr_employee_details.date_start
                                                   )
        LOOP
          ln_amt := pay_jp_balance_pkg.get_balance_value(ln_def_balance_id,lr_get_assact_bal.assignment_action_id);
          IF ln_amt IS NOT NULL THEN
            ln_term_allowance_amt := NVL(ln_term_allowance_amt,0) + NVL(ln_amt,0);  -- Added by MPOTHALA for BUG#8766629
            ld_payment_date       := lr_get_assact_bal.effective_date;
          END IF;
        END LOOP;
        --
        END IF;           -- Added for Bug 8838517
      END IF;
      --
      IF gb_debug THEN
        hr_utility.set_location('Archiving Employee Details',30);
      END IF;
      --
      pay_action_information_api.create_action_information
        ( p_action_information_id        => ln_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => lr_employee_details.assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_EMPDET_EMP'
        , p_action_information1          => lr_employee_details.full_name_kana
        , p_action_information2          => lr_employee_details.full_name_kanji
        , p_action_information3          => fnd_date.date_to_canonical(lr_employee_details.date_of_birth)
        , p_action_information4          => lr_employee_details.gender
        , p_action_information5          => lr_employee_details.address_line1
        , p_action_information6          => lr_employee_details.address_line2
        , p_action_information7          => lr_employee_details.address_line3
        , p_action_information8          => lr_employee_details.region_1
        , p_action_information9          => lr_employee_details.region_2
        , p_action_information10         => lr_employee_details.region_3
        , p_action_information11         => lr_employee_details.town_or_city
        , p_action_information12         => lr_employee_details.country
        , p_action_information13         => lr_employee_details.postal_code
        , p_action_information14         => fnd_date.date_to_canonical(lr_employee_details.hire_date)
        , p_action_information15         => lr_employee_details.kind_of_business
        , p_action_information16         => fnd_date.date_to_canonical(lr_employee_details.termination_date)
        , p_action_information17         => lr_employee_details.termination_reason
        , p_action_information18         => fnd_date.date_to_canonical(lr_employee_details.death_date)
        , p_action_information19         => lc_hi_num
        , p_action_information20         => lc_bp_num
        , p_action_information21         => lc_wpf_num
        , p_action_information22         => lc_uei_num
        , p_action_information23         => fnd_number.number_to_canonical(ln_term_allowance_amt)
        , p_action_information24         => fnd_date.date_to_canonical(ld_payment_date)
        , p_action_information25         => lc_hi_date
        , p_action_information26         => lc_bp_date
        , p_action_information27         => lc_wpf_date
        , p_action_information28         => lc_uei_date
        , p_action_information29         => lc_terminate_flag
        , p_action_information30         => lr_employee_details.employee_number
        );
--
      IF gb_debug THEN
        hr_utility.set_location('Archiving Employee Job Details For Workers Register',30);
      END IF;
--
      IF lc_terminate_flag = 'C' THEN
        lt_res_tb :=get_job_history(lr_employee_details.person_id,p_effective_date);
      END IF;

      i := lt_res_tb.first;
        WHILE  i IS NOT NULL LOOP
          hr_utility.set_location('Inside loop  for Archiving Employee Job Details For Workers Register',30);
          IF TRUNC(p_effective_date) < TRUNC(lt_res_tb(i).end_date)
            THEN
              lt_res_tb(i).end_date  :=null;
          END IF;
          pay_action_information_api.create_action_information
          ( p_action_information_id        => ln_action_info_id
          , p_action_context_id            => p_assignment_action_id
          , p_action_context_type          => 'AAP'
          , p_object_version_number        => ln_obj_version_num
          , p_effective_date               => p_effective_date
          , p_assignment_id                => lt_res_tb(i).assignment_id
          , p_source_id                    => NULL
          , p_source_text                  => NULL
          , p_action_information_category  => 'JP_EMPDET_JOB'
          , p_action_information1          => lt_res_tb(i).position
          , p_action_information2          => lt_res_tb(i).job
          , p_action_information3          => fnd_date.date_to_canonical(lt_res_tb(i).start_date)
          , p_action_information4          => fnd_date.date_to_canonical(lt_res_tb(i).end_date)
          , p_action_information5          => lt_res_tb(i).organization
          );
          hr_utility.set_location('exiting loop  for Archiving Employee Job Details For Workers Register',30);
          i:=lt_res_tb.next(i);
        END LOOP;  -- End loop for Job Details
--
      IF gb_debug THEN
        hr_utility.set_location('Archiving Employee Phone Number Details',30);
      END IF;
--
      FOR lr_phone_rec IN lcu_phone_details(lr_employee_details.person_id,p_effective_date)
      LOOP
        IF lr_phone_rec.lookup_code = 'H1' THEN
          lc_phone_home := lr_phone_rec.meaning||' '||lr_phone_rec.phone_number;
        ELSIF lr_phone_rec.lookup_code = 'M' THEN
          lc_phone_mobile := lr_phone_rec.meaning||' '||lr_phone_rec.phone_number;
        ELSIF lr_phone_rec.lookup_code = 'W1' THEN
          lc_phone_work := lr_phone_rec.meaning||' '||lr_phone_rec.phone_number;
        END IF;
      END LOOP;  -- End loop for Phone Details
      pay_action_information_api.create_action_information
        ( p_action_information_id        => ln_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => lr_employee_details.assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_EMPDET_PHONE'
        , p_action_information1          => lc_phone_home
        , p_action_information2          => lc_phone_mobile
        , p_action_information3          => lc_phone_work
        );

--
      IF gb_debug THEN
        hr_utility.set_location('Archiving Employee Educational Background Details',30);
      END IF;
--
      FOR lr_education_rec IN lcu_education_details(lr_employee_details.person_id,p_effective_date)
      LOOP
        pay_action_information_api.create_action_information
          ( p_action_information_id        => ln_action_info_id
          , p_action_context_id            => p_assignment_action_id
          , p_action_context_type          => 'AAP'
          , p_object_version_number        => ln_obj_version_num
          , p_effective_date               => p_effective_date
          , p_assignment_id                => lr_employee_details.assignment_id
          , p_source_id                    => NULL
          , p_source_text                  => NULL
          , p_action_information_category  => 'JP_EMPDET_EDUCATION_DET'
          , p_action_information1          => lr_education_rec.school_name
          , p_action_information2          => lr_education_rec.school_name_kana
          , p_action_information3          => lr_education_rec.faculty
          , p_action_information4          => lr_education_rec.faculty_kana
          , p_action_information5          => lr_education_rec.department_name
          , p_action_information6          => lr_education_rec.graduation_date
          );
      END LOOP;  -- End loop for Education Details
--
      IF gb_debug THEN
        hr_utility.set_location('Archiving Employee Previous Job Details',30);
      END IF;
--
      FOR lr_prev_job_rec IN lcu_prev_job_details(lr_employee_details.person_id)
        LOOP
          IF TRUNC(p_effective_date) > TRUNC(lr_prev_job_rec.end_date)
            THEN
              pay_action_information_api.create_action_information
              ( p_action_information_id        => ln_action_info_id
               , p_action_context_id            => p_assignment_action_id
               , p_action_context_type          => 'AAP'
               , p_object_version_number        => ln_obj_version_num
               , p_effective_date               => p_effective_date
               , p_assignment_id                => lr_employee_details.assignment_id
               , p_source_id                    => NULL
               , p_source_text                  => NULL
               , p_action_information_category  => 'JP_EMPDET_PREV_JOB'
               , p_action_information1          => lr_prev_job_rec.employer_name
               , p_action_information2          => fnd_date.date_to_canonical(lr_prev_job_rec.start_date)
               , p_action_information3          => fnd_date.date_to_canonical(lr_prev_job_rec.end_date)
               , p_action_information4          => lr_prev_job_rec.job_name
               , p_action_information5          => lr_prev_job_rec.employment_category
               );
           END IF;
        END LOOP;  -- End loop for Previous Job Details
--
        FOR lr_pjob_hist in  lcu_pjob_hist( lr_employee_details.person_id
                                            ,p_effective_date)
          LOOP
            ld_prev_job :=lr_pjob_hist.actual_termination_date;
            IF ld_prev_job IS NOT NULl THEN
          IF  lr_employee_details.actual_termination_date IS NULL THEN
                lt_res_tb :=get_job_history(lr_employee_details.person_id,ld_prev_job -1);
                i := lt_res_tb.first;
               WHILE i IS NOT NULL LOOP
                   hr_utility.set_location('Inside loop  for Archiving Employee  Previous Job Details For Workers Register',30);
                   pay_action_information_api.create_action_information
                 ( p_action_information_id        => ln_action_info_id
                 , p_action_context_id            => p_assignment_action_id
                 , p_action_context_type          => 'AAP'
                 , p_object_version_number        => ln_obj_version_num
                 , p_effective_date               => p_effective_date
                 , p_assignment_id                => lt_res_tb(i).assignment_id
                 , p_source_id                    => NULL
                 , p_source_text                  => NULL
                 , p_action_information_category  => 'JP_EMPDET_PREV_JOB'
                 , p_action_information1          =>  lt_res_tb(i).organization
                 , p_action_information2          => fnd_date.date_to_canonical(lt_res_tb(i).start_date)
                 , p_action_information3          => fnd_date.date_to_canonical(lt_res_tb(i).end_date)
                 , p_action_information4          => lt_res_tb(i).job
                 , p_action_information5          => 'REHIRE'
                );
                i:=lt_res_tb.next(i);
           END LOOP;  -- End loop for Previous Job Details
                   ELSIF lc_terminate_flag = 'T' THEN --8721997
                     lt_res_tb :=get_job_history(lr_employee_details.person_id,ld_prev_job -1);
                 i := lt_res_tb.first;
             WHILE i IS NOT NULL LOOP
                 hr_utility.set_location('Inside loop  for Archiving Employee Job Details For Workers Register',30);
                          pay_action_information_api.create_action_information
             ( p_action_information_id        => ln_action_info_id
             , p_action_context_id            => p_assignment_action_id
             , p_action_context_type          => 'AAP'
             , p_object_version_number        => ln_obj_version_num
             , p_effective_date               => p_effective_date
             , p_assignment_id                => lt_res_tb(i).assignment_id
             , p_source_id                    => NULL
             , p_source_text                  => NULL
             , p_action_information_category  => 'JP_EMPDET_JOB'
             , p_action_information1          => lt_res_tb(i).position
             , p_action_information2          => lt_res_tb(i).job
             , p_action_information3          => fnd_date.date_to_canonical(lt_res_tb(i).start_date)
             , p_action_information4          => fnd_date.date_to_canonical(lt_res_tb(i).end_date)
             , p_action_information5          => lt_res_tb(i).organization
             );
             hr_utility.set_location('exiting loop  for Archiving Employee Job Details For Workers Register',30);
             i:=lt_res_tb.next(i);
           END LOOP;--8721997
         END IF;
        END IF;
    END LOOP;
--
      IF gb_debug THEN
        hr_utility.set_location('Archiving Employee Qualification Details',30);
      END IF;
--
      FOR lr_qualification_rec IN lcu_qualification_details(lr_employee_details.person_id)
      LOOP
        pay_action_information_api.create_action_information
          ( p_action_information_id        => ln_action_info_id
          , p_action_context_id            => p_assignment_action_id
          , p_action_context_type          => 'AAP'
          , p_object_version_number        => ln_obj_version_num
          , p_effective_date               => p_effective_date
          , p_assignment_id                => lr_employee_details.assignment_id
          , p_source_id                    => NULL
          , p_source_text                  => NULL
          , p_action_information_category  => 'JP_EMPDET_QUALIFICATIONS'
          , p_action_information1          => lr_qualification_rec.type
          , p_action_information2          => lr_qualification_rec.title
          , p_action_information3          => lr_qualification_rec.status
          , p_action_information4          => lr_qualification_rec.grade
          , p_action_information5          => lr_qualification_rec.establishment
          , p_action_information6          => lr_qualification_rec.license_number
          , p_action_information7          => fnd_date.date_to_canonical(lr_qualification_rec.start_date)
          , p_action_information8          => fnd_date.date_to_canonical(lr_qualification_rec.end_date)
          );
      END LOOP;  -- End loop for Qualification Details
--
      IF gb_debug THEN
        hr_utility.set_location('Archiving Employee Assignment History',30);
      END IF;
--    --
      -- Added for BUG#8766511
      IF lr_employee_details.actual_termination_date IS NULL THEN
         ld_effective_date := gr_parameters.effective_date;
      ELSE
         IF lr_employee_details.actual_termination_date >  gr_parameters.effective_date THEN
           ld_effective_date := gr_parameters.effective_date;
         ELSE
           ld_effective_date := lr_employee_details.actual_termination_date;
         END IF;
      END IF;
      -- End for BUG#8766511
      --Assignment Details Start
      --
      IF gb_debug THEN
        hr_utility.set_location('lr_employee_details.person_id '||lr_employee_details.person_id,1);
        hr_utility.set_location('ld_effective_date '||ld_effective_date,1);
        hr_utility.set_location('gr_parameters.term_date_from '||gr_parameters.term_date_from,1);
        hr_utility.set_location('gr_parameters.term_date_to '||gr_parameters.term_date_to,1);
        hr_utility.set_location('gr_parameters.include_term_emp '||gr_parameters.include_term_emp,1);
        hr_utility.set_location('lr_employee_details.date_start   '||lr_employee_details.date_start,1);
      END IF;
      --
       lt_assign_tb :=get_assign_history(lr_employee_details.person_id
                                       ,ld_effective_date
                                       ,gr_parameters.term_date_from
                                       ,gr_parameters.term_date_to
                                       ,gr_parameters.include_term_emp
                                       ,lr_employee_details.date_start
                                        );
      i := lt_assign_tb.first;
        --
        WHILE  i IS NOT NULL LOOP
          hr_utility.set_location('Inside loop  for Archiving Assignment history Details',30);
          --
          IF TRUNC(p_effective_date) < TRUNC(lt_assign_tb(i).end_date)
            THEN
              lt_assign_tb(i).end_date  :=null;
          END IF;
          --
          pay_action_information_api.create_action_information
          ( p_action_information_id        => ln_action_info_id
          , p_action_context_id            => p_assignment_action_id
          , p_action_context_type          => 'AAP'
          , p_object_version_number        => ln_obj_version_num
          , p_effective_date               => p_effective_date
          , p_assignment_id                => lt_assign_tb(i).assignment_id
          , p_source_id                    => NULL
          , p_source_text                  => NULL
          , p_action_information_category  => 'JP_EMPDET_ASSIGNMENTS'
          , p_action_information1          => lt_assign_tb(i).organization
          , p_action_information2          => lt_assign_tb(i).job
          , p_action_information3          => lt_assign_tb(i).position
          , p_action_information4          => lt_assign_tb(i).grade
          , p_action_information5          => fnd_date.date_to_canonical(lt_assign_tb(i).start_date)
          , p_action_information6          => fnd_date.date_to_canonical(lt_assign_tb(i).end_date)
          , p_action_information7          => lt_assign_tb(i).assignment_number
          );
          hr_utility.set_location('exiting loop  for Archiving Employee Job Details For Workers Register',30);
          i:=lt_assign_tb.next(i);
        END LOOP;  -- End loop for Assignment Details
      --
      IF gb_debug THEN
        hr_utility.set_location('Archiving Employee Contact Information',30);
      END IF;
      --
      FOR lr_contact_rec IN lcu_contact_info(lr_employee_details.person_id
                                            ,gr_parameters.effective_date
                                            )
      LOOP
        pay_action_information_api.create_action_information
          ( p_action_information_id        => ln_action_info_id
          , p_action_context_id            => p_assignment_action_id
          , p_action_context_type          => 'AAP'
          , p_object_version_number        => ln_obj_version_num
          , p_effective_date               => p_effective_date
          , p_assignment_id                => lr_employee_details.assignment_id
          , p_source_id                    => NULL
          , p_source_text                  => NULL
          , p_action_information_category  => 'JP_EMPDET_CONTACT_INFO'
          , p_action_information1          => lr_contact_rec.full_name_kana
          , p_action_information2          => lr_contact_rec.full_name_kanji
          , p_action_information3          => lr_contact_rec.relationship
          , p_action_information4          => lr_contact_rec.gender
          , p_action_information5          => fnd_date.date_to_canonical(lr_contact_rec.birth_date)
          , p_action_information6          => fnd_number.number_to_canonical(lr_contact_rec.age)
          , p_action_information7          => lr_contact_rec.primary_contact
          , p_action_information8          => lr_contact_rec.dependent
          , p_action_information9          => lr_contact_rec.shared_residence
          , p_action_information10         => fnd_number.number_to_canonical(lr_contact_rec.sequence)
          , p_action_information11         => lr_contact_rec.household_head
          , p_action_information12         => lr_contact_rec.si_itax
          );
      END LOOP;  -- End loop for Contact Information
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
          hr_utility.set_location('Calling Extra info plug in procedure using dynamic SQL',30);
        END IF;
--
        EXECUTE IMMEDIATE 'BEGIN '||lr_proc_name.proc_name||lc_plsql_block||' END;'
        USING   IN  lr_employee_details.assignment_id
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
          , p_action_context_id            => p_assignment_action_id
          , p_action_context_type          => 'AAP'
          , p_object_version_number        => ln_obj_version_num
          , p_effective_date               => p_effective_date
          , p_assignment_id                => lr_employee_details.assignment_id
          , p_source_id                    => NULL
          , p_source_text                  => NULL
          , p_action_information_category  => 'JP_EMPDET_EXTRA_INFO'
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
    END IF; -- End IF for Employee Details
    CLOSE lcu_employee_details;
--
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1);
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
  END archive_code;
END per_jp_empdet_archive_pkg;

/
