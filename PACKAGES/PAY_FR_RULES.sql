--------------------------------------------------------
--  DDL for Package PAY_FR_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_RULES" AUTHID CURRENT_USER as
/*   $Header: pyfrrule.pkh 115.6 2004/01/09 08:45:12 aparkes noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,1994. All rights reserved
--
   Name        : pay_fr_rules
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -------------------------------------------
   01-FEB-2001  asnell      115.0  Created(template pycarule).
   07-JUN-2001  asnell      115.1  added get_source_context
   10-OCT-2002  srjadhav    115.2  Added get_dynamic_org_meth
   07-JUN-2001  asnell      115.3  added nocopy to out parms
   10-APR-2003  aparkes     115.4  2898674 added get_multi_tax_unit_pay_flag
   11-NOV-2003  aparkes     115.5  Added retro context override hook
   08-JAN-2004  aparkes     115.6  Added get_source_text2_context (for bug
                                   3360253) and get_source_number_context,
                                   following bug 3305989.
*/
   procedure get_source_text_context(p_asg_act_id number,
                                      p_ee_id number,
                                      p_source_text in out nocopy varchar2);

   procedure get_source_text2_context(p_asg_act_id number,
                                      p_ee_id number,
                                      p_source_text2 in out nocopy varchar2);

   procedure get_source_context(      p_asg_act_id number,
                                      p_ee_id number,
                                      p_source_id in out nocopy varchar2);

   procedure get_source_number_context(p_asg_act_id number,
                                       p_ee_id number,
                                       p_source_number in out nocopy varchar2);

   PROCEDURE get_dynamic_org_meth
				  (p_assignment_action_id in number
				   ,p_effective_date       in date
				   ,p_org_meth             in number   -- org meth with no bank account
				   ,p_org_method_id        out nocopy number); -- replacement org meth

   procedure get_multi_tax_unit_pay_flag(p_bus_grp in number,
                                         p_mtup_flag in out nocopy varchar2);

-- retro context override hook
   procedure retro_context_override(p_element_entry_id  in number,
                                    p_context_name      in varchar2,
                                    p_context_value     in varchar2,
                                    p_replacement_value out nocopy varchar2);
--
end pay_fr_rules;

 

/
