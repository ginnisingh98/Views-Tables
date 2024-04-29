--------------------------------------------------------
--  DDL for Package Body HR_DEI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DEI_UPD" as
/* $Header: hrdeirhi.pkb 120.1.12010000.3 2010/05/20 12:01:59 tkghosh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_dei_upd.';  -- Global package name
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
Procedure update_dml
  (p_rec in out nocopy hr_dei_shd.g_rec_type
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
  -- Update the hr_document_extra_info Row
  --
  update hr_document_extra_info
    set
     document_extra_info_id          = p_rec.document_extra_info_id
    ,document_type_id                = p_rec.document_type_id
    ,document_number                 = p_rec.document_number
    ,date_from                       = p_rec.date_from
    ,date_to                         = p_rec.date_to
    ,issued_by                       = p_rec.issued_by
    ,issued_at                       = p_rec.issued_at
    ,issued_date                     = p_rec.issued_date
    ,issuing_authority               = p_rec.issuing_authority
    ,verified_by                     = p_rec.verified_by
    ,verified_date                   = p_rec.verified_date
    ,related_object_name             = p_rec.related_object_name
    ,related_object_id_col           = p_rec.related_object_id_col
    ,related_object_id               = p_rec.related_object_id
    ,dei_attribute_category          = p_rec.dei_attribute_category
    ,dei_attribute1                  = p_rec.dei_attribute1
    ,dei_attribute2                  = p_rec.dei_attribute2
    ,dei_attribute3                  = p_rec.dei_attribute3
    ,dei_attribute4                  = p_rec.dei_attribute4
    ,dei_attribute5                  = p_rec.dei_attribute5
    ,dei_attribute6                  = p_rec.dei_attribute6
    ,dei_attribute7                  = p_rec.dei_attribute7
    ,dei_attribute8                  = p_rec.dei_attribute8
    ,dei_attribute9                  = p_rec.dei_attribute9
    ,dei_attribute10                 = p_rec.dei_attribute10
    ,dei_attribute11                 = p_rec.dei_attribute11
    ,dei_attribute12                 = p_rec.dei_attribute12
    ,dei_attribute13                 = p_rec.dei_attribute13
    ,dei_attribute14                 = p_rec.dei_attribute14
    ,dei_attribute15                 = p_rec.dei_attribute15
    ,dei_attribute16                 = p_rec.dei_attribute16
    ,dei_attribute17                 = p_rec.dei_attribute17
    ,dei_attribute18                 = p_rec.dei_attribute18
    ,dei_attribute19                 = p_rec.dei_attribute19
    ,dei_attribute20                 = p_rec.dei_attribute20
    ,dei_attribute21                 = p_rec.dei_attribute21
    ,dei_attribute22                 = p_rec.dei_attribute22
    ,dei_attribute23                 = p_rec.dei_attribute23
    ,dei_attribute24                 = p_rec.dei_attribute24
    ,dei_attribute25                 = p_rec.dei_attribute25
    ,dei_attribute26                 = p_rec.dei_attribute26
    ,dei_attribute27                 = p_rec.dei_attribute27
    ,dei_attribute28                 = p_rec.dei_attribute28
    ,dei_attribute29                 = p_rec.dei_attribute29
    ,dei_attribute30                 = p_rec.dei_attribute30
    ,dei_information_category        = p_rec.dei_information_category
    ,dei_information1                = p_rec.dei_information1
    ,dei_information2                = p_rec.dei_information2
    ,dei_information3                = p_rec.dei_information3
    ,dei_information4                = p_rec.dei_information4
    ,dei_information5                = p_rec.dei_information5
    ,dei_information6                = p_rec.dei_information6
    ,dei_information7                = p_rec.dei_information7
    ,dei_information8                = p_rec.dei_information8
    ,dei_information9                = p_rec.dei_information9
    ,dei_information10               = p_rec.dei_information10
    ,dei_information11               = p_rec.dei_information11
    ,dei_information12               = p_rec.dei_information12
    ,dei_information13               = p_rec.dei_information13
    ,dei_information14               = p_rec.dei_information14
    ,dei_information15               = p_rec.dei_information15
    ,dei_information16               = p_rec.dei_information16
    ,dei_information17               = p_rec.dei_information17
    ,dei_information18               = p_rec.dei_information18
    ,dei_information19               = p_rec.dei_information19
    ,dei_information20               = p_rec.dei_information20
    ,dei_information21               = p_rec.dei_information21
    ,dei_information22               = p_rec.dei_information22
    ,dei_information23               = p_rec.dei_information23
    ,dei_information24               = p_rec.dei_information24
    ,dei_information25               = p_rec.dei_information25
    ,dei_information26               = p_rec.dei_information26
    ,dei_information27               = p_rec.dei_information27
    ,dei_information28               = p_rec.dei_information28
    ,dei_information29               = p_rec.dei_information29
    ,dei_information30               = p_rec.dei_information30
    ,request_id                      = p_rec.request_id
    ,program_application_id          = p_rec.program_application_id
    ,program_id                      = p_rec.program_id
    ,program_update_date             = p_rec.program_update_date
    ,object_version_number           = p_rec.object_version_number
    where document_extra_info_id = p_rec.document_extra_info_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_dei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_dei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_dei_shd.constraint_error
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
  (p_rec in hr_dei_shd.g_rec_type
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
  (p_rec                          in hr_dei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_dei_rku.after_update
      (p_document_extra_info_id
      => p_rec.document_extra_info_id
      ,p_document_type_id
      => p_rec.document_type_id
      ,p_document_number
      => p_rec.document_number
      ,p_date_from
      => p_rec.date_from
      ,p_date_to
      => p_rec.date_to
      ,p_issued_by
      => p_rec.issued_by
      ,p_issued_at
      => p_rec.issued_at
      ,p_issued_date
      => p_rec.issued_date
      ,p_issuing_authority
      => p_rec.issuing_authority
      ,p_verified_by
      => p_rec.verified_by
      ,p_verified_date
      => p_rec.verified_date
      ,p_related_object_name
      => p_rec.related_object_name
      ,p_related_object_id_col
      => p_rec.related_object_id_col
      ,p_related_object_id
      => p_rec.related_object_id
      ,p_dei_attribute_category
      => p_rec.dei_attribute_category
      ,p_dei_attribute1
      => p_rec.dei_attribute1
      ,p_dei_attribute2
      => p_rec.dei_attribute2
      ,p_dei_attribute3
      => p_rec.dei_attribute3
      ,p_dei_attribute4
      => p_rec.dei_attribute4
      ,p_dei_attribute5
      => p_rec.dei_attribute5
      ,p_dei_attribute6
      => p_rec.dei_attribute6
      ,p_dei_attribute7
      => p_rec.dei_attribute7
      ,p_dei_attribute8
      => p_rec.dei_attribute8
      ,p_dei_attribute9
      => p_rec.dei_attribute9
      ,p_dei_attribute10
      => p_rec.dei_attribute10
      ,p_dei_attribute11
      => p_rec.dei_attribute11
      ,p_dei_attribute12
      => p_rec.dei_attribute12
      ,p_dei_attribute13
      => p_rec.dei_attribute13
      ,p_dei_attribute14
      => p_rec.dei_attribute14
      ,p_dei_attribute15
      => p_rec.dei_attribute15
      ,p_dei_attribute16
      => p_rec.dei_attribute16
      ,p_dei_attribute17
      => p_rec.dei_attribute17
      ,p_dei_attribute18
      => p_rec.dei_attribute18
      ,p_dei_attribute19
      => p_rec.dei_attribute19
      ,p_dei_attribute20
      => p_rec.dei_attribute20
      ,p_dei_attribute21
      => p_rec.dei_attribute21
      ,p_dei_attribute22
      => p_rec.dei_attribute22
      ,p_dei_attribute23
      => p_rec.dei_attribute23
      ,p_dei_attribute24
      => p_rec.dei_attribute24
      ,p_dei_attribute25
      => p_rec.dei_attribute25
      ,p_dei_attribute26
      => p_rec.dei_attribute26
      ,p_dei_attribute27
      => p_rec.dei_attribute27
      ,p_dei_attribute28
      => p_rec.dei_attribute28
      ,p_dei_attribute29
      => p_rec.dei_attribute29
      ,p_dei_attribute30
      => p_rec.dei_attribute30
      ,p_dei_information_category
      => p_rec.dei_information_category
      ,p_dei_information1
      => p_rec.dei_information1
      ,p_dei_information2
      => p_rec.dei_information2
      ,p_dei_information3
      => p_rec.dei_information3
      ,p_dei_information4
      => p_rec.dei_information4
      ,p_dei_information5
      => p_rec.dei_information5
      ,p_dei_information6
      => p_rec.dei_information6
      ,p_dei_information7
      => p_rec.dei_information7
      ,p_dei_information8
      => p_rec.dei_information8
      ,p_dei_information9
      => p_rec.dei_information9
      ,p_dei_information10
      => p_rec.dei_information10
      ,p_dei_information11
      => p_rec.dei_information11
      ,p_dei_information12
      => p_rec.dei_information12
      ,p_dei_information13
      => p_rec.dei_information13
      ,p_dei_information14
      => p_rec.dei_information14
      ,p_dei_information15
      => p_rec.dei_information15
      ,p_dei_information16
      => p_rec.dei_information16
      ,p_dei_information17
      => p_rec.dei_information17
      ,p_dei_information18
      => p_rec.dei_information18
      ,p_dei_information19
      => p_rec.dei_information19
      ,p_dei_information20
      => p_rec.dei_information20
      ,p_dei_information21
      => p_rec.dei_information21
      ,p_dei_information22
      => p_rec.dei_information22
      ,p_dei_information23
      => p_rec.dei_information23
      ,p_dei_information24
      => p_rec.dei_information24
      ,p_dei_information25
      => p_rec.dei_information25
      ,p_dei_information26
      => p_rec.dei_information26
      ,p_dei_information27
      => p_rec.dei_information27
      ,p_dei_information28
      => p_rec.dei_information28
      ,p_dei_information29
      => p_rec.dei_information29
      ,p_dei_information30
      => p_rec.dei_information30
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_person_id_o
      => hr_dei_shd.g_old_rec.person_id
      ,p_document_type_id_o
      => hr_dei_shd.g_old_rec.document_type_id
      ,p_document_number_o
      => hr_dei_shd.g_old_rec.document_number
      ,p_date_from_o
      => hr_dei_shd.g_old_rec.date_from
      ,p_date_to_o
      => hr_dei_shd.g_old_rec.date_to
      ,p_issued_by_o
      => hr_dei_shd.g_old_rec.issued_by
      ,p_issued_at_o
      => hr_dei_shd.g_old_rec.issued_at
      ,p_issued_date_o
      => hr_dei_shd.g_old_rec.issued_date
      ,p_issuing_authority_o
      => hr_dei_shd.g_old_rec.issuing_authority
      ,p_verified_by_o
      => hr_dei_shd.g_old_rec.verified_by
      ,p_verified_date_o
      => hr_dei_shd.g_old_rec.verified_date
      ,p_related_object_name_o
      => hr_dei_shd.g_old_rec.related_object_name
      ,p_related_object_id_col_o
      => hr_dei_shd.g_old_rec.related_object_id_col
      ,p_related_object_id_o
      => hr_dei_shd.g_old_rec.related_object_id
      ,p_dei_attribute_category_o
      => hr_dei_shd.g_old_rec.dei_attribute_category
      ,p_dei_attribute1_o
      => hr_dei_shd.g_old_rec.dei_attribute1
      ,p_dei_attribute2_o
      => hr_dei_shd.g_old_rec.dei_attribute2
      ,p_dei_attribute3_o
      => hr_dei_shd.g_old_rec.dei_attribute3
      ,p_dei_attribute4_o
      => hr_dei_shd.g_old_rec.dei_attribute4
      ,p_dei_attribute5_o
      => hr_dei_shd.g_old_rec.dei_attribute5
      ,p_dei_attribute6_o
      => hr_dei_shd.g_old_rec.dei_attribute6
      ,p_dei_attribute7_o
      => hr_dei_shd.g_old_rec.dei_attribute7
      ,p_dei_attribute8_o
      => hr_dei_shd.g_old_rec.dei_attribute8
      ,p_dei_attribute9_o
      => hr_dei_shd.g_old_rec.dei_attribute9
      ,p_dei_attribute10_o
      => hr_dei_shd.g_old_rec.dei_attribute10
      ,p_dei_attribute11_o
      => hr_dei_shd.g_old_rec.dei_attribute11
      ,p_dei_attribute12_o
      => hr_dei_shd.g_old_rec.dei_attribute12
      ,p_dei_attribute13_o
      => hr_dei_shd.g_old_rec.dei_attribute13
      ,p_dei_attribute14_o
      => hr_dei_shd.g_old_rec.dei_attribute14
      ,p_dei_attribute15_o
      => hr_dei_shd.g_old_rec.dei_attribute15
      ,p_dei_attribute16_o
      => hr_dei_shd.g_old_rec.dei_attribute16
      ,p_dei_attribute17_o
      => hr_dei_shd.g_old_rec.dei_attribute17
      ,p_dei_attribute18_o
      => hr_dei_shd.g_old_rec.dei_attribute18
      ,p_dei_attribute19_o
      => hr_dei_shd.g_old_rec.dei_attribute19
      ,p_dei_attribute20_o
      => hr_dei_shd.g_old_rec.dei_attribute20
      ,p_dei_attribute21_o
      => hr_dei_shd.g_old_rec.dei_attribute21
      ,p_dei_attribute22_o
      => hr_dei_shd.g_old_rec.dei_attribute22
      ,p_dei_attribute23_o
      => hr_dei_shd.g_old_rec.dei_attribute23
      ,p_dei_attribute24_o
      => hr_dei_shd.g_old_rec.dei_attribute24
      ,p_dei_attribute25_o
      => hr_dei_shd.g_old_rec.dei_attribute25
      ,p_dei_attribute26_o
      => hr_dei_shd.g_old_rec.dei_attribute26
      ,p_dei_attribute27_o
      => hr_dei_shd.g_old_rec.dei_attribute27
      ,p_dei_attribute28_o
      => hr_dei_shd.g_old_rec.dei_attribute28
      ,p_dei_attribute29_o
      => hr_dei_shd.g_old_rec.dei_attribute29
      ,p_dei_attribute30_o
      => hr_dei_shd.g_old_rec.dei_attribute30
      ,p_dei_information_category_o
      => hr_dei_shd.g_old_rec.dei_information_category
      ,p_dei_information1_o
      => hr_dei_shd.g_old_rec.dei_information1
      ,p_dei_information2_o
      => hr_dei_shd.g_old_rec.dei_information2
      ,p_dei_information3_o
      => hr_dei_shd.g_old_rec.dei_information3
      ,p_dei_information4_o
      => hr_dei_shd.g_old_rec.dei_information4
      ,p_dei_information5_o
      => hr_dei_shd.g_old_rec.dei_information5
      ,p_dei_information6_o
      => hr_dei_shd.g_old_rec.dei_information6
      ,p_dei_information7_o
      => hr_dei_shd.g_old_rec.dei_information7
      ,p_dei_information8_o
      => hr_dei_shd.g_old_rec.dei_information8
      ,p_dei_information9_o
      => hr_dei_shd.g_old_rec.dei_information9
      ,p_dei_information10_o
      => hr_dei_shd.g_old_rec.dei_information10
      ,p_dei_information11_o
      => hr_dei_shd.g_old_rec.dei_information11
      ,p_dei_information12_o
      => hr_dei_shd.g_old_rec.dei_information12
      ,p_dei_information13_o
      => hr_dei_shd.g_old_rec.dei_information13
      ,p_dei_information14_o
      => hr_dei_shd.g_old_rec.dei_information14
      ,p_dei_information15_o
      => hr_dei_shd.g_old_rec.dei_information15
      ,p_dei_information16_o
      => hr_dei_shd.g_old_rec.dei_information16
      ,p_dei_information17_o
      => hr_dei_shd.g_old_rec.dei_information17
      ,p_dei_information18_o
      => hr_dei_shd.g_old_rec.dei_information18
      ,p_dei_information19_o
      => hr_dei_shd.g_old_rec.dei_information19
      ,p_dei_information20_o
      => hr_dei_shd.g_old_rec.dei_information20
      ,p_dei_information21_o
      => hr_dei_shd.g_old_rec.dei_information21
      ,p_dei_information22_o
      => hr_dei_shd.g_old_rec.dei_information22
      ,p_dei_information23_o
      => hr_dei_shd.g_old_rec.dei_information23
      ,p_dei_information24_o
      => hr_dei_shd.g_old_rec.dei_information24
      ,p_dei_information25_o
      => hr_dei_shd.g_old_rec.dei_information25
      ,p_dei_information26_o
      => hr_dei_shd.g_old_rec.dei_information26
      ,p_dei_information27_o
      => hr_dei_shd.g_old_rec.dei_information27
      ,p_dei_information28_o
      => hr_dei_shd.g_old_rec.dei_information28
      ,p_dei_information29_o
      => hr_dei_shd.g_old_rec.dei_information29
      ,p_dei_information30_o
      => hr_dei_shd.g_old_rec.dei_information30
      ,p_request_id_o
      => hr_dei_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => hr_dei_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => hr_dei_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => hr_dei_shd.g_old_rec.program_update_date
      ,p_object_version_number_o
      => hr_dei_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_DOCUMENT_EXTRA_INFO'
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
  (p_rec in out nocopy hr_dei_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    hr_dei_shd.g_old_rec.person_id;
  End If;
  If (p_rec.document_type_id = hr_api.g_number) then
    p_rec.document_type_id :=
    hr_dei_shd.g_old_rec.document_type_id;
  End If;
  If (p_rec.document_number = hr_api.g_varchar2) then
    p_rec.document_number :=
    hr_dei_shd.g_old_rec.document_number;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    hr_dei_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    hr_dei_shd.g_old_rec.date_to;
  End If;
  If (p_rec.issued_by = hr_api.g_varchar2) then
    p_rec.issued_by :=
    hr_dei_shd.g_old_rec.issued_by;
  End If;
  If (p_rec.issued_at = hr_api.g_varchar2) then
    p_rec.issued_at :=
    hr_dei_shd.g_old_rec.issued_at;
  End If;
  If (p_rec.issued_date = hr_api.g_date) then
    p_rec.issued_date :=
    hr_dei_shd.g_old_rec.issued_date;
  End If;
  If (p_rec.issuing_authority = hr_api.g_varchar2) then
    p_rec.issuing_authority :=
    hr_dei_shd.g_old_rec.issuing_authority;
  End If;
  If (p_rec.verified_by = hr_api.g_number) then
    p_rec.verified_by :=
    hr_dei_shd.g_old_rec.verified_by;
  End If;
  If (p_rec.verified_date = hr_api.g_date) then
    p_rec.verified_date :=
    hr_dei_shd.g_old_rec.verified_date;
  End If;
  If (p_rec.related_object_name = hr_api.g_varchar2) then
    p_rec.related_object_name :=
    hr_dei_shd.g_old_rec.related_object_name;
  End If;
  If (p_rec.related_object_id_col = hr_api.g_varchar2) then
    p_rec.related_object_id_col :=
    hr_dei_shd.g_old_rec.related_object_id_col;
  End If;
  If (p_rec.related_object_id = hr_api.g_number) then
    p_rec.related_object_id :=
    hr_dei_shd.g_old_rec.related_object_id;
  End If;
  If (p_rec.dei_attribute_category = hr_api.g_varchar2) then
    p_rec.dei_attribute_category :=
    hr_dei_shd.g_old_rec.dei_attribute_category;
  End If;
  If (p_rec.dei_attribute1 = hr_api.g_varchar2) then
    p_rec.dei_attribute1 :=
    hr_dei_shd.g_old_rec.dei_attribute1;
  End If;
  If (p_rec.dei_attribute2 = hr_api.g_varchar2) then
    p_rec.dei_attribute2 :=
    hr_dei_shd.g_old_rec.dei_attribute2;
  End If;
  If (p_rec.dei_attribute3 = hr_api.g_varchar2) then
    p_rec.dei_attribute3 :=
    hr_dei_shd.g_old_rec.dei_attribute3;
  End If;
  If (p_rec.dei_attribute4 = hr_api.g_varchar2) then
    p_rec.dei_attribute4 :=
    hr_dei_shd.g_old_rec.dei_attribute4;
  End If;
  If (p_rec.dei_attribute5 = hr_api.g_varchar2) then
    p_rec.dei_attribute5 :=
    hr_dei_shd.g_old_rec.dei_attribute5;
  End If;
  If (p_rec.dei_attribute6 = hr_api.g_varchar2) then
    p_rec.dei_attribute6 :=
    hr_dei_shd.g_old_rec.dei_attribute6;
  End If;
  If (p_rec.dei_attribute7 = hr_api.g_varchar2) then
    p_rec.dei_attribute7 :=
    hr_dei_shd.g_old_rec.dei_attribute7;
  End If;
  If (p_rec.dei_attribute8 = hr_api.g_varchar2) then
    p_rec.dei_attribute8 :=
    hr_dei_shd.g_old_rec.dei_attribute8;
  End If;
  If (p_rec.dei_attribute9 = hr_api.g_varchar2) then
    p_rec.dei_attribute9 :=
    hr_dei_shd.g_old_rec.dei_attribute9;
  End If;
  If (p_rec.dei_attribute10 = hr_api.g_varchar2) then
    p_rec.dei_attribute10 :=
    hr_dei_shd.g_old_rec.dei_attribute10;
  End If;
  If (p_rec.dei_attribute11 = hr_api.g_varchar2) then
    p_rec.dei_attribute11 :=
    hr_dei_shd.g_old_rec.dei_attribute11;
  End If;
  If (p_rec.dei_attribute12 = hr_api.g_varchar2) then
    p_rec.dei_attribute12 :=
    hr_dei_shd.g_old_rec.dei_attribute12;
  End If;
  If (p_rec.dei_attribute13 = hr_api.g_varchar2) then
    p_rec.dei_attribute13 :=
    hr_dei_shd.g_old_rec.dei_attribute13;
  End If;
  If (p_rec.dei_attribute14 = hr_api.g_varchar2) then
    p_rec.dei_attribute14 :=
    hr_dei_shd.g_old_rec.dei_attribute14;
  End If;
  If (p_rec.dei_attribute15 = hr_api.g_varchar2) then
    p_rec.dei_attribute15 :=
    hr_dei_shd.g_old_rec.dei_attribute15;
  End If;
  If (p_rec.dei_attribute16 = hr_api.g_varchar2) then
    p_rec.dei_attribute16 :=
    hr_dei_shd.g_old_rec.dei_attribute16;
  End If;
  If (p_rec.dei_attribute17 = hr_api.g_varchar2) then
    p_rec.dei_attribute17 :=
    hr_dei_shd.g_old_rec.dei_attribute17;
  End If;
  If (p_rec.dei_attribute18 = hr_api.g_varchar2) then
    p_rec.dei_attribute18 :=
    hr_dei_shd.g_old_rec.dei_attribute18;
  End If;
  If (p_rec.dei_attribute19 = hr_api.g_varchar2) then
    p_rec.dei_attribute19 :=
    hr_dei_shd.g_old_rec.dei_attribute19;
  End If;
  If (p_rec.dei_attribute20 = hr_api.g_varchar2) then
    p_rec.dei_attribute20 :=
    hr_dei_shd.g_old_rec.dei_attribute20;
  End If;
  If (p_rec.dei_attribute21 = hr_api.g_varchar2) then
    p_rec.dei_attribute21 :=
    hr_dei_shd.g_old_rec.dei_attribute21;
  End If;
  If (p_rec.dei_attribute22 = hr_api.g_varchar2) then
    p_rec.dei_attribute22 :=
    hr_dei_shd.g_old_rec.dei_attribute22;
  End If;
  If (p_rec.dei_attribute23 = hr_api.g_varchar2) then
    p_rec.dei_attribute23 :=
    hr_dei_shd.g_old_rec.dei_attribute23;
  End If;
  If (p_rec.dei_attribute24 = hr_api.g_varchar2) then
    p_rec.dei_attribute24 :=
    hr_dei_shd.g_old_rec.dei_attribute24;
  End If;
  If (p_rec.dei_attribute25 = hr_api.g_varchar2) then
    p_rec.dei_attribute25 :=
    hr_dei_shd.g_old_rec.dei_attribute25;
  End If;
  If (p_rec.dei_attribute26 = hr_api.g_varchar2) then
    p_rec.dei_attribute26 :=
    hr_dei_shd.g_old_rec.dei_attribute26;
  End If;
  If (p_rec.dei_attribute27 = hr_api.g_varchar2) then
    p_rec.dei_attribute27 :=
    hr_dei_shd.g_old_rec.dei_attribute27;
  End If;
  If (p_rec.dei_attribute28 = hr_api.g_varchar2) then
    p_rec.dei_attribute28 :=
    hr_dei_shd.g_old_rec.dei_attribute28;
  End If;
  If (p_rec.dei_attribute29 = hr_api.g_varchar2) then
    p_rec.dei_attribute29 :=
    hr_dei_shd.g_old_rec.dei_attribute29;
  End If;
  If (p_rec.dei_attribute30 = hr_api.g_varchar2) then
    p_rec.dei_attribute30 :=
    hr_dei_shd.g_old_rec.dei_attribute30;
  End If;
  If (p_rec.dei_information_category = hr_api.g_varchar2) then
    p_rec.dei_information_category :=
    hr_dei_shd.g_old_rec.dei_information_category;
  End If;
  If (p_rec.dei_information1 = hr_api.g_varchar2) then
    p_rec.dei_information1 :=
    hr_dei_shd.g_old_rec.dei_information1;
  End If;
  If (p_rec.dei_information2 = hr_api.g_varchar2) then
    p_rec.dei_information2 :=
    hr_dei_shd.g_old_rec.dei_information2;
  End If;
  If (p_rec.dei_information3 = hr_api.g_varchar2) then
    p_rec.dei_information3 :=
    hr_dei_shd.g_old_rec.dei_information3;
  End If;
  If (p_rec.dei_information4 = hr_api.g_varchar2) then
    p_rec.dei_information4 :=
    hr_dei_shd.g_old_rec.dei_information4;
  End If;
  If (p_rec.dei_information5 = hr_api.g_varchar2) then
    p_rec.dei_information5 :=
    hr_dei_shd.g_old_rec.dei_information5;
  End If;
  If (p_rec.dei_information6 = hr_api.g_varchar2) then
    p_rec.dei_information6 :=
    hr_dei_shd.g_old_rec.dei_information6;
  End If;
  If (p_rec.dei_information7 = hr_api.g_varchar2) then
    p_rec.dei_information7 :=
    hr_dei_shd.g_old_rec.dei_information7;
  End If;
  If (p_rec.dei_information8 = hr_api.g_varchar2) then
    p_rec.dei_information8 :=
    hr_dei_shd.g_old_rec.dei_information8;
  End If;
  If (p_rec.dei_information9 = hr_api.g_varchar2) then
    p_rec.dei_information9 :=
    hr_dei_shd.g_old_rec.dei_information9;
  End If;
  If (p_rec.dei_information10 = hr_api.g_varchar2) then
    p_rec.dei_information10 :=
    hr_dei_shd.g_old_rec.dei_information10;
  End If;
  If (p_rec.dei_information11 = hr_api.g_varchar2) then
    p_rec.dei_information11 :=
    hr_dei_shd.g_old_rec.dei_information11;
  End If;
  If (p_rec.dei_information12 = hr_api.g_varchar2) then
    p_rec.dei_information12 :=
    hr_dei_shd.g_old_rec.dei_information12;
  End If;
  If (p_rec.dei_information13 = hr_api.g_varchar2) then
    p_rec.dei_information13 :=
    hr_dei_shd.g_old_rec.dei_information13;
  End If;
  If (p_rec.dei_information14 = hr_api.g_varchar2) then
    p_rec.dei_information14 :=
    hr_dei_shd.g_old_rec.dei_information14;
  End If;
  If (p_rec.dei_information15 = hr_api.g_varchar2) then
    p_rec.dei_information15 :=
    hr_dei_shd.g_old_rec.dei_information15;
  End If;
  If (p_rec.dei_information16 = hr_api.g_varchar2) then
    p_rec.dei_information16 :=
    hr_dei_shd.g_old_rec.dei_information16;
  End If;
  If (p_rec.dei_information17 = hr_api.g_varchar2) then
    p_rec.dei_information17 :=
    hr_dei_shd.g_old_rec.dei_information17;
  End If;
  If (p_rec.dei_information18 = hr_api.g_varchar2) then
    p_rec.dei_information18 :=
    hr_dei_shd.g_old_rec.dei_information18;
  End If;
  If (p_rec.dei_information19 = hr_api.g_varchar2) then
    p_rec.dei_information19 :=
    hr_dei_shd.g_old_rec.dei_information19;
  End If;
  If (p_rec.dei_information20 = hr_api.g_varchar2) then
    p_rec.dei_information20 :=
    hr_dei_shd.g_old_rec.dei_information20;
  End If;
  If (p_rec.dei_information21 = hr_api.g_varchar2) then
    p_rec.dei_information21 :=
    hr_dei_shd.g_old_rec.dei_information21;
  End If;
  If (p_rec.dei_information22 = hr_api.g_varchar2) then
    p_rec.dei_information22 :=
    hr_dei_shd.g_old_rec.dei_information22;
  End If;
  If (p_rec.dei_information23 = hr_api.g_varchar2) then
    p_rec.dei_information23 :=
    hr_dei_shd.g_old_rec.dei_information23;
  End If;
  If (p_rec.dei_information24 = hr_api.g_varchar2) then
    p_rec.dei_information24 :=
    hr_dei_shd.g_old_rec.dei_information24;
  End If;
  If (p_rec.dei_information25 = hr_api.g_varchar2) then
    p_rec.dei_information25 :=
    hr_dei_shd.g_old_rec.dei_information25;
  End If;
  If (p_rec.dei_information26 = hr_api.g_varchar2) then
    p_rec.dei_information26 :=
    hr_dei_shd.g_old_rec.dei_information26;
  End If;
  If (p_rec.dei_information27 = hr_api.g_varchar2) then
    p_rec.dei_information27 :=
    hr_dei_shd.g_old_rec.dei_information27;
  End If;
  If (p_rec.dei_information28 = hr_api.g_varchar2) then
    p_rec.dei_information28 :=
    hr_dei_shd.g_old_rec.dei_information28;
  End If;
  If (p_rec.dei_information29 = hr_api.g_varchar2) then
    p_rec.dei_information29 :=
    hr_dei_shd.g_old_rec.dei_information29;
  End If;
  If (p_rec.dei_information30 = hr_api.g_varchar2) then
    p_rec.dei_information30 :=
    hr_dei_shd.g_old_rec.dei_information30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    hr_dei_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    hr_dei_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    hr_dei_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    hr_dei_shd.g_old_rec.program_update_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hr_dei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_dei_shd.lck
    (p_rec.document_extra_info_id
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
  hr_dei_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  hr_dei_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_dei_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_dei_upd.post_update
     (p_rec
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
  (p_document_extra_info_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_document_type_id             in     number    default hr_api.g_number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_document_number              in     varchar2  default hr_api.g_varchar2
  ,p_issued_by                    in     varchar2  default hr_api.g_varchar2
  ,p_issued_at                    in     varchar2  default hr_api.g_varchar2
  ,p_issued_date                  in     date      default hr_api.g_date
  ,p_issuing_authority            in     varchar2  default hr_api.g_varchar2
  ,p_verified_by                  in     number    default hr_api.g_number
  ,p_verified_date                in     date      default hr_api.g_date
  ,p_related_object_name          in     varchar2  default hr_api.g_varchar2
  ,p_related_object_id_col        in     varchar2  default hr_api.g_varchar2
  ,p_related_object_id            in     number    default hr_api.g_number
  ,p_dei_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_dei_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_dei_information1             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information2             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information3             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information4             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information5             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information6             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information7             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information8             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information9             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information10            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information11            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information12            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information13            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information14            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information15            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information16            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information17            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information18            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information19            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information20            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information21            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information22            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information23            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information24            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information25            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information26            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information27            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information28            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information29            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information30            in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ) is
--
  l_rec   hr_dei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_dei_shd.convert_args
  (p_document_extra_info_id
  ,hr_api.g_number
  ,p_document_type_id
  ,p_document_number
  ,p_date_from
  ,p_date_to
  ,p_issued_by
  ,p_issued_at
  ,p_issued_date
  ,p_issuing_authority
  ,p_verified_by
  ,p_verified_date
  ,p_related_object_name
  ,p_related_object_id_col
  ,p_related_object_id
  ,p_dei_attribute_category
  ,p_dei_attribute1
  ,p_dei_attribute2
  ,p_dei_attribute3
  ,p_dei_attribute4
  ,p_dei_attribute5
  ,p_dei_attribute6
  ,p_dei_attribute7
  ,p_dei_attribute8
  ,p_dei_attribute9
  ,p_dei_attribute10
  ,p_dei_attribute11
  ,p_dei_attribute12
  ,p_dei_attribute13
  ,p_dei_attribute14
  ,p_dei_attribute15
  ,p_dei_attribute16
  ,p_dei_attribute17
  ,p_dei_attribute18
  ,p_dei_attribute19
  ,p_dei_attribute20
  ,p_dei_attribute21
  ,p_dei_attribute22
  ,p_dei_attribute23
  ,p_dei_attribute24
  ,p_dei_attribute25
  ,p_dei_attribute26
  ,p_dei_attribute27
  ,p_dei_attribute28
  ,p_dei_attribute29
  ,p_dei_attribute30
  ,p_dei_information_category
  ,p_dei_information1
  ,p_dei_information2
  ,p_dei_information3
  ,p_dei_information4
  ,p_dei_information5
  ,p_dei_information6
  ,p_dei_information7
  ,p_dei_information8
  ,p_dei_information9
  ,p_dei_information10
  ,p_dei_information11
  ,p_dei_information12
  ,p_dei_information13
  ,p_dei_information14
  ,p_dei_information15
  ,p_dei_information16
  ,p_dei_information17
  ,p_dei_information18
  ,p_dei_information19
  ,p_dei_information20
  ,p_dei_information21
  ,p_dei_information22
  ,p_dei_information23
  ,p_dei_information24
  ,p_dei_information25
  ,p_dei_information26
  ,p_dei_information27
  ,p_dei_information28
  ,p_dei_information29
  ,p_dei_information30
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_program_update_date
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_dei_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_dei_upd;

/
