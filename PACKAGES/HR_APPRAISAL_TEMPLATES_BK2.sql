--------------------------------------------------------
--  DDL for Package HR_APPRAISAL_TEMPLATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISAL_TEMPLATES_BK2" AUTHID CURRENT_USER as
/* $Header: peaptapi.pkh 120.4.12010000.6 2010/02/09 15:05:01 psugumar ship $ */
--
-- --------------------------------------------------------------------------
-- |-----------------------< update_appraisal_template_b >------------------|
-- --------------------------------------------------------------------------

Procedure update_appraisal_template_b	(
  p_appraisal_template_id        in number    ,
  p_object_version_number        in number    ,
  p_effective_date               in date      ,
  p_name                         in varchar2  ,
  p_description                  in varchar2  ,
  p_instructions                 in varchar2  ,
  p_date_from                    in date      ,
  p_date_to                      in date      ,
  p_assessment_type_id           in number    ,
  p_rating_scale_id              in number    ,
  p_questionnaire_template_id    in number    ,
  p_attribute_category           in varchar2  ,
  p_attribute1                   in varchar2  ,
  p_attribute2                   in varchar2  ,
  p_attribute3                   in varchar2  ,
  p_attribute4                   in varchar2  ,
  p_attribute5                   in varchar2  ,
  p_attribute6                   in varchar2  ,
  p_attribute7                   in varchar2  ,
  p_attribute8                   in varchar2  ,
  p_attribute9                   in varchar2  ,
  p_attribute10                  in varchar2  ,
  p_attribute11                  in varchar2  ,
  p_attribute12                  in varchar2  ,
  p_attribute13                  in varchar2  ,
  p_attribute14                  in varchar2  ,
  p_attribute15                  in varchar2  ,
  p_attribute16                  in varchar2  ,
  p_attribute17                  in varchar2  ,
  p_attribute18                  in varchar2  ,
  p_attribute19                  in varchar2  ,
  p_attribute20                  in varchar2
  ,p_objective_asmnt_type_id      in number
  ,p_ma_quest_template_id         in number
  ,p_link_appr_to_learning_path   in varchar2
  ,p_final_score_formula_id       in number
  ,p_update_personal_comp_profile in varchar2
  ,p_comp_profile_source_type     in varchar2
  ,p_show_competency_ratings      in varchar2
  ,p_show_objective_ratings       in varchar2
  ,p_show_overall_ratings         in varchar2
  ,p_show_overall_comments        in varchar2
  ,p_provide_overall_feedback     in varchar2
  ,p_show_participant_details     in varchar2
  ,p_allow_add_participant        in varchar2
  ,p_show_additional_details      in varchar2
  ,p_show_participant_names       in varchar2
  ,p_show_participant_ratings     in varchar2
  ,p_available_flag               in varchar2
  ,p_show_questionnaire_info     in varchar2
  ,p_ma_off_template_code 		    in varchar2
  ,p_appraisee_off_template_code  in varchar2
  ,p_other_part_off_template_code in varchar2
  ,p_part_app_off_template_code	  in varchar2
  ,p_part_rev_off_template_code	  in varchar2
  ,p_show_participant_comments     in varchar2   -- 8651478 bug fix
  ,p_show_term_employee            in varchar2  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2 -- 6181267 bug fix

  );
-- --------------------------------------------------------------------------
-- |-----------------------< update_appraisal_template_a >------------------|
-- --------------------------------------------------------------------------

Procedure update_appraisal_template_a
	(
  p_appraisal_template_id        in number    ,
  p_object_version_number        in number    ,
  p_effective_date               in date      ,
  p_name                         in varchar2  ,
  p_description                  in varchar2  ,
  p_instructions                 in varchar2  ,
  p_date_from                    in date      ,
  p_date_to                      in date      ,
  p_assessment_type_id           in number    ,
  p_rating_scale_id              in number    ,
  p_questionnaire_template_id    in number    ,
  p_attribute_category           in varchar2  ,
  p_attribute1                   in varchar2  ,
  p_attribute2                   in varchar2  ,
  p_attribute3                   in varchar2  ,
  p_attribute4                   in varchar2  ,
  p_attribute5                   in varchar2  ,
  p_attribute6                   in varchar2  ,
  p_attribute7                   in varchar2  ,
  p_attribute8                   in varchar2  ,
  p_attribute9                   in varchar2  ,
  p_attribute10                  in varchar2  ,
  p_attribute11                  in varchar2  ,
  p_attribute12                  in varchar2  ,
  p_attribute13                  in varchar2  ,
  p_attribute14                  in varchar2  ,
  p_attribute15                  in varchar2  ,
  p_attribute16                  in varchar2  ,
  p_attribute17                  in varchar2  ,
  p_attribute18                  in varchar2  ,
  p_attribute19                  in varchar2  ,
  p_attribute20                  in varchar2
  ,p_objective_asmnt_type_id      in number
  ,p_ma_quest_template_id         in number
  ,p_link_appr_to_learning_path   in varchar2
  ,p_final_score_formula_id       in number
  ,p_update_personal_comp_profile in varchar2
  ,p_comp_profile_source_type     in varchar2
  ,p_show_competency_ratings      in varchar2
  ,p_show_objective_ratings       in varchar2
  ,p_show_overall_ratings         in varchar2
  ,p_show_overall_comments        in varchar2
  ,p_provide_overall_feedback     in varchar2
  ,p_show_participant_details     in varchar2
  ,p_allow_add_participant        in varchar2
  ,p_show_additional_details      in varchar2
  ,p_show_participant_names       in varchar2
  ,p_show_participant_ratings     in varchar2
  ,p_available_flag               in varchar2
  ,p_show_questionnaire_info      in     varchar2
  ,p_ma_off_template_code 		    in varchar2
  ,p_appraisee_off_template_code  in varchar2
  ,p_other_part_off_template_code in varchar2
  ,p_part_app_off_template_code	  in varchar2
  ,p_part_rev_off_template_code	  in varchar2
  ,p_show_participant_comments     in varchar2   -- 8651478 bug fix
  ,p_show_term_employee            in varchar2   -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2   -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number    -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2   -- 6181267 bug fix

  );

end hr_appraisal_templates_bk2;

/
