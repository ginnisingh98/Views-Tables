--------------------------------------------------------
--  DDL for Package Body IRC_CMP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMP_SHD" as
/* $Header: ircmprhi.pkb 120.0 2007/11/19 11:38:55 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmp_shd.';  -- Global package name
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
  If (p_constraint_name = 'IRC_COMM_PROPERTIES_PK') Then
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
  (p_communication_property_id            in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       communication_property_id
      ,object_type
      ,object_id
      ,default_comm_status
      ,allow_attachment_flag
      ,auto_notification_flag
      ,allow_add_recipients
      ,default_moderator
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,object_version_number
    from        irc_comm_properties
    where       communication_property_id = p_communication_property_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_communication_property_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_communication_property_id
        = irc_cmp_shd.g_old_rec.communication_property_id and
        p_object_version_number
        = irc_cmp_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into irc_cmp_shd.g_old_rec;
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
          <> irc_cmp_shd.g_old_rec.object_version_number) Then
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
  (p_communication_property_id            in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       communication_property_id
      ,object_type
      ,object_id
      ,default_comm_status
      ,allow_attachment_flag
      ,auto_notification_flag
      ,allow_add_recipients
      ,default_moderator
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,object_version_number
    from        irc_comm_properties
    where       communication_property_id = p_communication_property_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COMMUNICATION_PROPERTY_ID'
    ,p_argument_value     => p_communication_property_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into irc_cmp_shd.g_old_rec;
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
      <> irc_cmp_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'irc_comm_properties');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_communication_property_id      in number
  ,p_object_type                    in varchar2
  ,p_object_id                      in number
  ,p_default_comm_status            in varchar2
  ,p_allow_attachment_flag          in varchar2
  ,p_auto_notification_flag         in varchar2
  ,p_allow_add_recipients           in varchar2
  ,p_default_moderator              in varchar2
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_information_category           in varchar2
  ,p_information1                   in varchar2
  ,p_information2                   in varchar2
  ,p_information3                   in varchar2
  ,p_information4                   in varchar2
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in varchar2
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
  l_rec.communication_property_id        := p_communication_property_id;
  l_rec.object_type                      := p_object_type;
  l_rec.object_id                        := p_object_id;
  l_rec.default_comm_status              := p_default_comm_status;
  l_rec.allow_attachment_flag            := p_allow_attachment_flag;
  l_rec.auto_notification_flag           := p_auto_notification_flag;
  l_rec.allow_add_recipients             := p_allow_add_recipients;
  l_rec.default_moderator                := p_default_moderator;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.information_category             := p_information_category;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end irc_cmp_shd;

/
