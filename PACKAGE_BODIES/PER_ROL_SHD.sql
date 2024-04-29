--------------------------------------------------------
--  DDL for Package Body PER_ROL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ROL_SHD" as
/* $Header: perolrhi.pkb 120.0 2005/05/31 18:34:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rol_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_ROLES_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_ROLES_PK') Then
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
  (p_role_id                              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       role_id
      ,job_id
      ,job_group_id
      ,person_id
      ,organization_id
      ,start_date
      ,end_date
      ,confidential_date
      ,emp_rights_flag
      ,end_of_rights_date
      ,primary_contact_flag
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
      ,role_information_category
      ,role_information1
      ,role_information2
      ,role_information3
      ,role_information4
      ,role_information5
      ,role_information6
      ,role_information7
      ,role_information8
      ,role_information9
      ,role_information10
      ,role_information11
      ,role_information12
      ,role_information13
      ,role_information14
      ,role_information15
      ,role_information16
      ,role_information17
      ,role_information18
      ,role_information19
      ,role_information20
      ,object_version_number
      ,old_end_date -- fix 1370960
    from per_roles
    where   role_id = p_role_id;
--
  l_fct_ret boolean;
--
Begin
  --
  If (p_role_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_role_id
        = per_rol_shd.g_old_rec.role_id and
        p_object_version_number
        = per_rol_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_rol_shd.g_old_rec;
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
          <> per_rol_shd.g_old_rec.object_version_number) Then
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
  (p_role_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       role_id
      ,job_id
      ,job_group_id
      ,person_id
      ,organization_id
      ,start_date
      ,end_date
      ,confidential_date
      ,emp_rights_flag
      ,end_of_rights_date
      ,primary_contact_flag
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
      ,role_information_category
      ,role_information1
      ,role_information2
      ,role_information3
      ,role_information4
      ,role_information5
      ,role_information6
      ,role_information7
      ,role_information8
      ,role_information9
      ,role_information10
      ,role_information11
      ,role_information12
      ,role_information13
      ,role_information14
      ,role_information15
      ,role_information16
      ,role_information17
      ,role_information18
      ,role_information19
      ,role_information20
      ,object_version_number
      ,old_end_date -- fix 1370960
    from per_roles
    where   role_id = p_role_id
    for  update nowait;
--
  l_proc varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ROLE_ID'
    ,p_argument_value     => p_role_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_rol_shd.g_old_rec;
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
      <> per_rol_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_roles');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_role_id                        in number
  ,p_job_id                         in number
  ,p_job_group_id                   in number
  ,p_person_id                      in number
  ,p_organization_id                in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_confidential_date              in date
  ,p_emp_rights_flag                in varchar2
  ,p_end_of_rights_date             in date
  ,p_primary_contact_flag           in varchar2
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
  ,p_role_information_category      in varchar2
  ,p_role_information1              in varchar2
  ,p_role_information2              in varchar2
  ,p_role_information3              in varchar2
  ,p_role_information4              in varchar2
  ,p_role_information5              in varchar2
  ,p_role_information6              in varchar2
  ,p_role_information7              in varchar2
  ,p_role_information8              in varchar2
  ,p_role_information9              in varchar2
  ,p_role_information10             in varchar2
  ,p_role_information11             in varchar2
  ,p_role_information12             in varchar2
  ,p_role_information13             in varchar2
  ,p_role_information14             in varchar2
  ,p_role_information15             in varchar2
  ,p_role_information16             in varchar2
  ,p_role_information17             in varchar2
  ,p_role_information18             in varchar2
  ,p_role_information19             in varchar2
  ,p_role_information20             in varchar2
  ,p_object_version_number          in number
  ,p_old_end_date                   in date -- fix 1370960
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.role_id                          := p_role_id;
  l_rec.job_id                           := p_job_id;
  l_rec.job_group_id                     := p_job_group_id;
  l_rec.person_id                        := p_person_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.confidential_date                := p_confidential_date;
  l_rec.emp_rights_flag                  := p_emp_rights_flag;
  l_rec.end_of_rights_date               := p_end_of_rights_date;
  l_rec.primary_contact_flag             := p_primary_contact_flag;
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
  l_rec.role_information_category        := p_role_information_category;
  l_rec.role_information1                := p_role_information1;
  l_rec.role_information2                := p_role_information2;
  l_rec.role_information3                := p_role_information3;
  l_rec.role_information4                := p_role_information4;
  l_rec.role_information5                := p_role_information5;
  l_rec.role_information6                := p_role_information6;
  l_rec.role_information7                := p_role_information7;
  l_rec.role_information8                := p_role_information8;
  l_rec.role_information9                := p_role_information9;
  l_rec.role_information10               := p_role_information10;
  l_rec.role_information11               := p_role_information11;
  l_rec.role_information12               := p_role_information12;
  l_rec.role_information13               := p_role_information13;
  l_rec.role_information14               := p_role_information14;
  l_rec.role_information15               := p_role_information15;
  l_rec.role_information16               := p_role_information16;
  l_rec.role_information17               := p_role_information17;
  l_rec.role_information18               := p_role_information18;
  l_rec.role_information19               := p_role_information19;
  l_rec.role_information20               := p_role_information20;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.old_end_date                     := p_old_end_date; -- fix 1370960
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_rol_shd;

/
