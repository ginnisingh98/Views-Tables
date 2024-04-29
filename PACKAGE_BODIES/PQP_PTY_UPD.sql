--------------------------------------------------------
--  DDL for Package Body PQP_PTY_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PTY_UPD" as
/* $Header: pqptyrhi.pkb 120.0.12000000.1 2007/01/16 04:29:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pty_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of
--   this procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
  (p_rec                   in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = hr_api.g_correction) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name => 'pqp_pension_types_f'
        ,p_base_key_column => 'pension_type_id'
        ,p_base_key_value  => p_rec.pension_type_id
        );
    --
    --
    --
    -- Update the pqp_pension_types_f Row
    --
    update  pqp_pension_types_f
    set
     pension_type_id                      = p_rec.pension_type_id
    ,pension_type_name                    = p_rec.pension_type_name
    ,pension_category                     = p_rec.pension_category
    ,pension_provider_type                = p_rec.pension_provider_type
    ,salary_calculation_method            = p_rec.salary_calculation_method
    ,threshold_conversion_rule            = p_rec.threshold_conversion_rule
    ,contribution_conversion_rule         = p_rec.contribution_conversion_rule
    ,er_annual_limit                      = p_rec.er_annual_limit
    ,ee_annual_limit                      = p_rec.ee_annual_limit
    ,er_annual_salary_threshold           = p_rec.er_annual_salary_threshold
    ,ee_annual_salary_threshold           = p_rec.ee_annual_salary_threshold
    ,object_version_number                = p_rec.object_version_number
    ,business_group_id                    = p_rec.business_group_id
    ,legislation_code                     = p_rec.legislation_code
    ,description                          = p_rec.description
    ,minimum_age                          = p_rec.minimum_age
    ,ee_contribution_percent              = p_rec.ee_contribution_percent
    ,maximum_age                          = p_rec.maximum_age
    ,er_contribution_percent              = p_rec.er_contribution_percent
    ,ee_annual_contribution               = p_rec.ee_annual_contribution
    ,er_annual_contribution               = p_rec.er_annual_contribution
    ,annual_premium_amount                = p_rec.annual_premium_amount
    ,ee_contribution_bal_type_id          = p_rec.ee_contribution_bal_type_id
    ,er_contribution_bal_type_id          = p_rec.er_contribution_bal_type_id
    ,balance_init_element_type_id         = p_rec.balance_init_element_type_id
    ,ee_contribution_fixed_rate           = p_rec.ee_contribution_fixed_rate    -- added for UK
    ,er_contribution_fixed_rate           = p_rec.er_contribution_fixed_rate    -- added for UK
    ,pty_attribute_category               = p_rec.pty_attribute_category
    ,pty_attribute1                       = p_rec.pty_attribute1
    ,pty_attribute2                       = p_rec.pty_attribute2
    ,pty_attribute3                       = p_rec.pty_attribute3
    ,pty_attribute4                       = p_rec.pty_attribute4
    ,pty_attribute5                       = p_rec.pty_attribute5
    ,pty_attribute6                       = p_rec.pty_attribute6
    ,pty_attribute7                       = p_rec.pty_attribute7
    ,pty_attribute8                       = p_rec.pty_attribute8
    ,pty_attribute9                       = p_rec.pty_attribute9
    ,pty_attribute10                      = p_rec.pty_attribute10
    ,pty_attribute11                      = p_rec.pty_attribute11
    ,pty_attribute12                      = p_rec.pty_attribute12
    ,pty_attribute13                      = p_rec.pty_attribute13
    ,pty_attribute14                      = p_rec.pty_attribute14
    ,pty_attribute15                      = p_rec.pty_attribute15
    ,pty_attribute16                      = p_rec.pty_attribute16
    ,pty_attribute17                      = p_rec.pty_attribute17
    ,pty_attribute18                      = p_rec.pty_attribute18
    ,pty_attribute19                      = p_rec.pty_attribute19
    ,pty_attribute20                      = p_rec.pty_attribute20
    ,pty_information_category             = p_rec.pty_information_category
    ,pty_information1                     = p_rec.pty_information1
    ,pty_information2                     = p_rec.pty_information2
    ,pty_information3                     = p_rec.pty_information3
    ,pty_information4                     = p_rec.pty_information4
    ,pty_information5                     = p_rec.pty_information5
    ,pty_information6                     = p_rec.pty_information6
    ,pty_information7                     = p_rec.pty_information7
    ,pty_information8                     = p_rec.pty_information8
    ,pty_information9                     = p_rec.pty_information9
    ,pty_information10                    = p_rec.pty_information10
    ,pty_information11                    = p_rec.pty_information11
    ,pty_information12                    = p_rec.pty_information12
    ,pty_information13                    = p_rec.pty_information13
    ,pty_information14                    = p_rec.pty_information14
    ,pty_information15                    = p_rec.pty_information15
    ,pty_information16                    = p_rec.pty_information16
    ,pty_information17                    = p_rec.pty_information17
    ,pty_information18                    = p_rec.pty_information18
    ,pty_information19                    = p_rec.pty_information19
    ,pty_information20                    = p_rec.pty_information20
    ,special_pension_type_code            = p_rec.special_pension_type_code       -- added for NL Phase 2B
    ,pension_sub_category         	  = p_rec.pension_sub_category        	  -- added for NL Phase 2B
    ,pension_basis_calc_method    	  = p_rec.pension_basis_calc_method   	  -- added for NL Phase 2B
    ,pension_salary_balance       	  = p_rec.pension_salary_balance      	  -- added for NL Phase 2B
    ,recurring_bonus_percent      	  = p_rec.recurring_bonus_percent     	  -- added for NL Phase 2B
    ,non_recurring_bonus_percent  	  = p_rec.non_recurring_bonus_percent 	  -- added for NL Phase 2B
    ,recurring_bonus_balance      	  = p_rec.recurring_bonus_balance     	  -- added for NL Phase 2B
    ,non_recurring_bonus_balance  	  = p_rec.non_recurring_bonus_balance 	  -- added for NL Phase 2B
    ,std_tax_reduction            	  = p_rec.std_tax_reduction           	  -- added for NL Phase 2B
    ,spl_tax_reduction            	  = p_rec.spl_tax_reduction           	  -- added for NL Phase 2B
    ,sig_sal_spl_tax_reduction    	  = p_rec.sig_sal_spl_tax_reduction   	  -- added for NL Phase 2B
    ,sig_sal_non_tax_reduction    	  = p_rec.sig_sal_non_tax_reduction   	  -- added for NL Phase 2B
    ,sig_sal_std_tax_reduction    	  = p_rec.sig_sal_std_tax_reduction   	  -- added for NL Phase 2B
    ,sii_std_tax_reduction        	  = p_rec.sii_std_tax_reduction       	  -- added for NL Phase 2B
    ,sii_spl_tax_reduction        	  = p_rec.sii_spl_tax_reduction       	  -- added for NL Phase 2B
    ,sii_non_tax_reduction        	  = p_rec.sii_non_tax_reduction       	  -- added for NL Phase 2B
    ,previous_year_bonus_included 	  = p_rec.previous_year_bonus_included	  -- added for NL Phase 2B
    ,recurring_bonus_period      	  = p_rec.recurring_bonus_period	  -- added for NL Phase 2B
    ,non_recurring_bonus_period 	  = p_rec.non_recurring_bonus_period	  -- added for NL Phase 2B
    ,ee_age_threshold                     = p_rec.ee_age_threshold                -- added for ABP TAR fixes
    ,er_age_threshold                     = p_rec.er_age_threshold                -- added for ABP TAR fixes
    ,ee_age_contribution                  = p_rec.ee_age_contribution             -- added for ABP TAR fixes
    ,er_age_contribution                  = p_rec.er_age_contribution             -- added for ABP TAR fixes
    where   pension_type_id = p_rec.pension_type_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    --
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqp_pty_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqp_pty_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec                      in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_pty_upd.dt_update_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--      the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details.
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
  (p_rec                     in out  nocopy   pqp_pty_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc                 varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --
    pqp_pty_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.pension_type_id
      ,p_new_effective_end_date => (p_validation_start_date - 1)
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    If (p_datetrack_mode = hr_api.g_update_override) then
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      pqp_pty_del.delete_dml
        (p_rec                   => p_rec
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_mode
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        );
    End If;
    --
    -- We must now insert the updated row
    --
    pqp_pty_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date         => p_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      );
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec                   in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_update >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                   in pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_pty_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_pension_type_id
      => p_rec.pension_type_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_pension_type_name
      => p_rec.pension_type_name
      ,p_pension_category
      => p_rec.pension_category
      ,p_pension_provider_type
      => p_rec.pension_provider_type
      ,p_salary_calculation_method
      => p_rec.salary_calculation_method
      ,p_threshold_conversion_rule
      => p_rec.threshold_conversion_rule
      ,p_contribution_conversion_rule
      => p_rec.contribution_conversion_rule
      ,p_er_annual_limit
      => p_rec.er_annual_limit
      ,p_ee_annual_limit
      => p_rec.ee_annual_limit
      ,p_er_annual_salary_threshold
      => p_rec.er_annual_salary_threshold
      ,p_ee_annual_salary_threshold
      => p_rec.ee_annual_salary_threshold
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_description
      => p_rec.description
      ,p_minimum_age
      => p_rec.minimum_age
      ,p_ee_contribution_percent
      => p_rec.ee_contribution_percent
      ,p_maximum_age
      => p_rec.maximum_age
      ,p_er_contribution_percent
      => p_rec.er_contribution_percent
      ,p_ee_annual_contribution
      => p_rec.ee_annual_contribution
      ,p_er_annual_contribution
      => p_rec.er_annual_contribution
      ,p_annual_premium_amount
      => p_rec.annual_premium_amount
      ,p_ee_contribution_bal_type_id
      => p_rec.ee_contribution_bal_type_id
      ,p_er_contribution_bal_type_id
      => p_rec.er_contribution_bal_type_id
      ,p_balance_init_element_type_id
      => p_rec.balance_init_element_type_id
      ,p_ee_contribution_fixed_rate  =>  p_rec.ee_contribution_fixed_rate    --added for UK
      ,p_er_contribution_fixed_rate  =>  p_rec.er_contribution_fixed_rate    --added for UK
      ,p_pty_attribute_category
      => p_rec.pty_attribute_category
      ,p_pty_attribute1
      => p_rec.pty_attribute1
      ,p_pty_attribute2
      => p_rec.pty_attribute2
      ,p_pty_attribute3
      => p_rec.pty_attribute3
      ,p_pty_attribute4
      => p_rec.pty_attribute4
      ,p_pty_attribute5
      => p_rec.pty_attribute5
      ,p_pty_attribute6
      => p_rec.pty_attribute6
      ,p_pty_attribute7
      => p_rec.pty_attribute7
      ,p_pty_attribute8
      => p_rec.pty_attribute8
      ,p_pty_attribute9
      => p_rec.pty_attribute9
      ,p_pty_attribute10
      => p_rec.pty_attribute10
      ,p_pty_attribute11
      => p_rec.pty_attribute11
      ,p_pty_attribute12
      => p_rec.pty_attribute12
      ,p_pty_attribute13
      => p_rec.pty_attribute13
      ,p_pty_attribute14
      => p_rec.pty_attribute14
      ,p_pty_attribute15
      => p_rec.pty_attribute15
      ,p_pty_attribute16
      => p_rec.pty_attribute16
      ,p_pty_attribute17
      => p_rec.pty_attribute17
      ,p_pty_attribute18
      => p_rec.pty_attribute18
      ,p_pty_attribute19
      => p_rec.pty_attribute19
      ,p_pty_attribute20
      => p_rec.pty_attribute20
      ,p_pty_information_category
      => p_rec.pty_information_category
      ,p_pty_information1
      => p_rec.pty_information1
      ,p_pty_information2
      => p_rec.pty_information2
      ,p_pty_information3
      => p_rec.pty_information3
      ,p_pty_information4
      => p_rec.pty_information4
      ,p_pty_information5
      => p_rec.pty_information5
      ,p_pty_information6
      => p_rec.pty_information6
      ,p_pty_information7
      => p_rec.pty_information7
      ,p_pty_information8
      => p_rec.pty_information8
      ,p_pty_information9
      => p_rec.pty_information9
      ,p_pty_information10
      => p_rec.pty_information10
      ,p_pty_information11
      => p_rec.pty_information11
      ,p_pty_information12
      => p_rec.pty_information12
      ,p_pty_information13
      => p_rec.pty_information13
      ,p_pty_information14
      => p_rec.pty_information14
      ,p_pty_information15
      => p_rec.pty_information15
      ,p_pty_information16
      => p_rec.pty_information16
      ,p_pty_information17
      => p_rec.pty_information17
      ,p_pty_information18
      => p_rec.pty_information18
      ,p_pty_information19
      => p_rec.pty_information19
      ,p_pty_information20
      => p_rec.pty_information20
      ,p_special_pension_type_code
      => p_rec.special_pension_type_code
      ,p_pension_sub_category
      => p_rec.pension_sub_category
      ,p_pension_basis_calc_method
      => p_rec.pension_basis_calc_method
      ,p_pension_salary_balance
      => p_rec.pension_salary_balance
      ,p_recurring_bonus_percent
      => p_rec.recurring_bonus_percent
      ,p_non_recurring_bonus_percent
      => p_rec.non_recurring_bonus_percent
      ,p_recurring_bonus_balance
      => p_rec.recurring_bonus_balance
      ,p_non_recurring_bonus_balance
      => p_rec.non_recurring_bonus_balance
      ,p_std_tax_reduction
      => p_rec.std_tax_reduction
      ,p_spl_tax_reduction
      => p_rec.spl_tax_reduction
      ,p_sig_sal_spl_tax_reduction
      => p_rec.sig_sal_spl_tax_reduction
      ,p_sig_sal_non_tax_reduction
      => p_rec.sig_sal_non_tax_reduction
      ,p_sig_sal_std_tax_reduction
      => p_rec.sig_sal_std_tax_reduction
      ,p_sii_std_tax_reduction
      => p_rec.sii_std_tax_reduction
      ,p_sii_spl_tax_reduction
      => p_rec.sii_spl_tax_reduction
      ,p_sii_non_tax_reduction
      => p_rec.sii_non_tax_reduction
      ,p_previous_year_bonus_included
      => p_rec.previous_year_bonus_included
      ,p_recurring_bonus_period
      => p_rec.recurring_bonus_period
      ,p_non_recurring_bonus_period
      => p_rec.non_recurring_bonus_period
      ,p_ee_age_threshold
      => p_rec.ee_age_threshold
      ,p_er_age_threshold
      => p_rec.er_age_threshold
      ,p_ee_age_contribution
      => p_rec.ee_age_contribution
      ,p_er_age_contribution
      => p_rec.er_age_contribution
      ,p_effective_start_date_o
      => pqp_pty_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pqp_pty_shd.g_old_rec.effective_end_date
      ,p_pension_type_name_o
      => pqp_pty_shd.g_old_rec.pension_type_name
      ,p_pension_category_o
      => pqp_pty_shd.g_old_rec.pension_category
      ,p_pension_provider_type_o
      => pqp_pty_shd.g_old_rec.pension_provider_type
      ,p_salary_calculation_method_o
      => pqp_pty_shd.g_old_rec.salary_calculation_method
      ,p_threshold_conversion_rule_o
      => pqp_pty_shd.g_old_rec.threshold_conversion_rule
      ,p_contribution_conversion_ru_o
      => pqp_pty_shd.g_old_rec.contribution_conversion_rule
      ,p_er_annual_limit_o
      => pqp_pty_shd.g_old_rec.er_annual_limit
      ,p_ee_annual_limit_o
      => pqp_pty_shd.g_old_rec.ee_annual_limit
      ,p_er_annual_salary_threshold_o
      => pqp_pty_shd.g_old_rec.er_annual_salary_threshold
      ,p_ee_annual_salary_threshold_o
      => pqp_pty_shd.g_old_rec.ee_annual_salary_threshold
      ,p_object_version_number_o
      => pqp_pty_shd.g_old_rec.object_version_number
      ,p_business_group_id_o
      => pqp_pty_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pqp_pty_shd.g_old_rec.legislation_code
      ,p_description_o
      => pqp_pty_shd.g_old_rec.description
      ,p_minimum_age_o
      => pqp_pty_shd.g_old_rec.minimum_age
      ,p_ee_contribution_percent_o
      => pqp_pty_shd.g_old_rec.ee_contribution_percent
      ,p_maximum_age_o
      => pqp_pty_shd.g_old_rec.maximum_age
      ,p_er_contribution_percent_o
      => pqp_pty_shd.g_old_rec.er_contribution_percent
      ,p_ee_annual_contribution_o
      => pqp_pty_shd.g_old_rec.ee_annual_contribution
      ,p_er_annual_contribution_o
      => pqp_pty_shd.g_old_rec.er_annual_contribution
      ,p_annual_premium_amount_o
      => pqp_pty_shd.g_old_rec.annual_premium_amount
      ,p_ee_contribution_bal_type_i_o
      => pqp_pty_shd.g_old_rec.ee_contribution_bal_type_id
      ,p_er_contribution_bal_type_i_o
      => pqp_pty_shd.g_old_rec.er_contribution_bal_type_id
      ,p_balance_init_element_type__o
      => pqp_pty_shd.g_old_rec.balance_init_element_type_id
     ,p_ee_contribution_fixed_rate_o  => pqp_pty_shd.g_old_rec.ee_contribution_fixed_rate  --added for UK
     ,p_er_contribution_fixed_rate_o  => pqp_pty_shd.g_old_rec.ee_contribution_fixed_rate  --added for UK
      ,p_pty_attribute_category_o
      => pqp_pty_shd.g_old_rec.pty_attribute_category
      ,p_pty_attribute1_o
      => pqp_pty_shd.g_old_rec.pty_attribute1
      ,p_pty_attribute2_o
      => pqp_pty_shd.g_old_rec.pty_attribute2
      ,p_pty_attribute3_o
      => pqp_pty_shd.g_old_rec.pty_attribute3
      ,p_pty_attribute4_o
      => pqp_pty_shd.g_old_rec.pty_attribute4
      ,p_pty_attribute5_o
      => pqp_pty_shd.g_old_rec.pty_attribute5
      ,p_pty_attribute6_o
      => pqp_pty_shd.g_old_rec.pty_attribute6
      ,p_pty_attribute7_o
      => pqp_pty_shd.g_old_rec.pty_attribute7
      ,p_pty_attribute8_o
      => pqp_pty_shd.g_old_rec.pty_attribute8
      ,p_pty_attribute9_o
      => pqp_pty_shd.g_old_rec.pty_attribute9
      ,p_pty_attribute10_o
      => pqp_pty_shd.g_old_rec.pty_attribute10
      ,p_pty_attribute11_o
      => pqp_pty_shd.g_old_rec.pty_attribute11
      ,p_pty_attribute12_o
      => pqp_pty_shd.g_old_rec.pty_attribute12
      ,p_pty_attribute13_o
      => pqp_pty_shd.g_old_rec.pty_attribute13
      ,p_pty_attribute14_o
      => pqp_pty_shd.g_old_rec.pty_attribute14
      ,p_pty_attribute15_o
      => pqp_pty_shd.g_old_rec.pty_attribute15
      ,p_pty_attribute16_o
      => pqp_pty_shd.g_old_rec.pty_attribute16
      ,p_pty_attribute17_o
      => pqp_pty_shd.g_old_rec.pty_attribute17
      ,p_pty_attribute18_o
      => pqp_pty_shd.g_old_rec.pty_attribute18
      ,p_pty_attribute19_o
      => pqp_pty_shd.g_old_rec.pty_attribute19
      ,p_pty_attribute20_o
      => pqp_pty_shd.g_old_rec.pty_attribute20
      ,p_pty_information_category_o
      => pqp_pty_shd.g_old_rec.pty_information_category
      ,p_pty_information1_o
      => pqp_pty_shd.g_old_rec.pty_information1
      ,p_pty_information2_o
      => pqp_pty_shd.g_old_rec.pty_information2
      ,p_pty_information3_o
      => pqp_pty_shd.g_old_rec.pty_information3
      ,p_pty_information4_o
      => pqp_pty_shd.g_old_rec.pty_information4
      ,p_pty_information5_o
      => pqp_pty_shd.g_old_rec.pty_information5
      ,p_pty_information6_o
      => pqp_pty_shd.g_old_rec.pty_information6
      ,p_pty_information7_o
      => pqp_pty_shd.g_old_rec.pty_information7
      ,p_pty_information8_o
      => pqp_pty_shd.g_old_rec.pty_information8
      ,p_pty_information9_o
      => pqp_pty_shd.g_old_rec.pty_information9
      ,p_pty_information10_o
      => pqp_pty_shd.g_old_rec.pty_information10
      ,p_pty_information11_o
      => pqp_pty_shd.g_old_rec.pty_information11
      ,p_pty_information12_o
      => pqp_pty_shd.g_old_rec.pty_information12
      ,p_pty_information13_o
      => pqp_pty_shd.g_old_rec.pty_information13
      ,p_pty_information14_o
      => pqp_pty_shd.g_old_rec.pty_information14
      ,p_pty_information15_o
      => pqp_pty_shd.g_old_rec.pty_information15
      ,p_pty_information16_o
      => pqp_pty_shd.g_old_rec.pty_information16
      ,p_pty_information17_o
      => pqp_pty_shd.g_old_rec.pty_information17
      ,p_pty_information18_o
      => pqp_pty_shd.g_old_rec.pty_information18
      ,p_pty_information19_o
      => pqp_pty_shd.g_old_rec.pty_information19
      ,p_pty_information20_o
      => pqp_pty_shd.g_old_rec.pty_information20
      ,p_special_pension_type_code_o
      => pqp_pty_shd.g_old_rec.special_pension_type_code
      ,p_pension_sub_category_o
      => pqp_pty_shd.g_old_rec.pension_sub_category
      ,p_pension_basis_calc_method_o
      => pqp_pty_shd.g_old_rec.pension_basis_calc_method
      ,p_pension_salary_balance_o
      => pqp_pty_shd.g_old_rec.pension_salary_balance
      ,p_recurring_bonus_percent_o
      => pqp_pty_shd.g_old_rec.recurring_bonus_percent
      ,p_non_recur_bonus_percent_o
      => pqp_pty_shd.g_old_rec.non_recurring_bonus_percent
      ,p_recurring_bonus_balance_o
      => pqp_pty_shd.g_old_rec.recurring_bonus_balance
      ,p_non_recur_bonus_balance_o
      => pqp_pty_shd.g_old_rec.non_recurring_bonus_balance
      ,p_std_tax_reduction_o
      => pqp_pty_shd.g_old_rec.std_tax_reduction
      ,p_spl_tax_reduction_o
      => pqp_pty_shd.g_old_rec.spl_tax_reduction
      ,p_sig_sal_spl_tax_reduction_o
      => pqp_pty_shd.g_old_rec.sig_sal_spl_tax_reduction
      ,p_sig_sal_non_tax_reduction_o
      => pqp_pty_shd.g_old_rec.sig_sal_non_tax_reduction
      ,p_sig_sal_std_tax_reduction_o
      => pqp_pty_shd.g_old_rec.sig_sal_std_tax_reduction
      ,p_sii_std_tax_reduction_o
      => pqp_pty_shd.g_old_rec.sii_std_tax_reduction
      ,p_sii_spl_tax_reduction_o
      => pqp_pty_shd.g_old_rec.sii_spl_tax_reduction
      ,p_sii_non_tax_reduction_o
      => pqp_pty_shd.g_old_rec.sii_non_tax_reduction
      ,p_prev_year_bonus_include_o
      => pqp_pty_shd.g_old_rec.previous_year_bonus_included
      ,p_recurring_bonus_period_o
      => pqp_pty_shd.g_old_rec.recurring_bonus_period
      ,p_non_recurring_bonus_period_o
      => pqp_pty_shd.g_old_rec.non_recurring_bonus_period
      ,p_ee_age_threshold_o
      => pqp_pty_shd.g_old_rec.ee_age_threshold
      ,p_er_age_threshold_o
      => pqp_pty_shd.g_old_rec.er_age_threshold
      ,p_ee_age_contribution_o
      => pqp_pty_shd.g_old_rec.ee_age_contribution
      ,p_er_age_contribution_o
      => pqp_pty_shd.g_old_rec.er_age_contribution
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_PENSION_TYPES_F'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
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
Procedure convert_defs
  (p_rec in out nocopy pqp_pty_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.pension_type_name = hr_api.g_varchar2) then
    p_rec.pension_type_name :=
    pqp_pty_shd.g_old_rec.pension_type_name;
  End If;
  If (p_rec.pension_category = hr_api.g_varchar2) then
    p_rec.pension_category :=
    pqp_pty_shd.g_old_rec.pension_category;
  End If;
  If (p_rec.pension_provider_type = hr_api.g_varchar2) then
    p_rec.pension_provider_type :=
    pqp_pty_shd.g_old_rec.pension_provider_type;
  End If;
  If (p_rec.salary_calculation_method = hr_api.g_varchar2) then
    p_rec.salary_calculation_method :=
    pqp_pty_shd.g_old_rec.salary_calculation_method;
  End If;
  If (p_rec.threshold_conversion_rule = hr_api.g_varchar2) then
    p_rec.threshold_conversion_rule :=
    pqp_pty_shd.g_old_rec.threshold_conversion_rule;
  End If;
  If (p_rec.contribution_conversion_rule = hr_api.g_varchar2) then
    p_rec.contribution_conversion_rule :=
    pqp_pty_shd.g_old_rec.contribution_conversion_rule;
  End If;
  If (p_rec.er_annual_limit = hr_api.g_number) then
    p_rec.er_annual_limit :=
    pqp_pty_shd.g_old_rec.er_annual_limit;
  End If;
  If (p_rec.ee_annual_limit = hr_api.g_number) then
    p_rec.ee_annual_limit :=
    pqp_pty_shd.g_old_rec.ee_annual_limit;
  End If;
  If (p_rec.er_annual_salary_threshold = hr_api.g_number) then
    p_rec.er_annual_salary_threshold :=
    pqp_pty_shd.g_old_rec.er_annual_salary_threshold;
  End If;
  If (p_rec.ee_annual_salary_threshold = hr_api.g_number) then
    p_rec.ee_annual_salary_threshold :=
    pqp_pty_shd.g_old_rec.ee_annual_salary_threshold;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqp_pty_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pqp_pty_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pqp_pty_shd.g_old_rec.description;
  End If;
  If (p_rec.minimum_age = hr_api.g_number) then
    p_rec.minimum_age :=
    pqp_pty_shd.g_old_rec.minimum_age;
  End If;
  If (p_rec.ee_contribution_percent = hr_api.g_number) then
    p_rec.ee_contribution_percent :=
    pqp_pty_shd.g_old_rec.ee_contribution_percent;
  End If;
  If (p_rec.maximum_age = hr_api.g_number) then
    p_rec.maximum_age :=
    pqp_pty_shd.g_old_rec.maximum_age;
  End If;
  If (p_rec.er_contribution_percent = hr_api.g_number) then
    p_rec.er_contribution_percent :=
    pqp_pty_shd.g_old_rec.er_contribution_percent;
  End If;
  If (p_rec.ee_annual_contribution = hr_api.g_number) then
    p_rec.ee_annual_contribution :=
    pqp_pty_shd.g_old_rec.ee_annual_contribution;
  End If;
  If (p_rec.er_annual_contribution = hr_api.g_number) then
    p_rec.er_annual_contribution :=
    pqp_pty_shd.g_old_rec.er_annual_contribution;
  End If;
  If (p_rec.annual_premium_amount = hr_api.g_number) then
    p_rec.annual_premium_amount :=
    pqp_pty_shd.g_old_rec.annual_premium_amount;
  End If;
  If (p_rec.ee_contribution_bal_type_id = hr_api.g_number) then
    p_rec.ee_contribution_bal_type_id :=
    pqp_pty_shd.g_old_rec.ee_contribution_bal_type_id;
  End If;
  If (p_rec.er_contribution_bal_type_id = hr_api.g_number) then
    p_rec.er_contribution_bal_type_id :=
    pqp_pty_shd.g_old_rec.er_contribution_bal_type_id;
  End If;
  If (p_rec.balance_init_element_type_id = hr_api.g_number) then
    p_rec.balance_init_element_type_id :=
    pqp_pty_shd.g_old_rec.balance_init_element_type_id;
  End If;



  If (p_rec.ee_contribution_fixed_rate  = hr_api.g_number) then           --added for UK
    p_rec.ee_contribution_fixed_rate:=
    pqp_pty_shd.g_old_rec.ee_contribution_fixed_rate;
  End If;

    If (p_rec.er_contribution_fixed_rate  = hr_api.g_number) then           --added for UK
    p_rec.er_contribution_fixed_rate:=
    pqp_pty_shd.g_old_rec.er_contribution_fixed_rate;
  End If;

  If (p_rec.pty_attribute_category = hr_api.g_varchar2) then
    p_rec.pty_attribute_category :=
    pqp_pty_shd.g_old_rec.pty_attribute_category;
  End If;
  If (p_rec.pty_attribute1 = hr_api.g_varchar2) then
    p_rec.pty_attribute1 :=
    pqp_pty_shd.g_old_rec.pty_attribute1;
  End If;
  If (p_rec.pty_attribute2 = hr_api.g_varchar2) then
    p_rec.pty_attribute2 :=
    pqp_pty_shd.g_old_rec.pty_attribute2;
  End If;
  If (p_rec.pty_attribute3 = hr_api.g_varchar2) then
    p_rec.pty_attribute3 :=
    pqp_pty_shd.g_old_rec.pty_attribute3;
  End If;
  If (p_rec.pty_attribute4 = hr_api.g_varchar2) then
    p_rec.pty_attribute4 :=
    pqp_pty_shd.g_old_rec.pty_attribute4;
  End If;
  If (p_rec.pty_attribute5 = hr_api.g_varchar2) then
    p_rec.pty_attribute5 :=
    pqp_pty_shd.g_old_rec.pty_attribute5;
  End If;
  If (p_rec.pty_attribute6 = hr_api.g_varchar2) then
    p_rec.pty_attribute6 :=
    pqp_pty_shd.g_old_rec.pty_attribute6;
  End If;
  If (p_rec.pty_attribute7 = hr_api.g_varchar2) then
    p_rec.pty_attribute7 :=
    pqp_pty_shd.g_old_rec.pty_attribute7;
  End If;
  If (p_rec.pty_attribute8 = hr_api.g_varchar2) then
    p_rec.pty_attribute8 :=
    pqp_pty_shd.g_old_rec.pty_attribute8;
  End If;
  If (p_rec.pty_attribute9 = hr_api.g_varchar2) then
    p_rec.pty_attribute9 :=
    pqp_pty_shd.g_old_rec.pty_attribute9;
  End If;
  If (p_rec.pty_attribute10 = hr_api.g_varchar2) then
    p_rec.pty_attribute10 :=
    pqp_pty_shd.g_old_rec.pty_attribute10;
  End If;
  If (p_rec.pty_attribute11 = hr_api.g_varchar2) then
    p_rec.pty_attribute11 :=
    pqp_pty_shd.g_old_rec.pty_attribute11;
  End If;
  If (p_rec.pty_attribute12 = hr_api.g_varchar2) then
    p_rec.pty_attribute12 :=
    pqp_pty_shd.g_old_rec.pty_attribute12;
  End If;
  If (p_rec.pty_attribute13 = hr_api.g_varchar2) then
    p_rec.pty_attribute13 :=
    pqp_pty_shd.g_old_rec.pty_attribute13;
  End If;
  If (p_rec.pty_attribute14 = hr_api.g_varchar2) then
    p_rec.pty_attribute14 :=
    pqp_pty_shd.g_old_rec.pty_attribute14;
  End If;
  If (p_rec.pty_attribute15 = hr_api.g_varchar2) then
    p_rec.pty_attribute15 :=
    pqp_pty_shd.g_old_rec.pty_attribute15;
  End If;
  If (p_rec.pty_attribute16 = hr_api.g_varchar2) then
    p_rec.pty_attribute16 :=
    pqp_pty_shd.g_old_rec.pty_attribute16;
  End If;
  If (p_rec.pty_attribute17 = hr_api.g_varchar2) then
    p_rec.pty_attribute17 :=
    pqp_pty_shd.g_old_rec.pty_attribute17;
  End If;
  If (p_rec.pty_attribute18 = hr_api.g_varchar2) then
    p_rec.pty_attribute18 :=
    pqp_pty_shd.g_old_rec.pty_attribute18;
  End If;
  If (p_rec.pty_attribute19 = hr_api.g_varchar2) then
    p_rec.pty_attribute19 :=
    pqp_pty_shd.g_old_rec.pty_attribute19;
  End If;
  If (p_rec.pty_attribute20 = hr_api.g_varchar2) then
    p_rec.pty_attribute20 :=
    pqp_pty_shd.g_old_rec.pty_attribute20;
  End If;
  If (p_rec.pty_information_category = hr_api.g_varchar2) then
    p_rec.pty_information_category :=
    pqp_pty_shd.g_old_rec.pty_information_category;
  End If;
  If (p_rec.pty_information1 = hr_api.g_varchar2) then
    p_rec.pty_information1 :=
    pqp_pty_shd.g_old_rec.pty_information1;
  End If;
  If (p_rec.pty_information2 = hr_api.g_varchar2) then
    p_rec.pty_information2 :=
    pqp_pty_shd.g_old_rec.pty_information2;
  End If;
  If (p_rec.pty_information3 = hr_api.g_varchar2) then
    p_rec.pty_information3 :=
    pqp_pty_shd.g_old_rec.pty_information3;
  End If;
  If (p_rec.pty_information4 = hr_api.g_varchar2) then
    p_rec.pty_information4 :=
    pqp_pty_shd.g_old_rec.pty_information4;
  End If;
  If (p_rec.pty_information5 = hr_api.g_varchar2) then
    p_rec.pty_information5 :=
    pqp_pty_shd.g_old_rec.pty_information5;
  End If;
  If (p_rec.pty_information6 = hr_api.g_varchar2) then
    p_rec.pty_information6 :=
    pqp_pty_shd.g_old_rec.pty_information6;
  End If;
  If (p_rec.pty_information7 = hr_api.g_varchar2) then
    p_rec.pty_information7 :=
    pqp_pty_shd.g_old_rec.pty_information7;
  End If;
  If (p_rec.pty_information8 = hr_api.g_varchar2) then
    p_rec.pty_information8 :=
    pqp_pty_shd.g_old_rec.pty_information8;
  End If;
  If (p_rec.pty_information9 = hr_api.g_varchar2) then
    p_rec.pty_information9 :=
    pqp_pty_shd.g_old_rec.pty_information9;
  End If;
  If (p_rec.pty_information10 = hr_api.g_varchar2) then
    p_rec.pty_information10 :=
    pqp_pty_shd.g_old_rec.pty_information10;
  End If;
  If (p_rec.pty_information11 = hr_api.g_varchar2) then
    p_rec.pty_information11 :=
    pqp_pty_shd.g_old_rec.pty_information11;
  End If;
  If (p_rec.pty_information12 = hr_api.g_varchar2) then
    p_rec.pty_information12 :=
    pqp_pty_shd.g_old_rec.pty_information12;
  End If;
  If (p_rec.pty_information13 = hr_api.g_varchar2) then
    p_rec.pty_information13 :=
    pqp_pty_shd.g_old_rec.pty_information13;
  End If;
  If (p_rec.pty_information14 = hr_api.g_varchar2) then
    p_rec.pty_information14 :=
    pqp_pty_shd.g_old_rec.pty_information14;
  End If;
  If (p_rec.pty_information15 = hr_api.g_varchar2) then
    p_rec.pty_information15 :=
    pqp_pty_shd.g_old_rec.pty_information15;
  End If;
  If (p_rec.pty_information16 = hr_api.g_varchar2) then
    p_rec.pty_information16 :=
    pqp_pty_shd.g_old_rec.pty_information16;
  End If;
  If (p_rec.pty_information17 = hr_api.g_varchar2) then
    p_rec.pty_information17 :=
    pqp_pty_shd.g_old_rec.pty_information17;
  End If;
  If (p_rec.pty_information18 = hr_api.g_varchar2) then
    p_rec.pty_information18 :=
    pqp_pty_shd.g_old_rec.pty_information18;
  End If;
  If (p_rec.pty_information19 = hr_api.g_varchar2) then
    p_rec.pty_information19 :=
    pqp_pty_shd.g_old_rec.pty_information19;
  End If;
  If (p_rec.pty_information20 = hr_api.g_varchar2) then
    p_rec.pty_information20 :=
    pqp_pty_shd.g_old_rec.pty_information20;
  End If;
  If (p_rec.special_pension_type_code = hr_api.g_varchar2) then
    p_rec.special_pension_type_code :=
    pqp_pty_shd.g_old_rec.special_pension_type_code;
  End If;
  If (p_rec.pension_sub_category = hr_api.g_varchar2) then
    p_rec.pension_sub_category :=
    pqp_pty_shd.g_old_rec.pension_sub_category;
  End If;
  If (p_rec.pension_basis_calc_method = hr_api.g_varchar2) then
    p_rec.pension_basis_calc_method :=
    pqp_pty_shd.g_old_rec.pension_basis_calc_method;
  End If;
  If (p_rec.pension_salary_balance = hr_api.g_number) then
    p_rec.pension_salary_balance :=
    pqp_pty_shd.g_old_rec.pension_salary_balance;
  End If;
  If (p_rec.recurring_bonus_percent = hr_api.g_number) then
    p_rec.recurring_bonus_percent :=
    pqp_pty_shd.g_old_rec.recurring_bonus_percent;
  End If;
  If (p_rec.non_recurring_bonus_percent = hr_api.g_number) then
    p_rec.non_recurring_bonus_percent :=
    pqp_pty_shd.g_old_rec.non_recurring_bonus_percent;
  End If;
  If (p_rec.recurring_bonus_balance = hr_api.g_number) then
    p_rec.recurring_bonus_balance :=
    pqp_pty_shd.g_old_rec.recurring_bonus_balance;
  End If;
  If (p_rec.non_recurring_bonus_balance = hr_api.g_number) then
    p_rec.non_recurring_bonus_balance :=
    pqp_pty_shd.g_old_rec.non_recurring_bonus_balance;
  End If;
  If (p_rec.std_tax_reduction = hr_api.g_varchar2) then
    p_rec.std_tax_reduction :=
    pqp_pty_shd.g_old_rec.std_tax_reduction;
  End If;
  If (p_rec.spl_tax_reduction = hr_api.g_varchar2) then
    p_rec.spl_tax_reduction :=
    pqp_pty_shd.g_old_rec.spl_tax_reduction;
  End If;
  If (p_rec.sig_sal_spl_tax_reduction = hr_api.g_varchar2) then
    p_rec.sig_sal_spl_tax_reduction :=
    pqp_pty_shd.g_old_rec.sig_sal_spl_tax_reduction;
  End If;
  If (p_rec.sig_sal_non_tax_reduction = hr_api.g_varchar2) then
    p_rec.sig_sal_non_tax_reduction :=
    pqp_pty_shd.g_old_rec.sig_sal_non_tax_reduction;
  End If;
  If (p_rec.sig_sal_std_tax_reduction = hr_api.g_varchar2) then
    p_rec.sig_sal_std_tax_reduction :=
    pqp_pty_shd.g_old_rec.sig_sal_std_tax_reduction;
  End If;
  If (p_rec.sii_std_tax_reduction = hr_api.g_varchar2) then
    p_rec.sii_std_tax_reduction :=
    pqp_pty_shd.g_old_rec.sii_std_tax_reduction;
  End If;
  If (p_rec.sii_spl_tax_reduction = hr_api.g_varchar2) then
    p_rec.sii_spl_tax_reduction :=
    pqp_pty_shd.g_old_rec.sii_spl_tax_reduction;
  End If;
  If (p_rec.sii_non_tax_reduction = hr_api.g_varchar2) then
    p_rec.sii_non_tax_reduction :=
    pqp_pty_shd.g_old_rec.sii_non_tax_reduction;
  End If;
  If (p_rec.previous_year_bonus_included = hr_api.g_varchar2) then
    p_rec.previous_year_bonus_included :=
    pqp_pty_shd.g_old_rec.previous_year_bonus_included;
  End If;
  If (p_rec.recurring_bonus_period = hr_api.g_varchar2) then
    p_rec.recurring_bonus_period :=
    pqp_pty_shd.g_old_rec.recurring_bonus_period;
  End If;
  If (p_rec.non_recurring_bonus_period = hr_api.g_varchar2) then
    p_rec.non_recurring_bonus_period :=
    pqp_pty_shd.g_old_rec.non_recurring_bonus_period;
  End If;
  If (p_rec.ee_age_threshold = hr_api.g_varchar2) then
    p_rec.ee_age_threshold :=
    pqp_pty_shd.g_old_rec.ee_age_threshold;
  End If;
  If (p_rec.er_age_threshold = hr_api.g_varchar2) then
    p_rec.er_age_threshold :=
    pqp_pty_shd.g_old_rec.er_age_threshold;
  End If;
  If (p_rec.ee_age_contribution = hr_api.g_varchar2) then
    p_rec.ee_age_contribution :=
    pqp_pty_shd.g_old_rec.ee_age_contribution;
  End If;
  If (p_rec.er_age_contribution = hr_api.g_varchar2) then
    p_rec.er_age_contribution :=
    pqp_pty_shd.g_old_rec.er_age_contribution;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pqp_pty_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'upd';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  pqp_pty_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_pension_type_id                  => p_rec.pension_type_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  pqp_pty_upd.convert_defs(p_rec);
  --
  pqp_pty_bus.update_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Update the row.
  --
  update_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date                  => l_validation_end_date
    );
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
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
  ,p_special_pension_type_code    in     varchar2  default hr_api.g_varchar2      -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number    default hr_api.g_number  	  -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number    default hr_api.g_number  	  -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number    default hr_api.g_number  	  -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number    default hr_api.g_number  	  -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number    default hr_api.g_number  	  -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2  default hr_api.g_varchar2 	  -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2  default hr_api.g_varchar2      -- added for ABP TAR fixes
  ,p_er_age_threshold             in     varchar2  default hr_api.g_varchar2      -- added for ABP TAR fixes
  ,p_ee_age_contribution          in     varchar2  default hr_api.g_varchar2      -- added for ABP TAR fixes
  ,p_er_age_contribution          in     varchar2  default hr_api.g_varchar2      -- added for ABP TAR fixes
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
--
  l_rec         pqp_pty_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_pty_shd.convert_args
    (p_pension_type_id
    ,null
    ,null
    ,p_pension_type_name
    ,p_pension_category
    ,p_pension_provider_type
    ,p_salary_calculation_method
    ,p_threshold_conversion_rule
    ,p_contribution_conversion_rule
    ,p_er_annual_limit
    ,p_ee_annual_limit
    ,p_er_annual_salary_threshold
    ,p_ee_annual_salary_threshold
    ,p_object_version_number
    ,p_business_group_id
    ,p_legislation_code
    ,p_description
    ,p_minimum_age
    ,p_ee_contribution_percent
    ,p_maximum_age
    ,p_er_contribution_percent
    ,p_ee_annual_contribution
    ,p_er_annual_contribution
    ,p_annual_premium_amount
    ,p_ee_contribution_bal_type_id
    ,p_er_contribution_bal_type_id
    ,p_balance_init_element_type_id
    ,p_ee_contribution_fixed_rate   --added for UK
    ,p_er_contribution_fixed_rate   --added for UK
    ,p_pty_attribute_category
    ,p_pty_attribute1
    ,p_pty_attribute2
    ,p_pty_attribute3
    ,p_pty_attribute4
    ,p_pty_attribute5
    ,p_pty_attribute6
    ,p_pty_attribute7
    ,p_pty_attribute8
    ,p_pty_attribute9
    ,p_pty_attribute10
    ,p_pty_attribute11
    ,p_pty_attribute12
    ,p_pty_attribute13
    ,p_pty_attribute14
    ,p_pty_attribute15
    ,p_pty_attribute16
    ,p_pty_attribute17
    ,p_pty_attribute18
    ,p_pty_attribute19
    ,p_pty_attribute20
    ,p_pty_information_category
    ,p_pty_information1
    ,p_pty_information2
    ,p_pty_information3
    ,p_pty_information4
    ,p_pty_information5
    ,p_pty_information6
    ,p_pty_information7
    ,p_pty_information8
    ,p_pty_information9
    ,p_pty_information10
    ,p_pty_information11
    ,p_pty_information12
    ,p_pty_information13
    ,p_pty_information14
    ,p_pty_information15
    ,p_pty_information16
    ,p_pty_information17
    ,p_pty_information18
    ,p_pty_information19
    ,p_pty_information20
    ,p_special_pension_type_code       -- added for NL Phase 2B
    ,p_pension_sub_category            -- added for NL Phase 2B
    ,p_pension_basis_calc_method       -- added for NL Phase 2B
    ,p_pension_salary_balance          -- added for NL Phase 2B
    ,p_recurring_bonus_percent         -- added for NL Phase 2B
    ,p_non_recurring_bonus_percent     -- added for NL Phase 2B
    ,p_recurring_bonus_balance         -- added for NL Phase 2B
    ,p_non_recurring_bonus_balance     -- added for NL Phase 2B
    ,p_std_tax_reduction               -- added for NL Phase 2B
    ,p_spl_tax_reduction               -- added for NL Phase 2B
    ,p_sig_sal_spl_tax_reduction       -- added for NL Phase 2B
    ,p_sig_sal_non_tax_reduction       -- added for NL Phase 2B
    ,p_sig_sal_std_tax_reduction       -- added for NL Phase 2B
    ,p_sii_std_tax_reduction           -- added for NL Phase 2B
    ,p_sii_spl_tax_reduction           -- added for NL Phase 2B
    ,p_sii_non_tax_reduction           -- added for NL Phase 2B
    ,p_previous_year_bonus_included    -- added for NL Phase 2B
    ,p_recurring_bonus_period          -- added for NL Phase 2B
    ,p_non_recurring_bonus_period      -- added for NL Phase 2B
    ,p_ee_age_threshold                -- added for ABP TAR Fixes
    ,p_er_age_threshold                -- added for ABP TAR Fixes
    ,p_ee_age_contribution             -- added for ABP TAR Fixes
    ,p_er_age_contribution             -- added for ABP TAR Fixes
     );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_pty_upd.upd
    (p_effective_date
    ,p_datetrack_mode
    ,l_rec
    );
  --
  -- Set the out parameters
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--

end pqp_pty_upd;


/
