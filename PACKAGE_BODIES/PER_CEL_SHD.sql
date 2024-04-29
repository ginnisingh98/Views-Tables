--------------------------------------------------------
--  DDL for Package Body PER_CEL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CEL_SHD" as
/* $Header: pecelrhi.pkb 120.3 2006/03/28 05:27:21 arumukhe noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cel_shd.';  -- Global package name
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
  Hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK1') Then
    hr_utility.set_message(800, 'HR_52251_CEL_COMP_ID_INVL');
    hr_utility.set_location(l_proc,10);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.COMPETENCE_ID');
    hr_utility.raise_error;

  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK2') Then
    hr_utility.set_message(801, 'HR_51612_CEL_BUS_GROUP_ID_INVL');
    hr_utility.set_location(l_proc,15);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.BUSINESS_GROUP_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK5') Then

    hr_utility.set_message(801, 'HR_51615_CEL_PROF_ID_INVL');
    hr_utility.set_location(l_proc,30);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.PROFICIENCY_LEVEL_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK6') Then
    hr_utility.set_message(801, 'HR_51616_CEL_HG_PROF_ID_INVL');
    hr_utility.set_location(l_proc,35);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.HIGH_PROFICIENCY_LEVEL_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK7') Then
    hr_utility.set_message(801, 'HR_51621_CEL_PERSON_ID_INVL');
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.PERSON_ID');
    hr_utility.set_location(l_proc,40);
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK8') Then
    hr_utility.set_message(801, 'HR_51620_CEL_JOB_ID_INVL');
    hr_utility.set_location(l_proc,45);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.JOB_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK9') Then
    hr_utility.set_message(801, 'HR_51622_CEL_POSITION_ID_INVL');
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.POSITION_ID');
    hr_utility.set_location(l_proc,50);
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK10') Then
    hr_utility.set_message(801, 'HR_51623_CEL_ORG_ID_INVL');
    hr_utility.set_location(l_proc,55);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.ORGANIZATION_ID');
    hr_utility.raise_error;

  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK14') Then
    hr_utility.set_message(801, 'HR_51628_CEL_ASS_ID_INVL');
    hr_utility.set_location(l_proc,70);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.ASSESSMENT_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK15') Then
    hr_utility.set_message(801, 'HR_51748_CEL_ASS_TYPE_ID_INVL');
    hr_utility.set_location(l_proc,75);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.ASSESSMENT_TYPE_ID');
    hr_utility.raise_error;

  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK16') Then
    hr_utility.set_message(801, 'HR_51631_CEL_RATE_ID_INVL');
    hr_utility.set_location(l_proc,80);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.RATING_LEVEL_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK17') Then
    hr_utility.set_message(801, 'HR_51632_CEL_WEG_ID_INVL');
    hr_utility.set_location(l_proc,85);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.WEIGHTING_LEVEL_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK18') Then
    hr_utility.set_message(801, 'HR_51633_CEL_PARENT_ID_INVL');
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.PARENT_COMPETENCE_ELEMENT_ID');
    hr_utility.set_location(l_proc,90);
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK19') Then
    hr_utility.set_message(800, 'HR_52341_PER_DATE_INVL');
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.VALID_GRADE_ID');
    hr_utility.set_location(l_proc,90);
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK20') Then
    hr_utility.set_message(800, 'HR_52338_COMP_DATE_INVL');
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.ENTERPRISE_ID');
    hr_utility.set_location(l_proc,90);
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK21') Then
    hr_utility.set_message(800, 'HR_52339_COMP_ELMT_DATE_INVL');
    hr_multi_message.add(
               p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM'
               ,p_associated_column2 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_TO'
               );
    hr_utility.set_location(l_proc,90);
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_FK22') Then
    hr_utility.set_message(800, 'HR_52342_GRD_DATE_INVL');
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.VALID_GRADE_ID');
    hr_utility.set_location(l_proc,90);
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCE_ELEMENTS_PK') Then

    hr_utility.set_message(801, 'HR_51634_CEL_PRI_KEY_ID_INVL');
    hr_utility.set_location(l_proc,95);
    hr_multi_message.add( p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.COMPETENCE_ELEMENT_ID');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End constraint_error;

--

-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_competence_element_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is

    select
	competence_element_id,
	object_version_number,
	type,
	business_group_id,
	enterprise_id,
	competence_id,
	proficiency_level_id,
	high_proficiency_level_id,
	weighting_level_id,
	rating_level_id,
	person_id,
	job_id,
	valid_grade_id,
	position_id,
	organization_id,
	parent_competence_element_id,
	activity_version_id,
	assessment_id,
	assessment_type_id,
	mandatory,
	effective_date_from,
	effective_date_to,
	group_competence_type,
	competence_type,
	normal_elapse_duration,
	normal_elapse_duration_unit,
	sequence_number,
	source_of_proficiency_level,
	line_score,
	certification_date,
	certification_method,
	next_certification_date,
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
        object_id,
        object_name,
        party_id  -- HR/TCA merge
       --
       -- BUG3356369
       --
       ,qualification_type_id
       ,unit_standard_type
       ,status
       ,information_category
       ,information1
       ,information2
       ,information3
       ,information4
       ,information5
       ,information6
       ,information7
       ,information8
       ,information9
       ,information10
       ,information11
       ,information12
       ,information13
       ,information14
       ,information15
       ,information16
       ,information17
       ,information18
       ,information19
       ,information20
       ,achieved_date
       ,appr_line_score
    from	per_competence_elements
    where	competence_element_id = p_competence_element_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_competence_element_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else

    If (
	p_competence_element_id = g_old_rec.competence_element_id and
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
  p_competence_element_id              in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	competence_element_id,
	object_version_number,
	type,
	business_group_id,
	enterprise_id,
	competence_id,
	proficiency_level_id,
	high_proficiency_level_id,
	weighting_level_id,
	rating_level_id,
	person_id,
	job_id,
	valid_grade_id,
	position_id,
	organization_id,
	parent_competence_element_id,
	activity_version_id,
	assessment_id,
	assessment_type_id,
	mandatory,
	effective_date_from,
	effective_date_to,
	group_competence_type,
	competence_type,
	normal_elapse_duration,
	normal_elapse_duration_unit,
	sequence_number,
	source_of_proficiency_level,
	line_score,
	certification_date,
	certification_method,
	next_certification_date,
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
        object_id,
        object_name,
        party_id -- HR/TCA merge
       --
       -- BUG3356369
       --
       ,qualification_type_id
       ,unit_standard_type
       ,status
       ,information_category
       ,information1
       ,information2
       ,information3
       ,information4
       ,information5
       ,information6
       ,information7
       ,information8
       ,information9
       ,information10
       ,information11
       ,information12
       ,information13
       ,information14
       ,information15
       ,information16
       ,information17
       ,information18
       ,information19
       ,information20
       ,achieved_date
       ,appr_line_score
    from	per_competence_elements
    where	competence_element_id = p_competence_element_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_competence_elements');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------

-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_competence_element_id         in number,
	p_object_version_number         in number,
	p_type                          in varchar2,
	p_business_group_id             in number,
	p_enterprise_id			in number,
	p_competence_id                 in number,
	p_proficiency_level_id          in number,
	p_high_proficiency_level_id     in number,
	p_weighting_level_id            in number,
	p_rating_level_id               in number,
	p_person_id                     in number,
	p_job_id                        in number,
	p_valid_grade_id		in number,
	p_position_id                   in number,
	p_organization_id               in number,
	p_parent_competence_element_id  in number,
	p_activity_version_id           in number,
	p_assessment_id                 in number,
	p_assessment_type_id            in number,
	p_mandatory            		in varchar2,
	p_effective_date_from           in date,
	p_effective_date_to             in date,
	p_group_competence_type         in varchar2,
	p_competence_type               in varchar2,
	p_normal_elapse_duration        in number,
	p_normal_elapse_duration_unit   in varchar2,
	p_sequence_number               in number,
	p_source_of_proficiency_level   in varchar2,
	p_line_score                    in number,
	p_certification_date            in date,
	p_certification_method          in varchar2,
	p_next_certification_date       in date,
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
        p_object_id                     in number,
     	p_object_name                   in varchar2,
	p_party_id                      in number default null -- HR/TCA merge
     -- BUG3356369
       ,p_qualification_type_id         in number
       ,p_unit_standard_type            in varchar2
       ,p_status                        in varchar2
       ,p_information_category          in varchar2
       ,p_information1                  in varchar2
       ,p_information2                  in varchar2
       ,p_information3                  in varchar2
       ,p_information4                  in varchar2
       ,p_information5                  in varchar2
       ,p_information6                  in varchar2
       ,p_information7                  in varchar2
       ,p_information8                  in varchar2
       ,p_information9                  in varchar2
       ,p_information10                 in varchar2
       ,p_information11                 in varchar2
       ,p_information12                 in varchar2
       ,p_information13                 in varchar2
       ,p_information14                 in varchar2
       ,p_information15                 in varchar2
       ,p_information16                 in varchar2
       ,p_information17                 in varchar2
       ,p_information18                 in varchar2
       ,p_information19                 in varchar2
       ,p_information20                 in varchar2
       ,p_achieved_date                 in date
       ,p_appr_line_score	        in number
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
  l_rec.competence_element_id            := p_competence_element_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.type                             := p_type;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.enterprise_id			 := p_enterprise_id;
  l_rec.competence_id                    := p_competence_id;
  l_rec.proficiency_level_id             := p_proficiency_level_id;
  l_rec.high_proficiency_level_id        := p_high_proficiency_level_id;
  l_rec.weighting_level_id               := p_weighting_level_id;
  l_rec.rating_level_id                  := p_rating_level_id;
  l_rec.person_id                        := p_person_id;
  l_rec.job_id                           := p_job_id;
  l_rec.valid_grade_id			 := p_valid_grade_id;
  l_rec.position_id                      := p_position_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.parent_competence_element_id     := p_parent_competence_element_id;
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.assessment_id                    := p_assessment_id;
  l_rec.assessment_type_id               := p_assessment_type_id;
  l_rec.mandatory               	 := p_mandatory;
  l_rec.effective_date_from              := p_effective_date_from;
  l_rec.effective_date_to                := p_effective_date_to;
  l_rec.group_competence_type            := p_group_competence_type;
  l_rec.competence_type                  := p_competence_type;
  l_rec.normal_elapse_duration           := p_normal_elapse_duration;
  l_rec.normal_elapse_duration_unit      := p_normal_elapse_duration_unit;
  l_rec.sequence_number                  := p_sequence_number;
  l_rec.source_of_proficiency_level      := p_source_of_proficiency_level;
  l_rec.line_score                       := p_line_score;
  l_rec.certification_date               := p_certification_date;
  l_rec.certification_method             := p_certification_method;
  l_rec.next_certification_date          := p_next_certification_date;
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
  l_rec.object_id                        := p_object_id;
  l_rec.object_name                      := p_object_name;
  l_rec.party_id                         := p_party_id; -- HR/TCA merge
 -- BUG3356369
  l_rec.qualification_type_id            := p_qualification_type_id;
  l_rec.unit_standard_type               := p_unit_standard_type;
  l_rec.status                           := p_status;
  l_rec.information_category             := p_information_category;
  l_rec.information1	    	         := p_information1;
  l_rec.information2	  	         := p_information2;
  l_rec.information3	 	         := p_information3;
  l_rec.information4	 	         := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6	        	 := p_information6;
  l_rec.information7	        	 := p_information7;
  l_rec.information8	        	 := p_information8;
  l_rec.information9	        	 := p_information9;
  l_rec.information10	        	 := p_information10;
  l_rec.information11	        	 := p_information11;
  l_rec.information12	        	 := p_information12;
  l_rec.information13	       	         := p_information13;
  l_rec.information14	  	         := p_information14;
  l_rec.information15	 	         := p_information15;
  l_rec.information16	  	         := p_information16;
  l_rec.information17	  	         := p_information17;
  l_rec.information18	 	         := p_information18;
  l_rec.information19	 	         := p_information19;
  l_rec.information20	   	         := p_information20;
  l_rec.achieved_date	   	         := p_achieved_date;
  l_rec.appr_line_score	   	         := p_appr_line_score;

  -- ngundura added object_id and object_name
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_cel_shd;

/
