--------------------------------------------------------
--  DDL for Package Body PER_SST_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SST_SHD" as
/* $Header: pesstrhi.pkb 120.1 2005/06/01 12:05:44 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_sst_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_RI_SETUP_SUB_TASKS_TL_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_RI_SETUP_SUB_TASKS_TL_PK1') Then
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
  (p_setup_sub_task_code                  in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       setup_sub_task_code
      ,language
      ,source_lang
      ,setup_sub_task_name
      ,setup_sub_task_description
    from  per_ri_setup_sub_tasks_tl
    where setup_sub_task_code = p_setup_sub_task_code;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_setup_sub_task_code is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_setup_sub_task_code
        = per_sst_shd.g_old_rec.setup_sub_task_code
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
      Fetch C_Sel1 Into per_sst_shd.g_old_rec;
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
  (p_setup_sub_task_code                  in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       setup_sub_task_code
      ,language
      ,source_lang
      ,setup_sub_task_name
      ,setup_sub_task_description
    from        per_ri_setup_sub_tasks_tl
    where       setup_sub_task_code = p_setup_sub_task_code
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SETUP_SUB_TASK_CODE'
    ,p_argument_value     => p_setup_sub_task_code
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_sst_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_ri_setup_sub_tasks_tl');
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
 delete from PER_RI_SETUP_SUB_TASKS_TL T
  where not exists
    (select NULL
    from PER_RI_SETUP_SUB_TASKS B
    where B.SETUP_SUB_TASK_CODE = T.SETUP_SUB_TASK_CODE
    );

  update PER_RI_SETUP_SUB_TASKS_TL T set (
      SETUP_SUB_TASK_NAME,
      SETUP_SUB_TASK_DESCRIPTION
    ) = (select
      B.SETUP_SUB_TASK_NAME,
      B.SETUP_SUB_TASK_DESCRIPTION
    from PER_RI_SETUP_SUB_TASKS_TL B
    where B.SETUP_SUB_TASK_CODE = T.SETUP_SUB_TASK_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SETUP_SUB_TASK_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.SETUP_SUB_TASK_CODE,
      SUBT.LANGUAGE
    from PER_RI_SETUP_SUB_TASKS_TL SUBB, PER_RI_SETUP_SUB_TASKS_TL SUBT
    where SUBB.SETUP_SUB_TASK_CODE = SUBT.SETUP_SUB_TASK_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SETUP_SUB_TASK_NAME <> SUBT.SETUP_SUB_TASK_NAME
      or SUBB.SETUP_SUB_TASK_DESCRIPTION <> SUBT.SETUP_SUB_TASK_DESCRIPTION
  ));

  insert into PER_RI_SETUP_SUB_TASKS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    SETUP_SUB_TASK_NAME,
    SETUP_SUB_TASK_DESCRIPTION,
    LAST_UPDATE_DATE,
    SETUP_SUB_TASK_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.SETUP_SUB_TASK_NAME,
    B.SETUP_SUB_TASK_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.SETUP_SUB_TASK_CODE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_RI_SETUP_SUB_TASKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_RI_SETUP_SUB_TASKS_TL T
    where T.SETUP_SUB_TASK_CODE = B.SETUP_SUB_TASK_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
End add_language;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_setup_sub_task_code            in varchar2
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_setup_sub_task_name            in varchar2
  ,p_setup_sub_task_description     in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.setup_sub_task_code              := p_setup_sub_task_code;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.setup_sub_task_name              := p_setup_sub_task_name;
  l_rec.setup_sub_task_description       := p_setup_sub_task_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_sst_shd;

/
