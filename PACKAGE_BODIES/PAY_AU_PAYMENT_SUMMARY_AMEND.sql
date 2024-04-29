--------------------------------------------------------
--  DDL for Package Body PAY_AU_PAYMENT_SUMMARY_AMEND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PAYMENT_SUMMARY_AMEND" AS
/* $Header: pyaupsam.pkb 120.0.12010000.3 2009/12/16 14:14:41 dduvvuri noship $*/
/*
*** -------------------------------------------------------------------------+
*** Program:     pay_au_payment_summary_amend (Package Body)
*** Description: Various procedures and functions to assist Amended
***              Payment Summary archival process and report
***
*** Change History
*** Date      Changed By  Version Description of Change
*** --------  ----------  ------- --------------------------------------------+
*** 08-Jan-08  avenkatk    115.0  6470581   Initial Version
*** 22-Jan-08  avenkatk    115.2  6470581   Changes made as per review comments
*** 23-Jan-08  avenkatk    115.3  6470581   Resolved GSCC Errors
*** 13-May-09  pmatamsr    115.4  8315198   Modified cursors csr_payg_items ,csr_etp_cmn_items
***                                         and get_archived_user_entities to include X_ETP_DEATH_BENEFIT_TFN
***                                         and X_LUMP_SUM_A_PAYMENT_TYPE DB items as part of Payment Summary
***                                         changes.
*** 11-Dec-09  dduvvuri    115.5  9113084   Added RANGE_PERSON_ID for Amended Payment Summary Archive.
*** --------------------------------------------------------------------------+
*/

g_debug             boolean;
g_business_group_id number;
g_package           constant varchar2(30) := 'pay_au_payment_summary_amend';
g_legislation_code  constant varchar2(2)  := 'AU';


TYPE char_tab_type IS TABLE OF ff_user_entities.user_entity_name%TYPE;

/* The following global tables store the User entity type of each DB Item */

g_payg_db_items char_tab_type;
g_etp1_db_items char_tab_type;
g_etp2_db_items char_tab_type;
g_etp3_db_items char_tab_type;
g_etp4_db_items char_tab_type;
g_etp_cmn_db_items char_tab_type;


/* The following variables hold the slotted DB Items */

l_cmn_tab_new archive_db_tab;
l_payg_tab_new archive_db_tab;
l_etp_cmn_tab_new archive_db_tab;
l_etp_1_tab_new archive_db_tab;
l_etp_2_tab_new archive_db_tab;
l_etp_3_tab_new archive_db_tab;
l_etp_4_tab_new archive_db_tab;
l_amend_types_new archive_db_tab;



/*
--------------------------------------------------------------------
    Name  : range_code
    Type  : Procedure
    Access: Public
    Description: This procedure returns a sql string to
                 select a range of assignments eligible for archival.
  --------------------------------------------------------------------
*/

PROCEDURE range_code
        (p_payroll_action_id   IN pay_payroll_actions.payroll_action_id%TYPE,
         p_sql                 OUT NOCOPY VARCHAR2)
IS
BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug
THEN
        hr_utility.set_location('Start of range_code    ',1);
END IF;

p_sql   := ' select distinct p.person_id'                                       ||
             ' from   per_people_f p,'                                        ||
                    ' pay_payroll_actions pa'                                     ||
             ' where  pa.payroll_action_id = :payroll_action_id'                  ||
             ' and    p.business_group_id = pa.business_group_id'                 ||
             ' order by p.person_id';

IF g_debug
THEN
        hr_utility.set_location('End of range_code',2);
END IF;
END range_code;

/*
    Bug 9113084 - Added Function range_person_on
--------------------------------------------------------------------
    Name  : range_person_on
    Type  : Function
    Access: Private
    Description: Checks if RANGE_PERSON_ID is enabled for
                 Archive process.
  --------------------------------------------------------------------
*/
FUNCTION range_person_on
RETURN BOOLEAN
IS

 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';

 CURSOR csr_range_format_param is
  select par.parameter_value
  from   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  where  map.report_format_mapping_id = par.report_format_mapping_id
  and    map.report_type = 'AU_PAY_SUMM_AMEND'
  and    map.report_format = 'AU_PAY_SUMM_AMEND'
  and    map.report_qualifier = 'AU'
  and    par.parameter_name = 'RANGE_PERSON_ID';

  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);

BEGIN

    g_debug := hr_utility.debug_enabled;

  BEGIN

    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;

    open csr_range_format_param;
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;

  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;
     IF g_debug THEN
           hr_utility.set_location('Range Person = True',1);
     END IF;
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;

/*
--------------------------------------------------------------------
    Name  : initialization_code
    Type  : Procedure
    Access: Public
    Description:  This procedure initializes global variables required
                  by Archive. The g_payment_summary_type parameters
                  is set to 'A'
  --------------------------------------------------------------------
*/

PROCEDURE initialization_code
        (p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE)
IS

l_procedure VARCHAR2(80);

BEGIN

g_debug := hr_utility.debug_enabled;
IF g_debug
THEN
    l_procedure     := g_package||'.initialization_code_amend';
    hr_utility.set_location('In Procedure   '||l_procedure,1000);
    END IF;

    pay_au_payment_summary.initialization_code(p_payroll_action_id);
    pay_au_payment_summary.g_payment_summary_type   := 'A'; /*Reset the Payment Summary Type Variable */
    populate_user_entity_types;                             /* Initialize the DB Item Types */

IF g_debug
THEN
    hr_utility.set_location('Leaving Procedure   '||l_procedure,1000);
END IF;

EXCEPTION
WHEN others THEN
IF g_debug THEN
    hr_utility.set_location('Error in initialization_code',1000);
END IF;
raise;
END initialization_code;


/*
--------------------------------------------------------------------
Name  : assignment_action_code
Type  : Procedure
Access: Public
Description:This procedure further restricts the assignment_id's
            returned by range_code.
            The procedure uses the Assignment ID or Assignment Set ID
            parameter and restricts assignments to be archived
            it then calls hr_nonrun.insact to create an assignment action id
  --------------------------------------------------------------------
*/

PROCEDURE assignment_action_code
    (p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE,
     p_start_person_id    IN per_all_people_f.person_id%TYPE,
     p_end_person_id      IN per_all_people_f.person_id%TYPE,
     p_chunk              IN NUMBER)
IS

v_next_action_id  pay_assignment_actions.assignment_action_id%type;

v_lst_year_start       date ;
v_fbt_year_start       date ;
v_lst_fbt_year_start   date ;
v_fbt_year_end         date ;
v_fin_year_start       date ;
v_fin_year_end         date ;
v_assignment_id        varchar2(50);
v_registered_employer  varchar2(50);
v_financial_year       varchar2(50);
v_payroll_id           varchar2(50);
v_employee_type        varchar2(1);
v_asg_id               number;
v_reg_emp              number;
l_lst_yr_term          varchar(10);

v_assignment_set_id    VARCHAR2(50);

l_procedure            VARCHAR2(80);

CURSOR get_params(c_payroll_action_id  per_all_assignments_f.assignment_id%TYPE)
IS
SELECT   to_date('01-07-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') Financial_year_start
        ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),6,4),'DD-MM-YYYY') Financial_year_end
        ,to_date('01-04-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') FBT_year_start
        ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') FBT_year_end
        ,decode(pay_core_utils.get_parameter('EMPLOYEE_TYPE',legislative_parameters),'C','Y','T','N','B','%')   Employee_type
        ,pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters)                             Registered_Employer
        ,pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters)                                  Financial_year
        ,pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters)               Assignment_id
        ,decode(pay_core_utils.get_parameter('PAYROLL',legislative_parameters),NULL,'%',pay_core_utils.get_parameter('PAYROLL',legislative_parameters)) payroll_id
        ,pay_core_utils.get_parameter('LST_YR_TERM',legislative_parameters)              lst_yr_term    /*3661230*/
        ,pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters)               Business_group_id
        ,pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',legislative_parameters)               assignment_set_id
FROM  pay_payroll_actions
WHERE payroll_action_id = c_payroll_Action_id;

CURSOR process_assignments_only(c_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE
                           ,c_start_person_id    IN per_all_people_f.person_id%TYPE
                           ,c_end_person_id      IN per_all_people_f.person_id%TYPE
                           ,c_assignment_id      IN per_all_assignments_f.assignment_id%TYPE
                           ,c_financial_year     IN VARCHAR2
                           ,c_tax_unit_id        IN pay_assignment_actions.tax_unit_iD%TYPE)
IS
SELECT DISTINCT paf.assignment_id
FROM   per_assignments_f paf
      ,per_people_f      ppf
      ,pay_payroll_actions ppa
WHERE  ppa.payroll_action_id = c_payroll_action_id
AND    ppf.person_id  BETWEEN c_start_person_id AND c_end_person_id
AND    ppf.person_id         = paf.person_id
AND    paf.assignment_id     = c_assignment_id
AND    paf.business_group_id = ppa.business_group_id
AND    EXISTS
        ( /* Check if a Datafile is run for this year */
           SELECT '1'
           FROM  pay_payroll_actions ppa1
                ,pay_assignment_actions paa1
           WHERE ppa1.payroll_action_id = paa1.payroll_action_id
           AND   ppa1.report_type       = 'AU_PS_DATA_FILE'
           AND   ppa1.report_qualifier  = 'AU'
           AND   ppa1.report_category   = 'REPORT'
           AND   paa1.assignment_id     =  paf.assignment_id
           AND   pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa1.legislative_parameters) = c_financial_year
           AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER',ppa1.legislative_parameters) = c_tax_unit_id
           )
