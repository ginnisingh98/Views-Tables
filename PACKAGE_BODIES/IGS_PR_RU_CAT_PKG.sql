--------------------------------------------------------
--  DDL for Package Body IGS_PR_RU_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_RU_CAT_PKG" AS
/* $Header: IGSQI11B.pls 115.6 2003/05/19 04:46:43 ijeddy ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PR_RU_CAT%RowType;
  new_references IGS_PR_RU_CAT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_rule_call_cd IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_message IN VARCHAR2 DEFAULT NULL,
    x_positive_rule_ind IN VARCHAR2 DEFAULT 'N',
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_RU_CAT
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
    new_references.progression_rule_cat := x_progression_rule_cat;
    new_references.description := x_description;
    new_references.s_rule_call_cd := x_s_rule_call_cd;
    new_references.closed_ind := x_closed_ind;
    new_references.message := x_message;
    new_references.positive_rule_ind := x_positive_rule_ind;
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
  -- "OSS_TST".trg_prgc_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_PR_RU_CAT
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate the system IGS_RU_RULE call code can be changed
	IF (p_updating AND new_references.s_rule_call_cd <> old_references.s_rule_call_cd) THEN
		IF IGS_PR_VAL_PRGC.prgp_val_prgc_upd (
					new_references.progression_rule_cat,
					old_references.s_rule_call_cd,
					new_references.s_rule_call_cd,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the system IGS_RU_RULE call code
	IF p_inserting OR
	  (p_updating AND new_references.s_rule_call_cd <> old_references.s_rule_call_cd) THEN
		IF IGS_PR_VAL_PRGC.prgp_val_src_prg (
					new_references.s_rule_call_cd,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;
  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.s_rule_call_cd = new_references.s_rule_call_cd)) OR
        ((new_references.s_rule_call_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_CALL_PKG.Get_PK_For_Validation (
        new_references.s_rule_call_cd
        ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_RULE_PKG.GET_FK_IGS_PR_RU_CAT (
      old_references.progression_rule_cat
      );

    IGS_PR_RU_APPL_PKG.GET_FK_IGS_PR_RU_CAT (
      old_references.progression_rule_cat
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_progression_rule_cat IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_CAT
      WHERE    progression_rule_cat = x_progression_rule_cat
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


  PROCEDURE GET_FK_IGS_RU_CALL (
    x_s_rule_call_cd IN VARCHAR2
    ) IS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_CAT
      WHERE    s_rule_call_cd = x_s_rule_call_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRGC_SRC_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_CALL;


 PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_rule_call_cd IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_message IN VARCHAR2 DEFAULT NULL,
    x_positive_rule_ind IN VARCHAR2 DEFAULT 'N',
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
      x_progression_rule_cat,
      x_description,
      x_s_rule_call_cd,
      x_closed_ind,
      x_message,
      x_positive_rule_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      Check_Parent_Existance;
	IF GET_PK_FOR_VALIDATION(
    			new_references.progression_rule_cat) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;
	CHECK_CONSTRAINTS;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Parent_Existance;
	CHECK_CONSTRAINTS;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
		IF GET_PK_FOR_VALIDATION(
    			new_references.progression_rule_cat) THEN
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


/*
The (L_ROWID := null) was added by ijeddy on the 12-apr-2003 as
part of the bug fix for bug no 2868726, (Uniqueness Check at Item Level)
*/
L_ROWID := null;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_POSITIVE_RULE_IND IN VARCHAR2 DEFAULT 'N',
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PR_RU_CAT
      where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT;
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
    x_progression_rule_cat => x_progression_rule_cat ,
    x_description => x_description ,
    x_s_rule_call_cd => x_s_rule_call_cd ,
    x_closed_ind => nvl( x_closed_ind, 'N'),
    x_message => x_message ,
    x_positive_rule_ind => x_positive_rule_ind,
    x_creation_date => x_last_update_date,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login => x_last_update_login
  );

  insert into IGS_PR_RU_CAT (
    PROGRESSION_RULE_CAT,
    DESCRIPTION,
    S_RULE_CALL_CD,
    CLOSED_IND,
    MESSAGE,
    POSITIVE_RULE_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PROGRESSION_RULE_CAT,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.S_RULE_CALL_CD,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.MESSAGE,
    NEW_REFERENCES.POSITIVE_RULE_IND,
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
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_POSITIVE_RULE_IND IN VARCHAR2 DEFAULT 'N'
) AS
  cursor c1 is select
      DESCRIPTION,
      S_RULE_CALL_CD,
      CLOSED_IND,
      MESSAGE,
      POSITIVE_RULE_IND
    from IGS_PR_RU_CAT
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.S_RULE_CALL_CD = X_S_RULE_CALL_CD)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.MESSAGE = X_MESSAGE)
           OR ((tlinfo.MESSAGE is null)
               AND (X_MESSAGE is null)))
     AND ((tlinfo.POSITIVE_RULE_IND = X_POSITIVE_RULE_IND)
         OR (( tlinfo.POSITIVE_RULE_IND IS NULL) AND (X_POSITIVE_RULE_IND IS NULL)))
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
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_POSITIVE_RULE_IND IN VARCHAR2 DEFAULT 'N',
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
    x_rowid => x_rowid,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_description => x_description ,
    x_s_rule_call_cd => x_s_rule_call_cd ,
    x_closed_ind => x_closed_ind ,
    x_message => x_message ,
    x_positive_rule_ind => x_positive_rule_ind,
    x_creation_date => x_last_update_date,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login => x_last_update_login
  );


  update IGS_PR_RU_CAT set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    S_RULE_CALL_CD = NEW_REFERENCES.S_RULE_CALL_CD,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    MESSAGE = NEW_REFERENCES.MESSAGE,
    POSITIVE_RULE_IND = NEW_REFERENCES.POSITIVE_RULE_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_POSITIVE_RULE_IND IN VARCHAR2 DEFAULT 'N',
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PR_RU_CAT
     where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PROGRESSION_RULE_CAT,
     X_DESCRIPTION,
     X_S_RULE_CALL_CD,
     X_CLOSED_IND,
     X_MESSAGE,
     X_POSITIVE_RULE_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID ,
   X_PROGRESSION_RULE_CAT,
   X_DESCRIPTION,
   X_S_RULE_CALL_CD,
   X_CLOSED_IND,
   X_MESSAGE,
   X_POSITIVE_RULE_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_PR_RU_CAT
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
	IF column_name IS NULL THEN
		NULL;
	ELSIF upper(Column_name) = 'CLOSED_IND' then
	    new_references.closed_ind := column_value;
	ELSIF upper(Column_name) = 'PROGRESSION_RULE_CAT'  then
	    new_references.progression_rule_cat := column_value;
	ELSIF upper(Column_name) = 'S_RULE_CALL_CD' then
	    new_references.s_rule_call_cd:= column_value;
	END IF;

IF UPPER(column_name) = 'CLOSED_IND'  OR column_name IS NULL THEN

		IF new_references.closed_ind NOT IN ('Y','N') THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;



IF UPPER(column_name) = 'PROGRESSION_RULE_CAT' OR column_name IS NULL THEN
		IF new_references.progression_rule_cat <> UPPER(new_references.progression_rule_cat) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;

IF UPPER(column_name) = 'S_RULE_CALL_CD' OR column_name IS NULL THEN
		IF new_references.s_rule_call_cd <> UPPER(new_references.s_rule_call_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;

END Check_Constraints;

end IGS_PR_RU_CAT_PKG;

/
