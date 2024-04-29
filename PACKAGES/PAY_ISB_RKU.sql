--------------------------------------------------------
--  DDL for Package PAY_ISB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ISB_RKU" AUTHID CURRENT_USER as
/* $Header: pyisbrhi.pkh 120.0 2005/05/29 06:02:09 appldev noship $ */
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
  ,p_social_benefit_id            in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_object_version_number        in number
  ,p_assignment_id                in number
  ,p_absence_start_date           in date
  ,p_absence_end_date             in date
  ,p_benefit_amount               in number
  ,p_benefit_type                 in varchar2
  ,p_calculation_option           in varchar2
  ,p_reduced_tax_credit           in number
  ,p_reduced_standard_cutoff      in number
  ,p_incident_id                  in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in varchar2
  ,p_program_update_date          in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_object_version_number_o      in number
  ,p_assignment_id_o              in number
  ,p_absence_start_date_o         in date
  ,p_absence_end_date_o           in date
  ,p_benefit_amount_o             in number
  ,p_benefit_type_o               in varchar2
  ,p_calculation_option_o         in varchar2
  ,p_reduced_tax_credit_o         in number
  ,p_reduced_standard_cutoff_o    in number
  ,p_incident_id_o                in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in varchar2
  ,p_program_update_date_o        in date
  );
--
end pay_isb_rku;

 

/