AND    NOT EXISTS
        ( /* Check if a locked Amended Payment Summary does not exist for this year */
        SELECT '1'
        FROM   pay_payroll_actions ppa2
              ,pay_assignment_actions paa2
              ,pay_action_interlocks pai
        WHERE   ppa2.payroll_action_id = paa2.payroll_action_id
          AND   ppa2.report_type       = 'AU_PAY_SUMM_AMEND'
          AND   ppa2.report_qualifier  = 'AU'
          AND   ppa2.report_category   = 'REPORT'
          AND   pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa2.legislative_parameters) = c_financial_year
          AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER',ppa2.legislative_parameters) = c_tax_unit_id
          AND   paa2.assignment_id      = paf.assignment_id
          AND   pai.locked_action_id   = paa2.assignment_action_id
        );


CURSOR process_assignments(c_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE
                           ,c_start_person_id    IN per_all_people_f.person_id%TYPE
                           ,c_end_person_id      IN per_all_people_f.person_id%TYPE
                           ,c_assignment_set_id  IN NUMBER
                           ,c_financial_year     IN VARCHAR2
                           ,c_tax_unit_id        IN pay_assignment_actions.tax_unit_iD%TYPE)
IS
SELECT DISTINCT paf.assignment_id
FROM   per_assignments_f paf
      ,per_people_f      ppf
      ,pay_payroll_actions ppa
      ,hr_assignment_set_amendments  has
WHERE  ppa.payroll_action_id = c_payroll_action_id
AND    ppf.person_id  BETWEEN c_start_person_id AND c_end_person_id
AND    ppf.person_id         = paf.person_id
AND    paf.assignment_id     = has.assignment_id
AND    has.assignment_set_id  = c_assignment_set_id
AND    upper(has.include_or_exclude) = 'I'
AND    paf.business_group_id = ppa.business_group_id
AND    EXISTS
        ( /* Check if a Datafile is run for this year */
           SELECT '1'
           FROM  pay_payroll_actions ppa1
                ,pay_assignment_actions paa1
           WHERE ppa1.payroll_action_id = paa1.payroll_action_id
           AND   ppa1.report_type       = 'AU_PS_DATA_FILE'
           AND   ppa1.report_qualifier  = 'AU'
           AND   ppa1.report_category   = 'REPORT'
           AND   paa1.assignment_id     =  paf.assignment_id
           AND   pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa1.legislative_parameters) = c_financial_year
           AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER',ppa1.legislative_parameters) = c_tax_unit_id
           )
AND    NOT EXISTS
        ( /* Check if a locked Amended Payment Summary does not exist for this year */
        SELECT '1'
        FROM   pay_payroll_actions ppa2
              ,pay_assignment_actions paa2
              ,pay_action_interlocks pai
        WHERE   ppa2.payroll_action_id = paa2.payroll_action_id
          AND   ppa2.report_type       = 'AU_PAY_SUMM_AMEND'
          AND   ppa2.report_qualifier  = 'AU'
          AND   ppa2.report_category   = 'REPORT'
          AND   pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa2.legislative_parameters) = c_financial_year
          AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER',ppa2.legislative_parameters) = c_tax_unit_id
          AND   paa2.assignment_id      = paf.assignment_id
          AND   pai.locked_action_id    = paa2.assignment_action_id
        );

/* 9113084 - Added range person cursor for the above CURSOR process_assignments */
/* 9113084 - Cursor fetches the assignments for Amended Payment Summary Archive when RANGE_PERSON_ID is enabled */
CURSOR range_process_assignments(c_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE
                           , c_chunk IN NUMBER
                           ,c_assignment_set_id  IN NUMBER
                           ,c_financial_year     IN VARCHAR2
                           ,c_tax_unit_id        IN pay_assignment_actions.tax_unit_iD%TYPE)
IS
SELECT DISTINCT paf.assignment_id
FROM   per_assignments_f paf
      ,per_people_f      ppf
      ,pay_payroll_actions ppa
      ,hr_assignment_set_amendments  has
      ,pay_population_ranges ppr
WHERE  ppa.payroll_action_id = c_payroll_action_id
AND    ppr.payroll_action_id = ppa.payroll_action_id
AND    ppr.chunk_number = c_chunk
AND    ppf.person_id  = ppr.person_id
AND    ppf.person_id         = paf.person_id
AND    paf.assignment_id     = has.assignment_id
AND    has.assignment_set_id  = c_assignment_set_id
AND    upper(has.include_or_exclude) = 'I'
AND    paf.business_group_id = ppa.business_group_id
AND    EXISTS
        ( /* Check if a Datafile is run for this year */
           SELECT '1'
           FROM  pay_payroll_actions ppa1
                ,pay_assignment_actions paa1
           WHERE ppa1.payroll_action_id = paa1.payroll_action_id
           AND   ppa1.report_type       = 'AU_PS_DATA_FILE'
           AND   ppa1.report_qualifier  = 'AU'
           AND   ppa1.report_category   = 'REPORT'
           AND   paa1.assignment_id     =  paf.assignment_id
           AND   pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa1.legislative_parameters) = c_financial_year
           AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER',ppa1.legislative_parameters) = c_tax_unit_id
           )
AND    NOT EXISTS
        ( /* Check if a locked Amended Payment Summary does not exist for this year */
        SELECT '1'
        FROM   pay_payroll_actions ppa2
              ,pay_assignment_actions paa2
              ,pay_action_interlocks pai
        WHERE   ppa2.payroll_action_id = paa2.payroll_action_id
          AND   ppa2.report_type       = 'AU_PAY_SUMM_AMEND'
          AND   ppa2.report_qualifier  = 'AU'
          AND   ppa2.report_category   = 'REPORT'
          AND   pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa2.legislative_parameters) = c_financial_year
          AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER',ppa2.legislative_parameters) = c_tax_unit_id
          AND   paa2.assignment_id      = paf.assignment_id
          AND   pai.locked_action_id    = paa2.assignment_action_id
        );


CURSOR   next_action_id
IS
SELECT pay_assignment_actions_s.nextval
FROM  dual;

BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug
THEN
    l_procedure     := g_package||'.assignment_action_coded';
    hr_utility.set_location('In Procedure   '||l_procedure,1020);
END IF;

/* Get the paramters for archival process */
OPEN   get_params(p_payroll_action_id);
FETCH  get_params
INTO      v_fin_year_start
         ,v_fin_year_end
         ,v_fbt_year_start
         ,v_fbt_year_end
         ,v_employee_type
         ,v_registered_employer
         ,v_financial_year
         ,v_assignment_id
         ,v_payroll_id
         ,l_lst_yr_term
         ,g_business_group_id
         ,v_assignment_set_id;
CLOSE get_params;

v_reg_emp := to_number(v_registered_employer);

IF g_debug
THEN
    hr_utility.set_location('p_payroll_action_id       '||p_payroll_action_id,1030);
    hr_utility.set_location('p_start_person_id         '||p_start_person_id,1030);
    hr_utility.set_location('p_end_person_id           '||p_end_person_id,1030);
    hr_utility.set_location('v_assignment_set_id       '||to_number(v_assignment_set_id),1030);
    hr_utility.set_location('v_financial_year          '||v_financial_year,1030);
    hr_utility.set_location('v_assignment_id           '||v_assignment_id,1030);
    hr_utility.set_location('v_reg_emp                 '||v_reg_emp,1030);
END IF;

IF v_assignment_id IS NOT NULL
THEN
        FOR csr_rec IN process_assignments_only(p_payroll_action_id
                                               ,p_start_person_id
                                               ,p_end_person_id
                                               ,to_number(v_assignment_id)
                                               ,v_financial_year
                                               ,v_reg_emp)
        LOOP
                OPEN next_action_id;
                FETCH next_action_id INTO v_next_action_id;
                CLOSE next_action_id;

                hr_nonrun_asact.insact(v_next_action_id,
                                       csr_rec.assignment_id,
                                       p_payroll_action_id,
                                       p_chunk,
                                       NULL);

        END LOOP;
ELSIF v_assignment_set_id IS NOT NULL
THEN

     IF range_person_on THEN /* 9113084 - Use new Range Person Cursor if Range Person is enabled */
           IF g_debug THEN
	       hr_utility.set_location('Using Range Person Cursor for fetching assignments ', 5);
           END IF;
        FOR csr_rec IN range_process_assignments(p_payroll_action_id
                                          ,p_chunk
                                          ,to_number(v_assignment_set_id)
                                          ,v_financial_year
                                          ,v_reg_emp)
        LOOP
                OPEN next_action_id;
                FETCH next_action_id INTO v_next_action_id;
                CLOSE next_action_id;

                hr_nonrun_asact.insact(v_next_action_id,
                                       csr_rec.assignment_id,
                                       p_payroll_action_id,
                                       p_chunk,
                                       NULL);
        END LOOP;
     ELSE  /* 9113084 - Old Logic to be used when Range Person is disabled */

        FOR csr_rec IN process_assignments(p_payroll_action_id
                                          ,p_start_person_id
                                          ,p_end_person_id
                                          ,to_number(v_assignment_set_id)
                                          ,v_financial_year
                                          ,v_reg_emp)
        LOOP
                OPEN next_action_id;
                FETCH next_action_id INTO v_next_action_id;
                CLOSE next_action_id;

                hr_nonrun_asact.insact(v_next_action_id,
                                       csr_rec.assignment_id,
                                       p_payroll_action_id,
                                       p_chunk,
                                       NULL);
        END LOOP;
     END IF;

