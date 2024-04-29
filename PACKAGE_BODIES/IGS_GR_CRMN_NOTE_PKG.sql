--------------------------------------------------------
--  DDL for Package Body IGS_GR_CRMN_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_CRMN_NOTE_PKG" as
/* $Header: IGSGI09B.pls 115.6 2002/11/29 00:35:52 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_CRMN_NOTE_ALL%RowType;
  new_references IGS_GR_CRMN_NOTE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_grd_note_type IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_CRMN_NOTE_ALL
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
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.ceremony_number := x_ceremony_number;
    new_references.reference_number := x_reference_number;
    new_references.grd_note_type := x_grd_note_type;
    new_references.grd_cal_type := x_grd_cal_type;
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

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number) AND
         (old_references.ceremony_number = new_references.ceremony_number)) OR
        ((new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL) OR
         (new_references.ceremony_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_CRMN_PKG.Get_PK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number,
        new_references.ceremony_number
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

    IF (((old_references.grd_note_type = new_references.grd_note_type)) OR
        ((new_references.grd_note_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_NOTE_TYPE_PKG.Get_PK_For_Validation (
        new_references.grd_note_type
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

    IF (((old_references.reference_number = new_references.reference_number)) OR
        ((new_references.reference_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_NOTE_PKG.Get_PK_For_Validation (
        new_references.reference_number
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
ELSIF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' THEN
  new_references.GRD_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'GRD_CAL_TYPE' THEN
  new_references.GRD_CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRD_NOTE_TYPE' THEN
  new_references.GRD_NOTE_TYPE:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CI_SEQUENCE_NUMBER <1 OR NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER > 999999 then
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

IF upper(Column_name) = 'GRD_NOTE_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_NOTE_TYPE<> upper(NEW_REFERENCES.GRD_NOTE_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
  END;

  FUNCTION Get_PK_For_Validation (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER,
    x_reference_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_NOTE_ALL
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number
      AND      reference_number = x_reference_number
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

  PROCEDURE GET_FK_IGS_GR_CRMN (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_NOTE_ALL
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GCN_GC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_CRMN;

  PROCEDURE GET_FK_IGS_GR_NOTE_TYPE (
    x_grd_note_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_NOTE_ALL
      WHERE    grd_note_type = x_grd_note_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GCN_GNT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_NOTE_TYPE;

  PROCEDURE GET_FK_IGS_GE_NOTE (
    x_reference_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_NOTE_ALL
      WHERE    reference_number = x_reference_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GCN_NOTE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_NOTE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_grd_note_type IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
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
      x_grd_ci_sequence_number,
      x_ceremony_number,
      x_reference_number,
      x_grd_note_type,
      x_grd_cal_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF GET_PK_FOR_VALIDATION(
		NEW_REFERENCES.grd_cal_type,
		NEW_REFERENCES.grd_ci_sequence_number,
    		NEW_REFERENCES.ceremony_number,
    		NEW_REFERENCES.reference_number
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
		NEW_REFERENCES.grd_cal_type,
		NEW_REFERENCES.grd_ci_sequence_number,
    		NEW_REFERENCES.ceremony_number,
    		NEW_REFERENCES.reference_number
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	check_constraints;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_GRD_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_GR_CRMN_NOTE_ALL
      where GRD_CAL_TYPE = X_GRD_CAL_TYPE
      and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
      and CEREMONY_NUMBER = X_CEREMONY_NUMBER
      and REFERENCE_NUMBER = X_REFERENCE_NUMBER;
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
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_reference_number => X_REFERENCE_NUMBER,
    x_grd_note_type => X_GRD_NOTE_TYPE,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN,
     x_org_id => igs_ge_gen_003.get_org_id
  );

  insert into IGS_GR_CRMN_NOTE_ALL (
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER,
    REFERENCE_NUMBER,
    GRD_NOTE_TYPE,
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
    NEW_REFERENCES.REFERENCE_NUMBER,
    NEW_REFERENCES.GRD_NOTE_TYPE,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_GRD_NOTE_TYPE in VARCHAR2
) AS
  cursor c1 is select
      GRD_NOTE_TYPE
    from IGS_GR_CRMN_NOTE_ALL
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

  if ( (tlinfo.GRD_NOTE_TYPE = X_GRD_NOTE_TYPE)

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
  X_REFERENCE_NUMBER in NUMBER,
  X_GRD_NOTE_TYPE in VARCHAR2,
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
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_reference_number => X_REFERENCE_NUMBER,
    x_grd_note_type => X_GRD_NOTE_TYPE,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_CRMN_NOTE_ALL set
    GRD_NOTE_TYPE = NEW_REFERENCES.GRD_NOTE_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_GRD_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_GR_CRMN_NOTE_ALL
     where GRD_CAL_TYPE = X_GRD_CAL_TYPE
     and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
     and CEREMONY_NUMBER = X_CEREMONY_NUMBER
     and REFERENCE_NUMBER = X_REFERENCE_NUMBER
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
     X_REFERENCE_NUMBER,
     X_GRD_NOTE_TYPE,
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
   X_REFERENCE_NUMBER,
   X_GRD_NOTE_TYPE,
   X_MODE
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  delete from IGS_GR_CRMN_NOTE_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_GR_CRMN_NOTE_PKG;

/
