--------------------------------------------------------
--  DDL for Package Body IGS_AS_UNIT_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_UNIT_CLASS_PKG" as
/* $Header: IGSDI34B.pls 120.0 2005/07/05 12:10:42 appldev noship $ */
--
  l_rowid VARCHAR2(25);
  old_references IGS_AS_UNIT_CLASS_ALL%RowType;
  new_references IGS_AS_UNIT_CLASS_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_day_of_week IN VARCHAR2 DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_UNIT_CLASS_ALL
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
    new_references.org_id:= x_org_id;
    new_references.unit_class:= x_unit_class;
    new_references.unit_mode:= x_unit_mode;
    new_references.description := x_description;
    new_references.day_of_week := x_day_of_week;
    new_references.start_time := x_start_time;
    new_references.end_time := x_end_time;
    new_references.closed_ind := x_closed_ind;
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
  -- "OSS_TST".trg_ucl_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AS_UNIT_CLASS
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE
    ) as
   v_message_name  varchar2(30);
	cst_null_datetime	DATE ;
  BEGIN
        cst_null_datetime := IGS_GE_DATE.IGSDATE('1900/01/01');
	-- Validate IGS_PS_UNIT mode. Also validate IGS_PS_UNIT mode if the closed
	-- indicator has been updated from closed to open to verify
	-- that the IGS_PS_UNIT mode is not closed.
	IF p_inserting OR
		(old_references.unit_mode<> new_references.unit_mode)	OR
		((old_references.closed_ind = 'N')		AND
		( new_references.closed_ind = 'Y')) THEN
		IF IGS_PS_VAL_UCl.crsp_val_ucl_um (
			new_references.unit_mode,
			v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate start and end times
	IF p_inserting OR
		(NVL(old_references.start_time,cst_null_datetime) <>
		NVL(new_references.start_time,cst_null_datetime)	OR
		NVL(old_references.end_time,cst_null_datetime) <>
		NVL(new_references.end_time,cst_null_datetime)) THEN
		IF IGS_PS_VAL_UCl.crsp_val_ucl_st_end (
			new_references.start_time,
			new_references.end_time,
			v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance as
  BEGIN
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
  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
	) as
BEGIN

      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'DAY_OF_WEEK' then
         new_references.day_of_week:= column_value;
      ELSIF upper(Column_name) = 'CLOSED_IND' then
         new_references.closed_ind:= column_value;
      ELSIF upper(Column_name) = 'UNIT_CLASS' then
         new_references.unit_class:= column_value;
      ELSIF upper(Column_name) = 'UNIT_MODE' then
         new_references.unit_mode:= column_value;
      END IF;

     IF upper(column_name) = 'DAY_OF_WEEK' OR
        column_name is null Then
        IF new_references.day_of_week <> UPPER(new_references.day_of_week) OR new_references.day_of_week NOT IN ( 'MONDAY' , 'TUESDAY' , 'WEDNESDAY' , 'THURSDAY' , 'FRIDAY' , 'SATURDAY' , 'SUNDAY' ) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'CLOSED_IND' OR
        column_name is null Then
        IF new_references.closed_ind <> UPPER(new_references.closed_ind) OR new_references.closed_ind NOT IN ( 'Y' , 'N' ) Then
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
     IF upper(column_name) = 'UNIT_MODE' OR
        column_name is null Then
        IF new_references.unit_mode <> UPPER(new_references.unit_mode) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
END Check_Constraints;


  FUNCTION   Get_PK_For_Validation (
    x_unit_class IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNIT_CLASS_ALL
      WHERE    unit_class= x_unit_class;
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
  PROCEDURE GET_FK_IGS_AS_UNIT_MODE (
    x_unit_mode IN VARCHAR2
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNIT_CLASS_ALL
      WHERE    unit_mode= x_unit_mode ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_UCL_UM_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_UNIT_MODE;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_day_of_week IN VARCHAR2 DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE  DEFAULT NULL,
    x_created_by IN NUMBER  DEFAULT NULL,
    x_last_update_date IN DATE  DEFAULT NULL,
    x_last_updated_by IN NUMBER  DEFAULT NULL,
    x_last_update_login IN NUMBER  DEFAULT NULL
  ) as
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_unit_class,
      x_unit_mode,
      x_description,
      x_day_of_week,
      x_start_time,
      x_end_time,
      x_closed_ind,
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
             new_references.unit_class
			             ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
       IF  Get_PK_For_Validation (
             new_references.unit_class
			             ) THEN
           Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
       END IF;
       Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
    END IF;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DAY_OF_WEEK in VARCHAR2,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_AS_UNIT_CLASS_ALL
      where UNIT_CLASS = X_UNIT_CLASS;
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
--
  Before_DML(
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_org_id => igs_ge_gen_003.get_org_id,
   x_closed_ind=>nvl(X_CLOSED_IND,'N'),
   x_day_of_week=>X_DAY_OF_WEEK,
   x_description=>X_DESCRIPTION,
   x_end_time=>X_END_TIME,
   x_start_time=>X_START_TIME,
   x_unit_class=>X_UNIT_CLASS,
   x_unit_mode=>X_UNIT_MODE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
--
  insert into IGS_AS_UNIT_CLASS_ALL (
    ORG_ID,
    UNIT_CLASS,
    UNIT_MODE,
    DESCRIPTION,
    DAY_OF_WEEK,
    START_TIME,
    END_TIME,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.UNIT_MODE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.DAY_OF_WEEK,
    NEW_REFERENCES.START_TIME,
    NEW_REFERENCES.END_TIME,
    NEW_REFERENCES.CLOSED_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
--
--
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DAY_OF_WEEK in VARCHAR2,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CLOSED_IND in VARCHAR2
) as
  cursor c1 is select
      UNIT_MODE,
      DESCRIPTION,
      DAY_OF_WEEK,
      START_TIME,
      END_TIME,
      CLOSED_IND
    from IGS_AS_UNIT_CLASS_ALL
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
  if ( (tlinfo.UNIT_MODE = X_UNIT_MODE)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.DAY_OF_WEEK = X_DAY_OF_WEEK)
           OR ((tlinfo.DAY_OF_WEEK is null)
               AND (X_DAY_OF_WEEK is null)))
      AND ((tlinfo.START_TIME = X_START_TIME)
           OR ((tlinfo.START_TIME is null)
               AND (X_START_TIME is null)))
      AND ((tlinfo.END_TIME = X_END_TIME)
           OR ((tlinfo.END_TIME is null)
               AND (X_END_TIME is null)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DAY_OF_WEEK in VARCHAR2,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
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
--
  Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_closed_ind=>X_CLOSED_IND,
   x_day_of_week=>X_DAY_OF_WEEK,
   x_description=>X_DESCRIPTION,
   x_end_time=>X_END_TIME,
   x_start_time=>X_START_TIME,
   x_unit_class=>X_UNIT_CLASS,
   x_unit_mode=>X_UNIT_MODE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
--
  update IGS_AS_UNIT_CLASS_ALL set
    UNIT_MODE = NEW_REFERENCES.UNIT_MODE,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    DAY_OF_WEEK = NEW_REFERENCES.DAY_OF_WEEK,
    START_TIME = NEW_REFERENCES.START_TIME,
    END_TIME = NEW_REFERENCES.END_TIME,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
--
--
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DAY_OF_WEEK in VARCHAR2,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AS_UNIT_CLASS_ALL
     where UNIT_CLASS = X_UNIT_CLASS
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_UNIT_CLASS,
     X_UNIT_MODE,
     X_DESCRIPTION,
     X_DAY_OF_WEEK,
     X_START_TIME,
     X_END_TIME,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_CLASS,
   X_UNIT_MODE,
   X_DESCRIPTION,
   X_DAY_OF_WEEK,
   X_START_TIME,
   X_END_TIME,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;
end IGS_AS_UNIT_CLASS_PKG;

/
