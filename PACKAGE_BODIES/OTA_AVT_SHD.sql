--------------------------------------------------------
--  DDL for Package Body OTA_AVT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_AVT_SHD" as
/* $Header: otavtrhi.pkb 120.0 2005/05/29 07:02:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_avt_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_ACTIVITY_VERSIONS_TL_PK') Then
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
  (p_activity_version_id                  in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       activity_version_id
      ,language
      ,source_lang
      ,version_name
      ,description
      ,intended_audience
      ,objectives
      ,keywords
    from  ota_activity_versions_tl
    where activity_version_id = p_activity_version_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_activity_version_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_activity_version_id
        = ota_avt_shd.g_old_rec.activity_version_id and
        p_language
        = ota_avt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into ota_avt_shd.g_old_rec;
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
  (p_activity_version_id                  in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       activity_version_id
      ,language
      ,source_lang
      ,version_name
      ,description
      ,intended_audience
      ,objectives
      ,keywords
    from        ota_activity_versions_tl
    where       activity_version_id = p_activity_version_id
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
    ,p_argument           => 'ACTIVITY_VERSION_ID'
    ,p_argument_value     => p_activity_version_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_avt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'ota_activity_versions_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Executed AOL's tltblgen(UNIX) program to generate the
-- ADD_LANGUAGE procedure.  Only the add_language procedure added here.
--
-- ----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from OTA_ACTIVITY_VERSIONS_TL T
  where not exists
    (select NULL
    from OTA_ACTIVITY_VERSIONS B
    where B.ACTIVITY_VERSION_ID = T.ACTIVITY_VERSION_ID
    );

  update OTA_ACTIVITY_VERSIONS_TL T set (
      VERSION_NAME,
      DESCRIPTION,
      INTENDED_AUDIENCE,
      OBJECTIVES,
      KEYWORDS
    ) = (select
      B.VERSION_NAME,
      B.DESCRIPTION,
      B.INTENDED_AUDIENCE,
      B.OBJECTIVES,
      B.KEYWORDS
    from OTA_ACTIVITY_VERSIONS_TL B
    where B.ACTIVITY_VERSION_ID = T.ACTIVITY_VERSION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTIVITY_VERSION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ACTIVITY_VERSION_ID,
      SUBT.LANGUAGE
    from OTA_ACTIVITY_VERSIONS_TL SUBB, OTA_ACTIVITY_VERSIONS_TL SUBT
    where SUBB.ACTIVITY_VERSION_ID = SUBT.ACTIVITY_VERSION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VERSION_NAME <> SUBT.VERSION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.INTENDED_AUDIENCE <> SUBT.INTENDED_AUDIENCE
      or (SUBB.INTENDED_AUDIENCE is null and SUBT.INTENDED_AUDIENCE is not null)
      or (SUBB.INTENDED_AUDIENCE is not null and SUBT.INTENDED_AUDIENCE is null)
      or SUBB.OBJECTIVES <> SUBT.OBJECTIVES
      or (SUBB.OBJECTIVES is null and SUBT.OBJECTIVES is not null)
      or (SUBB.OBJECTIVES is not null and SUBT.OBJECTIVES is null)
      or SUBB.KEYWORDS <> SUBT.KEYWORDS
      or (SUBB.KEYWORDS is null and SUBT.KEYWORDS is not null)
      or (SUBB.KEYWORDS is not null and SUBT.KEYWORDS is null)
  ));

  insert into OTA_ACTIVITY_VERSIONS_TL (
    ACTIVITY_VERSION_ID,
    VERSION_NAME,
    DESCRIPTION,
    INTENDED_AUDIENCE,
    OBJECTIVES,
    KEYWORDS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ACTIVITY_VERSION_ID,
    B.VERSION_NAME,
    B.DESCRIPTION,
    B.INTENDED_AUDIENCE,
    B.OBJECTIVES,
    B.KEYWORDS,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OTA_ACTIVITY_VERSIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OTA_ACTIVITY_VERSIONS_TL T
    where T.ACTIVITY_VERSION_ID = B.ACTIVITY_VERSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_activity_version_id            in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_version_name                   in varchar2
  ,p_description                    in varchar2
  ,p_intended_audience              in varchar2
  ,p_objectives                     in varchar2
  ,p_keywords                       in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.version_name                     := p_version_name;
  l_rec.description                      := p_description;
  l_rec.intended_audience                := p_intended_audience;
  l_rec.objectives                       := p_objectives;
  l_rec.keywords                         := p_keywords;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_avt_shd;

/
