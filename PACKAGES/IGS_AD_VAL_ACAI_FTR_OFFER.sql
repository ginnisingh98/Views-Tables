--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ACAI_FTR_OFFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ACAI_FTR_OFFER" AUTHID CURRENT_USER AS
/* $Header: IGSADB5S.pls 120.1 2005/09/19 10:40:26 appldev ship $ */
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To create future term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
rrengara        18-sep-2002     added p_process as a parameter to copy_child_records for deferment build 2563941
*******************************************************************************/
  PROCEDURE admp_val_offer_future_term(   errbuf out NOCOPY varchar2,
                                        retcode out NOCOPY number ,
                                        p_person_id hz_parties.party_id%TYPE,
                                        p_group_id igs_pe_persid_group.group_id%TYPE,
                                        p_nominated_course_cd  igs_ad_ps_appl.nominated_course_cd%TYPE,
                                        p_prev_acad_adm_cal  VARCHAR2,
                                        p_future_acad_adm_cal VARCHAR2,
                                        p_offer_dt   VARCHAR2,
                                        p_offer_response_dt VARCHAR2,
					p_application_type VARCHAR2 DEFAULT NULL,
					p_application_id NUMBER DEFAULT NULL);

  FUNCTION handle_application(          p_person_id hz_parties.party_id%TYPE,
                                        p_admission_appl_number igs_ad_appl.admission_appl_number%TYPE,
                                        p_nominated_course_cd  igs_ad_ps_appl.nominated_course_cd%TYPE,
                                        p_sequence_number  igs_ad_ps_appl_inst.sequence_number%TYPE,
                                        p_fut_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                                        p_fut_acad_cal_seq_no igs_ad_appl.acad_ci_sequence_number%TYPE,
                                        p_fut_adm_cal_type igs_ad_appl.adm_cal_type%TYPE,
                                        p_fut_adm_cal_seq_no igs_ad_appl.adm_ci_sequence_number%TYPE,
                                        p_new_admission_appl_number OUT NOCOPY igs_ad_appl.admission_appl_number%TYPE,
                                        p_new_sequence_number OUT NOCOPY igs_ad_ps_appl_inst.sequence_number%TYPE)
                                        RETURN BOOLEAN;

  FUNCTION copy_child_records(          p_new_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                                        p_new_sequence_number       IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                        p_person_id                 HZ_PARTIES.party_id%TYPE,
                                        p_old_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                                        p_old_sequence_number       IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                        p_nominated_course_cd       IGS_AD_PS_APPL.nominated_course_cd%TYPE,
                                        p_start_dt                  DATE,
					                              p_process                   VARCHAR2)
                                        RETURN BOOLEAN ;

  FUNCTION validate_offer_validations(  p_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                        p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                        p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                        p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                        p_old_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                        p_old_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                        p_offer_dt igs_ad_ps_appl_inst.offer_dt%TYPE,
                                        p_offer_response_dt igs_ad_ps_appl_inst.offer_response_dt%TYPE,
                                        p_fut_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                                        p_fut_acad_cal_seq_no igs_ad_appl.acad_ci_sequence_number%TYPE,
                                        p_fut_adm_cal_type igs_ad_appl.adm_cal_type%TYPE,
                                        p_fut_adm_cal_seq_no igs_ad_appl.adm_ci_sequence_number%TYPE,
                                        p_start_dt  DATE) RETURN BOOLEAN;

  FUNCTION copy_entrycomp_qual_status(  p_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                        p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                        p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                        p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                        p_new_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                        p_new_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE ) RETURN BOOLEAN;
END igs_ad_val_acai_ftr_offer;

 

/
