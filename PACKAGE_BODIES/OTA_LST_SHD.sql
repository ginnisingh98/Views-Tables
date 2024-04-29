--------------------------------------------------------
--  DDL for Package Body OTA_LST_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LST_SHD" as
/* $Header: otlstrhi.pkb 120.0 2005/05/29 07:25:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_lst_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_LP_SECTIONS_TL_PK') Then
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
  (p_learning_path_section_id             in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       learning_path_section_id
      ,language
      ,name
      ,description
      ,source_lang
    from  ota_lp_sections_tl
    where learning_path_section_id = p_learning_path_section_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_learning_path_section_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_learning_path_section_id
        = ota_lst_shd.g_old_rec.learning_path_section_id and
        p_language
        = ota_lst_shd.g_old_rec.language
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
      Fetch C_Sel1 Into ota_lst_shd.g_old_rec;
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
  (p_learning_path_section_id             in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       learning_path_section_id
      ,language
      ,name
      ,description
      ,source_lang
    from        ota_lp_sections_tl
    where       learning_path_section_id = p_learning_path_section_id
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
    ,p_argument           => 'LEARNING_PATH_SECTION_ID'
    ,p_argument_value     => p_learning_path_section_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_lst_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'ota_lp_sections_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- Added for Bug#4310348
procedure ADD_LANGUAGE
is
begin
  delete from OTA_LP_SECTIONS_TL T
  where not exists
    (select NULL
    from OTA_LP_SECTIONS B
    where B.LEARNING_PATH_SECTION_ID = T.LEARNING_PATH_SECTION_ID
    );

  update OTA_LP_SECTIONS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from OTA_LP_SECTIONS_TL B
    where B.LEARNING_PATH_SECTION_ID = T.LEARNING_PATH_SECTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LEARNING_PATH_SECTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LEARNING_PATH_SECTION_ID,
      SUBT.LANGUAGE
    from OTA_LP_SECTIONS_TL SUBB, OTA_LP_SECTIONS_TL SUBT
    where SUBB.LEARNING_PATH_SECTION_ID = SUBT.LEARNING_PATH_SECTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into OTA_LP_SECTIONS_TL (
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    LEARNING_PATH_SECTION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.LEARNING_PATH_SECTION_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OTA_LP_SECTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OTA_LP_SECTIONS_TL T
    where T.LEARNING_PATH_SECTION_ID = B.LEARNING_PATH_SECTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_learning_path_section_id       in number
  ,p_language                       in varchar2
  ,p_name                           in varchar2
  ,p_description                    in varchar2
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
  l_rec.learning_path_section_id         := p_learning_path_section_id;
  l_rec.language                         := p_language;
  l_rec.name                             := p_name;
  l_rec.description                      := p_description;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_lst_shd;

/
