--------------------------------------------------------
--  DDL for Package Body PER_IE_VEHICLE_ALLOC_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IE_VEHICLE_ALLOC_RULES" AS
/* $Header: peievehd.pkb 120.0.12000000.4 2007/02/23 09:24:23 rbhardwa ship $ */

PROCEDURE element_end_date_update (
  p_vehicle_allocation_id   IN  NUMBER,
  p_effective_date          IN  DATE) IS

l_proc VARCHAR2(30) := 'PER_IE_VEHICLE_ALLOC_RULES';

CURSOR csr_vehicle_element_entry IS
SELECT pee.element_entry_id,
       max(pee.object_version_number),
       max(ppa.effective_date),
       max(ppa.date_earned)                              -- 5872123
FROM   pay_element_types_f pet,
       pay_element_entry_values_f peev,
       pay_input_values_f piv,
       pay_element_entries_f pee,
       pqp_vehicle_allocations_f pva,
       pay_element_links_f  pel,
       pay_payroll_actions ppa,
       pay_assignment_actions paas,
       pay_run_results prr,
       per_all_assignments_f paa
WHERE  pee.assignment_id = pva.assignment_id
AND    p_effective_date BETWEEN
       pee.effective_start_date AND pee.effective_end_date
AND    pel.element_type_id = pet.element_type_id    -- Bug No.3648575
AND    pel.element_link_id = pee.element_link_id    -- Bug No.3648575
AND    pee.element_type_id + 0 = pet.element_type_id -- Bug No.3648575
AND    pet.element_name = 'IE BIK Company Vehicle'
AND    p_effective_date BETWEEN
       pet.effective_start_date AND pet.effective_end_date -- Bug No.3648575
AND    peev.element_entry_id = pee.element_entry_id
AND    p_effective_date BETWEEN
       peev.effective_start_date AND peev.effective_end_date
AND    peev.screen_entry_value =to_char(p_vehicle_allocation_id)
AND    peev.input_value_id = piv.input_value_id
AND    piv.name = 'Vehicle Allocation'
AND    p_effective_date BETWEEN
        piv.effective_start_date AND piv.effective_end_date
AND    pva.vehicle_allocation_id = p_vehicle_allocation_id
AND    p_effective_date BETWEEN
        pva.effective_start_date AND pva.effective_end_date
AND    p_effective_date BETWEEN
        pel.effective_start_date AND pel.effective_end_date
AND    prr.element_entry_id=pee.element_entry_id
AND    prr.element_type_id=pet.element_type_id
AND    prr.assignment_action_id=paas.assignment_action_id
AND    paas.payroll_action_id=ppa.payroll_action_id
AND    paas.assignment_id=paa.assignment_id
AND    paa.payroll_id=ppa.payroll_id
AND    ppa.action_type in ('R','Q')
AND    ppa.action_status='C'
AND    paa.assignment_id=pva.assignment_id
AND    ppa.effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
AND    ppa.effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date
AND    ppa.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
AND    ppa.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
AND    ppa.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
AND    ppa.effective_date BETWEEN pel.effective_start_date AND pel.effective_end_date
group by pee.element_entry_id;

CURSOR csr_pay_period(p_max_effective_date in DATE,p_max_date_earned in DATE) IS          -- 5872123
SELECT min(ptp.end_date)
FROM   per_time_periods ptp,
       per_all_assignments_f paa,
       pqp_vehicle_allocations_f pva
WHERE  ptp.payroll_id = paa.payroll_id
AND    paa.assignment_id = pva.assignment_id
AND    pva.vehicle_allocation_id = p_vehicle_allocation_id
-- AND    ptp.regular_payment_date>p_max_effective_date;                                  -- 5872123
AND    ptp.end_date>p_max_date_earned
AND    p_max_date_earned not between ptp.start_date and ptp.end_date;


l_effective_end_date    DATE;
l_effective_start_date  DATE;
l_element_entry_id      NUMBER;
l_object_version_number NUMBER := 0;
l_period_end_date       DATE;
l_delete_warning        BOOLEAN;
l_max_effective_date    DATE;
l_max_date_earned       DATE;                                                             -- 5872123

BEGIN

  /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN

    hr_utility.set_location('Entering ' || l_proc,10);
    hr_utility.set_location('p_vehicle_allocation_id = ' ||
                             p_vehicle_allocation_id,10);
    hr_utility.set_location('p_effective_date = ' || p_effective_date,10);

    OPEN  csr_vehicle_element_entry;
    FETCH csr_vehicle_element_entry
    INTO  l_element_entry_id,
        l_object_version_number,
	l_max_effective_date,
	l_max_date_earned;                                                                -- 5872123

    hr_utility.set_location('l_effective_start_date = ' ||
                              to_char(l_element_entry_id),30);
    hr_utility.set_location('l_effective_end_date = ' ||
                              to_char(l_object_version_number),30);
    hr_utility.set_location('l_effective_end_date = ' ||
                              to_char(l_max_effective_date),30);

    IF csr_vehicle_element_entry%FOUND THEN
	OPEN  csr_pay_period(l_max_effective_date,l_max_date_earned);                     -- 5872123
	FETCH csr_pay_period INTO  l_period_end_date;
	CLOSE csr_pay_period;

	hr_utility.set_location('l_element_entry_id = ' || l_element_entry_id,20);
	hr_utility.set_location('l_period_end_date = ' || l_period_end_date,20);
	hr_utility.set_location('Calling delete_element_entry',25);

	pay_element_entry_api.delete_element_entry (
	      p_validate              => FALSE,
	      p_datetrack_delete_mode => 'DELETE',
	      p_effective_date        => l_period_end_date,
	      p_element_entry_id      => l_element_entry_id,
	      p_object_version_number => l_object_version_number,
	      p_effective_start_date  => l_effective_start_date,
	      p_effective_end_date    => l_effective_end_date,
	      p_delete_warning        => l_delete_warning
	    );

	hr_utility.set_location('l_effective_start_date = ' ||
		                     l_effective_start_date,30);
	hr_utility.set_location('l_effective_end_date = ' ||
                             l_effective_end_date,30);
    END IF;

  CLOSE csr_vehicle_element_entry;
  hr_utility.set_location('Leaving ' || l_proc,40);

  END IF;  /* Added for GSI Bug 5472781 */

END element_end_date_update;
END per_ie_vehicle_alloc_rules;

/
