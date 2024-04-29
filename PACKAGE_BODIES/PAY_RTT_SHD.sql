--------------------------------------------------------
--  DDL for Package Body PAY_RTT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RTT_SHD" as
/* $Header: pyrttrhi.pkb 115.4 2003/02/06 17:21:56 rthirlby noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_rtt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_RUN_TYPES_TL_PK') Then
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
  (p_run_type_id                          in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       run_type_id
      ,language
      ,source_lang
      ,run_type_name
      ,shortname
    from  pay_run_types_f_tl
    where run_type_id = p_run_type_id
    and   language = p_language;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_run_type_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_run_type_id
        = pay_rtt_shd.g_old_rec.run_type_id and
        p_language
        = pay_rtt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into pay_rtt_shd.g_old_rec;
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
  (p_run_type_id                          in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       run_type_id
      ,language
      ,source_lang
      ,run_type_name
      ,shortname
    from	pay_run_types_f_tl
    where	run_type_id = p_run_type_id
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
    ,p_argument           => 'RUN_TYPE_ID'
    ,p_argument_value     => p_run_type_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_rtt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'pay_run_types_f_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure is generated using AOL's tltblgen(UNIX) program.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_language
is
begin
  delete from PAY_RUN_TYPES_F_TL T
  where not exists
    (select NULL
    from PAY_RUN_TYPES_F B
    where B.RUN_TYPE_ID = T.RUN_TYPE_ID
    );

  update PAY_RUN_TYPES_F_TL T set (
      RUN_TYPE_NAME,
      SHORTNAME
    ) = (select
      B.RUN_TYPE_NAME,
      B.SHORTNAME
    from PAY_RUN_TYPES_F_TL B
    where B.RUN_TYPE_ID = T.RUN_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RUN_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RUN_TYPE_ID,
      SUBT.LANGUAGE
    from PAY_RUN_TYPES_F_TL SUBB, PAY_RUN_TYPES_F_TL SUBT
    where SUBB.RUN_TYPE_ID = SUBT.RUN_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RUN_TYPE_NAME <> SUBT.RUN_TYPE_NAME
      or (SUBB.RUN_TYPE_NAME is null and SUBT.RUN_TYPE_NAME is not null)
      or (SUBB.RUN_TYPE_NAME is not null and SUBT.RUN_TYPE_NAME is null)
      or SUBB.SHORTNAME <> SUBT.SHORTNAME
      or (SUBB.SHORTNAME is null and SUBT.SHORTNAME is not null)
      or (SUBB.SHORTNAME is not null and SUBT.SHORTNAME is null)
  ));

  insert into PAY_RUN_TYPES_F_TL (
    RUN_TYPE_ID,
    RUN_TYPE_NAME,
    SHORTNAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.RUN_TYPE_ID,
    B.RUN_TYPE_NAME,
    B.SHORTNAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_RUN_TYPES_F_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_RUN_TYPES_F_TL T
    where T.RUN_TYPE_ID = B.RUN_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END add_language;
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_run_type_id                    in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_run_type_name                  in varchar2
  ,p_shortname                      in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.run_type_id                      := p_run_type_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.run_type_name                    := p_run_type_name;
  l_rec.shortname                        := p_shortname;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_rtt_shd;

/
