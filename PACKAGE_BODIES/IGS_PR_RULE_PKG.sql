--------------------------------------------------------
--  DDL for Package Body IGS_PR_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_RULE_PKG" AS
/* $Header: IGSQI09B.pls 115.10 2003/05/19 06:14:14 ijeddy ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PR_RULE_ALL%RowType;
  new_references IGS_PR_RULE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_message IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_RULE_ALL
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
    new_references.progression_rule_cd := x_progression_rule_cd;
    new_references.description := x_description;
    new_references.rul_sequence_number := x_rul_sequence_number;
    new_references.closed_ind := x_closed_ind;
    new_references.message := x_message;
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

  -- Trigger description :-
  -- "OSS_TST".trg_prr_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_PR_RULE
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate the progression IGS_RU_RULE category
	IF p_inserting THEN
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_PR_VAL_PRR.PRGP_VAL_PRGC_CLOSED" to program unit "IGS_PR_VAL_PRA.PRGP_VAL_PRGC_CLOSED". -- kdande
*/
		IF IGS_PR_VAL_PRA.prgp_val_prgc_closed (
					new_references.progression_rule_cat,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;
  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.progression_rule_cat = new_references.progression_rule_cat)) OR
        ((new_references.progression_rule_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_RU_CAT_PKG.Get_PK_For_Validation (
        new_references.progression_rule_cat
        ) THEN

	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

	END IF;
    END IF;

    IF (((old_references.rul_sequence_number = new_references.rul_sequence_number)) OR
        ((new_references.rul_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_RULE_PKG.Get_PK_For_Validation (
        new_references.rul_sequence_number
        ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_RU_APPL_PKG.GET_FK_IGS_PR_RULE (
      old_references.progression_rule_cat,
      old_references.progression_rule_cd
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_progression_rule_cat IN VARCHAR2,
    x_progression_rule_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RULE_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      progression_rule_cd = x_progression_rule_cd
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

  PROCEDURE GET_FK_IGS_PR_RU_CAT (
    x_progression_rule_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RULE_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRR_PRGC_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RU_CAT;

  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RULE_ALL
      WHERE    rul_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRR_RUL_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_RULE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_message IN VARCHAR2 DEFAULT NULL,
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
      x_progression_rule_cat,
      x_progression_rule_cd,
      x_description,
      x_rul_sequence_number,
      x_closed_ind,
      x_message,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
       Check_Parent_Existance;

	IF Get_PK_For_Validation (
	    new_references.progression_rule_cat,
	    new_references.progression_rule_cd
			    ) THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
		IF Get_PK_For_Validation (
	    new_references.progression_rule_cat,
	    new_references.progression_rule_cd
			    ) THEN
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
/*
The (L_ROWID := null) was added by ijeddy on the 19-May-2003 as
part of the bug fix for bug no 2868726, (Uniqueness Check at Item Level)
*/
L_ROWID := null;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PROGRESSION_RULE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_PR_RULE_ALL
      where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
      and PROGRESSION_RULE_CD = X_PROGRESSION_RULE_CD;
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
    x_rowid => x_rowid,
    x_progression_rule_cat => x_progression_rule_cat,
    x_progression_rule_cd => x_progression_rule_cd,
    x_description => x_description,
    x_rul_sequence_number => x_rul_sequence_number,
    x_closed_ind => nvl( x_closed_ind, 'N'),
    x_message => x_message,
    x_creation_date => x_last_update_date,
    x_created_by =>  x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login,
    x_org_id=>igs_ge_gen_003.get_org_id
  ) ;
  insert into IGS_PR_RULE_ALL (
    PROGRESSION_RULE_CAT,
    PROGRESSION_RULE_CD,
    DESCRIPTION,
    RUL_SEQUENCE_NUMBER,
    CLOSED_IND,
    MESSAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PROGRESSION_RULE_CAT,
    NEW_REFERENCES.PROGRESSION_RULE_CD,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.MESSAGE,
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
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PROGRESSION_RULE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MESSAGE in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      RUL_SEQUENCE_NUMBER,
      CLOSED_IND,
      MESSAGE
    from IGS_PR_RULE_ALL
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
      AND (tlinfo.RUL_SEQUENCE_NUMBER = X_RUL_SEQUENCE_NUMBER)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.MESSAGE = X_MESSAGE)
           OR ((tlinfo.MESSAGE is null)
               AND (X_MESSAGE is null)))
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
  X_PROGRESSION_RULE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MESSAGE in VARCHAR2,
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
    x_progression_rule_cat => x_progression_rule_cat,
    x_progression_rule_cd => x_progression_rule_cd,
    x_description => x_description,
    x_rul_sequence_number => x_rul_sequence_number,
    x_closed_ind => x_closed_ind,
    x_message => x_message,
    x_creation_date => x_last_update_date,
    x_created_by =>  x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login

  ) ;

  update IGS_PR_RULE_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    RUL_SEQUENCE_NUMBER = NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    MESSAGE = NEW_REFERENCES.MESSAGE,
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
  X_PROGRESSION_RULE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PR_RULE_ALL
     where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
     and PROGRESSION_RULE_CD = X_PROGRESSION_RULE_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PROGRESSION_RULE_CAT,
     X_PROGRESSION_RULE_CD,
     X_DESCRIPTION,
     X_RUL_SEQUENCE_NUMBER,
     X_CLOSED_IND,
     X_MESSAGE,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID ,
   X_PROGRESSION_RULE_CAT,
   X_PROGRESSION_RULE_CD,
   X_DESCRIPTION,
   X_RUL_SEQUENCE_NUMBER,
   X_CLOSED_IND,
   X_MESSAGE,
   X_MODE
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_PR_RULE_ALL
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
ELSIF upper(Column_name) = 'CLOSED_IND' THEN
  new_references.CLOSED_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROGRESSION_RULE_CAT' THEN
  new_references.PROGRESSION_RULE_CAT:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROGRESSION_RULE_CD' THEN
  new_references.PROGRESSION_RULE_CD:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'CLOSED_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CLOSED_IND not in  ('Y','N') then
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

IF (Column_name) = 'PROGRESSION_RULE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROGRESSION_RULE_CD<> (new_references.PROGRESSION_RULE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

END Check_Constraints;

end IGS_PR_RULE_PKG;

/