END IF;

IF g_debug THEN
    hr_utility.set_location('Leaving  '||l_procedure,1040);
END IF;

EXCEPTION
WHEN others THEN
IF g_debug THEN
    hr_utility.set_location('Error raised in assignment_action_code_amend procedure ',1050);
END IF;
raise;
END assignment_action_code;


/*
--------------------------------------------------------------------
Name  : populate_user_entity_types
Type  : Procedure
Access: Public
Description:This procedure populates the Global PL/SQL table with
            the User Entity type of all shipped DB items.
            PAYG        - PAYG Record
            ETP_CMN     - Common data reported in all ETP records
            ETP1        - Transtional (Y), Part of Prev Term (Y) ETP Record
            ETP2        - Transtional (Y), Part of Prev Term (N) ETP Record
            ETP3        - Transtional (N), Part of Prev Term (Y) ETP Record
            ETP4        - Transtional (N), Part of Prev Term (N) ETP Record
--------------------------------------------------------------------
*/

/*Bug 8315198 - Modified cursor csr_payg_items to include X_LUMP_SUM_A_PAYMENT_TYPE DB item for Amended archive process*/

PROCEDURE populate_user_entity_types
IS

CURSOR csr_payg_items
IS
SELECT user_entity_name
FROM  ff_user_entities
WHERE legislation_code = 'AU'
AND (  user_entity_name LIKE 'X_ALLOWANCE%'
        OR user_entity_name LIKE 'X_EMPLOYEE%DATE%'
        OR user_entity_name LIKE 'X_UNION%'
        OR user_entity_name LIKE 'X_%ASG_YTD'
        OR user_entity_name IN ('X_EMPLOYEE_TAX_FILE_NUMBER')
	OR user_entity_name IN ('X_LUMP_SUM_A_PAYMENT_TYPE')
        )
AND user_entity_name NOT LIKE 'X_%83%_ASG_YTD'
AND user_entity_name NOT LIKE 'X_%TRANS%_ASG_YTD'
AND user_entity_name NOT IN ('X_LUMP_SUM_C_PAYMENTS_ASG_YTD','X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD','X_INVALIDITY_PAYMENTS_ASG_YTD');


CURSOR csr_etp1_items
IS
SELECT user_entity_name
FROM  ff_user_entities
WHERE legislation_code = 'AU'
AND    user_entity_name IN
( 'X_ETP_DED_TRANS_PPTERM_ASG_YTD','X_INV_PAY_TRANS_PPTERM_ASG_YTD'
 ,'X_POST_JUN_83_TAXED_TRANS_PPTERM_ASG_YTD','X_PRE_JUL_83_COMP_TRANS_PPTERM_ASG_YTD');

CURSOR csr_etp2_items
IS
SELECT user_entity_name
FROM  ff_user_entities
WHERE legislation_code = 'AU'
AND    user_entity_name IN
( 'X_ETP_DED_TRANS_NOT_PPTERM_ASG_YTD','X_INV_PAY_TRANS_NOT_PPTERM_ASG_YTD'
 ,'X_POST_JUN_83_TAXED_TRANS_NOT_PPTERM_ASG_YTD','X_PRE_JUL_83_COMP_TRANS_NOT_PPTERM_ASG_YTD');

CURSOR csr_etp3_items
IS
SELECT user_entity_name
FROM  ff_user_entities
WHERE legislation_code = 'AU'
AND    user_entity_name IN
( 'X_ETP_DED_NOT_TRANS_PPTERM_ASG_YTD','X_INV_PAY_NOT_TRANS_PPTERM_ASG_YTD'
,'X_POST_JUN_83_TAXED_NOT_TRANS_PPTERM_ASG_YTD','X_PRE_JUL_83_COMP_NOT_TRANS_PPTERM_ASG_YTD');

CURSOR csr_etp4_items
IS
SELECT user_entity_name
FROM  ff_user_entities
WHERE legislation_code = 'AU'
AND    user_entity_name IN
( 'X_ETP_DED_NOT_TRANS_NOT_PPTERM_ASG_YTD','X_INV_PAY_NOT_TRANS_NOT_PPTERM_ASG_YTD'
 ,'X_POST_JUN_83_TAXED_NOT_TRANS_NOT_PPTERM_ASG_YTD','X_PRE_JUL_83_COMP_NOT_TRANS_NOT_PPTERM_ASG_YTD');

/*Bug 8315198 - Modified cursor csr_etp_cmn_items to include X_ETP_DEATH_BENEFIT_TFN DB item for Amended archive process*/

CURSOR csr_etp_cmn_items
IS
SELECT user_entity_name
FROM  ff_user_entities
WHERE legislation_code = 'AU'
AND (  user_entity_name LIKE 'X_ETP%DATE%'
      OR user_entity_name LIKE 'X_DAYS%'
      OR user_entity_name IN ('X_ETP_TAX_FILE_NUMBER')
      OR user_entity_name IN ('X_ETP_DEATH_BENEFIT_TFN')
       );

l_procedure     VARCHAR2(200);

BEGIN

        g_debug := hr_utility.debug_enabled;
        IF g_debug
        THEN
                l_procedure     := g_package||'.populate_user_entity_types';
                hr_utility.set_location('Entering Procedure     '||l_procedure,2400);
        END IF;

        OPEN csr_payg_items;
        FETCH csr_payg_items BULK COLLECT INTO g_payg_db_items;
        CLOSE csr_payg_items;

        OPEN  csr_etp_cmn_items;
        FETCH csr_etp_cmn_items BULK COLLECT INTO g_etp_cmn_db_items;
        CLOSE csr_etp_cmn_items ;

        OPEN  csr_etp1_items;
        FETCH csr_etp1_items BULK COLLECT INTO g_etp1_db_items;
        CLOSE csr_etp1_items ;

        OPEN  csr_etp2_items;
        FETCH csr_etp2_items BULK COLLECT INTO g_etp2_db_items;
        CLOSE csr_etp2_items ;

        OPEN  csr_etp3_items;
        FETCH csr_etp3_items BULK COLLECT INTO g_etp3_db_items;
        CLOSE csr_etp3_items ;

        OPEN  csr_etp4_items;
        FETCH csr_etp4_items BULK COLLECT INTO g_etp4_db_items;
        CLOSE csr_etp4_items ;

        IF g_debug
        THEN
                hr_utility.set_location('Leaving Procedure     '||l_procedure,2420);
        END IF;
END populate_user_entity_types;

/*
--------------------------------------------------------------------
Name  : check_user_entity_type
Type  : Function
Access: Public
Description:This procedure takes a User Entity Name and returns the
            Data file record which corresponds to the ITEM.
            Values returned,
            PAYG        - PAYG Record
            ETP_CMN     - Common data reported in all ETP records
            ETP1        - Transtional (Y), Part of Prev Term (Y) ETP Record
            ETP2        - Transtional (Y), Part of Prev Term (N) ETP Record
            ETP3        - Transtional (N), Part of Prev Term (Y) ETP Record
            ETP4        - Transtional (N), Part of Prev Term (N) ETP Record
            ETP_CMN_BAL - ETP Balances - not used anymore now
            AMEND       - Amend PS Flag Items
            CMN         - Rest of the Items (Default Value returned)
  --------------------------------------------------------------------
*/

FUNCTION check_user_entity_type(p_user_entity_name IN ff_user_entities.user_entity_name%TYPE)
RETURN VARCHAR2
IS


l_return_value  VARCHAR2(20);
l_procedure     VARCHAR2(80);

l_entity_id     ff_user_entities.user_entity_id%TYPE;
l_found         BOOLEAN;

BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug
THEN
        l_procedure     := g_package||'.check_user_entity_type';
        hr_utility.set_location('Entering Procedure     '||l_procedure,2500);
        hr_utility.set_location('p_user_entity_name     '||p_user_entity_name,2510);
END IF;

IF p_user_entity_name IN ('X_PAYG_PAYMENT_SUMMARY_TYPE','X_PAYMENT_SUMMARY_TYPE','X_ETP1_PAYMENT_SUMMARY_TYPE'
                          ,'X_ETP2_PAYMENT_SUMMARY_TYPE','X_ETP3_PAYMENT_SUMMARY_TYPE','X_ETP4_PAYMENT_SUMMARY_TYPE')
THEN
        l_return_value  := 'AMEND';

ELSIF p_user_entity_name IN ('X_LUMP_SUM_C_PAYMENTS_ASG_YTD','X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD',
                             'X_INVALIDITY_PAYMENTS_ASG_YTD')
THEN
        l_return_value  := 'ETP_CMN_BAL';
