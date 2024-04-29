--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SCA" AUTHID CURRENT_USER AS
/* $Header: IGSEN61S.pls 120.2 2006/05/02 23:56:53 ckasu ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --shtatiko    08-MAR-2004     Enh# 3167098, Removed finp_audit_fee_cat procedure.
  --vchappid    28-Vov-01       Enh Bug No: 2122257, Added new procedure finp_audit_fee_cat
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function genp_val_sdtt_sess
  --kkillams    11-11-2002      As part of Legacy Build bug no:2661533,
  --                            New parameter p_legacy is added to following functions
  --                            enrp_val_sca_lapse,enrp_val_sca_dr,enrp_val_sca_discont.
  --ckasu      02-May-2006     Modified as a part of bug#5191592
  -------------------------------------------------------------------------------------------
   --msrinivi bug 1956364 Removed duplciate finp_val_fc_closed func
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed function ENRP_VAL_SCA_TRNSFR
  --
  --
  -- Validate candidature proposed commencement date.
  FUNCTION admp_val_ca_comm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_min_submission_dt IN DATE ,
  p_parent IN VARCHAR2 ,
  p_ca_sequence_number IN OUT NOCOPY NUMBER ,
  p_candidature_exists_ind OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  admp_val_ca_comm, WNDS);
  --
  -- Validate candidature proposed commencement date value.
  FUNCTION admp_val_ca_comm_val(
  p_person_id IN NUMBER ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_course_start_dt IN DATE ,
  p_prpsd_commencement_dt IN DATE ,
  p_parent IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( admp_val_ca_comm_val , WNDS);
  --
  -- Validate candidature attendance percentage
  FUNCTION resp_val_ca_att_perc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_attendance_type IN VARCHAR2 ,
  p_attendance_percentage IN NUMBER ,
  p_candidature_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( resp_val_ca_att_perc , WNDS);
  --
  -- Validate that conditional offer is valid for course enrolment.
  FUNCTION enrp_val_acai_cndtnl(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_cndtnl_off_must_be_stsfd_ind IN VARCHAR2 DEFAULT 'N',
  p_s_adm_cndtnl_offer_status OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES(  enrp_val_acai_cndtnl,WNDS,WNPS);
  --
  -- Validate that research detail is valid for enrolment.
  FUNCTION enrp_val_res_elgbl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES(  enrp_val_res_elgbl,WNDS,WNPS);
  --
  -- Validate if research candidature details are complete.
  FUNCTION resp_val_ca_dtl_comp(
  p_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_parent IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES( resp_val_ca_dtl_comp,WNDS,WNPS);

  --
  -- To validate student course attempt enrolled units satisfy rules.
  FUNCTION enrp_val_unit_rule(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_rule_check_ind IN VARCHAR2 DEFAULT 'N',
  p_unit_cd OUT NOCOPY VARCHAR2 ,
  p_uv_version_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_unit_rule , WNDS);
  --
  -- To validate sca UNIT calendars against academic calendar type
  FUNCTION ENRP_VAL_SCA_CAT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SCA_CAT , WNDS);
  --
  -- To validate the IGS_EN_STDNT_PS_ATT.lapse_dt
  FUNCTION ENRP_VAL_SCA_LAPSE(
  p_course_attempt_status       IN VARCHAR2 ,
  p_lapse_dt                    IN DATE ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2 DEFAULT 'N')
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SCA_LAPSE, WNDS);
  --
  --
  -- To validate acceptance of admission course transfer.
  FUNCTION enrp_val_trnsfr_acpt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_trnsfr_acpt , WNDS);
  --
  -- To validate whether a change of course offering option is allowed
  FUNCTION ENRP_VAL_CHGO_ALWD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_CHGO_ALWD , WNDS);
  --
  -- To validate all sua records against coo cross restrictions
  FUNCTION ENRP_VAL_SUA_COO(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_coo_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name1 OUT NOCOPY VARCHAR2 ,
  p_message_name2 OUT NOCOPY VARCHAR2,
  p_message_name3 OUT NOCOPY VARCHAR2 ,
  p_load_or_teach_cal_type IN VARCHAR2,
  p_load_or_teach_seq_number IN NUMBER)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SUA_COO, WNDS);
  --
  -- To validate confirmed indicator on student course attempt
  FUNCTION enrp_val_sca_confirm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_course_attempt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sca_confirm , WNDS);
  --
  -- To validate the sca attendance type against the coo restriction
  FUNCTION ENRP_VAL_COO_ATT(
  p_person_id IN NUMBER ,
  p_coo_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_attendance_types OUT NOCOPY VARCHAR2,
  p_load_or_teach_cal_type IN VARCHAR2,
  p_load_or_teach_seq_number IN NUMBER)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_COO_ATT, WNDS);
  --
  -- To validate the SCA discontinuation reason code
  FUNCTION enrp_val_sca_dr(
  p_person_id                   IN NUMBER,
  p_course_cd                   IN VARCHAR2,
  p_discontinuation_reason_cd   IN VARCHAR2,
  p_discontinued_dt             IN DATE,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sca_dr, WNDS);
  --
  -- To validate the course attempt against funding source restrictions
  FUNCTION ENRP_VAL_SCA_FSR(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SCA_FSR , WNDS);
  --
  -- To validate the discontinuation date and the reason cd
  FUNCTION enrp_val_sca_discont(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_version_number              IN NUMBER ,
  p_course_attempt_status       IN VARCHAR2 ,
  p_discontinuation_reason_cd   IN VARCHAR2 ,
  p_discontinued_dt             IN DATE ,
  p_commencement_dt             IN DATE ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sca_discont , WNDS);
  --
  -- Validate the course commencement date against the students birth date
  FUNCTION enrp_val_sca_comm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sca_comm , WNDS);
  --
  -- To validate the student course attempt funding source
  FUNCTION ENRP_VAL_SCA_FS(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SCA_FS , WNDS);
  --
  -- Validate the IGS_PS_OFR_PAT for a IGS_EN_STDNT_PS_ATT
  FUNCTION enrp_val_sca_cop(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sca_cop, WNDS);
  --


  -- A FUNCTION enrp_val_sca_fc in this package has been removed as this will not be invoked
  -- as per the build changes for the Fee clac Build (Bug 1851586)
  -- This function validates whether the Student Program Attempt had an assessment
  -- record with the specified Fee Category.
  -- was invoked from  IGS_EN_STDNT_PS_ATT_PKG.

  --

FUNCTION handle_rederive_prog_att(
p_person_id IN NUMBER ,
p_admission_appl_number IN NUMBER ,
p_nominated_course_cd IN VARCHAR2 ,
p_sequence_number IN NUMBER,
p_message OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_EN_VAL_SCA;

 

/
