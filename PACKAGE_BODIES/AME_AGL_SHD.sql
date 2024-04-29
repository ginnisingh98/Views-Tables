--------------------------------------------------------
--  DDL for Package Body AME_AGL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_AGL_SHD" as
/* $Header: amaglrhi.pkb 120.0 2005/09/02 03:49 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_agl_shd.';  -- Global package name
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
  If (p_constraint_name = 'AME_APPROVAL_GROUPS_TL_PK') Then
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
  (p_approval_group_id                    in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       approval_group_id
      ,language
      ,source_lang
      ,user_approval_group_name
      ,description
    from  ame_approval_groups_tl
    where approval_group_id = p_approval_group_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_approval_group_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_approval_group_id
        = ame_agl_shd.g_old_rec.approval_group_id and
        p_language
        = ame_agl_shd.g_old_rec.language
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
      Fetch C_Sel1 Into ame_agl_shd.g_old_rec;
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
  (p_approval_group_id                    in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       approval_group_id
      ,language
      ,source_lang
      ,user_approval_group_name
      ,description
    from        ame_approval_groups_tl
    where       approval_group_id = p_approval_group_id
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
    ,p_argument           => 'APPROVAL_GROUP_ID'
    ,p_argument_value     => p_approval_group_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ame_agl_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'ame_approval_groups_tl');
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
--NOTE:This procedure was generated using:
--  setenv FND_TOP /fnddev/fnd/11.5
--  /fnddev/fnd/11.5/bin/AFTBLGEN
--
-- ----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from AME_APPROVAL_GROUPS_TL T
  where not exists
    (select NULL
    from AME_APPROVAL_GROUPS B
    where B.APPROVAL_GROUP_ID = T.APPROVAL_GROUP_ID
    );

  update AME_APPROVAL_GROUPS_TL T set (
      USER_APPROVAL_GROUP_NAME,
      DESCRIPTION
    ) = (select
      B.USER_APPROVAL_GROUP_NAME,
      B.DESCRIPTION
    from AME_APPROVAL_GROUPS_TL B
    where B.APPROVAL_GROUP_ID = T.APPROVAL_GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPROVAL_GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPROVAL_GROUP_ID,
      SUBT.LANGUAGE
    from AME_APPROVAL_GROUPS_TL SUBB, AME_APPROVAL_GROUPS_TL SUBT
    where SUBB.APPROVAL_GROUP_ID = SUBT.APPROVAL_GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_APPROVAL_GROUP_NAME <> SUBT.USER_APPROVAL_GROUP_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into AME_APPROVAL_GROUPS_TL (
    APPROVAL_GROUP_ID,
    USER_APPROVAL_GROUP_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPROVAL_GROUP_ID,
    B.USER_APPROVAL_GROUP_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AME_APPROVAL_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AME_APPROVAL_GROUPS_TL T
    where T.APPROVAL_GROUP_ID = B.APPROVAL_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_approval_group_id              in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_user_approval_group_name       in varchar2
  ,p_description                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.approval_group_id                := p_approval_group_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.user_approval_group_name         := p_user_approval_group_name;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ame_agl_shd;

/
