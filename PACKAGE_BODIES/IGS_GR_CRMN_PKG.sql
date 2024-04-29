--------------------------------------------------------
--  DDL for Package Body IGS_GR_CRMN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_CRMN_PKG" as
/* $Header: IGSGI08B.pls 115.6 2002/11/29 00:35:36 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_CRMN_ALL%RowType;
  new_references IGS_GR_CRMN_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_ceremony_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ceremony_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_closing_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_closing_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_start_time IN DATE DEFAULT NULL,
    x_ceremony_end_time IN DATE DEFAULT NULL,
    x_ceremony_fee IN NUMBER DEFAULT NULL,
    x_number_of_guests IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_CRMN_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.grd_cal_type := x_grd_cal_type;
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.ceremony_number := x_ceremony_number;
    new_references.venue_cd := x_venue_cd;
    new_references.ceremony_dt_alias := x_ceremony_dt_alias;
    new_references.ceremony_dai_sequence_number := x_ceremony_dai_sequence_number;
    new_references.closing_dt_alias := x_closing_dt_alias;
    new_references.closing_dai_sequence_number := x_closing_dai_sequence_number;
    new_references.ceremony_start_time := x_ceremony_start_time;
    new_references.ceremony_end_time := x_ceremony_end_time;
    new_references.ceremony_fee := x_ceremony_fee;
    new_references.number_of_guests := x_number_of_guests;
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
  -- "OSS_TST".trg_gc_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_CRMN_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate the graduation ceremony record can be updated
	IF p_updating THEN
		IF (new_references.ceremony_dt_alias <> old_references.ceremony_dt_alias OR
		    new_references.ceremony_dai_sequence_number <> old_references.ceremony_dai_sequence_number OR
		    new_references.closing_dt_alias <> old_references.closing_dt_alias OR
		    new_references.closing_dai_sequence_number <> old_references.closing_dai_sequence_number) THEN
			IF IGS_GR_VAL_GC.grdp_val_gc_upd(
					new_references.grd_cal_type,
					new_references.grd_ci_sequence_number,
					new_references.ceremony_number,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND new_references.venue_cd <> old_references.venue_cd) THEN
		-- Validate venue is related to a location with a s_location_type of grd_ctr
		IF IGS_GR_VAL_GC.grdp_val_ve_lot(
				new_references.venue_cd,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
		-- Validate venue is not closed
		IF IGS_GR_VAL_GC.assp_val_ve_closed(
				new_references.venue_cd,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
	(new_references.ceremony_dt_alias <> old_references.ceremony_dt_alias OR
	new_references.ceremony_dai_sequence_number <> old_references.ceremony_dai_sequence_number OR
	new_references.closing_dt_alias <> old_references.closing_dt_alias OR
	new_references.closing_dai_sequence_number <> old_references.closing_dai_sequence_number)) THEN
		-- Validate the graduation ceremony date aliases
		IF IGS_GR_VAL_GC.grdp_val_gc_dai(
				new_references.grd_cal_type,
				new_references.grd_ci_sequence_number,
				new_references.ceremony_dt_alias,
				new_references.ceremony_dai_sequence_number,
				new_references.closing_dt_alias,
				new_references.closing_dai_sequence_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_gc_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_GR_CRMN_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	IF p_inserting OR (p_updating AND
	   (new_references.ceremony_start_time <> old_references.ceremony_start_time OR
	   new_references.ceremony_end_time <> old_references.ceremony_end_time)) THEN
  			-- validate graduation ceremony start and end times
  			IF IGS_GR_VAL_GC.grdp_val_gc_times(
  					NEW_REFERENCES.grd_cal_type,
  					NEW_REFERENCES.grd_ci_sequence_number,
  					NEW_REFERENCES.ceremony_number,
  					NEW_REFERENCES.venue_cd,
  					NEW_REFERENCES.ceremony_dt_alias,
  					NEW_REFERENCES.ceremony_dai_sequence_number,
  					NEW_REFERENCES.ceremony_start_time,
  					NEW_REFERENCES.ceremony_end_time,
  					v_message_name) = FALSE THEN
  				Fnd_Message.Set_Name('IGS', v_message_name);
  				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
  			END IF;
		v_rowid_saved := TRUE;
	END IF;

  END AfterRowInsertUpdate2;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.ceremony_dt_alias = new_references.ceremony_dt_alias) AND
         (old_references.ceremony_dai_sequence_number = new_references.ceremony_dai_sequence_number) AND
         (old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number)) OR
        ((new_references.ceremony_dt_alias IS NULL) OR
         (new_references.ceremony_dai_sequence_number IS NULL) OR
         (new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.ceremony_dt_alias,
        new_references.ceremony_dai_sequence_number,
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

    IF (((old_references.closing_dt_alias = new_references.closing_dt_alias) AND
         (old_references.closing_dai_sequence_number = new_references.closing_dai_sequence_number) AND
         (old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number)) OR
        ((new_references.closing_dt_alias IS NULL) OR
         (new_references.closing_dai_sequence_number IS NULL) OR
         (new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.closing_dt_alias,
        new_references.closing_dai_sequence_number,
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

    IF (((old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number)) OR
        ((new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_CRMN_ROUND_PKG.Get_PK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

    IF (((old_references.venue_cd = new_references.venue_cd)) OR
        ((new_references.venue_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_VENUE_PKG.Get_PK_For_Validation (
        new_references.venue_cd
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE CHECK_CONSTRAINTS(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
  BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'CEREMONY_DT_ALIAS' THEN
  new_references.CEREMONY_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'CLOSING_DT_ALIAS' THEN
  new_references.CLOSING_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRD_CAL_TYPE' THEN
  new_references.GRD_CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'VENUE_CD' THEN
  new_references.VENUE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' THEN
  new_references.GRD_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'CEREMONY_NUMBER' THEN
  new_references.CEREMONY_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'CEREMONY_DAI_SEQUENCE_NUMBER' THEN
  new_references.CEREMONY_DAI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'CLOSING_DAI_SEQUENCE_NUMBER' THEN
  new_references.CLOSING_DAI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'CEREMONY_FEE' THEN
  new_references.CEREMONY_FEE:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'NUMBER_OF_GUESTS' THEN
  new_references.NUMBER_OF_GUESTS:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
END IF ;

IF upper(Column_name) = 'CEREMONY_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.CEREMONY_DT_ALIAS<> upper(NEW_REFERENCES.CEREMONY_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CLOSING_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.CLOSING_DT_ALIAS<> upper(NEW_REFERENCES.CLOSING_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRD_CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CAL_TYPE<> upper(NEW_REFERENCES.GRD_CAL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'VENUE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.VENUE_CD<> upper(NEW_REFERENCES.VENUE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
IF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CI_SEQUENCE_NUMBER < 1 OR new_references.GRD_CI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
IF upper(Column_name) = 'CEREMONY_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.CEREMONY_NUMBER < 0 OR new_references.CEREMONY_NUMBER > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
IF upper(Column_name) = 'CEREMONY_DAI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.CEREMONY_DAI_SEQUENCE_NUMBER < 1 OR new_references.CEREMONY_DAI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
IF upper(Column_name) = 'CLOSING_DAI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.CLOSING_DAI_SEQUENCE_NUMBER < 1 OR new_references.CLOSING_DAI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
IF upper(Column_name) = 'CEREMONY_FEE' OR COLUMN_NAME IS NULL THEN
  IF new_references.CEREMONY_FEE < 0.00 OR new_references.CEREMONY_FEE > 999.99 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
IF upper(Column_name) = 'NUMBER_OF_GUESTS' OR COLUMN_NAME IS NULL THEN
  IF new_references.NUMBER_OF_GUESTS < 0 OR new_references.NUMBER_OF_GUESTS > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
  END;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_GR_AWD_CEREMONY_PKG.GET_FK_IGS_GR_CRMN (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number,
      old_references.ceremony_number
      );

    IGS_GR_CRMN_NOTE_PKG.GET_FK_IGS_GR_CRMN (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number,
      old_references.ceremony_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_ALL
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number
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

  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_ALL
      WHERE    (ceremony_dt_alias = x_dt_alias
      AND      ceremony_dai_sequence_number = x_sequence_number
      AND      grd_cal_type = x_cal_type
      AND      grd_ci_sequence_number = x_ci_sequence_number)
	OR	   (closing_dt_alias = x_dt_alias
      AND      closing_dai_sequence_number = x_sequence_number
      AND      grd_cal_type = x_cal_type
      AND      grd_ci_sequence_number = x_ci_sequence_number) ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GC_CEREMONY_DAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA_INST;

  PROCEDURE GET_FK_IGS_GR_CRMN_ROUND (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_ALL
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GC_CRD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_CRMN_ROUND;

  PROCEDURE GET_FK_IGS_GR_VENUE (
    x_venue_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_ALL
      WHERE    venue_cd = x_venue_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GC_VE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_VENUE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_ceremony_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ceremony_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_closing_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_closing_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_start_time IN DATE DEFAULT NULL,
    x_ceremony_end_time IN DATE DEFAULT NULL,
    x_ceremony_fee IN NUMBER DEFAULT NULL,
    x_number_of_guests IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_grd_cal_type,
      x_grd_ci_sequence_number,
      x_ceremony_number,
      x_venue_cd,
      x_ceremony_dt_alias,
      x_ceremony_dai_sequence_number,
      x_closing_dt_alias,
      x_closing_dai_sequence_number,
      x_ceremony_start_time,
      x_ceremony_end_time,
      x_ceremony_fee,
      x_number_of_guests,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF GET_PK_FOR_VALIDATION(
	    NEW_REFERENCES.grd_cal_type,
	    NEW_REFERENCES.grd_ci_sequence_number,
	    NEW_REFERENCES.ceremony_number
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
	    NEW_REFERENCES.grd_cal_type,
	    NEW_REFERENCES.grd_ci_sequence_number,
	    NEW_REFERENCES.ceremony_number
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	check_child_existance;
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
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_VENUE_CD in VARCHAR2,
  X_CEREMONY_DT_ALIAS in VARCHAR2,
  X_CEREMONY_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CLOSING_DT_ALIAS in VARCHAR2,
  X_CLOSING_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_START_TIME in DATE,
  X_CEREMONY_END_TIME in DATE,
  X_CEREMONY_FEE in NUMBER,
  X_NUMBER_OF_GUESTS in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_GR_CRMN_ALL
      where GRD_CAL_TYPE = X_GRD_CAL_TYPE
      and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
      and CEREMONY_NUMBER = X_CEREMONY_NUMBER;
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_venue_cd => X_VENUE_CD,
    x_ceremony_dt_alias => X_CEREMONY_DT_ALIAS,
    x_ceremony_dai_sequence_number => X_CEREMONY_DAI_SEQUENCE_NUMBER,
    x_closing_dt_alias => X_CLOSING_DT_ALIAS,
    x_closing_dai_sequence_number => X_CLOSING_DAI_SEQUENCE_NUMBER,
    x_ceremony_start_time => X_CEREMONY_START_TIME,
    x_ceremony_end_time => X_CEREMONY_END_TIME,
    x_ceremony_fee => X_CEREMONY_FEE,
    x_number_of_guests => X_NUMBER_OF_GUESTS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN,
     x_org_id => igs_ge_gen_003.get_org_id
  );

  insert into IGS_GR_CRMN_ALL (
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER,
    VENUE_CD,
    CEREMONY_DT_ALIAS,
    CEREMONY_DAI_SEQUENCE_NUMBER,
    CLOSING_DT_ALIAS,
    CLOSING_DAI_SEQUENCE_NUMBER,
    CEREMONY_START_TIME,
    CEREMONY_END_TIME,
    CEREMONY_FEE,
    NUMBER_OF_GUESTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.GRD_CAL_TYPE,
    NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CEREMONY_NUMBER,
    NEW_REFERENCES.VENUE_CD,
    NEW_REFERENCES.CEREMONY_DT_ALIAS,
    NEW_REFERENCES.CEREMONY_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CLOSING_DT_ALIAS,
    NEW_REFERENCES.CLOSING_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CEREMONY_START_TIME,
    NEW_REFERENCES.CEREMONY_END_TIME,
    NEW_REFERENCES.CEREMONY_FEE,
    NEW_REFERENCES.NUMBER_OF_GUESTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  After_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID
    );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_VENUE_CD in VARCHAR2,
  X_CEREMONY_DT_ALIAS in VARCHAR2,
  X_CEREMONY_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CLOSING_DT_ALIAS in VARCHAR2,
  X_CLOSING_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_START_TIME in DATE,
  X_CEREMONY_END_TIME in DATE,
  X_CEREMONY_FEE in NUMBER,
  X_NUMBER_OF_GUESTS in NUMBER
) AS
  cursor c1 is select
      VENUE_CD,
      CEREMONY_DT_ALIAS,
      CEREMONY_DAI_SEQUENCE_NUMBER,
      CLOSING_DT_ALIAS,
      CLOSING_DAI_SEQUENCE_NUMBER,
      CEREMONY_START_TIME,
      CEREMONY_END_TIME,
      CEREMONY_FEE,
      NUMBER_OF_GUESTS
    from IGS_GR_CRMN_ALL
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.VENUE_CD = X_VENUE_CD)
      AND (tlinfo.CEREMONY_DT_ALIAS = X_CEREMONY_DT_ALIAS)
      AND (tlinfo.CEREMONY_DAI_SEQUENCE_NUMBER = X_CEREMONY_DAI_SEQUENCE_NUMBER)
      AND (tlinfo.CLOSING_DT_ALIAS = X_CLOSING_DT_ALIAS)
      AND (tlinfo.CLOSING_DAI_SEQUENCE_NUMBER = X_CLOSING_DAI_SEQUENCE_NUMBER)
      AND (tlinfo.CEREMONY_START_TIME = X_CEREMONY_START_TIME)
      AND (tlinfo.CEREMONY_END_TIME = X_CEREMONY_END_TIME)
      AND ((tlinfo.CEREMONY_FEE = X_CEREMONY_FEE)
           OR ((tlinfo.CEREMONY_FEE is null)
               AND (X_CEREMONY_FEE is null)))
      AND ((tlinfo.NUMBER_OF_GUESTS = X_NUMBER_OF_GUESTS)
           OR ((tlinfo.NUMBER_OF_GUESTS is null)
               AND (X_NUMBER_OF_GUESTS is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_VENUE_CD in VARCHAR2,
  X_CEREMONY_DT_ALIAS in VARCHAR2,
  X_CEREMONY_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CLOSING_DT_ALIAS in VARCHAR2,
  X_CLOSING_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_START_TIME in DATE,
  X_CEREMONY_END_TIME in DATE,
  X_CEREMONY_FEE in NUMBER,
  X_NUMBER_OF_GUESTS in NUMBER,
  X_MODE in VARCHAR2 default 'R'
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_venue_cd => X_VENUE_CD,
    x_ceremony_dt_alias => X_CEREMONY_DT_ALIAS,
    x_ceremony_dai_sequence_number => X_CEREMONY_DAI_SEQUENCE_NUMBER,
    x_closing_dt_alias => X_CLOSING_DT_ALIAS,
    x_closing_dai_sequence_number => X_CLOSING_DAI_SEQUENCE_NUMBER,
    x_ceremony_start_time => X_CEREMONY_START_TIME,
    x_ceremony_end_time => X_CEREMONY_END_TIME,
    x_ceremony_fee => X_CEREMONY_FEE,
    x_number_of_guests => X_NUMBER_OF_GUESTS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_CRMN_ALL set
    VENUE_CD = NEW_REFERENCES.VENUE_CD,
    CEREMONY_DT_ALIAS = NEW_REFERENCES.CEREMONY_DT_ALIAS,
    CEREMONY_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.CEREMONY_DAI_SEQUENCE_NUMBER,
    CLOSING_DT_ALIAS = NEW_REFERENCES.CLOSING_DT_ALIAS,
    CLOSING_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.CLOSING_DAI_SEQUENCE_NUMBER,
    CEREMONY_START_TIME = NEW_REFERENCES.CEREMONY_START_TIME,
    CEREMONY_END_TIME = NEW_REFERENCES.CEREMONY_END_TIME,
    CEREMONY_FEE = NEW_REFERENCES.CEREMONY_FEE,
    NUMBER_OF_GUESTS = NEW_REFERENCES.NUMBER_OF_GUESTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID
    );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_VENUE_CD in VARCHAR2,
  X_CEREMONY_DT_ALIAS in VARCHAR2,
  X_CEREMONY_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CLOSING_DT_ALIAS in VARCHAR2,
  X_CLOSING_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_START_TIME in DATE,
  X_CEREMONY_END_TIME in DATE,
  X_CEREMONY_FEE in NUMBER,
  X_NUMBER_OF_GUESTS in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_GR_CRMN_ALL
     where GRD_CAL_TYPE = X_GRD_CAL_TYPE
     and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
     and CEREMONY_NUMBER = X_CEREMONY_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GRD_CAL_TYPE,
     X_GRD_CI_SEQUENCE_NUMBER,
     X_CEREMONY_NUMBER,
     X_VENUE_CD,
     X_CEREMONY_DT_ALIAS,
     X_CEREMONY_DAI_SEQUENCE_NUMBER,
     X_CLOSING_DT_ALIAS,
     X_CLOSING_DAI_SEQUENCE_NUMBER,
     X_CEREMONY_START_TIME,
     X_CEREMONY_END_TIME,
     X_CEREMONY_FEE,
     X_NUMBER_OF_GUESTS,
     X_MODE,
     x_org_id
);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_GRD_CAL_TYPE,
   X_GRD_CI_SEQUENCE_NUMBER,
   X_CEREMONY_NUMBER,
   X_VENUE_CD,
   X_CEREMONY_DT_ALIAS,
   X_CEREMONY_DAI_SEQUENCE_NUMBER,
   X_CLOSING_DT_ALIAS,
   X_CLOSING_DAI_SEQUENCE_NUMBER,
   X_CEREMONY_START_TIME,
   X_CEREMONY_END_TIME,
   X_CEREMONY_FEE,
   X_NUMBER_OF_GUESTS,
   X_MODE
);
end ADD_ROW;

procedure DELETE_ROW (
   X_ROWID in VARCHAR2
) AS
begin

 Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );

  delete from IGS_GR_CRMN_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_GR_CRMN_PKG;

/
