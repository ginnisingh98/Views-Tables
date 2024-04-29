--------------------------------------------------------
--  DDL for Package Body PQP_VAI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAI_DEL" as
/* $Header: pqvairhi.pkb 120.0.12010000.2 2008/08/08 07:19:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vai_del.';  -- Global package name
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
  (p_rec in pqp_vai_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_vai_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pqp_veh_alloc_extra_info row.
  --
  delete from pqp_veh_alloc_extra_info
  where veh_alloc_extra_info_id = p_rec.veh_alloc_extra_info_id;
  --
  pqp_vai_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqp_vai_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vai_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_vai_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pqp_vai_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pqp_vai_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_vai_rkd.after_delete
      (p_veh_alloc_extra_info_id
      => p_rec.veh_alloc_extra_info_id
      ,p_vehicle_allocation_id_o
      => pqp_vai_shd.g_old_rec.vehicle_allocation_id
      ,p_information_type_o
      => pqp_vai_shd.g_old_rec.information_type
      ,p_vaei_attribute_category_o
      => pqp_vai_shd.g_old_rec.vaei_attribute_category
      ,p_vaei_attribute1_o
      => pqp_vai_shd.g_old_rec.vaei_attribute1
      ,p_vaei_attribute2_o
      => pqp_vai_shd.g_old_rec.vaei_attribute2
      ,p_vaei_attribute3_o
      => pqp_vai_shd.g_old_rec.vaei_attribute3
      ,p_vaei_attribute4_o
      => pqp_vai_shd.g_old_rec.vaei_attribute4
      ,p_vaei_attribute5_o
      => pqp_vai_shd.g_old_rec.vaei_attribute5
      ,p_vaei_attribute6_o
      => pqp_vai_shd.g_old_rec.vaei_attribute6
      ,p_vaei_attribute7_o
      => pqp_vai_shd.g_old_rec.vaei_attribute7
      ,p_vaei_attribute8_o
      => pqp_vai_shd.g_old_rec.vaei_attribute8
      ,p_vaei_attribute9_o
      => pqp_vai_shd.g_old_rec.vaei_attribute9
      ,p_vaei_attribute10_o
      => pqp_vai_shd.g_old_rec.vaei_attribute10
      ,p_vaei_attribute11_o
      => pqp_vai_shd.g_old_rec.vaei_attribute11
      ,p_vaei_attribute12_o
      => pqp_vai_shd.g_old_rec.vaei_attribute12
      ,p_vaei_attribute13_o
      => pqp_vai_shd.g_old_rec.vaei_attribute13
      ,p_vaei_attribute14_o
      => pqp_vai_shd.g_old_rec.vaei_attribute14
      ,p_vaei_attribute15_o
      => pqp_vai_shd.g_old_rec.vaei_attribute15
      ,p_vaei_attribute16_o
      => pqp_vai_shd.g_old_rec.vaei_attribute16
      ,p_vaei_attribute17_o
      => pqp_vai_shd.g_old_rec.vaei_attribute17
      ,p_vaei_attribute18_o
      => pqp_vai_shd.g_old_rec.vaei_attribute18
      ,p_vaei_attribute19_o
      => pqp_vai_shd.g_old_rec.vaei_attribute19
      ,p_vaei_attribute20_o
      => pqp_vai_shd.g_old_rec.vaei_attribute20
      ,p_vaei_information_category_o
      => pqp_vai_shd.g_old_rec.vaei_information_category
      ,p_vaei_information1_o
      => pqp_vai_shd.g_old_rec.vaei_information1
      ,p_vaei_information2_o
      => pqp_vai_shd.g_old_rec.vaei_information2
      ,p_vaei_information3_o
      => pqp_vai_shd.g_old_rec.vaei_information3
      ,p_vaei_information4_o
      => pqp_vai_shd.g_old_rec.vaei_information4
      ,p_vaei_information5_o
      => pqp_vai_shd.g_old_rec.vaei_information5
      ,p_vaei_information6_o
      => pqp_vai_shd.g_old_rec.vaei_information6
      ,p_vaei_information7_o
      => pqp_vai_shd.g_old_rec.vaei_information7
      ,p_vaei_information8_o
      => pqp_vai_shd.g_old_rec.vaei_information8
      ,p_vaei_information9_o
      => pqp_vai_shd.g_old_rec.vaei_information9
      ,p_vaei_information10_o
      => pqp_vai_shd.g_old_rec.vaei_information10
      ,p_vaei_information11_o
      => pqp_vai_shd.g_old_rec.vaei_information11
      ,p_vaei_information12_o
      => pqp_vai_shd.g_old_rec.vaei_information12
      ,p_vaei_information13_o
      => pqp_vai_shd.g_old_rec.vaei_information13
      ,p_vaei_information14_o
      => pqp_vai_shd.g_old_rec.vaei_information14
      ,p_vaei_information15_o
      => pqp_vai_shd.g_old_rec.vaei_information15
      ,p_vaei_information16_o
      => pqp_vai_shd.g_old_rec.vaei_information16
      ,p_vaei_information17_o
      => pqp_vai_shd.g_old_rec.vaei_information17
      ,p_vaei_information18_o
      => pqp_vai_shd.g_old_rec.vaei_information18
      ,p_vaei_information19_o
      => pqp_vai_shd.g_old_rec.vaei_information19
      ,p_vaei_information20_o
      => pqp_vai_shd.g_old_rec.vaei_information20
      ,p_vaei_information21_o
      => pqp_vai_shd.g_old_rec.vaei_information21
      ,p_vaei_information22_o
      => pqp_vai_shd.g_old_rec.vaei_information22
      ,p_vaei_information23_o
      => pqp_vai_shd.g_old_rec.vaei_information23
      ,p_vaei_information24_o
      => pqp_vai_shd.g_old_rec.vaei_information24
      ,p_vaei_information25_o
      => pqp_vai_shd.g_old_rec.vaei_information25
      ,p_vaei_information26_o
      => pqp_vai_shd.g_old_rec.vaei_information26
      ,p_vaei_information27_o
      => pqp_vai_shd.g_old_rec.vaei_information27
      ,p_vaei_information28_o
      => pqp_vai_shd.g_old_rec.vaei_information28
      ,p_vaei_information29_o
      => pqp_vai_shd.g_old_rec.vaei_information29
      ,p_vaei_information30_o
      => pqp_vai_shd.g_old_rec.vaei_information30
      ,p_object_version_number_o
      => pqp_vai_shd.g_old_rec.object_version_number
      ,p_request_id_o
      => pqp_vai_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => pqp_vai_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => pqp_vai_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => pqp_vai_shd.g_old_rec.program_update_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_ALLOC_EXTRA_INFO'
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
  (p_rec              in pqp_vai_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqp_vai_shd.lck
    (p_rec.veh_alloc_extra_info_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqp_vai_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pqp_vai_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqp_vai_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqp_vai_del.post_delete(p_rec);
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
  (p_veh_alloc_extra_info_id              in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pqp_vai_shd.g_rec_type;
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
  l_rec.veh_alloc_extra_info_id := p_veh_alloc_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqp_vai_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqp_vai_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqp_vai_del;

/
