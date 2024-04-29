--------------------------------------------------------
--  DDL for Package Body PER_CNT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNT_SHD" as
/* $Header: pecntrhi.pkb 120.1 2005/11/03 15:07 dgarg noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cnt_shd.';  -- Global package name
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
  If (p_constraint_name = 'SYS_C00255679') Then
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
  (p_configuration_code                   in     varchar2
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       configuration_code
      ,configuration_name
      ,configuration_description
      ,language
      ,source_lang
    from  per_ri_configurations_tl
    where configuration_code = p_configuration_code
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_configuration_code is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_configuration_code
        = per_cnt_shd.g_old_rec.configuration_code and
        p_language
        = per_cnt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_cnt_shd.g_old_rec;
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
  (p_configuration_code                   in     varchar2
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       configuration_code
      ,configuration_name
      ,configuration_description
      ,language
      ,source_lang
    from        per_ri_configurations_tl
    where       configuration_code = p_configuration_code
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
    ,p_argument           => 'CONFIGURATION_CODE'
    ,p_argument_value     => p_configuration_code
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_cnt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_ri_configurations_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
-- EDIT_HERE:  Execute AOL's tltblgen(UNIX) program to generate the
--             ADD_LANGUAGE procedure.  Only the add_language procedure
--             should be added here.  Remove the following skeleton
--             procedure.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS
Begin
  --
    delete from PER_RI_CONFIGURATIONS_TL T
  where not exists
    (select NULL
    from PER_RI_CONFIGURATIONS B
    where B.CONFIGURATION_CODE = T.CONFIGURATION_CODE
    );

  update PER_RI_CONFIGURATIONS_TL T set (
      CONFIGURATION_NAME,
      CONFIGURATION_DESCRIPTION
    ) = (select
      B.CONFIGURATION_NAME,
      B.CONFIGURATION_DESCRIPTION
    from PER_RI_CONFIGURATIONS_TL B
    where B.CONFIGURATION_CODE = T.CONFIGURATION_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CONFIGURATION_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.CONFIGURATION_CODE,
      SUBT.LANGUAGE
    from PER_RI_CONFIGURATIONS_TL SUBB, PER_RI_CONFIGURATIONS_TL SUBT
    where SUBB.CONFIGURATION_CODE = SUBT.CONFIGURATION_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CONFIGURATION_NAME <> SUBT.CONFIGURATION_NAME
      or SUBB.CONFIGURATION_DESCRIPTION <> SUBT.CONFIGURATION_DESCRIPTION
  ));

  insert into PER_RI_CONFIGURATIONS_TL (
    CONFIGURATION_CODE,
    CONFIGURATION_NAME,
    CONFIGURATION_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CONFIGURATION_CODE,
    B.CONFIGURATION_NAME,
    B.CONFIGURATION_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_RI_CONFIGURATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_RI_CONFIGURATIONS_TL T
    where T.CONFIGURATION_CODE = B.CONFIGURATION_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_configuration_code             in varchar2
  ,p_configuration_name             in varchar2
  ,p_configuration_description      in varchar2
  ,p_language                       in varchar2
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
  l_rec.configuration_code               := p_configuration_code;
  l_rec.configuration_name               := p_configuration_name;
  l_rec.configuration_description        := p_configuration_description;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_cnt_shd;

/
