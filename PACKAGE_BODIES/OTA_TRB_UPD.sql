--------------------------------------------------------
--  DDL for Package Body OTA_TRB_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRB_UPD" as
/* $Header: ottrbrhi.pkb 120.6.12000000.3 2007/07/05 09:22:53 aabalakr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_trb_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
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
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ota_trb_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_resource_bookings Row
  --
  update ota_resource_bookings
    set
     resource_booking_id             = p_rec.resource_booking_id
    ,supplied_resource_id            = p_rec.supplied_resource_id
    ,event_id                        = p_rec.event_id
    ,date_booking_placed             = p_rec.date_booking_placed
    ,object_version_number           = p_rec.object_version_number
    ,status                          = p_rec.status
    ,absolute_price                  = p_rec.absolute_price
    ,booking_person_id               = p_rec.booking_person_id
    ,comments                        = p_rec.comments
    ,contact_name                    = p_rec.contact_name
    ,contact_phone_number            = p_rec.contact_phone_number
    ,delegates_per_unit              = p_rec.delegates_per_unit
    ,quantity                        = p_rec.quantity
    ,required_date_from              = p_rec.required_date_from
    ,required_date_to                = p_rec.required_date_to
    ,required_end_time               = p_rec.required_end_time
    ,required_start_time             = p_rec.required_start_time
    ,deliver_to                      = p_rec.deliver_to
    ,primary_venue_flag              = p_rec.primary_venue_flag
    ,role_to_play                    = p_rec.role_to_play
    ,trb_information_category        = p_rec.trb_information_category
    ,trb_information1                = p_rec.trb_information1
    ,trb_information2                = p_rec.trb_information2
    ,trb_information3                = p_rec.trb_information3
    ,trb_information4                = p_rec.trb_information4
    ,trb_information5                = p_rec.trb_information5
    ,trb_information6                = p_rec.trb_information6
    ,trb_information7                = p_rec.trb_information7
    ,trb_information8                = p_rec.trb_information8
    ,trb_information9                = p_rec.trb_information9
    ,trb_information10               = p_rec.trb_information10
    ,trb_information11               = p_rec.trb_information11
    ,trb_information12               = p_rec.trb_information12
    ,trb_information13               = p_rec.trb_information13
    ,trb_information14               = p_rec.trb_information14
    ,trb_information15               = p_rec.trb_information15
    ,trb_information16               = p_rec.trb_information16
    ,trb_information17               = p_rec.trb_information17
    ,trb_information18               = p_rec.trb_information18
    ,trb_information19               = p_rec.trb_information19
    ,trb_information20               = p_rec.trb_information20
    ,display_to_learner_flag      = p_rec.display_to_learner_flag
  ,book_entire_period_flag    = p_rec.book_entire_period_flag
--  ,unbook_request_flag    in    = p_rec.unbook_request_flag
    ,chat_id                         = p_rec.chat_id
    ,forum_id                        = p_rec.forum_id
    ,timezone_code                   = p_rec.timezone_code
    where resource_booking_id = p_rec.resource_booking_id;
  --
  ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
    ota_trb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
    ota_trb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
    ota_trb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_effective_date               in date
  ,p_rec                          in ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_trb_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_resource_booking_id
      => p_rec.resource_booking_id
      ,p_supplied_resource_id
      => p_rec.supplied_resource_id
      ,p_event_id
      => p_rec.event_id
      ,p_date_booking_placed
      => p_rec.date_booking_placed
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_status
      => p_rec.status
      ,p_absolute_price
      => p_rec.absolute_price
      ,p_booking_person_id
      => p_rec.booking_person_id
      ,p_comments
      => p_rec.comments
      ,p_contact_name
      => p_rec.contact_name
      ,p_contact_phone_number
      => p_rec.contact_phone_number
      ,p_delegates_per_unit
      => p_rec.delegates_per_unit
      ,p_quantity
      => p_rec.quantity
      ,p_required_date_from
      => p_rec.required_date_from
      ,p_required_date_to
      => p_rec.required_date_to
      ,p_required_end_time
      => p_rec.required_end_time
      ,p_required_start_time
      => p_rec.required_start_time
      ,p_deliver_to
      => p_rec.deliver_to
      ,p_primary_venue_flag
      => p_rec.primary_venue_flag
      ,p_role_to_play
      => p_rec.role_to_play
      ,p_trb_information_category
      => p_rec.trb_information_category
      ,p_trb_information1
      => p_rec.trb_information1
      ,p_trb_information2
      => p_rec.trb_information2
      ,p_trb_information3
      => p_rec.trb_information3
      ,p_trb_information4
      => p_rec.trb_information4
      ,p_trb_information5
      => p_rec.trb_information5
      ,p_trb_information6
      => p_rec.trb_information6
      ,p_trb_information7
      => p_rec.trb_information7
      ,p_trb_information8
      => p_rec.trb_information8
      ,p_trb_information9
      => p_rec.trb_information9
      ,p_trb_information10
      => p_rec.trb_information10
      ,p_trb_information11
      => p_rec.trb_information11
      ,p_trb_information12
      => p_rec.trb_information12
      ,p_trb_information13
      => p_rec.trb_information13
      ,p_trb_information14
      => p_rec.trb_information14
      ,p_trb_information15
      => p_rec.trb_information15
      ,p_trb_information16
      => p_rec.trb_information16
      ,p_trb_information17
      => p_rec.trb_information17
      ,p_trb_information18
      => p_rec.trb_information18
      ,p_trb_information19
      => p_rec.trb_information19
      ,p_trb_information20
      => p_rec.trb_information20
      ,p_display_to_learner_flag
      => p_rec.display_to_learner_flag
      ,p_book_entire_period_flag
      => p_rec.book_entire_period_flag
     /* ,p_unbook_request_flag
      => p_rec.unbook_request_flag */
      ,p_chat_id
      => p_rec.chat_id
      ,p_forum_id
      => p_rec.forum_id
      ,p_timezone_code
      => p_rec.timezone_code
      ,p_supplied_resource_id_o
      => ota_trb_shd.g_old_rec.supplied_resource_id
      ,p_event_id_o
      => ota_trb_shd.g_old_rec.event_id
      ,p_date_booking_placed_o
      => ota_trb_shd.g_old_rec.date_booking_placed
      ,p_object_version_number_o
      => ota_trb_shd.g_old_rec.object_version_number
      ,p_status_o
      => ota_trb_shd.g_old_rec.status
      ,p_absolute_price_o
      => ota_trb_shd.g_old_rec.absolute_price
      ,p_booking_person_id_o
      => ota_trb_shd.g_old_rec.booking_person_id
      ,p_comments_o
      => ota_trb_shd.g_old_rec.comments
      ,p_contact_name_o
      => ota_trb_shd.g_old_rec.contact_name
      ,p_contact_phone_number_o
      => ota_trb_shd.g_old_rec.contact_phone_number
      ,p_delegates_per_unit_o
      => ota_trb_shd.g_old_rec.delegates_per_unit
      ,p_quantity_o
      => ota_trb_shd.g_old_rec.quantity
      ,p_required_date_from_o
      => ota_trb_shd.g_old_rec.required_date_from
      ,p_required_date_to_o
      => ota_trb_shd.g_old_rec.required_date_to
      ,p_required_end_time_o
      => ota_trb_shd.g_old_rec.required_end_time
      ,p_required_start_time_o
      => ota_trb_shd.g_old_rec.required_start_time
      ,p_deliver_to_o
      => ota_trb_shd.g_old_rec.deliver_to
      ,p_primary_venue_flag_o
      => ota_trb_shd.g_old_rec.primary_venue_flag
      ,p_role_to_play_o
      => ota_trb_shd.g_old_rec.role_to_play
      ,p_trb_information_category_o
      => ota_trb_shd.g_old_rec.trb_information_category
      ,p_trb_information1_o
      => ota_trb_shd.g_old_rec.trb_information1
      ,p_trb_information2_o
      => ota_trb_shd.g_old_rec.trb_information2
      ,p_trb_information3_o
      => ota_trb_shd.g_old_rec.trb_information3
      ,p_trb_information4_o
      => ota_trb_shd.g_old_rec.trb_information4
      ,p_trb_information5_o
      => ota_trb_shd.g_old_rec.trb_information5
      ,p_trb_information6_o
      => ota_trb_shd.g_old_rec.trb_information6
      ,p_trb_information7_o
      => ota_trb_shd.g_old_rec.trb_information7
      ,p_trb_information8_o
      => ota_trb_shd.g_old_rec.trb_information8
      ,p_trb_information9_o
      => ota_trb_shd.g_old_rec.trb_information9
      ,p_trb_information10_o
      => ota_trb_shd.g_old_rec.trb_information10
      ,p_trb_information11_o
      => ota_trb_shd.g_old_rec.trb_information11
      ,p_trb_information12_o
      => ota_trb_shd.g_old_rec.trb_information12
      ,p_trb_information13_o
      => ota_trb_shd.g_old_rec.trb_information13
      ,p_trb_information14_o
      => ota_trb_shd.g_old_rec.trb_information14
      ,p_trb_information15_o
      => ota_trb_shd.g_old_rec.trb_information15
      ,p_trb_information16_o
      => ota_trb_shd.g_old_rec.trb_information16
      ,p_trb_information17_o
      => ota_trb_shd.g_old_rec.trb_information17
      ,p_trb_information18_o
      => ota_trb_shd.g_old_rec.trb_information18
      ,p_trb_information19_o
      => ota_trb_shd.g_old_rec.trb_information19
      ,p_trb_information20_o
      => ota_trb_shd.g_old_rec.trb_information20
      ,p_display_to_learner_flag_o
      => ota_trb_shd.g_old_rec.display_to_learner_flag
      ,p_book_entire_period_flag_o
      => ota_trb_shd.g_old_rec.book_entire_period_flag
    /*  ,p_unbook_request_flag_o
      => ota_trb_shd.g_old_rec.unbook_request_flag */
      ,p_chat_id_o
      => ota_trb_shd.g_old_rec.chat_id
      ,p_forum_id_o
      => ota_trb_shd.g_old_rec.forum_id
      ,p_timezone_code_o
      => ota_trb_shd.g_old_rec.timezone_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_RESOURCE_BOOKINGS'
        ,p_hook_type   => 'AU');
      --
  end;
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
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy ota_trb_shd.g_rec_type
  ) is
