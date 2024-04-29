--------------------------------------------------------
--  DDL for Package Body GHR_CAA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CAA_SHD" as
/* $Header: ghcaarhi.pkb 115.1 2003/01/30 19:24:47 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_caa_shd.';  -- Global package name
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
  If (p_constraint_name = 'GHR_COMPL_AGENCY_APPEALS_FK1') Then
    fnd_message.set_name('GHR', 'GHR_38700_INVALID_COMPLAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'GHR_COMPL_AGENCY_APPEALS_PK') Then
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
  (p_compl_agency_appeal_id               in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       compl_agency_appeal_id
      ,complaint_id
      ,appeal_date
      ,reason_for_appeal
      ,source_decision_date
      ,docket_num
      ,agency_recvd_req_for_files
      ,files_due
      ,files_forwd
      ,agency_brief_due
      ,agency_brief_forwd
      ,agency_recvd_appellant_brief
      ,decision_date
      ,dec_recvd_by_agency
      ,decision
      ,dec_forwd_to_org
      ,agency_rfr_suspense
      ,request_for_rfr
      ,rfr_docket_num
      ,rfr_requested_by
      ,agency_rfr_due
      ,rfr_forwd_to_org
      ,org_forwd_rfr_to_agency
      ,agency_forwd_rfr_ofo
      ,rfr_decision_date
      ,agency_recvd_rfr_dec
      ,rfr_decision_forwd_to_org
      ,rfr_decision
      ,object_version_number
    from        ghr_compl_agency_appeals
    where       compl_agency_appeal_id = p_compl_agency_appeal_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_compl_agency_appeal_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_compl_agency_appeal_id
        = ghr_caa_shd.g_old_rec.compl_agency_appeal_id and
        p_object_version_number
        = ghr_caa_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ghr_caa_shd.g_old_rec;
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
          <> ghr_caa_shd.g_old_rec.object_version_number) Then
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
  (p_compl_agency_appeal_id               in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       compl_agency_appeal_id
      ,complaint_id
      ,appeal_date
      ,reason_for_appeal
      ,source_decision_date
      ,docket_num
      ,agency_recvd_req_for_files
      ,files_due
      ,files_forwd
      ,agency_brief_due
      ,agency_brief_forwd
      ,agency_recvd_appellant_brief
      ,decision_date
      ,dec_recvd_by_agency
      ,decision
      ,dec_forwd_to_org
      ,agency_rfr_suspense
      ,request_for_rfr
      ,rfr_docket_num
      ,rfr_requested_by
      ,agency_rfr_due
      ,rfr_forwd_to_org
      ,org_forwd_rfr_to_agency
      ,agency_forwd_rfr_ofo
      ,rfr_decision_date
      ,agency_recvd_rfr_dec
      ,rfr_decision_forwd_to_org
      ,rfr_decision
      ,object_version_number
    from        ghr_compl_agency_appeals
    where       compl_agency_appeal_id = p_compl_agency_appeal_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COMPL_AGENCY_APPEAL_ID'
    ,p_argument_value     => p_compl_agency_appeal_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ghr_caa_shd.g_old_rec;
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
      <> ghr_caa_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ghr_compl_agency_appeals');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_compl_agency_appeal_id         in number
  ,p_complaint_id                   in number
  ,p_appeal_date                    in date
  ,p_reason_for_appeal              in varchar2
  ,p_source_decision_date           in date
  ,p_docket_num                     in varchar2
  ,p_agency_recvd_req_for_files     in date
  ,p_files_due                      in date
  ,p_files_forwd                    in date
  ,p_agency_brief_due               in date
  ,p_agency_brief_forwd             in date
  ,p_agency_recvd_appellant_brief   in date
  ,p_decision_date                  in date
  ,p_dec_recvd_by_agency            in date
  ,p_decision                       in varchar2
  ,p_dec_forwd_to_org               in date
  ,p_agency_rfr_suspense            in date
  ,p_request_for_rfr                in date
  ,p_rfr_docket_num                 in varchar2
  ,p_rfr_requested_by               in varchar2
  ,p_agency_rfr_due                 in date
  ,p_rfr_forwd_to_org               in date
  ,p_org_forwd_rfr_to_agency        in date
  ,p_agency_forwd_rfr_ofo           in date
  ,p_rfr_decision_date              in date
  ,p_agency_recvd_rfr_dec           in date
  ,p_rfr_decision_forwd_to_org      in date
  ,p_rfr_decision                   in varchar2
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
  l_rec.compl_agency_appeal_id           := p_compl_agency_appeal_id;
  l_rec.complaint_id                     := p_complaint_id;
  l_rec.appeal_date                      := p_appeal_date;
  l_rec.reason_for_appeal                := p_reason_for_appeal;
  l_rec.source_decision_date             := p_source_decision_date;
  l_rec.docket_num                       := p_docket_num;
  l_rec.agency_recvd_req_for_files       := p_agency_recvd_req_for_files;
  l_rec.files_due                        := p_files_due;
  l_rec.files_forwd                      := p_files_forwd;
  l_rec.agency_brief_due                 := p_agency_brief_due;
  l_rec.agency_brief_forwd               := p_agency_brief_forwd;
  l_rec.agency_recvd_appellant_brief     := p_agency_recvd_appellant_brief;
  l_rec.decision_date                    := p_decision_date;
  l_rec.dec_recvd_by_agency              := p_dec_recvd_by_agency;
  l_rec.decision                         := p_decision;
  l_rec.dec_forwd_to_org                 := p_dec_forwd_to_org;
  l_rec.agency_rfr_suspense              := p_agency_rfr_suspense;
  l_rec.request_for_rfr                  := p_request_for_rfr;
  l_rec.rfr_docket_num                   := p_rfr_docket_num;
  l_rec.rfr_requested_by                 := p_rfr_requested_by;
  l_rec.agency_rfr_due                   := p_agency_rfr_due;
  l_rec.rfr_forwd_to_org                 := p_rfr_forwd_to_org;
  l_rec.org_forwd_rfr_to_agency          := p_org_forwd_rfr_to_agency;
  l_rec.agency_forwd_rfr_ofo             := p_agency_forwd_rfr_ofo;
  l_rec.rfr_decision_date                := p_rfr_decision_date;
  l_rec.agency_recvd_rfr_dec             := p_agency_recvd_rfr_dec;
  l_rec.rfr_decision_forwd_to_org        := p_rfr_decision_forwd_to_org;
  l_rec.rfr_decision                     := p_rfr_decision;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ghr_caa_shd;

/
