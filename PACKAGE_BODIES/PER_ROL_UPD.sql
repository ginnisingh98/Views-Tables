--------------------------------------------------------
--  DDL for Package Body PER_ROL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ROL_UPD" as
/* $Header: perolrhi.pkb 120.0 2005/05/31 18:34:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rol_upd.';  -- Global package name
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
  (p_rec in out nocopy per_rol_shd.g_rec_type
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
  -- Update the per_roles Row
  --
  update per_roles
    set
     role_id                         = p_rec.role_id
    ,job_id                          = p_rec.job_id
    ,job_group_id                    = p_rec.job_group_id
    ,person_id                       = p_rec.person_id
    ,organization_id                 = p_rec.organization_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,confidential_date               = p_rec.confidential_date
    ,emp_rights_flag                 = p_rec.emp_rights_flag
    ,end_of_rights_date              = p_rec.end_of_rights_date
    ,primary_contact_flag            = p_rec.primary_contact_flag
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
    ,role_information_category       = p_rec.role_information_category
    ,role_information1               = p_rec.role_information1
    ,role_information2               = p_rec.role_information2
    ,role_information3               = p_rec.role_information3
    ,role_information4               = p_rec.role_information4
    ,role_information5               = p_rec.role_information5
    ,role_information6               = p_rec.role_information6
    ,role_information7               = p_rec.role_information7
    ,role_information8               = p_rec.role_information8
    ,role_information9               = p_rec.role_information9
    ,role_information10              = p_rec.role_information10
    ,role_information11              = p_rec.role_information11
    ,role_information12              = p_rec.role_information12
    ,role_information13              = p_rec.role_information13
    ,role_information14              = p_rec.role_information14
    ,role_information15              = p_rec.role_information15
    ,role_information16              = p_rec.role_information16
    ,role_information17              = p_rec.role_information17
    ,role_information18              = p_rec.role_information18
    ,role_information19              = p_rec.role_information19
    ,role_information20              = p_rec.role_information20
    ,object_version_number           = p_rec.object_version_number
    ,old_end_date                    = p_rec.old_end_date -- fix 1370960
    where role_id = p_rec.role_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_rol_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_rol_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_rol_shd.constraint_error
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
  (p_rec in per_rol_shd.g_rec_type
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
  ,p_rec                          in per_rol_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_rol_rku.after_update
      (p_effective_date
    => p_effective_date
      ,p_role_id
      => p_rec.role_id
    ,p_job_id
    => p_rec.job_id
    ,p_job_group_id
    => p_rec.job_group_id
    ,p_person_id
    => p_rec.person_id
    ,p_organization_id
    => p_rec.organization_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_confidential_date
      => p_rec.confidential_date
      ,p_emp_rights_flag
      => p_rec.emp_rights_flag
      ,p_end_of_rights_date
      => p_rec.end_of_rights_date
      ,p_primary_contact_flag
      => p_rec.primary_contact_flag
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
      ,p_role_information_category
      => p_rec.role_information_category
      ,p_role_information1
      => p_rec.role_information1
      ,p_role_information2
      => p_rec.role_information2
      ,p_role_information3
      => p_rec.role_information3
      ,p_role_information4
      => p_rec.role_information4
      ,p_role_information5
      => p_rec.role_information5
      ,p_role_information6
      => p_rec.role_information6
      ,p_role_information7
      => p_rec.role_information7
      ,p_role_information8
      => p_rec.role_information8
      ,p_role_information9
      => p_rec.role_information9
      ,p_role_information10
      => p_rec.role_information10
      ,p_role_information11
      => p_rec.role_information11
      ,p_role_information12
      => p_rec.role_information12
      ,p_role_information13
      => p_rec.role_information13
      ,p_role_information14
      => p_rec.role_information14
      ,p_role_information15
      => p_rec.role_information15
      ,p_role_information16
      => p_rec.role_information16
      ,p_role_information17
      => p_rec.role_information17
      ,p_role_information18
      => p_rec.role_information18
      ,p_role_information19
      => p_rec.role_information19
      ,p_role_information20
      => p_rec.role_information20
      ,p_object_version_number
      => p_rec.object_version_number
    ,p_job_id_o
    => per_rol_shd.g_old_rec.job_id
    ,p_job_group_id_o
    => per_rol_shd.g_old_rec.job_group_id
    ,p_person_id_o
    => per_rol_shd.g_old_rec.person_id
    ,p_organization_id_o
    => per_rol_shd.g_old_rec.organization_id
      ,p_start_date_o
      => per_rol_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_rol_shd.g_old_rec.end_date
      ,p_confidential_date_o
      => per_rol_shd.g_old_rec.confidential_date
      ,p_emp_rights_flag_o
      => per_rol_shd.g_old_rec.emp_rights_flag
      ,p_end_of_rights_date_o
      => per_rol_shd.g_old_rec.end_of_rights_date
      ,p_primary_contact_flag_o
      => per_rol_shd.g_old_rec.primary_contact_flag
      ,p_attribute_category_o
      => per_rol_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_rol_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_rol_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_rol_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_rol_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_rol_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_rol_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_rol_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_rol_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_rol_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_rol_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_rol_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_rol_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_rol_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_rol_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_rol_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_rol_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_rol_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_rol_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_rol_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_rol_shd.g_old_rec.attribute20
      ,p_role_information_category_o
      => per_rol_shd.g_old_rec.role_information_category
      ,p_role_information1_o
      => per_rol_shd.g_old_rec.role_information1
      ,p_role_information2_o
      => per_rol_shd.g_old_rec.role_information2
      ,p_role_information3_o
      => per_rol_shd.g_old_rec.role_information3
      ,p_role_information4_o
      => per_rol_shd.g_old_rec.role_information4
      ,p_role_information5_o
      => per_rol_shd.g_old_rec.role_information5
      ,p_role_information6_o
      => per_rol_shd.g_old_rec.role_information6
      ,p_role_information7_o
      => per_rol_shd.g_old_rec.role_information7
      ,p_role_information8_o
      => per_rol_shd.g_old_rec.role_information8
      ,p_role_information9_o
      => per_rol_shd.g_old_rec.role_information9
      ,p_role_information10_o
      => per_rol_shd.g_old_rec.role_information10
      ,p_role_information11_o
      => per_rol_shd.g_old_rec.role_information11
      ,p_role_information12_o
      => per_rol_shd.g_old_rec.role_information12
      ,p_role_information13_o
      => per_rol_shd.g_old_rec.role_information13
      ,p_role_information14_o
      => per_rol_shd.g_old_rec.role_information14
      ,p_role_information15_o
      => per_rol_shd.g_old_rec.role_information15
      ,p_role_information16_o
      => per_rol_shd.g_old_rec.role_information16
      ,p_role_information17_o
      => per_rol_shd.g_old_rec.role_information17
      ,p_role_information18_o
      => per_rol_shd.g_old_rec.role_information18
      ,p_role_information19_o
      => per_rol_shd.g_old_rec.role_information19
      ,p_role_information20_o
      => per_rol_shd.g_old_rec.role_information20
      ,p_object_version_number_o
      => per_rol_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ROLES'
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
  (p_rec in out nocopy per_rol_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    per_rol_shd.g_old_rec.job_id;
  End If;
  If (p_rec.job_group_id = hr_api.g_number) then
    p_rec.job_group_id :=
    per_rol_shd.g_old_rec.job_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_rol_shd.g_old_rec.person_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    per_rol_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_rol_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_rol_shd.g_old_rec.end_date;
  End If;
  If (p_rec.confidential_date = hr_api.g_date) then
    p_rec.confidential_date :=
    per_rol_shd.g_old_rec.confidential_date;
  End If;
  If (p_rec.emp_rights_flag = hr_api.g_varchar2) then
    p_rec.emp_rights_flag :=
    per_rol_shd.g_old_rec.emp_rights_flag;
  End If;
  If (p_rec.end_of_rights_date = hr_api.g_date) then
    p_rec.end_of_rights_date :=
    per_rol_shd.g_old_rec.end_of_rights_date;
  End If;
  If (p_rec.primary_contact_flag = hr_api.g_varchar2) then
    p_rec.primary_contact_flag :=
    per_rol_shd.g_old_rec.primary_contact_flag;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_rol_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_rol_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_rol_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_rol_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_rol_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_rol_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_rol_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_rol_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_rol_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_rol_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_rol_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_rol_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_rol_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_rol_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_rol_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_rol_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_rol_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_rol_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_rol_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_rol_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_rol_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.role_information_category = hr_api.g_varchar2) then
    p_rec.role_information_category :=
    per_rol_shd.g_old_rec.role_information_category;
  End If;
  If (p_rec.role_information1 = hr_api.g_varchar2) then
    p_rec.role_information1 :=
    per_rol_shd.g_old_rec.role_information1;
  End If;
  If (p_rec.role_information2 = hr_api.g_varchar2) then
    p_rec.role_information2 :=
    per_rol_shd.g_old_rec.role_information2;
  End If;
  If (p_rec.role_information3 = hr_api.g_varchar2) then
    p_rec.role_information3 :=
    per_rol_shd.g_old_rec.role_information3;
  End If;
  If (p_rec.role_information4 = hr_api.g_varchar2) then
    p_rec.role_information4 :=
    per_rol_shd.g_old_rec.role_information4;
  End If;
  If (p_rec.role_information5 = hr_api.g_varchar2) then
    p_rec.role_information5 :=
    per_rol_shd.g_old_rec.role_information5;
  End If;
  If (p_rec.role_information6 = hr_api.g_varchar2) then
    p_rec.role_information6 :=
    per_rol_shd.g_old_rec.role_information6;
  End If;
  If (p_rec.role_information7 = hr_api.g_varchar2) then
    p_rec.role_information7 :=
    per_rol_shd.g_old_rec.role_information7;
  End If;
  If (p_rec.role_information8 = hr_api.g_varchar2) then
    p_rec.role_information8 :=
    per_rol_shd.g_old_rec.role_information8;
  End If;
  If (p_rec.role_information9 = hr_api.g_varchar2) then
    p_rec.role_information9 :=
    per_rol_shd.g_old_rec.role_information9;
  End If;
  If (p_rec.role_information10 = hr_api.g_varchar2) then
    p_rec.role_information10 :=
    per_rol_shd.g_old_rec.role_information10;
  End If;
  If (p_rec.role_information11 = hr_api.g_varchar2) then
    p_rec.role_information11 :=
    per_rol_shd.g_old_rec.role_information11;
  End If;
  If (p_rec.role_information12 = hr_api.g_varchar2) then
    p_rec.role_information12 :=
    per_rol_shd.g_old_rec.role_information12;
  End If;
  If (p_rec.role_information13 = hr_api.g_varchar2) then
    p_rec.role_information13 :=
    per_rol_shd.g_old_rec.role_information13;
  End If;
  If (p_rec.role_information14 = hr_api.g_varchar2) then
    p_rec.role_information14 :=
    per_rol_shd.g_old_rec.role_information14;
  End If;
  If (p_rec.role_information15 = hr_api.g_varchar2) then
    p_rec.role_information15 :=
    per_rol_shd.g_old_rec.role_information15;
  End If;
  If (p_rec.role_information16 = hr_api.g_varchar2) then
    p_rec.role_information16 :=
    per_rol_shd.g_old_rec.role_information16;
  End If;
  If (p_rec.role_information17 = hr_api.g_varchar2) then
    p_rec.role_information17 :=
    per_rol_shd.g_old_rec.role_information17;
  End If;
  If (p_rec.role_information18 = hr_api.g_varchar2) then
    p_rec.role_information18 :=
    per_rol_shd.g_old_rec.role_information18;
  End If;
  If (p_rec.role_information19 = hr_api.g_varchar2) then
    p_rec.role_information19 :=
    per_rol_shd.g_old_rec.role_information19;
  End If;
  If (p_rec.role_information20 = hr_api.g_varchar2) then
    p_rec.role_information20 :=
    per_rol_shd.g_old_rec.role_information20;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_rol_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_rol_shd.lck
    (p_rec.role_id
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
  per_rol_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  per_rol_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_rol_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_rol_upd.post_update
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
  ,p_role_id                      in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_confidential_date            in     date      default hr_api.g_date
  ,p_emp_rights_flag              in     varchar2  default hr_api.g_varchar2
  ,p_end_of_rights_date           in     date      default hr_api.g_date
  ,p_primary_contact_flag         in     varchar2  default hr_api.g_varchar2
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
  ,p_role_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_role_information1            in     varchar2  default hr_api.g_varchar2
  ,p_role_information2            in     varchar2  default hr_api.g_varchar2
  ,p_role_information3            in     varchar2  default hr_api.g_varchar2
  ,p_role_information4            in     varchar2  default hr_api.g_varchar2
  ,p_role_information5            in     varchar2  default hr_api.g_varchar2
  ,p_role_information6            in     varchar2  default hr_api.g_varchar2
  ,p_role_information7            in     varchar2  default hr_api.g_varchar2
  ,p_role_information8            in     varchar2  default hr_api.g_varchar2
  ,p_role_information9            in     varchar2  default hr_api.g_varchar2
  ,p_role_information10           in     varchar2  default hr_api.g_varchar2
  ,p_role_information11           in     varchar2  default hr_api.g_varchar2
  ,p_role_information12           in     varchar2  default hr_api.g_varchar2
  ,p_role_information13           in     varchar2  default hr_api.g_varchar2
  ,p_role_information14           in     varchar2  default hr_api.g_varchar2
  ,p_role_information15           in     varchar2  default hr_api.g_varchar2
  ,p_role_information16           in     varchar2  default hr_api.g_varchar2
  ,p_role_information17           in     varchar2  default hr_api.g_varchar2
  ,p_role_information18           in     varchar2  default hr_api.g_varchar2
  ,p_role_information19           in     varchar2  default hr_api.g_varchar2
  ,p_role_information20           in     varchar2  default hr_api.g_varchar2
  ,p_old_end_date                 in     date      default hr_api.g_date     -- fix 1370960
  ) is
--
  l_rec    per_rol_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_rol_shd.convert_args
  (p_role_id
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,hr_api.g_number
  ,p_start_date
  ,p_end_date
  ,p_confidential_date
  ,p_emp_rights_flag
  ,p_end_of_rights_date
  ,p_primary_contact_flag
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
  ,p_role_information_category
  ,p_role_information1
  ,p_role_information2
  ,p_role_information3
  ,p_role_information4
  ,p_role_information5
  ,p_role_information6
  ,p_role_information7
  ,p_role_information8
  ,p_role_information9
  ,p_role_information10
  ,p_role_information11
  ,p_role_information12
  ,p_role_information13
  ,p_role_information14
  ,p_role_information15
  ,p_role_information16
  ,p_role_information17
  ,p_role_information18
  ,p_role_information19
  ,p_role_information20
  ,p_object_version_number
  ,p_old_end_date -- fix 1370960
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_rol_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_rol_upd;

/
