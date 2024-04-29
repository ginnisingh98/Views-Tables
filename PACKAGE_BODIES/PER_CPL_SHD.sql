--------------------------------------------------------
--  DDL for Package Body PER_CPL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPL_SHD" as
/* $Header: pecplrhi.pkb 120.0.12000000.2 2007/05/30 12:19:15 arumukhe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cpl_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_COMPETENCES_TL_PK') Then
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
  (p_competence_id                        in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       competence_id
      ,language
      ,source_lang
      ,name
      ,competence_alias
      ,behavioural_indicator
      ,description
    from  per_competences_tl
    where competence_id = p_competence_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_competence_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_competence_id
        = per_cpl_shd.g_old_rec.competence_id and
        p_language
        = per_cpl_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_cpl_shd.g_old_rec;
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
  (p_competence_id                        in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       competence_id
      ,language
      ,source_lang
      ,name
      ,competence_alias
      ,behavioural_indicator
      ,description
    from        per_competences_tl
    where       competence_id = p_competence_id
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
    ,p_argument           => 'COMPETENCE_ID'
    ,p_argument_value     => p_competence_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_cpl_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_competences_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
procedure ADD_LANGUAGE
is
 --
  -- Return new tl competence records for new languages
  --
  cursor c_new_competences_tl is
  select cpl.competence_id
       , cd.id_flex_num
       , cd.competence_definition_id
       , cpl.created_by
       , cpl.creation_date
       , cpl.last_updated_by
       , cpl.last_update_date
       , cpl.last_update_login
       , l.language_code
       , cpl.source_lang
       , l.nls_language
       , cpl.behavioural_indicator
       , cpl.description
       , cpl.competence_alias
       , cpl.name
    --
    from per_competences            cpn
       , per_competence_definitions cd
       , per_competences_tl         cpl
       , fnd_languages         l
   where cpn.competence_definition_id =  cd.competence_definition_id
     and cpn.competence_id            =  cpl.competence_id
     and cpl.language                 =  userenv('LANG')
     and l.installed_flag        in ('I', 'B')
     and not exists (select null
                       from per_competences_tl t
                      where t.competence_id = cpl.competence_id
                        and t.language = l.language_code)
   order by l.language_code;
   --
   l_userenv_language_code   VARCHAR2(4) := userenv('LANG'); --Bug 2962837.
   --
   l_current_nls_language    VARCHAR2(30);
   --
   l_proc        varchar2(72) := g_package||'add_language';
   --
begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  delete from PER_COMPETENCES_TL T
  where not exists
    (select NULL
    from PER_COMPETENCES B
    where B.COMPETENCE_ID = T.COMPETENCE_ID
    );


   For l_competences_tl IN c_new_competences_tl loop
    --
    -- Only set session nls language if changed.
    --
    If l_current_nls_language = l_competences_tl.nls_language then

      null; -- Have not changed so do nothing.

    Else

      hr_kflex_utility.set_session_nls_language( l_competences_tl.nls_language );
      l_current_nls_language := l_competences_tl.nls_language;

    End if;
    --

  insert into PER_COMPETENCES_TL (
    COMPETENCE_ID,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    BEHAVIOURAL_INDICATOR,
    DESCRIPTION,
    COMPETENCE_ALIAS
  ) values
    (l_competences_tl.competence_id
          , nvl(fnd_flex_ext.get_segs( g_app_code
                                     , g_flex_code
                                     , l_competences_tl.id_flex_num
                                     , l_competences_tl.competence_definition_id
                                     )
              , l_competences_tl.name
              )
          , l_competences_tl.created_by
          , l_competences_tl.creation_date
          , l_competences_tl.last_updated_by
          , l_competences_tl.last_update_date
          , l_competences_tl.last_update_login
          , l_competences_tl.language_code
          , l_competences_tl.source_lang
          , l_competences_tl.behavioural_indicator
          , l_competences_tl.description
          , l_competences_tl.competence_alias);
    --

 --
  End loop;
  --
  hr_kflex_utility.set_session_language_code( l_userenv_language_code );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --

 Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;
end ADD_LANGUAGE;
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_competence_id                  in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_name                           in varchar2
  ,p_competence_alias               in varchar2
  ,p_behavioural_indicator          in varchar2
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
  l_rec.competence_id                    := p_competence_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.name                             := p_name;
  l_rec.competence_alias                 := p_competence_alias;
  l_rec.behavioural_indicator            := p_behavioural_indicator;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_cpl_shd;

/
