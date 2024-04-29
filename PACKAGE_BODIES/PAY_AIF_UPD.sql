--------------------------------------------------------
--  DDL for Package Body PAY_AIF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AIF_UPD" as
/* $Header: pyaifrhi.pkb 120.2.12000000.2 2007/03/30 05:34:36 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aif_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_aif_shd.g_rec_type
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
  -- Update the pay_action_information Row
  --
  update pay_action_information
    set
     action_information_id           = p_rec.action_information_id
    ,object_version_number           = p_rec.object_version_number
    ,action_information1             = p_rec.action_information1
    ,action_information2             = p_rec.action_information2
    ,action_information3             = p_rec.action_information3
    ,action_information4             = p_rec.action_information4
    ,action_information5             = p_rec.action_information5
    ,action_information6             = p_rec.action_information6
    ,action_information7             = p_rec.action_information7
    ,action_information8             = p_rec.action_information8
    ,action_information9             = p_rec.action_information9
    ,action_information10            = p_rec.action_information10
    ,action_information11            = p_rec.action_information11
    ,action_information12            = p_rec.action_information12
    ,action_information13            = p_rec.action_information13
    ,action_information14            = p_rec.action_information14
    ,action_information15            = p_rec.action_information15
    ,action_information16            = p_rec.action_information16
    ,action_information17            = p_rec.action_information17
    ,action_information18            = p_rec.action_information18
    ,action_information19            = p_rec.action_information19
    ,action_information20            = p_rec.action_information20
    ,action_information21            = p_rec.action_information21
    ,action_information22            = p_rec.action_information22
    ,action_information23            = p_rec.action_information23
    ,action_information24            = p_rec.action_information24
    ,action_information25            = p_rec.action_information25
    ,action_information26            = p_rec.action_information26
    ,action_information27            = p_rec.action_information27
    ,action_information28            = p_rec.action_information28
    ,action_information29            = p_rec.action_information29
    ,action_information30            = p_rec.action_information30
    where action_information_id = p_rec.action_information_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_aif_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_aif_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_aif_shd.constraint_error
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
  (p_rec in pay_aif_shd.g_rec_type
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
  (p_rec                          in pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_aif_rku.after_update
      (p_action_information_id
      => p_rec.action_information_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_action_information1
      => p_rec.action_information1
      ,p_action_information2
      => p_rec.action_information2
      ,p_action_information3
      => p_rec.action_information3
      ,p_action_information4
      => p_rec.action_information4
      ,p_action_information5
      => p_rec.action_information5
      ,p_action_information6
      => p_rec.action_information6
      ,p_action_information7
      => p_rec.action_information7
      ,p_action_information8
      => p_rec.action_information8
      ,p_action_information9
      => p_rec.action_information9
      ,p_action_information10
      => p_rec.action_information10
      ,p_action_information11
      => p_rec.action_information11
      ,p_action_information12
      => p_rec.action_information12
      ,p_action_information13
      => p_rec.action_information13
      ,p_action_information14
      => p_rec.action_information14
      ,p_action_information15
      => p_rec.action_information15
      ,p_action_information16
      => p_rec.action_information16
      ,p_action_information17
      => p_rec.action_information17
      ,p_action_information18
      => p_rec.action_information18
      ,p_action_information19
      => p_rec.action_information19
      ,p_action_information20
      => p_rec.action_information20
      ,p_action_information21
      => p_rec.action_information21
      ,p_action_information22
      => p_rec.action_information22
      ,p_action_information23
      => p_rec.action_information23
      ,p_action_information24
      => p_rec.action_information24
      ,p_action_information25
      => p_rec.action_information25
      ,p_action_information26
      => p_rec.action_information26
      ,p_action_information27
      => p_rec.action_information27
      ,p_action_information28
      => p_rec.action_information28
      ,p_action_information29
      => p_rec.action_information29
      ,p_action_information30
      => p_rec.action_information30
      ,p_action_context_id_o
      => pay_aif_shd.g_old_rec.action_context_id
      ,p_action_context_type_o
      => pay_aif_shd.g_old_rec.action_context_type
      ,p_tax_unit_id_o
      => pay_aif_shd.g_old_rec.tax_unit_id
      ,p_jurisdiction_code_o
      => pay_aif_shd.g_old_rec.jurisdiction_code
      ,p_source_id_o
      => pay_aif_shd.g_old_rec.source_id
      ,p_source_text_o
      => pay_aif_shd.g_old_rec.source_text
      ,p_tax_group_o
      => pay_aif_shd.g_old_rec.tax_group
      ,p_object_version_number_o
      => pay_aif_shd.g_old_rec.object_version_number
      ,p_effective_date_o
      => pay_aif_shd.g_old_rec.effective_date
      ,p_assignment_id_o
      => pay_aif_shd.g_old_rec.assignment_id
      ,p_action_information_categor_o
      => pay_aif_shd.g_old_rec.action_information_category
      ,p_action_information1_o
      => pay_aif_shd.g_old_rec.action_information1
      ,p_action_information2_o
      => pay_aif_shd.g_old_rec.action_information2
      ,p_action_information3_o
      => pay_aif_shd.g_old_rec.action_information3
      ,p_action_information4_o
      => pay_aif_shd.g_old_rec.action_information4
      ,p_action_information5_o
      => pay_aif_shd.g_old_rec.action_information5
      ,p_action_information6_o
      => pay_aif_shd.g_old_rec.action_information6
      ,p_action_information7_o
      => pay_aif_shd.g_old_rec.action_information7
      ,p_action_information8_o
      => pay_aif_shd.g_old_rec.action_information8
      ,p_action_information9_o
      => pay_aif_shd.g_old_rec.action_information9
      ,p_action_information10_o
      => pay_aif_shd.g_old_rec.action_information10
      ,p_action_information11_o
      => pay_aif_shd.g_old_rec.action_information11
      ,p_action_information12_o
      => pay_aif_shd.g_old_rec.action_information12
      ,p_action_information13_o
      => pay_aif_shd.g_old_rec.action_information13
      ,p_action_information14_o
      => pay_aif_shd.g_old_rec.action_information14
      ,p_action_information15_o
      => pay_aif_shd.g_old_rec.action_information15
      ,p_action_information16_o
      => pay_aif_shd.g_old_rec.action_information16
      ,p_action_information17_o
      => pay_aif_shd.g_old_rec.action_information17
      ,p_action_information18_o
      => pay_aif_shd.g_old_rec.action_information18
      ,p_action_information19_o
      => pay_aif_shd.g_old_rec.action_information19
      ,p_action_information20_o
      => pay_aif_shd.g_old_rec.action_information20
      ,p_action_information21_o
      => pay_aif_shd.g_old_rec.action_information21
      ,p_action_information22_o
      => pay_aif_shd.g_old_rec.action_information22
      ,p_action_information23_o
      => pay_aif_shd.g_old_rec.action_information23
      ,p_action_information24_o
      => pay_aif_shd.g_old_rec.action_information24
      ,p_action_information25_o
      => pay_aif_shd.g_old_rec.action_information25
      ,p_action_information26_o
      => pay_aif_shd.g_old_rec.action_information26
      ,p_action_information27_o
      => pay_aif_shd.g_old_rec.action_information27
      ,p_action_information28_o
      => pay_aif_shd.g_old_rec.action_information28
      ,p_action_information29_o
      => pay_aif_shd.g_old_rec.action_information29
      ,p_action_information30_o
      => pay_aif_shd.g_old_rec.action_information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ACTION_INFORMATION'
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
  (p_rec in out nocopy pay_aif_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.action_context_id = hr_api.g_number) then
    p_rec.action_context_id :=
    pay_aif_shd.g_old_rec.action_context_id;
  End If;
  If (p_rec.action_context_type = hr_api.g_varchar2) then
    p_rec.action_context_type :=
    pay_aif_shd.g_old_rec.action_context_type;
  End If;
  If (p_rec.tax_unit_id = hr_api.g_number) then
    p_rec.tax_unit_id :=
    pay_aif_shd.g_old_rec.tax_unit_id;
  End If;
  If (p_rec.jurisdiction_code = hr_api.g_varchar2) then
    p_rec.jurisdiction_code :=
    pay_aif_shd.g_old_rec.jurisdiction_code;
  End If;
  If (p_rec.source_id = hr_api.g_number) then
    p_rec.source_id :=
    pay_aif_shd.g_old_rec.source_id;
  End If;
  If (p_rec.source_text = hr_api.g_varchar2) then
    p_rec.source_text :=
    pay_aif_shd.g_old_rec.source_text;
  End If;
  If (p_rec.tax_group = hr_api.g_varchar2) then
    p_rec.tax_group :=
    pay_aif_shd.g_old_rec.tax_group;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date :=
    pay_aif_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pay_aif_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.action_information_category = hr_api.g_varchar2) then
    p_rec.action_information_category :=
    pay_aif_shd.g_old_rec.action_information_category;
  End If;
  If (p_rec.action_information1 = hr_api.g_varchar2) then
    p_rec.action_information1 :=
    pay_aif_shd.g_old_rec.action_information1;
  End If;
  If (p_rec.action_information2 = hr_api.g_varchar2) then
    p_rec.action_information2 :=
    pay_aif_shd.g_old_rec.action_information2;
  End If;
  If (p_rec.action_information3 = hr_api.g_varchar2) then
    p_rec.action_information3 :=
    pay_aif_shd.g_old_rec.action_information3;
  End If;
  If (p_rec.action_information4 = hr_api.g_varchar2) then
    p_rec.action_information4 :=
    pay_aif_shd.g_old_rec.action_information4;
  End If;
  If (p_rec.action_information5 = hr_api.g_varchar2) then
    p_rec.action_information5 :=
    pay_aif_shd.g_old_rec.action_information5;
  End If;
  If (p_rec.action_information6 = hr_api.g_varchar2) then
    p_rec.action_information6 :=
    pay_aif_shd.g_old_rec.action_information6;
  End If;
  If (p_rec.action_information7 = hr_api.g_varchar2) then
    p_rec.action_information7 :=
    pay_aif_shd.g_old_rec.action_information7;
  End If;
  If (p_rec.action_information8 = hr_api.g_varchar2) then
    p_rec.action_information8 :=
    pay_aif_shd.g_old_rec.action_information8;
  End If;
  If (p_rec.action_information9 = hr_api.g_varchar2) then
    p_rec.action_information9 :=
    pay_aif_shd.g_old_rec.action_information9;
  End If;
  If (p_rec.action_information10 = hr_api.g_varchar2) then
    p_rec.action_information10 :=
    pay_aif_shd.g_old_rec.action_information10;
  End If;
  If (p_rec.action_information11 = hr_api.g_varchar2) then
    p_rec.action_information11 :=
    pay_aif_shd.g_old_rec.action_information11;
  End If;
  If (p_rec.action_information12 = hr_api.g_varchar2) then
    p_rec.action_information12 :=
    pay_aif_shd.g_old_rec.action_information12;
  End If;
  If (p_rec.action_information13 = hr_api.g_varchar2) then
    p_rec.action_information13 :=
    pay_aif_shd.g_old_rec.action_information13;
  End If;
  If (p_rec.action_information14 = hr_api.g_varchar2) then
    p_rec.action_information14 :=
    pay_aif_shd.g_old_rec.action_information14;
  End If;
  If (p_rec.action_information15 = hr_api.g_varchar2) then
    p_rec.action_information15 :=
    pay_aif_shd.g_old_rec.action_information15;
  End If;
  If (p_rec.action_information16 = hr_api.g_varchar2) then
    p_rec.action_information16 :=
    pay_aif_shd.g_old_rec.action_information16;
  End If;
  If (p_rec.action_information17 = hr_api.g_varchar2) then
    p_rec.action_information17 :=
    pay_aif_shd.g_old_rec.action_information17;
  End If;
  If (p_rec.action_information18 = hr_api.g_varchar2) then
    p_rec.action_information18 :=
    pay_aif_shd.g_old_rec.action_information18;
  End If;
  If (p_rec.action_information19 = hr_api.g_varchar2) then
    p_rec.action_information19 :=
    pay_aif_shd.g_old_rec.action_information19;
  End If;
  If (p_rec.action_information20 = hr_api.g_varchar2) then
    p_rec.action_information20 :=
    pay_aif_shd.g_old_rec.action_information20;
  End If;
  If (p_rec.action_information21 = hr_api.g_varchar2) then
    p_rec.action_information21 :=
    pay_aif_shd.g_old_rec.action_information21;
  End If;
  If (p_rec.action_information22 = hr_api.g_varchar2) then
    p_rec.action_information22 :=
    pay_aif_shd.g_old_rec.action_information22;
  End If;
  If (p_rec.action_information23 = hr_api.g_varchar2) then
    p_rec.action_information23 :=
    pay_aif_shd.g_old_rec.action_information23;
  End If;
  If (p_rec.action_information24 = hr_api.g_varchar2) then
    p_rec.action_information24 :=
    pay_aif_shd.g_old_rec.action_information24;
  End If;
  If (p_rec.action_information25 = hr_api.g_varchar2) then
    p_rec.action_information25 :=
    pay_aif_shd.g_old_rec.action_information25;
  End If;
  If (p_rec.action_information26 = hr_api.g_varchar2) then
    p_rec.action_information26 :=
    pay_aif_shd.g_old_rec.action_information26;
  End If;
  If (p_rec.action_information27 = hr_api.g_varchar2) then
    p_rec.action_information27 :=
    pay_aif_shd.g_old_rec.action_information27;
  End If;
  If (p_rec.action_information28 = hr_api.g_varchar2) then
    p_rec.action_information28 :=
    pay_aif_shd.g_old_rec.action_information28;
  End If;
  If (p_rec.action_information29 = hr_api.g_varchar2) then
    p_rec.action_information29 :=
    pay_aif_shd.g_old_rec.action_information29;
  End If;
  If (p_rec.action_information30 = hr_api.g_varchar2) then
    p_rec.action_information30 :=
    pay_aif_shd.g_old_rec.action_information30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_aif_shd.lck
    (p_rec.action_information_id
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
  pay_aif_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_aif_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_aif_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_aif_upd.post_update
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_action_information_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_action_information1          in     varchar2  default hr_api.g_varchar2
  ,p_action_information2          in     varchar2  default hr_api.g_varchar2
  ,p_action_information3          in     varchar2  default hr_api.g_varchar2
  ,p_action_information4          in     varchar2  default hr_api.g_varchar2
  ,p_action_information5          in     varchar2  default hr_api.g_varchar2
  ,p_action_information6          in     varchar2  default hr_api.g_varchar2
  ,p_action_information7          in     varchar2  default hr_api.g_varchar2
  ,p_action_information8          in     varchar2  default hr_api.g_varchar2
  ,p_action_information9          in     varchar2  default hr_api.g_varchar2
  ,p_action_information10         in     varchar2  default hr_api.g_varchar2
  ,p_action_information11         in     varchar2  default hr_api.g_varchar2
  ,p_action_information12         in     varchar2  default hr_api.g_varchar2
  ,p_action_information13         in     varchar2  default hr_api.g_varchar2
  ,p_action_information14         in     varchar2  default hr_api.g_varchar2
  ,p_action_information15         in     varchar2  default hr_api.g_varchar2
  ,p_action_information16         in     varchar2  default hr_api.g_varchar2
  ,p_action_information17         in     varchar2  default hr_api.g_varchar2
  ,p_action_information18         in     varchar2  default hr_api.g_varchar2
  ,p_action_information19         in     varchar2  default hr_api.g_varchar2
  ,p_action_information20         in     varchar2  default hr_api.g_varchar2
  ,p_action_information21         in     varchar2  default hr_api.g_varchar2
  ,p_action_information22         in     varchar2  default hr_api.g_varchar2
  ,p_action_information23         in     varchar2  default hr_api.g_varchar2
  ,p_action_information24         in     varchar2  default hr_api.g_varchar2
  ,p_action_information25         in     varchar2  default hr_api.g_varchar2
  ,p_action_information26         in     varchar2  default hr_api.g_varchar2
  ,p_action_information27         in     varchar2  default hr_api.g_varchar2
  ,p_action_information28         in     varchar2  default hr_api.g_varchar2
  ,p_action_information29         in     varchar2  default hr_api.g_varchar2
  ,p_action_information30         in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  pay_aif_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_aif_shd.convert_args
  (p_action_information_id
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,hr_api.g_varchar2
  ,p_object_version_number
  ,hr_api.g_date
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,p_action_information1
  ,p_action_information2
  ,p_action_information3
  ,p_action_information4
  ,p_action_information5
  ,p_action_information6
  ,p_action_information7
  ,p_action_information8
  ,p_action_information9
  ,p_action_information10
  ,p_action_information11
  ,p_action_information12
  ,p_action_information13
  ,p_action_information14
  ,p_action_information15
  ,p_action_information16
  ,p_action_information17
  ,p_action_information18
  ,p_action_information19
  ,p_action_information20
  ,p_action_information21
  ,p_action_information22
  ,p_action_information23
  ,p_action_information24
  ,p_action_information25
  ,p_action_information26
  ,p_action_information27
  ,p_action_information28
  ,p_action_information29
  ,p_action_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_aif_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_aif_upd;

/
