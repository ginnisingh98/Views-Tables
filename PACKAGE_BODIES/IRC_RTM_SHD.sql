--------------------------------------------------------
--  DDL for Package Body IRC_RTM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RTM_SHD" as
/* $Header: irrtmrhi.pkb 120.3 2008/01/22 10:17:45 mkjayara noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_rtm_shd.';  -- Global package name
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
  If (p_constraint_name = 'IRC_REC_TEAM_MEMBERS_FK1') Then
    hr_utility.set_message('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'IRC_REC_TEAM_MEMBERS_FK2') Then
    hr_utility.set_message('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'IRC_REC_TEAM_MEMBERS_PK') Then
    hr_utility.set_message('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  Else
    hr_utility.set_message('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_rec_team_member_id                   in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       rec_team_member_id
      ,person_id
      ,party_id
      ,vacancy_id
      ,job_id
      ,start_date
      ,end_date
      ,update_allowed
      ,delete_allowed
      ,object_version_number
      ,interview_security
    from        irc_rec_team_members
    where       rec_team_member_id = p_rec_team_member_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_rec_team_member_id
        = irc_rtm_shd.g_old_rec.rec_team_member_id and
        p_object_version_number
        = irc_rtm_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into irc_rtm_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PER', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> irc_rtm_shd.g_old_rec.object_version_number) Then
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
  (p_rec_team_member_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       rec_team_member_id
      ,person_id
      ,party_id
      ,vacancy_id
      ,job_id
      ,start_date
      ,end_date
      ,update_allowed
      ,delete_allowed
      ,object_version_number
      ,interview_security
    from        irc_rec_team_members
    where       rec_team_member_id = p_rec_team_member_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'REC_TEAM_MEMBER_ID'
    ,p_argument_value     => p_rec_team_member_id
    );
  hr_utility.set_location('Rec team member id ok at ' || l_proc,7);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  hr_utility.set_location('OVN ok at ' || l_proc,9);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into irc_rtm_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_location('Invalid key at :'||l_proc, 11);
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> irc_rtm_shd.g_old_rec.object_version_number) Then
        hr_utility.set_location('Invalid OVN at :'||l_proc, 14);
        hr_utility.set_location(to_char(p_object_version_number) ||
          'vs' || to_char(irc_rtm_shd.g_old_rec.object_version_number) ||
          ' '||l_proc, 16);
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  -- We need to trap the ORA LOCK exception
  --
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_location('Object locked :'||l_proc, 21);
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'irc_rec_team_members');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_rec_team_member_id             in number
  ,p_person_id                      in number
  ,p_party_id                       in number
  ,p_vacancy_id                     in number
  ,p_job_id                         in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_update_allowed                 in varchar2
  ,p_delete_allowed                 in varchar2
  ,p_object_version_number          in number
  ,p_interview_security              in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.rec_team_member_id               := p_rec_team_member_id;
  l_rec.person_id                        := p_person_id;
  l_rec.party_id                         := p_party_id;
  l_rec.vacancy_id                       := p_vacancy_id;
  l_rec.job_id                           := p_job_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.update_allowed                   := p_update_allowed;
  l_rec.delete_allowed                   := p_delete_allowed;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.interview_security               := p_interview_security;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end irc_rtm_shd;

/
