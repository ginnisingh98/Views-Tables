--------------------------------------------------------
--  DDL for Package Body PAY_AU_TFN_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_TFN_MAGTAPE" AS
/* $Header: pyautfn.pkb 120.7.12010000.6 2009/10/13 13:55:46 dduvvuri ship $*/
------------------------------------------------------------------------------+


/* Bug 4066194 - REMOVED implementation
       Procedure - populate_tfn_flags
       Function  -  get_tfn_flag_values
   Above components moved to package "pay_au_tfn_magtape_flags".
*/

------------------------------------------------------------------------------+
-- This procedure sets the value of the global variable 'tax_api_called_from'
-- The value is set to 'FORM' in 'Tax Declaration' form when making changes to
-- the tax details.
------------------------------------------------------------------------------+

PROCEDURE set_value(p_value  in varchar2) IS

BEGIN
   hr_utility.trace('Start of procedure set_value');
   tax_api_called_from := p_value;
   hr_utility.trace('p value : ' || p_value);
   hr_utility.trace('End of procedure set_value');



EXCEPTION
   WHEN OTHERS THEN
      hr_utility.trace('Error in set_value');
      RAISE;

END set_value;


------------------------------------------------------------------------------+
-- This function returns the value stored in the variable 'tax_api_called_from'
-- It is used in the API 'HR_AU_TAX_API' to check if the API procedures are
-- called from the 'FORM' or from the wrapper APIs.
------------------------------------------------------------------------------+

FUNCTION get_value RETURN varchar2 IS
BEGIN
/* Bug 4066194 - IF Section Added for Resolving GSCC Warnings
   Default Value is 'API' */
   if (tax_api_called_from is null)
   then
       tax_api_called_from := 'API';
   end if;
   RETURN tax_api_called_from;
END;





------------------------------------------------------------------------------+
-- This procedure is used to select the range of persons to be considered
-- for the archicve process.
------------------------------------------------------------------------------+

PROCEDURE range_code
      (p_payroll_action_id   in  pay_payroll_actions.payroll_action_id%TYPE,
       p_sql                 out nocopy varchar2) IS

BEGIN

   hr_utility.set_location('Start of range_code',1);

/*Bug2920725   Corrected base tables to support security model*/

   p_sql := ' SELECT distinct p.person_id' ||
             ' FROM   per_people_f p,' ||
                    ' pay_payroll_actions pa ' ||
             ' WHERE  pa.payroll_action_id = :payroll_action_id' ||
             ' AND    p.business_group_id = pa.business_group_id' ||
             ' ORDER BY p.person_id';

   hr_utility.set_location('End of range_code',2);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.trace('Error in range_code');
      RAISE;
END range_code;





----------------------------------------------------------------------------+
-- This procedure is used to further restrict the Assignment Action
-- Creation. It calls the procedure that actually inserts the Assignment
-- Actions. We need this to restrict person from being reported on the
-- magtape once again.
----------------------------------------------------------------------------+

