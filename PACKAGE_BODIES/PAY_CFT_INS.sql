--------------------------------------------------------
--  DDL for Package Body PAY_CFT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CFT_INS" as
/* $Header: pycatrhi.pkb 120.1 2005/10/05 06:44:36 saurgupt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cft_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
	(p_rec 			 in out nocopy pay_cft_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   pay_ca_emp_fed_tax_info_f t
    where  t.emp_fed_tax_inf_id       = p_rec.emp_fed_tax_inf_id
    and    t.effective_start_date =
             pay_cft_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_ca_emp_fed_tax_info_f.created_by%TYPE;
  l_creation_date       pay_ca_emp_fed_tax_info_f.creation_date%TYPE;
  l_last_update_date   	pay_ca_emp_fed_tax_info_f.last_update_date%TYPE;
  l_last_updated_by     pay_ca_emp_fed_tax_info_f.last_updated_by%TYPE;
  l_last_update_login   pay_ca_emp_fed_tax_info_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'pay_ca_emp_fed_tax_info_f',
	 p_base_key_column => 'emp_fed_tax_inf_id',
	 p_base_key_value  => p_rec.emp_fed_tax_inf_id);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> 'INSERT') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  pay_cft_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_ca_emp_fed_tax_info_f
  --
  insert into pay_ca_emp_fed_tax_info_f
  (	emp_fed_tax_inf_id,
	effective_start_date,
	effective_end_date,
	legislation_code,
	assignment_id,
	business_group_id,
	employment_province,
	tax_credit_amount,
	claim_code,
	basic_exemption_flag,
	additional_tax,
	annual_dedn,
	total_expense_by_commission,
	total_remnrtn_by_commission,
	prescribed_zone_dedn_amt,
	other_fedtax_credits,
	cpp_qpp_exempt_flag,
	fed_exempt_flag,
	ei_exempt_flag,
	tax_calc_method,
	fed_override_amount,
	fed_override_rate,
	ca_tax_information_category,
	ca_tax_information1,
	ca_tax_information2,
	ca_tax_information3,
	ca_tax_information4,
	ca_tax_information5,
	ca_tax_information6,
	ca_tax_information7,
	ca_tax_information8,
	ca_tax_information9,
	ca_tax_information10,
	ca_tax_information11,
	ca_tax_information12,
	ca_tax_information13,
	ca_tax_information14,
	ca_tax_information15,
	ca_tax_information16,
	ca_tax_information17,
	ca_tax_information18,
	ca_tax_information19,
	ca_tax_information20,
	ca_tax_information21,
	ca_tax_information22,
	ca_tax_information23,
	ca_tax_information24,
	ca_tax_information25,
	ca_tax_information26,
	ca_tax_information27,
	ca_tax_information28,
	ca_tax_information29,
	ca_tax_information30,
	object_version_number,
	fed_lsf_amount,
	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.emp_fed_tax_inf_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.legislation_code,
	p_rec.assignment_id,
	p_rec.business_group_id,
	p_rec.employment_province,
	p_rec.tax_credit_amount,
	p_rec.claim_code,
	p_rec.basic_exemption_flag,
	p_rec.additional_tax,
	p_rec.annual_dedn,
	p_rec.total_expense_by_commission,
	p_rec.total_remnrtn_by_commission,
	p_rec.prescribed_zone_dedn_amt,
	p_rec.other_fedtax_credits,
	p_rec.cpp_qpp_exempt_flag,
	p_rec.fed_exempt_flag,
	p_rec.ei_exempt_flag,
	p_rec.tax_calc_method,
	p_rec.fed_override_amount,
	p_rec.fed_override_rate,
	p_rec.ca_tax_information_category,
	p_rec.ca_tax_information1,
	p_rec.ca_tax_information2,
	p_rec.ca_tax_information3,
	p_rec.ca_tax_information4,
	p_rec.ca_tax_information5,
	p_rec.ca_tax_information6,
	p_rec.ca_tax_information7,
	p_rec.ca_tax_information8,
	p_rec.ca_tax_information9,
	p_rec.ca_tax_information10,
	p_rec.ca_tax_information11,
	p_rec.ca_tax_information12,
	p_rec.ca_tax_information13,
	p_rec.ca_tax_information14,
	p_rec.ca_tax_information15,
	p_rec.ca_tax_information16,
	p_rec.ca_tax_information17,
	p_rec.ca_tax_information18,
	p_rec.ca_tax_information19,
	p_rec.ca_tax_information20,
	p_rec.ca_tax_information21,
	p_rec.ca_tax_information22,
	p_rec.ca_tax_information23,
	p_rec.ca_tax_information24,
	p_rec.ca_tax_information25,
	p_rec.ca_tax_information26,
	p_rec.ca_tax_information27,
	p_rec.ca_tax_information28,
	p_rec.ca_tax_information29,
	p_rec.ca_tax_information30,
	p_rec.object_version_number,
	p_rec.fed_lsf_amount,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  pay_cft_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
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
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy pay_cft_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
	(p_rec  			in out nocopy pay_cft_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_ca_emp_fed_tax_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.emp_fed_tax_inf_id;
  Close C_Sel1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
	(p_rec 			 in pay_cft_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pay_cft_rki.after_insert
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
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_ca_emp_fed_tax_info_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist<>
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_rec	 		 in  pay_cft_shd.g_rec_type,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'pay_ca_emp_fed_tax_info_f',
	 p_base_key_column	   => 'emp_fed_tax_inf_id',
	 p_base_key_value 	   => p_rec.emp_fed_tax_inf_id,
	 p_parent_table_name1      => 'per_all_assignments_f',
	 p_parent_key_column1      => 'assignment_id',
	 p_parent_key_value1       => p_rec.assignment_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec		   in out nocopy pay_cft_shd.g_rec_type,
  p_effective_date in     date
  ) is
--
  l_proc			varchar2(72) := g_package||'ins';
  l_datetrack_mode		varchar2(30) := 'INSERT';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  ins_lck
	(p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_rec	 		 => p_rec,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting insert validate operations
  --
--dbms_output.put_line('before insert validate');
  pay_cft_bus.insert_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
--dbms_output.put_line('after insert validate');
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-insert operation
  --
/*
  post_insert
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
*/
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_emp_fed_tax_inf_id           out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_legislation_code             in varchar2,
  p_assignment_id                in number,
  p_business_group_id            in number,
  p_employment_province          in varchar2         default null,
  p_tax_credit_amount            in number           default null,
  p_claim_code                   in varchar2         default null,
  p_basic_exemption_flag         in varchar2         default null,
  p_additional_tax               in number           default null,
  p_annual_dedn                  in number           default null,
  p_total_expense_by_commission  in number           default null,
  p_total_remnrtn_by_commission  in number           default null,
  p_prescribed_zone_dedn_amt     in number           default null,
  p_other_fedtax_credits         in varchar2         default null,
  p_cpp_qpp_exempt_flag          in varchar2         default null,
  p_fed_exempt_flag              in varchar2         default null,
  p_ei_exempt_flag               in varchar2         default null,
  p_tax_calc_method              in varchar2         default null,
  p_fed_override_amount          in number           default null,
  p_fed_override_rate            in number           default null,
  p_ca_tax_information_category  in varchar2         default null,
  p_ca_tax_information1          in varchar2         default null,
  p_ca_tax_information2          in varchar2         default null,
  p_ca_tax_information3          in varchar2         default null,
  p_ca_tax_information4          in varchar2         default null,
  p_ca_tax_information5          in varchar2         default null,
  p_ca_tax_information6          in varchar2         default null,
  p_ca_tax_information7          in varchar2         default null,
  p_ca_tax_information8          in varchar2         default null,
  p_ca_tax_information9          in varchar2         default null,
  p_ca_tax_information10         in varchar2         default null,
  p_ca_tax_information11         in varchar2         default null,
  p_ca_tax_information12         in varchar2         default null,
  p_ca_tax_information13         in varchar2         default null,
  p_ca_tax_information14         in varchar2         default null,
  p_ca_tax_information15         in varchar2         default null,
  p_ca_tax_information16         in varchar2         default null,
  p_ca_tax_information17         in varchar2         default null,
  p_ca_tax_information18         in varchar2         default null,
  p_ca_tax_information19         in varchar2         default null,
  p_ca_tax_information20         in varchar2         default null,
  p_ca_tax_information21         in varchar2         default null,
  p_ca_tax_information22         in varchar2         default null,
  p_ca_tax_information23         in varchar2         default null,
  p_ca_tax_information24         in varchar2         default null,
  p_ca_tax_information25         in varchar2         default null,
  p_ca_tax_information26         in varchar2         default null,
  p_ca_tax_information27         in varchar2         default null,
  p_ca_tax_information28         in varchar2         default null,
  p_ca_tax_information29         in varchar2         default null,
  p_ca_tax_information30         in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_fed_lsf_amount               in number           default null,
  p_effective_date		 in date
  ) is
--
  l_rec		pay_cft_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
  l_effective_date    date;
--
  cursor c1(asg_id number) is
    select max(effective_start_date)
    from   per_assignments_f asg
    where asg.assignment_id = asg_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
/* What ever the effective date is tax record is always created from the
   date when the assignment has started.  */
/*
  open c1(p_assignment_id);
  fetch c1 into l_effective_date;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as assignment_id not found in per_assignments_f
        -- table.
        --
--dbms_output.put_line('in assignment_id 6');
        hr_utility.set_message(800, 'HR_74025_INVALID_ASSIGNMENT_ID');
        hr_utility.raise_error;
      else
--       p_effective_date := l_effective_date;
       close c1;
      end if;
*/
       l_effective_date := p_effective_date;

  l_rec :=
  pay_cft_shd.convert_args
  (
  null,
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
  null,
  p_fed_lsf_amount
  );
  --
  -- Having converted the arguments into the pay_cft_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, l_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_emp_fed_tax_inf_id        	:= l_rec.emp_fed_tax_inf_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_cft_ins;

/
