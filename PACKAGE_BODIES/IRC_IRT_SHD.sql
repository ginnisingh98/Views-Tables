--------------------------------------------------------
--  DDL for Package Body IRC_IRT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IRT_SHD" as
/* $Header: irirtrhi.pkb 120.0 2005/07/26 15:10 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_irt_shd.';  -- Global package name
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
  If (p_constraint_name = 'IRC_ALL_RECRUITING_SITES_TL_PK') Then
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
  (p_recruiting_site_id                   in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       recruiting_site_id
      ,language
      ,source_lang
      ,site_name
      ,redirection_url
      ,''
      ,posting_url
      ,''
    from  irc_all_recruiting_sites_tl
    where recruiting_site_id = p_recruiting_site_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_recruiting_site_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_recruiting_site_id
        = irc_irt_shd.g_old_rec.recruiting_site_id and
        p_language
        = irc_irt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into irc_irt_shd.g_old_rec;
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
      irc_irt_shd.g_old_rec.redirection_url
      := dbms_lob.substr(irc_irt_shd.g_old_rec.redirection_url_c);
      irc_irt_shd.g_old_rec.posting_url
      := dbms_lob.substr(irc_irt_shd.g_old_rec.posting_url_c);
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
  (p_recruiting_site_id                   in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       recruiting_site_id
      ,language
      ,source_lang
      ,site_name
      ,redirection_url
      ,''
      ,posting_url
      ,''
    from        irc_all_recruiting_sites_tl
    where       recruiting_site_id = p_recruiting_site_id
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
    ,p_argument           => 'RECRUITING_SITE_ID'
    ,p_argument_value     => p_recruiting_site_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into irc_irt_shd.g_old_rec;
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
  irc_irt_shd.g_old_rec.redirection_url
  := dbms_lob.substr(irc_irt_shd.g_old_rec.redirection_url_c);
  irc_irt_shd.g_old_rec.posting_url
  := dbms_lob.substr(irc_irt_shd.g_old_rec.posting_url_c);
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
    fnd_message.set_token('TABLE_NAME', 'irc_all_recruiting_sites_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS
Begin
   delete from IRC_ALL_RECRUITING_SITES_TL T
  where not exists
    (select NULL
    from IRC_ALL_RECRUITING_SITES B
    where B.RECRUITING_SITE_ID = T.RECRUITING_SITE_ID
    );

  update IRC_ALL_RECRUITING_SITES_TL T set (
      SITE_NAME,
      REDIRECTION_URL,
      POSTING_URL
    ) = (select
      B.SITE_NAME,
      B.REDIRECTION_URL,
      B.POSTING_URL
    from IRC_ALL_RECRUITING_SITES_TL B
    where B.RECRUITING_SITE_ID = T.RECRUITING_SITE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RECRUITING_SITE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RECRUITING_SITE_ID,
      SUBT.LANGUAGE
    from IRC_ALL_RECRUITING_SITES_TL SUBB, IRC_ALL_RECRUITING_SITES_TL SUBT
    where SUBB.RECRUITING_SITE_ID = SUBT.RECRUITING_SITE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SITE_NAME <> SUBT.SITE_NAME
      or dbms_lob.compare(SUBB.REDIRECTION_URL,SUBT.REDIRECTION_URL) <> 0
      or (SUBB.REDIRECTION_URL is null and SUBT.REDIRECTION_URL is not null)
      or (SUBB.REDIRECTION_URL is not null and SUBT.REDIRECTION_URL is null)
      or dbms_lob.compare(SUBB.POSTING_URL,SUBT.POSTING_URL) <> 0
      or (SUBB.POSTING_URL is null and SUBT.POSTING_URL is not null)
      or (SUBB.POSTING_URL is not null and SUBT.POSTING_URL is null)
  ));

  insert into IRC_ALL_RECRUITING_SITES_TL (
    SITE_NAME,
    REDIRECTION_URL,
    POSTING_URL,
    RECRUITING_SITE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.SITE_NAME,
    B.REDIRECTION_URL,
    B.POSTING_URL,
    B.RECRUITING_SITE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IRC_ALL_RECRUITING_SITES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IRC_ALL_RECRUITING_SITES_TL T
    where T.RECRUITING_SITE_ID = B.RECRUITING_SITE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
End add_language;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_recruiting_site_id             in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_site_name                      in varchar2
  ,p_redirection_url                in varchar2
  ,p_posting_url                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.recruiting_site_id               := p_recruiting_site_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.site_name                        := p_site_name;
  l_rec.redirection_url                  := p_redirection_url;
  l_rec.posting_url                      := p_posting_url;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end irc_irt_shd;

/
