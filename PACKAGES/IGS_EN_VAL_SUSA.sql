--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SUSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SUSA" AUTHID CURRENT_USER AS
/* $Header: IGSEN69S.pls 115.5 2002/11/29 00:08:19 nsidana ship $ */
  --
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .Function genp_val_staff_prsn Removed
  --smadathi    24-AUG-2001     Bug No. 1956374 .Function genp_val_sdtt_sess Removed
 --msrinivi     27-AUG-2001     Bug 1956374  Func genp_val_prsn_id removed
 --prraj        15-Nov-2002     Added p_legacy parameter to functions enrp_val_susa_ins, enrp_val_susa_auth,
 --                             enrp_val_susa_cmplt, enrp_val_susa_sci_sd, enrp_val_susa_cousr, enrp_val_susa_parent,
 --                             enrp_val_susa_end_dt, enrp_val_susa_sci, enrp_val_susa_prmry as part of Legacy
 --                             build Bug# 2661533
  -------------------------------------------------------------------------------------------
  TYPE t_susa_rowid_record IS RECORD
  (
  v_rowid ROWID,
  v_parent_unit_set_cd IGS_AS_SU_SETATMPT.PARENT_UNIT_SET_CD%TYPE,
  v_end_dt IGS_AS_SU_SETATMPT.END_DT%TYPE,
  v_student_confirmed_ind IGS_AS_SU_SETATMPT.STUDENT_CONFIRMED_IND%TYPE,
  v_primary_set_ind IGS_AS_SU_SETATMPT.PRIMARY_SET_IND%TYPE);
  --
  --


  --
  -- Validate the authorisation fields.
  FUNCTION enrp_val_susa_auth(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_end_dt IN IGS_AS_SU_SETATMPT.end_dt%TYPE ,
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_message_name OUT NOCOPY  VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
  --
--PRAGMA RESTRICT_REFERENCES(enrp_val_susa_auth  , WNDS);
  -- Validate the requirement complete fields for IGS_AS_SU_SETATMPT.
  FUNCTION enrp_val_susa_cmplt(
  p_rqrmnts_complete_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
  --
--PRAGMA RESTRICT_REFERENCES(enrp_val_susa_cmplt  , WNDS);

  -- Validate the susa relationship exists in cousr
  FUNCTION ENRP_VAL_SUSA_COUSR(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_message_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_COUSR , WNDS);

  --
  -- Validate the student unit set attempt is able to be deleted.
  FUNCTION ENRP_VAL_SUSA_DEL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_end_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_db_trg_call IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_DEL , WNDS);
  --
  -- Validate the date fields associated with a student unit set attempt.
  FUNCTION ENRP_VAL_SUSA_DTS(
  p_selection_dt IN DATE ,
  p_end_dt IN DATE ,
  p_rqrmnts_complete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SUSA_DTS, WNDS);

  --
  -- Validate the student unit set attempt end date.
  FUNCTION ENRP_VAL_SUSA_END_DT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_end_dt IN DATE ,
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_message_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_END_DT , WNDS);

  --
  -- Validate student unit set atmpt voluntary end indicator and end date.
  FUNCTION ENRP_VAL_SUSA_END_VI(
  p_voluntary_end_ind IN VARCHAR2 DEFAULT 'N',
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_END_VI , WNDS);

  --
  -- Validate the student unit set attempt is able to be created.
  FUNCTION ENRP_VAL_SUSA_INS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SUSA_INS, WNDS);
  --
  -- Validate the linking of parent unit set to student unit set attempt .
  FUNCTION ENRP_VAL_SUSA_PARENT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_PARENT , WNDS);
  --
  -- Validate the IGS_AS_SU_SETATMPT.primary_set_ind field.
  FUNCTION ENRP_VAL_SUSA_PRMRY(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_primary_set_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_PRMRY , WNDS);
  --
  -- Validate the student unit set attempt against for the stdnt crs atmpt.
  FUNCTION ENRP_VAL_SUSA_SCA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_SCA , WNDS);

  --
  -- Validate the student unit set attempt confirmation indicator.
  FUNCTION ENRP_VAL_SUSA_SCI(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_selection_dt IN DATE ,
  p_end_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_SCI , WNDS);

  --
  -- Validate the student unit set attempt confirmation rules.
  FUNCTION ENRP_VAL_SUSA_SCI_RL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_new_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_old_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_SCI_RL , WNDS);

  --
  -- Validate student unit set atmpt confirm indicator and selection date.
  FUNCTION ENRP_VAL_SUSA_SCI_SD(
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_selection_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SUSA_SCI_SD , WNDS);
  --
  -- Validate the unit set is active for student unit set attempt.
  FUNCTION ENRP_VAL_SUSA_US_ACT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(ENRP_VAL_SUSA_US_ACT  , WNDS);

  --
  -- Validate the student unit set attempt requires authorisation.
  FUNCTION ENRP_VAL_SUSA_US_ATH(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_US_ATH , WNDS);
  --
  -- Validation routines for student unit set attempt.
  FUNCTION ENRP_VAL_SUSA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_selection_dt IN DATE ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_end_dt IN DATE ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_primary_set_ind IN VARCHAR2 DEFAULT 'N',
  p_voluntary_end_ind IN VARCHAR2 DEFAULT 'N',
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_override_title IN VARCHAR2 ,
  p_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_rqrmnts_complete_dt IN DATE ,
  p_s_completed_source_type IN VARCHAR2 ,
  p_action IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA , WNDS);

  --
  -- Validate the cascading setting of the end date of an susa record.
  FUNCTION ENRP_VAL_SUSA_ED_UPD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_end_dt IN DATE ,
  p_voluntary_end_ind IN VARCHAR2 DEFAULT 'N',
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SUSA_ED_UPD, WNDS);
  --
  -- Validate cascade unsetting of stdnt unit set atmpt confirmation ind.
  FUNCTION ENRP_VAL_SUSA_SCI_UP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUSA_SCI_UP , WNDS);
  --
  -- Validate the requirement complete fields for IGS_AS_SU_SETATMPT.
  FUNCTION enrp_val_susa_scst(
  p_rqrmnts_complete_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_s_completed_source_type IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY  VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_susa_scst , WNDS);

END IGS_EN_VAL_SUSA;

 

/
