--------------------------------------------------------
--  DDL for Package Body HR_ITP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITP_DEL" as
/* $Header: hritprhi.pkb 115.11 2003/12/03 07:01:45 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_itp_del.';  -- Global package name
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
  (p_rec in hr_itp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the hr_item_properties_b row.
  --
  delete from hr_item_properties_b
  where item_property_id = p_rec.item_property_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    hr_itp_shd.constraint_error
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
Procedure pre_delete(p_rec in hr_itp_shd.g_rec_type) is
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
Procedure post_delete(p_rec in hr_itp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    hr_itp_rkd.after_delete
      (p_item_property_id
      => p_rec.item_property_id
      ,p_object_version_number_o
      => hr_itp_shd.g_old_rec.object_version_number
      ,p_form_item_id_o
      => hr_itp_shd.g_old_rec.form_item_id
      ,p_template_item_id_o
      => hr_itp_shd.g_old_rec.template_item_id
      ,p_template_item_context_id_o
      => hr_itp_shd.g_old_rec.template_item_context_id
      ,p_alignment_o
      => hr_itp_shd.g_old_rec.alignment
      ,p_bevel_o
      => hr_itp_shd.g_old_rec.bevel
      ,p_case_restriction_o
      => hr_itp_shd.g_old_rec.case_restriction
      ,p_enabled_o
      => hr_itp_shd.g_old_rec.enabled
      ,p_format_mask_o
      => hr_itp_shd.g_old_rec.format_mask
      ,p_height_o
      => hr_itp_shd.g_old_rec.height
      ,p_information_formula_id_o
      => hr_itp_shd.g_old_rec.information_formula_id
      ,p_information_param_item_id1_o
      => hr_itp_shd.g_old_rec.information_parameter_item_id1
      ,p_information_param_item_id2_o
      => hr_itp_shd.g_old_rec.information_parameter_item_id2
      ,p_information_param_item_id3_o
      => hr_itp_shd.g_old_rec.information_parameter_item_id3
      ,p_information_param_item_id4_o
      => hr_itp_shd.g_old_rec.information_parameter_item_id4
      ,p_information_param_item_id5_o
      => hr_itp_shd.g_old_rec.information_parameter_item_id5
      ,p_insert_allowed_o
      => hr_itp_shd.g_old_rec.insert_allowed
      ,p_prompt_alignment_offset_o
      => hr_itp_shd.g_old_rec.prompt_alignment_offset
      ,p_prompt_display_style_o
      => hr_itp_shd.g_old_rec.prompt_display_style
      ,p_prompt_edge_o
      => hr_itp_shd.g_old_rec.prompt_edge
      ,p_prompt_edge_alignment_o
      => hr_itp_shd.g_old_rec.prompt_edge_alignment
      ,p_prompt_edge_offset_o
      => hr_itp_shd.g_old_rec.prompt_edge_offset
      ,p_prompt_text_alignment_o
      => hr_itp_shd.g_old_rec.prompt_text_alignment
      ,p_query_allowed_o
      => hr_itp_shd.g_old_rec.query_allowed
      ,p_required_o
      => hr_itp_shd.g_old_rec.required
      ,p_update_allowed_o
      => hr_itp_shd.g_old_rec.update_allowed
      ,p_validation_formula_id_o
      => hr_itp_shd.g_old_rec.validation_formula_id
      ,p_validation_param_item_id1_o
      => hr_itp_shd.g_old_rec.validation_parameter_item_id1
      ,p_validation_param_item_id2_o
      => hr_itp_shd.g_old_rec.validation_parameter_item_id2
      ,p_validation_param_item_id3_o
      => hr_itp_shd.g_old_rec.validation_parameter_item_id3
      ,p_validation_param_item_id4_o
      => hr_itp_shd.g_old_rec.validation_parameter_item_id4
      ,p_validation_param_item_id5_o
      => hr_itp_shd.g_old_rec.validation_parameter_item_id5
      ,p_visible_o
      => hr_itp_shd.g_old_rec.visible
      ,p_width_o
      => hr_itp_shd.g_old_rec.width
      ,p_x_position_o
      => hr_itp_shd.g_old_rec.x_position
      ,p_y_position_o
      => hr_itp_shd.g_old_rec.y_position
      ,p_information_category_o
      => hr_itp_shd.g_old_rec.information_category
      ,p_information1_o
      => hr_itp_shd.g_old_rec.information1
      ,p_information2_o
      => hr_itp_shd.g_old_rec.information2
      ,p_information3_o
      => hr_itp_shd.g_old_rec.information3
      ,p_information4_o
      => hr_itp_shd.g_old_rec.information4
      ,p_information5_o
      => hr_itp_shd.g_old_rec.information5
      ,p_information6_o
      => hr_itp_shd.g_old_rec.information6
      ,p_information7_o
      => hr_itp_shd.g_old_rec.information7
      ,p_information8_o
      => hr_itp_shd.g_old_rec.information8
      ,p_information9_o
      => hr_itp_shd.g_old_rec.information9
      ,p_information10_o
      => hr_itp_shd.g_old_rec.information10
      ,p_information11_o
      => hr_itp_shd.g_old_rec.information11
      ,p_information12_o
      => hr_itp_shd.g_old_rec.information12
      ,p_information13_o
      => hr_itp_shd.g_old_rec.information13
      ,p_information14_o
      => hr_itp_shd.g_old_rec.information14
      ,p_information15_o
      => hr_itp_shd.g_old_rec.information15
      ,p_information16_o
      => hr_itp_shd.g_old_rec.information16
      ,p_information17_o
      => hr_itp_shd.g_old_rec.information17
      ,p_information18_o
      => hr_itp_shd.g_old_rec.information18
      ,p_information19_o
      => hr_itp_shd.g_old_rec.information19
      ,p_information20_o
      => hr_itp_shd.g_old_rec.information20
      ,p_information21_o
      => hr_itp_shd.g_old_rec.information21
      ,p_information22_o
      => hr_itp_shd.g_old_rec.information22
      ,p_information23_o
      => hr_itp_shd.g_old_rec.information23
      ,p_information24_o
      => hr_itp_shd.g_old_rec.information24
      ,p_information25_o
      => hr_itp_shd.g_old_rec.information25
      ,p_information26_o
      => hr_itp_shd.g_old_rec.information26
      ,p_information27_o
      => hr_itp_shd.g_old_rec.information27
      ,p_information28_o
      => hr_itp_shd.g_old_rec.information28
      ,p_information29_o
      => hr_itp_shd.g_old_rec.information29
      ,p_information30_o
      => hr_itp_shd.g_old_rec.information30
      ,p_next_navigation_item_id_o
      => hr_itp_shd.g_old_rec.next_navigation_item_id
      ,p_prev_navigation_item_id_o
      => hr_itp_shd.g_old_rec.previous_navigation_item_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ITEM_PROPERTIES_B'
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
  (p_rec        in hr_itp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_itp_shd.lck
    (p_rec.item_property_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hr_itp_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  hr_itp_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hr_itp_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hr_itp_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_item_property_id                     in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   hr_itp_shd.g_rec_type;
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
  l_rec.item_property_id := p_item_property_id;
  l_rec.object_version_number := p_object_version_number;
  --
  --
  -- Having converted the arguments into the hr_itp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hr_itp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_itp_del;

/
