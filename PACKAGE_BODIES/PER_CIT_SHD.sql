--------------------------------------------------------
--  DDL for Package Body PER_CIT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CIT_SHD" as
/* $Header: pecitrhi.pkb 115.3 2004/06/28 22:24:21 jpthomas noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cit_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_CAGR_ENT_ITEMS_TL_PK') Then
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
  (p_cagr_entitlement_item_id             in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cagr_entitlement_item_id
      ,item_name
      ,language
      ,source_lang
    from  per_cagr_entitlement_items_tl
    where cagr_entitlement_item_id = p_cagr_entitlement_item_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_cagr_entitlement_item_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cagr_entitlement_item_id
        = per_cit_shd.g_old_rec.cagr_entitlement_item_id and
        p_language
        = per_cit_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_cit_shd.g_old_rec;
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
  (p_cagr_entitlement_item_id             in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       cagr_entitlement_item_id
      ,item_name
      ,language
      ,source_lang
    from        per_cagr_entitlement_items_tl
    where       cagr_entitlement_item_id = p_cagr_entitlement_item_id
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
    ,p_argument           => 'CAGR_ENTITLEMENT_ITEM_ID'
    ,p_argument_value     => p_cagr_entitlement_item_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_cit_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_cagr_entitlement_items_tl');
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
procedure ADD_LANGUAGE
is
begin
  delete from PER_CAGR_ENTITLEMENT_ITEMS_TL T
  where not exists
    (select NULL
    from PER_CAGR_ENTITLEMENT_ITEMS B
    where B.CAGR_ENTITLEMENT_ITEM_ID = T.CAGR_ENTITLEMENT_ITEM_ID
    );

  update PER_CAGR_ENTITLEMENT_ITEMS_TL T set (
      ITEM_NAME
    ) = (select
      B.ITEM_NAME
    from PER_CAGR_ENTITLEMENT_ITEMS_TL B
    where B.CAGR_ENTITLEMENT_ITEM_ID = T.CAGR_ENTITLEMENT_ITEM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CAGR_ENTITLEMENT_ITEM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CAGR_ENTITLEMENT_ITEM_ID,
      SUBT.LANGUAGE
    from PER_CAGR_ENTITLEMENT_ITEMS_TL SUBB, PER_CAGR_ENTITLEMENT_ITEMS_TL SUBT
    where SUBB.CAGR_ENTITLEMENT_ITEM_ID = SUBT.CAGR_ENTITLEMENT_ITEM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ITEM_NAME <> SUBT.ITEM_NAME
  ));

  insert into PER_CAGR_ENTITLEMENT_ITEMS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CAGR_ENTITLEMENT_ITEM_ID,
    ITEM_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CAGR_ENTITLEMENT_ITEM_ID,
    B.ITEM_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_CAGR_ENTITLEMENT_ITEMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_CAGR_ENTITLEMENT_ITEMS_TL T
    where T.CAGR_ENTITLEMENT_ITEM_ID = B.CAGR_ENTITLEMENT_ITEM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cagr_entitlement_item_id       in number
  ,p_item_name                      in varchar2
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
  l_rec.cagr_entitlement_item_id         := p_cagr_entitlement_item_id;
  l_rec.item_name                        := p_item_name;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_cit_shd;

/
