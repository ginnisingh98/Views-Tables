--------------------------------------------------------
--  DDL for Package PAY_CAL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CAL_RKI" AUTHID CURRENT_USER as
/* $Header: pycalrhi.pkh 120.1 2005/11/11 07:05:54 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_cost_allocation_id           in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_cost_allocation_keyflex_id   in number
  ,p_assignment_id                in number
  ,p_proportion                   in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  );
end pay_cal_rki;

 

/
