--------------------------------------------------------
--  DDL for Package Body PER_PEM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEM_SHD" as
/* $Header: pepemrhi.pkb 120.1.12010000.3 2009/01/12 08:21:02 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pem_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_PREVIOUS_EMPLOYERS_PK') Then
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
  (p_previous_employer_id                 in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       previous_employer_id
      ,business_group_id
      ,person_id
      ,party_id
      ,start_date
      ,end_date
      ,period_years
      ,period_days
      ,employer_name
      ,employer_country
      ,employer_address
      ,employer_type
      ,employer_subtype
      ,description
      ,pem_attribute_category
      ,pem_attribute1
      ,pem_attribute2
      ,pem_attribute3
      ,pem_attribute4
      ,pem_attribute5
      ,pem_attribute6
      ,pem_attribute7
      ,pem_attribute8
      ,pem_attribute9
      ,pem_attribute10
      ,pem_attribute11
      ,pem_attribute12
      ,pem_attribute13
      ,pem_attribute14
      ,pem_attribute15
      ,pem_attribute16
      ,pem_attribute17
      ,pem_attribute18
      ,pem_attribute19
      ,pem_attribute20
      ,pem_attribute21
      ,pem_attribute22
      ,pem_attribute23
      ,pem_attribute24
      ,pem_attribute25
      ,pem_attribute26
      ,pem_attribute27
      ,pem_attribute28
      ,pem_attribute29
      ,pem_attribute30
      ,pem_information_category
      ,pem_information1
      ,pem_information2
      ,pem_information3
      ,pem_information4
      ,pem_information5
      ,pem_information6
      ,pem_information7
      ,pem_information8
      ,pem_information9
      ,pem_information10
      ,pem_information11
      ,pem_information12
      ,pem_information13
      ,pem_information14
      ,pem_information15
      ,pem_information16
      ,pem_information17
      ,pem_information18
      ,pem_information19
      ,pem_information20
      ,pem_information21
      ,pem_information22
      ,pem_information23
      ,pem_information24
      ,pem_information25
      ,pem_information26
      ,pem_information27
      ,pem_information28
      ,pem_information29
      ,pem_information30
      ,object_version_number
      ,all_assignments
      ,period_months
    from        per_previous_employers
    where       previous_employer_id = p_previous_employer_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_previous_employer_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_previous_employer_id
        = per_pem_shd.g_old_rec.previous_employer_id and
        p_object_version_number
        = per_pem_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_pem_shd.g_old_rec;
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
          <> per_pem_shd.g_old_rec.object_version_number) Then
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
  (p_previous_employer_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       previous_employer_id
      ,business_group_id
      ,person_id
      ,party_id
      ,start_date
      ,end_date
      ,period_years
      ,period_days
      ,employer_name
      ,employer_country
      ,employer_address
      ,employer_type
      ,employer_subtype
      ,description
      ,pem_attribute_category
      ,pem_attribute1
      ,pem_attribute2
      ,pem_attribute3
      ,pem_attribute4
      ,pem_attribute5
      ,pem_attribute6
      ,pem_attribute7
      ,pem_attribute8
      ,pem_attribute9
      ,pem_attribute10
      ,pem_attribute11
      ,pem_attribute12
      ,pem_attribute13
      ,pem_attribute14
      ,pem_attribute15
      ,pem_attribute16
      ,pem_attribute17
      ,pem_attribute18
      ,pem_attribute19
      ,pem_attribute20
      ,pem_attribute21
      ,pem_attribute22
      ,pem_attribute23
      ,pem_attribute24
      ,pem_attribute25
      ,pem_attribute26
      ,pem_attribute27
      ,pem_attribute28
      ,pem_attribute29
      ,pem_attribute30
      ,pem_information_category
      ,pem_information1
      ,pem_information2
      ,pem_information3
      ,pem_information4
      ,pem_information5
      ,pem_information6
      ,pem_information7
      ,pem_information8
      ,pem_information9
      ,pem_information10
      ,pem_information11
      ,pem_information12
      ,pem_information13
      ,pem_information14
      ,pem_information15
      ,pem_information16
      ,pem_information17
      ,pem_information18
      ,pem_information19
      ,pem_information20
      ,pem_information21
      ,pem_information22
      ,pem_information23
      ,pem_information24
      ,pem_information25
      ,pem_information26
      ,pem_information27
      ,pem_information28
      ,pem_information29
      ,pem_information30
      ,object_version_number
      ,all_assignments
      ,period_months
    from        per_previous_employers
    where       previous_employer_id = p_previous_employer_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PREVIOUS_EMPLOYER_ID'
    ,p_argument_value     => p_previous_employer_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_pem_shd.g_old_rec;
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
      <> per_pem_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_previous_employers');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_previous_employer_id           in number
  ,p_business_group_id              in number
  ,p_person_id                      in number
  ,p_party_id                       in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_period_years                   in number
  ,p_period_days                    in number
  ,p_employer_name                  in varchar2
  ,p_employer_country               in varchar2
  ,p_employer_address               in varchar2
  ,p_employer_type                  in varchar2
  ,p_employer_subtype               in varchar2
  ,p_description                    in varchar2
  ,p_pem_attribute_category         in varchar2
  ,p_pem_attribute1                 in varchar2
  ,p_pem_attribute2                 in varchar2
  ,p_pem_attribute3                 in varchar2
  ,p_pem_attribute4                 in varchar2
  ,p_pem_attribute5                 in varchar2
  ,p_pem_attribute6                 in varchar2
  ,p_pem_attribute7                 in varchar2
  ,p_pem_attribute8                 in varchar2
  ,p_pem_attribute9                 in varchar2
  ,p_pem_attribute10                in varchar2
  ,p_pem_attribute11                in varchar2
  ,p_pem_attribute12                in varchar2
  ,p_pem_attribute13                in varchar2
  ,p_pem_attribute14                in varchar2
  ,p_pem_attribute15                in varchar2
  ,p_pem_attribute16                in varchar2
  ,p_pem_attribute17                in varchar2
  ,p_pem_attribute18                in varchar2
  ,p_pem_attribute19                in varchar2
  ,p_pem_attribute20                in varchar2
  ,p_pem_attribute21                in varchar2
  ,p_pem_attribute22                in varchar2
  ,p_pem_attribute23                in varchar2
  ,p_pem_attribute24                in varchar2
  ,p_pem_attribute25                in varchar2
  ,p_pem_attribute26                in varchar2
  ,p_pem_attribute27                in varchar2
  ,p_pem_attribute28                in varchar2
  ,p_pem_attribute29                in varchar2
  ,p_pem_attribute30                in varchar2
  ,p_pem_information_category       in varchar2
  ,p_pem_information1               in varchar2
  ,p_pem_information2               in varchar2
  ,p_pem_information3               in varchar2
  ,p_pem_information4               in varchar2
  ,p_pem_information5               in varchar2
  ,p_pem_information6               in varchar2
  ,p_pem_information7               in varchar2
  ,p_pem_information8               in varchar2
  ,p_pem_information9               in varchar2
  ,p_pem_information10              in varchar2
  ,p_pem_information11              in varchar2
  ,p_pem_information12              in varchar2
  ,p_pem_information13              in varchar2
  ,p_pem_information14              in varchar2
  ,p_pem_information15              in varchar2
  ,p_pem_information16              in varchar2
  ,p_pem_information17              in varchar2
  ,p_pem_information18              in varchar2
  ,p_pem_information19              in varchar2
  ,p_pem_information20              in varchar2
  ,p_pem_information21              in varchar2
  ,p_pem_information22              in varchar2
  ,p_pem_information23              in varchar2
  ,p_pem_information24              in varchar2
  ,p_pem_information25              in varchar2
  ,p_pem_information26              in varchar2
  ,p_pem_information27              in varchar2
  ,p_pem_information28              in varchar2
  ,p_pem_information29              in varchar2
  ,p_pem_information30              in varchar2
  ,p_object_version_number          in number
  ,p_all_assignments                in varchar2
  ,p_period_months                  in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.previous_employer_id             := p_previous_employer_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.person_id                        := p_person_id;
  l_rec.party_id                         := p_party_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.period_years                     := p_period_years;
  l_rec.period_days                      := p_period_days;
  l_rec.employer_name                    := p_employer_name;
  l_rec.employer_country                 := p_employer_country;
  l_rec.employer_address                 := p_employer_address;
  l_rec.employer_type                    := p_employer_type;
  l_rec.employer_subtype                 := p_employer_subtype;
  l_rec.description                      := p_description;
  l_rec.pem_attribute_category           := p_pem_attribute_category;
  l_rec.pem_attribute1                   := p_pem_attribute1;
  l_rec.pem_attribute2                   := p_pem_attribute2;
  l_rec.pem_attribute3                   := p_pem_attribute3;
  l_rec.pem_attribute4                   := p_pem_attribute4;
  l_rec.pem_attribute5                   := p_pem_attribute5;
  l_rec.pem_attribute6                   := p_pem_attribute6;
  l_rec.pem_attribute7                   := p_pem_attribute7;
  l_rec.pem_attribute8                   := p_pem_attribute8;
  l_rec.pem_attribute9                   := p_pem_attribute9;
  l_rec.pem_attribute10                  := p_pem_attribute10;
  l_rec.pem_attribute11                  := p_pem_attribute11;
  l_rec.pem_attribute12                  := p_pem_attribute12;
  l_rec.pem_attribute13                  := p_pem_attribute13;
  l_rec.pem_attribute14                  := p_pem_attribute14;
  l_rec.pem_attribute15                  := p_pem_attribute15;
  l_rec.pem_attribute16                  := p_pem_attribute16;
  l_rec.pem_attribute17                  := p_pem_attribute17;
  l_rec.pem_attribute18                  := p_pem_attribute18;
  l_rec.pem_attribute19                  := p_pem_attribute19;
  l_rec.pem_attribute20                  := p_pem_attribute20;
  l_rec.pem_attribute21                  := p_pem_attribute21;
  l_rec.pem_attribute22                  := p_pem_attribute22;
  l_rec.pem_attribute23                  := p_pem_attribute23;
  l_rec.pem_attribute24                  := p_pem_attribute24;
  l_rec.pem_attribute25                  := p_pem_attribute25;
  l_rec.pem_attribute26                  := p_pem_attribute26;
  l_rec.pem_attribute27                  := p_pem_attribute27;
  l_rec.pem_attribute28                  := p_pem_attribute28;
  l_rec.pem_attribute29                  := p_pem_attribute29;
  l_rec.pem_attribute30                  := p_pem_attribute30;
  l_rec.pem_information_category         := p_pem_information_category;
  l_rec.pem_information1                 := p_pem_information1;
  l_rec.pem_information2                 := p_pem_information2;
  l_rec.pem_information3                 := p_pem_information3;
  l_rec.pem_information4                 := p_pem_information4;
  l_rec.pem_information5                 := p_pem_information5;
  l_rec.pem_information6                 := p_pem_information6;
  l_rec.pem_information7                 := p_pem_information7;
  l_rec.pem_information8                 := p_pem_information8;
  l_rec.pem_information9                 := p_pem_information9;
  l_rec.pem_information10                := p_pem_information10;
  l_rec.pem_information11                := p_pem_information11;
  l_rec.pem_information12                := p_pem_information12;
  l_rec.pem_information13                := p_pem_information13;
  l_rec.pem_information14                := p_pem_information14;
  l_rec.pem_information15                := p_pem_information15;
  l_rec.pem_information16                := p_pem_information16;
  l_rec.pem_information17                := p_pem_information17;
  l_rec.pem_information18                := p_pem_information18;
  l_rec.pem_information19                := p_pem_information19;
  l_rec.pem_information20                := p_pem_information20;
  l_rec.pem_information21                := p_pem_information21;
  l_rec.pem_information22                := p_pem_information22;
  l_rec.pem_information23                := p_pem_information23;
  l_rec.pem_information24                := p_pem_information24;
  l_rec.pem_information25                := p_pem_information25;
  l_rec.pem_information26                := p_pem_information26;
  l_rec.pem_information27                := p_pem_information27;
  l_rec.pem_information28                := p_pem_information28;
  l_rec.pem_information29                := p_pem_information29;
  l_rec.pem_information30                := p_pem_information30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.all_assignments                  := p_all_assignments;
  l_rec.period_months                    := p_period_months;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_pem_shd;

/
