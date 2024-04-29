--------------------------------------------------------
--  DDL for Package Body SSP_MAT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_MAT_UPD" as
/* $Header: spmatrhi.pkb 120.5.12010000.3 2008/08/13 13:27:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_mat_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ssp_mat_shd.g_rec_type) is
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
  ssp_mat_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ssp_maternities Row
  --
  update ssp_maternities
  set
  due_date                          = p_rec.due_date,
  start_date_maternity_allowance    = p_rec.start_date_maternity_allowance,
  notification_of_birth_date        = p_rec.notification_of_birth_date,
  unfit_for_scheduled_return        = p_rec.unfit_for_scheduled_return,
  stated_return_date                = p_rec.stated_return_date,
  intend_to_return_flag             = p_rec.intend_to_return_flag,
  start_date_with_new_employer      = p_rec.start_date_with_new_employer,
  smp_must_be_paid_by_date          = p_rec.smp_must_be_paid_by_date,
  pay_smp_as_lump_sum               = p_rec.pay_smp_as_lump_sum,
  live_birth_flag                   = p_rec.live_birth_flag,
  actual_birth_date                 = p_rec.actual_birth_date,
  mpp_start_date                    = p_rec.mpp_start_date,
  object_version_number             = p_rec.object_version_number,
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
  LEAVE_TYPE                        = p_rec.LEAVE_TYPE,
  MATCHING_DATE                     = p_rec.MATCHING_DATE,
  PLACEMENT_DATE                    = p_rec.PLACEMENT_DATE ,
  DISRUPTED_PLACEMENT_DATE          = p_rec.DISRUPTED_PLACEMENT_DATE,
  mat_information_category          = p_rec.mat_information_category,
  mat_information1                  = p_rec.mat_information1,
  mat_information2                  = p_rec.mat_information2,
  mat_information3                  = p_rec.mat_information3,
  mat_information4                  = p_rec.mat_information4,
  mat_information5                  = p_rec.mat_information5,
  mat_information6                  = p_rec.mat_information6,
  mat_information7                  = p_rec.mat_information7,
  mat_information8                  = p_rec.mat_information8,
  mat_information9                  = p_rec.mat_information9,
  mat_information10                 = p_rec.mat_information10,
  mat_information11                 = p_rec.mat_information11,
  mat_information12                 = p_rec.mat_information12,
  mat_information13                 = p_rec.mat_information13,
  mat_information14                 = p_rec.mat_information14,
  mat_information15                 = p_rec.mat_information15,
  mat_information16                 = p_rec.mat_information16,
  mat_information17                 = p_rec.mat_information17,
  mat_information18                 = p_rec.mat_information18,
  mat_information19                 = p_rec.mat_information19,
  mat_information20                 = p_rec.mat_information20,
  mat_information21                 = p_rec.mat_information21,
  mat_information22                 = p_rec.mat_information22,
  mat_information23                 = p_rec.mat_information23,
  mat_information24                 = p_rec.mat_information24,
  mat_information25                 = p_rec.mat_information25,
  mat_information26                 = p_rec.mat_information26,
  mat_information27                 = p_rec.mat_information27,
  mat_information28                 = p_rec.mat_information28,
  mat_information29                 = p_rec.mat_information29,
  mat_information30                 = p_rec.mat_information30
  where maternity_id = p_rec.maternity_id;
  --
  ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_mat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_mat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_mat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ssp_mat_shd.g_rec_type) is
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
Procedure post_update(p_rec in ssp_mat_shd.g_rec_type) is
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
Procedure convert_defs(p_rec in out nocopy ssp_mat_shd.g_rec_type) is
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
  If (p_rec.due_date = hr_api.g_date) then
    p_rec.due_date :=
    ssp_mat_shd.g_old_rec.due_date;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ssp_mat_shd.g_old_rec.person_id;
  End If;
  If (p_rec.start_date_maternity_allowance = hr_api.g_date) then
    p_rec.start_date_maternity_allowance :=
    ssp_mat_shd.g_old_rec.start_date_maternity_allowance;
  End If;
  If (p_rec.notification_of_birth_date = hr_api.g_date) then
    p_rec.notification_of_birth_date :=
    ssp_mat_shd.g_old_rec.notification_of_birth_date;
  End If;
  If (p_rec.unfit_for_scheduled_return = hr_api.g_varchar2) then
    p_rec.unfit_for_scheduled_return :=
    ssp_mat_shd.g_old_rec.unfit_for_scheduled_return;
  End If;
  If (p_rec.stated_return_date = hr_api.g_date) then
    p_rec.stated_return_date :=
    ssp_mat_shd.g_old_rec.stated_return_date;
  End If;
  If (p_rec.intend_to_return_flag = hr_api.g_varchar2) then
    p_rec.intend_to_return_flag :=
    ssp_mat_shd.g_old_rec.intend_to_return_flag;
  End If;
  If (p_rec.start_date_with_new_employer = hr_api.g_date) then
    p_rec.start_date_with_new_employer :=
    ssp_mat_shd.g_old_rec.start_date_with_new_employer;
  End If;
  If (p_rec.smp_must_be_paid_by_date = hr_api.g_date) then
    p_rec.smp_must_be_paid_by_date :=
    ssp_mat_shd.g_old_rec.smp_must_be_paid_by_date;
  End If;
  If (p_rec.pay_smp_as_lump_sum = hr_api.g_varchar2) then
    p_rec.pay_smp_as_lump_sum :=
    ssp_mat_shd.g_old_rec.pay_smp_as_lump_sum;
  End If;
  If (p_rec.live_birth_flag = hr_api.g_varchar2) then
    p_rec.live_birth_flag :=
    ssp_mat_shd.g_old_rec.live_birth_flag;
  End If;
  If (p_rec.actual_birth_date = hr_api.g_date) then
    p_rec.actual_birth_date :=
    ssp_mat_shd.g_old_rec.actual_birth_date;
  End If;
  If (p_rec.mpp_start_date = hr_api.g_date) then
    p_rec.mpp_start_date :=
    ssp_mat_shd.g_old_rec.mpp_start_date;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    ssp_mat_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    ssp_mat_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    ssp_mat_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    ssp_mat_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    ssp_mat_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    ssp_mat_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    ssp_mat_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    ssp_mat_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    ssp_mat_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    ssp_mat_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    ssp_mat_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    ssp_mat_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    ssp_mat_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    ssp_mat_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    ssp_mat_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    ssp_mat_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    ssp_mat_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    ssp_mat_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    ssp_mat_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    ssp_mat_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    ssp_mat_shd.g_old_rec.attribute20;
  End If;

  If (p_rec.LEAVE_TYPE = hr_api.g_varchar2) then
    p_rec.LEAVE_TYPE :=
    ssp_mat_shd.g_old_rec.LEAVE_TYPE;
  End If;

  If (p_rec.MATCHING_DATE = hr_api.g_date) then
    p_rec.MATCHING_DATE :=
    ssp_mat_shd.g_old_rec.MATCHING_DATE;
  End If;

  If (p_rec.PLACEMENT_DATE = hr_api.g_date) then
    p_rec.PLACEMENT_DATE :=
    ssp_mat_shd.g_old_rec.PLACEMENT_DATE;
  End If;

  If (p_rec.DISRUPTED_PLACEMENT_DATE = hr_api.g_date) then
    p_rec.DISRUPTED_PLACEMENT_DATE :=
    ssp_mat_shd.g_old_rec.DISRUPTED_PLACEMENT_DATE;
  End If;

  If (p_rec.mat_information_category = hr_api.g_varchar2) then
    p_rec.mat_information_category :=
    ssp_mat_shd.g_old_rec.mat_information_category;
  End If;
  If (p_rec.mat_information1 = hr_api.g_varchar2) then
    p_rec.mat_information1 :=
    ssp_mat_shd.g_old_rec.mat_information1;
  End If;
  If (p_rec.mat_information1 = hr_api.g_varchar2) then
    p_rec.mat_information1 :=
    ssp_mat_shd.g_old_rec.mat_information1;
  End If;
  If (p_rec.mat_information2 = hr_api.g_varchar2) then
    p_rec.mat_information2 :=
    ssp_mat_shd.g_old_rec.mat_information2;
  End If;
  If (p_rec.mat_information3 = hr_api.g_varchar2) then
    p_rec.mat_information3 :=
    ssp_mat_shd.g_old_rec.mat_information3;
  End If;
  If (p_rec.mat_information4 = hr_api.g_varchar2) then
    p_rec.mat_information4 :=
    ssp_mat_shd.g_old_rec.mat_information4;
  End If;
  If (p_rec.mat_information5 = hr_api.g_varchar2) then
    p_rec.mat_information5 :=
    ssp_mat_shd.g_old_rec.mat_information5;
  End If;
  If (p_rec.mat_information6 = hr_api.g_varchar2) then
    p_rec.mat_information6 :=
    ssp_mat_shd.g_old_rec.mat_information6;
  End If;
  If (p_rec.mat_information7 = hr_api.g_varchar2) then
    p_rec.mat_information7 :=
    ssp_mat_shd.g_old_rec.mat_information7;
  End If;
  If (p_rec.mat_information8 = hr_api.g_varchar2) then
    p_rec.mat_information8 :=
    ssp_mat_shd.g_old_rec.mat_information8;
  End If;
  If (p_rec.mat_information9 = hr_api.g_varchar2) then
    p_rec.mat_information9 :=
    ssp_mat_shd.g_old_rec.mat_information9;
  End If;
  If (p_rec.mat_information10 = hr_api.g_varchar2) then
    p_rec.mat_information10 :=
    ssp_mat_shd.g_old_rec.mat_information10;
  End If;
  If (p_rec.mat_information11 = hr_api.g_varchar2) then
    p_rec.mat_information11 :=
    ssp_mat_shd.g_old_rec.mat_information11;
  End If;
  If (p_rec.mat_information12 = hr_api.g_varchar2) then
    p_rec.mat_information12 :=
    ssp_mat_shd.g_old_rec.mat_information12;
  End If;
  If (p_rec.mat_information13 = hr_api.g_varchar2) then
    p_rec.mat_information13 :=
    ssp_mat_shd.g_old_rec.mat_information13;
  End If;
  If (p_rec.mat_information14 = hr_api.g_varchar2) then
    p_rec.mat_information14 :=
    ssp_mat_shd.g_old_rec.mat_information14;
  End If;
  If (p_rec.mat_information15 = hr_api.g_varchar2) then
    p_rec.mat_information15 :=
    ssp_mat_shd.g_old_rec.mat_information15;
  End If;
  If (p_rec.mat_information16 = hr_api.g_varchar2) then
    p_rec.mat_information16 :=
    ssp_mat_shd.g_old_rec.mat_information16;
  End If;
  If (p_rec.mat_information17 = hr_api.g_varchar2) then
    p_rec.mat_information17 :=
    ssp_mat_shd.g_old_rec.mat_information17;
  End If;
  If (p_rec.mat_information18 = hr_api.g_varchar2) then
    p_rec.mat_information18 :=
    ssp_mat_shd.g_old_rec.mat_information18;
  End If;
  If (p_rec.mat_information19 = hr_api.g_varchar2) then
    p_rec.mat_information19 :=
    ssp_mat_shd.g_old_rec.mat_information19;
  End If;
  If (p_rec.mat_information20 = hr_api.g_varchar2) then
    p_rec.mat_information20 :=
    ssp_mat_shd.g_old_rec.mat_information20;
  End If;
  If (p_rec.mat_information21 = hr_api.g_varchar2) then
    p_rec.mat_information21 :=
    ssp_mat_shd.g_old_rec.mat_information21;
  End If;
  If (p_rec.mat_information22 = hr_api.g_varchar2) then
    p_rec.mat_information12 :=
    ssp_mat_shd.g_old_rec.mat_information22;
  End If;
  If (p_rec.mat_information23 = hr_api.g_varchar2) then
    p_rec.mat_information23 :=
    ssp_mat_shd.g_old_rec.mat_information23;
  End If;
  If (p_rec.mat_information24 = hr_api.g_varchar2) then
    p_rec.mat_information24 :=
    ssp_mat_shd.g_old_rec.mat_information24;
  End If;
  If (p_rec.mat_information25 = hr_api.g_varchar2) then
    p_rec.mat_information25 :=
    ssp_mat_shd.g_old_rec.mat_information25;
  End If;
  If (p_rec.mat_information26 = hr_api.g_varchar2) then
    p_rec.mat_information26 :=
    ssp_mat_shd.g_old_rec.mat_information26;
  End If;
  If (p_rec.mat_information27 = hr_api.g_varchar2) then
    p_rec.mat_information27 :=
    ssp_mat_shd.g_old_rec.mat_information27;
  End If;
  If (p_rec.mat_information28 = hr_api.g_varchar2) then
    p_rec.mat_information28 :=
    ssp_mat_shd.g_old_rec.mat_information28;
  End If;
  If (p_rec.mat_information29 = hr_api.g_varchar2) then
    p_rec.mat_information29 :=
    ssp_mat_shd.g_old_rec.mat_information29;
  End If;
  If (p_rec.mat_information30 = hr_api.g_varchar2) then
    p_rec.mat_information30 :=
    ssp_mat_shd.g_old_rec.mat_information30;
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
  p_rec        in out nocopy ssp_mat_shd.g_rec_type,
  p_validate   in     boolean default false
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
    SAVEPOINT upd_ssp_mat;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ssp_mat_shd.lck
	(
	p_rec.maternity_id,
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
  ssp_mat_bus.update_validate(p_rec);
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
    ROLLBACK TO upd_ssp_mat;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_maternity_id                 in number,
  p_object_version_number        in out nocopy number,
  p_due_date                     in date             default hr_api.g_date,
  p_start_date_SMA 		 in date             default hr_api.g_date,
  p_notification_of_birth_date   in date             default hr_api.g_date,
  p_unfit_for_scheduled_return   in varchar2         default hr_api.g_varchar2,
  p_stated_return_date           in date             default hr_api.g_date,
  p_intend_to_return_flag        in varchar2         default hr_api.g_varchar2,
  p_start_date_with_new_employer in date             default hr_api.g_date,
  p_smp_must_be_paid_by_date     in date             default hr_api.g_date,
  p_pay_smp_as_lump_sum          in varchar2         default hr_api.g_varchar2,
  p_live_birth_flag              in varchar2         default hr_api.g_varchar2,
  p_actual_birth_date            in date             default hr_api.g_date,
  p_mpp_start_date               in date             default hr_api.g_date,
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
  p_LEAVE_TYPE                   in VARCHAR2         default 'MA',
  p_MATCHING_DATE                in DATE             default hr_api.g_date,
  p_PLACEMENT_DATE               in DATE             default hr_api.g_date,
  p_DISRUPTED_PLACEMENT_DATE     in DATE             default hr_api.g_date,
  p_validate                     in boolean          default false,
  p_mat_information_category     in varchar2         default hr_api.g_varchar2,
  p_mat_information1             in varchar2         default hr_api.g_varchar2,
  p_mat_information2             in varchar2         default hr_api.g_varchar2,
  p_mat_information3             in varchar2         default hr_api.g_varchar2,
  p_mat_information4             in varchar2         default hr_api.g_varchar2,
  p_mat_information5             in varchar2         default hr_api.g_varchar2,
  p_mat_information6             in varchar2         default hr_api.g_varchar2,
  p_mat_information7             in varchar2         default hr_api.g_varchar2,
  p_mat_information8             in varchar2         default hr_api.g_varchar2,
  p_mat_information9             in varchar2         default hr_api.g_varchar2,
  p_mat_information10            in varchar2         default hr_api.g_varchar2,
  p_mat_information11            in varchar2         default hr_api.g_varchar2,
  p_mat_information12            in varchar2         default hr_api.g_varchar2,
  p_mat_information13            in varchar2         default hr_api.g_varchar2,
  p_mat_information14            in varchar2         default hr_api.g_varchar2,
  p_mat_information15            in varchar2         default hr_api.g_varchar2,
  p_mat_information16            in varchar2         default hr_api.g_varchar2,
  p_mat_information17            in varchar2         default hr_api.g_varchar2,
  p_mat_information18            in varchar2         default hr_api.g_varchar2,
  p_mat_information19            in varchar2         default hr_api.g_varchar2,
  p_mat_information20            in varchar2         default hr_api.g_varchar2,
  p_mat_information21            in varchar2         default hr_api.g_varchar2,
  p_mat_information22            in varchar2         default hr_api.g_varchar2,
  p_mat_information23            in varchar2         default hr_api.g_varchar2,
  p_mat_information24            in varchar2         default hr_api.g_varchar2,
  p_mat_information25            in varchar2         default hr_api.g_varchar2,
  p_mat_information26            in varchar2         default hr_api.g_varchar2,
  p_mat_information27            in varchar2         default hr_api.g_varchar2,
  p_mat_information28            in varchar2         default hr_api.g_varchar2,
  p_mat_information29            in varchar2         default hr_api.g_varchar2,
  p_mat_information30            in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  ssp_mat_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ssp_mat_shd.convert_args
  (
  p_maternity_id,
  p_due_date,
  hr_api.g_number,
  p_start_date_SMA,
  p_notification_of_birth_date,
  p_unfit_for_scheduled_return,
  p_stated_return_date,
  p_intend_to_return_flag,
  p_start_date_with_new_employer,
  p_smp_must_be_paid_by_date,
  p_pay_smp_as_lump_sum,
  p_live_birth_flag,
  p_actual_birth_date,
  p_mpp_start_date,
  p_object_version_number,
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
  p_LEAVE_TYPE ,
  p_MATCHING_DATE,
  p_PLACEMENT_DATE ,
  p_DISRUPTED_PLACEMENT_DATE,
  p_mat_information_category,
  p_mat_information1,
  p_mat_information2,
  p_mat_information3,
  p_mat_information4,
  p_mat_information5,
  p_mat_information6,
  p_mat_information7,
  p_mat_information8,
  p_mat_information9,
  p_mat_information10,
  p_mat_information11,
  p_mat_information12,
  p_mat_information13,
  p_mat_information14,
  p_mat_information15,
  p_mat_information16,
  p_mat_information17,
  p_mat_information18,
  p_mat_information19,
  p_mat_information20,
  p_mat_information21,
  p_mat_information22,
  p_mat_information23,
  p_mat_information24,
  p_mat_information25,
  p_mat_information26,
  p_mat_information27,
  p_mat_information28,
  p_mat_information29,
  p_mat_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ssp_mat_upd;

/
