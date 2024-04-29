--------------------------------------------------------
--  DDL for Package Body HR_PFT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PFT_SHD" as
/* $Header: hrpftrhi.pkb 120.0 2005/05/31 02:07:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_pft_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_ALL_POSITIONS_F_TL_PK') Then
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
  (p_position_id                          in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       position_id
      ,language
      ,source_lang
      ,name
    from  hr_all_positions_f_tl
    where position_id = p_position_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_position_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_position_id
        = hr_pft_shd.g_old_rec.position_id and
        p_language
        = hr_pft_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hr_pft_shd.g_old_rec;
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
  (p_position_id                          in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       position_id
      ,language
      ,source_lang
      ,name
    from        hr_all_positions_f_tl
    where       position_id = p_position_id
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
    ,p_argument           => 'POSITION_ID'
    ,p_argument_value     => p_position_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_pft_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hr_all_positions_f_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE add_language IS
  --
  -- Return new tl position records for new languages
  --
  cursor c_new_positions_tl is
  select psf.position_id
       , psd.id_flex_num
       , psd.position_definition_id
       , pft.created_by
       , pft.creation_date
       , pft.last_updated_by
       , pft.last_update_date
       , pft.last_update_login
       , l.language_code
       , pft.source_lang
       , l.nls_language
       , pft.name
    from per_position_definitions psd
       , hr_all_positions_f_tl    pft
       , hr_all_positions_f       psf
       , fnd_languages            l
   where psf.effective_end_date     =  hr_api.g_eot
     and psd.position_definition_id =  psf.position_definition_id
     and psf.position_id            =  pft.position_id
     and pft.language               =  userenv('LANG')
     and l.installed_flag           in ('I', 'B')
     and not exists (select null
                       from hr_all_positions_f_tl pft2
                      where pft2.position_id = pft.position_id
                        and pft2.language = l.language_code)
   order by l.language_code;
   --
   l_userenv_language_code   VARCHAR2(4) := userenv('LANG'); --Bug #2958520
   --
   l_current_nls_language    VARCHAR2(30);
   --
   l_proc        varchar2(72) := g_package||'add_language';
   --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  delete from HR_ALL_POSITIONS_F_TL T
  where not exists
    (select NULL
    from HR_ALL_POSITIONS_F B
    where B.POSITION_ID = T.POSITION_ID
    );
  --
  --
  For l_position_tl IN c_new_positions_tl loop
    --
    -- Only set session nls language if changed.
    --
    If l_current_nls_language = l_position_tl.nls_language then

      null; -- Have not changed so do nothing.

    Else

      hr_kflex_utility.set_session_nls_language( l_position_tl.nls_language );
      l_current_nls_language := l_position_tl.nls_language;

    End if;
    --
    insert into hr_all_positions_f_tl (
            position_id
          , name
          , created_by
          , creation_date
          , last_updated_by
          , last_update_date
          , last_update_login
          , language
          , source_lang)
    values (l_position_tl.position_id
          , nvl(fnd_flex_ext.get_segs( g_app_code
                                     , g_flex_code
                                     , l_position_tl.id_flex_num
                                     , l_position_tl.position_definition_id
                                     )
               , l_position_tl.name
               )
          , l_position_tl.created_by
          , l_position_tl.creation_date
          , l_position_tl.last_updated_by
          , l_position_tl.last_update_date
          , l_position_tl.last_update_login
          , l_position_tl.language_code
          , l_position_tl.source_lang);
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
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_position_id                    in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_name                           in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.position_id                      := p_position_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.name                             := p_name;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_pft_shd;

/
