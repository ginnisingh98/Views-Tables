--------------------------------------------------------
--  DDL for Package Body PER_PJU_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJU_SHD" as
/* $Header: pepjurhi.pkb 115.14 2002/12/04 10:55:38 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pju_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_PREVIOUS_JOBS_USAGES_PK') Then
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
  (p_previous_job_usage_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       previous_job_usage_id
      ,assignment_id
      ,previous_employer_id
      ,previous_job_id
      ,start_date
      ,end_date
      ,period_years
      ,period_months
      ,period_days
      ,pju_attribute_category
      ,pju_attribute1
      ,pju_attribute2
      ,pju_attribute3
      ,pju_attribute4
      ,pju_attribute5
      ,pju_attribute6
      ,pju_attribute7
      ,pju_attribute8
      ,pju_attribute9
      ,pju_attribute10
      ,pju_attribute11
      ,pju_attribute12
      ,pju_attribute13
      ,pju_attribute14
      ,pju_attribute15
      ,pju_attribute16
      ,pju_attribute17
      ,pju_attribute18
      ,pju_attribute19
      ,pju_attribute20
      ,pju_information_category
      ,pju_information1
      ,pju_information2
      ,pju_information3
      ,pju_information4
      ,pju_information5
      ,pju_information6
      ,pju_information7
      ,pju_information8
      ,pju_information9
      ,pju_information10
      ,pju_information11
      ,pju_information12
      ,pju_information13
      ,pju_information14
      ,pju_information15
      ,pju_information16
      ,pju_information17
      ,pju_information18
      ,pju_information19
      ,pju_information20
      ,object_version_number
    from        per_previous_job_usages
    where       previous_job_usage_id = p_previous_job_usage_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_previous_job_usage_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_previous_job_usage_id
        = per_pju_shd.g_old_rec.previous_job_usage_id and
        p_object_version_number
        = per_pju_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_pju_shd.g_old_rec;
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
          <> per_pju_shd.g_old_rec.object_version_number) Then
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
  (p_previous_job_usage_id                in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       previous_job_usage_id
      ,assignment_id
      ,previous_employer_id
      ,previous_job_id
      ,start_date
      ,end_date
      ,period_years
      ,period_months
      ,period_days
      ,pju_attribute_category
      ,pju_attribute1
      ,pju_attribute2
      ,pju_attribute3
      ,pju_attribute4
      ,pju_attribute5
      ,pju_attribute6
      ,pju_attribute7
      ,pju_attribute8
      ,pju_attribute9
      ,pju_attribute10
      ,pju_attribute11
      ,pju_attribute12
      ,pju_attribute13
      ,pju_attribute14
      ,pju_attribute15
      ,pju_attribute16
      ,pju_attribute17
      ,pju_attribute18
      ,pju_attribute19
      ,pju_attribute20
      ,pju_information_category
      ,pju_information1
      ,pju_information2
      ,pju_information3
      ,pju_information4
      ,pju_information5
      ,pju_information6
      ,pju_information7
      ,pju_information8
      ,pju_information9
      ,pju_information10
      ,pju_information11
      ,pju_information12
      ,pju_information13
      ,pju_information14
      ,pju_information15
      ,pju_information16
      ,pju_information17
      ,pju_information18
      ,pju_information19
      ,pju_information20
      ,object_version_number
    from        per_previous_job_usages
    where       previous_job_usage_id = p_previous_job_usage_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PREVIOUS_JOB_USAGE_ID'
    ,p_argument_value     => p_previous_job_usage_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_pju_shd.g_old_rec;
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
      <> per_pju_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_previous_job_usages');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_previous_job_usage_id          in number
  ,p_assignment_id                  in number
  ,p_previous_employer_id           in number
  ,p_previous_job_id                in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_period_years                   in number
  ,p_period_months                  in number
  ,p_period_days                    in number
  ,p_pju_attribute_category         in varchar2
  ,p_pju_attribute1                 in varchar2
  ,p_pju_attribute2                 in varchar2
  ,p_pju_attribute3                 in varchar2
  ,p_pju_attribute4                 in varchar2
  ,p_pju_attribute5                 in varchar2
  ,p_pju_attribute6                 in varchar2
  ,p_pju_attribute7                 in varchar2
  ,p_pju_attribute8                 in varchar2
  ,p_pju_attribute9                 in varchar2
  ,p_pju_attribute10                in varchar2
  ,p_pju_attribute11                in varchar2
  ,p_pju_attribute12                in varchar2
  ,p_pju_attribute13                in varchar2
  ,p_pju_attribute14                in varchar2
  ,p_pju_attribute15                in varchar2
  ,p_pju_attribute16                in varchar2
  ,p_pju_attribute17                in varchar2
  ,p_pju_attribute18                in varchar2
  ,p_pju_attribute19                in varchar2
  ,p_pju_attribute20                in varchar2
  ,p_pju_information_category       in varchar2
  ,p_pju_information1               in varchar2
  ,p_pju_information2               in varchar2
  ,p_pju_information3               in varchar2
  ,p_pju_information4               in varchar2
  ,p_pju_information5               in varchar2
  ,p_pju_information6               in varchar2
  ,p_pju_information7               in varchar2
  ,p_pju_information8               in varchar2
  ,p_pju_information9               in varchar2
  ,p_pju_information10              in varchar2
  ,p_pju_information11              in varchar2
  ,p_pju_information12              in varchar2
  ,p_pju_information13              in varchar2
  ,p_pju_information14              in varchar2
  ,p_pju_information15              in varchar2
  ,p_pju_information16              in varchar2
  ,p_pju_information17              in varchar2
  ,p_pju_information18              in varchar2
  ,p_pju_information19              in varchar2
  ,p_pju_information20              in varchar2
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
  l_rec.previous_job_usage_id            := p_previous_job_usage_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.previous_employer_id             := p_previous_employer_id;
  l_rec.previous_job_id                  := p_previous_job_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.period_years                     := p_period_years;
  l_rec.period_months                    := p_period_months;
  l_rec.period_days                      := p_period_days;
  l_rec.pju_attribute_category           := p_pju_attribute_category;
  l_rec.pju_attribute1                   := p_pju_attribute1;
  l_rec.pju_attribute2                   := p_pju_attribute2;
  l_rec.pju_attribute3                   := p_pju_attribute3;
  l_rec.pju_attribute4                   := p_pju_attribute4;
  l_rec.pju_attribute5                   := p_pju_attribute5;
  l_rec.pju_attribute6                   := p_pju_attribute6;
  l_rec.pju_attribute7                   := p_pju_attribute7;
  l_rec.pju_attribute8                   := p_pju_attribute8;
  l_rec.pju_attribute9                   := p_pju_attribute9;
  l_rec.pju_attribute10                  := p_pju_attribute10;
  l_rec.pju_attribute11                  := p_pju_attribute11;
  l_rec.pju_attribute12                  := p_pju_attribute12;
  l_rec.pju_attribute13                  := p_pju_attribute13;
  l_rec.pju_attribute14                  := p_pju_attribute14;
  l_rec.pju_attribute15                  := p_pju_attribute15;
  l_rec.pju_attribute16                  := p_pju_attribute16;
  l_rec.pju_attribute17                  := p_pju_attribute17;
  l_rec.pju_attribute18                  := p_pju_attribute18;
  l_rec.pju_attribute19                  := p_pju_attribute19;
  l_rec.pju_attribute20                  := p_pju_attribute20;
  l_rec.pju_information_category         := p_pju_information_category;
  l_rec.pju_information1                 := p_pju_information1;
  l_rec.pju_information2                 := p_pju_information2;
  l_rec.pju_information3                 := p_pju_information3;
  l_rec.pju_information4                 := p_pju_information4;
  l_rec.pju_information5                 := p_pju_information5;
  l_rec.pju_information6                 := p_pju_information6;
  l_rec.pju_information7                 := p_pju_information7;
  l_rec.pju_information8                 := p_pju_information8;
  l_rec.pju_information9                 := p_pju_information9;
  l_rec.pju_information10                := p_pju_information10;
  l_rec.pju_information11                := p_pju_information11;
  l_rec.pju_information12                := p_pju_information12;
  l_rec.pju_information13                := p_pju_information13;
  l_rec.pju_information14                := p_pju_information14;
  l_rec.pju_information15                := p_pju_information15;
  l_rec.pju_information16                := p_pju_information16;
  l_rec.pju_information17                := p_pju_information17;
  l_rec.pju_information18                := p_pju_information18;
  l_rec.pju_information19                := p_pju_information19;
  l_rec.pju_information20                := p_pju_information20;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_pju_shd;

/
