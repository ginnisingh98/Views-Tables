--------------------------------------------------------
--  DDL for Package PQH_PTX_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_INS" AUTHID CURRENT_USER as
/* $Header: pqptxrhi.pkh 120.0.12010000.2 2008/08/06 07:42:54 sathkris ship $ */

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
  p_effective_date               in date,
  p_rec        in out nocopy pqh_ptx_shd.g_rec_type
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
  p_effective_date               in date,
  p_position_transaction_id      out nocopy number,
  p_action_date                  in date             default null,
  p_position_id                  in number           default null,
  p_availability_status_id       in number           default null,
  p_business_group_id            in number           default null,
  p_entry_step_id                in number           default null,
  p_entry_grade_rule_id                in number           default null,
  p_job_id                       in number           default null,
  p_location_id                  in number           default null,
  p_organization_id              in number           default null,
  p_pay_freq_payroll_id          in number           default null,
  p_position_definition_id       in number           default null,
  p_prior_position_id            in number           default null,
  p_relief_position_id           in number           default null,
  p_entry_grade_id        in number           default null,
  p_successor_position_id        in number           default null,
  p_supervisor_position_id       in number           default null,
  p_amendment_date               in date             default null,
  p_amendment_recommendation     in varchar2         default null,
  p_amendment_ref_number         in varchar2         default null,
  p_avail_status_prop_end_date   in date             default null,
  p_bargaining_unit_cd           in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_country1                     in varchar2         default null,
  p_country2                     in varchar2         default null,
  p_country3                     in varchar2         default null,
  p_current_job_prop_end_date    in date             default null,
  p_current_org_prop_end_date    in date             default null,
  p_date_effective               in date             default null,
  p_date_end                     in date             default null,
  p_earliest_hire_date           in date             default null,
  p_fill_by_date                 in date             default null,
  p_frequency                    in varchar2         default null,
  p_fte                          in number           default null,
  p_fte_capacity                 in varchar2         default null,
  p_location1                    in varchar2         default null,
  p_location2                    in varchar2         default null,
  p_location3                    in varchar2         default null,
  p_max_persons                  in number           default null,
  p_name                         in varchar2         default null,
  p_other_requirements           in varchar2         default null,
  p_overlap_period               in number           default null,
  p_overlap_unit_cd              in varchar2         default null,
  p_passport_required            in varchar2         default null,
  p_pay_term_end_day_cd          in varchar2         default null,
  p_pay_term_end_month_cd        in varchar2         default null,
  p_permanent_temporary_flag     in varchar2         default null,
  p_permit_recruitment_flag      in varchar2         default null,
  p_position_type                in varchar2         default null,
  p_posting_description          in varchar2         default null,
  p_probation_period             in number           default null,
  p_probation_period_unit_cd     in varchar2         default null,
  p_relocate_domestically        in varchar2         default null,
  p_relocate_internationally     in varchar2         default null,
  p_replacement_required_flag    in varchar2         default null,
  p_review_flag                  in varchar2         default null,
  p_seasonal_flag                in varchar2         default null,
  p_security_requirements        in varchar2         default null,
  p_service_minimum              in varchar2         default null,
  p_term_start_day_cd            in varchar2         default null,
  p_term_start_month_cd          in varchar2         default null,
  p_time_normal_finish           in varchar2         default null,
  p_time_normal_start            in varchar2         default null,
  p_transaction_status           in varchar2         default null,
  p_travel_required              in varchar2         default null,
  p_working_hours                in number           default null,
  p_works_council_approval_flag  in varchar2         default null,
  p_work_any_country             in varchar2         default null,
  p_work_any_location            in varchar2         default null,
  p_work_period_type_cd          in varchar2         default null,
  p_work_schedule                in varchar2         default null,
  p_work_duration                in varchar2         default null,
  p_work_term_end_day_cd         in varchar2         default null,
  p_work_term_end_month_cd       in varchar2         default null,
  p_proposed_fte_for_layoff      in number           default null,
  p_proposed_date_for_layoff     in date             default null,
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
  p_object_version_number        out nocopy number ,
  p_pay_basis_id                 in number 	     default null,
  p_supervisor_id          	 in number 	     default null,
  p_wf_transaction_category_id 	 in number 	     default null
  );
--
end pqh_ptx_ins;

/
