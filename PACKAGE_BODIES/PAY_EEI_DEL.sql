--------------------------------------------------------
--  DDL for Package Body PAY_EEI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EEI_DEL" as
/* $Header: pyeeirhi.pkb 120.11 2006/07/12 05:28:45 vikgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_eei_del.';  -- Global package name
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
  (p_rec in pay_eei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_eei_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pay_element_type_extra_info row.
  --
  delete from pay_element_type_extra_info
  where element_type_extra_info_id = p_rec.element_type_extra_info_id;
  --
  pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
    pay_eei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pay_eei_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   delete dml.
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
Procedure post_delete(p_rec in pay_eei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    pay_eei_rkd.after_delete
      (p_element_type_extra_info_id
      => p_rec.element_type_extra_info_id
      ,p_element_type_id_o
      => pay_eei_shd.g_old_rec.element_type_id
      ,p_information_type_o
      => pay_eei_shd.g_old_rec.information_type
      ,p_request_id_o
      => pay_eei_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => pay_eei_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => pay_eei_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => pay_eei_shd.g_old_rec.program_update_date
      ,p_eei_attribute_category_o
      => pay_eei_shd.g_old_rec.eei_attribute_category
      ,p_eei_attribute1_o
      => pay_eei_shd.g_old_rec.eei_attribute1
      ,p_eei_attribute2_o
      => pay_eei_shd.g_old_rec.eei_attribute2
      ,p_eei_attribute3_o
      => pay_eei_shd.g_old_rec.eei_attribute3
      ,p_eei_attribute4_o
      => pay_eei_shd.g_old_rec.eei_attribute4
      ,p_eei_attribute5_o
      => pay_eei_shd.g_old_rec.eei_attribute5
      ,p_eei_attribute6_o
      => pay_eei_shd.g_old_rec.eei_attribute6
      ,p_eei_attribute7_o
      => pay_eei_shd.g_old_rec.eei_attribute7
      ,p_eei_attribute8_o
      => pay_eei_shd.g_old_rec.eei_attribute8
      ,p_eei_attribute9_o
      => pay_eei_shd.g_old_rec.eei_attribute9
      ,p_eei_attribute10_o
      => pay_eei_shd.g_old_rec.eei_attribute10
      ,p_eei_attribute11_o
      => pay_eei_shd.g_old_rec.eei_attribute11
      ,p_eei_attribute12_o
      => pay_eei_shd.g_old_rec.eei_attribute12
      ,p_eei_attribute13_o
      => pay_eei_shd.g_old_rec.eei_attribute13
      ,p_eei_attribute14_o
      => pay_eei_shd.g_old_rec.eei_attribute14
      ,p_eei_attribute15_o
      => pay_eei_shd.g_old_rec.eei_attribute15
      ,p_eei_attribute16_o
      => pay_eei_shd.g_old_rec.eei_attribute16
      ,p_eei_attribute17_o
      => pay_eei_shd.g_old_rec.eei_attribute17
      ,p_eei_attribute18_o
      => pay_eei_shd.g_old_rec.eei_attribute18
      ,p_eei_attribute19_o
      => pay_eei_shd.g_old_rec.eei_attribute19
      ,p_eei_attribute20_o
      => pay_eei_shd.g_old_rec.eei_attribute20
      ,p_eei_information_category_o
      => pay_eei_shd.g_old_rec.eei_information_category
      ,p_eei_information1_o
      => pay_eei_shd.g_old_rec.eei_information1
      ,p_eei_information2_o
      => pay_eei_shd.g_old_rec.eei_information2
      ,p_eei_information3_o
      => pay_eei_shd.g_old_rec.eei_information3
      ,p_eei_information4_o
      => pay_eei_shd.g_old_rec.eei_information4
      ,p_eei_information5_o
      => pay_eei_shd.g_old_rec.eei_information5
      ,p_eei_information6_o
      => pay_eei_shd.g_old_rec.eei_information6
      ,p_eei_information7_o
      => pay_eei_shd.g_old_rec.eei_information7
      ,p_eei_information8_o
      => pay_eei_shd.g_old_rec.eei_information8
      ,p_eei_information9_o
      => pay_eei_shd.g_old_rec.eei_information9
      ,p_eei_information10_o
      => pay_eei_shd.g_old_rec.eei_information10
      ,p_eei_information11_o
      => pay_eei_shd.g_old_rec.eei_information11
      ,p_eei_information12_o
      => pay_eei_shd.g_old_rec.eei_information12
      ,p_eei_information13_o
      => pay_eei_shd.g_old_rec.eei_information13
      ,p_eei_information14_o
      => pay_eei_shd.g_old_rec.eei_information14
      ,p_eei_information15_o
      => pay_eei_shd.g_old_rec.eei_information15
      ,p_eei_information16_o
      => pay_eei_shd.g_old_rec.eei_information16
      ,p_eei_information17_o
      => pay_eei_shd.g_old_rec.eei_information17
      ,p_eei_information18_o
      => pay_eei_shd.g_old_rec.eei_information18
      ,p_eei_information19_o
      => pay_eei_shd.g_old_rec.eei_information19
      ,p_eei_information20_o
      => pay_eei_shd.g_old_rec.eei_information20
      ,p_eei_information21_o
      => pay_eei_shd.g_old_rec.eei_information21
      ,p_eei_information22_o
      => pay_eei_shd.g_old_rec.eei_information22
      ,p_eei_information23_o
      => pay_eei_shd.g_old_rec.eei_information23
      ,p_eei_information24_o
      => pay_eei_shd.g_old_rec.eei_information24
      ,p_eei_information25_o
      => pay_eei_shd.g_old_rec.eei_information25
      ,p_eei_information26_o
      => pay_eei_shd.g_old_rec.eei_information26
      ,p_eei_information27_o
      => pay_eei_shd.g_old_rec.eei_information27
      ,p_eei_information28_o
      => pay_eei_shd.g_old_rec.eei_information28
      ,p_eei_information29_o
      => pay_eei_shd.g_old_rec.eei_information29
      ,p_eei_information30_o
      => pay_eei_shd.g_old_rec.eei_information30
      ,p_object_version_number_o
      => pay_eei_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_TYPE_EXTRA_INFO'
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
  (p_rec	      in pay_eei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_eei_shd.lck
    (p_rec.element_type_extra_info_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_eei_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pay_eei_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pay_eei_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pay_eei_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_element_type_extra_info_id           in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  pay_eei_shd.g_rec_type;
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
  l_rec.element_type_extra_info_id := p_element_type_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_eei_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_eei_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_eei_del;

/
