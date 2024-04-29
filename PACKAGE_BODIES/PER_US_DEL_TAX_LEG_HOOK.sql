--------------------------------------------------------
--  DDL for Package Body PER_US_DEL_TAX_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_DEL_TAX_LEG_HOOK" AS
/* $Header: pyusdel.pkb 120.0.12010000.2 2009/04/22 11:39:44 pannapur noship $ */

 PROCEDURE DELETE_US_TAX_INFO
         (P_PERSON_ID in NUMBER
         ,P_EFFECTIVE_DATE in DATE
        )
IS
  --
  cursor csr_assignment_id(p_person_id NUMBER,p_effective_date DATE)
  is
	select assignment_id
	from per_all_assignments_f PAA,per_periods_of_service PPS
        where PAA.person_id=p_person_id
	and PAA.period_of_service_id=PPS.period_of_service_id
        and p_effective_date between PPS.date_start and
	nvl(PPS.actual_termination_date,to_date('4712/12/31', 'YYYY/MM/DD'));

  l_assignment_id NUMBER;

--

BEGIN

hr_utility.set_location('Entering: PER_US_DEL_TAX_LEG_HOOK.DELETE_US_TAX_INFO', 10);

 open csr_assignment_id(p_person_id,p_effective_date);
 Loop
     fetch csr_assignment_id into l_assignment_id;

      pay_us_tax_internal.maintain_us_employee_taxes (
          p_effective_date =>  P_EFFECTIVE_DATE
         ,p_datetrack_mode => 'ZAP'
         ,p_assignment_id  => l_assignment_id
         ,p_delete_routine => 'ASSIGNMENT' );

      exit when csr_assignment_id%NOTFOUND;

  hr_utility.trace('Deleted the tax records of '||l_assignment_id);

 END Loop ;
 close csr_assignment_id;

hr_utility.set_location('Leaving: PER_US_DEL_TAX_LEG_HOOK.DELETE_US_TAX_INFO', 20);

EXCEPTION

  WHEN OTHERS THEN
   hr_utility.trace('Exception raised in PER_US_DEL_TAX_LEG_HOOK.DELETE_US_TAX_INFO');
   hr_utility.set_location('Leaving: PER_US_DEL_TAX_LEG_HOOK.DELETE_US_TAX_INFO', 30);
   hr_utility.oracle_error(sqlcode);
   hr_utility.raise_error;

--
END DELETE_US_TAX_INFO;

END PER_US_DEL_TAX_LEG_HOOK;


/
