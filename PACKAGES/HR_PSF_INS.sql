--------------------------------------------------------
--  DDL for Package HR_PSF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PSF_INS" AUTHID CURRENT_USER as
/* $Header: hrpsfrhi.pkh 120.1.12010000.3 2008/08/06 12:49:25 sathkris ship $ */
--
--
g_debug boolean := hr_utility.debug_enabled;
--
--
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
  (p_position_id  in  number);
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date);
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
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) We must lock parent rows (if any exist).
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  (
  p_rec        in out nocopy hr_psf_shd.g_rec_type,
  p_effective_date in     date,
  p_validate        in   boolean default false
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
--   (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (
  p_position_id                  out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_availability_status_id       in number           default null,
  p_business_group_id            in number,
  p_entry_step_id                in number           default null,
  p_entry_grade_rule_id          in number           default null,
  p_job_id                       in number,
  p_location_id                  in number           default null,
  p_organization_id              in number,
  p_pay_freq_payroll_id          in number           default null,
  p_position_definition_id       in number,
  p_position_transaction_id      in number           default null,
  p_prior_position_id            in number           default null,
  p_relief_position_id           in number           default null,
  p_entry_grade_id               in number           default null,
  p_successor_position_id        in number           default null,
  p_supervisor_position_id       in number           default null,
  p_amendment_date               in date             default null,
  p_amendment_recommendation     in varchar2         default null,
  p_amendment_ref_number         in varchar2         default null,
  p_bargaining_unit_cd           in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_current_job_prop_end_date    in date             default null,
  p_current_org_prop_end_date    in date             default null,
  p_avail_status_prop_end_date   in date             default null,
  p_date_effective               in date,
  p_date_end                     in date             default null,
  p_earliest_hire_date           in date             default null,
  p_fill_by_date                 in date             default null,
  p_frequency                    in varchar2         default null,
  p_fte                          in number           default null,
  p_max_persons                  in number           default null,
  p_name                         in varchar2         default null,
  p_overlap_period               in number           default null,
  p_overlap_unit_cd              in varchar2         default null,
  p_pay_term_end_day_cd          in varchar2         default null,
  p_pay_term_end_month_cd        in varchar2         default null,
  p_permanent_temporary_flag     in varchar2         default null,
  p_permit_recruitment_flag      in varchar2         default null,
  p_position_type                in varchar2         default null,
  p_posting_description          in varchar2         default null,
  p_probation_period             in number           default null,
  p_probation_period_unit_cd     in varchar2         default null,
  p_replacement_required_flag    in varchar2         default null,
  p_review_flag                  in varchar2         default null,
  p_seasonal_flag                in varchar2         default null,
  p_security_requirements        in varchar2         default null,
  p_status                       in varchar2         default null,
  p_term_start_day_cd            in varchar2         default null,
  p_term_start_month_cd          in varchar2         default null,
  p_time_normal_finish           in varchar2         default null,
  p_time_normal_start            in varchar2         default null,
  p_update_source_cd             in varchar2         default null,
  p_working_hours                in number           default null,
  p_works_council_approval_flag  in varchar2         default null,
  p_work_period_type_cd          in varchar2         default null,
  p_work_term_end_day_cd         in varchar2         default null,
  p_work_term_end_month_cd       in varchar2         default null,
  p_proposed_fte_for_layoff      in number           default null,
  p_proposed_date_for_layoff     in date             default null,
  p_pay_basis_id                 in  number          default null,
  p_supervisor_id                in  number          default null,
  p_copied_to_old_table_flag     in  varchar2          default null,
  p_information1                 in varchar2         default null,
  p_information2                 in varchar2         default null,
  p_information3                 in varchar2         default null,
  p_information4                 in varchar2         default null,
  p_information5                 in varchar2         default null,
  p_information6                 in varchar2         default null,
  p_information7                 in varchar2         default null,
  p_information8                 in varchar2         default null,
  p_information9                 in varchar2         default null,
  p_information10                in varchar2         default null,
  p_information11                in varchar2         default null,
  p_information12                in varchar2         default null,
  p_information13                in varchar2         default null,
  p_information14                in varchar2         default null,
  p_information15                in varchar2         default null,
  p_information16                in varchar2         default null,
  p_information17                in varchar2         default null,
  p_information18                in varchar2         default null,
  p_information19                in varchar2         default null,
  p_information20                in varchar2         default null,
  p_information21                in varchar2         default null,
  p_information22                in varchar2         default null,
  p_information23                in varchar2         default null,
  p_information24                in varchar2         default null,
  p_information25                in varchar2         default null,
  p_information26                in varchar2         default null,
  p_information27                in varchar2         default null,
  p_information28                in varchar2         default null,
  p_information29                in varchar2         default null,
  p_information30                in varchar2         default null,
  p_information_category         in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_attribute21                  in varchar2         default null,
  p_attribute22                  in varchar2         default null,
  p_attribute23                  in varchar2         default null,
  p_attribute24                  in varchar2         default null,
  p_attribute25                  in varchar2         default null,
  p_attribute26                  in varchar2         default null,
  p_attribute27                  in varchar2         default null,
  p_attribute28                  in varchar2         default null,
  p_attribute29                  in varchar2         default null,
  p_attribute30                  in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number,
  p_effective_date       in date,
  p_validate        in   boolean default false,
  p_security_profile_id in number default hr_security.get_security_profile
  );
--
end hr_psf_ins;

/
