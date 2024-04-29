--------------------------------------------------------
--  DDL for Package Body PAY_HK_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_RULES" as
/* $Header: pyhkrule.pkb 115.1 2002/12/02 10:39:47 srrajago ship $ */
/*
   Copyright (c) Oracle Corporation 2000. All rights reserved
--
   Name        : pay_hk_rules
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -------------------------------------------
   08-Nov-2000  jbailie     115.0  Created.
   02-Dec-2002  srrajago    115.1  Included 'nocopy' option in the 'in out' parameter of the procedure get_source_context,
                                   dbdrv,checkfile commands.
*/
--
--
   procedure get_source_context(p_asg_act_id number,
                                p_ee_id number,
                                p_source_id in out nocopy number)
   is

   cursor csr_get_source is
   select fnd_number.canonical_to_number(target.ENTRY_INFORMATION1)
   from pay_element_entries_f target
       ,pay_assignment_actions paa
       ,pay_payroll_actions ppa
   where ppa.payroll_action_id = paa.payroll_action_id
   and   target.element_entry_id = p_ee_id
   and   target.assignment_id = paa.assignment_id
   and   ppa.effective_date between target.effective_start_date
                                and target.effective_end_date
   and   paa.assignment_action_id = p_asg_act_id;

   begin


   open csr_get_source;
   fetch csr_get_source into p_source_id;
   close csr_get_source;

--
   end get_source_context;

end pay_hk_rules;

/
