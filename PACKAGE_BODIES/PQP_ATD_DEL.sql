--------------------------------------------------------
--  DDL for Package Body PQP_ATD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ATD_DEL" as
/* $Header: pqatdrhi.pkb 115.10 2003/02/17 22:13:56 tmehra ship $ */

----------------------------------------------------------------------------
--|                     Private Global Definitions                           |
----------------------------------------------------------------------------

g_package  varchar2(33)        := '  pqp_atd_del.';  -- Global package name

----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pqp_atd_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'delete_dml';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_atd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pqp_alien_transaction_data row.
  --
  delete from pqp_alien_transaction_data
  where alien_transaction_id = p_rec.alien_transaction_id;
  --
  pqp_atd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqp_atd_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_atd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_atd_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;

----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------
Procedure pre_delete(p_rec in pqp_atd_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'pre_delete';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;

----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------
Procedure post_delete(
p_effective_date in date,p_rec in pqp_atd_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'post_delete';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    pqp_atd_rkd.after_delete
      (
  p_alien_transaction_id          =>p_rec.alien_transaction_id
 ,p_person_id_o                   =>pqp_atd_shd.g_old_rec.person_id
 ,p_data_source_type_o            =>pqp_atd_shd.g_old_rec.data_source_type
 ,p_tax_year_o                    =>pqp_atd_shd.g_old_rec.tax_year
 ,p_income_code_o                 =>pqp_atd_shd.g_old_rec.income_code
 ,p_withholding_rate_o            =>pqp_atd_shd.g_old_rec.withholding_rate
 ,p_income_code_sub_type_o        =>pqp_atd_shd.g_old_rec.income_code_sub_type
 ,p_exemption_code_o              =>pqp_atd_shd.g_old_rec.exemption_code
 ,p_maximum_benefit_amount_o      =>pqp_atd_shd.g_old_rec.maximum_benefit_amount
 ,p_retro_lose_ben_amt_flag_o     =>pqp_atd_shd.g_old_rec.retro_lose_ben_amt_flag
 ,p_date_benefit_ends_o           =>pqp_atd_shd.g_old_rec.date_benefit_ends
 ,p_retro_lose_ben_date_flag_o    =>pqp_atd_shd.g_old_rec.retro_lose_ben_date_flag
 ,p_current_residency_status_o    =>pqp_atd_shd.g_old_rec.current_residency_status
 ,p_nra_to_ra_date_o              =>pqp_atd_shd.g_old_rec.nra_to_ra_date
 ,p_target_departure_date_o       =>pqp_atd_shd.g_old_rec.target_departure_date
 ,p_tax_residence_country_code_o  =>pqp_atd_shd.g_old_rec.tax_residence_country_code
 ,p_treaty_info_update_date_o     =>pqp_atd_shd.g_old_rec.treaty_info_update_date
 ,p_nra_exempt_from_fica_o        =>pqp_atd_shd.g_old_rec.nra_exempt_from_fica
 ,p_student_exempt_from_fica_o    =>pqp_atd_shd.g_old_rec.student_exempt_from_fica
 ,p_addl_withholding_flag_o       =>pqp_atd_shd.g_old_rec.addl_withholding_flag
 ,p_addl_withholding_amt_o        =>pqp_atd_shd.g_old_rec.addl_withholding_amt
 ,p_addl_wthldng_amt_period_ty_o=>pqp_atd_shd.g_old_rec.addl_wthldng_amt_period_type
 ,p_personal_exemption_o          =>pqp_atd_shd.g_old_rec.personal_exemption
 ,p_addl_exemption_allowed_o      =>pqp_atd_shd.g_old_rec.addl_exemption_allowed
 ,p_number_of_days_in_usa_o       =>pqp_atd_shd.g_old_rec.number_of_days_in_usa
 ,p_wthldg_allow_eligible_flag_o  =>pqp_atd_shd.g_old_rec.wthldg_allow_eligible_flag
 ,p_treaty_ben_allowed_flag_o     =>pqp_atd_shd.g_old_rec.treaty_ben_allowed_flag
 ,p_treaty_benefits_start_date_o  =>pqp_atd_shd.g_old_rec.treaty_benefits_start_date
 ,p_ra_effective_date_o           =>pqp_atd_shd.g_old_rec.ra_effective_date
 ,p_state_code_o                  =>pqp_atd_shd.g_old_rec.state_code
 ,p_state_honors_treaty_flag_o    =>pqp_atd_shd.g_old_rec.state_honors_treaty_flag
 ,p_ytd_payments_o                =>pqp_atd_shd.g_old_rec.ytd_payments
 ,p_ytd_w2_payments_o             =>pqp_atd_shd.g_old_rec.ytd_w2_payments
 ,p_ytd_w2_withholding_o          =>pqp_atd_shd.g_old_rec.ytd_w2_withholding
 ,p_ytd_withholding_allowance_o   =>pqp_atd_shd.g_old_rec.ytd_withholding_allowance
 ,p_ytd_treaty_payments_o         =>pqp_atd_shd.g_old_rec.ytd_treaty_payments
 ,p_ytd_treaty_withheld_amt_o     =>pqp_atd_shd.g_old_rec.ytd_treaty_withheld_amt
 ,p_record_source_o               =>pqp_atd_shd.g_old_rec.record_source
 ,p_visa_type_o                   =>pqp_atd_shd.g_old_rec.visa_type
 ,p_j_sub_type_o                  =>pqp_atd_shd.g_old_rec.j_sub_type
 ,p_primary_activity_o            =>pqp_atd_shd.g_old_rec.primary_activity
 ,p_non_us_country_code_o         =>pqp_atd_shd.g_old_rec.non_us_country_code
 ,p_citizenship_country_code_o    =>pqp_atd_shd.g_old_rec.citizenship_country_code
 ,p_constant_addl_tax_o           =>pqp_atd_shd.g_old_rec.constant_addl_tax
 ,p_date_8233_signed_o            =>pqp_atd_shd.g_old_rec.date_8233_signed
 ,p_date_w4_signed_o              =>pqp_atd_shd.g_old_rec.date_w4_signed
 ,p_error_indicator_o             =>pqp_atd_shd.g_old_rec.error_indicator
 ,p_prev_er_treaty_benefit_amt_o  =>pqp_atd_shd.g_old_rec.prev_er_treaty_benefit_amt
 ,p_error_text_o                  =>pqp_atd_shd.g_old_rec.error_text
 ,p_object_version_number_o       =>pqp_atd_shd.g_old_rec.object_version_number
 ,p_current_analysis_o            =>pqp_atd_shd.g_old_rec.current_analysis
 ,p_forecast_income_code_o        =>pqp_atd_shd.g_old_rec.forecast_income_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ALIEN_TRANS_DATA'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;

----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_rec              in pqp_atd_shd.g_rec_type
  ) is

  l_proc  varchar2(72) := g_package||'del';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqp_atd_shd.lck
        (
        p_rec.alien_transaction_id,
        p_rec.object_version_number
        );
  --
  -- Call the supporting delete validate operation
  --
  pqp_atd_bus.delete_validate(p_rec
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

----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_alien_transaction_id               in number,
  p_object_version_number              in number
  ) is

  l_rec          pqp_atd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.alien_transaction_id:= p_alien_transaction_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqp_atd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END del;

END pqp_atd_del;

/
