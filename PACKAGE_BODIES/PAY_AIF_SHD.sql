--------------------------------------------------------
--  DDL for Package Body PAY_AIF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AIF_SHD" as
/* $Header: pyaifrhi.pkb 120.2.12000000.2 2007/03/30 05:34:36 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aif_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_ACTION_INFORMATION_PK') Then
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
  (p_action_information_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       action_information_id
      ,action_context_id
      ,action_context_type
      ,tax_unit_id
      ,jurisdiction_code
      ,source_id
      ,source_text
      ,tax_group
      ,object_version_number
      ,effective_date
      ,assignment_id
      ,action_information_category
      ,action_information1
      ,action_information2
      ,action_information3
      ,action_information4
      ,action_information5
      ,action_information6
      ,action_information7
      ,action_information8
      ,action_information9
      ,action_information10
      ,action_information11
      ,action_information12
      ,action_information13
      ,action_information14
      ,action_information15
      ,action_information16
      ,action_information17
      ,action_information18
      ,action_information19
      ,action_information20
      ,action_information21
      ,action_information22
      ,action_information23
      ,action_information24
      ,action_information25
      ,action_information26
      ,action_information27
      ,action_information28
      ,action_information29
      ,action_information30
    from	pay_action_information
    where	action_information_id = p_action_information_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_action_information_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_action_information_id
        = pay_aif_shd.g_old_rec.action_information_id and
        p_object_version_number
        = pay_aif_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_aif_shd.g_old_rec;
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
          <> pay_aif_shd.g_old_rec.object_version_number) Then
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
  (p_action_information_id                in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       action_information_id
      ,action_context_id
      ,action_context_type
      ,tax_unit_id
      ,jurisdiction_code
      ,source_id
      ,source_text
      ,tax_group
      ,object_version_number
      ,effective_date
      ,assignment_id
      ,action_information_category
      ,action_information1
      ,action_information2
      ,action_information3
      ,action_information4
      ,action_information5
      ,action_information6
      ,action_information7
      ,action_information8
      ,action_information9
      ,action_information10
      ,action_information11
      ,action_information12
      ,action_information13
      ,action_information14
      ,action_information15
      ,action_information16
      ,action_information17
      ,action_information18
      ,action_information19
      ,action_information20
      ,action_information21
      ,action_information22
      ,action_information23
      ,action_information24
      ,action_information25
      ,action_information26
      ,action_information27
      ,action_information28
      ,action_information29
      ,action_information30
    from	pay_action_information
    where	action_information_id = p_action_information_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ACTION_INFORMATION_ID'
    ,p_argument_value     => p_action_information_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_aif_shd.g_old_rec;
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
      <> pay_aif_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_action_information');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_action_information_id          in number
  ,p_action_context_id              in number
  ,p_action_context_type            in varchar2
  ,p_tax_unit_id                    in number
  ,p_jurisdiction_code              in varchar2
  ,p_source_id                      in number
  ,p_source_text                    in varchar2
  ,p_tax_group                      in varchar2
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  ,p_assignment_id                  in number
  ,p_action_information_category    in varchar2
  ,p_action_information1            in varchar2
  ,p_action_information2            in varchar2
  ,p_action_information3            in varchar2
  ,p_action_information4            in varchar2
  ,p_action_information5            in varchar2
  ,p_action_information6            in varchar2
  ,p_action_information7            in varchar2
  ,p_action_information8            in varchar2
  ,p_action_information9            in varchar2
  ,p_action_information10           in varchar2
  ,p_action_information11           in varchar2
  ,p_action_information12           in varchar2
  ,p_action_information13           in varchar2
  ,p_action_information14           in varchar2
  ,p_action_information15           in varchar2
  ,p_action_information16           in varchar2
  ,p_action_information17           in varchar2
  ,p_action_information18           in varchar2
  ,p_action_information19           in varchar2
  ,p_action_information20           in varchar2
  ,p_action_information21           in varchar2
  ,p_action_information22           in varchar2
  ,p_action_information23           in varchar2
  ,p_action_information24           in varchar2
  ,p_action_information25           in varchar2
  ,p_action_information26           in varchar2
  ,p_action_information27           in varchar2
  ,p_action_information28           in varchar2
  ,p_action_information29           in varchar2
  ,p_action_information30           in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.action_information_id            := p_action_information_id;
  l_rec.action_context_id                := p_action_context_id;
  l_rec.action_context_type              := p_action_context_type;
  l_rec.tax_unit_id                      := p_tax_unit_id;
  l_rec.jurisdiction_code                := p_jurisdiction_code;
  l_rec.source_id                        := p_source_id;
  l_rec.source_text                      := p_source_text;
  l_rec.tax_group                        := p_tax_group;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.effective_date                   := p_effective_date;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.action_information_category      := p_action_information_category;
  l_rec.action_information1              := p_action_information1;
  l_rec.action_information2              := p_action_information2;
  l_rec.action_information3              := p_action_information3;
  l_rec.action_information4              := p_action_information4;
  l_rec.action_information5              := p_action_information5;
  l_rec.action_information6              := p_action_information6;
  l_rec.action_information7              := p_action_information7;
  l_rec.action_information8              := p_action_information8;
  l_rec.action_information9              := p_action_information9;
  l_rec.action_information10             := p_action_information10;
  l_rec.action_information11             := p_action_information11;
  l_rec.action_information12             := p_action_information12;
  l_rec.action_information13             := p_action_information13;
  l_rec.action_information14             := p_action_information14;
  l_rec.action_information15             := p_action_information15;
  l_rec.action_information16             := p_action_information16;
  l_rec.action_information17             := p_action_information17;
  l_rec.action_information18             := p_action_information18;
  l_rec.action_information19             := p_action_information19;
  l_rec.action_information20             := p_action_information20;
  l_rec.action_information21             := p_action_information21;
  l_rec.action_information22             := p_action_information22;
  l_rec.action_information23             := p_action_information23;
  l_rec.action_information24             := p_action_information24;
  l_rec.action_information25             := p_action_information25;
  l_rec.action_information26             := p_action_information26;
  l_rec.action_information27             := p_action_information27;
  l_rec.action_information28             := p_action_information28;
  l_rec.action_information29             := p_action_information29;
  l_rec.action_information30             := p_action_information30;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_aif_shd;

/
