--------------------------------------------------------
--  DDL for Package IGS_AD_DEF_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_DEF_APPL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADC1S.pls 120.1 2005/10/25 23:39:32 appldev ship $ */
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 13 SEP 2002

Purpose:
  To create deferred term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
  PROCEDURE admp_val_offer_defer_term(   errbuf out NOCOPY varchar2,
                                        retcode out NOCOPY number ,
                                        p_person_id hz_parties.party_id%TYPE,
                                        p_group_id igs_pe_persid_group.group_id%TYPE,
                                        p_nominated_course_cd  igs_ad_ps_appl.nominated_course_cd%TYPE,
                                        p_prev_acad_adm_cal  VARCHAR2,
                                        p_def_acad_adm_cal VARCHAR2,
                                        p_offer_dt   VARCHAR2,
                                        p_offer_response_dt VARCHAR2);

/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 06 AUG 2002

Purpose:
  To Create deferred term application , copy child records, copy entry and completness status , give offer with validation

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
PROCEDURE cmn_handle_application
       (
       p_person_id	hz_parties.party_id%TYPE,
       p_admission_appl_number  IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
       p_nominated_course_cd   IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
       p_sequence_number      IGS_AD_PS_APPL_INST.sequence_number%TYPE ,
       p_def_acad_cal_type    igs_ad_appl.acad_cal_type%TYPE ,
       p_def_acad_cal_seq_no   igs_ad_appl.acad_ci_sequence_number%TYPE,
       p_def_adm_cal_type      igs_ad_appl.adm_cal_type%TYPE,
       p_def_adm_cal_seq_no    igs_ad_appl.adm_ci_sequence_number%TYPE,
       p_offer_dt              igs_ad_ps_appl_inst.offer_dt%TYPE,
       p_offer_response_dt     igs_ad_ps_appl_inst.offer_response_dt%TYPE
       );

/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 06 AUG 2002

Purpose:
  To create deferred term application , this is getting called from admp_val_offer_defer_tem

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
  FUNCTION handle_application(          p_person_id hz_parties.party_id%TYPE,
                                        p_admission_appl_number igs_ad_appl.admission_appl_number%TYPE,
                                        p_nominated_course_cd  igs_ad_ps_appl.nominated_course_cd%TYPE,
                                        p_sequence_number  igs_ad_ps_appl_inst.sequence_number%TYPE,
                                        p_def_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                                        p_def_acad_cal_seq_no igs_ad_appl.acad_ci_sequence_number%TYPE,
                                        p_def_adm_cal_type igs_ad_appl.adm_cal_type%TYPE,
                                        p_def_adm_cal_seq_no igs_ad_appl.adm_ci_sequence_number%TYPE,
                                        p_new_admission_appl_number OUT NOCOPY igs_ad_appl.admission_appl_number%TYPE,
                                        p_new_sequence_number OUT NOCOPY igs_ad_ps_appl_inst.sequence_number%TYPE)
                                        RETURN BOOLEAN;
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 06 AUG 2002

Purpose:
  To validate offer and update the same for the application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/

  FUNCTION validate_offer_validations(  p_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                        p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                        p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                        p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                        p_old_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                        p_old_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                        p_offer_dt igs_ad_ps_appl_inst.offer_dt%TYPE,
                                        p_offer_response_dt igs_ad_ps_appl_inst.offer_response_dt%TYPE,
                                        p_def_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                                        p_def_acad_cal_seq_no igs_ad_appl.acad_ci_sequence_number%TYPE,
                                        p_def_adm_cal_type igs_ad_appl.adm_cal_type%TYPE,
                                        p_def_adm_cal_seq_no igs_ad_appl.adm_ci_sequence_number%TYPE,
                                        p_start_dt DATE) RETURN BOOLEAN;
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 06 AUG 2002

Purpose:
  To validate entry qual status and completness status for the old application and copy the same to new application
Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/

  FUNCTION copy_entrycomp_qual_status(  p_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                        p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                        p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                        p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                        p_new_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                        p_new_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE ) RETURN BOOLEAN;

/*******************************************************************************
Created by  : hreddych
Date created: 16 OCT 2002

Purpose:
  To update the Offer response status of the new application to 'ACCEPTED'
  if the offer deferment status of the old application is 'CONFIRM'

Change History: (who, when, what: )
Who             When            What
apadegal        06-Oct-2005     Changed it to a Function to handle exceptions in pre-enrolment.
*******************************************************************************/

  FUNCTION Update_offer_response_accepted (p_person_id  HZ_PARTIES.party_id%TYPE,
                                            p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                            p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                            p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE) RETURN BOOLEAN;
END IGS_AD_DEF_APPL_PKG;

 

/
