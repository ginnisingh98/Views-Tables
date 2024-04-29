--------------------------------------------------------
--  DDL for Package Body PAY_AU_PAYMENT_SUMMARY_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PAYMENT_SUMMARY_MAGTAPE" as
/* $Header: pyaupsm.pkb 120.4.12010000.4 2009/12/16 14:17:37 dduvvuri ship $*/
  -------------------------------------------------------------------------+

--  g_debug boolean := hr_utility.debug_enabled; --Bug3132178
 g_debug boolean := TRUE; --Bug3132178


  procedure range_code
      (p_payroll_action_id   in pay_payroll_actions.payroll_action_id%type,
       p_sql                out NOCOPY varchar2) is
    begin
-- hr_utility.trace_on(null, 'magtape');
	    hr_utility.set_location('Start of range_code',1);
       /*Bug2920725   Corrected base tables to support security model*/

        p_sql := ' select distinct p.person_id' ||
                  ' from   per_people_f p,' ||
                         ' pay_payroll_actions pa ' ||
                  ' where  pa.payroll_action_id = :payroll_action_id' ||
                  ' and    p.business_group_id = pa.business_group_id' ||
                   ' order by p.person_id';

      IF g_debug THEN
	    hr_utility.set_location('End of range_code',2);
      END IF;
  end range_code;

