--------------------------------------------------------
--  DDL for Package Body OTA_TDB_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_DEL" as
/* $Header: ottdb01t.pkb 120.26.12010000.3 2009/10/12 06:51:15 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_tdb_del.';  -- Global package name
g_event_id number;  -- Use to save event_id before deleting enrollment.
--Added for Bug#4106893
g_person_id number;
g_contact_id number;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of this
--   procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in ota_tdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ota_tdb_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ota_delegate_bookings row.
  --
  delete from ota_delegate_bookings
  where booking_id = p_rec.booking_id;
  --
  ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tdb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tdb_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ota_tdb_shd.g_rec_type) is
--
  cursor c_get_event_id is
  select event_id, delegate_person_id, delegate_contact_id
  from ota_delegate_bookings
  where booking_id = p_rec.booking_id;

  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  --
  -- Get the event id before deleting, in case the event status needs to
  -- be reset at a later stage.
  --
  --Modified for Bug#4106893
  open c_get_event_id;
  fetch c_get_event_id into g_event_id, g_person_id, g_contact_id;
  close c_get_event_id;

  --
  -- Bug 663791. This code moved from post_delete procedure to here.
  -- Delete all status history records for the deleted booking
  --
  delete from ota_booking_status_histories
  where booking_id = p_rec.booking_id;
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
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in ota_tdb_shd.g_rec_type) is
--
  cursor c_get_forum_id is
  select fns.forum_id,fns.object_version_number
  from ota_frm_obj_inclusions foi,ota_frm_notif_subscribers fns
  where foi.object_id = g_event_id
  and foi.object_Type = 'E'
  and foi.forum_id = fns.forum_id
  and (fns.person_id = g_person_id or fns.contact_id = g_contact_id);
  l_event_rec    ota_evt_shd.g_rec_type;
  l_event_exists boolean;
  l_proc         varchar2(72) := g_package||'post_delete';

  --Added for Bug#4106893
  l_lp_enrollment_ids varchar2(4000);
  --for cert members
  l_cert_prd_enrollment_ids varchar2(4000);
  v_forum_id number;
  v_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  ota_evt_shd.get_event_details(g_event_id,
                                l_event_rec,
                                l_event_exists);

  if l_event_exists then
  --
    --
    -- Reset Event Status
    --

    ota_evt_bus2.reset_event_status(g_event_id
                                   ,l_event_rec.object_version_number
                                   ,l_event_rec.event_status
                                   ,l_event_rec.maximum_attendees);
  --
  end if;

  --
  --Added for Bug#4106893
  IF g_person_id IS NOT NULL THEN
        ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => g_event_id,
                                                                 p_person_id         => g_person_id,
                                                                 p_contact_id        => null,
                                                                 p_lp_enrollment_ids => l_lp_enrollment_ids);
        --if the enrollment is deleted then check any associated cert enrollments that get effected
        ota_cme_util.update_cme_status(p_event_id          => g_event_id,
                                                                 p_person_id         => g_person_id,
                                                                 p_contact_id        => null,
                                                                 p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);
  ELSIF g_contact_id IS NOT NULL THEN
        ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => g_event_id,
                                                               p_person_id         => null,
                                                               p_contact_id        => g_contact_id,
                                                               p_lp_enrollment_ids => l_lp_enrollment_ids);
        --if the enrollment is deleted then check any associated cert enrollments that get effected
        ota_cme_util.update_cme_status(p_event_id          => g_event_id,
                                                                 p_person_id         => null,
                                                                 p_contact_id        => g_contact_id,
                                                                 p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);
  END IF;
 --Delete the forum notification record for this class,for this user
   OPEN c_get_forum_id;
   FETCH c_get_forum_id into v_forum_id, v_object_version_number;

   LOOP
   Exit When c_get_forum_id%notfound OR c_get_forum_id%notfound is null;

   ota_fns_del.del
     (
     p_forum_id      => v_forum_id
     ,p_person_id    => g_person_id
     ,p_contact_id   => g_contact_id
     ,p_object_version_number    => v_object_version_number
  );

   FETCH c_get_forum_id into v_forum_id, v_object_version_number;
   End Loop;
  Close c_get_forum_id;



  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec       in ota_tdb_shd.g_rec_type,
  p_validate  in boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
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
    SAVEPOINT del_ota_tdb;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  ota_tdb_shd.lck
        (
        p_rec.booking_id,
        p_rec.object_version_number
        );
  --
  -- Call the supporting delete validate operation
  --
  ota_tdb_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
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
    ROLLBACK TO del_ota_tdb;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_booking_id                         in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  ) is
--
  l_rec   ota_tdb_shd.g_rec_type;
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
  l_rec.booking_id:= p_booking_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ota_tdb_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ota_tdb_del;

/
