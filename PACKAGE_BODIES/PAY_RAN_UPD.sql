--------------------------------------------------------
--  DDL for Package Body PAY_RAN_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RAN_UPD" as
/* $Header: pyranrhi.pkb 120.0.12000000.2 2007/02/10 10:03:01 vetsrini noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_ran_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_ran_shd.g_rec_type
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
  -- Update the pay_ranges_f Row
  --
  update pay_ranges_f
    set
     range_id                        = p_rec.range_id
    ,EFFECTIVE_START_DATE            = p_rec.EFFECTIVE_START_DATE
    ,EFFECTIVE_END_DATE              = p_rec.EFFECTIVE_END_DATE
    ,range_table_id                  = p_rec.range_table_id
    ,low_band                        = p_rec.low_band
    ,high_band                       = p_rec.high_band
    ,amount1                         = p_rec.amount1
    ,amount2                         = p_rec.amount2
    ,amount3                         = p_rec.amount3
    ,amount4                         = p_rec.amount4
    ,amount5                         = p_rec.amount5
    ,amount6                         = p_rec.amount6
    ,amount7                         = p_rec.amount7
    ,amount8                         = p_rec.amount8
    ,object_version_number           = p_rec.object_version_number
    where range_id = p_rec.range_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_ran_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_ran_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_ran_shd.constraint_error
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
  (p_rec in pay_ran_shd.g_rec_type
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
  (p_rec                          in pay_ran_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_ran_rku.after_update
      (p_range_id      => p_rec.range_id
      ,p_range_table_id      => p_rec.range_table_id
      ,p_low_band      => p_rec.low_band
      ,p_high_band      => p_rec.high_band
      ,p_amount1      => p_rec.amount1
      ,p_amount2      => p_rec.amount2
      ,p_amount3      => p_rec.amount3
      ,p_amount4      => p_rec.amount4
      ,p_amount5      => p_rec.amount5
      ,p_amount6      => p_rec.amount6
      ,p_amount7      => p_rec.amount7
      ,p_amount8      => p_rec.amount8
      ,p_effective_start_date      => p_rec.effective_start_date
      ,p_effective_end_date      => p_rec.effective_end_date
      ,p_object_version_number      => p_rec.object_version_number
      ,p_range_table_id_o      => pay_ran_shd.g_old_rec.range_table_id
      ,p_low_band_o      => pay_ran_shd.g_old_rec.low_band
      ,p_high_band_o      => pay_ran_shd.g_old_rec.high_band
      ,p_amount1_o      => pay_ran_shd.g_old_rec.amount1
      ,p_amount2_o      => pay_ran_shd.g_old_rec.amount2
      ,p_amount3_o      => pay_ran_shd.g_old_rec.amount3
      ,p_amount4_o      => pay_ran_shd.g_old_rec.amount4
      ,p_amount5_o      => pay_ran_shd.g_old_rec.amount5
      ,p_amount6_o      => pay_ran_shd.g_old_rec.amount6
      ,p_amount7_o      => pay_ran_shd.g_old_rec.amount7
      ,p_amount8_o      => pay_ran_shd.g_old_rec.amount8
      ,p_effective_start_date_o      => pay_ran_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o      => pay_ran_shd.g_old_rec.effective_end_date
      ,p_object_version_number_o      => pay_ran_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RANGES_F'
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
  (p_rec in out nocopy pay_ran_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.range_table_id = hr_api.g_number) then
    p_rec.range_table_id :=
    pay_ran_shd.g_old_rec.range_table_id;
  End If;
  If (p_rec.low_band = hr_api.g_number) then
    p_rec.low_band :=
    pay_ran_shd.g_old_rec.low_band;
  End If;
  If (p_rec.high_band = hr_api.g_number) then
    p_rec.high_band :=
    pay_ran_shd.g_old_rec.high_band;
  End If;
  If (p_rec.amount1 = hr_api.g_number) then
    p_rec.amount1 :=    pay_ran_shd.g_old_rec.amount1;
  End If;
    If (p_rec.amount2 = hr_api.g_number) then
    p_rec.amount2 :=    pay_ran_shd.g_old_rec.amount2;
  End If;
    If (p_rec.amount3 = hr_api.g_number) then
    p_rec.amount3 :=    pay_ran_shd.g_old_rec.amount3;
  End If;
    If (p_rec.amount4 = hr_api.g_number) then
    p_rec.amount4 :=    pay_ran_shd.g_old_rec.amount4;
  End If;
  If (p_rec.amount5 = hr_api.g_number) then
    p_rec.amount5 :=    pay_ran_shd.g_old_rec.amount5;
  End If;
    If (p_rec.amount6 = hr_api.g_number) then
    p_rec.amount6 :=    pay_ran_shd.g_old_rec.amount6;
  End If;
    If (p_rec.amount7 = hr_api.g_number) then
    p_rec.amount7 :=    pay_ran_shd.g_old_rec.amount7;
  End If;
    If (p_rec.amount8 = hr_api.g_number) then
    p_rec.amount8 :=    pay_ran_shd.g_old_rec.amount8;
  End If;

  If (p_rec.effective_start_date = hr_api.g_date) then
    p_rec.effective_start_date :=
    pay_ran_shd.g_old_rec.effective_start_date;
  End If;
  If (p_rec.effective_end_date = hr_api.g_date) then
    p_rec.effective_end_date :=
    pay_ran_shd.g_old_rec.effective_end_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pay_ran_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_ran_shd.lck
    (p_rec.range_id
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
  pay_ran_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_ran_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_ran_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --

  -- Commented Because UserHook Support is not Provided for Now.
/*
 pay_ran_upd.post_update
     (p_rec
     );
*/
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_range_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_range_table_id               in     number    default hr_api.g_number
  ,p_low_band                     in     number    default hr_api.g_number
  ,p_high_band                    in     number    default hr_api.g_number
  ,p_amount1                      in     number    default hr_api.g_number
  ,p_amount2                      in     number    default hr_api.g_number
  ,p_amount3                      in     number    default hr_api.g_number
  ,p_amount4                      in     number    default hr_api.g_number
  ,p_amount5                      in     number    default hr_api.g_number
  ,p_amount6                      in     number    default hr_api.g_number
  ,p_amount7                      in     number    default hr_api.g_number
  ,p_amount8                      in     number    default hr_api.g_number
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_effective_end_date           in     date      default hr_api.g_date
  ) is
--
  l_rec   pay_ran_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_ran_shd.convert_args
  (p_range_id
  ,p_range_table_id
  ,p_low_band
  ,p_high_band
  ,p_amount1
  ,p_amount2
  ,p_amount3
  ,p_amount4
  ,p_amount5
  ,p_amount6
  ,p_amount7
  ,p_amount8
  ,p_effective_start_date
  ,p_effective_end_date
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_ran_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_ran_upd;

/
