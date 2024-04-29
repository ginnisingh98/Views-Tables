--------------------------------------------------------
--  DDL for Package Body IGS_AS_UNTAS_PATTERN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_UNTAS_PATTERN_PKG" as
/* $Header: IGSDI33B.pls 120.0 2005/07/05 12:26:53 appldev noship $ */

--
  l_rowid VARCHAR2(25);
  old_references IGS_AS_UNTAS_PATTERN_ALL%RowType;
  new_references IGS_AS_UNTAS_PATTERN_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_ass_pattern_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_dflt_pattern_ind IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_action_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) as
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_UNTAS_PATTERN_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
            Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type:= x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.ass_pattern_id := x_ass_pattern_id;
    new_references.ass_pattern_cd := x_ass_pattern_cd;
    new_references.description := x_description;
    new_references.location_cd := x_location_cd;
    new_references.unit_class:= x_unit_class;
    new_references.unit_mode:= x_unit_mode;
    new_references.dflt_pattern_ind := x_dflt_pattern_ind;
    new_references.logical_delete_dt := x_logical_delete_dt;
    new_references.action_dt := x_action_dt;
    new_references.org_id := x_org_id;
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
  -- Trigger description :-
  -- "OSS_TST".trg_uap_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AS_UNTAS_PATTERN
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
   v_message_name  varchar2(30);
  BEGIN
	IF  p_inserting OR p_updating THEN
		-- Validate IGS_AD_LOCATION closed indicator

		-- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_UAP.crsp_val_loc_cd
		IF  IGS_PS_VAL_UOO.crsp_val_loc_cd (
						new_references.location_cd,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
		-- Validate IGS_PS_UNIT mode closed indicator
		-- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_UAP.crsp_val_um_closed
		IF  IGS_AS_VAL_UAI.crsp_val_um_closed (
						new_references.unit_mode,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
		-- Validate IGS_PS_UNIT class indicator
		-- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_UAP.crsp_val_ucl_closed
		IF  IGS_AS_VAL_UAI.crsp_val_ucl_closed (
						new_references.unit_class,
				v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
		-- If the IGS_PS_UNIT version status is inactive then prevent inserts, updates and
		-- deletes. As deletes are logical, they are equiv to updates and delete
		-- trigger is not required.
		IF  IGS_ps_val_unit.crsp_val_iud_uv_dtl (
						new_references.unit_cd,
						new_references.version_number,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
		-- If calendar instance is inactive, then prevent inserts, updates and
		-- deletes. As deletes are logical, they are equiv to updates and delete
		-- trigger is not required.
		IF  IGS_AS_VAL_UAI.crsp_val_crs_ci (
						new_references.cal_type,
						new_references.ci_sequence_number,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	    IF  p_inserting THEN
		-- If calendar type is closed, then prevent inserts.
		-- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_UAP.crsp_val_uo_cal_type
		IF  IGS_AS_VAL_UAI.crsp_val_uo_cal_type (
						new_references.cal_type,
		v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	    END IF;
	-- Validate that IGS_PS_UNIT mode and IGS_PS_UNIT class cannot be set at the same time.
	IF  p_inserting OR
	   (p_updating AND
	    (NVL(new_references.unit_class,'NULL') <> NVL(old_references.unit_class,'NULL')) OR
	    (NVL(new_references.unit_mode,'NULL') <> NVL(old_references.unit_mode,'NULL')))THEN
		IF  IGS_AS_VAL_UAP.assp_val_uc_um (new_references.UNIT_MODE,
						new_references.unit_class,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the IGS_AD_LOCATION, class and mode are not not in conflict with any of
	-- the pattern items.
	IF (p_updating AND
	   ((NVL(new_references.location_cd, 'NULL') <> NVL(old_references.location_cd, 'NULL')) OR
	    (NVL(new_references.unit_class,'NULL') <> NVL(old_references.unit_class,'NULL')) OR
	    (NVL(new_references.unit_mode, 'NULL') <> NVL(old_references.unit_mode,'NULL'))))THEN
		IF  IGS_AS_VAL_UAP.assp_val_uap_uoo_upd (new_references.unit_cd,
						new_references.version_number,
						new_references.cal_type,						new_references.ci_sequence_number,
						new_references.ass_pattern_id,
						new_references.location_cd,
						new_references.unit_class,
						new_references.unit_mode,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
		IF  IGS_AS_GEN_005.ASSP_UPD_UAP_UOO (new_references.unit_cd,
					new_references.version_number,
					new_references.cal_type,					new_references.ci_sequence_number,
					new_references.ass_pattern_id,
					new_references.location_cd,
					new_references.unit_class,					new_references.unit_mode,					'Y',
					v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR p_deleting OR
	   (p_updating AND
	   ((NVL(new_references.location_cd, 'NULL') <> NVL(old_references.location_cd, 'NULL')) OR
	    (NVL(new_references.unit_class,'NULL') <> NVL(old_references.unit_class,'NULL')) OR
	    (new_references.dflt_pattern_ind <> old_references.dflt_pattern_ind) OR
	    (NVL(new_references.logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
		NVL(old_references.logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
	    (NVL(new_references.unit_mode,'NULL') <> NVL(old_references.unit_mode,'NULL'))))THEN
		IF NVL(new_references.action_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
			 = IGS_GE_DATE.IGSDATE('1900/01/01') THEN
			new_references.action_dt := SYSDATE;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_uap_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_UNTAS_PATTERN
  -- FOR EACH ROW
  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
     v_message_name  varchar2(30);
  BEGIN
  	IF p_inserting OR
  	    ( p_updating AND
  		new_references.ass_pattern_cd <> old_references.ass_pattern_cd) THEN
        IF IGS_AS_VAL_UAP.assp_val_uap_uniq_cd(
  				new_references.unit_cd,
  				new_references.version_number,
  				new_references.cal_type,
  				new_references.ci_sequence_number,
  				new_references.ass_pattern_id,
  				new_references.ass_pattern_cd,
  					v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  			END IF;
  		-- Validate the assessment pattern code is unique within the IGS_PS_UNIT offering
  		-- pattern.
  		-- Cannot call assp_val_uap_uniq_cd because trigger will be mutating.
  		 -- Save the rowid of the current row.
  	END IF;
  END AfterRowInsertUpdate2;
  -- Trigger description :-
  -- "OSS_TST".trg_uap_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_UNTAS_PATTERN

  PROCEDURE Check_Parent_Existance as
  BEGIN
    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd is NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd ,
        'N'
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

 IF (((old_references.unit_class= new_references.unit_class)) OR
        ((new_references.unit_class IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_AS_UNIT_CLASS_PKG.Get_PK_For_Validation (
        new_references.unit_class
        ))THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.unit_mode= new_references.unit_mode)) OR
        ((new_references.unit_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_AS_UNIT_MODE_PKG.Get_PK_For_Validation (
        new_references.unit_mode
        ))THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type= new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_PS_UNIT_OFR_PAT_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.ci_sequence_number
        ))THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

PROCEDURE Check_Uniqueness AS
   BEGIN
IF  Get_UK_For_Validation (
	         new_references.ass_pattern_id
                          ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
App_Exception.Raise_Exception;
END IF;

End Check_Uniqueness;

PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
	) as
BEGIN



      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'ASS_PATTERN_ID' then
         new_references.ass_pattern_id:= igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'ASS_PATTERN_CD' then
         new_references.ass_pattern_cd:= column_value;
      ELSIF upper(Column_name) = 'CAL_TYPE' then
         new_references.cal_type:= column_value;
      ELSIF upper(Column_name) = 'LOCATION_CD' then
         new_references.location_cd:= column_value;
      ELSIF upper(Column_name) = 'UNIT_MODE' then
         new_references.unit_mode:= column_value;
      ELSIF upper(Column_name) = 'UNIT_CLASS' then
         new_references.unit_class:= column_value;
      ELSIF upper(Column_name) = 'DFLT_PATTERN_IND' then
         new_references.dflt_pattern_ind:= column_value;
      ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
         new_references.ci_sequence_number:= igs_ge_number.to_num(column_value);

      END IF;

     IF upper(column_name) = 'ASS_PATTERN_CD' OR
        column_name is null Then
        IF new_references.ass_pattern_cd <> UPPER(new_references.ass_pattern_cd) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'ASS_PATTERN_ID' OR
         column_name is null Then
         IF new_references.ass_pattern_id < 1  AND   new_references.ass_pattern_id > 999999 Then
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
         END IF;
      END IF;
     IF upper(column_name) = 'CAL_TYPE' OR
        column_name is null Then
        IF new_references.cal_type <> UPPER(new_references.cal_type) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'LOCATION_CD' OR
        column_name is null Then
        IF new_references.location_cd <> UPPER(new_references.location_cd) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'UNIT_MODE' OR
        column_name is null Then
        IF new_references.unit_mode <> UPPER(new_references.unit_mode) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'UNIT_CLASS' OR
        column_name is null Then
        IF new_references.unit_class <> UPPER(new_references.unit_class) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'DFLT_PATTERN_IND' OR
        column_name is null Then
        IF new_references.dflt_pattern_ind <> UPPER(new_references.dflt_pattern_ind) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;


      IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR
         column_name is null Then
         IF new_references.ci_sequence_number < 1  AND   new_references.ci_sequence_number > 999999 Then
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
         END IF;
      END IF;
END Check_Constraints;


  PROCEDURE Check_Child_Existance as
  BEGIN
    IGS_AS_UNT_PATRN_ITM_PKG.GET_FK_IGS_AS_UNTAS_PATTERN (
      OLD_references.unit_cd,
      OLD_references.version_number,
      OLD_references.cal_type,
      OLD_references.ci_sequence_number,
      OLD_references.ass_pattern_id
      );
    IGS_AS_SU_ATMPT_ITM_PKG.GET_UFK_IGS_AS_UNTAS_PATTERN (
      OLD_references.ass_pattern_id
      );
    IGS_AS_SU_ATMPT_PAT_PKG.GET_UFK_IGS_AS_UNTAS_PATTERN (
      OLD_references.ass_pattern_id
      );
  END Check_Child_Existance;
PROCEDURE Check_UK_Child_Existance as
  BEGIN
    IF ((old_references.ass_pattern_id = new_references.ass_pattern_id)
    OR (old_references.ass_pattern_id IS NULL)) THEN
       NULL;
    ELSE
       IGS_AS_SU_ATMPT_ITM_PKG.GET_UFK_IGS_AS_UNTAS_PATTERN(old_references.ass_pattern_id);
       IGS_AS_SU_ATMPT_PAT_PKG.GET_UFK_IGS_AS_UNTAS_PATTERN(old_references.ass_pattern_id);
    END IF;
  END Check_UK_Child_Existance;
  FUNCTION   Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_ass_pattern_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNTAS_PATTERN_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type= x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      ass_pattern_id = x_ass_pattern_id
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


  FUNCTION Get_UK_For_Validation (
    x_ass_pattern_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNTAS_PATTERN_ALL
      WHERE    ass_pattern_id = x_ass_pattern_id
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
  END Get_UK_For_Validation;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNTAS_PATTERN_ALL
      WHERE    location_cd = x_location_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_UAP_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_LOCATION;
  PROCEDURE GET_FK_IGS_AS_UNIT_CLASS (
    x_unit_class IN VARCHAR2
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNTAS_PATTERN_ALL
      WHERE    unit_class= x_unit_class ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_UAP_UCL_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_UNIT_CLASS;
  PROCEDURE GET_FK_IGS_AS_UNIT_MODE (
    x_unit_mode IN VARCHAR2
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNTAS_PATTERN_ALL
      WHERE    unit_mode= x_unit_mode ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_UAP_UM_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_UNIT_MODE;
  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_PAT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNTAS_PATTERN_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type= x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_UAP_UOP_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_UNIT_OFR_PAT;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL ,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_ass_pattern_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_dflt_pattern_ind IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_action_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL ,
    x_created_by IN NUMBER DEFAULT NULL ,
    x_last_update_date IN DATE DEFAULT NULL ,
    x_last_updated_by IN NUMBER DEFAULT NULL ,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) as
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_ass_pattern_id,
      x_ass_pattern_cd,
      x_description,
      x_location_cd,
      x_unit_class,
      x_unit_mode,
      x_dflt_pattern_ind,
      x_logical_delete_dt,
      x_action_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
IF  Get_PK_For_Validation (
             new_references.unit_cd ,
             new_references.version_number ,
             new_references.cal_type ,
             new_references.ci_sequence_number,
             new_references.ass_pattern_id
			             ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
App_Exception.Raise_Exception;
END IF;

      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
      Check_UK_Child_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
   IF  Get_PK_For_Validation (
             new_references.unit_cd,
             new_references.version_number,
             new_references.cal_type,
             new_references.ci_sequence_number,
             new_references.ass_pattern_id
			             ) THEN
   Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
  ) as
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;
l_rowid:=NULL;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_PATTERN_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DFLT_PATTERN_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_ACTION_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) as
    cursor C is select ROWID from IGS_AS_UNTAS_PATTERN_ALL
      where UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
      and ASS_PATTERN_ID = X_ASS_PATTERN_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := NULL;
     X_PROGRAM_ID := NULL;
     X_PROGRAM_APPLICATION_ID := NULL;
     X_PROGRAM_UPDATE_DATE := NULL;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
--
   Before_DML(
    p_action=>'INSERT',
    x_rowid=>X_ROWID,
    x_action_dt=>X_ACTION_DT,
    x_ass_pattern_cd=>X_ASS_PATTERN_CD,
    x_ass_pattern_id=>X_ASS_PATTERN_ID,
    x_cal_type=>X_CAL_TYPE,
    x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
    x_description=>X_DESCRIPTION,
    x_dflt_pattern_ind=>nvl(X_DFLT_PATTERN_IND,'N'),
    x_location_cd=>X_LOCATION_CD,
    x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
    x_unit_cd=>X_UNIT_CD,
    x_unit_class=>X_UNIT_CLASS,
    x_unit_mode=>X_UNIT_MODE,
    x_version_number=>X_VERSION_NUMBER,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
    );
--
  insert into IGS_AS_UNTAS_PATTERN_ALL (
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    ASS_PATTERN_ID,
    ASS_PATTERN_CD,
    DESCRIPTION,
    LOCATION_CD,
    UNIT_CLASS,
    UNIT_MODE,
    DFLT_PATTERN_IND,
    LOGICAL_DELETE_DT,
    ACTION_DT,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ASS_PATTERN_ID,
    NEW_REFERENCES.ASS_PATTERN_CD,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.UNIT_MODE,
    NEW_REFERENCES.DFLT_PATTERN_IND,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    NEW_REFERENCES.ACTION_DT,
    NEW_REFERENCES.ORG_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
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
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_PATTERN_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DFLT_PATTERN_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_ACTION_DT in DATE
) as
  cursor c1 is select
      ASS_PATTERN_CD,
      DESCRIPTION,
      LOCATION_CD,
      UNIT_CLASS,
      UNIT_MODE,
      DFLT_PATTERN_IND,
      LOGICAL_DELETE_DT,
      ACTION_DT
    from IGS_AS_UNTAS_PATTERN_ALL
    where ROWID = X_ROWID  for update  nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
  if ( (tlinfo.ASS_PATTERN_CD = X_ASS_PATTERN_CD)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.UNIT_CLASS = X_UNIT_CLASS)
           OR ((tlinfo.UNIT_CLASS is null)
               AND (X_UNIT_CLASS is null)))
      AND ((tlinfo.UNIT_MODE = X_UNIT_MODE)
           OR ((tlinfo.UNIT_MODE is null)
               AND (X_UNIT_MODE is null)))
      AND (tlinfo.DFLT_PATTERN_IND = X_DFLT_PATTERN_IND)
      AND ((trunc(tlinfo.LOGICAL_DELETE_DT) = trunc(X_LOGICAL_DELETE_DT))
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
      AND ((trunc(tlinfo.ACTION_DT) = trunc(X_ACTION_DT))
           OR ((tlinfo.ACTION_DT is null)
               AND (X_ACTION_DT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_ROWID in  VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_PATTERN_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DFLT_PATTERN_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_ACTION_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
    app_exception.raise_exception;
  end if;
  Before_DML(
    p_action=>'UPDATE',
    x_rowid=>X_ROWID,
    x_action_dt=>X_ACTION_DT,
    x_ass_pattern_cd=>X_ASS_PATTERN_CD,
    x_ass_pattern_id=>X_ASS_PATTERN_ID,
    x_cal_type=>X_CAL_TYPE,
    x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
    x_description=>X_DESCRIPTION,
    x_dflt_pattern_ind=>X_DFLT_PATTERN_IND,
    x_location_cd=>X_LOCATION_CD,
    x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
    x_unit_cd=>X_UNIT_CD,
    x_unit_class=>X_UNIT_CLASS,
    x_unit_mode=>X_UNIT_MODE,
    x_version_number=>X_VERSION_NUMBER,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
 if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
--
--
end if;
  update IGS_AS_UNTAS_PATTERN_ALL set
    ASS_PATTERN_CD = NEW_REFERENCES.ASS_PATTERN_CD,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    UNIT_MODE = NEW_REFERENCES.UNIT_MODE,
    DFLT_PATTERN_IND = NEW_REFERENCES.DFLT_PATTERN_IND,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    ACTION_DT = NEW_REFERENCES.ACTION_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
--
After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
--
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_PATTERN_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DFLT_PATTERN_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_ACTION_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) as
  cursor c1 is select rowid from IGS_AS_UNTAS_PATTERN_ALL
     where UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and CAL_TYPE = X_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and ASS_PATTERN_ID = X_ASS_PATTERN_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_ASS_PATTERN_ID,
     X_ASS_PATTERN_CD,
     X_DESCRIPTION,
     X_LOCATION_CD,
     X_UNIT_CLASS,
     X_UNIT_MODE,
     X_DFLT_PATTERN_IND,
     X_LOGICAL_DELETE_DT,
     X_ACTION_DT,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_ASS_PATTERN_ID,
   X_ASS_PATTERN_CD,
   X_DESCRIPTION,
   X_LOCATION_CD,
   X_UNIT_CLASS,
   X_UNIT_MODE,
   X_DFLT_PATTERN_IND,
   X_LOGICAL_DELETE_DT,
   X_ACTION_DT,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) as
begin
--
Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
--
  delete from IGS_AS_UNTAS_PATTERN_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
--
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
--
end DELETE_ROW;
end IGS_AS_UNTAS_PATTERN_PKG;

/
