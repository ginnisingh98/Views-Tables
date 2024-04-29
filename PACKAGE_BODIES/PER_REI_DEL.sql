--------------------------------------------------------
--  DDL for Package Body PER_REI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REI_DEL" as
/* $Header: pereirhi.pkb 115.6 2003/10/07 19:01:25 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rei_del.';  -- Global package name
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
  (p_rec                     in out nocopy per_rei_shd.g_rec_type
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
    per_rei_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from per_contact_extra_info_f
    where       contact_extra_info_id = p_rec.contact_extra_info_id
    and   effective_start_date = p_validation_start_date;
    --
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    per_rei_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from per_contact_extra_info_f
    where        contact_extra_info_id = p_rec.contact_extra_info_id
    and   effective_start_date >= p_validation_start_date;
    --
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy per_rei_shd.g_rec_type
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
  per_rei_del.dt_delete_dml
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
  (p_rec                     in out nocopy per_rei_shd.g_rec_type
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
      := per_rei_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    per_rei_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.contact_extra_info_id
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
  (p_rec                   in out nocopy per_rei_shd.g_rec_type
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
  per_rei_del.dt_pre_delete
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
  (p_rec                   in per_rei_shd.g_rec_type
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
    per_rei_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_contact_extra_info_id
      => p_rec.contact_extra_info_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_effective_start_date_o
      => per_rei_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => per_rei_shd.g_old_rec.effective_end_date
      ,p_contact_relationship_id_o
      => per_rei_shd.g_old_rec.contact_relationship_id
      ,p_information_type_o
      => per_rei_shd.g_old_rec.information_type
      ,p_cei_information_category_o
      => per_rei_shd.g_old_rec.cei_information_category
      ,p_cei_information1_o
      => per_rei_shd.g_old_rec.cei_information1
      ,p_cei_information2_o
      => per_rei_shd.g_old_rec.cei_information2
      ,p_cei_information3_o
      => per_rei_shd.g_old_rec.cei_information3
      ,p_cei_information4_o
      => per_rei_shd.g_old_rec.cei_information4
      ,p_cei_information5_o
      => per_rei_shd.g_old_rec.cei_information5
      ,p_cei_information6_o
      => per_rei_shd.g_old_rec.cei_information6
      ,p_cei_information7_o
      => per_rei_shd.g_old_rec.cei_information7
      ,p_cei_information8_o
      => per_rei_shd.g_old_rec.cei_information8
      ,p_cei_information9_o
      => per_rei_shd.g_old_rec.cei_information9
      ,p_cei_information10_o
      => per_rei_shd.g_old_rec.cei_information10
      ,p_cei_information11_o
      => per_rei_shd.g_old_rec.cei_information11
      ,p_cei_information12_o
      => per_rei_shd.g_old_rec.cei_information12
      ,p_cei_information13_o
      => per_rei_shd.g_old_rec.cei_information13
      ,p_cei_information14_o
      => per_rei_shd.g_old_rec.cei_information14
      ,p_cei_information15_o
      => per_rei_shd.g_old_rec.cei_information15
      ,p_cei_information16_o
      => per_rei_shd.g_old_rec.cei_information16
      ,p_cei_information17_o
      => per_rei_shd.g_old_rec.cei_information17
      ,p_cei_information18_o
      => per_rei_shd.g_old_rec.cei_information18
      ,p_cei_information19_o
      => per_rei_shd.g_old_rec.cei_information19
      ,p_cei_information20_o
      => per_rei_shd.g_old_rec.cei_information20
      ,p_cei_information21_o
      => per_rei_shd.g_old_rec.cei_information21
      ,p_cei_information22_o
      => per_rei_shd.g_old_rec.cei_information22
      ,p_cei_information23_o
      => per_rei_shd.g_old_rec.cei_information23
      ,p_cei_information24_o
      => per_rei_shd.g_old_rec.cei_information24
      ,p_cei_information25_o
      => per_rei_shd.g_old_rec.cei_information25
      ,p_cei_information26_o
      => per_rei_shd.g_old_rec.cei_information26
      ,p_cei_information27_o
      => per_rei_shd.g_old_rec.cei_information27
      ,p_cei_information28_o
      => per_rei_shd.g_old_rec.cei_information28
      ,p_cei_information29_o
      => per_rei_shd.g_old_rec.cei_information29
      ,p_cei_information30_o
      => per_rei_shd.g_old_rec.cei_information30
      ,p_cei_attribute_category_o
      => per_rei_shd.g_old_rec.cei_attribute_category
      ,p_cei_attribute1_o
      => per_rei_shd.g_old_rec.cei_attribute1
      ,p_cei_attribute2_o
      => per_rei_shd.g_old_rec.cei_attribute2
      ,p_cei_attribute3_o
      => per_rei_shd.g_old_rec.cei_attribute3
      ,p_cei_attribute4_o
      => per_rei_shd.g_old_rec.cei_attribute4
      ,p_cei_attribute5_o
      => per_rei_shd.g_old_rec.cei_attribute5
      ,p_cei_attribute6_o
      => per_rei_shd.g_old_rec.cei_attribute6
      ,p_cei_attribute7_o
      => per_rei_shd.g_old_rec.cei_attribute7
      ,p_cei_attribute8_o
      => per_rei_shd.g_old_rec.cei_attribute8
      ,p_cei_attribute9_o
      => per_rei_shd.g_old_rec.cei_attribute9
      ,p_cei_attribute10_o
      => per_rei_shd.g_old_rec.cei_attribute10
      ,p_cei_attribute11_o
      => per_rei_shd.g_old_rec.cei_attribute11
      ,p_cei_attribute12_o
      => per_rei_shd.g_old_rec.cei_attribute12
      ,p_cei_attribute13_o
      => per_rei_shd.g_old_rec.cei_attribute13
      ,p_cei_attribute14_o
      => per_rei_shd.g_old_rec.cei_attribute14
      ,p_cei_attribute15_o
      => per_rei_shd.g_old_rec.cei_attribute15
      ,p_cei_attribute16_o
      => per_rei_shd.g_old_rec.cei_attribute16
      ,p_cei_attribute17_o
      => per_rei_shd.g_old_rec.cei_attribute17
      ,p_cei_attribute18_o
      => per_rei_shd.g_old_rec.cei_attribute18
      ,p_cei_attribute19_o
      => per_rei_shd.g_old_rec.cei_attribute19
      ,p_cei_attribute20_o
      => per_rei_shd.g_old_rec.cei_attribute20
      ,p_object_version_number_o
      => per_rei_shd.g_old_rec.object_version_number
      ,p_request_id_o
      => per_rei_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_rei_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_rei_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_rei_shd.g_old_rec.program_update_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CONTACT_EXTRA_INFO_F'
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
  ,p_rec            in out nocopy per_rei_shd.g_rec_type
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
  per_rei_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_contact_extra_info_id            => p_rec.contact_extra_info_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  per_rei_bus.delete_validate
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
  per_rei_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  per_rei_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  per_rei_del.post_delete
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
  ,p_contact_extra_info_id            in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ) is
--
  l_rec         per_rei_shd.g_rec_type;
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
  l_rec.contact_extra_info_id          := p_contact_extra_info_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the per_rei_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_rei_del.del
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
end per_rei_del;

/
