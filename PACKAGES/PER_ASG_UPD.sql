--------------------------------------------------------
--  DDL for Package PER_ASG_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_UPD" AUTHID CURRENT_USER as
/* $Header: peasgrhi.pkh 120.4.12010000.2 2009/11/20 06:56:26 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd business process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   3) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   4) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   5) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   6) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   7) The update_dml process will physical perform the update dml into the
--      specified entity.
--   8) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   9) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode. If
--   the p_validate argument has been set to true then all the work will be
--   rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  (
  p_rec                        in out nocopy    per_asg_shd.g_rec_type,
  p_effective_date             in       date,
  p_datetrack_mode             in       varchar2,
  p_validation_start_date      out nocopy      date,
  p_validation_end_date        out nocopy      date,
  p_validate                   in       boolean default false,
  p_payroll_id_updated         out nocopy      boolean,
  p_other_manager_warning      out nocopy boolean,
  p_hourly_salaried_warning    out nocopy boolean,
  p_no_managers_warning        out nocopy boolean,
  p_org_now_no_manager_warning out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   business process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--   Note that the out parameter p_business_group_id will always be set,
--   regardless of the p_validate value.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  (
  p_assignment_id                in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            out nocopy number,
  p_recruiter_id                 in number           default hr_api.g_number,
  p_grade_id                     in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_assignment_status_type_id    in number           default hr_api.g_number,
  p_payroll_id                   in number           default hr_api.g_number,
  p_location_id                  in number           default hr_api.g_number,
  p_person_referred_by_id        in number           default hr_api.g_number,
  p_supervisor_id                in number           default hr_api.g_number,
  p_special_ceiling_step_id      in number           default hr_api.g_number,
  p_recruitment_activity_id      in number           default hr_api.g_number,
  p_source_organization_id       in number           default hr_api.g_number,

  p_organization_id              in number           default hr_api.g_number,
  p_people_group_id              in number           default hr_api.g_number,
  p_soft_coding_keyflex_id       in number           default hr_api.g_number,
  p_vacancy_id                   in number           default hr_api.g_number,
  p_pay_basis_id                 in number           default hr_api.g_number,
  p_assignment_type              in varchar2         default hr_api.g_varchar2,
  p_primary_flag                 in varchar2         default hr_api.g_varchar2,
  p_application_id               in number           default hr_api.g_number,
  p_assignment_number            in varchar2         default hr_api.g_varchar2,
  p_change_reason                in varchar2         default hr_api.g_varchar2,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_date_probation_end           in date             default hr_api.g_date,

  p_default_code_comb_id         in number           default hr_api.g_number,
  p_employment_category          in varchar2         default hr_api.g_varchar2,
  p_frequency                    in varchar2         default hr_api.g_varchar2,
  p_internal_address_line        in varchar2         default hr_api.g_varchar2,
  p_manager_flag                 in varchar2         default hr_api.g_varchar2,
  p_normal_hours                 in number           default hr_api.g_number,
  p_perf_review_period           in number           default hr_api.g_number,
  p_perf_review_period_frequency in varchar2         default hr_api.g_varchar2,
  p_period_of_service_id         in number           default hr_api.g_number,
  p_probation_period             in number           default hr_api.g_number,
  p_probation_unit               in varchar2         default hr_api.g_varchar2,
  p_sal_review_period            in number           default hr_api.g_number,
  p_sal_review_period_frequency  in varchar2         default hr_api.g_varchar2,
  p_set_of_books_id              in number           default hr_api.g_number,

  p_source_type                  in varchar2         default hr_api.g_varchar2,
  p_time_normal_finish           in varchar2         default hr_api.g_varchar2,
  p_time_normal_start            in varchar2         default hr_api.g_varchar2,
  p_bargaining_unit_code         in varchar2         default hr_api.g_varchar2,
  p_labour_union_member_flag     in varchar2         default hr_api.g_varchar2,
  p_hourly_salaried_code         in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_ass_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_ass_attribute1               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute2               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute3               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute4               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute5               in varchar2         default hr_api.g_varchar2,

  p_ass_attribute6               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute7               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute8               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute9               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute10              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute11              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute12              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute13              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute14              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute15              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute16              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute17              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute18              in varchar2         default hr_api.g_varchar2,

  p_ass_attribute19              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute20              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute21              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute22              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute23              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute24              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute25              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute26              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute27              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute28              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute29              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute30              in varchar2         default hr_api.g_varchar2,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_contract_id                  in number           default hr_api.g_number,
  p_establishment_id             in number           default hr_api.g_number,
  p_collective_agreement_id      in number           default hr_api.g_number,
  p_cagr_grade_def_id            in number           default hr_api.g_number,
  p_cagr_id_flex_num             in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_notice_period                in number           default hr_api.g_number,
  p_notice_period_uom            in varchar2         default hr_api.g_varchar2,
  p_employee_category            in varchar2         default hr_api.g_varchar2,
  p_work_at_home                 in varchar2         default hr_api.g_varchar2,
  p_job_post_source_name         in varchar2         default hr_api.g_varchar2,
  p_posting_content_id           in number           default hr_api.g_number,
  p_placement_date_start         in date             default hr_api.g_date,
  p_vendor_id                    in number           default hr_api.g_number,
  p_vendor_employee_number       in varchar2         default hr_api.g_varchar2,
  p_vendor_assignment_number     in varchar2         default hr_api.g_varchar2,
  p_assignment_category          in varchar2         default hr_api.g_varchar2,
  p_project_title                in varchar2         default hr_api.g_varchar2,
  p_applicant_rank               in number           default hr_api.g_number,
  p_grade_ladder_pgm_id          in number           default hr_api.g_number,
  p_supervisor_assignment_id     in number           default hr_api.g_number,
  p_vendor_site_id               in number           default hr_api.g_number,
  p_po_header_id                 in number           default hr_api.g_number,
  p_po_line_id                   in number           default hr_api.g_number,
  p_projected_assignment_end     in date             default hr_api.g_date,
  p_payroll_id_updated           out nocopy boolean,
  p_other_manager_warning        out nocopy boolean,
  p_hourly_salaried_warning      out nocopy boolean,
  p_no_managers_warning          out nocopy boolean,
  p_org_now_no_manager_warning   out nocopy boolean,
  p_validation_start_date        out nocopy date,
  p_validation_end_date          out nocopy date,
  p_effective_date               in date,
  p_datetrack_mode               in varchar2,
  p_validate                     in boolean      default false
  );
--
end per_asg_upd;

/
