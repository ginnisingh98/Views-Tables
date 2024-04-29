--------------------------------------------------------
--  DDL for Package Body OTA_TAV_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TAV_INS" as
/* $Header: ottav01t.pkb 120.2.12010000.3 2009/08/11 13:44:21 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tav_ins.';  -- Global package name
g_activity_version_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_activity_version_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_tav_ins.g_activity_version_id_i := p_activity_version_id;
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
Procedure insert_dml(p_rec in out nocopy ota_tav_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_tav_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_activity_versions
  --
  insert into ota_activity_versions
  (	activity_version_id,
	activity_id,
	superseded_by_act_version_id,
	developer_organization_id,
	controlling_person_id,
	object_version_number,
	version_name,
	comments,
	description,
	duration,
	duration_units,
	end_date,
	intended_audience,
	language_id,
	maximum_attendees,
	minimum_attendees,
	objectives,
	start_date,
	success_criteria,
	user_status,
        vendor_id,
        actual_cost,
        budget_cost,
        budget_currency_code,
        expenses_allowed,
        professional_credit_type,
        professional_credits,
        maximum_internal_attendees,
	tav_information_category,
	tav_information1,
	tav_information2,
	tav_information3,
	tav_information4,
	tav_information5,
	tav_information6,
	tav_information7,
	tav_information8,
	tav_information9,
	tav_information10,
	tav_information11,
	tav_information12,
	tav_information13,
	tav_information14,
	tav_information15,
	tav_information16,
	tav_information17,
	tav_information18,
	tav_information19,
	tav_information20,
      inventory_item_id,
      organization_id,
      rco_id,
      version_code,
      business_group_id,
      data_source,
      competency_update_level,
      eres_enabled

  )
  Values
  (	p_rec.activity_version_id,
	p_rec.activity_id,
	p_rec.superseded_by_act_version_id,
	p_rec.developer_organization_id,
	p_rec.controlling_person_id,
	p_rec.object_version_number,
	p_rec.version_name,
	p_rec.comments,
	p_rec.description,
	p_rec.duration,
	p_rec.duration_units,
	p_rec.end_date,
	p_rec.intended_audience,
	p_rec.language_id,
	p_rec.maximum_attendees,
	p_rec.minimum_attendees,
	p_rec.objectives,
	p_rec.start_date,
	p_rec.success_criteria,
	p_rec.user_status,
        p_rec.vendor_id,
        p_rec.actual_cost,
        p_rec.budget_cost,
        p_rec.budget_currency_code,
        p_rec.expenses_allowed,
        p_rec.professional_credit_type,
        p_rec.professional_credits,
        p_rec.maximum_internal_attendees,
	p_rec.tav_information_category,
	p_rec.tav_information1,
	p_rec.tav_information2,
	p_rec.tav_information3,
	p_rec.tav_information4,
	p_rec.tav_information5,
	p_rec.tav_information6,
	p_rec.tav_information7,
	p_rec.tav_information8,
	p_rec.tav_information9,
	p_rec.tav_information10,
	p_rec.tav_information11,
	p_rec.tav_information12,
	p_rec.tav_information13,
	p_rec.tav_information14,
	p_rec.tav_information15,
	p_rec.tav_information16,
	p_rec.tav_information17,
	p_rec.tav_information18,
	p_rec.tav_information19,
	p_rec.tav_information20,
      p_rec.inventory_item_id,
      p_rec.organization_id,
      p_rec.rco_id,
      p_rec.version_code,
      p_rec.business_group_id,
      p_rec.data_source ,
      p_rec.competency_update_level,
      p_rec.eres_enabled
  );
  --
  ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ota_tav_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_activity_versions_s.nextval from sys.dual;
--
--
  Cursor C_Sel2 is
    Select null
      from ota_activity_versions
     where activity_version_id =
             ota_tav_ins.g_activity_version_id_i;
--
  l_exists varchar2(1);
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (ota_tav_ins.g_activity_version_id_i is not null) Then
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
    p_rec.activity_version_id :=
      ota_tav_ins.g_activity_version_id_i;
    ota_tav_ins.g_activity_version_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.activity_version_id;
  Close C_Sel1;
  --

  END IF;

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
Procedure post_insert(p_rec in ota_tav_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    ota_tav_api_business_rules.set_superseding_version
            (p_rec.activity_id
            ,p_rec.activity_version_id
            ,p_rec.start_date);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ota_tav_shd.g_rec_type,
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
    SAVEPOINT ins_ota_tav;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_tav_bus.insert_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
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
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
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
    ROLLBACK TO ins_ota_tav;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_activity_version_id          out nocopy number,
  p_activity_id                  in number,
  p_superseded_by_act_version_id in number          ,
  p_developer_organization_id    in number,
  p_controlling_person_id        in number          ,
  p_object_version_number        out  nocopy  number,
  p_version_name                 in varchar2,
  p_comments                     in varchar2        ,
  p_description                  in varchar2        ,
  p_duration                     in number          ,
  p_duration_units               in varchar2        ,
  p_end_date                     in date            ,
  p_intended_audience            in varchar2        ,
  p_language_id                  in number          ,
  p_maximum_attendees            in number          ,
  p_minimum_attendees            in number          ,
  p_objectives                   in varchar2        ,
  p_start_date                   in date            ,
  p_success_criteria             in varchar2        ,
  p_user_status                  in varchar2        ,
  p_vendor_id                    in number          ,
  p_actual_cost                  in number          ,
  p_budget_cost                  in number          ,
  p_budget_currency_code         in varchar2        ,
  p_expenses_allowed             in varchar2        ,
  p_professional_credit_type     in varchar2        ,
  p_professional_credits         in number          ,
  p_maximum_internal_attendees   in number          ,
  p_tav_information_category     in varchar2        ,
  p_tav_information1             in varchar2        ,
  p_tav_information2             in varchar2        ,
  p_tav_information3             in varchar2        ,
  p_tav_information4             in varchar2        ,
  p_tav_information5             in varchar2        ,
  p_tav_information6             in varchar2        ,
  p_tav_information7             in varchar2        ,
  p_tav_information8             in varchar2        ,
  p_tav_information9             in varchar2        ,
  p_tav_information10            in varchar2        ,
  p_tav_information11            in varchar2        ,
  p_tav_information12            in varchar2        ,
  p_tav_information13            in varchar2        ,
  p_tav_information14            in varchar2        ,
  p_tav_information15            in varchar2        ,
  p_tav_information16            in varchar2        ,
  p_tav_information17            in varchar2        ,
  p_tav_information18            in varchar2        ,
  p_tav_information19            in varchar2        ,
  p_tav_information20            in varchar2        ,
  p_inventory_item_id            in number          ,
  p_organization_id		   in number	    ,
  p_rco_id		         in number	    ,
  p_version_code                 in varchar2,
  p_business_group_id            in number,
  p_validate                     in boolean,
  p_data_source                  in varchar2
  ,p_competency_update_level        in     varchar2,
  p_eres_enabled                 in varchar2

 ) is
--
  l_rec	  ota_tav_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_tav_shd.convert_args
  (
 null,
  p_activity_id,
  p_superseded_by_act_version_id,
  p_developer_organization_id,
  p_controlling_person_id,
 null,
  p_version_name,
  p_comments,
  p_description,
  p_duration,
  p_duration_units,
  p_end_date,
  p_intended_audience,
  p_language_id,
  p_maximum_attendees,
  p_minimum_attendees,
  p_objectives,
  p_start_date,
  p_success_criteria,
  p_user_status,
  p_vendor_id,
  p_actual_cost,
  p_budget_cost,
  p_budget_currency_code,
  p_expenses_allowed,
  p_professional_credit_type,
  p_professional_credits,
  p_maximum_internal_attendees,
  p_tav_information_category,
  p_tav_information1,
  p_tav_information2,
  p_tav_information3,
  p_tav_information4,
  p_tav_information5,
  p_tav_information6,
  p_tav_information7,
  p_tav_information8,
  p_tav_information9,
  p_tav_information10,
  p_tav_information11,
  p_tav_information12,
  p_tav_information13,
  p_tav_information14,
  p_tav_information15,
  p_tav_information16,
  p_tav_information17,
  p_tav_information18,
  p_tav_information19,
  p_tav_information20,
  p_inventory_item_id,
  p_organization_id,
  p_rco_id,
  p_version_code,
  p_business_group_id,
  p_data_source
  ,p_competency_update_level,
  p_eres_enabled

  );
  --
  -- Having converted the arguments into the ota_tav_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
 p_activity_version_id:=l_rec.activity_version_id;
p_object_version_number:=l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_tav_ins;

/
