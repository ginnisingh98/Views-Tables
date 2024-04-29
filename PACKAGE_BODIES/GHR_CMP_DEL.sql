--------------------------------------------------------
--  DDL for Package Body GHR_CMP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CMP_DEL" as
/* $Header: ghcmprhi.pkb 120.0 2005/05/29 02:54:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cmp_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
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
Procedure delete_dml
  (p_rec in ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the ghr_complaints2 row.
  --
  delete from ghr_complaints2
  where complaint_id = p_rec.complaint_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    ghr_cmp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ghr_cmp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in ghr_cmp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  begin
    --
    ghr_cmp_rkd.after_delete
      (p_complaint_id                 => p_rec.complaint_id
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
      --,p_fad_final_action_closure_o  => ghr_cmp_shd.g_old_rec.fad_final_action_closure
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in ghr_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ghr_cmp_shd.lck
    (p_rec.complaint_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ghr_cmp_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  ghr_cmp_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ghr_cmp_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ghr_cmp_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_complaint_id                         in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ghr_cmp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.complaint_id := p_complaint_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ghr_cmp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ghr_cmp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ghr_cmp_del;

/
