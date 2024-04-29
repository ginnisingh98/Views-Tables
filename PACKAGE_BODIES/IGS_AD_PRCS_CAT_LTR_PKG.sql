--------------------------------------------------------
--  DDL for Package Body IGS_AD_PRCS_CAT_LTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PRCS_CAT_LTR_PKG" AS
/* $Header: IGSAI36B.pls 115.6 2003/10/30 13:20:05 rghosh ship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_AD_PRCS_CAT_LTR%RowType;
  new_references IGS_AD_PRCS_CAT_LTR%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    x_correspondence_type IN VARCHAR2 DEFAULT NULL,
    x_letter_reference_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PRCS_CAT_LTR
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
    new_references.admission_cat := x_admission_cat;
    new_references.s_admission_process_type := x_s_admission_process_type;
    new_references.correspondence_type := x_correspondence_type;
    new_references.letter_reference_number := x_letter_reference_number;
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

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate the System Letter
	IF p_inserting
	OR (old_references.correspondence_type <> new_references.correspondence_type)
	OR (old_references.letter_reference_number <> new_references.letter_reference_number) THEN
		-- Validate that the s_letter is not closed.
		IF IGS_AD_VAL_APCL.corp_val_slet_closed(
					new_references.correspondence_type,
					new_references.letter_reference_number,
					v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS',v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
		-- Validate that the s_letter is of type 'ADM'
		IF IGS_AD_VAL_APCL.corp_val_slet_slrt(
					new_references.correspondence_type,
					new_references.letter_reference_number,
					'ADM',
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;

  END BeforeRowInsertUpdate1;

PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
)
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'ADMISSION_CAT' then
     new_references.admission_cat := column_value;
 ELSIF upper(Column_name) = 'S_ADMISSION_PROCESS_TYPE' then
     new_references.s_admission_process_type := column_value;
 ELSIF upper(Column_name) = 'CORRESPONDENCE_TYPE' then
     new_references.correspondence_type := column_value;
END IF;

IF upper(column_name) = 'ADMISSION_CAT' OR
	 column_name is null Then
     IF new_references.admission_cat <> UPPER(new_references.admission_cat) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'CORRESPONDENCE_TYPE' OR
     column_name is null Then
     IF new_references.correspondence_type <> UPPER(new_references.correspondence_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'S_ADMISSION_PROCESS_TYPE' OR
     column_name is null Then
     IF new_references.s_admission_process_type <> UPPER(new_references.s_admission_process_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.admission_cat = new_references.admission_cat) AND
         (old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.admission_cat IS NULL) OR
         (new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_AD_PRCS_CAT_PKG.Get_PK_For_Validation (
        new_references.admission_cat,
        new_references.s_admission_process_type,
        'N'
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	 IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
	 END IF;
    END IF;

    IF (((old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.letter_reference_number = new_references.letter_reference_number)) OR
        ((new_references.correspondence_type IS NULL) OR
         (new_references.letter_reference_number IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_CO_S_LTR_PKG.Get_PK_For_Validation (
        new_references.correspondence_type,
        new_references.letter_reference_number
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	 IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
	 END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_correspondence_type IN VARCHAR2
    )
RETURN BOOLEAN
AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRCS_CAT_LTR
      WHERE    admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type
      AND      correspondence_type = x_correspondence_type
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

  PROCEDURE GET_FK_IGS_AD_PRCS_CAT (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRCS_CAT_LTR
      WHERE    admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCL_APC_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PRCS_CAT;

  PROCEDURE GET_FK_IGS_CO_S_LTR (
    x_correspondence_type IN VARCHAR2,
    x_letter_reference_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRCS_CAT_LTR
      WHERE    correspondence_type = x_correspondence_type
      AND      letter_reference_number = x_letter_reference_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCL_SLET_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CO_S_LTR;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    x_correspondence_type IN VARCHAR2 DEFAULT NULL,
    x_letter_reference_number IN NUMBER DEFAULT NULL,
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
      x_s_admission_process_type,
      x_correspondence_type,
      x_letter_reference_number,
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
          new_references.admission_cat,
          new_references.s_admission_process_type,
          new_references.correspondence_type
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
      IF  Get_PK_For_Validation (
          new_references.admission_cat,
          new_references.s_admission_process_type,
          new_references.correspondence_type
		) THEN
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
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_PRCS_CAT_LTR
      where ADMISSION_CAT = X_ADMISSION_CAT
      and S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE
      and CORRESPONDENCE_TYPE = X_CORRESPONDENCE_TYPE;
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

  Before_DML(p_action =>'INSERT',
  x_rowid =>X_ROWID,
  x_admission_cat => X_ADMISSION_CAT,
  x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
  x_correspondence_type => X_CORRESPONDENCE_TYPE,
  x_letter_reference_number=> X_LETTER_REFERENCE_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_AD_PRCS_CAT_LTR (
    ADMISSION_CAT,
    S_ADMISSION_PROCESS_TYPE,
    CORRESPONDENCE_TYPE,
    LETTER_REFERENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE,
    NEW_REFERENCES.CORRESPONDENCE_TYPE,
    NEW_REFERENCES.LETTER_REFERENCE_NUMBER,
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
 p_action =>'INSERT',
 x_rowid => X_ROWID
);
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER
) AS
  cursor c1 is select
      LETTER_REFERENCE_NUMBER
    from IGS_AD_PRCS_CAT_LTR
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

  if ( (tlinfo.LETTER_REFERENCE_NUMBER = X_LETTER_REFERENCE_NUMBER)
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
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
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
  Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_admission_cat => X_ADMISSION_CAT,
  x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
  x_correspondence_type => X_CORRESPONDENCE_TYPE,
  x_letter_reference_number=> X_LETTER_REFERENCE_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_AD_PRCS_CAT_LTR set
    LETTER_REFERENCE_NUMBER = NEW_REFERENCES.LETTER_REFERENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
 p_action =>'UPDATE',
 x_rowid => X_ROWID
);
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_PRCS_CAT_LTR
     where ADMISSION_CAT = X_ADMISSION_CAT
     and S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE
     and CORRESPONDENCE_TYPE = X_CORRESPONDENCE_TYPE
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ADMISSION_CAT,
     X_S_ADMISSION_PROCESS_TYPE,
     X_CORRESPONDENCE_TYPE,
     X_LETTER_REFERENCE_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ADMISSION_CAT,
   X_S_ADMISSION_PROCESS_TYPE,
   X_CORRESPONDENCE_TYPE,
   X_LETTER_REFERENCE_NUMBER,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_AD_PRCS_CAT_LTR
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_AD_PRCS_CAT_LTR_PKG;

/
