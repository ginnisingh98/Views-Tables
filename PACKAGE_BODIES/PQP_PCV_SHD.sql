--------------------------------------------------------
--  DDL for Package Body PQP_PCV_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PCV_SHD" as
/* $Header: pqpcvrhi.pkb 120.0 2005/05/29 01:55:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pcv_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQP_CONFIGURATION_VALUES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
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
  (p_configuration_value_id               in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       configuration_value_id
      ,business_group_id
      ,legislation_code
      ,pcv_attribute_category
      ,pcv_attribute1
      ,pcv_attribute2
      ,pcv_attribute3
      ,pcv_attribute4
      ,pcv_attribute5
      ,pcv_attribute6
      ,pcv_attribute7
      ,pcv_attribute8
      ,pcv_attribute9
      ,pcv_attribute10
      ,pcv_attribute11
      ,pcv_attribute12
      ,pcv_attribute13
      ,pcv_attribute14
      ,pcv_attribute15
      ,pcv_attribute16
      ,pcv_attribute17
      ,pcv_attribute18
      ,pcv_attribute19
      ,pcv_attribute20
      ,pcv_information_category
      ,pcv_information1
      ,pcv_information2
      ,pcv_information3
      ,pcv_information4
      ,pcv_information5
      ,pcv_information6
      ,pcv_information7
      ,pcv_information8
      ,pcv_information9
      ,pcv_information10
      ,pcv_information11
      ,pcv_information12
      ,pcv_information13
      ,pcv_information14
      ,pcv_information15
      ,pcv_information16
      ,pcv_information17
      ,pcv_information18
      ,pcv_information19
      ,pcv_information20
      ,object_version_number
      ,configuration_name
    from        pqp_configuration_values
    where       configuration_value_id = p_configuration_value_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_configuration_value_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_configuration_value_id
        = pqp_pcv_shd.g_old_rec.configuration_value_id and
        p_object_version_number
        = pqp_pcv_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_pcv_shd.g_old_rec;
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
          <> pqp_pcv_shd.g_old_rec.object_version_number) Then
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
  (p_configuration_value_id               in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       configuration_value_id
      ,business_group_id
      ,legislation_code
      ,pcv_attribute_category
      ,pcv_attribute1
      ,pcv_attribute2
      ,pcv_attribute3
      ,pcv_attribute4
      ,pcv_attribute5
      ,pcv_attribute6
      ,pcv_attribute7
      ,pcv_attribute8
      ,pcv_attribute9
      ,pcv_attribute10
      ,pcv_attribute11
      ,pcv_attribute12
      ,pcv_attribute13
      ,pcv_attribute14
      ,pcv_attribute15
      ,pcv_attribute16
      ,pcv_attribute17
      ,pcv_attribute18
      ,pcv_attribute19
      ,pcv_attribute20
      ,pcv_information_category
      ,pcv_information1
      ,pcv_information2
      ,pcv_information3
      ,pcv_information4
      ,pcv_information5
      ,pcv_information6
      ,pcv_information7
      ,pcv_information8
      ,pcv_information9
      ,pcv_information10
      ,pcv_information11
      ,pcv_information12
      ,pcv_information13
      ,pcv_information14
      ,pcv_information15
      ,pcv_information16
      ,pcv_information17
      ,pcv_information18
      ,pcv_information19
      ,pcv_information20
      ,object_version_number
      ,configuration_name
    from        pqp_configuration_values
    where       configuration_value_id = p_configuration_value_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CONFIGURATION_VALUE_ID'
    ,p_argument_value     => p_configuration_value_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_pcv_shd.g_old_rec;
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
      <> pqp_pcv_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqp_configuration_values');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_configuration_value_id         in number
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_pcv_attribute_category         in varchar2
  ,p_pcv_attribute1                 in varchar2
  ,p_pcv_attribute2                 in varchar2
  ,p_pcv_attribute3                 in varchar2
  ,p_pcv_attribute4                 in varchar2
  ,p_pcv_attribute5                 in varchar2
  ,p_pcv_attribute6                 in varchar2
  ,p_pcv_attribute7                 in varchar2
  ,p_pcv_attribute8                 in varchar2
  ,p_pcv_attribute9                 in varchar2
  ,p_pcv_attribute10                in varchar2
  ,p_pcv_attribute11                in varchar2
  ,p_pcv_attribute12                in varchar2
  ,p_pcv_attribute13                in varchar2
  ,p_pcv_attribute14                in varchar2
  ,p_pcv_attribute15                in varchar2
  ,p_pcv_attribute16                in varchar2
  ,p_pcv_attribute17                in varchar2
  ,p_pcv_attribute18                in varchar2
  ,p_pcv_attribute19                in varchar2
  ,p_pcv_attribute20                in varchar2
  ,p_pcv_information_category       in varchar2
  ,p_pcv_information1               in varchar2
  ,p_pcv_information2               in varchar2
  ,p_pcv_information3               in varchar2
  ,p_pcv_information4               in varchar2
  ,p_pcv_information5               in varchar2
  ,p_pcv_information6               in varchar2
  ,p_pcv_information7               in varchar2
  ,p_pcv_information8               in varchar2
  ,p_pcv_information9               in varchar2
  ,p_pcv_information10              in varchar2
  ,p_pcv_information11              in varchar2
  ,p_pcv_information12              in varchar2
  ,p_pcv_information13              in varchar2
  ,p_pcv_information14              in varchar2
  ,p_pcv_information15              in varchar2
  ,p_pcv_information16              in varchar2
  ,p_pcv_information17              in varchar2
  ,p_pcv_information18              in varchar2
  ,p_pcv_information19              in varchar2
  ,p_pcv_information20              in varchar2
  ,p_object_version_number          in number
  ,p_configuration_name             in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.configuration_value_id           := p_configuration_value_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.pcv_attribute_category           := p_pcv_attribute_category;
  l_rec.pcv_attribute1                   := p_pcv_attribute1;
  l_rec.pcv_attribute2                   := p_pcv_attribute2;
  l_rec.pcv_attribute3                   := p_pcv_attribute3;
  l_rec.pcv_attribute4                   := p_pcv_attribute4;
  l_rec.pcv_attribute5                   := p_pcv_attribute5;
  l_rec.pcv_attribute6                   := p_pcv_attribute6;
  l_rec.pcv_attribute7                   := p_pcv_attribute7;
  l_rec.pcv_attribute8                   := p_pcv_attribute8;
  l_rec.pcv_attribute9                   := p_pcv_attribute9;
  l_rec.pcv_attribute10                  := p_pcv_attribute10;
  l_rec.pcv_attribute11                  := p_pcv_attribute11;
  l_rec.pcv_attribute12                  := p_pcv_attribute12;
  l_rec.pcv_attribute13                  := p_pcv_attribute13;
  l_rec.pcv_attribute14                  := p_pcv_attribute14;
  l_rec.pcv_attribute15                  := p_pcv_attribute15;
  l_rec.pcv_attribute16                  := p_pcv_attribute16;
  l_rec.pcv_attribute17                  := p_pcv_attribute17;
  l_rec.pcv_attribute18                  := p_pcv_attribute18;
  l_rec.pcv_attribute19                  := p_pcv_attribute19;
  l_rec.pcv_attribute20                  := p_pcv_attribute20;
  l_rec.pcv_information_category         := p_pcv_information_category;
  l_rec.pcv_information1                 := p_pcv_information1;
  l_rec.pcv_information2                 := p_pcv_information2;
  l_rec.pcv_information3                 := p_pcv_information3;
  l_rec.pcv_information4                 := p_pcv_information4;
  l_rec.pcv_information5                 := p_pcv_information5;
  l_rec.pcv_information6                 := p_pcv_information6;
  l_rec.pcv_information7                 := p_pcv_information7;
  l_rec.pcv_information8                 := p_pcv_information8;
  l_rec.pcv_information9                 := p_pcv_information9;
  l_rec.pcv_information10                := p_pcv_information10;
  l_rec.pcv_information11                := p_pcv_information11;
  l_rec.pcv_information12                := p_pcv_information12;
  l_rec.pcv_information13                := p_pcv_information13;
  l_rec.pcv_information14                := p_pcv_information14;
  l_rec.pcv_information15                := p_pcv_information15;
  l_rec.pcv_information16                := p_pcv_information16;
  l_rec.pcv_information17                := p_pcv_information17;
  l_rec.pcv_information18                := p_pcv_information18;
  l_rec.pcv_information19                := p_pcv_information19;
  l_rec.pcv_information20                := p_pcv_information20;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.configuration_name               := p_configuration_name;

  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_pcv_shd;

/
