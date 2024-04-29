--------------------------------------------------------
--  DDL for Package Body HR_WPT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WPT_SHD" as
/* $Header: hrwptrhi.pkb 115.4 2002/12/03 14:23:01 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_wpt_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_WINDOW_PROPERTIES_TL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_WINDOW_PROPERTIES_TL_PK') Then
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
  (p_window_property_id                   in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       window_property_id
      ,language
      ,source_lang
      ,title
    from  hr_window_properties_tl
    where window_property_id = p_window_property_id
    and   language = p_language;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_window_property_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_window_property_id
        = hr_wpt_shd.g_old_rec.window_property_id and
        p_language
        = hr_wpt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hr_wpt_shd.g_old_rec;
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
  (p_window_property_id                   in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       window_property_id
      ,language
      ,source_lang
      ,title
    from	hr_window_properties_tl
    where	window_property_id = p_window_property_id
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
    ,p_argument           => 'WINDOW_PROPERTY_ID'
    ,p_argument_value     => p_window_property_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_wpt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hr_window_properties_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
Procedure add_language is
  --
  cursor csr_window_properties is
    select wpt.window_property_id
          ,wpt.title
          ,wpt.source_lang
      from hr_window_properties_tl wpt
     where wpt.language = userenv('LANG');
  --
Begin
   --
   delete from hr_window_properties_tl t
     where not exists
     (  select null
           from hr_window_properties_b b
           where b.window_property_id = t.window_property_id
     );

   update hr_window_properties_tl t
      set ( title ) =
             ( select b.title
                  from hr_window_properties_tl b
                  where b.window_property_id = t.window_property_id
                  and   b.language = t.source_lang       )
     where ( t.window_property_id,
             t.language
	   ) in
        ( select subt.window_property_id,
                 subt.language
             from hr_window_properties_tl subb, hr_window_properties_tl subt
             where subb.window_property_id = subt.window_property_id
             and subb.language = subt.source_lang
             and ( subb.title <> subt.title
             or    (subb.title is null and subt.title is not null)
             or    (subb.title is not null and subt.title is null)
		  )
	);
   --
  --
  for l_window_property in csr_window_properties loop
    hr_wpt_ins.ins_tl
      (p_language_code                => l_window_property.source_lang
      ,p_window_property_id           => l_window_property.window_property_id
      ,p_title                        => l_window_property.title
      );
  end loop;
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_window_property_id             in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_title                          in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.window_property_id               := p_window_property_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.title                            := p_title;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_wpt_shd;

/
