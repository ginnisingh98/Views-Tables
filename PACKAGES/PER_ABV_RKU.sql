--------------------------------------------------------
--  DDL for Package PER_ABV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABV_RKU" AUTHID CURRENT_USER as
/* $Header: peabvrhi.pkh 120.0 2005/05/31 04:50:16 appldev noship $ */
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
  ,p_assignment_budget_value_id   in number
  ,p_unit                         in varchar2
  ,p_value                        in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_object_version_number        in number
  ,p_business_group_id_o          in number
  ,p_assignment_id_o              in number
  ,p_unit_o                       in varchar2
  ,p_value_o                      in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_object_version_number_o      in number
  );
--
end per_abv_rku;

 

/
