--------------------------------------------------------
--  DDL for Package PQH_VLD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_VLD_RKD" AUTHID CURRENT_USER as
/* $Header: pqvldrhi.pkh 120.0 2005/05/29 02:54:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_validation_id                in number
  ,p_pension_fund_type_code_o     in varchar2
  ,p_pension_fund_id_o            in number
  ,p_business_group_id_o          in number
  ,p_person_id_o                  in number
  ,p_request_date_o               in date
  ,p_completion_date_o            in date
  ,p_previous_employer_id_o       in number
  ,p_previously_validated_flag_o  in varchar2
  ,p_status_o                     in varchar2
  ,p_employer_amount_o            in number
  ,p_employer_currency_code_o     in varchar2
  ,p_employee_amount_o            in number
  ,p_employee_currency_code_o     in varchar2
  ,p_deduction_per_period_o       in number
  ,p_deduction_currency_code_o    in varchar2
  ,p_percent_of_salary_o          in number
  ,p_object_version_number_o      in number
  );
--
end pqh_vld_rkd;

 

/
