--------------------------------------------------------
--  DDL for Package Body OTA_RUD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RUD_UPD" as
/* $Header: otrudrhi.pkb 120.2 2005/09/08 06:34:32 pgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_rud_upd.';  -- Global package name
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
  (p_rec in out nocopy ota_rud_shd.g_rec_type
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
  -- Update the ota_resource_usages Row
  --
  update ota_resource_usages
    set
     resource_usage_id               = p_rec.resource_usage_id
    ,supplied_resource_id            = p_rec.supplied_resource_id
    ,activity_version_id             = p_rec.activity_version_id
    ,object_version_number           = p_rec.object_version_number
    ,required_flag                   = p_rec.required_flag
    ,start_date                      = p_rec.start_date
    ,comments                        = p_rec.comments
    ,end_date                        = p_rec.end_date
    ,quantity                        = p_rec.quantity
    ,resource_type                   = p_rec.resource_type
    ,role_to_play                    = p_rec.role_to_play
    ,usage_reason                    = p_rec.usage_reason
    ,rud_information_category        = p_rec.rud_information_category
    ,rud_information1                = p_rec.rud_information1
    ,rud_information2                = p_rec.rud_information2
    ,rud_information3                = p_rec.rud_information3
    ,rud_information4                = p_rec.rud_information4
    ,rud_information5                = p_rec.rud_information5
    ,rud_information6                = p_rec.rud_information6
    ,rud_information7                = p_rec.rud_information7
    ,rud_information8                = p_rec.rud_information8
    ,rud_information9                = p_rec.rud_information9
    ,rud_information10               = p_rec.rud_information10
    ,rud_information11               = p_rec.rud_information11
    ,rud_information12               = p_rec.rud_information12
    ,rud_information13               = p_rec.rud_information13
    ,rud_information14               = p_rec.rud_information14
    ,rud_information15               = p_rec.rud_information15
    ,rud_information16               = p_rec.rud_information16
    ,rud_information17               = p_rec.rud_information17
    ,rud_information18               = p_rec.rud_information18
    ,rud_information19               = p_rec.rud_information19
    ,rud_information20               = p_rec.rud_information20
    ,offering_id                     = p_rec.offering_id
    where resource_usage_id = p_rec.resource_usage_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ota_rud_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_rud_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_rud_shd.constraint_error
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
  (p_rec in ota_rud_shd.g_rec_type
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
  ,p_rec                          in ota_rud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_rud_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_resource_usage_id
      => p_rec.resource_usage_id
      ,p_supplied_resource_id
      => p_rec.supplied_resource_id
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_required_flag
      => p_rec.required_flag
      ,p_start_date
      => p_rec.start_date
      ,p_comments
      => p_rec.comments
      ,p_end_date
      => p_rec.end_date
      ,p_quantity
      => p_rec.quantity
      ,p_resource_type
      => p_rec.resource_type
      ,p_role_to_play
      => p_rec.role_to_play
      ,p_usage_reason
      => p_rec.usage_reason
      ,p_rud_information_category
      => p_rec.rud_information_category
      ,p_rud_information1
      => p_rec.rud_information1
      ,p_rud_information2
      => p_rec.rud_information2
      ,p_rud_information3
      => p_rec.rud_information3
      ,p_rud_information4
      => p_rec.rud_information4
      ,p_rud_information5
      => p_rec.rud_information5
      ,p_rud_information6
      => p_rec.rud_information6
      ,p_rud_information7
      => p_rec.rud_information7
      ,p_rud_information8
      => p_rec.rud_information8
      ,p_rud_information9
      => p_rec.rud_information9
      ,p_rud_information10
      => p_rec.rud_information10
      ,p_rud_information11
      => p_rec.rud_information11
      ,p_rud_information12
      => p_rec.rud_information12
      ,p_rud_information13
      => p_rec.rud_information13
      ,p_rud_information14
      => p_rec.rud_information14
      ,p_rud_information15
      => p_rec.rud_information15
      ,p_rud_information16
      => p_rec.rud_information16
      ,p_rud_information17
      => p_rec.rud_information17
      ,p_rud_information18
      => p_rec.rud_information18
      ,p_rud_information19
      => p_rec.rud_information19
      ,p_rud_information20
      => p_rec.rud_information20
      ,p_offering_id
      => p_rec.offering_id
      ,p_supplied_resource_id_o
      => ota_rud_shd.g_old_rec.supplied_resource_id
      ,p_activity_version_id_o
      => ota_rud_shd.g_old_rec.activity_version_id
      ,p_object_version_number_o
      => ota_rud_shd.g_old_rec.object_version_number
      ,p_required_flag_o
      => ota_rud_shd.g_old_rec.required_flag
      ,p_start_date_o
      => ota_rud_shd.g_old_rec.start_date
      ,p_comments_o
      => ota_rud_shd.g_old_rec.comments
      ,p_end_date_o
      => ota_rud_shd.g_old_rec.end_date
      ,p_quantity_o
      => ota_rud_shd.g_old_rec.quantity
      ,p_resource_type_o
      => ota_rud_shd.g_old_rec.resource_type
      ,p_role_to_play_o
      => ota_rud_shd.g_old_rec.role_to_play
      ,p_usage_reason_o
      => ota_rud_shd.g_old_rec.usage_reason
      ,p_rud_information_category_o
      => ota_rud_shd.g_old_rec.rud_information_category
      ,p_rud_information1_o
      => ota_rud_shd.g_old_rec.rud_information1
      ,p_rud_information2_o
      => ota_rud_shd.g_old_rec.rud_information2
      ,p_rud_information3_o
      => ota_rud_shd.g_old_rec.rud_information3
      ,p_rud_information4_o
      => ota_rud_shd.g_old_rec.rud_information4
      ,p_rud_information5_o
      => ota_rud_shd.g_old_rec.rud_information5
      ,p_rud_information6_o
      => ota_rud_shd.g_old_rec.rud_information6
      ,p_rud_information7_o
      => ota_rud_shd.g_old_rec.rud_information7
      ,p_rud_information8_o
      => ota_rud_shd.g_old_rec.rud_information8
      ,p_rud_information9_o
      => ota_rud_shd.g_old_rec.rud_information9
      ,p_rud_information10_o
      => ota_rud_shd.g_old_rec.rud_information10
      ,p_rud_information11_o
      => ota_rud_shd.g_old_rec.rud_information11
      ,p_rud_information12_o
      => ota_rud_shd.g_old_rec.rud_information12
      ,p_rud_information13_o
      => ota_rud_shd.g_old_rec.rud_information13
      ,p_rud_information14_o
      => ota_rud_shd.g_old_rec.rud_information14
      ,p_rud_information15_o
      => ota_rud_shd.g_old_rec.rud_information15
      ,p_rud_information16_o
      => ota_rud_shd.g_old_rec.rud_information16
      ,p_rud_information17_o
      => ota_rud_shd.g_old_rec.rud_information17
      ,p_rud_information18_o
      => ota_rud_shd.g_old_rec.rud_information18
      ,p_rud_information19_o
      => ota_rud_shd.g_old_rec.rud_information19
      ,p_rud_information20_o
      => ota_rud_shd.g_old_rec.rud_information20
      ,p_offering_id_o
      => ota_rud_shd.g_old_rec.offering_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_RESOURCE_USAGES'
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
  (p_rec in out nocopy ota_rud_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.supplied_resource_id = hr_api.g_number) then
    p_rec.supplied_resource_id :=
    ota_rud_shd.g_old_rec.supplied_resource_id;
  End If;
  If (p_rec.activity_version_id = hr_api.g_number) then
    p_rec.activity_version_id :=
    ota_rud_shd.g_old_rec.activity_version_id;
  End If;
  If (p_rec.required_flag = hr_api.g_varchar2) then
    p_rec.required_flag :=
    ota_rud_shd.g_old_rec.required_flag;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    ota_rud_shd.g_old_rec.start_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_rud_shd.g_old_rec.comments;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    ota_rud_shd.g_old_rec.end_date;
  End If;
  If (p_rec.quantity = hr_api.g_number) then
    p_rec.quantity :=
    ota_rud_shd.g_old_rec.quantity;
  End If;
  If (p_rec.resource_type = hr_api.g_varchar2) then
    p_rec.resource_type :=
    ota_rud_shd.g_old_rec.resource_type;
  End If;
  If (p_rec.role_to_play = hr_api.g_varchar2) then
    p_rec.role_to_play :=
    ota_rud_shd.g_old_rec.role_to_play;
  End If;
  If (p_rec.usage_reason = hr_api.g_varchar2) then
    p_rec.usage_reason :=
    ota_rud_shd.g_old_rec.usage_reason;
  End If;
  If (p_rec.rud_information_category = hr_api.g_varchar2) then
    p_rec.rud_information_category :=
    ota_rud_shd.g_old_rec.rud_information_category;
  End If;
  If (p_rec.rud_information1 = hr_api.g_varchar2) then
    p_rec.rud_information1 :=
    ota_rud_shd.g_old_rec.rud_information1;
  End If;
  If (p_rec.rud_information2 = hr_api.g_varchar2) then
    p_rec.rud_information2 :=
    ota_rud_shd.g_old_rec.rud_information2;
  End If;
  If (p_rec.rud_information3 = hr_api.g_varchar2) then
    p_rec.rud_information3 :=
    ota_rud_shd.g_old_rec.rud_information3;
  End If;
  If (p_rec.rud_information4 = hr_api.g_varchar2) then
    p_rec.rud_information4 :=
    ota_rud_shd.g_old_rec.rud_information4;
  End If;
  If (p_rec.rud_information5 = hr_api.g_varchar2) then
    p_rec.rud_information5 :=
    ota_rud_shd.g_old_rec.rud_information5;
  End If;
  If (p_rec.rud_information6 = hr_api.g_varchar2) then
    p_rec.rud_information6 :=
    ota_rud_shd.g_old_rec.rud_information6;
  End If;
  If (p_rec.rud_information7 = hr_api.g_varchar2) then
    p_rec.rud_information7 :=
    ota_rud_shd.g_old_rec.rud_information7;
  End If;
  If (p_rec.rud_information8 = hr_api.g_varchar2) then
    p_rec.rud_information8 :=
    ota_rud_shd.g_old_rec.rud_information8;
  End If;
  If (p_rec.rud_information9 = hr_api.g_varchar2) then
    p_rec.rud_information9 :=
    ota_rud_shd.g_old_rec.rud_information9;
  End If;
  If (p_rec.rud_information10 = hr_api.g_varchar2) then
    p_rec.rud_information10 :=
    ota_rud_shd.g_old_rec.rud_information10;
  End If;
  If (p_rec.rud_information11 = hr_api.g_varchar2) then
    p_rec.rud_information11 :=
    ota_rud_shd.g_old_rec.rud_information11;
  End If;
  If (p_rec.rud_information12 = hr_api.g_varchar2) then
    p_rec.rud_information12 :=
    ota_rud_shd.g_old_rec.rud_information12;
  End If;
  If (p_rec.rud_information13 = hr_api.g_varchar2) then
    p_rec.rud_information13 :=
    ota_rud_shd.g_old_rec.rud_information13;
  End If;
  If (p_rec.rud_information14 = hr_api.g_varchar2) then
    p_rec.rud_information14 :=
    ota_rud_shd.g_old_rec.rud_information14;
  End If;
  If (p_rec.rud_information15 = hr_api.g_varchar2) then
    p_rec.rud_information15 :=
    ota_rud_shd.g_old_rec.rud_information15;
  End If;
  If (p_rec.rud_information16 = hr_api.g_varchar2) then
    p_rec.rud_information16 :=
    ota_rud_shd.g_old_rec.rud_information16;
  End If;
  If (p_rec.rud_information17 = hr_api.g_varchar2) then
    p_rec.rud_information17 :=
    ota_rud_shd.g_old_rec.rud_information17;
  End If;
  If (p_rec.rud_information18 = hr_api.g_varchar2) then
    p_rec.rud_information18 :=
    ota_rud_shd.g_old_rec.rud_information18;
  End If;
  If (p_rec.rud_information19 = hr_api.g_varchar2) then
    p_rec.rud_information19 :=
    ota_rud_shd.g_old_rec.rud_information19;
  End If;
  If (p_rec.rud_information20 = hr_api.g_varchar2) then
    p_rec.rud_information20 :=
    ota_rud_shd.g_old_rec.rud_information20;
  End If;
  If (p_rec.offering_id = hr_api.g_number) then
    p_rec.offering_id :=
    ota_rud_shd.g_old_rec.offering_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_rud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ota_rud_shd.lck
    (p_rec.resource_usage_id
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
  ota_rud_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ota_rud_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ota_rud_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ota_rud_upd.post_update
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
  ,p_resource_usage_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_supplied_resource_id         in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_quantity                     in     number    default hr_api.g_number
  ,p_resource_type                in     varchar2  default hr_api.g_varchar2
  ,p_role_to_play                 in     varchar2  default hr_api.g_varchar2
  ,p_usage_reason                 in     varchar2  default hr_api.g_varchar2
  ,p_rud_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_rud_information1             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information2             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information3             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information4             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information5             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information6             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information7             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information8             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information9             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information10            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information11            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information12            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information13            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information14            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information15            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information16            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information17            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information18            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information19            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information20            in     varchar2  default hr_api.g_varchar2
  ,p_offering_id                  in     number    default hr_api.g_number
  ) is
--
  l_rec   ota_rud_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_rud_shd.convert_args
  (p_resource_usage_id
  ,p_supplied_resource_id
  ,p_activity_version_id
  ,p_object_version_number
  ,p_required_flag
  ,p_start_date
  ,p_comments
  ,p_end_date
  ,p_quantity
  ,p_resource_type
  ,p_role_to_play
  ,p_usage_reason
  ,p_rud_information_category
  ,p_rud_information1
  ,p_rud_information2
  ,p_rud_information3
  ,p_rud_information4
  ,p_rud_information5
  ,p_rud_information6
  ,p_rud_information7
  ,p_rud_information8
  ,p_rud_information9
  ,p_rud_information10
  ,p_rud_information11
  ,p_rud_information12
  ,p_rud_information13
  ,p_rud_information14
  ,p_rud_information15
  ,p_rud_information16
  ,p_rud_information17
  ,p_rud_information18
  ,p_rud_information19
  ,p_rud_information20
  ,p_offering_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ota_rud_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_rud_upd;

/
