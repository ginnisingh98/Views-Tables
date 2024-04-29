--------------------------------------------------------
--  DDL for Package BEN_CPI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPI_UPD" AUTHID CURRENT_USER as
/* $Header: becpirhi.pkh 120.0 2005/05/28 01:13 appldev noship $ */
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
  (p_rec                          in out nocopy ben_cpi_shd.g_rec_type
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
  (p_group_per_in_ler_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_full_name                    in     varchar2  default hr_api.g_varchar2
  ,p_brief_name                   in     varchar2  default hr_api.g_varchar2
  ,p_custom_name                  in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_full_name         in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_brief_name        in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_custom_name       in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_years_employed               in     number    default hr_api.g_number
  ,p_years_in_job                 in     number    default hr_api.g_number
  ,p_years_in_position            in     number    default hr_api.g_number
  ,p_years_in_grade               in     number    default hr_api.g_number
  ,p_employee_number              in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_original_start_date          in     date      default hr_api.g_date
  ,p_adjusted_svc_date            in     date      default hr_api.g_date
  ,p_base_salary                  in     number    default hr_api.g_number
  ,p_base_salary_change_date      in     date      default hr_api.g_date
  ,p_payroll_name                 in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating           in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating_type      in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating_date      in     date      default hr_api.g_date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_pay_rate_id                  in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_grade_annulization_factor    in     number    default hr_api.g_number
  ,p_pay_annulization_factor      in     number    default hr_api.g_number
  ,p_grd_min_val                  in     number    default hr_api.g_number
  ,p_grd_max_val                  in     number    default hr_api.g_number
  ,p_grd_mid_point                in     number    default hr_api.g_number
  ,p_grd_quartile                 in     varchar2  default hr_api.g_varchar2
  ,p_grd_comparatio               in     number    default hr_api.g_number
  ,p_emp_category                 in     varchar2  default hr_api.g_varchar2
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_email_address                in     varchar2  default hr_api.g_varchar2
  ,p_base_salary_frequency        in     varchar2  default hr_api.g_varchar2
  ,p_new_assgn_ovn                in     number    default hr_api.g_number
  ,p_new_perf_event_id            in     number    default hr_api.g_number
  ,p_new_perf_review_id           in     number    default hr_api.g_number
  ,p_post_process_stat_cd         in     varchar2  default hr_api.g_varchar2
  ,p_feedback_rating              in     varchar2  default hr_api.g_varchar2
  ,p_feedback_comments            in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment1              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment2              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment3              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment4              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment5              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment6              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment7              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment8              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment9              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment10             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment11             in     number    default hr_api.g_number
  ,p_custom_segment12             in     number    default hr_api.g_number
  ,p_custom_segment13             in     number    default hr_api.g_number
  ,p_custom_segment14             in     number    default hr_api.g_number
  ,p_custom_segment15             in     number    default hr_api.g_number
  ,p_custom_segment16             in     number    default hr_api.g_number
  ,p_custom_segment17             in     number    default hr_api.g_number
  ,p_custom_segment18             in     number    default hr_api.g_number
  ,p_custom_segment19             in     number    default hr_api.g_number
  ,p_custom_segment20             in     number    default hr_api.g_number
  ,p_people_group_name            in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment1        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment2        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment3        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment4        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment5        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment6        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment7        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment8        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment9        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment10       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment11       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_ws_comments                  in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_feedback_date                in     date      default hr_api.g_date
  );
--
end ben_cpi_upd;

 

/