ELSE

       /* ETP Items can have values
                   1. ETP1 (YY)
                   2. ETP2 (YN)
                   3. ETP3 (NY)
                   4. ETP4 (NN)
                   5. ETP_CMN   (Rest of the Common Items)
        */

        l_found         := FALSE;
        IF (l_found = FALSE AND g_payg_db_items.COUNT > 0)
        THEN
                FOR i IN g_payg_db_items.FIRST..g_payg_db_items.LAST
                LOOP
                        IF (g_payg_db_items(i) = p_user_entity_name)
                        THEN
                                l_found         := TRUE;
                                l_return_value  := 'PAYG';
                        END IF;
                END LOOP;
        END IF;

        IF (l_found = FALSE AND g_etp_cmn_db_items.COUNT > 0)
        THEN
                FOR i IN g_etp_cmn_db_items.FIRST..g_etp_cmn_db_items.LAST
                LOOP
                        IF (g_etp_cmn_db_items(i) = p_user_entity_name)
                        THEN
                                l_found         := TRUE;
                                l_return_value  := 'ETP_CMN';
                        END IF;
                END LOOP;
        END IF;

        IF (l_found = FALSE AND g_etp1_db_items.COUNT > 0)
        THEN
                FOR i IN g_etp1_db_items.FIRST..g_etp1_db_items.LAST
                LOOP
                        IF (g_etp1_db_items(i) = p_user_entity_name)
                        THEN
                                l_found         := TRUE;
                                l_return_value  := 'ETP1';
                        END IF;
                END LOOP;
        END IF;

        IF (l_found = FALSE AND g_etp2_db_items.COUNT > 0)
        THEN
                FOR i IN g_etp2_db_items.FIRST..g_etp2_db_items.LAST
                LOOP
                        IF (g_etp2_db_items(i) = p_user_entity_name)
                        THEN
                                l_found         := TRUE;
                                l_return_value  := 'ETP2';
                        END IF;
                END LOOP;
        END IF;


        IF (l_found = FALSE AND g_etp3_db_items.COUNT > 0)
        THEN
                FOR i IN g_etp3_db_items.FIRST..g_etp3_db_items.LAST
                LOOP
                        IF (g_etp3_db_items(i) = p_user_entity_name)
                        THEN
                                l_found         := TRUE;
                                l_return_value  := 'ETP3';
                        END IF;
                END LOOP;
        END IF;

        IF (l_found = FALSE AND g_etp4_db_items.COUNT > 0)
        THEN
                FOR i IN g_etp4_db_items.FIRST..g_etp4_db_items.LAST
                LOOP
                        IF (g_etp4_db_items(i) = p_user_entity_name)
                        THEN
                                l_found         := TRUE;
                                l_return_value  := 'ETP4';
                        END IF;
                END LOOP;
        END IF;

        l_return_value := NVL(l_return_value,'CMN');

END IF;

        IF g_debug THEN
                hr_utility.set_location('Return Value           '||l_return_value,2520);
                hr_utility.set_location('Leaving Procedure      '||l_procedure,2530);
        END IF;

        RETURN NVL(l_return_value,'CMN');

END check_user_entity_type;


/*
--------------------------------------------------------------------
Name  : compare_user_entity_value
Type  : Function
Access: Private
Description:This procedure takes a User entity name and two values
            and compares the same.
            The following values are returned,
                    Y - Value Matches
                    N - Values Don't Match
--------------------------------------------------------------------
*/

FUNCTION compare_user_entity_value
        (p_user_entity_name IN ff_user_entities.user_entity_name%TYPE
        ,p_value1           IN ff_archive_items.value%TYPE
        ,p_value2           IN ff_archive_items.value%TYPE
        ,p_data_type         IN ff_database_items.data_type%TYPE)
RETURN VARCHAR2
IS

l_procedure     VARCHAR2(80);
l_return_flag   VARCHAR2(5);

BEGIN

IF g_debug
THEN
        l_procedure     := g_package||'.compare_user_entity_value';
        hr_utility.set_location('Entering Function      '||l_procedure,2600);
        hr_utility.set_location('p_user_entity_name     '||p_user_entity_name,2610);
        hr_utility.set_location('p_value1               '||p_value1,2620);
        hr_utility.set_location('p_value2               '||p_value2,2620);
        hr_utility.set_location('p_data_type            '||p_data_type,2620);
END IF;

l_return_flag   := 'Y'; /* Default - Values Match */

        IF p_data_type  = 'N'
        THEN
                IF trunc(to_number(p_value1)) <> trunc(to_number(p_value2))
                THEN
                        l_return_flag   := 'N';
                END IF;
        ELSIF p_data_type  = 'D'
        THEN
                IF fnd_date.canonical_to_date(p_value1) <> fnd_date.canonical_to_date(p_value2)
                THEN
                        l_return_flag   := 'N';
                END IF;
        ELSE
                IF trim(p_value1) <> trim(p_value2)
                THEN
                        l_return_flag   := 'N';
                END IF;
        END IF;

IF g_debug
THEN
        hr_utility.set_location('l_return_flag          '||l_return_flag,2640);
        hr_utility.set_location('Leaving Function       '||l_procedure,2650);
END IF;

RETURN l_return_flag;

END compare_user_entity_value;


/*
--------------------------------------------------------------------
Name  : find_new_missing_items
Type  : Procedure
Access: Private
Description:This procedure is called when the count of items
            for old and new archive do not match.
            This Procedure identifies the missing item from New
            Archive and sets the appropriate Amend PS Flag
  --------------------------------------------------------------------
*/

PROCEDURE find_new_missing_items
        (p_archive_action_id    IN pay_assignment_actions.assignment_action_id%TYPE
        ,p_old_count            IN NUMBER
        ,p_all_tab_new          IN archive_db_tab
        ,p_new_count            IN NUMBER)
IS

/* Bug 8315198 - Modified cursor to include X_ETP_DEATH_BENEFIT_TFN and X_LUMP_SUM_A_PAYMENT_TYPE DB items */
CURSOR get_archived_user_entities
        (c_archive_action_id pay_assignment_actions.assignment_action_id%TYPE)
IS
SELECT  fue.user_entity_name
FROM    ff_archive_items fae,
        ff_user_entities fue
WHERE  fae.context1 = c_archive_action_id
AND   fue.user_entity_id = fae.user_entity_id
AND   (
        fue.user_entity_name    LIKE 'X_ALLOWANCE%'
        OR fue.user_entity_name LIKE 'X_EMPLOYEE%DATE%'
        OR fue.user_entity_name LIKE 'X_UNION%'
        OR fue.user_entity_name LIKE 'X_%ASG_YTD'
        OR  fue.user_entity_name IN( 'X_SORT_EMPLOYEE_TYPE','X_EMPLOYEE_TAX_FILE_NUMBER','X_ETP_TAX_FILE_NUMBER'
                                ,'X_ETP_DEATH_BENEFIT_TFN','X_LUMP_SUM_A_PAYMENT_TYPE'
                                ,'X_ETP_DED_TRANS_PPTERM_ASG_YTD','X_INV_PAY_TRANS_PPTERM_ASG_YTD'
                                ,'X_POST_JUN_83_TAXED_TRANS_PPTERM_ASG_YTD','X_PRE_JUL_83_COMP_TRANS_PPTERM_ASG_YTD'
                                ,'X_ETP_DED_TRANS_NOT_PPTERM_ASG_YTD','X_INV_PAY_TRANS_NOT_PPTERM_ASG_YTD'
                                ,'X_POST_JUN_83_TAXED_TRANS_NOT_PPTERM_ASG_YTD','X_PRE_JUL_83_COMP_TRANS_NOT_PPTERM_ASG_YTD'
                                ,'X_ETP_DED_NOT_TRANS_PPTERM_ASG_YTD','X_INV_PAY_NOT_TRANS_PPTERM_ASG_YTD'
                                ,'X_POST_JUN_83_TAXED_NOT_TRANS_PPTERM_ASG_YTD','X_PRE_JUL_83_COMP_NOT_TRANS_PPTERM_ASG_YTD'
                                ,'X_ETP_DED_NOT_TRANS_NOT_PPTERM_ASG_YTD','X_INV_PAY_NOT_TRANS_NOT_PPTERM_ASG_YTD'
                                ,'X_POST_JUN_83_TAXED_NOT_TRANS_NOT_PPTERM_ASG_YTD','X_PRE_JUL_83_COMP_NOT_TRANS_NOT_PPTERM_ASG_YTD' )
        OR fue.user_entity_name LIKE 'X_ETP%DATE%'
        OR fue.user_entity_name LIKE 'X_DAYS%'
        )
AND     fue.user_entity_name  NOT IN ('X_PAYMENT_SUMMARY_TYPE','X_PAYG_PAYMENT_SUMMARY_TYPE','X_ETP1_PAYMENT_SUMMARY_TYPE'
                                 ,'X_ETP2_PAYMENT_SUMMARY_TYPE','X_ETP3_PAYMENT_SUMMARY_TYPE','X_ETP4_PAYMENT_SUMMARY_TYPE'
                                 ,'X_LUMP_SUM_C_PAYMENTS_ASG_YTD','X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD','X_INVALIDITY_PAYMENTS_ASG_YTD'
                                 ,'X_PRE_JUL_83_COMPONENT_ASG_YTD','X_POST_JUN_83_UNTAXED_ASG_YTD','X_POST_JUN_83_TAXED_ASG_YTD')
AND     fue.legislation_code     = 'AU';

l_procedure     VARCHAR2(100);
l_diff_count    NUMBER;
l_found         BOOLEAN;
l_item_type     VARCHAR2(20);


BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug
THEN
        l_procedure     := g_package||'.find_new_missing_items';
        hr_utility.set_location('Entering Procedure     '||l_procedure,3500);
END IF;

l_diff_count    := p_old_count - p_new_count;

/*    Logic Used
      (A) Fetch all items from Original Archive for Standard and ETP pages
      (B) If this item is missing in New Archive PL/SQL table, set the Amended PS Flag accordingly
      (C) We will look only for items of type PAYG,ETP_CMN,ETP1, ETP2,ETP3,ETP4 - Relevant Numeric and Date Types
      (D) CMN - we are not interested if these items are missing
      (E) ETP_CMN_BAL and AMEND items are archived for all Employees - so will be ignored
*/

FOR csr_rec IN get_archived_user_entities(p_archive_action_id)
LOOP
        IF l_diff_count = 0
        THEN
                exit;
        END IF;

        l_found := FALSE;
        IF (p_all_tab_new.COUNT > 0)
        THEN
                FOR i IN p_all_tab_new.FIRST..p_all_tab_new.LAST
                LOOP
                        IF p_all_tab_new(i).db_item_name = csr_rec.user_entity_name
                        THEN
                                l_found := TRUE;
                                exit;
                        END IF;
                END LOOP;
        END IF;

        IF (l_found = FALSE)
        THEN
                /* DB Item missing in New Archive.
                   Set the Amend Flags */
                IF  g_debug
                THEN
                        hr_utility.set_location('Missing Item Found     '||csr_rec.user_entity_name,3510);
                END IF;
                l_item_type := check_user_entity_type(csr_rec.user_entity_name);
                IF l_item_type = 'PAYG'
                THEN
                       l_amend_types_new(1).db_item_value := 'A';
                ELSIF l_item_type = 'ETP_CMN'
                THEN
                       l_amend_types_new(2).db_item_value := 'A';
                       l_amend_types_new(3).db_item_value := 'A';
                       l_amend_types_new(4).db_item_value := 'A';
                       l_amend_types_new(5).db_item_value := 'A';
                ELSIF l_item_type = 'ETP1'
                THEN
                       l_amend_types_new(2).db_item_value := 'A';
                ELSIF l_item_type = 'ETP2'
                THEN
                       l_amend_types_new(3).db_item_value := 'A';
                ELSIF l_item_type = 'ETP3'
                THEN
                       l_amend_types_new(4).db_item_value := 'A';

                ELSIF l_item_type = 'ETP4'
                THEN
                       l_amend_types_new(5).db_item_value := 'A';
                END IF;
                l_diff_count := l_diff_count - 1;
        END IF;
END LOOP;

IF g_debug
THEN
        hr_utility.set_location('Payment Summary Flags  ',3520);
    IF (l_amend_types_new.COUNT > 0 )
    THEN
        FOR i IN l_amend_types_new.FIRST..l_amend_types_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_amend_types_new(i).db_item_name,1,50),50,' ')||rpad(l_amend_types_new(i).db_item_value,30,' '),3530);
        END LOOP;
        hr_utility.set_location('Leaving Procedure     '||l_procedure,3540);
    END IF;
END IF;

END find_new_missing_items;



/*
--------------------------------------------------------------------
Name  : slot_items_build_archive_list
Type  : Procedure
Access: Private
Description:This private procedure does the actual comparison and
            slotting in multiple PL/SQL tables - one for each datafile type.
            It takes each item in Archive Pl/SQL table - finds the
            data file record, compares with the Original Archive value
            and sets the Amended PS Flag PL/sql table accordingly.
  --------------------------------------------------------------------
*/

PROCEDURE  slot_items_build_archive_list
        (p_archive_action_id    IN pay_assignment_actions.assignment_action_id%TYPE
        ,p_all_tab_new          IN archive_db_tab)
IS

