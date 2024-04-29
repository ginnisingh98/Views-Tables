--------------------------------------------------------
--  DDL for Package Body PER_ZA_AO_ASS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_AO_ASS_SHD" as
/* $Header: pezaaash.pkb 115.2 2002/12/10 09:54:49 nsugavan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_ao_ass_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_QUALIFICATIONS_FK1') Then
    hr_utility.set_message(801, 'HR_51850_ass_ATT_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_FK2') Then
    hr_utility.set_message(801, 'HR_51851_ass_QUAL_TYPE_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_FK3') Then
    hr_utility.set_message(801, 'HR_51852_ass_BUS_GRP_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_UK') Then
    hr_utility.set_message(801,'HR_51847_ass_REC_EXISTS');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ass_CHK_DATES') Then
    hr_utility.set_message(801, 'HR_51853_ass_DATE_INV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_PK') Then
    hr_utility.set_message(801, 'HR_51854_ass_QUAL_ID_PK');
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
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  	p_area_of_assessment_id in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
	    area_of_assessment_id,
  		assessment_id,
		area_of_assessment,
		assessment_result,
		assessment_criteria
    from
    	per_za_areas_of_assessment
    where
    	area_of_assessment_id = p_area_of_assessment_id
    for	update nowait;

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
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'area_of_assessment_id',
     p_argument_value => p_area_of_assessment_id);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_za_ao_assessments');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args(
    p_area_of_assessment_id	    in number,
  	p_assessment_id           	in number,
	p_area_of_assessment		in varchar2,
	p_assessment_result			in varchar2,
	p_assessment_criteria		in varchar2
)
	Return g_za_rec_type is
--
  l_rec	  g_za_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.area_of_assessment_id     := p_area_of_assessment_id;
  l_rec.assessment_id			  := p_assessment_id;
  l_rec.area_of_assessment		  := p_area_of_assessment;
  l_rec.assessment_result		  := p_assessment_result;
  l_rec.assessment_criteria		  := p_assessment_criteria;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
procedure get_new_id(p_area_of_assessment_id out nocopy number) IS
begin
    select
	    PER_ZA_AREAS_OF_ASSESSMENT_S.nextval
	into
	    p_area_of_assessment_id
	from
	    dual;
--
exception
   when others then
   p_area_of_assessment_id := null;
--
end get_new_id;

end per_za_ao_ass_shd;

/
