--------------------------------------------------------
--  DDL for Package PQP_PTY_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PTY_UPD" AUTHID CURRENT_USER as
/* $Header: pqptyrhi.pkh 120.0.12000000.1 2007/01/16 04:29:04 appldev noship $ */
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
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pqp_pty_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd >------------------------------------|
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
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_type_name            in     varchar2  default hr_api.g_varchar2
  ,p_pension_category             in     varchar2  default hr_api.g_varchar2
  ,p_pension_provider_type        in     varchar2  default hr_api.g_varchar2
  ,p_salary_calculation_method    in     varchar2  default hr_api.g_varchar2
  ,p_threshold_conversion_rule    in     varchar2  default hr_api.g_varchar2
  ,p_contribution_conversion_rule in     varchar2  default hr_api.g_varchar2
  ,p_er_annual_limit              in     number    default hr_api.g_number
  ,p_ee_annual_limit              in     number    default hr_api.g_number
  ,p_er_annual_salary_threshold   in     number    default hr_api.g_number
  ,p_ee_annual_salary_threshold   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_minimum_age                  in     number    default hr_api.g_number
  ,p_ee_contribution_percent      in     number    default hr_api.g_number
  ,p_maximum_age                  in     number    default hr_api.g_number
  ,p_er_contribution_percent      in     number    default hr_api.g_number
  ,p_ee_annual_contribution       in     number    default hr_api.g_number
  ,p_er_annual_contribution       in     number    default hr_api.g_number
  ,p_annual_premium_amount        in     number    default hr_api.g_number
  ,p_ee_contribution_bal_type_id  in     number    default hr_api.g_number
  ,p_er_contribution_bal_type_id  in     number    default hr_api.g_number
  ,p_balance_init_element_type_id in     number    default hr_api.g_number
  ,p_ee_contribution_fixed_rate   in     number    default hr_api.g_number --added for UK
  ,p_er_contribution_fixed_rate   in     number    default hr_api.g_number --added for UK
  ,p_pty_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pty_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pty_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information20            in     varchar2  default hr_api.g_varchar2
  ,p_special_pension_type_code    in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number    default hr_api.g_number       -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number    default hr_api.g_number       -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number    default hr_api.g_number       -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number    default hr_api.g_number       -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number    default hr_api.g_number       -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2  default hr_api.g_varchar2     -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2  default hr_api.g_varchar2     -- added for ABP TAR Fixes
  ,p_er_age_threshold             in     varchar2  default hr_api.g_varchar2     -- added for ABP TAR Fixes
  ,p_ee_age_contribution          in     varchar2  default hr_api.g_varchar2     -- added for ABP TAR Fixes
  ,p_er_age_contribution          in     varchar2  default hr_api.g_varchar2     -- added for ABP TAR Fixes
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
end pqp_pty_upd;

/
