--------------------------------------------------------
--  DDL for Package Body PER_RES_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RES_UPD" as
/* $Header: peresrhi.pkb 115.2 2003/04/02 13:38:24 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_res_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy per_res_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the per_cagr_entitlement_results Row
  --
  update per_cagr_entitlement_results
    set
     cagr_entitlement_result_id      = p_rec.cagr_entitlement_result_id
    ,chosen_flag                     = p_rec.chosen_flag
    ,object_version_number           = p_rec.object_version_number
    where cagr_entitlement_result_id = p_rec.cagr_entitlement_result_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_res_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_res_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_res_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in per_res_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_effective_date               in date
  ,p_rec                          in per_res_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  /*
  begin
    --
    per_res_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_cagr_entitlement_result_id  => p_rec.cagr_entitlement_result_id
      ,p_beneficial_flag => p_rec.beneficial_flag
      ,p_chosen_flag => p_rec.chosen_flag
      ,p_object_version_number => p_rec.object_version_number
      ,p_assignment_id_o
      => per_res_shd.g_old_rec.assignment_id
      ,p_start_date_o
      => per_res_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_res_shd.g_old_rec.end_date
      ,p_collective_agreement_id_o
      => per_res_shd.g_old_rec.collective_agreement_id
      ,p_cagr_entitlement_item_id_o
      => per_res_shd.g_old_rec.cagr_entitlement_item_id
      ,p_element_type_id_o
      => per_res_shd.g_old_rec.element_type_id
      ,p_input_value_id_o
      => per_res_shd.g_old_rec.input_value_id
      ,p_cagr_api_id_o
      => per_res_shd.g_old_rec.cagr_api_id
      ,p_cagr_api_param_id_o
      => per_res_shd.g_old_rec.cagr_api_param_id
      ,p_category_name_o
      => per_res_shd.g_old_rec.category_name
      ,p_cagr_entitlement_id_o
      => per_res_shd.g_old_rec.cagr_entitlement_id
      ,p_cagr_entitlement_line_id_o
      => per_res_shd.g_old_rec.cagr_entitlement_line_id
      ,p_value_o
      => per_res_shd.g_old_rec.value
      ,p_units_of_measure_o
      => per_res_shd.g_old_rec.units_of_measure
      ,p_range_from_o
      => per_res_shd.g_old_rec.range_from
      ,p_range_to_o
      => per_res_shd.g_old_rec.range_to
      ,p_grade_spine_id_o
      => per_res_shd.g_old_rec.grade_spine_id
      ,p_parent_spine_id_o
      => per_res_shd.g_old_rec.parent_spine_id
      ,p_step_id_o
      => per_res_shd.g_old_rec.step_id
      ,p_from_step_id_o
      => per_res_shd.g_old_rec.from_step_id
      ,p_to_step_id_o
      => per_res_shd.g_old_rec.to_step_id
      ,p_beneficial_flag_o
      => per_res_shd.g_old_rec.beneficial_flag
      ,p_oipl_id_o
      => per_res_shd.g_old_rec.oipl_id
      ,p_chosen_flag_o
      => per_res_shd.g_old_rec.chosen_flag
      ,p_column_type_o
      => per_res_shd.g_old_rec.column_type
      ,p_column_size_o
      => per_res_shd.g_old_rec.column_size
      ,p_cagr_request_id_o
      => per_res_shd.g_old_rec.cagr_request_id
      ,p_business_group_id_o
      => per_res_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => per_res_shd.g_old_rec.legislation_code
      ,p_eligy_prfl_id_o
      => per_res_shd.g_old_rec.eligy_prfl_id
      ,p_formula_id_o
      => per_res_shd.g_old_rec.formula_id
      ,p_object_version_number_o
      => per_res_shd.g_old_rec.object_version_number
      );
null;
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CAGR_ENTITLEMENT_RESULTS'
        ,p_hook_type   => 'AU');
      --
  end;
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy per_res_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    per_res_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_res_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_res_shd.g_old_rec.end_date;
  End If;
  If (p_rec.collective_agreement_id = hr_api.g_number) then
    p_rec.collective_agreement_id :=
    per_res_shd.g_old_rec.collective_agreement_id;
  End If;
  If (p_rec.cagr_entitlement_item_id = hr_api.g_number) then
    p_rec.cagr_entitlement_item_id :=
    per_res_shd.g_old_rec.cagr_entitlement_item_id;
  End If;
  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    per_res_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.input_value_id = hr_api.g_number) then
    p_rec.input_value_id :=
    per_res_shd.g_old_rec.input_value_id;
  End If;
  If (p_rec.cagr_api_id = hr_api.g_number) then
    p_rec.cagr_api_id :=
    per_res_shd.g_old_rec.cagr_api_id;
  End If;
  If (p_rec.cagr_api_param_id = hr_api.g_number) then
    p_rec.cagr_api_param_id :=
    per_res_shd.g_old_rec.cagr_api_param_id;
  End If;
  If (p_rec.category_name = hr_api.g_varchar2) then
    p_rec.category_name :=
    per_res_shd.g_old_rec.category_name;
  End If;
  If (p_rec.cagr_entitlement_id = hr_api.g_number) then
    p_rec.cagr_entitlement_id :=
    per_res_shd.g_old_rec.cagr_entitlement_id;
  End If;
  If (p_rec.cagr_entitlement_line_id = hr_api.g_number) then
    p_rec.cagr_entitlement_line_id :=
    per_res_shd.g_old_rec.cagr_entitlement_line_id;
  End If;
  If (p_rec.value = hr_api.g_varchar2) then
    p_rec.value :=
    per_res_shd.g_old_rec.value;
  End If;
  If (p_rec.units_of_measure = hr_api.g_varchar2) then
    p_rec.units_of_measure :=
    per_res_shd.g_old_rec.units_of_measure;
  End If;
  If (p_rec.range_from = hr_api.g_varchar2) then
    p_rec.range_from :=
    per_res_shd.g_old_rec.range_from;
  End If;
  If (p_rec.range_to = hr_api.g_varchar2) then
    p_rec.range_to :=
    per_res_shd.g_old_rec.range_to;
  End If;
  If (p_rec.grade_spine_id = hr_api.g_number) then
    p_rec.grade_spine_id :=
    per_res_shd.g_old_rec.grade_spine_id;
  End If;
  If (p_rec.parent_spine_id = hr_api.g_number) then
    p_rec.parent_spine_id :=
    per_res_shd.g_old_rec.parent_spine_id;
  End If;
  If (p_rec.step_id = hr_api.g_number) then
    p_rec.step_id :=
    per_res_shd.g_old_rec.step_id;
  End If;
  If (p_rec.from_step_id = hr_api.g_number) then
    p_rec.from_step_id :=
    per_res_shd.g_old_rec.from_step_id;
  End If;
  If (p_rec.to_step_id = hr_api.g_number) then
    p_rec.to_step_id :=
    per_res_shd.g_old_rec.to_step_id;
  End If;
  If (p_rec.beneficial_flag = hr_api.g_varchar2) then
    p_rec.beneficial_flag :=
    per_res_shd.g_old_rec.beneficial_flag;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    per_res_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.chosen_flag = hr_api.g_varchar2) then
    p_rec.chosen_flag :=
    per_res_shd.g_old_rec.chosen_flag;
  End If;
  If (p_rec.column_type = hr_api.g_varchar2) then
    p_rec.column_type :=
    per_res_shd.g_old_rec.column_type;
  End If;
  If (p_rec.column_size = hr_api.g_number) then
    p_rec.column_size :=
    per_res_shd.g_old_rec.column_size;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_res_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    per_res_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.eligy_prfl_id = hr_api.g_number) then
    p_rec.eligy_prfl_id :=
    per_res_shd.g_old_rec.eligy_prfl_id;
  End If;
  If (p_rec.formula_id = hr_api.g_number) then
    p_rec.formula_id :=
    per_res_shd.g_old_rec.formula_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_res_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_res_shd.lck
    (p_rec.cagr_entitlement_result_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  per_res_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  per_res_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_res_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_res_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_cagr_entitlement_result_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_chosen_flag                  in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   per_res_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_res_shd.convert_args
  (p_cagr_entitlement_result_id
  ,hr_api.g_number
  ,hr_api.g_date
  ,hr_api.g_date
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,hr_api.g_varchar2
  ,hr_api.g_varchar2
  ,hr_api.g_varchar2
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,hr_api.g_number
  ,p_chosen_flag          -- this and ovn are only attributes that can be updated
  ,hr_api.g_varchar2
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,hr_api.g_number
  ,hr_api.g_number
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_res_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_res_upd;

/
