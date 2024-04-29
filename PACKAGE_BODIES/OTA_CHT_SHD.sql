--------------------------------------------------------
--  DDL for Package Body OTA_CHT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CHT_SHD" as
/* $Header: otchtrhi.pkb 120.1 2005/12/08 11:27 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_cht_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_CHATS_TL_TEMP_PK') Then
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
  (p_chat_id                              in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       chat_id
      ,name
      ,description
      ,language
      ,source_lang
    from  ota_chats_tl
    where chat_id = p_chat_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_chat_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_chat_id
        = ota_cht_shd.g_old_rec.chat_id and
        p_language
        = ota_cht_shd.g_old_rec.language
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
      Fetch C_Sel1 Into ota_cht_shd.g_old_rec;
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
  (p_chat_id                              in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       chat_id
      ,name
      ,description
      ,language
      ,source_lang
    from        ota_chats_tl
    where       chat_id = p_chat_id
    and   language = p_language
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CHAT_ID'
    ,p_argument_value     => p_chat_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_cht_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'ota_chats_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
-- EDIT_HERE:  Execute AOL's tltblgen(UNIX) program to generate the
--             ADD_LANGUAGE procedure.  Only the add_language procedure
--             should be added here.  Remove the following skeleton
--             procedure.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS
Begin
  --
  delete from OTA_CHATS_TL T
  where not exists
    (select NULL
    from OTA_CHATS_B B
    where B.CHAT_ID = T.CHAT_ID
    );

  update OTA_CHATS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from OTA_CHATS_TL B
    where B.CHAT_ID = T.CHAT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHAT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHAT_ID,
      SUBT.LANGUAGE
    from OTA_CHATS_TL SUBB, OTA_CHATS_TL SUBT
    where SUBB.CHAT_ID = SUBT.CHAT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into OTA_CHATS_TL (
    CHAT_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CHAT_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OTA_CHATS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OTA_CHATS_TL T
    where T.CHAT_ID = B.CHAT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_chat_id                        in number
  ,p_name                           in varchar2
  ,p_description                    in varchar2
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.chat_id                          := p_chat_id;
  l_rec.name                             := p_name;
  l_rec.description                      := p_description;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_cht_shd;

/
