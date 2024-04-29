--------------------------------------------------------
--  DDL for Package PAY_SA_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SA_RULES" AUTHID CURRENT_USER as
/* $Header: pysarule.pkh 115.0 2003/12/24 01:38:58 abppradh noship $ */
  procedure get_source_text_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_text in out nocopy varchar2);
  procedure get_source_text2_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_text2 in out nocopy varchar2);
  procedure get_source_number_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_number in out nocopy varchar2);
end pay_sa_rules;

 

/