/*
    Bug 8501365 - Added Function range_person_on
--------------------------------------------------------------------
    Name  : range_person_on
    Type  : Function
    Access: Private
    Description: Checks if RANGE_PERSON_ID is enabled for
                 Archive process.
  --------------------------------------------------------------------
    Bug 9113084 - Check if Range Person is enabled for Data File and its Validation
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
  and    map.report_type in ('AU_PS_DATA_FILE','AU_PS_DATA_FILE_VAL')
  and    map.report_format in ('AU_PS_DATA_FILE','AU_PS_DATA_FILE_VAL')
  and    map.report_qualifier = 'AU'
  and    par.parameter_name = 'RANGE_PERSON_ID'; -- Bug fix 5567246

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

    -----------------------------------------------------------------------+
    -- This procedure is used to further restrict the Assignment Action
    -- Creation. It calls the procedure that actually inserts the Assignment
    -- Actions.
  -----------------------------------------------------------------------+

  procedure assignment_action_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       p_start_person_id    in per_all_people_f.person_id%type,
       p_end_person_id      in per_all_people_f.person_id%type,
       p_chunk              in number) is

    v_next_action_id  pay_assignment_actions.assignment_action_id%type;
    v_run_action_id   pay_assignment_actions.assignment_action_id%type;
    p_assignment_id pay_assignment_Actions.assignment_id%type;
    ps_report_id pay_assignment_actions.assignment_action_id%type;
    l_payment_summary_type varchar2(5) := 'O'; /* bug 6630375 */

    ------start of Bug3132178-----------------------------------------------------
    l_testing_flag  varchar2(5):='N';
    l_archive_payroll_action pay_payroll_actions.payroll_action_id%type;


    CURSOR get_parameters
    IS
    SELECT  pay_core_utils.get_parameter('IS_TESTING',ppa.legislative_parameters),
        pay_core_utils.get_parameter('ARCHIVE_PAYROLL_ACTION',ppa.legislative_parameters),
                pay_core_utils.get_parameter('PAYMENT_SUMMARY_TYPE',ppa.legislative_parameters) /* bug 6630375 */
    FROM    pay_payroll_actions ppa
    WHERE   ppa.payroll_Action_id = p_payroll_action_id;


     CURSOR process_assignments_val
      (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       c_start_person_id    in per_all_people_f.person_id%type,
       c_end_person_id      in per_all_people_f.person_id%type)
     IS
       SELECT DISTINCT 'ASSIGNMENT_ACTION_ID=C',
              paa.assignment_action_id ps_report_id,
              paa.assignment_id
         FROM pay_assignment_actions paa,
              per_assignments_f a
        WHERE paa.payroll_action_id = c_payroll_action_id
          AND paa.action_status = 'C'
          AND a.assignment_id = paa.assignment_id
          AND pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG',paa.assignment_action_id)='YES'
      AND pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG',paa.assignment_action_id)='NO'   /* Added for bug 5257622 */
          AND a.person_id BETWEEN c_start_person_id AND c_end_person_id ;

     /* 9113084 - Added range cursor for above cursor process_assignments_val */
     /* 9113084 - Cursor to fetch assignments for Data File Validation when RANGE_PERSON_ID is enabled */
     CURSOR rg_process_assignments_val
      (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       c_chunk IN NUMBER)
     IS
       SELECT DISTINCT 'ASSIGNMENT_ACTION_ID=C',
              paa.assignment_action_id ps_report_id,
              paa.assignment_id
         FROM pay_assignment_actions paa,
              per_assignments_f a,
	      pay_population_ranges ppr
        WHERE paa.payroll_action_id = c_payroll_action_id
	  AND ppr.payroll_action_id = p_payroll_action_id
	  AND ppr.chunk_number = c_chunk
          AND paa.action_status = 'C'
          AND a.assignment_id = paa.assignment_id
          AND pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG',paa.assignment_action_id)='YES'
      AND pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG',paa.assignment_action_id)='NO'
          AND a.person_id = ppr.person_id ;

    --------End of Bug3132178--------------------------------------------------


     /*Bug2920725   Corrected base tables to support security model*/
      CURSOR process_assignments
        (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
         c_start_person_id    in per_all_people_f.person_id%type,
         c_end_person_id      in per_all_people_f.person_id%type) is
       SELECT /*+ INDEX (apac PAY_ASSIGNMENT_ACTIONS_N50)
                  INDEX (ppac PAY_ASSIGNMENT_ACTIONS_PK)
                  INDEX(mpa PAY_PAYROLL_ACTIONS_PK)
                  INDEX(ppai PAY_ACTION_INTERLOCKS_FK2)
                  INDEX (p PER_PEOPLE_F_PK)
                  INDEX(a PER_ASSIGNMENTS_F_PK) */
       DISTINCT 'ASSIGNMENT_ACTION_ID=C',
              ppac.assignment_action_id ps_report_id,
              ppac.assignment_id
         FROM pay_payroll_actions mpa,
             per_people_f p,
              per_assignments_f a,
              pay_payroll_actions apa,
              pay_assignment_actions apac,
              pay_payroll_actions ppa,
              pay_assignment_actions ppac,
              pay_action_interlocks ppai
        WHERE mpa.payroll_action_id =c_payroll_action_id
          AND p.person_id = a.person_id
          AND p.person_id BETWEEN c_start_person_id AND c_end_person_id
          AND p.business_group_id = mpa.business_group_id
          AND apa.payroll_action_id = apac.payroll_action_id
          AND ppa.payroll_action_id = ppac.payroll_action_id
          AND apac.assignment_action_id = ppai.locked_action_id
          AND ppac.assignment_action_id = ppai.locking_action_id
          and apa.action_status = 'C'
          AND ppa.action_status = 'C'
          AND apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
          AND a.assignment_id = apac.assignment_id
          AND a.assignment_id = ppac.assignment_id
          AND apa.report_type ='AU_PAYMENT_SUMMARY'
          AND ppa.report_type = 'AU_PAYMENT_SUMMARY_REPORT'
          AND pay_core_utils.get_parameter('BUSINESS_GROUP_ID',apa.legislative_parameters)=
              pay_core_utils.get_parameter('BUSINESS_GROUP_ID',mpa.legislative_parameters)
          AND pay_core_utils.get_parameter('REGISTERED_EMPLOYER',apa.legislative_parameters)=
              pay_core_utils.get_parameter('REGISTERED_EMPLOYER',mpa.legislative_parameters)
          AND pay_core_utils.get_parameter('FINANCIAL_YEAR',apa.legislative_parameters)=
              pay_core_utils.get_parameter('FINANCIAL_YEAR',mpa.legislative_parameters)
          AND NOT EXISTS  /* 5471093 */
               (SELECT /*+ ORDERED */ locked_action_id
                  FROM pay_action_interlocks pail,
                       pay_assignment_actions paa1,
                       pay_payroll_actions paas
                 WHERE paas.action_type='X'
                   and paas.action_status='C'
                   AND paas.report_type='AU_PS_DATA_FILE'
                   AND paa1.payroll_action_id = paas.payroll_action_id
                   AND pail.locking_action_id = paa1.assignment_action_id
                   AND pail.locked_action_id  = ppac.assignment_action_id);


