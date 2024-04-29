--------------------------------------------------------
--  DDL for Package PQP_DET_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_DET_INS" AUTHID CURRENT_USER as
/* $Header: pqdetrhi.pkh 120.0.12010000.1 2008/07/28 11:08:28 appldev ship $ */


-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}

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

-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.

-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.

-- Developer Implementation Notes:
--   None.

-- Access Status:
--   Internal Development Use Only.

-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date               in date,
  p_rec        in out nocopy pqp_det_shd.g_rec_type
  );

-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}

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

-- Prerequisites:

-- In Parameters:

-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (
  p_effective_date               in date,
  p_analyzed_data_details_id     out nocopy number,
  p_analyzed_data_id             in number,
  p_income_code                  in varchar2         default null,
  p_withholding_rate             in number           default null,
  p_income_code_sub_type         in varchar2         default null,
  p_exemption_code               in varchar2         default null,
  p_maximum_benefit_amount       in number           default null,
  p_retro_lose_ben_amt_flag      in varchar2         default null,
  p_date_benefit_ends            in date             default null,
  p_retro_lose_ben_date_flag     in varchar2         default null,
  p_nra_exempt_from_ss           in varchar2         default null,
  p_nra_exempt_from_medicare     in varchar2         default null,
  p_student_exempt_from_ss       in varchar2         default null,
  p_student_exempt_from_medi     in varchar2         default null,
  p_addl_withholding_flag        in varchar2         default null,
  p_constant_addl_tax            in number           default null,
  p_addl_withholding_amt         in number           default null,
  p_addl_wthldng_amt_period_type in varchar2         default null,
  p_personal_exemption           in number           default null,
  p_addl_exemption_allowed       in number           default null,
  p_treaty_ben_allowed_flag      in varchar2         default null,
  p_treaty_benefits_start_date   in date             default null,
  p_object_version_number        out nocopy number ,
  p_retro_loss_notification_sent in varchar2         default null,
  p_current_analysis             in varchar2         default null,
  p_forecast_income_code         in varchar2         default null
  );

end pqp_det_ins;

/
