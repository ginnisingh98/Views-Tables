--------------------------------------------------------
--  DDL for Package BEN_CPI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPI_INS" AUTHID CURRENT_USER as
/* $Header: becpirhi.pkh 120.0 2005/05/28 01:13 appldev noship $ */
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
  (p_group_per_in_ler_id  in  number);
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
  (p_rec                      in out nocopy ben_cpi_shd.g_rec_type
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
  (p_group_per_in_ler_id            in     number
  ,p_assignment_id                  in     number   default null
  ,p_person_id                      in     number   default null
  ,p_supervisor_id                  in     number   default null
  ,p_effective_date                 in     date     default null
  ,p_full_name                      in     varchar2 default null
  ,p_brief_name                     in     varchar2 default null
  ,p_custom_name                    in     varchar2 default null
  ,p_supervisor_full_name           in     varchar2 default null
  ,p_supervisor_brief_name          in     varchar2 default null
  ,p_supervisor_custom_name         in     varchar2 default null
  ,p_legislation_code               in     varchar2 default null
  ,p_years_employed                 in     number   default null
  ,p_years_in_job                   in     number   default null
  ,p_years_in_position              in     number   default null
  ,p_years_in_grade                 in     number   default null
  ,p_employee_number                in     varchar2 default null
  ,p_start_date                     in     date     default null
  ,p_original_start_date            in     date     default null
  ,p_adjusted_svc_date              in     date     default null
  ,p_base_salary                    in     number   default null
  ,p_base_salary_change_date        in     date     default null
  ,p_payroll_name                   in     varchar2 default null
  ,p_performance_rating             in     varchar2 default null
  ,p_performance_rating_type        in     varchar2 default null
  ,p_performance_rating_date        in     date     default null
  ,p_business_group_id              in     number   default null
  ,p_organization_id                in     number   default null
  ,p_job_id                         in     number   default null
  ,p_grade_id                       in     number   default null
  ,p_position_id                    in     number   default null
  ,p_people_group_id                in     number   default null
  ,p_soft_coding_keyflex_id         in     number   default null
  ,p_location_id                    in     number   default null
  ,p_pay_rate_id                    in     number   default null
  ,p_assignment_status_type_id      in     number   default null
  ,p_frequency                      in     varchar2 default null
  ,p_grade_annulization_factor      in     number   default null
  ,p_pay_annulization_factor        in     number   default null
  ,p_grd_min_val                    in     number   default null
  ,p_grd_max_val                    in     number   default null
  ,p_grd_mid_point                  in     number   default null
  ,p_grd_quartile                   in     varchar2 default null
  ,p_grd_comparatio                 in     number   default null
  ,p_emp_category                   in     varchar2 default null
  ,p_change_reason                  in     varchar2 default null
  ,p_normal_hours                   in     number   default null
  ,p_email_address                  in     varchar2 default null
  ,p_base_salary_frequency          in     varchar2 default null
  ,p_new_assgn_ovn                  in     number   default null
  ,p_new_perf_event_id              in     number   default null
  ,p_new_perf_review_id             in     number   default null
  ,p_post_process_stat_cd           in     varchar2 default null
  ,p_feedback_rating                in     varchar2 default null
  ,p_feedback_comments              in     varchar2 default null
  ,p_custom_segment1                in     varchar2 default null
  ,p_custom_segment2                in     varchar2 default null
  ,p_custom_segment3                in     varchar2 default null
  ,p_custom_segment4                in     varchar2 default null
  ,p_custom_segment5                in     varchar2 default null
  ,p_custom_segment6                in     varchar2 default null
  ,p_custom_segment7                in     varchar2 default null
  ,p_custom_segment8                in     varchar2 default null
  ,p_custom_segment9                in     varchar2 default null
  ,p_custom_segment10               in     varchar2 default null
  ,p_custom_segment11               in     number   default null
  ,p_custom_segment12               in     number   default null
  ,p_custom_segment13               in     number   default null
  ,p_custom_segment14               in     number   default null
  ,p_custom_segment15               in     number   default null
  ,p_custom_segment16               in     number   default null
  ,p_custom_segment17               in     number   default null
  ,p_custom_segment18               in     number   default null
  ,p_custom_segment19               in     number   default null
  ,p_custom_segment20               in     number   default null
  ,p_people_group_name              in     varchar2 default null
  ,p_people_group_segment1          in     varchar2 default null
  ,p_people_group_segment2          in     varchar2 default null
  ,p_people_group_segment3          in     varchar2 default null
  ,p_people_group_segment4          in     varchar2 default null
  ,p_people_group_segment5          in     varchar2 default null
  ,p_people_group_segment6          in     varchar2 default null
  ,p_people_group_segment7          in     varchar2 default null
  ,p_people_group_segment8          in     varchar2 default null
  ,p_people_group_segment9          in     varchar2 default null
  ,p_people_group_segment10         in     varchar2 default null
  ,p_people_group_segment11         in     varchar2 default null
  ,p_ass_attribute_category         in     varchar2 default null
  ,p_ass_attribute1                 in     varchar2 default null
  ,p_ass_attribute2                 in     varchar2 default null
  ,p_ass_attribute3                 in     varchar2 default null
  ,p_ass_attribute4                 in     varchar2 default null
  ,p_ass_attribute5                 in     varchar2 default null
  ,p_ass_attribute6                 in     varchar2 default null
  ,p_ass_attribute7                 in     varchar2 default null
  ,p_ass_attribute8                 in     varchar2 default null
  ,p_ass_attribute9                 in     varchar2 default null
  ,p_ass_attribute10                in     varchar2 default null
  ,p_ass_attribute11                in     varchar2 default null
  ,p_ass_attribute12                in     varchar2 default null
  ,p_ass_attribute13                in     varchar2 default null
  ,p_ass_attribute14                in     varchar2 default null
  ,p_ass_attribute15                in     varchar2 default null
  ,p_ass_attribute16                in     varchar2 default null
  ,p_ass_attribute17                in     varchar2 default null
  ,p_ass_attribute18                in     varchar2 default null
  ,p_ass_attribute19                in     varchar2 default null
  ,p_ass_attribute20                in     varchar2 default null
  ,p_ass_attribute21                in     varchar2 default null
  ,p_ass_attribute22                in     varchar2 default null
  ,p_ass_attribute23                in     varchar2 default null
  ,p_ass_attribute24                in     varchar2 default null
  ,p_ass_attribute25                in     varchar2 default null
  ,p_ass_attribute26                in     varchar2 default null
  ,p_ass_attribute27                in     varchar2 default null
  ,p_ass_attribute28                in     varchar2 default null
  ,p_ass_attribute29                in     varchar2 default null
  ,p_ass_attribute30                in     varchar2 default null
  ,p_ws_comments                    in     varchar2 default null
  ,p_cpi_attribute_category         in     varchar2 default null
  ,p_cpi_attribute1                 in     varchar2 default null
  ,p_cpi_attribute2                 in     varchar2 default null
  ,p_cpi_attribute3                 in     varchar2 default null
  ,p_cpi_attribute4                 in     varchar2 default null
  ,p_cpi_attribute5                 in     varchar2 default null
  ,p_cpi_attribute6                 in     varchar2 default null
  ,p_cpi_attribute7                 in     varchar2 default null
  ,p_cpi_attribute8                 in     varchar2 default null
  ,p_cpi_attribute9                 in     varchar2 default null
  ,p_cpi_attribute10                in     varchar2 default null
  ,p_cpi_attribute11                in     varchar2 default null
  ,p_cpi_attribute12                in     varchar2 default null
  ,p_cpi_attribute13                in     varchar2 default null
  ,p_cpi_attribute14                in     varchar2 default null
  ,p_cpi_attribute15                in     varchar2 default null
  ,p_cpi_attribute16                in     varchar2 default null
  ,p_cpi_attribute17                in     varchar2 default null
  ,p_cpi_attribute18                in     varchar2 default null
  ,p_cpi_attribute19                in     varchar2 default null
  ,p_cpi_attribute20                in     varchar2 default null
  ,p_cpi_attribute21                in     varchar2 default null
  ,p_cpi_attribute22                in     varchar2 default null
  ,p_cpi_attribute23                in     varchar2 default null
  ,p_cpi_attribute24                in     varchar2 default null
  ,p_cpi_attribute25                in     varchar2 default null
  ,p_cpi_attribute26                in     varchar2 default null
  ,p_cpi_attribute27                in     varchar2 default null
  ,p_cpi_attribute28                in     varchar2 default null
  ,p_cpi_attribute29                in     varchar2 default null
  ,p_cpi_attribute30                in     varchar2 default null
  ,p_feedback_date                  in     date     default null
  ,p_object_version_number             out nocopy number
  );
--
end ben_cpi_ins;

 

/
