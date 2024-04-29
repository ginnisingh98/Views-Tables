--------------------------------------------------------
--  DDL for Package Body PER_APT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APT_SHD" as
/* $Header: peaptrhi.pkb 120.4.12010000.7 2010/02/09 15:06:58 psugumar ship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_apt_shd.';  -- Global package name
-- ---------------------------------------------------------------------------+
-- |---------------------------< constraint_error >---------------------------|
-- ---------------------------------------------------------------------------+
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is

  l_proc 	varchar2(72) := g_package||'constraint_error';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_FK1') Then
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_FK2') Then
    hr_utility.set_message(801, 'HR_51912_APT_AST_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_FK3') Then
    hr_utility.set_message(801, 'HR_51928_APT_RSC_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_FK4') Then
    hr_utility.set_message(801, 'HR_51915_APT_QST_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_FK5') Then
    fnd_message.set_name(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_FK6') Then
    fnd_message.set_name(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISAL_TEMPLATES_UK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
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
  p_appraisal_template_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is


  -- Cursor selects the 'current' row from the HR Schema

  Cursor C_Sel1 is
    select
		appraisal_template_id,
	business_group_id,
	object_version_number,
	name,
	description,
	instructions,
	date_from,
	date_to,
	assessment_type_id,
	rating_scale_id,
	questionnaire_template_id,
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
	objective_asmnt_type_id,
    ma_quest_template_id,
    link_appr_to_learning_path,
    final_score_formula_id,
    update_personal_comp_profile,
    comp_profile_source_type,
    show_competency_ratings,
    show_objective_ratings,
    show_overall_ratings,
    show_overall_comments,
    provide_overall_feedback,
    show_participant_details,
    allow_add_participant,
    show_additional_details,
    show_participant_names,
    show_participant_ratings,
    available_flag,
	  show_questionnaire_info,
    ma_off_template_code,
	  appraisee_off_template_code,
	  other_part_off_template_code,
	  part_rev_off_template_code,
	  part_app_off_template_code,
                           show_participant_comments -- 8651478 bug fix
,show_term_employee
,show_term_contigent
,disp_term_emp_period_from
,show_future_term_employee

    from	per_appraisal_templates
    where	appraisal_template_id = p_appraisal_template_id;

  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If (
	p_appraisal_template_id is null and
	p_object_version_number is null
     ) Then

    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false

    l_fct_ret := false;
  Else
    If (
	p_appraisal_template_id = g_old_rec.appraisal_template_id and
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
  p_appraisal_template_id              in number,
  p_object_version_number              in number
  ) is

-- Cursor selects the 'current' row from the HR Schema

  Cursor C_Sel1 is
    select 	appraisal_template_id,
	business_group_id,
	object_version_number,
	name,
	description,
	instructions,
	date_from,
	date_to,
	assessment_type_id,
	rating_scale_id,
	questionnaire_template_id,
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
	objective_asmnt_type_id,
    ma_quest_template_id,
    link_appr_to_learning_path,
    final_score_formula_id,
    update_personal_comp_profile,
    comp_profile_source_type,
    show_competency_ratings,
    show_objective_ratings,
    show_overall_ratings,
    show_overall_comments,
    provide_overall_feedback,
    show_participant_details,
    allow_add_participant,
    show_additional_details,
    show_participant_names,
    show_participant_ratings,
    available_flag,
	  show_questionnaire_info,
    ma_off_template_code,
	  appraisee_off_template_code,
	  other_part_off_template_code,
	  part_rev_off_template_code,
	  part_app_off_template_code,
                            show_participant_comments -- 8651478 bug fix
,show_term_employee
,show_term_contigent
,disp_term_emp_period_from
,show_future_term_employee

    from	per_appraisal_templates
    where	appraisal_template_id = p_appraisal_template_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_appraisal_templates');
    hr_utility.raise_error;
End lck;

-- ---------------------------------------------------------------------------+
-- |-----------------------------< convert_args >-----------------------------|
-- ---------------------------------------------------------------------------+
Function convert_args
	(
p_appraisal_template_id         in number,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_name                          in varchar2,
	p_description                   in varchar2,
	p_instructions                  in varchar2,
	p_date_from                     in date,
	p_date_to                       in date,
	p_assessment_type_id            in number,
	p_rating_scale_id               in number,
	p_questionnaire_template_id     in number,
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
	p_attribute20                   in varchar2
   ,p_objective_asmnt_type_id        in number
   ,p_ma_quest_template_id           in number
  ,p_link_appr_to_learning_path     in varchar2
  ,p_final_score_formula_id         in number
  ,p_update_personal_comp_profile   in varchar2
  ,p_comp_profile_source_type       in varchar2
  ,p_show_competency_ratings        in varchar2
  ,p_show_objective_ratings         in varchar2
  ,p_show_overall_ratings           in varchar2
  ,p_show_overall_comments          in varchar2
  ,p_provide_overall_feedback       in varchar2
  ,p_show_participant_details       in varchar2
  ,p_allow_add_participant          in varchar2
  ,p_show_additional_details        in varchar2
  ,p_show_participant_names         in varchar2
  ,p_show_participant_ratings       in varchar2
  ,p_available_flag                 in varchar2
  ,p_show_questionnaire_info        in varchar2
  ,p_ma_off_template_code			      in varchar2
  ,p_apraisee_off_template_code	 	  in varchar2
  ,p_other_part_off_template_code  	in varchar2
  ,p_part_app_off_template_code	  	in varchar2
  ,p_part_rev_off_template_code 	  in varchar2
,p_show_participant_comments     in varchar2    -- 8651478 bug fix
  ,p_show_term_employee            in varchar2   -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2    -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number     -- 6181267 bug fix
  ,p_show_future_term_employee          in varchar2    -- 6181267 bug fix

	)
	Return g_rec_type is

  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Convert arguments into local l_rec structure.

  l_rec.appraisal_template_id            := p_appraisal_template_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.name                             := p_name;
  l_rec.description                      := p_description;
  l_rec.instructions                     := p_instructions;
  l_rec.date_from                        := p_date_from;
  l_rec.date_to                          := p_date_to;
  l_rec.assessment_type_id               := p_assessment_type_id;
  l_rec.rating_scale_id                  := p_rating_scale_id;
  l_rec.questionnaire_template_id        := p_questionnaire_template_id;
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
  l_rec.objective_asmnt_type_id          := p_objective_asmnt_type_id;
  l_rec.ma_quest_template_id             := p_ma_quest_template_id;
  l_rec.link_appr_to_learning_path       := p_link_appr_to_learning_path;
  l_rec.final_score_formula_id           := p_final_score_formula_id;
  l_rec.update_personal_comp_profile     := p_update_personal_comp_profile;
  l_rec.comp_profile_source_type         := p_comp_profile_source_type;
  l_rec.show_competency_ratings          := p_show_competency_ratings;
  l_rec.show_objective_ratings           := p_show_objective_ratings;
  l_rec.show_overall_ratings             := p_show_overall_ratings;
  l_rec.show_overall_comments            := p_show_overall_comments;
  l_rec.provide_overall_feedback         := p_provide_overall_feedback;
  l_rec.show_participant_details         := p_show_participant_details;
  l_rec.allow_add_participant            := p_allow_add_participant;
  l_rec.show_additional_details          := p_show_additional_details;
  l_rec.show_participant_names           := p_show_participant_names;
  l_rec.show_participant_ratings         := p_show_participant_ratings;
  l_rec.available_flag                   := p_available_flag;
  l_rec.show_questionnaire_info          := p_show_questionnaire_info;
  l_rec.ma_off_template_code			       := p_ma_off_template_code;
  l_rec.appraisee_off_template_code		   := p_apraisee_off_template_code;
  l_rec.other_part_off_template_code	   := p_other_part_off_template_code;
  l_rec.part_app_off_template_code		   := p_part_app_off_template_code;
  l_rec.part_rev_off_template_code		   :=	p_part_rev_off_template_code;
  l_rec.show_participant_comments         := p_show_participant_comments;   -- 8651478 bug fix

  l_rec.show_term_employee           := p_show_term_employee;  -- 6181267 bug fix
  l_rec.show_term_contigent          := p_show_term_contigent;   -- 6181267 bug fix
  l_rec.disp_term_emp_period_from    := p_disp_term_emp_period_from;   -- 6181267 bug fix
  l_rec.show_future_term_employee    := p_show_future_term_employee; -- 6181267 bug fix

  -- Return the plsql record structure.

  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);

End convert_args;

end per_apt_shd;

/
