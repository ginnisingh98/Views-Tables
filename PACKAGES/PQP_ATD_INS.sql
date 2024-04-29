--------------------------------------------------------
--  DDL for Package PQP_ATD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ATD_INS" AUTHID CURRENT_USER as
/* $Header: pqatdrhi.pkh 120.0.12010000.1 2008/07/28 11:08:00 appldev ship $ */

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
  p_rec        in out nocopy pqp_atd_shd.g_rec_type
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
  p_alien_transaction_id         out nocopy number,
  p_person_id                    in  number          default null,
  p_data_source_type             in varchar2,
  p_tax_year                     in number           default null,
  p_income_code                  in varchar2,
  p_withholding_rate             in number           default null,
  p_income_code_sub_type         in varchar2         default null,
  p_exemption_code               in varchar2         default null,
  p_maximum_benefit_amount       in number           default null,
  p_retro_lose_ben_amt_flag      in varchar2         default null,
  p_date_benefit_ends            in date             default null,
  p_retro_lose_ben_date_flag     in varchar2         default null,
  p_current_residency_status     in varchar2         default null,
  p_nra_to_ra_date               in date             default null,
  p_target_departure_date        in date             default null,
  p_tax_residence_country_code   in varchar2         default null,
  p_treaty_info_update_date      in date             default null,
  p_nra_exempt_from_fica         in varchar2         default null,
  p_student_exempt_from_fica     in varchar2         default null,
  p_addl_withholding_flag        in varchar2         default null,
  p_addl_withholding_amt         in number           default null,
  p_addl_wthldng_amt_period_type in varchar2         default null,
  p_personal_exemption           in number           default null,
  p_addl_exemption_allowed       in number           default null,
  p_number_of_days_in_usa        in number           default null,
  p_wthldg_allow_eligible_flag   in varchar2         default null,
  p_treaty_ben_allowed_flag      in varchar2         default null,
  p_treaty_benefits_start_date   in date             default null,
  p_ra_effective_date            in date             default null,
  p_state_code                   in varchar2         default null,
  p_state_honors_treaty_flag     in varchar2         default null,
  p_ytd_payments                 in number           default null,
  p_ytd_w2_payments              in number           default null,
  p_ytd_w2_withholding           in number           default null,
  p_ytd_withholding_allowance    in number           default null,
  p_ytd_treaty_payments          in number           default null,
  p_ytd_treaty_withheld_amt      in number           default null,
  p_record_source                in varchar2         default null,
  p_visa_type                    in varchar2         default null,
  p_j_sub_type                   in varchar2         default null,
  p_primary_activity             in varchar2         default null,
  p_non_us_country_code          in varchar2         default null,
  p_citizenship_country_code     in varchar2         default null,
  p_constant_addl_tax            in number           default null,
  p_date_8233_signed             in date             default null,
  p_date_w4_signed               in date             default null,
  p_error_indicator              in varchar2         default null,
  p_prev_er_treaty_benefit_amt   in number           default null,
  p_error_text                   in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_current_analysis             in  varchar2        default null,
  p_forecast_income_code         in  varchar2        default null

  );
--
end pqp_atd_ins;

/
