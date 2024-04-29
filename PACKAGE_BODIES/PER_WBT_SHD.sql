--------------------------------------------------------
--  DDL for Package Body PER_WBT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_WBT_SHD" as
/* $Header: pewbtrhi.pkb 115.2 2004/07/04 23:58:13 balchand noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_wbt_shd.';  -- Global package name
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
  Null;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_workbench_item_code                  in     varchar2
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       workbench_item_code
      ,language
      ,workbench_item_name
      ,workbench_item_description
      ,source_lang
    from  per_ri_workbench_items_tl
    where workbench_item_code = p_workbench_item_code
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_workbench_item_code is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_workbench_item_code
        = per_wbt_shd.g_old_rec.workbench_item_code and
        p_language
        = per_wbt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_wbt_shd.g_old_rec;
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
  (p_workbench_item_code                  in     varchar2
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       workbench_item_code
      ,language
      ,workbench_item_name
      ,workbench_item_description
      ,source_lang
    from        per_ri_workbench_items_tl
    where       workbench_item_code = p_workbench_item_code
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
    ,p_argument           => 'WORKBENCH_ITEM_CODE'
    ,p_argument_value     => p_workbench_item_code
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_wbt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_ri_workbench_items_tl');
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
    delete from PER_RI_WORKBENCH_ITEMS_TL T
  where not exists
    (select NULL
    from PER_RI_WORKBENCH_ITEMS B
    where B.WORKBENCH_ITEM_CODE = T.WORKBENCH_ITEM_CODE
    );

  update PER_RI_WORKBENCH_ITEMS_TL T set (
      WORKBENCH_ITEM_NAME,
      WORKBENCH_ITEM_DESCRIPTION
    ) = (select
      B.WORKBENCH_ITEM_NAME,
      B.WORKBENCH_ITEM_DESCRIPTION
    from PER_RI_WORKBENCH_ITEMS_TL B
    where B.WORKBENCH_ITEM_CODE = T.WORKBENCH_ITEM_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WORKBENCH_ITEM_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.WORKBENCH_ITEM_CODE,
      SUBT.LANGUAGE
    from PER_RI_WORKBENCH_ITEMS_TL SUBB, PER_RI_WORKBENCH_ITEMS_TL SUBT
    where SUBB.WORKBENCH_ITEM_CODE = SUBT.WORKBENCH_ITEM_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.WORKBENCH_ITEM_NAME <> SUBT.WORKBENCH_ITEM_NAME
      or SUBB.WORKBENCH_ITEM_DESCRIPTION <> SUBT.WORKBENCH_ITEM_DESCRIPTION
  ));

  insert into PER_RI_WORKBENCH_ITEMS_TL (
    WORKBENCH_ITEM_CODE,
    WORKBENCH_ITEM_NAME,
    WORKBENCH_ITEM_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.WORKBENCH_ITEM_CODE,
    B.WORKBENCH_ITEM_NAME,
    B.WORKBENCH_ITEM_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_RI_WORKBENCH_ITEMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_RI_WORKBENCH_ITEMS_TL T
    where T.WORKBENCH_ITEM_CODE = B.WORKBENCH_ITEM_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
End add_language;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_workbench_item_code            in varchar2
  ,p_language                       in varchar2
  ,p_workbench_item_name            in varchar2
  ,p_workbench_item_description     in varchar2
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
  l_rec.workbench_item_code              := p_workbench_item_code;
  l_rec.language                         := p_language;
  l_rec.workbench_item_name              := p_workbench_item_name;
  l_rec.workbench_item_description       := p_workbench_item_description;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_wbt_shd;

/
