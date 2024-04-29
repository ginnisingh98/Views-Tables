--------------------------------------------------------
--  DDL for Package Body PAY_SET_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SET_UPD" as
/* $Header: pysetrhi.pkb 120.0 2005/05/29 08:39:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_set_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pay_set_shd.g_rec_type) is
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
  -- Update the pay_shadow_element_types Row
  --
  update pay_shadow_element_types
  set
  classification_name               = p_rec.classification_name,
  additional_entry_allowed_flag     = p_rec.additional_entry_allowed_flag,
  adjustment_only_flag              = p_rec.adjustment_only_flag,
  closed_for_entry_flag             = p_rec.closed_for_entry_flag,
  element_name                      = p_rec.element_name,
  indirect_only_flag                = p_rec.indirect_only_flag,
  multiple_entries_allowed_flag     = p_rec.multiple_entries_allowed_flag,
  multiply_value_flag               = p_rec.multiply_value_flag,
  post_termination_rule             = p_rec.post_termination_rule,
  process_in_run_flag               = p_rec.process_in_run_flag,
  relative_processing_priority      = p_rec.relative_processing_priority,
  processing_type                   = p_rec.processing_type,
  standard_link_flag                = p_rec.standard_link_flag,
  input_currency_code               = p_rec.input_currency_code,
  output_currency_code              = p_rec.output_currency_code,
  benefit_classification_name       = p_rec.benefit_classification_name,
  description                       = p_rec.description,
  qualifying_age                    = p_rec.qualifying_age,
  qualifying_length_of_service      = p_rec.qualifying_length_of_service,
  qualifying_units                  = p_rec.qualifying_units,
  reporting_name                    = p_rec.reporting_name,
  attribute_category                = p_rec.attribute_category,
  attribute1                        = p_rec.attribute1,
  attribute2                        = p_rec.attribute2,
  attribute3                        = p_rec.attribute3,
  attribute4                        = p_rec.attribute4,
  attribute5                        = p_rec.attribute5,
  attribute6                        = p_rec.attribute6,
  attribute7                        = p_rec.attribute7,
  attribute8                        = p_rec.attribute8,
  attribute9                        = p_rec.attribute9,
  attribute10                       = p_rec.attribute10,
  attribute11                       = p_rec.attribute11,
  attribute12                       = p_rec.attribute12,
  attribute13                       = p_rec.attribute13,
  attribute14                       = p_rec.attribute14,
  attribute15                       = p_rec.attribute15,
  attribute16                       = p_rec.attribute16,
  attribute17                       = p_rec.attribute17,
  attribute18                       = p_rec.attribute18,
  attribute19                       = p_rec.attribute19,
  attribute20                       = p_rec.attribute20,
  element_information_category      = p_rec.element_information_category,
  element_information1              = p_rec.element_information1,
  element_information2              = p_rec.element_information2,
  element_information3              = p_rec.element_information3,
  element_information4              = p_rec.element_information4,
  element_information5              = p_rec.element_information5,
  element_information6              = p_rec.element_information6,
  element_information7              = p_rec.element_information7,
  element_information8              = p_rec.element_information8,
  element_information9              = p_rec.element_information9,
  element_information10             = p_rec.element_information10,
  element_information11             = p_rec.element_information11,
  element_information12             = p_rec.element_information12,
  element_information13             = p_rec.element_information13,
  element_information14             = p_rec.element_information14,
  element_information15             = p_rec.element_information15,
  element_information16             = p_rec.element_information16,
  element_information17             = p_rec.element_information17,
  element_information18             = p_rec.element_information18,
  element_information19             = p_rec.element_information19,
  element_information20             = p_rec.element_information20,
  third_party_pay_only_flag         = p_rec.third_party_pay_only_flag,
  skip_formula                      = p_rec.skip_formula,
  payroll_formula_id                = p_rec.payroll_formula_id,
  exclusion_rule_id                 = p_rec.exclusion_rule_id,
  iterative_flag                    = p_rec.iterative_flag,
  iterative_priority                = p_rec.iterative_priority,
  iterative_formula_name            = p_rec.iterative_formula_name,
  process_mode                      = p_rec.process_mode,
  grossup_flag                      = p_rec.grossup_flag,
  advance_indicator                 = p_rec.advance_indicator,
  advance_payable                   = p_rec.advance_payable,
  advance_deduction                 = p_rec.advance_deduction,
  process_advance_entry             = p_rec.process_advance_entry,
  proration_group                   = p_rec.proration_group,
  proration_formula                 = p_rec.proration_formula,
  recalc_event_group                = p_rec.recalc_event_group,
  once_each_period_flag             = p_rec.once_each_period_flag,
  object_version_number             = p_rec.object_version_number
  where element_type_id = p_rec.element_type_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_set_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_set_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_set_shd.constraint_error
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
Procedure pre_update(p_rec in pay_set_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
Procedure post_update(p_rec in pay_set_shd.g_rec_type) is
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
Procedure convert_defs(p_rec in out nocopy pay_set_shd.g_rec_type) is
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
  If (p_rec.template_id = hr_api.g_number) then
    p_rec.template_id :=
    pay_set_shd.g_old_rec.template_id;
  End If;
  If (p_rec.classification_name = hr_api.g_varchar2) then
    p_rec.classification_name :=
    pay_set_shd.g_old_rec.classification_name;
  End If;
  If (p_rec.additional_entry_allowed_flag = hr_api.g_varchar2) then
    p_rec.additional_entry_allowed_flag :=
    pay_set_shd.g_old_rec.additional_entry_allowed_flag;
  End If;
  If (p_rec.adjustment_only_flag = hr_api.g_varchar2) then
    p_rec.adjustment_only_flag :=
    pay_set_shd.g_old_rec.adjustment_only_flag;
  End If;
  If (p_rec.closed_for_entry_flag = hr_api.g_varchar2) then
    p_rec.closed_for_entry_flag :=
    pay_set_shd.g_old_rec.closed_for_entry_flag;
  End If;
  If (p_rec.element_name = hr_api.g_varchar2) then
    p_rec.element_name :=
    pay_set_shd.g_old_rec.element_name;
  End If;
  If (p_rec.indirect_only_flag = hr_api.g_varchar2) then
    p_rec.indirect_only_flag :=
    pay_set_shd.g_old_rec.indirect_only_flag;
  End If;
  If (p_rec.multiple_entries_allowed_flag = hr_api.g_varchar2) then
    p_rec.multiple_entries_allowed_flag :=
    pay_set_shd.g_old_rec.multiple_entries_allowed_flag;
  End If;
  If (p_rec.multiply_value_flag = hr_api.g_varchar2) then
    p_rec.multiply_value_flag :=
    pay_set_shd.g_old_rec.multiply_value_flag;
  End If;
  If (p_rec.post_termination_rule = hr_api.g_varchar2) then
    p_rec.post_termination_rule :=
    pay_set_shd.g_old_rec.post_termination_rule;
  End If;
  If (p_rec.process_in_run_flag = hr_api.g_varchar2) then
    p_rec.process_in_run_flag :=
    pay_set_shd.g_old_rec.process_in_run_flag;
  End If;
  If (p_rec.relative_processing_priority = hr_api.g_number) then
    p_rec.relative_processing_priority :=
    pay_set_shd.g_old_rec.relative_processing_priority;
  End If;
  If (p_rec.processing_type = hr_api.g_varchar2) then
    p_rec.processing_type :=
    pay_set_shd.g_old_rec.processing_type;
  End If;
  If (p_rec.standard_link_flag = hr_api.g_varchar2) then
    p_rec.standard_link_flag :=
    pay_set_shd.g_old_rec.standard_link_flag;
  End If;
  If (p_rec.input_currency_code = hr_api.g_varchar2) then
    p_rec.input_currency_code :=
    pay_set_shd.g_old_rec.input_currency_code;
  End If;
  If (p_rec.output_currency_code = hr_api.g_varchar2) then
    p_rec.output_currency_code :=
    pay_set_shd.g_old_rec.output_currency_code;
  End If;
  If (p_rec.benefit_classification_name = hr_api.g_varchar2) then
    p_rec.benefit_classification_name :=
    pay_set_shd.g_old_rec.benefit_classification_name;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pay_set_shd.g_old_rec.description;
  End If;
  If (p_rec.qualifying_age = hr_api.g_number) then
    p_rec.qualifying_age :=
    pay_set_shd.g_old_rec.qualifying_age;
  End If;
  If (p_rec.qualifying_length_of_service = hr_api.g_number) then
    p_rec.qualifying_length_of_service :=
    pay_set_shd.g_old_rec.qualifying_length_of_service;
  End If;
  If (p_rec.qualifying_units = hr_api.g_varchar2) then
    p_rec.qualifying_units :=
    pay_set_shd.g_old_rec.qualifying_units;
  End If;
  If (p_rec.reporting_name = hr_api.g_varchar2) then
    p_rec.reporting_name :=
    pay_set_shd.g_old_rec.reporting_name;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pay_set_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pay_set_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pay_set_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pay_set_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pay_set_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pay_set_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pay_set_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pay_set_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pay_set_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pay_set_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pay_set_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pay_set_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pay_set_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pay_set_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pay_set_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pay_set_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pay_set_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pay_set_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pay_set_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pay_set_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pay_set_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.element_information_category = hr_api.g_varchar2) then
    p_rec.element_information_category :=
    pay_set_shd.g_old_rec.element_information_category;
  End If;
  If (p_rec.element_information1 = hr_api.g_varchar2) then
    p_rec.element_information1 :=
    pay_set_shd.g_old_rec.element_information1;
  End If;
  If (p_rec.element_information2 = hr_api.g_varchar2) then
    p_rec.element_information2 :=
    pay_set_shd.g_old_rec.element_information2;
  End If;
  If (p_rec.element_information3 = hr_api.g_varchar2) then
    p_rec.element_information3 :=
    pay_set_shd.g_old_rec.element_information3;
  End If;
  If (p_rec.element_information4 = hr_api.g_varchar2) then
    p_rec.element_information4 :=
    pay_set_shd.g_old_rec.element_information4;
  End If;
  If (p_rec.element_information5 = hr_api.g_varchar2) then
    p_rec.element_information5 :=
    pay_set_shd.g_old_rec.element_information5;
  End If;
  If (p_rec.element_information6 = hr_api.g_varchar2) then
    p_rec.element_information6 :=
    pay_set_shd.g_old_rec.element_information6;
  End If;
  If (p_rec.element_information7 = hr_api.g_varchar2) then
    p_rec.element_information7 :=
    pay_set_shd.g_old_rec.element_information7;
  End If;
  If (p_rec.element_information8 = hr_api.g_varchar2) then
    p_rec.element_information8 :=
    pay_set_shd.g_old_rec.element_information8;
  End If;
  If (p_rec.element_information9 = hr_api.g_varchar2) then
    p_rec.element_information9 :=
    pay_set_shd.g_old_rec.element_information9;
  End If;
  If (p_rec.element_information10 = hr_api.g_varchar2) then
    p_rec.element_information10 :=
    pay_set_shd.g_old_rec.element_information10;
  End If;
  If (p_rec.element_information11 = hr_api.g_varchar2) then
    p_rec.element_information11 :=
    pay_set_shd.g_old_rec.element_information11;
  End If;
  If (p_rec.element_information12 = hr_api.g_varchar2) then
    p_rec.element_information12 :=
    pay_set_shd.g_old_rec.element_information12;
  End If;
  If (p_rec.element_information13 = hr_api.g_varchar2) then
    p_rec.element_information13 :=
    pay_set_shd.g_old_rec.element_information13;
  End If;
  If (p_rec.element_information14 = hr_api.g_varchar2) then
    p_rec.element_information14 :=
    pay_set_shd.g_old_rec.element_information14;
  End If;
  If (p_rec.element_information15 = hr_api.g_varchar2) then
    p_rec.element_information15 :=
    pay_set_shd.g_old_rec.element_information15;
  End If;
  If (p_rec.element_information16 = hr_api.g_varchar2) then
    p_rec.element_information16 :=
    pay_set_shd.g_old_rec.element_information16;
  End If;
  If (p_rec.element_information17 = hr_api.g_varchar2) then
    p_rec.element_information17 :=
    pay_set_shd.g_old_rec.element_information17;
  End If;
  If (p_rec.element_information18 = hr_api.g_varchar2) then
    p_rec.element_information18 :=
    pay_set_shd.g_old_rec.element_information18;
  End If;
  If (p_rec.element_information19 = hr_api.g_varchar2) then
    p_rec.element_information19 :=
    pay_set_shd.g_old_rec.element_information19;
  End If;
  If (p_rec.element_information20 = hr_api.g_varchar2) then
    p_rec.element_information20 :=
    pay_set_shd.g_old_rec.element_information20;
  End If;
  If (p_rec.third_party_pay_only_flag = hr_api.g_varchar2) then
    p_rec.third_party_pay_only_flag :=
    pay_set_shd.g_old_rec.third_party_pay_only_flag;
  End If;
  If (p_rec.skip_formula = hr_api.g_varchar2) then
    p_rec.skip_formula :=
    pay_set_shd.g_old_rec.skip_formula;
  End If;
  If (p_rec.payroll_formula_id = hr_api.g_number) then
    p_rec.payroll_formula_id :=
    pay_set_shd.g_old_rec.payroll_formula_id;
  End If;
  If (p_rec.exclusion_rule_id = hr_api.g_number) then
    p_rec.exclusion_rule_id :=
    pay_set_shd.g_old_rec.exclusion_rule_id;
  End If;
  If (p_rec.iterative_flag = hr_api.g_varchar2) then
    p_rec.iterative_flag :=
    pay_set_shd.g_old_rec.iterative_flag;
  End If;
  If (p_rec.iterative_priority = hr_api.g_number) then
    p_rec.iterative_priority :=
    pay_set_shd.g_old_rec.iterative_priority;
  End If;
  If (p_rec.iterative_formula_name = hr_api.g_varchar2) then
    p_rec.iterative_formula_name :=
    pay_set_shd.g_old_rec.iterative_formula_name;
  End If;
  If (p_rec.process_mode = hr_api.g_varchar2) then
    p_rec.process_mode :=
    pay_set_shd.g_old_rec.process_mode;
  End If;
  If (p_rec.grossup_flag = hr_api.g_varchar2) then
    p_rec.grossup_flag :=
    pay_set_shd.g_old_rec.grossup_flag;
  End If;
  If (p_rec.advance_indicator = hr_api.g_varchar2) then
    p_rec.advance_indicator :=
    pay_set_shd.g_old_rec.advance_indicator;
  End If;
  If (p_rec.advance_payable = hr_api.g_varchar2) then
    p_rec.advance_payable :=
    pay_set_shd.g_old_rec.advance_payable;
  End If;
  If (p_rec.advance_deduction = hr_api.g_varchar2) then
    p_rec.advance_deduction :=
    pay_set_shd.g_old_rec.advance_deduction;
  End If;
  If (p_rec.process_advance_entry = hr_api.g_varchar2) then
    p_rec.process_advance_entry :=
    pay_set_shd.g_old_rec.process_advance_entry;
  End If;
  If (p_rec.proration_group = hr_api.g_varchar2) then
    p_rec.proration_group :=
    pay_set_shd.g_old_rec.proration_group;
  End If;
  If (p_rec.proration_formula = hr_api.g_varchar2) then
    p_rec.proration_formula :=
    pay_set_shd.g_old_rec.proration_formula;
  End If;
  If (p_rec.recalc_event_group = hr_api.g_varchar2) then
    p_rec.recalc_event_group :=
    pay_set_shd.g_old_rec.recalc_event_group;
  End If;
  If (p_rec.once_each_period_flag = hr_api.g_varchar2) then
    p_rec.once_each_period_flag :=
    pay_set_shd.g_old_rec.once_each_period_flag;
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
  ,p_rec            in out nocopy pay_set_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_set_shd.lck
	(
	p_rec.element_type_id,
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
  pay_set_bus.update_validate(p_effective_date, p_rec);
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
  p_element_type_id              in number,
  p_classification_name          in varchar2         default hr_api.g_varchar2,
  p_additional_entry_allowed_fla in varchar2         default hr_api.g_varchar2,
  p_adjustment_only_flag         in varchar2         default hr_api.g_varchar2,
  p_closed_for_entry_flag        in varchar2         default hr_api.g_varchar2,
  p_element_name                 in varchar2         default hr_api.g_varchar2,
  p_indirect_only_flag           in varchar2         default hr_api.g_varchar2,
  p_multiple_entries_allowed_fla in varchar2         default hr_api.g_varchar2,
  p_multiply_value_flag          in varchar2         default hr_api.g_varchar2,
  p_post_termination_rule        in varchar2         default hr_api.g_varchar2,
  p_process_in_run_flag          in varchar2         default hr_api.g_varchar2,
  p_relative_processing_priority in number           default hr_api.g_number,
  p_processing_type              in varchar2         default hr_api.g_varchar2,
  p_standard_link_flag           in varchar2         default hr_api.g_varchar2,
  p_input_currency_code          in varchar2         default hr_api.g_varchar2,
  p_output_currency_code         in varchar2         default hr_api.g_varchar2,
  p_benefit_classification_name  in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_qualifying_age               in number           default hr_api.g_number,
  p_qualifying_length_of_service in number           default hr_api.g_number,
  p_qualifying_units             in varchar2         default hr_api.g_varchar2,
  p_reporting_name               in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_element_information_category in varchar2         default hr_api.g_varchar2,
  p_element_information1         in varchar2         default hr_api.g_varchar2,
  p_element_information2         in varchar2         default hr_api.g_varchar2,
  p_element_information3         in varchar2         default hr_api.g_varchar2,
  p_element_information4         in varchar2         default hr_api.g_varchar2,
  p_element_information5         in varchar2         default hr_api.g_varchar2,
  p_element_information6         in varchar2         default hr_api.g_varchar2,
  p_element_information7         in varchar2         default hr_api.g_varchar2,
  p_element_information8         in varchar2         default hr_api.g_varchar2,
  p_element_information9         in varchar2         default hr_api.g_varchar2,
  p_element_information10        in varchar2         default hr_api.g_varchar2,
  p_element_information11        in varchar2         default hr_api.g_varchar2,
  p_element_information12        in varchar2         default hr_api.g_varchar2,
  p_element_information13        in varchar2         default hr_api.g_varchar2,
  p_element_information14        in varchar2         default hr_api.g_varchar2,
  p_element_information15        in varchar2         default hr_api.g_varchar2,
  p_element_information16        in varchar2         default hr_api.g_varchar2,
  p_element_information17        in varchar2         default hr_api.g_varchar2,
  p_element_information18        in varchar2         default hr_api.g_varchar2,
  p_element_information19        in varchar2         default hr_api.g_varchar2,
  p_element_information20        in varchar2         default hr_api.g_varchar2,
  p_third_party_pay_only_flag    in varchar2         default hr_api.g_varchar2,
  p_skip_formula                 in varchar2         default hr_api.g_varchar2,
  p_payroll_formula_id           in number           default hr_api.g_number,
  p_exclusion_rule_id            in number           default hr_api.g_number,
  p_iterative_flag               in varchar2         default hr_api.g_varchar2,
  p_iterative_priority           in number           default hr_api.g_number,
  p_iterative_formula_name       in varchar2         default hr_api.g_varchar2,
  p_process_mode                 in varchar2         default hr_api.g_varchar2,
  p_grossup_flag                 in varchar2         default hr_api.g_varchar2,
  p_advance_indicator            in varchar2         default hr_api.g_varchar2,
  p_advance_payable              in varchar2         default hr_api.g_varchar2,
  p_advance_deduction            in varchar2         default hr_api.g_varchar2,
  p_process_advance_entry        in varchar2         default hr_api.g_varchar2,
  p_proration_group              in varchar2         default hr_api.g_varchar2,
  p_proration_formula            in varchar2         default hr_api.g_varchar2,
  p_recalc_event_group           in varchar2         default hr_api.g_varchar2,
  p_once_each_period_flag        in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  pay_set_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_set_shd.convert_args
  (
  p_element_type_id,
  hr_api.g_number,
  p_classification_name,
  p_additional_entry_allowed_fla,
  p_adjustment_only_flag,
  p_closed_for_entry_flag,
  p_element_name,
  p_indirect_only_flag,
  p_multiple_entries_allowed_fla,
  p_multiply_value_flag,
  p_post_termination_rule,
  p_process_in_run_flag,
  p_relative_processing_priority,
  p_processing_type,
  p_standard_link_flag,
  p_input_currency_code,
  p_output_currency_code,
  p_benefit_classification_name,
  p_description,
  p_qualifying_age,
  p_qualifying_length_of_service,
  p_qualifying_units,
  p_reporting_name,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
  p_element_information_category,
  p_element_information1,
  p_element_information2,
  p_element_information3,
  p_element_information4,
  p_element_information5,
  p_element_information6,
  p_element_information7,
  p_element_information8,
  p_element_information9,
  p_element_information10,
  p_element_information11,
  p_element_information12,
  p_element_information13,
  p_element_information14,
  p_element_information15,
  p_element_information16,
  p_element_information17,
  p_element_information18,
  p_element_information19,
  p_element_information20,
  p_third_party_pay_only_flag,
  p_skip_formula,
  p_payroll_formula_id,
  p_exclusion_rule_id,
  p_iterative_flag,
  p_iterative_priority,
  p_iterative_formula_name,
  p_process_mode,
  p_grossup_flag,
  p_advance_indicator,
  p_advance_payable,
  p_advance_deduction,
  p_process_advance_entry,
  p_proration_group,
  p_proration_formula,
  p_recalc_event_group,
  p_once_each_period_flag,
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
end pay_set_upd;

/
