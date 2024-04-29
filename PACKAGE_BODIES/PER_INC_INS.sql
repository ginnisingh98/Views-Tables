--------------------------------------------------------
--  DDL for Package Body PER_INC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_INC_INS" as
/* $Header: peincrhi.pkb 115.29 2003/08/31 00:49:48 kjagadee noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_inc_ins.';  -- Global package name
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
  (p_rec in out nocopy per_inc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: per_work_incidents
  --
  insert into per_work_incidents
      (incident_id
      ,person_id
      ,incident_reference
      ,incident_type
      ,incident_date
      ,incident_time
      ,org_notified_date
      ,assignment_id
      ,location
      ,at_work_flag
      ,report_date
      ,report_time
      ,report_method
      ,person_reported_by
      ,person_reported_to
      ,witness_details
      ,description
      ,injury_type
      ,disease_type
      ,hazard_type
      ,body_part
      ,treatment_received_flag
      ,hospital_details
        ,emergency_code
        ,hospitalized_flag
        ,hospital_address
        ,activity_at_time_of_work
        ,objects_involved
        ,privacy_issue
        ,work_start_time
        ,date_of_death
        ,report_completed_by
        ,reporting_person_title
        ,reporting_person_phone
        ,days_restricted_work
        ,days_away_from_work
      ,doctor_name
      ,compensation_date
      ,compensation_currency
      ,compensation_amount
      ,remedial_hs_action
      ,notified_hsrep_id
      ,notified_hsrep_date
      ,notified_rep_id
      ,notified_rep_date
      ,notified_rep_org_id
      ,related_incident_id
      ,over_time_flag
	 ,absence_exists_flag
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
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,inc_information_category
      ,inc_information1
      ,inc_information2
      ,inc_information3
      ,inc_information4
      ,inc_information5
      ,inc_information6
      ,inc_information7
      ,inc_information8
      ,inc_information9
      ,inc_information10
      ,inc_information11
      ,inc_information12
      ,inc_information13
      ,inc_information14
      ,inc_information15
      ,inc_information16
      ,inc_information17
      ,inc_information18
      ,inc_information19
      ,inc_information20
      ,inc_information21
      ,inc_information22
      ,inc_information23
      ,inc_information24
      ,inc_information25
      ,inc_information26
      ,inc_information27
      ,inc_information28
      ,inc_information29
      ,inc_information30
      ,object_version_number
      )
  Values
    (p_rec.incident_id
    ,p_rec.person_id
    ,p_rec.incident_reference
    ,p_rec.incident_type
    ,p_rec.incident_date
    ,p_rec.incident_time
    ,p_rec.org_notified_date
    ,p_rec.assignment_id
    ,p_rec.location
    ,p_rec.at_work_flag
    ,p_rec.report_date
    ,p_rec.report_time
    ,p_rec.report_method
    ,p_rec.person_reported_by
    ,p_rec.person_reported_to
    ,p_rec.witness_details
    ,p_rec.description
    ,p_rec.injury_type
    ,p_rec.disease_type
    ,p_rec.hazard_type
    ,p_rec.body_part
    ,p_rec.treatment_received_flag
    ,p_rec.hospital_details
       ,p_rec.emergency_code
       ,p_rec.hospitalized_flag
       ,p_rec.hospital_address
       ,p_rec.activity_at_time_of_work
       ,p_rec.objects_involved
       ,p_rec.privacy_issue
       ,p_rec.work_start_time
       ,p_rec.date_of_death
       ,p_rec.report_completed_by
       ,p_rec.reporting_person_title
       ,p_rec.reporting_person_phone
       ,p_rec.days_restricted_work
       ,p_rec.days_away_from_work
    ,p_rec.doctor_name
    ,p_rec.compensation_date
    ,p_rec.compensation_currency
    ,p_rec.compensation_amount
    ,p_rec.remedial_hs_action
    ,p_rec.notified_hsrep_id
    ,p_rec.notified_hsrep_date
    ,p_rec.notified_rep_id
    ,p_rec.notified_rep_date
    ,p_rec.notified_rep_org_id
    ,p_rec.related_incident_id
    ,p_rec.over_time_flag
    ,p_rec.absence_exists_flag
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
    ,p_rec.attribute21
    ,p_rec.attribute22
    ,p_rec.attribute23
    ,p_rec.attribute24
    ,p_rec.attribute25
    ,p_rec.attribute26
    ,p_rec.attribute27
    ,p_rec.attribute28
    ,p_rec.attribute29
    ,p_rec.attribute30
    ,p_rec.inc_information_category
    ,p_rec.inc_information1
    ,p_rec.inc_information2
    ,p_rec.inc_information3
    ,p_rec.inc_information4
    ,p_rec.inc_information5
    ,p_rec.inc_information6
    ,p_rec.inc_information7
    ,p_rec.inc_information8
    ,p_rec.inc_information9
    ,p_rec.inc_information10
    ,p_rec.inc_information11
    ,p_rec.inc_information12
    ,p_rec.inc_information13
    ,p_rec.inc_information14
    ,p_rec.inc_information15
    ,p_rec.inc_information16
    ,p_rec.inc_information17
    ,p_rec.inc_information18
    ,p_rec.inc_information19
    ,p_rec.inc_information20
    ,p_rec.inc_information21
    ,p_rec.inc_information22
    ,p_rec.inc_information23
    ,p_rec.inc_information24
    ,p_rec.inc_information25
    ,p_rec.inc_information26
    ,p_rec.inc_information27
    ,p_rec.inc_information28
    ,p_rec.inc_information29
    ,p_rec.inc_information30
    ,p_rec.object_version_number
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_inc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_inc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_inc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec  in out nocopy per_inc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_work_incidents_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.incident_id;
  Close C_Sel1;
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
  ,p_rec                          in per_inc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_inc_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_incident_id
      => p_rec.incident_id
      ,p_person_id
      => p_rec.person_id
      ,p_incident_reference
      => p_rec.incident_reference
      ,p_incident_type
      => p_rec.incident_type
      ,p_incident_date
      => p_rec.incident_date
      ,p_incident_time
      => p_rec.incident_time
      ,p_org_notified_date
      => p_rec.org_notified_date
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_location
      => p_rec.location
      ,p_at_work_flag
      => p_rec.at_work_flag
      ,p_report_date
      => p_rec.report_date
      ,p_report_time
      => p_rec.report_time
      ,p_report_method
      => p_rec.report_method
      ,p_person_reported_by
      => p_rec.person_reported_by
      ,p_person_reported_to
      => p_rec.person_reported_to
      ,p_witness_details
      => p_rec.witness_details
      ,p_description
      => p_rec.description
      ,p_injury_type
      => p_rec.injury_type
      ,p_disease_type
      => p_rec.disease_type
      ,p_hazard_type
      => p_rec.hazard_type
      ,p_body_part
      => p_rec.body_part
      ,p_treatment_received_flag
      => p_rec.treatment_received_flag
      ,p_hospital_details
      => p_rec.hospital_details
  ,p_emergency_code                 => p_rec.emergency_code
  ,p_hospitalized_flag              => p_rec.hospitalized_flag
  ,p_hospital_address               => p_rec.hospital_address
  ,p_activity_at_time_of_work       => p_rec.activity_at_time_of_work
  ,p_objects_involved               => p_rec.objects_involved
  ,p_privacy_issue                  => p_rec.privacy_issue
  ,p_work_start_time                => p_rec.work_start_time
  ,p_date_of_death                  => p_rec.date_of_death
  ,p_report_completed_by            => p_rec.report_completed_by
  ,p_reporting_person_title         => p_rec.reporting_person_title
  ,p_reporting_person_phone         => p_rec.reporting_person_phone
  ,p_days_restricted_work           => p_rec.days_restricted_work
  ,p_days_away_from_work            => p_rec.days_away_from_work
      ,p_doctor_name
      => p_rec.doctor_name
      ,p_compensation_date
      => p_rec.compensation_date
      ,p_compensation_currency
      => p_rec.compensation_currency
      ,p_compensation_amount
      => p_rec.compensation_amount
      ,p_remedial_hs_action
      => p_rec.remedial_hs_action
      ,p_notified_hsrep_id
      => p_rec.notified_hsrep_id
      ,p_notified_hsrep_date
      => p_rec.notified_hsrep_date
      ,p_notified_rep_id
      => p_rec.notified_rep_id
      ,p_notified_rep_date
      => p_rec.notified_rep_date
      ,p_notified_rep_org_id
      => p_rec.notified_rep_org_id
      ,p_related_incident_id
      => p_rec.related_incident_id
      ,p_over_time_flag
      => p_rec.over_time_flag
      ,p_absence_exists_flag
      => p_rec.absence_exists_flag
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
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_inc_information_category
      => p_rec.inc_information_category
      ,p_inc_information1
      => p_rec.inc_information1
      ,p_inc_information2
      => p_rec.inc_information2
      ,p_inc_information3
      => p_rec.inc_information3
      ,p_inc_information4
      => p_rec.inc_information4
      ,p_inc_information5
      => p_rec.inc_information5
      ,p_inc_information6
      => p_rec.inc_information6
      ,p_inc_information7
      => p_rec.inc_information7
      ,p_inc_information8
      => p_rec.inc_information8
      ,p_inc_information9
      => p_rec.inc_information9
      ,p_inc_information10
      => p_rec.inc_information10
      ,p_inc_information11
      => p_rec.inc_information11
      ,p_inc_information12
      => p_rec.inc_information12
      ,p_inc_information13
      => p_rec.inc_information13
      ,p_inc_information14
      => p_rec.inc_information14
      ,p_inc_information15
      => p_rec.inc_information15
      ,p_inc_information16
      => p_rec.inc_information16
      ,p_inc_information17
      => p_rec.inc_information17
      ,p_inc_information18
      => p_rec.inc_information18
      ,p_inc_information19
      => p_rec.inc_information19
      ,p_inc_information20
      => p_rec.inc_information20
      ,p_inc_information21
      => p_rec.inc_information21
      ,p_inc_information22
      => p_rec.inc_information22
      ,p_inc_information23
      => p_rec.inc_information23
      ,p_inc_information24
      => p_rec.inc_information24
      ,p_inc_information25
      => p_rec.inc_information25
      ,p_inc_information26
      => p_rec.inc_information26
      ,p_inc_information27
      => p_rec.inc_information27
      ,p_inc_information28
      => p_rec.inc_information28
      ,p_inc_information29
      => p_rec.inc_information29
      ,p_inc_information30
      => p_rec.inc_information30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_WORK_INCIDENTS'
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
  ,p_rec                          in out nocopy per_inc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_inc_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  per_inc_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_inc_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_inc_ins.post_insert
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
  (p_effective_date               in     date
  ,p_person_id                      in     number
  ,p_incident_reference             in     varchar2
  ,p_incident_type                  in     varchar2
  ,p_incident_date                  in     date
  ,p_at_work_flag                   in     varchar2
  ,p_related_incident_id            in     number   default null
  ,p_incident_time                  in     varchar2 default null
  ,p_org_notified_date              in     date     default null
  ,p_assignment_id                  in     number   default null
  ,p_location                       in     varchar2 default null
  ,p_report_date                    in     date     default null
  ,p_report_time                    in     varchar2 default null
  ,p_report_method                  in     varchar2 default null
  ,p_person_reported_by             in     number   default null
  ,p_person_reported_to             in     varchar2 default null
  ,p_witness_details                in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_injury_type                    in     varchar2 default null
  ,p_disease_type                   in     varchar2 default null
  ,p_hazard_type                    in     varchar2 default null
  ,p_body_part                      in     varchar2 default null
  ,p_treatment_received_flag        in     varchar2 default null
  ,p_hospital_details               in     varchar2 default null
    ,p_emergency_code                 in     varchar2 default null
    ,p_hospitalized_flag              in     varchar2 default null
    ,p_hospital_address               in     varchar2 default null
    ,p_activity_at_time_of_work       in     varchar2 default null
    ,p_objects_involved               in     varchar2 default null
    ,p_privacy_issue                  in     varchar2 default null
    ,p_work_start_time                in     varchar2 default null
    ,p_date_of_death                  in     date     default null
    ,p_report_completed_by            in     varchar2 default null
    ,p_reporting_person_title         in     varchar2 default null
    ,p_reporting_person_phone         in     varchar2 default null
    ,p_days_restricted_work           in     number   default null
    ,p_days_away_from_work            in     number   default null
  ,p_doctor_name                    in     varchar2 default null
  ,p_compensation_date              in     date     default null
  ,p_compensation_currency          in     varchar2 default null
  ,p_compensation_amount            in     number   default null
  ,p_remedial_hs_action             in     varchar2 default null
  ,p_notified_hsrep_id              in     number   default null
  ,p_notified_hsrep_date            in     date     default null
  ,p_notified_rep_id                in     number   default null
  ,p_notified_rep_date              in     date     default null
  ,p_notified_rep_org_id            in     number   default null
  ,p_over_time_flag                 in     varchar2 default null
  ,p_absence_exists_flag            in     varchar2 default null
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
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_inc_information_category       in     varchar2 default null
  ,p_inc_information1               in     varchar2 default null
  ,p_inc_information2               in     varchar2 default null
  ,p_inc_information3               in     varchar2 default null
  ,p_inc_information4               in     varchar2 default null
  ,p_inc_information5               in     varchar2 default null
  ,p_inc_information6               in     varchar2 default null
  ,p_inc_information7               in     varchar2 default null
  ,p_inc_information8               in     varchar2 default null
  ,p_inc_information9               in     varchar2 default null
  ,p_inc_information10              in     varchar2 default null
  ,p_inc_information11              in     varchar2 default null
  ,p_inc_information12              in     varchar2 default null
  ,p_inc_information13              in     varchar2 default null
  ,p_inc_information14              in     varchar2 default null
  ,p_inc_information15              in     varchar2 default null
  ,p_inc_information16              in     varchar2 default null
  ,p_inc_information17              in     varchar2 default null
  ,p_inc_information18              in     varchar2 default null
  ,p_inc_information19              in     varchar2 default null
  ,p_inc_information20              in     varchar2 default null
  ,p_inc_information21              in     varchar2 default null
  ,p_inc_information22              in     varchar2 default null
  ,p_inc_information23              in     varchar2 default null
  ,p_inc_information24              in     varchar2 default null
  ,p_inc_information25              in     varchar2 default null
  ,p_inc_information26              in     varchar2 default null
  ,p_inc_information27              in     varchar2 default null
  ,p_inc_information28              in     varchar2 default null
  ,p_inc_information29              in     varchar2 default null
  ,p_inc_information30              in     varchar2 default null
  ,p_incident_id                       out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  per_inc_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_inc_shd.convert_args
    (null
    ,p_person_id
    ,p_incident_reference
    ,p_incident_type
    ,p_incident_date
    ,p_incident_time
    ,p_org_notified_date
    ,p_assignment_id
    ,p_location
    ,p_at_work_flag
    ,p_report_date
    ,p_report_time
    ,p_report_method
    ,p_person_reported_by
    ,p_person_reported_to
    ,p_witness_details
    ,p_description
    ,p_injury_type
    ,p_disease_type
    ,p_hazard_type
    ,p_body_part
    ,p_treatment_received_flag
    ,p_hospital_details
      ,p_emergency_code
      ,p_hospitalized_flag
      ,p_hospital_address
      ,p_activity_at_time_of_work
      ,p_objects_involved
      ,p_privacy_issue
      ,p_work_start_time
      ,p_date_of_death
      ,p_report_completed_by
      ,p_reporting_person_title
      ,p_reporting_person_phone
      ,p_days_restricted_work
      ,p_days_away_from_work
    ,p_doctor_name
    ,p_compensation_date
    ,p_compensation_currency
    ,p_compensation_amount
    ,p_remedial_hs_action
    ,p_notified_hsrep_id
    ,p_notified_hsrep_date
    ,p_notified_rep_id
    ,p_notified_rep_date
    ,p_notified_rep_org_id
    ,p_related_incident_id
    ,p_over_time_flag
    ,p_absence_exists_flag
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
    ,p_attribute21
    ,p_attribute22
    ,p_attribute23
    ,p_attribute24
    ,p_attribute25
    ,p_attribute26
    ,p_attribute27
    ,p_attribute28
    ,p_attribute29
    ,p_attribute30
    ,p_inc_information_category
    ,p_inc_information1
    ,p_inc_information2
    ,p_inc_information3
    ,p_inc_information4
    ,p_inc_information5
    ,p_inc_information6
    ,p_inc_information7
    ,p_inc_information8
    ,p_inc_information9
    ,p_inc_information10
    ,p_inc_information11
    ,p_inc_information12
    ,p_inc_information13
    ,p_inc_information14
    ,p_inc_information15
    ,p_inc_information16
    ,p_inc_information17
    ,p_inc_information18
    ,p_inc_information19
    ,p_inc_information20
    ,p_inc_information21
    ,p_inc_information22
    ,p_inc_information23
    ,p_inc_information24
    ,p_inc_information25
    ,p_inc_information26
    ,p_inc_information27
    ,p_inc_information28
    ,p_inc_information29
    ,p_inc_information30
    ,null
    );
  --
  -- Having converted the arguments into the per_inc_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_inc_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_incident_id := l_rec.incident_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_inc_ins;

/
