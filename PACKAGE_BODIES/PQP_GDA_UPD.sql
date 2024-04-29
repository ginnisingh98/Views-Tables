--------------------------------------------------------
--  DDL for Package Body PQP_GDA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GDA_UPD" as
/* $Header: pqgdarhi.pkb 120.0 2005/05/29 01:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_gda_upd.';  -- Global package name
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
  (p_rec in out nocopy pqp_gda_shd.g_rec_type
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
  -- Update the pqp_gap_daily_absences Row
  --
  update pqp_gap_daily_absences
    set
     gap_daily_absence_id            = p_rec.gap_daily_absence_id
    ,gap_absence_plan_id             = p_rec.gap_absence_plan_id
    ,absence_date                    = p_rec.absence_date
    ,work_pattern_day_type           = p_rec.work_pattern_day_type
    ,level_of_entitlement            = p_rec.level_of_entitlement
    ,level_of_pay                    = p_rec.level_of_pay
    ,duration                        = p_rec.duration
    ,duration_in_hours               = p_rec.duration_in_hours
    ,working_days_per_week           = p_rec.working_days_per_week
    ,fte                             = p_rec.fte -- LG
    ,object_version_number           = p_rec.object_version_number
    where gap_daily_absence_id = p_rec.gap_daily_absence_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqp_gda_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqp_gda_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqp_gda_shd.constraint_error
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
  (p_rec in pqp_gda_shd.g_rec_type
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
  ,p_rec                          in pqp_gda_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_gda_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_gap_daily_absence_id
      => p_rec.gap_daily_absence_id
      ,p_gap_absence_plan_id
      => p_rec.gap_absence_plan_id
      ,p_absence_date
      => p_rec.absence_date
      ,p_work_pattern_day_type
      => p_rec.work_pattern_day_type
      ,p_level_of_entitlement
      => p_rec.level_of_entitlement
      ,p_level_of_pay
      => p_rec.level_of_pay
      ,p_duration
      => p_rec.duration
      ,p_duration_in_hours
      => p_rec.duration_in_hours
      ,p_working_days_per_week
      => p_rec.working_days_per_week
      ,p_fte -- LG
      => p_rec.fte -- LG
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_gap_absence_plan_id_o
      => pqp_gda_shd.g_old_rec.gap_absence_plan_id
      ,p_absence_date_o
      => pqp_gda_shd.g_old_rec.absence_date
      ,p_work_pattern_day_type_o
      => pqp_gda_shd.g_old_rec.work_pattern_day_type
      ,p_level_of_entitlement_o
      => pqp_gda_shd.g_old_rec.level_of_entitlement
      ,p_level_of_pay_o
      => pqp_gda_shd.g_old_rec.level_of_pay
      ,p_duration_o
      => pqp_gda_shd.g_old_rec.duration
      ,p_duration_in_hours_o
      => pqp_gda_shd.g_old_rec.duration_in_hours
      ,p_working_days_per_week_o
      => pqp_gda_shd.g_old_rec.working_days_per_week
      ,p_fte_o -- LG
      => pqp_gda_shd.g_old_rec.fte -- LG
      ,p_object_version_number_o
      => pqp_gda_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_GAP_DAILY_ABSENCES'
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
  (p_rec in out nocopy pqp_gda_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.gap_absence_plan_id = hr_api.g_number) then
    p_rec.gap_absence_plan_id :=
    pqp_gda_shd.g_old_rec.gap_absence_plan_id;
  End If;
  If (p_rec.absence_date = hr_api.g_date) then
    p_rec.absence_date :=
    pqp_gda_shd.g_old_rec.absence_date;
  End If;
  If (p_rec.work_pattern_day_type = hr_api.g_varchar2) then
    p_rec.work_pattern_day_type :=
    pqp_gda_shd.g_old_rec.work_pattern_day_type;
  End If;
  If (p_rec.level_of_entitlement = hr_api.g_varchar2) then
    p_rec.level_of_entitlement :=
    pqp_gda_shd.g_old_rec.level_of_entitlement;
  End If;
  If (p_rec.level_of_pay = hr_api.g_varchar2) then
    p_rec.level_of_pay :=
    pqp_gda_shd.g_old_rec.level_of_pay;
  End If;
  If (p_rec.duration = hr_api.g_number) then
    p_rec.duration :=
    pqp_gda_shd.g_old_rec.duration;
  End If;
  If (p_rec.duration_in_hours = hr_api.g_number) then
    p_rec.duration_in_hours :=
    pqp_gda_shd.g_old_rec.duration_in_hours;
  End If;
  If (p_rec.working_days_per_week = hr_api.g_number) then
    p_rec.working_days_per_week :=
    pqp_gda_shd.g_old_rec.working_days_per_week;
  End If;
  -- LG added below if block
  If (p_rec.fte = hr_api.g_number) then
    p_rec.fte :=
    pqp_gda_shd.g_old_rec.fte;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqp_gda_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_gda_shd.lck
    (p_rec.gap_daily_absence_id
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
  pqp_gda_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqp_gda_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqp_gda_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqp_gda_upd.post_update
     (p_effective_date
     ,p_rec
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
  (p_effective_date               in     date
  ,p_gap_daily_absence_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_gap_absence_plan_id          in     number    default hr_api.g_number
  ,p_absence_date                 in     date      default hr_api.g_date
  ,p_work_pattern_day_type        in     varchar2  default hr_api.g_varchar2
  ,p_level_of_entitlement         in     varchar2  default hr_api.g_varchar2
  ,p_level_of_pay                 in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_in_hours            in     number    default hr_api.g_number
  ,p_working_days_per_week        in     number    default hr_api.g_number
  ,p_fte                          in     number    default hr_api.g_number -- LG
  ) is
--
  l_rec   pqp_gda_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_gda_shd.convert_args
  (p_gap_daily_absence_id
  ,p_gap_absence_plan_id
  ,p_absence_date
  ,p_work_pattern_day_type
  ,p_level_of_entitlement
  ,p_level_of_pay
  ,p_duration
  ,p_duration_in_hours
  ,p_working_days_per_week
  ,p_fte -- LG
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_gda_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqp_gda_upd;

/
