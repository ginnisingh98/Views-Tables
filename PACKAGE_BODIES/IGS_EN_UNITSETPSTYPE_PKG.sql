--------------------------------------------------------
--  DDL for Package Body IGS_EN_UNITSETPSTYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_UNITSETPSTYPE_PKG" AS
/* $Header: IGSEI03B.pls 115.5 2003/06/05 13:03:36 sarakshi ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_EN_UNITSETPSTYPE%RowType;
  new_references IGS_EN_UNITSETPSTYPE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_UNITSETPSTYPE
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
    new_references.course_type := x_course_type;
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
  -- "OSS_TST".trg_usct_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_UNITSETPSTYPE
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_unit_set_cd		IGS_EN_UNITSETPSTYPE.unit_set_cd%TYPE;
	v_version_number	IGS_EN_UNITSETPSTYPE.version_number%TYPE;
      v_message_name  varchar2(30);
  BEGIN
	-- Set variables.
	IF p_deleting THEN
		v_unit_set_cd		:= old_references.unit_set_cd;
		v_version_number	:= old_references.version_number;
	ELSE -- p_inserting or p_updating
		v_unit_set_cd		:= new_references.unit_set_cd;
		v_version_number	:= new_references.version_number;
	END IF;
	-- <usct1>
	-- Can not alter details when UNIT set is INACTIVE
	IF  IGS_PS_VAL_COUSR.crsp_val_iud_us_dtl (
					v_unit_set_cd,
					v_version_number,
					v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
	END IF;
	IF p_inserting OR p_updating THEN
		-- <usct2>
		-- Can not alter details when COURSE type is closed
		IF  IGS_as_VAL_acot.crsp_val_cty_closed (
						new_references.course_type,
						v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 ) as

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'COURSE_TYPE' THEN
        new_references.course_type := column_value;
    ELSIF  UPPER(column_name) = 'UNIT_SET_CD' THEN
        new_references.unit_set_cd := column_value;
    END IF;


    IF ((UPPER (column_name) = 'COURSE_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.course_type <> UPPER (new_references.course_type)) THEN
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

    IF (((old_references.course_type = new_references.course_type)) OR
        ((new_references.course_type IS NULL))) THEN
      NULL;
    ELSE
       IF NOT  IGS_PS_TYPE_PKG.Get_PK_For_Validation (
          new_references.course_type
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
    x_course_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNITSETPSTYPE
      WHERE    unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number
      AND      course_type = x_course_type
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


  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNITSETPSTYPE
      WHERE    unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_USCT_US_FK');
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
    x_course_type IN VARCHAR2 DEFAULT NULL,
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
      x_course_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
 	IF Get_PK_For_Validation(
		 new_references.unit_set_cd,
 		 new_references.version_number,
                 new_references.course_type
	                            ) THEN

 		Fnd_message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
		          new_references.unit_set_cd,
		          new_references.version_number,
                          new_references.course_type
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
  X_COURSE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_UNITSETPSTYPE
      where UNIT_SET_CD = X_UNIT_SET_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and COURSE_TYPE = X_COURSE_TYPE;
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
      x_course_type => x_course_type ,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_updated_by
  );

  insert into IGS_EN_UNITSETPSTYPE (
    UNIT_SET_CD,
    VERSION_NUMBER,
    COURSE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.COURSE_TYPE,
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
  X_COURSE_TYPE in VARCHAR2
) AS
  cursor c1 is select
     ROWID
    from IGS_EN_UNITSETPSTYPE
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
  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
) AS
begin

  Before_DML(
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );
  delete from IGS_EN_UNITSETPSTYPE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_EN_UNITSETPSTYPE_PKG;

/
