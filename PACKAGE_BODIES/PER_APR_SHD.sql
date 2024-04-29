--------------------------------------------------------
--  DDL for Package Body PER_APR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APR_SHD" as
/* $Header: peaprrhi.pkb 120.8.12010000.18 2010/05/25 12:18:15 psugumar ship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_apr_shd.';  -- Global package name

-- ---------------------------------------------------------------------------+
-- |---------------------------< constraint_error >---------------------------|
-- ---------------------------------------------------------------------------+
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is

  l_proc 	varchar2(72) := g_package||'constraint_error';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If (p_constraint_name = 'PER_APPRAISALS_FK1') Then
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISALS_FK2') Then
    hr_utility.set_message(801,'HR_52246_APR_TEMP_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISALS_FK3') Then
    hr_utility.set_message(801,'HR_51898_APR_NO_SUCH_LEVEL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPRAISALS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
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
  p_appraisal_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is


  -- Cursor selects the 'current' row from the HR Schema

  Cursor C_Sel1 is
    select
	appraisal_id,
	business_group_id,
	object_version_number,
	appraisal_template_id,
	appraisee_person_id,
	appraiser_person_id,
	appraisal_date,
	appraisal_period_end_date,
	appraisal_period_start_date,
	type,
	next_appraisal_date,
	status,
	group_date,
	group_initiator_id,
	comments,
	overall_performance_level_id,
	open,
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
	system_type,
	system_params,
	appraisee_access,
	main_appraiser_id,
	assignment_id,
	assignment_start_date,
	assignment_business_group_id,
	assignment_organization_id  ,
	assignment_job_id           ,
	assignment_position_id      ,
	assignment_grade_id ,
	appraisal_system_status,
	potential_readiness_level,
	potential_short_term_workopp,
	potential_long_term_workopp,
	potential_details,
	event_id,
        show_competency_ratings,
        show_objective_ratings,
        show_questionnaire_info,
        show_participant_details,
        show_participant_ratings,
        show_participant_names,
        show_overall_ratings,
        show_overall_comments,
        update_appraisal,
        provide_overall_feedback,
        appraisee_comments,
        plan_id,
        offline_status,
        retention_potential ,
        show_participant_comments -- 8651478 bug fix
    from	per_appraisals
    where	appraisal_id = p_appraisal_id;

  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If (
	p_appraisal_id is null and
	p_object_version_number is null
     ) Then

    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false

    l_fct_ret := false;
  Else
    If (
	p_appraisal_id = g_old_rec.appraisal_id and
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
  p_appraisal_id                       in number,
  p_object_version_number              in number
  ) is

-- Cursor selects the 'current' row from the HR Schema

  Cursor C_Sel1 is
  select
	appraisal_id,
	business_group_id,
	object_version_number,
	appraisal_template_id,
	appraisee_person_id,
	appraiser_person_id,
	appraisal_date,
	appraisal_period_end_date,
	appraisal_period_start_date,
	type,
	next_appraisal_date,
	status,
	group_date,
	group_initiator_id,
	comments,
	overall_performance_level_id,
	open,
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
	system_type,
	system_params,
	appraisee_access,
	main_appraiser_id,
	assignment_id,
	assignment_start_date,
	assignment_business_group_id,
	assignment_organization_id  ,
	assignment_job_id           ,
	assignment_position_id      ,
	assignment_grade_id ,
	appraisal_system_status,
	potential_readiness_level ,
	potential_short_term_workopp ,
	potential_long_term_workopp ,
	potential_details ,
        event_id,
        show_competency_ratings,
        show_objective_ratings,
        show_questionnaire_info,
        show_participant_details,
        show_participant_ratings,
        show_participant_names,
        show_overall_ratings,
        show_overall_comments,
        update_appraisal,
        provide_overall_feedback,
        appraisee_comments,
        plan_id,
        offline_status,
       retention_potential ,
 show_participant_comments -- 8651478 bug fix
    from	per_appraisals
    where	appraisal_id = p_appraisal_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_appraisals');
    hr_utility.raise_error;
End lck;

-- ---------------------------------------------------------------------------+
-- |-----------------------------< convert_args >-----------------------------|
-- ---------------------------------------------------------------------------+
Function convert_args
	(
	p_appraisal_id                  in number,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_appraisal_template_id         in number,
	p_appraisee_person_id           in number,
	p_appraiser_person_id           in number,
	p_appraisal_date                in date,
	p_appraisal_period_end_date     in date,
	p_appraisal_period_start_date   in date,
	p_type                          in varchar2,
	p_next_appraisal_date           in date,
	p_status                        in varchar2,
	p_group_date			in date,
	p_group_initiator_id		in number,
	p_comments                      in varchar2,
	p_overall_performance_level_id  in number,
	p_open                          in varchar2,
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
	p_system_type                   in varchar2,
	p_system_params                 in varchar2,
	p_appraisee_access              in varchar2,
	p_main_appraiser_id             in number,
	p_assignment_id                 in number,
	p_assignment_start_date         in date,
	p_asg_business_group_id         in number,
	p_assignment_organization_id    in number,
	p_assignment_job_id             in number,
	p_assignment_position_id        in number,
	p_assignment_grade_id           in number,
	p_appraisal_system_status       in varchar2,
	p_potential_readiness_level 	in varchar2,
	p_potential_short_term_workopp  in varchar2,
	p_potential_long_term_workopp   in varchar2,
	p_potential_details             in varchar2,
	p_event_id                      in number,
        p_show_competency_ratings      in varchar2,
        p_show_objective_ratings       in varchar2,
        p_show_questionnaire_info      in varchar2,
        p_show_participant_details     in varchar2,
        p_show_participant_ratings     in varchar2,
        p_show_participant_names       in varchar2,
        p_show_overall_ratings         in varchar2,
        p_show_overall_comments        in varchar2,
        p_update_appraisal             in varchar2,
        p_provide_overall_feedback     in varchar2,
        p_appraisee_comments           in varchar2,
        p_plan_id                      in number,
        p_offline_status               in varchar2,
       p_retention_potential     in        varchar2,
p_show_participant_comments     in varchar2   -- 8651478 bug fix
	)
	Return g_rec_type is

  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Convert arguments into local l_rec structure.

  l_rec.appraisal_id                     := p_appraisal_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.appraisal_template_id            := p_appraisal_template_id;
  l_rec.appraisee_person_id              := p_appraisee_person_id;
  l_rec.appraiser_person_id              := p_appraiser_person_id;
  l_rec.appraisal_date                   := p_appraisal_date;
  l_rec.appraisal_period_end_date        := p_appraisal_period_end_date;
  l_rec.appraisal_period_start_date      := p_appraisal_period_start_date;

  l_rec.assignment_business_group_id     := p_asg_business_group_id;
  l_rec.assignment_organization_id       := p_assignment_organization_id  ;
  l_rec.assignment_job_id                := p_assignment_job_id           ;
  l_rec.assignment_position_id           := p_assignment_position_id      ;
  l_rec.assignment_grade_id              := p_assignment_grade_id         ;

  l_rec.type                             := p_type;
  l_rec.next_appraisal_date              := p_next_appraisal_date;
  l_rec.status                           := p_status;
  l_rec.group_date			 := p_group_date;
  l_rec.group_initiator_id		 := p_group_initiator_id;
  l_rec.comments                         := p_comments;
  l_rec.overall_performance_level_id     := p_overall_performance_level_id;
  l_rec.open                             := p_open;
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
  l_rec.system_type                      := p_system_type;
  l_rec.system_params                    := p_system_params;
  l_rec.appraisee_access                 := p_appraisee_access;
  l_rec.main_appraiser_id                := p_main_appraiser_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.assignment_start_date            := p_assignment_start_date;
  l_rec.assignment_business_group_id     := p_asg_business_group_id;
  l_rec.assignment_organization_id       := p_assignment_organization_id  ;
  l_rec.assignment_job_id                := p_assignment_job_id           ;
  l_rec.assignment_position_id           := p_assignment_position_id      ;
  l_rec.assignment_grade_id              := p_assignment_grade_id ;
  l_rec.appraisal_system_status          := p_appraisal_system_status;
  l_rec.potential_readiness_level        := p_potential_readiness_level;
  l_rec.potential_short_term_workopp     := p_potential_short_term_workopp  ;
  l_rec.potential_long_term_workopp      := p_potential_long_term_workopp           ;
  l_rec.potential_details                := p_potential_details      ;
  l_rec.event_id                         := p_event_id ;
  l_rec.show_competency_ratings          := p_show_competency_ratings;
  l_rec.show_objective_ratings           := p_show_objective_ratings;
  l_rec.show_questionnaire_info          := p_show_questionnaire_info;
  l_rec.show_participant_details         := p_show_participant_details;
  l_rec.show_participant_ratings         := p_show_participant_ratings;
  l_rec.show_participant_names           := p_show_participant_names;
  l_rec.show_overall_ratings             := p_show_overall_ratings;
  l_rec.show_overall_comments            := p_show_overall_comments;
  l_rec.update_appraisal                 := p_update_appraisal;
  l_rec.provide_overall_feedback         := p_provide_overall_feedback;
  l_rec.appraisee_comments               := p_appraisee_comments;
  l_rec.plan_id                          := p_plan_id;
  l_rec.offline_status                   := p_offline_status;
l_rec.retention_potential   :=  p_retention_potential;
  l_rec.show_participant_comments         := p_show_participant_comments;   -- 8651478 bug fix

  -- Return the plsql record structure.

  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);

End convert_args;

end per_apr_shd;

/
