--------------------------------------------------------
--  DDL for Package Body PQP_FFA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_FFA_SHD" as
/* $Header: pqffarhi.pkb 120.0 2006/04/26 23:47 pbhure noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_ffa_shd.';  -- Global package name
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

  If (p_constraint_name = 'PQP_FLXDU_FUNC_ATTRIBUTES_PK') Then
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
  (p_flxdu_func_attribute_id              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       flxdu_func_attribute_id
      ,flxdu_func_name
      ,flxdu_func_source_type
      ,flxdu_func_integrator_code
      ,flxdu_func_xml_data
      ,legislation_code
      ,description
      ,object_version_number
    from        pqp_flxdu_func_attributes
    where       flxdu_func_attribute_id = p_flxdu_func_attribute_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_flxdu_func_attribute_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_flxdu_func_attribute_id
        = pqp_ffa_shd.g_old_rec.flxdu_func_attribute_id and
        p_object_version_number
        = pqp_ffa_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_ffa_shd.g_old_rec;
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
          <> pqp_ffa_shd.g_old_rec.object_version_number) Then
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
  (p_flxdu_func_attribute_id              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       flxdu_func_attribute_id
      ,flxdu_func_name
      ,flxdu_func_source_type
      ,flxdu_func_integrator_code
      ,flxdu_func_xml_data
      ,legislation_code
      ,description
      ,object_version_number
    from        pqp_flxdu_func_attributes
    where       flxdu_func_attribute_id = p_flxdu_func_attribute_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'FLXDU_FUNC_ATTRIBUTE_ID'
    ,p_argument_value     => p_flxdu_func_attribute_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_ffa_shd.g_old_rec;
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
      <> pqp_ffa_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqp_flxdu_func_attributes');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_flxdu_func_attribute_id        in number
  ,p_flxdu_func_name                in varchar2
  ,p_flxdu_func_source_type         in varchar2
  ,p_flxdu_func_integrator_code     in varchar2
  ,p_flxdu_func_xml_data            in varchar2
  ,p_legislation_code               in varchar2
  ,p_description                    in varchar2
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
  l_rec.flxdu_func_attribute_id          := p_flxdu_func_attribute_id;
  l_rec.flxdu_func_name                  := p_flxdu_func_name;
  l_rec.flxdu_func_source_type           := p_flxdu_func_source_type;
  l_rec.flxdu_func_integrator_code       := p_flxdu_func_integrator_code;
  l_rec.flxdu_func_xml_data              := p_flxdu_func_xml_data;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.description                      := p_description;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_ffa_shd;

/
