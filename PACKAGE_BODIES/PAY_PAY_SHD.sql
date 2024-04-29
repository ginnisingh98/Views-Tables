--------------------------------------------------------
--  DDL for Package Body PAY_PAY_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAY_SHD" as
/* $Header: pypayrhi.pkb 120.0.12000000.3 2007/03/08 09:23:27 mshingan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pay_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_PAYROLLS_F_FK2') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLLS_F_FK3') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLLS_F_FK4') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLLS_F_FK5') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLLS_F_FK6') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLLS_F_FK7') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLLS_F_FK8') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLLS_F_PK') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','40');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLL_NEGATIVE_PAY_A_CHK') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','45');
    fnd_message.raise_error;
  --
  ElsIf (p_constraint_name = 'PAY_PAYROLL_WORKLOAD_SHIFT_CHK') Then
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','50');
    fnd_message.raise_error;
  --
  Else
  --
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  --
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date                   in date
  ,p_payroll_id                       in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     payroll_id
    ,effective_start_date
    ,effective_end_date
    ,default_payment_method_id
    ,business_group_id
    ,consolidation_set_id
    ,cost_allocation_keyflex_id
    ,suspense_account_keyflex_id
    ,gl_set_of_books_id
    ,soft_coding_keyflex_id
    ,period_type
    ,organization_id
    ,cut_off_date_offset
    ,direct_deposit_date_offset
    ,first_period_end_date
    ,negative_pay_allowed_flag
    ,number_of_years
    ,pay_advice_date_offset
    ,pay_date_offset
    ,payroll_name
    ,workload_shifting_level
    ,comment_id
    ,null
    ,midpoint_offset
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,arrears_flag
    ,payroll_type
    ,prl_information_category
    ,prl_information1
    ,prl_information2
    ,prl_information3
    ,prl_information4
    ,prl_information5
    ,prl_information6
    ,prl_information7
    ,prl_information8
    ,prl_information9
    ,prl_information10
    ,prl_information11
    ,prl_information12
    ,prl_information13
    ,prl_information14
    ,prl_information15
    ,prl_information16
    ,prl_information17
    ,prl_information18
    ,prl_information19
    ,prl_information20
    ,prl_information21
    ,prl_information22
    ,prl_information23
    ,prl_information24
    ,prl_information25
    ,prl_information26
    ,prl_information27
    ,prl_information28
    ,prl_information29
    ,prl_information30
    ,multi_assignments_flag
    ,period_reset_years
    ,object_version_number
    ,payslip_view_date_offset
    from        pay_all_payrolls_f
    where       payroll_id = p_payroll_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_payroll_id is null or
      (p_object_version_number is null and
       pay_pay_shd.g_old_rec.object_version_number is not null)) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_payroll_id =
        pay_pay_shd.g_old_rec.payroll_id and (
       (p_object_version_number =
         pay_pay_shd.g_old_rec.object_version_number) or
        (p_object_version_number is null and
         pay_pay_shd.g_old_rec.object_version_number is null))) then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
      --
      Open C_Sel1;
      Fetch C_Sel1 Into pay_pay_shd.g_old_rec;
      If C_Sel1%notfound Then
      --
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      --
      End If;
      Close C_Sel1;
      If (p_object_version_number <> pay_pay_shd.g_old_rec.object_version_number) Then
      --
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      --
      End If;
      l_fct_ret := true;
    --
    End If;
  --
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_correction             out nocopy boolean
  ,p_update                 out nocopy boolean
  ,p_update_override        out nocopy boolean
  ,p_update_change_insert   out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'pay_all_payrolls_f'
    ,p_base_key_column       => 'payroll_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
  (p_effective_date        in date
  ,p_base_key_value        in number
  ,p_zap                   out nocopy boolean
  ,p_delete                out nocopy boolean
  ,p_future_change         out nocopy boolean
  ,p_delete_next_change    out nocopy boolean
  ) is
  --
  l_proc                varchar2(72)    := g_package||'find_dt_del_modes';
  --
  l_parent_key_value1     number;
  --
  Cursor C_Sel1 Is
    select t.default_payment_method_id
    from   pay_all_payrolls_f t
    where  t.payroll_id = p_base_key_value
    and    p_effective_date
    between t.effective_start_date and t.effective_end_date;
  --
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open C_sel1;
  Fetch C_Sel1 Into
     l_parent_key_value1;

  If C_Sel1%NOTFOUND then
  --
     Close C_Sel1;
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE',l_proc);
     fnd_message.set_token('STEP','10');
     fnd_message.raise_error;
  --
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'pay_all_payrolls_f'
   ,p_base_key_column               => 'payroll_id'
   ,p_base_key_value                => p_base_key_value

   ,p_parent_table_name1            => 'pay_org_payment_methods_f'
   ,p_parent_key_column1            => 'org_payment_method_id'
   ,p_parent_key_value1             => l_parent_key_value1

   ,p_zap                           => p_zap
   ,p_delete                        => p_delete
   ,p_future_change                 => p_future_change
   ,p_delete_next_change            => p_delete_next_change
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
  (p_effective_date                   in date
  ,p_base_key_value                   in number
  ,p_new_effective_end_date           in date
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ,p_object_version_number  out nocopy number
  ) is
--
  l_proc                  varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
  l_status_of_dml boolean;
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name    => 'pay_all_payrolls_f'
      ,p_base_key_column    => 'payroll_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  pay_pay_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_all_payrolls_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.payroll_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  l_status_of_dml := SQL%NOTFOUND;
  pay_pay_shd.g_api_dml := false;   -- Unset the api dml status

    if (l_status_of_dml) then
    --
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                 'pay_payrolls_f_pkg.update_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    --
    End if;

  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_payroll_id                       in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_argument              varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     payroll_id
    ,effective_start_date
    ,effective_end_date
    ,default_payment_method_id
    ,business_group_id
    ,consolidation_set_id
    ,cost_allocation_keyflex_id
    ,suspense_account_keyflex_id
    ,gl_set_of_books_id
    ,soft_coding_keyflex_id
    ,period_type
    ,organization_id
    ,cut_off_date_offset
    ,direct_deposit_date_offset
    ,first_period_end_date
    ,negative_pay_allowed_flag
    ,number_of_years
    ,pay_advice_date_offset
    ,pay_date_offset
    ,payroll_name
    ,workload_shifting_level
    ,comment_id
    ,null
    ,midpoint_offset
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,arrears_flag
    ,payroll_type
    ,prl_information_category
    ,prl_information1
    ,prl_information2
    ,prl_information3
    ,prl_information4
    ,prl_information5
    ,prl_information6
    ,prl_information7
    ,prl_information8
    ,prl_information9
    ,prl_information10
    ,prl_information11
    ,prl_information12
    ,prl_information13
    ,prl_information14
    ,prl_information15
    ,prl_information16
    ,prl_information17
    ,prl_information18
    ,prl_information19
    ,prl_information20
    ,prl_information21
    ,prl_information22
    ,prl_information23
    ,prl_information24
    ,prl_information25
    ,prl_information26
    ,prl_information27
    ,prl_information28
    ,prl_information29
    ,prl_information30
    ,multi_assignments_flag
    ,period_reset_years
    ,object_version_number
    ,payslip_view_date_offset
    from    pay_all_payrolls_f
    where   payroll_id = p_payroll_id
    and     p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  -- Cursor C_Sel3 select comment text
  --
  Cursor C_Sel3 is
    select hc.comment_text
    from   hr_comments hc
    where  hc.comment_id = pay_pay_shd.g_old_rec.comment_id;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'effective_date'
                            ,p_argument_value => p_effective_date
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'datetrack_mode'
                            ,p_argument_value => p_datetrack_mode
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'payroll_id'
                            ,p_argument_value => p_payroll_id
                            );

  if  (p_datetrack_mode = hr_api.g_insert) then
      hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );
  end if;

  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
  --
	    -- We must select and lock the current row.
	    --
	    Open  C_Sel1;
	    Fetch C_Sel1 Into pay_pay_shd.g_old_rec;
	    If C_Sel1%notfound then
	    --
		      Close C_Sel1;
		      --
		      -- The primary key is invalid therefore we must error
		      --
		      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
		      fnd_message.raise_error;
	    --
	    End If;
	    Close C_Sel1;

        if (pay_pay_shd.g_old_rec.object_version_number is not null) then
           hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );
        end if;

	    If (p_object_version_number <> pay_pay_shd.g_old_rec.object_version_number and
            pay_pay_shd.g_old_rec.object_version_number is not null) Then
	       --
		   fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
	   	   fnd_message.raise_error;
	       --
	    End If;
	    --
	    -- Providing we are doing an update and a comment_id exists then
	    -- we select the comment text.
	    --
	    If ((pay_pay_shd.g_old_rec.comment_id is not null) and
		(p_datetrack_mode = hr_api.g_update             or
		 p_datetrack_mode = hr_api.g_correction         or
		 p_datetrack_mode = hr_api.g_update_override    or
		 p_datetrack_mode = hr_api.g_update_change_insert)) then
	    --
	       Open C_Sel3;
	       Fetch C_Sel3 Into pay_pay_shd.g_old_rec.comments;
	       If C_Sel3%notfound then
	       --
			  -- The comments for the specified comment_id does not exist.
			  -- We must error due to data integrity problems.
			  --
			  Close C_Sel3;
			  fnd_message.set_name('PAY', 'HR_7202_COMMENT_TEXT_NOT_EXIST');
			  fnd_message.raise_error;
	       --
	       End If;
               Close C_Sel3;
	    --
	    End If;
	    --
	    -- Validate the datetrack mode mode getting the validation start
	    -- and end dates for the specified datetrack operation.

	    dt_api.validate_dt_mode
	      (p_effective_date             => p_effective_date
	      ,p_datetrack_mode             => p_datetrack_mode
	      ,p_base_table_name            => 'pay_all_payrolls_f'
	      ,p_base_key_column            => 'payroll_id'
	      ,p_base_key_value             => p_payroll_id

	      ,p_parent_table_name1         => 'pay_org_payment_methods_f'
	      ,p_parent_key_column1         => 'org_payment_method_id'
	      ,p_parent_key_value1          => pay_pay_shd.g_old_rec.default_payment_method_id

	      ,p_child_table_name1          => 'per_all_assignments_f'
	      ,p_child_key_column1          => 'assignment_id'
	      ,p_child_alt_base_key_column1 => 'payroll_id'

	      ,p_child_table_name2          => 'pay_element_links_f'
	      ,p_child_key_column2          => 'element_link_id'
	      ,p_child_alt_base_key_column2 => 'payroll_id'

	      ,p_child_table_name3          => 'hr_all_positions_f'
	      ,p_child_key_column3	    => 'position_id'
	      ,p_child_alt_base_key_column3 => 'pay_freq_payroll_id'

	      ,p_enforce_foreign_locking    => true
	      ,p_validation_start_date      => l_validation_start_date
	      ,p_validation_end_date        => l_validation_end_date
	      );
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  --
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;

  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pay_all_payrolls_f');
    fnd_message.raise_error;
--
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
--
Function convert_args
  (p_payroll_id                     in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_default_payment_method_id      in number
  ,p_business_group_id              in number
  ,p_consolidation_set_id           in number
  ,p_cost_allocation_keyflex_id     in number
  ,p_suspense_account_keyflex_id    in number
  ,p_gl_set_of_books_id             in number
  ,p_soft_coding_keyflex_id         in number
  ,p_period_type                    in varchar2
  ,p_organization_id                in number
  ,p_cut_off_date_offset            in number
  ,p_direct_deposit_date_offset     in number
  ,p_first_period_end_date          in date
  ,p_negative_pay_allowed_flag      in varchar2
  ,p_number_of_years                in number
  ,p_pay_advice_date_offset         in number
  ,p_pay_date_offset                in number
  ,p_payroll_name                   in varchar2
  ,p_workload_shifting_level        in varchar2
  ,p_comment_id                     in number
  ,p_comments                       in varchar2
  ,p_midpoint_offset                in number
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_arrears_flag                   in varchar2
  ,p_payroll_type                   in varchar2
  ,p_prl_information_category       in varchar2
  ,p_prl_information1               in varchar2
  ,p_prl_information2               in varchar2
  ,p_prl_information3               in varchar2
  ,p_prl_information4               in varchar2
  ,p_prl_information5               in varchar2
  ,p_prl_information6               in varchar2
  ,p_prl_information7               in varchar2
  ,p_prl_information8               in varchar2
  ,p_prl_information9               in varchar2
  ,p_prl_information10              in varchar2
  ,p_prl_information11              in varchar2
  ,p_prl_information12              in varchar2
  ,p_prl_information13              in varchar2
  ,p_prl_information14              in varchar2
  ,p_prl_information15              in varchar2
  ,p_prl_information16              in varchar2
  ,p_prl_information17              in varchar2
  ,p_prl_information18              in varchar2
  ,p_prl_information19              in varchar2
  ,p_prl_information20              in varchar2
  ,p_prl_information21              in varchar2
  ,p_prl_information22              in varchar2
  ,p_prl_information23              in varchar2
  ,p_prl_information24              in varchar2
  ,p_prl_information25              in varchar2
  ,p_prl_information26              in varchar2
  ,p_prl_information27              in varchar2
  ,p_prl_information28              in varchar2
  ,p_prl_information29              in varchar2
  ,p_prl_information30              in varchar2
  ,p_multi_assignments_flag         in varchar2
  ,p_period_reset_years             in varchar2
  ,p_object_version_number          in number

  ,p_payslip_view_date_offset       in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.payroll_id                       := p_payroll_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.default_payment_method_id        := p_default_payment_method_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.consolidation_set_id             := p_consolidation_set_id;
  l_rec.cost_allocation_keyflex_id       := p_cost_allocation_keyflex_id;
  l_rec.suspense_account_keyflex_id      := p_suspense_account_keyflex_id;
  l_rec.gl_set_of_books_id               := p_gl_set_of_books_id;
  l_rec.soft_coding_keyflex_id           := p_soft_coding_keyflex_id;
  l_rec.period_type                      := p_period_type;
  l_rec.organization_id                  := p_organization_id;
  l_rec.cut_off_date_offset              := p_cut_off_date_offset;
  l_rec.direct_deposit_date_offset       := p_direct_deposit_date_offset;
  l_rec.first_period_end_date            := p_first_period_end_date;
  l_rec.negative_pay_allowed_flag        := p_negative_pay_allowed_flag;
  l_rec.number_of_years                  := p_number_of_years;
  l_rec.pay_advice_date_offset           := p_pay_advice_date_offset;
  l_rec.pay_date_offset                  := p_pay_date_offset;
  l_rec.payroll_name                     := p_payroll_name;
  l_rec.workload_shifting_level          := p_workload_shifting_level;
  l_rec.comment_id                       := p_comment_id;
  l_rec.comments                         := p_comments;
  l_rec.midpoint_offset                  := p_midpoint_offset;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.arrears_flag                     := p_arrears_flag;
  l_rec.payroll_type                     := p_payroll_type;
  l_rec.prl_information_category         := p_prl_information_category;
  l_rec.prl_information1                 := p_prl_information1;
  l_rec.prl_information2                 := p_prl_information2;
  l_rec.prl_information3                 := p_prl_information3;
  l_rec.prl_information4                 := p_prl_information4;
  l_rec.prl_information5                 := p_prl_information5;
  l_rec.prl_information6                 := p_prl_information6;
  l_rec.prl_information7                 := p_prl_information7;
  l_rec.prl_information8                 := p_prl_information8;
  l_rec.prl_information9                 := p_prl_information9;
  l_rec.prl_information10                := p_prl_information10;
  l_rec.prl_information11                := p_prl_information11;
  l_rec.prl_information12                := p_prl_information12;
  l_rec.prl_information13                := p_prl_information13;
  l_rec.prl_information14                := p_prl_information14;
  l_rec.prl_information15                := p_prl_information15;
  l_rec.prl_information16                := p_prl_information16;
  l_rec.prl_information17                := p_prl_information17;
  l_rec.prl_information18                := p_prl_information18;
  l_rec.prl_information19                := p_prl_information19;
  l_rec.prl_information20                := p_prl_information20;
  l_rec.prl_information21                := p_prl_information21;
  l_rec.prl_information22                := p_prl_information22;
  l_rec.prl_information23                := p_prl_information23;
  l_rec.prl_information24                := p_prl_information24;
  l_rec.prl_information25                := p_prl_information25;
  l_rec.prl_information26                := p_prl_information26;
  l_rec.prl_information27                := p_prl_information27;
  l_rec.prl_information28                := p_prl_information28;
  l_rec.prl_information29                := p_prl_information29;
  l_rec.prl_information30                := p_prl_information30;
  l_rec.multi_assignments_flag           := p_multi_assignments_flag;
  l_rec.period_reset_years               := p_period_reset_years;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.payslip_view_date_offset	 := p_payslip_view_date_offset;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_pay_shd;

/
