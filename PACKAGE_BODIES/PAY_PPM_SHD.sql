--------------------------------------------------------
--  DDL for Package Body PAY_PPM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPM_SHD" as
/* $Header: pyppmrhi.pkb 120.3.12010000.5 2010/03/30 06:46:19 priupadh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ppm_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PAY_PERSONAL_PAYMENT_METHO_FK1') Then
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PERSONAL_PAYMENT_METHO_FK2') Then
    -- Error: The specified external account does not exist
    hr_utility.set_message(801, 'HR_6223_PAYM_BAD_ACCT');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PERSONAL_PAYMENT_METHO_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date		in date,
   p_personal_payment_method_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	personal_payment_method_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	external_account_id,
	assignment_id,
	run_type_id,
	org_payment_method_id,
	amount,
	comment_id,
	null,
	percentage,
	priority,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
	object_version_number,
	payee_type,
	payee_id,
	ppm_information_category,
	ppm_information1,
	ppm_information2,
	ppm_information3,
	ppm_information4,
	ppm_information5,
	ppm_information6,
	ppm_information7,
	ppm_information8,
	ppm_information9,
	ppm_information10,
	ppm_information11,
	ppm_information12,
	ppm_information13,
	ppm_information14,
	ppm_information15,
	ppm_information16,
	ppm_information17,
	ppm_information18,
	ppm_information19,
	ppm_information20,
	ppm_information21,
	ppm_information22,
	ppm_information23,
	ppm_information24,
	ppm_information25,
	ppm_information26,
	ppm_information27,
	ppm_information28,
	ppm_information29,
	ppm_information30
    from	pay_personal_payment_methods_f
    where	personal_payment_method_id = p_personal_payment_method_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_personal_payment_method_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_personal_payment_method_id = g_old_rec.personal_payment_method_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap			out nocopy boolean,
	 p_delete		out nocopy boolean,
	 p_future_change	out nocopy boolean,
	 p_delete_next_change	out nocopy boolean) is
--
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
--
  l_parent_key_value1	number;
  l_parent_key_value2	number;
  --
  Cursor C_Sel1 Is
    select  t.org_payment_method_id,
	    t.assignment_id
    from    pay_personal_payment_methods_f t
    where   t.personal_payment_method_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value2;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'pay_personal_payment_methods_f',
	 p_base_key_column	=> 'personal_payment_method_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'pay_org_payment_methods_f',
	 p_parent_key_column1	=> 'org_payment_method_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'per_all_assignments_f',
	 p_parent_key_column2	=> 'assignment_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  --
  p_future_change := false;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction		out nocopy boolean,
	 p_update		out nocopy boolean,
	 p_update_override	out nocopy boolean,
	 p_update_change_insert	out nocopy boolean) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'pay_personal_payment_methods_f',
	 p_base_key_column	=> 'personal_payment_method_id',
	 p_base_key_value	=> p_base_key_value,
	 p_correction		=> p_correction,
	 p_update		=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number) is
--
  l_proc 		  varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name	=> 'pay_personal_payment_methods_f',
	 p_base_key_column	=> 'personal_payment_method_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_personal_payment_methods_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.personal_payment_method_id	  = p_base_key_value
  and	  p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_personal_payment_method_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  l_lock_table            varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	personal_payment_method_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	external_account_id,
	assignment_id,
	run_type_id,
	org_payment_method_id,
	amount,
	comment_id,
	null,
	percentage,
	priority,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
	object_version_number,
	payee_type,
	payee_id,
	ppm_information_category,
	ppm_information1,
	ppm_information2,
	ppm_information3,
	ppm_information4,
	ppm_information5,
	ppm_information6,
	ppm_information7,
	ppm_information8,
	ppm_information9,
	ppm_information10,
	ppm_information11,
	ppm_information12,
	ppm_information13,
	ppm_information14,
	ppm_information15,
	ppm_information16,
	ppm_information17,
	ppm_information18,
	ppm_information19,
	ppm_information20,
	ppm_information21,
	ppm_information22,
	ppm_information23,
	ppm_information24,
	ppm_information25,
	ppm_information26,
	ppm_information27,
	ppm_information28,
	ppm_information29,
	ppm_information30
    from    pay_personal_payment_methods_f
    where   personal_payment_method_id         = p_personal_payment_method_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  -- Cursor C_Sel3 select comment text
  --
  Cursor C_Sel3 is
    select hc.comment_text
    from   hr_comments hc
    where  hc.comment_id = pay_ppm_shd.g_old_rec.comment_id;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'personal_payment_method_id',
                             p_argument_value => p_personal_payment_method_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- It is necessary to lock PAY_ORG_PAY_METHOD_USAGES_F for datetrack modes
    -- that extend a PPM because return_effective_end_date needs to be ensure that
    -- the usages are still valid when the record is valid. PAY_ORG_PAY_METHOD_USAGES_F
    -- comes before PAY_PERSONAL_PAYMENT_METHODS_F in the HRMS lock ladder.
    --
    --
    if p_datetrack_mode = 'DELETE_NEXT_CHANGE' or p_datetrack_mode = 'FUTURE_CHANGE'
    then
      l_lock_table := 'pay_org_pay_method_usages_f';
      lock table pay_org_pay_method_usages_f in share mode nowait;
    end if;
    --
    -- We must select and lock the current row.
    --
    l_lock_table := 'pay_personal_payment_methods_f';
    Open  C_Sel1;
    Fetch C_Sel1 Into g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
    hr_utility.set_location(l_proc, 15);
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    If ((g_old_rec.comment_id is not null)              and
        (p_datetrack_mode = 'UPDATE'                   or
         p_datetrack_mode = 'CORRECTION'               or
         p_datetrack_mode = 'UPDATE_OVERRIDE'          or
         p_datetrack_mode = 'UPDATE_CHANGE_INSERT')) then
      Open C_Sel3;
      Fetch C_Sel3 Into pay_ppm_shd.g_old_rec.comments;
      If C_Sel3%notfound then
        --
        -- The comments for the specified comment_id does not exist.
        -- We must error due to data integrity problems.
        --
        Close C_Sel3;
        hr_utility.set_message(801, 'HR_7202_COMMENT_TEXT_NOT_EXIST');
        hr_utility.raise_error;
      End If;
      Close C_Sel3;
    End If;
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
        (p_effective_date          => p_effective_date,
         p_datetrack_mode          => p_datetrack_mode,
         p_base_table_name         => 'pay_personal_payment_methods_f',
         p_base_key_column         => 'personal_payment_method_id',
         p_base_key_value          => p_personal_payment_method_id,
         p_parent_table_name1      => 'pay_org_payment_methods_f',
         p_parent_key_column1      => 'org_payment_method_id',
         p_parent_key_value1       => g_old_rec.org_payment_method_id,
         p_parent_table_name2      => 'per_all_assignments_f',
         p_parent_key_column2      => 'assignment_id',
         p_parent_key_value2       => g_old_rec.assignment_id,
	 p_child_table_name1       => 'pay_element_entries_f',
	 p_child_key_column1       => 'element_entry_id',
         p_enforce_foreign_locking => true,
         p_validation_start_date   => l_validation_start_date,
         p_validation_end_date     => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', l_lock_table)
;
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'pay_personal_payment_methods_f')
;
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_personal_payment_method_id    in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_external_account_id           in number,
	p_assignment_id                 in number,
        p_run_type_id                   in number,
	p_org_payment_method_id         in number,
	p_amount                        in number,
	p_comment_id                    in number,
	p_comments                      in varchar2,
	p_percentage                    in number,
	p_priority                      in number,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
	p_object_version_number         in number,
	p_payee_type                    in varchar2,
	p_payee_id                      in number,
        p_ppm_information_category      in varchar2,
        p_ppm_information1              in varchar2,
        p_ppm_information2              in varchar2,
        p_ppm_information3              in varchar2,
        p_ppm_information4              in varchar2,
        p_ppm_information5              in varchar2,
        p_ppm_information6              in varchar2,
        p_ppm_information7              in varchar2,
        p_ppm_information8              in varchar2,
        p_ppm_information9              in varchar2,
        p_ppm_information10             in varchar2,
        p_ppm_information11             in varchar2,
        p_ppm_information12             in varchar2,
        p_ppm_information13             in varchar2,
        p_ppm_information14             in varchar2,
        p_ppm_information15             in varchar2,
        p_ppm_information16             in varchar2,
        p_ppm_information17             in varchar2,
        p_ppm_information18             in varchar2,
        p_ppm_information19             in varchar2,
        p_ppm_information20             in varchar2,
        p_ppm_information21             in varchar2,
        p_ppm_information22             in varchar2,
        p_ppm_information23             in varchar2,
        p_ppm_information24             in varchar2,
        p_ppm_information25             in varchar2,
        p_ppm_information26             in varchar2,
        p_ppm_information27             in varchar2,
        p_ppm_information28             in varchar2,
        p_ppm_information29             in varchar2,
        p_ppm_information30             in varchar2
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.personal_payment_method_id       := p_personal_payment_method_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.external_account_id              := p_external_account_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.run_type_id                      := p_run_type_id  ;
  l_rec.org_payment_method_id            := p_org_payment_method_id;
  l_rec.amount                           := p_amount;
  l_rec.comment_id                       := p_comment_id;
  l_rec.comments                         := p_comments;
  l_rec.percentage                       := p_percentage;
  l_rec.priority                         := p_priority;
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
  l_rec.object_version_number            := p_object_version_number;
  l_rec.payee_type                       := p_payee_type;
  l_rec.payee_id                         := p_payee_id;
  l_rec.ppm_information_category         := p_ppm_information_category;
  l_rec.ppm_information1                 := p_ppm_information1;
  l_rec.ppm_information2                 := p_ppm_information2;
  l_rec.ppm_information3                 := p_ppm_information3;
  l_rec.ppm_information4                 := p_ppm_information4;
  l_rec.ppm_information5                 := p_ppm_information5;
  l_rec.ppm_information6                 := p_ppm_information6;
  l_rec.ppm_information7                 := p_ppm_information7;
  l_rec.ppm_information8                 := p_ppm_information8;
  l_rec.ppm_information9                 := p_ppm_information9;
  l_rec.ppm_information10                := p_ppm_information10;
  l_rec.ppm_information11                := p_ppm_information11;
  l_rec.ppm_information12                := p_ppm_information12;
  l_rec.ppm_information13                := p_ppm_information13;
  l_rec.ppm_information14                := p_ppm_information14;
  l_rec.ppm_information15                := p_ppm_information15;
  l_rec.ppm_information16                := p_ppm_information16;
  l_rec.ppm_information17                := p_ppm_information17;
  l_rec.ppm_information18                := p_ppm_information18;
  l_rec.ppm_information19                := p_ppm_information19;
  l_rec.ppm_information20                := p_ppm_information20;
  l_rec.ppm_information21                := p_ppm_information21;
  l_rec.ppm_information22                := p_ppm_information22;
  l_rec.ppm_information23                := p_ppm_information23;
  l_rec.ppm_information24                := p_ppm_information24;
  l_rec.ppm_information25                := p_ppm_information25;
  l_rec.ppm_information26                := p_ppm_information26;
  l_rec.ppm_information27                := p_ppm_information27;
  l_rec.ppm_information28                := p_ppm_information28;
  l_rec.ppm_information29                := p_ppm_information29;
  l_rec.ppm_information30                := p_ppm_information30;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pay_ppm_shd;

/
