--------------------------------------------------------
--  DDL for Package Body PER_CNI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNI_UPD" as
/* $Header: pecnirhi.pkb 120.0 2005/05/31 06:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cni_upd.';  -- Global package name
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
  (p_rec in out nocopy per_cni_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  p_rec.object_version_number :=p_rec.object_version_number+1;
  --
  -- Update the per_ri_config_information Row
  --
  update per_ri_config_information
    set
     configuration_code              = p_rec.configuration_code
    ,config_information_category     = p_rec.config_information_category
    ,config_information1             = p_rec.config_information1
    ,config_information2             = p_rec.config_information2
    ,config_information3             = p_rec.config_information3
    ,config_information4             = p_rec.config_information4
    ,config_information5             = p_rec.config_information5
    ,config_information6             = p_rec.config_information6
    ,config_information7             = p_rec.config_information7
    ,config_information8             = p_rec.config_information8
    ,config_information9             = p_rec.config_information9
    ,config_information10            = p_rec.config_information10
    ,config_information11            = p_rec.config_information11
    ,config_information12            = p_rec.config_information12
    ,config_information13            = p_rec.config_information13
    ,config_information14            = p_rec.config_information14
    ,config_information15            = p_rec.config_information15
    ,config_information16            = p_rec.config_information16
    ,config_information17            = p_rec.config_information17
    ,config_information18            = p_rec.config_information18
    ,config_information19            = p_rec.config_information19
    ,config_information20            = p_rec.config_information20
    ,config_information21            = p_rec.config_information21
    ,config_information22            = p_rec.config_information22
    ,config_information23            = p_rec.config_information23
    ,config_information24            = p_rec.config_information24
    ,config_information25            = p_rec.config_information25
    ,config_information26            = p_rec.config_information26
    ,config_information27            = p_rec.config_information27
    ,config_information28            = p_rec.config_information28
    ,config_information29            = p_rec.config_information29
    ,config_information30            = p_rec.config_information30
    ,config_information_id           = p_rec.config_information_id
    ,config_sequence                 = p_rec.config_sequence
    ,object_version_number           = p_rec.object_version_number
    where config_information_id = p_rec.config_information_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_cni_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_cni_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_cni_shd.constraint_error
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
  (p_rec in per_cni_shd.g_rec_type
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
  ,p_rec                          in per_cni_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_cni_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_configuration_code
      => p_rec.configuration_code
      ,p_config_information_category
      => p_rec.config_information_category
      ,p_config_information1
      => p_rec.config_information1
      ,p_config_information2
      => p_rec.config_information2
      ,p_config_information3
      => p_rec.config_information3
      ,p_config_information4
      => p_rec.config_information4
      ,p_config_information5
      => p_rec.config_information5
      ,p_config_information6
      => p_rec.config_information6
      ,p_config_information7
      => p_rec.config_information7
      ,p_config_information8
      => p_rec.config_information8
      ,p_config_information9
      => p_rec.config_information9
      ,p_config_information10
      => p_rec.config_information10
      ,p_config_information11
      => p_rec.config_information11
      ,p_config_information12
      => p_rec.config_information12
      ,p_config_information13
      => p_rec.config_information13
      ,p_config_information14
      => p_rec.config_information14
      ,p_config_information15
      => p_rec.config_information15
      ,p_config_information16
      => p_rec.config_information16
      ,p_config_information17
      => p_rec.config_information17
      ,p_config_information18
      => p_rec.config_information18
      ,p_config_information19
      => p_rec.config_information19
      ,p_config_information20
      => p_rec.config_information20
      ,p_config_information21
      => p_rec.config_information21
      ,p_config_information22
      => p_rec.config_information22
      ,p_config_information23
      => p_rec.config_information23
      ,p_config_information24
      => p_rec.config_information24
      ,p_config_information25
      => p_rec.config_information25
      ,p_config_information26
      => p_rec.config_information26
      ,p_config_information27
      => p_rec.config_information27
      ,p_config_information28
      => p_rec.config_information28
      ,p_config_information29
      => p_rec.config_information29
      ,p_config_information30
      => p_rec.config_information30
      ,p_config_information_id
      => p_rec.config_information_id
      ,p_config_sequence
      => p_rec.config_sequence
      ,p_configuration_code_o
      => per_cni_shd.g_old_rec.configuration_code
      ,p_config_information_categor_o
      => per_cni_shd.g_old_rec.config_information_category
      ,p_config_information1_o
      => per_cni_shd.g_old_rec.config_information1
      ,p_config_information2_o
      => per_cni_shd.g_old_rec.config_information2
      ,p_config_information3_o
      => per_cni_shd.g_old_rec.config_information3
      ,p_config_information4_o
      => per_cni_shd.g_old_rec.config_information4
      ,p_config_information5_o
      => per_cni_shd.g_old_rec.config_information5
      ,p_config_information6_o
      => per_cni_shd.g_old_rec.config_information6
      ,p_config_information7_o
      => per_cni_shd.g_old_rec.config_information7
      ,p_config_information8_o
      => per_cni_shd.g_old_rec.config_information8
      ,p_config_information9_o
      => per_cni_shd.g_old_rec.config_information9
      ,p_config_information10_o
      => per_cni_shd.g_old_rec.config_information10
      ,p_config_information11_o
      => per_cni_shd.g_old_rec.config_information11
      ,p_config_information12_o
      => per_cni_shd.g_old_rec.config_information12
      ,p_config_information13_o
      => per_cni_shd.g_old_rec.config_information13
      ,p_config_information14_o
      => per_cni_shd.g_old_rec.config_information14
      ,p_config_information15_o
      => per_cni_shd.g_old_rec.config_information15
      ,p_config_information16_o
      => per_cni_shd.g_old_rec.config_information16
      ,p_config_information17_o
      => per_cni_shd.g_old_rec.config_information17
      ,p_config_information18_o
      => per_cni_shd.g_old_rec.config_information18
      ,p_config_information19_o
      => per_cni_shd.g_old_rec.config_information19
      ,p_config_information20_o
      => per_cni_shd.g_old_rec.config_information20
      ,p_config_information21_o
      => per_cni_shd.g_old_rec.config_information21
      ,p_config_information22_o
      => per_cni_shd.g_old_rec.config_information22
      ,p_config_information23_o
      => per_cni_shd.g_old_rec.config_information23
      ,p_config_information24_o
      => per_cni_shd.g_old_rec.config_information24
      ,p_config_information25_o
      => per_cni_shd.g_old_rec.config_information25
      ,p_config_information26_o
      => per_cni_shd.g_old_rec.config_information26
      ,p_config_information27_o
      => per_cni_shd.g_old_rec.config_information27
      ,p_config_information28_o
      => per_cni_shd.g_old_rec.config_information28
      ,p_config_information29_o
      => per_cni_shd.g_old_rec.config_information29
      ,p_config_information30_o
      => per_cni_shd.g_old_rec.config_information30
      ,p_config_sequence_o
      => per_cni_shd.g_old_rec.config_sequence
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_RI_CONFIG_INFORMATION'
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
  (p_rec in out nocopy per_cni_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.configuration_code = hr_api.g_varchar2) then
    p_rec.configuration_code :=
    per_cni_shd.g_old_rec.configuration_code;
  End If;
  If (p_rec.config_information_category = hr_api.g_varchar2) then
    p_rec.config_information_category :=
    per_cni_shd.g_old_rec.config_information_category;
  End If;
  If (p_rec.config_information1 = hr_api.g_varchar2) then
    p_rec.config_information1 :=
    per_cni_shd.g_old_rec.config_information1;
  End If;
  If (p_rec.config_information2 = hr_api.g_varchar2) then
    p_rec.config_information2 :=
    per_cni_shd.g_old_rec.config_information2;
  End If;
  If (p_rec.config_information3 = hr_api.g_varchar2) then
    p_rec.config_information3 :=
    per_cni_shd.g_old_rec.config_information3;
  End If;
  If (p_rec.config_information4 = hr_api.g_varchar2) then
    p_rec.config_information4 :=
    per_cni_shd.g_old_rec.config_information4;
  End If;
  If (p_rec.config_information5 = hr_api.g_varchar2) then
    p_rec.config_information5 :=
    per_cni_shd.g_old_rec.config_information5;
  End If;
  If (p_rec.config_information6 = hr_api.g_varchar2) then
    p_rec.config_information6 :=
    per_cni_shd.g_old_rec.config_information6;
  End If;
  If (p_rec.config_information7 = hr_api.g_varchar2) then
    p_rec.config_information7 :=
    per_cni_shd.g_old_rec.config_information7;
  End If;
  If (p_rec.config_information8 = hr_api.g_varchar2) then
    p_rec.config_information8 :=
    per_cni_shd.g_old_rec.config_information8;
  End If;
  If (p_rec.config_information9 = hr_api.g_varchar2) then
    p_rec.config_information9 :=
    per_cni_shd.g_old_rec.config_information9;
  End If;
  If (p_rec.config_information10 = hr_api.g_varchar2) then
    p_rec.config_information10 :=
    per_cni_shd.g_old_rec.config_information10;
  End If;
  If (p_rec.config_information11 = hr_api.g_varchar2) then
    p_rec.config_information11 :=
    per_cni_shd.g_old_rec.config_information11;
  End If;
  If (p_rec.config_information12 = hr_api.g_varchar2) then
    p_rec.config_information12 :=
    per_cni_shd.g_old_rec.config_information12;
  End If;
  If (p_rec.config_information13 = hr_api.g_varchar2) then
    p_rec.config_information13 :=
    per_cni_shd.g_old_rec.config_information13;
  End If;
  If (p_rec.config_information14 = hr_api.g_varchar2) then
    p_rec.config_information14 :=
    per_cni_shd.g_old_rec.config_information14;
  End If;
  If (p_rec.config_information15 = hr_api.g_varchar2) then
    p_rec.config_information15 :=
    per_cni_shd.g_old_rec.config_information15;
  End If;
  If (p_rec.config_information16 = hr_api.g_varchar2) then
    p_rec.config_information16 :=
    per_cni_shd.g_old_rec.config_information16;
  End If;
  If (p_rec.config_information17 = hr_api.g_varchar2) then
    p_rec.config_information17 :=
    per_cni_shd.g_old_rec.config_information17;
  End If;
  If (p_rec.config_information18 = hr_api.g_varchar2) then
    p_rec.config_information18 :=
    per_cni_shd.g_old_rec.config_information18;
  End If;
  If (p_rec.config_information19 = hr_api.g_varchar2) then
    p_rec.config_information19 :=
    per_cni_shd.g_old_rec.config_information19;
  End If;
  If (p_rec.config_information20 = hr_api.g_varchar2) then
    p_rec.config_information20 :=
    per_cni_shd.g_old_rec.config_information20;
  End If;
  If (p_rec.config_information21 = hr_api.g_varchar2) then
    p_rec.config_information21 :=
    per_cni_shd.g_old_rec.config_information21;
  End If;
  If (p_rec.config_information22 = hr_api.g_varchar2) then
    p_rec.config_information22 :=
    per_cni_shd.g_old_rec.config_information22;
  End If;
  If (p_rec.config_information23 = hr_api.g_varchar2) then
    p_rec.config_information23 :=
    per_cni_shd.g_old_rec.config_information23;
  End If;
  If (p_rec.config_information24 = hr_api.g_varchar2) then
    p_rec.config_information24 :=
    per_cni_shd.g_old_rec.config_information24;
  End If;
  If (p_rec.config_information25 = hr_api.g_varchar2) then
    p_rec.config_information25 :=
    per_cni_shd.g_old_rec.config_information25;
  End If;
  If (p_rec.config_information26 = hr_api.g_varchar2) then
    p_rec.config_information26 :=
    per_cni_shd.g_old_rec.config_information26;
  End If;
  If (p_rec.config_information27 = hr_api.g_varchar2) then
    p_rec.config_information27 :=
    per_cni_shd.g_old_rec.config_information27;
  End If;
  If (p_rec.config_information28 = hr_api.g_varchar2) then
    p_rec.config_information28 :=
    per_cni_shd.g_old_rec.config_information28;
  End If;
  If (p_rec.config_information29 = hr_api.g_varchar2) then
    p_rec.config_information29 :=
    per_cni_shd.g_old_rec.config_information29;
  End If;
  If (p_rec.config_information30 = hr_api.g_varchar2) then
    p_rec.config_information30 :=
    per_cni_shd.g_old_rec.config_information30;
  End If;
  If (p_rec.config_sequence = hr_api.g_number) then
    p_rec.config_sequence :=
    per_cni_shd.g_old_rec.config_sequence;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_cni_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_cni_shd.lck
    (p_rec.config_information_id
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
  per_cni_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_cni_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_cni_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_cni_upd.post_update
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
  ,p_config_information_id        in     number
  ,p_configuration_code           in     varchar2  default hr_api.g_varchar2
  ,p_config_information_category  in     varchar2  default hr_api.g_varchar2
  ,p_config_sequence              in     number    default hr_api.g_number
  ,p_config_information1          in     varchar2  default hr_api.g_varchar2
  ,p_config_information2          in     varchar2  default hr_api.g_varchar2
  ,p_config_information3          in     varchar2  default hr_api.g_varchar2
  ,p_config_information4          in     varchar2  default hr_api.g_varchar2
  ,p_config_information5          in     varchar2  default hr_api.g_varchar2
  ,p_config_information6          in     varchar2  default hr_api.g_varchar2
  ,p_config_information7          in     varchar2  default hr_api.g_varchar2
  ,p_config_information8          in     varchar2  default hr_api.g_varchar2
  ,p_config_information9          in     varchar2  default hr_api.g_varchar2
  ,p_config_information10         in     varchar2  default hr_api.g_varchar2
  ,p_config_information11         in     varchar2  default hr_api.g_varchar2
  ,p_config_information12         in     varchar2  default hr_api.g_varchar2
  ,p_config_information13         in     varchar2  default hr_api.g_varchar2
  ,p_config_information14         in     varchar2  default hr_api.g_varchar2
  ,p_config_information15         in     varchar2  default hr_api.g_varchar2
  ,p_config_information16         in     varchar2  default hr_api.g_varchar2
  ,p_config_information17         in     varchar2  default hr_api.g_varchar2
  ,p_config_information18         in     varchar2  default hr_api.g_varchar2
  ,p_config_information19         in     varchar2  default hr_api.g_varchar2
  ,p_config_information20         in     varchar2  default hr_api.g_varchar2
  ,p_config_information21         in     varchar2  default hr_api.g_varchar2
  ,p_config_information22         in     varchar2  default hr_api.g_varchar2
  ,p_config_information23         in     varchar2  default hr_api.g_varchar2
  ,p_config_information24         in     varchar2  default hr_api.g_varchar2
  ,p_config_information25         in     varchar2  default hr_api.g_varchar2
  ,p_config_information26         in     varchar2  default hr_api.g_varchar2
  ,p_config_information27         in     varchar2  default hr_api.g_varchar2
  ,p_config_information28         in     varchar2  default hr_api.g_varchar2
  ,p_config_information29         in     varchar2  default hr_api.g_varchar2
  ,p_config_information30         in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        In Out Nocopy Number
  ) is
--
  l_rec   per_cni_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_cni_shd.convert_args
  (p_configuration_code
  ,p_config_information_category
  ,p_config_information1
  ,p_config_information2
  ,p_config_information3
  ,p_config_information4
  ,p_config_information5
  ,p_config_information6
  ,p_config_information7
  ,p_config_information8
  ,p_config_information9
  ,p_config_information10
  ,p_config_information11
  ,p_config_information12
  ,p_config_information13
  ,p_config_information14
  ,p_config_information15
  ,p_config_information16
  ,p_config_information17
  ,p_config_information18
  ,p_config_information19
  ,p_config_information20
  ,p_config_information21
  ,p_config_information22
  ,p_config_information23
  ,p_config_information24
  ,p_config_information25
  ,p_config_information26
  ,p_config_information27
  ,p_config_information28
  ,p_config_information29
  ,p_config_information30
  ,p_config_information_id
  ,p_config_sequence
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_cni_upd.upd
     (p_effective_date
     ,l_rec
     );
  --

  p_object_version_number := l_rec.object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_cni_upd;

/
