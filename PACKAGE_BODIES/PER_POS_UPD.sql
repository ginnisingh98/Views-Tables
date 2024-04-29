--------------------------------------------------------
--  DDL for Package Body PER_POS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_UPD" as
/* $Header: peposrhi.pkb 120.0.12010000.1 2008/07/28 05:23:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pos_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
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
-- In Arguments:
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
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy per_pos_shd.g_rec_type) is
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
  per_pos_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- PMFLETCH Now using per_all_positions
  --
  -- Update the per_all_positions Row
  --
  update per_all_positions
  set
  position_id                       = p_rec.position_id,
  successor_position_id             = p_rec.successor_position_id,
  relief_position_id                = p_rec.relief_position_id,
  location_id                       = p_rec.location_id,
  position_definition_id            = p_rec.position_definition_id,
  date_effective                    = p_rec.date_effective,
  comments                          = p_rec.comments,
  date_end                          = p_rec.date_end,
  frequency                         = p_rec.frequency,
  name                              = p_rec.name,
  probation_period                  = p_rec.probation_period,
  probation_period_units            = p_rec.probation_period_units,
  replacement_required_flag         = p_rec.replacement_required_flag,
  time_normal_finish                = p_rec.time_normal_finish,
  time_normal_start                 = p_rec.time_normal_start,
  status                            = p_rec.status,
  working_hours                     = p_rec.working_hours,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
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
  object_version_number             = p_rec.object_version_number
  where position_id = p_rec.position_id;
  --
  per_pos_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_pos_shd.g_api_dml := false;   -- Unset the api dml status
    per_pos_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_pos_shd.g_api_dml := false;   -- Unset the api dml status
    per_pos_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_pos_shd.g_api_dml := false;   -- Unset the api dml status
    per_pos_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_pos_shd.g_api_dml := false;   -- Unset the api dml status
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
-- In Arguments:
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
Procedure pre_update(p_rec in per_pos_shd.g_rec_type) is
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
-- In Arguments:
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
Procedure post_update(p_rec in per_pos_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  begin
    per_pos_rku.after_update
      (p_position_id                  => p_rec.position_id
      ,p_successor_position_id        => p_rec.successor_position_id
      ,p_relief_position_id           => p_rec.relief_position_id
      ,p_location_id                  => p_rec.location_id
      ,p_position_definition_id       => p_rec.position_definition_id
      ,p_date_effective               => p_rec.date_effective
      ,p_comments                     => p_rec.comments
      ,p_date_end                     => p_rec.date_end
      ,p_frequency                    => p_rec.frequency
      ,p_name                         => p_rec.name
      ,p_probation_period             => p_rec.probation_period
      ,p_probation_period_units       => p_rec.probation_period_units
      ,p_replacement_required_flag    => p_rec.replacement_required_flag
      ,p_time_normal_finish           => p_rec.time_normal_finish
      ,p_time_normal_start            => p_rec.time_normal_start
      ,p_status                       => p_rec.status
      ,p_working_hours                => p_rec.working_hours
      ,p_request_id                   => p_rec.request_id
      ,p_program_application_id       => p_rec.program_application_id
      ,p_program_id                   => p_rec.program_id
      ,p_program_update_date          => p_rec.program_update_date
      ,p_attribute_category           => p_rec.attribute_category
      ,p_attribute1                   => p_rec.attribute1
      ,p_attribute2                   => p_rec.attribute2
      ,p_attribute3                   => p_rec.attribute3
      ,p_attribute4                   => p_rec.attribute4
      ,p_attribute5                   => p_rec.attribute5
      ,p_attribute6                   => p_rec.attribute6
      ,p_attribute7                   => p_rec.attribute7
      ,p_attribute8                   => p_rec.attribute8
      ,p_attribute9                   => p_rec.attribute9
      ,p_attribute10                  => p_rec.attribute10
      ,p_attribute11                  => p_rec.attribute11
      ,p_attribute12                  => p_rec.attribute12
      ,p_attribute13                  => p_rec.attribute13
      ,p_attribute14                  => p_rec.attribute14
      ,p_attribute15                  => p_rec.attribute15
      ,p_attribute16                  => p_rec.attribute16
      ,p_attribute17                  => p_rec.attribute17
      ,p_attribute18                  => p_rec.attribute18
      ,p_attribute19                  => p_rec.attribute19
      ,p_attribute20                  => p_rec.attribute20
      ,p_object_version_number        => p_rec.object_version_number
      ,p_business_group_id_o
          => per_pos_shd.g_old_rec.business_group_id
      ,p_job_id_o
          => per_pos_shd.g_old_rec.job_id
      ,p_organization_id_o
          => per_pos_shd.g_old_rec.organization_id
      ,p_successor_position_id_o
          => per_pos_shd.g_old_rec.successor_position_id
      ,p_relief_position_id_o
          => per_pos_shd.g_old_rec.relief_position_id
      ,p_location_id_o
          => per_pos_shd.g_old_rec.location_id
      ,p_position_definition_id_o
          => per_pos_shd.g_old_rec.position_definition_id
      ,p_date_effective_o
          => per_pos_shd.g_old_rec.date_effective
      ,p_comments_o
          => per_pos_shd.g_old_rec.comments
      ,p_date_end_o
          => per_pos_shd.g_old_rec.date_end
      ,p_frequency_o
          => per_pos_shd.g_old_rec.frequency
      ,p_name_o
          => per_pos_shd.g_old_rec.name
      ,p_probation_period_o
          => per_pos_shd.g_old_rec.probation_period
      ,p_probation_period_units_o
          => per_pos_shd.g_old_rec.probation_period_units
      ,p_replacement_required_flag_o
          => per_pos_shd.g_old_rec.replacement_required_flag
      ,p_time_normal_finish_o
          => per_pos_shd.g_old_rec.time_normal_finish
      ,p_time_normal_start_o
          => per_pos_shd.g_old_rec.time_normal_start
      ,p_status_o
          => per_pos_shd.g_old_rec.status
      ,p_working_hours_o
          => per_pos_shd.g_old_rec.working_hours
      ,p_request_id_o
          => per_pos_shd.g_old_rec.request_id
      ,p_program_application_id_o
          => per_pos_shd.g_old_rec.program_application_id
      ,p_program_id_o
          => per_pos_shd.g_old_rec.program_id
      ,p_program_update_date_o
          => per_pos_shd.g_old_rec.program_update_date
      ,p_attribute_category_o
          => per_pos_shd.g_old_rec.attribute_category
      ,p_attribute1_o
          => per_pos_shd.g_old_rec.attribute1
      ,p_attribute2_o
          => per_pos_shd.g_old_rec.attribute2
      ,p_attribute3_o
          => per_pos_shd.g_old_rec.attribute3
      ,p_attribute4_o
          => per_pos_shd.g_old_rec.attribute4
      ,p_attribute5_o
          => per_pos_shd.g_old_rec.attribute5
      ,p_attribute6_o
          => per_pos_shd.g_old_rec.attribute6
      ,p_attribute7_o
          => per_pos_shd.g_old_rec.attribute7
      ,p_attribute8_o
          => per_pos_shd.g_old_rec.attribute8
      ,p_attribute9_o
          => per_pos_shd.g_old_rec.attribute9
      ,p_attribute10_o
          => per_pos_shd.g_old_rec.attribute10
      ,p_attribute11_o
          => per_pos_shd.g_old_rec.attribute11
      ,p_attribute12_o
          => per_pos_shd.g_old_rec.attribute12
      ,p_attribute13_o
          => per_pos_shd.g_old_rec.attribute13
      ,p_attribute14_o
          => per_pos_shd.g_old_rec.attribute14
      ,p_attribute15_o
          => per_pos_shd.g_old_rec.attribute15
      ,p_attribute16_o
          => per_pos_shd.g_old_rec.attribute16
      ,p_attribute17_o
          => per_pos_shd.g_old_rec.attribute17
      ,p_attribute18_o
          => per_pos_shd.g_old_rec.attribute18
      ,p_attribute19_o
          => per_pos_shd.g_old_rec.attribute19
      ,p_attribute20_o
          => per_pos_shd.g_old_rec.attribute20
      ,p_object_version_number_o
          => per_pos_shd.g_old_rec.object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_POSITIONS'
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
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
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
Procedure convert_defs(p_rec in out nocopy per_pos_shd.g_rec_type) is
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
    per_pos_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    per_pos_shd.g_old_rec.job_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    per_pos_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.successor_position_id = hr_api.g_number) then
    p_rec.successor_position_id :=
    per_pos_shd.g_old_rec.successor_position_id;
  End If;
  If (p_rec.relief_position_id = hr_api.g_number) then
    p_rec.relief_position_id :=
    per_pos_shd.g_old_rec.relief_position_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    per_pos_shd.g_old_rec.location_id;
  End If;
  If (p_rec.position_definition_id = hr_api.g_number) then
    p_rec.position_definition_id :=
    per_pos_shd.g_old_rec.position_definition_id;
  End If;
  If (p_rec.date_effective = hr_api.g_date) then
    p_rec.date_effective :=
    per_pos_shd.g_old_rec.date_effective;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_pos_shd.g_old_rec.comments;
  End If;
  If (p_rec.date_end = hr_api.g_date) then
    p_rec.date_end :=
    per_pos_shd.g_old_rec.date_end;
  End If;
  If (p_rec.frequency = hr_api.g_varchar2) then
    p_rec.frequency :=
    per_pos_shd.g_old_rec.frequency;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    per_pos_shd.g_old_rec.name;
  End If;
  If (p_rec.probation_period = hr_api.g_number) then
    p_rec.probation_period :=
    per_pos_shd.g_old_rec.probation_period;
  End If;
  If (p_rec.probation_period_units = hr_api.g_varchar2) then
    p_rec.probation_period_units :=
    per_pos_shd.g_old_rec.probation_period_units;
  End If;
  If (p_rec.replacement_required_flag = hr_api.g_varchar2) then
    p_rec.replacement_required_flag :=
    per_pos_shd.g_old_rec.replacement_required_flag;
  End If;
  If (p_rec.time_normal_finish = hr_api.g_varchar2) then
    p_rec.time_normal_finish :=
    per_pos_shd.g_old_rec.time_normal_finish;
  End If;
  If (p_rec.time_normal_start = hr_api.g_varchar2) then
    p_rec.time_normal_start :=
    per_pos_shd.g_old_rec.time_normal_start;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    per_pos_shd.g_old_rec.status;
  End If;
  If (p_rec.working_hours = hr_api.g_number) then
    p_rec.working_hours :=
    per_pos_shd.g_old_rec.working_hours;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_pos_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_pos_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_pos_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_pos_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_pos_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_pos_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_pos_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_pos_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_pos_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_pos_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_pos_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_pos_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_pos_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_pos_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_pos_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_pos_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_pos_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_pos_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_pos_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_pos_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_pos_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_pos_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_pos_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_pos_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_pos_shd.g_old_rec.attribute20;
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
  p_rec        in out nocopy per_pos_shd.g_rec_type,
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
    SAVEPOINT upd_per_pos;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  --
  per_pos_shd.lck
	(
	p_rec.position_id,
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
  per_pos_bus.update_validate(p_rec);
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
    ROLLBACK TO upd_per_pos;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_position_id                  in number,
  p_successor_position_id        in number           default hr_api.g_number,
  p_relief_position_id           in number           default hr_api.g_number,
  p_location_id                  in number           default hr_api.g_number,
  p_position_definition_id       in number           default hr_api.g_number,
  p_date_effective               in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_date_end                     in date             default hr_api.g_date,
  p_frequency                    in varchar2         default hr_api.g_varchar2,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_probation_period             in number           default hr_api.g_number,
  p_probation_period_units       in varchar2         default hr_api.g_varchar2,
  p_replacement_required_flag    in varchar2         default hr_api.g_varchar2,
  p_time_normal_finish           in varchar2         default hr_api.g_varchar2,
  p_time_normal_start            in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_working_hours                in number           default hr_api.g_number,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
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
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean          default false
  ) is
--
  l_rec	  per_pos_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pos_shd.convert_args
  (
  p_position_id,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  p_successor_position_id,
  p_relief_position_id,
  p_location_id,
  p_position_definition_id,
  p_date_effective,
  p_comments,
  p_date_end,
  p_frequency,
  p_name,
  p_probation_period,
  p_probation_period_units,
  p_replacement_required_flag,
  p_time_normal_finish,
  p_time_normal_start,
  p_status,
  p_working_hours,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
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
  p_object_version_number
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
end per_pos_upd;

/