CURSOR csr_get_value(c_user_entity_name VARCHAR2,
                     c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
IS
SELECT  fai.value
       ,fdi.data_type
FROM    ff_archive_items fai,
        ff_user_entities fue,
        ff_database_items fdi
WHERE fai.context1         = c_assignment_action_id
AND   fai.user_entity_id   = fue.user_entity_id
AND   fdi.user_entity_id   = fue.user_entity_id
AND   fue.user_entity_name = c_user_entity_name;

i_index NUMBER;
l_procedure     VARCHAR2(80);

l_item_type     VARCHAR2(20);
l_old_value     ff_archive_items.value%TYPE;
l_data_type     ff_database_items.data_type%TYPE;

l_compare_flag  VARCHAR2(2);
l_etp_cmn_flag  VARCHAR2(2);


BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug
THEN
        l_procedure     := g_package||'.slot_items_build_archive_list';
        hr_utility.set_location('Entering Procedure     '||l_procedure,3700);
END IF;


l_etp_cmn_flag := 'O'; /* Initialize ETP Common Change Flag to O */

IF ( p_all_tab_new.COUNT > 0 )
THEN
    FOR i IN p_all_tab_new.FIRST..p_all_tab_new.LAST
    LOOP

    l_compare_flag := 'Y';

    l_item_type     := check_user_entity_type(p_all_tab_new(i).db_item_name);

    IF l_item_type ='CMN'
    THEN
            /* Only Old Values */
            OPEN csr_get_value(p_all_tab_new(i).db_item_name
                              ,p_archive_action_id);
            FETCH csr_get_value INTO l_old_value,l_data_type;
            IF   csr_get_value%NOTFOUND
            THEN
                    l_old_value     := NULL;
                    l_data_type     := NULL;
            END IF;
            CLOSE csr_get_value;

            i_index := NVL(l_cmn_tab_new.LAST,-1) + 1;

            l_cmn_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
            l_cmn_tab_new(i_index).db_item_value  := l_old_value;

    ELSIF l_item_type ='PAYG'
    THEN
            IF l_amend_types_new(1).db_item_value  <> 'A'
            THEN

                    OPEN csr_get_value(p_all_tab_new(i).db_item_name
                                      ,p_archive_action_id);
                    FETCH csr_get_value INTO l_old_value,l_data_type;
                    IF   csr_get_value%NOTFOUND
                    THEN
                            l_amend_types_new(1).db_item_value := 'A';
                            l_old_value     := NULL;
                            l_data_type     := NULL;
                    ELSE
                            /* Compare Old and New Values
                               Set the Amended Payment Summary Flag accordingly
                            */

                            l_compare_flag := compare_user_entity_value
                                                    (p_all_tab_new(i).db_item_name
                                                    ,p_all_tab_new(i).db_item_value
                                                    ,l_old_value
                                                    ,l_data_type);

                            IF l_compare_flag = 'N'
                            THEN
                                    l_amend_types_new(1).db_item_value := 'A';
                            END IF;
                    END IF;
                    CLOSE csr_get_value ;

                    i_index := NVL(l_payg_tab_new.LAST,-1) + 1;

                    l_payg_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_payg_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;

            ELSE
                    /* Amended Payment Summary - No need to compare
                    */

                    i_index := NVL(l_payg_tab_new.LAST,-1) + 1;

                    l_payg_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_payg_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;

            END IF;
    ELSIF l_item_type IN ('ETP_CMN','ETP_CMN_BAL')
    THEN
            IF ( l_item_type = 'ETP_CMN' AND l_etp_cmn_flag  <> 'A')
            THEN

                    OPEN csr_get_value(p_all_tab_new(i).db_item_name
                                      ,p_archive_action_id);
                    FETCH csr_get_value INTO l_old_value,l_data_type;
                    IF   csr_get_value%NOTFOUND
                    THEN
                            l_etp_cmn_flag  := 'A';
                            l_amend_types_new(2).db_item_value := 'A';
                            l_amend_types_new(3).db_item_value := 'A';
                            l_amend_types_new(4).db_item_value := 'A';
                            l_amend_types_new(5).db_item_value := 'A';
                            l_old_value     := NULL;
                            l_data_type     := NULL;
                    ELSE
                            /* Compare Old and New Values
                               Set the Amended Payment Summary Flag accordingly
                            */

                            l_compare_flag := compare_user_entity_value
                                                    (p_all_tab_new(i).db_item_name
                                                    ,p_all_tab_new(i).db_item_value
                                                    ,l_old_value
                                                    ,l_data_type);

                            IF l_compare_flag = 'N'
                            THEN
                                l_etp_cmn_flag  := 'A';
                                l_amend_types_new(2).db_item_value := 'A';
                                l_amend_types_new(3).db_item_value := 'A';
                                l_amend_types_new(4).db_item_value := 'A';
                                l_amend_types_new(5).db_item_value := 'A';
                            END IF;
                    END IF;
                    CLOSE csr_get_value ;

                    i_index := NVL(l_etp_cmn_tab_new.LAST,-1) + 1;

                    l_etp_cmn_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_cmn_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;

            ELSE
                    /* Amended Payment Summary - No need to compare
                       ETP Balances - will be adjusted in ETP1-4 Sections. Always copy the new Value
                    */

                    i_index := NVL(l_etp_cmn_tab_new.LAST,-1) + 1;

                    l_etp_cmn_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_cmn_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;

            END IF;
    ELSIF l_item_type ='ETP1'
    THEN
            IF l_amend_types_new(2).db_item_value  <> 'A'
            THEN

                    OPEN csr_get_value(p_all_tab_new(i).db_item_name
                                      ,p_archive_action_id);
                    FETCH csr_get_value INTO l_old_value,l_data_type;
                    IF   csr_get_value%NOTFOUND
                    THEN
                            l_amend_types_new(2).db_item_value := 'A';
                            l_old_value     := NULL;
                            l_data_type     := NULL;
                    ELSE
                            /* Compare Old and New Values
                               Set the Amended Payment Summary Flag accordingly
                            */

                            l_compare_flag := compare_user_entity_value
                                                    (p_all_tab_new(i).db_item_name
                                                    ,p_all_tab_new(i).db_item_value
                                                    ,l_old_value
                                                    ,l_data_type);

                            IF l_compare_flag = 'N'
                            THEN
                            l_amend_types_new(2).db_item_value := 'A';
                            END IF;
                    END IF;
                    CLOSE csr_get_value ;

                    i_index := NVL(l_etp_1_tab_new.LAST,-1) + 1;

                    l_etp_1_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_1_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;

            ELSE
                    /* Amended Payment Summary - No need to compare
                    */

                    i_index := NVL(l_etp_1_tab_new.LAST,-1) + 1;

                    l_etp_1_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_1_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;
            END IF;

    ELSIF l_item_type ='ETP2'
    THEN
            IF l_amend_types_new(3).db_item_value  <> 'A'
            THEN

                    OPEN csr_get_value(p_all_tab_new(i).db_item_name
                                      ,p_archive_action_id);
                    FETCH csr_get_value INTO l_old_value,l_data_type;
                    IF   csr_get_value%NOTFOUND
                    THEN
                            l_amend_types_new(3).db_item_value := 'A';
                            l_old_value     := NULL;
                            l_data_type     := NULL;
                    ELSE
                            /* Compare Old and New Values
                               Set the Amended Payment Summary Flag accordingly
                            */

                            l_compare_flag := compare_user_entity_value
                                                    (p_all_tab_new(i).db_item_name
                                                    ,p_all_tab_new(i).db_item_value
                                                    ,l_old_value
                                                    ,l_data_type);

                            IF l_compare_flag = 'N'
                            THEN
                            l_amend_types_new(3).db_item_value := 'A';
                            END IF;
                    END IF;
                    CLOSE csr_get_value ;

                    i_index := NVL(l_etp_2_tab_new.LAST,-1) + 1;

                    l_etp_2_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_2_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;

            ELSE
                    /* Amended Payment Summary - No need to compare
                    */

                    i_index := NVL(l_etp_2_tab_new.LAST,-1) + 1;

                    l_etp_2_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_2_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;
            END IF;

    ELSIF l_item_type ='ETP3'
    THEN
            IF l_amend_types_new(4).db_item_value  <> 'A'
            THEN

                    OPEN csr_get_value(p_all_tab_new(i).db_item_name
                                      ,p_archive_action_id);
                    FETCH csr_get_value INTO l_old_value,l_data_type;
                    IF   csr_get_value%NOTFOUND
                    THEN
                            l_amend_types_new(4).db_item_value := 'A';
                            l_old_value     := NULL;
                            l_data_type     := NULL;
                    ELSE
                            /* Compare Old and New Values
                               Set the Amended Payment Summary Flag accordingly
                            */

                            l_compare_flag := compare_user_entity_value
                                                    (p_all_tab_new(i).db_item_name
                                                    ,p_all_tab_new(i).db_item_value
                                                    ,l_old_value
                                                    ,l_data_type);

                            IF l_compare_flag = 'N'
                            THEN
                            l_amend_types_new(4).db_item_value := 'A';
                            END IF;
                    END IF;
                    CLOSE csr_get_value ;

                    i_index := NVL(l_etp_3_tab_new.LAST,-1) + 1;

                    l_etp_3_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_3_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;

            ELSE
                    /* Amended Payment Summary - No need to compare
                    */

                    i_index := NVL(l_etp_3_tab_new.LAST,-1) + 1;

                    l_etp_3_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_3_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;
            END IF;

    ELSIF l_item_type ='ETP4'
    THEN
            IF l_amend_types_new(5).db_item_value  <> 'A'
            THEN

                    OPEN csr_get_value(p_all_tab_new(i).db_item_name
                                      ,p_archive_action_id);
                    FETCH csr_get_value INTO l_old_value,l_data_type;
                    IF   csr_get_value%NOTFOUND
                    THEN
                            l_amend_types_new(5).db_item_value := 'A';
                            l_old_value     := NULL;
                            l_data_type     := NULL;
                    ELSE
                            /* Compare Old and New Values
                               Set the Amended Payment Summary Flag accordingly
                            */

                            l_compare_flag := compare_user_entity_value
                                                    (p_all_tab_new(i).db_item_name
                                                    ,p_all_tab_new(i).db_item_value
                                                    ,l_old_value
                                                    ,l_data_type);

                            IF l_compare_flag = 'N'
                            THEN
                            l_amend_types_new(5).db_item_value := 'A';
                            END IF;
                    END IF;
                    CLOSE csr_get_value ;

                    i_index := NVL(l_etp_4_tab_new.LAST,-1) + 1;

                    l_etp_4_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_4_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;

            ELSE
                    /* Amended Payment Summary - No need to compare
                    */
                    i_index := NVL(l_etp_4_tab_new.LAST,-1) + 1;

                    l_etp_4_tab_new(i_index).db_item_name   := p_all_tab_new(i).db_item_name;
                    l_etp_4_tab_new(i_index).db_item_value  := p_all_tab_new(i).db_item_value;
            END IF;
    END IF;

    END LOOP;
END IF;

/* Reset the Value of DB Item X_PAYMENT_SUMMARY_TYPE if No individual record has changed
*/

IF   ( l_amend_types_new(1).db_item_value ='O'
        AND l_amend_types_new(2).db_item_value ='O'
        AND l_amend_types_new(3).db_item_value ='O'
        AND l_amend_types_new(4).db_item_value ='O'
        AND l_amend_types_new(5).db_item_value ='O')
THEN
        l_amend_types_new(0).db_item_value :='O';
END IF;

IF g_debug
THEN
    IF ( l_cmn_tab_new.COUNT > 0)
    THEN
        hr_utility.set_location('              COMMON ITEMS                            ',3710);

        FOR i IN l_cmn_tab_new.FIRST..l_cmn_tab_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_cmn_tab_new(i).db_item_name,1,50),50,' ')||rpad(l_cmn_tab_new(i).db_item_value,30,' '),3710);
        END LOOP;
    END IF;

    IF ( l_payg_tab_new.COUNT > 0)
    THEN
        hr_utility.set_location('              STANDARD ITEMS                            ',3720);

        FOR i IN l_payg_tab_new.FIRST..l_payg_tab_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_payg_tab_new(i).db_item_name,1,50),50,' ')||rpad(l_payg_tab_new(i).db_item_value,30,' '),3720);
        END LOOP;
    END IF;


    IF ( l_etp_cmn_tab_new.COUNT > 0)
    THEN
        hr_utility.set_location('              ETP COMMON ITEMS                            ',3730);

        FOR i IN l_etp_cmn_tab_new.FIRST..l_etp_cmn_tab_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_etp_cmn_tab_new(i).db_item_name,1,50),50,' ')||rpad(l_etp_cmn_tab_new(i).db_item_value,30,' '),3730);
        END LOOP;
    END IF;

    IF (l_etp_1_tab_new.COUNT > 0)
    THEN
        hr_utility.set_location('              ETP 1 ITEMS                            ',3740);

        FOR i IN l_etp_1_tab_new.FIRST..l_etp_1_tab_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_etp_1_tab_new(i).db_item_name,1,50),50,' ')||rpad(l_etp_1_tab_new(i).db_item_value,30,' '),3740);
        END LOOP;
    END IF;

    IF (l_etp_2_tab_new.COUNT > 0)
    THEN
        hr_utility.set_location('              ETP 2 ITEMS                            ',3750);

        FOR i IN l_etp_2_tab_new.FIRST..l_etp_2_tab_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_etp_2_tab_new(i).db_item_name,1,50),50,' ')||rpad(l_etp_2_tab_new(i).db_item_value,30,' '),3750);
        END LOOP;
    END IF;

    IF (l_etp_3_tab_new.COUNT > 0)
    THEN
        hr_utility.set_location('              ETP 3 ITEMS                            ',3760);

        FOR i IN l_etp_3_tab_new.FIRST..l_etp_3_tab_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_etp_3_tab_new(i).db_item_name,1,50),50,' ')||rpad(l_etp_3_tab_new(i).db_item_value,30,' '),3760);
        END LOOP;
    END IF;

    IF ( l_etp_4_tab_new.COUNT > 0)
    THEN
        hr_utility.set_location('              ETP 4 ITEMS                            ',3770);

        FOR i IN l_etp_4_tab_new.FIRST..l_etp_4_tab_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_etp_4_tab_new(i).db_item_name,1,50),50,' ')||rpad(l_etp_4_tab_new(i).db_item_value,30,' '),3770);
        END LOOP;
    END IF;


    IF (l_amend_types_new.COUNT > 0)
    THEN
        hr_utility.set_location('              AMEND TYPE ITEMS                            ',3780);

        FOR i IN l_amend_types_new.FIRST..l_amend_types_new.LAST
        LOOP
               hr_utility.set_location(rpad(i,5,' ')||rpad(substr(l_amend_types_new(i).db_item_name,1,50),50,' ')||rpad(l_amend_types_new(i).db_item_value,30,' '),3780);
        END LOOP;
    END IF;

        hr_utility.set_location('Leaving Procedure     '||l_procedure,3800);
