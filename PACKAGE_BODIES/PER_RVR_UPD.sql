--------------------------------------------------------
--  DDL for Package Body PER_RVR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RVR_UPD" as
/* $Header: pervrrhi.pkb 120.5 2006/06/12 23:57:11 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rvr_upd.';  -- Global package name
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
  (p_rec in out nocopy per_rvr_shd.g_rec_type
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
  -- Update the per_ri_view_reports Row
  --
  update per_ri_view_reports
    set
     workbench_item_code             = p_rec.workbench_item_code
    ,workbench_view_report_code      = p_rec.workbench_view_report_code
    ,workbench_view_report_type      = p_rec.workbench_view_report_type
    ,workbench_view_report_action    = p_rec.workbench_view_report_action
    ,workbench_view_country          = p_rec.workbench_view_country
    ,wb_view_report_instruction      = p_rec.wb_view_report_instruction
    ,object_version_number           = p_rec.object_version_number
    ,primary_industry		         = p_rec.primary_industry
    ,enabled_flag                    = p_rec.enabled_flag
    where workbench_view_report_code = p_rec.workbench_view_report_code;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_rvr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_rvr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_rvr_shd.constraint_error
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
  (p_rec in per_rvr_shd.g_rec_type
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
  (p_rec                          in per_rvr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_rvr_rku.after_update
      (p_workbench_item_code             => p_rec.workbench_item_code
      ,p_workbench_view_report_code      => p_rec.workbench_view_report_code
      ,p_workbench_view_report_type      => p_rec.workbench_view_report_type
      ,p_workbench_view_report_action    => p_rec.workbench_view_report_action
      ,p_workbench_view_country          => p_rec.workbench_view_country
      ,p_wb_view_report_instruction      => p_rec.wb_view_report_instruction
      ,p_object_version_number           => p_rec.object_version_number
      ,p_primary_industry	        	 => p_rec.primary_industry
      ,p_enabled_flag                    => p_rec.enabled_flag
      ,p_workbench_item_code_o           => per_rvr_shd.g_old_rec.workbench_item_code
      ,p_workbench_view_report_type_o    => per_rvr_shd.g_old_rec.workbench_view_report_type
      ,p_workbench_view_report_acti_o    => per_rvr_shd.g_old_rec.workbench_view_report_action
      ,p_workbench_view_country_o        => per_rvr_shd.g_old_rec.workbench_view_country
      ,p_wb_view_report_instruction_o    => per_rvr_shd.g_old_rec.wb_view_report_instruction
      ,p_object_version_number_o         => per_rvr_shd.g_old_rec.object_version_number
      ,p_primary_industry_o	        	 => per_rvr_shd.g_old_rec.primary_industry
      ,p_enabled_flag_o                  => per_rvr_shd.g_old_rec.enabled_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_RI_VIEW_REPORTS'
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
  (p_rec in out nocopy per_rvr_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.workbench_item_code = hr_api.g_varchar2) then
    p_rec.workbench_item_code :=
    per_rvr_shd.g_old_rec.workbench_item_code;
  End If;
  If (p_rec.workbench_view_report_type = hr_api.g_varchar2) then
    p_rec.workbench_view_report_type :=
    per_rvr_shd.g_old_rec.workbench_view_report_type;
  End If;
  If (p_rec.workbench_view_report_action = hr_api.g_varchar2) then
    p_rec.workbench_view_report_action :=
    per_rvr_shd.g_old_rec.workbench_view_report_action;
  End If;
  If (p_rec.workbench_view_country = hr_api.g_varchar2) then
    p_rec.workbench_view_country :=
    per_rvr_shd.g_old_rec.workbench_view_country;
  End If;
  If (p_rec.wb_view_report_instruction = hr_api.g_varchar2) then
    p_rec.wb_view_report_instruction :=
    per_rvr_shd.g_old_rec.wb_view_report_instruction;
  End If;
  If (p_rec.primary_industry = hr_api.g_varchar2) then
    p_rec.primary_industry :=
    per_rvr_shd.g_old_rec.primary_industry;
  End If;
  If (p_rec.enabled_flag = hr_api.g_varchar2) then
      p_rec.enabled_flag :=
     per_rvr_shd.g_old_rec.enabled_flag;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy per_rvr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_rvr_shd.lck
    (p_rec.workbench_view_report_code
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
  per_rvr_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_rvr_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_rvr_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_rvr_upd.post_update
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
  (p_workbench_view_report_code   in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_workbench_item_code          in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_report_type   in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_report_action in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_country       in     varchar2  default hr_api.g_varchar2
  ,p_wb_view_report_instruction   in     varchar2  default hr_api.g_varchar2
  ,p_primary_industry		      in	 varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   per_rvr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_rvr_shd.convert_args
  (p_workbench_item_code
  ,p_workbench_view_report_code
  ,p_workbench_view_report_type
  ,p_workbench_view_report_action
  ,p_workbench_view_country
  ,p_wb_view_report_instruction
  ,p_object_version_number
  ,p_primary_industry
  ,p_enabled_flag
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_rvr_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_rvr_upd;

/
