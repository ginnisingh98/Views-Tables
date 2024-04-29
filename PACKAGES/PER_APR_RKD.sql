--------------------------------------------------------
--  DDL for Package PER_APR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APR_RKD" AUTHID CURRENT_USER as
/* $Header: peaprrhi.pkh 120.2.12010000.3 2009/08/12 14:18:24 rvagvala ship $ */

-- ---------------------------------------------------------------------------+
-- |----------------------------< after_delete >------------------------------|
-- ---------------------------------------------------------------------------+

procedure after_delete	(
	p_appraisal_id                  in number,
	p_business_group_id_o           in number,
	p_appraisal_template_id_o       in number,
	p_appraisee_person_id_o         in number,
	p_appraiser_person_id_o         in number,
	p_appraisal_date_o              in date,
	p_appraisal_period_end_date_o   in date,
	p_appraisal_period_start_dat_o  in date,
	p_type_o                        in varchar2,
	p_next_appraisal_date_o         in date,
	p_status_o                      in varchar2,
	p_group_date_o                  in date,
	p_group_initiator_id_o          in number,
	p_comments_o                    in varchar2,
	p_overall_performance_level_o   in number,
        p_open_o                        in varchar2,
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
	p_object_version_number_o       in number,
	p_system_type_o                 in varchar2,
	p_system_params_o               in varchar2,
	p_appraisee_access_o            in varchar2,
	p_main_appraiser_id_o           in number,
	p_assignment_id_o               in number,
	p_assignment_start_date_o       in date,
	p_asg_business_group_id_o       in number,
	p_assignment_organization_id_o  in number,
	p_assignment_job_id_o           in number,
	p_assignment_position_id_o      in number,
	p_assignment_grade_id_o         in number,
	p_appraisal_system_status_o     in varchar2,
	p_potential_readiness_level_o   in varchar2,
	p_potnl_short_term_workopp_o in varchar2,
	p_potnl_long_term_workopp_o  in varchar2,
	p_potential_details_o            in varchar2,
        p_event_id_o                     in number,
        p_show_competency_ratings_o      in varchar2,
        p_show_objective_ratings_o       in varchar2,
        p_show_questionnaire_info_o      in varchar2,
        p_show_participant_details_o     in varchar2,
        p_show_participant_ratings_o     in varchar2,
        p_show_participant_names_o       in varchar2,
        p_show_overall_ratings_o         in varchar2,
        p_show_overall_comments_o        in varchar2,
        p_update_appraisal_o             in varchar2,
        p_provide_overall_feedback_o     in varchar2,
        p_appraisee_comments_o           in varchar2,
	p_plan_id_o                      in number,
  p_offline_status_o               in varchar2,
 p_retention_potential_o     in        varchar2,
p_show_participant_comments_o     in varchar2   -- 8651478 bug fix
    );

end per_apr_rkd;

/
