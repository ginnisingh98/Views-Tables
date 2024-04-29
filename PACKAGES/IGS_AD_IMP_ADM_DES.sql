--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_ADM_DES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_ADM_DES" AUTHID CURRENT_USER AS
/* $Header: IGSADB1S.pls 120.0 2005/06/01 21:35:09 appldev noship $ */
   PROCEDURE update_int_table (
      p_status               IN   igs_ad_admde_int.status%TYPE,
      p_error_msg            IN   fnd_new_messages.message_text%TYPE,
      p_interface_mkdes_id   IN   igs_ad_admde_int.interface_mkdes_id%TYPE,
      p_outcome_status       IN   igs_ad_admde_int.adm_outcome_status%TYPE
      );

   PROCEDURE validate_set_decision_details (
      p_batch_id               IN       igs_ad_admde_int.batch_id%TYPE,
      p_interface_mkdes_id     IN       igs_ad_admde_int.interface_mkdes_id%TYPE,
      p_person_id              IN       igs_pe_person.person_id%TYPE,
      p_acad_cal_type           IN       igs_ad_appl.acad_cal_type%TYPE,
      p_acad_ci_sequence_number IN       igs_ad_appl.acad_ci_sequence_number%TYPE,
      p_adm_cal_type            IN       igs_ad_appl.adm_cal_type%TYPE,
      p_adm_ci_sequence_number  IN       igs_ad_appl.adm_ci_sequence_number%TYPE,
      p_admission_cat           IN       igs_ad_appl.admission_cat%TYPE,
      p_s_admission_process_type IN      igs_ad_appl.s_admission_process_type%TYPE,
      p_s_adm_outcome_status   IN       igs_ad_ou_Stat.s_adm_outcome_status%TYPE,
      p_decision_make_id       OUT NOCOPY      igs_ad_ps_appl_inst.decision_make_id%TYPE,
      p_decision_date          OUT NOCOPY      igs_ad_ps_appl_inst.decision_date%TYPE,
      p_decision_reason_id     OUT NOCOPY      igs_ad_ps_appl_inst.decision_reason_id%TYPE,
      p_pending_reason_id      OUT NOCOPY      igs_ad_ps_appl_inst.pending_reason_id%TYPE,
      p_offer_dt               OUT NOCOPY      igs_ad_ps_appl_inst.offer_dt%TYPE,
      p_offer_response_dt      OUT NOCOPY      igs_ad_ps_appl_inst.offer_response_dt%TYPE,
      p_error_msg              OUT NOCOPY      fnd_new_messages.message_name%TYPE,
      p_return_status          OUT NOCOPY      VARCHAR2,
      p_prpsd_commencement_date   IN  igs_ad_admde_int_all.prpsd_commencement_date%TYPE DEFAULT NULL
   );

   PROCEDURE prc_adm_outcome_status (
      p_person_id               IN       igs_pe_person.person_id%TYPE,
      p_admission_appl_number   IN       igs_ad_appl.admission_appl_number%TYPE,
      p_nominated_course_cd     IN       igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
      p_sequence_number         IN       igs_ad_ps_appl_inst.sequence_number%TYPE,
      p_adm_outcome_status      IN       igs_ad_ou_stat.adm_outcome_status%TYPE,
      p_s_adm_outcome_status    IN       igs_ad_ou_stat.s_adm_outcome_status%TYPE,
      p_acad_cal_type           IN       igs_ad_appl.acad_cal_type%TYPE,
      p_acad_ci_sequence_number IN       igs_ad_appl.acad_ci_sequence_number%TYPE,
      p_adm_cal_type            IN       igs_ad_appl.adm_cal_type%TYPE,
      p_adm_ci_sequence_number  IN       igs_ad_appl.adm_ci_sequence_number%TYPE,
      p_admission_cat           IN       igs_ad_appl.admission_cat%TYPE,
      p_s_admission_process_type IN      igs_ad_appl.s_admission_process_type%TYPE,
      p_batch_id                IN       igs_ad_admde_int.batch_id%TYPE,
      p_interface_run_id        IN       igs_ad_admde_int.interface_run_id%TYPE,
      p_interface_mkdes_id      IN       igs_ad_admde_int.interface_mkdes_id%TYPE,
      p_error_message               OUT NOCOPY      fnd_new_messages.message_text%TYPE,
      p_return_status           OUT NOCOPY      VARCHAR2,
      p_ucas_transaction    IN VARCHAR2 DEFAULT 'N',
      p_reconsideration     IN VARCHAR2 DEFAULT 'N',
      p_prpsd_commencement_date   IN  igs_ad_admde_int_all.prpsd_commencement_date%TYPE DEFAULT NULL

   );

   PROCEDURE import_adm_decision (
	      p_batch_id 		    IN	igs_ad_batc_def_det_all.batch_id%TYPE,
      	      p_ucas_transaction            IN    VARCHAR2,
              p_message_name                OUT NOCOPY VARCHAR2,
              p_msg_token_rec_prc_cnt       OUT NOCOPY NUMBER
        );

   PROCEDURE discard_adm_decision (
	      p_batch_id 		    IN	igs_ad_batc_def_det_all.batch_id%TYPE,
              p_message_name                OUT NOCOPY VARCHAR2,
              p_msg_token_rec_prc_cnt       OUT NOCOPY NUMBER
        );

END igs_ad_imp_adm_des;

 

/
