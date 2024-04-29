--------------------------------------------------------
--  DDL for Package Body OTA_TDB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_INS" as
/* $Header: ottdb01t.pkb 120.26.12010000.3 2009/10/12 06:51:15 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_tdb_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_booking_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_booking_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_tdb_ins.g_booking_id_i := p_booking_id;
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
Procedure insert_dml(p_rec in out nocopy ota_tdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_tdb_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_delegate_bookings
  --
  insert into ota_delegate_bookings
  (     booking_id,
        booking_status_type_id,
        delegate_person_id,
        contact_id,
        business_group_id,
        event_id,
        customer_id,
        authorizer_person_id,
        date_booking_placed,
        corespondent,
        internal_booking_flag,
        number_of_places,
        object_version_number,
        administrator,
        booking_priority,
        comments,
        contact_address_id,
        delegate_contact_phone,
        delegate_contact_fax,
        third_party_customer_id,
        third_party_contact_id,
        third_party_address_id,
        third_party_contact_phone,
        third_party_contact_fax,
        date_status_changed,
        failure_reason,
        attendance_result,
        language_id,
        source_of_booking,
        special_booking_instructions,
        successful_attendance_flag,
        tdb_information_category,
        tdb_information1,
        tdb_information2,
        tdb_information3,
        tdb_information4,
        tdb_information5,
        tdb_information6,
        tdb_information7,
        tdb_information8,
        tdb_information9,
        tdb_information10,
        tdb_information11,
        tdb_information12,
        tdb_information13,
        tdb_information14,
        tdb_information15,
        tdb_information16,
        tdb_information17,
        tdb_information18,
        tdb_information19,
        tdb_information20,
        organization_id,
        sponsor_person_id,
        sponsor_assignment_id,
        person_address_id,
        delegate_assignment_id,
        delegate_contact_id,
        delegate_contact_email,
        third_party_email,
        person_address_type,
        line_id,
        org_id,
        daemon_flag,
        daemon_type,
        old_event_id,
        quote_line_id,
        interface_source,
        total_training_time,
        content_player_status,
        score,
        completed_content,
        total_content    ,
	booking_justification_id,
	is_history_flag,
	is_mandatory_enrollment,
	sign_eval_status
  )
  Values
  (     p_rec.booking_id,
        p_rec.booking_status_type_id,
        p_rec.delegate_person_id,
        p_rec.contact_id,
        p_rec.business_group_id,
        p_rec.event_id,
        p_rec.customer_id,
        p_rec.authorizer_person_id,
        p_rec.date_booking_placed,
        p_rec.corespondent,
        p_rec.internal_booking_flag,
        p_rec.number_of_places,
        p_rec.object_version_number,
        p_rec.administrator,
        p_rec.booking_priority,
        p_rec.comments,
        p_rec.contact_address_id,
        p_rec.delegate_contact_phone,
        p_rec.delegate_contact_fax,
        p_rec.third_party_customer_id,
        p_rec.third_party_contact_id,
        p_rec.third_party_address_id,
        p_rec.third_party_contact_phone,
        p_rec.third_party_contact_fax,
        p_rec.date_status_changed,
        p_rec.failure_reason,
        p_rec.attendance_result,
        p_rec.language_id,
        p_rec.source_of_booking,
        p_rec.special_booking_instructions,
        p_rec.successful_attendance_flag,
        p_rec.tdb_information_category,
        p_rec.tdb_information1,
        p_rec.tdb_information2,
        p_rec.tdb_information3,
        p_rec.tdb_information4,
        p_rec.tdb_information5,
        p_rec.tdb_information6,
        p_rec.tdb_information7,
        p_rec.tdb_information8,
        p_rec.tdb_information9,
        p_rec.tdb_information10,
        p_rec.tdb_information11,
        p_rec.tdb_information12,
        p_rec.tdb_information13,
        p_rec.tdb_information14,
        p_rec.tdb_information15,
        p_rec.tdb_information16,
        p_rec.tdb_information17,
        p_rec.tdb_information18,
        p_rec.tdb_information19,
        p_rec.tdb_information20,
        p_rec.organization_id,
        p_rec.sponsor_person_id,
        p_rec.sponsor_assignment_id,
        p_rec.person_address_id,
        p_rec.delegate_assignment_id,
        p_rec.delegate_contact_id,
        p_rec.delegate_contact_email,
        p_rec.third_party_email,
        p_rec.person_address_type,
        p_rec.line_id,
        p_rec.org_id,
        p_rec.daemon_flag,
        p_rec.daemon_type,
        p_rec.old_event_id,
        p_rec.quote_line_id,
        p_rec.interface_source,
        p_rec.total_training_time,
      p_rec.content_player_status,
      p_rec.score,
      p_rec.completed_content,
      p_rec.total_content     ,
      p_rec.booking_justification_id,
      p_rec.is_history_flag,
      p_rec.is_mandatory_enrollment,
      p_rec.sign_eval_status
  );
  --
  ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tdb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tdb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tdb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ota_tdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_delegate_bookings_s.nextval from sys.dual;
--
--
  Cursor C_Sel2 is
    Select null
      from ota_delegate_bookings
     where booking_id =
             ota_tdb_ins.g_booking_id_i;
--
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If (ota_tdb_ins.g_booking_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ota_delegate_bookings');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.booking_id :=
      ota_tdb_ins.g_booking_id_i;
    ota_tdb_ins.g_booking_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.booking_id;
    Close C_Sel1;
  --
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
Procedure post_insert(p_rec                 in ota_tdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
  l_dummy number;
  l_return  boolean;
--

  CURSOR c_event  /* Added for Bug 3385192 */
  IS
  select line_id
  from ota_events
  where event_id = p_rec.event_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF p_rec.line_id is not null then
     l_return := ota_utility.check_wf_status(p_rec.line_id,'BLOCK');
     IF l_return = TRUE THEN
        wf_engine.Completeactivity('OEOL',
                                        to_char(p_rec.line_id),
                                        'BLOCK',null);
     END IF;
  ELSE  /* Added for Bug 3385192  to complete the check of enrollment status*/
    FOR line in c_event
    LOOP
      IF line.line_id is not null then
        l_return := ota_utility.check_wf_status(line.line_id,'BLOCK');
       IF l_return = TRUE THEN

           wf_engine.Completeactivity('OEOL',
               to_char(line.line_id),
               'BLOCK',null);
        END IF;
       END IF;
      END LOOP;

    END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);


