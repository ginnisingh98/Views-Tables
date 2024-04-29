--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATIONS_BK2" AUTHID CURRENT_USER as
/* $Header: pqvldapi.pkh 120.1 2005/10/02 02:28:42 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_Validation_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Validation_b
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_object_version_number        in     number
  ,p_pension_fund_type_code       in     varchar2
  ,p_pension_fund_id              in     number
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_previously_validated_flag    in     varchar2
  ,p_request_date                 in     date
  ,p_completion_date              in     date
  ,p_previous_employer_id         in     number
  ,p_status                       in     varchar2
  ,p_employer_amount              in     number
  ,p_employer_currency_code       in     varchar2
  ,p_employee_amount              in     number
  ,p_employee_currency_code       in     varchar2
  ,p_deduction_per_period         in     number
  ,p_deduction_currency_code      in     varchar2
  ,p_percent_of_salary            in     number);

--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Update_Validation_a> >---------------------|
-- ----------------------------------------------------------------------------

procedure Update_Validation_a
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_object_version_number        in     number
  ,p_pension_fund_type_code       in     varchar2
  ,p_pension_fund_id              in     number
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_previously_validated_flag    in     varchar2
  ,p_request_date                 in     date
  ,p_completion_date              in     date
  ,p_previous_employer_id         in     number
  ,p_status                       in     varchar2
  ,p_employer_amount              in     number
  ,p_employer_currency_code       in     varchar2
  ,p_employee_amount              in     number
  ,p_employee_currency_code       in     varchar2
  ,p_deduction_per_period         in     number
  ,p_deduction_currency_code      in     varchar2
  ,p_percent_of_salary            in     number
  );

end pqh_fr_validations_bk2;

 

/
