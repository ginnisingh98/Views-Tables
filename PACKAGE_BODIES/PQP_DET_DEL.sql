--------------------------------------------------------
--  DDL for Package Body PQP_DET_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_DET_DEL" as
/* $Header: pqdetrhi.pkb 115.8 2003/02/17 22:14:03 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_det_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
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
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pqp_det_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_det_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pqp_analyzed_alien_details row.
  --
  delete from pqp_analyzed_alien_details
  where analyzed_data_details_id = p_rec.analyzed_data_details_id;
  --
  pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_det_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pqp_det_shd.g_rec_type) is
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
p_effective_date in date,p_rec in pqp_det_shd.g_rec_type) is
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
    pqp_det_rkd.after_delete
      (
  p_analyzed_data_details_id      =>p_rec.analyzed_data_details_id
 ,p_analyzed_data_id_o            =>pqp_det_shd.g_old_rec.analyzed_data_id
 ,p_income_code_o                 =>pqp_det_shd.g_old_rec.income_code
 ,p_withholding_rate_o            =>pqp_det_shd.g_old_rec.withholding_rate
 ,p_income_code_sub_type_o        =>pqp_det_shd.g_old_rec.income_code_sub_type
 ,p_exemption_code_o              =>pqp_det_shd.g_old_rec.exemption_code
 ,p_maximum_benefit_amount_o      =>pqp_det_shd.g_old_rec.maximum_benefit_amount
 ,p_retro_lose_ben_amt_flag_o     =>pqp_det_shd.g_old_rec.retro_lose_ben_amt_flag
 ,p_date_benefit_ends_o           =>pqp_det_shd.g_old_rec.date_benefit_ends
 ,p_retro_lose_ben_date_flag_o    =>pqp_det_shd.g_old_rec.retro_lose_ben_date_flag
 ,p_nra_exempt_from_ss_o          =>pqp_det_shd.g_old_rec.nra_exempt_from_ss
 ,p_nra_exempt_from_medicare_o    =>pqp_det_shd.g_old_rec.nra_exempt_from_medicare
 ,p_student_exempt_from_ss_o      =>pqp_det_shd.g_old_rec.student_exempt_from_ss
 ,p_student_exempt_from_medi_o    =>pqp_det_shd.g_old_rec.student_exempt_from_medicare
 ,p_addl_withholding_flag_o       =>pqp_det_shd.g_old_rec.addl_withholding_flag
 ,p_constant_addl_tax_o           =>pqp_det_shd.g_old_rec.constant_addl_tax
 ,p_addl_withholding_amt_o        =>pqp_det_shd.g_old_rec.addl_withholding_amt
 ,p_addl_wthldng_amt_period_ty_o  =>pqp_det_shd.g_old_rec.addl_wthldng_amt_period_type
 ,p_personal_exemption_o          =>pqp_det_shd.g_old_rec.personal_exemption
 ,p_addl_exemption_allowed_o      =>pqp_det_shd.g_old_rec.addl_exemption_allowed
 ,p_treaty_ben_allowed_flag_o     =>pqp_det_shd.g_old_rec.treaty_ben_allowed_flag
 ,p_treaty_benefits_start_date_o  =>pqp_det_shd.g_old_rec.treaty_benefits_start_date
 ,p_object_version_number_o       =>pqp_det_shd.g_old_rec.object_version_number
 ,p_retro_loss_notif_sent_o       =>pqp_det_shd.g_old_rec.retro_loss_notification_sent
 ,p_current_analysis_o            =>pqp_det_shd.g_old_rec.current_analysis
 ,p_forecast_income_code_o        =>pqp_det_shd.g_old_rec.forecast_income_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ANALYZED_ALIEN_DET'
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
  p_rec	      in pqp_det_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqp_det_shd.lck
	(
	p_rec.analyzed_data_details_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqp_det_bus.delete_validate(p_rec
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
  p_analyzed_data_details_id           in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqp_det_shd.g_rec_type;
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
  l_rec.analyzed_data_details_id:= p_analyzed_data_details_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the det_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqp_det_del;

/
