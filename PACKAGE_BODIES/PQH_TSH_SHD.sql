--------------------------------------------------------
--  DDL for Package Body PQH_TSH_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TSH_SHD" as
/* $Header: pqtshrhi.pkb 120.2 2005/12/21 11:28:58 hpandya noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_tsh_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_SS_TRANS_STATE_HISTORY_PK') Then
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
  (p_transaction_history_id               in     number
  ,p_approval_history_id                  in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       transaction_history_id
      ,approval_history_id
      ,creator_person_id
      ,creator_role
      ,status
      ,transaction_state
      ,effective_date
      ,effective_date_option
      ,last_update_role
      ,parent_transaction_id
      ,relaunch_function
      ,transaction_document
    from        pqh_ss_trans_state_history
    where       transaction_history_id = p_transaction_history_id
    and   approval_history_id = p_approval_history_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_transaction_history_id is null and
      p_approval_history_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_transaction_history_id
        = pqh_tsh_shd.g_old_rec.transaction_history_id and
        p_approval_history_id
        = pqh_tsh_shd.g_old_rec.approval_history_id
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
      Fetch C_Sel1 Into pqh_tsh_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      --
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
  (p_transaction_history_id               in     number
  ,p_approval_history_id                  in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       transaction_history_id
      ,approval_history_id
      ,creator_person_id
      ,creator_role
      ,status
      ,transaction_state
      ,effective_date
      ,effective_date_option
      ,last_update_role
      ,parent_transaction_id
      ,relaunch_function
      ,transaction_document
    from        pqh_ss_trans_state_history
    where       transaction_history_id = p_transaction_history_id
    and   approval_history_id = p_approval_history_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TRANSACTION_HISTORY_ID'
    ,p_argument_value     => p_transaction_history_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'approval_history_id'
    ,p_argument_value     => p_approval_history_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_tsh_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
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
    fnd_message.set_token('TABLE_NAME', 'pqh_ss_trans_state_history');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_transaction_history_id         in number
  ,p_approval_history_id            in number
  ,p_creator_person_id              in number
  ,p_creator_role                   in varchar2
  ,p_status                         in varchar2
  ,p_transaction_state              in varchar2
  ,p_effective_date                 in date
  ,p_effective_date_option          in varchar2
  ,p_last_update_role               in varchar2
  ,p_parent_transaction_id          in number
  ,p_relaunch_function              in varchar2
  ,p_transaction_document           in CLOB
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.transaction_history_id           := p_transaction_history_id;
  l_rec.approval_history_id              := p_approval_history_id;
  l_rec.creator_person_id                := p_creator_person_id;
  l_rec.creator_role                     := p_creator_role;
  l_rec.status                           := p_status;
  l_rec.transaction_state                := p_transaction_state;
  l_rec.effective_date                   := p_effective_date;
  l_rec.effective_date_option            := p_effective_date_option;
  l_rec.last_update_role                 := p_last_update_role;
  l_rec.parent_transaction_id            := p_parent_transaction_id;
  l_rec.relaunch_function                := p_relaunch_function;
  l_rec.transaction_document             := p_transaction_document;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_tsh_shd;

/
