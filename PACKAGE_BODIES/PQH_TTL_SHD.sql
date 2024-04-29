--------------------------------------------------------
--  DDL for Package Body PQH_TTL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TTL_SHD" as
/* $Header: pqttlrhi.pkb 120.1 2005/08/06 13:18:05 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_ttl_shd.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_template_id                        in number,
  p_language                           in varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		template_id,
	template_name,
	language,
	source_lang
    from	pqh_templates_tl
    where	template_id = p_template_id
  and   language = p_language;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_template_id is null or
	p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_template_id = g_old_rec.template_id and
	p_language = g_old_rec.language
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      --
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_template_id                        in number,
  p_language                           in varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	template_id,
	template_name,
	language,
	source_lang
    from	pqh_templates_tl
    where	template_id = p_template_id
  and   language = p_language
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pqh_templates_tl');
    hr_utility.raise_error;
End lck;
--
--
-- --------------------------------------ADD LANGUAGE ------------------------
--

procedure ADD_LANGUAGE
is
begin
  delete from PQH_TEMPLATES_TL T
  where not exists
    (select NULL
    from PQH_TEMPLATES B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  update PQH_TEMPLATES_TL T set (
      TEMPLATE_NAME
    ) = (select
      B.TEMPLATE_NAME
    from PQH_TEMPLATES_TL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from PQH_TEMPLATES_TL SUBB, PQH_TEMPLATES_TL SUBT
    where SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
  ));

 insert into PQH_TEMPLATES_TL (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TEMPLATE_ID,
    B.TEMPLATE_NAME,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQH_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQH_TEMPLATES_TL T
    where T.TEMPLATE_ID = B.TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_template_id                   in number,
	p_template_name                 in varchar2,
	p_language                      in varchar2,
	p_source_lang                   in varchar2
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.template_id                      := p_template_id;
  l_rec.template_name                    := p_template_name;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqh_ttl_shd;

/
