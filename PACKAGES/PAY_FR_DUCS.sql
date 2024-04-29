--------------------------------------------------------
--  DDL for Package PAY_FR_DUCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_DUCS" AUTHID CURRENT_USER as
/* $Header: pyfraduc.pkh 115.4 2002/11/27 14:39:51 aparkes ship $ */

--
FUNCTION  get_parameter (
          p_parameter_string          in varchar2
         ,p_token                     in varchar2
         ,p_segment_number            in number default null)  return varchar2;
--
PROCEDURE get_all_parameters (
			      	 p_payroll_action_id       in number
				,p_business_group_id       out nocopy number
				,p_company_id              out nocopy number
				,p_period_type             out nocopy varchar2
				,p_period_start_date       out nocopy date
				,p_effective_date          out nocopy date
				,p_english_base            out nocopy varchar2
				,p_english_rate            out nocopy varchar2
				,p_english_pay_value       out nocopy varchar2
				,p_english_contrib_code    out nocopy varchar2
				,p_french_base             out nocopy varchar2
				,p_french_rate             out nocopy varchar2
				,p_french_pay_value        out nocopy varchar2
				,p_french_contrib_code     out nocopy varchar2);

--
PROCEDURE get_lookup(
                     p_lookup_type    in varchar2
                    ,p_lookup_code    in varchar2
                    ,p_lookup_meaning out nocopy varchar2
                    ,p_lookup_tag     out nocopy varchar2);
--
PROCEDURE get_count_emps(p_payroll_action_id in  number
                        ,p_page_identifier   in  number
                        ,p_page_type         in  varchar2
                        ,p_contribution_emps out nocopy number
                        ,p_month_end_male    out nocopy number
                        ,p_month_end_female  out nocopy number
                        ,p_month_end_total   out nocopy number
                        ,p_total_actions     out nocopy number);

--
PROCEDURE process_payment(
                         p_name           in varchar2
                        ,p_total_payment  in number
                        ,p_payment1_type  in varchar2
                        ,p_payment1_limit in number
                        ,p_payment1_value out nocopy number
                        ,p_payment2_type  in varchar2
                        ,p_payment2_limit in number
                        ,p_payment2_value out nocopy number
                        ,p_payment3_type  in varchar2
                        ,p_payment3_limit in number
                        ,p_payment3_value out nocopy number);
--
PROCEDURE process_contributions(
	                	 p_payroll_action_id   in number
                                ,p_page_identifier     in number
                                ,p_page_type           in varchar2
                                ,p_total_contributions out nocopy number);

--
PROCEDURE recalculate_payment(
          errbuf                      out nocopy varchar2
         ,retcode                     out nocopy varchar2
         ,p_company_id                in number
         ,p_period_end_date 	      in varchar2
         ,p_period_type 	      in varchar2
         ,p_override_information_id   in number default null);
--

PROCEDURE range_code(
   	  p_payroll_action_id         in number
         ,sqlstr                      out nocopy varchar2);
--
PROCEDURE assignment_action_code (
          p_payroll_action_id         in number
	 ,p_start_person_id           in number
	 ,p_end_person_id             in number
         ,p_chunk                     in number);
--
PROCEDURE archinit(p_payroll_action_id IN NUMBER);
--
PROCEDURE archive_code (
   	  p_assignment_action_id      in number
   	 ,p_effective_date            in date);
--
PROCEDURE retrieve_contributions(
	  p_assignment_action_id      in number
         ,p_effective_date            in date
         ,p_tax_unit_id               in number default null);
--
PROCEDURE deinitialize_code(
	  p_payroll_action_id         in number);
--



end PAY_FR_DUCS;

 

/
