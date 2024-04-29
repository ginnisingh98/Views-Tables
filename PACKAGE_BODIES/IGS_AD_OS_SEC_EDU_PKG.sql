--------------------------------------------------------
--  DDL for Package Body IGS_AD_OS_SEC_EDU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_OS_SEC_EDU_PKG" as
 /* $Header: IGSAI42B.pls 115.4 2003/10/30 13:20:32 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_OS_SEC_EDU%RowType;
  new_references IGS_AD_OS_SEC_EDU%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_os_scndry_edu_qualification IN VARCHAR2 DEFAULT NULL,
    x_result IN VARCHAR2 DEFAULT NULL,
    x_candidate_number IN NUMBER DEFAULT NULL,
    x_school_name IN VARCHAR2 DEFAULT NULL,
    x_country_cd IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_OS_SEC_EDU
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
    new_references.sequence_number := x_sequence_number;
    new_references.result_obtained_yr := x_result_obtained_yr;
    new_references.os_scndry_edu_qualification := x_os_scndry_edu_qualification;
    new_references.result := x_result;
    new_references.candidate_number := x_candidate_number;
    new_references.school_name := x_school_name;
    new_references.country_cd := x_country_cd;
    new_references.comments := x_comments;
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
	-- Validate Overseas Secondary Education Qualification closed ind.
	IF p_inserting
	OR ((old_references.os_scndry_edu_qualification <> new_references.os_scndry_edu_qualification)
	OR (old_references.os_scndry_edu_qualification IS NULL AND
				 new_references.os_scndry_edu_qualification IS NOT NULL)) THEN
		IF IGS_AD_VAL_OSE.admp_val_oseq_closed(
					new_references.os_scndry_edu_qualification,
					v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate Overseas Secondary Education Qualification IGS_PE_COUNTRY_CD.
	IF p_inserting
	OR ((old_references.os_scndry_edu_qualification <> new_references.os_scndry_edu_qualification)
	OR (old_references.os_scndry_edu_qualification IS NULL AND
				 new_references.os_scndry_edu_qualification IS NOT NULL)
	OR (old_references.country_cd <> new_references.country_cd)) THEN
		IF IGS_AD_VAL_OSE.admp_val_ose_qcntry(
					new_references.os_scndry_edu_qualification,
					new_references.country_cd,
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
	ELSIF upper(Column_Name) = 'OS_SCNDRY_EDU_QUALIFICATION' then
		new_references.os_scndry_edu_qualification := column_value;
	ELSIF upper(Column_Name) = 'RESULT' then
		new_references.result := column_value;
	ELSIF upper(Column_Name) = 'SCHOOL_NAME' then
		new_references.school_name := column_value;
	ELSIF upper(Column_Name) = 'COUNTRY_CD' then
		new_references.country_cd := column_value;
	ELSIF upper(Column_Name) = 'SEQUENCE_NUMBER' then
		new_references.sequence_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'RESULT_OBTAINED_YR' then
		new_references.result_obtained_yr := igs_ge_number.to_num(column_value);
	END IF;

	IF upper(Column_Name) = 'OS_SCNDRY_EDU_QUALIFICATION' OR Column_Name IS NULL THEN
		IF new_references.os_scndry_edu_qualification <> UPPER(new_references.os_scndry_edu_qualification) THEN
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
	IF upper(Column_Name) = 'SCHOOL_NAME' OR Column_Name IS NULL THEN
		IF new_references.school_name <> UPPER(new_references.school_name) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'COUNTRY_CD' OR Column_Name IS NULL THEN
		IF new_references.country_cd <> UPPER(new_references.country_cd) THEN
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
	IF upper(Column_Name) = 'RESULT_OBTAINED_YR' OR Column_Name IS NULL THEN
		IF new_references.result_obtained_yr < 1900 OR new_references.result_obtained_yr > 2050 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.country_cd = new_references.country_cd)) OR
        ((new_references.country_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_COUNTRY_CD_PKG.Get_PK_For_Validation (
        new_references.country_cd
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.os_scndry_edu_qualification = new_references.os_scndry_edu_qualification)) OR
        ((new_references.os_scndry_edu_qualification IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_OS_SEC_EDU_QF_PKG.Get_PK_For_Validation (
        new_references.os_scndry_edu_qualification,
        'N'
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_OS_SEC_ED_SUB_PKG.GET_FK_IGS_AD_OS_SEC_EDU (
      old_references.person_id,
      old_references.sequence_number
      );

  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_OS_SEC_EDU
      WHERE    person_id = x_person_id
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

  PROCEDURE GET_FK_IGS_PE_COUNTRY_CD (
    x_country_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_OS_SEC_EDU
      WHERE    country_cd = x_country_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_OSE_CNC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_COUNTRY_CD;

  PROCEDURE GET_FK_IGS_AD_OS_SEC_EDU_QF (
    x_os_scndry_edu_qualification IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_OS_SEC_EDU
      WHERE    os_scndry_edu_qualification = x_os_scndry_edu_qualification ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_OSE_OSEQ_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_OS_SEC_EDU_QF;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_OS_SEC_EDU
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_OSE_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_os_scndry_edu_qualification IN VARCHAR2 DEFAULT NULL,
    x_result IN VARCHAR2 DEFAULT NULL,
    x_candidate_number IN NUMBER DEFAULT NULL,
    x_school_name IN VARCHAR2 DEFAULT NULL,
    x_country_cd IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
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
      x_sequence_number,
      x_result_obtained_yr,
      x_os_scndry_edu_qualification,
      x_result,
      x_candidate_number,
      x_school_name,
      x_country_cd,
      x_comments,
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
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_OS_SCNDRY_EDU_QUALIFICATION in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_CANDIDATE_NUMBER in NUMBER,
  X_SCHOOL_NAME in VARCHAR2,
  X_COUNTRY_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_OS_SEC_EDU
      where PERSON_ID = X_PERSON_ID
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
    x_person_id => x_person_id ,
    x_sequence_number => x_sequence_number ,
    x_result_obtained_yr => x_result_obtained_yr ,
    x_os_scndry_edu_qualification => x_os_scndry_edu_qualification ,
    x_result => x_result  ,
    x_candidate_number => x_candidate_number ,
    x_school_name => x_school_name ,
    x_country_cd => x_country_cd ,
    x_comments => x_comments ,
    x_creation_date=>X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY  ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );

  insert into IGS_AD_OS_SEC_EDU (
    PERSON_ID,
    SEQUENCE_NUMBER,
    RESULT_OBTAINED_YR,
    OS_SCNDRY_EDU_QUALIFICATION,
    RESULT,
    CANDIDATE_NUMBER,
    SCHOOL_NAME,
    COUNTRY_CD,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.RESULT_OBTAINED_YR,
    NEW_REFERENCES.OS_SCNDRY_EDU_QUALIFICATION,
    NEW_REFERENCES.RESULT,
    NEW_REFERENCES.CANDIDATE_NUMBER,
    NEW_REFERENCES.SCHOOL_NAME,
    NEW_REFERENCES.COUNTRY_CD,
    NEW_REFERENCES.COMMENTS,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_OS_SCNDRY_EDU_QUALIFICATION in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_CANDIDATE_NUMBER in NUMBER,
  X_SCHOOL_NAME in VARCHAR2,
  X_COUNTRY_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      RESULT_OBTAINED_YR,
      OS_SCNDRY_EDU_QUALIFICATION,
      RESULT,
      CANDIDATE_NUMBER,
      SCHOOL_NAME,
      COUNTRY_CD,
      COMMENTS
    from IGS_AD_OS_SEC_EDU
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

      if ( ((tlinfo.RESULT_OBTAINED_YR = X_RESULT_OBTAINED_YR)
           OR ((tlinfo.RESULT_OBTAINED_YR is null)
               AND (X_RESULT_OBTAINED_YR is null)))
      AND ((tlinfo.OS_SCNDRY_EDU_QUALIFICATION = X_OS_SCNDRY_EDU_QUALIFICATION)
           OR ((tlinfo.OS_SCNDRY_EDU_QUALIFICATION is null)
               AND (X_OS_SCNDRY_EDU_QUALIFICATION is null)))
      AND ((tlinfo.RESULT = X_RESULT)
           OR ((tlinfo.RESULT is null)
               AND (X_RESULT is null)))
      AND ((tlinfo.CANDIDATE_NUMBER = X_CANDIDATE_NUMBER)
           OR ((tlinfo.CANDIDATE_NUMBER is null)
               AND (X_CANDIDATE_NUMBER is null)))
      AND ((tlinfo.SCHOOL_NAME = X_SCHOOL_NAME)
           OR ((tlinfo.SCHOOL_NAME is null)
               AND (X_SCHOOL_NAME is null)))
      AND (tlinfo.COUNTRY_CD = X_COUNTRY_CD)
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_OS_SCNDRY_EDU_QUALIFICATION in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_CANDIDATE_NUMBER in NUMBER,
  X_SCHOOL_NAME in VARCHAR2,
  X_COUNTRY_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) As
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
    x_person_id => x_person_id ,
    x_sequence_number => x_sequence_number ,
    x_result_obtained_yr => x_result_obtained_yr ,
    x_os_scndry_edu_qualification => x_os_scndry_edu_qualification ,
    x_result => x_result  ,
    x_candidate_number => x_candidate_number ,
    x_school_name => x_school_name ,
    x_country_cd => x_country_cd ,
    x_comments => x_comments ,
    x_creation_date=>X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY  ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );

  update IGS_AD_OS_SEC_EDU set
    RESULT_OBTAINED_YR = NEW_REFERENCES.RESULT_OBTAINED_YR,
    OS_SCNDRY_EDU_QUALIFICATION = NEW_REFERENCES.OS_SCNDRY_EDU_QUALIFICATION,
    RESULT = NEW_REFERENCES.RESULT,
    CANDIDATE_NUMBER = NEW_REFERENCES.CANDIDATE_NUMBER,
    SCHOOL_NAME = NEW_REFERENCES.SCHOOL_NAME,
    COUNTRY_CD = NEW_REFERENCES.COUNTRY_CD,
    COMMENTS = NEW_REFERENCES.COMMENTS,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_OS_SCNDRY_EDU_QUALIFICATION in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_CANDIDATE_NUMBER in NUMBER,
  X_SCHOOL_NAME in VARCHAR2,
  X_COUNTRY_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_OS_SEC_EDU
     where PERSON_ID = X_PERSON_ID
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
     X_SEQUENCE_NUMBER,
     X_RESULT_OBTAINED_YR,
     X_OS_SCNDRY_EDU_QUALIFICATION,
     X_RESULT,
     X_CANDIDATE_NUMBER,
     X_SCHOOL_NAME,
     X_COUNTRY_CD,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID ,
   X_PERSON_ID,
   X_SEQUENCE_NUMBER,
   X_RESULT_OBTAINED_YR,
   X_OS_SCNDRY_EDU_QUALIFICATION,
   X_RESULT,
   X_CANDIDATE_NUMBER,
   X_SCHOOL_NAME,
   X_COUNTRY_CD,
   X_COMMENTS,
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

  delete from IGS_AD_OS_SEC_EDU
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;


 After_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );


end DELETE_ROW;

end IGS_AD_OS_SEC_EDU_PKG;

/
