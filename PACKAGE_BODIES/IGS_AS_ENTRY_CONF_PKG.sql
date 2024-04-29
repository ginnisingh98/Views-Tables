--------------------------------------------------------
--  DDL for Package Body IGS_AS_ENTRY_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ENTRY_CONF_PKG" AS
/* $Header: IGSDI46B.pls 115.11 2003/12/05 11:02:13 kdande ship $ */
  l_rowid        VARCHAR2 (25);
  old_references igs_as_entry_conf%ROWTYPE;
  new_references igs_as_entry_conf%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_creation_date                IN     DATE,
    x_created_by                   IN     NUMBER,
    x_last_update_date             IN     DATE,
    x_last_updated_by              IN     NUMBER,
    x_last_update_login            IN     NUMBER,
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT *
      FROM   igs_as_entry_conf
      WHERE  ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF  (cur_old_ref_values%NOTFOUND)
        AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE cur_old_ref_values;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.s_control_num := x_s_control_num;
    new_references.key_allow_invalid_ind := x_key_allow_invalid_ind;
    new_references.key_collect_mark_ind := x_key_collect_mark_ind;
    new_references.key_grade_derive_ind := x_key_grade_derive_ind;
    new_references.key_mark_mndtry_ind := x_key_mark_mndtry_ind;
    new_references.upld_person_no_exist := x_upld_person_no_exist;
    new_references.upld_crs_not_enrolled := x_upld_crs_not_enrolled;
    new_references.upld_unit_not_enrolled := x_upld_unit_not_enrolled;
    new_references.upld_unit_discont := x_upld_unit_discont;
    new_references.upld_grade_invalid := x_upld_grade_invalid;
    new_references.upld_mark_grade_invalid := x_upld_mark_grade_invalid;
    new_references.key_mark_entry_dec_points := x_key_mark_entry_dec_points;
    new_references.key_prtl_sbmn_allowed_ind := x_key_prtl_sbmn_allowed_ind;
    new_references.upld_ug_sbmtd_grade_exist := x_upld_ug_sbmtd_grade_exist;
    new_references.upld_ug_saved_grade_exist := x_upld_ug_saved_grade_exist;
    new_references.upld_asmnt_item_not_exist := x_upld_asmnt_item_not_exist;
    new_references.upld_asmnt_item_grd_exist := x_upld_asmnt_item_grd_exist;
    new_references.key_derive_unit_grade_flag := x_key_derive_unit_grade_flag;
    new_references.key_allow_inst_finalize_flag := x_key_allow_inst_finalize_flag;
    new_references.key_ai_collect_mark_flag := x_key_ai_collect_mark_flag;
    new_references.key_ai_mark_mndtry_flag := x_key_ai_mark_mndtry_flag;
    new_references.key_ai_grade_derive_flag := x_key_ai_grade_derive_flag;
    new_references.key_ai_allow_invalid_flag := x_key_ai_allow_invalid_flag;
    new_references.key_ai_mark_entry_dec_points := x_key_ai_mark_entry_dec_points;
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
  END set_column_values;

  FUNCTION get_pk_for_validation (x_s_control_num IN NUMBER)
    RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT     ROWID
      FROM       igs_as_entry_conf
      WHERE      s_control_num = x_s_control_num
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN (FALSE);
    END IF;
  END get_pk_for_validation;

  PROCEDURE check_constraints (column_name IN VARCHAR2, column_value IN VARCHAR2) AS
  BEGIN
    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER (column_name) = 'KEY_ALLOW_INVALID_IND' THEN
      new_references.key_allow_invalid_ind := column_value;
    ELSIF UPPER (column_name) = 'KEY_COLLECT_MARK_IND' THEN
      new_references.key_collect_mark_ind := column_value;
    ELSIF UPPER (column_name) = 'KEY_GRADE_DERIVE_IND' THEN
      new_references.key_grade_derive_ind := column_value;
    ELSIF UPPER (column_name) = 'KEY_MARK_MNDTRY_IND' THEN
      new_references.key_mark_mndtry_ind := column_value;
    ELSIF UPPER (column_name) = 'UPLD_CRS_NOT_ENROLLED' THEN
      new_references.upld_crs_not_enrolled := column_value;
    ELSIF UPPER (column_name) = 'UPLD_GRADE_INVALID' THEN
      new_references.upld_grade_invalid := column_value;
    ELSIF UPPER (column_name) = 'UPLD_MARK_GRADE_INVALID' THEN
      new_references.upld_mark_grade_invalid := column_value;
    ELSIF UPPER (column_name) = 'UPLD_PERSON_NO_EXIST' THEN
      new_references.upld_person_no_exist := column_value;
    ELSIF UPPER (column_name) = 'UPLD_UNIT_DISCONT' THEN
      new_references.upld_unit_discont := column_value;
    ELSIF UPPER (column_name) = 'UPLD_UNIT_NOT_ENROLLED' THEN
      new_references.upld_unit_not_enrolled := column_value;
    ELSIF UPPER (column_name) = 'S_CONTROL_NUM' THEN
      new_references.s_control_num := igs_ge_number.to_num (column_value);
    ELSIF UPPER (column_name) = 'KEY_PRTL_SBMN_ALLOWED_IND' THEN
      new_references.key_prtl_sbmn_allowed_ind := column_value;
    ELSIF UPPER (column_name) = 'UPLD_UG_SBMTD_GRADE_EXIST' THEN
      new_references.upld_ug_sbmtd_grade_exist := column_value;
    ELSIF UPPER (column_name) = 'UPLD_UG_SAVED_GRADE_EXIST' THEN
      new_references.upld_ug_saved_grade_exist := column_value;
    ELSIF UPPER (column_name) = 'UPLD_ASMNT_ITEM_NOT_EXIST' THEN
      new_references.upld_asmnt_item_not_exist := column_value;
    ELSIF UPPER (column_name) = 'UPLD_ASMNT_ITEM_GRD_EXIST' THEN
      new_references.upld_asmnt_item_grd_exist := column_value;
    ELSIF UPPER (column_name) = 'KEY_DERIVE_UNIT_GRADE_FLAG' THEN
      new_references.key_derive_unit_grade_flag := column_value;
    ELSIF UPPER (column_name) = 'KEY_ALLOW_INST_FINALIZE_FLAG' THEN
      new_references.key_allow_inst_finalize_flag := column_value;
    ELSIF UPPER (column_name) = 'KEY_AI_COLLECT_MARK_FLAG' THEN
      new_references.key_ai_collect_mark_flag := column_value;
    ELSIF UPPER (column_name) = 'KEY_AI_MARK_MNDTRY_FLAG' THEN
      new_references.key_ai_mark_mndtry_flag := column_value;
    ELSIF UPPER (column_name) = 'KEY_AI_GRADE_DERIVE_FLAG' THEN
      new_references.key_ai_grade_derive_flag := column_value;
    ELSIF UPPER (column_name) = 'KEY_AI_ALLOW_INVALID_FLAG' THEN
      new_references.key_ai_allow_invalid_flag := column_value;
    END IF;
    IF UPPER (column_name) = 'KEY_ALLOW_INVALID_IND'
       OR column_name IS NULL THEN
      IF new_references.key_allow_invalid_ind <> UPPER (new_references.key_allow_invalid_ind)
         OR new_references.key_allow_invalid_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_COLLECT_MARK_IND'
       OR column_name IS NULL THEN
      IF new_references.key_collect_mark_ind <> UPPER (new_references.key_collect_mark_ind)
         OR new_references.key_collect_mark_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_GRADE_DERIVE_IND'
       OR column_name IS NULL THEN
      IF new_references.key_grade_derive_ind <> UPPER (new_references.key_grade_derive_ind)
         OR new_references.key_grade_derive_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_MARK_MNDTRY_IND'
       OR column_name IS NULL THEN
      IF new_references.key_mark_mndtry_ind <> UPPER (new_references.key_mark_mndtry_ind)
         OR new_references.key_mark_mndtry_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_CRS_NOT_ENROLLED'
       OR column_name IS NULL THEN
      IF new_references.upld_crs_not_enrolled <> UPPER (new_references.upld_crs_not_enrolled)
         OR new_references.upld_crs_not_enrolled NOT IN ('A', 'D', 'H') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_GRADE_INVALID'
       OR column_name IS NULL THEN
      IF new_references.upld_grade_invalid <> UPPER (new_references.upld_grade_invalid)
         OR new_references.upld_grade_invalid NOT IN ('D', 'A') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_MARK_GRADE_INVALID'
       OR column_name IS NULL THEN
      IF new_references.upld_mark_grade_invalid <> UPPER (new_references.upld_mark_grade_invalid)
         OR new_references.upld_mark_grade_invalid NOT IN ('A', 'D', 'H', 'W') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_PERSON_NO_EXIST'
       OR column_name IS NULL THEN
      IF new_references.upld_person_no_exist <> UPPER (new_references.upld_person_no_exist)
         OR new_references.upld_person_no_exist NOT IN ('A', 'D') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_UNIT_DISCONT'
       OR column_name IS NULL THEN
      IF new_references.upld_unit_discont <> UPPER (new_references.upld_unit_discont)
         OR new_references.upld_unit_discont NOT IN ('D', 'A', 'H') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_UNIT_NOT_ENROLLED'
       OR column_name IS NULL THEN
      IF new_references.upld_unit_not_enrolled <> UPPER (new_references.upld_unit_not_enrolled)
         OR new_references.upld_unit_not_enrolled NOT IN ('A', 'D', 'H') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'S_CONTROL_NUM'
       OR column_name IS NULL THEN
      IF  new_references.s_control_num < 1
          AND new_references.s_control_num > 1 THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_ALLOW_INVALID_IND'
       OR column_name IS NULL THEN
      IF new_references.key_allow_invalid_ind <> UPPER (new_references.key_allow_invalid_ind)
         OR new_references.key_allow_invalid_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_PRTL_SBMN_ALLOWED_IND'
       OR column_name IS NULL THEN
      IF new_references.key_prtl_sbmn_allowed_ind <> UPPER (new_references.key_prtl_sbmn_allowed_ind)
         OR new_references.key_prtl_sbmn_allowed_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_UG_SBMTD_GRADE_EXIST'
       OR column_name IS NULL THEN
      IF new_references.upld_ug_sbmtd_grade_exist <> UPPER (new_references.upld_ug_sbmtd_grade_exist)
         OR new_references.upld_ug_sbmtd_grade_exist NOT IN ('D', 'A') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_UG_SAVED_GRADE_EXIST'
       OR column_name IS NULL THEN
      IF new_references.upld_ug_saved_grade_exist <> UPPER (new_references.upld_ug_saved_grade_exist)
         OR new_references.upld_ug_saved_grade_exist NOT IN ('D', 'A', 'W') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_ASMNT_ITEM_NOT_EXIST'
       OR column_name IS NULL THEN
      IF new_references.upld_asmnt_item_not_exist <> UPPER (new_references.upld_asmnt_item_not_exist)
         OR new_references.upld_asmnt_item_not_exist NOT IN ('D', 'A') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UPLD_ASMNT_ITEM_GRD_EXIST'
       OR column_name IS NULL THEN
      IF new_references.upld_asmnt_item_grd_exist <> UPPER (new_references.upld_asmnt_item_grd_exist)
         OR new_references.upld_asmnt_item_grd_exist NOT IN ('D', 'A', 'W') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_DERIVE_UNIT_GRADE_FLAG'
       OR column_name IS NULL THEN
      IF new_references.key_derive_unit_grade_flag <> UPPER (new_references.key_derive_unit_grade_flag)
         OR new_references.key_derive_unit_grade_flag NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_ALLOW_INST_FINALIZE_FLAG'
       OR column_name IS NULL THEN
      IF new_references.key_allow_inst_finalize_flag <> UPPER (new_references.key_allow_inst_finalize_flag)
         OR new_references.key_allow_inst_finalize_flag NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_AI_COLLECT_MARK_FLAG'
       OR column_name IS NULL THEN
      IF new_references.key_ai_collect_mark_flag <> UPPER (new_references.key_ai_collect_mark_flag)
         OR new_references.key_ai_collect_mark_flag NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_AI_MARK_MNDTRY_FLAG'
       OR column_name IS NULL THEN
      IF new_references.key_ai_mark_mndtry_flag <> UPPER (new_references.key_ai_mark_mndtry_flag)
         OR new_references.key_ai_mark_mndtry_flag NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_AI_GRADE_DERIVE_FLAG'
       OR column_name IS NULL THEN
      IF new_references.key_ai_grade_derive_flag <> UPPER (new_references.key_ai_grade_derive_flag)
         OR new_references.key_ai_grade_derive_flag NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'KEY_AI_ALLOW_INVALID_FLAG'
       OR column_name IS NULL THEN
      IF new_references.key_ai_allow_invalid_flag <> UPPER (new_references.key_ai_allow_invalid_flag)
         OR new_references.key_ai_allow_invalid_flag NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
  END check_constraints;

  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_creation_date                IN     DATE,
    x_created_by                   IN     NUMBER,
    x_last_update_date             IN     DATE,
    x_last_updated_by              IN     NUMBER,
    x_last_update_login            IN     NUMBER,
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  ) AS
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_s_control_num,
      x_key_allow_invalid_ind,
      x_key_collect_mark_ind,
      x_key_grade_derive_ind,
      x_key_mark_mndtry_ind,
      x_upld_person_no_exist,
      x_upld_crs_not_enrolled,
      x_upld_unit_not_enrolled,
      x_upld_unit_discont,
      x_upld_grade_invalid,
      x_upld_mark_grade_invalid,
      x_key_mark_entry_dec_points,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_key_prtl_sbmn_allowed_ind,
      x_upld_ug_sbmtd_grade_exist,
      x_upld_ug_saved_grade_exist,
      x_upld_asmnt_item_not_exist,
      x_upld_asmnt_item_grd_exist,
      x_key_derive_unit_grade_flag,
      x_key_allow_inst_finalize_flag,
      x_key_ai_collect_mark_flag,
      x_key_ai_mark_mndtry_flag,
      x_key_ai_grade_derive_flag,
      x_key_ai_allow_invalid_flag,
      x_key_ai_mark_entry_dec_points
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF get_pk_for_validation (new_references.s_control_num) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      NULL;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF get_pk_for_validation (new_references.s_control_num) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
    END IF;
  END before_dml;

  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_mode                         IN     VARCHAR2,
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  ) AS
    CURSOR c IS
      SELECT ROWID
      FROM   igs_as_entry_conf
      WHERE  s_control_num = x_s_control_num;
    x_last_update_date  DATE;
    x_last_updated_by   NUMBER;
    x_last_update_login NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml (
      p_action                       => 'INSERT',
      x_rowid                        => x_rowid,
      x_key_allow_invalid_ind        => NVL (x_key_allow_invalid_ind, 'Y'),
      x_key_collect_mark_ind         => NVL (x_key_collect_mark_ind, 'Y'),
      x_key_grade_derive_ind         => NVL (x_key_grade_derive_ind, 'Y'),
      x_key_mark_mndtry_ind          => NVL (x_key_mark_mndtry_ind, 'N'),
      x_s_control_num                => x_s_control_num,
      x_upld_crs_not_enrolled        => NVL (x_upld_crs_not_enrolled, 'D'),
      x_upld_grade_invalid           => NVL (x_upld_grade_invalid, 'D'),
      x_upld_mark_grade_invalid      => NVL (x_upld_mark_grade_invalid, 'D'),
      x_upld_person_no_exist         => NVL (x_upld_person_no_exist, 'D'),
      x_upld_unit_discont            => NVL (x_upld_unit_discont, 'D'),
      x_upld_unit_not_enrolled       => NVL (x_upld_unit_not_enrolled, 'D'),
      x_key_mark_entry_dec_points    => x_key_mark_entry_dec_points,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_key_prtl_sbmn_allowed_ind    => x_key_prtl_sbmn_allowed_ind,
      x_upld_ug_sbmtd_grade_exist    => x_upld_ug_sbmtd_grade_exist,
      x_upld_ug_saved_grade_exist    => x_upld_ug_saved_grade_exist,
      x_upld_asmnt_item_not_exist    => x_upld_asmnt_item_not_exist,
      x_upld_asmnt_item_grd_exist    => x_upld_asmnt_item_grd_exist,
      x_key_derive_unit_grade_flag   => x_key_derive_unit_grade_flag,
      x_key_allow_inst_finalize_flag => x_key_allow_inst_finalize_flag,
      x_key_ai_collect_mark_flag     => x_key_ai_collect_mark_flag,
      x_key_ai_mark_mndtry_flag      => x_key_ai_mark_mndtry_flag,
      x_key_ai_grade_derive_flag     => x_key_ai_grade_derive_flag,
      x_key_ai_allow_invalid_flag    => x_key_ai_allow_invalid_flag,
      x_key_ai_mark_entry_dec_points => x_key_ai_mark_entry_dec_points
    );
    INSERT INTO igs_as_entry_conf
                (s_control_num,
                 key_allow_invalid_ind,
                 key_collect_mark_ind,
                 key_grade_derive_ind,
                 key_mark_mndtry_ind,
                 upld_person_no_exist,
                 upld_crs_not_enrolled,
                 upld_unit_not_enrolled,
                 upld_unit_discont,
                 upld_grade_invalid,
                 upld_mark_grade_invalid,
                 key_mark_entry_dec_points, creation_date,
                 created_by, last_update_date, last_updated_by,
                 last_update_login, key_prtl_sbmn_allowed_ind,
                 upld_ug_sbmtd_grade_exist,
                 upld_ug_saved_grade_exist,
                 upld_asmnt_item_not_exist,
                 upld_asmnt_item_grd_exist,
                 key_derive_unit_grade_flag,
                 key_allow_inst_finalize_flag,
                 key_ai_collect_mark_flag,
                 key_ai_mark_mndtry_flag,
                 key_ai_grade_derive_flag,
                 key_ai_allow_invalid_flag,
                 key_ai_mark_entry_dec_points
                 )
         VALUES (new_references.s_control_num,
                 new_references.key_allow_invalid_ind,
                 new_references.key_collect_mark_ind,
                 new_references.key_grade_derive_ind,
                 new_references.key_mark_mndtry_ind,
                 new_references.upld_person_no_exist,
                 new_references.upld_crs_not_enrolled,
                 new_references.upld_unit_not_enrolled,
                 new_references.upld_unit_discont,
                 new_references.upld_grade_invalid,
                 new_references.upld_mark_grade_invalid,
                 new_references.key_mark_entry_dec_points, x_last_update_date,
                 x_last_updated_by, x_last_update_date, x_last_updated_by,
                 x_last_update_login, new_references.key_prtl_sbmn_allowed_ind,
                 new_references.upld_ug_sbmtd_grade_exist,
                 new_references.upld_ug_saved_grade_exist,
                 new_references.upld_asmnt_item_not_exist,
                 new_references.upld_asmnt_item_grd_exist,
                 new_references.key_derive_unit_grade_flag,
                 new_references.key_allow_inst_finalize_flag,
                 new_references.key_ai_collect_mark_flag,
                 new_references.key_ai_mark_mndtry_flag,
                 new_references.key_ai_grade_derive_flag,
                 new_references.key_ai_allow_invalid_flag,
                 new_references.key_ai_mark_entry_dec_points);
    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
  END insert_row;

  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  ) AS
    CURSOR c1 IS
      SELECT     key_allow_invalid_ind,
                 key_collect_mark_ind,
                 key_grade_derive_ind,
                 key_mark_mndtry_ind,
                 upld_person_no_exist,
                 upld_crs_not_enrolled,
                 upld_unit_not_enrolled,
                 upld_unit_discont,
                 upld_grade_invalid,
                 upld_mark_grade_invalid,
                 key_mark_entry_dec_points,
                 key_prtl_sbmn_allowed_ind,
                 upld_ug_sbmtd_grade_exist,
                 upld_ug_saved_grade_exist,
                 upld_asmnt_item_not_exist,
                 upld_asmnt_item_grd_exist,
                 key_derive_unit_grade_flag,
                 key_allow_inst_finalize_flag,
                 key_ai_collect_mark_flag,
                 key_ai_mark_mndtry_flag,
                 key_ai_grade_derive_flag,
                 key_ai_allow_invalid_flag,
                 key_ai_mark_entry_dec_points
      FROM       igs_as_entry_conf
      WHERE      ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;
    IF ((tlinfo.key_allow_invalid_ind = x_key_allow_invalid_ind)
        AND (tlinfo.key_collect_mark_ind = x_key_collect_mark_ind)
        AND (tlinfo.key_grade_derive_ind = x_key_grade_derive_ind)
        AND (tlinfo.key_mark_mndtry_ind = x_key_mark_mndtry_ind)
        AND (tlinfo.upld_person_no_exist = x_upld_person_no_exist)
        AND (tlinfo.upld_crs_not_enrolled = x_upld_crs_not_enrolled)
        AND (tlinfo.upld_unit_not_enrolled = x_upld_unit_not_enrolled)
        AND (tlinfo.upld_unit_discont = x_upld_unit_discont)
        AND (tlinfo.upld_grade_invalid = x_upld_grade_invalid)
        AND (tlinfo.upld_mark_grade_invalid = x_upld_mark_grade_invalid)
        AND (tlinfo.key_mark_entry_dec_points = x_key_mark_entry_dec_points
             OR (tlinfo.key_mark_entry_dec_points IS NULL
                 AND x_key_mark_entry_dec_points IS NULL
                )
            )
        AND (tlinfo.key_prtl_sbmn_allowed_ind = x_key_prtl_sbmn_allowed_ind
             OR (tlinfo.key_prtl_sbmn_allowed_ind IS NULL
                 AND x_key_prtl_sbmn_allowed_ind IS NULL
                )
            )
        AND (tlinfo.upld_ug_sbmtd_grade_exist = x_upld_ug_sbmtd_grade_exist
             OR (tlinfo.upld_ug_sbmtd_grade_exist IS NULL
                 AND x_upld_ug_sbmtd_grade_exist IS NULL
                )
            )
        AND (tlinfo.upld_ug_saved_grade_exist = x_upld_ug_saved_grade_exist
             OR (tlinfo.upld_ug_saved_grade_exist IS NULL
                 AND x_upld_ug_saved_grade_exist IS NULL
                )
            )
        AND (tlinfo.upld_asmnt_item_not_exist = x_upld_asmnt_item_not_exist
             OR (tlinfo.upld_asmnt_item_not_exist IS NULL
                 AND x_upld_asmnt_item_not_exist IS NULL
                )
            )
        AND (tlinfo.upld_asmnt_item_grd_exist = x_upld_asmnt_item_grd_exist
             OR (tlinfo.upld_asmnt_item_grd_exist IS NULL
                 AND x_upld_asmnt_item_grd_exist IS NULL
                )
            )
        AND (tlinfo.key_derive_unit_grade_flag = x_key_derive_unit_grade_flag
             OR (tlinfo.key_derive_unit_grade_flag IS NULL
                 AND x_key_derive_unit_grade_flag IS NULL
                )
            )
        AND (tlinfo.key_allow_inst_finalize_flag = x_key_allow_inst_finalize_flag
             OR (tlinfo.key_allow_inst_finalize_flag IS NULL
                 AND x_key_allow_inst_finalize_flag IS NULL
                )
            )
        AND (tlinfo.key_ai_collect_mark_flag = x_key_ai_collect_mark_flag
             OR (tlinfo.key_ai_collect_mark_flag IS NULL
                 AND x_key_ai_collect_mark_flag IS NULL
                )
            )
        AND (tlinfo.key_ai_mark_mndtry_flag = x_key_ai_mark_mndtry_flag
             OR (tlinfo.key_ai_mark_mndtry_flag IS NULL
                 AND x_key_ai_mark_mndtry_flag IS NULL
                )
            )
        AND (tlinfo.key_ai_grade_derive_flag = x_key_ai_grade_derive_flag
             OR (tlinfo.key_ai_grade_derive_flag IS NULL
                 AND x_key_ai_grade_derive_flag IS NULL
                )
            )
        AND (tlinfo.key_ai_allow_invalid_flag = x_key_ai_allow_invalid_flag
             OR (tlinfo.key_ai_allow_invalid_flag IS NULL
                 AND x_key_ai_allow_invalid_flag IS NULL
                )
            )
        AND (tlinfo.key_ai_mark_entry_dec_points = x_key_ai_mark_entry_dec_points
             OR (tlinfo.key_ai_mark_entry_dec_points IS NULL
                 AND x_key_ai_mark_entry_dec_points IS NULL
                )
            )
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    RETURN;
  END lock_row;

  PROCEDURE update_row (
    x_rowid                        IN     VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_mode                         IN     VARCHAR2,
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  ) AS
    x_last_update_date  DATE;
    x_last_updated_by   NUMBER;
    x_last_update_login NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml (
      p_action                       => 'UPDATE',
      x_rowid                        => x_rowid,
      x_key_allow_invalid_ind        => x_key_allow_invalid_ind,
      x_key_collect_mark_ind         => x_key_collect_mark_ind,
      x_key_grade_derive_ind         => x_key_grade_derive_ind,
      x_key_mark_mndtry_ind          => x_key_mark_mndtry_ind,
      x_s_control_num                => x_s_control_num,
      x_upld_crs_not_enrolled        => x_upld_crs_not_enrolled,
      x_upld_grade_invalid           => x_upld_grade_invalid,
      x_upld_mark_grade_invalid      => x_upld_mark_grade_invalid,
      x_upld_person_no_exist         => x_upld_person_no_exist,
      x_upld_unit_discont            => x_upld_unit_discont,
      x_upld_unit_not_enrolled       => x_upld_unit_not_enrolled,
      x_key_mark_entry_dec_points    => x_key_mark_entry_dec_points,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_key_prtl_sbmn_allowed_ind    => x_key_prtl_sbmn_allowed_ind,
      x_upld_ug_sbmtd_grade_exist    => x_upld_ug_sbmtd_grade_exist,
      x_upld_ug_saved_grade_exist    => x_upld_ug_saved_grade_exist,
      x_upld_asmnt_item_not_exist    => x_upld_asmnt_item_not_exist,
      x_upld_asmnt_item_grd_exist    => x_upld_asmnt_item_grd_exist,
      x_key_derive_unit_grade_flag   => x_key_derive_unit_grade_flag,
      x_key_allow_inst_finalize_flag => x_key_allow_inst_finalize_flag,
      x_key_ai_collect_mark_flag     => x_key_ai_collect_mark_flag,
      x_key_ai_mark_mndtry_flag      => x_key_ai_mark_mndtry_flag,
      x_key_ai_grade_derive_flag     => x_key_ai_grade_derive_flag,
      x_key_ai_allow_invalid_flag    => x_key_ai_allow_invalid_flag,
      x_key_ai_mark_entry_dec_points => x_key_ai_mark_entry_dec_points
    );
    UPDATE igs_as_entry_conf
       SET key_allow_invalid_ind = new_references.key_allow_invalid_ind,
           key_collect_mark_ind = new_references.key_collect_mark_ind,
           key_grade_derive_ind = new_references.key_grade_derive_ind,
           key_mark_mndtry_ind = new_references.key_mark_mndtry_ind,
           upld_person_no_exist = new_references.upld_person_no_exist,
           upld_crs_not_enrolled = new_references.upld_crs_not_enrolled,
           upld_unit_not_enrolled = new_references.upld_unit_not_enrolled,
           upld_unit_discont = new_references.upld_unit_discont,
           upld_grade_invalid = new_references.upld_grade_invalid,
           upld_mark_grade_invalid = new_references.upld_mark_grade_invalid,
           key_mark_entry_dec_points = new_references.key_mark_entry_dec_points,
           last_update_date = x_last_update_date,
           last_updated_by = x_last_updated_by,
           last_update_login = x_last_update_login,
           key_prtl_sbmn_allowed_ind = x_key_prtl_sbmn_allowed_ind,
           upld_ug_sbmtd_grade_exist = x_upld_ug_sbmtd_grade_exist,
           upld_ug_saved_grade_exist = x_upld_ug_saved_grade_exist,
           upld_asmnt_item_not_exist = x_upld_asmnt_item_not_exist,
           upld_asmnt_item_grd_exist = x_upld_asmnt_item_grd_exist,
           key_derive_unit_grade_flag = x_key_derive_unit_grade_flag,
           key_allow_inst_finalize_flag = x_key_allow_inst_finalize_flag,
           key_ai_collect_mark_flag = x_key_ai_collect_mark_flag,
           key_ai_mark_mndtry_flag = x_key_ai_mark_mndtry_flag,
           key_ai_grade_derive_flag = x_key_ai_grade_derive_flag,
           key_ai_allow_invalid_flag = x_key_ai_allow_invalid_flag,
           key_ai_mark_entry_dec_points = x_key_ai_mark_entry_dec_points
     WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;

  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_mode                         IN     VARCHAR2,
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  ) AS
    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_as_entry_conf
      WHERE  s_control_num = x_s_control_num;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_s_control_num,
        x_key_allow_invalid_ind,
        x_key_collect_mark_ind,
        x_key_grade_derive_ind,
        x_key_mark_mndtry_ind,
        x_upld_person_no_exist,
        x_upld_crs_not_enrolled,
        x_upld_unit_not_enrolled,
        x_upld_unit_discont,
        x_upld_grade_invalid,
        x_upld_mark_grade_invalid,
        x_key_mark_entry_dec_points,
        x_mode,
        x_key_prtl_sbmn_allowed_ind,
        x_upld_ug_sbmtd_grade_exist,
        x_upld_ug_saved_grade_exist,
        x_upld_asmnt_item_not_exist,
        x_upld_asmnt_item_grd_exist,
        x_key_derive_unit_grade_flag,
        x_key_allow_inst_finalize_flag,
        x_key_ai_collect_mark_flag,
        x_key_ai_mark_mndtry_flag,
        x_key_ai_grade_derive_flag,
        x_key_ai_allow_invalid_flag,
        x_key_ai_mark_entry_dec_points
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_s_control_num,
      x_key_allow_invalid_ind,
      x_key_collect_mark_ind,
      x_key_grade_derive_ind,
      x_key_mark_mndtry_ind,
      x_upld_person_no_exist,
      x_upld_crs_not_enrolled,
      x_upld_unit_not_enrolled,
      x_upld_unit_discont,
      x_upld_grade_invalid,
      x_upld_mark_grade_invalid,
      x_key_mark_entry_dec_points,
      x_mode,
      x_key_prtl_sbmn_allowed_ind,
      x_upld_ug_sbmtd_grade_exist,
      x_upld_ug_saved_grade_exist,
      x_upld_asmnt_item_not_exist,
      x_upld_asmnt_item_grd_exist,
      x_key_derive_unit_grade_flag,
      x_key_allow_inst_finalize_flag,
      x_key_ai_collect_mark_flag,
      x_key_ai_mark_mndtry_flag,
      x_key_ai_grade_derive_flag,
      x_key_ai_allow_invalid_flag,
      x_key_ai_mark_entry_dec_points
    );
  END add_row;

  PROCEDURE delete_row (x_rowid IN VARCHAR2) AS
  BEGIN
    before_dml (
      p_action                       => 'DELETE',
      x_rowid                        => x_rowid
    );
    DELETE FROM igs_as_entry_conf
          WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;
END igs_as_entry_conf_pkg;

/
