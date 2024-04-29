--------------------------------------------------------
--  DDL for Package PER_DPF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DPF_RKU" AUTHID CURRENT_USER as
  /* $Header: pedpfrhi.pkh 120.0 2005/05/31 07:45:06 appldev noship $ */
  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------< after_update >------------------------------|
  -- ----------------------------------------------------------------------------
  --
procedure after_update
  (
  p_deployment_factor_id         in number,
--  p_position_id                  in number, these are columns that are not updateable.
--  p_person_id                    in number, these are columns that are not updateable.
--  p_job_id                       in number, these are columns that are not updateable.
  p_business_group_id            in number,
  p_work_any_country             in varchar2,
  p_work_any_location            in varchar2,
  p_relocate_domestically        in varchar2,
  p_relocate_internationally     in varchar2,
  p_travel_required              in varchar2,
  p_country1                     in varchar2,
  p_country2                     in varchar2,
  p_country3                     in varchar2,
  p_work_duration                in varchar2,
  p_work_schedule                in varchar2,
  p_work_hours                   in varchar2,
  p_fte_capacity                 in varchar2,
  p_visit_internationally        in varchar2,
  p_only_current_location        in varchar2,
  p_no_country1                  in varchar2,
  p_no_country2                  in varchar2,
  p_no_country3                  in varchar2,
  p_comments                     in varchar2,
  p_earliest_available_date      in date,
  p_available_for_transfer       in varchar2,
  p_relocation_preference        in varchar2,
  p_relocation_required          in varchar2,
  p_passport_required            in varchar2,
  p_location1                    in varchar2,
  p_location2                    in varchar2,
  p_location3                    in varchar2,
  p_other_requirements           in varchar2,
  p_service_minimum              in varchar2,
  p_object_version_number        in number,
  p_effective_date               in date,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_position_id_o                  in number,
  p_person_id_o                    in number,
  p_job_id_o                       in number,
  p_business_group_id_o            in number,
  p_work_any_country_o             in varchar2,
  p_work_any_location_o            in varchar2,
  p_relocate_domestically_o        in varchar2,
  p_relocate_internationally_o     in varchar2,
  p_travel_required_o              in varchar2,
  p_country1_o                     in varchar2,
  p_country2_o                     in varchar2,
  p_country3_o                     in varchar2,
  p_work_duration_o                in varchar2,
  p_work_schedule_o                in varchar2,
  p_work_hours_o                   in varchar2,
  p_fte_capacity_o                 in varchar2,
  p_visit_internationally_o        in varchar2,
  p_only_current_location_o        in varchar2,
  p_no_country1_o                  in varchar2,
  p_no_country2_o                  in varchar2,
  p_no_country3_o                  in varchar2,
  p_comments_o                     in varchar2,
  p_earliest_available_date_o      in date,
  p_available_for_transfer_o       in varchar2,
  p_relocation_preference_o        in varchar2,
  p_relocation_required_o          in varchar2,
  p_passport_required_o            in varchar2,
  p_location1_o                    in varchar2,
  p_location2_o                    in varchar2,
  p_location3_o                    in varchar2,
  p_other_requirements_o           in varchar2,
  p_service_minimum_o              in varchar2,
  p_object_version_number_o        in number,
  p_attribute_category_o           in varchar2,
  p_attribute1_o                   in varchar2,
  p_attribute2_o                   in varchar2,
  p_attribute3_o                   in varchar2,
  p_attribute4_o                   in varchar2,
  p_attribute5_o                   in varchar2,
  p_attribute6_o                   in varchar2,
  p_attribute7_o                   in varchar2,
  p_attribute8_o                   in varchar2,
  p_attribute9_o                   in varchar2,
  p_attribute10_o                  in varchar2,
  p_attribute11_o                  in varchar2,
  p_attribute12_o                  in varchar2,
  p_attribute13_o                  in varchar2,
  p_attribute14_o                  in varchar2,
  p_attribute15_o                  in varchar2,
  p_attribute16_o                  in varchar2,
  p_attribute17_o                  in varchar2,
  p_attribute18_o                  in varchar2,
  p_attribute19_o                  in varchar2,
  p_attribute20_o                  in varchar2
 );
end per_dpf_rku;

 

/