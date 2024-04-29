--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_AS_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_AS_RT_PKG" as
/* $Header: IGSSI20B.pls 120.2 2006/05/26 13:42:06 skharida ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_AS_RT%RowType;
  new_references IGS_FI_FEE_AS_RT%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_chg_rate IN NUMBER DEFAULT NULL,
    x_lower_nrml_rate_ovrd_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_AS_RT
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
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.fee_type := x_fee_type;
    new_references.start_dt := x_start_dt;
    new_references.end_dt := x_end_dt;
    new_references.location_cd := x_location_cd;
    new_references.attendance_type := x_attendance_type;
    new_references.attendance_mode := x_attendance_mode;
    new_references.chg_rate := x_chg_rate;
    new_references.lower_nrml_rate_ovrd_ind := x_lower_nrml_rate_ovrd_ind;
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
  -- "OSS_TST".trg_cfar_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_FI_FEE_AS_RT
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate contract fee assessment rate
	IF p_inserting THEN
		IF  IGS_FI_VAL_CFAR.finp_val_cfar_ins(
					new_references.person_id,
					new_references.course_cd,
					new_references.fee_type,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR
	  (p_updating AND new_references.end_dt IS NOT NULL AND
	  (new_references.start_dt <> old_references.start_dt OR new_references.end_dt <> old_references.end_dt)) THEN
		IF IGS_FI_VAL_CFAR.finp_val_cfar_end_dt(
					new_references.start_dt,
					new_references.end_dt,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
	  new_references.fee_type <> old_references.fee_type) THEN
		IF  IGS_FI_VAL_CFAR.finp_val_ft_closed(
					new_references.fee_type,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
	  new_references.attendance_type <> old_references.attendance_type) THEN
		IF  IGS_FI_VAL_CFAR.finp_val_att_closed(
					new_references.attendance_type,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
	  new_references.attendance_mode <> old_references.attendance_mode) THEN
		IF  IGS_FI_VAL_CFAR.finp_val_am_closed(
					new_references.attendance_mode,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
	  new_references.location_cd <> old_references.location_cd) THEN
		IF  IGS_FI_VAL_CFAR.finp_val_loc_closed(
					new_references.location_cd,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_cfar_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_FI_FEE_AS_RT
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  BEGIN
	-- create a history
	IGS_FI_GEN_002.finp_ins_cfar_hist(old_references.person_id,
		old_references.course_cd,
		old_references.fee_type,
		old_references.start_dt,
		new_references.end_dt,
		old_references.end_dt,
		new_references.location_cd,
		old_references.location_cd,
		new_references.attendance_type,
		old_references.attendance_type,
		new_references.attendance_mode,
		old_references.attendance_mode,
		new_references.chg_rate,
		old_references.chg_rate,
		new_references.lower_nrml_rate_ovrd_ind,
		old_references.lower_nrml_rate_ovrd_ind,
		new_references.last_updated_by,
		old_references.last_updated_by,
		new_references.last_update_date,
		old_references.last_update_date);
  END AfterRowUpdate3;
  -- Trigger description :-
  -- "OSS_TST".trg_cfar_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_FI_FEE_AS_RT
  PROCEDURE AfterStmtInsertUpdate4(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate the start and end dates
  	IF p_inserting OR p_updating THEN
  		IF  new_references.end_dt IS NULL THEN
  			IF IGS_FI_VAL_CFAR.finp_val_cfar_open (
  				              new_references.person_id,
  		    		              new_references.course_cd,
  				              new_references.fee_type,
  		    		              new_references.start_dt,
  				              v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
                                 IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
  			END IF;
  		END IF;
  		IF IGS_FI_VAL_CFAR.finp_val_cfar_ovrlp (
  			              new_references.person_id,
  		    	              new_references.course_cd,
  			              new_references.fee_type,
  		    	              new_references.start_dt,
  			              new_references.end_dt,
  			              v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
  	END IF;
  END AfterStmtInsertUpdate4;
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
  ||  skharida        26-May-2006   Bug 5217319 Removed the hardcoded precision check
  ||  vvutukur        17-May-2002   removed upper check on fee_type column.bug#2344826.
  ----------------------------------------------------------------------------*/
 BEGIN
  IF  column_name is null then
     NULL;
  ELSIF upper(Column_name) = 'CHG_RATE' then
     new_references.chg_rate := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'ATTENDANCE_MODE' then
     new_references.attendance_mode := column_value;
  ELSIF upper(Column_name) = 'ATTENDANCE_TYPE' then
     new_references.attendance_type := column_value;
  ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
  ELSIF upper(Column_name) = 'LOCATION_CD' then
     new_references.location_cd := column_value;
  ELSIF upper(Column_name) = 'LOWER_NRML_RATE_OVRD_IND' then
     new_references.lower_nrml_rate_ovrd_ind := column_value;
  End if;

  IF upper(column_name) = 'CHG_RATE' OR
       column_name is null Then
       IF new_references.chg_rate  < 0 Then
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
  END IF;

  IF upper(column_name) = 'ATTENDANCE_MODE' OR
       column_name is null Then
       IF new_references.attendance_mode <>
  	UPPER(new_references.attendance_mode) Then
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
  END IF;

