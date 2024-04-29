--------------------------------------------------------
--  DDL for Package Body IGS_PE_ALTERNATV_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_ALTERNATV_EXT_PKG" as
/* $Header: IGSNI01B.pls 115.3 2002/11/29 01:13:42 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PE_ALTERNATV_EXT%RowType;
  new_references IGS_PE_ALTERNATV_EXT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_exit_course_cd IN VARCHAR2 DEFAULT NULL,
    x_exit_version_set IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_ALTERNATV_EXT
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
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.exit_course_cd := x_exit_course_cd;
    new_references.exit_version_set := x_exit_version_set;
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
  -- "OSS_TST".trg_ae_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_PE_ALTERNATV_EXT
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
	v_message_name  varchar2(30);
	v_course_cd		    IGS_PE_ALTERNATV_EXT.course_cd%TYPE;
	v_version_number	IGS_PE_ALTERNATV_EXT.version_number%TYPE;
  BEGIN
	-- Set variables.
	IF p_deleting THEN
		v_course_cd := old_references.course_cd;
		v_version_number := old_references.version_number;
	ELSE -- p_inserting or p_updating
		v_course_cd := new_references.course_cd;
		v_version_number := new_references.version_number;
	END IF;
	-- Validate the insert/update/delete.
	IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl (
			v_course_cd,
			v_version_number,
			v_message_name) = FALSE THEN
	Fnd_Message.Set_Name('IGS', v_message_name);
	IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
	END IF;


  END BeforeRowInsertUpdateDelete1;


  PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 as
 BEGIN
    IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
 ELSIF upper(Column_name) = 'EXIT_COURSE_CD' then
     new_references.exit_course_cd := column_value;
END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd  <> UPPER(new_references.course_cd ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
END IF;

IF upper(column_name) = 'EXIT_COURSE_CD' OR
     column_name is null Then
     IF new_references.exit_course_cd <>
UPPER(new_references.exit_course_cd ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.exit_course_cd = new_references.exit_course_cd)) OR
        ((new_references.exit_course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_PS_COURSE_PKG.Get_PK_For_Validation (
         new_references.exit_course_cd
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
      IF  NOT (IGS_PS_VER_PKG.Get_PK_For_Validation (
         new_references.course_cd,
         new_references.version_number)) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_PS_STDNT_APV_ALT_PKG.GET_FK_IGS_PE_ALTERNATV_EXT (
      old_references.course_cd,
      old_references.version_number,
      old_references.exit_course_cd
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_exit_course_cd IN VARCHAR2
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_ALTERNATV_EXT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      exit_course_cd = x_exit_course_cd
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

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_ALTERNATV_EXT
      WHERE    exit_course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_AE_CRS_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_COURSE;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_ALTERNATV_EXT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_AE_CRV_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_VER;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_exit_course_cd IN VARCHAR2 DEFAULT NULL,
    x_exit_version_set IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_course_cd,
      x_version_number,
      x_exit_course_cd,
      x_exit_version_set,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
          NEW_REFERENCES.course_cd,
          NEW_REFERENCES.version_number ,
          NEW_REFERENCES.exit_course_cd
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
        BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );

       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
        BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
       Check_Child_Existance; -- if procedure present
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          NEW_REFERENCES.course_cd ,
          NEW_REFERENCES.version_number ,
          NEW_REFERENCES.exit_course_cd
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       Check_Constraints; -- if procedure present

ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance; -- if procedure present
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
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_SET in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_PE_ALTERNATV_EXT
      where COURSE_CD = X_COURSE_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and EXIT_COURSE_CD = X_EXIT_COURSE_CD;
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
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_course_cd=>X_COURSE_CD,
 x_exit_course_cd=>X_EXIT_COURSE_CD,
 x_exit_version_set=>X_EXIT_VERSION_SET,
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_PE_ALTERNATV_EXT (
    COURSE_CD,
    VERSION_NUMBER,
    EXIT_COURSE_CD,
    EXIT_VERSION_SET,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.EXIT_COURSE_CD,
    NEW_REFERENCES.EXIT_VERSION_SET,
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
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_SET in VARCHAR2
) as
  cursor c1 is select
      EXIT_VERSION_SET
    from IGS_PE_ALTERNATV_EXT
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');

    close c1;
    App_Exception.Raise_Exception;
    return;
  end if;
  close c1;

      if ( ((tlinfo.EXIT_VERSION_SET = X_EXIT_VERSION_SET)
           OR ((tlinfo.EXIT_VERSION_SET is null)
               AND (X_EXIT_VERSION_SET is null)))
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
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_SET in VARCHAR2,
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
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_course_cd=>X_COURSE_CD,
 x_exit_course_cd=>X_EXIT_COURSE_CD,
 x_exit_version_set=>X_EXIT_VERSION_SET,
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_PE_ALTERNATV_EXT set
    EXIT_VERSION_SET = NEW_REFERENCES.EXIT_VERSION_SET,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_SET in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_PE_ALTERNATV_EXT
     where COURSE_CD = X_COURSE_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and EXIT_COURSE_CD = X_EXIT_COURSE_CD
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
     X_EXIT_COURSE_CD,
     X_EXIT_VERSION_SET,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_EXIT_COURSE_CD,
   X_EXIT_VERSION_SET,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

  delete from IGS_PE_ALTERNATV_EXT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );


end DELETE_ROW;

end IGS_PE_ALTERNATV_EXT_PKG;

/
