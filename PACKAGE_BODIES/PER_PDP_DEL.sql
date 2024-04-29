--------------------------------------------------------
--  DDL for Package Body PER_PDP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDP_DEL" as
/* $Header: pepdprhi.pkb 115.8 2004/01/29 05:53:10 adudekul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pdp_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in per_pdp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_periods_of_placement row.
  --
  delete from per_periods_of_placement
  where period_of_placement_id = p_rec.period_of_placement_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_pdp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End delete_dml;
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
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in per_pdp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
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
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in per_pdp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pdp_rkd.after_delete
      (p_object_version_number_o
      => per_pdp_shd.g_old_rec.object_version_number
      ,p_business_group_id_o
      => per_pdp_shd.g_old_rec.business_group_id
      ,p_person_id_o
      => per_pdp_shd.g_old_rec.person_id
      ,p_date_start_o
      => per_pdp_shd.g_old_rec.date_start
      ,p_actual_termination_date_o
      => per_pdp_shd.g_old_rec.actual_termination_date
      ,p_projected_termination_date_o
      => per_pdp_shd.g_old_rec.projected_termination_date
      ,p_termination_reason_o
      => per_pdp_shd.g_old_rec.termination_reason
      ,p_attribute_category_o
      => per_pdp_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_pdp_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_pdp_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_pdp_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_pdp_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_pdp_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_pdp_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_pdp_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_pdp_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_pdp_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_pdp_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_pdp_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_pdp_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_pdp_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_pdp_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_pdp_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_pdp_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_pdp_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_pdp_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_pdp_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_pdp_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => per_pdp_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => per_pdp_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => per_pdp_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => per_pdp_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => per_pdp_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => per_pdp_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => per_pdp_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => per_pdp_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => per_pdp_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => per_pdp_shd.g_old_rec.attribute30
      ,p_information_category_o
      => per_pdp_shd.g_old_rec.information_category
      ,p_information1_o
      => per_pdp_shd.g_old_rec.information1
      ,p_information2_o
      => per_pdp_shd.g_old_rec.information2
      ,p_information3_o
      => per_pdp_shd.g_old_rec.information3
      ,p_information4_o
      => per_pdp_shd.g_old_rec.information4
      ,p_information5_o
      => per_pdp_shd.g_old_rec.information5
      ,p_information6_o
      => per_pdp_shd.g_old_rec.information6
      ,p_information7_o
      => per_pdp_shd.g_old_rec.information7
      ,p_information8_o
      => per_pdp_shd.g_old_rec.information8
      ,p_information9_o
      => per_pdp_shd.g_old_rec.information9
      ,p_information10_o
      => per_pdp_shd.g_old_rec.information10
      ,p_information11_o
      => per_pdp_shd.g_old_rec.information11
      ,p_information12_o
      => per_pdp_shd.g_old_rec.information12
      ,p_information13_o
      => per_pdp_shd.g_old_rec.information13
      ,p_information14_o
      => per_pdp_shd.g_old_rec.information14
      ,p_information15_o
      => per_pdp_shd.g_old_rec.information15
      ,p_information16_o
      => per_pdp_shd.g_old_rec.information16
      ,p_information17_o
      => per_pdp_shd.g_old_rec.information17
      ,p_information18_o
      => per_pdp_shd.g_old_rec.information18
      ,p_information19_o
      => per_pdp_shd.g_old_rec.information19
      ,p_information20_o
      => per_pdp_shd.g_old_rec.information20
      ,p_information21_o
      => per_pdp_shd.g_old_rec.information21
      ,p_information22_o
      => per_pdp_shd.g_old_rec.information22
      ,p_information23_o
      => per_pdp_shd.g_old_rec.information23
      ,p_information24_o
      => per_pdp_shd.g_old_rec.information24
      ,p_information25_o
      => per_pdp_shd.g_old_rec.information25
      ,p_information26_o
      => per_pdp_shd.g_old_rec.information26
      ,p_information27_o
      => per_pdp_shd.g_old_rec.information27
      ,p_information28_o
      => per_pdp_shd.g_old_rec.information28
      ,p_information29_o
      => per_pdp_shd.g_old_rec.information29
      ,p_information30_o
      => per_pdp_shd.g_old_rec.information30
      ,p_final_process_date_o
      => per_pdp_shd.g_old_rec.final_process_date
      ,p_last_standard_process_date_o
      => per_pdp_shd.g_old_rec.last_standard_process_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PERIODS_OF_PLACEMENT'
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
  (p_rec              in per_pdp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_pdp_shd.lck
    (p_rec.period_of_placement_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_pdp_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_pdp_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_pdp_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_pdp_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_person_id                            in     number
  ,p_date_start                           in     date
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_pdp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
  l_period_of_placement_id  number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- The sequence key period_of_placement_id is hidden from the user
  -- because they should be using the user key person_id and date_start.
  -- To prevent confusion, period_of_placement_id is not passed in del
  -- so is instead queried from the database.
  --
  l_period_of_placement_id := per_pdp_bus.return_period_of_placement_id
    (p_person_id            => p_person_id
    ,p_date_start           => p_date_start);

  hr_utility.trace ('period_of_placement_id: '
                   ||to_char(l_period_of_placement_id));

  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.period_of_placement_id := l_period_of_placement_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_pdp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_pdp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_pdp_del;

/
