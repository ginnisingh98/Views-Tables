--------------------------------------------------------
--  DDL for Package Body PER_CNL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNL_DEL" as
/* $Header: pecnlrhi.pkb 120.0 2005/05/31 06:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cnl_del.';  -- Global package name
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
  (p_rec in per_cnl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_ri_config_locations row.
  --
  delete from per_ri_config_locations
  where location_id = p_rec.location_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_cnl_shd.constraint_error
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
Procedure pre_delete(p_rec in per_cnl_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_cnl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_cnl_rkd.after_delete
      (p_location_id               => p_rec.location_id
      ,p_configuration_code_o      => per_cnl_shd.g_old_rec.configuration_code
      ,p_configuration_context_o   => per_cnl_shd.g_old_rec.configuration_context
      ,p_location_code_o           => per_cnl_shd.g_old_rec.location_code
      ,p_description_o             => per_cnl_shd.g_old_rec.description
      ,p_style_o                   => per_cnl_shd.g_old_rec.style
      ,p_address_line_1_o          => per_cnl_shd.g_old_rec.address_line_1
      ,p_address_line_2_o          => per_cnl_shd.g_old_rec.address_line_2
      ,p_address_line_3_o          => per_cnl_shd.g_old_rec.address_line_3
      ,p_town_or_city_o            => per_cnl_shd.g_old_rec.town_or_city
      ,p_country_o                 => per_cnl_shd.g_old_rec.country
      ,p_postal_code_o             => per_cnl_shd.g_old_rec.postal_code
      ,p_region_1_o                => per_cnl_shd.g_old_rec.region_1
      ,p_region_2_o                => per_cnl_shd.g_old_rec.region_2
      ,p_region_3_o                => per_cnl_shd.g_old_rec.region_3
      ,p_telephone_number_1_o      => per_cnl_shd.g_old_rec.telephone_number_1
      ,p_telephone_number_2_o      => per_cnl_shd.g_old_rec.telephone_number_2
      ,p_telephone_number_3_o      => per_cnl_shd.g_old_rec.telephone_number_3
      ,p_loc_information13_o       => per_cnl_shd.g_old_rec.loc_information13
      ,p_loc_information14_o       => per_cnl_shd.g_old_rec.loc_information14
      ,p_loc_information15_o       => per_cnl_shd.g_old_rec.loc_information15
      ,p_loc_information16_o       => per_cnl_shd.g_old_rec.loc_information16
      ,p_loc_information17_o       => per_cnl_shd.g_old_rec.loc_information17
      ,p_loc_information18_o       => per_cnl_shd.g_old_rec.loc_information18
      ,p_loc_information19_o       => per_cnl_shd.g_old_rec.loc_information19
      ,p_loc_information20_o       => per_cnl_shd.g_old_rec.loc_information20
      ,p_object_version_number_o   => per_cnl_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_RI_CONFIG_LOCATIONS'
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
  (p_rec              in per_cnl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_cnl_shd.lck
    (p_rec.location_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_cnl_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_cnl_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_cnl_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_cnl_del.post_delete(p_rec);
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
  (p_location_id                          in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_cnl_shd.g_rec_type;
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
  l_rec.location_id := p_location_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_cnl_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_cnl_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_cnl_del;

/
