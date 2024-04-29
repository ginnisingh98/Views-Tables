--------------------------------------------------------
--  DDL for Package PER_SSL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSL_UPD" AUTHID CURRENT_USER as
/* $Header: pesslrhi.pkh 120.0.12010000.1 2008/07/28 06:01:26 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
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
  p_rec            in out nocopy per_ssl_shd.g_rec_type,
  p_effective_date in date
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
  p_salary_survey_line_id        in number,
  p_object_version_number        in out nocopy number,
  p_survey_job_name_code         in varchar2         default hr_api.g_varchar2,
  p_survey_region_code           in varchar2         default hr_api.g_varchar2,
  p_survey_seniority_code        in varchar2         default hr_api.g_varchar2,
  p_company_size_code            in varchar2         default hr_api.g_varchar2,
  p_industry_code                in varchar2         default hr_api.g_varchar2,
  p_survey_age_code              in varchar2         default hr_api.g_varchar2,
  p_start_date                   in date             default hr_api.g_date,
  p_end_date                     in date             default hr_api.g_date,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_differential                 in number           default hr_api.g_number,
  p_minimum_pay                  in number           default hr_api.g_number,
  p_mean_pay                     in number           default hr_api.g_number,
  p_maximum_pay                  in number           default hr_api.g_number,
  p_graduate_pay                 in number           default hr_api.g_number,
  p_starting_pay                 in number           default hr_api.g_number,
  p_percentage_change            in number           default hr_api.g_number,
  p_job_first_quartile           in number           default hr_api.g_number,
  p_job_median_quartile          in number           default hr_api.g_number,
  p_job_third_quartile           in number           default hr_api.g_number,
  p_job_fourth_quartile          in number           default hr_api.g_number,
  p_minimum_total_compensation   in number           default hr_api.g_number,
  p_mean_total_compensation      in number           default hr_api.g_number,
  p_maximum_total_compensation   in number           default hr_api.g_number,
  p_compnstn_first_quartile      in number           default hr_api.g_number,
  p_compnstn_median_quartile     in number           default hr_api.g_number,
  p_compnstn_third_quartile      in number           default hr_api.g_number,
  p_compnstn_fourth_quartile     in number           default hr_api.g_number,
/*Added for Enhancement 4021737 */
  p_tenth_percentile             in number           default hr_api.g_number,
  p_twenty_fifth_percentile      in number           default hr_api.g_number,
  p_fiftieth_percentile          in number           default hr_api.g_number,
  p_seventy_fifth_percentile     in number           default hr_api.g_number,
  p_ninetieth_percentile         in number           default hr_api.g_number,
  p_minimum_bonus                in number           default hr_api.g_number,
  p_mean_bonus                   in number           default hr_api.g_number,
  p_maximum_bonus                in number           default hr_api.g_number,
  p_minimum_salary_increase      in number           default hr_api.g_number,
  p_mean_salary_increase         in number           default hr_api.g_number,
  p_maximum_salary_increase      in number           default hr_api.g_number,
  p_min_variable_compensation    in number           default hr_api.g_number,
  p_mean_variable_compensation   in number           default hr_api.g_number,
  p_max_variable_compensation    in number           default hr_api.g_number,
  p_minimum_stock                in number           default hr_api.g_number,
  p_mean_stock                   in number           default hr_api.g_number,
  p_maximum_stock                in number           default hr_api.g_number,
  p_stock_display_type           in varchar2         default hr_api.g_varchar2,
/*End Enhancement 4021737 */
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
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
/*Added for Enhancement 4021737 */
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
/*End Enhancement 4021737  */
  p_effective_date               in date             default hr_api.g_date
  );
--
end per_ssl_upd;

/
