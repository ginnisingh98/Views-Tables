--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_OFR_PAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_OFR_PAT_PKG" as
/* $Header: IGSPI87B.pls 120.1 2005/06/29 05:05:25 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_UNIT_OFR_PAT_ALL%RowType;
  new_references IGS_PS_UNIT_OFR_PAT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ci_start_dt IN DATE DEFAULT NULL,
    x_ci_end_dt IN DATE DEFAULT NULL,
    x_waitlist_allowed IN VARCHAR2 DEFAULT NULL,
    x_max_students_per_waitlist IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id  IN NUMBER DEFAULT NULL,
    X_DELETE_FLAG IN VARCHAR2 ,
    x_abort_flag  IN     VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_OFR_PAT_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.ci_start_dt := x_ci_start_dt;
    new_references.ci_end_dt := x_ci_end_dt;
    new_references.waitlist_allowed := x_waitlist_allowed;
    new_references.max_students_per_waitlist := x_max_students_per_waitlist;
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
    new_references.org_id := x_org_id;
    new_references.delete_flag := x_delete_flag;
    new_references.abort_flag := x_abort_flag;

  END Set_Column_Values;

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_unit_cd			IGS_PS_UNIT_OFR_PAT_ALL.unit_cd%TYPE;
	v_version_number		IGS_PS_UNIT_OFR_PAT_ALL.version_number%TYPE;
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Set variables.
	IF p_deleting THEN
		v_unit_cd := old_references.unit_cd;
		v_version_number := old_references.version_number;
	ELSE -- p_inserting or p_updating
		v_unit_cd := new_references.unit_cd;
		v_version_number := new_references.version_number;
	END IF;
	-- Validate the insert/update/delete.
	IF IGS_PS_VAL_UNIT.crsp_val_iud_uv_dtl (
			v_unit_cd,
			v_version_number,
v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	IF p_inserting THEN
		-- Validate the calendar instance status.
		IF IGS_aS_VAL_uai.crsp_val_crs_ci (
				new_references.cal_type,
				new_references.ci_sequence_number,
v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
		-- Validate calendar type.
		-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UOp.crsp_val_uo_cal_type
		IF IGS_AS_VAL_UAI.crsp_val_uo_cal_type (
				new_references.cal_type,
v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

PROCEDURE Check_Constraints(
  Column_Name IN	VARCHAR2 DEFAULT NULL,
  Column_Value IN	VARCHAR2 DEFAULT NULL)
AS
BEGIN

	IF Column_Name IS NULL Then
		NULL;
	ELSIF UPPER(column_name)='CAL_TYPE' Then
		New_References.Cal_Type := Column_Value;
	ELSIF UPPER(column_name)='UNIT_CD' Then
		New_References.Unit_Cd := Column_Value;
	ELSIF UPPER(column_name)='WAITLIST_ALLOWED' Then
		New_References.waitlist_allowed := Column_Value;
	ELSIF UPPER(column_name)='MAX_STUDENTS_PER_WAITLIST' Then
		New_References.max_students_per_waitlist := Column_Value;
	ELSIF UPPER(column_name)='DELETE_FLAG' THEN
		New_References.delete_flag := Column_Value;
	END IF;

	IF UPPER(column_name)='CAL_TYPE' OR Column_Name IS NULL Then
		IF New_References.Cal_Type <> UPPER(New_References.Cal_Type) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF UPPER(column_name)='UNIT_CD' OR Column_Name IS NULL Then
		IF New_References.Unit_Cd <> UPPER(New_References.Unit_CD) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF UPPER(column_name)='WAITLIST_ALLOWED' OR Column_Name IS NULL Then
		IF New_References.waitlist_allowed NOT IN ( 'Y' , 'N' ) Then
                       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                       IGS_GE_MSG_STACK.ADD;
                       App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF UPPER(column_name)='DELETE_FLAG' OR Column_Name IS NULL THEN
		IF New_References.delete_flag NOT IN ( 'Y' , 'N' ) THEN
                       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                       IGS_GE_MSG_STACK.ADD;
                       App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF UPPER(column_name)='ABORT_FLAG' OR Column_Name IS NULL THEN
		IF New_References.abort_flag NOT IN ( 'Y' , 'N' ) THEN
                       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                       IGS_GE_MSG_STACK.ADD;
                       App_Exception.Raise_Exception;
		END IF;
	END IF;



        IF UPPER(column_name)='MAX_STUDENTS_PER_WAITLIST' OR Column_Name IS NULL Then
                IF New_References.MAX_STUDENTS_PER_WAITLIST < 0 OR New_References.MAX_STUDENTS_PER_WAITLIST > 999999 Then
                           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                           IGS_GE_MSG_STACK.ADD;
                           App_Exception.Raise_Exception;
                END IF;
        END IF;

      IF Column_name is NULL THEN
        /* check for NOT NULL constraint in two new columns added in 115 */
        IF (new_references.waitlist_allowed is NULL)THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_PS_MAND_WLST_ALLOW');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;

        IF (new_references.max_students_per_waitlist is NULL)THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_PS_MAND_MAX_STDNT_WLST');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
      END IF;

