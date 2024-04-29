--------------------------------------------------------
--  DDL for Package HR_PSF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PSF_UPD" AUTHID CURRENT_USER as
/* $Header: hrpsfrhi.pkh 120.1.12010000.3 2008/08/06 12:49:25 sathkris ship $ */
--
--
  g_debug boolean := hr_utility.debug_enabled;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--
-- Post Success:
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode.
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
  p_rec        in out nocopy  hr_psf_shd.g_rec_type,
  p_effective_date   in    date,
  p_datetrack_mode   in    varchar2,
  p_validate        in   boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.
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
  p_position_id                  in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_availability_status_id       in number           default hr_api.g_number,
--  p_business_group_id            in number           default hr_api.g_number,
  p_entry_step_id                in number           default hr_api.g_number,
  p_entry_grade_rule_id          in number           default hr_api.g_number,
--  p_job_id                       in number           default hr_api.g_number,
  p_location_id                  in number           default hr_api.g_number,
--  p_organization_id              in number           default hr_api.g_number,
  p_pay_freq_payroll_id          in number           default hr_api.g_number,
  p_position_definition_id       in number           default hr_api.g_number,
  p_position_transaction_id      in number           default hr_api.g_number,
  p_prior_position_id            in number           default hr_api.g_number,
  p_relief_position_id           in number           default hr_api.g_number,
  p_entry_grade_id               in number           default hr_api.g_number,
  p_successor_position_id        in number           default hr_api.g_number,
  p_supervisor_position_id       in number           default hr_api.g_number,
  p_amendment_date               in date             default hr_api.g_date,
  p_amendment_recommendation     in varchar2         default hr_api.g_varchar2,
  p_amendment_ref_number         in varchar2         default hr_api.g_varchar2,
  p_bargaining_unit_cd           in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_current_job_prop_end_date    in date             default hr_api.g_date,
  p_current_org_prop_end_date    in date             default hr_api.g_date,
  p_avail_status_prop_end_date   in date             default hr_api.g_date,
  p_date_effective               in date             default hr_api.g_date,
  p_date_end                     in date             default hr_api.g_date,
  p_earliest_hire_date           in date             default hr_api.g_date,
  p_fill_by_date                 in date             default hr_api.g_date,
  p_frequency                    in varchar2         default hr_api.g_varchar2,
  p_fte                          in number           default hr_api.g_number,
  p_max_persons                  in number           default hr_api.g_number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_overlap_period               in number           default hr_api.g_number,
  p_overlap_unit_cd              in varchar2         default hr_api.g_varchar2,
  p_pay_term_end_day_cd          in varchar2         default hr_api.g_varchar2,
  p_pay_term_end_month_cd        in varchar2         default hr_api.g_varchar2,
  p_permanent_temporary_flag     in varchar2         default hr_api.g_varchar2,
  p_permit_recruitment_flag      in varchar2         default hr_api.g_varchar2,
  p_position_type                in varchar2         default hr_api.g_varchar2,
  p_posting_description          in varchar2         default hr_api.g_varchar2,
  p_probation_period             in number           default hr_api.g_number,
  p_probation_period_unit_cd     in varchar2         default hr_api.g_varchar2,
  p_replacement_required_flag    in varchar2         default hr_api.g_varchar2,
  p_review_flag                  in varchar2         default hr_api.g_varchar2,
  p_seasonal_flag                in varchar2         default hr_api.g_varchar2,
  p_security_requirements        in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_term_start_day_cd            in varchar2         default hr_api.g_varchar2,
  p_term_start_month_cd          in varchar2         default hr_api.g_varchar2,
  p_time_normal_finish           in varchar2         default hr_api.g_varchar2,
  p_time_normal_start            in varchar2         default hr_api.g_varchar2,
  p_update_source_cd             in varchar2         default hr_api.g_varchar2,
  p_working_hours                in number           default hr_api.g_number,
  p_works_council_approval_flag  in varchar2         default hr_api.g_varchar2,
  p_work_period_type_cd          in varchar2         default hr_api.g_varchar2,
  p_work_term_end_day_cd         in varchar2         default hr_api.g_varchar2,
  p_work_term_end_month_cd       in varchar2         default hr_api.g_varchar2,
  p_proposed_fte_for_layoff      in number           default hr_api.g_number,
  p_proposed_date_for_layoff     in date             default hr_api.g_date,
  p_pay_basis_id                 in  number          default hr_api.g_number,
  p_supervisor_id                in  number          default hr_api.g_number,
  p_copied_to_old_table_flag     in  varchar2          default hr_api.g_varchar2,
  p_information1                 in varchar2         default hr_api.g_varchar2,
  p_information2                 in varchar2         default hr_api.g_varchar2,
  p_information3                 in varchar2         default hr_api.g_varchar2,
  p_information4                 in varchar2         default hr_api.g_varchar2,
  p_information5                 in varchar2         default hr_api.g_varchar2,
  p_information6                 in varchar2         default hr_api.g_varchar2,
  p_information7                 in varchar2         default hr_api.g_varchar2,
  p_information8                 in varchar2         default hr_api.g_varchar2,
  p_information9                 in varchar2         default hr_api.g_varchar2,
  p_information10                in varchar2         default hr_api.g_varchar2,
  p_information11                in varchar2         default hr_api.g_varchar2,
  p_information12                in varchar2         default hr_api.g_varchar2,
  p_information13                in varchar2         default hr_api.g_varchar2,
  p_information14                in varchar2         default hr_api.g_varchar2,
  p_information15                in varchar2         default hr_api.g_varchar2,
  p_information16                in varchar2         default hr_api.g_varchar2,
  p_information17                in varchar2         default hr_api.g_varchar2,
  p_information18                in varchar2         default hr_api.g_varchar2,
  p_information19                in varchar2         default hr_api.g_varchar2,
  p_information20                in varchar2         default hr_api.g_varchar2,
  p_information21                in varchar2         default hr_api.g_varchar2,
  p_information22                in varchar2         default hr_api.g_varchar2,
  p_information23                in varchar2         default hr_api.g_varchar2,
  p_information24                in varchar2         default hr_api.g_varchar2,
  p_information25                in varchar2         default hr_api.g_varchar2,
  p_information26                in varchar2         default hr_api.g_varchar2,
  p_information27                in varchar2         default hr_api.g_varchar2,
  p_information28                in varchar2         default hr_api.g_varchar2,
  p_information29                in varchar2         default hr_api.g_varchar2,
  p_information30                in varchar2         default hr_api.g_varchar2,
  p_information_category         in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_effective_date       in date,
  p_datetrack_mode       in varchar2,
  p_validate        in   boolean default false
  );
--
end hr_psf_upd;

/
