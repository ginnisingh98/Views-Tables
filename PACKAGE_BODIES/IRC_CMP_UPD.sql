--------------------------------------------------------
--  DDL for Package Body IRC_CMP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMP_UPD" as
/* $Header: ircmprhi.pkb 120.0 2007/11/19 11:38:55 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmp_upd.';  -- Global package name
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
  (p_rec in out nocopy irc_cmp_shd.g_rec_type
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
  -- Update the irc_comm_properties Row
  --
  update irc_comm_properties
    set
     communication_property_id       = p_rec.communication_property_id
    ,object_type                     = p_rec.object_type
    ,object_id                       = p_rec.object_id
    ,default_comm_status             = p_rec.default_comm_status
    ,allow_attachment_flag           = p_rec.allow_attachment_flag
    ,auto_notification_flag          = p_rec.auto_notification_flag
    ,allow_add_recipients            = p_rec.allow_add_recipients
    ,default_moderator               = p_rec.default_moderator
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
    ,object_version_number           = p_rec.object_version_number
    where communication_property_id = p_rec.communication_property_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    irc_cmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    irc_cmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_cmp_shd.constraint_error
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
  (p_rec in irc_cmp_shd.g_rec_type
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
  ,p_rec                          in irc_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_cmp_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_communication_property_id
      => p_rec.communication_property_id
      ,p_object_type
      => p_rec.object_type
      ,p_object_id
      => p_rec.object_id
      ,p_default_comm_status
      => p_rec.default_comm_status
      ,p_allow_attachment_flag
      => p_rec.allow_attachment_flag
      ,p_auto_notification_flag
      => p_rec.auto_notification_flag
      ,p_allow_add_recipients
      => p_rec.allow_add_recipients
      ,p_default_moderator
      => p_rec.default_moderator
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
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_object_type_o
      => irc_cmp_shd.g_old_rec.object_type
      ,p_object_id_o
      => irc_cmp_shd.g_old_rec.object_id
      ,p_default_comm_status_o
      => irc_cmp_shd.g_old_rec.default_comm_status
      ,p_allow_attachment_flag_o
      => irc_cmp_shd.g_old_rec.allow_attachment_flag
      ,p_auto_notification_flag_o
      => irc_cmp_shd.g_old_rec.auto_notification_flag
      ,p_allow_add_recipients_o
      => irc_cmp_shd.g_old_rec.allow_add_recipients
      ,p_default_moderator_o
      => irc_cmp_shd.g_old_rec.default_moderator
      ,p_attribute_category_o
      => irc_cmp_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => irc_cmp_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => irc_cmp_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => irc_cmp_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => irc_cmp_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => irc_cmp_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => irc_cmp_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => irc_cmp_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => irc_cmp_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => irc_cmp_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => irc_cmp_shd.g_old_rec.attribute10
      ,p_information_category_o
      => irc_cmp_shd.g_old_rec.information_category
      ,p_information1_o
      => irc_cmp_shd.g_old_rec.information1
      ,p_information2_o
      => irc_cmp_shd.g_old_rec.information2
      ,p_information3_o
      => irc_cmp_shd.g_old_rec.information3
      ,p_information4_o
      => irc_cmp_shd.g_old_rec.information4
      ,p_information5_o
      => irc_cmp_shd.g_old_rec.information5
      ,p_information6_o
      => irc_cmp_shd.g_old_rec.information6
      ,p_information7_o
      => irc_cmp_shd.g_old_rec.information7
      ,p_information8_o
      => irc_cmp_shd.g_old_rec.information8
      ,p_information9_o
      => irc_cmp_shd.g_old_rec.information9
      ,p_information10_o
      => irc_cmp_shd.g_old_rec.information10
      ,p_object_version_number_o
      => irc_cmp_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_COMM_PROPERTIES'
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
  (p_rec in out nocopy irc_cmp_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.object_type = hr_api.g_varchar2) then
    p_rec.object_type :=
    irc_cmp_shd.g_old_rec.object_type;
  End If;
  If (p_rec.object_id = hr_api.g_number) then
    p_rec.object_id :=
    irc_cmp_shd.g_old_rec.object_id;
  End If;
  If (p_rec.default_comm_status = hr_api.g_varchar2) then
    p_rec.default_comm_status :=
    irc_cmp_shd.g_old_rec.default_comm_status;
  End If;
  If (p_rec.allow_attachment_flag = hr_api.g_varchar2) then
    p_rec.allow_attachment_flag :=
    irc_cmp_shd.g_old_rec.allow_attachment_flag;
  End If;
  If (p_rec.auto_notification_flag = hr_api.g_varchar2) then
    p_rec.auto_notification_flag :=
    irc_cmp_shd.g_old_rec.auto_notification_flag;
  End If;
  If (p_rec.allow_add_recipients = hr_api.g_varchar2) then
    p_rec.allow_add_recipients :=
    irc_cmp_shd.g_old_rec.allow_add_recipients;
  End If;
  If (p_rec.default_moderator = hr_api.g_varchar2) then
    p_rec.default_moderator :=
    irc_cmp_shd.g_old_rec.default_moderator;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    irc_cmp_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    irc_cmp_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    irc_cmp_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    irc_cmp_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    irc_cmp_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    irc_cmp_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    irc_cmp_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    irc_cmp_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    irc_cmp_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    irc_cmp_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    irc_cmp_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    irc_cmp_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    irc_cmp_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    irc_cmp_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    irc_cmp_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    irc_cmp_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    irc_cmp_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    irc_cmp_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    irc_cmp_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    irc_cmp_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    irc_cmp_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    irc_cmp_shd.g_old_rec.information10;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  irc_cmp_shd.lck
    (p_rec.communication_property_id
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
  irc_cmp_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  irc_cmp_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  irc_cmp_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  --irc_cmp_upd.post_update
  --   (p_effective_date
  --   ,p_rec
  --   );
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
  ,p_communication_property_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_object_type                  in     varchar2  default hr_api.g_varchar2
  ,p_object_id                    in     number    default hr_api.g_number
  ,p_default_comm_status          in     varchar2  default hr_api.g_varchar2
  ,p_allow_attachment_flag        in     varchar2  default hr_api.g_varchar2
  ,p_auto_notification_flag       in     varchar2  default hr_api.g_varchar2
  ,p_allow_add_recipients         in     varchar2  default hr_api.g_varchar2
  ,p_default_moderator            in     varchar2  default hr_api.g_varchar2
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
  ) is
--
  l_rec   irc_cmp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  irc_cmp_shd.convert_args
  (p_communication_property_id
  ,p_object_type
  ,p_object_id
  ,p_default_comm_status
  ,p_allow_attachment_flag
  ,p_auto_notification_flag
  ,p_allow_add_recipients
  ,p_default_moderator
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
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_cmp_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end irc_cmp_upd;

/
