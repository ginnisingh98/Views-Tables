--------------------------------------------------------
--  DDL for Package Body PQP_PCV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PCV_UPD" as
/* $Header: pqpcvrhi.pkb 120.0 2005/05/29 01:55:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pcv_upd.';  -- Global package name
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
  (p_rec in out nocopy pqp_pcv_shd.g_rec_type
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
  -- Update the pqp_configuration_values Row
  --
  update pqp_configuration_values
    set
     configuration_value_id          = p_rec.configuration_value_id
    ,business_group_id               = p_rec.business_group_id
    ,legislation_code                = p_rec.legislation_code
    ,pcv_attribute_category          = p_rec.pcv_attribute_category
    ,pcv_attribute1                  = p_rec.pcv_attribute1
    ,pcv_attribute2                  = p_rec.pcv_attribute2
    ,pcv_attribute3                  = p_rec.pcv_attribute3
    ,pcv_attribute4                  = p_rec.pcv_attribute4
    ,pcv_attribute5                  = p_rec.pcv_attribute5
    ,pcv_attribute6                  = p_rec.pcv_attribute6
    ,pcv_attribute7                  = p_rec.pcv_attribute7
    ,pcv_attribute8                  = p_rec.pcv_attribute8
    ,pcv_attribute9                  = p_rec.pcv_attribute9
    ,pcv_attribute10                 = p_rec.pcv_attribute10
    ,pcv_attribute11                 = p_rec.pcv_attribute11
    ,pcv_attribute12                 = p_rec.pcv_attribute12
    ,pcv_attribute13                 = p_rec.pcv_attribute13
    ,pcv_attribute14                 = p_rec.pcv_attribute14
    ,pcv_attribute15                 = p_rec.pcv_attribute15
    ,pcv_attribute16                 = p_rec.pcv_attribute16
    ,pcv_attribute17                 = p_rec.pcv_attribute17
    ,pcv_attribute18                 = p_rec.pcv_attribute18
    ,pcv_attribute19                 = p_rec.pcv_attribute19
    ,pcv_attribute20                 = p_rec.pcv_attribute20
    ,pcv_information_category        = p_rec.pcv_information_category
    ,pcv_information1                = p_rec.pcv_information1
    ,pcv_information2                = p_rec.pcv_information2
    ,pcv_information3                = p_rec.pcv_information3
    ,pcv_information4                = p_rec.pcv_information4
    ,pcv_information5                = p_rec.pcv_information5
    ,pcv_information6                = p_rec.pcv_information6
    ,pcv_information7                = p_rec.pcv_information7
    ,pcv_information8                = p_rec.pcv_information8
    ,pcv_information9                = p_rec.pcv_information9
    ,pcv_information10               = p_rec.pcv_information10
    ,pcv_information11               = p_rec.pcv_information11
    ,pcv_information12               = p_rec.pcv_information12
    ,pcv_information13               = p_rec.pcv_information13
    ,pcv_information14               = p_rec.pcv_information14
    ,pcv_information15               = p_rec.pcv_information15
    ,pcv_information16               = p_rec.pcv_information16
    ,pcv_information17               = p_rec.pcv_information17
    ,pcv_information18               = p_rec.pcv_information18
    ,pcv_information19               = p_rec.pcv_information19
    ,pcv_information20               = p_rec.pcv_information20
    ,object_version_number           = p_rec.object_version_number
    ,configuration_name              =p_rec.configuration_name
    where configuration_value_id = p_rec.configuration_value_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqp_pcv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqp_pcv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqp_pcv_shd.constraint_error
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
  (p_rec in pqp_pcv_shd.g_rec_type
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
  ,p_rec                          in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_pcv_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_configuration_value_id
      => p_rec.configuration_value_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_pcv_attribute_category
      => p_rec.pcv_attribute_category
      ,p_pcv_attribute1
      => p_rec.pcv_attribute1
      ,p_pcv_attribute2
      => p_rec.pcv_attribute2
      ,p_pcv_attribute3
      => p_rec.pcv_attribute3
      ,p_pcv_attribute4
      => p_rec.pcv_attribute4
      ,p_pcv_attribute5
      => p_rec.pcv_attribute5
      ,p_pcv_attribute6
      => p_rec.pcv_attribute6
      ,p_pcv_attribute7
      => p_rec.pcv_attribute7
      ,p_pcv_attribute8
      => p_rec.pcv_attribute8
      ,p_pcv_attribute9
      => p_rec.pcv_attribute9
      ,p_pcv_attribute10
      => p_rec.pcv_attribute10
      ,p_pcv_attribute11
      => p_rec.pcv_attribute11
      ,p_pcv_attribute12
      => p_rec.pcv_attribute12
      ,p_pcv_attribute13
      => p_rec.pcv_attribute13
      ,p_pcv_attribute14
      => p_rec.pcv_attribute14
      ,p_pcv_attribute15
      => p_rec.pcv_attribute15
      ,p_pcv_attribute16
      => p_rec.pcv_attribute16
      ,p_pcv_attribute17
      => p_rec.pcv_attribute17
      ,p_pcv_attribute18
      => p_rec.pcv_attribute18
      ,p_pcv_attribute19
      => p_rec.pcv_attribute19
      ,p_pcv_attribute20
      => p_rec.pcv_attribute20
      ,p_pcv_information_category
      => p_rec.pcv_information_category
      ,p_pcv_information1
      => p_rec.pcv_information1
      ,p_pcv_information2
      => p_rec.pcv_information2
      ,p_pcv_information3
      => p_rec.pcv_information3
      ,p_pcv_information4
      => p_rec.pcv_information4
      ,p_pcv_information5
      => p_rec.pcv_information5
      ,p_pcv_information6
      => p_rec.pcv_information6
      ,p_pcv_information7
      => p_rec.pcv_information7
      ,p_pcv_information8
      => p_rec.pcv_information8
      ,p_pcv_information9
      => p_rec.pcv_information9
      ,p_pcv_information10
      => p_rec.pcv_information10
      ,p_pcv_information11
      => p_rec.pcv_information11
      ,p_pcv_information12
      => p_rec.pcv_information12
      ,p_pcv_information13
      => p_rec.pcv_information13
      ,p_pcv_information14
      => p_rec.pcv_information14
      ,p_pcv_information15
      => p_rec.pcv_information15
      ,p_pcv_information16
      => p_rec.pcv_information16
      ,p_pcv_information17
      => p_rec.pcv_information17
      ,p_pcv_information18
      => p_rec.pcv_information18
      ,p_pcv_information19
      => p_rec.pcv_information19
      ,p_pcv_information20
      => p_rec.pcv_information20
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_configuration_name
      => p_rec.configuration_name
      ,p_business_group_id_o
      => pqp_pcv_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pqp_pcv_shd.g_old_rec.legislation_code
      ,p_pcv_attribute_category_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute_category
      ,p_pcv_attribute1_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute1
      ,p_pcv_attribute2_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute2
      ,p_pcv_attribute3_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute3
      ,p_pcv_attribute4_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute4
      ,p_pcv_attribute5_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute5
      ,p_pcv_attribute6_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute6
      ,p_pcv_attribute7_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute7
      ,p_pcv_attribute8_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute8
      ,p_pcv_attribute9_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute9
      ,p_pcv_attribute10_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute10
      ,p_pcv_attribute11_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute11
      ,p_pcv_attribute12_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute12
      ,p_pcv_attribute13_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute13
      ,p_pcv_attribute14_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute14
      ,p_pcv_attribute15_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute15
      ,p_pcv_attribute16_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute16
      ,p_pcv_attribute17_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute17
      ,p_pcv_attribute18_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute18
      ,p_pcv_attribute19_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute19
      ,p_pcv_attribute20_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute20
      ,p_pcv_information_category_o
      => pqp_pcv_shd.g_old_rec.pcv_information_category
      ,p_pcv_information1_o
      => pqp_pcv_shd.g_old_rec.pcv_information1
      ,p_pcv_information2_o
      => pqp_pcv_shd.g_old_rec.pcv_information2
      ,p_pcv_information3_o
      => pqp_pcv_shd.g_old_rec.pcv_information3
      ,p_pcv_information4_o
      => pqp_pcv_shd.g_old_rec.pcv_information4
      ,p_pcv_information5_o
      => pqp_pcv_shd.g_old_rec.pcv_information5
      ,p_pcv_information6_o
      => pqp_pcv_shd.g_old_rec.pcv_information6
      ,p_pcv_information7_o
      => pqp_pcv_shd.g_old_rec.pcv_information7
      ,p_pcv_information8_o
      => pqp_pcv_shd.g_old_rec.pcv_information8
      ,p_pcv_information9_o
      => pqp_pcv_shd.g_old_rec.pcv_information9
      ,p_pcv_information10_o
      => pqp_pcv_shd.g_old_rec.pcv_information10
      ,p_pcv_information11_o
      => pqp_pcv_shd.g_old_rec.pcv_information11
      ,p_pcv_information12_o
      => pqp_pcv_shd.g_old_rec.pcv_information12
      ,p_pcv_information13_o
      => pqp_pcv_shd.g_old_rec.pcv_information13
      ,p_pcv_information14_o
      => pqp_pcv_shd.g_old_rec.pcv_information14
      ,p_pcv_information15_o
      => pqp_pcv_shd.g_old_rec.pcv_information15
      ,p_pcv_information16_o
      => pqp_pcv_shd.g_old_rec.pcv_information16
      ,p_pcv_information17_o
      => pqp_pcv_shd.g_old_rec.pcv_information17
      ,p_pcv_information18_o
      => pqp_pcv_shd.g_old_rec.pcv_information18
      ,p_pcv_information19_o
      => pqp_pcv_shd.g_old_rec.pcv_information19
      ,p_pcv_information20_o
      => pqp_pcv_shd.g_old_rec.pcv_information20
      ,p_object_version_number_o
      => pqp_pcv_shd.g_old_rec.object_version_number
      ,p_configuration_name_o
      => pqp_pcv_shd.g_old_rec.configuration_name
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_CONFIGURATION_VALUES'
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
  (p_rec in out nocopy pqp_pcv_shd.g_rec_type
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
    pqp_pcv_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pqp_pcv_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.pcv_attribute_category = hr_api.g_varchar2) then
    p_rec.pcv_attribute_category :=
    pqp_pcv_shd.g_old_rec.pcv_attribute_category;
  End If;
  If (p_rec.pcv_attribute1 = hr_api.g_varchar2) then
    p_rec.pcv_attribute1 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute1;
  End If;
  If (p_rec.pcv_attribute2 = hr_api.g_varchar2) then
    p_rec.pcv_attribute2 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute2;
  End If;
  If (p_rec.pcv_attribute3 = hr_api.g_varchar2) then
    p_rec.pcv_attribute3 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute3;
  End If;
  If (p_rec.pcv_attribute4 = hr_api.g_varchar2) then
    p_rec.pcv_attribute4 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute4;
  End If;
  If (p_rec.pcv_attribute5 = hr_api.g_varchar2) then
    p_rec.pcv_attribute5 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute5;
  End If;
  If (p_rec.pcv_attribute6 = hr_api.g_varchar2) then
    p_rec.pcv_attribute6 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute6;
  End If;
  If (p_rec.pcv_attribute7 = hr_api.g_varchar2) then
    p_rec.pcv_attribute7 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute7;
  End If;
  If (p_rec.pcv_attribute8 = hr_api.g_varchar2) then
    p_rec.pcv_attribute8 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute8;
  End If;
  If (p_rec.pcv_attribute9 = hr_api.g_varchar2) then
    p_rec.pcv_attribute9 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute9;
  End If;
  If (p_rec.pcv_attribute10 = hr_api.g_varchar2) then
    p_rec.pcv_attribute10 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute10;
  End If;
  If (p_rec.pcv_attribute11 = hr_api.g_varchar2) then
    p_rec.pcv_attribute11 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute11;
  End If;
  If (p_rec.pcv_attribute12 = hr_api.g_varchar2) then
    p_rec.pcv_attribute12 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute12;
  End If;
  If (p_rec.pcv_attribute13 = hr_api.g_varchar2) then
    p_rec.pcv_attribute13 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute13;
  End If;
  If (p_rec.pcv_attribute14 = hr_api.g_varchar2) then
    p_rec.pcv_attribute14 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute14;
  End If;
  If (p_rec.pcv_attribute15 = hr_api.g_varchar2) then
    p_rec.pcv_attribute15 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute15;
  End If;
  If (p_rec.pcv_attribute16 = hr_api.g_varchar2) then
    p_rec.pcv_attribute16 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute16;
  End If;
  If (p_rec.pcv_attribute17 = hr_api.g_varchar2) then
    p_rec.pcv_attribute17 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute17;
  End If;
  If (p_rec.pcv_attribute18 = hr_api.g_varchar2) then
    p_rec.pcv_attribute18 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute18;
  End If;
  If (p_rec.pcv_attribute19 = hr_api.g_varchar2) then
    p_rec.pcv_attribute19 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute19;
  End If;
  If (p_rec.pcv_attribute20 = hr_api.g_varchar2) then
    p_rec.pcv_attribute20 :=
    pqp_pcv_shd.g_old_rec.pcv_attribute20;
  End If;
  If (p_rec.pcv_information_category = hr_api.g_varchar2) then
    p_rec.pcv_information_category :=
    pqp_pcv_shd.g_old_rec.pcv_information_category;
  End If;
  If (p_rec.pcv_information1 = hr_api.g_varchar2) then
    p_rec.pcv_information1 :=
    pqp_pcv_shd.g_old_rec.pcv_information1;
  End If;
  If (p_rec.pcv_information2 = hr_api.g_varchar2) then
    p_rec.pcv_information2 :=
    pqp_pcv_shd.g_old_rec.pcv_information2;
  End If;
  If (p_rec.pcv_information3 = hr_api.g_varchar2) then
    p_rec.pcv_information3 :=
    pqp_pcv_shd.g_old_rec.pcv_information3;
  End If;
  If (p_rec.pcv_information4 = hr_api.g_varchar2) then
    p_rec.pcv_information4 :=
    pqp_pcv_shd.g_old_rec.pcv_information4;
  End If;
  If (p_rec.pcv_information5 = hr_api.g_varchar2) then
    p_rec.pcv_information5 :=
    pqp_pcv_shd.g_old_rec.pcv_information5;
  End If;
  If (p_rec.pcv_information6 = hr_api.g_varchar2) then
    p_rec.pcv_information6 :=
    pqp_pcv_shd.g_old_rec.pcv_information6;
  End If;
  If (p_rec.pcv_information7 = hr_api.g_varchar2) then
    p_rec.pcv_information7 :=
    pqp_pcv_shd.g_old_rec.pcv_information7;
  End If;
  If (p_rec.pcv_information8 = hr_api.g_varchar2) then
    p_rec.pcv_information8 :=
    pqp_pcv_shd.g_old_rec.pcv_information8;
  End If;
  If (p_rec.pcv_information9 = hr_api.g_varchar2) then
    p_rec.pcv_information9 :=
    pqp_pcv_shd.g_old_rec.pcv_information9;
  End If;
  If (p_rec.pcv_information10 = hr_api.g_varchar2) then
    p_rec.pcv_information10 :=
    pqp_pcv_shd.g_old_rec.pcv_information10;
  End If;
  If (p_rec.pcv_information11 = hr_api.g_varchar2) then
    p_rec.pcv_information11 :=
    pqp_pcv_shd.g_old_rec.pcv_information11;
  End If;
  If (p_rec.pcv_information12 = hr_api.g_varchar2) then
    p_rec.pcv_information12 :=
    pqp_pcv_shd.g_old_rec.pcv_information12;
  End If;
  If (p_rec.pcv_information13 = hr_api.g_varchar2) then
    p_rec.pcv_information13 :=
    pqp_pcv_shd.g_old_rec.pcv_information13;
  End If;
  If (p_rec.pcv_information14 = hr_api.g_varchar2) then
    p_rec.pcv_information14 :=
    pqp_pcv_shd.g_old_rec.pcv_information14;
  End If;
  If (p_rec.pcv_information15 = hr_api.g_varchar2) then
    p_rec.pcv_information15 :=
    pqp_pcv_shd.g_old_rec.pcv_information15;
  End If;
  If (p_rec.pcv_information16 = hr_api.g_varchar2) then
    p_rec.pcv_information16 :=
    pqp_pcv_shd.g_old_rec.pcv_information16;
  End If;
  If (p_rec.pcv_information17 = hr_api.g_varchar2) then
    p_rec.pcv_information17 :=
    pqp_pcv_shd.g_old_rec.pcv_information17;
  End If;
  If (p_rec.pcv_information18 = hr_api.g_varchar2) then
    p_rec.pcv_information18 :=
    pqp_pcv_shd.g_old_rec.pcv_information18;
  End If;
  If (p_rec.pcv_information19 = hr_api.g_varchar2) then
    p_rec.pcv_information19 :=
    pqp_pcv_shd.g_old_rec.pcv_information19;
  End If;
  If (p_rec.pcv_information20 = hr_api.g_varchar2) then
    p_rec.pcv_information20 :=
    pqp_pcv_shd.g_old_rec.pcv_information20;
  End If;
  If (p_rec.configuration_name = hr_api.g_varchar2) then
    p_rec.configuration_name :=
    pqp_pcv_shd.g_old_rec.configuration_name;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_pcv_shd.lck
    (p_rec.configuration_value_id
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
  pqp_pcv_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqp_pcv_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqp_pcv_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqp_pcv_upd.post_update
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
  ,p_configuration_value_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_pcv_attribute_category       in     varchar2
  ,p_pcv_attribute1               in     varchar2
  ,p_pcv_attribute2               in     varchar2
  ,p_pcv_attribute3               in     varchar2
  ,p_pcv_attribute4               in     varchar2
  ,p_pcv_attribute5               in     varchar2
  ,p_pcv_attribute6               in     varchar2
  ,p_pcv_attribute7               in     varchar2
  ,p_pcv_attribute8               in     varchar2
  ,p_pcv_attribute9               in     varchar2
  ,p_pcv_attribute10              in     varchar2
  ,p_pcv_attribute11              in     varchar2
  ,p_pcv_attribute12              in     varchar2
  ,p_pcv_attribute13              in     varchar2
  ,p_pcv_attribute14              in     varchar2
  ,p_pcv_attribute15              in     varchar2
  ,p_pcv_attribute16              in     varchar2
  ,p_pcv_attribute17              in     varchar2
  ,p_pcv_attribute18              in     varchar2
  ,p_pcv_attribute19              in     varchar2
  ,p_pcv_attribute20              in     varchar2
  ,p_pcv_information_category     in     varchar2
  ,p_pcv_information1             in     varchar2
  ,p_pcv_information2             in     varchar2
  ,p_pcv_information3             in     varchar2
  ,p_pcv_information4             in     varchar2
  ,p_pcv_information5             in     varchar2
  ,p_pcv_information6             in     varchar2
  ,p_pcv_information7             in     varchar2
  ,p_pcv_information8             in     varchar2
  ,p_pcv_information9             in     varchar2
  ,p_pcv_information10            in     varchar2
  ,p_pcv_information11            in     varchar2
  ,p_pcv_information12            in     varchar2
  ,p_pcv_information13            in     varchar2
  ,p_pcv_information14            in     varchar2
  ,p_pcv_information15            in     varchar2
  ,p_pcv_information16            in     varchar2
  ,p_pcv_information17            in     varchar2
  ,p_pcv_information18            in     varchar2
  ,p_pcv_information19            in     varchar2
  ,p_pcv_information20            in     varchar2
  ,p_configuration_name           in     varchar2
  ) is
--
  l_rec   pqp_pcv_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_pcv_shd.convert_args
  (p_configuration_value_id
  ,p_business_group_id
  ,p_legislation_code
  ,p_pcv_attribute_category
  ,p_pcv_attribute1
  ,p_pcv_attribute2
  ,p_pcv_attribute3
  ,p_pcv_attribute4
  ,p_pcv_attribute5
  ,p_pcv_attribute6
  ,p_pcv_attribute7
  ,p_pcv_attribute8
  ,p_pcv_attribute9
  ,p_pcv_attribute10
  ,p_pcv_attribute11
  ,p_pcv_attribute12
  ,p_pcv_attribute13
  ,p_pcv_attribute14
  ,p_pcv_attribute15
  ,p_pcv_attribute16
  ,p_pcv_attribute17
  ,p_pcv_attribute18
  ,p_pcv_attribute19
  ,p_pcv_attribute20
  ,p_pcv_information_category
  ,p_pcv_information1
  ,p_pcv_information2
  ,p_pcv_information3
  ,p_pcv_information4
  ,p_pcv_information5
  ,p_pcv_information6
  ,p_pcv_information7
  ,p_pcv_information8
  ,p_pcv_information9
  ,p_pcv_information10
  ,p_pcv_information11
  ,p_pcv_information12
  ,p_pcv_information13
  ,p_pcv_information14
  ,p_pcv_information15
  ,p_pcv_information16
  ,p_pcv_information17
  ,p_pcv_information18
  ,p_pcv_information19
  ,p_pcv_information20
  ,p_object_version_number
  ,p_configuration_name
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_pcv_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqp_pcv_upd;

/
