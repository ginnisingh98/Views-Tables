--------------------------------------------------------
--  DDL for Package Body OTA_SRT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_SRT_SHD" as
/* $Header: otsrtrhi.pkb 115.3 2003/05/19 07:56:51 jbharath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_srt_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_SUPPLIABLE_RESOURCES_TL_PK') Then
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
  (p_supplied_resource_id                 in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       supplied_resource_id
      ,language
      ,name
      ,special_instruction
      ,source_lang
    from  ota_suppliable_resources_tl
    where supplied_resource_id = p_supplied_resource_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_supplied_resource_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_supplied_resource_id
        = ota_srt_shd.g_old_rec.supplied_resource_id and
        p_language
        = ota_srt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into ota_srt_shd.g_old_rec;
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
  (p_supplied_resource_id                 in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       supplied_resource_id
      ,language
      ,name
      ,special_instruction
      ,source_lang
    from        ota_suppliable_resources_tl
    where       supplied_resource_id = p_supplied_resource_id
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
    ,p_argument           => 'SUPPLIED_RESOURCE_ID'
    ,p_argument_value     => p_supplied_resource_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_srt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'ota_suppliable_resources_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Executed AOL's tltblgen(UNIX) program to generate the
-- ADD_LANGUAGE procedure.  Only the add_language procedure
-- is added here.
--
-- ----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from OTA_SUPPLIABLE_RESOURCES_TL T
  where not exists
    (select NULL
    from OTA_SUPPLIABLE_RESOURCES B
    where B.SUPPLIED_RESOURCE_ID = T.SUPPLIED_RESOURCE_ID
    );

  update OTA_SUPPLIABLE_RESOURCES_TL T set (
      SPECIAL_INSTRUCTION,
      NAME
    ) = (select
      B.SPECIAL_INSTRUCTION,
      B.NAME
    from OTA_SUPPLIABLE_RESOURCES_TL B
    where B.SUPPLIED_RESOURCE_ID = T.SUPPLIED_RESOURCE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SUPPLIED_RESOURCE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SUPPLIED_RESOURCE_ID,
      SUBT.LANGUAGE
    from OTA_SUPPLIABLE_RESOURCES_TL SUBB, OTA_SUPPLIABLE_RESOURCES_TL SUBT
    where SUBB.SUPPLIED_RESOURCE_ID = SUBT.SUPPLIED_RESOURCE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SPECIAL_INSTRUCTION <> SUBT.SPECIAL_INSTRUCTION
      or (SUBB.SPECIAL_INSTRUCTION is null and SUBT.SPECIAL_INSTRUCTION is not null)
      or (SUBB.SPECIAL_INSTRUCTION is not null and SUBT.SPECIAL_INSTRUCTION is null)
      or SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
  ));

  insert into OTA_SUPPLIABLE_RESOURCES_TL (
    SUPPLIED_RESOURCE_ID,
    NAME,
    SPECIAL_INSTRUCTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SUPPLIED_RESOURCE_ID,
    B.NAME,
    B.SPECIAL_INSTRUCTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OTA_SUPPLIABLE_RESOURCES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OTA_SUPPLIABLE_RESOURCES_TL T
    where T.SUPPLIED_RESOURCE_ID = B.SUPPLIED_RESOURCE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_supplied_resource_id           in number
  ,p_language                       in varchar2
  ,p_name                           in varchar2
  ,p_special_instruction            in varchar2
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
  l_rec.supplied_resource_id             := p_supplied_resource_id;
  l_rec.language                         := p_language;
  l_rec.name                             := p_name;
  l_rec.special_instruction              := p_special_instruction;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_srt_shd;

/
