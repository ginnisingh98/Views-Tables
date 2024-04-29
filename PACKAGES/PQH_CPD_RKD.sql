--------------------------------------------------------
--  DDL for Package PQH_CPD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CPD_RKD" AUTHID CURRENT_USER as
/* $Header: pqcpdrhi.pkh 120.0 2005/05/29 01:44:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_corps_definition_id          in number
  ,p_business_group_id_o          in number
  ,p_name_o                       in varchar2
  ,p_status_cd_o                  in varchar2
  ,p_retirement_age_o             in number
  ,p_category_cd_o                in varchar2
  ,p_recruitment_end_date_o       in date
  ,p_corps_type_cd_o              in varchar2
  ,p_starting_grade_step_id_o     in number
  ,p_task_desc_o                  in varchar2
  ,p_secondment_threshold_o       in number
  ,p_normal_hours_o               in number
  ,p_normal_hours_frequency_o     in varchar2
  ,p_minimum_hours_o              in number
  ,p_minimum_hours_frequency_o    in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_object_version_number_o      in number
  ,p_type_of_ps_o                 in varchar2
  ,p_date_from_o                  in date
  ,p_date_to_o                    in date
  ,p_primary_prof_field_id_o      in number
  ,p_starting_grade_id_o          in number
  ,p_ben_pgm_id_o                 in number
  ,p_probation_period_o           in number
  ,p_probation_units_o            in varchar2
  );
--
end pqh_cpd_rkd;

 

/
