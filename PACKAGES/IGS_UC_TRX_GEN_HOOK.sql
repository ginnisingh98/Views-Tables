--------------------------------------------------------
--  DDL for Package IGS_UC_TRX_GEN_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_TRX_GEN_HOOK" AUTHID CURRENT_USER AS
/* $Header: IGSUC21S.pls 115.8 2003/11/21 14:35:01 ayedubat noship $ */

  PROCEDURE Create_UCAS_Transactions(
    p_ucas_id  IN igs_pe_person.api_person_id%TYPE,
    p_choice_number IN igs_uc_transactions.choice_no%TYPE,
    p_person_number IN igs_pe_person.person_number%TYPE,
    p_admission_appl_number IN igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
    p_nominated_course_cd IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
    p_sequence_number IN igs_ad_ps_appl_inst.sequence_number%TYPE,
    p_outcome_status IN igs_ad_ps_appl_inst.adm_outcome_status%TYPE,
    p_cond_offer_status IN igs_ad_ps_appl_inst.adm_cndtnl_offer_status%TYPE,
    p_alt_appl_id  IN igs_ad_appl.alt_appl_id%TYPE  DEFAULT NULL,
    p_condition_category IN igs_uc_offer_conds.condition_category%TYPE DEFAULT NULL,
    p_condition_name IN igs_uc_offer_conds.condition_name%TYPE DEFAULT NULL,
    p_uc_tran_id OUT NOCOPY NUMBER
  );

END igs_uc_trx_gen_hook;

 

/
