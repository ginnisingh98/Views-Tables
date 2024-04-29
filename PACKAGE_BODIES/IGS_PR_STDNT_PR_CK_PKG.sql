--------------------------------------------------------
--  DDL for Package Body IGS_PR_STDNT_PR_CK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_STDNT_PR_CK_PKG" AS
/* $Header: IGSQI14B.pls 120.0 2005/07/05 12:13:57 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PR_STDNT_PR_CK%RowType;
  new_references IGS_PR_STDNT_PR_CK%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_rule_check_dt IN DATE DEFAULT NULL,
    x_s_prg_check_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_STDNT_PR_CK
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
    new_references.s_prg_check_type := x_s_prg_check_type;
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

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.prg_cal_type = new_references.prg_cal_type) AND
         (old_references.prg_ci_sequence_number = new_references.prg_ci_sequence_number)) OR
        ((new_references.prg_cal_type IS NULL) OR
         (new_references.prg_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.prg_cal_type,
        new_references.prg_ci_sequence_number
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.s_prg_check_type = new_references.s_prg_check_type)) OR
        ((new_references.s_prg_check_type IS NULL))) THEN
      NULL;
    ELSE

      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
	'PRG_CHECK_TYPE',
        new_references.s_prg_check_type
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;


    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_SDT_PR_RU_CK_PKG.GET_FK_IGS_PR_STDNT_PR_CK (
      old_references.person_id,
      old_references.course_cd,
      old_references.prg_cal_type,
      old_references.prg_ci_sequence_number,
      old_references.rule_check_dt
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_rule_check_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_STDNT_PR_CK
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      prg_cal_type = x_prg_cal_type
      AND      prg_ci_sequence_number = x_prg_ci_sequence_number
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

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_STDNT_PR_CK
      WHERE    prg_cal_type = x_cal_type
      AND      prg_ci_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPCHK_CI_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_STDNT_PR_CK
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPCHK_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_prg_check_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_STDNT_PR_CK
      WHERE    s_prg_check_type = x_s_prg_check_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPCHK_SPCT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_rule_check_dt IN DATE DEFAULT NULL,
    x_s_prg_check_type IN VARCHAR2 DEFAULT NULL,
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
      x_course_cd,
      x_prg_cal_type,
      x_prg_ci_sequence_number,
      x_rule_check_dt,
      x_s_prg_check_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Check_Parent_Existance;
	IF GET_PK_FOR_VALIDATION(
	    new_references.person_id ,
	    new_references.course_cd ,
	    new_references.prg_cal_type,
	    new_references.prg_ci_sequence_number,
	    new_references.rule_check_dt)  THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
	    new_references.person_id ,
	    new_references.course_cd ,
	    new_references.prg_cal_type,
	    new_references.prg_ci_sequence_number,
	    new_references.rule_check_dt)  THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  X_RULE_CHECK_DT in DATE,
  X_S_PRG_CHECK_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PR_STDNT_PR_CK
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and PRG_CAL_TYPE = X_PRG_CAL_TYPE
      and PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER
      and RULE_CHECK_DT = X_RULE_CHECK_DT;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
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
    x_s_prg_check_type => x_s_prg_check_type ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login => x_last_update_login
  ) ;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_PR_STDNT_PR_CK (
    PERSON_ID,
    COURSE_CD,
    PRG_CAL_TYPE,
    PRG_CI_SEQUENCE_NUMBER,
    RULE_CHECK_DT,
    S_PRG_CHECK_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.PRG_CAL_TYPE,
    NEW_REFERENCES.PRG_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.RULE_CHECK_DT,
    NEW_REFERENCES.S_PRG_CHECK_TYPE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_S_PRG_CHECK_TYPE in VARCHAR2
) AS
  cursor c1 is select
      S_PRG_CHECK_TYPE
    from IGS_PR_STDNT_PR_CK
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

  if ( (tlinfo.S_PRG_CHECK_TYPE = X_S_PRG_CHECK_TYPE)
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
  X_RULE_CHECK_DT in DATE,
  X_S_PRG_CHECK_TYPE in VARCHAR2,
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
  elsif (X_MODE IN ('R', 'S')) then
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
    x_s_prg_check_type => x_s_prg_check_type ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login => x_last_update_login
  ) ;


  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_PR_STDNT_PR_CK set
    S_PRG_CHECK_TYPE = NEW_REFERENCES.S_PRG_CHECK_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_S_PRG_CHECK_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PR_STDNT_PR_CK
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and PRG_CAL_TYPE = X_PRG_CAL_TYPE
     and PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER
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
     X_RULE_CHECK_DT,
     X_S_PRG_CHECK_TYPE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_PRG_CAL_TYPE,
   X_PRG_CI_SEQUENCE_NUMBER,
   X_RULE_CHECK_DT,
   X_S_PRG_CHECK_TYPE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) is
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  ) ;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_PR_STDNT_PR_CK
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

end DELETE_ROW;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) IS
    BEGIN

	IF column_name IS NULL THEN
		NULL;
	ELSIF upper(Column_name) = 'PRG_CI_SEQUENCE_NUMBER' THEN
		new_references.prg_ci_sequence_number  := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'COURSE_CD' THEN
		new_references.course_cd := column_value;
	ELSIF upper(Column_name) = 'PRG_CAL_TYPE' THEN
		new_references.prg_cal_type := column_value;
	ELSIF upper(Column_name) = 'S_PRG_CHECK_TYPE' THEN
		new_references.s_prg_check_type := column_value;
	END IF;

	IF upper(Column_name) = 'PRG_CI_SEQUENCE_NUMBER' OR column_name IS NULL THEN
		IF    new_references.prg_ci_sequence_number < 1
      	AND  new_references.prg_ci_sequence_number  > 999999 THEN
      	  Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	     END IF;
	END IF;
	IF upper(Column_name) = 'COURSE_CD' OR column_name IS NULL THEN
	   IF	new_references.course_cd <> UPPER(new_references.course_cd) THEN
	        Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      	  App_Exception.Raise_Exception;
         END IF;
	END IF;
	  IF upper(Column_name) = 'PRG_CAL_TYPE'  OR column_name IS NULL THEN
	   IF new_references.prg_cal_type <> UPPER(new_references.prg_cal_type)  THEN
	        Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	   END IF;
      END IF;
	IF upper(Column_name) = 'S_PRG_CHECK_TYPE' OR column_name IS NULL THEN
	   IF new_references.s_prg_check_type <> UPPER(new_references.s_prg_check_type) THEN
	        Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	   END IF;
	END IF;
END Check_Constraints;

end IGS_PR_STDNT_PR_CK_PKG;

/
