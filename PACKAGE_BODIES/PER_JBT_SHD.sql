--------------------------------------------------------
--  DDL for Package Body PER_JBT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JBT_SHD" as
/* $Header: pejbtrhi.pkb 115.2 2003/05/16 06:44:35 adudekul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_jbt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_JOBS_TL_PK') Then
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
  (p_job_id                               in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       job_id
      ,language
      ,source_lang
      ,name
    from  per_jobs_tl
    where job_id = p_job_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_job_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_job_id
        = per_jbt_shd.g_old_rec.job_id and
        p_language
        = per_jbt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_jbt_shd.g_old_rec;
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
  (p_job_id                               in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       job_id
      ,language
      ,source_lang
      ,name
    from        per_jobs_tl
    where       job_id = p_job_id
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
    ,p_argument           => 'JOB_ID'
    ,p_argument_value     => p_job_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_jbt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_jobs_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS
  --
  -- Return new tl job records for new languages
  --
  cursor c_new_jobs_tl is
  select jbt.job_id
       , jb.id_flex_num
       , jb.job_definition_id
       , jbt.created_by
       , jbt.creation_date
       , jbt.last_updated_by
       , jbt.last_update_date
       , jbt.last_update_login
       , l.language_code
       , jbt.source_lang
       , l.nls_language
       , jbt.name
    from per_jobs            job
       , per_job_definitions jb
       , per_jobs_tl         jbt
       , fnd_languages         l
   where job.job_definition_id =  jb.job_definition_id
     and job.job_id            =  jbt.job_id
     and jbt.language            =  userenv('LANG')
     and l.installed_flag        in ('I', 'B')
     and not exists (select null
                       from per_jobs_tl t
                      where t.job_id = jbt.job_id
                        and t.language = l.language_code)
   order by l.language_code;
   --
   l_userenv_language_code   VARCHAR2(4) := userenv('LANG'); --Bug2962837.
   --
   l_current_nls_language    VARCHAR2(30);
   --
   l_proc        varchar2(72) := g_package||'add_language';
   --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  delete from PER_JOBS_TL T
  where not exists
    (select NULL
    from PER_JOBS B
    where B.JOB_ID = T.JOB_ID
    );
  --
  --
  For l_jobs_tl IN c_new_jobs_tl loop
    --
    -- Only set session nls language if changed.
    --
    If l_current_nls_language = l_jobs_tl.nls_language then

      null; -- Have not changed so do nothing.

    Else

      hr_kflex_utility.set_session_nls_language( l_jobs_tl.nls_language );
      l_current_nls_language := l_jobs_tl.nls_language;

    End if;
    --
    insert into per_jobs_tl (
            job_id
          , name
          , created_by
          , creation_date
          , last_updated_by
          , last_update_date
          , last_update_login
          , language
          , source_lang)
    values (l_jobs_tl.job_id
          , nvl(fnd_flex_ext.get_segs( g_app_code
                                     , g_flex_code
                                     , l_jobs_tl.id_flex_num
                                     , l_jobs_tl.job_definition_id
                                     )
               , l_jobs_tl.name
               )
          , l_jobs_tl.created_by
          , l_jobs_tl.creation_date
          , l_jobs_tl.last_updated_by
          , l_jobs_tl.last_update_date
          , l_jobs_tl.last_update_login
          , l_jobs_tl.language_code
          , l_jobs_tl.source_lang);
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
  (p_job_id                         in number
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
  l_rec.job_id                           := p_job_id;
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
end per_jbt_shd;

/
