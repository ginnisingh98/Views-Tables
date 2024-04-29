--------------------------------------------------------
--  DDL for Package Body PQH_BRE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BRE_SHD" as
/* $Header: pqbrerhi.pkb 115.6 2003/06/04 08:19:51 ggnanagu noship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_bre_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_BDGT_POOL_REALLOCTIONS_FK1') Then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','5');
      fnd_message.raise_error;
  ELSIf (p_constraint_name = 'PQH_BDGT_POOL_REALLOCTIONS_PK') Then
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
  (p_reallocation_id                      in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       reallocation_id
      ,position_id
      ,pool_id
      ,reallocation_amt
      ,reserved_amt
      ,object_version_number
      ,txn_detail_id
      ,transaction_type
      ,budget_detail_id
      ,budget_period_id
      ,entity_id
      ,start_date
      ,end_date
    from        pqh_bdgt_pool_realloctions
    where       reallocation_id = p_reallocation_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_reallocation_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_reallocation_id
        = pqh_bre_shd.g_old_rec.reallocation_id and
        p_object_version_number
        = pqh_bre_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_bre_shd.g_old_rec;
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
          <> pqh_bre_shd.g_old_rec.object_version_number) Then
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
  (p_reallocation_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       reallocation_id
      ,position_id
      ,pool_id
      ,reallocation_amt
      ,reserved_amt
      ,object_version_number
      ,txn_detail_id
      ,transaction_type
      ,budget_detail_id
      ,budget_period_id
      ,entity_id
      ,start_date
      ,end_date
    from        pqh_bdgt_pool_realloctions
    where       reallocation_id = p_reallocation_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'REALLOCATION_ID'
    ,p_argument_value     => p_reallocation_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_bre_shd.g_old_rec;
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
      <> pqh_bre_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_bdgt_pool_realloctions');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_reallocation_id                in number
  ,p_position_id                    in number
  ,p_pool_id                        in number
  ,p_reallocation_amt               in number
  ,p_reserved_amt                   in number
  ,p_object_version_number          in number
  ,p_txn_detail_id                 in number
  ,p_transaction_type               in varchar2
  ,p_budget_detail_id               in number
  ,p_budget_period_id               in number
  ,p_entity_id                      in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.reallocation_id                  := p_reallocation_id;
  l_rec.position_id                      := p_position_id;
  l_rec.pool_id                          := p_pool_id;
  l_rec.reallocation_amt                 := p_reallocation_amt;
  l_rec.reserved_amt                     := p_reserved_amt;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.txn_detail_id                   := p_txn_detail_id;
  l_rec.transaction_type                 := p_transaction_type;
  l_rec.budget_detail_id                 := p_budget_detail_id;
  l_rec.budget_period_id                 := p_budget_period_id;
  l_rec.entity_id                        := p_entity_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_bre_shd;

/