--
  l_proc	  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.supplied_resource_id = hr_api.g_number) then
    p_rec.supplied_resource_id :=
    ota_trb_shd.g_old_rec.supplied_resource_id;
  End If;
  If (p_rec.event_id = hr_api.g_number) then
    p_rec.event_id :=
    ota_trb_shd.g_old_rec.event_id;
  End If;
  If (p_rec.date_booking_placed = hr_api.g_date) then
    p_rec.date_booking_placed :=
    ota_trb_shd.g_old_rec.date_booking_placed;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    ota_trb_shd.g_old_rec.status;
  End If;
  If (p_rec.absolute_price = hr_api.g_number) then
    p_rec.absolute_price :=
    ota_trb_shd.g_old_rec.absolute_price;
  End If;
  If (p_rec.booking_person_id = hr_api.g_number) then
    p_rec.booking_person_id :=
    ota_trb_shd.g_old_rec.booking_person_id;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_trb_shd.g_old_rec.comments;
  End If;
  If (p_rec.contact_name = hr_api.g_varchar2) then
    p_rec.contact_name :=
    ota_trb_shd.g_old_rec.contact_name;
  End If;
  If (p_rec.contact_phone_number = hr_api.g_varchar2) then
    p_rec.contact_phone_number :=
    ota_trb_shd.g_old_rec.contact_phone_number;
  End If;
  If (p_rec.delegates_per_unit = hr_api.g_number) then
    p_rec.delegates_per_unit :=
    ota_trb_shd.g_old_rec.delegates_per_unit;
  End If;
  If (p_rec.quantity = hr_api.g_number) then
    p_rec.quantity :=
    ota_trb_shd.g_old_rec.quantity;
  End If;
  If (p_rec.required_date_from = hr_api.g_date) then
    p_rec.required_date_from :=
    ota_trb_shd.g_old_rec.required_date_from;
  End If;
  If (p_rec.required_date_to = hr_api.g_date) then
    p_rec.required_date_to :=
    ota_trb_shd.g_old_rec.required_date_to;
  End If;
  If (p_rec.required_end_time = hr_api.g_varchar2) then
    p_rec.required_end_time :=
    ota_trb_shd.g_old_rec.required_end_time;
  End If;
  If (p_rec.required_start_time = hr_api.g_varchar2) then
    p_rec.required_start_time :=
    ota_trb_shd.g_old_rec.required_start_time;
  End If;
  If (p_rec.deliver_to = hr_api.g_varchar2) then
    p_rec.deliver_to :=
    ota_trb_shd.g_old_rec.deliver_to;
  End If;
  If (p_rec.primary_venue_flag = hr_api.g_varchar2) then
    p_rec.primary_venue_flag :=
    ota_trb_shd.g_old_rec.primary_venue_flag;
  End If;
  If (p_rec.role_to_play = hr_api.g_varchar2) then
    p_rec.role_to_play :=
    ota_trb_shd.g_old_rec.role_to_play;
  End If;
  If (p_rec.trb_information_category = hr_api.g_varchar2) then
    p_rec.trb_information_category :=
    ota_trb_shd.g_old_rec.trb_information_category;
  End If;
  If (p_rec.trb_information1 = hr_api.g_varchar2) then
    p_rec.trb_information1 :=
    ota_trb_shd.g_old_rec.trb_information1;
  End If;
  If (p_rec.trb_information2 = hr_api.g_varchar2) then
    p_rec.trb_information2 :=
    ota_trb_shd.g_old_rec.trb_information2;
  End If;
  If (p_rec.trb_information3 = hr_api.g_varchar2) then
    p_rec.trb_information3 :=
    ota_trb_shd.g_old_rec.trb_information3;
  End If;
  If (p_rec.trb_information4 = hr_api.g_varchar2) then
    p_rec.trb_information4 :=
    ota_trb_shd.g_old_rec.trb_information4;
  End If;
  If (p_rec.trb_information5 = hr_api.g_varchar2) then
    p_rec.trb_information5 :=
    ota_trb_shd.g_old_rec.trb_information5;
  End If;
  If (p_rec.trb_information6 = hr_api.g_varchar2) then
    p_rec.trb_information6 :=
    ota_trb_shd.g_old_rec.trb_information6;
  End If;
  If (p_rec.trb_information7 = hr_api.g_varchar2) then
    p_rec.trb_information7 :=
    ota_trb_shd.g_old_rec.trb_information7;
  End If;
  If (p_rec.trb_information8 = hr_api.g_varchar2) then
    p_rec.trb_information8 :=
    ota_trb_shd.g_old_rec.trb_information8;
  End If;
  If (p_rec.trb_information9 = hr_api.g_varchar2) then
    p_rec.trb_information9 :=
    ota_trb_shd.g_old_rec.trb_information9;
  End If;
  If (p_rec.trb_information10 = hr_api.g_varchar2) then
    p_rec.trb_information10 :=
    ota_trb_shd.g_old_rec.trb_information10;
  End If;
  If (p_rec.trb_information11 = hr_api.g_varchar2) then
    p_rec.trb_information11 :=
    ota_trb_shd.g_old_rec.trb_information11;
  End If;
  If (p_rec.trb_information12 = hr_api.g_varchar2) then
    p_rec.trb_information12 :=
    ota_trb_shd.g_old_rec.trb_information12;
  End If;
  If (p_rec.trb_information13 = hr_api.g_varchar2) then
    p_rec.trb_information13 :=
    ota_trb_shd.g_old_rec.trb_information13;
  End If;
  If (p_rec.trb_information14 = hr_api.g_varchar2) then
    p_rec.trb_information14 :=
    ota_trb_shd.g_old_rec.trb_information14;
  End If;
  If (p_rec.trb_information15 = hr_api.g_varchar2) then
    p_rec.trb_information15 :=
    ota_trb_shd.g_old_rec.trb_information15;
  End If;
  If (p_rec.trb_information16 = hr_api.g_varchar2) then
    p_rec.trb_information16 :=
    ota_trb_shd.g_old_rec.trb_information16;
  End If;
  If (p_rec.trb_information17 = hr_api.g_varchar2) then
    p_rec.trb_information17 :=
    ota_trb_shd.g_old_rec.trb_information17;
  End If;
  If (p_rec.trb_information18 = hr_api.g_varchar2) then
    p_rec.trb_information18 :=
    ota_trb_shd.g_old_rec.trb_information18;
  End If;
  If (p_rec.trb_information19 = hr_api.g_varchar2) then
    p_rec.trb_information19 :=
    ota_trb_shd.g_old_rec.trb_information19;
  End If;
  If (p_rec.trb_information20 = hr_api.g_varchar2) then
    p_rec.trb_information20 :=
    ota_trb_shd.g_old_rec.trb_information20;
  End If;
  If (p_rec.display_to_learner_flag = hr_api.g_varchar2) then
    p_rec.display_to_learner_flag :=
    ota_trb_shd.g_old_rec.display_to_learner_flag;
  End If;
  If (p_rec.book_entire_period_flag = hr_api.g_varchar2) then
    p_rec.book_entire_period_flag :=
    ota_trb_shd.g_old_rec.book_entire_period_flag;
  End If;
 /* If (p_rec.unbook_request_flag = hr_api.g_varchar2) then
    p_rec.unbook_request_flag :=
    ota_trb_shd.g_old_rec.unbook_request_flag;
  End If; */
  If (p_rec.chat_id = hr_api.g_number) then
    p_rec.chat_id :=
    ota_trb_shd.g_old_rec.chat_id;
  End If;
  If (p_rec.forum_id = hr_api.g_number) then
    p_rec.forum_id :=
    ota_trb_shd.g_old_rec.forum_id;
  End If;
  If (p_rec.timezone_code = hr_api.g_varchar2) then
    p_rec.timezone_code :=
    ota_trb_shd.g_old_rec.timezone_code;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ota_trb_shd.lck
    (p_rec.resource_booking_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ota_trb_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ota_trb_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ota_trb_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ota_trb_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_resource_booking_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_supplied_resource_id         in     number    default hr_api.g_number
  ,p_date_booking_placed          in     date      default hr_api.g_date
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_absolute_price               in     number    default hr_api.g_number
  ,p_booking_person_id            in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_contact_name                 in     varchar2  default hr_api.g_varchar2
  ,p_contact_phone_number         in     varchar2  default hr_api.g_varchar2
  ,p_delegates_per_unit           in     number    default hr_api.g_number
  ,p_quantity                     in     number    default hr_api.g_number
  ,p_required_date_from           in     date      default hr_api.g_date
  ,p_required_date_to             in     date      default hr_api.g_date
  ,p_required_end_time            in     varchar2  default hr_api.g_varchar2
  ,p_required_start_time          in     varchar2  default hr_api.g_varchar2
  ,p_deliver_to                   in     varchar2  default hr_api.g_varchar2
  ,p_primary_venue_flag           in     varchar2  default hr_api.g_varchar2
  ,p_role_to_play                 in     varchar2  default hr_api.g_varchar2
  ,p_trb_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_trb_information1             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information2             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information3             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information4             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information5             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information6             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information7             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information8             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information9             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information10            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information11            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information12            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information13            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information14            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information15            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information16            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information17            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information18            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information19            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information20            in     varchar2  default hr_api.g_varchar2
  ,p_display_to_learner_flag      in     varchar2  default hr_api.g_varchar2
  ,p_book_entire_period_flag    in     varchar2  default hr_api.g_varchar2
--  ,p_unbook_request_flag	  in     varchar2  default hr_api.g_varchar2
  ,p_chat_id                      in     number    default hr_api.g_number
  ,p_forum_id                     in     number    default hr_api.g_number
  ,p_timezone_code                IN    VARCHAR2   DEFAULT hr_api.g_varchar2
  ) is
