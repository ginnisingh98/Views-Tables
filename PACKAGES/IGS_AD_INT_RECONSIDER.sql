--------------------------------------------------------
--  DDL for Package IGS_AD_INT_RECONSIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_INT_RECONSIDER" AUTHID CURRENT_USER AS
/* $Header: IGSADD6S.pls 120.0 2005/10/14 10:31:00 appldev noship $ */

FUNCTION copy_application_child_records (p_person_id                 HZ_PARTIES.party_id%TYPE,
                                         p_new_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                                         p_old_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
					 p_nominated_course_cd       IGS_AD_PS_APPL_INST_ALL.nominated_course_cd%TYPE,
					 p_sequence_number           IGS_AD_PS_APPL_INST_ALL.sequence_number%TYPE)
         RETURN boolean;

FUNCTION copy_instance_child_records (p_new_admission_appl_number IN IGS_AD_APPL.admission_appl_number%TYPE,
                                      p_new_sequence_number       IN IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                      p_person_id                 IN HZ_PARTIES.party_id%TYPE,
                                      p_old_admission_appl_number IN IGS_AD_APPL.admission_appl_number%TYPE,
                                      p_old_sequence_number       IN IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                      p_nominated_course_cd       IN IGS_AD_PS_APPL.nominated_course_cd%TYPE,
                                      p_start_dt                  IN DATE)
RETURN BOOLEAN;

PROCEDURE admp_init_reconsider(
                        errbuf out NOCOPY varchar2,
                        retcode out NOCOPY number ,
                        p_curr_acad_adm_cal VARCHAR2,
			p_future_acad_adm_cal VARCHAR2,
                        p_application_type VARCHAR2,
                        p_group_id igs_pe_persid_group.group_id%TYPE,
			p_application_id NUMBER,
			p_decision_date VARCHAR2,
			p_dec_maker_id igs_pe_person_base_v.person_id%TYPE,
			p_dec_reason_id IGS_AD_CODE_CLASSES.code_id%TYPE
			);
END igs_ad_int_reconsider;


 

/
