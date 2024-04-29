--------------------------------------------------------
--  DDL for Package Body IRC_IPC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPC_SHD" as
/* $Header: iripcrhi.pkb 120.0 2005/07/26 15:08:54 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipc_shd.';  -- Global package name
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
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'IRC_POSTING_CONTENTS_PK') Then
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
  (p_posting_content_id                   in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       posting_content_id
      ,display_manager_info
      ,display_recruiter_info
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
      ,ipc_information_category
      ,ipc_information1
      ,ipc_information2
      ,ipc_information3
      ,ipc_information4
      ,ipc_information5
      ,ipc_information6
      ,ipc_information7
      ,ipc_information8
      ,ipc_information9
      ,ipc_information10
      ,ipc_information11
      ,ipc_information12
      ,ipc_information13
      ,ipc_information14
      ,ipc_information15
      ,ipc_information16
      ,ipc_information17
      ,ipc_information18
      ,ipc_information19
      ,ipc_information20
      ,ipc_information21
      ,ipc_information22
      ,ipc_information23
      ,ipc_information24
      ,ipc_information25
      ,ipc_information26
      ,ipc_information27
      ,ipc_information28
      ,ipc_information29
      ,ipc_information30
      ,object_version_number
      ,date_approved
      ,recruiter_full_name
      ,recruiter_email
      ,recruiter_work_telephone
      ,manager_full_name
      ,manager_email
      ,manager_work_telephone
    from        irc_posting_contents
    where       posting_content_id = p_posting_content_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_posting_content_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_posting_content_id
        = irc_ipc_shd.g_old_rec.posting_content_id and
        p_object_version_number
        = irc_ipc_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into irc_ipc_shd.g_old_rec;
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
          <> irc_ipc_shd.g_old_rec.object_version_number) Then
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
  (p_posting_content_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       posting_content_id
      ,display_manager_info
      ,display_recruiter_info
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
      ,ipc_information_category
      ,ipc_information1
      ,ipc_information2
      ,ipc_information3
      ,ipc_information4
      ,ipc_information5
      ,ipc_information6
      ,ipc_information7
      ,ipc_information8
      ,ipc_information9
      ,ipc_information10
      ,ipc_information11
      ,ipc_information12
      ,ipc_information13
      ,ipc_information14
      ,ipc_information15
      ,ipc_information16
      ,ipc_information17
      ,ipc_information18
      ,ipc_information19
      ,ipc_information20
      ,ipc_information21
      ,ipc_information22
      ,ipc_information23
      ,ipc_information24
      ,ipc_information25
      ,ipc_information26
      ,ipc_information27
      ,ipc_information28
      ,ipc_information29
      ,ipc_information30
      ,object_version_number
      ,date_approved
      ,recruiter_full_name
      ,recruiter_email
      ,recruiter_work_telephone
      ,manager_full_name
      ,manager_email
      ,manager_work_telephone
    from        irc_posting_contents
    where       posting_content_id = p_posting_content_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'POSTING_CONTENT_ID'
    ,p_argument_value     => p_posting_content_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into irc_ipc_shd.g_old_rec;
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
      <> irc_ipc_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'irc_posting_contents');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_posting_content_id             in number
  ,p_display_manager_info           in varchar2
  ,p_display_recruiter_info         in varchar2
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
  ,p_ipc_information_category       in varchar2
  ,p_ipc_information1               in varchar2
  ,p_ipc_information2               in varchar2
  ,p_ipc_information3               in varchar2
  ,p_ipc_information4               in varchar2
  ,p_ipc_information5               in varchar2
  ,p_ipc_information6               in varchar2
  ,p_ipc_information7               in varchar2
  ,p_ipc_information8               in varchar2
  ,p_ipc_information9               in varchar2
  ,p_ipc_information10              in varchar2
  ,p_ipc_information11              in varchar2
  ,p_ipc_information12              in varchar2
  ,p_ipc_information13              in varchar2
  ,p_ipc_information14              in varchar2
  ,p_ipc_information15              in varchar2
  ,p_ipc_information16              in varchar2
  ,p_ipc_information17              in varchar2
  ,p_ipc_information18              in varchar2
  ,p_ipc_information19              in varchar2
  ,p_ipc_information20              in varchar2
  ,p_ipc_information21              in varchar2
  ,p_ipc_information22              in varchar2
  ,p_ipc_information23              in varchar2
  ,p_ipc_information24              in varchar2
  ,p_ipc_information25              in varchar2
  ,p_ipc_information26              in varchar2
  ,p_ipc_information27              in varchar2
  ,p_ipc_information28              in varchar2
  ,p_ipc_information29              in varchar2
  ,p_ipc_information30              in varchar2
  ,p_object_version_number          in number
  ,p_date_approved                  in date
  ,p_recruiter_full_name            in varchar2
  ,p_recruiter_email                in varchar2
  ,p_recruiter_work_telephone       in varchar2
  ,p_manager_full_name              in varchar2
  ,p_manager_email                  in varchar2
  ,p_manager_work_telephone         in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.posting_content_id               := p_posting_content_id;
  l_rec.display_manager_info             := p_display_manager_info;
  l_rec.display_recruiter_info           := p_display_recruiter_info;
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
  l_rec.ipc_information_category         := p_ipc_information_category;
  l_rec.ipc_information1                 := p_ipc_information1;
  l_rec.ipc_information2                 := p_ipc_information2;
  l_rec.ipc_information3                 := p_ipc_information3;
  l_rec.ipc_information4                 := p_ipc_information4;
  l_rec.ipc_information5                 := p_ipc_information5;
  l_rec.ipc_information6                 := p_ipc_information6;
  l_rec.ipc_information7                 := p_ipc_information7;
  l_rec.ipc_information8                 := p_ipc_information8;
  l_rec.ipc_information9                 := p_ipc_information9;
  l_rec.ipc_information10                := p_ipc_information10;
  l_rec.ipc_information11                := p_ipc_information11;
  l_rec.ipc_information12                := p_ipc_information12;
  l_rec.ipc_information13                := p_ipc_information13;
  l_rec.ipc_information14                := p_ipc_information14;
  l_rec.ipc_information15                := p_ipc_information15;
  l_rec.ipc_information16                := p_ipc_information16;
  l_rec.ipc_information17                := p_ipc_information17;
  l_rec.ipc_information18                := p_ipc_information18;
  l_rec.ipc_information19                := p_ipc_information19;
  l_rec.ipc_information20                := p_ipc_information20;
  l_rec.ipc_information21                := p_ipc_information21;
  l_rec.ipc_information22                := p_ipc_information22;
  l_rec.ipc_information23                := p_ipc_information23;
  l_rec.ipc_information24                := p_ipc_information24;
  l_rec.ipc_information25                := p_ipc_information25;
  l_rec.ipc_information26                := p_ipc_information26;
  l_rec.ipc_information27                := p_ipc_information27;
  l_rec.ipc_information28                := p_ipc_information28;
  l_rec.ipc_information29                := p_ipc_information29;
  l_rec.ipc_information30                := p_ipc_information30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.date_approved                    := p_date_approved;
  l_rec.recruiter_full_name              := p_recruiter_full_name;
  l_rec.recruiter_email                  := p_recruiter_email;
  l_rec.recruiter_work_telephone         := p_recruiter_work_telephone;
  l_rec.manager_full_name                := p_manager_full_name;
  l_rec.manager_email                    := p_manager_email;
  l_rec.manager_work_telephone           := p_manager_work_telephone ;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end irc_ipc_shd;

/
