--------------------------------------------------------
--  DDL for Package Body PAY_BTH_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTH_SHD" as
/* $Header: pybthrhi.pkb 120.2 2005/06/12 16:19:52 susivasu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_bth_shd.';  -- Global package name
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
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_BATCH_HEADERS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCH_ACTION_IF_EXISTS_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'ACTION_IF_EXISTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCH_BATCH_STATUS_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'BATCH_STATUS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCH_DATE_EFFECTIVE_CHA_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'DATE_EFFECTIVE_CHANGES');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCH_PURGE_AFTER_TRANSF_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'PURGE_AFTER_TRANSFER');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCH_REJECT_IF_FUTURE_C_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'REJECT_IF_FUTURE_CHANGES');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCH_REJECT_IF_RESULTS_E_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'REJECT_IF_RESULTS_EXISTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCH_PURGE_AFTER_R_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME', 'PURGE_AFTER_ROLLBACK');
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
  (p_batch_id                             in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       batch_id
      ,business_group_id
      ,batch_name
      ,batch_status
      ,action_if_exists
      ,batch_reference
      ,batch_source
      ,batch_type
      ,comments
      ,date_effective_changes
      ,purge_after_transfer
      ,reject_if_future_changes
      ,reject_if_results_exists
      ,purge_after_rollback
      ,REJECT_ENTRY_NOT_REMOVED
      ,ROLLBACK_ENTRY_UPDATES
      ,object_version_number
    from	pay_batch_headers
    where	batch_id = p_batch_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_batch_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_batch_id
        = pay_bth_shd.g_old_rec.batch_id and
        p_object_version_number
        = pay_bth_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_bth_shd.g_old_rec;
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
          <> pay_bth_shd.g_old_rec.object_version_number) Then
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
  (p_batch_id                             in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       batch_id
      ,business_group_id
      ,batch_name
      ,batch_status
      ,action_if_exists
      ,batch_reference
      ,batch_source
      ,batch_type
      ,comments
      ,date_effective_changes
      ,purge_after_transfer
      ,reject_if_future_changes
      ,reject_if_results_exists
      ,purge_after_rollback
      ,REJECT_ENTRY_NOT_REMOVED
      ,ROLLBACK_ENTRY_UPDATES
      ,object_version_number
    from	pay_batch_headers
    where	batch_id = p_batch_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'BATCH_ID'
    ,p_argument_value     => p_batch_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_bth_shd.g_old_rec;
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
      <> pay_bth_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_batch_headers');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_batch_id                       in number
  ,p_business_group_id              in number
  ,p_batch_name                     in varchar2
  ,p_batch_status                   in varchar2
  ,p_action_if_exists               in varchar2
  ,p_batch_reference                in varchar2
  ,p_batch_source                   in varchar2
  ,p_batch_type                     in varchar2
  ,p_comments                       in varchar2
  ,p_date_effective_changes         in varchar2
  ,p_purge_after_transfer           in varchar2
  ,p_reject_if_future_changes       in varchar2
  ,p_reject_if_results_exists       in varchar2
  ,p_purge_after_rollback           in varchar2
  ,p_REJECT_ENTRY_NOT_REMOVED       in varchar2
  ,p_ROLLBACK_ENTRY_UPDATES         in varchar2
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
  l_rec.batch_id                         := p_batch_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.batch_name                       := p_batch_name;
  l_rec.batch_status                     := p_batch_status;
  l_rec.action_if_exists                 := p_action_if_exists;
  l_rec.batch_reference                  := p_batch_reference;
  l_rec.batch_source                     := p_batch_source;
  l_rec.batch_type                       := p_batch_type;
  l_rec.comments                         := p_comments;
  l_rec.date_effective_changes           := p_date_effective_changes;
  l_rec.purge_after_transfer             := p_purge_after_transfer;
  l_rec.reject_if_future_changes         := p_reject_if_future_changes;
  l_rec.reject_if_results_exists         := p_reject_if_results_exists;
  l_rec.purge_after_rollback             := p_purge_after_rollback;
  l_rec.REJECT_ENTRY_NOT_REMOVED         := p_REJECT_ENTRY_NOT_REMOVED;
  l_rec.ROLLBACK_ENTRY_UPDATES           := p_ROLLBACK_ENTRY_UPDATES;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_bth_shd;

/
