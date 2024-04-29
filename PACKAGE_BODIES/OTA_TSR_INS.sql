--------------------------------------------------------
--  DDL for Package Body OTA_TSR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TSR_INS" as
/* $Header: ottsr01t.pkb 120.2 2005/08/08 23:27:40 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tsr_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_supplied_resource_id_i  number   default null;

-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_supplied_resource_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_tsr_ins.g_supplied_resource_id_i := p_supplied_resource_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
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
Procedure insert_dml(p_rec in out nocopy ota_tsr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_tsr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_suppliable_resources
  --
  insert into ota_suppliable_resources
  (	supplied_resource_id,
	vendor_id,
	business_group_id,
	resource_definition_id,
	consumable_flag,
	object_version_number,
	resource_type,
	start_date,
	comments,
	cost,
	cost_unit,
	currency_code,
	end_date,
	internal_address_line,
	lead_time,
	name,
	supplier_reference,
	tsr_information_category,
	tsr_information1,
	tsr_information2,
	tsr_information3,
	tsr_information4,
	tsr_information5,
	tsr_information6,
	tsr_information7,
	tsr_information8,
	tsr_information9,
	tsr_information10,
	tsr_information11,
	tsr_information12,
	tsr_information13,
	tsr_information14,
	tsr_information15,
	tsr_information16,
	tsr_information17,
	tsr_information18,
	tsr_information19,
	tsr_information20,
      training_center_id,
      location_id,
      trainer_id,
      special_instruction
  )
  Values
  (	p_rec.supplied_resource_id,
	p_rec.vendor_id,
	p_rec.business_group_id,
	p_rec.resource_definition_id,
	p_rec.consumable_flag,
	p_rec.object_version_number,
	p_rec.resource_type,
	p_rec.start_date,
	p_rec.comments,
	p_rec.cost,
	p_rec.cost_unit,
	p_rec.currency_code,
	p_rec.end_date,
	p_rec.internal_address_line,
	p_rec.lead_time,
	p_rec.name,
	p_rec.supplier_reference,
	p_rec.tsr_information_category,
	p_rec.tsr_information1,
	p_rec.tsr_information2,
	p_rec.tsr_information3,
	p_rec.tsr_information4,
	p_rec.tsr_information5,
	p_rec.tsr_information6,
	p_rec.tsr_information7,
	p_rec.tsr_information8,
	p_rec.tsr_information9,
	p_rec.tsr_information10,
	p_rec.tsr_information11,
	p_rec.tsr_information12,
	p_rec.tsr_information13,
	p_rec.tsr_information14,
	p_rec.tsr_information15,
	p_rec.tsr_information16,
	p_rec.tsr_information17,
	p_rec.tsr_information18,
	p_rec.tsr_information19,
	p_rec.tsr_information20,
      p_rec.training_center_id,
      p_rec.location_id,
      p_rec.trainer_id,
      p_rec.special_instruction
  );
  --
  ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tsr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tsr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tsr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ota_tsr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_suppliable_resources_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ota_suppliable_resources
     where supplied_resource_id =
             ota_tsr_ins.g_supplied_resource_id_i;
--

  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   If (ota_tsr_ins.g_supplied_resource_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','ota_suppliable_resources');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.supplied_resource_id :=
      ota_tsr_ins.g_supplied_resource_id_i;
    ota_tsr_ins.g_supplied_resource_id_i := null;
  Else
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.supplied_resource_id;
    Close C_Sel1;
  End If;
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
Procedure post_insert(p_rec in ota_tsr_shd.g_rec_type) is
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
  p_rec        in out nocopy ota_tsr_shd.g_rec_type,
  p_validate   in     boolean
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
    SAVEPOINT ins_ota_tsr;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_tsr_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_ota_tsr;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_supplied_resource_id         out nocopy number,
  p_vendor_id                    in number,
  p_business_group_id            in number,
  p_resource_definition_id       in number,
  p_consumable_flag              in varchar2,
  p_object_version_number        out nocopy number,
  p_resource_type                in varchar2,
  p_start_date                   in date,
  p_comments                     in varchar2,
  p_cost                         in number,
  p_cost_unit                    in varchar2,
  p_currency_code                in varchar2,
  p_end_date                     in date    ,
  p_internal_address_line        in varchar2,
  p_lead_time                    in number  ,
  p_name                         in varchar2,
  p_supplier_reference           in varchar2,
  p_tsr_information_category     in varchar2,
  p_tsr_information1             in varchar2,
  p_tsr_information2             in varchar2,
  p_tsr_information3             in varchar2,
  p_tsr_information4             in varchar2,
  p_tsr_information5             in varchar2,
  p_tsr_information6             in varchar2,
  p_tsr_information7             in varchar2,
  p_tsr_information8             in varchar2,
  p_tsr_information9             in varchar2,
  p_tsr_information10            in varchar2,
  p_tsr_information11            in varchar2,
  p_tsr_information12            in varchar2,
  p_tsr_information13            in varchar2,
  p_tsr_information14            in varchar2,
  p_tsr_information15            in varchar2,
  p_tsr_information16            in varchar2,
  p_tsr_information17            in varchar2,
  p_tsr_information18            in varchar2,
  p_tsr_information19            in varchar2,
  p_tsr_information20            in varchar2,
  p_training_center_id           in number,
  p_location_id			   in number,
  p_trainer_id                   in number,
  p_special_instruction          in varchar2,
  p_validate                     in boolean
  ) is
--
  l_rec	  ota_tsr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_tsr_shd.convert_args
  (
  null,
  p_vendor_id,
  p_business_group_id,
  p_resource_definition_id,
  p_consumable_flag,
  null,
  p_resource_type,
  p_start_date,
  p_comments,
  p_cost,
  p_cost_unit,
  p_currency_code,
  p_end_date,
  p_internal_address_line,
  p_lead_time,
  p_name,
  p_supplier_reference,
  p_tsr_information_category,
  p_tsr_information1,
  p_tsr_information2,
  p_tsr_information3,
  p_tsr_information4,
  p_tsr_information5,
  p_tsr_information6,
  p_tsr_information7,
  p_tsr_information8,
  p_tsr_information9,
  p_tsr_information10,
  p_tsr_information11,
  p_tsr_information12,
  p_tsr_information13,
  p_tsr_information14,
  p_tsr_information15,
  p_tsr_information16,
  p_tsr_information17,
  p_tsr_information18,
  p_tsr_information19,
  p_tsr_information20,
  p_training_center_id,
  p_location_id,
  p_trainer_id,
  p_special_instruction
  );
  --
  -- Having converted the arguments into the ota_tsr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_supplied_resource_id := l_rec.supplied_resource_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_tsr_ins;

/
