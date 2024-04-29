--------------------------------------------------------
--  DDL for Package Body OTA_TDB_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_UPD" as
/* $Header: ottdb01t.pkb 120.26.12010000.3 2009/10/12 06:51:15 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_tdb_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ota_tdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ota_tdb_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_delegate_bookings Row
  --
  update ota_delegate_bookings
  set
  booking_id                        = p_rec.booking_id,
  booking_status_type_id            = p_rec.booking_status_type_id,
  delegate_person_id                = p_rec.delegate_person_id,
  contact_id                        = p_rec.contact_id,
  business_group_id                 = p_rec.business_group_id,
  event_id                          = p_rec.event_id,
  customer_id                       = p_rec.customer_id,
  authorizer_person_id              = p_rec.authorizer_person_id,
  date_booking_placed               = p_rec.date_booking_placed,
  corespondent                      = p_rec.corespondent,
  internal_booking_flag             = p_rec.internal_booking_flag,
  number_of_places                  = p_rec.number_of_places,
  object_version_number             = p_rec.object_version_number,
  administrator                     = p_rec.administrator,
  booking_priority                  = p_rec.booking_priority,
  comments                          = p_rec.comments,
  contact_address_id                = p_rec.contact_address_id,
  delegate_contact_phone            = p_rec.delegate_contact_phone,
  delegate_contact_fax              = p_rec.delegate_contact_fax,
  third_party_customer_id           = p_rec.third_party_customer_id,
  third_party_contact_id            = p_rec.third_party_contact_id,
  third_party_address_id            = p_rec.third_party_address_id,
  third_party_contact_phone         = p_rec.third_party_contact_phone,
  third_party_contact_fax           = p_rec.third_party_contact_fax,
  date_status_changed               = p_rec.date_status_changed,
  failure_reason                    = p_rec.failure_reason,
  attendance_result                 = p_rec.attendance_result,
  language_id                       = p_rec.language_id,
  source_of_booking                 = p_rec.source_of_booking,
  special_booking_instructions      = p_rec.special_booking_instructions,
  successful_attendance_flag        = p_rec.successful_attendance_flag,
  tdb_information_category          = p_rec.tdb_information_category,
  tdb_information1                  = p_rec.tdb_information1,
  tdb_information2                  = p_rec.tdb_information2,
  tdb_information3                  = p_rec.tdb_information3,
  tdb_information4                  = p_rec.tdb_information4,
  tdb_information5                  = p_rec.tdb_information5,
  tdb_information6                  = p_rec.tdb_information6,
  tdb_information7                  = p_rec.tdb_information7,
  tdb_information8                  = p_rec.tdb_information8,
  tdb_information9                  = p_rec.tdb_information9,
  tdb_information10                 = p_rec.tdb_information10,
  tdb_information11                 = p_rec.tdb_information11,
  tdb_information12                 = p_rec.tdb_information12,
  tdb_information13                 = p_rec.tdb_information13,
  tdb_information14                 = p_rec.tdb_information14,
  tdb_information15                 = p_rec.tdb_information15,
  tdb_information16                 = p_rec.tdb_information16,
  tdb_information17                 = p_rec.tdb_information17,
  tdb_information18                 = p_rec.tdb_information18,
  tdb_information19                 = p_rec.tdb_information19,
  tdb_information20                 = p_rec.tdb_information20,
  organization_id                   = p_rec.organization_id,
  sponsor_person_id                 = p_rec.sponsor_person_id,
  sponsor_assignment_id             = p_rec.sponsor_assignment_id,
  person_address_id                 = p_rec.person_address_id,
  delegate_assignment_id            = p_rec.delegate_assignment_id,
  delegate_contact_id               = p_rec.delegate_contact_id,
  delegate_contact_email            = p_rec.delegate_contact_email,
  third_party_email                 = p_rec.third_party_email,
  person_address_type               = p_rec.person_address_type,
  line_id                                       = p_rec.line_id,
  org_id                                        = p_rec.org_id,
  daemon_flag                           = p_rec.daemon_flag,
  daemon_type                           = p_rec.daemon_type,
  old_event_id                       = p_rec.old_event_id,
  quote_line_id                      = p_rec.quote_line_id,
  interface_source                   = p_rec.interface_source,
  total_training_time                    = p_rec.total_training_time,
  content_player_status                  = p_rec.content_player_status,
  score                              = p_rec.score,
  completed_content                  = p_rec.completed_content,
  total_content                      = p_rec.total_content,
  booking_justification_id                   = p_rec.booking_justification_id,
  is_history_flag                    = p_rec.is_history_flag,
  sign_eval_status                   = p_rec.sign_eval_status
  where booking_id = p_rec.booking_id;
  --
  ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
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
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ota_tdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
/*ota_tdb_bus.chk_status_changed
                (p_line_id              => p_rec.line_id
                ,p_status_type_id       => p_rec.booking_status_type_id
                ,p_daemon_type  => p_rec.daemon_type
                ,p_event_id             => p_rec.event_id
                ,p_booking_id   => p_rec.booking_id
                ,p_org_id               => p_rec.org_id);  */
hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
            (p_rec                       in     ota_tdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    ota_tdb_bus.chk_status_changed
                (p_line_id              => p_rec.line_id
                ,p_status_type_id       => p_rec.booking_status_type_id
                ,p_daemon_type  => p_rec.daemon_type
                ,p_event_id             => p_rec.event_id
                ,p_booking_id   => p_rec.booking_id
                ,p_org_id               => p_rec.org_id);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_defs(p_rec in out nocopy ota_tdb_shd.g_rec_type)
         Return ota_tdb_shd.g_rec_type is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.booking_status_type_id = hr_api.g_number) then
    p_rec.booking_status_type_id :=
    ota_tdb_shd.g_old_rec.booking_status_type_id;
  End If;
  If (p_rec.delegate_person_id = hr_api.g_number) then
    p_rec.delegate_person_id :=
    ota_tdb_shd.g_old_rec.delegate_person_id;
  End If;
  If (p_rec.contact_id = hr_api.g_number) then
    p_rec.contact_id :=
    ota_tdb_shd.g_old_rec.contact_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ota_tdb_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.event_id = hr_api.g_number) then
    p_rec.event_id :=
    ota_tdb_shd.g_old_rec.event_id;
  End If;
  If (p_rec.customer_id = hr_api.g_number) then
    p_rec.customer_id :=
    ota_tdb_shd.g_old_rec.customer_id;
  End If;
  If (p_rec.authorizer_person_id = hr_api.g_number) then
    p_rec.authorizer_person_id :=
    ota_tdb_shd.g_old_rec.authorizer_person_id;
  End If;
  If (p_rec.date_booking_placed = hr_api.g_date) then
    p_rec.date_booking_placed :=
    ota_tdb_shd.g_old_rec.date_booking_placed;
  End If;
  If (p_rec.corespondent = hr_api.g_varchar2) then
    p_rec.corespondent :=
    ota_tdb_shd.g_old_rec.corespondent;
  End If;
  If (p_rec.internal_booking_flag = hr_api.g_varchar2) then
    p_rec.internal_booking_flag :=
    ota_tdb_shd.g_old_rec.internal_booking_flag;
  End If;
  If (p_rec.number_of_places = hr_api.g_number) then
    p_rec.number_of_places :=
    ota_tdb_shd.g_old_rec.number_of_places;
  End If;
  If (p_rec.administrator = hr_api.g_number) then
    p_rec.administrator :=
    ota_tdb_shd.g_old_rec.administrator;
  End If;
  If (p_rec.booking_priority = hr_api.g_varchar2) then
    p_rec.booking_priority :=
    ota_tdb_shd.g_old_rec.booking_priority;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_tdb_shd.g_old_rec.comments;
  End If;
  If (p_rec.contact_address_id = hr_api.g_number) then
    p_rec.contact_address_id :=
    ota_tdb_shd.g_old_rec.contact_address_id;
  End If;
  If (p_rec.delegate_contact_phone = hr_api.g_varchar2) then
    p_rec.delegate_contact_phone :=
    ota_tdb_shd.g_old_rec.delegate_contact_phone;
  End If;
  If (p_rec.delegate_contact_fax = hr_api.g_varchar2) then
    p_rec.delegate_contact_fax :=
    ota_tdb_shd.g_old_rec.delegate_contact_fax;
  End If;
  If (p_rec.third_party_customer_id = hr_api.g_number) then
    p_rec.third_party_customer_id :=
    ota_tdb_shd.g_old_rec.third_party_customer_id;
  End If;
  If (p_rec.third_party_contact_id = hr_api.g_number) then
    p_rec.third_party_contact_id :=
    ota_tdb_shd.g_old_rec.third_party_contact_id;
  End If;
  If (p_rec.third_party_address_id = hr_api.g_number) then
    p_rec.third_party_address_id :=
    ota_tdb_shd.g_old_rec.third_party_address_id;
  End If;
  If (p_rec.third_party_contact_phone = hr_api.g_varchar2) then
    p_rec.third_party_contact_phone :=
    ota_tdb_shd.g_old_rec.third_party_contact_phone;
  End If;
  If (p_rec.third_party_contact_fax = hr_api.g_varchar2) then
    p_rec.third_party_contact_fax :=
    ota_tdb_shd.g_old_rec.third_party_contact_fax;
  End If;
  If (p_rec.date_status_changed = hr_api.g_date) then
    p_rec.date_status_changed :=
    ota_tdb_shd.g_old_rec.date_status_changed;
  End If;
  If (p_rec.failure_reason = hr_api.g_varchar2) then
    p_rec.failure_reason :=
    ota_tdb_shd.g_old_rec.failure_reason;
  End If;
  If (p_rec.attendance_result = hr_api.g_varchar2) then
    p_rec.attendance_result :=
    ota_tdb_shd.g_old_rec.attendance_result;
  End If;
  If (p_rec.language_id = hr_api.g_number) then
    p_rec.language_id :=
    ota_tdb_shd.g_old_rec.language_id;
  End If;
  If (p_rec.source_of_booking = hr_api.g_varchar2) then
    p_rec.source_of_booking :=
    ota_tdb_shd.g_old_rec.source_of_booking;
  End If;
  If (p_rec.special_booking_instructions = hr_api.g_varchar2) then
    p_rec.special_booking_instructions :=
    ota_tdb_shd.g_old_rec.special_booking_instructions;
  End If;
  If (p_rec.successful_attendance_flag = hr_api.g_varchar2) then
    p_rec.successful_attendance_flag :=
    ota_tdb_shd.g_old_rec.successful_attendance_flag;
  End If;
  If (p_rec.tdb_information_category = hr_api.g_varchar2) then
    p_rec.tdb_information_category :=
    ota_tdb_shd.g_old_rec.tdb_information_category;
  End If;
  If (p_rec.tdb_information1 = hr_api.g_varchar2) then
    p_rec.tdb_information1 :=
    ota_tdb_shd.g_old_rec.tdb_information1;
  End If;
  If (p_rec.tdb_information2 = hr_api.g_varchar2) then
    p_rec.tdb_information2 :=
    ota_tdb_shd.g_old_rec.tdb_information2;
  End If;
  If (p_rec.tdb_information3 = hr_api.g_varchar2) then
    p_rec.tdb_information3 :=
    ota_tdb_shd.g_old_rec.tdb_information3;
  End If;
  If (p_rec.tdb_information4 = hr_api.g_varchar2) then
    p_rec.tdb_information4 :=
    ota_tdb_shd.g_old_rec.tdb_information4;
  End If;
  If (p_rec.tdb_information5 = hr_api.g_varchar2) then
    p_rec.tdb_information5 :=
    ota_tdb_shd.g_old_rec.tdb_information5;
  End If;
  If (p_rec.tdb_information6 = hr_api.g_varchar2) then
    p_rec.tdb_information6 :=
    ota_tdb_shd.g_old_rec.tdb_information6;
  End If;
  If (p_rec.tdb_information7 = hr_api.g_varchar2) then
    p_rec.tdb_information7 :=
    ota_tdb_shd.g_old_rec.tdb_information7;
  End If;
  If (p_rec.tdb_information8 = hr_api.g_varchar2) then
    p_rec.tdb_information8 :=
    ota_tdb_shd.g_old_rec.tdb_information8;
  End If;
  If (p_rec.tdb_information9 = hr_api.g_varchar2) then
    p_rec.tdb_information9 :=
    ota_tdb_shd.g_old_rec.tdb_information9;
  End If;
  If (p_rec.tdb_information10 = hr_api.g_varchar2) then
    p_rec.tdb_information10 :=
    ota_tdb_shd.g_old_rec.tdb_information10;
  End If;
  If (p_rec.tdb_information11 = hr_api.g_varchar2) then
    p_rec.tdb_information11 :=
    ota_tdb_shd.g_old_rec.tdb_information11;
  End If;
  If (p_rec.tdb_information12 = hr_api.g_varchar2) then
    p_rec.tdb_information12 :=
    ota_tdb_shd.g_old_rec.tdb_information12;
  End If;
  If (p_rec.tdb_information13 = hr_api.g_varchar2) then
    p_rec.tdb_information13 :=
    ota_tdb_shd.g_old_rec.tdb_information13;
  End If;
  If (p_rec.tdb_information14 = hr_api.g_varchar2) then
    p_rec.tdb_information14 :=
    ota_tdb_shd.g_old_rec.tdb_information14;
  End If;
  If (p_rec.tdb_information15 = hr_api.g_varchar2) then
    p_rec.tdb_information15 :=
    ota_tdb_shd.g_old_rec.tdb_information15;
  End If;
  If (p_rec.tdb_information16 = hr_api.g_varchar2) then
    p_rec.tdb_information16 :=
    ota_tdb_shd.g_old_rec.tdb_information16;
  End If;
  If (p_rec.tdb_information17 = hr_api.g_varchar2) then
    p_rec.tdb_information17 :=
    ota_tdb_shd.g_old_rec.tdb_information17;
  End If;
  If (p_rec.tdb_information18 = hr_api.g_varchar2) then
    p_rec.tdb_information18 :=
    ota_tdb_shd.g_old_rec.tdb_information18;
  End If;
  If (p_rec.tdb_information19 = hr_api.g_varchar2) then
    p_rec.tdb_information19 :=
    ota_tdb_shd.g_old_rec.tdb_information19;
  End If;
  If (p_rec.tdb_information20 = hr_api.g_varchar2) then
    p_rec.tdb_information20 :=
    ota_tdb_shd.g_old_rec.tdb_information20;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ota_tdb_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.sponsor_person_id = hr_api.g_number) then
    p_rec.sponsor_person_id :=
    ota_tdb_shd.g_old_rec.sponsor_person_id;
  End If;
  If (p_rec.sponsor_assignment_id = hr_api.g_number) then
    p_rec.sponsor_assignment_id :=
    ota_tdb_shd.g_old_rec.sponsor_assignment_id;
  End If;
  If (p_rec.person_address_id = hr_api.g_number) then
    p_rec.person_address_id :=
    ota_tdb_shd.g_old_rec.person_address_id;
  End If;
  If (p_rec.delegate_assignment_id = hr_api.g_number) then
    p_rec.delegate_assignment_id :=
    ota_tdb_shd.g_old_rec.delegate_assignment_id;
  End If;
  If (p_rec.delegate_contact_id = hr_api.g_number) then
    p_rec.delegate_contact_id :=
    ota_tdb_shd.g_old_rec.delegate_contact_id;
  End If;
  If (p_rec.delegate_contact_email = hr_api.g_varchar2) then
    p_rec.delegate_contact_email :=
    ota_tdb_shd.g_old_rec.delegate_contact_email;
  End If;
  If (p_rec.third_party_email = hr_api.g_varchar2) then
    p_rec.third_party_email :=
    ota_tdb_shd.g_old_rec.third_party_email;
  End If;
  If (p_rec.person_address_type = hr_api.g_varchar2) then
    p_rec.person_address_type :=
    ota_tdb_shd.g_old_rec.person_address_type;
  End If;
  If (p_rec.line_id = hr_api.g_number) then
    p_rec.line_id :=
    ota_tdb_shd.g_old_rec.line_id;
  End If;
   If (p_rec.org_id = hr_api.g_number) then
    p_rec.org_id :=
    ota_tdb_shd.g_old_rec.org_id;
  End If;
  If (p_rec.daemon_flag = hr_api.g_varchar2) then
    p_rec.daemon_flag :=
    ota_tdb_shd.g_old_rec.daemon_flag;
  End If;
   If (p_rec.daemon_type = hr_api.g_varchar2) then
    p_rec.daemon_type :=
    ota_tdb_shd.g_old_rec.daemon_type;
  End If;

  If (p_rec.old_event_id = hr_api.g_number) then
    p_rec.old_event_id :=
    ota_tdb_shd.g_old_rec.old_event_id;
  End If;

  If (p_rec.quote_line_id = hr_api.g_number) then
    p_rec.quote_line_id :=
    ota_tdb_shd.g_old_rec.quote_line_id;
  End If;

  If (p_rec.interface_source = hr_api.g_varchar2) then
    p_rec.interface_source :=
    ota_tdb_shd.g_old_rec.interface_source;
  End If;

  If (p_rec.total_training_time = hr_api.g_varchar2) then
    p_rec.total_training_time :=
    ota_tdb_shd.g_old_rec.total_training_time ;
  End If;

 If (p_rec.content_player_status= hr_api.g_varchar2) then
    p_rec.content_player_status:=
    ota_tdb_shd.g_old_rec.content_player_status;
  End If;

 If (p_rec.score = hr_api.g_number) then
    p_rec.score:=
    ota_tdb_shd.g_old_rec.score;
  End If;
 If (p_rec.completed_content= hr_api.g_number) then
    p_rec.completed_content:=
    ota_tdb_shd.g_old_rec.completed_content;
  End If;
 If (p_rec.total_content = hr_api.g_number) then
    p_rec.total_content :=
    ota_tdb_shd.g_old_rec.total_content ;
  End If;
  if (p_rec.booking_justification_id = hr_api.g_number) then
    p_rec.booking_justification_id :=
      ota_tdb_shd.g_old_rec.booking_justification_id;
  End If;
  if (p_rec.is_history_flag = hr_api.g_varchar2) then
    p_rec.is_history_flag :=
      ota_tdb_shd.g_old_rec.is_history_flag;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec                       in out nocopy ota_tdb_shd.g_rec_type,
  p_status_change_comments    in     varchar2,
  p_update_finance_line       in     varchar2,
  p_tfl_object_version_number in out nocopy number,
  p_finance_header_id         in     number,
  p_finance_line_id           in out nocopy number,
  p_standard_amount           in     number,
  p_unitary_amount            in     number,
  p_money_amount              in     number,
  p_currency_code             in     varchar2,
  p_booking_deal_type         in     varchar2,
  p_booking_deal_id           in     number,
  p_enrollment_type           in     varchar2,
  p_validate                  in     boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
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
    SAVEPOINT upd_ota_tdb;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_tdb_shd.lck
        (
        p_rec.booking_id,
        p_rec.object_version_number
        );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  ota_tdb_bus.update_validate(convert_defs(p_rec),p_enrollment_type);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
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
    ROLLBACK TO upd_ota_tdb;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_booking_id                   in number,
  p_booking_status_type_id       in number           ,
  p_delegate_person_id           in number           ,
  p_contact_id                   in number           ,
  p_business_group_id            in number           ,
  p_event_id                     in number           ,
  p_customer_id                  in number           ,
  p_authorizer_person_id         in number           ,
  p_date_booking_placed          in date             ,
  p_corespondent                 in varchar2         ,
  p_internal_booking_flag        in varchar2         ,
  p_number_of_places             in number           ,
  p_object_version_number        in out nocopy number,
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
  p_status_change_comments       in varchar2         ,
  p_failure_reason               in varchar2         ,
  p_attendance_result            in varchar2         ,
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
  p_update_finance_line          in varchar2         ,
  p_tfl_object_version_number    in out nocopy number,
  p_finance_header_id            in number           ,
  p_finance_line_id              in out nocopy number,
  p_standard_amount              in number           ,
  p_unitary_amount               in number           ,
  p_money_amount                 in number           ,
  p_currency_code                in varchar2         ,
  p_booking_deal_type            in varchar2         ,
  p_booking_deal_id              in number           ,
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
  p_daemon_flag                    in varchar2       ,
  p_daemon_type                    in varchar2       ,
  p_old_event_id                 in number           ,
  p_quote_line_id                in number           ,
  p_interface_source             in varchar2         ,
  p_total_training_time          in varchar2         ,
  p_content_player_status        in varchar2         ,
  p_score                              in number             ,
  p_completed_content              in number         ,
  p_total_content                      in number               ,
  p_booking_justification_id               in number,
  p_is_history_flag in varchar2,
  p_sign_eval_status in varchar2
  ) is
--
  l_rec   ota_tdb_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_tdb_shd.convert_args
  (
  p_booking_id,
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
  p_object_version_number,
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
  p_total_content ,
  p_booking_justification_id,
  p_is_history_flag,
  p_sign_eval_status
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec,
      p_status_change_comments,
      p_update_finance_line,
      p_tfl_object_version_number,
      p_finance_header_id,
      p_finance_line_id ,
      p_standard_amount,
      p_unitary_amount ,
      p_money_amount  ,
      p_currency_code,
      p_booking_deal_type,
      p_booking_deal_id,
      p_enrollment_type,
      p_validate
      );

  --
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_tdb_upd;

/
