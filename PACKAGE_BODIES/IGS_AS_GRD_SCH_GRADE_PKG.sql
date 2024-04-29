--------------------------------------------------------
--  DDL for Package Body IGS_AS_GRD_SCH_GRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GRD_SCH_GRADE_PKG" AS
 /* $Header: IGSDI21B.pls 120.0 2005/07/05 11:28:46 appldev noship $ */
 l_rowid VARCHAR2(25);
  old_references IGS_AS_GRD_SCH_GRADE%RowType;
  new_references IGS_AS_GRD_SCH_GRADE%RowType;
PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dflt_outstanding_ind IN VARCHAR2 DEFAULT NULL,
    x_external_grade IN VARCHAR2 DEFAULT NULL,
    x_lower_mark_range IN NUMBER DEFAULT NULL,
    x_upper_mark_range IN NUMBER DEFAULT NULL,
    x_min_percentage IN NUMBER DEFAULT NULL,
    x_max_percentage IN NUMBER DEFAULT NULL,
    x_gpa_val IN NUMBER DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_s_special_grade_type IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_full_grade_name IN VARCHAR2 DEFAULT NULL,
    x_s_result_type IN VARCHAR2 DEFAULT NULL,
    x_show_on_noticeboard_ind IN VARCHAR2 DEFAULT NULL,
    x_show_on_official_ntfctn_ind IN VARCHAR2 DEFAULT NULL,
    x_show_in_newspaper_ind IN VARCHAR2 DEFAULT NULL,
    x_show_internally_ind IN VARCHAR2 DEFAULT NULL,
    x_system_only_ind IN VARCHAR2 DEFAULT NULL,
    x_show_in_earned_crdt_ind IN VARCHAR2 DEFAULT NULL,
    x_incl_in_repeat_process_ind IN VARCHAR2 DEFAULT NULL,
    x_admin_only_ind IN VARCHAR2 DEFAULT NULL,
    x_grading_period_cd IN VARCHAR2 DEFAULT NULL,
    x_repeat_grade IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_closed_ind        IN VARCHAR2 DEFAULT 'N'
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_GRD_SCH_GRADE
      WHERE    rowid = x_rowid;

  BEGIN
    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.

    Open cur_old_ref_values;

    Fetch cur_old_ref_values INTO old_references;

    IF (cur_old_ref_values%NOTFOUND) AND (p_action  NOT IN ('INSERT','VALIDATE_INSERT')) THEN

      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	        Close cur_old_ref_values;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.dflt_outstanding_ind := x_dflt_outstanding_ind;
    new_references.external_grade := x_external_grade;
    new_references.lower_mark_range := x_lower_mark_range;
    new_references.upper_mark_range := x_upper_mark_range;
    new_references.min_percentage := x_min_percentage;
    new_references.max_percentage := x_max_percentage;
    new_references.gpa_val := x_gpa_val;
    new_references.rank := x_rank;
    new_references.s_special_grade_type := x_s_special_grade_type;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.version_number := x_version_number;
    new_references.grade := x_grade;
    new_references.full_grade_name := x_full_grade_name;
    new_references.s_result_type := x_s_result_type;
    new_references.show_on_noticeboard_ind := x_show_on_noticeboard_ind;
    new_references.show_on_official_ntfctn_ind := x_show_on_official_ntfctn_ind;
    new_references.show_in_newspaper_ind := x_show_in_newspaper_ind;
    new_references.show_internally_ind := x_show_internally_ind;
    new_references.system_only_ind := x_system_only_ind;
    new_references.show_in_earned_crdt_ind := x_show_in_earned_crdt_ind ;
    new_references.incl_in_repeat_process_ind := x_incl_in_repeat_process_ind ;
    new_references.admin_only_ind := x_admin_only_ind ;
    new_references.grading_period_cd := x_grading_period_cd ;
    new_references.repeat_grade := x_repeat_grade ;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.closed_ind  := x_closed_ind;

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
  END Set_Column_Values;

PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
        v_message_name          VARCHAR2(30);

