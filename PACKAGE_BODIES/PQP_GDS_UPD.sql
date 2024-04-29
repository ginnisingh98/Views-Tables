--------------------------------------------------------
--  DDL for Package Body PQP_GDS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GDS_UPD" as
/* $Header: pqgdsrhi.pkb 120.0 2005/10/28 07:32 rvishwan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_gds_upd.';  -- Global package name
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
  (p_rec in out nocopy pqp_gds_shd.g_rec_type
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
  pqp_gds_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqp_gap_duration_summary Row
  --
  update pqp_gap_duration_summary
    set
     gap_duration_summary_id         = p_rec.gap_duration_summary_id
    ,assignment_id                   = p_rec.assignment_id
    ,gap_absence_plan_id             = p_rec.gap_absence_plan_id
    ,summary_type                    = p_rec.summary_type
    ,gap_level                       = p_rec.gap_level
    ,duration_in_days                = p_rec.duration_in_days
    ,duration_in_hours               = p_rec.duration_in_hours
    ,date_start                      = p_rec.date_start
    ,date_end                        = p_rec.date_end
    ,object_version_number           = p_rec.object_version_number
    where gap_duration_summary_id = p_rec.gap_duration_summary_id;
  --
  pqp_gds_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_gds_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_gds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_gds_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_gds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_gds_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_gds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_gds_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pqp_gds_shd.g_rec_type
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
  (p_rec                          in pqp_gds_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_gds_rku.after_update
      (p_gap_duration_summary_id
      => p_rec.gap_duration_summary_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_gap_absence_plan_id
      => p_rec.gap_absence_plan_id
      ,p_summary_type
      => p_rec.summary_type
      ,p_gap_level
      => p_rec.gap_level
      ,p_duration_in_days
      => p_rec.duration_in_days
      ,p_duration_in_hours
      => p_rec.duration_in_hours
      ,p_date_start
      => p_rec.date_start
      ,p_date_end
      => p_rec.date_end
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_assignment_id_o
      => pqp_gds_shd.g_old_rec.assignment_id
      ,p_gap_absence_plan_id_o
      => pqp_gds_shd.g_old_rec.gap_absence_plan_id
      ,p_summary_type_o
      => pqp_gds_shd.g_old_rec.summary_type
      ,p_gap_level_o
      => pqp_gds_shd.g_old_rec.gap_level
      ,p_duration_in_days_o
      => pqp_gds_shd.g_old_rec.duration_in_days
      ,p_duration_in_hours_o
      => pqp_gds_shd.g_old_rec.duration_in_hours
      ,p_date_start_o
      => pqp_gds_shd.g_old_rec.date_start
      ,p_date_end_o
      => pqp_gds_shd.g_old_rec.date_end
      ,p_object_version_number_o
      => pqp_gds_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_GAP_DURATION_SUMMARY'
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
  (p_rec in out nocopy pqp_gds_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqp_gds_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.gap_absence_plan_id = hr_api.g_number) then
    p_rec.gap_absence_plan_id :=
    pqp_gds_shd.g_old_rec.gap_absence_plan_id;
  End If;
  If (p_rec.summary_type = hr_api.g_varchar2) then
    p_rec.summary_type :=
    pqp_gds_shd.g_old_rec.summary_type;
  End If;
  If (p_rec.gap_level = hr_api.g_varchar2) then
    p_rec.gap_level :=
    pqp_gds_shd.g_old_rec.gap_level;
  End If;
  If (p_rec.duration_in_days = hr_api.g_number) then
    p_rec.duration_in_days :=
    pqp_gds_shd.g_old_rec.duration_in_days;
  End If;
  If (p_rec.duration_in_hours = hr_api.g_number) then
    p_rec.duration_in_hours :=
    pqp_gds_shd.g_old_rec.duration_in_hours;
  End If;
  If (p_rec.date_start = hr_api.g_date) then
    p_rec.date_start :=
    pqp_gds_shd.g_old_rec.date_start;
  End If;
  If (p_rec.date_end = hr_api.g_date) then
    p_rec.date_end :=
    pqp_gds_shd.g_old_rec.date_end;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pqp_gds_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_gds_shd.lck
    (p_rec.gap_duration_summary_id
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
  pqp_gds_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqp_gds_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqp_gds_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqp_gds_upd.post_update
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
  (p_gap_duration_summary_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_gap_absence_plan_id          in     number    default hr_api.g_number
  ,p_summary_type                 in     varchar2  default hr_api.g_varchar2
  ,p_gap_level                    in     varchar2  default hr_api.g_varchar2
  ,p_duration_in_days             in     number    default hr_api.g_number
  ,p_duration_in_hours            in     number    default hr_api.g_number
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_date_end                     in     date      default hr_api.g_date
  ) is
--
  l_rec   pqp_gds_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_gds_shd.convert_args
  (p_gap_duration_summary_id
  ,p_assignment_id
  ,p_gap_absence_plan_id
  ,p_summary_type
  ,p_gap_level
  ,p_duration_in_days
  ,p_duration_in_hours
  ,p_date_start
  ,p_date_end
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_gds_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqp_gds_upd;

/
