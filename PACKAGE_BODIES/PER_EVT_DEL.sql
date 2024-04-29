--------------------------------------------------------
--  DDL for Package Body PER_EVT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EVT_DEL" as
/* $Header: peevtrhi.pkb 120.2 2008/04/30 11:32:10 uuddavol ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_evt_del.';  -- Global package name
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
  (p_rec in per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_evt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_events row.
  --
  delete from per_events
  where event_id = p_rec.event_id;
  --
  per_evt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_evt_shd.g_api_dml := false;   -- Unset the api dml status
    per_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_evt_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in per_evt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
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
Procedure post_delete(p_rec in per_evt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
    begin
    --
    per_evt_rkd.after_delete
      (p_event_id
      => p_rec.event_id
      ,p_business_group_id_o
      => per_evt_shd.g_old_rec.business_group_id
      ,p_location_id_o
      => per_evt_shd.g_old_rec.location_id
      ,p_internal_contact_person_id_o
      => per_evt_shd.g_old_rec.internal_contact_person_id
      ,p_organization_run_by_id_o
      => per_evt_shd.g_old_rec.organization_run_by_id
      ,p_assignment_id_o
      => per_evt_shd.g_old_rec.assignment_id
      ,p_date_start_o
      => per_evt_shd.g_old_rec.date_start
      ,p_type_o
      => per_evt_shd.g_old_rec.type
      ,p_comments_o
      => per_evt_shd.g_old_rec.comments
      ,p_contact_telephone_number_o
      => per_evt_shd.g_old_rec.contact_telephone_number
      ,p_date_end_o
      => per_evt_shd.g_old_rec.date_end
      ,p_emp_or_apl_o
      => per_evt_shd.g_old_rec.emp_or_apl
      ,p_event_or_interview_o
      => per_evt_shd.g_old_rec.event_or_interview
      ,p_external_contact_o
      => per_evt_shd.g_old_rec.external_contact
      ,p_time_end_o
      => per_evt_shd.g_old_rec.time_end
      ,p_time_start_o
      => per_evt_shd.g_old_rec.time_start
      ,p_request_id_o
      => per_evt_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_evt_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_evt_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_evt_shd.g_old_rec.program_update_date
      ,p_attribute_category_o
      => per_evt_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_evt_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_evt_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_evt_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_evt_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_evt_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_evt_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_evt_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_evt_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_evt_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_evt_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_evt_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_evt_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_evt_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_evt_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_evt_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_evt_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_evt_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_evt_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_evt_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_evt_shd.g_old_rec.attribute20
      ,p_party_id_o
      => per_evt_shd.g_old_rec.party_id
      ,p_object_version_number_o
      => per_evt_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_EVENTS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- We must lock the row which we need to delete.
  --
  per_evt_shd.lck
    (p_rec.event_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_evt_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  per_evt_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_evt_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_evt_del.post_delete(p_rec);
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_event_id                             in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_evt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.event_id := p_event_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_evt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_evt_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End del;
--
end per_evt_del;

/
