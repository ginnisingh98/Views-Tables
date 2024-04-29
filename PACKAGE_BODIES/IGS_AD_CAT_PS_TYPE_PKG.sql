--------------------------------------------------------
--  DDL for Package Body IGS_AD_CAT_PS_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_CAT_PS_TYPE_PKG" as
/* $Header: IGSAI13B.pls 115.7 2003/10/30 13:19:01 rghosh ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_CAT_PS_TYPE%RowType;
  new_references IGS_AD_CAT_PS_TYPE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_CAT_PS_TYPE
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
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.admission_cat := x_admission_cat;
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

   PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate the admission category closed indicator.
	IF IGS_AD_VAL_ACCT.admp_val_ac_closed (
			new_references.admission_cat,
			v_message_name) = FALSE THEN
		         Fnd_Message.Set_Name('IGS',v_message_name);
                         IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
	END IF;
	-- Validate the course type closed indicator.
	IF IGS_AS_VAL_ACOT.crsp_val_cty_closed (
			new_references.course_type,
			v_message_name) = FALSE THEN
                         Fnd_Message.Set_Name('IGS',v_message_name);
                         IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
	END IF;
  END BeforeRowInsert1;

  PROCEDURE Check_Constraints (
    Column_Name	IN	VARCHAR2	DEFAULT NULL,
    Column_Value 	IN	VARCHAR2	DEFAULT NULL
  ) AS
  BEGIN
	IF  column_name is null then
     		NULL;
	ELSIF upper(Column_name) = 'ADMISSION_CAT' Then
     		new_references.admission_cat := column_value;
	ELSIF upper(Column_name) = 'COURSE_TYPE' Then
     		new_references.course_type := column_value;
	END IF;
	IF upper(column_name) = 'ADMISSION_CAT' OR column_name is null Then
     		IF new_references.admission_cat <> UPPER(new_references.admission_cat) Then
       		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       		  IGS_GE_MSG_STACK.ADD;
       		  App_Exception.Raise_Exception;
     		END IF;
	END IF;
	IF upper(column_name) = 'COURSE_TYPE' OR column_name is null Then
     		IF new_references.course_type <> UPPER(new_references.course_type ) Then
       		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       		  IGS_GE_MSG_STACK.ADD;
       		  App_Exception.Raise_Exception;
     		END IF;
	END IF;
  END Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_CAT_PKG.Get_PK_For_Validation (
        new_references.admission_cat , 'N' ) THEN
     		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.course_type = new_references.course_type)) OR
        ((new_references.course_type IS NULL))) THEN
      NULL;
    ELSE
       IF NOT IGS_PS_TYPE_PKG.Get_PK_For_Validation (
        new_references.course_type ) THEN
     		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
      END IF;
   END IF;

  END Check_Parent_Existance;

  Function Get_PK_For_Validation (
    x_admission_cat IN VARCHAR2,
    x_course_type IN VARCHAR2 )
  RETURN BOOLEAN  AS
	CURSOR cur_rowid IS
      	SELECT   rowid
      	FROM     IGS_AD_CAT_PS_TYPE
      	WHERE    admission_cat = x_admission_cat
      	AND      course_type = x_course_type
           	FOR UPDATE NOWAIT;
	lv_rowid cur_rowid%RowType;
  BEGIN  -- Get_PK_For_Validation
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

  PROCEDURE GET_FK_IGS_AD_CAT (
    x_admission_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_CAT_PS_TYPE
      WHERE    admission_cat = x_admission_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACCT_AC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_CAT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
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
      x_admission_cat,
      x_course_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

	IF (p_action = 'INSERT') THEN
      	-- Call all the procedures related to Before Insert.
     		BeforeRowInsert1 ( p_inserting => TRUE );
      	IF  Get_PK_For_Validation (
          		new_references.admission_cat,
			new_references.course_type ) THEN
         		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
      	IF  Get_PK_For_Validation (
          		new_references.admission_cat,
			new_references.course_type ) THEN
         		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         		IGS_GE_MSG_STACK.ADD;
          		App_Exception.Raise_Exception;
      	END IF;
	      Check_Constraints;
 	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	      Check_Constraints;
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
  X_ADMISSION_CAT in VARCHAR2,
  X_COURSE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_CAT_PS_TYPE
      where ADMISSION_CAT = X_ADMISSION_CAT
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
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_admission_cat=>X_ADMISSION_CAT,
   x_course_type=>X_COURSE_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_AD_CAT_PS_TYPE (
    ADMISSION_CAT,
    COURSE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ADMISSION_CAT,
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

  After_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_COURSE_TYPE in VARCHAR2
) AS
  cursor c1 is select ROWID
    from IGS_AD_CAT_PS_TYPE
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_AD_CAT_PS_TYPE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_AD_CAT_PS_TYPE_PKG;

/
