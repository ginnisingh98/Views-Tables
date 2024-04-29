--------------------------------------------------------
--  DDL for Package Body PQH_WDT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WDT_DEL" as
/* $Header: pqwdtrhi.pkb 120.0.12000000.1 2007/01/17 00:29:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wdt_del.';  -- Global package name
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
Procedure delete_dml(p_rec in pqh_wdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the pqh_worksheet_details row.
  --
  delete from pqh_worksheet_details
  where worksheet_detail_id = p_rec.worksheet_detail_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqh_wdt_shd.constraint_error
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
Procedure pre_delete(p_rec in pqh_wdt_shd.g_rec_type) is
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
p_effective_date in date,p_rec in pqh_wdt_shd.g_rec_type) is
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
    pqh_wdt_rkd.after_delete
      (
  p_worksheet_detail_id           =>p_rec.worksheet_detail_id
 ,p_worksheet_id_o                =>pqh_wdt_shd.g_old_rec.worksheet_id
 ,p_organization_id_o             =>pqh_wdt_shd.g_old_rec.organization_id
 ,p_job_id_o                      =>pqh_wdt_shd.g_old_rec.job_id
 ,p_position_id_o                 =>pqh_wdt_shd.g_old_rec.position_id
 ,p_grade_id_o                    =>pqh_wdt_shd.g_old_rec.grade_id
 ,p_position_transaction_id_o     =>pqh_wdt_shd.g_old_rec.position_transaction_id
 ,p_budget_detail_id_o            =>pqh_wdt_shd.g_old_rec.budget_detail_id
 ,p_parent_worksheet_detail_id_o  =>pqh_wdt_shd.g_old_rec.parent_worksheet_detail_id
 ,p_user_id_o                     =>pqh_wdt_shd.g_old_rec.user_id
 ,p_action_cd_o                   =>pqh_wdt_shd.g_old_rec.action_cd
 ,p_budget_unit1_percent_o        =>pqh_wdt_shd.g_old_rec.budget_unit1_percent
 ,p_budget_unit1_value_o          =>pqh_wdt_shd.g_old_rec.budget_unit1_value
 ,p_budget_unit2_percent_o        =>pqh_wdt_shd.g_old_rec.budget_unit2_percent
 ,p_budget_unit2_value_o          =>pqh_wdt_shd.g_old_rec.budget_unit2_value
 ,p_budget_unit3_percent_o        =>pqh_wdt_shd.g_old_rec.budget_unit3_percent
 ,p_budget_unit3_value_o          =>pqh_wdt_shd.g_old_rec.budget_unit3_value
 ,p_object_version_number_o       =>pqh_wdt_shd.g_old_rec.object_version_number
 ,p_budget_unit1_value_type_cd_o  =>pqh_wdt_shd.g_old_rec.budget_unit1_value_type_cd
 ,p_budget_unit2_value_type_cd_o  =>pqh_wdt_shd.g_old_rec.budget_unit2_value_type_cd
 ,p_budget_unit3_value_type_cd_o  =>pqh_wdt_shd.g_old_rec.budget_unit3_value_type_cd
 ,p_status_o                      =>pqh_wdt_shd.g_old_rec.status
 ,p_budget_unit1_available_o      =>pqh_wdt_shd.g_old_rec.budget_unit1_available
 ,p_budget_unit2_available_o      =>pqh_wdt_shd.g_old_rec.budget_unit2_available
 ,p_budget_unit3_available_o      =>pqh_wdt_shd.g_old_rec.budget_unit3_available
 ,p_old_unit1_value_o             =>pqh_wdt_shd.g_old_rec.old_unit1_value
 ,p_old_unit2_value_o             =>pqh_wdt_shd.g_old_rec.old_unit2_value
 ,p_old_unit3_value_o             =>pqh_wdt_shd.g_old_rec.old_unit3_value
 ,p_defer_flag_o                  =>pqh_wdt_shd.g_old_rec.defer_flag
 ,p_propagation_method_o          =>pqh_wdt_shd.g_old_rec.propagation_method
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_worksheet_details'
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
  p_rec	      in pqh_wdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_wdt_shd.lck
	(
	p_rec.worksheet_detail_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqh_wdt_bus.delete_validate(p_rec
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
  p_worksheet_detail_id                in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqh_wdt_shd.g_rec_type;
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
  l_rec.worksheet_detail_id:= p_worksheet_detail_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_wdt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_wdt_del;

/
