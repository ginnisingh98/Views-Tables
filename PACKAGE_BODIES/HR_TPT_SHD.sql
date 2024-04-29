--------------------------------------------------------
--  DDL for Package Body HR_TPT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TPT_SHD" as
/* $Header: hrtptrhi.pkb 115.4 2002/12/03 13:09:29 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_tpt_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_TAB_PAGE_PROPERTIES_TL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_TAB_PAGE_PROPERTIES_TL_PK') Then
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
  (p_tab_page_property_id                 in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       tab_page_property_id
      ,language
      ,source_lang
      ,label
    from  hr_tab_page_properties_tl
    where tab_page_property_id = p_tab_page_property_id
    and   language = p_language;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_tab_page_property_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_tab_page_property_id
        = hr_tpt_shd.g_old_rec.tab_page_property_id and
        p_language
        = hr_tpt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hr_tpt_shd.g_old_rec;
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
  (p_tab_page_property_id                 in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       tab_page_property_id
      ,language
      ,source_lang
      ,label
    from	hr_tab_page_properties_tl
    where	tab_page_property_id = p_tab_page_property_id
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
    ,p_argument           => 'TAB_PAGE_PROPERTY_ID'
    ,p_argument_value     => p_tab_page_property_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_tpt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hr_tab_page_properties_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
Procedure add_language is
  --
  cursor csr_tab_page_properties is
    select tpt.tab_page_property_id
          ,tpt.label
          ,tpt.source_lang
      from hr_tab_page_properties_tl tpt
     where tpt.language = userenv('LANG');
  --
Begin
   --
   delete from hr_tab_page_properties_tl t
     where not exists
     (  select null
           from hr_tab_page_properties_b b
           where b.tab_page_property_id = t.tab_page_property_id
     );

   update hr_tab_page_properties_tl t
      set ( label
          ) =
             ( select b.label
                  from hr_tab_page_properties_tl b
                  where b.tab_page_property_id = t.tab_page_property_id
                  and   b.language = t.source_lang       )
     where ( t.tab_page_property_id,
             t.language
	   ) in
        ( select subt.tab_page_property_id,
                 subt.language
             from hr_tab_page_properties_tl subb, hr_tab_page_properties_tl subt
             where subb.tab_page_property_id = subt.tab_page_property_id
             and subb.language = subt.source_lang
             and (  subb.label <> subt.label
             or    (subb.label is null and subt.label is not null)
             or    (subb.label is not null and subt.label is null)
		  )
	);
   --
  --
  for l_tab_page_property in csr_tab_page_properties loop
    hr_tpt_ins.ins_tl
      (p_language_code                => l_tab_page_property.source_lang
      ,p_tab_page_property_id         => l_tab_page_property.tab_page_property_id
      ,p_label                        => l_tab_page_property.label
      );
  end loop;
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_tab_page_property_id           in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_label                          in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.tab_page_property_id             := p_tab_page_property_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.label                            := p_label;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_tpt_shd;

/
