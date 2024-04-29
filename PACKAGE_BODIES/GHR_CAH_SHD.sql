--------------------------------------------------------
--  DDL for Package Body GHR_CAH_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CAH_SHD" as
/* $Header: ghcahrhi.pkb 115.1 2003/01/30 19:24:56 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cah_shd.';  -- Global package name
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
  If (p_constraint_name = 'GHR_COMPL_CA_HEADERS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'GHR_COMPL_CA_HEADERS_FK1') Then
    fnd_message.set_name('GHR', 'GHR_38700_INVALID_COMPLAINT');
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
  (p_compl_ca_header_id                   in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       compl_ca_header_id
      ,complaint_id
      ,ca_source
      ,last_compliance_report
      ,compliance_closed
      ,compl_docket_number
      ,appeal_docket_number
      ,pfe_docket_number
      ,pfe_received
      ,agency_brief_pfe_due
      ,agency_brief_pfe_date
      ,decision_pfe_date
      ,decision_pfe
      ,agency_recvd_pfe_decision
      ,agency_pfe_brief_forwd
      ,agency_notified_noncom
      ,comrep_noncom_req
      ,eeo_off_req_data_from_org
      ,org_forwd_data_to_eeo_off
      ,dec_implemented
      ,complaint_reinstated
      ,stage_complaint_reinstated
      ,object_version_number
    from        ghr_compl_ca_headers
    where       compl_ca_header_id = p_compl_ca_header_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_compl_ca_header_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_compl_ca_header_id
        = ghr_cah_shd.g_old_rec.compl_ca_header_id and
        p_object_version_number
        = ghr_cah_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ghr_cah_shd.g_old_rec;
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
          <> ghr_cah_shd.g_old_rec.object_version_number) Then
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
  (p_compl_ca_header_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       compl_ca_header_id
      ,complaint_id
      ,ca_source
      ,last_compliance_report
      ,compliance_closed
      ,compl_docket_number
      ,appeal_docket_number
      ,pfe_docket_number
      ,pfe_received
      ,agency_brief_pfe_due
      ,agency_brief_pfe_date
      ,decision_pfe_date
      ,decision_pfe
      ,agency_recvd_pfe_decision
      ,agency_pfe_brief_forwd
      ,agency_notified_noncom
      ,comrep_noncom_req
      ,eeo_off_req_data_from_org
      ,org_forwd_data_to_eeo_off
      ,dec_implemented
      ,complaint_reinstated
      ,stage_complaint_reinstated
      ,object_version_number
    from        ghr_compl_ca_headers
    where       compl_ca_header_id = p_compl_ca_header_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COMPL_CA_HEADER_ID'
    ,p_argument_value     => p_compl_ca_header_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ghr_cah_shd.g_old_rec;
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
      <> ghr_cah_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ghr_compl_ca_headers');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_compl_ca_header_id             in number
  ,p_complaint_id                   in number
  ,p_ca_source                      in varchar2
  ,p_last_compliance_report         in date
  ,p_compliance_closed              in date
  ,p_compl_docket_number            in varchar2
  ,p_appeal_docket_number           in varchar2
  ,p_pfe_docket_number              in varchar2
  ,p_pfe_received                   in date
  ,p_agency_brief_pfe_due           in date
  ,p_agency_brief_pfe_date          in date
  ,p_decision_pfe_date              in date
  ,p_decision_pfe                   in varchar2
  ,p_agency_recvd_pfe_decision      in date
  ,p_agency_pfe_brief_forwd         in date
  ,p_agency_notified_noncom         in date
  ,p_comrep_noncom_req              in varchar2
  ,p_eeo_off_req_data_from_org      in date
  ,p_org_forwd_data_to_eeo_off      in date
  ,p_dec_implemented                in date
  ,p_complaint_reinstated           in date
  ,p_stage_complaint_reinstated     in varchar2
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
  l_rec.compl_ca_header_id               := p_compl_ca_header_id;
  l_rec.complaint_id                     := p_complaint_id;
  l_rec.ca_source                        := p_ca_source;
  l_rec.last_compliance_report           := p_last_compliance_report;
  l_rec.compliance_closed                := p_compliance_closed;
  l_rec.compl_docket_number              := p_compl_docket_number;
  l_rec.appeal_docket_number             := p_appeal_docket_number;
  l_rec.pfe_docket_number                := p_pfe_docket_number;
  l_rec.pfe_received                     := p_pfe_received;
  l_rec.agency_brief_pfe_due             := p_agency_brief_pfe_due;
  l_rec.agency_brief_pfe_date            := p_agency_brief_pfe_date;
  l_rec.decision_pfe_date                := p_decision_pfe_date;
  l_rec.decision_pfe                     := p_decision_pfe;
  l_rec.agency_recvd_pfe_decision        := p_agency_recvd_pfe_decision;
  l_rec.agency_pfe_brief_forwd           := p_agency_pfe_brief_forwd;
  l_rec.agency_notified_noncom           := p_agency_notified_noncom;
  l_rec.comrep_noncom_req                := p_comrep_noncom_req;
  l_rec.eeo_off_req_data_from_org        := p_eeo_off_req_data_from_org;
  l_rec.org_forwd_data_to_eeo_off        := p_org_forwd_data_to_eeo_off;
  l_rec.dec_implemented                  := p_dec_implemented;
  l_rec.complaint_reinstated             := p_complaint_reinstated;
  l_rec.stage_complaint_reinstated       := p_stage_complaint_reinstated;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ghr_cah_shd;

/
