--------------------------------------------------------
--  DDL for Package Body IGS_EN_UNIT_SET_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_UNIT_SET_NOTE_PKG" as
/* $Header: IGSEI05B.pls 115.3 2002/11/28 23:32:11 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_EN_UNIT_SET_NOTE%RowType;
  new_references IGS_EN_UNIT_SET_NOTE%RowType;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_crs_note_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_UNIT_SET_NOTE
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.version_number := x_version_number;
    new_references.reference_number := x_reference_number;
    new_references.crs_note_type := x_crs_note_type;
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
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 ) as

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'UNIT_SET_CD' THEN
        new_references.unit_set_cd := column_value;
    ELSIF  UPPER(column_name) = 'CRS_NOTE_TYPE' THEN
        new_references.crs_note_type := column_value;
    END IF;


    IF ((UPPER (column_name) = 'CRS_NOTE_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.crs_note_type <> UPPER (new_references.crs_note_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'UNIT_SET_CD') OR (column_name IS NULL)) THEN
      IF (new_references.unit_set_cd <> UPPER (new_references.unit_set_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.crs_note_type = new_references.crs_note_type)) OR
        ((new_references.crs_note_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_NOTE_TYPE_PKG.Get_PK_For_Validation (
        new_references.crs_note_type
        ) THEN
       	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;


    END IF;

    IF (((old_references.reference_number = new_references.reference_number)) OR
        ((new_references.reference_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_NOTE_PKG.Get_PK_For_Validation (
                new_references.reference_number
           ) THEN

             Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;

    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.unit_set_cd,
        new_references.version_number
        ) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;

    END IF;
   END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_NOTE
      WHERE    unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number
      AND      reference_number = x_reference_number
      FOR UPDATE NOWAIT;

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

  PROCEDURE GET_FK_IGS_PS_NOTE_TYPE (
    x_crs_note_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_NOTE
      WHERE    crs_note_type = x_crs_note_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_CNT_USN_FK');
IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_NOTE_TYPE;

  PROCEDURE GET_FK_IGS_GE_NOTE (
    x_reference_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_NOTE
      WHERE    reference_number = x_reference_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_USN_NOTE_FK');
IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_NOTE;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_NOTE
      WHERE    unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_US_USN_FK');
IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_UNIT_SET;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_crs_note_type IN VARCHAR2 DEFAULT NULL,
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
      x_unit_set_cd,
      x_version_number,
      x_reference_number,
      x_crs_note_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
    	IF Get_PK_For_Validation(
		 new_references.unit_set_cd,
 		 new_references.version_number,
                 new_references.reference_number
	                            ) THEN

 		Fnd_message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
 		App_Exception.Raise_Exception;

	END IF;
	Check_Constraints;
        Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	 Check_Constraints;
         Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
			 new_references.unit_set_cd,
 			 new_references.version_number,
                	 new_references.reference_number
				 ) THEN
		          Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
		          App_Exception.Raise_Exception;
     	        END IF;
      		Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      		  Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
                    null;
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
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_UNIT_SET_NOTE
      where UNIT_SET_CD = X_UNIT_SET_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
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

   Before_DML(
      p_action => 'INSERT' ,
      x_rowid => x_rowid ,
      x_unit_set_cd => x_unit_set_cd ,
      x_version_number => x_version_number ,
      x_reference_number => x_reference_number ,
      x_crs_note_type => x_crs_note_type ,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login
    );


  insert into IGS_EN_UNIT_SET_NOTE (
    UNIT_SET_CD,
    VERSION_NUMBER,
    REFERENCE_NUMBER,
    CRS_NOTE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.REFERENCE_NUMBER,
    NEW_REFERENCES.CRS_NOTE_TYPE,
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
  X_ROWID IN VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2
) AS
  cursor c1 is select
      CRS_NOTE_TYPE
    from IGS_EN_UNIT_SET_NOTE
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

  if ( (tlinfo.CRS_NOTE_TYPE = X_CRS_NOTE_TYPE)
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
  X_ROWID IN VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
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

    Before_DML(
      p_action => 'UPDATE' ,
      x_rowid => x_rowid ,
      x_unit_set_cd => x_unit_set_cd ,
      x_version_number => x_version_number ,
      x_reference_number => x_reference_number ,
      x_crs_note_type => x_crs_note_type ,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login
    );


  update IGS_EN_UNIT_SET_NOTE set
    CRS_NOTE_TYPE = NEW_REFERENCES.CRS_NOTE_TYPE,
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
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_UNIT_SET_NOTE
     where UNIT_SET_CD = X_UNIT_SET_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and REFERENCE_NUMBER = X_REFERENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_SET_CD,
     X_VERSION_NUMBER,
     X_REFERENCE_NUMBER,
     X_CRS_NOTE_TYPE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_SET_CD,
   X_VERSION_NUMBER,
   X_REFERENCE_NUMBER,
   X_CRS_NOTE_TYPE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
) AS
begin

  Before_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_EN_UNIT_SET_NOTE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );


end DELETE_ROW;

end IGS_EN_UNIT_SET_NOTE_PKG;

/
