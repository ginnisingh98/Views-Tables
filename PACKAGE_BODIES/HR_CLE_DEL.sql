--------------------------------------------------------
--  DDL for Package Body HR_CLE_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CLE_DEL" as
/* $Header: hrclerhi.pkb 115.6 2002/12/03 09:27:16 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_cle_del.';  -- Global package name
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
  (p_rec                     in out nocopy hr_cle_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in     varchar2
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
    delete from hr_de_soc_ins_contr_lvls_f
    where       soc_ins_contr_lvls_id = p_rec.soc_ins_contr_lvls_id
    and   effective_start_date = p_validation_start_date;
    --
    --
  Else
    --
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from hr_de_soc_ins_contr_lvls_f
    where        soc_ins_contr_lvls_id = p_rec.soc_ins_contr_lvls_id
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
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy hr_cle_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in     varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_cle_del.dt_delete_dml
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
  (p_rec                     in out nocopy hr_cle_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in     varchar2
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
      := hr_cle_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    hr_cle_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.soc_ins_contr_lvls_id
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
  (p_rec                   in out nocopy hr_cle_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in     varchar2
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
  hr_cle_del.dt_pre_delete
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
  (p_rec                   in hr_cle_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in     varchar2
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
    hr_cle_rkd.after_delete
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
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
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
  ,p_rec            in out nocopy hr_cle_shd.g_rec_type
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
 hr_utility.trace('object1' ||p_rec.object_version_number);
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
 hr_utility.trace('object2' ||p_rec.object_version_number);
  --
  -- We must lock the row which we need to delete.
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
  -- Call the supporting delete validate operation
  --
  hr_cle_bus.delete_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting pre-delete operation
  --
  hr_cle_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  hr_cle_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  hr_cle_del.post_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
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
  ,p_soc_ins_contr_lvls_id            in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ) is
--
  l_rec         hr_cle_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
hr_utility.trace('passed' ||p_object_version_number);
  l_rec.soc_ins_contr_lvls_id          := p_soc_ins_contr_lvls_id;
  l_rec.object_version_number          := p_object_version_number;
  --
  -- Having converted the arguments into the hr_cle_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
 hr_utility.trace('object3' ||l_rec.object_version_number);

  hr_cle_del.del
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
end hr_cle_del;

/
