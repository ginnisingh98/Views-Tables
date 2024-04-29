--------------------------------------------------------
--  DDL for Package PER_OBJ_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OBJ_RKD" AUTHID CURRENT_USER as
/* $Header: peobjrhi.pkh 120.4.12010000.1 2008/07/28 05:04:18 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_delete >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
   p_objective_id                  in number,
   p_name_o                        in varchar2,
   p_target_date_o                 in date,
   p_start_date_o                  in date,
   p_business_group_id_o           in number,
   p_object_version_number_o       in number,
   p_owning_person_id_o            in number,
   p_achievement_date_o            in date,
   p_detail_o                      in varchar2,
   p_comments_o                    in varchar2,
   p_success_criteria_o            in varchar2,
   p_appraisal_id_o                in number,
   p_attribute_category_o          in varchar2,
   p_attribute1_o                  in varchar2,
   p_attribute2_o                  in varchar2,
   p_attribute3_o                  in varchar2,
   p_attribute4_o                  in varchar2,
   p_attribute5_o                  in varchar2,
   p_attribute6_o                  in varchar2,
   p_attribute7_o                  in varchar2,
   p_attribute8_o                  in varchar2,
   p_attribute9_o                  in varchar2,
   p_attribute10_o                 in varchar2,
   p_attribute11_o                 in varchar2,
   p_attribute12_o                 in varchar2,
   p_attribute13_o                 in varchar2,
   p_attribute14_o                 in varchar2,
   p_attribute15_o                 in varchar2,
   p_attribute16_o                 in varchar2,
   p_attribute17_o                 in varchar2,
   p_attribute18_o                 in varchar2,
   p_attribute19_o                 in varchar2,
   p_attribute20_o                 in varchar2,
   p_attribute21_o                 in varchar2,
   p_attribute22_o                 in varchar2,
   p_attribute23_o                 in varchar2,
   p_attribute24_o                 in varchar2,
   p_attribute25_o                 in varchar2,
   p_attribute26_o                 in varchar2,
   p_attribute27_o                 in varchar2,
   p_attribute28_o                 in varchar2,
   p_attribute29_o                 in varchar2,
   p_attribute30_o                 in varchar2,

   p_scorecard_id_o                in number,
   p_copied_from_library_id_o      in number,
   p_copied_from_objective_id_o    in number,
   p_aligned_with_objective_id_o   in number,

   p_next_review_date_o            in date,
   p_group_code_o                  in varchar2,
   p_priority_code_o               in varchar2,
   p_appraise_flag_o               in varchar2,
   p_verified_flag_o               in varchar2,

   p_target_value_o                in number,
   p_actual_value_o                in number,
   p_weighting_percent_o           in number,
   p_complete_percent_o            in number,
   p_uom_code_o                    in varchar2,

   p_measurement_style_code_o      in varchar2,
   p_measure_name_o                in varchar2,
   p_measure_type_code_o           in varchar2,
   p_measure_comments_o            in varchar2,
   p_sharing_access_code_o         in varchar2
  );
end per_obj_rkd;

/
