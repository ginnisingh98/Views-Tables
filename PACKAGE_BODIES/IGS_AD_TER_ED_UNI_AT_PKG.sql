--------------------------------------------------------
--  DDL for Package Body IGS_AD_TER_ED_UNI_AT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TER_ED_UNI_AT_PKG" as
/* $Header: IGSAI51B.pls 115.4 2002/11/28 22:08:07 nsidana ship $ */
-- Bg No 1956374 , Procedure admp_val_teua_sret reference is changed

  l_rowid VARCHAR2(25);
  old_references IGS_AD_TER_ED_UNI_AT%RowType;
  new_references IGS_AD_TER_ED_UNI_AT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_te_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_enrolled_yr IN NUMBER DEFAULT NULL,
    x_result_type IN VARCHAR2 DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_credit_points IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_TER_ED_UNI_AT
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND p_action NOT IN ('INSERT','VALIDATE_INSERT') THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.te_sequence_number := x_te_sequence_number;
    new_references.unit_cd := x_unit_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.enrolled_yr := x_enrolled_yr;
    new_references.result_type := x_result_type;
    new_references.title := x_title;
    new_references.credit_points := x_credit_points;
    new_references.grade := x_grade;
    new_references.discipline_group_cd := x_discipline_group_cd;
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
    ) as
	v_message_name VARCHAR2(30);
  BEGIN
	--
	-- Validate Tertiary Education unit Attempt
	--
	IF p_inserting
	OR (old_references.result_type <> new_references.result_type) THEN
		-- Validate Result Type
		IF IGS_AD_VAL_OSES.admp_val_teua_sret(
				new_references.result_type,
				v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
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
	ELSIF upper(Column_Name) = 'TE_SEQUENCE_NUMBER' then
		new_references.te_sequence_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'SEQUENCE_NUMBER' then
		new_references.sequence_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'CREDIT_POINTS' then
		new_references.credit_points := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'ENROLLED_YR' then
		new_references.enrolled_yr := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'DISCIPLINE_GROUP_CD' then
		new_references.discipline_group_cd := column_value;
	ELSIF upper(Column_Name) = 'UNIT_CD' then
		new_references.unit_cd := column_value;
	ELSIF upper(Column_Name) = 'GRADE' then
		new_references.grade := column_value;
	ELSIF upper(Column_Name) = 'TITLE' then
		new_references.title := column_value;
	ELSIF upper(Column_Name) = 'RESULT_TYPE' then
		new_references.result_type := column_value;
	END IF;

	IF upper(Column_Name) = 'TE_SEQUENCE_NUMBER' OR Column_Name IS NULL THEN
		IF new_references.te_sequence_number < 1 OR new_references.te_sequence_number > 999999 THEN
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
	IF upper(Column_Name) = 'CREDIT_POINTS' OR Column_Name IS NULL THEN
		IF new_references.credit_points < 0 OR new_references.credit_points > 999.999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'ENROLLED_YR' OR Column_Name IS NULL THEN
		IF new_references.enrolled_yr < 1900 OR new_references.enrolled_yr > 2050 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'DISCIPLINE_GROUP_CD' OR Column_Name IS NULL THEN
		IF new_references.discipline_group_cd <> UPPER(new_references.discipline_group_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'UNIT_CD' OR Column_Name IS NULL THEN
		IF new_references.unit_cd <> UPPER(new_references.unit_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'GRADE' OR Column_Name IS NULL THEN
		IF new_references.grade <> UPPER(new_references.grade) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'TITLE' OR Column_Name IS NULL THEN
		IF new_references.title <> UPPER(new_references.title) THEN
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

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.discipline_group_cd = new_references.discipline_group_cd)) OR
        ((new_references.discipline_group_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_DSCP_PKG.Get_PK_For_Validation (
        new_references.discipline_group_cd
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.te_sequence_number = new_references.te_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.te_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_TER_EDU_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.te_sequence_number
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

function Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_te_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_ED_UNI_AT
      WHERE    person_id = x_person_id
      AND      te_sequence_number = x_te_sequence_number
      AND      unit_cd = x_unit_cd
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

  PROCEDURE GET_FK_IGS_PS_DSCP (
    x_discipline_group_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_ED_UNI_AT
      WHERE    discipline_group_cd = x_discipline_group_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TEUA_DI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_DSCP;

  PROCEDURE GET_FK_IGS_AD_TER_EDU (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_ED_UNI_AT
      WHERE    person_id = x_person_id
      AND      te_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TEUA_TE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_TER_EDU;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_te_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_enrolled_yr IN NUMBER DEFAULT NULL,
    x_result_type IN VARCHAR2 DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_credit_points IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
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
      x_te_sequence_number,
      x_unit_cd,
      x_sequence_number,
      x_enrolled_yr,
      x_result_type,
      x_title,
      x_credit_points,
      x_grade,
      x_discipline_group_cd,
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
		new_references.person_id,
		new_references.te_sequence_number,
		new_references.unit_cd,
		new_references.sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.te_sequence_number,
		new_references.unit_cd,
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
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
  BEGIN
    l_rowid := x_rowid;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ENROLLED_YR in NUMBER,
  X_RESULT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_GRADE in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) As
    cursor C is select ROWID from IGS_AD_TER_ED_UNI_AT
      where PERSON_ID = X_PERSON_ID
      and TE_SEQUENCE_NUMBER = X_TE_SEQUENCE_NUMBER
      and UNIT_CD = X_UNIT_CD
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
     x_person_id => X_PERSON_ID,
     x_te_sequence_number => X_TE_SEQUENCE_NUMBER,
     x_unit_cd => X_UNIT_CD,
     x_sequence_number => X_SEQUENCE_NUMBER,
     x_enrolled_yr => X_ENROLLED_YR,
     x_result_type => X_RESULT_TYPE,
     x_title => X_TITLE,
     x_credit_points => X_CREDIT_POINTS,
     x_grade => X_GRADE,
     x_discipline_group_cd => X_DISCIPLINE_GROUP_CD,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_TER_ED_UNI_AT (
    PERSON_ID,
    TE_SEQUENCE_NUMBER,
    UNIT_CD,
    SEQUENCE_NUMBER,
    ENROLLED_YR,
    RESULT_TYPE,
    TITLE,
    CREDIT_POINTS,
    GRADE,
    DISCIPLINE_GROUP_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.TE_SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.ENROLLED_YR,
    NEW_REFERENCES.RESULT_TYPE,
    NEW_REFERENCES.TITLE,
    NEW_REFERENCES.CREDIT_POINTS,
    NEW_REFERENCES.GRADE,
    NEW_REFERENCES.DISCIPLINE_GROUP_CD,
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
     x_rowid => X_ROWID
    );
  end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ENROLLED_YR in NUMBER,
  X_RESULT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_GRADE in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2
) As
  cursor c1 is select
      ENROLLED_YR,
      RESULT_TYPE,
      TITLE,
      CREDIT_POINTS,
      GRADE,
      DISCIPLINE_GROUP_CD
    from IGS_AD_TER_ED_UNI_AT
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

  if ( (tlinfo.ENROLLED_YR = X_ENROLLED_YR)
      AND (tlinfo.RESULT_TYPE = X_RESULT_TYPE)
      AND ((tlinfo.TITLE = X_TITLE)
           OR ((tlinfo.TITLE is null)
               AND (X_TITLE is null)))
      AND ((tlinfo.CREDIT_POINTS = X_CREDIT_POINTS)
           OR ((tlinfo.CREDIT_POINTS is null)
               AND (X_CREDIT_POINTS is null)))
      AND ((tlinfo.GRADE = X_GRADE)
           OR ((tlinfo.GRADE is null)
               AND (X_GRADE is null)))
      AND ((tlinfo.DISCIPLINE_GROUP_CD = X_DISCIPLINE_GROUP_CD)
           OR ((tlinfo.DISCIPLINE_GROUP_CD is null)
               AND (X_DISCIPLINE_GROUP_CD is null)))
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
  X_TE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ENROLLED_YR in NUMBER,
  X_RESULT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_GRADE in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
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
  Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
     x_person_id => X_PERSON_ID,
     x_te_sequence_number => X_TE_SEQUENCE_NUMBER,
     x_unit_cd => X_UNIT_CD,
     x_sequence_number => X_SEQUENCE_NUMBER,
     x_enrolled_yr => X_ENROLLED_YR,
     x_result_type => X_RESULT_TYPE,
     x_title => X_TITLE,
     x_credit_points => X_CREDIT_POINTS,
     x_grade => X_GRADE,
     x_discipline_group_cd => X_DISCIPLINE_GROUP_CD,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_AD_TER_ED_UNI_AT set
    ENROLLED_YR = NEW_REFERENCES.ENROLLED_YR,
    RESULT_TYPE = NEW_REFERENCES.RESULT_TYPE,
    TITLE = NEW_REFERENCES.TITLE,
    CREDIT_POINTS = NEW_REFERENCES.CREDIT_POINTS,
    GRADE = NEW_REFERENCES.GRADE,
    DISCIPLINE_GROUP_CD = NEW_REFERENCES.DISCIPLINE_GROUP_CD,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID
    );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ENROLLED_YR in NUMBER,
  X_RESULT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_GRADE in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) As
  cursor c1 is select rowid from IGS_AD_TER_ED_UNI_AT
     where PERSON_ID = X_PERSON_ID
     and TE_SEQUENCE_NUMBER = X_TE_SEQUENCE_NUMBER
     and UNIT_CD = X_UNIT_CD
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
     X_TE_SEQUENCE_NUMBER,
     X_UNIT_CD,
     X_SEQUENCE_NUMBER,
     X_ENROLLED_YR,
     X_RESULT_TYPE,
     X_TITLE,
     X_CREDIT_POINTS,
     X_GRADE,
     X_DISCIPLINE_GROUP_CD,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_TE_SEQUENCE_NUMBER,
   X_UNIT_CD,
   X_SEQUENCE_NUMBER,
   X_ENROLLED_YR,
   X_RESULT_TYPE,
   X_TITLE,
   X_CREDIT_POINTS,
   X_GRADE,
   X_DISCIPLINE_GROUP_CD,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) As
begin
  Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );

  delete from IGS_AD_TER_ED_UNI_AT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_AD_TER_ED_UNI_AT_PKG;

/
