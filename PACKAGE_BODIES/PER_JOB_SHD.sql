--------------------------------------------------------
--  DDL for Package Body PER_JOB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JOB_SHD" as
/* $Header: pejobrhi.pkb 120.0.12010000.2 2009/05/12 06:16:11 varanjan ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_job_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc    varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_JOBS_FK1') Then
    hr_utility.set_message(800, 'HR_52018_JOB_NO_BG');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_JOBS_FK2') Then
    hr_utility.set_message(800, 'HR_52017_JOB_DEF_INVALID');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'PER_JOBS_FK3') Then
    hr_utility.set_message(800,'HR_52670_JOB_GROUP_INV');
    hr_utility.set_message_token('PROCEDURE',l_proc);
    hr_utility.set_message_token('STEP','11');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_JOBS_PK') Then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;

  ElsIf (p_constraint_name = 'PER_JOBS_UK2') Then
    hr_utility.set_message(800, 'HR_52019_JOB_NAME_BG_EXISTS');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;

  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
   p_job_id                             in number,
   p_object_version_number              in number
  )
   Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
      job_id,
      business_group_id,
      job_definition_id,
      date_from,
      comments,
      date_to,
      approval_authority,
      name,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      job_information_category,
      job_information1,
      job_information2,
      job_information3,
      job_information4,
      job_information5,
      job_information6,
      job_information7,
      job_information8,
      job_information9,
      job_information10,
      job_information11,
      job_information12,
      job_information13,
      job_information14,
      job_information15,
      job_information16,
      job_information17,
      job_information18,
      job_information19,
      job_information20,
    benchmark_job_flag,
    benchmark_job_id,
    emp_rights_flag,
    job_group_id,
      object_version_number
    from     per_jobs
    where    job_id = p_job_id;
--
  l_proc varchar2(72)   := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
      p_job_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
        p_job_id                = g_old_rec.job_id and
        p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
   p_job_id                             in number,
   p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
      job_id,
      business_group_id,
      job_definition_id,
      date_from,
      comments,
      date_to,
      approval_authority,
      name,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      job_information_category,
      job_information1,
      job_information2,
      job_information3,
      job_information4,
      job_information5,
      job_information6,
      job_information7,
      job_information8,
      job_information9,
      job_information10,
      job_information11,
      job_information12,
      job_information13,
      job_information14,
      job_information15,
      job_information16,
      job_information17,
      job_information18,
      job_information19,
      job_information20,
    benchmark_job_flag,
    benchmark_job_id,
    emp_rights_flag,
    job_group_id,
      object_version_number
    from     per_jobs
    where    job_id = p_job_id
    for  update nowait;
--
  l_proc varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'object_version_number'
    ,p_argument_value => p_object_version_number);
--
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'per_jobs');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (
   p_job_id                        in number,
   p_business_group_id             in number,
   p_job_definition_id             in number,
   p_date_from                     in date,
   p_comments                      in varchar2,
   p_date_to                       in date,
   p_approval_authority            in number,
   p_name                          in varchar2,
   p_request_id                    in number,
   p_program_application_id        in number,
   p_program_id                    in number,
   p_program_update_date           in date,
   p_attribute_category            in varchar2,
   p_attribute1                    in varchar2,
   p_attribute2                    in varchar2,
   p_attribute3                    in varchar2,
   p_attribute4                    in varchar2,
   p_attribute5                    in varchar2,
   p_attribute6                    in varchar2,
   p_attribute7                    in varchar2,
   p_attribute8                    in varchar2,
   p_attribute9                    in varchar2,
   p_attribute10                   in varchar2,
   p_attribute11                   in varchar2,
   p_attribute12                   in varchar2,
   p_attribute13                   in varchar2,
   p_attribute14                   in varchar2,
   p_attribute15                   in varchar2,
   p_attribute16                   in varchar2,
   p_attribute17                   in varchar2,
   p_attribute18                   in varchar2,
   p_attribute19                   in varchar2,
   p_attribute20                   in varchar2,
   p_job_information_category      in varchar2,
   p_job_information1              in varchar2,
   p_job_information2              in varchar2,
   p_job_information3              in varchar2,
   p_job_information4              in varchar2,
   p_job_information5              in varchar2,
   p_job_information6              in varchar2,
   p_job_information7              in varchar2,
   p_job_information8              in varchar2,
   p_job_information9              in varchar2,
   p_job_information10             in varchar2,
   p_job_information11             in varchar2,
   p_job_information12             in varchar2,
   p_job_information13             in varchar2,
   p_job_information14             in varchar2,
   p_job_information15             in varchar2,
   p_job_information16             in varchar2,
   p_job_information17             in varchar2,
   p_job_information18             in varchar2,
   p_job_information19             in varchar2,
   p_job_information20             in varchar2,
   p_benchmark_job_flag            in varchar2,
   p_benchmark_job_id              in number,
   p_emp_rights_flag               in varchar2,
   p_job_group_id                  in number,
   p_object_version_number         in number
  )
  Return g_rec_type is
--
  l_rec    g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.job_id                           := p_job_id;
  hr_utility.set_location('Entering:'||l_proc, 1);
  l_rec.business_group_id                := p_business_group_id;
  hr_utility.set_location('Entering:'||l_proc, 2);
  l_rec.job_definition_id                := p_job_definition_id;
  hr_utility.set_location('Entering:'||l_proc, 3);
  l_rec.date_from                        := p_date_from;
  hr_utility.set_location('Entering:'||l_proc, 4);
  l_rec.comments                         := p_comments;
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_rec.date_to                          := p_date_to;
  hr_utility.set_location('Entering:'||l_proc, 6);
  l_rec.approval_authority               := p_approval_authority;
  hr_utility.set_location('Entering:'||l_proc, 7);
  l_rec.name                             := p_name;
  hr_utility.set_location('Entering:'||l_proc, 8);
  l_rec.request_id                       := p_request_id;
  hr_utility.set_location('Entering:'||l_proc, 9);
  l_rec.program_application_id           := p_program_application_id;
  hr_utility.set_location('Entering:'||l_proc, 10);
  l_rec.program_id                       := p_program_id;
  hr_utility.set_location('Entering:'||l_proc, 11);
  l_rec.program_update_date              := p_program_update_date;
  hr_utility.set_location('Entering:'||l_proc, 12);
  l_rec.attribute_category               := p_attribute_category;
  hr_utility.set_location('Entering:'||l_proc, 13);
  l_rec.attribute1                       := p_attribute1;
  hr_utility.set_location('Entering:'||l_proc, 14);
  l_rec.attribute2                       := p_attribute2;
  hr_utility.set_location('Entering:'||l_proc, 15);
  l_rec.attribute3                       := p_attribute3;
  hr_utility.set_location('Entering:'||l_proc, 16);
  l_rec.attribute4                       := p_attribute4;
  hr_utility.set_location('Entering:'||l_proc, 17);
  l_rec.attribute5                       := p_attribute5;
  hr_utility.set_location('Entering:'||l_proc, 18);
  l_rec.attribute6                       := p_attribute6;
  hr_utility.set_location('Entering:'||l_proc, 19);
  l_rec.attribute7                       := p_attribute7;
  hr_utility.set_location('Entering:'||l_proc, 20);
  l_rec.attribute8                       := p_attribute8;
  hr_utility.set_location('Entering:'||l_proc, 21);
  l_rec.attribute9                       := p_attribute9;
  hr_utility.set_location('Entering:'||l_proc, 22);
  l_rec.attribute10                      := p_attribute10;
  hr_utility.set_location('Entering:'||l_proc, 23);
  l_rec.attribute11                      := p_attribute11;
  hr_utility.set_location('Entering:'||l_proc, 24);
  l_rec.attribute12                      := p_attribute12;
  hr_utility.set_location('Entering:'||l_proc, 25);
  l_rec.attribute13                      := p_attribute13;
  hr_utility.set_location('Entering:'||l_proc, 26);
  l_rec.attribute14                      := p_attribute14;
  hr_utility.set_location('Entering:'||l_proc, 27);
  l_rec.attribute15                      := p_attribute15;
  hr_utility.set_location('Entering:'||l_proc, 28);
  l_rec.attribute16                      := p_attribute16;
  hr_utility.set_location('Entering:'||l_proc, 29);
  l_rec.attribute17                      := p_attribute17;
  hr_utility.set_location('Entering:'||l_proc, 30);
  l_rec.attribute18                      := p_attribute18;
  hr_utility.set_location('Entering:'||l_proc, 31);
  l_rec.attribute19                      := p_attribute19;
  hr_utility.set_location('Entering:'||l_proc, 32);
  l_rec.attribute20                      := p_attribute20;
  hr_utility.set_location('Entering:'||l_proc, 33);
  l_rec.job_information_category         := p_job_information_category;
  hr_utility.set_location('Entering:'||l_proc, 34);
  l_rec.job_information1                 := p_job_information1;
  hr_utility.set_location('Entering:'||l_proc, 35);
  l_rec.job_information2                 := p_job_information2;
  hr_utility.set_location('Entering:'||l_proc, 36);
  l_rec.job_information3                 := p_job_information3;
  hr_utility.set_location('Entering:'||l_proc, 37);
  l_rec.job_information4                 := p_job_information4;
  hr_utility.set_location('Entering:'||l_proc, 38);
  l_rec.job_information5                 := p_job_information5;
  hr_utility.set_location('Entering:'||l_proc, 39);
  l_rec.job_information6                 := p_job_information6;
  hr_utility.set_location('Entering:'||l_proc, 40);
  l_rec.job_information7                 := p_job_information7;
  hr_utility.set_location('Entering:'||l_proc, 41);
  l_rec.job_information8                 := p_job_information8;
  hr_utility.set_location('Entering:'||l_proc, 42);
  l_rec.job_information9                 := p_job_information9;
  hr_utility.set_location('Entering:'||l_proc, 43);
  l_rec.job_information10                := p_job_information10;
  hr_utility.set_location('Entering:'||l_proc, 44);
  l_rec.job_information11                := p_job_information11;
  hr_utility.set_location('Entering:'||l_proc, 45);
  l_rec.job_information12                := p_job_information12;
  hr_utility.set_location('Entering:'||l_proc, 46);
  l_rec.job_information13                := p_job_information13;
  hr_utility.set_location('Entering:'||l_proc, 47);
  l_rec.job_information14                := p_job_information14;
  hr_utility.set_location('Entering:'||l_proc, 48);
  l_rec.job_information15                := p_job_information15;
  hr_utility.set_location('Entering:'||l_proc, 49);
  l_rec.job_information16                := p_job_information16;
  hr_utility.set_location('Entering:'||l_proc, 50);
  l_rec.job_information17                := p_job_information17;
  hr_utility.set_location('Entering:'||l_proc, 51);
  l_rec.job_information18                := p_job_information18;
  hr_utility.set_location('Entering:'||l_proc, 52);
  l_rec.job_information19                := p_job_information19;
  hr_utility.set_location('Entering:'||l_proc, 53);
  l_rec.job_information20                := p_job_information20;
  hr_utility.set_location('Entering:'||l_proc, 54);
  l_rec.benchmark_job_flag               := p_benchmark_job_flag;
  hr_utility.set_location('Entering:'||l_proc, 55);
  l_rec.benchmark_job_id                 := p_benchmark_job_id;
  hr_utility.set_location('Entering:'||l_proc, 56);
  l_rec.emp_rights_flag                  := p_emp_rights_flag;
  hr_utility.set_location('Entering:'||l_proc, 57);
  l_rec.job_group_id                     := p_job_group_id;
  hr_utility.set_location('Entering:'||l_proc, 58);
  l_rec.object_version_number            := p_object_version_number;
  hr_utility.set_location('Entering:'||l_proc, 59);
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_job_shd;

/
