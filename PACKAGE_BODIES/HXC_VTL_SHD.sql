--------------------------------------------------------
--  DDL for Package Body HXC_VTL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_VTL_SHD" as
/* $Header: hxcvtlrhi.pkb 120.2 2005/09/23 06:39:43 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_vtl_shd.';  -- Global package name
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
  If (p_constraint_name = 'HXC_ALIAS_VALUES_TL_PK') Then
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
  (p_alias_value_id                       in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       alias_value_id
      ,alias_value_name
      ,language
      ,source_lang
    from  hxc_alias_values_tl
    where alias_value_id = p_alias_value_id
    and   language = p_language;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_alias_value_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_alias_value_id
        = hxc_vtl_shd.g_old_rec.alias_value_id and
        p_language
        = hxc_vtl_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hxc_vtl_shd.g_old_rec;
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
  (p_alias_value_id                       in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       alias_value_id
      ,alias_value_name
      ,language
      ,source_lang
    from	hxc_alias_values_tl
    where	alias_value_id = p_alias_value_id
    and   language = p_language
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
    ,p_argument           => 'ALIAS_VALUE_ID'
    ,p_argument_value     => p_alias_value_id
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
  Fetch C_Sel1 Into hxc_vtl_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hxc_alias_values_tl');
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
  delete from hxc_alias_values_tl t
   where not exists
      (select null
         from hxc_alias_values_tl b
        where b.alias_value_id = t.alias_value_id
      );
  --
  update hxc_alias_values_tl t
  set (alias_value_name) =
      (select b.alias_value_name
         from hxc_alias_values_tl b
        where b.alias_value_id = t.alias_value_id
          and b.language = t.source_lang)
  where (t.alias_value_id
        ,t.language)
     in (select subt.alias_value_id
               ,subt.language
           from hxc_alias_values_tl subb
               ,hxc_alias_values_tl subt
          where subb.alias_value_id = subt.alias_value_id
            and subb.language = subt.source_lang
            and subb.alias_value_name <> subt.alias_value_name
        );
  --
  insert into hxc_alias_values_tl
   (alias_value_id
   ,alias_value_name
   ,language
   ,source_lang
   ,last_update_date
   ,last_updated_by
   ,last_update_login
   ,created_by
   ,creation_date
   )
   select b.alias_value_id
         ,b.alias_value_name
         ,l.language_code
         ,b.source_lang
         ,b.last_update_date
         ,b.last_updated_by
         ,b.last_update_login
         ,b.created_by
         ,b.creation_date
    from hxc_alias_values_tl b
        ,fnd_languages l
   where l.installed_flag in ('I', 'B')
     and b.language = userenv('LANG')
     and not exists
        (select null
           from hxc_alias_values_tl t
          where t.alias_value_id = b.alias_value_id
            and t.language = l.language_code
        );
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_alias_value_id                 in number
  ,p_alias_value_name               in varchar2
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
  l_rec.alias_value_id                   := p_alias_value_id;
  l_rec.alias_value_name                 := p_alias_value_name;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_vtl_shd;

/
