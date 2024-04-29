--------------------------------------------------------
--  DDL for Package Body IGS_AD_OS_SEC_ED_SUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_OS_SEC_ED_SUB_PKG" as
/* $Header: IGSAI40B.pls 115.3 2002/11/28 22:04:52 nsidana ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_AD_OS_SEC_ED_SUB%RowType;
  new_references IGS_AD_OS_SEC_ED_SUB%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ose_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_subject_cd IN VARCHAR2 DEFAULT NULL,
    x_subject_desc IN VARCHAR2 DEFAULT NULL,
    x_result_type IN VARCHAR2 DEFAULT NULL,
    x_result IN VARCHAR2 DEFAULT NULL,
    x_subject_result_yr IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_OS_SEC_ED_SUB
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
    new_references.person_id := x_person_id;
    new_references.ose_sequence_number := x_ose_sequence_number;
    new_references.sequence_number := x_sequence_number;
    new_references.subject_cd := x_subject_cd;
    new_references.subject_desc := x_subject_desc;
    new_references.result_type := x_result_type;
    new_references.result := x_result;
    new_references.subject_result_yr := x_subject_result_yr;
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
	v_message_name	varchar2(30);
  BEGIN
	-- Ensure that at least one of subject_cd and/or subject_desc is entered
	IF p_inserting OR p_updating THEN
		IF IGS_AD_VAL_OSES.admp_val_oses_subj(
					new_references.subject_cd,
					new_references.subject_desc,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate System admission outcome status IGS_PS_UNIT outcome ind.
	IF p_inserting OR (old_references.result_type <> new_references.result_type) THEN
		IF IGS_AD_VAL_OSES.admp_val_teua_sret(
					new_references.result_type,
					v_message_name) = FALSE THEN
	       	Fnd_Message.Set_Name('IGS',v_message_name);
	       	IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  procedure Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
  )
  AS
  BEGIN
	IF Column_Name is null then
		NULL;
	ELSIF upper(Column_Name) = 'SUBJECT_CD' then
		new_references.subject_cd := column_value;
	ELSIF upper(Column_Name) = 'SUBJECT_DESC' then
		new_references.subject_desc := column_value;
	ELSIF upper(Column_Name) = 'RESULT_TYPE' then
		new_references.result_type := column_value;
	ELSIF upper(Column_Name) = 'RESULT' then
		new_references.result := column_value;
	ELSIF upper(Column_Name) = 'OSE_SEQUENCE_NUMBER' then
		new_references.ose_sequence_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'SEQUENCE_NUMBER' then
		new_references.sequence_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'SUBJECT_RESULT_YR' then
		new_references.subject_result_yr := igs_ge_number.to_num(column_value);
	END IF;

	IF upper(Column_Name) = 'SUBJECT_CD' OR Column_Name IS NULL THEN
		IF new_references.subject_cd <> UPPER(new_references.subject_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SUBJECT_DESC' OR Column_Name IS NULL THEN
		IF new_references.subject_desc <> UPPER(new_references.subject_desc) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'RESULT_TYPE' OR Column_Name IS NULL THEN
		IF new_references.result_type <> UPPER(new_references.result_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'RESULT' OR Column_Name IS NULL THEN
		IF new_references.result <> UPPER(new_references.result) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'OSE_SEQUENCE_NUMBER' OR Column_Name IS NULL THEN
		IF new_references.ose_sequence_number < 1 OR new_references.ose_sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SEQUENCE_NUMBER' OR Column_Name IS NULL THEN
		IF new_references.sequence_number < 1 OR new_references.sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SUBJECT_RESULT_YR' OR Column_Name IS NULL THEN
		IF new_references.subject_result_yr < 1900 OR new_references.subject_result_yr > 2050 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.ose_sequence_number = new_references.ose_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.ose_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_OS_SEC_EDU_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.ose_sequence_number
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ose_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
)return BOOLEAN AS

    CURSOR cur_rowid is
      SELECT   rowid
      FROM     IGS_AD_OS_SEC_ED_SUB
      WHERE    person_id = x_person_id
      AND      ose_sequence_number = x_ose_sequence_number
      AND      sequence_number = x_sequence_number
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

  PROCEDURE GET_FK_IGS_AD_OS_SEC_EDU (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_OS_SEC_ED_SUB
      WHERE    person_id = x_person_id
      AND      ose_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_OSES_OSE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_OS_SEC_EDU;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ose_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_subject_cd IN VARCHAR2 DEFAULT NULL,
    x_subject_desc IN VARCHAR2 DEFAULT NULL,
    x_result_type IN VARCHAR2 DEFAULT NULL,
    x_result IN VARCHAR2 DEFAULT NULL,
    x_subject_result_yr IN NUMBER DEFAULT NULL,
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
      x_person_id,
      x_ose_sequence_number,
      x_sequence_number,
      x_subject_cd,
      x_subject_desc,
      x_result_type,
      x_result,
      x_subject_result_yr,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.ose_sequence_number,
		new_references.sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.ose_sequence_number,
		new_references.sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  X_PERSON_ID in NUMBER,
  X_OSE_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_OS_SEC_ED_SUB
      where PERSON_ID = X_PERSON_ID
      and OSE_SEQUENCE_NUMBER = X_OSE_SEQUENCE_NUMBER
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

 Before_DML(
    p_action=>'INSERT' ,
    x_rowid=>X_ROWID ,
    x_person_id => X_PERSON_ID ,
    x_ose_sequence_number => X_OSE_SEQUENCE_NUMBER ,
    x_sequence_number => X_SEQUENCE_NUMBER ,
    x_subject_cd => X_SUBJECT_CD ,
    x_subject_desc => X_SUBJECT_DESC ,
    x_result_type => X_RESULT_TYPE ,
    x_result => X_RESULT ,
    x_subject_result_yr => X_SUBJECT_RESULT_YR ,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY   ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );


  insert into IGS_AD_OS_SEC_ED_SUB (
    PERSON_ID,
    OSE_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
    SUBJECT_CD,
    SUBJECT_DESC,
    RESULT_TYPE,
    RESULT,
    SUBJECT_RESULT_YR,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.OSE_SEQUENCE_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.SUBJECT_CD,
    NEW_REFERENCES.SUBJECT_DESC,
    NEW_REFERENCES.RESULT_TYPE,
    NEW_REFERENCES.RESULT,
    NEW_REFERENCES.SUBJECT_RESULT_YR,
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
  p_action=>'INSERT',
  x_rowid=> X_ROWID
         );


end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2 ,
  X_PERSON_ID in NUMBER,
  X_OSE_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_SUBJECT_RESULT_YR in NUMBER
) AS
  cursor c1 is select
      SUBJECT_CD,
      SUBJECT_DESC,
      RESULT_TYPE,
      RESULT,
      SUBJECT_RESULT_YR
    from IGS_AD_OS_SEC_ED_SUB
   WHERE  ROWID = X_ROWID  for update nowait ;
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

      if ( ((tlinfo.SUBJECT_CD = X_SUBJECT_CD)
           OR ((tlinfo.SUBJECT_CD is null)
               AND (X_SUBJECT_CD is null)))
      AND ((tlinfo.SUBJECT_DESC = X_SUBJECT_DESC)
           OR ((tlinfo.SUBJECT_DESC is null)
               AND (X_SUBJECT_DESC is null)))
      AND (tlinfo.RESULT_TYPE = X_RESULT_TYPE)
      AND ((tlinfo.RESULT = X_RESULT)
           OR ((tlinfo.RESULT is null)
               AND (X_RESULT is null)))
      AND ((tlinfo.SUBJECT_RESULT_YR = X_SUBJECT_RESULT_YR)
           OR ((tlinfo.SUBJECT_RESULT_YR is null)
               AND (X_SUBJECT_RESULT_YR is null)))
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
  X_ROWID in VARCHAR2 ,
  X_PERSON_ID in NUMBER,
  X_OSE_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_SUBJECT_RESULT_YR in NUMBER,
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
    p_action=>'UPDATE' ,
    x_rowid=>X_ROWID ,
    x_person_id => X_PERSON_ID ,
    x_ose_sequence_number => X_OSE_SEQUENCE_NUMBER ,
    x_sequence_number => X_SEQUENCE_NUMBER ,
    x_subject_cd => X_SUBJECT_CD ,
    x_subject_desc => X_SUBJECT_DESC ,
    x_result_type => X_RESULT_TYPE ,
    x_result => X_RESULT ,
    x_subject_result_yr => X_SUBJECT_RESULT_YR ,
    x_creation_date=>X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY   ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );



  update IGS_AD_OS_SEC_ED_SUB set
    SUBJECT_CD = NEW_REFERENCES.SUBJECT_CD,
    SUBJECT_DESC = NEW_REFERENCES.SUBJECT_DESC,
    RESULT_TYPE = NEW_REFERENCES.RESULT_TYPE,
    RESULT = NEW_REFERENCES.RESULT,
    SUBJECT_RESULT_YR = NEW_REFERENCES.SUBJECT_RESULT_YR,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML(
  p_action=>'UPDATE',
  x_rowid=> X_ROWID
         );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_OSE_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_OS_SEC_ED_SUB
     where PERSON_ID = X_PERSON_ID
     and OSE_SEQUENCE_NUMBER = X_OSE_SEQUENCE_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_OSE_SEQUENCE_NUMBER,
     X_SEQUENCE_NUMBER,
     X_SUBJECT_CD,
     X_SUBJECT_DESC,
     X_RESULT_TYPE,
     X_RESULT,
     X_SUBJECT_RESULT_YR,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID  ,
   X_PERSON_ID,
   X_OSE_SEQUENCE_NUMBER,
   X_SEQUENCE_NUMBER,
   X_SUBJECT_CD,
   X_SUBJECT_DESC,
   X_RESULT_TYPE,
   X_RESULT,
   X_SUBJECT_RESULT_YR,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin


 Before_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );

  delete from IGS_AD_OS_SEC_ED_SUB
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;


 After_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );

end DELETE_ROW;

end IGS_AD_OS_SEC_ED_SUB_PKG;

/
