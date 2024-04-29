--------------------------------------------------------
--  DDL for Package Body HR_CLE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CLE_UPD" as
/* $Header: hrclerhi.pkb 115.6 2002/12/03 09:27:16 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_cle_upd.';  -- Global package name
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
  (p_rec                   in out nocopy hr_cle_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode in     varchar2
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
        (p_base_table_name => 'hr_de_soc_ins_contr_lvls_f'
        ,p_base_key_column => 'soc_ins_contr_lvls_id'
        ,p_base_key_value  => p_rec.soc_ins_contr_lvls_id
        );
    --
    --
    --
    -- Update the hr_de_soc_ins_contr_lvls_f Row
    --
    update  hr_de_soc_ins_contr_lvls_f
    set
     soc_ins_contr_lvls_id                = p_rec.soc_ins_contr_lvls_id
    ,organization_id                      = p_rec.organization_id
    ,normal_percentage                    = p_rec.normal_percentage
    ,normal_amount                        = p_rec.normal_amount
    ,increased_percentage                 = p_rec.increased_percentage
    ,increased_amount                     = p_rec.increased_amount
    ,reduced_percentage                   = p_rec.reduced_percentage
    ,reduced_amount                       = p_rec.reduced_amount
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
    ,object_version_number                = p_rec.object_version_number
    ,attribute21                          = p_rec.attribute21
    ,attribute22                          = p_rec.attribute22
    ,attribute23                          = p_rec.attribute23
    ,attribute24                          = p_rec.attribute24
    ,attribute25                          = p_rec.attribute25
    ,attribute26                          = p_rec.attribute26
    ,attribute27                          = p_rec.attribute27
    ,attribute28                          = p_rec.attribute28
    ,attribute29                          = p_rec.attribute29
    ,attribute30                          = p_rec.attribute30
    ,flat_tax_limit_per_month	          = p_rec.flat_tax_limit_per_month
    ,flat_tax_limit_per_year		  = p_rec.flat_tax_limit_per_year
    ,min_increased_contribution		  = p_rec.min_increased_contribution
    ,max_increased_contribution	    	  = p_rec.max_increased_contribution
    ,month1			          = p_rec.month1
    ,month1_min_contribution    	  = p_rec.month1_min_contribution
    ,month1_max_contribution      	  = p_rec.month1_max_contribution
    ,month2			    	  = p_rec.month2
    ,month2_min_contribution	    	  = p_rec.month2_min_contribution
    ,month2_max_contribution	    	  = p_rec.month2_max_contribution
    ,employee_contribution	    	  = p_rec.employee_contribution
    ,contribution_level_type            		  = p_rec.contribution_level_type
    where   soc_ins_contr_lvls_id = p_rec.soc_ins_contr_lvls_id
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
    hr_cle_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_cle_shd.constraint_error
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
  (p_rec                      in out nocopy hr_cle_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode in     varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_cle_upd.dt_update_dml
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
  (p_rec                     in out nocopy     hr_cle_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode in     varchar2
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
    hr_cle_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.soc_ins_contr_lvls_id
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
      hr_cle_del.delete_dml
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
    hr_cle_ins.insert_dml
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
  (p_rec                   in out nocopy hr_cle_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode in     varchar2
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
  (p_rec                   in hr_cle_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode in     varchar2
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
    hr_cle_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_soc_ins_contr_lvls_id
      => p_rec.soc_ins_contr_lvls_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_normal_percentage
      => p_rec.normal_percentage
      ,p_normal_amount
      => p_rec.normal_amount
      ,p_increased_percentage
      => p_rec.increased_percentage
      ,p_increased_amount
      => p_rec.increased_amount
      ,p_reduced_percentage
      => p_rec.reduced_percentage
      ,p_reduced_amount
      => p_rec.reduced_amount
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
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
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_flat_tax_limit_per_month
       => p_rec.flat_tax_limit_per_month
      ,p_flat_tax_limit_per_year
       => p_rec.flat_tax_limit_per_year
      ,p_min_increased_contribution
       => p_rec.min_increased_contribution
      ,p_max_increased_contribution
       => p_rec.max_increased_contribution
      ,p_month1
       => p_rec.month1
      ,p_month1_min_contribution
       => p_rec.month1_min_contribution
      ,p_month1_max_contribution
       => p_rec.month1_max_contribution
      ,p_month2
       => p_rec.month2
      ,p_month2_min_contribution
       => p_rec.month2_min_contribution
      ,p_month2_max_contribution
       => p_rec.month2_max_contribution
      ,p_employee_contribution
        => p_rec.employee_contribution
      ,p_contribution_level_type
       => p_rec.contribution_level_type
      ,p_organization_id_o
      => hr_cle_shd.g_old_rec.organization_id
      ,p_normal_percentage_o
      => hr_cle_shd.g_old_rec.normal_percentage
      ,p_normal_amount_o
      => hr_cle_shd.g_old_rec.normal_amount
      ,p_increased_percentage_o
      => hr_cle_shd.g_old_rec.increased_percentage
      ,p_increased_amount_o
      => hr_cle_shd.g_old_rec.increased_amount
      ,p_reduced_percentage_o
      => hr_cle_shd.g_old_rec.reduced_percentage
      ,p_reduced_amount_o
      => hr_cle_shd.g_old_rec.reduced_amount
      ,p_effective_start_date_o
      => hr_cle_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => hr_cle_shd.g_old_rec.effective_end_date
      ,p_attribute_category_o
      => hr_cle_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => hr_cle_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => hr_cle_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => hr_cle_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => hr_cle_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => hr_cle_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => hr_cle_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => hr_cle_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => hr_cle_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => hr_cle_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => hr_cle_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => hr_cle_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => hr_cle_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => hr_cle_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => hr_cle_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => hr_cle_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => hr_cle_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => hr_cle_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => hr_cle_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => hr_cle_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => hr_cle_shd.g_old_rec.attribute20
      ,p_object_version_number_o
      => hr_cle_shd.g_old_rec.object_version_number
      ,p_attribute21_o
      => hr_cle_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => hr_cle_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => hr_cle_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => hr_cle_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => hr_cle_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => hr_cle_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => hr_cle_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => hr_cle_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => hr_cle_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => hr_cle_shd.g_old_rec.attribute30
      ,p_flat_tax_limit_per_month_o
       => hr_cle_shd.g_old_rec.flat_tax_limit_per_month
      ,p_flat_tax_limit_per_year_o
       => hr_cle_shd.g_old_rec.flat_tax_limit_per_year
      ,p_min_increased_contribution_o
       => hr_cle_shd.g_old_rec.min_increased_contribution
      ,p_max_increased_contribution_o
       => hr_cle_shd.g_old_rec.max_increased_contribution
      ,p_month1_o
       => hr_cle_shd.g_old_rec.month1
      ,p_month1_min_contribution_o
       => hr_cle_shd.g_old_rec.month1_min_contribution
      ,p_month1_max_contribution_o
       => hr_cle_shd.g_old_rec.month1_max_contribution
      ,p_month2_o
       => hr_cle_shd.g_old_rec.month2
      ,p_month2_min_contribution_o
       => hr_cle_shd.g_old_rec.month2_min_contribution
      ,p_month2_max_contribution_o
       => hr_cle_shd.g_old_rec.month2_max_contribution
      ,p_employee_contribution_o
        => hr_cle_shd.g_old_rec.employee_contribution
      ,p_contribution_level_type_o
       => hr_cle_shd.g_old_rec.contribution_level_type
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_DE_SOC_INS_CONTR_LVLS_F'
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
  (p_rec in out nocopy hr_cle_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    hr_cle_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.normal_percentage = hr_api.g_number) then
    p_rec.normal_percentage :=
    hr_cle_shd.g_old_rec.normal_percentage;
  End If;
  If (p_rec.normal_amount = hr_api.g_number) then
    p_rec.normal_amount :=
    hr_cle_shd.g_old_rec.normal_amount;
  End If;
  If (p_rec.increased_percentage = hr_api.g_number) then
    p_rec.increased_percentage :=
    hr_cle_shd.g_old_rec.increased_percentage;
  End If;
  If (p_rec.increased_amount = hr_api.g_number) then
    p_rec.increased_amount :=
    hr_cle_shd.g_old_rec.increased_amount;
  End If;
  If (p_rec.reduced_percentage = hr_api.g_number) then
    p_rec.reduced_percentage :=
    hr_cle_shd.g_old_rec.reduced_percentage;
  End If;
  If (p_rec.reduced_amount = hr_api.g_number) then
    p_rec.reduced_amount :=
    hr_cle_shd.g_old_rec.reduced_amount;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    hr_cle_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    hr_cle_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    hr_cle_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    hr_cle_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    hr_cle_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    hr_cle_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    hr_cle_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    hr_cle_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    hr_cle_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    hr_cle_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    hr_cle_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    hr_cle_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    hr_cle_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    hr_cle_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    hr_cle_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    hr_cle_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    hr_cle_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    hr_cle_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    hr_cle_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    hr_cle_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    hr_cle_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    hr_cle_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    hr_cle_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    hr_cle_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    hr_cle_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    hr_cle_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    hr_cle_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    hr_cle_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    hr_cle_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    hr_cle_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    hr_cle_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.flat_tax_limit_per_month= hr_api.g_number) then
    p_rec.flat_tax_limit_per_month :=
    hr_cle_shd.g_old_rec.flat_tax_limit_per_month;
  End If;
  If (p_rec.flat_tax_limit_per_year = hr_api.g_number) then
    p_rec.flat_tax_limit_per_year :=
    hr_cle_shd.g_old_rec.flat_tax_limit_per_year;
  End If;
  If (p_rec.min_increased_contribution= hr_api.g_number) then
    p_rec.min_increased_contribution :=
    hr_cle_shd.g_old_rec.min_increased_contribution;
  End If;
  If (p_rec.max_increased_contribution= hr_api.g_number) then
    p_rec.max_increased_contribution :=
    hr_cle_shd.g_old_rec.max_increased_contribution;
  End If;
  If (p_rec.month1= hr_api.g_varchar2) then
    p_rec.month1 :=
    hr_cle_shd.g_old_rec.month1;
  End If;
  If (p_rec.month1_min_contribution= hr_api.g_number) then
    p_rec.month1_min_contribution  :=
    hr_cle_shd.g_old_rec.month1_min_contribution;
  End If;
  If (p_rec.month1_max_contribution= hr_api.g_number) then
    p_rec.month1_max_contribution       :=
    hr_cle_shd.g_old_rec.month1_max_contribution;
  End If;
  If (p_rec.month2= hr_api.g_varchar2) then
    p_rec.month2 :=
    hr_cle_shd.g_old_rec.month2;
  End If;
  If (p_rec.month2_min_contribution = hr_api.g_number) then
    p_rec.month2_min_contribution :=
    hr_cle_shd.g_old_rec.month2_min_contribution;
  End If;
  If (p_rec.month2_max_contribution = hr_api.g_number) then
    p_rec.month2_max_contribution :=
    hr_cle_shd.g_old_rec.month2_max_contribution;
  End If;
  If (p_rec.employee_contribution= hr_api.g_number) then
    p_rec.employee_contribution	  :=
    hr_cle_shd.g_old_rec.employee_contribution;
  End If;
  If (p_rec.contribution_level_type = hr_api.g_varchar2) then
    p_rec.contribution_level_type    :=
    hr_cle_shd.g_old_rec.contribution_level_type;
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
  ,p_rec            in out nocopy hr_cle_shd.g_rec_type
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
  hr_cle_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_soc_ins_contr_lvls_id            => p_rec.soc_ins_contr_lvls_id
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
  hr_cle_upd.convert_defs(p_rec);
  --
  hr_cle_bus.update_validate
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
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_soc_ins_contr_lvls_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_normal_percentage            in     number    default hr_api.g_number
  ,p_increased_percentage         in     number    default hr_api.g_number
  ,p_reduced_percentage           in     number    default hr_api.g_number
  ,p_normal_amount                in     number    default hr_api.g_number
  ,p_increased_amount             in     number    default hr_api.g_number
  ,p_reduced_amount               in     number    default hr_api.g_number
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
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_flat_tax_limit_per_month	  in     number    default hr_api.g_number
  ,p_flat_tax_limit_per_year	  in     number    default hr_api.g_number
  ,p_min_increased_contribution   in     number    default hr_api.g_number
  ,p_max_increased_contribution   in     number    default hr_api.g_number
  ,p_month1			  in     varchar2  default hr_api.g_varchar2
  ,p_month1_min_contribution      in     number    default hr_api.g_number
  ,p_month1_max_contribution      in     number    default hr_api.g_number
  ,p_month2			  in     varchar2  default hr_api.g_varchar2
  ,p_month2_min_contribution      in     number    default hr_api.g_number
  ,p_month2_max_contribution      in     number    default hr_api.g_number
  ,p_employee_contribution	  in     number    default hr_api.g_number
  ,p_contribution_level_type  		  in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
--
  l_rec         hr_cle_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_cle_shd.convert_args
    (p_soc_ins_contr_lvls_id
    ,p_organization_id
    ,p_normal_percentage
    ,p_normal_amount
    ,p_increased_percentage
    ,p_increased_amount
    ,p_reduced_percentage
    ,p_reduced_amount
    ,null
    ,null
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
    ,p_object_version_number
    ,p_attribute21
    ,p_attribute22
    ,p_attribute23
    ,p_attribute24
    ,p_attribute25
    ,p_attribute26
    ,p_attribute27
    ,p_attribute28
    ,p_attribute29
    ,p_attribute30
    ,p_flat_tax_limit_per_month
    ,p_flat_tax_limit_per_year
    ,p_min_increased_contribution
    ,p_max_increased_contribution
    ,p_month1
    ,p_month1_min_contribution
    ,p_month1_max_contribution
    ,p_month2
    ,p_month2_min_contribution
    ,p_month2_max_contribution
    ,p_employee_contribution
    ,p_contribution_level_type
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_cle_upd.upd
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
end hr_cle_upd;

/