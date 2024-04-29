--------------------------------------------------------
--  DDL for Package Body PER_GB_REVERSE_TERM_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_REVERSE_TERM_RULES" AS
/* $Header: pegbrtmr.pkb 120.0.12010000.2 2010/04/15 13:25:52 npannamp noship $ */

--
-------------------------------------------------------------------------------
-- VALIDATE_REVERSE_TERMINATION
-------------------------------------------------------------------------------

PROCEDURE VALIDATE_REVERSE_TERMINATION(p_person_id          		IN NUMBER
									  ,p_actual_termination_date 	IN DATE
) IS
--
l_proc VARCHAR2(30) ;
--
cursor csr_all_assignments is
SELECT paaf.assignment_id,
		 paaf.assignment_number
FROM     per_all_assignments_f  paaf,
         per_assignment_status_types past
WHERE  paaf.person_id = p_person_id
and p_actual_termination_date between paaf.effective_start_date and paaf.effective_end_date
AND paaf.assignment_status_type_id = past.assignment_status_type_id
AND past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN');

--
BEGIN
  --
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
   --
   l_proc := 'VALIDATE_REVERSE_TERMINATION';

   hr_utility.set_location('Entering:'|| l_proc, 10);
   for l_asg in csr_all_assignments
   loop
   hr_utility.trace(l_proc||': Checking for P45'||
                      ', p_assignment_id='||l_asg.assignment_id);
   --
   -- Check if P45 is issued for this Assignnment
   -- if issued, error message should be shown.
   --
   if pay_p45_pkg.return_p45_issued_flag(l_asg.assignment_id) = 'Y' then
           hr_utility.trace(l_proc||': P45 issued for Assignment ID : '||l_asg.assignment_id);
	   hr_utility.set_message(800,'HR_GB_78150_P45_ISSUED_SS');
  	   hr_utility.raise_error;
   end if;
   --
   end loop;
   hr_utility.trace(l_proc||': P45 check completed ');
   --

 END IF;
 --
 hr_utility.set_location('Leaving:'|| l_proc, 100);
 --
END VALIDATE_REVERSE_TERMINATION;
--

--
END PER_GB_REVERSE_TERM_RULES;

/
