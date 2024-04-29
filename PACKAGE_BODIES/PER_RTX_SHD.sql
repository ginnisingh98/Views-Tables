--------------------------------------------------------
--  DDL for Package Body PER_RTX_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RTX_SHD" as
/* $Header: pertxrhi.pkb 115.3 2004/06/28 23:22:17 kjagadee noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rtx_shd.';  -- Global package name
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
 hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_RATING_LEVELS_FK1') Then
    hr_utility.set_message(801, 'HR_51471_RTL_RSC_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_RATING_LEVELS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_RATING_LEVELS_FK3') Then
    hr_utility.set_message(801, 'HR_51472_RTL_CPN_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_RATING_LEVELS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_RATING_LEVELS_UK2') Then
    hr_utility.set_message(801, 'HR_51477_RTL_STEP_NOT_UNIQUE');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_RATING_LEVELS_UK3') Then
    hr_utility.set_message(801, 'HR_51474_RTL_NOT_UNIQUE');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_RTL_CPN_OR_RSC_CHK') Then
    hr_utility.set_message(801, 'HR_51482_RTL_RSC_OR_CPN');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_rating_level_id                      in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       rating_level_id
      ,language
      ,source_lang
      ,name
      ,behavioural_indicator
    from  per_rating_levels_tl
    where rating_level_id = p_rating_level_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_rating_level_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_rating_level_id
        = per_rtx_shd.g_old_rec.rating_level_id and
        p_language
        = per_rtx_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_rtx_shd.g_old_rec;
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
  (p_rating_level_id                      in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       rating_level_id
      ,language
      ,source_lang
      ,name
      ,behavioural_indicator
    from        per_rating_levels_tl
    where       rating_level_id = p_rating_level_id
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
    ,p_argument           => 'RATING_LEVEL_ID'
    ,p_argument_value     => p_rating_level_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_rtx_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_rating_levels_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- MB added on 16-Dec-2002
procedure ADD_LANGUAGE
is
begin
  delete from PER_RATING_LEVELS_TL T
  where not exists
    (select NULL
    from PER_RATING_LEVELS B
    where B.RATING_LEVEL_ID = T.RATING_LEVEL_ID
    );

  update PER_RATING_LEVELS_TL T set (
      NAME,
      BEHAVIOURAL_INDICATOR
    ) = (select
      B.NAME,
      B.BEHAVIOURAL_INDICATOR
    from PER_RATING_LEVELS_TL B
    where B.RATING_LEVEL_ID = T.RATING_LEVEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RATING_LEVEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RATING_LEVEL_ID,
      SUBT.LANGUAGE
    from PER_RATING_LEVELS_TL SUBB, PER_RATING_LEVELS_TL SUBT
    where SUBB.RATING_LEVEL_ID = SUBT.RATING_LEVEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.BEHAVIOURAL_INDICATOR <> SUBT.BEHAVIOURAL_INDICATOR
      or (SUBB.BEHAVIOURAL_INDICATOR is null and SUBT.BEHAVIOURAL_INDICATOR is not null)
      or (SUBB.BEHAVIOURAL_INDICATOR is not null and SUBT.BEHAVIOURAL_INDICATOR is null)
  ));

  insert into PER_RATING_LEVELS_TL (
    RATING_LEVEL_ID,
    NAME,
    BEHAVIOURAL_INDICATOR,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ INDEX(b)*/
    B.RATING_LEVEL_ID,
    B.NAME,
    B.BEHAVIOURAL_INDICATOR,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_RATING_LEVELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_RATING_LEVELS_TL T
    where T.RATING_LEVEL_ID = B.RATING_LEVEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_rating_level_id                in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_name                           in varchar2
  ,p_behavioural_indicator          in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.rating_level_id                  := p_rating_level_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.name                             := p_name;
  l_rec.behavioural_indicator            := p_behavioural_indicator;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_rtx_shd;

/
