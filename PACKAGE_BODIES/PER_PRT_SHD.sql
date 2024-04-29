--------------------------------------------------------
--  DDL for Package Body PER_PRT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PRT_SHD" as
/* $Header: peprtrhi.pkb 120.2 2006/05/03 18:37:44 kandra noship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_prt_shd.';  -- Global package name

-- ---------------------------------------------------------------------------+
-- |---------------------------< constraint_error >---------------------------|
-- ---------------------------------------------------------------------------+
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is

  l_proc 	varchar2(72) := g_package||'constraint_error';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If (p_constraint_name = 'PER_PERFORMANCE_RATINGS_FK2') Then
    hr_utility.set_message(801, 'HR_51919_PRT_APR_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PERFORMANCE_RATINGS_FK4') Then
    hr_utility.set_message(801, 'HR_51925_PRT_RLI_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PERFORMANCE_RATINGS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;

-- ---------------------------------------------------------------------------+
-- |-----------------------------< api_updating >-----------------------------|
-- ---------------------------------------------------------------------------+
Function api_updating
  (
  p_performance_rating_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is


  -- Cursor selects the 'current' row from the HR Schema

  Cursor C_Sel1 is
    select
	performance_rating_id,
	person_id,
	objective_id,
	object_version_number,
	appraisal_id,
	performance_level_id,
	comments,
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
	appr_line_score
    from	per_performance_ratings
    where	performance_rating_id = p_performance_rating_id;

  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If (
	p_performance_rating_id is null and
	p_object_version_number is null
     ) Then

    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false

    l_fct_ret := false;
  Else
    If (
	p_performance_rating_id = g_old_rec.performance_rating_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);

      -- The g_old_rec is current therefore we must
      -- set the returning function to true

      l_fct_ret := true;
    Else

      -- Select the current row into g_old_rec

      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;

        -- The primary key is invalid therefore we must error

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

End api_updating;

-- ---------------------------------------------------------------------------+
-- |---------------------------------< lck >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure lck
  (
  p_performance_rating_id              in number,
  p_object_version_number              in number
  ) is

-- Cursor selects the 'current' row from the HR Schema

  Cursor C_Sel1 is
    select 	performance_rating_id,

	person_id,
	objective_id,
	object_version_number,
	appraisal_id,
	performance_level_id,
	comments,
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
	appr_line_score
    from	per_performance_ratings
    where	performance_rating_id = p_performance_rating_id
    for	update nowait;

  l_proc	varchar2(72) := g_package||'lck';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);

  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;

    -- The primary key is invalid therefore we must error

    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

-- We need to trap the ORA LOCK exception

Exception
  When HR_Api.Object_Locked then

    -- The object is locked therefore we need to supply a meaningful
    -- error message.

    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'per_performance_ratings');
    hr_utility.raise_error;
End lck;

-- ---------------------------------------------------------------------------+
-- |-----------------------------< convert_args >-----------------------------|
-- ---------------------------------------------------------------------------+
Function convert_args
	(
	p_performance_rating_id         in number,
	p_person_id                     in number,
	p_objective_id                  in number,
	p_object_version_number         in number,
	p_appraisal_id                  in number,
	p_performance_level_id          in number,
	p_comments                      in varchar2,
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
	p_appr_line_score               in number
	)
	Return g_rec_type is

  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Convert arguments into local l_rec structure.

  l_rec.performance_rating_id            := p_performance_rating_id;
  l_rec.person_id                        := p_person_id;
  l_rec.objective_id                     := p_objective_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.appraisal_id                     := p_appraisal_id;
  l_rec.performance_level_id             := p_performance_level_id;
  l_rec.comments                         := p_comments;
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
  l_rec.appr_line_score                  := p_appr_line_score;

  -- Return the plsql record structure.

  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);

End convert_args;

end per_prt_shd;

/
