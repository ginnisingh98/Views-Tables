--------------------------------------------------------
--  DDL for Package PSP_ERD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERD_RKI" AUTHID CURRENT_USER as
/* $Header: PSPEDRHS.pls 120.3 2006/01/25 01:49 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effort_report_detail_id      in number
  ,p_effort_report_id             in number
  ,p_object_version_number        in number
  ,p_assignment_id                in number
  ,p_assignment_number            in varchar2
  ,p_gl_sum_criteria_segment_name in varchar2
  ,p_gl_segment1                  in varchar2
  ,p_gl_segment2                  in varchar2
  ,p_gl_segment3                  in varchar2
  ,p_gl_segment4                  in varchar2
  ,p_gl_segment5                  in varchar2
  ,p_gl_segment6                  in varchar2
  ,p_gl_segment7                  in varchar2
  ,p_gl_segment8                  in varchar2
  ,p_gl_segment9                  in varchar2
  ,p_gl_segment10                 in varchar2
  ,p_gl_segment11                 in varchar2
  ,p_gl_segment12                 in varchar2
  ,p_gl_segment13                 in varchar2
  ,p_gl_segment14                 in varchar2
  ,p_gl_segment15                 in varchar2
  ,p_gl_segment16                 in varchar2
  ,p_gl_segment17                 in varchar2
  ,p_gl_segment18                 in varchar2
  ,p_gl_segment19                 in varchar2
  ,p_gl_segment20                 in varchar2
  ,p_gl_segment21                 in varchar2
  ,p_gl_segment22                 in varchar2
  ,p_gl_segment23                 in varchar2
  ,p_gl_segment24                 in varchar2
  ,p_gl_segment25                 in varchar2
  ,p_gl_segment26                 in varchar2
  ,p_gl_segment27                 in varchar2
  ,p_gl_segment28                 in varchar2
  ,p_gl_segment29                 in varchar2
  ,p_gl_segment30                 in varchar2
  ,p_project_id                   in number
  ,p_project_number               in varchar2
  ,p_project_name                 in varchar2
  ,p_expenditure_organization_id  in number
  ,p_exp_org_name                 in varchar2
  ,p_expenditure_type             in varchar2
  ,p_task_id                      in number
  ,p_task_number                  in varchar2
  ,p_task_name                    in varchar2
  ,p_award_id                     in number
  ,p_award_number                 in varchar2
  ,p_award_short_name             in varchar2
  ,p_actual_salary_amt            in number
  ,p_payroll_percent              in number
  ,p_proposed_salary_amt          in number
  ,p_proposed_effort_percent      in number
  ,p_committed_cost_share         in number
  ,p_schedule_start_date          in date
  ,p_schedule_end_date            in date
  ,p_ame_transaction_id           in varchar2
  ,p_investigator_name            in varchar2
  ,p_investigator_person_id       in number
  ,p_investigator_org_name        in varchar2
  ,p_investigator_primary_org_id  in number
  ,p_value1                       in number
  ,p_value2                       in number
  ,p_value3                       in number
  ,p_value4                       in number
  ,p_value5                       in number
  ,p_value6                       in number
  ,p_value7                       in number
  ,p_value8                       in number
  ,p_value9                       in number
  ,p_value10                      in number
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_grouping_category            in varchar2
  );
end psp_erd_rki;

 

/
