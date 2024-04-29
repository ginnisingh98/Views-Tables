--------------------------------------------------------
--  DDL for Package BEN_ASG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ASG_INS" AUTHID CURRENT_USER as
/* $Header: beasgrhi.pkh 120.0.12010000.1 2008/07/29 10:51:34 appldev ship $ */

g_trgr_loc_chg boolean default TRUE;

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
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
    (p_rec           in out nocopy per_asg_shd.g_rec_type,
     p_effective_date    in date,
     p_datetrack_mode    in varchar2,
     p_validation_start_date in date,
     p_validation_end_date   in date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the specified entity. The role of this process is to insert a
--   row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) We must lock parent rows (if any exist).
--   3) No validation business rules are executed.
--   4) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   5) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   6) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   7) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
--   p_validate_df_flex
--     Optional parameter used to determine whether descriptive flexfield
--     validation is to be performed or bypassed; necessary for API calls
--     that attempt to insert an assignment row but are unable to complete
--     as they have no means of providing mandatory segment values. Default
--     is True - perform validation.
--
-- Post Success:
--   A row will be inserted into the specified entity without being committed.
--   If the p_validate argument has been set to true then all the work will
--   be rolled back.
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
  p_rec                    in out nocopy per_asg_shd.g_rec_type,
  p_effective_date             in     date,
  p_validate                   in     boolean default false,
  p_validate_df_flex           in     boolean default true,
  --
  -- 70.2 change a start.
  --
  p_other_manager_warning      out nocopy    boolean,
-- Bug 2033513
  p_hourly_salaried_warning    out nocopy    boolean
  --
  -- 70.2 change a end.
  --
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--   p_validate_df_flex
--     Optional parameter used to determine whether descriptive flexfield
--     validation is to be performed or bypassed; necessary for API calls
--     that attempt to insert an assignment row but are unable to complete
--     as they have no means of providing mandatory segment values. Default
--     is True - perform validation
--
-- Post Success:
--   A row will be inserted for the specified entity without being committed
--   (or rollbacked depending on the p_validate status).
--   p_assignment_number has been validated or generated.
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
  p_assignment_id                out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_recruiter_id                 in number           default null,
  p_grade_id                     in number           default null,
  p_position_id                  in number           default null,
  p_job_id                       in number           default null,
  p_assignment_status_type_id    in number,
  p_payroll_id                   in number           default null,
  p_location_id                  in number           default null,
  p_person_referred_by_id        in number           default null,
  p_supervisor_id                in number           default null,
  p_special_ceiling_step_id      in number           default null,
  p_person_id                    in number,
  p_recruitment_activity_id      in number           default null,
  p_source_organization_id       in number           default null,
  p_organization_id              in number,
  p_people_group_id              in number           default null,
  p_soft_coding_keyflex_id       in number           default null,
  p_vacancy_id                   in number           default null,
  p_pay_basis_id                 in number           default null,
  p_assignment_sequence          out nocopy number,
  p_assignment_type              in varchar2,
  p_primary_flag                 in varchar2,
  p_application_id               in number           default null,
  p_assignment_number            in out nocopy varchar2,
  p_change_reason                in varchar2         default null,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default null,
  p_date_probation_end           in date             default null,
  p_default_code_comb_id         in number           default null,
  p_employment_category          in varchar2         default null,
  p_frequency                    in varchar2         default null,
  p_internal_address_line        in varchar2         default null,
  p_manager_flag                 in varchar2         default null,
  p_normal_hours                 in number           default null,
  p_perf_review_period           in number           default null,
  p_perf_review_period_frequency in varchar2         default null,
  p_period_of_service_id         in number           default null,
  p_probation_period             in number           default null,
  p_probation_unit               in varchar2         default null,
  p_sal_review_period            in number           default null,
  p_sal_review_period_frequency  in varchar2         default null,
  p_set_of_books_id              in number           default null,
  p_source_type                  in varchar2         default null,
  p_time_normal_finish           in varchar2         default null,
  p_time_normal_start            in varchar2         default null,
  p_bargaining_unit_code         in varchar2         default null,
  p_labour_union_member_flag     in varchar2         default 'N',
  p_hourly_salaried_code         in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_ass_attribute_category       in varchar2         default null,
  p_ass_attribute1               in varchar2         default null,
  p_ass_attribute2               in varchar2         default null,
  p_ass_attribute3               in varchar2         default null,
  p_ass_attribute4               in varchar2         default null,
  p_ass_attribute5               in varchar2         default null,
  p_ass_attribute6               in varchar2         default null,
  p_ass_attribute7               in varchar2         default null,
  p_ass_attribute8               in varchar2         default null,
  p_ass_attribute9               in varchar2         default null,
  p_ass_attribute10              in varchar2         default null,
  p_ass_attribute11              in varchar2         default null,
  p_ass_attribute12              in varchar2         default null,
  p_ass_attribute13              in varchar2         default null,
  p_ass_attribute14              in varchar2         default null,
  p_ass_attribute15              in varchar2         default null,
  p_ass_attribute16              in varchar2         default null,
  p_ass_attribute17              in varchar2         default null,
  p_ass_attribute18              in varchar2         default null,
  p_ass_attribute19              in varchar2         default null,
  p_ass_attribute20              in varchar2         default null,
  p_ass_attribute21              in varchar2         default null,
  p_ass_attribute22              in varchar2         default null,
  p_ass_attribute23              in varchar2         default null,
  p_ass_attribute24              in varchar2         default null,
  p_ass_attribute25              in varchar2         default null,
  p_ass_attribute26              in varchar2         default null,
  p_ass_attribute27              in varchar2         default null,
  p_ass_attribute28              in varchar2         default null,
  p_ass_attribute29              in varchar2         default null,
  p_ass_attribute30              in varchar2         default null,
  p_title                        in varchar2         default null,
  p_validate_df_flex             in boolean          default true,
  p_object_version_number        out nocopy number,
  p_other_manager_warning        out nocopy boolean,
  p_hourly_salaried_warning      out nocopy boolean,
  p_effective_date       in date,
  p_validate             in boolean          default false ,
  p_contract_id                  in number           default null,
  p_establishment_id             in number           default null,
  p_collective_agreement_id      in number           default null,
  p_cagr_grade_def_id            in number           default null,
  p_cagr_id_flex_num             in number           default null,
  p_notice_period        in number       default null,
  p_notice_period_uom        in varchar2         default null,
  p_employee_category        in varchar2         default null,
  p_work_at_home         in varchar2         default null,
  p_job_post_source_name     in varchar2         default null,
  p_posting_content_id           in number           default null,
  p_placement_date_start         in date             default null,
  p_vendor_id                    in number           default null,
  p_vendor_employee_number       in varchar2         default null,
  p_vendor_assignment_number     in varchar2         default null,
  p_assignment_category          in varchar2         default null,
  p_project_title                in varchar2         default null,
  p_applicant_rank               in number           default null
 );
--
end ben_asg_ins;

/
