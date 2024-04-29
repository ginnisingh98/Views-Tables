--------------------------------------------------------
--  DDL for Package Body BEN_BCD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BCD_UPD" as
/* $Header: bebcdrhi.pkb 120.0 2005/05/28 00:34:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_bcd_upd.';  -- Global package name
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
  (p_rec in out nocopy ben_bcd_shd.g_rec_type
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
  -- Update the ben_cwb_matrix_dtl Row
  --
  update ben_cwb_matrix_dtl
    set
     cwb_matrix_dtl_id               = p_rec.cwb_matrix_dtl_id
    ,cwb_matrix_id                   = p_rec.cwb_matrix_id
    ,row_crit_val                    = p_rec.row_crit_val
    ,col_crit_val                    = p_rec.col_crit_val
    ,pct_emp_cndr                    = p_rec.pct_emp_cndr
    ,pct_val                         = p_rec.pct_val
    ,emp_amt                         = p_rec.emp_amt
    ,business_group_id               = p_rec.business_group_id
    ,object_version_number           = p_rec.object_version_number
    where cwb_matrix_dtl_id = p_rec.cwb_matrix_dtl_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ben_bcd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ben_bcd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ben_bcd_shd.constraint_error
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
  (p_rec in ben_bcd_shd.g_rec_type
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
  (p_rec                          in ben_bcd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_bcd_rku.after_update
      (p_cwb_matrix_dtl_id
      => p_rec.cwb_matrix_dtl_id
      ,p_cwb_matrix_id
      => p_rec.cwb_matrix_id
      ,p_row_crit_val
      => p_rec.row_crit_val
      ,p_col_crit_val
      => p_rec.col_crit_val
      ,p_pct_emp_cndr
      => p_rec.pct_emp_cndr
      ,p_pct_val
      => p_rec.pct_val
      ,p_emp_amt
      => p_rec.emp_amt
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_cwb_matrix_id_o
      => ben_bcd_shd.g_old_rec.cwb_matrix_id
      ,p_row_crit_val_o
      => ben_bcd_shd.g_old_rec.row_crit_val
      ,p_col_crit_val_o
      => ben_bcd_shd.g_old_rec.col_crit_val
      ,p_pct_emp_cndr_o
      => ben_bcd_shd.g_old_rec.pct_emp_cndr
      ,p_pct_val_o
      => ben_bcd_shd.g_old_rec.pct_val
      ,p_emp_amt_o
      => ben_bcd_shd.g_old_rec.emp_amt
      ,p_business_group_id_o
      => ben_bcd_shd.g_old_rec.business_group_id
      ,p_object_version_number_o
      => ben_bcd_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_MATRIX_DTL'
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
  (p_rec in out nocopy ben_bcd_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.cwb_matrix_id = hr_api.g_number) then
    p_rec.cwb_matrix_id :=
    ben_bcd_shd.g_old_rec.cwb_matrix_id;
  End If;
  If (p_rec.row_crit_val = hr_api.g_varchar2) then
    p_rec.row_crit_val :=
    ben_bcd_shd.g_old_rec.row_crit_val;
  End If;
  If (p_rec.col_crit_val = hr_api.g_varchar2) then
    p_rec.col_crit_val :=
    ben_bcd_shd.g_old_rec.col_crit_val;
  End If;
  If (p_rec.pct_emp_cndr = hr_api.g_number) then
    p_rec.pct_emp_cndr :=
    ben_bcd_shd.g_old_rec.pct_emp_cndr;
  End If;
  If (p_rec.pct_val = hr_api.g_number) then
    p_rec.pct_val :=
    ben_bcd_shd.g_old_rec.pct_val;
  End If;
  If (p_rec.emp_amt = hr_api.g_number) then
    p_rec.emp_amt :=
    ben_bcd_shd.g_old_rec.emp_amt;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_bcd_shd.g_old_rec.business_group_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy ben_bcd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_bcd_shd.lck
    (p_rec.cwb_matrix_dtl_id
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
  ben_bcd_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ben_bcd_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_bcd_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_bcd_upd.post_update
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
  (p_cwb_matrix_dtl_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_cwb_matrix_id                in     number    default hr_api.g_number
  ,p_row_crit_val                 in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_col_crit_val                 in     varchar2  default hr_api.g_varchar2
  ,p_pct_emp_cndr                 in     number    default hr_api.g_number
  ,p_pct_val                      in     number    default hr_api.g_number
  ,p_emp_amt                      in     number    default hr_api.g_number
  ) is
--
  l_rec   ben_bcd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_bcd_shd.convert_args
  (p_cwb_matrix_dtl_id
  ,p_cwb_matrix_id
  ,p_row_crit_val
  ,p_col_crit_val
  ,p_pct_emp_cndr
  ,p_pct_val
  ,p_emp_amt
  ,p_business_group_id
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_bcd_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_bcd_upd;

/
