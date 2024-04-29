--------------------------------------------------------
--  DDL for Package Body IGS_AD_AUS_SEC_ED_SU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_AUS_SEC_ED_SU_PKG" as
/* $Header: IGSAI68B.pls 115.5 2003/10/30 13:21:55 rghosh ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_AUS_SEC_ED_SU%RowType;
  new_references IGS_AD_AUS_SEC_ED_SU%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ase_sequence_number IN NUMBER DEFAULT NULL,
    x_subject_result_yr IN NUMBER DEFAULT NULL,
    x_subject_cd IN VARCHAR2 DEFAULT NULL,
    x_subject_desc IN VARCHAR2 DEFAULT NULL,
    x_subject_mark IN VARCHAR2 DEFAULT NULL,
    x_subject_mark_level IN VARCHAR2 DEFAULT NULL,
    x_subject_weighting IN VARCHAR2 DEFAULT NULL,
    x_subject_ass_type IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_AUS_SEC_ED_SU
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
    new_references.person_id := x_person_id;
    new_references.ase_sequence_number := x_ase_sequence_number;
    new_references.subject_result_yr := x_subject_result_yr;
    new_references.subject_cd := x_subject_cd;
    new_references.subject_desc := x_subject_desc;
    new_references.subject_mark := x_subject_mark;
    new_references.subject_mark_level := x_subject_mark_level;
    new_references.subject_weighting := x_subject_weighting;
    new_references.subject_ass_type := x_subject_ass_type;
    new_references.notes := x_notes;
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
	ELSIF upper(Column_Name) = 'SUBJECT_MARK' then
		new_references.subject_mark := column_value;
	ELSIF upper(Column_Name) = 'SUBJECT_MARK_LEVEL' then
		new_references.subject_mark_level := column_value;
	ELSIF upper(Column_Name) = 'SUBJECT_ASS_TYPE' then
		new_references.subject_ass_type := column_value;
	ELSIF upper(Column_Name) = 'SUBJECT_WEIGHTING' then
		new_references.subject_weighting := column_value;
	ELSIF upper(Column_Name) = 'SUBJECT_RESULT_YR' then
		new_references.subject_result_yr := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'ASE_SEQUENCE_NUMBER' then
		new_references.ase_sequence_number := igs_ge_number.to_num(column_value);
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
	IF upper(Column_Name) = 'SUBJECT_MARK' OR Column_Name IS NULL THEN
		IF new_references.subject_mark <> UPPER(new_references.subject_mark) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SUBJECT_MARK_LEVEL' OR Column_Name IS NULL THEN
		IF new_references.subject_mark_level <> UPPER(new_references.subject_mark_level) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SUBJECT_ASS_TYPE' OR Column_Name IS NULL THEN
		IF new_references.subject_ass_type <> UPPER(new_references.subject_ass_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SUBJECT_WEIGHTING' OR Column_Name IS NULL THEN
		IF new_references.subject_weighting <> UPPER(new_references.subject_weighting) THEN
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
	IF ((UPPER (column_name) = 'ASE_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      	IF ((new_references.ase_sequence_number < 1) OR (new_references.ase_sequence_number > 9999999999)) THEN
        		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        		IGS_GE_MSG_STACK.ADD;
        		App_Exception.Raise_Exception;
      	END IF;
	END IF;
  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.subject_ass_type = new_references.subject_ass_type)) OR
        ((new_references.subject_ass_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_AUSE_ED_AS_TY_PKG.Get_PK_For_Validation (
        new_references.subject_ass_type,
        'N'
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.ase_sequence_number = new_references.ase_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.ase_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_AUS_SEC_EDU_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.ase_sequence_number
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ase_sequence_number IN NUMBER,
    x_subject_result_yr IN NUMBER,
    x_subject_cd IN VARCHAR2
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUS_SEC_ED_SU
      WHERE    person_id = x_person_id
      AND      ase_sequence_number = x_ase_sequence_number
      AND      subject_result_yr = x_subject_result_yr
      AND      subject_cd = x_subject_cd
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

  PROCEDURE get_fk_igs_ad_ause_ed_as_ty (
    x_aus_scndry_edu_ass_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUS_SEC_ED_SU
      WHERE    subject_ass_type = x_aus_scndry_edu_ass_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
     Close cur_rowid;
     Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUSES_ASEAT_FK');
     IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END get_fk_igs_ad_ause_ed_as_ty;

  PROCEDURE GET_FK_IGS_AD_AUS_SEC_EDU (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUS_SEC_ED_SU
      WHERE    person_id = x_person_id
      AND      ase_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUSES_ASE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_AUS_SEC_EDU;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ase_sequence_number IN NUMBER DEFAULT NULL,
    x_subject_result_yr IN NUMBER DEFAULT NULL,
    x_subject_cd IN VARCHAR2 DEFAULT NULL,
    x_subject_desc IN VARCHAR2 DEFAULT NULL,
    x_subject_mark IN VARCHAR2 DEFAULT NULL,
    x_subject_mark_level IN VARCHAR2 DEFAULT NULL,
    x_subject_weighting IN VARCHAR2 DEFAULT NULL,
    x_subject_ass_type IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
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
      x_ase_sequence_number,
      x_subject_result_yr,
      x_subject_cd,
      x_subject_desc,
      x_subject_mark,
      x_subject_mark_level,
      x_subject_weighting,
      x_subject_ass_type,
      x_notes,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.ase_sequence_number,
		new_references.subject_result_yr,
		new_references.subject_cd
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	  Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
	  Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.ase_sequence_number,
		new_references.subject_result_yr,
		new_references.subject_cd
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
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_SUBJECT_MARK in VARCHAR2,
  X_SUBJECT_MARK_LEVEL in VARCHAR2,
  X_SUBJECT_WEIGHTING in VARCHAR2,
  X_SUBJECT_ASS_TYPE in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_AUS_SEC_ED_SU
      where PERSON_ID = X_PERSON_ID
      and ASE_SEQUENCE_NUMBER = X_ASE_SEQUENCE_NUMBER
      and SUBJECT_RESULT_YR = X_SUBJECT_RESULT_YR
      and SUBJECT_CD = X_SUBJECT_CD;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1) then
      X_REQUEST_ID := NULL;
      X_PROGRAM_ID := NULL;
      X_PROGRAM_APPLICATION_ID := NULL;
      X_PROGRAM_UPDATE_DATE := NULL;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML(
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_person_id=>X_PERSON_ID,
   x_ase_sequence_number=>X_ASE_SEQUENCE_NUMBER,
   x_subject_result_yr=>X_SUBJECT_RESULT_YR,
   x_subject_cd=>X_SUBJECT_CD,
   x_subject_desc=>X_SUBJECT_DESC,
   x_subject_mark=>X_SUBJECT_MARK,
   x_subject_mark_level=>X_SUBJECT_MARK_LEVEL,
   x_subject_weighting=>X_SUBJECT_WEIGHTING,
   x_subject_ass_type=>X_SUBJECT_ASS_TYPE,
   x_notes=>X_NOTES,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_AD_AUS_SEC_ED_SU (
    PERSON_ID,
    ASE_SEQUENCE_NUMBER,
    SUBJECT_RESULT_YR,
    SUBJECT_CD,
    SUBJECT_DESC,
    SUBJECT_MARK,
    SUBJECT_MARK_LEVEL,
    SUBJECT_WEIGHTING,
    SUBJECT_ASS_TYPE,
    NOTES,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ASE_SEQUENCE_NUMBER,
    NEW_REFERENCES.SUBJECT_RESULT_YR,
    NEW_REFERENCES.SUBJECT_CD,
    NEW_REFERENCES.SUBJECT_DESC,
    NEW_REFERENCES.SUBJECT_MARK,
    NEW_REFERENCES.SUBJECT_MARK_LEVEL,
    NEW_REFERENCES.SUBJECT_WEIGHTING,
    NEW_REFERENCES.SUBJECT_ASS_TYPE,
    NEW_REFERENCES.NOTES,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
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
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_SUBJECT_MARK in VARCHAR2,
  X_SUBJECT_MARK_LEVEL in VARCHAR2,
  X_SUBJECT_WEIGHTING in VARCHAR2,
  X_SUBJECT_ASS_TYPE in VARCHAR2,
  X_NOTES in VARCHAR2
) AS
  cursor c1 is select
      SUBJECT_DESC,
      SUBJECT_MARK,
      SUBJECT_MARK_LEVEL,
      SUBJECT_WEIGHTING,
      SUBJECT_ASS_TYPE,
      NOTES
    from IGS_AD_AUS_SEC_ED_SU
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

      if ( ((tlinfo.SUBJECT_DESC = X_SUBJECT_DESC)
           OR ((tlinfo.SUBJECT_DESC is null)
               AND (X_SUBJECT_DESC is null)))
      AND ((tlinfo.SUBJECT_MARK = X_SUBJECT_MARK)
           OR ((tlinfo.SUBJECT_MARK is null)
               AND (X_SUBJECT_MARK is null)))
      AND ((tlinfo.SUBJECT_MARK_LEVEL = X_SUBJECT_MARK_LEVEL)
           OR ((tlinfo.SUBJECT_MARK_LEVEL is null)
               AND (X_SUBJECT_MARK_LEVEL is null)))
      AND ((tlinfo.SUBJECT_WEIGHTING = X_SUBJECT_WEIGHTING)
           OR ((tlinfo.SUBJECT_WEIGHTING is null)
               AND (X_SUBJECT_WEIGHTING is null)))
      AND ((tlinfo.SUBJECT_ASS_TYPE = X_SUBJECT_ASS_TYPE)
           OR ((tlinfo.SUBJECT_ASS_TYPE is null)
               AND (X_SUBJECT_ASS_TYPE is null)))
      AND ((tlinfo.NOTES = X_NOTES)
           OR ((tlinfo.NOTES is null)
               AND (X_NOTES is null)))
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
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_SUBJECT_MARK in VARCHAR2,
  X_SUBJECT_MARK_LEVEL in VARCHAR2,
  X_SUBJECT_WEIGHTING in VARCHAR2,
  X_SUBJECT_ASS_TYPE in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
   x_person_id=>X_PERSON_ID,
   x_ase_sequence_number=>X_ASE_SEQUENCE_NUMBER,
   x_subject_result_yr=>X_SUBJECT_RESULT_YR,
   x_subject_cd=>X_SUBJECT_CD,
   x_subject_desc=>X_SUBJECT_DESC,
   x_subject_mark=>X_SUBJECT_MARK,
   x_subject_mark_level=>X_SUBJECT_MARK_LEVEL,
   x_subject_weighting=>X_SUBJECT_WEIGHTING,
   x_subject_ass_type=>X_SUBJECT_ASS_TYPE,
   x_notes=>X_NOTES,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  if (X_MODE = 'R') then
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1) then
      X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
      X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  end if;
  update IGS_AD_AUS_SEC_ED_SU set
    SUBJECT_DESC = NEW_REFERENCES.SUBJECT_DESC,
    SUBJECT_MARK = NEW_REFERENCES.SUBJECT_MARK,
    SUBJECT_MARK_LEVEL = NEW_REFERENCES.SUBJECT_MARK_LEVEL,
    SUBJECT_WEIGHTING = NEW_REFERENCES.SUBJECT_WEIGHTING,
    SUBJECT_ASS_TYPE = NEW_REFERENCES.SUBJECT_ASS_TYPE,
    NOTES = NEW_REFERENCES.NOTES,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE

  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID);

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_SUBJECT_MARK in VARCHAR2,
  X_SUBJECT_MARK_LEVEL in VARCHAR2,
  X_SUBJECT_WEIGHTING in VARCHAR2,
  X_SUBJECT_ASS_TYPE in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_AUS_SEC_ED_SU
     where PERSON_ID = X_PERSON_ID
     and ASE_SEQUENCE_NUMBER = X_ASE_SEQUENCE_NUMBER
     and SUBJECT_RESULT_YR = X_SUBJECT_RESULT_YR
     and SUBJECT_CD = X_SUBJECT_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ASE_SEQUENCE_NUMBER,
     X_SUBJECT_RESULT_YR,
     X_SUBJECT_CD,
     X_SUBJECT_DESC,
     X_SUBJECT_MARK,
     X_SUBJECT_MARK_LEVEL,
     X_SUBJECT_WEIGHTING,
     X_SUBJECT_ASS_TYPE,
     X_NOTES,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ASE_SEQUENCE_NUMBER,
   X_SUBJECT_RESULT_YR,
   X_SUBJECT_CD,
   X_SUBJECT_DESC,
   X_SUBJECT_MARK,
   X_SUBJECT_MARK_LEVEL,
   X_SUBJECT_WEIGHTING,
   X_SUBJECT_ASS_TYPE,
   X_NOTES,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_AD_AUS_SEC_ED_SU
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);
end DELETE_ROW;

end IGS_AD_AUS_SEC_ED_SU_PKG;

/