End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec                 in out nocopy ota_tdb_shd.g_rec_type,
  p_create_finance_line in varchar2,
  p_finance_header_id   in number,
  p_currency_code       in varchar2,
  p_standard_amount     in number,
  p_unitary_amount      in number,
  p_money_amount        in number,
  p_booking_deal_id     in number,
  p_booking_deal_type   in varchar2,
  p_finance_line_id     in out nocopy number,
  p_enrollment_type     in varchar2,
  p_validate            in boolean

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
    SAVEPOINT ins_ota_tdb;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_tdb_bus.insert_validate(p_rec,p_enrollment_type);
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
    ROLLBACK TO ins_ota_tdb;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_booking_id                   out nocopy number,
  p_booking_status_type_id       in number,
  p_delegate_person_id           in number           ,
  p_contact_id                   in number,
  p_business_group_id            in number,
  p_event_id                     in number,
  p_customer_id                  in number           ,
  p_authorizer_person_id         in number           ,
  p_date_booking_placed          in date,
  p_corespondent                 in varchar2         ,
  p_internal_booking_flag        in varchar2,
  p_number_of_places             in number,
  p_object_version_number        out nocopy number,
  p_administrator                in number           ,
  p_booking_priority             in varchar2         ,
  p_comments                     in varchar2         ,
  p_contact_address_id           in number           ,
  p_delegate_contact_phone       in varchar2         ,
  p_delegate_contact_fax         in varchar2         ,
  p_third_party_customer_id      in number           ,
  p_third_party_contact_id       in number           ,
  p_third_party_address_id       in number           ,
  p_third_party_contact_phone    in varchar2         ,
  p_third_party_contact_fax      in varchar2         ,
  p_date_status_changed          in date             ,
  p_failure_reason               in varchar2         ,
  p_attendance_result            in varchar2           ,
  p_language_id                  in number           ,
  p_source_of_booking            in varchar2         ,
  p_special_booking_instructions in varchar2         ,
  p_successful_attendance_flag   in varchar2         ,
  p_tdb_information_category     in varchar2         ,
  p_tdb_information1             in varchar2         ,
  p_tdb_information2             in varchar2         ,
  p_tdb_information3             in varchar2         ,
  p_tdb_information4             in varchar2         ,
  p_tdb_information5             in varchar2         ,
  p_tdb_information6             in varchar2         ,
  p_tdb_information7             in varchar2         ,
  p_tdb_information8             in varchar2         ,
  p_tdb_information9             in varchar2         ,
  p_tdb_information10            in varchar2         ,
  p_tdb_information11            in varchar2         ,
  p_tdb_information12            in varchar2         ,
  p_tdb_information13            in varchar2         ,
  p_tdb_information14            in varchar2         ,
  p_tdb_information15            in varchar2         ,
  p_tdb_information16            in varchar2         ,
  p_tdb_information17            in varchar2         ,
  p_tdb_information18            in varchar2         ,
  p_tdb_information19            in varchar2         ,
  p_tdb_information20            in varchar2         ,
  p_create_finance_line          in varchar2         ,
  p_finance_header_id            in number           ,
  p_currency_code                in varchar2         ,
  p_standard_amount              in number           ,
  p_unitary_amount               in number           ,
  p_money_amount                 in number           ,
  p_booking_deal_id              in number           ,
  p_booking_deal_type            in varchar2         ,
  p_finance_line_id              in out nocopy number,
  p_enrollment_type              in varchar2         ,
  p_validate                     in boolean          ,
  p_organization_id              in number           ,
  p_sponsor_person_id            in number           ,
  p_sponsor_assignment_id        in number           ,
  p_person_address_id            in number           ,
  p_delegate_assignment_id       in number           ,
  p_delegate_contact_id          in number           ,
  p_delegate_contact_email       in varchar2         ,
  p_third_party_email            in varchar2         ,
  p_person_address_type          in varchar2         ,
  p_line_id                                in number         ,
  p_org_id                                 in number         ,
  p_daemon_flag                    in varchar2         ,
  p_daemon_type                    in varchar2         ,
  p_old_event_id                 in number           ,
  p_quote_line_id                in number           ,
  p_interface_source             in varchar2         ,
  p_total_training_time          in varchar2         ,
  p_content_player_status        in varchar2         ,
  p_score                              in number             ,
  p_completed_content              in number         ,
  p_total_content                      in number               ,
  p_booking_justification_id              in number,
  p_is_history_flag in varchar2,
  p_sign_eval_status in varchar2,
  p_is_mandatory_enrollment in varchar2
  ) is
