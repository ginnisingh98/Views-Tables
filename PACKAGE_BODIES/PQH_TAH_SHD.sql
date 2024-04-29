--------------------------------------------------------
--  DDL for Package Body PQH_TAH_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TAH_SHD" as
/* $Header: pqtahrhi.pkb 120.2 2005/12/21 11:27:52 hpandya noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_tah_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_SS_APPROVAL_HISTORY_PK') Then
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
  (p_approval_history_id                  in     number
  ,p_transaction_history_id               in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       approval_history_id
      ,transaction_history_id
      ,transaction_effective_date
      ,action
      ,user_name
      ,transaction_item_type
      ,transaction_item_key
      ,effective_date_option
      ,orig_system
      ,orig_system_id
      ,notification_id
      ,user_comment
    from        pqh_ss_approval_history
    where
        approval_history_id = p_approval_history_id
    and transaction_history_id = p_transaction_history_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_approval_history_id is null and
      p_transaction_history_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_approval_history_id
        = pqh_tah_shd.g_old_rec.approval_history_id and
        p_transaction_history_id
        = pqh_tah_shd.g_old_rec.transaction_history_id
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
      Fetch C_Sel1 Into pqh_tah_shd.g_old_rec;
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
  (p_approval_history_id                  in     number
  ,p_transaction_history_id               in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       approval_history_id
      ,transaction_history_id
      ,transaction_effective_date
      ,action
      ,user_name
      ,transaction_item_type
      ,transaction_item_key
      ,effective_date_option
      ,orig_system
      ,orig_system_id
      ,notification_id
      ,user_comment
    from        pqh_ss_approval_history
    where
    approval_history_id = p_approval_history_id
    and   transaction_history_id = p_transaction_history_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'APPROVAL_HISTORY_ID'
    ,p_argument_value     => p_approval_history_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TRANSACTION_HISTORY_ID'
    ,p_argument_value     => p_transaction_history_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_tah_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'pqh_ss_approval_history');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_approval_history_id            in number
  ,p_transaction_history_id         in number
  ,p_transaction_effective_date     in date
  ,p_action                         in varchar2
  ,p_user_name                      in varchar2
  ,p_transaction_item_type          in varchar2
  ,p_transaction_item_key           in varchar2
  ,p_effective_date_option          in varchar2
  ,p_orig_system                    in varchar2
  ,p_orig_system_id                 in number
  ,p_notification_id                in number
  ,p_user_comment                   in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.approval_history_id              := p_approval_history_id;
  l_rec.transaction_history_id           := p_transaction_history_id;
  l_rec.transaction_effective_date       := p_transaction_effective_date;
  l_rec.action                           := p_action;
  l_rec.user_name                        := p_user_name;
  l_rec.transaction_item_type            := p_transaction_item_type;
  l_rec.transaction_item_key             := p_transaction_item_key;
  l_rec.effective_date_option            := p_effective_date_option;
  l_rec.orig_system                      := p_orig_system;
  l_rec.orig_system_id                   := p_orig_system_id;
  l_rec.notification_id                  := p_notification_id;
  l_rec.user_comment                     := p_user_comment;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_tah_shd;

/
