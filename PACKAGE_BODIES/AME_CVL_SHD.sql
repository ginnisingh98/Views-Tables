--------------------------------------------------------
--  DDL for Package Body AME_CVL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CVL_SHD" as
/* $Header: amcvlrhi.pkb 120.1 2006/01/03 02:46 tkolla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_cvl_shd.';  -- Global package name
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
  If (p_constraint_name = 'AME_CONFIG_VARS_TL_PK') Then
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
  (p_variable_name                        in     varchar2
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       variable_name
      ,language
      ,source_lang
      ,user_config_var_name
      ,description
    from  ame_config_vars_tl
    where variable_name = p_variable_name
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_variable_name is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_variable_name
        = ame_cvl_shd.g_old_rec.variable_name and
        p_language
        = ame_cvl_shd.g_old_rec.language
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
      Fetch C_Sel1 Into ame_cvl_shd.g_old_rec;
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
  (p_variable_name                        in     varchar2
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       variable_name
      ,language
      ,source_lang
      ,user_config_var_name
      ,description
    from        ame_config_vars_tl
    where       variable_name = p_variable_name
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
    ,p_argument           => 'VARIABLE_NAME'
    ,p_argument_value     => p_variable_name
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ame_cvl_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'ame_config_vars_tl');
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
procedure ADD_LANGUAGE
is
begin
  delete from AME_CONFIG_VARS_TL T
  where not exists
    (select NULL
    from AME_CONFIG_VARS B
    where B.VARIABLE_NAME = T.VARIABLE_NAME
    );

  update AME_CONFIG_VARS_TL T set (
      USER_CONFIG_VAR_NAME,
      DESCRIPTION
    ) = (select
      B.USER_CONFIG_VAR_NAME,
      B.DESCRIPTION
    from AME_CONFIG_VARS_TL B
    where B.VARIABLE_NAME = T.VARIABLE_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VARIABLE_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.VARIABLE_NAME,
      SUBT.LANGUAGE
    from AME_CONFIG_VARS_TL SUBB, AME_CONFIG_VARS_TL SUBT
    where SUBB.VARIABLE_NAME = SUBT.VARIABLE_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_CONFIG_VAR_NAME <> SUBT.USER_CONFIG_VAR_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into AME_CONFIG_VARS_TL (
    VARIABLE_NAME,
    USER_CONFIG_VAR_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.VARIABLE_NAME,
    B.USER_CONFIG_VAR_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AME_CONFIG_VARS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AME_CONFIG_VARS_TL T
    where T.VARIABLE_NAME = B.VARIABLE_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_variable_name                  in varchar2
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_user_config_var_name           in varchar2
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
  l_rec.variable_name                    := p_variable_name;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.user_config_var_name             := p_user_config_var_name;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ame_cvl_shd;

/
