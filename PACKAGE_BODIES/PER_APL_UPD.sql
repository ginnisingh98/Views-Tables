--------------------------------------------------------
--  DDL for Package Body PER_APL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APL_UPD" as
/* $Header: peaplrhi.pkb 120.1 2005/10/25 00:31:11 risgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_apl_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy per_apl_shd.g_rec_type) is
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
  per_apl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_applications Row
  --
  update per_applications
  set
  application_id                    = p_rec.application_id,
  date_received                     = p_rec.date_received,
  comments                          = p_rec.comments,
  current_employer                  = p_rec.current_employer,
  date_end                          = p_rec.date_end,
  projected_hire_date               = p_rec.projected_hire_date,
  successful_flag                   = p_rec.successful_flag,
  termination_reason                = p_rec.termination_reason,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  appl_attribute_category           = p_rec.appl_attribute_category,
  appl_attribute1                   = p_rec.appl_attribute1,
  appl_attribute2                   = p_rec.appl_attribute2,
  appl_attribute3                   = p_rec.appl_attribute3,
  appl_attribute4                   = p_rec.appl_attribute4,
  appl_attribute5                   = p_rec.appl_attribute5,
  appl_attribute6                   = p_rec.appl_attribute6,
  appl_attribute7                   = p_rec.appl_attribute7,
  appl_attribute8                   = p_rec.appl_attribute8,
  appl_attribute9                   = p_rec.appl_attribute9,
  appl_attribute10                  = p_rec.appl_attribute10,
  appl_attribute11                  = p_rec.appl_attribute11,
  appl_attribute12                  = p_rec.appl_attribute12,
  appl_attribute13                  = p_rec.appl_attribute13,
  appl_attribute14                  = p_rec.appl_attribute14,
  appl_attribute15                  = p_rec.appl_attribute15,
  appl_attribute16                  = p_rec.appl_attribute16,
  appl_attribute17                  = p_rec.appl_attribute17,
  appl_attribute18                  = p_rec.appl_attribute18,
  appl_attribute19                  = p_rec.appl_attribute19,
  appl_attribute20                  = p_rec.appl_attribute20,
  object_version_number             = p_rec.object_version_number
  where application_id = p_rec.application_id;
  --
  per_apl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_apl_shd.g_api_dml := false;   -- Unset the api dml status
    per_apl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_apl_shd.g_api_dml := false;   -- Unset the api dml status
    per_apl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_apl_shd.g_api_dml := false;   -- Unset the api dml status
    per_apl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_apl_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in per_apl_shd.g_rec_type) is
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
Procedure post_update(p_rec             in per_apl_shd.g_rec_type
                     ,p_effective_date  in date) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  begin
    per_apl_rku.after_update
      (p_application_id               => p_rec.application_id
      ,p_date_received                => p_rec.date_received
      ,p_comments                     => p_rec.comments
      ,p_current_employer             => p_rec.current_employer
      ,p_projected_hire_date          => p_rec.projected_hire_date
      ,p_successful_flag              => p_rec.successful_flag
      ,p_termination_reason           => p_rec.termination_reason
      ,p_request_id                   => p_rec.request_id
      ,p_program_application_id       => p_rec.program_application_id
      ,p_program_id                   => p_rec.program_id
      ,p_program_update_date          => p_rec.program_update_date
      ,p_appl_attribute_category      => p_rec.appl_attribute_category
      ,p_appl_attribute1              => p_rec.appl_attribute1
      ,p_appl_attribute2              => p_rec.appl_attribute2
      ,p_appl_attribute3              => p_rec.appl_attribute3
      ,p_appl_attribute4              => p_rec.appl_attribute4
      ,p_appl_attribute5              => p_rec.appl_attribute5
      ,p_appl_attribute6              => p_rec.appl_attribute6
      ,p_appl_attribute7              => p_rec.appl_attribute7
      ,p_appl_attribute8              => p_rec.appl_attribute8
      ,p_appl_attribute9              => p_rec.appl_attribute9
      ,p_appl_attribute10             => p_rec.appl_attribute10
      ,p_appl_attribute11             => p_rec.appl_attribute11
      ,p_appl_attribute12             => p_rec.appl_attribute12
      ,p_appl_attribute13             => p_rec.appl_attribute13
      ,p_appl_attribute14             => p_rec.appl_attribute14
      ,p_appl_attribute15             => p_rec.appl_attribute15
      ,p_appl_attribute16             => p_rec.appl_attribute16
      ,p_appl_attribute17             => p_rec.appl_attribute17
      ,p_appl_attribute18             => p_rec.appl_attribute18
      ,p_appl_attribute19             => p_rec.appl_attribute19
      ,p_appl_attribute20             => p_rec.appl_attribute20
      ,p_object_version_number        => p_rec.object_version_number
      ,p_effective_date               => p_effective_date
      ,p_business_group_id_o
          => per_apl_shd.g_old_rec.business_group_id
      ,p_person_id_o
          => per_apl_shd.g_old_rec.person_id
      ,p_date_received_o
          => per_apl_shd.g_old_rec.date_received
      ,p_comments_o
          => per_apl_shd.g_old_rec.comments
      ,p_current_employer_o
          => per_apl_shd.g_old_rec.current_employer
      ,p_projected_hire_date_o
          => per_apl_shd.g_old_rec.projected_hire_date
      ,p_successful_flag_o
          => per_apl_shd.g_old_rec.successful_flag
      ,p_termination_reason_o
          => per_apl_shd.g_old_rec.termination_reason
      ,p_request_id_o
          => per_apl_shd.g_old_rec.request_id
      ,p_program_application_id_o
          => per_apl_shd.g_old_rec.program_application_id
      ,p_program_id_o
          => per_apl_shd.g_old_rec.program_id
      ,p_program_update_date_o
          => per_apl_shd.g_old_rec.program_update_date
      ,p_appl_attribute_category_o
          => per_apl_shd.g_old_rec.appl_attribute_category
      ,p_appl_attribute1_o
          => per_apl_shd.g_old_rec.appl_attribute1
      ,p_appl_attribute2_o
          => per_apl_shd.g_old_rec.appl_attribute2
      ,p_appl_attribute3_o
          => per_apl_shd.g_old_rec.appl_attribute3
      ,p_appl_attribute4_o
          => per_apl_shd.g_old_rec.appl_attribute4
      ,p_appl_attribute5_o
          => per_apl_shd.g_old_rec.appl_attribute5
      ,p_appl_attribute6_o
          => per_apl_shd.g_old_rec.appl_attribute6
      ,p_appl_attribute7_o
          => per_apl_shd.g_old_rec.appl_attribute7
      ,p_appl_attribute8_o
          => per_apl_shd.g_old_rec.appl_attribute8
      ,p_appl_attribute9_o
          => per_apl_shd.g_old_rec.appl_attribute9
      ,p_appl_attribute10_o
          => per_apl_shd.g_old_rec.appl_attribute10
      ,p_appl_attribute11_o
          => per_apl_shd.g_old_rec.appl_attribute11
      ,p_appl_attribute12_o
          => per_apl_shd.g_old_rec.appl_attribute12
      ,p_appl_attribute13_o
          => per_apl_shd.g_old_rec.appl_attribute13
      ,p_appl_attribute14_o
          => per_apl_shd.g_old_rec.appl_attribute14
      ,p_appl_attribute15_o
          => per_apl_shd.g_old_rec.appl_attribute15
      ,p_appl_attribute16_o
          => per_apl_shd.g_old_rec.appl_attribute16
      ,p_appl_attribute17_o
          => per_apl_shd.g_old_rec.appl_attribute17
      ,p_appl_attribute18_o
          => per_apl_shd.g_old_rec.appl_attribute18
      ,p_appl_attribute19_o
          => per_apl_shd.g_old_rec.appl_attribute19
      ,p_appl_attribute20_o
          => per_apl_shd.g_old_rec.appl_attribute20
      ,p_object_version_number_o
          => per_apl_shd.g_old_rec.object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_APPLICATIONS'
        ,p_hook_type   => 'AU'
        );
  end;
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
Procedure convert_defs(p_rec in out nocopy per_apl_shd.g_rec_type) is
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
    per_apl_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_apl_shd.g_old_rec.person_id;
  End If;
  If (p_rec.date_received = hr_api.g_date) then
hr_utility.set_location(l_proc,6);
    p_rec.date_received :=
    per_apl_shd.g_old_rec.date_received;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_apl_shd.g_old_rec.comments;
  End If;
  If (p_rec.current_employer = hr_api.g_varchar2) then
    p_rec.current_employer :=
    per_apl_shd.g_old_rec.current_employer;
  End If;
  If (p_rec.date_end = hr_api.g_date) then
    p_rec.date_end :=
    per_apl_shd.g_old_rec.date_end;
  End If;
  If (p_rec.projected_hire_date = hr_api.g_date) then
    p_rec.projected_hire_date :=
    per_apl_shd.g_old_rec.projected_hire_date;
  End If;
  If (p_rec.successful_flag = hr_api.g_varchar2) then
    p_rec.successful_flag :=
    per_apl_shd.g_old_rec.successful_flag;
  End If;
  If (p_rec.termination_reason = hr_api.g_varchar2) then
    p_rec.termination_reason :=
    per_apl_shd.g_old_rec.termination_reason;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_apl_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_apl_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_apl_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_apl_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.appl_attribute_category = hr_api.g_varchar2) then
    p_rec.appl_attribute_category :=
    per_apl_shd.g_old_rec.appl_attribute_category;
  End If;
  If (p_rec.appl_attribute1 = hr_api.g_varchar2) then
    p_rec.appl_attribute1 :=
    per_apl_shd.g_old_rec.appl_attribute1;
  End If;
  If (p_rec.appl_attribute2 = hr_api.g_varchar2) then
    p_rec.appl_attribute2 :=
    per_apl_shd.g_old_rec.appl_attribute2;
  End If;
  If (p_rec.appl_attribute3 = hr_api.g_varchar2) then
    p_rec.appl_attribute3 :=
    per_apl_shd.g_old_rec.appl_attribute3;
  End If;
  If (p_rec.appl_attribute4 = hr_api.g_varchar2) then
    p_rec.appl_attribute4 :=
    per_apl_shd.g_old_rec.appl_attribute4;
  End If;
  If (p_rec.appl_attribute5 = hr_api.g_varchar2) then
    p_rec.appl_attribute5 :=
    per_apl_shd.g_old_rec.appl_attribute5;
  End If;
  If (p_rec.appl_attribute6 = hr_api.g_varchar2) then
    p_rec.appl_attribute6 :=
    per_apl_shd.g_old_rec.appl_attribute6;
  End If;
  If (p_rec.appl_attribute7 = hr_api.g_varchar2) then
    p_rec.appl_attribute7 :=
    per_apl_shd.g_old_rec.appl_attribute7;
  End If;
  If (p_rec.appl_attribute8 = hr_api.g_varchar2) then
    p_rec.appl_attribute8 :=
    per_apl_shd.g_old_rec.appl_attribute8;
  End If;
  If (p_rec.appl_attribute9 = hr_api.g_varchar2) then
    p_rec.appl_attribute9 :=
    per_apl_shd.g_old_rec.appl_attribute9;
  End If;
  If (p_rec.appl_attribute10 = hr_api.g_varchar2) then
    p_rec.appl_attribute10 :=
    per_apl_shd.g_old_rec.appl_attribute10;
  End If;
  If (p_rec.appl_attribute11 = hr_api.g_varchar2) then
    p_rec.appl_attribute11 :=
    per_apl_shd.g_old_rec.appl_attribute11;
  End If;
  If (p_rec.appl_attribute12 = hr_api.g_varchar2) then
    p_rec.appl_attribute12 :=
    per_apl_shd.g_old_rec.appl_attribute12;
  End If;
  If (p_rec.appl_attribute13 = hr_api.g_varchar2) then
    p_rec.appl_attribute13 :=
    per_apl_shd.g_old_rec.appl_attribute13;
  End If;
  If (p_rec.appl_attribute14 = hr_api.g_varchar2) then
    p_rec.appl_attribute14 :=
    per_apl_shd.g_old_rec.appl_attribute14;
  End If;
  If (p_rec.appl_attribute15 = hr_api.g_varchar2) then
    p_rec.appl_attribute15 :=
    per_apl_shd.g_old_rec.appl_attribute15;
  End If;
  If (p_rec.appl_attribute16 = hr_api.g_varchar2) then
    p_rec.appl_attribute16 :=
    per_apl_shd.g_old_rec.appl_attribute16;
  End If;
  If (p_rec.appl_attribute17 = hr_api.g_varchar2) then
    p_rec.appl_attribute17 :=
    per_apl_shd.g_old_rec.appl_attribute17;
  End If;
  If (p_rec.appl_attribute18 = hr_api.g_varchar2) then
    p_rec.appl_attribute18 :=
    per_apl_shd.g_old_rec.appl_attribute18;
  End If;
  If (p_rec.appl_attribute19 = hr_api.g_varchar2) then
    p_rec.appl_attribute19 :=
    per_apl_shd.g_old_rec.appl_attribute19;
  End If;
  If (p_rec.appl_attribute20 = hr_api.g_varchar2) then
    p_rec.appl_attribute20 :=
    per_apl_shd.g_old_rec.appl_attribute20;
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
  p_rec            in out nocopy per_apl_shd.g_rec_type,
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
    SAVEPOINT upd_per_apl;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_apl_shd.lck
	(
	p_rec.application_id,
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
  per_apl_bus.update_validate(p_rec
			     ,p_effective_date);
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
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
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
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
    ROLLBACK TO upd_per_apl;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_application_id              in number,
  p_date_received               in date             default hr_api.g_date,
  p_comments                    in varchar2         default hr_api.g_varchar2,
  p_current_employer            in varchar2         default hr_api.g_varchar2,
  p_date_end                    in date             default hr_api.g_date,
  p_projected_hire_date         in date             default hr_api.g_date,
  p_successful_flag             in varchar2         default hr_api.g_varchar2,
  p_termination_reason          in varchar2         default hr_api.g_varchar2,
  p_request_id                  in number           default hr_api.g_number,
  p_program_application_id      in number           default hr_api.g_number,
  p_program_id                  in number           default hr_api.g_number,
  p_program_update_date         in date             default hr_api.g_date,
  p_appl_attribute_category     in varchar2         default hr_api.g_varchar2,
  p_appl_attribute1             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute2             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute3             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute4             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute5             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute6             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute7             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute8             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute9             in varchar2         default hr_api.g_varchar2,
  p_appl_attribute10            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute11            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute12            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute13            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute14            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute15            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute16            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute17            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute18            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute19            in varchar2         default hr_api.g_varchar2,
  p_appl_attribute20            in varchar2         default hr_api.g_varchar2,
  p_object_version_number       in out nocopy number,
  p_effective_date              in date,
  p_validate                    in boolean      default false
  ) is
--
  l_rec	  per_apl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_apl_shd.convert_args
  (
  p_application_id,
  hr_api.g_number,
  hr_api.g_number,
  p_date_received,
  p_comments,
  p_current_employer,
  p_date_end,
  p_projected_hire_date,
  p_successful_flag,
  p_termination_reason,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_appl_attribute_category,
  p_appl_attribute1,
  p_appl_attribute2,
  p_appl_attribute3,
  p_appl_attribute4,
  p_appl_attribute5,
  p_appl_attribute6,
  p_appl_attribute7,
  p_appl_attribute8,
  p_appl_attribute9,
  p_appl_attribute10,
  p_appl_attribute11,
  p_appl_attribute12,
  p_appl_attribute13,
  p_appl_attribute14,
  p_appl_attribute15,
  p_appl_attribute16,
  p_appl_attribute17,
  p_appl_attribute18,
  p_appl_attribute19,
  p_appl_attribute20,
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
end per_apl_upd;

/
