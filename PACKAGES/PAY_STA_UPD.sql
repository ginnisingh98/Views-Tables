--------------------------------------------------------
--  DDL for Package PAY_STA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STA_UPD" AUTHID CURRENT_USER as
/* $Header: pystarhi.pkh 120.0.12000000.2 2007/05/01 22:41:10 ahanda noship $ */
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
  p_rec                 in out nocopy pay_sta_shd.g_rec_type,
  p_effective_date      in            date,
  p_datetrack_mode      in            varchar2
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
  p_emp_state_tax_rule_id        in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_additional_wa_amount         in number           default hr_api.g_number,
  p_filing_status_code           in varchar2         default hr_api.g_varchar2,
  p_remainder_percent            in number           default hr_api.g_number,
  p_secondary_wa                 in number           default hr_api.g_number,
  p_sit_additional_tax           in number           default hr_api.g_number,
  p_sit_override_amount          in number           default hr_api.g_number,
  p_sit_override_rate            in number           default hr_api.g_number,
  p_withholding_allowances       in number           default hr_api.g_number,
  p_excessive_wa_reject_date     in date             default hr_api.g_date,
  p_sdi_exempt                   in varchar2         default hr_api.g_varchar2,
  p_sit_exempt                   in varchar2         default hr_api.g_varchar2,
  p_sit_optional_calc_ind        in varchar2         default hr_api.g_varchar2,
  p_state_non_resident_cert      in varchar2         default hr_api.g_varchar2,
  p_sui_exempt                   in varchar2         default hr_api.g_varchar2,
  p_wc_exempt                    in varchar2         default hr_api.g_varchar2,
  p_wage_exempt                  in varchar2         default hr_api.g_varchar2,
  p_sui_wage_base_override_amoun in number           default hr_api.g_number,
  p_supp_tax_override_rate       in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_effective_date             in date,
  p_datetrack_mode             in varchar2,
  p_attribute_category          in varchar2         default hr_api.g_varchar2,
  p_attribute1                  in varchar2         default hr_api.g_varchar2,
  p_attribute2                  in varchar2         default hr_api.g_varchar2,
  p_attribute3                  in varchar2         default hr_api.g_varchar2,
  p_attribute4                  in varchar2         default hr_api.g_varchar2,
  p_attribute5                  in varchar2         default hr_api.g_varchar2,
  p_attribute6                  in varchar2         default hr_api.g_varchar2,
  p_attribute7                  in varchar2         default hr_api.g_varchar2,
  p_attribute8                  in varchar2         default hr_api.g_varchar2,
  p_attribute9                  in varchar2         default hr_api.g_varchar2,
  p_attribute10                 in varchar2         default hr_api.g_varchar2,
  p_attribute11                 in varchar2         default hr_api.g_varchar2,
  p_attribute12                 in varchar2         default hr_api.g_varchar2,
  p_attribute13                 in varchar2         default hr_api.g_varchar2,
  p_attribute14                 in varchar2         default hr_api.g_varchar2,
  p_attribute15                 in varchar2         default hr_api.g_varchar2,
  p_attribute16                 in varchar2         default hr_api.g_varchar2,
  p_attribute17                 in varchar2         default hr_api.g_varchar2,
  p_attribute18                 in varchar2         default hr_api.g_varchar2,
  p_attribute19                 in varchar2         default hr_api.g_varchar2,
  p_attribute20                 in varchar2         default hr_api.g_varchar2,
  p_attribute21                 in varchar2         default hr_api.g_varchar2,
  p_attribute22                 in varchar2         default hr_api.g_varchar2,
  p_attribute23                 in varchar2         default hr_api.g_varchar2,
  p_attribute24                 in varchar2         default hr_api.g_varchar2,
  p_attribute25                 in varchar2         default hr_api.g_varchar2,
  p_attribute26                 in varchar2         default hr_api.g_varchar2,
  p_attribute27                 in varchar2         default hr_api.g_varchar2,
  p_attribute28                 in varchar2         default hr_api.g_varchar2,
  p_attribute29                 in varchar2         default hr_api.g_varchar2,
  p_attribute30                 in varchar2         default hr_api.g_varchar2,
  p_sta_information_category    in varchar2         default hr_api.g_varchar2,
  p_sta_information1            in varchar2         default hr_api.g_varchar2,
  p_sta_information2            in varchar2         default hr_api.g_varchar2,
  p_sta_information3            in varchar2         default hr_api.g_varchar2,
  p_sta_information4            in varchar2         default hr_api.g_varchar2,
  p_sta_information5            in varchar2         default hr_api.g_varchar2,
  p_sta_information6            in varchar2         default hr_api.g_varchar2,
  p_sta_information7            in varchar2         default hr_api.g_varchar2,
  p_sta_information8            in varchar2         default hr_api.g_varchar2,
  p_sta_information9            in varchar2         default hr_api.g_varchar2,
  p_sta_information10           in varchar2         default hr_api.g_varchar2,
  p_sta_information11           in varchar2         default hr_api.g_varchar2,
  p_sta_information12           in varchar2         default hr_api.g_varchar2,
  p_sta_information13           in varchar2         default hr_api.g_varchar2,
  p_sta_information14           in varchar2         default hr_api.g_varchar2,
  p_sta_information15           in varchar2         default hr_api.g_varchar2,
  p_sta_information16           in varchar2         default hr_api.g_varchar2,
  p_sta_information17           in varchar2         default hr_api.g_varchar2,
  p_sta_information18           in varchar2         default hr_api.g_varchar2,
  p_sta_information19           in varchar2         default hr_api.g_varchar2,
  p_sta_information20           in varchar2         default hr_api.g_varchar2,
  p_sta_information21           in varchar2         default hr_api.g_varchar2,
  p_sta_information22           in varchar2         default hr_api.g_varchar2,
  p_sta_information23           in varchar2         default hr_api.g_varchar2,
  p_sta_information24           in varchar2         default hr_api.g_varchar2,
  p_sta_information25           in varchar2         default hr_api.g_varchar2,
  p_sta_information26           in varchar2         default hr_api.g_varchar2,
  p_sta_information27           in varchar2         default hr_api.g_varchar2,
  p_sta_information28           in varchar2         default hr_api.g_varchar2,
  p_sta_information29           in varchar2         default hr_api.g_varchar2,
  p_sta_information30           in varchar2         default hr_api.g_varchar2
  );
--
end pay_sta_upd;

 

/
