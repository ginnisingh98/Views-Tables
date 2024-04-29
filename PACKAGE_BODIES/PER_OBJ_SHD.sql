--------------------------------------------------------
--  DDL for Package Body PER_OBJ_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OBJ_SHD" as
/* $Header: peobjrhi.pkb 120.16.12010000.4 2008/11/05 05:52:10 rvagvala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_obj_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_OBJECTIVES_FK1') Then
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_OBJECTIVES_FK2') Then
    hr_utility.set_message(801,'HR_52054_OBJ_APR_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_OBJECTIVES_PK') Then
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_objective_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	objective_id,
	name,
	target_date,
	start_date,
	business_group_id,
	object_version_number,
	owning_person_id,
	achievement_date,
	detail,
	comments,
	success_criteria,
	appraisal_id,
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
	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute25,
	attribute26,
	attribute27,
	attribute28,
	attribute29,
	attribute30,

        scorecard_id,
        copied_from_library_id,
        copied_from_objective_id,
        aligned_with_objective_id,

        next_review_date,
        group_code,
        priority_code,
        appraise_flag,
        verified_flag,

        target_value,
        actual_value,
        weighting_percent,
        complete_percent,
        uom_code,

        measurement_style_code,
        measure_name,
        measure_type_code,
        measure_comments ,
        sharing_access_code

    from	per_objectives
    where	objective_id = p_objective_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_objective_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_objective_id = g_old_rec.objective_id and
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
      else
        Close C_Sel1;
      End If;
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
  p_objective_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
        objective_id,
	name,
	target_date,
	start_date,
	business_group_id,
	object_version_number,
	owning_person_id,
	achievement_date,
	detail,
	comments,
	success_criteria,
	appraisal_id,
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

	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute25,
	attribute26,
	attribute27,
	attribute28,
	attribute29,
	attribute30,

        scorecard_id,
        copied_from_library_id,
        copied_from_objective_id,
        aligned_with_objective_id,

        next_review_date,
        group_code,
        priority_code,
        appraise_flag,
        verified_flag,

        target_value,
        actual_value,
        weighting_percent,
        complete_percent,
        uom_code,

        measurement_style_code,
        measure_name,
        measure_type_code,
        measure_comments ,
        sharing_access_code

    from	per_objectives
    where	objective_id = p_objective_id
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
  else
    Close C_Sel1;
  End If;

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
    hr_utility.set_message_token('TABLE_NAME', 'per_objectives');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_objective_id                  in number,
	p_name                          in varchar2,
	p_target_date                   in date,
	p_start_date                    in date,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_owning_person_id              in number,
	p_achievement_date              in date,
	p_detail                        in varchar2,
	p_comments                      in varchar2,
	p_success_criteria              in varchar2,
	p_appraisal_id                  in number,
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

        p_attribute21                   in varchar2,
        p_attribute22                   in varchar2,
        p_attribute23                   in varchar2,
        p_attribute24                   in varchar2,
        p_attribute25                   in varchar2,
        p_attribute26                   in varchar2,
        p_attribute27                   in varchar2,
        p_attribute28                   in varchar2,
        p_attribute29                   in varchar2,
        p_attribute30                   in varchar2,

        p_scorecard_id                  in  number,
        p_copied_from_library_id        in  number,
        p_copied_from_objective_id      in number,
        p_aligned_with_objective_id     in number,

        p_next_review_date              in date,
        p_group_code                    in varchar2,
        p_priority_code                 in varchar2,
        p_appraise_flag                 in varchar2,
        p_verified_flag                 in varchar2,

        p_target_value                  in number,
        p_actual_value                  in number,
        p_weighting_percent             in number,
        p_complete_percent              in number,
        p_uom_code                      in varchar2,

        p_measurement_style_code        in varchar2,
        p_measure_name                  in varchar2,
        p_measure_type_code             in varchar2,
        p_measure_comments              in varchar2,
        p_sharing_access_code           in varchar2

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
  l_rec.objective_id                     := p_objective_id;
  l_rec.name                             := p_name;
  l_rec.target_date                      := p_target_date;
  l_rec.start_date                       := p_start_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.owning_person_id                 := p_owning_person_id;
  l_rec.achievement_date                 := p_achievement_date;
  l_rec.detail                           := p_detail;
  l_rec.comments                         := p_comments;
  l_rec.success_criteria                 := p_success_criteria;
  l_rec.appraisal_id                     := p_appraisal_id;
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

  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;

  l_rec.scorecard_id                     := p_scorecard_id;
  l_rec.copied_from_library_id           := p_copied_from_library_id;
  l_rec.copied_from_objective_id         := p_copied_from_objective_id;
  l_rec.aligned_with_objective_id        := p_aligned_with_objective_id;

  l_rec.next_review_date                 := p_next_review_date;
  l_rec.group_code                       := p_group_code;
  l_rec.priority_code                    := p_priority_code;
  l_rec.appraise_flag                    := p_appraise_flag;
  l_rec.verified_flag                    := p_verified_flag;

  l_rec.target_value                     := p_target_value;
  l_rec.actual_value                     := p_actual_value;
  l_rec.weighting_percent                := p_weighting_percent;
  l_rec.complete_percent                 := p_complete_percent;
  l_rec.uom_code                         := p_uom_code;

  l_rec.measurement_style_code           := p_measurement_style_code;
  l_rec.measure_name                     := p_measure_name;
  l_rec.measure_type_code                := p_measure_type_code;
  l_rec.measure_comments                 := p_measure_comments;
  l_rec.sharing_access_code              := p_sharing_access_code;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_obj_shd;

/
