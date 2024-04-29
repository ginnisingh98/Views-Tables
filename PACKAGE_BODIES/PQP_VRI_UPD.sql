--------------------------------------------------------
--  DDL for Package Body PQP_VRI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRI_UPD" as
/* $Header: pqvrirhi.pkb 120.0.12010000.2 2008/08/08 07:24:11 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vri_upd.';  -- Global package name
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
  (p_rec in out nocopy pqp_vri_shd.g_rec_type
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
  pqp_vri_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqp_veh_repos_extra_info Row
  --
  update pqp_veh_repos_extra_info
    set
     veh_repos_extra_info_id         = p_rec.veh_repos_extra_info_id
    ,vehicle_repository_id           = p_rec.vehicle_repository_id
    ,information_type                = p_rec.information_type
    ,vrei_attribute_category         = p_rec.vrei_attribute_category
    ,vrei_attribute1                 = p_rec.vrei_attribute1
    ,vrei_attribute2                 = p_rec.vrei_attribute2
    ,vrei_attribute3                 = p_rec.vrei_attribute3
    ,vrei_attribute4                 = p_rec.vrei_attribute4
    ,vrei_attribute5                 = p_rec.vrei_attribute5
    ,vrei_attribute6                 = p_rec.vrei_attribute6
    ,vrei_attribute7                 = p_rec.vrei_attribute7
    ,vrei_attribute8                 = p_rec.vrei_attribute8
    ,vrei_attribute9                 = p_rec.vrei_attribute9
    ,vrei_attribute10                = p_rec.vrei_attribute10
    ,vrei_attribute11                = p_rec.vrei_attribute11
    ,vrei_attribute12                = p_rec.vrei_attribute12
    ,vrei_attribute13                = p_rec.vrei_attribute13
    ,vrei_attribute14                = p_rec.vrei_attribute14
    ,vrei_attribute15                = p_rec.vrei_attribute15
    ,vrei_attribute16                = p_rec.vrei_attribute16
    ,vrei_attribute17                = p_rec.vrei_attribute17
    ,vrei_attribute18                = p_rec.vrei_attribute18
    ,vrei_attribute19                = p_rec.vrei_attribute19
    ,vrei_attribute20                = p_rec.vrei_attribute20
    ,vrei_information_category       = p_rec.vrei_information_category
    ,vrei_information1               = p_rec.vrei_information1
    ,vrei_information2               = p_rec.vrei_information2
    ,vrei_information3               = p_rec.vrei_information3
    ,vrei_information4               = p_rec.vrei_information4
    ,vrei_information5               = p_rec.vrei_information5
    ,vrei_information6               = p_rec.vrei_information6
    ,vrei_information7               = p_rec.vrei_information7
    ,vrei_information8               = p_rec.vrei_information8
    ,vrei_information9               = p_rec.vrei_information9
    ,vrei_information10              = p_rec.vrei_information10
    ,vrei_information11              = p_rec.vrei_information11
    ,vrei_information12              = p_rec.vrei_information12
    ,vrei_information13              = p_rec.vrei_information13
    ,vrei_information14              = p_rec.vrei_information14
    ,vrei_information15              = p_rec.vrei_information15
    ,vrei_information16              = p_rec.vrei_information16
    ,vrei_information17              = p_rec.vrei_information17
    ,vrei_information18              = p_rec.vrei_information18
    ,vrei_information19              = p_rec.vrei_information19
    ,vrei_information20              = p_rec.vrei_information20
    ,vrei_information21              = p_rec.vrei_information21
    ,vrei_information22              = p_rec.vrei_information22
    ,vrei_information23              = p_rec.vrei_information23
    ,vrei_information24              = p_rec.vrei_information24
    ,vrei_information25              = p_rec.vrei_information25
    ,vrei_information26              = p_rec.vrei_information26
    ,vrei_information27              = p_rec.vrei_information27
    ,vrei_information28              = p_rec.vrei_information28
    ,vrei_information29              = p_rec.vrei_information29
    ,vrei_information30              = p_rec.vrei_information30
    ,object_version_number           = p_rec.object_version_number
    ,request_id                      = p_rec.request_id
    ,program_application_id          = p_rec.program_application_id
    ,program_id                      = p_rec.program_id
    ,program_update_date             = p_rec.program_update_date
    where veh_repos_extra_info_id = p_rec.veh_repos_extra_info_id;
  --
  pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vri_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vri_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vri_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pqp_vri_shd.g_rec_type
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
  (p_rec                          in pqp_vri_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_vri_rku.after_update
      (p_veh_repos_extra_info_id
      => p_rec.veh_repos_extra_info_id
      ,p_vehicle_repository_id
      => p_rec.vehicle_repository_id
      ,p_information_type
      => p_rec.information_type
      ,p_vrei_attribute_category
      => p_rec.vrei_attribute_category
      ,p_vrei_attribute1
      => p_rec.vrei_attribute1
      ,p_vrei_attribute2
      => p_rec.vrei_attribute2
      ,p_vrei_attribute3
      => p_rec.vrei_attribute3
      ,p_vrei_attribute4
      => p_rec.vrei_attribute4
      ,p_vrei_attribute5
      => p_rec.vrei_attribute5
      ,p_vrei_attribute6
      => p_rec.vrei_attribute6
      ,p_vrei_attribute7
      => p_rec.vrei_attribute7
      ,p_vrei_attribute8
      => p_rec.vrei_attribute8
      ,p_vrei_attribute9
      => p_rec.vrei_attribute9
      ,p_vrei_attribute10
      => p_rec.vrei_attribute10
      ,p_vrei_attribute11
      => p_rec.vrei_attribute11
      ,p_vrei_attribute12
      => p_rec.vrei_attribute12
      ,p_vrei_attribute13
      => p_rec.vrei_attribute13
      ,p_vrei_attribute14
      => p_rec.vrei_attribute14
      ,p_vrei_attribute15
      => p_rec.vrei_attribute15
      ,p_vrei_attribute16
      => p_rec.vrei_attribute16
      ,p_vrei_attribute17
      => p_rec.vrei_attribute17
      ,p_vrei_attribute18
      => p_rec.vrei_attribute18
      ,p_vrei_attribute19
      => p_rec.vrei_attribute19
      ,p_vrei_attribute20
      => p_rec.vrei_attribute20
      ,p_vrei_information_category
      => p_rec.vrei_information_category
      ,p_vrei_information1
      => p_rec.vrei_information1
      ,p_vrei_information2
      => p_rec.vrei_information2
      ,p_vrei_information3
      => p_rec.vrei_information3
      ,p_vrei_information4
      => p_rec.vrei_information4
      ,p_vrei_information5
      => p_rec.vrei_information5
      ,p_vrei_information6
      => p_rec.vrei_information6
      ,p_vrei_information7
      => p_rec.vrei_information7
      ,p_vrei_information8
      => p_rec.vrei_information8
      ,p_vrei_information9
      => p_rec.vrei_information9
      ,p_vrei_information10
      => p_rec.vrei_information10
      ,p_vrei_information11
      => p_rec.vrei_information11
      ,p_vrei_information12
      => p_rec.vrei_information12
      ,p_vrei_information13
      => p_rec.vrei_information13
      ,p_vrei_information14
      => p_rec.vrei_information14
      ,p_vrei_information15
      => p_rec.vrei_information15
      ,p_vrei_information16
      => p_rec.vrei_information16
      ,p_vrei_information17
      => p_rec.vrei_information17
      ,p_vrei_information18
      => p_rec.vrei_information18
      ,p_vrei_information19
      => p_rec.vrei_information19
      ,p_vrei_information20
      => p_rec.vrei_information20
      ,p_vrei_information21
      => p_rec.vrei_information21
      ,p_vrei_information22
      => p_rec.vrei_information22
      ,p_vrei_information23
      => p_rec.vrei_information23
      ,p_vrei_information24
      => p_rec.vrei_information24
      ,p_vrei_information25
      => p_rec.vrei_information25
      ,p_vrei_information26
      => p_rec.vrei_information26
      ,p_vrei_information27
      => p_rec.vrei_information27
      ,p_vrei_information28
      => p_rec.vrei_information28
      ,p_vrei_information29
      => p_rec.vrei_information29
      ,p_vrei_information30
      => p_rec.vrei_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_vehicle_repository_id_o
      => pqp_vri_shd.g_old_rec.vehicle_repository_id
      ,p_information_type_o
      => pqp_vri_shd.g_old_rec.information_type
      ,p_vrei_attribute_category_o
      => pqp_vri_shd.g_old_rec.vrei_attribute_category
      ,p_vrei_attribute1_o
      => pqp_vri_shd.g_old_rec.vrei_attribute1
      ,p_vrei_attribute2_o
      => pqp_vri_shd.g_old_rec.vrei_attribute2
      ,p_vrei_attribute3_o
      => pqp_vri_shd.g_old_rec.vrei_attribute3
      ,p_vrei_attribute4_o
      => pqp_vri_shd.g_old_rec.vrei_attribute4
      ,p_vrei_attribute5_o
      => pqp_vri_shd.g_old_rec.vrei_attribute5
      ,p_vrei_attribute6_o
      => pqp_vri_shd.g_old_rec.vrei_attribute6
      ,p_vrei_attribute7_o
      => pqp_vri_shd.g_old_rec.vrei_attribute7
      ,p_vrei_attribute8_o
      => pqp_vri_shd.g_old_rec.vrei_attribute8
      ,p_vrei_attribute9_o
      => pqp_vri_shd.g_old_rec.vrei_attribute9
      ,p_vrei_attribute10_o
      => pqp_vri_shd.g_old_rec.vrei_attribute10
      ,p_vrei_attribute11_o
      => pqp_vri_shd.g_old_rec.vrei_attribute11
      ,p_vrei_attribute12_o
      => pqp_vri_shd.g_old_rec.vrei_attribute12
      ,p_vrei_attribute13_o
      => pqp_vri_shd.g_old_rec.vrei_attribute13
      ,p_vrei_attribute14_o
      => pqp_vri_shd.g_old_rec.vrei_attribute14
      ,p_vrei_attribute15_o
      => pqp_vri_shd.g_old_rec.vrei_attribute15
      ,p_vrei_attribute16_o
      => pqp_vri_shd.g_old_rec.vrei_attribute16
      ,p_vrei_attribute17_o
      => pqp_vri_shd.g_old_rec.vrei_attribute17
      ,p_vrei_attribute18_o
      => pqp_vri_shd.g_old_rec.vrei_attribute18
      ,p_vrei_attribute19_o
      => pqp_vri_shd.g_old_rec.vrei_attribute19
      ,p_vrei_attribute20_o
      => pqp_vri_shd.g_old_rec.vrei_attribute20
      ,p_vrei_information_category_o
      => pqp_vri_shd.g_old_rec.vrei_information_category
      ,p_vrei_information1_o
      => pqp_vri_shd.g_old_rec.vrei_information1
      ,p_vrei_information2_o
      => pqp_vri_shd.g_old_rec.vrei_information2
      ,p_vrei_information3_o
      => pqp_vri_shd.g_old_rec.vrei_information3
      ,p_vrei_information4_o
      => pqp_vri_shd.g_old_rec.vrei_information4
      ,p_vrei_information5_o
      => pqp_vri_shd.g_old_rec.vrei_information5
      ,p_vrei_information6_o
      => pqp_vri_shd.g_old_rec.vrei_information6
      ,p_vrei_information7_o
      => pqp_vri_shd.g_old_rec.vrei_information7
      ,p_vrei_information8_o
      => pqp_vri_shd.g_old_rec.vrei_information8
      ,p_vrei_information9_o
      => pqp_vri_shd.g_old_rec.vrei_information9
      ,p_vrei_information10_o
      => pqp_vri_shd.g_old_rec.vrei_information10
      ,p_vrei_information11_o
      => pqp_vri_shd.g_old_rec.vrei_information11
      ,p_vrei_information12_o
      => pqp_vri_shd.g_old_rec.vrei_information12
      ,p_vrei_information13_o
      => pqp_vri_shd.g_old_rec.vrei_information13
      ,p_vrei_information14_o
      => pqp_vri_shd.g_old_rec.vrei_information14
      ,p_vrei_information15_o
      => pqp_vri_shd.g_old_rec.vrei_information15
      ,p_vrei_information16_o
      => pqp_vri_shd.g_old_rec.vrei_information16
      ,p_vrei_information17_o
      => pqp_vri_shd.g_old_rec.vrei_information17
      ,p_vrei_information18_o
      => pqp_vri_shd.g_old_rec.vrei_information18
      ,p_vrei_information19_o
      => pqp_vri_shd.g_old_rec.vrei_information19
      ,p_vrei_information20_o
      => pqp_vri_shd.g_old_rec.vrei_information20
      ,p_vrei_information21_o
      => pqp_vri_shd.g_old_rec.vrei_information21
      ,p_vrei_information22_o
      => pqp_vri_shd.g_old_rec.vrei_information22
      ,p_vrei_information23_o
      => pqp_vri_shd.g_old_rec.vrei_information23
      ,p_vrei_information24_o
      => pqp_vri_shd.g_old_rec.vrei_information24
      ,p_vrei_information25_o
      => pqp_vri_shd.g_old_rec.vrei_information25
      ,p_vrei_information26_o
      => pqp_vri_shd.g_old_rec.vrei_information26
      ,p_vrei_information27_o
      => pqp_vri_shd.g_old_rec.vrei_information27
      ,p_vrei_information28_o
      => pqp_vri_shd.g_old_rec.vrei_information28
      ,p_vrei_information29_o
      => pqp_vri_shd.g_old_rec.vrei_information29
      ,p_vrei_information30_o
      => pqp_vri_shd.g_old_rec.vrei_information30
      ,p_object_version_number_o
      => pqp_vri_shd.g_old_rec.object_version_number
      ,p_request_id_o
      => pqp_vri_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => pqp_vri_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => pqp_vri_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => pqp_vri_shd.g_old_rec.program_update_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_REPOS_EXTRA_INFO'
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
  (p_rec in out nocopy pqp_vri_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.vehicle_repository_id = hr_api.g_number) then
    p_rec.vehicle_repository_id :=
    pqp_vri_shd.g_old_rec.vehicle_repository_id;
  End If;
  If (p_rec.information_type = hr_api.g_varchar2) then
    p_rec.information_type :=
    pqp_vri_shd.g_old_rec.information_type;
  End If;
  If (p_rec.vrei_attribute_category = hr_api.g_varchar2) then
    p_rec.vrei_attribute_category :=
    pqp_vri_shd.g_old_rec.vrei_attribute_category;
  End If;
  If (p_rec.vrei_attribute1 = hr_api.g_varchar2) then
    p_rec.vrei_attribute1 :=
    pqp_vri_shd.g_old_rec.vrei_attribute1;
  End If;
  If (p_rec.vrei_attribute2 = hr_api.g_varchar2) then
    p_rec.vrei_attribute2 :=
    pqp_vri_shd.g_old_rec.vrei_attribute2;
  End If;
  If (p_rec.vrei_attribute3 = hr_api.g_varchar2) then
    p_rec.vrei_attribute3 :=
    pqp_vri_shd.g_old_rec.vrei_attribute3;
  End If;
  If (p_rec.vrei_attribute4 = hr_api.g_varchar2) then
    p_rec.vrei_attribute4 :=
    pqp_vri_shd.g_old_rec.vrei_attribute4;
  End If;
  If (p_rec.vrei_attribute5 = hr_api.g_varchar2) then
    p_rec.vrei_attribute5 :=
    pqp_vri_shd.g_old_rec.vrei_attribute5;
  End If;
  If (p_rec.vrei_attribute6 = hr_api.g_varchar2) then
    p_rec.vrei_attribute6 :=
    pqp_vri_shd.g_old_rec.vrei_attribute6;
  End If;
  If (p_rec.vrei_attribute7 = hr_api.g_varchar2) then
    p_rec.vrei_attribute7 :=
    pqp_vri_shd.g_old_rec.vrei_attribute7;
  End If;
  If (p_rec.vrei_attribute8 = hr_api.g_varchar2) then
    p_rec.vrei_attribute8 :=
    pqp_vri_shd.g_old_rec.vrei_attribute8;
  End If;
  If (p_rec.vrei_attribute9 = hr_api.g_varchar2) then
    p_rec.vrei_attribute9 :=
    pqp_vri_shd.g_old_rec.vrei_attribute9;
  End If;
  If (p_rec.vrei_attribute10 = hr_api.g_varchar2) then
    p_rec.vrei_attribute10 :=
    pqp_vri_shd.g_old_rec.vrei_attribute10;
  End If;
  If (p_rec.vrei_attribute11 = hr_api.g_varchar2) then
    p_rec.vrei_attribute11 :=
    pqp_vri_shd.g_old_rec.vrei_attribute11;
  End If;
  If (p_rec.vrei_attribute12 = hr_api.g_varchar2) then
    p_rec.vrei_attribute12 :=
    pqp_vri_shd.g_old_rec.vrei_attribute12;
  End If;
  If (p_rec.vrei_attribute13 = hr_api.g_varchar2) then
    p_rec.vrei_attribute13 :=
    pqp_vri_shd.g_old_rec.vrei_attribute13;
  End If;
  If (p_rec.vrei_attribute14 = hr_api.g_varchar2) then
    p_rec.vrei_attribute14 :=
    pqp_vri_shd.g_old_rec.vrei_attribute14;
  End If;
  If (p_rec.vrei_attribute15 = hr_api.g_varchar2) then
    p_rec.vrei_attribute15 :=
    pqp_vri_shd.g_old_rec.vrei_attribute15;
  End If;
  If (p_rec.vrei_attribute16 = hr_api.g_varchar2) then
    p_rec.vrei_attribute16 :=
    pqp_vri_shd.g_old_rec.vrei_attribute16;
  End If;
  If (p_rec.vrei_attribute17 = hr_api.g_varchar2) then
    p_rec.vrei_attribute17 :=
    pqp_vri_shd.g_old_rec.vrei_attribute17;
  End If;
  If (p_rec.vrei_attribute18 = hr_api.g_varchar2) then
    p_rec.vrei_attribute18 :=
    pqp_vri_shd.g_old_rec.vrei_attribute18;
  End If;
  If (p_rec.vrei_attribute19 = hr_api.g_varchar2) then
    p_rec.vrei_attribute19 :=
    pqp_vri_shd.g_old_rec.vrei_attribute19;
  End If;
  If (p_rec.vrei_attribute20 = hr_api.g_varchar2) then
    p_rec.vrei_attribute20 :=
    pqp_vri_shd.g_old_rec.vrei_attribute20;
  End If;
  If (p_rec.vrei_information_category = hr_api.g_varchar2) then
    p_rec.vrei_information_category :=
    pqp_vri_shd.g_old_rec.vrei_information_category;
  End If;
  If (p_rec.vrei_information1 = hr_api.g_varchar2) then
    p_rec.vrei_information1 :=
    pqp_vri_shd.g_old_rec.vrei_information1;
  End If;
  If (p_rec.vrei_information2 = hr_api.g_varchar2) then
    p_rec.vrei_information2 :=
    pqp_vri_shd.g_old_rec.vrei_information2;
  End If;
  If (p_rec.vrei_information3 = hr_api.g_varchar2) then
    p_rec.vrei_information3 :=
    pqp_vri_shd.g_old_rec.vrei_information3;
  End If;
  If (p_rec.vrei_information4 = hr_api.g_varchar2) then
    p_rec.vrei_information4 :=
    pqp_vri_shd.g_old_rec.vrei_information4;
  End If;
  If (p_rec.vrei_information5 = hr_api.g_varchar2) then
    p_rec.vrei_information5 :=
    pqp_vri_shd.g_old_rec.vrei_information5;
  End If;
  If (p_rec.vrei_information6 = hr_api.g_varchar2) then
    p_rec.vrei_information6 :=
    pqp_vri_shd.g_old_rec.vrei_information6;
  End If;
  If (p_rec.vrei_information7 = hr_api.g_varchar2) then
    p_rec.vrei_information7 :=
    pqp_vri_shd.g_old_rec.vrei_information7;
  End If;
  If (p_rec.vrei_information8 = hr_api.g_varchar2) then
    p_rec.vrei_information8 :=
    pqp_vri_shd.g_old_rec.vrei_information8;
  End If;
  If (p_rec.vrei_information9 = hr_api.g_varchar2) then
    p_rec.vrei_information9 :=
    pqp_vri_shd.g_old_rec.vrei_information9;
  End If;
  If (p_rec.vrei_information10 = hr_api.g_varchar2) then
    p_rec.vrei_information10 :=
    pqp_vri_shd.g_old_rec.vrei_information10;
  End If;
  If (p_rec.vrei_information11 = hr_api.g_varchar2) then
    p_rec.vrei_information11 :=
    pqp_vri_shd.g_old_rec.vrei_information11;
  End If;
  If (p_rec.vrei_information12 = hr_api.g_varchar2) then
    p_rec.vrei_information12 :=
    pqp_vri_shd.g_old_rec.vrei_information12;
  End If;
  If (p_rec.vrei_information13 = hr_api.g_varchar2) then
    p_rec.vrei_information13 :=
    pqp_vri_shd.g_old_rec.vrei_information13;
  End If;
  If (p_rec.vrei_information14 = hr_api.g_varchar2) then
    p_rec.vrei_information14 :=
    pqp_vri_shd.g_old_rec.vrei_information14;
  End If;
  If (p_rec.vrei_information15 = hr_api.g_varchar2) then
    p_rec.vrei_information15 :=
    pqp_vri_shd.g_old_rec.vrei_information15;
  End If;
  If (p_rec.vrei_information16 = hr_api.g_varchar2) then
    p_rec.vrei_information16 :=
    pqp_vri_shd.g_old_rec.vrei_information16;
  End If;
  If (p_rec.vrei_information17 = hr_api.g_varchar2) then
    p_rec.vrei_information17 :=
    pqp_vri_shd.g_old_rec.vrei_information17;
  End If;
  If (p_rec.vrei_information18 = hr_api.g_varchar2) then
    p_rec.vrei_information18 :=
    pqp_vri_shd.g_old_rec.vrei_information18;
  End If;
  If (p_rec.vrei_information19 = hr_api.g_varchar2) then
    p_rec.vrei_information19 :=
    pqp_vri_shd.g_old_rec.vrei_information19;
  End If;
  If (p_rec.vrei_information20 = hr_api.g_varchar2) then
    p_rec.vrei_information20 :=
    pqp_vri_shd.g_old_rec.vrei_information20;
  End If;
  If (p_rec.vrei_information21 = hr_api.g_varchar2) then
    p_rec.vrei_information21 :=
    pqp_vri_shd.g_old_rec.vrei_information21;
  End If;
  If (p_rec.vrei_information22 = hr_api.g_varchar2) then
    p_rec.vrei_information22 :=
    pqp_vri_shd.g_old_rec.vrei_information22;
  End If;
  If (p_rec.vrei_information23 = hr_api.g_varchar2) then
    p_rec.vrei_information23 :=
    pqp_vri_shd.g_old_rec.vrei_information23;
  End If;
  If (p_rec.vrei_information24 = hr_api.g_varchar2) then
    p_rec.vrei_information24 :=
    pqp_vri_shd.g_old_rec.vrei_information24;
  End If;
  If (p_rec.vrei_information25 = hr_api.g_varchar2) then
    p_rec.vrei_information25 :=
    pqp_vri_shd.g_old_rec.vrei_information25;
  End If;
  If (p_rec.vrei_information26 = hr_api.g_varchar2) then
    p_rec.vrei_information26 :=
    pqp_vri_shd.g_old_rec.vrei_information26;
  End If;
  If (p_rec.vrei_information27 = hr_api.g_varchar2) then
    p_rec.vrei_information27 :=
    pqp_vri_shd.g_old_rec.vrei_information27;
  End If;
  If (p_rec.vrei_information28 = hr_api.g_varchar2) then
    p_rec.vrei_information28 :=
    pqp_vri_shd.g_old_rec.vrei_information28;
  End If;
  If (p_rec.vrei_information29 = hr_api.g_varchar2) then
    p_rec.vrei_information29 :=
    pqp_vri_shd.g_old_rec.vrei_information29;
  End If;
  If (p_rec.vrei_information30 = hr_api.g_varchar2) then
    p_rec.vrei_information30 :=
    pqp_vri_shd.g_old_rec.vrei_information30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    pqp_vri_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    pqp_vri_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    pqp_vri_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    pqp_vri_shd.g_old_rec.program_update_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pqp_vri_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_vri_shd.lck
    (p_rec.veh_repos_extra_info_id
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
  pqp_vri_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqp_vri_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqp_vri_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqp_vri_upd.post_update
     (p_rec
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
  (p_veh_repos_extra_info_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_repository_id        in     number    default hr_api.g_number
  ,p_information_type             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information1            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information2            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information3            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information4            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information5            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information6            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information7            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information8            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information9            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information10           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information11           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information12           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information13           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information14           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information15           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information16           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information17           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information18           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information19           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information20           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information21           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information22           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information23           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information24           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information25           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information26           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information27           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information28           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information29           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information30           in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ) is
--
  l_rec   pqp_vri_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_vri_shd.convert_args
  (p_veh_repos_extra_info_id
  ,p_vehicle_repository_id
  ,p_information_type
  ,p_vrei_attribute_category
  ,p_vrei_attribute1
  ,p_vrei_attribute2
  ,p_vrei_attribute3
  ,p_vrei_attribute4
  ,p_vrei_attribute5
  ,p_vrei_attribute6
  ,p_vrei_attribute7
  ,p_vrei_attribute8
  ,p_vrei_attribute9
  ,p_vrei_attribute10
  ,p_vrei_attribute11
  ,p_vrei_attribute12
  ,p_vrei_attribute13
  ,p_vrei_attribute14
  ,p_vrei_attribute15
  ,p_vrei_attribute16
  ,p_vrei_attribute17
  ,p_vrei_attribute18
  ,p_vrei_attribute19
  ,p_vrei_attribute20
  ,p_vrei_information_category
  ,p_vrei_information1
  ,p_vrei_information2
  ,p_vrei_information3
  ,p_vrei_information4
  ,p_vrei_information5
  ,p_vrei_information6
  ,p_vrei_information7
  ,p_vrei_information8
  ,p_vrei_information9
  ,p_vrei_information10
  ,p_vrei_information11
  ,p_vrei_information12
  ,p_vrei_information13
  ,p_vrei_information14
  ,p_vrei_information15
  ,p_vrei_information16
  ,p_vrei_information17
  ,p_vrei_information18
  ,p_vrei_information19
  ,p_vrei_information20
  ,p_vrei_information21
  ,p_vrei_information22
  ,p_vrei_information23
  ,p_vrei_information24
  ,p_vrei_information25
  ,p_vrei_information26
  ,p_vrei_information27
  ,p_vrei_information28
  ,p_vrei_information29
  ,p_vrei_information30
  ,p_object_version_number
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_program_update_date
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_vri_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqp_vri_upd;

/
