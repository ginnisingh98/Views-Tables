--------------------------------------------------------
--  DDL for Package Body BEN_BCM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BCM_SHD" as
/* $Header: bebcmrhi.pkb 115.2 2003/03/10 14:31:07 ssrayapu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_bcm_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CWB_MATRIX_PK') Then
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
  (p_cwb_matrix_id                        in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cwb_matrix_id
      ,name
      ,date_saved
      ,plan_id
      ,matrix_typ_cd
      ,person_id
      ,row_crit_cd
      ,col_crit_cd
      ,alct_by_cd
      ,business_group_id
      ,object_version_number
    from        ben_cwb_matrix
    where       cwb_matrix_id = p_cwb_matrix_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_cwb_matrix_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cwb_matrix_id
        = ben_bcm_shd.g_old_rec.cwb_matrix_id and
        p_object_version_number
        = ben_bcm_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_bcm_shd.g_old_rec;
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
          <> ben_bcm_shd.g_old_rec.object_version_number) Then
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
  (p_cwb_matrix_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       cwb_matrix_id
      ,name
      ,date_saved
      ,plan_id
      ,matrix_typ_cd
      ,person_id
      ,row_crit_cd
      ,col_crit_cd
      ,alct_by_cd
      ,business_group_id
      ,object_version_number
    from        ben_cwb_matrix
    where       cwb_matrix_id = p_cwb_matrix_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CWB_MATRIX_ID'
    ,p_argument_value     => p_cwb_matrix_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_bcm_shd.g_old_rec;
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
      <> ben_bcm_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_cwb_matrix');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cwb_matrix_id                  in number
  ,p_name                           in varchar2
  ,p_date_saved                     in date
  ,p_plan_id                        in number
  ,p_matrix_typ_cd                  in varchar2
  ,p_person_id                      in number
  ,p_row_crit_cd                    in varchar2
  ,p_col_crit_cd                    in varchar2
  ,p_alct_by_cd                     in varchar2
  ,p_business_group_id              in number
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
  l_rec.cwb_matrix_id                    := p_cwb_matrix_id;
  l_rec.name                             := p_name;
  l_rec.date_saved                       := p_date_saved;
  l_rec.plan_id                          := p_plan_id;
  l_rec.matrix_typ_cd                    := p_matrix_typ_cd;
  l_rec.person_id                        := p_person_id;
  l_rec.row_crit_cd                      := p_row_crit_cd;
  l_rec.col_crit_cd                      := p_col_crit_cd;
  l_rec.alct_by_cd                       := p_alct_by_cd;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_bcm_shd;

/