--
  l_rec   ota_tdb_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_tdb_shd.convert_args
  (
  null,
  p_booking_status_type_id,
  p_delegate_person_id,
  p_contact_id,
  p_business_group_id,
  p_event_id,
  p_customer_id,
  p_authorizer_person_id,
  p_date_booking_placed,
  p_corespondent,
  p_internal_booking_flag,
  p_number_of_places,
  null,
  p_administrator,
  p_booking_priority,
  p_comments,
  p_contact_address_id,
  p_delegate_contact_phone,
  p_delegate_contact_fax,
  p_third_party_customer_id,
  p_third_party_contact_id,
  p_third_party_address_id,
  p_third_party_contact_phone,
  p_third_party_contact_fax,
  p_date_status_changed,
  p_failure_reason,
  p_attendance_result,
  p_language_id,
  p_source_of_booking,
  p_special_booking_instructions,
  p_successful_attendance_flag,
  p_tdb_information_category,
  p_tdb_information1,
  p_tdb_information2,
  p_tdb_information3,
  p_tdb_information4,
  p_tdb_information5,
  p_tdb_information6,
  p_tdb_information7,
  p_tdb_information8,
  p_tdb_information9,
  p_tdb_information10,
  p_tdb_information11,
  p_tdb_information12,
  p_tdb_information13,
  p_tdb_information14,
  p_tdb_information15,
  p_tdb_information16,
  p_tdb_information17,
  p_tdb_information18,
  p_tdb_information19,
  p_tdb_information20,
  p_organization_id,
  p_sponsor_person_id,
  p_sponsor_assignment_id,
  p_person_address_id,
  p_delegate_assignment_id,
  p_delegate_contact_id,
  p_delegate_contact_email,
  p_third_party_email,
  p_person_address_type,
  p_line_id,
  p_org_id,
  p_daemon_flag,
  p_daemon_type,
  p_old_event_id,
  p_quote_line_id,
  p_interface_source,
  p_total_training_time,
  p_content_player_status,
  p_score,
  p_completed_content,
  p_total_content,
  p_booking_justification_id,
  p_is_history_flag,
  p_sign_eval_status,
  p_is_mandatory_enrollment
  );
  --
  -- Having converted the arguments into the ota_tdb_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec,
      p_create_finance_line,
      p_finance_header_id,
      p_currency_code,
      p_standard_amount,
      p_unitary_amount,
      p_money_amount,
      p_booking_deal_id,
      p_booking_deal_type,
      p_finance_line_id,
      p_enrollment_type,
      p_validate
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_booking_id := l_rec.booking_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_tdb_ins;


/
