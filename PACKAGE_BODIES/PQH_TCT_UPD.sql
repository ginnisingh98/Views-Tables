--------------------------------------------------------
--  DDL for Package Body PQH_TCT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCT_UPD" as
/* $Header: pqtctrhi.pkb 120.4.12000000.2 2007/04/19 12:48:04 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tct_upd.';  -- Global package name
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
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
Procedure update_dml(p_rec in out nocopy pqh_tct_shd.g_rec_type) is
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
  --
  -- Update the pqh_transaction_categories Row
  --
  update pqh_transaction_categories
  set
  transaction_category_id           = p_rec.transaction_category_id,
  custom_wf_process_name            = p_rec.custom_wf_process_name,
  custom_workflow_name              = p_rec.custom_workflow_name,
  form_name                         = p_rec.form_name,
  freeze_status_cd                  = p_rec.freeze_status_cd,
  future_action_cd                  = p_rec.future_action_cd,
  member_cd                         = p_rec.member_cd,
  name                              = p_rec.name,
  short_name                        = p_rec.short_name,
  post_style_cd                     = p_rec.post_style_cd,
  post_txn_function                 = p_rec.post_txn_function,
  route_validated_txn_flag          = p_rec.route_validated_txn_flag,
  prevent_approver_skip             = p_rec.prevent_approver_skip,
  workflow_enable_flag          = p_rec.workflow_enable_flag,
  enable_flag          = p_rec.enable_flag,
  timeout_days                      = p_rec.timeout_days,
  object_version_number             = p_rec.object_version_number,
  consolidated_table_route_id       = p_rec.consolidated_table_route_id,
  business_group_id                 = p_rec.business_group_id,
  setup_type_cd                     = p_rec.setup_type_cd,
  master_table_route_id       = p_rec.master_table_route_id
  where transaction_category_id = p_rec.transaction_category_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_tct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_tct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_tct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pqh_tct_shd.g_rec_type) is
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(
p_effective_date in date,p_rec in pqh_tct_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pqh_tct_rku.after_update
      (
  p_transaction_category_id       =>p_rec.transaction_category_id
 ,p_custom_wf_process_name        =>p_rec.custom_wf_process_name
 ,p_custom_workflow_name          =>p_rec.custom_workflow_name
 ,p_form_name                     =>p_rec.form_name
 ,p_freeze_status_cd              =>p_rec.freeze_status_cd
 ,p_future_action_cd              =>p_rec.future_action_cd
 ,p_member_cd                     =>p_rec.member_cd
 ,p_name                          =>p_rec.name
 ,p_short_name                    =>p_rec.short_name
 ,p_post_style_cd                 =>p_rec.post_style_cd
 ,p_post_txn_function             =>p_rec.post_txn_function
 ,p_route_validated_txn_flag      =>p_rec.route_validated_txn_flag
 ,p_prevent_approver_skip         =>p_rec.prevent_approver_skip
 ,p_workflow_enable_flag      =>p_rec.workflow_enable_flag
 ,p_enable_flag      =>p_rec.enable_flag
 ,p_timeout_days                  =>p_rec.timeout_days
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_consolidated_table_route_id   =>p_rec.consolidated_table_route_id
 ,p_business_group_id             => p_rec.business_group_id
 ,p_setup_type_cd                 => p_rec.setup_type_cd
 ,p_master_table_route_id   =>p_rec.master_table_route_id
 ,p_effective_date                =>p_effective_date
 ,p_custom_wf_process_name_o      =>pqh_tct_shd.g_old_rec.custom_wf_process_name
 ,p_custom_workflow_name_o        =>pqh_tct_shd.g_old_rec.custom_workflow_name
 ,p_form_name_o                   =>pqh_tct_shd.g_old_rec.form_name
 ,p_freeze_status_cd_o            =>pqh_tct_shd.g_old_rec.freeze_status_cd
 ,p_future_action_cd_o            =>pqh_tct_shd.g_old_rec.future_action_cd
 ,p_member_cd_o                   =>pqh_tct_shd.g_old_rec.member_cd
 ,p_name_o                        =>pqh_tct_shd.g_old_rec.name
 ,p_short_name_o                  =>pqh_tct_shd.g_old_rec.short_name
 ,p_post_style_cd_o               =>pqh_tct_shd.g_old_rec.post_style_cd
 ,p_post_txn_function_o           =>pqh_tct_shd.g_old_rec.post_txn_function
 ,p_route_validated_txn_flag_o    =>pqh_tct_shd.g_old_rec.route_validated_txn_flag
 ,p_prevent_approver_skip_o       =>pqh_tct_shd.g_old_rec.prevent_approver_skip
 ,p_workflow_enable_flag_o    =>pqh_tct_shd.g_old_rec.workflow_enable_flag
 ,p_enable_flag_o    =>pqh_tct_shd.g_old_rec.enable_flag
 ,p_timeout_days_o                =>pqh_tct_shd.g_old_rec.timeout_days
 ,p_object_version_number_o       =>pqh_tct_shd.g_old_rec.object_version_number
 ,p_consolidated_table_route_i_o =>pqh_tct_shd.g_old_rec.consolidated_table_route_id
 ,p_business_group_id_o             => pqh_tct_shd.g_old_rec.business_group_id
 ,p_setup_type_cd_o                 => pqh_tct_shd.g_old_rec.setup_type_cd
 ,p_master_table_route_i_o =>pqh_tct_shd.g_old_rec.master_table_route_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_transaction_categories'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pqh_tct_shd.g_rec_type) is
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
  If (p_rec.custom_wf_process_name = hr_api.g_varchar2) then
    p_rec.custom_wf_process_name :=
    pqh_tct_shd.g_old_rec.custom_wf_process_name;
  End If;
  If (p_rec.custom_workflow_name = hr_api.g_varchar2) then
    p_rec.custom_workflow_name :=
    pqh_tct_shd.g_old_rec.custom_workflow_name;
  End If;
  If (p_rec.form_name = hr_api.g_varchar2) then
    p_rec.form_name :=
    pqh_tct_shd.g_old_rec.form_name;
  End If;
  If (p_rec.freeze_status_cd = hr_api.g_varchar2) then
    p_rec.freeze_status_cd :=
    pqh_tct_shd.g_old_rec.freeze_status_cd;
  End If;
  If (p_rec.future_action_cd = hr_api.g_varchar2) then
    p_rec.future_action_cd :=
    pqh_tct_shd.g_old_rec.future_action_cd;
  End If;
  If (p_rec.member_cd = hr_api.g_varchar2) then
    p_rec.member_cd :=
    pqh_tct_shd.g_old_rec.member_cd;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    pqh_tct_shd.g_old_rec.name;
  End If;
  If (p_rec.short_name = hr_api.g_varchar2) then
    p_rec.short_name :=
    pqh_tct_shd.g_old_rec.short_name;
  End If;
  If (p_rec.post_style_cd = hr_api.g_varchar2) then
    p_rec.post_style_cd :=
    pqh_tct_shd.g_old_rec.post_style_cd;
  End If;
  If (p_rec.post_txn_function = hr_api.g_varchar2) then
    p_rec.post_txn_function :=
    pqh_tct_shd.g_old_rec.post_txn_function;
  End If;
  If (p_rec.route_validated_txn_flag = hr_api.g_varchar2) then
    p_rec.route_validated_txn_flag :=
    pqh_tct_shd.g_old_rec.route_validated_txn_flag;
  End If;
  If (p_rec.prevent_approver_skip = hr_api.g_varchar2) then
    p_rec.prevent_approver_skip :=
    pqh_tct_shd.g_old_rec.prevent_approver_skip;
  End If;
  If (p_rec.workflow_enable_flag = hr_api.g_varchar2) then
    p_rec.workflow_enable_flag :=
    pqh_tct_shd.g_old_rec.workflow_enable_flag;
  End If;
  If (p_rec.enable_flag = hr_api.g_varchar2) then
    p_rec.enable_flag :=
    pqh_tct_shd.g_old_rec.enable_flag;
  End If;
  If (p_rec.timeout_days = hr_api.g_number) then
    p_rec.timeout_days :=
    pqh_tct_shd.g_old_rec.timeout_days;
  End If;
  If (p_rec.consolidated_table_route_id = hr_api.g_number) then
    p_rec.consolidated_table_route_id :=
    pqh_tct_shd.g_old_rec.consolidated_table_route_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_tct_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.setup_type_cd = hr_api.g_varchar2) then
    p_rec.setup_type_cd :=
    pqh_tct_shd.g_old_rec.setup_type_cd;
  End If;
  If (p_rec.master_table_route_id = hr_api.g_number) then
    p_rec.master_table_route_id :=
    pqh_tct_shd.g_old_rec.master_table_route_id;
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
  p_effective_date in date,
  p_rec        in out nocopy pqh_tct_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_tct_shd.lck
	(
	p_rec.transaction_category_id,
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
  pqh_tct_bus.update_validate(p_rec
  ,p_effective_date);
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
  post_update(
p_effective_date,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_transaction_category_id      in number,
  p_custom_wf_process_name       in varchar2         default hr_api.g_varchar2,
  p_custom_workflow_name         in varchar2         default hr_api.g_varchar2,
  p_form_name                    in varchar2         default hr_api.g_varchar2,
  p_freeze_status_cd             in varchar2         default hr_api.g_varchar2,
  p_future_action_cd             in varchar2         default hr_api.g_varchar2,
  p_member_cd                    in varchar2         default hr_api.g_varchar2,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_short_name                   in varchar2         default hr_api.g_varchar2,
  p_post_style_cd                in varchar2         default hr_api.g_varchar2,
  p_post_txn_function            in varchar2         default hr_api.g_varchar2,
  p_route_validated_txn_flag     in varchar2         default hr_api.g_varchar2,
  p_prevent_approver_skip        in varchar2         default hr_api.g_varchar2,
  p_workflow_enable_flag     in varchar2         default hr_api.g_varchar2,
  p_enable_flag     in varchar2         default hr_api.g_varchar2,
  p_timeout_days                 in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_consolidated_table_route_id  in number           default hr_api.g_number ,
  p_business_group_id            in number           default hr_api.g_number ,
  p_setup_type_cd                in varchar2         default hr_api.g_varchar2,
  p_master_table_route_id  in number           default hr_api.g_number
  ) is
--
  l_rec	  pqh_tct_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_tct_shd.convert_args
  (
  p_transaction_category_id,
  p_custom_wf_process_name,
  p_custom_workflow_name,
  p_form_name,
  p_freeze_status_cd,
  p_future_action_cd,
  p_member_cd,
  p_name,
  p_short_name,
  p_post_style_cd,
  p_post_txn_function,
  p_route_validated_txn_flag,
  p_prevent_approver_skip,
  p_workflow_enable_flag,
  p_enable_flag,
  p_timeout_days,
  p_object_version_number,
  p_consolidated_table_route_id ,
  p_business_group_id,
  p_setup_type_cd,
  p_master_table_route_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_tct_upd;

/
