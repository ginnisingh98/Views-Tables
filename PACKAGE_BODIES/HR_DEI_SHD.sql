--------------------------------------------------------
--  DDL for Package Body HR_DEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DEI_SHD" as
/* $Header: hrdeirhi.pkb 120.1.12010000.3 2010/05/20 12:01:59 tkghosh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_dei_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_DOCUMENT_EXTRA_INFO_PK') Then
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
  (p_document_extra_info_id               in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       document_extra_info_id
      ,person_id
      ,document_type_id
      ,document_number
      ,date_from
      ,date_to
      ,issued_by
      ,issued_at
      ,issued_date
      ,issuing_authority
      ,verified_by
      ,verified_date
      ,related_object_name
      ,related_object_id_col
      ,related_object_id
      ,dei_attribute_category
      ,dei_attribute1
      ,dei_attribute2
      ,dei_attribute3
      ,dei_attribute4
      ,dei_attribute5
      ,dei_attribute6
      ,dei_attribute7
      ,dei_attribute8
      ,dei_attribute9
      ,dei_attribute10
      ,dei_attribute11
      ,dei_attribute12
      ,dei_attribute13
      ,dei_attribute14
      ,dei_attribute15
      ,dei_attribute16
      ,dei_attribute17
      ,dei_attribute18
      ,dei_attribute19
      ,dei_attribute20
      ,dei_attribute21
      ,dei_attribute22
      ,dei_attribute23
      ,dei_attribute24
      ,dei_attribute25
      ,dei_attribute26
      ,dei_attribute27
      ,dei_attribute28
      ,dei_attribute29
      ,dei_attribute30
      ,dei_information_category
      ,dei_information1
      ,dei_information2
      ,dei_information3
      ,dei_information4
      ,dei_information5
      ,dei_information6
      ,dei_information7
      ,dei_information8
      ,dei_information9
      ,dei_information10
      ,dei_information11
      ,dei_information12
      ,dei_information13
      ,dei_information14
      ,dei_information15
      ,dei_information16
      ,dei_information17
      ,dei_information18
      ,dei_information19
      ,dei_information20
      ,dei_information21
      ,dei_information22
      ,dei_information23
      ,dei_information24
      ,dei_information25
      ,dei_information26
      ,dei_information27
      ,dei_information28
      ,dei_information29
      ,dei_information30
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,object_version_number
    from        hr_document_extra_info
    where       document_extra_info_id = p_document_extra_info_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_document_extra_info_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_document_extra_info_id
        = hr_dei_shd.g_old_rec.document_extra_info_id and
        p_object_version_number
        = hr_dei_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_dei_shd.g_old_rec;
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
          <> hr_dei_shd.g_old_rec.object_version_number) Then
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
  (p_document_extra_info_id               in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       document_extra_info_id
      ,person_id
      ,document_type_id
      ,document_number
      ,date_from
      ,date_to
      ,issued_by
      ,issued_at
      ,issued_date
      ,issuing_authority
      ,verified_by
      ,verified_date
      ,related_object_name
      ,related_object_id_col
      ,related_object_id
      ,dei_attribute_category
      ,dei_attribute1
      ,dei_attribute2
      ,dei_attribute3
      ,dei_attribute4
      ,dei_attribute5
      ,dei_attribute6
      ,dei_attribute7
      ,dei_attribute8
      ,dei_attribute9
      ,dei_attribute10
      ,dei_attribute11
      ,dei_attribute12
      ,dei_attribute13
      ,dei_attribute14
      ,dei_attribute15
      ,dei_attribute16
      ,dei_attribute17
      ,dei_attribute18
      ,dei_attribute19
      ,dei_attribute20
      ,dei_attribute21
      ,dei_attribute22
      ,dei_attribute23
      ,dei_attribute24
      ,dei_attribute25
      ,dei_attribute26
      ,dei_attribute27
      ,dei_attribute28
      ,dei_attribute29
      ,dei_attribute30
      ,dei_information_category
      ,dei_information1
      ,dei_information2
      ,dei_information3
      ,dei_information4
      ,dei_information5
      ,dei_information6
      ,dei_information7
      ,dei_information8
      ,dei_information9
      ,dei_information10
      ,dei_information11
      ,dei_information12
      ,dei_information13
      ,dei_information14
      ,dei_information15
      ,dei_information16
      ,dei_information17
      ,dei_information18
      ,dei_information19
      ,dei_information20
      ,dei_information21
      ,dei_information22
      ,dei_information23
      ,dei_information24
      ,dei_information25
      ,dei_information26
      ,dei_information27
      ,dei_information28
      ,dei_information29
      ,dei_information30
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,object_version_number
    from        hr_document_extra_info
    where       document_extra_info_id = p_document_extra_info_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'DOCUMENT_EXTRA_INFO_ID'
    ,p_argument_value     => p_document_extra_info_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_dei_shd.g_old_rec;
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
      <> hr_dei_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_document_extra_info');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_document_extra_info_id         in number
  ,p_person_id                      in number
  ,p_document_type_id               in number
  ,p_document_number                in varchar2
  ,p_date_from                      in date
  ,p_date_to                        in date
  ,p_issued_by                      in varchar2
  ,p_issued_at                      in varchar2
  ,p_issued_date                    in date
  ,p_issuing_authority              in varchar2
  ,p_verified_by                    in number
  ,p_verified_date                  in date
  ,p_related_object_name            in varchar2
  ,p_related_object_id_col          in varchar2
  ,p_related_object_id              in number
  ,p_dei_attribute_category         in varchar2
  ,p_dei_attribute1                 in varchar2
  ,p_dei_attribute2                 in varchar2
  ,p_dei_attribute3                 in varchar2
  ,p_dei_attribute4                 in varchar2
  ,p_dei_attribute5                 in varchar2
  ,p_dei_attribute6                 in varchar2
  ,p_dei_attribute7                 in varchar2
  ,p_dei_attribute8                 in varchar2
  ,p_dei_attribute9                 in varchar2
  ,p_dei_attribute10                in varchar2
  ,p_dei_attribute11                in varchar2
  ,p_dei_attribute12                in varchar2
  ,p_dei_attribute13                in varchar2
  ,p_dei_attribute14                in varchar2
  ,p_dei_attribute15                in varchar2
  ,p_dei_attribute16                in varchar2
  ,p_dei_attribute17                in varchar2
  ,p_dei_attribute18                in varchar2
  ,p_dei_attribute19                in varchar2
  ,p_dei_attribute20                in varchar2
  ,p_dei_attribute21                in varchar2
  ,p_dei_attribute22                in varchar2
  ,p_dei_attribute23                in varchar2
  ,p_dei_attribute24                in varchar2
  ,p_dei_attribute25                in varchar2
  ,p_dei_attribute26                in varchar2
  ,p_dei_attribute27                in varchar2
  ,p_dei_attribute28                in varchar2
  ,p_dei_attribute29                in varchar2
  ,p_dei_attribute30                in varchar2
  ,p_dei_information_category       in varchar2
  ,p_dei_information1               in varchar2
  ,p_dei_information2               in varchar2
  ,p_dei_information3               in varchar2
  ,p_dei_information4               in varchar2
  ,p_dei_information5               in varchar2
  ,p_dei_information6               in varchar2
  ,p_dei_information7               in varchar2
  ,p_dei_information8               in varchar2
  ,p_dei_information9               in varchar2
  ,p_dei_information10              in varchar2
  ,p_dei_information11              in varchar2
  ,p_dei_information12              in varchar2
  ,p_dei_information13              in varchar2
  ,p_dei_information14              in varchar2
  ,p_dei_information15              in varchar2
  ,p_dei_information16              in varchar2
  ,p_dei_information17              in varchar2
  ,p_dei_information18              in varchar2
  ,p_dei_information19              in varchar2
  ,p_dei_information20              in varchar2
  ,p_dei_information21              in varchar2
  ,p_dei_information22              in varchar2
  ,p_dei_information23              in varchar2
  ,p_dei_information24              in varchar2
  ,p_dei_information25              in varchar2
  ,p_dei_information26              in varchar2
  ,p_dei_information27              in varchar2
  ,p_dei_information28              in varchar2
  ,p_dei_information29              in varchar2
  ,p_dei_information30              in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
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
  l_rec.document_extra_info_id           := p_document_extra_info_id;
  l_rec.person_id                        := p_person_id;
  l_rec.document_type_id                 := p_document_type_id;
  l_rec.document_number                  := p_document_number;
  l_rec.date_from                        := p_date_from;
  l_rec.date_to                          := p_date_to;
  l_rec.issued_by                        := p_issued_by;
  l_rec.issued_at                        := p_issued_at;
  l_rec.issued_date                      := p_issued_date;
  l_rec.issuing_authority                := p_issuing_authority;
  l_rec.verified_by                      := p_verified_by;
  l_rec.verified_date                    := p_verified_date;
  l_rec.related_object_name              := p_related_object_name;
  l_rec.related_object_id_col            := p_related_object_id_col;
  l_rec.related_object_id                := p_related_object_id;
  l_rec.dei_attribute_category           := p_dei_attribute_category;
  l_rec.dei_attribute1                   := p_dei_attribute1;
  l_rec.dei_attribute2                   := p_dei_attribute2;
  l_rec.dei_attribute3                   := p_dei_attribute3;
  l_rec.dei_attribute4                   := p_dei_attribute4;
  l_rec.dei_attribute5                   := p_dei_attribute5;
  l_rec.dei_attribute6                   := p_dei_attribute6;
  l_rec.dei_attribute7                   := p_dei_attribute7;
  l_rec.dei_attribute8                   := p_dei_attribute8;
  l_rec.dei_attribute9                   := p_dei_attribute9;
  l_rec.dei_attribute10                  := p_dei_attribute10;
  l_rec.dei_attribute11                  := p_dei_attribute11;
  l_rec.dei_attribute12                  := p_dei_attribute12;
  l_rec.dei_attribute13                  := p_dei_attribute13;
  l_rec.dei_attribute14                  := p_dei_attribute14;
  l_rec.dei_attribute15                  := p_dei_attribute15;
  l_rec.dei_attribute16                  := p_dei_attribute16;
  l_rec.dei_attribute17                  := p_dei_attribute17;
  l_rec.dei_attribute18                  := p_dei_attribute18;
  l_rec.dei_attribute19                  := p_dei_attribute19;
  l_rec.dei_attribute20                  := p_dei_attribute20;
  l_rec.dei_attribute21                  := p_dei_attribute21;
  l_rec.dei_attribute22                  := p_dei_attribute22;
  l_rec.dei_attribute23                  := p_dei_attribute23;
  l_rec.dei_attribute24                  := p_dei_attribute24;
  l_rec.dei_attribute25                  := p_dei_attribute25;
  l_rec.dei_attribute26                  := p_dei_attribute26;
  l_rec.dei_attribute27                  := p_dei_attribute27;
  l_rec.dei_attribute28                  := p_dei_attribute28;
  l_rec.dei_attribute29                  := p_dei_attribute29;
  l_rec.dei_attribute30                  := p_dei_attribute30;
  l_rec.dei_information_category         := p_dei_information_category;
  l_rec.dei_information1                 := p_dei_information1;
  l_rec.dei_information2                 := p_dei_information2;
  l_rec.dei_information3                 := p_dei_information3;
  l_rec.dei_information4                 := p_dei_information4;
  l_rec.dei_information5                 := p_dei_information5;
  l_rec.dei_information6                 := p_dei_information6;
  l_rec.dei_information7                 := p_dei_information7;
  l_rec.dei_information8                 := p_dei_information8;
  l_rec.dei_information9                 := p_dei_information9;
  l_rec.dei_information10                := p_dei_information10;
  l_rec.dei_information11                := p_dei_information11;
  l_rec.dei_information12                := p_dei_information12;
  l_rec.dei_information13                := p_dei_information13;
  l_rec.dei_information14                := p_dei_information14;
  l_rec.dei_information15                := p_dei_information15;
  l_rec.dei_information16                := p_dei_information16;
  l_rec.dei_information17                := p_dei_information17;
  l_rec.dei_information18                := p_dei_information18;
  l_rec.dei_information19                := p_dei_information19;
  l_rec.dei_information20                := p_dei_information20;
  l_rec.dei_information21                := p_dei_information21;
  l_rec.dei_information22                := p_dei_information22;
  l_rec.dei_information23                := p_dei_information23;
  l_rec.dei_information24                := p_dei_information24;
  l_rec.dei_information25                := p_dei_information25;
  l_rec.dei_information26                := p_dei_information26;
  l_rec.dei_information27                := p_dei_information27;
  l_rec.dei_information28                := p_dei_information28;
  l_rec.dei_information29                := p_dei_information29;
  l_rec.dei_information30                := p_dei_information30;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_dei_shd;

/
