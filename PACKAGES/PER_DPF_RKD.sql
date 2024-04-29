--------------------------------------------------------
--  DDL for Package PER_DPF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DPF_RKD" AUTHID CURRENT_USER as
/* $Header: pedpfrhi.pkh 120.0 2005/05/31 07:45:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_deployment_factor_id           in number,
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
end per_dpf_rkd;


 

/
