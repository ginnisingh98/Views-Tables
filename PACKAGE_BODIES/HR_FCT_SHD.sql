--------------------------------------------------------
--  DDL for Package Body HR_FCT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FCT_SHD" as
/* $Header: hrfctrhi.pkb 115.3 2002/12/03 10:28:03 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_fct_shd.';  -- Global package name
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
  If    (p_constraint_name = 'HR_FORM_CANVASES_TL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_FORM_CANVASES_TL_PK') Then
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
  (p_form_canvas_id                       in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       form_canvas_id
      ,language
      ,source_lang
      ,user_canvas_name
      ,description
    from  hr_form_canvases_tl
    where form_canvas_id = p_form_canvas_id
    and   language = p_language;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_form_canvas_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_form_canvas_id
        = hr_fct_shd.g_old_rec.form_canvas_id and
        p_language
        = hr_fct_shd.g_old_rec.language
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
      Fetch C_Sel1 Into hr_fct_shd.g_old_rec;
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
  (p_form_canvas_id                       in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       form_canvas_id
      ,language
      ,source_lang
      ,user_canvas_name
      ,description
    from	hr_form_canvases_tl
    where	form_canvas_id = p_form_canvas_id
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
    ,p_argument           => 'FORM_CANVAS_ID'
    ,p_argument_value     => p_form_canvas_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_fct_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hr_form_canvases_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
Procedure add_language is
  --
  cursor csr_form_canvases is
    select fct.form_canvas_id
          ,fct.user_canvas_name
          ,fct.description
          ,fct.source_lang
      from hr_form_canvases_tl fct
     where fct.language = userenv('LANG');
  --
Begin
   --
   delete from hr_form_canvases_tl t
     where not exists
     (  select null
           from hr_form_canvases b
           where b.form_canvas_id = t.form_canvas_id
     );

   update hr_form_canvases_tl t
      set ( user_canvas_name,
            description ) =
             ( select b.user_canvas_name,
                      b.description
                  from hr_form_canvases_tl b
                  where b.form_canvas_id = t.form_canvas_id
                  and   b.language = t.source_lang       )
     where ( t.form_canvas_id,
             t.language
	   ) in
        ( select subt.form_canvas_id,
                 subt.language
             from hr_form_canvases_tl subb, hr_form_canvases_tl subt
             where subb.form_canvas_id = subt.form_canvas_id
             and subb.language = subt.source_lang
             and ( subb.user_canvas_name <> subt.user_canvas_name
             or    subb.description <> subt.description
             or    (subb.description is null and subt.description is not null)
             or    (subb.description is not null and subt.description is null)
		  )
	);
   --
  --
  for l_form_canvas in csr_form_canvases loop
    hr_fct_ins.ins_tl
      (p_language_code                => l_form_canvas.source_lang
      ,p_form_canvas_id               => l_form_canvas.form_canvas_id
      ,p_user_canvas_name             => l_form_canvas.user_canvas_name
      ,p_description                  => l_form_canvas.description
      );
  end loop;
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_form_canvas_id                 in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_user_canvas_name               in varchar2
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
  l_rec.form_canvas_id                   := p_form_canvas_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.user_canvas_name                 := p_user_canvas_name;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_fct_shd;

/
