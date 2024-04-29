--------------------------------------------------------
--  DDL for Package PSP_ERD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERD_UPD" AUTHID CURRENT_USER as
/* $Header: PSPEDRHS.pls 120.3 2006/01/25 01:49 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
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
Procedure upd
  (p_rec                          in out nocopy psp_erd_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
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
Procedure upd
  (p_effort_report_detail_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_effort_report_id             in     number    default hr_api.g_number
  ,p_actual_salary_amt            in     number    default hr_api.g_number
  ,p_payroll_percent              in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_gl_sum_criteria_segment_name in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment1                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment2                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment3                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment4                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment5                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment6                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment7                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment8                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment9                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment10                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment11                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment12                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment13                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment14                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment15                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment16                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment17                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment18                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment19                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment20                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment21                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment22                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment23                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment24                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment25                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment26                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment27                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment28                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment29                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment30                 in     varchar2  default hr_api.g_varchar2
  ,p_project_id                   in     number    default hr_api.g_number
  ,p_project_number               in     varchar2  default hr_api.g_varchar2
  ,p_project_name                 in     varchar2  default hr_api.g_varchar2
  ,p_expenditure_organization_id  in     number    default hr_api.g_number
  ,p_exp_org_name                 in     varchar2  default hr_api.g_varchar2
  ,p_expenditure_type             in     varchar2  default hr_api.g_varchar2
  ,p_task_id                      in     number    default hr_api.g_number
  ,p_task_number                  in     varchar2  default hr_api.g_varchar2
  ,p_task_name                    in     varchar2  default hr_api.g_varchar2
  ,p_award_id                     in     number    default hr_api.g_number
  ,p_award_number                 in     varchar2  default hr_api.g_varchar2
  ,p_award_short_name             in     varchar2  default hr_api.g_varchar2
  ,p_proposed_salary_amt          in     number    default hr_api.g_number
  ,p_proposed_effort_percent      in     number    default hr_api.g_number
  ,p_committed_cost_share         in     number    default hr_api.g_number
  ,p_schedule_start_date          in     date      default hr_api.g_date
  ,p_schedule_end_date            in     date      default hr_api.g_date
  ,p_ame_transaction_id           in     varchar2  default hr_api.g_varchar2
  ,p_investigator_name            in     varchar2  default hr_api.g_varchar2
  ,p_investigator_person_id       in     number    default hr_api.g_number
  ,p_investigator_org_name        in     varchar2  default hr_api.g_varchar2
  ,p_investigator_primary_org_id  in     number    default hr_api.g_number
  ,p_value1                       in     number    default hr_api.g_number
  ,p_value2                       in     number    default hr_api.g_number
  ,p_value3                       in     number    default hr_api.g_number
  ,p_value4                       in     number    default hr_api.g_number
  ,p_value5                       in     number    default hr_api.g_number
  ,p_value6                       in     number    default hr_api.g_number
  ,p_value7                       in     number    default hr_api.g_number
  ,p_value8                       in     number    default hr_api.g_number
  ,p_value9                       in     number    default hr_api.g_number
  ,p_value10                      in     number    default hr_api.g_number
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_grouping_category            in     varchar2  default hr_api.g_varchar2
  );
--
end psp_erd_upd;

 

/
