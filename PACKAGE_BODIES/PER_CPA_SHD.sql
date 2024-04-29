--------------------------------------------------------
--  DDL for Package Body PER_CPA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPA_SHD" as
/* $Header: pecparhi.pkb 115.4 2002/12/04 15:03:48 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_cpa_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc     varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_CAGR_API_PARAMETERS_PK') Then
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
  (p_cagr_api_param_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cagr_api_param_id
      ,cagr_api_id
      ,display_name
      ,parameter_name
      ,column_type
      ,column_size
      ,uom_parameter
      ,uom_lookup
	  ,default_uom
	  ,hidden
      ,object_version_number
    from    per_cagr_api_parameters
    where    cagr_api_param_id = p_cagr_api_param_id;
--
  l_fct_ret    boolean;
--
Begin
  --
  If (p_cagr_api_param_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cagr_api_param_id
        = per_cpa_shd.g_old_rec.cagr_api_param_id and
        p_object_version_number
        = per_cpa_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_cpa_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> per_cpa_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
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
  (p_cagr_api_param_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       cagr_api_param_id
      ,cagr_api_id
      ,display_name
      ,parameter_name
      ,column_type
      ,column_size
      ,uom_parameter
      ,uom_lookup
	  ,default_uom
	  ,hidden
      ,object_version_number
    from    per_cagr_api_parameters
    where    cagr_api_param_id = p_cagr_api_param_id
    for    update nowait;
--
  l_proc    varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CAGR_API_PARAM_ID'
    ,p_argument_value     => p_cagr_api_param_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_cpa_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> per_cpa_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
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
    fnd_message.set_token('TABLE_NAME', 'per_cagr_api_parameters');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cagr_api_param_id              in number
  ,p_cagr_api_id                    in number
  ,p_display_name                   in varchar2
  ,p_parameter_name                 in varchar2
  ,p_column_type                    in varchar2
  ,p_column_size                    in number
  ,p_uom_parameter                  in varchar2
  ,p_uom_lookup                     in varchar2
  ,p_default_uom                    in varchar2
  ,p_hidden                         in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.cagr_api_param_id                := p_cagr_api_param_id;
  l_rec.cagr_api_id                      := p_cagr_api_id;
  l_rec.display_name                     := p_display_name;
  l_rec.parameter_name                   := p_parameter_name;
  l_rec.column_type                      := p_column_type;
  l_rec.column_size                      := p_column_size;
  l_rec.uom_parameter                    := p_uom_parameter;
  l_rec.uom_lookup                       := p_uom_lookup;
  l_rec.default_uom                      := p_default_uom;
  l_rec.hidden                           := p_hidden;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_cpa_shd;

/
