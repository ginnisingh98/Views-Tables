--------------------------------------------------------
--  DDL for Package Body OTA_TSP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TSP_INS" as
/* $Header: ottsp01t.pkb 120.0 2005/05/29 07:54:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tsp_ins.';  -- Global package name
g_skill_provision_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_skill_provision_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_tsp_ins.g_skill_provision_id_i := p_skill_provision_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
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
Procedure insert_dml(p_rec in out nocopy ota_tsp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_tsp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_skill_provisions
  --
  insert into ota_skill_provisions
  (	skill_provision_id,
	activity_version_id,
	object_version_number,
	type,
	comments,
	tsp_information_category,
	tsp_information1,
	tsp_information2,
	tsp_information3,
	tsp_information4,
	tsp_information5,
	tsp_information6,
	tsp_information7,
	tsp_information8,
	tsp_information9,
	tsp_information10,
	tsp_information11,
	tsp_information12,
	tsp_information13,
	tsp_information14,
	tsp_information15,
	tsp_information16,
	tsp_information17,
	tsp_information18,
	tsp_information19,
	tsp_information20,
	analysis_criteria_id
  )
  Values
  (	p_rec.skill_provision_id,
	p_rec.activity_version_id,
	p_rec.object_version_number,
	p_rec.type,
	p_rec.comments,
	p_rec.tsp_information_category,
	p_rec.tsp_information1,
	p_rec.tsp_information2,
	p_rec.tsp_information3,
	p_rec.tsp_information4,
	p_rec.tsp_information5,
	p_rec.tsp_information6,
	p_rec.tsp_information7,
	p_rec.tsp_information8,
	p_rec.tsp_information9,
	p_rec.tsp_information10,
	p_rec.tsp_information11,
	p_rec.tsp_information12,
	p_rec.tsp_information13,
	p_rec.tsp_information14,
	p_rec.tsp_information15,
	p_rec.tsp_information16,
	p_rec.tsp_information17,
	p_rec.tsp_information18,
	p_rec.tsp_information19,
	p_rec.tsp_information20,
	p_rec.analysis_criteria_id
  );
  --
  ota_tsp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tsp_shd.g_api_dml := false;   -- Unset the api dml status
  ota_tsp_shd.g_api_dml := true;  -- Set the api dml status
    ota_tsp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tsp_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tsp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tsp_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tsp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tsp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert
  (p_rec  in out nocopy ota_tsp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_skill_provisions_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ota_skill_provisions
     where skill_provision_id =
             ota_tsp_ins.g_skill_provision_id_i;
--
  l_exists varchar2(1);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (ota_tsp_ins.g_skill_provision_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','irc_documents');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.skill_provision_id :=
      ota_tsp_ins.g_skill_provision_id_i;
    ota_tsp_ins.g_skill_provision_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
  --
  -- Select the next sequence number
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.skill_provision_id;
  Close C_Sel1;

  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
---- ----------------------------------------------------------------------------
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
Procedure post_insert(p_rec in ota_tsp_shd.g_rec_type) is
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
  p_rec        in out nocopy ota_tsp_shd.g_rec_type,
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
    SAVEPOINT ins_tsp;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_tsp_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_tsp;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_skill_provision_id           out nocopy number,
  p_activity_version_id          in number,
  p_object_version_number        out nocopy number,
  p_type                         in varchar2,
  p_comments                     in varchar2         default null,
  p_tsp_information_category     in varchar2         default null,
  p_tsp_information1             in varchar2         default null,
  p_tsp_information2             in varchar2         default null,
  p_tsp_information3             in varchar2         default null,
  p_tsp_information4             in varchar2         default null,
  p_tsp_information5             in varchar2         default null,
  p_tsp_information6             in varchar2         default null,
  p_tsp_information7             in varchar2         default null,
  p_tsp_information8             in varchar2         default null,
  p_tsp_information9             in varchar2         default null,
  p_tsp_information10            in varchar2         default null,
  p_tsp_information11            in varchar2         default null,
  p_tsp_information12            in varchar2         default null,
  p_tsp_information13            in varchar2         default null,
  p_tsp_information14            in varchar2         default null,
  p_tsp_information15            in varchar2         default null,
  p_tsp_information16            in varchar2         default null,
  p_tsp_information17            in varchar2         default null,
  p_tsp_information18            in varchar2         default null,
  p_tsp_information19            in varchar2         default null,
  p_tsp_information20            in varchar2         default null,
  p_analysis_criteria_id         in number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ota_tsp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_tsp_shd.convert_args
  (
  null,
  p_activity_version_id,
  null,
  p_type,
  p_comments,
  p_tsp_information_category,
  p_tsp_information1,
  p_tsp_information2,
  p_tsp_information3,
  p_tsp_information4,
  p_tsp_information5,
  p_tsp_information6,
  p_tsp_information7,
  p_tsp_information8,
  p_tsp_information9,
  p_tsp_information10,
  p_tsp_information11,
  p_tsp_information12,
  p_tsp_information13,
  p_tsp_information14,
  p_tsp_information15,
  p_tsp_information16,
  p_tsp_information17,
  p_tsp_information18,
  p_tsp_information19,
  p_tsp_information20,
  p_analysis_criteria_id
  );
  --
  -- Having converted the arguments into the tsp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_skill_provision_id := l_rec.skill_provision_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_tsp_ins;

/
