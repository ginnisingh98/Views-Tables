--------------------------------------------------------
--  DDL for Package Body PAY_STA_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_STA_DEL" as
/* $Header: pystarhi.pkb 120.0.12000000.3 2007/05/23 00:34:32 ppanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_sta_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
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
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      	     date,
       p_datetrack_mode        in            varchar2,
       p_validation_start_date in            date,
       p_validation_end_date   in            date) is
--
  l_proc      varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    pay_sta_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_us_emp_state_tax_rules_f
    where       emp_state_tax_rule_id = p_rec.emp_state_tax_rule_id
    and        effective_start_date = p_validation_start_date;
    --
    pay_sta_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    pay_sta_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_us_emp_state_tax_rules_f
    where        emp_state_tax_rule_id = p_rec.emp_state_tax_rule_id
    and        effective_start_date >= p_validation_start_date;
    --
    pay_sta_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pay_sta_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      	     date,
       p_datetrack_mode        in      	     varchar2,
       p_validation_start_date in            date,
       p_validation_end_date   in            date) is
--
  l_proc      varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec               => p_rec,
            p_effective_date        => p_effective_date,
            p_datetrack_mode        => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
            p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      	     date,
       p_datetrack_mode        in            varchar2,
       p_validation_start_date in            date,
       p_validation_end_date   in            date) is
--
  l_proc      varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := pay_sta_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pay_sta_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date,
       p_base_key_value         => p_rec.emp_state_tax_rule_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in            date,
       p_datetrack_mode        in            varchar2,
       p_validation_start_date in            date,
       p_validation_end_date   in            date) is
--
  l_proc      varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec                   => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
      (p_rec                   in pay_sta_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date) is
--
  l_proc      varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
 /*    pay_sta_rkd.after_delete
      (
  p_emp_state_tax_rule_id      =>p_rec.emp_state_tax_rule_id
 ,p_datetrack_mode             =>p_datetrack_mode
 ,p_effective_date             =>p_effective_date
 ,p_object_version_number      =>p_rec.object_version_number
 ,p_validation_start_date      =>p_validation_start_date
 ,p_validation_end_date        =>p_validation_end_date
 ,p_effective_start_date       =>p_rec.effective_start_date
 ,p_effective_end_date         =>p_rec.effective_end_date
 ,p_effective_start_date_o     =>pay_sta_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o       =>pay_sta_shd.g_old_rec.effective_end_date
 ,p_assignment_id_o            =>pay_sta_shd.g_old_rec.assignment_id
 ,p_state_code_o               =>pay_sta_shd.g_old_rec.state_code
 ,p_jurisdiction_code_o        =>pay_sta_shd.g_old_rec.jurisdiction_code
 ,p_business_group_id_o        =>pay_sta_shd.g_old_rec.business_group_id
 ,p_additional_wa_amount_o     =>pay_sta_shd.g_old_rec.additional_wa_amount
 ,p_filing_status_code_o       =>pay_sta_shd.g_old_rec.filing_status_code
 ,p_remainder_percent_o        =>pay_sta_shd.g_old_rec.remainder_percent
 ,p_secondary_wa_o             =>pay_sta_shd.g_old_rec.secondary_wa
 ,p_sit_additional_tax_o       =>pay_sta_shd.g_old_rec.sit_additional_tax
 ,p_sit_override_amount_o      =>pay_sta_shd.g_old_rec.sit_override_amount
 ,p_sit_override_rate_o        =>pay_sta_shd.g_old_rec.sit_override_rate
 ,p_withholding_allowances_o   =>pay_sta_shd.g_old_rec.withholding_allowances
 ,p_excessive_wa_reject_date_o =>pay_sta_shd.g_old_rec.excessive_wa_reject_date
 ,p_sdi_exempt_o               =>pay_sta_shd.g_old_rec.sdi_exempt
 ,p_sit_exempt_o               =>pay_sta_shd.g_old_rec.sit_exempt
 ,p_sit_optional_calc_ind_o    =>pay_sta_shd.g_old_rec.sit_optional_calc_ind
 ,p_state_non_resident_cert_o  =>pay_sta_shd.g_old_rec.state_non_resident_cert
 ,p_sui_exempt_o               =>pay_sta_shd.g_old_rec.sui_exempt
 ,p_wc_exempt_o                =>pay_sta_shd.g_old_rec.wc_exempt
 ,p_wage_exempt_o              =>pay_sta_shd.g_old_rec.wage_exempt
 ,p_sui_wage_base_override_amo_o =>
                            pay_sta_shd.g_old_rec.sui_wage_base_override_amount
 ,p_supp_tax_override_rate_o   =>pay_sta_shd.g_old_rec.supp_tax_override_rate
 ,p_object_version_number_o    =>pay_sta_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_US_EMP_STATE_TAX_RULES_F
        ,p_hook_type   => 'AD');
      --
 */
    null;
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
   p_rec                in out nocopy pay_sta_shd.g_rec_type
  ,p_effective_date     in            date
  ,p_datetrack_mode     in            varchar2
  ,p_delete_routine     in            varchar2   default null
  ) is
--
  l_proc                  varchar2(72) := g_package||'del';
  l_validation_start_date      date;
  l_validation_end_date        date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  pay_sta_shd.lck
      (p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id,
       p_object_version_number => p_rec.object_version_number,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  pay_sta_bus.delete_validate
      (p_rec                   => p_rec
      ,p_effective_date        => p_effective_date
      ,p_datetrack_mode        => p_datetrack_mode
      ,p_validation_start_date => l_validation_start_date
      ,p_validation_end_date   => l_validation_end_date
      ,p_delete_routine        => p_delete_routine
      );
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
--
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
   p_emp_state_tax_rule_id in     	 number
  ,p_effective_start_date  out    nocopy date
  ,p_effective_end_date    out    nocopy date
  ,p_object_version_number in out nocopy number
  ,p_effective_date        in     	 date
  ,p_datetrack_mode        in     	 varchar2
  ,p_delete_routine        in     	 varchar2   default null
  ) is
--
  l_rec            pay_sta_shd.g_rec_type;
  l_proc      varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.emp_state_tax_rule_id       := p_emp_state_tax_rule_id;
  l_rec.object_version_number       := p_object_version_number;
  --
  -- Having converted the arguments into the pay_sta_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode, p_delete_routine);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_sta_del;

/
