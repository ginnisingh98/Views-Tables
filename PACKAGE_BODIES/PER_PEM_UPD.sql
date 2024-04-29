--------------------------------------------------------
--  DDL for Package Body PER_PEM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEM_UPD" as
/* $Header: pepemrhi.pkb 120.1.12010000.3 2009/01/12 08:21:02 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pem_upd.';  -- Global package name
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
  (p_rec in out nocopy per_pem_shd.g_rec_type
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
  -- Update the per_previous_employers Row
  --
  update per_previous_employers
    set
     previous_employer_id            = p_rec.previous_employer_id
    ,business_group_id               = p_rec.business_group_id
    ,person_id                       = p_rec.person_id
    ,party_id                        = p_rec.party_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,period_years                    = p_rec.period_years
    ,period_days                     = p_rec.period_days
    ,employer_name                   = p_rec.employer_name
    ,employer_country                = p_rec.employer_country
    ,employer_address                = p_rec.employer_address
    ,employer_type                   = p_rec.employer_type
    ,employer_subtype                = p_rec.employer_subtype
    ,description                     = p_rec.description
    ,pem_attribute_category          = p_rec.pem_attribute_category
    ,pem_attribute1                  = p_rec.pem_attribute1
    ,pem_attribute2                  = p_rec.pem_attribute2
    ,pem_attribute3                  = p_rec.pem_attribute3
    ,pem_attribute4                  = p_rec.pem_attribute4
    ,pem_attribute5                  = p_rec.pem_attribute5
    ,pem_attribute6                  = p_rec.pem_attribute6
    ,pem_attribute7                  = p_rec.pem_attribute7
    ,pem_attribute8                  = p_rec.pem_attribute8
    ,pem_attribute9                  = p_rec.pem_attribute9
    ,pem_attribute10                 = p_rec.pem_attribute10
    ,pem_attribute11                 = p_rec.pem_attribute11
    ,pem_attribute12                 = p_rec.pem_attribute12
    ,pem_attribute13                 = p_rec.pem_attribute13
    ,pem_attribute14                 = p_rec.pem_attribute14
    ,pem_attribute15                 = p_rec.pem_attribute15
    ,pem_attribute16                 = p_rec.pem_attribute16
    ,pem_attribute17                 = p_rec.pem_attribute17
    ,pem_attribute18                 = p_rec.pem_attribute18
    ,pem_attribute19                 = p_rec.pem_attribute19
    ,pem_attribute20                 = p_rec.pem_attribute20
    ,pem_attribute21                 = p_rec.pem_attribute21
    ,pem_attribute22                 = p_rec.pem_attribute22
    ,pem_attribute23                 = p_rec.pem_attribute23
    ,pem_attribute24                 = p_rec.pem_attribute24
    ,pem_attribute25                 = p_rec.pem_attribute25
    ,pem_attribute26                 = p_rec.pem_attribute26
    ,pem_attribute27                 = p_rec.pem_attribute27
    ,pem_attribute28                 = p_rec.pem_attribute28
    ,pem_attribute29                 = p_rec.pem_attribute29
    ,pem_attribute30                 = p_rec.pem_attribute30
    ,pem_information_category        = p_rec.pem_information_category
    ,pem_information1                = p_rec.pem_information1
    ,pem_information2                = p_rec.pem_information2
    ,pem_information3                = p_rec.pem_information3
    ,pem_information4                = p_rec.pem_information4
    ,pem_information5                = p_rec.pem_information5
    ,pem_information6                = p_rec.pem_information6
    ,pem_information7                = p_rec.pem_information7
    ,pem_information8                = p_rec.pem_information8
    ,pem_information9                = p_rec.pem_information9
    ,pem_information10               = p_rec.pem_information10
    ,pem_information11               = p_rec.pem_information11
    ,pem_information12               = p_rec.pem_information12
    ,pem_information13               = p_rec.pem_information13
    ,pem_information14               = p_rec.pem_information14
    ,pem_information15               = p_rec.pem_information15
    ,pem_information16               = p_rec.pem_information16
    ,pem_information17               = p_rec.pem_information17
    ,pem_information18               = p_rec.pem_information18
    ,pem_information19               = p_rec.pem_information19
    ,pem_information20               = p_rec.pem_information20
    ,pem_information21               = p_rec.pem_information21
    ,pem_information22               = p_rec.pem_information22
    ,pem_information23               = p_rec.pem_information23
    ,pem_information24               = p_rec.pem_information24
    ,pem_information25               = p_rec.pem_information25
    ,pem_information26               = p_rec.pem_information26
    ,pem_information27               = p_rec.pem_information27
    ,pem_information28               = p_rec.pem_information28
    ,pem_information29               = p_rec.pem_information29
    ,pem_information30               = p_rec.pem_information30
    ,object_version_number           = p_rec.object_version_number
    ,all_assignments                 = p_rec.all_assignments
    ,period_months                   = p_rec.period_months
    where previous_employer_id = p_rec.previous_employer_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pem_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pem_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pem_shd.constraint_error
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
  (p_rec in per_pem_shd.g_rec_type
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
  ,p_rec                          in per_pem_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pem_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_previous_employer_id
      => p_rec.previous_employer_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_person_id
      => p_rec.person_id
      ,p_party_id
      => p_rec.party_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_period_years
      => p_rec.period_years
      ,p_period_days
      => p_rec.period_days
      ,p_employer_name
      => p_rec.employer_name
      ,p_employer_country
      => p_rec.employer_country
      ,p_employer_address
      => p_rec.employer_address
      ,p_employer_type
      => p_rec.employer_type
      ,p_employer_subtype
      => p_rec.employer_subtype
      ,p_description
      => p_rec.description
      ,p_pem_attribute_category
      => p_rec.pem_attribute_category
      ,p_pem_attribute1
      => p_rec.pem_attribute1
      ,p_pem_attribute2
      => p_rec.pem_attribute2
      ,p_pem_attribute3
      => p_rec.pem_attribute3
      ,p_pem_attribute4
      => p_rec.pem_attribute4
      ,p_pem_attribute5
      => p_rec.pem_attribute5
      ,p_pem_attribute6
      => p_rec.pem_attribute6
      ,p_pem_attribute7
      => p_rec.pem_attribute7
      ,p_pem_attribute8
      => p_rec.pem_attribute8
      ,p_pem_attribute9
      => p_rec.pem_attribute9
      ,p_pem_attribute10
      => p_rec.pem_attribute10
      ,p_pem_attribute11
      => p_rec.pem_attribute11
      ,p_pem_attribute12
      => p_rec.pem_attribute12
      ,p_pem_attribute13
      => p_rec.pem_attribute13
      ,p_pem_attribute14
      => p_rec.pem_attribute14
      ,p_pem_attribute15
      => p_rec.pem_attribute15
      ,p_pem_attribute16
      => p_rec.pem_attribute16
      ,p_pem_attribute17
      => p_rec.pem_attribute17
      ,p_pem_attribute18
      => p_rec.pem_attribute18
      ,p_pem_attribute19
      => p_rec.pem_attribute19
      ,p_pem_attribute20
      => p_rec.pem_attribute20
      ,p_pem_attribute21
      => p_rec.pem_attribute21
      ,p_pem_attribute22
      => p_rec.pem_attribute22
      ,p_pem_attribute23
      => p_rec.pem_attribute23
      ,p_pem_attribute24
      => p_rec.pem_attribute24
      ,p_pem_attribute25
      => p_rec.pem_attribute25
      ,p_pem_attribute26
      => p_rec.pem_attribute26
      ,p_pem_attribute27
      => p_rec.pem_attribute27
      ,p_pem_attribute28
      => p_rec.pem_attribute28
      ,p_pem_attribute29
      => p_rec.pem_attribute29
      ,p_pem_attribute30
      => p_rec.pem_attribute30
      ,p_pem_information_category
      => p_rec.pem_information_category
      ,p_pem_information1
      => p_rec.pem_information1
      ,p_pem_information2
      => p_rec.pem_information2
      ,p_pem_information3
      => p_rec.pem_information3
      ,p_pem_information4
      => p_rec.pem_information4
      ,p_pem_information5
      => p_rec.pem_information5
      ,p_pem_information6
      => p_rec.pem_information6
      ,p_pem_information7
      => p_rec.pem_information7
      ,p_pem_information8
      => p_rec.pem_information8
      ,p_pem_information9
      => p_rec.pem_information9
      ,p_pem_information10
      => p_rec.pem_information10
      ,p_pem_information11
      => p_rec.pem_information11
      ,p_pem_information12
      => p_rec.pem_information12
      ,p_pem_information13
      => p_rec.pem_information13
      ,p_pem_information14
      => p_rec.pem_information14
      ,p_pem_information15
      => p_rec.pem_information15
      ,p_pem_information16
      => p_rec.pem_information16
      ,p_pem_information17
      => p_rec.pem_information17
      ,p_pem_information18
      => p_rec.pem_information18
      ,p_pem_information19
      => p_rec.pem_information19
      ,p_pem_information20
      => p_rec.pem_information20
      ,p_pem_information21
      => p_rec.pem_information21
      ,p_pem_information22
      => p_rec.pem_information22
      ,p_pem_information23
      => p_rec.pem_information23
      ,p_pem_information24
      => p_rec.pem_information24
      ,p_pem_information25
      => p_rec.pem_information25
      ,p_pem_information26
      => p_rec.pem_information26
      ,p_pem_information27
      => p_rec.pem_information27
      ,p_pem_information28
      => p_rec.pem_information28
      ,p_pem_information29
      => p_rec.pem_information29
      ,p_pem_information30
      => p_rec.pem_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_all_assignments
      => p_rec.all_assignments
      ,p_period_months
      => p_rec.period_months
      ,p_business_group_id_o
      => per_pem_shd.g_old_rec.business_group_id
      ,p_person_id_o
      => per_pem_shd.g_old_rec.person_id
      ,p_party_id_o
      => per_pem_shd.g_old_rec.party_id
      ,p_start_date_o
      => per_pem_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_pem_shd.g_old_rec.end_date
      ,p_period_years_o
      => per_pem_shd.g_old_rec.period_years
      ,p_period_days_o
      => per_pem_shd.g_old_rec.period_days
      ,p_employer_name_o
      => per_pem_shd.g_old_rec.employer_name
      ,p_employer_country_o
      => per_pem_shd.g_old_rec.employer_country
      ,p_employer_address_o
      => per_pem_shd.g_old_rec.employer_address
      ,p_employer_type_o
      => per_pem_shd.g_old_rec.employer_type
      ,p_employer_subtype_o
      => per_pem_shd.g_old_rec.employer_subtype
      ,p_description_o
      => per_pem_shd.g_old_rec.description
      ,p_pem_attribute_category_o
      => per_pem_shd.g_old_rec.pem_attribute_category
      ,p_pem_attribute1_o
      => per_pem_shd.g_old_rec.pem_attribute1
      ,p_pem_attribute2_o
      => per_pem_shd.g_old_rec.pem_attribute2
      ,p_pem_attribute3_o
      => per_pem_shd.g_old_rec.pem_attribute3
      ,p_pem_attribute4_o
      => per_pem_shd.g_old_rec.pem_attribute4
      ,p_pem_attribute5_o
      => per_pem_shd.g_old_rec.pem_attribute5
      ,p_pem_attribute6_o
      => per_pem_shd.g_old_rec.pem_attribute6
      ,p_pem_attribute7_o
      => per_pem_shd.g_old_rec.pem_attribute7
      ,p_pem_attribute8_o
      => per_pem_shd.g_old_rec.pem_attribute8
      ,p_pem_attribute9_o
      => per_pem_shd.g_old_rec.pem_attribute9
      ,p_pem_attribute10_o
      => per_pem_shd.g_old_rec.pem_attribute10
      ,p_pem_attribute11_o
      => per_pem_shd.g_old_rec.pem_attribute11
      ,p_pem_attribute12_o
      => per_pem_shd.g_old_rec.pem_attribute12
      ,p_pem_attribute13_o
      => per_pem_shd.g_old_rec.pem_attribute13
      ,p_pem_attribute14_o
      => per_pem_shd.g_old_rec.pem_attribute14
      ,p_pem_attribute15_o
      => per_pem_shd.g_old_rec.pem_attribute15
      ,p_pem_attribute16_o
      => per_pem_shd.g_old_rec.pem_attribute16
      ,p_pem_attribute17_o
      => per_pem_shd.g_old_rec.pem_attribute17
      ,p_pem_attribute18_o
      => per_pem_shd.g_old_rec.pem_attribute18
      ,p_pem_attribute19_o
      => per_pem_shd.g_old_rec.pem_attribute19
      ,p_pem_attribute20_o
      => per_pem_shd.g_old_rec.pem_attribute20
      ,p_pem_attribute21_o
      => per_pem_shd.g_old_rec.pem_attribute21
      ,p_pem_attribute22_o
      => per_pem_shd.g_old_rec.pem_attribute22
      ,p_pem_attribute23_o
      => per_pem_shd.g_old_rec.pem_attribute23
      ,p_pem_attribute24_o
      => per_pem_shd.g_old_rec.pem_attribute24
      ,p_pem_attribute25_o
      => per_pem_shd.g_old_rec.pem_attribute25
      ,p_pem_attribute26_o
      => per_pem_shd.g_old_rec.pem_attribute26
      ,p_pem_attribute27_o
      => per_pem_shd.g_old_rec.pem_attribute27
      ,p_pem_attribute28_o
      => per_pem_shd.g_old_rec.pem_attribute28
      ,p_pem_attribute29_o
      => per_pem_shd.g_old_rec.pem_attribute29
      ,p_pem_attribute30_o
      => per_pem_shd.g_old_rec.pem_attribute30
      ,p_pem_information_category_o
      => per_pem_shd.g_old_rec.pem_information_category
      ,p_pem_information1_o
      => per_pem_shd.g_old_rec.pem_information1
      ,p_pem_information2_o
      => per_pem_shd.g_old_rec.pem_information2
      ,p_pem_information3_o
      => per_pem_shd.g_old_rec.pem_information3
      ,p_pem_information4_o
      => per_pem_shd.g_old_rec.pem_information4
      ,p_pem_information5_o
      => per_pem_shd.g_old_rec.pem_information5
      ,p_pem_information6_o
      => per_pem_shd.g_old_rec.pem_information6
      ,p_pem_information7_o
      => per_pem_shd.g_old_rec.pem_information7
      ,p_pem_information8_o
      => per_pem_shd.g_old_rec.pem_information8
      ,p_pem_information9_o
      => per_pem_shd.g_old_rec.pem_information9
      ,p_pem_information10_o
      => per_pem_shd.g_old_rec.pem_information10
      ,p_pem_information11_o
      => per_pem_shd.g_old_rec.pem_information11
      ,p_pem_information12_o
      => per_pem_shd.g_old_rec.pem_information12
      ,p_pem_information13_o
      => per_pem_shd.g_old_rec.pem_information13
      ,p_pem_information14_o
      => per_pem_shd.g_old_rec.pem_information14
      ,p_pem_information15_o
      => per_pem_shd.g_old_rec.pem_information15
      ,p_pem_information16_o
      => per_pem_shd.g_old_rec.pem_information16
      ,p_pem_information17_o
      => per_pem_shd.g_old_rec.pem_information17
      ,p_pem_information18_o
      => per_pem_shd.g_old_rec.pem_information18
      ,p_pem_information19_o
      => per_pem_shd.g_old_rec.pem_information19
      ,p_pem_information20_o
      => per_pem_shd.g_old_rec.pem_information20
      ,p_pem_information21_o
      => per_pem_shd.g_old_rec.pem_information21
      ,p_pem_information22_o
      => per_pem_shd.g_old_rec.pem_information22
      ,p_pem_information23_o
      => per_pem_shd.g_old_rec.pem_information23
      ,p_pem_information24_o
      => per_pem_shd.g_old_rec.pem_information24
      ,p_pem_information25_o
      => per_pem_shd.g_old_rec.pem_information25
      ,p_pem_information26_o
      => per_pem_shd.g_old_rec.pem_information26
      ,p_pem_information27_o
      => per_pem_shd.g_old_rec.pem_information27
      ,p_pem_information28_o
      => per_pem_shd.g_old_rec.pem_information28
      ,p_pem_information29_o
      => per_pem_shd.g_old_rec.pem_information29
      ,p_pem_information30_o
      => per_pem_shd.g_old_rec.pem_information30
      ,p_object_version_number_o
      => per_pem_shd.g_old_rec.object_version_number
      ,p_all_assignments_o
      => per_pem_shd.g_old_rec.all_assignments
      ,p_period_months_o
      => per_pem_shd.g_old_rec.period_months
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PREVIOUS_EMPLOYERS'
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
  (p_rec in out nocopy per_pem_shd.g_rec_type
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
    per_pem_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_pem_shd.g_old_rec.person_id;
  End If;
  If (p_rec.party_id = hr_api.g_number) then
    p_rec.party_id :=
    per_pem_shd.g_old_rec.party_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_pem_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_pem_shd.g_old_rec.end_date;
  End If;
  If (p_rec.period_years = hr_api.g_number) then
    p_rec.period_years :=
    per_pem_shd.g_old_rec.period_years;
  End If;
  If (p_rec.period_days = hr_api.g_number) then
    p_rec.period_days :=
    per_pem_shd.g_old_rec.period_days;
  End If;
  If (p_rec.employer_name = hr_api.g_varchar2) then
    p_rec.employer_name :=
    per_pem_shd.g_old_rec.employer_name;
  End If;
  If (p_rec.employer_country = hr_api.g_varchar2) then
    p_rec.employer_country :=
    per_pem_shd.g_old_rec.employer_country;
  End If;
  If (p_rec.employer_address = hr_api.g_varchar2) then
    p_rec.employer_address :=
    per_pem_shd.g_old_rec.employer_address;
  End If;
  If (p_rec.employer_type = hr_api.g_varchar2) then
    p_rec.employer_type :=
    per_pem_shd.g_old_rec.employer_type;
  End If;
  If (p_rec.employer_subtype = hr_api.g_varchar2) then
    p_rec.employer_subtype :=
    per_pem_shd.g_old_rec.employer_subtype;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    per_pem_shd.g_old_rec.description;
  End If;
  If (p_rec.pem_attribute_category = hr_api.g_varchar2) then
    p_rec.pem_attribute_category :=
    per_pem_shd.g_old_rec.pem_attribute_category;
  End If;
  If (p_rec.pem_attribute1 = hr_api.g_varchar2) then
    p_rec.pem_attribute1 :=
    per_pem_shd.g_old_rec.pem_attribute1;
  End If;
  If (p_rec.pem_attribute2 = hr_api.g_varchar2) then
    p_rec.pem_attribute2 :=
    per_pem_shd.g_old_rec.pem_attribute2;
  End If;
  If (p_rec.pem_attribute3 = hr_api.g_varchar2) then
    p_rec.pem_attribute3 :=
    per_pem_shd.g_old_rec.pem_attribute3;
  End If;
  If (p_rec.pem_attribute4 = hr_api.g_varchar2) then
    p_rec.pem_attribute4 :=
    per_pem_shd.g_old_rec.pem_attribute4;
  End If;
  If (p_rec.pem_attribute5 = hr_api.g_varchar2) then
    p_rec.pem_attribute5 :=
    per_pem_shd.g_old_rec.pem_attribute5;
  End If;
  If (p_rec.pem_attribute6 = hr_api.g_varchar2) then
    p_rec.pem_attribute6 :=
    per_pem_shd.g_old_rec.pem_attribute6;
  End If;
  If (p_rec.pem_attribute7 = hr_api.g_varchar2) then
    p_rec.pem_attribute7 :=
    per_pem_shd.g_old_rec.pem_attribute7;
  End If;
  If (p_rec.pem_attribute8 = hr_api.g_varchar2) then
    p_rec.pem_attribute8 :=
    per_pem_shd.g_old_rec.pem_attribute8;
  End If;
  If (p_rec.pem_attribute9 = hr_api.g_varchar2) then
    p_rec.pem_attribute9 :=
    per_pem_shd.g_old_rec.pem_attribute9;
  End If;
  If (p_rec.pem_attribute10 = hr_api.g_varchar2) then
    p_rec.pem_attribute10 :=
    per_pem_shd.g_old_rec.pem_attribute10;
  End If;
  If (p_rec.pem_attribute11 = hr_api.g_varchar2) then
    p_rec.pem_attribute11 :=
    per_pem_shd.g_old_rec.pem_attribute11;
  End If;
  If (p_rec.pem_attribute12 = hr_api.g_varchar2) then
    p_rec.pem_attribute12 :=
    per_pem_shd.g_old_rec.pem_attribute12;
  End If;
  If (p_rec.pem_attribute13 = hr_api.g_varchar2) then
    p_rec.pem_attribute13 :=
    per_pem_shd.g_old_rec.pem_attribute13;
  End If;
  If (p_rec.pem_attribute14 = hr_api.g_varchar2) then
    p_rec.pem_attribute14 :=
    per_pem_shd.g_old_rec.pem_attribute14;
  End If;
  If (p_rec.pem_attribute15 = hr_api.g_varchar2) then
    p_rec.pem_attribute15 :=
    per_pem_shd.g_old_rec.pem_attribute15;
  End If;
  If (p_rec.pem_attribute16 = hr_api.g_varchar2) then
    p_rec.pem_attribute16 :=
    per_pem_shd.g_old_rec.pem_attribute16;
  End If;
  If (p_rec.pem_attribute17 = hr_api.g_varchar2) then
    p_rec.pem_attribute17 :=
    per_pem_shd.g_old_rec.pem_attribute17;
  End If;
  If (p_rec.pem_attribute18 = hr_api.g_varchar2) then
    p_rec.pem_attribute18 :=
    per_pem_shd.g_old_rec.pem_attribute18;
  End If;
  If (p_rec.pem_attribute19 = hr_api.g_varchar2) then
    p_rec.pem_attribute19 :=
    per_pem_shd.g_old_rec.pem_attribute19;
  End If;
  If (p_rec.pem_attribute20 = hr_api.g_varchar2) then
    p_rec.pem_attribute20 :=
    per_pem_shd.g_old_rec.pem_attribute20;
  End If;
  If (p_rec.pem_attribute21 = hr_api.g_varchar2) then
    p_rec.pem_attribute21 :=
    per_pem_shd.g_old_rec.pem_attribute21;
  End If;
  If (p_rec.pem_attribute22 = hr_api.g_varchar2) then
    p_rec.pem_attribute22 :=
    per_pem_shd.g_old_rec.pem_attribute22;
  End If;
  If (p_rec.pem_attribute23 = hr_api.g_varchar2) then
    p_rec.pem_attribute23 :=
    per_pem_shd.g_old_rec.pem_attribute23;
  End If;
  If (p_rec.pem_attribute24 = hr_api.g_varchar2) then
    p_rec.pem_attribute24 :=
    per_pem_shd.g_old_rec.pem_attribute24;
  End If;
  If (p_rec.pem_attribute25 = hr_api.g_varchar2) then
    p_rec.pem_attribute25 :=
    per_pem_shd.g_old_rec.pem_attribute25;
  End If;
  If (p_rec.pem_attribute26 = hr_api.g_varchar2) then
    p_rec.pem_attribute26 :=
    per_pem_shd.g_old_rec.pem_attribute26;
  End If;
  If (p_rec.pem_attribute27 = hr_api.g_varchar2) then
    p_rec.pem_attribute27 :=
    per_pem_shd.g_old_rec.pem_attribute27;
  End If;
  If (p_rec.pem_attribute28 = hr_api.g_varchar2) then
    p_rec.pem_attribute28 :=
    per_pem_shd.g_old_rec.pem_attribute28;
  End If;
  If (p_rec.pem_attribute29 = hr_api.g_varchar2) then
    p_rec.pem_attribute29 :=
    per_pem_shd.g_old_rec.pem_attribute29;
  End If;
  If (p_rec.pem_attribute30 = hr_api.g_varchar2) then
    p_rec.pem_attribute30 :=
    per_pem_shd.g_old_rec.pem_attribute30;
  End If;
  If (p_rec.pem_information_category = hr_api.g_varchar2) then
    p_rec.pem_information_category :=
    per_pem_shd.g_old_rec.pem_information_category;
  End If;
  If (p_rec.pem_information1 = hr_api.g_varchar2) then
    p_rec.pem_information1 :=
    per_pem_shd.g_old_rec.pem_information1;
  End If;
  If (p_rec.pem_information2 = hr_api.g_varchar2) then
    p_rec.pem_information2 :=
    per_pem_shd.g_old_rec.pem_information2;
  End If;
  If (p_rec.pem_information3 = hr_api.g_varchar2) then
    p_rec.pem_information3 :=
    per_pem_shd.g_old_rec.pem_information3;
  End If;
  If (p_rec.pem_information4 = hr_api.g_varchar2) then
    p_rec.pem_information4 :=
    per_pem_shd.g_old_rec.pem_information4;
  End If;
  If (p_rec.pem_information5 = hr_api.g_varchar2) then
    p_rec.pem_information5 :=
    per_pem_shd.g_old_rec.pem_information5;
  End If;
  If (p_rec.pem_information6 = hr_api.g_varchar2) then
    p_rec.pem_information6 :=
    per_pem_shd.g_old_rec.pem_information6;
  End If;
  If (p_rec.pem_information7 = hr_api.g_varchar2) then
    p_rec.pem_information7 :=
    per_pem_shd.g_old_rec.pem_information7;
  End If;
  If (p_rec.pem_information8 = hr_api.g_varchar2) then
    p_rec.pem_information8 :=
    per_pem_shd.g_old_rec.pem_information8;
  End If;
  If (p_rec.pem_information9 = hr_api.g_varchar2) then
    p_rec.pem_information9 :=
    per_pem_shd.g_old_rec.pem_information9;
  End If;
  If (p_rec.pem_information10 = hr_api.g_varchar2) then
    p_rec.pem_information10 :=
    per_pem_shd.g_old_rec.pem_information10;
  End If;
  If (p_rec.pem_information11 = hr_api.g_varchar2) then
    p_rec.pem_information11 :=
    per_pem_shd.g_old_rec.pem_information11;
  End If;
  If (p_rec.pem_information12 = hr_api.g_varchar2) then
    p_rec.pem_information12 :=
    per_pem_shd.g_old_rec.pem_information12;
  End If;
  If (p_rec.pem_information13 = hr_api.g_varchar2) then
    p_rec.pem_information13 :=
    per_pem_shd.g_old_rec.pem_information13;
  End If;
  If (p_rec.pem_information14 = hr_api.g_varchar2) then
    p_rec.pem_information14 :=
    per_pem_shd.g_old_rec.pem_information14;
  End If;
  If (p_rec.pem_information15 = hr_api.g_varchar2) then
    p_rec.pem_information15 :=
    per_pem_shd.g_old_rec.pem_information15;
  End If;
  If (p_rec.pem_information16 = hr_api.g_varchar2) then
    p_rec.pem_information16 :=
    per_pem_shd.g_old_rec.pem_information16;
  End If;
  If (p_rec.pem_information17 = hr_api.g_varchar2) then
    p_rec.pem_information17 :=
    per_pem_shd.g_old_rec.pem_information17;
  End If;
  If (p_rec.pem_information18 = hr_api.g_varchar2) then
    p_rec.pem_information18 :=
    per_pem_shd.g_old_rec.pem_information18;
  End If;
  If (p_rec.pem_information19 = hr_api.g_varchar2) then
    p_rec.pem_information19 :=
    per_pem_shd.g_old_rec.pem_information19;
  End If;
  If (p_rec.pem_information20 = hr_api.g_varchar2) then
    p_rec.pem_information20 :=
    per_pem_shd.g_old_rec.pem_information20;
  End If;
  If (p_rec.pem_information21 = hr_api.g_varchar2) then
    p_rec.pem_information21 :=
    per_pem_shd.g_old_rec.pem_information21;
  End If;
  If (p_rec.pem_information22 = hr_api.g_varchar2) then
    p_rec.pem_information22 :=
    per_pem_shd.g_old_rec.pem_information22;
  End If;
  If (p_rec.pem_information23 = hr_api.g_varchar2) then
    p_rec.pem_information23 :=
    per_pem_shd.g_old_rec.pem_information23;
  End If;
  If (p_rec.pem_information24 = hr_api.g_varchar2) then
    p_rec.pem_information24 :=
    per_pem_shd.g_old_rec.pem_information24;
  End If;
  If (p_rec.pem_information25 = hr_api.g_varchar2) then
    p_rec.pem_information25 :=
    per_pem_shd.g_old_rec.pem_information25;
  End If;
  If (p_rec.pem_information26 = hr_api.g_varchar2) then
    p_rec.pem_information26 :=
    per_pem_shd.g_old_rec.pem_information26;
  End If;
  If (p_rec.pem_information27 = hr_api.g_varchar2) then
    p_rec.pem_information27 :=
    per_pem_shd.g_old_rec.pem_information27;
  End If;
  If (p_rec.pem_information28 = hr_api.g_varchar2) then
    p_rec.pem_information28 :=
    per_pem_shd.g_old_rec.pem_information28;
  End If;
  If (p_rec.pem_information29 = hr_api.g_varchar2) then
    p_rec.pem_information29 :=
    per_pem_shd.g_old_rec.pem_information29;
  End If;
  If (p_rec.pem_information30 = hr_api.g_varchar2) then
    p_rec.pem_information30 :=
    per_pem_shd.g_old_rec.pem_information30;
  End If;
  If (p_rec.all_assignments = hr_api.g_varchar2) then
    p_rec.all_assignments :=
    per_pem_shd.g_old_rec.all_assignments;
  End If;
  If (p_rec.period_months = hr_api.g_number) then
    p_rec.period_months :=
    per_pem_shd.g_old_rec.period_months;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_pem_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pem_shd.lck
    (p_rec.previous_employer_id
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
  per_pem_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_pem_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pem_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_pem_upd.post_update
     (p_effective_date
     ,p_rec
     );
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_previous_employer_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_employer_name                in     varchar2  default hr_api.g_varchar2
  ,p_employer_country             in     varchar2  default hr_api.g_varchar2
  ,p_employer_address             in     varchar2  default hr_api.g_varchar2
  ,p_employer_type                in     varchar2  default hr_api.g_varchar2
  ,p_employer_subtype             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pem_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pem_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information30            in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default hr_api.g_varchar2
  ,p_period_months                in     number    default hr_api.g_number
  ) is
--
  l_rec   per_pem_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pem_shd.convert_args
  (p_previous_employer_id
  ,p_business_group_id
  ,p_person_id
  ,p_party_id
  ,p_start_date
  ,p_end_date
  ,p_period_years
  ,p_period_days
  ,p_employer_name
  ,p_employer_country
  ,p_employer_address
  ,p_employer_type
  ,p_employer_subtype
  ,p_description
  ,p_pem_attribute_category
  ,p_pem_attribute1
  ,p_pem_attribute2
  ,p_pem_attribute3
  ,p_pem_attribute4
  ,p_pem_attribute5
  ,p_pem_attribute6
  ,p_pem_attribute7
  ,p_pem_attribute8
  ,p_pem_attribute9
  ,p_pem_attribute10
  ,p_pem_attribute11
  ,p_pem_attribute12
  ,p_pem_attribute13
  ,p_pem_attribute14
  ,p_pem_attribute15
  ,p_pem_attribute16
  ,p_pem_attribute17
  ,p_pem_attribute18
  ,p_pem_attribute19
  ,p_pem_attribute20
  ,p_pem_attribute21
  ,p_pem_attribute22
  ,p_pem_attribute23
  ,p_pem_attribute24
  ,p_pem_attribute25
  ,p_pem_attribute26
  ,p_pem_attribute27
  ,p_pem_attribute28
  ,p_pem_attribute29
  ,p_pem_attribute30
  ,p_pem_information_category
  ,p_pem_information1
  ,p_pem_information2
  ,p_pem_information3
  ,p_pem_information4
  ,p_pem_information5
  ,p_pem_information6
  ,p_pem_information7
  ,p_pem_information8
  ,p_pem_information9
  ,p_pem_information10
  ,p_pem_information11
  ,p_pem_information12
  ,p_pem_information13
  ,p_pem_information14
  ,p_pem_information15
  ,p_pem_information16
  ,p_pem_information17
  ,p_pem_information18
  ,p_pem_information19
  ,p_pem_information20
  ,p_pem_information21
  ,p_pem_information22
  ,p_pem_information23
  ,p_pem_information24
  ,p_pem_information25
  ,p_pem_information26
  ,p_pem_information27
  ,p_pem_information28
  ,p_pem_information29
  ,p_pem_information30
  ,p_object_version_number
  ,p_all_assignments
  ,p_period_months
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pem_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pem_upd;

/