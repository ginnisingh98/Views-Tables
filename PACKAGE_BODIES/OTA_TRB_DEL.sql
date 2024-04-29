--------------------------------------------------------
--  DDL for Package Body OTA_TRB_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRB_DEL" as
/* $Header: ottrbrhi.pkb 120.6.12000000.3 2007/07/05 09:22:53 aabalakr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_trb_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
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
Procedure delete_dml
  (p_rec in ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ota_trb_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ota_resource_bookings row.
  --
  delete from ota_resource_bookings
  where resource_booking_id = p_rec.resource_booking_id;
  --
  ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
    ota_trb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_trb_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ota_trb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if resource exists in allocations
  --
  ota_trb_api_procedures.check_tra_resource_exists(p_rec.resource_booking_id);
  --
  -- Check if trainer exists in allocations
  --
  ota_trb_api_procedures.check_tra_trainer_exists(p_rec.resource_booking_id);
  --
  -- check if finance lines exist.
  --
  ota_trb_api_procedures.check_if_tfl_exists(p_rec.resource_booking_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in ota_trb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_trb_rkd.after_delete
      (p_resource_booking_id
      => p_rec.resource_booking_id
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in ota_trb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ota_trb_shd.lck
    (p_rec.resource_booking_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ota_trb_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ota_trb_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ota_trb_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ota_trb_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_resource_booking_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ota_trb_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.resource_booking_id := p_resource_booking_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ota_trb_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ota_trb_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ota_trb_del;

/
