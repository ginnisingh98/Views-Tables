--------------------------------------------------------
--  DDL for Package Body PQH_BGT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BGT_DEL" as
/* $Header: pqbgtrhi.pkb 120.1 2005/09/21 03:11:10 hmehta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bgt_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
Procedure delete_dml(p_rec in pqh_bgt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the pqh_budgets row.
  --
  delete from pqh_budgets
  where budget_id = p_rec.budget_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqh_bgt_shd.constraint_error
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
Procedure pre_delete(p_rec in pqh_bgt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
 l_budgets_rec   pqh_budgets%ROWTYPE;

 cursor csr_budget(p_budget_id IN number) is
 select *
 from pqh_budgets
 where budget_id = p_budget_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
      OPEN csr_budget(p_budget_id =>  p_rec.budget_id);
        FETCH csr_budget INTO l_budgets_rec;
      CLOSE csr_budget;


  hr_utility.set_location('Status :'||l_budgets_rec.status, 6);

       IF NVL(l_budgets_rec.status,'X') = 'FROZEN' THEN
         --
         -- raise error as you cannot delete frozen budget
            hr_utility.set_message(8302,'PQH_FROZEN_BUDGET');
            hr_utility.raise_error;
         --
       ELSE
         --
         -- delete the record in pqh_budget_versions
            delete from pqh_budget_versions
            where budget_id = l_budgets_rec.budget_id;
         --
         -- delete the records from pqh_budget_gl_flex_maps
            delete from pqh_budget_gl_flex_maps
            where budget_id = l_budgets_rec.budget_id;
         --
         -- delete from pqh_bdgt_cmmtmnt_elmnts
            delete from pqh_bdgt_cmmtmnt_elmnts
            where  budget_id = l_budgets_rec.budget_id;
         --
       END IF;

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
p_effective_date in date,p_rec in pqh_bgt_shd.g_rec_type) is
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
    pqh_bgt_rkd.after_delete
      (
  p_budget_id                     =>p_rec.budget_id
 ,p_business_group_id_o           =>pqh_bgt_shd.g_old_rec.business_group_id
 ,p_start_organization_id_o       =>pqh_bgt_shd.g_old_rec.start_organization_id
 ,p_org_structure_version_id_o    =>pqh_bgt_shd.g_old_rec.org_structure_version_id
 ,p_budgeted_entity_cd_o          =>pqh_bgt_shd.g_old_rec.budgeted_entity_cd
 ,p_budget_style_cd_o             =>pqh_bgt_shd.g_old_rec.budget_style_cd
 ,p_budget_name_o                 =>pqh_bgt_shd.g_old_rec.budget_name
 ,p_period_set_name_o             =>pqh_bgt_shd.g_old_rec.period_set_name
 ,p_budget_start_date_o           =>pqh_bgt_shd.g_old_rec.budget_start_date
 ,p_budget_end_date_o             =>pqh_bgt_shd.g_old_rec.budget_end_date
 ,p_gl_budget_name_o              =>pqh_bgt_shd.g_old_rec.gl_budget_name
 ,P_psb_budget_flag_o             =>pqh_bgt_shd.g_old_rec.psb_budget_flag
 ,p_transfer_to_gl_flag_o         =>pqh_bgt_shd.g_old_rec.transfer_to_gl_flag
 ,p_transfer_to_grants_flag_o     =>pqh_bgt_shd.g_old_rec.transfer_to_grants_flag
 ,p_status_o                      =>pqh_bgt_shd.g_old_rec.status
 ,p_object_version_number_o       =>pqh_bgt_shd.g_old_rec.object_version_number
 ,p_budget_unit1_id_o             =>pqh_bgt_shd.g_old_rec.budget_unit1_id
 ,p_budget_unit2_id_o             =>pqh_bgt_shd.g_old_rec.budget_unit2_id
 ,p_budget_unit3_id_o             =>pqh_bgt_shd.g_old_rec.budget_unit3_id
 ,p_gl_set_of_books_id_o          =>pqh_bgt_shd.g_old_rec.gl_set_of_books_id
 ,p_budget_unit1_aggregate_o      =>pqh_bgt_shd.g_old_rec.budget_unit1_aggregate
 ,p_budget_unit2_aggregate_o      =>pqh_bgt_shd.g_old_rec.budget_unit2_aggregate
 ,p_budget_unit3_aggregate_o      =>pqh_bgt_shd.g_old_rec.budget_unit3_aggregate
 ,p_position_control_flag_o       =>pqh_bgt_shd.g_old_rec.position_control_flag
 ,p_valid_grade_reqd_flag_o       =>pqh_bgt_shd.g_old_rec.valid_grade_reqd_flag
 ,p_currency_code_o               =>pqh_bgt_shd.g_old_rec.currency_code
 ,p_dflt_budget_set_id_o          =>pqh_bgt_shd.g_old_rec.dflt_budget_set_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_budgets'
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
  p_rec	      in pqh_bgt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_bgt_shd.lck
	(
	p_rec.budget_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqh_bgt_bus.delete_validate(p_rec
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
  p_budget_id                          in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqh_bgt_shd.g_rec_type;
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
  l_rec.budget_id:= p_budget_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_bgt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_bgt_del;

/
