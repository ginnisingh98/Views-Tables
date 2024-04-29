--------------------------------------------------------
--  DDL for Package Body IGS_PR_S_CRV_PRG_CAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_S_CRV_PRG_CAL_PKG" as
/* $Header: IGSQI21B.pls 115.3 2002/11/29 03:19:23 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PR_S_CRV_PRG_CAL%RowType;
  new_references IGS_PR_S_CRV_PRG_CAL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_stream_num IN NUMBER DEFAULT NULL,
    x_show_cause_length IN NUMBER DEFAULT NULL,
    x_appeal_length IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_S_CRV_PRG_CAL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.prg_cal_type := x_prg_cal_type;
    new_references.stream_num := x_stream_num;
    new_references.show_cause_length := x_show_cause_length;
    new_references.appeal_length := x_appeal_length;
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
  -- "OSS_TST".trg_scpca_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_PR_S_CRV_PRG_CAL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate the progression calendar type
	IF p_inserting THEN
		IF IGS_PR_VAL_SCPCA.prgp_val_cfg_cat (
					new_references.prg_cal_type,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the show cause length
	IF p_inserting OR (p_updating AND
	   new_references.show_cause_length <> old_references.show_cause_length) THEN
		IF IGS_PR_VAL_SCPCA.prgp_val_scpca_cause (
					new_references.course_cd,
					new_references.version_number,
					new_references.show_cause_length,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the appeal length
	IF p_inserting OR (p_updating AND
	   new_references.appeal_length <> old_references.appeal_length) THEN
		IF IGS_PR_VAL_SCPCA.prgp_val_scpca_apl (
					new_references.course_cd,
					new_references.version_number,
					new_references.appeal_length,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.prg_cal_type = new_references.prg_cal_type)) OR
        ((new_references.prg_cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_TYPE_PKG.Get_PK_For_Validation (
        new_references.prg_cal_type
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
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
      IF NOT IGS_PR_S_CRV_PRG_CON_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_prg_cal_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_S_CRV_PRG_CAL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      prg_cal_type = x_prg_cal_type
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close Cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_S_CRV_PRG_CAL
      WHERE    prg_cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SCPCA_CAT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_TYPE;

  PROCEDURE GET_FK_IGS_PR_S_CRV_PRG_CON (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_S_CRV_PRG_CAL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SCPCA_SCPC_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_S_CRV_PRG_CON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_stream_num IN NUMBER DEFAULT NULL,
    x_show_cause_length IN NUMBER DEFAULT NULL,
    x_appeal_length IN NUMBER DEFAULT NULL,
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
      x_course_cd,
      x_version_number,
      x_prg_cal_type,
      x_stream_num,
      x_show_cause_length,
      x_appeal_length,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
         new_references.course_cd,
         new_references.version_number,
         new_references.prg_cal_type
         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation (
         new_references.course_cd,
         new_references.version_number,
         new_references.prg_cal_type
         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_STREAM_NUM in NUMBER,
  X_SHOW_CAUSE_LENGTH in NUMBER,
  X_APPEAL_LENGTH in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_PR_S_CRV_PRG_CAL
      where COURSE_CD = X_COURSE_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and PRG_CAL_TYPE = X_PRG_CAL_TYPE;
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

    Before_DML(
     p_action => 'INSERT',
     x_rowid => X_ROWID,
     x_appeal_length => X_APPEAL_LENGTH,
     x_course_cd => X_COURSE_CD,
     x_prg_cal_type => X_PRG_CAL_TYPE,
     x_show_cause_length => X_SHOW_CAUSE_LENGTH,
     x_stream_num => X_STREAM_NUM,
     x_version_number => X_VERSION_NUMBER,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
     );

  insert into IGS_PR_S_CRV_PRG_CAL (
    COURSE_CD,
    VERSION_NUMBER,
    PRG_CAL_TYPE,
    STREAM_NUM,
    SHOW_CAUSE_LENGTH,
    APPEAL_LENGTH,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.PRG_CAL_TYPE,
    NEW_REFERENCES.STREAM_NUM,
    NEW_REFERENCES.SHOW_CAUSE_LENGTH,
    NEW_REFERENCES.APPEAL_LENGTH,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_STREAM_NUM in NUMBER,
  X_SHOW_CAUSE_LENGTH in NUMBER,
  X_APPEAL_LENGTH in NUMBER
) as
  cursor c1 is select
      STREAM_NUM,
      SHOW_CAUSE_LENGTH,
      APPEAL_LENGTH
    from IGS_PR_S_CRV_PRG_CAL
    where ROWID = X_ROWID
    for update nowait;
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

  if ( (tlinfo.STREAM_NUM = X_STREAM_NUM)
      AND ((tlinfo.SHOW_CAUSE_LENGTH = X_SHOW_CAUSE_LENGTH)
           OR ((tlinfo.SHOW_CAUSE_LENGTH is null)
               AND (X_SHOW_CAUSE_LENGTH is null)))
      AND ((tlinfo.APPEAL_LENGTH = X_APPEAL_LENGTH)
           OR ((tlinfo.APPEAL_LENGTH is null)
               AND (X_APPEAL_LENGTH is null)))
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_STREAM_NUM in NUMBER,
  X_SHOW_CAUSE_LENGTH in NUMBER,
  X_APPEAL_LENGTH in NUMBER,
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

    Before_DML(
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
     x_appeal_length => X_APPEAL_LENGTH,
     x_course_cd => X_COURSE_CD,
     x_prg_cal_type => X_PRG_CAL_TYPE,
     x_show_cause_length => X_SHOW_CAUSE_LENGTH,
     x_stream_num => X_STREAM_NUM,
     x_version_number => X_VERSION_NUMBER,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
     );

  update IGS_PR_S_CRV_PRG_CAL set
    STREAM_NUM = NEW_REFERENCES.STREAM_NUM,
    SHOW_CAUSE_LENGTH = NEW_REFERENCES.SHOW_CAUSE_LENGTH,
    APPEAL_LENGTH = NEW_REFERENCES.APPEAL_LENGTH,
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_STREAM_NUM in NUMBER,
  X_SHOW_CAUSE_LENGTH in NUMBER,
  X_APPEAL_LENGTH in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_PR_S_CRV_PRG_CAL
     where COURSE_CD = X_COURSE_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and PRG_CAL_TYPE = X_PRG_CAL_TYPE
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_VERSION_NUMBER,
     X_PRG_CAL_TYPE,
     X_STREAM_NUM,
     X_SHOW_CAUSE_LENGTH,
     X_APPEAL_LENGTH,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_PRG_CAL_TYPE,
   X_STREAM_NUM,
   X_SHOW_CAUSE_LENGTH,
   X_APPEAL_LENGTH,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML(
     p_action=>'DELETE',
     x_rowid=>X_ROWID
    );

  delete from IGS_PR_S_CRV_PRG_CAL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE  Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
) AS
BEGIN

IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'COURSE_CD' THEN
  new_references.COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PRG_CAL_TYPE' THEN
  new_references.PRG_CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'STREAM_NUM' THEN
  new_references.STREAM_NUM:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SHOW_CAUSE_LENGTH' THEN
  new_references.SHOW_CAUSE_LENGTH:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'APPEAL_LENGTH' THEN
  new_references.APPEAL_LENGTH:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.COURSE_CD<> upper(new_references.COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRG_CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRG_CAL_TYPE<> upper(new_references.PRG_CAL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'STREAM_NUM' OR COLUMN_NAME IS NULL THEN
  IF new_references.STREAM_NUM < 0 or new_references.STREAM_NUM > 99 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SHOW_CAUSE_LENGTH' OR COLUMN_NAME IS NULL THEN
  IF new_references.SHOW_CAUSE_LENGTH < 0 or new_references.SHOW_CAUSE_LENGTH > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'APPEAL_LENGTH' OR COLUMN_NAME IS NULL THEN
  IF new_references.APPEAL_LENGTH < 0 or new_references.APPEAL_LENGTH > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


END Check_Constraints;

end IGS_PR_S_CRV_PRG_CAL_PKG;

/
