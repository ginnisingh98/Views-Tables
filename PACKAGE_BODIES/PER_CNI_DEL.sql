--------------------------------------------------------
--  DDL for Package Body PER_CNI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNI_DEL" as
/* $Header: pecnirhi.pkb 120.0 2005/05/31 06:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cni_del.';  -- Global package name
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
  (p_rec in per_cni_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_ri_config_information row.
  --
  delete from per_ri_config_information
  where config_information_id = p_rec.config_information_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_cni_shd.constraint_error
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
Procedure pre_delete(p_rec in per_cni_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_cni_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_cni_rkd.after_delete
      (p_config_information_id
      => p_rec.config_information_id
      ,p_configuration_code_o
      => per_cni_shd.g_old_rec.configuration_code
      ,p_config_information_categor_o
      => per_cni_shd.g_old_rec.config_information_category
      ,p_config_information1_o
      => per_cni_shd.g_old_rec.config_information1
      ,p_config_information2_o
      => per_cni_shd.g_old_rec.config_information2
      ,p_config_information3_o
      => per_cni_shd.g_old_rec.config_information3
      ,p_config_information4_o
      => per_cni_shd.g_old_rec.config_information4
      ,p_config_information5_o
      => per_cni_shd.g_old_rec.config_information5
      ,p_config_information6_o
      => per_cni_shd.g_old_rec.config_information6
      ,p_config_information7_o
      => per_cni_shd.g_old_rec.config_information7
      ,p_config_information8_o
      => per_cni_shd.g_old_rec.config_information8
      ,p_config_information9_o
      => per_cni_shd.g_old_rec.config_information9
      ,p_config_information10_o
      => per_cni_shd.g_old_rec.config_information10
      ,p_config_information11_o
      => per_cni_shd.g_old_rec.config_information11
      ,p_config_information12_o
      => per_cni_shd.g_old_rec.config_information12
      ,p_config_information13_o
      => per_cni_shd.g_old_rec.config_information13
      ,p_config_information14_o
      => per_cni_shd.g_old_rec.config_information14
      ,p_config_information15_o
      => per_cni_shd.g_old_rec.config_information15
      ,p_config_information16_o
      => per_cni_shd.g_old_rec.config_information16
      ,p_config_information17_o
      => per_cni_shd.g_old_rec.config_information17
      ,p_config_information18_o
      => per_cni_shd.g_old_rec.config_information18
      ,p_config_information19_o
      => per_cni_shd.g_old_rec.config_information19
      ,p_config_information20_o
      => per_cni_shd.g_old_rec.config_information20
      ,p_config_information21_o
      => per_cni_shd.g_old_rec.config_information21
      ,p_config_information22_o
      => per_cni_shd.g_old_rec.config_information22
      ,p_config_information23_o
      => per_cni_shd.g_old_rec.config_information23
      ,p_config_information24_o
      => per_cni_shd.g_old_rec.config_information24
      ,p_config_information25_o
      => per_cni_shd.g_old_rec.config_information25
      ,p_config_information26_o
      => per_cni_shd.g_old_rec.config_information26
      ,p_config_information27_o
      => per_cni_shd.g_old_rec.config_information27
      ,p_config_information28_o
      => per_cni_shd.g_old_rec.config_information28
      ,p_config_information29_o
      => per_cni_shd.g_old_rec.config_information29
      ,p_config_information30_o
      => per_cni_shd.g_old_rec.config_information30
      ,p_config_sequence_o
      => per_cni_shd.g_old_rec.config_sequence
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_RI_CONFIG_INFORMATION'
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
  (p_rec     In per_cni_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_cni_shd.lck
    (p_rec.config_information_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_cni_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_cni_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_cni_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_cni_del.post_delete(p_rec);
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
  (p_config_information_id In Number
  ,p_object_version_number In Number
  ) is
--
  l_rec   per_cni_shd.g_rec_type;
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
  l_rec.config_information_id := p_config_information_id;
  l_rec.object_version_number := p_object_version_number;
  --
  --
  -- Having converted the arguments into the per_cni_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_cni_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_cni_del;

/
