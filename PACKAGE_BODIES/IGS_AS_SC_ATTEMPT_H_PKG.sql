--------------------------------------------------------
--  DDL for Package Body IGS_AS_SC_ATTEMPT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SC_ATTEMPT_H_PKG" AS
/* $Header: IGSDI19B.pls 115.13 2003/12/04 13:07:26 rvangala ship $ */

l_rowid VARCHAR2(25);
  old_references IGS_AS_SC_ATTEMPT_H_ALL%ROWTYPE;
  new_references IGS_AS_SC_ATTEMPT_H_ALL%ROWTYPE;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_progression_status IN VARCHAR2 DEFAULT NULL,
    x_derived_att_type IN VARCHAR2 DEFAULT NULL,
    x_derived_att_mode IN VARCHAR2 DEFAULT NULL,
    x_provisional_ind IN VARCHAR2 DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_discontinuation_reason_cd IN VARCHAR2 DEFAULT NULL,
    x_lapsed_dt IN DATE DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_fs_description IN VARCHAR2 DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_elo_description IN VARCHAR2 DEFAULT NULL,
    x_derived_completion_yr IN NUMBER DEFAULT NULL,
    x_derived_completion_perd IN VARCHAR2 DEFAULT NULL,
    x_nominated_completion_yr IN NUMBER DEFAULT NULL,
    x_nominated_completion_perd IN VARCHAR2 DEFAULT NULL,
    x_rule_check_ind IN VARCHAR2 DEFAULT NULL,
    x_waive_option_check_ind IN VARCHAR2 DEFAULT NULL,
    x_last_rule_check_dt IN DATE DEFAULT NULL,
    x_publish_outcomes_ind IN VARCHAR2 DEFAULT NULL,
    x_course_rqrmnt_complete_ind IN VARCHAR2 DEFAULT NULL,
    x_course_rqrmnts_complete_dt IN DATE DEFAULT NULL,
    x_s_completed_source_type IN VARCHAR2 DEFAULT NULL,
    x_override_time_limitation IN NUMBER DEFAULT NULL,
    x_advanced_standing_ind IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fc_description IN VARCHAR2 DEFAULT NULL,
    x_correspondence_cat IN VARCHAR2 DEFAULT NULL,
    x_cc_description IN VARCHAR2 DEFAULT NULL,
    x_self_help_group_ind IN VARCHAR2 DEFAULT NULL,
    x_adm_admission_appl_number IN NUMBER DEFAULT NULL,
    x_adm_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_adm_sequence_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_student_confirmed_ind IN VARCHAR2 DEFAULT NULL,
    x_commencement_dt IN DATE DEFAULT NULL,
    x_course_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_last_date_of_attendance IN DATE DEFAULT NULL,
    x_dropped_by  IN VARCHAR2 DEFAULT NULL,
    x_primary_program_type IN VARCHAR2 DEFAULT NULL,
    x_primary_prog_type_source IN VARCHAR2 DEFAULT NULL,
    x_catalog_cal_type IN VARCHAR2 DEFAULT NULL,
    x_catalog_seq_num IN NUMBER DEFAULT NULL,
    x_key_program IN VARCHAR2 DEFAULT 'N',
    x_override_cmpl_dt  IN DATE DEFAULT NULL,
    x_manual_ovr_cmpl_dt_ind  IN VARCHAR2 DEFAULT 'N',
    x_coo_id   IN NUMBER DEFAULT NULL,
    x_igs_pr_class_std_id IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_SC_ATTEMPT_H_ALL
      WHERE    ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action  NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      CLOSE cur_old_ref_values;
      APP_EXCEPTION.RAISE_EXCEPTION;

      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.progression_status := x_progression_status;
    new_references.derived_att_type := x_derived_att_type;
    new_references.derived_att_mode := x_derived_att_mode;
    new_references.provisional_ind := x_provisional_ind;
    new_references.discontinued_dt := x_discontinued_dt;
    new_references.discontinuation_reason_cd:= x_discontinuation_reason_cd;
    new_references.lapsed_dt := x_lapsed_dt;
    new_references.funding_source:= x_funding_source;
    new_references.fs_description := x_fs_description;
    new_references.exam_location_cd := x_exam_location_cd;
    new_references.elo_description := x_elo_description;
    new_references.derived_completion_yr := x_derived_completion_yr;
    new_references.derived_completion_perd := x_derived_completion_perd;
    new_references.nominated_completion_yr := x_nominated_completion_yr;
    new_references.nominated_completion_perd := x_nominated_completion_perd;
    new_references.rule_check_ind := x_rule_check_ind;
    new_references.waive_option_check_ind := x_waive_option_check_ind;
    new_references.last_rule_check_dt := x_last_rule_check_dt;
    new_references.publish_outcomes_ind := x_publish_outcomes_ind;
    new_references.course_rqrmnt_complete_ind := x_course_rqrmnt_complete_ind;
    new_references.course_rqrmnts_complete_dt := x_course_rqrmnts_complete_dt;
    new_references.s_completed_source_type := x_s_completed_source_type;
    new_references.override_time_limitation := x_override_time_limitation;
    new_references.advanced_standing_ind := x_advanced_standing_ind;
    new_references.fee_cat:= x_fee_cat;
    new_references.fc_description := x_fc_description;
    new_references.correspondence_cat:= x_correspondence_cat;
    new_references.cc_description := x_cc_description;
    new_references.self_help_group_ind := x_self_help_group_ind;
    new_references.adm_admission_appl_number := x_adm_admission_appl_number;
    new_references.adm_nominated_course_cd := x_adm_nominated_course_cd;
    new_references.adm_sequence_number := x_adm_sequence_number;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.version_number := x_version_number;
    new_references.cal_type:= x_cal_type;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode:= x_attendance_mode;
    new_references.attendance_type:= x_attendance_type;
    new_references.student_confirmed_ind := x_student_confirmed_ind;
    new_references.commencement_dt := x_commencement_dt;
    new_references.course_attempt_status := x_course_attempt_status;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.last_date_of_attendance:=x_last_date_of_attendance;
    new_references.dropped_by:=x_dropped_by;
    new_references.primary_program_type:=x_primary_program_type;
    new_references.primary_prog_type_source:=x_primary_prog_type_source;
    new_references.catalog_cal_type:=x_catalog_cal_type;
    new_references.catalog_seq_num:=x_catalog_seq_num;
    new_references.key_program:=x_key_program;
    new_references.override_cmpl_dt  := x_override_cmpl_dt;
    new_references.manual_ovr_cmpl_dt_ind  := x_manual_ovr_cmpl_dt_ind;
    new_references.coo_id  := x_coo_id;
    new_references.igs_pr_class_std_id := x_igs_pr_class_std_id;

  END Set_Column_Values;

 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-May-2002   removed upper check constraint on fee_cat column.bug#2344826.
  ----------------------------------------------------------------------------*/

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name IS NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'NOMINATED_COMPLETION_PERD' THEN
        new_references.nominated_completion_perd := column_value;
    ELSIF  UPPER(column_name) = 'LOCATION_CD' THEN
        new_references.location_cd := column_value;
    ELSIF  UPPER(column_name) = 'FUNDING_SOURCE' THEN
        new_references.funding_source := column_value;
    ELSIF  UPPER(column_name) = 'EXAM_LOCATION_CD' THEN
        new_references.exam_location_cd := column_value;
    ELSIF  UPPER(column_name) = 'DISCONTINUATION_REASON_CD' THEN
        new_references.DISCONTINUATION_REASON_CD := column_value;
    ELSIF  UPPER(column_name) = 'DERIVED_COMPLETION_PERD' THEN
        new_references.derived_completion_perd := column_value;
    ELSIF  UPPER(column_name) = 'DERIVED_ATT_TYPE' THEN
        new_references.derived_att_type := column_value;
    ELSIF  UPPER(column_name) = 'DERIVED_ATT_MODE' THEN
        new_references.derived_att_mode := column_value;
    ELSIF  UPPER(column_name) = 'COURSE_RQRMNT_COMPLETE_IND' THEN
        new_references.course_rqrmnt_complete_ind := column_value;
    ELSIF  UPPER(column_name) = 'COURSE_CD' THEN
        new_references.course_cd := column_value;
    ELSIF  UPPER(column_name) = 'COURSE_ATTEMPT_STATUS' THEN
        new_references.course_attempt_status := column_value;
    ELSIF  UPPER(column_name) = 'CORRESPONDENCE_CAT' THEN
        new_references.correspondence_cat := column_value;
    ELSIF  UPPER(column_name) = 'CAL_TYPE' THEN
        new_references.cal_type := column_value;
    ELSIF  UPPER(column_name) = 'ATTENDANCE_TYPE' THEN
        new_references.attendance_type := column_value;
    ELSIF  UPPER(column_name) = 'ATTENDANCE_MODE' THEN
        new_references.attendance_mode := column_value;
    ELSIF  UPPER(column_name) = 'ADM_NOMINATED_COURSE_CD' THEN
        new_references.adm_nominated_course_cd := column_value;
    ELSIF  UPPER(column_name) = 'PROVISIONAL_IND ' THEN
        new_references.provisional_ind  := column_value;
    ELSIF  UPPER(column_name) = 'WAIVE_OPTION_CHECK_IND' THEN
        new_references.waive_option_check_ind := column_value;
    ELSIF  UPPER(column_name) = 'SELF_HELP_GROUP_IND ' THEN
        new_references.self_help_group_ind  := column_value;
    ELSIF  UPPER(column_name) = 'ADM_SEQUENCE_NUMBER' THEN
        new_references.adm_sequence_number := igs_ge_number.to_num(column_value);
    ELSIF  UPPER(column_name) = 'COURSE_RQRMNT_COMPLETE_IND' THEN
        new_references.course_rqrmnt_complete_ind := column_value;
    ELSIF  UPPER(column_name) = 'ADVANCED_STANDING_IND ' THEN
        new_references.advanced_standing_ind  := column_value;
    ELSIF  UPPER(column_name) = 'PUBLISH_OUTCOMES_IND' THEN
        new_references.publish_outcomes_ind := column_value;
    ELSIF  UPPER(column_name) = 'RULE_CHECK_IND ' THEN
        new_references.rule_check_ind  := column_value;
    ELSIF  UPPER(column_name) = 'STUDENT_CONFIRMED_IND' THEN
        new_references.student_confirmed_ind := column_value;
    ELSIF  UPPER(column_name) = 'MANUAL_OVR_CMPL_DT_IND' THEN
        new_references.manual_ovr_cmpl_dt_ind := column_value;
    ELSIF  UPPER(column_name) = 'COO_ID' THEN
        new_references.coo_id := column_value;
    ELSIF  UPPER(column_name) = 'IGS_PR_CLASS_STD_ID' THEN
        new_references.igs_pr_class_std_id := column_value;
    END IF;
    IF ((UPPER (column_name) = 'STUDENT_CONFIRMED_IND') OR (column_name IS NULL)) THEN
      IF new_references.student_confirmed_ind NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'RULE_CHECK_IND ') OR (column_name IS NULL)) THEN
      IF new_references.rule_check_ind NOT IN ( 'Y' , 'N' )  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'PUBLISH_OUTCOMES_IND') OR (column_name IS NULL)) THEN
      IF new_references.publish_outcomes_ind NOT IN ( 'Y' , 'N' )  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ADVANCED_STANDING_IND ') OR (column_name IS NULL)) THEN
      IF new_references.advanced_standing_ind  NOT IN ( 'Y' , 'N' )  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'COURSE_RQRMNT_COMPLETE_IND') OR (column_name IS NULL)) THEN
      IF new_references.course_rqrmnt_complete_ind   NOT IN ( 'Y' , 'N' )   THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ADM_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF new_references.adm_sequence_number < 1 OR
         new_references.adm_sequence_number > 999999 THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'SELF_HELP_GROUP_IND ') OR (column_name IS NULL)) THEN
      IF new_references.self_help_group_ind  NOT IN  ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'WAIVE_OPTION_CHECK_IND') OR (column_name IS NULL)) THEN
      IF new_references.waive_option_check_ind  NOT IN  ( 'Y' , 'N' )  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'PROVISIONAL_IND ') OR (column_name IS NULL)) THEN
      IF new_references.provisional_ind   NOT IN  ( 'Y' , 'N' )  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ADM_NOMINATED_COURSE_CD') OR (column_name IS NULL)) THEN
      IF (new_references.adm_nominated_course_cd <> UPPER (new_references.adm_nominated_course_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ATTENDANCE_MODE') OR (column_name IS NULL)) THEN
      IF (new_references.attendance_mode <> UPPER (new_references.attendance_mode)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ATTENDANCE_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.attendance_type <> UPPER (new_references.attendance_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.cal_type <> UPPER (new_references.cal_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'CORRESPONDENCE_CAT') OR (column_name IS NULL)) THEN
      IF (new_references.correspondence_cat <> UPPER (new_references.correspondence_cat)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'COURSE_ATTEMPT_STATUS') OR (column_name IS NULL)) THEN
      IF (new_references.course_attempt_status <> UPPER (new_references.course_attempt_status)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'COURSE_CD') OR (column_name IS NULL)) THEN
      IF (new_references.course_cd <> UPPER (new_references.course_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'COURSE_RQRMNT_COMPLETE_IND') OR (column_name IS NULL)) THEN
      IF (new_references.course_rqrmnt_complete_ind <> UPPER (new_references.course_rqrmnt_complete_ind)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'DERIVED_ATT_MODE') OR (column_name IS NULL)) THEN
      IF (new_references.derived_att_mode <> UPPER (new_references.derived_att_mode)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'DERIVED_ATT_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.derived_att_type <> UPPER (new_references.derived_att_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'DERIVED_COMPLETION_PERD') OR (column_name IS NULL)) THEN
      IF (new_references.derived_completion_perd <> UPPER (new_references.derived_completion_perd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'DISCONTINUATION_REASON_CD') OR (column_name IS NULL)) THEN
      IF (new_references.DISCONTINUATION_REASON_CD <> UPPER (new_references.DISCONTINUATION_REASON_CD)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'EXAM_LOCATION_CD') OR (column_name IS NULL)) THEN
      IF (new_references.exam_location_cd <> UPPER (new_references.exam_location_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'FUNDING_SOURCE') OR (column_name IS NULL)) THEN
      IF (new_references.funding_source <> UPPER (new_references.funding_source)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'LOCATION_CD') OR (column_name IS NULL)) THEN
      IF (new_references.location_cd <> UPPER (new_references.location_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'NOMINATED_COMPLETION_PERD') OR (column_name IS NULL)) THEN
      IF (new_references.nominated_completion_perd <> UPPER (new_references.nominated_completion_perd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'MANUAL_OVR_CMPL_DT_IND') OR (column_name IS NULL)) THEN
      IF new_references.manual_ovr_cmpl_dt_ind  NOT IN  ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_AS_SC_ATTEMPT_H_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      hist_start_dt = x_hist_start_dt
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN(TRUE);
    ELSE
       CLOSE cur_rowid;
       RETURN(FALSE);
    END IF;


  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_progression_status IN VARCHAR2 DEFAULT NULL,
    x_derived_att_type IN VARCHAR2 DEFAULT NULL,
    x_derived_att_mode IN VARCHAR2 DEFAULT NULL,
    x_provisional_ind IN VARCHAR2 DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_discontinuation_reason_cd IN VARCHAR2 DEFAULT NULL,
    x_lapsed_dt IN DATE DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_fs_description IN VARCHAR2 DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_elo_description IN VARCHAR2 DEFAULT NULL,
    x_derived_completion_yr IN NUMBER DEFAULT NULL,
    x_derived_completion_perd IN VARCHAR2 DEFAULT NULL,
    x_nominated_completion_yr IN NUMBER DEFAULT NULL,
    x_nominated_completion_perd IN VARCHAR2 DEFAULT NULL,
    x_rule_check_ind IN VARCHAR2 DEFAULT NULL,
    x_waive_option_check_ind IN VARCHAR2 DEFAULT NULL,
    x_last_rule_check_dt IN DATE DEFAULT NULL,
    x_publish_outcomes_ind IN VARCHAR2 DEFAULT NULL,
    x_course_rqrmnt_complete_ind IN VARCHAR2 DEFAULT NULL,
    x_course_rqrmnts_complete_dt IN DATE DEFAULT NULL,
    x_s_completed_source_type IN VARCHAR2 DEFAULT NULL,
    x_override_time_limitation IN NUMBER DEFAULT NULL,
    x_advanced_standing_ind IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fc_description IN VARCHAR2 DEFAULT NULL,
    x_correspondence_cat IN VARCHAR2 DEFAULT NULL,
    x_cc_description IN VARCHAR2 DEFAULT NULL,
    x_self_help_group_ind IN VARCHAR2 DEFAULT NULL,
    x_adm_admission_appl_number IN NUMBER DEFAULT NULL,
    x_adm_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_adm_sequence_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_student_confirmed_ind IN VARCHAR2 DEFAULT NULL,
    x_commencement_dt IN DATE DEFAULT NULL,
    x_course_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_last_date_of_attendance IN DATE DEFAULT NULL,
    x_dropped_by  IN VARCHAR2 DEFAULT NULL,
    x_primary_program_type IN VARCHAR2 DEFAULT NULL,
    x_primary_prog_type_source IN VARCHAR2 DEFAULT NULL,
    x_catalog_cal_type IN VARCHAR2 DEFAULT NULL,
    x_catalog_seq_num IN NUMBER DEFAULT NULL,
    x_key_program IN VARCHAR2 DEFAULT 'N' ,
    x_override_cmpl_dt  IN DATE DEFAULT NULL,
    x_manual_ovr_cmpl_dt_ind  IN VARCHAR2 DEFAULT 'N',
    x_coo_id IN NUMBER DEFAULT NULL,
    x_igs_pr_class_std_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_progression_status,
      x_derived_att_type,
      x_derived_att_mode,
      x_provisional_ind,
      x_discontinued_dt,
      x_discontinuation_reason_cd,
      x_lapsed_dt,
      x_funding_source,
      x_fs_description,
      x_exam_location_cd,
      x_elo_description,
      x_derived_completion_yr,
      x_derived_completion_perd,
      x_nominated_completion_yr,
      x_nominated_completion_perd,
      x_rule_check_ind,
      x_waive_option_check_ind,
      x_last_rule_check_dt,
      x_publish_outcomes_ind,
      x_course_rqrmnt_complete_ind,
      x_course_rqrmnts_complete_dt,
      x_s_completed_source_type,
      x_override_time_limitation,
      x_advanced_standing_ind,
      x_fee_cat,
      x_fc_description,
      x_correspondence_cat,
      x_cc_description,
      x_self_help_group_ind,
      x_adm_admission_appl_number,
      x_adm_nominated_course_cd,
      x_adm_sequence_number,
      x_person_id,
      x_course_cd,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_version_number,
      x_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_student_confirmed_ind,
      x_commencement_dt,
      x_course_attempt_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_last_date_of_attendance,
      x_dropped_by,
      x_primary_program_type,
      x_primary_prog_type_source,
      x_catalog_cal_type,
      x_catalog_seq_num,
      x_key_program,
      x_override_cmpl_dt,
      x_manual_ovr_cmpl_dt_ind,
      x_coo_id,
      x_igs_pr_class_std_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation(
		          new_references.person_id ,
		          new_references.course_cd ,
			    new_references.hist_start_dt
	                            ) THEN

 		Fnd_message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
                IGS_GE_MSG_STACK.ADD;
 		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

	Check_Constraints;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
		          new_references.person_id ,
		          new_references.course_cd ,
			    new_references.hist_start_dt
 				 ) THEN
		          Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
		          APP_EXCEPTION.RAISE_EXCEPTION;
     	        END IF;
     		Check_Constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     		  Check_Constraints;

    END IF;
  END Before_DML;

PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_ORG_ID IN NUMBER,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_HIST_START_DT IN DATE,
  X_HIST_END_DT IN DATE,
  X_HIST_WHO IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_CAL_TYPE IN VARCHAR2,
  X_LOCATION_CD IN VARCHAR2,
  X_ATTENDANCE_MODE IN VARCHAR2,
  X_ATTENDANCE_TYPE IN VARCHAR2,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_COMMENCEMENT_DT IN DATE,
  X_COURSE_ATTEMPT_STATUS IN VARCHAR2,
  X_PROGRESSION_STATUS IN VARCHAR2,
  X_DERIVED_ATT_TYPE IN VARCHAR2,
  X_DERIVED_ATT_MODE IN VARCHAR2,
  X_PROVISIONAL_IND IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_DISCONTINUATION_REASON_CD IN VARCHAR2,
  X_LAPSED_DT IN DATE,
  X_FUNDING_SOURCE IN VARCHAR2,
  X_FS_DESCRIPTION IN VARCHAR2,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_ELO_DESCRIPTION IN VARCHAR2,
  X_DERIVED_COMPLETION_YR IN NUMBER,
  X_DERIVED_COMPLETION_PERD IN VARCHAR2,
  X_NOMINATED_COMPLETION_YR IN NUMBER,
  X_NOMINATED_COMPLETION_PERD IN VARCHAR2,
  X_RULE_CHECK_IND IN VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND IN VARCHAR2,
  X_LAST_RULE_CHECK_DT IN DATE,
  X_PUBLISH_OUTCOMES_IND IN VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND IN VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION IN NUMBER,
  X_ADVANCED_STANDING_IND IN VARCHAR2,
  X_FEE_CAT IN VARCHAR2,
  X_FC_DESCRIPTION IN VARCHAR2,
  X_CORRESPONDENCE_CAT IN VARCHAR2,
  X_CC_DESCRIPTION IN VARCHAR2,
  X_SELF_HELP_GROUP_IND IN VARCHAR2,
  X_ADM_ADMISSION_APPL_NUMBER IN NUMBER,
  X_ADM_NOMINATED_COURSE_CD IN VARCHAR2,
  X_ADM_SEQUENCE_NUMBER IN NUMBER,
  X_MODE IN VARCHAR2 DEFAULT 'R',
  X_LAST_DATE_OF_ATTENDANCE IN DATE DEFAULT NULL,
  X_DROPPED_BY  IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_CAL_TYPE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM IN NUMBER DEFAULT NULL,
  X_KEY_PROGRAM IN VARCHAR2 DEFAULT 'N',
  X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
  X_MANUAL_OVR_CMPL_DT_IND  IN VARCHAR2 DEFAULT 'N',
  X_COO_ID IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
  ) AS
    CURSOR C IS SELECT ROWID FROM IGS_AS_SC_ATTEMPT_H_ALL
      WHERE PERSON_ID = X_PERSON_ID
      AND COURSE_CD = X_COURSE_CD
      AND HIST_START_DT = X_HIST_START_DT;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_adm_admission_appl_number=>X_ADM_ADMISSION_APPL_NUMBER,
  x_adm_nominated_course_cd=>X_ADM_NOMINATED_COURSE_CD,
  x_adm_sequence_number=>X_ADM_SEQUENCE_NUMBER,
  x_advanced_standing_ind=>X_ADVANCED_STANDING_IND,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_cal_type=>X_CAL_TYPE,
  x_cc_description=>X_CC_DESCRIPTION,
  x_commencement_dt=>X_COMMENCEMENT_DT,
  x_correspondence_cat=>X_CORRESPONDENCE_CAT,
  x_course_attempt_status=>X_COURSE_ATTEMPT_STATUS,
  x_course_cd=>X_COURSE_CD,
  x_course_rqrmnt_complete_ind=>X_COURSE_RQRMNT_COMPLETE_IND,
  x_course_rqrmnts_complete_dt=>X_COURSE_RQRMNTS_COMPLETE_DT,
  x_derived_att_mode=>X_DERIVED_ATT_MODE,
  x_derived_att_type=>X_DERIVED_ATT_TYPE,
  x_derived_completion_perd=>X_DERIVED_COMPLETION_PERD,
  x_derived_completion_yr=>X_DERIVED_COMPLETION_YR,
  x_discontinuation_reason_cd=>X_DISCONTINUATION_REASON_CD,
  x_discontinued_dt=>X_DISCONTINUED_DT,
  x_elo_description=>X_ELO_DESCRIPTION,
  x_exam_location_cd=>X_EXAM_LOCATION_CD,
  x_fc_description=>X_FC_DESCRIPTION,
  x_fee_cat=>X_FEE_CAT,
  x_fs_description=>X_FS_DESCRIPTION,
  x_funding_source=>X_FUNDING_SOURCE,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_who=>X_HIST_WHO,
  x_lapsed_dt=>X_LAPSED_DT,
  x_last_rule_check_dt=>X_LAST_RULE_CHECK_DT,
  x_location_cd=>X_LOCATION_CD,
  x_nominated_completion_perd=>X_NOMINATED_COMPLETION_PERD,
  x_nominated_completion_yr=>X_NOMINATED_COMPLETION_YR,
  x_override_time_limitation=>X_OVERRIDE_TIME_LIMITATION,
  x_person_id=>X_PERSON_ID,
  x_progression_status=>X_PROGRESSION_STATUS,
  x_provisional_ind=>X_PROVISIONAL_IND,
  x_publish_outcomes_ind=>X_PUBLISH_OUTCOMES_IND,
  x_rule_check_ind=>X_RULE_CHECK_IND,
  x_s_completed_source_type=>X_S_COMPLETED_SOURCE_TYPE,
  x_self_help_group_ind=>X_SELF_HELP_GROUP_IND,
  x_student_confirmed_ind=>X_STUDENT_CONFIRMED_IND,
  x_version_number=>X_VERSION_NUMBER,
  x_waive_option_check_ind=>X_WAIVE_OPTION_CHECK_IND,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_last_date_of_attendance =>X_LAST_DATE_OF_ATTENDANCE,
  x_dropped_by =>X_DROPPED_BY,
  x_primary_program_type=>X_PRIMARY_PROGRAM_TYPE,
  x_primary_prog_type_source=>X_PRIMARY_PROG_TYPE_SOURCE,
  x_catalog_cal_type=>X_CATALOG_CAL_TYPE,
  x_catalog_seq_num=>X_CATALOG_SEQ_NUM,
  x_key_program=>X_KEY_PROGRAM,
  x_override_cmpl_dt  => X_OVERRIDE_CMPL_DT,
  x_manual_ovr_cmpl_dt_ind  => X_MANUAL_OVR_CMPL_DT_IND,
  x_coo_id => X_COO_ID,
  x_igs_pr_class_std_id => X_IGS_PR_CLASS_STD_ID
  );
  INSERT INTO IGS_AS_SC_ATTEMPT_H_ALL (
    ORG_ID,
    PERSON_ID,
    COURSE_CD,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    VERSION_NUMBER,
    CAL_TYPE,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    STUDENT_CONFIRMED_IND,
    COMMENCEMENT_DT,
    COURSE_ATTEMPT_STATUS,
    PROGRESSION_STATUS,
    DERIVED_ATT_TYPE,
    DERIVED_ATT_MODE,
    PROVISIONAL_IND,
    DISCONTINUED_DT,
    DISCONTINUATION_REASON_CD,
    LAPSED_DT,
    FUNDING_SOURCE,
    FS_DESCRIPTION,
    EXAM_LOCATION_CD,
    ELO_DESCRIPTION,
    DERIVED_COMPLETION_YR,
    DERIVED_COMPLETION_PERD,
    NOMINATED_COMPLETION_YR,
    NOMINATED_COMPLETION_PERD,
    RULE_CHECK_IND,
    WAIVE_OPTION_CHECK_IND,
    LAST_RULE_CHECK_DT,
    PUBLISH_OUTCOMES_IND,
    COURSE_RQRMNT_COMPLETE_IND,
    COURSE_RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE,
    OVERRIDE_TIME_LIMITATION,
    ADVANCED_STANDING_IND,
    FEE_CAT,
    FC_DESCRIPTION,
    CORRESPONDENCE_CAT,
    CC_DESCRIPTION,
    SELF_HELP_GROUP_IND,
    ADM_ADMISSION_APPL_NUMBER,
    ADM_NOMINATED_COURSE_CD,
    ADM_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_DATE_OF_ATTENDANCE,
    DROPPED_BY,
    PRIMARY_PROGRAM_TYPE,
    PRIMARY_PROG_TYPE_SOURCE,
    CATALOG_CAL_TYPE,
    CATALOG_SEQ_NUM,
    KEY_PROGRAM,
    OVERRIDE_CMPL_DT,
    MANUAL_OVR_CMPL_DT_IND,
    COO_ID,
    IGS_PR_CLASS_STD_ID
  ) VALUES (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.STUDENT_CONFIRMED_IND,
    NEW_REFERENCES.COMMENCEMENT_DT,
    NEW_REFERENCES.COURSE_ATTEMPT_STATUS,
    NEW_REFERENCES.PROGRESSION_STATUS,
    NEW_REFERENCES.DERIVED_ATT_TYPE,
    NEW_REFERENCES.DERIVED_ATT_MODE,
    NEW_REFERENCES.PROVISIONAL_IND,
    NEW_REFERENCES.DISCONTINUED_DT,
    NEW_REFERENCES.DISCONTINUATION_REASON_CD,
    NEW_REFERENCES.LAPSED_DT,
    NEW_REFERENCES.FUNDING_SOURCE,
    NEW_REFERENCES.FS_DESCRIPTION,
    NEW_REFERENCES.EXAM_LOCATION_CD,
    NEW_REFERENCES.ELO_DESCRIPTION,
    NEW_REFERENCES.DERIVED_COMPLETION_YR,
    NEW_REFERENCES.DERIVED_COMPLETION_PERD,
    NEW_REFERENCES.NOMINATED_COMPLETION_YR,
    NEW_REFERENCES.NOMINATED_COMPLETION_PERD,
    NEW_REFERENCES.RULE_CHECK_IND,
    NEW_REFERENCES.WAIVE_OPTION_CHECK_IND,
    NEW_REFERENCES.LAST_RULE_CHECK_DT,
    NEW_REFERENCES.PUBLISH_OUTCOMES_IND,
    NEW_REFERENCES.COURSE_RQRMNT_COMPLETE_IND,
    NEW_REFERENCES.COURSE_RQRMNTS_COMPLETE_DT,
    NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    NEW_REFERENCES.OVERRIDE_TIME_LIMITATION,
    NEW_REFERENCES.ADVANCED_STANDING_IND,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FC_DESCRIPTION,
    NEW_REFERENCES.CORRESPONDENCE_CAT,
    NEW_REFERENCES.CC_DESCRIPTION,
    NEW_REFERENCES.SELF_HELP_GROUP_IND,
    NEW_REFERENCES.ADM_ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.ADM_NOMINATED_COURSE_CD,
    NEW_REFERENCES.ADM_SEQUENCE_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.LAST_DATE_OF_ATTENDANCE,
    NEW_REFERENCES.DROPPED_BY,
    NEW_REFERENCES.PRIMARY_PROGRAM_TYPE,
    NEW_REFERENCES.PRIMARY_PROG_TYPE_SOURCE,
    NEW_REFERENCES.CATALOG_CAL_TYPE,
    NEW_REFERENCES.CATALOG_SEQ_NUM,
    NEW_REFERENCES.KEY_PROGRAM,
    NEW_REFERENCES.OVERRIDE_CMPL_DT,
    NEW_REFERENCES.MANUAL_OVR_CMPL_DT_IND,
    NEW_REFERENCES.COO_ID,
    NEW_REFERENCES.IGS_PR_CLASS_STD_ID
  );
  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;
