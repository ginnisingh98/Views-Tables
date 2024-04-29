--------------------------------------------------------
--  DDL for Package Body HXC_ULT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULT_SHD" as
/* $Header: hxcultrhi.pkb 120.2 2005/09/23 06:33:16 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ult_shd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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

  If (p_constraint_name = 'HXC_LAYOUTS_TL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HXC_LAYOUTS_TL_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HXC_LAYOUTS_TL_UK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  (p_layout_id                            in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HXC Schema
  --
  Cursor C_Sel1 is
    select
       layout_id
      ,display_layout_name
      ,language
      ,source_lang
    from  hxc_layouts_tl
    where layout_id = p_layout_id
      AND language = p_language;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_layout_id is null OR p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_layout_id = hxc_ult_shd.g_old_rec.layout_id
    AND p_language = hxc_ult_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hxc_ult_shd.g_old_rec;
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
  (p_layout_id                            in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HXC Schema
--
  Cursor C_Sel1 is
    select
       layout_id
      ,display_layout_name
      ,language
      ,source_lang
    from	hxc_layouts_tl
    WHERE layout_id = p_layout_id
      AND language = p_language
    for	update nowait;
--
  l_proc	varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'lck';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LAYOUT_ID'
    ,p_argument_value     => p_layout_id
    );
  if g_debug then
  	hr_utility.set_location(l_proc,6);
  end if;
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_ult_shd.g_old_rec;
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
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
    fnd_message.set_token('TABLE_NAME', 'hxc_layouts_tl');
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
  delete from hxc_layouts_tl t
   where not exists
      (select null
         from hxc_layouts b
        where b.layout_id = t.layout_id
      );
  --
  update hxc_layouts_tl t
  set (display_layout_name) =
      (select b.display_layout_name
         from hxc_layouts_tl b
        where b.layout_id = t.layout_id
          and b.language = t.source_lang)
  where (t.layout_id
        ,t.language)
     in (select subt.layout_id
               ,subt.language
           from hxc_layouts_tl subb
               ,hxc_layouts_tl subt
          where subb.layout_id = subt.layout_id
            and subb.language = subt.source_lang
            and subb.display_layout_name <> subt.display_layout_name
        );
  --
  insert into hxc_layouts_tl
   (layout_id
   ,display_layout_name
   ,language
   ,source_lang
   ,last_update_date
   ,last_updated_by
   ,last_update_login
   ,created_by
   ,creation_date
   )
   select b.layout_id
         ,b.display_layout_name
         ,l.language_code
         ,b.source_lang
         ,b.last_update_date
         ,b.last_updated_by
         ,b.last_update_login
         ,b.created_by
         ,b.creation_date
    from hxc_layouts_tl b
        ,fnd_languages l
   where l.installed_flag in ('I', 'B')
     and b.language = userenv('LANG')
     and not exists
        (select null
           from hxc_layouts_tl t
          where t.layout_id = b.layout_id
            and t.language = l.language_code
        );
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_layout_id                      in number
  ,p_display_layout_name            in varchar2
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
  l_rec.layout_id                        := p_layout_id;
  l_rec.display_layout_name              := p_display_layout_name;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_ult_shd;

/
