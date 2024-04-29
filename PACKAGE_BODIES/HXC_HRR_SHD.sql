--------------------------------------------------------
--  DDL for Package Body HXC_HRR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HRR_SHD" as
/* $Header: hxchrrrhi.pkb 120.3 2005/09/23 10:43:47 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hrr_shd.';  -- Global package name
g_debug boolean		:=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'HXC_RESOURCE_RULES_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HXC_RESOURCE_RULES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  (p_resource_rule_id                     in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       resource_rule_id
      ,name
      ,business_group_id
      ,legislation_code
      ,eligibility_criteria_type
      ,eligibility_criteria_id
      ,pref_hierarchy_id
      ,rule_evaluation_order
      ,resource_type
      ,start_date
      ,end_date
      ,object_version_number
    from	hxc_resource_rules
    where	resource_rule_id = p_resource_rule_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_resource_rule_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_resource_rule_id
        = hxc_hrr_shd.g_old_rec.resource_rule_id and
        p_object_version_number
        = hxc_hrr_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hxc_hrr_shd.g_old_rec;
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
          <> hxc_hrr_shd.g_old_rec.object_version_number) Then
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
  (p_resource_rule_id                     in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       resource_rule_id
      ,name
      ,business_group_id
      ,legislation_code
      ,eligibility_criteria_type
      ,eligibility_criteria_id
      ,pref_hierarchy_id
      ,rule_evaluation_order
      ,resource_type
      ,start_date
      ,end_date
      ,object_version_number
    from	hxc_resource_rules
    where	resource_rule_id = p_resource_rule_id
    for	update nowait;
--
  l_proc	varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'lck';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RESOURCE_RULE_ID'
    ,p_argument_value     => p_resource_rule_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_hrr_shd.g_old_rec;
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
      <> hxc_hrr_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
    fnd_message.set_token('TABLE_NAME', 'hxc_resource_rules');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_resource_rule_id               in number
  ,p_name                           in varchar2
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_eligibility_criteria_type      in varchar2
  ,p_eligibility_criteria_id        in varchar2
  ,p_pref_hierarchy_id              in number
  ,p_rule_evaluation_order          in number
  ,p_resource_type                  in varchar2
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.resource_rule_id                 := p_resource_rule_id;
  l_rec.name                             := p_name;
  l_rec.business_group_id                 := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.eligibility_criteria_type        := p_eligibility_criteria_type;
  l_rec.eligibility_criteria_id          := p_eligibility_criteria_id;
  l_rec.pref_hierarchy_id                := p_pref_hierarchy_id;
  l_rec.rule_evaluation_order            := p_rule_evaluation_order;
  l_rec.resource_type                    := p_resource_type;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_hrr_shd;

/
