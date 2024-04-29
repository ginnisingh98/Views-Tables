--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SPO" AUTHID CURRENT_USER AS
/* $Header: IGSPR21S.pls 115.7 2002/11/29 02:49:29 nsidana ship $ */

   --msrinivi bug 1956374 Removed genp_prc_clear_row_id --
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_POT_CLOSED) - from the spec and body. -- kdande
*/
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_att_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_active"
  -------------------------------------------------------------------------------------------
  --

  TYPE r_spo_record_type IS RECORD

  (

  person_id IGS_PR_STDNT_PR_OU_ALL.PERSON_ID%TYPE,

  course_cd IGS_PR_STDNT_PR_OU_ALL.COURSE_CD%TYPE,

  sequence_number IGS_PR_STDNT_PR_OU_ALL.SEQUENCE_NUMBER%TYPE,

  prg_cal_type IGS_PR_STDNT_PR_OU_ALL.PRG_CAL_TYPE%TYPE,

  prg_ci_sequence_number IGS_PR_STDNT_PR_OU_ALL.PRG_CI_SEQUENCE_NUMBER%TYPE,

  rule_check_dt IGS_PR_STDNT_PR_OU_ALL.RULE_CHECK_DT%TYPE,

  progression_rule_cat IGS_PR_STDNT_PR_OU_ALL.PROGRESSION_RULE_CAT%TYPE,


  pra_sequence_number IGS_PR_STDNT_PR_OU_ALL.PRA_SEQUENCE_NUMBER%TYPE,

  progression_outcome_type IGS_PR_STDNT_PR_OU_ALL.PROGRESSION_OUTCOME_TYPE%TYPE,

  old_decision_status IGS_PR_STDNT_PR_OU_ALL.DECISION_STATUS%TYPE,

  new_decision_status IGS_PR_STDNT_PR_OU_ALL.DECISION_STATUS%TYPE,

  decision_dt IGS_PR_STDNT_PR_OU_ALL.DECISION_DT%TYPE,

  decision_org_unit_cd IGS_PR_STDNT_PR_OU_ALL.DECISION_ORG_UNIT_CD%TYPE,

  decision_ou_start_dt IGS_PR_STDNT_PR_OU_ALL.DECISION_OU_START_DT%TYPE,

  applied_dt IGS_PR_STDNT_PR_OU_ALL.APPLIED_DT%TYPE,

  expiry_dt IGS_PR_STDNT_PR_OU_ALL.EXPIRY_DT%TYPE,

  encmb_course_group_cd IGS_PR_STDNT_PR_OU_ALL.ENCMB_COURSE_GROUP_CD%TYPE,

  restricted_enrolment_cp IGS_PR_STDNT_PR_OU_ALL.RESTRICTED_ENROLMENT_CP%TYPE,


  restricted_attendance_type IGS_PR_STDNT_PR_OU_ALL.RESTRICTED_ATTENDANCE_TYPE%TYPE,

  new_duration IGS_PR_STDNT_PR_OU_ALL.DURATION%TYPE,

  old_duration_type IGS_PR_STDNT_PR_OU_ALL.DURATION_TYPE%TYPE,

  new_duration_type IGS_PR_STDNT_PR_OU_ALL.DURATION_TYPE%TYPE,

  old_duration IGS_PR_STDNT_PR_OU_ALL.DURATION%TYPE);

  --

  --

  TYPE t_spo_table IS TABLE OF

  igs_pr_val_spo.r_spo_record_type

  INDEX BY BINARY_INTEGER;

  --

  --


  gt_rowid_table t_spo_table;

  --

  --

  gt_empty_table t_spo_table;

  --

  --

  gv_table_index BINARY_INTEGER;

  --

  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_spo_rowids(

  p_inserting IN BOOLEAN ,


  p_updating IN BOOLEAN ,

  p_deleting IN BOOLEAN ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome decision status changes

  FUNCTION prgp_val_spo_dcsn(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_ci_sequence_number IN NUMBER ,

  p_rule_check_dt IN DATE ,


  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_progression_outcome_type IN VARCHAR2 ,

  p_old_decision_status IN VARCHAR2 ,

  p_new_decision_status IN VARCHAR2 ,

  p_decision_dt IN DATE ,

  p_decision_org_unit_cd IN VARCHAR2 ,

  p_decision_ou_start_dt IN DATE ,

  p_applied_dt IN DATE ,

  p_expiry_dt IN DATE ,

  p_message_name OUT NOCOPY VARCHAR2 )


RETURN BOOLEAN;

  --

  -- Validate student progression outcome decision date

  FUNCTION prgp_val_spo_dcsn_dt(

  p_decision_dt IN DATE ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome show cause date

  FUNCTION prgp_val_spo_sc_dt(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,


  p_applied_dt IN DATE ,

  p_decision_dt IN DATE ,

  p_decision_status IN VARCHAR2 ,

  p_show_cause_expiry_dt IN DATE ,

  p_old_show_cause_dt IN DATE ,

  p_new_show_cause_dt IN DATE ,

  p_show_cause_outcome_dt IN DATE ,

  p_appeal_dt IN DATE ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --


  -- Validate student progression outcome show cause expiry date

  FUNCTION prgp_val_spo_sc_exp(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_ci_sequence_number IN NUMBER ,

  p_decision_status IN VARCHAR2 ,

  p_old_show_cause_expiry_dt IN DATE ,

  p_new_show_cause_expiry_dt IN DATE ,

  p_show_cause_dt IN DATE ,

  p_show_cause_outcome_dt IN DATE ,

  p_appeal_expiry_dt IN DATE ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome show cause outcome date

  FUNCTION prgp_val_spo_sc_out(

  p_decision_status IN VARCHAR2 ,

  p_show_cause_dt IN DATE ,

  p_show_cause_outcome_dt IN DATE ,

  p_show_cause_outcome_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


  --

  -- Validate student progression outcome appeal date

  FUNCTION prgp_val_spo_apl_dt(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_applied_dt IN DATE ,

  p_decision_dt IN DATE ,

  p_decision_status IN VARCHAR2 ,

  p_appeal_expiry_dt IN DATE ,

  p_old_appeal_dt IN DATE ,

  p_new_appeal_dt IN DATE ,

  p_appeal_outcome_dt IN DATE ,


  p_show_cause_dt IN DATE ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome appeal expiry date

  FUNCTION prgp_val_spo_apl_exp(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_ci_sequence_number IN NUMBER ,

  p_decision_status IN VARCHAR2 ,

  p_old_appeal_expiry_dt IN DATE ,

  p_new_appeal_expiry_dt IN DATE ,

  p_appeal_dt IN DATE ,

  p_appeal_outcome_dt IN DATE ,

  p_show_cause_expiry_dt IN DATE ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome appeal outcome date

  FUNCTION prgp_val_spo_apl_out(

  p_old_decision_status IN VARCHAR2 ,

  p_appeal_dt IN DATE ,

  p_appeal_outcome_dt IN DATE ,

  p_appeal_outcome_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Get applied date if student progression outcome detail has changed

  FUNCTION prgp_GET_SPO_APLY_DT(

  p_decision_status IN VARCHAR2 ,

  p_old_applied_dt IN DATE ,

  p_new_applied_dt IN DATE ,

  p_old_encmb_course_group_cd IN VARCHAR2 ,

  p_new_encmb_course_group_cd IN VARCHAR2 ,

  p_old_restricted_enrolment_cp IN NUMBER ,

  p_new_restricted_enrolment_cp IN NUMBER ,

  p_old_restricted_attend_type IN VARCHAR2 ,

  p_new_restricted_attend_type IN VARCHAR2 ,

  p_old_expiry_dt IN DATE ,

  p_new_expiry_dt IN DATE ,

  p_old_duration IN NUMBER ,

  p_new_duration IN NUMBER ,

  p_old_duration_type IN VARCHAR2 ,

  p_new_duration_type IN VARCHAR2 ,

  p_out_applied_dt OUT NOCOPY DATE )

RETURN BOOLEAN;


  --

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_spo_rowid(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,


  p_prg_cal_type IN VARCHAR2 ,

  p_prg_ci_sequence_number IN NUMBER ,

  p_rule_check_dt IN DATE ,

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_progression_outcome_type IN VARCHAR2 ,

  p_old_decision_status IN VARCHAR2 ,

  p_new_decision_status IN VARCHAR2 ,

  p_decision_dt IN DATE ,

  p_decision_org_unit_cd IN VARCHAR2 ,

  p_decision_ou_start_dt IN DATE ,

  p_applied_dt IN DATE ,


  p_expiry_dt IN DATE ,

  p_encmb_course_group_cd IN VARCHAR2 ,

  p_restricted_enrolment_cp IN NUMBER ,

  p_restricted_attendance_type IN VARCHAR2 ,

  p_old_duration IN NUMBER ,

  p_new_duration IN NUMBER ,

  p_old_duration_type IN VARCHAR2 ,

  p_new_duration_type IN VARCHAR2 ) ;

  --

  -- Validate progression calendar instance


  FUNCTION prgp_val_prg_ci(

  p_cal_type IN VARCHAR2 ,

  p_ci_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome can be inserted

  FUNCTION prgp_val_spo_ins(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_ci_sequence_number IN NUMBER ,


  p_rule_check_dt IN DATE ,

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome has the required details

  FUNCTION prgp_val_spo_rqrd(

  p_progression_outcome_type IN VARCHAR2 ,

  p_duration IN NUMBER ,

  p_duration_type IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome restricted attendance type

  FUNCTION prgp_val_spo_att(

  p_progression_outcome_type IN VARCHAR2 ,

  p_restricted_attendance_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome encumbered course group code

  FUNCTION prgp_val_spo_cgr(


  p_progression_outcome_type IN VARCHAR2 ,

  p_encmb_course_group_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome restricted enrolment cp's

  FUNCTION prgp_val_spo_cp(

  p_progression_outcome_type IN VARCHAR2 ,

  p_restricted_enrolment_cp IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


  --

  -- Validate student progression outcome duration/duration type changes

  FUNCTION prgp_val_spo_drtn(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_decision_status IN VARCHAR2 ,

  p_old_duration IN NUMBER ,

  p_new_duration IN NUMBER ,

  p_old_duration_type IN VARCHAR2 ,

  p_new_duration_type IN VARCHAR2 ,

  p_expiry_dt IN DATE ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate if course_group.course_group_cd is closed.

  FUNCTION crsp_val_cgr_closed(


  p_course_group_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  --

  -- Validate student progression outcome decision status of APPROVED

  FUNCTION prgp_val_spo_approve(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_progression_outcome_type IN VARCHAR2 ,

  p_old_decision_status IN VARCHAR2 ,

  p_new_decision_status IN VARCHAR2 ,

  p_encmb_course_group_cd IN VARCHAR2 ,

  p_restricted_enrolment_cp IN NUMBER ,

  p_restricted_attendance_type IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome applied date

  FUNCTION prgp_val_spo_aply_dt(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_old_applied_dt IN DATE ,

  p_new_applied_dt IN DATE ,

  p_decision_status IN VARCHAR2 ,

  p_decision_dt IN DATE ,


  p_show_cause_expiry_dt IN DATE ,

  p_show_cause_outcome_dt IN DATE ,

  p_appeal_expiry_dt IN DATE ,

  p_appeal_outcome_dt IN DATE ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome show cause

  FUNCTION prgp_val_spo_cause(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_progression_rule_cat IN VARCHAR2 ,


  p_pro_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,

  p_show_cause_dt IN DATE ,

  p_show_cause_expiry_dt IN DATE ,

  p_show_cause_outcome_dt IN DATE ,

  p_show_cause_outcome_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome appeal

  FUNCTION prgp_val_spo_appeal(


  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_progression_rule_cat IN VARCHAR2 ,

  p_pro_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,

  p_appeal_dt IN DATE ,

  p_appeal_expiry_dt IN DATE ,

  p_appeal_outcome_dt IN DATE ,

  p_appeal_outcome_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --


  -- Validate student progression outcome outcome type is not being changed

  FUNCTION prgp_val_spo_pot(

  p_old_progression_outcome_type IN VARCHAR2 ,

  p_new_progression_outcome_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate student progression outcome expiry date

  FUNCTION prgp_val_spo_exp_dt(

  p_expiry_dt IN DATE ,

  p_message_name OUT NOCOPY VARCHAR2 )


RETURN BOOLEAN;

END igs_pr_val_spo;

 

/
