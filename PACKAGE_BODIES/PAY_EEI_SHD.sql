--------------------------------------------------------
--  DDL for Package Body PAY_EEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EEI_SHD" as
/* $Header: pyeeirhi.pkb 120.11 2006/07/12 05:28:45 vikgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_eei_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_ELEMENT_TYPE_EXTRA_INFO_FK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_TYPE_EXTRA_INFO_PK') Then
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
  (p_element_type_extra_info_id           in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       element_type_extra_info_id
      ,element_type_id
      ,information_type
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,eei_attribute_category
      ,eei_attribute1
      ,eei_attribute2
      ,eei_attribute3
      ,eei_attribute4
      ,eei_attribute5
      ,eei_attribute6
      ,eei_attribute7
      ,eei_attribute8
      ,eei_attribute9
      ,eei_attribute10
      ,eei_attribute11
      ,eei_attribute12
      ,eei_attribute13
      ,eei_attribute14
      ,eei_attribute15
      ,eei_attribute16
      ,eei_attribute17
      ,eei_attribute18
      ,eei_attribute19
      ,eei_attribute20
      ,eei_information_category
      ,eei_information1
      ,eei_information2
      ,eei_information3
      ,eei_information4
      ,eei_information5
      ,eei_information6
      ,eei_information7
      ,eei_information8
      ,eei_information9
      ,eei_information10
      ,eei_information11
      ,eei_information12
      ,eei_information13
      ,eei_information14
      ,eei_information15
      ,eei_information16
      ,eei_information17
      ,eei_information18
      ,eei_information19
      ,eei_information20
      ,eei_information21
      ,eei_information22
      ,eei_information23
      ,eei_information24
      ,eei_information25
      ,eei_information26
      ,eei_information27
      ,eei_information28
      ,eei_information29
      ,eei_information30
      ,object_version_number
    from	pay_element_type_extra_info
    where	element_type_extra_info_id = p_element_type_extra_info_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_element_type_extra_info_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_element_type_extra_info_id
        = pay_eei_shd.g_old_rec.element_type_extra_info_id and
        p_object_version_number
        = pay_eei_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_eei_shd.g_old_rec;
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
          <> pay_eei_shd.g_old_rec.object_version_number) Then
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
  (p_element_type_extra_info_id           in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       element_type_extra_info_id
      ,element_type_id
      ,information_type
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,eei_attribute_category
      ,eei_attribute1
      ,eei_attribute2
      ,eei_attribute3
      ,eei_attribute4
      ,eei_attribute5
      ,eei_attribute6
      ,eei_attribute7
      ,eei_attribute8
      ,eei_attribute9
      ,eei_attribute10
      ,eei_attribute11
      ,eei_attribute12
      ,eei_attribute13
      ,eei_attribute14
      ,eei_attribute15
      ,eei_attribute16
      ,eei_attribute17
      ,eei_attribute18
      ,eei_attribute19
      ,eei_attribute20
      ,eei_information_category
      ,eei_information1
      ,eei_information2
      ,eei_information3
      ,eei_information4
      ,eei_information5
      ,eei_information6
      ,eei_information7
      ,eei_information8
      ,eei_information9
      ,eei_information10
      ,eei_information11
      ,eei_information12
      ,eei_information13
      ,eei_information14
      ,eei_information15
      ,eei_information16
      ,eei_information17
      ,eei_information18
      ,eei_information19
      ,eei_information20
      ,eei_information21
      ,eei_information22
      ,eei_information23
      ,eei_information24
      ,eei_information25
      ,eei_information26
      ,eei_information27
      ,eei_information28
      ,eei_information29
      ,eei_information30
      ,object_version_number
    from	pay_element_type_extra_info
    where	element_type_extra_info_id = p_element_type_extra_info_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ELEMENT_TYPE_EXTRA_INFO_ID'
    ,p_argument_value     => p_element_type_extra_info_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_eei_shd.g_old_rec;
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
      <> pay_eei_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_element_type_extra_info');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_element_type_extra_info_id     in number
  ,p_element_type_id                in number
  ,p_information_type               in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  ,p_eei_attribute_category         in varchar2
  ,p_eei_attribute1                 in varchar2
  ,p_eei_attribute2                 in varchar2
  ,p_eei_attribute3                 in varchar2
  ,p_eei_attribute4                 in varchar2
  ,p_eei_attribute5                 in varchar2
  ,p_eei_attribute6                 in varchar2
  ,p_eei_attribute7                 in varchar2
  ,p_eei_attribute8                 in varchar2
  ,p_eei_attribute9                 in varchar2
  ,p_eei_attribute10                in varchar2
  ,p_eei_attribute11                in varchar2
  ,p_eei_attribute12                in varchar2
  ,p_eei_attribute13                in varchar2
  ,p_eei_attribute14                in varchar2
  ,p_eei_attribute15                in varchar2
  ,p_eei_attribute16                in varchar2
  ,p_eei_attribute17                in varchar2
  ,p_eei_attribute18                in varchar2
  ,p_eei_attribute19                in varchar2
  ,p_eei_attribute20                in varchar2
  ,p_eei_information_category       in varchar2
  ,p_eei_information1               in varchar2
  ,p_eei_information2               in varchar2
  ,p_eei_information3               in varchar2
  ,p_eei_information4               in varchar2
  ,p_eei_information5               in varchar2
  ,p_eei_information6               in varchar2
  ,p_eei_information7               in varchar2
  ,p_eei_information8               in varchar2
  ,p_eei_information9               in varchar2
  ,p_eei_information10              in varchar2
  ,p_eei_information11              in varchar2
  ,p_eei_information12              in varchar2
  ,p_eei_information13              in varchar2
  ,p_eei_information14              in varchar2
  ,p_eei_information15              in varchar2
  ,p_eei_information16              in varchar2
  ,p_eei_information17              in varchar2
  ,p_eei_information18              in varchar2
  ,p_eei_information19              in varchar2
  ,p_eei_information20              in varchar2
  ,p_eei_information21              in varchar2
  ,p_eei_information22              in varchar2
  ,p_eei_information23              in varchar2
  ,p_eei_information24              in varchar2
  ,p_eei_information25              in varchar2
  ,p_eei_information26              in varchar2
  ,p_eei_information27              in varchar2
  ,p_eei_information28              in varchar2
  ,p_eei_information29              in varchar2
  ,p_eei_information30              in varchar2
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
  l_rec.element_type_extra_info_id       := p_element_type_extra_info_id;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.information_type                 := p_information_type;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.eei_attribute_category           := p_eei_attribute_category;
  l_rec.eei_attribute1                   := p_eei_attribute1;
  l_rec.eei_attribute2                   := p_eei_attribute2;
  l_rec.eei_attribute3                   := p_eei_attribute3;
  l_rec.eei_attribute4                   := p_eei_attribute4;
  l_rec.eei_attribute5                   := p_eei_attribute5;
  l_rec.eei_attribute6                   := p_eei_attribute6;
  l_rec.eei_attribute7                   := p_eei_attribute7;
  l_rec.eei_attribute8                   := p_eei_attribute8;
  l_rec.eei_attribute9                   := p_eei_attribute9;
  l_rec.eei_attribute10                  := p_eei_attribute10;
  l_rec.eei_attribute11                  := p_eei_attribute11;
  l_rec.eei_attribute12                  := p_eei_attribute12;
  l_rec.eei_attribute13                  := p_eei_attribute13;
  l_rec.eei_attribute14                  := p_eei_attribute14;
  l_rec.eei_attribute15                  := p_eei_attribute15;
  l_rec.eei_attribute16                  := p_eei_attribute16;
  l_rec.eei_attribute17                  := p_eei_attribute17;
  l_rec.eei_attribute18                  := p_eei_attribute18;
  l_rec.eei_attribute19                  := p_eei_attribute19;
  l_rec.eei_attribute20                  := p_eei_attribute20;
  l_rec.eei_information_category         := p_eei_information_category;
  l_rec.eei_information1                 := p_eei_information1;
  l_rec.eei_information2                 := p_eei_information2;
  l_rec.eei_information3                 := p_eei_information3;
  l_rec.eei_information4                 := p_eei_information4;
  l_rec.eei_information5                 := p_eei_information5;
  l_rec.eei_information6                 := p_eei_information6;
  l_rec.eei_information7                 := p_eei_information7;
  l_rec.eei_information8                 := p_eei_information8;
  l_rec.eei_information9                 := p_eei_information9;
  l_rec.eei_information10                := p_eei_information10;
  l_rec.eei_information11                := p_eei_information11;
  l_rec.eei_information12                := p_eei_information12;
  l_rec.eei_information13                := p_eei_information13;
  l_rec.eei_information14                := p_eei_information14;
  l_rec.eei_information15                := p_eei_information15;
  l_rec.eei_information16                := p_eei_information16;
  l_rec.eei_information17                := p_eei_information17;
  l_rec.eei_information18                := p_eei_information18;
  l_rec.eei_information19                := p_eei_information19;
  l_rec.eei_information20                := p_eei_information20;
  l_rec.eei_information21                := p_eei_information21;
  l_rec.eei_information22                := p_eei_information22;
  l_rec.eei_information23                := p_eei_information23;
  l_rec.eei_information24                := p_eei_information24;
  l_rec.eei_information25                := p_eei_information25;
  l_rec.eei_information26                := p_eei_information26;
  l_rec.eei_information27                := p_eei_information27;
  l_rec.eei_information28                := p_eei_information28;
  l_rec.eei_information29                := p_eei_information29;
  l_rec.eei_information30                := p_eei_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_eei_shd;

/