IF upper(column_name) = 'ATTENDANCE_TYPE' OR
     column_name is null Then
     IF new_references.ATTENDANCE_TYPE <>
	UPPER(new_references.ATTENDANCE_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.COURSE_CD <>
	UPPER(new_references.COURSE_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'LOCATION_CD' OR
     column_name is null Then
     IF new_references.LOCATION_CD <>
	UPPER(new_references.LOCATION_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'LOWER_NRML_RATE_OVRD_IND' OR
     column_name is null Then
     IF new_references.LOWER_NRML_RATE_OVRD_IND <>
	UPPER(new_references.LOWER_NRML_RATE_OVRD_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'LOWER_NRML_RATE_OVRD_IND' OR
     column_name is null Then
     IF (new_references.lower_nrml_rate_ovrd_ind not in ('Y', 'N')) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
  END Check_Constraints;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.attendance_mode = new_references.attendance_mode)) OR
        ((new_references.attendance_mode IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_EN_ATD_MODE_PKG.Get_PK_For_Validation (
        new_references.attendance_mode
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.attendance_type
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
    IF (((old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_type IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_FI_FEE_TYPE_PKG.Get_PK_For_Validation (
        new_references.fee_type
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd ,
        'N'
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;
  Function Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_fee_type IN VARCHAR2,
    x_start_dt IN DATE
    ) Return Boolean
	AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      fee_type = x_fee_type
      AND      start_dt = x_start_dt
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
  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RT
      WHERE    attendance_mode = x_attendance_mode ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_CFAR_AM_FK');
         IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_ATD_MODE;
  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RT
      WHERE    attendance_type = x_attendance_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_CFAR_ATT_FK');
         IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RT
      WHERE    location_cd = x_location_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_CFAR_LOC_FK');
         IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_LOCATION;
  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_CFAR_SCA_FK');
         IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_STDNT_PS_ATT;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_chg_rate IN NUMBER DEFAULT NULL,
    x_lower_nrml_rate_ovrd_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_fee_type,
      x_start_dt,
      x_end_dt,
      x_location_cd,
      x_attendance_type,
      x_attendance_mode,
      x_chg_rate,
      x_lower_nrml_rate_ovrd_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	  	IF  Get_PK_For_Validation (
			new_references.person_id ,
			new_references.course_cd ,
			new_references.fee_type ,
    		new_references.start_dt
	  	    ) THEN
	  	         Fnd_Message.Set_Name ('IGS', 'IGS_FI_CONTRACT_EXISTS_FEETYP');
                          IGS_GE_MSG_STACK.ADD;
	  	          App_Exception.Raise_Exception;
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
      Null;
	  ELSIF (p_action = 'VALIDATE_INSERT') THEN
	        IF  Get_PK_For_Validation (
			new_references.person_id ,
			new_references.course_cd ,
			new_references.fee_type ,
    		new_references.start_dt
			) THEN
	           Fnd_Message.Set_Name ('IGS', 'IGS_FI_CONTRACT_EXISTS_FEETYP');
                   IGS_GE_MSG_STACK.ADD;
	            App_Exception.Raise_Exception;
	        END IF;
	        Check_Constraints;
	  ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	         Check_Constraints;
	  ELSIF (p_action = 'VALIDATE_DELETE') THEN
	        Null;
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
      AfterStmtInsertUpdate4 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate3 ( p_updating => TRUE );
      AfterStmtInsertUpdate4 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CHG_RATE in NUMBER,
  X_LOWER_NRML_RATE_OVRD_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_FI_FEE_AS_RT
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and FEE_TYPE = X_FEE_TYPE
      and START_DT = X_START_DT;
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
  elsif (X_MODE IN ('R', 'S')) then
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
    if (X_REQUEST_ID =  -1) then
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
 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_chg_rate=>X_CHG_RATE,
  x_course_cd=>X_COURSE_CD,
  x_end_dt=>X_END_DT,
  x_fee_type=>X_FEE_TYPE,
  x_location_cd=>X_LOCATION_CD,
  x_lower_nrml_rate_ovrd_ind=>NVL(X_LOWER_NRML_RATE_OVRD_IND,'N'),
  x_person_id=>X_PERSON_ID,
  x_start_dt=>X_START_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_FI_FEE_AS_RT (
    PERSON_ID,
    COURSE_CD,
    FEE_TYPE,
    START_DT,
    END_DT,
    LOCATION_CD,
    ATTENDANCE_TYPE,
    ATTENDANCE_MODE,
    CHG_RATE,
    LOWER_NRML_RATE_OVRD_IND,
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
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.CHG_RATE,
    NEW_REFERENCES.LOWER_NRML_RATE_OVRD_IND,
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
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
After_DML(
 p_action => 'INSERT',
 x_rowid  => X_ROWID
);
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CHG_RATE in NUMBER,
  X_LOWER_NRML_RATE_OVRD_IND in VARCHAR2
) as
  cursor c1 is select
      END_DT,
      LOCATION_CD,
      ATTENDANCE_TYPE,
      ATTENDANCE_MODE,
      CHG_RATE,
      LOWER_NRML_RATE_OVRD_IND
    from IGS_FI_FEE_AS_RT
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
      if ( ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE is null)
               AND (X_ATTENDANCE_TYPE is null)))
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE is null)
               AND (X_ATTENDANCE_MODE is null)))
      AND (tlinfo.CHG_RATE = X_CHG_RATE)
      AND (tlinfo.LOWER_NRML_RATE_OVRD_IND = X_LOWER_NRML_RATE_OVRD_IND)
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
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CHG_RATE in NUMBER,
  X_LOWER_NRML_RATE_OVRD_IND in VARCHAR2,
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
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_chg_rate=>X_CHG_RATE,
  x_course_cd=>X_COURSE_CD,
  x_end_dt=>X_END_DT,
  x_fee_type=>X_FEE_TYPE,
  x_location_cd=>X_LOCATION_CD,
  x_lower_nrml_rate_ovrd_ind=>X_LOWER_NRML_RATE_OVRD_IND,
  x_person_id=>X_PERSON_ID,
  x_start_dt=>X_START_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID =  -1) then
      X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
      X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_FI_FEE_AS_RT set
    END_DT = NEW_REFERENCES.END_DT,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    CHG_RATE = NEW_REFERENCES.CHG_RATE,
    LOWER_NRML_RATE_OVRD_IND = NEW_REFERENCES.LOWER_NRML_RATE_OVRD_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML(
 p_action => 'UPDATE',
 x_rowid  => X_ROWID
);
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CHG_RATE in NUMBER,
  X_LOWER_NRML_RATE_OVRD_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_FI_FEE_AS_RT
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and FEE_TYPE = X_FEE_TYPE
     and START_DT = X_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_FEE_TYPE,
     X_START_DT,
     X_END_DT,
     X_LOCATION_CD,
     X_ATTENDANCE_TYPE,
     X_ATTENDANCE_MODE,
     X_CHG_RATE,
     X_LOWER_NRML_RATE_OVRD_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_FEE_TYPE,
   X_START_DT,
   X_END_DT,
   X_LOCATION_CD,
   X_ATTENDANCE_TYPE,
   X_ATTENDANCE_MODE,
   X_CHG_RATE,
   X_LOWER_NRML_RATE_OVRD_IND,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) as
begin
Before_DML(
 p_action => 'DELETE',
 x_rowid  => X_ROWID
);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_FI_FEE_AS_RT
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML(
 p_action => 'DELETE',
 x_rowid  => X_ROWID
);
END delete_row;
END igs_fi_fee_as_rt_pkg;

/
