--------------------------------------------------------
--  DDL for Package Body IRC_CMM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMM_SHD" as
/* $Header: ircmmrhi.pkb 120.2 2008/04/14 14:50:29 amikukum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmm_shd.';  -- Global package name
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
  If (p_constraint_name = 'IRC_COMM_MESSAGES_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'IRC_COMM_MESSAGES_PK') Then
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
  (p_communication_message_id             in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       communication_message_id
      ,parent_id
      ,communication_topic_id
      ,message_subject
      ,message_body
      ,message_post_date
      ,sender_type
      ,sender_id
      ,document_type
      ,document_id
      ,deleted_flag
      ,object_version_number
    from        irc_comm_messages
    where       communication_message_id = p_communication_message_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_communication_message_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_communication_message_id
        = irc_cmm_shd.g_old_rec.communication_message_id and
        p_object_version_number
        = irc_cmm_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into irc_cmm_shd.g_old_rec;
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
          <> irc_cmm_shd.g_old_rec.object_version_number) Then
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
  (p_communication_message_id             in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       communication_message_id
      ,parent_id
      ,communication_topic_id
      ,message_subject
      ,message_body
      ,message_post_date
      ,sender_type
      ,sender_id
      ,document_type
      ,document_id
      ,deleted_flag
      ,object_version_number
    from        irc_comm_messages
    where       communication_message_id = p_communication_message_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COMMUNICATION_MESSAGE_ID'
    ,p_argument_value     => p_communication_message_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into irc_cmm_shd.g_old_rec;
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
      <> irc_cmm_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'irc_comm_messages');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_communication_message_id       in number
  ,p_parent_id                      in number
  ,p_communication_topic_id         in number
  ,p_message_subject                in varchar2
  ,p_message_body                   in varchar2
  ,p_message_post_date              in date
  ,p_sender_type                    in varchar2
  ,p_sender_id                      in number
  ,p_document_type                  in varchar2
  ,p_document_id                    in number
  ,p_deleted_flag                   in varchar2
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
  l_rec.communication_message_id         := p_communication_message_id;
  l_rec.parent_id                        := p_parent_id;
  l_rec.communication_topic_id           := p_communication_topic_id;
  l_rec.message_subject                  := p_message_subject;
  l_rec.message_body                     := p_message_body;
  l_rec.message_post_date                := p_message_post_date;
  l_rec.sender_type                      := p_sender_type;
  l_rec.sender_id                        := p_sender_id;
  l_rec.document_type                    := p_document_type;
  l_rec.document_id                      := p_document_id;
  l_rec.deleted_flag                     := p_deleted_flag;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end irc_cmm_shd;

/
