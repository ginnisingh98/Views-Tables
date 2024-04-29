--------------------------------------------------------
--  DDL for Package Body PER_ABS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABS_INS" as
/* $Header: peabsrhi.pkb 120.17.12010000.9 2010/03/23 06:49:45 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abs_ins.';  -- Global package name

-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_absence_attendance_id_i number default null;

procedure set_base_key_value
  (p_absence_attendance_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_abs_ins.g_absence_attendance_id_i := p_absence_attendance_id;
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
  (p_rec in out nocopy per_abs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_abs_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_absence_attendances
  --
  insert into per_absence_attendances
      (absence_attendance_id
      ,business_group_id
      ,absence_attendance_type_id
      ,abs_attendance_reason_id
      ,person_id
      ,authorising_person_id
      ,replacement_person_id
      ,period_of_incapacity_id
      ,absence_days
      ,absence_hours
      ,comments
      ,date_end
      ,date_notification
      ,date_projected_end
      ,date_projected_start
      ,date_start
      ,occurrence
      ,ssp1_issued
      ,time_end
      ,time_projected_end
      ,time_projected_start
      ,time_start
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,maternity_id
      ,sickness_start_date
      ,sickness_end_date
      ,pregnancy_related_illness
      ,reason_for_notification_delay
      ,accept_late_notification_flag
      ,linked_absence_id
      ,abs_information_category
      ,abs_information1
      ,abs_information2
      ,abs_information3
      ,abs_information4
      ,abs_information5
      ,abs_information6
      ,abs_information7
      ,abs_information8
      ,abs_information9
      ,abs_information10
      ,abs_information11
      ,abs_information12
      ,abs_information13
      ,abs_information14
      ,abs_information15
      ,abs_information16
      ,abs_information17
      ,abs_information18
      ,abs_information19
      ,abs_information20
      ,abs_information21
      ,abs_information22
      ,abs_information23
      ,abs_information24
      ,abs_information25
      ,abs_information26
      ,abs_information27
      ,abs_information28
      ,abs_information29
      ,abs_information30
      ,batch_id
      ,object_version_number
      ,absence_case_id
      )
  Values
    (p_rec.absence_attendance_id
    ,p_rec.business_group_id
    ,p_rec.absence_attendance_type_id
    ,p_rec.abs_attendance_reason_id
    ,p_rec.person_id
    ,p_rec.authorising_person_id
    ,p_rec.replacement_person_id
    ,p_rec.period_of_incapacity_id
    ,p_rec.absence_days
    ,p_rec.absence_hours
    ,p_rec.comments
    ,p_rec.date_end
    ,p_rec.date_notification
    ,p_rec.date_projected_end
    ,p_rec.date_projected_start
    ,p_rec.date_start
    ,p_rec.occurrence
    ,p_rec.ssp1_issued
    ,p_rec.time_end
    ,p_rec.time_projected_end
    ,p_rec.time_projected_start
    ,p_rec.time_start
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.maternity_id
    ,p_rec.sickness_start_date
    ,p_rec.sickness_end_date
    ,p_rec.pregnancy_related_illness
    ,p_rec.reason_for_notification_delay
    ,p_rec.accept_late_notification_flag
    ,p_rec.linked_absence_id
    ,p_rec.abs_information_category
    ,p_rec.abs_information1
    ,p_rec.abs_information2
    ,p_rec.abs_information3
    ,p_rec.abs_information4
    ,p_rec.abs_information5
    ,p_rec.abs_information6
    ,p_rec.abs_information7
    ,p_rec.abs_information8
    ,p_rec.abs_information9
    ,p_rec.abs_information10
    ,p_rec.abs_information11
    ,p_rec.abs_information12
    ,p_rec.abs_information13
    ,p_rec.abs_information14
    ,p_rec.abs_information15
    ,p_rec.abs_information16
    ,p_rec.abs_information17
    ,p_rec.abs_information18
    ,p_rec.abs_information19
    ,p_rec.abs_information20
    ,p_rec.abs_information21
    ,p_rec.abs_information22
    ,p_rec.abs_information23
    ,p_rec.abs_information24
    ,p_rec.abs_information25
    ,p_rec.abs_information26
    ,p_rec.abs_information27
    ,p_rec.abs_information28
    ,p_rec.abs_information29
    ,p_rec.abs_information30
    ,p_rec.batch_id
    ,p_rec.object_version_number
    ,p_rec.absence_case_id
    );
  --
  per_abs_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec                 in out nocopy per_abs_shd.g_rec_type
  ,p_effective_date      in date
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
  l_occurrence number;
  l_exists varchar2(1);
--
  Cursor C_Sel1 is select per_absence_attendances_s.nextval from sys.dual;

  Cursor C_Sel2 is
         select null
                from per_absence_attendances
                where absence_attendance_id = per_abs_ins.g_absence_attendance_id_i;


  Cursor c_get_occurrence is
  select nvl(max(abs.occurrence), 0) + 1
  from   per_absence_attendances abs
  where  abs.business_group_id = p_rec.business_group_id
  and    abs.absence_attendance_type_id = p_rec.absence_attendance_type_id
  and    abs.person_id = p_rec.person_id;

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
*/

  hr_utility.set_location(l_proc, 10);

 -- nachuri changes for using base key passed from bc4j
    If per_abs_ins.g_absence_attendance_id_i is not null then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found then
      Close C_Sel2;
      --
      -- The primary key values are already in use.
      --
      fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
      fnd_message.set_token('TABLE_NAME','PER_ABSENCE_ATTENDANCES');
      fnd_message.raise_error;
    end if;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.absence_attendance_id := per_abs_ins.g_absence_attendance_id_i;
    per_abs_ins.g_absence_attendance_id_i := null;
    --
  else
    --
    --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.absence_attendance_id;
  Close C_Sel1;
  --
  End If;


  hr_utility.set_location(l_proc, 20);

  --
  -- Fetch the next occurrence number
  --
  open  c_get_occurrence;
  fetch c_get_occurrence into l_occurrence;
  close c_get_occurrence;

  --
  -- Set the values that are system derived (note that absence days
  -- and hours may not necessarily be system derived, but are set
  -- to global variables regardless).
  --
  p_rec.occurrence    := l_occurrence;
  p_rec.absence_hours := per_abs_shd.g_absence_hours;
  p_rec.absence_days  := per_abs_shd.g_absence_days;


  hr_utility.set_location(' Leaving:'||l_proc, 50);

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
  ,p_rec                          in per_abs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    hr_utility.set_location(l_proc, 10);

    per_abs_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_absence_attendance_id
      => p_rec.absence_attendance_id
      ,p_business_group_id
      => p_rec.business_group_id
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ABSENCE_ATTENDANCES'
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
  l_proc  varchar2(72) := g_package||'ins';
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_abs_bus.insert_validate
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
  -- Call the supporting pre_insert operation
  --
  per_abs_ins.pre_insert(p_rec, p_effective_date);
  --
  -- Insert the row
  --
  per_abs_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_abs_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);

