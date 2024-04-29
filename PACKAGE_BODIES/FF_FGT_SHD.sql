--------------------------------------------------------
--  DDL for Package Body FF_FGT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FGT_SHD" as
/* $Header: fffgtrhi.pkb 120.0 2005/05/27 23:24:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ff_fgt_shd.';  -- Global package name
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
  If (p_constraint_name = 'FF_GLOBALS_F_TL_PRIMARY_KEY') Then
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
  (p_global_id                            in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       global_id
      ,language
      ,source_lang
      ,global_name
      ,global_description
    from  ff_globals_f_tl
    where global_id = p_global_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_global_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_global_id
        = ff_fgt_shd.g_old_rec.global_id and
        p_language
        = ff_fgt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into ff_fgt_shd.g_old_rec;
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
  (p_global_id                            in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       global_id
      ,language
      ,source_lang
      ,global_name
      ,global_description
    from        ff_globals_f_tl
    where       global_id = p_global_id
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
    ,p_argument           => 'GLOBAL_ID'
    ,p_argument_value     => p_global_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ff_fgt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'ff_globals_f_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from FF_GLOBALS_F_TL T
  where not exists
    (select NULL
    from FF_GLOBALS_F B
    where B.GLOBAL_ID = T.GLOBAL_ID
    );
  update FF_GLOBALS_F_TL T set (
      GLOBAL_NAME,
      GLOBAL_DESCRIPTION
    ) = (select
      B.GLOBAL_NAME,
      B.GLOBAL_DESCRIPTION
    from FF_GLOBALS_F_TL B
    where B.GLOBAL_ID = T.GLOBAL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GLOBAL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GLOBAL_ID,
      SUBT.LANGUAGE
    from FF_GLOBALS_F_TL SUBB, FF_GLOBALS_F_TL SUBT
    where SUBB.GLOBAL_ID = SUBT.GLOBAL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GLOBAL_NAME <> SUBT.GLOBAL_NAME
      or SUBB.GLOBAL_DESCRIPTION <> SUBT.GLOBAL_DESCRIPTION
      or (SUBB.GLOBAL_DESCRIPTION is null and SUBT.GLOBAL_DESCRIPTION is not null)
      or (SUBB.GLOBAL_DESCRIPTION is not null and SUBT.GLOBAL_DESCRIPTION is null)
  ));

  insert into FF_GLOBALS_F_TL (
    GLOBAL_ID,
    GLOBAL_NAME,
    GLOBAL_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GLOBAL_ID,
    B.GLOBAL_NAME,
    B.GLOBAL_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FF_GLOBALS_F_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FF_GLOBALS_F_TL T
    where T.GLOBAL_ID = B.GLOBAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_global_id                      in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_global_name                    in varchar2
  ,p_global_description             in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.global_id                        := p_global_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.global_name                      := p_global_name;
  l_rec.global_description               := p_global_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ff_fgt_shd;

/
