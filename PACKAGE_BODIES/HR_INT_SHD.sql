--------------------------------------------------------
--  DDL for Package Body HR_INT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_INT_SHD" as
/* $Header: hrintrhi.pkb 115.0 2004/01/09 01:40:47 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_int_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_KI_INTEGRATIONS_PK') Then
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
  (p_integration_id                       in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       integration_id
      ,integration_key
      ,party_type
      ,party_name
      ,party_site_name
      ,transaction_type
      ,transaction_subtype
      ,standard_code
      ,ext_trans_type
      ,ext_trans_subtype
      ,trans_direction
      ,url
      ,synched
      ,ext_application_id
      ,application_name
      ,application_type
      ,application_url
      ,logout_url
      ,user_field
      ,password_field
      ,authentication_needed
      ,field_name1
      ,field_value1
      ,field_name2
      ,field_value2
      ,field_name3
      ,field_value3
      ,field_name4
      ,field_value4
      ,field_name5
      ,field_value5
      ,field_name6
      ,field_value6
      ,field_name7
      ,field_value7
      ,field_name8
      ,field_value8
      ,field_name9
      ,field_value9
      ,object_version_number
    from        hr_ki_integrations
    where       integration_id = p_integration_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_integration_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_integration_id
        = hr_int_shd.g_old_rec.integration_id and
        p_object_version_number
        = hr_int_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_int_shd.g_old_rec;
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
          <> hr_int_shd.g_old_rec.object_version_number) Then
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
  (p_integration_id                       in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       integration_id
      ,integration_key
      ,party_type
      ,party_name
      ,party_site_name
      ,transaction_type
      ,transaction_subtype
      ,standard_code
      ,ext_trans_type
      ,ext_trans_subtype
      ,trans_direction
      ,url
      ,synched
      ,ext_application_id
      ,application_name
      ,application_type
      ,application_url
      ,logout_url
      ,user_field
      ,password_field
      ,authentication_needed
      ,field_name1
      ,field_value1
      ,field_name2
      ,field_value2
      ,field_name3
      ,field_value3
      ,field_name4
      ,field_value4
      ,field_name5
      ,field_value5
      ,field_name6
      ,field_value6
      ,field_name7
      ,field_value7
      ,field_name8
      ,field_value8
      ,field_name9
      ,field_value9
      ,object_version_number
    from        hr_ki_integrations
    where       integration_id = p_integration_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'INTEGRATION_ID'
    ,p_argument_value     => p_integration_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_int_shd.g_old_rec;
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
      <> hr_int_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_ki_integrations');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_integration_id                 in number
  ,p_integration_key                in varchar2
  ,p_party_type                     in varchar2
  ,p_party_name                     in varchar2
  ,p_party_site_name                in varchar2
  ,p_transaction_type               in varchar2
  ,p_transaction_subtype            in varchar2
  ,p_standard_code                  in varchar2
  ,p_ext_trans_type                 in varchar2
  ,p_ext_trans_subtype              in varchar2
  ,p_trans_direction                in varchar2
  ,p_url                            in varchar2
  ,p_synched                        in varchar2
  ,p_ext_application_id             in number
  ,p_application_name               in varchar2
  ,p_application_type               in varchar2
  ,p_application_url                in varchar2
  ,p_logout_url                     in varchar2
  ,p_user_field                     in varchar2
  ,p_password_field                 in varchar2
  ,p_authentication_needed          in varchar2
  ,p_field_name1                    in varchar2
  ,p_field_value1                   in varchar2
  ,p_field_name2                    in varchar2
  ,p_field_value2                   in varchar2
  ,p_field_name3                    in varchar2
  ,p_field_value3                   in varchar2
  ,p_field_name4                    in varchar2
  ,p_field_value4                   in varchar2
  ,p_field_name5                    in varchar2
  ,p_field_value5                   in varchar2
  ,p_field_name6                    in varchar2
  ,p_field_value6                   in varchar2
  ,p_field_name7                    in varchar2
  ,p_field_value7                   in varchar2
  ,p_field_name8                    in varchar2
  ,p_field_value8                   in varchar2
  ,p_field_name9                    in varchar2
  ,p_field_value9                   in varchar2
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
  l_rec.integration_id                   := p_integration_id;
  l_rec.integration_key                  := p_integration_key;
  l_rec.party_type                       := p_party_type;
  l_rec.party_name                       := p_party_name;
  l_rec.party_site_name                  := p_party_site_name;
  l_rec.transaction_type                 := p_transaction_type;
  l_rec.transaction_subtype              := p_transaction_subtype;
  l_rec.standard_code                    := p_standard_code;
  l_rec.ext_trans_type                   := p_ext_trans_type;
  l_rec.ext_trans_subtype                := p_ext_trans_subtype;
  l_rec.trans_direction                  := p_trans_direction;
  l_rec.url                              := p_url;
  l_rec.synched                          := p_synched;
  l_rec.ext_application_id               := p_ext_application_id;
  l_rec.application_name                 := p_application_name;
  l_rec.application_type                 := p_application_type;
  l_rec.application_url                  := p_application_url;
  l_rec.logout_url                       := p_logout_url;
  l_rec.user_field                       := p_user_field;
  l_rec.password_field                   := p_password_field;
  l_rec.authentication_needed            := p_authentication_needed;
  l_rec.field_name1                      := p_field_name1;
  l_rec.field_value1                     := p_field_value1;
  l_rec.field_name2                      := p_field_name2;
  l_rec.field_value2                     := p_field_value2;
  l_rec.field_name3                      := p_field_name3;
  l_rec.field_value3                     := p_field_value3;
  l_rec.field_name4                      := p_field_name4;
  l_rec.field_value4                     := p_field_value4;
  l_rec.field_name5                      := p_field_name5;
  l_rec.field_value5                     := p_field_value5;
  l_rec.field_name6                      := p_field_name6;
  l_rec.field_value6                     := p_field_value6;
  l_rec.field_name7                      := p_field_name7;
  l_rec.field_value7                     := p_field_value7;
  l_rec.field_name8                      := p_field_name8;
  l_rec.field_value8                     := p_field_value8;
  l_rec.field_name9                      := p_field_name9;
  l_rec.field_value9                     := p_field_value9;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_int_shd;

/
