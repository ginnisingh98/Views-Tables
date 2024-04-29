--------------------------------------------------------
--  DDL for Package Body PQH_CPD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CPD_UPD" as
/* $Header: pqcpdrhi.pkb 120.0 2005/05/29 01:44:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_cpd_upd.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
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
  (p_rec in out nocopy pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
     l_proc := g_package||'update_dml';
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  pqh_cpd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqh_corps_definitions Row
  --
  update pqh_corps_definitions
    set
     corps_definition_id             = p_rec.corps_definition_id
    ,business_group_id               = p_rec.business_group_id
    ,name                            = p_rec.name
    ,status_cd                       = p_rec.status_cd
    ,retirement_age                  = p_rec.retirement_age
    ,category_cd                     = p_rec.category_cd
    ,recruitment_end_date            = p_rec.recruitment_end_date
    ,corps_type_cd                   = p_rec.corps_type_cd
    ,starting_grade_step_id          = p_rec.starting_grade_step_id
    ,task_desc                       = p_rec.task_desc
    ,secondment_threshold            = p_rec.secondment_threshold
    ,normal_hours                    = p_rec.normal_hours
    ,normal_hours_frequency          = p_rec.normal_hours_frequency
    ,minimum_hours                   = p_rec.minimum_hours
    ,minimum_hours_frequency         = p_rec.minimum_hours_frequency
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
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    ,attribute_category              = p_rec.attribute_category
    ,object_version_number           = p_rec.object_version_number
    ,type_of_ps                      = p_rec.type_of_ps
    ,date_from                       = p_rec.date_from
    ,date_to                         = p_rec.date_to
    ,primary_prof_field_id           = p_rec.primary_prof_field_id
    ,starting_grade_id               = p_rec.starting_grade_id
    ,ben_pgm_id                      = p_rec.ben_pgm_id
    ,probation_period                = p_rec.probation_period
    ,probation_units                 = p_rec.probation_units
    where corps_definition_id = p_rec.corps_definition_id;
  --
  pqh_cpd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_cpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_cpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_cpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqh_cpd_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
    l_proc := g_package||'pre_update';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  ,p_rec                          in pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
     l_proc := g_package||'post_update';
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    pqh_cpd_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_corps_definition_id
      => p_rec.corps_definition_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_name
      => p_rec.name
      ,p_status_cd
      => p_rec.status_cd
      ,p_retirement_age
      => p_rec.retirement_age
      ,p_category_cd
      => p_rec.category_cd
      ,p_recruitment_end_date
      => p_rec.recruitment_end_date
      ,p_corps_type_cd
      => p_rec.corps_type_cd
      ,p_starting_grade_step_id
      => p_rec.starting_grade_step_id
      ,p_task_desc
      => p_rec.task_desc
      ,p_secondment_threshold
      => p_rec.secondment_threshold
      ,p_normal_hours
      => p_rec.normal_hours
      ,p_normal_hours_frequency
      => p_rec.normal_hours_frequency
      ,p_minimum_hours
      => p_rec.minimum_hours
      ,p_minimum_hours_frequency
      => p_rec.minimum_hours_frequency
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
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_type_of_ps
      => p_rec.type_of_ps
      ,p_date_from
      => p_rec.date_from
      ,p_date_to
      => p_rec.date_to
      ,p_primary_prof_field_id
      => p_rec.primary_prof_field_id
      ,p_starting_grade_id
      => p_rec.starting_grade_id
      ,p_ben_pgm_id
      => p_rec.ben_pgm_id
      ,p_probation_period
      => p_rec.probation_period
      ,p_probation_units
      => p_rec.probation_units
      ,p_business_group_id_o
      => pqh_cpd_shd.g_old_rec.business_group_id
      ,p_name_o
      => pqh_cpd_shd.g_old_rec.name
      ,p_status_cd_o
      => pqh_cpd_shd.g_old_rec.status_cd
      ,p_retirement_age_o
      => pqh_cpd_shd.g_old_rec.retirement_age
      ,p_category_cd_o
      => pqh_cpd_shd.g_old_rec.category_cd
      ,p_recruitment_end_date_o
      => pqh_cpd_shd.g_old_rec.recruitment_end_date
      ,p_corps_type_cd_o
      => pqh_cpd_shd.g_old_rec.corps_type_cd
      ,p_starting_grade_step_id_o
      => pqh_cpd_shd.g_old_rec.starting_grade_step_id
      ,p_task_desc_o
      => pqh_cpd_shd.g_old_rec.task_desc
      ,p_secondment_threshold_o
      => pqh_cpd_shd.g_old_rec.secondment_threshold
      ,p_normal_hours_o
      => pqh_cpd_shd.g_old_rec.normal_hours
      ,p_normal_hours_frequency_o
      => pqh_cpd_shd.g_old_rec.normal_hours_frequency
      ,p_minimum_hours_o
      => pqh_cpd_shd.g_old_rec.minimum_hours
      ,p_minimum_hours_frequency_o
      => pqh_cpd_shd.g_old_rec.minimum_hours_frequency
      ,p_attribute1_o
      => pqh_cpd_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pqh_cpd_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pqh_cpd_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pqh_cpd_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pqh_cpd_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pqh_cpd_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pqh_cpd_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pqh_cpd_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pqh_cpd_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pqh_cpd_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pqh_cpd_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pqh_cpd_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pqh_cpd_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pqh_cpd_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pqh_cpd_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pqh_cpd_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pqh_cpd_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pqh_cpd_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pqh_cpd_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pqh_cpd_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => pqh_cpd_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => pqh_cpd_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => pqh_cpd_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => pqh_cpd_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => pqh_cpd_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => pqh_cpd_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => pqh_cpd_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => pqh_cpd_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => pqh_cpd_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => pqh_cpd_shd.g_old_rec.attribute30
      ,p_attribute_category_o
      => pqh_cpd_shd.g_old_rec.attribute_category
      ,p_object_version_number_o
      => pqh_cpd_shd.g_old_rec.object_version_number
      ,p_type_of_ps_o
      => pqh_cpd_shd.g_old_rec.type_of_ps
      ,p_date_from_o
      => pqh_cpd_shd.g_old_rec.date_from
      ,p_date_to_o
      => pqh_cpd_shd.g_old_rec.date_to
      ,p_primary_prof_field_id_o
      => pqh_cpd_shd.g_old_rec.primary_prof_field_id
      ,p_starting_grade_id_o
      => pqh_cpd_shd.g_old_rec.starting_grade_id
      ,p_ben_pgm_id_o
      => pqh_cpd_shd.g_old_rec.ben_pgm_id
      ,p_probation_period_o
      => pqh_cpd_shd.g_old_rec.probation_period
      ,p_probation_units_o
      => pqh_cpd_shd.g_old_rec.probation_units
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_CORPS_DEFINITIONS'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec in out nocopy pqh_cpd_shd.g_rec_type
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
    pqh_cpd_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    pqh_cpd_shd.g_old_rec.name;
  End If;
  If (p_rec.status_cd = hr_api.g_varchar2) then
    p_rec.status_cd :=
    pqh_cpd_shd.g_old_rec.status_cd;
  End If;
  If (p_rec.retirement_age = hr_api.g_number) then
    p_rec.retirement_age :=
    pqh_cpd_shd.g_old_rec.retirement_age;
  End If;
  If (p_rec.category_cd = hr_api.g_varchar2) then
    p_rec.category_cd :=
    pqh_cpd_shd.g_old_rec.category_cd;
  End If;
  If (p_rec.recruitment_end_date = hr_api.g_date) then
    p_rec.recruitment_end_date :=
    pqh_cpd_shd.g_old_rec.recruitment_end_date;
  End If;
  If (p_rec.corps_type_cd = hr_api.g_varchar2) then
    p_rec.corps_type_cd :=
    pqh_cpd_shd.g_old_rec.corps_type_cd;
  End If;
  If (p_rec.starting_grade_step_id = hr_api.g_number) then
    p_rec.starting_grade_step_id :=
    pqh_cpd_shd.g_old_rec.starting_grade_step_id;
  End If;
  If (p_rec.task_desc = hr_api.g_varchar2) then
    p_rec.task_desc :=
    pqh_cpd_shd.g_old_rec.task_desc;
  End If;
  If (p_rec.secondment_threshold = hr_api.g_number) then
    p_rec.secondment_threshold :=
    pqh_cpd_shd.g_old_rec.secondment_threshold;
  End If;
  If (p_rec.normal_hours = hr_api.g_number) then
    p_rec.normal_hours :=
    pqh_cpd_shd.g_old_rec.normal_hours;
  End If;
  If (p_rec.normal_hours_frequency = hr_api.g_varchar2) then
    p_rec.normal_hours_frequency :=
    pqh_cpd_shd.g_old_rec.normal_hours_frequency;
  End If;
  If (p_rec.minimum_hours = hr_api.g_number) then
    p_rec.minimum_hours :=
    pqh_cpd_shd.g_old_rec.minimum_hours;
  End If;
  If (p_rec.minimum_hours_frequency = hr_api.g_varchar2) then
    p_rec.minimum_hours_frequency :=
    pqh_cpd_shd.g_old_rec.minimum_hours_frequency;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pqh_cpd_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pqh_cpd_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pqh_cpd_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pqh_cpd_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pqh_cpd_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pqh_cpd_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pqh_cpd_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pqh_cpd_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pqh_cpd_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pqh_cpd_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pqh_cpd_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pqh_cpd_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pqh_cpd_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pqh_cpd_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pqh_cpd_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pqh_cpd_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pqh_cpd_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pqh_cpd_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pqh_cpd_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pqh_cpd_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    pqh_cpd_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    pqh_cpd_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    pqh_cpd_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    pqh_cpd_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    pqh_cpd_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    pqh_cpd_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    pqh_cpd_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    pqh_cpd_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    pqh_cpd_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    pqh_cpd_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pqh_cpd_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.type_of_ps = hr_api.g_varchar2) then
    p_rec.type_of_ps :=
    pqh_cpd_shd.g_old_rec.type_of_ps;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    pqh_cpd_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    pqh_cpd_shd.g_old_rec.date_to;
  End If;
  If (p_rec.primary_prof_field_id = hr_api.g_number) then
    p_rec.primary_prof_field_id :=
    pqh_cpd_shd.g_old_rec.primary_prof_field_id;
  End If;
  If (p_rec.starting_grade_id = hr_api.g_number) then
    p_rec.starting_grade_id :=
    pqh_cpd_shd.g_old_rec.starting_grade_id;
  End If;
  If (p_rec.ben_pgm_id = hr_api.g_number) then
    p_rec.ben_pgm_id :=
    pqh_cpd_shd.g_old_rec.ben_pgm_id;
  End If;
  If (p_rec.probation_period = hr_api.g_number) then
    p_rec.probation_period :=
    pqh_cpd_shd.g_old_rec.probation_period;
  End If;
  If (p_rec.probation_units = hr_api.g_varchar2) then
    p_rec.probation_units :=
    pqh_cpd_shd.g_old_rec.probation_units;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
    l_proc := g_package||'upd';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to update.
  --
  pqh_cpd_shd.lck
    (p_rec.corps_definition_id
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
  pqh_cpd_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqh_cpd_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_cpd_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_cpd_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_corps_definition_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_status_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_category_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_retirement_age               in     number    default hr_api.g_number
  ,p_recruitment_end_date         in     date      default hr_api.g_date
  ,p_corps_type_cd                in     varchar2  default hr_api.g_varchar2
  ,p_starting_grade_step_id       in     number    default hr_api.g_number
  ,p_task_desc                    in     varchar2  default hr_api.g_varchar2
  ,p_secondment_threshold         in     number    default hr_api.g_number
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_normal_hours_frequency       in     varchar2  default hr_api.g_varchar2
  ,p_minimum_hours                in     number    default hr_api.g_number
  ,p_minimum_hours_frequency      in     varchar2  default hr_api.g_varchar2
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
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_type_of_ps                   in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_primary_prof_field_id        in     number    default hr_api.g_number
  ,p_starting_grade_id            in     number    default hr_api.g_number
  ,p_ben_pgm_id                   in     number    default hr_api.g_number
  ,p_probation_period             in     number    default hr_api.g_number
  ,p_probation_units              in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pqh_cpd_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  if g_debug then
     l_proc := g_package||'upd';
      hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_cpd_shd.convert_args
  (p_corps_definition_id
  ,p_business_group_id
  ,p_name
  ,p_status_cd
  ,p_retirement_age
  ,p_category_cd
  ,p_recruitment_end_date
  ,p_corps_type_cd
  ,p_starting_grade_step_id
  ,p_task_desc
  ,p_secondment_threshold
  ,p_normal_hours
  ,p_normal_hours_frequency
  ,p_minimum_hours
  ,p_minimum_hours_frequency
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
  ,p_attribute_category
  ,p_object_version_number
  ,p_type_of_ps
  ,p_date_from
  ,p_date_to
  ,p_primary_prof_field_id
  ,p_starting_grade_id
  ,p_ben_pgm_id
  ,p_probation_period
  ,p_probation_units
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_cpd_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end pqh_cpd_upd;

/
