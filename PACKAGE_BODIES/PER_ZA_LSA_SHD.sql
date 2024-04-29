--------------------------------------------------------
--  DDL for Package Body PER_ZA_LSA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_LSA_SHD" as
/* $Header: pezalssh.pkb 115.0 2001/02/04 22:34:10 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_lsa_shd.';  -- Global package name
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
  	p_agreement_id     	in	number,
	p_person_id			in 	number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
        AGREEMENT_ID,
   		NAME,
   		DESCRIPTION,
   		AGREEMENT_NUMBER,
   		PERSON_ID,
   		AGREEMENT_START_DATE,
   		AGREEMENT_END_DATE,
   		STATUS,
   		SETA,
   		PROBATIONARY_END_DATE,
   		TERMINATED_BY,
   		LEARNER_TYPE,
   		REASON_FOR_TERMINATION,
   		ACTUAL_END_DATE,
   		AGREEMENT_HARD_COPY_ID,
   		LAST_UPDATE_DATE,
   		LAST_UPDATED_BY,
   		LAST_UPDATE_LOGIN,
   		CREATED_BY,
   		CREATION_DATE
	from
    	per_za_learnership_agreements
    where
    	agreement_id = p_agreement_id
    for	update nowait;

   l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'agreement_id',
     p_argument_value => p_agreement_id);

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
    hr_utility.set_message_token('TABLE_NAME', 'per_za_learnership_agreements');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
  	p_agreement_id           	in	number,
  	p_person_id             	in	number,
	p_name						in	varchar2,
	p_description				in	varchar2,
	p_agreement_number			in	varchar2,
	p_agreement_start_date		in	date,
	p_agreement_end_date		in	date,
	p_status					in	varchar2,
	p_seta						in	varchar2,
	p_probationary_end_date		in	date,
	p_terminated_by				in	varchar2,
	p_learner_type				in	varchar2,
	p_reason_for_termination	in	varchar2,
	p_actual_end_date			in	date,
	p_agreement_hard_copy_id	in	number
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
    l_rec.agreement_id           := p_agreement_id;
  	l_rec.person_id				 := p_person_id;
	l_rec.name					 := p_name;
	l_rec.description			 := p_description;
	l_rec.agreement_number		 := p_agreement_number;
	l_rec.probationary_end_date	 := p_probationary_end_date;
	l_rec.agreement_start_date	 := p_agreement_start_date;
	l_rec.agreement_end_date	 := p_agreement_end_date;
	l_rec.actual_end_date		 := p_actual_end_date;
	l_rec.SETA					 := p_seta;
	l_rec.learner_type			 := p_learner_type;
	l_rec.status				 := p_status;
	l_rec.terminated_by			 := p_terminated_by;
	l_rec.reason_for_termination := p_reason_for_termination;
	l_rec.agreement_hard_copy_id := p_agreement_hard_copy_id;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_za_lsa_shd;

/
