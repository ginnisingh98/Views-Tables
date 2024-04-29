--------------------------------------------------------
--  DDL for Package PQP_DET_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_DET_UPD" AUTHID CURRENT_USER as
/* $Header: pqdetrhi.pkh 120.0.12010000.1 2008/07/28 11:08:28 appldev ship $ */

-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}

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

-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:

-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.

-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.

-- Developer Implementation Notes:
--   None.

-- Access Status:
--   Internal Development Use Only.

-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date               in date,
  p_rec        in out nocopy pqp_det_shd.g_rec_type
  );

-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}

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

-- Prerequisites:

-- In Parameters:

-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.

-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.

-- Developer Implementation Notes:
--   None.

-- Access Status:
--   Internal Development Use Only.

-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date               in date,
  p_analyzed_data_details_id     in number,
  p_analyzed_data_id             in number           default hr_api.g_number,
  p_income_code                  in varchar2         default hr_api.g_varchar2,
  p_withholding_rate             in number           default hr_api.g_number,
  p_income_code_sub_type         in varchar2         default hr_api.g_varchar2,
  p_exemption_code               in varchar2         default hr_api.g_varchar2,
  p_maximum_benefit_amount       in number           default hr_api.g_number,
  p_retro_lose_ben_amt_flag      in varchar2         default hr_api.g_varchar2,
  p_date_benefit_ends            in date             default hr_api.g_date,
  p_retro_lose_ben_date_flag     in varchar2         default hr_api.g_varchar2,
  p_nra_exempt_from_ss           in varchar2         default hr_api.g_varchar2,
  p_nra_exempt_from_medicare     in varchar2         default hr_api.g_varchar2,
  p_student_exempt_from_ss     in varchar2         default hr_api.g_varchar2,
  p_student_exempt_from_medi     in varchar2         default hr_api.g_varchar2,
  p_addl_withholding_flag        in varchar2         default hr_api.g_varchar2,
  p_constant_addl_tax            in number           default hr_api.g_number,
  p_addl_withholding_amt         in number           default hr_api.g_number,
  p_addl_wthldng_amt_period_type in varchar2         default hr_api.g_varchar2,
  p_personal_exemption           in number           default hr_api.g_number,
  p_addl_exemption_allowed       in number           default hr_api.g_number,
  p_treaty_ben_allowed_flag      in varchar2         default hr_api.g_varchar2,
  p_treaty_benefits_start_date   in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_retro_loss_notification_sent in varchar2         default hr_api.g_varchar2,
  p_current_analysis             in varchar2         default hr_api.g_varchar2,
  p_forecast_income_code         in varchar2         default hr_api.g_varchar2
  );

end pqp_det_upd;

/