/*========================================================================================================+
 |
 | DESCRIPTION
 |
 |
 | NOTES
 |
 |
 | HISTORY
 | Who                  When                    Why
 | Aiyer                09-Jan-2003             Modified for the fix of the bug #2693772
 |                                              Modified the validation to check whether grade translations already existed
 |						only if old s_result_type and new s_result_type did not match.
 *===========================================================================================================*/
  BEGIN
        -- Validate that inserts/updates are allowed
        IF  p_inserting OR p_updating THEN
                -- Validate if grade's grading schema is current or future
                IF p_inserting OR p_updating THEN
                        IF  IGS_AS_VAL_GSG.assp_val_gs_cur_fut (
                                                        new_references.grading_schema_cd,
                                                        new_references.version_number,
                                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                -- Validate upper mark range >= lower mark range and both set if one is set
                IF p_inserting OR p_updating THEN
                        IF  IGS_AS_VAL_GSG.assp_val_gsg_mrk_rng (
                                                        new_references.lower_mark_range,
                                                        new_references.upper_mark_range,
                                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                -- Validate max percentage >= min percentage
                IF p_inserting OR p_updating THEN
                        IF  IGS_AS_VAL_GSG.assp_val_gsg_min_max (
                                                        new_references.min_percentage,
                                                        new_references.max_percentage,
                                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;

                -- Validate result type can not be changed when translations exist for the
                -- grade
                /*
                   Code modified for the bug #2693772
                   Modified the validation to check whether grade translations already existed
                   only if old s_result_type and new s_result_type did not match.
                */

                IF (p_inserting OR p_updating)   AND
                   new_references.s_result_type  <> old_references.s_result_type
                THEN

                        IF  IGS_AS_VAL_GSG.assp_val_gsg_gsgt (
                                                        new_references.grading_schema_cd,
                                                        new_references.version_number,
                                                        new_references.grade,
                                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;

                -- Validate if s_special_grade_type is 'CONCEDED-PASS' then
                -- s_result_type must be 'PASS'
                IF IGS_AS_VAL_GSG.assp_val_gsg_ssgt (
                                        new_references.s_special_grade_type,
                                        new_references.s_result_type,
                                        v_message_name) = FALSE THEN
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;
  END BeforeRowInsertUpdate1;
PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
      v_message_name    VARCHAR2(30);
  BEGIN
        IF  p_inserting OR p_updating THEN
            IF IGS_AS_VAL_GSG.assp_val_gsg_m_ovrlp (
                                        new_references.grading_schema_cd,
                                        new_references.version_number,
                                        new_references.grade,
                                        new_references.lower_mark_range,
                                        new_references.upper_mark_range,
                                        v_message_name) = FALSE THEN
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
  		-- Validate dflt outstanding indicator only set for 1 grade
  		IF  new_references.dflt_outstanding_ind = 'Y' THEN
  		    IF  IGS_AS_VAL_GSG.assp_val_gsg_dflt (
  					new_references.grading_schema_cd,
  					new_references.version_number,
  					new_references.grade,
  					v_message_name) = FALSE THEN
  			FND_MESSAGE.SET_NAME('IGS',v_message_name);
  			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
  		    END IF;
  		END IF;
      END IF;
  END AfterRowInsertUpdate2;

 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 ) as

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'GPA_VAL ' THEN
        new_references.gpa_val  := igs_ge_number.to_num(column_value);
    ELSIF  UPPER(column_name) = 'MAX_PERCENTAGE ' THEN
        new_references.max_percentage  := igs_ge_number.to_num(column_value);
    ELSIF  UPPER(column_name) = 'MIN_PERCENTAGE' THEN
        new_references.min_percentage := igs_ge_number.to_num(column_value);
    ELSIF  UPPER(column_name) = 'S_RESULT_TYPE' THEN
        new_references.s_result_type := column_value;
    ELSIF  UPPER(column_name) = 'GRADING_SCHEMA_CD' THEN
        new_references.grading_schema_cd := column_value;
    ELSIF  UPPER(column_name) = 'GRADE' THEN
        new_references.grade := column_value;
    ELSIF  UPPER(column_name) = 'FULL_GRADE_NAME' THEN
        new_references.full_grade_name := column_value;
    ELSIF  UPPER(column_name) = 'EXTERNAL_GRADE' THEN
        new_references.external_grade := column_value;
    ELSIF  UPPER(column_name) = 'VERSION_NUMBER ' THEN
        new_references.version_number  := igs_ge_number.to_num(column_value);
    ELSIF  UPPER(column_name) = 'SHOW_ON_NOTICEBOARD_IND ' THEN
        new_references.show_on_noticeboard_ind  := column_value;
    ELSIF  UPPER(column_name) = 'SHOW_ON_OFFICIAL_NTFCTN_IND ' THEN
        new_references.show_on_official_ntfctn_ind  := column_value;
    ELSIF  UPPER(column_name) = 'SHOW_IN_NEWSPAPER_IND ' THEN
        new_references.show_in_newspaper_ind  := column_value;
    ELSIF  UPPER(column_name) = 'SHOW_INTERNALLY_IND ' THEN
        new_references.show_internally_ind  := column_value;
    ELSIF  UPPER(column_name) = 'SYSTEM_ONLY_IND' THEN
        new_references.system_only_ind := column_value;
    ELSIF  UPPER(column_name) = 'DFLT_OUTSTANDING_IND' THEN
        new_references.dflt_outstanding_ind := column_value;
    ELSIF  UPPER(column_name) = 'LOWER_MARK_RANGE ' THEN
        new_references.lower_mark_range  := igs_ge_number.to_num(column_value);
    ELSIF  UPPER(column_name) = 'UPPER_MARK_RANGE ' THEN
        new_references.upper_mark_range  := igs_ge_number.to_num(column_value);
    ELSIF  UPPER(column_name) = 'S_SPECIAL_GRADE_TYPE ' THEN
        new_references.s_special_grade_type  := column_value;

    ELSIF  UPPER(column_name) = 'SHOW_IN_EARNED_CRDT_IND' THEN
        new_references.show_in_earned_crdt_ind  := column_value;
    ELSIF  UPPER(column_name) = 'INCL_IN_REPEAT_PROCESS_IND' THEN
        new_references.incl_in_repeat_process_ind  := column_value;
    ELSIF  UPPER(column_name) = 'ADMIN_ONLY_IND ' THEN
        new_references.admin_only_ind  := column_value;
    ELSIF  UPPER(column_name) = 'GRADING_PERIOD_CD' THEN
        new_references.grading_period_cd  := column_value;
    ELSIF  UPPER(column_name) = 'REPEAT_GRADE' THEN
        new_references.repeat_grade  := column_value;

    END IF;

    IF ((UPPER (column_name) = 'S_SPECIAL_GRADE_TYPE ') OR (column_name IS NULL)) THEN
      IF new_references.s_special_grade_type NOT IN ( 'SUPP-EXAM' , 'SPECIAL-EXAM' , 'REPLACEABLE' , 'CONCEDED-PASS' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'DFLT_OUTSTANDING_IND') OR (column_name IS NULL)) THEN
      IF new_references.dflt_outstanding_ind NOT IN  ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'SYSTEM_ONLY_IND') OR (column_name IS NULL)) THEN
      IF new_references.system_only_ind NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'SHOW_INTERNALLY_IND ') OR (column_name IS NULL)) THEN
      IF new_references.show_internally_ind NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'SHOW_IN_NEWSPAPER_IND ') OR (column_name IS NULL)) THEN
      IF new_references.show_in_newspaper_ind  NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'SHOW_ON_OFFICIAL_NTFCTN_IND ') OR (column_name IS NULL)) THEN
      IF new_references.show_on_official_ntfctn_ind  NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'SHOW_ON_NOTICEBOARD_IND ') OR (column_name IS NULL)) THEN
      IF new_references.show_on_noticeboard_ind  NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'VERSION_NUMBER ') OR (column_name IS NULL)) THEN
      IF new_references.version_number  < 0  OR
         new_references.version_number  > 999 THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'EXTERNAL_GRADE') OR (column_name IS NULL)) THEN
      IF (new_references.external_grade <> UPPER (new_references.external_grade)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'GRADE') OR (column_name IS NULL)) THEN
      IF (new_references.grade <> UPPER (new_references.grade)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'GRADING_SCHEMA_CD') OR (column_name IS NULL)) THEN
      IF (new_references.grading_schema_cd <> UPPER (new_references.grading_schema_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


    IF ((UPPER (column_name) = 'S_RESULT_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.s_result_type <> UPPER (new_references.s_result_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


    IF ((UPPER (column_name) = 'MIN_PERCENTAGE') OR (column_name IS NULL)) THEN
      IF new_references.min_percentage < 0 OR
	    new_references.min_percentage > 100 THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'MAX_PERCENTAGE ') OR (column_name IS NULL)) THEN
      IF new_references.max_percentage   < 0 OR
      	new_references.max_percentage   > 100	 THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'GPA_VAL ') OR (column_name IS NULL)) THEN
      IF new_references.gpa_val  < 0 OR
         new_references.gpa_val  > 999.99  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


  END Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AS_GRD_SCHEMA_PKG.Get_PK_For_Validation (
        new_references.grading_schema_cd,
        new_references.version_number
        ) THEN

	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     APP_EXCEPTION.RAISE_EXCEPTION;

       END IF;
    END IF;
   -- Has to be changed.
    IF (((old_references.s_result_type = new_references.s_result_type)) OR
        ((new_references.s_result_type IS NULL))) THEN
      NULL;
