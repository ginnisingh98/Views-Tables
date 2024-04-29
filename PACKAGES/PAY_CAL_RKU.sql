--------------------------------------------------------
--  DDL for Package PAY_CAL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CAL_RKU" AUTHID CURRENT_USER as
/* $Header: pycalrhi.pkh 120.1 2005/11/11 07:05:54 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
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
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_cost_allocation_keyflex_id_o in number
  ,p_assignment_id_o              in number
  ,p_proportion_o                 in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  );
--
end pay_cal_rku;

 

/