END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.cal_type = new_references.cal_type) AND
          (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.ci_start_dt = new_references.ci_start_dt) AND
         (old_references.ci_end_dt = new_references.ci_end_dt)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.ci_start_dt IS NULL) OR
         (new_references.ci_end_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_UK_For_Validation (
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.ci_start_dt,
        new_references.ci_end_dt) THEN
				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_OFR_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.cal_type) THEN
				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_PS_APLINSTUNT_PKG.GET_FK_IGS_PS_UNIT_OFR_PAT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_AS_MARK_SHEET_PKG.GET_FK_IGS_PS_UNIT_OFR_PAT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_AS_NON_ENR_STDOT_PKG.GET_FK_IGS_PS_UNIT_OFR_PAT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_AS_UNITASS_ITEM_PKG.GET_FK_IGS_PS_UNIT_OFR_PAT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );


    IGS_PS_UNIT_OFR_OPT_PKG.GET_FK_IGS_PS_UNIT_OFR_PAT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_PS_UNT_OFR_PAT_N_PKG.GET_FK_IGS_PS_UNIT_OFR_PAT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_PS_UOFR_WLST_PRI_PKG.GET_FK_IGS_PS_UNIT_OFR_PAT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );
    IGS_PS_RSV_UOP_PRI_PKG.GET_FK_IGS_PS_UNIT_OFR_PAT(
       old_references.unit_cd,
       old_references.version_number,
       old_references.cal_type,
       old_references.ci_sequence_number);


  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_PAT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      delete_flag = 'N' ;
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

  END Get_PK_For_Validation;

  PROCEDURE GET_UFK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_PAT_ALL
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_sequence_number
      AND      ci_start_dt = x_start_dt
      AND      ci_end_dt = x_end_dt
      AND      delete_flag = 'N';

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UOP_CI_UFK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_PAT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      delete_flag = 'N';

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UOP_UO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_OFR;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ci_start_dt IN DATE DEFAULT NULL,
    x_ci_end_dt IN DATE DEFAULT NULL,
    x_waitlist_allowed IN VARCHAR2 DEFAULT NULL,
    x_max_students_per_waitlist IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    X_DELETE_FLAG IN VARCHAR2 ,
    x_abort_flag  IN     VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_ci_start_dt,
      x_ci_end_dt,
      x_waitlist_allowed,
      x_max_students_per_waitlist,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id,
      x_delete_flag,
      x_abort_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	   IF Get_PK_For_Validation (New_References.unit_cd,
					    New_References.version_number,
					    New_References.cal_type,
					    New_References.ci_sequence_number ) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	   END IF;
	   Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
	   Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	   IF Get_PK_For_Validation (New_References.unit_cd,
					    New_References.version_number,
					    New_References.cal_type,
					    New_References.ci_sequence_number ) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
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



  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_WAITLIST_ALLOWED in VARCHAR2,
  X_MAX_STUDENTS_PER_WAITLIST in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_DELETE_FLAG IN VARCHAR2 ,
  x_abort_flag  IN     VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_PS_UNIT_OFR_PAT_ALL
      where UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
      and CAL_TYPE = X_CAL_TYPE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
    l_c_rowid  ROWID;

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


  Before_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID,
  x_unit_cd => X_UNIT_CD,
  x_version_number => X_VERSION_NUMBER,
  x_cal_type => X_CAL_TYPE,
  x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
  x_ci_start_dt => X_CI_START_DT,
  x_ci_end_dt => X_CI_END_DT,
  x_waitlist_allowed => X_WAITLIST_ALLOWED,
  x_max_students_per_waitlist => X_MAX_STUDENTS_PER_WAITLIST,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_delete_flag => x_delete_flag,
  x_abort_flag  => x_abort_flag
  );

  OPEN C;
  FETCH C INTO l_c_rowid;
  IF C%NOTFOUND THEN
    CLOSE C;
    INSERT INTO IGS_PS_UNIT_OFR_PAT_ALL (
      UNIT_CD,
      VERSION_NUMBER,
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      CI_START_DT,
      CI_END_DT,
      WAITLIST_ALLOWED,
      MAX_STUDENTS_PER_WAITLIST,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE,
      ORG_ID,
      DELETE_FLAG,
      ABORT_FLAG
      ) VALUES (
      NEW_REFERENCES.UNIT_CD,
      NEW_REFERENCES.VERSION_NUMBER,
      NEW_REFERENCES.CAL_TYPE,
      NEW_REFERENCES.CI_SEQUENCE_NUMBER,
      NEW_REFERENCES.CI_START_DT,
      NEW_REFERENCES.CI_END_DT,
      NEW_REFERENCES.WAITLIST_ALLOWED,
      NEW_REFERENCES.MAX_STUDENTS_PER_WAITLIST,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_REQUEST_ID,
      X_PROGRAM_ID,
      X_PROGRAM_APPLICATION_ID,
      X_PROGRAM_UPDATE_DATE,
      NEW_REFERENCES.ORG_ID,
      NEW_REFERENCES.DELETE_FLAG,
      NEW_REFERENCES.ABORT_FLAG
      );
  ELSE
    CLOSE C;
    UPDATE IGS_PS_UNIT_OFR_PAT_ALL SET
      WAITLIST_ALLOWED=NEW_REFERENCES.WAITLIST_ALLOWED,
      MAX_STUDENTS_PER_WAITLIST=NEW_REFERENCES.MAX_STUDENTS_PER_WAITLIST,
      CREATION_DATE=X_LAST_UPDATE_DATE,
      CREATED_BY=X_LAST_UPDATED_BY,
      LAST_UPDATE_DATE=X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY=X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN=X_LAST_UPDATE_LOGIN,
      REQUEST_ID=X_REQUEST_ID,
      PROGRAM_ID=X_PROGRAM_ID,
      PROGRAM_APPLICATION_ID=X_PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE=X_PROGRAM_UPDATE_DATE,
      DELETE_FLAG = 'N',
      abort_flag = new_references.abort_flag
    WHERE ROWID=l_c_rowid;
  END IF;


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
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_WAITLIST_ALLOWED in VARCHAR2,
  X_MAX_STUDENTS_PER_WAITLIST  in NUMBER,
  X_DELETE_FLAG IN VARCHAR2 ,
  x_abort_flag  IN     VARCHAR2
) AS
  cursor c1 is select
      CI_START_DT,
      CI_END_DT,
      WAITLIST_ALLOWED,
      MAX_STUDENTS_PER_WAITLIST,
      DELETE_FLAG,
      abort_flag
    from IGS_PS_UNIT_OFR_PAT_ALL
    where ROWID = X_ROWID for update nowait;
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

  if (    (tlinfo.CI_START_DT = X_CI_START_DT)
      AND (tlinfo.CI_END_DT = X_CI_END_DT)
      AND ((tlinfo.WAITLIST_ALLOWED = X_WAITLIST_ALLOWED)
            OR ((tlinfo.WAITLIST_ALLOWED IS NULL) AND (X_WAITLIST_ALLOWED IS NULL)))
      AND ((tlinfo.DELETE_FLAG = X_DELETE_FLAG)
            OR ((tlinfo.DELETE_FLAG IS NULL) AND (X_DELETE_FLAG IS NULL)))
      AND ((tlinfo.MAX_STUDENTS_PER_WAITLIST = X_MAX_STUDENTS_PER_WAITLIST)
            OR ((tlinfo.MAX_STUDENTS_PER_WAITLIST IS NULL) AND (X_MAX_STUDENTS_PER_WAITLIST IS NULL)))
      AND (tlinfo.ABORT_FLAG = X_ABORT_FLAG)
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
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_WAITLIST_ALLOWED in VARCHAR2,
  X_MAX_STUDENTS_PER_WAITLIST in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_DELETE_FLAG IN VARCHAR2 ,
  x_abort_flag  IN     VARCHAR2
  ) AS
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
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_unit_cd => X_UNIT_CD,
  x_version_number => X_VERSION_NUMBER,
  x_cal_type => X_CAL_TYPE,
  x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
  x_ci_start_dt => X_CI_START_DT,
  x_ci_end_dt => X_CI_END_DT,
  x_waitlist_allowed => X_WAITLIST_ALLOWED,
  x_max_students_per_waitlist => X_MAX_STUDENTS_PER_WAITLIST,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_delete_flag =>  X_DELETE_FLAG,
  x_abort_flag  =>  x_abort_flag
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
  end if;

  IF x_delete_flag = 'Y' THEN
    Check_Child_Existance;
  END IF;

  update IGS_PS_UNIT_OFR_PAT_ALL set
    CI_START_DT = NEW_REFERENCES.CI_START_DT,
    CI_END_DT = NEW_REFERENCES.CI_END_DT,
    WAITLIST_ALLOWED = NEW_REFERENCES.WAITLIST_ALLOWED,
    MAX_STUDENTS_PER_WAITLIST = NEW_REFERENCES.MAX_STUDENTS_PER_WAITLIST,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    DELETE_FLAG = NEW_REFERENCES.DELETE_flag,
    ABORT_FLAG = NEW_REFERENCES.ABORT_FLAG
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
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_WAITLIST_ALLOWED in VARCHAR2,
  X_MAX_STUDENTS_PER_WAITLIST in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_DELETE_FLAG IN VARCHAR2 ,
  x_abort_flag  IN     VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_PS_UNIT_OFR_PAT_ALL
     where UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and CAL_TYPE = X_CAL_TYPE
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
     X_CI_SEQUENCE_NUMBER,
     X_CAL_TYPE,
     X_CI_START_DT,
     X_CI_END_DT,
     X_WAITLIST_ALLOWED,
     X_MAX_STUDENTS_PER_WAITLIST,
     X_MODE,
     X_ORG_ID,
     X_DELETE_FLAG,
     x_abort_flag);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_CI_SEQUENCE_NUMBER,
   X_CAL_TYPE,
   X_CI_START_DT,
   X_CI_END_DT,
   X_WAITLIST_ALLOWED,
   X_MAX_STUDENTS_PER_WAITLIST,
   X_MODE,
   X_DELETE_FLAG,
   x_abort_flag
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
  delete from IGS_PS_UNIT_OFR_PAT_ALL
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

end DELETE_ROW;

end IGS_PS_UNIT_OFR_PAT_PKG;

/
