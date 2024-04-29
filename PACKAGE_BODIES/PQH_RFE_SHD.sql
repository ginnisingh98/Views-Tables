--------------------------------------------------------
--  DDL for Package Body PQH_RFE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RFE_SHD" as
/* $Header: pqrferhi.pkb 120.0 2005/10/06 14:54 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_rfe_shd.';  -- Global package name
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
 If (p_constraint_name = 'PQH_RATE_FACTOR_ON_ELMNTS_FK1') Then
    hr_utility.set_message(8302, 'PQH_RBC_INVALID_CRT_RT_ELMNT');
    hr_utility.raise_error;
  /*fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;*/
  ElsIf (p_constraint_name = 'PQH_RATE_FACTOR_ON_ELMNTS_FK2') Then
    hr_utility.set_message(8302, 'PQH_RBC_INVALID_CRT_RT_FACTOR');
    hr_utility.raise_error;
  /*fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;*/
  ElsIf (p_constraint_name = 'PQH_RATE_FACTOR_ON_ELMNTS_FK3') Then
    hr_utility.set_message(8302, 'PQH_RBC_INVALID_BUSINESS_GRP');
    hr_utility.raise_error;
   /* fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;*/
  ElsIf (p_constraint_name = 'PQH_RATE_FACTOR_ON_ELMNTS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
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
  (p_rate_factor_on_elmnt_id              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       rate_factor_on_elmnt_id
      ,criteria_rate_element_id
      ,criteria_rate_factor_id
      ,rate_factor_val_record_tbl
      ,rate_factor_val_record_col
      ,business_group_id
      ,legislation_code
      ,object_version_number
    from        pqh_rate_factor_on_elmnts
    where       rate_factor_on_elmnt_id = p_rate_factor_on_elmnt_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_rate_factor_on_elmnt_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_rate_factor_on_elmnt_id
        = pqh_rfe_shd.g_old_rec.rate_factor_on_elmnt_id and
        p_object_version_number
        = pqh_rfe_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_rfe_shd.g_old_rec;
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
          <> pqh_rfe_shd.g_old_rec.object_version_number) Then
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
  (p_rate_factor_on_elmnt_id              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       rate_factor_on_elmnt_id
      ,criteria_rate_element_id
      ,criteria_rate_factor_id
      ,rate_factor_val_record_tbl
      ,rate_factor_val_record_col
      ,business_group_id
      ,legislation_code
      ,object_version_number
    from        pqh_rate_factor_on_elmnts
    where       rate_factor_on_elmnt_id = p_rate_factor_on_elmnt_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RATE_FACTOR_ON_ELMNT_ID'
    ,p_argument_value     => p_rate_factor_on_elmnt_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_rfe_shd.g_old_rec;
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
      <> pqh_rfe_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_rate_factor_on_elmnts');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_rate_factor_on_elmnt_id        in number
  ,p_criteria_rate_element_id       in number
  ,p_criteria_rate_factor_id        in number
  ,p_rate_factor_val_record_tbl     in varchar2
  ,p_rate_factor_val_record_col     in varchar2
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
  l_rec.rate_factor_on_elmnt_id          := p_rate_factor_on_elmnt_id;
  l_rec.criteria_rate_element_id         := p_criteria_rate_element_id;
  l_rec.criteria_rate_factor_id          := p_criteria_rate_factor_id;
  l_rec.rate_factor_val_record_tbl       := p_rate_factor_val_record_tbl;
  l_rec.rate_factor_val_record_col       := p_rate_factor_val_record_col;
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
end pqh_rfe_shd;

/