END IF;


END slot_items_build_archive_list;


/*
--------------------------------------------------------------------
Name  : archive_db_items_tab
Type  : Procedure
Access: Private
Description:This procedure archives the contents of the
            user entity value PL/SQL table
--------------------------------------------------------------------
*/

PROCEDURE archive_db_items_tab(
         p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%TYPE
        ,p_db_item_tab           IN archive_db_tab
        )
IS

CURSOR  get_user_entity_id(c_user_entity_name IN VARCHAR2)
IS
SELECT fue.user_entity_id
      ,dbi.data_type
FROM  ff_user_entities  fue
     ,ff_database_items dbi
WHERE user_entity_name     = c_user_entity_name
AND   fue.user_entity_id   = dbi.user_entity_id
AND   fue.legislation_code = 'AU';

l_procedure             VARCHAR2(80);
l_user_entity_id        ff_user_entities.user_entity_id%TYPE;
l_archive_item_id       ff_archive_items.archive_item_id%TYPE;
l_object_version_number ff_archive_items.object_version_number%type;
l_some_warning          boolean;

e_ue_missing            EXCEPTION;

BEGIN

g_debug := hr_utility.debug_enabled;
IF g_debug
THEN
        l_procedure     := g_package||'.archive_db_items_tab';
        hr_utility.set_location('Entering Procedure     '||l_procedure,4200);
END IF;

IF (p_db_item_tab.COUNT > 0)
THEN
        FOR i IN p_db_item_tab.FIRST..p_db_item_tab.LAST
        LOOP
                IF g_debug
                THEN
                        hr_utility.set_location('p_db_item_tab.name     '||p_db_item_tab(i).db_item_name,4210);
                        hr_utility.set_location('p_db_item_tab.value    '||p_db_item_tab(i).db_item_value,4220);
                END IF;

                FOR csr_ue_rec IN get_user_entity_id(p_db_item_tab(i).db_item_name)
                LOOP
                        l_archive_item_id       := NULL;
                        l_object_version_number := NULL;
                        l_some_warning          := NULL;

                        ff_archive_api.create_archive_item
                         (p_validate              => false
                         ,p_archive_item_id       => l_archive_item_id
                         ,p_user_entity_id        => csr_ue_rec.user_entity_id
                         ,p_archive_value         => p_db_item_tab(i).db_item_value
                         ,p_archive_type          => 'AAP'
                         ,p_action_id             => p_assignment_action_id
                         ,p_legislation_code      => 'AU'
                         ,p_object_version_number => l_object_version_number
                         ,p_context_name1         => 'ASSIGNMENT_ACTION_ID'
                         ,p_context1              => p_assignment_action_id
                         ,p_some_warning          => l_some_warning);

                        IF g_debug
                        THEN
                                hr_utility.set_location('l_archive_item_id      '||l_archive_item_id,4230);
                        END IF;
                END LOOP;

        END LOOP;
END IF;
IF g_debug
THEN
        hr_utility.set_location('Leaving Procedure      '||l_procedure,4250);
END IF;

END archive_db_items_tab;


/*
--------------------------------------------------------------------
Name  : modify_and_archive_code
Type  : Procedure
Access: Public
Description:This procedure is called from Archive code of Payment Summary
            with a PL/SQL table holding all DB items and values
            This procedure slots the DB items according to record
            in datafile and populates different PL/SQL tables.
            Data is archived in this procedure based on Amend PS
            flags.
  --------------------------------------------------------------------
*/
PROCEDURE modify_and_archive_code
        (p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%TYPE
        ,p_effective_date        IN DATE
        ,p_all_tab_new           IN archive_db_tab)
IS

l_procedure     VARCHAR2(80);

CURSOR get_orig_archive_id
        (c_assignmenr_id pay_assignment_actions.assignment_id%TYPE
        ,c_fin_year      VARCHAR2
        ,c_tax_unit_id  pay_assignment_actions.tax_unit_id%TYPE
        )
IS
SELECT selfplock.locked_action_id
FROM     pay_assignment_actions mpaa
        ,pay_payroll_actions    mppa
        ,pay_action_interlocks  mplock
        ,pay_action_interlocks  selfplock
WHERE   mpaa.assignment_id      = c_assignmenr_id
AND   mpaa.payroll_action_id    = mppa.payroll_action_id
AND   mppa.report_type          = 'AU_PS_DATA_FILE'
AND   mppa.report_qualifier     = 'AU'
AND   mppa.report_category      = 'REPORT'
AND   pay_core_utils.get_parameter('FINANCIAL_YEAR',mppa.legislative_parameters) = c_fin_year
AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER',mppa.legislative_parameters) = c_tax_unit_id
AND   mplock.locking_action_id  = mpaa.assignment_action_id
AND   mplock.locked_action_id   = selfplock.locking_action_id;


CURSOR c_action(c_assignment_action_id NUMBER) IS
SELECT pay_core_utils.get_parameter('BUSINESS_GROUP_ID',ppa.legislative_parameters)
,      pay_core_utils.get_parameter('REGISTERED_EMPLOYER',ppa.legislative_parameters)
,      pay_core_utils.get_parameter('EMPLOYEE_TYPE',ppa.legislative_parameters)
,      ppa.payroll_action_id
,      paa.assignment_id
,      to_date('01-07-'|| substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters),1,4),'DD-MM-YYYY')
,      to_date('30-06-'|| substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters),6,4),'DD-MM-YYYY')
,      pay_core_utils.get_parameter('LST_YR_TERM',ppa.legislative_parameters)
,      pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters)
FROM   pay_assignment_actions     paa
,      pay_payroll_actions        ppa
WHERE  paa.assignment_action_id   = c_assignment_action_id
AND    ppa.payroll_action_id      = paa.payroll_action_id ;

CURSOR get_context_id(c_context_name ff_contexts.context_name%TYPE)
IS
SELECT fc.context_id
FROM   ff_contexts fc
WHERE  fc.context_name = c_context_name;

CURSOR get_archive_item_count(c_archive_action_id pay_assignment_actions.assignment_action_id%TYPE
                             ,c_context_id        ff_contexts.context_id%TYPE)
IS
SELECT COUNT(*)
FROM    ff_archive_items fai,
        ff_user_entities fue,
        ff_archive_item_contexts faic
WHERE fai.context1 = c_archive_action_id
AND   fue.user_entity_id = fai.user_entity_id
AND   fai.archive_item_id = faic.archive_item_id
AND   faic.context_id = c_context_id
AND   fue.user_entity_name NOT IN ('X_PAYMENT_SUMMARY_TYPE'
                                  ,'X_PAYG_PAYMENT_SUMMARY_TYPE'
                                  ,'X_ETP1_PAYMENT_SUMMARY_TYPE'
                                  ,'X_ETP2_PAYMENT_SUMMARY_TYPE'
                                  ,'X_ETP3_PAYMENT_SUMMARY_TYPE'
                                  ,'X_ETP4_PAYMENT_SUMMARY_TYPE');

l_assignment_id               pay_assignment_actions.assignment_id%TYPE;
l_business_group_id           pay_payroll_actions.business_group_id%TYPE ;
l_registered_employer         hr_organization_units.organization_id%TYPE;
l_payroll_action_id           pay_payroll_actions.payroll_action_id%TYPE ;
l_year_start                  pay_payroll_Actions.effective_date%TYPE;
l_year_end                    pay_payroll_actions.effective_date%TYPE;
l_employee_type               per_all_people_f.current_Employee_Flag%TYPE;
l_lst_yr_term                 varchar2(10);
l_fin_year                    VARCHAR2(20);
l_archive_action_id           pay_assignment_actions.assignment_action_id%TYPE;

l_eit_value                   VARCHAR2(10);

l_new_count                   NUMBER;
l_old_count                   NUMBER;
l_context_id                  ff_contexts.context_id%TYPE;

BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug
THEN
        l_procedure  := g_package||'.modify_and_archive_code';
        hr_utility.set_location('Entering Procedure  '||l_procedure, 3000);
END IF;

/* Print All the DB Items Values got from Archive */
IF g_debug
THEN
    IF (p_all_tab_new.COUNT > 0)
    THEN
        FOR i IN p_all_tab_new.FIRST..p_all_tab_new.LAST
        LOOP
            hr_utility.set_location(rpad(i,5,' ')||rpad(p_all_tab_new(i).db_item_name,50,' ')||rpad(p_all_tab_new(i).db_item_value,30,' '),3010);
        END LOOP;
    END IF;
END IF;

OPEN c_action(p_assignment_action_id);
FETCH c_action INTO  l_business_group_id
                    ,l_registered_employer
                    ,l_employee_type
                    ,l_payroll_action_id
                    ,l_assignment_id
                    ,l_year_start
                    ,l_year_end
                    ,l_lst_yr_term
                    ,l_fin_year;
CLOSE c_action;


OPEN get_orig_archive_id(l_assignment_id
                        ,l_fin_year
                        ,l_registered_employer);
FETCH get_orig_archive_id INTO l_archive_action_id;
CLOSE get_orig_archive_id;

