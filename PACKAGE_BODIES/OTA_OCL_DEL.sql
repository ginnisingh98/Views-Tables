--------------------------------------------------------
--  DDL for Package Body OTA_OCL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OCL_DEL" as
/* $Header: otoclrhi.pkb 120.1.12000000.2 2007/02/07 09:19:37 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_ocl_del.';  -- Global package name
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
  (p_rec in ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the ota_competence_languages row.
  --
  delete from ota_competence_languages
  where competence_language_id = p_rec.competence_language_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    ota_ocl_shd.constraint_error
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
Procedure pre_delete(p_rec in ota_ocl_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ota_ocl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    ota_ocl_rkd.after_delete
      (p_competence_language_id
      => p_rec.competence_language_id
      ,p_competence_id_o
      => ota_ocl_shd.g_old_rec.competence_id
      ,p_language_code_o
      => ota_ocl_shd.g_old_rec.language_code
      ,p_min_proficiency_level_id_o
      => ota_ocl_shd.g_old_rec.min_proficiency_level_id
      ,p_business_group_id_o
      => ota_ocl_shd.g_old_rec.business_group_id
      ,p_object_version_number_o
      => ota_ocl_shd.g_old_rec.object_version_number
      ,p_ocl_information_category_o
      => ota_ocl_shd.g_old_rec.ocl_information_category
      ,p_ocl_information1_o
      => ota_ocl_shd.g_old_rec.ocl_information1
      ,p_ocl_information2_o
      => ota_ocl_shd.g_old_rec.ocl_information2
      ,p_ocl_information3_o
      => ota_ocl_shd.g_old_rec.ocl_information3
      ,p_ocl_information4_o
      => ota_ocl_shd.g_old_rec.ocl_information4
      ,p_ocl_information5_o
      => ota_ocl_shd.g_old_rec.ocl_information5
      ,p_ocl_information6_o
      => ota_ocl_shd.g_old_rec.ocl_information6
      ,p_ocl_information7_o
      => ota_ocl_shd.g_old_rec.ocl_information7
      ,p_ocl_information8_o
      => ota_ocl_shd.g_old_rec.ocl_information8
      ,p_ocl_information9_o
      => ota_ocl_shd.g_old_rec.ocl_information9
      ,p_ocl_information10_o
      => ota_ocl_shd.g_old_rec.ocl_information10
      ,p_ocl_information11_o
      => ota_ocl_shd.g_old_rec.ocl_information11
      ,p_ocl_information12_o
      => ota_ocl_shd.g_old_rec.ocl_information12
      ,p_ocl_information13_o
      => ota_ocl_shd.g_old_rec.ocl_information13
      ,p_ocl_information14_o
      => ota_ocl_shd.g_old_rec.ocl_information14
      ,p_ocl_information15_o
      => ota_ocl_shd.g_old_rec.ocl_information15
      ,p_ocl_information16_o
      => ota_ocl_shd.g_old_rec.ocl_information16
      ,p_ocl_information17_o
      => ota_ocl_shd.g_old_rec.ocl_information17
      ,p_ocl_information18_o
      => ota_ocl_shd.g_old_rec.ocl_information18
      ,p_ocl_information19_o
      => ota_ocl_shd.g_old_rec.ocl_information19
      ,p_ocl_information20_o
      => ota_ocl_shd.g_old_rec.ocl_information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_COMPETENCE_LANGUAGES'
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
  (p_rec	      in ota_ocl_shd.g_rec_type,
   p_validate     in boolean default false

  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

    If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_ota_ocl;
  End If;

  --
  -- We must lock the row which we need to delete.
  --
  ota_ocl_shd.lck
    (p_rec.competence_language_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ota_ocl_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  ota_ocl_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ota_ocl_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ota_ocl_del.post_delete(p_rec);

   If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_ota_ocl;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_competence_language_id               in     number
  ,p_object_version_number                in     number
  ,p_validate                              in 	 boolean default false

  ) is
--
  l_rec	  ota_ocl_shd.g_rec_type;
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
  l_rec.competence_language_id := p_competence_language_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ota_ocl_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ota_ocl_del.del(l_rec,p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ota_ocl_del;

/
