--------------------------------------------------------
--  DDL for Package Body OTA_ACI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACI_UPD" as
/* $Header: otacirhi.pkb 120.0 2005/05/29 06:51:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_aci_upd.';  -- Global package name
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
  (p_rec in out nocopy ota_aci_shd.g_rec_type
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
  ota_aci_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_act_cat_inclusions Row
  --
  update ota_act_cat_inclusions
    set
     activity_version_id             = p_rec.activity_version_id
    ,activity_category               = p_rec.activity_category
    ,object_version_number           = p_rec.object_version_number
    ,event_id                        = p_rec.event_id
    ,comments                        = p_rec.comments
    ,aci_information_category        = p_rec.aci_information_category
    ,aci_information1                = p_rec.aci_information1
    ,aci_information2                = p_rec.aci_information2
    ,aci_information3                = p_rec.aci_information3
    ,aci_information4                = p_rec.aci_information4
    ,aci_information5                = p_rec.aci_information5
    ,aci_information6                = p_rec.aci_information6
    ,aci_information7                = p_rec.aci_information7
    ,aci_information8                = p_rec.aci_information8
    ,aci_information9                = p_rec.aci_information9
    ,aci_information10               = p_rec.aci_information10
    ,aci_information11               = p_rec.aci_information11
    ,aci_information12               = p_rec.aci_information12
    ,aci_information13               = p_rec.aci_information13
    ,aci_information14               = p_rec.aci_information14
    ,aci_information15               = p_rec.aci_information15
    ,aci_information16               = p_rec.aci_information16
    ,aci_information17               = p_rec.aci_information17
    ,aci_information18               = p_rec.aci_information18
    ,aci_information19               = p_rec.aci_information19
    ,aci_information20               = p_rec.aci_information20
    ,start_date_active               = p_rec.start_date_active
    ,end_date_active                 = p_rec.end_date_active
    ,primary_flag                    = p_rec.primary_flag
    ,category_usage_id               = p_rec.category_usage_id
    where activity_version_id = p_rec.activity_version_id
    and category_usage_id = p_rec.category_usage_id;
  --
  ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
    ota_aci_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
    ota_aci_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
    ota_aci_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in ota_aci_shd.g_rec_type
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
  ,p_rec                          in ota_aci_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_aci_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_activity_category
      => p_rec.activity_category
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_event_id
      => p_rec.event_id
      ,p_comments
      => p_rec.comments
      ,p_aci_information_category
      => p_rec.aci_information_category
      ,p_aci_information1
      => p_rec.aci_information1
      ,p_aci_information2
      => p_rec.aci_information2
      ,p_aci_information3
      => p_rec.aci_information3
      ,p_aci_information4
      => p_rec.aci_information4
      ,p_aci_information5
      => p_rec.aci_information5
      ,p_aci_information6
      => p_rec.aci_information6
      ,p_aci_information7
      => p_rec.aci_information7
      ,p_aci_information8
      => p_rec.aci_information8
      ,p_aci_information9
      => p_rec.aci_information9
      ,p_aci_information10
      => p_rec.aci_information10
      ,p_aci_information11
      => p_rec.aci_information11
      ,p_aci_information12
      => p_rec.aci_information12
      ,p_aci_information13
      => p_rec.aci_information13
      ,p_aci_information14
      => p_rec.aci_information14
      ,p_aci_information15
      => p_rec.aci_information15
      ,p_aci_information16
      => p_rec.aci_information16
      ,p_aci_information17
      => p_rec.aci_information17
      ,p_aci_information18
      => p_rec.aci_information18
      ,p_aci_information19
      => p_rec.aci_information19
      ,p_aci_information20
      => p_rec.aci_information20
      ,p_start_date_active
      => p_rec.start_date_active
      ,p_end_date_active
      => p_rec.end_date_active
      ,p_primary_flag
      => p_rec.primary_flag
      ,p_category_usage_id
      => p_rec.category_usage_id
      ,p_activity_category_o
      => ota_aci_shd.g_old_rec.activity_category
      ,p_object_version_number_o
      => ota_aci_shd.g_old_rec.object_version_number
      ,p_event_id_o
      => ota_aci_shd.g_old_rec.event_id
      ,p_comments_o
      => ota_aci_shd.g_old_rec.comments
      ,p_aci_information_category_o
      => ota_aci_shd.g_old_rec.aci_information_category
      ,p_aci_information1_o
      => ota_aci_shd.g_old_rec.aci_information1
      ,p_aci_information2_o
      => ota_aci_shd.g_old_rec.aci_information2
      ,p_aci_information3_o
      => ota_aci_shd.g_old_rec.aci_information3
      ,p_aci_information4_o
      => ota_aci_shd.g_old_rec.aci_information4
      ,p_aci_information5_o
      => ota_aci_shd.g_old_rec.aci_information5
      ,p_aci_information6_o
      => ota_aci_shd.g_old_rec.aci_information6
      ,p_aci_information7_o
      => ota_aci_shd.g_old_rec.aci_information7
      ,p_aci_information8_o
      => ota_aci_shd.g_old_rec.aci_information8
      ,p_aci_information9_o
      => ota_aci_shd.g_old_rec.aci_information9
      ,p_aci_information10_o
      => ota_aci_shd.g_old_rec.aci_information10
      ,p_aci_information11_o
      => ota_aci_shd.g_old_rec.aci_information11
      ,p_aci_information12_o
      => ota_aci_shd.g_old_rec.aci_information12
      ,p_aci_information13_o
      => ota_aci_shd.g_old_rec.aci_information13
      ,p_aci_information14_o
      => ota_aci_shd.g_old_rec.aci_information14
      ,p_aci_information15_o
      => ota_aci_shd.g_old_rec.aci_information15
      ,p_aci_information16_o
      => ota_aci_shd.g_old_rec.aci_information16
      ,p_aci_information17_o
      => ota_aci_shd.g_old_rec.aci_information17
      ,p_aci_information18_o
      => ota_aci_shd.g_old_rec.aci_information18
      ,p_aci_information19_o
      => ota_aci_shd.g_old_rec.aci_information19
      ,p_aci_information20_o
      => ota_aci_shd.g_old_rec.aci_information20
      ,p_start_date_active_o
      => ota_aci_shd.g_old_rec.start_date_active
      ,p_end_date_active_o
      => ota_aci_shd.g_old_rec.end_date_active
      ,p_primary_flag_o
      => ota_aci_shd.g_old_rec.primary_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_ACT_CAT_INCLUSIONS'
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
  (p_rec in out nocopy ota_aci_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.activity_category = hr_api.g_varchar2) then
    p_rec.activity_category :=
    ota_aci_shd.g_old_rec.activity_category;
  End If;
  If (p_rec.event_id = hr_api.g_number) then
    p_rec.event_id :=
    ota_aci_shd.g_old_rec.event_id;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_aci_shd.g_old_rec.comments;
  End If;
  If (p_rec.aci_information_category = hr_api.g_varchar2) then
    p_rec.aci_information_category :=
    ota_aci_shd.g_old_rec.aci_information_category;
  End If;
  If (p_rec.aci_information1 = hr_api.g_varchar2) then
    p_rec.aci_information1 :=
    ota_aci_shd.g_old_rec.aci_information1;
  End If;
  If (p_rec.aci_information2 = hr_api.g_varchar2) then
    p_rec.aci_information2 :=
    ota_aci_shd.g_old_rec.aci_information2;
  End If;
  If (p_rec.aci_information3 = hr_api.g_varchar2) then
    p_rec.aci_information3 :=
    ota_aci_shd.g_old_rec.aci_information3;
  End If;
  If (p_rec.aci_information4 = hr_api.g_varchar2) then
    p_rec.aci_information4 :=
    ota_aci_shd.g_old_rec.aci_information4;
  End If;
  If (p_rec.aci_information5 = hr_api.g_varchar2) then
    p_rec.aci_information5 :=
    ota_aci_shd.g_old_rec.aci_information5;
  End If;
  If (p_rec.aci_information6 = hr_api.g_varchar2) then
    p_rec.aci_information6 :=
    ota_aci_shd.g_old_rec.aci_information6;
  End If;
  If (p_rec.aci_information7 = hr_api.g_varchar2) then
    p_rec.aci_information7 :=
    ota_aci_shd.g_old_rec.aci_information7;
  End If;
  If (p_rec.aci_information8 = hr_api.g_varchar2) then
    p_rec.aci_information8 :=
    ota_aci_shd.g_old_rec.aci_information8;
  End If;
  If (p_rec.aci_information9 = hr_api.g_varchar2) then
    p_rec.aci_information9 :=
    ota_aci_shd.g_old_rec.aci_information9;
  End If;
  If (p_rec.aci_information10 = hr_api.g_varchar2) then
    p_rec.aci_information10 :=
    ota_aci_shd.g_old_rec.aci_information10;
  End If;
  If (p_rec.aci_information11 = hr_api.g_varchar2) then
    p_rec.aci_information11 :=
    ota_aci_shd.g_old_rec.aci_information11;
  End If;
  If (p_rec.aci_information12 = hr_api.g_varchar2) then
    p_rec.aci_information12 :=
    ota_aci_shd.g_old_rec.aci_information12;
  End If;
  If (p_rec.aci_information13 = hr_api.g_varchar2) then
    p_rec.aci_information13 :=
    ota_aci_shd.g_old_rec.aci_information13;
  End If;
  If (p_rec.aci_information14 = hr_api.g_varchar2) then
    p_rec.aci_information14 :=
    ota_aci_shd.g_old_rec.aci_information14;
  End If;
  If (p_rec.aci_information15 = hr_api.g_varchar2) then
    p_rec.aci_information15 :=
    ota_aci_shd.g_old_rec.aci_information15;
  End If;
  If (p_rec.aci_information16 = hr_api.g_varchar2) then
    p_rec.aci_information16 :=
    ota_aci_shd.g_old_rec.aci_information16;
  End If;
  If (p_rec.aci_information17 = hr_api.g_varchar2) then
    p_rec.aci_information17 :=
    ota_aci_shd.g_old_rec.aci_information17;
  End If;
  If (p_rec.aci_information18 = hr_api.g_varchar2) then
    p_rec.aci_information18 :=
    ota_aci_shd.g_old_rec.aci_information18;
  End If;
  If (p_rec.aci_information19 = hr_api.g_varchar2) then
    p_rec.aci_information19 :=
    ota_aci_shd.g_old_rec.aci_information19;
  End If;
  If (p_rec.aci_information20 = hr_api.g_varchar2) then
    p_rec.aci_information20 :=
    ota_aci_shd.g_old_rec.aci_information20;
  End If;
  If (p_rec.start_date_active = hr_api.g_date) then
    p_rec.start_date_active :=
    ota_aci_shd.g_old_rec.start_date_active;
  End If;
  If (p_rec.end_date_active = hr_api.g_date) then
    p_rec.end_date_active :=
    ota_aci_shd.g_old_rec.end_date_active;
  End If;
  If (p_rec.primary_flag = hr_api.g_varchar2) then
    p_rec.primary_flag :=
    ota_aci_shd.g_old_rec.primary_flag;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_aci_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ota_aci_shd.lck
    (p_rec.activity_version_id
    ,p_rec.category_usage_id
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
  ota_aci_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ota_aci_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ota_aci_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ota_aci_upd.post_update
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
  ,p_activity_version_id          in     number
  ,p_category_usage_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_activity_category            in     varchar2  default hr_api.g_varchar2
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_aci_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_aci_information1             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information2             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information3             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information4             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information5             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information6             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information7             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information8             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information9             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information10            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information11            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information12            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information13            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information14            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information15            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information16            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information17            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information18            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information19            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information20            in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_primary_flag                 in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ota_aci_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_aci_shd.convert_args
  (p_activity_version_id
  ,p_activity_category
  ,p_object_version_number
  ,p_event_id
  ,p_comments
  ,p_aci_information_category
  ,p_aci_information1
  ,p_aci_information2
  ,p_aci_information3
  ,p_aci_information4
  ,p_aci_information5
  ,p_aci_information6
  ,p_aci_information7
  ,p_aci_information8
  ,p_aci_information9
  ,p_aci_information10
  ,p_aci_information11
  ,p_aci_information12
  ,p_aci_information13
  ,p_aci_information14
  ,p_aci_information15
  ,p_aci_information16
  ,p_aci_information17
  ,p_aci_information18
  ,p_aci_information19
  ,p_aci_information20
  ,p_start_date_active
  ,p_end_date_active
  ,p_primary_flag
  ,p_category_usage_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ota_aci_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_aci_upd;

/