ELSIF NOT  IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
        'RESULT_TYPE',
        new_references.s_result_type
        ) THEN

	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	     APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END Check_Parent_Existance;
  PROCEDURE Check_Child_Existance AS
  --who                  when                   what
  --smadathi          29-MAY-2001          The foreign key references to IGS_PS_UNT_REPT_FMLY , IGS_PS_UNT_PRV_GRADE removed as per DLD
  --smadathi          25-MAY-2001          The foreign key references to IGS_PS_USEC_PRV_GRAD removed as per DLD
  --pkpatel           04-SEP-2001          Bug no. 1960126  Dld Academic Record Maintenance
  --                                       Added igs_av_stnd_unit_pkg.get_fk_igs_as_grd_sch_grade
  BEGIN
    IGS_AD_ADM_UT_STA_GD_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );
    IGS_AS_INS_GRD_ENTRY_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );
    IGS_AS_GRD_SCH_TRN_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );
    IGS_AS_GRD_SCH_TRN_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );
    IGS_AS_NON_ENR_STDOT_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );
    IGS_AS_SU_STMPTOUT_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );
    IGS_AS_SU_STMPTOUT_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );

    IGS_AS_INC_GRD_CPROF_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );

    IGS_AV_STND_UNIT_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number,
      old_references.grade
      );
