--------------------------------------------------------
--  DDL for Package Body IRC_IPD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPD_SHD" as
/* $Header: iripdrhi.pkb 120.0 2005/07/26 15:09:42 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipd_shd.';  -- Global package name
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
  If (p_constraint_name = 'IRC_PENDING_DATA_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'IRC_PENDING_DATA_UK') Then
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
  (p_pending_data_id                      in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       pending_data_id
      ,email_address
      ,vacancy_id
      ,last_name
      ,first_name
      ,user_password
      ,resume_file_name
      ,resume_description
      ,resume_mime_type
      ,source_type
      ,job_post_source_name
      ,posting_content_id
      ,person_id
      ,processed
      ,sex
      ,date_of_birth
      ,per_information_category
      ,per_information1
      ,per_information2
      ,per_information3
      ,per_information4
      ,per_information5
      ,per_information6
      ,per_information7
      ,per_information8
      ,per_information9
      ,per_information10
      ,per_information11
      ,per_information12
      ,per_information13
      ,per_information14
      ,per_information15
      ,per_information16
      ,per_information17
      ,per_information18
      ,per_information19
      ,per_information20
      ,per_information21
      ,per_information22
      ,per_information23
      ,per_information24
      ,per_information25
      ,per_information26
      ,per_information27
      ,per_information28
      ,per_information29
      ,per_information30
      ,error_message
      ,creation_date
      ,last_update_date
      ,allow_access
      ,user_guid
      ,visitor_resp_key
      ,visitor_resp_appl_id
      ,security_group_key
    from        irc_pending_data
    where       pending_data_id = p_pending_data_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_pending_data_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pending_data_id
        = irc_ipd_shd.g_old_rec.pending_data_id
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
      Fetch C_Sel1 Into irc_ipd_shd.g_old_rec;
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
  (p_pending_data_id                      in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       pending_data_id
      ,email_address
      ,vacancy_id
      ,last_name
      ,first_name
      ,user_password
      ,resume_file_name
      ,resume_description
      ,resume_mime_type
      ,source_type
      ,job_post_source_name
      ,posting_content_id
      ,person_id
      ,processed
      ,sex
      ,date_of_birth
      ,per_information_category
      ,per_information1
      ,per_information2
      ,per_information3
      ,per_information4
      ,per_information5
      ,per_information6
      ,per_information7
      ,per_information8
      ,per_information9
      ,per_information10
      ,per_information11
      ,per_information12
      ,per_information13
      ,per_information14
      ,per_information15
      ,per_information16
      ,per_information17
      ,per_information18
      ,per_information19
      ,per_information20
      ,per_information21
      ,per_information22
      ,per_information23
      ,per_information24
      ,per_information25
      ,per_information26
      ,per_information27
      ,per_information28
      ,per_information29
      ,per_information30
      ,error_message
      ,creation_date
      ,last_update_date
      ,allow_access
      ,user_guid
      ,visitor_resp_key
      ,visitor_resp_appl_id
      ,security_group_key
    from        irc_pending_data
    where       pending_data_id = p_pending_data_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PENDING_DATA_ID'
    ,p_argument_value     => p_pending_data_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into irc_ipd_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'irc_pending_data');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_pending_data_id                in number
  ,p_email_address                  in varchar2
  ,p_vacancy_id                     in number
  ,p_last_name                      in varchar2
  ,p_first_name                     in varchar2
  ,p_user_password                  in varchar2
  ,p_resume_file_name               in varchar2
  ,p_resume_description             in varchar2
  ,p_resume_mime_type               in varchar2
  ,p_source_type                    in varchar2
  ,p_job_post_source_name           in varchar2
  ,p_posting_content_id             in number
  ,p_person_id                      in number
  ,p_processed                      in varchar2
  ,p_sex                            in varchar2
  ,p_date_of_birth                  in date
  ,p_per_information_category       in varchar2
  ,p_per_information1               in varchar2
  ,p_per_information2               in varchar2
  ,p_per_information3               in varchar2
  ,p_per_information4               in varchar2
  ,p_per_information5               in varchar2
  ,p_per_information6               in varchar2
  ,p_per_information7               in varchar2
  ,p_per_information8               in varchar2
  ,p_per_information9               in varchar2
  ,p_per_information10              in varchar2
  ,p_per_information11              in varchar2
  ,p_per_information12              in varchar2
  ,p_per_information13              in varchar2
  ,p_per_information14              in varchar2
  ,p_per_information15              in varchar2
  ,p_per_information16              in varchar2
  ,p_per_information17              in varchar2
  ,p_per_information18              in varchar2
  ,p_per_information19              in varchar2
  ,p_per_information20              in varchar2
  ,p_per_information21              in varchar2
  ,p_per_information22              in varchar2
  ,p_per_information23              in varchar2
  ,p_per_information24              in varchar2
  ,p_per_information25              in varchar2
  ,p_per_information26              in varchar2
  ,p_per_information27              in varchar2
  ,p_per_information28              in varchar2
  ,p_per_information29              in varchar2
  ,p_per_information30              in varchar2
  ,p_error_message                  in varchar2
  ,p_creation_date                  in date
  ,p_last_update_date               in date
  ,p_allow_access                   in varchar2
  ,p_user_guid                      in raw
  ,p_visitor_resp_key               in varchar2
  ,p_visitor_resp_appl_id           in number
  ,p_security_group_key             in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.pending_data_id                  := p_pending_data_id;
  l_rec.email_address                    := p_email_address;
  l_rec.vacancy_id                       := p_vacancy_id;
  l_rec.last_name                        := p_last_name;
  l_rec.first_name                       := p_first_name;
  l_rec.user_password                    := p_user_password;
  l_rec.resume_file_name                 := p_resume_file_name;
  l_rec.resume_description               := p_resume_description;
  l_rec.resume_mime_type                 := p_resume_mime_type;
  l_rec.source_type                      := p_source_type;
  l_rec.job_post_source_name             := p_job_post_source_name;
  l_rec.posting_content_id               := p_posting_content_id;
  l_rec.person_id                        := p_person_id;
  l_rec.processed                        := p_processed;
  l_rec.sex                              := p_sex;
  l_rec.date_of_birth                    := p_date_of_birth;
  l_rec.per_information_category         := p_per_information_category;
  l_rec.per_information1                 := p_per_information1;
  l_rec.per_information2                 := p_per_information2;
  l_rec.per_information3                 := p_per_information3;
  l_rec.per_information4                 := p_per_information4;
  l_rec.per_information5                 := p_per_information5;
  l_rec.per_information6                 := p_per_information6;
  l_rec.per_information7                 := p_per_information7;
  l_rec.per_information8                 := p_per_information8;
  l_rec.per_information9                 := p_per_information9;
  l_rec.per_information10                := p_per_information10;
  l_rec.per_information11                := p_per_information11;
  l_rec.per_information12                := p_per_information12;
  l_rec.per_information13                := p_per_information13;
  l_rec.per_information14                := p_per_information14;
  l_rec.per_information15                := p_per_information15;
  l_rec.per_information16                := p_per_information16;
  l_rec.per_information17                := p_per_information17;
  l_rec.per_information18                := p_per_information18;
  l_rec.per_information19                := p_per_information19;
  l_rec.per_information20                := p_per_information20;
  l_rec.per_information21                := p_per_information21;
  l_rec.per_information22                := p_per_information22;
  l_rec.per_information23                := p_per_information23;
  l_rec.per_information24                := p_per_information24;
  l_rec.per_information25                := p_per_information25;
  l_rec.per_information26                := p_per_information26;
  l_rec.per_information27                := p_per_information27;
  l_rec.per_information28                := p_per_information28;
  l_rec.per_information29                := p_per_information29;
  l_rec.per_information30                := p_per_information30;
  l_rec.error_message                    := p_error_message;
  l_rec.creation_date                    := p_creation_date;
  l_rec.last_update_date                 := p_last_update_date;
  l_rec.allow_access                     := p_allow_access;
  l_rec.user_guid                        := p_user_guid;
  l_rec.visitor_resp_key                 := p_visitor_resp_key;
  l_rec.visitor_resp_appl_id             := p_visitor_resp_appl_id;
  l_rec.security_group_key               := p_security_group_key;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end irc_ipd_shd;

/
