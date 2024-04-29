--------------------------------------------------------
--  DDL for Package Body HR_IPT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IPT_SHD" as
/* $Header: hriptrhi.pkb 115.9 2003/05/06 17:43:05 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_ipt_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_ITEM_PROPERTIES_TL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_TL_PK') Then
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
  (p_item_property_id                     in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       item_property_id
      ,language
      ,source_lang
      ,default_value
      ,information_prompt
      ,label
      ,prompt_text
      ,tooltip_text
    from  hr_item_properties_tl
    where item_property_id = p_item_property_id
    and   language = p_language;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_item_property_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_item_property_id
        = hr_ipt_shd.g_old_rec.item_property_id and
        p_language
        = hr_ipt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hr_ipt_shd.g_old_rec;
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
  (p_item_property_id                     in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       item_property_id
      ,language
      ,source_lang
      ,default_value
      ,information_prompt
      ,label
      ,prompt_text
      ,tooltip_text
    from	hr_item_properties_tl
    where	item_property_id = p_item_property_id
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
    ,p_argument           => 'ITEM_PROPERTY_ID'
    ,p_argument_value     => p_item_property_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_ipt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hr_item_properties_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
Procedure add_language is
  --
  cursor csr_item_properties is
    select ipt.item_property_id
          ,ipt.default_value
          ,ipt.information_prompt
          ,ipt.label
          ,ipt.prompt_text
          ,ipt.tooltip_text
          ,ipt.source_lang
      from hr_item_properties_tl ipt
     where ipt.language = userenv('LANG');
  --
Begin
   -- 115.8 after AOL recommendation the UPDATE and DELETE statements were removed
   -- to assist performance of PERNLINS
   --
  for l_item_property in csr_item_properties loop
    hr_ipt_ins.ins_tl
      (p_language_code                => l_item_property.source_lang
      ,p_item_property_id             => l_item_property.item_property_id
      ,p_default_value                => l_item_property.default_value
      ,p_information_prompt           => l_item_property.information_prompt
      ,p_label                        => l_item_property.label
      ,p_prompt_text                  => l_item_property.prompt_text
      ,p_tooltip_text                 => l_item_property.tooltip_text
      );
  end loop;
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_item_property_id               in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_default_value                  in varchar2
  ,p_information_prompt             in varchar2
  ,p_label                          in varchar2
  ,p_prompt_text                    in varchar2
  ,p_tooltip_text                   in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.item_property_id                 := p_item_property_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.default_value                    := p_default_value;
  l_rec.information_prompt               := p_information_prompt;
  l_rec.label                            := p_label;
  l_rec.prompt_text                      := p_prompt_text;
  l_rec.tooltip_text                     := p_tooltip_text;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_ipt_shd;

/
