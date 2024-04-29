--------------------------------------------------------
--  DDL for Package Body PER_QUA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QUA_UPD" as
/* $Header: pequarhi.pkb 120.0.12010000.2 2008/08/06 09:31:13 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_qua_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy per_qua_shd.g_rec_type) is
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
  per_qua_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_qualifications Row
  --
  update per_qualifications
  set
  qualification_id                  = p_rec.qualification_id,
  business_group_id                 = p_rec.business_group_id,
  object_version_number             = p_rec.object_version_number,
  person_id                         = p_rec.person_id,
  title                             = p_rec.title,
  grade_attained                    = p_rec.grade_attained,
  status                            = p_rec.status,
  awarded_date                      = p_rec.awarded_date,
  fee                               = p_rec.fee,
  fee_currency                      = p_rec.fee_currency,
  training_completed_amount         = p_rec.training_completed_amount,
  reimbursement_arrangements        = p_rec.reimbursement_arrangements,
  training_completed_units          = p_rec.training_completed_units,
  total_training_amount             = p_rec.total_training_amount,
  start_date                        = p_rec.start_date,
  end_date                          = p_rec.end_date,
  license_number                    = p_rec.license_number,
  expiry_date                       = p_rec.expiry_date,
  license_restrictions              = p_rec.license_restrictions,
  projected_completion_date         = p_rec.projected_completion_date,
  awarding_body                     = p_rec.awarding_body,
  tuition_method                    = p_rec.tuition_method,
  group_ranking                     = p_rec.group_ranking,
  comments                          = p_rec.comments,
  qualification_type_id             = p_rec.qualification_type_id,
  attendance_id                     = p_rec.attendance_id,
  attribute_category                = p_rec.attribute_category,
  attribute1                        = p_rec.attribute1,
  attribute2                        = p_rec.attribute2,
  attribute3                        = p_rec.attribute3,
  attribute4                        = p_rec.attribute4,
  attribute5                        = p_rec.attribute5,
  attribute6                        = p_rec.attribute6,
  attribute7                        = p_rec.attribute7,
  attribute8                        = p_rec.attribute8,
  attribute9                        = p_rec.attribute9,
  attribute10                       = p_rec.attribute10,
  attribute11                       = p_rec.attribute11,
  attribute12                       = p_rec.attribute12,
  attribute13                       = p_rec.attribute13,
  attribute14                       = p_rec.attribute14,
  attribute15                       = p_rec.attribute15,
  attribute16                       = p_rec.attribute16,
  attribute17                       = p_rec.attribute17,
  attribute18                       = p_rec.attribute18,
  attribute19                       = p_rec.attribute19,
  attribute20                       = p_rec.attribute20,
  qua_information_category                = p_rec.qua_information_category,
  qua_information1                        = p_rec.qua_information1,
  qua_information2                        = p_rec.qua_information2,
  qua_information3                        = p_rec.qua_information3,
  qua_information4                        = p_rec.qua_information4,
  qua_information5                        = p_rec.qua_information5,
  qua_information6                        = p_rec.qua_information6,
  qua_information7                        = p_rec.qua_information7,
  qua_information8                        = p_rec.qua_information8,
  qua_information9                        = p_rec.qua_information9,
  qua_information10                       = p_rec.qua_information10,
  qua_information11                       = p_rec.qua_information11,
  qua_information12                       = p_rec.qua_information12,
  qua_information13                       = p_rec.qua_information13,
  qua_information14                       = p_rec.qua_information14,
  qua_information15                       = p_rec.qua_information15,
  qua_information16                       = p_rec.qua_information16,
  qua_information17                       = p_rec.qua_information17,
  qua_information18                       = p_rec.qua_information18,
  qua_information19                       = p_rec.qua_information19,
  qua_information20                       = p_rec.qua_information20,
  professional_body_name            = p_rec.professional_body_name,
  membership_number                 = p_rec.membership_number,
  membership_category               = p_rec.membership_category,
  subscription_payment_method       = p_rec.subscription_payment_method,
  party_id                          = p_rec.party_id
  where qualification_id            = p_rec.qualification_id;
  --
  per_qua_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_qua_shd.g_api_dml := false;   -- Unset the api dml status
    per_qua_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_qua_shd.g_api_dml := false;   -- Unset the api dml status
    per_qua_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_qua_shd.g_api_dml := false;   -- Unset the api dml status
    per_qua_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_qua_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in per_qua_shd.g_rec_type) is
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
Procedure post_update(p_rec            in per_qua_shd.g_rec_type,
                      p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of Row Handler User Hook for post_update.
  --
  Begin
    per_qua_rku.after_update
      (
      p_qualification_id             => p_rec.qualification_id,
      p_business_group_id            => p_rec.business_group_id,
      p_object_version_number        => p_rec.object_version_number,
      p_person_id                    => p_rec.person_id,
      p_title                        => p_rec.title,
      p_grade_attained               => p_rec.grade_attained,
      p_status                       => p_rec.status,
      p_awarded_date                 => p_rec.awarded_date,
      p_fee                          => p_rec.fee,
      p_fee_currency                 => p_rec.fee_currency,
      p_training_completed_amount    => p_rec.training_completed_amount,
      p_reimbursement_arrangements   => p_rec.reimbursement_arrangements,
      p_training_completed_units     => p_rec.training_completed_units,
      p_total_training_amount        => p_rec.total_training_amount,
      p_start_date                   => p_rec.start_date,
      p_end_date                     => p_rec.end_date,
      p_license_number               => p_rec.license_number,
      p_expiry_date                  => p_rec.expiry_date,
      p_license_restrictions         => p_rec.license_restrictions,
      p_projected_completion_date    => p_rec.projected_completion_date,
      p_awarding_body                => p_rec.awarding_body,
      p_tuition_method               => p_rec.tuition_method,
      p_group_ranking                => p_rec.group_ranking,
      p_comments                     => p_rec.comments,
      p_qualification_type_id        => p_rec.qualification_type_id,
      p_attendance_id                => p_rec.attendance_id,
      p_attribute_category           => p_rec.attribute_category,
      p_attribute1                   => p_rec.attribute1,
      p_attribute2                   => p_rec.attribute2,
      p_attribute3                   => p_rec.attribute3,
      p_attribute4                   => p_rec.attribute4,
      p_attribute5                   => p_rec.attribute5,
      p_attribute6                   => p_rec.attribute6,
      p_attribute7                   => p_rec.attribute7,
      p_attribute8                   => p_rec.attribute8,
      p_attribute9                   => p_rec.attribute9,
      p_attribute10                  => p_rec.attribute10,
      p_attribute11                  => p_rec.attribute11,
      p_attribute12                  => p_rec.attribute12,
      p_attribute13                  => p_rec.attribute13,
      p_attribute14                  => p_rec.attribute14,
      p_attribute15                  => p_rec.attribute15,
      p_attribute16                  => p_rec.attribute16,
      p_attribute17                  => p_rec.attribute17,
      p_attribute18                  => p_rec.attribute18,
      p_attribute19                  => p_rec.attribute19,
      p_attribute20                  => p_rec.attribute20,
      p_qua_information_category           => p_rec.qua_information_category,
      p_qua_information1                   => p_rec.qua_information1,
      p_qua_information2                   => p_rec.qua_information2,
      p_qua_information3                   => p_rec.qua_information3,
      p_qua_information4                   => p_rec.qua_information4,
      p_qua_information5                   => p_rec.qua_information5,
      p_qua_information6                   => p_rec.qua_information6,
      p_qua_information7                   => p_rec.qua_information7,
      p_qua_information8                   => p_rec.qua_information8,
      p_qua_information9                   => p_rec.qua_information9,
      p_qua_information10                  => p_rec.qua_information10,
      p_qua_information11                  => p_rec.qua_information11,
      p_qua_information12                  => p_rec.qua_information12,
      p_qua_information13                  => p_rec.qua_information13,
      p_qua_information14                  => p_rec.qua_information14,
      p_qua_information15                  => p_rec.qua_information15,
      p_qua_information16                  => p_rec.qua_information16,
      p_qua_information17                  => p_rec.qua_information17,
      p_qua_information18                  => p_rec.qua_information18,
      p_qua_information19                  => p_rec.qua_information19,
      p_qua_information20                  => p_rec.qua_information20,
      p_professional_body_name       => p_rec.professional_body_name,
      p_membership_number            => p_rec.membership_number,
      p_membership_category          => p_rec.membership_category,
      p_subscription_payment_method  => p_rec.subscription_payment_method,
      p_party_id                     => p_rec.party_id,
      p_effective_date               => p_effective_date,
      p_business_group_id_o          => per_qua_shd.g_old_rec.business_group_id,
      p_person_id_o                  => per_qua_shd.g_old_rec.person_id,
      p_object_version_number_o      => per_qua_shd.g_old_rec.object_version_number,
      p_title_o                      => per_qua_shd.g_old_rec.title,
      p_grade_attained_o             => per_qua_shd.g_old_rec.grade_attained,
      p_status_o                     => per_qua_shd.g_old_rec.status,
      p_awarded_date_o               => per_qua_shd.g_old_rec.awarded_date,
      p_fee_o                        => per_qua_shd.g_old_rec.fee,
      p_fee_currency_o               => per_qua_shd.g_old_rec.fee_currency,
      p_training_completed_amount_o  => per_qua_shd.g_old_rec.training_completed_amount,
      p_reimbursement_arrangements_o => per_qua_shd.g_old_rec.reimbursement_arrangements,
      p_training_completed_units_o   => per_qua_shd.g_old_rec.training_completed_units,
      p_total_training_amount_o      => per_qua_shd.g_old_rec.total_training_amount,
      p_start_date_o                 => per_qua_shd.g_old_rec.start_date,
      p_end_date_o                   => per_qua_shd.g_old_rec.end_date,
      p_license_number_o             => per_qua_shd.g_old_rec.license_number,
      p_expiry_date_o                => per_qua_shd.g_old_rec.expiry_date,
      p_license_restrictions_o       => per_qua_shd.g_old_rec.license_restrictions,
      p_projected_completion_date_o  => per_qua_shd.g_old_rec.projected_completion_date,
      p_awarding_body_o              => per_qua_shd.g_old_rec.awarding_body,
      p_tuition_method_o             => per_qua_shd.g_old_rec.tuition_method,
      p_group_ranking_o              => per_qua_shd.g_old_rec.group_ranking,
      p_comments_o                   => per_qua_shd.g_old_rec.comments,
      p_qualification_type_id_o      => per_qua_shd.g_old_rec.qualification_type_id,
      p_attendance_id_o              => per_qua_shd.g_old_rec.attendance_id,
      p_attribute_category_o         => per_qua_shd.g_old_rec.attribute_category,
      p_attribute1_o                 => per_qua_shd.g_old_rec.attribute1,
      p_attribute2_o                 => per_qua_shd.g_old_rec.attribute2,
      p_attribute3_o                 => per_qua_shd.g_old_rec.attribute3,
      p_attribute4_o                 => per_qua_shd.g_old_rec.attribute4,
      p_attribute5_o                 => per_qua_shd.g_old_rec.attribute5,
      p_attribute6_o                 => per_qua_shd.g_old_rec.attribute6,
      p_attribute7_o                 => per_qua_shd.g_old_rec.attribute7,
      p_attribute8_o                 => per_qua_shd.g_old_rec.attribute8,
      p_attribute9_o                 => per_qua_shd.g_old_rec.attribute9,
      p_attribute10_o                => per_qua_shd.g_old_rec.attribute10,
      p_attribute11_o                => per_qua_shd.g_old_rec.attribute11,
      p_attribute12_o                => per_qua_shd.g_old_rec.attribute12,
      p_attribute13_o                => per_qua_shd.g_old_rec.attribute13,
      p_attribute14_o                => per_qua_shd.g_old_rec.attribute14,
      p_attribute15_o                => per_qua_shd.g_old_rec.attribute15,
      p_attribute16_o                => per_qua_shd.g_old_rec.attribute16,
      p_attribute17_o                => per_qua_shd.g_old_rec.attribute17,
      p_attribute18_o                => per_qua_shd.g_old_rec.attribute18,
      p_attribute19_o                => per_qua_shd.g_old_rec.attribute19,
      p_attribute20_o                => per_qua_shd.g_old_rec.attribute20,
      p_qua_information_category_o         => per_qua_shd.g_old_rec.qua_information_category,
      p_qua_information1_o                 => per_qua_shd.g_old_rec.qua_information1,
      p_qua_information2_o                 => per_qua_shd.g_old_rec.qua_information2,
      p_qua_information3_o                 => per_qua_shd.g_old_rec.qua_information3,
      p_qua_information4_o                 => per_qua_shd.g_old_rec.qua_information4,
      p_qua_information5_o                 => per_qua_shd.g_old_rec.qua_information5,
      p_qua_information6_o                 => per_qua_shd.g_old_rec.qua_information6,
      p_qua_information7_o                 => per_qua_shd.g_old_rec.qua_information7,
      p_qua_information8_o                 => per_qua_shd.g_old_rec.qua_information8,
      p_qua_information9_o                 => per_qua_shd.g_old_rec.qua_information9,
      p_qua_information10_o                => per_qua_shd.g_old_rec.qua_information10,
      p_qua_information11_o                => per_qua_shd.g_old_rec.qua_information11,
      p_qua_information12_o                => per_qua_shd.g_old_rec.qua_information12,
      p_qua_information13_o                => per_qua_shd.g_old_rec.qua_information13,
      p_qua_information14_o                => per_qua_shd.g_old_rec.qua_information14,
      p_qua_information15_o                => per_qua_shd.g_old_rec.qua_information15,
      p_qua_information16_o                => per_qua_shd.g_old_rec.qua_information16,
      p_qua_information17_o                => per_qua_shd.g_old_rec.qua_information17,
      p_qua_information18_o                => per_qua_shd.g_old_rec.qua_information18,
      p_qua_information19_o                => per_qua_shd.g_old_rec.qua_information19,
      p_qua_information20_o                => per_qua_shd.g_old_rec.qua_information20,
      p_professional_body_name_o     => per_qua_shd.g_old_rec.professional_body_name,
      p_membership_number_o          => per_qua_shd.g_old_rec.membership_number,
      p_membership_category_o        => per_qua_shd.g_old_rec.membership_category,
      p_subscription_payment_meth_o  => per_qua_shd.g_old_rec.subscription_payment_method,
      p_party_id_o                   => per_qua_shd.g_old_rec.party_id
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_QUALIFICATIONS'
        ,p_hook_type   => 'AU'
        );
  end;
  --
  -- End of Row Handler User Hook for post_update.
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
Procedure convert_defs(p_rec in out nocopy per_qua_shd.g_rec_type) is
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
    per_qua_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_qua_shd.g_old_rec.person_id;
  End If;
  If (p_rec.title = hr_api.g_varchar2) then
    p_rec.title :=
    per_qua_shd.g_old_rec.title;
  End If;
  If (p_rec.grade_attained = hr_api.g_varchar2) then
    p_rec.grade_attained :=
    per_qua_shd.g_old_rec.grade_attained;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    per_qua_shd.g_old_rec.status;
  End If;
  If (p_rec.awarded_date = hr_api.g_date) then
    p_rec.awarded_date :=
    per_qua_shd.g_old_rec.awarded_date;
  End If;
  If (p_rec.fee = hr_api.g_number) then
    p_rec.fee :=
    per_qua_shd.g_old_rec.fee;
  End If;
  If (p_rec.fee_currency = hr_api.g_varchar2) then
    p_rec.fee_currency :=
    per_qua_shd.g_old_rec.fee_currency;
  End If;
  If (p_rec.training_completed_amount = hr_api.g_number) then
    p_rec.training_completed_amount :=
    per_qua_shd.g_old_rec.training_completed_amount;
  End If;
  If (p_rec.reimbursement_arrangements = hr_api.g_varchar2) then
    p_rec.reimbursement_arrangements :=
    per_qua_shd.g_old_rec.reimbursement_arrangements;
  End If;
  If (p_rec.training_completed_units = hr_api.g_varchar2) then
    p_rec.training_completed_units :=
    per_qua_shd.g_old_rec.training_completed_units;
  End If;
  If (p_rec.total_training_amount = hr_api.g_number) then
    p_rec.total_training_amount :=
    per_qua_shd.g_old_rec.total_training_amount;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_qua_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_qua_shd.g_old_rec.end_date;
  End If;
  If (p_rec.license_number = hr_api.g_varchar2) then
    p_rec.license_number :=
    per_qua_shd.g_old_rec.license_number;
  End If;
  If (p_rec.expiry_date = hr_api.g_date) then
    p_rec.expiry_date :=
    per_qua_shd.g_old_rec.expiry_date;
  End If;
  If (p_rec.license_restrictions = hr_api.g_varchar2) then
    p_rec.license_restrictions :=
    per_qua_shd.g_old_rec.license_restrictions;
  End If;
  If (p_rec.projected_completion_date = hr_api.g_date) then
    p_rec.projected_completion_date :=
    per_qua_shd.g_old_rec.projected_completion_date;
  End If;
  If (p_rec.awarding_body = hr_api.g_varchar2) then
    p_rec.awarding_body :=
    per_qua_shd.g_old_rec.awarding_body;
  End If;
  If (p_rec.tuition_method = hr_api.g_varchar2) then
    p_rec.tuition_method :=
    per_qua_shd.g_old_rec.tuition_method;
  End If;
  If (p_rec.group_ranking = hr_api.g_varchar2) then
    p_rec.group_ranking :=
    per_qua_shd.g_old_rec.group_ranking;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_qua_shd.g_old_rec.comments;
  End If;
  If (p_rec.qualification_type_id = hr_api.g_number) then
    p_rec.qualification_type_id :=
    per_qua_shd.g_old_rec.qualification_type_id;
  End If;
  If (p_rec.attendance_id = hr_api.g_number) then
    p_rec.attendance_id :=
    per_qua_shd.g_old_rec.attendance_id;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_qua_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_qua_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_qua_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_qua_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_qua_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_qua_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_qua_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_qua_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_qua_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_qua_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_qua_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_qua_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_qua_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_qua_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_qua_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_qua_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_qua_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_qua_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_qua_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_qua_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_qua_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.qua_information_category = hr_api.g_varchar2) then
    p_rec.qua_information_category :=
    per_qua_shd.g_old_rec.qua_information_category;
  End If;
  If (p_rec.qua_information1 = hr_api.g_varchar2) then
    p_rec.qua_information1 :=
    per_qua_shd.g_old_rec.qua_information1;
  End If;
  If (p_rec.qua_information2 = hr_api.g_varchar2) then
    p_rec.qua_information2 :=
    per_qua_shd.g_old_rec.qua_information2;
  End If;
  If (p_rec.qua_information3 = hr_api.g_varchar2) then
    p_rec.qua_information3 :=
    per_qua_shd.g_old_rec.qua_information3;
  End If;
  If (p_rec.qua_information4 = hr_api.g_varchar2) then
    p_rec.qua_information4 :=
    per_qua_shd.g_old_rec.qua_information4;
  End If;
  If (p_rec.qua_information5 = hr_api.g_varchar2) then
    p_rec.qua_information5 :=
    per_qua_shd.g_old_rec.qua_information5;
  End If;
  If (p_rec.qua_information6 = hr_api.g_varchar2) then
    p_rec.qua_information6 :=
    per_qua_shd.g_old_rec.qua_information6;
  End If;
  If (p_rec.qua_information7 = hr_api.g_varchar2) then
    p_rec.qua_information7 :=
    per_qua_shd.g_old_rec.qua_information7;
  End If;
  If (p_rec.qua_information8 = hr_api.g_varchar2) then
    p_rec.qua_information8 :=
    per_qua_shd.g_old_rec.qua_information8;
  End If;
  If (p_rec.qua_information9 = hr_api.g_varchar2) then
    p_rec.qua_information9 :=
    per_qua_shd.g_old_rec.qua_information9;
  End If;
  If (p_rec.qua_information10 = hr_api.g_varchar2) then
    p_rec.qua_information10 :=
    per_qua_shd.g_old_rec.qua_information10;
  End If;
  If (p_rec.qua_information11 = hr_api.g_varchar2) then
    p_rec.qua_information11 :=
    per_qua_shd.g_old_rec.qua_information11;
  End If;
  If (p_rec.qua_information12 = hr_api.g_varchar2) then
    p_rec.qua_information12 :=
    per_qua_shd.g_old_rec.qua_information12;
  End If;
  If (p_rec.qua_information13 = hr_api.g_varchar2) then
    p_rec.qua_information13 :=
    per_qua_shd.g_old_rec.qua_information13;
  End If;
  If (p_rec.qua_information14 = hr_api.g_varchar2) then
    p_rec.qua_information14 :=
    per_qua_shd.g_old_rec.qua_information14;
  End If;
  If (p_rec.qua_information15 = hr_api.g_varchar2) then
    p_rec.qua_information15 :=
    per_qua_shd.g_old_rec.qua_information15;
  End If;
  If (p_rec.qua_information16 = hr_api.g_varchar2) then
    p_rec.qua_information16 :=
    per_qua_shd.g_old_rec.qua_information16;
  End If;
  If (p_rec.qua_information17 = hr_api.g_varchar2) then
    p_rec.qua_information17 :=
    per_qua_shd.g_old_rec.qua_information17;
  End If;
  If (p_rec.qua_information18 = hr_api.g_varchar2) then
    p_rec.qua_information18 :=
    per_qua_shd.g_old_rec.qua_information18;
  End If;
  If (p_rec.qua_information19 = hr_api.g_varchar2) then
    p_rec.qua_information19 :=
    per_qua_shd.g_old_rec.qua_information19;
  End If;
  If (p_rec.qua_information20 = hr_api.g_varchar2) then
    p_rec.qua_information20 :=
    per_qua_shd.g_old_rec.qua_information20;
  End If;
  If (p_rec.professional_body_name = hr_api.g_varchar2) then
    p_rec.professional_body_name :=
    per_qua_shd.g_old_rec.professional_body_name;
  End If;
  If (p_rec.membership_number = hr_api.g_varchar2) then
    p_rec.membership_number :=
    per_qua_shd.g_old_rec.membership_number;
  End If;
  If (p_rec.membership_category = hr_api.g_varchar2) then
    p_rec.membership_category :=
    per_qua_shd.g_old_rec.membership_category;
  End If;
  If (p_rec.subscription_payment_method = hr_api.g_varchar2) then
    p_rec.subscription_payment_method :=
    per_qua_shd.g_old_rec.subscription_payment_method;
  End If;
  If (p_rec.party_id = hr_api.g_number) then  -- HR/TCA merge
    p_rec.party_id :=
    per_qua_shd.g_old_rec.party_id;
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
  p_rec            in out nocopy per_qua_shd.g_rec_type,
  p_effective_date in     date,
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
    SAVEPOINT upd_qua;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_qua_shd.lck
	(
	p_rec.qualification_id,
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
  per_qua_bus.update_validate(p_rec,p_effective_date);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
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
  post_update(p_rec, p_effective_date);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
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
    ROLLBACK TO upd_qua;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_qualification_id             in number,
  p_business_group_id            in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_person_id                    in number           default hr_api.g_number,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_grade_attained               in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_awarded_date                 in date             default hr_api.g_date,
  p_fee                          in number           default hr_api.g_number,
  p_fee_currency                 in varchar2         default hr_api.g_varchar2,
  p_training_completed_amount    in number           default hr_api.g_number,
  p_reimbursement_arrangements   in varchar2         default hr_api.g_varchar2,
  p_training_completed_units     in varchar2         default hr_api.g_varchar2,
  p_total_training_amount        in number           default hr_api.g_number,
  p_start_date                   in date             default hr_api.g_date,
  p_end_date                     in date             default hr_api.g_date,
  p_license_number               in varchar2         default hr_api.g_varchar2,
  p_expiry_date                  in date             default hr_api.g_date,
  p_license_restrictions         in varchar2         default hr_api.g_varchar2,
  p_projected_completion_date    in date             default hr_api.g_date,
  p_awarding_body                in varchar2         default hr_api.g_varchar2,
  p_tuition_method               in varchar2         default hr_api.g_varchar2,
  p_group_ranking                in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_qualification_type_id        in number           default hr_api.g_number,
  p_attendance_id                in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
	p_qua_information_category            in varchar2 default hr_api.g_varchar2,
	p_qua_information1                    in varchar2 default hr_api.g_varchar2,
	p_qua_information2                    in varchar2 default hr_api.g_varchar2,
	p_qua_information3                    in varchar2 default hr_api.g_varchar2,
	p_qua_information4                    in varchar2 default hr_api.g_varchar2,
	p_qua_information5                    in varchar2 default hr_api.g_varchar2,
	p_qua_information6                    in varchar2 default hr_api.g_varchar2,
	p_qua_information7                    in varchar2 default hr_api.g_varchar2,
	p_qua_information8                    in varchar2 default hr_api.g_varchar2,
	p_qua_information9                    in varchar2 default hr_api.g_varchar2,
	p_qua_information10                   in varchar2 default hr_api.g_varchar2,
	p_qua_information11                   in varchar2 default hr_api.g_varchar2,
	p_qua_information12                   in varchar2 default hr_api.g_varchar2,
	p_qua_information13                   in varchar2 default hr_api.g_varchar2,
	p_qua_information14                   in varchar2 default hr_api.g_varchar2,
	p_qua_information15                   in varchar2 default hr_api.g_varchar2,
	p_qua_information16                   in varchar2 default hr_api.g_varchar2,
	p_qua_information17                   in varchar2 default hr_api.g_varchar2,
	p_qua_information18                   in varchar2 default hr_api.g_varchar2,
	p_qua_information19                   in varchar2 default hr_api.g_varchar2,
	p_qua_information20                   in varchar2 default hr_api.g_varchar2,
  p_effective_date               in date,
  p_validate                     in boolean      default false,
  p_professional_body_name       in varchar2     default hr_api.g_varchar2,
  p_membership_number            in varchar2     default hr_api.g_varchar2,
  p_membership_category          in varchar2     default hr_api.g_varchar2,
  p_subscription_payment_method  in varchar2     default hr_api.g_varchar2,
  p_party_id                     in number       default hr_api.g_number
  ) is
--
  l_rec	  per_qua_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_qua_shd.convert_args
  (
  p_qualification_id,
  p_business_group_id,
  p_object_version_number,
  p_person_id,
  p_title,
  p_grade_attained,
  p_status,
  p_awarded_date,
  p_fee,
  p_fee_currency,
  p_training_completed_amount,
  p_reimbursement_arrangements,
  p_training_completed_units,
  p_total_training_amount,
  p_start_date,
  p_end_date,
  p_license_number,
  p_expiry_date,
  p_license_restrictions,
  p_projected_completion_date,
  p_awarding_body,
  p_tuition_method,
  p_group_ranking,
  p_comments,
  p_qualification_type_id,
  p_attendance_id,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
	p_qua_information_category,
	p_qua_information1,
	p_qua_information2,
	p_qua_information3,
	p_qua_information4,
	p_qua_information5,
	p_qua_information6,
	p_qua_information7,
	p_qua_information8,
	p_qua_information9,
	p_qua_information10,
	p_qua_information11,
	p_qua_information12,
	p_qua_information13,
	p_qua_information14,
	p_qua_information15,
	p_qua_information16,
	p_qua_information17,
	p_qua_information18,
	p_qua_information19,
	p_qua_information20,
  p_professional_body_name,
  p_membership_number,
  p_membership_category,
  p_subscription_payment_method,
  p_party_id
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
end per_qua_upd;

/
