--------------------------------------------------------
--  DDL for Package Body PAY_IE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_RULES" as
/*   $Header: pyierule.pkb 120.0 2005/05/29 05:46:40 appldev noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,1994. All rights reserved
--
   Name        : pay_ie_rules
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -------------------------------------------
   07-MAR-2003  vmkhande    115.0  Created(template pyfrrule).
*/
--
--
   procedure get_source_text_context(p_asg_act_id number,
                                     p_ee_id number,
                                     p_source_text in out NOCOPY varchar2)
   is
   begin
           hr_utility.set_location('PAY_ie_RULES.get_source_text_context',1);
          /* removed the defaulting as due to a core bug defulating was being
called even for ASG_YTD dim. this resulted in bugs! */
           --p_source_text := 'IE_A1';
           p_source_text := null;
           hr_utility.set_location('PAY_IE_RULES.get_source_text_context',3);
           hr_utility.set_location('PAY_IE_RULES.get_source_text_context='||
                               p_source_text,4);
   end get_source_text_context;


   PROCEDURE get_main_tax_unit_id
     (p_assignment_id                 IN     NUMBER
     ,p_effective_date                IN     DATE
     ,p_tax_unit_id                   OUT NOCOPY NUMBER ) IS

		CURSOR c_get_tex_unit_id(l_assignment_id number,l_effective_date date) IS
		SELECT to_number(scl.segment4)
		from    per_all_assignments_f asg,
			pay_all_payrolls_f papf,
			hr_soft_coding_keyflex scl
		where	asg.business_group_id = papf.business_group_id
		and	papf.payroll_id = asg.payroll_id
		and	asg.assignment_id = l_assignment_id
		and	l_effective_date between asg.effective_start_date and asg.effective_end_date
		and	l_effective_date between papf.effective_start_date and papf.effective_end_date
		and	papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;
    BEGIN
       -- hr_utility.trace_on('Y','IETUINT');
        hr_utility.set_location('asg_id = ' || p_assignment_id,20);
        hr_utility.set_location('effective_date = ' || p_effective_date,30);

   	  OPEN c_get_tex_unit_id(p_assignment_id,p_effective_date);
   	  FETCH c_get_tex_unit_id INTO p_tax_unit_id ;
   	  CLOSE c_get_tex_unit_id;

   	  hr_utility.set_location('p_tax_unit_id = ' || p_tax_unit_id,30);
    EXCEPTION
   	WHEN others THEN
   	p_tax_unit_id := NULL;
 END get_main_tax_unit_id;

end pay_ie_rules;

/
