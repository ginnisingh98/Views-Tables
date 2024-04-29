--------------------------------------------------------
--  DDL for Package Body GHR_CMP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CMP_UPD" as
/* $Header: ghcmprhi.pkb 120.0 2005/05/29 02:54:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cmp_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the ghr_complaints2 Row
  --
  update ghr_complaints2
    set
     complaint_id                    = p_rec.complaint_id
    ,complainant_person_id           = p_rec.complainant_person_id
    ,business_group_id               = p_rec.business_group_id
    ,docket_number                   = p_rec.docket_number
    ,stage                           = p_rec.stage
    ,class_flag                      = p_rec.class_flag
    ,mixed_flag                      = p_rec.mixed_flag
    ,consolidated_flag               = p_rec.consolidated_flag
    ,remand_flag                     = p_rec.remand_flag
    ,active_flag                     = p_rec.active_flag
    ,information_inquiry             = p_rec.information_inquiry
    ,pcom_init                       = p_rec.pcom_init
    ,alleg_incident                  = p_rec.alleg_incident
    ,alleg_discrim_org_id            = p_rec.alleg_discrim_org_id
    ,rr_ltr_date                     = p_rec.rr_ltr_date
    ,rr_ltr_recvd                    = p_rec.rr_ltr_recvd
    ,pre_com_elec                    = p_rec.pre_com_elec
    --,adr_offered                     = p_rec.adr_offered
    ,class_agent_flag                = p_rec.class_agent_flag
    ,pre_com_desc                    = p_rec.pre_com_desc
    ,counselor_asg                   = p_rec.counselor_asg
    ,init_counselor_interview        = p_rec.init_counselor_interview
    ,anonymity_requested             = p_rec.anonymity_requested
    ,counsel_ext_ltr                 = p_rec.counsel_ext_ltr
    ,traditional_counsel_outcome     = p_rec.traditional_counsel_outcome
    ,final_interview                 = p_rec.final_interview
    ,notice_rtf_recvd                = p_rec.notice_rtf_recvd
    ,precom_closed                   = p_rec.precom_closed
    ,precom_closure_nature           = p_rec.precom_closure_nature
    ,counselor_rpt_sub               = p_rec.counselor_rpt_sub
    ,hr_office_org_id                = p_rec.hr_office_org_id
    ,eeo_office_org_id               = p_rec.eeo_office_org_id
    ,serviced_org_id                 = p_rec.serviced_org_id
    ,formal_com_filed                = p_rec.formal_com_filed
    ,ack_ltr                         = p_rec.ack_ltr
    ,clarification_ltr_date          = p_rec.clarification_ltr_date
    ,clarification_response_recvd    = p_rec.clarification_response_recvd
    ,forwarded_legal_review          = p_rec.forwarded_legal_review
    ,returned_from_legal             = p_rec.returned_from_legal
    ,letter_type                     = p_rec.letter_type
    ,letter_date                     = p_rec.letter_date
    ,letter_recvd                    = p_rec.letter_recvd
    ,investigation_source            = p_rec.investigation_source
    ,investigator_recvd_req          = p_rec.investigator_recvd_req
    ,agency_investigator_req         = p_rec.agency_investigator_req
    ,investigator_asg                = p_rec.investigator_asg
    ,investigation_start             = p_rec.investigation_start
    ,investigation_end               = p_rec.investigation_end
    ,investigation_extended          = p_rec.investigation_extended
    ,invest_extension_desc           = p_rec.invest_extension_desc
    ,agency_recvd_roi                = p_rec.agency_recvd_roi
    ,comrep_recvd_roi                = p_rec.comrep_recvd_roi
    ,options_ltr_date                = p_rec.options_ltr_date
    ,comrep_recvd_opt_ltr            = p_rec.comrep_recvd_opt_ltr
    ,comrep_opt_ltr_response         = p_rec.comrep_opt_ltr_response
    ,resolution_offer                = p_rec.resolution_offer
    ,comrep_resol_offer_recvd        = p_rec.comrep_resol_offer_recvd
    ,comrep_resol_offer_response     = p_rec.comrep_resol_offer_response
    ,comrep_resol_offer_desc         = p_rec.comrep_resol_offer_desc
    ,resol_offer_signed              = p_rec.resol_offer_signed
    ,resol_offer_desc                = p_rec.resol_offer_desc
    ,hearing_source                  = p_rec.hearing_source
    ,agency_notified_hearing         = p_rec.agency_notified_hearing
    ,eeoc_hearing_docket_num         = p_rec.eeoc_hearing_docket_num
    ,hearing_complete                = p_rec.hearing_complete
    ,aj_merit_decision_date          = p_rec.aj_merit_decision_date
    ,agency_recvd_aj_merit_dec       = p_rec.agency_recvd_aj_merit_dec
    ,aj_merit_decision               = p_rec.aj_merit_decision
    ,aj_ca_decision_date             = p_rec.aj_ca_decision_date
    ,agency_recvd_aj_ca_dec          = p_rec.agency_recvd_aj_ca_dec
    ,aj_ca_decision                  = p_rec.aj_ca_decision
    ,fad_requested                   = p_rec.fad_requested
    ,merit_fad                       = p_rec.merit_fad
    ,attorney_fees_fad               = p_rec.attorney_fees_fad
    ,comp_damages_fad                = p_rec.comp_damages_fad
    ,non_compliance_fad              = p_rec.non_compliance_fad
    ,fad_req_recvd_eeo_office        = p_rec.fad_req_recvd_eeo_office
    ,fad_req_forwd_to_agency         = p_rec.fad_req_forwd_to_agency
    ,agency_recvd_request            = p_rec.agency_recvd_request
    ,fad_due                         = p_rec.fad_due
    ,fad_date                        = p_rec.fad_date
    ,fad_decision                    = p_rec.fad_decision
   -- ,fad_final_action_closure        = p_rec.fad_final_action_closure
    ,fad_forwd_to_comrep             = p_rec.fad_forwd_to_comrep
    ,fad_recvd_by_comrep             = p_rec.fad_recvd_by_comrep
    ,fad_imp_ltr_forwd_to_org        = p_rec.fad_imp_ltr_forwd_to_org
    ,fad_decision_forwd_legal        = p_rec.fad_decision_forwd_legal
    ,fad_decision_recvd_legal        = p_rec.fad_decision_recvd_legal
    ,fa_source                       = p_rec.fa_source
    ,final_action_due                = p_rec.final_action_due
    --,final_action_nature_of_closure  = p_rec.final_action_nature_of_closure
    ,final_act_forwd_comrep          = p_rec.final_act_forwd_comrep
    ,final_act_recvd_comrep          = p_rec.final_act_recvd_comrep
    ,final_action_decision_date      = p_rec.final_action_decision_date
    ,final_action_decision           = p_rec.final_action_decision
    ,fa_imp_ltr_forwd_to_org         = p_rec.fa_imp_ltr_forwd_to_org
    ,fa_decision_forwd_legal         = p_rec.fa_decision_forwd_legal
    ,fa_decision_recvd_legal         = p_rec.fa_decision_recvd_legal
    ,civil_action_filed              = p_rec.civil_action_filed
    ,agency_closure_confirmed        = p_rec.agency_closure_confirmed
    ,consolidated_complaint_id       = p_rec.consolidated_complaint_id
    ,consolidated                    = p_rec.consolidated
    ,stage_of_consolidation          = p_rec.stage_of_consolidation
    ,comrep_notif_consolidation      = p_rec.comrep_notif_consolidation
    ,consolidation_desc              = p_rec.consolidation_desc
    ,complaint_closed                = p_rec.complaint_closed
    ,nature_of_closure               = p_rec.nature_of_closure
    ,complaint_closed_desc           = p_rec.complaint_closed_desc
    ,filed_formal_class              = p_rec.filed_formal_class
    ,forwd_eeoc                      = p_rec.forwd_eeoc
    ,aj_cert_decision_date           = p_rec.aj_cert_decision_date
    ,aj_cert_decision_recvd          = p_rec.aj_cert_decision_recvd
    ,aj_cert_decision                = p_rec.aj_cert_decision
    ,class_members_notified          = p_rec.class_members_notified
    ,number_of_complaintants         = p_rec.number_of_complaintants
    ,class_hearing                   = p_rec.class_hearing
    ,aj_dec                          = p_rec.aj_dec
    ,agency_recvd_aj_dec             = p_rec.agency_recvd_aj_dec
    ,aj_decision                     = p_rec.aj_decision
    ,object_version_number           = p_rec.object_version_number
    ,agency_brief_eeoc               = p_rec.agency_brief_eeoc
    ,agency_notif_of_civil_action    = p_rec.agency_notif_of_civil_action
    ,fad_source                      = p_rec.fad_source
    ,agency_files_forwarded_eeoc     = p_rec.agency_files_forwarded_eeoc
    ,hearing_req                     = p_rec.hearing_req
    ,agency_code                     = p_rec.agency_code
    ,audited_by                      = p_rec.audited_by
    ,record_received                 = p_rec.record_received
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    where complaint_id = p_rec.complaint_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ghr_cmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ghr_cmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ghr_cmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_effective_date               in date
  ,p_rec                          in ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  begin
    --

     ghr_cmp_rku.after_update
      (p_effective_date               => p_effective_date
      ,p_complaint_id                 => p_rec.complaint_id
      ,p_complainant_person_id        => p_rec.complainant_person_id
      ,p_business_group_id            => p_rec.business_group_id
      ,p_docket_number                => p_rec.docket_number
      ,p_stage                        => p_rec.stage
      ,p_class_flag                   => p_rec.class_flag
      ,p_mixed_flag                   => p_rec.mixed_flag
      ,p_consolidated_flag            => p_rec.consolidated_flag
      ,p_remand_flag                  => p_rec.remand_flag
      ,p_active_flag                  => p_rec.active_flag
      ,p_information_inquiry          => p_rec.information_inquiry
      ,p_pcom_init                    => p_rec.pcom_init
      ,p_alleg_incident               => p_rec.alleg_incident
      ,p_alleg_discrim_org_id         => p_rec.alleg_discrim_org_id
      ,p_rr_ltr_date                  => p_rec.rr_ltr_date
      ,p_rr_ltr_recvd                 => p_rec.rr_ltr_recvd
      ,p_pre_com_elec                 => p_rec.pre_com_elec
      --,p_adr_offered                  => p_rec.adr_offered
      ,p_class_agent_flag             => p_rec.class_agent_flag
      ,p_pre_com_desc                 => p_rec.pre_com_desc
      ,p_counselor_asg                => p_rec.counselor_asg
      ,p_init_counselor_interview     => p_rec.init_counselor_interview
      ,p_anonymity_requested          => p_rec.anonymity_requested
      ,p_counsel_ext_ltr              => p_rec.counsel_ext_ltr
      ,p_traditional_counsel_outcome  => p_rec.traditional_counsel_outcome
      ,p_final_interview              => p_rec.final_interview
      ,p_notice_rtf_recvd             => p_rec.notice_rtf_recvd
      ,p_precom_closed                => p_rec.precom_closed
      ,p_precom_closure_nature        => p_rec.precom_closure_nature
      ,p_counselor_rpt_sub            => p_rec.counselor_rpt_sub
      ,p_hr_office_org_id             => p_rec.hr_office_org_id
      ,p_eeo_office_org_id            => p_rec.eeo_office_org_id
      ,p_serviced_org_id              => p_rec.serviced_org_id
      ,p_formal_com_filed             => p_rec.formal_com_filed
      ,p_ack_ltr                      => p_rec.ack_ltr
      ,p_clarification_ltr_date       => p_rec.clarification_ltr_date
      ,p_clarification_response_recvd => p_rec.clarification_response_recvd
      ,p_forwarded_legal_review       => p_rec.forwarded_legal_review
      ,p_returned_from_legal          => p_rec.returned_from_legal
      ,p_letter_type                  => p_rec.letter_type
      ,p_letter_date                  => p_rec.letter_date
      ,p_letter_recvd                 => p_rec.letter_recvd
      ,p_investigation_source         => p_rec.investigation_source
      ,p_investigator_recvd_req       => p_rec.investigator_recvd_req
      ,p_agency_investigator_req      => p_rec.agency_investigator_req
      ,p_investigator_asg             => p_rec.investigator_asg
      ,p_investigation_start          => p_rec.investigation_start
      ,p_investigation_end            => p_rec.investigation_end
      ,p_investigation_extended       => p_rec.investigation_extended
      ,p_invest_extension_desc        => p_rec.invest_extension_desc
      ,p_agency_recvd_roi             => p_rec.agency_recvd_roi
      ,p_comrep_recvd_roi             => p_rec.comrep_recvd_roi
      ,p_options_ltr_date             => p_rec.options_ltr_date
      ,p_comrep_recvd_opt_ltr         => p_rec.comrep_recvd_opt_ltr
      ,p_comrep_opt_ltr_response      => p_rec.comrep_opt_ltr_response
      ,p_resolution_offer             => p_rec.resolution_offer
      ,p_comrep_resol_offer_recvd     => p_rec.comrep_resol_offer_recvd
      ,p_comrep_resol_offer_response  => p_rec.comrep_resol_offer_response
      ,p_comrep_resol_offer_desc      => p_rec.comrep_resol_offer_desc
      ,p_resol_offer_signed           => p_rec.resol_offer_signed
      ,p_resol_offer_desc             => p_rec.resol_offer_desc
      ,p_hearing_source               => p_rec.hearing_source
      ,p_agency_notified_hearing      => p_rec.agency_notified_hearing
      ,p_eeoc_hearing_docket_num      => p_rec.eeoc_hearing_docket_num
      ,p_hearing_complete             => p_rec.hearing_complete
      ,p_aj_merit_decision_date       => p_rec.aj_merit_decision_date
      ,p_agency_recvd_aj_merit_dec    => p_rec.agency_recvd_aj_merit_dec
      ,p_aj_merit_decision            => p_rec.aj_merit_decision
      ,p_aj_ca_decision_date          => p_rec.aj_ca_decision_date
      ,p_agency_recvd_aj_ca_dec       => p_rec.agency_recvd_aj_ca_dec
      ,p_aj_ca_decision               => p_rec.aj_ca_decision
      ,p_fad_requested                => p_rec.fad_requested
      ,p_merit_fad                    => p_rec.merit_fad
      ,p_attorney_fees_fad            => p_rec.attorney_fees_fad
      ,p_comp_damages_fad             => p_rec.comp_damages_fad
      ,p_non_compliance_fad           => p_rec.non_compliance_fad
      ,p_fad_req_recvd_eeo_office     => p_rec.fad_req_recvd_eeo_office
      ,p_fad_req_forwd_to_agency      => p_rec.fad_req_forwd_to_agency
      ,p_agency_recvd_request         => p_rec.agency_recvd_request
      ,p_fad_due                      => p_rec.fad_due
      ,p_fad_date                     => p_rec.fad_date
      ,p_fad_decision                 => p_rec.fad_decision
     -- ,p_fad_final_action_closure     => p_rec.fad_final_action_closure
      ,p_fad_forwd_to_comrep          => p_rec.fad_forwd_to_comrep
      ,p_fad_recvd_by_comrep          => p_rec.fad_recvd_by_comrep
      ,p_fad_imp_ltr_forwd_to_org     => p_rec.fad_imp_ltr_forwd_to_org
      ,p_fad_decision_forwd_legal     => p_rec.fad_decision_forwd_legal
      ,p_fad_decision_recvd_legal     => p_rec.fad_decision_recvd_legal
      ,p_fa_source                    => p_rec.fa_source
      ,p_final_action_due             => p_rec.final_action_due
      --,p_final_action_nature_of_closu => p_rec.final_action_nature_of_closure
      ,p_final_act_forwd_comrep       => p_rec.final_act_forwd_comrep
      ,p_final_act_recvd_comrep       => p_rec.final_act_recvd_comrep
      ,p_final_action_decision_date   => p_rec.final_action_decision_date
      ,p_final_action_decision        => p_rec.final_action_decision
      ,p_fa_imp_ltr_forwd_to_org      => p_rec.fa_imp_ltr_forwd_to_org
      ,p_fa_decision_forwd_legal      => p_rec.fa_decision_forwd_legal
      ,p_fa_decision_recvd_legal      => p_rec.fa_decision_recvd_legal
      ,p_civil_action_filed           => p_rec.civil_action_filed
      ,p_agency_closure_confirmed     => p_rec.agency_closure_confirmed
      ,p_consolidated_complaint_id    => p_rec.consolidated_complaint_id
      ,p_consolidated                 => p_rec.consolidated
      ,p_stage_of_consolidation       => p_rec.stage_of_consolidation
      ,p_comrep_notif_consolidation   => p_rec.comrep_notif_consolidation
      ,p_consolidation_desc           => p_rec.consolidation_desc
      ,p_complaint_closed             => p_rec.complaint_closed
      ,p_nature_of_closure            => p_rec.nature_of_closure
      ,p_complaint_closed_desc        => p_rec.complaint_closed_desc
      ,p_filed_formal_class           => p_rec.filed_formal_class
      ,p_forwd_eeoc                   => p_rec.forwd_eeoc
      ,p_aj_cert_decision_date        => p_rec.aj_cert_decision_date
      ,p_aj_cert_decision_recvd       => p_rec.aj_cert_decision_recvd
      ,p_aj_cert_decision             => p_rec.aj_cert_decision
      ,p_class_members_notified       => p_rec.class_members_notified
      ,p_number_of_complaintants      => p_rec.number_of_complaintants
      ,p_class_hearing                => p_rec.class_hearing
      ,p_aj_dec                       => p_rec.aj_dec
      ,p_agency_recvd_aj_dec          => p_rec.agency_recvd_aj_dec
      ,p_aj_decision                  => p_rec.aj_decision
      ,p_object_version_number        => p_rec.object_version_number
      ,p_agency_brief_eeoc            => p_rec.agency_brief_eeoc
      ,p_agency_notif_of_civil_action => p_rec.agency_notif_of_civil_action
      ,p_fad_source                   => p_rec.fad_source
      ,p_agency_files_forwarded_eeoc  => p_rec.agency_files_forwarded_eeoc
      ,p_hearing_req                  => p_rec.hearing_req
      ,p_agency_code                  => p_rec.agency_code
      ,p_audited_by                   => p_rec.audited_by
      ,p_record_received              => p_rec.record_received
      ,p_attribute_category           => p_rec.attribute_category
      ,p_attribute1                   => p_rec.attribute1
      ,p_attribute2                   => p_rec.attribute2
      ,p_attribute3                   => p_rec.attribute3
      ,p_attribute4                   => p_rec.attribute4
      ,p_attribute5                   => p_rec.attribute5
      ,p_attribute6                   => p_rec.attribute6
      ,p_attribute7                   => p_rec.attribute7
      ,p_attribute8                   => p_rec.attribute8
      ,p_attribute9                   => p_rec.attribute9
      ,p_attribute10                  => p_rec.attribute10
      ,p_attribute11                  => p_rec.attribute11
      ,p_attribute12                  => p_rec.attribute12
      ,p_attribute13                  => p_rec.attribute13
      ,p_attribute14                  => p_rec.attribute14
      ,p_attribute15                  => p_rec.attribute15
      ,p_attribute16                  => p_rec.attribute16
      ,p_attribute17                  => p_rec.attribute17
      ,p_attribute18                  => p_rec.attribute18
      ,p_attribute19                  => p_rec.attribute19
      ,p_attribute20                  => p_rec.attribute20
      ,p_attribute21                  => p_rec.attribute21
      ,p_attribute22                  => p_rec.attribute22
      ,p_attribute23                  => p_rec.attribute23
      ,p_attribute24                  => p_rec.attribute24
      ,p_attribute25                  => p_rec.attribute25
      ,p_attribute26                  => p_rec.attribute26
      ,p_attribute27                  => p_rec.attribute27
      ,p_attribute28                  => p_rec.attribute28
      ,p_attribute29                  => p_rec.attribute29
      ,p_attribute30                  => p_rec.attribute30
      ,p_complainant_person_id_o      => ghr_cmp_shd.g_old_rec.complainant_person_id
      ,p_business_group_id_o          => ghr_cmp_shd.g_old_rec.business_group_id
      ,p_docket_number_o              => ghr_cmp_shd.g_old_rec.docket_number
      ,p_stage_o                      => ghr_cmp_shd.g_old_rec.stage
      ,p_class_flag_o                 => ghr_cmp_shd.g_old_rec.class_flag
      ,p_mixed_flag_o                 => ghr_cmp_shd.g_old_rec.mixed_flag
      ,p_consolidated_flag_o          => ghr_cmp_shd.g_old_rec.consolidated_flag
      ,p_remand_flag_o                => ghr_cmp_shd.g_old_rec.remand_flag
      ,p_active_flag_o                => ghr_cmp_shd.g_old_rec.active_flag
      ,p_information_inquiry_o        => ghr_cmp_shd.g_old_rec.information_inquiry
      ,p_pcom_init_o                  => ghr_cmp_shd.g_old_rec.pcom_init
      ,p_alleg_incident_o             => ghr_cmp_shd.g_old_rec.alleg_incident
      ,p_alleg_discrim_org_id_o       => ghr_cmp_shd.g_old_rec.alleg_discrim_org_id
      ,p_rr_ltr_date_o                => ghr_cmp_shd.g_old_rec.rr_ltr_date
      ,p_rr_ltr_recvd_o               => ghr_cmp_shd.g_old_rec.rr_ltr_recvd
      ,p_pre_com_elec_o               => ghr_cmp_shd.g_old_rec.pre_com_elec
      --,p_adr_offered_o                => ghr_cmp_shd.g_old_rec.adr_offered
      ,p_class_agent_flag_o           => ghr_cmp_shd.g_old_rec.class_agent_flag
      ,p_pre_com_desc_o               => ghr_cmp_shd.g_old_rec.pre_com_desc
      ,p_counselor_asg_o              => ghr_cmp_shd.g_old_rec.counselor_asg
      ,p_init_counselor_interview_o   => ghr_cmp_shd.g_old_rec.init_counselor_interview
      ,p_anonymity_requested_o        => ghr_cmp_shd.g_old_rec.anonymity_requested
      ,p_counsel_ext_ltr_o            => ghr_cmp_shd.g_old_rec.counsel_ext_ltr
      ,p_traditional_counsel_outcom_o => ghr_cmp_shd.g_old_rec.traditional_counsel_outcome
      ,p_final_interview_o            => ghr_cmp_shd.g_old_rec.final_interview
      ,p_notice_rtf_recvd_o           => ghr_cmp_shd.g_old_rec.notice_rtf_recvd
      ,p_precom_closed_o              => ghr_cmp_shd.g_old_rec.precom_closed
      ,p_precom_closure_nature_o      => ghr_cmp_shd.g_old_rec.precom_closure_nature
      ,p_counselor_rpt_sub_o          => ghr_cmp_shd.g_old_rec.counselor_rpt_sub
      ,p_hr_office_org_id_o           => ghr_cmp_shd.g_old_rec.hr_office_org_id
      ,p_eeo_office_org_id_o          => ghr_cmp_shd.g_old_rec.eeo_office_org_id
      ,p_serviced_org_id_o            => ghr_cmp_shd.g_old_rec.serviced_org_id
      ,p_formal_com_filed_o           => ghr_cmp_shd.g_old_rec.formal_com_filed
      ,p_ack_ltr_o                    => ghr_cmp_shd.g_old_rec.ack_ltr
      ,p_clarification_ltr_date_o     => ghr_cmp_shd.g_old_rec.clarification_ltr_date
      ,p_clarification_response_rec_o => ghr_cmp_shd.g_old_rec.clarification_response_recvd
      ,p_forwarded_legal_review_o     => ghr_cmp_shd.g_old_rec.forwarded_legal_review
      ,p_returned_from_legal_o        => ghr_cmp_shd.g_old_rec.returned_from_legal
      ,p_letter_type_o                => ghr_cmp_shd.g_old_rec.letter_type
      ,p_letter_date_o                => ghr_cmp_shd.g_old_rec.letter_date
      ,p_letter_recvd_o               => ghr_cmp_shd.g_old_rec.letter_recvd
      ,p_investigation_source_o       => ghr_cmp_shd.g_old_rec.investigation_source
      ,p_investigator_recvd_req_o     => ghr_cmp_shd.g_old_rec.investigator_recvd_req
      ,p_agency_investigator_req_o    => ghr_cmp_shd.g_old_rec.agency_investigator_req
      ,p_investigator_asg_o           => ghr_cmp_shd.g_old_rec.investigator_asg
      ,p_investigation_start_o        => ghr_cmp_shd.g_old_rec.investigation_start
      ,p_investigation_end_o          => ghr_cmp_shd.g_old_rec.investigation_end
      ,p_investigation_extended_o     => ghr_cmp_shd.g_old_rec.investigation_extended
      ,p_invest_extension_desc_o      => ghr_cmp_shd.g_old_rec.invest_extension_desc
      ,p_agency_recvd_roi_o           => ghr_cmp_shd.g_old_rec.agency_recvd_roi
      ,p_comrep_recvd_roi_o           => ghr_cmp_shd.g_old_rec.comrep_recvd_roi
      ,p_options_ltr_date_o           => ghr_cmp_shd.g_old_rec.options_ltr_date
      ,p_comrep_recvd_opt_ltr_o       => ghr_cmp_shd.g_old_rec.comrep_recvd_opt_ltr
      ,p_comrep_opt_ltr_response_o    => ghr_cmp_shd.g_old_rec.comrep_opt_ltr_response
      ,p_resolution_offer_o           => ghr_cmp_shd.g_old_rec.resolution_offer
      ,p_comrep_resol_offer_recvd_o   => ghr_cmp_shd.g_old_rec.comrep_resol_offer_recvd
      ,p_comrep_resol_offer_respons_o => ghr_cmp_shd.g_old_rec.comrep_resol_offer_response
      ,p_comrep_resol_offer_desc_o    => ghr_cmp_shd.g_old_rec.comrep_resol_offer_desc
      ,p_resol_offer_signed_o         => ghr_cmp_shd.g_old_rec.resol_offer_signed
      ,p_resol_offer_desc_o           => ghr_cmp_shd.g_old_rec.resol_offer_desc
      ,p_hearing_source_o             => ghr_cmp_shd.g_old_rec.hearing_source
      ,p_agency_notified_hearing_o    => ghr_cmp_shd.g_old_rec.agency_notified_hearing
      ,p_eeoc_hearing_docket_num_o    => ghr_cmp_shd.g_old_rec.eeoc_hearing_docket_num
      ,p_hearing_complete_o           => ghr_cmp_shd.g_old_rec.hearing_complete
      ,p_aj_merit_decision_date_o     => ghr_cmp_shd.g_old_rec.aj_merit_decision_date
      ,p_agency_recvd_aj_merit_dec_o  => ghr_cmp_shd.g_old_rec.agency_recvd_aj_merit_dec
      ,p_aj_merit_decision_o          => ghr_cmp_shd.g_old_rec.aj_merit_decision
      ,p_aj_ca_decision_date_o        => ghr_cmp_shd.g_old_rec.aj_ca_decision_date
      ,p_agency_recvd_aj_ca_dec_o     => ghr_cmp_shd.g_old_rec.agency_recvd_aj_ca_dec
      ,p_aj_ca_decision_o             => ghr_cmp_shd.g_old_rec.aj_ca_decision
      ,p_fad_requested_o              => ghr_cmp_shd.g_old_rec.fad_requested
      ,p_merit_fad_o                  => ghr_cmp_shd.g_old_rec.merit_fad
      ,p_attorney_fees_fad_o          => ghr_cmp_shd.g_old_rec.attorney_fees_fad
      ,p_comp_damages_fad_o           => ghr_cmp_shd.g_old_rec.comp_damages_fad
      ,p_non_compliance_fad_o         => ghr_cmp_shd.g_old_rec.non_compliance_fad
      ,p_fad_req_recvd_eeo_office_o   => ghr_cmp_shd.g_old_rec.fad_req_recvd_eeo_office
      ,p_fad_req_forwd_to_agency_o    => ghr_cmp_shd.g_old_rec.fad_req_forwd_to_agency
      ,p_agency_recvd_request_o       => ghr_cmp_shd.g_old_rec.agency_recvd_request
      ,p_fad_due_o                    => ghr_cmp_shd.g_old_rec.fad_due
      ,p_fad_date_o                   => ghr_cmp_shd.g_old_rec.fad_date
      ,p_fad_decision_o               => ghr_cmp_shd.g_old_rec.fad_decision
     -- ,p_fad_final_action_closure_o   => ghr_cmp_shd.g_old_rec.fad_final_action_closure
      ,p_fad_forwd_to_comrep_o        => ghr_cmp_shd.g_old_rec.fad_forwd_to_comrep
      ,p_fad_recvd_by_comrep_o        => ghr_cmp_shd.g_old_rec.fad_recvd_by_comrep
      ,p_fad_imp_ltr_forwd_to_org_o   => ghr_cmp_shd.g_old_rec.fad_imp_ltr_forwd_to_org
      ,p_fad_decision_forwd_legal_o   => ghr_cmp_shd.g_old_rec.fad_decision_forwd_legal
      ,p_fad_decision_recvd_legal_o   => ghr_cmp_shd.g_old_rec.fad_decision_recvd_legal
      ,p_fa_source_o                  => ghr_cmp_shd.g_old_rec.fa_source
      ,p_final_action_due_o           => ghr_cmp_shd.g_old_rec.final_action_due
      --,p_final_action_nature_of_clo_o => ghr_cmp_shd.g_old_rec.final_action_nature_of_closure
      ,p_final_act_forwd_comrep_o     => ghr_cmp_shd.g_old_rec.final_act_forwd_comrep
      ,p_final_act_recvd_comrep_o     => ghr_cmp_shd.g_old_rec.final_act_recvd_comrep
      ,p_final_action_decision_date_o => ghr_cmp_shd.g_old_rec.final_action_decision_date
      ,p_final_action_decision_o      => ghr_cmp_shd.g_old_rec.final_action_decision
      ,p_fa_imp_ltr_forwd_to_org_o    => ghr_cmp_shd.g_old_rec.fa_imp_ltr_forwd_to_org
      ,p_fa_decision_forwd_legal_o    => ghr_cmp_shd.g_old_rec.fa_decision_forwd_legal
      ,p_fa_decision_recvd_legal_o    => ghr_cmp_shd.g_old_rec.fa_decision_recvd_legal
      ,p_civil_action_filed_o         => ghr_cmp_shd.g_old_rec.civil_action_filed
      ,p_agency_closure_confirmed_o   => ghr_cmp_shd.g_old_rec.agency_closure_confirmed
      ,p_consolidated_complaint_id_o  => ghr_cmp_shd.g_old_rec.consolidated_complaint_id
      ,p_consolidated_o               => ghr_cmp_shd.g_old_rec.consolidated
      ,p_stage_of_consolidation_o     => ghr_cmp_shd.g_old_rec.stage_of_consolidation
      ,p_comrep_notif_consolidation_o => ghr_cmp_shd.g_old_rec.comrep_notif_consolidation
      ,p_consolidation_desc_o         => ghr_cmp_shd.g_old_rec.consolidation_desc
      ,p_complaint_closed_o           => ghr_cmp_shd.g_old_rec.complaint_closed
      ,p_nature_of_closure_o          => ghr_cmp_shd.g_old_rec.nature_of_closure
      ,p_complaint_closed_desc_o      => ghr_cmp_shd.g_old_rec.complaint_closed_desc
      ,p_filed_formal_class_o         => ghr_cmp_shd.g_old_rec.filed_formal_class
      ,p_forwd_eeoc_o                 => ghr_cmp_shd.g_old_rec.forwd_eeoc
      ,p_aj_cert_decision_date_o      => ghr_cmp_shd.g_old_rec.aj_cert_decision_date
      ,p_aj_cert_decision_recvd_o     => ghr_cmp_shd.g_old_rec.aj_cert_decision_recvd
      ,p_aj_cert_decision_o           => ghr_cmp_shd.g_old_rec.aj_cert_decision
      ,p_class_members_notified_o     => ghr_cmp_shd.g_old_rec.class_members_notified
      ,p_number_of_complaintants_o    => ghr_cmp_shd.g_old_rec.number_of_complaintants
      ,p_class_hearing_o              => ghr_cmp_shd.g_old_rec.class_hearing
      ,p_aj_dec_o                     => ghr_cmp_shd.g_old_rec.aj_dec
      ,p_agency_recvd_aj_dec_o        => ghr_cmp_shd.g_old_rec.agency_recvd_aj_dec
      ,p_aj_decision_o                => ghr_cmp_shd.g_old_rec.aj_decision
      ,p_object_version_number_o      => ghr_cmp_shd.g_old_rec.object_version_number
      ,p_agency_brief_eeoc_o          => ghr_cmp_shd.g_old_rec.agency_brief_eeoc
      ,p_agency_notif_of_civil_acti_o => ghr_cmp_shd.g_old_rec.agency_notif_of_civil_action
      ,p_fad_source_o                 => ghr_cmp_shd.g_old_rec.fad_source
      ,p_agency_files_forwarded_eeo_o => ghr_cmp_shd.g_old_rec.agency_files_forwarded_eeoc
      ,p_hearing_req_o                => ghr_cmp_shd.g_old_rec.hearing_req
      ,p_agency_code_o                => ghr_cmp_shd.g_old_rec.agency_code
      ,p_audited_by_o                 => ghr_cmp_shd.g_old_rec.audited_by
      ,p_record_received_o            => ghr_cmp_shd.g_old_rec.record_received
      ,p_attribute_category_o         => ghr_cmp_shd.g_old_rec.attribute_category
      ,p_attribute1_o                 => ghr_cmp_shd.g_old_rec.attribute1
      ,p_attribute2_o                 => ghr_cmp_shd.g_old_rec.attribute2
      ,p_attribute3_o                 => ghr_cmp_shd.g_old_rec.attribute3
      ,p_attribute4_o                 => ghr_cmp_shd.g_old_rec.attribute4
      ,p_attribute5_o                 => ghr_cmp_shd.g_old_rec.attribute5
      ,p_attribute6_o                 => ghr_cmp_shd.g_old_rec.attribute6
      ,p_attribute7_o                 => ghr_cmp_shd.g_old_rec.attribute7
      ,p_attribute8_o                 => ghr_cmp_shd.g_old_rec.attribute8
      ,p_attribute9_o                 => ghr_cmp_shd.g_old_rec.attribute9
      ,p_attribute10_o                => ghr_cmp_shd.g_old_rec.attribute10
      ,p_attribute11_o                => ghr_cmp_shd.g_old_rec.attribute11
      ,p_attribute12_o                => ghr_cmp_shd.g_old_rec.attribute12
      ,p_attribute13_o                => ghr_cmp_shd.g_old_rec.attribute13
      ,p_attribute14_o                => ghr_cmp_shd.g_old_rec.attribute14
      ,p_attribute15_o                => ghr_cmp_shd.g_old_rec.attribute15
      ,p_attribute16_o                => ghr_cmp_shd.g_old_rec.attribute16
      ,p_attribute17_o                => ghr_cmp_shd.g_old_rec.attribute17
      ,p_attribute18_o                => ghr_cmp_shd.g_old_rec.attribute18
      ,p_attribute19_o                => ghr_cmp_shd.g_old_rec.attribute19
      ,p_attribute20_o                => ghr_cmp_shd.g_old_rec.attribute20
      ,p_attribute21_o                => ghr_cmp_shd.g_old_rec.attribute21
      ,p_attribute22_o                => ghr_cmp_shd.g_old_rec.attribute22
      ,p_attribute23_o                => ghr_cmp_shd.g_old_rec.attribute23
      ,p_attribute24_o                => ghr_cmp_shd.g_old_rec.attribute24
      ,p_attribute25_o                => ghr_cmp_shd.g_old_rec.attribute25
      ,p_attribute26_o                => ghr_cmp_shd.g_old_rec.attribute26
      ,p_attribute27_o                => ghr_cmp_shd.g_old_rec.attribute27
      ,p_attribute28_o                => ghr_cmp_shd.g_old_rec.attribute28
      ,p_attribute29_o                => ghr_cmp_shd.g_old_rec.attribute29
      ,p_attribute30_o                => ghr_cmp_shd.g_old_rec.attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'GHR_COMPLAINTS2'
        ,p_hook_type   => 'AU');
      --

  end;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy ghr_cmp_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.complainant_person_id = hr_api.g_number) then
    p_rec.complainant_person_id :=
    ghr_cmp_shd.g_old_rec.complainant_person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ghr_cmp_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.docket_number = hr_api.g_varchar2) then
    p_rec.docket_number :=
    ghr_cmp_shd.g_old_rec.docket_number;
  End If;
  If (p_rec.stage = hr_api.g_varchar2) then
    p_rec.stage :=
    ghr_cmp_shd.g_old_rec.stage;
  End If;
  If (p_rec.class_flag = hr_api.g_varchar2) then
    p_rec.class_flag :=
    ghr_cmp_shd.g_old_rec.class_flag;
  End If;
  If (p_rec.mixed_flag = hr_api.g_varchar2) then
    p_rec.mixed_flag :=
    ghr_cmp_shd.g_old_rec.mixed_flag;
  End If;
  If (p_rec.consolidated_flag = hr_api.g_varchar2) then
    p_rec.consolidated_flag :=
    ghr_cmp_shd.g_old_rec.consolidated_flag;
  End If;
  If (p_rec.remand_flag = hr_api.g_varchar2) then
    p_rec.remand_flag :=
    ghr_cmp_shd.g_old_rec.remand_flag;
  End If;
  If (p_rec.active_flag = hr_api.g_varchar2) then
    p_rec.active_flag :=
    ghr_cmp_shd.g_old_rec.active_flag;
  End If;
  If (p_rec.information_inquiry = hr_api.g_date) then
    p_rec.information_inquiry :=
    ghr_cmp_shd.g_old_rec.information_inquiry;
  End If;
  If (p_rec.pcom_init = hr_api.g_date) then
    p_rec.pcom_init :=
    ghr_cmp_shd.g_old_rec.pcom_init;
  End If;
  If (p_rec.alleg_incident = hr_api.g_date) then
    p_rec.alleg_incident :=
    ghr_cmp_shd.g_old_rec.alleg_incident;
  End If;
  If (p_rec.alleg_discrim_org_id = hr_api.g_number) then
    p_rec.alleg_discrim_org_id :=
    ghr_cmp_shd.g_old_rec.alleg_discrim_org_id;
  End If;
  If (p_rec.rr_ltr_date = hr_api.g_date) then
    p_rec.rr_ltr_date :=
    ghr_cmp_shd.g_old_rec.rr_ltr_date;
  End If;
  If (p_rec.rr_ltr_recvd = hr_api.g_date) then
    p_rec.rr_ltr_recvd :=
    ghr_cmp_shd.g_old_rec.rr_ltr_recvd;
  End If;
  If (p_rec.pre_com_elec = hr_api.g_varchar2) then
    p_rec.pre_com_elec :=
    ghr_cmp_shd.g_old_rec.pre_com_elec;
  End If;
/*
  If (p_rec.adr_offered = hr_api.g_varchar2) then
    p_rec.adr_offered :=
    ghr_cmp_shd.g_old_rec.adr_offered;
  End If;
*/
  If (p_rec.class_agent_flag = hr_api.g_varchar2) then
    p_rec.class_agent_flag :=
    ghr_cmp_shd.g_old_rec.class_agent_flag;
  End If;
  If (p_rec.pre_com_desc = hr_api.g_varchar2) then
    p_rec.pre_com_desc :=
    ghr_cmp_shd.g_old_rec.pre_com_desc;
  End If;
  If (p_rec.counselor_asg = hr_api.g_date) then
    p_rec.counselor_asg :=
    ghr_cmp_shd.g_old_rec.counselor_asg;
  End If;
  If (p_rec.init_counselor_interview = hr_api.g_date) then
    p_rec.init_counselor_interview :=
    ghr_cmp_shd.g_old_rec.init_counselor_interview;
  End If;
  If (p_rec.anonymity_requested = hr_api.g_varchar2) then
    p_rec.anonymity_requested :=
    ghr_cmp_shd.g_old_rec.anonymity_requested;
  End If;
  If (p_rec.counsel_ext_ltr = hr_api.g_date) then
    p_rec.counsel_ext_ltr :=
    ghr_cmp_shd.g_old_rec.counsel_ext_ltr;
  End If;
  If (p_rec.traditional_counsel_outcome = hr_api.g_varchar2) then
    p_rec.traditional_counsel_outcome :=
    ghr_cmp_shd.g_old_rec.traditional_counsel_outcome;
  End If;
  If (p_rec.final_interview = hr_api.g_date) then
    p_rec.final_interview :=
    ghr_cmp_shd.g_old_rec.final_interview;
  End If;
  If (p_rec.notice_rtf_recvd = hr_api.g_date) then
    p_rec.notice_rtf_recvd :=
    ghr_cmp_shd.g_old_rec.notice_rtf_recvd;
  End If;
  If (p_rec.precom_closed = hr_api.g_date) then
    p_rec.precom_closed :=
    ghr_cmp_shd.g_old_rec.precom_closed;
  End If;
  If (p_rec.precom_closure_nature = hr_api.g_varchar2) then
    p_rec.precom_closure_nature :=
    ghr_cmp_shd.g_old_rec.precom_closure_nature;
  End If;
  If (p_rec.counselor_rpt_sub = hr_api.g_date) then
    p_rec.counselor_rpt_sub :=
    ghr_cmp_shd.g_old_rec.counselor_rpt_sub;
  End If;
  If (p_rec.hr_office_org_id = hr_api.g_number) then
    p_rec.hr_office_org_id :=
    ghr_cmp_shd.g_old_rec.hr_office_org_id;
  End If;
  If (p_rec.eeo_office_org_id = hr_api.g_number) then
    p_rec.eeo_office_org_id :=
    ghr_cmp_shd.g_old_rec.eeo_office_org_id;
  End If;
  If (p_rec.serviced_org_id = hr_api.g_number) then
    p_rec.serviced_org_id :=
    ghr_cmp_shd.g_old_rec.serviced_org_id;
  End If;
  If (p_rec.formal_com_filed = hr_api.g_date) then
    p_rec.formal_com_filed :=
    ghr_cmp_shd.g_old_rec.formal_com_filed;
  End If;
  If (p_rec.ack_ltr = hr_api.g_date) then
    p_rec.ack_ltr :=
    ghr_cmp_shd.g_old_rec.ack_ltr;
  End If;
  If (p_rec.clarification_ltr_date = hr_api.g_date) then
    p_rec.clarification_ltr_date :=
    ghr_cmp_shd.g_old_rec.clarification_ltr_date;
  End If;
  If (p_rec.clarification_response_recvd = hr_api.g_date) then
    p_rec.clarification_response_recvd :=
    ghr_cmp_shd.g_old_rec.clarification_response_recvd;
  End If;
  If (p_rec.forwarded_legal_review = hr_api.g_date) then
    p_rec.forwarded_legal_review :=
    ghr_cmp_shd.g_old_rec.forwarded_legal_review;
  End If;
  If (p_rec.returned_from_legal = hr_api.g_date) then
    p_rec.returned_from_legal :=
    ghr_cmp_shd.g_old_rec.returned_from_legal;
  End If;
  If (p_rec.letter_type = hr_api.g_varchar2) then
    p_rec.letter_type :=
    ghr_cmp_shd.g_old_rec.letter_type;
  End If;
  If (p_rec.letter_date = hr_api.g_date) then
    p_rec.letter_date :=
    ghr_cmp_shd.g_old_rec.letter_date;
  End If;
  If (p_rec.letter_recvd = hr_api.g_date) then
    p_rec.letter_recvd :=
    ghr_cmp_shd.g_old_rec.letter_recvd;
  End If;
  If (p_rec.investigation_source = hr_api.g_varchar2) then
    p_rec.investigation_source :=
    ghr_cmp_shd.g_old_rec.investigation_source;
  End If;
  If (p_rec.investigator_recvd_req = hr_api.g_date) then
    p_rec.investigator_recvd_req :=
    ghr_cmp_shd.g_old_rec.investigator_recvd_req;
  End If;
  If (p_rec.agency_investigator_req = hr_api.g_date) then
    p_rec.agency_investigator_req :=
    ghr_cmp_shd.g_old_rec.agency_investigator_req;
  End If;
  If (p_rec.investigator_asg = hr_api.g_date) then
    p_rec.investigator_asg :=
    ghr_cmp_shd.g_old_rec.investigator_asg;
  End If;
  If (p_rec.investigation_start = hr_api.g_date) then
    p_rec.investigation_start :=
    ghr_cmp_shd.g_old_rec.investigation_start;
  End If;
  If (p_rec.investigation_end = hr_api.g_date) then
    p_rec.investigation_end :=
    ghr_cmp_shd.g_old_rec.investigation_end;
  End If;
  If (p_rec.investigation_extended = hr_api.g_date) then
    p_rec.investigation_extended :=
    ghr_cmp_shd.g_old_rec.investigation_extended;
  End If;
  If (p_rec.invest_extension_desc = hr_api.g_varchar2) then
    p_rec.invest_extension_desc :=
    ghr_cmp_shd.g_old_rec.invest_extension_desc;
  End If;
  If (p_rec.agency_recvd_roi = hr_api.g_date) then
    p_rec.agency_recvd_roi :=
    ghr_cmp_shd.g_old_rec.agency_recvd_roi;
  End If;
  If (p_rec.comrep_recvd_roi = hr_api.g_date) then
    p_rec.comrep_recvd_roi :=
    ghr_cmp_shd.g_old_rec.comrep_recvd_roi;
  End If;
  If (p_rec.options_ltr_date = hr_api.g_date) then
    p_rec.options_ltr_date :=
    ghr_cmp_shd.g_old_rec.options_ltr_date;
  End If;
  If (p_rec.comrep_recvd_opt_ltr = hr_api.g_date) then
    p_rec.comrep_recvd_opt_ltr :=
    ghr_cmp_shd.g_old_rec.comrep_recvd_opt_ltr;
  End If;
  If (p_rec.comrep_opt_ltr_response = hr_api.g_varchar2) then
    p_rec.comrep_opt_ltr_response :=
    ghr_cmp_shd.g_old_rec.comrep_opt_ltr_response;
  End If;
  If (p_rec.resolution_offer = hr_api.g_date) then
    p_rec.resolution_offer :=
    ghr_cmp_shd.g_old_rec.resolution_offer;
  End If;
  If (p_rec.comrep_resol_offer_recvd = hr_api.g_date) then
    p_rec.comrep_resol_offer_recvd :=
    ghr_cmp_shd.g_old_rec.comrep_resol_offer_recvd;
  End If;
  If (p_rec.comrep_resol_offer_response = hr_api.g_date) then
    p_rec.comrep_resol_offer_response :=
    ghr_cmp_shd.g_old_rec.comrep_resol_offer_response;
  End If;
  If (p_rec.comrep_resol_offer_desc = hr_api.g_varchar2) then
    p_rec.comrep_resol_offer_desc :=
    ghr_cmp_shd.g_old_rec.comrep_resol_offer_desc;
  End If;
  If (p_rec.resol_offer_signed = hr_api.g_date) then
    p_rec.resol_offer_signed :=
    ghr_cmp_shd.g_old_rec.resol_offer_signed;
  End If;
  If (p_rec.resol_offer_desc = hr_api.g_varchar2) then
    p_rec.resol_offer_desc :=
    ghr_cmp_shd.g_old_rec.resol_offer_desc;
  End If;
  If (p_rec.hearing_source = hr_api.g_varchar2) then
    p_rec.hearing_source :=
    ghr_cmp_shd.g_old_rec.hearing_source;
  End If;
  If (p_rec.agency_notified_hearing = hr_api.g_date) then
    p_rec.agency_notified_hearing :=
    ghr_cmp_shd.g_old_rec.agency_notified_hearing;
  End If;
  If (p_rec.eeoc_hearing_docket_num = hr_api.g_varchar2) then
    p_rec.eeoc_hearing_docket_num :=
    ghr_cmp_shd.g_old_rec.eeoc_hearing_docket_num;
  End If;
  If (p_rec.hearing_complete = hr_api.g_date) then
    p_rec.hearing_complete :=
    ghr_cmp_shd.g_old_rec.hearing_complete;
  End If;
  If (p_rec.aj_merit_decision_date = hr_api.g_date) then
    p_rec.aj_merit_decision_date :=
    ghr_cmp_shd.g_old_rec.aj_merit_decision_date;
  End If;
  If (p_rec.agency_recvd_aj_merit_dec = hr_api.g_date) then
    p_rec.agency_recvd_aj_merit_dec :=
    ghr_cmp_shd.g_old_rec.agency_recvd_aj_merit_dec;
  End If;
  If (p_rec.aj_merit_decision = hr_api.g_varchar2) then
    p_rec.aj_merit_decision :=
    ghr_cmp_shd.g_old_rec.aj_merit_decision;
  End If;
  If (p_rec.aj_ca_decision_date = hr_api.g_date) then
    p_rec.aj_ca_decision_date :=
    ghr_cmp_shd.g_old_rec.aj_ca_decision_date;
  End If;
  If (p_rec.agency_recvd_aj_ca_dec = hr_api.g_date) then
    p_rec.agency_recvd_aj_ca_dec :=
    ghr_cmp_shd.g_old_rec.agency_recvd_aj_ca_dec;
  End If;
  If (p_rec.aj_ca_decision = hr_api.g_varchar2) then
    p_rec.aj_ca_decision :=
    ghr_cmp_shd.g_old_rec.aj_ca_decision;
  End If;
  If (p_rec.fad_requested = hr_api.g_date) then
    p_rec.fad_requested :=
    ghr_cmp_shd.g_old_rec.fad_requested;
  End If;
  If (p_rec.merit_fad = hr_api.g_varchar2) then
    p_rec.merit_fad :=
    ghr_cmp_shd.g_old_rec.merit_fad;
  End If;
  If (p_rec.attorney_fees_fad = hr_api.g_varchar2) then
    p_rec.attorney_fees_fad :=
    ghr_cmp_shd.g_old_rec.attorney_fees_fad;
  End If;
  If (p_rec.comp_damages_fad = hr_api.g_varchar2) then
    p_rec.comp_damages_fad :=
    ghr_cmp_shd.g_old_rec.comp_damages_fad;
  End If;
  If (p_rec.non_compliance_fad = hr_api.g_varchar2) then
    p_rec.non_compliance_fad :=
    ghr_cmp_shd.g_old_rec.non_compliance_fad;
  End If;
  If (p_rec.fad_req_recvd_eeo_office = hr_api.g_date) then
    p_rec.fad_req_recvd_eeo_office :=
    ghr_cmp_shd.g_old_rec.fad_req_recvd_eeo_office;
  End If;
  If (p_rec.fad_req_forwd_to_agency = hr_api.g_date) then
    p_rec.fad_req_forwd_to_agency :=
    ghr_cmp_shd.g_old_rec.fad_req_forwd_to_agency;
  End If;
  If (p_rec.agency_recvd_request = hr_api.g_date) then
    p_rec.agency_recvd_request :=
    ghr_cmp_shd.g_old_rec.agency_recvd_request;
  End If;
  If (p_rec.fad_due = hr_api.g_date) then
    p_rec.fad_due :=
    ghr_cmp_shd.g_old_rec.fad_due;
  End If;
  If (p_rec.fad_date = hr_api.g_date) then
    p_rec.fad_date :=
    ghr_cmp_shd.g_old_rec.fad_date;
  End If;
  If (p_rec.fad_decision = hr_api.g_varchar2) then
    p_rec.fad_decision :=
    ghr_cmp_shd.g_old_rec.fad_decision;
  End If;
