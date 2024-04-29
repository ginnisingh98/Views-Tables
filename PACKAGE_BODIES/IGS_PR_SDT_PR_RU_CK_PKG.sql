--------------------------------------------------------
--  DDL for Package Body IGS_PR_SDT_PR_RU_CK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_SDT_PR_RU_CK_PKG" AS
/* $Header: IGSQI17B.pls 115.7 2002/11/29 03:18:19 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PR_SDT_PR_RU_CK_ALL%RowType;
  new_references IGS_PR_SDT_PR_RU_CK_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_rule_check_dt IN DATE DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_passed_ind IN VARCHAR2 DEFAULT NULL,
    x_rule_message_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_SDT_PR_RU_CK_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.prg_cal_type := x_prg_cal_type;
    new_references.prg_ci_sequence_number := x_prg_ci_sequence_number;
    new_references.rule_check_dt := x_rule_check_dt;
    new_references.progression_rule_cat := x_progression_rule_cat;
    new_references.pra_sequence_number := x_pra_sequence_number;
    new_references.passed_ind := x_passed_ind;
    new_references.rule_message_text := x_rule_message_text;
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
    new_references.org_id := x_org_id;
  END Set_Column_Values;

   PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.progression_rule_cat = new_references.progression_rule_cat) AND
         (old_references.pra_sequence_number = new_references.pra_sequence_number)) OR
        ((new_references.progression_rule_cat IS NULL) OR
         (new_references.pra_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_RU_APPL_PKG.Get_PK_For_Validation (
        new_references.progression_rule_cat,
        new_references.pra_sequence_number
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.prg_cal_type = new_references.prg_cal_type) AND
         (old_references.prg_ci_sequence_number = new_references.prg_ci_sequence_number) AND
         (old_references.rule_check_dt = new_references.rule_check_dt)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.prg_cal_type IS NULL) OR
         (new_references.prg_ci_sequence_number IS NULL) OR
         (new_references.rule_check_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_STDNT_PR_CK_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd,
        new_references.prg_cal_type,
        new_references.prg_ci_sequence_number,
        new_references.rule_check_dt
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_STDNT_PR_OU_PKG.GET_FK_IGS_PR_SDT_PR_RU_CK (
      old_references.person_id,
      old_references.course_cd,
      old_references.prg_cal_type,
      old_references.prg_ci_sequence_number,
      old_references.progression_rule_cat,
      old_references.pra_sequence_number,
      old_references.rule_check_dt
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_rule_check_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_SDT_PR_RU_CK_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      prg_cal_type = x_prg_cal_type
      AND      prg_ci_sequence_number = x_prg_ci_sequence_number
      AND      progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_pra_sequence_number
      AND      rule_check_dt = x_rule_check_dt
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

  PROCEDURE GET_FK_IGS_PR_RU_APPL (
    x_progression_rule_cat IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_SDT_PR_RU_CK_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPRC_PRA_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RU_APPL;

  PROCEDURE GET_FK_IGS_PR_STDNT_PR_CK (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_rule_check_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_SDT_PR_RU_CK_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      prg_cal_type = x_prg_cal_type
      AND      prg_ci_sequence_number = x_prg_ci_sequence_number
      AND      rule_check_dt = x_rule_check_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPRC_SPCHK_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_STDNT_PR_CK;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_rule_check_dt IN DATE DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_rule_message_text IN VARCHAR2 DEFAULT NULL,
    x_passed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_course_cd,
      x_prg_cal_type,
      x_prg_ci_sequence_number,
      x_rule_check_dt,
      x_progression_rule_cat,
      x_pra_sequence_number,
      x_passed_ind,
      x_rule_message_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
       Check_Parent_Existance;
	IF GET_PK_FOR_VALIDATION(
		    new_references.person_id,
		    new_references.course_cd,
		    new_references.prg_cal_type,
		    new_references.prg_ci_sequence_number,
		    new_references.progression_rule_cat,
		    new_references.pra_sequence_number,
		    new_references.rule_check_dt) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	 CHECK_CONSTRAINTS;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       Check_Parent_Existance;
	CHECK_CONSTRAINTS;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
		    new_references.person_id,
		    new_references.course_cd,
		    new_references.prg_cal_type,
		    new_references.prg_ci_sequence_number,
		    new_references.progression_rule_cat,
		    new_references.pra_sequence_number,
		    new_references.rule_check_dt) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	 CHECK_CONSTRAINTS;

	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 CHECK_CONSTRAINTS;

	ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_PASSED_IND in VARCHAR2,
  X_RULE_MESSAGE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_PR_SDT_PR_RU_CK_ALL
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and PRG_CAL_TYPE = X_PRG_CAL_TYPE
      and PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER
      and PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
      and PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER
      and RULE_CHECK_DT = X_RULE_CHECK_DT;
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
    x_rowid => x_rowid ,
    x_person_id => x_person_id ,
    x_course_cd => x_course_cd ,
    x_prg_cal_type => x_prg_cal_type ,
    x_prg_ci_sequence_number => x_prg_ci_sequence_number ,
    x_rule_check_dt => x_rule_check_dt ,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_pra_sequence_number => x_pra_sequence_number ,
    x_rule_message_text => x_rule_message_text ,
    x_passed_ind => nvl( x_passed_ind, 'Y') ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login => x_last_update_login,
    x_org_id => igs_ge_gen_003.get_org_id
  );
  insert into IGS_PR_SDT_PR_RU_CK_ALL (
    PERSON_ID,
    COURSE_CD,
    PRG_CAL_TYPE,
    PRG_CI_SEQUENCE_NUMBER,
    RULE_CHECK_DT,
    PROGRESSION_RULE_CAT,
    PRA_SEQUENCE_NUMBER,
    PASSED_IND,
    RULE_MESSAGE_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.PRG_CAL_TYPE,
    NEW_REFERENCES.PRG_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.RULE_CHECK_DT,
    NEW_REFERENCES.PROGRESSION_RULE_CAT,
    NEW_REFERENCES.PRA_SEQUENCE_NUMBER,
    NEW_REFERENCES.PASSED_IND,
    NEW_REFERENCES.RULE_MESSAGE_TEXT,
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_PASSED_IND in VARCHAR2,
  X_RULE_MESSAGE_TEXT in VARCHAR2
) AS
  cursor c1 is select
      PERSON_ID,
      COURSE_CD,
      PRG_CAL_TYPE,
      PRG_CI_SEQUENCE_NUMBER,
      PROGRESSION_RULE_CAT ,
      PRA_SEQUENCE_NUMBER ,
      RULE_CHECK_DT ,
      PASSED_IND ,
      RULE_MESSAGE_TEXT
    from IGS_PR_SDT_PR_RU_CK_ALL
    where ROWID = X_ROWID for update nowait;
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

  if (
  (tlinfo.PERSON_ID = X_PERSON_ID) AND
  (tlinfo.COURSE_CD =X_COURSE_CD) AND
  (tlinfo.PRG_CAL_TYPE = X_PRG_CAL_TYPE) AND
  (tlinfo.PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER) AND
  (tlinfo.PROGRESSION_RULE_CAT =X_PROGRESSION_RULE_CAT) AND
  (tlinfo.PRA_SEQUENCE_NUMBER =X_PRA_SEQUENCE_NUMBER) AND
  (tlinfo.RULE_CHECK_DT =X_RULE_CHECK_DT) AND
  (tlinfo.PASSED_IND =X_PASSED_IND) AND
  ( (tlinfo.RULE_MESSAGE_TEXT =X_RULE_MESSAGE_TEXT)
     OR (( tlinfo.RULE_MESSAGE_TEXT is null)
         AND (X_RULE_MESSAGE_TEXT is null)))

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
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_PASSED_IND in VARCHAR2,
  X_RULE_MESSAGE_TEXT in VARCHAR2,
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
Before_DML (
    p_action => 'UPDATE',
    x_rowid => x_rowid ,
    x_person_id => x_person_id ,
    x_course_cd => x_course_cd ,
    x_prg_cal_type => x_prg_cal_type ,
    x_prg_ci_sequence_number => x_prg_ci_sequence_number ,
    x_rule_check_dt => x_rule_check_dt ,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_pra_sequence_number => x_pra_sequence_number ,
    x_rule_message_text => x_rule_message_text ,
    x_passed_ind => x_passed_ind ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login => x_last_update_login
    );

  update IGS_PR_SDT_PR_RU_CK_ALL set
    PASSED_IND = NEW_REFERENCES.PASSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_PASSED_IND in VARCHAR2,
  X_RULE_MESSAGE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PR_SDT_PR_RU_CK_ALL
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and PRG_CAL_TYPE = X_PRG_CAL_TYPE
     and PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER
     and PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
     and PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER
     and RULE_CHECK_DT = X_RULE_CHECK_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_PRG_CAL_TYPE,
     X_PRG_CI_SEQUENCE_NUMBER,
     X_PROGRESSION_RULE_CAT,
     X_PRA_SEQUENCE_NUMBER,
     X_RULE_CHECK_DT,
     X_PASSED_IND,
     X_RULE_MESSAGE_TEXT,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID ,
   X_PERSON_ID,
   X_COURSE_CD,
   X_PRG_CAL_TYPE,
   X_PRG_CI_SEQUENCE_NUMBER,
   X_PROGRESSION_RULE_CAT,
   X_PRA_SEQUENCE_NUMBER,
   X_RULE_CHECK_DT,
   X_PASSED_IND,
   X_RULE_MESSAGE_TEXT,
   X_MODE
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  ) ;
  delete from IGS_PR_SDT_PR_RU_CK_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
    BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'COURSE_CD' THEN
  new_references.COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PASSED_IND' THEN
  new_references.PASSED_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PRG_CAL_TYPE' THEN
  new_references.PRG_CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROGRESSION_RULE_CAT' THEN
  new_references.PROGRESSION_RULE_CAT:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PRA_SEQUENCE_NUMBER' THEN
  new_references.PRA_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'PRG_CI_SEQUENCE_NUMBER' THEN
  new_references.PRG_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.COURSE_CD<> upper(new_references.COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PASSED_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.PASSED_IND<> upper(new_references.PASSED_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.PASSED_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRG_CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRG_CAL_TYPE<> upper(new_references.PRG_CAL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PROGRESSION_RULE_CAT' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROGRESSION_RULE_CAT<> upper(new_references.PROGRESSION_RULE_CAT) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRA_SEQUENCE_NUMBER < 1 or new_references.PRA_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRG_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRG_CI_SEQUENCE_NUMBER < 1 or new_references.PRG_CI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

END Check_Constraints;


end IGS_PR_SDT_PR_RU_CK_PKG;

/
