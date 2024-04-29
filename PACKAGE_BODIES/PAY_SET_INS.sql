--------------------------------------------------------
--  DDL for Package Body PAY_SET_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SET_INS" as
/* $Header: pysetrhi.pkb 120.0 2005/05/29 08:39:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_set_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy pay_set_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pay_shadow_element_types
  --
  insert into pay_shadow_element_types
  (	element_type_id,
	template_id,
	classification_name,
	additional_entry_allowed_flag,
	adjustment_only_flag,
	closed_for_entry_flag,
	element_name,
	indirect_only_flag,
	multiple_entries_allowed_flag,
	multiply_value_flag,
	post_termination_rule,
	process_in_run_flag,
	relative_processing_priority,
	processing_type,
	standard_link_flag,
	input_currency_code,
	output_currency_code,
	benefit_classification_name,
	description,
	qualifying_age,
	qualifying_length_of_service,
	qualifying_units,
	reporting_name,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
	element_information_category,
	element_information1,
	element_information2,
	element_information3,
	element_information4,
	element_information5,
	element_information6,
	element_information7,
	element_information8,
	element_information9,
	element_information10,
	element_information11,
	element_information12,
	element_information13,
	element_information14,
	element_information15,
	element_information16,
	element_information17,
	element_information18,
	element_information19,
	element_information20,
	third_party_pay_only_flag,
	skip_formula,
	payroll_formula_id,
	exclusion_rule_id,
        iterative_flag,
        iterative_priority,
        iterative_formula_name,
        process_mode,
        grossup_flag,
        advance_indicator,
        advance_payable,
        advance_deduction,
        process_advance_entry,
        proration_group,
        proration_formula,
        recalc_event_group,
        once_each_period_flag,
	object_version_number
  )
  Values
  (	p_rec.element_type_id,
	p_rec.template_id,
	p_rec.classification_name,
	p_rec.additional_entry_allowed_flag,
	p_rec.adjustment_only_flag,
	p_rec.closed_for_entry_flag,
	p_rec.element_name,
	p_rec.indirect_only_flag,
	p_rec.multiple_entries_allowed_flag,
	p_rec.multiply_value_flag,
	p_rec.post_termination_rule,
	p_rec.process_in_run_flag,
	p_rec.relative_processing_priority,
	p_rec.processing_type,
	p_rec.standard_link_flag,
	p_rec.input_currency_code,
	p_rec.output_currency_code,
	p_rec.benefit_classification_name,
	p_rec.description,
	p_rec.qualifying_age,
	p_rec.qualifying_length_of_service,
	p_rec.qualifying_units,
	p_rec.reporting_name,
	p_rec.attribute_category,
	p_rec.attribute1,
	p_rec.attribute2,
	p_rec.attribute3,
	p_rec.attribute4,
	p_rec.attribute5,
	p_rec.attribute6,
	p_rec.attribute7,
	p_rec.attribute8,
	p_rec.attribute9,
	p_rec.attribute10,
	p_rec.attribute11,
	p_rec.attribute12,
	p_rec.attribute13,
	p_rec.attribute14,
	p_rec.attribute15,
	p_rec.attribute16,
	p_rec.attribute17,
	p_rec.attribute18,
	p_rec.attribute19,
	p_rec.attribute20,
	p_rec.element_information_category,
	p_rec.element_information1,
	p_rec.element_information2,
	p_rec.element_information3,
	p_rec.element_information4,
	p_rec.element_information5,
	p_rec.element_information6,
	p_rec.element_information7,
	p_rec.element_information8,
	p_rec.element_information9,
	p_rec.element_information10,
	p_rec.element_information11,
	p_rec.element_information12,
	p_rec.element_information13,
	p_rec.element_information14,
	p_rec.element_information15,
	p_rec.element_information16,
	p_rec.element_information17,
	p_rec.element_information18,
	p_rec.element_information19,
	p_rec.element_information20,
	p_rec.third_party_pay_only_flag,
	p_rec.skip_formula,
	p_rec.payroll_formula_id,
	p_rec.exclusion_rule_id,
        p_rec.iterative_flag,
        p_rec.iterative_priority,
        p_rec.iterative_formula_name,
        p_rec.process_mode,
        p_rec.grossup_flag,
        p_rec.advance_indicator,
        p_rec.advance_payable,
        p_rec.advance_deduction,
        p_rec.process_advance_entry,
        p_rec.proration_group,
        p_rec.proration_formula,
        p_rec.recalc_event_group,
        p_rec.once_each_period_flag,
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy pay_set_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_shadow_element_types_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.element_type_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in pay_set_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date in            date
  ,p_rec            in out nocopy pay_set_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_set_bus.insert_validate(p_effective_date, p_rec);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_element_type_id              out nocopy number,
  p_effective_date               in date,
  p_template_id                  in number,
  p_classification_name          in varchar2,
  p_additional_entry_allowed_fla in varchar2,
  p_adjustment_only_flag         in varchar2,
  p_closed_for_entry_flag        in varchar2,
  p_element_name                 in varchar2,
  p_indirect_only_flag           in varchar2,
  p_multiple_entries_allowed_fla in varchar2,
  p_multiply_value_flag          in varchar2,
  p_post_termination_rule        in varchar2,
  p_process_in_run_flag          in varchar2,
  p_relative_processing_priority in number,
  p_processing_type              in varchar2         default null,
  p_standard_link_flag           in varchar2,
  p_input_currency_code          in varchar2         default null,
  p_output_currency_code         in varchar2         default null,
  p_benefit_classification_name  in varchar2         default null,
  p_description                  in varchar2         default null,
  p_qualifying_age               in number           default null,
  p_qualifying_length_of_service in number           default null,
  p_qualifying_units             in varchar2         default null,
  p_reporting_name               in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_element_information_category in varchar2         default null,
  p_element_information1         in varchar2         default null,
  p_element_information2         in varchar2         default null,
  p_element_information3         in varchar2         default null,
  p_element_information4         in varchar2         default null,
  p_element_information5         in varchar2         default null,
  p_element_information6         in varchar2         default null,
  p_element_information7         in varchar2         default null,
  p_element_information8         in varchar2         default null,
  p_element_information9         in varchar2         default null,
  p_element_information10        in varchar2         default null,
  p_element_information11        in varchar2         default null,
  p_element_information12        in varchar2         default null,
  p_element_information13        in varchar2         default null,
  p_element_information14        in varchar2         default null,
  p_element_information15        in varchar2         default null,
  p_element_information16        in varchar2         default null,
  p_element_information17        in varchar2         default null,
  p_element_information18        in varchar2         default null,
  p_element_information19        in varchar2         default null,
  p_element_information20        in varchar2         default null,
  p_third_party_pay_only_flag    in varchar2         default null,
  p_skip_formula                 in varchar2         default null,
  p_payroll_formula_id           in number           default null,
  p_exclusion_rule_id            in number           default null,
  p_iterative_flag               in varchar2         default null,
  p_iterative_priority           in number           default null,
  p_iterative_formula_name       in varchar2         default null,
  p_process_mode                 in varchar2         default null,
  p_grossup_flag                 in varchar2         default null,
  p_advance_indicator            in varchar2         default null,
  p_advance_payable              in varchar2         default null,
  p_advance_deduction            in varchar2         default null,
  p_process_advance_entry        in varchar2         default null,
  p_proration_group              in varchar2         default null,
  p_proration_formula            in varchar2         default null,
  p_recalc_event_group           in varchar2         default null,
  p_once_each_period_flag        in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  pay_set_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_set_shd.convert_args
  (
  null,
  p_template_id,
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
  null
  );
  --
  -- Having converted the arguments into the pay_set_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date, l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_element_type_id := l_rec.element_type_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_set_ins;

/
