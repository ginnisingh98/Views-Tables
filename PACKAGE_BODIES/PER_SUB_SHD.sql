--------------------------------------------------------
--  DDL for Package Body PER_SUB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUB_SHD" as
/* $Header: pesubrhi.pkb 115.14 2004/02/23 01:47:08 smparame ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_sub_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
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
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_SUBJECTS_TAKEN_FK1') Then
    hr_utility.set_message(801, 'HR_51813_SUB_QUAL_ID_REF');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_SUBJECTS_TAKEN_PK') Then
    hr_utility.set_message(801, 'HR_51814_SUB_SUB_TAKEN_ID_PK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_SUBJECTS_TAKEN_UK1') Then
    hr_utility.set_message(801, 'HR_51815_SUB_REC_NOT_UNIQ');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_SUB_START_DATES') Then
    hr_utility.set_message(801, 'HR_51816_SUB_START_DATE_INV');
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
  p_subjects_taken_id                  in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		subjects_taken_id,
	start_date,
	major,
	subject_status,
	subject,
	grade_attained,
	end_date,
	qualification_id,
	object_version_number,
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
	sub_information_category,
	sub_information1,
	sub_information2,
	sub_information3,
	sub_information4,
	sub_information5,
	sub_information6,
	sub_information7,
	sub_information8,
	sub_information9,
	sub_information10,
	sub_information11,
	sub_information12,
	sub_information13,
	sub_information14,
	sub_information15,
	sub_information16,
	sub_information17,
	sub_information18,
	sub_information19,
	sub_information20
    from	per_subjects_taken
    where	subjects_taken_id = p_subjects_taken_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_subjects_taken_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_subjects_taken_id = g_old_rec.subjects_taken_id and
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
  p_subjects_taken_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	subjects_taken_id,
	start_date,
	major,
	subject_status,
	subject,
	grade_attained,
	end_date,
	qualification_id,
	object_version_number,
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
	sub_information_category,
	sub_information1,
	sub_information2,
	sub_information3,
	sub_information4,
	sub_information5,
	sub_information6,
	sub_information7,
	sub_information8,
	sub_information9,
	sub_information10,
	sub_information11,
	sub_information12,
	sub_information13,
	sub_information14,
	sub_information15,
	sub_information16,
	sub_information17,
	sub_information18,
	sub_information19,
	sub_information20
    from	per_subjects_taken
    where	subjects_taken_id = p_subjects_taken_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_subjects_taken');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_subjects_taken_id             in number,
	p_start_date                    in date,
	p_major                         in varchar2,
	p_subject_status                in varchar2,
	p_subject                       in varchar2,
	p_grade_attained                in varchar2,
	p_end_date                      in date,
	p_qualification_id              in number,
	p_object_version_number         in number,
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
	p_sub_information_category            in varchar2,
	p_sub_information1                    in varchar2,
	p_sub_information2                    in varchar2,
	p_sub_information3                    in varchar2,
	p_sub_information4                    in varchar2,
	p_sub_information5                    in varchar2,
	p_sub_information6                    in varchar2,
	p_sub_information7                    in varchar2,
	p_sub_information8                    in varchar2,
	p_sub_information9                    in varchar2,
	p_sub_information10                   in varchar2,
	p_sub_information11                   in varchar2,
	p_sub_information12                   in varchar2,
	p_sub_information13                   in varchar2,
	p_sub_information14                   in varchar2,
	p_sub_information15                   in varchar2,
	p_sub_information16                   in varchar2,
	p_sub_information17                   in varchar2,
	p_sub_information18                   in varchar2,
	p_sub_information19                   in varchar2,
	p_sub_information20                   in varchar2
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.subjects_taken_id                := p_subjects_taken_id;
  l_rec.start_date                       := p_start_date;
  l_rec.major                            := p_major;
  l_rec.subject_status                   := p_subject_status;
  l_rec.subject                          := p_subject;
  l_rec.grade_attained                   := p_grade_attained;
  l_rec.end_date                         := p_end_date;
  l_rec.qualification_id                 := p_qualification_id;
  l_rec.object_version_number            := p_object_version_number;
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
  l_rec.sub_information_category               := p_sub_information_category;
  l_rec.sub_information1                       := p_sub_information1;
  l_rec.sub_information2                       := p_sub_information2;
  l_rec.sub_information3                       := p_sub_information3;
  l_rec.sub_information4                       := p_sub_information4;
  l_rec.sub_information5                       := p_sub_information5;
  l_rec.sub_information6                       := p_sub_information6;
  l_rec.sub_information7                       := p_sub_information7;
  l_rec.sub_information8                       := p_sub_information8;
  l_rec.sub_information9                       := p_sub_information9;
  l_rec.sub_information10                      := p_sub_information10;
  l_rec.sub_information11                      := p_sub_information11;
  l_rec.sub_information12                      := p_sub_information12;
  l_rec.sub_information13                      := p_sub_information13;
  l_rec.sub_information14                      := p_sub_information14;
  l_rec.sub_information15                      := p_sub_information15;
  l_rec.sub_information16                      := p_sub_information16;
  l_rec.sub_information17                      := p_sub_information17;
  l_rec.sub_information18                      := p_sub_information18;
  l_rec.sub_information19                      := p_sub_information19;
  l_rec.sub_information20                      := p_sub_information20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_sub_shd;

/
