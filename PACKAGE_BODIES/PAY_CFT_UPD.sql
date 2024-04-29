--------------------------------------------------------
--  DDL for Package Body PAY_CFT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CFT_UPD" as
/* $Header: pycatrhi.pkb 120.1 2005/10/05 06:44:36 saurgupt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cft_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
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
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
	(p_rec 			 in out nocopy pay_cft_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
	  (p_base_table_name	=> 'pay_ca_emp_fed_tax_info_f',
	   p_base_key_column	=> 'emp_fed_tax_inf_id',
	   p_base_key_value	=> p_rec.emp_fed_tax_inf_id);
    --
    pay_cft_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the pay_ca_emp_fed_tax_info_f Row
    --
    update  pay_ca_emp_fed_tax_info_f
    set
        emp_fed_tax_inf_id              = p_rec.emp_fed_tax_inf_id,
    legislation_code                = p_rec.legislation_code,
    assignment_id                   = p_rec.assignment_id,
    business_group_id               = p_rec.business_group_id,
    employment_province             = p_rec.employment_province,
    tax_credit_amount               = p_rec.tax_credit_amount,
    claim_code                      = p_rec.claim_code,
    basic_exemption_flag            = p_rec.basic_exemption_flag,
    additional_tax                  = p_rec.additional_tax,
    annual_dedn                     = p_rec.annual_dedn,
    total_expense_by_commission     = p_rec.total_expense_by_commission,
    total_remnrtn_by_commission     = p_rec.total_remnrtn_by_commission,
    prescribed_zone_dedn_amt        = p_rec.prescribed_zone_dedn_amt,
    other_fedtax_credits            = p_rec.other_fedtax_credits,
    cpp_qpp_exempt_flag             = p_rec.cpp_qpp_exempt_flag,
    fed_exempt_flag                 = p_rec.fed_exempt_flag,
    ei_exempt_flag                  = p_rec.ei_exempt_flag,
    tax_calc_method                 = p_rec.tax_calc_method,
    fed_override_amount             = p_rec.fed_override_amount,
    fed_override_rate               = p_rec.fed_override_rate,
    ca_tax_information_category     = p_rec.ca_tax_information_category,
    ca_tax_information1             = p_rec.ca_tax_information1,
    ca_tax_information2             = p_rec.ca_tax_information2,
    ca_tax_information3             = p_rec.ca_tax_information3,
    ca_tax_information4             = p_rec.ca_tax_information4,
    ca_tax_information5             = p_rec.ca_tax_information5,
    ca_tax_information6             = p_rec.ca_tax_information6,
    ca_tax_information7             = p_rec.ca_tax_information7,
    ca_tax_information8             = p_rec.ca_tax_information8,
    ca_tax_information9             = p_rec.ca_tax_information9,
    ca_tax_information10            = p_rec.ca_tax_information10,
    ca_tax_information11            = p_rec.ca_tax_information11,
    ca_tax_information12            = p_rec.ca_tax_information12,
    ca_tax_information13            = p_rec.ca_tax_information13,
    ca_tax_information14            = p_rec.ca_tax_information14,
    ca_tax_information15            = p_rec.ca_tax_information15,
    ca_tax_information16            = p_rec.ca_tax_information16,
    ca_tax_information17            = p_rec.ca_tax_information17,
    ca_tax_information18            = p_rec.ca_tax_information18,
    ca_tax_information19            = p_rec.ca_tax_information19,
    ca_tax_information20            = p_rec.ca_tax_information20,
    ca_tax_information21            = p_rec.ca_tax_information21,
    ca_tax_information22            = p_rec.ca_tax_information22,
    ca_tax_information23            = p_rec.ca_tax_information23,
    ca_tax_information24            = p_rec.ca_tax_information24,
    ca_tax_information25            = p_rec.ca_tax_information25,
    ca_tax_information26            = p_rec.ca_tax_information26,
    ca_tax_information27            = p_rec.ca_tax_information27,
    ca_tax_information28            = p_rec.ca_tax_information28,
    ca_tax_information29            = p_rec.ca_tax_information29,
    ca_tax_information30            = p_rec.ca_tax_information30,
    object_version_number           = p_rec.object_version_number,
    fed_lsf_amount          	    = p_rec.fed_lsf_amount
    where   emp_fed_tax_inf_id = p_rec.emp_fed_tax_inf_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    pay_cft_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_cft_shd.g_api_dml := false;   -- Unset the api dml status
    pay_cft_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_cft_shd.g_api_dml := false;   -- Unset the api dml status
    pay_cft_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_cft_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
	(p_rec 			 in out nocopy pay_cft_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--	the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
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
Procedure dt_pre_update
	(p_rec 			 in out	nocopy pay_cft_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    pay_cft_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.emp_fed_tax_inf_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      pay_cft_del.delete_dml
        (p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => p_validation_start_date,
	 p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    pay_cft_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date		=> p_effective_date,
       p_datetrack_mode		=> p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
	(p_rec 			 in out	nocopy pay_cft_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
Procedure post_update
	(p_rec 			 in pay_cft_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --

  begin
    --
    pay_cft_rku.after_update
      (
  p_emp_fed_tax_inf_id            =>p_rec.emp_fed_tax_inf_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_legislation_code              =>p_rec.legislation_code
 ,p_assignment_id                 =>p_rec.assignment_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_employment_province           =>p_rec.employment_province
 ,p_tax_credit_amount             =>p_rec.tax_credit_amount
 ,p_claim_code                    =>p_rec.claim_code
 ,p_basic_exemption_flag          =>p_rec.basic_exemption_flag
 ,p_additional_tax                =>p_rec.additional_tax
 ,p_annual_dedn                   =>p_rec.annual_dedn
 ,p_total_expense_by_commission   =>p_rec.total_expense_by_commission
 ,p_total_remnrtn_by_commission   =>p_rec.total_remnrtn_by_commission
 ,p_prescribed_zone_dedn_amt      =>p_rec.prescribed_zone_dedn_amt
 ,p_other_fedtax_credits          =>p_rec.other_fedtax_credits
 ,p_cpp_qpp_exempt_flag           =>p_rec.cpp_qpp_exempt_flag
 ,p_fed_exempt_flag               =>p_rec.fed_exempt_flag
 ,p_ei_exempt_flag                =>p_rec.ei_exempt_flag
 ,p_tax_calc_method               =>p_rec.tax_calc_method
 ,p_fed_override_amount           =>p_rec.fed_override_amount
 ,p_fed_override_rate             =>p_rec.fed_override_rate
 ,p_ca_tax_information_category   =>p_rec.ca_tax_information_category
 ,p_ca_tax_information1           =>p_rec.ca_tax_information1
 ,p_ca_tax_information2           =>p_rec.ca_tax_information2
 ,p_ca_tax_information3           =>p_rec.ca_tax_information3
 ,p_ca_tax_information4           =>p_rec.ca_tax_information4
 ,p_ca_tax_information5           =>p_rec.ca_tax_information5
 ,p_ca_tax_information6           =>p_rec.ca_tax_information6
 ,p_ca_tax_information7           =>p_rec.ca_tax_information7
 ,p_ca_tax_information8           =>p_rec.ca_tax_information8
 ,p_ca_tax_information9           =>p_rec.ca_tax_information9
 ,p_ca_tax_information10          =>p_rec.ca_tax_information10
 ,p_ca_tax_information11          =>p_rec.ca_tax_information11
 ,p_ca_tax_information12          =>p_rec.ca_tax_information12
 ,p_ca_tax_information13          =>p_rec.ca_tax_information13
 ,p_ca_tax_information14          =>p_rec.ca_tax_information14
 ,p_ca_tax_information15          =>p_rec.ca_tax_information15
 ,p_ca_tax_information16          =>p_rec.ca_tax_information16
 ,p_ca_tax_information17          =>p_rec.ca_tax_information17
 ,p_ca_tax_information18          =>p_rec.ca_tax_information18
 ,p_ca_tax_information19          =>p_rec.ca_tax_information19
 ,p_ca_tax_information20          =>p_rec.ca_tax_information20
 ,p_ca_tax_information21          =>p_rec.ca_tax_information21
 ,p_ca_tax_information22          =>p_rec.ca_tax_information22
 ,p_ca_tax_information23          =>p_rec.ca_tax_information23
 ,p_ca_tax_information24          =>p_rec.ca_tax_information24
 ,p_ca_tax_information25          =>p_rec.ca_tax_information25
 ,p_ca_tax_information26          =>p_rec.ca_tax_information26
 ,p_ca_tax_information27          =>p_rec.ca_tax_information27
 ,p_ca_tax_information28          =>p_rec.ca_tax_information28
 ,p_ca_tax_information29          =>p_rec.ca_tax_information29
 ,p_ca_tax_information30          =>p_rec.ca_tax_information30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_fed_lsf_amount         	  =>p_rec.fed_lsf_amount
 ,p_effective_date                =>p_effective_date
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date_o        =>pay_cft_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>pay_cft_shd.g_old_rec.effective_end_date
 ,p_legislation_code_o            =>pay_cft_shd.g_old_rec.legislation_code
 ,p_assignment_id_o               =>pay_cft_shd.g_old_rec.assignment_id
 ,p_business_group_id_o           =>pay_cft_shd.g_old_rec.business_group_id
 ,p_employment_province_o         =>pay_cft_shd.g_old_rec.employment_province
 ,p_tax_credit_amount_o           =>pay_cft_shd.g_old_rec.tax_credit_amount
 ,p_claim_code_o                  =>pay_cft_shd.g_old_rec.claim_code
 ,p_basic_exemption_flag_o        =>pay_cft_shd.g_old_rec.basic_exemption_flag
 ,p_additional_tax_o              =>pay_cft_shd.g_old_rec.additional_tax
 ,p_annual_dedn_o                 =>pay_cft_shd.g_old_rec.annual_dedn
 ,p_total_expense_by_commissio_o =>pay_cft_shd.g_old_rec.total_expense_by_commission
 ,p_total_remnrtn_by_commissio_o =>pay_cft_shd.g_old_rec.total_remnrtn_by_commission
 ,p_prescribed_zone_dedn_amt_o    =>pay_cft_shd.g_old_rec.prescribed_zone_dedn_amt
 ,p_other_fedtax_credits_o        =>pay_cft_shd.g_old_rec.other_fedtax_credits
 ,p_cpp_qpp_exempt_flag_o         =>pay_cft_shd.g_old_rec.cpp_qpp_exempt_flag
 ,p_fed_exempt_flag_o             =>pay_cft_shd.g_old_rec.fed_exempt_flag
 ,p_ei_exempt_flag_o              =>pay_cft_shd.g_old_rec.ei_exempt_flag
 ,p_tax_calc_method_o             =>pay_cft_shd.g_old_rec.tax_calc_method
 ,p_fed_override_amount_o         =>pay_cft_shd.g_old_rec.fed_override_amount
 ,p_fed_override_rate_o           =>pay_cft_shd.g_old_rec.fed_override_rate
 ,p_ca_tax_information_categor_o =>pay_cft_shd.g_old_rec.ca_tax_information_category
 ,p_ca_tax_information1_o         =>pay_cft_shd.g_old_rec.ca_tax_information1
 ,p_ca_tax_information2_o         =>pay_cft_shd.g_old_rec.ca_tax_information2
 ,p_ca_tax_information3_o         =>pay_cft_shd.g_old_rec.ca_tax_information3
 ,p_ca_tax_information4_o         =>pay_cft_shd.g_old_rec.ca_tax_information4
 ,p_ca_tax_information5_o         =>pay_cft_shd.g_old_rec.ca_tax_information5
 ,p_ca_tax_information6_o         =>pay_cft_shd.g_old_rec.ca_tax_information6
 ,p_ca_tax_information7_o         =>pay_cft_shd.g_old_rec.ca_tax_information7
 ,p_ca_tax_information8_o         =>pay_cft_shd.g_old_rec.ca_tax_information8
 ,p_ca_tax_information9_o         =>pay_cft_shd.g_old_rec.ca_tax_information9
 ,p_ca_tax_information10_o        =>pay_cft_shd.g_old_rec.ca_tax_information10
 ,p_ca_tax_information11_o        =>pay_cft_shd.g_old_rec.ca_tax_information11
 ,p_ca_tax_information12_o        =>pay_cft_shd.g_old_rec.ca_tax_information12
 ,p_ca_tax_information13_o        =>pay_cft_shd.g_old_rec.ca_tax_information13
 ,p_ca_tax_information14_o        =>pay_cft_shd.g_old_rec.ca_tax_information14
 ,p_ca_tax_information15_o        =>pay_cft_shd.g_old_rec.ca_tax_information15
 ,p_ca_tax_information16_o        =>pay_cft_shd.g_old_rec.ca_tax_information16
 ,p_ca_tax_information17_o        =>pay_cft_shd.g_old_rec.ca_tax_information17
 ,p_ca_tax_information18_o        =>pay_cft_shd.g_old_rec.ca_tax_information18
 ,p_ca_tax_information19_o        =>pay_cft_shd.g_old_rec.ca_tax_information19
 ,p_ca_tax_information20_o        =>pay_cft_shd.g_old_rec.ca_tax_information20
 ,p_ca_tax_information21_o        =>pay_cft_shd.g_old_rec.ca_tax_information21
 ,p_ca_tax_information22_o        =>pay_cft_shd.g_old_rec.ca_tax_information22
 ,p_ca_tax_information23_o        =>pay_cft_shd.g_old_rec.ca_tax_information23
 ,p_ca_tax_information24_o        =>pay_cft_shd.g_old_rec.ca_tax_information24
 ,p_ca_tax_information25_o        =>pay_cft_shd.g_old_rec.ca_tax_information25
 ,p_ca_tax_information26_o        =>pay_cft_shd.g_old_rec.ca_tax_information26
 ,p_ca_tax_information27_o        =>pay_cft_shd.g_old_rec.ca_tax_information27
 ,p_ca_tax_information28_o        =>pay_cft_shd.g_old_rec.ca_tax_information28
 ,p_ca_tax_information29_o        =>pay_cft_shd.g_old_rec.ca_tax_information29
 ,p_ca_tax_information30_o        =>pay_cft_shd.g_old_rec.ca_tax_information30
 ,p_object_version_number_o       =>pay_cft_shd.g_old_rec.object_version_number
 ,p_fed_lsf_amount_o         	  =>pay_cft_shd.g_old_rec.fed_lsf_amount
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_ca_emp_fed_tax_info_f'
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
Procedure convert_defs(p_rec in out nocopy pay_cft_shd.g_rec_type) is
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
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_cft_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pay_cft_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_cft_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.employment_province = hr_api.g_varchar2) then
    p_rec.employment_province :=
    pay_cft_shd.g_old_rec.employment_province;
  End If;
  If (p_rec.tax_credit_amount = hr_api.g_number) then
    p_rec.tax_credit_amount :=
    pay_cft_shd.g_old_rec.tax_credit_amount;
  End If;
  If (p_rec.claim_code = hr_api.g_varchar2) then
    p_rec.claim_code :=
    pay_cft_shd.g_old_rec.claim_code;
  End If;
  If (p_rec.basic_exemption_flag = hr_api.g_varchar2) then
    p_rec.basic_exemption_flag :=
    pay_cft_shd.g_old_rec.basic_exemption_flag;
  End If;
  If (p_rec.additional_tax = hr_api.g_number) then
    p_rec.additional_tax :=
    pay_cft_shd.g_old_rec.additional_tax;
  End If;
  If (p_rec.annual_dedn = hr_api.g_number) then
    p_rec.annual_dedn :=
    pay_cft_shd.g_old_rec.annual_dedn;
  End If;
  If (p_rec.total_expense_by_commission = hr_api.g_number) then
    p_rec.total_expense_by_commission :=
    pay_cft_shd.g_old_rec.total_expense_by_commission;
  End If;
  If (p_rec.total_remnrtn_by_commission = hr_api.g_number) then
    p_rec.total_remnrtn_by_commission :=
    pay_cft_shd.g_old_rec.total_remnrtn_by_commission;
  End If;
  If (p_rec.prescribed_zone_dedn_amt = hr_api.g_number) then
    p_rec.prescribed_zone_dedn_amt :=
    pay_cft_shd.g_old_rec.prescribed_zone_dedn_amt;
  End If;
  If (p_rec.other_fedtax_credits = hr_api.g_varchar2) then
    p_rec.other_fedtax_credits :=
    pay_cft_shd.g_old_rec.other_fedtax_credits;
  End If;
  If (p_rec.cpp_qpp_exempt_flag = hr_api.g_varchar2) then
    p_rec.cpp_qpp_exempt_flag :=
    pay_cft_shd.g_old_rec.cpp_qpp_exempt_flag;
  End If;
  If (p_rec.fed_exempt_flag = hr_api.g_varchar2) then
    p_rec.fed_exempt_flag :=
    pay_cft_shd.g_old_rec.fed_exempt_flag;
  End If;
  If (p_rec.ei_exempt_flag = hr_api.g_varchar2) then
    p_rec.ei_exempt_flag :=
    pay_cft_shd.g_old_rec.ei_exempt_flag;
  End If;
  If (p_rec.tax_calc_method = hr_api.g_varchar2) then
    p_rec.tax_calc_method :=
    pay_cft_shd.g_old_rec.tax_calc_method;
  End If;
  If (p_rec.fed_override_amount = hr_api.g_number) then
    p_rec.fed_override_amount :=
    pay_cft_shd.g_old_rec.fed_override_amount;
  End If;
  If (p_rec.fed_override_rate = hr_api.g_number) then
    p_rec.fed_override_rate :=
    pay_cft_shd.g_old_rec.fed_override_rate;
  End If;
  If (p_rec.ca_tax_information_category = hr_api.g_varchar2) then
    p_rec.ca_tax_information_category :=
    pay_cft_shd.g_old_rec.ca_tax_information_category;
  End If;
  If (p_rec.ca_tax_information1 = hr_api.g_varchar2) then
    p_rec.ca_tax_information1 :=
    pay_cft_shd.g_old_rec.ca_tax_information1;
  End If;
  If (p_rec.ca_tax_information2 = hr_api.g_varchar2) then
    p_rec.ca_tax_information2 :=
    pay_cft_shd.g_old_rec.ca_tax_information2;
  End If;
  If (p_rec.ca_tax_information3 = hr_api.g_varchar2) then
    p_rec.ca_tax_information3 :=
    pay_cft_shd.g_old_rec.ca_tax_information3;
  End If;
  If (p_rec.ca_tax_information4 = hr_api.g_varchar2) then
    p_rec.ca_tax_information4 :=
    pay_cft_shd.g_old_rec.ca_tax_information4;
  End If;
  If (p_rec.ca_tax_information5 = hr_api.g_varchar2) then
    p_rec.ca_tax_information5 :=
    pay_cft_shd.g_old_rec.ca_tax_information5;
  End If;
  If (p_rec.ca_tax_information6 = hr_api.g_varchar2) then
    p_rec.ca_tax_information6 :=
    pay_cft_shd.g_old_rec.ca_tax_information6;
  End If;
  If (p_rec.ca_tax_information7 = hr_api.g_varchar2) then
    p_rec.ca_tax_information7 :=
    pay_cft_shd.g_old_rec.ca_tax_information7;
  End If;
  If (p_rec.ca_tax_information8 = hr_api.g_varchar2) then
    p_rec.ca_tax_information8 :=
    pay_cft_shd.g_old_rec.ca_tax_information8;
  End If;
  If (p_rec.ca_tax_information9 = hr_api.g_varchar2) then
    p_rec.ca_tax_information9 :=
    pay_cft_shd.g_old_rec.ca_tax_information9;
  End If;
  If (p_rec.ca_tax_information10 = hr_api.g_varchar2) then
    p_rec.ca_tax_information10 :=
    pay_cft_shd.g_old_rec.ca_tax_information10;
  End If;
  If (p_rec.ca_tax_information11 = hr_api.g_varchar2) then
    p_rec.ca_tax_information11 :=
    pay_cft_shd.g_old_rec.ca_tax_information11;
  End If;
  If (p_rec.ca_tax_information12 = hr_api.g_varchar2) then
    p_rec.ca_tax_information12 :=
    pay_cft_shd.g_old_rec.ca_tax_information12;
  End If;
  If (p_rec.ca_tax_information13 = hr_api.g_varchar2) then
    p_rec.ca_tax_information13 :=
    pay_cft_shd.g_old_rec.ca_tax_information13;
  End If;
  If (p_rec.ca_tax_information14 = hr_api.g_varchar2) then
    p_rec.ca_tax_information14 :=
    pay_cft_shd.g_old_rec.ca_tax_information14;
  End If;
  If (p_rec.ca_tax_information15 = hr_api.g_varchar2) then
    p_rec.ca_tax_information15 :=
    pay_cft_shd.g_old_rec.ca_tax_information15;
  End If;
  If (p_rec.ca_tax_information16 = hr_api.g_varchar2) then
    p_rec.ca_tax_information16 :=
    pay_cft_shd.g_old_rec.ca_tax_information16;
  End If;
  If (p_rec.ca_tax_information17 = hr_api.g_varchar2) then
    p_rec.ca_tax_information17 :=
    pay_cft_shd.g_old_rec.ca_tax_information17;
  End If;
  If (p_rec.ca_tax_information18 = hr_api.g_varchar2) then
    p_rec.ca_tax_information18 :=
    pay_cft_shd.g_old_rec.ca_tax_information18;
  End If;
  If (p_rec.ca_tax_information19 = hr_api.g_varchar2) then
    p_rec.ca_tax_information19 :=
    pay_cft_shd.g_old_rec.ca_tax_information19;
  End If;
  If (p_rec.ca_tax_information20 = hr_api.g_varchar2) then
    p_rec.ca_tax_information20 :=
    pay_cft_shd.g_old_rec.ca_tax_information20;
  End If;
  If (p_rec.ca_tax_information21 = hr_api.g_varchar2) then
    p_rec.ca_tax_information21 :=
    pay_cft_shd.g_old_rec.ca_tax_information21;
  End If;
  If (p_rec.ca_tax_information22 = hr_api.g_varchar2) then
    p_rec.ca_tax_information22 :=
    pay_cft_shd.g_old_rec.ca_tax_information22;
  End If;
  If (p_rec.ca_tax_information23 = hr_api.g_varchar2) then
    p_rec.ca_tax_information23 :=
    pay_cft_shd.g_old_rec.ca_tax_information23;
  End If;
  If (p_rec.ca_tax_information24 = hr_api.g_varchar2) then
    p_rec.ca_tax_information24 :=
    pay_cft_shd.g_old_rec.ca_tax_information24;
  End If;
  If (p_rec.ca_tax_information25 = hr_api.g_varchar2) then
    p_rec.ca_tax_information25 :=
    pay_cft_shd.g_old_rec.ca_tax_information25;
  End If;
  If (p_rec.ca_tax_information26 = hr_api.g_varchar2) then
    p_rec.ca_tax_information26 :=
    pay_cft_shd.g_old_rec.ca_tax_information26;
  End If;
  If (p_rec.ca_tax_information27 = hr_api.g_varchar2) then
    p_rec.ca_tax_information27 :=
    pay_cft_shd.g_old_rec.ca_tax_information27;
  End If;
  If (p_rec.ca_tax_information28 = hr_api.g_varchar2) then
    p_rec.ca_tax_information28 :=
    pay_cft_shd.g_old_rec.ca_tax_information28;
  End If;
  If (p_rec.ca_tax_information29 = hr_api.g_varchar2) then
    p_rec.ca_tax_information29 :=
    pay_cft_shd.g_old_rec.ca_tax_information29;
  End If;
  If (p_rec.ca_tax_information30 = hr_api.g_varchar2) then
    p_rec.ca_tax_information30 :=
    pay_cft_shd.g_old_rec.ca_tax_information30;
  End If;
  If (p_rec.fed_lsf_amount = hr_api.g_number) then
    p_rec.fed_lsf_amount :=
    pay_cft_shd.g_old_rec.fed_lsf_amount;
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
  p_rec			in out nocopy 	pay_cft_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  pay_cft_shd.lck
	(
         p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_emp_fed_tax_inf_id	 => p_rec.emp_fed_tax_inf_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_cft_bus.update_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode  	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
/*
   post_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
*/
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_emp_fed_tax_inf_id           in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_legislation_code             in varchar2         default hr_api.g_varchar2,
  p_assignment_id                in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_employment_province          in varchar2         default hr_api.g_varchar2,
  p_tax_credit_amount            in number           default hr_api.g_number,
  p_claim_code                   in varchar2         default hr_api.g_varchar2,
  p_basic_exemption_flag         in varchar2         default hr_api.g_varchar2,
  p_additional_tax               in number           default hr_api.g_number,
  p_annual_dedn                  in number           default hr_api.g_number,
  p_total_expense_by_commission  in number           default hr_api.g_number,
  p_total_remnrtn_by_commission  in number           default hr_api.g_number,
  p_prescribed_zone_dedn_amt     in number           default hr_api.g_number,
  p_other_fedtax_credits         in varchar2         default hr_api.g_varchar2,
  p_cpp_qpp_exempt_flag          in varchar2         default hr_api.g_varchar2,
  p_fed_exempt_flag              in varchar2         default hr_api.g_varchar2,
  p_ei_exempt_flag               in varchar2         default hr_api.g_varchar2,
  p_tax_calc_method              in varchar2         default hr_api.g_varchar2,
  p_fed_override_amount          in number           default hr_api.g_number,
  p_fed_override_rate            in number           default hr_api.g_number,
  p_ca_tax_information_category  in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information1          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information2          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information3          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information4          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information5          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information6          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information7          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information8          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information9          in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information10         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information11         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information12         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information13         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information14         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information15         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information16         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information17         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information18         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information19         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information20         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information21         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information22         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information23         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information24         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information25         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information26         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information27         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information28         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information29         in varchar2         default hr_api.g_varchar2,
  p_ca_tax_information30         in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_fed_lsf_amount            	 in number           default hr_api.g_number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		pay_cft_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_cft_shd.convert_args
  (
  p_emp_fed_tax_inf_id,
  null,
  null,
  p_legislation_code,
  p_assignment_id,
  p_business_group_id,
  p_employment_province,
  p_tax_credit_amount,
  p_claim_code,
  p_basic_exemption_flag,
  p_additional_tax,
  p_annual_dedn,
  p_total_expense_by_commission,
  p_total_remnrtn_by_commission,
  p_prescribed_zone_dedn_amt,
  p_other_fedtax_credits,
  p_cpp_qpp_exempt_flag,
  p_fed_exempt_flag,
  p_ei_exempt_flag,
  p_tax_calc_method,
  p_fed_override_amount,
  p_fed_override_rate,
  p_ca_tax_information_category,
  p_ca_tax_information1,
  p_ca_tax_information2,
  p_ca_tax_information3,
  p_ca_tax_information4,
  p_ca_tax_information5,
  p_ca_tax_information6,
  p_ca_tax_information7,
  p_ca_tax_information8,
  p_ca_tax_information9,
  p_ca_tax_information10,
  p_ca_tax_information11,
  p_ca_tax_information12,
  p_ca_tax_information13,
  p_ca_tax_information14,
  p_ca_tax_information15,
  p_ca_tax_information16,
  p_ca_tax_information17,
  p_ca_tax_information18,
  p_ca_tax_information19,
  p_ca_tax_information20,
  p_ca_tax_information21,
  p_ca_tax_information22,
  p_ca_tax_information23,
  p_ca_tax_information24,
  p_ca_tax_information25,
  p_ca_tax_information26,
  p_ca_tax_information27,
  p_ca_tax_information28,
  p_ca_tax_information29,
  p_ca_tax_information30,
  p_object_version_number,
  p_fed_lsf_amount
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_cft_upd;

/
