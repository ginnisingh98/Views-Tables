--------------------------------------------------------
--  DDL for Package Body OTA_OCL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OCL_UPD" as
/* $Header: otoclrhi.pkb 120.1.12000000.2 2007/02/07 09:19:37 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_ocl_upd.';  -- Global package name
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
  (p_rec in out nocopy ota_ocl_shd.g_rec_type
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
  -- Update the ota_competence_languages Row
  --
  update ota_competence_languages
    set
     competence_language_id          = p_rec.competence_language_id
    ,competence_id                   = p_rec.competence_id
    ,language_code                     = p_rec.language_code
    ,min_proficiency_level_id        = p_rec.min_proficiency_level_id
    ,business_group_id               = p_rec.business_group_id
    ,object_version_number           = p_rec.object_version_number
    ,ocl_information_category        = p_rec.ocl_information_category
    ,ocl_information1                = p_rec.ocl_information1
    ,ocl_information2                = p_rec.ocl_information2
    ,ocl_information3                = p_rec.ocl_information3
    ,ocl_information4                = p_rec.ocl_information4
    ,ocl_information5                = p_rec.ocl_information5
    ,ocl_information6                = p_rec.ocl_information6
    ,ocl_information7                = p_rec.ocl_information7
    ,ocl_information8                = p_rec.ocl_information8
    ,ocl_information9                = p_rec.ocl_information9
    ,ocl_information10               = p_rec.ocl_information10
    ,ocl_information11               = p_rec.ocl_information11
    ,ocl_information12               = p_rec.ocl_information12
    ,ocl_information13               = p_rec.ocl_information13
    ,ocl_information14               = p_rec.ocl_information14
    ,ocl_information15               = p_rec.ocl_information15
    ,ocl_information16               = p_rec.ocl_information16
    ,ocl_information17               = p_rec.ocl_information17
    ,ocl_information18               = p_rec.ocl_information18
    ,ocl_information19               = p_rec.ocl_information19
    ,ocl_information20               = p_rec.ocl_information20
    where competence_language_id = p_rec.competence_language_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ota_ocl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_ocl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_ocl_shd.constraint_error
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
  (p_rec in ota_ocl_shd.g_rec_type
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
  ,p_rec                          in ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_ocl_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_competence_language_id
      => p_rec.competence_language_id
      ,p_competence_id
      => p_rec.competence_id
      ,p_language_code
      => p_rec.language_code
      ,p_min_proficiency_level_id
      => p_rec.min_proficiency_level_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_ocl_information_category
      => p_rec.ocl_information_category
      ,p_ocl_information1
      => p_rec.ocl_information1
      ,p_ocl_information2
      => p_rec.ocl_information2
      ,p_ocl_information3
      => p_rec.ocl_information3
      ,p_ocl_information4
      => p_rec.ocl_information4
      ,p_ocl_information5
      => p_rec.ocl_information5
      ,p_ocl_information6
      => p_rec.ocl_information6
      ,p_ocl_information7
      => p_rec.ocl_information7
      ,p_ocl_information8
      => p_rec.ocl_information8
      ,p_ocl_information9
      => p_rec.ocl_information9
      ,p_ocl_information10
      => p_rec.ocl_information10
      ,p_ocl_information11
      => p_rec.ocl_information11
      ,p_ocl_information12
      => p_rec.ocl_information12
      ,p_ocl_information13
      => p_rec.ocl_information13
      ,p_ocl_information14
      => p_rec.ocl_information14
      ,p_ocl_information15
      => p_rec.ocl_information15
      ,p_ocl_information16
      => p_rec.ocl_information16
      ,p_ocl_information17
      => p_rec.ocl_information17
      ,p_ocl_information18
      => p_rec.ocl_information18
      ,p_ocl_information19
      => p_rec.ocl_information19
      ,p_ocl_information20
      => p_rec.ocl_information20
      ,p_competence_id_o
      => ota_ocl_shd.g_old_rec.competence_id
      ,p_language_code_o
      => ota_ocl_shd.g_old_rec.language_code
      ,p_min_proficiency_level_id_o
      => ota_ocl_shd.g_old_rec.min_proficiency_level_id
      ,p_business_group_id_o
      => ota_ocl_shd.g_old_rec.business_group_id
      ,p_object_version_number_o
      => ota_ocl_shd.g_old_rec.object_version_number
      ,p_ocl_information_category_o
      => ota_ocl_shd.g_old_rec.ocl_information_category
      ,p_ocl_information1_o
      => ota_ocl_shd.g_old_rec.ocl_information1
      ,p_ocl_information2_o
      => ota_ocl_shd.g_old_rec.ocl_information2
      ,p_ocl_information3_o
      => ota_ocl_shd.g_old_rec.ocl_information3
      ,p_ocl_information4_o
      => ota_ocl_shd.g_old_rec.ocl_information4
      ,p_ocl_information5_o
      => ota_ocl_shd.g_old_rec.ocl_information5
      ,p_ocl_information6_o
      => ota_ocl_shd.g_old_rec.ocl_information6
      ,p_ocl_information7_o
      => ota_ocl_shd.g_old_rec.ocl_information7
      ,p_ocl_information8_o
      => ota_ocl_shd.g_old_rec.ocl_information8
      ,p_ocl_information9_o
      => ota_ocl_shd.g_old_rec.ocl_information9
      ,p_ocl_information10_o
      => ota_ocl_shd.g_old_rec.ocl_information10
      ,p_ocl_information11_o
      => ota_ocl_shd.g_old_rec.ocl_information11
      ,p_ocl_information12_o
      => ota_ocl_shd.g_old_rec.ocl_information12
      ,p_ocl_information13_o
      => ota_ocl_shd.g_old_rec.ocl_information13
      ,p_ocl_information14_o
      => ota_ocl_shd.g_old_rec.ocl_information14
      ,p_ocl_information15_o
      => ota_ocl_shd.g_old_rec.ocl_information15
      ,p_ocl_information16_o
      => ota_ocl_shd.g_old_rec.ocl_information16
      ,p_ocl_information17_o
      => ota_ocl_shd.g_old_rec.ocl_information17
      ,p_ocl_information18_o
      => ota_ocl_shd.g_old_rec.ocl_information18
      ,p_ocl_information19_o
      => ota_ocl_shd.g_old_rec.ocl_information19
      ,p_ocl_information20_o
      => ota_ocl_shd.g_old_rec.ocl_information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_COMPETENCE_LANGUAGES'
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
  (p_rec in out nocopy ota_ocl_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.competence_id = hr_api.g_number) then
    p_rec.competence_id :=
    ota_ocl_shd.g_old_rec.competence_id;
  End If;
  If (p_rec.language_code = hr_api.g_varchar2) then
    p_rec.language_code :=
    ota_ocl_shd.g_old_rec.language_code;
  End If;
  If (p_rec.min_proficiency_level_id = hr_api.g_number) then
    p_rec.min_proficiency_level_id :=
    ota_ocl_shd.g_old_rec.min_proficiency_level_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ota_ocl_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.ocl_information_category = hr_api.g_varchar2) then
    p_rec.ocl_information_category :=
    ota_ocl_shd.g_old_rec.ocl_information_category;
  End If;
  If (p_rec.ocl_information1 = hr_api.g_varchar2) then
    p_rec.ocl_information1 :=
    ota_ocl_shd.g_old_rec.ocl_information1;
  End If;
  If (p_rec.ocl_information2 = hr_api.g_varchar2) then
    p_rec.ocl_information2 :=
    ota_ocl_shd.g_old_rec.ocl_information2;
  End If;
  If (p_rec.ocl_information3 = hr_api.g_varchar2) then
    p_rec.ocl_information3 :=
    ota_ocl_shd.g_old_rec.ocl_information3;
  End If;
  If (p_rec.ocl_information4 = hr_api.g_varchar2) then
    p_rec.ocl_information4 :=
    ota_ocl_shd.g_old_rec.ocl_information4;
  End If;
  If (p_rec.ocl_information5 = hr_api.g_varchar2) then
    p_rec.ocl_information5 :=
    ota_ocl_shd.g_old_rec.ocl_information5;
  End If;
  If (p_rec.ocl_information6 = hr_api.g_varchar2) then
    p_rec.ocl_information6 :=
    ota_ocl_shd.g_old_rec.ocl_information6;
  End If;
  If (p_rec.ocl_information7 = hr_api.g_varchar2) then
    p_rec.ocl_information7 :=
    ota_ocl_shd.g_old_rec.ocl_information7;
  End If;
  If (p_rec.ocl_information8 = hr_api.g_varchar2) then
    p_rec.ocl_information8 :=
    ota_ocl_shd.g_old_rec.ocl_information8;
  End If;
  If (p_rec.ocl_information9 = hr_api.g_varchar2) then
    p_rec.ocl_information9 :=
    ota_ocl_shd.g_old_rec.ocl_information9;
  End If;
  If (p_rec.ocl_information10 = hr_api.g_varchar2) then
    p_rec.ocl_information10 :=
    ota_ocl_shd.g_old_rec.ocl_information10;
  End If;
  If (p_rec.ocl_information11 = hr_api.g_varchar2) then
    p_rec.ocl_information11 :=
    ota_ocl_shd.g_old_rec.ocl_information11;
  End If;
  If (p_rec.ocl_information12 = hr_api.g_varchar2) then
    p_rec.ocl_information12 :=
    ota_ocl_shd.g_old_rec.ocl_information12;
  End If;
  If (p_rec.ocl_information13 = hr_api.g_varchar2) then
    p_rec.ocl_information13 :=
    ota_ocl_shd.g_old_rec.ocl_information13;
  End If;
  If (p_rec.ocl_information14 = hr_api.g_varchar2) then
    p_rec.ocl_information14 :=
    ota_ocl_shd.g_old_rec.ocl_information14;
  End If;
  If (p_rec.ocl_information15 = hr_api.g_varchar2) then
    p_rec.ocl_information15 :=
    ota_ocl_shd.g_old_rec.ocl_information15;
  End If;
  If (p_rec.ocl_information16 = hr_api.g_varchar2) then
    p_rec.ocl_information16 :=
    ota_ocl_shd.g_old_rec.ocl_information16;
  End If;
  If (p_rec.ocl_information17 = hr_api.g_varchar2) then
    p_rec.ocl_information17 :=
    ota_ocl_shd.g_old_rec.ocl_information17;
  End If;
  If (p_rec.ocl_information18 = hr_api.g_varchar2) then
    p_rec.ocl_information18 :=
    ota_ocl_shd.g_old_rec.ocl_information18;
  End If;
  If (p_rec.ocl_information19 = hr_api.g_varchar2) then
    p_rec.ocl_information19 :=
    ota_ocl_shd.g_old_rec.ocl_information19;
  End If;
  If (p_rec.ocl_information20 = hr_api.g_varchar2) then
    p_rec.ocl_information20 :=
    ota_ocl_shd.g_old_rec.ocl_information20;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ota_ocl_shd.lck
    (p_rec.competence_language_id
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
  ota_ocl_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  ota_ocl_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ota_ocl_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ota_ocl_upd.post_update
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
  ,p_competence_language_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_competence_id                in     number    default hr_api.g_number
  ,p_language_code                  in     varchar2    default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_min_proficiency_level_id     in     number    default hr_api.g_number
  ,p_ocl_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information1             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information2             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information3             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information4             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information5             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information6             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information7             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information8             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information9             in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information10            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information11            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information12            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information13            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information14            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information15            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information16            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information17            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information18            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information19            in     varchar2  default hr_api.g_varchar2
  ,p_ocl_information20            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  ota_ocl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_ocl_shd.convert_args
  (p_competence_language_id
  ,p_competence_id
  ,p_language_code
  ,p_min_proficiency_level_id
  ,p_business_group_id
  ,p_object_version_number
  ,p_ocl_information_category
  ,p_ocl_information1
  ,p_ocl_information2
  ,p_ocl_information3
  ,p_ocl_information4
  ,p_ocl_information5
  ,p_ocl_information6
  ,p_ocl_information7
  ,p_ocl_information8
  ,p_ocl_information9
  ,p_ocl_information10
  ,p_ocl_information11
  ,p_ocl_information12
  ,p_ocl_information13
  ,p_ocl_information14
  ,p_ocl_information15
  ,p_ocl_information16
  ,p_ocl_information17
  ,p_ocl_information18
  ,p_ocl_information19
  ,p_ocl_information20
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ota_ocl_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_ocl_upd;

/
