--------------------------------------------------------
--  DDL for Package Body PQH_REI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_REI_DEL" as
/* $Header: pqreirhi.pkb 115.3 2002/12/03 20:42:51 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_rei_del.';  -- Global package name
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
  (p_rec in pqh_rei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the pqh_role_extra_info row.
  --
  delete from pqh_role_extra_info
  where role_extra_info_id = p_rec.role_extra_info_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pqh_rei_shd.constraint_error
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
Procedure pre_delete(p_rec in pqh_rei_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pqh_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_rei_rkd.after_delete
      (p_role_extra_info_id       => p_rec.role_extra_info_id
      ,p_role_id_o       => pqh_rei_shd.g_old_rec.role_id
      ,p_information_type_o       => pqh_rei_shd.g_old_rec.information_type
      ,p_request_id_o       => pqh_rei_shd.g_old_rec.request_id
      ,p_program_application_id_o       => pqh_rei_shd.g_old_rec.program_application_id
      ,p_program_id_o       => pqh_rei_shd.g_old_rec.program_id
      ,p_program_update_date_o       => pqh_rei_shd.g_old_rec.program_update_date
      ,p_attribute_category_o       => pqh_rei_shd.g_old_rec.attribute_category
      ,p_attribute1_o       => pqh_rei_shd.g_old_rec.attribute1
      ,p_attribute2_o       => pqh_rei_shd.g_old_rec.attribute2
      ,p_attribute3_o       => pqh_rei_shd.g_old_rec.attribute3
      ,p_attribute4_o       => pqh_rei_shd.g_old_rec.attribute4
      ,p_attribute5_o       => pqh_rei_shd.g_old_rec.attribute5
      ,p_attribute6_o       => pqh_rei_shd.g_old_rec.attribute6
      ,p_attribute7_o       => pqh_rei_shd.g_old_rec.attribute7
      ,p_attribute8_o       => pqh_rei_shd.g_old_rec.attribute8
      ,p_attribute9_o       => pqh_rei_shd.g_old_rec.attribute9
      ,p_attribute10_o      => pqh_rei_shd.g_old_rec.attribute10
      ,p_attribute11_o      => pqh_rei_shd.g_old_rec.attribute11
      ,p_attribute12_o      => pqh_rei_shd.g_old_rec.attribute12
      ,p_attribute13_o      => pqh_rei_shd.g_old_rec.attribute13
      ,p_attribute14_o      => pqh_rei_shd.g_old_rec.attribute14
      ,p_attribute15_o      => pqh_rei_shd.g_old_rec.attribute15
      ,p_attribute16_o      => pqh_rei_shd.g_old_rec.attribute16
      ,p_attribute17_o      => pqh_rei_shd.g_old_rec.attribute17
      ,p_attribute18_o      => pqh_rei_shd.g_old_rec.attribute18
      ,p_attribute19_o      => pqh_rei_shd.g_old_rec.attribute19
      ,p_attribute20_o      => pqh_rei_shd.g_old_rec.attribute20
      ,p_attribute21_o      => pqh_rei_shd.g_old_rec.attribute21
      ,p_attribute22_o      => pqh_rei_shd.g_old_rec.attribute22
      ,p_attribute23_o      => pqh_rei_shd.g_old_rec.attribute23
      ,p_attribute24_o      => pqh_rei_shd.g_old_rec.attribute24
      ,p_attribute25_o      => pqh_rei_shd.g_old_rec.attribute25
      ,p_attribute26_o      => pqh_rei_shd.g_old_rec.attribute26
      ,p_attribute27_o      => pqh_rei_shd.g_old_rec.attribute27
      ,p_attribute28_o      => pqh_rei_shd.g_old_rec.attribute28
      ,p_attribute29_o      => pqh_rei_shd.g_old_rec.attribute29
      ,p_attribute30_o      => pqh_rei_shd.g_old_rec.attribute30
      ,p_information_category_o      => pqh_rei_shd.g_old_rec.information_category
      ,p_information1_o       => pqh_rei_shd.g_old_rec.information1
      ,p_information2_o       => pqh_rei_shd.g_old_rec.information2
      ,p_information3_o       => pqh_rei_shd.g_old_rec.information3
      ,p_information4_o       => pqh_rei_shd.g_old_rec.information4
      ,p_information5_o       => pqh_rei_shd.g_old_rec.information5
      ,p_information6_o       => pqh_rei_shd.g_old_rec.information6
      ,p_information7_o       => pqh_rei_shd.g_old_rec.information7
      ,p_information8_o       => pqh_rei_shd.g_old_rec.information8
      ,p_information9_o       => pqh_rei_shd.g_old_rec.information9
      ,p_information10_o       => pqh_rei_shd.g_old_rec.information10
      ,p_information11_o       => pqh_rei_shd.g_old_rec.information11
      ,p_information12_o       => pqh_rei_shd.g_old_rec.information12
      ,p_information13_o       => pqh_rei_shd.g_old_rec.information13
      ,p_information14_o       => pqh_rei_shd.g_old_rec.information14
      ,p_information15_o       => pqh_rei_shd.g_old_rec.information15
      ,p_information16_o       => pqh_rei_shd.g_old_rec.information16
      ,p_information17_o       => pqh_rei_shd.g_old_rec.information17
      ,p_information18_o       => pqh_rei_shd.g_old_rec.information18
      ,p_information19_o       => pqh_rei_shd.g_old_rec.information19
      ,p_information20_o       => pqh_rei_shd.g_old_rec.information20
      ,p_information21_o       => pqh_rei_shd.g_old_rec.information21
      ,p_information22_o       => pqh_rei_shd.g_old_rec.information22
      ,p_information23_o       => pqh_rei_shd.g_old_rec.information23
      ,p_information24_o       => pqh_rei_shd.g_old_rec.information24
      ,p_information25_o       => pqh_rei_shd.g_old_rec.information25
      ,p_information26_o       => pqh_rei_shd.g_old_rec.information26
      ,p_information27_o       => pqh_rei_shd.g_old_rec.information27
      ,p_information28_o       => pqh_rei_shd.g_old_rec.information28
      ,p_information29_o       => pqh_rei_shd.g_old_rec.information29
      ,p_information30_o       => pqh_rei_shd.g_old_rec.information30
      ,p_object_version_number_o  => pqh_rei_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_ROLE_EXTRA_INFO'
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
  (p_rec              in pqh_rei_shd.g_rec_type
   ,p_validate  in boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_pqh_rei;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  pqh_rei_shd.lck
    (p_rec.role_extra_info_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqh_rei_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pqh_rei_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqh_rei_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqh_rei_del.post_delete(p_rec);
  --

  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_pqh_rei;
End del;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_role_extra_info_id                   in     number
  ,p_object_version_number                in     number
  ,p_validate                           in boolean
  ) is
--
  l_rec   pqh_rei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.role_extra_info_id := p_role_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_rei_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqh_rei_del.del(l_rec,p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_rei_del;

/
