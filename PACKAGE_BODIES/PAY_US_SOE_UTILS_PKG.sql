--------------------------------------------------------
--  DDL for Package Body PAY_US_SOE_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_SOE_UTILS_PKG" as
/* $Header: pyussoeu.pkb 115.3 2002/09/07 00:27:40 ekim ship $  */

/***************************************************************************
*  Copyright (c)1999 Oracle Corporation, Redwood Shores, California, USA   *
*                          All rights reserved.                            *
****************************************************************************
*                                                                          *
* File:  pyussoeu.pkb                                                      *
*                                                                          *
* Description:                                                             *
*                                                                          *
*                                                                          *
*                                                                          *
* History                                                                  *
* -----------------------------------------------------                    *
* 26-JUN-1999         pganguly        Created                              *
*                                                                          *
* 03-oct-2001  115.1  tclewis         modified cusror cur_base_salary      *
*                               to use least                               *
*                               nvl(ppa.date_earned, ppa.effective_date)   *
*                               actual termination date                    *
* 06-Sep-2002  115.2  ekim      Changed to fnd_number.canonical_to_number  *
*                               in  cur_base_salary                        *
* 06-Sep-2002  115.3  ekim      Added dbdrv command.                       *
***************************************************************************/

function get_base_sal( p_assignment_action_id in number)
			return number is
begin

declare

	l_salary number;
	l_term_date date;
        l_date	date;

        cursor cur_get_date is
	select
		nvl(ppa.date_earned, ppa.effective_date)
        from 	pay_payroll_actions ppa,
		pay_assignment_actions paa
        where 	paa.assignment_action_id = p_assignment_action_id
        and   	ppa.payroll_action_id   = paa.payroll_action_id;

	cursor cur_actual_termination_date is
	select
		pos.actual_termination_date
	from 	per_periods_of_service pos,
		per_assignments_f paf,
		pay_assignment_actions paa,
		pay_payroll_actions ppa
	where   paf.assignment_id 	= paa.assignment_id
	and     ppa.payroll_action_id 	= paa.payroll_action_id
	and 	paa.assignment_action_id = p_assignment_action_id
	and 	l_date between paf.effective_start_date
		       and paf.effective_end_date
	and 	paf.period_of_service_id = pos.period_of_service_id;

	cursor cur_base_salary is
	select
      		fnd_number.canonical_to_number(peev.screen_entry_value)
	from
       		pay_element_entries_f pee,
       		pay_element_entry_values_f peev,
       		pay_input_values_f piv,
       		per_pay_bases ppb,
       		per_assignments_f paf,
       		pay_payroll_actions ppa,
       		pay_assignment_actions paa
	where
		least(nvl(ppa.date_earned, ppa.effective_date),
              nvl(l_term_date, nvl(ppa.date_earned, ppa.effective_date)
                  )
              )
               between
           		pee.effective_start_date and pee.effective_end_date
		and    pee.element_entry_id = peev.element_entry_id
		and    pee.entry_type = 'E'
		and    pee.assignment_id = paf.assignment_id
		and    least(nvl(ppa.date_earned, ppa.effective_date),
                     nvl(l_term_date, nvl(ppa.date_earned, ppa.effective_date)
                         )
                     )
                  between
           		peev.effective_start_date and peev.effective_end_date
		and    peev.input_value_id+0 = piv.input_value_id
		and    least(nvl(ppa.date_earned, ppa.effective_date),
                     nvl(l_term_date, nvl(ppa.date_earned, ppa.effective_date)
                         )
                     )
                  between
           		piv.effective_start_date and piv.effective_end_date
		and    piv.input_value_id = ppb.input_value_id
		and    ppb.pay_basis_id = paf.pay_basis_id
		and    nvl(ppa.date_earned, ppa.effective_date) between
          		paf.effective_start_date and paf.effective_end_date
		and    paf.assignment_id = paa.assignment_id
		and    ppa.payroll_action_id = paa.payroll_action_id
		and    paa.assignment_action_id = p_assignment_action_id;

begin
	open  cur_get_date;
	fetch cur_get_date
	into  l_date;
	close cur_get_date;

	open  cur_actual_termination_date;
	fetch cur_actual_termination_date
	into  l_term_date;
	close cur_actual_termination_date;

	open  cur_base_salary;
	fetch cur_base_salary
	into  l_salary;
	close cur_base_salary;

	return(l_salary);
end;
end get_base_sal;

end pay_us_soe_utils_pkg;

/
