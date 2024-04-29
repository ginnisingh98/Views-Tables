--------------------------------------------------------
--  DDL for Package PQP_PTY_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PTY_SHD" AUTHID CURRENT_USER as
/* $Header: pqptyrhi.pkh 120.0.12000000.1 2007/01/16 04:29:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (pension_type_id                 number(10)
  ,effective_start_date            date
  ,effective_end_date              date
  ,pension_type_name               varchar2(240)
  ,pension_category                varchar2(30)
  ,pension_provider_type           varchar2(30)
  ,salary_calculation_method       varchar2(30)
  ,threshold_conversion_rule       varchar2(30)
  ,contribution_conversion_rule    varchar2(30)
  ,er_annual_limit                 number(14,4)
  ,ee_annual_limit                 number(14,4)
  ,er_annual_salary_threshold      number(14,4)
  ,ee_annual_salary_threshold      number(14,4)
  ,object_version_number           number(9)
  ,business_group_id               number(15)
  ,legislation_code                varchar2(30)
  ,description                     varchar2(240)
  ,minimum_age                     number(9)         -- Increased length
  ,ee_contribution_percent         number(13,4)      -- Increased length
  ,maximum_age                     number(9)         -- Increased length
  ,er_contribution_percent         number(13,4)      -- Increased length
  ,ee_annual_contribution          number(14,4)
  ,er_annual_contribution          number(14,4)
  ,annual_premium_amount           number(14,4)
  ,ee_contribution_bal_type_id     number(9)
  ,er_contribution_bal_type_id     number(9)
  ,balance_init_element_type_id    number(9)
  ,ee_contribution_fixed_rate      number(14,4) -- added for UK
  ,er_contribution_fixed_rate      number(14,4) -- added for UK
  ,pty_attribute_category          varchar2(30)
  ,pty_attribute1                  varchar2(150)
  ,pty_attribute2                  varchar2(150)
  ,pty_attribute3                  varchar2(150)
  ,pty_attribute4                  varchar2(150)
  ,pty_attribute5                  varchar2(150)
  ,pty_attribute6                  varchar2(150)
  ,pty_attribute7                  varchar2(150)
  ,pty_attribute8                  varchar2(150)
  ,pty_attribute9                  varchar2(150)
  ,pty_attribute10                 varchar2(150)
  ,pty_attribute11                 varchar2(150)
  ,pty_attribute12                 varchar2(150)
  ,pty_attribute13                 varchar2(150)
  ,pty_attribute14                 varchar2(150)
  ,pty_attribute15                 varchar2(150)
  ,pty_attribute16                 varchar2(150)
  ,pty_attribute17                 varchar2(150)
  ,pty_attribute18                 varchar2(150)
  ,pty_attribute19                 varchar2(150)
  ,pty_attribute20                 varchar2(150)
  ,pty_information_category        varchar2(30)
  ,pty_information1                varchar2(150)
  ,pty_information2                varchar2(150)
  ,pty_information3                varchar2(150)
  ,pty_information4                varchar2(150)
  ,pty_information5                varchar2(150)
  ,pty_information6                varchar2(150)
  ,pty_information7                varchar2(150)
  ,pty_information8                varchar2(150)
  ,pty_information9                varchar2(150)
  ,pty_information10               varchar2(150)
  ,pty_information11               varchar2(150)
  ,pty_information12               varchar2(150)
  ,pty_information13               varchar2(150)
  ,pty_information14               varchar2(150)
  ,pty_information15               varchar2(150)
  ,pty_information16               varchar2(150)
  ,pty_information17               varchar2(150)
  ,pty_information18               varchar2(150)
  ,pty_information19               varchar2(150)
  ,pty_information20               varchar2(150)
  ,special_pension_type_code       varchar2(30)  -- added for NL Phase 2B
  ,pension_sub_category            varchar2(30)  -- added for NL Phase 2B
  ,pension_basis_calc_method       varchar2(30)  -- added for NL Phase 2B
  ,pension_salary_balance          number(9,0)   -- added for NL Phase 2B
  ,recurring_bonus_percent         number(7,4)   -- added for NL Phase 2B
  ,non_recurring_bonus_percent     number(7,4)   -- added for NL Phase 2B
  ,recurring_bonus_balance         number(9,0)   -- added for NL Phase 2B
  ,non_recurring_bonus_balance     number(9,0)   -- added for NL Phase 2B
  ,std_tax_reduction               varchar2(30)  -- added for NL Phase 2B
  ,spl_tax_reduction               varchar2(30)  -- added for NL Phase 2B
  ,sig_sal_spl_tax_reduction       varchar2(30)  -- added for NL Phase 2B
  ,sig_sal_non_tax_reduction       varchar2(30)  -- added for NL Phase 2B
  ,sig_sal_std_tax_reduction       varchar2(30)  -- added for NL Phase 2B
  ,sii_std_tax_reduction           varchar2(30)  -- added for NL Phase 2B
  ,sii_spl_tax_reduction           varchar2(30)  -- added for NL Phase 2B
  ,sii_non_tax_reduction           varchar2(30)  -- added for NL Phase 2B
  ,previous_year_bonus_included    varchar2(30)  -- added for NL Phase 2B
  ,recurring_bonus_period          varchar2(30)  -- added for NL Phase 2B
  ,non_recurring_bonus_period      varchar2(30)  -- added for NL Phase 2B
  ,ee_age_threshold                varchar2(30)  -- added for ABP TAR Fixes
  ,er_age_threshold                varchar2(30)  -- added for ABP TAR Fixes
  ,ee_age_contribution             varchar2(30)  -- added for ABP TAR Fixes
  ,er_age_contribution             varchar2(30)  -- added for ABP TAR Fixes
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'PQP_PENSION_TYPES_F';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Prerequisites:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which corresponds with a constraint error.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
--  {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date                   in date
  ,p_pension_type_id                  in number
  ,p_object_version_number            in number
  ) Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack update modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the update modes
--   available where TRUE indicates that the corresponding update mode
--   is available.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :pension_type_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack update mode of
--   UPDATE. To implement this you would have to set and return a Boolean
--   value of FALSE after the call to the dt_api.find_dt_upd_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_correction             out nocopy boolean
  ,p_update                 out nocopy boolean
  ,p_update_override        out nocopy boolean
  ,p_update_change_insert   out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack delete modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the delete modes
--   available where TRUE indicates that the corresponding delete mode is
--   available.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :pension_type_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack delete mode of
--   ZAP. To implement this you would have to set and return a Boolean value
--   of FALSE after the call to the dt_api.find_dt_del_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
  (p_effective_date        in date
  ,p_base_key_value        in number
  ,p_zap                   out nocopy boolean
  ,p_delete                out nocopy boolean
  ,p_future_change         out nocopy boolean
  ,p_delete_next_change    out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will update the specified datetrack row with the
--   specified new effective end date. The object version number is also
--   set to the next object version number. DateTrack modes which call
--   this procedure are: UPDATE, UPDATE_CHANGE_INSERT,
--   UPDATE_OVERRIDE, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE.
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_new_effective_end_date
--     Specifies the new effective end date which will be set for the
--     row as of the effective date.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :pension_type_id).
--
-- Post Success:
--   The specified row will be updated with the new effective end date and
--   object_version_number.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_new_effective_end_date in date
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_object_version_number  out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process for datetrack is complicated and comprises of the
--   following processing
--   The processing steps are as follows:
--   1) The row to be updated or deleted must be locked.
--      By locking this row, the g_old_rec record data type is populated.
--   2) If a comment exists the text is selected from hr_comments.
--   3) The datetrack mode is then validated to ensure the operation is
--      valid. If the mode is valid the validation start and end dates for
--      the mode will be derived and returned. Any required locking is
--      completed when the datetrack mode is validated.
--
-- Prerequisites:
--   When attempting to call the lck procedure the object version number,
--   primary key, effective date and datetrack mode must be specified.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update or delete mode.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_pension_type_id                  in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function.  Any possible
--   errors within this function will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
  (p_pension_type_id                in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_pension_type_name              in varchar2
  ,p_pension_category               in varchar2
  ,p_pension_provider_type          in varchar2
  ,p_salary_calculation_method      in varchar2
  ,p_threshold_conversion_rule      in varchar2
  ,p_contribution_conversion_rule   in varchar2
  ,p_er_annual_limit                in number
  ,p_ee_annual_limit                in number
  ,p_er_annual_salary_threshold     in number
  ,p_ee_annual_salary_threshold     in number
  ,p_object_version_number          in number
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_description                    in varchar2
  ,p_minimum_age                    in number
  ,p_ee_contribution_percent        in number
  ,p_maximum_age                    in number
  ,p_er_contribution_percent        in number
  ,p_ee_annual_contribution         in number
  ,p_er_annual_contribution         in number
  ,p_annual_premium_amount          in number
  ,p_ee_contribution_bal_type_id    in number
  ,p_er_contribution_bal_type_id    in number
  ,p_balance_init_element_type_id   in number
  ,p_ee_contribution_fixed_rate     in number  --added for UK
  ,p_er_contribution_fixed_rate     in number  --added for UK
  ,p_pty_attribute_category         in varchar2
  ,p_pty_attribute1                 in varchar2
  ,p_pty_attribute2                 in varchar2
  ,p_pty_attribute3                 in varchar2
  ,p_pty_attribute4                 in varchar2
  ,p_pty_attribute5                 in varchar2
  ,p_pty_attribute6                 in varchar2
  ,p_pty_attribute7                 in varchar2
  ,p_pty_attribute8                 in varchar2
  ,p_pty_attribute9                 in varchar2
  ,p_pty_attribute10                in varchar2
  ,p_pty_attribute11                in varchar2
  ,p_pty_attribute12                in varchar2
  ,p_pty_attribute13                in varchar2
  ,p_pty_attribute14                in varchar2
  ,p_pty_attribute15                in varchar2
  ,p_pty_attribute16                in varchar2
  ,p_pty_attribute17                in varchar2
  ,p_pty_attribute18                in varchar2
  ,p_pty_attribute19                in varchar2
  ,p_pty_attribute20                in varchar2
  ,p_pty_information_category       in varchar2
  ,p_pty_information1               in varchar2
  ,p_pty_information2               in varchar2
  ,p_pty_information3               in varchar2
  ,p_pty_information4               in varchar2
  ,p_pty_information5               in varchar2
  ,p_pty_information6               in varchar2
  ,p_pty_information7               in varchar2
  ,p_pty_information8               in varchar2
  ,p_pty_information9               in varchar2
  ,p_pty_information10              in varchar2
  ,p_pty_information11              in varchar2
  ,p_pty_information12              in varchar2
  ,p_pty_information13              in varchar2
  ,p_pty_information14              in varchar2
  ,p_pty_information15              in varchar2
  ,p_pty_information16              in varchar2
  ,p_pty_information17              in varchar2
  ,p_pty_information18              in varchar2
  ,p_pty_information19              in varchar2
  ,p_pty_information20              in varchar2
  ,p_special_pension_type_code      in varchar2    -- added for NL Phase 2B
  ,p_pension_sub_category           in varchar2    -- added for NL Phase 2B
  ,p_pension_basis_calc_method      in varchar2    -- added for NL Phase 2B
  ,p_pension_salary_balance         in number      -- added for NL Phase 2B
  ,p_recurring_bonus_percent        in number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent    in number      -- added for NL Phase 2B
  ,p_recurring_bonus_balance        in number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance    in number      -- added for NL Phase 2B
  ,p_std_tax_reduction              in varchar2    -- added for NL Phase 2B
  ,p_spl_tax_reduction              in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction      in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction      in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction      in varchar2    -- added for NL Phase 2B
  ,p_sii_std_tax_reduction          in varchar2    -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction          in varchar2    -- added for NL Phase 2B
  ,p_sii_non_tax_reduction          in varchar2    -- added for NL Phase 2B
  ,p_previous_year_bonus_included   in varchar2    -- added for NL Phase 2B
  ,p_recurring_bonus_period         in varchar2    -- added for NL Phase 2B
  ,p_non_recurring_bonus_period     in varchar2    -- added for NL Phase 2B
  ,p_ee_age_threshold               in varchar2    -- added for ABP TAR fixes
  ,p_er_age_threshold               in varchar2    -- added for ABP TAR fixes
  ,p_ee_age_contribution            in varchar2    -- added for ABP TAR fixes
  ,p_er_age_contribution            in varchar2    -- added for ABP TAR fixes
  )
  Return g_rec_type;
--
end pqp_pty_shd;

/
