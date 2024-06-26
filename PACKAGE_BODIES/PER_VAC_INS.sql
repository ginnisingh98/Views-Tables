--------------------------------------------------------
--  DDL for Package Body PER_VAC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VAC_INS" as
/* $Header: pevacrhi.pkb 120.0.12010000.2 2010/04/08 10:24:32 karthmoh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_vac_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_vacancy_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_vacancy_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_vac_ins.g_vacancy_id_i := p_vacancy_id;
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
--   if a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
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
  (p_rec in out nocopy per_vac_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_vac_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_all_vacancies
  --
  insert into per_all_vacancies
      (vacancy_id
      ,business_group_id
      ,position_id
      ,job_id
      ,grade_id
      ,organization_id
      ,requisition_id
      ,people_group_id
      ,location_id
      ,recruiter_id
      ,date_from
      ,name
      ,comments
      ,date_to
      ,description
      ,number_of_openings
      ,status
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
      ,vacancy_category
      ,budget_measurement_type
      ,budget_measurement_value
      ,manager_id
      ,security_method
      ,primary_posting_id
      ,assessment_id
      ,object_version_number
      )
  Values
    (p_rec.vacancy_id
    ,p_rec.business_group_id
    ,p_rec.position_id
    ,p_rec.job_id
    ,p_rec.grade_id
    ,p_rec.organization_id
    ,p_rec.requisition_id
    ,p_rec.people_group_id
    ,p_rec.location_id
    ,p_rec.recruiter_id
    ,p_rec.date_from
    ,p_rec.name
    ,p_rec.comments
    ,p_rec.date_to
    ,p_rec.description
    ,p_rec.number_of_openings
    ,p_rec.status
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
    ,p_rec.vacancy_category
    ,p_rec.budget_measurement_type
    ,p_rec.budget_measurement_value
    ,p_rec.manager_id
    ,p_rec.security_method
    ,p_rec.primary_posting_id
    ,p_rec.assessment_id
    ,p_rec.object_version_number
    );
  --
   per_vac_shd.g_api_dml := false;  -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated then
    -- A check constraint has been violated
    per_vac_shd.g_api_dml := false;  -- Unset the api dml status
    per_vac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated then
    -- Parent integrity has been violated
    per_vac_shd.g_api_dml := false;  -- Unset the api dml status
    per_vac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated then
    -- Unique integrity has been violated
    per_vac_shd.g_api_dml := false;  -- Unset the api dml status
    per_vac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others then
    per_vac_shd.g_api_dml := false;  -- Unset the api dml status
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
--   if an error has occurred, an error message and exception will be raised
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
  (p_rec  in out nocopy per_vac_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select per_vacancies_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from per_all_vacancies
     where vacancy_id =
             per_vac_ins.g_vacancy_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (per_vac_ins.g_vacancy_id_i is not null) then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    if C_Sel2%found then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','per_all_vacancies');
       fnd_message.raise_error;
    end if;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.vacancy_id :=
      per_vac_ins.g_vacancy_id_i;
    per_vac_ins.g_vacancy_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.vacancy_id;
    Close C_Sel1;
  end if;
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
--   if an error has occurred, an error message and exception will be raised
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
  (p_rec                          in per_vac_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_vac_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_vacancy_id
      => p_rec.vacancy_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_position_id
      => p_rec.position_id
      ,p_job_id
      => p_rec.job_id
      ,p_grade_id
      => p_rec.grade_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_requisition_id
      => p_rec.requisition_id
      ,p_people_group_id
      => p_rec.people_group_id
      ,p_location_id
      => p_rec.location_id
      ,p_recruiter_id
      => p_rec.recruiter_id
      ,p_date_from
      => p_rec.date_from
      ,p_name
      => p_rec.name
      ,p_comments
      => p_rec.comments
      ,p_date_to
      => p_rec.date_to
      ,p_description
      => p_rec.description
      ,p_number_of_openings
      => p_rec.number_of_openings
      ,p_status
      => p_rec.status
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
      ,p_vacancy_category
      => p_rec.vacancy_category
      ,p_budget_measurement_type
      => p_rec.budget_measurement_type
      ,p_budget_measurement_value
      => p_rec.budget_measurement_value
      ,p_manager_id
      => p_rec.manager_id
      ,p_security_method
      => p_rec.security_method
      ,p_primary_posting_id
      => p_rec.primary_posting_id
      ,p_assessment_id
      => p_rec.assessment_id
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ALL_VACANCIES'
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
  (p_rec                          in out nocopy per_vac_shd.g_rec_type
  ,p_effective_date               in            date
  ,p_inv_pos_grade_warning           out nocopy boolean
  ,p_inv_job_grade_warning           out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_vac_bus.insert_validate
     (p_rec                   => p_rec
     ,p_effective_date        => p_effective_date
     ,p_inv_pos_grade_warning => p_inv_pos_grade_warning
     ,p_inv_job_grade_warning => p_inv_job_grade_warning
     );
  --
  -- Call the supporting pre-insert operation
  --
  per_vac_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_vac_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_vac_ins.post_insert
     (p_rec
     ,p_effective_date
     );
  hr_multi_message.end_validation_set();
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
  ,p_requisition_id                 in     number
  ,p_date_from                      in     date
  ,p_name                           in     varchar2
  ,p_position_id                    in     number   default null
  ,p_job_id                         in     number   default null
  ,p_grade_id                       in     number   default null
  ,p_organization_id                in     number   default null
  ,p_people_group_id                in     number   default null
  ,p_location_id                    in     number   default null
  ,p_recruiter_id                   in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_date_to                        in     date     default null
  ,p_description                    in     varchar2 default null
  ,p_number_of_openings             in     number   default null
  ,p_status                         in     varchar2 default null
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
  ,p_vacancy_category               in     varchar2 default null
  ,p_budget_measurement_type        in     varchar2 default null
  ,p_budget_measurement_value       in     number   default null
  ,p_manager_id                     in     number   default null
  ,p_security_method                in     varchar2 default null
  ,p_primary_posting_id             in     number   default null
  ,p_assessment_id                  in     number   default null
  ,p_inv_pos_grade_warning             out nocopy boolean
  ,p_inv_job_grade_warning             out nocopy boolean
  ,p_vacancy_id                        out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   per_vac_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_vac_shd.convert_args
    (null
    ,p_business_group_id
    ,p_position_id
    ,p_job_id
    ,p_grade_id
    ,p_organization_id
    ,p_requisition_id
    ,p_people_group_id
    ,p_location_id
    ,p_recruiter_id
    ,p_date_from
    ,p_name
    ,p_comments
    ,p_date_to
    ,p_description
    ,p_number_of_openings
    ,p_status
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
    ,p_vacancy_category
    ,p_budget_measurement_type
    ,p_budget_measurement_value
    ,p_manager_id
    ,p_security_method
    ,p_primary_posting_id
    ,p_assessment_id
    ,null
    );
  --
  -- Having converted the arguments into the per_vac_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_vac_ins.ins
     (p_rec => l_rec
     ,p_effective_date        => p_effective_date
     ,p_inv_pos_grade_warning => p_inv_pos_grade_warning
     ,p_inv_job_grade_warning => p_inv_job_grade_warning
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_vacancy_id := l_rec.vacancy_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_vac_ins;

/
