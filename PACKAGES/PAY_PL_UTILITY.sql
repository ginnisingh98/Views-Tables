--------------------------------------------------------
--  DDL for Package PAY_PL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_UTILITY" AUTHID CURRENT_USER AS
/* $Header: pyplutil.pkh 120.0 2005/10/14 04:04:24 mseshadr noship $ */
FUNCTION pay_pl_nip_format(p_nip IN NUMBER
              ) RETURN VARCHAR2;
--


function pl_get_sii_details(
                          p_assignment_id             number,
                          p_date_earned               date  ,
                          p_payroll_id                number,
                          p_active_term_flag          out nocopy varchar2,
                          p_sii_code                  out nocopy varchar2,
                          p_old_age_contrib           out nocopy varchar2,
                          p_pension_contrib           out nocopy varchar2,
                          p_sickness_contrib          out nocopy varchar2,
                          p_work_injury_contrib       out nocopy varchar2,
                          p_labor_contrib             out nocopy varchar2,
                          p_unemployment_contrib      out nocopy varchar2,
                          p_health_contrib            out nocopy varchar2,
                          p_term_sii_code             out nocopy varchar2,
                          p_term_old_age_contrib      out nocopy varchar2,
                          p_term_pension_contrib      out nocopy varchar2,
                          p_term_sickness_contrib     out nocopy varchar2,
                          p_term_work_injury_contrib  out nocopy varchar2,
                          p_term_labor_contrib        out nocopy varchar2,
                          p_term_unemployment_contrib out nocopy varchar2,
                          p_term_health_contrib       out nocopy varchar2
                                                    ) return number;

FUNCTION GET_RATE_OF_TAX(p_date_earned    IN DATE,
				 p_taxable_base IN NUMBER,
				 p_rate_of_tax 	  IN VARCHAR2,
				 p_spouse_or_child_flag IN VARCHAR2,
 				 p_tax_percentage OUT NOCOPY NUMBER) RETURN NUMBER;

Function pl_get_tax_details(
                          p_assignment_id                                number,
                          p_date_earned                                  date  ,
                          p_payroll_id                                   number,
                          p_sii_code                          out nocopy varchar2,
                          p_spouse_or_child_flag              out nocopy varchar2,
                          p_income_reduction                  out nocopy varchar2,
                          p_tax_reduction                     out nocopy varchar2,
                          p_income_reduction_amount           out nocopy NUMBER,
                          p_rate_of_tax                       out nocopy varchar2,
                          p_contract_category                 out nocopy varchar2,
                          p_contract_type                     out nocopy varchar2,
                          p_ir_flag                           out nocopy varchar2
                           ) return number;

END pay_pl_utility;

 

/