/*
  If (p_rec.fad_final_action_closure = hr_api.g_varchar2) then
    p_rec.fad_final_action_closure :=
    ghr_cmp_shd.g_old_rec.fad_final_action_closure;
  End If;
*/
  If (p_rec.fad_forwd_to_comrep = hr_api.g_date) then
    p_rec.fad_forwd_to_comrep :=
    ghr_cmp_shd.g_old_rec.fad_forwd_to_comrep;
  End If;
  If (p_rec.fad_recvd_by_comrep = hr_api.g_date) then
    p_rec.fad_recvd_by_comrep :=
    ghr_cmp_shd.g_old_rec.fad_recvd_by_comrep;
  End If;
  If (p_rec.fad_imp_ltr_forwd_to_org = hr_api.g_date) then
    p_rec.fad_imp_ltr_forwd_to_org :=
    ghr_cmp_shd.g_old_rec.fad_imp_ltr_forwd_to_org;
  End If;
  If (p_rec.fad_decision_forwd_legal = hr_api.g_date) then
    p_rec.fad_decision_forwd_legal :=
    ghr_cmp_shd.g_old_rec.fad_decision_forwd_legal;
  End If;
  If (p_rec.fad_decision_recvd_legal = hr_api.g_date) then
    p_rec.fad_decision_recvd_legal :=
    ghr_cmp_shd.g_old_rec.fad_decision_recvd_legal;
  End If;
  If (p_rec.fa_source = hr_api.g_varchar2) then
    p_rec.fa_source :=
    ghr_cmp_shd.g_old_rec.fa_source;
  End If;
  If (p_rec.final_action_due = hr_api.g_date) then
    p_rec.final_action_due :=
    ghr_cmp_shd.g_old_rec.final_action_due;
  End If;
