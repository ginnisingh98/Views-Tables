--------------------------------------------------------
--  DDL for Package Body OTA_EVT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVT_INS" as
/* $Header: otevt01t.pkb 120.13.12010000.5 2009/07/29 07:12:13 shwnayak ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_evt_ins.';  -- Global package name
--
g_event_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_event_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_evt_ins.g_event_id_i := p_event_id;
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
Procedure insert_dml(p_rec in out nocopy ota_evt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_evt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_events
  --
  insert into ota_events
  (	event_id,
	vendor_id,
	activity_version_id,
	business_group_id,
	organization_id,
	event_type,
	object_version_number,
	title,
        budget_cost,
        actual_cost,
        budget_currency_code,
	centre,
	comments,
	course_end_date,
	course_end_time,
	course_start_date,
	course_start_time,
	duration,
	duration_units,
	enrolment_end_date,
	enrolment_start_date,
	language_id,
	user_status,
	development_event_type,
	event_status,
	price_basis,
	currency_code,
	maximum_attendees,
	maximum_internal_attendees,
	minimum_attendees,
	standard_price,
	category_code,
	parent_event_id,
        book_independent_flag,
        public_event_flag,
        secure_event_flag,
	evt_information_category,
	evt_information1,
	evt_information2,
	evt_information3,
	evt_information4,
	evt_information5,
	evt_information6,
	evt_information7,
	evt_information8,
	evt_information9,
	evt_information10,
	evt_information11,
	evt_information12,
	evt_information13,
	evt_information14,
	evt_information15,
	evt_information16,
	evt_information17,
	evt_information18,
	evt_information19,
	evt_information20,
    project_id,
    owner_id,
    line_id,
    org_id,
    training_center_id,
    location_id,
    offering_id,
    timezone,
    parent_offering_id,
    data_source,
    event_availability
  )
  Values
  (	p_rec.event_id,
	p_rec.vendor_id,
	p_rec.activity_version_id,
	p_rec.business_group_id,
	p_rec.organization_id,
	p_rec.event_type,
	p_rec.object_version_number,
	p_rec.title,
    p_rec.budget_cost,
    p_rec.actual_cost,
    p_rec.budget_currency_code,
	p_rec.centre,
	p_rec.comments,
	p_rec.course_end_date,
	p_rec.course_end_time,
	p_rec.course_start_date,
	p_rec.course_start_time,
	p_rec.duration,
	p_rec.duration_units,
	p_rec.enrolment_end_date,
	p_rec.enrolment_start_date,
	p_rec.language_id,
	p_rec.user_status,
	p_rec.development_event_type,
	p_rec.event_status,
	p_rec.price_basis,
	p_rec.currency_code,
	p_rec.maximum_attendees,
	p_rec.maximum_internal_attendees,
	p_rec.minimum_attendees,
	p_rec.standard_price,
	p_rec.category_code,
	p_rec.parent_event_id,
    p_rec.book_independent_flag,
    p_rec.public_event_flag,
    p_rec.secure_event_flag,
	p_rec.evt_information_category,
	p_rec.evt_information1,
	p_rec.evt_information2,
	p_rec.evt_information3,
	p_rec.evt_information4,
	p_rec.evt_information5,
	p_rec.evt_information6,
	p_rec.evt_information7,
	p_rec.evt_information8,
	p_rec.evt_information9,
	p_rec.evt_information10,
	p_rec.evt_information11,
	p_rec.evt_information12,
	p_rec.evt_information13,
	p_rec.evt_information14,
	p_rec.evt_information15,
	p_rec.evt_information16,
	p_rec.evt_information17,
	p_rec.evt_information18,
	p_rec.evt_information19,
	p_rec.evt_information20,
    p_rec.project_id,
    p_rec.owner_id,
    p_rec.line_id,
    p_rec.org_id,
    p_rec.training_center_id,
    p_rec.location_id,
    p_rec.offering_id,
    p_rec.timezone,
    p_rec.parent_offering_id,
    p_rec.data_source,
    p_rec.event_availability
      );
  --
  ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
    ota_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
    ota_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
    ota_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy ota_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_events_s.nextval from sys.dual;
--
Cursor C_Sel2 is
    Select null
      from ota_events
     where event_id =
             ota_evt_ins.g_event_id_i;
--
  l_exists varchar2(1);
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (ota_evt_ins.g_event_id_i is not null) Then
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
    p_rec.event_id :=
      ota_evt_ins.g_event_id_i;
    ota_evt_ins.g_event_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.event_id;
  Close C_Sel1;

  END IF;
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
Procedure post_insert(p_rec in ota_evt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
  l_return  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
/* commented out to fix bug 3385192.  The call is moved to ota_tdb_ins.post_insert */
/*  IF p_rec.line_id is not null then
     l_return := ota_utility.check_wf_status(p_rec.line_id,'BLOCK');
     IF l_return = TRUE THEN

      wf_engine.Completeactivity('OEOL',
					to_char(p_rec.line_id),
					'BLOCK',null);
     END IF;

    END IF;*/

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ota_evt_shd.g_rec_type,
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
    SAVEPOINT ins_ota_evt;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_evt_bus.insert_validate(p_rec);
  -- added for eBS by asud
     hr_multi_message.end_validation_set;
  -- added for eBS by asud
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
  -- added for eBS by asud
     hr_multi_message.end_validation_set;
  -- added for eBS by asud
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
    ROLLBACK TO ins_ota_evt;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_event_id                     out nocopy number,
  p_vendor_id                    in number           default null,
  p_activity_version_id          in number           default null,
  p_business_group_id            in number,
  p_organization_id              in number           default null,
  p_event_type                   in varchar2,
  p_object_version_number        out nocopy number,
  p_title                        in varchar2,
  p_budget_cost                  in number           default null,
  p_actual_cost                  in number           default null,
  p_budget_currency_code         in varchar2         default null,
  p_centre                       in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_course_end_date              in date             default null,
  p_course_end_time              in varchar2         default null,
  p_course_start_date            in date             default null,
  p_course_start_time            in varchar2         default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_enrolment_end_date           in date             default null,
  p_enrolment_start_date         in date             default null,
  p_language_id                  in number           default null,
  p_user_status                  in varchar2         default null,
  p_development_event_type       in varchar2         default null,
  p_event_status                 in varchar2         default null,
  p_price_basis                  in varchar2         default null,
  p_currency_code                in varchar2         default null,
  p_maximum_attendees            in number           default null,
  p_maximum_internal_attendees   in number           default null,
  p_minimum_attendees            in number           default null,
  p_standard_price               in number           default null,
  p_category_code                in varchar2         default null,
  p_parent_event_id              in number           default null,
  p_book_independent_flag        in varchar2         default null,
  p_public_event_flag            in varchar2         default null,
  p_secure_event_flag            in varchar2         default null,
  p_evt_information_category     in varchar2         default null,
  p_evt_information1             in varchar2         default null,
  p_evt_information2             in varchar2         default null,
  p_evt_information3             in varchar2         default null,
  p_evt_information4             in varchar2         default null,
  p_evt_information5             in varchar2         default null,
  p_evt_information6             in varchar2         default null,
  p_evt_information7             in varchar2         default null,
  p_evt_information8             in varchar2         default null,
  p_evt_information9             in varchar2         default null,
  p_evt_information10            in varchar2         default null,
  p_evt_information11            in varchar2         default null,
  p_evt_information12            in varchar2         default null,
  p_evt_information13            in varchar2         default null,
  p_evt_information14            in varchar2         default null,
  p_evt_information15            in varchar2         default null,
  p_evt_information16            in varchar2         default null,
  p_evt_information17            in varchar2         default null,
  p_evt_information18            in varchar2         default null,
  p_evt_information19            in varchar2         default null,
  p_evt_information20            in varchar2         default null,
  p_project_id                   in number           default null,
  p_owner_id			         in number	         default null,
  p_line_id				         in number	         default null,
  p_org_id				         in number	         default null,
  p_training_center_id           in number           default null,
  p_location_id                  in number           default null,
  p_offering_id         	     in number           default null,
  p_timezone	                 in varchar2         default null,
  p_parent_offering_id           in number           default null,
  p_data_source	                 in varchar2         default null,
  p_validate                     in boolean          default false,
  p_event_availability           in varchar2         default null
  ) is
