--------------------------------------------------------
--  DDL for Package Body PER_DRX_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRX_SHD" as
/* $Header: pedrxrhi.pkb 120.0.12010000.2 2018/06/25 07:21:06 hardeeps noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_drx_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_DRT_COL_CONTEXTS_PK') Then
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
  (p_ff_column_id					in number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		ff_column_id
		,column_id
		,ff_name
		,context_name
		,column_name
		,column_phase
		,attribute
		,rule_type
		,parameter_1
		,parameter_2
		,comments
    from	per_drt_col_contexts
    where	ff_column_id = p_ff_column_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_ff_column_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_ff_column_id
        = per_drx_shd.g_old_rec.ff_column_id
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
      Fetch C_Sel1 Into per_drx_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
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
  (p_ff_column_id					in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
		ff_column_id
		,column_id
		,ff_name
		,context_name
		,column_name
		,column_phase
		,attribute
		,rule_type
		,parameter_1
		,parameter_2
		,comments
    from	per_drt_col_contexts
    where	ff_column_id = p_ff_column_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
	hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'FF_COLUMN_ID'
    ,p_argument_value     => p_ff_column_id
    );

  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_drx_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'PER_DRT_COL_CONTEXTS');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_ff_column_id					in		number
  ,p_column_id						in		number
  ,p_ff_name                 		in 		varchar2
  ,p_context_name           		in      varchar2
  ,p_column_name                    in 		varchar2
  ,p_column_phase                    in 		number
  ,p_attribute           	in      varchar2
  ,p_rule_type                 		in      varchar2
  ,p_parameter_1           		    in      varchar2
  ,p_parameter_2             		in      varchar2
  ,p_comments             			in      varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.ff_column_id               := p_ff_column_id;
  l_rec.column_id                  := p_column_id;
  l_rec.ff_name             	   := p_ff_name;
  l_rec.context_name               := p_context_name;
  l_rec.column_name                := p_column_name;
  l_rec.column_phase               := p_column_phase;
  l_rec.attribute         		   := p_attribute;
  l_rec.rule_type                  := p_rule_type;
  l_rec.parameter_1                := p_parameter_1;
  l_rec.parameter_2                := p_parameter_2;
  l_rec.comments                   := p_comments;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_drx_shd;

/
