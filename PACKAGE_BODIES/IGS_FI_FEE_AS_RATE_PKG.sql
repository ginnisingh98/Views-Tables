--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_AS_RATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_AS_RATE_PKG" AS
/* $Header: IGSSI68B.pls 120.4 2006/05/26 10:57:37 sapanigr ship $*/

  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_AS_RATE%RowType;
  new_references IGS_FI_FEE_AS_RATE%RowType;
  -- Forward declaring the private procedure to ensure compiling of the package
  PROCEDURE beforerowupdate;

  PROCEDURE Set_Column_Values (
    p_action                      IN VARCHAR2,
    x_rowid                       IN VARCHAR2 ,
    x_far_id                      IN NUMBER ,
    x_fee_type                    IN VARCHAR2 ,
    x_fee_cal_type                IN VARCHAR2 ,
    x_fee_ci_sequence_number      IN NUMBER ,
    x_s_relation_type             IN VARCHAR2 ,
    x_rate_number                 IN NUMBER ,
    x_fee_cat                     IN VARCHAR2 ,
    x_location_cd                 IN VARCHAR2 ,
    x_attendance_type             IN VARCHAR2 ,
    x_attendance_mode             IN VARCHAR2 ,
    x_order_of_precedence         IN NUMBER ,
    x_govt_hecs_payment_option    IN VARCHAR2 ,
    x_govt_hecs_cntrbtn_band      IN NUMBER ,
    x_chg_rate                    IN NUMBER ,
    x_logical_delete_dt           IN DATE ,
    x_residency_status_cd         IN VARCHAR2 ,
    x_course_cd                   IN VARCHAR2 ,
    x_version_number              IN NUMBER ,
    x_org_party_id                IN NUMBER ,
    x_class_standing              IN VARCHAR2 ,
    x_creation_date               IN DATE ,
    x_created_by                  IN NUMBER ,
    x_last_update_date            IN DATE ,
    x_last_updated_by             IN NUMBER ,
    x_last_update_login           IN NUMBER,
    x_unit_set_cd                 IN VARCHAR2,
    x_us_version_number           IN NUMBER,
    x_unit_cd                     IN VARCHAR2 ,
    x_unit_version_number         IN NUMBER   ,
    x_unit_level                  IN VARCHAR2 ,
    x_unit_type_id                IN NUMBER   ,
    x_unit_class                  IN VARCHAR2 ,
    x_unit_mode                   IN VARCHAR2

  ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  --------------------------------------------------------------------*/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    rowid = x_rowid;

  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.far_id                   := x_far_id;
    new_references.fee_type                 := x_fee_type;
    new_references.fee_cal_type             := x_fee_cal_type;
    new_references.fee_ci_sequence_number   := x_fee_ci_sequence_number;
    new_references.s_relation_type          := x_s_relation_type;
    new_references.rate_number              := x_rate_number;
    new_references.fee_cat                  := x_fee_cat;
    new_references.location_cd              := x_location_cd;
    new_references.attendance_type          := x_attendance_type;
    new_references.attendance_mode          := x_attendance_mode;
    new_references.order_of_precedence      := x_order_of_precedence;
    new_references.govt_hecs_payment_option := x_govt_hecs_payment_option;
    new_references.govt_hecs_cntrbtn_band   := x_govt_hecs_cntrbtn_band;
    new_references.chg_rate                 := x_chg_rate;
    new_references.logical_delete_dt        := x_logical_delete_dt;
    new_references.residency_status_cd      := x_residency_status_cd;
    new_references.course_cd                := x_course_cd;
    new_references.version_number           := x_version_number;
    new_references.org_party_id             := x_org_party_id;
    new_references.class_standing           := x_class_standing;
    new_references.unit_set_cd              := x_unit_set_cd;
    new_references.us_version_number        := x_us_version_number;
    new_references.unit_cd                  := x_unit_cd  ;
    new_references.unit_version_number      := x_unit_version_number ;
    new_references.unit_level               := x_unit_level   ;
    new_references.unit_type_id             := x_unit_type_id ;
    new_references.unit_class               := x_unit_class   ;
    new_references.unit_mode                := x_unit_mode    ;


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


  -- Trigger description
  -- before insert or delete or update on IGS_FI_FEE_AS_RATE for each row
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
   v_message_name varchar2(30);
  BEGIN
        -- Validate Fee Assessment Rate can be created.
        IF p_inserting THEN
                -- If IGS_FI_FEE_TYPE.s_fee_trigger_cat = 'INSTITUTN' or
                -- IGS_FI_FEE_TYPE.s_fee_type = 'HECS', then schedules can only
                -- be defined against FTCI's.
                IF new_references.s_relation_type <> 'FTCI' THEN
                        IF IGS_FI_VAL_FAR.finp_val_far_ins (
                                        new_references.fee_type,
                                        v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
        END IF;
        -- Validate that appropriate fields are set depending on the fee type.
        IF p_inserting OR p_updating THEN
                IF IGS_FI_VAL_FAR.finp_val_far_defntn (
                                new_references.fee_type,
                                new_references.location_cd,
                                new_references.attendance_type,
                                new_references.attendance_mode,
                                new_references.govt_hecs_payment_option,
                                new_references.govt_hecs_cntrbtn_band,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate fee category is only set when the relation type = 'FCFL'.
        IF p_inserting OR p_updating THEN
                IF IGS_FI_VAL_FAR.finp_val_far_rltn (
                                        new_references.s_relation_type,
                                        new_references.fee_cat,
                                        v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate closed indicators.
        IF p_inserting OR p_updating THEN
                -- Validate for closed location.
                IF IGS_FI_VAL_FAR.crsp_val_loc_cd (
                                        new_references.location_cd,
                                        v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
                -- Validate for closed attendance type.
-- change igs_fi_val_far.enrp_val_att_closed
-- to     igs_en_val_pee.enrp_val_att_closed
--
                IF IGS_EN_VAL_PEE.enrp_val_att_closed (
                                        new_references.attendance_type,
                                        v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
                -- Validate for closed attendance mode.
                IF IGS_FI_VAL_FAR.enrp_val_am_closed (
                                        new_references.attendance_mode,
                                        v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
  END BeforeRowInsertUpdateDelete1;


  -- Trigger description :-
  -- AFTER UPDATE ON IGS_FI_FEE_AS_RATE FOR EACH ROW
  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  ||                                  in call to finp_ins_far_hist
  --------------------------------------------------------------------*/
  BEGIN
        -- create a history
        igs_fi_gen_002.finp_ins_far_hist(old_references.fee_type,
                old_references.fee_cal_type,
                old_references.fee_ci_sequence_number,
                old_references.s_relation_type,
                old_references.rate_number,
                new_references.fee_cat,
                old_references.fee_cat,
                new_references.location_cd,
                old_references.location_cd,
                new_references.attendance_type,
                old_references.attendance_type,
                new_references.attendance_mode,
                old_references.attendance_mode,
                new_references.order_of_precedence,
                old_references.order_of_precedence,
                new_references.govt_hecs_payment_option,
                old_references.govt_hecs_payment_option,
                new_references.govt_hecs_cntrbtn_band,
                old_references.govt_hecs_cntrbtn_band,
                new_references.chg_rate,
                old_references.chg_rate,
                new_references.unit_class ,
                old_references.unit_class ,
                new_references.residency_status_cd,
                old_references.residency_status_cd,
                new_references.course_cd,
                old_references.course_cd,
                new_references.version_number,
                old_references.version_number,
                new_references.org_party_id,
                old_references.org_party_id,
                new_references.class_standing,
                old_references.class_standing,
                new_references.last_updated_by,
                old_references.last_updated_by,
                new_references.last_update_date,
                old_references.last_update_date,
                new_references.unit_set_cd,
                old_references.unit_set_cd,
                new_references.us_version_number,
                old_references.us_version_number,
                new_references.unit_cd ,
                old_references.unit_cd ,
                new_references.unit_version_number,
                old_references.unit_version_number,
                new_references.unit_level ,
                old_references.unit_level ,
                new_references.unit_type_id,
                old_references.unit_type_id,
                new_references.unit_mode ,
                old_references.unit_mode
                );

  END AfterRowUpdate3;


  -- Trigger description :-
  -- AFTER INSERT OR UPDATE ON IGS_FI_FEE_AS_RATE
  PROCEDURE AfterStmtInsertUpdate4(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Modified call to finp_val_far_unique - Added 2
  ||                                  new columns unit_set_cd and us_version_number
  --------------------------------------------------------------------*/
  v_message_name varchar2(30);
  v_message_string VARCHAR2(512);
  BEGIN
        -- Validate if fee_ass_rate can be created and if so, then
        -- validate that it is unique and the order of precedence.
        IF p_inserting OR p_updating THEN
                IF IGS_FI_VAL_FAR.finp_val_far_create(new_references.fee_type,
                                      new_references.fee_cal_type,
                                      new_references.fee_ci_sequence_number,
                                      new_references.s_relation_type,
                                      v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
                IF igs_fi_val_far.finp_val_far_unique(new_references.fee_type,
                                      new_references.fee_cal_type,
                                      new_references.fee_ci_sequence_number,
                                      new_references.s_relation_type,
                                      new_references.rate_number,
                                      new_references.fee_cat,
                                      new_references.location_cd,
                                      new_references.attendance_type,
                                      new_references.attendance_mode,
                                      new_references.govt_hecs_payment_option,
                                      new_references.govt_hecs_cntrbtn_band,
                                      new_references.chg_rate,
                                      new_references.unit_class,
                                      new_references.residency_status_cd,
                                      new_references.course_cd,
                                      new_references.version_number,
                                      new_references.org_party_id,
                                      new_references.class_standing,
                                      v_message_name,
                                      new_references.unit_set_cd,
                                      new_references.us_version_number,
                                      new_references.unit_cd ,
                                      new_references.unit_version_number,
                                      new_references.unit_level ,
                                      new_references.unit_type_id,
                                      new_references.unit_mode
                                      ) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
                IF IGS_FI_VAL_FAR.finp_val_far_order(new_references.fee_type,
                                      new_references.fee_cal_type,
                                      new_references.fee_ci_sequence_number,
                                      new_references.s_relation_type,
                                      new_references.rate_number,
                                      new_references.fee_cat,
                                      new_references.location_cd,
                                      new_references.attendance_type,
                                      new_references.attendance_mode,
                                      new_references.govt_hecs_payment_option,
                                      new_references.govt_hecs_cntrbtn_band,
                                      new_references.order_of_precedence,
                                      v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
  END AfterStmtInsertUpdate4;


  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 ,
    column_value IN  VARCHAR2
  ) AS
   /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr        26-May-2006    Enh 5217319. Removed highest value criteria for item 'CHG_RATE'
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  ||  vvutukur       21-Apr-2003      Bug#2885575.Changed the upper limit check to 999999999 for fields rate_number and order_of_precedence.
  ||  SYKRISHn       10APR03          ORDER_OF_PRECEDENCE - Changes limit check to 9999
  ||  vvutukur        12-May-2002     removed upper check constraint on fee category,fee type columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'ATTENDANCE_MODE') THEN
      new_references.attendance_mode := column_value;
    ELSIF (UPPER (column_name) = 'ATTENDANCE_TYPE') THEN
      new_references.attendance_type := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CAL_TYPE') THEN
      new_references.fee_cal_type := column_value;
    ELSIF (UPPER (column_name) = 'GOVT_HECS_PAYMENT_OPTION') THEN
      new_references.govt_hecs_payment_option := column_value;
    ELSIF (UPPER (column_name) = 'LOCATION_CD') THEN
      new_references.location_cd := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') THEN
      new_references.fee_ci_sequence_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'S_RELATION_TYPE') THEN
      new_references.s_relation_type := column_value;
    ELSIF (UPPER (column_name) = 'RATE_NUMBER') THEN
      new_references.rate_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'ORDER_OF_PRECEDENCE') THEN
      new_references.order_of_precedence := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'CHG_RATE') THEN
      new_references.chg_rate := igs_ge_number.to_num (column_value);
    ELSIF (UPPER (column_name) = 'COURSE_CD') THEN
      new_references.course_cd := column_value;
    ELSIF (UPPER (column_name) = 'VERSION_NUMBER') THEN
      new_references.version_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER (column_name) = 'CLASS_STANDING') THEN
      new_references.class_standing := column_value;
    ELSIF (UPPER(column_name) = 'UNIT_SET_CD') THEN
      new_references.unit_set_cd := column_value;
    ELSIF (UPPER(column_name) = 'UNIT_VERSION_NUMBER') THEN
      new_references.unit_version_number := igs_ge_number.to_num(column_value);
    ELSIF (UPPER(column_name) = 'US_VERSION_NUMBER') THEN
      new_references.us_version_number := igs_ge_number.to_num(column_value);
    ELSIF (UPPER(column_name) = 'UNIT_TYPE_ID') THEN
      new_references.unit_type_id := igs_ge_number.to_num(column_value);
    ELSIF (UPPER (column_name) = 'UNIT_CD') THEN
      new_references.unit_cd  := column_value;
    ELSIF (UPPER (column_name) = 'UNIT_LEVEL') THEN
      new_references.unit_level := column_value;
    ELSIF (UPPER (column_name) = 'UNIT_CLASS') THEN
      new_references.unit_class := column_value;
    ELSIF (UPPER(column_name) = 'UNIT_MODE') THEN
      new_references.unit_mode := column_value;
    END IF;

    IF ((UPPER (column_name) = 'ATTENDANCE_MODE') OR (column_name IS NULL)) THEN
      IF (new_references.attendance_mode <> UPPER (new_references.attendance_mode)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'ATTENDANCE_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.attendance_type <> UPPER (new_references.attendance_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.fee_cal_type <> UPPER (new_references.fee_cal_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'GOVT_HECS_PAYMENT_OPTION') OR (column_name IS NULL)) THEN
      IF (new_references.govt_hecs_payment_option <> UPPER (new_references.govt_hecs_payment_option)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'LOCATION_CD') OR (column_name IS NULL)) THEN
      IF (new_references.location_cd <> UPPER (new_references.location_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.fee_ci_sequence_number < 1) OR (new_references.fee_ci_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'S_RELATION_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.s_relation_type NOT IN ('FTCI', 'FCFL')) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'RATE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.rate_number < 1) OR (new_references.rate_number > 999999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'ORDER_OF_PRECEDENCE') OR (column_name IS NULL)) THEN
      IF ((new_references.order_of_precedence < 0) OR (new_references.order_of_precedence > 999999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'CHG_RATE') OR (column_name IS NULL)) THEN
      IF (new_references.chg_rate < 0) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'COURSE_CD') OR (column_name IS NULL)) THEN
      IF (new_references.course_cd <> UPPER (new_references.course_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'VERSION_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.version_number < 0) OR (new_references.version_number > 999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'CLASS_STANDING') OR (column_name IS NULL)) THEN
      IF (new_references.class_standing <> UPPER (new_references.class_standing)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'UNIT_SET_CD') OR (column_name IS NULL)) THEN
      IF (new_references.unit_set_cd <> UPPER(new_references.unit_set_cd)) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'US_VERSION_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.us_version_number < 0) OR (new_references.us_version_number > 999)) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'UNIT_VERSION_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.unit_version_number < 0) OR (new_references.unit_version_number > 999)) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'UNIT_TYPE_ID') OR (column_name IS NULL)) THEN
      IF (new_references.unit_type_id < 0) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'UNIT_CD') OR (column_name IS NULL)) THEN
      IF (new_references.unit_cd <> UPPER (new_references.unit_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'UNIT_LEVEL') OR (column_name IS NULL)) THEN
      IF (new_references.unit_level <> UPPER(new_references.unit_level)) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'UNIT_CLASS') OR (column_name IS NULL)) THEN
      IF (new_references.unit_class <> UPPER (new_references.unit_class)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'UNIT_MODE') OR (column_name IS NULL)) THEN
      IF (new_references.unit_mode <> UPPER(new_references.unit_mode)) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END Check_Constraints;


  PROCEDURE Check_Uniqueness AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  BEGIN
    IF (Get_UK1_For_Validation (
          new_references.fee_type,
          new_references.fee_cal_type,
          new_references.fee_ci_sequence_number,
          new_references.rate_number,
          new_references.fee_cat
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
    IF (Get_UK2_For_Validation (
          new_references.fee_type,
          new_references.fee_cal_type,
          new_references.fee_ci_sequence_number,
          new_references.s_relation_type,
          new_references.rate_number,
          new_references.fee_cat
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Uniqueness;


  PROCEDURE Check_Child_Existance AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  svuppala        23-JUN-2005     Bug 3392088 Modifications as part of CPF build
  --------------------------------------------------------------------*/
  BEGIN
    igs_fi_elm_range_rt_pkg.get_ufk_igs_fi_fee_as_rate (
      new_references.fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.s_relation_type,
      new_references.rate_number,
      new_references.fee_cat
    );

    -- checking child
    igs_fi_sub_er_rt_pkg.get_fk_igs_fi_fee_as_rate (
      new_references.far_id
    );
  END Check_Child_Existance;


  PROCEDURE Check_UK_Child_Existance AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  BEGIN
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.s_relation_type = new_references.s_relation_type) AND
         (old_references.rate_number = new_references.rate_number) AND
         (old_references.fee_cat = new_references.fee_cat)) OR
        ((old_references.fee_type = Null) AND
         (old_references.fee_cal_type = Null) AND
         (old_references.fee_ci_sequence_number = Null) AND
         (old_references.s_relation_type = Null) AND
         (old_references.rate_number = Null) AND
         (old_references.fee_cat = Null))) THEN
      NULL;
    ELSE
      igs_fi_elm_range_rt_pkg.get_ufk_igs_fi_fee_as_rate(
        old_references.fee_type,
        old_references.fee_cal_type,
        old_references.fee_ci_sequence_number,
        old_references.s_relation_type,
        old_references.rate_number,
        old_references.fee_cat
      );
    END IF;
  END Check_UK_Child_Existance;


  PROCEDURE Check_Parent_Existance AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        17-Sep-2003     Enh 3108052 - Unit Sets in Rate Table build
  ||                                  Added call to igs_en_unit_set_pkg.get_pk_for_validation
  --------------------------------------------------------------------*/
    CURSOR cur1(p_party_id  IN NUMBER)  IS
      SELECT 'X'
      FROM   hz_parties         HP,
             igs_pe_hz_parties  PHP
      WHERE  HP.party_id = p_party_id
             AND    PHP.inst_org_ind = 'O'
             AND    HP.party_id = PHP.party_id;
  BEGIN
    IF (((old_references.attendance_mode = new_references.attendance_mode)) OR
        ((new_references.attendance_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_MODE_PKG.Get_PK_For_Validation (
               new_references.attendance_mode
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
               new_references.attendance_type
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
               new_references.fee_cat,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number,
               new_references.fee_type
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_TYP_CA_INST_PKG.Get_PK_For_Validation (
               new_references.fee_type,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.govt_hecs_cntrbtn_band = new_references.govt_hecs_cntrbtn_band)) OR
        ((new_references.govt_hecs_cntrbtn_band IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_GOVT_HEC_CNTB_PKG.Get_PK_For_Validation (
               new_references.govt_hecs_cntrbtn_band
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.govt_hecs_payment_option = new_references.govt_hecs_payment_option)) OR
        ((new_references.govt_hecs_payment_option IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_GOV_HEC_PA_OP_PKG.Get_PK_For_Validation (
               new_references.govt_hecs_payment_option
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
               new_references.location_cd ,
               'N'
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.residency_status_cd = new_references.residency_status_cd)) OR
        ((new_references.residency_status_cd  IS NULL)))  THEN
        NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
                'PE_RES_STATUS',new_references.residency_status_cd
                ) THEN
          Fnd_Message.Set_Name ('FND' , 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
               new_references.course_cd,
               new_references.version_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.org_party_id = new_references.org_party_id)  OR
         (new_references.org_party_id  IS NULL)))  THEN
         NULL;
    ELSE
      OPEN  cur1(new_references.org_party_id);
      IF (cur1%NOTFOUND) THEN
        CLOSE cur1;
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      CLOSE cur1;
    END IF;

    IF (((old_references.class_standing = new_references.class_standing) OR
        (new_references.class_standing IS NULL)))THEN
      NULL;
    ELSE
      IF NOT IGS_PR_CLASS_STD_PKG.Get_UK_For_Validation (
               new_references.class_standing
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.us_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_en_unit_set_pkg.get_pk_for_validation(
               new_references.unit_set_cd,
               new_references.us_version_number
               ) THEN
        fnd_message.set_name ('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;


  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_far_id NUMBER
    ) RETURN BOOLEAN AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    far_id = x_far_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
      Close cur_rowid;
      Return (FALSE);
    END IF;
  END Get_PK_For_Validation;


  FUNCTION Get_UK1_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_rate_number IN NUMBER,
    x_fee_cat IN VARCHAR2
  ) RETURN BOOLEAN AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      rate_number = x_rate_number
      AND      fee_cat = x_fee_cat
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
      Close cur_rowid;
      Return (FALSE);
    END IF;
  END Get_UK1_For_Validation;


  FUNCTION Get_UK2_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_rate_number IN NUMBER,
    x_fee_cat IN VARCHAR2
  ) RETURN BOOLEAN AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      s_relation_type = x_s_relation_type
      AND      rate_number = x_rate_number
      AND      (fee_cat = x_fee_cat or fee_cat is null)
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
      Close cur_rowid;
      Return (FALSE);
    END IF;
  END Get_UK2_For_Validation;


  PROCEDURE get_fk_igs_as_unit_mode (
         x_unit_mode IN VARCHAR2
         ) AS
   /*-------------------------------------------------------
  ||  Created By : svuppala
  ||  Created On : 01-JUN-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ------------------------------------------------------------
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_fee_as_rate
      WHERE   (unit_mode  = x_unit_mode);

    lv_rowid cur_rowid%RowType;

    BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FAR_UM_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_unit_mode;

  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    attendance_mode = x_attendance_mode ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAR_AM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_ATD_MODE;


  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    attendance_type = x_attendance_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAR_ATT_FK');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_ATD_TYPE;


  PROCEDURE GET_FK_IGS_FI_GOVT_HEC_CNTB (
    x_govt_hecs_cntrbtn_band IN NUMBER
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    govt_hecs_cntrbtn_band = x_govt_hecs_cntrbtn_band ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
       Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAR_GHC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_GOVT_HEC_CNTB;


  PROCEDURE GET_FK_IGS_FI_GOV_HEC_PA_OP (
    x_govt_hecs_payment_option IN VARCHAR2
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    govt_hecs_payment_option = x_govt_hecs_payment_option ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
          Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAR_GHPO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_GOV_HEC_PA_OP;


  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RATE
      WHERE    location_cd = x_location_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
         Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAR_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_LOCATION;


  PROCEDURE GET_FK_IGS_PS_VER(
    x_course_cd    IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR  cur_rowid IS
      SELECT rowid
      FROM  IGS_FI_FEE_AS_RATE
      WHERE  course_cd = x_course_cd
      AND    version_number = x_version_number;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO  lv_rowid;
    IF(cur_rowid%FOUND) THEN
      Close cur_rowid;
         Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAR_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_VER;


  PROCEDURE GET_UFK_IGS_PR_CLASS_STD(
    x_class_standing IN VARCHAR2
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    -- Modified cur_rowid to fetch records from igs_fi_fee_as_rate instead of fetching from
    -- IGS_PR_CLASS_STD. This has been done as per Bug# 2637262.
    CURSOR  cur_rowid IS
      SELECT rowid
      FROM IGS_FI_FEE_AS_RATE
      WHERE class_standing =  x_class_standing;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO  lv_rowid;
    IF(cur_rowid%FOUND) THEN
      Close cur_rowid;
         Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAR_PCS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_UFK_IGS_PR_CLASS_STD;


  PROCEDURE Before_DML (
    p_action                      IN VARCHAR2,
    x_rowid                       IN VARCHAR2 ,
    x_far_id                      IN NUMBER ,
    x_fee_type                    IN VARCHAR2 ,
    x_fee_cal_type                IN VARCHAR2 ,
    x_fee_ci_sequence_number      IN NUMBER ,
    x_s_relation_type             IN VARCHAR2 ,
    x_rate_number                 IN NUMBER ,
    x_fee_cat                     IN VARCHAR2 ,
    x_location_cd                 IN VARCHAR2 ,
    x_attendance_type             IN VARCHAR2 ,
    x_attendance_mode             IN VARCHAR2 ,
    x_order_of_precedence         IN NUMBER ,
    x_govt_hecs_payment_option    IN VARCHAR2 ,
    x_govt_hecs_cntrbtn_band      IN NUMBER ,
    x_chg_rate                    IN NUMBER ,
    x_logical_delete_dt           IN DATE ,
    x_residency_status_cd         IN VARCHAR2 ,
    x_course_cd                   IN VARCHAR2 ,
    x_version_number              IN NUMBER ,
    x_org_party_id                IN NUMBER ,
    x_class_standing              IN VARCHAR2 ,
    x_creation_date               IN DATE  ,
    x_created_by                  IN NUMBER  ,
    x_last_update_date            IN DATE  ,
    x_last_updated_by             IN NUMBER  ,
    x_last_update_login           IN NUMBER,
    x_unit_set_cd                 IN VARCHAR2,
    x_us_version_number           IN NUMBER,
    x_unit_cd                     IN VARCHAR2 ,
    x_unit_version_number         IN NUMBER   ,
    x_unit_level                  IN VARCHAR2 ,
    x_unit_type_id                IN NUMBER   ,
    x_unit_class                  IN VARCHAR2 ,
    x_unit_mode                   IN VARCHAR2
  ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  --------------------------------------------------------------------*/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_far_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_s_relation_type,
      x_rate_number,
      x_fee_cat,
      x_location_cd,
      x_attendance_type,
      x_attendance_mode,
      x_order_of_precedence,
      x_govt_hecs_payment_option,
      x_govt_hecs_cntrbtn_band,
      x_chg_rate,
      x_logical_delete_dt,
      x_residency_status_cd,
      x_course_cd,
      x_version_number,
      x_org_party_id,
      x_class_standing,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_unit_set_cd,
      x_us_version_number,
      x_unit_cd ,
      x_unit_version_number,
      x_unit_level,
      x_unit_type_id,
      x_unit_class,
      x_unit_mode

    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE ,p_updating => FALSE , p_deleting => FALSE );
      IF (Get_PK_For_Validation (
            new_references.far_id
            )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE , p_updating => TRUE ,p_deleting => FALSE);
      beforerowupdate;
      Check_Parent_Existance;
      Check_UK_Child_Existance;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE, p_updating => FALSE , p_deleting => TRUE );
      Check_Child_Existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.far_id
          )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
      Check_UK_Child_Existance;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;


  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterStmtInsertUpdate4 ( p_inserting => TRUE ,p_updating => FALSE , p_deleting => FALSE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate3 ( p_inserting => FALSE , p_updating => TRUE ,p_deleting => FALSE);
      AfterStmtInsertUpdate4 ( p_inserting => FALSE , p_updating => TRUE ,p_deleting => FALSE);
    END IF;
    l_rowid := NULL;
  END After_DML;


PROCEDURE insert_row (
  x_rowid                       IN OUT NOCOPY VARCHAR2,
  x_far_id                      IN OUT NOCOPY NUMBER,
  x_fee_type                    IN VARCHAR2,
  x_fee_cal_type                IN VARCHAR2,
  x_fee_ci_sequence_number      IN NUMBER,
  x_s_relation_type             IN VARCHAR2,
  x_rate_number                 IN NUMBER,
  x_fee_cat                     IN VARCHAR2,
  x_location_cd                 IN VARCHAR2,
  x_attendance_type             IN VARCHAR2,
  x_attendance_mode             IN VARCHAR2,
  x_order_of_precedence         IN NUMBER,
  x_govt_hecs_payment_option    IN VARCHAR2,
  x_govt_hecs_cntrbtn_band      IN NUMBER,
  x_chg_rate                    IN NUMBER,
  x_logical_delete_dt           IN DATE,
  x_residency_status_cd         IN VARCHAR2 ,
  x_course_cd                   IN VARCHAR2 ,
  x_version_number              IN NUMBER ,
  x_org_party_id                IN NUMBER ,
  x_class_standing              IN VARCHAR2 ,
  x_mode                        IN VARCHAR2,
  x_unit_set_cd                 IN VARCHAR2,
  x_us_version_number           IN NUMBER,
  x_unit_cd                     IN VARCHAR2 ,
  x_unit_version_number         IN NUMBER   ,
  x_unit_level                  IN VARCHAR2 ,
  x_unit_type_id                IN NUMBER   ,
  x_unit_class                  IN VARCHAR2 ,
  x_unit_mode                   IN VARCHAR2
  ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  --------------------------------------------------------------------*/
    CURSOR C (cp_range_id IN NUMBER) is select ROWID from IGS_FI_FEE_AS_RATE
      where far_id = cp_range_id;

    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;

BEGIN
   x_last_update_date := SYSDATE;
   IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
   ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.USER_ID;
      IF x_last_updated_by IS NULL THEN
         x_last_updated_by := -1;
      END IF;
      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
         x_last_update_login := -1;
      END IF;
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id = -1 ) THEN
          x_request_id := NULL;
          x_program_id := NULL;
          x_program_application_id := NULL;
          x_program_update_date := NULL;
      ELSE
          x_program_update_date:=SYSDATE;
      END IF;
   ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

  SELECT   igs_fi_fee_as_rate_far_id_s.nextval
  INTO     x_far_id
  FROM     dual;

Before_DML(
 p_action                    =>'INSERT',
 x_rowid                     => x_rowid,
 x_far_id                    => x_far_id,
 x_attendance_mode           => x_attendance_mode,
 x_attendance_type           => x_attendance_type,
 x_chg_rate                  => x_chg_rate,
 x_fee_cal_type              => x_fee_cal_type,
 x_fee_cat                   => x_fee_cat,
 x_fee_ci_sequence_number    => x_fee_ci_sequence_number,
 x_fee_type                  => x_fee_type,
 x_govt_hecs_cntrbtn_band    => x_govt_hecs_cntrbtn_band,
 x_govt_hecs_payment_option  => x_govt_hecs_payment_option,
 x_location_cd               => x_location_cd,
 x_logical_delete_dt         => x_logical_delete_dt,
 x_order_of_precedence       => x_order_of_precedence,
 x_rate_number               => x_rate_number,
 x_s_relation_type           => x_s_relation_type,
 x_residency_status_cd       => x_residency_status_cd,
 x_course_cd                 => x_course_cd,
 x_version_number            => x_version_number,
 x_org_party_id              => x_org_party_id,
 x_class_standing            => x_class_standing,
 x_creation_date             => x_last_update_date,
 x_created_by                => x_last_updated_by,
 x_last_update_date          => x_last_update_date,
 x_last_updated_by           => x_last_updated_by,
 x_last_update_login         => x_last_update_login,
 x_unit_set_cd               => x_unit_set_cd,
 x_us_version_number         => x_us_version_number,
 x_unit_cd                   => x_unit_cd,
 x_unit_version_number       => x_unit_version_number,
 x_unit_level                => x_unit_level ,
 x_unit_type_id              => x_unit_type_id,
 x_unit_class                => x_unit_class ,
 x_unit_mode                 => x_unit_mode
 );

  INSERT INTO igs_fi_fee_as_rate (
    far_id,
    fee_type,
    fee_cal_type,
    fee_ci_sequence_number,
    s_relation_type,
    rate_number,
    fee_cat,
    location_cd,
    attendance_type,
    attendance_mode,
    order_of_precedence,
    govt_hecs_payment_option,
    govt_hecs_cntrbtn_band,
    chg_rate,
    logical_delete_dt,
    residency_status_cd,
    course_cd,
    version_number,
    org_party_id,
    class_standing,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    request_id,
    program_id,
    program_application_id,
    program_update_date,
    unit_set_cd,
    us_version_number,
    unit_cd ,
    unit_version_number,
    unit_level  ,
    unit_type_id,
    unit_class  ,
    unit_mode
  ) VALUES (
    new_references.far_id,
    new_references.fee_type,
    new_references.fee_cal_type,
    new_references.fee_ci_sequence_number,
    new_references.s_relation_type,
    new_references.rate_number,
    new_references.fee_cat,
    new_references.location_cd,
    new_references.attendance_type,
    new_references.attendance_mode,
    new_references.order_of_precedence,
    new_references.govt_hecs_payment_option,
    new_references.govt_hecs_cntrbtn_band,
    new_references.chg_rate,
    new_references.logical_delete_dt,
    new_references.residency_status_cd,
    new_references.course_cd,
    new_references.version_number,
    new_references.org_party_id,
    new_references.class_standing,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    x_request_id,
    x_program_id,
    x_program_application_id,
    x_program_update_date,
    new_references.unit_set_cd,
    new_references.us_version_number,
    new_references.unit_cd,
    new_references.unit_version_number,
    new_references.unit_level ,
    new_references.unit_type_id ,
    new_references.unit_class,
    new_references.unit_mode
  );

  OPEN c (x_far_id);
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

  After_DML(
            p_action =>'INSERT',
            x_rowid => x_rowid
          );

END insert_row;


PROCEDURE lock_row (
  x_rowid                       IN VARCHAR2,
  x_far_id                      IN NUMBER,
  x_fee_type                    IN VARCHAR2,
  x_fee_cal_type                IN VARCHAR2,
  x_fee_ci_sequence_number      IN NUMBER,
  x_s_relation_type             IN VARCHAR2,
  x_rate_number                 IN NUMBER,
  x_fee_cat                     IN VARCHAR2,
  x_location_cd                 IN VARCHAR2,
  x_attendance_type             IN VARCHAR2,
  x_attendance_mode             IN VARCHAR2,
  x_order_of_precedence         IN NUMBER,
  x_govt_hecs_payment_option    IN VARCHAR2,
  x_govt_hecs_cntrbtn_band      IN NUMBER,
  x_chg_rate                    IN NUMBER,
  x_logical_delete_dt           IN DATE,
  x_residency_status_cd         IN VARCHAR2 ,
  x_course_cd                   IN VARCHAR2 ,
  x_version_number              IN NUMBER ,
  x_org_party_id                IN NUMBER ,
  x_class_standing              IN VARCHAR2,
  x_unit_set_cd                 IN VARCHAR2,
  x_us_version_number           IN NUMBER,
  x_unit_cd                     IN VARCHAR2 ,
  x_unit_version_number         IN NUMBER   ,
  x_unit_level                  IN VARCHAR2 ,
  x_unit_type_id                IN NUMBER   ,
  x_unit_class                  IN VARCHAR2 ,
  x_unit_mode                   IN VARCHAR2
) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  --------------------------------------------------------------------*/
  CURSOR c1 IS
  SELECT far_id,
         fee_cal_type,
         fee_ci_sequence_number,
         s_relation_type,
         rate_number,
         fee_cat,
         location_cd,
         attendance_type,
         attendance_mode,
         order_of_precedence,
         govt_hecs_payment_option,
         govt_hecs_cntrbtn_band,
         chg_rate,
         logical_delete_dt,
         residency_status_cd,
         course_cd,
         version_number,
         org_party_id,
         class_standing,
         unit_set_cd,
         us_version_number,
         unit_cd,
         unit_version_number,
         unit_level  ,
         unit_type_id ,
         unit_class ,
         unit_mode
   FROM igs_fi_fee_as_rate
   WHERE rowid = x_rowid
   FOR UPDATE NOWAIT;

  tlinfo c1%ROWTYPE;

BEGIN

  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
      CLOSE c1;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
  END IF;
  CLOSE c1;
  IF ( (tlinfo.fee_cal_type = x_fee_cal_type)
      AND (tlinfo.far_id = x_far_id)
      AND (tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number)
      AND (tlinfo.s_relation_type = x_s_relation_type)
      AND (tlinfo.rate_number = x_rate_number)
      AND ((tlinfo.fee_cat = x_fee_cat) OR ((tlinfo.fee_cat IS NULL) AND (x_fee_cat IS NULL)))
      AND ((tlinfo.location_cd = x_location_cd) OR ((tlinfo.LOCATION_CD is null) AND (x_location_cd IS NULL)))
      AND ((tlinfo.attendance_type = x_attendance_type) OR ((tlinfo.attendance_type IS NULL) AND (x_attendance_type IS NULL)))
      AND ((tlinfo.attendance_mode = x_attendance_mode) OR ((tlinfo.attendance_mode IS NULL) AND (x_attendance_mode IS NULL)))
      AND ((tlinfo.order_of_precedence = x_order_of_precedence) OR ((tlinfo.order_of_precedence IS NULL) AND (x_order_of_precedence IS NULL)))
      AND ((tlinfo.govt_hecs_payment_option = x_govt_hecs_payment_option) OR ((tlinfo.govt_hecs_payment_option IS NULL) AND (x_govt_hecs_payment_option IS NULL)))
      AND ((tlinfo.govt_hecs_cntrbtn_band = x_govt_hecs_cntrbtn_band) OR ((tlinfo.govt_hecs_cntrbtn_band IS NULL) AND (x_govt_hecs_cntrbtn_band IS NULL)))
      AND (tlinfo.chg_rate = x_chg_rate)
      AND ((tlinfo.logical_delete_dt = x_logical_delete_dt) OR ((tlinfo.logical_delete_dt IS NULL) AND (x_logical_delete_dt IS NULL)))
      AND ((tlinfo.residency_status_cd = x_residency_status_cd) OR ((tlinfo.residency_status_cd IS NULL) AND (x_residency_status_cd IS NULL)))
      AND ((tlinfo.course_cd = x_course_cd) OR ((tlinfo.course_cd IS NULL) AND (x_course_cd IS NULL)))
      AND ((tlinfo.version_number = x_version_number) OR ((tlinfo.version_number IS NULL) AND (x_version_number IS NULL)))
      AND ((tlinfo.org_party_id = x_org_party_id) OR ((tlinfo.org_party_id IS NULL)  AND (x_org_party_id IS NULL)))
      AND ((tlinfo.class_standing = x_class_standing) OR ((tlinfo.class_standing IS NULL) AND (x_class_standing IS NULL)))
      AND ((tlinfo.unit_set_cd = x_unit_set_cd) OR ((tlinfo.unit_set_cd IS NULL) AND (x_unit_set_cd IS NULL)))
      AND ((tlinfo.us_version_number = x_us_version_number) OR ((tlinfo.us_version_number IS NULL) AND (x_us_version_number IS NULL)))
      AND ((tlinfo.unit_cd = x_unit_cd) OR ((tlinfo.unit_cd IS NULL) AND (x_unit_cd IS NULL)))
      AND ((tlinfo.unit_version_number = x_unit_version_number) OR ((tlinfo.unit_version_number IS NULL) AND (x_unit_version_number IS NULL)))
      AND ((tlinfo.unit_level = x_unit_level) OR ((tlinfo.unit_level IS NULL)  AND (x_unit_level IS NULL)))
      AND ((tlinfo.unit_type_id = x_unit_type_id) OR ((tlinfo.unit_type_id IS NULL) AND (x_unit_type_id IS NULL)))
      AND ((tlinfo.unit_class = x_unit_class) OR ((tlinfo.unit_class IS NULL) AND (x_unit_class IS NULL)))
      AND ((tlinfo.unit_mode = x_unit_mode) OR ((tlinfo.unit_mode IS NULL) AND (x_unit_mode IS NULL)))
    ) THEN
      NULL;
  ELSE
     fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
  END IF;

  RETURN;

END lock_row;


PROCEDURE update_row (
  x_rowid                       IN VARCHAR2,
  x_far_id                      IN NUMBER,
  x_fee_type                    IN VARCHAR2,
  x_fee_cal_type                IN VARCHAR2,
  x_fee_ci_sequence_number      IN NUMBER,
  x_s_relation_type             IN VARCHAR2,
  x_rate_number                 IN NUMBER,
  x_fee_cat                     IN VARCHAR2,
  x_location_cd                 IN VARCHAR2,
  x_attendance_type             IN VARCHAR2,
  x_attendance_mode             IN VARCHAR2,
  x_order_of_precedence         IN NUMBER,
  x_govt_hecs_payment_option    IN VARCHAR2,
  x_govt_hecs_cntrbtn_band      IN NUMBER,
  x_chg_rate                    IN NUMBER,
  x_logical_delete_dt           IN DATE,
  x_residency_status_cd         IN VARCHAR2 ,
  x_course_cd                   IN VARCHAR2 ,
  x_version_number              IN NUMBER ,
  x_org_party_id                IN NUMBER  ,
  x_class_standing              IN VARCHAR2 ,
  x_mode                        IN VARCHAR2,
  x_unit_set_cd                 IN VARCHAR2,
  x_us_version_number           IN NUMBER,
  x_unit_cd                     IN VARCHAR2 ,
  x_unit_version_number         IN NUMBER   ,
  x_unit_level                  IN VARCHAR2 ,
  x_unit_type_id                IN NUMBER   ,
  x_unit_class                  IN VARCHAR2 ,
  x_unit_mode                   IN VARCHAR2
  ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  --------------------------------------------------------------------*/
    x_last_update_date       DATE;
    x_last_updated_by        NUMBER;
    x_last_update_login      NUMBER;
    x_request_id             NUMBER;
    x_program_id             NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date    DATE;

BEGIN

  x_last_update_date := SYSDATE;

  IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
  ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
         x_last_updated_by := -1;
      END IF;
      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
         x_last_update_login := -1;
      END IF;
      x_request_id                := fnd_global.conc_request_id;
      x_program_id                := fnd_global.conc_program_id;
      x_program_application_id    := fnd_global.prog_appl_id;
      IF (x_request_id = -1 ) THEN
          x_request_id              := old_references.request_id;
          x_program_id              := old_references.program_id;
          x_program_application_id  := old_references.program_application_id;
          x_program_update_date     := old_references.program_update_date;
      ELSE
          x_program_update_date := SYSDATE;
      END IF;
  ELSE
      fnd_message.set_name('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END IF;

  Before_DML(
   p_action                      => 'UPDATE',
   x_rowid                       => x_rowid,
   x_far_id                      => x_far_id,
   x_attendance_mode             => x_attendance_mode,
   x_attendance_type             => x_attendance_type,
   x_chg_rate                    => x_chg_rate,
   x_fee_cal_type                => x_fee_cal_type,
   x_fee_cat                     => x_fee_cat,
   x_fee_ci_sequence_number      => x_fee_ci_sequence_number,
   x_fee_type                    => x_fee_type,
   x_govt_hecs_cntrbtn_band      => x_govt_hecs_cntrbtn_band,
   x_govt_hecs_payment_option    => x_govt_hecs_payment_option,
   x_location_cd                 => x_location_cd,
   x_logical_delete_dt           => x_logical_delete_dt,
   x_order_of_precedence         => x_order_of_precedence,
   x_rate_number                 => x_rate_number,
   x_s_relation_type             => x_s_relation_type,
   x_residency_status_cd         => x_residency_status_cd,
   x_course_cd                   => x_course_cd,
   x_version_number              => x_version_number,
   x_org_party_id                => x_org_party_id,
   x_class_standing              => x_class_standing,
   x_creation_date               => x_last_update_date,
   x_created_by                  => x_last_updated_by,
   x_last_update_date            => x_last_update_date,
   x_last_updated_by             => x_last_updated_by,
   x_last_update_login           => x_last_update_login,
   x_unit_set_cd                 => x_unit_set_cd,
   x_us_version_number           => x_us_version_number,
   x_unit_cd                     => x_unit_cd,
   x_unit_version_number         => x_unit_version_number,
   x_unit_level                  => x_unit_level ,
   x_unit_type_id                => x_unit_type_id,
   x_unit_class                  => x_unit_class ,
   x_unit_mode                   => x_unit_mode
 );

  UPDATE igs_fi_fee_as_rate
  SET
    far_id                   = far_id,
    fee_cal_type             = new_references.fee_cal_type,
    fee_ci_sequence_number   = new_references.fee_ci_sequence_number,
    s_relation_type          = new_references.s_relation_type,
    rate_number              = new_references.rate_number,
    fee_cat                  = new_references.fee_cat,
    location_cd              = new_references.location_cd,
    attendance_type          = new_references.attendance_type,
    attendance_mode          = new_references.attendance_mode,
    order_of_precedence      = new_references.order_of_precedence,
    govt_hecs_payment_option = new_references.govt_hecs_payment_option,
    govt_hecs_cntrbtn_band   = new_references.govt_hecs_cntrbtn_band,
    chg_rate                 = new_references.chg_rate,
    logical_delete_dt        = new_references.logical_delete_dt,
    residency_status_cd      = new_references.residency_status_cd,
    course_cd                = new_references.course_cd,
    version_number           = new_references.version_number,
    org_party_id             = new_references.org_party_id,
    class_standing           = new_references.class_standing,
    last_update_date         = x_last_update_date,
    last_updated_by          = x_last_updated_by,
    last_update_login        = x_last_update_login,
    request_id               = x_request_id,
    program_id               = x_program_id,
    program_application_id   = x_program_application_id,
    program_update_date      = x_program_update_date,
    unit_set_cd              = new_references.unit_set_cd,
    us_version_number        = new_references.us_version_number,
    unit_cd                  = new_references.unit_cd,
    unit_version_number      = new_references.unit_version_number,
    unit_level               = new_references.unit_level ,
    unit_type_id             = new_references.unit_type_id,
    unit_class               = new_references.unit_class ,
    unit_mode                = new_references.unit_mode
  WHERE rowid = x_rowid ;

  IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
  END IF;

  after_dml(
            p_action =>'UPDATE',
            x_rowid => x_rowid
           );

END update_row;


PROCEDURE add_row (
  x_rowid                       IN OUT NOCOPY VARCHAR2,
  x_far_id                      IN OUT NOCOPY NUMBER,
  x_fee_type                    IN VARCHAR2,
  x_fee_cal_type                IN VARCHAR2,
  x_fee_ci_sequence_number      IN NUMBER,
  x_s_relation_type             IN VARCHAR2,
  x_rate_number                 IN NUMBER,
  x_fee_cat                     IN VARCHAR2,
  x_location_cd                 IN VARCHAR2,
  x_attendance_type             IN VARCHAR2,
  x_attendance_mode             IN VARCHAR2,
  x_order_of_precedence         IN NUMBER,
  x_govt_hecs_payment_option    IN VARCHAR2,
  x_govt_hecs_cntrbtn_band      IN NUMBER,
  x_chg_rate                    IN NUMBER,
  x_logical_delete_dt           IN DATE,
  x_residency_status_cd         IN VARCHAR2 ,
  x_course_cd                   IN VARCHAR2 ,
  x_version_number              IN NUMBER ,
  x_org_party_id                IN NUMBER ,
  x_class_standing              IN VARCHAR2 ,
  x_mode                        IN VARCHAR2 ,
  x_unit_set_cd                 IN VARCHAR2,
  x_us_version_number           IN NUMBER,
  x_unit_cd                     IN VARCHAR2 ,
  x_unit_version_number         IN NUMBER   ,
  x_unit_level                  IN VARCHAR2 ,
  x_unit_type_id                IN NUMBER   ,
  x_unit_class                  IN VARCHAR2 ,
  x_unit_mode                   IN VARCHAR2
  ) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  --------------------------------------------------------------------*/
  CURSOR c1 IS
    SELECT rowid
    FROM igs_fi_fee_as_rate
    WHERE far_id = x_far_id ;
BEGIN
  OPEN c1;
  FETCH c1 INTO x_rowid;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    insert_row (
     x_rowid,
     x_far_id,
     x_fee_type,
     x_fee_cal_type,
     x_fee_ci_sequence_number,
     x_s_relation_type,
     x_rate_number,
     x_fee_cat,
     x_location_cd,
     x_attendance_type,
     x_attendance_mode,
     x_order_of_precedence,
     x_govt_hecs_payment_option,
     x_govt_hecs_cntrbtn_band,
     x_chg_rate,
     x_logical_delete_dt,
     x_residency_status_cd,
     x_course_cd,
     x_version_number,
     x_org_party_id,
     x_class_standing,
     x_mode,
     x_unit_set_cd,
     x_us_version_number,
     x_unit_cd,
     x_unit_version_number,
     x_unit_level,
     x_unit_type_id,
     x_unit_class,
     x_unit_mode
     );
    RETURN;
  END IF;
  CLOSE c1;

  update_row (
   x_rowid,
   x_far_id,
   x_fee_type,
   x_fee_cal_type,
   x_fee_ci_sequence_number,
   x_s_relation_type,
   x_rate_number,
   x_fee_cat,
   x_location_cd,
   x_attendance_type,
   x_attendance_mode,
   x_order_of_precedence,
   x_govt_hecs_payment_option,
   x_govt_hecs_cntrbtn_band,
   x_chg_rate,
   x_logical_delete_dt,
   x_residency_status_cd,
   x_course_cd,
   x_version_number,
   x_org_party_id,
   x_class_standing,
   x_mode,
   x_unit_set_cd,
   x_us_version_number,
   x_unit_cd,
   x_unit_version_number,
   x_unit_level,
   x_unit_type_id,
   x_unit_class,
   x_unit_mode
   );
END add_row;


PROCEDURE delete_row (
  x_rowid IN VARCHAR2
) AS
   /*-----------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
BEGIN
   Before_DML( p_action =>'DELETE',
               x_rowid => X_ROWID
             );
  DELETE FROM igs_fi_fee_as_rate
  WHERE rowid = x_rowid;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;


PROCEDURE beforerowupdate AS
 /*----------------------------------------------------------------------------
  ||  Created By : vchappid
  ||  Created On : 02-Jul-2002
  ||  Purpose : Will not allow any updation of attributes when the logical delete date is set.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 ----------------------------------------------------------------------------*/
BEGIN
  -- Bug#2409567, Will not allow any updation of attributes when the logical delete date is set.
  IF old_references.logical_delete_dt IS NOT NULL THEN
    fnd_message.set_name('IGS','IGS_FI_LOG_DEL_UPD_NOT_ALLOWED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
END beforerowupdate;

PROCEDURE get_fk_igs_en_unit_set_all(
    x_unit_set_cd         IN VARCHAR2,
    x_us_version_number   IN NUMBER
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By : Priya Athipatla
  ||  Created On : 17-Sep-2003
  ||  Purpose : To validate FK with igs_en_unit_set_all
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR  cur_rowid IS
      SELECT rowid
      FROM   igs_fi_fee_as_rate
      WHERE  unit_set_cd = x_unit_set_cd
      AND    us_version_number = x_us_version_number;

    lv_rowid    cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO  lv_rowid;
    IF(cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name('IGS', 'IGS_FI_FAR_EUS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_en_unit_set_all;

END igs_fi_fee_as_rate_pkg;

/
