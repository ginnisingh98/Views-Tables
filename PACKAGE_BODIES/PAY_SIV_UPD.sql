--------------------------------------------------------
--  DDL for Package Body PAY_SIV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SIV_UPD" as
/* $Header: pysivrhi.pkb 120.0 2005/05/29 08:52:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_siv_upd.';  -- Global package name
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
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
Procedure update_dml(p_rec in out nocopy pay_siv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  -- Update the pay_shadow_input_values Row
  --
  update pay_shadow_input_values
  set
  input_value_id                    = p_rec.input_value_id,
  element_type_id                   = p_rec.element_type_id,
  display_sequence                  = p_rec.display_sequence,
  generate_db_items_flag            = p_rec.generate_db_items_flag,
  hot_default_flag                  = p_rec.hot_default_flag,
  mandatory_flag                    = p_rec.mandatory_flag,
  name                              = p_rec.name,
  uom                               = p_rec.uom,
  lookup_type                       = p_rec.lookup_type,
  default_value                     = p_rec.default_value,
  max_value                         = p_rec.max_value,
  min_value                         = p_rec.min_value,
  warning_or_error                  = p_rec.warning_or_error,
  default_value_column              = p_rec.default_value_column,
  exclusion_rule_id                 = p_rec.exclusion_rule_id,
  formula_id			    = p_rec.formula_id,
  input_validation_formula	    = p_rec.input_validation_formula,
  object_version_number             = p_rec.object_version_number
  where input_value_id = p_rec.input_value_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_siv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_siv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_siv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pay_siv_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in pay_siv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pay_siv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    pay_siv_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.display_sequence = hr_api.g_number) then
    p_rec.display_sequence :=
    pay_siv_shd.g_old_rec.display_sequence;
  End If;
  If (p_rec.generate_db_items_flag = hr_api.g_varchar2) then
    p_rec.generate_db_items_flag :=
    pay_siv_shd.g_old_rec.generate_db_items_flag;
  End If;
  If (p_rec.hot_default_flag = hr_api.g_varchar2) then
    p_rec.hot_default_flag :=
    pay_siv_shd.g_old_rec.hot_default_flag;
  End If;
  If (p_rec.mandatory_flag = hr_api.g_varchar2) then
    p_rec.mandatory_flag :=
    pay_siv_shd.g_old_rec.mandatory_flag;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    pay_siv_shd.g_old_rec.name;
  End If;
  If (p_rec.uom = hr_api.g_varchar2) then
    p_rec.uom :=
    pay_siv_shd.g_old_rec.uom;
  End If;
  If (p_rec.lookup_type = hr_api.g_varchar2) then
    p_rec.lookup_type :=
    pay_siv_shd.g_old_rec.lookup_type;
  End If;
  If (p_rec.default_value = hr_api.g_varchar2) then
    p_rec.default_value :=
    pay_siv_shd.g_old_rec.default_value;
  End If;
  If (p_rec.max_value = hr_api.g_varchar2) then
    p_rec.max_value :=
    pay_siv_shd.g_old_rec.max_value;
  End If;
  If (p_rec.min_value = hr_api.g_varchar2) then
    p_rec.min_value :=
    pay_siv_shd.g_old_rec.min_value;
  End If;
  If (p_rec.warning_or_error = hr_api.g_varchar2) then
    p_rec.warning_or_error :=
    pay_siv_shd.g_old_rec.warning_or_error;
  End If;
  If (p_rec.default_value_column = hr_api.g_varchar2) then
    p_rec.default_value_column :=
    pay_siv_shd.g_old_rec.default_value_column;
  End If;
  If (p_rec.exclusion_rule_id = hr_api.g_number) then
    p_rec.exclusion_rule_id :=
    pay_siv_shd.g_old_rec.exclusion_rule_id;
  End If;
  If (p_rec.formula_id = hr_api.g_number) then
    p_rec.formula_id :=
    pay_siv_shd.g_old_rec.formula_id;
  End If;
  If (p_rec.input_validation_formula = hr_api.g_varchar2) then
    p_rec.input_validation_formula :=
    pay_siv_shd.g_old_rec.input_validation_formula;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in            date
  ,p_rec            in out nocopy pay_siv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_siv_shd.lck
	(
	p_rec.input_value_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_siv_bus.update_validate(p_effective_date, p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date               in date,
  p_input_value_id               in number,
  p_element_type_id              in number           default hr_api.g_number,
  p_display_sequence             in number           default hr_api.g_number,
  p_generate_db_items_flag       in varchar2         default hr_api.g_varchar2,
  p_hot_default_flag             in varchar2         default hr_api.g_varchar2,
  p_mandatory_flag               in varchar2         default hr_api.g_varchar2,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_uom                          in varchar2         default hr_api.g_varchar2,
  p_lookup_type                  in varchar2         default hr_api.g_varchar2,
  p_default_value                in varchar2         default hr_api.g_varchar2,
  p_max_value                    in varchar2         default hr_api.g_varchar2,
  p_min_value                    in varchar2         default hr_api.g_varchar2,
  p_warning_or_error             in varchar2         default hr_api.g_varchar2,
  p_default_value_column         in varchar2         default hr_api.g_varchar2,
  p_exclusion_rule_id            in number           default hr_api.g_number,
  p_formula_id                   in number           default hr_api.g_number,
  p_input_validation_formula	 in varchar2	     default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  pay_siv_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_siv_shd.convert_args
  (
  p_input_value_id,
  p_element_type_id,
  p_display_sequence,
  p_generate_db_items_flag,
  p_hot_default_flag,
  p_mandatory_flag,
  p_name,
  p_uom,
  p_lookup_type,
  p_default_value,
  p_max_value,
  p_min_value,
  p_warning_or_error,
  p_default_value_column,
  p_exclusion_rule_id,
  p_formula_id,
  p_input_validation_formula,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(p_effective_date, l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_siv_upd;

/
