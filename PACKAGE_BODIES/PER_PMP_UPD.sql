--------------------------------------------------------
--  DDL for Package Body PER_PMP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PMP_UPD" as
/* $Header: pepmprhi.pkb 120.8.12010000.4 2010/01/27 15:51:33 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pmp_upd.';  -- Global package name
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
  (p_rec in out nocopy per_pmp_shd.g_rec_type
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
  --
  -- Update the per_perf_mgmt_plans Row
  --
  update per_perf_mgmt_plans
    set
     plan_id                         = p_rec.plan_id
    ,object_version_number           = p_rec.object_version_number
    ,plan_name                       = p_rec.plan_name
    ,administrator_person_id         = p_rec.administrator_person_id
    ,previous_plan_id                = p_rec.previous_plan_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,status_code                     = p_rec.status_code
    ,hierarchy_type_code             = p_rec.hierarchy_type_code
    ,supervisor_id                   = p_rec.supervisor_id
    ,supervisor_assignment_id        = p_rec.supervisor_assignment_id
    ,organization_structure_id       = p_rec.organization_structure_id
    ,org_structure_version_id        = p_rec.org_structure_version_id
    ,top_organization_id             = p_rec.top_organization_id
    ,position_structure_id           = p_rec.position_structure_id
    ,pos_structure_version_id        = p_rec.pos_structure_version_id
    ,top_position_id                 = p_rec.top_position_id
    ,hierarchy_levels                = p_rec.hierarchy_levels
    ,automatic_enrollment_flag       = p_rec.automatic_enrollment_flag
    ,assignment_types_code           = p_rec.assignment_types_code
    ,primary_asg_only_flag           = p_rec.primary_asg_only_flag
    ,include_obj_setting_flag        = p_rec.include_obj_setting_flag
    ,obj_setting_start_date          = p_rec.obj_setting_start_date
    ,obj_setting_deadline            = p_rec.obj_setting_deadline
    ,obj_set_outside_period_flag     = p_rec.obj_set_outside_period_flag
    ,method_code                     = p_rec.method_code
    ,notify_population_flag          = p_rec.notify_population_flag
    ,automatic_allocation_flag       = p_rec.automatic_allocation_flag
    ,copy_past_objectives_flag       = p_rec.copy_past_objectives_flag
    ,sharing_alignment_task_flag     = p_rec.sharing_alignment_task_flag
    ,include_appraisals_flag         = p_rec.include_appraisals_flag
    ,change_sc_status_flag    = p_rec.change_sc_status_flag
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
   ,update_library_objectives       = p_rec.update_library_objectives   -- 8740021 bug fix
   ,automatic_approval_flag       = p_rec.automatic_approval_flag
    where plan_id = p_rec.plan_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec in per_pmp_shd.g_rec_type
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
  ,p_rec                          in per_pmp_shd.g_rec_type
  ,p_duplicate_name_warning       in boolean
  ,p_no_life_events_warning       in boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pmp_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_plan_id
      => p_rec.plan_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_plan_name
      => p_rec.plan_name
      ,p_administrator_person_id
      => p_rec.administrator_person_id
      ,p_previous_plan_id
      => p_rec.previous_plan_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_status_code
      => p_rec.status_code
      ,p_hierarchy_type_code
      => p_rec.hierarchy_type_code
      ,p_supervisor_id
      => p_rec.supervisor_id
      ,p_supervisor_assignment_id
      => p_rec.supervisor_assignment_id
      ,p_organization_structure_id
      => p_rec.organization_structure_id
      ,p_org_structure_version_id
      => p_rec.org_structure_version_id
      ,p_top_organization_id
      => p_rec.top_organization_id
      ,p_position_structure_id
      => p_rec.position_structure_id
      ,p_pos_structure_version_id
      => p_rec.pos_structure_version_id
      ,p_top_position_id
      => p_rec.top_position_id
      ,p_hierarchy_levels
      => p_rec.hierarchy_levels
      ,p_automatic_enrollment_flag
      => p_rec.automatic_enrollment_flag
      ,p_assignment_types_code
      => p_rec.assignment_types_code
      ,p_primary_asg_only_flag
      => p_rec.primary_asg_only_flag
      ,p_include_obj_setting_flag
      => p_rec.include_obj_setting_flag
      ,p_obj_setting_start_date
      => p_rec.obj_setting_start_date
      ,p_obj_setting_deadline
      => p_rec.obj_setting_deadline
      ,p_obj_set_outside_period_flag
      => p_rec.obj_set_outside_period_flag
      ,p_method_code
      => p_rec.method_code
      ,p_notify_population_flag
      => p_rec.notify_population_flag
      ,p_automatic_allocation_flag
      => p_rec.automatic_allocation_flag
      ,p_copy_past_objectives_flag
      => p_rec.copy_past_objectives_flag
      ,p_sharing_alignment_task_flag
      => p_rec.sharing_alignment_task_flag
      ,p_include_appraisals_flag
      => p_rec.include_appraisals_flag
      ,p_change_sc_status_flag => p_rec.change_sc_status_flag
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
      ,p_update_library_objectives
      => p_rec.update_library_objectives   -- 8740021 bug fix
      ,p_automatic_approval_flag
      => p_rec.automatic_approval_flag
      ,p_object_version_number_o
      => per_pmp_shd.g_old_rec.object_version_number
      ,p_plan_name_o
      => per_pmp_shd.g_old_rec.plan_name
      ,p_administrator_person_id_o
      => per_pmp_shd.g_old_rec.administrator_person_id
      ,p_previous_plan_id_o
      => per_pmp_shd.g_old_rec.previous_plan_id
      ,p_start_date_o
      => per_pmp_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_pmp_shd.g_old_rec.end_date
      ,p_status_code_o
      => per_pmp_shd.g_old_rec.status_code
      ,p_hierarchy_type_code_o
      => per_pmp_shd.g_old_rec.hierarchy_type_code
      ,p_supervisor_id_o
      => per_pmp_shd.g_old_rec.supervisor_id
      ,p_supervisor_assignment_id_o
      => per_pmp_shd.g_old_rec.supervisor_assignment_id
      ,p_organization_structure_id_o
      => per_pmp_shd.g_old_rec.organization_structure_id
      ,p_org_structure_version_id_o
      => per_pmp_shd.g_old_rec.org_structure_version_id
      ,p_top_organization_id_o
      => per_pmp_shd.g_old_rec.top_organization_id
      ,p_position_structure_id_o
      => per_pmp_shd.g_old_rec.position_structure_id
      ,p_pos_structure_version_id_o
      => per_pmp_shd.g_old_rec.pos_structure_version_id
      ,p_top_position_id_o
      => per_pmp_shd.g_old_rec.top_position_id
      ,p_hierarchy_levels_o
      => per_pmp_shd.g_old_rec.hierarchy_levels
      ,p_automatic_enrollment_flag_o
      => per_pmp_shd.g_old_rec.automatic_enrollment_flag
      ,p_assignment_types_code_o
      => per_pmp_shd.g_old_rec.assignment_types_code
      ,p_primary_asg_only_flag_o
      => per_pmp_shd.g_old_rec.primary_asg_only_flag
      ,p_include_obj_setting_flag_o
      => per_pmp_shd.g_old_rec.include_obj_setting_flag
      ,p_obj_setting_start_date_o
      => per_pmp_shd.g_old_rec.obj_setting_start_date
      ,p_obj_setting_deadline_o
      => per_pmp_shd.g_old_rec.obj_setting_deadline
      ,p_obj_set_outside_period_fla_o
      => per_pmp_shd.g_old_rec.obj_set_outside_period_flag
      ,p_method_code_o
      => per_pmp_shd.g_old_rec.method_code
      ,p_notify_population_flag_o
      => per_pmp_shd.g_old_rec.notify_population_flag
      ,p_automatic_allocation_flag_o
      => per_pmp_shd.g_old_rec.automatic_allocation_flag
      ,p_copy_past_objectives_flag_o
      => per_pmp_shd.g_old_rec.copy_past_objectives_flag
      ,p_sharing_alignment_task_fla_o
      => per_pmp_shd.g_old_rec.sharing_alignment_task_flag
      ,p_include_appraisals_flag_o
      => per_pmp_shd.g_old_rec.include_appraisals_flag
  ,p_change_sc_status_flag_o => per_pmp_shd.g_old_rec.change_sc_status_flag
      ,p_attribute_category_o
      => per_pmp_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_pmp_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_pmp_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_pmp_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_pmp_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_pmp_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_pmp_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_pmp_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_pmp_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_pmp_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_pmp_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_pmp_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_pmp_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_pmp_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_pmp_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_pmp_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_pmp_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_pmp_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_pmp_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_pmp_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_pmp_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => per_pmp_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => per_pmp_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => per_pmp_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => per_pmp_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => per_pmp_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => per_pmp_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => per_pmp_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => per_pmp_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => per_pmp_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => per_pmp_shd.g_old_rec.attribute30
     ,p_update_library_objectives_o
      => per_pmp_shd.g_old_rec.update_library_objectives     --  8740021 bug fix
     ,p_automatic_approval_flag_o
      => per_pmp_shd.g_old_rec.automatic_approval_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PERF_MGMT_PLANS'
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
  (p_rec in out nocopy per_pmp_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.plan_name = hr_api.g_varchar2) then
    p_rec.plan_name :=
    per_pmp_shd.g_old_rec.plan_name;
  End If;
  If (p_rec.administrator_person_id = hr_api.g_number) then
    p_rec.administrator_person_id :=
    per_pmp_shd.g_old_rec.administrator_person_id;
  End If;
  If (p_rec.previous_plan_id = hr_api.g_number) then
    p_rec.previous_plan_id :=
    per_pmp_shd.g_old_rec.previous_plan_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_pmp_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_pmp_shd.g_old_rec.end_date;
  End If;
  If (p_rec.status_code = hr_api.g_varchar2) then
    p_rec.status_code :=
    per_pmp_shd.g_old_rec.status_code;
  End If;
  If (p_rec.hierarchy_type_code = hr_api.g_varchar2) then
    p_rec.hierarchy_type_code :=
    per_pmp_shd.g_old_rec.hierarchy_type_code;
  End If;
  If (p_rec.supervisor_id = hr_api.g_number) then
    p_rec.supervisor_id :=
    per_pmp_shd.g_old_rec.supervisor_id;
  End If;
  If (p_rec.supervisor_assignment_id = hr_api.g_number) then
    p_rec.supervisor_assignment_id :=
    per_pmp_shd.g_old_rec.supervisor_assignment_id;
  End If;
  If (p_rec.organization_structure_id = hr_api.g_number) then
    p_rec.organization_structure_id :=
    per_pmp_shd.g_old_rec.organization_structure_id;
  End If;
  If (p_rec.org_structure_version_id = hr_api.g_number) then
    p_rec.org_structure_version_id :=
    per_pmp_shd.g_old_rec.org_structure_version_id;
  End If;
  If (p_rec.top_organization_id = hr_api.g_number) then
    p_rec.top_organization_id :=
    per_pmp_shd.g_old_rec.top_organization_id;
  End If;
  If (p_rec.position_structure_id = hr_api.g_number) then
    p_rec.position_structure_id :=
    per_pmp_shd.g_old_rec.position_structure_id;
  End If;
  If (p_rec.pos_structure_version_id = hr_api.g_number) then
    p_rec.pos_structure_version_id :=
    per_pmp_shd.g_old_rec.pos_structure_version_id;
  End If;
  If (p_rec.top_position_id = hr_api.g_number) then
    p_rec.top_position_id :=
    per_pmp_shd.g_old_rec.top_position_id;
  End If;
  If (p_rec.hierarchy_levels = hr_api.g_number) then
    p_rec.hierarchy_levels :=
    per_pmp_shd.g_old_rec.hierarchy_levels;
  End If;
  If (p_rec.automatic_enrollment_flag = hr_api.g_varchar2) then
    p_rec.automatic_enrollment_flag :=
    per_pmp_shd.g_old_rec.automatic_enrollment_flag;
  End If;
  If (p_rec.assignment_types_code = hr_api.g_varchar2) then
    p_rec.assignment_types_code :=
    per_pmp_shd.g_old_rec.assignment_types_code;
  End If;
  If (p_rec.primary_asg_only_flag = hr_api.g_varchar2) then
    p_rec.primary_asg_only_flag :=
    per_pmp_shd.g_old_rec.primary_asg_only_flag;
  End If;
  If (p_rec.include_obj_setting_flag = hr_api.g_varchar2) then
    p_rec.include_obj_setting_flag :=
    per_pmp_shd.g_old_rec.include_obj_setting_flag;
  End If;
  If (p_rec.obj_setting_start_date = hr_api.g_date) then
    p_rec.obj_setting_start_date :=
    per_pmp_shd.g_old_rec.obj_setting_start_date;
  End If;
  If (p_rec.obj_setting_deadline = hr_api.g_date) then
    p_rec.obj_setting_deadline :=
    per_pmp_shd.g_old_rec.obj_setting_deadline;
  End If;
  If (p_rec.obj_set_outside_period_flag = hr_api.g_varchar2) then
    p_rec.obj_set_outside_period_flag :=
    per_pmp_shd.g_old_rec.obj_set_outside_period_flag;
  End If;
  If (p_rec.method_code = hr_api.g_varchar2) then
    p_rec.method_code :=
    per_pmp_shd.g_old_rec.method_code;
  End If;
  If (p_rec.notify_population_flag = hr_api.g_varchar2) then
    p_rec.notify_population_flag :=
    per_pmp_shd.g_old_rec.notify_population_flag;
  End If;
  If (p_rec.automatic_allocation_flag = hr_api.g_varchar2) then
    p_rec.automatic_allocation_flag :=
    per_pmp_shd.g_old_rec.automatic_allocation_flag;
  End If;
  If (p_rec.copy_past_objectives_flag = hr_api.g_varchar2) then
    p_rec.copy_past_objectives_flag :=
    per_pmp_shd.g_old_rec.copy_past_objectives_flag;
  End If;
  If (p_rec.sharing_alignment_task_flag = hr_api.g_varchar2) then
    p_rec.sharing_alignment_task_flag :=
    per_pmp_shd.g_old_rec.sharing_alignment_task_flag;
  End If;
  If (p_rec.include_appraisals_flag = hr_api.g_varchar2) then
    p_rec.include_appraisals_flag :=
    per_pmp_shd.g_old_rec.include_appraisals_flag;
  End If;

  If (p_rec.change_sc_status_flag = hr_api.g_varchar2) then
    p_rec.change_sc_status_flag :=
    per_pmp_shd.g_old_rec.change_sc_status_flag;
  End If;

  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_pmp_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_pmp_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_pmp_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_pmp_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_pmp_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_pmp_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_pmp_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_pmp_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_pmp_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_pmp_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_pmp_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_pmp_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_pmp_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_pmp_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_pmp_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_pmp_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_pmp_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_pmp_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_pmp_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_pmp_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_pmp_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    per_pmp_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    per_pmp_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    per_pmp_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    per_pmp_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    per_pmp_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    per_pmp_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    per_pmp_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    per_pmp_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    per_pmp_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    per_pmp_shd.g_old_rec.attribute30;
  End If;
   --  8740021 bug fix
  If (p_rec.update_library_objectives = hr_api.g_varchar2) then
    p_rec.update_library_objectives :=
    per_pmp_shd.g_old_rec.update_library_objectives;
  End If;
  If (p_rec.automatic_approval_flag = hr_api.g_varchar2) then
    p_rec.automatic_approval_flag :=
    per_pmp_shd.g_old_rec.automatic_approval_flag;
  End If;
  --

End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_pmp_shd.g_rec_type
  ,p_duplicate_name_warning       out nocopy boolean
  ,p_no_life_events_warning       out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pmp_shd.lck
    (p_rec.plan_id
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
  per_pmp_bus.update_validate
     (p_effective_date
     ,p_rec
     ,p_duplicate_name_warning
     ,p_no_life_events_warning
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_pmp_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pmp_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_pmp_upd.post_update
     (p_effective_date
     ,p_rec
     ,p_duplicate_name_warning
     ,p_no_life_events_warning
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
  ,p_plan_id                      in     number
  ,p_object_version_number        in out nocopy number
  ,p_plan_name                    in     varchar2  default hr_api.g_varchar2
  ,p_administrator_person_id      in     number    default hr_api.g_number
  ,p_previous_plan_id             in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_automatic_enrollment_flag    in     varchar2  default hr_api.g_varchar2
  ,p_assignment_types_code        in     varchar2  default hr_api.g_varchar2
  ,p_primary_asg_only_flag        in     varchar2  default hr_api.g_varchar2
  ,p_include_obj_setting_flag     in     varchar2  default hr_api.g_varchar2
  ,p_obj_set_outside_period_flag  in     varchar2  default hr_api.g_varchar2
  ,p_method_code                  in     varchar2  default hr_api.g_varchar2
  ,p_notify_population_flag       in     varchar2  default hr_api.g_varchar2
  ,p_automatic_allocation_flag    in     varchar2  default hr_api.g_varchar2
  ,p_copy_past_objectives_flag    in     varchar2  default hr_api.g_varchar2
  ,p_sharing_alignment_task_flag  in     varchar2  default hr_api.g_varchar2
  ,p_include_appraisals_flag      in     varchar2  default hr_api.g_varchar2
  ,p_hierarchy_type_code          in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_supervisor_assignment_id     in     number    default hr_api.g_number
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_org_structure_version_id     in     number    default hr_api.g_number
  ,p_top_organization_id          in     number    default hr_api.g_number
  ,p_position_structure_id        in     number    default hr_api.g_number
  ,p_pos_structure_version_id     in     number    default hr_api.g_number
  ,p_top_position_id              in     number    default hr_api.g_number
  ,p_hierarchy_levels             in     number    default hr_api.g_number
  ,p_obj_setting_start_date       in     date      default hr_api.g_date
  ,p_obj_setting_deadline         in     date      default hr_api.g_date
  ,p_change_sc_status_flag in     varchar2  default hr_api.g_varchar2
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
  ,p_status_code                  in out nocopy varchar2
  ,p_duplicate_name_warning          out nocopy boolean
  ,p_no_life_events_warning          out nocopy boolean
  ,p_update_library_objectives in varchar2  default hr_api.g_varchar2     -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   per_pmp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
  l_duplicate_name_warning       boolean;
  l_no_life_events_warning       boolean;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pmp_shd.convert_args
  (p_plan_id
  ,p_object_version_number
  ,p_plan_name
  ,p_administrator_person_id
  ,p_previous_plan_id
  ,p_start_date
  ,p_end_date
  ,p_status_code
  ,p_hierarchy_type_code
  ,p_supervisor_id
  ,p_supervisor_assignment_id
  ,p_organization_structure_id
  ,p_org_structure_version_id
  ,p_top_organization_id
  ,p_position_structure_id
  ,p_pos_structure_version_id
  ,p_top_position_id
  ,p_hierarchy_levels
  ,p_automatic_enrollment_flag
  ,p_assignment_types_code
  ,p_primary_asg_only_flag
  ,p_include_obj_setting_flag
  ,p_obj_setting_start_date
  ,p_obj_setting_deadline
  ,p_obj_set_outside_period_flag
  ,p_method_code
  ,p_notify_population_flag
  ,p_automatic_allocation_flag
  ,p_copy_past_objectives_flag
  ,p_sharing_alignment_task_flag
  ,p_include_appraisals_flag
  ,p_change_sc_status_flag
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
  ,p_update_library_objectives --  8740021 bug fix
  ,p_automatic_approval_flag
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pmp_upd.upd
     (p_effective_date
     ,l_rec
     ,l_duplicate_name_warning
     ,l_no_life_events_warning
     );
  p_object_version_number   := l_rec.object_version_number;
  p_status_code             := l_rec.status_code;
  p_duplicate_name_warning  := l_duplicate_name_warning;
  p_no_life_events_warning  := l_no_life_events_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pmp_upd;

/
