--------------------------------------------------------
--  DDL for Package Body PER_AST_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_AST_SHD" as
/* $Header: peastrhi.pkb 120.7.12010000.2 2008/10/20 14:11:39 kgowripe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ast_shd.';  -- Global package name
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
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  If (p_constraint_name = 'PER_ASS_TYPES_RATE_NULL_CHK') Then
    hr_utility.set_message(801, 'HR_51508_AST_R_ASSCLASS_ERR2');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASSESSMENT_TYPES_FK2') Then
    hr_utility.set_message(801, 'HR_51507_AST_RATE_ID_INVAL');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASS_TYPES_RATE_NOTNULL_CHK') Then
    hr_utility.set_message(801, 'HR_51506_AST_R_ASSCLAS_ERR');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASSESSMENT_TYPES_FK3') Then
    hr_utility.set_message(801, 'HR_51504_AST_WEIGHT_ID_INVAL');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASSESSMENT_TYPES_NAME_UK1') Then
    hr_utility.set_message(801, 'HR_51499_AST_NAME_NOT_UNIQ');
     hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASSESSMENT_TYPE_PK') Then
    -- The primary key is generated via a sequence, so it should never
    -- be invalid
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_FK2') Then
    hr_utility.set_message(800, 'HR_52605_AST_APT_EXISTS');
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
  p_assessment_type_id                 in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select assessment_type_id,
	name,
	business_group_id,
	description,
	rating_scale_id,
	weighting_scale_id,
	rating_scale_comment,
	weighting_scale_comment,
	assessment_classification,
	display_assessment_comments,
	date_from,
	date_to,
	comments,
	instructions,
	weighting_classification,
        line_score_formula,
        total_score_formula,
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
    type,
    line_score_formula_id,
    default_job_competencies,
    available_flag
    from	per_assessment_types
    where	assessment_type_id = p_assessment_type_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_assessment_type_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_assessment_type_id = g_old_rec.assessment_type_id and
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
  p_assessment_type_id                 in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
 	assessment_type_id,
	name,
	business_group_id,
	description,
	rating_scale_id,
	weighting_scale_id,
	rating_scale_comment,
	weighting_scale_comment,
	assessment_classification,
	display_assessment_comments,
	date_from,
	date_to,
	comments,
	instructions,
        weighting_classification,
        line_score_formula,
        total_score_formula,
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
    type,
    line_score_formula_id,
    default_job_competencies,
    available_flag
    from	per_assessment_types
    where	assessment_type_id = p_assessment_type_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_assessment_types');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_assessment_type_id            in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_description                   in varchar2,
	p_rating_scale_id               in number,
	p_weighting_scale_id            in number,
	p_rating_scale_comment          in varchar2,
	p_weighting_scale_comment       in varchar2,
	p_assessment_classification     in varchar2,
	p_display_assessment_comments   in varchar2,
	p_date_from			in date,
	p_date_to			in date,
	p_comments                      in varchar2,
	p_instructions                  in varchar2,
        p_weighting_classification      in varchar2,
        p_line_score_formula            in varchar2,
        p_total_score_formula           in varchar2,
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
	p_type                          in varchar2,
	p_line_score_formula_id         in number,
	p_default_job_competencies      in varchar2,
	p_available_flag                in varchar2
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
  l_rec.assessment_type_id               := p_assessment_type_id;
  l_rec.name                             := p_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.description                      := p_description;
  l_rec.rating_scale_id                  := p_rating_scale_id;
  l_rec.weighting_scale_id               := p_weighting_scale_id;
  l_rec.rating_scale_comment             := p_rating_scale_comment;
  l_rec.weighting_scale_comment          := p_weighting_scale_comment;
  l_rec.assessment_classification        := p_assessment_classification;
  l_rec.display_assessment_comments      := p_display_assessment_comments;
  l_rec.date_from			 := p_date_from;
  l_rec.date_to				 := p_date_to;
  l_rec.comments                         := p_comments;
  l_rec.instructions                     := p_instructions;
  l_rec.weighting_classification         := p_weighting_classification;
  l_rec.line_score_formula               := p_line_score_formula;
  l_rec.total_score_formula		 := p_total_score_formula;
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
  l_rec.type                             := p_type;
  l_rec.line_score_formula_id            := p_line_score_formula_id;
  l_rec.default_job_competencies         := p_default_job_competencies;
  l_rec.available_flag                   := p_available_flag;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_ast_shd;

/
