--------------------------------------------------------
--  DDL for Package Body PQH_VLP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VLP_UPD" as
/* $Header: pqvlprhi.pkb 115.6 2004/03/31 00:31:40 kgowripe noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_vlp_upd.';  -- Global package name
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
  (p_rec in out nocopy pqh_vlp_shd.g_rec_type
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
  -- Update the pqh_fr_validation_periods Row
  --
  update pqh_fr_validation_periods
    set
     validation_period_id            = p_rec.validation_period_id
    ,validation_id                   = p_rec.validation_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,previous_employer_id            = p_rec.previous_employer_id
    ,assignment_category	     = p_rec.assignment_category
    ,normal_hours                    = p_rec.normal_hours
    ,frequency                       = p_rec.frequency
    ,period_years                    = p_rec.period_years
    ,period_months                   = p_rec.period_months
    ,period_days                     = p_rec.period_days
    ,comments                        = p_rec.comments
    ,validation_status               = p_rec.validation_status
    ,object_version_number           = p_rec.object_version_number
    where validation_period_id = p_rec.validation_period_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_vlp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_vlp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_vlp_shd.constraint_error
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
  (p_rec in pqh_vlp_shd.g_rec_type
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
  ,p_rec                          in pqh_vlp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_vlp_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_validation_period_id
      => p_rec.validation_period_id
      ,p_validation_id
      => p_rec.validation_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_previous_employer_id
      => p_rec.previous_employer_id
      ,p_assignment_category
      => p_rec.assignment_category
      ,p_normal_hours
      => p_rec.normal_hours
      ,p_frequency
      => p_rec.frequency
      ,p_period_years
      => p_rec.period_years
      ,p_period_months
      => p_rec.period_months
      ,p_period_days
      => p_rec.period_days
      ,p_comments
      => p_rec.comments
      ,p_validation_status
      => p_rec.validation_status
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_validation_id_o
      => pqh_vlp_shd.g_old_rec.validation_id
      ,p_start_date_o
      => pqh_vlp_shd.g_old_rec.start_date
      ,p_end_date_o
      => pqh_vlp_shd.g_old_rec.end_date
      ,p_previous_employer_id_o
      => pqh_vlp_shd.g_old_rec.previous_employer_id
      ,p_assignment_category_o
      => pqh_vlp_shd.g_old_rec.assignment_category
      ,p_normal_hours_o
      => pqh_vlp_shd.g_old_rec.normal_hours
      ,p_frequency_o
      => pqh_vlp_shd.g_old_rec.frequency
      ,p_period_years_o
      => pqh_vlp_shd.g_old_rec.period_years
      ,p_period_months_o
      => pqh_vlp_shd.g_old_rec.period_months
      ,p_period_days_o
      => pqh_vlp_shd.g_old_rec.period_days
      ,p_comments_o
      => pqh_vlp_shd.g_old_rec.comments
      ,p_validation_status_o
      => pqh_vlp_shd.g_old_rec.validation_status
      ,p_object_version_number_o
      => pqh_vlp_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATION_PERIODS'
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
  (p_rec in out nocopy pqh_vlp_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.validation_id = hr_api.g_number) then
    p_rec.validation_id :=
    pqh_vlp_shd.g_old_rec.validation_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    pqh_vlp_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    pqh_vlp_shd.g_old_rec.end_date;
  End If;
  If (p_rec.previous_employer_id = hr_api.g_number) then
    p_rec.previous_employer_id :=
    pqh_vlp_shd.g_old_rec.previous_employer_id;
  End If;
  If (p_rec.assignment_category = hr_api.g_varchar2) then
    p_rec.assignment_category :=
    pqh_vlp_shd.g_old_rec.assignment_category;
  End If;

  If (p_rec.normal_hours = hr_api.g_number) then
    p_rec.normal_hours :=
    pqh_vlp_shd.g_old_rec.normal_hours;
  End If;
  If (p_rec.frequency = hr_api.g_varchar2) then
    p_rec.frequency :=
    pqh_vlp_shd.g_old_rec.frequency;
  End If;
  If (p_rec.period_years = hr_api.g_number) then
    p_rec.period_years :=
    pqh_vlp_shd.g_old_rec.period_years;
  End If;
  If (p_rec.period_months = hr_api.g_number) then
    p_rec.period_months :=
    pqh_vlp_shd.g_old_rec.period_months;
  End If;
  If (p_rec.period_days = hr_api.g_number) then
    p_rec.period_days :=
    pqh_vlp_shd.g_old_rec.period_days;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    pqh_vlp_shd.g_old_rec.comments;
  End If;
  If (p_rec.validation_status = hr_api.g_varchar2) then
    p_rec.validation_status :=
    pqh_vlp_shd.g_old_rec.validation_status;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_vlp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_vlp_shd.lck
    (p_rec.validation_period_id
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
  pqh_vlp_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqh_vlp_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_vlp_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_vlp_upd.post_update
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
  ,p_validation_period_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_validation_id                in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_assignment_category	  in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_validation_status            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pqh_vlp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_vlp_shd.convert_args
  (p_validation_period_id
  ,p_validation_id
  ,p_start_date
  ,p_end_date
  ,p_previous_employer_id
  ,p_assignment_category
  ,p_normal_hours
  ,p_frequency
  ,p_period_years
  ,p_period_months
  ,p_period_days
  ,p_comments
  ,p_validation_status
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_vlp_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_vlp_upd;

/