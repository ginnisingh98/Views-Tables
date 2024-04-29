--------------------------------------------------------
--  DDL for Package Body PAY_ETM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ETM_UPD" as
/* $Header: pyetmrhi.pkb 120.0 2005/05/29 04:42:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_etm_upd.';  -- Global package name
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
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
Procedure update_dml(p_rec in out nocopy pay_etm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  -- Update the pay_element_templates Row
  --
  update pay_element_templates
  set
  base_processing_priority          = p_rec.base_processing_priority,
  version_number                    = p_rec.version_number,
  max_base_name_length              = p_rec.max_base_name_length,
  preference_info_category          = p_rec.preference_info_category,
  preference_information1           = p_rec.preference_information1,
  preference_information2           = p_rec.preference_information2,
  preference_information3           = p_rec.preference_information3,
  preference_information4           = p_rec.preference_information4,
  preference_information5           = p_rec.preference_information5,
  preference_information6           = p_rec.preference_information6,
  preference_information7           = p_rec.preference_information7,
  preference_information8           = p_rec.preference_information8,
  preference_information9           = p_rec.preference_information9,
  preference_information10          = p_rec.preference_information10,
  preference_information11          = p_rec.preference_information11,
  preference_information12          = p_rec.preference_information12,
  preference_information13          = p_rec.preference_information13,
  preference_information14          = p_rec.preference_information14,
  preference_information15          = p_rec.preference_information15,
  preference_information16          = p_rec.preference_information16,
  preference_information17          = p_rec.preference_information17,
  preference_information18          = p_rec.preference_information18,
  preference_information19          = p_rec.preference_information19,
  preference_information20          = p_rec.preference_information20,
  preference_information21          = p_rec.preference_information21,
  preference_information22          = p_rec.preference_information22,
  preference_information23          = p_rec.preference_information23,
  preference_information24          = p_rec.preference_information24,
  preference_information25          = p_rec.preference_information25,
  preference_information26          = p_rec.preference_information26,
  preference_information27          = p_rec.preference_information27,
  preference_information28          = p_rec.preference_information28,
  preference_information29          = p_rec.preference_information29,
  preference_information30          = p_rec.preference_information30,
  configuration_info_category       = p_rec.configuration_info_category,
  configuration_information1        = p_rec.configuration_information1,
  configuration_information2        = p_rec.configuration_information2,
  configuration_information3        = p_rec.configuration_information3,
  configuration_information4        = p_rec.configuration_information4,
  configuration_information5        = p_rec.configuration_information5,
  configuration_information6        = p_rec.configuration_information6,
  configuration_information7        = p_rec.configuration_information7,
  configuration_information8        = p_rec.configuration_information8,
  configuration_information9        = p_rec.configuration_information9,
  configuration_information10       = p_rec.configuration_information10,
  configuration_information11       = p_rec.configuration_information11,
  configuration_information12       = p_rec.configuration_information12,
  configuration_information13       = p_rec.configuration_information13,
  configuration_information14       = p_rec.configuration_information14,
  configuration_information15       = p_rec.configuration_information15,
  configuration_information16       = p_rec.configuration_information16,
  configuration_information17       = p_rec.configuration_information17,
  configuration_information18       = p_rec.configuration_information18,
  configuration_information19       = p_rec.configuration_information19,
  configuration_information20       = p_rec.configuration_information20,
  configuration_information21       = p_rec.configuration_information21,
  configuration_information22       = p_rec.configuration_information22,
  configuration_information23       = p_rec.configuration_information23,
  configuration_information24       = p_rec.configuration_information24,
  configuration_information25       = p_rec.configuration_information25,
  configuration_information26       = p_rec.configuration_information26,
  configuration_information27       = p_rec.configuration_information27,
  configuration_information28       = p_rec.configuration_information28,
  configuration_information29       = p_rec.configuration_information29,
  configuration_information30       = p_rec.configuration_information30,
  object_version_number             = p_rec.object_version_number
  where template_id = p_rec.template_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_etm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_etm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_etm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
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
Procedure pre_update(p_rec in pay_etm_shd.g_rec_type) is
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
--   A Pl/Sql record structre.
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
Procedure post_update(p_rec in pay_etm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pay_etm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.template_type = hr_api.g_varchar2) then
    p_rec.template_type :=
    pay_etm_shd.g_old_rec.template_type;
  End If;
  If (p_rec.template_name = hr_api.g_varchar2) then
    p_rec.template_name :=
    pay_etm_shd.g_old_rec.template_name;
  End If;
  If (p_rec.base_processing_priority = hr_api.g_number) then
    p_rec.base_processing_priority :=
    pay_etm_shd.g_old_rec.base_processing_priority;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_etm_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_etm_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.version_number = hr_api.g_number) then
    p_rec.version_number :=
    pay_etm_shd.g_old_rec.version_number;
  End If;
  If (p_rec.base_name = hr_api.g_varchar2) then
    p_rec.base_name :=
    pay_etm_shd.g_old_rec.base_name;
  End If;
  If (p_rec.max_base_name_length = hr_api.g_number) then
    p_rec.max_base_name_length :=
    pay_etm_shd.g_old_rec.max_base_name_length;
  End If;
  If (p_rec.preference_info_category = hr_api.g_varchar2) then
    p_rec.preference_info_category :=
    pay_etm_shd.g_old_rec.preference_info_category;
  End If;
  If (p_rec.preference_information1 = hr_api.g_varchar2) then
    p_rec.preference_information1 :=
    pay_etm_shd.g_old_rec.preference_information1;
  End If;
  If (p_rec.preference_information2 = hr_api.g_varchar2) then
    p_rec.preference_information2 :=
    pay_etm_shd.g_old_rec.preference_information2;
  End If;
  If (p_rec.preference_information3 = hr_api.g_varchar2) then
    p_rec.preference_information3 :=
    pay_etm_shd.g_old_rec.preference_information3;
  End If;
  If (p_rec.preference_information4 = hr_api.g_varchar2) then
    p_rec.preference_information4 :=
    pay_etm_shd.g_old_rec.preference_information4;
  End If;
  If (p_rec.preference_information5 = hr_api.g_varchar2) then
    p_rec.preference_information5 :=
    pay_etm_shd.g_old_rec.preference_information5;
  End If;
  If (p_rec.preference_information6 = hr_api.g_varchar2) then
    p_rec.preference_information6 :=
    pay_etm_shd.g_old_rec.preference_information6;
  End If;
  If (p_rec.preference_information7 = hr_api.g_varchar2) then
    p_rec.preference_information7 :=
    pay_etm_shd.g_old_rec.preference_information7;
  End If;
  If (p_rec.preference_information8 = hr_api.g_varchar2) then
    p_rec.preference_information8 :=
    pay_etm_shd.g_old_rec.preference_information8;
  End If;
  If (p_rec.preference_information9 = hr_api.g_varchar2) then
    p_rec.preference_information9 :=
    pay_etm_shd.g_old_rec.preference_information9;
  End If;
  If (p_rec.preference_information10 = hr_api.g_varchar2) then
    p_rec.preference_information10 :=
    pay_etm_shd.g_old_rec.preference_information10;
  End If;
  If (p_rec.preference_information11 = hr_api.g_varchar2) then
    p_rec.preference_information11 :=
    pay_etm_shd.g_old_rec.preference_information11;
  End If;
  If (p_rec.preference_information12 = hr_api.g_varchar2) then
    p_rec.preference_information12 :=
    pay_etm_shd.g_old_rec.preference_information12;
  End If;
  If (p_rec.preference_information13 = hr_api.g_varchar2) then
    p_rec.preference_information13 :=
    pay_etm_shd.g_old_rec.preference_information13;
  End If;
  If (p_rec.preference_information14 = hr_api.g_varchar2) then
    p_rec.preference_information14 :=
    pay_etm_shd.g_old_rec.preference_information14;
  End If;
  If (p_rec.preference_information15 = hr_api.g_varchar2) then
    p_rec.preference_information15 :=
    pay_etm_shd.g_old_rec.preference_information15;
  End If;
  If (p_rec.preference_information16 = hr_api.g_varchar2) then
    p_rec.preference_information16 :=
    pay_etm_shd.g_old_rec.preference_information16;
  End If;
  If (p_rec.preference_information17 = hr_api.g_varchar2) then
    p_rec.preference_information17 :=
    pay_etm_shd.g_old_rec.preference_information17;
  End If;
  If (p_rec.preference_information18 = hr_api.g_varchar2) then
    p_rec.preference_information18 :=
    pay_etm_shd.g_old_rec.preference_information18;
  End If;
  If (p_rec.preference_information19 = hr_api.g_varchar2) then
    p_rec.preference_information19 :=
    pay_etm_shd.g_old_rec.preference_information19;
  End If;
  If (p_rec.preference_information20 = hr_api.g_varchar2) then
    p_rec.preference_information20 :=
    pay_etm_shd.g_old_rec.preference_information20;
  End If;
  If (p_rec.preference_information21 = hr_api.g_varchar2) then
    p_rec.preference_information21 :=
    pay_etm_shd.g_old_rec.preference_information21;
  End If;
  If (p_rec.preference_information22 = hr_api.g_varchar2) then
    p_rec.preference_information22 :=
    pay_etm_shd.g_old_rec.preference_information22;
  End If;
  If (p_rec.preference_information23 = hr_api.g_varchar2) then
    p_rec.preference_information23 :=
    pay_etm_shd.g_old_rec.preference_information23;
  End If;
  If (p_rec.preference_information24 = hr_api.g_varchar2) then
    p_rec.preference_information24 :=
    pay_etm_shd.g_old_rec.preference_information24;
  End If;
  If (p_rec.preference_information25 = hr_api.g_varchar2) then
    p_rec.preference_information25 :=
    pay_etm_shd.g_old_rec.preference_information25;
  End If;
  If (p_rec.preference_information26 = hr_api.g_varchar2) then
    p_rec.preference_information26 :=
    pay_etm_shd.g_old_rec.preference_information26;
  End If;
  If (p_rec.preference_information27 = hr_api.g_varchar2) then
    p_rec.preference_information27 :=
    pay_etm_shd.g_old_rec.preference_information27;
  End If;
  If (p_rec.preference_information28 = hr_api.g_varchar2) then
    p_rec.preference_information28 :=
    pay_etm_shd.g_old_rec.preference_information28;
  End If;
  If (p_rec.preference_information29 = hr_api.g_varchar2) then
    p_rec.preference_information29 :=
    pay_etm_shd.g_old_rec.preference_information29;
  End If;
  If (p_rec.preference_information30 = hr_api.g_varchar2) then
    p_rec.preference_information30 :=
    pay_etm_shd.g_old_rec.preference_information30;
  End If;
  If (p_rec.configuration_info_category = hr_api.g_varchar2) then
    p_rec.configuration_info_category :=
    pay_etm_shd.g_old_rec.configuration_info_category;
  End If;
  If (p_rec.configuration_information1 = hr_api.g_varchar2) then
    p_rec.configuration_information1 :=
    pay_etm_shd.g_old_rec.configuration_information1;
  End If;
  If (p_rec.configuration_information2 = hr_api.g_varchar2) then
    p_rec.configuration_information2 :=
    pay_etm_shd.g_old_rec.configuration_information2;
  End If;
  If (p_rec.configuration_information3 = hr_api.g_varchar2) then
    p_rec.configuration_information3 :=
    pay_etm_shd.g_old_rec.configuration_information3;
  End If;
  If (p_rec.configuration_information4 = hr_api.g_varchar2) then
    p_rec.configuration_information4 :=
    pay_etm_shd.g_old_rec.configuration_information4;
  End If;
  If (p_rec.configuration_information5 = hr_api.g_varchar2) then
    p_rec.configuration_information5 :=
    pay_etm_shd.g_old_rec.configuration_information5;
  End If;
  If (p_rec.configuration_information6 = hr_api.g_varchar2) then
    p_rec.configuration_information6 :=
    pay_etm_shd.g_old_rec.configuration_information6;
  End If;
  If (p_rec.configuration_information7 = hr_api.g_varchar2) then
    p_rec.configuration_information7 :=
    pay_etm_shd.g_old_rec.configuration_information7;
  End If;
  If (p_rec.configuration_information8 = hr_api.g_varchar2) then
    p_rec.configuration_information8 :=
    pay_etm_shd.g_old_rec.configuration_information8;
  End If;
  If (p_rec.configuration_information9 = hr_api.g_varchar2) then
    p_rec.configuration_information9 :=
    pay_etm_shd.g_old_rec.configuration_information9;
  End If;
  If (p_rec.configuration_information10 = hr_api.g_varchar2) then
    p_rec.configuration_information10 :=
    pay_etm_shd.g_old_rec.configuration_information10;
  End If;
  If (p_rec.configuration_information11 = hr_api.g_varchar2) then
    p_rec.configuration_information11 :=
    pay_etm_shd.g_old_rec.configuration_information11;
  End If;
  If (p_rec.configuration_information12 = hr_api.g_varchar2) then
    p_rec.configuration_information12 :=
    pay_etm_shd.g_old_rec.configuration_information12;
  End If;
  If (p_rec.configuration_information13 = hr_api.g_varchar2) then
    p_rec.configuration_information13 :=
    pay_etm_shd.g_old_rec.configuration_information13;
  End If;
  If (p_rec.configuration_information14 = hr_api.g_varchar2) then
    p_rec.configuration_information14 :=
    pay_etm_shd.g_old_rec.configuration_information14;
  End If;
  If (p_rec.configuration_information15 = hr_api.g_varchar2) then
    p_rec.configuration_information15 :=
    pay_etm_shd.g_old_rec.configuration_information15;
  End If;
  If (p_rec.configuration_information16 = hr_api.g_varchar2) then
    p_rec.configuration_information16 :=
    pay_etm_shd.g_old_rec.configuration_information16;
  End If;
  If (p_rec.configuration_information17 = hr_api.g_varchar2) then
    p_rec.configuration_information17 :=
    pay_etm_shd.g_old_rec.configuration_information17;
  End If;
  If (p_rec.configuration_information18 = hr_api.g_varchar2) then
    p_rec.configuration_information18 :=
    pay_etm_shd.g_old_rec.configuration_information18;
  End If;
  If (p_rec.configuration_information19 = hr_api.g_varchar2) then
    p_rec.configuration_information19 :=
    pay_etm_shd.g_old_rec.configuration_information19;
  End If;
  If (p_rec.configuration_information20 = hr_api.g_varchar2) then
    p_rec.configuration_information20 :=
    pay_etm_shd.g_old_rec.configuration_information20;
  End If;
  If (p_rec.configuration_information21 = hr_api.g_varchar2) then
    p_rec.configuration_information21 :=
    pay_etm_shd.g_old_rec.configuration_information21;
  End If;
  If (p_rec.configuration_information22 = hr_api.g_varchar2) then
    p_rec.configuration_information22 :=
    pay_etm_shd.g_old_rec.configuration_information22;
  End If;
  If (p_rec.configuration_information23 = hr_api.g_varchar2) then
    p_rec.configuration_information23 :=
    pay_etm_shd.g_old_rec.configuration_information23;
  End If;
  If (p_rec.configuration_information24 = hr_api.g_varchar2) then
    p_rec.configuration_information24 :=
    pay_etm_shd.g_old_rec.configuration_information24;
  End If;
  If (p_rec.configuration_information25 = hr_api.g_varchar2) then
    p_rec.configuration_information25 :=
    pay_etm_shd.g_old_rec.configuration_information25;
  End If;
  If (p_rec.configuration_information26 = hr_api.g_varchar2) then
    p_rec.configuration_information26 :=
    pay_etm_shd.g_old_rec.configuration_information26;
  End If;
  If (p_rec.configuration_information27 = hr_api.g_varchar2) then
    p_rec.configuration_information27 :=
    pay_etm_shd.g_old_rec.configuration_information27;
  End If;
  If (p_rec.configuration_information28 = hr_api.g_varchar2) then
    p_rec.configuration_information28 :=
    pay_etm_shd.g_old_rec.configuration_information28;
  End If;
  If (p_rec.configuration_information29 = hr_api.g_varchar2) then
    p_rec.configuration_information29 :=
    pay_etm_shd.g_old_rec.configuration_information29;
  End If;
  If (p_rec.configuration_information30 = hr_api.g_varchar2) then
    p_rec.configuration_information30 :=
    pay_etm_shd.g_old_rec.configuration_information30;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date  in     date
  ,p_rec             in out nocopy pay_etm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_etm_shd.lck
	(
	p_rec.template_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_etm_bus.update_validate(p_effective_date, p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_template_id                  in number,
  p_effective_date               in date,
  p_base_processing_priority     in number           default hr_api.g_number,
  p_version_number               in number           default hr_api.g_number,
  p_max_base_name_length         in number           default hr_api.g_number,
  p_preference_info_category     in varchar2         default hr_api.g_varchar2,
  p_preference_information1      in varchar2         default hr_api.g_varchar2,
  p_preference_information2      in varchar2         default hr_api.g_varchar2,
  p_preference_information3      in varchar2         default hr_api.g_varchar2,
  p_preference_information4      in varchar2         default hr_api.g_varchar2,
  p_preference_information5      in varchar2         default hr_api.g_varchar2,
  p_preference_information6      in varchar2         default hr_api.g_varchar2,
  p_preference_information7      in varchar2         default hr_api.g_varchar2,
  p_preference_information8      in varchar2         default hr_api.g_varchar2,
  p_preference_information9      in varchar2         default hr_api.g_varchar2,
  p_preference_information10     in varchar2         default hr_api.g_varchar2,
  p_preference_information11     in varchar2         default hr_api.g_varchar2,
  p_preference_information12     in varchar2         default hr_api.g_varchar2,
  p_preference_information13     in varchar2         default hr_api.g_varchar2,
  p_preference_information14     in varchar2         default hr_api.g_varchar2,
  p_preference_information15     in varchar2         default hr_api.g_varchar2,
  p_preference_information16     in varchar2         default hr_api.g_varchar2,
  p_preference_information17     in varchar2         default hr_api.g_varchar2,
  p_preference_information18     in varchar2         default hr_api.g_varchar2,
  p_preference_information19     in varchar2         default hr_api.g_varchar2,
  p_preference_information20     in varchar2         default hr_api.g_varchar2,
  p_preference_information21     in varchar2         default hr_api.g_varchar2,
  p_preference_information22     in varchar2         default hr_api.g_varchar2,
  p_preference_information23     in varchar2         default hr_api.g_varchar2,
  p_preference_information24     in varchar2         default hr_api.g_varchar2,
  p_preference_information25     in varchar2         default hr_api.g_varchar2,
  p_preference_information26     in varchar2         default hr_api.g_varchar2,
  p_preference_information27     in varchar2         default hr_api.g_varchar2,
  p_preference_information28     in varchar2         default hr_api.g_varchar2,
  p_preference_information29     in varchar2         default hr_api.g_varchar2,
  p_preference_information30     in varchar2         default hr_api.g_varchar2,
  p_configuration_info_category  in varchar2         default hr_api.g_varchar2,
  p_configuration_information1   in varchar2         default hr_api.g_varchar2,
  p_configuration_information2   in varchar2         default hr_api.g_varchar2,
  p_configuration_information3   in varchar2         default hr_api.g_varchar2,
  p_configuration_information4   in varchar2         default hr_api.g_varchar2,
  p_configuration_information5   in varchar2         default hr_api.g_varchar2,
  p_configuration_information6   in varchar2         default hr_api.g_varchar2,
  p_configuration_information7   in varchar2         default hr_api.g_varchar2,
  p_configuration_information8   in varchar2         default hr_api.g_varchar2,
  p_configuration_information9   in varchar2         default hr_api.g_varchar2,
  p_configuration_information10  in varchar2         default hr_api.g_varchar2,
  p_configuration_information11  in varchar2         default hr_api.g_varchar2,
  p_configuration_information12  in varchar2         default hr_api.g_varchar2,
  p_configuration_information13  in varchar2         default hr_api.g_varchar2,
  p_configuration_information14  in varchar2         default hr_api.g_varchar2,
  p_configuration_information15  in varchar2         default hr_api.g_varchar2,
  p_configuration_information16  in varchar2         default hr_api.g_varchar2,
  p_configuration_information17  in varchar2         default hr_api.g_varchar2,
  p_configuration_information18  in varchar2         default hr_api.g_varchar2,
  p_configuration_information19  in varchar2         default hr_api.g_varchar2,
  p_configuration_information20  in varchar2         default hr_api.g_varchar2,
  p_configuration_information21  in varchar2         default hr_api.g_varchar2,
  p_configuration_information22  in varchar2         default hr_api.g_varchar2,
  p_configuration_information23  in varchar2         default hr_api.g_varchar2,
  p_configuration_information24  in varchar2         default hr_api.g_varchar2,
  p_configuration_information25  in varchar2         default hr_api.g_varchar2,
  p_configuration_information26  in varchar2         default hr_api.g_varchar2,
  p_configuration_information27  in varchar2         default hr_api.g_varchar2,
  p_configuration_information28  in varchar2         default hr_api.g_varchar2,
  p_configuration_information29  in varchar2         default hr_api.g_varchar2,
  p_configuration_information30  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  pay_etm_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_etm_shd.convert_args
  (
  p_template_id,
  hr_api.g_varchar2,
  hr_api.g_varchar2,
  p_base_processing_priority,
  hr_api.g_number,
  hr_api.g_varchar2,
  p_version_number,
  hr_api.g_varchar2,
  p_max_base_name_length,
  p_preference_info_category,
  p_preference_information1,
  p_preference_information2,
  p_preference_information3,
  p_preference_information4,
  p_preference_information5,
  p_preference_information6,
  p_preference_information7,
  p_preference_information8,
  p_preference_information9,
  p_preference_information10,
  p_preference_information11,
  p_preference_information12,
  p_preference_information13,
  p_preference_information14,
  p_preference_information15,
  p_preference_information16,
  p_preference_information17,
  p_preference_information18,
  p_preference_information19,
  p_preference_information20,
  p_preference_information21,
  p_preference_information22,
  p_preference_information23,
  p_preference_information24,
  p_preference_information25,
  p_preference_information26,
  p_preference_information27,
  p_preference_information28,
  p_preference_information29,
  p_preference_information30,
  p_configuration_info_category,
  p_configuration_information1,
  p_configuration_information2,
  p_configuration_information3,
  p_configuration_information4,
  p_configuration_information5,
  p_configuration_information6,
  p_configuration_information7,
  p_configuration_information8,
  p_configuration_information9,
  p_configuration_information10,
  p_configuration_information11,
  p_configuration_information12,
  p_configuration_information13,
  p_configuration_information14,
  p_configuration_information15,
  p_configuration_information16,
  p_configuration_information17,
  p_configuration_information18,
  p_configuration_information19,
  p_configuration_information20,
  p_configuration_information21,
  p_configuration_information22,
  p_configuration_information23,
  p_configuration_information24,
  p_configuration_information25,
  p_configuration_information26,
  p_configuration_information27,
  p_configuration_information28,
  p_configuration_information29,
  p_configuration_information30,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(p_effective_date, l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_etm_upd;

/
