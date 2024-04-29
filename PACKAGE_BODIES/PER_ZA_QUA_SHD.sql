--------------------------------------------------------
--  DDL for Package Body PER_ZA_QUA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_QUA_SHD" as
/* $Header: pezaqush.pkb 115.0 2001/02/04 22:35:21 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_qua_shd.';  -- Global package name
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
    hr_utility.set_message(801, 'HR_51850_QUA_ATT_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_FK2') Then
    hr_utility.set_message(801, 'HR_51851_QUA_QUAL_TYPE_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_FK3') Then
    hr_utility.set_message(801, 'HR_51852_QUA_BUS_GRP_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_UK') Then
    hr_utility.set_message(801,'HR_51847_QUA_REC_EXISTS');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUA_CHK_DATES') Then
    hr_utility.set_message(801, 'HR_51853_QUA_DATE_INV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_PK') Then
    hr_utility.set_message(801, 'HR_51854_QUA_QUAL_ID_PK');
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
  p_qualification_id                   in per_subjects_taken.QUALIFICATION_ID%TYPE
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
	    qualification_id,
		level_id,
		field_of_learning,
		sub_field,
		registration_date,
		registration_number
    from
	    per_za_formal_qualifications
    where
	    qualification_id = p_qualification_id
    for	update nowait;

   l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

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
    hr_utility.set_message_token('TABLE_NAME', 'per_qualifications');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_qualification_id              in number,
	p_level_id                      in number,
	p_field_of_learning             in varchar2,
	p_sub_field                     in varchar2,
	p_registration_date             in date,
	p_registration_number           in varchar2
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
  l_rec.qualification_id                 := p_qualification_id;
  l_rec.level_id                         := p_level_id;
  l_rec.field_of_learning                := p_field_of_learning;
  l_rec.sub_field                        := p_sub_field;
  l_rec.registration_date                := p_registration_date;
  l_rec.registration_number              := p_registration_number;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_za_qua_shd;

/
