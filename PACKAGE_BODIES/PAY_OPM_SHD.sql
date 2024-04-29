--------------------------------------------------------
--  DDL for Package Body PAY_OPM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_OPM_SHD" as
/* $Header: pyopmrhi.pkb 120.4 2005/11/07 01:38:13 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_opm_shd.';  -- Global package name
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
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_ORG_PAYMENT_METHODS_F_FK1') Then
    -- RAISE ERROR MESSAGE
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'BUSINESS_GROUP_ID');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ORG_PAYMENT_METHODS_F_FK2') Then
    -- RAISE ERROR MESSAGE
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'EXTERNAL_ACCOUNT_ID');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ORG_PAYMENT_METHODS_F_FK3') Then
    -- RAISE ERROR MESSAGE
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'PAYMENT_TYPE_ID');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ORG_PAYMENT_METHODS_F_FK4') Then
    -- RAISE ERROR MESSAGE
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'DEFINED_BALANCE_ID');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ORG_PAYMENT_METHODS_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date                   in date
  ,p_org_payment_method_id            in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     org_payment_method_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,external_account_id
    ,currency_code
    ,payment_type_id
    ,defined_balance_id
    ,org_payment_method_name
    ,comment_id
    ,null
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
    ,pmeth_information_category
    ,pmeth_information1
    ,pmeth_information2
    ,pmeth_information3
    ,pmeth_information4
    ,pmeth_information5
    ,pmeth_information6
    ,pmeth_information7
    ,pmeth_information8
    ,pmeth_information9
    ,pmeth_information10
    ,pmeth_information11
    ,pmeth_information12
    ,pmeth_information13
    ,pmeth_information14
    ,pmeth_information15
    ,pmeth_information16
    ,pmeth_information17
    ,pmeth_information18
    ,pmeth_information19
    ,pmeth_information20
    ,object_version_number
    ,transfer_to_gl_flag
    ,cost_payment
    ,cost_cleared_payment
    ,cost_cleared_void_payment
    ,exclude_manual_payment
    from	pay_org_payment_methods_f
    where	org_payment_method_id = p_org_payment_method_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_org_payment_method_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_org_payment_method_id =
        pay_opm_shd.g_old_rec.org_payment_method_id and
        p_object_version_number =
        pay_opm_shd.g_old_rec.object_version_number) Then
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
      Fetch C_Sel1 Into pay_opm_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> pay_opm_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
  (p_effective_date         in         date
  ,p_base_key_value         in         number
  ,p_correction             out nocopy boolean
  ,p_update                 out nocopy boolean
  ,p_update_override        out nocopy boolean
  ,p_update_change_insert   out nocopy boolean
  ) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'pay_org_payment_methods_f'
    ,p_base_key_column       => 'org_payment_method_id'
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
  (p_effective_date        in         date
  ,p_base_key_value        in         number
  ,p_zap                   out nocopy boolean
  ,p_delete                out nocopy boolean
  ,p_future_change         out nocopy boolean
  ,p_delete_next_change    out nocopy boolean
  ) is
  --
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'pay_org_payment_methods_f'
   ,p_base_key_column               => 'org_payment_method_id'
   ,p_base_key_value                => p_base_key_value
   ,p_zap                           => p_zap
   ,p_delete                        => p_delete
   ,p_future_change                 => p_future_change
   ,p_delete_next_change            => p_delete_next_change
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
      (p_base_table_name    => 'pay_org_payment_methods_f'
      ,p_base_key_column    => 'org_payment_method_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  pay_opm_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_org_payment_methods_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.org_payment_method_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in         date
  ,p_datetrack_mode                   in         varchar2
  ,p_org_payment_method_id            in         number
  ,p_object_version_number            in         number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     org_payment_method_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,external_account_id
    ,currency_code
    ,payment_type_id
    ,defined_balance_id
    ,org_payment_method_name
    ,comment_id
    ,null
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
    ,pmeth_information_category
    ,pmeth_information1
    ,pmeth_information2
    ,pmeth_information3
    ,pmeth_information4
    ,pmeth_information5
    ,pmeth_information6
    ,pmeth_information7
    ,pmeth_information8
    ,pmeth_information9
    ,pmeth_information10
    ,pmeth_information11
    ,pmeth_information12
    ,pmeth_information13
    ,pmeth_information14
    ,pmeth_information15
    ,pmeth_information16
    ,pmeth_information17
    ,pmeth_information18
    ,pmeth_information19
    ,pmeth_information20
    ,object_version_number
    ,transfer_to_gl_flag
    ,cost_payment
    ,cost_cleared_payment
    ,cost_cleared_void_payment
    ,exclude_manual_payment
    from    pay_org_payment_methods_f
    where   org_payment_method_id = p_org_payment_method_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  -- Cursor C_Sel3 select comment text
  --
  Cursor C_Sel3 is
    select hc.comment_text
    from   hr_comments hc
    where  hc.comment_id = pay_opm_shd.g_old_rec.comment_id;
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
                            ,p_argument       => 'org_payment_method_id'
                            ,p_argument_value => p_org_payment_method_id
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into pay_opm_shd.g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number
          <> pay_opm_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    If ((pay_opm_shd.g_old_rec.comment_id is not null) and
        (p_datetrack_mode = hr_api.g_update             or
         p_datetrack_mode = hr_api.g_correction         or
         p_datetrack_mode = hr_api.g_update_override    or
         p_datetrack_mode = hr_api.g_update_change_insert)) then
       Open C_Sel3;
       Fetch C_Sel3 Into pay_opm_shd.g_old_rec.comments;
       If C_Sel3%notfound then
          --
          -- The comments for the specified comment_id does not exist.
          -- We must error due to data integrity problems.
          --
          Close C_Sel3;
          fnd_message.set_name('PAY', 'HR_7202_COMMENT_TEXT_NOT_EXIST');
          fnd_message.raise_error;
       End If;
       Close C_Sel3;
    End If;
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_org_payment_methods_f'
      ,p_base_key_column         => 'org_payment_method_id'
      ,p_base_key_value          => p_org_payment_method_id
      ,p_child_table_name1       => 'pay_org_pay_method_usages_f'
      ,p_child_key_column1       => 'org_pay_method_usage_id'
      ,p_child_table_name2       => 'pay_personal_payment_methods_f'
      ,p_child_key_column2       => 'personal_payment_method_id'
      ,p_child_table_name3       => 'pay_run_type_org_methods_f'
      ,p_child_key_column3       => 'run_type_org_method_id'
      -- ,p_child_table_name4       => 'pay_all_payrolls_f'
      -- ,p_child_key_column4       => 'payroll_id'
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pay_org_payment_methods_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_org_payment_method_id          in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_external_account_id            in number
  ,p_currency_code                  in varchar2
  ,p_payment_type_id                in number
  ,p_defined_balance_id             in number
  ,p_org_payment_method_name        in varchar2
  ,p_comment_id                     in number
  ,p_comments                       in varchar2
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
  ,p_pmeth_information_category     in varchar2
  ,p_pmeth_information1             in varchar2
  ,p_pmeth_information2             in varchar2
  ,p_pmeth_information3             in varchar2
  ,p_pmeth_information4             in varchar2
  ,p_pmeth_information5             in varchar2
  ,p_pmeth_information6             in varchar2
  ,p_pmeth_information7             in varchar2
  ,p_pmeth_information8             in varchar2
  ,p_pmeth_information9             in varchar2
  ,p_pmeth_information10            in varchar2
  ,p_pmeth_information11            in varchar2
  ,p_pmeth_information12            in varchar2
  ,p_pmeth_information13            in varchar2
  ,p_pmeth_information14            in varchar2
  ,p_pmeth_information15            in varchar2
  ,p_pmeth_information16            in varchar2
  ,p_pmeth_information17            in varchar2
  ,p_pmeth_information18            in varchar2
  ,p_pmeth_information19            in varchar2
  ,p_pmeth_information20            in varchar2
  ,p_object_version_number          in number
  ,p_transfer_to_gl_flag            in varchar2
  ,p_cost_payment                   in varchar2
  ,p_cost_cleared_payment           in varchar2
  ,p_cost_cleared_void_payment      in varchar2
  ,p_exclude_manual_payment         in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.org_payment_method_id            := p_org_payment_method_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.external_account_id              := p_external_account_id;
  l_rec.currency_code                    := p_currency_code;
  l_rec.payment_type_id                  := p_payment_type_id;
  l_rec.defined_balance_id               := p_defined_balance_id;
  l_rec.org_payment_method_name          := p_org_payment_method_name;
  l_rec.comment_id                       := p_comment_id;
  l_rec.comments                         := p_comments;
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
  l_rec.pmeth_information_category       := p_pmeth_information_category;
  l_rec.pmeth_information1               := p_pmeth_information1;
  l_rec.pmeth_information2               := p_pmeth_information2;
  l_rec.pmeth_information3               := p_pmeth_information3;
  l_rec.pmeth_information4               := p_pmeth_information4;
  l_rec.pmeth_information5               := p_pmeth_information5;
  l_rec.pmeth_information6               := p_pmeth_information6;
  l_rec.pmeth_information7               := p_pmeth_information7;
  l_rec.pmeth_information8               := p_pmeth_information8;
  l_rec.pmeth_information9               := p_pmeth_information9;
  l_rec.pmeth_information10              := p_pmeth_information10;
  l_rec.pmeth_information11              := p_pmeth_information11;
  l_rec.pmeth_information12              := p_pmeth_information12;
  l_rec.pmeth_information13              := p_pmeth_information13;
  l_rec.pmeth_information14              := p_pmeth_information14;
  l_rec.pmeth_information15              := p_pmeth_information15;
  l_rec.pmeth_information16              := p_pmeth_information16;
  l_rec.pmeth_information17              := p_pmeth_information17;
  l_rec.pmeth_information18              := p_pmeth_information18;
  l_rec.pmeth_information19              := p_pmeth_information19;
  l_rec.pmeth_information20              := p_pmeth_information20;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.transfer_to_gl_flag              := p_transfer_to_gl_flag;
  l_rec.cost_payment                     := p_cost_payment;
  l_rec.cost_cleared_payment             := p_cost_cleared_payment;
  l_rec.cost_cleared_void_payment        := p_cost_cleared_void_payment;
  l_rec.exclude_manual_payment           := p_exclude_manual_payment;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_opm_shd;

/