IF g_debug
THEN
    hr_utility.set_location('l_business_group_id    '||l_business_group_id,3020);
    hr_utility.set_location('l_registered_employer  '||l_registered_employer,3020);
    hr_utility.set_location('l_employee_type        '||l_employee_type,3020);
    hr_utility.set_location('l_payroll_action_id    '||l_payroll_action_id,3020);
    hr_utility.set_location('l_assignment_id        '||l_assignment_id,3020);
    hr_utility.set_location('l_year_start           '||l_year_start,3020);
    hr_utility.set_location('l_year_end             '||l_year_end,3020);
    hr_utility.set_location('l_lst_yr_term          '||l_lst_yr_term,3020);
    hr_utility.set_location('l_fin_year             '||l_fin_year,3020);
    hr_utility.set_location('l_archive_action_id    '||l_archive_action_id,3020);
END IF;


/* Now you have all the archive items - slot them according to Datafile record
   Initialize the PL/SQL tables to NULL
*/

l_cmn_tab_new.DELETE;
l_payg_tab_new.DELETE;
l_etp_cmn_tab_new.DELETE;
l_etp_1_tab_new.DELETE;
l_etp_2_tab_new.DELETE;
l_etp_3_tab_new.DELETE;
l_etp_4_tab_new.DELETE;
l_amend_types_new.DELETE;

/* Initialize all Amended Payment Summary Flags,
          Index     Meaning    Value
            0.      Common      A
            1       Standard    O
            2       ETP1        O
            3       ETP2        O
            4       ETP3        O
            5       ETP4        O
*/

    l_amend_types_new(0).db_item_name       := 'X_PAYMENT_SUMMARY_TYPE';
    l_amend_types_new(0).db_item_value      := 'A';

    l_amend_types_new(1).db_item_name       := 'X_PAYG_PAYMENT_SUMMARY_TYPE';
    l_amend_types_new(1).db_item_value      := 'O';

    l_amend_types_new(2).db_item_name       := 'X_ETP1_PAYMENT_SUMMARY_TYPE';
    l_amend_types_new(2).db_item_value      := 'O';

    l_amend_types_new(3).db_item_name       := 'X_ETP2_PAYMENT_SUMMARY_TYPE';
    l_amend_types_new(3).db_item_value      := 'O';

    l_amend_types_new(4).db_item_name       := 'X_ETP3_PAYMENT_SUMMARY_TYPE';
    l_amend_types_new(4).db_item_value      := 'O';

    l_amend_types_new(5).db_item_name       := 'X_ETP4_PAYMENT_SUMMARY_TYPE';
    l_amend_types_new(5).db_item_value      := 'O';


/*      Check count and set flags if some items are missing in New Run
*/

    l_new_count     := NVL(p_all_tab_new.LAST,-1) + 1;

    OPEN get_context_id('ASSIGNMENT_ACTION_ID');
    FETCH get_context_id INTO l_context_id;
    CLOSE get_context_id;

    OPEN  get_archive_item_count(l_archive_action_id,l_context_id);
    FETCH get_archive_item_count INTO l_old_count;
    CLOSE get_archive_item_count ;

    IF g_debug THEN
        hr_utility.set_location('Old Archive Count      '||l_old_count,3030);
        hr_utility.set_location('New Archive Count      '||l_new_count,3030);
    END IF;

    IF l_old_count > l_new_count
    THEN
    /* Some Items Missing from New Archive - Find and Set the Amend Flags appropriately
    */
        find_new_missing_items(l_archive_action_id
                              ,l_old_count
                              ,p_all_tab_new
                              ,l_new_count);
    END IF;

    slot_items_build_archive_list(l_archive_action_id
                                 ,p_all_tab_new);

    /*  1. Archive all Common Information - Old
        2. Archive all Standard Information - Old/New based on EIT
        3. Archive all ETP Information - Old/New based on EIT
        4. Archive Amended Payment Summary Flags
    */

        archive_db_items_tab
                (p_assignment_action_id  => p_assignment_action_id
                ,p_db_item_tab           => l_cmn_tab_new);

        archive_db_items_tab
                (p_assignment_action_id  => p_assignment_action_id
                ,p_db_item_tab           => l_payg_tab_new);

        archive_db_items_tab
                (p_assignment_action_id  => p_assignment_action_id
                ,p_db_item_tab           => l_etp_cmn_tab_new);

        archive_db_items_tab
                (p_assignment_action_id  => p_assignment_action_id
                ,p_db_item_tab           => l_etp_1_tab_new);

        archive_db_items_tab
                (p_assignment_action_id  => p_assignment_action_id
                ,p_db_item_tab           => l_etp_2_tab_new);

        archive_db_items_tab
                (p_assignment_action_id  => p_assignment_action_id
                ,p_db_item_tab           => l_etp_3_tab_new);

        archive_db_items_tab
                (p_assignment_action_id  => p_assignment_action_id
                ,p_db_item_tab           => l_etp_4_tab_new);

        archive_db_items_tab
                (p_assignment_action_id  => p_assignment_action_id
                ,p_db_item_tab           => l_amend_types_new);

IF g_debug
THEN
        hr_utility.set_location('Leaving Procedure  '||l_procedure, 3000);
END IF;

END modify_and_archive_code;

PROCEDURE spawn_data_file
        (p_payroll_action_id IN pay_payroll_actions.payroll_action_id%TYPE)
IS

l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
l_business_group_id     NUMBER;
l_start_date            DATE;
l_end_date              DATE;
l_effective_date        DATE;
l_legal_employer        NUMBER;
l_financial_year_code   VARCHAR2(10);
l_test_efile            VARCHAR2(10);
l_financial_year        VARCHAR2(10);
l_legislative_param     VARCHAR2(200);
l_procedure             VARCHAR2(80);
ps_request_id           NUMBER;
  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

CURSOR csr_magtape_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
IS
SELECT  pay_core_utils.get_parameter('TEST_EFILE',legislative_parameters)        TEST_EFILE,
        pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters)        BUSINESS_GROUP_ID,
        pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters)  FINANCIAL_YEAR,
        pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters)    REGISTERED_EMPLOYER,
        to_date(pay_core_utils.get_parameter('START_DATE',legislative_parameters),'YYYY/MM/DD') start_date,
        to_date(pay_core_utils.get_parameter('END_DATE',legislative_parameters),'YYYY/MM/DD')   end_date,
        to_date(pay_core_utils.get_parameter('EFFECTIVE_DATE',legislative_parameters),'YYYY/MM/DD')   EFFECTIVE_DATE
FROM    pay_payroll_actions ppa
WHERE   ppa.payroll_action_id  =  c_payroll_action_id;


CURSOR csr_lookup_code (c_financial_year VARCHAR2)
IS
SELECT LOOKUP_CODE
FROM HR_LOOKUPS
WHERE lookup_type   = 'AU_PS_FINANCIAL_YEAR'
AND enabled_flag    = 'Y'
AND meaning         = c_financial_year;

BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug
THEN
    l_procedure     := g_package||'.spawn_data_file';
    hr_utility.set_location('Entering package       '||l_procedure,4500);
END IF;

ps_request_id :=-1;
l_TEST_EFILE :='N';

OPEN  csr_magtape_params(p_payroll_action_id);
FETCH csr_magtape_params
INTO    l_test_efile,
        l_business_group_id,
        l_financial_year,
        l_legal_employer,
        l_start_date,
        l_end_date,
        l_effective_date;
CLOSE csr_magtape_params;

IF l_TEST_EFILE = 'Y'
THEN
       OPEN  csr_lookup_code(l_financial_year);
       FETCH csr_lookup_code
       INTO  l_financial_year_code;
       CLOSE csr_lookup_code;

    l_legislative_param := 'BUSINESS_GROUP_ID='      || l_business_group_id         ||' '
                || 'FINANCIAL_YEAR='         || l_FINANCIAL_YEAR            ||' '
                || 'REGISTERED_EMPLOYER='    || l_legal_employer            ||' '
                || 'IS_TESTING='             || 'Y'                         ||' '
                || 'ARCHIVE_PAYROLL_ACTION=' || to_char(p_payroll_action_id)||' '
                || 'END_DATE='               || to_char(l_end_date,'YYYY/MM/DD HH:MI:SS')||' '
                || 'PAYMENT_SUMMARY_TYPE=A';

     ps_request_id := fnd_request.submit_request
     ('PAY',
      'PYAUPSDF',
      null,
      null,
      false,
      'ARCHIVE',
      'AU_PS_DATA_FILE_VAL',                 -- Report_format of magtape process
      'AU',
      to_char(l_start_date,'YYYY/MM/DD HH:MI:SS'),
      to_char(l_EFFECTIVE_DATE,'YYYY/MM/DD HH:MI:SS'),
      'REPORT',
      l_business_group_id,
      null,
      null,
      l_legal_employer,
      l_FINANCIAL_YEAR_code,
      'END_DATE='||to_char(l_end_date,'YYYY/MM/DD HH:MI:SS'),
      'Y',                                   -- IS_TESTING Parameter
      'A',
      'AU_PAY_SUMM_AMEND',
      to_number(p_payroll_action_id),        -- Archive_PAyroll_Action
      l_legislative_param                    -- Legislative parameters
     );

END IF;

IF g_debug
THEN
    hr_utility.set_location('Leaving procedure          '||l_procedure,4540);
END IF;

END spawn_data_file;

END pay_au_payment_summary_amend;

/
