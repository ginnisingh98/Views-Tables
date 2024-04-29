--------------------------------------------------------
--  DDL for Package Body GHR_CCL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CCL_SHD" as
/* $Header: ghcclrhi.pkb 115.1 2003/01/30 19:25:09 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_ccl_shd.';  -- Global package name
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
  If (p_constraint_name = 'GHR_COMPL_CLAIMS_FK1') Then
    fnd_message.set_name('GHR','GHR_38700_INVALID_COMPLAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'GHR_COMPL_CLAIMS_PK') Then
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
  (p_compl_claim_id                       in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       compl_claim_id
      ,complaint_id
      ,claim
      ,incident_date
      ,phase
      ,mixed_flag
      ,claim_source
      ,agency_acceptance
      ,aj_acceptance
      ,agency_appeal
      ,object_version_number
    from        ghr_compl_claims
    where       compl_claim_id = p_compl_claim_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_compl_claim_id is null
      and p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_compl_claim_id
        = ghr_ccl_shd.g_old_rec.compl_claim_id
     and p_object_version_number = ghr_ccl_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ghr_ccl_shd.g_old_rec;
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
      If (p_object_version_number
          <> ghr_ccl_shd.g_old_rec.object_version_number) Then
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
  (p_compl_claim_id                       in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       compl_claim_id
      ,complaint_id
      ,claim
      ,incident_date
      ,phase
      ,mixed_flag
      ,claim_source
      ,agency_acceptance
      ,aj_acceptance
      ,agency_appeal
      ,object_version_number
    from        ghr_compl_claims
    where       compl_claim_id = p_compl_claim_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COMPL_CLAIM_ID'
    ,p_argument_value     => p_compl_claim_id
    );

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ghr_ccl_shd.g_old_rec;
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
      <> ghr_ccl_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;

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
    fnd_message.set_token('TABLE_NAME', 'ghr_compl_claims');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_compl_claim_id                 in number
  ,p_complaint_id                   in number
  ,p_claim                          in varchar2
  ,p_incident_date                  in date
  ,p_phase                          in varchar2
  ,p_mixed_flag                     in varchar2
  ,p_claim_source                   in varchar2
  ,p_agency_acceptance              in varchar2
  ,p_aj_acceptance                  in varchar2
  ,p_agency_appeal                  in varchar2
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
  l_rec.compl_claim_id                   := p_compl_claim_id;
  l_rec.complaint_id                     := p_complaint_id;
  l_rec.claim                            := p_claim;
  l_rec.incident_date                    := p_incident_date;
  l_rec.phase                            := p_phase;
  l_rec.mixed_flag                       := p_mixed_flag;
  l_rec.claim_source                     := p_claim_source;
  l_rec.agency_acceptance                := p_agency_acceptance;
  l_rec.aj_acceptance                    := p_aj_acceptance;
  l_rec.agency_appeal                    := p_agency_appeal;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ghr_ccl_shd;

/
