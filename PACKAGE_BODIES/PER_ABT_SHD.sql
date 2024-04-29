--------------------------------------------------------
--  DDL for Package Body PER_ABT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABT_SHD" as
/* $Header: peabtrhi.pkb 120.1 2005/10/10 04:12 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_ABS_ATTENDANCE_TYP_PK') Then
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
  (p_absence_attendance_type_id           in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       absence_attendance_type_id
      ,name
      ,language
      ,source_lang
    from  per_abs_attendance_types_tl
    where absence_attendance_type_id = p_absence_attendance_type_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_absence_attendance_type_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_absence_attendance_type_id
        = per_abt_shd.g_old_rec.absence_attendance_type_id and
        p_language
        = per_abt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_abt_shd.g_old_rec;
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
  (p_absence_attendance_type_id           in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       absence_attendance_type_id
      ,name
      ,language
      ,source_lang
    from        per_abs_attendance_types_tl
    where       absence_attendance_type_id = p_absence_attendance_type_id
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
    ,p_argument           => 'ABSENCE_ATTENDANCE_TYPE_ID'
    ,p_argument_value     => p_absence_attendance_type_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_abt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_abs_attendance_types_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure add_language is
begin
  --
  delete from per_abs_attendance_types_tl t
  where not exists
    (select null
    from per_absence_attendance_types b
    where b.absence_attendance_type_id = t.absence_attendance_type_id
    );

  update per_abs_attendance_types_tl t set (
      name
    ) = (select
      b.name
    from per_abs_attendance_types_tl b
    where b.absence_attendance_type_id = t.absence_attendance_type_id
    and b.language = t.source_lang)
  where (
      t.absence_attendance_type_id,
      t.language
  ) in (select
      subt.absence_attendance_type_id,
      subt.language
    from per_abs_attendance_types_tl subb, per_abs_attendance_types_tl subt
    where subb.absence_attendance_type_id = subt.absence_attendance_type_id
    and subb.language = subt.source_lang
    and (subb.name <> subt.name
  ));

  insert into per_abs_attendance_types_tl (
    absence_attendance_type_id,
    name,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    language,
    source_lang
  ) select /*+ ordered */
    b.absence_attendance_type_id,
    b.name,
    b.created_by,
    b.creation_date,
    b.last_updated_by,
    b.last_update_date,
    b.last_update_login,
    l.language_code,
    b.source_lang
  from per_abs_attendance_types_tl b, fnd_languages l
  where l.installed_flag in ('I', 'B')
  and b.language = userenv('lang')
  and not exists
    (select null
    from per_abs_attendance_types_tl t
    where t.absence_attendance_type_id = b.absence_attendance_type_id
    and t.language = l.language_code);
  --
end;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_absence_attendance_type_id     in number
  ,p_name                           in varchar2
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
  l_rec.absence_attendance_type_id       := p_absence_attendance_type_id;
  l_rec.name                             := p_name;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_abt_shd;

/
