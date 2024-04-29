--------------------------------------------------------
--  DDL for Package Body PER_RET_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RET_DEL" as
/* $Header: peretrhi.pkb 115.1 2002/12/06 11:29:20 eumenyio noship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ret_del.';  -- Global package name
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
  (p_rec in per_ret_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_cagr_retained_rights row.
  --
  delete from per_cagr_retained_rights
  where cagr_retained_right_id = p_rec.cagr_retained_right_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_ret_shd.constraint_error
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
Procedure pre_delete(p_rec in per_ret_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_ret_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
/*
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_ret_rkd.after_delete
      (p_cagr_retained_right_id
      => p_rec.cagr_retained_right_id
      ,p_assignment_id_o
      => per_ret_shd.g_old_rec.assignment_id
      ,p_cagr_entitlement_item_id_o
      => per_ret_shd.g_old_rec.cagr_entitlement_item_id
      ,p_collective_agreement_id_o
      => per_ret_shd.g_old_rec.collective_agreement_id
      ,p_cagr_entitlement_id_o
      => per_ret_shd.g_old_rec.cagr_entitlement_id
      ,p_category_name_o
      => per_ret_shd.g_old_rec.category_name
      ,p_element_type_id_o
      => per_ret_shd.g_old_rec.element_type_id
      ,p_input_value_id_o
      => per_ret_shd.g_old_rec.input_value_id
      ,p_cagr_api_id_o
      => per_ret_shd.g_old_rec.cagr_api_id
      ,p_cagr_api_param_id_o
      => per_ret_shd.g_old_rec.cagr_api_param_id
      ,p_cagr_entitlement_line_id_o
      => per_ret_shd.g_old_rec.cagr_entitlement_line_id
      ,p_freeze_flag_o
      => per_ret_shd.g_old_rec.freeze_flag
      ,p_value_o
      => per_ret_shd.g_old_rec.value
      ,p_units_of_measure_o
      => per_ret_shd.g_old_rec.units_of_measure
      ,p_start_date_o
      => per_ret_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_ret_shd.g_old_rec.end_date
      ,p_parent_spine_id_o
      => per_ret_shd.g_old_rec.parent_spine_id
      ,p_formula_id_o
      => per_ret_shd.g_old_rec.formula_id
      ,p_oipl_id_o
      => per_ret_shd.g_old_rec.oipl_id
      ,p_step_id_o
      => per_ret_shd.g_old_rec.step_id
      ,p_grade_spine_id_o
      => per_ret_shd.g_old_rec.grade_spine_id
      ,p_column_type_o
      => per_ret_shd.g_old_rec.column_type
      ,p_column_size_o
      => per_ret_shd.g_old_rec.column_size
      ,p_eligy_prfl_id_o
      => per_ret_shd.g_old_rec.eligy_prfl_id
      ,p_object_version_number_o
      => per_ret_shd.g_old_rec.object_version_number
      ,p_cagr_entitlement_result_id_o
      => per_ret_shd.g_old_rec.cagr_entitlement_result_id
      ,p_business_group_id_o
      => per_ret_shd.g_old_rec.business_group_id
      ,p_flex_value_set_id_o
      => per_ret_shd.g_old_rec.flex_value_set_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CAGR_RETAINED_RIGHTS'
        ,p_hook_type   => 'AD');
      --
  end;
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in per_ret_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_ret_shd.lck
    (p_rec.cagr_retained_right_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_ret_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  per_ret_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_ret_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_ret_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_cagr_retained_right_id              in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_ret_shd.g_rec_type;
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
  l_rec.cagr_retained_right_id := p_cagr_retained_right_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_ret_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_ret_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_ret_del;

/
