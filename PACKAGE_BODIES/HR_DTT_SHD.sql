--------------------------------------------------------
--  DDL for Package Body HR_DTT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DTT_SHD" as
/* $Header: hrdttrhi.pkb 120.0 2005/05/30 23:52:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_dtt_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_DOCUMENT_TYPES_TL_PK') Then
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
  (p_document_type_id                     in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       document_type_id
      ,language
      ,source_language
      ,document_type
      ,description
    from  hr_document_types_tl
    where document_type_id = p_document_type_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_document_type_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_document_type_id
        = hr_dtt_shd.g_old_rec.document_type_id and
        p_language
        = hr_dtt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hr_dtt_shd.g_old_rec;
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
  (p_document_type_id                     in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       document_type_id
      ,language
      ,source_language
      ,document_type
      ,description
    from        hr_document_types_tl
    where       document_type_id = p_document_type_id
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
    ,p_argument           => 'DOCUMENT_TYPE_ID'
    ,p_argument_value     => p_document_type_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_dtt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hr_document_types_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from HR_DOCUMENT_TYPES_TL T
  where not exists
    (select NULL
    from HR_DOCUMENT_TYPES B
    where B.DOCUMENT_TYPE_ID = T.DOCUMENT_TYPE_ID
    );

  update HR_DOCUMENT_TYPES_TL T set (
      DOCUMENT_TYPE,
      DESCRIPTION
    ) = (select
      B.DOCUMENT_TYPE,
      B.DESCRIPTION
    from HR_DOCUMENT_TYPES_TL B
    where B.DOCUMENT_TYPE_ID = T.DOCUMENT_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANGUAGE)
  where (
      T.DOCUMENT_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_TYPE_ID,
      SUBT.LANGUAGE
    from HR_DOCUMENT_TYPES_TL SUBB, HR_DOCUMENT_TYPES_TL SUBT
    where SUBB.DOCUMENT_TYPE_ID = SUBT.DOCUMENT_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANGUAGE
    and (SUBB.DOCUMENT_TYPE <> SUBT.DOCUMENT_TYPE
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into HR_DOCUMENT_TYPES_TL (
    DOCUMENT_TYPE_ID,
    DOCUMENT_TYPE,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANGUAGE
  ) select /*+ ORDERED */
    B.DOCUMENT_TYPE_ID,
    B.DOCUMENT_TYPE,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANGUAGE
  from HR_DOCUMENT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_DOCUMENT_TYPES_TL T
    where T.DOCUMENT_TYPE_ID = B.DOCUMENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_document_type_id               in number
  ,p_language                       in varchar2
  ,p_source_language                in varchar2
  ,p_document_type                  in varchar2
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
  l_rec.document_type_id                 := p_document_type_id;
  l_rec.language                         := p_language;
  l_rec.source_language                  := p_source_language;
  l_rec.document_type                    := p_document_type;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_dtt_shd;

/
