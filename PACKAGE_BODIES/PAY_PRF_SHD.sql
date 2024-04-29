--------------------------------------------------------
--  DDL for Package Body PAY_PRF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRF_SHD" as
 /* $Header: pyprfrhi.pkb 120.0 2005/05/29 07:49:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prf_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_RANGE_TABLE_UK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_RANGE_TABLE_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_RANGE_TABLE_UK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PERIOD_FREQ_F_NN') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'RANGE_TABLE_F_NN') Then
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
  (p_range_table_id                       in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       range_table_id
      ,effective_start_date
      ,effective_end_date
      ,range_table_number
      ,row_value_uom
      ,period_frequency
      ,earnings_type
      ,business_group_id
      ,legislation_code
      ,last_updated_login
      ,created_date
      ,object_version_number
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
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,ran_information_category
      ,ran_information1
      ,ran_information2
      ,ran_information3
      ,ran_information4
      ,ran_information5
      ,ran_information6
      ,ran_information7
      ,ran_information8
      ,ran_information9
      ,ran_information10
      ,ran_information11
      ,ran_information12
      ,ran_information13
      ,ran_information14
      ,ran_information15
      ,ran_information16
      ,ran_information17
      ,ran_information18
      ,ran_information19
      ,ran_information20
      ,ran_information21
      ,ran_information22
      ,ran_information23
      ,ran_information24
      ,ran_information25
      ,ran_information26
      ,ran_information27
      ,ran_information28
      ,ran_information29
      ,ran_information30
    from        pay_range_tables_f
    where       range_table_id = p_range_table_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_range_table_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_range_table_id
        = pay_prf_shd.g_old_rec.range_table_id and
        p_object_version_number
        = pay_prf_shd.g_old_rec.object_version_number
       ) Then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into pay_prf_shd.g_old_rec;
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
          <> pay_prf_shd.g_old_rec.object_version_number) Then
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
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_range_table_id                       in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       range_table_id
      ,effective_start_date
      ,effective_end_date
      ,range_table_number
      ,row_value_uom
      ,period_frequency
      ,earnings_type
      ,business_group_id
      ,legislation_code
      ,last_updated_login
      ,created_date
      ,object_version_number
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
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,ran_information_category
      ,ran_information1
      ,ran_information2
      ,ran_information3
      ,ran_information4
      ,ran_information5
      ,ran_information6
      ,ran_information7
      ,ran_information8
      ,ran_information9
      ,ran_information10
      ,ran_information11
      ,ran_information12
      ,ran_information13
      ,ran_information14
      ,ran_information15
      ,ran_information16
      ,ran_information17
      ,ran_information18
      ,ran_information19
      ,ran_information20
      ,ran_information21
      ,ran_information22
      ,ran_information23
      ,ran_information24
      ,ran_information25
      ,ran_information26
      ,ran_information27
      ,ran_information28
      ,ran_information29
      ,ran_information30
    from        pay_range_tables_f
    where       range_table_id = p_range_table_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RANGE_TABLE_ID'
    ,p_argument_value     => p_range_table_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_prf_shd.g_old_rec;
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
      <> pay_prf_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
    fnd_message.set_token('TABLE_NAME', 'pay_range_tables_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_range_table_id                 in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_range_table_number             in number
  ,p_row_value_uom                  in varchar2
  ,p_period_frequency               in varchar2
  ,p_earnings_type                  in varchar2
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_last_updated_login             in number
  ,p_created_date                   in date
  ,p_object_version_number          in number
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
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  ,p_ran_information_category       in varchar2
  ,p_ran_information1               in varchar2
  ,p_ran_information2               in varchar2
  ,p_ran_information3               in varchar2
  ,p_ran_information4               in varchar2
  ,p_ran_information5               in varchar2
  ,p_ran_information6               in varchar2
  ,p_ran_information7               in varchar2
  ,p_ran_information8               in varchar2
  ,p_ran_information9               in varchar2
  ,p_ran_information10              in varchar2
  ,p_ran_information11              in varchar2
  ,p_ran_information12              in varchar2
  ,p_ran_information13              in varchar2
  ,p_ran_information14              in varchar2
  ,p_ran_information15              in varchar2
  ,p_ran_information16              in varchar2
  ,p_ran_information17              in varchar2
  ,p_ran_information18              in varchar2
  ,p_ran_information19              in varchar2
  ,p_ran_information20              in varchar2
  ,p_ran_information21              in varchar2
  ,p_ran_information22              in varchar2
  ,p_ran_information23              in varchar2
  ,p_ran_information24              in varchar2
  ,p_ran_information25              in varchar2
  ,p_ran_information26              in varchar2
  ,p_ran_information27              in varchar2
  ,p_ran_information28              in varchar2
  ,p_ran_information29              in varchar2
  ,p_ran_information30              in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.range_table_id                   := p_range_table_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.range_table_number               := p_range_table_number;
  l_rec.row_value_uom                    := p_row_value_uom;
  l_rec.period_frequency                 := p_period_frequency;
  l_rec.earnings_type                    := p_earnings_type;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.last_updated_login               := p_last_updated_login;
  l_rec.created_date                     := p_created_date;
  l_rec.object_version_number            := p_object_version_number;
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
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.ran_information_category         := p_ran_information_category;
  l_rec.ran_information1                 := p_ran_information1;
  l_rec.ran_information2                 := p_ran_information2;
  l_rec.ran_information3                 := p_ran_information3;
  l_rec.ran_information4                 := p_ran_information4;
  l_rec.ran_information5                 := p_ran_information5;
  l_rec.ran_information6                 := p_ran_information6;
  l_rec.ran_information7                 := p_ran_information7;
  l_rec.ran_information8                 := p_ran_information8;
  l_rec.ran_information9                 := p_ran_information9;
  l_rec.ran_information10                := p_ran_information10;
  l_rec.ran_information11                := p_ran_information11;
  l_rec.ran_information12                := p_ran_information12;
  l_rec.ran_information13                := p_ran_information13;
  l_rec.ran_information14                := p_ran_information14;
  l_rec.ran_information15                := p_ran_information15;
  l_rec.ran_information16                := p_ran_information16;
  l_rec.ran_information17                := p_ran_information17;
  l_rec.ran_information18                := p_ran_information18;
  l_rec.ran_information19                := p_ran_information19;
  l_rec.ran_information20                := p_ran_information20;
  l_rec.ran_information21                := p_ran_information21;
  l_rec.ran_information22                := p_ran_information22;
  l_rec.ran_information23                := p_ran_information23;
  l_rec.ran_information24                := p_ran_information24;
  l_rec.ran_information25                := p_ran_information25;
  l_rec.ran_information26                := p_ran_information26;
  l_rec.ran_information27                := p_ran_information27;
  l_rec.ran_information28                := p_ran_information28;
  l_rec.ran_information29                := p_ran_information29;
  l_rec.ran_information30                := p_ran_information30;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_prf_shd;

/
