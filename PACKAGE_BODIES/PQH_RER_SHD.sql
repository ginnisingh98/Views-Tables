--------------------------------------------------------
--  DDL for Package Body PQH_RER_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RER_SHD" as
/* $Header: pqrerrhi.pkb 120.0 2005/10/06 14:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_rer_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_RATE_ELEMENT_RELATIONS_FK1') Then
    hr_utility.set_message(8302, 'PQH_RBC_INVALID_CRT_RT_ELMNT');
    hr_utility.raise_error;
  /*fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;*/
  ElsIf (p_constraint_name = 'PQH_RATE_ELEMENT_RELATIONS_FK3') Then
    hr_utility.set_message(8302, 'PQH_RBC_INVALID_BUSINESS_GRP');
    hr_utility.raise_error;
 /* fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error; */
  ElsIf (p_constraint_name = 'PQH_RATE_ELEMENT_RELATIONS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PQH_RATE_ELEMENT_RELATIONS_FK4') Then
    hr_utility.set_message(8302, 'PQH_RBC_INVALID_ELEMENT_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_RATE_ELEMENT_RELATIONS_FK5') Then
    hr_utility.set_message(8302, 'PQH_RBC_INVALID_INPUT_VALUE');
    hr_utility.raise_error;
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
  (p_rate_element_relation_id             in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       rate_element_relation_id
      ,criteria_rate_element_id
      ,relation_type_cd
      ,rel_element_type_id
      ,rel_input_value_id
      ,business_group_id
      ,legislation_code
      ,object_version_number
    from        pqh_rate_element_relations
    where       rate_element_relation_id = p_rate_element_relation_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_rate_element_relation_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_rate_element_relation_id
        = pqh_rer_shd.g_old_rec.rate_element_relation_id and
        p_object_version_number
        = pqh_rer_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_rer_shd.g_old_rec;
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
          <> pqh_rer_shd.g_old_rec.object_version_number) Then
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
  (p_rate_element_relation_id             in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       rate_element_relation_id
      ,criteria_rate_element_id
      ,relation_type_cd
      ,rel_element_type_id
      ,rel_input_value_id
      ,business_group_id
      ,legislation_code
      ,object_version_number
    from        pqh_rate_element_relations
    where       rate_element_relation_id = p_rate_element_relation_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RATE_ELEMENT_RELATION_ID'
    ,p_argument_value     => p_rate_element_relation_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_rer_shd.g_old_rec;
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
      <> pqh_rer_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_rate_element_relations');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_rate_element_relation_id       in number
  ,p_criteria_rate_element_id       in number
  ,p_relation_type_cd               in varchar2
  ,p_rel_element_type_id            in number
  ,p_rel_input_value_id             in number
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
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
  l_rec.rate_element_relation_id         := p_rate_element_relation_id;
  l_rec.criteria_rate_element_id         := p_criteria_rate_element_id;
  l_rec.relation_type_cd                 := p_relation_type_cd;
  l_rec.rel_element_type_id              := p_rel_element_type_id;
  l_rec.rel_input_value_id               := p_rel_input_value_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_rer_shd;

/
