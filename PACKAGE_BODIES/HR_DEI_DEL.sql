--------------------------------------------------------
--  DDL for Package Body HR_DEI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DEI_DEL" as
/* $Header: hrdeirhi.pkb 120.1.12010000.3 2010/05/20 12:01:59 tkghosh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_dei_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
  (p_rec in hr_dei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the hr_document_extra_info row.
  --
  delete from hr_document_extra_info
  where document_extra_info_id = p_rec.document_extra_info_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    hr_dei_shd.constraint_error
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
Procedure pre_delete(p_rec in hr_dei_shd.g_rec_type) is
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
Procedure post_delete(p_rec in hr_dei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_dei_rkd.after_delete
      (p_document_extra_info_id
      => p_rec.document_extra_info_id
      ,p_person_id_o
      => hr_dei_shd.g_old_rec.person_id
      ,p_document_type_id_o
      => hr_dei_shd.g_old_rec.document_type_id
      ,p_document_number_o
      => hr_dei_shd.g_old_rec.document_number
      ,p_date_from_o
      => hr_dei_shd.g_old_rec.date_from
      ,p_date_to_o
      => hr_dei_shd.g_old_rec.date_to
      ,p_issued_by_o
      => hr_dei_shd.g_old_rec.issued_by
      ,p_issued_at_o
      => hr_dei_shd.g_old_rec.issued_at
      ,p_issued_date_o
      => hr_dei_shd.g_old_rec.issued_date
      ,p_issuing_authority_o
      => hr_dei_shd.g_old_rec.issuing_authority
      ,p_verified_by_o
      => hr_dei_shd.g_old_rec.verified_by
      ,p_verified_date_o
      => hr_dei_shd.g_old_rec.verified_date
      ,p_related_object_name_o
      => hr_dei_shd.g_old_rec.related_object_name
      ,p_related_object_id_col_o
      => hr_dei_shd.g_old_rec.related_object_id_col
      ,p_related_object_id_o
      => hr_dei_shd.g_old_rec.related_object_id
      ,p_dei_attribute_category_o
      => hr_dei_shd.g_old_rec.dei_attribute_category
      ,p_dei_attribute1_o
      => hr_dei_shd.g_old_rec.dei_attribute1
      ,p_dei_attribute2_o
      => hr_dei_shd.g_old_rec.dei_attribute2
      ,p_dei_attribute3_o
      => hr_dei_shd.g_old_rec.dei_attribute3
      ,p_dei_attribute4_o
      => hr_dei_shd.g_old_rec.dei_attribute4
      ,p_dei_attribute5_o
      => hr_dei_shd.g_old_rec.dei_attribute5
      ,p_dei_attribute6_o
      => hr_dei_shd.g_old_rec.dei_attribute6
      ,p_dei_attribute7_o
      => hr_dei_shd.g_old_rec.dei_attribute7
      ,p_dei_attribute8_o
      => hr_dei_shd.g_old_rec.dei_attribute8
      ,p_dei_attribute9_o
      => hr_dei_shd.g_old_rec.dei_attribute9
      ,p_dei_attribute10_o
      => hr_dei_shd.g_old_rec.dei_attribute10
      ,p_dei_attribute11_o
      => hr_dei_shd.g_old_rec.dei_attribute11
      ,p_dei_attribute12_o
      => hr_dei_shd.g_old_rec.dei_attribute12
      ,p_dei_attribute13_o
      => hr_dei_shd.g_old_rec.dei_attribute13
      ,p_dei_attribute14_o
      => hr_dei_shd.g_old_rec.dei_attribute14
      ,p_dei_attribute15_o
      => hr_dei_shd.g_old_rec.dei_attribute15
      ,p_dei_attribute16_o
      => hr_dei_shd.g_old_rec.dei_attribute16
      ,p_dei_attribute17_o
      => hr_dei_shd.g_old_rec.dei_attribute17
      ,p_dei_attribute18_o
      => hr_dei_shd.g_old_rec.dei_attribute18
      ,p_dei_attribute19_o
      => hr_dei_shd.g_old_rec.dei_attribute19
      ,p_dei_attribute20_o
      => hr_dei_shd.g_old_rec.dei_attribute20
      ,p_dei_attribute21_o
      => hr_dei_shd.g_old_rec.dei_attribute21
      ,p_dei_attribute22_o
      => hr_dei_shd.g_old_rec.dei_attribute22
      ,p_dei_attribute23_o
      => hr_dei_shd.g_old_rec.dei_attribute23
      ,p_dei_attribute24_o
      => hr_dei_shd.g_old_rec.dei_attribute24
      ,p_dei_attribute25_o
      => hr_dei_shd.g_old_rec.dei_attribute25
      ,p_dei_attribute26_o
      => hr_dei_shd.g_old_rec.dei_attribute26
      ,p_dei_attribute27_o
      => hr_dei_shd.g_old_rec.dei_attribute27
      ,p_dei_attribute28_o
      => hr_dei_shd.g_old_rec.dei_attribute28
      ,p_dei_attribute29_o
      => hr_dei_shd.g_old_rec.dei_attribute29
      ,p_dei_attribute30_o
      => hr_dei_shd.g_old_rec.dei_attribute30
      ,p_dei_information_category_o
      => hr_dei_shd.g_old_rec.dei_information_category
      ,p_dei_information1_o
      => hr_dei_shd.g_old_rec.dei_information1
      ,p_dei_information2_o
      => hr_dei_shd.g_old_rec.dei_information2
      ,p_dei_information3_o
      => hr_dei_shd.g_old_rec.dei_information3
      ,p_dei_information4_o
      => hr_dei_shd.g_old_rec.dei_information4
      ,p_dei_information5_o
      => hr_dei_shd.g_old_rec.dei_information5
      ,p_dei_information6_o
      => hr_dei_shd.g_old_rec.dei_information6
      ,p_dei_information7_o
      => hr_dei_shd.g_old_rec.dei_information7
      ,p_dei_information8_o
      => hr_dei_shd.g_old_rec.dei_information8
      ,p_dei_information9_o
      => hr_dei_shd.g_old_rec.dei_information9
      ,p_dei_information10_o
      => hr_dei_shd.g_old_rec.dei_information10
      ,p_dei_information11_o
      => hr_dei_shd.g_old_rec.dei_information11
      ,p_dei_information12_o
      => hr_dei_shd.g_old_rec.dei_information12
      ,p_dei_information13_o
      => hr_dei_shd.g_old_rec.dei_information13
      ,p_dei_information14_o
      => hr_dei_shd.g_old_rec.dei_information14
      ,p_dei_information15_o
      => hr_dei_shd.g_old_rec.dei_information15
      ,p_dei_information16_o
      => hr_dei_shd.g_old_rec.dei_information16
      ,p_dei_information17_o
      => hr_dei_shd.g_old_rec.dei_information17
      ,p_dei_information18_o
      => hr_dei_shd.g_old_rec.dei_information18
      ,p_dei_information19_o
      => hr_dei_shd.g_old_rec.dei_information19
      ,p_dei_information20_o
      => hr_dei_shd.g_old_rec.dei_information20
      ,p_dei_information21_o
      => hr_dei_shd.g_old_rec.dei_information21
      ,p_dei_information22_o
      => hr_dei_shd.g_old_rec.dei_information22
      ,p_dei_information23_o
      => hr_dei_shd.g_old_rec.dei_information23
      ,p_dei_information24_o
      => hr_dei_shd.g_old_rec.dei_information24
      ,p_dei_information25_o
      => hr_dei_shd.g_old_rec.dei_information25
      ,p_dei_information26_o
      => hr_dei_shd.g_old_rec.dei_information26
      ,p_dei_information27_o
      => hr_dei_shd.g_old_rec.dei_information27
      ,p_dei_information28_o
      => hr_dei_shd.g_old_rec.dei_information28
      ,p_dei_information29_o
      => hr_dei_shd.g_old_rec.dei_information29
      ,p_dei_information30_o
      => hr_dei_shd.g_old_rec.dei_information30
      ,p_request_id_o
      => hr_dei_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => hr_dei_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => hr_dei_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => hr_dei_shd.g_old_rec.program_update_date
      ,p_object_version_number_o
      => hr_dei_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_DOCUMENT_EXTRA_INFO'
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
  (p_rec              in hr_dei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_dei_shd.lck
    (p_rec.document_extra_info_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hr_dei_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  hr_dei_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hr_dei_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hr_dei_del.post_delete(p_rec);
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
  (p_document_extra_info_id               in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   hr_dei_shd.g_rec_type;
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
  l_rec.document_extra_info_id := p_document_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_dei_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hr_dei_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_dei_del;

/
