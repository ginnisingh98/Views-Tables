--------------------------------------------------------
--  DDL for Package Body PER_ZA_ASS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_ASS_SHD" as
/* $Header: pezaassh.pkb 115.0 2001/02/04 22:30:58 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_ass_shd.';  -- Global package name
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
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  	p_assessment_id           	in	number,
	p_person_id			in 	number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
  		assessment_id,
  		person_id,
  		level_id,
  		name_of_assessor,
  		institution,
  		credit,
  		date_of_assessment,
  		final_result,
  		assessment_number,
  		location_where_assessed,
  		field_of_learning,
		sub_field,
		assessment_start_date,
		assessment_end_date,
		competence_acquired,
		ETQA_name,
		certification_date,
		certificate_number,
		accredited_by,
		date_of_accreditation,
		certification_expiry_date
    from
    	per_za_assessments
    where
    	assessment_id = p_assessment_id
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
     p_argument       => 'assessment_id',
     p_argument_value => p_assessment_id);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_za_assessments');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args(
  	p_assessment_id           	in number,
	p_person_id             	in number,
	p_level_id             		in number,
	p_name_of_assessor 			in varchar2,
	p_institution 				in varchar2,
	p_credit             		in number,
	p_date_of_assessment 		in date,
	p_final_result 				in varchar2,
	p_assessment_number			in varchar2,
	p_location_where_assessed	in varchar2,
	p_field_of_learning 		in varchar2,
	p_sub_field					in varchar2,
	p_assessment_start_date     in date,
	p_assessment_end_date		in date,
	p_competence_acquired		in varchar2,
	p_ETQA_name				    in varchar2,
	p_certification_date		in date,
	p_certificate_number		in varchar2,
	p_accredited_by			    in varchar2,
	p_date_of_accreditation	    in date,
	p_certification_expiry_date in date)
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
  l_rec.assessment_id			  := p_assessment_id;
  l_rec.person_id				  := p_person_id;
  l_rec.level_id				  := p_level_id;
  l_rec.name_of_assessor		  := p_name_of_assessor;
  l_rec.institution				  := p_institution;
  l_rec.credit					  := p_credit;
  l_rec.date_of_assessment		  := p_date_of_assessment;
  l_rec.final_result			  := p_final_result;
  l_rec.assessment_number		  := p_assessment_number;
  l_rec.location_where_assessed	  := p_location_where_assessed;
  l_rec.field_of_learning		  := p_field_of_learning;
  l_rec.sub_field				  := p_sub_field;
  l_rec.assessment_start_date     := p_assessment_start_date;
  l_rec.assessment_end_date		  := p_assessment_end_date;
  l_rec.competence_acquired		  := p_competence_acquired;
  l_rec.ETQA_name				  := p_ETQA_name;
  l_rec.certification_date		  := p_certification_date;
  l_rec.certificate_number		  := p_certificate_number;
  l_rec.accredited_by			  := p_accredited_by;
  l_rec.date_of_accreditation	  := p_date_of_accreditation;
  l_rec.certification_expiry_date := p_certification_expiry_date;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
procedure validate_record(p_date_from                 in     date default null,
		  				  p_date_to	                  in     date default null,
						  p_date_of_assessment        in     date default null,
						  p_certification_date        in     date default null,
						  p_certification_expiry_date in     date default null,
						  p_date_of_accreditation     in     date default null) IS

  l_proc    varchar2(72) := g_package||'validate_record';
  l_message varchar2(50);

begin
    hr_utility.set_location(' Entering:'||l_proc, 10);

	-- check that the date from is <= date to
	if p_date_from is not null and p_date_to is not null and
       p_date_from > p_date_to
    then
    	hr_utility.set_location(' Entering:'||l_proc, 20);
		l_message := fnd_message.get_string('PAY','PER_74516_DATE_FROM_DATE_TO');
		fnd_message.set_encoded(l_message);
--		l_message := substr(l_message, 1, 30);
        hr_utility.set_message(801, 'PER_74516_DATE_FROM_DATE_TO');
--   	    hr_utility.set_message(801,l_message);
   	    hr_utility.raise_error;
	end if;

	-- check that the date from <= date of assessment
	if p_date_from is not null and p_date_of_assessment is not null and
	   p_date_from > p_date_of_assessment
	then
        hr_utility.set_location(' Entering:'||l_proc, 30);
		l_message := fnd_message.get_string('PAY','PER_74517_DATE_FROM_DATE_ASS');
   	    hr_utility.set_message(801,l_message);
   	    hr_utility.raise_error;
	end if;

	-- check that the date of assessment <= date to
	if p_date_of_assessment is not null and p_date_to is not null and
	   p_date_of_assessment > p_date_to
	then
    	hr_utility.set_location(' Entering:'||l_proc, 40);
		l_message := fnd_message.get_string('PAY','PER_74518_DATE_ASS_DATE_TO');
   	    hr_utility.set_message(801,l_message);
   	    hr_utility.raise_error;
	end if;

	-- check that the certification date >= date of assessment
	if p_certification_date is not null and p_date_of_assessment is not null and
	   p_certification_date < p_date_of_assessment
	then
    	hr_utility.set_location(' Entering:'||l_proc, 50);
		l_message := fnd_message.get_string('PAY','PER_74519_DATE_CERT_DATE_ASS');
   	    hr_utility.set_message(801,l_message);
   	    hr_utility.raise_error;
	end if;

	-- check that the date of accreditation <= certification date
	if p_date_of_accreditation is not null and p_certification_date is not null and
	   p_date_of_accreditation < p_certification_date
	then
    	hr_utility.set_location(' Entering:'||l_proc, 60);
		l_message := fnd_message.get_string('PAY','PER_74520_DATE_ACCR_DATE_CERT');
   	    hr_utility.set_message(801,l_message);
   	    hr_utility.raise_error;
	end if;

	-- check that the certification date < certification date
	if p_certification_expiry_date is not null and p_certification_date is not null and
	   p_certification_expiry_date >= p_certification_date
	then
    	hr_utility.set_location(' Entering:'||l_proc, 70);
		l_message := fnd_message.get_string('PAY','PER_74521_EXP_DATE_CERT_DATE');
   	    hr_utility.set_message(801,l_message);
   	    hr_utility.raise_error;
	end if;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
end validate_record;

end per_za_ass_shd;

/
