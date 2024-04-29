--------------------------------------------------------
--  DDL for Package PSP_ERD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERD_RKD" AUTHID CURRENT_USER as
/* $Header: PSPEDRHS.pls 120.3 2006/01/25 01:49 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effort_report_detail_id      in number
  ,p_effort_report_id_o           in number
  ,p_object_version_number_o      in number
  ,p_assignment_id_o              in number
  ,p_assignment_number_o          in varchar2
  ,p_gl_sum_criteria_segment_na_o in varchar2
  ,p_gl_segment1_o                in varchar2
  ,p_gl_segment2_o                in varchar2
  ,p_gl_segment3_o                in varchar2
  ,p_gl_segment4_o                in varchar2
  ,p_gl_segment5_o                in varchar2
  ,p_gl_segment6_o                in varchar2
  ,p_gl_segment7_o                in varchar2
  ,p_gl_segment8_o                in varchar2
  ,p_gl_segment9_o                in varchar2
  ,p_gl_segment10_o               in varchar2
  ,p_gl_segment11_o               in varchar2
  ,p_gl_segment12_o               in varchar2
  ,p_gl_segment13_o               in varchar2
  ,p_gl_segment14_o               in varchar2
  ,p_gl_segment15_o               in varchar2
  ,p_gl_segment16_o               in varchar2
  ,p_gl_segment17_o               in varchar2
  ,p_gl_segment18_o               in varchar2
  ,p_gl_segment19_o               in varchar2
  ,p_gl_segment20_o               in varchar2
  ,p_gl_segment21_o               in varchar2
  ,p_gl_segment22_o               in varchar2
  ,p_gl_segment23_o               in varchar2
  ,p_gl_segment24_o               in varchar2
  ,p_gl_segment25_o               in varchar2
  ,p_gl_segment26_o               in varchar2
  ,p_gl_segment27_o               in varchar2
  ,p_gl_segment28_o               in varchar2
  ,p_gl_segment29_o               in varchar2
  ,p_gl_segment30_o               in varchar2
  ,p_project_id_o                 in number
  ,p_project_number_o             in varchar2
  ,p_project_name_o               in varchar2
  ,p_expenditure_organization_i_o in number
  ,p_exp_org_name_o               in varchar2
  ,p_expenditure_type_o           in varchar2
  ,p_task_id_o                    in number
  ,p_task_number_o                in varchar2
  ,p_task_name_o                  in varchar2
  ,p_award_id_o                   in number
  ,p_award_number_o               in varchar2
  ,p_award_short_name_o           in varchar2
  ,p_actual_salary_amt_o          in number
  ,p_payroll_percent_o            in number
  ,p_proposed_salary_amt_o        in number
  ,p_proposed_effort_percent_o    in number
  ,p_committed_cost_share_o       in number
  ,p_schedule_start_date_o        in date
  ,p_schedule_end_date_o          in date
  ,p_ame_transaction_id_o         in varchar2
  ,p_investigator_name_o          in varchar2
  ,p_investigator_person_id_o     in number
  ,p_investigator_org_name_o      in varchar2
  ,p_investigator_primary_org_i_o in number
  ,p_value1_o                     in number
  ,p_value2_o                     in number
  ,p_value3_o                     in number
  ,p_value4_o                     in number
  ,p_value5_o                     in number
  ,p_value6_o                     in number
  ,p_value7_o                     in number
  ,p_value8_o                     in number
  ,p_value9_o                     in number
  ,p_value10_o                    in number
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
  ,p_grouping_category_o          in varchar2
  );
--
end psp_erd_rkd;

 

/
