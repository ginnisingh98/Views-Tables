--------------------------------------------------------
--  DDL for Package Body PER_ABS_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABS_DEL" as
/* $Header: peabsrhi.pkb 120.17.12010000.9 2010/03/23 06:49:45 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abs_del.';  -- Global package name
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
  (p_rec in per_abs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_abs_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_absence_attendances row.
  --
  delete from per_absence_attendances
  where absence_attendance_id = p_rec.absence_attendance_id;
  --
  per_abs_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_abs_shd.g_api_dml := false;   -- Unset the api dml status
    per_abs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_abs_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in per_abs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
Procedure post_delete(p_rec in per_abs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    per_abs_rkd.after_delete
      (p_absence_attendance_id
      => p_rec.absence_attendance_id
      ,p_business_group_id_o
      => per_abs_shd.g_old_rec.business_group_id
      ,p_absence_attendance_type_id_o
      => per_abs_shd.g_old_rec.absence_attendance_type_id
      ,p_abs_attendance_reason_id_o
      => per_abs_shd.g_old_rec.abs_attendance_reason_id
      ,p_person_id_o
      => per_abs_shd.g_old_rec.person_id
      ,p_authorising_person_id_o
      => per_abs_shd.g_old_rec.authorising_person_id
      ,p_replacement_person_id_o
      => per_abs_shd.g_old_rec.replacement_person_id
      ,p_period_of_incapacity_id_o
      => per_abs_shd.g_old_rec.period_of_incapacity_id
      ,p_absence_days_o
      => per_abs_shd.g_old_rec.absence_days
      ,p_absence_hours_o
      => per_abs_shd.g_old_rec.absence_hours
      ,p_comments_o
      => per_abs_shd.g_old_rec.comments
      ,p_date_end_o
      => per_abs_shd.g_old_rec.date_end
      ,p_date_notification_o
      => per_abs_shd.g_old_rec.date_notification
      ,p_date_projected_end_o
      => per_abs_shd.g_old_rec.date_projected_end
      ,p_date_projected_start_o
      => per_abs_shd.g_old_rec.date_projected_start
      ,p_date_start_o
      => per_abs_shd.g_old_rec.date_start
      ,p_occurrence_o
      => per_abs_shd.g_old_rec.occurrence
      ,p_ssp1_issued_o
      => per_abs_shd.g_old_rec.ssp1_issued
      ,p_time_end_o
      => per_abs_shd.g_old_rec.time_end
      ,p_time_projected_end_o
      => per_abs_shd.g_old_rec.time_projected_end
      ,p_time_projected_start_o
      => per_abs_shd.g_old_rec.time_projected_start
      ,p_time_start_o
      => per_abs_shd.g_old_rec.time_start
      ,p_request_id_o
      => per_abs_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_abs_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_abs_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_abs_shd.g_old_rec.program_update_date
      ,p_attribute_category_o
      => per_abs_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_abs_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_abs_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_abs_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_abs_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_abs_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_abs_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_abs_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_abs_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_abs_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_abs_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_abs_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_abs_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_abs_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_abs_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_abs_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_abs_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_abs_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_abs_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_abs_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_abs_shd.g_old_rec.attribute20
      ,p_maternity_id_o
      => per_abs_shd.g_old_rec.maternity_id
      ,p_sickness_start_date_o
      => per_abs_shd.g_old_rec.sickness_start_date
      ,p_sickness_end_date_o
      => per_abs_shd.g_old_rec.sickness_end_date
      ,p_pregnancy_related_illness_o
      => per_abs_shd.g_old_rec.pregnancy_related_illness
      ,p_reason_for_notification_de_o
      => per_abs_shd.g_old_rec.reason_for_notification_delay
      ,p_accept_late_notification_f_o
      => per_abs_shd.g_old_rec.accept_late_notification_flag
      ,p_linked_absence_id_o
      => per_abs_shd.g_old_rec.linked_absence_id
      ,p_abs_information_category_o
      => per_abs_shd.g_old_rec.abs_information_category
      ,p_abs_information1_o
      => per_abs_shd.g_old_rec.abs_information1
      ,p_abs_information2_o
      => per_abs_shd.g_old_rec.abs_information2
      ,p_abs_information3_o
      => per_abs_shd.g_old_rec.abs_information3
      ,p_abs_information4_o
      => per_abs_shd.g_old_rec.abs_information4
      ,p_abs_information5_o
      => per_abs_shd.g_old_rec.abs_information5
      ,p_abs_information6_o
      => per_abs_shd.g_old_rec.abs_information6
      ,p_abs_information7_o
      => per_abs_shd.g_old_rec.abs_information7
      ,p_abs_information8_o
      => per_abs_shd.g_old_rec.abs_information8
      ,p_abs_information9_o
      => per_abs_shd.g_old_rec.abs_information9
      ,p_abs_information10_o
      => per_abs_shd.g_old_rec.abs_information10
      ,p_abs_information11_o
      => per_abs_shd.g_old_rec.abs_information11
      ,p_abs_information12_o
      => per_abs_shd.g_old_rec.abs_information12
      ,p_abs_information13_o
      => per_abs_shd.g_old_rec.abs_information13
      ,p_abs_information14_o
      => per_abs_shd.g_old_rec.abs_information14
      ,p_abs_information15_o
      => per_abs_shd.g_old_rec.abs_information15
      ,p_abs_information16_o
      => per_abs_shd.g_old_rec.abs_information16
      ,p_abs_information17_o
      => per_abs_shd.g_old_rec.abs_information17
      ,p_abs_information18_o
      => per_abs_shd.g_old_rec.abs_information18
      ,p_abs_information19_o
      => per_abs_shd.g_old_rec.abs_information19
      ,p_abs_information20_o
      => per_abs_shd.g_old_rec.abs_information20
      ,p_abs_information21_o
      => per_abs_shd.g_old_rec.abs_information21
      ,p_abs_information22_o
      => per_abs_shd.g_old_rec.abs_information22
      ,p_abs_information23_o
      => per_abs_shd.g_old_rec.abs_information23
      ,p_abs_information24_o
      => per_abs_shd.g_old_rec.abs_information24
      ,p_abs_information25_o
      => per_abs_shd.g_old_rec.abs_information25
      ,p_abs_information26_o
      => per_abs_shd.g_old_rec.abs_information26
      ,p_abs_information27_o
      => per_abs_shd.g_old_rec.abs_information27
      ,p_abs_information28_o
      => per_abs_shd.g_old_rec.abs_information28
      ,p_abs_information29_o
      => per_abs_shd.g_old_rec.abs_information29
      ,p_abs_information30_o
      => per_abs_shd.g_old_rec.abs_information30
      ,p_batch_id_o
      => per_abs_shd.g_old_rec.batch_id
      ,p_absence_case_id_o
      => per_abs_shd.g_old_rec.absence_case_id
      ,p_object_version_number_o
      => per_abs_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ABSENCE_ATTENDANCES'
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
  (p_rec          in per_abs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_abs_shd.lck
    (p_rec.absence_attendance_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_abs_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  per_abs_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_abs_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_abs_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_absence_attendance_id                in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_abs_shd.g_rec_type;
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
  l_rec.absence_attendance_id := p_absence_attendance_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_abs_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_abs_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_abs_del;

/
