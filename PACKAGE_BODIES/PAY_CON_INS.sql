--------------------------------------------------------
--  DDL for Package Body PAY_CON_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CON_INS" as
/* $Header: pyconrhi.pkb 115.3 1999/12/03 16:45:29 pkm ship      $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_con_ins.';  -- Global package name
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
--   2) To set and unset the g_api_dml status as required (as we are about to
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
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml(p_rec in out pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pay_con_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_us_contribution_history
  --
  insert into pay_us_contribution_history
  (	contr_history_id,
	person_id,
	date_from,
	date_to,
	contr_type,
	business_group_id,
	legislation_code,
	amt_contr,
	max_contr_allowed,
	includable_comp,
	tax_unit_id,
	source_system,
	contr_information_category,
	contr_information1,
	contr_information2,
	contr_information3,
	contr_information4,
	contr_information5,
	contr_information6,
	contr_information7,
	contr_information8,
	contr_information9,
	contr_information10,
	contr_information11,
	contr_information12,
	contr_information13,
	contr_information14,
	contr_information15,
	contr_information16,
	contr_information17,
	contr_information18,
	contr_information19,
	contr_information20,
	contr_information21,
	contr_information22,
	contr_information23,
	contr_information24,
	contr_information25,
	contr_information26,
	contr_information27,
	contr_information28,
	contr_information29,
	contr_information30,
	object_version_number
  )
  Values
  (	p_rec.contr_history_id,
	p_rec.person_id,
	p_rec.date_from,
	p_rec.date_to,
	p_rec.contr_type,
	p_rec.business_group_id,
	p_rec.legislation_code,
	p_rec.amt_contr,
	p_rec.max_contr_allowed,
	p_rec.includable_comp,
	p_rec.tax_unit_id,
	p_rec.source_system,
	p_rec.contr_information_category,
	p_rec.contr_information1,
	p_rec.contr_information2,
	p_rec.contr_information3,
	p_rec.contr_information4,
	p_rec.contr_information5,
	p_rec.contr_information6,
	p_rec.contr_information7,
	p_rec.contr_information8,
	p_rec.contr_information9,
	p_rec.contr_information10,
	p_rec.contr_information11,
	p_rec.contr_information12,
	p_rec.contr_information13,
	p_rec.contr_information14,
	p_rec.contr_information15,
	p_rec.contr_information16,
	p_rec.contr_information17,
	p_rec.contr_information18,
	p_rec.contr_information19,
	p_rec.contr_information20,
	p_rec.contr_information21,
	p_rec.contr_information22,
	p_rec.contr_information23,
	p_rec.contr_information24,
	p_rec.contr_information25,
	p_rec.contr_information26,
	p_rec.contr_information27,
	p_rec.contr_information28,
	p_rec.contr_information29,
	p_rec.contr_information30,
	p_rec.object_version_number
  );
  --
  pay_con_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
    pay_con_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
    pay_con_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
    pay_con_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_us_contribution_history_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.contr_history_id;
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
Procedure post_insert(p_rec in pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pay_con_rki.after_insert
      (
  p_contr_history_id              =>p_rec.contr_history_id
 ,p_person_id                     =>p_rec.person_id
 ,p_date_from                     =>p_rec.date_from
 ,p_date_to                       =>p_rec.date_to
 ,p_contr_type                    =>p_rec.contr_type
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_legislation_code              =>p_rec.legislation_code
 ,p_amt_contr                     =>p_rec.amt_contr
 ,p_max_contr_allowed             =>p_rec.max_contr_allowed
 ,p_includable_comp               =>p_rec.includable_comp
 ,p_tax_unit_id                   =>p_rec.tax_unit_id
 ,p_source_system                 =>p_rec.source_system
 ,p_contr_information_category    =>p_rec.contr_information_category
 ,p_contr_information1            =>p_rec.contr_information1
 ,p_contr_information2            =>p_rec.contr_information2
 ,p_contr_information3            =>p_rec.contr_information3
 ,p_contr_information4            =>p_rec.contr_information4
 ,p_contr_information5            =>p_rec.contr_information5
 ,p_contr_information6            =>p_rec.contr_information6
 ,p_contr_information7            =>p_rec.contr_information7
 ,p_contr_information8            =>p_rec.contr_information8
 ,p_contr_information9            =>p_rec.contr_information9
 ,p_contr_information10           =>p_rec.contr_information10
 ,p_contr_information11           =>p_rec.contr_information11
 ,p_contr_information12           =>p_rec.contr_information12
 ,p_contr_information13           =>p_rec.contr_information13
 ,p_contr_information14           =>p_rec.contr_information14
 ,p_contr_information15           =>p_rec.contr_information15
 ,p_contr_information16           =>p_rec.contr_information16
 ,p_contr_information17           =>p_rec.contr_information17
 ,p_contr_information18           =>p_rec.contr_information18
 ,p_contr_information19           =>p_rec.contr_information19
 ,p_contr_information20           =>p_rec.contr_information20
 ,p_contr_information21           =>p_rec.contr_information21
 ,p_contr_information22           =>p_rec.contr_information22
 ,p_contr_information23           =>p_rec.contr_information23
 ,p_contr_information24           =>p_rec.contr_information24
 ,p_contr_information25           =>p_rec.contr_information25
 ,p_contr_information26           =>p_rec.contr_information26
 ,p_contr_information27           =>p_rec.contr_information27
 ,p_contr_information28           =>p_rec.contr_information28
 ,p_contr_information29           =>p_rec.contr_information29
 ,p_contr_information30           =>p_rec.contr_information30
 ,p_object_version_number         =>p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_contribution_history'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out pay_con_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_con_bus.insert_validate(p_rec);
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
  p_contr_history_id             out number,
  p_person_id                    in number,
  p_date_from                    in date,
  p_date_to                      in date,
  p_contr_type                   in varchar2,
  p_business_group_id            in number,
  p_legislation_code             in varchar2,
  p_amt_contr                    in number           default null,
  p_max_contr_allowed            in number           default null,
  p_includable_comp              in number           default null,
  p_tax_unit_id                  in number           default null,
  p_source_system                in varchar2         default null,
  p_contr_information_category   in varchar2         default null,
  p_contr_information1           in varchar2         default null,
  p_contr_information2           in varchar2         default null,
  p_contr_information3           in varchar2         default null,
  p_contr_information4           in varchar2         default null,
  p_contr_information5           in varchar2         default null,
  p_contr_information6           in varchar2         default null,
  p_contr_information7           in varchar2         default null,
  p_contr_information8           in varchar2         default null,
  p_contr_information9           in varchar2         default null,
  p_contr_information10          in varchar2         default null,
  p_contr_information11          in varchar2         default null,
  p_contr_information12          in varchar2         default null,
  p_contr_information13          in varchar2         default null,
  p_contr_information14          in varchar2         default null,
  p_contr_information15          in varchar2         default null,
  p_contr_information16          in varchar2         default null,
  p_contr_information17          in varchar2         default null,
  p_contr_information18          in varchar2         default null,
  p_contr_information19          in varchar2         default null,
  p_contr_information20          in varchar2         default null,
  p_contr_information21          in varchar2         default null,
  p_contr_information22          in varchar2         default null,
  p_contr_information23          in varchar2         default null,
  p_contr_information24          in varchar2         default null,
  p_contr_information25          in varchar2         default null,
  p_contr_information26          in varchar2         default null,
  p_contr_information27          in varchar2         default null,
  p_contr_information28          in varchar2         default null,
  p_contr_information29          in varchar2         default null,
  p_contr_information30          in varchar2         default null,
  p_object_version_number        out number
  ) is
--
  l_rec	  pay_con_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_con_shd.convert_args
  (
  null,
  p_person_id,
  p_date_from,
  p_date_to,
  p_contr_type,
  p_business_group_id,
  p_legislation_code,
  p_amt_contr,
  p_max_contr_allowed,
  p_includable_comp,
  p_tax_unit_id,
  p_source_system,
  p_contr_information_category,
  p_contr_information1,
  p_contr_information2,
  p_contr_information3,
  p_contr_information4,
  p_contr_information5,
  p_contr_information6,
  p_contr_information7,
  p_contr_information8,
  p_contr_information9,
  p_contr_information10,
  p_contr_information11,
  p_contr_information12,
  p_contr_information13,
  p_contr_information14,
  p_contr_information15,
  p_contr_information16,
  p_contr_information17,
  p_contr_information18,
  p_contr_information19,
  p_contr_information20,
  p_contr_information21,
  p_contr_information22,
  p_contr_information23,
  p_contr_information24,
  p_contr_information25,
  p_contr_information26,
  p_contr_information27,
  p_contr_information28,
  p_contr_information29,
  p_contr_information30,
  null
  );
  --
  -- Having converted the arguments into the pay_con_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_contr_history_id := l_rec.contr_history_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_con_ins;

/