--
  l_rec   ota_trb_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_trb_shd.convert_args
  (p_resource_booking_id
  ,p_supplied_resource_id
  ,p_event_id
  ,p_date_booking_placed
  ,p_object_version_number
  ,p_status
  ,p_absolute_price
  ,p_booking_person_id
  ,p_comments
  ,p_contact_name
  ,p_contact_phone_number
  ,p_delegates_per_unit
  ,p_quantity
  ,p_required_date_from
  ,p_required_date_to
  ,p_required_end_time
  ,p_required_start_time
  ,p_deliver_to
  ,p_primary_venue_flag
  ,p_role_to_play
  ,p_trb_information_category
  ,p_trb_information1
  ,p_trb_information2
  ,p_trb_information3
  ,p_trb_information4
  ,p_trb_information5
  ,p_trb_information6
  ,p_trb_information7
  ,p_trb_information8
  ,p_trb_information9
  ,p_trb_information10
  ,p_trb_information11
  ,p_trb_information12
  ,p_trb_information13
  ,p_trb_information14
  ,p_trb_information15
  ,p_trb_information16
  ,p_trb_information17
  ,p_trb_information18
  ,p_trb_information19
  ,p_trb_information20
  ,p_display_to_learner_flag
  ,p_book_entire_period_flag
 -- ,p_unbook_request_flag
  ,p_chat_id
  ,p_forum_id
  ,p_timezone_code
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ota_trb_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_trb_upd;

/
