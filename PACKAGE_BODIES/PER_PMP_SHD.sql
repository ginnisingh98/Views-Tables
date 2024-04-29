--------------------------------------------------------
--  DDL for Package Body PER_PMP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PMP_SHD" as
/* $Header: pepmprhi.pkb 120.8.12010000.4 2010/01/27 15:51:33 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pmp_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_PERF_MGMT_PLANS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_plan_id                              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       plan_id
      ,object_version_number
      ,plan_name
      ,administrator_person_id
      ,previous_plan_id
      ,start_date
      ,end_date
      ,status_code
      ,hierarchy_type_code
      ,supervisor_id
      ,supervisor_assignment_id
      ,organization_structure_id
      ,org_structure_version_id
      ,top_organization_id
      ,position_structure_id
      ,pos_structure_version_id
      ,top_position_id
      ,hierarchy_levels
      ,automatic_enrollment_flag
      ,assignment_types_code
      ,primary_asg_only_flag
      ,include_obj_setting_flag
      ,obj_setting_start_date
      ,obj_setting_deadline
      ,obj_set_outside_period_flag
      ,method_code
      ,notify_population_flag
      ,automatic_allocation_flag
      ,copy_past_objectives_flag
      ,sharing_alignment_task_flag
      ,include_appraisals_flag
      ,change_sc_status_flag
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
     ,update_library_objectives    -- 8740021 bug fix
     ,automatic_approval_flag
    from        per_perf_mgmt_plans
    where       plan_id = p_plan_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_plan_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_plan_id
        = per_pmp_shd.g_old_rec.plan_id and
        p_object_version_number
        = per_pmp_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into per_pmp_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> per_pmp_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_plan_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       plan_id
      ,object_version_number
      ,plan_name
      ,administrator_person_id
      ,previous_plan_id
      ,start_date
      ,end_date
      ,status_code
      ,hierarchy_type_code
      ,supervisor_id
      ,supervisor_assignment_id
      ,organization_structure_id
      ,org_structure_version_id
      ,top_organization_id
      ,position_structure_id
      ,pos_structure_version_id
      ,top_position_id
      ,hierarchy_levels
      ,automatic_enrollment_flag
      ,assignment_types_code
      ,primary_asg_only_flag
      ,include_obj_setting_flag
      ,obj_setting_start_date
      ,obj_setting_deadline
      ,obj_set_outside_period_flag
      ,method_code
      ,notify_population_flag
      ,automatic_allocation_flag
      ,copy_past_objectives_flag
      ,sharing_alignment_task_flag
      ,include_appraisals_flag
      ,change_sc_status_flag
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,update_library_objectives    -- 8740021 bug fix
      ,automatic_approval_flag
    from        per_perf_mgmt_plans
    where       plan_id = p_plan_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PLAN_ID'
    ,p_argument_value     => p_plan_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_pmp_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> per_pmp_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'per_perf_mgmt_plans');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_plan_id                        in number
  ,p_object_version_number          in number
  ,p_plan_name                      in varchar2
  ,p_administrator_person_id        in number
  ,p_previous_plan_id               in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_status_code                    in varchar2
  ,p_hierarchy_type_code            in varchar2
  ,p_supervisor_id                  in number
  ,p_supervisor_assignment_id       in number
  ,p_organization_structure_id      in number
  ,p_org_structure_version_id       in number
  ,p_top_organization_id            in number
  ,p_position_structure_id          in number
  ,p_pos_structure_version_id       in number
  ,p_top_position_id                in number
  ,p_hierarchy_levels               in number
  ,p_automatic_enrollment_flag      in varchar2
  ,p_assignment_types_code          in varchar2
  ,p_primary_asg_only_flag          in varchar2
  ,p_include_obj_setting_flag       in varchar2
  ,p_obj_setting_start_date         in date
  ,p_obj_setting_deadline           in date
  ,p_obj_set_outside_period_flag    in varchar2
  ,p_method_code                    in varchar2
  ,p_notify_population_flag         in varchar2
  ,p_automatic_allocation_flag      in varchar2
  ,p_copy_past_objectives_flag      in varchar2
  ,p_sharing_alignment_task_flag    in varchar2
  ,p_include_appraisals_flag        in varchar2
  ,p_change_sc_status_flag   in varchar2
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  ,p_update_library_objectives in varchar2   -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.plan_id                          := p_plan_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.plan_name                        := p_plan_name;
  l_rec.administrator_person_id          := p_administrator_person_id;
  l_rec.previous_plan_id                 := p_previous_plan_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.status_code                      := p_status_code;
  l_rec.hierarchy_type_code              := p_hierarchy_type_code;
  l_rec.supervisor_id                    := p_supervisor_id;
  l_rec.supervisor_assignment_id         := p_supervisor_assignment_id;
  l_rec.organization_structure_id        := p_organization_structure_id;
  l_rec.org_structure_version_id         := p_org_structure_version_id;
  l_rec.top_organization_id              := p_top_organization_id;
  l_rec.position_structure_id            := p_position_structure_id;
  l_rec.pos_structure_version_id         := p_pos_structure_version_id;
  l_rec.top_position_id                  := p_top_position_id;
  l_rec.hierarchy_levels                 := p_hierarchy_levels;
  l_rec.automatic_enrollment_flag        := p_automatic_enrollment_flag;
  l_rec.assignment_types_code            := p_assignment_types_code;
  l_rec.primary_asg_only_flag            := p_primary_asg_only_flag;
  l_rec.include_obj_setting_flag         := p_include_obj_setting_flag;
  l_rec.obj_setting_start_date           := p_obj_setting_start_date;
  l_rec.obj_setting_deadline             := p_obj_setting_deadline;
  l_rec.obj_set_outside_period_flag      := p_obj_set_outside_period_flag;
  l_rec.method_code                      := p_method_code;
  l_rec.notify_population_flag           := p_notify_population_flag;
  l_rec.automatic_allocation_flag        := p_automatic_allocation_flag;
  l_rec.copy_past_objectives_flag        := p_copy_past_objectives_flag;
  l_rec.sharing_alignment_task_flag      := p_sharing_alignment_task_flag;
  l_rec.include_appraisals_flag          := p_include_appraisals_flag;
  l_rec.change_sc_status_flag     := p_change_sc_status_flag;
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
  l_rec.update_library_objectives        := p_update_library_objectives;
  l_rec.automatic_approval_flag        := p_automatic_approval_flag;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_pmp_shd;

/
