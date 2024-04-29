--------------------------------------------------------
--  DDL for Package PQH_VLD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_VLD_RKI" AUTHID CURRENT_USER as
/* $Header: pqvldrhi.pkh 120.0 2005/05/29 02:54:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_id                in number
  ,p_pension_fund_type_code       in varchar2
  ,p_pension_fund_id              in number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_request_date                 in date
  ,p_completion_date              in date
  ,p_previous_employer_id         in number
  ,p_previously_validated_flag    in varchar2
  ,p_status                       in varchar2
  ,p_employer_amount              in number
  ,p_employer_currency_code       in varchar2
  ,p_employee_amount              in number
  ,p_employee_currency_code       in varchar2
  ,p_deduction_per_period         in number
  ,p_deduction_currency_code      in varchar2
  ,p_percent_of_salary            in number
  ,p_object_version_number        in number
  );
end pqh_vld_rki;

 

/
