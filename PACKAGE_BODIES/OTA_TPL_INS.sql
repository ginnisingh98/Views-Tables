--------------------------------------------------------
--  DDL for Package Body OTA_TPL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPL_INS" as
/* $Header: ottpl01t.pkb 115.2 99/07/16 00:55:57 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tpl_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of this
--   procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out ota_tpl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_tpl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_price_lists
  --
  insert into ota_price_lists
  (	price_list_id,
	business_group_id,
	currency_code,
	default_flag,
	name,
	object_version_number,
	price_list_type,
	start_date,
	comments,
	description,
	end_date,
	single_unit_price,
	training_unit_type,
	tpl_information_category,
	tpl_information1,
	tpl_information2,
	tpl_information3,
	tpl_information4,
	tpl_information5,
	tpl_information6,
	tpl_information7,
	tpl_information8,
	tpl_information9,
	tpl_information10,
	tpl_information11,
	tpl_information12,
	tpl_information13,
	tpl_information14,
	tpl_information15,
	tpl_information16,
	tpl_information17,
	tpl_information18,
	tpl_information19,
	tpl_information20
  )
  Values
  (	p_rec.price_list_id,
	p_rec.business_group_id,
	p_rec.currency_code,
	p_rec.default_flag,
	p_rec.name,
	p_rec.object_version_number,
	p_rec.price_list_type,
	p_rec.start_date,
	p_rec.comments,
	p_rec.description,
	p_rec.end_date,
	p_rec.single_unit_price,
	p_rec.training_unit_type,
	p_rec.tpl_information_category,
	p_rec.tpl_information1,
	p_rec.tpl_information2,
	p_rec.tpl_information3,
	p_rec.tpl_information4,
	p_rec.tpl_information5,
	p_rec.tpl_information6,
	p_rec.tpl_information7,
	p_rec.tpl_information8,
	p_rec.tpl_information9,
	p_rec.tpl_information10,
	p_rec.tpl_information11,
	p_rec.tpl_information12,
	p_rec.tpl_information13,
	p_rec.tpl_information14,
	p_rec.tpl_information15,
	p_rec.tpl_information16,
	p_rec.tpl_information17,
	p_rec.tpl_information18,
	p_rec.tpl_information19,
	p_rec.tpl_information20
  );
  --
  ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tpl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tpl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tpl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out ota_tpl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_price_lists_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.price_list_id;
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
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ota_tpl_shd.g_rec_type) is
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
  (
  p_rec        in out ota_tpl_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_ota_tpl;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_tpl_bus.insert_validate(p_rec);
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
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
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
    ROLLBACK TO ins_ota_tpl;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_price_list_id                out number,
  p_business_group_id            in number,
  p_currency_code                in varchar2,
  p_default_flag                 in varchar2,
  p_name                         in varchar2,
  p_object_version_number        out number,
  p_price_list_type              in varchar2,
  p_start_date                   in date,
  p_comments                     in varchar2         default null,
  p_description                  in varchar2         default null,
  p_end_date                     in date             default null,
  p_single_unit_price            in number           default null,
  p_training_unit_type           in varchar2         default null,
  p_tpl_information_category     in varchar2         default null,
  p_tpl_information1             in varchar2         default null,
  p_tpl_information2             in varchar2         default null,
  p_tpl_information3             in varchar2         default null,
  p_tpl_information4             in varchar2         default null,
  p_tpl_information5             in varchar2         default null,
  p_tpl_information6             in varchar2         default null,
  p_tpl_information7             in varchar2         default null,
  p_tpl_information8             in varchar2         default null,
  p_tpl_information9             in varchar2         default null,
  p_tpl_information10            in varchar2         default null,
  p_tpl_information11            in varchar2         default null,
  p_tpl_information12            in varchar2         default null,
  p_tpl_information13            in varchar2         default null,
  p_tpl_information14            in varchar2         default null,
  p_tpl_information15            in varchar2         default null,
  p_tpl_information16            in varchar2         default null,
  p_tpl_information17            in varchar2         default null,
  p_tpl_information18            in varchar2         default null,
  p_tpl_information19            in varchar2         default null,
  p_tpl_information20            in varchar2         default null,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ota_tpl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_tpl_shd.convert_args
  (
  null,
  p_business_group_id,
  p_currency_code,
  p_default_flag,
  p_name,
  null,
  p_price_list_type,
  p_start_date,
  p_comments,
  p_description,
  p_end_date,
  p_single_unit_price,
  p_training_unit_type,
  p_tpl_information_category,
  p_tpl_information1,
  p_tpl_information2,
  p_tpl_information3,
  p_tpl_information4,
  p_tpl_information5,
  p_tpl_information6,
  p_tpl_information7,
  p_tpl_information8,
  p_tpl_information9,
  p_tpl_information10,
  p_tpl_information11,
  p_tpl_information12,
  p_tpl_information13,
  p_tpl_information14,
  p_tpl_information15,
  p_tpl_information16,
  p_tpl_information17,
  p_tpl_information18,
  p_tpl_information19,
  p_tpl_information20
  );
  --
  -- Having converted the arguments into the ota_tpl_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_price_list_id := l_rec.price_list_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_tpl_ins;

/
