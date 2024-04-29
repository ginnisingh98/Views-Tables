--------------------------------------------------------
--  DDL for Package Body PER_SHT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHT_DEL" as
/* $Header: peshtrhi.pkb 120.0 2005/05/31 21:06:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_sht_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
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
Procedure delete_dml(p_rec in per_sht_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete the per_shared_types row.
  --
  delete from per_shared_types
  where shared_type_id = p_rec.shared_type_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_sht_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_delete(p_rec in per_sht_shd.g_rec_type) is
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
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(
p_effective_date in date,p_rec in per_sht_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    per_sht_rkd.after_delete
      (
  p_shared_type_id                =>p_rec.shared_type_id
 ,p_business_group_id_o           =>per_sht_shd.g_old_rec.business_group_id
 ,p_shared_type_name_o            =>per_sht_shd.g_old_rec.shared_type_name
 ,p_shared_type_code_o            =>per_sht_shd.g_old_rec.shared_type_code
 ,p_system_type_cd_o              =>per_sht_shd.g_old_rec.system_type_cd
 ,p_information1_o                =>per_sht_shd.g_old_rec.information1
 ,p_information2_o                =>per_sht_shd.g_old_rec.information2
 ,p_information3_o                =>per_sht_shd.g_old_rec.information3
 ,p_information4_o                =>per_sht_shd.g_old_rec.information4
 ,p_information5_o                =>per_sht_shd.g_old_rec.information5
 ,p_information6_o                =>per_sht_shd.g_old_rec.information6
 ,p_information7_o                =>per_sht_shd.g_old_rec.information7
 ,p_information8_o                =>per_sht_shd.g_old_rec.information8
 ,p_information9_o                =>per_sht_shd.g_old_rec.information9
 ,p_information10_o               =>per_sht_shd.g_old_rec.information10
 ,p_information11_o               =>per_sht_shd.g_old_rec.information11
 ,p_information12_o               =>per_sht_shd.g_old_rec.information12
 ,p_information13_o               =>per_sht_shd.g_old_rec.information13
 ,p_information14_o               =>per_sht_shd.g_old_rec.information14
 ,p_information15_o               =>per_sht_shd.g_old_rec.information15
 ,p_information16_o               =>per_sht_shd.g_old_rec.information16
 ,p_information17_o               =>per_sht_shd.g_old_rec.information17
 ,p_information18_o               =>per_sht_shd.g_old_rec.information18
 ,p_information19_o               =>per_sht_shd.g_old_rec.information19
 ,p_information20_o               =>per_sht_shd.g_old_rec.information20
 ,p_information21_o               =>per_sht_shd.g_old_rec.information21
 ,p_information22_o               =>per_sht_shd.g_old_rec.information22
 ,p_information23_o               =>per_sht_shd.g_old_rec.information23
 ,p_information24_o               =>per_sht_shd.g_old_rec.information24
 ,p_information25_o               =>per_sht_shd.g_old_rec.information25
 ,p_information26_o               =>per_sht_shd.g_old_rec.information26
 ,p_information27_o               =>per_sht_shd.g_old_rec.information27
 ,p_information28_o               =>per_sht_shd.g_old_rec.information28
 ,p_information29_o               =>per_sht_shd.g_old_rec.information29
 ,p_information30_o               =>per_sht_shd.g_old_rec.information30
 ,p_information_category_o        =>per_sht_shd.g_old_rec.information_category
 ,p_object_version_number_o       =>per_sht_shd.g_old_rec.object_version_number
 ,p_lookup_type_o                 =>per_sht_shd.g_old_rec.lookup_type
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_shared_types'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_rec	      in per_sht_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_sht_shd.lck
	(
	p_rec.shared_type_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  per_sht_bus.delete_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_shared_type_id                     in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  per_sht_shd.g_rec_type;
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
  l_rec.shared_type_id:= p_shared_type_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_sht_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_sht_del;

/
