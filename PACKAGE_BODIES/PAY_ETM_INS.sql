--------------------------------------------------------
--  DDL for Package Body PAY_ETM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ETM_INS" as
/* $Header: pyetmrhi.pkb 120.0 2005/05/29 04:42:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_etm_ins.';  -- Global package name
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
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml(p_rec in out nocopy pay_etm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Insert the row into: pay_element_templates
  --
  insert into pay_element_templates
  (	template_id,
	template_type,
	template_name,
	base_processing_priority,
	business_group_id,
	legislation_code,
	version_number,
	base_name,
	max_base_name_length,
	preference_info_category,
	preference_information1,
	preference_information2,
	preference_information3,
	preference_information4,
	preference_information5,
	preference_information6,
	preference_information7,
	preference_information8,
	preference_information9,
	preference_information10,
	preference_information11,
	preference_information12,
	preference_information13,
	preference_information14,
	preference_information15,
	preference_information16,
	preference_information17,
	preference_information18,
	preference_information19,
	preference_information20,
	preference_information21,
	preference_information22,
	preference_information23,
	preference_information24,
	preference_information25,
	preference_information26,
	preference_information27,
	preference_information28,
	preference_information29,
	preference_information30,
	configuration_info_category,
	configuration_information1,
	configuration_information2,
	configuration_information3,
	configuration_information4,
	configuration_information5,
	configuration_information6,
	configuration_information7,
	configuration_information8,
	configuration_information9,
	configuration_information10,
	configuration_information11,
	configuration_information12,
	configuration_information13,
	configuration_information14,
	configuration_information15,
	configuration_information16,
	configuration_information17,
	configuration_information18,
	configuration_information19,
	configuration_information20,
	configuration_information21,
	configuration_information22,
	configuration_information23,
	configuration_information24,
	configuration_information25,
	configuration_information26,
	configuration_information27,
	configuration_information28,
	configuration_information29,
	configuration_information30,
	object_version_number
  )
  Values
  (	p_rec.template_id,
	p_rec.template_type,
	p_rec.template_name,
	p_rec.base_processing_priority,
	p_rec.business_group_id,
	p_rec.legislation_code,
	p_rec.version_number,
	p_rec.base_name,
	p_rec.max_base_name_length,
	p_rec.preference_info_category,
	p_rec.preference_information1,
	p_rec.preference_information2,
	p_rec.preference_information3,
	p_rec.preference_information4,
	p_rec.preference_information5,
	p_rec.preference_information6,
	p_rec.preference_information7,
	p_rec.preference_information8,
	p_rec.preference_information9,
	p_rec.preference_information10,
	p_rec.preference_information11,
	p_rec.preference_information12,
	p_rec.preference_information13,
	p_rec.preference_information14,
	p_rec.preference_information15,
	p_rec.preference_information16,
	p_rec.preference_information17,
	p_rec.preference_information18,
	p_rec.preference_information19,
	p_rec.preference_information20,
	p_rec.preference_information21,
	p_rec.preference_information22,
	p_rec.preference_information23,
	p_rec.preference_information24,
	p_rec.preference_information25,
	p_rec.preference_information26,
	p_rec.preference_information27,
	p_rec.preference_information28,
	p_rec.preference_information29,
	p_rec.preference_information30,
	p_rec.configuration_info_category,
	p_rec.configuration_information1,
	p_rec.configuration_information2,
	p_rec.configuration_information3,
	p_rec.configuration_information4,
	p_rec.configuration_information5,
	p_rec.configuration_information6,
	p_rec.configuration_information7,
	p_rec.configuration_information8,
	p_rec.configuration_information9,
	p_rec.configuration_information10,
	p_rec.configuration_information11,
	p_rec.configuration_information12,
	p_rec.configuration_information13,
	p_rec.configuration_information14,
	p_rec.configuration_information15,
	p_rec.configuration_information16,
	p_rec.configuration_information17,
	p_rec.configuration_information18,
	p_rec.configuration_information19,
	p_rec.configuration_information20,
	p_rec.configuration_information21,
	p_rec.configuration_information22,
	p_rec.configuration_information23,
	p_rec.configuration_information24,
	p_rec.configuration_information25,
	p_rec.configuration_information26,
	p_rec.configuration_information27,
	p_rec.configuration_information28,
	p_rec.configuration_information29,
	p_rec.configuration_information30,
	p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_etm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_etm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_etm_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pay_etm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_element_templates_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.template_id;
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
Procedure post_insert(p_rec in pay_etm_shd.g_rec_type) is
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
  (p_effective_date  in     date
  ,p_rec             in out nocopy pay_etm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_etm_bus.insert_validate(p_effective_date, p_rec);
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
  p_template_id                  out nocopy number,
  p_effective_date               in date,
  p_template_type                in varchar2,
  p_template_name                in varchar2,
  p_base_processing_priority     in number,
  p_business_group_id            in number           default null,
  p_legislation_code             in varchar2         default null,
  p_version_number               in number,
  p_base_name                    in varchar2         default null,
  p_max_base_name_length         in number,
  p_preference_info_category     in varchar2         default null,
  p_preference_information1      in varchar2         default null,
  p_preference_information2      in varchar2         default null,
  p_preference_information3      in varchar2         default null,
  p_preference_information4      in varchar2         default null,
  p_preference_information5      in varchar2         default null,
  p_preference_information6      in varchar2         default null,
  p_preference_information7      in varchar2         default null,
  p_preference_information8      in varchar2         default null,
  p_preference_information9      in varchar2         default null,
  p_preference_information10     in varchar2         default null,
  p_preference_information11     in varchar2         default null,
  p_preference_information12     in varchar2         default null,
  p_preference_information13     in varchar2         default null,
  p_preference_information14     in varchar2         default null,
  p_preference_information15     in varchar2         default null,
  p_preference_information16     in varchar2         default null,
  p_preference_information17     in varchar2         default null,
  p_preference_information18     in varchar2         default null,
  p_preference_information19     in varchar2         default null,
  p_preference_information20     in varchar2         default null,
  p_preference_information21     in varchar2         default null,
  p_preference_information22     in varchar2         default null,
  p_preference_information23     in varchar2         default null,
  p_preference_information24     in varchar2         default null,
  p_preference_information25     in varchar2         default null,
  p_preference_information26     in varchar2         default null,
  p_preference_information27     in varchar2         default null,
  p_preference_information28     in varchar2         default null,
  p_preference_information29     in varchar2         default null,
  p_preference_information30     in varchar2         default null,
  p_configuration_info_category  in varchar2         default null,
  p_configuration_information1   in varchar2         default null,
  p_configuration_information2   in varchar2         default null,
  p_configuration_information3   in varchar2         default null,
  p_configuration_information4   in varchar2         default null,
  p_configuration_information5   in varchar2         default null,
  p_configuration_information6   in varchar2         default null,
  p_configuration_information7   in varchar2         default null,
  p_configuration_information8   in varchar2         default null,
  p_configuration_information9   in varchar2         default null,
  p_configuration_information10  in varchar2         default null,
  p_configuration_information11  in varchar2         default null,
  p_configuration_information12  in varchar2         default null,
  p_configuration_information13  in varchar2         default null,
  p_configuration_information14  in varchar2         default null,
  p_configuration_information15  in varchar2         default null,
  p_configuration_information16  in varchar2         default null,
  p_configuration_information17  in varchar2         default null,
  p_configuration_information18  in varchar2         default null,
  p_configuration_information19  in varchar2         default null,
  p_configuration_information20  in varchar2         default null,
  p_configuration_information21  in varchar2         default null,
  p_configuration_information22  in varchar2         default null,
  p_configuration_information23  in varchar2         default null,
  p_configuration_information24  in varchar2         default null,
  p_configuration_information25  in varchar2         default null,
  p_configuration_information26  in varchar2         default null,
  p_configuration_information27  in varchar2         default null,
  p_configuration_information28  in varchar2         default null,
  p_configuration_information29  in varchar2         default null,
  p_configuration_information30  in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  pay_etm_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_etm_shd.convert_args
  (
  null,
  p_template_type,
  p_template_name,
  p_base_processing_priority,
  p_business_group_id,
  p_legislation_code,
  p_version_number,
  p_base_name,
  p_max_base_name_length,
  p_preference_info_category,
  p_preference_information1,
  p_preference_information2,
  p_preference_information3,
  p_preference_information4,
  p_preference_information5,
  p_preference_information6,
  p_preference_information7,
  p_preference_information8,
  p_preference_information9,
  p_preference_information10,
  p_preference_information11,
  p_preference_information12,
  p_preference_information13,
  p_preference_information14,
  p_preference_information15,
  p_preference_information16,
  p_preference_information17,
  p_preference_information18,
  p_preference_information19,
  p_preference_information20,
  p_preference_information21,
  p_preference_information22,
  p_preference_information23,
  p_preference_information24,
  p_preference_information25,
  p_preference_information26,
  p_preference_information27,
  p_preference_information28,
  p_preference_information29,
  p_preference_information30,
  p_configuration_info_category,
  p_configuration_information1,
  p_configuration_information2,
  p_configuration_information3,
  p_configuration_information4,
  p_configuration_information5,
  p_configuration_information6,
  p_configuration_information7,
  p_configuration_information8,
  p_configuration_information9,
  p_configuration_information10,
  p_configuration_information11,
  p_configuration_information12,
  p_configuration_information13,
  p_configuration_information14,
  p_configuration_information15,
  p_configuration_information16,
  p_configuration_information17,
  p_configuration_information18,
  p_configuration_information19,
  p_configuration_information20,
  p_configuration_information21,
  p_configuration_information22,
  p_configuration_information23,
  p_configuration_information24,
  p_configuration_information25,
  p_configuration_information26,
  p_configuration_information27,
  p_configuration_information28,
  p_configuration_information29,
  p_configuration_information30,
  null
  );
  --
  -- Having converted the arguments into the pay_etm_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date, l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_template_id := l_rec.template_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_etm_ins;

/
