--------------------------------------------------------
--  DDL for Package Body PAY_US_UPDATE_TAX_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_UPDATE_TAX_REC_PKG" AS
/* $Header: pyusutxr.pkb 120.0 2005/05/29 10:07:53 appldev noship $ */

     PROCEDURE terminate_emp_tax_records ( p_assignment_id NUMBER
					  ,p_process_date  DATE
					  ,p_actual_termination_date DATE default NULL)
     IS

	l_new_end_date	DATE;
	l_ef_date	DATE;
	l_default_date 	DATE;
	l_dt_mode	VARCHAR2(30);
	l_proc		VARCHAR2(100) := 'pay_us_update_tax_rec_pkg.terminate_emp_tax_records';

	CURSOR csr_tax_defaulting(p_asg_id NUMBER) is
	select	min(ftr.effective_start_date)
	from	pay_us_emp_fed_tax_rules_f ftr
	where	ftr.assignment_id = p_asg_id;


	CURSOR csr_tax_entries(p_asg_id NUMBER,p_ef_date DATE) is
	select	pee.element_entry_id
	from	pay_element_entries_f pee,
		pay_element_links_f pel,
		pay_element_types_f pet
	where	pee.element_link_id = pel.element_link_id
	  and	pel.element_type_id = pet.element_type_id
	  and	p_ef_date between pet.effective_start_date and pet.effective_end_date
	  and	p_ef_date between pel.effective_start_date and pel.effective_end_date
	  and	p_ef_date between pee.effective_start_date and pee.effective_end_date
	  and	(pet.element_name like '%VERTEX%'
	         or upper(pet.element_name) = 'WORKERS COMPENSATION')
	  and	pee.assignment_id = p_asg_id;

     BEGIN

	 hr_utility.trace('Entering: ' || l_proc);
	 open csr_tax_defaulting(p_assignment_id);
	 fetch csr_tax_defaulting into l_default_date;

	 if csr_tax_defaulting%NOTFOUND then
		-- no defaulting, then nothing to do!
		close csr_tax_defaulting;
		return;
	 end if;

	 close csr_tax_defaulting;

	 if (p_process_date is null) then
		if (p_actual_termination_date is null) then
         		hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         		hr_utility.set_message_token('PROCEDURE','PROCESS_US_TAX_RULES');
         		hr_utility.set_message_token('STEP',1);
         		hr_utility.raise_error;

		else
			l_new_end_date := hr_api.g_eot;
			l_ef_date := p_actual_termination_date;
		end if;
	 else
		l_new_end_date := p_process_date;
		l_ef_date := p_process_date;

	 end if;

         if hr_general.chk_maintain_tax_records = 'Y' then

             hr_utility.set_location(l_proc,6);
             UPDATE  pay_us_emp_fed_tax_rules_f peft
             SET     peft.effective_end_date    = l_new_end_date
             WHERE   peft.assignment_id         = p_assignment_id
             AND     l_ef_date
             BETWEEN peft.effective_start_date AND peft.effective_end_date;
             --
	     DELETE pay_us_emp_fed_tax_rules_f peft
	     WHERE  peft.assignment_id 		= p_assignment_id
	     AND    peft.effective_start_date 	> l_ef_date;
	     --
             hr_utility.set_location(l_proc,7);
             UPDATE  pay_us_emp_state_tax_rules_f pest
             SET     pest.effective_end_date    =  l_new_end_date
             WHERE   pest.assignment_id         =  p_assignment_id
             AND     l_ef_date
             BETWEEN pest.effective_start_date AND pest.effective_end_date;
             --
	     DELETE pay_us_emp_state_tax_rules_f pest
	     WHERE  pest.assignment_id 		= p_assignment_id
	     AND    pest.effective_start_date 	> l_ef_date;
	     --
             hr_utility.set_location(l_proc,8);
             UPDATE  pay_us_emp_county_tax_rules_f pect
             SET     pect.effective_end_date    =  l_new_end_date
             WHERE   pect.assignment_id         = p_assignment_id
             AND     l_ef_date
             BETWEEN pect.effective_start_date  AND pect.effective_end_date;
             --
	     DELETE pay_us_emp_county_tax_rules_f pect
	     WHERE  pect.assignment_id 		= p_assignment_id
	     AND    pect.effective_start_date 	> l_ef_date;
             --
             hr_utility.set_location(l_proc,9);
             UPDATE  pay_us_emp_city_tax_rules_f pecit
             SET     pecit.effective_end_date   =  l_new_end_date
             WHERE   pecit.assignment_id        =  p_assignment_id
             AND     l_ef_date
             BETWEEN pecit.effective_start_date AND pecit.effective_end_date;
             --
	     DELETE pay_us_emp_city_tax_rules_f pecit
	     WHERE  pecit.assignment_id 	= p_assignment_id
	     AND    pecit.effective_start_date 	> l_ef_date;
             --
	end if; -- maintaining tax records

	if hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                          p_legislation => 'US')
	   and p_process_date is null  then

	     -- We need to clean out the Vertex Element Entries.
	     -- We don't want to end date them, just erase any future changes.
	     -- We don't do anything if final_process date is set, since
	     -- the element ending code will handle that case.

	   -- if defaulting has happened in the future, we want to zap the ee's
	   -- else we want to delete any changes after the ATD

	   if l_default_date > l_ef_date then
		l_ef_date := l_default_date;
		l_dt_mode := hr_api.g_zap;
	   else
		l_dt_mode := hr_api.g_future_change;
	   end if;

	   hr_utility.set_location(l_proc,10);
	   for c_ele_rec in csr_tax_entries(p_assignment_id,l_ef_date)
	   loop

		hr_entry_api.delete_element_entry(
 		 p_dt_delete_mode  	=> l_dt_mode,
  		 p_session_date		=> l_ef_date,
  		 p_element_entry_id    	=> c_ele_rec.element_entry_id
 		);


	   end loop;

	end if; -- payroll installed

	hr_utility.trace(' Leaving: ' || l_proc);


     EXCEPTION
          when NO_DATA_FOUND then
               NULL;

     END terminate_emp_tax_records;


     PROCEDURE reverse_term_emp_tax_records ( p_assignment_id  NUMBER
                                             ,p_process_date   DATE)
     IS
     BEGIN
     --
        hr_utility.trace('Entered reverse_term_emp_tax_records for assign ' ||
                         p_assignment_id );
        --
	hr_utility.set_location
	('pay_us_update_tax_rec_pkg.reverse_term_emp_tax_records',5);
        UPDATE  pay_us_emp_fed_tax_rules_f peft
        SET     peft.effective_end_date    =
                to_date('31/12/4712','DD/MM/YYYY')
        WHERE   peft.assignment_id         = p_assignment_id
        AND     peft.effective_end_date    = p_process_date;
        --
	hr_utility.set_location
	('pay_us_update_tax_rec_pkg.reverse_term_emp_tax_records',6);
        UPDATE  pay_us_emp_state_tax_rules_f pest
        SET     pest.effective_end_date    =
                to_date('31/12/4712','DD/MM/YYYY')
        WHERE   pest.assignment_id         = p_assignment_id
        AND     pest.effective_end_date    = p_process_date;
        --
	hr_utility.set_location
	('pay_us_update_tax_rec_pkg.reverse_term_emp_tax_records',7);
        UPDATE  pay_us_emp_county_tax_rules_f pect
        SET     pect.effective_end_date    =
                to_date('31/12/4712','DD/MM/YYYY')
        WHERE   pect.assignment_id         = p_assignment_id
        AND     pect.effective_end_date    = p_process_date;
       --
	hr_utility.set_location
	('pay_us_update_tax_rec_pkg.reverse_term_emp_tax_records',8);
        UPDATE  pay_us_emp_city_tax_rules_f pecit
        SET     pecit.effective_end_date   =
                to_date('31/12/4712','DD/MM/YYYY')
        WHERE   pecit.assignment_id        = p_assignment_id
        AND     pecit.effective_end_date   = p_process_date;
        --
        EXCEPTION
           when NO_DATA_FOUND then
                NULL;

     END reverse_term_emp_tax_records;

end pay_us_update_tax_rec_pkg;

/