/*
  If (p_rec.final_action_nature_of_closure = hr_api.g_varchar2) then
    p_rec.final_action_nature_of_closure :=
    ghr_cmp_shd.g_old_rec.final_action_nature_of_closure;
  End If;
*/
  If (p_rec.final_act_forwd_comrep = hr_api.g_date) then
    p_rec.final_act_forwd_comrep :=
    ghr_cmp_shd.g_old_rec.final_act_forwd_comrep;
  End If;
  If (p_rec.final_act_recvd_comrep = hr_api.g_date) then
    p_rec.final_act_recvd_comrep :=
    ghr_cmp_shd.g_old_rec.final_act_recvd_comrep;
  End If;
   If (p_rec.final_action_decision_date = hr_api.g_date) then
    p_rec.final_action_decision_date :=
    ghr_cmp_shd.g_old_rec.final_action_decision_date;
  End If;
    If (p_rec.final_action_decision = hr_api.g_varchar2) then
    p_rec.final_action_decision :=
    ghr_cmp_shd.g_old_rec.final_action_decision;
  End If;
  If (p_rec.fa_imp_ltr_forwd_to_org = hr_api.g_date) then
    p_rec.fa_imp_ltr_forwd_to_org :=
    ghr_cmp_shd.g_old_rec.fa_imp_ltr_forwd_to_org;
  End If;
  If (p_rec.fa_decision_forwd_legal = hr_api.g_date) then
    p_rec.fa_decision_forwd_legal :=
    ghr_cmp_shd.g_old_rec.fa_decision_forwd_legal;
  End If;
  If (p_rec.fa_decision_recvd_legal = hr_api.g_date) then
    p_rec.fa_decision_recvd_legal :=
    ghr_cmp_shd.g_old_rec.fa_decision_recvd_legal;
  End If;
  If (p_rec.civil_action_filed = hr_api.g_date) then
    p_rec.civil_action_filed :=
    ghr_cmp_shd.g_old_rec.civil_action_filed;
  End If;
  If (p_rec.agency_closure_confirmed = hr_api.g_date) then
    p_rec.agency_closure_confirmed :=
    ghr_cmp_shd.g_old_rec.agency_closure_confirmed;
  End If;
  If (p_rec.consolidated_complaint_id = hr_api.g_number) then
    p_rec.consolidated_complaint_id :=
    ghr_cmp_shd.g_old_rec.consolidated_complaint_id;
  End If;
  If (p_rec.consolidated = hr_api.g_date) then
    p_rec.consolidated :=
    ghr_cmp_shd.g_old_rec.consolidated;
  End If;
  If (p_rec.stage_of_consolidation = hr_api.g_varchar2) then
    p_rec.stage_of_consolidation :=
    ghr_cmp_shd.g_old_rec.stage_of_consolidation;
  End If;
  If (p_rec.comrep_notif_consolidation = hr_api.g_date) then
    p_rec.comrep_notif_consolidation :=
    ghr_cmp_shd.g_old_rec.comrep_notif_consolidation;
  End If;
  If (p_rec.consolidation_desc = hr_api.g_varchar2) then
    p_rec.consolidation_desc :=
    ghr_cmp_shd.g_old_rec.consolidation_desc;
  End If;
  If (p_rec.complaint_closed = hr_api.g_date) then
    p_rec.complaint_closed :=
    ghr_cmp_shd.g_old_rec.complaint_closed;
  End If;
  If (p_rec.nature_of_closure = hr_api.g_varchar2) then
    p_rec.nature_of_closure :=
    ghr_cmp_shd.g_old_rec.nature_of_closure;
  End If;
  If (p_rec.complaint_closed_desc = hr_api.g_varchar2) then
    p_rec.complaint_closed_desc :=
    ghr_cmp_shd.g_old_rec.complaint_closed_desc;
  End If;
  If (p_rec.filed_formal_class = hr_api.g_date) then
    p_rec.filed_formal_class :=
    ghr_cmp_shd.g_old_rec.filed_formal_class;
  End If;
  If (p_rec.forwd_eeoc = hr_api.g_date) then
    p_rec.forwd_eeoc :=
    ghr_cmp_shd.g_old_rec.forwd_eeoc;
  End If;
  If (p_rec.aj_cert_decision_date = hr_api.g_date) then
    p_rec.aj_cert_decision_date :=
    ghr_cmp_shd.g_old_rec.aj_cert_decision_date;
  End If;
  If (p_rec.aj_cert_decision_recvd = hr_api.g_date) then
    p_rec.aj_cert_decision_recvd :=
    ghr_cmp_shd.g_old_rec.aj_cert_decision_recvd;
  End If;
  If (p_rec.aj_cert_decision = hr_api.g_varchar2) then
    p_rec.aj_cert_decision :=
    ghr_cmp_shd.g_old_rec.aj_cert_decision;
  End If;
  If (p_rec.class_members_notified = hr_api.g_date) then
    p_rec.class_members_notified :=
    ghr_cmp_shd.g_old_rec.class_members_notified;
  End If;
  If (p_rec.number_of_complaintants = hr_api.g_number) then
    p_rec.number_of_complaintants :=
    ghr_cmp_shd.g_old_rec.number_of_complaintants;
  End If;
  If (p_rec.class_hearing = hr_api.g_date) then
    p_rec.class_hearing :=
    ghr_cmp_shd.g_old_rec.class_hearing;
  End If;
  If (p_rec.aj_dec = hr_api.g_date) then
    p_rec.aj_dec :=
    ghr_cmp_shd.g_old_rec.aj_dec;
  End If;
  If (p_rec.agency_recvd_aj_dec = hr_api.g_date) then
    p_rec.agency_recvd_aj_dec :=
    ghr_cmp_shd.g_old_rec.agency_recvd_aj_dec;
  End If;
  If (p_rec.aj_decision = hr_api.g_varchar2) then
    p_rec.aj_decision :=
    ghr_cmp_shd.g_old_rec.aj_decision;
  End If;
  If (p_rec.agency_brief_eeoc = hr_api.g_date) then
    p_rec.agency_brief_eeoc :=
    ghr_cmp_shd.g_old_rec.agency_brief_eeoc;
  End If;
  If (p_rec.agency_notif_of_civil_action = hr_api.g_date) then
    p_rec.agency_notif_of_civil_action :=
    ghr_cmp_shd.g_old_rec.agency_notif_of_civil_action;
  End If;
  If (p_rec.fad_source = hr_api.g_varchar2) then
    p_rec.fad_source :=
    ghr_cmp_shd.g_old_rec.fad_source;
  End If;
  If (p_rec.agency_files_forwarded_eeoc = hr_api.g_date) then
    p_rec.agency_files_forwarded_eeoc :=
    ghr_cmp_shd.g_old_rec.agency_files_forwarded_eeoc;
  End If;
  If (p_rec.hearing_req = hr_api.g_date) then
    p_rec.hearing_req :=
    ghr_cmp_shd.g_old_rec.hearing_req;
  End If;
 If (p_rec.agency_code = hr_api.g_varchar2) then
    p_rec.agency_code :=
    ghr_cmp_shd.g_old_rec.agency_code;
 End If;
 If (p_rec.audited_by = hr_api.g_varchar2) then
    p_rec.audited_by :=
    ghr_cmp_shd.g_old_rec.audited_by;
 End If;
 If (p_rec.record_received = hr_api.g_date) then
    p_rec.record_received :=
    ghr_cmp_shd.g_old_rec.record_received;
 End If;
