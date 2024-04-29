--------------------------------------------------------
--  DDL for Package Body PER_ZA_TRA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_TRA_SHD" as
/* $Header: pezatrsh.pkb 115.0 2001/02/04 22:36:38 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_tra_shd.';  -- Global package name
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
    hr_utility.set_message(801, 'HR_51850_tra_ATT_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_FK2') Then
    hr_utility.set_message(801, 'HR_51851_tra_QUAL_TYPE_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_FK3') Then
    hr_utility.set_message(801, 'HR_51852_tra_BUS_GRP_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_UK') Then
    hr_utility.set_message(801,'HR_51847_tra_REC_EXISTS');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_tra_CHK_DATES') Then
    hr_utility.set_message(801, 'HR_51853_tra_DATE_INV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_PK') Then
    hr_utility.set_message(801, 'HR_51854_tra_QUAL_ID_PK');
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
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  	p_training_id          	in	number,
	p_person_id			in 	number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
 	TRAINING_ID,
 	LEVEL_ID,
 	PERSON_ID,
 	FIELD_OF_LEARNING,
 	COURSE,
 	SUB_FIELD,
 	CREDIT,
	NOTIONAL_HOURS,
 	REGISTRATION_DATE,
 	REGISTRATION_NUMBER
    from
	    	per_za_training
    where
	    	training_id = p_training_id
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
     p_argument       => 'training_id',
     p_argument_value => p_training_id);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_za_training');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	 	P_TRAINING_ID			IN	NUMBER,
 		P_LEVEL_ID               	IN	NUMBER,
 		P_PERSON_ID              	IN	NUMBER,
 		P_FIELD_OF_LEARNING      	IN	VARCHAR2,
 		P_COURSE                 	IN	VARCHAR2,
 		P_SUB_FIELD              	IN	VARCHAR2,
 		P_CREDIT                 	IN	NUMBER,
		P_NOTIONAL_HOURS			IN NUMBER,
 		P_REGISTRATION_DATE      	IN	DATE,
 		P_REGISTRATION_NUMBER    	IN	VARCHAR2
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
  l_rec.training_id			:= p_training_id;
  l_rec.level_id				:= p_level_id;
  l_rec.person_id				:= p_person_id;
  l_rec.field_of_learning		:= p_field_of_learning;
  l_rec.course				:= p_course;
  l_rec.sub_field				:= p_sub_field;
  l_rec.credit				:= p_credit;
  l_rec.notional_hours      := p_notional_hours;
  l_rec.registration_date		:= p_registration_date;
  l_rec.registration_number		:= p_registration_number;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_za_tra_shd;

/