PROCEDURE LOCK_ROW (
  X_ROWID IN  VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_HIST_START_DT IN DATE,
  X_HIST_END_DT IN DATE,
  X_HIST_WHO IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_CAL_TYPE IN VARCHAR2,
  X_LOCATION_CD IN VARCHAR2,
  X_ATTENDANCE_MODE IN VARCHAR2,
  X_ATTENDANCE_TYPE IN VARCHAR2,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_COMMENCEMENT_DT IN DATE,
  X_COURSE_ATTEMPT_STATUS IN VARCHAR2,
  X_PROGRESSION_STATUS IN VARCHAR2,
  X_DERIVED_ATT_TYPE IN VARCHAR2,
  X_DERIVED_ATT_MODE IN VARCHAR2,
  X_PROVISIONAL_IND IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_DISCONTINUATION_REASON_CD IN VARCHAR2,
  X_LAPSED_DT IN DATE,
  X_FUNDING_SOURCE IN VARCHAR2,
  X_FS_DESCRIPTION IN VARCHAR2,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_ELO_DESCRIPTION IN VARCHAR2,
  X_DERIVED_COMPLETION_YR IN NUMBER,
  X_DERIVED_COMPLETION_PERD IN VARCHAR2,
  X_NOMINATED_COMPLETION_YR IN NUMBER,
  X_NOMINATED_COMPLETION_PERD IN VARCHAR2,
  X_RULE_CHECK_IND IN VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND IN VARCHAR2,
  X_LAST_RULE_CHECK_DT IN DATE,
  X_PUBLISH_OUTCOMES_IND IN VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND IN VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION IN NUMBER,
  X_ADVANCED_STANDING_IND IN VARCHAR2,
  X_FEE_CAT IN VARCHAR2,
  X_FC_DESCRIPTION IN VARCHAR2,
  X_CORRESPONDENCE_CAT IN VARCHAR2,
  X_CC_DESCRIPTION IN VARCHAR2,
  X_SELF_HELP_GROUP_IND IN VARCHAR2,
  X_ADM_ADMISSION_APPL_NUMBER IN NUMBER,
  X_ADM_NOMINATED_COURSE_CD IN VARCHAR2,
  X_ADM_SEQUENCE_NUMBER IN NUMBER,
  X_LAST_DATE_OF_ATTENDANCE IN DATE DEFAULT NULL,
  X_DROPPED_BY  IN VARCHAR2 DEFAULT NULL ,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_CAL_TYPE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM IN NUMBER DEFAULT NULL,
  X_KEY_PROGRAM IN VARCHAR2 DEFAULT 'N',
  X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
  X_MANUAL_OVR_CMPL_DT_IND  IN VARCHAR2 DEFAULT 'N',
  X_COO_ID IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
) AS
  CURSOR c1 IS SELECT
      HIST_END_DT,
      HIST_WHO,
      VERSION_NUMBER,
      CAL_TYPE,
      LOCATION_CD,
      ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      STUDENT_CONFIRMED_IND,
      COMMENCEMENT_DT,
      COURSE_ATTEMPT_STATUS,
      PROGRESSION_STATUS,
      DERIVED_ATT_TYPE,
      DERIVED_ATT_MODE,
      PROVISIONAL_IND,
      DISCONTINUED_DT,
      DISCONTINUATION_REASON_CD,
      LAPSED_DT,
      FUNDING_SOURCE,
      FS_DESCRIPTION,
      EXAM_LOCATION_CD,
      ELO_DESCRIPTION,
      DERIVED_COMPLETION_YR,
      DERIVED_COMPLETION_PERD,
      NOMINATED_COMPLETION_YR,
      NOMINATED_COMPLETION_PERD,
      RULE_CHECK_IND,
      WAIVE_OPTION_CHECK_IND,
      LAST_RULE_CHECK_DT,
      PUBLISH_OUTCOMES_IND,
      COURSE_RQRMNT_COMPLETE_IND,
      COURSE_RQRMNTS_COMPLETE_DT,
      S_COMPLETED_SOURCE_TYPE,
      OVERRIDE_TIME_LIMITATION,
      ADVANCED_STANDING_IND,
      FEE_CAT,
      FC_DESCRIPTION,
      CORRESPONDENCE_CAT,
      CC_DESCRIPTION,
      SELF_HELP_GROUP_IND,
      ADM_ADMISSION_APPL_NUMBER,
      ADM_NOMINATED_COURSE_CD,
      ADM_SEQUENCE_NUMBER,
      LAST_DATE_OF_ATTENDANCE,
      DROPPED_BY,
      PRIMARY_PROGRAM_TYPE,
      PRIMARY_PROG_TYPE_SOURCE,
      CATALOG_CAL_TYPE,
      CATALOG_SEQ_NUM,
      KEY_PROGRAM,
      OVERRIDE_CMPL_DT,
      MANUAL_OVR_CMPL_DT_IND,
      COO_ID,
     IGS_PR_CLASS_STD_ID
    FROM IGS_AS_SC_ATTEMPT_H_ALL
    WHERE ROWID = X_ROWID  FOR UPDATE  NOWAIT;
  tlinfo c1%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    CLOSE c1;
    RETURN;
  END IF;
  CLOSE c1;
  IF ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
           OR ((tlinfo.VERSION_NUMBER IS NULL)
               AND (X_VERSION_NUMBER IS NULL)))
      AND ((tlinfo.CAL_TYPE = X_CAL_TYPE)
           OR ((tlinfo.CAL_TYPE IS NULL)
               AND (X_CAL_TYPE IS NULL)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD IS NULL)
               AND (X_LOCATION_CD IS NULL)))
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE IS NULL)
               AND (X_ATTENDANCE_MODE IS NULL)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE IS NULL)
               AND (X_ATTENDANCE_TYPE IS NULL)))
      AND ((tlinfo.STUDENT_CONFIRMED_IND = X_STUDENT_CONFIRMED_IND)
           OR ((tlinfo.STUDENT_CONFIRMED_IND IS NULL)
               AND (X_STUDENT_CONFIRMED_IND IS NULL)))
      AND ((tlinfo.COMMENCEMENT_DT = X_COMMENCEMENT_DT)
           OR ((tlinfo.COMMENCEMENT_DT IS NULL)
               AND (X_COMMENCEMENT_DT IS NULL)))
      AND ((tlinfo.COURSE_ATTEMPT_STATUS = X_COURSE_ATTEMPT_STATUS)
           OR ((tlinfo.COURSE_ATTEMPT_STATUS IS NULL)
               AND (X_COURSE_ATTEMPT_STATUS IS NULL)))
      AND ((tlinfo.PROGRESSION_STATUS = X_PROGRESSION_STATUS)
           OR ((tlinfo.PROGRESSION_STATUS IS NULL)
               AND (X_PROGRESSION_STATUS IS NULL)))
      AND ((tlinfo.DERIVED_ATT_TYPE = X_DERIVED_ATT_TYPE)
           OR ((tlinfo.DERIVED_ATT_TYPE IS NULL)
               AND (X_DERIVED_ATT_TYPE IS NULL)))
      AND ((tlinfo.DERIVED_ATT_MODE = X_DERIVED_ATT_MODE)
           OR ((tlinfo.DERIVED_ATT_MODE IS NULL)
               AND (X_DERIVED_ATT_MODE IS NULL)))
      AND ((tlinfo.PROVISIONAL_IND = X_PROVISIONAL_IND)
           OR ((tlinfo.PROVISIONAL_IND IS NULL)
               AND (X_PROVISIONAL_IND IS NULL)))
      AND ((tlinfo.DISCONTINUED_DT = X_DISCONTINUED_DT)
           OR ((tlinfo.DISCONTINUED_DT IS NULL)
               AND (X_DISCONTINUED_DT IS NULL)))
      AND ((tlinfo.DISCONTINUATION_REASON_CD = X_DISCONTINUATION_REASON_CD)
           OR ((tlinfo.DISCONTINUATION_REASON_CD IS NULL)
               AND (X_DISCONTINUATION_REASON_CD IS NULL)))
      AND ((tlinfo.LAPSED_DT = X_LAPSED_DT)
           OR ((tlinfo.LAPSED_DT IS NULL)
               AND (X_LAPSED_DT IS NULL)))
      AND ((tlinfo.FUNDING_SOURCE = X_FUNDING_SOURCE)
           OR ((tlinfo.FUNDING_SOURCE IS NULL)
               AND (X_FUNDING_SOURCE IS NULL)))
      AND ((tlinfo.FS_DESCRIPTION = X_FS_DESCRIPTION)
           OR ((tlinfo.FS_DESCRIPTION IS NULL)
               AND (X_FS_DESCRIPTION IS NULL)))
      AND ((tlinfo.EXAM_LOCATION_CD = X_EXAM_LOCATION_CD)
           OR ((tlinfo.EXAM_LOCATION_CD IS NULL)
               AND (X_EXAM_LOCATION_CD IS NULL)))
      AND ((tlinfo.ELO_DESCRIPTION = X_ELO_DESCRIPTION)
           OR ((tlinfo.ELO_DESCRIPTION IS NULL)
               AND (X_ELO_DESCRIPTION IS NULL)))
      AND ((tlinfo.DERIVED_COMPLETION_YR = X_DERIVED_COMPLETION_YR)
           OR ((tlinfo.DERIVED_COMPLETION_YR IS NULL)
               AND (X_DERIVED_COMPLETION_YR IS NULL)))
      AND ((tlinfo.DERIVED_COMPLETION_PERD = X_DERIVED_COMPLETION_PERD)
           OR ((tlinfo.DERIVED_COMPLETION_PERD IS NULL)
               AND (X_DERIVED_COMPLETION_PERD IS NULL)))
      AND ((tlinfo.NOMINATED_COMPLETION_YR = X_NOMINATED_COMPLETION_YR)
           OR ((tlinfo.NOMINATED_COMPLETION_YR IS NULL)
               AND (X_NOMINATED_COMPLETION_YR IS NULL)))
      AND ((tlinfo.NOMINATED_COMPLETION_PERD = X_NOMINATED_COMPLETION_PERD)
           OR ((tlinfo.NOMINATED_COMPLETION_PERD IS NULL)
               AND (X_NOMINATED_COMPLETION_PERD IS NULL)))
      AND ((tlinfo.RULE_CHECK_IND = X_RULE_CHECK_IND)
           OR ((tlinfo.RULE_CHECK_IND IS NULL)
               AND (X_RULE_CHECK_IND IS NULL)))
      AND ((tlinfo.WAIVE_OPTION_CHECK_IND = X_WAIVE_OPTION_CHECK_IND)
           OR ((tlinfo.WAIVE_OPTION_CHECK_IND IS NULL)
               AND (X_WAIVE_OPTION_CHECK_IND IS NULL)))
      AND ((tlinfo.LAST_RULE_CHECK_DT = X_LAST_RULE_CHECK_DT)
           OR ((tlinfo.LAST_RULE_CHECK_DT IS NULL)
               AND (X_LAST_RULE_CHECK_DT IS NULL)))
      AND ((tlinfo.PUBLISH_OUTCOMES_IND = X_PUBLISH_OUTCOMES_IND)
           OR ((tlinfo.PUBLISH_OUTCOMES_IND IS NULL)
               AND (X_PUBLISH_OUTCOMES_IND IS NULL)))
      AND ((tlinfo.COURSE_RQRMNT_COMPLETE_IND = X_COURSE_RQRMNT_COMPLETE_IND)
           OR ((tlinfo.COURSE_RQRMNT_COMPLETE_IND IS NULL)
               AND (X_COURSE_RQRMNT_COMPLETE_IND IS NULL)))
      AND ((tlinfo.COURSE_RQRMNTS_COMPLETE_DT = X_COURSE_RQRMNTS_COMPLETE_DT)
           OR ((tlinfo.COURSE_RQRMNTS_COMPLETE_DT IS NULL)
               AND (X_COURSE_RQRMNTS_COMPLETE_DT IS NULL)))
      AND ((tlinfo.S_COMPLETED_SOURCE_TYPE = X_S_COMPLETED_SOURCE_TYPE)
           OR ((tlinfo.S_COMPLETED_SOURCE_TYPE IS NULL)
               AND (X_S_COMPLETED_SOURCE_TYPE IS NULL)))
      AND ((tlinfo.OVERRIDE_TIME_LIMITATION = X_OVERRIDE_TIME_LIMITATION)
           OR ((tlinfo.OVERRIDE_TIME_LIMITATION IS NULL)
               AND (X_OVERRIDE_TIME_LIMITATION IS NULL)))
      AND ((tlinfo.ADVANCED_STANDING_IND = X_ADVANCED_STANDING_IND)
           OR ((tlinfo.ADVANCED_STANDING_IND IS NULL)
               AND (X_ADVANCED_STANDING_IND IS NULL)))
      AND ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT IS NULL)
               AND (X_FEE_CAT IS NULL)))
      AND ((tlinfo.FC_DESCRIPTION = X_FC_DESCRIPTION)
           OR ((tlinfo.FC_DESCRIPTION IS NULL)
               AND (X_FC_DESCRIPTION IS NULL)))
      AND ((tlinfo.CORRESPONDENCE_CAT = X_CORRESPONDENCE_CAT)
           OR ((tlinfo.CORRESPONDENCE_CAT IS NULL)
               AND (X_CORRESPONDENCE_CAT IS NULL)))
      AND ((tlinfo.CC_DESCRIPTION = X_CC_DESCRIPTION)
           OR ((tlinfo.CC_DESCRIPTION IS NULL)
               AND (X_CC_DESCRIPTION IS NULL)))
      AND ((tlinfo.SELF_HELP_GROUP_IND = X_SELF_HELP_GROUP_IND)
           OR ((tlinfo.SELF_HELP_GROUP_IND IS NULL)
               AND (X_SELF_HELP_GROUP_IND IS NULL)))
      AND ((tlinfo.ADM_ADMISSION_APPL_NUMBER = X_ADM_ADMISSION_APPL_NUMBER)
           OR ((tlinfo.ADM_ADMISSION_APPL_NUMBER IS NULL)
               AND (X_ADM_ADMISSION_APPL_NUMBER IS NULL)))
      AND ((tlinfo.ADM_NOMINATED_COURSE_CD = X_ADM_NOMINATED_COURSE_CD)
           OR ((tlinfo.ADM_NOMINATED_COURSE_CD IS NULL)
               AND (X_ADM_NOMINATED_COURSE_CD IS NULL)))
      AND ((tlinfo.ADM_SEQUENCE_NUMBER = X_ADM_SEQUENCE_NUMBER)
           OR ((tlinfo.ADM_SEQUENCE_NUMBER IS NULL)
               AND (X_ADM_SEQUENCE_NUMBER IS NULL)))
      AND ((tlinfo.LAST_DATE_OF_ATTENDANCE = X_LAST_DATE_OF_ATTENDANCE)
           OR ((tlinfo.LAST_DATE_OF_ATTENDANCE IS NULL)
               AND (X_LAST_DATE_OF_ATTENDANCE IS NULL)))
      AND ((tlinfo.DROPPED_BY = X_DROPPED_BY)
           OR ((tlinfo.DROPPED_BY IS NULL)
               AND (X_DROPPED_BY IS NULL)))
      AND ((tlinfo.PRIMARY_PROGRAM_TYPE = X_PRIMARY_PROGRAM_TYPE)
           OR ((tlinfo.PRIMARY_PROGRAM_TYPE IS NULL)
               AND (X_PRIMARY_PROGRAM_TYPE IS NULL)))
      AND ((tlinfo.PRIMARY_PROG_TYPE_SOURCE = X_PRIMARY_PROG_TYPE_SOURCE)
           OR ((tlinfo.PRIMARY_PROG_TYPE_SOURCE IS NULL)
               AND (X_PRIMARY_PROG_TYPE_SOURCE IS NULL)))
      AND ((tlinfo.CATALOG_CAL_TYPE = X_CATALOG_CAL_TYPE)
           OR ((tlinfo.CATALOG_CAL_TYPE IS NULL)
               AND (X_CATALOG_CAL_TYPE IS NULL)))
      AND ((tlinfo.CATALOG_SEQ_NUM = X_CATALOG_SEQ_NUM)
           OR ((tlinfo.CATALOG_SEQ_NUM IS NULL)
               AND (X_CATALOG_SEQ_NUM IS NULL)))
      AND ((tlinfo.KEY_PROGRAM = X_KEY_PROGRAM)
           OR ((tlinfo.KEY_PROGRAM IS NULL)
               AND (X_KEY_PROGRAM IS NULL)))
      AND ((tlinfo.OVERRIDE_CMPL_DT = X_OVERRIDE_CMPL_DT)
           OR ((tlinfo.OVERRIDE_CMPL_DT IS NULL)
               AND (X_OVERRIDE_CMPL_DT IS NULL)))
      AND ((tlinfo.MANUAL_OVR_CMPL_DT_IND = X_MANUAL_OVR_CMPL_DT_IND)
           OR ((tlinfo.MANUAL_OVR_CMPL_DT_IND IS NULL)
               AND (X_MANUAL_OVR_CMPL_DT_IND IS NULL)))
      AND ((tlinfo.COO_ID = X_COO_ID)
           OR ((tlinfo.COO_ID IS NULL)
               AND (X_COO_ID IS NULL)))
      AND ((tlinfo.IGS_PR_CLASS_STD_ID = X_IGS_PR_CLASS_STD_ID)
           OR ((tlinfo.IGS_PR_CLASS_STD_ID IS NULL)
               AND (X_IGS_PR_CLASS_STD_ID IS NULL)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  RETURN;
END LOCK_ROW;
PROCEDURE UPDATE_ROW (
  X_ROWID IN  VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_HIST_START_DT IN DATE,
  X_HIST_END_DT IN DATE,
  X_HIST_WHO IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_CAL_TYPE IN VARCHAR2,
  X_LOCATION_CD IN VARCHAR2,
  X_ATTENDANCE_MODE IN VARCHAR2,
  X_ATTENDANCE_TYPE IN VARCHAR2,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_COMMENCEMENT_DT IN DATE,
  X_COURSE_ATTEMPT_STATUS IN VARCHAR2,
  X_PROGRESSION_STATUS IN VARCHAR2,
  X_DERIVED_ATT_TYPE IN VARCHAR2,
  X_DERIVED_ATT_MODE IN VARCHAR2,
  X_PROVISIONAL_IND IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_DISCONTINUATION_REASON_CD IN VARCHAR2,
  X_LAPSED_DT IN DATE,
  X_FUNDING_SOURCE IN VARCHAR2,
  X_FS_DESCRIPTION IN VARCHAR2,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_ELO_DESCRIPTION IN VARCHAR2,
  X_DERIVED_COMPLETION_YR IN NUMBER,
  X_DERIVED_COMPLETION_PERD IN VARCHAR2,
  X_NOMINATED_COMPLETION_YR IN NUMBER,
  X_NOMINATED_COMPLETION_PERD IN VARCHAR2,
  X_RULE_CHECK_IND IN VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND IN VARCHAR2,
  X_LAST_RULE_CHECK_DT IN DATE,
  X_PUBLISH_OUTCOMES_IND IN VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND IN VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION IN NUMBER,
  X_ADVANCED_STANDING_IND IN VARCHAR2,
  X_FEE_CAT IN VARCHAR2,
  X_FC_DESCRIPTION IN VARCHAR2,
  X_CORRESPONDENCE_CAT IN VARCHAR2,
  X_CC_DESCRIPTION IN VARCHAR2,
  X_SELF_HELP_GROUP_IND IN VARCHAR2,
  X_ADM_ADMISSION_APPL_NUMBER IN NUMBER,
  X_ADM_NOMINATED_COURSE_CD IN VARCHAR2,
  X_ADM_SEQUENCE_NUMBER IN NUMBER,
  X_MODE IN VARCHAR2 DEFAULT 'R',
  X_LAST_DATE_OF_ATTENDANCE IN DATE DEFAULT NULL,
  X_DROPPED_BY  IN VARCHAR2 DEFAULT NULL ,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_CAL_TYPE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM IN NUMBER DEFAULT NULL,
  X_KEY_PROGRAM IN VARCHAR2 DEFAULT 'N',
  X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
  X_MANUAL_OVR_CMPL_DT_IND IN VARCHAR2 DEFAULT 'N',
  X_COO_ID IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
 ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_adm_admission_appl_number=>X_ADM_ADMISSION_APPL_NUMBER,
  x_adm_nominated_course_cd=>X_ADM_NOMINATED_COURSE_CD,
  x_adm_sequence_number=>X_ADM_SEQUENCE_NUMBER,
  x_advanced_standing_ind=>X_ADVANCED_STANDING_IND,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_cal_type=>X_CAL_TYPE,
  x_cc_description=>X_CC_DESCRIPTION,
  x_commencement_dt=>X_COMMENCEMENT_DT,
  x_correspondence_cat=>X_CORRESPONDENCE_CAT,
  x_course_attempt_status=>X_COURSE_ATTEMPT_STATUS,
  x_course_cd=>X_COURSE_CD,
  x_course_rqrmnt_complete_ind=>X_COURSE_RQRMNT_COMPLETE_IND,
  x_course_rqrmnts_complete_dt=>X_COURSE_RQRMNTS_COMPLETE_DT,
  x_derived_att_mode=>X_DERIVED_ATT_MODE,
  x_derived_att_type=>X_DERIVED_ATT_TYPE,
  x_derived_completion_perd=>X_DERIVED_COMPLETION_PERD,
  x_derived_completion_yr=>X_DERIVED_COMPLETION_YR,
  x_discontinuation_reason_cd=>X_DISCONTINUATION_REASON_CD,
  x_discontinued_dt=>X_DISCONTINUED_DT,
  x_elo_description=>X_ELO_DESCRIPTION,
  x_exam_location_cd=>X_EXAM_LOCATION_CD,
  x_fc_description=>X_FC_DESCRIPTION,
  x_fee_cat=>X_FEE_CAT,
  x_fs_description=>X_FS_DESCRIPTION,
  x_funding_source=>X_FUNDING_SOURCE,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_who=>X_HIST_WHO,
  x_lapsed_dt=>X_LAPSED_DT,
  x_last_rule_check_dt=>X_LAST_RULE_CHECK_DT,
  x_location_cd=>X_LOCATION_CD,
  x_nominated_completion_perd=>X_NOMINATED_COMPLETION_PERD,
  x_nominated_completion_yr=>X_NOMINATED_COMPLETION_YR,
  x_override_time_limitation=>X_OVERRIDE_TIME_LIMITATION,
  x_person_id=>X_PERSON_ID,
  x_progression_status=>X_PROGRESSION_STATUS,
  x_provisional_ind=>X_PROVISIONAL_IND,
  x_publish_outcomes_ind=>X_PUBLISH_OUTCOMES_IND,
  x_rule_check_ind=>X_RULE_CHECK_IND,
  x_s_completed_source_type=>X_S_COMPLETED_SOURCE_TYPE,
  x_self_help_group_ind=>X_SELF_HELP_GROUP_IND,
  x_student_confirmed_ind=>X_STUDENT_CONFIRMED_IND,
  x_version_number=>X_VERSION_NUMBER,
  x_waive_option_check_ind=>X_WAIVE_OPTION_CHECK_IND,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_last_date_of_attendance =>X_LAST_DATE_OF_ATTENDANCE,
  x_dropped_by =>X_DROPPED_BY,
  x_primary_program_type=>X_PRIMARY_PROGRAM_TYPE,
  x_primary_prog_type_source=>X_PRIMARY_PROG_TYPE_SOURCE,
  x_catalog_cal_type=>X_CATALOG_CAL_TYPE,
  x_catalog_seq_num=>X_CATALOG_SEQ_NUM,
  x_key_program=>X_KEY_PROGRAM,
  x_override_cmpl_dt  => X_OVERRIDE_CMPL_DT,
  x_manual_ovr_cmpl_dt_ind => X_MANUAL_OVR_CMPL_DT_IND,
  x_coo_id   => X_COO_ID,
  X_igs_pr_class_std_id => X_IGS_PR_CLASS_STD_ID
  );
  UPDATE IGS_AS_SC_ATTEMPT_H_ALL SET
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    STUDENT_CONFIRMED_IND = NEW_REFERENCES.STUDENT_CONFIRMED_IND,
    COMMENCEMENT_DT = NEW_REFERENCES.COMMENCEMENT_DT,
    COURSE_ATTEMPT_STATUS = NEW_REFERENCES.COURSE_ATTEMPT_STATUS,
    PROGRESSION_STATUS = NEW_REFERENCES.PROGRESSION_STATUS,
    DERIVED_ATT_TYPE = NEW_REFERENCES.DERIVED_ATT_TYPE,
    DERIVED_ATT_MODE = NEW_REFERENCES.DERIVED_ATT_MODE,
    PROVISIONAL_IND = NEW_REFERENCES.PROVISIONAL_IND,
    DISCONTINUED_DT = NEW_REFERENCES.DISCONTINUED_DT,
    DISCONTINUATION_REASON_CD = NEW_REFERENCES.DISCONTINUATION_REASON_CD,
    LAPSED_DT = NEW_REFERENCES.LAPSED_DT,
    FUNDING_SOURCE = NEW_REFERENCES.FUNDING_SOURCE,
    FS_DESCRIPTION = NEW_REFERENCES.FS_DESCRIPTION,
    EXAM_LOCATION_CD = NEW_REFERENCES.EXAM_LOCATION_CD,
    ELO_DESCRIPTION = NEW_REFERENCES.ELO_DESCRIPTION,
    DERIVED_COMPLETION_YR = NEW_REFERENCES.DERIVED_COMPLETION_YR,
    DERIVED_COMPLETION_PERD = NEW_REFERENCES.DERIVED_COMPLETION_PERD,
    NOMINATED_COMPLETION_YR = NEW_REFERENCES.NOMINATED_COMPLETION_YR,
    NOMINATED_COMPLETION_PERD = NEW_REFERENCES.NOMINATED_COMPLETION_PERD,
    RULE_CHECK_IND = NEW_REFERENCES.RULE_CHECK_IND,
    WAIVE_OPTION_CHECK_IND = NEW_REFERENCES.WAIVE_OPTION_CHECK_IND,
    LAST_RULE_CHECK_DT = NEW_REFERENCES.LAST_RULE_CHECK_DT,
    PUBLISH_OUTCOMES_IND = NEW_REFERENCES.PUBLISH_OUTCOMES_IND,
    COURSE_RQRMNT_COMPLETE_IND = NEW_REFERENCES.COURSE_RQRMNT_COMPLETE_IND,
    COURSE_RQRMNTS_COMPLETE_DT = NEW_REFERENCES.COURSE_RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE = NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    OVERRIDE_TIME_LIMITATION = NEW_REFERENCES.OVERRIDE_TIME_LIMITATION,
    ADVANCED_STANDING_IND = NEW_REFERENCES.ADVANCED_STANDING_IND,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    FC_DESCRIPTION = NEW_REFERENCES.FC_DESCRIPTION,
    CORRESPONDENCE_CAT = NEW_REFERENCES.CORRESPONDENCE_CAT,
    CC_DESCRIPTION = NEW_REFERENCES.CC_DESCRIPTION,
    SELF_HELP_GROUP_IND = NEW_REFERENCES.SELF_HELP_GROUP_IND,
    ADM_ADMISSION_APPL_NUMBER = NEW_REFERENCES.ADM_ADMISSION_APPL_NUMBER,
    ADM_NOMINATED_COURSE_CD = NEW_REFERENCES.ADM_NOMINATED_COURSE_CD,
    ADM_SEQUENCE_NUMBER = NEW_REFERENCES.ADM_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    LAST_DATE_OF_ATTENDANCE= NEW_REFERENCES.LAST_DATE_OF_ATTENDANCE,
    DROPPED_BY = NEW_REFERENCES.DROPPED_BY,
    PRIMARY_PROGRAM_TYPE=NEW_REFERENCES.PRIMARY_PROGRAM_TYPE,
    PRIMARY_PROG_TYPE_SOURCE=NEW_REFERENCES.PRIMARY_PROG_TYPE_SOURCE,
    CATALOG_CAL_TYPE=NEW_REFERENCES.CATALOG_CAL_TYPE,
    CATALOG_SEQ_NUM=NEW_REFERENCES.CATALOG_SEQ_NUM,
    KEY_PROGRAM=NEW_REFERENCES.KEY_PROGRAM,
    OVERRIDE_CMPL_DT = NEW_REFERENCES.OVERRIDE_CMPL_DT,
    MANUAL_OVR_CMPL_DT_IND = NEW_REFERENCES.MANUAL_OVR_CMPL_DT_IND,
    COO_ID = NEW_REFERENCES.COO_ID,
    IGS_PR_CLASS_STD_ID=NEW_REFERENCES.IGS_PR_CLASS_STD_ID
  WHERE ROWID = X_ROWID;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;
PROCEDURE ADD_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_ORG_ID IN NUMBER,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_HIST_START_DT IN DATE,
  X_HIST_END_DT IN DATE,
  X_HIST_WHO IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_CAL_TYPE IN VARCHAR2,
  X_LOCATION_CD IN VARCHAR2,
  X_ATTENDANCE_MODE IN VARCHAR2,
  X_ATTENDANCE_TYPE IN VARCHAR2,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_COMMENCEMENT_DT IN DATE,
  X_COURSE_ATTEMPT_STATUS IN VARCHAR2,
  X_PROGRESSION_STATUS IN VARCHAR2,
  X_DERIVED_ATT_TYPE IN VARCHAR2,
  X_DERIVED_ATT_MODE IN VARCHAR2,
  X_PROVISIONAL_IND IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_DISCONTINUATION_REASON_CD IN VARCHAR2,
  X_LAPSED_DT IN DATE,
  X_FUNDING_SOURCE IN VARCHAR2,
  X_FS_DESCRIPTION IN VARCHAR2,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_ELO_DESCRIPTION IN VARCHAR2,
  X_DERIVED_COMPLETION_YR IN NUMBER,
  X_DERIVED_COMPLETION_PERD IN VARCHAR2,
  X_NOMINATED_COMPLETION_YR IN NUMBER,
  X_NOMINATED_COMPLETION_PERD IN VARCHAR2,
  X_RULE_CHECK_IND IN VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND IN VARCHAR2,
  X_LAST_RULE_CHECK_DT IN DATE,
  X_PUBLISH_OUTCOMES_IND IN VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND IN VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION IN NUMBER,
  X_ADVANCED_STANDING_IND IN VARCHAR2,
  X_FEE_CAT IN VARCHAR2,
  X_FC_DESCRIPTION IN VARCHAR2,
  X_CORRESPONDENCE_CAT IN VARCHAR2,
  X_CC_DESCRIPTION IN VARCHAR2,
  X_SELF_HELP_GROUP_IND IN VARCHAR2,
  X_ADM_ADMISSION_APPL_NUMBER IN NUMBER,
  X_ADM_NOMINATED_COURSE_CD IN VARCHAR2,
  X_ADM_SEQUENCE_NUMBER IN NUMBER,
  X_MODE IN VARCHAR2 DEFAULT 'R',
  X_LAST_DATE_OF_ATTENDANCE IN DATE DEFAULT NULL,
  X_DROPPED_BY  IN VARCHAR2 DEFAULT NULL ,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_CAL_TYPE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM IN NUMBER DEFAULT NULL,
  X_KEY_PROGRAM IN VARCHAR2 DEFAULT 'N',
  X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
  X_MANUAL_OVR_CMPL_DT_IND  IN VARCHAR2 DEFAULT 'N',
  X_COO_ID IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
  ) AS
  CURSOR c1 IS SELECT ROWID FROM IGS_AS_SC_ATTEMPT_H_ALL
     WHERE PERSON_ID = X_PERSON_ID
     AND COURSE_CD = X_COURSE_CD
     AND HIST_START_DT = X_HIST_START_DT
  ;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_LOCATION_CD,
     X_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_STUDENT_CONFIRMED_IND,
     X_COMMENCEMENT_DT,
     X_COURSE_ATTEMPT_STATUS,
     X_PROGRESSION_STATUS,
     X_DERIVED_ATT_TYPE,
     X_DERIVED_ATT_MODE,
     X_PROVISIONAL_IND,
     X_DISCONTINUED_DT,
     X_DISCONTINUATION_REASON_CD,
     X_LAPSED_DT,
     X_FUNDING_SOURCE,
     X_FS_DESCRIPTION,
     X_EXAM_LOCATION_CD,
     X_ELO_DESCRIPTION,
     X_DERIVED_COMPLETION_YR,
     X_DERIVED_COMPLETION_PERD,
     X_NOMINATED_COMPLETION_YR,
     X_NOMINATED_COMPLETION_PERD,
     X_RULE_CHECK_IND,
     X_WAIVE_OPTION_CHECK_IND,
     X_LAST_RULE_CHECK_DT,
     X_PUBLISH_OUTCOMES_IND,
     X_COURSE_RQRMNT_COMPLETE_IND,
     X_COURSE_RQRMNTS_COMPLETE_DT,
     X_S_COMPLETED_SOURCE_TYPE,
     X_OVERRIDE_TIME_LIMITATION,
     X_ADVANCED_STANDING_IND,
     X_FEE_CAT,
     X_FC_DESCRIPTION,
     X_CORRESPONDENCE_CAT,
     X_CC_DESCRIPTION,
     X_SELF_HELP_GROUP_IND,
     X_ADM_ADMISSION_APPL_NUMBER,
     X_ADM_NOMINATED_COURSE_CD,
     X_ADM_SEQUENCE_NUMBER,
     X_MODE,
     X_LAST_DATE_OF_ATTENDANCE,
     X_DROPPED_BY,
     X_PRIMARY_PROGRAM_TYPE,
     X_PRIMARY_PROG_TYPE_SOURCE,
     X_CATALOG_CAL_TYPE,
     X_CATALOG_SEQ_NUM,
     X_KEY_PROGRAM,
     X_OVERRIDE_CMPL_DT,
     X_MANUAL_OVR_CMPL_DT_IND,
     X_COO_ID,
     X_IGS_PR_CLASS_STD_ID
);
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_LOCATION_CD,
   X_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_STUDENT_CONFIRMED_IND,
   X_COMMENCEMENT_DT,
   X_COURSE_ATTEMPT_STATUS,
   X_PROGRESSION_STATUS,
   X_DERIVED_ATT_TYPE,
   X_DERIVED_ATT_MODE,
   X_PROVISIONAL_IND,
   X_DISCONTINUED_DT,
   X_DISCONTINUATION_REASON_CD,
   X_LAPSED_DT,
   X_FUNDING_SOURCE,
   X_FS_DESCRIPTION,
   X_EXAM_LOCATION_CD,
   X_ELO_DESCRIPTION,
   X_DERIVED_COMPLETION_YR,
   X_DERIVED_COMPLETION_PERD,
   X_NOMINATED_COMPLETION_YR,
   X_NOMINATED_COMPLETION_PERD,
   X_RULE_CHECK_IND,
   X_WAIVE_OPTION_CHECK_IND,
   X_LAST_RULE_CHECK_DT,
   X_PUBLISH_OUTCOMES_IND,
   X_COURSE_RQRMNT_COMPLETE_IND,
   X_COURSE_RQRMNTS_COMPLETE_DT,
   X_S_COMPLETED_SOURCE_TYPE,
   X_OVERRIDE_TIME_LIMITATION,
   X_ADVANCED_STANDING_IND,
   X_FEE_CAT,
   X_FC_DESCRIPTION,
   X_CORRESPONDENCE_CAT,
   X_CC_DESCRIPTION,
   X_SELF_HELP_GROUP_IND,
   X_ADM_ADMISSION_APPL_NUMBER,
   X_ADM_NOMINATED_COURSE_CD,
   X_ADM_SEQUENCE_NUMBER,
   X_MODE,
   X_LAST_DATE_OF_ATTENDANCE,
   X_DROPPED_BY,
   X_PRIMARY_PROGRAM_TYPE,
   X_PRIMARY_PROG_TYPE_SOURCE,
   X_CATALOG_CAL_TYPE,
   X_CATALOG_SEQ_NUM,
   X_KEY_PROGRAM,
   X_OVERRIDE_CMPL_DT,
   X_MANUAL_OVR_CMPL_DT_IND,
   X_COO_ID,
   X_IGS_PR_CLASS_STD_ID
);
END ADD_ROW;
PROCEDURE DELETE_ROW (
  X_ROWID IN VARCHAR2) AS
BEGIN
Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  DELETE FROM IGS_AS_SC_ATTEMPT_H_ALL
 WHERE ROWID = X_ROWID;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

END IGS_AS_SC_ATTEMPT_H_PKG;

/