---------------------------------------------------------------------------

  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    ghr_cmp_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    ghr_cmp_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    ghr_cmp_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    ghr_cmp_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    ghr_cmp_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    ghr_cmp_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    ghr_cmp_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    ghr_cmp_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    ghr_cmp_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    ghr_cmp_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    ghr_cmp_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    ghr_cmp_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    ghr_cmp_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    ghr_cmp_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    ghr_cmp_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    ghr_cmp_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    ghr_cmp_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    ghr_cmp_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    ghr_cmp_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    ghr_cmp_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    ghr_cmp_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    ghr_cmp_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    ghr_cmp_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    ghr_cmp_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    ghr_cmp_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    ghr_cmp_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    ghr_cmp_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    ghr_cmp_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    ghr_cmp_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    ghr_cmp_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    ghr_cmp_shd.g_old_rec.attribute30;
  End If;

  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ghr_cmp_shd.lck
    (p_rec.complaint_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ghr_cmp_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  ghr_cmp_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ghr_cmp_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ghr_cmp_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_complaint_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_complainant_person_id        in     number
  ,p_business_group_id            in     number
  ,p_docket_number                in     varchar2
  ,p_stage                        in     varchar2
  ,p_class_flag                   in     varchar2
  ,p_mixed_flag                   in     varchar2
  ,p_consolidated_flag            in     varchar2
  ,p_remand_flag                  in     varchar2
  ,p_active_flag                  in     varchar2
  ,p_information_inquiry          in     date
  ,p_pcom_init                    in     date
  ,p_alleg_incident               in     date
  ,p_alleg_discrim_org_id         in     number
  ,p_rr_ltr_date                  in     date
  ,p_rr_ltr_recvd                 in     date
  ,p_pre_com_elec                 in     varchar2
  --,p_adr_offered                  in     varchar2
  ,p_class_agent_flag             in     varchar2
  ,p_pre_com_desc                 in     varchar2
  ,p_counselor_asg                in     date
  ,p_init_counselor_interview     in     date
  ,p_anonymity_requested          in     varchar2
  ,p_counsel_ext_ltr              in     date
  ,p_traditional_counsel_outcome  in     varchar2
  ,p_final_interview              in     date
  ,p_notice_rtf_recvd             in     date
  ,p_precom_closed                in     date
  ,p_precom_closure_nature        in     varchar2
  ,p_counselor_rpt_sub            in     date
  ,p_hr_office_org_id             in     number
  ,p_eeo_office_org_id            in     number
  ,p_serviced_org_id              in     number
  ,p_formal_com_filed             in     date
  ,p_ack_ltr                      in     date
  ,p_clarification_ltr_date       in     date
  ,p_clarification_response_recvd in     date
  ,p_forwarded_legal_review       in     date
  ,p_returned_from_legal          in     date
  ,p_letter_type                  in     varchar2
  ,p_letter_date                  in     date
  ,p_letter_recvd                 in     date
  ,p_investigation_source         in     varchar2
  ,p_investigator_recvd_req       in     date
  ,p_agency_investigator_req      in     date
  ,p_investigator_asg             in     date
  ,p_investigation_start          in     date
  ,p_investigation_end            in     date
  ,p_investigation_extended       in     date
  ,p_invest_extension_desc        in     varchar2
  ,p_agency_recvd_roi             in     date
  ,p_comrep_recvd_roi             in     date
  ,p_options_ltr_date             in     date
  ,p_comrep_recvd_opt_ltr         in     date
  ,p_comrep_opt_ltr_response      in     varchar2
  ,p_resolution_offer             in     date
  ,p_comrep_resol_offer_recvd     in     date
  ,p_comrep_resol_offer_response  in     date
  ,p_comrep_resol_offer_desc      in     varchar2
  ,p_resol_offer_signed           in     date
  ,p_resol_offer_desc             in     varchar2
  ,p_hearing_source               in     varchar2
  ,p_agency_notified_hearing      in     date
  ,p_eeoc_hearing_docket_num      in     varchar2
  ,p_hearing_complete             in     date
  ,p_aj_merit_decision_date       in     date
  ,p_agency_recvd_aj_merit_dec    in     date
  ,p_aj_merit_decision            in     varchar2
  ,p_aj_ca_decision_date          in     date
  ,p_agency_recvd_aj_ca_dec       in     date
  ,p_aj_ca_decision               in     varchar2
  ,p_fad_requested                in     date
  ,p_merit_fad                    in     varchar2
  ,p_attorney_fees_fad            in     varchar2
  ,p_comp_damages_fad             in     varchar2
  ,p_non_compliance_fad           in     varchar2
  ,p_fad_req_recvd_eeo_office     in     date
  ,p_fad_req_forwd_to_agency      in     date
  ,p_agency_recvd_request         in     date
  ,p_fad_due                      in     date
  ,p_fad_date                     in     date
  ,p_fad_decision                 in     varchar2
  --p_fad_final_action_closure     in     varchar2
  ,p_fad_forwd_to_comrep          in     date
  ,p_fad_recvd_by_comrep          in     date
  ,p_fad_imp_ltr_forwd_to_org     in     date
  ,p_fad_decision_forwd_legal     in     date
  ,p_fad_decision_recvd_legal     in     date
  ,p_fa_source                    in     varchar2
  ,p_final_action_due             in     date
  --,p_final_action_nature_of_closu in     varchar2
  ,p_final_act_forwd_comrep       in     date
  ,p_final_act_recvd_comrep       in     date
  ,p_final_action_decision_date   in     date
  ,p_final_action_decision        in     varchar2
  ,p_fa_imp_ltr_forwd_to_org      in     date
  ,p_fa_decision_forwd_legal      in     date
  ,p_fa_decision_recvd_legal      in     date
  ,p_civil_action_filed           in     date
  ,p_agency_closure_confirmed     in     date
  ,p_consolidated_complaint_id    in     number
  ,p_consolidated                 in     date
  ,p_stage_of_consolidation       in     varchar2
  ,p_comrep_notif_consolidation   in     date
  ,p_consolidation_desc           in     varchar2
  ,p_complaint_closed             in     date
  ,p_nature_of_closure            in     varchar2
  ,p_complaint_closed_desc        in     varchar2
  ,p_filed_formal_class           in     date
  ,p_forwd_eeoc                   in     date
  ,p_aj_cert_decision_date        in     date
  ,p_aj_cert_decision_recvd       in     date
  ,p_aj_cert_decision             in     varchar2
  ,p_class_members_notified       in     date
  ,p_number_of_complaintants      in     number
  ,p_class_hearing                in     date
  ,p_aj_dec                       in     date
  ,p_agency_recvd_aj_dec          in     date
  ,p_aj_decision                  in     varchar2
  ,p_agency_brief_eeoc            in     date
  ,p_agency_notif_of_civil_action in     date
  ,p_fad_source                   in     varchar2
  ,p_agency_files_forwarded_eeoc  in     date
  ,p_hearing_req                  in     date
  ,p_agency_code                  in     varchar2
  ,p_audited_by                   in     varchar2
  ,p_record_received              in     date
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  ) is
--
  l_rec   ghr_cmp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_cmp_shd.convert_args
  (p_complaint_id
  ,p_complainant_person_id
  ,p_business_group_id
  ,p_docket_number
  ,p_stage
  ,p_class_flag
  ,p_mixed_flag
  ,p_consolidated_flag
  ,p_remand_flag
  ,p_active_flag
  ,p_information_inquiry
  ,p_pcom_init
  ,p_alleg_incident
  ,p_alleg_discrim_org_id
  ,p_rr_ltr_date
  ,p_rr_ltr_recvd
  ,p_pre_com_elec
  --,p_adr_offered
  ,p_class_agent_flag
  ,p_pre_com_desc
  ,p_counselor_asg
  ,p_init_counselor_interview
  ,p_anonymity_requested
  ,p_counsel_ext_ltr
  ,p_traditional_counsel_outcome
  ,p_final_interview
  ,p_notice_rtf_recvd
  ,p_precom_closed
  ,p_precom_closure_nature
  ,p_counselor_rpt_sub
  ,p_hr_office_org_id
  ,p_eeo_office_org_id
  ,p_serviced_org_id
  ,p_formal_com_filed
  ,p_ack_ltr
  ,p_clarification_ltr_date
  ,p_clarification_response_recvd
  ,p_forwarded_legal_review
  ,p_returned_from_legal
  ,p_letter_type
  ,p_letter_date
  ,p_letter_recvd
  ,p_investigation_source
  ,p_investigator_recvd_req
  ,p_agency_investigator_req
  ,p_investigator_asg
  ,p_investigation_start
  ,p_investigation_end
  ,p_investigation_extended
  ,p_invest_extension_desc
  ,p_agency_recvd_roi
  ,p_comrep_recvd_roi
  ,p_options_ltr_date
  ,p_comrep_recvd_opt_ltr
  ,p_comrep_opt_ltr_response
  ,p_resolution_offer
  ,p_comrep_resol_offer_recvd
  ,p_comrep_resol_offer_response
  ,p_comrep_resol_offer_desc
  ,p_resol_offer_signed
  ,p_resol_offer_desc
  ,p_hearing_source
  ,p_agency_notified_hearing
  ,p_eeoc_hearing_docket_num
  ,p_hearing_complete
  ,p_aj_merit_decision_date
  ,p_agency_recvd_aj_merit_dec
  ,p_aj_merit_decision
  ,p_aj_ca_decision_date
  ,p_agency_recvd_aj_ca_dec
  ,p_aj_ca_decision
  ,p_fad_requested
  ,p_merit_fad
  ,p_attorney_fees_fad
  ,p_comp_damages_fad
  ,p_non_compliance_fad
  ,p_fad_req_recvd_eeo_office
  ,p_fad_req_forwd_to_agency
  ,p_agency_recvd_request
  ,p_fad_due
  ,p_fad_date
  ,p_fad_decision
  --,p_fad_final_action_closure
  ,p_fad_forwd_to_comrep
  ,p_fad_recvd_by_comrep
  ,p_fad_imp_ltr_forwd_to_org
  ,p_fad_decision_forwd_legal
  ,p_fad_decision_recvd_legal
  ,p_fa_source
  ,p_final_action_due
  --,p_final_action_nature_of_closu
  ,p_final_act_forwd_comrep
  ,p_final_act_recvd_comrep
  ,p_final_action_decision_date
  ,p_final_action_decision
  ,p_fa_imp_ltr_forwd_to_org
  ,p_fa_decision_forwd_legal
  ,p_fa_decision_recvd_legal
  ,p_civil_action_filed
  ,p_agency_closure_confirmed
  ,p_consolidated_complaint_id
  ,p_consolidated
  ,p_stage_of_consolidation
  ,p_comrep_notif_consolidation
  ,p_consolidation_desc
  ,p_complaint_closed
  ,p_nature_of_closure
  ,p_complaint_closed_desc
  ,p_filed_formal_class
  ,p_forwd_eeoc
  ,p_aj_cert_decision_date
  ,p_aj_cert_decision_recvd
  ,p_aj_cert_decision
  ,p_class_members_notified
  ,p_number_of_complaintants
  ,p_class_hearing
  ,p_aj_dec
  ,p_agency_recvd_aj_dec
  ,p_aj_decision
  ,p_object_version_number
  ,p_agency_brief_eeoc
  ,p_agency_notif_of_civil_action
  ,p_fad_source
  ,p_agency_files_forwarded_eeoc
  ,p_hearing_req
  ,p_agency_code
  ,p_audited_by
  ,p_record_received
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ghr_cmp_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ghr_cmp_upd;

/
