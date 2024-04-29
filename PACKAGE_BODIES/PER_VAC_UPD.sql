--------------------------------------------------------
--  DDL for Package Body PER_VAC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VAC_UPD" as
/* $Header: pevacrhi.pkb 120.0.12010000.2 2010/04/08 10:24:32 karthmoh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_vac_upd.';  -- Global package name
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
--   if a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
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
  (p_rec in out nocopy per_vac_shd.g_rec_type
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
  per_vac_shd.g_api_dml := true;  -- Set the dml status
  --
  -- Update the per_all_vacancies Row
  --
  update per_all_vacancies
    set
     vacancy_id                      = p_rec.vacancy_id
    ,business_group_id               = p_rec.business_group_id
    ,position_id                     = p_rec.position_id
    ,job_id                          = p_rec.job_id
    ,grade_id                        = p_rec.grade_id
    ,organization_id                 = p_rec.organization_id
    ,requisition_id                  = p_rec.requisition_id
    ,people_group_id                 = p_rec.people_group_id
    ,location_id                     = p_rec.location_id
    ,recruiter_id                    = p_rec.recruiter_id
    ,date_from                       = p_rec.date_from
    ,name                            = p_rec.name
    ,comments                        = p_rec.comments
    ,date_to                         = p_rec.date_to
    ,description                     = p_rec.description
    ,number_of_openings              = p_rec.number_of_openings
    ,status                          = p_rec.status
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
    ,vacancy_category                = p_rec.vacancy_category
    ,budget_measurement_type         = p_rec.budget_measurement_type
    ,budget_measurement_value        = p_rec.budget_measurement_value
    ,manager_id                      = p_rec.manager_id
    ,security_method                 = p_rec.security_method
    ,primary_posting_id              = p_rec.primary_posting_id
    ,assessment_id                   = p_rec.assessment_id
    ,object_version_number           = p_rec.object_version_number
    where vacancy_id = p_rec.vacancy_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated then
    -- A check constraint has been violated
    per_vac_shd.g_api_dml := false;  -- Unset the dml status
    per_vac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated then
    -- Parent integrity has been violated
    per_vac_shd.g_api_dml := false;  -- Unset the dml status
    per_vac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated then
    -- Unique integrity has been violated
    per_vac_shd.g_api_dml := false;  -- Unset the dml status
    per_vac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others then
    per_vac_shd.g_api_dml := false;  -- Unset the dml status
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
--   if an error has occurred, an error message and exception wil be raised
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
  (p_rec in per_vac_shd.g_rec_type
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
--   if an error has occurred, an error message and exception will be raised
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
  (p_rec                          in per_vac_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_vac_rku.after_update
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
      ,p_position_id_o
      => per_vac_shd.g_old_rec.position_id
      ,p_job_id_o
      => per_vac_shd.g_old_rec.job_id
      ,p_grade_id_o
      => per_vac_shd.g_old_rec.grade_id
      ,p_organization_id_o
      => per_vac_shd.g_old_rec.organization_id
      ,p_requisition_id_o
      => per_vac_shd.g_old_rec.requisition_id
      ,p_people_group_id_o
      => per_vac_shd.g_old_rec.people_group_id
      ,p_location_id_o
      => per_vac_shd.g_old_rec.location_id
      ,p_recruiter_id_o
      => per_vac_shd.g_old_rec.recruiter_id
      ,p_date_from_o
      => per_vac_shd.g_old_rec.date_from
      ,p_comments_o
      => per_vac_shd.g_old_rec.comments
      ,p_date_to_o
      => per_vac_shd.g_old_rec.date_to
      ,p_description_o
      => per_vac_shd.g_old_rec.description
      ,p_number_of_openings_o
      => per_vac_shd.g_old_rec.number_of_openings
      ,p_status_o
      => per_vac_shd.g_old_rec.status
      ,p_request_id_o
      => per_vac_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_vac_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_vac_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_vac_shd.g_old_rec.program_update_date
      ,p_attribute_category_o
      => per_vac_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_vac_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_vac_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_vac_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_vac_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_vac_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_vac_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_vac_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_vac_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_vac_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_vac_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_vac_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_vac_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_vac_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_vac_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_vac_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_vac_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_vac_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_vac_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_vac_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_vac_shd.g_old_rec.attribute20
      ,p_vacancy_category_o
      => per_vac_shd.g_old_rec.vacancy_category
      ,p_budget_measurement_type_o
      => per_vac_shd.g_old_rec.budget_measurement_type
      ,p_budget_measurement_value_o
      => per_vac_shd.g_old_rec.budget_measurement_value
      ,p_manager_id_o
      => per_vac_shd.g_old_rec.manager_id
      ,p_security_method_o
      => per_vac_shd.g_old_rec.security_method
      ,p_primary_posting_id_o
      => per_vac_shd.g_old_rec.primary_posting_id
      ,p_assessment_id_o
      => per_vac_shd.g_old_rec.assessment_id
      ,p_object_version_number_o
      => per_vac_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ALL_VACANCIES'
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
--   have not been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. if a system default is being
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
  (p_rec in out nocopy per_vac_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. if a system default
  -- is being used then we must set to the 'current' argument value.
  --
  if (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_vac_shd.g_old_rec.business_group_id;
  end if;
  if (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    per_vac_shd.g_old_rec.position_id;
  end if;
  if (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    per_vac_shd.g_old_rec.job_id;
  end if;
  if (p_rec.grade_id = hr_api.g_number) then
    p_rec.grade_id :=
    per_vac_shd.g_old_rec.grade_id;
  end if;
  if (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    per_vac_shd.g_old_rec.organization_id;
  end if;
  if (p_rec.requisition_id = hr_api.g_number) then
    p_rec.requisition_id :=
    per_vac_shd.g_old_rec.requisition_id;
  end if;
  if (p_rec.people_group_id = hr_api.g_number) then
    p_rec.people_group_id :=
    per_vac_shd.g_old_rec.people_group_id;
  end if;
  if (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    per_vac_shd.g_old_rec.location_id;
  end if;
  if (p_rec.recruiter_id = hr_api.g_number) then
    p_rec.recruiter_id :=
    per_vac_shd.g_old_rec.recruiter_id;
  end if;
  if (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    per_vac_shd.g_old_rec.date_from;
  end if;
  if (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    per_vac_shd.g_old_rec.name;
  end if;
  if (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_vac_shd.g_old_rec.comments;
  end if;
  if (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    per_vac_shd.g_old_rec.date_to;
  end if;
  if (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    per_vac_shd.g_old_rec.description;
  end if;
  if (p_rec.number_of_openings = hr_api.g_number) then
    p_rec.number_of_openings :=
    per_vac_shd.g_old_rec.number_of_openings;
  end if;
  if (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    per_vac_shd.g_old_rec.status;
  end if;
  if (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_vac_shd.g_old_rec.request_id;
  end if;
  if (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_vac_shd.g_old_rec.program_application_id;
  end if;
  if (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_vac_shd.g_old_rec.program_id;
  end if;
  if (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_vac_shd.g_old_rec.program_update_date;
  end if;
  if (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_vac_shd.g_old_rec.attribute_category;
  end if;
  if (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_vac_shd.g_old_rec.attribute1;
  end if;
  if (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_vac_shd.g_old_rec.attribute2;
  end if;
  if (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_vac_shd.g_old_rec.attribute3;
  end if;
  if (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_vac_shd.g_old_rec.attribute4;
  end if;
  if (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_vac_shd.g_old_rec.attribute5;
  end if;
  if (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_vac_shd.g_old_rec.attribute6;
  end if;
  if (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_vac_shd.g_old_rec.attribute7;
  end if;
  if (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_vac_shd.g_old_rec.attribute8;
  end if;
  if (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_vac_shd.g_old_rec.attribute9;
  end if;
  if (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_vac_shd.g_old_rec.attribute10;
  end if;
  if (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_vac_shd.g_old_rec.attribute11;
  end if;
  if (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_vac_shd.g_old_rec.attribute12;
  end if;
  if (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_vac_shd.g_old_rec.attribute13;
  end if;
  if (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_vac_shd.g_old_rec.attribute14;
  end if;
  if (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_vac_shd.g_old_rec.attribute15;
  end if;
  if (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_vac_shd.g_old_rec.attribute16;
  end if;
  if (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_vac_shd.g_old_rec.attribute17;
  end if;
  if (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_vac_shd.g_old_rec.attribute18;
  end if;
  if (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_vac_shd.g_old_rec.attribute19;
  end if;
  if (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_vac_shd.g_old_rec.attribute20;
  end if;
  if (p_rec.vacancy_category = hr_api.g_varchar2) then
    p_rec.vacancy_category :=
    per_vac_shd.g_old_rec.vacancy_category;
  end if;
  if (p_rec.budget_measurement_type = hr_api.g_varchar2) then
    p_rec.budget_measurement_type :=
    per_vac_shd.g_old_rec.budget_measurement_type;
  end if;
  if (p_rec.budget_measurement_value = hr_api.g_number) then
    p_rec.budget_measurement_value :=
    per_vac_shd.g_old_rec.budget_measurement_value;
  end if;
  if (p_rec.manager_id = hr_api.g_number) then
    p_rec.manager_id :=
    per_vac_shd.g_old_rec.manager_id;
  end if;
  if (p_rec.security_method = hr_api.g_varchar2) then
    p_rec.security_method :=
    per_vac_shd.g_old_rec.security_method;
  end if;
  if (p_rec.primary_posting_id = hr_api.g_number) then
    p_rec.primary_posting_id :=
    per_vac_shd.g_old_rec.primary_posting_id;
  end if;
  if (p_rec.assessment_id = hr_api.g_number) then
    p_rec.assessment_id :=
    per_vac_shd.g_old_rec.assessment_id;
  end if;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy per_vac_shd.g_rec_type
  ,p_effective_date               in            date
  ,p_inv_pos_grade_warning           out nocopy boolean
  ,p_inv_job_grade_warning           out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_vac_shd.lck
    (p_rec.vacancy_id
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
  per_vac_bus.update_validate
     (p_rec                   => p_rec
     ,p_effective_date        => p_effective_date
     ,p_inv_pos_grade_warning => p_inv_pos_grade_warning
     ,p_inv_job_grade_warning => p_inv_job_grade_warning

     );
  --
  -- Call the supporting pre-update operation
  --
  per_vac_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_vac_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_vac_upd.post_update
     (p_rec
     ,p_effective_date
     );
  hr_multi_message.end_validation_set();
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_vacancy_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_requisition_id               in     number    default hr_api.g_number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_recruiter_id                 in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_number_of_openings           in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
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
  ,p_vacancy_category             in     varchar2  default hr_api.g_varchar2
  ,p_budget_measurement_type      in     varchar2  default hr_api.g_varchar2
  ,p_budget_measurement_value     in     number    default hr_api.g_number
  ,p_manager_id                   in     number    default hr_api.g_number
  ,p_security_method              in     varchar2  default hr_api.g_varchar2
  ,p_primary_posting_id           in     number    default hr_api.g_number
  ,p_assessment_id                in     number    default hr_api.g_number
  ,p_inv_pos_grade_warning           out nocopy boolean
  ,p_inv_job_grade_warning           out nocopy boolean
  ) is
--
  l_rec   per_vac_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_vac_shd.convert_args
  (p_vacancy_id
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
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_vac_upd.upd
     (p_rec => l_rec
     ,p_effective_date        => p_effective_date
     ,p_inv_pos_grade_warning => p_inv_pos_grade_warning
     ,p_inv_job_grade_warning => p_inv_job_grade_warning
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_vac_upd;

/