PROCEDURE assignment_action_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
       p_start_person_id    in per_all_people_f.person_id%TYPE,
       p_END_person_id      in per_all_people_f.person_id%TYPE,
       p_chunk              in number) IS

   v_next_action_id  pay_assignment_actions.assignment_action_id%TYPE;
   v_run_action_id   pay_assignment_actions.assignment_action_id%TYPE;
   p_assignment_id   pay_assignment_actions.assignment_id%TYPE;
   ps_report_id      pay_assignment_actions.assignment_action_id%TYPE;


   ----------------------------------------------------------------------------------
   -- Cursor to restrict the assignments to be processed by the magtape.
   -- It selects all assignments of the input 'Legal Employer' who has changed the
   -- tax detail fields value in the current reporting period.
   -- Select all assignments -
   --   1. Within the legal employer
   --   2. Either terminated OR tax details updated in the current reporting period
   --   3. Not already reported by a magtape in the current reporting period.
   ----------------------------------------------------------------------------------

   /* Bug 2728358 - Added check for employee terminated on report end date */

  /*Bug2920725   Corrected base tables to support security model*/

   /* Bug 2974527 - Added trunc for fnd_date.canonical_to_date function */
   /* Bug 2974527 - Backed out the changed for Bug 2974527*/
   /* Bug 3229452 - Used fnd_date.canonical_to_date instead of to_date for selecting
                    report end date from ppa.legislative paramenters */
   /* Bug 4215439 - Added ORDERED hint TO the assignment cursor*/
    /*Bug 5348307 - Commented condition
                    c_report_end_date BETWEEN paa.effective_start_date AND paa.effective_end_date
                    and condition
                    paa.effective_start_date between c_report_end_date - 13 and c_report_end_date */
   /* Bug 8352719 - Removed NULL termination date check at 2 places and a redundant join*/
   CURSOR process_assignments
     (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
      c_start_person_id    in per_all_people_f.person_id%TYPE,
      c_end_person_id      in per_all_people_f.person_id%TYPE,
      c_business_group_id  in per_business_groups.business_group_id%TYPE,
      c_legal_employer_id  in hr_soft_coding_keyflex.segment1%TYPE,
      c_report_end_date    in date) IS
   SELECT  /*+ ORDERED */ paa.assignment_id,
  	   decode(sign(nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY')) - c_report_end_date),1,
  			null,pps.actual_termination_date) actual_termination_date,
           peev.screen_entry_value tax_file_number
     FROM  pay_payroll_actions        ppa
          ,per_people_f           pap
          ,per_assignments_f      paa
          ,hr_soft_coding_keyflex     hsc
          ,per_periods_of_service     pps
          ,pay_element_entries_f      pee
          ,pay_element_links_f        pel
          ,pay_element_types_f        pet
          ,pay_input_values_f         piv
          ,pay_element_entry_values_f peev
    WHERE  ppa.payroll_action_id       = c_payroll_action_id
      AND  pap.person_id                BETWEEN c_start_person_id AND c_end_person_id
      AND  pap.person_id               = paa.person_id
      AND  paa.business_group_id       = c_business_group_id
      AND  pap.business_group_id       = ppa.business_group_id
      AND  paa.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
      AND  hsc.segment1                = c_legal_employer_id
      AND  pps.person_id               = paa.person_id
      And  pps.period_of_service_id    = paa.period_of_service_id
      AND  pps.date_start= (select max(pps1.date_start)
	  	  		 from per_periods_of_service pps1
	  	  		  where pps1.person_id=pps.person_id
                                  AND  pps1.date_start <= c_report_end_date
		           )  /*Bug2751008*/
      AND  paa.effective_start_date    = (SELECT max(effective_Start_date)
                                            FROM  per_assignments_f a
                                           WHERE  a.assignment_id = paa.assignment_id
                                           and a.effective_start_date <= c_report_end_Date /*5474358 */
                                           group by a.assignment_id
                                            )
      AND  pap.effective_start_date    = (SELECT max(effective_Start_date)
                                            FROM  per_people_f p
                                           WHERE  p.person_id = pap.person_id
                                           and p.effective_start_Date <= c_report_end_date  /*5474358 */
                                            group by p.person_id)
      AND  pet.element_name            = 'Tax Information'
      AND  pel.element_type_id         = pet.element_type_id
      AND  pee.element_link_id         = pel.element_link_id
      AND  pee.assignment_id           = paa.assignment_id
      AND  pee.entry_information_category = 'AU_TAX DEDUCTIONS'
      AND  ((trunc(fnd_date.canonical_to_date(pee.entry_information1)) BETWEEN c_report_end_date -13 AND c_report_end_date) /* 8352719 */
            OR  (nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY')) BETWEEN c_report_end_date - 13 AND c_report_end_date  and peev.screen_entry_value = '111 111 111'))
      AND  piv.name                    = 'Tax File Number'
      AND  piv.element_type_id         = pet.element_type_id
      AND  peev.input_value_id         = piv.input_value_id
      AND  peev.element_entry_id       = pee.element_entry_id
      AND  pee.effective_start_date    =
                 (SELECT  max(pee1.effective_start_date)
                    FROM  pay_element_types_f    pet1
                         ,pay_element_links_f    pel1
                         ,pay_element_entries_f  pee1
                   WHERE pet1.element_name     = 'Tax Information'
                     AND pet1.element_type_id  = pel1.element_type_id
                     AND pel1.element_link_id  = pee1.element_link_id
                     AND pee1.assignment_id    = paa.assignment_id
		     AND pee1.entry_information1 is not null /*Bug 5356467*/
                     AND pee1.effective_start_date <= c_report_end_date
                     AND pel1.effective_start_date BETWEEN pet1.effective_start_date
                                                       AND pet1.effective_end_date
                  )
      AND  peev.effective_start_date   = (SELECT max(peev1.effective_start_date)
	                                    FROM pay_element_entry_values_f peev1
					   WHERE peev1.element_entry_value_id = peev.element_entry_value_id
					     AND peev1.effective_start_date <=  c_report_end_date)
      /* 8352719 - removed the redundant join */
      AND  c_report_end_date BETWEEN pap.effective_start_date AND pap.effective_end_date   /* 4620635 */
      AND  c_report_end_date BETWEEN pet.effective_start_date AND pet.effective_end_date
      AND  c_report_end_date BETWEEN pel.effective_start_date AND pel.effective_end_date
      AND  c_report_end_date BETWEEN piv.effective_start_date AND piv.effective_end_date
      AND  NOT EXISTS
           (SELECT  1
              FROM  pay_payroll_actions    ppa,
                    pay_assignment_actions pac
              WHERE pac.assignment_id      = paa.assignment_id
         	AND ppa.payroll_Action_id  = pac.payroll_action_id
         	AND fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORT_END_DATE',ppa.legislative_parameters))
         	            BETWEEN c_report_end_date - 13 AND c_report_end_date
                AND pac.action_status      = 'C'
         	AND ppa.action_TYPE        = 'X'
         	AND ppa.report_TYPE        = 'AU_TFN_MAGTAPE');



   ----------------------------------------------------------------------------------
   -- Cursor to fetch the passed parameters to the magtape process
   ----------------------------------------------------------------------------------
  /* Bug 2974527 - Changed the cursor to consider report end date -1 */
  /* Bug 3229452 - Used fnd_date.canonical_to_date instead of to_date for selecting
                    report end date from ppa.legislative paramenters */
   CURSOR c_get_parameters( c_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE) IS
   SELECT
         pay_core_utils.get_parameter('BUSINESS_GROUP_ID',ppa.legislative_parameters),
         pay_core_utils.get_parameter('LEGAL_EMPLOYER',ppa.legislative_parameters),
         fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORT_END_DATE',ppa.legislative_parameters))-1
    FROM pay_payroll_actions ppa
   WHERE ppa.payroll_action_id = c_payroll_action_id;

   l_business_group_id  per_business_groups.business_group_id%TYPE;
   l_legal_employer_id  hr_soft_coding_keyflex.segment1%TYPE;
   l_report_end_date    date;

   CURSOR next_action_id IS
   SELECT pay_assignment_actions_s.nextval
     FROM dual;

BEGIN

   hr_utility.set_location('Start of assignment_action_code',3);

   OPEN c_get_parameters(p_payroll_action_id);
   FETCH c_get_parameters INTO l_business_group_id,
                               l_legal_employer_id,
                               l_report_end_date;
   CLOSE c_get_parameters;


   FOR process_rec in process_assignments (p_payroll_action_id,
                                           p_start_person_id,
                                           p_end_person_id,
                                           l_business_group_id,
                                           l_legal_employer_id,
                                           l_report_end_date)
   LOOP
     EXIT WHEN process_assignments%NOTFOUND;

     -- If the employee's TFN is '111 111 111' and not terminated in the current reporting
     -- period, then employee is not eligible for magtape.

     IF (process_rec.tax_file_number= '111 111 111' AND
         nvl(process_rec.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY')) NOT BETWEEN (l_report_end_date - 13)
                                                                                AND l_report_end_date) THEN
        hr_utility.trace('Employee not eligible for magtape');
     ELSE
        hr_utility.trace(' In the assignment action insertion ');

        OPEN next_action_id;
        FETCH next_action_id INTO v_next_action_id;
        CLOSE next_action_id;

        hr_nonrun_asact.insact(v_next_action_id,
                               process_rec.assignment_id,
                               p_payroll_action_id,
                               p_chunk,
                               null);
     END IF;


   END LOOP;

   hr_utility.set_location('End of assignment_action_code',5);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.trace('Error in assignment_action_code');
      RAISE;

END assignment_action_code;


----------------------------------------------------------------------------+
-- This IS used by legislation groups to set global contexts that are
-- required for the lifetime of the archiving process.
-- We call the procedure 'populate_tfn_flags' to populate the
-- plsql table as the table used by the cursor in magtape to select the
-- eligible employees to print on the magtape.
-----------------------------------------------------------------------------+

PROCEDURE initialization_code
   (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE) IS


   ----------------------------------------------------------------------------------
   -- CURSOR to FETCH the passed parameters to the magtape process
   ----------------------------------------------------------------------------------
  /* Bug 2974527 - Changed the cursor to consider report end date -1 */
  /* Bug 3229452 - Used fnd_date.canonical_to_date instead of to_date for selecting
                   report end date from ppa.legislative paramenters */
   CURSOR c_get_parameters( c_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE) IS
   SELECT
         pay_core_utils.get_parameter('BUSINESS_GROUP_ID',ppa.legislative_parameters),
         pay_core_utils.get_parameter('LEGAL_EMPLOYER',ppa.legislative_parameters),
         fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORT_END_DATE',ppa.legislative_parameters))-1
   FROM  pay_payroll_actions ppa
   WHERE ppa.payroll_action_id = c_payroll_action_id;

   l_business_group_id  per_business_groups.business_group_id%TYPE;
   l_legal_employer_id  hr_soft_coding_keyflex.segment1%TYPE;
   l_report_end_date    date;


BEGIN

   hr_utility.set_location('Start of initialization_code',6);

   OPEN c_get_parameters(p_payroll_action_id);
   FETCH c_get_parameters INTO l_business_group_id,
                               l_legal_employer_id,
                               l_report_end_date;
   CLOSE c_get_parameters;

   --Call populate_tfn_flags to populate the plsql tables

   /* Bug 4066194 - Changed procedure call to refer to
      procedure in package - pay_au_tfn_magtape_flags
   */


   pay_au_tfn_magtape_flags.populate_tfn_flags(p_payroll_action_id,
                      to_number(l_business_group_id),
                      l_legal_employer_id,
                      l_report_end_date);


   hr_utility.set_location('End of initialization_code',7);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.trace('Error in initialization_code');
      RAISE;

END initialization_code;


------------------------------------------------------------------------------+
-- Used to actually perform the archival of data.  We are not archiving
-- any data here, so thIS IS null.
-----------------------------------------------------------------------------+

PROCEDURE archive_code
      (p_payroll_action_id  in pay_assignment_actions.payroll_action_id%TYPE,
       p_effective_date     in date) IS

BEGIN
   hr_utility.set_location('Start of archive_code',8);
   null;
   hr_utility.set_location('End of archive_code',9);
END archive_code;


END pay_au_tfn_magtape;

/
