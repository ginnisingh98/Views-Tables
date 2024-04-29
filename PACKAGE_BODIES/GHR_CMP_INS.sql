--------------------------------------------------------
--  DDL for Package Body GHR_CMP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CMP_INS" as
/* $Header: ghcmprhi.pkb 120.0 2005/05/29 02:54:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cmp_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec in out nocopy ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: ghr_complaints2
  --
  insert into ghr_complaints2
      (complaint_id
      ,complainant_person_id
      ,business_group_id
      ,docket_number
      ,stage
      ,class_flag
      ,mixed_flag
      ,consolidated_flag
      ,remand_flag
      ,active_flag
      ,information_inquiry
      ,pcom_init
      ,alleg_incident
      ,alleg_discrim_org_id
      ,rr_ltr_date
      ,rr_ltr_recvd
      ,pre_com_elec
      --,adr_offered
      ,class_agent_flag
      ,pre_com_desc
      ,counselor_asg
      ,init_counselor_interview
      ,anonymity_requested
      ,counsel_ext_ltr
      ,traditional_counsel_outcome
      ,final_interview
      ,notice_rtf_recvd
      ,precom_closed
      ,precom_closure_nature
      ,counselor_rpt_sub
      ,hr_office_org_id
      ,eeo_office_org_id
      ,serviced_org_id
      ,formal_com_filed
      ,ack_ltr
      ,clarification_ltr_date
      ,clarification_response_recvd
      ,forwarded_legal_review
      ,returned_from_legal
      ,letter_type
      ,letter_date
      ,letter_recvd
      ,investigation_source
      ,investigator_recvd_req
      ,agency_investigator_req
      ,investigator_asg
      ,investigation_start
      ,investigation_end
      ,investigation_extended
      ,invest_extension_desc
      ,agency_recvd_roi
      ,comrep_recvd_roi
      ,options_ltr_date
      ,comrep_recvd_opt_ltr
      ,comrep_opt_ltr_response
      ,resolution_offer
      ,comrep_resol_offer_recvd
      ,comrep_resol_offer_response
      ,comrep_resol_offer_desc
      ,resol_offer_signed
      ,resol_offer_desc
      ,hearing_source
      ,agency_notified_hearing
      ,eeoc_hearing_docket_num
      ,hearing_complete
      ,aj_merit_decision_date
      ,agency_recvd_aj_merit_dec
      ,aj_merit_decision
      ,aj_ca_decision_date
      ,agency_recvd_aj_ca_dec
      ,aj_ca_decision
      ,fad_requested
      ,merit_fad
      ,attorney_fees_fad
      ,comp_damages_fad
      ,non_compliance_fad
      ,fad_req_recvd_eeo_office
      ,fad_req_forwd_to_agency
      ,agency_recvd_request
      ,fad_due
      ,fad_date
      ,fad_decision
     -- ,fad_final_action_closure
      ,fad_forwd_to_comrep
      ,fad_recvd_by_comrep
      ,fad_imp_ltr_forwd_to_org
      ,fad_decision_forwd_legal
      ,fad_decision_recvd_legal
      ,fa_source
      ,final_action_due
      --,final_action_nature_of_closure
      ,final_act_forwd_comrep
      ,final_act_recvd_comrep
      ,final_action_decision_date
      ,final_action_decision
      ,fa_imp_ltr_forwd_to_org
      ,fa_decision_forwd_legal
      ,fa_decision_recvd_legal
      ,civil_action_filed
      ,agency_closure_confirmed
      ,consolidated_complaint_id
      ,consolidated
      ,stage_of_consolidation
      ,comrep_notif_consolidation
      ,consolidation_desc
      ,complaint_closed
      ,nature_of_closure
      ,complaint_closed_desc
      ,filed_formal_class
      ,forwd_eeoc
      ,aj_cert_decision_date
      ,aj_cert_decision_recvd
      ,aj_cert_decision
      ,class_members_notified
      ,number_of_complaintants
      ,class_hearing
      ,aj_dec
      ,agency_recvd_aj_dec
      ,aj_decision
      ,object_version_number
      ,agency_brief_eeoc
      ,agency_notif_of_civil_action
      ,fad_source
      ,agency_files_forwarded_eeoc
      ,hearing_req
      ,agency_code
      ,audited_by
      ,record_received
	,attribute_category
	,attribute1
	,attribute2
	,attribute3
	,attribute4
	,attribute5
	,attribute6
	,attribute7
	,attribute8
	,attribute9
	,attribute10
	,attribute11
	,attribute12
	,attribute13
	,attribute14
	,attribute15
	,attribute16
	,attribute17
	,attribute18
	,attribute19
	,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      )
  Values
    (p_rec.complaint_id
    ,p_rec.complainant_person_id
    ,p_rec.business_group_id
    ,p_rec.docket_number
    ,p_rec.stage
    ,p_rec.class_flag
    ,p_rec.mixed_flag
    ,p_rec.consolidated_flag
    ,p_rec.remand_flag
    ,p_rec.active_flag
    ,p_rec.information_inquiry
    ,p_rec.pcom_init
    ,p_rec.alleg_incident
    ,p_rec.alleg_discrim_org_id
    ,p_rec.rr_ltr_date
    ,p_rec.rr_ltr_recvd
    ,p_rec.pre_com_elec
    --,p_rec.adr_offered
    ,p_rec.class_agent_flag
    ,p_rec.pre_com_desc
    ,p_rec.counselor_asg
    ,p_rec.init_counselor_interview
    ,p_rec.anonymity_requested
    ,p_rec.counsel_ext_ltr
    ,p_rec.traditional_counsel_outcome
    ,p_rec.final_interview
    ,p_rec.notice_rtf_recvd
    ,p_rec.precom_closed
    ,p_rec.precom_closure_nature
    ,p_rec.counselor_rpt_sub
    ,p_rec.hr_office_org_id
    ,p_rec.eeo_office_org_id
    ,p_rec.serviced_org_id
    ,p_rec.formal_com_filed
    ,p_rec.ack_ltr
    ,p_rec.clarification_ltr_date
    ,p_rec.clarification_response_recvd
    ,p_rec.forwarded_legal_review
    ,p_rec.returned_from_legal
    ,p_rec.letter_type
    ,p_rec.letter_date
    ,p_rec.letter_recvd
    ,p_rec.investigation_source
    ,p_rec.investigator_recvd_req
    ,p_rec.agency_investigator_req
    ,p_rec.investigator_asg
    ,p_rec.investigation_start
    ,p_rec.investigation_end
    ,p_rec.investigation_extended
    ,p_rec.invest_extension_desc
    ,p_rec.agency_recvd_roi
    ,p_rec.comrep_recvd_roi
    ,p_rec.options_ltr_date
    ,p_rec.comrep_recvd_opt_ltr
    ,p_rec.comrep_opt_ltr_response
    ,p_rec.resolution_offer
    ,p_rec.comrep_resol_offer_recvd
    ,p_rec.comrep_resol_offer_response
    ,p_rec.comrep_resol_offer_desc
    ,p_rec.resol_offer_signed
    ,p_rec.resol_offer_desc
    ,p_rec.hearing_source
    ,p_rec.agency_notified_hearing
    ,p_rec.eeoc_hearing_docket_num
    ,p_rec.hearing_complete
    ,p_rec.aj_merit_decision_date
    ,p_rec.agency_recvd_aj_merit_dec
    ,p_rec.aj_merit_decision
    ,p_rec.aj_ca_decision_date
    ,p_rec.agency_recvd_aj_ca_dec
    ,p_rec.aj_ca_decision
    ,p_rec.fad_requested
    ,p_rec.merit_fad
    ,p_rec.attorney_fees_fad
    ,p_rec.comp_damages_fad
    ,p_rec.non_compliance_fad
    ,p_rec.fad_req_recvd_eeo_office
    ,p_rec.fad_req_forwd_to_agency
    ,p_rec.agency_recvd_request
    ,p_rec.fad_due
    ,p_rec.fad_date
    ,p_rec.fad_decision
   -- ,p_rec.fad_final_action_closure
    ,p_rec.fad_forwd_to_comrep
    ,p_rec.fad_recvd_by_comrep
    ,p_rec.fad_imp_ltr_forwd_to_org
    ,p_rec.fad_decision_forwd_legal
    ,p_rec.fad_decision_recvd_legal
    ,p_rec.fa_source
    ,p_rec.final_action_due
   -- ,p_rec.final_action_nature_of_closure
    ,p_rec.final_act_forwd_comrep
    ,p_rec.final_act_recvd_comrep
    ,p_rec.final_action_decision_date
    ,p_rec.final_action_decision
    ,p_rec.fa_imp_ltr_forwd_to_org
    ,p_rec.fa_decision_forwd_legal
    ,p_rec.fa_decision_recvd_legal
    ,p_rec.civil_action_filed
    ,p_rec.agency_closure_confirmed
    ,p_rec.consolidated_complaint_id
    ,p_rec.consolidated
    ,p_rec.stage_of_consolidation
    ,p_rec.comrep_notif_consolidation
    ,p_rec.consolidation_desc
    ,p_rec.complaint_closed
    ,p_rec.nature_of_closure
    ,p_rec.complaint_closed_desc
    ,p_rec.filed_formal_class
    ,p_rec.forwd_eeoc
    ,p_rec.aj_cert_decision_date
    ,p_rec.aj_cert_decision_recvd
    ,p_rec.aj_cert_decision
    ,p_rec.class_members_notified
    ,p_rec.number_of_complaintants
    ,p_rec.class_hearing
    ,p_rec.aj_dec
    ,p_rec.agency_recvd_aj_dec
    ,p_rec.aj_decision
    ,p_rec.object_version_number
    ,p_rec.agency_brief_eeoc
    ,p_rec.agency_notif_of_civil_action
    ,p_rec.fad_source
    ,p_rec.agency_files_forwarded_eeoc
    ,p_rec.hearing_req
    ,p_rec.agency_code
    ,p_rec.audited_by
    ,p_rec.record_received
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.attribute21
    ,p_rec.attribute22
    ,p_rec.attribute23
    ,p_rec.attribute24
    ,p_rec.attribute25
    ,p_rec.attribute26
    ,p_rec.attribute27
    ,p_rec.attribute28
    ,p_rec.attribute29
    ,p_rec.attribute30
    );

  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec  in out nocopy ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ghr_complaints2_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.complaint_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  begin
    --
    ghr_cmp_rki.after_insert
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
     -- ,p_final_action_nature_of_closu => p_rec.final_action_nature_of_closure
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'GHR_COMPLAINTS2'
        ,p_hook_type   => 'AI');
      --
  end;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ghr_cmp_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  ghr_cmp_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ghr_cmp_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ghr_cmp_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_complainant_person_id          in     number
  ,p_business_group_id              in     number
  ,p_docket_number                  in     varchar2
  ,p_stage                          in     varchar2
  ,p_class_flag                     in     varchar2
  ,p_mixed_flag                     in     varchar2
  ,p_consolidated_flag              in     varchar2
  ,p_remand_flag                    in     varchar2
  ,p_active_flag                    in     varchar2
  ,p_information_inquiry            in     date
  ,p_pcom_init                      in     date
  ,p_alleg_incident                 in     date
  ,p_alleg_discrim_org_id           in     number
  ,p_rr_ltr_date                    in     date
  ,p_rr_ltr_recvd                   in     date
  ,p_pre_com_elec                   in     varchar2
  --,p_adr_offered                    in     varchar2
  ,p_class_agent_flag               in     varchar2
  ,p_pre_com_desc                   in     varchar2
  ,p_counselor_asg                  in     date
  ,p_init_counselor_interview       in     date
  ,p_anonymity_requested            in     varchar2
  ,p_counsel_ext_ltr                in     date
  ,p_traditional_counsel_outcome    in     varchar2
  ,p_final_interview                in     date
  ,p_notice_rtf_recvd               in     date
  ,p_precom_closed                  in     date
  ,p_precom_closure_nature          in     varchar2
  ,p_counselor_rpt_sub              in     date
  ,p_hr_office_org_id               in     number
  ,p_eeo_office_org_id              in     number
  ,p_serviced_org_id                in     number
  ,p_formal_com_filed               in     date
  ,p_ack_ltr                        in     date
  ,p_clarification_ltr_date         in     date
  ,p_clarification_response_recvd   in     date
  ,p_forwarded_legal_review         in     date
  ,p_returned_from_legal            in     date
  ,p_letter_type                    in     varchar2
  ,p_letter_date                    in     date
  ,p_letter_recvd                   in     date
  ,p_investigation_source           in     varchar2
  ,p_investigator_recvd_req         in     date
  ,p_agency_investigator_req        in     date
  ,p_investigator_asg               in     date
  ,p_investigation_start            in     date
  ,p_investigation_end              in     date
  ,p_investigation_extended         in     date
  ,p_invest_extension_desc          in     varchar2
  ,p_agency_recvd_roi               in     date
  ,p_comrep_recvd_roi               in     date
  ,p_options_ltr_date               in     date
  ,p_comrep_recvd_opt_ltr           in     date
  ,p_comrep_opt_ltr_response        in     varchar2
  ,p_resolution_offer               in     date
  ,p_comrep_resol_offer_recvd       in     date
  ,p_comrep_resol_offer_response    in     date
  ,p_comrep_resol_offer_desc        in     varchar2
  ,p_resol_offer_signed             in     date
  ,p_resol_offer_desc               in     varchar2
  ,p_hearing_source                 in     varchar2
  ,p_agency_notified_hearing        in     date
  ,p_eeoc_hearing_docket_num        in     varchar2
  ,p_hearing_complete               in     date
  ,p_aj_merit_decision_date         in     date
  ,p_agency_recvd_aj_merit_dec      in     date
  ,p_aj_merit_decision              in     varchar2
  ,p_aj_ca_decision_date            in     date
  ,p_agency_recvd_aj_ca_dec         in     date
  ,p_aj_ca_decision                 in     varchar2
  ,p_fad_requested                  in     date
  ,p_merit_fad                      in     varchar2
  ,p_attorney_fees_fad              in     varchar2
  ,p_comp_damages_fad               in     varchar2
  ,p_non_compliance_fad             in     varchar2
  ,p_fad_req_recvd_eeo_office       in     date
  ,p_fad_req_forwd_to_agency        in     date
  ,p_agency_recvd_request           in     date
  ,p_fad_due                        in     date
  ,p_fad_date                       in     date
  ,p_fad_decision                   in     varchar2
  --,p_fad_final_action_closure       in     varchar2
  ,p_fad_forwd_to_comrep            in     date
  ,p_fad_recvd_by_comrep            in     date
  ,p_fad_imp_ltr_forwd_to_org       in     date
  ,p_fad_decision_forwd_legal       in     date
  ,p_fad_decision_recvd_legal       in     date
  ,p_fa_source                      in     varchar2
  ,p_final_action_due               in     date
  --,p_final_action_nature_of_closu   in     varchar2
  ,p_final_act_forwd_comrep         in     date
  ,p_final_act_recvd_comrep         in     date
  ,p_final_action_decision_date     in     date
  ,p_final_action_decision          in     varchar2
  ,p_fa_imp_ltr_forwd_to_org        in     date
  ,p_fa_decision_forwd_legal        in     date
  ,p_fa_decision_recvd_legal        in     date
  ,p_civil_action_filed             in     date
  ,p_agency_closure_confirmed       in     date
  ,p_consolidated_complaint_id      in     number
  ,p_consolidated                   in     date
  ,p_stage_of_consolidation         in     varchar2
  ,p_comrep_notif_consolidation     in     date
  ,p_consolidation_desc             in     varchar2
  ,p_complaint_closed               in     date
  ,p_nature_of_closure              in     varchar2
  ,p_complaint_closed_desc          in     varchar2
  ,p_filed_formal_class             in     date
  ,p_forwd_eeoc                     in     date
  ,p_aj_cert_decision_date          in     date
  ,p_aj_cert_decision_recvd         in     date
  ,p_aj_cert_decision               in     varchar2
  ,p_class_members_notified         in     date
  ,p_number_of_complaintants        in     number
  ,p_class_hearing                  in     date
  ,p_aj_dec                         in     date
  ,p_agency_recvd_aj_dec            in     date
  ,p_aj_decision                    in     varchar2
  ,p_agency_brief_eeoc              in     date
  ,p_agency_notif_of_civil_action   in     date
  ,p_fad_source                     in     varchar2
  ,p_agency_files_forwarded_eeoc    in     date
  ,p_hearing_req                    in     date
  ,p_agency_code                    in     varchar2
  ,p_audited_by                     in     varchar2
  ,p_record_received                in     date
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_attribute21                    in     varchar2
  ,p_attribute22                    in     varchar2
  ,p_attribute23                    in     varchar2
  ,p_attribute24                    in     varchar2
  ,p_attribute25                    in     varchar2
  ,p_attribute26                    in     varchar2
  ,p_attribute27                    in     varchar2
  ,p_attribute28                    in     varchar2
  ,p_attribute29                    in     varchar2
  ,p_attribute30                    in     varchar2
  ,p_complaint_id                      out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ghr_cmp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ghr_cmp_shd.convert_args
    (null
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
    ,null
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
  -- Having converted the arguments into the ghr_cmp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ghr_cmp_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_complaint_id := l_rec.complaint_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ghr_cmp_ins;

/
