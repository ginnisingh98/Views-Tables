--------------------------------------------------------
--  DDL for Package PAY_ZA_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_RULES" AUTHID CURRENT_USER as
/* $Header: pyzarule.pkh 120.0 2006/04/12 01:03:14 kapalani noship $ */
  procedure get_source_text_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_text in out nocopy varchar2);
  procedure get_source_number_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_number in out nocopy varchar2);
end pay_za_rules;

 

/
