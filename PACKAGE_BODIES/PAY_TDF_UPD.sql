--------------------------------------------------------
--  DDL for Package Body PAY_TDF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TDF_UPD" as
/* $Header: pytdfrhi.pkb 120.4 2005/09/20 06:56 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_tdf_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_tdf_shd.g_rec_type
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
  pay_tdf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_time_definitions Row
  --
  update pay_time_definitions
    set
     time_definition_id              = p_rec.time_definition_id
    ,short_name                      = p_rec.short_name
    ,definition_name                 = p_rec.definition_name
    ,period_type                     = p_rec.period_type
    ,period_unit                     = p_rec.period_unit
    ,day_adjustment                  = p_rec.day_adjustment
    ,dynamic_code                    = p_rec.dynamic_code
    ,business_group_id               = p_rec.business_group_id
    ,legislation_code                = p_rec.legislation_code
    ,definition_type                 = p_rec.definition_type
    ,number_of_years                 = p_rec.number_of_years
    ,start_date                      = p_rec.start_date
    ,period_time_definition_id       = p_rec.period_time_definition_id
    ,creator_id                      = p_rec.creator_id
    ,creator_type                    = p_rec.creator_type
    ,object_version_number           = p_rec.object_version_number
    where time_definition_id = p_rec.time_definition_id;
  --
  pay_tdf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_tdf_shd.g_api_dml := false;   -- Unset the api dml status
    pay_tdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_tdf_shd.g_api_dml := false;   -- Unset the api dml status
    pay_tdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_tdf_shd.g_api_dml := false;   -- Unset the api dml status
    pay_tdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_tdf_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pay_tdf_shd.g_rec_type
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
  ,p_rec                          in pay_tdf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_tdf_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_time_definition_id
      => p_rec.time_definition_id
      ,p_short_name
      => p_rec.short_name
      ,p_definition_name
      => p_rec.definition_name
      ,p_period_type
      => p_rec.period_type
      ,p_period_unit
      => p_rec.period_unit
      ,p_day_adjustment
      => p_rec.day_adjustment
      ,p_dynamic_code
      => p_rec.dynamic_code
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_definition_type
      => p_rec.definition_type
      ,p_number_of_years
      => p_rec.number_of_years
      ,p_start_date
      => p_rec.start_date
      ,p_period_time_definition_id
      => p_rec.period_time_definition_id
      ,p_creator_id
      => p_rec.creator_id
      ,p_creator_type
      => p_rec.creator_type
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_short_name_o
      => pay_tdf_shd.g_old_rec.short_name
      ,p_definition_name_o
      => pay_tdf_shd.g_old_rec.definition_name
      ,p_period_type_o
      => pay_tdf_shd.g_old_rec.period_type
      ,p_period_unit_o
      => pay_tdf_shd.g_old_rec.period_unit
      ,p_day_adjustment_o
      => pay_tdf_shd.g_old_rec.day_adjustment
      ,p_dynamic_code_o
      => pay_tdf_shd.g_old_rec.dynamic_code
      ,p_business_group_id_o
      => pay_tdf_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_tdf_shd.g_old_rec.legislation_code
      ,p_definition_type_o
      => pay_tdf_shd.g_old_rec.definition_type
      ,p_number_of_years_o
      => pay_tdf_shd.g_old_rec.number_of_years
      ,p_start_date_o
      => pay_tdf_shd.g_old_rec.start_date
      ,p_period_time_definition_id_o
      => pay_tdf_shd.g_old_rec.period_time_definition_id
      ,p_creator_id_o
      => pay_tdf_shd.g_old_rec.creator_id
      ,p_creator_type_o
      => pay_tdf_shd.g_old_rec.creator_type
      ,p_object_version_number_o
      => pay_tdf_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_TIME_DEFINITIONS'
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
  (p_rec in out nocopy pay_tdf_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.short_name = hr_api.g_varchar2) then
    p_rec.short_name :=
    pay_tdf_shd.g_old_rec.short_name;
  End If;
  If (p_rec.definition_name = hr_api.g_varchar2) then
    p_rec.definition_name :=
    pay_tdf_shd.g_old_rec.definition_name;
  End If;
  If (p_rec.period_type = hr_api.g_varchar2) then
    p_rec.period_type :=
    pay_tdf_shd.g_old_rec.period_type;
  End If;
  If (p_rec.period_unit = hr_api.g_varchar2) then
    p_rec.period_unit :=
    pay_tdf_shd.g_old_rec.period_unit;
  End If;
  If (p_rec.day_adjustment = hr_api.g_varchar2) then
    p_rec.day_adjustment :=
    pay_tdf_shd.g_old_rec.day_adjustment;
  End If;
  If (p_rec.dynamic_code = hr_api.g_varchar2) then
    p_rec.dynamic_code :=
    pay_tdf_shd.g_old_rec.dynamic_code;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_tdf_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_tdf_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.definition_type = hr_api.g_varchar2) then
    p_rec.definition_type :=
    pay_tdf_shd.g_old_rec.definition_type;
  End If;
  If (p_rec.number_of_years = hr_api.g_number) then
    p_rec.number_of_years :=
    pay_tdf_shd.g_old_rec.number_of_years;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    pay_tdf_shd.g_old_rec.start_date;
  End If;
  If (p_rec.period_time_definition_id = hr_api.g_number) then
    p_rec.period_time_definition_id :=
    pay_tdf_shd.g_old_rec.period_time_definition_id;
  End If;
  If (p_rec.creator_id = hr_api.g_number) then
    p_rec.creator_id :=
    pay_tdf_shd.g_old_rec.creator_id;
  End If;
  If (p_rec.creator_type = hr_api.g_varchar2) then
    p_rec.creator_type :=
    pay_tdf_shd.g_old_rec.creator_type;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pay_tdf_shd.g_rec_type
  ,p_regenerate_periods              out nocopy boolean
  ,p_delete_periods                  out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_tdf_shd.lck
    (p_rec.time_definition_id
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
  pay_tdf_bus.update_validate
     (p_effective_date
     ,p_rec
     ,p_regenerate_periods
     ,p_delete_periods
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_tdf_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_tdf_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_tdf_upd.post_update
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
  ,p_time_definition_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_regenerate_periods           out nocopy boolean
  ,p_delete_periods               out nocopy boolean
  ,p_short_name                   in     varchar2  default hr_api.g_varchar2
  ,p_definition_name              in     varchar2  default hr_api.g_varchar2
  ,p_period_type                  in     varchar2  default hr_api.g_varchar2
  ,p_period_unit                  in     varchar2  default hr_api.g_varchar2
  ,p_day_adjustment               in     varchar2  default hr_api.g_varchar2
  ,p_dynamic_code                 in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_definition_type              in     varchar2  default hr_api.g_varchar2
  ,p_number_of_years              in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_period_time_definition_id    in     number    default hr_api.g_number
  ,p_creator_id                   in     number    default hr_api.g_number
  ,p_creator_type                 in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pay_tdf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_tdf_shd.convert_args
  (p_time_definition_id
  ,p_short_name
  ,p_definition_name
  ,p_period_type
  ,p_period_unit
  ,p_day_adjustment
  ,p_dynamic_code
  ,p_business_group_id
  ,p_legislation_code
  ,p_definition_type
  ,p_number_of_years
  ,p_start_date
  ,p_period_time_definition_id
  ,p_creator_id
  ,p_creator_type
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_tdf_upd.upd
     (p_effective_date
     ,l_rec
     ,p_regenerate_periods
     ,p_delete_periods
     );

  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_tdf_upd;

/
