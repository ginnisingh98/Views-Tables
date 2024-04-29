--------------------------------------------------------
--  DDL for Package PER_APR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APR_RKI" AUTHID CURRENT_USER as
/* $Header: peaprrhi.pkh 120.2.12010000.3 2009/08/12 14:18:24 rvagvala ship $ */

-- ---------------------------------------------------------------------------+
-- |----------------------------< after_insert >------------------------------|
-- ---------------------------------------------------------------------------+

procedure after_insert	(
	p_appraisal_id                  in number,
	p_business_group_id             in number,
	p_appraisal_template_id         in number,
	p_appraisee_person_id           in number,
	p_appraiser_person_id           in number,
	p_appraisal_date                in date,
	p_appraisal_period_end_date     in date,
	p_appraisal_period_start_date   in date,
	p_type                          in varchar2,
	p_next_appraisal_date           in date,
	p_status                        in varchar2,
	p_group_date                    in date,
	p_group_initiator_id            in number,
	p_comments                      in varchar2,
	p_overall_performance_level_id  in number,
        p_open                          in varchar2,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
	p_object_version_number         in number,
	p_system_type                   in varchar2,
	p_system_params                 in varchar2,
	p_appraisee_access              in varchar2,
	p_main_appraiser_id             in number,
	p_assignment_id                 in number,
	p_assignment_start_date         in date,
	p_asg_business_group_id         in number,
	p_assignment_organization_id    in number,
	p_assignment_job_id             in number,
	p_assignment_position_id        in number,
	p_assignment_grade_id           in number,
	p_appraisal_system_status       in varchar2,
	p_potential_readiness_level     in varchar2,
	p_potential_short_term_workopp  in varchar2,
	p_potential_long_term_workopp   in varchar2,
	p_potential_details             in varchar2,
        p_event_id                      in number,
        p_show_competency_ratings       in varchar2,
        p_show_objective_ratings        in varchar2,
        p_show_questionnaire_info       in varchar2,
        p_show_participant_details      in varchar2,
        p_show_participant_ratings      in varchar2,
        p_show_participant_names        in varchar2,
        p_show_overall_ratings          in varchar2,
        p_show_overall_comments         in varchar2,
        p_update_appraisal              in varchar2,
        p_provide_overall_feedback      in varchar2,
        p_appraisee_comments            in varchar2,
	p_plan_id                       in number,
  p_offline_status                in varchar2,
p_retention_potential     in        varchar2,
p_show_participant_comments     in varchar2   -- 8651478 bug fix
    );

end per_apr_rki;

/
