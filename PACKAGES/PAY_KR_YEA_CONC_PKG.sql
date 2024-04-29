--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_CONC_PKG" AUTHID CURRENT_USER as
/* $Header: pykrycon.pkh 120.1.12000000.1 2007/01/17 22:19:51 appldev noship $ */
-------------------------------------------------------------------------
  procedure submit_yea (errbuf				out nocopy  varchar2,
			retcode				out nocopy  varchar2,
                        p_yea_type			in  varchar2,
                        p_effective_date		in  varchar2,
                        p_business_group_id		in  per_all_people_f.business_group_id%type,
                        p_payroll_id			in  pay_payroll_actions.payroll_id%type,
			p_action_parameter_group_id	in  pay_action_parameter_groups.action_parameter_group_id%type,
			p_consolidation_set_id		in  pay_consolidation_sets.consolidation_set_id%type,
                        p_assignment_set_id		in  hr_assignment_sets.assignment_set_id%type,
                        p_element_type_id		in  pay_element_types.element_type_id%type,
                        p_run_type_id			in  pay_run_types.run_type_id%type
                      ) ;
end pay_kr_yea_conc_pkg;

 

/
