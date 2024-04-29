--------------------------------------------------------
--  DDL for Package PQH_PTX_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_RKD" AUTHID CURRENT_USER as
/* $Header: pqptxrhi.pkh 120.0.12010000.2 2008/08/06 07:42:54 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_position_transaction_id        in number
 ,p_action_date_o                  in date
 ,p_position_id_o                  in number
 ,p_availability_status_id_o       in number
 ,p_business_group_id_o            in number
 ,p_entry_step_id_o                in number
 ,p_entry_grade_rule_id_o                in number
 ,p_job_id_o                       in number
 ,p_location_id_o                  in number
 ,p_organization_id_o              in number
 ,p_pay_freq_payroll_id_o          in number
 ,p_position_definition_id_o       in number
 ,p_prior_position_id_o            in number
 ,p_relief_position_id_o           in number
 ,p_entry_grade_id_o        in number
 ,p_successor_position_id_o        in number
 ,p_supervisor_position_id_o       in number
 ,p_amendment_date_o               in date
 ,p_amendment_recommendation_o     in varchar2
 ,p_amendment_ref_number_o         in varchar2
 ,p_avail_status_prop_end_date_o   in date
 ,p_bargaining_unit_cd_o           in varchar2
 ,p_comments_o                     in long
 ,p_country1_o                     in varchar2
 ,p_country2_o                     in varchar2
 ,p_country3_o                     in varchar2
 ,p_current_job_prop_end_date_o    in date
 ,p_current_org_prop_end_date_o    in date
 ,p_date_effective_o               in date
 ,p_date_end_o                     in date
 ,p_earliest_hire_date_o           in date
 ,p_fill_by_date_o                 in date
 ,p_frequency_o                    in varchar2
 ,p_fte_o                          in number
 ,p_fte_capacity_o                 in varchar2
 ,p_location1_o                    in varchar2
 ,p_location2_o                    in varchar2
 ,p_location3_o                    in varchar2
 ,p_max_persons_o                  in number
 ,p_name_o                         in varchar2
 ,p_other_requirements_o           in varchar2
 ,p_overlap_period_o               in number
 ,p_overlap_unit_cd_o              in varchar2
 ,p_passport_required_o            in varchar2
 ,p_pay_term_end_day_cd_o          in varchar2
 ,p_pay_term_end_month_cd_o        in varchar2
 ,p_permanent_temporary_flag_o     in varchar2
 ,p_permit_recruitment_flag_o      in varchar2
 ,p_position_type_o                in varchar2
 ,p_posting_description_o          in varchar2
 ,p_probation_period_o             in number
 ,p_probation_period_unit_cd_o     in varchar2
 ,p_relocate_domestically_o        in varchar2
 ,p_relocate_internationally_o     in varchar2
 ,p_replacement_required_flag_o    in varchar2
 ,p_review_flag_o                  in varchar2
 ,p_seasonal_flag_o                in varchar2
 ,p_security_requirements_o        in varchar2
 ,p_service_minimum_o              in varchar2
 ,p_term_start_day_cd_o            in varchar2
 ,p_term_start_month_cd_o          in varchar2
 ,p_time_normal_finish_o           in varchar2
 ,p_time_normal_start_o            in varchar2
 ,p_transaction_status_o           in varchar2
 ,p_travel_required_o              in varchar2
 ,p_working_hours_o                in number
 ,p_works_council_approval_fla_o  in varchar2
 ,p_work_any_country_o             in varchar2
 ,p_work_any_location_o            in varchar2
 ,p_work_period_type_cd_o          in varchar2
 ,p_work_schedule_o                in varchar2
 ,p_work_duration_o                in varchar2
 ,p_work_term_end_day_cd_o         in varchar2
 ,p_work_term_end_month_cd_o       in varchar2
 ,p_proposed_fte_for_layoff_o      in  number
 ,p_proposed_date_for_layoff_o     in  date
 ,p_information1_o                 in varchar2
 ,p_information2_o                 in varchar2
 ,p_information3_o                 in varchar2
 ,p_information4_o                 in varchar2
 ,p_information5_o                 in varchar2
 ,p_information6_o                 in varchar2
 ,p_information7_o                 in varchar2
 ,p_information8_o                 in varchar2
 ,p_information9_o                 in varchar2
 ,p_information10_o                in varchar2
 ,p_information11_o                in varchar2
 ,p_information12_o                in varchar2
 ,p_information13_o                in varchar2
 ,p_information14_o                in varchar2
 ,p_information15_o                in varchar2
 ,p_information16_o                in varchar2
 ,p_information17_o                in varchar2
 ,p_information18_o                in varchar2
 ,p_information19_o                in varchar2
 ,p_information20_o                in varchar2
 ,p_information21_o                in varchar2
 ,p_information22_o                in varchar2
 ,p_information23_o                in varchar2
 ,p_information24_o                in varchar2
 ,p_information25_o                in varchar2
 ,p_information26_o                in varchar2
 ,p_information27_o                in varchar2
 ,p_information28_o                in varchar2
 ,p_information29_o                in varchar2
 ,p_information30_o                in varchar2
 ,p_information_category_o         in varchar2
 ,p_attribute1_o                   in varchar2
 ,p_attribute2_o                   in varchar2
 ,p_attribute3_o                   in varchar2
 ,p_attribute4_o                   in varchar2
 ,p_attribute5_o                   in varchar2
 ,p_attribute6_o                   in varchar2
 ,p_attribute7_o                   in varchar2
 ,p_attribute8_o                   in varchar2
 ,p_attribute9_o                   in varchar2
 ,p_attribute10_o                  in varchar2
 ,p_attribute11_o                  in varchar2
 ,p_attribute12_o                  in varchar2
 ,p_attribute13_o                  in varchar2
 ,p_attribute14_o                  in varchar2
 ,p_attribute15_o                  in varchar2
 ,p_attribute16_o                  in varchar2
 ,p_attribute17_o                  in varchar2
 ,p_attribute18_o                  in varchar2
 ,p_attribute19_o                  in varchar2
 ,p_attribute20_o                  in varchar2
 ,p_attribute21_o                  in varchar2
 ,p_attribute22_o                  in varchar2
 ,p_attribute23_o                  in varchar2
 ,p_attribute24_o                  in varchar2
 ,p_attribute25_o                  in varchar2
 ,p_attribute26_o                  in varchar2
 ,p_attribute27_o                  in varchar2
 ,p_attribute28_o                  in varchar2
 ,p_attribute29_o                  in varchar2
 ,p_attribute30_o                  in varchar2
 ,p_attribute_category_o           in varchar2
 ,p_object_version_number_o        in number
 ,p_pay_basis_id_o                 in number
 ,p_supervisor_id_o          	   in number
 ,p_wf_transaction_category_id_o   in number
  );
--
end pqh_ptx_rkd;

/
