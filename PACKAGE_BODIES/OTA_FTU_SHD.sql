--------------------------------------------------------
--  DDL for Package Body OTA_FTU_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FTU_SHD" as
/* $Header: otfturhi.pkb 120.1 2005/09/21 02:31 aabalakr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_ftu_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_PVT_FRM_THREAD_USERS_PK1') Then
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
  (p_forum_thread_id                      in     number
  ,p_forum_id                             in     number
  ,p_person_id                            in     number
  ,p_contact_id                           in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       forum_thread_id
      ,forum_id
      ,business_group_id
      ,author_person_id
      ,author_contact_id
      ,person_id
      ,contact_id
      ,object_version_number
    from        ota_pvt_frm_thread_users
    where forum_thread_id = p_forum_thread_id
    and  forum_id = p_forum_id
    and   person_id = p_person_id
    and   contact_id = p_contact_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_forum_thread_id is null and
      p_forum_id is null and
      p_person_id is null and
      p_contact_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_forum_thread_id
        = ota_ftu_shd.g_old_rec.forum_thread_id and
        p_forum_id
        = ota_ftu_shd.g_old_rec.forum_id and
        p_person_id
        = ota_ftu_shd.g_old_rec.person_id and
        p_contact_id
        = ota_ftu_shd.g_old_rec.contact_id and
        p_object_version_number
        = ota_ftu_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ota_ftu_shd.g_old_rec;
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
          <> ota_ftu_shd.g_old_rec.object_version_number) Then
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
  (p_forum_thread_id                      in     number
  ,p_forum_id                             in     number
  ,p_person_id                            in     number
  ,p_contact_id                           in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       forum_thread_id
      ,forum_id
      ,business_group_id
      ,author_person_id
      ,author_contact_id
      ,person_id
      ,contact_id
      ,object_version_number
    from        ota_pvt_frm_thread_users
    where forum_thread_id = p_forum_thread_id
    and forum_id = p_forum_id
    and  (person_id is null or person_id = p_person_id)
    and  (contact_id is null or contact_id = p_contact_id)
        for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'FORUM_THREAD_ID'
    ,p_argument_value     => p_forum_thread_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'FORUM_ID'
    ,p_argument_value     => p_forum_id
    );
  hr_utility.set_location(l_proc,7);
-- hr_api.mandatory_arg_error
--    (p_api_name           => l_proc
--    ,p_argument           => 'PERSON_ID'
--    ,p_argument_value     => p_person_id
--    );
  hr_utility.set_location(l_proc,8);
--  hr_api.mandatory_arg_error
--    (p_api_name           => l_proc
--    ,p_argument           => 'CONTACT_ID'
--    ,p_argument_value     => p_contact_id
--    );
  hr_utility.set_location(l_proc,9);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_ftu_shd.g_old_rec;
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
      <> ota_ftu_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ota_pvt_frm_thread_users');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_forum_thread_id                in number
  ,p_forum_id                       in number
  ,p_business_group_id              in number
  ,p_author_person_id               in number
  ,p_author_contact_id              in number
  ,p_person_id                      in number
  ,p_contact_id                     in number
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
  l_rec.forum_thread_id                  := p_forum_thread_id;
  l_rec.forum_id                         := p_forum_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.author_person_id                 := p_author_person_id;
  l_rec.author_contact_id                := p_author_contact_id;
  l_rec.person_id                        := p_person_id;
  l_rec.contact_id                       := p_contact_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_ftu_shd;

/
