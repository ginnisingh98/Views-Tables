--------------------------------------------------------
--  DDL for Package Body PER_PAT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PAT_UPD" as
/* $Header: pepatrhi.pkb 120.2 2005/10/27 07:56 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pat_upd.';  -- Global package name
g_debug   boolean      := hr_utility.debug_enabled;
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
  (p_rec in out nocopy per_pat_shd.g_rec_type
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
  --
  -- Update the per_allocated_tasks Row
  --
  update per_allocated_tasks
    set
     allocated_task_id               = p_rec.allocated_task_id
    ,allocated_checklist_id          = p_rec.allocated_checklist_id
    ,task_name                       = p_rec.task_name
    ,description                     = p_rec.description
    ,performer_orig_system           = p_rec.performer_orig_system
    ,performer_orig_sys_id           = p_rec.performer_orig_sys_id
    ,task_owner_person_id            = p_rec.task_owner_person_id
    ,task_sequence                   = p_rec.task_sequence
    ,target_start_date               = p_rec.target_start_date
    ,target_end_date                 = p_rec.target_end_date
    ,actual_start_date               = p_rec.actual_start_date
    ,actual_end_date                 = p_rec.actual_end_date
    ,action_url                      = p_rec.action_url
    ,mandatory_flag                  = p_rec.mandatory_flag
    ,status                          = p_rec.status
    ,object_version_number           = p_rec.object_version_number
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
    ,information_category            = p_rec.information_category
    ,information1                    = p_rec.information1
    ,information2                    = p_rec.information2
    ,information3                    = p_rec.information3
    ,information4                    = p_rec.information4
    ,information5                    = p_rec.information5
    ,information6                    = p_rec.information6
    ,information7                    = p_rec.information7
    ,information8                    = p_rec.information8
    ,information9                    = p_rec.information9
    ,information10                   = p_rec.information10
    ,information11                   = p_rec.information11
    ,information12                   = p_rec.information12
    ,information13                   = p_rec.information13
    ,information14                   = p_rec.information14
    ,information15                   = p_rec.information15
    ,information16                   = p_rec.information16
    ,information17                   = p_rec.information17
    ,information18                   = p_rec.information18
    ,information19                   = p_rec.information19
    ,information20                   = p_rec.information20
    where allocated_task_id = p_rec.allocated_task_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pat_shd.constraint_error
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
  (p_rec in per_pat_shd.g_rec_type
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
  ,p_rec                          in per_pat_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pat_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_allocated_task_id
      => p_rec.allocated_task_id
      ,p_allocated_checklist_id
      => p_rec.allocated_checklist_id
      ,p_task_name
      => p_rec.task_name
      ,p_description
      => p_rec.description
      ,p_performer_orig_system
      => p_rec.performer_orig_system
      ,p_performer_orig_sys_id
      => p_rec.performer_orig_sys_id
      ,p_task_owner_person_id
      => p_rec.task_owner_person_id
      ,p_task_sequence
      => p_rec.task_sequence
      ,p_target_start_date
      => p_rec.target_start_date
      ,p_target_end_date
      => p_rec.target_end_date
      ,p_actual_start_date
      => p_rec.actual_start_date
      ,p_actual_end_date
      => p_rec.actual_end_date
      ,p_action_url
      => p_rec.action_url
      ,p_mandatory_flag
      => p_rec.mandatory_flag
      ,p_status
      => p_rec.status
      ,p_object_version_number
      => p_rec.object_version_number
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
      ,p_information_category
      => p_rec.information_category
      ,p_information1
      => p_rec.information1
      ,p_information2
      => p_rec.information2
      ,p_information3
      => p_rec.information3
      ,p_information4
      => p_rec.information4
      ,p_information5
      => p_rec.information5
      ,p_information6
      => p_rec.information6
      ,p_information7
      => p_rec.information7
      ,p_information8
      => p_rec.information8
      ,p_information9
      => p_rec.information9
      ,p_information10
      => p_rec.information10
      ,p_information11
      => p_rec.information11
      ,p_information12
      => p_rec.information12
      ,p_information13
      => p_rec.information13
      ,p_information14
      => p_rec.information14
      ,p_information15
      => p_rec.information15
      ,p_information16
      => p_rec.information16
      ,p_information17
      => p_rec.information17
      ,p_information18
      => p_rec.information18
      ,p_information19
      => p_rec.information19
      ,p_information20
      => p_rec.information20
      ,p_allocated_checklist_id_o
      => per_pat_shd.g_old_rec.allocated_checklist_id
      ,p_task_name_o
      => per_pat_shd.g_old_rec.task_name
      ,p_description_o
      => per_pat_shd.g_old_rec.description
      ,p_performer_orig_system_o
      => per_pat_shd.g_old_rec.performer_orig_system
      ,p_performer_orig_sys_id_o
      => per_pat_shd.g_old_rec.performer_orig_sys_id
      ,p_task_owner_person_id_o
      => per_pat_shd.g_old_rec.task_owner_person_id
      ,p_task_sequence_o
      => per_pat_shd.g_old_rec.task_sequence
      ,p_target_start_date_o
      => per_pat_shd.g_old_rec.target_start_date
      ,p_target_end_date_o
      => per_pat_shd.g_old_rec.target_end_date
      ,p_actual_start_date_o
      => per_pat_shd.g_old_rec.actual_start_date
      ,p_actual_end_date_o
      => per_pat_shd.g_old_rec.actual_end_date
      ,p_action_url_o
      => per_pat_shd.g_old_rec.action_url
      ,p_mandatory_flag_o
      => per_pat_shd.g_old_rec.mandatory_flag
      ,p_status_o
      => per_pat_shd.g_old_rec.status
      ,p_object_version_number_o
      => per_pat_shd.g_old_rec.object_version_number
      ,p_attribute_category_o
      => per_pat_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_pat_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_pat_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_pat_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_pat_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_pat_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_pat_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_pat_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_pat_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_pat_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_pat_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_pat_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_pat_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_pat_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_pat_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_pat_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_pat_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_pat_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_pat_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_pat_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_pat_shd.g_old_rec.attribute20
      ,p_information_category_o
      => per_pat_shd.g_old_rec.information_category
      ,p_information1_o
      => per_pat_shd.g_old_rec.information1
      ,p_information2_o
      => per_pat_shd.g_old_rec.information2
      ,p_information3_o
      => per_pat_shd.g_old_rec.information3
      ,p_information4_o
      => per_pat_shd.g_old_rec.information4
      ,p_information5_o
      => per_pat_shd.g_old_rec.information5
      ,p_information6_o
      => per_pat_shd.g_old_rec.information6
      ,p_information7_o
      => per_pat_shd.g_old_rec.information7
      ,p_information8_o
      => per_pat_shd.g_old_rec.information8
      ,p_information9_o
      => per_pat_shd.g_old_rec.information9
      ,p_information10_o
      => per_pat_shd.g_old_rec.information10
      ,p_information11_o
      => per_pat_shd.g_old_rec.information11
      ,p_information12_o
      => per_pat_shd.g_old_rec.information12
      ,p_information13_o
      => per_pat_shd.g_old_rec.information13
      ,p_information14_o
      => per_pat_shd.g_old_rec.information14
      ,p_information15_o
      => per_pat_shd.g_old_rec.information15
      ,p_information16_o
      => per_pat_shd.g_old_rec.information16
      ,p_information17_o
      => per_pat_shd.g_old_rec.information17
      ,p_information18_o
      => per_pat_shd.g_old_rec.information18
      ,p_information19_o
      => per_pat_shd.g_old_rec.information19
      ,p_information20_o
      => per_pat_shd.g_old_rec.information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ALLOCATED_TASKS'
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
  (p_rec in out nocopy per_pat_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.allocated_checklist_id = hr_api.g_number) then
    p_rec.allocated_checklist_id :=
    per_pat_shd.g_old_rec.allocated_checklist_id;
  End If;
  If (p_rec.task_name = hr_api.g_varchar2) then
    p_rec.task_name :=
    per_pat_shd.g_old_rec.task_name;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    per_pat_shd.g_old_rec.description;
  End If;
  If (p_rec.performer_orig_system = hr_api.g_varchar2) then
    p_rec.performer_orig_system :=
    per_pat_shd.g_old_rec.performer_orig_system;
  End If;
  If (p_rec.performer_orig_sys_id = hr_api.g_number) then
    p_rec.performer_orig_sys_id :=
    per_pat_shd.g_old_rec.performer_orig_sys_id;
  End If;
  If (p_rec.task_owner_person_id = hr_api.g_number) then
    p_rec.task_owner_person_id :=
    per_pat_shd.g_old_rec.task_owner_person_id;
  End If;
  If (p_rec.task_sequence = hr_api.g_number) then
    p_rec.task_sequence :=
    per_pat_shd.g_old_rec.task_sequence;
  End If;
  If (p_rec.target_start_date = hr_api.g_date) then
    p_rec.target_start_date :=
    per_pat_shd.g_old_rec.target_start_date;
  End If;
  If (p_rec.target_end_date = hr_api.g_date) then
    p_rec.target_end_date :=
    per_pat_shd.g_old_rec.target_end_date;
  End If;
  If (p_rec.actual_start_date = hr_api.g_date) then
    p_rec.actual_start_date :=
    per_pat_shd.g_old_rec.actual_start_date;
  End If;
  If (p_rec.actual_end_date = hr_api.g_date) then
    p_rec.actual_end_date :=
    per_pat_shd.g_old_rec.actual_end_date;
  End If;
  If (p_rec.action_url = hr_api.g_varchar2) then
    p_rec.action_url :=
    per_pat_shd.g_old_rec.action_url;
  End If;
  If (p_rec.mandatory_flag = hr_api.g_varchar2) then
    p_rec.mandatory_flag :=
    per_pat_shd.g_old_rec.mandatory_flag;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    per_pat_shd.g_old_rec.status;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_pat_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_pat_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_pat_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_pat_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_pat_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_pat_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_pat_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_pat_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_pat_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_pat_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_pat_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_pat_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_pat_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_pat_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_pat_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_pat_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_pat_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_pat_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_pat_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_pat_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_pat_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    per_pat_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    per_pat_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    per_pat_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    per_pat_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    per_pat_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    per_pat_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    per_pat_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    per_pat_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    per_pat_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    per_pat_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    per_pat_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    per_pat_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    per_pat_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    per_pat_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    per_pat_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    per_pat_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    per_pat_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    per_pat_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    per_pat_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    per_pat_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    per_pat_shd.g_old_rec.information20;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_pat_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pat_shd.lck
    (p_rec.allocated_task_id
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
  per_pat_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_pat_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pat_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_pat_upd.post_update
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
  ,p_allocated_task_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_allocated_checklist_id       in     number    default hr_api.g_number
  ,p_task_name                    in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_performer_orig_system        in     varchar2  default hr_api.g_varchar2
  ,p_performer_orig_sys_id     in     number    default hr_api.g_number
  ,p_task_owner_person_id         in     number    default hr_api.g_number
  ,p_task_sequence                in     number    default hr_api.g_number
  ,p_target_start_date            in     date      default hr_api.g_date
  ,p_target_end_date              in     date      default hr_api.g_date
  ,p_actual_start_date            in     date      default hr_api.g_date
  ,p_actual_end_date              in     date      default hr_api.g_date
  ,p_action_url                   in     varchar2  default hr_api.g_varchar2
  ,p_mandatory_flag               in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
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
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   per_pat_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pat_shd.convert_args
  (p_allocated_task_id
  ,p_allocated_checklist_id
  ,p_task_name
  ,p_description
  ,p_performer_orig_system
  ,p_performer_orig_sys_id
  ,p_task_owner_person_id
  ,p_task_sequence
  ,p_target_start_date
  ,p_target_end_date
  ,p_actual_start_date
  ,p_actual_end_date
  ,p_action_url
  ,p_mandatory_flag
  ,p_status
  ,p_object_version_number
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
  ,p_information_category
  ,p_information1
  ,p_information2
  ,p_information3
  ,p_information4
  ,p_information5
  ,p_information6
  ,p_information7
  ,p_information8
  ,p_information9
  ,p_information10
  ,p_information11
  ,p_information12
  ,p_information13
  ,p_information14
  ,p_information15
  ,p_information16
  ,p_information17
  ,p_information18
  ,p_information19
  ,p_information20
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pat_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pat_upd;

/
