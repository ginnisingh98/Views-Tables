--------------------------------------------------------
--  DDL for Package Body PER_CTR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTR_UPD" as
/* $Header: pectrrhi.pkb 120.2.12010000.3 2009/04/09 13:42:18 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ctr_upd.';  -- Global package name
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy per_ctr_shd.g_rec_type) is
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
  per_ctr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_contact_relationships Row
  --
  update per_contact_relationships
  set
  contact_type                      = p_rec.contact_type,
  comments                          = p_rec.comments,
  primary_contact_flag              = p_rec.primary_contact_flag,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  date_start                        = p_rec.date_start,
  start_life_reason_id              = p_rec.start_life_reason_id,
  date_end                          = p_rec.date_end,
  end_life_reason_id                = p_rec.end_life_reason_id,
  rltd_per_rsds_w_dsgntr_flag       = p_rec.rltd_per_rsds_w_dsgntr_flag,
  personal_flag                     = p_rec.personal_flag,
  sequence_number                   = p_rec.sequence_number,
  cont_attribute_category           = p_rec.cont_attribute_category,
  cont_attribute1                   = p_rec.cont_attribute1,
  cont_attribute2                   = p_rec.cont_attribute2,
  cont_attribute3                   = p_rec.cont_attribute3,
  cont_attribute4                   = p_rec.cont_attribute4,
  cont_attribute5                   = p_rec.cont_attribute5,
  cont_attribute6                   = p_rec.cont_attribute6,
  cont_attribute7                   = p_rec.cont_attribute7,
  cont_attribute8                   = p_rec.cont_attribute8,
  cont_attribute9                   = p_rec.cont_attribute9,
  cont_attribute10                  = p_rec.cont_attribute10,
  cont_attribute11                  = p_rec.cont_attribute11,
  cont_attribute12                  = p_rec.cont_attribute12,
  cont_attribute13                  = p_rec.cont_attribute13,
  cont_attribute14                  = p_rec.cont_attribute14,
  cont_attribute15                  = p_rec.cont_attribute15,
  cont_attribute16                  = p_rec.cont_attribute16,
  cont_attribute17                  = p_rec.cont_attribute17,
  cont_attribute18                  = p_rec.cont_attribute18,
  cont_attribute19                  = p_rec.cont_attribute19,
  cont_attribute20                  = p_rec.cont_attribute20,
  cont_information_category           = p_rec.cont_information_category,
  cont_information1                   = p_rec.cont_information1,
  cont_information2                   = p_rec.cont_information2,
  cont_information3                   = p_rec.cont_information3,
  cont_information4                   = p_rec.cont_information4,
  cont_information5                   = p_rec.cont_information5,
  cont_information6                   = p_rec.cont_information6,
  cont_information7                   = p_rec.cont_information7,
  cont_information8                   = p_rec.cont_information8,
  cont_information9                   = p_rec.cont_information9,
  cont_information10                  = p_rec.cont_information10,
  cont_information11                  = p_rec.cont_information11,
  cont_information12                  = p_rec.cont_information12,
  cont_information13                  = p_rec.cont_information13,
  cont_information14                  = p_rec.cont_information14,
  cont_information15                  = p_rec.cont_information15,
  cont_information16                  = p_rec.cont_information16,
  cont_information17                  = p_rec.cont_information17,
  cont_information18                  = p_rec.cont_information18,
  cont_information19                  = p_rec.cont_information19,
  cont_information20                  = p_rec.cont_information20,
  third_party_pay_flag              = p_rec.third_party_pay_flag,
  bondholder_flag                   = p_rec.bondholder_flag,
  dependent_flag                    = p_rec.dependent_flag,
  beneficiary_flag                  = p_rec.beneficiary_flag,
  object_version_number             = p_rec.object_version_number
  where contact_relationship_id = p_rec.contact_relationship_id;
  --
  per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
    per_ctr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
    per_ctr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
    per_ctr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in per_ctr_shd.g_rec_type) is
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec            in per_ctr_shd.g_rec_type,
                      p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_update';
  --
  -- Start of fix for WWBUG 1408379
  --
  l_old ben_con_ler.g_con_ler_rec;
  l_new ben_con_ler.g_con_ler_rec;
  --
  -- End of fix for WWBUG 1408379
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  begin
    per_ctr_rku.after_update
      (p_contact_relationship_id        => p_rec.contact_relationship_id
      ,p_business_group_id              => p_rec.business_group_id
      ,p_person_id                      => p_rec.person_id
      ,p_contact_person_id              => p_rec.contact_person_id
      ,p_contact_type                   => p_rec.contact_type
      ,p_comments                       => p_rec.comments
      ,p_primary_contact_flag           => p_rec.primary_contact_flag
      ,p_request_id                     => p_rec.request_id
      ,p_program_application_id         => p_rec.program_application_id
      ,p_program_id                     => p_rec.program_id
      ,p_program_update_date            => p_rec.program_update_date
      ,p_date_start                     => p_rec.date_start
      ,p_start_life_reason_id           => p_rec.start_life_reason_id
      ,p_date_end                       => p_rec.date_end
      ,p_end_life_reason_id             => p_rec.end_life_reason_id
      ,p_rltd_per_rsds_w_dsgntr_flag    => p_rec.rltd_per_rsds_w_dsgntr_flag
      ,p_personal_flag                  => p_rec.personal_flag
      ,p_sequence_number                => p_rec.sequence_number
      ,p_cont_attribute_category        => p_rec.cont_attribute_category
      ,p_cont_attribute1                => p_rec.cont_attribute1
      ,p_cont_attribute2                => p_rec.cont_attribute2
      ,p_cont_attribute3                => p_rec.cont_attribute3
      ,p_cont_attribute4                => p_rec.cont_attribute4
      ,p_cont_attribute5                => p_rec.cont_attribute5
      ,p_cont_attribute6                => p_rec.cont_attribute6
      ,p_cont_attribute7                => p_rec.cont_attribute7
      ,p_cont_attribute8                => p_rec.cont_attribute8
      ,p_cont_attribute9                => p_rec.cont_attribute9
      ,p_cont_attribute10               => p_rec.cont_attribute10
      ,p_cont_attribute11               => p_rec.cont_attribute11
      ,p_cont_attribute12               => p_rec.cont_attribute12
      ,p_cont_attribute13               => p_rec.cont_attribute13
      ,p_cont_attribute14               => p_rec.cont_attribute14
      ,p_cont_attribute15               => p_rec.cont_attribute15
      ,p_cont_attribute16               => p_rec.cont_attribute16
      ,p_cont_attribute17               => p_rec.cont_attribute17
      ,p_cont_attribute18               => p_rec.cont_attribute18
      ,p_cont_attribute19               => p_rec.cont_attribute19
      ,p_cont_attribute20               => p_rec.cont_attribute20
      ,p_cont_information_category        => p_rec.cont_information_category
      ,p_cont_information1                => p_rec.cont_information1
      ,p_cont_information2                => p_rec.cont_information2
      ,p_cont_information3                => p_rec.cont_information3
      ,p_cont_information4                => p_rec.cont_information4
      ,p_cont_information5                => p_rec.cont_information5
      ,p_cont_information6                => p_rec.cont_information6
      ,p_cont_information7                => p_rec.cont_information7
      ,p_cont_information8                => p_rec.cont_information8
      ,p_cont_information9                => p_rec.cont_information9
      ,p_cont_information10               => p_rec.cont_information10
      ,p_cont_information11               => p_rec.cont_information11
      ,p_cont_information12               => p_rec.cont_information12
      ,p_cont_information13               => p_rec.cont_information13
      ,p_cont_information14               => p_rec.cont_information14
      ,p_cont_information15               => p_rec.cont_information15
      ,p_cont_information16               => p_rec.cont_information16
      ,p_cont_information17               => p_rec.cont_information17
      ,p_cont_information18               => p_rec.cont_information18
      ,p_cont_information19               => p_rec.cont_information19
      ,p_cont_information20               => p_rec.cont_information20
      ,p_third_party_pay_flag           => p_rec.third_party_pay_flag
      ,p_bondholder_flag                => p_rec.bondholder_flag
      ,p_dependent_flag                 => p_rec.dependent_flag
      ,p_beneficiary_flag               => p_rec.beneficiary_flag
      ,p_object_version_number          => p_rec.object_version_number
      ,p_effective_date                 => p_effective_date
      ,p_business_group_id_o
          => per_ctr_shd.g_old_rec.business_group_id
      ,p_person_id_o
          => per_ctr_shd.g_old_rec.person_id
      ,p_contact_person_id_o
          => per_ctr_shd.g_old_rec.contact_person_id
      ,p_contact_type_o
          => per_ctr_shd.g_old_rec.contact_type
      ,p_comments_o
          => per_ctr_shd.g_old_rec.comments
      ,p_primary_contact_flag_o
          => per_ctr_shd.g_old_rec.primary_contact_flag
      ,p_request_id_o
          => per_ctr_shd.g_old_rec.request_id
      ,p_program_application_id_o
          => per_ctr_shd.g_old_rec.program_application_id
      ,p_program_id_o
          => per_ctr_shd.g_old_rec.program_id
      ,p_program_update_date_o
          => per_ctr_shd.g_old_rec.program_update_date
      ,p_date_start_o
          => per_ctr_shd.g_old_rec.date_start
      ,p_start_life_id_o
          => per_ctr_shd.g_old_rec.start_life_reason_id
      ,p_date_end_o
          => per_ctr_shd.g_old_rec.date_end
      ,p_end_life_id_o
          => per_ctr_shd.g_old_rec.end_life_reason_id
      ,p_rltd_per_dsgntr_flag_o
         => per_ctr_shd.g_old_rec.rltd_per_rsds_w_dsgntr_flag
      ,p_personal_flag_o
         => per_ctr_shd.g_old_rec.personal_flag
      ,p_sequence_number_o
    => per_ctr_shd.g_old_rec.sequence_number
      ,p_cont_attribute_category_o
          => per_ctr_shd.g_old_rec.cont_attribute_category
      ,p_cont_attribute1_o
          => per_ctr_shd.g_old_rec.cont_attribute1
      ,p_cont_attribute2_o
          => per_ctr_shd.g_old_rec.cont_attribute2
      ,p_cont_attribute3_o
          => per_ctr_shd.g_old_rec.cont_attribute3
      ,p_cont_attribute4_o
          => per_ctr_shd.g_old_rec.cont_attribute4
      ,p_cont_attribute5_o
          => per_ctr_shd.g_old_rec.cont_attribute5
      ,p_cont_attribute6_o
          => per_ctr_shd.g_old_rec.cont_attribute6
      ,p_cont_attribute7_o
          => per_ctr_shd.g_old_rec.cont_attribute7
      ,p_cont_attribute8_o
          => per_ctr_shd.g_old_rec.cont_attribute8
      ,p_cont_attribute9_o
          => per_ctr_shd.g_old_rec.cont_attribute9
      ,p_cont_attribute10_o
          => per_ctr_shd.g_old_rec.cont_attribute10
      ,p_cont_attribute11_o
          => per_ctr_shd.g_old_rec.cont_attribute11
      ,p_cont_attribute12_o
          => per_ctr_shd.g_old_rec.cont_attribute12
      ,p_cont_attribute13_o
          => per_ctr_shd.g_old_rec.cont_attribute13
      ,p_cont_attribute14_o
          => per_ctr_shd.g_old_rec.cont_attribute14
      ,p_cont_attribute15_o
          => per_ctr_shd.g_old_rec.cont_attribute15
      ,p_cont_attribute16_o
          => per_ctr_shd.g_old_rec.cont_attribute16
      ,p_cont_attribute17_o
          => per_ctr_shd.g_old_rec.cont_attribute17
      ,p_cont_attribute18_o
          => per_ctr_shd.g_old_rec.cont_attribute18
      ,p_cont_attribute19_o
          => per_ctr_shd.g_old_rec.cont_attribute19
      ,p_cont_attribute20_o
          => per_ctr_shd.g_old_rec.cont_attribute20
      ,p_cont_information_category_o
          => per_ctr_shd.g_old_rec.cont_information_category
      ,p_cont_information1_o
          => per_ctr_shd.g_old_rec.cont_information1
      ,p_cont_information2_o
          => per_ctr_shd.g_old_rec.cont_information2
      ,p_cont_information3_o
          => per_ctr_shd.g_old_rec.cont_information3
      ,p_cont_information4_o
          => per_ctr_shd.g_old_rec.cont_information4
      ,p_cont_information5_o
          => per_ctr_shd.g_old_rec.cont_information5
      ,p_cont_information6_o
          => per_ctr_shd.g_old_rec.cont_information6
      ,p_cont_information7_o
          => per_ctr_shd.g_old_rec.cont_information7
      ,p_cont_information8_o
          => per_ctr_shd.g_old_rec.cont_information8
      ,p_cont_information9_o
          => per_ctr_shd.g_old_rec.cont_information9
      ,p_cont_information10_o
          => per_ctr_shd.g_old_rec.cont_information10
      ,p_cont_information11_o
          => per_ctr_shd.g_old_rec.cont_information11
      ,p_cont_information12_o
          => per_ctr_shd.g_old_rec.cont_information12
      ,p_cont_information13_o
          => per_ctr_shd.g_old_rec.cont_information13
      ,p_cont_information14_o
          => per_ctr_shd.g_old_rec.cont_information14
      ,p_cont_information15_o
          => per_ctr_shd.g_old_rec.cont_information15
      ,p_cont_information16_o
          => per_ctr_shd.g_old_rec.cont_information16
      ,p_cont_information17_o
          => per_ctr_shd.g_old_rec.cont_information17
      ,p_cont_information18_o
          => per_ctr_shd.g_old_rec.cont_information18
      ,p_cont_information19_o
          => per_ctr_shd.g_old_rec.cont_information19
      ,p_cont_information20_o
          => per_ctr_shd.g_old_rec.cont_information20
      ,p_third_party_pay_flag_o
          => per_ctr_shd.g_old_rec.third_party_pay_flag
      ,p_bondholder_flag_o
          => per_ctr_shd.g_old_rec.bondholder_flag
      ,p_dependent_flag_o
          => per_ctr_shd.g_old_rec.dependent_flag
      ,p_beneficiary_flag_o
          => per_ctr_shd.g_old_rec.beneficiary_flag
      ,p_object_version_number_o
          => per_ctr_shd.g_old_rec.object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CONTACT_RELATIONSHIPS'
        ,p_hook_type   => 'AU'
        );
  end;
  --
  -- Start of Fix for WWBUG 1408379
  --
  l_old.person_id := per_ctr_shd.g_old_rec.person_id;
  l_old.contact_person_id := per_ctr_shd.g_old_rec.contact_person_id;
  l_old.business_group_id := per_ctr_shd.g_old_rec.business_group_id;
  l_old.date_start := per_ctr_shd.g_old_rec.date_start;
  l_old.date_end := per_ctr_shd.g_old_rec.date_end;
  l_old.contact_type := per_ctr_shd.g_old_rec.contact_type;
  l_old.personal_flag := per_ctr_shd.g_old_rec.personal_flag;
  l_old.start_life_reason_id := per_ctr_shd.g_old_rec.start_life_reason_id;
  l_old.end_life_reason_id := per_ctr_shd.g_old_rec.end_life_reason_id;
  l_old.rltd_per_rsds_w_dsgntr_flag := per_ctr_shd.g_old_rec.rltd_per_rsds_w_dsgntr_flag;
  l_old.contact_relationship_id := per_ctr_shd.g_old_rec.contact_relationship_id;
  l_new.person_id := p_rec.person_id;
  l_new.contact_person_id := p_rec.contact_person_id;
  l_new.business_group_id := p_rec.business_group_id;
  l_new.date_start := p_rec.date_start;
  l_new.date_end := p_rec.date_end;
  l_new.contact_type := p_rec.contact_type;
  l_new.personal_flag := p_rec.personal_flag;
  l_new.start_life_reason_id := p_rec.start_life_reason_id;
  l_new.end_life_reason_id := p_rec.end_life_reason_id;
  l_new.rltd_per_rsds_w_dsgntr_flag := p_rec.rltd_per_rsds_w_dsgntr_flag;
  l_new.contact_relationship_id := p_rec.contact_relationship_id;
  --
  ben_con_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => p_effective_date);
  --
  -- End of Fix for WWBUG 1408379
  --
  --
  -- End of API User Hook for post_update.
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_ctr_shd.g_rec_type) is
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
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_ctr_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_ctr_shd.g_old_rec.person_id;
  End If;
  If (p_rec.contact_person_id = hr_api.g_number) then
    p_rec.contact_person_id :=
    per_ctr_shd.g_old_rec.contact_person_id;
  End If;
  If (p_rec.contact_type = hr_api.g_varchar2) then
    p_rec.contact_type :=
    per_ctr_shd.g_old_rec.contact_type;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_ctr_shd.g_old_rec.comments;
  End If;
  If (p_rec.primary_contact_flag = hr_api.g_varchar2) then
    p_rec.primary_contact_flag :=
    per_ctr_shd.g_old_rec.primary_contact_flag;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_ctr_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_ctr_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_ctr_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_ctr_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.date_start = hr_api.g_date) then
    p_rec.date_start :=
     per_ctr_shd.g_old_rec.date_start;
  End If;
  If (p_rec.start_life_reason_id = hr_api.g_number) then
    p_rec.start_life_reason_id :=
      per_ctr_shd.g_old_rec.start_life_reason_id;
  End If;
  If (p_rec.date_end = hr_api.g_date) then
    p_rec.date_end :=
       per_ctr_shd.g_old_rec.date_end;
  End If;
  If (p_rec.end_life_reason_id = hr_api.g_number) then
    p_rec.end_life_reason_id :=
      per_ctr_shd.g_old_rec.end_life_reason_id;
  End If;
  If (p_rec.rltd_per_rsds_w_dsgntr_flag = hr_api.g_varchar2) then
    p_rec.rltd_per_rsds_w_dsgntr_flag :=
      per_ctr_shd.g_old_rec.rltd_per_rsds_w_dsgntr_flag;
  End If;
  If (p_rec.personal_flag = hr_api.g_varchar2) then
    p_rec.personal_flag :=
      per_ctr_shd.g_old_rec.personal_flag;
  End If;
  If (p_rec.sequence_number = hr_api.g_number) then
    p_rec.sequence_number :=
      per_ctr_shd.g_old_rec.sequence_number;
  End If;
  If (p_rec.cont_attribute_category = hr_api.g_varchar2) then
    p_rec.cont_attribute_category :=
    per_ctr_shd.g_old_rec.cont_attribute_category;
  End If;
  If (p_rec.cont_attribute1 = hr_api.g_varchar2) then
    p_rec.cont_attribute1 :=
    per_ctr_shd.g_old_rec.cont_attribute1;
  End If;
  If (p_rec.cont_attribute2 = hr_api.g_varchar2) then
    p_rec.cont_attribute2 :=
    per_ctr_shd.g_old_rec.cont_attribute2;
  End If;
  If (p_rec.cont_attribute3 = hr_api.g_varchar2) then
    p_rec.cont_attribute3 :=
    per_ctr_shd.g_old_rec.cont_attribute3;
  End If;
  If (p_rec.cont_attribute4 = hr_api.g_varchar2) then
    p_rec.cont_attribute4 :=
    per_ctr_shd.g_old_rec.cont_attribute4;
  End If;
  If (p_rec.cont_attribute5 = hr_api.g_varchar2) then
    p_rec.cont_attribute5 :=
    per_ctr_shd.g_old_rec.cont_attribute5;
  End If;
  If (p_rec.cont_attribute6 = hr_api.g_varchar2) then
    p_rec.cont_attribute6 :=
    per_ctr_shd.g_old_rec.cont_attribute6;
  End If;
  If (p_rec.cont_attribute7 = hr_api.g_varchar2) then
    p_rec.cont_attribute7 :=
    per_ctr_shd.g_old_rec.cont_attribute7;
  End If;
  If (p_rec.cont_attribute8 = hr_api.g_varchar2) then
    p_rec.cont_attribute8 :=
    per_ctr_shd.g_old_rec.cont_attribute8;
  End If;
  If (p_rec.cont_attribute9 = hr_api.g_varchar2) then
    p_rec.cont_attribute9 :=
    per_ctr_shd.g_old_rec.cont_attribute9;
  End If;
  If (p_rec.cont_attribute10 = hr_api.g_varchar2) then
    p_rec.cont_attribute10 :=
    per_ctr_shd.g_old_rec.cont_attribute10;
  End If;
  If (p_rec.cont_attribute11 = hr_api.g_varchar2) then
    p_rec.cont_attribute11 :=
    per_ctr_shd.g_old_rec.cont_attribute11;
  End If;
  If (p_rec.cont_attribute12 = hr_api.g_varchar2) then
    p_rec.cont_attribute12 :=
    per_ctr_shd.g_old_rec.cont_attribute12;
  End If;
  If (p_rec.cont_attribute13 = hr_api.g_varchar2) then
    p_rec.cont_attribute13 :=
    per_ctr_shd.g_old_rec.cont_attribute13;
  End If;
  If (p_rec.cont_attribute14 = hr_api.g_varchar2) then
    p_rec.cont_attribute14 :=
    per_ctr_shd.g_old_rec.cont_attribute14;
  End If;
  If (p_rec.cont_attribute15 = hr_api.g_varchar2) then
    p_rec.cont_attribute15 :=
    per_ctr_shd.g_old_rec.cont_attribute15;
  End If;
  If (p_rec.cont_attribute16 = hr_api.g_varchar2) then
    p_rec.cont_attribute16 :=
    per_ctr_shd.g_old_rec.cont_attribute16;
  End If;
  If (p_rec.cont_attribute17 = hr_api.g_varchar2) then
    p_rec.cont_attribute17 :=
    per_ctr_shd.g_old_rec.cont_attribute17;
  End If;
  If (p_rec.cont_attribute18 = hr_api.g_varchar2) then
    p_rec.cont_attribute18 :=
    per_ctr_shd.g_old_rec.cont_attribute18;
  End If;
  If (p_rec.cont_attribute19 = hr_api.g_varchar2) then
    p_rec.cont_attribute19 :=
    per_ctr_shd.g_old_rec.cont_attribute19;
  End If;
  If (p_rec.cont_attribute20 = hr_api.g_varchar2) then
    p_rec.cont_attribute20 :=
    per_ctr_shd.g_old_rec.cont_attribute20;
  End If;
  If (p_rec.cont_information_category = hr_api.g_varchar2) then
    p_rec.cont_information_category :=
    per_ctr_shd.g_old_rec.cont_information_category;
  End If;
  If (p_rec.cont_information1 = hr_api.g_varchar2) then
    p_rec.cont_information1 :=
    per_ctr_shd.g_old_rec.cont_information1;
  End If;
  If (p_rec.cont_information2 = hr_api.g_varchar2) then
    p_rec.cont_information2 :=
    per_ctr_shd.g_old_rec.cont_information2;
  End If;
  If (p_rec.cont_information3 = hr_api.g_varchar2) then
    p_rec.cont_information3 :=
    per_ctr_shd.g_old_rec.cont_information3;
  End If;
  If (p_rec.cont_information4 = hr_api.g_varchar2) then
    p_rec.cont_information4 :=
    per_ctr_shd.g_old_rec.cont_information4;
  End If;
  If (p_rec.cont_information5 = hr_api.g_varchar2) then
    p_rec.cont_information5 :=
    per_ctr_shd.g_old_rec.cont_information5;
  End If;
  If (p_rec.cont_information6 = hr_api.g_varchar2) then
    p_rec.cont_information6 :=
    per_ctr_shd.g_old_rec.cont_information6;
  End If;
  If (p_rec.cont_information7 = hr_api.g_varchar2) then
    p_rec.cont_information7 :=
    per_ctr_shd.g_old_rec.cont_information7;
  End If;
  If (p_rec.cont_information8 = hr_api.g_varchar2) then
    p_rec.cont_information8 :=
    per_ctr_shd.g_old_rec.cont_information8;
  End If;
  If (p_rec.cont_information9 = hr_api.g_varchar2) then
    p_rec.cont_information9 :=
    per_ctr_shd.g_old_rec.cont_information9;
  End If;
  If (p_rec.cont_information10 = hr_api.g_varchar2) then
    p_rec.cont_information10 :=
    per_ctr_shd.g_old_rec.cont_information10;
  End If;
  If (p_rec.cont_information11 = hr_api.g_varchar2) then
    p_rec.cont_information11 :=
    per_ctr_shd.g_old_rec.cont_information11;
  End If;
  If (p_rec.cont_information12 = hr_api.g_varchar2) then
    p_rec.cont_information12 :=
    per_ctr_shd.g_old_rec.cont_information12;
  End If;
  If (p_rec.cont_information13 = hr_api.g_varchar2) then
    p_rec.cont_information13 :=
    per_ctr_shd.g_old_rec.cont_information13;
  End If;
  If (p_rec.cont_information14 = hr_api.g_varchar2) then
    p_rec.cont_information14 :=
    per_ctr_shd.g_old_rec.cont_information14;
  End If;
  If (p_rec.cont_information15 = hr_api.g_varchar2) then
    p_rec.cont_information15 :=
    per_ctr_shd.g_old_rec.cont_information15;
  End If;
  If (p_rec.cont_information16 = hr_api.g_varchar2) then
    p_rec.cont_information16 :=
    per_ctr_shd.g_old_rec.cont_information16;
  End If;
  If (p_rec.cont_information17 = hr_api.g_varchar2) then
    p_rec.cont_information17 :=
    per_ctr_shd.g_old_rec.cont_information17;
  End If;
  If (p_rec.cont_information18 = hr_api.g_varchar2) then
    p_rec.cont_information18 :=
    per_ctr_shd.g_old_rec.cont_information18;
  End If;
  If (p_rec.cont_information19 = hr_api.g_varchar2) then
    p_rec.cont_information19 :=
    per_ctr_shd.g_old_rec.cont_information19;
  End If;
  If (p_rec.cont_information20 = hr_api.g_varchar2) then
    p_rec.cont_information20 :=
    per_ctr_shd.g_old_rec.cont_information20;
  End If;
  If (p_rec.third_party_pay_flag = hr_api.g_varchar2) then
    p_rec.third_party_pay_flag :=
    per_ctr_shd.g_old_rec.third_party_pay_flag;
  End If;
  If (p_rec.bondholder_flag = hr_api.g_varchar2) then
    p_rec.bondholder_flag :=
    per_ctr_shd.g_old_rec.bondholder_flag;
  End If;
  If (p_rec.dependent_flag = hr_api.g_varchar2) then
    p_rec.dependent_flag :=
    per_ctr_shd.g_old_rec.dependent_flag;
  End If;
  If (p_rec.beneficiary_flag = hr_api.g_varchar2) then
    p_rec.beneficiary_flag :=
    per_ctr_shd.g_old_rec.beneficiary_flag;
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
  (
  p_rec            in out nocopy per_ctr_shd.g_rec_type,
  p_effective_date in date,
  p_validate       in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_per_ctr;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_ctr_shd.lck
   (
   p_rec.contact_relationship_id,
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
  per_ctr_bus.update_validate(p_rec
                             ,p_effective_date);
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
  post_update(p_rec
             ,p_effective_date);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_per_ctr;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_contact_relationship_id      in number,
  p_contact_type                 in varchar2         default hr_api.g_varchar2,
  p_comments                     in long             default hr_api.g_varchar2,
  p_primary_contact_flag         in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_date_start                   in date             default hr_api.g_date,
  p_start_life_reason_id         in number           default hr_api.g_number,
  p_date_end                     in date             default hr_api.g_date,
  p_end_life_reason_id           in number           default hr_api.g_number,
  p_rltd_per_rsds_w_dsgntr_flag  in varchar2         default hr_api.g_varchar2,
  p_personal_flag                in varchar2         default hr_api.g_varchar2,
  p_sequence_number              in number           default hr_api.g_number,
  p_cont_attribute_category      in varchar2         default hr_api.g_varchar2,
  p_cont_attribute1              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute2              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute3              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute4              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute5              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute6              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute7              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute8              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute9              in varchar2         default hr_api.g_varchar2,
  p_cont_attribute10             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute11             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute12             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute13             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute14             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute15             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute16             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute17             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute18             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute19             in varchar2         default hr_api.g_varchar2,
  p_cont_attribute20             in varchar2         default hr_api.g_varchar2,
  p_cont_information_category      in varchar2         default hr_api.g_varchar2,
  p_cont_information1              in varchar2         default hr_api.g_varchar2,
  p_cont_information2              in varchar2         default hr_api.g_varchar2,
  p_cont_information3              in varchar2         default hr_api.g_varchar2,
  p_cont_information4              in varchar2         default hr_api.g_varchar2,
  p_cont_information5              in varchar2         default hr_api.g_varchar2,
  p_cont_information6              in varchar2         default hr_api.g_varchar2,
  p_cont_information7              in varchar2         default hr_api.g_varchar2,
  p_cont_information8              in varchar2         default hr_api.g_varchar2,
  p_cont_information9              in varchar2         default hr_api.g_varchar2,
  p_cont_information10             in varchar2         default hr_api.g_varchar2,
  p_cont_information11             in varchar2         default hr_api.g_varchar2,
  p_cont_information12             in varchar2         default hr_api.g_varchar2,
  p_cont_information13             in varchar2         default hr_api.g_varchar2,
  p_cont_information14             in varchar2         default hr_api.g_varchar2,
  p_cont_information15             in varchar2         default hr_api.g_varchar2,
  p_cont_information16             in varchar2         default hr_api.g_varchar2,
  p_cont_information17             in varchar2         default hr_api.g_varchar2,
  p_cont_information18             in varchar2         default hr_api.g_varchar2,
  p_cont_information19             in varchar2         default hr_api.g_varchar2,
  p_cont_information20             in varchar2         default hr_api.g_varchar2,
  p_third_party_pay_flag         in varchar2         default hr_api.g_varchar2,
  p_bondholder_flag              in varchar2         default hr_api.g_varchar2,
  p_dependent_flag               in varchar2         default hr_api.g_varchar2,
  p_beneficiary_flag             in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date               in date,
  p_validate                     in boolean      default false
  ) is
--
  l_rec    per_ctr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_ctr_shd.convert_args
  (
  p_contact_relationship_id,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  p_contact_type,
  p_comments,
  p_primary_contact_flag,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_date_start,
  p_start_life_reason_id,
  p_date_end,
  p_end_life_reason_id,
  p_rltd_per_rsds_w_dsgntr_flag,
  p_personal_flag,
  p_sequence_number,
  p_cont_attribute_category,
  p_cont_attribute1,
  p_cont_attribute2,
  p_cont_attribute3,
  p_cont_attribute4,
  p_cont_attribute5,
  p_cont_attribute6,
  p_cont_attribute7,
  p_cont_attribute8,
  p_cont_attribute9,
  p_cont_attribute10,
  p_cont_attribute11,
  p_cont_attribute12,
  p_cont_attribute13,
  p_cont_attribute14,
  p_cont_attribute15,
  p_cont_attribute16,
  p_cont_attribute17,
  p_cont_attribute18,
  p_cont_attribute19,
  p_cont_attribute20,
  p_cont_information_category,
  p_cont_information1,
  p_cont_information2,
  p_cont_information3,
  p_cont_information4,
  p_cont_information5,
  p_cont_information6,
  p_cont_information7,
  p_cont_information8,
  p_cont_information9,
  p_cont_information10,
  p_cont_information11,
  p_cont_information12,
  p_cont_information13,
  p_cont_information14,
  p_cont_information15,
  p_cont_information16,
  p_cont_information17,
  p_cont_information18,
  p_cont_information19,
  p_cont_information20,
  p_third_party_pay_flag,
  p_bondholder_flag,
  p_dependent_flag,
  p_beneficiary_flag,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_ctr_upd;

/
