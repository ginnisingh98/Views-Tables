--------------------------------------------------------
--  DDL for Package Body PQH_ACC_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ACC_DEL" as
/* $Header: pqaccrhi.pkb 115.4 2004/03/15 23:54:54 svorugan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_acc_del.';  -- Global package name
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
  (p_rec                     in out nocopy pqh_acc_shd.g_rec_type
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
    delete from pqh_accommodations_f
    where       accommodation_id = p_rec.accommodation_id
    and   effective_start_date = p_validation_start_date;
    --
    --
  Else
    --
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pqh_accommodations_f
    where        accommodation_id = p_rec.accommodation_id
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
  (p_rec                     in out nocopy pqh_acc_shd.g_rec_type
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
  pqh_acc_del.dt_delete_dml
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
  (p_rec                     in out nocopy pqh_acc_shd.g_rec_type
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
      := pqh_acc_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pqh_acc_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.accommodation_id
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
  (p_rec                   in out nocopy pqh_acc_shd.g_rec_type
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
  pqh_acc_del.dt_pre_delete
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
  (p_rec                   in pqh_acc_shd.g_rec_type
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
    pqh_acc_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_accommodation_id
      => p_rec.accommodation_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_accommodation_name_o
      => pqh_acc_shd.g_old_rec.accommodation_name
      ,p_effective_start_date_o
      => pqh_acc_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pqh_acc_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => pqh_acc_shd.g_old_rec.business_group_id
      ,p_location_id_o
      => pqh_acc_shd.g_old_rec.location_id
      ,p_accommodation_desc_o
      => pqh_acc_shd.g_old_rec.accommodation_desc
      ,p_accommodation_type_o
      => pqh_acc_shd.g_old_rec.accommodation_type
      ,p_style_o
      => pqh_acc_shd.g_old_rec.style
      ,p_address_line_1_o
      => pqh_acc_shd.g_old_rec.address_line_1
      ,p_address_line_2_o
      => pqh_acc_shd.g_old_rec.address_line_2
      ,p_address_line_3_o
      => pqh_acc_shd.g_old_rec.address_line_3
      ,p_town_or_city_o
      => pqh_acc_shd.g_old_rec.town_or_city
      ,p_country_o
      => pqh_acc_shd.g_old_rec.country
      ,p_postal_code_o
      => pqh_acc_shd.g_old_rec.postal_code
      ,p_region_1_o
      => pqh_acc_shd.g_old_rec.region_1
      ,p_region_2_o
      => pqh_acc_shd.g_old_rec.region_2
      ,p_region_3_o
      => pqh_acc_shd.g_old_rec.region_3
      ,p_telephone_number_1_o
      => pqh_acc_shd.g_old_rec.telephone_number_1
      ,p_telephone_number_2_o
      => pqh_acc_shd.g_old_rec.telephone_number_2
      ,p_telephone_number_3_o
      => pqh_acc_shd.g_old_rec.telephone_number_3
      ,p_floor_number_o
      => pqh_acc_shd.g_old_rec.floor_number
      ,p_floor_area_o
      => pqh_acc_shd.g_old_rec.floor_area
      ,p_floor_area_measure_unit_o
      => pqh_acc_shd.g_old_rec.floor_area_measure_unit
      ,p_main_rooms_o
      => pqh_acc_shd.g_old_rec.main_rooms
      ,p_family_size_o
      => pqh_acc_shd.g_old_rec.family_size
      ,p_suitability_disabled_o
      => pqh_acc_shd.g_old_rec.suitability_disabled
      ,p_rental_value_o
      => pqh_acc_shd.g_old_rec.rental_value
      ,p_rental_value_currency_o
      => pqh_acc_shd.g_old_rec.rental_value_currency
      ,p_owner_o
      => pqh_acc_shd.g_old_rec.owner
      ,p_comments_o
      => pqh_acc_shd.g_old_rec.comments
      ,p_information_category_o
      => pqh_acc_shd.g_old_rec.information_category
      ,p_information1_o
      => pqh_acc_shd.g_old_rec.information1
      ,p_information2_o
      => pqh_acc_shd.g_old_rec.information2
      ,p_information3_o
      => pqh_acc_shd.g_old_rec.information3
      ,p_information4_o
      => pqh_acc_shd.g_old_rec.information4
      ,p_information5_o
      => pqh_acc_shd.g_old_rec.information5
      ,p_information6_o
      => pqh_acc_shd.g_old_rec.information6
      ,p_information7_o
      => pqh_acc_shd.g_old_rec.information7
      ,p_information8_o
      => pqh_acc_shd.g_old_rec.information8
      ,p_information9_o
      => pqh_acc_shd.g_old_rec.information9
      ,p_information10_o
      => pqh_acc_shd.g_old_rec.information10
      ,p_information11_o
      => pqh_acc_shd.g_old_rec.information11
      ,p_information12_o
      => pqh_acc_shd.g_old_rec.information12
      ,p_information13_o
      => pqh_acc_shd.g_old_rec.information13
      ,p_information14_o
      => pqh_acc_shd.g_old_rec.information14
      ,p_information15_o
      => pqh_acc_shd.g_old_rec.information15
      ,p_information16_o
      => pqh_acc_shd.g_old_rec.information16
      ,p_information17_o
      => pqh_acc_shd.g_old_rec.information17
      ,p_information18_o
      => pqh_acc_shd.g_old_rec.information18
      ,p_information19_o
      => pqh_acc_shd.g_old_rec.information19
      ,p_information20_o
      => pqh_acc_shd.g_old_rec.information20
      ,p_information21_o
      => pqh_acc_shd.g_old_rec.information21
      ,p_information22_o
      => pqh_acc_shd.g_old_rec.information22
      ,p_information23_o
      => pqh_acc_shd.g_old_rec.information23
      ,p_information24_o
      => pqh_acc_shd.g_old_rec.information24
      ,p_information25_o
      => pqh_acc_shd.g_old_rec.information25
      ,p_information26_o
      => pqh_acc_shd.g_old_rec.information26
      ,p_information27_o
      => pqh_acc_shd.g_old_rec.information27
      ,p_information28_o
      => pqh_acc_shd.g_old_rec.information28
      ,p_information29_o
      => pqh_acc_shd.g_old_rec.information29
      ,p_information30_o
      => pqh_acc_shd.g_old_rec.information30
      ,p_attribute_category_o
      => pqh_acc_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pqh_acc_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pqh_acc_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pqh_acc_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pqh_acc_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pqh_acc_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pqh_acc_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pqh_acc_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pqh_acc_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pqh_acc_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pqh_acc_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pqh_acc_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pqh_acc_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pqh_acc_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pqh_acc_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pqh_acc_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pqh_acc_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pqh_acc_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pqh_acc_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pqh_acc_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pqh_acc_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => pqh_acc_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => pqh_acc_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => pqh_acc_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => pqh_acc_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => pqh_acc_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => pqh_acc_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => pqh_acc_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => pqh_acc_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => pqh_acc_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => pqh_acc_shd.g_old_rec.attribute30
      ,p_object_version_number_o
      => pqh_acc_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_ACCOMMODATIONS_F'
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
  ,p_rec            in out nocopy pqh_acc_shd.g_rec_type
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
  pqh_acc_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_accommodation_id                 => p_rec.accommodation_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  pqh_acc_bus.delete_validate
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
  pqh_acc_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pqh_acc_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pqh_acc_del.post_delete
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
  ,p_accommodation_id                 in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ) is
--
  l_rec         pqh_acc_shd.g_rec_type;
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
  l_rec.accommodation_id          := p_accommodation_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_acc_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqh_acc_del.del
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
end pqh_acc_del;

/
