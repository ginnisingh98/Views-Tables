--------------------------------------------------------
--  DDL for Package Body PAY_PRF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRF_UPD" as
/* $Header: pyprfrhi.pkb 120.0 2005/05/29 07:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prf_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_prf_shd.g_rec_type
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
  -- Update the pay_range_tables_f Row
  --
  update pay_range_tables_f
    set
     range_table_id                  = p_rec.range_table_id
    ,effective_start_date            = p_rec.effective_start_date
    ,effective_end_date              = p_rec.effective_end_date
    ,range_table_number              = p_rec.range_table_number
    ,row_value_uom                   = p_rec.row_value_uom
    ,period_frequency                = p_rec.period_frequency
    ,earnings_type                   = p_rec.earnings_type
    ,business_group_id               = p_rec.business_group_id
    ,legislation_code                = p_rec.legislation_code
    ,last_updated_login              = p_rec.last_updated_login
    ,created_date                    = p_rec.created_date
    ,object_version_number           = p_rec.object_version_number
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
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    ,ran_information_category        = p_rec.ran_information_category
    ,ran_information1                = p_rec.ran_information1
    ,ran_information2                = p_rec.ran_information2
    ,ran_information3                = p_rec.ran_information3
    ,ran_information4                = p_rec.ran_information4
    ,ran_information5                = p_rec.ran_information5
    ,ran_information6                = p_rec.ran_information6
    ,ran_information7                = p_rec.ran_information7
    ,ran_information8                = p_rec.ran_information8
    ,ran_information9                = p_rec.ran_information9
    ,ran_information10               = p_rec.ran_information10
    ,ran_information11               = p_rec.ran_information11
    ,ran_information12               = p_rec.ran_information12
    ,ran_information13               = p_rec.ran_information13
    ,ran_information14               = p_rec.ran_information14
    ,ran_information15               = p_rec.ran_information15
    ,ran_information16               = p_rec.ran_information16
    ,ran_information17               = p_rec.ran_information17
    ,ran_information18               = p_rec.ran_information18
    ,ran_information19               = p_rec.ran_information19
    ,ran_information20               = p_rec.ran_information20
    ,ran_information21               = p_rec.ran_information21
    ,ran_information22               = p_rec.ran_information22
    ,ran_information23               = p_rec.ran_information23
    ,ran_information24               = p_rec.ran_information24
    ,ran_information25               = p_rec.ran_information25
    ,ran_information26               = p_rec.ran_information26
    ,ran_information27               = p_rec.ran_information27
    ,ran_information28               = p_rec.ran_information28
    ,ran_information29               = p_rec.ran_information29
    ,ran_information30               = p_rec.ran_information30
    where range_table_id = p_rec.range_table_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_prf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_prf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_prf_shd.constraint_error
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
  (p_rec in pay_prf_shd.g_rec_type
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
  (p_rec                          in pay_prf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_prf_rku.after_update
      (p_range_table_id
      => p_rec.range_table_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_range_table_number
      => p_rec.range_table_number
      ,p_row_value_uom
      => p_rec.row_value_uom
      ,p_period_frequency
      => p_rec.period_frequency
      ,p_earnings_type
      => p_rec.earnings_type
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_last_updated_login
      => p_rec.last_updated_login
      ,p_created_date
      => p_rec.created_date
      ,p_object_version_number
      => p_rec.object_version_number
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
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_ran_information_category
      => p_rec.ran_information_category
      ,p_ran_information1
      => p_rec.ran_information1
      ,p_ran_information2
      => p_rec.ran_information2
      ,p_ran_information3
      => p_rec.ran_information3
      ,p_ran_information4
      => p_rec.ran_information4
      ,p_ran_information5
      => p_rec.ran_information5
      ,p_ran_information6
      => p_rec.ran_information6
      ,p_ran_information7
      => p_rec.ran_information7
      ,p_ran_information8
      => p_rec.ran_information8
      ,p_ran_information9
      => p_rec.ran_information9
      ,p_ran_information10
      => p_rec.ran_information10
      ,p_ran_information11
      => p_rec.ran_information11
      ,p_ran_information12
      => p_rec.ran_information12
      ,p_ran_information13
      => p_rec.ran_information13
      ,p_ran_information14
      => p_rec.ran_information14
      ,p_ran_information15
      => p_rec.ran_information15
      ,p_ran_information16
      => p_rec.ran_information16
      ,p_ran_information17
      => p_rec.ran_information17
      ,p_ran_information18
      => p_rec.ran_information18
      ,p_ran_information19
      => p_rec.ran_information19
      ,p_ran_information20
      => p_rec.ran_information20
      ,p_ran_information21
      => p_rec.ran_information21
      ,p_ran_information22
      => p_rec.ran_information22
      ,p_ran_information23
      => p_rec.ran_information23
      ,p_ran_information24
      => p_rec.ran_information24
      ,p_ran_information25
      => p_rec.ran_information25
      ,p_ran_information26
      => p_rec.ran_information26
      ,p_ran_information27
      => p_rec.ran_information27
      ,p_ran_information28
      => p_rec.ran_information28
      ,p_ran_information29
      => p_rec.ran_information29
      ,p_ran_information30
      => p_rec.ran_information30
      ,p_effective_start_date_o
      => pay_prf_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_prf_shd.g_old_rec.effective_end_date
      ,p_range_table_number_o
      => pay_prf_shd.g_old_rec.range_table_number
      ,p_row_value_uom_o
      => pay_prf_shd.g_old_rec.row_value_uom
      ,p_period_frequency_o
      => pay_prf_shd.g_old_rec.period_frequency
      ,p_earnings_type_o
      => pay_prf_shd.g_old_rec.earnings_type
      ,p_business_group_id_o
      => pay_prf_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_prf_shd.g_old_rec.legislation_code
      ,p_last_updated_login_o
      => pay_prf_shd.g_old_rec.last_updated_login
      ,p_created_date_o
      => pay_prf_shd.g_old_rec.created_date
      ,p_object_version_number_o
      => pay_prf_shd.g_old_rec.object_version_number
      ,p_attribute_category_o
      => pay_prf_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_prf_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_prf_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_prf_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_prf_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_prf_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_prf_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_prf_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_prf_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_prf_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_prf_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_prf_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_prf_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_prf_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_prf_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_prf_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_prf_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_prf_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_prf_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_prf_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_prf_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => pay_prf_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => pay_prf_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => pay_prf_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => pay_prf_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => pay_prf_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => pay_prf_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => pay_prf_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => pay_prf_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => pay_prf_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => pay_prf_shd.g_old_rec.attribute30
      ,p_ran_information_category_o
      => pay_prf_shd.g_old_rec.ran_information_category
      ,p_ran_information1_o
      => pay_prf_shd.g_old_rec.ran_information1
      ,p_ran_information2_o
      => pay_prf_shd.g_old_rec.ran_information2
      ,p_ran_information3_o
      => pay_prf_shd.g_old_rec.ran_information3
      ,p_ran_information4_o
      => pay_prf_shd.g_old_rec.ran_information4
      ,p_ran_information5_o
      => pay_prf_shd.g_old_rec.ran_information5
      ,p_ran_information6_o
      => pay_prf_shd.g_old_rec.ran_information6
      ,p_ran_information7_o
      => pay_prf_shd.g_old_rec.ran_information7
      ,p_ran_information8_o
      => pay_prf_shd.g_old_rec.ran_information8
      ,p_ran_information9_o
      => pay_prf_shd.g_old_rec.ran_information9
      ,p_ran_information10_o
      => pay_prf_shd.g_old_rec.ran_information10
      ,p_ran_information11_o
      => pay_prf_shd.g_old_rec.ran_information11
      ,p_ran_information12_o
      => pay_prf_shd.g_old_rec.ran_information12
      ,p_ran_information13_o
      => pay_prf_shd.g_old_rec.ran_information13
      ,p_ran_information14_o
      => pay_prf_shd.g_old_rec.ran_information14
      ,p_ran_information15_o
      => pay_prf_shd.g_old_rec.ran_information15
      ,p_ran_information16_o
      => pay_prf_shd.g_old_rec.ran_information16
      ,p_ran_information17_o
      => pay_prf_shd.g_old_rec.ran_information17
      ,p_ran_information18_o
      => pay_prf_shd.g_old_rec.ran_information18
      ,p_ran_information19_o
      => pay_prf_shd.g_old_rec.ran_information19
      ,p_ran_information20_o
      => pay_prf_shd.g_old_rec.ran_information20
      ,p_ran_information21_o
      => pay_prf_shd.g_old_rec.ran_information21
      ,p_ran_information22_o
      => pay_prf_shd.g_old_rec.ran_information22
      ,p_ran_information23_o
      => pay_prf_shd.g_old_rec.ran_information23
      ,p_ran_information24_o
      => pay_prf_shd.g_old_rec.ran_information24
      ,p_ran_information25_o
      => pay_prf_shd.g_old_rec.ran_information25
      ,p_ran_information26_o
      => pay_prf_shd.g_old_rec.ran_information26
      ,p_ran_information27_o
      => pay_prf_shd.g_old_rec.ran_information27
      ,p_ran_information28_o
      => pay_prf_shd.g_old_rec.ran_information28
      ,p_ran_information29_o
      => pay_prf_shd.g_old_rec.ran_information29
      ,p_ran_information30_o
      => pay_prf_shd.g_old_rec.ran_information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RANGE_TABLES_F'
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
  (p_rec in out nocopy pay_prf_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.effective_start_date = hr_api.g_date) then
    p_rec.effective_start_date :=
    pay_prf_shd.g_old_rec.effective_start_date;
  End If;
  If (p_rec.effective_end_date = hr_api.g_date) then
    p_rec.effective_end_date :=
    pay_prf_shd.g_old_rec.effective_end_date;
  End If;
  If (p_rec.range_table_number = hr_api.g_number) then
    p_rec.range_table_number :=
    pay_prf_shd.g_old_rec.range_table_number;
  End If;
  If (p_rec.row_value_uom = hr_api.g_varchar2) then
    p_rec.row_value_uom :=
    pay_prf_shd.g_old_rec.row_value_uom;
  End If;
  If (p_rec.period_frequency = hr_api.g_varchar2) then
    p_rec.period_frequency :=
    pay_prf_shd.g_old_rec.period_frequency;
  End If;
  If (p_rec.earnings_type = hr_api.g_varchar2) then
    p_rec.earnings_type :=
    pay_prf_shd.g_old_rec.earnings_type;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_prf_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_prf_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.last_updated_login = hr_api.g_number) then
    p_rec.last_updated_login :=
    pay_prf_shd.g_old_rec.last_updated_login;
  End If;
  If (p_rec.created_date = hr_api.g_date) then
    p_rec.created_date :=
    pay_prf_shd.g_old_rec.created_date;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pay_prf_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pay_prf_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pay_prf_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pay_prf_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pay_prf_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pay_prf_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pay_prf_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pay_prf_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pay_prf_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pay_prf_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pay_prf_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pay_prf_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pay_prf_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pay_prf_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pay_prf_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pay_prf_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pay_prf_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pay_prf_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pay_prf_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pay_prf_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pay_prf_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    pay_prf_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    pay_prf_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    pay_prf_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    pay_prf_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    pay_prf_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    pay_prf_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    pay_prf_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    pay_prf_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    pay_prf_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    pay_prf_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.ran_information_category = hr_api.g_varchar2) then
    p_rec.ran_information_category :=
    pay_prf_shd.g_old_rec.ran_information_category;
  End If;
  If (p_rec.ran_information1 = hr_api.g_varchar2) then
    p_rec.ran_information1 :=
    pay_prf_shd.g_old_rec.ran_information1;
  End If;
  If (p_rec.ran_information2 = hr_api.g_varchar2) then
    p_rec.ran_information2 :=
    pay_prf_shd.g_old_rec.ran_information2;
  End If;
  If (p_rec.ran_information3 = hr_api.g_varchar2) then
    p_rec.ran_information3 :=
    pay_prf_shd.g_old_rec.ran_information3;
  End If;
  If (p_rec.ran_information4 = hr_api.g_varchar2) then
    p_rec.ran_information4 :=
    pay_prf_shd.g_old_rec.ran_information4;
  End If;
  If (p_rec.ran_information5 = hr_api.g_varchar2) then
    p_rec.ran_information5 :=
    pay_prf_shd.g_old_rec.ran_information5;
  End If;
  If (p_rec.ran_information6 = hr_api.g_varchar2) then
    p_rec.ran_information6 :=
    pay_prf_shd.g_old_rec.ran_information6;
  End If;
  If (p_rec.ran_information7 = hr_api.g_varchar2) then
    p_rec.ran_information7 :=
    pay_prf_shd.g_old_rec.ran_information7;
  End If;
  If (p_rec.ran_information8 = hr_api.g_varchar2) then
    p_rec.ran_information8 :=
    pay_prf_shd.g_old_rec.ran_information8;
  End If;
  If (p_rec.ran_information9 = hr_api.g_varchar2) then
    p_rec.ran_information9 :=
    pay_prf_shd.g_old_rec.ran_information9;
  End If;
  If (p_rec.ran_information10 = hr_api.g_varchar2) then
    p_rec.ran_information10 :=
    pay_prf_shd.g_old_rec.ran_information10;
  End If;
  If (p_rec.ran_information11 = hr_api.g_varchar2) then
    p_rec.ran_information11 :=
    pay_prf_shd.g_old_rec.ran_information11;
  End If;
  If (p_rec.ran_information12 = hr_api.g_varchar2) then
    p_rec.ran_information12 :=
    pay_prf_shd.g_old_rec.ran_information12;
  End If;
  If (p_rec.ran_information13 = hr_api.g_varchar2) then
    p_rec.ran_information13 :=
    pay_prf_shd.g_old_rec.ran_information13;
  End If;
  If (p_rec.ran_information14 = hr_api.g_varchar2) then
    p_rec.ran_information14 :=
    pay_prf_shd.g_old_rec.ran_information14;
  End If;
  If (p_rec.ran_information15 = hr_api.g_varchar2) then
    p_rec.ran_information15 :=
    pay_prf_shd.g_old_rec.ran_information15;
  End If;
  If (p_rec.ran_information16 = hr_api.g_varchar2) then
    p_rec.ran_information16 :=
    pay_prf_shd.g_old_rec.ran_information16;
  End If;
  If (p_rec.ran_information17 = hr_api.g_varchar2) then
    p_rec.ran_information17 :=
    pay_prf_shd.g_old_rec.ran_information17;
  End If;
  If (p_rec.ran_information18 = hr_api.g_varchar2) then
    p_rec.ran_information18 :=
    pay_prf_shd.g_old_rec.ran_information18;
  End If;
  If (p_rec.ran_information19 = hr_api.g_varchar2) then
    p_rec.ran_information19 :=
    pay_prf_shd.g_old_rec.ran_information19;
  End If;
  If (p_rec.ran_information20 = hr_api.g_varchar2) then
    p_rec.ran_information20 :=
    pay_prf_shd.g_old_rec.ran_information20;
  End If;
  If (p_rec.ran_information21 = hr_api.g_varchar2) then
    p_rec.ran_information21 :=
    pay_prf_shd.g_old_rec.ran_information21;
  End If;
  If (p_rec.ran_information22 = hr_api.g_varchar2) then
    p_rec.ran_information22 :=
    pay_prf_shd.g_old_rec.ran_information22;
  End If;
  If (p_rec.ran_information23 = hr_api.g_varchar2) then
    p_rec.ran_information23 :=
    pay_prf_shd.g_old_rec.ran_information23;
  End If;
  If (p_rec.ran_information24 = hr_api.g_varchar2) then
    p_rec.ran_information24 :=
    pay_prf_shd.g_old_rec.ran_information24;
  End If;
  If (p_rec.ran_information25 = hr_api.g_varchar2) then
    p_rec.ran_information25 :=
    pay_prf_shd.g_old_rec.ran_information25;
  End If;
  If (p_rec.ran_information26 = hr_api.g_varchar2) then
    p_rec.ran_information26 :=
    pay_prf_shd.g_old_rec.ran_information26;
  End If;
  If (p_rec.ran_information27 = hr_api.g_varchar2) then
    p_rec.ran_information27 :=
    pay_prf_shd.g_old_rec.ran_information27;
  End If;
  If (p_rec.ran_information28 = hr_api.g_varchar2) then
    p_rec.ran_information28 :=
    pay_prf_shd.g_old_rec.ran_information28;
  End If;
  If (p_rec.ran_information29 = hr_api.g_varchar2) then
    p_rec.ran_information29 :=
    pay_prf_shd.g_old_rec.ran_information29;
  End If;
  If (p_rec.ran_information30 = hr_api.g_varchar2) then
    p_rec.ran_information30 :=
    pay_prf_shd.g_old_rec.ran_information30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pay_prf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_prf_shd.lck
    (p_rec.range_table_id
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
  pay_prf_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_prf_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_prf_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --

  -- Commented Because User Hook not Supported as of now.
  /*
   pay_prf_upd.post_update
     (p_rec
     );
  */
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_range_table_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_range_table_number           in     number    default hr_api.g_number
  ,p_period_frequency             in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_effective_end_date           in     date      default hr_api.g_date
  ,p_row_value_uom                in     varchar2  default hr_api.g_varchar2
  ,p_earnings_type                in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_last_updated_login           in     number    default hr_api.g_number
  ,p_created_date                 in     date      default hr_api.g_date
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
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_ran_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_ran_information1             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information2             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information3             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information4             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information5             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information6             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information7             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information8             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information9             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information10            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information11            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information12            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information13            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information14            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information15            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information16            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information17            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information18            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information19            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information20            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information21            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information22            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information23            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information24            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information25            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information26            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information27            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information28            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information29            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information30            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pay_prf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_prf_shd.convert_args
  (p_range_table_id
  ,p_effective_start_date
  ,p_effective_end_date
  ,p_range_table_number
  ,p_row_value_uom
  ,p_period_frequency
  ,p_earnings_type
  ,p_business_group_id
  ,p_legislation_code
  ,p_last_updated_login
  ,p_created_date
  ,p_object_version_number
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
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  ,p_ran_information_category
  ,p_ran_information1
  ,p_ran_information2
  ,p_ran_information3
  ,p_ran_information4
  ,p_ran_information5
  ,p_ran_information6
  ,p_ran_information7
  ,p_ran_information8
  ,p_ran_information9
  ,p_ran_information10
  ,p_ran_information11
  ,p_ran_information12
  ,p_ran_information13
  ,p_ran_information14
  ,p_ran_information15
  ,p_ran_information16
  ,p_ran_information17
  ,p_ran_information18
  ,p_ran_information19
  ,p_ran_information20
  ,p_ran_information21
  ,p_ran_information22
  ,p_ran_information23
  ,p_ran_information24
  ,p_ran_information25
  ,p_ran_information26
  ,p_ran_information27
  ,p_ran_information28
  ,p_ran_information29
  ,p_ran_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_prf_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_prf_upd;

/
