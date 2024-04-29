--------------------------------------------------------
--  DDL for Package Body PER_PJI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJI_SHD" as
/* $Header: pepjirhi.pkb 115.8 2002/12/03 15:41:52 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pji_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_PREV_JOB_EXTRA_INFO_PK') Then
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
  (p_previous_job_extra_info_id           in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       previous_job_extra_info_id
      ,previous_job_id
      ,information_type
      ,pji_attribute_category
      ,pji_attribute1
      ,pji_attribute2
      ,pji_attribute3
      ,pji_attribute4
      ,pji_attribute5
      ,pji_attribute6
      ,pji_attribute7
      ,pji_attribute8
      ,pji_attribute9
      ,pji_attribute10
      ,pji_attribute11
      ,pji_attribute12
      ,pji_attribute13
      ,pji_attribute14
      ,pji_attribute15
      ,pji_attribute16
      ,pji_attribute17
      ,pji_attribute18
      ,pji_attribute19
      ,pji_attribute20
      ,pji_attribute21
      ,pji_attribute22
      ,pji_attribute23
      ,pji_attribute24
      ,pji_attribute25
      ,pji_attribute26
      ,pji_attribute27
      ,pji_attribute28
      ,pji_attribute29
      ,pji_attribute30
      ,pji_information_category
      ,pji_information1
      ,pji_information2
      ,pji_information3
      ,pji_information4
      ,pji_information5
      ,pji_information6
      ,pji_information7
      ,pji_information8
      ,pji_information9
      ,pji_information10
      ,pji_information11
      ,pji_information12
      ,pji_information13
      ,pji_information14
      ,pji_information15
      ,pji_information16
      ,pji_information17
      ,pji_information18
      ,pji_information19
      ,pji_information20
      ,pji_information21
      ,pji_information22
      ,pji_information23
      ,pji_information24
      ,pji_information25
      ,pji_information26
      ,pji_information27
      ,pji_information28
      ,pji_information29
      ,pji_information30
      ,object_version_number
    from        per_prev_job_extra_info
    where       previous_job_extra_info_id = p_previous_job_extra_info_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_previous_job_extra_info_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_previous_job_extra_info_id
        = per_pji_shd.g_old_rec.previous_job_extra_info_id and
        p_object_version_number
        = per_pji_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_pji_shd.g_old_rec;
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
          <> per_pji_shd.g_old_rec.object_version_number) Then
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
  (p_previous_job_extra_info_id           in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       previous_job_extra_info_id
      ,previous_job_id
      ,information_type
      ,pji_attribute_category
      ,pji_attribute1
      ,pji_attribute2
      ,pji_attribute3
      ,pji_attribute4
      ,pji_attribute5
      ,pji_attribute6
      ,pji_attribute7
      ,pji_attribute8
      ,pji_attribute9
      ,pji_attribute10
      ,pji_attribute11
      ,pji_attribute12
      ,pji_attribute13
      ,pji_attribute14
      ,pji_attribute15
      ,pji_attribute16
      ,pji_attribute17
      ,pji_attribute18
      ,pji_attribute19
      ,pji_attribute20
      ,pji_attribute21
      ,pji_attribute22
      ,pji_attribute23
      ,pji_attribute24
      ,pji_attribute25
      ,pji_attribute26
      ,pji_attribute27
      ,pji_attribute28
      ,pji_attribute29
      ,pji_attribute30
      ,pji_information_category
      ,pji_information1
      ,pji_information2
      ,pji_information3
      ,pji_information4
      ,pji_information5
      ,pji_information6
      ,pji_information7
      ,pji_information8
      ,pji_information9
      ,pji_information10
      ,pji_information11
      ,pji_information12
      ,pji_information13
      ,pji_information14
      ,pji_information15
      ,pji_information16
      ,pji_information17
      ,pji_information18
      ,pji_information19
      ,pji_information20
      ,pji_information21
      ,pji_information22
      ,pji_information23
      ,pji_information24
      ,pji_information25
      ,pji_information26
      ,pji_information27
      ,pji_information28
      ,pji_information29
      ,pji_information30
      ,object_version_number
    from        per_prev_job_extra_info
    where       previous_job_extra_info_id = p_previous_job_extra_info_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PREVIOUS_JOB_EXTRA_INFO_ID'
    ,p_argument_value     => p_previous_job_extra_info_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_pji_shd.g_old_rec;
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
      <> per_pji_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_prev_job_extra_info');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_previous_job_extra_info_id     in number
  ,p_previous_job_id                in number
  ,p_information_type               in varchar2
  ,p_pji_attribute_category         in varchar2
  ,p_pji_attribute1                 in varchar2
  ,p_pji_attribute2                 in varchar2
  ,p_pji_attribute3                 in varchar2
  ,p_pji_attribute4                 in varchar2
  ,p_pji_attribute5                 in varchar2
  ,p_pji_attribute6                 in varchar2
  ,p_pji_attribute7                 in varchar2
  ,p_pji_attribute8                 in varchar2
  ,p_pji_attribute9                 in varchar2
  ,p_pji_attribute10                in varchar2
  ,p_pji_attribute11                in varchar2
  ,p_pji_attribute12                in varchar2
  ,p_pji_attribute13                in varchar2
  ,p_pji_attribute14                in varchar2
  ,p_pji_attribute15                in varchar2
  ,p_pji_attribute16                in varchar2
  ,p_pji_attribute17                in varchar2
  ,p_pji_attribute18                in varchar2
  ,p_pji_attribute19                in varchar2
  ,p_pji_attribute20                in varchar2
  ,p_pji_attribute21                in varchar2
  ,p_pji_attribute22                in varchar2
  ,p_pji_attribute23                in varchar2
  ,p_pji_attribute24                in varchar2
  ,p_pji_attribute25                in varchar2
  ,p_pji_attribute26                in varchar2
  ,p_pji_attribute27                in varchar2
  ,p_pji_attribute28                in varchar2
  ,p_pji_attribute29                in varchar2
  ,p_pji_attribute30                in varchar2
  ,p_pji_information_category       in varchar2
  ,p_pji_information1               in varchar2
  ,p_pji_information2               in varchar2
  ,p_pji_information3               in varchar2
  ,p_pji_information4               in varchar2
  ,p_pji_information5               in varchar2
  ,p_pji_information6               in varchar2
  ,p_pji_information7               in varchar2
  ,p_pji_information8               in varchar2
  ,p_pji_information9               in varchar2
  ,p_pji_information10              in varchar2
  ,p_pji_information11              in varchar2
  ,p_pji_information12              in varchar2
  ,p_pji_information13              in varchar2
  ,p_pji_information14              in varchar2
  ,p_pji_information15              in varchar2
  ,p_pji_information16              in varchar2
  ,p_pji_information17              in varchar2
  ,p_pji_information18              in varchar2
  ,p_pji_information19              in varchar2
  ,p_pji_information20              in varchar2
  ,p_pji_information21              in varchar2
  ,p_pji_information22              in varchar2
  ,p_pji_information23              in varchar2
  ,p_pji_information24              in varchar2
  ,p_pji_information25              in varchar2
  ,p_pji_information26              in varchar2
  ,p_pji_information27              in varchar2
  ,p_pji_information28              in varchar2
  ,p_pji_information29              in varchar2
  ,p_pji_information30              in varchar2
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
  l_rec.previous_job_extra_info_id       := p_previous_job_extra_info_id;
  l_rec.previous_job_id                  := p_previous_job_id;
  l_rec.information_type                 := p_information_type;
  l_rec.pji_attribute_category           := p_pji_attribute_category;
  l_rec.pji_attribute1                   := p_pji_attribute1;
  l_rec.pji_attribute2                   := p_pji_attribute2;
  l_rec.pji_attribute3                   := p_pji_attribute3;
  l_rec.pji_attribute4                   := p_pji_attribute4;
  l_rec.pji_attribute5                   := p_pji_attribute5;
  l_rec.pji_attribute6                   := p_pji_attribute6;
  l_rec.pji_attribute7                   := p_pji_attribute7;
  l_rec.pji_attribute8                   := p_pji_attribute8;
  l_rec.pji_attribute9                   := p_pji_attribute9;
  l_rec.pji_attribute10                  := p_pji_attribute10;
  l_rec.pji_attribute11                  := p_pji_attribute11;
  l_rec.pji_attribute12                  := p_pji_attribute12;
  l_rec.pji_attribute13                  := p_pji_attribute13;
  l_rec.pji_attribute14                  := p_pji_attribute14;
  l_rec.pji_attribute15                  := p_pji_attribute15;
  l_rec.pji_attribute16                  := p_pji_attribute16;
  l_rec.pji_attribute17                  := p_pji_attribute17;
  l_rec.pji_attribute18                  := p_pji_attribute18;
  l_rec.pji_attribute19                  := p_pji_attribute19;
  l_rec.pji_attribute20                  := p_pji_attribute20;
  l_rec.pji_attribute21                  := p_pji_attribute21;
  l_rec.pji_attribute22                  := p_pji_attribute22;
  l_rec.pji_attribute23                  := p_pji_attribute23;
  l_rec.pji_attribute24                  := p_pji_attribute24;
  l_rec.pji_attribute25                  := p_pji_attribute25;
  l_rec.pji_attribute26                  := p_pji_attribute26;
  l_rec.pji_attribute27                  := p_pji_attribute27;
  l_rec.pji_attribute28                  := p_pji_attribute28;
  l_rec.pji_attribute29                  := p_pji_attribute29;
  l_rec.pji_attribute30                  := p_pji_attribute30;
  l_rec.pji_information_category         := p_pji_information_category;
  l_rec.pji_information1                 := p_pji_information1;
  l_rec.pji_information2                 := p_pji_information2;
  l_rec.pji_information3                 := p_pji_information3;
  l_rec.pji_information4                 := p_pji_information4;
  l_rec.pji_information5                 := p_pji_information5;
  l_rec.pji_information6                 := p_pji_information6;
  l_rec.pji_information7                 := p_pji_information7;
  l_rec.pji_information8                 := p_pji_information8;
  l_rec.pji_information9                 := p_pji_information9;
  l_rec.pji_information10                := p_pji_information10;
  l_rec.pji_information11                := p_pji_information11;
  l_rec.pji_information12                := p_pji_information12;
  l_rec.pji_information13                := p_pji_information13;
  l_rec.pji_information14                := p_pji_information14;
  l_rec.pji_information15                := p_pji_information15;
  l_rec.pji_information16                := p_pji_information16;
  l_rec.pji_information17                := p_pji_information17;
  l_rec.pji_information18                := p_pji_information18;
  l_rec.pji_information19                := p_pji_information19;
  l_rec.pji_information20                := p_pji_information20;
  l_rec.pji_information21                := p_pji_information21;
  l_rec.pji_information22                := p_pji_information22;
  l_rec.pji_information23                := p_pji_information23;
  l_rec.pji_information24                := p_pji_information24;
  l_rec.pji_information25                := p_pji_information25;
  l_rec.pji_information26                := p_pji_information26;
  l_rec.pji_information27                := p_pji_information27;
  l_rec.pji_information28                := p_pji_information28;
  l_rec.pji_information29                := p_pji_information29;
  l_rec.pji_information30                := p_pji_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_pji_shd;

/
