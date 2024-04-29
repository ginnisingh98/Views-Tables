--------------------------------------------------------
--  DDL for Package Body PER_ABS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABS_UPD" as
/* $Header: peabsrhi.pkb 120.17.12010000.9 2010/03/23 06:49:45 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abs_upd.';  -- Global package name
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
  (p_rec in out nocopy per_abs_shd.g_rec_type
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
  per_abs_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_absence_attendances Row
  --
  update per_absence_attendances
    set
     absence_attendance_id           = p_rec.absence_attendance_id
    ,business_group_id               = p_rec.business_group_id
    ,absence_attendance_type_id      = p_rec.absence_attendance_type_id
    ,abs_attendance_reason_id        = p_rec.abs_attendance_reason_id
    ,person_id                       = p_rec.person_id
    ,authorising_person_id           = p_rec.authorising_person_id
    ,replacement_person_id           = p_rec.replacement_person_id
    ,period_of_incapacity_id         = p_rec.period_of_incapacity_id
    ,absence_days                    = p_rec.absence_days
    ,absence_hours                   = p_rec.absence_hours
    ,comments                        = p_rec.comments
    ,date_end                        = p_rec.date_end
    ,date_notification               = p_rec.date_notification
    ,date_projected_end              = p_rec.date_projected_end
    ,date_projected_start            = p_rec.date_projected_start
    ,date_start                      = p_rec.date_start
    ,occurrence                      = p_rec.occurrence
    ,ssp1_issued                     = p_rec.ssp1_issued
    ,time_end                        = p_rec.time_end
    ,time_projected_end              = p_rec.time_projected_end
    ,time_projected_start            = p_rec.time_projected_start
    ,time_start                      = p_rec.time_start
    ,request_id                      = p_rec.request_id
    ,program_application_id          = p_rec.program_application_id
    ,program_id                      = p_rec.program_id
    ,program_update_date             = p_rec.program_update_date
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,maternity_id                    = p_rec.maternity_id
    ,sickness_start_date             = p_rec.sickness_start_date
    ,sickness_end_date               = p_rec.sickness_end_date
    ,pregnancy_related_illness       = p_rec.pregnancy_related_illness
    ,reason_for_notification_delay   = p_rec.reason_for_notification_delay
    ,accept_late_notification_flag   = p_rec.accept_late_notification_flag
    ,linked_absence_id               = p_rec.linked_absence_id
    ,abs_information_category        = p_rec.abs_information_category
    ,abs_information1                = p_rec.abs_information1
    ,abs_information2                = p_rec.abs_information2
    ,abs_information3                = p_rec.abs_information3
    ,abs_information4                = p_rec.abs_information4
    ,abs_information5                = p_rec.abs_information5
    ,abs_information6                = p_rec.abs_information6
    ,abs_information7                = p_rec.abs_information7
    ,abs_information8                = p_rec.abs_information8
    ,abs_information9                = p_rec.abs_information9
    ,abs_information10               = p_rec.abs_information10
    ,abs_information11               = p_rec.abs_information11
    ,abs_information12               = p_rec.abs_information12
    ,abs_information13               = p_rec.abs_information13
    ,abs_information14               = p_rec.abs_information14
    ,abs_information15               = p_rec.abs_information15
    ,abs_information16               = p_rec.abs_information16
    ,abs_information17               = p_rec.abs_information17
    ,abs_information18               = p_rec.abs_information18
    ,abs_information19               = p_rec.abs_information19
    ,abs_information20               = p_rec.abs_information20
    ,abs_information21               = p_rec.abs_information21
    ,abs_information22               = p_rec.abs_information22
    ,abs_information23               = p_rec.abs_information23
    ,abs_information24               = p_rec.abs_information24
    ,abs_information25               = p_rec.abs_information25
    ,abs_information26               = p_rec.abs_information26
    ,abs_information27               = p_rec.abs_information27
    ,abs_information28               = p_rec.abs_information28
    ,abs_information29               = p_rec.abs_information29
    ,abs_information30               = p_rec.abs_information30
    ,batch_id                        = p_rec.batch_id
    ,object_version_number           = p_rec.object_version_number
    ,absence_case_id                 = p_rec.absence_case_id
    where absence_attendance_id = p_rec.absence_attendance_id;
  --
  per_abs_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_abs_shd.g_api_dml := false;   -- Unset the api dml status
    per_abs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_abs_shd.g_api_dml := false;   -- Unset the api dml status
    per_abs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_abs_shd.g_api_dml := false;   -- Unset the api dml status
    per_abs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_abs_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec            in out nocopy per_abs_shd.g_rec_type
  ,p_effective_date in     date
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

/*
  per_abs_bus.chk_cal_duration
     (p_absence_attendance_id      => p_rec.absence_attendance_id
     ,p_absence_attendance_type_id => p_rec.absence_attendance_type_id
     ,p_object_version_number      => p_rec.object_version_number
     ,p_absence_days               => p_rec.absence_days
     ,p_absence_hours              => p_rec.absence_hours
     ,p_date_start                 => p_rec.date_start
     ,p_date_end                   => p_rec.date_end
     ,p_time_start                 => p_rec.time_start
     ,p_time_end                   => p_rec.time_end
     ,p_effective_date             => p_effective_date
     ,p_person_id                  => p_rec.person_id
     ,p_business_group_id          => p_rec.business_group_id
     ,p_entitlement_warning        => l_entitlement_warning
  );
  p_entitlement_warning := l_entitlement_warning;
  --
*/

  --
  -- Set the absence durations.  Note that the durations are set
  -- to global variables because the values may have been over-
  -- written by the system.
  --
  p_rec.absence_hours := per_abs_shd.g_absence_hours;
  p_rec.absence_days  := per_abs_shd.g_absence_days;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End pre_update;
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
  ,p_rec                          in per_abs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin

    per_abs_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_absence_attendance_id
      => p_rec.absence_attendance_id
      ,p_absence_attendance_type_id
      => p_rec.absence_attendance_type_id
      ,p_abs_attendance_reason_id
      => p_rec.abs_attendance_reason_id
      ,p_person_id
      => p_rec.person_id
      ,p_authorising_person_id
      => p_rec.authorising_person_id
      ,p_replacement_person_id
      => p_rec.replacement_person_id
      ,p_period_of_incapacity_id
      => p_rec.period_of_incapacity_id
      ,p_absence_days
      => p_rec.absence_days
      ,p_absence_hours
      => p_rec.absence_hours
      ,p_comments
      => p_rec.comments
      ,p_date_end
      => p_rec.date_end
      ,p_date_notification
      => p_rec.date_notification
      ,p_date_projected_end
      => p_rec.date_projected_end
      ,p_date_projected_start
      => p_rec.date_projected_start
      ,p_date_start
      => p_rec.date_start
      ,p_occurrence
      => p_rec.occurrence
      ,p_ssp1_issued
      => p_rec.ssp1_issued
      ,p_time_end
      => p_rec.time_end
      ,p_time_projected_end
      => p_rec.time_projected_end
      ,p_time_projected_start
      => p_rec.time_projected_start
      ,p_time_start
      => p_rec.time_start
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_maternity_id
      => p_rec.maternity_id
      ,p_sickness_start_date
      => p_rec.sickness_start_date
      ,p_sickness_end_date
      => p_rec.sickness_end_date
      ,p_pregnancy_related_illness
      => p_rec.pregnancy_related_illness
      ,p_reason_for_notification_dela
      => p_rec.reason_for_notification_delay
      ,p_accept_late_notification_fla
      => p_rec.accept_late_notification_flag
      ,p_linked_absence_id
      => p_rec.linked_absence_id
      ,p_abs_information_category
      => p_rec.abs_information_category
      ,p_abs_information1
      => p_rec.abs_information1
      ,p_abs_information2
      => p_rec.abs_information2
      ,p_abs_information3
      => p_rec.abs_information3
      ,p_abs_information4
      => p_rec.abs_information4
      ,p_abs_information5
      => p_rec.abs_information5
      ,p_abs_information6
      => p_rec.abs_information6
      ,p_abs_information7
      => p_rec.abs_information7
      ,p_abs_information8
      => p_rec.abs_information8
      ,p_abs_information9
      => p_rec.abs_information9
      ,p_abs_information10
      => p_rec.abs_information10
      ,p_abs_information11
      => p_rec.abs_information11
      ,p_abs_information12
      => p_rec.abs_information12
      ,p_abs_information13
      => p_rec.abs_information13
      ,p_abs_information14
      => p_rec.abs_information14
      ,p_abs_information15
      => p_rec.abs_information15
      ,p_abs_information16
      => p_rec.abs_information16
      ,p_abs_information17
      => p_rec.abs_information17
      ,p_abs_information18
      => p_rec.abs_information18
      ,p_abs_information19
      => p_rec.abs_information19
      ,p_abs_information20
      => p_rec.abs_information20
      ,p_abs_information21
      => p_rec.abs_information21
      ,p_abs_information22
      => p_rec.abs_information22
      ,p_abs_information23
      => p_rec.abs_information23
      ,p_abs_information24
      => p_rec.abs_information24
      ,p_abs_information25
      => p_rec.abs_information25
      ,p_abs_information26
      => p_rec.abs_information26
      ,p_abs_information27
      => p_rec.abs_information27
      ,p_abs_information28
      => p_rec.abs_information28
      ,p_abs_information29
      => p_rec.abs_information29
      ,p_abs_information30
      => p_rec.abs_information30
      ,p_absence_case_id
      => p_rec.absence_case_id
      ,p_batch_id
      => p_rec.batch_id
      ,p_object_version_number
      => p_rec.object_version_number
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
  (p_rec in out nocopy per_abs_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_abs_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.absence_attendance_type_id = hr_api.g_number) then
    p_rec.absence_attendance_type_id :=
    per_abs_shd.g_old_rec.absence_attendance_type_id;
  End If;
  If (p_rec.abs_attendance_reason_id = hr_api.g_number) then
    p_rec.abs_attendance_reason_id :=
    per_abs_shd.g_old_rec.abs_attendance_reason_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_abs_shd.g_old_rec.person_id;
  End If;
  If (p_rec.authorising_person_id = hr_api.g_number) then
    p_rec.authorising_person_id :=
    per_abs_shd.g_old_rec.authorising_person_id;
  End If;
  If (p_rec.replacement_person_id = hr_api.g_number) then
    p_rec.replacement_person_id :=
    per_abs_shd.g_old_rec.replacement_person_id;
  End If;
  If (p_rec.period_of_incapacity_id = hr_api.g_number) then
    p_rec.period_of_incapacity_id :=
    per_abs_shd.g_old_rec.period_of_incapacity_id;
  End If;
  If (p_rec.absence_days = hr_api.g_number) then
    p_rec.absence_days :=
    per_abs_shd.g_old_rec.absence_days;
  End If;
  If (p_rec.absence_hours = hr_api.g_number) then
    p_rec.absence_hours :=
    per_abs_shd.g_old_rec.absence_hours;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_abs_shd.g_old_rec.comments;
  End If;
  If (p_rec.date_end = hr_api.g_date) then
    p_rec.date_end :=
    per_abs_shd.g_old_rec.date_end;
  End If;
  If (p_rec.date_notification = hr_api.g_date) then
    p_rec.date_notification :=
    per_abs_shd.g_old_rec.date_notification;
  End If;
  If (p_rec.date_projected_end = hr_api.g_date) then
    p_rec.date_projected_end :=
    per_abs_shd.g_old_rec.date_projected_end;
  End If;
  If (p_rec.date_projected_start = hr_api.g_date) then
    p_rec.date_projected_start :=
    per_abs_shd.g_old_rec.date_projected_start;
  End If;
  If (p_rec.date_start = hr_api.g_date) then
    p_rec.date_start :=
    per_abs_shd.g_old_rec.date_start;
  End If;
  If (p_rec.occurrence = hr_api.g_number) then
    p_rec.occurrence :=
    per_abs_shd.g_old_rec.occurrence;
  End If;
  If (p_rec.ssp1_issued = hr_api.g_varchar2) then
    p_rec.ssp1_issued :=
    per_abs_shd.g_old_rec.ssp1_issued;
  End If;
  If (p_rec.time_end = hr_api.g_varchar2) then
    p_rec.time_end :=
    per_abs_shd.g_old_rec.time_end;
  End If;
  If (p_rec.time_projected_end = hr_api.g_varchar2) then
    p_rec.time_projected_end :=
    per_abs_shd.g_old_rec.time_projected_end;
  End If;
  If (p_rec.time_projected_start = hr_api.g_varchar2) then
    p_rec.time_projected_start :=
    per_abs_shd.g_old_rec.time_projected_start;
  End If;
  If (p_rec.time_start = hr_api.g_varchar2) then
    p_rec.time_start :=
    per_abs_shd.g_old_rec.time_start;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_abs_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_abs_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_abs_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_abs_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_abs_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_abs_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_abs_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_abs_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_abs_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_abs_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_abs_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_abs_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_abs_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_abs_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_abs_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_abs_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_abs_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_abs_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_abs_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_abs_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_abs_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_abs_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_abs_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_abs_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_abs_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.maternity_id = hr_api.g_number) then
    p_rec.maternity_id :=
    per_abs_shd.g_old_rec.maternity_id;
  End If;
  If (p_rec.sickness_start_date = hr_api.g_date) then
    p_rec.sickness_start_date :=
    per_abs_shd.g_old_rec.sickness_start_date;
  End If;
  If (p_rec.sickness_end_date = hr_api.g_date) then
    p_rec.sickness_end_date :=
    per_abs_shd.g_old_rec.sickness_end_date;
  End If;
  If (p_rec.pregnancy_related_illness = hr_api.g_varchar2) then
    p_rec.pregnancy_related_illness :=
    per_abs_shd.g_old_rec.pregnancy_related_illness;
  End If;
  If (p_rec.reason_for_notification_delay = hr_api.g_varchar2) then
    p_rec.reason_for_notification_delay :=
    per_abs_shd.g_old_rec.reason_for_notification_delay;
  End If;
  If (p_rec.accept_late_notification_flag = hr_api.g_varchar2) then
    p_rec.accept_late_notification_flag :=
    per_abs_shd.g_old_rec.accept_late_notification_flag;
  End If;
  If (p_rec.linked_absence_id = hr_api.g_number) then
    p_rec.linked_absence_id :=
    per_abs_shd.g_old_rec.linked_absence_id;
  End If;
  If (p_rec.abs_information_category = hr_api.g_varchar2) then
    p_rec.abs_information_category :=
    per_abs_shd.g_old_rec.abs_information_category;
  End If;
  If (p_rec.abs_information1 = hr_api.g_varchar2) then
    p_rec.abs_information1 :=
    per_abs_shd.g_old_rec.abs_information1;
  End If;
  If (p_rec.abs_information2 = hr_api.g_varchar2) then
    p_rec.abs_information2 :=
    per_abs_shd.g_old_rec.abs_information2;
  End If;
  If (p_rec.abs_information3 = hr_api.g_varchar2) then
    p_rec.abs_information3 :=
    per_abs_shd.g_old_rec.abs_information3;
  End If;
  If (p_rec.abs_information4 = hr_api.g_varchar2) then
    p_rec.abs_information4 :=
    per_abs_shd.g_old_rec.abs_information4;
  End If;
  If (p_rec.abs_information5 = hr_api.g_varchar2) then
    p_rec.abs_information5 :=
    per_abs_shd.g_old_rec.abs_information5;
  End If;
  If (p_rec.abs_information6 = hr_api.g_varchar2) then
    p_rec.abs_information6 :=
    per_abs_shd.g_old_rec.abs_information6;
  End If;
  If (p_rec.abs_information7 = hr_api.g_varchar2) then
    p_rec.abs_information7 :=
    per_abs_shd.g_old_rec.abs_information7;
  End If;
  If (p_rec.abs_information8 = hr_api.g_varchar2) then
    p_rec.abs_information8 :=
    per_abs_shd.g_old_rec.abs_information8;
  End If;
  If (p_rec.abs_information9 = hr_api.g_varchar2) then
    p_rec.abs_information9 :=
    per_abs_shd.g_old_rec.abs_information9;
  End If;
  If (p_rec.abs_information10 = hr_api.g_varchar2) then
    p_rec.abs_information10 :=
    per_abs_shd.g_old_rec.abs_information10;
  End If;
  If (p_rec.abs_information11 = hr_api.g_varchar2) then
    p_rec.abs_information11 :=
    per_abs_shd.g_old_rec.abs_information11;
  End If;
  If (p_rec.abs_information12 = hr_api.g_varchar2) then
    p_rec.abs_information12 :=
    per_abs_shd.g_old_rec.abs_information12;
  End If;
  If (p_rec.abs_information13 = hr_api.g_varchar2) then
    p_rec.abs_information13 :=
    per_abs_shd.g_old_rec.abs_information13;
  End If;
  If (p_rec.abs_information14 = hr_api.g_varchar2) then
    p_rec.abs_information14 :=
    per_abs_shd.g_old_rec.abs_information14;
  End If;
  If (p_rec.abs_information15 = hr_api.g_varchar2) then
    p_rec.abs_information15 :=
    per_abs_shd.g_old_rec.abs_information15;
  End If;
  If (p_rec.abs_information16 = hr_api.g_varchar2) then
    p_rec.abs_information16 :=
    per_abs_shd.g_old_rec.abs_information16;
  End If;
  If (p_rec.abs_information17 = hr_api.g_varchar2) then
    p_rec.abs_information17 :=
    per_abs_shd.g_old_rec.abs_information17;
  End If;
  If (p_rec.abs_information18 = hr_api.g_varchar2) then
    p_rec.abs_information18 :=
    per_abs_shd.g_old_rec.abs_information18;
  End If;
  If (p_rec.abs_information19 = hr_api.g_varchar2) then
    p_rec.abs_information19 :=
    per_abs_shd.g_old_rec.abs_information19;
  End If;
  If (p_rec.abs_information20 = hr_api.g_varchar2) then
    p_rec.abs_information20 :=
    per_abs_shd.g_old_rec.abs_information20;
  End If;
  If (p_rec.abs_information21 = hr_api.g_varchar2) then
    p_rec.abs_information21 :=
    per_abs_shd.g_old_rec.abs_information21;
  End If;
  If (p_rec.abs_information22 = hr_api.g_varchar2) then
    p_rec.abs_information22 :=
    per_abs_shd.g_old_rec.abs_information22;
  End If;
  If (p_rec.abs_information23 = hr_api.g_varchar2) then
    p_rec.abs_information23 :=
    per_abs_shd.g_old_rec.abs_information23;
  End If;
  If (p_rec.abs_information24 = hr_api.g_varchar2) then
    p_rec.abs_information24 :=
    per_abs_shd.g_old_rec.abs_information24;
  End If;
  If (p_rec.abs_information25 = hr_api.g_varchar2) then
    p_rec.abs_information25 :=
    per_abs_shd.g_old_rec.abs_information25;
  End If;
  If (p_rec.abs_information26 = hr_api.g_varchar2) then
    p_rec.abs_information26 :=
    per_abs_shd.g_old_rec.abs_information26;
  End If;
  If (p_rec.abs_information27 = hr_api.g_varchar2) then
    p_rec.abs_information27 :=
    per_abs_shd.g_old_rec.abs_information27;
  End If;
  If (p_rec.abs_information28 = hr_api.g_varchar2) then
    p_rec.abs_information28 :=
    per_abs_shd.g_old_rec.abs_information28;
  End If;
  If (p_rec.abs_information29 = hr_api.g_varchar2) then
    p_rec.abs_information29 :=
    per_abs_shd.g_old_rec.abs_information29;
  End If;
  If (p_rec.abs_information30 = hr_api.g_varchar2) then
    p_rec.abs_information30 :=
    per_abs_shd.g_old_rec.abs_information30;
  End If;
  If (p_rec.absence_case_id = hr_api.g_number) then
    p_rec.absence_case_id :=
    per_abs_shd.g_old_rec.absence_case_id;
  End If;
  If (p_rec.batch_id = hr_api.g_number) then
    p_rec.batch_id :=
    per_abs_shd.g_old_rec.batch_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_rec                          in out nocopy per_abs_shd.g_rec_type
  ,p_dur_dys_less_warning         out nocopy    boolean
  ,p_dur_hrs_less_warning         out nocopy    boolean
  ,p_exceeds_pto_entit_warning    out nocopy    boolean
  ,p_exceeds_run_total_warning    out nocopy    boolean
  ,p_abs_overlap_warning          out nocopy    boolean
  ,p_abs_day_after_warning        out nocopy    boolean
  ,p_dur_overwritten_warning      out nocopy    boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_abs_shd.lck
    (p_rec.absence_attendance_id
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

  per_abs_bus.update_validate
     (p_effective_date            => p_effective_date
     ,p_rec                       => p_rec
     ,p_dur_dys_less_warning      => p_dur_dys_less_warning
     ,p_dur_hrs_less_warning      => p_dur_hrs_less_warning
     ,p_exceeds_pto_entit_warning => p_exceeds_pto_entit_warning
     ,p_exceeds_run_total_warning => p_exceeds_run_total_warning
     ,p_abs_overlap_warning       => p_abs_overlap_warning
     ,p_abs_day_after_warning     => p_abs_day_after_warning
     ,p_dur_overwritten_warning   => p_dur_overwritten_warning
     );

  --
  -- Call the supporting pre-update operation
  --
  per_abs_upd.pre_update(p_rec, p_effective_date);
  --
  -- Update the row.
  --
  per_abs_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_abs_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_absence_attendance_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_abs_attendance_reason_id     in     number    default hr_api.g_number
  ,p_authorising_person_id        in     number    default hr_api.g_number
  ,p_replacement_person_id        in     number    default hr_api.g_number
  ,p_period_of_incapacity_id      in     number    default hr_api.g_number
  ,p_absence_days                 in out nocopy number
  ,p_absence_hours                in out nocopy number
  --start changes for bug 5987410
  --,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     long  default NULL
  --end changes for bug 5987410
	,p_date_notification            in     date      default hr_api.g_date
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_date_projected_start         in     date      default hr_api.g_date
  ,p_date_projected_end           in     date      default hr_api.g_date
  ,p_time_start                   in     varchar2  default hr_api.g_varchar2
  ,p_time_end                     in     varchar2  default hr_api.g_varchar2
  ,p_time_projected_start         in     varchar2  default hr_api.g_varchar2
  ,p_time_projected_end           in     varchar2  default hr_api.g_varchar2
  ,p_occurrence                   in     number    default hr_api.g_number
  ,p_ssp1_issued                  in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_maternity_id                 in     number    default hr_api.g_number
  ,p_sickness_start_date          in     date      default hr_api.g_date
  ,p_sickness_end_date            in     date      default hr_api.g_date
  ,p_pregnancy_related_illness    in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_notification_dela in     varchar2  default hr_api.g_varchar2
  ,p_accept_late_notification_fla in     varchar2  default hr_api.g_varchar2
  ,p_linked_absence_id            in     number    default hr_api.g_number
  ,p_abs_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_abs_information1             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information2             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information3             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information4             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information5             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information6             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information7             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information8             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information9             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information10            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information11            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information12            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information13            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information14            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information15            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information16            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information17            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information18            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information19            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information20            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information21            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information22            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information23            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information24            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information25            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information26            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information27            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information28            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information29            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information30            in     varchar2  default hr_api.g_varchar2
  ,p_batch_id                     in     number    default hr_api.g_number
  ,p_absence_case_id              in     number    default hr_api.g_number
  ,p_dur_dys_less_warning         out nocopy    boolean
  ,p_dur_hrs_less_warning         out nocopy    boolean
  ,p_exceeds_pto_entit_warning    out nocopy    boolean
  ,p_exceeds_run_total_warning    out nocopy    boolean
  ,p_abs_overlap_warning          out nocopy    boolean
  ,p_abs_day_after_warning        out nocopy    boolean
  ,p_dur_overwritten_warning      out nocopy    boolean
  ) is
