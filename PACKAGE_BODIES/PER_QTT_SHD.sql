--------------------------------------------------------
--  DDL for Package Body PER_QTT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QTT_SHD" as
/* $Header: peqttrhi.pkb 115.2 2003/05/13 06:22:26 fsheikh noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_qtt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_QUALIFICATION_TYPES_TL_PK') Then
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
  (p_qualification_type_id                in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       qualification_type_id
      ,language
      ,source_lang
      ,name
    from  per_qualification_types_tl
    where qualification_type_id = p_qualification_type_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_qualification_type_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_qualification_type_id
        = per_qtt_shd.g_old_rec.qualification_type_id and
        p_language
        = per_qtt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_qtt_shd.g_old_rec;
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
  (p_qualification_type_id                in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       qualification_type_id
      ,language
      ,source_lang
      ,name
    from        per_qualification_types_tl
    where       qualification_type_id = p_qualification_type_id
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
    ,p_argument           => 'QUALIFICATION_TYPE_ID'
    ,p_argument_value     => p_qualification_type_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_qtt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_qualification_types_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_language IS
Begin
  --
  delete from PER_QUALIFICATION_TYPES_TL T
  where not exists
    (select NULL
    from PER_QUALIFICATION_TYPES B
    where B.QUALIFICATION_TYPE_ID = T.QUALIFICATION_TYPE_ID
    );

  update PER_QUALIFICATION_TYPES_TL T set (
      NAME
    ) = (select
      B.NAME
    from PER_QUALIFICATION_TYPES_TL B
    where B.QUALIFICATION_TYPE_ID = T.QUALIFICATION_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUALIFICATION_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QUALIFICATION_TYPE_ID,
      SUBT.LANGUAGE
    from PER_QUALIFICATION_TYPES_TL SUBB, PER_QUALIFICATION_TYPES_TL SUBT
    where SUBB.QUALIFICATION_TYPE_ID = SUBT.QUALIFICATION_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
  ));

  insert into PER_QUALIFICATION_TYPES_TL (
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    NAME,
    QUALIFICATION_TYPE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.NAME,
    B.QUALIFICATION_TYPE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_QUALIFICATION_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_QUALIFICATION_TYPES_TL T
    where T.QUALIFICATION_TYPE_ID = B.QUALIFICATION_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
End add_language;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_qualification_type_id          in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_name                           in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.qualification_type_id            := p_qualification_type_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.name                             := p_name;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_qtt_shd;

/
