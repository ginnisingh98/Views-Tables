--------------------------------------------------------
--  DDL for Package PER_APT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APT_RKD" AUTHID CURRENT_USER as
/* $Header: peaptrhi.pkh 120.2.12010000.4 2010/02/09 15:10:29 psugumar ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete	(
	p_appraisal_template_id         in number,
	p_business_group_id_o           in number,
	p_object_version_number_o       in number,
	p_name_o                        in varchar2,
	p_description_o                 in varchar2,
	p_instructions_o                in varchar2,
	p_date_from_o                   in date,
	p_date_to_o                     in date,
	p_assessment_type_id_o          in number,
	p_rating_scale_id_o             in number,
	p_questionnaire_template_id_o   in number,
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
	p_attribute20_o                 in varchar2
	,p_objective_asmnt_type_id_o    in number
  ,p_ma_quest_template_id_o       in number
  ,p_link_appr_to_learning_path_o in varchar2
  ,p_final_score_formula_id_o     in number
  ,p_update_personal_comp_profi_o in varchar2
  ,p_comp_profile_source_type_o   in varchar2
  ,p_show_competency_ratings_o    in varchar2
  ,p_show_objective_ratings_o     in varchar2
  ,p_show_overall_ratings_o       in varchar2
  ,p_show_overall_comments_o      in varchar2
  ,p_provide_overall_feedback_o   in varchar2
  ,p_show_participant_details_o   in varchar2
  ,p_allow_add_participant_o      in varchar2
  ,p_show_additional_details_o    in varchar2
  ,p_show_participant_names_o     in varchar2
  ,p_show_participant_ratings_o   in varchar2
  ,p_available_flag_o             in varchar2
  ,p_show_questionnaire_info_o    in varchar2
  ,p_show_participant_comments_o     in varchar2   -- 8651478 bug fix

  ,p_show_term_employee_o            in varchar2   -- 6181267 bug fix
  ,p_show_term_contigent_o           in varchar2    -- 6181267 bug fix
  ,p_disp_term_emp_period_from_o     in     number    -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE_o          in varchar2    -- 6181267 bug fix

  );

end per_apt_rkd;

/
