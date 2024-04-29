--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SUA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SUA" AUTHID CURRENT_USER AS
/* $Header: IGSEN68S.pls 120.2 2005/11/24 03:05:13 appldev ship $ */
  -------------------------------------------------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_STAFF_PRSN
  --                            removed .
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed .
  --kkillams    17-MAY-2002     New parameter is added to enrp_val_sua_ovrd_cp functionc w.r.t.
  --Sudhir 24-MAY-2002 Added out NOCOPY parameter for procedure enrp_val_discont_aus
  --svenkata    20-Nov-2002     Added a new parameter p_legacy to selectively carry out NOCOPY validations for legacy.
  --                            The following routines have been modified : enrp_val_sua_uoo , enrp_val_sua_enr_dt,
  --                            enrp_val_sua_advstnd,resp_val_sua_cnfrm,enrp_val_sua_discont,enrp_val_discont_aus
  -- amuthu     20-JAn-2003     Added the no_assessment_ind column to the function enrp_val_sua_ovrd_cp
  -- kkillams   28-04-2003      Added new parameter p_uoo_id to the enrp_get_sua_ausg, enrp_val_sua_dupl, enrp_val_sua_update
  --                            and enrp_val_sua_delete functions w.r.t. bug number 2829262
  -- svenkata   3-Jun-2003      The function ENRP_VAL_COO_CROSS has been removed. The same functionality has been implemented as
  --                            cross-element restrictions of Validations. Bug# 2829272
  -- svanukur   18-oct-2003    created procedures enr_sub_units and drop_sub_units as part of placements build 3052438
  -- ckasu      17-Nov-2004    modfied signature of  ENRP_VAL_SUA_CNFRM_P procedure by adding uoo_id and course_cd version
  --                           as apart of Program transfer Build#4000939
  -- bdeviset   24-Nov_2005    Added proc validate_mus for bug#4676023
  -------------------------------------------------------------------------------------------------------------------------------------------
  --
  --modified by sarakshi on 27-7-2001 to include p_uoo_id parameter in the function enrp_val_discont_aus

  TYPE t_sua_duplicate_record IS RECORD
  (
  v_person_id IGS_EN_SU_ATTEMPT_ALL.PERSON_ID%TYPE,
  v_course_cd IGS_EN_SU_ATTEMPT_ALL.COURSE_CD%TYPE,
  v_unit_cd IGS_EN_SU_ATTEMPT_ALL.UNIT_CD%TYPE,
  v_cal_type IGS_EN_SU_ATTEMPT_ALL.CAL_TYPE%TYPE,
  v_ci_sequence_number IGS_EN_SU_ATTEMPT_ALL.CI_SEQUENCE_NUMBER%TYPE,
  v_unit_attempt_status IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE);
  --
  --
  TYPE t_sua_discont_record IS RECORD
  (
  v_old_discontinued_dt IGS_EN_SU_ATTEMPT_ALL.DISCONTINUED_DT%TYPE,
  v_discont_rowid ROWID);
  --
  --
  TYPE t_sua_deleted_record IS RECORD
  (
  v_course_cd IGS_EN_SU_ATTEMPT_ALL.COURSE_CD%TYPE,
  v_person_id IGS_EN_SU_ATTEMPT_ALL.PERSON_ID%TYPE);
  --
  --
  TYPE t_sua_exists_record IS RECORD
  (
  v_exists_person_id IGS_EN_SU_ATTEMPT_ALL.PERSON_ID%TYPE,
  v_exists_course_cd IGS_EN_SU_ATTEMPT_ALL.COURSE_CD%TYPE,
  v_exists_unit_cd IGS_EN_SU_ATTEMPT_ALL.UNIT_CD%TYPE,
  v_exists_version_number IGS_EN_SU_ATTEMPT_ALL.VERSION_NUMBER%TYPE,
  v_exists_cal_type IGS_EN_SU_ATTEMPT_ALL.CAL_TYPE%TYPE,
  v_exists_ci_sequence_number IGS_EN_SU_ATTEMPT_ALL.CI_SEQUENCE_NUMBER%TYPE,
  v_exists_unit_attempt_status IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE);
  --
  --
  TYPE t_sua_duplicate_table IS TABLE OF
  IGS_EN_VAL_SUA.t_sua_duplicate_record
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_sua_discont_table IS TABLE OF
  IGS_EN_VAL_SUA.t_sua_discont_record
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_sua_deleted_table IS TABLE OF
  IGS_EN_VAL_SUA.t_sua_deleted_record
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_sua_exists_table IS TABLE OF
  IGS_EN_VAL_SUA.t_sua_exists_record
  INDEX BY BINARY_INTEGER;
  --

  --
  gt_sua_deleted_table t_sua_deleted_table;
  --
  --
  gt_sua_deleted_empty_table t_sua_deleted_table;
  --
  --
  gv_sua_deleted_table_index BINARY_INTEGER;
  --
  --
  gt_sua_duplicate_table t_sua_duplicate_table;
  --
  --
  gt_sua_duplicate_empty_table t_sua_duplicate_table;
  --
  --
  gv_sua_duplicate_table_index BINARY_INTEGER;
  --
  --
  gt_sua_exists_table t_sua_exists_table;
  --
  --
  gt_sua_exists_empty_table t_sua_exists_table;
  --
  --
  gv_sua_exists_table_index BINARY_INTEGER;
  --
  --
  gt_sua_discont_table t_sua_discont_table;
  --
  --
  gt_sua_discont_empty_table t_sua_discont_table;
  --
  --
  gv_sua_discont_table_index BINARY_INTEGER;

  --
  -- To validate the confirmation of a research unit attempt.
  FUNCTION RESP_VAL_SUA_CNFRM(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2 DEFAULT 'N'  )
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( RESP_VAL_SUA_CNFRM , WNDS);

  --
  -- To validate all research units in an academic period
  FUNCTION RESP_VAL_SUA_ALL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( RESP_VAL_SUA_ALL , WNDS);

  --
  -- To validate for student unit attempt being excluded
  FUNCTION ENRP_VAL_SUA_EXCLD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUA_EXCLD , WNDS);

  --
  -- To validate update of SUA.
