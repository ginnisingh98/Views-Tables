--------------------------------------------------------
--  DDL for Package Body OTA_TPC_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPC_DEL" as
/* $Header: ottpcrhi.pkb 115.5 2003/06/17 14:27:43 sfmorris noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tpc_del.';  -- Global package name
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
  (p_rec in ota_tpc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the ota_training_plan_costs row.
  --
  delete from ota_training_plan_costs
  where training_plan_cost_id = p_rec.training_plan_cost_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    ota_tpc_shd.constraint_error
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
Procedure pre_delete(p_rec in ota_tpc_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ota_tpc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    ota_tpc_rkd.after_delete
      (p_training_plan_cost_id
      => p_rec.training_plan_cost_id
      ,p_tp_measurement_type_id_o
      => ota_tpc_shd.g_old_rec.tp_measurement_type_id
      ,p_training_plan_id_o
      => ota_tpc_shd.g_old_rec.training_plan_id
      ,p_booking_id_o
      => ota_tpc_shd.g_old_rec.booking_id
      ,p_event_id_o
      => ota_tpc_shd.g_old_rec.event_id
      ,p_amount_o
      => ota_tpc_shd.g_old_rec.amount
      ,p_currency_code_o
      => ota_tpc_shd.g_old_rec.currency_code
      ,p_business_group_id_o
      => ota_tpc_shd.g_old_rec.business_group_id
      ,p_object_version_number_o
      => ota_tpc_shd.g_old_rec.object_version_number
      ,p_attribute_category_o
      => ota_tpc_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => ota_tpc_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => ota_tpc_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => ota_tpc_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => ota_tpc_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => ota_tpc_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => ota_tpc_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => ota_tpc_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => ota_tpc_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => ota_tpc_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => ota_tpc_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => ota_tpc_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => ota_tpc_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => ota_tpc_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => ota_tpc_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => ota_tpc_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => ota_tpc_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => ota_tpc_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => ota_tpc_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => ota_tpc_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => ota_tpc_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => ota_tpc_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => ota_tpc_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => ota_tpc_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => ota_tpc_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => ota_tpc_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => ota_tpc_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => ota_tpc_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => ota_tpc_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => ota_tpc_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => ota_tpc_shd.g_old_rec.attribute30
      ,p_information_category_o
      => ota_tpc_shd.g_old_rec.information_category
      ,p_tp_cost_information1_o
      => ota_tpc_shd.g_old_rec.tp_cost_information1
      ,p_tp_cost_information2_o
      => ota_tpc_shd.g_old_rec.tp_cost_information2
      ,p_tp_cost_information3_o
      => ota_tpc_shd.g_old_rec.tp_cost_information3
      ,p_tp_cost_information4_o
      => ota_tpc_shd.g_old_rec.tp_cost_information4
      ,p_tp_cost_information5_o
      => ota_tpc_shd.g_old_rec.tp_cost_information5
      ,p_tp_cost_information6_o
      => ota_tpc_shd.g_old_rec.tp_cost_information6
      ,p_tp_cost_information7_o
      => ota_tpc_shd.g_old_rec.tp_cost_information7
      ,p_tp_cost_information8_o
      => ota_tpc_shd.g_old_rec.tp_cost_information8
      ,p_tp_cost_information9_o
      => ota_tpc_shd.g_old_rec.tp_cost_information9
      ,p_tp_cost_information10_o
      => ota_tpc_shd.g_old_rec.tp_cost_information10
      ,p_tp_cost_information11_o
      => ota_tpc_shd.g_old_rec.tp_cost_information11
      ,p_tp_cost_information12_o
      => ota_tpc_shd.g_old_rec.tp_cost_information12
      ,p_tp_cost_information13_o
      => ota_tpc_shd.g_old_rec.tp_cost_information13
      ,p_tp_cost_information14_o
      => ota_tpc_shd.g_old_rec.tp_cost_information14
      ,p_tp_cost_information15_o
      => ota_tpc_shd.g_old_rec.tp_cost_information15
      ,p_tp_cost_information16_o
      => ota_tpc_shd.g_old_rec.tp_cost_information16
      ,p_tp_cost_information17_o
      => ota_tpc_shd.g_old_rec.tp_cost_information17
      ,p_tp_cost_information18_o
      => ota_tpc_shd.g_old_rec.tp_cost_information18
      ,p_tp_cost_information19_o
      => ota_tpc_shd.g_old_rec.tp_cost_information19
      ,p_tp_cost_information20_o
      => ota_tpc_shd.g_old_rec.tp_cost_information20
      ,p_tp_cost_information21_o
      => ota_tpc_shd.g_old_rec.tp_cost_information21
      ,p_tp_cost_information22_o
      => ota_tpc_shd.g_old_rec.tp_cost_information22
      ,p_tp_cost_information23_o
      => ota_tpc_shd.g_old_rec.tp_cost_information23
      ,p_tp_cost_information24_o
      => ota_tpc_shd.g_old_rec.tp_cost_information24
      ,p_tp_cost_information25_o
      => ota_tpc_shd.g_old_rec.tp_cost_information25
      ,p_tp_cost_information26_o
      => ota_tpc_shd.g_old_rec.tp_cost_information26
      ,p_tp_cost_information27_o
      => ota_tpc_shd.g_old_rec.tp_cost_information27
      ,p_tp_cost_information28_o
      => ota_tpc_shd.g_old_rec.tp_cost_information28
      ,p_tp_cost_information29_o
      => ota_tpc_shd.g_old_rec.tp_cost_information29
      ,p_tp_cost_information30_o
      => ota_tpc_shd.g_old_rec.tp_cost_information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_TRAINING_PLAN_COSTS'
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
  (p_rec	      in ota_tpc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ota_tpc_shd.lck
    (p_rec.training_plan_cost_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ota_tpc_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  ota_tpc_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ota_tpc_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ota_tpc_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_training_plan_cost_id                in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  ota_tpc_shd.g_rec_type;
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
  l_rec.training_plan_cost_id := p_training_plan_cost_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ota_tpc_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ota_tpc_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ota_tpc_del;

/
