--------------------------------------------------------
--  DDL for Package IGS_GR_VAL_GR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_VAL_GR" AUTHID CURRENT_USER AS
/* $Header: IGSGR10S.pls 115.9 2003/10/07 08:36:13 ijeddy ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of GRDP_VAL_AWARD_TYPE
  --                            removed .
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_aw_closed"
  --ijeddy      06-Oct-2003    Build  3129913, Program completion Validation.
  -------------------------------------------------------------------------------------------
  -- Check if a specifc encumbrance effect applies to a person encumbrance
  FUNCTION enrp_val_encmb_efct(
  p_person_id  HZ_PARTIES.party_id%TYPE,
  p_course_cd  IGS_PS_COURSE.course_cd%TYPE ,
  p_effective_dt  DATE ,
  p_encmb_effect_type  IGS_EN_ENCMB_EFCTTYP.s_encmb_effect_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate graduand student course attempt is a graduating course.
  FUNCTION grdp_val_gr_sca(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate Graduand Ceremony Round calendar instance.
  FUNCTION grdp_val_gr_crd_ci(
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate GRADUAND required details.
  FUNCTION grdp_val_gr_rqrd(
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_honours_level  VARCHAR2 DEFAULT NULL,
  p_sur_for_course_cd  IGS_GR_GRADUAND_ALL.sur_for_course_cd%TYPE ,
  p_sur_for_crs_version_number  IGS_GR_GRADUAND_ALL.sur_for_crs_version_number%TYPE ,
  p_sur_for_award_cd  IGS_GR_GRADUAND_ALL.sur_for_award_cd%TYPE ,
  p_conferral_dt  IGS_GR_GRADUAND_V.conferral_dt%TYPE DEFAULT NULL,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate graduand status.
  FUNCTION grdp_val_gr_gst(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_new_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_old_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate graduand approval status.
  FUNCTION grdp_val_gr_gas(
  p_person_id IN HZ_PARTIES.party_id%TYPE,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_new_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_old_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate system graduand type.
  FUNCTION GRDP_VAL_GR_TYPE(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_new_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_old_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate proxy details.
  FUNCTION grdp_val_gr_proxy(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_proxy_award_ind  IGS_GR_GRADUAND_ALL.proxy_award_ind%TYPE ,
  p_proxy_award_person_id  IGS_GR_GRADUAND_ALL.proxy_award_person_id%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Check for multiple instances of the same award for the person.
  FUNCTION grdp_val_gr_unique(
  p_person_id IN IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt IN IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_grd_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_grd_ci_sequence_num IN NUMBER ,
  p_award_course_cd IN IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number IN IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd IN IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the update of a graduand with graduand awards ceremonies.
  FUNCTION grdp_val_gr_upd(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate inserting or updating a graduand.
  FUNCTION grdp_val_gr_iu(
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the graduand has satisfied academic requirements for an award
  FUNCTION grdp_val_aw_eligible(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate graduand course award.
  FUNCTION grdp_val_gr_caw(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate if graduand approval status is closed.
  FUNCTION grdp_val_gas_closed(
  p_graduand_appr_status  IGS_GR_APRV_STAT.graduand_appr_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate if graduand status is closed.
  FUNCTION grdp_val_gst_closed(
  p_graduand_status  IGS_GR_STAT.graduand_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate if honours level is closed.
  FUNCTION grdp_val_hl_closed(
  p_honours_level IN VARCHAR2 DEFAULT NULL,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate graduand surrender for award.
  FUNCTION GRDP_VAL_GR_SUR_CAW(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_sur_for_course_cd  IGS_GR_GRADUAND_ALL.sur_for_course_cd%TYPE ,
  p_sur_for_crs_version_num  IGS_GR_GRADUAND_ALL.sur_for_crs_version_number%TYPE ,
  p_sur_for_award_cd  IGS_GR_GRADUAND_ALL.sur_for_award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_GR_VAL_GR;

 

/
