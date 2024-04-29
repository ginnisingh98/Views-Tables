--------------------------------------------------------
--  DDL for Package PQP_PTY_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PTY_INS" AUTHID CURRENT_USER as
/* $Header: pqptyrhi.pkh 120.0.12000000.1 2007/01/16 04:29:04 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_pension_type_id  in  number);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
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
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) We must lock parent rows (if any exist).
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  (p_effective_date in     date
  ,p_rec            in out nocopy pqp_pty_shd.g_rec_type
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
--   (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (p_effective_date                 in     date
  ,p_pension_type_name              in     varchar2
  ,p_pension_category               in     varchar2
  ,p_pension_provider_type          in     varchar2
  ,p_salary_calculation_method      in     varchar2
  ,p_threshold_conversion_rule      in     varchar2
  ,p_contribution_conversion_rule   in     varchar2
  ,p_er_annual_limit                in     number
  ,p_ee_annual_limit                in     number
  ,p_er_annual_salary_threshold     in     number
  ,p_ee_annual_salary_threshold     in     number
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_minimum_age                    in     number   default null
  ,p_ee_contribution_percent        in     number   default null
  ,p_maximum_age                    in     number   default null
  ,p_er_contribution_percent        in     number   default null
  ,p_ee_annual_contribution         in     number   default null
  ,p_er_annual_contribution         in     number   default null
  ,p_annual_premium_amount          in     number   default null
  ,p_ee_contribution_bal_type_id    in     number   default null
  ,p_er_contribution_bal_type_id    in     number   default null
  ,p_balance_init_element_type_id   in     number   default null
  ,p_ee_contribution_fixed_rate     in     number   default null --added for UK
  ,p_er_contribution_fixed_rate     in     number   default null --added for UK
  ,p_pty_attribute_category         in     varchar2 default null
  ,p_pty_attribute1                 in     varchar2 default null
  ,p_pty_attribute2                 in     varchar2 default null
  ,p_pty_attribute3                 in     varchar2 default null
  ,p_pty_attribute4                 in     varchar2 default null
  ,p_pty_attribute5                 in     varchar2 default null
  ,p_pty_attribute6                 in     varchar2 default null
  ,p_pty_attribute7                 in     varchar2 default null
  ,p_pty_attribute8                 in     varchar2 default null
  ,p_pty_attribute9                 in     varchar2 default null
  ,p_pty_attribute10                in     varchar2 default null
  ,p_pty_attribute11                in     varchar2 default null
  ,p_pty_attribute12                in     varchar2 default null
  ,p_pty_attribute13                in     varchar2 default null
  ,p_pty_attribute14                in     varchar2 default null
  ,p_pty_attribute15                in     varchar2 default null
  ,p_pty_attribute16                in     varchar2 default null
  ,p_pty_attribute17                in     varchar2 default null
  ,p_pty_attribute18                in     varchar2 default null
  ,p_pty_attribute19                in     varchar2 default null
  ,p_pty_attribute20                in     varchar2 default null
  ,p_pty_information_category       in     varchar2 default null
  ,p_pty_information1               in     varchar2 default null
  ,p_pty_information2               in     varchar2 default null
  ,p_pty_information3               in     varchar2 default null
  ,p_pty_information4               in     varchar2 default null
  ,p_pty_information5               in     varchar2 default null
  ,p_pty_information6               in     varchar2 default null
  ,p_pty_information7               in     varchar2 default null
  ,p_pty_information8               in     varchar2 default null
  ,p_pty_information9               in     varchar2 default null
  ,p_pty_information10              in     varchar2 default null
  ,p_pty_information11              in     varchar2 default null
  ,p_pty_information12              in     varchar2 default null
  ,p_pty_information13              in     varchar2 default null
  ,p_pty_information14              in     varchar2 default null
  ,p_pty_information15              in     varchar2 default null
  ,p_pty_information16              in     varchar2 default null
  ,p_pty_information17              in     varchar2 default null
  ,p_pty_information18              in     varchar2 default null
  ,p_pty_information19              in     varchar2 default null
  ,p_pty_information20              in     varchar2 default null
  ,p_special_pension_type_code      in     varchar2 default null    -- added for NL Phase 2B
  ,p_pension_sub_category           in     varchar2 default null    -- added for NL Phase 2B
  ,p_pension_basis_calc_method      in     varchar2 default null    -- added for NL Phase 2B
  ,p_pension_salary_balance         in     number   default null    -- added for NL Phase 2B
  ,p_recurring_bonus_percent        in     number   default null    -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent    in     number   default null    -- added for NL Phase 2B
  ,p_recurring_bonus_balance        in     number   default null    -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance    in     number   default null    -- added for NL Phase 2B
  ,p_std_tax_reduction              in     varchar2 default null    -- added for NL Phase 2B
  ,p_spl_tax_reduction              in     varchar2 default null    -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction      in     varchar2 default null    -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction      in     varchar2 default null    -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction      in     varchar2 default null    -- added for NL Phase 2B
  ,p_sii_std_tax_reduction          in     varchar2 default null    -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction          in     varchar2 default null    -- added for NL Phase 2B
  ,p_sii_non_tax_reduction          in     varchar2 default null    -- added for NL Phase 2B
  ,p_previous_year_bonus_included   in     varchar2 default null    -- added for NL Phase 2B
  ,p_recurring_bonus_period         in     varchar2 default null    -- added for NL Phase 2B
  ,p_non_recurring_bonus_period     in     varchar2 default null    -- added for NL Phase 2B
  ,p_ee_age_threshold               in     varchar2 default null    -- added for ABP TAR Fixes
  ,p_er_age_threshold               in     varchar2 default null    -- added for ABP TAR Fixes
  ,p_ee_age_contribution            in     varchar2 default null    -- added for ABP TAR Fixes
  ,p_er_age_contribution            in     varchar2 default null    -- added for ABP TAR Fixes
  ,p_pension_type_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  );
--
end pqp_pty_ins;

/
