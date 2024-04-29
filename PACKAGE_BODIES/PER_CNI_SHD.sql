--------------------------------------------------------
--  DDL for Package Body PER_CNI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNI_SHD" as
/* $Header: pecnirhi.pkb 120.0 2005/05/31 06:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cni_shd.';  -- Global package name
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
  If (p_constraint_name = 'SYS_C00255171') Then
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
  (p_config_information_id                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       configuration_code
      ,config_information_category
      ,config_information1
      ,config_information2
      ,config_information3
      ,config_information4
      ,config_information5
      ,config_information6
      ,config_information7
      ,config_information8
      ,config_information9
      ,config_information10
      ,config_information11
      ,config_information12
      ,config_information13
      ,config_information14
      ,config_information15
      ,config_information16
      ,config_information17
      ,config_information18
      ,config_information19
      ,config_information20
      ,config_information21
      ,config_information22
      ,config_information23
      ,config_information24
      ,config_information25
      ,config_information26
      ,config_information27
      ,config_information28
      ,config_information29
      ,config_information30
      ,config_information_id
      ,config_sequence
      ,object_version_number
    from        per_ri_config_information
    where       config_information_id = p_config_information_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_config_information_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_config_information_id
        = per_cni_shd.g_old_rec.config_information_id
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
      Fetch C_Sel1 Into per_cni_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      --
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
  (p_config_information_id In Number
  ,p_object_version_number In Number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       configuration_code
      ,config_information_category
      ,config_information1
      ,config_information2
      ,config_information3
      ,config_information4
      ,config_information5
      ,config_information6
      ,config_information7
      ,config_information8
      ,config_information9
      ,config_information10
      ,config_information11
      ,config_information12
      ,config_information13
      ,config_information14
      ,config_information15
      ,config_information16
      ,config_information17
      ,config_information18
      ,config_information19
      ,config_information20
      ,config_information21
      ,config_information22
      ,config_information23
      ,config_information24
      ,config_information25
      ,config_information26
      ,config_information27
      ,config_information28
      ,config_information29
      ,config_information30
      ,config_information_id
      ,config_sequence
      ,object_version_number
    from        per_ri_config_information
    where       config_information_id = p_config_information_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CONFIG_INFORMATION_ID'
    ,p_argument_value     => p_config_information_id
    );

  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );

  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_cni_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --

  If (p_object_version_number <> per_wbi_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_ri_config_information');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_configuration_code             in varchar2
  ,p_config_information_category    in varchar2
  ,p_config_information1            in varchar2
  ,p_config_information2            in varchar2
  ,p_config_information3            in varchar2
  ,p_config_information4            in varchar2
  ,p_config_information5            in varchar2
  ,p_config_information6            in varchar2
  ,p_config_information7            in varchar2
  ,p_config_information8            in varchar2
  ,p_config_information9            in varchar2
  ,p_config_information10           in varchar2
  ,p_config_information11           in varchar2
  ,p_config_information12           in varchar2
  ,p_config_information13           in varchar2
  ,p_config_information14           in varchar2
  ,p_config_information15           in varchar2
  ,p_config_information16           in varchar2
  ,p_config_information17           in varchar2
  ,p_config_information18           in varchar2
  ,p_config_information19           in varchar2
  ,p_config_information20           in varchar2
  ,p_config_information21           in varchar2
  ,p_config_information22           in varchar2
  ,p_config_information23           in varchar2
  ,p_config_information24           in varchar2
  ,p_config_information25           in varchar2
  ,p_config_information26           in varchar2
  ,p_config_information27           in varchar2
  ,p_config_information28           in varchar2
  ,p_config_information29           in varchar2
  ,p_config_information30           in varchar2
  ,p_config_information_id          in number
  ,p_config_sequence                in number
  ,p_object_version_number          In Number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.configuration_code               := p_configuration_code;
  l_rec.config_information_category      := p_config_information_category;
  l_rec.config_information1              := p_config_information1;
  l_rec.config_information2              := p_config_information2;
  l_rec.config_information3              := p_config_information3;
  l_rec.config_information4              := p_config_information4;
  l_rec.config_information5              := p_config_information5;
  l_rec.config_information6              := p_config_information6;
  l_rec.config_information7              := p_config_information7;
  l_rec.config_information8              := p_config_information8;
  l_rec.config_information9              := p_config_information9;
  l_rec.config_information10             := p_config_information10;
  l_rec.config_information11             := p_config_information11;
  l_rec.config_information12             := p_config_information12;
  l_rec.config_information13             := p_config_information13;
  l_rec.config_information14             := p_config_information14;
  l_rec.config_information15             := p_config_information15;
  l_rec.config_information16             := p_config_information16;
  l_rec.config_information17             := p_config_information17;
  l_rec.config_information18             := p_config_information18;
  l_rec.config_information19             := p_config_information19;
  l_rec.config_information20             := p_config_information20;
  l_rec.config_information21             := p_config_information21;
  l_rec.config_information22             := p_config_information22;
  l_rec.config_information23             := p_config_information23;
  l_rec.config_information24             := p_config_information24;
  l_rec.config_information25             := p_config_information25;
  l_rec.config_information26             := p_config_information26;
  l_rec.config_information27             := p_config_information27;
  l_rec.config_information28             := p_config_information28;
  l_rec.config_information29             := p_config_information29;
  l_rec.config_information30             := p_config_information30;
  l_rec.config_information_id            := p_config_information_id;
  l_rec.config_sequence                  := p_config_sequence;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_cni_shd;

/
