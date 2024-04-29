--------------------------------------------------------
--  DDL for Package Body HR_TRS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRS_INS" as
/* $Header: hrtrsrhi.pkb 120.2 2005/10/11 02:10:33 hpandya noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_trs_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_transaction_step_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_transaction_step_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_trs_ins.g_transaction_step_id_i := p_transaction_step_id;
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy hr_trs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  hr_trs_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hr_api_transaction_steps
  --
  insert into hr_api_transaction_steps
  ( transaction_step_id,
    transaction_id,
    api_name,
    api_display_name,
    processing_order,
    item_type,
    item_key,
    activity_id,
    creator_person_id,
    update_person_id,
    object_version_number,
    object_type,
    object_name,
    object_identifier,
    object_state,
    pk1,
    pk2,
    pk3,
    pk4,
    pk5,
    information_category,
    information1,
    information2,
    information3,
    information4,
    information5,
    information6,
    information7,
    information8,
    information9,
    information10,
    information11,
    information12,
    information13,
    information14,
    information15,
    information16,
    information17,
    information18,
    information19,
    information20,
    information21,
    information22,
    information23,
    information24,
    information25,
    information26,
    information27,
    information28,
    information29,
    information30

  )
  Values
  ( p_rec.transaction_step_id,
    p_rec.transaction_id,
    p_rec.api_name,
    p_rec.api_display_name,
    p_rec.processing_order,
    p_rec.item_type,
    p_rec.item_key,
    p_rec.activity_id,
    p_rec.creator_person_id,
    p_rec.update_person_id,
    p_rec.object_version_number,
    p_rec.object_type,
    p_rec.object_name,
    p_rec.object_identifier,
    p_rec.object_state,
    p_rec.pk1,
    p_rec.pk2,
    p_rec.pk3,
    p_rec.pk4,
    p_rec.pk5,
    p_rec.information_category,
    p_rec.information1,
    p_rec.information2,
    p_rec.information3,
    p_rec.information4,
    p_rec.information5,
    p_rec.information6,
    p_rec.information7,
    p_rec.information8,
    p_rec.information9,
    p_rec.information10,
    p_rec.information11,
    p_rec.information12,
    p_rec.information13,
    p_rec.information14,
    p_rec.information15,
    p_rec.information16,
    p_rec.information17,
    p_rec.information18,
    p_rec.information19,
    p_rec.information20,
    p_rec.information21,
    p_rec.information22,
    p_rec.information23,
    p_rec.information24,
    p_rec.information25,
    p_rec.information26,
    p_rec.information27,
    p_rec.information28,
    p_rec.information29,
    p_rec.information30

  );
  --
  hr_trs_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hr_trs_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hr_trs_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hr_trs_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hr_trs_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy hr_trs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
  Cursor C_Sel1 is select hr_api_transaction_steps_s.nextval from sys.dual;

  Cursor C_Sel2 is
         select null
                from hr_api_transaction_steps
                where transaction_step_id = hr_trs_ins.g_transaction_step_id_i;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If hr_trs_ins.g_transaction_step_id_i is not null then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found then
      Close C_Sel2;
      --
      -- The primary key values are already in use.
      --
      fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
      fnd_message.set_token('TABLE_NAME','hr_api_transaction_steps');
      fnd_message.raise_error;
    end if;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.transaction_step_id := hr_trs_ins.g_transaction_step_id_i;
    hr_trs_ins.g_transaction_step_id_i := null;
    --
  else
    --
    --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.transaction_step_id;
  Close C_Sel1;
  End If;

  if p_rec.processing_order is null then
     p_rec.processing_order := 0;
  end if;

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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in hr_trs_shd.g_rec_type) is
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
  p_rec        in out nocopy hr_trs_shd.g_rec_type,
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
    SAVEPOINT ins_hr_trs;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  hr_trs_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_hr_trs;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_transaction_step_id          out nocopy number,
  p_transaction_id               in number           default null,
  p_api_name                     in varchar2,
  p_api_display_name             in varchar2         default null,
  p_processing_order             in number,
  p_item_type                    in varchar2         default null,
  p_item_key                     in varchar2         default null,
  p_activity_id                  in number           default null,
  p_creator_person_id            in number,
  p_update_person_id             in number           default null,
  p_object_version_number        out nocopy number,
   p_validate                     in boolean   	        default false,
   p_OBJECT_TYPE                    in        VARCHAR2  default null,
   p_OBJECT_NAME                    in        VARCHAR2  default null,
   p_OBJECT_IDENTIFIER              in        VARCHAR2  default null,
   p_OBJECT_STATE                   in        VARCHAR2  default null,
   p_PK1                            in        VARCHAR2   default null,
   p_PK2                            in        VARCHAR2   default null,
   p_PK3                            in        VARCHAR2   default null,
   p_PK4                            in        VARCHAR2   default null,
   p_PK5                            in        VARCHAR2   default null,
   p_information_category             in	      VARCHAR2   default null,
   p_information1                     in        VARCHAR2   default null,
   p_information2                     in        VARCHAR2   default null,
   p_information3                     in        VARCHAR2   default null,
   p_information4                     in        VARCHAR2   default null,
   p_information5                     in        VARCHAR2   default null,
   p_information6                     in        VARCHAR2   default null,
   p_information7                     in        VARCHAR2   default null,
   p_information8                     in        VARCHAR2   default null,
   p_information9                     in        VARCHAR2   default null,
   p_information10                    in        VARCHAR2   default null,
   p_information11                    in        VARCHAR2   default null,
   p_information12                    in        VARCHAR2   default null,
   p_information13                    in        VARCHAR2   default null,
   p_information14                    in        VARCHAR2   default null,
   p_information15                    in        VARCHAR2   default null,
   p_information16                    in        VARCHAR2   default null,
   p_information17                    in        VARCHAR2   default null,
   p_information18                    in        VARCHAR2   default null,
   p_information19                    in        VARCHAR2   default null,
   p_information20                    in        VARCHAR2   default null,
   p_information21                    in        VARCHAR2   default null,
   p_information22                    in        VARCHAR2   default null,
   p_information23                    in        VARCHAR2   default null,
   p_information24                    in        VARCHAR2   default null,
   p_information25                    in        VARCHAR2   default null,
   p_information26                    in        VARCHAR2   default null,
   p_information27                    in        VARCHAR2   default null,
   p_information28                    in        VARCHAR2   default null,
   p_information29                    in        VARCHAR2   default null,
   p_information30                    in        VARCHAR2   default null


  ) is
--
  l_rec   hr_trs_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_trs_shd.convert_args
  (
  null,
  p_transaction_id,
  p_api_name,
  p_api_display_name,
  p_processing_order,
  p_item_type,
  p_item_key,
  p_activity_id,
  p_creator_person_id,
  p_update_person_id,
  null,
  p_object_type,
  p_object_name,
  p_object_identifier,
  p_object_state,
  p_pk1,
  p_pk2,
  p_pk3,
  p_pk4,
  p_pk5,
  p_information_category,
  p_information1,
  p_information2,
  p_information3,
  p_information4,
  p_information5,
  p_information6,
  p_information7,
  p_information8,
  p_information9,
  p_information10,
  p_information11,
  p_information12,
  p_information13,
  p_information14,
  p_information15,
  p_information16,
  p_information17,
  p_information18,
  p_information19,
  p_information20,
  p_information21,
  p_information22,
  p_information23,
  p_information24,
  p_information25,
  p_information26,
  p_information27,
  p_information28,
  p_information29,
  p_information30


  );
  --
  -- Having converted the arguments into the hr_trs_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_transaction_step_id := l_rec.transaction_step_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end hr_trs_ins;

/
