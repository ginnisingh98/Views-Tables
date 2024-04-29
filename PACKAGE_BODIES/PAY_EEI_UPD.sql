--------------------------------------------------------
--  DDL for Package Body PAY_EEI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EEI_UPD" as
/* $Header: pyeeirhi.pkb 120.11 2006/07/12 05:28:45 vikgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_eei_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_eei_shd.g_rec_type
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
  pay_eei_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_element_type_extra_info Row
  --
  update pay_element_type_extra_info
    set
     element_type_extra_info_id      = p_rec.element_type_extra_info_id
    ,element_type_id                 = p_rec.element_type_id
    ,information_type                = p_rec.information_type
    ,request_id                      = p_rec.request_id
    ,program_application_id          = p_rec.program_application_id
    ,program_id                      = p_rec.program_id
    ,program_update_date             = p_rec.program_update_date
    ,eei_attribute_category          = p_rec.eei_attribute_category
    ,eei_attribute1                  = p_rec.eei_attribute1
    ,eei_attribute2                  = p_rec.eei_attribute2
    ,eei_attribute3                  = p_rec.eei_attribute3
    ,eei_attribute4                  = p_rec.eei_attribute4
    ,eei_attribute5                  = p_rec.eei_attribute5
    ,eei_attribute6                  = p_rec.eei_attribute6
    ,eei_attribute7                  = p_rec.eei_attribute7
    ,eei_attribute8                  = p_rec.eei_attribute8
    ,eei_attribute9                  = p_rec.eei_attribute9
    ,eei_attribute10                 = p_rec.eei_attribute10
    ,eei_attribute11                 = p_rec.eei_attribute11
    ,eei_attribute12                 = p_rec.eei_attribute12
    ,eei_attribute13                 = p_rec.eei_attribute13
    ,eei_attribute14                 = p_rec.eei_attribute14
    ,eei_attribute15                 = p_rec.eei_attribute15
    ,eei_attribute16                 = p_rec.eei_attribute16
    ,eei_attribute17                 = p_rec.eei_attribute17
    ,eei_attribute18                 = p_rec.eei_attribute18
    ,eei_attribute19                 = p_rec.eei_attribute19
    ,eei_attribute20                 = p_rec.eei_attribute20
    ,eei_information_category        = p_rec.eei_information_category
    ,eei_information1                = p_rec.eei_information1
    ,eei_information2                = p_rec.eei_information2
    ,eei_information3                = p_rec.eei_information3
    ,eei_information4                = p_rec.eei_information4
    ,eei_information5                = p_rec.eei_information5
    ,eei_information6                = p_rec.eei_information6
    ,eei_information7                = p_rec.eei_information7
    ,eei_information8                = p_rec.eei_information8
    ,eei_information9                = p_rec.eei_information9
    ,eei_information10               = p_rec.eei_information10
    ,eei_information11               = p_rec.eei_information11
    ,eei_information12               = p_rec.eei_information12
    ,eei_information13               = p_rec.eei_information13
    ,eei_information14               = p_rec.eei_information14
    ,eei_information15               = p_rec.eei_information15
    ,eei_information16               = p_rec.eei_information16
    ,eei_information17               = p_rec.eei_information17
    ,eei_information18               = p_rec.eei_information18
    ,eei_information19               = p_rec.eei_information19
    ,eei_information20               = p_rec.eei_information20
    ,eei_information21               = p_rec.eei_information21
    ,eei_information22               = p_rec.eei_information22
    ,eei_information23               = p_rec.eei_information23
    ,eei_information24               = p_rec.eei_information24
    ,eei_information25               = p_rec.eei_information25
    ,eei_information26               = p_rec.eei_information26
    ,eei_information27               = p_rec.eei_information27
    ,eei_information28               = p_rec.eei_information28
    ,eei_information29               = p_rec.eei_information29
    ,eei_information30               = p_rec.eei_information30
    ,object_version_number           = p_rec.object_version_number
    where element_type_extra_info_id = p_rec.element_type_extra_info_id;
  --
  pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
    pay_eei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
    pay_eei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
    pay_eei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pay_eei_shd.g_rec_type
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
  (p_rec                          in pay_eei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_eei_rku.after_update
      (p_element_type_extra_info_id
      => p_rec.element_type_extra_info_id
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_information_type
      => p_rec.information_type
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_eei_attribute_category
      => p_rec.eei_attribute_category
      ,p_eei_attribute1
      => p_rec.eei_attribute1
      ,p_eei_attribute2
      => p_rec.eei_attribute2
      ,p_eei_attribute3
      => p_rec.eei_attribute3
      ,p_eei_attribute4
      => p_rec.eei_attribute4
      ,p_eei_attribute5
      => p_rec.eei_attribute5
      ,p_eei_attribute6
      => p_rec.eei_attribute6
      ,p_eei_attribute7
      => p_rec.eei_attribute7
      ,p_eei_attribute8
      => p_rec.eei_attribute8
      ,p_eei_attribute9
      => p_rec.eei_attribute9
      ,p_eei_attribute10
      => p_rec.eei_attribute10
      ,p_eei_attribute11
      => p_rec.eei_attribute11
      ,p_eei_attribute12
      => p_rec.eei_attribute12
      ,p_eei_attribute13
      => p_rec.eei_attribute13
      ,p_eei_attribute14
      => p_rec.eei_attribute14
      ,p_eei_attribute15
      => p_rec.eei_attribute15
      ,p_eei_attribute16
      => p_rec.eei_attribute16
      ,p_eei_attribute17
      => p_rec.eei_attribute17
      ,p_eei_attribute18
      => p_rec.eei_attribute18
      ,p_eei_attribute19
      => p_rec.eei_attribute19
      ,p_eei_attribute20
      => p_rec.eei_attribute20
      ,p_eei_information_category
      => p_rec.eei_information_category
      ,p_eei_information1
      => p_rec.eei_information1
      ,p_eei_information2
      => p_rec.eei_information2
      ,p_eei_information3
      => p_rec.eei_information3
      ,p_eei_information4
      => p_rec.eei_information4
      ,p_eei_information5
      => p_rec.eei_information5
      ,p_eei_information6
      => p_rec.eei_information6
      ,p_eei_information7
      => p_rec.eei_information7
      ,p_eei_information8
      => p_rec.eei_information8
      ,p_eei_information9
      => p_rec.eei_information9
      ,p_eei_information10
      => p_rec.eei_information10
      ,p_eei_information11
      => p_rec.eei_information11
      ,p_eei_information12
      => p_rec.eei_information12
      ,p_eei_information13
      => p_rec.eei_information13
      ,p_eei_information14
      => p_rec.eei_information14
      ,p_eei_information15
      => p_rec.eei_information15
      ,p_eei_information16
      => p_rec.eei_information16
      ,p_eei_information17
      => p_rec.eei_information17
      ,p_eei_information18
      => p_rec.eei_information18
      ,p_eei_information19
      => p_rec.eei_information19
      ,p_eei_information20
      => p_rec.eei_information20
      ,p_eei_information21
      => p_rec.eei_information21
      ,p_eei_information22
      => p_rec.eei_information22
      ,p_eei_information23
      => p_rec.eei_information23
      ,p_eei_information24
      => p_rec.eei_information24
      ,p_eei_information25
      => p_rec.eei_information25
      ,p_eei_information26
      => p_rec.eei_information26
      ,p_eei_information27
      => p_rec.eei_information27
      ,p_eei_information28
      => p_rec.eei_information28
      ,p_eei_information29
      => p_rec.eei_information29
      ,p_eei_information30
      => p_rec.eei_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_element_type_id_o
      => pay_eei_shd.g_old_rec.element_type_id
      ,p_information_type_o
      => pay_eei_shd.g_old_rec.information_type
      ,p_request_id_o
      => pay_eei_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => pay_eei_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => pay_eei_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => pay_eei_shd.g_old_rec.program_update_date
      ,p_eei_attribute_category_o
      => pay_eei_shd.g_old_rec.eei_attribute_category
      ,p_eei_attribute1_o
      => pay_eei_shd.g_old_rec.eei_attribute1
      ,p_eei_attribute2_o
      => pay_eei_shd.g_old_rec.eei_attribute2
      ,p_eei_attribute3_o
      => pay_eei_shd.g_old_rec.eei_attribute3
      ,p_eei_attribute4_o
      => pay_eei_shd.g_old_rec.eei_attribute4
      ,p_eei_attribute5_o
      => pay_eei_shd.g_old_rec.eei_attribute5
      ,p_eei_attribute6_o
      => pay_eei_shd.g_old_rec.eei_attribute6
      ,p_eei_attribute7_o
      => pay_eei_shd.g_old_rec.eei_attribute7
      ,p_eei_attribute8_o
      => pay_eei_shd.g_old_rec.eei_attribute8
      ,p_eei_attribute9_o
      => pay_eei_shd.g_old_rec.eei_attribute9
      ,p_eei_attribute10_o
      => pay_eei_shd.g_old_rec.eei_attribute10
      ,p_eei_attribute11_o
      => pay_eei_shd.g_old_rec.eei_attribute11
      ,p_eei_attribute12_o
      => pay_eei_shd.g_old_rec.eei_attribute12
      ,p_eei_attribute13_o
      => pay_eei_shd.g_old_rec.eei_attribute13
      ,p_eei_attribute14_o
      => pay_eei_shd.g_old_rec.eei_attribute14
      ,p_eei_attribute15_o
      => pay_eei_shd.g_old_rec.eei_attribute15
      ,p_eei_attribute16_o
      => pay_eei_shd.g_old_rec.eei_attribute16
      ,p_eei_attribute17_o
      => pay_eei_shd.g_old_rec.eei_attribute17
      ,p_eei_attribute18_o
      => pay_eei_shd.g_old_rec.eei_attribute18
      ,p_eei_attribute19_o
      => pay_eei_shd.g_old_rec.eei_attribute19
      ,p_eei_attribute20_o
      => pay_eei_shd.g_old_rec.eei_attribute20
      ,p_eei_information_category_o
      => pay_eei_shd.g_old_rec.eei_information_category
      ,p_eei_information1_o
      => pay_eei_shd.g_old_rec.eei_information1
      ,p_eei_information2_o
      => pay_eei_shd.g_old_rec.eei_information2
      ,p_eei_information3_o
      => pay_eei_shd.g_old_rec.eei_information3
      ,p_eei_information4_o
      => pay_eei_shd.g_old_rec.eei_information4
      ,p_eei_information5_o
      => pay_eei_shd.g_old_rec.eei_information5
      ,p_eei_information6_o
      => pay_eei_shd.g_old_rec.eei_information6
      ,p_eei_information7_o
      => pay_eei_shd.g_old_rec.eei_information7
      ,p_eei_information8_o
      => pay_eei_shd.g_old_rec.eei_information8
      ,p_eei_information9_o
      => pay_eei_shd.g_old_rec.eei_information9
      ,p_eei_information10_o
      => pay_eei_shd.g_old_rec.eei_information10
      ,p_eei_information11_o
      => pay_eei_shd.g_old_rec.eei_information11
      ,p_eei_information12_o
      => pay_eei_shd.g_old_rec.eei_information12
      ,p_eei_information13_o
      => pay_eei_shd.g_old_rec.eei_information13
      ,p_eei_information14_o
      => pay_eei_shd.g_old_rec.eei_information14
      ,p_eei_information15_o
      => pay_eei_shd.g_old_rec.eei_information15
      ,p_eei_information16_o
      => pay_eei_shd.g_old_rec.eei_information16
      ,p_eei_information17_o
      => pay_eei_shd.g_old_rec.eei_information17
      ,p_eei_information18_o
      => pay_eei_shd.g_old_rec.eei_information18
      ,p_eei_information19_o
      => pay_eei_shd.g_old_rec.eei_information19
      ,p_eei_information20_o
      => pay_eei_shd.g_old_rec.eei_information20
      ,p_eei_information21_o
      => pay_eei_shd.g_old_rec.eei_information21
      ,p_eei_information22_o
      => pay_eei_shd.g_old_rec.eei_information22
      ,p_eei_information23_o
      => pay_eei_shd.g_old_rec.eei_information23
      ,p_eei_information24_o
      => pay_eei_shd.g_old_rec.eei_information24
      ,p_eei_information25_o
      => pay_eei_shd.g_old_rec.eei_information25
      ,p_eei_information26_o
      => pay_eei_shd.g_old_rec.eei_information26
      ,p_eei_information27_o
      => pay_eei_shd.g_old_rec.eei_information27
      ,p_eei_information28_o
      => pay_eei_shd.g_old_rec.eei_information28
      ,p_eei_information29_o
      => pay_eei_shd.g_old_rec.eei_information29
      ,p_eei_information30_o
      => pay_eei_shd.g_old_rec.eei_information30
      ,p_object_version_number_o
      => pay_eei_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_TYPE_EXTRA_INFO'
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
  (p_rec in out nocopy pay_eei_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    pay_eei_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.information_type = hr_api.g_varchar2) then
    p_rec.information_type :=
    pay_eei_shd.g_old_rec.information_type;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    pay_eei_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    pay_eei_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    pay_eei_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    pay_eei_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.eei_attribute_category = hr_api.g_varchar2) then
    p_rec.eei_attribute_category :=
    pay_eei_shd.g_old_rec.eei_attribute_category;
  End If;
  If (p_rec.eei_attribute1 = hr_api.g_varchar2) then
    p_rec.eei_attribute1 :=
    pay_eei_shd.g_old_rec.eei_attribute1;
  End If;
  If (p_rec.eei_attribute2 = hr_api.g_varchar2) then
    p_rec.eei_attribute2 :=
    pay_eei_shd.g_old_rec.eei_attribute2;
  End If;
  If (p_rec.eei_attribute3 = hr_api.g_varchar2) then
    p_rec.eei_attribute3 :=
    pay_eei_shd.g_old_rec.eei_attribute3;
  End If;
  If (p_rec.eei_attribute4 = hr_api.g_varchar2) then
    p_rec.eei_attribute4 :=
    pay_eei_shd.g_old_rec.eei_attribute4;
  End If;
  If (p_rec.eei_attribute5 = hr_api.g_varchar2) then
    p_rec.eei_attribute5 :=
    pay_eei_shd.g_old_rec.eei_attribute5;
  End If;
  If (p_rec.eei_attribute6 = hr_api.g_varchar2) then
    p_rec.eei_attribute6 :=
    pay_eei_shd.g_old_rec.eei_attribute6;
  End If;
  If (p_rec.eei_attribute7 = hr_api.g_varchar2) then
    p_rec.eei_attribute7 :=
    pay_eei_shd.g_old_rec.eei_attribute7;
  End If;
  If (p_rec.eei_attribute8 = hr_api.g_varchar2) then
    p_rec.eei_attribute8 :=
    pay_eei_shd.g_old_rec.eei_attribute8;
  End If;
  If (p_rec.eei_attribute9 = hr_api.g_varchar2) then
    p_rec.eei_attribute9 :=
    pay_eei_shd.g_old_rec.eei_attribute9;
  End If;
  If (p_rec.eei_attribute10 = hr_api.g_varchar2) then
    p_rec.eei_attribute10 :=
    pay_eei_shd.g_old_rec.eei_attribute10;
  End If;
  If (p_rec.eei_attribute11 = hr_api.g_varchar2) then
    p_rec.eei_attribute11 :=
    pay_eei_shd.g_old_rec.eei_attribute11;
  End If;
  If (p_rec.eei_attribute12 = hr_api.g_varchar2) then
    p_rec.eei_attribute12 :=
    pay_eei_shd.g_old_rec.eei_attribute12;
  End If;
  If (p_rec.eei_attribute13 = hr_api.g_varchar2) then
    p_rec.eei_attribute13 :=
    pay_eei_shd.g_old_rec.eei_attribute13;
  End If;
  If (p_rec.eei_attribute14 = hr_api.g_varchar2) then
    p_rec.eei_attribute14 :=
    pay_eei_shd.g_old_rec.eei_attribute14;
  End If;
  If (p_rec.eei_attribute15 = hr_api.g_varchar2) then
    p_rec.eei_attribute15 :=
    pay_eei_shd.g_old_rec.eei_attribute15;
  End If;
  If (p_rec.eei_attribute16 = hr_api.g_varchar2) then
    p_rec.eei_attribute16 :=
    pay_eei_shd.g_old_rec.eei_attribute16;
  End If;
  If (p_rec.eei_attribute17 = hr_api.g_varchar2) then
    p_rec.eei_attribute17 :=
    pay_eei_shd.g_old_rec.eei_attribute17;
  End If;
  If (p_rec.eei_attribute18 = hr_api.g_varchar2) then
    p_rec.eei_attribute18 :=
    pay_eei_shd.g_old_rec.eei_attribute18;
  End If;
  If (p_rec.eei_attribute19 = hr_api.g_varchar2) then
    p_rec.eei_attribute19 :=
    pay_eei_shd.g_old_rec.eei_attribute19;
  End If;
  If (p_rec.eei_attribute20 = hr_api.g_varchar2) then
    p_rec.eei_attribute20 :=
    pay_eei_shd.g_old_rec.eei_attribute20;
  End If;
  If (p_rec.eei_information_category = hr_api.g_varchar2) then
    p_rec.eei_information_category :=
    pay_eei_shd.g_old_rec.eei_information_category;
  End If;
  If (p_rec.eei_information1 = hr_api.g_varchar2) then
    p_rec.eei_information1 :=
    pay_eei_shd.g_old_rec.eei_information1;
  End If;
  If (p_rec.eei_information2 = hr_api.g_varchar2) then
    p_rec.eei_information2 :=
    pay_eei_shd.g_old_rec.eei_information2;
  End If;
  If (p_rec.eei_information3 = hr_api.g_varchar2) then
    p_rec.eei_information3 :=
    pay_eei_shd.g_old_rec.eei_information3;
  End If;
  If (p_rec.eei_information4 = hr_api.g_varchar2) then
    p_rec.eei_information4 :=
    pay_eei_shd.g_old_rec.eei_information4;
  End If;
  If (p_rec.eei_information5 = hr_api.g_varchar2) then
    p_rec.eei_information5 :=
    pay_eei_shd.g_old_rec.eei_information5;
  End If;
  If (p_rec.eei_information6 = hr_api.g_varchar2) then
    p_rec.eei_information6 :=
    pay_eei_shd.g_old_rec.eei_information6;
  End If;
  If (p_rec.eei_information7 = hr_api.g_varchar2) then
    p_rec.eei_information7 :=
    pay_eei_shd.g_old_rec.eei_information7;
  End If;
  If (p_rec.eei_information8 = hr_api.g_varchar2) then
    p_rec.eei_information8 :=
    pay_eei_shd.g_old_rec.eei_information8;
  End If;
  If (p_rec.eei_information9 = hr_api.g_varchar2) then
    p_rec.eei_information9 :=
    pay_eei_shd.g_old_rec.eei_information9;
  End If;
  If (p_rec.eei_information10 = hr_api.g_varchar2) then
    p_rec.eei_information10 :=
    pay_eei_shd.g_old_rec.eei_information10;
  End If;
  If (p_rec.eei_information11 = hr_api.g_varchar2) then
    p_rec.eei_information11 :=
    pay_eei_shd.g_old_rec.eei_information11;
  End If;
  If (p_rec.eei_information12 = hr_api.g_varchar2) then
    p_rec.eei_information12 :=
    pay_eei_shd.g_old_rec.eei_information12;
  End If;
  If (p_rec.eei_information13 = hr_api.g_varchar2) then
    p_rec.eei_information13 :=
    pay_eei_shd.g_old_rec.eei_information13;
  End If;
  If (p_rec.eei_information14 = hr_api.g_varchar2) then
    p_rec.eei_information14 :=
    pay_eei_shd.g_old_rec.eei_information14;
  End If;
  If (p_rec.eei_information15 = hr_api.g_varchar2) then
    p_rec.eei_information15 :=
    pay_eei_shd.g_old_rec.eei_information15;
  End If;
  If (p_rec.eei_information16 = hr_api.g_varchar2) then
    p_rec.eei_information16 :=
    pay_eei_shd.g_old_rec.eei_information16;
  End If;
  If (p_rec.eei_information17 = hr_api.g_varchar2) then
    p_rec.eei_information17 :=
    pay_eei_shd.g_old_rec.eei_information17;
  End If;
  If (p_rec.eei_information18 = hr_api.g_varchar2) then
    p_rec.eei_information18 :=
    pay_eei_shd.g_old_rec.eei_information18;
  End If;
  If (p_rec.eei_information19 = hr_api.g_varchar2) then
    p_rec.eei_information19 :=
    pay_eei_shd.g_old_rec.eei_information19;
  End If;
  If (p_rec.eei_information20 = hr_api.g_varchar2) then
    p_rec.eei_information20 :=
    pay_eei_shd.g_old_rec.eei_information20;
  End If;
  If (p_rec.eei_information21 = hr_api.g_varchar2) then
    p_rec.eei_information21 :=
    pay_eei_shd.g_old_rec.eei_information21;
  End If;
  If (p_rec.eei_information22 = hr_api.g_varchar2) then
    p_rec.eei_information22 :=
    pay_eei_shd.g_old_rec.eei_information22;
  End If;
  If (p_rec.eei_information23 = hr_api.g_varchar2) then
    p_rec.eei_information23 :=
    pay_eei_shd.g_old_rec.eei_information23;
  End If;
  If (p_rec.eei_information24 = hr_api.g_varchar2) then
    p_rec.eei_information24 :=
    pay_eei_shd.g_old_rec.eei_information24;
  End If;
  If (p_rec.eei_information25 = hr_api.g_varchar2) then
    p_rec.eei_information25 :=
    pay_eei_shd.g_old_rec.eei_information25;
  End If;
  If (p_rec.eei_information26 = hr_api.g_varchar2) then
    p_rec.eei_information26 :=
    pay_eei_shd.g_old_rec.eei_information26;
  End If;
  If (p_rec.eei_information27 = hr_api.g_varchar2) then
    p_rec.eei_information27 :=
    pay_eei_shd.g_old_rec.eei_information27;
  End If;
  If (p_rec.eei_information28 = hr_api.g_varchar2) then
    p_rec.eei_information28 :=
    pay_eei_shd.g_old_rec.eei_information28;
  End If;
  If (p_rec.eei_information29 = hr_api.g_varchar2) then
    p_rec.eei_information29 :=
    pay_eei_shd.g_old_rec.eei_information29;
  End If;
  If (p_rec.eei_information30 = hr_api.g_varchar2) then
    p_rec.eei_information30 :=
    pay_eei_shd.g_old_rec.eei_information30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pay_eei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_eei_shd.lck
    (p_rec.element_type_extra_info_id
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
  pay_eei_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  pay_eei_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_eei_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_eei_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_element_type_extra_info_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_information_type             in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_eei_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_eei_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_eei_information1             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information2             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information3             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information4             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information5             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information6             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information7             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information8             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information9             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information10            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information11            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information12            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information13            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information14            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information15            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information16            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information17            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information18            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information19            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information20            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information21            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information22            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information23            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information24            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information25            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information26            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information27            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information28            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information29            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information30            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  pay_eei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_eei_shd.convert_args
  (p_element_type_extra_info_id
  ,p_element_type_id
  ,p_information_type
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_program_update_date
  ,p_eei_attribute_category
  ,p_eei_attribute1
  ,p_eei_attribute2
  ,p_eei_attribute3
  ,p_eei_attribute4
  ,p_eei_attribute5
  ,p_eei_attribute6
  ,p_eei_attribute7
  ,p_eei_attribute8
  ,p_eei_attribute9
  ,p_eei_attribute10
  ,p_eei_attribute11
  ,p_eei_attribute12
  ,p_eei_attribute13
  ,p_eei_attribute14
  ,p_eei_attribute15
  ,p_eei_attribute16
  ,p_eei_attribute17
  ,p_eei_attribute18
  ,p_eei_attribute19
  ,p_eei_attribute20
  ,p_eei_information_category
  ,p_eei_information1
  ,p_eei_information2
  ,p_eei_information3
  ,p_eei_information4
  ,p_eei_information5
  ,p_eei_information6
  ,p_eei_information7
  ,p_eei_information8
  ,p_eei_information9
  ,p_eei_information10
  ,p_eei_information11
  ,p_eei_information12
  ,p_eei_information13
  ,p_eei_information14
  ,p_eei_information15
  ,p_eei_information16
  ,p_eei_information17
  ,p_eei_information18
  ,p_eei_information19
  ,p_eei_information20
  ,p_eei_information21
  ,p_eei_information22
  ,p_eei_information23
  ,p_eei_information24
  ,p_eei_information25
  ,p_eei_information26
  ,p_eei_information27
  ,p_eei_information28
  ,p_eei_information29
  ,p_eei_information30
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_eei_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_eei_upd;

/
