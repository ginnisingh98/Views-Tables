--------------------------------------------------------
--  DDL for Package BEN_DPNT_EDC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_EDC_UPD" AUTHID CURRENT_USER AS
/* $Header: beedvrhi.pkh 120.0.12010000.1 2010/04/09 06:34:15 pvelvano noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--
-- Post Success:
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode.
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
  p_rec			in out nocopy 	ben_dpnt_edc_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
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
   p_dpnt_eligy_crit_values_id         In  Number
  ,p_dpnt_cvg_eligy_prfl_id            In      Number default hr_api.g_number
  ,p_eligy_criteria_dpnt_id            In  Number       default hr_api.g_number
  ,p_effective_start_date         Out nocopy Date
  ,p_effective_end_date           Out nocopy Date
  ,p_ordr_num                     In  Number       default hr_api.g_number
  ,p_number_value1                In  Number       default hr_api.g_number
  ,p_number_value2                In  Number       default hr_api.g_number
  ,p_char_value1                  In  Varchar2     default hr_api.g_varchar2
  ,p_char_value2                  In  Varchar2     default hr_api.g_varchar2
  ,p_date_value1                  In  Date         default hr_api.g_date
  ,p_date_value2                  In  Date         default hr_api.g_date
  ,p_excld_flag                   In  Varchar2     default hr_api.g_varchar2
  ,p_business_group_id            In  Number       default hr_api.g_number
  ,p_edc_attribute_category       In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute1               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute2               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute3               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute4               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute5               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute6               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute7               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute8               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute9               In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute10              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute11              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute12              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute13              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute14              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute15              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute16              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute17              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute18              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute19              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute20              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute21              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute22              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute23              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute24              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute25              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute26              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute27              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute28              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute29              In  Varchar2     default hr_api.g_varchar2
  ,p_edc_attribute30              In  Varchar2     default hr_api.g_varchar2
  ,p_object_version_number        In Out nocopy Number
  ,p_effective_date               In  Date
  ,p_datetrack_mode               In  varchar2
  ,p_Char_value3                  In  Varchar2     default hr_api.g_varchar2
  ,p_Char_value4                  In  Varchar2     default hr_api.g_varchar2
  ,p_Number_value3                In  Number	   default hr_api.g_number
  ,p_Number_value4                In  Number	   default hr_api.g_number
  ,p_Date_value3                  In  Date	   default hr_api.g_date
  ,p_Date_value4                  In  Date	   default hr_api.g_date
  );
--
end ben_dpnt_edc_upd;

/
