--------------------------------------------------------
--  DDL for Package Body PER_PTU_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PTU_DEL" as
/* $Header: pepturhi.pkb 120.0 2005/05/31 15:57:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ptu_del.';  -- Global package name
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
--   1) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   2) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   3) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
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
   (p_rec          in out nocopy per_ptu_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from per_person_type_usages_f
    where       person_type_usage_id = p_rec.person_type_usage_id
    and    effective_start_date = p_validation_start_date;
    --
  Else
    hr_utility.set_location(l_proc, 15);
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from per_person_type_usages_f
    where        person_type_usage_id = p_rec.person_type_usage_id
    and    effective_start_date >= p_validation_start_date;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
   (p_rec          in out nocopy per_ptu_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec         => p_rec,
      p_effective_date  => p_effective_date,
      p_datetrack_mode  => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
      p_validation_end_date   => p_validation_end_date);
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
--   A Pl/Sql record structre.
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
   (p_rec          in out nocopy per_ptu_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := per_ptu_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    per_ptu_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date,
       p_base_key_value         => p_rec.person_type_usage_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date  => p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
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
--   A Pl/Sql record structre.
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
   (p_rec          in out nocopy per_ptu_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec          => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
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
   (p_rec          in per_ptu_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Start of API User Hook for post_delete.
  begin
    per_ptu_rkd.after_delete
      (
           p_person_type_usage_id   => p_rec.person_type_usage_id,
           p_person_id_o        => per_ptu_shd.g_old_rec.person_id,
           p_person_type_id_o    => per_ptu_shd.g_old_rec.person_type_id,
           p_effective_start_date_o
                         => per_ptu_shd.g_old_rec.effective_start_date,
           p_effective_end_date_o => per_ptu_shd.g_old_rec.effective_end_date,
           p_object_version_number_o
                         => per_ptu_shd.g_old_rec.object_version_number,
           p_request_id_o         => per_ptu_shd.g_old_rec.request_id,
           p_program_application_id_o
                      => per_ptu_shd.g_old_rec.program_application_id,
           p_program_id_o     => per_ptu_shd.g_old_rec.program_id,
           p_program_update_date_o => per_ptu_shd.g_old_rec.program_update_date
     ,p_attribute_category_o  => per_ptu_shd.g_old_rec.attribute_category
     ,p_attribute1_o          => per_ptu_shd.g_old_rec.attribute1
     ,p_attribute2_o          => per_ptu_shd.g_old_rec.attribute2
     ,p_attribute3_o          => per_ptu_shd.g_old_rec.attribute3
     ,p_attribute4_o          => per_ptu_shd.g_old_rec.attribute4
     ,p_attribute5_o          => per_ptu_shd.g_old_rec.attribute5
     ,p_attribute6_o          => per_ptu_shd.g_old_rec.attribute6
     ,p_attribute7_o          => per_ptu_shd.g_old_rec.attribute7
     ,p_attribute8_o          => per_ptu_shd.g_old_rec.attribute8
     ,p_attribute9_o          => per_ptu_shd.g_old_rec.attribute9
     ,p_attribute10_o         => per_ptu_shd.g_old_rec.attribute10
     ,p_attribute11_o         => per_ptu_shd.g_old_rec.attribute11
     ,p_attribute12_o         => per_ptu_shd.g_old_rec.attribute12
     ,p_attribute13_o         => per_ptu_shd.g_old_rec.attribute13
     ,p_attribute14_o         => per_ptu_shd.g_old_rec.attribute14
     ,p_attribute15_o         => per_ptu_shd.g_old_rec.attribute15
     ,p_attribute16_o         => per_ptu_shd.g_old_rec.attribute16
     ,p_attribute17_o         => per_ptu_shd.g_old_rec.attribute17
     ,p_attribute18_o         => per_ptu_shd.g_old_rec.attribute18
     ,p_attribute19_o         => per_ptu_shd.g_old_rec.attribute19
     ,p_attribute20_o         => per_ptu_shd.g_old_rec.attribute20
     ,p_attribute21_o         => per_ptu_shd.g_old_rec.attribute21
     ,p_attribute22_o         => per_ptu_shd.g_old_rec.attribute22
     ,p_attribute23_o         => per_ptu_shd.g_old_rec.attribute23
     ,p_attribute24_o         => per_ptu_shd.g_old_rec.attribute24
     ,p_attribute25_o         => per_ptu_shd.g_old_rec.attribute25
     ,p_attribute26_o         => per_ptu_shd.g_old_rec.attribute26
     ,p_attribute27_o         => per_ptu_shd.g_old_rec.attribute27
     ,p_attribute28_o         => per_ptu_shd.g_old_rec.attribute28
     ,p_attribute29_o         => per_ptu_shd.g_old_rec.attribute29
     ,p_attribute30_o         => per_ptu_shd.g_old_rec.attribute30,
           p_effective_date        => p_effective_date,
           p_datetrack_mode        => p_datetrack_mode,
           p_validation_start_date => p_validation_start_date,
           p_validation_end_date   => p_validation_end_date,
           p_effective_start_date  => p_rec.effective_start_date,
           p_effective_end_date    => p_rec.effective_end_date,
           p_object_version_number => p_rec.object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PERSON_TYPE_USAGES_F'
        ,p_hook_type   => 'AD'
        );
  end;
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec        in out nocopy  per_ptu_shd.g_rec_type,
  p_effective_date   in    date,
  p_datetrack_mode   in    varchar2
  ) is
--
  l_proc       varchar2(72) := g_package||'del';
  l_validation_start_date  date;
  l_validation_end_date    date;
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
  per_ptu_shd.lck
   (p_effective_date  => p_effective_date,
          p_datetrack_mode  => p_datetrack_mode,
          p_person_type_usage_id  => p_rec.person_type_usage_id,
          p_object_version_number => p_rec.object_version_number,
          p_validation_start_date => l_validation_start_date,
          p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  per_ptu_bus.delete_validate
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_person_type_usage_id     in   number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date       out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date     in     date,
  p_datetrack_mode     in     varchar2
  ) is
--
  l_rec     per_ptu_shd.g_rec_type;
  l_proc varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.person_type_usage_id     := p_person_type_usage_id;
  l_rec.object_version_number    := p_object_version_number;
  --
  -- Having converted the arguments into the per_ptu_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_ptu_del;

/
