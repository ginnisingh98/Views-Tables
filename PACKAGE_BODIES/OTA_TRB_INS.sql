--------------------------------------------------------
--  DDL for Package Body OTA_TRB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRB_INS" as
/* $Header: ottrbrhi.pkb 120.6.12000000.3 2007/07/05 09:22:53 aabalakr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_trb_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_resource_booking_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_resource_booking_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_trb_ins.g_resource_booking_id_i := p_resource_booking_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
Procedure insert_dml
  (p_rec in out nocopy ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_trb_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_resource_bookings
  --
  insert into ota_resource_bookings
      (resource_booking_id
      ,supplied_resource_id
      ,event_id
      ,date_booking_placed
      ,object_version_number
      ,status
      ,absolute_price
      ,booking_person_id
      ,comments
      ,contact_name
      ,contact_phone_number
      ,delegates_per_unit
      ,quantity
      ,required_date_from
      ,required_date_to
      ,required_end_time
      ,required_start_time
      ,deliver_to
      ,primary_venue_flag
      ,role_to_play
      ,trb_information_category
      ,trb_information1
      ,trb_information2
      ,trb_information3
      ,trb_information4
      ,trb_information5
      ,trb_information6
      ,trb_information7
      ,trb_information8
      ,trb_information9
      ,trb_information10
      ,trb_information11
      ,trb_information12
      ,trb_information13
      ,trb_information14
      ,trb_information15
      ,trb_information16
      ,trb_information17
      ,trb_information18
      ,trb_information19
      ,trb_information20
      ,display_to_learner_flag
      ,book_entire_period_flag
    --  ,unbook_request_flag
     ,chat_id
     ,forum_id
     ,timezone_code
      )
  Values
    (p_rec.resource_booking_id
    ,p_rec.supplied_resource_id
    ,p_rec.event_id
    ,p_rec.date_booking_placed
    ,p_rec.object_version_number
    ,p_rec.status
    ,p_rec.absolute_price
    ,p_rec.booking_person_id
    ,p_rec.comments
    ,p_rec.contact_name
    ,p_rec.contact_phone_number
    ,p_rec.delegates_per_unit
    ,p_rec.quantity
    ,p_rec.required_date_from
    ,p_rec.required_date_to
    ,p_rec.required_end_time
    ,p_rec.required_start_time
    ,p_rec.deliver_to
    ,p_rec.primary_venue_flag
    ,p_rec.role_to_play
    ,p_rec.trb_information_category
    ,p_rec.trb_information1
    ,p_rec.trb_information2
    ,p_rec.trb_information3
    ,p_rec.trb_information4
    ,p_rec.trb_information5
    ,p_rec.trb_information6
    ,p_rec.trb_information7
    ,p_rec.trb_information8
    ,p_rec.trb_information9
    ,p_rec.trb_information10
    ,p_rec.trb_information11
    ,p_rec.trb_information12
    ,p_rec.trb_information13
    ,p_rec.trb_information14
    ,p_rec.trb_information15
    ,p_rec.trb_information16
    ,p_rec.trb_information17
    ,p_rec.trb_information18
    ,p_rec.trb_information19
    ,p_rec.trb_information20
    ,p_rec.display_to_learner_flag
   ,p_rec.book_entire_period_flag
 --   ,p_rec.unbook_request_flag
    ,p_rec.chat_id
    ,p_rec.forum_id
    ,p_rec.timezone_code
    );
  --
  ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure pre_insert
  (p_rec  in out nocopy ota_trb_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ota_resource_bookings_s.nextval from sys.dual;
--
--   Cursor to check Automatic Primary Venue
--
  Cursor C_Sel2 is
  Select null
  From ota_resource_bookings orb
  Where orb.event_id = p_rec.event_id
  and   orb.primary_venue_flag = 'Y'
  and   orb.supplied_resource_id in(
	   Select osr.supplied_resource_id
	   from ota_suppliable_resources osr
	   where osr.resource_type = 'V');
--
  Cursor C_Sel3 is
  SELECT resource_type
  FROM   OTA_SUPPLIABLE_RESOURCES
  WHERE  SUPPLIED_RESOURCE_ID = p_rec.supplied_resource_id;
--
  Cursor C_Sel4 is
    Select null
      from ota_resource_bookings
     where resource_booking_id =
             ota_trb_ins.g_resource_booking_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exist  varchar2(1);
  l_resource_type  ota_suppliable_resources.resource_type%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ota_trb_ins.g_resource_booking_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel4;
    Fetch C_Sel4 into l_exist;
    If C_Sel4%found Then
       Close C_Sel4;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','ota_resource_bookings');
       fnd_message.raise_error;
    End If;
    Close C_Sel4;
    --
    -- Use registered key values and clear globals
    --
    p_rec.resource_booking_id :=
      ota_trb_ins.g_resource_booking_id_i;
    ota_trb_ins.g_resource_booking_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.resource_booking_id;
    Close C_Sel1;
  End If;
  --
 -- Check if there's a existing Primary Venue
  --
  If p_rec.event_id is not null then
     Open C_Sel2;
     Fetch C_Sel2 into l_exist;
     If C_Sel2%notfound Then
        OPEN C_Sel3;
        FETCH C_Sel3 INTO l_resource_type;
        IF l_resource_type = 'V' then
  --
  --        Check the Primary Venue as a Primary if is not
  --
            If p_rec.primary_venue_flag  ='N' then
               p_rec.primary_venue_flag:='Y';
            End If;
        END IF;
        CLOSE C_Sel3;
     End If;
       Close C_Sel2;
  End If; -- Check if there's a existing Primary Venue
  --
  If p_rec.event_id is not null then
     Open C_Sel2;
     Fetch C_Sel2 into l_exist;
     If C_Sel2%notfound Then
        OPEN C_Sel3;
        FETCH C_Sel3 INTO l_resource_type;
        IF l_resource_type = 'V' then
  --
  --        Check the Primary Venue as a Primary if is not
  --
            If p_rec.primary_venue_flag  ='N' then
               p_rec.primary_venue_flag:='Y';
            End If;
        END IF;
        CLOSE C_Sel3;
     End If;
       Close C_Sel2;
  End If;
  --
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
--   This private procedure contains any processing which is required after
--   the insert dml.
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
Procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_trb_rki.after_insert
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
    /*  ,p_unbook_request_flag
      => p_rec.unbook_request_flag*/
      ,p_chat_id
      => p_rec.chat_id
      ,p_forum_id
      => p_rec.forum_id
      ,p_timezone_code
      => p_rec.timezone_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_RESOURCE_BOOKINGS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ota_trb_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ota_trb_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ota_trb_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ota_trb_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_supplied_resource_id           in     number
  ,p_date_booking_placed            in     date
  ,p_status                         in     varchar2
  ,p_event_id                       in     number   default null
  ,p_absolute_price                 in     number   default null
  ,p_booking_person_id              in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_contact_name                   in     varchar2 default null
  ,p_contact_phone_number           in     varchar2 default null
  ,p_delegates_per_unit             in     number   default null
  ,p_quantity                       in     number   default null
  ,p_required_date_from             in     date     default null
  ,p_required_date_to               in     date     default null
  ,p_required_end_time              in     varchar2 default null
  ,p_required_start_time            in     varchar2 default null
  ,p_deliver_to                     in     varchar2 default null
  ,p_primary_venue_flag             in     varchar2 default null
  ,p_role_to_play                   in     varchar2 default null
  ,p_trb_information_category       in     varchar2 default null
  ,p_trb_information1               in     varchar2 default null
  ,p_trb_information2               in     varchar2 default null
  ,p_trb_information3               in     varchar2 default null
  ,p_trb_information4               in     varchar2 default null
  ,p_trb_information5               in     varchar2 default null
  ,p_trb_information6               in     varchar2 default null
  ,p_trb_information7               in     varchar2 default null
  ,p_trb_information8               in     varchar2 default null
  ,p_trb_information9               in     varchar2 default null
  ,p_trb_information10              in     varchar2 default null
  ,p_trb_information11              in     varchar2 default null
  ,p_trb_information12              in     varchar2 default null
  ,p_trb_information13              in     varchar2 default null
  ,p_trb_information14              in     varchar2 default null
  ,p_trb_information15              in     varchar2 default null
  ,p_trb_information16              in     varchar2 default null
  ,p_trb_information17              in     varchar2 default null
  ,p_trb_information18              in     varchar2 default null
  ,p_trb_information19              in     varchar2 default null
  ,p_trb_information20              in     varchar2 default null
  ,p_display_to_learner_flag      in     varchar2  default null
  ,p_book_entire_period_flag    in     varchar2  default null
--  ,p_unbook_request_flag    in     varchar2  default null
  ,p_chat_id                        in     number   default null
  ,p_forum_id                       in     number   default null
  ,p_resource_booking_id               out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_timezone_code                  IN VARCHAR2 DEFAULT NULL
  ) is
--
  l_rec   ota_trb_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_trb_shd.convert_args
    (null
    ,p_supplied_resource_id
    ,p_event_id
    ,p_date_booking_placed
    ,null
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
  -- Having converted the arguments into the ota_trb_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ota_trb_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_resource_booking_id := l_rec.resource_booking_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_trb_ins;

/
