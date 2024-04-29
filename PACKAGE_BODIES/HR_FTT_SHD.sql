--------------------------------------------------------
--  DDL for Package Body HR_FTT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FTT_SHD" as
/* $Header: hrfttrhi.pkb 115.3 2002/12/03 13:13:18 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_ftt_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If    (p_constraint_name = 'HR_FORM_TAB_PAGES_TL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_FORM_TAB_PAGES_TL_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  (p_form_tab_page_id                     in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       form_tab_page_id
      ,language
      ,source_lang
      ,user_tab_page_name
      ,description
    from  hr_form_tab_pages_tl
    where form_tab_page_id = p_form_tab_page_id
    and   language = p_language;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_form_tab_page_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_form_tab_page_id
        = hr_ftt_shd.g_old_rec.form_tab_page_id and
        p_language
        = hr_ftt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hr_ftt_shd.g_old_rec;
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
  (p_form_tab_page_id                     in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       form_tab_page_id
      ,language
      ,source_lang
      ,user_tab_page_name
      ,description
    from	hr_form_tab_pages_tl
    where	form_tab_page_id = p_form_tab_page_id
    and   language = p_language
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'FORM_TAB_PAGE_ID'
    ,p_argument_value     => p_form_tab_page_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_ftt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hr_form_tab_pages_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
Procedure add_language is
  --
  cursor csr_form_tab_pages is
    select ftt.form_tab_page_id
          ,ftt.user_tab_page_name
          ,ftt.description
          ,ftt.source_lang
      from hr_form_tab_pages_tl ftt
     where ftt.language = userenv('LANG');
  --
Begin
   --
   delete from hr_form_tab_pages_tl t
     where not exists
     (  select null
           from hr_form_tab_pages_b b
           where b.form_tab_page_id = t.form_tab_page_id
     );

   update hr_form_tab_pages_tl t
      set ( user_tab_page_name,
            description ) =
             ( select b.user_tab_page_name,
                      b.description
                  from hr_form_tab_pages_tl b
                  where b.form_tab_page_id = t.form_tab_page_id
                  and   b.language = t.source_lang       )
     where ( t.form_tab_page_id,
             t.language
	   ) in
        ( select subt.form_tab_page_id,
                 subt.language
             from hr_form_tab_pages_tl subb, hr_form_tab_pages_tl subt
             where subb.form_tab_page_id = subt.form_tab_page_id
             and subb.language = subt.source_lang
             and ( subb.user_tab_page_name <> subt.user_tab_page_name
             or    subb.description <> subt.description
             or    (subb.description is null and subt.description is not null)
             or    (subb.description is not null and subt.description is null)
		  )
	);
   --
  --
  for l_form_tab_page in csr_form_tab_pages loop
    hr_ftt_ins.ins_tl
      (p_language_code                => l_form_tab_page.source_lang
      ,p_form_tab_page_id             => l_form_tab_page.form_tab_page_id
      ,p_user_tab_page_name           => l_form_tab_page.user_tab_page_name
      ,p_description                  => l_form_tab_page.description
      );
  end loop;
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_form_tab_page_id               in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_user_tab_page_name             in varchar2
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
  l_rec.form_tab_page_id                 := p_form_tab_page_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.user_tab_page_name               := p_user_tab_page_name;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_ftt_shd;

/