-- Added by DDEY as a part of Bug# 2162831
IGS_AS_SU_ATMPT_ITM_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
     old_references.grading_schema_cd ,
     old_references.version_number ,
     old_references.grade
    );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_GRD_SCH_GRADE
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      version_number = x_version_number
      AND      grade = x_grade;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return(TRUE);
    ELSE
       Close cur_rowid;
       Return(FALSE);
    END IF;

    Close cur_rowid;
  END Get_PK_For_Validation;
  PROCEDURE GET_FK_IGS_AS_GRD_SCHEMA (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_GRD_SCH_GRADE
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      version_number = x_version_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_GSG_GS_FK');
      IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_GRD_SCHEMA;
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_result_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_GRD_SCH_GRADE
      WHERE    s_result_type = x_s_result_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_GSG_SLV_FK');
      IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_dflt_outstanding_ind IN VARCHAR2 DEFAULT NULL,
    x_external_grade IN VARCHAR2 DEFAULT NULL,
    x_lower_mark_range IN NUMBER DEFAULT NULL,
    x_upper_mark_range IN NUMBER DEFAULT NULL,
    x_min_percentage IN NUMBER DEFAULT NULL,
    x_max_percentage IN NUMBER DEFAULT NULL,
    x_gpa_val IN NUMBER DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_s_special_grade_type IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_full_grade_name IN VARCHAR2 DEFAULT NULL,
    x_s_result_type IN VARCHAR2 DEFAULT NULL,
    x_show_on_noticeboard_ind IN VARCHAR2 DEFAULT NULL,
    x_show_on_official_ntfctn_ind IN VARCHAR2 DEFAULT NULL,
    x_show_in_newspaper_ind IN VARCHAR2 DEFAULT NULL,
    x_show_internally_ind IN VARCHAR2 DEFAULT NULL,
    x_system_only_ind IN VARCHAR2 DEFAULT NULL,
    x_show_in_earned_crdt_ind IN VARCHAR2 DEFAULT NULL,
    x_incl_in_repeat_process_ind IN VARCHAR2 DEFAULT NULL,
    x_admin_only_ind IN VARCHAR2 DEFAULT NULL,
    x_grading_period_cd IN VARCHAR2 DEFAULT NULL,
    x_repeat_grade IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_dflt_outstanding_ind,
      x_external_grade,
      x_lower_mark_range,
      x_upper_mark_range,
      x_min_percentage,
      x_max_percentage,
      x_gpa_val,
      x_rank,
      x_s_special_grade_type,
      x_grading_schema_cd,
      x_version_number,
      x_grade,
      x_full_grade_name,
      x_s_result_type,
      x_show_on_noticeboard_ind,
      x_show_on_official_ntfctn_ind,
      x_show_in_newspaper_ind,
      x_show_internally_ind,
      x_system_only_ind,
      x_show_in_earned_crdt_ind,
      x_incl_in_repeat_process_ind,
      x_admin_only_ind,
      x_grading_period_cd,
      x_repeat_grade,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_closed_ind
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation(
		 new_references.grading_schema_cd,
 		 new_references.version_number,
             new_references.grade
	                            ) THEN

 		Fnd_message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
 		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.

      Check_Child_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
				 new_references.grading_schema_cd,
   			 	 new_references.version_number,
            	 	 new_references.grade
				 ) THEN
		          Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		          IGS_GE_MSG_STACK.ADD;
		          APP_EXCEPTION.RAISE_EXCEPTION;
     	        END IF;
      	Check_Constraints;
 	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      	  Check_Constraints;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
              Check_Child_Existance;
    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );

    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_FULL_GRADE_NAME in VARCHAR2,
  X_S_RESULT_TYPE in VARCHAR2,
  X_SHOW_ON_NOTICEBOARD_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_S_SPECIAL_GRADE_TYPE in VARCHAR2,
  X_SHOW_IN_NEWSPAPER_IND in VARCHAR2,
  X_SHOW_INTERNALLY_IND in VARCHAR2,
  X_SYSTEM_ONLY_IND in VARCHAR2,
  X_DFLT_OUTSTANDING_IND in VARCHAR2,
  X_EXTERNAL_GRADE in VARCHAR2,
  X_LOWER_MARK_RANGE in NUMBER,
  X_UPPER_MARK_RANGE in NUMBER,
  X_MIN_PERCENTAGE in NUMBER,
  X_MAX_PERCENTAGE in NUMBER,
  X_GPA_VAL in NUMBER,
  X_RANK in NUMBER,
  X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2,
  X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2,
  X_ADMIN_ONLY_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2,
  X_REPEAT_GRADE in VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_closed_ind IN VARCHAR2 default 'N'
  ) AS
    cursor C is select ROWID from IGS_AS_GRD_SCH_GRADE
      where GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and GRADE = X_GRADE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_dflt_outstanding_ind=> NVL(X_DFLT_OUTSTANDING_IND,'N'),
 x_external_grade=>X_EXTERNAL_GRADE,
 x_full_grade_name=>X_FULL_GRADE_NAME,
 x_gpa_val=>X_GPA_VAL,
 x_grade=>X_GRADE,
 x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
 x_lower_mark_range=>X_LOWER_MARK_RANGE,
 x_max_percentage=>X_MAX_PERCENTAGE,
 x_min_percentage=>X_MIN_PERCENTAGE,
 x_rank=>X_RANK,
 x_s_result_type=>X_S_RESULT_TYPE,
 x_s_special_grade_type=>X_S_SPECIAL_GRADE_TYPE,
 x_show_in_newspaper_ind=> NVL(X_SHOW_IN_NEWSPAPER_IND,'Y'),
 x_show_internally_ind=> NVL(X_SHOW_INTERNALLY_IND,'Y'),
 x_show_on_noticeboard_ind=> NVL(X_SHOW_ON_NOTICEBOARD_IND,'Y'),
 x_show_on_official_ntfctn_ind=> NVL(X_SHOW_ON_OFFICIAL_NTFCTN_IND,'Y'),
 x_system_only_ind=> NVL(X_SYSTEM_ONLY_IND,'N'),
 x_upper_mark_range=>X_UPPER_MARK_RANGE,
 x_version_number=>X_VERSION_NUMBER,
  x_show_in_earned_crdt_ind => X_SHOW_IN_EARNED_CRDT_IND ,
  x_incl_in_repeat_process_ind => X_SHOW_IN_EARNED_CRDT_IND ,
  x_admin_only_ind => X_ADMIN_ONLY_IND ,
  x_grading_period_cd => X_GRADING_PERIOD_CD ,
  x_repeat_grade => X_REPEAT_GRADE ,
      x_attribute_category=>x_attribute_category,
      x_attribute1=>x_attribute1,
      x_attribute2=>x_attribute2,
      x_attribute3=>x_attribute3,
      x_attribute4=>x_attribute4,
      x_attribute5=>x_attribute5,
      x_attribute6=>x_attribute6,
      x_attribute7=>x_attribute7,
      x_attribute8=>x_attribute8,
      x_attribute9=>x_attribute9,
      x_attribute10=>x_attribute10,
      x_attribute11=>x_attribute11,
      x_attribute12=>x_attribute12,
      x_attribute13=>x_attribute13,
      x_attribute14=>x_attribute14,
      x_attribute15=>x_attribute15,
      x_attribute16=>x_attribute16,
      x_attribute17=>x_attribute17,
      x_attribute18=>x_attribute18,
      x_attribute19=>x_attribute19,
      x_attribute20=>x_attribute20,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_closed_ind => x_closed_ind
);
  insert into IGS_AS_GRD_SCH_GRADE (
    GRADING_SCHEMA_CD,
    VERSION_NUMBER,
    GRADE,
    FULL_GRADE_NAME,
    S_RESULT_TYPE,
    SHOW_ON_NOTICEBOARD_IND,
    SHOW_ON_OFFICIAL_NTFCTN_IND,
    S_SPECIAL_GRADE_TYPE,
    SHOW_IN_NEWSPAPER_IND,
    SHOW_INTERNALLY_IND,
    SYSTEM_ONLY_IND,
    DFLT_OUTSTANDING_IND,
    EXTERNAL_GRADE,
    LOWER_MARK_RANGE,
    UPPER_MARK_RANGE,
    MIN_PERCENTAGE,
    MAX_PERCENTAGE,
    GPA_VAL,
    RANK,
    SHOW_IN_EARNED_CRDT_IND,
    INCL_IN_REPEAT_PROCESS_IND,
    ADMIN_ONLY_IND,
    GRADING_PERIOD_CD,
    REPEAT_GRADE,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CLOSED_IND
  ) values (
    NEW_REFERENCES.GRADING_SCHEMA_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.GRADE,
    NEW_REFERENCES.FULL_GRADE_NAME,
    NEW_REFERENCES.S_RESULT_TYPE,
    NEW_REFERENCES.SHOW_ON_NOTICEBOARD_IND,
    NEW_REFERENCES.SHOW_ON_OFFICIAL_NTFCTN_IND,
    NEW_REFERENCES.S_SPECIAL_GRADE_TYPE,
    NEW_REFERENCES.SHOW_IN_NEWSPAPER_IND,
    NEW_REFERENCES.SHOW_INTERNALLY_IND,
    NEW_REFERENCES.SYSTEM_ONLY_IND,
    NEW_REFERENCES.DFLT_OUTSTANDING_IND,
    NEW_REFERENCES.EXTERNAL_GRADE,
    NEW_REFERENCES.LOWER_MARK_RANGE,
    NEW_REFERENCES.UPPER_MARK_RANGE,
    NEW_REFERENCES.MIN_PERCENTAGE,
    NEW_REFERENCES.MAX_PERCENTAGE,
    NEW_REFERENCES.GPA_VAL,
    NEW_REFERENCES.RANK,
    NEW_REFERENCES.SHOW_IN_EARNED_CRDT_IND,
    NEW_REFERENCES.INCL_IN_REPEAT_PROCESS_IND,
    NEW_REFERENCES.ADMIN_ONLY_IND,
    NEW_REFERENCES.GRADING_PERIOD_CD,
    NEW_REFERENCES.REPEAT_GRADE,
    new_references.attribute_category,
    new_references.attribute1,
    new_references.attribute2,
    new_references.attribute3,
    new_references.attribute4,
    new_references.attribute5,
    new_references.attribute6,
    new_references.attribute7,
    new_references.attribute8,
    new_references.attribute9,
    new_references.attribute10,
    new_references.attribute11,
    new_references.attribute12,
    new_references.attribute13,
    new_references.attribute14,
    new_references.attribute15,
    new_references.attribute16,
    new_references.attribute17,
    new_references.attribute18,
    new_references.attribute19,
    new_references.attribute20,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    new_references.closed_ind
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_FULL_GRADE_NAME in VARCHAR2,
  X_S_RESULT_TYPE in VARCHAR2,
  X_SHOW_ON_NOTICEBOARD_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_S_SPECIAL_GRADE_TYPE in VARCHAR2,
  X_SHOW_IN_NEWSPAPER_IND in VARCHAR2,
  X_SHOW_INTERNALLY_IND in VARCHAR2,
  X_SYSTEM_ONLY_IND in VARCHAR2,
  X_DFLT_OUTSTANDING_IND in VARCHAR2,
  X_EXTERNAL_GRADE in VARCHAR2,
  X_LOWER_MARK_RANGE in NUMBER,
  X_UPPER_MARK_RANGE in NUMBER,
  X_MIN_PERCENTAGE in NUMBER,
  X_MAX_PERCENTAGE in NUMBER,
  X_GPA_VAL in NUMBER,
  X_RANK in NUMBER,
  X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2,
  X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2,
  X_ADMIN_ONLY_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2,
  X_REPEAT_GRADE in VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  x_closed_ind IN VARCHAR2 default 'N'
  ) AS
  cursor c1 is select
      FULL_GRADE_NAME,
      S_RESULT_TYPE,
      SHOW_ON_NOTICEBOARD_IND,
      SHOW_ON_OFFICIAL_NTFCTN_IND,
      S_SPECIAL_GRADE_TYPE,
      SHOW_IN_NEWSPAPER_IND,
      SHOW_INTERNALLY_IND,
      SYSTEM_ONLY_IND,
      DFLT_OUTSTANDING_IND,
      EXTERNAL_GRADE,
      LOWER_MARK_RANGE,
      UPPER_MARK_RANGE,
      MIN_PERCENTAGE,
      MAX_PERCENTAGE,
      GPA_VAL,
      RANK,
      SHOW_IN_EARNED_CRDT_IND,
      INCL_IN_REPEAT_PROCESS_IND,
      ADMIN_ONLY_IND,
      GRADING_PERIOD_CD,
      REPEAT_GRADE,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      closed_ind
    from IGS_AS_GRD_SCH_GRADE
    where ROWID = X_ROWID  for update  nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.FULL_GRADE_NAME = X_FULL_GRADE_NAME)
      AND (tlinfo.S_RESULT_TYPE = X_S_RESULT_TYPE)
      AND (tlinfo.SHOW_ON_NOTICEBOARD_IND = X_SHOW_ON_NOTICEBOARD_IND)
      AND (tlinfo.SHOW_ON_OFFICIAL_NTFCTN_IND = X_SHOW_ON_OFFICIAL_NTFCTN_IND)
      AND ((tlinfo.S_SPECIAL_GRADE_TYPE = X_S_SPECIAL_GRADE_TYPE) OR ((tlinfo.S_SPECIAL_GRADE_TYPE is null) AND (X_S_SPECIAL_GRADE_TYPE is null)))
      AND ((tlinfo.SHOW_IN_NEWSPAPER_IND = X_SHOW_IN_NEWSPAPER_IND)  or (( tlinfo.SHOW_IN_NEWSPAPER_IND is null ) AND ( X_SHOW_IN_NEWSPAPER_IND is null )))
      AND ((tlinfo.SHOW_INTERNALLY_IND = X_SHOW_INTERNALLY_IND)  or (( tlinfo.SHOW_INTERNALLY_IND is null ) AND ( X_SHOW_INTERNALLY_IND is null )))
      AND ((tlinfo.SYSTEM_ONLY_IND = X_SYSTEM_ONLY_IND)  or (( tlinfo.SYSTEM_ONLY_IND is null ) AND ( X_SYSTEM_ONLY_IND is null )))
      AND ((tlinfo.DFLT_OUTSTANDING_IND = X_DFLT_OUTSTANDING_IND) or (( tlinfo.DFLT_OUTSTANDING_IND is null ) AND ( X_DFLT_OUTSTANDING_IND is null )))
      AND ((tlinfo.EXTERNAL_GRADE = X_EXTERNAL_GRADE) OR ((tlinfo.EXTERNAL_GRADE is null) AND (X_EXTERNAL_GRADE is null)))
      AND ((tlinfo.LOWER_MARK_RANGE = X_LOWER_MARK_RANGE) OR ((tlinfo.LOWER_MARK_RANGE is null) AND (X_LOWER_MARK_RANGE is null)))
      AND ((tlinfo.UPPER_MARK_RANGE = X_UPPER_MARK_RANGE) OR ((tlinfo.UPPER_MARK_RANGE is null) AND (X_UPPER_MARK_RANGE is null)))
      AND ((tlinfo.MIN_PERCENTAGE = X_MIN_PERCENTAGE) OR ((tlinfo.MIN_PERCENTAGE is null) AND (X_MIN_PERCENTAGE is null)))
      AND ((tlinfo.MAX_PERCENTAGE = X_MAX_PERCENTAGE) OR ((tlinfo.MAX_PERCENTAGE is null) AND (X_MAX_PERCENTAGE is null)))
      AND ((tlinfo.GPA_VAL = X_GPA_VAL)  OR ((tlinfo.GPA_VAL is null)               AND (X_GPA_VAL is null)))
      AND ((tlinfo.RANK = X_RANK) OR (( tlinfo.RANK is null ) AND (X_RANK is null )))
      AND ((tlinfo.INCL_IN_REPEAT_PROCESS_IND = X_INCL_IN_REPEAT_PROCESS_IND) OR ((tlinfo.INCL_IN_REPEAT_PROCESS_IND is null)     AND (X_INCL_IN_REPEAT_PROCESS_IND is null)))
      AND ((tlinfo.ADMIN_ONLY_IND = X_ADMIN_ONLY_IND) OR ((tlinfo.ADMIN_ONLY_IND is null)     AND (X_ADMIN_ONLY_IND is null)))
      AND ((tlinfo.GRADING_PERIOD_CD = X_GRADING_PERIOD_CD) OR ((tlinfo.GRADING_PERIOD_CD is null)     AND (X_GRADING_PERIOD_CD is null)))
      AND ((tlinfo.REPEAT_GRADE = X_REPEAT_GRADE) OR ((tlinfo.REPEAT_GRADE is null)     AND (X_REPEAT_GRADE is null)))
      AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (x_attribute_category IS NULL)))
      AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (x_attribute1 IS NULL)))
      AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (x_attribute2 IS NULL)))
      AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (x_attribute3 IS NULL)))
      AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (x_attribute4 IS NULL)))
      AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (x_attribute5 IS NULL)))
      AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (x_attribute6 IS NULL)))
      AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (x_attribute7 IS NULL)))
      AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (x_attribute8 IS NULL)))
      AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (x_attribute9 IS NULL)))
      AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (x_attribute10 IS NULL)))
      AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (x_attribute11 IS NULL)))
      AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (x_attribute12 IS NULL)))
      AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (x_attribute13 IS NULL)))
     AND ((tlinfo.attribute14 = x_attribute14)  OR ((tlinfo.attribute14 IS NULL) AND (x_attribute14 IS NULL)))
     AND ((tlinfo.attribute15 = x_attribute15)  OR ((tlinfo.attribute15 IS NULL) AND (x_attribute15 IS NULL)))
     AND ((tlinfo.attribute16 = x_attribute16)  OR ((tlinfo.attribute16 IS NULL) AND (x_attribute16 IS NULL)))
     AND ((tlinfo.attribute17 = x_attribute17)  OR ((tlinfo.attribute17 IS NULL) AND (x_attribute17 IS NULL)))
     AND ((tlinfo.attribute18 = x_attribute18)  OR ((tlinfo.attribute18 IS NULL) AND (x_attribute18 IS NULL)))
     AND ((tlinfo.attribute19 = x_attribute19)  OR ((tlinfo.attribute19 IS NULL) AND (x_attribute19 IS NULL)))
     AND ((tlinfo.attribute20 = x_attribute20)  OR ((tlinfo.attribute20 IS NULL) AND (x_attribute20 IS NULL)))
     AND ((tlinfo.closed_ind = x_closed_ind)  OR ((tlinfo.closed_ind IS NULL) AND (x_closed_ind IS NULL)))
     ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_ROWID in  VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_FULL_GRADE_NAME in VARCHAR2,
  X_S_RESULT_TYPE in VARCHAR2,
  X_SHOW_ON_NOTICEBOARD_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_S_SPECIAL_GRADE_TYPE in VARCHAR2,
  X_SHOW_IN_NEWSPAPER_IND in VARCHAR2,
  X_SHOW_INTERNALLY_IND in VARCHAR2,
  X_SYSTEM_ONLY_IND in VARCHAR2,
  X_DFLT_OUTSTANDING_IND in VARCHAR2,
  X_EXTERNAL_GRADE in VARCHAR2,
  X_LOWER_MARK_RANGE in NUMBER,
  X_UPPER_MARK_RANGE in NUMBER,
  X_MIN_PERCENTAGE in NUMBER,
  X_MAX_PERCENTAGE in NUMBER,
  X_GPA_VAL in NUMBER,
  X_RANK in NUMBER,
  X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2,
  X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2,
  X_ADMIN_ONLY_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2,
  X_REPEAT_GRADE in VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_closed_ind In VARCHAR2 default 'N'
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_dflt_outstanding_ind=>X_DFLT_OUTSTANDING_IND,
 x_external_grade=>X_EXTERNAL_GRADE,
 x_full_grade_name=>X_FULL_GRADE_NAME,
 x_gpa_val=>X_GPA_VAL,
 x_grade=>X_GRADE,
 x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
 x_lower_mark_range=>X_LOWER_MARK_RANGE,
 x_max_percentage=>X_MAX_PERCENTAGE,
 x_min_percentage=>X_MIN_PERCENTAGE,
 x_rank=>X_RANK,
 x_s_result_type=>X_S_RESULT_TYPE,
 x_s_special_grade_type=>X_S_SPECIAL_GRADE_TYPE,
 x_show_in_newspaper_ind=>X_SHOW_IN_NEWSPAPER_IND,
 x_show_internally_ind=>X_SHOW_INTERNALLY_IND,
 x_show_on_noticeboard_ind=>X_SHOW_ON_NOTICEBOARD_IND,
 x_show_on_official_ntfctn_ind=>X_SHOW_ON_OFFICIAL_NTFCTN_IND,
 x_system_only_ind=>X_SYSTEM_ONLY_IND,
 x_upper_mark_range=>X_UPPER_MARK_RANGE,
 x_version_number=>X_VERSION_NUMBER,
 x_show_in_earned_crdt_ind => X_SHOW_IN_EARNED_CRDT_IND,
 x_incl_in_repeat_process_ind => X_INCL_IN_REPEAT_PROCESS_IND,
 x_admin_only_ind => X_ADMIN_ONLY_IND,
 x_grading_period_cd => X_GRADING_PERIOD_CD,
 x_repeat_grade => X_REPEAT_GRADE ,
 x_attribute_category=>x_attribute_category,
 x_attribute1=>x_attribute1,
 x_attribute2=>x_attribute2,
 x_attribute3=>x_attribute3,
 x_attribute4=>x_attribute4,
 x_attribute5=>x_attribute5,
 x_attribute6=>x_attribute6,
 x_attribute7=>x_attribute7,
 x_attribute8=>x_attribute8,
 x_attribute9=>x_attribute9,
 x_attribute10=>x_attribute10,
 x_attribute11=>x_attribute11,
 x_attribute12=>x_attribute12,
 x_attribute13=>x_attribute13,
 x_attribute14=>x_attribute14,
 x_attribute15=>x_attribute15,
 x_attribute16=>x_attribute16,
 x_attribute17=>x_attribute17,
 x_attribute18=>x_attribute18,
 x_attribute19=>x_attribute19,
 x_attribute20=>x_attribute20,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_closed_ind =>  x_closed_ind
 );
  update IGS_AS_GRD_SCH_GRADE set
    FULL_GRADE_NAME = NEW_REFERENCES.FULL_GRADE_NAME,
    S_RESULT_TYPE = NEW_REFERENCES.S_RESULT_TYPE,
    SHOW_ON_NOTICEBOARD_IND = NEW_REFERENCES.SHOW_ON_NOTICEBOARD_IND,
    SHOW_ON_OFFICIAL_NTFCTN_IND = NEW_REFERENCES.SHOW_ON_OFFICIAL_NTFCTN_IND,
    S_SPECIAL_GRADE_TYPE = NEW_REFERENCES.S_SPECIAL_GRADE_TYPE,
    SHOW_IN_NEWSPAPER_IND = NEW_REFERENCES.SHOW_IN_NEWSPAPER_IND,
    SHOW_INTERNALLY_IND = NEW_REFERENCES.SHOW_INTERNALLY_IND,
    SYSTEM_ONLY_IND = NEW_REFERENCES.SYSTEM_ONLY_IND,
    DFLT_OUTSTANDING_IND = NEW_REFERENCES.DFLT_OUTSTANDING_IND,
    EXTERNAL_GRADE = NEW_REFERENCES.EXTERNAL_GRADE,
    LOWER_MARK_RANGE = NEW_REFERENCES.LOWER_MARK_RANGE,
    UPPER_MARK_RANGE = NEW_REFERENCES.UPPER_MARK_RANGE,
    MIN_PERCENTAGE = NEW_REFERENCES.MIN_PERCENTAGE,
    MAX_PERCENTAGE = NEW_REFERENCES.MAX_PERCENTAGE,
    GPA_VAL = NEW_REFERENCES.GPA_VAL,
    RANK = NEW_REFERENCES.RANK,
    SHOW_IN_EARNED_CRDT_IND = NEW_REFERENCES.SHOW_IN_EARNED_CRDT_IND,
    INCL_IN_REPEAT_PROCESS_IND = NEW_REFERENCES.INCL_IN_REPEAT_PROCESS_IND,
    ADMIN_ONLY_IND = NEW_REFERENCES.ADMIN_ONLY_IND,
    GRADING_PERIOD_CD = NEW_REFERENCES.GRADING_PERIOD_CD,
    REPEAT_GRADE = NEW_REFERENCES.REPEAT_GRADE,
    attribute_category =  new_references.attribute_category,
    attribute1 =  new_references.attribute1,
    attribute2 =  new_references.attribute2,
    attribute3 =  new_references.attribute3,
    attribute4 =  new_references.attribute4,
    attribute5 =  new_references.attribute5,
    attribute6 =  new_references.attribute6,
    attribute7 =  new_references.attribute7,
    attribute8 =  new_references.attribute8,
    attribute9 =  new_references.attribute9,
    attribute10 =  new_references.attribute10,
    attribute11 =  new_references.attribute11,
    attribute12 =  new_references.attribute12,
    attribute13 =  new_references.attribute13,
    attribute14 =  new_references.attribute14,
    attribute15 =  new_references.attribute15,
    attribute16 =  new_references.attribute16,
    attribute17 =  new_references.attribute17,
    attribute18 =  new_references.attribute18,
    attribute19 =  new_references.attribute19,
    attribute20 =  new_references.attribute20,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    closed_ind = x_closed_ind
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_FULL_GRADE_NAME in VARCHAR2,
  X_S_RESULT_TYPE in VARCHAR2,
  X_SHOW_ON_NOTICEBOARD_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_S_SPECIAL_GRADE_TYPE in VARCHAR2,
  X_SHOW_IN_NEWSPAPER_IND in VARCHAR2,
  X_SHOW_INTERNALLY_IND in VARCHAR2,
  X_SYSTEM_ONLY_IND in VARCHAR2,
  X_DFLT_OUTSTANDING_IND in VARCHAR2,
  X_EXTERNAL_GRADE in VARCHAR2,
  X_LOWER_MARK_RANGE in NUMBER,
  X_UPPER_MARK_RANGE in NUMBER,
  X_MIN_PERCENTAGE in NUMBER,
  X_MAX_PERCENTAGE in NUMBER,
  X_GPA_VAL in NUMBER,
  X_RANK in NUMBER,
  X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2,
  X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2,
  X_ADMIN_ONLY_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2,
  X_REPEAT_GRADE in VARCHAR2,
    x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_closed_ind IN VARCHAR2 default 'N'
  ) AS
  cursor c1 is select rowid from IGS_AS_GRD_SCH_GRADE
     where GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and GRADE = X_GRADE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GRADING_SCHEMA_CD,
     X_VERSION_NUMBER,
     X_GRADE,
     X_FULL_GRADE_NAME,
     X_S_RESULT_TYPE,
     X_SHOW_ON_NOTICEBOARD_IND,
     X_SHOW_ON_OFFICIAL_NTFCTN_IND,
     X_S_SPECIAL_GRADE_TYPE,
     X_SHOW_IN_NEWSPAPER_IND,
     X_SHOW_INTERNALLY_IND,
     X_SYSTEM_ONLY_IND,
     X_DFLT_OUTSTANDING_IND,
     X_EXTERNAL_GRADE,
     X_LOWER_MARK_RANGE,
     X_UPPER_MARK_RANGE,
     X_MIN_PERCENTAGE,
     X_MAX_PERCENTAGE,
     X_GPA_VAL,
     X_RANK,
     X_SHOW_IN_EARNED_CRDT_IND,
     X_INCL_IN_REPEAT_PROCESS_IND,
     X_ADMIN_ONLY_IND,
     X_GRADING_PERIOD_CD,
     X_REPEAT_GRADE,
     x_attribute_category,
     x_attribute1,
     x_attribute2,
     x_attribute3,
     x_attribute4,
     x_attribute5,
     x_attribute6,
     x_attribute7,
     x_attribute8,
     x_attribute9,
     x_attribute10,
     x_attribute11,
     x_attribute12,
     x_attribute13,
     x_attribute14,
     x_attribute15,
     x_attribute16,
     x_attribute17,
     x_attribute18,
     x_attribute19,
     x_attribute20,
     X_MODE,
     x_closed_ind);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_GRADING_SCHEMA_CD,
   X_VERSION_NUMBER,
   X_GRADE,
   X_FULL_GRADE_NAME,
   X_S_RESULT_TYPE,
   X_SHOW_ON_NOTICEBOARD_IND,
   X_SHOW_ON_OFFICIAL_NTFCTN_IND,
   X_S_SPECIAL_GRADE_TYPE,
   X_SHOW_IN_NEWSPAPER_IND,
   X_SHOW_INTERNALLY_IND,
   X_SYSTEM_ONLY_IND,
   X_DFLT_OUTSTANDING_IND,
   X_EXTERNAL_GRADE,
   X_LOWER_MARK_RANGE,
   X_UPPER_MARK_RANGE,
   X_MIN_PERCENTAGE,
   X_MAX_PERCENTAGE,
   X_GPA_VAL,
   X_RANK,
   X_SHOW_IN_EARNED_CRDT_IND ,
   X_INCL_IN_REPEAT_PROCESS_IND ,
   X_ADMIN_ONLY_IND ,
   X_GRADING_PERIOD_CD,
   X_REPEAT_GRADE ,
   x_attribute_category,
   x_attribute1,
   x_attribute2,
   x_attribute3,
   x_attribute4,
   x_attribute5,
   x_attribute6,
   x_attribute7,
   x_attribute8,
   x_attribute9,
   x_attribute10,
   x_attribute11,
   x_attribute12,
   x_attribute13,
   x_attribute14,
   x_attribute15,
   x_attribute16,
   x_attribute17,
   x_attribute18,
   x_attribute19,
   x_attribute20,
   X_MODE,
   x_closed_ind);
end ADD_ROW;

end IGS_AS_GRD_SCH_GRADE_PKG;

/
