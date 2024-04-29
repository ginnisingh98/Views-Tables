--------------------------------------------------------
--  DDL for Package Body PER_GDT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GDT_SHD" as
/* $Header: pegdtrhi.pkb 115.3 2003/12/30 05:12:58 vanantha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_gdt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_GRADES_TL_PK') Then
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
  (p_grade_id                             in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       grade_id
      ,language
      ,source_lang
      ,name
    from  per_grades_tl
    where grade_id = p_grade_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_grade_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_grade_id
        = per_gdt_shd.g_old_rec.grade_id and
        p_language
        = per_gdt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_gdt_shd.g_old_rec;
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
  (p_grade_id                             in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       grade_id
      ,language
      ,source_lang
      ,name
    from        per_grades_tl
    where       grade_id = p_grade_id
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
    ,p_argument           => 'GRADE_ID'
    ,p_argument_value     => p_grade_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_gdt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_grades_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS

  --
  -- Return new tl grade records for new languages
  --
  cursor c_new_grades_tl is
  select gdt.grade_id
       , gd.id_flex_num
       , gd.grade_definition_id
       , gdt.created_by
       , gdt.creation_date
       , gdt.last_updated_by
       , gdt.last_update_date
       , gdt.last_update_login
       , l.language_code
       , gdt.source_lang
       , l.nls_language
       , gdt.name
    from per_grades            grd
       , per_grade_definitions gd
       , per_grades_tl         gdt
       , fnd_languages         l
   where grd.grade_definition_id =  gd.grade_definition_id
     and grd.grade_id            =  gdt.grade_id
     and gdt.language            =  userenv('LANG')
     and l.installed_flag        in ('I', 'B')
     and not exists (select null
                       from per_grades_tl t
                      where t.grade_id = gdt.grade_id
                        and t.language = l.language_code)
   order by l.language_code;
   --
   l_userenv_language_code   VARCHAR2(4) := userenv('LANG'); --Bug 2962837.
   --
   l_current_nls_language    VARCHAR2(30);
   --
   l_proc        varchar2(72) := g_package||'add_language';
   --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  delete from PER_GRADES_TL T
  where not exists
    (select NULL
    from PER_GRADES B
    where B.GRADE_ID = T.GRADE_ID
    );
  --
  --
  For l_grades_tl IN c_new_grades_tl loop
    --
    -- Only set session nls language if changed.
    --
    If l_current_nls_language = l_grades_tl.nls_language then

      null; -- Have not changed so do nothing.

    Else

      hr_kflex_utility.set_session_nls_language( l_grades_tl.nls_language );
      l_current_nls_language := l_grades_tl.nls_language;

    End if;
    --
    insert into per_grades_tl (
            grade_id
          , name
          , created_by
          , creation_date
          , last_updated_by
          , last_update_date
          , last_update_login
          , language
          , source_lang)
    values (l_grades_tl.grade_id
          , nvl(fnd_flex_ext.get_segs( g_app_code
                                     , g_flex_code
                                     , l_grades_tl.id_flex_num
                                     , l_grades_tl.grade_definition_id
                                     )
               , l_grades_tl.name
               )
          , l_grades_tl.created_by
          , l_grades_tl.creation_date
          , l_grades_tl.last_updated_by
          , l_grades_tl.last_update_date
          , l_grades_tl.last_update_login
          , l_grades_tl.language_code
          , l_grades_tl.source_lang);
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
End add_language;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_grade_id                       in number
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
  l_rec.grade_id                         := p_grade_id;
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
end per_gdt_shd;

/
