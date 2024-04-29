--------------------------------------------------------
--  DDL for Package PQP_ATD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ATD_UPD" AUTHID CURRENT_USER as
/* $Header: pqatdrhi.pkh 120.0.12010000.1 2008/07/28 11:08:00 appldev ship $ */
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
  p_effective_date               in date,
  p_rec        in out nocopy pqp_atd_shd.g_rec_type
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
  p_effective_date               in date,
  p_alien_transaction_id         in number,
  p_person_id                    in number           default hr_api.g_number,
  p_data_source_type             in varchar2         default hr_api.g_varchar2,
  p_tax_year                     in number           default hr_api.g_number,
  p_income_code                  in varchar2         default hr_api.g_varchar2,
  p_withholding_rate             in number           default hr_api.g_number,
  p_income_code_sub_type         in varchar2         default hr_api.g_varchar2,
  p_exemption_code               in varchar2         default hr_api.g_varchar2,
  p_maximum_benefit_amount       in number           default hr_api.g_number,
  p_retro_lose_ben_amt_flag      in varchar2         default hr_api.g_varchar2,
  p_date_benefit_ends            in date             default hr_api.g_date,
  p_retro_lose_ben_date_flag     in varchar2         default hr_api.g_varchar2,
  p_current_residency_status     in varchar2         default hr_api.g_varchar2,
  p_nra_to_ra_date               in date             default hr_api.g_date,
  p_target_departure_date        in date             default hr_api.g_date,
  p_tax_residence_country_code   in varchar2         default hr_api.g_varchar2,
  p_treaty_info_update_date      in date             default hr_api.g_date,
  p_nra_exempt_from_fica         in varchar2         default hr_api.g_varchar2,
  p_student_exempt_from_fica     in varchar2         default hr_api.g_varchar2,
  p_addl_withholding_flag        in varchar2         default hr_api.g_varchar2,
  p_addl_withholding_amt         in number           default hr_api.g_number,
  p_addl_wthldng_amt_period_type in varchar2         default hr_api.g_varchar2,
  p_personal_exemption           in number           default hr_api.g_number,
  p_addl_exemption_allowed       in number           default hr_api.g_number,
  p_number_of_days_in_usa        in number           default hr_api.g_number,
  p_wthldg_allow_eligible_flag   in varchar2         default hr_api.g_varchar2,
  p_treaty_ben_allowed_flag      in varchar2         default hr_api.g_varchar2,
  p_treaty_benefits_start_date   in date             default hr_api.g_date,
  p_ra_effective_date            in date             default hr_api.g_date,
  p_state_code                   in varchar2         default hr_api.g_varchar2,
  p_state_honors_treaty_flag     in varchar2         default hr_api.g_varchar2,
  p_ytd_payments                 in number           default hr_api.g_number,
  p_ytd_w2_payments              in number           default hr_api.g_number,
  p_ytd_w2_withholding           in number           default hr_api.g_number,
  p_ytd_withholding_allowance    in number           default hr_api.g_number,
  p_ytd_treaty_payments          in number           default hr_api.g_number,
  p_ytd_treaty_withheld_amt      in number           default hr_api.g_number,
  p_record_source                in varchar2         default hr_api.g_varchar2,
  p_visa_type                    in varchar2         default hr_api.g_varchar2,
  p_j_sub_type                   in varchar2         default hr_api.g_varchar2,
  p_primary_activity             in varchar2         default hr_api.g_varchar2,
  p_non_us_country_code          in varchar2         default hr_api.g_varchar2,
  p_citizenship_country_code     in varchar2         default hr_api.g_varchar2,
  p_constant_addl_tax            in number           default hr_api.g_number,
  p_date_8233_signed             in date             default hr_api.g_date,
  p_date_w4_signed               in date             default hr_api.g_date,
  p_error_indicator              in varchar2         default hr_api.g_varchar2,
  p_prev_er_treaty_benefit_amt   in number           default hr_api.g_number,
  p_error_text                   in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_current_analysis             in  varchar2        default hr_api.g_varchar2,
  p_forecast_income_code         in  varchar2        default hr_api.g_varchar2

  );
--
end pqp_atd_upd;

/
