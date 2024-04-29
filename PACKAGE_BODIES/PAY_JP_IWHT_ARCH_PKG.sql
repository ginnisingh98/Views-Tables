--------------------------------------------------------
--  DDL for Package Body PAY_JP_IWHT_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_IWHT_ARCH_PKG" AS
-- $Header: pyjpiwar.pkb 120.1.12010000.8 2010/05/13 06:59:32 mpothala noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  PAYJLWL.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of pay_jp_iwht_arch_pkg
-- *
-- * USAGE
-- *   To install       sqlplus <apps_user>/<apps_pwd> @payjpwlarchpkg.pkb
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC payjpwlarchpkg.<procedure name>
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
-- * LAST UPDATE DATE   05-Feb-2010
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * VERSION             DATE        AUTHOR(S)             DESCRIPTION
-- * ------- ----------- -----------------------------------------------------------
-- * 120.0.12010000.1  05-Feb-2010   MPOTHALA               Creation
-- * 120.1.12010000.2  08-Mar-2010	 MPOTHALA               update after unit testing
-- * 120.1.12010000.3  09-Mar-2010	 MPOTHALA               To fix bugs of the bug #9437454
-- * 120.1.12010000.4  26-Mar-2010	 MPOTHALA               To fix bugs of the bug #9525922,9509191
-- * 120.1.12010000.5  29-Mar-2010	 MPOTHALA               To fix bugs of the bug #9525922,9509191
-- * 120.1.12010000.6  31-Mar-2010	 MPOTHALA               To fix bugs of the bug #9569078
-- * 120.1.12010000.7  31-Mar-2010	 MPOTHALA               To fix bugs of the bug #9554515
-- * 120.1.12010000.8  13-May-2010	 MPOTHALA               Fixed assignment set issue
-- *********************************************************************************
  --Declaration of constant global variables
  --
  gc_package                  CONSTANT VARCHAR2(60) := 'pay_jp_iwht_arch_pkg.';
  gc_report_type              CONSTANT VARCHAR2(60) := 'JP_IWHT_ARCH';
  --
  --  Global to store package name for tracing.
  --  Declaration of global variables
  gn_arc_payroll_action_id    pay_payroll_actions.payroll_action_id%type;
  gn_business_group_id        hr_all_organization_units.organization_id%type;
  gn_payroll_action_id        pay_payroll_actions.payroll_action_id%TYPE;
  gb_debug                    BOOLEAN;
  gd_end_date                 DATE;
  gd_start_date               DATE;
  gd_effective_date           DATE;
  gd_ystart_date			DATE;
  gd_yend_date    	      DATE;

  --
  PROCEDURE range_code ( p_payroll_action_id  IN         pay_payroll_actions.payroll_action_id%TYPE
                        ,p_sql                OUT        NOCOPY VARCHAR2
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
  END range_code;
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
  SELECT business_group_id
        ,effective_date
        ,fnd_number.canonical_to_number(pay_core_utils.get_parameter('ITAX_ORGANIZATION_ID',legislative_parameters))
        ,fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ID',legislative_parameters))
        ,fnd_date.canonical_to_date(pay_core_utils.get_parameter('TERMINATION_DATE_FROM', legislative_parameters))
        ,fnd_date.canonical_to_date(pay_core_utils.get_parameter('TERMINATION_DATE_TO',legislative_parameters))
        ,fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',legislative_parameters))
        ,pay_core_utils.get_parameter('REARCHIVE_FLAG',legislative_parameters)
  FROM  pay_payroll_actions PPA
  WHERE PPA.payroll_action_id  =  p_payroll_action_id;
  -- Local Variables
  lc_procedure                VARCHAR2(200);
  i                           NUMBER := 0;
  lc_legislative_parameters	pay_payroll_actions.legislative_parameters%type;
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
    INTO   gr_parameters.business_group_id
          ,gr_parameters.effective_date
          ,gr_parameters.withholding_agent_id
          ,gr_parameters.payroll_id
          ,gr_parameters.termination_date_from
          ,gr_parameters.termination_date_to
          ,gr_parameters.assignment_set_id
          ,gr_parameters.rearchive_flag;
    CLOSE lcr_params;
    --
    IF gb_debug THEN
       hr_utility.set_location('p_payroll_action_id.........          = ' || p_payroll_action_id,30);
       hr_utility.set_location('gr_parameters.business_group_id.......= ' || gr_parameters.business_group_id,30);
       hr_utility.set_location('gr_parameters.effective_date.......= ' || gr_parameters.effective_date,30);
       hr_utility.set_location('gr_parameters.withholding_agent_id..........= ' ||gr_parameters.withholding_agent_id,30);
       hr_utility.set_location('gr_parameters.payroll_id......= '  || gr_parameters.payroll_id,30);
       hr_utility.set_location('gr_parameters.gr_parameters.termination_date_from...= ' || gr_parameters.termination_date_from  ,30);
       hr_utility.set_location('gr_parameters.termination_date_to.....= ' || gr_parameters.termination_date_to,30);
       hr_utility.set_location('gr_parameters.assignment_set_id .....= ' || gr_parameters.assignment_set_id ,30);
       hr_utility.set_location('gr_parameters.rearchive_flag.......= ' || gr_parameters.rearchive_flag,30);
    END IF;
    --
    gd_ystart_date	 := TRUNC(gr_parameters.effective_date, 'YYYY');
    gd_yend_date		 := ADD_MONTHS(gd_ystart_date, 12) - 1;
    gn_business_group_id := gr_parameters.business_group_id ;
    gn_payroll_action_id := p_payroll_action_id;
    -------------------------------------------------------------------------
    -- Fetch the Organization information into global type
    -------------------------------------------------------------------------
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
  PROCEDURE initialization_code ( p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE )
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
  END initialization_code;
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
 PROCEDURE delete_assact ( p_assignment_id      IN per_all_assignments_f.assignment_id%TYPE)
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
  CURSOR lcu_action_information_id(p_assignment_id   per_all_assignments_f.assignment_id%TYPE)
  IS
  SELECT PAI.object_version_number
        ,PAI.action_information_id
        ,PAC.assignment_action_id
  FROM pay_action_information   PAI
      ,pay_assignment_actions   PAC
      ,pay_payroll_actions       PPA
  WHERE PAI.action_context_id = PAC.assignment_action_id
  AND   PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id   = PPA.payroll_action_id
  AND   PAI.action_context_type = 'AAP'
  AND   PPA.report_type         = gc_report_type;
  --
  lc_procedure               VARCHAR2(200);
  --
  BEGIN
    --
    gb_debug :=hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'delete_assact';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    -----------------------------------------------------------
    -- Fetch the parameters passed by user into global variable
    -- initialize procedure
    -----------------------------------------------------------
    --
    FOR lr_emp_assignment_det in lcu_action_information_id(p_assignment_id)
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
  END delete_assact;
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
  --
  PROCEDURE assignment_action_code( p_payroll_action_id IN pay_payroll_actions.payroll_action_id%type
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
  CURSOR lcu_emp_assignment_det_r(p_payroll_action_id       pay_payroll_actions.payroll_action_id%TYPE
                                 ,p_business_group_id       per_assignments_f.business_group_id%TYPE
                                 ,p_effective_date          DATE
                                 ,p_payroll_id              pay_payrolls_f.payroll_id%TYPE
                                 ,p_with_hold_id            hr_all_organization_units.organization_id%TYPE
                                 ,p_termination_date_from   DATE
                                 ,p_termination_date_to     DATE
                                 )
  IS
  SELECT PAF.assignment_id
        ,PPS.actual_termination_date
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
  AND    PPS.period_of_service_id   = NVL(PAF.period_of_service_id,PPS.period_of_service_id)
  AND    NVL(PAF.payroll_id,-999)   = NVL(p_payroll_id,NVL(PAF.payroll_id,-999))
  AND    NVL(get_with_hold_agent(PAF.assignment_id,NVL(PPS.actual_termination_date,p_effective_date)),-999) = NVL(p_with_hold_id,NVL(get_with_hold_agent(PAF.assignment_id,NVL(PPS.actual_termination_date,p_effective_date)),-999))
  AND   ( TRUNC(PPS.actual_termination_date) BETWEEN  TRUNC(NVL(p_termination_date_from,PPS.actual_termination_date))   AND TRUNC(NVL(p_termination_date_to,PPS.actual_termination_date))
           OR
           (p_termination_date_from IS NULL AND p_termination_date_to IS NULL)) -- #Bug 9527179
  AND   TRUNC(NVL(PPS.actual_termination_date,p_effective_date)) BETWEEN PPF.effective_start_date  AND PPF.effective_end_date
  AND   TRUNC(NVL(PPS.actual_termination_date,p_effective_date)) BETWEEN PAF.effective_start_date  AND PAF.effective_end_date
  AND    EXISTS(SELECT 1
	FROM	pay_jp_pre_tax		PPT,
		pay_assignment_actions	PAA,
		pay_payroll_actions	PPA
	WHERE	PPA.effective_date BETWEEN gd_ystart_date AND gd_yend_date
      AND   PAA.assignment_id  = PAF.assignment_id
	AND	PPA.business_group_id + 0 = p_business_group_id
	AND	PPA.action_type in ('R', 'Q', 'B', 'I')
	AND	PAA.payroll_action_id = PPA.payroll_action_id
	AND	PAA.action_status = 'C'
	AND	PPT.assignment_action_id = PAA.assignment_action_id
	AND	PPT.action_status = 'C'
	AND	PPT.salary_category = 'TERM'
	AND	NVL(PPT.itax_organization_id,-999) = NVL(NVL(p_with_hold_id,PPT.itax_organization_id),-999)
   	AND	NOT EXISTS(
			SELECT	null
			FROM	pay_payroll_actions	PPAV,
				pay_assignment_actions	PAAV,
				pay_action_interlocks	PAI
			WHERE	PAI.locked_action_id = PAA.assignment_action_id
                  AND	PAAV.assignment_action_id = PAI.locking_action_id
			AND	PPAV.payroll_action_id = PAAV.payroll_action_id
			AND	PPAV.action_type = 'V'))
  ORDER BY PAF.assignment_id;
  --
  CURSOR lcu_emp_assignment_det ( p_payroll_action_id       pay_payroll_actions.payroll_action_id%TYPE
                                 ,p_start_person_id         per_all_people_f.person_id%TYPE
                                 ,p_end_person_id           per_all_people_f.person_id%TYPE
                                 ,p_business_group_id       per_assignments_f.business_group_id%TYPE
                                 ,p_effective_date          DATE
                                 ,p_payroll_id              pay_payrolls_f.payroll_id%TYPE
                                 ,p_with_hold_id            hr_all_organization_units.organization_id%TYPE
                                 ,p_termination_date_from   DATE
                                 ,p_termination_date_to     DATE
                                 )
  IS
  SELECT PAF.assignment_id
        ,PPS.actual_termination_date
  FROM   per_assignments_f            PAF
        ,per_people_f                 PPF
        ,per_periods_of_service       PPS
  WHERE  PAF.person_id              = PPF.person_id
  AND    PPF.person_id              = PPS.person_id
  AND    PAF.business_group_id      = p_business_group_id
  AND    PPS.period_of_service_id   = NVL(PAF.period_of_service_id,PPS.period_of_service_id)
  AND    PPF.person_id BETWEEN p_start_person_id AND p_end_person_id
  AND    NVL(PAF.payroll_id,-999)   = NVL(p_payroll_id,NVL(PAF.payroll_id,-999))
  AND    NVL(get_with_hold_agent(PAF.assignment_id,NVL(PPS.actual_termination_date,p_effective_date)),-999) = NVL(p_with_hold_id,NVL(get_with_hold_agent(PAF.assignment_id,NVL(PPS.actual_termination_date,p_effective_date)),-999))
  AND   ( TRUNC(PPS.actual_termination_date) BETWEEN  TRUNC(NVL(p_termination_date_from,PPS.actual_termination_date))   AND TRUNC(NVL(p_termination_date_to,PPS.actual_termination_date))
           OR
           (p_termination_date_from IS NULL AND p_termination_date_to IS NULL)) -- #Bug 9527179
  AND   TRUNC(NVL(PPS.actual_termination_date,p_effective_date)) BETWEEN PPF.effective_start_date  AND PPF.effective_end_date
  AND   TRUNC(NVL(PPS.actual_termination_date,p_effective_date)) BETWEEN PAF.effective_start_date  AND PAF.effective_end_date
  AND    EXISTS(SELECT 1
	   FROM	pay_jp_pre_tax		PPT,
		pay_assignment_actions	PAA,
		pay_payroll_actions	PPA
	  WHERE	PPA.effective_date BETWEEN gd_ystart_date AND gd_yend_date
        AND   PAA.assignment_id  = PAF.assignment_id
	  AND	PPA.business_group_id + 0 = p_business_group_id
	  AND	PPA.action_type in ('R', 'Q', 'B', 'I')
	  AND	PAA.payroll_action_id = PPA.payroll_action_id
	  AND	PAA.action_status = 'C'
	  AND	PPT.assignment_action_id = PAA.assignment_action_id
	  AND	PPT.action_status = 'C'
	  AND	PPT.salary_category = 'TERM'
	  AND	NVL(PPT.itax_organization_id,-999) = NVL(NVL(p_with_hold_id,PPT.itax_organization_id),-999)
  	  AND	NOT EXISTS(
			SELECT	null
			FROM	pay_payroll_actions	PPAV,
				pay_assignment_actions	PAAV,
				pay_action_interlocks	PAI
			WHERE	PAI.locked_action_id = PAA.assignment_action_id
                  AND	PAAV.assignment_action_id = PAI.locking_action_id
			AND	PPAV.payroll_action_id = PAAV.payroll_action_id
			AND	PPAV.action_type = 'V'))
  ORDER BY PAF.assignment_id;
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
  --
  ld_termination_date_from      DATE;
  ld_termination_date_to        DATE;
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
    --
    IF range_person_on THEN
      --
      IF gb_debug THEN
         hr_utility.set_location('before range person1 on loop',20);
      END IF;
      --
      FOR lr_emp_assignment_det_r in lcu_emp_assignment_det_r(p_payroll_action_id
                                                             ,gr_parameters.business_group_id
                                                             ,gr_parameters.effective_date
                                                             ,gr_parameters.payroll_id
                                                             ,gr_parameters.withholding_agent_id
                                                             ,gr_parameters.termination_date_from
                                                             ,gr_parameters.termination_date_to
                                                             )
      LOOP
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
        -- Create the archive assignment actions
        --
        IF NVL(gr_parameters.assignment_set_id,0) = 0 THEN

              -- Create the archive assignment actions
              hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det_r.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                     );

         ELSE
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => gr_parameters.assignment_set_id
                                                                              ,p_assignment_id     => lr_emp_assignment_det_r.assignment_id
                                                                              ,p_effective_date    => NVL(lr_emp_assignment_det_r.actual_termination_date,gr_parameters.effective_date) -- #Bug No 9508028
                                                                              ,p_populate_fs_flag  => 'Y'  -- #Bug No 9508028
                                                                              );

              IF gb_debug THEN
                  hr_utility.set_location('lc_include_flag after check.= '||lc_include_flag ,20);
              END IF;
              --
              IF lc_include_flag = 'Y' THEN
               --
               OPEN  lcu_next_action_id;
               FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
               CLOSE lcu_next_action_id;
               --

                -- Create the archive assignment actions
                hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det_r.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                     );

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
                                                         ,gr_parameters.effective_date
                                                         ,gr_parameters.payroll_id
                                                         ,gr_parameters.withholding_agent_id
                                                         ,gr_parameters.termination_date_from
                                                         ,gr_parameters.termination_date_to
                                                         )
      LOOP
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
        -- Create the archive assignment actions
        --
        IF NVL(gr_parameters.assignment_set_id,0) = 0 THEN

              -- Create the archive assignment actions

               hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                     );
                --
         ELSE
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => gr_parameters.assignment_set_id
                                                                              ,p_assignment_id     => lr_emp_assignment_det.assignment_id
                                                                              ,p_effective_date    => NVL(lr_emp_assignment_det.actual_termination_date,gr_parameters.effective_date) -- #Bug No 9508028
                                                                              ,p_populate_fs_flag  => 'Y'  -- #Bug No 9508028
                                                                              );
              IF gb_debug THEN
                  hr_utility.set_location('lc_include_flag after check.= '||lc_include_flag ,20);
              END IF;
              --
              IF lc_include_flag = 'Y' THEN

                --
                OPEN  lcu_next_action_id;
                FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                CLOSE lcu_next_action_id;

                -- Create the archive assignment actions
                hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                     );
               --
             END IF;
         END IF;
         --
         lc_include_flag := NULL; -- #Bug No 9508028

        --
      END LOOP;
      --
      END IF;
      --
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END assignment_action_code;
  --
  PROCEDURE archive_code ( p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%type
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
  CURSOR lcu_employee_details ( p_assignment_id     per_all_assignments_f.assignment_id%TYPE
                              , p_effective_date    DATE
                              )
  IS
  SELECT  PPF.person_id                                            person_id
         ,PPF.employee_number                                      employee_number
         ,PPF.first_name                                           first_name_kana
         ,PPF.last_name                                            last_name_kana
         ,PPF.per_information19                                    first_name_kanji
         ,PPF.per_information18                                    last_name_kanji
         ,PPS.date_start                                           hire_date
         ,PPS.actual_termination_date                              termination_date
         ,PAF.assignment_id                                        assignment_id
         ,PAF.payroll_id                                           payroll_id
         ,get_with_hold_agent(p_assignment_id,NVL(PPS.actual_termination_date,p_effective_date))    withhold_agent_id
         ,DECODE(PADR.address_id,NULL,PADC.town_or_city,PADR.town_or_city)                      district_code
         ,DECODE(PADR.address_id,NULL,PADC.address_line1 ,PADR.address_line1)                    address_line1
         ,DECODE(PADR.address_id,NULL,PADC.address_line2 ,PADR.address_line2)                    address_line2
         ,DECODE(PADR.address_id,NULL,PADC.address_line3 ,PADR.address_line3)                    address_line3
  FROM   per_people_f                    PPF
       , per_assignments_f               PAF
       , per_periods_of_service          PPS
       , per_addresses                   PADR
       , per_addresses                   PADC
  WHERE  PAF.person_id                     = PPF.person_id
  AND    PPS.person_id                     = PPF.person_id
  AND    PAF.assignment_id                 =  p_assignment_id
  AND    PADR.person_id(+)                   = PPF.person_id
  AND    PADR.address_type(+)                = 'JP_R'
  AND    TRUNC(p_effective_date)   BETWEEN TRUNC(NVL(PADR.date_from(+),p_effective_date)) AND NVL(PADR.date_to(+),TO_DATE('31/12/4712','DD/MM/YYYY')) --bug #9554515
  AND    PADC.person_id(+)                    = PPF.person_id
  AND    PADC.address_type(+)                = 'JP_C'
  AND    TRUNC(p_effective_date)   BETWEEN  TRUNC(NVL(PADC.date_from(+),p_effective_date)) AND NVL(PADC.date_to(+),TO_DATE('31/12/4712','DD/MM/YYYY')) --bug #9554515
  AND    PPS.period_of_service_id = NVL(PAF.period_of_service_id,PPS.period_of_service_id) -- #Bug 9569078
  AND    EXISTS(SELECT 1
	   FROM	pay_jp_pre_tax		PPT,
		      pay_assignment_actions	PAA,
		      pay_payroll_actions	PPA
	  WHERE PPA.effective_date BETWEEN gd_ystart_date AND gd_yend_date
        AND   PAA.assignment_id  = PAF.assignment_id
	  AND	PPA.action_type in ('R', 'Q', 'B', 'I')
	  AND	PAA.payroll_action_id = PPA.payroll_action_id
	  AND	PAA.action_status = 'C'
	  AND	PPT.assignment_action_id = PAA.assignment_action_id
	  AND	PPT.action_status = 'C'
	  AND	PPT.salary_category = 'TERM'
	  AND TRUNC(NVL(PPS.actual_termination_date,PPA.effective_date))  BETWEEN PPF.effective_start_date  AND PPF.effective_end_date
        AND TRUNC(NVL(PPS.actual_termination_date,PPA.effective_date))  BETWEEN PAF.effective_start_date  AND PAF.effective_end_date
	  AND	NOT EXISTS(
			SELECT	null
			FROM	pay_payroll_actions	PPAV,
				pay_assignment_actions	PAAV,
				pay_action_interlocks	PAI
			WHERE	PAI.locked_action_id = PAA.assignment_action_id
                  AND	PAAV.assignment_action_id = PAI.locking_action_id
			AND	PPAV.payroll_action_id = PAAV.payroll_action_id
			AND	PPAV.action_type = 'V'))
  ORDER BY PAF.assignment_id,PPF.effective_start_date;
  --
  CURSOR lcu_swot_details(p_itax_organization_id  NUMBER)
  IS
  SELECT	 HOI.org_information1
            ,HOI.org_information6
            ,HOI.org_information7
            ,HOI.org_information8
		,HOI.org_information12
  FROM	hr_all_organization_units	HOU,
		hr_organization_information	HOI
  WHERE	HOU.organization_id = p_itax_organization_id
  AND     HOI.organization_id(+) = hou.organization_id
  AND	HOI.org_information_context(+) = 'JP_TAX_SWOT_INFO';
  --
  CURSOR lcu_address_details(p_person_id       NUMBER
                            ,p_effective_date  DATE)
  IS
  SELECT    PAD.town_or_city                                      jan_1st_district_code
           ,PAD.address_line1                                     jan_1st_address_line1
           ,PAD.address_line2                                     jan_1st_address_line2
           ,PAD.address_line3                                     jan_1st_address_line3
  FROM   per_addresses                   PAD
  WHERE  PAD.person_id                  = p_person_id
  AND    ((PAD.address_type               = 'JP_R')
           OR
          (PAD.address_type              = 'JP_C'))
  AND    p_effective_date BETWEEN NVL(PAD.date_from,p_effective_date) AND NVL(PAD.date_to,TO_DATE('31/12/4712','DD/MM/YYYY'));
  --
  CURSOR lcu_tax_details(p_assignment_id NUMBER
                        ,p_business_group_id NUMBER)
  IS
  SELECT	NVL(sum(ppt.taxable_sal_amt + ppt.taxable_mat_amt), 0)   termination_money
	     ,NVL(sum(ppt.itax), 0)                                    withholding_tax
           ,NVL(sum(ppt.sp_ltax_shi), 0)                             muncipal_tax 	  -- Bug 9525922
           ,NVL(sum(ppt.sp_ltax_to), 0)                              prefectural_tax  -- Bug 9525922
  FROM	pay_jp_pre_tax		PPT,
		pay_assignment_actions	PAA,
		pay_payroll_actions	PPA
  WHERE PPA.effective_date BETWEEN gd_ystart_date AND gd_yend_date
  AND   PPA.business_group_id + 0 = p_business_group_id
  AND   PAA.assignment_id         = p_assignment_id
  AND   PPA.action_type in ('R', 'Q', 'B', 'I')
  AND	  PAA.payroll_action_id = PPA.payroll_action_id
  AND   PAA.action_status = 'C'
  AND   PPT.assignment_action_id = PAA.assignment_action_id
  AND   PPT.action_status = 'C'
  AND   PPT.salary_category = 'TERM'
  AND   NOT EXISTS(
			SELECT	null
			FROM	pay_payroll_actions	PPAV,
				pay_assignment_actions	PAAV,
				pay_action_interlocks	PAI
			WHERE	PAI.locked_action_id = PAA.assignment_action_id
			AND	PAAV.assignment_action_id = PAI.locking_action_id
			AND	PPAV.payroll_action_id = PAAV.payroll_action_id
			AND   PPAV.action_type = 'V');
  --
  CURSOR lcu_assact_details(p_assignment_id     NUMBER
                           ,p_business_group_id NUMBER)
  IS
  SELECT	PAA.assignment_action_id
           ,PPA.effective_date
           ,PPA.date_earned
  FROM	pay_jp_pre_tax		PPT,
		pay_assignment_actions	PAA,
		pay_payroll_actions	PPA
  WHERE PPA.effective_date BETWEEN gd_ystart_date AND gd_yend_date
  AND   PPA.business_group_id + 0 = p_business_group_id
  AND   PAA.assignment_id         = p_assignment_id
  AND   PPA.action_type in ('R', 'Q', 'B', 'I')
  AND	  PAA.payroll_action_id = PPA.payroll_action_id
  AND   PAA.action_status = 'C'
  AND   PPT.assignment_action_id = PAA.assignment_action_id
  AND   PPT.action_status = 'C'
  AND   PPT.salary_category = 'TERM'
  AND   NOT EXISTS(
			SELECT	null
			FROM	pay_payroll_actions	PPAV,
				pay_assignment_actions	PAAV,
				pay_action_interlocks	PAI
			WHERE	PAI.locked_action_id = PAA.assignment_action_id
			AND	PAAV.assignment_action_id = PAI.locking_action_id
			AND	PPAV.payroll_action_id = PAAV.payroll_action_id
			AND   PPAV.action_type = 'V');
  --
  CURSOR lcu_get_bal_id
  IS
  SELECT PDB.defined_balance_id
  FROM   pay_balance_types      PBT
        ,pay_balance_dimensions PBD
        ,pay_defined_balances   PDB
  WHERE   PBT.balance_name         = 'B_TRM_INCOME_EXM'
  AND     PBD.database_item_suffix = '_ASG_RUN'
  AND     PBT.balance_type_id      = PDB.balance_type_id
  AND     PBD.balance_dimension_id = PDB.balance_dimension_id;
  --
  CURSOR lcu_prev_archive (p_assignment_id     per_all_assignments_f.assignment_id%TYPE)
  IS
  SELECT 'Y'
  FROM pay_action_information   PAI
      ,pay_assignment_actions   PAC
      ,pay_payroll_actions       PPA
  WHERE PAI.action_context_id = PAC.assignment_action_id
  AND   PAC.assignment_id     = p_assignment_id
  AND   PAC.payroll_action_id   = PPA.payroll_action_id
  AND   PAI.action_context_type = 'AAP'
  AND   PPA.report_type         = gc_report_type;
  --
  lc_procedure                  VARCHAR2(200);
  lc_swot_address_line1         VARCHAR2(150);
  lc_swot_address_line2         VARCHAR2(150);
  lc_swot_address_line3         VARCHAR2(150);
  lc_swot_phone_number          VARCHAR2(150);
  lc_swot_employer              VARCHAR2(150);
  lc_description1               pay_action_information.action_information23%TYPE;
  lc_description2               pay_action_information.action_information24%TYPE;
  lc_descfield                  pay_action_information.action_information23%TYPE;
  lc_descfield2                 pay_action_information.action_information23%TYPE;
  lc_descfield3                 pay_action_information.action_information23%TYPE;
  lc_descfield4                 pay_action_information.action_information24%TYPE;
  lc_descfield5                 pay_action_information.action_information24%TYPE;
  lc_1st_jan_district_code      per_addresses.town_or_city%TYPE;
  lc_1st_jan_address_line1      per_addresses.address_line1%TYPE;
  lc_1st_jan_address_line2      per_addresses.address_line2%TYPE;
  lc_1st_jan_address_line3      per_addresses.address_line3%TYPE;
  lc_note_submit_flag           VARCHAR2(10);
  lc_archive                    VARCHAR2(10) DEFAULT 'N';
  lc_check_flag                 VARCHAR2(10) DEFAULT 'N';
  --
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_tax_action_info_id         pay_action_information.action_information_id%TYPE;
  ln_tax_obj_version_num        pay_action_information.object_version_number%TYPE;
  ln_assignment_id              per_all_assignments_f.assignment_id%TYPE;
  ln_service_years              NUMBER;
  ln_termination_money          NUMBER;
  ln_withholidng_tax            NUMBER;
  ln_muncipal_tax               NUMBER;
  ln_prefectural_tax            NUMBER;
  ln_def_balance_id             pay_defined_balances.defined_balance_id%TYPE;
  ln_term_ded_amt               NUMBER;
  ln_amt                        NUMBER;
  ln_term_ass_act_id            pay_assignment_actions.assignment_action_id%TYPE;
  --
  ld_term_payment_date          pay_payroll_actions.effective_date%TYPE;
  ld_date_earned                pay_payroll_actions.date_earned%TYPE;
  ld_start_date                 DATE;
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
    --
    -- Fetch the Assignemnt Id
    --
    OPEN  lcu_get_assignment_id(p_assignment_action_id);
    FETCH lcu_get_assignment_id INTO ln_assignment_id;
    CLOSE lcu_get_assignment_id;
    --
    OPEN  lcu_get_bal_id;
    FETCH lcu_get_bal_id INTO ln_def_balance_id;
    CLOSE lcu_get_bal_id;
    --
    IF (gr_parameters.rearchive_flag = 'Y') THEN
      --
      delete_assact(ln_assignment_id);
      lc_archive := 'Y';
      --
    ELSE
      --
      --  Checking whether record exists for this assignment
      --
      OPEN  lcu_prev_archive(ln_assignment_id);
      FETCH lcu_prev_archive INTO lc_check_flag;
      CLOSE lcu_prev_archive;
      --
      IF lc_check_flag = 'Y' THEN
         --
         lc_archive := 'N';
         --
      ELSE
        --
        lc_archive := 'Y';
        --
      END IF;
      --
    END IF;
    --
    IF lc_archive = 'Y' THEN
    --
    FOR lr_emp_rec  IN lcu_employee_details(ln_assignment_id,gr_parameters.effective_date)
    LOOP
    --
    --SWOT Details
    --
    IF gd_ystart_date >= TRUNC(lr_emp_rec.hire_date) THEN
      ld_start_date:= gd_ystart_date;
    ELSE
      ld_start_date:= TRUNC(lr_emp_rec.hire_date);
    END IF;
    --
    OPEN  lcu_swot_details(lr_emp_rec.withhold_agent_id);
    FETCH lcu_swot_details INTO lc_swot_employer
                               ,lc_swot_address_line1
                               ,lc_swot_address_line2
                               ,lc_swot_address_line3
                               ,lc_swot_phone_number;
    CLOSE lcu_swot_details;
    --
    OPEN  lcu_address_details(lr_emp_rec.person_id
                             ,ld_start_date);
    FETCH lcu_address_details INTO lc_1st_jan_district_code
                               ,lc_1st_jan_address_line1
                               ,lc_1st_jan_address_line2
                               ,lc_1st_jan_address_line3;
    CLOSE lcu_address_details;
    --
    FOR lr_get_assact_bal IN lcu_assact_details(lr_emp_rec.assignment_id
                                               ,gr_parameters.business_group_id
                                                 )
    LOOP
          ln_amt := pay_jp_balance_pkg.get_balance_value(ln_def_balance_id,lr_get_assact_bal.assignment_action_id);
          IF ln_amt IS NOT NULL THEN
            ln_term_ded_amt:= NVL(ln_term_ded_amt,0) + NVL(ln_amt,0);
            ln_term_ass_act_id   := lr_get_assact_bal.assignment_action_id;
            ld_term_payment_date := lr_get_assact_bal.effective_date;
            ld_date_earned       := lr_get_assact_bal.date_earned;
          END IF;
    END LOOP;
    --
    -- Fetching service years
    --
    ln_service_years   := pay_jp_balance_pkg.get_result_value_number('TRM_INCOME_DCT','SERVICE_YEARS',ln_term_ass_act_id);
    --
    -- Fetching Notification Flag
    --
    lc_note_submit_flag := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_INFO','SUBMIT_FLAG',lr_emp_rec.assignment_id,ld_date_earned);
    --
    -- Fetching Term_ Withholding Tax Report Infromation
    --
    IF gb_debug THEN
      --
      hr_utility.set_location('Date Earned = ' || ld_date_earned,10);
      --
    END IF;
    --
    lc_descfield  :=  pay_jp_balance_pkg.get_entry_value_char('TRM_WITHHOLD_TAX_REPORT_INFO','DESC_FIELD',lr_emp_rec.assignment_id,ld_date_earned);  --Bug 9509191
    lc_descfield2 :=  pay_jp_balance_pkg.get_entry_value_char('TRM_WITHHOLD_TAX_REPORT_INFO','DESC_FIELD2',lr_emp_rec.assignment_id,ld_date_earned);
    lc_descfield3 :=  pay_jp_balance_pkg.get_entry_value_char('TRM_WITHHOLD_TAX_REPORT_INFO','DESC_FIELD3',lr_emp_rec.assignment_id,ld_date_earned);
    lc_descfield4 :=  pay_jp_balance_pkg.get_entry_value_char('TRM_WITHHOLD_TAX_REPORT_INFO','DESC_FIELD4',lr_emp_rec.assignment_id,ld_date_earned);
    lc_descfield5 :=  pay_jp_balance_pkg.get_entry_value_char('TRM_WITHHOLD_TAX_REPORT_INFO','DESC_FIELD5',lr_emp_rec.assignment_id,ld_date_earned); --Bug 9509191
    --
    lc_description1 := lc_descfield || lc_descfield2 || lc_descfield3;
    lc_description2 := lc_descfield4 || lc_descfield5;
    --
    --JP_IWHT_EMP Info
    --
    pay_action_information_api.create_action_information
      (
        p_validate                       => FALSE
       ,p_action_context_id              => p_assignment_action_id
       ,p_action_context_type            => 'AAP'
       ,p_action_information_category    => 'JP_IWHT_EMP'
       ,p_tax_unit_id                    => NULL
       ,p_jurisdiction_code              => NULL
       ,p_source_id                      => NULL
       ,p_source_text                    => NULL
       ,p_tax_group                      => NULL
       ,p_effective_date                 => p_effective_date
       ,p_assignment_id                  => fnd_number.number_to_canonical(lr_emp_rec.assignment_id)
       ,p_action_information1            => lr_emp_rec.employee_number
       ,p_action_information2            => lr_emp_rec.last_name_kana
       ,p_action_information3            => lr_emp_rec.first_name_kana
       ,p_action_information4            => lr_emp_rec.last_name_kanji
       ,p_action_information5            => lr_emp_rec.first_name_kanji
       ,p_action_information6            => lr_emp_rec.district_code
       ,p_action_information7            => lr_emp_rec.address_line1
       ,p_action_information8            => lr_emp_rec.address_line2
       ,p_action_information9            => lr_emp_rec.address_line3
       ,p_action_information10           => lc_1st_jan_district_code
       ,p_action_information11           => lc_1st_jan_address_line1
       ,p_action_information12           => lc_1st_jan_address_line2
       ,p_action_information13           => lc_1st_jan_address_line3
       ,p_action_information14           => fnd_date.date_to_canonical(lr_emp_rec.hire_date)
       ,p_action_information15           => fnd_date.date_to_canonical(lr_emp_rec.termination_date)
       ,p_action_information16           => ln_service_years
       ,p_action_information17           => lr_emp_rec.withhold_agent_id
       ,p_action_information18           => lc_swot_employer
       ,p_action_information19           => lc_swot_address_line1
       ,p_action_information20           => lc_swot_address_line2
       ,p_action_information21           => lc_swot_address_line3
       ,p_action_information22           => lc_swot_phone_number
       ,p_action_information23           => lc_description1
       ,p_action_information24           => lc_description2
       ,p_action_information_id          => ln_action_info_id
       ,p_object_version_number          => ln_obj_version_num
       );
       --
       lc_1st_jan_district_code := NULL;
       lc_1st_jan_address_line1 := NULL;
       lc_1st_jan_address_line2 := NULL;
       lc_1st_jan_address_line3 := NULL;
       --
       -- JP_IWHT_TAX Info ---------------
       --
       OPEN  lcu_tax_details(lr_emp_rec.assignment_id,gr_parameters.business_group_id);
       FETCH lcu_tax_details INTO   ln_termination_money
                                   ,ln_withholidng_tax
                                   ,ln_muncipal_tax
                                   ,ln_prefectural_tax;
       CLOSE lcu_tax_details;
       --
       pay_action_information_api.create_action_information
      (
        p_validate                       => FALSE
       ,p_action_context_id              => p_assignment_action_id
       ,p_action_context_type            => 'AAP'
       ,p_action_information_category    => 'JP_IWHT_TAX'
       ,p_tax_unit_id                    => NULL
       ,p_jurisdiction_code              => NULL
       ,p_source_id                      => NULL
       ,p_source_text                    => NULL
       ,p_tax_group                      => NULL
       ,p_effective_date                 => p_effective_date
       ,p_assignment_id                  => fnd_number.number_to_canonical(lr_emp_rec.assignment_id)
       ,p_action_information1            => NVL(lc_note_submit_flag,'N')
       ,p_action_information2            => fnd_number.number_to_canonical(ln_termination_money)
       ,p_action_information3            => fnd_number.number_to_canonical(ln_withholidng_tax)
       ,p_action_information4            => fnd_number.number_to_canonical(ln_muncipal_tax)
       ,p_action_information5            => fnd_number.number_to_canonical(ln_prefectural_tax)
       ,p_action_information6            => fnd_number.number_to_canonical(ln_term_ded_amt)
       ,p_action_information7            => fnd_date.date_to_canonical(ld_term_payment_date)
       ,p_action_information8            => fnd_date.date_to_canonical(ld_date_earned)
       ,p_action_information_id          => ln_tax_action_info_id
       ,p_object_version_number          => ln_tax_obj_version_num
       );
      --
      --END OF JP_IWHT_TAX Info ---------------
      --
        ln_termination_money  :=  NULL;
        ln_withholidng_tax    :=  NULL;
        ln_muncipal_tax       :=  NULL;
        ln_prefectural_tax    :=  NULL;
        ln_term_ass_act_id    :=  NULL;
        ld_term_payment_date  :=  NULL;
        ld_date_earned        :=  NULL;
        lc_archive            := 'N';
    --
    END LOOP;
    --
    END IF;
    --
    IF gb_debug THEN
      --
       hr_utility.set_location('Leaving ' || lc_procedure,10);
      --
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    --
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END archive_code;
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
       ,pay_payroll_actions     PPA
  WHERE PAA.payroll_action_id = PPA.payroll_action_id
  AND   PAA.action_status     = 'C'
  AND   PPA.report_type   = gc_report_type
  AND   NOT EXISTS( SELECT NULL
                    FROM    pay_action_information  PAI
                    WHERE   PAI.action_context_id = PAA.assignment_action_id
                    AND     PAI.action_context_type = 'AAP');

  --
  lc_proc                 CONSTANT VARCHAR2(61) := gc_package || 'deinitialise_code';
  --
BEGIN
  --
    gb_debug := hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
           hr_utility.set_location('Entering: ' || lc_proc, 10);
    END IF;
    --
    FOR l_rec IN lcu_assacts LOOP
                py_rollback_pkg.rollback_ass_action(l_rec.assignment_action_id);
    END LOOP;
    --
    IF gb_debug THEN
      --
      hr_utility.set_location('Leaving ' || lc_proc,20);
      --
    END IF;
    --
END deinitialize_code;
--
END pay_jp_iwht_arch_pkg;

/