/*
   Bug 8501365 - Added Cursor for Range Person
               - Uses person_id in pay_population_ranges
  --------------------------------------------------------------------+
  -- Cursor      : range_process_assignments
  -- Description : Fetches assignments For Data File
  --               Used when RANGE_PERSON_ID feature is enabled
  --------------------------------------------------------------------+
*/

        CURSOR range_process_assignments(c_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE,
                                         c_chunk IN NUMBER)
        IS
         SELECT /*+ INDEX (mpa  PAY_PAYROLL_ACTIONS_PK)
                    INDEX (ppr  PAY_POPULATION_RANGES_N4)
                    INDEX (p    PER_PEOPLE_F_PK)
                    INDEX (apa  PAY_PAYROLL_ACTIONS_N52)
                    INDEX (a    PER_ASSIGNMENTS_F_N12)
                    INDEX (apac PAY_ASSIGNMENT_ACTIONS_N51)
                    INDEX (ppai PAY_ACTION_INTERLOCKS_FK2)
                    INDEX (ppac PAY_ASSIGNMENT_ACTIONS_PK)
                  */
       DISTINCT 'ASSIGNMENT_ACTION_ID=C',
              ppac.assignment_action_id ps_report_id,
              ppac.assignment_id
         FROM pay_payroll_actions mpa,
              pay_population_ranges ppr,
              per_people_f p,
              per_assignments_f a,
              pay_payroll_actions apa,
              pay_assignment_actions apac,
              pay_payroll_actions ppa,
              pay_assignment_actions ppac,
              pay_action_interlocks ppai
        WHERE mpa.payroll_action_id = c_payroll_action_id
          AND ppr.payroll_action_id = mpa.payroll_action_id
          AND p.person_id           = ppr.person_id
          AND ppr.chunk_number      = c_chunk
          AND p.person_id           = a.person_id
          AND p.business_group_id   = mpa.business_group_id
          AND apa.payroll_action_id = apac.payroll_action_id
          AND ppa.payroll_action_id = ppac.payroll_action_id
          AND apac.assignment_action_id = ppai.locked_action_id
          AND ppac.assignment_action_id = ppai.locking_action_id
          and apa.action_status = 'C'
          AND ppa.action_status = 'C'
          AND apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
          AND a.assignment_id = apac.assignment_id
          AND a.assignment_id = ppac.assignment_id
          AND apa.report_type  ='AU_PAYMENT_SUMMARY'
          AND apa.report_qualifier = 'AU'
          AND apa.report_category  = 'REPORT'
          AND ppa.report_type  = 'AU_PAYMENT_SUMMARY_REPORT'
          AND ppa.report_qualifier = 'AU'
          AND ppa.report_category  = 'REPORT'
          AND apa.business_group_id = mpa.business_group_id
          AND pay_core_utils.get_parameter('REGISTERED_EMPLOYER',apa.legislative_parameters)=
              pay_core_utils.get_parameter('REGISTERED_EMPLOYER',mpa.legislative_parameters)
          AND pay_core_utils.get_parameter('FINANCIAL_YEAR',apa.legislative_parameters)=
              pay_core_utils.get_parameter('FINANCIAL_YEAR',mpa.legislative_parameters)
          AND NOT EXISTS  /* 5471093 */
               (SELECT locked_action_id
                  FROM pay_action_interlocks pail,
                       pay_assignment_actions paa1,
                       pay_payroll_actions paas
                 WHERE paas.report_type='AU_PS_DATA_FILE'
                   AND paas.report_qualifier = 'AU'
                   AND paas.report_category  = 'REPORT'
                   AND paas.action_status='C'
                   AND paa1.assignment_id    =  a.assignment_id
                   AND paa1.payroll_action_id = paas.payroll_action_id
                   AND pail.locking_action_id = paa1.assignment_action_id
                   AND pail.locked_action_id  = ppac.assignment_action_id);


     CURSOR process_assignments_val_amend /* bug 6630375 */
      (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       c_start_person_id    in per_all_people_f.person_id%type,
       c_end_person_id      in per_all_people_f.person_id%type)
     IS
       SELECT DISTINCT 'ASSIGNMENT_ACTION_ID=C',
              paa.assignment_action_id ps_report_id,
              paa.assignment_id
         FROM pay_assignment_actions paa,
              per_assignments_f a,
              pay_payroll_actions ppa
        WHERE ppa.payroll_action_id = c_payroll_action_id
          AND ppa.payroll_action_id = paa.payroll_action_id
          AND ppa.action_status = 'C'
          AND a.assignment_id = paa.assignment_id
          AND pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG',paa.assignment_action_id)='YES'
      AND pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG',paa.assignment_action_id)='NO'
      AND pay_au_payment_summary.get_archive_value('X_PAYMENT_SUMMARY_TYPE',paa.assignment_action_id)='A'
      AND ppa.report_type = 'AU_PAY_SUMM_AMEND'
      AND a.person_id BETWEEN c_start_person_id AND c_end_person_id ;

     /* 9113084 - Added below range cursor for above cursor process_assignments_val_amend */
     /* 9113084 - Cursor to fetch assigments for Amended Data File Validation when RANGE_PERSON_ID is enabled */
     CURSOR range_assignments_val_amend
      (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       c_chunk IN NUMBER)
     IS
       SELECT DISTINCT 'ASSIGNMENT_ACTION_ID=C',
              paa.assignment_action_id ps_report_id,
              paa.assignment_id
         FROM pay_assignment_actions paa,
              per_assignments_f a,
              pay_population_ranges ppr
        WHERE paa.payroll_action_id = c_payroll_action_id
          AND ppr.payroll_action_id = p_payroll_action_id
	  AND ppr.chunk_number = c_chunk
          AND paa.action_status = 'C'
          AND a.assignment_id = paa.assignment_id
          AND pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG',paa.assignment_action_id)='YES'
      AND pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG',paa.assignment_action_id)='NO'
      AND pay_au_payment_summary.get_archive_value('X_PAYMENT_SUMMARY_TYPE',paa.assignment_action_id)='A'
      AND a.person_id = ppr.person_id ;


      CURSOR process_assignments_amend  /* bug 6630375 */
        (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
         c_start_person_id    in per_all_people_f.person_id%type,
         c_end_person_id      in per_all_people_f.person_id%type) is
       SELECT /*+ INDEX (apac PAY_ASSIGNMENT_ACTIONS_N50)
                  INDEX (ppac PAY_ASSIGNMENT_ACTIONS_PK)
                  INDEX(mpa PAY_PAYROLL_ACTIONS_PK)
                  INDEX(ppai PAY_ACTION_INTERLOCKS_FK2)
                  INDEX (p PER_PEOPLE_F_PK)
                  INDEX(a PER_ASSIGNMENTS_F_PK) */
       DISTINCT 'ASSIGNMENT_ACTION_ID=C',
              ppac.assignment_action_id ps_report_id,
              ppac.assignment_id
         FROM pay_payroll_actions mpa,
             per_people_f p,
              per_assignments_f a,
              pay_payroll_actions apa,
              pay_assignment_actions apac,
              pay_payroll_actions ppa,
              pay_assignment_actions ppac,
              pay_action_interlocks ppai
        WHERE mpa.payroll_action_id =c_payroll_action_id
          AND p.person_id = a.person_id
          AND p.person_id BETWEEN c_start_person_id AND c_end_person_id
          AND p.business_group_id = mpa.business_group_id
          AND apa.payroll_action_id = apac.payroll_action_id
          AND ppa.payroll_action_id = ppac.payroll_action_id
          AND apac.assignment_action_id = ppai.locked_action_id
          AND ppac.assignment_action_id = ppai.locking_action_id
          and apa.action_status = 'C'
          AND ppa.action_status = 'C'
          AND apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
          AND a.assignment_id = apac.assignment_id
          AND a.assignment_id = ppac.assignment_id
          AND apa.report_type ='AU_PAY_SUMM_AMEND'
          AND ppa.report_type = 'AU_PAYMENT_SUMMARY_REPORT'
          AND pay_core_utils.get_parameter('BUSINESS_GROUP_ID',apa.legislative_parameters)=
              pay_core_utils.get_parameter('BUSINESS_GROUP_ID',mpa.legislative_parameters)
          AND pay_core_utils.get_parameter('REGISTERED_EMPLOYER',apa.legislative_parameters)=
              pay_core_utils.get_parameter('REGISTERED_EMPLOYER',mpa.legislative_parameters)
          AND pay_core_utils.get_parameter('FINANCIAL_YEAR',apa.legislative_parameters)=
              pay_core_utils.get_parameter('FINANCIAL_YEAR',mpa.legislative_parameters)
          AND pay_au_payment_summary.get_archive_value('X_PAYMENT_SUMMARY_TYPE', apac.assignment_action_id)='A'
          AND NOT EXISTS  /* 5471093 */
               (SELECT /*+ ORDERED */ locked_action_id
                  FROM pay_action_interlocks pail,
                       pay_assignment_actions paa1,
                       pay_payroll_actions paas
                 WHERE paas.action_type='X'
                   and paas.action_status='C'
                   AND paas.report_type='AU_PS_DATA_FILE'
                   AND paa1.payroll_action_id = paas.payroll_action_id
                   AND pail.locking_action_id = paa1.assignment_action_id
                   AND pail.locked_action_id  = ppac.assignment_action_id);


      /* 9113084 - Added Range Cursor for above cursor process_assignments_amend */
      /* 9113084 - Cursor fetches assignments for Amended Data File when RANGE_PERSON_ID is enabled */
      CURSOR rg_process_assignments_amend
        (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
         c_chunk IN NUMBER) is
       SELECT /*+ INDEX (apac PAY_ASSIGNMENT_ACTIONS_N50)
                  INDEX (ppac PAY_ASSIGNMENT_ACTIONS_PK)
                  INDEX(mpa PAY_PAYROLL_ACTIONS_PK)
                  INDEX(ppai PAY_ACTION_INTERLOCKS_FK2)
                  INDEX (p PER_PEOPLE_F_PK)
                  INDEX(a PER_ASSIGNMENTS_F_PK) */
       DISTINCT 'ASSIGNMENT_ACTION_ID=C',
              ppac.assignment_action_id ps_report_id,
              ppac.assignment_id
         FROM pay_payroll_actions mpa,
             per_people_f p,
              per_assignments_f a,
              pay_payroll_actions apa,
              pay_assignment_actions apac,
              pay_payroll_actions ppa,
              pay_assignment_actions ppac,
              pay_action_interlocks ppai,
	      pay_population_ranges ppr
        WHERE mpa.payroll_action_id =c_payroll_action_id
	  AND ppr.payroll_action_id = mpa.payroll_action_id
	  AND ppr.chunk_number = c_chunk
          AND p.person_id = a.person_id
          AND p.person_id = ppr.person_id
          AND p.business_group_id = mpa.business_group_id
          AND apa.payroll_action_id = apac.payroll_action_id
          AND ppa.payroll_action_id = ppac.payroll_action_id
          AND apac.assignment_action_id = ppai.locked_action_id
          AND ppac.assignment_action_id = ppai.locking_action_id
          and apa.action_status = 'C'
          AND ppa.action_status = 'C'
          AND apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
          AND a.assignment_id = apac.assignment_id
          AND a.assignment_id = ppac.assignment_id
          AND apa.report_type ='AU_PAY_SUMM_AMEND'
          AND ppa.report_type = 'AU_PAYMENT_SUMMARY_REPORT'
          AND pay_core_utils.get_parameter('BUSINESS_GROUP_ID',apa.legislative_parameters)=
              pay_core_utils.get_parameter('BUSINESS_GROUP_ID',mpa.legislative_parameters)
          AND pay_core_utils.get_parameter('REGISTERED_EMPLOYER',apa.legislative_parameters)=
              pay_core_utils.get_parameter('REGISTERED_EMPLOYER',mpa.legislative_parameters)
          AND pay_core_utils.get_parameter('FINANCIAL_YEAR',apa.legislative_parameters)=
              pay_core_utils.get_parameter('FINANCIAL_YEAR',mpa.legislative_parameters)
          AND pay_au_payment_summary.get_archive_value('X_PAYMENT_SUMMARY_TYPE', apac.assignment_action_id)='A'
          AND NOT EXISTS
               (SELECT /*+ ORDERED */ locked_action_id
                  FROM pay_action_interlocks pail,
                       pay_assignment_actions paa1,
                       pay_payroll_actions paas
                 WHERE paas.action_type='X'
                   and paas.action_status='C'
                   AND paas.report_type='AU_PS_DATA_FILE'
                   AND paa1.payroll_action_id = paas.payroll_action_id
                   AND pail.locking_action_id = paa1.assignment_action_id
                   AND pail.locked_action_id  = ppac.assignment_action_id);


  CURSOR next_action_id IS
        SELECT pay_assignment_actions_s.NEXTVAL
        FROM   dual;

   BEGIN

      IF g_debug THEN
          hr_utility.set_location('Start of assignment_action_code',3);
      END IF;
       --------start of Bug3132178-----------------------------------------------------
      OPEN get_parameters;
      FETCH get_parameters INTO l_testing_flag,l_archive_payroll_action,l_payment_summary_type;
      CLOSE get_parameters;


      IF l_testing_flag = 'Y' THEN -- In this case fetch the assignments processed by archival process
       IF l_payment_summary_type = 'O' THEN
          IF range_person_on THEN /* 9113084 - Use new Range Person Cursor if Range Person is enabled */
                   IF g_debug THEN
                      hr_utility.set_location('Using Range Person Cursor for fetching assignments', 5);
                   END IF;
             FOR process_rec IN rg_process_assignments_val (l_archive_payroll_action,
                                                     p_chunk)
             LOOP
               EXIT WHEN rg_process_assignments_val%NOTFOUND;
               OPEN next_action_id;
               FETCH next_action_id INTO v_next_action_id;
               CLOSE next_action_id;
               hr_nonrun_asact.insact(v_next_action_id,
                                     process_rec.assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     NULL);
               IF g_debug THEN
                    hr_utility.set_location('After calling hr_nonrun_asact.insint',5);
               END IF;
              END LOOP;
	  ELSE /* 9113084 - Use Old logic if Range Person is disabled */

             FOR process_rec IN process_assignments_val (l_archive_payroll_action,
                                                     p_start_person_id,
                                                     p_end_person_id)
             LOOP
               EXIT WHEN process_assignments_val%NOTFOUND;
               OPEN next_action_id;
               FETCH next_action_id INTO v_next_action_id;
               CLOSE next_action_id;
               hr_nonrun_asact.insact(v_next_action_id,
                                     process_rec.assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     NULL);
               IF g_debug THEN
                    hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
               END IF;
              END LOOP;
          END IF;
      ELSE /* bug 6630375 */
         IF range_person_on  THEN
                   IF g_debug THEN
                      hr_utility.set_location('Using Range Person Cursor for fetching assignments', 5);
                   END IF;
         FOR process_rec IN range_assignments_val_amend(l_archive_payroll_action,
                                                     p_chunk)
         LOOP
              EXIT WHEN range_assignments_val_amend%NOTFOUND;
              OPEN next_action_id;
              FETCH next_action_id INTO v_next_action_id;
              CLOSE next_action_id;
              hr_nonrun_asact.insact(v_next_action_id,
                                     process_rec.assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     NULL);
              IF g_debug THEN
                    hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
              END IF;
         END LOOP;
	 ELSE  /* 9113084 - Use Old Logic when Range Person is disabled */

         FOR process_rec IN process_assignments_val_amend (l_archive_payroll_action,
                                                     p_start_person_id,
                                                     p_end_person_id)
         LOOP
              EXIT WHEN process_assignments_val_amend%NOTFOUND;
              OPEN next_action_id;
              FETCH next_action_id INTO v_next_action_id;
              CLOSE next_action_id;
              hr_nonrun_asact.insact(v_next_action_id,
                                     process_rec.assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     NULL);
              IF g_debug THEN
                    hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
              END IF;
         END LOOP;
         END IF;
       END IF;
         ------End of Bug3132178-----------------------------------------------------
      ELSE      -- In this case fetch the assignments locked by Self-Printed Process.
       IF l_payment_summary_type = 'O' THEN

           /* Bug 8501365  - Added Changes for Range Person
               - Call Cursor using pay_population_ranges if Range Person Enabled
                 Else call Old Cursor
           */
           IF range_person_on
           THEN

               FOR process_rec IN range_process_assignments
                                                      (p_payroll_action_id,
                                                       p_chunk)
               LOOP
                    EXIT WHEN range_process_assignments%NOTFOUND;
                    OPEN next_action_id;
                    FETCH next_action_id INTO v_next_action_id;
                    CLOSE next_action_id;
                    hr_nonrun_asact.insact(v_next_action_id,
                                           process_rec.assignment_id,
                                           p_payroll_action_id,
                                           p_chunk,
                                           NULL);
                    IF g_debug THEN
                          hr_utility.set_location('Before calling hr_nonrun_asact.insint',14);
                          hr_utility.set_location('locking action' || v_next_action_id, 15);
                          hr_utility.set_location('locked action' ||  process_rec.ps_report_id, 16);
                    END IF;
                    hr_nonrun_asact.insint(v_next_action_id, -- locking action id
                                           process_rec.ps_report_id); -- locked action id

                    IF g_debug THEN
                          hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
                    END IF;
               END LOOP;

           ELSE

               FOR process_rec IN process_assignments (p_payroll_action_id,
                                                       p_start_person_id,
                                                       p_end_person_id)
               LOOP
                    EXIT WHEN process_assignments%NOTFOUND;
                    OPEN next_action_id;
                    FETCH next_action_id INTO v_next_action_id;
                    CLOSE next_action_id;
                    hr_nonrun_asact.insact(v_next_action_id,
                                           process_rec.assignment_id,
                                           p_payroll_action_id,
                                           p_chunk,
                                           NULL);
                    IF g_debug THEN
                          hr_utility.set_location('Before calling hr_nonrun_asact.insint',14);
                          hr_utility.set_location('locking action' || v_next_action_id, 15);
                          hr_utility.set_location('locked action' ||  process_rec.ps_report_id, 16);
                    END IF;
                    hr_nonrun_asact.insint(v_next_action_id, -- locking action id
                                           process_rec.ps_report_id); -- locked action id

                    IF g_debug THEN
                          hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
                    END IF;
               END LOOP;
             END IF;
         ELSE /* bug 6630375 */
	   IF range_person_on THEN /* 9113084 - Use new Range Person Cursor if Range Person is enabled */
                   IF g_debug THEN
                      hr_utility.set_location('Using Range Person Cursor for fetching assignments', 5);
                   END IF;
           FOR process_rec IN rg_process_assignments_amend (p_payroll_action_id,
                                                   p_chunk)
           LOOP
                EXIT WHEN rg_process_assignments_amend%NOTFOUND;
                OPEN next_action_id;
                FETCH next_action_id INTO v_next_action_id;
                CLOSE next_action_id;
                hr_nonrun_asact.insact(v_next_action_id,
                                       process_rec.assignment_id,
                                       p_payroll_action_id,
                                       p_chunk,
                                       NULL);
                IF g_debug THEN
                      hr_utility.set_location('Before calling hr_nonrun_asact.insint',14);
                      hr_utility.set_location('locking action' || v_next_action_id, 15);
                      hr_utility.set_location('locked action' ||  process_rec.ps_report_id, 16);
                END IF;
                hr_nonrun_asact.insint(v_next_action_id, -- locking action id
                                       process_rec.ps_report_id); -- locked action id

                IF g_debug THEN
                      hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
                END IF;
           END LOOP;
	   ELSE /* 9113084 - Use Old Logic if Range Person is disabled */

           FOR process_rec IN process_assignments_amend (p_payroll_action_id,
                                                   p_start_person_id,
                                                   p_end_person_id)
           LOOP
                EXIT WHEN process_assignments_amend%NOTFOUND;
                OPEN next_action_id;
                FETCH next_action_id INTO v_next_action_id;
                CLOSE next_action_id;
                hr_nonrun_asact.insact(v_next_action_id,
                                       process_rec.assignment_id,
                                       p_payroll_action_id,
                                       p_chunk,
                                       NULL);
                IF g_debug THEN
                      hr_utility.set_location('Before calling hr_nonrun_asact.insint',14);
                      hr_utility.set_location('locking action' || v_next_action_id, 15);
                      hr_utility.set_location('locked action' ||  process_rec.ps_report_id, 16);
                END IF;
                hr_nonrun_asact.insint(v_next_action_id, -- locking action id
                                       process_rec.ps_report_id); -- locked action id

                IF g_debug THEN
                      hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
                END IF;
           END LOOP;
	   END IF;
         END IF;
      END IF;
      IF g_debug THEN
          hr_utility.set_location('End of assignment_action_code',5);
      END IF;
   END assignment_action_code;

    -----------------------------------------------------------------------+
    -- This is used by legislation groups to set global contexts that are
    -- required for the lifetime of the archiving process. This is null
    -- because there are no setup requirements, but a procedure needs to
    -- exist in pay_report_format_mappings_f, otherwise the archiver will
    -- assume that no archival of data is required.
  ------------------------------------------------------------------------+

   procedure initialization_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type) is
    begin
       IF g_debug THEN
          hr_utility.set_location('Start of initialization_code',6);
       END IF;
       null;
       IF g_debug THEN
	   hr_utility.set_location('End of initialization_code',7);
       END IF;
    end initialization_code;


  -------------------------------------------------------------------------+
  -- Used to actually perform the archival of data.  We are not archiving
  -- any data here, so this is null.
  ------------------------------------------------------------------------+
    procedure archive_code
      (p_payroll_action_id  in pay_assignment_actions.payroll_action_id%type,
      p_effective_date        in date)
      is

    begin
       IF g_debug THEN
	    hr_utility.set_location('Start of archive_code',8);
       END IF;
       null;
       IF g_debug THEN
             hr_utility.set_location('End of archive_code',9);
       END IF;
     end archive_code;
  ---------------------------------------------------------------------------+

End pay_au_payment_summary_magtape;

/
