--------------------------------------------------------
--  DDL for Package Body HR_ORI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORI_SHD" as
/* $Header: hrorirhi.pkb 120.3.12010000.2 2008/08/06 08:45:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ori_shd.';  -- Global package name
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
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'HR_ORGANIZATION_INFORMATIO_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ORGANIZATION_INFORMATIO_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ORGANIZATION_INFORMATIO_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  (p_org_information_id                   in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       org_information_id
      ,org_information_context
      ,organization_id
      ,org_information1
      ,org_information10
      ,org_information11
      ,org_information12
      ,org_information13
      ,org_information14
      ,org_information15
      ,org_information16
      ,org_information17
      ,org_information18
      ,org_information19
      ,org_information2
      ,org_information20
      ,org_information3
      ,org_information4
      ,org_information5
      ,org_information6
      ,org_information7
      ,org_information8
      ,org_information9
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
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
      ,object_version_number
    from hr_organization_information
    where   org_information_id = p_org_information_id;
--
  l_fct_ret boolean;
--
Begin
  --
  If (p_org_information_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_org_information_id
        = hr_ori_shd.g_old_rec.org_information_id and
        p_object_version_number
        = hr_ori_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_ori_shd.g_old_rec;
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
          <> hr_ori_shd.g_old_rec.object_version_number) Then
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
  (p_org_information_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       org_information_id
      ,org_information_context
      ,organization_id
      ,org_information1
      ,org_information10
      ,org_information11
      ,org_information12
      ,org_information13
      ,org_information14
      ,org_information15
      ,org_information16
      ,org_information17
      ,org_information18
      ,org_information19
      ,org_information2
      ,org_information20
      ,org_information3
      ,org_information4
      ,org_information5
      ,org_information6
      ,org_information7
      ,org_information8
      ,org_information9
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
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
      ,object_version_number
    from hr_organization_information
    where   org_information_id = p_org_information_id
    for  update nowait;
--
  l_proc varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ORG_INFORMATION_ID'
    ,p_argument_value     => p_org_information_id
    );
  --Bug:1790746 fix Start
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument   => 'object_version_number'
    ,p_argument_value   => p_object_version_number
     );
  --Bug:1790746 fix End
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_ori_shd.g_old_rec;
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
      <> hr_ori_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_organization_information');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_org_information_id             in number
  ,p_org_information_context        in varchar2
  ,p_organization_id                in number
  ,p_org_information1               in varchar2
  ,p_org_information10              in varchar2
  ,p_org_information11              in varchar2
  ,p_org_information12              in varchar2
  ,p_org_information13              in varchar2
  ,p_org_information14              in varchar2
  ,p_org_information15              in varchar2
  ,p_org_information16              in varchar2
  ,p_org_information17              in varchar2
  ,p_org_information18              in varchar2
  ,p_org_information19              in varchar2
  ,p_org_information2               in varchar2
  ,p_org_information20              in varchar2
  ,p_org_information3               in varchar2
  ,p_org_information4               in varchar2
  ,p_org_information5               in varchar2
  ,p_org_information6               in varchar2
  ,p_org_information7               in varchar2
  ,p_org_information8               in varchar2
  ,p_org_information9               in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
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
  l_rec.org_information_id               := p_org_information_id;
  l_rec.org_information_context          := p_org_information_context;
  l_rec.organization_id                  := p_organization_id;
  l_rec.org_information1                 := p_org_information1;
  l_rec.org_information10                := p_org_information10;
  l_rec.org_information11                := p_org_information11;
  l_rec.org_information12                := p_org_information12;
  l_rec.org_information13                := p_org_information13;
  l_rec.org_information14                := p_org_information14;
  l_rec.org_information15                := p_org_information15;
  l_rec.org_information16                := p_org_information16;
  l_rec.org_information17                := p_org_information17;
  l_rec.org_information18                := p_org_information18;
  l_rec.org_information19                := p_org_information19;
  l_rec.org_information2                 := p_org_information2;
  l_rec.org_information20                := p_org_information20;
  l_rec.org_information3                 := p_org_information3;
  l_rec.org_information4                 := p_org_information4;
  l_rec.org_information5                 := p_org_information5;
  l_rec.org_information6                 := p_org_information6;
  l_rec.org_information7                 := p_org_information7;
  l_rec.org_information8                 := p_org_information8;
  l_rec.org_information9                 := p_org_information9;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
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
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_ori_shd;

/
