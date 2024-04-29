--------------------------------------------------------
--  DDL for Package Body IGS_RE_DFLT_MS_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_DFLT_MS_SET_PKG" as
/* $Header: IGSRI06B.pls 115.7 2002/11/29 03:32:37 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_RE_DFLT_MS_SET_ALL%RowType;
  new_references IGS_RE_DFLT_MS_SET_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_milestone_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_days IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_DFLT_MS_SET_ALL
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
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.milestone_type := x_milestone_type;
    new_references.attendance_type := x_attendance_type;
    new_references.attendance_mode := x_attendance_mode;
    new_references.sequence_number := x_sequence_number;
    new_references.offset_days := x_offset_days;
    new_references.comments := x_comments;
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
  PROCEDURE Check_Constraints (
    Column_Name in VARCHAR2 DEFAULT NULL ,
    Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
 BEGIN
 IF Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'COURSE_CD' THEN
   new_references.COURSE_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'MILESTONE_TYPE' THEN
   new_references.MILESTONE_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'ATTENDANCE_TYPE' THEN
   new_references.ATTENDANCE_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
   new_references.SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'OFFSET_DAYS' THEN
   new_references.OFFSET_DAYS := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 END IF;
  IF upper(column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.COURSE_CD <> upper(NEW_REFERENCES.COURSE_CD) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'MILESTONE_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.MILESTONE_TYPE <> upper(NEW_REFERENCES.MILESTONE_TYPE) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'ATTENDANCE_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.ATTENDANCE_TYPE <> upper(NEW_REFERENCES.ATTENDANCE_TYPE) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.SEQUENCE_NUMBER < 1 OR new_references.SEQUENCE_NUMBER > 999999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'OFFSET_DAYS' OR COLUMN_NAME IS NULL THEN
    IF new_references.OFFSET_DAYS < 0 OR new_references.OFFSET_DAYS > 9999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
 END Check_Constraints ;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
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
    IF (((old_references.milestone_type = new_references.milestone_type)) OR
        ((new_references.milestone_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_MILESTONE_TYP_PKG.Get_PK_For_Validation (
        new_references.milestone_type
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
    x_milestone_type IN VARCHAR2,
    x_attendance_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN
   AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_DFLT_MS_SET_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      milestone_type = x_milestone_type
      AND      attendance_type = x_attendance_type
      AND      sequence_number = x_sequence_number
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
 	RETURN(TRUE);
    ELSE
        Close cur_rowid;
        RETURN(FALSE);
    END IF;
  END Get_PK_For_Validation;
  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_DFLT_MS_SET_ALL
      WHERE    attendance_type = x_attendance_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_DMS_ATT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_ATD_TYPE;
  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_DFLT_MS_SET_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_DMS_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_VER;
  PROCEDURE GET_FK_IGS_PR_MILESTONE_TYP (
    x_milestone_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_DFLT_MS_SET_ALL
      WHERE    milestone_type = x_milestone_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_DMS_MTY_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PR_MILESTONE_TYP;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_milestone_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_days IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
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
      x_course_cd,
      x_version_number,
      x_milestone_type,
      x_attendance_type,
      x_attendance_mode,
      x_sequence_number,
      x_offset_days,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	      IF Get_PK_For_Validation (
		    new_references.course_cd,
		    new_references.version_number,
		    new_references.milestone_type,
		    new_references.attendance_type,
		    new_references.sequence_number
	      ) THEN
		 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
		 IGS_GE_MSG_STACK.ADD;
	         App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
	    new_references.course_cd,
	    new_references.version_number,
	    new_references.milestone_type,
	    new_references.attendance_type,
	    new_references.sequence_number
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MILESTONE_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DAYS in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_DFLT_MS_SET_ALL
      where COURSE_CD = X_COURSE_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and MILESTONE_TYPE = X_MILESTONE_TYPE
      and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
      and ATTENDANCE_MODE = X_ATTENDANCE_MODE
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_milestone_type => X_MILESTONE_TYPE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_offset_days => X_OFFSET_DAYS,
    x_comments => X_COMMENTS,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  );
  insert into IGS_RE_DFLT_MS_SET_ALL (
    COURSE_CD,
    VERSION_NUMBER,
    MILESTONE_TYPE,
    ATTENDANCE_TYPE,
    ATTENDANCE_MODE,
    SEQUENCE_NUMBER,
    OFFSET_DAYS,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.MILESTONE_TYPE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.OFFSET_DAYS,
    NEW_REFERENCES.COMMENTS,
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MILESTONE_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DAYS in NUMBER,
  X_COMMENTS in VARCHAR2
) as
  cursor c1 is select
      OFFSET_DAYS,
      COMMENTS
    from IGS_RE_DFLT_MS_SET_ALL
    where ROWID = X_ROWID
    for update nowait;
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
  if ( (tlinfo.OFFSET_DAYS = X_OFFSET_DAYS)
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MILESTONE_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DAYS in NUMBER,
  X_COMMENTS in VARCHAR2,
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
  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_milestone_type => X_MILESTONE_TYPE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_offset_days => X_OFFSET_DAYS,
    x_comments => X_COMMENTS,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_RE_DFLT_MS_SET_ALL set
    OFFSET_DAYS = NEW_REFERENCES.OFFSET_DAYS,
    COMMENTS = NEW_REFERENCES.COMMENTS,
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
  X_MILESTONE_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DAYS in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_DFLT_MS_SET_ALL
     where COURSE_CD = X_COURSE_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and MILESTONE_TYPE = X_MILESTONE_TYPE
     and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
     and ATTENDANCE_MODE = X_ATTENDANCE_MODE
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
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
     X_MILESTONE_TYPE,
     X_ATTENDANCE_TYPE,
     X_ATTENDANCE_MODE,
     X_SEQUENCE_NUMBER,
     X_OFFSET_DAYS,
     X_COMMENTS,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_MILESTONE_TYPE,
   X_ATTENDANCE_TYPE,
   X_ATTENDANCE_MODE,
   X_SEQUENCE_NUMBER,
   X_OFFSET_DAYS,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  ) as
begin
  delete from IGS_RE_DFLT_MS_SET_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_RE_DFLT_MS_SET_PKG;

/
