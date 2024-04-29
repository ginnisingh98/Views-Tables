--------------------------------------------------------
--  DDL for Package Body PAY_OPM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_OPM_UPD" as
/* $Header: pyopmrhi.pkb 120.4 2005/11/07 01:38:13 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_opm_upd.';  -- Global package name
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
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
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
  (p_rec                   in out nocopy pay_opm_shd.g_rec_type
  ,p_effective_date        in            date
  ,p_datetrack_mode        in            varchar2
  ,p_validation_start_date in            date
  ,p_validation_end_date   in            date
  ) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
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
        (p_base_table_name => 'pay_org_payment_methods_f'
        ,p_base_key_column => 'org_payment_method_id'
        ,p_base_key_value  => p_rec.org_payment_method_id
        );
    --
    pay_opm_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the pay_org_payment_methods_f Row
    --
    update  pay_org_payment_methods_f
    set
     org_payment_method_id                = p_rec.org_payment_method_id
    ,business_group_id                    = p_rec.business_group_id
    ,external_account_id                  = p_rec.external_account_id
    ,currency_code                        = p_rec.currency_code
    ,payment_type_id                      = p_rec.payment_type_id
    ,defined_balance_id                   = p_rec.defined_balance_id
    ,org_payment_method_name              = p_rec.org_payment_method_name
    ,comment_id                           = p_rec.comment_id
    ,attribute_category                   = p_rec.attribute_category
    ,attribute1                           = p_rec.attribute1
    ,attribute2                           = p_rec.attribute2
    ,attribute3                           = p_rec.attribute3
    ,attribute4                           = p_rec.attribute4
    ,attribute5                           = p_rec.attribute5
    ,attribute6                           = p_rec.attribute6
    ,attribute7                           = p_rec.attribute7
    ,attribute8                           = p_rec.attribute8
    ,attribute9                           = p_rec.attribute9
    ,attribute10                          = p_rec.attribute10
    ,attribute11                          = p_rec.attribute11
    ,attribute12                          = p_rec.attribute12
    ,attribute13                          = p_rec.attribute13
    ,attribute14                          = p_rec.attribute14
    ,attribute15                          = p_rec.attribute15
    ,attribute16                          = p_rec.attribute16
    ,attribute17                          = p_rec.attribute17
    ,attribute18                          = p_rec.attribute18
    ,attribute19                          = p_rec.attribute19
    ,attribute20                          = p_rec.attribute20
    ,pmeth_information_category           = p_rec.pmeth_information_category
    ,pmeth_information1                   = p_rec.pmeth_information1
    ,pmeth_information2                   = p_rec.pmeth_information2
    ,pmeth_information3                   = p_rec.pmeth_information3
    ,pmeth_information4                   = p_rec.pmeth_information4
    ,pmeth_information5                   = p_rec.pmeth_information5
    ,pmeth_information6                   = p_rec.pmeth_information6
    ,pmeth_information7                   = p_rec.pmeth_information7
    ,pmeth_information8                   = p_rec.pmeth_information8
    ,pmeth_information9                   = p_rec.pmeth_information9
    ,pmeth_information10                  = p_rec.pmeth_information10
    ,pmeth_information11                  = p_rec.pmeth_information11
    ,pmeth_information12                  = p_rec.pmeth_information12
    ,pmeth_information13                  = p_rec.pmeth_information13
    ,pmeth_information14                  = p_rec.pmeth_information14
    ,pmeth_information15                  = p_rec.pmeth_information15
    ,pmeth_information16                  = p_rec.pmeth_information16
    ,pmeth_information17                  = p_rec.pmeth_information17
    ,pmeth_information18                  = p_rec.pmeth_information18
    ,pmeth_information19                  = p_rec.pmeth_information19
    ,pmeth_information20                  = p_rec.pmeth_information20
    ,object_version_number                = p_rec.object_version_number
    ,transfer_to_gl_flag                  = p_rec.transfer_to_gl_flag
    ,cost_payment			  = p_rec.cost_payment
    ,cost_cleared_payment                 = p_rec.cost_cleared_payment
    ,cost_cleared_void_payment            = p_rec.cost_cleared_void_payment
    ,exclude_manual_payment               = p_rec.exclude_manual_payment
    where   org_payment_method_id = p_rec.org_payment_method_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
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
    pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
    pay_opm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
    pay_opm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec                      in out nocopy pay_opm_shd.g_rec_type
  ,p_effective_date           in            date
  ,p_datetrack_mode           in            varchar2
  ,p_validation_start_date    in            date
  ,p_validation_end_date      in            date
  ) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_opm_upd.dt_update_dml
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
--	the validation_start_date.
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
  (p_rec                     in out nocopy pay_opm_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --
    pay_opm_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value	        => p_rec.org_payment_method_id
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
      pay_opm_del.delete_dml
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
    pay_opm_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date	        => p_effective_date
      ,p_datetrack_mode	        => p_datetrack_mode
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
--
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
  (p_rec                   in out nocopy pay_opm_shd.g_rec_type
  ,p_effective_date        in            date
  ,p_datetrack_mode        in            varchar2
  ,p_validation_start_date in            date
  ,p_validation_end_date   in            date
  ) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null and p_rec.comment_id is null) then
     hr_comm_api.ins(p_comment_id        => p_rec.comment_id
                    ,p_source_table_name => 'PAY_ORG_PAYMENT_METHODS_F'
                    ,p_comment_text      => p_rec.comments
                    );
  -- Update the comments if they have changed
  ElsIf (p_rec.comment_id is not null and p_rec.comments <>
        pay_opm_shd.g_old_rec.comments) then
     hr_comm_api.upd(p_comment_id        => p_rec.comment_id
                    ,p_source_table_name => 'PAY_ORG_PAYMENT_METHODS_F'
                    ,p_comment_text      => p_rec.comments
                    );
  End If;
  --
  dt_pre_update
    (p_rec                   => p_rec
    ,p_effective_date	     => p_effective_date
    ,p_datetrack_mode	     => p_datetrack_mode
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
--   This private procedure contains any processing which is required after the
--   update dml.
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
  (p_rec                   in pay_opm_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_opm_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_org_payment_method_id
      => p_rec.org_payment_method_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_external_account_id
      => p_rec.external_account_id
      ,p_currency_code
      => p_rec.currency_code
      ,p_comment_id
      => p_rec.comment_id
      ,p_comments
      => p_rec.comments
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_pmeth_information_category
      => p_rec.pmeth_information_category
      ,p_pmeth_information1
      => p_rec.pmeth_information1
      ,p_pmeth_information2
      => p_rec.pmeth_information2
      ,p_pmeth_information3
      => p_rec.pmeth_information3
      ,p_pmeth_information4
      => p_rec.pmeth_information4
      ,p_pmeth_information5
      => p_rec.pmeth_information5
      ,p_pmeth_information6
      => p_rec.pmeth_information6
      ,p_pmeth_information7
      => p_rec.pmeth_information7
      ,p_pmeth_information8
      => p_rec.pmeth_information8
      ,p_pmeth_information9
      => p_rec.pmeth_information9
      ,p_pmeth_information10
      => p_rec.pmeth_information10
      ,p_pmeth_information11
      => p_rec.pmeth_information11
      ,p_pmeth_information12
      => p_rec.pmeth_information12
      ,p_pmeth_information13
      => p_rec.pmeth_information13
      ,p_pmeth_information14
      => p_rec.pmeth_information14
      ,p_pmeth_information15
      => p_rec.pmeth_information15
      ,p_pmeth_information16
      => p_rec.pmeth_information16
      ,p_pmeth_information17
      => p_rec.pmeth_information17
      ,p_pmeth_information18
      => p_rec.pmeth_information18
      ,p_pmeth_information19
      => p_rec.pmeth_information19
      ,p_pmeth_information20
      => p_rec.pmeth_information20
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_transfer_to_gl_flag
      => p_rec.transfer_to_gl_flag
      ,p_cost_payment
      => p_rec.cost_payment
      ,p_cost_cleared_payment
      => p_rec.cost_cleared_payment
      ,p_cost_cleared_void_payment
      => p_rec.cost_cleared_void_payment
      ,p_exclude_manual_payment
      => p_rec.exclude_manual_payment
      ,p_effective_start_date_o
      => pay_opm_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_opm_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => pay_opm_shd.g_old_rec.business_group_id
      ,p_external_account_id_o
      => pay_opm_shd.g_old_rec.external_account_id
      ,p_currency_code_o
      => pay_opm_shd.g_old_rec.currency_code
      ,p_payment_type_id_o
      => pay_opm_shd.g_old_rec.payment_type_id
      ,p_defined_balance_id_o
      => pay_opm_shd.g_old_rec.defined_balance_id
      ,p_org_payment_method_name_o
      => pay_opm_shd.g_old_rec.org_payment_method_name
      ,p_comment_id_o
      => pay_opm_shd.g_old_rec.comment_id
      ,p_comments_o
      => pay_opm_shd.g_old_rec.comments
      ,p_attribute_category_o
      => pay_opm_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_opm_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_opm_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_opm_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_opm_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_opm_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_opm_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_opm_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_opm_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_opm_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_opm_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_opm_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_opm_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_opm_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_opm_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_opm_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_opm_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_opm_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_opm_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_opm_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_opm_shd.g_old_rec.attribute20
      ,p_pmeth_information_category_o
      => pay_opm_shd.g_old_rec.pmeth_information_category
      ,p_pmeth_information1_o
      => pay_opm_shd.g_old_rec.pmeth_information1
      ,p_pmeth_information2_o
      => pay_opm_shd.g_old_rec.pmeth_information2
      ,p_pmeth_information3_o
      => pay_opm_shd.g_old_rec.pmeth_information3
      ,p_pmeth_information4_o
      => pay_opm_shd.g_old_rec.pmeth_information4
      ,p_pmeth_information5_o
      => pay_opm_shd.g_old_rec.pmeth_information5
      ,p_pmeth_information6_o
      => pay_opm_shd.g_old_rec.pmeth_information6
      ,p_pmeth_information7_o
      => pay_opm_shd.g_old_rec.pmeth_information7
      ,p_pmeth_information8_o
      => pay_opm_shd.g_old_rec.pmeth_information8
      ,p_pmeth_information9_o
      => pay_opm_shd.g_old_rec.pmeth_information9
      ,p_pmeth_information10_o
      => pay_opm_shd.g_old_rec.pmeth_information10
      ,p_pmeth_information11_o
      => pay_opm_shd.g_old_rec.pmeth_information11
      ,p_pmeth_information12_o
      => pay_opm_shd.g_old_rec.pmeth_information12
      ,p_pmeth_information13_o
      => pay_opm_shd.g_old_rec.pmeth_information13
      ,p_pmeth_information14_o
      => pay_opm_shd.g_old_rec.pmeth_information14
      ,p_pmeth_information15_o
      => pay_opm_shd.g_old_rec.pmeth_information15
      ,p_pmeth_information16_o
      => pay_opm_shd.g_old_rec.pmeth_information16
      ,p_pmeth_information17_o
      => pay_opm_shd.g_old_rec.pmeth_information17
      ,p_pmeth_information18_o
      => pay_opm_shd.g_old_rec.pmeth_information18
      ,p_pmeth_information19_o
      => pay_opm_shd.g_old_rec.pmeth_information19
      ,p_pmeth_information20_o
      => pay_opm_shd.g_old_rec.pmeth_information20
      ,p_object_version_number_o
      => pay_opm_shd.g_old_rec.object_version_number
      ,p_transfer_to_gl_flag_o
      => pay_opm_shd.g_old_rec.transfer_to_gl_flag
      ,p_cost_payment_o
      => pay_opm_shd.g_old_rec.cost_payment
      ,p_cost_cleared_payment_o
      => pay_opm_shd.g_old_rec.cost_cleared_payment
      ,p_cost_cleared_void_payment_o
      => pay_opm_shd.g_old_rec.cost_cleared_void_payment
      ,p_exclude_manual_payment_o
      => pay_opm_shd.g_old_rec.exclude_manual_payment
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ORG_PAYMENT_METHODS_F'
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
  (p_rec in out nocopy pay_opm_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_opm_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.external_account_id = hr_api.g_number) then
    p_rec.external_account_id :=
    pay_opm_shd.g_old_rec.external_account_id;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    pay_opm_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.payment_type_id = hr_api.g_number) then
    p_rec.payment_type_id :=
    pay_opm_shd.g_old_rec.payment_type_id;
  End If;
  If (p_rec.defined_balance_id = hr_api.g_number) then
    p_rec.defined_balance_id :=
    pay_opm_shd.g_old_rec.defined_balance_id;
  End If;
  If (p_rec.org_payment_method_name = hr_api.g_varchar2) then
    p_rec.org_payment_method_name :=
    pay_opm_shd.g_old_rec.org_payment_method_name;
  End If;
  If (p_rec.comment_id = hr_api.g_number) then
    p_rec.comment_id :=
    pay_opm_shd.g_old_rec.comment_id;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    pay_opm_shd.g_old_rec.comments;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pay_opm_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pay_opm_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pay_opm_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pay_opm_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pay_opm_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pay_opm_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pay_opm_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pay_opm_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pay_opm_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pay_opm_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pay_opm_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pay_opm_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pay_opm_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pay_opm_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pay_opm_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pay_opm_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pay_opm_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pay_opm_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pay_opm_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pay_opm_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pay_opm_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.pmeth_information_category = hr_api.g_varchar2) then
    p_rec.pmeth_information_category :=
    pay_opm_shd.g_old_rec.pmeth_information_category;
  End If;
  If (p_rec.pmeth_information1 = hr_api.g_varchar2) then
    p_rec.pmeth_information1 :=
    pay_opm_shd.g_old_rec.pmeth_information1;
  End If;
  If (p_rec.pmeth_information2 = hr_api.g_varchar2) then
    p_rec.pmeth_information2 :=
    pay_opm_shd.g_old_rec.pmeth_information2;
  End If;
  If (p_rec.pmeth_information3 = hr_api.g_varchar2) then
    p_rec.pmeth_information3 :=
    pay_opm_shd.g_old_rec.pmeth_information3;
  End If;
  If (p_rec.pmeth_information4 = hr_api.g_varchar2) then
    p_rec.pmeth_information4 :=
    pay_opm_shd.g_old_rec.pmeth_information4;
  End If;
  If (p_rec.pmeth_information5 = hr_api.g_varchar2) then
    p_rec.pmeth_information5 :=
    pay_opm_shd.g_old_rec.pmeth_information5;
  End If;
  If (p_rec.pmeth_information6 = hr_api.g_varchar2) then
    p_rec.pmeth_information6 :=
    pay_opm_shd.g_old_rec.pmeth_information6;
  End If;
  If (p_rec.pmeth_information7 = hr_api.g_varchar2) then
    p_rec.pmeth_information7 :=
    pay_opm_shd.g_old_rec.pmeth_information7;
  End If;
  If (p_rec.pmeth_information8 = hr_api.g_varchar2) then
    p_rec.pmeth_information8 :=
    pay_opm_shd.g_old_rec.pmeth_information8;
  End If;
  If (p_rec.pmeth_information9 = hr_api.g_varchar2) then
    p_rec.pmeth_information9 :=
    pay_opm_shd.g_old_rec.pmeth_information9;
  End If;
  If (p_rec.pmeth_information10 = hr_api.g_varchar2) then
    p_rec.pmeth_information10 :=
    pay_opm_shd.g_old_rec.pmeth_information10;
  End If;
  If (p_rec.pmeth_information11 = hr_api.g_varchar2) then
    p_rec.pmeth_information11 :=
    pay_opm_shd.g_old_rec.pmeth_information11;
  End If;
  If (p_rec.pmeth_information12 = hr_api.g_varchar2) then
    p_rec.pmeth_information12 :=
    pay_opm_shd.g_old_rec.pmeth_information12;
  End If;
  If (p_rec.pmeth_information13 = hr_api.g_varchar2) then
    p_rec.pmeth_information13 :=
    pay_opm_shd.g_old_rec.pmeth_information13;
  End If;
  If (p_rec.pmeth_information14 = hr_api.g_varchar2) then
    p_rec.pmeth_information14 :=
    pay_opm_shd.g_old_rec.pmeth_information14;
  End If;
  If (p_rec.pmeth_information15 = hr_api.g_varchar2) then
    p_rec.pmeth_information15 :=
    pay_opm_shd.g_old_rec.pmeth_information15;
  End If;
  If (p_rec.pmeth_information16 = hr_api.g_varchar2) then
    p_rec.pmeth_information16 :=
    pay_opm_shd.g_old_rec.pmeth_information16;
  End If;
  If (p_rec.pmeth_information17 = hr_api.g_varchar2) then
    p_rec.pmeth_information17 :=
    pay_opm_shd.g_old_rec.pmeth_information17;
  End If;
  If (p_rec.pmeth_information18 = hr_api.g_varchar2) then
    p_rec.pmeth_information18 :=
    pay_opm_shd.g_old_rec.pmeth_information18;
  End If;
  If (p_rec.pmeth_information19 = hr_api.g_varchar2) then
    p_rec.pmeth_information19 :=
    pay_opm_shd.g_old_rec.pmeth_information19;
  End If;
  If (p_rec.pmeth_information20 = hr_api.g_varchar2) then
    p_rec.pmeth_information20 :=
    pay_opm_shd.g_old_rec.pmeth_information20;
  End If;
  If (p_rec.transfer_to_gl_flag = hr_api.g_varchar2) then
    p_rec.transfer_to_gl_flag :=
    pay_opm_shd.g_old_rec.transfer_to_gl_flag;
  End If;
  If (p_rec.cost_payment = hr_api.g_varchar2) then
    p_rec.cost_payment :=
    pay_opm_shd.g_old_rec.cost_payment;
  End If;
  If (p_rec.cost_cleared_payment = hr_api.g_varchar2) then
    p_rec.cost_cleared_payment :=
    pay_opm_shd.g_old_rec.cost_cleared_payment;
  End If;
  If (p_rec.cost_cleared_void_payment = hr_api.g_varchar2) then
    p_rec.cost_cleared_void_payment :=
    pay_opm_shd.g_old_rec.cost_cleared_void_payment;
  End If;
  If (p_rec.exclude_manual_payment = hr_api.g_varchar2) then
    p_rec.exclude_manual_payment :=
    pay_opm_shd.g_old_rec.exclude_manual_payment;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in            date
  ,p_datetrack_mode in            varchar2
  ,p_rec            in out nocopy pay_opm_shd.g_rec_type
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
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
  pay_opm_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_org_payment_method_id            => p_rec.org_payment_method_id
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
  pay_opm_upd.convert_defs(p_rec);
  --
  pay_opm_bus.update_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
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
    ,p_validation_end_date	            => l_validation_end_date
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
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_org_payment_method_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_external_account_id          in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information_category   in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information1           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information2           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information3           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information4           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information5           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information6           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information7           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information8           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information9           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information10          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information11          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information12          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information13          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information14          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information15          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information16          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information17          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information18          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information19          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information20          in     varchar2  default hr_api.g_varchar2
  ,p_transfer_to_gl_flag          in     varchar2  default hr_api.g_varchar2
  ,p_cost_payment                 in     varchar2  default hr_api.g_varchar2
  ,p_cost_cleared_payment         in     varchar2  default hr_api.g_varchar2
  ,p_cost_cleared_void_payment    in     varchar2  default hr_api.g_varchar2
  ,p_exclude_manual_payment       in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_comment_id                      out nocopy number
  ) is
--
  l_rec		pay_opm_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_opm_shd.convert_args
    (p_org_payment_method_id
    ,null
    ,null
    ,hr_api.g_number
    ,p_external_account_id
    ,p_currency_code
    ,hr_api.g_number
    ,hr_api.g_number
    ,hr_api.g_varchar2
    ,hr_api.g_number
    ,p_comments
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_pmeth_information_category
    ,p_pmeth_information1
    ,p_pmeth_information2
    ,p_pmeth_information3
    ,p_pmeth_information4
    ,p_pmeth_information5
    ,p_pmeth_information6
    ,p_pmeth_information7
    ,p_pmeth_information8
    ,p_pmeth_information9
    ,p_pmeth_information10
    ,p_pmeth_information11
    ,p_pmeth_information12
    ,p_pmeth_information13
    ,p_pmeth_information14
    ,p_pmeth_information15
    ,p_pmeth_information16
    ,p_pmeth_information17
    ,p_pmeth_information18
    ,p_pmeth_information19
    ,p_pmeth_information20
    ,p_object_version_number
    ,p_transfer_to_gl_flag
    ,p_cost_payment
    ,p_cost_cleared_payment
    ,p_cost_cleared_void_payment
    ,p_exclude_manual_payment
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_opm_upd.upd
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
  p_comment_id                       := l_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_opm_upd;

/
