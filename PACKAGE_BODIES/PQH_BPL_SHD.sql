--------------------------------------------------------
--  DDL for Package Body PQH_BPL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BPL_SHD" as
/* $Header: pqbplrhi.pkb 115.9 2003/04/11 11:44:23 mvankada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_bpl_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
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
  If (p_constraint_name = 'PQH_BUDGET_POOLS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGET_POOLS_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGET_POOLS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGET_POOLS_U1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
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
  (p_pool_id                              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       pool_id
      ,name
      ,budget_version_id
      ,budget_unit_id
      ,object_version_number
      ,entity_type
      ,parent_pool_id
      ,business_group_id
      ,approval_status
      ,wf_transaction_category_id
    from        pqh_budget_pools
    where       pool_id = p_pool_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_pool_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pool_id
        = pqh_bpl_shd.g_old_rec.pool_id and
        p_object_version_number
        = pqh_bpl_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_bpl_shd.g_old_rec;
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
          <> pqh_bpl_shd.g_old_rec.object_version_number) Then
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
  (p_pool_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       pool_id
      ,name
      ,budget_version_id
      ,budget_unit_id
      ,object_version_number
      ,entity_type
      ,parent_pool_id
      ,business_group_id
      ,approval_status
      ,wf_transaction_category_id
    from        pqh_budget_pools
    where       pool_id = p_pool_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'POOL_ID'
    ,p_argument_value     => p_pool_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_bpl_shd.g_old_rec;
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
      <> pqh_bpl_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_budget_pools');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_pool_id                        in number
  ,p_name                           in varchar2
  ,p_budget_version_id              in number
  ,p_budget_unit_id                 in number
  ,p_object_version_number          in number
  ,p_entity_type                    in varchar2
  ,p_parent_pool_id               in number
  ,p_business_group_id              in number
  ,p_approval_status                in varchar2
  ,p_wf_transaction_category_id     in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.pool_id                          := p_pool_id;
  l_rec.name                             := p_name;
  l_rec.budget_version_id                := p_budget_version_id;
  l_rec.budget_unit_id                   := p_budget_unit_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.entity_type                      := p_entity_type;
  l_rec.parent_pool_id                 := p_parent_pool_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.approval_status                  := p_approval_status;
  l_rec.wf_transaction_category_id       :=p_wf_transaction_category_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_bpl_shd;

/
