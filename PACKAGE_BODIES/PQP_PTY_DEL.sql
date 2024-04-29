--------------------------------------------------------
--  DDL for Package Body PQP_PTY_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PTY_DEL" as
/* $Header: pqptyrhi.pkb 120.0.12000000.1 2007/01/16 04:29:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pty_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
  (p_rec                     in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = hr_api.g_delete_next_change) then
    --
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pqp_pension_types_f
    where       pension_type_id = p_rec.pension_type_id
    and   effective_start_date = p_validation_start_date;
    --
    --
  Else
    --
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pqp_pension_types_f
    where        pension_type_id = p_rec.pension_type_id
    and   effective_start_date >= p_validation_start_date;
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Deletes row(s) from hr_application_ownerships depending on the mode that
--   the row handler has been called in.
--
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column  IN  varchar2
                               ,p_pk_value   IN  varchar2
                               ,p_datetrack_mode IN varchar2) IS
--
BEGIN
  --
  IF ((hr_startup_data_api_support.return_startup_mode
                           IN ('STARTUP','GENERIC')) AND
      p_datetrack_mode = 'ZAP') THEN
     --
     DELETE FROM hr_application_ownerships
      WHERE key_name = p_pk_column
        AND key_value = p_pk_value;
     --
  END IF;
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number
                               ,p_datetrack_mode IN varchar2) IS
--
BEGIN
  delete_app_ownerships(p_pk_column,
                        to_char(p_pk_value),
                        p_datetrack_mode
                       );
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_pty_del.dt_delete_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
  (p_rec                     in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> hr_api.g_zap) then
    --
    p_rec.effective_start_date
      := pqp_pty_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pqp_pty_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.pension_type_id
      ,p_new_effective_end_date => p_rec.effective_end_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number            => p_rec.object_version_number
      );
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
  (p_rec                   in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
--
  --
  pqp_pty_del.dt_pre_delete
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_delete >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
  (p_rec                   in pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   begin
      --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('PENSION_TYPE_ID', p_rec.pension_type_id
      ,p_datetrack_mode
      );
    --
    pqp_pty_rkd.after_delete
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
     ,p_ee_contribution_fixed_rate_o  => pqp_pty_shd.g_old_rec.ee_contribution_fixed_rate
     ,p_er_contribution_fixed_rate_o  => pqp_pty_shd.g_old_rec.ee_contribution_fixed_rate
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pqp_pty_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'del';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
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
  -- Call the supporting delete validate operation
  --
  pqp_pty_bus.delete_validate
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
  -- Call the supporting pre-delete operation
  --
  pqp_pty_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pqp_pty_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pqp_pty_del.post_delete
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
  hr_utility.set_location(' Leaving:'||l_proc, 5);
End del;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< del >-----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_pension_type_id                  in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ) is

    Cursor csr_data_pension_types_f
    (
    c_pension_type_id in pqp_pension_types_f.pension_type_id%TYPE
    ) Is
    select
    business_group_id,
    pension_type_id
    from pqp_pension_types_f
    where
    pension_type_id =  c_pension_type_id;
--
  l_rec         pqp_pty_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'del';
  l_business_group_id pqp_pension_types_f.business_group_id%TYPE;
  l_pension_type_id pqp_pension_types_f.pension_type_id%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --

      open csr_data_pension_types_f
      (
        c_pension_type_id => p_pension_type_id
      );

      fetch csr_data_pension_types_f
      Into
      l_business_group_id,
      l_pension_type_id;

      l_rec.pension_type_id          := p_pension_type_id;
      l_rec.object_version_number     := p_object_version_number;
      l_rec.business_group_id := l_business_group_id;


  --
  -- Having converted the arguments into the pqp_pty_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqp_pty_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     );
  --
  --
  -- Set the out arguments
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqp_pty_del;


/
