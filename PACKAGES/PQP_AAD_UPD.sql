--------------------------------------------------------
--  DDL for Package PQP_AAD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_AAD_UPD" AUTHID CURRENT_USER as
/* $Header: pqaadrhi.pkh 120.0 2005/05/29 01:39:54 appldev noship $ */
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
  p_rec        in out nocopy pqp_aad_shd.g_rec_type
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
  p_analyzed_data_id             in number,
  p_assignment_id                in number           default hr_api.g_number,
  p_data_source                  in varchar2         default hr_api.g_varchar2,
  p_tax_year                     in number           default hr_api.g_number,
  p_current_residency_status     in varchar2         default hr_api.g_varchar2,
  p_nra_to_ra_date               in date             default hr_api.g_date,
  p_target_departure_date        in date             default hr_api.g_date,
  p_tax_residence_country_code   in varchar2         default hr_api.g_varchar2,
  p_treaty_info_update_date      in date             default hr_api.g_date,
  p_number_of_days_in_usa        in number           default hr_api.g_number,
  p_withldg_allow_eligible_flag  in varchar2         default hr_api.g_varchar2,
  p_ra_effective_date            in date             default hr_api.g_date,
  p_record_source                in varchar2         default hr_api.g_varchar2,
  p_visa_type                    in varchar2         default hr_api.g_varchar2,
  p_j_sub_type                   in varchar2         default hr_api.g_varchar2,
  p_primary_activity             in varchar2         default hr_api.g_varchar2,
  p_non_us_country_code          in varchar2         default hr_api.g_varchar2,
  p_citizenship_country_code     in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number
  ,p_date_8233_signed            in date             default hr_api.g_date
  ,p_date_w4_signed              in date             default hr_api.g_date
  );
--
end pqp_aad_upd;

 

/
