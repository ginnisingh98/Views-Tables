--------------------------------------------------------
--  DDL for Package PSP_ERD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERD_INS" AUTHID CURRENT_USER as
/* $Header: PSPEDRHS.pls 120.3 2006/01/25 01:49 dpaudel noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_effort_report_detail_id  in  number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                      in out nocopy psp_erd_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effort_report_id               in     number
  ,p_actual_salary_amt              in     number
  ,p_payroll_percent                in     number
  ,p_assignment_id                  in     number   default null
  ,p_assignment_number              in     varchar2 default null
  ,p_gl_sum_criteria_segment_name   in     varchar2 default null
  ,p_gl_segment1                    in     varchar2 default null
  ,p_gl_segment2                    in     varchar2 default null
  ,p_gl_segment3                    in     varchar2 default null
  ,p_gl_segment4                    in     varchar2 default null
  ,p_gl_segment5                    in     varchar2 default null
  ,p_gl_segment6                    in     varchar2 default null
  ,p_gl_segment7                    in     varchar2 default null
  ,p_gl_segment8                    in     varchar2 default null
  ,p_gl_segment9                    in     varchar2 default null
  ,p_gl_segment10                   in     varchar2 default null
  ,p_gl_segment11                   in     varchar2 default null
  ,p_gl_segment12                   in     varchar2 default null
  ,p_gl_segment13                   in     varchar2 default null
  ,p_gl_segment14                   in     varchar2 default null
  ,p_gl_segment15                   in     varchar2 default null
  ,p_gl_segment16                   in     varchar2 default null
  ,p_gl_segment17                   in     varchar2 default null
  ,p_gl_segment18                   in     varchar2 default null
  ,p_gl_segment19                   in     varchar2 default null
  ,p_gl_segment20                   in     varchar2 default null
  ,p_gl_segment21                   in     varchar2 default null
  ,p_gl_segment22                   in     varchar2 default null
  ,p_gl_segment23                   in     varchar2 default null
  ,p_gl_segment24                   in     varchar2 default null
  ,p_gl_segment25                   in     varchar2 default null
  ,p_gl_segment26                   in     varchar2 default null
  ,p_gl_segment27                   in     varchar2 default null
  ,p_gl_segment28                   in     varchar2 default null
  ,p_gl_segment29                   in     varchar2 default null
  ,p_gl_segment30                   in     varchar2 default null
  ,p_project_id                     in     number   default null
  ,p_project_number                 in     varchar2 default null
  ,p_project_name                   in     varchar2 default null
  ,p_expenditure_organization_id    in     number   default null
  ,p_exp_org_name                   in     varchar2 default null
  ,p_expenditure_type               in     varchar2 default null
  ,p_task_id                        in     number   default null
  ,p_task_number                    in     varchar2 default null
  ,p_task_name                      in     varchar2 default null
  ,p_award_id                       in     number   default null
  ,p_award_number                   in     varchar2 default null
  ,p_award_short_name               in     varchar2 default null
  ,p_proposed_salary_amt            in     number   default null
  ,p_proposed_effort_percent        in     number   default null
  ,p_committed_cost_share           in     number   default null
  ,p_schedule_start_date            in     date     default null
  ,p_schedule_end_date              in     date     default null
  ,p_ame_transaction_id             in     varchar2 default null
  ,p_investigator_name              in     varchar2 default null
  ,p_investigator_person_id         in     number   default null
  ,p_investigator_org_name          in     varchar2 default null
  ,p_investigator_primary_org_id    in     number   default null
  ,p_value1                         in     number   default null
  ,p_value2                         in     number   default null
  ,p_value3                         in     number   default null
  ,p_value4                         in     number   default null
  ,p_value5                         in     number   default null
  ,p_value6                         in     number   default null
  ,p_value7                         in     number   default null
  ,p_value8                         in     number   default null
  ,p_value9                         in     number   default null
  ,p_value10                        in     number   default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_grouping_category              in     varchar2 default null
  ,p_effort_report_detail_id           out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end psp_erd_ins;

 

/
