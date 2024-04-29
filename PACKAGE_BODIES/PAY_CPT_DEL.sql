--------------------------------------------------------
--  DDL for Package Body PAY_CPT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CPT_DEL" as
/* $Header: pycprrhi.pkb 120.1.12010000.3 2008/08/06 07:04:33 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cpt_del.';  -- Global package name
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
	(p_rec 			 in out nocopy pay_cpt_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    pay_cpt_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_ca_emp_prov_tax_info_f
    where       emp_province_tax_inf_id = p_rec.emp_province_tax_inf_id
    and	  effective_start_date = p_validation_start_date;
    --
    pay_cpt_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    pay_cpt_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_ca_emp_prov_tax_info_f
    where        emp_province_tax_inf_id = p_rec.emp_province_tax_inf_id
    and	  effective_start_date >= p_validation_start_date;
    --
    pay_cpt_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pay_cpt_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy pay_cpt_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
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
	(p_rec 			 in out nocopy pay_cpt_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := pay_cpt_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pay_cpt_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date,
       p_base_key_value	        => p_rec.emp_province_tax_inf_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date,
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
	(p_rec 			 in out nocopy pay_cpt_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
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
	(p_rec 			 in pay_cpt_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    pay_cpt_rkd.after_delete
      (
  p_emp_province_tax_inf_id       =>p_rec.emp_province_tax_inf_id
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_effective_start_date_o        =>pay_cpt_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>pay_cpt_shd.g_old_rec.effective_end_date
 ,p_legislation_code_o            =>pay_cpt_shd.g_old_rec.legislation_code
 ,p_assignment_id_o               =>pay_cpt_shd.g_old_rec.assignment_id
 ,p_business_group_id_o           =>pay_cpt_shd.g_old_rec.business_group_id
 ,p_province_code_o               =>pay_cpt_shd.g_old_rec.province_code
 ,p_jurisdiction_code_o           =>pay_cpt_shd.g_old_rec.jurisdiction_code
 ,p_tax_credit_amount_o           =>pay_cpt_shd.g_old_rec.tax_credit_amount
 ,p_basic_exemption_flag_o        =>pay_cpt_shd.g_old_rec.basic_exemption_flag
 ,p_deduction_code_o              =>pay_cpt_shd.g_old_rec.deduction_code
 ,p_extra_info_not_provided_o     =>pay_cpt_shd.g_old_rec.extra_info_not_provided
 ,p_marriage_status_o             =>pay_cpt_shd.g_old_rec.marriage_status
 ,p_no_of_infirm_dependants_o     =>pay_cpt_shd.g_old_rec.no_of_infirm_dependants
 ,p_non_resident_status_o         =>pay_cpt_shd.g_old_rec.non_resident_status
 ,p_disability_status_o           =>pay_cpt_shd.g_old_rec.disability_status
 ,p_no_of_dependants_o            =>pay_cpt_shd.g_old_rec.no_of_dependants
 ,p_annual_dedn_o                 =>pay_cpt_shd.g_old_rec.annual_dedn
 ,p_total_expense_by_commissio_o =>pay_cpt_shd.g_old_rec.total_expense_by_commission
 ,p_total_remnrtn_by_commissio_o =>pay_cpt_shd.g_old_rec.total_remnrtn_by_commission
 ,p_prescribed_zone_dedn_amt_o    =>pay_cpt_shd.g_old_rec.prescribed_zone_dedn_amt
 ,p_additional_tax_o              =>pay_cpt_shd.g_old_rec.additional_tax
 ,p_prov_override_rate_o          =>pay_cpt_shd.g_old_rec.prov_override_rate
 ,p_prov_override_amount_o        =>pay_cpt_shd.g_old_rec.prov_override_amount
 ,p_prov_exempt_flag_o            =>pay_cpt_shd.g_old_rec.prov_exempt_flag
 ,p_pmed_exempt_flag_o            =>pay_cpt_shd.g_old_rec.pmed_exempt_flag
 ,p_wc_exempt_flag_o              =>pay_cpt_shd.g_old_rec.wc_exempt_flag
 ,p_qpp_exempt_flag_o             =>pay_cpt_shd.g_old_rec.qpp_exempt_flag
 ,p_tax_calc_method_o             =>pay_cpt_shd.g_old_rec.tax_calc_method
 ,p_other_tax_credit_o            =>pay_cpt_shd.g_old_rec.other_tax_credit
 ,p_ca_tax_information_categor_o =>pay_cpt_shd.g_old_rec.ca_tax_information_category
 ,p_ca_tax_information1_o         =>pay_cpt_shd.g_old_rec.ca_tax_information1
 ,p_ca_tax_information2_o         =>pay_cpt_shd.g_old_rec.ca_tax_information2
 ,p_ca_tax_information3_o         =>pay_cpt_shd.g_old_rec.ca_tax_information3
 ,p_ca_tax_information4_o         =>pay_cpt_shd.g_old_rec.ca_tax_information4
 ,p_ca_tax_information5_o         =>pay_cpt_shd.g_old_rec.ca_tax_information5
 ,p_ca_tax_information6_o         =>pay_cpt_shd.g_old_rec.ca_tax_information6
 ,p_ca_tax_information7_o         =>pay_cpt_shd.g_old_rec.ca_tax_information7
 ,p_ca_tax_information8_o         =>pay_cpt_shd.g_old_rec.ca_tax_information8
 ,p_ca_tax_information9_o         =>pay_cpt_shd.g_old_rec.ca_tax_information9
 ,p_ca_tax_information10_o        =>pay_cpt_shd.g_old_rec.ca_tax_information10
 ,p_ca_tax_information11_o        =>pay_cpt_shd.g_old_rec.ca_tax_information11
 ,p_ca_tax_information12_o        =>pay_cpt_shd.g_old_rec.ca_tax_information12
 ,p_ca_tax_information13_o        =>pay_cpt_shd.g_old_rec.ca_tax_information13
 ,p_ca_tax_information14_o        =>pay_cpt_shd.g_old_rec.ca_tax_information14
 ,p_ca_tax_information15_o        =>pay_cpt_shd.g_old_rec.ca_tax_information15
 ,p_ca_tax_information16_o        =>pay_cpt_shd.g_old_rec.ca_tax_information16
 ,p_ca_tax_information17_o        =>pay_cpt_shd.g_old_rec.ca_tax_information17
 ,p_ca_tax_information18_o        =>pay_cpt_shd.g_old_rec.ca_tax_information18
 ,p_ca_tax_information19_o        =>pay_cpt_shd.g_old_rec.ca_tax_information19
 ,p_ca_tax_information20_o        =>pay_cpt_shd.g_old_rec.ca_tax_information20
 ,p_ca_tax_information21_o        =>pay_cpt_shd.g_old_rec.ca_tax_information21
 ,p_ca_tax_information22_o        =>pay_cpt_shd.g_old_rec.ca_tax_information22
 ,p_ca_tax_information23_o        =>pay_cpt_shd.g_old_rec.ca_tax_information23
 ,p_ca_tax_information24_o        =>pay_cpt_shd.g_old_rec.ca_tax_information24
 ,p_ca_tax_information25_o        =>pay_cpt_shd.g_old_rec.ca_tax_information25
 ,p_ca_tax_information26_o        =>pay_cpt_shd.g_old_rec.ca_tax_information26
 ,p_ca_tax_information27_o        =>pay_cpt_shd.g_old_rec.ca_tax_information27
 ,p_ca_tax_information28_o        =>pay_cpt_shd.g_old_rec.ca_tax_information28
 ,p_ca_tax_information29_o        =>pay_cpt_shd.g_old_rec.ca_tax_information29
 ,p_ca_tax_information30_o        =>pay_cpt_shd.g_old_rec.ca_tax_information30
 ,p_object_version_number_o       =>pay_cpt_shd.g_old_rec.object_version_number
 ,p_prov_lsp_amount_o             =>pay_cpt_shd.g_old_rec.prov_lsp_amount
 ,p_ppip_exempt_flag_o             =>pay_cpt_shd.g_old_rec.ppip_exempt_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_ca_emp_prov_tax_info_f'
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
  p_rec			in out 	nocopy pay_cpt_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'del';
  l_validation_start_date	date;
  l_validation_end_date		date;
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
  pay_cpt_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_emp_province_tax_inf_id	 => p_rec.emp_province_tax_inf_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  pay_cpt_bus.delete_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
/*
  post_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
*/
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_emp_province_tax_inf_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2
  ) is
--
  l_rec		pay_cpt_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.emp_province_tax_inf_id		:= p_emp_province_tax_inf_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the pay_cpt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode);
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
end pay_cpt_del;

/
