--------------------------------------------------------
--  DDL for Package Body PQH_STR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STR_SHD" as
/* $Header: pqstrrhi.pkb 115.10 2004/04/06 05:49 svorugan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_str_shd.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
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
  If (p_constraint_name = 'PQH_FR_STAT_SITUATION_RULES_PK') Then
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
  (p_stat_situation_rule_id               in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       stat_situation_rule_id
      ,statutory_situation_id
      ,processing_sequence
      ,txn_category_attribute_id
      ,from_value
      ,to_value
      ,enabled_flag
      ,required_flag
      ,exclude_flag
      ,object_version_number
    from        pqh_fr_stat_situation_rules
    where       stat_situation_rule_id = p_stat_situation_rule_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_stat_situation_rule_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_stat_situation_rule_id
        = pqh_str_shd.g_old_rec.stat_situation_rule_id and
        p_object_version_number
        = pqh_str_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_str_shd.g_old_rec;
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
          <> pqh_str_shd.g_old_rec.object_version_number) Then
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
  (p_stat_situation_rule_id               in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       stat_situation_rule_id
      ,statutory_situation_id
      ,processing_sequence
      ,txn_category_attribute_id
      ,from_value
      ,to_value
      ,enabled_flag
      ,required_flag
      ,exclude_flag
      ,object_version_number
    from        pqh_fr_stat_situation_rules
    where       stat_situation_rule_id = p_stat_situation_rule_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin

  if g_debug then
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;

  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'STAT_SITUATION_RULE_ID'
    ,p_argument_value     => p_stat_situation_rule_id
    );

  if g_debug then
  --
  hr_utility.set_location(l_proc,6);
  --
  End if;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_str_shd.g_old_rec;
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
      <> pqh_str_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

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
    fnd_message.set_token('TABLE_NAME', 'pqh_fr_stat_situation_rules');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_stat_situation_rule_id         in number
  ,p_statutory_situation_id         in number
  ,p_processing_sequence            in number
  ,p_txn_category_attribute_id      in number
  ,p_from_value                     in varchar2
  ,p_to_value                       in varchar2
  ,p_enabled_flag                   in varchar2
  ,p_required_flag                  in varchar2
  ,p_exclude_flag                   in varchar2
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
  l_rec.stat_situation_rule_id           := p_stat_situation_rule_id;
  l_rec.statutory_situation_id           := p_statutory_situation_id;
  l_rec.processing_sequence              := p_processing_sequence;
  l_rec.txn_category_attribute_id        := p_txn_category_attribute_id;
  l_rec.from_value                       := p_from_value;
  l_rec.to_value                         := p_to_value;
  l_rec.enabled_flag                     := p_enabled_flag;
  l_rec.required_flag                    := p_required_flag;
  l_rec.exclude_flag                     := p_exclude_flag;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_str_shd;

/
