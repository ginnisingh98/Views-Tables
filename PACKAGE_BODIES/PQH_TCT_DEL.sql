--------------------------------------------------------
--  DDL for Package Body PQH_TCT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCT_DEL" as
/* $Header: pqtctrhi.pkb 120.4.12000000.2 2007/04/19 12:48:04 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tct_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pqh_tct_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the pqh_transaction_categories row.
  --
  delete from pqh_transaction_categories
  where transaction_category_id = p_rec.transaction_category_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqh_tct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in pqh_tct_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(
p_effective_date in date,p_rec in pqh_tct_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    pqh_tct_rkd.after_delete
      (
  p_transaction_category_id       =>p_rec.transaction_category_id
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
 ,p_business_group_id_o    => pqh_tct_shd.g_old_rec.business_group_id
 ,p_setup_type_cd_o        => pqh_tct_shd.g_old_rec.setup_type_cd
 ,p_master_table_route_i_o =>pqh_tct_shd.g_old_rec.master_table_route_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_transaction_categories'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_rec	      in pqh_tct_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_tct_shd.lck
	(
	p_rec.transaction_category_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqh_tct_bus.delete_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_transaction_category_id            in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqh_tct_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.transaction_category_id:= p_transaction_category_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_tct_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_tct_del;

/