end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_absence_attendance_type_id     in     number
  ,p_person_id                      in     number
  ,p_abs_attendance_reason_id       in     number   default null
  ,p_authorising_person_id          in     number   default null
  ,p_replacement_person_id          in     number   default null
  ,p_period_of_incapacity_id        in     number   default null
  ,p_absence_days                   in out nocopy number
  ,p_absence_hours                  in out nocopy number
  --start changes for bug 5987410
  --,p_comments                       in     varchar2 default null
  ,p_comments                       in     long default null
  --end changes for bug 5987410
  ,p_date_end                       in     date     default null
  ,p_date_notification              in     date     default null
  ,p_date_projected_end             in     date     default null
  ,p_date_projected_start           in     date     default null
  ,p_date_start                     in     date     default null
  ,p_occurrence                     out nocopy    number
  ,p_ssp1_issued                    in     varchar2 default null
  ,p_time_end                       in     varchar2 default null
  ,p_time_projected_end             in     varchar2 default null
  ,p_time_projected_start           in     varchar2 default null
  ,p_time_start                     in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_maternity_id                   in     number   default null
  ,p_sickness_start_date            in     date     default null
  ,p_sickness_end_date              in     date     default null
  ,p_pregnancy_related_illness      in     varchar2 default null
  ,p_reason_for_notification_dela   in     varchar2 default null
  ,p_accept_late_notification_fla   in     varchar2 default null
  ,p_linked_absence_id              in     number   default null
  ,p_abs_information_category       in     varchar2 default null
  ,p_abs_information1               in     varchar2 default null
  ,p_abs_information2               in     varchar2 default null
  ,p_abs_information3               in     varchar2 default null
  ,p_abs_information4               in     varchar2 default null
  ,p_abs_information5               in     varchar2 default null
  ,p_abs_information6               in     varchar2 default null
  ,p_abs_information7               in     varchar2 default null
  ,p_abs_information8               in     varchar2 default null
  ,p_abs_information9               in     varchar2 default null
  ,p_abs_information10              in     varchar2 default null
  ,p_abs_information11              in     varchar2 default null
  ,p_abs_information12              in     varchar2 default null
  ,p_abs_information13              in     varchar2 default null
  ,p_abs_information14              in     varchar2 default null
  ,p_abs_information15              in     varchar2 default null
  ,p_abs_information16              in     varchar2 default null
  ,p_abs_information17              in     varchar2 default null
  ,p_abs_information18              in     varchar2 default null
  ,p_abs_information19              in     varchar2 default null
  ,p_abs_information20              in     varchar2 default null
  ,p_abs_information21              in     varchar2 default null
  ,p_abs_information22              in     varchar2 default null
  ,p_abs_information23              in     varchar2 default null
  ,p_abs_information24              in     varchar2 default null
  ,p_abs_information25              in     varchar2 default null
  ,p_abs_information26              in     varchar2 default null
  ,p_abs_information27              in     varchar2 default null
  ,p_abs_information28              in     varchar2 default null
  ,p_abs_information29              in     varchar2 default null
  ,p_abs_information30              in     varchar2 default null
  ,p_batch_id                       in     number   default null
  ,p_absence_case_id                in     number   default null
  ,p_absence_attendance_id          out nocopy    number
  ,p_object_version_number          out nocopy    number
  ,p_dur_dys_less_warning           out nocopy    boolean
  ,p_dur_hrs_less_warning           out nocopy    boolean
  ,p_exceeds_pto_entit_warning      out nocopy    boolean
  ,p_exceeds_run_total_warning      out nocopy    boolean
  ,p_abs_overlap_warning            out nocopy    boolean
  ,p_abs_day_after_warning          out nocopy    boolean
  ,p_dur_overwritten_warning        out nocopy    boolean
  ) is
--
  l_rec   per_abs_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
  l_absence_days           number;
  l_absence_hours          number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_abs_shd.convert_args
    (null
    ,p_business_group_id
    ,p_absence_attendance_type_id
    ,p_abs_attendance_reason_id
    ,p_person_id
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
    ,null             -- p_occurrence
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
    ,p_absence_Case_id
    ,p_batch_id
    ,null
    );
  --
  -- Having converted the arguments into the per_abs_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_abs_ins.ins
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
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_absence_attendance_id := l_rec.absence_attendance_id;
  p_object_version_number := l_rec.object_version_number;
  p_absence_days          := l_rec.absence_days;
  p_absence_hours         := l_rec.absence_hours;
  p_occurrence            := l_rec.occurrence;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_abs_ins;

/
