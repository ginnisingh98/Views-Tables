--------------------------------------------------------
--  DDL for Package Body PER_PJO_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJO_SHD" as
/* $Header: pepjorhi.pkb 120.0.12010000.2 2008/08/06 09:28:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pjo_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_PREVIOUS_JOBS_FK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_PREVIOUS_JOBS_PK') Then
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
  (p_previous_job_id                      in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       previous_job_id
      ,previous_employer_id
      ,start_date
      ,end_date
      ,period_years
      ,period_days
      ,job_name
      ,employment_category
      ,description
      ,pjo_attribute_category
      ,pjo_attribute1
      ,pjo_attribute2
      ,pjo_attribute3
      ,pjo_attribute4
      ,pjo_attribute5
      ,pjo_attribute6
      ,pjo_attribute7
      ,pjo_attribute8
      ,pjo_attribute9
      ,pjo_attribute10
      ,pjo_attribute11
      ,pjo_attribute12
      ,pjo_attribute13
      ,pjo_attribute14
      ,pjo_attribute15
      ,pjo_attribute16
      ,pjo_attribute17
      ,pjo_attribute18
      ,pjo_attribute19
      ,pjo_attribute20
      ,pjo_attribute21
      ,pjo_attribute22
      ,pjo_attribute23
      ,pjo_attribute24
      ,pjo_attribute25
      ,pjo_attribute26
      ,pjo_attribute27
      ,pjo_attribute28
      ,pjo_attribute29
      ,pjo_attribute30
      ,pjo_information_category
      ,pjo_information1
      ,pjo_information2
      ,pjo_information3
      ,pjo_information4
      ,pjo_information5
      ,pjo_information6
      ,pjo_information7
      ,pjo_information8
      ,pjo_information9
      ,pjo_information10
      ,pjo_information11
      ,pjo_information12
      ,pjo_information13
      ,pjo_information14
      ,pjo_information15
      ,pjo_information16
      ,pjo_information17
      ,pjo_information18
      ,pjo_information19
      ,pjo_information20
      ,pjo_information21
      ,pjo_information22
      ,pjo_information23
      ,pjo_information24
      ,pjo_information25
      ,pjo_information26
      ,pjo_information27
      ,pjo_information28
      ,pjo_information29
      ,pjo_information30
      ,object_version_number
      ,all_assignments
      ,period_months
    from        per_previous_jobs
    where       previous_job_id = p_previous_job_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_previous_job_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_previous_job_id
        = per_pjo_shd.g_old_rec.previous_job_id and
        p_object_version_number
        = per_pjo_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_pjo_shd.g_old_rec;
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
          <> per_pjo_shd.g_old_rec.object_version_number) Then
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
  (p_previous_job_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       previous_job_id
      ,previous_employer_id
      ,start_date
      ,end_date
      ,period_years
      ,period_days
      ,job_name
      ,employment_category
      ,description
      ,pjo_attribute_category
      ,pjo_attribute1
      ,pjo_attribute2
      ,pjo_attribute3
      ,pjo_attribute4
      ,pjo_attribute5
      ,pjo_attribute6
      ,pjo_attribute7
      ,pjo_attribute8
      ,pjo_attribute9
      ,pjo_attribute10
      ,pjo_attribute11
      ,pjo_attribute12
      ,pjo_attribute13
      ,pjo_attribute14
      ,pjo_attribute15
      ,pjo_attribute16
      ,pjo_attribute17
      ,pjo_attribute18
      ,pjo_attribute19
      ,pjo_attribute20
      ,pjo_attribute21
      ,pjo_attribute22
      ,pjo_attribute23
      ,pjo_attribute24
      ,pjo_attribute25
      ,pjo_attribute26
      ,pjo_attribute27
      ,pjo_attribute28
      ,pjo_attribute29
      ,pjo_attribute30
      ,pjo_information_category
      ,pjo_information1
      ,pjo_information2
      ,pjo_information3
      ,pjo_information4
      ,pjo_information5
      ,pjo_information6
      ,pjo_information7
      ,pjo_information8
      ,pjo_information9
      ,pjo_information10
      ,pjo_information11
      ,pjo_information12
      ,pjo_information13
      ,pjo_information14
      ,pjo_information15
      ,pjo_information16
      ,pjo_information17
      ,pjo_information18
      ,pjo_information19
      ,pjo_information20
      ,pjo_information21
      ,pjo_information22
      ,pjo_information23
      ,pjo_information24
      ,pjo_information25
      ,pjo_information26
      ,pjo_information27
      ,pjo_information28
      ,pjo_information29
      ,pjo_information30
      ,object_version_number
      ,all_assignments
      ,period_months
    from        per_previous_jobs
    where       previous_job_id = p_previous_job_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PREVIOUS_JOB_ID'
    ,p_argument_value     => p_previous_job_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_pjo_shd.g_old_rec;
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
      <> per_pjo_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_previous_jobs');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_previous_job_id                in number
  ,p_previous_employer_id           in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_period_years                   in number
  ,p_period_days                    in number
  ,p_job_name                       in varchar2
  ,p_employment_category            in varchar2
  ,p_description                    in varchar2
  ,p_pjo_attribute_category         in varchar2
  ,p_pjo_attribute1                 in varchar2
  ,p_pjo_attribute2                 in varchar2
  ,p_pjo_attribute3                 in varchar2
  ,p_pjo_attribute4                 in varchar2
  ,p_pjo_attribute5                 in varchar2
  ,p_pjo_attribute6                 in varchar2
  ,p_pjo_attribute7                 in varchar2
  ,p_pjo_attribute8                 in varchar2
  ,p_pjo_attribute9                 in varchar2
  ,p_pjo_attribute10                in varchar2
  ,p_pjo_attribute11                in varchar2
  ,p_pjo_attribute12                in varchar2
  ,p_pjo_attribute13                in varchar2
  ,p_pjo_attribute14                in varchar2
  ,p_pjo_attribute15                in varchar2
  ,p_pjo_attribute16                in varchar2
  ,p_pjo_attribute17                in varchar2
  ,p_pjo_attribute18                in varchar2
  ,p_pjo_attribute19                in varchar2
  ,p_pjo_attribute20                in varchar2
  ,p_pjo_attribute21                in varchar2
  ,p_pjo_attribute22                in varchar2
  ,p_pjo_attribute23                in varchar2
  ,p_pjo_attribute24                in varchar2
  ,p_pjo_attribute25                in varchar2
  ,p_pjo_attribute26                in varchar2
  ,p_pjo_attribute27                in varchar2
  ,p_pjo_attribute28                in varchar2
  ,p_pjo_attribute29                in varchar2
  ,p_pjo_attribute30                in varchar2
  ,p_pjo_information_category       in varchar2
  ,p_pjo_information1               in varchar2
  ,p_pjo_information2               in varchar2
  ,p_pjo_information3               in varchar2
  ,p_pjo_information4               in varchar2
  ,p_pjo_information5               in varchar2
  ,p_pjo_information6               in varchar2
  ,p_pjo_information7               in varchar2
  ,p_pjo_information8               in varchar2
  ,p_pjo_information9               in varchar2
  ,p_pjo_information10              in varchar2
  ,p_pjo_information11              in varchar2
  ,p_pjo_information12              in varchar2
  ,p_pjo_information13              in varchar2
  ,p_pjo_information14              in varchar2
  ,p_pjo_information15              in varchar2
  ,p_pjo_information16              in varchar2
  ,p_pjo_information17              in varchar2
  ,p_pjo_information18              in varchar2
  ,p_pjo_information19              in varchar2
  ,p_pjo_information20              in varchar2
  ,p_pjo_information21              in varchar2
  ,p_pjo_information22              in varchar2
  ,p_pjo_information23              in varchar2
  ,p_pjo_information24              in varchar2
  ,p_pjo_information25              in varchar2
  ,p_pjo_information26              in varchar2
  ,p_pjo_information27              in varchar2
  ,p_pjo_information28              in varchar2
  ,p_pjo_information29              in varchar2
  ,p_pjo_information30              in varchar2
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
  l_rec.previous_job_id                  := p_previous_job_id;
  l_rec.previous_employer_id             := p_previous_employer_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.period_years                     := p_period_years;
  l_rec.period_days                      := p_period_days;
  l_rec.job_name                         := p_job_name;
  l_rec.employment_category              := p_employment_category;
  l_rec.description                      := p_description;
  l_rec.pjo_attribute_category           := p_pjo_attribute_category;
  l_rec.pjo_attribute1                   := p_pjo_attribute1;
  l_rec.pjo_attribute2                   := p_pjo_attribute2;
  l_rec.pjo_attribute3                   := p_pjo_attribute3;
  l_rec.pjo_attribute4                   := p_pjo_attribute4;
  l_rec.pjo_attribute5                   := p_pjo_attribute5;
  l_rec.pjo_attribute6                   := p_pjo_attribute6;
  l_rec.pjo_attribute7                   := p_pjo_attribute7;
  l_rec.pjo_attribute8                   := p_pjo_attribute8;
  l_rec.pjo_attribute9                   := p_pjo_attribute9;
  l_rec.pjo_attribute10                  := p_pjo_attribute10;
  l_rec.pjo_attribute11                  := p_pjo_attribute11;
  l_rec.pjo_attribute12                  := p_pjo_attribute12;
  l_rec.pjo_attribute13                  := p_pjo_attribute13;
  l_rec.pjo_attribute14                  := p_pjo_attribute14;
  l_rec.pjo_attribute15                  := p_pjo_attribute15;
  l_rec.pjo_attribute16                  := p_pjo_attribute16;
  l_rec.pjo_attribute17                  := p_pjo_attribute17;
  l_rec.pjo_attribute18                  := p_pjo_attribute18;
  l_rec.pjo_attribute19                  := p_pjo_attribute19;
  l_rec.pjo_attribute20                  := p_pjo_attribute20;
  l_rec.pjo_attribute21                  := p_pjo_attribute21;
  l_rec.pjo_attribute22                  := p_pjo_attribute22;
  l_rec.pjo_attribute23                  := p_pjo_attribute23;
  l_rec.pjo_attribute24                  := p_pjo_attribute24;
  l_rec.pjo_attribute25                  := p_pjo_attribute25;
  l_rec.pjo_attribute26                  := p_pjo_attribute26;
  l_rec.pjo_attribute27                  := p_pjo_attribute27;
  l_rec.pjo_attribute28                  := p_pjo_attribute28;
  l_rec.pjo_attribute29                  := p_pjo_attribute29;
  l_rec.pjo_attribute30                  := p_pjo_attribute30;
  l_rec.pjo_information_category         := p_pjo_information_category;
  l_rec.pjo_information1                 := p_pjo_information1;
  l_rec.pjo_information2                 := p_pjo_information2;
  l_rec.pjo_information3                 := p_pjo_information3;
  l_rec.pjo_information4                 := p_pjo_information4;
  l_rec.pjo_information5                 := p_pjo_information5;
  l_rec.pjo_information6                 := p_pjo_information6;
  l_rec.pjo_information7                 := p_pjo_information7;
  l_rec.pjo_information8                 := p_pjo_information8;
  l_rec.pjo_information9                 := p_pjo_information9;
  l_rec.pjo_information10                := p_pjo_information10;
  l_rec.pjo_information11                := p_pjo_information11;
  l_rec.pjo_information12                := p_pjo_information12;
  l_rec.pjo_information13                := p_pjo_information13;
  l_rec.pjo_information14                := p_pjo_information14;
  l_rec.pjo_information15                := p_pjo_information15;
  l_rec.pjo_information16                := p_pjo_information16;
  l_rec.pjo_information17                := p_pjo_information17;
  l_rec.pjo_information18                := p_pjo_information18;
  l_rec.pjo_information19                := p_pjo_information19;
  l_rec.pjo_information20                := p_pjo_information20;
  l_rec.pjo_information21                := p_pjo_information21;
  l_rec.pjo_information22                := p_pjo_information22;
  l_rec.pjo_information23                := p_pjo_information23;
  l_rec.pjo_information24                := p_pjo_information24;
  l_rec.pjo_information25                := p_pjo_information25;
  l_rec.pjo_information26                := p_pjo_information26;
  l_rec.pjo_information27                := p_pjo_information27;
  l_rec.pjo_information28                := p_pjo_information28;
  l_rec.pjo_information29                := p_pjo_information29;
  l_rec.pjo_information30                := p_pjo_information30;
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
end per_pjo_shd;

/