FUNCTION enrp_val_sua_update(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_unit_attempt_status         IN VARCHAR2 ,
  p_new_version_number          IN NUMBER ,
  p_new_location_cd             IN VARCHAR2 ,
  p_new_unit_class              IN VARCHAR2 ,
  p_new_enrolled_dt             IN DATE ,
  p_new_discontinued_dt         IN DATE ,
  p_new_admin_unit_status       IN VARCHAR2 ,
  p_new_rule_waived_dt          IN DATE ,
  p_new_rule_waived_person_id   IN NUMBER ,
  p_new_no_assessment_ind       IN VARCHAR2 ,
  p_new_sup_unit_cd             IN VARCHAR2 ,
  p_new_sup_version_number      IN NUMBER ,
  p_new_exam_location_cd        IN VARCHAR2 ,
  p_old_version_number          IN NUMBER ,
  p_old_location_cd             IN VARCHAR2 ,
  p_old_unit_class              IN VARCHAR2 ,
  p_old_enrolled_dt             IN DATE ,
  p_old_discontinued_dt         IN DATE ,
  p_old_admin_unit_status       IN VARCHAR2 ,
  p_old_rule_waived_dt          IN DATE ,
  p_old_rule_waived_person_id   IN NUMBER ,
  p_old_no_assessment_ind       IN VARCHAR2 ,
  p_old_sup_unit_cd             IN VARCHAR2 ,
  p_old_sup_version_number      IN NUMBER ,
  p_old_exam_location_cd        IN VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN NUMBER)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sua_update , WNDS);

  --
  -- To validate SUA override credit reason
  FUNCTION enrp_val_sua_cp_rsn(
  p_override_enrolled_cp IN NUMBER ,
  p_override_achievable_cp IN NUMBER ,
  p_override_credit_reason IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sua_cp_rsn , WNDS);

  --
  -- Routine to clear records saved in a PL/SQL RECORD from a prior commit.
  PROCEDURE enrp_clear_sua_exist
;

  --
  -- To validate enrolled date of SUA.
  FUNCTION enrp_val_sua_ci(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_form_trigger_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sua_ci , WNDS);

  --
  -- To validate SUA alternative TITLE.
  FUNCTION enrp_val_sua_alt_ttl(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_alternative_title IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sua_alt_ttl, WNDS);

  --
  -- Routine to clear records saved in a PL/SQL RECORD from a prior commit.
  PROCEDURE enrp_clear_sua_dupl
;

  --
  -- Validate whether unit attempt can be pre-enrolled
  FUNCTION ENRP_VAL_SUA_PRE(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_log_creation_dt IN DATE ,
  p_warn_level OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
  --
  -- To validate SUA advanced standing unit.
  FUNCTION enrp_val_sua_advstnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crs_version_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_un_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sua_advstnd, WNDS);

  --
  -- To validate the insertion of an sua against any intermissions
  FUNCTION ENRP_VAL_SUA_INTRMT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUA_INTRMT , WNDS);

  --
  -- Routine to clear records saved in a PL/SQL RECORD from a prior commit.
  PROCEDURE enrp_clear_sua_disc
