--------------------------------------------------------
--  DDL for Package Body PAY_PBC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PBC_SHD" as
/* $Header: pypbcrhi.pkb 120.0 2005/05/29 07:19:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pbc_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_BALANCE_CATEGORIES_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Elsif
    (p_constraint_name = 'PAY_BALANCE_CATEGORIES_F_UK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  ,p_balance_category_id              in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     balance_category_id
    ,category_name
    ,effective_start_date
    ,effective_end_date
    ,legislation_code
    ,business_group_id
    ,save_run_balance_enabled
    ,user_category_name
    ,pbc_information_category
    ,pbc_information1
    ,pbc_information2
    ,pbc_information3
    ,pbc_information4
    ,pbc_information5
    ,pbc_information6
    ,pbc_information7
    ,pbc_information8
    ,pbc_information9
    ,pbc_information10
    ,pbc_information11
    ,pbc_information12
    ,pbc_information13
    ,pbc_information14
    ,pbc_information15
    ,pbc_information16
    ,pbc_information17
    ,pbc_information18
    ,pbc_information19
    ,pbc_information20
    ,pbc_information21
    ,pbc_information22
    ,pbc_information23
    ,pbc_information24
    ,pbc_information25
    ,pbc_information26
    ,pbc_information27
    ,pbc_information28
    ,pbc_information29
    ,pbc_information30
    ,object_version_number
    from        pay_balance_categories_f
    where       balance_category_id = p_balance_category_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_balance_category_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_balance_category_id =
        pay_pbc_shd.g_old_rec.balance_category_id and
        p_object_version_number =
        pay_pbc_shd.g_old_rec.object_version_number
) Then
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
      Fetch C_Sel1 Into pay_pbc_shd.g_old_rec;
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
          <> pay_pbc_shd.g_old_rec.object_version_number) Then
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
    ,p_base_table_name       => 'pay_balance_categories_f'
    ,p_base_key_column       => 'balance_category_id'
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
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'pay_balance_categories_f'
   ,p_base_key_column               => 'balance_category_id'
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
  l_proc                  varchar2(72) := g_package||'upd_effective_end_date';
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
      (p_base_table_name    => 'pay_balance_categories_f'
      ,p_base_key_column    => 'balance_category_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_balance_categories_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.balance_category_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_balance_category_id              in number
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
     balance_category_id
    ,category_name
    ,effective_start_date
    ,effective_end_date
    ,legislation_code
    ,business_group_id
    ,save_run_balance_enabled
    ,user_category_name
    ,pbc_information_category
    ,pbc_information1
    ,pbc_information2
    ,pbc_information3
    ,pbc_information4
    ,pbc_information5
    ,pbc_information6
    ,pbc_information7
    ,pbc_information8
    ,pbc_information9
    ,pbc_information10
    ,pbc_information11
    ,pbc_information12
    ,pbc_information13
    ,pbc_information14
    ,pbc_information15
    ,pbc_information16
    ,pbc_information17
    ,pbc_information18
    ,pbc_information19
    ,pbc_information20
    ,pbc_information21
    ,pbc_information22
    ,pbc_information23
    ,pbc_information24
    ,pbc_information25
    ,pbc_information26
    ,pbc_information27
    ,pbc_information28
    ,pbc_information29
    ,pbc_information30
    ,object_version_number
    from    pay_balance_categories_f
    where   balance_category_id = p_balance_category_id
    and     p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  --
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
                            ,p_argument       => 'balance_category_id'
                            ,p_argument_value => p_balance_category_id
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
    Fetch C_Sel1 Into pay_pbc_shd.g_old_rec;
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
          <> pay_pbc_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_balance_categories_f'
      ,p_base_key_column         => 'balance_category_id'
      ,p_base_key_value          => p_balance_category_id
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
    fnd_message.set_token('TABLE_NAME', 'pay_balance_categories_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_balance_category_id            in number
  ,p_category_name                  in varchar2
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_legislation_code               in varchar2
  ,p_business_group_id              in number
  ,p_save_run_balance_enabled       in varchar2
  ,p_user_category_name             in varchar2
  ,p_pbc_information_category       in varchar2
  ,p_pbc_information1               in varchar2
  ,p_pbc_information2               in varchar2
  ,p_pbc_information3               in varchar2
  ,p_pbc_information4               in varchar2
  ,p_pbc_information5               in varchar2
  ,p_pbc_information6               in varchar2
  ,p_pbc_information7               in varchar2
  ,p_pbc_information8               in varchar2
  ,p_pbc_information9               in varchar2
  ,p_pbc_information10              in varchar2
  ,p_pbc_information11              in varchar2
  ,p_pbc_information12              in varchar2
  ,p_pbc_information13              in varchar2
  ,p_pbc_information14              in varchar2
  ,p_pbc_information15              in varchar2
  ,p_pbc_information16              in varchar2
  ,p_pbc_information17              in varchar2
  ,p_pbc_information18              in varchar2
  ,p_pbc_information19              in varchar2
  ,p_pbc_information20              in varchar2
  ,p_pbc_information21              in varchar2
  ,p_pbc_information22              in varchar2
  ,p_pbc_information23              in varchar2
  ,p_pbc_information24              in varchar2
  ,p_pbc_information25              in varchar2
  ,p_pbc_information26              in varchar2
  ,p_pbc_information27              in varchar2
  ,p_pbc_information28              in varchar2
  ,p_pbc_information29              in varchar2
  ,p_pbc_information30              in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.balance_category_id              := p_balance_category_id;
  l_rec.category_name                    := p_category_name;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.save_run_balance_enabled         := p_save_run_balance_enabled;
  l_rec.user_category_name               := p_user_category_name;
  l_rec.pbc_information_category         := p_pbc_information_category;
  l_rec.pbc_information1                 := p_pbc_information1;
  l_rec.pbc_information2                 := p_pbc_information2;
  l_rec.pbc_information3                 := p_pbc_information3;
  l_rec.pbc_information4                 := p_pbc_information4;
  l_rec.pbc_information5                 := p_pbc_information5;
  l_rec.pbc_information6                 := p_pbc_information6;
  l_rec.pbc_information7                 := p_pbc_information7;
  l_rec.pbc_information8                 := p_pbc_information8;
  l_rec.pbc_information9                 := p_pbc_information9;
  l_rec.pbc_information10                := p_pbc_information10;
  l_rec.pbc_information11                := p_pbc_information11;
  l_rec.pbc_information12                := p_pbc_information12;
  l_rec.pbc_information13                := p_pbc_information13;
  l_rec.pbc_information14                := p_pbc_information14;
  l_rec.pbc_information15                := p_pbc_information15;
  l_rec.pbc_information16                := p_pbc_information16;
  l_rec.pbc_information17                := p_pbc_information17;
  l_rec.pbc_information18                := p_pbc_information18;
  l_rec.pbc_information19                := p_pbc_information19;
  l_rec.pbc_information20                := p_pbc_information20;
  l_rec.pbc_information21                := p_pbc_information21;
  l_rec.pbc_information22                := p_pbc_information22;
  l_rec.pbc_information23                := p_pbc_information23;
  l_rec.pbc_information24                := p_pbc_information24;
  l_rec.pbc_information25                := p_pbc_information25;
  l_rec.pbc_information26                := p_pbc_information26;
  l_rec.pbc_information27                := p_pbc_information27;
  l_rec.pbc_information28                := p_pbc_information28;
  l_rec.pbc_information29                := p_pbc_information29;
  l_rec.pbc_information30                := p_pbc_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_pbc_shd;

/