--
  l_person_id                    number := hr_api.g_number;
  l_absence_attendance_type_id   number := hr_api.g_number;
  l_business_group_id            number := hr_api.g_number;
  l_rec                          per_abs_shd.g_rec_type;
  l_proc                         varchar2(72) := g_package||'upd';
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_abs_shd.convert_args
  (p_absence_attendance_id
  ,l_business_group_id
  ,l_absence_attendance_type_id
  ,p_abs_attendance_reason_id
  ,l_person_id
  ,p_authorising_person_id
  ,p_replacement_person_id
  ,p_period_of_incapacity_id
  ,p_absence_days
  ,p_absence_hours
  ,p_comments
  ,p_date_end
  ,p_date_notification
  ,p_date_projected_end
  ,p_date_projected_start
  ,p_date_start
  ,hr_api.g_number   -- p_occurrence
  ,p_ssp1_issued
  ,p_time_end
  ,p_time_projected_end
  ,p_time_projected_start
  ,p_time_start
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_program_update_date
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_maternity_id
  ,p_sickness_start_date
  ,p_sickness_end_date
  ,p_pregnancy_related_illness
  ,p_reason_for_notification_dela
  ,p_accept_late_notification_fla
  ,p_linked_absence_id
  ,p_abs_information_category
  ,p_abs_information1
  ,p_abs_information2
  ,p_abs_information3
  ,p_abs_information4
  ,p_abs_information5
  ,p_abs_information6
  ,p_abs_information7
  ,p_abs_information8
  ,p_abs_information9
  ,p_abs_information10
  ,p_abs_information11
  ,p_abs_information12
  ,p_abs_information13
  ,p_abs_information14
  ,p_abs_information15
  ,p_abs_information16
  ,p_abs_information17
  ,p_abs_information18
  ,p_abs_information19
  ,p_abs_information20
  ,p_abs_information21
  ,p_abs_information22
  ,p_abs_information23
  ,p_abs_information24
  ,p_abs_information25
  ,p_abs_information26
  ,p_abs_information27
  ,p_abs_information28
  ,p_abs_information29
  ,p_abs_information30
  ,p_absence_case_id
  ,p_batch_id
  ,p_object_version_number
  );
  hr_utility.set_location(l_proc, 6);
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_abs_upd.upd
     (p_effective_date            => p_effective_date
     ,p_rec                       => l_rec
     ,p_dur_dys_less_warning      => p_dur_dys_less_warning
     ,p_dur_hrs_less_warning      => p_dur_hrs_less_warning
     ,p_exceeds_pto_entit_warning => p_exceeds_pto_entit_warning
     ,p_exceeds_run_total_warning => p_exceeds_run_total_warning
     ,p_abs_overlap_warning       => p_abs_overlap_warning
     ,p_abs_day_after_warning     => p_abs_day_after_warning
     ,p_dur_overwritten_warning   => p_dur_overwritten_warning
     );

  p_object_version_number := l_rec.object_version_number;
  p_absence_days          := l_rec.absence_days;
  p_absence_hours         := l_rec.absence_hours;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

End upd;
--
end per_abs_upd;

/
