--------------------------------------------------------
--  DDL for Package BEN_XER_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XER_UPD" AUTHID CURRENT_USER as
/* $Header: bexerrhi.pkh 120.0 2005/05/28 12:32:39 appldev noship $ */
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
  p_rec        in out nocopy ben_xer_shd.g_rec_type
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
  p_ext_data_elmt_in_rcd_id      in number,
  p_seq_num                      in number           default hr_api.g_number,
  p_strt_pos                     in number           default hr_api.g_number,
  p_dlmtr_val                    in varchar2         default hr_api.g_varchar2,
  p_rqd_flag                     in varchar2         default hr_api.g_varchar2,
  p_sprs_cd                      in varchar2         default hr_api.g_varchar2,
  p_any_or_all_cd                in varchar2         default hr_api.g_varchar2,
  p_ext_data_elmt_id             in number           default hr_api.g_number,
  p_ext_rcd_id                   in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_legislation_code             in varchar2         default hr_api.g_varchar2,
  p_last_update_date             in date             default hr_api.g_date,
  p_creation_date                in date             default hr_api.g_date,
  p_last_updated_by              in number           default hr_api.g_number,
  p_last_update_login            in number           default hr_api.g_number,
  p_created_by                   in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_hide_flag                    in varchar2         default hr_api.g_varchar2
  );
--
end ben_xer_upd;

 

/