;

  --
  -- Validate the discontinued administrative unit status.
  FUNCTION enrp_val_discont_aus(
  p_administrative_unit_status IN VARCHAR2 ,
  p_discontinued_dt IN DATE ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_uoo_id IN NUMBER DEFAULT NULL,
  p_message_token OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2 DEFAULT 'N'  )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_discont_aus, WNDS);

  --
  -- Get SUA grading schema.
  FUNCTION enrp_get_sua_gs(
  p_effective_dt IN DATE ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_version_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_get_sua_gs, WNDS);

  --
  -- Get SUA administrative unit status grade.
 FUNCTION enrp_get_sua_ausg(
  p_administrative_unit_status  IN VARCHAR2 ,
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_effective_dt                IN DATE ,
  p_grading_schema_cd           OUT NOCOPY VARCHAR2 ,
  p_version_number              OUT NOCOPY NUMBER ,
  p_grade                       OUT NOCOPY VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN NUMBER)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_get_sua_ausg , WNDS);

  --
  -- To validate the discontinuation date
  FUNCTION enrp_val_sua_discont(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_ci_start_dt IN DATE ,
  p_enrolled_dt IN DATE ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_discontinued_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2 DEFAULT 'N'  )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sua_discont , WNDS);

  --
  -- To validate enrolled date of SUA.
  FUNCTION enrp_val_sua_enr_dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_enrolled_dt IN DATE ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_ci_end_dt IN DATE ,
  p_commencement_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sua_enr_dt , WNDS);

  --
  --
  -- To validate deletion of the student unit attempt
  FUNCTION enrp_val_sua_delete(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_form_trigger_ind    IN VARCHAR2 DEFAULT 'N' ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_discontinued_dt     IN DATE ,
  p_effective_dt        IN DATE ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sua_delete, WNDS);

  --
  -- To validate insert of SUA.
  FUNCTION enrp_val_sua_insert(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sua_insert , WNDS);

  --
  -- Validate the confirmation of a student unit attempt.
  FUNCTION ENRP_VAL_SUA_CNFRM(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number  NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ci_end_dt IN DATE ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_enrolled_dt IN DATE ,
  p_fail_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUA_CNFRM , WNDS);

  --
  -- Validate the IGS_PS_COURSE against a posted change to student unit attempt.
 FUNCTION ENRP_VAL_SUA_CNFRM_P(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2,
  p_course_version IN NUMBER,
  p_coo_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_uoo_id    IN NUMBER,
  p_fail_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 ,
  p_message_name2 OUT NOCOPY varchar2 )
  RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SUA_CNFRM_P , WNDS);

  --
  -- To validate SUA override credit point values
  FUNCTION enrp_val_sua_ovrd_cp(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_achievable_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_uoo_id IN NUMBER DEFAULT NULL,
  p_no_assessment_ind IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sua_ovrd_cp , WNDS);

  --
  -- To validate SUA RULE waived date.
  FUNCTION enrp_val_sua_rule_wv(
  p_rule_waived_dt IN DATE ,
  p_enrolled_dt IN DATE ,
  p_rule_waived_person_id IN OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sua_rule_wv, WNDS);

  --


  --
  -- To validate SUA unit offering option.
  FUNCTION enrp_val_sua_uoo(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy  IN VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sua_uoo, WNDS);

  --
  -- To validate sca LOCATION code against coo restriction
  FUNCTION ENRP_VAL_COO_LOC(
  p_coo_id IN NUMBER ,
  p_unit_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_COO_LOC , WNDS);

  --
  -- To validate the sca att mode against coo restriction
  FUNCTION ENRP_VAL_COO_MODE(
  p_coo_id IN NUMBER ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_COO_MODE , WNDS);
  --
  -- To validate for student unit attempt being duplicated
  FUNCTION enrp_val_sua_dupl(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_uv_version_number   IN NUMBER ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_duplicate_course_cd OUT NOCOPY VARCHAR2 ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sua_dupl, WNDS);

PROCEDURE enr_sub_units(
p_person_id           IN NUMBER ,
p_course_cd           IN VARCHAR2 ,
p_uoo_id              IN NUMBER,
p_waitlist_flag       IN VARCHAR2,
p_load_cal_type       IN VARCHAR2,
p_load_seq_num        IN NUMBER,
p_enrollment_date     IN DATE ,
p_enrollment_method   IN VARCHAR2,
p_enr_uoo_ids         IN VARCHAR2,
p_uoo_ids             OUT NOCOPY VARCHAR2,
p_waitlist_uoo_ids     OUT NOCOPY VARCHAR2,
p_failed_uoo_ids      OUT NOCOPY VARCHAR2);

Procedure drop_sub_units(
p_person_id         IN      NUMBER,
p_course_cd         IN      VARCHAR2,
p_uoo_id            IN      NUMBER,
p_load_cal_type     IN      VARCHAR2,
p_load_seq_num      IN      NUMBER,
p_acad_cal_type     IN      VARCHAR2,
p_acad_seq_num      IN      NUMBER,
p_enrollment_method IN      VARCHAR2,
p_confirmed_ind     IN      VARCHAR2,
p_person_type       IN      VARCHAR2,
p_effective_date    IN      DATE,
p_course_ver_num    IN      NUMBER,
p_dcnt_reason_cd    IN      VARCHAR2,
p_admin_unit_status IN       VARCHAR2,
p_uoo_ids           OUT    NOCOPY VARCHAR2,
p_error_message     OUT    NOCOPY VARCHAR2);


PROCEDURE validate_mus(
p_person_id             IN NUMBER,
p_course_cd             IN VARCHAR2,
p_uoo_id                IN NUMBER
);


END IGS_EN_VAL_SUA;

 

/