--
  l_rec	  ota_evt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_evt_shd.convert_args
  (
  null,
  p_vendor_id,
  p_activity_version_id,
  p_business_group_id,
  p_organization_id,
  p_event_type,
  null,
  p_title,
  p_budget_cost,
  p_actual_cost,
  p_budget_currency_code,
  p_centre,
  p_comments,
  p_course_end_date,
  p_course_end_time,
  p_course_start_date,
  p_course_start_time,
  p_duration,
  p_duration_units,
  p_enrolment_end_date,
  p_enrolment_start_date,
  p_language_id,
  p_user_status,
  p_development_event_type,
  p_event_status,
  p_price_basis,
  p_currency_code,
  p_maximum_attendees,
  p_maximum_internal_attendees,
  p_minimum_attendees,
  p_standard_price,
  p_category_code,
  p_parent_event_id,
  p_book_independent_flag,
  p_public_event_flag,
  p_secure_event_flag,
  p_evt_information_category,
  p_evt_information1,
  p_evt_information2,
  p_evt_information3,
  p_evt_information4,
  p_evt_information5,
  p_evt_information6,
  p_evt_information7,
  p_evt_information8,
  p_evt_information9,
  p_evt_information10,
  p_evt_information11,
  p_evt_information12,
  p_evt_information13,
  p_evt_information14,
  p_evt_information15,
  p_evt_information16,
  p_evt_information17,
  p_evt_information18,
  p_evt_information19,
  p_evt_information20,
  p_project_id,
  p_owner_id,
  p_line_id,
  p_org_id,
  p_training_center_id,
  p_location_id,
  p_offering_id,
  p_timezone,
  p_parent_offering_id,
  p_data_source,
  p_event_availability
  );
  --
  -- Having converted the arguments into the ota_evt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_event_id := l_rec.event_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_evt_ins;

/
