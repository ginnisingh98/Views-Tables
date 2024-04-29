--------------------------------------------------------
--  DDL for Package Body PAY_BDT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BDT_SHD" as
/* $Header: pybdtrhi.pkb 120.3 2005/11/24 05:36:48 arashid noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_bdt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_BALANCE_DIMENSIONS_TL_PK') Then
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
  (p_balance_dimension_id                 in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       balance_dimension_id
      ,language
      ,source_lang
      ,dimension_name
      ,database_item_suffix
      ,description
    from  pay_balance_dimensions_tl
    where balance_dimension_id = p_balance_dimension_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_balance_dimension_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_balance_dimension_id
        = pay_bdt_shd.g_old_rec.balance_dimension_id and
        p_language
        = pay_bdt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into pay_bdt_shd.g_old_rec;
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
  (p_balance_dimension_id                 in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       balance_dimension_id
      ,language
      ,source_lang
      ,dimension_name
      ,database_item_suffix
      ,description
    from        pay_balance_dimensions_tl
    where       balance_dimension_id = p_balance_dimension_id
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
    ,p_argument           => 'BALANCE_DIMENSION_ID'
    ,p_argument_value     => p_balance_dimension_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_bdt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'pay_balance_dimensions_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS
Begin
  delete from PAY_BALANCE_DIMENSIONS_TL T
  where not exists
    (select NULL
    from PAY_BALANCE_DIMENSIONS B
    where B.BALANCE_DIMENSION_ID = T.BALANCE_DIMENSION_ID
    );
update PAY_BALANCE_DIMENSIONS_TL T set (
      DIMENSION_NAME,
      DESCRIPTION
    ) = (select
      B.DIMENSION_NAME,
      B.DESCRIPTION
    from PAY_BALANCE_DIMENSIONS_TL B
    where B.BALANCE_DIMENSION_ID = T.BALANCE_DIMENSION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BALANCE_DIMENSION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BALANCE_DIMENSION_ID,
      SUBT.LANGUAGE
    from PAY_BALANCE_DIMENSIONS_TL SUBB, PAY_BALANCE_DIMENSIONS_TL SUBT
    where SUBB.BALANCE_DIMENSION_ID = SUBT.BALANCE_DIMENSION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DIMENSION_NAME <> SUBT.DIMENSION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
  insert into PAY_BALANCE_DIMENSIONS_TL (
    BALANCE_DIMENSION_ID,
    DIMENSION_NAME,
    DATABASE_ITEM_SUFFIX,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.BALANCE_DIMENSION_ID,
    B.DIMENSION_NAME,
    B.DATABASE_ITEM_SUFFIX,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_BALANCE_DIMENSIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_BALANCE_DIMENSIONS_TL T
    where T.BALANCE_DIMENSION_ID = B.BALANCE_DIMENSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
End add_language;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_balance_dimension_id           in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_dimension_name                 in varchar2
  ,p_database_item_suffix           in varchar2
  ,p_description                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.balance_dimension_id             := p_balance_dimension_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.dimension_name                   := p_dimension_name;
  l_rec.database_item_suffix             := p_database_item_suffix;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_bdt_shd;

/
